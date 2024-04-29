--------------------------------------------------------
--  DDL for Package Body PER_RI_RT_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RI_RT_UTIL_PKG" AS
/* $Header: perrirtutil.pkb 120.3 2006/10/05 09:54:16 balchand noship $ */
PROCEDURE insert_per_ri_rt_gen (p_job_name      VARCHAR2,
                                p_request_id    NUMBER,
				p_user_id       NUMBER)
IS
CURSOR csr_get_conc_proc_stat IS
  SELECT PHASE_CODE,
         STATUS_CODE,
	 ACTUAL_START_DATE
    FROM FND_CONCURRENT_REQUESTS fcr
   WHERE request_id = p_request_id;
l_req_phase   VARCHAR2(1);
l_req_status  VARCHAR2(1);
l_submit_date DATE;
BEGIN
OPEN csr_get_conc_proc_stat;
  FETCH csr_get_conc_proc_stat INTO l_req_phase, l_req_status,l_submit_date;
CLOSE csr_get_conc_proc_stat;

INSERT INTO per_ri_rt_gen (
                        JOB_NAME,
                        REQUEST_ID,
                        USER_ID,
                        REQUEST_PHASE,
                        REQUEST_STATUS,
                        SUBMISSION_DATE,
                        COMPLETION_DATE,
			TEST_SUITE)
		VALUES  (p_job_name,
		        p_request_id,
			p_user_id,
			l_req_phase,
			l_req_status,
			sysdate,--l_submit_date,
			null,
			null);
END insert_per_ri_rt_gen;

FUNCTION make_sql_stmt (p_value_set_id      in number,
		    	p_value_set_type    in varchar2,
		    	p_choice	    out nocopy boolean)
	return varchar2 is

c	number;
l_stmt 	varchar2(20000);
l_where varchar2(2000) ;

BEGIN

IF p_value_set_type = 'F' THEN
	p_choice := FALSE;

    select 'select to_char('||value_column_name||') display_value, '||
           replace(id_column_name, ',',  '  || ')||' id_value '||
    	 ' from '||application_table_name
    into l_stmt
    from   fnd_flex_validation_tables t
    where  t.flex_value_set_id = p_value_set_id;

    select additional_where_clause
    into   l_where
    from   fnd_flex_validation_tables t
    where  t.flex_value_set_id = p_value_set_id;

    if l_where is not null then
     l_stmt := l_stmt ||' '||l_where;
    end if;

ELSIF p_value_set_type = 'I' THEN

	p_choice := TRUE;

    l_stmt := 'select flex_value_meaning display_value, '||
         '  flex_value_id  id_value  '||
    	 ' from fnd_flex_values_vl t'||
         ' where t.flex_value_set_id = :1'|| --//p_value_set_id||
         ' and t.enabled_flag=''Y''' ;
END IF;
    -- test the SQL
    c := dbms_sql.open_cursor ;
--##MS trap any exceptions raised here so that we can close the cursor before
--     raising the error
    BEGIN
       dbms_sql.parse(c , l_stmt , dbms_sql.native) ;
    EXCEPTION
      WHEN OTHERS THEN
        dbms_sql.close_cursor(c);
        RAISE;
    END;

--##MS close cursor if the parse raised no exceptions
    dbms_sql.close_cursor(c);

    return (l_stmt);

  return ( null );

END make_sql_stmt;

FUNCTION get_display_prompt (p_flexfield VARCHAR2,
                             p_context   VARCHAR2,
			     p_column    VARCHAR2) return VARCHAR2
IS
CURSOR get_window_prompt IS
   SELECT form_left_prompt
     FROM fnd_descr_flex_col_usage_vl
    WHERE descriptive_flexfield_name = p_flexfield
      AND descriptive_flex_context_code = p_context
      AND application_column_name = p_column;
l_end_user_column_name VARCHAR2(100);
BEGIN
  OPEN get_window_prompt;
    FETCH get_window_prompt into l_end_user_column_name;
  CLOSE get_window_prompt;
  RETURN l_end_user_column_name;
END get_display_prompt;

FUNCTION get_display_value(p_flexfield  VARCHAR2,
                            p_context   VARCHAR2,
			    p_column    VARCHAR2,
			    p_value     VARCHAR2) return varchar2
IS
Cursor get_sel_set IS
   SELECT nvl(flex_value_set_id,-999)
     FROM fnd_descr_flex_col_usage_vl
    WHERE descriptive_flexfield_name = p_flexfield
      AND descriptive_flex_context_code = p_context
      AND application_column_name = p_column;

CURSOR chk_segment_enabled IS
   SELECT 1
     FROM fnd_descr_flex_col_usage_vl
    WHERE descriptive_flexfield_name = p_flexfield
      AND descriptive_flex_context_code = p_context
      AND application_column_name = p_column
      AND display_flag = 'Y'
      AND ENABLED_FLAG = 'Y';

CURSOR get_sel_set_type(p_value_set_id NUMBER) IS
   SELECT validation_type
     FROM fnd_flex_value_sets
    WHERE flex_value_set_id = p_value_set_id;

l_value_set_id   NUMBER;
l_value_set_type VARCHAR2(1);
l_sql_stmt       VARCHAR2(20000);
l_new_sql_stmt   VARCHAR2(20000);
c                NUMBER;
l_value          VARCHAR2(200);
l_dummy          NUMBER;
l_choice         Boolean;
BEGIN

OPEN get_sel_set;
  FETCH get_sel_set into l_value_set_id;
CLOSE get_sel_set;
OPEN chk_segment_enabled;
  FETCH chk_segment_enabled into l_dummy;
  if (chk_segment_enabled%NOTFOUND) then
    CLOSE chk_segment_enabled;
    return null;
  else
    CLOSE chk_segment_enabled;
  end if;

if (l_value_set_id = -999 or l_value_set_id is null) then
    return p_value;
end if;
if (p_value is null) then return null; end if;
     hr_utility.trace('Value Set Id is ' || l_value_set_id);
  IF (l_value_set_id <> -999) THEN
     OPEN get_sel_set_type(l_value_set_id);
        FETCH get_sel_set_type INTO l_value_set_type;
     CLOSE get_sel_set_type;
     hr_utility.trace('Value set type is ' || l_value_set_type);
     IF (l_value_set_type = 'F' OR l_value_set_type = 'I') THEN
         l_sql_stmt := make_sql_stmt(p_value_set_id   => l_value_set_id,
	                             	p_value_set_type =>l_value_set_type,
				     				p_choice => l_choice);
	 IF (l_sql_stmt is null ) then
	    hr_utility.trace('Null');
	    RETURN NULL;
	 END IF;
	 hr_utility.trace(l_sql_stmt);

	IF l_choice = TRUE THEN

	 l_new_sql_stmt := 'select display_value from (' || l_sql_stmt || ') where id_value = to_char(:p_value)';
         execute immediate l_new_sql_stmt into l_value using l_value_set_id,p_value;

	ELSIF l_choice = FALSE THEN

	 l_new_sql_stmt := 'select display_value from (' || l_sql_stmt || ') where id_value = to_char(:p_value)';
         execute immediate l_new_sql_stmt into l_value using p_value;

	END IF;

	 RETURN l_value;
     ELSIF (l_value_set_type = 'N') THEN
         RETURN p_value;
     ELSE
         RETURN null;
     END IF;
  END IF;
EXCEPTION
WHEN OTHERS then
   return null;
END get_display_value;

FUNCTION chk_context (p_flexfield VARCHAR2,
                      p_context   VARCHAR2) RETURN NUMBER
IS
CURSOR chk_segments_for_context IS
  SELECT count(*)
    FROM fnd_descr_flex_col_usage_vl
   WHERE descriptive_flexfield_name = p_flexfield
     AND descriptive_flex_context_code = p_context;
l_number NUMBER;
BEGIN
  OPEN chk_segments_for_context;
    FETCH chk_segments_for_context INTO l_number;
  CLOSE chk_segments_for_context;
RETURN l_number;
END chk_context;

PROCEDURE  generate_xml (p_entity_code  VARCHAR2,
                        p_sample_size  NUMBER,
			p_business_group_id NUMBER,
			p_xmldata     OUT nocopy CLOB)
IS
CURSOR get_legislation_code IS
-- SELECT legislation_code
--   FROM per_business_groups
--  WHERE business_group_id = p_business_group_id;

select hr_api.return_legislation_code(p_business_group_id)
as legislation_code
from dual;

l_query_str   VARCHAR2(20000);
queryCtx      DBMS_XMLQuery.ctxType;
xmlString1    CLOB ;
l_entityset   VARCHAR2(100) ;
l_entity      VARCHAR2(100) ;
l_legislation_code  VARCHAR2(10);
l_sample_size number;
BEGIN
if (p_sample_size is null) then
   l_sample_size := 5;
else
   l_sample_size := p_sample_size;
end if;
hr_utility.trace('.................1');

hr_utility.trace('Entering ...........1');
IF (p_entity_code = 'ORGANIZATION_HIERARCHY') THEN
   l_query_str := 'SELECT pos.name OrganizationStructureName,' ||
'               pos.primary_structure_flag primaryflag,' ||
'		pos.POSITION_CONTROL_STRUCTURE_FLG PosnCtrlStrFlg,' ||
'		pov.VERSION_NUMBER Versionnumber,' ||
'		to_char(pov.DATE_FROM,''rrrr-mm-dd'') DateFrom,' ||
'		to_char(pov.Date_to,''rrrr-mm-dd'') DateTo,' ||
'		pov.topnode_pos_ctrl_enabled_flag TopNodeCtrlFlg,' ||
'		poe.position_control_enabled_flag PositionCtrlFlg,' ||
'		hou1.NAME ParentOrg,' ||
'		hou2.NAME ChildOrg' ||
'          FROM per_organization_structures_v pos,' ||
'               per_org_structure_versions_v pov,' ||
'               per_org_structure_elements poe,' ||
'		hr_organization_units hou1,' ||
'		hr_organization_units hou2' ||
'         WHERE poe.org_structure_version_id = pov.org_structure_version_id' ||
'           AND pov.organization_structure_id = pos.organization_structure_id' ||
'	    AND poe.organization_id_parent = hou1.organization_id' ||
'	    AND poe.organization_id_child  = hou2.organization_id' ||
'	    AND poe.business_group_id = hou1.business_group_id' ||
'	    AND poe.business_group_id = hou2.business_group_id' ||
'           AND poe.business_group_id = :business_group_id'; --|| p_business_group_id;
   l_entityset := 'OrgHierarchies';
   l_entity := 'OrgHierarchy';
