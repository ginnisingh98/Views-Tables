--------------------------------------------------------
--  DDL for Package Body OZF_PARTY_MERGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_PARTY_MERGE_PVT" AS
/* $Header: ozfvprmb.pls 120.2 2006/07/07 00:44:44 mkothari ship $ */
-----------------------------------------------------------------------
G_PKG_NAME      CONSTANT VARCHAR2(30):='OZF_PARTY_MERGE_PVT';


FUNCTION check_party_exists(p_party_id IN number)
RETURN varchar2
IS
l_trade_profile_id number;
l_return_flag      varchar2(30);

CURSOR get_party_data(p_party_id in number) IS
select trade_profile_id
from   ozf_cust_trd_prfls_all
where  party_id = p_party_id
and    cust_account_id is null;

BEGIN
  OPEN get_party_data(p_party_id);
    FETCH get_party_data INTO l_trade_profile_id;
  CLOSE get_party_data;

  IF l_trade_profile_id is null THEN
    l_return_flag := 'FALSE';
  ELSE
    l_return_flag := 'TRUE';
  END IF;

  RETURN l_return_flag;

END check_party_exists;

-----------------------------------------------------------------------
-- PROCEDURE
--   Trade_Profile_Party_Merge
--
-- HISTORY
--   07/30/2001  mgudivak  Created.
-----------------------------------------------------------------------
PROCEDURE Trade_Profile_Party_Merge
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) is
  l_api_name            CONSTANT VARCHAR2(30) := 'Trade_Profile_Party_Merge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

  l_to_party_exists     varchar2(20);
BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.TRADE_PROFILE_PARTY_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code into l_merge_reason_code
    from HZ_MERGE_BATCH
    where batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;


    IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            l_to_party_exists := check_party_exists(p_to_fk_id);

            IF l_to_party_exists = 'FALSE' THEN
               -- update the from party profile to to_party
               UPDATE OZF_CUST_TRD_PRFLS_ALL
               SET party_id = p_to_fk_id,
                last_update_date = hz_utility_pub.last_update_date,
                last_updated_by = hz_utility_pub.user_id,
                last_update_login = hz_utility_pub.last_update_login,
                program_application_id = hz_utility_pub.program_application_id,
                program_id = hz_utility_pub.program_id,
                program_update_date = sysdate
               where party_id = p_from_fk_id;
            ELSIF l_to_party_exists = 'TRUE' THEN
               -- delete the from party profile since to_party profile exists
               DELETE FROM OZF_CUST_TRD_PRFLS_ALL
               WHERE party_id = p_from_fk_id
               AND   cust_account_id is null;
            END IF;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.TRADE_PROFILE_PARTY_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Trade_Profile_Party_Merge;

-----------------------------------------------------------------------
-- PROCEDURE
--   Claim_Broker_Merge
--
-- HISTORY
--   07/30/2001  mgudivak  Created.
-----------------------------------------------------------------------
PROCEDURE Claim_Broker_Merge
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) is
  l_api_name            CONSTANT VARCHAR2(30) := 'Claim_Broker_Merge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.CLAIM_BROKER_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code into l_merge_reason_code
    from HZ_MERGE_BATCH
    where batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;


    IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE OZF_CLAIMS_ALL
            SET broker_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
            where broker_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.CLAIM_BROKER_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Claim_Broker_Merge;

-----------------------------------------------------------------------
-- PROCEDURE
--   Claim_Contact_Merge
--
-- HISTORY
--   07/30/2001  mgudivak  Created.
-----------------------------------------------------------------------
PROCEDURE Claim_Contact_Merge
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) is
  l_api_name            CONSTANT VARCHAR2(30) := 'Claim_Contact_Merge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.CLAIM_CONTACT_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code into l_merge_reason_code
    from HZ_MERGE_BATCH
    where batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;


    IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE OZF_CLAIMS_ALL
            SET contact_id = p_to_fk_id,
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

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.CLAIM_CONTACT_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Claim_Contact_Merge;


