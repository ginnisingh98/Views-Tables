--------------------------------------------------------
--  DDL for Package Body AS_OPP_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_OPP_MERGE_PKG" as
/* $Header: asxpmopb.pls 120.2 2006/05/24 06:14:41 subabu ship $ */
--
-- NAME
-- AS_OPP_MERGE_PKG
--
-- HISTORY
--   02/20/2001    XDING         CREATED
--

G_API_NAME      CONSTANT VARCHAR2(30):='AS_OPP_MERGE_PKG.OPP_MERGE';

PROCEDURE OPP_MERGE
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY /* file.sql.39 change */   NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
--   ,p_request_id              IN       NUMBER
   ,x_return_status           IN OUT NOCOPY /* file.sql.39 change */   VARCHAR2
) is
  l_col_name            VARCHAR2(60) ;
  l_api_version_number  CONSTANT NUMBER       := 2.0;
  l_merge_reason_code   VARCHAR2(30);
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code into l_merge_reason_code
    from HZ_MERGE_BATCH
    where batch_id = p_batch_id;


    IF l_merge_reason_code = 'DUPLICATE' THEN

	  null;
    ELSE
	  null;
    END IF;

    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

    IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
	     IF p_parent_entity_name = 'HZ_PARTIES' THEN

		   l_col_name := 'AS_LEADS_ALL.customer_id';

	   	   UPDATE AS_LEADS_ALL
		   set object_version_number =  nvl(object_version_number,0) + 1, customer_id = p_to_fk_id,
			  last_update_date = hz_utility_pub.last_update_date,
			  last_updated_by = hz_utility_pub.user_id,
			  last_update_login = hz_utility_pub.last_update_login,
			  request_id = hz_utility_pub.request_id,
			  program_application_id = hz_utility_pub.program_application_id,
			  program_id = hz_utility_pub.program_id,
			  program_update_date = sysdate
		   where customer_id = p_from_fk_id;

		   l_col_name := 'AS_LEADS_ALL.close_competitor_id';

	   	   UPDATE AS_LEADS_ALL
		   set object_version_number =  nvl(object_version_number,0) + 1, close_competitor_id = p_to_fk_id,
			  last_update_date = hz_utility_pub.last_update_date,
			  last_updated_by = hz_utility_pub.user_id,
			  last_update_login = hz_utility_pub.last_update_login,
			  request_id = hz_utility_pub.request_id,
			  program_application_id = hz_utility_pub.program_application_id,
			  program_id = hz_utility_pub.program_id,
			  program_update_date = sysdate
		   where close_competitor_id = p_from_fk_id;

