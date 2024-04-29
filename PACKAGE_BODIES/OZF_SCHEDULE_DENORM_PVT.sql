--------------------------------------------------------
--  DDL for Package Body OZF_SCHEDULE_DENORM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_SCHEDULE_DENORM_PVT" AS
/* $Header: ozfvscdb.pls 120.1 2006/04/12 10:46:20 gramanat noship $ */

g_pkg_name   CONSTANT VARCHAR2(30):='OZF_SCHEDULE_DENORM_PVT';


PROCEDURE initial_load(l_org_id IN NUMBER )
IS

  CURSOR c_items_hl_denorm IS
  SELECT activity_hl_id, schedule_id,item, item_type
    FROM ozf_activity_hl_denorm
   WHERE item is not null;


  CURSOR c_activity_person IS
  SELECT distinct am.campaign_id,
                  ct.campaign_name,
				  am.campaign_class,
				  am.campaign_status,
				  am.campaign_type,
                  am.confidential_flag,
                  s.schedule_id,
		   		  'CSCH' object_class,
		 		  s.schedule_name,
				  s.status_code,
				  s.source_code,
				  s.start_date_time,
				  s.end_date_time,
                  s.owner_user_id,
				  s.activity_type_code,
                  s.activity_id,
				  s.marketing_medium_id,
				  am.custom_setup_id,
				  ps.party_id,
                  cs.cust_account_id,
				  cs.cust_acct_site_id,
				  cu.site_use_id,
				  cu.site_use_code,
                  decode(cu.site_use_code,'BILL_TO','QUALIFIER_ATTRIBUTE14','SHIP_TO','QUALIFIER_ATTRIBUTE11') qualifier_attribute,
                  'CUSTOMER' qualifier_context,
                  nvl(am.item_type,'ALLPRODUCTS') prod_indicator
    FROM   ams_campaign_schedules_vl s,
                   ozf_activity_hl_denorm am,
                   ams_campaigns_vl ct,
                   ams_list_entries le,
                   hz_parties b, hz_party_sites ps,hz_locations f,
                   hz_cust_acct_sites_all cs,hz_cust_site_uses_all cu,hz_locations hl, hz_party_sites hp
   WHERE
              s.schedule_id = am.schedule_id and
              ct.campaign_id = s.campaign_id and
              am.list_header_id is not null and
              le.list_header_id = am.list_header_id and
              le.party_id = b.party_id
              and b.party_type = 'PERSON'
              and ps.party_id = b.party_id
              and ps.identifying_address_flag = 'Y'
              and f.location_id = ps.location_id
              and hl.city = f.city
              and hl.state = f.state
              and hl.postal_code = f.postal_code
              and hl.country = f.country
              and hp.location_id = hl.location_id
              and hp.party_site_id = cs.party_site_id
              and cu.cust_acct_site_id = cs.cust_acct_site_id
              and cu.site_use_code in ('SHIP_TO','BILL_TO');

  CURSOR c_activity_relationship IS
  SELECT distinct am.campaign_id,
                  ct.campaign_name,
				  am.campaign_class,
				  am.campaign_status,
				  am.campaign_type,
                  am.confidential_flag,
                  s.schedule_id,
				  'CSCH' object_class,
				  s.schedule_name,
				  s.status_code,
				  s.source_code,
				  s.start_date_time,
				  s.end_date_time,
                  s.owner_user_id,
				  s.activity_type_code,
				  s.activity_id,
				  s.marketing_medium_id,
				  am.custom_setup_id,
				  hr.subject_id party_id,
                  cs.cust_account_id,
				  cs.cust_acct_site_id,
				  cu.site_use_id,
				  cu.site_use_code,
                  decode(cu.site_use_code,'BILL_TO','QUALIFIER_ATTRIBUTE14','SHIP_TO','QUALIFIER_ATTRIBUTE11') qualifier_attribute,
                  'CUSTOMER' qualifier_context,
                  nvl(am.item_type,'ALLPRODUCTS') prod_indicator
            FROM   ozf_activity_hl_denorm am,
                   ams_campaign_schedules_vl s,
                   ams_campaigns_vl ct,
                   ams_list_entries le,
                   hz_parties b, hz_cust_accounts ca,
                   hz_cust_acct_sites_all cs,hz_cust_site_uses_all cu, hz_relationships hr
            WHERE
              s.schedule_id = am.schedule_id
              and ct.campaign_id = s.campaign_id
              and am.list_header_id is not null
              and le.list_header_id = am.list_header_id
              and le.party_id = b.party_id
              and b.party_type = 'PARTY_RELATIONSHIP'
              and hr.party_id = b.party_id
              and hr.subject_type = 'ORGANIZATION'
              and ca.party_id = hr.subject_id
              and cs.cust_account_id = ca.cust_account_id
              and cu.cust_acct_site_id = cs.cust_acct_site_id
              and cu.site_use_code in ('SHIP_TO','BILL_TO');

  CURSOR c_activity_organization IS
          SELECT distinct am.campaign_id,
		         ct.campaign_name,
				 am.campaign_class,
				 am.campaign_status,
				 am.campaign_type,
                 am.confidential_flag,
                 s.schedule_id,
				 'CSCH' object_class,
				 s.schedule_name,
				 s.status_code,
				 s.source_code,
				 s.start_date_time,
				 s.end_date_time,
                 s.owner_user_id,
				 s.activity_type_code,
				 s.activity_id,
				 s.marketing_medium_id,
				 am.custom_setup_id,
				 b.party_id,
                 cs.cust_account_id,
				 cs.cust_acct_site_id,
				 cu.site_use_id,
				 cu.site_use_code,
                 decode(cu.site_use_code,'BILL_TO','QUALIFIER_ATTRIBUTE14','SHIP_TO','QUALIFIER_ATTRIBUTE11') qualifier_attribute,
                 'CUSTOMER' qualifier_context,
                 nvl(am.item_type,'ALLPRODUCTS') prod_indicator
            FROM   ozf_activity_hl_denorm am,
                   ams_campaign_schedules_vl s,
                   ams_campaigns_vl ct,
                   ams_list_entries le,
                   hz_parties b, hz_cust_accounts ca,
                   hz_cust_acct_sites_all cs,hz_cust_site_uses_all cu
            WHERE
              am.schedule_id = s.schedule_id
              and ct.campaign_id = s.campaign_id
              and le.list_header_id = am.list_header_id
              and le.party_id = b.party_id
              and b.party_type = 'ORGANIZATION'
              and ca.party_id = b.party_id
              and cs.cust_account_id = ca.cust_account_id
              and cu.cust_acct_site_id = cs.cust_acct_site_id
              and cu.site_use_code in ('SHIP_TO','BILL_TO');

  CURSOR c_all_campaigns IS
         SELECT c.campaign_id, c.status_code, c.rollup_type, c.campaign_type,
                c.campaign_name,c.private_flag
           FROM
                ams_campaigns_vl c
          WHERE
                c.status_code in ('ACTIVE', 'AVAILABLE', 'COMPLETED', 'PENDINGAPPROVAL');


  CURSOR c_activity_product_family IS
         SELECT distinct am.campaign_id, ct.campaign_name, am.campaign_class, am.campaign_status, am.campaign_type,am.confidential_flag,
                s.schedule_id, 'CSCH' object_class,s.schedule_name,s.status_code,s.source_code, s.start_date_time, s.end_date_time,
                s.owner_user_id, am.item,
                decode(am.item_type,'PRODUCT','PRICING_ATTRIBUTE1','FAMILY','PRICING_ATTRIBUTE2','') item_type,
				s.activity_type_code, s.activity_id, s.marketing_medium_id,am.custom_setup_id,
                decode(am.list_header_id,null,'ALLCUSTOMERS','CUSTOMERS') cust_indicator
            FROM
             ozf_activity_hl_denorm am,
             ams_campaign_schedules_vl s,
             ams_campaigns_vl ct
           WHERE
             am.schedule_id = s.schedule_id
             and ct.campaign_id = s.campaign_id;

  CURSOR c_activity_products IS
         SELECT am.campaign_id, ct.campaign_name, am.campaign_class, am.campaign_status, am.campaign_type,am.confidential_flag,
                s.schedule_id, 'CSCH' object_class,s.schedule_name,s.status_code, s.source_code, s.start_date_time, s.end_date_time,
                s.owner_user_id, mtl.inventory_item_id item, 'PRICING_ATTRIBUTE1' item_type,
                s.activity_type_code, s.activity_id, s.marketing_medium_id,am.custom_setup_id,
                decode(am.list_header_id,null,'ALLCUSTOMERS','CUSTOMERS') cust_indicator
           FROM
             ozf_activity_hl_denorm am,
             ams_campaign_schedules_vl s,
             ams_campaigns_vl ct,
             ams_act_products ap,
             mtl_item_categories mtl,
             eni_prod_denorm_hrchy_v eni
           WHERE
             am.schedule_id                 = s.schedule_id
             and ct.campaign_id             = s.campaign_id
             and ap.act_product_used_by_id  = s.schedule_id
             and ap.arc_act_product_used_by = 'CSCH'
             and ap.level_type_code         = 'FAMILY'
             and mtl.category_set_id        = eni.category_set_id
             and mtl.category_id            = eni.child_id
             and eni.parent_id              = ap.category_id
             and mtl.organization_id        = l_org_id;