-----------------------------------------------------------------------
-- PROCEDURE
--   Claim_History_Broker_Merge
--
-- HISTORY
--   07/30/2001  mgudivak  Created.
-----------------------------------------------------------------------
PROCEDURE Claim_History_Broker_Merge
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) is
  l_api_name            CONSTANT VARCHAR2(30) := 'Claim_History_Broker_Merge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.CLAIM_HISTORY_BROKER_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code into l_merge_reason_code
    from HZ_MERGE_BATCH
    where batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;


    IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE OZF_CLAIMS_HISTORY_ALL
            SET broker_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
            where broker_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.CLAIM_HISTORY_BROKER_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Claim_History_Broker_Merge;


-----------------------------------------------------------------------
-- PROCEDURE
--   Claim_History_Contact_Merge
--
-- HISTORY
--   07/30/2001  mgudivak  Created.
-----------------------------------------------------------------------
PROCEDURE Claim_History_Contact_Merge
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) is
  l_api_name            CONSTANT VARCHAR2(30) := 'Claim_History_Contact_Merge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.CLAIM_HISTORY_CONTACT_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code into l_merge_reason_code
    from HZ_MERGE_BATCH
    where batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;


    IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE OZF_CLAIMS_HISTORY_ALL
            SET contact_id = p_to_fk_id,
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

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.CLAIM_HISTORY_CONTACT_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Claim_History_Contact_Merge;

-----------------------------------------------------------------------
-- PROCEDURE
--   Budget_Party_Merge
--
-- HISTORY
--   07/30/2001  mgudivak  Created.
-----------------------------------------------------------------------
PROCEDURE Budget_Party_Merge
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) is
  l_api_name            CONSTANT VARCHAR2(30) := 'Budget_Party_Merge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.BUDGET_PARTY_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code into l_merge_reason_code
    from HZ_MERGE_BATCH
    where batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;


    IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE OZF_ACT_BUDGETS
            SET budget_source_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login
               -- ,program_application_id = hz_utility_pub.program_application_id,
               -- program_id = hz_utility_pub.program_id,
               -- program_update_date = sysdate
            where budget_source_id = p_from_fk_id
            and   budget_source_type = 'PTNR' ;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.BUDGET_PARTY_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Budget_Party_Merge;

-----------------------------------------------------------------------
-- PROCEDURE
--   Budget_Vendor_Merge
--
-- HISTORY
--   07/30/2001  mgudivak  Created.
-----------------------------------------------------------------------
PROCEDURE Budget_Vendor_Merge
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) is
  l_api_name            CONSTANT VARCHAR2(30) := 'Budget_Vendor_Merge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.BUDGET_VENDOR_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code into l_merge_reason_code
    from HZ_MERGE_BATCH
    where batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;


    IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE OZF_ACT_BUDGETS
            SET vendor_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login
               -- ,program_application_id = hz_utility_pub.program_application_id,
               -- program_id = hz_utility_pub.program_id,
               -- program_update_date = sysdate
            where vendor_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.BUDGET_VENDOR_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Budget_Vendor_Merge;

PROCEDURE Offer_Buy_Group_Party_Merge
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) is
  l_api_name            CONSTANT VARCHAR2(30) := 'Offer_Buy_Group_Party_Merge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.OFFER_PARTY_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code into l_merge_reason_code
    from HZ_MERGE_BATCH
    where batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;


    IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE OZF_OFFERS
            SET BUYING_GROUP_CONTACT_ID  = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login
            where BUYING_GROUP_CONTACT_ID = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.OFFER_PARTY_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Offer_Buy_Group_Party_Merge;




