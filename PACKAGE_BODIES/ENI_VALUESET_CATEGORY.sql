--------------------------------------------------------
--  DDL for Package Body ENI_VALUESET_CATEGORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_VALUESET_CATEGORY" AS
/* $Header: ENIITCTB.pls 115.26 2004/03/12 09:23:37 sbag noship $  */

g_error  boolean:= false;
g_errbuf  varchar2(10000);
g_warn boolean:= false;
g_count number;
l_vbh_catset_id number;
--

--
-- Purpose: Main Procedure to control the flow and handle concurrent manager variables

procedure      ENI_POPULATE_MAIN
  ( Errbuf    out NOCOPY Varchar2,
    retcode   out NOCOPY Varchar2)
is

begin

    FND_FILE.PUT_NAMES('enivalcat.log','enivalcat.out',fnd_profile.value('EDW_LOGFILE_DIR'));
    g_error := eni_validate_structure;

    if g_error = true then
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in Validation ');
        FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
        Errbuf:=g_errbuf;
        retcode:=2;
    else
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Validation complete');
        FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
        eni_populate_category;

        if g_warn = true then
           Errbuf:=g_errbuf;
           retcode:=1;
        end if;

        if g_error = true then
           Errbuf:=g_errbuf;
           retcode:=2;
        end if;
    end if;

end ENI_POPULATE_MAIN;



function ENI_VALIDATE_STRUCTURE return boolean
is
    l_struct_code number;
    l_application_column varchar(10);
    l_enabled_flag varchar2(1);
    l_flex_value_set_id number;
    invalid_segment exception;
    segment_not_enabled exception;
    value_set_null exception;

begin

    -- get vbh category set

    BEGIN
      select category_set_id into l_vbh_catset_id
       from mtl_default_category_sets
      where functional_area_id = 11;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
       l_vbh_catset_id := 1000000006;
    END;

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Category set id is:' || l_vbh_catset_id);

    -- Check to see if the structure asscociated with the category set is PRODUCT_CATEGORIES --
    begin
        select id_flex_num into l_struct_code
          from fnd_id_flex_structures a, mtl_category_sets_b b
         where a.id_flex_num=b.structure_id
           and b.category_set_id = l_vbh_catset_id
           and id_flex_structure_code='PRODUCT_CATEGORIES';

     fnd_file.put_line(fnd_file.log, 'Structure is: ' || l_struct_code);
    exception
        when NO_DATA_FOUND then
             FND_FILE.PUT_LINE(FND_FILE.LOG,'Error: The flex structure associated with this category set is not PRODUCT_CATEGORIES');
             g_error:=true;
             goto end_block;
    end;


    -- Check to see if segment1 associated with the structure is valid  --

    select application_column_name, enabled_flag, to_number(flex_value_set_id)
      into l_application_column, l_enabled_flag, l_flex_value_set_id
      from fnd_id_flex_segments
     where application_id = 401
       and id_flex_code = 'MCAT'
       and enabled_flag = 'Y'
       and id_flex_num = l_struct_code;

     fnd_file.put_line(fnd_file.log, 'Flexvalue set id ' || l_flex_value_set_id);

    if l_application_column <> 'SEGMENT1' then
       raise invalid_segment;
    elsif l_flex_value_set_id is null then
       raise value_set_null;
    end if;



    return g_error;

    << end_block >>
       null;

    exception
         when INVALID_SEGMENT then
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Error: The segment associated with this category set is not SEGMENT1');
              g_error:=true;
              return g_error;
         when VALUE_SET_NULL then
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Error: Value set associated with this category set is null');
              g_error:=true;
              return g_error;
         when NO_DATA_FOUND then
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Error: There is no SEGMENT associated with PRODUCT_CATEGORIES category set OR it is disabled');
              g_error:=true;
              return g_error;
         when TOO_MANY_ROWS then
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Error: More than 1 SEGMENT is associated with PRODUCT_CATEGORIES category set');
              g_error:=true;
              return g_error;
         when OTHERS then
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Error: ' || sqlerrm);
              g_error:=true;
              return g_error;

end; -- Procedure to validate structure

FUNCTION get_flex_value_set_id(p_appl_id varchar2, p_id_flex_code Varchar2, p_vbh_catset_id number) RETURN number is
   l_flex_value_set_id number;
   l_struct_id NUMBER;
   l_count_segments NUMBER;
