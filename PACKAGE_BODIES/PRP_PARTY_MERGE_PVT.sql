--------------------------------------------------------
--  DDL for Package Body PRP_PARTY_MERGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PRP_PARTY_MERGE_PVT" AS
/* $Header: PRPVPMGB.pls 115.0 2003/04/02 00:12:51 vpalaiya noship $ */

  --
  -- Start of Comments
  --
  -- NAME
  --   PRP_PARTY_MERGE_PVT
  --
  -- PURPOSE
  --
  -- NOTES
  --
  --+

G_PKG_NAME  CONSTANT VARCHAR2(30):='PRP_PARTY_MERGE_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12):='PRPVPMGB.pls';

----------------------------------------------------------------------------
-- PUBLIC PROCEDURES
--   Merge_Proposals
--    When in ERP Parties are merged, the foriegn keys to party_id and other
--    columns should also be updated in Proposal tables. This procedure will
--    update PRP_PROPOSALS table and will be called from party merge
--    concurrent program.
--
-- DESCRIPTION
--
-- REQUIRES
--
-- EXCEPTIONS RAISED
--
-- KNOWN BUGS
--
-- NOTES
--
-- HISTORY
--
----------------------------------------------------------------------------+
PROCEDURE Merge_Proposals
  (
   p_entity_name                 IN VARCHAR2,
   p_from_id                     IN NUMBER,
   x_to_id                       OUT NOCOPY NUMBER,
   p_from_fk_id                  IN NUMBER,
   p_to_fk_id                    IN NUMBER,
   p_parent_entity_name          IN VARCHAR2,
   p_batch_id                    IN NUMBER,
   p_batch_party_id              IN NUMBER,
   x_return_status               OUT NOCOPY VARCHAR2
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Merge_Proposals';
  l_api_version                  CONSTANT NUMBER       := 1.0;
  l_count                        NUMBER(10)            := 0;

  -- Get all the rows from PRP_PROPOSALS that are to be merged and lock them
  CURSOR c1 IS SELECT 1 FROM prp_proposals
    WHERE party_id = p_from_fk_id
    OR contact_party_id = p_from_fk_id
    FOR UPDATE NOWAIT;

BEGIN

  -- Log message
  arp_message.set_line(G_PKG_NAME || '.' || l_api_name || '()+');

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Do All Validations
  --

  -- Check the Merge Reason code. If the merge reason is duplicate record,
  -- then no validation is required. Otherwise do the required validations.

  -- Commenting this section for now as we are not doing any validations,
  -- if the reason is not 'Duplicate Record'. In future if we need any
  -- validations we can uncomment this sections and add validations.

  -- SELECT merge_reason_code INTO l_merge_reason_code
  -- FROM hz_merge_batch
  -- WHERE batch_id = p_batch_id;

  -- IF l_merge_reason_code = 'DUPLICATE' THEN
  -- NULL;
  -- ELSE
  -- NULL;
  -- END IF;

  --
  -- Perform the merge operation
  --

  -- If the parent has not changed (i.e. parent is getting transfered),
  -- then nothing needs to be done. Set Merge To id same as Merged From id
  -- and return.
  IF p_from_fk_id = p_to_fk_id THEN
    x_to_id := p_from_id;
    RETURN;
  END IF;

  --
  -- If the parent has changed (i.e. parent is getting merged), then transfer
  -- the dependent record to the new parent.
  --
  IF p_from_fk_id <> p_to_fk_id THEN

    IF p_parent_entity_name = 'HZ_PARTIES' THEN

      -- Log message
      arp_message.set_name('AR', 'AR_LOCKING_TABLE');
      arp_message.set_token('TABLE_NAME', 'PRP_PROPOSALS', FALSE);

      -- Lock table
      OPEN C1;
      CLOSE C1;

      -- Log message
      arp_message.set_name('AR', 'AR_UPDATING_TABLE');
      arp_message.set_token('TABLE_NAME','PRP_PROPOSALS', FALSE);

      -- Update table
      UPDATE prp_proposals SET
        party_id = DECODE(party_id, p_from_fk_id, p_to_fk_id, party_id),
        contact_party_id = DECODE(contact_party_id, p_from_fk_id, p_to_fk_id,
                                  contact_party_id),
        last_update_date = hz_utility_pub.last_update_date,
        last_updated_by  = hz_utility_pub.user_id,
        last_update_login = hz_utility_pub.last_update_login,
        program_id = hz_utility_pub.program_id,
        program_login_id = hz_utility_pub.last_update_login,
        program_application_id = hz_utility_pub.program_application_id,
        request_id = hz_utility_pub.request_id
        WHERE party_id = p_from_fk_id
        OR contact_party_id = p_from_fk_id;

      -- Get the row count
      l_count := sql%rowcount;

      -- Log message
      arp_message.set_name('AR', 'AR_ROWS_UPDATED');
      arp_message.set_token('NUM_ROWS', to_char(l_count));

    END IF;

  END IF;

  -- Log message
  arp_message.set_line(G_PKG_NAME || '.' || l_api_name || '()-');

EXCEPTION

   WHEN OTHERS THEN
     arp_message.set_line
     (
     G_PKG_NAME || '.' || l_api_name || '():'
     || 'sqlerrm=' || SQLERRM || ','
     || 'sqlcode=' || SQLCODE
     );
     x_return_status :=  FND_API.G_RET_STS_ERROR;
     RAISE;

END Merge_Proposals;

----------------------------------------------------------------------------
-- PUBLIC PROCEDURES
--   Merge_Email_Recipients
--    When in ERP Parties are merged, the foriegn keys to party_id and other
--    columns should also be updated in Proposal tables. This procedure will
--    update PRP_EMAIL_RECIPIENTS table and will be called from party merge
--    concurrent program.
--
-- DESCRIPTION
--
-- REQUIRES
--
-- EXCEPTIONS RAISED
--
-- KNOWN BUGS
--
-- NOTES
--
-- HISTORY
--
----------------------------------------------------------------------------+
PROCEDURE Merge_Email_Recipients
  (
   p_entity_name                 IN VARCHAR2,
   p_from_id                     IN NUMBER,
   x_to_id                       OUT NOCOPY NUMBER,
   p_from_fk_id                  IN NUMBER,
   p_to_fk_id                    IN NUMBER,
   p_parent_entity_name          IN VARCHAR2,
   p_batch_id                    IN NUMBER,
   p_batch_party_id              IN NUMBER,
   x_return_status               OUT NOCOPY VARCHAR2
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Merge_Email_Recipients';
  l_api_version                  CONSTANT NUMBER       := 1.0;
  l_count                        NUMBER(10)            := 0;

  -- Get all the rows from PRP_EMAIL_RECIPIENTS that are to be merged
  -- and lock them
  CURSOR c1 IS SELECT 1 FROM prp_email_recipients
    WHERE party_id = p_from_fk_id
    FOR UPDATE NOWAIT;

BEGIN

  -- Log message
  arp_message.set_line(G_PKG_NAME || '.' || l_api_name || '()+');

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Do All Validations
  --

  -- Check the Merge Reason code. If the merge reason is duplicate record,
  -- then no validation is required. Otherwise do the required validations.

  -- Commenting this section for now as we are not doing any validations,
  -- if the reason is not 'Duplicate Record'. In future if we need any
  -- validations we can uncomment this sections and add validations.

  -- SELECT merge_reason_code INTO l_merge_reason_code
  -- FROM hz_merge_batch
  -- WHERE batch_id = p_batch_id;

  -- IF l_merge_reason_code = 'DUPLICATE' THEN
  -- NULL;
  -- ELSE
  -- NULL;
  -- END IF;

  --
  -- Perform the merge operation
  --

  -- If the parent has not changed (i.e. parent is getting transfered),
  -- then nothing needs to be done. Set Merge To id same as Merged From id
  -- and return.
  IF p_from_fk_id = p_to_fk_id THEN
    x_to_id := p_from_id;
    RETURN;
  END IF;

  --
  -- If the parent has changed (i.e. parent is getting merged), then transfer
  -- the dependent record to the new parent.
  --
  IF p_from_fk_id <> p_to_fk_id THEN

    IF p_parent_entity_name = 'HZ_PARTIES' THEN

      -- Log message
      arp_message.set_name('AR', 'AR_LOCKING_TABLE');
      arp_message.set_token('TABLE_NAME', 'PRP_EMAIL_RECIPIENTS', FALSE);

      -- Lock table
      OPEN C1;
      CLOSE C1;

      -- Log message
      arp_message.set_name('AR', 'AR_UPDATING_TABLE');
      arp_message.set_token('TABLE_NAME','PRP_EMAIL_RECIPIENTS', FALSE);

      -- Update table
      UPDATE prp_email_recipients SET
        party_id = p_to_fk_id,
        last_update_date = hz_utility_pub.last_update_date,
        last_updated_by  = hz_utility_pub.user_id,
        last_update_login = hz_utility_pub.last_update_login,
        program_id = hz_utility_pub.program_id,
        program_login_id = hz_utility_pub.last_update_login,
        program_application_id = hz_utility_pub.program_application_id,
        request_id = hz_utility_pub.request_id
        WHERE party_id = p_from_fk_id;

      -- Get the row count
      l_count := sql%rowcount;

      -- Log message
      arp_message.set_name('AR', 'AR_ROWS_UPDATED');
      arp_message.set_token('NUM_ROWS', to_char(l_count));

    END IF;

  END IF;

  -- Log message
  arp_message.set_line(G_PKG_NAME || '.' || l_api_name || '()-');

EXCEPTION

   WHEN OTHERS THEN
     arp_message.set_line
     (
     G_PKG_NAME || '.' || l_api_name || '():'
     || 'sqlerrm=' || SQLERRM || ','
     || 'sqlcode=' || SQLCODE
     );
     x_return_status :=  FND_API.G_RET_STS_ERROR;
     RAISE;

END Merge_Email_Recipients;

END PRP_PARTY_MERGE_PVT;

/