-----------------------------------------------------------------------
-- PROCEDURE
--    Offer_Denorm_Party_Merge
--
-- HISTORY
--   14-APR-2003  julou   Created.
-----------------------------------------------------------------------
PROCEDURE Offer_Denorm_Party_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Offer_Denorm_Party_Merge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);
/*
  CURSOR c_object_id IS
  SELECT object_id
  FROM   ozf_activity_customers
  WHERE  party_id = p_from_fk_id;

  CURSOR c_is_duplicate(l_list_header_id NUMBER, l_party_id NUMBER) IS
  SELECT 'Y'
  FROM   OZF_offer_parties
  WHERE  qp_list_header_id = l_list_header_id
  AND    party_id = l_party_id;

  l_is_duplicate VARCHAR2(10);
*/
BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.OFFER_DENORM_PARTY_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT merge_reason_code INTO l_merge_reason_code
    FROM HZ_MERGE_BATCH
    WHERE batch_id = p_batch_id;

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
/*          FOR l_object_id IN c_object_id LOOP
            l_is_duplicate := NULL;

	          OPEN c_is_duplicate(l_list_header_id.qp_list_header_id, p_to_fk_id);
            FETCH c_is_duplicate INTO l_is_duplicate;
            CLOSE c_is_duplicate;

            IF l_is_duplicate = 'Y' THEN
            DELETE FROM OZF_offer_parties
            WHERE qp_list_header_id = l_list_header_id.qp_list_header_id
            AND   party_id = p_from_fk_id;
          ELSE*/
            UPDATE ozf_activity_customers
            SET    party_id = p_to_fk_id
	                ,last_update_date = hz_utility_pub.last_update_date
                  ,last_updated_by = hz_utility_pub.user_id
                  ,last_update_login = hz_utility_pub.last_update_login
            WHERE  party_id = p_from_fk_id;
--          END IF;

--        END LOOP;
      END IF;
      EXCEPTION
        WHEN OTHERS THEN
          arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
          x_return_status :=  FND_API.G_RET_STS_ERROR;
          raise;
      END;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.OFFER_DENORM_PARTY_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Offer_Denorm_Party_Merge;


-----------------------------------------------------------------------
-- PROCEDURE
--   Claim_Line_Party_Merge
--
-- HISTORY
--   04/23/2004  samaresh  Created.
-----------------------------------------------------------------------
PROCEDURE Claim_Line_Party_Merge
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) is
  l_api_name            CONSTANT VARCHAR2(30) := 'Claim_Line_Party_Merge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.CLAIM_LINE_PARTY_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code into l_merge_reason_code
    from HZ_MERGE_BATCH
    where batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;


    IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE OZF_CLAIM_LINES_ALL
            SET buy_group_party_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
            where buy_group_party_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.CLAIM_LINE_PARTY_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Claim_Line_Party_Merge;

-----------------------------------------------------------------------
-- PROCEDURE
--    Claim_Line_Hist_Party_Merge
--
-- HISTORY
--   04/23/2004  samaresh  Created.
-----------------------------------------------------------------------
PROCEDURE Claim_Line_Hist_Party_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Claim_Line_Hist_Party_Merge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.CLAIM_LINE_HIST_PARTY_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT merge_reason_code INTO l_merge_reason_code
    FROM HZ_MERGE_BATCH
    WHERE batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;


    IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE OZF_CLAIM_LINES_HIST_ALL
            SET buy_group_party_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
            where buy_group_party_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.CLAIM_LINE_HIST_PARTY_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Claim_Line_Hist_Party_Merge;

-----------------------------------------------------------------------
-- PROCEDURE
--    Claim_Line_Hist_Party_Merge
--
-- HISTORY
--   04/23/2004  samaresh  Created.
-----------------------------------------------------------------------
PROCEDURE Code_Conversion_Party_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Code_Conversion_Party_Merge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.CODE_CONVERSION_PARTY_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT merge_reason_code INTO l_merge_reason_code
    FROM HZ_MERGE_BATCH
    WHERE batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

     IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE ozf_code_conversions_all
            SET party_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login
            where party_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.CODE_CONVERSION_PARTY_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Code_Conversion_Party_Merge;

