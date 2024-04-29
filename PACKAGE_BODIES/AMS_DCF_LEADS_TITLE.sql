--------------------------------------------------------
--  DDL for Package Body AMS_DCF_LEADS_TITLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DCF_LEADS_TITLE" AS
/* $Header: amsvldsb.pls 115.3 2002/09/26 01:24:37 snallapa ship $*/
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


FUNCTION print_kpi_bin_title (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
is
    vPeriod         varchar2(80);
    xPeriod         varchar2(80);

BEGIN
    vPeriod := jtfb_dcf.get_parameter_value(p_parameters, 'P_PERIOD');
    select to_char(start_date,'mm-dd') ||' to '|| to_char(end_date,'mm-dd') into xPeriod from bim_r_periods where calc_type = 'FIXED' and period_type = vPeriod;
    return (xPeriod);
EXCEPTION
WHEN OTHERS THEN
   null;
END print_kpi_bin_title;

-- Create a parameter for holding the report title.

FUNCTION print_kpi_report_title (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
is
    vContext        varchar2(80);
    xContext        varchar2(80);
    vRepName        varchar2(80);
    vPeriod         varchar2(80);
    xPeriod         varchar2(80);
    vFor            varchar2(80);
    vCompCode       varchar2(80);

BEGIN
    vCompCode := jtfb_dcf.get_parameter_value(p_parameters,'DCF.componentCode');
    select
       meaning into vRepName
    from
       fnd_lookup_values
    where
       lookup_type= 'BIM_DBC_DCF_TITLES'
       and lookup_code = vCompCode
       and language = userenv('LANG');
    vContext := jtfb_dcf.get_parameter_value(p_parameters, 'pContext');
    -- vRepName := jtfb_dcf.get_parameter_value(p_parameters, 'P_REPORT_NAME');
    vPeriod := jtfb_dcf.get_parameter_value(p_parameters, 'P_PERIOD');
    vFor := ams_utility_pvt.get_lookup_meaning('AMS_IO_OTHER','FOR');
    select to_char(start_date,'mm-dd') ||' to '|| to_char(end_date,'mm-dd') into xPeriod from bim_r_periods where calc_type = 'FIXED' and period_type = vPeriod;

    return (vRepName||' '||vFor||' '|| xPeriod);
EXCEPTION
WHEN OTHERS THEN
    return (vRepName);
   null;
END print_kpi_report_title;

FUNCTION print_reg_bin_title (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
is
    vRepName         varchar2(80);
    xRetString       varchar2(100);
    vIn              varchar2(80);
    vScaleByCode     varchar2(80);
    vScaleByMeaning  varchar2(80);
    vCompCode       varchar2(80);

BEGIN
    vCompCode := jtfb_dcf.get_parameter_value(p_parameters,'DCF.componentCode');
    select
       meaning into vRepName
    from
       fnd_lookup_values
    where
       lookup_type= 'BIM_DBC_DCF_TITLES'
       and lookup_code = vCompCode
       and language = userenv('LANG');
    vIn := ams_utility_pvt.get_lookup_meaning('AMS_IO_OTHER','IN');
    vScaleByCode := jtfb_dcf.get_parameter_value(p_parameters, 'P_SCALE_BY');
    --vRepName := jtfb_dcf.get_parameter_value(p_parameters, 'P_BIN_NAME');
    if (vScaleByCode <> '1') then
        select meaning into vScaleByMeaning from ams_lookups
         where lookup_type ='AMS_IO_SCALE_BY' and lookup_code = vScaleByCode;
    else
        vScaleByMeaning := '';
    end if;

    return (vRepName||' (' ||vIn|| ' '||vScaleByMeaning||') ');
EXCEPTION
WHEN OTHERS THEN
return (vRepName);
   null;
END print_reg_bin_title;


FUNCTION print_reg_bin_title_ls (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
is
    vRepName         varchar2(80);
    xRetString       varchar2(100);
    vIn              varchar2(80);
    vScaleByCode     varchar2(80);
    vScaleByMeaning  varchar2(80);
    vCompCode       varchar2(80);

BEGIN
    vCompCode := jtfb_dcf.get_parameter_value(p_parameters,'DCF.componentCode');
    select
       meaning into vRepName
    from
       fnd_lookup_values
    where
       lookup_type= 'BIM_DBC_DCF_TITLES'
       and lookup_code = vCompCode
       and language = userenv('LANG');
    vIn := ams_utility_pvt.get_lookup_meaning('AMS_IO_OTHER','IN');
    vScaleByCode := jtfb_dcf.get_parameter_value(p_parameters, 'P_SCALE_BY');
    --vRepName := jtfb_dcf.get_parameter_value(p_parameters, 'P_BIN_NAME_LS');
    if (vScaleByCode <> '1') then
        select meaning into vScaleByMeaning from ams_lookups
         where lookup_type ='AMS_IO_SCALE_BY' and lookup_code = vScaleByCode;
       return (vRepName||' (' ||vIn|| ' '||vScaleByMeaning||') ');
    else
       return (vRepName);
    end if;

EXCEPTION
WHEN OTHERS THEN
return (vRepName);
   null;
END print_reg_bin_title_ls;

FUNCTION print_reg_bin_title_lq (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
is
    vRepName         varchar2(80);
    xRetString       varchar2(100);
    vIn              varchar2(80);
    vScaleByCode     varchar2(80);
    vScaleByMeaning  varchar2(80);
    vCompCode       varchar2(80);

BEGIN
    vCompCode := jtfb_dcf.get_parameter_value(p_parameters,'DCF.componentCode');
    select
       meaning into vRepName
    from
       fnd_lookup_values
    where
       lookup_type= 'BIM_DBC_DCF_TITLES'
       and lookup_code = vCompCode
       and language = userenv('LANG');
    vIn := ams_utility_pvt.get_lookup_meaning('AMS_IO_OTHER','IN');
    vScaleByCode := jtfb_dcf.get_parameter_value(p_parameters, 'P_SCALE_BY');
    --vRepName := jtfb_dcf.get_parameter_value(p_parameters, 'P_BIN_NAME_LQ');
    if (vScaleByCode <> '1') then
        select meaning into vScaleByMeaning from ams_lookups
         where lookup_type ='AMS_IO_SCALE_BY' and lookup_code = vScaleByCode;
         return (vRepName||' (' ||vIn|| ' '||vScaleByMeaning||') ');
    else
        return (vRepName);
    end if;

EXCEPTION
WHEN OTHERS THEN
return (vRepName);
   null;
END print_reg_bin_title_lq;

FUNCTION print_reg_bin_title_ws (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
is
    vRepName         varchar2(80);
    xRetString       varchar2(100);
    vIn              varchar2(80);
    vScaleByCode     varchar2(80);
    vScaleByMeaning  varchar2(80);
    vCompCode       varchar2(80);

BEGIN
    vCompCode := jtfb_dcf.get_parameter_value(p_parameters,'DCF.componentCode');
    select
       meaning into vRepName
    from
       fnd_lookup_values
    where
       lookup_type= 'BIM_DBC_DCF_TITLES'
       and lookup_code = vCompCode
       and language = userenv('LANG');
    vIn := ams_utility_pvt.get_lookup_meaning('AMS_IO_OTHER','IN');
    vScaleByCode := jtfb_dcf.get_parameter_value(p_parameters, 'P_SCALE_BY');
    --vRepName := jtfb_dcf.get_parameter_value(p_parameters, 'P_BIN_NAME_WS');
    if (vScaleByCode <> '1') then
        select meaning into vScaleByMeaning from ams_lookups
         where lookup_type ='AMS_IO_SCALE_BY' and lookup_code = vScaleByCode;
         return (vRepName||' (' ||vIn|| ' '||vScaleByMeaning||') ');
    else
        return (vRepName);
    end if;

EXCEPTION
WHEN OTHERS THEN
return (vRepName);
   null;
END print_reg_bin_title_ws;

FUNCTION print_reg_bin_title_is (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
is
    vRepName         varchar2(80);
    xRetString       varchar2(100);
    vIn              varchar2(80);
    vScaleByCode     varchar2(80);
    vScaleByMeaning  varchar2(80);
    vCompCode       varchar2(80);

BEGIN
    vCompCode := jtfb_dcf.get_parameter_value(p_parameters,'DCF.componentCode');
    select
       meaning into vRepName
    from
       fnd_lookup_values
    where
       lookup_type= 'BIM_DBC_DCF_TITLES'
       and lookup_code = vCompCode
       and language = userenv('LANG');
    vIn := ams_utility_pvt.get_lookup_meaning('AMS_IO_OTHER','IN');
    vScaleByCode := jtfb_dcf.get_parameter_value(p_parameters, 'P_SCALE_BY');
    --vRepName := jtfb_dcf.get_parameter_value(p_parameters, 'P_BIN_NAME_IS');
    if (vScaleByCode <> '1') then
        select meaning into vScaleByMeaning from ams_lookups
         where lookup_type ='AMS_IO_SCALE_BY' and lookup_code = vScaleByCode;
         return (vRepName||' (' ||vIn|| ' '||vScaleByMeaning||') ');
    else
        return (vRepName);
    end if;

EXCEPTION
WHEN OTHERS THEN
return (vRepName);
   null;
END print_reg_bin_title_is;

FUNCTION print_reg_bin_title_wr (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
is
    vRepName         varchar2(80);
    xRetString       varchar2(100);
    vIn              varchar2(80);
    vScaleByCode     varchar2(80);
    vScaleByMeaning  varchar2(80);
    vCompCode       varchar2(80);

BEGIN
    vCompCode := jtfb_dcf.get_parameter_value(p_parameters,'DCF.componentCode');
    select
       meaning into vRepName
    from
       fnd_lookup_values
    where
       lookup_type= 'BIM_DBC_DCF_TITLES'
       and lookup_code = vCompCode
       and language = userenv('LANG');
    vIn := ams_utility_pvt.get_lookup_meaning('AMS_IO_OTHER','IN');
    vScaleByCode := jtfb_dcf.get_parameter_value(p_parameters, 'P_SCALE_BY');
    --vRepName := jtfb_dcf.get_parameter_value(p_parameters, 'P_BIN_NAME_WR');
    if (vScaleByCode <> '1') then
        select meaning into vScaleByMeaning from ams_lookups
         where lookup_type ='AMS_IO_SCALE_BY' and lookup_code = vScaleByCode;
        return (vRepName||' (' ||vIn|| ' '||vScaleByMeaning||') ');
    else
        return (vRepName);
    end if;

EXCEPTION
WHEN OTHERS THEN
return (vRepName);
   null;
END print_reg_bin_title_wr;


FUNCTION print_reg_report_title (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
is
    vContext         varchar2(80);
    xContext         varchar2(80);
    vRepName         varchar2(80);
    xRem             varchar2(80);
    xYear            varchar2(80);
    xQtr             varchar2(80);
    xMonth           varchar2(80);
    xDisplayType     varchar2(80);
    xPeriod          varchar2(80);
    xRetString       varchar2(100);
    vDefPeriod       varchar2(80);
    vPeriod          varchar2(80);
    vTo              varchar2(80);
    vFor              varchar2(80);
    vIn              varchar2(80);
    vScaleByCode     varchar2(80);
    vScaleByMeaning  varchar2(80);
    vCompCode       varchar2(80);


BEGIN
    vCompCode := jtfb_dcf.get_parameter_value(p_parameters,'DCF.componentCode');
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
    vDefPeriod := jtfb_dcf.get_parameter_value(p_parameters, 'P_DEF_PERIOD');
    vPeriod := jtfb_dcf.get_parameter_value(p_parameters, 'P_PERIOD');
    vScaleByCode := jtfb_dcf.get_parameter_value(p_parameters, 'P_SCALE_BY');
    --vTo := ams_utility_pvt.get_lookup_meaning('AMS_IO_OTHER','TO');
    vFor := ams_utility_pvt.get_lookup_meaning('AMS_IO_OTHER','FOR');

    xRetString := 'x';
    xDisplayType := 'Z';
    if (vContext is NULL OR vContext = 'NOT_FOUND' OR vContext = '') then
        vContext := vDefPeriod;
    end if;
    if (vContext = 'LEAD_COVERAGE' OR vContext = 'LEAD_TO_OPP') THEN
        vContext := 'N-N-N-'||vPeriod;
    end if;

    if (vContext is not NULL) then
           select year, qtr,month,display_type into xYear, xQtr, xMonth, xDisplayType
             from bim_r_lead_qu_bin_mv where year||'-'||qtr||'-'||month||'-'||display_type = vContext
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
    end if;

    if (xRetString = 'x') then
       xRetString := '';
    end if;
    if (vScaleByCode <> '1') then
        select meaning into vScaleByMeaning from ams_lookups
         where lookup_type ='AMS_IO_SCALE_BY' and lookup_code = vScaleByCode;
         return (vRepName||' (' ||vIn|| ' '||vScaleByMeaning||') '||vFor||' '|| xRetString);
    else
         return (vRepName||' '||vFor||' '|| xRetString);
    end if;
EXCEPTION
WHEN OTHERS THEN
return (vRepName);
   null;
END print_reg_report_title;

END;

/