ELSIF (p_entity_code = 'JOB_GROUPS') THEN
  l_query_str := 'SELECT pjg.displayed_name JobGrpName,' ||
'               ffs.id_flex_structure_name JobFlexStr,' ||
'               hou.name BGName,' ||
'               pjg.MASTER_FLAG MasterFlg' ||
'          FROM per_job_groups pjg,' ||
'               fnd_id_flex_structures_vl ffs,' ||
'               hr_organization_units hou' ||
'         WHERE pjg.business_group_id = hou.organization_id' ||
'           AND hou.organization_id = hou.business_group_id' ||
'           AND pjg.id_flex_num = ffs.id_flex_num' ||
'           AND ffs.id_flex_code = ''JOB''' ||
'           AND pjg.business_group_id = :business_group_id'; --|| p_business_group_id;
    l_entityset := 'JobGroups';
    l_entity := 'JobGroup';
ELSIF (p_entity_code = 'JOB_GROUPS_GB') THEN
  l_query_str := 'SELECT pjg.displayed_name JobGrpName,' ||
'               ffs.id_flex_structure_name JobFlexStr,' ||
'               hou.name BGName,' ||
'               pjg.MASTER_FLAG MasterFlg' ||
'          FROM per_job_groups pjg,' ||
'               fnd_id_flex_structures_vl ffs,' ||
'               hr_organization_units hou' ||
'         WHERE pjg.business_group_id = hou.organization_id' ||
'           AND hou.organization_id = hou.business_group_id' ||
'           AND pjg.id_flex_num = ffs.id_flex_num' ||
'           AND ffs.id_flex_code = ''JOB''' ||
'           AND pjg.business_group_id = :business_group_id'; --|| p_business_group_id;
    l_entityset := 'JobGroups';
    l_entity := 'JobGroup';
ELSIF (p_entity_code = 'LOCATIONS') THEN
  l_query_str := 'SELECT hl.location_code LocationCode, ' ||
'           hl.description Description, ' ||
'	   to_char(hl.inactive_date,''rrrr-mm-dd'') InactiveDate, ' ||
'	   ffc.descriptive_flex_context_name Style, ' ||
'	   hl.ship_to_site_flag ShiptoSiteFlag, ' ||
'	   hl.receiving_site_flag ReceivingSiteFlag,' ||
'	   hl.bill_to_site_flag BillToSiteFlag, ' ||
'	   hl.in_organization_flag InOrgFlag, ' ||
'	   hl.office_site_flag OfficeSiteFlag, ' ||
'	   hl1.location_code ShipToLocation, ' ||
'	   pap.full_name Contact, ' ||
'	   hou.NAME InventoryOrg, ' ||
'	   hod2.organization_name TaxCode, ' ||
'	   hl.ECE_TP_LOCATION_CODE EDILocnCode,' ||
'          decode(per_ri_rt_util_pkg.chk_context(''Address Location'',hl.STYLE),0,null,''LOC_ADDRESS_0'') flexfield,' ||
'          decode(per_ri_rt_util_pkg.chk_context(''Address Location'',hl.STYLE),0,null,''Location Address'') curform,' ||
'          decode(per_ri_rt_util_pkg.chk_context(''Address Location'',hl.STYLE),0,null,''Cancel'') button,' ||
'	   per_ri_rt_util_pkg.get_display_prompt ( ''Address Location'',hl.STYLE,''ADDRESS_LINE_1'') Addressline1pmt, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt ( ''Address Location'',hl.STYLE,''ADDRESS_LINE_2'') Addressline2pmt, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt ( ''Address Location'',hl.STYLE,''ADDRESS_LINE_3'') Addressline3pmt, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt ( ''Address Location'',hl.STYLE,''COUNTRY'') countrypmt, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt ( ''Address Location'',hl.STYLE,''LOC_INFORMATION13'') LocInformation13pmt, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt ( ''Address Location'',hl.STYLE,''LOC_INFORMATION14'') LocInformation14pmt, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt ( ''Address Location'',hl.STYLE,''LOC_INFORMATION15'') LocInformation15pmt, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt ( ''Address Location'',hl.STYLE,''LOC_INFORMATION16'') LocInformation16pmt, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt ( ''Address Location'',hl.STYLE,''LOC_INFORMATION17'') LocInformation17pmt, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt ( ''Address Location'',hl.STYLE,''LOC_INFORMATION18'') LocInformation18pmt, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt ( ''Address Location'',hl.STYLE,''LOC_INFORMATION19'') LocInformation19pmt, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt ( ''Address Location'',hl.STYLE,''LOC_INFORMATION20'') LocInformation20pmt, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt ( ''Address Location'',hl.STYLE,''POSTAL_CODE'') PostalCodepmt, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt ( ''Address Location'',hl.STYLE,''REGION_1'') Region1pmt, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt ( ''Address Location'',hl.STYLE,''REGION_2'') Region2pmt, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt ( ''Address Location'',hl.STYLE,''region_3'') Region3pmt, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt ( ''Address Location'',hl.STYLE,''TELEPHONE_NUMBER_1'') TelephoneNumber1pmt, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt ( ''Address Location'',hl.STYLE,''TELEPHONE_NUMBER_2'') TelephoneNumber2pmt, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt ( ''Address Location'',hl.STYLE,''TELEPHONE_NUMBER_3'') TelephoneNumber3pmt, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt ( ''Address Location'',hl.STYLE,''TOWN_OR_CITY'') TownOrCitypmt, ' ||
'	   per_ri_rt_util_pkg.get_display_value ( ''Address Location'',hl.STYLE,''ADDRESS_LINE_1'',hl.address_line_1) Addressline1, ' ||
'	   per_ri_rt_util_pkg.get_display_value ( ''Address Location'',hl.STYLE,''ADDRESS_LINE_2'',hl.address_line_2) Addressline2, ' ||
'	   per_ri_rt_util_pkg.get_display_value ( ''Address Location'',hl.STYLE,''ADDRESS_LINE_3'',hl.address_line_3) Addressline3, ' ||
'	   per_ri_rt_util_pkg.get_display_value ( ''Address Location'',hl.STYLE,''COUNTRY'',hl.COUNTRY) country, ' ||
'	   per_ri_rt_util_pkg.get_display_value ( ''Address Location'',hl.STYLE,''LOC_INFORMATION13'',hl.loc_information13) LocInformation13, ' ||
'	   per_ri_rt_util_pkg.get_display_value ( ''Address Location'',hl.STYLE,''LOC_INFORMATION14'',hl.loc_information14) LocInformation14, ' ||
'	   per_ri_rt_util_pkg.get_display_value ( ''Address Location'',hl.STYLE,''LOC_INFORMATION15'',hl.loc_information15) LocInformation15, ' ||
'	   per_ri_rt_util_pkg.get_display_value ( ''Address Location'',hl.STYLE,''LOC_INFORMATION16'',hl.loc_information16) LocInformation16, ' ||
'	   per_ri_rt_util_pkg.get_display_value ( ''Address Location'',hl.STYLE,''LOC_INFORMATION17'',hl.loc_information17) LocInformation17, ' ||
'	   per_ri_rt_util_pkg.get_display_value ( ''Address Location'',hl.STYLE,''LOC_INFORMATION18'',hl.loc_information18) LocInformation18, ' ||
'	   per_ri_rt_util_pkg.get_display_value ( ''Address Location'',hl.STYLE,''LOC_INFORMATION19'',hl.loc_information19) LocInformation19, ' ||
'	   per_ri_rt_util_pkg.get_display_value ( ''Address Location'',hl.STYLE,''LOC_INFORMATION20'',hl.loc_information20) LocInformation20, ' ||
'	   per_ri_rt_util_pkg.get_display_value ( ''Address Location'',hl.STYLE,''POSTAL_CODE'',hl.POSTAL_CODE) PostalCode, ' ||
'	   per_ri_rt_util_pkg.get_display_value ( ''Address Location'',hl.STYLE,''REGION_1'',hl.REGION_1) Region1, ' ||
'	   per_ri_rt_util_pkg.get_display_value ( ''Address Location'',hl.STYLE,''REGION_2'',hl.REGION_2) Region2, ' ||
'	   per_ri_rt_util_pkg.get_display_value ( ''Address Location'',hl.STYLE,''region_3'',hl.region_3) Region3, ' ||
'	   per_ri_rt_util_pkg.get_display_value ( ''Address Location'',hl.STYLE,''TELEPHONE_NUMBER_1'',hl.TELEPHONE_NUMBER_1) TelephoneNumber1, ' ||
'	   per_ri_rt_util_pkg.get_display_value ( ''Address Location'',hl.STYLE,''TELEPHONE_NUMBER_2'',hl.telephone_number_2) TelephoneNumber2, ' ||
'	   per_ri_rt_util_pkg.get_display_value ( ''Address Location'',hl.STYLE,''TELEPHONE_NUMBER_3'',hl.telephone_number_3) TelephoneNumber3, ' ||
'	   per_ri_rt_util_pkg.get_display_value ( ''Address Location'',hl.STYLE,''TOWN_OR_CITY'',hl.town_or_city) TownOrCity ' ||
'     FROM hr_locations hl, ' ||
'          fnd_descr_flex_contexts_vl ffc, ' ||
'	   hr_locations hl1, ' ||
'	   per_all_people pap, ' ||
'	   hr_organization_units hou, ' ||
'	   org_organization_definitions hod2 ' ||
'    WHERE ffc.descriptive_flex_context_code = hl.STYLE ' ||
'      AND ffc.descriptive_flexfield_name = ''Address Location'' ' ||
'      AND hl.ship_to_location_id = hl1.LOCATION_ID ' ||
'      AND hl.designated_receiver_id = pap.person_id(+) ' ||
'      AND hl.INVENTORY_ORGANIZATION_ID = hou.organization_id(+) ' ||
'      AND hl.tax_name = hod2.organization_code(+)' ||
'      AND (hl.business_group_id is null or hl.business_group_id = :business_group_id)'; --' || p_business_group_id || ')';
  l_entityset := 'Locations';
  l_entity := 'Location';