-----------------------------------------------------------------------
-- PROCEDURE
--    Resale_Batch_Prtn_Merge
--
-- HISTORY
--   04/23/2004  samaresh  Created.
-----------------------------------------------------------------------
PROCEDURE Resale_Batch_Prtn_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Resale_Batch_Prtn_Merge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_BATCH_PRTN_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT merge_reason_code INTO l_merge_reason_code
    FROM HZ_MERGE_BATCH
    WHERE batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

     IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE ozf_resale_batches_all
            SET partner_party_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
            where partner_party_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_BATCH_PRTN_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Resale_Batch_Prtn_Merge;

-----------------------------------------------------------------------
-- PROCEDURE
--    Resale_Batch_Prtn_Cnt_Merge
--
-- HISTORY
--   04/23/2004  samaresh  Created.
-----------------------------------------------------------------------
PROCEDURE Resale_Batch_Prtn_Cnt_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Resale_Batch_Prtn_Cnt_Merge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_BATCH_PRTN_CNT_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT merge_reason_code INTO l_merge_reason_code
    FROM HZ_MERGE_BATCH
    WHERE batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

     IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE ozf_resale_batches_all
            SET partner_contact_party_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
            where partner_contact_party_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_BATCH_PRTN_CNT_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Resale_Batch_Prtn_Cnt_Merge;

-----------------------------------------------------------------------
-- PROCEDURE
--    Resale_Int_Ship_Frm_Cnt_Mge
--
-- HISTORY
--   04/23/2004  samaresh  Created.
-----------------------------------------------------------------------
PROCEDURE Resale_Int_Ship_Frm_Cnt_Mge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Resale_Int_Ship_Frm_Cnt_Mge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_INT_SHIP_FRM_CNT_MGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT merge_reason_code INTO l_merge_reason_code
    FROM HZ_MERGE_BATCH
    WHERE batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

     IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE ozf_resale_lines_int_all
            SET ship_from_contact_party_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
            where ship_from_contact_party_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_INT_SHIP_FRM_CNT_MGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Resale_Int_Ship_Frm_Cnt_Mge;

-----------------------------------------------------------------------
-- PROCEDURE
--    Resale_Int_Sold_Frm_Cnt_Mge
--
-- HISTORY
--   04/23/2004  samaresh  Created.
-----------------------------------------------------------------------
PROCEDURE Resale_Int_Sold_Frm_Cnt_Mge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Resale_Int_Sold_Frm_Cnt_Mge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_INT_SOLD_FRM_CNT_MGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT merge_reason_code INTO l_merge_reason_code
    FROM HZ_MERGE_BATCH
    WHERE batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

     IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE ozf_resale_lines_int_all
            SET sold_from_contact_party_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
            where sold_from_contact_party_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_INT_SOLD_FRM_CNT_MGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Resale_Int_Sold_Frm_Cnt_Mge;


-----------------------------------------------------------------------
-- PROCEDURE
--    Resale_Int_Bill_To_Merge
--
-- HISTORY
--   04/23/2004  samaresh  Created.
-----------------------------------------------------------------------
PROCEDURE Resale_Int_Bill_To_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Resale_Int_Bill_To_Merge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_INT_BILL_TO_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT merge_reason_code INTO l_merge_reason_code
    FROM HZ_MERGE_BATCH
    WHERE batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

     IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE ozf_resale_lines_int_all
            SET bill_to_party_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
            where bill_to_party_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_INT_BILL_TO_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Resale_Int_Bill_To_Merge;


-----------------------------------------------------------------------
-- PROCEDURE
--    Resale_Int_Bill_To_Cnt_Mge
--
-- HISTORY
--   04/23/2004  samaresh  Created.
-----------------------------------------------------------------------
PROCEDURE Resale_Int_Bill_To_Cnt_Mge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Resale_Int_Bill_To_Cnt_Mge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_INT_BILL_TO_CNT_MGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT merge_reason_code INTO l_merge_reason_code
    FROM HZ_MERGE_BATCH
    WHERE batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

     IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE ozf_resale_lines_int_all
            SET bill_to_contact_party_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
            where bill_to_contact_party_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_INT_BILL_TO_CNT_MGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Resale_Int_Bill_To_Cnt_Mge;

