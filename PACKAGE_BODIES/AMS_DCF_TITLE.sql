--------------------------------------------------------
--  DDL for Package Body AMS_DCF_TITLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DCF_TITLE" AS
/* $Header: amsvdtlb.pls 115.23 2003/11/10 13:53:48 arvikuma ship $*/
--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below

FUNCTION get_currency (p_parameters IN varchar2 default null) return varchar2
IS
    vScaleByCode        varchar2(80);
    vScaleByMeaning     varchar2(80);
    vIn                 varchar2(80);
    vFor                varchar2(80);
    vCurrency           varchar2(80);

BEGIN
    vIn := ams_utility_pvt.get_lookup_meaning('AMS_IO_OTHER','IN');
    vFor := ams_utility_pvt.get_lookup_meaning('AMS_IO_OTHER','FOR');
    vCurrency := fnd_profile.VALUE('AMS_DEFAULT_CURR_CODE');
    vScaleByCode := jtfb_dcf.get_parameter_value(p_parameters, 'P_SCALE_BY');
    if (vScaleByCode <> '1') then
        select meaning into vScaleByMeaning from ams_lookups where lookup_type ='AMS_IO_SCALE_BY' and lookup_code = vScaleByCode;
    else
        vScaleByMeaning := '';
    end if;

    return (' (' ||vIn|| ' '||vScaleByMeaning|| ' '||vCurrency||') ' || vFor||' ');

EXCEPTION
WHEN OTHERS THEN
    return (' ');
    null;
END get_currency;

