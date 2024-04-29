--------------------------------------------------------
--  DDL for Package Body MSC_BI2EBS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_BI2EBS_PKG" as
/*  $Header: MSCHBBEB.pls 120.8.12010000.4 2010/02/11 16:29:50 wexia ship $ */


/*
CREATE OR REPLACE TYPE MSC_HUB_ASCP_PARAM_REC AS OBJECT
(
plan_name  varchar2(20),
org_list MSC_HUB_ORG_LIST,
category_list MSC_HUB_CATEGORY_LIST,
res_group_list MSC_HUB_RES_GROUP_LIST,
res_list MSC_HUB_RES_LIST,
exp_group_list MSC_HUB_EXP_GROUP_LIST,
exp_list MSC_HUB_EXP_LIST,
item_list MSC_HUB_ITEM_LIST,
date_list MSC_HUB_DATE_LIST,
from_date date,
to_date date);

SELECT
HEADER_ID,
fnd_run_function.get_run_function_url(
     CAST(fnd_function.get_function_id('ISC_ORDINF_DETAILS_PMV') AS NUMBER),
     CAST( VALUEOF(NQ_SESSION.OLTP_EBS_RESP_APPL_ID) AS NUMBER),
     CAST( VALUEOF(NQ_SESSION.OLTP_EBS_RESP_ID) AS NUMBER),
     CAST( VALUEOF(NQ_SESSION.OLTP_EBS_SEC_GROUP_ID) AS NUMBER),
'HeaderId='||HEADER_ID||'&pFunctionName=ISC_ORDINF_DETAILS_PMV&pMode=NO&pageFunctionName=ISC_ORDINF_DETAILS_PMV',
     NULL) as ORDER_HEADER_ACTION_LINK_URL


*/



value_delimeter                                    constant varchar2(3):='%3B'; ---;
pair_delimeter                                     constant varchar2(3):='%2C';  --,

ascp_value_delimeter                                    constant varchar2(1):=';'; ---;
ascp_pair_delimeter                                     constant varchar2(1):=',';  --,

ASCP_WB_FUNC                       constant  varchar2(20):='MSCFNSCW-SCP';

WND                        constant  varchar2(10):='PHB_WND';
DMODE                          constant  varchar2(10):='PHB_MODE';

PLAN_ID                        constant  varchar2(10):='PHB_PLN';
ORG_ID                         constant  varchar2(10):='PHB_ORG';
CATEGORY_ID                    constant  varchar2(10):='PHB_CATE';
ITEM_ID                            constant  varchar2(10):='PHB_ITEM';
RESOURCE_GROUP_ID                  constant  varchar2(10):='PHB_RESGRP';
RESOURCE_ID                    constant  varchar2(10):='PHB_RES';
EXCEPTION_GROUP                    constant  varchar2(10):='PHB_EXGRP';
EXCEPTION_ID                       constant  varchar2(10):='PHB_EX';
DATE_LIST                      constant  varchar2(10):='PHB_DT';

FROM_DATE                      constant  varchar2(10):='PHB_DT1';
TO_DATE                        constant  varchar2(10):='PHB_DT2';

SPACE                          constant varchar2(1):=' ';
REPLACEMENT                    constant varchar2(1):='|';


function  get_ascp_launch_url(p_params in MSC_HUB_ASCP_PARAM_REC) return varchar2 is

l_plan_id number;
l_plan_name varchar2(100);

l_org_name_list MSC_HUB_ORG_LIST;
l_category_name_list MSC_HUB_CATEGORY_LIST;
l_item_name_list MSC_HUB_ITEM_LIST;

l_res_group_name_list MSC_HUB_RES_GROUP_LIST;
l_res_name_list MSC_HUB_RES_LIST;
l_exp_group_name_list MSC_HUB_EXP_GROUP_LIST;
l_exp_name_list MSC_HUB_EXP_LIST;

l_date_list MSC_HUB_DATE_LIST;
l_from_date varchar2(10);
l_to_date varchar2(10);

x_url  varchar2(500);
l_param_string  varchar2(400);
l_temp1 number;
l_temp2 number;
l_resp_id number;
l_appl_id number;
l_sec_group_id number;
l_wnd  varchar2(20);
l_mode number;

cursor c_plan_id(p_plan_run_name varchar2) is
  select plan_id from msc_plan_runs
  where plan_run_name = p_plan_run_name;