-----------------------------------------------------------------------
-- PROCEDURE
--    Resale_Int_Ship_To_Merge
--
-- HISTORY
--   07/18/2005  slkrishn  Created.
-----------------------------------------------------------------------
PROCEDURE Resale_Int_Ship_To_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Resale_Int_Ship_To_Merge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_INT_SHIP_TO_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT merge_reason_code INTO l_merge_reason_code
    FROM HZ_MERGE_BATCH
    WHERE batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

     IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE ozf_resale_lines_int_all
            SET ship_to_party_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
            where ship_to_party_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_INT_SHIP_TO_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Resale_Int_Ship_To_Merge;


-----------------------------------------------------------------------
-- PROCEDURE
--    Resale_Int_Ship_To_Cnt_Mge
--
-- HISTORY
--   04/23/2004  samaresh  Created.
-----------------------------------------------------------------------
PROCEDURE Resale_Int_Ship_To_Cnt_Mge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Resale_Int_Ship_To_Cnt_Mge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_INT_BILL_TO_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT merge_reason_code INTO l_merge_reason_code
    FROM HZ_MERGE_BATCH
    WHERE batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

     IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE ozf_resale_lines_int_all
            SET ship_to_contact_party_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
            where ship_to_contact_party_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_INT_SHIP_TO_CNT_MGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Resale_Int_Ship_To_Cnt_Mge;

-----------------------------------------------------------------------
-- PROCEDURE
--    Resale_Int_End_Cust_Merge
--
-- HISTORY
--   04/23/2004  samaresh  Created.
-----------------------------------------------------------------------
PROCEDURE Resale_Int_End_Cust_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Resale_Int_End_Cust_Merge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_INT_BILL_TO_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT merge_reason_code INTO l_merge_reason_code
    FROM HZ_MERGE_BATCH
    WHERE batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

     IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE ozf_resale_lines_int_all
            SET end_cust_party_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
            where end_cust_party_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_INT_END_CUST_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Resale_Int_End_Cust_Merge;

-----------------------------------------------------------------------
-- PROCEDURE
--    Resale_Int_End_Cust_Cnt_Mge
--
-- HISTORY
--   04/23/2004  samaresh  Created.
-----------------------------------------------------------------------
PROCEDURE Resale_Int_End_Cust_Cnt_Mge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Resale_Int_End_Cust_Cnt_Mge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_INT_BILL_TO_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT merge_reason_code INTO l_merge_reason_code
    FROM HZ_MERGE_BATCH
    WHERE batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

     IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE ozf_resale_lines_int_all
            SET end_cust_contact_party_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
            where end_cust_contact_party_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_INT_END_CUST_CNT_MGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Resale_Int_End_Cust_Cnt_Mge;

-----------------------------------------------------------------------
-- PROCEDURE
--    Resale_Int_Bill_To_Merge
--
-- HISTORY
--   04/23/2004  samaresh  Created.
-----------------------------------------------------------------------
PROCEDURE Resale_Head_Bill_To_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Resale_Head_Bill_To_Merge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_HEAD_BILL_TO_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT merge_reason_code INTO l_merge_reason_code
    FROM HZ_MERGE_BATCH
    WHERE batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

     IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE ozf_resale_headers_all
            SET bill_to_party_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
            where bill_to_party_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_HEAD_BILL_TO_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Resale_Head_Bill_To_Merge;

-----------------------------------------------------------------------
-- PROCEDURE
--    Resale_Head_Bill_To_Cnt_Mge
--
-- HISTORY
--   04/23/2004  samaresh  Created.
-----------------------------------------------------------------------
PROCEDURE Resale_Head_Bill_To_Cnt_Mge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Resale_Head_Bill_To_Cnt_Mge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_HEAD_BILL_TO_CNT_MGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT merge_reason_code INTO l_merge_reason_code
    FROM HZ_MERGE_BATCH
    WHERE batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

     IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE ozf_resale_headers_all
            SET bill_to_contact_party_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
            where bill_to_contact_party_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_HEAD_BILL_TO_CNT_MGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Resale_Head_Bill_To_Cnt_Mge;

