--------------------------------------------------------
--  DDL for Package Body IBE_SEARCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_SEARCH_PVT" as
/* $Header: IBEVCSKB.pls 120.1.12010000.3 2014/05/27 21:39:29 ytian ship $  */

/* +=======================================================================
|    Copyright (c) 1999, 2014 Oracle Corporation, Redwood Shores, CA, USA
|                         All rights reserved.
+=======================================================================
| FILENAME
|   ibevcskb.sql
|
| DESCRIPTION
|
| NOTES
|This is primarily used for the triggers of mtl tables to update the
|IBE_CT_IMEDIA_SEARCH table .
|
|MTL_ITEM_CATEGORIES
|1) insert ,
|2) delete
|not sure if direct updates take place here
|
|MTL_SYSTEM_ITEMS_B
|dont care about its update as we are not using any of its columns right now
|Although we could just write the inset update delete on its tl table we
|still decided to write the delete on it :-)
|
|
|
| HISTORY
|   12-15-99  Savio T    Created.
|   10-16-03 abhandar  modified bug fix 3168087:catalog search performance
|   04-16-08 mgiridha  bug 6924793 ITEMS NOT SEARCHABLE BY PART NUMBER AFTER REPUBLISHING ON ISTORE.
|   20-May-13 nsatyava Bug 16566759 - IBE_CT_IMEDIA_SEARCH CONTAINS ROWS WITH DIFFERENT CATEGORY_SET_ID FOR SAME ITEM
|   27-May-14 ytian Fixed Bug 18782056 to add filter of master org and take care of NULL value for search category set.
+=======================================================================*/

-----------------------------------------------
--PROCEDURE CALLED ON INSERT IN ITEM CATEGORIES
--HERE YOU NEED TO INSERT A NEW ROW INTO IMEDIA_SEARCH TABLE
--added on 04/18 code to join on mtl_system_items_b
--table to get web status flag over
-----------------------------------------------
procedure Item_Category_Inserted(
new_category_id       number,
new_category_set_id   number,
new_inventory_item_id number,
new_organization_id   number)
is

l_insert_flag boolean:=false;
l_search_category_set varchar2(30):='';
l_search_web_status VARCHAR2(30):= 'PUBLISHED';
l_use_category_search VARCHAR2(30)	:= 'N ';


begin

--dbms_output.put_line('Start item category inserted');

--dbms_output.put_line('inputs are:new_category_id='||new_category_id
--||':new_category_set_id='||new_category_set_id
--||':new_inventory_item_id='||new_inventory_item_id
--||':new_organization_id ='||new_organization_id);

--Get IBE_SEARCH_CATEGORY_SET Profile value
l_use_category_search := FND_PROFILE.VALUE_specific('IBE_USE_CATEGORY_SEARCH',671,0,671);
--Get Search Category Set profile IBE_SEARCH_CATEGORY_SET;
l_search_category_set := FND_PROFILE.VALUE_specific('IBE_SEARCH_CATEGORY_SET',671,0,671);
--Get product status profile IBE_SEARCH_WEB_STATUS;
l_search_web_status := FND_PROFILE.VALUE_specific('IBE_SEARCH_WEB_STATUS',671,0,671);

--dbms_output.put_line('use_category_search='||l_use_category_search
--||'search_category_set='||l_search_category_set||':search_web_status='||l_search_web_status);

IF l_search_category_set is not null THEN
   IF new_category_set_id = l_search_category_set THEN
      l_insert_flag := TRUE;
   ELSE
       l_insert_flag := FALSE;
   END IF;
ELSE
  l_insert_flag := TRUE;
END IF;


