--------------------------------------------------------
--  DDL for Package Body AMS_PARTY_MERGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_PARTY_MERGE_PVT" AS
/* $Header: amsvprmb.pls 115.28 2004/04/09 04:19:37 julou ship $ */
-----------------------------------------------------------------------
G_PKG_NAME      CONSTANT VARCHAR2(30):='AMS_PARTY_MERGE_PVT';

PROCEDURE REG_PARTY_MERGE
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
  l_api_name            CONSTANT VARCHAR2(30) := 'PARTY_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.REG_PARTY_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

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

         UPDATE AMS_EVENT_REGISTRATIONS
         set REGISTRANT_PARTY_ID = p_to_fk_id,
           last_update_date = hz_utility_pub.last_update_date,
           last_updated_by = hz_utility_pub.user_id,
           last_update_login = hz_utility_pub.last_update_login,
           program_application_id = hz_utility_pub.program_application_id,
           program_id = hz_utility_pub.program_id,
           program_update_date = sysdate
         where REGISTRANT_PARTY_ID = p_from_fk_id;

-- following part added by soagrawa on 17-jan-2003
-- for bug# 2696534.  Also refer to bug# 1539211

         UPDATE AMS_EVENT_REGISTRATIONS
         set REGISTRANT_CONTACT_ID = p_to_fk_id,
           last_update_date = hz_utility_pub.last_update_date,
           last_updated_by = hz_utility_pub.user_id,
           last_update_login = hz_utility_pub.last_update_login,
           program_application_id = hz_utility_pub.program_application_id,
           program_id = hz_utility_pub.program_id,
           program_update_date = sysdate
         where REGISTRANT_CONTACT_ID = p_from_fk_id;

-- following part removed by soagrawa on 17-jan-2003
-- for bug# 2696534.  Also refer to bug# 1539211

/*
        ELSIF p_parent_entity_name = 'HZ_ORG_CONTACTS' THEN   -- merge org_contact
         UPDATE AMS_EVENT_REGISTRATIONS
         set REGISTRANT_CONTACT_ID = p_to_fk_id,
           last_update_date = hz_utility_pub.last_update_date,
           last_updated_by = hz_utility_pub.user_id,
           last_update_login = hz_utility_pub.last_update_login,
           program_application_id = hz_utility_pub.program_application_id,
           program_id = hz_utility_pub.program_id,
           program_update_date = sysdate
         where REGISTRANT_CONTACT_ID = p_from_fk_id;
*/
        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.REG_PARTY_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END REG_PARTY_MERGE;

PROCEDURE ATN_PARTY_MERGE
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
  l_api_name            CONSTANT VARCHAR2(30) := 'PARTY_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.ATN_PARTY_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

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
         UPDATE AMS_EVENT_REGISTRATIONS
         set ATTENDANT_PARTY_ID = p_to_fk_id,
           last_update_date = hz_utility_pub.last_update_date,
           last_updated_by = hz_utility_pub.user_id,
           last_update_login = hz_utility_pub.last_update_login,
           program_application_id = hz_utility_pub.program_application_id,
           program_id = hz_utility_pub.program_id,
           program_update_date = sysdate
         where ATTENDANT_PARTY_ID = p_from_fk_id;

-- following part added by soagrawa on 17-jan-2003
-- for bug# 2696534.  Also refer to bug# 1539211

         UPDATE AMS_EVENT_REGISTRATIONS
         set ATTENDANT_CONTACT_ID = p_to_fk_id,
           last_update_date = hz_utility_pub.last_update_date,
           last_updated_by = hz_utility_pub.user_id,
           last_update_login = hz_utility_pub.last_update_login,
           program_application_id = hz_utility_pub.program_application_id,
           program_id = hz_utility_pub.program_id,
           program_update_date = sysdate
         where ATTENDANT_CONTACT_ID = p_from_fk_id;


-- following part removed by soagrawa on 17-jan-2003
-- for bug# 2696534.  Also refer to bug# 1539211

/*        ELSIF p_parent_entity_name = 'HZ_ORG_CONTACTS' THEN   -- merge org_contact
         UPDATE AMS_EVENT_REGISTRATIONS
         set ATTENDANT_CONTACT_ID = p_to_fk_id,
           last_update_date = hz_utility_pub.last_update_date,
           last_updated_by = hz_utility_pub.user_id,
           last_update_login = hz_utility_pub.last_update_login,
           program_application_id = hz_utility_pub.program_application_id,
           program_id = hz_utility_pub.program_id,
           program_update_date = sysdate
         where ATTENDANT_CONTACT_ID = p_from_fk_id;
         */
        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.ATN_PARTY_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END ATN_PARTY_MERGE;

