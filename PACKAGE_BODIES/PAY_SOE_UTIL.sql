--------------------------------------------------------
--  DDL for Package Body PAY_SOE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SOE_UTIL" as
/* $Header: pysoeutl.pkb 120.1.12010000.2 2009/01/05 11:40:05 parusia ship $ */
--
g_debug boolean := hr_utility.debug_enabled;
--
cursor config is
select org_information2 elements1
,      org_information3 elements2
,      org_information4 elements3
,      org_information5 elements4
,      org_information6 elements5
,      org_information7 elements6
,      org_information8 information1
,      org_information9 balances1
,      org_information10 balances2
,      org_information11 balances3
from   hr_organization_information
where  organization_id = fnd_profile.value('PER_BUSINESS_GROUP_ID')
and    org_information_context = 'Business Group:SOE Information'
and    org_information1 = fnd_profile.value('PAY_SOE_USER_CATEGORY');
--
l_config config%ROWTYPE;
--
TYPE dataValueRecType is RECORD (colName varchar2(30)
                                ,colValue VARCHAR2(240)
                                ,firstCol BOOLEAN
                                ,lastCol BOOLEAN);
dataValueRec dataValueRecType;
--
TYPE dataValueTabType is TABLE of dataValueRecType INDEX by BINARY_INTEGER;
dataValueTab dataValueTabType;
--
i number := 0;
--
--
initialized boolean := FALSE;
-- Bug 7377886
-- global variable bgid_save will store the bg_id for which SOE Information
-- has been retrieved
bgid_save number ;
--
/* --------------------------------------------------------------------
   Procedure : setValue
   --------------------
Maintain pl/sql table of column name and value pairs. firstcol and
lastcol indicate the select statements first and last columns (used
to format the statement correctly
----------------------------------------------------------------------- */
procedure setValue(name varchar2
                  ,value varchar2
                  ,firstCol BOOLEAN
                  ,lastCol BOOLEAN) is
begin
   if g_debug then
     hr_utility.trace('colid  = ' || name || value);
   end if;
   --
   dataValueRec.colName := ' COL' || name;
   dataValueRec.colValue := value;
   dataValueRec.firstCol := firstCol;
   dataValueRec.lastCol := lastCol;
   --
   i := i + 1;
   dataValueTab(i) := dataValueRec;
end;
--
/* --------------------------------------------------------------------
   Procedure : clear
   --------------------
Clears down existing dataValueTab PL/SQL table
----------------------------------------------------------------------- */
procedure clear is
begin
   dataValueTab.delete;
   i := 0;
end;
--
/* --------------------------------------------------------------------
   Function : genCursor
   --------------------
Process contents of pl/SQL table to return SQL statement in the form

   select 'a' COL1, 'b' COL2 from dual
   union
   select 'c' COL1, 'd' COL2 from dual;
----------------------------------------------------------------------- */
function genCursor return long is
   l_sql_string long;
   l_ref_cursor ref_cursor;
begin
  for a in dataValueTab.first..dataValueTab.last loop
     if dataValueTab(a).firstCol then
        l_sql_string := l_sql_string ||'select ';     else
        l_sql_string := l_sql_string ||',';
     end if;
     l_sql_string :=
        l_sql_string || ''''
                     || dataValueTab(a).colValue
                     || ''''
                     || dataValueTab(a).colName;
     --
     if dataValueTab(a).lastCol then
        l_sql_string :=
           l_sql_string || ' from dual ';
        --
        if a <> dataValueTab.last then
           l_sql_string := l_sql_string ||' union all ';
        end if;
     end if;
  end loop;
  --
-- Create the reference cursor
--
--  open l_ref_cursor for l_sql_string;
--
  return l_sql_string;
end;
--
/* --------------------------------------------------------------------
   Function : convertCursor
   --------------------
The following function is called by the SOE moduled VO code for each of the
SOE Regions to convert the SQL string in to a REF CURSOR that
can be processed by the VO.
----------------------------------------------------------------------- */
function convertCursor(p_sql_string long) return ref_cursor is
l_ref_cursor ref_cursor;
begin
    if g_debug then
      hr_utility.trace(substr(p_sql_string,1,2000));
      hr_utility.trace(substr(p_sql_string,2001,2000));
      hr_utility.trace(substr(p_sql_string,4001,2000));
    end if;
    --
    open l_ref_cursor for p_sql_string;
    return l_ref_cursor;
end;
--
/* --------------------------------------------------------------------
   Function : getIDFlexValue
   --------------------
The following function evaluates a key flexfield segment to determine
whether it has a Table Validated Value Set. If so then it returns
the MEANING value from the value set, otherwise the ID value.
This is used by the Bank Flexfield function, but is made public so
that it could be used by other legislatively defined functions.
----------------------------------------------------------------------- */
function getIDFlexValue(p_id_flex_code in varchar2
                       ,p_id_flex_num in number
                       ,p_application_column_name varchar2
                       ,p_id in varchar2) return varchar2 is
--
TYPE FlexCurTyp IS REF CURSOR;  -- define weak REF CURSOR type
flex_cv   FlexCurTyp;  -- declare cursor variable
--
l_code varchar2(30);
l_val varchar2(80);
--
l_sql varchar2(2000);
l_flex_value_set_id number;
--
cursor getTableValidation is
select f.flex_value_set_id
from   fnd_id_flex_segments f
,      fnd_flex_validation_tables t
where  f.id_flex_code = p_id_flex_code
and    f.id_flex_num = p_id_flex_num
and    f.application_column_name = p_application_column_name
and    f.flex_value_set_id = t.flex_value_set_id;
--
begin
open getTableValidation;
fetch getTableValidation into l_flex_value_set_id;
close getTableValidation;
  --
