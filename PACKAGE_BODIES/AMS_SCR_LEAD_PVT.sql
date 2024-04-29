--------------------------------------------------------
--  DDL for Package Body AMS_SCR_LEAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_SCR_LEAD_PVT" AS
/* $Header: amsvsldb.pls 115.4 2003/12/01 07:56:23 sodixit noship $ */
-- ===============================================================
-- Package name
--         AMS_SCR_LEAD_PVT
-- Purpose
--          This package contains APIs used for creating Sales Lead
--
-- History
--
-- NOTE
--
-- ===============================================================

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
G_B2C_PARTY_TYPE VARCHAR2(10) := 'B2C';
G_B2B_PARTY_TYPE VARCHAR2(10) := 'B2B';
--===================================================================
--   API Name
--         CREATE_SALES_LEAD
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_dlg_ctx_field_list_obj IN  AMS_DLG_CTX_FIELD_LIST_T Required
--       p_flow_component_id       IN  Number
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   ==============================================================================
--

PROCEDURE CREATE_SALES_LEAD(
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_party_type                 IN   VARCHAR2,
    p_scr_lead_rec               IN   scr_lead_rec_type := g_miss_lead_rec,
    p_camp_sch_source_code	 IN   VARCHAR2,
    x_return_status              OUT  NOCOPY  VARCHAR2,
    x_msg_count                  OUT  NOCOPY  NUMBER,
    x_msg_data                   OUT  NOCOPY  VARCHAR2,
    p_party_id			 IN   NUMBER,
    p_org_party_id		 IN   NUMBER,
    p_org_rel_party_id           IN   NUMBER
     )
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Sales_Lead';
   l_party_type varchar2(30);
   l_batch_id number;
   l_contact_party_id number;
   l_party_id number;
   l_person_party_id number;
   l_org_party_id number;
   l_rel_party_id number;

   cursor c_get_batch_id
   is
   select as_import_interface_s.nextval
   from dual;

   cursor c_get_party_ids (l_rel_party_id in number)
   is
   select subject_id person_party_id, object_id org_party_id
   from hz_relationships
   where party_id = l_rel_party_id
   and
   relationship_type = 'CONTACT'
   and
   directional_flag = 'F'
   and
   relationship_code = 'CONTACT_OF';

BEGIN

   x_return_status := 'S';

   --insert into ams_script_tmp
   --values('p_party_id='||p_party_id, sysdate);

   open c_get_batch_id;
   fetch c_get_batch_id into l_batch_id;
   close c_get_batch_id;

   if (p_party_type = G_B2C_PARTY_TYPE) then
      if p_party_id IS NOT NULL
      then
	      l_party_id := p_party_id;

	      --insert into ams_script_tmp
	      --values('B2C partyId='||p_party_type, sysdate);
      end if;
      l_party_type := 'PERSON';
   elsif (p_party_type = G_B2B_PARTY_TYPE) then
      if p_party_id IS NOT NULL
      then
	      open c_get_party_ids(p_party_id);
	      fetch c_get_party_ids into l_person_party_id, l_org_party_id;
	      close c_get_party_ids;

		--   insert into ams_script_tmp
		--   values('B2B partyId='||p_party_type, sysdate);

	      l_party_id := l_org_party_id;
	      l_contact_party_id := l_person_party_id;
      end if;

      l_party_type := 'ORGANIZATION';

   end if;

   --insert into ams_script_tmp
   --values('p_party_type='||p_party_type, sysdate);

   INSERT INTO
   AS_IMPORT_INTERFACE
   (
     IMPORT_INTERFACE_ID,
     CREATED_BY,
     CREATION_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATE_LOGIN,
     LOAD_TYPE,
     LOAD_DATE,
     LOAD_STATUS,
     STATUS_CODE,
     PROMOTION_CODE,
     BATCH_ID,
     SOURCE_SYSTEM,
     CUSTOMER_NAME,
     CUSTOMER_TYPE,
     FIRST_NAME,
     LAST_NAME,
     EMAIL_ADDRESS,
     PHONE_NUMBER,
     PHONE_TYPE,
     ADDRESS1,
     ADDRESS2,
     ADDRESS3,
     ADDRESS4,
     CITY,
     STATE,
     POSTAL_CODE,
     COUNTRY,
     BUDGET_AMOUNT,
     CURRENCY_CODE,
     BUDGET_STATUS_CODE,
     DECISION_TIMEFRAME_CODE,
     CONTACT_ROLE_CODE,
     category_id_1,   --bug3287870; modified interest_type_id_1 to category_type_id
     PARTY_ID,
     CONTACT_PARTY_ID,
     PARTY_TYPE
   )
   VALUES
   (
     l_batch_id,
     FND_GLOBAL.USER_ID,
     sysdate,
     FND_GLOBAL.USER_ID,
     sysdate,
     FND_GLOBAL.USER_ID,
     'LEAD_LOAD',
     sysdate,
     'NEW',
     'NEW',
     p_camp_sch_source_code,
     l_batch_id,
     'MARKETING',
     p_scr_lead_rec.ORGANIZATION,
     l_party_type,
     p_scr_lead_rec.FIRST_NAME,
     p_scr_lead_rec.LAST_NAME,
     p_scr_lead_rec.EMAIL_ADDRESS,
     p_scr_lead_rec.DAY_PHONE_NUMBER,
     'GEN',
     p_scr_lead_rec.ADDRESS1,
     p_scr_lead_rec.ADDRESS2,
     p_scr_lead_rec.ADDRESS3,
     p_scr_lead_rec.ADDRESS4,
     p_scr_lead_rec.CITY,
     p_scr_lead_rec.STATE,
     p_scr_lead_rec.POSTAL_CODE,
     p_scr_lead_rec.COUNTRY,
     p_scr_lead_rec.BUDGET_AMOUNT,
     p_scr_lead_rec.BUDGET_CURRENCY_CODE,
     p_scr_lead_rec.BUDGET_STATUS_CODE,
     p_scr_lead_rec.PURCHASING_TIME_FRAME,
     p_scr_lead_rec.CONTACT_ROLE_CODE,
     p_scr_lead_rec.INTEREST_TYPE,
     l_party_id,
     l_contact_party_id,
     l_party_type
     );

EXCEPTION

WHEN OTHERS THEN
   RAISE;

END CREATE_SALES_LEAD;

END  AMS_SCR_LEAD_PVT;

/