-----------------------------------------------------------------------
-- PROCEDURE
--    Channel_Party_Merge
--
-- HISTORY
--   07/15/2000  ptendulk  Created.
-----------------------------------------------------------------------
PROCEDURE Channel_Party_Merge
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
  l_api_name            CONSTANT VARCHAR2(30) := 'PARTY_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.CHANNEL_PARTY_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

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
         -- Following lines of code is added by ptendulk on 14-May-2001
            -- to do the party merge for table ams_channels_b
            UPDATE AMS_CHANNELS_B
            SET   party_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
            where party_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.CHANNEL_PARTY_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Channel_Party_Merge;

-----------------------------------------------------------------------
-- PROCEDURE
--    Party_src_Party_Merge
--
-- HISTORY
--   07/15/2000  USingh   Created.
-----------------------------------------------------------------------
PROCEDURE Party_src_Party_Merge
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
  l_api_name            CONSTANT VARCHAR2(30) := 'PARTY_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.CHANNEL_PARTY_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

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
         -- Following lines of code is added by ptendulk on 14-May-2001
            -- to do the party merge for table ams_channels_b
            UPDATE AMS_PARTY_SOURCES
            SET   party_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
            where party_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.CHANNEL_PARTY_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Party_src_Party_Merge;

-----------------------------------------------------------------------
-- PROCEDURE
--    Segment_Party_Merge
--
-- HISTORY
--   05/15/2001  yxliu  Created.
-----------------------------------------------------------------------
PROCEDURE Segment_Party_Merge
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
  l_api_name            CONSTANT VARCHAR2(30) := 'PARTY_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.SEGMENT_PARTY_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

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
         -- Following lines of code is added by yxliu on 15-May-2001
            -- to do the party merge for table ams_party_market_segments
            UPDATE AMS_PARTY_MARKET_SEGMENTS
            SET   party_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login,
               program_application_id = hz_utility_pub.program_application_id,
               program_id = hz_utility_pub.program_id,
               program_update_date = sysdate
            where party_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.SEGMENT_PARTY_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Segment_Party_Merge;

-----------------------------------------------------------------------
-- PROCEDURE
--    Post_Cust_Party_Merge
--
-- HISTORY
--   05/21/2001  ryedator  Created.
-----------------------------------------------------------------------
PROCEDURE Post_Cust_Party_Merge
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
  l_api_name            CONSTANT VARCHAR2(30) := 'PARTY_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.POST_CUST_PARTY_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

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
         -- Following lines of code is added by ptendulk on 14-May-2001
            -- to do the party merge for table ams_iba_postings_b
            UPDATE AMS_IBA_POSTINGS_B
            SET customer_party_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login
               --, program_application_id = hz_utility_pub.program_application_id,
               -- program_id = hz_utility_pub.program_id,
               -- program_update_date = sysdate
            where customer_party_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.POST_CUST_PARTY_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Post_Cust_Party_Merge;

-----------------------------------------------------------------------
-- PROCEDURE
--    Post_Affl_Party_Merge
--
-- HISTORY
--   05/22/2000  ryedator  Created.
-----------------------------------------------------------------------
PROCEDURE Post_Affl_Party_Merge
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
  l_api_name            CONSTANT VARCHAR2(30) := 'PARTY_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.POST_AFFL_PARTY_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

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
         -- Following lines of code is added by ptendulk on 14-May-2001
            -- to do the party merge for table ams_iba_postings_b
            UPDATE AMS_IBA_POSTINGS_B
            SET affiliate_party_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login
               -- ,program_application_id = hz_utility_pub.program_application_id,
               -- program_id = hz_utility_pub.program_id,
               -- program_update_date = sysdate
            where affiliate_party_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.POST_AFFL_PARTY_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Post_Affl_Party_Merge;


-----------------------------------------------------------------------
-- PROCEDURE
--   Campaign_Partner_Merge
--
-- HISTORY
--   07/30/2001  mgudivak  Created.
-----------------------------------------------------------------------
PROCEDURE Campaign_Partner_Merge
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
  l_api_name            CONSTANT VARCHAR2(30) := 'PARTY_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.CAMPAIGN_PARTNER_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

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

            UPDATE AMS_ACT_PARTNERS
            SET partner_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login
               --, program_application_id = hz_utility_pub.program_application_id,
               -- program_id = hz_utility_pub.program_id,
               -- program_update_date = sysdate
            where partner_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.CAMPAIGN_PARTNER_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Campaign_Partner_Merge;

