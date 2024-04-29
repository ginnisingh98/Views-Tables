--------------------------------------------------------
--  DDL for Package Body AS_INTEREST_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_INTEREST_MERGE_PKG" as
/* $Header: asxpmitb.pls 120.1 2005/11/25 01:30:25 subabu noship $ */
--
-- NAME
-- AS_INTEREST_MERGE_PKG
--
-- HISTORY
--   02/15/2001    ACNG          CREATED
--

G_PKG_NAME      CONSTANT VARCHAR2(30):='AS_INTEREST_MERGE_PKG';

PROCEDURE INTERESTS_MERGE
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT   NOCOPY NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT   NOCOPY VARCHAR2
) is
  l_api_name            CONSTANT VARCHAR2(30) := 'INTEREST_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 2.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AS_INTEREST_MERGE_PKG.INTEREST_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code into l_merge_reason_code
    from HZ_MERGE_BATCH
    where batch_id = p_batch_id;

    IF l_merge_reason_code = 'DUPLICATE' THEN
       -- ***************************************************************************
       -- if reason code is duplicate then allow the party merge to happen without
       -- any validations.
       -- ***************************************************************************
	  null;
    ELSE
       -- ***************************************************************************
       -- if there are any validations to be done, include it in this section
       -- ***************************************************************************
	  null;
    END IF;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

    -- ***************************************************************************
    -- If the parent has changed(ie. Parent is getting merged) then transfer the
    -- dependent record to the new parent. Before transferring check if a similar
    -- dependent record exists on the new parent. If a duplicate exists then do
    -- not transfer and return the id of the duplicate record as the Merged To Id
    -- ***************************************************************************

    -- ***************************************************************************
    -- Add your own logic if you need to take care of the following cases
    -- Check the if record duplicate if change party_id from merge-from
    -- to merge-to id.  E.g. : in AS_ACCESSES_ALL, if you have the following
    -- situation
    --
    -- customer_id    address_id     contact_id
    -- ===========    ==========     ==========
    --   1200           1100
    --   1300           1400
    --
    -- if p_from_fk_id = 1200, p_to_fk_id = 1300 for customer_id
    --    p_from_fk_id = 1100, p_to_fk_id = 1400 for address_id
    -- therefore, if changing 1200 to 1300 (customer_id)
    -- and 1100 to 1400 (address_id), then it will cause unique
    -- key violation assume that all other fields are the same
    -- So, please check if you need to check for record duplication
    -- ***************************************************************************

    IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
	     IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party
	   	   UPDATE AS_INTERESTS_ALL
		   set object_version_number =  nvl(object_version_number,0) + 1, customer_id = p_to_fk_id,
			  last_update_date = hz_utility_pub.last_update_date,
			  last_updated_by = hz_utility_pub.user_id,
			  last_update_login = hz_utility_pub.last_update_login,
			  program_application_id = hz_utility_pub.program_application_id,
			  program_id = hz_utility_pub.program_id,
			  program_update_date = sysdate
		   where customer_id = p_from_fk_id;
	     ELSIF p_parent_entity_name = 'HZ_PARTY_SITES' THEN    -- merge party_site
		   UPDATE AS_INTERESTS_ALL
		   set object_version_number =  nvl(object_version_number,0) + 1, address_id = p_to_fk_id,
			  last_update_date = hz_utility_pub.last_update_date,
			  last_updated_by = hz_utility_pub.user_id,
			  last_update_login = hz_utility_pub.last_update_login,
			  program_application_id = hz_utility_pub.program_application_id,
			  program_id = hz_utility_pub.program_id,
			  program_update_date = sysdate
		   where address_id = p_from_fk_id;
	     ELSIF p_parent_entity_name = 'HZ_ORG_CONTACTS' THEN   -- merge org_contact
		   UPDATE AS_INTERESTS_ALL
		   set object_version_number =  nvl(object_version_number,0) + 1, contact_id = p_to_fk_id,
			  last_update_date = hz_utility_pub.last_update_date,
			  last_updated_by = hz_utility_pub.user_id,
			  last_update_login = hz_utility_pub.last_update_login,
			  program_application_id = hz_utility_pub.program_application_id,
			  program_id = hz_utility_pub.program_id,
			  program_update_date = sysdate
		   where contact_id = p_from_fk_id;
	     END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AS_INTEREST_MERGE_PKG.INTEREST_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END INTERESTS_MERGE;

PROCEDURE CURRENT_ENV_MERGE
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT   NOCOPY NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT   NOCOPY VARCHAR2
) is
  l_api_name            CONSTANT VARCHAR2(30) := 'CURRENT_ENV_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 2.0;
  l_merge_reason_code   VARCHAR2(30);
BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AS_INTEREST_MERGE_PKG.CURRENT_ENV_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code into l_merge_reason_code
    from HZ_MERGE_BATCH
    where batch_id = p_batch_id;

    IF l_merge_reason_code = 'DUPLICATE' THEN
       -- ***************************************************************************
       -- if reason code is duplicate then allow the party merge to happen without
       -- any validations.
       -- ***************************************************************************
	  null;
    ELSE
       -- ***************************************************************************
       -- if there are any validations to be done, include it in this section
       -- ***************************************************************************
	  null;
    END IF;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

    -- ***************************************************************************
    -- If the parent has changed(ie. Parent is getting merged) then transfer the
    -- dependent record to the new parent. Before transferring check if a similar
    -- dependent record exists on the new parent. If a duplicate exists then do
    -- not transfer and return the id of the duplicate record as the Merged To Id
    -- ***************************************************************************

    -- ***************************************************************************
    -- Add your own logic if you need to take care of the following cases
    -- Check the if record duplicate if change party_id from merge-from
    -- to merge-to id.  E.g. : in AS_ACCESSES_ALL, if you have the following
    -- situation
    --
    -- customer_id    address_id     contact_id
    -- ===========    ==========     ==========
    --   1200           1100
    --   1300           1400
    --
    -- if p_from_fk_id = 1200, p_to_fk_id = 1300 for customer_id
    --    p_from_fk_id = 1100, p_to_fk_id = 1400 for address_id
    -- therefore, if changing 1200 to 1300 (customer_id)
    -- and 1100 to 1400 (address_id), then it will cause unique
    -- key violation assume that all other fields are the same
    -- So, please check if you need to check for record duplication
    -- ***************************************************************************

    IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
	     IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party
	   	   UPDATE AS_CURRENT_ENVIRONMENT
		   set customer_id = p_to_fk_id,
			  last_update_date = hz_utility_pub.last_update_date,
			  last_updated_by = hz_utility_pub.user_id,
			  last_update_login = hz_utility_pub.last_update_login
		   where customer_id = p_from_fk_id;
	     ELSIF p_parent_entity_name = 'HZ_PARTY_SITES' THEN    -- merge party_site
		   UPDATE AS_CURRENT_ENVIRONMENT
		   set address_id = p_to_fk_id,
			  last_update_date = hz_utility_pub.last_update_date,
			  last_updated_by = hz_utility_pub.user_id,
			  last_update_login = hz_utility_pub.last_update_login
		   where address_id = p_from_fk_id;
	     END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AS_INTEREST_MERGE_PKG.CURRENT_ENV_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END CURRENT_ENV_MERGE;

END AS_INTEREST_MERGE_PKG;

/
