--------------------------------------------------------
--  DDL for Package Body AMS_MINISITE_DENORM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_MINISITE_DENORM_PVT" as
/* $Header: amsvmsib.pls 120.2 2005/12/30 00:33:00 sikalyan ship $ */

--=======================================================
--  script used to populate AMS_IBA_MS_ITEMS_DENORM table
--  with data required for section search
--=======================================================

procedure loadMsitesDenormTable(
	errbuf OUT NOCOPY VARCHAR2,
	retcode OUT NOCOPY NUMBER
)
is

dd                        varchar2(20);
l_out_AppInfo             boolean;
l_status_AppInfo          varchar2(300) ;
l_industry_AppInfo        varchar2(300) ;
l_oracle_schema_AppInfo   varchar2(300) ;
l_application_short_name  varchar2(300) ;

CURSOR compCur IS
 select MSITE_ID, MSITE_ROOT_SECTION_ID, START_DATE_ACTIVE from ibe_msites_b
 where msite_id <> 1;
-- where  END_DATE_ACTIVE  > sysdate ;

cursor allTopLevelSections(l_minisite_id in number, l_msite_root_section_id in number) IS
  SELECT distinct s.section_id
  FROM ibe_dsp_msite_sct_sects mss, ibe_dsp_sections_b s
      WHERE mss.parent_section_id = l_msite_root_section_id
  AND mss.mini_site_id        = l_minisite_id
  AND s.section_id            = mss.child_section_id
  AND s.section_type_code     = 'N'
--and not exists (select 1
  --              from ibe_msites_b cc
    --            where s.section_id = cc.MSITE_ROOT_SECTION_ID
      --         )
--  AND NVL(mss.start_date_active, SYSDATE) <= SYSDATE
--  AND NVL(mss.end_date_active, SYSDATE) >= SYSDATE
--  AND NVL(s.start_date_active, SYSDATE) <= SYSDATE
--  AND NVL(s.end_date_active, SYSDATE) >= SYSDATE
   AND TRUNC(SYSDATE) BETWEEN NVL(TRUNC(MSS.START_DATE_ACTIVE),TRUNC(SYSDATE)) AND NVL(TRUNC(MSS.END_DATE_ACTIVE),TRUNC(SYSDATE))
  AND TRUNC(SYSDATE) BETWEEN NVL(TRUNC(S.START_DATE_ACTIVE),TRUNC(SYSDATE)) AND NVL(TRUNC(S.END_DATE_ACTIVE),TRUNC(SYSDATE))
  ORDER BY  s.section_id;

CURSOR ItemCur(p_sectionId in NUMBER, p_msite_id in NUMBER)
IS
SELECT DISTINCT f.inventory_item_id, f.organization_id
  FROM  ibe_dsp_section_items f
  WHERE f.section_id in
(
select cs.child_section_id from
(
SELECT mss.child_section_id child_section_id
     FROM ibe_DSP_MSITE_SCT_SECTS mss
     START WITH mss.child_section_id = p_sectionId
     and mss.mini_site_id = p_msite_id
     CONNECT BY PRIOR mss.child_section_id = mss.parent_section_id
     and mss.mini_site_id = p_msite_id
) cs
where cs.child_section_id not in
(
	 select mss2.parent_section_id
	 from ibe_DSP_MSITE_SCT_SECTS mss2
	 where mini_site_id = p_msite_id
)
and NOT EXISTS
     (
       select 1
       from ibe_dsp_sections_b s
       where s.section_id = cs.child_section_id
       and s.status_code = 'UNPUBLISHED'
     )
);