IF (l_insert_flag) THEN
   --dbms_output.put_line('l_insert_flag=true');

  --Get IBE_SEARCH_WEB_STATUS profile value
  l_search_web_status := FND_PROFILE.VALUE_specific('IBE_SEARCH_WEB_STATUS',671,0,671);

  IF l_search_web_status = 'PUBLISHED' or l_search_web_status is NULL THEN

     --dbms_output.put_line('inserting into ibe_ct_imedia_search table for web status PUBLISHED/NULL');
     insert into ibe_ct_imedia_search (IBE_CT_IMEDIA_SEARCH_ID
        , OBJECT_VERSION_NUMBER, CREATED_BY, CREATION_DATE
        , LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
        , CATEGORY_ID, ORGANIZATION_ID, INVENTORY_ITEM_ID
        , LANGUAGE, DESCRIPTION, LONG_DESCRIPTION, INDEXED_SEARCH
        , CATEGORY_SET_ID, WEB_STATUS)
        SELECT
           ibe_ct_imedia_search_s1.nextval,
           0,       FND_GLOBAL.user_id,
           SYSDATE,       FND_GLOBAL.user_id,
           SYSDATE,       FND_GLOBAL.conc_login_id,
           new_category_id ,       new_organization_id ,
           new_inventory_item_id,       b.LANGUAGE,
           b.DESCRIPTION,       b.LONG_DESCRIPTION,
           ibe_search_setup_pvt.WriteToLob(b.description , b.long_description ,c.concatenated_segments),
           new_category_set_id   ,       a.web_status
        from  mtl_system_items_b a ,mtl_system_items_tl b ,mtl_system_items_kfv c
        where   b.INVENTORY_ITEM_ID = a.INVENTORY_ITEM_ID
        and   b.organization_id   = a.organization_id
        and   b.INVENTORY_ITEM_ID = new_inventory_item_id
        and   b.ORGANIZATION_ID   = new_organization_id
        and   a.INVENTORY_ITEM_ID = c.INVENTORY_ITEM_ID
        and   a.ORGANIZATION_ID   = c.organization_id
        and   a.web_status = 'PUBLISHED';

   ELSIF l_search_web_status ='PUBLISHED_UNPUBLISHED' THEN

        --dbms_output.put_line('inserting into ibe_ct_imedia_search table for web status PUBLISHED_UNPUBLISHED');
        insert into ibe_ct_imedia_search (IBE_CT_IMEDIA_SEARCH_ID
        , OBJECT_VERSION_NUMBER, CREATED_BY, CREATION_DATE
        , LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
        , CATEGORY_ID, ORGANIZATION_ID, INVENTORY_ITEM_ID
        , LANGUAGE, DESCRIPTION, LONG_DESCRIPTION, INDEXED_SEARCH
        , CATEGORY_SET_ID, WEB_STATUS)
        SELECT
            ibe_ct_imedia_search_s1.nextval,
            0,       FND_GLOBAL.user_id,
            SYSDATE,       FND_GLOBAL.user_id,
            SYSDATE,       FND_GLOBAL.conc_login_id,
            new_category_id ,       new_organization_id ,
            new_inventory_item_id,       b.LANGUAGE,
            b.DESCRIPTION,       b.LONG_DESCRIPTION,
            ibe_search_setup_pvt.WriteToLob(b.description, b.long_description ,c.concatenated_segments),
            new_category_set_id ,  a.web_status
            from  mtl_system_items_b a ,mtl_system_items_tl b ,mtl_system_items_kfv c
            where   b.INVENTORY_ITEM_ID = a.INVENTORY_ITEM_ID
            and   b.organization_id   = a.organization_id
            and   b.INVENTORY_ITEM_ID = new_inventory_item_id
            and   b.ORGANIZATION_ID   = new_organization_id
            and   a.INVENTORY_ITEM_ID = c.INVENTORY_ITEM_ID
            and   a.ORGANIZATION_ID   = c.organization_id
            and   a.web_status IN ('PUBLISHED', 'UNPUBLISHED');
  ELSE
        --dbms_output.put_line('inserting into ibe_ct_imedia_search table for web status ALL');
         insert into ibe_ct_imedia_search (IBE_CT_IMEDIA_SEARCH_ID
        , OBJECT_VERSION_NUMBER, CREATED_BY, CREATION_DATE
        , LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
        , CATEGORY_ID, ORGANIZATION_ID, INVENTORY_ITEM_ID
        , LANGUAGE, DESCRIPTION, LONG_DESCRIPTION, INDEXED_SEARCH
        , CATEGORY_SET_ID, WEB_STATUS)
        SELECT
           ibe_ct_imedia_search_s1.nextval,
           0,       FND_GLOBAL.user_id,
           SYSDATE,       FND_GLOBAL.user_id,
           SYSDATE,       FND_GLOBAL.conc_login_id,
           new_category_id ,       new_organization_id ,
           new_inventory_item_id,       b.LANGUAGE,
           b.DESCRIPTION,       b.LONG_DESCRIPTION,
           ibe_search_setup_pvt.WriteToLob(b.description , b.long_description ,c.concatenated_segments),
           new_category_set_id   ,       a.web_status
        from  mtl_system_items_b a ,mtl_system_items_tl b ,mtl_system_items_kfv c
        where   b.INVENTORY_ITEM_ID = a.INVENTORY_ITEM_ID
        and   b.organization_id   = a.organization_id
        and   b.INVENTORY_ITEM_ID = new_inventory_item_id
        and   b.ORGANIZATION_ID   = new_organization_id
        and   a.INVENTORY_ITEM_ID = c.INVENTORY_ITEM_ID
        and   a.ORGANIZATION_ID   = c.organization_id;
   END IF;
END IF;

--dbms_output.put_line(' End Item Category Inserted');
END Item_Category_Inserted;


-----------------------------------------------
--PROCEDURE CALLED ON DELETE IN ITEM CATEGORIES
-- 04/17 UPDATED THIS FUNCTION CALL TO TAKE OLD
-- AND NEW ORG ID SO THAT WE CAN NOW DELETE A CATEGORY
-- FOR A PRODUCT BELONGING TO A SPECIFIC ORG ID
-----------------------------------------------

procedure Item_Category_Deleted(
old_category_id number,
old_category_set_id number,
old_inventory_item_id number,
old_organization_id number)
is
begin

delete from  ibe_ct_imedia_search c
where  c.CATEGORY_ID       = old_category_id
and    c.CATEGORY_SET_ID   = old_category_set_id
and    c.INVENTORY_ITEM_ID = old_inventory_item_id
and    c.ORGANIZATION_ID   = old_organization_id  ;


end Item_Category_Deleted;


-----------------------------------------------
--PROCEDURE CALLED ON UPDATE IN ITEM CATEGORIES
-- 04/17 UPDATED THIS FUNCTION CALL TO TAKE OLD
-- AND NEW ORG ID SO THAT WE CAN NOW UPDATE A CATEGORY
-- FOR A PRODUCT BELONGING TO A SPECIFIC ORG ID
-----------------------------------------------