BEGIN

      ozf_utility_pvt.write_conc_log('-- Initial Load Start -- '|| to_char(sysdate,'dd-mon-yyyy-hh:mi:ss'));
      ozf_utility_pvt.write_conc_log('-- Insert into HLD -- ');

      /* Drop all the indexes in ozf_activity_hl_denorm */

      /* Recreate all the indexes on ozf_activity_hl_denorm */
      FOR i IN c_all_campaigns LOOP
             INSERT into ozf_activity_hl_denorm
                   (Activity_hl_id,Schedule_Id,Campaign_id,Campaign_status,Campaign_class,
                    Campaign_type,Campaign_name,Confidential_flag,Item,Item_type,List_header_id,Custom_setup_id,
                    Last_Update_date,Last_updated_by,Creation_date,Created_by,last_update_login)
             SELECT ozf_activity_hl_denorm_s.nextval, s.schedule_id, i.campaign_id, i.status_code,
                    i.rollup_type, i.campaign_type, i.campaign_name,i.private_flag,
                    decode(ap.inventory_item_id, null, ap.category_id,ap.inventory_item_id) item,
                    ap.level_type_code item_type, al.list_header_id,s.custom_setup_id,
                    sysdate,FND_GLOBAL.user_id,sysdate,FND_GLOBAL.user_id,FND_GLOBAL.conc_login_id
               FROM
                    ams_campaign_schedules_b s,
                    ams_act_products ap,
                    ams_act_lists al
              WHERE
                    s.campaign_id = i.campaign_id AND
                    ap.act_product_used_by_id(+) = s.schedule_id  AND
                    ap.arc_act_product_used_by(+) = 'CSCH' and
                    al.list_act_type(+) = 'TARGET' AND  al.list_used_by(+) = 'CSCH' AND
                    al.list_used_by_id(+) = s.schedule_id;
       END LOOP;

       ozf_utility_pvt.write_conc_log('-- Insert into Activity Customers 1 --'|| to_char(sysdate,'dd-mon-yyyy-hh:mi:ss'));

       FOR i IN c_activity_person LOOP
             INSERT into ozf_activity_customers (activity_customer_id,parent_id, parent_desc, parent_class,
               parent_status, parent_type, confidential_flag,object_id,object_class, object_desc,object_status,source_code,
               start_date, end_date, owner_id, activity_type_code,activity_id, marketing_medium_id,custom_setup_id,
               party_id, cust_account_id,cust_acct_site_id,site_use_id,site_use_code,
               qualifier_attribute,qualifier_context,prod_indicator,
               Last_Update_date,Last_updated_by,Creation_date,Created_by,last_update_login)
        values(ozf_activity_customers_s.nextval,
               i.campaign_id,
               i.campaign_name,
               i.campaign_class,
               i.campaign_status,
               i.campaign_type,
               i.confidential_flag,
               i.schedule_id,
               i.object_class,
               i.schedule_name,
               i.status_code,
               i.source_code,
               i.start_date_time,
               i.end_date_time,
               i.owner_user_id,
               i.activity_type_code,
               i.activity_id,
               i.marketing_medium_id,
               i.custom_setup_id,
               i.party_id,i.cust_account_id,i.cust_acct_site_id,i.site_use_id,i.site_use_code,
               i.qualifier_attribute,i.qualifier_context, i.prod_indicator,
               sysdate,FND_GLOBAL.user_id,sysdate,FND_GLOBAL.user_id,FND_GLOBAL.conc_login_id);
       END LOOP;


       ozf_utility_pvt.write_conc_log('-- Insert into Activity Customers 2 --'|| to_char(sysdate,'dd-mon-yyyy-hh:mi:ss'));

       FOR i IN c_activity_relationship LOOP
       INSERT into ozf_activity_customers (activity_customer_id,parent_id, parent_desc, parent_class,
               parent_status, parent_type,confidential_flag, object_id,object_class, object_desc,object_status,source_code,
               start_date, end_date, owner_id, activity_type_code,activity_id, marketing_medium_id,custom_setup_id,
               party_id, cust_account_id,cust_acct_site_id,site_use_id,site_use_code,
               qualifier_attribute,qualifier_context,prod_indicator,
               Last_Update_date,Last_updated_by,Creation_date,Created_by,last_update_login)
        values(ozf_activity_customers_s.nextval,
               i.campaign_id, i.campaign_name,i.campaign_class, i.campaign_status, i.campaign_type,i.confidential_flag,
               i.schedule_id,i.object_class,i.schedule_name,i.status_code,i.source_code,i.start_date_time,i.end_date_time,
               i.owner_user_id, i.activity_type_code,i.activity_id,i.marketing_medium_id,i.custom_setup_id,
               i.party_id,i.cust_account_id,i.cust_acct_site_id,i.site_use_id,i.site_use_code,
               i.qualifier_attribute,i.qualifier_context, i.prod_indicator,
           	sysdate,FND_GLOBAL.user_id,sysdate,FND_GLOBAL.user_id,FND_GLOBAL.conc_login_id);
       END LOOP;


       ozf_utility_pvt.write_conc_log('-- Insert into Activity Customers 3 --'|| to_char(sysdate,'dd-mon-yyyy-hh:mi:ss'));

       FOR i IN c_activity_organization LOOP
       INSERT into ozf_activity_customers (activity_customer_id,parent_id, parent_desc, parent_class,
               parent_status, parent_type,confidential_flag, object_id,object_class, object_desc,object_status,source_code,
               start_date, end_date, owner_id, activity_type_code,activity_id, marketing_medium_id,custom_setup_id,
               party_id, cust_account_id,cust_acct_site_id,site_use_id,site_use_code,
               qualifier_attribute,qualifier_context,prod_indicator,
               Last_Update_date,Last_updated_by,Creation_date,Created_by,last_update_login)
        values(ozf_activity_customers_s.nextval,
         i.campaign_id, i.campaign_name,i.campaign_class, i.campaign_status, i.campaign_type,i.confidential_flag,
         i.schedule_id,i.object_class,i.schedule_name,i.status_code,i.source_code,i.start_date_time,i.end_date_time,
         i.owner_user_id, i.activity_type_code,i.activity_id,i.marketing_medium_id,i.custom_setup_id,
         i.party_id,i.cust_account_id,i.cust_acct_site_id,i.site_use_id,i.site_use_code,
         i.qualifier_attribute,i.qualifier_context, i.prod_indicator,
         sysdate,FND_GLOBAL.user_id,sysdate,FND_GLOBAL.user_id,FND_GLOBAL.conc_login_id);
       END LOOP;


       ozf_utility_pvt.write_conc_log('-- Insert into Activity Products  1 --'|| to_char(sysdate,'dd-mon-yyyy-hh:mi:ss'));

       FOR i in c_activity_product_family LOOP
	   INSERT into ozf_activity_products (activity_product_id,parent_id, parent_desc, parent_class,
               parent_status, parent_type, confidential_flag,object_id,object_class, object_desc,object_status,source_code,
             start_date, end_date, owner_id,item,item_type, activity_type_code,activity_id, marketing_medium_id,custom_setup_id,
               cust_indicator,Last_Update_date,Last_updated_by,Creation_date,Created_by,last_update_login)
       values (ozf_activity_products_s.nextval,i.campaign_id, i.campaign_name, i.campaign_class, i.campaign_status, i.campaign_type,i.confidential_flag,
                i.schedule_id, i.object_class,i.schedule_name,i.status_code,i.source_code, i.start_date_time, i.end_date_time,
                i.owner_user_id, i.item, i.item_type,
				i.activity_type_code, i.activity_id, i.marketing_medium_id,i.custom_setup_id,i.cust_indicator,
					 sysdate,FND_GLOBAL.user_id,sysdate,FND_GLOBAL.user_id,FND_GLOBAL.conc_login_id);
       END LOOP;

       ozf_utility_pvt.write_conc_log('-- Insert into Activity Products  2 --'|| to_char(sysdate,'dd-mon-yyyy-hh:mi:ss'));

	   FOR i in c_activity_products LOOP
       INSERT into ozf_activity_products (activity_product_id,parent_id, parent_desc, parent_class,
               parent_status, parent_type,confidential_flag, object_id,object_class, object_desc,object_status,source_code,
             start_date, end_date, owner_id,item,item_type, activity_type_code,activity_id, marketing_medium_id,custom_setup_id,
               cust_indicator,Last_Update_date,Last_updated_by,Creation_date,Created_by,last_update_login)
       values (ozf_activity_products_s.nextval,i.campaign_id, i.campaign_name, i.campaign_class, i.campaign_status, i.campaign_type,i.confidential_flag,
                i.schedule_id, i.object_class,i.schedule_name,i.status_code,i.source_code, i.start_date_time, i.end_date_time,
                i.owner_user_id, i.item, i.item_type,
				i.activity_type_code, i.activity_id, i.marketing_medium_id,i.custom_setup_id,i.cust_indicator,
					 sysdate,FND_GLOBAL.user_id,sysdate,FND_GLOBAL.user_id,FND_GLOBAL.conc_login_id);
       END LOOP;


       ozf_utility_pvt.write_conc_log('-- Initial Load End  --');