cursor c_org_id(p_org_name varchar2) is
  SELECT MTP.SR_INSTANCE_ID, MTP.SR_TP_ID
  from msc_trading_partners mtp
  where mtp.organization_code = p_org_name
  and mtp.partner_type=3;

cursor c_category_id(p_category_name varchar2) is
   select sr_category_id from msc_phub_categories_mv
   where CATEGORY_NAME = p_category_name
   and category_set_id = fnd_profile.value('MSC_HUB_CAT_SET_ID_1');

cursor c_item_id(p_plan_id number,p_item_name varchar2) is
   select unique inventory_item_id from msc_system_items
   where item_name=p_item_name
   and plan_id = p_plan_id;

cursor c_res_id (p_plan_id number, p_res_name varchar2) is
  SELECT unique MDR.RESOURCE_ID
  FROM MSC_DEPARTMENT_RESOURCES MDR, MFG_LOOKUPS ML1,MFG_LOOKUPS ML2
  where MDR.RESOURCE_CODE = p_res_name
  and   mdr.plan_id =p_plan_id
   and ML1.LOOKUP_CODE = nvl(MDR.BOTTLENECK_FLAG,2)
  AND ML1.LOOKUP_TYPE = 'SYS_YES_NO'
  AND ML2.LOOKUP_CODE = MDR.RESOURCE_TYPE
  AND ML2.LOOKUP_TYPE = 'BOM_RESOURCE_TYPE';

 cursor c_exp_id (p_exp_name varchar2) is
    SELECT lookup_code exception_type_id FROM mfg_lookups
    WHERE lookup_type = 'MRP_EXCEPTION_CODE_TYPE'
    and lookup_code not in (101,102,103,104)
    and meaning =p_exp_name;