-----------------------------------------------------------------------
-- PROCEDURE
--   Campaign_VAD_Merge
--
-- HISTORY
--   07/30/2001  mgudivak  Created.
-----------------------------------------------------------------------
PROCEDURE Campaign_VAD_Merge
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
  l_api_name            CONSTANT VARCHAR2(30) := 'PARTY_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.CAMPAIGN_VAD_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

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

            UPDATE AMS_ACT_PARTNERS
            SET preferred_vad_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login
               --,program_application_id = hz_utility_pub.program_application_id,
               -- program_id = hz_utility_pub.program_id,
               -- program_update_date = sysdate
            where preferred_vad_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.CAMPAIGN_VAD_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Campaign_VAD_Merge;

-----------------------------------------------------------------------
-- PROCEDURE
--   Campaign_Contact_Merge
--
-- HISTORY
--   07/30/2001  mgudivak  Created.
-----------------------------------------------------------------------
PROCEDURE Campaign_Contact_Merge
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
  l_api_name            CONSTANT VARCHAR2(30) := 'PARTY_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.CAMPAIGN_CONTACT_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

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

            UPDATE AMS_ACT_PARTNERS
            SET primary_contact_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login
               --, program_application_id = hz_utility_pub.program_application_id,
               -- program_id = hz_utility_pub.program_id,
               -- program_update_date = sysdate
            where primary_contact_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.CAMPAIGN_CONTACT_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Campaign_Contact_Merge;
-----------------------------------------------------------------------
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
  l_api_name            CONSTANT VARCHAR2(30) := 'PARTY_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

  l_to_party_exists     varchar2(20);
BEGIN
/* julou 08-APR-2004 migrated to ozfvprmb.pls
    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.TRADE_PROFILE_PARTY_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

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

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.TRADE_PROFILE_PARTY_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));
*/
NULL;
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
  l_api_name            CONSTANT VARCHAR2(30) := 'PARTY_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN
/* julou 08-APR-2004 migrated to ozfvprmb.pls
    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.CLAIM_BROKER_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

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

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.CLAIM_BROKER_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));
*/
NULL;
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
  l_api_name            CONSTANT VARCHAR2(30) := 'PARTY_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN
/* julou 08-APR-2004 migrated to ozfvprmb.pls
    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.CLAIM_CONTACT_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

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

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.CLAIM_CONTACT_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));
*/
NULL;
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
  l_api_name            CONSTANT VARCHAR2(30) := 'PARTY_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN
/* julou 08-APR-2004 migrated to ozfvprmb.pls
    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.CLAIM_HISTORY_BROKER_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

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

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.CLAIM_HISTORY_BROKER_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));
*/
NULL;
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
  l_api_name            CONSTANT VARCHAR2(30) := 'PARTY_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN
/* julou 08-APR-2004 migrated to ozfvprmb.pls
    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.CLAIM_HISTORY_CONTACT_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

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

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.CLAIM_HISTORY_CONTACT_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));
*/
NULL;
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
  l_api_name            CONSTANT VARCHAR2(30) := 'PARTY_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN
/* julou 08-APR-2004 migrated to ozfvprmb.pls
    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.BUDGET_PARTY_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

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

            UPDATE AMS_ACT_BUDGETS
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

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.BUDGET_PARTY_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));
*/
NULL;
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
  l_api_name            CONSTANT VARCHAR2(30) := 'PARTY_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN
/* julou 08-APR-2004 migrated to ozfvprmb.pls
    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.BUDGET_VENDOR_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

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

            UPDATE AMS_ACT_BUDGETS
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

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.BUDGET_VENDOR_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));
*/
NULL;
END Budget_Vendor_Merge;

PROCEDURE OFFER_PARTY_MERGE
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
  l_api_name            CONSTANT VARCHAR2(30) := 'OFFER_PARTY_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN
/* julou 08-APR-2004 migrated to ozfvprmb.pls
    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.OFFER_PARTY_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

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

            UPDATE AMS_OFFERS
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

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.OFFER_PARTY_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));
*/
NULL;
END OFFER_PARTY_Merge;


-----------------------------------------------------------------------
-- PROCEDURE
--   Product_Comp_Party_Merge
--
-- HISTORY
--   09/24/2001  abhola  Created.
-----------------------------------------------------------------------
PROCEDURE Product_Comp_Party_Merge
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
  l_api_name            CONSTANT VARCHAR2(30) := 'PARTY_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.Product_Comp_Party_Merge start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

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

            UPDATE ams_competitor_products_b
            SET COMPETITOR_PARTY_ID = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login
            where COMPETITOR_PARTY_ID = p_from_fk_id  ;

       END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.Product_Comp_Party_Merge end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Product_Comp_Party_Merge;