/*
 		   l_col_name := 'AS_LEADS_ALL.end_user_customer_id';

	   	   UPDATE AS_LEADS_ALL
		   set object_version_number =  nvl(object_version_number,0) + 1, end_user_customer_id = p_to_fk_id,
			  last_update_date = hz_utility_pub.last_update_date,
			  last_updated_by = hz_utility_pub.user_id,
			  last_update_login = hz_utility_pub.last_update_login,
			  request_id = hz_utility_pub.request_id,
			  program_application_id = hz_utility_pub.program_application_id,
			  program_id = hz_utility_pub.program_id,
			  program_update_date = sysdate
		   where end_user_customer_id = p_from_fk_id;
*/

		   l_col_name := 'AS_LEADS_ALL.incumbent_partner_party_id';

	   	   UPDATE AS_LEADS_ALL
		   set object_version_number =  nvl(object_version_number,0) + 1, incumbent_partner_party_id = p_to_fk_id,
		          incumbent_partner_resource_id=( select resource_id
	                        from jtf_rs_resource_extns
				where category = 'PARTNER'
				and source_id = p_to_fk_id),
			  last_update_date = hz_utility_pub.last_update_date,
			  last_updated_by = hz_utility_pub.user_id,
			  last_update_login = hz_utility_pub.last_update_login,
			  request_id = hz_utility_pub.request_id,
			  program_application_id = hz_utility_pub.program_application_id,
			  program_id = hz_utility_pub.program_id,
			  program_update_date = sysdate
		   where incumbent_partner_party_id = p_from_fk_id;

		   l_col_name := 'AS_LEAD_COMPETITORS.competitor_id';

		   UPDATE AS_LEAD_COMPETITORS
		   set object_version_number =  nvl(object_version_number,0) + 1, competitor_id = p_to_fk_id,
			  last_update_date = hz_utility_pub.last_update_date,
			  last_updated_by = hz_utility_pub.user_id,
			  last_update_login = hz_utility_pub.last_update_login,
			  request_id = hz_utility_pub.request_id,
			  program_application_id = hz_utility_pub.program_application_id,
			  program_id = hz_utility_pub.program_id,
			  program_update_date = sysdate
		   where competitor_id = p_from_fk_id;

 		   l_col_name := 'AS_LEAD_CONTACTS_ALL.contact_party_id';

		   UPDATE AS_LEAD_CONTACTS_ALL
		   set object_version_number =  nvl(object_version_number,0) + 1, contact_party_id = p_to_fk_id,
			  last_update_date = hz_utility_pub.last_update_date,
			  last_updated_by = hz_utility_pub.user_id,
			  last_update_login = hz_utility_pub.last_update_login,
			  request_id = hz_utility_pub.request_id,
			  program_application_id = hz_utility_pub.program_application_id,
			  program_id = hz_utility_pub.program_id,
			  program_update_date = sysdate
		   where contact_party_id = p_from_fk_id;

 		   l_col_name := 'AS_LEAD_CONTACTS_ALL.customer_id';

		   UPDATE AS_LEAD_CONTACTS_ALL
		   set object_version_number =  nvl(object_version_number,0) + 1, customer_id = p_to_fk_id,
			  last_update_date = hz_utility_pub.last_update_date,
			  last_updated_by = hz_utility_pub.user_id,
			  last_update_login = hz_utility_pub.last_update_login,
			  request_id = hz_utility_pub.request_id,
			  program_application_id = hz_utility_pub.program_application_id,
			  program_id = hz_utility_pub.program_id,
			  program_update_date = sysdate
		   where customer_id = p_from_fk_id;

 		   l_col_name := 'AS_SALES_CREDITS.partner_customer_id';

		   UPDATE AS_SALES_CREDITS
		   set object_version_number =  nvl(object_version_number,0) + 1, partner_customer_id = p_to_fk_id,
			  last_update_date = hz_utility_pub.last_update_date,
			  last_updated_by = hz_utility_pub.user_id,
			  last_update_login = hz_utility_pub.last_update_login,
			  request_id = hz_utility_pub.request_id,
			  program_application_id = hz_utility_pub.program_application_id,
			  program_id = hz_utility_pub.program_id,
			  program_update_date = sysdate
		   where partner_customer_id = p_from_fk_id;

 		   l_col_name := 'AS_SALES_CREDITS_DENORM.partner_customer_id';

		   UPDATE AS_SALES_CREDITS_DENORM
		   set object_version_number =  nvl(object_version_number,0) + 1, partner_customer_id = p_to_fk_id,
			  last_update_date = hz_utility_pub.last_update_date,
			  last_updated_by = hz_utility_pub.user_id,
			  last_update_login = hz_utility_pub.last_update_login,
			  request_id = hz_utility_pub.request_id,
			  program_application_id = hz_utility_pub.program_application_id,
			  program_id = hz_utility_pub.program_id,
			  program_update_date = sysdate
		   where partner_customer_id = p_from_fk_id;

 		   l_col_name := 'AS_SALES_CREDITS_DENORM.customer_id';

		   UPDATE AS_SALES_CREDITS_DENORM
		   set object_version_number =  nvl(object_version_number,0) + 1, customer_id = p_to_fk_id,
			  last_update_date = hz_utility_pub.last_update_date,
			  last_updated_by = hz_utility_pub.user_id,
			  last_update_login = hz_utility_pub.last_update_login,
			  request_id = hz_utility_pub.request_id,
			  program_application_id = hz_utility_pub.program_application_id,
			  program_id = hz_utility_pub.program_id,
			  program_update_date = sysdate
		   where customer_id = p_from_fk_id;

		   -- add AS_LEADS_LOG.customer_id and AS_LEADS_LOG.close_competitor_id
		   -- add AS_SALES_CREDITS_DENORM.close_competitor_id

		   l_col_name := 'AS_LEADS_LOG.customer_id';

	   	   UPDATE AS_LEADS_LOG
		   set object_version_number =  nvl(object_version_number,0) + 1, customer_id = p_to_fk_id
			  --last_update_date = hz_utility_pub.last_update_date,
			  --last_updated_by = hz_utility_pub.user_id,
			  --last_update_login = hz_utility_pub.last_update_login
			  --request_id = hz_utility_pub.request_id,
			  --program_application_id = hz_utility_pub.program_application_id,
			  --program_id = hz_utility_pub.program_id,
			  --program_update_date = sysdate
		   where customer_id = p_from_fk_id;

		   l_col_name := 'AS_LEADS_LOG.close_competitor_id';

	   	   UPDATE AS_LEADS_LOG
		   set object_version_number =  nvl(object_version_number,0) + 1, close_competitor_id = p_to_fk_id
			  --last_update_date = hz_utility_pub.last_update_date,
			  --last_updated_by = hz_utility_pub.user_id,
			  --last_update_login = hz_utility_pub.last_update_login,
			  --request_id = hz_utility_pub.request_id,
			  --program_application_id = hz_utility_pub.program_application_id,
			  --program_id = hz_utility_pub.program_id,
			  --program_update_date = sysdate
		   where close_competitor_id = p_from_fk_id;

 		   l_col_name := 'AS_SALES_CREDITS_DENORM.close_competitor_id';

		   UPDATE AS_SALES_CREDITS_DENORM
		   set object_version_number =  nvl(object_version_number,0) + 1, close_competitor_id = p_to_fk_id,
			  last_update_date = hz_utility_pub.last_update_date,
			  last_updated_by = hz_utility_pub.user_id,
			  last_update_login = hz_utility_pub.last_update_login,
			  request_id = hz_utility_pub.request_id,
			  program_application_id = hz_utility_pub.program_application_id,
			  program_id = hz_utility_pub.program_id,
			  program_update_date = sysdate
		   where close_competitor_id = p_from_fk_id;


	     ELSIF p_parent_entity_name = 'HZ_PARTY_SITES' THEN

		   l_col_name := 'AS_LEADS_ALL.address_id';

		   UPDATE AS_LEADS_ALL
		   set object_version_number =  nvl(object_version_number,0) + 1, address_id = p_to_fk_id,
			  last_update_date = hz_utility_pub.last_update_date,
			  last_updated_by = hz_utility_pub.user_id,
			  last_update_login = hz_utility_pub.last_update_login,
			  request_id = hz_utility_pub.request_id,
			  program_application_id = hz_utility_pub.program_application_id,
			  program_id = hz_utility_pub.program_id,
			  program_update_date = sysdate
		   where address_id = p_from_fk_id;