procedure Item_Category_Updated(
old_category_id       number,new_category_id       number,
old_category_set_id   number,new_category_set_id   number,
old_inventory_item_id number,new_inventory_item_id number,
old_organization_id   number,new_organization_id   number)
is

l_search_category_set VARCHAR2(30);
l_search_web_status VARCHAR2(30);
l_use_category_search VARCHAR(30);
l_web_status VARCHAR2(30);
l_temp number;

CURSOR c_check_section_item_csr (c_inventory_item_id number, c_organization_id number) is
select 1  from mtl_system_items_b item
where item.inventory_item_id =c_inventory_item_id
and item.organization_id=c_organization_id
and item.web_status='PUBLISHED' and
exists (select 1 from ibe_dsp_section_items sec_item
where sec_item.inventory_item_id=item.inventory_item_id
and organization_id=item.organization_id);


begin

----dbms_output.put_line('begin item category updated');
----dbms_output.put_line('inputs :oldCatId='||old_category_id
--||':oldCatSetId='||old_category_set_id
--||':old_inventory_item_id='||old_inventory_item_id
--||':oldOrgId='||old_organization_id
--||':newCatId='||new_category_id
--||':newCatSetId='||new_category_set_id
--||':newInvItemId='||new_inventory_item_id
--||':newOrgId='||new_organization_id);

IF old_category_set_id = new_category_set_id THEN
    --dbms_output.put_line('Updating data :old category set id = new category set id');
    update ibe_ct_imedia_search c
    set CATEGORY_ID        = new_category_id,
       CATEGORY_SET_ID     = new_category_set_id,
       LAST_UPDATE_DATE    = sysdate,
       INVENTORY_ITEM_ID   = new_inventory_item_id,
       ORGANIZATION_ID     = new_organization_id
    where  c.CATEGORY_ID       = old_category_id
    AND    c.CATEGORY_SET_ID   = old_category_set_id
    AND    c.INVENTORY_ITEM_ID = old_inventory_item_id
    AND    c.ORGANIZATION_ID   = old_organization_id;

ELSE -- the old and new category set ids are different-------------

      --Get IBE_SEARCH_CATEGORY_SET Profile value
    l_search_category_set := FND_PROFILE.VALUE_specific('IBE_SEARCH_CATEGORY_SET',671,0,671);
    ----dbms_output.put_line('Search category set='||l_search_category_set);
    IF l_search_category_set is NULL THEN
        ------dbms_output.put_line('Updating data :search category set is null');
        update ibe_ct_imedia_search c
        set CATEGORY_ID         = new_category_id,
            CATEGORY_SET_ID     = new_category_set_id,
            LAST_UPDATE_DATE    = sysdate,
            INVENTORY_ITEM_ID   = new_inventory_item_id,
            ORGANIZATION_ID     = new_organization_id
        where c.CATEGORY_ID    = old_category_id
        AND c.CATEGORY_SET_ID   = old_category_set_id
        AND c.INVENTORY_ITEM_ID = old_inventory_item_id
        AND c.ORGANIZATION_ID   = old_organization_id;

    ELSE ----- search category set not null----------------------

        ----dbms_output.put_line('Search category set is not null');
        IF old_category_set_id = l_search_category_set THEN
           ----dbms_output.put_line('Deleting row:old category set id = l_search category set');

           --------------enhancement -check for section search -------------
           l_use_category_search := FND_PROFILE.VALUE_specific('IBE_USE_CATEGORY_SEARCH',671,0,671);

           IF l_use_category_search ='N' then --profile set for section search
              -- check whether item associated to some section
               OPEN c_check_section_item_csr(old_inventory_item_id,old_organization_id);
               FETCH c_check_section_item_csr into l_temp;
               IF c_check_section_item_csr%FOUND then
                  --- update the record
                    CLOSE c_check_section_item_csr;
                    update ibe_ct_imedia_search c
                    set CATEGORY_ID      = new_category_id,
                    CATEGORY_SET_ID     = new_category_set_id,
                    LAST_UPDATE_DATE    = sysdate,
                    INVENTORY_ITEM_ID   = new_inventory_item_id,
                    ORGANIZATION_ID     = new_organization_id
                    where c.CATEGORY_ID   = old_category_id
                    AND c.CATEGORY_SET_ID  = old_category_set_id
                    AND c.INVENTORY_ITEM_ID= old_inventory_item_id
                    AND c.ORGANIZATION_ID  = old_organization_id;

                ELSE ------- c_check_section_item_csr NOT found-----------
                   -- delete the record -
                   CLOSE c_check_section_item_csr;
                    DELETE ibe_ct_imedia_search where
                    CATEGORY_ID    = old_category_id
                    AND CATEGORY_SET_ID   = old_category_set_id
                    AND INVENTORY_ITEM_ID = old_inventory_item_id
                    AND ORGANIZATION_ID   = old_organization_id;
                END IF;

           ELSE ------l_use_category_search ='Y'--------
              DELETE ibe_ct_imedia_search where
              CATEGORY_ID    = old_category_id
              AND CATEGORY_SET_ID   = old_category_set_id
              AND INVENTORY_ITEM_ID = old_inventory_item_id
              AND ORGANIZATION_ID   = old_organization_id;
          END IF;

        ElSIF new_category_set_id = l_search_category_set THEN
            ----dbms_output.put_line('Adding row :new category set id = l_search category set');
             --Insert item into ibe_ct_imedia_search table based on the new value and IBE_SEARCH_WEB_STATUS profile value;

          select web_status into l_web_status  from mtl_system_items_b
          where inventory_item_id=new_inventory_item_id and organization_id= new_organization_id;
          l_search_web_status := FND_PROFILE.VALUE_specific('IBE_SEARCH_WEB_STATUS',671,0,671);

          ----dbms_output.put_line('l_web_status='||l_web_status||':search web status='||l_search_web_status);

          if ( l_search_web_status ='ALL'
              OR l_search_web_status=l_web_status
              OR (l_search_web_status='PUBLISHED_UNPUBLISHED' AND l_web_status='PUBLISHED')
              OR (l_search_web_status='PUBLISHED_UNPUBLISHED' AND l_web_status='UNPUBLISHED')) THEN

               ----dbms_output.put_line ('Inserting into ibe_ct_imedia_search table');

               insert into ibe_ct_imedia_search (IBE_CT_IMEDIA_SEARCH_ID
                , OBJECT_VERSION_NUMBER, CREATED_BY, CREATION_DATE
                , LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
                , CATEGORY_ID, ORGANIZATION_ID, INVENTORY_ITEM_ID
                , LANGUAGE, DESCRIPTION, LONG_DESCRIPTION, INDEXED_SEARCH
                , CATEGORY_SET_ID, WEB_STATUS)
              SELECT
                ibe_ct_imedia_search_s1.nextval,
                0,  FND_GLOBAL.user_id,
                SYSDATE, FND_GLOBAL.user_id,
                SYSDATE, FND_GLOBAL.conc_login_id,
                new_category_id , new_organization_id ,
                new_inventory_item_id,  b.LANGUAGE,
                b.DESCRIPTION, b.LONG_DESCRIPTION,
                ibe_search_setup_pvt.WriteToLob(b.description , b.long_description ,c.concatenated_segments),
                new_category_set_id , a.web_status
             from  mtl_system_items_b a ,mtl_system_items_tl b ,mtl_system_items_kfv c
             where b.INVENTORY_ITEM_ID = a.INVENTORY_ITEM_ID
             and   b.organization_id   = a.organization_id
             and   b.INVENTORY_ITEM_ID = new_inventory_item_id
             and   b.ORGANIZATION_ID   = new_organization_id
             and   a.INVENTORY_ITEM_ID = c.INVENTORY_ITEM_ID
             and   a.ORGANIZATION_ID   = c.organization_id;
           -- and   a.web_status = l_search_web_status;
           END IF;
        END IF;
  END IF;
  ----dbms_output.put_line('Done');
