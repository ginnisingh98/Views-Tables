--------------------------------------------------------
--  DDL for Package Body JTF_RS_JSP_LOV_RECS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_JSP_LOV_RECS_PUB" AS
/* $Header: jtfrsjlb.pls 120.2.12010000.2 2009/04/30 07:23:20 avjha ship $ */

---------------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_RS_GET_RSC_NAMES_PUB
--    ---------------------------------------------------
--    PURPOSE
--      Get resource details for JSP LOV Screens
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      04/30/2001    EIHSU           Created
--    End of Comments
--
--
-- ***************************************************
--              GLOBAL VARIABLES
-- ***************************************************
   G_PKG_NAME      CONSTANT VARCHAR2(30):='JTF_RS_JSP_LOV_RECS_PUB';
   G_FILE_NAME     CONSTANT VARCHAR2(12):='jtfrsjlb.pls';

   G_NEW_LINE      CONSTANT  VARCHAR2(02) := FND_GLOBAL.Local_Chr(10);
   G_APPL_ID       CONSTANT  NUMBER       := FND_GLOBAL.Prog_Appl_Id;
   G_LOGIN_ID      CONSTANT  NUMBER       := FND_GLOBAL.Conc_Login_Id;
   G_PROGRAM_ID    CONSTANT  NUMBER       := FND_GLOBAL.Conc_Program_Id;
   G_USER_ID       CONSTANT  NUMBER       := FND_GLOBAL.User_Id;
   G_REQUEST_ID    CONSTANT  NUMBER       := FND_GLOBAL.Conc_Request_Id;
   G_APP_SHORT_NAME  CONSTANT VARCHAR2(15) := FND_GLOBAL.Application_Short_Name;

    --TYPE GenericCurTyp IS REF CURSOR;
    TYPE Lov_output_cur_type IS REF CURSOR ;--RETURN lov_output_rec_type;

    Procedure Get_LOV_Records
    (   p_range_low           IN NUMBER,
        p_range_high          IN NUMBER,
        p_record_group_name   IN VARCHAR2, -- name of the data to fetch
        p_in_filter_lov_rec   IN lov_input_rec_type,
        p_in_filter1          IN VARCHAR2,
        p_in_filter2          IN VARCHAR2,
        x_total_rows          OUT NOCOPY NUMBER,
        x_more_data_flag      OUT NOCOPY VARCHAR2,
        x_lov_ak_region       OUT NOCOPY VARCHAR2,
        x_result_tbl          OUT NOCOPY lov_output_tbl_type,
        x_ext_col_cnt         OUT NOCOPY NUMBER
    )
    IS
        -- Our generic cursor
        lov_output_cur      Lov_output_cur_type;
        --lov_output_cur      GenericCurTyp;

        -- filtering record type
        l_in_filter_lov_rec     lov_input_rec_type;

        -- Processed cursor inputs
        l_display_value    varchar2(2000);
        l_code_value       varchar2(100);
        l_aux_value1       varchar2(2000);
        l_aux_value2       varchar2(2000);
        l_aux_value3       varchar2(2000);

  /* Moved the initial assignment of below variables to inside begin */
        l_in_filter1     VARCHAR2(100);
        l_in_filter2     VARCHAR2(100);
        l_filter_number1    NUMBER;
        l_filter_number2    NUMBER;
        -- Cursor iteration variables
        l_index                      NUMBER := 0;
        l_range_high                 NUMBER;
        rec                          lov_output_rec_type;

  /* Moved the initial assignment of below variables to inside begin */
        l_new_low_value             number;
        l_new_high_value            number;
        l_total_count               number := 0;
        l_rec_set                   number := 1;
        l_start                     number := 0;
        l_more_data                 varchar2(1) ;
        l_org_id                    number;
        l_catset                    number;

    BEGIN

       l_in_filter1      := p_in_filter1;
       l_in_filter2      := p_in_filter2;
       l_new_low_value   := p_range_low ;
       l_new_high_value  := p_range_high ;

        l_in_filter_lov_rec := p_in_filter_lov_rec;
        x_ext_col_cnt := 0; -- setting to default count of extra columns

        IF (p_range_high < 0) THEN
           l_rec_set  := ABS(p_range_high);
        END IF;

        If p_record_group_name = 'RESOURCE_NAMES' then
            -- Resource Names
            x_lov_ak_region := 'JTF_RS_RES_LOV_REGION';
            -- input resource_name
            l_display_value := UPPER(l_in_filter_lov_rec.display_value) || '%';
            -- input resource_number
            l_aux_value1 := NVL(l_in_filter_lov_rec.aux_value1,'%');
            -- input resource_category
            l_aux_value2 := NVL(l_in_filter_lov_rec.aux_value2,'%');
            if l_in_filter1 is null then

                -- Get the total count if "Last" hyperlink is clicked
                IF (p_range_high < 0) THEN
                    SELECT count(*)
                      INTO l_total_count
                      from JTF_RS_RESOURCE_EXTNS_VL RES, FND_LOOKUPS FL
                     where  category like l_aux_value2
                       and resource_number like l_aux_value1
                       and UPPER(resource_name) like l_display_value
		       and trunc(sysdate) <= nvl(res.end_date_active,trunc(sysdate))
		       and FL.lookup_type = 'JTF_RS_RESOURCE_CATEGORY'
		       and fl.lookup_code = res.category ;

                    l_start := MOD(l_total_count, l_rec_set);

                    IF (l_start = 0) THEN
                        l_new_low_value  := l_total_count - l_rec_set + 1;
                        l_new_high_value := l_total_count ;
                    ELSE
                        l_new_low_value  := l_total_count - l_start + 1;
                        l_new_high_value := l_total_count ;
                    END IF;

                END IF;

                OPEN lov_output_cur FOR

                    SELECT resource_name            display_value,
                           to_char(resource_id)     code_value,
                           resource_number          aux_value1,
                           fl.lookup_code                 aux_value2,
                           fl.meaning              aux_value3,
                           null                    ext_value1,
                           null                    ext_value2,
                           null                    ext_value3,
                           null                    ext_value4,
                           null                    ext_value5
                    from JTF_RS_RESOURCE_EXTNS_VL RES, FND_LOOKUPS FL
                    where  category like l_aux_value2
                       and resource_number like l_aux_value1
                       and UPPER(resource_name) like l_display_value
		       and trunc(sysdate) <= nvl(res.end_date_active,trunc(sysdate))
		       and FL.lookup_type = 'JTF_RS_RESOURCE_CATEGORY'
		       and fl.lookup_code = res.category
                    order by resource_name;
            else
                l_filter_number1 := to_number(l_in_filter1);
               -- dbms_output.put_line('l_filter_number1: ' ||l_filter_number1);

                -- Get the total count if "Last" hyperlink is clicked
                IF (p_range_high < 0) THEN
                    SELECT count(*)
                      INTO l_total_count
                      from JTF_RS_RESOURCE_EXTNS_VL RES, FND_LOOKUPS FL
                      where resource_id <> l_filter_number1
                        and category like l_aux_value2
                        and resource_number like l_aux_value1
                        and UPPER(resource_name) like l_display_value
		        and trunc(sysdate) <= nvl(res.end_date_active,trunc(sysdate))
		        and FL.lookup_type = 'JTF_RS_RESOURCE_CATEGORY'
		        and fl.lookup_code = res.category ;

                    l_start := MOD(l_total_count, l_rec_set);

                    IF (l_start = 0) THEN
                        l_new_low_value  := l_total_count - l_rec_set + 1;
                        l_new_high_value := l_total_count ;
                    ELSE
                        l_new_low_value  := l_total_count - l_start + 1;
                        l_new_high_value := l_total_count ;
                    END IF;

                END IF;

                OPEN lov_output_cur FOR
                    SELECT resource_name            display_value,
                           to_char(resource_id)     code_value,
                           resource_number          aux_value1,
                           fl.lookup_code           aux_value2,
                           fl.meaning               aux_value3,
                           null                    ext_value1,
                           null                    ext_value2,
                           null                    ext_value3,
                           null                    ext_value4,
                           null                    ext_value5
                    from JTF_RS_RESOURCE_EXTNS_VL RES, FND_LOOKUPS FL
                    where resource_id <> l_filter_number1
                        and category like l_aux_value2
                        and resource_number like l_aux_value1
                        and UPPER(resource_name) like l_display_value
		        and trunc(sysdate) <= nvl(res.end_date_active,trunc(sysdate))
		        and FL.lookup_type = 'JTF_RS_RESOURCE_CATEGORY'
		        and fl.lookup_code = res.category
                    order by resource_name;
            end if;

        elsif p_record_group_name = 'MANAGER_NAMES' then
            -- Resource Names
            x_lov_ak_region := 'JTF_RS_MANAGER_LOV_REGION';
            -- input manager_name
            l_display_value := UPPER(l_in_filter_lov_rec.display_value) || '%';
            -- input org_id
            l_aux_value1 := l_in_filter_lov_rec.aux_value1;
            l_aux_value2 := l_in_filter_lov_rec.aux_value2;
            if l_in_filter1 is null then

                -- Get the total count if "Last" hyperlink is clicked
                IF (p_range_high < 0) THEN
                    SELECT count(*)
                      INTO l_total_count
                    from JTF_RS_RESOURCE_EXTNS_VL RES
                    where UPPER(resource_name) like l_display_value
                    and res.source_business_grp_id = to_number(l_aux_value2)
		    and trunc(sysdate) <= nvl(res.end_date_active,trunc(sysdate))
                    and res.category = 'EMPLOYEE' ;

                    l_start := MOD(l_total_count, l_rec_set);

                    IF (l_start = 0) THEN
                        l_new_low_value  := l_total_count - l_rec_set + 1;
                        l_new_high_value := l_total_count ;
                    ELSE
                        l_new_low_value  := l_total_count - l_start + 1;
                        l_new_high_value := l_total_count ;
                    END IF;

                END IF;

                OPEN lov_output_cur FOR
                    SELECT resource_name            display_value,
                           to_char(resource_id)     code_value,
                           source_number            aux_value1,
                           res.source_business_grp_id aux_value2,
                           null                     aux_value3,
                           null                    ext_value1,
                           null                    ext_value2,
                           null                    ext_value3,
                           null                    ext_value4,
                           null                    ext_value5
                    from JTF_RS_RESOURCE_EXTNS_VL RES
                    where UPPER(resource_name) like l_display_value
                    and res.source_business_grp_id = to_number(l_aux_value2)
		    and trunc(sysdate) <= nvl(res.end_date_active,trunc(sysdate))
                    and res.category = 'EMPLOYEE'
                    order by resource_name;
            else
                l_filter_number1 := to_number(l_in_filter1);
              --  dbms_output.put_line('l_filter_number1: ' ||l_filter_number1);

                -- Get the total count if "Last" hyperlink is clicked
                IF (p_range_high < 0) THEN
                    SELECT count(*)
                      INTO l_total_count
                    from JTF_RS_RESOURCE_EXTNS_VL RES
                    where resource_id <> l_filter_number1
                    and res.source_business_grp_id = to_number(l_aux_value2)
                    and UPPER(resource_name) like l_display_value
		    and trunc(sysdate) <= nvl(res.end_date_active,trunc(sysdate))
                    and res.category = 'EMPLOYEE' ;

                    l_start := MOD(l_total_count, l_rec_set);

                    IF (l_start = 0) THEN
                        l_new_low_value  := l_total_count - l_rec_set + 1;
                        l_new_high_value := l_total_count ;
                    ELSE
                        l_new_low_value  := l_total_count - l_start + 1;
                        l_new_high_value := l_total_count ;
                    END IF;

                END IF;

                OPEN lov_output_cur FOR
                    SELECT resource_name            display_value,
                           to_char(resource_id)     code_value,
                           source_number            aux_value1,
                           res.source_business_grp_id  aux_value2,
                           null                     aux_value3,
                           null                    ext_value1,
                           null                    ext_value2,
                           null                    ext_value3,
                           null                    ext_value4,
                           null                    ext_value5
                    from JTF_RS_RESOURCE_EXTNS_VL RES
                    where resource_id <> l_filter_number1
                    and res.source_business_grp_id = to_number(l_aux_value2)
                    and UPPER(resource_name) like l_display_value
		    and trunc(sysdate) <= nvl(res.end_date_active,trunc(sysdate))
                    and res.category = 'EMPLOYEE'
                    order by resource_name;
            end if;

        elsif p_record_group_name = 'GROUP_NAMES' then
            -- Group Names
            x_lov_ak_region := 'JTF_RS_GROUP_LOV_REGION';
            -- input group_name
            l_display_value := UPPER(l_in_filter_lov_rec.display_value) || '%';
            -- input group_number
            l_aux_value1 := l_in_filter_lov_rec.aux_value1 || '%';
            l_filter_number1 := to_number(nvl(l_in_filter1, '-99'));

                -- Get the total count if "Last" hyperlink is clicked
                IF (p_range_high < 0) THEN
                    SELECT count(*)
                      INTO l_total_count
                      from jtf_rs_groups_vl
                     where UPPER(group_name) like l_display_value
                       and group_number like l_aux_value1
                       and trunc(sysdate) <= NVL(end_date_active, sysdate)
                       and group_id <> l_filter_number1 ;

                    l_start := MOD(l_total_count, l_rec_set);

                    IF (l_start = 0) THEN
                        l_new_low_value  := l_total_count - l_rec_set + 1;
                        l_new_high_value := l_total_count ;
                    ELSE
                        l_new_low_value  := l_total_count - l_start + 1;
                        l_new_high_value := l_total_count ;
                    END IF;

                END IF;


            OPEN lov_output_cur FOR
                SELECT group_name, to_char(group_id), group_number, group_desc, null, null, null, null, null, null
                from jtf_rs_groups_vl
                where UPPER(group_name) like l_display_value
                    and group_number like l_aux_value1
                    and trunc(sysdate) <= NVL(end_date_active, sysdate)
                    and group_id <> l_filter_number1
                order by group_name;

        elsif p_record_group_name = 'ROLES' then
            -- Role Names
            x_lov_ak_region := 'JTF_RS_ROLES_LOV_REGION';
            -- input role_name
            l_display_value := UPPER(l_in_filter_lov_rec.display_value) || '%';
            -- input role_type_code
            if l_in_filter_lov_rec.aux_value1 is not null then
               l_aux_value1 := l_in_filter_lov_rec.aux_value1;
            else
               l_aux_value1 := '%';
            end if;
            -- input role_type_name
            if l_in_filter_lov_rec.aux_value2 is not null then
               l_aux_value2 := l_in_filter_lov_rec.aux_value2;
            else
               l_aux_value2 := '%';
            end if;
            x_ext_col_cnt := 4; -- 4 extra columns are used.

                -- Get the total count if "Last" hyperlink is clicked
                IF (p_range_high < 0) THEN
                    SELECT count(*)
                      INTO l_total_count
                      from jtf_rs_roles_vl jrr,
                           fnd_lookups flk
                     where UPPER(role_name) like l_display_value
                       and jrr.role_type_code like l_aux_value1
                       and flk.meaning like l_aux_value2
                       and flk.lookup_type = 'JTF_RS_ROLE_TYPE'
                       and flk.lookup_code = jrr.role_type_code
                       and nvl(jrr.active_flag, 'Y') <> 'N' ;

                    l_start := MOD(l_total_count, l_rec_set);

                    IF (l_start = 0) THEN
                        l_new_low_value  := l_total_count - l_rec_set + 1;
                        l_new_high_value := l_total_count ;
                    ELSE
                        l_new_low_value  := l_total_count - l_start + 1;
                        l_new_high_value := l_total_count ;
                    END IF;

                END IF;


            OPEN lov_output_cur FOR

                select jrr.role_name, to_char(jrr.role_id), jrr.role_type_code, flk.meaning, null, '%'||manager_flag||'%', '%'||admin_flag||'%', '%'||member_flag||'%', '%'||lead_flag||'%', null
                from jtf_rs_roles_vl jrr,
                    fnd_lookups flk
                where UPPER(role_name) like l_display_value
                    and jrr.role_type_code like l_aux_value1
                    and flk.meaning like l_aux_value2
                    and flk.lookup_type = 'JTF_RS_ROLE_TYPE'
                    and flk.lookup_code = jrr.role_type_code
                    and nvl(jrr.active_flag, 'Y') <> 'N'
                order by role_name;

        elsif p_record_group_name = 'JOB_TITLES' then
            -- Role Names
            x_lov_ak_region := 'JTF_RS_JOB_TITLES_LOV_REGION';
            -- input name
            l_display_value := UPPER(l_in_filter_lov_rec.display_value) || '%';
            -- filter input business_group_id
            l_aux_value1    := l_in_filter_lov_rec.aux_value1;

            if l_aux_value1 is null then

                -- Get the total count if "Last" hyperlink is clicked
                IF (p_range_high < 0) THEN
                    SELECT count(*)
                      INTO l_total_count
                      from per_jobs
                      where UPPER(name) like l_display_value
                        and sysdate >= date_from and sysdate <= NVL(date_to, sysdate);

                    l_start := MOD(l_total_count, l_rec_set);

                    IF (l_start = 0) THEN
                        l_new_low_value  := l_total_count - l_rec_set + 1;
                        l_new_high_value := l_total_count ;
                    ELSE
                        l_new_low_value  := l_total_count - l_start + 1;
                        l_new_high_value := l_total_count ;
                    END IF;

                END IF;

                OPEN lov_output_cur FOR
                    select name, to_char(job_id), to_char(business_group_id), null, null, null, null, null, null, null
                    from per_jobs
                    where UPPER(name) like l_display_value
                         and sysdate >= date_from and sysdate <= NVL(date_to, sysdate)
                    order by name;
            else

                -- Get the total count if "Last" hyperlink is clicked
                IF (p_range_high < 0) THEN
                    SELECT count(*)
                      INTO l_total_count
                      from per_jobs
                     where UPPER(name) like l_display_value
                       and business_group_id = l_aux_value1
                       and sysdate >= date_from and sysdate <= NVL(date_to, sysdate) ;

                    l_start := MOD(l_total_count, l_rec_set);

                    IF (l_start = 0) THEN
                        l_new_low_value  := l_total_count - l_rec_set + 1;
                        l_new_high_value := l_total_count ;
                    ELSE
                        l_new_low_value  := l_total_count - l_start + 1;
                        l_new_high_value := l_total_count ;
                    END IF;

                END IF;

                OPEN lov_output_cur FOR

                    select name, to_char(job_id), to_char(business_group_id), null, null, null, null, null, null, null
                    from per_jobs
                    where UPPER(name) like NVL(l_display_value, '%')
                         and business_group_id = l_aux_value1
                         and sysdate >= date_from and sysdate <= NVL(date_to, sysdate)
                    order by name;
            end if;
        elsif p_record_group_name = 'CATEGORIES' then
            -- categories region
            x_lov_ak_region := 'JTF_RS_CATEGORIES_LOV_REGION';
            -- input name
            l_display_value := UPPER(l_in_filter_lov_rec.display_value) || '%';

            l_catset :=  to_number(fnd_profile.value('CS_SR_DEFAULT_CATEGORY_SET'));
            if l_catset is null then
		-- Get the total count if "Last" hyperlink is clicked
		IF (p_range_high < 0) THEN
		    SELECT count(*)
		      INTO l_total_count
		      from jtf_rs_item_categories_v
		      where UPPER(category_name) like l_display_value
			and nvl(enabled_flag, 'Y') <> 'N'
		        and trunc(sysdate) < nvl(disable_date, sysdate);

		    l_start := MOD(l_total_count, l_rec_set);

		    IF (l_start = 0) THEN
			l_new_low_value  := l_total_count - l_rec_set + 1;
			l_new_high_value := l_total_count ;
		    ELSE
			l_new_low_value  := l_total_count - l_start + 1;
			l_new_high_value := l_total_count ;
		    END IF;

		END IF;

		OPEN lov_output_cur FOR
		    select distinct a.category_name, a.category_id, a.DESCRIPTION, null,null, null, null, null, null, null
                    from jtf_rs_item_categories_v a
		    where UPPER(a.category_name) like l_display_value
			and nvl(a.enabled_flag, 'Y') <> 'N'
		        and trunc(sysdate) < nvl(disable_date, sysdate)
		    order by a.category_name;
            else
		-- Get the total count if "Last" hyperlink is clicked
		IF (p_range_high < 0) THEN
		    SELECT count(*)
		      INTO l_total_count
		    from jtf_rs_item_categories_v a, mtl_category_set_valid_cats b
		    where UPPER(a.category_name) like NVL(l_display_value, '%')
		      and nvl(a.enabled_flag, 'Y') <> 'N'
                      and trunc(sysdate) < nvl(disable_date, sysdate)
                      and a.category_id = b.category_id
                      and b.category_set_id = l_catset;

		    l_start := MOD(l_total_count, l_rec_set);

		    IF (l_start = 0) THEN
			l_new_low_value  := l_total_count - l_rec_set + 1;
			l_new_high_value := l_total_count ;
		    ELSE
			l_new_low_value  := l_total_count - l_start + 1;
			l_new_high_value := l_total_count ;
		    END IF;

		END IF;
		OPEN lov_output_cur FOR
		    select distinct a.category_name, a.category_id, a.DESCRIPTION, null,null, null, null, null, null, null
		    from jtf_rs_item_categories_v a, mtl_category_set_valid_cats b
		    where UPPER(a.category_name) like l_display_value
		      and nvl(a.enabled_flag, 'Y') <> 'N'
                      and trunc(sysdate) < nvl(disable_date, sysdate)
                      and a.category_id = b.category_id
                      and b.category_set_id = l_catset
		    order by a.category_name;
            end if;
        elsif p_record_group_name = 'PRODUCTS' then
            -- Products
            x_lov_ak_region := 'JTF_RS_PRODUCTS_LOV_REGION';
            -- Product field
            l_display_value := UPPER(l_in_filter_lov_rec.display_value) || '%';

            l_org_id := jtf_resource_utl.get_inventory_org_id();

            l_aux_value1    := l_in_filter_lov_rec.aux_value1;

            if l_aux_value1 is null then

                IF (p_range_high < 0) THEN
                    SELECT count(*)
                      INTO l_total_count
                    from jtf_rs_products_v a
                    where UPPER(a.PRODUCT_NAME) like l_display_value
       			 and nvl(a.enabled_flag, 'Y') <> 'N'
                         and a.PRODUCT_ORG_ID = l_org_id;

                    l_start := MOD(l_total_count, l_rec_set);

                    IF (l_start = 0) THEN
                        l_new_low_value  := l_total_count - l_rec_set + 1;
                        l_new_high_value := l_total_count ;
                    ELSE
                        l_new_low_value  := l_total_count - l_start + 1;
                        l_new_high_value := l_total_count ;
                    END IF;

                END IF;

                OPEN lov_output_cur FOR
                    select a.PRODUCT_NAME, to_char(a.PRODUCT_ID), null, a.DESCRIPTION, null, null, null, null, null, null
                    from jtf_rs_products_v a
                    where UPPER(a.PRODUCT_NAME) like l_display_value
       			 and nvl(a.enabled_flag, 'Y') <> 'N'
                         and a.PRODUCT_ORG_ID = l_org_id
                    order by a.PRODUCT_NAME;
            else

                -- Get the total count if "Last" hyperlink is clicked
                IF (p_range_high < 0) THEN
                    SELECT count(*)
                      INTO l_total_count
                      from jtf_rs_products_v a
                     where UPPER(PRODUCT_NAME) like l_display_value
                       and PRODUCT_ORG_ID = l_org_id
                       and nvl(a.enabled_flag, 'Y') <> 'N'
                       and  exists(select null from mtl_item_categories c
		       where a.product_id = c.inventory_item_id
		       and c.organization_id = l_org_id
		       and c.category_id = l_aux_value1);

                    l_start := MOD(l_total_count, l_rec_set);

                    IF (l_start = 0) THEN
                        l_new_low_value  := l_total_count - l_rec_set + 1;
                        l_new_high_value := l_total_count ;
                    ELSE
                        l_new_low_value  := l_total_count - l_start + 1;
                        l_new_high_value := l_total_count ;
                    END IF;

                END IF;
                OPEN lov_output_cur FOR
                    select a.PRODUCT_NAME, to_char(a.PRODUCT_ID), null, a.DESCRIPTION, null, null, null, null, null, null
                      from jtf_rs_products_v a
                    where UPPER(a.PRODUCT_NAME) like l_display_value
                       and a.PRODUCT_ORG_ID = l_org_id
       		       and nvl(a.enabled_flag, 'Y') <> 'N'
                       and  exists(select null from mtl_item_categories c
		       where a.product_id = c.inventory_item_id
		       and c.organization_id = l_org_id
		       and c.category_id = l_aux_value1)
                    order by a.PRODUCT_NAME;
            end if;
        elsif p_record_group_name = 'PLATFORMS' then
            -- Products
            x_lov_ak_region := 'JTF_RS_PLATFORMS_LOV_REGION';
            -- Product field
            l_display_value := UPPER(l_in_filter_lov_rec.display_value) || '%';

            l_org_id := jtf_resource_utl.get_inventory_org_id();

            l_aux_value1    := l_in_filter_lov_rec.aux_value1;

            if l_aux_value1 is null then
                -- Get the total count if "Last" hyperlink is clicked
                IF (p_range_high < 0) THEN
                    SELECT count(*)
                      INTO l_total_count
                      from jtf_rs_platforms_v a
                     where UPPER(a.PLATFORM_NAME) like l_display_value
                       and a.platform_org_id = l_org_id;

                    l_start := MOD(l_total_count, l_rec_set);

                    IF (l_start = 0) THEN
                        l_new_low_value  := l_total_count - l_rec_set + 1;
                        l_new_high_value := l_total_count ;
                    ELSE
                        l_new_low_value  := l_total_count - l_start + 1;
                        l_new_high_value := l_total_count ;
                    END IF;

                END IF;

                OPEN lov_output_cur FOR
                    select a.PLATFORM_NAME, to_char(a.PLATFORM_ID), to_char(a.category_id), a.DESCRIPTION, null, null, null, null, null, null
                    from jtf_rs_platforms_v a
                    where UPPER(a.PLATFORM_NAME) like l_display_value
                       and a.platform_org_id = l_org_id
                   order by a.PLATFORM_NAME;
            else
                -- Get the total count if "Last" hyperlink is clicked
                IF (p_range_high < 0) THEN
                    SELECT count(*)
                      INTO l_total_count
                      from jtf_rs_platforms_v a
                     where UPPER(a.PLATFORM_NAME) like l_display_value
                       and a.category_id = l_aux_value1
                       and a.platform_org_id = l_org_id;

                    l_start := MOD(l_total_count, l_rec_set);

                    IF (l_start = 0) THEN
                        l_new_low_value  := l_total_count - l_rec_set + 1;
                        l_new_high_value := l_total_count ;
                    ELSE
                        l_new_low_value  := l_total_count - l_start + 1;
                        l_new_high_value := l_total_count ;
                    END IF;

                END IF;

                OPEN lov_output_cur FOR
                    select a.PLATFORM_NAME, to_char(a.PLATFORM_ID), to_char(a.category_id), a.DESCRIPTION, null, null, null, null, null, null
                    from jtf_rs_platforms_v a
                    where UPPER(a.PLATFORM_NAME) like l_display_value
                       and a.category_id = l_aux_value1
                       and a.platform_org_id = l_org_id
                   order by a.PLATFORM_NAME;
            end if;
        elsif p_record_group_name = 'PROBLEM_CODES' then
            -- Problem codes region
            x_lov_ak_region := 'JTF_RS_PROBLEM_CODE_LOV_REGION';
            -- input name
            l_display_value := UPPER(l_in_filter_lov_rec.display_value) || '%';

	    -- Get the total count if "Last" hyperlink is clicked
	    IF (p_range_high < 0) THEN
		SELECT count(*)
		  INTO l_total_count
		  from jtf_rs_problem_codes_v
		  where UPPER(PROBLEM_NAME) like l_display_value
       			 AND enabled_flag = 'Y'
                         AND trunc(sysdate) between trunc(nvl(start_date_active, sysdate)) and
                                 nvl(end_date_active, sysdate);

		l_start := MOD(l_total_count, l_rec_set);

		IF (l_start = 0) THEN
		    l_new_low_value  := l_total_count - l_rec_set + 1;
		    l_new_high_value := l_total_count ;
		ELSE
		    l_new_low_value  := l_total_count - l_start + 1;
		    l_new_high_value := l_total_count ;
		END IF;

	    END IF;

	    OPEN lov_output_cur FOR
		select a.PROBLEM_NAME, a.PROBLEM_CODE, a.DESCRIPTION, null,null, null, null, null, null, null
		from jtf_rs_problem_codes_v a
		where UPPER(a.PROBLEM_NAME) like l_display_value
                     AND a.enabled_flag = 'Y'
                     AND trunc(sysdate) between trunc(nvl(a.start_date_active, sysdate)) and
                                 nvl(a.end_date_active, sysdate)
		order by a.PROBLEM_NAME;
        elsif p_record_group_name = 'COMPONENTS' then
            -- Products
            x_lov_ak_region := 'JTF_RS_COMPONENTS_LOV_REGION';
            -- Product field
            l_display_value := UPPER(l_in_filter_lov_rec.display_value) || '%';
            -- filter input product id
            l_aux_value1    := l_in_filter_lov_rec.aux_value1;

            l_org_id := jtf_resource_utl.get_inventory_org_id();

            if l_aux_value1 is null then

                OPEN lov_output_cur FOR
                    select null, null, null, null, null, null, null, null, null, null
                    from dual
                    where 'Y' = 'N';
            else
		IF (p_range_high < 0) THEN
		    SELECT count(*)
		      INTO l_total_count
		    from jtf_rs_components_v a
		    where UPPER(a.COMPONENT_NAME) like l_display_value
                       and a.product_org_id = l_org_id
		       and a.product_id = l_aux_value1;

		    l_start := MOD(l_total_count, l_rec_set);

		    IF (l_start = 0) THEN
			l_new_low_value  := l_total_count - l_rec_set + 1;
			l_new_high_value := l_total_count ;
		    ELSE
			l_new_low_value  := l_total_count - l_start + 1;
			l_new_high_value := l_total_count ;
		    END IF;

		END IF;

                OPEN lov_output_cur FOR
                    select a.COMPONENT_NAME, to_char(a.COMPONENT_ID), to_char(a.product_id), a.DESCRIPTION, null, null, null, null, null, null
                    from jtf_rs_components_v a
                    where UPPER(a.COMPONENT_NAME) like l_display_value
                       and a.product_id = l_aux_value1
                       and a.product_org_id = l_org_id
                    order by a.COMPONENT_NAME;
            end if;
        elsif p_record_group_name = 'PRODUCT_PROBLEM_CODES' then
            -- Products
            x_lov_ak_region := 'JTF_RS_PROBLEM_CODE_LOV_REGION';
            -- Product field
            l_display_value := UPPER(l_in_filter_lov_rec.display_value) || '%';
            -- filter input product id
            l_aux_value1    := l_in_filter_lov_rec.aux_value1;

            l_org_id := jtf_resource_utl.get_inventory_org_id();

            if l_aux_value1 is null then
                OPEN lov_output_cur FOR
                    ' select null, null, null, null, null, null, null, null, null, null '||
		    ' from dual '||
                    ' where 1 = 2 ';
            else
		IF (p_range_high < 0) THEN
                    EXECUTE IMMEDIATE
		    ' SELECT count(*) '||
		    ' from cs_sr_prob_code_mapping_detail a, jtf_rs_problem_codes_v b '||
                    ' where UPPER(b.PROBLEM_NAME) like :1 '||
                      ' and nvl(b.enabled_flag, ''Y'') <> ''N'' '||
                      ' and a.ORGANIZATION_ID = :2 '||
                      ' and a.inventory_item_id = :3 '||
                      ' and a.problem_code = b.problem_code '
		      INTO l_total_count
                      USING  l_display_value ,l_org_id, l_aux_value1;

		    l_start := MOD(l_total_count, l_rec_set);

		    IF (l_start = 0) THEN
			l_new_low_value  := l_total_count - l_rec_set + 1;
			l_new_high_value := l_total_count ;
		    ELSE
			l_new_low_value  := l_total_count - l_start + 1;
			l_new_high_value := l_total_count ;
		    END IF;

		END IF;
                OPEN lov_output_cur FOR
                    ' select b.PROBLEM_NAME, a.PROBLEM_CODE, to_char(a.inventory_item_id), b.DESCRIPTION, null, null, null, null, null, null ' ||
		    ' from cs_sr_prob_code_mapping_detail a, jtf_rs_problem_codes_v b '||
                    ' where UPPER(b.PROBLEM_NAME) like :1 '||
                      ' and nvl(b.enabled_flag, ''Y'') <> ''N'' '||
                      ' and a.ORGANIZATION_ID = :2 '||
                      ' and a.inventory_item_id = :3 '||
                      ' and a.problem_code = b.problem_code '||
                    ' order by b.PROBLEM_NAME '
                USING l_display_value, l_org_id, l_aux_value1;
            end if;
        elsif p_record_group_name = 'SUPPORT_SITES' then
            -- Support site Names
            x_lov_ak_region := 'JTF_RS_SUPPORT_SITE_LOV_REGION';
            -- input Support site address 1
            l_display_value := UPPER(l_in_filter_lov_rec.display_value) || '%';
            l_filter_number1 := to_number(nvl(l_in_filter1, '-99'));

                -- Get the total count if "Last" hyperlink is clicked
                IF (p_range_high < 0) THEN
                    SELECT count(*)
                    INTO l_total_count
                    FROM hz_party_sites p, hz_locations loc, hz_party_site_uses psu
                    WHERE UPPER(loc.address1) like l_display_value
                    AND p.party_site_id = psu.party_site_id
                    AND psu.site_use_type = 'SUPPORT_SITE'
                    AND p.location_id = loc.location_id;

                    l_start := MOD(l_total_count, l_rec_set);

                    IF (l_start = 0) THEN
                        l_new_low_value  := l_total_count - l_rec_set + 1;
                        l_new_high_value := l_total_count ;
                    ELSE
                        l_new_low_value  := l_total_count - l_start + 1;
                        l_new_high_value := l_total_count ;
                    END IF;

                END IF;


            OPEN lov_output_cur FOR
                SELECT loc.address1, to_char(p.party_site_id), loc.city, null, null, null, null, null, null, null
                FROM hz_party_sites p, hz_locations loc, hz_party_site_uses psu
                WHERE UPPER(loc.address1) like l_display_value
                AND p.party_site_id = psu.party_site_id
                AND psu.site_use_type = 'SUPPORT_SITE'
                AND p.location_id = loc.location_id
                ORDER BY loc.address1;

        else
            --dbms_output.put_line('Invalid record group name specified ');

                -- Get the total count if "Last" hyperlink is clicked
                IF (p_range_high < 0) THEN
                    SELECT count(*)
                      INTO l_total_count
                      FROM dual;

                    l_start := MOD(l_total_count, l_rec_set);

                    IF (l_start = 0) THEN
                        l_new_low_value  := l_total_count - l_rec_set + 1;
                        l_new_high_value := l_total_count ;
                    ELSE
                        l_new_low_value  := l_total_count - l_start + 1;
                        l_new_high_value := l_total_count ;
                    END IF;

                END IF;

            OPEN lov_output_cur FOR
                select 'display_value', 'code_value', 'aux_value1', 'aux_value2', 'aux_value3', null, null, null, null, null
                from dual;
        end if;

        ----------------------------------------------
        -- Loop dynamic cursor to output table type
        ----------------------------------------------
       	x_total_rows := 0;
        l_range_high := l_new_high_value + 1;

        loop
            fetch lov_output_cur into rec;
            IF (x_total_rows = l_range_high) then
                x_more_data_flag := 'Y' ;
            ELSE
              IF ((x_total_rows <> l_range_high) OR lov_output_cur%notfound ) THEN
                x_more_data_flag := 'N' ;
              END IF;
            END IF;
            exit when x_total_rows = l_range_high;
            exit when lov_output_cur%notfound;

            x_total_rows := x_total_rows + 1;
            if (x_total_rows between l_new_low_value and l_new_high_value) OR
                (p_range_high = -1) then
                l_index := l_index + 1;
                x_result_tbl(l_index) := rec;
             end if;
        end loop;
        close lov_output_cur;

    END Get_LOV_Records;

END JTF_RS_JSP_LOV_RECS_PUB;

/