if l_flex_value_set_id is not null then
  l_sql := per_cagr_utility_pkg.get_sql_from_vset_id(l_flex_value_set_id);
  --
  OPEN flex_cv FOR l_sql;
  loop
    fetch flex_cv into l_code,l_val;
    if flex_cv%notfound then
       l_val := p_id;
       exit;
    elsif l_code = p_id then
       exit;
    end if;
  end loop;
  --
  close flex_cv;
  --
 else
   l_val := p_id;
 end if;
 --
 return l_val;
end getIdFlexValue;
--
/* --------------------------------------------------------------------
   Function : getBankDetails
   --------------------
The following function retrieves the Bank Name or Bank Account Number
(depending on Segment Type passed in).
----------------------------------------------------------------------- */
function getBankDetails(p_legislation_code varchar2
                       ,p_external_account_id varchar2
                       ,p_segment_type varchar2
                       ,p_mask number) return varchar2 is
--
cursor getSegment is
select decode(substr(meaning,1,3)
             ,p_legislation_code||'_',substr(meaning,4,length(meaning)-3)
             ,meaning)
from   hr_lookups
where  lookup_type = p_segment_type
and    lookup_code = p_legislation_code;
--
l_segment varchar2(30);
l_value varchar2(80);
l_id_flex_num number;
l_id varchar2(80);
l_sql varchar2(2000);
l_seglen number;
begin
  open getSegment;
  fetch getSegment into l_segment;
  close getSegment;
  --
  if l_segment is not null then
     l_sql := 'select id_flex_num,'||l_segment||
              ' from pay_external_accounts '||
              ' where external_account_id = :eaId';
     --
     EXECUTE IMMEDIATE l_sql INTO l_id_flex_num, l_id
                             USING p_external_account_id;
     --
     l_value := getIdFlexValue('BANK',l_id_flex_num,l_segment,l_id);
  end if;
  --
  if p_mask is not null then
     l_seglen := length(l_value);
     --
     if sign(p_mask) = 1 then
        -- Bugfix 5695538
        -- Don't do any masking if the number of characters to display is
        -- greater than the number of characters in the segment
        if p_mask <= l_seglen then
          l_value := lpad(substr(l_value,l_seglen-p_mask+1,p_mask),l_seglen,'X');
        end if;
     else
        l_value := rpad(substr(l_value,1,abs(p_mask)),l_seglen,'X');
     end if;
  end if;
  --
  return l_value;
end getBankDetails;
--
/* --------------------------------------------------------------------
   Function : getConfig
   --------------------
This following function retrieves information from the
"Business Group:SOE" flexfield and returns the value of the segment requested.
----------------------------------------------------------------------- */
function getConfig(p_config_type varchar2) return varchar2 is
--
l_config_value varchar2(80);
l_bgid number;
l_soe_user_cat varchar2(50);
l_init varchar2(10);
--
begin

  select fnd_profile.value('PER_BUSINESS_GROUP_ID') into l_bgid from dual ;
  select fnd_profile.value('PAY_SOE_USER_CATEGORY') into l_soe_user_cat from dual ;

  if initialized = true then
      l_init := 'true';
  else
      l_init := 'false';
  end if ;

  hr_utility.trace('initialized : '||l_init);
  hr_utility.trace('PER_BUSINESS_GROUP_ID : '||l_bgid);
  hr_utility.trace('PAY_SOE_USER_CATEGORY : '||l_soe_user_cat);

  -- Bug 7377886
  -- Added the clause bgid_save = l_bgid,
  -- so that the SOE intialization part is skipped only if the BG is not changed
  -- If BG is changed, then the SOE Information from BG needs to re-retrieved
  if initialized and bgid_save = l_bgid then
     null;
  else
     open config;
     fetch config into l_config;
     if config%notfound then
        close config;
        initialized := TRUE;
        return null;
     end if;
     close config;
     --
     initialized := TRUE;
     -- Bug 7377886
     -- Saving the BG id for which the SOE information has been retrieved
     bgid_save := l_bgid ;
  end if;
  --
    if p_config_type = 'ELEMENTS1' then
       l_config_value := l_config.elements1;
    elsif p_config_type = 'ELEMENTS2' then
          l_config_value := l_config.elements2;
    elsif p_config_type = 'ELEMENTS3' then
          l_config_value := l_config.elements3;
    elsif p_config_type = 'ELEMENTS4' then
          l_config_value := l_config.elements4;
    elsif p_config_type = 'ELEMENTS5' then
          l_config_value := l_config.elements5;
    elsif p_config_type = 'ELEMENTS6' then
          l_config_value := l_config.elements6;
    elsif p_config_type = 'INFORMATION1' then
          l_config_value := l_config.information1;
    elsif p_config_type = 'BALANCES1' then
          l_config_value := l_config.balances1;
    elsif p_config_type = 'BALANCES2' then
          l_config_value := l_config.balances2;
    elsif p_config_type = 'BALANCES3' then
          l_config_value := l_config.balances3;
    end if;
  --
  hr_utility.trace('Returning '||p_config_type||' : '||l_config_value);
  return l_config_value;
  --
end getConfig;
--
end pay_soe_util;

/