FUNCTION print_kpi_bin_title (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
is
    vPeriod         varchar2(80);
    xPeriod         varchar2(80);

BEGIN
    vPeriod := jtfb_dcf.get_parameter_value(p_parameters, 'P_PERIOD_TYPE');
    select to_char(start_date,'mm-dd') ||' to '|| to_char(end_date,'mm-dd') into xPeriod from bim_r_periods where calc_type = 'FIXED' and period_type = vPeriod;
    return (xPeriod);
    --return ('The data reported is for Region: ' || xRegion || ', Country: ' || xCountry || ', Business Unit: ' || xBusinessUnit || ', Activity Type: ' || xActivityType || ', Campaign Status: ' || xCampaignStatus || ' aggregated by ' || xAggregateBy);
EXCEPTION
WHEN OTHERS THEN
--   dbms_output.put_line(sqlerrm(sqlcode));
   null;
END print_kpi_bin_title;

-- Create a parameter for holding the report title.

FUNCTION print_kpi_report_title (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
is
    vContext         varchar2(80);
    xContext         varchar2(80);
    vRepName         varchar2(80);
    vPeriod         varchar2(80);
    xPeriod         varchar2(80);
    vFor            varchar2(80);
    vCompCode       varchar2(80);

BEGIN
    vCompCode := jtfb_dcf.get_parameter_value(p_parameters, 'DCF.componentCode');
    select
       meaning into vRepName
    from
       fnd_lookup_values
    where
       lookup_type= 'BIM_DBC_DCF_TITLES'
       and lookup_code = vCompCode
       and language = userenv('LANG');
    vContext := jtfb_dcf.get_parameter_value(p_parameters, 'pContext');
    vPeriod := jtfb_dcf.get_parameter_value(p_parameters, 'P_PERIOD_TYPE');
    vFor := ams_utility_pvt.get_lookup_meaning('AMS_IO_OTHER','FOR');
    select to_char(start_date,'mm-dd') ||' to '|| to_char(end_date,'mm-dd') into xPeriod from bim_r_periods where calc_type = 'FIXED' and period_type = vPeriod;

    return (vRepName || get_currency(p_parameters) || xPeriod);
EXCEPTION
WHEN OTHERS THEN
    return (vRepName);
--   dbms_output.put_line(sqlerrm(sqlcode));
   null;
END print_kpi_report_title;

FUNCTION print_hom_report_nc_title (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
IS
    vPeriod      varchar2(80);
    xRetString   varchar2(100);
    vRepName     varchar2(80);
    vFor         varchar2(80);
    vCompCode       varchar2(80);

BEGIN
    vCompCode := jtfb_dcf.get_parameter_value(p_parameters, 'DCF.componentCode');
    select
       meaning into vRepName
    from
       fnd_lookup_values
    where
       lookup_type= 'BIM_DBC_DCF_TITLES'
       and lookup_code = vCompCode
       and language = userenv('LANG');
    vPeriod := jtfb_dcf.get_parameter_value(p_parameters, 'P_PERIOD');
    --vRepName := jtfb_dcf.get_parameter_value(p_parameters, 'P_REPORT_NAME');
    vFor := ams_utility_pvt.get_lookup_meaning('AMS_IO_OTHER','FOR');
    xRetString := '';
    if (vPeriod is not NULL) then
        select substr(vPeriod,0,INSTR(vPeriod,'|')-1) into xRetString from dual;
        xRetString := ' '||vFor||' ' || xRetString;
    end if;
    return (vRepName || xRetString);

EXCEPTION
WHEN OTHERS THEN
--   dbms_output.put_line(sqlerrm(sqlcode));
return (vRepName);
   null;
END print_hom_report_nc_title;


FUNCTION print_hom_report_title (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
IS
    vPeriod      varchar2(80);
    xRetString   varchar2(100);
    vRepName     varchar2(80);
    --vCurrency    varchar2(80);
    vCompCode       varchar2(80);

BEGIN
    vCompCode := jtfb_dcf.get_parameter_value(p_parameters, 'DCF.componentCode');
    select
       meaning into vRepName
    from
       fnd_lookup_values
    where
       lookup_type= 'BIM_DBC_DCF_TITLES'
       and lookup_code = vCompCode
       and language = userenv('LANG');
    vPeriod := jtfb_dcf.get_parameter_value(p_parameters, 'P_PERIOD');
    --vRepName := jtfb_dcf.get_parameter_value(p_parameters, 'P_REPORT_NAME');
    xRetString := '';
    --select fnd_profile.VALUE('AMS_DEFAULT_CURR_CODE') into vCurrency from dual;
    if (vPeriod is not NULL) then
        select substr(vPeriod,0,INSTR(vPeriod,'|')-1) into xRetString from dual;
        --xRetString := ' - ' || xRetString;
    end if;
    --return (vRepName ||' (in '||vCurrency||')'|| xRetString);
    return (vRepName || get_currency(p_parameters) || xRetString);

EXCEPTION
WHEN OTHERS THEN
--   dbms_output.put_line(sqlerrm(sqlcode));
return (vRepName);
   null;
END print_hom_report_title;

FUNCTION print_reg_bin_title_kpi (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
is
    vRepName         varchar2(80);
    vDefRepName         varchar2(80);
    xRetString       varchar2(100);
    vIn              varchar2(80);
    vFor             varchar2(80);
    vCurrency        varchar2(80);
    vScaleByCode     varchar2(80);
    vScaleByMeaning  varchar2(80);
    vCompCode       varchar2(80);

BEGIN
    vCompCode := jtfb_dcf.get_parameter_value(p_parameters, 'DCF.componentCode');
    select
       meaning into vRepName
    from
       fnd_lookup_values
    where
       lookup_type= 'BIM_DBC_DCF_TITLES'
       and lookup_code = vCompCode
       and language = userenv('LANG');
    vIn := ams_utility_pvt.get_lookup_meaning('AMS_IO_OTHER','IN');
    vCurrency := fnd_profile.VALUE('AMS_DEFAULT_CURR_CODE');
    vScaleByCode := jtfb_dcf.get_parameter_value(p_parameters, 'P_SCALE_BY');
    --vRepName := jtfb_dcf.get_parameter_value(p_parameters, 'P_TITLE_NAME_KP');
    vDefRepName := 'Response to Lead';
    if (vScaleByCode <> '1') then
        select meaning into vScaleByMeaning from ams_lookups
         where lookup_type ='AMS_IO_SCALE_BY' and lookup_code = vScaleByCode;
    else
        vScaleByMeaning := '';
    end if;

    return (vRepName||' (' ||vIn|| ' '||vScaleByMeaning|| ' '||vCurrency||') ');
EXCEPTION
WHEN OTHERS THEN
return (vDefRepName);
   null;
END print_reg_bin_title_kpi;

FUNCTION print_reg_bin_title_mb (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
is
    vRepName         varchar2(80);
    vDefRepName         varchar2(80);
    xRetString       varchar2(100);
    vIn              varchar2(80);
    vFor             varchar2(80);
    vCurrency        varchar2(80);
    vScaleByCode     varchar2(80);
    vScaleByMeaning  varchar2(80);
    vCompCode       varchar2(80);

BEGIN
    vCompCode := jtfb_dcf.get_parameter_value(p_parameters, 'DCF.componentCode');
    select
       meaning into vRepName
    from
       fnd_lookup_values
    where
       lookup_type= 'BIM_DBC_DCF_TITLES'
       and lookup_code = vCompCode
       and language = userenv('LANG');
    vIn := ams_utility_pvt.get_lookup_meaning('AMS_IO_OTHER','IN');
    vCurrency := fnd_profile.VALUE('AMS_DEFAULT_CURR_CODE');
    vScaleByCode := jtfb_dcf.get_parameter_value(p_parameters, 'P_SCALE_BY');
    --vRepName := jtfb_dcf.get_parameter_value(p_parameters, 'P_TITLE_NAME_MB');
    vDefRepName := 'Marketing Budgets';
    if (vScaleByCode <> '1') then
        select meaning into vScaleByMeaning from ams_lookups
         where lookup_type ='AMS_IO_SCALE_BY' and lookup_code = vScaleByCode;
    else
        vScaleByMeaning := '';
    end if;

    return (vRepName||' (' ||vIn|| ' '||vScaleByMeaning|| ' '||vCurrency||') ');
EXCEPTION
WHEN OTHERS THEN
return (vDefRepName);
   null;
END print_reg_bin_title_mb;

FUNCTION print_reg_bin_title_ce (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
is
    vRepName         varchar2(80);
    vDefRepName         varchar2(80);
    xRetString       varchar2(100);
    vIn              varchar2(80);
    vFor             varchar2(80);
    vCurrency        varchar2(80);
    vScaleByCode     varchar2(80);
    vScaleByMeaning  varchar2(80);
    vCompCode       varchar2(80);

BEGIN
    vCompCode := jtfb_dcf.get_parameter_value(p_parameters, 'DCF.componentCode');
    select
       meaning into vRepName
    from
       fnd_lookup_values
    where
       lookup_type= 'BIM_DBC_DCF_TITLES'
       and lookup_code = vCompCode
       and language = userenv('LANG');
    vIn := ams_utility_pvt.get_lookup_meaning('AMS_IO_OTHER','IN');
    vCurrency := fnd_profile.VALUE('AMS_DEFAULT_CURR_CODE');
    vScaleByCode := jtfb_dcf.get_parameter_value(p_parameters, 'P_SCALE_BY');
    --vRepName := jtfb_dcf.get_parameter_value(p_parameters, 'P_TITLE_NAME_CE');
    vDefRepName := 'Campaign Effectiveness';
    if (vScaleByCode <> '1') then
        select meaning into vScaleByMeaning from ams_lookups
         where lookup_type ='AMS_IO_SCALE_BY' and lookup_code = vScaleByCode;
    else
        vScaleByMeaning := '';
    end if;

    return (vRepName||' (' ||vIn|| ' '||vScaleByMeaning|| ' '||vCurrency||') ');

EXCEPTION
WHEN OTHERS THEN
return (vDefRepName);
   null;
END print_reg_bin_title_ce;

FUNCTION print_reg_bin_title_ee (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
is
    vRepName         varchar2(80);
    vDefRepName         varchar2(80);
    xRetString       varchar2(100);
    vIn              varchar2(80);
    vFor             varchar2(80);
    vCurrency        varchar2(80);
    vScaleByCode     varchar2(80);
    vScaleByMeaning  varchar2(80);
    vCompCode       varchar2(80);

BEGIN
    vCompCode := jtfb_dcf.get_parameter_value(p_parameters, 'DCF.componentCode');
    select
       meaning into vRepName
    from
       fnd_lookup_values
    where
       lookup_type= 'BIM_DBC_DCF_TITLES'
       and lookup_code = vCompCode
       and language = userenv('LANG');
    vIn := ams_utility_pvt.get_lookup_meaning('AMS_IO_OTHER','IN');
    vCurrency := fnd_profile.VALUE('AMS_DEFAULT_CURR_CODE');
    vScaleByCode := jtfb_dcf.get_parameter_value(p_parameters, 'P_SCALE_BY');
    --vRepName := jtfb_dcf.get_parameter_value(p_parameters, 'P_TITLE_NAME_EE');
    vDefRepName := 'Event Effectiveness';
    if (vScaleByCode <> '1') then
        select meaning into vScaleByMeaning from ams_lookups
         where lookup_type ='AMS_IO_SCALE_BY' and lookup_code = vScaleByCode;
    else
        vScaleByMeaning := '';
    end if;

    return (vRepName||' (' ||vIn|| ' '||vScaleByMeaning|| ' '||vCurrency||') ');
EXCEPTION
WHEN OTHERS THEN
return (vDefRepName);
   null;
END print_reg_bin_title_ee;



FUNCTION print_reg_report_title (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
is
    vContext         varchar2(80);
    xContext         varchar2(80);
    vRepName         varchar2(80);
    vSource          varchar2(80);
    vCurrency        varchar2(80);
    xRem             varchar2(80);
    xYear            varchar2(80);
    xQtr             varchar2(80);
    xMonth           varchar2(80);
    xDisplayType     varchar2(80);
    xPeriod          varchar2(80);
    xRetString       varchar2(100);
    vDefPeriod       varchar2(80);
    vTo              varchar2(80);
    vCompCode       varchar2(80);



BEGIN
    vCompCode := jtfb_dcf.get_parameter_value(p_parameters, 'DCF.componentCode');
    select
       meaning into vRepName
    from
       fnd_lookup_values
    where
       lookup_type= 'BIM_DBC_DCF_TITLES'
       and lookup_code = vCompCode
       and language = userenv('LANG');
    vContext := jtfb_dcf.get_parameter_value(p_parameters, 'pContext');
    --vRepName := jtfb_dcf.get_parameter_value(p_parameters, 'P_REPORT_NAME');
      vSource := jtfb_dcf.get_parameter_value(p_parameters, 'P_BIN_NAME');
      if vSource not in  ('N','NOT_FOUND') then
	if vCompcode in ('AMS_REP_CAMP_BY_LEAD_OPPO','AMS_REP_CAMP_BY_BUDGET_AMT','AMS_REP_CAMPAIGNS_BY_ORDER','AMS_CAMP_BY_ACTIVITY') then
	  vSource :='AMS_BIN_CAMP_EFFECTIVENESS';
	elsif vCompcode in ('AMS_BUDGET_TOTAL_AMT','AMS_BUDGET_ACTIVITY','AMS_REP_BUD_BY_CAMPAIGN','AMS_REP_BUD_BY_BU','AMS_GRAPH_BGT_UTL_BY_BU','AMS_GRAPH_BGT_UTL_BY_CAT') then
          vSource :='AMS_BIN_MARKETING_BUDGETS';
	elsif vCompcode in ('AMS_REP_EVENT_BY_REGISTRAN','AMS_REP_EVENT_BY_LEAD_OPPO','AMS_REP_EVENT_BY_BUD_AMT','AMS_REP_EVENT_BY_EVENT_TYP') then
          vSource :='AMS_BIN_EVENT_EFFECTIVENES';
	elsif  vCompcode in ( 'AMS_REP_MARK_ACTI','AMS_REP_MARK_CAMP') then
           vSource :='AMS_BIN_MARKET_ACTIV';
	end if;
      end if;
   -- vSource := jtfb_dcf.get_parameter_value(p_parameters, 'P_BIN_NAME');
    vDefPeriod := jtfb_dcf.get_parameter_value(p_parameters, 'P_DEF_PERIOD');
    vTo := ams_utility_pvt.get_lookup_meaning('AMS_IO_OTHER','TO');

    xRetString := 'x';
    xDisplayType := 'Z';
    select fnd_profile.VALUE('AMS_DEFAULT_CURR_CODE') into vCurrency from dual;
    if (vDefPeriod is not NULL) then
       select substr(vDefPeriod,0,INSTR(vDefPeriod,'-',10)-1) into xRetString from dual;
       select year, qtr into xYear, xQtr
             from bim_r_fd_dim_sum_mv where year||'-'||qtr = xRetString and rownum < 2;
       xRetString := xQtr;
    end if;

    if (vContext is not NULL) then
       if (vSource = 'AMS_BIN_MARKETING_BUDGETS') then
           select year, qtr,month,display_type into xYear, xQtr, xMonth,xDisplayType
             from bim_r_fd_dim_sum_mv where year||'-'||qtr||'-'||month||'-'||display_type = vContext
             and rownum < 2;
           if (xDisplayType <> 'Z') then
               select to_char(start_date,fnd_profile.VALUE('ICX_DATE_FORMAT_MASK')) ||' ' ||vTo||' '||
                      to_char(end_date,fnd_profile.VALUE('ICX_DATE_FORMAT_MASK')) into xPeriod
                 from bim_r_periods where calc_type = 'ROLLING' and period_type = xDisplayType;
              xRetString :=  ' ' || xDisplayType || ' ('||xPeriod ||')';
           else
               xRetString := xYear;
               if (xQtr <> 'N') then
                  xRetString :=  xQtr;
               end if;
               if (xMonth <> 'N') then
                   xRetString :=  xMonth;
               end if;
           end if;
       elsif (vSource = 'AMS_BIN_MARKET_ACTIV') then
           select year, qtr,month,display_type into xYear, xQtr, xMonth,xDisplayType
             from bim_r_fd_dim_sum_mv where year||'-'||qtr||'-'||month||'-'||display_type = vContext
             and rownum < 2;
           if (xDisplayType <> 'Z') then
               select to_char(start_date,fnd_profile.VALUE('ICX_DATE_FORMAT_MASK')) ||' ' ||vTo||' '||
                      to_char(end_date,fnd_profile.VALUE('ICX_DATE_FORMAT_MASK')) into xPeriod
                 from bim_r_periods where calc_type = 'ROLLING' and period_type = xDisplayType;
              xRetString :=  ' ' || xDisplayType || ' ('||xPeriod ||')';
           else
               xRetString := xYear;
               if (xQtr <> 'N') then
                  xRetString :=  xQtr;
               end if;
               if (xMonth <> 'N') then
                   xRetString :=  xMonth;
               end if;
           end if;
       elsif (vSource = 'AMS_BIN_EVENT_EFFECTIVENES') then
           select year, qtr,month into xYear, xQtr, xMonth
             from BIM_R_EVEN_DIM_SUM_MV where year||'-'||qtr||'-'||month = vContext and rownum < 2;
               xRetString := xYear;
               if (xQtr <> 'N') then
                  xRetString :=  xQtr;
               end if;
               if (xMonth <> 'N') then
                   xRetString := xMonth;
               end if;
       elsif (vSource = 'AMS_BIN_CAMP_EFFECTIVENESS') then
           select year, qtr,month into xYear, xQtr, xMonth
             from BIM_R_CAMP_DIM_SUM_MV where year||'-'||qtr||'-'||month = vContext and rownum < 2;
               xRetString := xYear;
               if (xQtr <> 'N') then
                  xRetString :=  xQtr;
               end if;
               if (xMonth <> 'N') then
                   xRetString := xMonth;
               end if;
       end if;
    end if;
    --if (xRetString <> 'x') then
    --   xRetString := ' - '||xRetString;
    --else
    --   xRetString := '';
    --end if;
    --return (vRepName ||' (in '||vCurrency||')'|| xRetString);

    if (xRetString = 'x') then
       xRetString := '';
    end if;
    return (vRepName || get_currency(p_parameters) || xRetString);
EXCEPTION
WHEN OTHERS THEN
-- dbms_output.put_line(sqlerrm(sqlcode));
--return (vRepName ||' '|| xRetString );
return (vRepName);
   null;
END print_reg_report_title;

-- Here need to take care of the fourth parameter.
FUNCTION print_reg_incremental_title (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
is
    vContext         varchar2(80);
    vRepName         varchar2(80);
    xIncr            varchar2(80);
    xPeriod          varchar2(80);
    vCompCode       varchar2(80);

BEGIN
    vCompCode := jtfb_dcf.get_parameter_value(p_parameters, 'DCF.componentCode');
    select
       meaning into vRepName
    from
       fnd_lookup_values
    where
       lookup_type= 'BIM_DBC_DCF_TITLES'
       and lookup_code = vCompCode
       and language = userenv('LANG');
    vContext := jtfb_dcf.get_parameter_value(p_parameters, 'pContext');
    --vRepName := jtfb_dcf.get_parameter_value(p_parameters, 'P_REPORT_NAME');

    select substr(vContext,INSTR(vContext,'-',-1)+1) into xIncr from dual;

    select start_date ||'-'|| end_date into xPeriod from bim_r_periods where calc_type = 'ROLLING' and period_type = xIncr;

    return (vRepName||' '||xPeriod );
EXCEPTION
WHEN OTHERS THEN
--   dbms_output.put_line(sqlerrm(sqlcode));
   null;
END print_reg_incremental_title;



FUNCTION print_mktg_activities_title (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
is
    vPeriod    varchar2(80);
    vRepName  varchar2(80);
    xCount     varchar2(80);
    vCompCode       varchar2(80);

BEGIN
    vCompCode := jtfb_dcf.get_parameter_value(p_parameters, 'DCF.componentCode');
    select
       meaning into vRepName
    from
       fnd_lookup_values
    where
       lookup_type= 'BIM_DBC_DCF_TITLES'
       and lookup_code = vCompCode
       and language = userenv('LANG');
    vPeriod := jtfb_dcf.get_parameter_value(p_parameters, 'P_AGGREGATE_BY');
    --vReportName := jtfb_dcf.get_parameter_value(p_parameters, 'P_REP_NAME');
    if (vPeriod = 'INCREMENT') then
       select to_char(current_count_value,'999,999,999,999') into xCount from bim_r_camp_act_bin_mv a
       where a.aggregate_by = 'INCREMENT'
       and a.year is not null
       and a.qtr is not null
       and a.month is not null
       AND a.display_type is not null and rownum < 2;
    else
       select /*+ index_desc(A, BIM_R_CAMP_ACT_BIN_MV_N4) */
       TO_CHAR(A.current_count_value,'999,999,999,999') into xCount
       from BIM_R_CAMP_ACT_BIN_MV A
       where  A.AGGREGATE_BY = 'MONTH'  AND A.YEAR IS NOT NULL
       AND A.QTR IS NOT NULL AND A.MONTH IS NOT NULL
       AND A.DISPLAY_TYPE IS NOT NULL
       and rownum <2;
       --select to_char(a.cv,'999,999,999,999') into xCount
       --  from (select current_count_value cv from bim_r_camp_act_bin_mv a
       --          where a.aggregate_by = 'MONTH'
       --            and a.year is not null
       --            and a.qtr is not null
       --            and a.month is not null
       --            AND a.display_type is not null
       --            order by a.year desc, a.qtr desc, a.month_order desc) a
       -- where rownum < 2;
    end if;
    return (vRepName || ' - '|| xCount);

EXCEPTION
WHEN OTHERS THEN
--   dbms_output.put_line(sqlerrm(sqlcode));
    return (vRepName);
   null;
END print_mktg_activities_title;

FUNCTION print_currency(p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
is
    vRepName         varchar2(80);
    vIn              varchar2(80);
    vFor             varchar2(80);
    vCurrency        varchar2(80);
BEGIN
    vRepName := jtfb_dcf.get_parameter_value(p_parameters, 'P_REPORT_NAME');
    vIn := ams_utility_pvt.get_lookup_meaning('AMS_IO_OTHER','IN');
    vFor := ams_utility_pvt.get_lookup_meaning('AMS_IO_OTHER','FOR');
    vCurrency := fnd_profile.VALUE('AMS_DEFAULT_CURR_CODE');
    return (vRepName||' (' ||vIn|| ' '||vCurrency||') ' );

EXCEPTION
WHEN OTHERS THEN
--   dbms_output.put_line(sqlerrm(sqlcode));
    return (vRepName);
   null;
END print_currency;


FUNCTION print_reg_report_nc_title (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
is
    vContext         varchar2(80);
    xContext         varchar2(80);
    vRepName         varchar2(80);
    vSource          varchar2(80);
    xRem             varchar2(80);
    xYear            varchar2(80);
    xQtr             varchar2(80);
    xMonth           varchar2(80);
    xDisplayType     varchar2(80);
    xPeriod          varchar2(80);
    xRetString       varchar2(100);
    vDefPeriod       varchar2(80);
    vfor             varchar2(80);
    vTo              varchar2(80);
    vCompCode       varchar2(80);


BEGIN
    vCompCode := jtfb_dcf.get_parameter_value(p_parameters, 'DCF.componentCode');
    select
       meaning into vRepName
    from
       fnd_lookup_values
    where
       lookup_type= 'BIM_DBC_DCF_TITLES'
       and lookup_code = vCompCode
       and language = userenv('LANG');
    vContext := jtfb_dcf.get_parameter_value(p_parameters, 'pContext');
    --vRepName := jtfb_dcf.get_parameter_value(p_parameters, 'P_REPORT_NAME');
    vSource := jtfb_dcf.get_parameter_value(p_parameters, 'P_BIN_NAME');
    if vSource not in ('NOT_FOUND','N') then
	if	vCompCode in ('AMS_GRAPH_EVENT_BY_ATTEND','AMS_GRAPH_EVENT_BY_LEAD','AMS_REP_EVENT_BY_REGISTRAN') then
		vSource := 'AMS_BIN_EVENT_EFFECTIVENES';
	elsif  vCompCode in ('AMS_GRAPH_BGT_UTL_BY_BU','AMS_GRAPH_BGT_UTL_BY_CAT') then
		vSource :='AMS_BIN_MARKETING_BUDGETS';
	 elsif  vCompCode in ('AMS_GRAPH_CAMP_BY_LEADS','AMS_GRAPH_CAMP_BY_OPPOR') then
		vSource :='AMS_BIN_CAMP_EFFECTIVENESS';
         end if;
    end if;
    vDefPeriod := jtfb_dcf.get_parameter_value(p_parameters, 'P_DEF_PERIOD');
    vTo := ams_utility_pvt.get_lookup_meaning('AMS_IO_OTHER','TO');

    xRetString := 'x';
     if (vDefPeriod is not NULL) then
       select substr(vDefPeriod,0,INSTR(vDefPeriod,'-',10)-1) into xRetString from dual;
       select year, qtr into xYear, xQtr
             from bim_r_fd_dim_sum_mv where year||'-'||qtr = xRetString and rownum < 2;
       xRetString := xQtr;
    end if;

    if (vContext is not NULL) then
       if (vSource = 'AMS_BIN_MARKETING_BUDGETS') then
           select year, qtr,month,display_type into xYear, xQtr, xMonth,xDisplayType
             from bim_r_fd_dim_sum_mv where year||'-'||qtr||'-'||month||'-'||display_type = vContext
             and rownum < 2;
           if (xDisplayType <> 'Z') then
               select to_char(start_date,fnd_profile.VALUE('ICX_DATE_FORMAT_MASK')) ||' ' ||vTo||' '||
                      to_char(end_date,fnd_profile.VALUE('ICX_DATE_FORMAT_MASK')) into xPeriod
                 from bim_r_periods where calc_type = 'ROLLING' and period_type = xDisplayType;
              xRetString :=  ' ' || xDisplayType || ' ('||xPeriod ||')';
           else
               xRetString := xYear;
               if (xQtr <> 'N') then
                  xRetString :=  xQtr;
               end if;
               if (xMonth <> 'N') then
                   xRetString :=  xMonth;
               end if;
           end if;
       elsif (vSource = 'AMS_BIN_MARKET_ACTIV') then
           select year, qtr,month,display_type into xYear, xQtr, xMonth,xDisplayType
             from bim_r_fd_dim_sum_mv where year||'-'||qtr||'-'||month||'-'||display_type = vContext
             and rownum < 2;
           if (xDisplayType <> 'Z') then
               select to_char(start_date,fnd_profile.VALUE('ICX_DATE_FORMAT_MASK')) ||' ' ||vTo||' '||
                      to_char(end_date,fnd_profile.VALUE('ICX_DATE_FORMAT_MASK')) into xPeriod
                 from bim_r_periods where calc_type = 'ROLLING' and period_type = xDisplayType;
              xRetString :=  ' ' || xDisplayType || ' ('||xPeriod ||')';
           else
               xRetString := xYear;
               if (xQtr <> 'N') then
                  xRetString :=  xQtr;
               end if;
               if (xMonth <> 'N') then
                   xRetString :=  xMonth;
               end if;
           end if;
       elsif (vSource = 'AMS_BIN_EVENT_EFFECTIVENES') then
           select year, qtr,month into xYear, xQtr, xMonth
             from BIM_R_EVEN_DIM_SUM_MV where year||'-'||qtr||'-'||month = vContext and rownum < 2;
               xRetString := xYear;
               if (xQtr <> 'N') then
                  xRetString :=  xQtr;
               end if;
               if (xMonth <> 'N') then
                   xRetString := xMonth;
               end if;
       elsif (vSource = 'AMS_BIN_CAMP_EFFECTIVENESS') then
           select year, qtr,month into xYear, xQtr, xMonth
             from BIM_R_CAMP_DIM_SUM_MV where year||'-'||qtr||'-'||month = vContext and rownum < 2;
               xRetString := xYear;
               if (xQtr <> 'N') then
                  xRetString :=  xQtr;
               end if;
               if (xMonth <> 'N') then
                   xRetString := xMonth;
               end if;
       end if;
    end if;
    vFor := ams_utility_pvt.get_lookup_meaning('AMS_IO_OTHER','FOR');
    if (xRetString <> 'x') then
       xRetString := ' '||vfor||' '||xRetString;
    else
       xRetString := '';
    end if;
    return (vRepName || xRetString);
EXCEPTION
WHEN OTHERS THEN
return (vRepName);
null;

END print_reg_report_nc_title;

END;

/