-----------------------------------------------------------------------
-- PROCEDURE
--    Resale_Head_Ship_To_Merge
--
-- HISTORY
--   04/23/2004  samaresh  Created.
-----------------------------------------------------------------------
PROCEDURE Resale_Head_Ship_To_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Resale_Head_Ship_To_Merge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_HEAD_SHIP_TO_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT merge_reason_code INTO l_merge_reason_code
    FROM HZ_MERGE_BATCH
    WHERE batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

     IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE ozf_resale_headers_all
            SET ship_to_party_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
            where ship_to_party_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_HEAD_SHIP_TO_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Resale_Head_Ship_To_Merge;

-----------------------------------------------------------------------
-- PROCEDURE
--    Resale_Head_Ship_To_Cnt_Mge
--
-- HISTORY
--   04/23/2004  samaresh  Created.
-----------------------------------------------------------------------
PROCEDURE Resale_Head_Ship_To_Cnt_Mge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Resale_Head_Ship_To_Cnt_Mge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_HEAD_SHIP_TO_CNT_MGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT merge_reason_code INTO l_merge_reason_code
    FROM HZ_MERGE_BATCH
    WHERE batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

     IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE ozf_resale_headers_all
            SET ship_to_contact_party_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
            where ship_to_contact_party_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_HEAD_SHIP_TO_CNT_MGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Resale_Head_Ship_To_Cnt_Mge;

-----------------------------------------------------------------------
-- PROCEDURE
--    Resale_Line_Ship_Frm_Cnt_Mge
--
-- HISTORY
--   04/23/2004  samaresh  Created.
-----------------------------------------------------------------------
PROCEDURE Resale_Line_Ship_Frm_Cnt_Mge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Resale_Line_Ship_Frm_Cnt_Mge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_LINE_SHIP_FRM_CNT_MGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT merge_reason_code INTO l_merge_reason_code
    FROM HZ_MERGE_BATCH
    WHERE batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

     IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE ozf_resale_lines_all
            SET ship_from_contact_party_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
            where ship_from_contact_party_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_LINE_SHIP_FRM_CNT_MGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Resale_Line_Ship_Frm_Cnt_Mge;

-----------------------------------------------------------------------
-- PROCEDURE
--    Resale_Line_Sold_Frm_Cnt_Mge
--
-- HISTORY
--   04/23/2004  samaresh  Created.
-----------------------------------------------------------------------
PROCEDURE Resale_Line_Sold_Frm_Cnt_Mge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Resale_Line_Sold_Frm_Cnt_Mge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_LINE_SOLD_FRM_CNT_MGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT merge_reason_code INTO l_merge_reason_code
    FROM HZ_MERGE_BATCH
    WHERE batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

     IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE ozf_resale_lines_all
            SET sold_from_contact_party_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
            where sold_from_contact_party_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_LINE_SOLD_FRM_CNT_MGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Resale_Line_Sold_Frm_Cnt_Mge;

-----------------------------------------------------------------------
-- PROCEDURE
--    Resale_Line_Bill_To_Merge
--
-- HISTORY
--   04/23/2004  samaresh  Created.
-----------------------------------------------------------------------
PROCEDURE Resale_Line_Bill_To_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Resale_Line_Bill_To_Merge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_LINE_BILL_TO_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT merge_reason_code INTO l_merge_reason_code
    FROM HZ_MERGE_BATCH
    WHERE batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

     IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE ozf_resale_lines_all
            SET bill_to_party_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
            where bill_to_party_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_LINE_BILL_TO_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Resale_Line_Bill_To_Merge;