begin

   select structure_id into l_struct_id
     from mtl_category_sets_b
    where category_set_id = p_vbh_catset_id;

   select count(flex_value_set_id)
     into l_count_segments
     from fnd_id_flex_segments
    where application_id = p_appl_id
      and id_flex_code = p_id_flex_code
      and enabled_flag = 'Y'
      and id_flex_num = l_struct_id;


   if l_count_segments = 1 then

         select flex_value_set_id into l_flex_value_set_id
         from fnd_id_flex_segments
        where application_id =  p_appl_id
          and id_flex_code = p_id_flex_code
          and enabled_flag = 'Y'
          and id_flex_num = l_struct_id;
   else
      l_flex_value_set_id := null;
   end if;

   return l_flex_value_set_id;

 exception
    when no_data_found then
        return null;
    when others then
        raise;
end get_flex_value_set_id;



-- Purpose: Procedure to look at a valueset and populate the Financial
-- Reporting Category Set with categories.

procedure ENI_POPULATE_CATEGORY
is


    l_value INV_ITEM_CATEGORY_PUB.CATEGORY_REC_TYPE;
    l_return_status    VARCHAR2(10000);
    l_errorcode        NUMBER;
    l_msg_count        NUMBER := 0;
    l_msg_data         VARCHAR2(10000);
    l_category_rec     INV_ITEM_CATEGORY_PUB.CATEGORY_REC_TYPE;
    l_category_id      NUMBER;
    -- l_vbh_catset_id    NUMBER;
    l_control   NUMBER;
    l_mult_flag  VARCHAR2(1);
    l_struct_code number;
    l_data varchar2(10000);
    l_msg_index_out varchar2(10000);
    l_count number :=0;
    l_catg_upd number := 0;
    multiple_cat_allowed exception;
    control_org exception;
    l_value_set_id number;


--  Get all the values from the valueset attached to the category set "Product Classification"
    cursor c1(l_value_set_id number) is
    select /*+ first_rows */ val.FLEX_VALUE_MEANING l_segment1,
           val.DESCRIPTION l_description,
           val.SUMMARY_FLAG l_summary_flag,
           val.ENABLED_FLAG l_enabled_flag,
           val.START_DATE_ACTIVE l_start_date_active,
           val.END_DATE_ACTIVE l_end_date_active,
           mtb.category_id category_id,
           cat.STRUCTURE_ID l_structure_id,
           1 update_flag -- Update Flag to indicate updateable records
      from FND_FLEX_VALUES_VL val, --FND_ID_FLEX_SEGMENTS seg,
           MTL_CATEGORY_SETS cat, MTL_CATEGORIES_B mtb, MTL_CATEGORIES_TL mtl
     where  val.FLEX_VALUE_SET_ID = l_value_set_id -- seg.FLEX_VALUE_SET_ID
      -- and  seg.ID_FLEX_CODE='MCAT'
      -- and seg.APPLICATION_ID = '401'
      -- and seg.APPLICATION_COLUMN_NAME ='SEGMENT1'
      -- and seg.ID_FLEX_NUM=cat.STRUCTURE_ID
       and cat.CATEGORY_SET_ID = l_vbh_catset_id
       and cat.structure_id = mtb.structure_id
       and mtb.segment1 = val.flex_value_meaning
       and mtl.category_id = mtb.category_id
       and (to_date(to_char(val.last_update_date,'DD/MM/YYYY HH:MI'),'DD/MM/YYYY HH:MI')> to_date(to_char(mtb.last_update_date,'DD/MM/YYYY HH:MI'),'DD/MM/YYYY HH:MI')
            or mtl.description <> val.description
            or mtb.end_date_active <> val.end_date_active)
    union all
    select val.FLEX_VALUE_MEANING l_segment1,
           val.DESCRIPTION l_description,
           val.SUMMARY_FLAG l_summary_flag,
           val.ENABLED_FLAG l_enabled_flag,
           val.START_DATE_ACTIVE l_start_date_active,
           val.END_DATE_ACTIVE l_end_date_active,
           to_number(null),
           cat.STRUCTURE_ID l_structure_id,
           0 -- Insert Flag to indicate a new node
      from FND_FLEX_VALUES_VL val,-- FND_ID_FLEX_SEGMENTS seg,
           MTL_CATEGORY_SETS cat
     where  val.FLEX_VALUE_SET_ID = l_value_set_id -- seg.FLEX_VALUE_SET_ID
       -- and  seg.ID_FLEX_CODE='MCAT'
       -- and seg.APPLICATION_ID = '401'
       -- and seg.APPLICATION_COLUMN_NAME ='SEGMENT1'
       -- and seg.ID_FLEX_NUM=cat.STRUCTURE_ID
       and cat.CATEGORY_SET_ID = l_vbh_catset_id
       and not exists(select category_id from mtl_categories_b
               where structure_id = cat.structure_id
                 and segment1 = val.flex_value_meaning);