begin

     l_plan_name        := p_params.plan_name;
     l_wnd          := p_params.wnd;

     l_org_name_list        := p_params.org_list;
     l_category_name_list   := p_params.category_list;
     l_item_name_list       := p_params.item_list;

     l_res_group_name_list  := p_params.res_group_list;
     l_res_name_list        := p_params.res_list;

     l_exp_group_name_list  := p_params.exp_group_list;
     l_exp_name_list        := p_params.exp_list;

     l_date_list        := p_params.date_list;
     l_from_date        := p_params.from_date;
     l_to_Date          := p_params.to_date;


    if(l_wnd = 'EXCEPTION') then l_mode:=4;
    elsif (l_wnd = 'ITEM') then l_mode:=2;
    elsif (l_wnd = 'RESOURCE') then l_mode:=3;
    elsif (l_wnd = 'SDA') then l_mode:=5;
    else  l_mode :=1;
    end if;


    l_param_string := DMODE || '=1' || ' ' || WND || '=' ||  l_mode;  --- note that parameter is separated by ' ' in form

    select FND_GLOBAL.RESP_ID, FND_GLOBAL.RESP_APPL_ID,FND_GLOBAL.SECURITY_GROUP_ID
    into  l_resp_id,l_appl_id,l_sec_group_id
    from dual;

     -----------------------------------------------------
     -- get plan_id from msc_plan_runs table
     ----------------------------------------------------

     open c_plan_id(l_plan_name);
     fetch c_plan_id into l_plan_id;
     close c_plan_id;

     l_param_string :=l_param_string || ' ' || PLAN_ID  || '=' ||  l_plan_id;

     -----------------------------------------------------
     -- get org id list
     -- org id = sr_instance_id,org_id
     ----------------------------------------------------
    if(l_org_name_list is not null) then
     for i in 1 .. l_org_name_list.count loop
         open c_org_id(l_org_name_list(i));
     fetch c_org_id into l_temp1,l_temp2;
     if (c_org_id%FOUND) then
       if (i = 1) then
        l_param_string :=l_param_string || ' ' || ORG_ID || '=' || '(' || l_temp1 || ascp_pair_delimeter ||  l_temp2 || ')' ;
       else
        l_param_string :=l_param_string || ascp_value_delimeter  || '(' ||
                                        l_temp1 || ascp_pair_delimeter ||  l_temp2 || ')';

       end if;
     end if;
     close c_org_id;
     end loop;
    end if;
     -----------------------------------------------------
     -- get category id
     ----------------------------------------------------
    if (l_category_name_list is not null) then
     for i in 1 .. l_category_name_list.count loop
         open c_category_id(l_category_name_list(i));
     fetch c_category_id into l_temp1;
     if (c_category_id%FOUND) then
       if (i = 1) then
        l_param_string :=l_param_string || ' ' || CATEGORY_ID || '=' || l_temp1 ;
       else
        l_param_string :=l_param_string || ascp_value_delimeter  || l_temp1;

       end if;
    end if;
    close c_category_id;
     end loop;
    end if;
     -----------------------------------------------------
     -- get item id
     ----------------------------------------------------
    if(l_item_name_list is not null) then
     for i in 1 .. l_item_name_list.count loop
         open c_item_id(l_plan_id,l_item_name_list(i));
     fetch c_item_id into l_temp1;
     if (c_item_id%FOUND) then
       if (i = 1) then
        l_param_string :=l_param_string || ' ' || ITEM_ID || '=' || l_temp1 ;
       else
        l_param_string :=l_param_string || ascp_value_delimeter  || l_temp1;

       end if;
     end if;
         close c_item_id;
     end loop;
   end if;

    ---------------------------------------------------------
    --- add resource group
    ------------------------------------------------------
    if (l_res_group_name_list  is not null) then
     for i in 1 .. l_res_group_name_list.count loop
         if (i = 1) then
        l_param_string :=l_param_string || ' ' || RESOURCE_GROUP_ID || '=' ||
                  replace(l_res_group_name_list(i),SPACE,REPLACEMENT) ;
     else
        l_param_string :=l_param_string || ascp_value_delimeter  || replace(l_res_group_name_list(i),SPACE,REPLACEMENT);

     end if;
     end loop;

    end if;
    --------------------------------------------------------
    --- add resource id
    ------------------------------------------------------
    if(l_res_name_list  is not null) then
     for i in 1 .. l_res_name_list.count loop
         open c_res_id(l_plan_id,l_res_name_list(i));
     fetch c_res_id into l_temp1;
     if (c_res_id%FOUND) then
       if (i = 1) then
        l_param_string :=l_param_string || ' ' || RESOURCE_ID || '=' || l_temp1 ;
       else
        l_param_string :=l_param_string || ascp_value_delimeter  || l_temp1;

       end if;
     end if;
     close c_res_id;
     end loop;
   end if;
    --------------------------------------------------------
    --- add exp group
    ------------------------------------------------------
    if (l_exp_group_name_list is not null) then
     for i in 1 .. l_exp_group_name_list.count loop
         if (i = 1) then
        l_param_string :=l_param_string || ' ' || EXCEPTION_GROUP || '=' ||
           replace(l_exp_group_name_list(i),SPACE,REPLACEMENT) ;
     else
        l_param_string :=l_param_string || ascp_value_delimeter  || replace(l_exp_group_name_list(i),SPACE,REPLACEMENT);

     end if;
     end loop;
    end if;
    --------------------------------------------------------
    --- add exp id
    ------------------------------------------------------
    if (l_exp_name_list is not null) then
     for i in 1 .. l_exp_name_list.count loop
         open c_exp_id(l_exp_name_list(i));
     fetch c_exp_id into l_temp1;
     if (c_exp_id%FOUND) then
       if (i = 1) then
        l_param_string :=l_param_string || ' ' || EXCEPTION_ID || '=' ||  l_temp1 ;
       else
        l_param_string :=l_param_string || ascp_value_delimeter  || l_temp1;

       end if;
     end if;
     close c_exp_id;
     end loop;
   end if;
    --------------------------------------------------------
    --- add date list
    ------------------------------------------------------
    if (l_date_list is not  null) then
     for i in 1 .. l_date_list.count loop
         if (i = 1) then
        l_param_string :=l_param_string || ' ' || DATE_LIST || '=' || l_date_list(i);
     else
        l_param_string :=l_param_string || ascp_value_delimeter  || l_date_list(i);

     end if;
     end loop;
    end if;
--------------------------------------------------------------------------------------
    if (l_from_date is not null) then
         l_param_string :=l_param_string || ' ' || FROM_DATE || '=' || l_from_date;
    end if;

    if (l_to_date is not null) then
         l_param_string :=l_param_string || ' ' || TO_DATE || '=' || l_to_date;
    end if;



    ----------------------------

   -- dbms_output.put_line('before=' || l_param_string);
    /* x_url :=fnd_run_function.get_run_function_url(fnd_function.get_function_id(ASCP_WB_FUNC),
                        l_appl_id,
                        l_resp_id,
                        l_sec_group_id,
                        l_param_string,
                        null);
   */
   return l_param_string;


