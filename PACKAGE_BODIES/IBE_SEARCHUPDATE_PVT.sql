--------------------------------------------------------
--  DDL for Package Body IBE_SEARCHUPDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_SEARCHUPDATE_PVT" as
/* $Header: IBEVCSUB.pls 120.7.12010000.5 2017/11/16 06:47:17 amaheshw ship $  */
-----------------------------------------------
--PACKAGE BODY FOR IBE_SEARCH_UPDATE
-----------------------------------------------

--+=======================================================================
--In other tables (ie mtl_system_items has new row ) but not in clob table
--refer pg 290 of oracle 8 book on why not exists was used instead of not in
-- merchant to have to call below procedure as a concurrent program when he
-- has customized to add more columns into clob from mtl_system_items_b table
-- when the mtl_system_items_b adds a new row we need to move data over from
-- that segment also into the clob table
-- +=======================================================================            :
-- End of Comments

G_FETCH_LIMIT CONSTANT NUMBER := 1000;


-------
-- (code for PROCEDURE InsertClob removed on 04/08/2005 by rgupta)
-- This procedure is no longer used and has been removed as a result of SQL REP
-- issues.
--


-------
-- (code for PROCEDURE UpdateClob removed on 04/08/2005 by rgupta)
-- This procedure is no longer used and has been removed as a result of SQL REP
-- issues.
--


-------
-- (code for PROCEDURE TokenizeString removed on 04/08/2005 by rgupta)
-- This procedure is no longer used and has been removed as a result of SQL REP
-- issues.
--