ELSIF (p_entity_code = 'JOBS') THEN
  l_query_str := 'SELECT pjg.displayed_name JobGroup,' ||
'          pjv.name jobname,' ||
'	   to_char(pjv.date_from,''rrrr-mm-dd'') datefrom,' ||
'	   to_char(pjv.date_to,''rrrr-mm-dd'') dateto,' ||
'	   pjv.approval_authority approvalauthority,' ||
'	   pjv.emp_rights_flag emprightsflag,' ||
'	   pjv.benchmark_job_flag benchmarkFlag,' ||
'	   pj1.name benchmarkjobname,' ||
'          decode(per_ri_rt_util_pkg.chk_context(''Job Developer DF'',pjv.job_information_category),0,null,''JOBS_DEVELOPER_DF_0'') flexfield,' ||
'          decode(per_ri_rt_util_pkg.chk_context(''Job Developer DF'',pjv.job_information_category),0,null,''Further Job Information'') curform,' ||
'          decode(per_ri_rt_util_pkg.chk_context(''Job Developer DF'',pjv.job_information_category),0,null,''Cancel'') button,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION1'') JobInformationprompt1,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION2'') JobInformationprompt2,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION3'') JobInformationprompt3,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION4'') JobInformationprompt4,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION5'') JobInformationprompt5,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION6'') JobInformationprompt6,' ||
'          per_ri_rt_util_pkg.get_display_prompt (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION7'') JobInformationprompt7,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION8'') JobInformationprompt8,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION9'') JobInformationprompt9,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION10'') JobInformationprompt10,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION11'') JobInformationprompt11,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION12'') JobInformationprompt12,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION13'') JobInformationprompt13,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION14'') JobInformationprompt14,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION15'') JobInformationprompt15,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION16'') JobInformationprompt16,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION17'') JobInformationprompt17,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION18'') JobInformationprompt18,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION19'') JobInformationprompt19,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION20'') JobInformationprompt20,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION1'',pjv.job_information1) JobInformation1,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION2'',pjv.job_information2) JobInformation2,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION3'',pjv.job_information3) JobInformation3,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION4'',pjv.job_information4) JobInformation4,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION5'',pjv.job_information5) JobInformation5,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION6'',pjv.job_information6) JobInformation6,' ||
'          per_ri_rt_util_pkg.get_display_value (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION7'',pjv.job_information7) JobInformation7,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION8'',pjv.job_information8) JobInformation8,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION9'',pjv.job_information9) JobInformation9,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION10'',pjv.job_information10) JobInformation10,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION11'',pjv.job_information11) JobInformation11,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION12'',pjv.job_information12) JobInformation12,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION13'',pjv.job_information13) JobInformation13,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION14'',pjv.JOB_INFORMATION14) JobInformation14,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION15'',pjv.job_information15) JobInformation15,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION16'',pjv.job_information16) JobInformation16,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION17'',pjv.job_information17) JobInformation17,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION18'',pjv.job_information18) JobInformation18,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION19'',pjv.job_information19) JobInformation19,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Job Developer DF'',pjv.job_information_category,''JOB_INFORMATION20'',pjv.job_information20) JobInformation20' ||
'  FROM per_job_groups pjg,' ||
'       per_jobs_vl pjv,' ||
'	   per_jobs pj1' ||
' WHERE pjg.JOB_GROUP_ID = pjv.JOB_GROUP_ID ' ||
'   AND pjv.BENCHMARK_JOB_ID = pj1.JOB_ID(+)' ||
'   AND pjv.business_group_id = :business_group_id'; --|| p_business_group_id;

  l_entityset := 'Jobs';
  l_entity := 'Job';
ELSIF (p_entity_code = 'GRADES') THEN
  l_query_str := 'select pgv.SEQUENCE SequenceNo,' ||
'           pgv.NAME Name,' ||
'	   pgv.SHORT_NAME  ShortName,' ||
'	   to_char(pgv.date_from,''rrrr-mm-dd'') DateFrom,' ||
'	   to_char(pgv.date_to,''rrrr-mm-dd'') DateTo,' ||
'          decode(per_ri_rt_util_pkg.chk_context(''PER_GRADES'',pgv.attribute_category),0,null,''GRD1_DF_0'') flexfield,' ||
'          decode(per_ri_rt_util_pkg.chk_context(''PER_GRADES'',pgv.attribute_category),0,null,''Additional Grade Details'') curform,' ||
'          decode(per_ri_rt_util_pkg.chk_context(''PER_GRADES'',pgv.attribute_category),0,null,''Cancel'') Button,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE1'') Attributeprompt1,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE2'') Attributeprompt2,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE3'') Attributeprompt3,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE4'') Attributeprompt4,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE5'') Attributeprompt5,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE6'') Attributeprompt6,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE7'') Attributeprompt7,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE8'') Attributeprompt8,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE9'') Attributeprompt9,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE10'') Attributeprompt10,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE11'') Attributeprompt11,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE12'') Attributeprompt12,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE13'') Attributeprompt13,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE14'') Attributeprompt14,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE15'') Attributeprompt15,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE16'') Attributeprompt16,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE17'') Attributeprompt17,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE18'') Attributeprompt18,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE19'') Attributeprompt19,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE20'') Attributeprompt20,' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE1'',pgv.attribute1) Attribute1,' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE2'',pgv.attribute2) Attribute2,' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE3'',pgv.attribute3) Attribute3,' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE4'',pgv.attribute4) Attribute4,' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE5'',pgv.attribute5) Attribute5,' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE6'',pgv.attribute6) Attribute6,' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE7'',pgv.attribute7) Attribute7,' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE8'',pgv.attribute8) Attribute8,' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE9'',pgv.attribute9) Attribute9,' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE10'',pgv.attribute10) Attribute10,' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE11'',pgv.attribute11) Attribute11,' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE12'',pgv.attribute12) Attribute12,' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE13'',pgv.attribute13) Attribute13,' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE14'',pgv.attribute14) Attribute14,' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE15'',pgv.attribute15) Attribute15,' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE16'',pgv.attribute16) Attribute16,' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE17'',pgv.attribute17) Attribute17,' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE18'',pgv.attribute18) Attribute18,' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE19'',pgv.attribute19) Attribute19,' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_GRADES'',pgv.attribute_category,''ATTRIBUTE20'',pgv.attribute20) Attribute20 ' ||
'  from per_grades_vl pgv '||
' where pgv.business_group_id = :business_group_id'; --|| p_business_group_id;

  l_entityset := 'Grades';
  l_entity := 'Grade';
ELSIF (p_entity_code = 'PAYROLLS') THEN
  l_query_str := 'select ppv.payroll_name PayrollName, ' ||
'           ppv.display_period_type PeriodType, ' ||
'	   to_char(ppv.first_period_end_date,''rrrr-mm-dd'') FirstPeriodEndDate, ' ||
'	   ppv.number_of_years NumberofYears, ' ||
'	   ppv.pay_date_offset PayDateOffset, ' ||
'	   ppv.direct_deposit_date_offset DirectDepDateOffset, ' ||
'	   ppv.cut_off_date_offset CutOffDateOffset, ' ||
'	   ppv.payment_method PaymentMethod, ' ||
'	   ppv.consolidation_set ConsolidationSet, ' ||
'	   to_char(ppv.effective_start_date,''rrrr-mm-dd'') StartDate, ' ||
'	   to_char(ppv.effective_end_date,''rrrr-mm-dd'') EndDate, ' ||
'	   ppv.negative_pay_allowed_flag NegPayAllowed, ' ||
'	   ppv.multi_assignments_flag MultiAssgFlag, ' ||
'          decode(per_ri_rt_util_pkg.chk_context(''Payroll Developer DF'',ppv.prl_information_category),0,null,''PRL_PAYROLL_DESC_FLEX_0'') flexfield,' ||
'          decode(per_ri_rt_util_pkg.chk_context(''Payroll Developer DF'',ppv.prl_information_category),0,null,''Further Payroll Information'') curform,' ||
'          decode(per_ri_rt_util_pkg.chk_context(''Payroll Developer DF'',ppv.prl_information_category),0,null,''Cancel'') Button,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION1'') PayrollInfoprompt1, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION2'') PayrollInfoprompt2, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION3'') PayrollInfoprompt3, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION4'') PayrollInfoprompt4, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION5'') PayrollInfoprompt5, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION6'') PayrollInfoprompt6, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION7'') PayrollInfoprompt7, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION8'') PayrollInfoprompt8, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION9'') PayrollInfoprompt9, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION10'') PayrollInfoprompt10, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION11'') PayrollInfoprompt11, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION12'') PayrollInfoprompt12, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION13'') PayrollInfoprompt13, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION14'') PayrollInfoprompt14, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION15'') PayrollInfoprompt15, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION16'') PayrollInfoprompt16, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION17'') PayrollInfoprompt17, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION18'') PayrollInfoprompt18, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION19'') PayrollInfoprompt19, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION20'') PayrollInfoprompt20, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION21'') PayrollInfoprompt21, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION22'') PayrollInfoprompt22, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION23'') PayrollInfoprompt23, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION24'') PayrollInfoprompt24, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION25'') PayrollInfoprompt25, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION26'') PayrollInfoprompt26, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION27'') PayrollInfoprompt27, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION28'') PayrollInfoprompt28, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION29'') PayrollInfoprompt29, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION30'') PayrollInfoprompt30, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION1'',ppv.prl_information1) PayrollInformaion1, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION2'',ppv.prl_information2) PayrollInformaion2, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION3'',ppv.prl_information3) PayrollInformaion3, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION4'',ppv.prl_information4) PayrollInformaion4, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION5'',ppv.prl_information5) PayrollInformaion5, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION6'',ppv.prl_information6) PayrollInformaion6, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION7'',ppv.prl_information7) PayrollInformaion7, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION8'',ppv.prl_information8) PayrollInformaion8, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION9'',ppv.prl_information9) PayrollInformaion9, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION10'',ppv.prl_information10) PayrollInformaion10, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION11'',ppv.prl_information11) PayrollInformaion11, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION12'',ppv.prl_information12) PayrollInformaion12, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION13'',ppv.prl_information13) PayrollInformaion13, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION14'',ppv.prl_information14) PayrollInformaion14, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION15'',ppv.prl_information15) PayrollInformaion15, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION16'',ppv.prl_information16) PayrollInformaion16, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION17'',ppv.prl_information17) PayrollInformaion17, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION18'',ppv.prl_information18) PayrollInformaion18, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION19'',ppv.prl_information19) PayrollInformaion19, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION20'',ppv.prl_information20) PayrollInformaion20, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION21'',ppv.prl_information21) PayrollInformaion21, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION22'',ppv.prl_information22) PayrollInformaion22, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION23'',ppv.prl_information23) PayrollInformaion23, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION24'',ppv.prl_information24) PayrollInformaion24, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION25'',ppv.prl_information25) PayrollInformaion25, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION26'',ppv.prl_information26) PayrollInformaion26, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION27'',ppv.prl_information27) PayrollInformaion27, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION28'',ppv.prl_information28) PayrollInformaion28, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION29'',ppv.prl_information29) PayrollInformaion29, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Payroll Developer DF'',ppv.prl_information_category,''PRL_INFORMATION30'',ppv.prl_information30) PayrollInformaion30 ' ||
'  from pay_payrolls_v2 ppv' ||
' where ppv.business_group_id = :business_group_id'; --|| p_business_group_id;

    l_entityset := 'Payrolls';
    l_entity := 'Payroll';