END IF;
END Item_Category_Updated;

-----------------------------------------------
--PROCEDURE CALLED ON DELETE IN ITEM
--SINCE WE DONT MOVE DATA FROM MTL_ITEMS BASE
--TABLE NOW , WE ARE NOT WRITING THE INSERT AND UPDATE
--PROCEDURES FOR IT
-----------------------------------------------

procedure Item_Deleted(
old_inventory_item_id number,
old_organization_id number)
is
begin

delete from  ibe_ct_imedia_search c
where        c.INVENTORY_ITEM_ID = old_inventory_item_id
and          c.ORGANIZATION_ID   = old_organization_id ;

end Item_Deleted ;

-----------------------------------------------
--Function to check whether item associated with the
-- profile value category set id
-----------------------------------------------

function Item_In_CatSetId_profile(
   p_inventory_item_id IN number,
   p_organization_id IN number) return NUMBER
is
 l_search_category_set varchar2(30);
 l_search_web_status VARCHAR2(30):= 'PUBLISHED';
 l_use_category_search VARCHAR2(30)	:= 'N ';
 l_item_exists_count        NUMBER     :=  0 ;

begin
 --Get Search Category Set profile IBE_SEARCH_CATEGORY_SET;
  l_search_category_set := FND_PROFILE.VALUE_specific('IBE_SEARCH_CATEGORY_SET',671,0,671);
 -- Check if item is under the category set specified by IBE_SEARCH_CATEGORY_SET
   if l_search_category_set is not null then
      select 1 into l_item_exists_count from mtl_item_categories
      where inventory_item_id = p_inventory_item_id and
      organization_id= p_organization_id and category_set_id=l_search_category_set
      and rownum=1;
  else  ---- profile value NULL ie All Category Set Ids
     select 1 into l_item_exists_count  from mtl_item_categories
     where inventory_item_id = p_inventory_item_id and
     organization_id= p_organization_id and rownum=1;
  END If;

RETURN l_item_exists_count;
end Item_In_CatSetId_profile;
-----------------------------------------------
--PROCEDURE CALLED ON UPDATE IN ITEM
--WE will not insert new row when web_status flag
-- is updated to "PUBLISHED" because we already
-- have a data inserted through the concurrent program
-- regardless of web_status.  We just need to update
-- the web_status in ibe_ct_imedia_search
-----------------------------------------------
procedure Item_Updated(
old_inventory_item_id number,
old_organization_id   number,
old_web_status        varchar2,
new_web_status        varchar2)
is

l_search_web_status VARCHAR2(30);
l_category_set_id VARCHAR2(30);
l_item_exists number :=0;
l_module varchar2(20):='ibe_search_pvt';
l_temp number:=0;

begin
----dbms_output.put_line('inputs:oldInvItemId='||old_inventory_item_id
--||':oldOrgId='||old_organization_id
--||':oldWebStatus='||old_web_status
--||':newWebStatus='||new_web_status);