END;

PROCEDURE refresh_schedules(
  ERRBUF           OUT NOCOPY VARCHAR2,
  RETCODE          OUT NOCOPY VARCHAR2,
  x_return_status  OUT NOCOPY VARCHAR2,
  p_increment_flag IN  VARCHAR2 := 'N',
  p_latest_comp_date IN DATE
)
IS


  CURSOR c_new_items_hl_denorm(l_latest_comp_date DATE) IS
  SELECT activity_hl_id
    FROM ozf_activity_hl_denorm a, ams_act_products b
   WHERE a.schedule_id = b.act_product_used_by_id
     AND b.arc_act_product_used_by = 'CSCH'
     AND b.creation_date > l_latest_comp_date;

  CURSOR c_items_hl_denorm IS
  SELECT activity_hl_id, schedule_id,item, item_type
    FROM ozf_activity_hl_denorm
   WHERE item is not null;

  CURSOR c_new_schedules_cust(l_latest_comp_date DATE) IS
  SELECT DISTINCT am.Schedule_Id,am.Campaign_id,am.Campaign_status,am.Campaign_class,am.Campaign_type,
                  am.Campaign_name,am.List_header_id,am.confidential_flag,am.item, am.item_type, b.party_id, b.party_type
      FROM ozf_activity_hl_denorm am, ams_list_entries le, hz_parties b
     WHERE am.schedule_update_date > l_latest_comp_date
       AND am.list_header_id is not null
       AND le.list_header_id = am.list_header_id
       AND le.party_id = b.party_id;

  CURSOR c_new_schedules_prod(l_latest_comp_date DATE) IS
  SELECT DISTINCT am.Schedule_Id,am.Campaign_id,am.Campaign_status,am.Campaign_class,am.Campaign_type,
                  am.Campaign_name,am.list_header_id,am.confidential_flag, am.item, am.item_type
      FROM ozf_activity_hl_denorm am
     WHERE am.schedule_update_date > l_latest_comp_date
       AND am.item is not null;

  CURSOR c_changed_list_headers(l_latest_comp_date DATE) IS
  SELECT DISTINCT a.schedule_id
    FROM ozf_activity_hl_denorm a,ams_list_headers_all lh
   WHERE a.list_header_id is not null
     AND lh.list_header_id = a.list_header_id
     AND lh.last_update_date > l_latest_comp_date;

  CURSOR c_product_exists(l_item_id NUMBER, l_schedule_id NUMBER) IS
  SELECT 'Y'
    FROM DUAL
  WHERE EXISTS (
                SELECT 1
                  FROM ams_act_products
                 WHERE inventory_item_id = l_item_id
                   AND act_product_used_by_id  = l_schedule_id
                   AND arc_act_product_used_by = 'CSCH'
                   AND level_type_code = 'PRODUCT'
               );

  CURSOR c_category_exists(l_category_id NUMBER, l_schedule_id NUMBER) IS
  SELECT 'Y'
    FROM DUAL
  WHERE EXISTS (
                SELECT 1
                  FROM ams_act_products
                 WHERE category_id = l_category_id
                   AND act_product_used_by_id  = l_schedule_id
                   AND arc_act_product_used_by = 'CSCH'
                   AND level_type_code = 'FAMILY'
               );


  /* product_update_date is update when a new product is added during the incremental refresh */
  CURSOR c_activity_incr_products(l_latest_comp_date DATE) IS
  SELECT distinct a.parent_id, a.parent_desc, a.parent_class,
               a.parent_status, a.parent_type,b.confidential_flag, a.object_id, a.object_type,a.object_status,a.object_class,
               a.source_code, a.start_date, a.end_date, a.owner_id, b.item, b.item_type, a.activity_type_code,
               a.activity_id, a.marketing_medium_id, a.cust_indicator
          FROM ozf_activity_products a,ozf_activity_hl_denorm b
         WHERE a.object_id = b.schedule_id
           and a.object_class      = 'CSCH'
           and b.product_update_date > l_latest_comp_date;


  /* Get the newly added Categories exploded into products */
  CURSOR c_activity_incr_categories(l_latest_comp_date DATE,l_org_id NUMBER) IS
  SELECT distinct a.parent_id, a.parent_desc, a.parent_class,
               a.parent_status, a.parent_type,b.confidential_flag, a.object_id, a.object_type,a.object_status,a.object_class,
               a.source_code,a.start_date,a.end_date,a.owner_id,mtl.inventory_item_id item,'PRODUCT' item_type, a.activity_type_code,
               a.activity_id, a.marketing_medium_id, a.cust_indicator
          FROM ozf_activity_products a,
               ozf_activity_hl_denorm b,
               mtl_item_categories mtl,
               eni_prod_denorm_hrchy_v eni
         WHERE b.product_update_date > l_latest_comp_date
           and b.item_type         = 'FAMILY'
           and a.object_id         = b.schedule_id
           and a.object_class      = 'CSCH'
           and eni.parent_id       = b.item
           and mtl.category_set_id = eni.category_set_id
           and mtl.category_id     = eni.child_id
           and mtl.organization_id = l_org_id;


    CURSOR c_activity_incr_person( l_schedule_id NUMBER,l_party_id NUMBER,l_item_type VARCHAR) IS
           SELECT distinct s.campaign_id, ct.campaign_name, ct.rollup_type, ct.status_code parent_status,
                  ct.campaign_type,ct.private_flag, s.schedule_id, 'CSCH' object_class, s.schedule_name, s.status_code,s.source_code,
                  s.start_date_time, s.end_date_time, s.owner_user_id, s.activity_type_code,
                  s.activity_id, s.marketing_medium_id, ps.party_id,cs.cust_account_id,
                  cs.cust_acct_site_id, cu.site_use_id,cu.site_use_code,nvl(l_item_type,'ALLPRODUCTS') prod_indicator
             FROM   ams_campaign_schedules_vl s,
                    ams_campaigns_vl ct,
                    hz_party_sites ps,hz_locations f,
                    hz_cust_acct_sites_all cs,hz_cust_site_uses_all cu,hz_locations hl, hz_party_sites hp
             WHERE
               s.schedule_id = l_schedule_id
               and ct.campaign_id = s.campaign_id
               and ps.party_id = l_party_id
               and ps.identifying_address_flag = 'Y'
               and f.location_id = ps.location_id
               and hl.city = f.city
               and hl.state = f.state
               and hl.postal_code = f.postal_code
               and hl.country = f.country
               and hp.location_id = hl.location_id
               and hp.party_site_id = cs.party_site_id
               and cu.cust_acct_site_id = cs.cust_acct_site_id
               and cu.site_use_code in ('SHIP_TO','BILL_TO');

	CURSOR c_activity_incr_relationship( l_schedule_id NUMBER,l_party_id NUMBER,l_item_type VARCHAR) IS
           SELECT distinct s.campaign_id, ct.campaign_name, ct.rollup_type, ct.status_code parent_status,
                  ct.campaign_type,ct.private_flag, s.schedule_id, 'CSCH' object_class, s.schedule_name,s.status_code, s.source_code,
                  s.start_date_time, s.end_date_time, s.owner_user_id, s.activity_type_code,
                  s.activity_id, s.marketing_medium_id, hr.subject_id party_id, cs.cust_account_id,
                  cs.cust_acct_site_id, cu.site_use_id,cu.site_use_code,nvl(l_item_type,'ALLPRODUCTS') prod_indicator
             FROM   ams_campaign_schedules_vl s,
                    ams_campaigns_vl ct,
                    hz_cust_accounts ca,
                    hz_cust_acct_sites_all cs,hz_cust_site_uses_all cu, hz_relationships hr
             WHERE
               s.schedule_id = l_schedule_id
               and ct.campaign_id = s.campaign_id
               and hr.party_id = l_party_id
               and hr.subject_type = 'ORGANIZATION'
               and ca.party_id = hr.subject_id
               and cs.cust_account_id = ca.cust_account_id
               and cu.cust_acct_site_id = cs.cust_acct_site_id
               and cu.site_use_code in ('SHIP_TO','BILL_TO');

	CURSOR c_activity_incr_organization( l_schedule_id NUMBER,l_party_id NUMBER,l_item_type VARCHAR) IS
           SELECT distinct s.campaign_id, ct.campaign_name, ct.rollup_type, ct.status_code parent_status,
                  ct.campaign_type,ct.private_flag, s.schedule_id, 'CSCH' object_class, s.schedule_name,s.status_code, s.source_code,
                  s.start_date_time, s.end_date_time, s.owner_user_id, s.activity_type_code,
                  s.activity_id, s.marketing_medium_id, ca.party_id,cs.cust_account_id,
                  cs.cust_acct_site_id, cu.site_use_id,cu.site_use_code,nvl(l_item_type,'ALLPRODUCTS') prod_indicator
             FROM   ams_campaign_schedules_vl s,
                    ams_campaigns_vl ct,
                    hz_cust_accounts ca,
                    hz_cust_acct_sites_all cs,hz_cust_site_uses_all cu
             WHERE
               s.schedule_id = l_schedule_id
               and ct.campaign_id = s.campaign_id
               and ca.party_id = l_party_id
               and cs.cust_account_id = ca.cust_account_id
               and cu.cust_acct_site_id = cs.cust_acct_site_id
               and cu.site_use_code in ('SHIP_TO','BILL_TO');

       CURSOR c_activity_incr_prod_new(l_schedule_id NUMBER, l_list_header_id NUMBER) IS
           SELECT distinct s.campaign_id, ct.campaign_name, ct.rollup_type, ct.status_code parent_status,
                  ct.campaign_type,ct.private_flag, s.schedule_id, 'CSCH' object_class, s.schedule_name, s.status_code,s.source_code,
                  s.start_date_time, s.end_date_time, s.owner_user_id, s.activity_type_code,
                  s.activity_id, s.marketing_medium_id,
                  decode(ap.inventory_item_id, null, ap.category_id,ap.inventory_item_id) item,
                  ap.level_type_code item_type,
                  decode(l_list_header_id,null,'ALLCUSTOMERS','CUSTOMERS') cust_indicator
             FROM ams_campaign_schedules_vl s,
                  ams_campaigns_vl ct,
                  ams_act_products ap
            WHERE
                  s.schedule_id = l_schedule_id AND
                  ct.campaign_id = s.campaign_id and
                  ap.act_product_used_by_id = s.schedule_id  AND
                  ap.arc_act_product_used_by = 'CSCH';

	   CURSOR c_activity_incr_cat_new(l_schedule_id NUMBER,l_org_id NUMBER,l_list_header_id NUMBER) IS
           SELECT distinct s.campaign_id, ct.campaign_name, ct.rollup_type, ct.status_code parent_status,
                  ct.campaign_type,ct.private_flag, s.schedule_id, 'CSCH' object_class, s.schedule_name,s.status_code, s.source_code,
                  s.start_date_time, s.end_date_time, s.owner_user_id, s.activity_type_code,
                  s.activity_id, s.marketing_medium_id,
                  mtl.inventory_item_id item,
                  'PRODUCT' item_type,
                  decode(l_list_header_id,null,'ALLCUSTOMERS','CUSTOMERS') cust_indicator
             FROM ams_campaign_schedules_vl s,
                  ams_campaigns_vl ct,
                  ams_act_products ap,
                  mtl_item_categories mtl,
                  eni_prod_denorm_hrchy_v eni
            WHERE
                  s.schedule_id              = l_schedule_id AND
                  ct.campaign_id             = s.campaign_id AND
                  ap.act_product_used_by_id  = s.schedule_id  AND
                  ap.arc_act_product_used_by = 'CSCH' AND
                  ap.level_type_code         = 'FAMILY' AND
                  mtl.category_set_id        = eni.category_set_id AND
                  mtl.category_id            = eni.child_id AND
                  eni.parent_id              = ap.category_id  AND
                  mtl.organization_id        = l_org_id;

	   CURSOR c_incr_campaigns IS
           SELECT c.campaign_id, c.status_code, c.rollup_type, c.campaign_type, c.campaign_name,c.private_flag
             FROM
                  ams_campaigns_vl c
            WHERE
                  c.status_code in ('ACTIVE', 'AVAILABLE', 'COMPLETED', 'PENDINGAPPROVAL');

  l_api_version       CONSTANT NUMBER       := 1.0;
  l_api_name          CONSTANT VARCHAR2(30) := 'refresh_denorm';
  l_full_name         CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_return_status     VARCHAR2(1);
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);

  l_conc_program_id   NUMBER;
  l_app_id            NUMBER;
  l_latest_comp_date  DATE;
  l_offer_changed     VARCHAR2(1);
  l_qualifier_changed VARCHAR2(1);
  l_dummy             VARCHAR2(1);
  l_index_tablespace  VARCHAR2(100);
  l_increment_flag    VARCHAR2(1);

  l_stmt_denorm       VARCHAR2(32000) := NULL;
  l_stmt_offer        VARCHAR2(32000) := NULL;
  l_stmt_product      VARCHAR2(32000) := NULL;
  l_stmt_hl_denorm    VARCHAR2(32000) := NULL;
  l_product_changed   VARCHAR2(1)     := NULL;
  l_org_id            NUMBER;

  l_denorm_csr        NUMBER;
  l_ignore            NUMBER;


