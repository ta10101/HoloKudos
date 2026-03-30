use hdi::prelude::*;

/// A kudo given from one agent to another.
/// The giver is always the author of the action (implicit from the source chain).
#[hdk_entry_helper]
#[derive(Clone)]
pub struct Kudo {
    pub recipient: AgentPubKey,
    pub category: String, // "collab" | "code" | "mentor" | "idea" | "help" | "comms"
    pub message: String,
}

#[hdk_entry_types]
#[unit_enum(UnitEntryTypes)]
pub enum EntryTypes {
    Kudo(Kudo),
}

#[hdk_link_types]
pub enum LinkTypes {
    /// Global anchor → ActionHash  (browse all kudos)
    AllKudos,
    /// Recipient AgentPubKey → ActionHash  (kudos received by an agent)
    KudosForRecipient,
}

#[hdk_extern]
pub fn validate(op: Op) -> ExternResult<ValidateCallbackResult> {
    match op.flattened::<EntryTypes, LinkTypes>()? {
        FlatOp::StoreEntry(store_entry) => match store_entry {
            OpEntry::CreateEntry { app_entry, .. } | OpEntry::UpdateEntry { app_entry, .. } => {
                match app_entry {
                    EntryTypes::Kudo(kudo) => validate_kudo(kudo),
                }
            }
            _ => Ok(ValidateCallbackResult::Valid),
        },
        _ => Ok(ValidateCallbackResult::Valid),
    }
}

fn validate_kudo(kudo: Kudo) -> ExternResult<ValidateCallbackResult> {
    if kudo.message.trim().is_empty() {
        return Ok(ValidateCallbackResult::Invalid("Kudo message cannot be empty".into()));
    }
    if kudo.message.len() > 500 {
        return Ok(ValidateCallbackResult::Invalid("Kudo message too long (max 500 chars)".into()));
    }
    let valid_cats = ["collab", "code", "mentor", "idea", "help", "comms"];
    if !valid_cats.contains(&kudo.category.as_str()) {
        return Ok(ValidateCallbackResult::Invalid(format!("Invalid category: {}", kudo.category)));
    }
    Ok(ValidateCallbackResult::Valid)
}