-----------------------------------------------------------------------
-- PROCEDURE
--   PLACEMENT_SITE_PARTY_MERGE
--
-- HISTORY
--   03/05/2002  sodixit  Created.
-----------------------------------------------------------------------
PROCEDURE PLACEMENT_SITE_PARTY_MERGE
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
  l_api_name            CONSTANT VARCHAR2(30) := 'PARTY_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.PLACEMENT_SITE_PARTY_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

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

            UPDATE AMS_IBA_PL_SITES_B
            SET SITE_CATEGORY_OBJECT_ID = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login
            where SITE_CATEGORY_OBJECT_ID = p_from_fk_id
            and   SITE_CATEGORY_TYPE = 'AFFILIATES' ;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.PLACEMENT_SITE_PARTY_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END PLACEMENT_SITE_PARTY_MERGE;

-----------------------------------------------------------------------
-- PROCEDURE
--    Src_lines_Party_Merge
--
-- HISTORY
--   01/09/2003  USingh   Created.
-----------------------------------------------------------------------
PROCEDURE Src_lines_Party_Merge
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
  l_api_name            CONSTANT VARCHAR2(30) := 'PARTY_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.CHANNEL_PARTY_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

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
         -- Following lines of code is added by ptendulk on 14-May-2001
            -- to do the party merge for table ams_channels_b
            UPDATE AMS_IMP_SOURCE_LINES
            SET   party_id = p_to_fk_id,
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

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.CHANNEL_PARTY_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Src_lines_Party_Merge;

-----------------------------------------------------------------------
-- PROCEDURE
--    List_entries_Party_Merge
--
-- HISTORY
--   01/09/2003  USingh   Created.
-----------------------------------------------------------------------
PROCEDURE List_entries_Party_Merge
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
  l_api_name            CONSTANT VARCHAR2(30) := 'PARTY_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.CHANNEL_PARTY_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

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
         -- Following lines of code is added by ptendulk on 14-May-2001
            -- to do the party merge for table ams_channels_b
            UPDATE AMS_LIST_ENTRIES
            SET   party_id = p_to_fk_id,
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

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.CHANNEL_PARTY_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END List_entries_Party_Merge;

-----------------------------------------------------------------------
-- PROCEDURE
--    Listentries_Parent_Party_Merge
--
-- HISTORY
--   01/09/2003  USingh   Created.
-----------------------------------------------------------------------
PROCEDURE Listentries_Parent_Party_Merge
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
  l_api_name            CONSTANT VARCHAR2(30) := 'PARTY_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.CHANNEL_PARTY_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

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
         -- Following lines of code is added by ptendulk on 14-May-2001
            -- to do the party merge for table ams_channels_b
            UPDATE AMS_LIST_ENTRIES
            SET   parent_party_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login
            where parent_party_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.CHANNEL_PARTY_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Listentries_Parent_Party_Merge;

-----------------------------------------------------------------------
-- PROCEDURE
--    Venues_Party_Merge created for (ams_venues_b)
--
-- HISTORY
--   06-Mar-2003    Musman   Created
-----------------------------------------------------------------------
PROCEDURE Venues_Party_Merge
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY  NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY  VARCHAR2
) is
  l_api_name            CONSTANT VARCHAR2(30) := 'PARTY_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.VENUES_PARTY_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

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
         -- Following lines of code is added by musman on 6-Mar-2003
         -- to do the party merge for table ams_venues_b
            UPDATE AMS_VENUES_B
            SET   party_id = p_to_fk_id,
               last_update_date = hz_utility_pub.last_update_date,
               last_updated_by = hz_utility_pub.user_id,
               last_update_login = hz_utility_pub.last_update_login
	       --enabled_flag = 'N'  -- added to fix bug#3483075:anchaudh
            where party_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.VENUES_PARTY_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Venues_Party_Merge;

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
  l_api_name            CONSTANT VARCHAR2(30) := 'PARTY_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

  CURSOR c_list_header_id IS
  SELECT qp_list_header_id
  FROM   ams_offer_parties
  WHERE  party_id = p_from_fk_id;

  CURSOR c_is_duplicate(l_list_header_id NUMBER, l_party_id NUMBER) IS
  SELECT 'Y'
  FROM   ams_offer_parties
  WHERE  qp_list_header_id = l_list_header_id
  AND    party_id = l_party_id;

  l_is_duplicate VARCHAR2(10);