ELSIF (p_entity_code = 'ELEMENTS') THEN
hr_utility.trace('Elements.........1');
  l_query_str := 'SELECT pet.element_name ElementName,' ||
'           pet.reporting_name ReportingName,' ||
'	   pet.description Description,' ||
'	   pet.classification_name Classification,' ||
'	   pet.benefit_classification_name BenefitClassification,' ||
'	   to_char(pet.effective_start_date,''rrrr-mm-dd'') StartDate,' ||
'	   decode(to_char(pet.effective_end_date,''rrrr-mm-dd''),''4712-12-31'',null,to_char(pet.effective_end_date,''rrrr-mm-dd'')) EndDate,' ||
'          pet.multiply_value_flag RecurringFlag,' ||
'	   pet.post_termination_rule PostTerminationRule,' ||
'	   pet.processing_priority Priority,' ||
'	   pet.formula_name SkipRule,' ||
'	   pet.multiple_entries_allowed_flag MultipleEntriesAllowed,' ||
'	   pet.additional_entry_allowed_flag AddEntryAllowed,' ||
'	   pet.closed_for_entry_flag ClosedForEntry,' ||
'	   pet.process_in_run_flag ProcessIfRun,' ||
'	   pet.indirect_only_flag IndirectOnlyFlag,' ||
'	   pet.adjustment_only_flag AdjOnlyFlg,' ||
'	   pet.third_party_pay_only_flag ThirdPartyPayFlg,' ||
'	   pet.input_currency_code IPCurrencyCode,' ||
'	   pet.output_currency_code OPCurrencyCode,' ||
'	   pet.qualifying_age Age,' ||
'	   pet.qualifying_length_of_service LegnthOfSrvc,' ||
'	   pet.qualifying_unit_name Units,' ||
'	   pet.standard_link_flag Standard,' ||
'	   pet.grossup_flag GrossUpFlag,' ||
'	   pet.iterative_flag IterativeFlag,' ||
'	   pet.iterative_formula_name IterativeFormula,' ||
'	   pet.iterative_priority IterativePriority,' ||
'	   pet.separate_payment SeperatePayment,' ||
'	   pet.process_separate_flag SeperateFlg,' ||
'	   pet.d_retro_summ_ele_name RetroSummEleName,' ||
'	   pet.proration_group_name ProrationGroup,' ||
'	   pet.proration_formula_name ProrationFormula,' ||
'          decode(per_ri_rt_util_pkg.chk_context(''Element Developer DF'',pet.element_information_category),0,null,''ELEMENT_TYPES_DEVELOPER_DF_0'') flexfield,' ||
'          decode(per_ri_rt_util_pkg.chk_context(''Element Developer DF'',pet.element_information_category),0,null,''Further Element Information'') curform,' ||
'          decode(per_ri_rt_util_pkg.chk_context(''Element Developer DF'',pet.element_information_category),0,null,''Cancel'') Button,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION1'') ElementInfoprompt1,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION2'') ElementInfoprompt2,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION3'') ElementInfoprompt3,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION4'') ElementInfoprompt4,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION5'') ElementInfoprompt5,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION6'') ElementInfoprompt6,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION7'') ElementInfoprompt7,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION8'') ElementInfoprompt8,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION9'') ElementInfoprompt9,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION10'') ElementInfoprompt10,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION11'') ElementInfoprompt11,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION12'') ElementInfoprompt12,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION13'') ElementInfoprompt13,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION14'') ElementInfoprompt14,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION15'') ElementInfoprompt15,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION16'') ElementInfoprompt16,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION17'') ElementInfoprompt17,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION18'') ElementInfoprompt18,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION19'') ElementInfoprompt19,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION20'') ElementInfoprompt20,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION1'',pet.element_information1) ElementInfo1,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION2'',pet.element_information2) ElementInfo2,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION3'',pet.element_information3) ElementInfo3,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION4'',pet.element_information4) ElementInfo4,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION5'',pet.element_information5) ElementInfo5,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION6'',pet.element_information6) ElementInfo6,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION7'',pet.element_information7) ElementInfo7,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION8'',pet.element_information8) ElementInfo8,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION9'',pet.element_information9) ElementInfo9,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION10'',pet.element_information10) ElementInfo10,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION11'',pet.element_information11) ElementInfo11,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION12'',pet.element_information12) ElementInfo12,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION13'',pet.element_information13) ElementInfo13,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION14'',pet.element_information14) ElementInfo14,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION15'',pet.element_information15) ElementInfo15,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION16'',pet.element_information16) ElementInfo16,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION17'',pet.element_information17) ElementInfo17,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION18'',pet.element_information18) ElementInfo18,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION19'',pet.element_information19) ElementInfo19,' ||
'	   per_ri_rt_util_pkg.get_display_value (''Element Developer DF'',pet.element_information_category,''ELEMENT_INFORMATION20'',pet.element_information20) ElementInfo20 ' ||
'  FROM pay_element_types_denorm_v pet ' ||
' WHERE pet.business_group_id = :business_group_id'; --|| p_business_group_id;

   l_entityset := 'Elements';
   l_entity := 'Element';
ELSIF (p_entity_code = 'SALARY_BASES') THEN
hr_utility.trace('Salary Bases.........1');
  l_query_str := 'select ppb.name Name, ' ||
'           hl.meaning PayBasis, ' ||
'	   ppb.pay_annualization_factor AnnualFactor, ' ||
'	   pet.element_name Element, ' ||
'	   pit.name InputValue, ' ||
'	   pr.name GradeRate, ' ||
'	   ppb.grade_annualization_factor GradeAnnualFactor, ' ||
'	   to_char(piv.effective_start_date,''rrrr-mm-dd'') StartDate, ' ||
'	   decode(to_char(piv.effective_end_date,''rrrr-mm-dd''),''4712-12-31'',null,to_char(piv.effective_end_date,''rrrr-mm-dd'')) EndDate, ' ||
'          decode(per_ri_rt_util_pkg.chk_context(''PER_PAY_BASES'',ppb.attribute_category),0,null,''PAYBAS_DF_ITEM_0'') flexfield,' ||
'          decode(per_ri_rt_util_pkg.chk_context(''PER_PAY_BASES'',ppb.attribute_category),0,null,''Additional Salary Basis Details'') curform,' ||
'          decode(per_ri_rt_util_pkg.chk_context(''PER_PAY_BASES'',ppb.attribute_category),0,null,''Cancel'') Button,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE1'') Attributeprompt1, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE2'') Attributeprompt2, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE3'') Attributeprompt3, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE4'') Attributeprompt4, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE5'') Attributeprompt5, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE6'') Attributeprompt6, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE7'') Attributeprompt7, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE8'') Attributeprompt8, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE9'') Attributeprompt9, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE10'') Attributeprompt10, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE11'') Attributeprompt11, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE12'') Attributeprompt12, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE13'') Attributeprompt13, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE14'') Attributeprompt14, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE15'') Attributeprompt15, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE16'') Attributeprompt16, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE17'') Attributeprompt17, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE18'') Attributeprompt18, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE19'') Attributeprompt19, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE20'') Attributeprompt20, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE1'',ppb.attribute1) Attribute1, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE2'',ppb.attribute2) Attribute2, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE3'',ppb.attribute3) Attribute3, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE4'',ppb.attribute4) Attribute4, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE5'',ppb.attribute5) Attribute5, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE6'',ppb.attribute6) Attribute6, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE7'',ppb.attribute7) Attribute7, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE8'',ppb.attribute8) Attribute8, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE9'',ppb.attribute9) Attribute9, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE10'',ppb.attribute10) Attribute10, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE11'',ppb.attribute11) Attribute11, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE12'',ppb.attribute12) Attribute12, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE13'',ppb.attribute13) Attribute13, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE14'',ppb.attribute14) Attribute14, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE15'',ppb.attribute15) Attribute15, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE16'',ppb.attribute16) Attribute16, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE17'',ppb.attribute17) Attribute17, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE18'',ppb.attribute18) Attribute18, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE19'',ppb.attribute19) Attribute19, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''PER_PAY_BASES'',ppb.attribute_category,''ATTRIBUTE20'',ppb.attribute20) Attribute20  ' ||
'  from per_pay_bases ppb, ' ||
'       hr_lookups hl, ' ||
'	   pay_input_values_f piv, ' ||
'	   pay_input_values_f_tl pit, ' ||
'	   pay_element_types pet, ' ||
'	   pay_rates pr ' ||
' where ppb.PAY_BASIS = hl.lookup_code ' ||
'   and hl.lookup_type = ''PAY_BASIS'' ' ||
'   and ppb.INPUT_VALUE_ID = piv.INPUT_VALUE_ID ' ||
'   and piv.input_value_id = pit.INPUT_VALUE_ID ' ||
'   and piv.element_type_id = pet.element_type_id ' ||
'   and ppb.RATE_ID = pr.RATE_ID(+) ' ||
'   and pit.language = ''US'' ' ||
'   and ppb.business_group_id = :business_group_id'; --|| p_business_group_id;

     l_entityset := 'SalaryBases';
     l_entity    := 'SalaryBasis';
