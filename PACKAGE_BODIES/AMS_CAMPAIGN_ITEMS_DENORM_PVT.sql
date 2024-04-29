--------------------------------------------------------
--  DDL for Package Body AMS_CAMPAIGN_ITEMS_DENORM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CAMPAIGN_ITEMS_DENORM_PVT" as
/* $Header: amsvcpib.pls 115.3 2003/02/18 13:35:56 sikalyan ship $ */

--=======================================================
-- script to populate AMS_IBA_CPN_ITEMS_DENORM table
--=======================================================

procedure loadCampaignItemsDenormTable(
	errbuf OUT NOCOPY VARCHAR2,
	retcode OUT NOCOPY NUMBER
)
is

CURSOR SchedCur IS

 SELECT inventory_item_id, organization_id, category_id,
        category_set_id, act_product_used_by_id,
        arc_act_product_used_by
  FROM ams_act_products a,
       ams_campaign_schedules_b b
 WHERE a.act_product_used_by_id = b.schedule_id
 AND b.activity_type_code = 'INTERNET'
 AND b.status_code = 'ACTIVE'
 AND b.active_flag = 'Y'
 AND b.activity_id = 30
 AND TRUNC(SYSDATE) BETWEEN NVL(TRUNC(b.start_date_time),TRUNC(SYSDATE)) AND NVL(TRUNC(b.end_date_time),TRUNC(SYSDATE));

 -- AND nvl(b.end_date_time,SYSDATE) >= SYSDATE

BEGIN

 DELETE FROM ams_iba_cpn_items_denorm;

-- commit;

 for SchedItem in SchedCur loop

   IF SchedItem.inventory_item_id is NOT NULL
   THEN
     insert into ams_iba_cpn_items_denorm
     ( cpn_item_id
      , item_id
      , inventory_org_id
      , object_used_by_type
      , object_used_by_id
      , OBJECT_VERSION_NUMBER
      , CREATED_BY
      , CREATION_DATE
      , LAST_UPDATED_BY
      , LAST_UPDATED_DATE
      , LAST_UPDATE_LOGIN
     )
     select
      ams_iba_cpn_items_denorm_s.nextval,
      SchedItem.inventory_item_id,
      SchedItem.organization_id,
      SchedItem.arc_act_product_used_by,
      SchedItem.act_product_used_by_id,
      1,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.conc_login_id
      from DUAL;
  END IF;

  IF SchedItem.category_id IS NOT NULL
  THEN
    INSERT INTO ams_iba_cpn_items_denorm
    ( cpn_item_id
      , item_id
      , inventory_org_id
      , object_used_by_type
      , object_used_by_id
      , OBJECT_VERSION_NUMBER
      , CREATED_BY
      , CREATION_DATE
      , LAST_UPDATED_BY
      , LAST_UPDATED_DATE
      , LAST_UPDATE_LOGIN
    )
    SELECT
      ams_iba_cpn_items_denorm_s.nextval,
      inventory_item_id,
      organization_id,
      SchedItem.arc_act_product_used_by,
      SchedItem.act_product_used_by_id,
      1,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.conc_login_id
    FROM mtl_item_categories a
    WHERE category_id = SchedItem.category_id
    AND NOT EXISTS
       (select 'x' from ams_iba_cpn_items_denorm
        where item_id = a.inventory_item_id
        AND inventory_org_id = a.organization_id);

  END IF;

end loop;

--commit;

END loadCampaignItemsDenormTable;

END AMS_CAMPAIGN_ITEMS_DENORM_PVT;

/