--=======================================================================
--  script used to populate IBE_SECTION_SEARCH table
--  with data required for section search
--=======================================================================
procedure loadMsitesSectionItemsTable(
	errbuf	OUT NOCOPY VARCHAR2,
	retcode OUT NOCOPY NUMBER
)
is

  l_application_short_name  varchar2(300) ;
  l_status_AppInfo          varchar2(300) ;
  l_industry_AppInfo        varchar2(300) ;
  l_oracle_schema_AppInfo   varchar2(300) ;
  x_msite_ids  msite_id_tbl_type;
  l_index      BINARY_INTEGER;
  l_master_msite_id number;
  l_root_section_id number;
  l_sequence number;


  TYPE t_id IS TABLE OF ibe_ct_imedia_search.IBE_CT_IMEDIA_SEARCH_ID%TYPE
    INDEX BY BINARY_INTEGER;
  TYPE t_version_number IS TABLE OF
    ibe_ct_imedia_search.OBJECT_VERSION_NUMBER%TYPE INDEX BY BINARY_INTEGER;
  TYPE t_created_by IS TABLE OF ibe_ct_imedia_search.CREATED_BY%TYPE
    INDEX BY BINARY_INTEGER;
  TYPE t_creation_date IS TABLE OF ibe_ct_imedia_search.CREATION_DATE%TYPE
    INDEX BY BINARY_INTEGER;
  TYPE t_last_updated_by IS TABLE OF ibe_ct_imedia_search.LAST_UPDATED_BY%TYPE
    INDEX BY BINARY_INTEGER;
  TYPE t_last_updated_date IS TABLE OF
    ibe_ct_imedia_search.LAST_UPDATE_DATE%TYPE INDEX BY BINARY_INTEGER;
  TYPE t_last_update_login IS TABLE OF
    ibe_ct_imedia_search.LAST_UPDATE_LOGIN%TYPE INDEX BY BINARY_INTEGER;
  TYPE t_category_id IS TABLE OF ibe_ct_imedia_search.CATEGORY_ID%TYPE
    INDEX BY BINARY_INTEGER;
  TYPE t_organization_id IS TABLE OF ibe_ct_imedia_search.ORGANIZATION_ID%TYPE
    INDEX BY BINARY_INTEGER;
  TYPE t_inventory_item_id IS TABLE OF
    ibe_ct_imedia_search.INVENTORY_ITEM_ID%TYPE INDEX BY BINARY_INTEGER;
  TYPE t_language IS TABLE OF ibe_ct_imedia_search.LANGUAGE%TYPE
    INDEX BY BINARY_INTEGER;
  TYPE t_description IS TABLE OF ibe_ct_imedia_search.DESCRIPTION%TYPE
    INDEX BY BINARY_INTEGER;
  TYPE t_long_description IS TABLE OF
    ibe_ct_imedia_search.LONG_DESCRIPTION%TYPE INDEX BY BINARY_INTEGER;
  TYPE t_concatenated_segments IS TABLE OF
    mtl_system_items_b_kfv.concatenated_segments%TYPE INDEX BY BINARY_INTEGER;
  TYPE t_category_set_id IS TABLE OF ibe_ct_imedia_search.CATEGORY_SET_ID%TYPE
    INDEX BY BINARY_INTEGER;
  TYPE t_web_status IS TABLE OF ibe_ct_imedia_search.WEB_STATUS%TYPE
    INDEX BY BINARY_INTEGER;
  TYPE t_section_id IS TABLE of ibe_dsp_sections_b.section_id%TYPE
	INDEX BY BINARY_INTEGER;


  l_use_category_search VARCHAR(50);
  l_search_category_set VARCHAR2(50);
  l_tmp NUMBER;
  l_index_exists  NUMBER :=  0 ;
  l_id_tbl t_id;
  l_version_number_tbl t_version_number;
  l_created_by_tbl t_created_by;
  l_creation_date_tbl t_creation_date;
  l_last_updated_by_tbl t_last_updated_by;
  l_last_updated_date_tbl t_last_updated_date;
  l_last_update_login_tbl t_last_update_login;
  l_category_id_tbl t_category_id;
  l_organization_id_tbl t_organization_id;
  l_inventory_item_id_tbl t_inventory_item_id;
  l_language_tbl t_language;
  l_description_tbl t_description;
  l_long_description_tbl t_long_description;
  l_concatenated_segments_tbl t_concatenated_segments;
  l_category_set_id_tbl t_category_set_id;
  l_web_status_tbl t_web_status;
  l_toplevel_section_tbl t_section_id;
  --anita end ---

  l_count NUMBER := 2;
  CURSOR compCur IS
    select  MSITE_ID,MSITE_ROOT_SECTION_ID
	 from ibe_msites_b
     where msite_id <> 1 and site_type = 'I';
     -- where  END_DATE_ACTIVE  > sysdate ;

  -- sytong, bug fix 2550153, remove extra table ibe_msites_b in from clause
  cursor allTopLevelSections(l_minisite_id in number,
					    l_msite_root_section_id in number) IS
    SELECT distinct s.section_id
      FROM IBE_DSP_MSITE_SCT_SECTS mss, IBE_DSP_SECTIONS_B s
     WHERE mss.parent_section_id = l_msite_root_section_id
       AND mss.mini_site_id        =  l_minisite_id
       AND s.section_id            = mss.child_section_id
       AND s.section_type_code     = 'N'
       -- Fix bug
       AND s.status_code = 'PUBLISHED'
       AND NVL(mss.start_date_active, SYSDATE) <= SYSDATE
       AND NVL(mss.end_date_active, SYSDATE) >= SYSDATE
       AND NVL(s.start_date_active, SYSDATE) <= SYSDATE
       AND NVL(s.end_date_active, SYSDATE) >= SYSDATE
    ORDER BY  s.section_id;

  -- cursor for catalog exclusions
  CURSOR c2(l_c_master_msite_id IN NUMBER,
		  l_c_msite_id IN NUMBER, l_c_root_section_id IN NUMBER) IS
    select /*+ first_rows */ inventory_item_id
      from (
          select section_item_id, idsi.inventory_item_id
            from ibe_dsp_section_items idsi
           where section_id IN
                 (
                  select  child_section_id
                  from    ibe_dsp_msite_sct_sects s1
                  where  mini_site_id = l_c_master_msite_id
                  and    NOT EXISTS
                          (
                          select  child_section_id
                          from    ibe_dsp_msite_sct_sects s2
                          where  mini_site_id = l_c_msite_id
                          and    s2.child_section_id=s1.child_section_id
                          )
                  CONNECT BY PRIOR child_section_id = parent_section_id
                  and    PRIOR mini_site_id = l_c_master_msite_id
                  and    mini_site_id = l_c_master_msite_id
                  START WITH child_section_id = l_c_root_section_id
                  and    mini_site_id = l_c_master_msite_id
                  )
          and  NOT EXISTS
          (
            select inventory_item_id
            from  ibe_dsp_section_items i1, ibe_dsp_msite_sct_items i2

            where  i1.section_item_id  = i2.section_item_id
            and    i2.mini_site_id = l_c_msite_id
      and i1.inventory_item_id = idsi.inventory_item_id
          )
          union
          select  /*ordered use_nl(s3,i2) */ section_item_id, i2.inventory_item_id
          from    ibe_dsp_msite_sct_sects s3, ibe_dsp_section_items i2
          where  i2.section_id = s3.child_section_id
          and      s3.mini_site_id = l_c_msite_id
          and    NOT EXISTS
                  (
                  select  null
                  from    ibe_dsp_msite_sct_items i3
                  where  mini_site_id = l_c_msite_id
                  and    i3.section_item_id = i2.section_item_id
                  )
          );


  CURSOR c3 IS
    SELECT msite_id, msite_root_section_id
	 FROM ibe_msites_b
     WHERE sysdate BETWEEN start_date_active AND NVL(end_date_active, sysdate)
       AND master_msite_flag = 'N' AND site_type = 'I';