ELSIF (p_entity_code = 'POSITIONS') THEN
  l_query_str := 'select hpv.NAME Name, ' ||
'          hpv.review_flag ReviewFlag, ' ||
'	   to_char(hpv.date_effective,''rrrr-mm-dd'') StartDate, ' ||
'	   hpv.date_effective_name DateEffName, ' ||
'	   hpv.position_type_desc PositionType, ' ||
'	   hpv.permanent_temporary_flag PermanentFlg, ' ||
'	   hpv.seasonal_flag SeasonalFlg, ' ||
'	   hpv.organization_desc OrganizationName, ' ||
'	   hpv.job_desc Job, ' ||
'	   to_char(hpv.current_job_prop_end_date,''rrrr-mm-dd'') JobPropEndDate, ' ||
'	   to_char(hpv.current_org_prop_end_date,''rrrr-mm-dd'') OrgPropEndDate, ' ||
'	   hpv.availability_status_desc AvailStatus, ' ||
'	   to_char(hpv.availability_status_start_date,''rrrr-mm-dd'') AvailStartDate, ' ||
'	   to_char(hpv.avail_status_prop_end_date,''rrrr-mm-dd'') AvailEndDate, ' ||
'	   hpv.location_desc Location, ' ||
'	   hpv.status_desc Status, ' ||
'	   to_char(hpv.effective_start_date,''rrrr-mm-dd'') EffStartDate, ' ||
'	   to_char(hpv.effective_end_date,''rrrr-mm-dd'') EffEndDate, ' ||
'	   hpv.fte FTE, ' ||
'	   hpv.max_persons HeadCount, ' ||
'	   hpv.bargaining_unit_desc BargainingUnit, ' ||
'	   to_char(hpv.earliest_hire_date,''rrrr-mm-dd'') EarliestHireDate, ' ||
'	   to_char(hpv.fill_by_date,''rrrr-mm-dd'') FillByDate, ' ||
'	   hpv.permit_recruitment_flag PermitRecruitingFlg, ' ||
'	   hpv.pay_freq_payroll_desc Payroll, ' ||
'	   hpv.pay_basis_desc SalaryBasis, ' ||
'	   hpv.entry_grade_desc Grade, ' ||
'	   hpv.entry_step_desc GradeStep, ' ||
'	   hpv.grade_rate_value GradeScaleRate, ' ||
'	   hpv.point_value Value, ' ||
'	   hpv.grade_rate_min GradeRateRangeMin, ' ||
'	   hpv.grade_rate_mid GradeRateRangeMid, ' ||
'	   hpv.grade_rate_max GradeRateRangeMax, ' ||
'	   hpv.probation_period ProbationDuration, ' ||
'	   hpv.probation_unit_desc ProbDurationUnit, ' ||
'	   hpv.overlap_period OverlapDuration, ' ||
'	   hpv.overlap_unit_desc OverlapDurationUnit, ' ||
'	   hpv.proposed_fte_for_layoff ProposedLayoffFTE, ' ||
'	   to_char(hpv.proposed_date_for_layoff,''rrrr-mm-dd'') ProposedLayoffDate, ' ||
'	   hpv.working_hours WorkingHrs, ' ||
'	   hpv.frequency_desc Frequency, ' ||
'	   hpv.time_normal_start NormalTimeStart, ' ||
'	   hpv.time_normal_finish NormalTimeFinish, ' ||
'	   hpv.supervisor_desc Supervisor, ' ||
'	   hpv.replacement_required_flag ReplacementReqFlg, ' ||
'	   hpv.works_council_approval_flag WorkCouncilApprFlg, ' ||
'	   hpv.supervisor_position_desc SupervisorPosn, ' ||
'	   hpv.relief_position_desc Relief, ' ||
'	   hpv.successor_position_desc Successor, ' ||
'	   hpv.work_period_type_cd ExtendedPayFlg, ' ||
'	   hpv.term_start_day_desc WorkTermStartDay, ' ||
'	   hpv.term_start_month_desc WorkTermStartMonth, ' ||
'	   hpv.work_term_end_day_desc WorkTermEndDay, ' ||
'	   hpv.work_term_end_month_desc WorkTermEndMonth, ' ||
'	   hpv.pay_term_end_day_desc PayTermEndDay, ' ||
'	   hpv.pay_term_end_month_desc PayTermEndMonth, ' ||
'          decode(per_ri_rt_util_pkg.chk_context(''Position Developer DF'',hpv.information_category),0,null,''POSITIONS_POS_DEVELOPER_DF_0'') flexfield,' ||
'          decode(per_ri_rt_util_pkg.chk_context(''Position Developer DF'',hpv.information_category),0,null,''Further Position Information'') curform,' ||
'          decode(per_ri_rt_util_pkg.chk_context(''Position Developer DF'',hpv.information_category),0,null,''Cancel'') Button,' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Position Developer DF'',hpv.information_category,''INFORMATION1'') Infoprompt1, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Position Developer DF'',hpv.information_category,''INFORMATION2'') Infoprompt2, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Position Developer DF'',hpv.information_category,''INFORMATION3'') Infoprompt3, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Position Developer DF'',hpv.information_category,''INFORMATION4'') Infoprompt4, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Position Developer DF'',hpv.information_category,''INFORMATION5'') Infoprompt5, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Position Developer DF'',hpv.information_category,''INFORMATION6'') Infoprompt6, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Position Developer DF'',hpv.information_category,''INFORMATION7'') Infoprompt7, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Position Developer DF'',hpv.information_category,''INFORMATION8'') Infoprompt8, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Position Developer DF'',hpv.information_category,''INFORMATION9'') Infoprompt9, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Position Developer DF'',hpv.information_category,''INFORMATION10'') Infoprompt10, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Position Developer DF'',hpv.information_category,''INFORMATION11'') Infoprompt11, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Position Developer DF'',hpv.information_category,''INFORMATION12'') Infoprompt12, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Position Developer DF'',hpv.information_category,''INFORMATION13'') Infoprompt13, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Position Developer DF'',hpv.information_category,''INFORMATION14'') Infoprompt14, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Position Developer DF'',hpv.information_category,''INFORMATION15'') Infoprompt15, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Position Developer DF'',hpv.information_category,''INFORMATION16'') Infoprompt16, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Position Developer DF'',hpv.information_category,''INFORMATION17'') Infoprompt17, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Position Developer DF'',hpv.information_category,''INFORMATION18'') Infoprompt18, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Position Developer DF'',hpv.information_category,''INFORMATION19'') Infoprompt19, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt (''Position Developer DF'',hpv.information_category,''INFORMATION20'') Infoprompt20, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Position Developer DF'',hpv.information_category,''INFORMATION1'',hpv.information1) Information1, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Position Developer DF'',hpv.information_category,''INFORMATION2'',hpv.information2) Information2, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Position Developer DF'',hpv.information_category,''INFORMATION3'',hpv.information3) Information3, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Position Developer DF'',hpv.information_category,''INFORMATION4'',hpv.information4) Information4, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Position Developer DF'',hpv.information_category,''INFORMATION5'',hpv.information5) Information5, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Position Developer DF'',hpv.information_category,''INFORMATION6'',hpv.information6) Information6, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Position Developer DF'',hpv.information_category,''INFORMATION7'',hpv.information7) Information7, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Position Developer DF'',hpv.information_category,''INFORMATION8'',hpv.information8) Information8, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Position Developer DF'',hpv.information_category,''INFORMATION9'',hpv.information9) Information9, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Position Developer DF'',hpv.information_category,''INFORMATION10'',hpv.information10) Information10, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Position Developer DF'',hpv.information_category,''INFORMATION11'',hpv.information11) Information11, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Position Developer DF'',hpv.information_category,''INFORMATION12'',hpv.information12) Information12, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Position Developer DF'',hpv.information_category,''INFORMATION13'',hpv.information13) Information13, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Position Developer DF'',hpv.information_category,''INFORMATION14'',hpv.information14) Information14, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Position Developer DF'',hpv.information_category,''INFORMATION15'',hpv.information15) Information15, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Position Developer DF'',hpv.information_category,''INFORMATION16'',hpv.information16) Information16, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Position Developer DF'',hpv.information_category,''INFORMATION17'',hpv.information17) Information17, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Position Developer DF'',hpv.information_category,''INFORMATION18'',hpv.information18) Information18, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Position Developer DF'',hpv.information_category,''INFORMATION19'',hpv.information19) Information19, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Position Developer DF'',hpv.information_category,''INFORMATION20'',hpv.information20) Information20 ' ||
' from hr_positions_v hpv ' ||
'where hpv.business_group_id = :business_group_id'; --|| p_business_group_id;

     l_entityset := 'Positions';
     l_entity    := 'Position';
ELSIF (p_entity_code = 'POSITION_HIERARCHY') THEN
  l_query_str := 'select pps.name Name, ' ||