/*
		   l_col_name := 'AS_LEADS_ALL.end_user_address_id';

		   UPDATE AS_LEADS_ALL
		   set object_version_number =  nvl(object_version_number,0) + 1, end_user_address_id = p_to_fk_id,
			  last_update_date = hz_utility_pub.last_update_date,
			  last_updated_by = hz_utility_pub.user_id,
			  last_update_login = hz_utility_pub.last_update_login,
			  request_id = hz_utility_pub.request_id,
			  program_application_id = hz_utility_pub.program_application_id,
			  program_id = hz_utility_pub.program_id,
			  program_update_date = sysdate
		   where end_user_address_id = p_from_fk_id;
*/

 		   l_col_name := 'AS_LEAD_CONTACTS_ALL.address_id';

		   UPDATE AS_LEAD_CONTACTS_ALL
		   set object_version_number =  nvl(object_version_number,0) + 1, address_id = p_to_fk_id,
			  last_update_date = hz_utility_pub.last_update_date,
			  last_updated_by = hz_utility_pub.user_id,
			  last_update_login = hz_utility_pub.last_update_login,
			  request_id = hz_utility_pub.request_id,
			  program_application_id = hz_utility_pub.program_application_id,
			  program_id = hz_utility_pub.program_id,
			  program_update_date = sysdate
		   where address_id = p_from_fk_id;

 		   l_col_name := 'AS_SALES_CREDITS.partner_address_id';

		   UPDATE AS_SALES_CREDITS
		   set object_version_number =  nvl(object_version_number,0) + 1, partner_address_id = p_to_fk_id,
			  last_update_date = hz_utility_pub.last_update_date,
			  last_updated_by = hz_utility_pub.user_id,
			  last_update_login = hz_utility_pub.last_update_login,
			  request_id = hz_utility_pub.request_id,
			  program_application_id = hz_utility_pub.program_application_id,
			  program_id = hz_utility_pub.program_id,
			  program_update_date = sysdate
		   where partner_address_id = p_from_fk_id;

 		   l_col_name := 'AS_SALES_CREDITS_DENORM.partner_address_id';

		   UPDATE AS_SALES_CREDITS_DENORM
		   set object_version_number =  nvl(object_version_number,0) + 1, partner_address_id = p_to_fk_id,
			  last_update_date = hz_utility_pub.last_update_date,
			  last_updated_by = hz_utility_pub.user_id,
			  last_update_login = hz_utility_pub.last_update_login,
			  request_id = hz_utility_pub.request_id,
			  program_application_id = hz_utility_pub.program_application_id,
			  program_id = hz_utility_pub.program_id,
			  program_update_date = sysdate
		   where partner_address_id = p_from_fk_id;

		   l_col_name := 'AS_SALES_CREDITS_DENORM.address_id';

		   UPDATE AS_SALES_CREDITS_DENORM
		   set object_version_number =  nvl(object_version_number,0) + 1, address_id = p_to_fk_id,
			  last_update_date = hz_utility_pub.last_update_date,
			  last_updated_by = hz_utility_pub.user_id,
			  last_update_login = hz_utility_pub.last_update_login,
			  request_id = hz_utility_pub.request_id,
			  program_application_id = hz_utility_pub.program_application_id,
			  program_id = hz_utility_pub.program_id,
			  program_update_date = sysdate
		   where address_id = p_from_fk_id;

		   -- add AS_LEADS_LOG.address_id

		   l_col_name := 'AS_LEADS_LOG.address_id';

		   UPDATE AS_LEADS_LOG
		   set object_version_number =  nvl(object_version_number,0) + 1, address_id = p_to_fk_id
			  --last_update_date = hz_utility_pub.last_update_date,
			  --last_updated_by = hz_utility_pub.user_id,
			  --last_update_login = hz_utility_pub.last_update_login,
			  --request_id = hz_utility_pub.request_id,
			  --program_application_id = hz_utility_pub.program_application_id,
			  --program_id = hz_utility_pub.program_id,
			  --program_update_date = sysdate
		   where address_id = p_from_fk_id;

	     ELSIF p_parent_entity_name = 'HZ_ORG_CONTACTS' THEN


		   l_col_name := 'AS_LEAD_CONTACTS_ALL.contact_id';

		   UPDATE AS_LEAD_CONTACTS_ALL
		   set object_version_number =  nvl(object_version_number,0) + 1, contact_id = p_to_fk_id,
			  last_update_date = hz_utility_pub.last_update_date,
			  last_updated_by = hz_utility_pub.user_id,
			  last_update_login = hz_utility_pub.last_update_login,
			  request_id = hz_utility_pub.request_id,
			  program_application_id = hz_utility_pub.program_application_id,
			  program_id = hz_utility_pub.program_id,
			  program_update_date = sysdate
		   where contact_id = p_from_fk_id;

	     ELSIF p_parent_entity_name = 'HZ_CONTACT_POINTS' THEN

		   l_col_name := 'AS_LEAD_CONTACTS_ALL.phone_id';

		   UPDATE AS_LEAD_CONTACTS_ALL
		   set object_version_number =  nvl(object_version_number,0) + 1, phone_id = p_to_fk_id,
			  last_update_date = hz_utility_pub.last_update_date,
			  last_updated_by = hz_utility_pub.user_id,
			  last_update_login = hz_utility_pub.last_update_login,
			  request_id = hz_utility_pub.request_id,
			  program_application_id = hz_utility_pub.program_application_id,
			  program_id = hz_utility_pub.program_id,
			  program_update_date = sysdate
		   where phone_id = p_from_fk_id;


	     END IF;
       EXCEPTION
          WHEN OTHERS THEN
             arp_message.set_line(g_api_name || ': ' || l_col_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'AS_OPP_MERGE_PKG.OPP_MERGE end : ' ||
				to_char(sysdate,'DD-MON-YYYY HH24:MI'));

END OPP_MERGE;

END AS_OPP_MERGE_PKG;

/