--Get IBE_SEARCH_WEB_STATUS Profile value
l_search_web_status := FND_PROFILE.VALUE_specific('IBE_SEARCH_WEB_STATUS',671,0,671);

-- Bug 16566759 Setting Category_set_id
l_category_set_id :=  FND_PROFILE.VALUE_specific('IBE_SEARCH_CATEGORY_SET',671,0,671);

IF l_search_web_status='ALL' THEN
    --dbms_output.put_line('updating data;Web status =ALL');
    update ibe_ct_imedia_search
    set     web_status  = new_web_status
    where   inventory_item_id   = old_inventory_item_id
    and     organization_id     = old_organization_id;

ELSIF l_search_web_status='PUBLISHED_UNPUBLISHED' THEN
   IF old_web_status NOT IN ('PUBLISHED', 'UNPUBLISHED') THEN
      ----dbms_output.put_line('old_web_status NOT IN (PUBLISHED,UNPUBLISHED)');
      IF new_web_status IN ('PUBLISHED', 'UNPUBLISHED') THEN
        ----dbms_output.put_line ('new_web_status IN (PUBLISHED, UNPUBLISHED)');

   -- need to check whether the item exists under the profile category_set_id value
        l_item_exists:=Item_In_CatSetId_profile(old_inventory_item_id,old_organization_id);

        ----dbms_output.put_line('l_item_exists='||l_item_exists);
        IF (l_item_exists>0) then
         --Insert item into ibe_ct_imedia_search;
           --dbms_output.put_line('Adding Row ;l_item_exists >0');

            -- ***inserting '' for the concatenated_segment in the clob
            --as cannot access mtl_system_items_kfv.concatenated_segments value here.
            --Later on ItemTL_Updated trigger will be called which will update the
            -- CLOB value ****.
            -- Above comment is not valid changed below query for bug 6924793 mgiridha
     if (l_category_set_id is NOT NULL) then
            insert into ibe_ct_imedia_search (IBE_CT_IMEDIA_SEARCH_ID
            , OBJECT_VERSION_NUMBER, CREATED_BY, CREATION_DATE
            , LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
            , CATEGORY_ID, ORGANIZATION_ID, INVENTORY_ITEM_ID
            , LANGUAGE, DESCRIPTION, LONG_DESCRIPTION, INDEXED_SEARCH
            , CATEGORY_SET_ID, WEB_STATUS)
            SELECT
             ibe_ct_imedia_search_s1.nextval,
             0,       FND_GLOBAL.user_id,
             SYSDATE,       FND_GLOBAL.user_id,
             SYSDATE,       FND_GLOBAL.conc_login_id,
             d.category_id  ,       old_organization_id ,
             old_inventory_item_id,       b.LANGUAGE,
             b.DESCRIPTION,       b.LONG_DESCRIPTION,
             ibe_search_setup_pvt.WriteToLob(b.description , b.long_description ,a.concatenated_segments),
             d.category_set_id ,  new_web_status
             from  mtl_system_items_tl b ,mtl_item_categories d, mtl_system_items_b_kfv a
             where b.INVENTORY_ITEM_ID = old_inventory_item_id
	     and   b.ORGANIZATION_ID   = old_organization_id
       and   d.category_set_id  = l_category_set_id
	     and   b.INVENTORY_ITEM_ID = d.INVENTORY_ITEM_ID
	     and   b.organization_id   = d.organization_id
	     and   d.INVENTORY_ITEM_ID = a.INVENTORY_ITEM_ID
	     and   d.organization_id   = a.organization_id
          and
         exists (select 1
                 from oe_system_parameters_all osp
                 where osp.master_organization_id = b.organization_id);
    else
 insert into ibe_ct_imedia_search (IBE_CT_IMEDIA_SEARCH_ID
            , OBJECT_VERSION_NUMBER, CREATED_BY, CREATION_DATE
            , LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
            , CATEGORY_ID, ORGANIZATION_ID, INVENTORY_ITEM_ID
            , LANGUAGE, DESCRIPTION, LONG_DESCRIPTION, INDEXED_SEARCH
            , CATEGORY_SET_ID, WEB_STATUS)
            SELECT
             ibe_ct_imedia_search_s1.nextval,
             0,       FND_GLOBAL.user_id,
             SYSDATE,       FND_GLOBAL.user_id,
             SYSDATE,       FND_GLOBAL.conc_login_id,
             d.category_id  ,       old_organization_id ,
             old_inventory_item_id,       b.LANGUAGE,
             b.DESCRIPTION,       b.LONG_DESCRIPTION,
             ibe_search_setup_pvt.WriteToLob(b.description , b.long_description ,a.concatenated_segments),
             d.category_set_id ,  new_web_status
             from  mtl_system_items_tl b ,mtl_item_categories d, mtl_system_items_b_kfv a
             where b.INVENTORY_ITEM_ID = old_inventory_item_id
	     and   b.ORGANIZATION_ID   = old_organization_id
       --and   d.category_set_id  = l_category_set_id
	     and   b.INVENTORY_ITEM_ID = d.INVENTORY_ITEM_ID
	     and   b.organization_id   = d.organization_id
	     and   d.INVENTORY_ITEM_ID = a.INVENTORY_ITEM_ID
	     and   d.organization_id   = a.organization_id
          and
         exists (select 1
                 from oe_system_parameters_all osp
                 where osp.master_organization_id = b.organization_id);


    end if;
         END IF;
     END IF;
  ELSE  -- old_web_status IN ('PUBLISHED', 'UNPUBLISHED')
      IF new_web_status IN ('PUBLISHED', 'UNPUBLISHED') THEN
        ----dbms_output.put_line('updating... ,new_web_status IN (PUBLISHED, UNPUBLISHED');

        update ibe_ct_imedia_search
        set     web_status  = new_web_status
        where   inventory_item_id   = old_inventory_item_id
        AND     organization_id     = old_organization_id;
     END IF;
  END IF;