'          pps.primary_position_flag PrimaryFlg, ' ||
'	   psv.version_number Version, ' ||
'	   to_char(psv.DATE_FROM,''rrrr-mm-dd'') DateFrom, ' ||
'          to_char(psv.date_to,''rrrr-mm-dd'') DateTo, ' ||
'	   pp1.NAME ParentPosition, ' ||
'	   pp2.name SubordinatePosition ' ||
'     from per_pos_structure_elements pse, ' ||
'          per_pos_structure_versions psv, ' ||
'	   per_position_structures pps, ' ||
'	   per_positions pp1, ' ||
'	   per_positions pp2 ' ||
'    where pse.POS_STRUCTURE_VERSION_ID = psv.POS_STRUCTURE_VERSION_ID ' ||
'      and psv.POSITION_STRUCTURE_ID = pps.POSITION_STRUCTURE_ID ' ||
'      and pse.PARENT_POSITION_ID = pp1.POSITION_ID ' ||
'      and pse.SUBORDINATE_POSITION_ID = pp2.position_id ' ||
'      and pse.business_group_id = :business_group_id'; --|| p_business_group_id;

    l_entityset := 'PositionHierarchies';
    l_entity := 'PositionHierarchy';
ELSIF (p_entity_code = 'ELEMENT_LINKS') THEN
hr_utility.trace('Element Link.........1');
  l_query_str := 'select pel.element_name ElementName, ' ||
'           pel.description Description, ' ||
'	   pel.classification_name Classification, ' ||
'	   pel.processing_type ProcessingType, ' ||
'	   pel.standard_link_flag StandardLinkFlg, ' ||
'	   pel.organization_name OrganizationName, ' ||
'	   pel.job_name Job, ' ||
'	   pel.grade_name Grade, ' ||
'	   pel.employment_category_name EmpCategory, ' ||
'	   pel.pay_basis_name SalaryBasis, ' ||
'	   ppg.group_name PeopleGroup, ' ||
'	   pel.position_name Position, ' ||
'	   pel.location_code Location, ' ||
'	   pel.payroll_name Payroll, ' ||
'	   pel.link_to_all_payrolls_flag LinkToAllPayFlg, ' ||
'          pel.transfer_to_gl_flag TransferToGL, ' ||
'	   pel.costable_type CostableType, ' ||
'	   pel.element_set_name DistributionSet, ' ||
'	   pel.qualifying_age QualAge, ' ||
'	   pel.qualifying_length_of_service QualLengthOfService, ' ||
'	   pel.qualifying_unit_name QualUnits, ' ||
'	   to_char(pel.effective_start_date,''rrrr-mm-dd'') EffectiveStartDate, ' ||
'	   decode(to_char(pel.Effective_end_date,''rrrr-mm-dd''),''4712-12-31'',null,to_char(effective_end_date,''rrrr-mm-dd'')) EffectiveEndDate ' ||
'  from pay_element_links_v pel, ' ||
'       pay_people_groups ppg ' ||
' where pel.PEOPLE_GROUP_ID = ppg.PEOPLE_GROUP_ID(+) ' ||
'   and pel.business_group_id = :business_group_id'; --|| p_business_group_id;

   l_entityset := 'ElementLinks';
   l_entity := 'ElementLink';
ELSIF (p_entity_code = 'EMPLOYEES_US') THEN
  l_query_str := 'select ppv.EMPLOYEE_NUMBER EmployeeNumber, ' ||
'           ppv.LAST_NAME LastName, ' ||
'	   ppv.FIRST_NAME FirstName, ' ||
'	   ppv.D_TITLE Title, ' ||
'	   ppv.PRE_NAME_ADJUNCT Prefix, ' ||
'	   ppv.SUFFIX Suffix, ' ||
'	   ppv.MIDDLE_NAMES MiddleName, ' ||
'	   ppv.D_SEX Sex, ' ||
'	   ppv.D_PERSON_TYPE_ID PersonType, ' ||
'	   ppv.NATIONAL_IDENTIFIER SSNNumber, ' ||
'	   to_char(ppv.DATE_OF_BIRTH,''rrrr-mm-dd'') DateOfBirth, ' ||
'	   ppv.TOWN_OF_BIRTH TownOfBirth, ' ||
'	   ppv.REGION_OF_BIRTH RegionOfBirth, ' ||
'	   ppv.D_COUNTRY_OF_BIRTH CountryOfBirth, ' ||
'	   ppv.D_MARITAL_STATUS MaritalStatus, ' ||
'	   ppv.D_NATIONALITY Nationality, ' ||
'	   ppv.D_REGISTERED_DISABLED_FLAG RegisteredDisabled, ' ||
'	   to_char(ppv.EFFECTIVE_START_DATE,''rrrr-mm-dd'') EffectiveStartDate, ' ||
'	   to_char(ppv.EFFECTIVE_END_DATE,''rrrr-mm-dd'') EffectiveEndDate, ' ||
'	   to_char(ppv.HIRE_DATE,''rrrr-mm-dd'') LatestStartDate, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Person Developer DF'',ppv.per_information_category,''PER_INFORMATION1'',per_information1) EthnicOrigin, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Person Developer DF'',ppv.per_information_category,''PER_INFORMATION2'',per_information2) I_9, ' ||
'	   to_char(to_date(per_ri_rt_util_pkg.get_display_value (''Person Developer DF'',ppv.per_information_category,''PER_INFORMATION3'',per_information3),''rrrr-mm-dd hh24:mi:ss''),''rrrr-mm-dd'') I_9ExpDate, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Person Developer DF'',ppv.per_information_category,''PER_INFORMATION5'',per_information5) VeteranStatus, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Person Developer DF'',ppv.per_information_category,''PER_INFORMATION7'',per_information7) NewHireStatus, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Person Developer DF'',ppv.per_information_category,''PER_INFORMATION8'',per_information8) ReasonForExclusion, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Person Developer DF'',ppv.per_information_category,''PER_INFORMATION9'',per_information9) ChildSupportObligation, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Person Developer DF'',ppv.per_information_category,''PER_INFORMATION10'',per_information10) OptedforMedicarePartB, ' ||
'	   ppv.OFFICE_NUMBER Office, ' ||
'	   ppv.INTERNAL_LOCATION Location, ' ||
'	   ppv.EMAIL_ADDRESS EmailId, ' ||
'	   ppv.MAILSTOP MailStop, ' ||
'	   ppv.D_HOME_OFFICE MailTo, ' ||
'	   ppv.RESUME_EXISTS ResumeExists, ' ||
'	   to_char(ppv.RESUME_LAST_UPDATED,''rrrr-mm-dd'') ResumeLastUpdated, ' ||
'	   to_char(ppv.HOLD_APPLICANT_DATE_UNTIL,''rrrr-mm-dd'') HoldApplDateUntil, ' ||
'	   ppv.HONORS Honors, ' ||
'	   ppv.KNOWN_AS PreferredName, ' ||
'	   ppv.PREVIOUS_LAST_NAME PreviousLastName, ' ||
'	   ppv.D_WORK_SCHEDULE WorkSchedule, ' ||
'	   ppv.D_STUDENT_STATUS StudentStatus, ' ||
'	   ppv.FTE_CAPACITY FullTimeAvailability, ' ||
'	   to_char(ppv.DATE_EMPLOYEE_DATA_VERIFIED,''rrrr-mm-dd'') DateLastVerified, ' ||
'	   ppv.D_CORR_LANGUAGE CorrespendenceLang, ' ||
'	   ppv.ON_MILITARY_SERVICE OnMilitaryService, ' ||
'	   ppv.SECOND_PASSPORT_EXISTS SecondPassportExists, ' ||
'	   to_char(ppv.DATE_OF_DEATH,''rrrr-mm-dd'') DateOfDeath, ' ||
'	   ppv.D_BENEFIT_GROUP_NAME BenefitGroupName, ' ||
'	   ppv.D_USES_TOBACCO_FLAG UsesTobacco, ' ||
'	   to_char(ppv.ADJUSTED_SVC_DATE,''rrrr-mm-dd'') AdjustedSrvcDate, ' ||
'	   to_char(ppv.DPDNT_ADOPTION_DATE,''rrrr-mm-dd'') AdoptionDate, ' ||
'	   to_char(ppv.ORIGINAL_DATE_OF_HIRE,''rrrr-mm-dd'') DateFirstHired  ' ||
'  from per_people_v ppv ' ||
' where ppv.S_SYSTEM_PERSON_TYPE = ''EMP'' ' ||
'   and business_group_id = :business_group_id'; --|| p_business_group_id;

     l_entityset := 'Employees';
     l_entity := 'Employee';
ELSIF (p_entity_code = 'EMPLOYEES_GB') THEN

  l_query_str := 'select ppv.EMPLOYEE_NUMBER EmployeeNumber, ' ||