--added new cursor :ab-------
BEGIN
  -- Solve the GSCC warning:
  -- Do not use default values in PL/SQL variable declaration or initialization
  l_use_category_search :='';
  l_search_category_set :='PUBLISHED';

  select application_short_name
    into l_application_short_name
    from fnd_application
   where application_id = 671 ;

FOR l_count in 1..2 LOOP  -- bug2365753
  if (fnd_installation.get_app_info(l_application_short_name,
  			l_status_AppInfo          ,
  			l_industry_AppInfo        ,
  			l_oracle_schema_AppInfo   )) then
    EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_oracle_schema_AppInfo || '.'
      || 'IBE_SECTION_SEARCH_PART drop storage';
  else
    -- This happens only when application schema checking call
    -- is wrong. It usually should not happen.
    execute immediate 'truncate table IBE_SECTION_SEARCH_PART';
  end if ;

  for v_CompoundData in compCur loop --{
	open allTopLevelSections(v_CompoundData.MSITE_ID,v_CompoundData.MSITE_ROOT_SECTION_ID);
	fetch allTopLevelSections bulk collect into l_toplevel_section_tbl;
	close allTopLevelSections;
     FND_FILE.PUT_LINE(FND_FILE.LOG,' Inserting into IBE_SECTION_SEARCH_PART' );

	forall l_count2 in 1..l_toplevel_section_tbl.count
    -- removed on 08/28/01 the minus for parent sections , this is because
    -- anyway the parent sections cannot have items , look at bug 1917056
    -- also changed the 2nd minus to juts remove unpublished sections
    -- compared to before where it was removing unpublished sections
    -- for each given minisite by joining minisite_section table
    insert into IBE_SECTION_SEARCH_PART
      (inventory_item_id
      , organization_id
      , section_id
      , minisite_id
      , OBJECT_VERSION_NUMBER
      , CREATED_BY
      , CREATION_DATE
      , LAST_UPDATED_BY
      , LAST_UPDATE_DATE
      , LAST_UPDATE_LOGIN)
	 select
     distinct f.inventory_item_id,f.organization_id ,
	f.section_id,
--	l_toplevel_section_tbl(l_count2),
	 --sectionIdData.section_id,
   	 --distinct g.inventory_item_id,g.organization_id ,sectionIdData.section_id,
     v_CompoundData.MSITE_ID,
     1,
     FND_GLOBAL.user_id,
     SYSDATE,
     FND_GLOBAL.user_id,
     SYSDATE,
     FND_GLOBAL.conc_login_id
     from ibe_dsp_section_items f ,
		  ibe_dsp_sections_b s
     where (f.end_date_active > sysdate or f.end_date_active is null)
      and f.start_date_active < sysdate
	 and f.section_id = s.section_id
	 and s.status_code = 'PUBLISHED' and f.section_id in
          ( SELECT mss.child_section_id
              FROM IBE_DSP_MSITE_SCT_SECTS mss
              START WITH mss.child_section_id = l_toplevel_section_tbl(l_count2) --sectionIdData.section_id
                     and mss.mini_site_id = v_CompoundData.MSITE_ID
              CONNECT BY PRIOR mss.child_section_id = mss.parent_section_id
                     AND mss.mini_site_id = v_CompoundData.MSITE_ID
          );
 /*
   select distinct g.inventory_item_id,g.organization_id ,sectionIdData.section_id,
          v_CompoundData.MSITE_ID,
          1,
          FND_GLOBAL.user_id,
          SYSDATE,
          FND_GLOBAL.user_id,
          SYSDATE,
          FND_GLOBAL.conc_login_id
     from ibe_dsp_section_items f ,
          mtl_system_items_b g,
		ibe_dsp_sections_b s
    where f.inventory_item_id = g.inventory_item_id
      and (f.end_date_active > sysdate or f.end_date_active is null)
      and f.start_date_active < sysdate
	 and f.section_id = s.section_id
	 and s.status_code = 'PUBLISHED'
      and f.section_id in
          ( SELECT mss.child_section_id
              FROM IBE_DSP_MSITE_SCT_SECTS mss
              START WITH mss.child_section_id = sectionIdData.section_id
                     and mss.mini_site_id = v_CompoundData.MSITE_ID
              CONNECT BY PRIOR mss.child_section_id = mss.parent_section_id
                     AND mss.mini_site_id =v_CompoundData.MSITE_ID
          );
    end loop;
*/
  end loop; --}

  /* Now after loading the data we will remove the catalog
   exclusions for item to minisite from the table
  */
  select msite_id into l_master_msite_id
    from ibe_msites_b
   where UPPER(master_msite_flag) = 'Y' and site_type = 'I';

  l_index := 1;
  FOR r3 IN c3 LOOP
    x_msite_ids(l_index).msite_id := r3.msite_id;
    x_msite_ids(l_index).msite_root_section_id := r3.msite_root_section_id;
    l_index := l_index + 1;
  END LOOP;

  -- For items
  l_index := 1;
  FOR i IN 1..x_msite_ids.COUNT LOOP
    FOR r2 IN c2(l_master_msite_id, x_msite_ids(i).msite_id,
	 x_msite_ids(i).msite_root_section_id) LOOP
      delete from ibe_section_search_part
            where inventory_item_id = r2.inventory_item_id
              and minisite_id = x_msite_ids(i).msite_id;
    END LOOP; -- end loop r2
  END LOOP; -- end loop i
     FND_FILE.PUT_LINE(FND_FILE.LOG,' Calling Alter table exchange partition'   );

 if (fnd_installation.get_app_info(l_application_short_name,
        l_status_AppInfo          ,
       l_industry_AppInfo        ,
       l_oracle_schema_AppInfo   )) then
       EXECUTE IMMEDIATE 'ALTER TABLE ' || l_oracle_schema_AppInfo || '.'
            || 'IBE_SECTION_SEARCH_PART exchange partition PART1 with table  '
           || l_oracle_schema_AppInfo || '.' || 'IBE_SECTION_SEARCH'
           ||' including indexes without validation';
    else
       -- This happens only when application schema checking call
       -- is wrong. It usually should not happen.

    execute immediate
    'alter table IBE_SECTION_SEARCH_PART exchange partition PART1 with table IBE_SECTION_SEARCH ' ||
     'including indexes without validation' ;