ELSIF (l_search_web_status='PUBLISHED' OR l_search_web_status is null)  THEN

    ----dbms_output.put_line('l_search_web_status=PUBLISHED OR l_search_web_status is null');

    IF new_web_status ='PUBLISHED' THEN

       ----dbms_output.put_line('new_web_status = PUBLISHED');
       --  need to check whether the item exists under the profile category_set_id value
       l_item_exists:=Item_In_CatSetId_profile(old_inventory_item_id,old_organization_id);

       IF (l_item_exists>0) then
        --Insert item into ibe_ct_imedia_search;
            ----dbms_output.put_line('inserting row...: l_item_exists='||l_item_exists);

            --**** inserting '' for the concatenated_segment in the clob
            --as cannot access mtl_system_items_kfv.concatenated_segments value here.
            --Later on ItemTL_Updated trigger will be called which will update the
            -- CLOB value ****.
            -- Above comment is not valid changed below query for bug 6924793 mgiridha

        if (l_category_set_id is NOT NULL) then
            insert into ibe_ct_imedia_search (IBE_CT_IMEDIA_SEARCH_ID
            , OBJECT_VERSION_NUMBER, CREATED_BY, CREATION_DATE
            , LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
            , CATEGORY_ID, ORGANIZATION_ID, INVENTORY_ITEM_ID
            , LANGUAGE, DESCRIPTION, LONG_DESCRIPTION, INDEXED_SEARCH
            , CATEGORY_SET_ID, WEB_STATUS)
            SELECT
             ibe_ct_imedia_search_s1.nextval,
             0,       FND_GLOBAL.user_id,
             SYSDATE,       FND_GLOBAL.user_id,
             SYSDATE,       FND_GLOBAL.conc_login_id,
             d.category_id  ,       old_organization_id ,
             old_inventory_item_id,       b.LANGUAGE,
             b.DESCRIPTION,       b.LONG_DESCRIPTION,
             ibe_search_setup_pvt.WriteToLob(b.description , b.long_description ,a.concatenated_segments),
             d.category_set_id ,  new_web_status
             from  mtl_system_items_tl b ,mtl_item_categories d, mtl_system_items_b_kfv a
             where b.INVENTORY_ITEM_ID = old_inventory_item_id
	     and   b.ORGANIZATION_ID   = old_organization_id
       and   d.category_set_id  = l_category_set_id
	     and   b.INVENTORY_ITEM_ID = d.INVENTORY_ITEM_ID
	     and   b.organization_id   = d.organization_id
	     and   d.INVENTORY_ITEM_ID = a.INVENTORY_ITEM_ID
	     and   d.organization_id   = a.organization_id
          and exists (select 1
                   from oe_system_parameters_all osp
                   where osp.master_organization_id = b.organization_id);

else
      insert into ibe_ct_imedia_search (IBE_CT_IMEDIA_SEARCH_ID
            , OBJECT_VERSION_NUMBER, CREATED_BY, CREATION_DATE
            , LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
            , CATEGORY_ID, ORGANIZATION_ID, INVENTORY_ITEM_ID
            , LANGUAGE, DESCRIPTION, LONG_DESCRIPTION, INDEXED_SEARCH
            , CATEGORY_SET_ID, WEB_STATUS)
            SELECT
             ibe_ct_imedia_search_s1.nextval,
             0,       FND_GLOBAL.user_id,
             SYSDATE,       FND_GLOBAL.user_id,
             SYSDATE,       FND_GLOBAL.conc_login_id,
             d.category_id  ,       old_organization_id ,
             old_inventory_item_id,       b.LANGUAGE,
             b.DESCRIPTION,       b.LONG_DESCRIPTION,
             ibe_search_setup_pvt.WriteToLob(b.description , b.long_description ,a.concatenated_segments),
             d.category_set_id ,  new_web_status
             from  mtl_system_items_tl b ,mtl_item_categories d, mtl_system_items_b_kfv a
             where b.INVENTORY_ITEM_ID = old_inventory_item_id
	     and   b.ORGANIZATION_ID   = old_organization_id
       --and   d.category_set_id  = l_category_set_id
	     and   b.INVENTORY_ITEM_ID = d.INVENTORY_ITEM_ID
	     and   b.organization_id   = d.organization_id
	     and   d.INVENTORY_ITEM_ID = a.INVENTORY_ITEM_ID
	     and   d.organization_id   = a.organization_id
          and exists (select 1
                   from oe_system_parameters_all osp
                   where osp.master_organization_id = b.organization_id);

  end if;

        END IF;
  ELSE
     -- Delete item from ibe_ct_imedia_search;
      ----dbms_output.put_line('deleting from ibe_ct_imedia_search');
      Delete from ibe_ct_imedia_search
      where INVENTORY_ITEM_ID = old_inventory_item_id
      and   ORGANIZATION_ID   = old_organization_id;
   END If;
  END IF;
 commit;
   ----dbms_output.put_line('Item_Update done.');