BEGIN
/* julou 08-APR-2004 migrated to ozfvprmb.pls
    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.OFFER_DENORM_PARTY_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

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
          FOR l_list_header_id IN c_list_header_id LOOP
            l_is_duplicate := NULL;

	          OPEN c_is_duplicate(l_list_header_id.qp_list_header_id, p_to_fk_id);
            FETCH c_is_duplicate INTO l_is_duplicate;
            CLOSE c_is_duplicate;

            IF l_is_duplicate = 'Y' THEN
            DELETE FROM ams_offer_parties
            WHERE qp_list_header_id = l_list_header_id.qp_list_header_id
            AND   party_id = p_from_fk_id;
          ELSE
            UPDATE ams_offer_parties
            SET    party_id = p_to_fk_id
	                ,last_update_date = hz_utility_pub.last_update_date
                  ,last_updated_by = hz_utility_pub.user_id
                  ,last_update_login = hz_utility_pub.last_update_login
            WHERE  qp_list_header_id = l_list_header_id.qp_list_header_id
            AND    party_id = p_from_fk_id;
          END IF;

        END LOOP;
      END IF;
      EXCEPTION
        WHEN OTHERS THEN
          arp_message.set_line(g_pkg_name || '.' || l_api_name || ': ' || sqlerrm);
          x_return_status :=  FND_API.G_RET_STS_ERROR;
          raise;
      END;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.OFFER_DENORM_PARTY_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));
*/
NULL;
END Offer_Denorm_Party_Merge;


-----------------------------------------------------------------------
-- PROCEDURE
--    Resources_Party_Merge created for (ams_act_resources)
--
-- HISTORY
--   16-May-2003    soagrawa    Created
-----------------------------------------------------------------------



PROCEDURE Resources_Party_Merge
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY  NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY  VARCHAR2
) is
  l_api_name            CONSTANT VARCHAR2(30) := 'PARTY_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN


FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.RESOURCES_PARTY_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code into l_merge_reason_code
    from HZ_MERGE_BATCH
    where batch_id = p_batch_id;

    IF l_merge_reason_code = 'DUPLICATE' THEN
       --***************************************************************************
       -- if reason code is duplicate then allow the party merge to happen without
       -- any validations.
       --***************************************************************************
     null;
    ELSE
       --***************************************************************************
       -- if there are any validations to be done, include it in this section
       --***************************************************************************
     null;
    END IF;

    --***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    --***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

    --***************************************************************************
    -- If the parent has changed(ie. Parent is getting merged) then transfer the
    -- dependent record to the new parent. Before transferring check if a similar
    -- dependent record exists on the new parent. If a duplicate exists then do
    -- not transfer and return the id of the duplicate record as the Merged To Id
    --***************************************************************************

    --***************************************************************************
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
    --***************************************************************************

    IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party


            -- Following lines of code is added by soagrawa on 23-Mar-2003
            -- to do the party merge for table ams_act_resources

               UPDATE AMS_ACT_RESOURCES
               SET   resource_id = p_to_fk_id,
                     last_update_date = hz_utility_pub.last_update_date,
                     last_updated_by = hz_utility_pub.user_id,
                     last_update_login = hz_utility_pub.last_update_login
               where resource_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': '|| sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.RESOURCES_PARTY_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Resources_Party_Merge;

-----------------------------------------------------------------------
-- PROCEDURE
--    Agendas_Party_Merge created for (ams_agendas_b)
--
-- HISTORY
--   09-May-2003    dbiswas    Created
-----------------------------------------------------------------------

PROCEDURE Agendas_Party_Merge
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY  NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY  VARCHAR2
) is
  l_api_name            CONSTANT VARCHAR2(30) := 'PARTY_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN


FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.AGENDAS_PARTY_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code into l_merge_reason_code
    from HZ_MERGE_BATCH
    where batch_id = p_batch_id;

    IF l_merge_reason_code = 'DUPLICATE' THEN
       --***************************************************************************
       -- if reason code is duplicate then allow the party merge to happen without
       -- any validations.
       --***************************************************************************
     null;
    ELSE
       --***************************************************************************
       -- if there are any validations to be done, include it in this section
       --***************************************************************************
     null;
    END IF;

    --***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    --***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

    --***************************************************************************
    -- If the parent has changed(ie. Parent is getting merged) then transfer the
    -- dependent record to the new parent. Before transferring check if a similar
    -- dependent record exists on the new parent. If a duplicate exists then do
    -- not transfer and return the id of the duplicate record as the Merged To Id
    --***************************************************************************

    --***************************************************************************
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
    --***************************************************************************

    IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party


            -- Following lines of code is added by  dbiswas on 09-Mar-2003
            -- to do the party merge for table ams_agendas_b
               UPDATE AMS_AGENDAS_B
               SET   coordinator_id = p_to_fk_id,
                     last_update_date = hz_utility_pub.last_update_date,
                     last_updated_by = hz_utility_pub.user_id,
                     last_update_login = hz_utility_pub.last_update_login
               where coordinator_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': '|| sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.AGENDAS_PARTY_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END Agendas_Party_Merge;