-----------------------------------------------------------------------
-- PROCEDURE
--    Resale_Line_Bill_To_Cnt_Mge
--
-- HISTORY
--   04/23/2004  samaresh  Created.
-----------------------------------------------------------------------
PROCEDURE Resale_Line_Bill_To_Cnt_Mge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Resale_Line_Bill_To_Cnt_Mge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_LINE_BILL_TO_CNT_MGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT merge_reason_code INTO l_merge_reason_code
    FROM HZ_MERGE_BATCH
    WHERE batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

     IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE ozf_resale_lines_all
            SET bill_to_contact_party_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
            where bill_to_contact_party_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_LINE_BILL_TO_CNT_MGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Resale_Line_Bill_To_Cnt_Mge;


-----------------------------------------------------------------------
-- PROCEDURE
--    Resale_Line_Ship_To_Merge
--
-- HISTORY
--   04/23/2004  samaresh  Created.
-----------------------------------------------------------------------
PROCEDURE Resale_Line_Ship_To_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Resale_Line_Ship_To_Merge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_LINE_SHIP_TO_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT merge_reason_code INTO l_merge_reason_code
    FROM HZ_MERGE_BATCH
    WHERE batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

     IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE ozf_resale_lines_all
            SET ship_to_party_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
            where ship_to_party_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_LINE_SHIP_TO_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Resale_Line_Ship_To_Merge;


-----------------------------------------------------------------------
-- PROCEDURE
--    Resale_Line_Ship_To_Cnt_Mge
--
-- HISTORY
--   04/23/2004  samaresh  Created.
-----------------------------------------------------------------------
PROCEDURE Resale_Line_Ship_To_Cnt_Mge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Resale_Line_Ship_To_Cnt_Mge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_LINE_SHIP_TO_CNT_MGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT merge_reason_code INTO l_merge_reason_code
    FROM HZ_MERGE_BATCH
    WHERE batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

     IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE ozf_resale_lines_all
            SET ship_to_contact_party_id  = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
            where ship_to_contact_party_id  = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_LINE_SHIP_TO_CNT_MGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Resale_Line_Ship_To_Cnt_Mge;

-----------------------------------------------------------------------
-- PROCEDURE
--    Resale_Line_End_Cust_Merge
--
-- HISTORY
--   04/23/2004  samaresh  Created.
-----------------------------------------------------------------------
PROCEDURE Resale_Line_End_Cust_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Resale_Line_End_Cust_Merge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_LINE_END_CUST_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT merge_reason_code INTO l_merge_reason_code
    FROM HZ_MERGE_BATCH
    WHERE batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

     IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE ozf_resale_lines_all
            SET end_cust_party_id   = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
            where end_cust_party_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_LINE_END_CUST_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Resale_Line_End_Cust_Merge;
-----------------------------------------------------------------------
-- PROCEDURE
--    Resale_Line_End_Cust_Cnt_Mge
--
-- HISTORY
--   04/23/2004  samaresh  Created.
-----------------------------------------------------------------------
PROCEDURE Resale_Line_End_Cust_Cnt_Mge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Resale_Line_End_Cust_Cnt_Mge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_LINE_END_CUST_CNT_MGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT merge_reason_code INTO l_merge_reason_code
    FROM HZ_MERGE_BATCH
    WHERE batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

     IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE ozf_resale_lines_all
            SET end_cust_contact_party_id   = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
            where end_cust_contact_party_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.RESALE_LINE_END_CUST_CNT_MGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Resale_Line_End_Cust_Cnt_Mge;

-----------------------------------------------------------------------
-- PROCEDURE
--    Request_Head_End_Cust_Merge
--
-- HISTORY
--   04/23/2004  samaresh  Created.
-----------------------------------------------------------------------
PROCEDURE Request_Head_End_Cust_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Request_Head_End_Cust_Merge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.REQUEST_HEAD_END_CUST_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT merge_reason_code INTO l_merge_reason_code
    FROM HZ_MERGE_BATCH
    WHERE batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

     IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE ozf_request_headers_all_b
            SET end_cust_party_id  = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
            where end_cust_party_id  = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.REQUEST_HEAD_END_CUST_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Request_Head_End_Cust_Merge;