end Item_Updated;
-----------------------------------------------
--PROCEDURE CALLED ON DELETE IN ITEMS_TL
-----------------------------------------------

procedure ItemTL_Deleted(
old_inventory_item_id number,
old_organization_id   number,
old_language          varchar2)
is
begin

delete from  ibe_ct_imedia_search c
where        c.INVENTORY_ITEM_ID = old_inventory_item_id
and          c.LANGUAGE          = old_language
and          c.ORGANIZATION_ID   = old_organization_id ;


end ItemTL_Deleted;

-----------------------------------------------
--PROCEDURE CALLED ON UPDATE IN ITEMS_TL
--??????????????????????????????????????????????????????????????????????????????????
--question on how to take care of scenario when an item is deleted from 1 org
--and assigned to another org  is it an update operation or is it a 2 step
--delete/insert operation
-----------------------------------------------

procedure ItemTL_Updated(
old_inventory_item_id number,
old_organization_id number,
old_language varchar2,
new_language varchar2,
new_description varchar2,
new_long_description varchar2
)
is
begin

 update IBE_CT_IMEDIA_SEARCH g
 set
	g.language                = new_language ,
	g.LAST_UPDATE_DATE        = sysdate ,
        g.DESCRIPTION             = new_description ,
        g.LONG_DESCRIPTION        = new_long_description ,
        g.INDEXED_SEARCH        =  (select ibe_search_setup_pvt.WriteToLob(new_description , new_long_description,a.concatenated_segments)
                                    from mtl_system_items_kfv a
                                    where a.inventory_item_id = old_inventory_item_id
                                    and   a.organization_id   = old_organization_id
                                   )
   where g.INVENTORY_ITEM_ID    = old_inventory_item_id
   AND  g.organization_id       = old_organization_id
   AND  g.language              = old_language ;

end ItemTL_Updated;



-----------------------------------------------
--PROCEDURE CALLED ON INSERT IN ITEMS_TL
--HERE YOU NEED TO INSERT A NEW ROW INTO IMEDIA_SEARCH TABLE
-----------------------------------------------

procedure ItemTL_Inserted(
new_inventory_item_id number,
new_organization_id number,
new_language varchar2,
new_description varchar2,
new_long_description varchar2
)
is

 l_search_category_set varchar2(30);
 l_search_web_status VARCHAR2(30):= 'PUBLISHED';
 l_use_category_search VARCHAR2(30)	:= 'N ';
 l_insert_flag boolean :=false;
 l_item_exists Number:=0;
 l_temp number;

CURSOR c_check_section_item_csr (c_inventory_item_id number, c_organization_id number) is
select 1  from mtl_system_items_b item
where item.inventory_item_id =c_inventory_item_id
and item.organization_id=c_organization_id
and item.web_status='PUBLISHED' and
exists (select 1 from ibe_dsp_section_items sec_item
where sec_item.inventory_item_id=item.inventory_item_id
and organization_id=item.organization_id);

begin
----dbms_output.put_line('inputs:newInvItemId='||new_inventory_item_id
--||':newOrgId='||new_organization_id
--||':newlang='||new_language
--||':new_description='||new_description
--||':new_long_description='||new_long_description);

l_insert_flag := FALSE;
--Get IBE_SEARCH_CATEGORY_SET Profile value
l_use_category_search := FND_PROFILE.VALUE_specific('IBE_USE_CATEGORY_SEARCH',671,0,671);

----dbms_output.put_line('l_use_category_search='||l_use_category_search);

l_search_category_set := FND_PROFILE.VALUE_specific('IBE_SEARCH_CATEGORY_SET',671,0,671);

----dbms_output.put_line('l_search_category_set='||l_search_category_set);

IF l_search_category_set is not null then

   l_item_exists:=Item_In_CatSetId_profile(new_inventory_item_id,new_organization_id);
   --IF item is under the category_set_id specified by the profile_value THEN
   ----dbms_output.put_line('l_item_exists='||l_item_exists);

     IF l_item_exists >0 then
        l_insert_flag := TRUE;

     ELSE
       ---------check whether item associated to some section------
         IF  l_use_category_search='N' THEN --profile set for section search
               OPEN c_check_section_item_csr(new_inventory_item_id,new_organization_id);
               FETCH c_check_section_item_csr into l_temp;
               IF c_check_section_item_csr%FOUND then
                     l_insert_flag:=TRUE;
                ELSE
                    l_insert_flag:=FALSE;
                END IF;
               CLOSE c_check_section_item_csr;
          ELSE
             l_insert_flag:= FALSE;
          END IF;
      -----------------------------------
    END IF;

ELSE -- l_search_category_set is null ie ALL ----------------
   l_insert_flag := TRUE;
END IF;

