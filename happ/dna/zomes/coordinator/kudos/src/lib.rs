use hdk::prelude::*;
use kudos_integrity::*;

fn all_kudos_anchor() -> ExternResult<EntryHash> {
    Path::from("all_kudos").path_entry_hash()
}

/// Called by UI: give a kudo to another agent.
#[hdk_extern]
pub fn create_kudo(kudo: Kudo) -> ExternResult<ActionHash> {
    let recipient = kudo.recipient.clone();

    let action_hash = create_entry(EntryTypes::Kudo(kudo))?;

    // Link from global anchor so anyone can browse all kudos
    let anchor = all_kudos_anchor()?;
    create_link(anchor, action_hash.clone(), LinkTypes::AllKudos, ())?;

    // Link from recipient's agent key so we can look up kudos they received
    create_link(recipient, action_hash.clone(), LinkTypes::KudosForRecipient, ())?;

    Ok(action_hash)
}

/// Called by UI: fetch every kudo on the DHT.
#[hdk_extern]
pub fn get_all_kudos(_: ()) -> ExternResult<Vec<Record>> {
    let anchor = all_kudos_anchor()?;
    let links = get_links(
        GetLinksInputBuilder::try_new(anchor, LinkTypes::AllKudos)?.build(),
    )?;
    records_from_links(links)
}

/// Called by UI: fetch kudos received by a specific agent.
#[hdk_extern]
pub fn get_kudos_for_agent(agent: AgentPubKey) -> ExternResult<Vec<Record>> {
    let links = get_links(
        GetLinksInputBuilder::try_new(agent, LinkTypes::KudosForRecipient)?.build(),
    )?;
    records_from_links(links)
}

/// Called by UI: return this conductor's agent key so the UI knows who "you" are.
#[hdk_extern]
pub fn whoami(_: ()) -> ExternResult<AgentPubKey> {
    agent_info().map(|i| i.agent_latest_pubkey)
}

fn records_from_links(links: Vec<Link>) -> ExternResult<Vec<Record>> {
    let mut records = Vec::new();
    for link in links {
        if let Ok(Some(action_hash)) = ActionHash::try_from(link.target.clone())
            .map(Some)
            .or_else(|_| Ok::<_, WasmError>(None))
        {
            if let Some(record) = get(action_hash, GetOptions::default())? {
                records.push(record);
            }
        }
    }
    Ok(records)
}