end get_ascp_launch_url;





function  get_dmtr_launch_url(p_params in MSC_HUB_DMTR_PARAM_REC) return varchar2 is


l_comb    MSC_HUB_DMTR_COMB;
l_comb_list MSC_HUB_DMTR_COMB_LIST;
l_query_name varchar2(200);
l_temp1 number;
l_url_string varchar2(500);

TYPE DmtraCurType IS REF CURSOR;
c_remember_cur  DmtraCurType;
c_qid_cur   DmtraCurType;
c_lid_cur DmtraCurType;

l_sql_statement varchar2(512);
l_sql_qid varchar2(512);
l_sql_lid varchar2(512);

l_group_table_id varchar2(38);
l_gtable varchar2(100);
l_id_field varchar2(100);
l_data_field varchar2(100);
l_remember_id number;
l_schema varchar2(50) := 'DMTRA_TEMPLATE';
x_url varchar2(600);
j number;

begin

    begin
        select fnd_profile.value('MSD_DEM_SCHEMA') into l_schema from dual;
    exception
        when others then
            null;
    end;

    l_sql_qid :='select query_id from '||l_schema||'.queries where query_name=:1';
    l_sql_lid :='select group_table_id,gtable,id_field,data_field from '||l_schema||'.group_tables where table_label=:1';

    l_query_name    :=p_params.query_name;
    l_comb_list     :=p_params.comb_list;

    -------------------------------------------------------------------
    -- get the queryId
    -----------------------------------------------------------------

     open c_qid_cur for l_sql_qid using l_query_name;
     fetch c_qid_cur  into l_temp1;
     close c_qid_cur;

     l_url_string :='queryId=' || l_temp1;


     ----------------------------------------------------------------
     -- get each level/member pair
     -- in the format as combination=424,3;492,4
     --------------------------------------------------------------


   if (l_comb_list is not null) then
    for i in 1 .. l_comb_list.count loop
        l_comb :=l_comb_list(i);
    --dbms_output.put_line(l_comb.dmtr_level);
    open c_lid_cur for l_sql_lid using l_comb.dmtr_level;


        fetch c_lid_cur into l_group_table_id,l_gtable,l_id_field,l_data_field;


    --  now find out the member for the level
    if (c_lid_cur%FOUND) then
       l_sql_statement:='select ' || l_id_field || ' from '||l_schema||'.' || l_gtable ||
                      ' where ' || l_data_field  || '= :1' ;
       -- dbms_output.put_line(l_sql_statement);
           close c_lid_cur;
           if (i =1) then
              -- l_url_string := l_url_string || '%26combination=' ;
              l_url_string := l_url_string || '&combination=' ; -- bug 8632364
           else
              l_url_string := l_url_string || value_delimeter ;

           end if;
           j := 1;

          open c_remember_cur for l_sql_statement using l_comb.dmtr_member;

          loop

             fetch c_remember_cur into l_remember_id ;
         exit when c_remember_cur%notfound;
          -- dbms_output.put_line(c_remember_cur%rowcount);
         --  dbms_output.put_line(l_group_table_id || ',' || l_remember_id);
             -- dbms_output.put_line(l_url_string);

         if (j=1) then
            l_url_string :=l_url_string                    || l_group_table_id ||  pair_delimeter || l_remember_id;
         else
            l_url_string :=l_url_string || value_delimeter || l_group_table_id || pair_delimeter || l_remember_id;
         end if;
          j:=j+1;
          end loop;
           close c_remember_cur;
     end if;
       end loop;
     end if;
    /* x_url :=Fnd_profile.value('MSD_DEM_HOST_URL') || '/portal/prelogin.jsp?redirectUrl=partnerLogin.jsp?'
           || l_url_string || '&submitUrl=loginCheck.jsp&loginUrl=loginpage.jsp&source=0&component=sop&componentowner=yes';
     */

     -- dbms_output.put_line('before=' || l_url_string);
   return l_url_string;


end get_dmtr_launch_url;


end msc_bi2ebs_pkg;

/