IF (l_insert_flag) THEN

   ----dbms_output.put_line('l_insert_flag=true');
  --Get IBE_SEARCH_WEB_STATUS profile value
   l_search_web_status := FND_PROFILE.VALUE_specific('IBE_SEARCH_WEB_STATUS',671,0,671);

   ----dbms_output.put_line('l_search_web_status='||l_search_web_status);

   IF l_search_web_status = 'PUBLISHED' THEN
        ----dbms_output.put_line('inserting row , web status PUBLISHED');
        insert into ibe_ct_imedia_search (IBE_CT_IMEDIA_SEARCH_ID
        , OBJECT_VERSION_NUMBER, CREATED_BY, CREATION_DATE
        , LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
        , CATEGORY_ID, ORGANIZATION_ID, INVENTORY_ITEM_ID
        , LANGUAGE, DESCRIPTION, LONG_DESCRIPTION, INDEXED_SEARCH
        , CATEGORY_SET_ID, WEB_STATUS)
        SELECT
        ibe_ct_imedia_search_s1.nextval,
        0,       FND_GLOBAL.user_id,
        SYSDATE,       FND_GLOBAL.user_id,
        SYSDATE,       FND_GLOBAL.conc_login_id,
        c.category_id ,       new_organization_id ,
        new_inventory_item_id,       new_LANGUAGE,
        new_DESCRIPTION,       new_LONG_DESCRIPTION,
        ibe_search_setup_pvt.WriteToLob(new_description , new_long_description ,a.concatenated_segments),
        c.category_set_id   ,       b.web_status
        from  mtl_system_items_kfv a, mtl_system_items_b b, mtl_item_categories c
        where   b.INVENTORY_ITEM_ID = a.INVENTORY_ITEM_ID
        and   b.organization_id   = a.organization_id
        and   b.INVENTORY_ITEM_ID = new_inventory_item_id
        and   b.ORGANIZATION_ID   = new_organization_id
        and   a.INVENTORY_ITEM_ID = c.INVENTORY_ITEM_ID
        and   a.ORGANIZATION_ID   = c.organization_id
        and   b.web_status = 'PUBLISHED'
        and exists (select 1
                   from oe_system_parameters_all osp
                   where osp.master_organization_id = b.organization_id);


   ELSIF l_search_web_status = 'PUBLISHED_UNPUBLISHED' THEN
        ----dbms_output.put_line('inserting row , web status PUBLISHED UNPUBLISHED');
        insert into ibe_ct_imedia_search (IBE_CT_IMEDIA_SEARCH_ID
        , OBJECT_VERSION_NUMBER, CREATED_BY, CREATION_DATE
        , LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
        , CATEGORY_ID, ORGANIZATION_ID, INVENTORY_ITEM_ID
        , LANGUAGE, DESCRIPTION, LONG_DESCRIPTION, INDEXED_SEARCH
        , CATEGORY_SET_ID, WEB_STATUS)
        SELECT
        ibe_ct_imedia_search_s1.nextval,
        0,       FND_GLOBAL.user_id,
        SYSDATE,       FND_GLOBAL.user_id,
        SYSDATE,       FND_GLOBAL.conc_login_id,
        c.category_id ,       new_organization_id ,
        new_inventory_item_id,       new_LANGUAGE,
        new_DESCRIPTION,       new_LONG_DESCRIPTION,
        ibe_search_setup_pvt.WriteToLob(new_description , new_long_description ,a.concatenated_segments),
        c.category_set_id   ,       b.web_status
        from  mtl_system_items_kfv a, mtl_system_items_b b, mtl_item_categories c
        where   b.INVENTORY_ITEM_ID = a.INVENTORY_ITEM_ID
        and   b.organization_id   = a.organization_id
        and   b.INVENTORY_ITEM_ID = new_inventory_item_id
        and   b.ORGANIZATION_ID   = new_organization_id
        and   a.INVENTORY_ITEM_ID = c.INVENTORY_ITEM_ID
        and   a.ORGANIZATION_ID   = c.organization_id
        and   b.web_status IN ('PUBLISHED', 'UNPUBLISHED');
   ELSE
        ----dbms_output.put_line('inserting row , web status ALL');
        insert into ibe_ct_imedia_search (IBE_CT_IMEDIA_SEARCH_ID
        , OBJECT_VERSION_NUMBER, CREATED_BY, CREATION_DATE
        , LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
        , CATEGORY_ID, ORGANIZATION_ID, INVENTORY_ITEM_ID
        , LANGUAGE, DESCRIPTION, LONG_DESCRIPTION, INDEXED_SEARCH
        , CATEGORY_SET_ID, WEB_STATUS)
        SELECT
        ibe_ct_imedia_search_s1.nextval,
        0,       FND_GLOBAL.user_id,
        SYSDATE,       FND_GLOBAL.user_id,
        SYSDATE,       FND_GLOBAL.conc_login_id,
        c.category_id ,       new_organization_id ,
        new_inventory_item_id,       new_LANGUAGE,
        new_DESCRIPTION,       new_LONG_DESCRIPTION,
        ibe_search_setup_pvt.WriteToLob(new_description , new_long_description ,a.concatenated_segments),
        c.category_set_id   ,       b.web_status
        from  mtl_system_items_kfv a, mtl_system_items_b b, mtl_item_categories c
        where  b.INVENTORY_ITEM_ID = a.INVENTORY_ITEM_ID
        and   b.organization_id   = a.organization_id
        and   b.INVENTORY_ITEM_ID = new_inventory_item_id
        and   b.ORGANIZATION_ID   = new_organization_id
        and   a.INVENTORY_ITEM_ID = c.INVENTORY_ITEM_ID
        and   a.ORGANIZATION_ID   = c.organization_id
and exists (select 1
                   from oe_system_parameters_all osp
                   where osp.master_organization_id = b.organization_id);
   END IF;
END IF;
----dbms_output.put_line('END:ItemTL_Inserted');
end ItemTL_Inserted;


end IBE_Search_PVT;

/