end if;

END LOOP; -- end for loop bug23265753

  /*  Section for getting oracle schema name for ibe , since we cannot hard code schema
      name , so strategy is to get application short name pass it to fnd api . note it
      can throw exception if more than one schema is found , but this cannot happen for
      iStore since it is a new product in 11.5
  */
  -- Remove the following select statement as the l_application_short_name
  -- has been set at the beginning of the procedure.
  -- select application_short_name
  --  into l_application_short_name
  --  from fnd_application
  --  where application_id = 671 ;
  --
  -- refresh materialized view in apps schema
/*
  execute immediate
    'begin DBMS_MVIEW.REFRESH(:1,''A'','''',TRUE, FALSE, 0,0,0, TRUE); end; '
    using 'ibe_sct_search_mv' ;
*/
  -- removing for now as it is very expenisve and time consuming to do
  -- and unnecessary if you just add a new section etc
  --ctx_ddl.sync_index('IBE_CT_IMEDIA_SEARCH_IM');

-- ========= ab start =============================================

--Original Section Refresh logic in the program, including populating ibe_section_search table and refresh materialized view ibe_sct_search_mv;
--Get category search profile setting IBE_USE_CATEGORY_SEARCH;
l_use_category_search := FND_PROFILE.VALUE_specific('IBE_USE_CATEGORY_SEARCH',671,0,671);