'           ppv.LAST_NAME LastName, ' ||
'	   ppv.FIRST_NAME FirstName, ' ||
'	   ppv.D_TITLE Title, ' ||
'	   ppv.PRE_NAME_ADJUNCT Prefix, ' ||
'	   ppv.SUFFIX Suffix, ' ||
'	   ppv.MIDDLE_NAMES MiddleName, ' ||
'	   ppv.D_SEX Sex, ' ||
'	   ppv.D_PERSON_TYPE_ID PersonType, ' ||
'	   ppv.NATIONAL_IDENTIFIER SSNNumber, ' ||
'	   to_char(ppv.DATE_OF_BIRTH,''rrrr-mm-dd'') DateOfBirth, ' ||
'	   ppv.TOWN_OF_BIRTH TownOfBirth, ' ||
'	   ppv.REGION_OF_BIRTH RegionOfBirth, ' ||
'	   ppv.D_COUNTRY_OF_BIRTH CountryOfBirth, ' ||
'	   ppv.D_MARITAL_STATUS MaritalStatus, ' ||
'	   ppv.D_NATIONALITY Nationality, ' ||
'	   ppv.D_REGISTERED_DISABLED_FLAG RegisteredDisabled, ' ||
'	   to_char(ppv.EFFECTIVE_START_DATE,''rrrr-mm-dd'') EffectiveStartDate, ' ||
'	   to_char(ppv.EFFECTIVE_END_DATE,''rrrr-mm-dd'') EffectiveEndDate, ' ||
'	   to_char(ppv.HIRE_DATE,''rrrr-mm-dd'') LatestStartDate, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Person Developer DF'',ppv.per_information_category,''PER_INFORMATION1'',per_information1) EthnicOrigin, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Person Developer DF'',ppv.per_information_category,''PER_INFORMATION2'',per_information2) Director, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Person Developer DF'',ppv.per_information_category,''PER_INFORMATION3'',per_information3) NoOfWeeks, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Person Developer DF'',ppv.per_information_category,''PER_INFORMATION4'',per_information4) Pensioner, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Person Developer DF'',ppv.per_information_category,''PER_INFORMATION5'',per_information5) WorkPermitNo, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Person Developer DF'',ppv.per_information_category,''PER_INFORMATION6'',per_information6) AdditionalPensionableYears, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Person Developer DF'',ppv.per_information_category,''PER_INFORMATION7'',per_information7) AdditionalPensionableMonths, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Person Developer DF'',ppv.per_information_category,''PER_INFORMATION8'',per_information8) AdditionalPensionableDays, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Person Developer DF'',ppv.per_information_category,''PER_INFORMATION9'',per_information9) NIMultipleAssignments, ' ||
'	   per_ri_rt_util_pkg.get_display_value (''Person Developer DF'',ppv.per_information_category,''PER_INFORMATION10'',per_information10) PAYEAggregatedAssignments, ' ||
' 	   to_char(to_date(per_ri_rt_util_pkg.get_display_value (''Person Developer DF'',ppv.per_information_category,''PER_INFORMATION11'',per_information11),''rrrr-mm-dd hh24:mi:ss''),''rrrr-mm-dd'') DSSLinkingLetterEndDate, ' ||
'	   ppv.OFFICE_NUMBER Office, ' ||
'	   ppv.INTERNAL_LOCATION Location, ' ||
'	   ppv.EMAIL_ADDRESS EmailId, ' ||
'	   ppv.MAILSTOP MailStop, ' ||
'	   ppv.D_HOME_OFFICE MailTo, ' ||
'	   ppv.RESUME_EXISTS ResumeExists, ' ||
'	   to_char(ppv.RESUME_LAST_UPDATED,''rrrr-mm-dd'') ResumeLastUpdated, ' ||
'	   to_char(ppv.HOLD_APPLICANT_DATE_UNTIL,''rrrr-mm-dd'') HoldApplDateUntil, ' ||
'	   ppv.HONORS Honors, ' ||
'	   ppv.KNOWN_AS PreferredName, ' ||
'	   ppv.PREVIOUS_LAST_NAME PreviousLastName, ' ||
'	   ppv.D_WORK_SCHEDULE WorkSchedule, ' ||
'	   ppv.D_STUDENT_STATUS StudentStatus, ' ||
'	   ppv.FTE_CAPACITY FullTimeAvailability, ' ||
'	   to_char(ppv.DATE_EMPLOYEE_DATA_VERIFIED,''rrrr-mm-dd'') DateLastVerified, ' ||
'	   ppv.D_CORR_LANGUAGE CorrespendenceLang, ' ||
'	   ppv.ON_MILITARY_SERVICE OnMilitaryService, ' ||
'	   ppv.SECOND_PASSPORT_EXISTS SecondPassportExists, ' ||
'	   to_char(ppv.DATE_OF_DEATH,''rrrr-mm-dd'') DateOfDeath, ' ||
'	   ppv.D_BENEFIT_GROUP_NAME BenefitGroupName, ' ||
'	   ppv.D_USES_TOBACCO_FLAG UsesTobacco, ' ||
'	   to_char(ppv.ADJUSTED_SVC_DATE,''rrrr-mm-dd'') AdjustedSrvcDate, ' ||
'	   to_char(ppv.DPDNT_ADOPTION_DATE,''rrrr-mm-dd'') AdoptionDate, ' ||
'	   to_char(ppv.ORIGINAL_DATE_OF_HIRE,''rrrr-mm-dd'') DateFirstHired  ' ||
'  from per_people_v ppv ' ||
' where ppv.S_SYSTEM_PERSON_TYPE = ''EMP'' ' ||
'   and business_group_id = :business_group_id'; --|| p_business_group_id;

     l_entityset := 'Employees';
     l_entity := 'Employee';
ELSIF (p_entity_code = 'EMPLOYEES') THEN
  l_query_str := 'select ppv.EMPLOYEE_NUMBER EmployeeNumber, ' ||
'           ppv.LAST_NAME LastName, ' ||
'	   ppv.FIRST_NAME FirstName, ' ||
'	   ppv.D_TITLE Title, ' ||
'	   ppv.PRE_NAME_ADJUNCT Prefix, ' ||
'	   ppv.SUFFIX Suffix, ' ||
'	   ppv.MIDDLE_NAMES MiddleName, ' ||
'	   ppv.D_SEX Sex, ' ||
'	   ppv.D_PERSON_TYPE_ID PersonType, ' ||
'	   ppv.NATIONAL_IDENTIFIER SSNNumber, ' ||
'	   to_char(ppv.DATE_OF_BIRTH,''rrrr-mm-dd'') DateOfBirth, ' ||
'	   ppv.TOWN_OF_BIRTH TownOfBirth, ' ||
'	   ppv.REGION_OF_BIRTH RegionOfBirth, ' ||
'	   ppv.D_COUNTRY_OF_BIRTH CountryOfBirth, ' ||
'	   ppv.D_MARITAL_STATUS MaritalStatus, ' ||
'	   ppv.D_NATIONALITY Nationality, ' ||
'	   ppv.D_REGISTERED_DISABLED_FLAG RegisteredDisabled, ' ||
'	   to_char(ppv.EFFECTIVE_START_DATE,''rrrr-mm-dd'') EffectiveStartDate, ' ||
'	   to_char(ppv.EFFECTIVE_END_DATE,''rrrr-mm-dd'') EffectiveEndDate, ' ||
'	   to_char(ppv.HIRE_DATE,''rrrr-mm-dd'') LatestStartDate, ' ||
'	   ppv.OFFICE_NUMBER Office, ' ||
'	   ppv.INTERNAL_LOCATION Location, ' ||
'	   ppv.EMAIL_ADDRESS EmailId, ' ||
'	   ppv.MAILSTOP MailStop, ' ||
'	   ppv.D_HOME_OFFICE MailTo, ' ||
'	   ppv.RESUME_EXISTS ResumeExists, ' ||
'	   to_char(ppv.RESUME_LAST_UPDATED,''rrrr-mm-dd'') ResumeLastUpdated, ' ||
'	   to_char(ppv.HOLD_APPLICANT_DATE_UNTIL,''rrrr-mm-dd'') HoldApplDateUntil, ' ||
'	   ppv.HONORS Honors, ' ||
'	   ppv.KNOWN_AS PreferredName, ' ||
'	   ppv.PREVIOUS_LAST_NAME PreviousLastName, ' ||
'	   ppv.D_WORK_SCHEDULE WorkSchedule, ' ||
'	   ppv.D_STUDENT_STATUS StudentStatus, ' ||
'	   ppv.FTE_CAPACITY FullTimeAvailability, ' ||
'	   to_char(ppv.DATE_EMPLOYEE_DATA_VERIFIED,''rrrr-mm-dd'') DateLastVerified, ' ||
'	   ppv.D_CORR_LANGUAGE CorrespendenceLang, ' ||
'	   ppv.ON_MILITARY_SERVICE OnMilitaryService, ' ||
'	   ppv.SECOND_PASSPORT_EXISTS SecondPassportExists, ' ||
'	   to_char(ppv.DATE_OF_DEATH,''rrrr-mm-dd'') DateOfDeath, ' ||
'	   ppv.D_BENEFIT_GROUP_NAME BenefitGroupName, ' ||
'	   ppv.D_USES_TOBACCO_FLAG UsesTobacco, ' ||
'	   to_char(ppv.ADJUSTED_SVC_DATE,''rrrr-mm-dd'') AdjustedSrvcDate, ' ||
'	   to_char(ppv.DPDNT_ADOPTION_DATE,''rrrr-mm-dd'') AdoptionDate, ' ||
'	   to_char(ppv.ORIGINAL_DATE_OF_HIRE,''rrrr-mm-dd'') DateFirstHired  ' ||
'  from per_people_v ppv ' ||
' where ppv.S_SYSTEM_PERSON_TYPE = ''EMP'' ' ||
'   and business_group_id = :business_group_id'; --|| p_business_group_id;

     l_entityset := 'Employees';
     l_entity := 'Employee';
ELSIF (p_entity_code = 'BUSINESS_GROUPS') THEN
  l_query_str := 'select hou.NAME Name, ' ||
'          hou.ORGANIZATION_TYPE OrganiationType, ' ||
'          to_char(hou.DATE_FROM,''rrrr-mm-dd'') DateFrom, ' ||
'	   to_char(hou.Date_to,''rrrr-mm-dd'') DateTo, ' ||
'	   hou.LOCATION_CODE Location, ' ||
'	   hou.INTERNAL_EXTERNAL_MEANING Internal, ' ||
'	   hou.INTERNAL_ADDRESS_LINE InternalAddress, ' ||
'	   hoi1.ORG_INFORMATION1_MEANING Classification, ' ||
'          hoi1.org_information1 Enabled, ' ||
'	   hoi.ORG_INFORMATION_CONTEXT AdditionalOrgInfo, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION1'') OrgInfoPmt1, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION2'') OrgInfoPmt2, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION3'') OrgInfoPmt3, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION4'') OrgInfoPmt4, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION5'') OrgInfoPmt5, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION6'') OrgInfoPmt6, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION7'') OrgInfoPmt7, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION8'') OrgInfoPmt8, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION9'') OrgInfoPmt9, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION10'') OrgInfoPmt10, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION11'') OrgInfoPmt11, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION12'') OrgInfoPmt12, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION13'') OrgInfoPmt13, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION14'') OrgInfoPmt14, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION15'') OrgInfoPmt15, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION16'') OrgInfoPmt16, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION17'') OrgInfoPmt17, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION18'') OrgInfoPmt18, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION19'') OrgInfoPmt19, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION20'') OrgInfoPmt20, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION1'',hoi.org_information1) OrgInfo1, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION2'',hoi.org_information2) OrgInfo2, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION3'',hoi.org_information3) OrgInfo3, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION4'',hoi.org_information4) OrgInfo4, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION5'',hoi.org_information5) OrgInfo5, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION6'',hoi.org_information6) OrgInfo6, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION7'',hoi.org_information7) OrgInfo7, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION8'',hoi.org_information8) OrgInfo8, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION9'',hoi.org_information9) OrgInfo9, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION10'',hoi.org_information10) OrgInfo10, ' ||
'	   to_char(to_date(per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION11'',hoi.org_information11),''rrrr/mm/dd hh24:mi:ss''),''rrrr-mm-dd'') OrgInfo11, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION12'',hoi.org_information12) OrgInfo12, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION13'',hoi.org_information13) OrgInfo13, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION14'',hoi.org_information14) OrgInfo14, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION15'',hoi.org_information15) OrgInfo15, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION16'',hoi.org_information16) OrgInfo16, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION17'',hoi.org_information17) OrgInfo17, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION18'',hoi.org_information18) OrgInfo18, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION19'',hoi.org_information19) OrgInfo19, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION20'',hoi.org_information20) OrgInfo20 ' ||
'  from hr_organization_information_v hoi, ' ||
'       hr_organization_information_v hoi1, ' ||
'       hr_organization_units_v hou ' ||
' where hoi.organization_id = hou.ORGANIZATION_ID ' ||
'   and hoi1.organization_id = hou.organization_id ' ||
'   and hoi.organization_id = hoi1.organization_id ' ||
'   and hoi1.org_information1 = ''HR_BG'' '||
'   and hoi.ORG_INFORMATION_CONTEXT = ''Business Group Information'' ' ||
'   and hou.business_group_id = :business_group_id'; --|| p_business_group_id;
     l_entityset := 'BusinessGroups';
     l_entity := 'BusinessGroup';
