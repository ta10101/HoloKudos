use tauri_plugin_holochain::{HolochainExt, HolochainPluginConfig};

const APP_ID: &str = "holokudos";

// The compiled .happ is embedded in the binary at compile time.
// Run build.sh first to produce this file.
const HAPP: &[u8] =
    include_bytes!("../../../holokudos-happ/workdir/holokudos.happ");

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_holochain::init(
            HolochainPluginConfig::new(
                holochain_bin(),
                lair_bin(),
            ),
        ))
        .setup(|app| {
            let handle = app.handle().clone();
            tauri::async_runtime::spawn(async move {
                if let Err(e) = startup(handle).await {
                    eprintln!("HoloKudos startup error: {e:?}");
                }
            });
            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error running HoloKudos");
}

async fn startup(handle: tauri::AppHandle) -> anyhow::Result<()> {
    let admin = handle.holochain()?.admin_websocket().await?;

    // Install the hApp only if this is the first launch
    let installed = admin.list_apps(None).await?;
    if !installed.iter().any(|a| a.installed_app_id == APP_ID) {
        use holochain_client::{AppBundleSource, InstallAppPayload};
        use holochain_types::app::AppBundle;
        use std::collections::HashMap;

        admin.install_app(InstallAppPayload {
            source: AppBundleSource::Bundle(AppBundle::decode(HAPP)?),
            agent_key: None,
            installed_app_id: Some(APP_ID.into()),
            membrane_proofs: HashMap::new(),
            network_seed: None,
            ignore_genesis_failure: false,
        }).await?;

        admin.enable_app(APP_ID.into()).await?;
    }

    // Open a Tauri window for this app.
    // The plugin sets window.__HC_LAUNCHER_ENV__ so the UI auto-connects.
    handle.holochain()?.open_app_window(APP_ID.into()).await?;

    Ok(())
}

/// Returns path to the bundled holochain binary (next to the .exe).
fn holochain_bin() -> std::path::PathBuf {
    let mut p = std::env::current_exe().unwrap();
    p.pop();
    p.push(if cfg!(windows) { "holochain.exe" } else { "holochain" });
    p
}

/// Returns path to the bundled lair-keystore binary.
fn lair_bin() -> std::path::PathBuf {
    let mut p = std::env::current_exe().unwrap();
    p.pop();
    p.push(if cfg!(windows) { "lair-keystore.exe" } else { "lair-keystore" });
    p
}