--  SELECT DISTINCT f.inventory_item_id, f.organization_id
--p_sectionId, p_msite_id
-- FROM  ibe_dsp_section_items f
--  WHERE f.section_id in
--  (
--    SELECT mss.child_section_id
--SELECT mss.parent_section_id
--     FROM ibe_DSP_MSITE_SCT_SECTS mss
--     START WITH mss.child_section_id = p_sectionId
--START WITH mss.parent_section_id = p_sectionId
--     and mss.mini_site_id = p_msite_id
--   CONNECT BY PRIOR mss.child_section_id = mss.parent_section_id
--   AND mss.mini_site_id = p_msite_id
--   MINUS
--   (SELECT mss2.parent_section_id
--     FROM ibe_DSP_MSITE_SCT_SECTS mss2
--   )
--   MINUS
--   (
--     select s.section_id
--     from ibe_DSP_MSITE_SCT_SECTS mss3 , ibe_dsp_sections_b s
--     where  mss3.child_section_id = s.section_id
--     and s.status_code     = 'UNPUBLISHED'
--     and mss3.mini_site_id = p_msite_id
--   )
--   );


BEGIN

DELETE FROM ams_iba_ms_items_denorm;

--commit;

for v_CompoundData in compCur loop

   for sectionIdData in allTopLevelSections(v_CompoundData.MSITE_ID, v_CompoundData.MSITE_ROOT_SECTION_ID ) loop

     for ItemData in ItemCur(sectionIdData.section_id, v_CompoundData.MSITE_ID)
     loop
        insert into ams_iba_ms_items_denorm
          ( item_id                   --inventory_item_id
            , inventory_org_id        --organization_id
            , top_section_id          --section_id
            , minisite_id
            , minisite_item_id
            , start_date_active
            , OBJECT_VERSION_NUMBER
            , CREATED_BY
            , CREATION_DATE
            , LAST_UPDATED_BY
            , LAST_UPDATED_DATE
            , LAST_UPDATE_LOGIN
          )
          VALUES
          (
            ItemData.inventory_item_id,
            ItemData.organization_id,
            sectionIdData.section_id,
	    v_CompoundData.MSITE_ID,
	     ams_iba_ms_items_denorm_s.nextval,
	     v_CompoundData.start_date_active,
	     1,
	     FND_GLOBAL.user_id,
	     SYSDATE,
	     FND_GLOBAL.user_id,
	     SYSDATE,
	     FND_GLOBAL.conc_login_id
          );

     end loop;
/*
    select distinct f.inventory_item_id,f.organization_id, sectionIdData.section_id,
     v_CompoundData.MSITE_ID,
     -- NextMinisiteItemId,  --ams_iba_ms_items_denorm_s.nextval,
     ams_iba_ms_items_denorm_s.nextval,
     v_CompoundData.start_date_active,
     1,
     FND_GLOBAL.user_id,
     SYSDATE,
     FND_GLOBAL.user_id,
     SYSDATE,
     FND_GLOBAL.conc_login_id
     from ibe_dsp_section_items f
     where f.section_id in
    (
      SELECT mss.child_section_id
--SELECT mss.parent_section_id
      FROM ibe_DSP_MSITE_SCT_SECTS mss
      START WITH mss.child_section_id = sectionIdData.section_id
--START WITH mss.parent_section_id = sectionIdData.section_id
      and mss.mini_site_id = v_CompoundData.MSITE_ID
      CONNECT BY PRIOR mss.child_section_id = mss.parent_section_id
      AND mss.mini_site_id =v_CompoundData.MSITE_ID
      MINUS
      (SELECT mss2.parent_section_id
        FROM ibe_DSP_MSITE_SCT_SECTS mss2
      )
      MINUS
      (
        select s.section_id
        from ibe_DSP_MSITE_SCT_SECTS mss3 , ibe_dsp_sections_b s
        where  mss3.child_section_id = s.section_id
        and s.status_code     = 'UNPUBLISHED'
        and mss3.mini_site_id = v_CompoundData.MSITE_ID
      )
   );
*/
  end loop;

end loop;

--commit;

END loadMsitesDenormTable;

END AMS_MINISITE_DENORM_PVT;

/
