--------------------------------------------------------
--  DDL for Package Body BIV_DBI_PARAM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIV_DBI_PARAM_PKG" as
/* $Header: bivsrvrparb.pls 120.0 2005/05/24 18:11:52 appldev noship $ */

function get_params( p_region_code varchar2 default null )
  return varchar2 as

  l_basic_parameters varchar2(2000);

begin

  l_basic_parameters :=
        '&AS_OF_DATE='        || fnd_date.date_to_chardate(TRUNC(sysdate)) ||
        case
          when get_def_time_per like '%FII_ROLLING_WEEK%' then
            '&FII_ROLLING_WEEK=' || get_def_time_per
          when get_def_time_per like '%FII_ROLLING_MONTH%' then
            '&FII_ROLLING_MONTH=' || get_def_time_per
          when get_def_time_per like '%FII_ROLLING_QTR%' then
            '&FII_ROLLING_QTR=' || get_def_time_per
          when get_def_time_per like '%FII_ROLLING_YEAR%' then
            '&FII_ROLLING_YEAR=' || get_def_time_per
        end ||
        case
          when get_def_time_comp like '%YEARLY%' then
            '&YEARLY='         || get_def_time_comp
          else
            '&SEQUENTIAL='     || get_def_time_comp
        end ||
        -- note that "All" needs to be in mxed case to work correctly
        '&REQUESTTYPE=All' ||
        '&ENI_ITEM_VBH_CAT=All';

  -- The following was added to show only unresolved service requests on the page
  if( p_region_code IN ('BIV_DBI_UNR_BAK_TBL' ,'BIV_DBI_UNR_BAK_DBN_TRD' ,'BIV_DBI_UNR_BAK_TRD'))
  then
       l_basic_parameters :=  l_basic_parameters ||
        '&BIV_RES_STATUS=N';
  end if;

  case
    when p_region_code like '%TRD%' then
      return
        l_basic_parameters ||
        '&VIEW_BY=' || get_def_time_per;

    when p_region_code like '%TBL%' then
      return
        l_basic_parameters ||
        '&VIEW_BY=' || 'SEVERITY+SEVERITY';

    when p_region_code like '%KPI%' then
      return
        l_basic_parameters ||
        '&VIEW_BY=' || 'BIV_REQUEST_TYPE+REQUESTTYPE';
    when p_region_code like '%PARAM%' then
      return
        l_basic_parameters;

    else
      return
        l_basic_parameters;

  end case;

  return '&AS_OF_DATE=' || fnd_date.date_to_chardate(TRUNC(sysdate));

end get_params;

function get_def_time_per
  return varchar2 as

begin

  return 'TIME+FII_ROLLING_MONTH';

end get_def_time_per;

function get_def_time_comp
  return varchar2 as

begin

  return 'TIME_COMPARISON_TYPE+SEQUENTIAL';

end get_def_time_comp;

end biv_dbi_param_pkg;

/