-----------------------------------------------------------------------
-- PROCEDURE
--    TCOP_CHANNEL_PARTY_MERGE created for (AMS_TCOP_CHANNEL_SUMMARY)
--
-- HISTORY
--   02-Jan-2004    mayjain    Created
-----------------------------------------------------------------------
PROCEDURE TCOP_CHANNEL_PARTY_MERGE
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY  NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY  VARCHAR2
)
is
  l_api_name            CONSTANT VARCHAR2(30) := 'PARTY_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);



BEGIN


FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.TCOP_CHANNEL_PARTY_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code into l_merge_reason_code
    from HZ_MERGE_BATCH
    where batch_id = p_batch_id;

    IF l_merge_reason_code = 'DUPLICATE' THEN
       --***************************************************************************
       -- if reason code is duplicate then allow the party merge to happen without
       -- any validations.
       --***************************************************************************
     null;
    ELSE
       --***************************************************************************
       -- if there are any validations to be done, include it in this section
       --***************************************************************************
     null;
    END IF;

    --***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    --***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

    --***************************************************************************
    -- If the parent has changed(ie. Parent is getting merged) then transfer the
    -- dependent record to the new parent. Before transferring check if a similar
    -- dependent record exists on the new parent. If a duplicate exists then do
    -- not transfer and return the id of the duplicate record as the Merged To Id
    --***************************************************************************

    --***************************************************************************
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
    --***************************************************************************

    IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

	      	 -- Delete all the rows with which have the p_from_fk_id and media_id combination same as p_to_fk_id and media_id
		 DELETE FROM AMS_TCOP_CHANNEL_SUMMARY
		 WHERE party_id = p_from_fk_id
		 and channel_summary_id in
		 (SELECT f.channel_summary_id
		  FROM AMS_TCOP_CHANNEL_SUMMARY f, AMS_TCOP_CHANNEL_SUMMARY t
		  WHERE f.party_id = p_from_fk_id
		        AND t.party_id = p_to_fk_id
                        AND f.MEDIA_ID  = t.MEDIA_ID);

		   -- Update the rows which do not satisfy the above criteria
                   UPDATE AMS_TCOP_CHANNEL_SUMMARY
		   SET   party_id = p_to_fk_id,
                         last_update_date = hz_utility_pub.last_update_date,
                         last_updated_by = hz_utility_pub.user_id,
                         last_update_login = hz_utility_pub.last_update_login
		   WHERE party_id = p_from_fk_id
		   and channel_summary_id not in
		  (SELECT f.channel_summary_id
		   FROM AMS_TCOP_CHANNEL_SUMMARY f, AMS_TCOP_CHANNEL_SUMMARY t
		   WHERE f.party_id = p_from_fk_id
		        AND t.party_id = p_to_fk_id
                        AND f.MEDIA_ID  = t.MEDIA_ID);

        END IF;
       EXCEPTION
          WHEN OTHERS THEN

	     arp_message.set_line(g_pkg_name || '.' || l_api_name || ': '|| sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.TCOP_CHANNEL_PARTY_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END TCOP_CHANNEL_PARTY_MERGE;



-----------------------------------------------------------------------
-- PROCEDURE
--    TCOP_CONTACT_PARTY_MERGE created for (AMS_TCOP_CONTACTS)
--
-- HISTORY
--   02-Jan-2004    mayjain    Created
-----------------------------------------------------------------------
PROCEDURE TCOP_CONTACT_PARTY_MERGE
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY  NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY  VARCHAR2
)
is
  l_api_name            CONSTANT VARCHAR2(30) := 'PARTY_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);



BEGIN


FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.TCOP_CONTACT_PARTY_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code into l_merge_reason_code
    from HZ_MERGE_BATCH
    where batch_id = p_batch_id;

    IF l_merge_reason_code = 'DUPLICATE' THEN
       --***************************************************************************
       -- if reason code is duplicate then allow the party merge to happen without
       -- any validations.
       --***************************************************************************
     null;
    ELSE
       --***************************************************************************
       -- if there are any validations to be done, include it in this section
       --***************************************************************************
     null;
    END IF;

    --***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    --***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

    --***************************************************************************
    -- If the parent has changed(ie. Parent is getting merged) then transfer the
    -- dependent record to the new parent. Before transferring check if a similar
    -- dependent record exists on the new parent. If a duplicate exists then do
    -- not transfer and return the id of the duplicate record as the Merged To Id
    --***************************************************************************

    --***************************************************************************
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
    --***************************************************************************

    IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

	         DELETE FROM AMS_TCOP_CONTACTS
		 WHERE party_id = p_from_fk_id
		 and CONTACT_ID  in
		 (SELECT f.CONTACT_ID
		  FROM AMS_TCOP_CONTACTS f, AMS_TCOP_CONTACTS t
		  WHERE f.party_id = p_from_fk_id
		        AND t.party_id = p_to_fk_id
                        AND f.SCHEDULE_ID  = t.SCHEDULE_ID);


                   UPDATE AMS_TCOP_CONTACTS
		   SET   party_id = p_to_fk_id,
                         last_update_date = hz_utility_pub.last_update_date,
                         last_updated_by = hz_utility_pub.user_id,
                         last_update_login = hz_utility_pub.last_update_login
		   WHERE party_id = p_from_fk_id
		   and CONTACT_ID not in
		 (SELECT f.CONTACT_ID
		  FROM AMS_TCOP_CONTACTS f, AMS_TCOP_CONTACTS t
		  WHERE f.party_id = p_from_fk_id
		        AND t.party_id = p_to_fk_id
                        AND f.SCHEDULE_ID  = t.SCHEDULE_ID);

        END IF;
       EXCEPTION
          WHEN OTHERS THEN

	     arp_message.set_line(g_pkg_name || '.' || l_api_name || ': '|| sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.TCOP_CONTACT_PARTY_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END TCOP_CONTACT_PARTY_MERGE;


-----------------------------------------------------------------------
-- PROCEDURE
--    TCOP_CONTACT_SUMM_PARTY_MERGE created for (AMS_TCOP_CONTACT_SUMMARY)
--
-- HISTORY
--   02-Jan-2004    mayjain    Created
-----------------------------------------------------------------------
PROCEDURE TCOP_CONTACT_SUMM_PARTY_MERGE
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY  NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY  VARCHAR2
)
is
  l_api_name            CONSTANT VARCHAR2(30) := 'PARTY_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);
  l_party_val_flag      VARCHAR2(1);
  l_temp_num            NUMBER;

  CURSOR party_cur(to_party NUMBER)
  IS
	SELECT 1
	FROM AMS_TCOP_CONTACT_SUMMARY
	WHERE party_id = to_party;

BEGIN


FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.TCOP_CONTACT_SUMM_PARTY_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code into l_merge_reason_code
    from HZ_MERGE_BATCH
    where batch_id = p_batch_id;

    IF l_merge_reason_code = 'DUPLICATE' THEN
       --***************************************************************************
       -- if reason code is duplicate then allow the party merge to happen without
       -- any validations.
       --***************************************************************************
     null;
    ELSE
       --***************************************************************************
       -- if there are any validations to be done, include it in this section
       --***************************************************************************
     null;
    END IF;

    --***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    --***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

    --***************************************************************************
    -- If the parent has changed(ie. Parent is getting merged) then transfer the
    -- dependent record to the new parent. Before transferring check if a similar
    -- dependent record exists on the new parent. If a duplicate exists then do
    -- not transfer and return the id of the duplicate record as the Merged To Id
    --***************************************************************************

    --***************************************************************************
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
    --***************************************************************************

    IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

              OPEN party_cur (p_to_fk_id);
	      FETCH party_cur into l_temp_num;
	      IF party_cur%FOUND
	      THEN
		l_party_val_flag := 'Y';
	      ELSE
		l_party_val_flag := 'N';
	      END IF;
	      CLOSE party_cur;

	      IF l_party_val_flag = 'Y'
	      THEN

		  DELETE FROM AMS_TCOP_CONTACT_SUMMARY
		  WHERE party_id = p_from_fk_id;

	      ELSE
	          UPDATE AMS_TCOP_CONTACT_SUMMARY
                  SET   party_id = p_to_fk_id,
                        last_update_date = hz_utility_pub.last_update_date,
                        last_updated_by = hz_utility_pub.user_id,
                        last_update_login = hz_utility_pub.last_update_login
                  WHERE party_id = p_from_fk_id;
	     END IF;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': '|| sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.TCOP_CONTACT_SUMM_PARTY_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END TCOP_CONTACT_SUMM_PARTY_MERGE;


-----------------------------------------------------------------------
-- PROCEDURE
--    TCOP_PRVW_CONTACT_PARTY_MERGE created for (AMS_TCOP_PRVW_CONTACTS)
--
-- HISTORY
--   02-Jan-2004    mayjain    Created
-----------------------------------------------------------------------
PROCEDURE TCOP_PRVW_CONTACT_PARTY_MERGE
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY  NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY  VARCHAR2
)
is
  l_api_name            CONSTANT VARCHAR2(30) := 'PARTY_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);


BEGIN


FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.TCOP_PRVW_CONTACT_PARTY_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code into l_merge_reason_code
    from HZ_MERGE_BATCH
    where batch_id = p_batch_id;

    IF l_merge_reason_code = 'DUPLICATE' THEN
       --***************************************************************************
       -- if reason code is duplicate then allow the party merge to happen without
       -- any validations.
       --***************************************************************************
     null;
    ELSE
       --***************************************************************************
       -- if there are any validations to be done, include it in this section
       --***************************************************************************
     null;
    END IF;

    --***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    --***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

    --***************************************************************************
    -- If the parent has changed(ie. Parent is getting merged) then transfer the
    -- dependent record to the new parent. Before transferring check if a similar
    -- dependent record exists on the new parent. If a duplicate exists then do
    -- not transfer and return the id of the duplicate record as the Merged To Id
    --***************************************************************************

    --***************************************************************************
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
    --***************************************************************************

    IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party



		  UPDATE AMS_TCOP_PRVW_CONTACTS
                  SET   party_id = p_to_fk_id,
                        last_update_date = hz_utility_pub.last_update_date,
                        last_updated_by = hz_utility_pub.user_id,
                        last_update_login = hz_utility_pub.last_update_login
                  WHERE party_id = p_from_fk_id;

        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': '|| sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.TCOP_PRVW_CONTACT_PARTY_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END TCOP_PRVW_CONTACT_PARTY_MERGE;



-----------------------------------------------------------------------
-- PROCEDURE
--    TCOP_PRVW_FTG_DTL_PARTY_MERGE created for (AMS_TCOP_PRVW_FTG_DTLS)
--
-- HISTORY
--   02-Jan-2004    mayjain    Created
-----------------------------------------------------------------------
PROCEDURE TCOP_PRVW_FTG_DTL_PARTY_MERGE
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY  NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY  VARCHAR2
)
is
  l_api_name            CONSTANT VARCHAR2(30) := 'PARTY_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);

BEGIN


FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.TCOP_PRVW_FTG_DTL_PARTY_MERGE start : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code into l_merge_reason_code
    from HZ_MERGE_BATCH
    where batch_id = p_batch_id;

    IF l_merge_reason_code = 'DUPLICATE' THEN
       --***************************************************************************
       -- if reason code is duplicate then allow the party merge to happen without
       -- any validations.
       --***************************************************************************
     null;
    ELSE
       --***************************************************************************
       -- if there are any validations to be done, include it in this section
       --***************************************************************************
     null;
    END IF;

    --***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    --***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

    --***************************************************************************
    -- If the parent has changed(ie. Parent is getting merged) then transfer the
    -- dependent record to the new parent. Before transferring check if a similar
    -- dependent record exists on the new parent. If a duplicate exists then do
    -- not transfer and return the id of the duplicate record as the Merged To Id
    --***************************************************************************

    --***************************************************************************
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
    --***************************************************************************

    IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
        IF p_parent_entity_name = 'HZ_PARTIES' THEN           -- merge party

	       DELETE FROM AMS_TCOP_PRVW_FTG_DTLS
		 WHERE party_id = p_from_fk_id
		 and FATIGUE_DETAIL_ID  in
		 (SELECT f.FATIGUE_DETAIL_ID
		  FROM AMS_TCOP_PRVW_FTG_DTLS f, AMS_TCOP_PRVW_FTG_DTLS t
		  WHERE f.party_id = p_from_fk_id
		        AND t.party_id = p_to_fk_id
                        AND f.PREVIEW_ID  = t.PREVIEW_ID);

               UPDATE AMS_TCOP_PRVW_FTG_DTLS
               SET   party_id = p_to_fk_id,
                     last_update_date = hz_utility_pub.last_update_date,
                     last_updated_by = hz_utility_pub.user_id,
                     last_update_login = hz_utility_pub.last_update_login
               where party_id = p_from_fk_id
	       and FATIGUE_DETAIL_ID not in
		 (SELECT f.FATIGUE_DETAIL_ID
		  FROM AMS_TCOP_PRVW_FTG_DTLS f, AMS_TCOP_PRVW_FTG_DTLS t
		  WHERE f.party_id = p_from_fk_id
		        AND t.party_id = p_to_fk_id
                        AND f.PREVIEW_ID  = t.PREVIEW_ID);
        END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_pkg_name || '.' || l_api_name || ': '|| sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;


FND_FILE.PUT_LINE(FND_FILE.LOG,'AMS_PARTY_MERGE_PKG.TCOP_PRVW_FTG_DTL_PARTY_MERGE end : '||to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END TCOP_PRVW_FTG_DTL_PARTY_MERGE;


END AMS_PARTY_MERGE_PVT;

/