BEGIN
  SAVEPOINT refresh_schedule;

  ERRBUF := NULL;
  RETCODE := '0';

  IF p_increment_flag = 'N' THEN
    l_increment_flag := 'N' ;
  ELSE
    l_increment_flag := 'Y';
  END IF;

  l_org_id := FND_PROFILE.VALUE('QP_ORGANIZATION_ID');
  l_latest_comp_date := p_latest_comp_date;

  ozf_Utility_PVT.debug_message(l_full_name || ': Start Schedule Denorm');
  ozf_utility_pvt.write_conc_log('-- pIncrement Flag is    : ' || p_increment_flag );
  ozf_utility_pvt.write_conc_log('-- lIncrement Flag is    : ' || l_increment_flag );
  ozf_utility_pvt.write_conc_log('-- l_latest_comp_date is: ' || l_latest_comp_date );
  ozf_utility_pvt.write_conc_log('-- l_org_id is          : ' || l_org_id );


  IF NOT FND_API.compatible_api_call(l_api_version,
                                     l_api_version,
                                     l_api_name,
                                     g_pkg_name)
  THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;


  If l_increment_flag = 'N' then
     /* Full Load or Initial Load */
     -- EXECUTE IMMEDIATE 'TRUNCATE TABLE ozf_activity_hl_denorm';

      ozf_utility_pvt.write_conc_log('-- Full Load: Deleting from Temp Tables --');

      --DELETE FROM ozf_activity_products_temp where object_class = 'CSCH'  ;
      --DELETE FROM ozf_activity_customers_temp where object_class = 'CSCH'  ;

      ozf_utility_pvt.write_conc_log('-- Full Load: Deleting from Denorm Tables --');

      delete from ozf_activity_hl_denorm;
      delete from ozf_activity_products where object_class = 'CSCH' ;
      delete from ozf_activity_customers where object_class = 'CSCH' ;

      initial_load(l_org_id);
  else

     /* Incremental Refresh */

     ozf_utility_pvt.write_conc_log('-- Incremental Load Start  --'|| '-'||to_char(sysdate,'dd-mon-yyy-hh:mi:ss'));

     FOR i IN c_items_hl_denorm LOOP

       l_product_changed := null;
       if (i.item_type = 'PRODUCT') THEN
          OPEN c_product_exists(i.item, i.schedule_id);
          FETCH c_product_exists INTO l_product_changed;
          CLOSE c_product_exists;
       elsif (i.item_type = 'FAMILY') then
          OPEN c_category_exists(i.item, i.schedule_id);
          FETCH c_category_exists INTO l_product_changed;
          CLOSE c_category_exists;
       end if;

      ozf_utility_pvt.write_conc_log('-- l_product_changed is : ' || l_product_changed || '-'||to_char(sysdate,'dd-mon-yyy-hh:mi:ss'));

       IF l_product_changed IS NULL THEN
          -- product has been deleted

          ozf_utility_pvt.write_conc_log('-- Deleting product from denorm : '|| i.item_type
                                                                             || ' - '
                                                                             || i.item );

          DELETE from ozf_activity_hl_denorm where activity_hl_id = i.activity_hl_id;

          if (i.item_type = 'PRODUCT') then

             DELETE from ozf_activity_products
              WHERE item = i.item
                AND object_id = i.schedule_id
                AND object_class = 'CSCH';

          elsif (i.item_type = 'FAMILY') then

             DELETE from ozf_activity_products
              WHERE object_id = i.schedule_id
                AND object_class = 'CSCH'
                AND items_category = i.item;

          end if;

       end if;

     END LOOP;

    ozf_utility_pvt.write_conc_log('-- Adding the new products to ozf_activity_hl_denorm table -- '|| '-'||to_char(sysdate,'dd-mon-yyy-hh:mi:ss'));

    INSERT into ozf_activity_hl_denorm
                (Activity_hl_id,Schedule_Id,Campaign_id,Campaign_status,Campaign_class,
                 Campaign_type,Campaign_name,confidential_flag,Item,Item_type,List_header_id,
                 Last_Update_date,Last_updated_by,Creation_date,Created_by,last_update_login,product_update_date)
           SELECT ozf_activity_hl_denorm_s.nextval, Schedule_Id, Campaign_id, Campaign_status, Campaign_class, Campaign_type,
                  Campaign_name, confidential_flag,Item, Item_type, List_header_id,sysdate,null,sysdate,null,null,sysdate
             FROM ozf_activity_hl_denorm a, ams_act_products b
            WHERE a.schedule_id = b.act_product_used_by_id
              AND b.arc_act_product_used_by = 'CSCH'
              AND b.creation_date > l_latest_comp_date;

    ozf_utility_pvt.write_conc_log('-- Adding the new product to the denorm table -- '|| '-'||to_char(sysdate,'dd-mon-yyy-hh:mi:ss'));

    /* product_update_date is update when a new product is added during the incremental refresh */
    FOR i in c_activity_incr_products(l_latest_comp_date) LOOP
    INSERT into ozf_activity_products (activity_product_id,parent_id, parent_desc, parent_class,
               parent_status, parent_type, confidential_flag,object_id,object_type,object_status,object_class, source_code,
               start_date, end_date, owner_id, item, item_type, activity_type_code,
               activity_id, marketing_medium_id, cust_indicator,Last_Update_date,Last_updated_by,Creation_date,Created_by,last_update_login)
     values (ozf_activity_products_s.nextval,i.parent_id, i.parent_desc, i.parent_class,
               i.parent_status, i.parent_type,i.confidential_flag, i.object_id, i.object_type,i.object_status,i.object_class,
               i.source_code, i.start_date, i.end_date, i.owner_id, i.item, i.item_type, i.activity_type_code,
               i.activity_id, i.marketing_medium_id, i.cust_indicator,sysdate,FND_GLOBAL.user_id,sysdate,FND_GLOBAL.user_id,FND_GLOBAL.conc_login_id);
     END LOOP;

    ozf_utility_pvt.write_conc_log('-- Adding category products to the denorm table -- '|| '-'||to_char(sysdate,'dd-mon-yyy-hh:mi:ss'));

    /* Get the newly added Categories exploded into products */

    FOR i in c_activity_incr_categories(l_latest_comp_date,l_org_id) LOOP
    INSERT into ozf_activity_products (activity_product_id,parent_id, parent_desc, parent_class,
               parent_status, parent_type,confidential_flag, object_id,object_type,object_status,object_class, source_code,
               start_date, end_date, owner_id, item, item_type, activity_type_code,
               activity_id, marketing_medium_id, cust_indicator,Last_Update_date,Last_updated_by,Creation_date,Created_by,last_update_login)
     values (ozf_activity_products_s.nextval,i.parent_id, i.parent_desc, i.parent_class,
               i.parent_status, i.parent_type,i.confidential_flag, i.object_id, i.object_type,i.object_status,i.object_class,
               i.source_code, i.start_date, i.end_date, i.owner_id, i.item, i.item_type, i.activity_type_code,
               i.activity_id, i.marketing_medium_id, i.cust_indicator,sysdate,FND_GLOBAL.user_id,sysdate,FND_GLOBAL.user_id,FND_GLOBAL.conc_login_id);
     END LOOP;

    /* Need to look into Campaign Status also */

    ozf_utility_pvt.write_conc_log('-- Update the status in the ozf_activity_hl_denorm table from Campaign Schedules --'|| '-'||to_char(sysdate,'dd-mon-yyy-hh:mi:ss'));
    update ozf_activity_hl_denorm h
        set (h.schedule_status,h.schedule_update_date) =
         (SELECT b.status_code,sysdate
            FROM ams_campaign_schedules_b b
           WHERE b.schedule_id = h.schedule_id
             AND b.last_update_date > l_latest_comp_date
             AND b.creation_date < l_latest_comp_date);

    ozf_utility_pvt.write_conc_log('-- After the update, the status of some schedules may change --'|| '-'||to_char(sysdate,'dd-mon-yyy-hh:mi:ss'));
    ozf_utility_pvt.write_conc_log('-- Delete Cancelled Schedules and its depedants --');

    DELETE from ozf_activity_customers a where EXISTS
                (select b.schedule_id
                   from ozf_activity_hl_denorm b
                  where b.schedule_status in ('CANCELLED','ARCHIVED','ONHOLD')
                    and b.schedule_id = a.object_id and a.object_class = 'CSCH');
    DELETE from ozf_activity_products a where EXISTS
                (select b.schedule_id
                   from ozf_activity_hl_denorm b
                  where b.schedule_status in ('CANCELLED','ARCHIVED','ONHOLD')
                    and b.schedule_id = a.object_id and a.object_class = 'CSCH');
    DELETE from ozf_activity_hl_denorm where schedule_status in ('CANCELLED', 'ARCHIVED', 'ONHOLD');

    /*If the list have been re-regenerated, mark them for to picked up as new schedules and also delete them
      from ozf_activity_customers */

    FOR i in c_changed_list_headers(l_latest_comp_date) LOOP

    ozf_utility_pvt.write_conc_log('-- List changed for schedule : ' || i.schedule_id || '-'||to_char(sysdate,'dd-mon-yyy-hh:mi:ss'));

        UPDATE ozf_activity_hl_denorm
           SET schedule_update_date = sysdate
         WHERE schedule_id = i.schedule_id
           AND list_header_id is not null;

        DELETE from ozf_activity_customers where object_id = i.schedule_id and object_class = 'CSCH';
    END LOOP;

    /* Add new schedules to both the hl_denorm table */
    FOR i in c_incr_campaigns LOOP
           INSERT into ozf_activity_hl_denorm
                (Activity_hl_id,Schedule_Id,Campaign_id,Campaign_status,Campaign_class,
                 Campaign_type,Campaign_name,confidential_flag,Item,Item_type,List_header_id,
                 Last_Update_date,Last_updated_by,Creation_date,Created_by,last_update_login,schedule_update_date)
           SELECT ozf_activity_hl_denorm_s.nextval, s.schedule_id, i.campaign_id, i.status_code,
                  i.rollup_type, i.campaign_type, i.campaign_name,i.private_flag,
                  decode(ap.inventory_item_id, null, ap.category_id,ap.inventory_item_id) item,
                  ap.level_type_code item_type, al.list_header_id,sysdate,null,sysdate,null,null,sysdate
             FROM
                  ams_campaign_schedules_b s,
                  ams_act_products ap,
                  ams_act_lists al
            WHERE
                  s.campaign_id = i.campaign_id AND
                  s.creation_date > l_latest_comp_date and
                  ap.act_product_used_by_id(+) = s.schedule_id  AND
                  ap.arc_act_product_used_by(+) = 'CSCH' and
                  al.list_act_type(+) = 'TARGET' AND  al.list_used_by(+) = 'CSCH' AND
                  al.list_used_by_id(+) = s.schedule_id;
    END LOOP;

    FOR i in c_new_schedules_cust(l_latest_comp_date) LOOP

       ozf_utility_pvt.write_conc_log('-- Denorm parties for new or changed schedule : ' || i.schedule_id|| '-'||to_char(sysdate,'dd-mon-yyy-hh:mi:ss') );

       FOR j in	c_activity_incr_person( i.schedule_id, i.party_id,i.item_type) LOOP
       INSERT into ozf_activity_customers (activity_customer_id,parent_id, parent_desc, parent_class,
               parent_status, parent_type, confidential_flag,object_id,object_class,object_desc,object_status,source_code,
               start_date, end_date, owner_id, activity_type_code,activity_id, marketing_medium_id,
               party_id, cust_account_id,cust_acct_site_id,site_use_id,site_use_code,prod_indicator,Last_Update_date,Last_updated_by,Creation_date,Created_by,last_update_login)
       values(ozf_activity_customers_s.nextval,j.campaign_id, j.campaign_name, j.rollup_type, j.parent_status,
                  j.campaign_type,j.private_flag, j.schedule_id, j.object_class, j.schedule_name, j.status_code,j.source_code,
                  j.start_date_time, j.end_date_time, j.owner_user_id, j.activity_type_code,
                  j.activity_id, j.marketing_medium_id, j.party_id, j.cust_account_id,
                  j.cust_acct_site_id, j.site_use_id, j.site_use_code, j.prod_indicator,sysdate,FND_GLOBAL.user_id,sysdate,FND_GLOBAL.user_id,FND_GLOBAL.conc_login_id);
       END LOOP;

       FOR j in	c_activity_incr_relationship( i.schedule_id, i.party_id,i.item_type) LOOP
       INSERT into ozf_activity_customers (activity_customer_id,parent_id, parent_desc, parent_class,
               parent_status, parent_type,confidential_flag, object_id,object_class,object_desc,object_status,source_code,
               start_date, end_date, owner_id, activity_type_code,activity_id, marketing_medium_id,
               party_id, cust_account_id,cust_acct_site_id,site_use_id,site_use_code,prod_indicator,Last_Update_date,Last_updated_by,Creation_date,Created_by,last_update_login)
       values(ozf_activity_customers_s.nextval,j.campaign_id, j.campaign_name, j.rollup_type, j.parent_status,
                  j.campaign_type,j.private_flag, j.schedule_id, j.object_class, j.schedule_name, j.status_code,j.source_code,
                  j.start_date_time, j.end_date_time, j.owner_user_id, j.activity_type_code,
                  j.activity_id, j.marketing_medium_id, j.party_id, j.cust_account_id,
                  j.cust_acct_site_id, j.site_use_id, j.site_use_code, j.prod_indicator,sysdate,FND_GLOBAL.user_id,sysdate,FND_GLOBAL.user_id,FND_GLOBAL.conc_login_id);
       END LOOP;

       FOR j in	c_activity_incr_organization( i.schedule_id, i.party_id,i.item_type) LOOP
       INSERT into ozf_activity_customers (activity_customer_id,parent_id, parent_desc, parent_class,
               parent_status, parent_type,confidential_flag, object_id,object_class,object_desc,object_status,source_code,
               start_date, end_date, owner_id, activity_type_code,activity_id, marketing_medium_id,
               party_id, cust_account_id,cust_acct_site_id,site_use_id,site_use_code,prod_indicator,Last_Update_date,Last_updated_by,Creation_date,Created_by,last_update_login)
       values(ozf_activity_customers_s.nextval,j.campaign_id, j.campaign_name, j.rollup_type, j.parent_status,
                  j.campaign_type,j.private_flag, j.schedule_id, j.object_class, j.schedule_name, j.status_code,j.source_code,
                  j.start_date_time, j.end_date_time, j.owner_user_id, j.activity_type_code,
                  j.activity_id, j.marketing_medium_id, j.party_id, j.cust_account_id,
                  j.cust_acct_site_id, j.site_use_id, j.site_use_code, j.prod_indicator,sysdate,FND_GLOBAL.user_id,sysdate,FND_GLOBAL.user_id,FND_GLOBAL.conc_login_id);
       END LOOP;

    END LOOP;


    FOR i in c_new_schedules_prod(l_latest_comp_date) LOOP

    ozf_utility_pvt.write_conc_log('-- Denorm products for new or changed schedule : ' || i.schedule_id|| '-'||to_char(sysdate,'dd-mon-yyy-hh:mi:ss') );

       FOR j in	c_activity_incr_prod_new( i.schedule_id,i.list_header_id) LOOP
       INSERT into ozf_activity_products (activity_product_id,parent_id, parent_desc, parent_class,
               parent_status, parent_type,confidential_flag, object_id,object_class, object_desc,object_status,source_code,
               start_date, end_date, owner_id, activity_type_code,activity_id, marketing_medium_id,
               item,item_type,cust_indicator,Last_Update_date,Last_updated_by,Creation_date,Created_by,last_update_login)
        values(ozf_activity_products_s.nextval,j.campaign_id, j.campaign_name, j.rollup_type, j.parent_status,
                  j.campaign_type,j.private_flag, j.schedule_id, j.object_class, j.schedule_name, j.status_code,j.source_code,
                  j.start_date_time, j.end_date_time, j.owner_user_id, j.activity_type_code,
                  j.activity_id, j.marketing_medium_id, j.item, j.item_type,
                  j.cust_indicator,sysdate,FND_GLOBAL.user_id,sysdate,FND_GLOBAL.user_id,FND_GLOBAL.conc_login_id);
       END LOOP;
       FOR j in	c_activity_incr_cat_new(i.schedule_id, l_org_id,i.list_header_id) LOOP
       INSERT into ozf_activity_products (activity_product_id,parent_id, parent_desc, parent_class,
               parent_status, parent_type,confidential_flag, object_id,object_class, object_desc,object_status,source_code,
               start_date, end_date, owner_id, activity_type_code,activity_id, marketing_medium_id,
               item,item_type,cust_indicator,Last_Update_date,Last_updated_by,Creation_date,Created_by,last_update_login)
        values(ozf_activity_products_s.nextval,j.campaign_id, j.campaign_name, j.rollup_type, j.parent_status,
                  j.campaign_type,j.private_flag, j.schedule_id, j.object_class, j.schedule_name, j.status_code,j.source_code,
                  j.start_date_time, j.end_date_time, j.owner_user_id, j.activity_type_code,
                  j.activity_id, j.marketing_medium_id, j.item, j.item_type,
                  j.cust_indicator,sysdate,FND_GLOBAL.user_id,sysdate,FND_GLOBAL.user_id,FND_GLOBAL.conc_login_id);
       END LOOP;
    END LOOP;

    ozf_utility_pvt.write_conc_log('-- Incremental Load End  --'|| '-'||to_char(sysdate,'dd-mon-yyy-hh:mi:ss'));

  End If;

  EXCEPTION
    WHEN FND_API.g_exc_unexpected_error THEN
      ozf_utility_pvt.write_conc_log('-- Error:  --'||SQLERRM);
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      ERRBUF := SQLERRM || ' ' || l_msg_data;
      RETCODE := '2';

    WHEN OTHERS THEN
      --ROLLBACK TO refresh_denorm;
      ozf_utility_pvt.write_conc_log('-- Error:  --'||SQLERRM);
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      ERRBUF := SQLERRM || ' ' || l_stmt_denorm;
      RETCODE := '2';

END refresh_schedules;



END OZF_SCHEDULE_DENORM_PVT;

/