ELSIF (p_entity_code = 'LEGAL_ENTITIES') THEN
  l_query_str := 'select hou.NAME Name, ' ||
'          hou.ORGANIZATION_TYPE OrganiationType, ' ||
'          to_char(hou.DATE_FROM,''rrrr-mm-dd'') DateFrom, ' ||
'	   to_char(hou.Date_to,''rrrr-mm-dd'') DateTo, ' ||
'	   hou.LOCATION_CODE Location, ' ||
'	   hou.INTERNAL_EXTERNAL_MEANING Internal, ' ||
'	   hou.INTERNAL_ADDRESS_LINE InternalAddress, ' ||
'	   hoi1.ORG_INFORMATION1_MEANING Classification, ' ||
'          hoi1.org_information1 Enabled, ' ||
'	   hoi.ORG_INFORMATION_CONTEXT AdditionalOrgInfo, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION1'') OrgInfoPmt1, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION2'') OrgInfoPmt2, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION3'') OrgInfoPmt3, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION4'') OrgInfoPmt4, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION5'') OrgInfoPmt5, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION6'') OrgInfoPmt6, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION7'') OrgInfoPmt7, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION8'') OrgInfoPmt8, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION9'') OrgInfoPmt9, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION10'') OrgInfoPmt10, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION11'') OrgInfoPmt11, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION12'') OrgInfoPmt12, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION13'') OrgInfoPmt13, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION14'') OrgInfoPmt14, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION15'') OrgInfoPmt15, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION16'') OrgInfoPmt16, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION17'') OrgInfoPmt17, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION18'') OrgInfoPmt18, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION19'') OrgInfoPmt19, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION20'') OrgInfoPmt20, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION1'',hoi.org_information1) OrgInfo1, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION2'',hoi.org_information2) OrgInfo2, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION3'',hoi.org_information3) OrgInfo3, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION4'',hoi.org_information4) OrgInfo4, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION5'',hoi.org_information5) OrgInfo5, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION6'',hoi.org_information6) OrgInfo6, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION7'',hoi.org_information7) OrgInfo7, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION8'',hoi.org_information8) OrgInfo8, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION9'',hoi.org_information9) OrgInfo9, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION10'',hoi.org_information10) OrgInfo10, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION11'',hoi.org_information11) OrgInfo11, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION12'',hoi.org_information12) OrgInfo12, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION13'',hoi.org_information13) OrgInfo13, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION14'',hoi.org_information14) OrgInfo14, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION15'',hoi.org_information15) OrgInfo15, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION16'',hoi.org_information16) OrgInfo16, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION17'',hoi.org_information17) OrgInfo17, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION18'',hoi.org_information18) OrgInfo18, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION19'',hoi.org_information19) OrgInfo19, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION20'',hoi.org_information20) OrgInfo20 ' ||
'  from hr_organization_information_v hoi, ' ||
'       hr_organization_information_v hoi1, ' ||
'       hr_organization_units_v hou ' ||
' where hoi.organization_id = hou.ORGANIZATION_ID ' ||
'   and hoi1.organization_id = hou.organization_id ' ||
'   and hoi.organization_id = hoi1.organization_id ' ||
'   and hoi1.org_information1 = ''HR_LEGAL'' '||
'   and hoi.ORG_INFORMATION_CONTEXT = ''Legal Entity Accounting'' ' ||
'   and hou.business_group_id = :business_group_id'; --|| p_business_group_id;
     l_entityset := 'LegalEntities';
     l_entity := 'LegalEntity';
ELSIF (p_entity_code = 'OPERATING_UNITS') THEN
  l_query_str := 'select hou.NAME Name, ' ||
'          hou.ORGANIZATION_TYPE OrganiationType, ' ||
'          to_char(hou.DATE_FROM,''rrrr-mm-dd'') DateFrom, ' ||
'	   to_char(hou.Date_to,''rrrr-mm-dd'') DateTo, ' ||
'	   hou.LOCATION_CODE Location, ' ||
'	   hou.INTERNAL_EXTERNAL_MEANING Internal, ' ||
'	   hou.INTERNAL_ADDRESS_LINE InternalAddress, ' ||
'	   hoi1.ORG_INFORMATION1_MEANING Classification, ' ||
'          hoi1.org_information1 Enabled, ' ||
'	   hoi.ORG_INFORMATION_CONTEXT AdditionalOrgInfo, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION1'') OrgInfoPmt1, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION2'') OrgInfoPmt2, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION3'') OrgInfoPmt3, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION4'') OrgInfoPmt4, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION5'') OrgInfoPmt5, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION6'') OrgInfoPmt6, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION7'') OrgInfoPmt7, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION8'') OrgInfoPmt8, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION9'') OrgInfoPmt9, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION10'') OrgInfoPmt10, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION11'') OrgInfoPmt11, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION12'') OrgInfoPmt12, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION13'') OrgInfoPmt13, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION14'') OrgInfoPmt14, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION15'') OrgInfoPmt15, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION16'') OrgInfoPmt16, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION17'') OrgInfoPmt17, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION18'') OrgInfoPmt18, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION19'') OrgInfoPmt19, ' ||
'	   per_ri_rt_util_pkg.get_display_prompt(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION20'') OrgInfoPmt20, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION1'',hoi.org_information1) OrgInfo1, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION2'',hoi.org_information2) OrgInfo2, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION3'',hoi.org_information3) OrgInfo3, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION4'',hoi.org_information4) OrgInfo4, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION5'',hoi.org_information5) OrgInfo5, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION6'',hoi.org_information6) OrgInfo6, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION7'',hoi.org_information7) OrgInfo7, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION8'',hoi.org_information8) OrgInfo8, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION9'',hoi.org_information9) OrgInfo9, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION10'',hoi.org_information10) OrgInfo10, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION11'',hoi.org_information11) OrgInfo11, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION12'',hoi.org_information12) OrgInfo12, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION13'',hoi.org_information13) OrgInfo13, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION14'',hoi.org_information14) OrgInfo14, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION15'',hoi.org_information15) OrgInfo15, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION16'',hoi.org_information16) OrgInfo16, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION17'',hoi.org_information17) OrgInfo17, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION18'',hoi.org_information18) OrgInfo18, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION19'',hoi.org_information19) OrgInfo19, ' ||
'	   per_ri_rt_util_pkg.GET_DISPLAY_VALUE(''Org Developer DF'',hoi.org_information_CONTEXT,''ORG_INFORMATION20'',hoi.org_information20) OrgInfo20 ' ||
'  from hr_organization_information_v hoi, ' ||
'       hr_organization_information_v hoi1, ' ||
'       hr_organization_units_v hou ' ||
' where hoi.organization_id = hou.ORGANIZATION_ID ' ||
'   and hoi1.organization_id = hou.organization_id ' ||
'   and hoi.organization_id = hoi1.organization_id ' ||
'   and hoi1.org_information1 = ''OPERATING_UNIT'' '||
'   and hoi.ORG_INFORMATION_CONTEXT = ''Operating Unit Information'' ' ||
'   and hou.business_group_id = :business_group_id'; --|| p_business_group_id;
     l_entityset := 'OperatingUnits';
     l_entity := 'OperatingUnit';
ELSE
  p_xmldata := null;
  RETURN;
END IF;
hr_utility.trace(l_entityset || '.........2');
--hr_utility.trace('Query is ' || l_query_str);

queryCtx     := DBMS_XMLQuery.newContext(l_query_str);
DBMS_XMLQuery.setMaxRows(queryCtx,l_sample_size);
DBMS_XMLQuery.setRowsetTag(queryctx,l_entityset);

hr_utility.trace(l_entityset || '.........3');
DBMS_XMLQuery.setRowTag(queryctx,l_entityset);

DBMS_XMLQuery.setBindValue(queryCtx,'business_group_id',p_business_group_id);

p_xmldata := DBMS_XMLQuery.getXML(queryCtx);
hr_utility.trace(l_entityset || '.........4');

IF (instr(p_xmldata,(l_entityset || '/')) <>0 ) THEN
  p_xmldata := null;
END IF;
hr_utility.trace('Returned' );
EXCEPTION
WHEN OTHERS THEN
   hr_utility.trace(substr(SQLERRM,1,1000));
hr_utility.trace(l_entityset || '.........5');
   RAISE;
END generate_xml;
PROCEDURE apps_initialise IS
begin
  insert into fnd_sessions(session_id,effective_date) values (userenv('SESSIONID'),sysdate);
exception
when others then
  hr_utility.trace(substr(SQLERRM,1,100));
  raise;
end;
END per_ri_rt_util_pkg;

/