-----------------------------------------------------------------------
-- PROCEDURE
--    Request_Head_Reseller_Merge
--
-- HISTORY
--   04/23/2004  samaresh  Created.
-----------------------------------------------------------------------
PROCEDURE Request_Head_Reseller_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Request_Head_Reseller_Merge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.REQUEST_HEAD_RESELLER_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT merge_reason_code INTO l_merge_reason_code
    FROM HZ_MERGE_BATCH
    WHERE batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

     IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE ozf_request_headers_all_b
            SET reseller_party_id  = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
            where reseller_party_id  = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.REQUEST_HEAD_RESELLER_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Request_Head_Reseller_Merge;

-----------------------------------------------------------------------
-- PROCEDURE
--    Acct_Alloc_Parent_Party_Merge
--
-- HISTORY
--   04/23/2004  samaresh  Created.
-----------------------------------------------------------------------
PROCEDURE Acct_Alloc_Parent_Party_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Acct_Alloc_Parent_Party_Merge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.ACCT_ALLOC_PARENT_PARTY_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT merge_reason_code INTO l_merge_reason_code
    FROM HZ_MERGE_BATCH
    WHERE batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

     IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE ozf_account_allocations
            SET parent_party_id  = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login
            where parent_party_id  = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.ACCT_ALLOC_PARENT_PARTY_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Acct_Alloc_Parent_Party_Merge;

-----------------------------------------------------------------------
-- PROCEDURE
--    Acct_Alloc_Rollup_Party_Merge
--
-- HISTORY
--   04/23/2004  samaresh  Created.
-----------------------------------------------------------------------
PROCEDURE Acct_Alloc_Rollup_Party_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Acct_Alloc_Rollup_Party_Merge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.ACCT_ALLOC_ROLLUP_PARTY_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT merge_reason_code INTO l_merge_reason_code
    FROM HZ_MERGE_BATCH
    WHERE batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

     IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE ozf_account_allocations
            SET rollup_party_id  = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login
            where rollup_party_id  = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.ACCT_ALLOC_ROLLUP_PARTY_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Acct_Alloc_Rollup_Party_Merge;

-----------------------------------------------------------------------
-- PROCEDURE
--    Offer_Autopay_Party_Merge
--
-- HISTORY
--   04/23/2004  samaresh  Created.
-----------------------------------------------------------------------

PROCEDURE Offer_Autopay_Party_Merge
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) is
  l_api_name            CONSTANT VARCHAR2(30) := 'Offer_Autopay_Party_Merge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.OFFER_AUTOPAY_PARTY_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code into l_merge_reason_code
    from HZ_MERGE_BATCH
    where batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;


    IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE OZF_OFFERS
            SET autopay_party_id  = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login
            where autopay_party_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.OFFER_AUTOPAY_PARTY_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Offer_Autopay_Party_Merge;


-----------------------------------------------------------------------
-- PROCEDURE
--    Request_Head_Partner_Merge
--
-- HISTORY
--   04/23/2004  samaresh  Created.
-----------------------------------------------------------------------
PROCEDURE Request_Head_Partner_Merge
(   p_entity_name             IN     VARCHAR2
   ,p_from_id                 IN     NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN     NUMBER
   ,p_to_fk_id                IN     NUMBER
   ,p_parent_entity_name      IN     VARCHAR2
   ,p_batch_id                IN     NUMBER
   ,p_batch_party_id          IN     NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Request_Head_Partner_Merge';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.REQUEST_HEAD_PARTNER_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT merge_reason_code INTO l_merge_reason_code
    FROM HZ_MERGE_BATCH
    WHERE batch_id = p_batch_id;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

     IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

            UPDATE ozf_request_headers_all_b
            SET partner_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
            where partner_id  = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


    FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_PARTY_MERGE_PKG.REQUEST_HEAD_PARTNER_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Request_Head_Partner_Merge;


END OZF_PARTY_MERGE_PVT;

/