begin


  -- Go thru the cursor and insert every value as a category in the category set

   begin
      select FLEX_VALUE_SET_ID
        into l_value_set_id
        from FND_ID_FLEX_SEGMENTS
       where APPLICATION_ID = '401'
         and ID_FLEX_CODE = 'MCAT'
         and APPLICATION_COLUMN_NAME = 'SEGMENT1'
         and ID_FLEX_NUM = (select STRUCTURE_ID
                              from MTL_CATEGORY_SETS_B
                             where CATEGORY_SET_ID = l_vbh_catset_id)
         and ENABLED_FLAG = 'Y';

     exception
        when no_data_found then
           FND_FILE.PUT_LINE(FND_FILE.LOG,'Error: The segment associated with
 the default category set is not SEGMENT1');
           g_error:=true;
           goto end_block;
    end;

    FOR c1_rec IN c1(l_value_set_id) LOOP

            l_count:=l_count+1;
            l_category_rec.structure_id :=c1_rec.l_structure_id ;
            l_category_rec.segment1 := c1_rec.l_segment1;
            l_category_rec.description := c1_rec.l_description;
            l_category_rec.summary_flag := c1_rec.l_summary_flag;
            l_category_rec.enabled_flag := c1_rec.l_enabled_flag;
            l_category_rec.start_date_active := c1_rec.l_start_date_active;
            l_category_rec.end_date_active := c1_rec.l_end_date_active;
            l_category_rec.disable_date := c1_rec.l_end_date_active;

            fnd_msg_pub.initialize;

            if c1_rec.update_flag = 1 then
               l_category_rec.category_id := c1_rec.category_id;

               FND_FILE.PUT_LINE(FND_FILE.LOG,'Selected node for update: '||c1_rec.l_segment1);
               INV_ITEM_CATEGORY_PUB.Update_Category(
                                        p_api_version=>1,
                                        x_return_status =>l_return_status,
                                        x_errorcode=> l_errorcode ,
                                        x_msg_count=> l_msg_count,
                                        x_msg_data=> l_msg_data,
                                        p_category_rec =>l_category_rec
                                        );
            else

               FND_FILE.PUT_LINE(FND_FILE.LOG,'Selected node for insert: '|| c1_rec.l_segment1);
               INV_ITEM_CATEGORY_PUB.Create_Category (p_api_version=>1,
                                        x_return_status =>l_return_status,
                                        x_errorcode=> l_errorcode ,
                                        x_msg_count=> l_msg_count,
                                        x_msg_data=> l_msg_data,
                                        p_category_rec =>l_category_rec,
                                        x_category_id =>l_category_id);
            end if;

            if l_msg_count > 0 then
               FND_MSG_PUB.Get(p_msg_index=>fnd_msg_pub.G_LAST,p_encoded=>FND_API.G_FALSE, p_msg_index_out=>l_msg_index_out, p_data=>l_data);
               FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in insert/update of node' );
               FND_FILE.PUT_LINE(FND_FILE.LOG,substrb(l_data,1,1000));
               FND_FILE.PUT_LINE(FND_FILE.LOG,substrb(l_data,1001,1000));
               FND_FILE.PUT_LINE(FND_FILE.LOG,' ' );

               g_warn:=true;
            else
               FND_FILE.PUT_LINE(FND_FILE.LOG,'Node committed to database ' );
               FND_FILE.PUT_LINE(FND_FILE.LOG,' ' );
            end if;

        end loop;

        -- If there are no values in the value set then raise exception

      if l_count =0 then
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'No nodes were updated or inserted. This could be because there were no changes in the valueset since the last time it was updated or there are no values defined in the hierarchy');
         g_count := l_count;
      end if;


      <<end_block>>
          null;

    exception
        when others then
            g_errbuf:= 'Error in Category Population'||sqlerrm;
--            dbms_output.put_line('Error in Category Population'||sqlerrm);
            g_error:=true;
            raise;
    end;

 end;

/