If l_use_category_search='N' Then
   l_tmp:=0;
   ----dbms_output.put_line('category search is N');

  --Get search category set profile setting IBE_SEARCH_CATEGORY_SET;
  l_search_category_set := FND_PROFILE.VALUE_specific('IBE_SEARCH_CATEGORY_SET',671,0,671);
   ----dbms_output.put_line('search category set value='||l_search_category_set);
  If (l_search_category_set is not null) Then
	INSERT INTO ibe_ct_imedia_search
       (IBE_CT_IMEDIA_SEARCH_ID,
       INVENTORY_ITEM_ID,
       OBJECT_VERSION_NUMBER,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN,
       CATEGORY_ID,
       ORGANIZATION_ID,
       LANGUAGE,
       DESCRIPTION,
       LONG_DESCRIPTION,
       CATEGORY_SET_ID,
       WEB_STATUS,
       INDEXED_SEARCH)
      select ibe_ct_imedia_search_s1.nextval,
      t.INVENTORY_ITEM_ID,t.OBJECT_VERSION_NUMBER,t.CREATED_BY,t.CREATION_DATE,t.LAST_UPDATED_BY,
      t.LAST_UPDATE_DATE,t.LAST_UPDATE_LOGIN,t.CATEGORY_ID,t.ORGANIZATION_ID,t.LANGUAGE,
      t.DESCRIPTION,t.LONG_DESCRIPTION,t.CATEGORY_SET_ID,t.WEB_STATUS,
      ibe_search_setup_pvt.WriteToLob(t.DESCRIPTION, t.LONG_DESCRIPTION, t.concatenated_segments)
      from
		(select distinct b.INVENTORY_ITEM_ID INVENTORY_ITEM_ID,1 OBJECT_VERSION_NUMBER,
                      	FND_GLOBAL.user_id CREATED_BY,SYSDATE CREATION_DATE,
                    	FND_GLOBAL.user_id LAST_UPDATED_BY, SYSDATE LAST_UPDATE_DATE,
                        FND_GLOBAL.conc_login_id LAST_UPDATE_LOGIN, c.CATEGORY_ID,
                        b.ORGANIZATION_ID,b.LANGUAGE,b.DESCRIPTION, b.LONG_DESCRIPTION,
                        a.concatenated_segments,c.CATEGORY_SET_ID,a.WEB_STATUS
         from  mtl_system_items_b_kfv a, mtl_system_items_tl b, mtl_item_categories c, ibe_dsp_section_items d
         where d.inventory_item_id = a.inventory_item_id
           and d.organization_id = a.organization_id
           and a.INVENTORY_ITEM_ID = b.INVENTORY_ITEM_ID
           and a.organization_id   = b.organization_id
           and a.web_status = 'PUBLISHED'
           and a.INVENTORY_ITEM_ID = c.INVENTORY_ITEM_ID
           and a.organization_id   = c.organization_id
           and not exists ( select r.INVENTORY_ITEM_ID ,r.ORGANIZATION_ID
                              from IBE_CT_IMEDIA_SEARCH r
                             where r.INVENTORY_ITEM_ID = b.INVENTORY_ITEM_ID
                               and r.ORGANIZATION_ID   = b.ORGANIZATION_ID)
        )t ;

     commit;

     FND_FILE.PUT_LINE(FND_FILE.LOG,' the loop index after insert is  = ' || l_tmp   );
     ----dbms_output.put_line(' the loop index after insert is  = ' || l_tmp   );
     ----dbms_output.put_line('sequence value='||l_sequence);
     l_sequence:=l_sequence+1;
     l_tmp:=l_tmp+1;


--Check IBE_CT_IMEDIA_SEARCH_IM Index;
 select count(*)
 into l_index_exists
 from user_indexes
 where index_name = 'IBE_CT_IMEDIA_SEARCH_IM';

 if(l_index_exists > 0 ) then
      ----dbms_output.put_line('Before synchronizing the index');
     --Synchronize the IBE_CT_IMEDIA_SEARCH_IM index by calling inter media synchronize procedure;
	     FND_FILE.PUT_LINE(FND_FILE.LOG,' Sync the intermedia index' );

     ctx_ddl.sync_index('IBE_CT_IMEDIA_SEARCH_IM');

  End if;
 End if;
End if;

--==========end ab =======================================
  FND_FILE.PUT_LINE(FND_FILE.LOG,'Procedure completed sucessfully');
end loadMsitesSectionItemsTable;


end IBE_SearchUpdate_PVT ;

/
