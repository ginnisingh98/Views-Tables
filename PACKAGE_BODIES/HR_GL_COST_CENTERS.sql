--------------------------------------------------------
--  DDL for Package Body HR_GL_COST_CENTERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_GL_COST_CENTERS" AS
/* $Header: hrglcsyn.pkb 120.0 2005/05/31 00:37:09 appldev noship $ */

g_package varchar2(20) := 'hr_gl_cost_centers';
g_max_number_of_retries NUMBER := 10;
g_debug_level varchar2(80) := null;
g_no_cc_proc_exc exception;
g_org_name_length number;

/*
cid number;
g_newline varchar2(10) := fnd_global.newline;
g_tab varchar2(30) := fnd_global.tab;


g_log_file utl_file.file_type;
g_application_short_name VARCHAR2(50) := 'PER';
g_bgid	NUMBER := 0;
g_retcode NUMBER := 0;
g_ccid NUMBER := 0;
g_mode VARCHAR2(30) := null;

g_last_update_login number := 0;

g_start_date DATE;

g_edw_cc_reporting_temp VARCHAR2(40) := 'HR_CC_REPORTING_TEMP';
g_edw_cc_reporting_comp VARCHAR2(40) := 'HR_CC_REPORTING_COMP';
g_edw_sync_temp		VARCHAR2(40) := 'HR_SYNC_TEMP';
g_edw_sync_ccid		VARCHAR2(40) := 'HR_SYNC_GL_CCID';
g_schema		VARCHAR2(10) := null;

*/
Function getDebugState return varchar2 is

cursor c_get_debug is
       select parameter_value
         from pay_action_parameters
	where parameter_name = 'HR_GL_SYNC_DEBUG';
l_debug_level varchar2(80);

BEGIN
  l_debug_level := g_debug_level;
  if l_debug_level is null then
    open c_get_debug;
    fetch c_get_debug into l_debug_level;
    if c_get_debug%NOTFOUND then
      g_debug_level := 'NORMAL';
      close c_get_debug;
    elsif c_get_debug%FOUND then
      g_debug_level := l_debug_level;
      close c_get_debug;
    end if;
  end if;
  return l_debug_level;
END;


Procedure writelog(p_text           in VARCHAR2
                  ,p_error_or_debug in VARCHAR2 default null) IS

l_debug_level varchar2(80);

BEGIN

  l_debug_level := getDebugState();

  if     p_error_or_debug = 'D'
  then
    if l_debug_level = 'DEBUG' then
        fnd_file.put_line(FND_FILE.log, p_text);
    end if;
  elsif p_error_or_debug = 'E' then
    fnd_file.put_line(FND_FILE.log, p_text);
    hr_utility.raise_error;
  else
    fnd_file.put_line(FND_FILE.log, p_text);
  end if;

  hr_utility.set_location(p_text,10);
exception
  when others then
      if SQLCODE = -20100 then
        hr_utility.set_location(substr(p_text,1,100),20);
      else
        hr_utility.set_location('writelog encountered unexpected exception',30);
        raise;
      end if;
END;

Procedure dumpccidtable(p_tablename IN varchar2) is
l_stmt varchar2(2000);
type curType is ref cursor;
c_list curType;
l_ccid number;
l_org_id number;
l_debug_level varchar2(10);
begin

  l_debug_level := getDebugState;
  if l_debug_level <> 'DEBUG' then
    return;
  end if;

  writelog('Dumping table '||p_tablename,'D');
  l_stmt := 'select ccid, org_id from '||p_tablename;
  open c_list for l_stmt;
  loop
      fetch c_list into l_ccid, l_org_id;
      exit when c_list%NOTFOUND;
      writelog('ccid '||to_char(l_ccid),'D');
      writelog('org_id '||to_char(l_org_id),'D');
  end loop;
  close c_list;
end;

Procedure dumptemptable(p_tablename IN varchar2) is
l_stmt varchar2(2000);
type curType is ref cursor;
c_list curType;
l_ccid number;
l_org_id number;
l_chart_of_accounts_id number;
l_company varchar2(240);
l_company_vs number;
l_cc_vs number;
l_cost_center varchar2(240);
l_business_group_id number;
l_debug_level varchar2(10);
begin

  l_debug_level := getDebugState;
  if l_debug_level <> 'DEBUG' then
    return;
  end if;

  writelog('Dumping table '||p_tablename,'D');
  l_stmt := 'select ccid, org_id, chart_of_accounts_id,
             company, company_vs, cost_center, cc_vs,
	     business_group_id from '||p_tablename;
  open c_list for l_stmt;
  loop
      fetch c_list into l_ccid, l_org_id, l_chart_of_accounts_id,
                        l_company, l_company_vs, l_cost_center,
			l_cc_vs, l_business_group_id ;
      exit when c_list%NOTFOUND;
      writelog('ccid '||to_char(l_ccid),'D');
      writelog('org_id '||to_char(l_org_id),'D');
      writelog('coa_id '||to_char(l_chart_of_accounts_id),'D');
      writelog('company '||l_company,'D');
      writelog('company vs '||to_char(l_company_vs),'D');
      writelog('cost_center '||l_cost_center,'D');
      writelog('cost_center vs '||to_char(l_cc_vs),'D');
      writelog('bg id '||to_char(l_business_group_id),'D');
  end loop;
  close c_list;
end;

Procedure droptable(p_tablename IN VARCHAR2,
                    p_force     IN BOOLEAN default TRUE) IS
l_proc          varchar2(50) := g_package||'.droptable';
l_debug_level   varchar2(80);
BEGIN
  hr_utility.set_location('Entering : '||l_proc,10);
  l_debug_level := getDebugState();

  if    p_force
     OR
       (not p_force and
	    l_debug_level <> 'DEBUG') then
    hr_utility.set_location(l_proc,15);
    execute immediate 'drop table '||  p_tablename;
  end if;
  hr_utility.set_location('Leaving : '||l_proc,20);

Exception when others then
  writelog(sqlerrm,'D');
  IF (sqlcode = -942) THEN
    /*
    ** table does not exist at time of dropping which
    ** we can ignore.
    */
    hr_utility.set_location('Leaving : '||l_proc,30);
    null;
  ELSE
    hr_utility.set_location('Leaving : '||l_proc,40);
    raise;
  END IF;

END;

Function reportMissingFlex(p_chart_of_accounts_id  NUMBER,
                           p_cc_segment            VARCHAR2,
			   p_company_segment       VARCHAR2,
			   p_cc_vs                 NUMBER,
			   p_company_vs            NUMBER) return number is

l_retcode number;
l_proc varchar2(150) := g_package||'.reportMissingFlex';
l_message varchar2(150);
begin

  hr_utility.set_location('Entering : '||l_proc,10);

  hr_utility.set_message(800,'PER_289604_WRN_CHRT_ACC_ID');
  fnd_message.set_token('ID',p_chart_of_accounts_id);
  l_message := fnd_message.get();

  writelog(l_message,'W');
  if p_company_segment is NULL then
    writelog(fnd_message.get_string(800,'PER_289605_WRN_COMP_SEG'),'W');
  end if;
  if p_cc_segment is NULL then
    writelog(fnd_message.get_string(800,'PER_289606_WRN_CC_SEG'),'W');
  end if;
  if p_company_vs = -1 then
    writelog(fnd_message.get_string(800,'PER_289607_WRN_COMP_VS'),'W');
  end if;
  if p_cc_vs = - 1 then
    writelog(fnd_message.get_string(800,'PER_289608_WRN_CC_VS'),'W');
  end if;
  l_retcode := 1;
  hr_utility.set_location('Leaving : '||l_proc,20);
  return l_retcode;

end;

Function getProductSchema(p_product IN VARCHAR2) RETURN VARCHAR2  IS
l_dummy1 varchar2(2000);
l_dummy2 varchar2(2000);
l_schema varchar2(400);
l_proc   varchar2(50) := g_package||'.getProductSchema';
BEGIN
  hr_utility.set_location('Entering : '||l_proc,10);
  if FND_INSTALLATION.GET_APP_INFO(p_product
                                  ,l_dummy1
				  ,l_dummy2
				  ,l_schema) = false then
    hr_utility.set_location('Leaving : '||l_proc,15);
    return null;
  end if;
  hr_utility.set_location('Leaving : '||l_proc,20);
  return l_schema;
END;

Procedure writeHeaderFileHeader(p_file    in utl_file.file_type
                               ,p_bgid    in NUMBER
                               ,p_datfile in VARCHAR2) IS
l_bg_name per_business_groups.name%type := null;
l_proc varchar2(50) := g_package||'.writeHeaderFileHeader';
l_tab varchar2(5) := fnd_global.tab;
BEGIN
  hr_utility.set_location('Entering : '||l_proc,10);
  BEGIN
    SELECT name INTO l_bg_name
    from PER_BUSINESS_GROUPS
    WHERE business_group_id = p_bgid;

    utl_file.put_line(P_FILE, 'Header'||l_tab||'Start');
    utl_file.put_line(P_FILE, 'Batch Name'||l_tab||
             substr(l_bg_name||'-'||to_char(sysdate, 'YYYY/MM/DD'), 1, 70));
    utl_file.put_line(P_FILE, 'Date'||l_tab||to_char(sysdate, 'YYYY/MM/DD'));
    utl_file.put_line(P_FILE, 'Version'||l_tab||'1.0');
    utl_file.put_line(P_FILE, 'Date Format'||l_tab||'YYYY/MM/DD');
    utl_file.put_line(P_FILE, 'Number Format'||l_tab||'999999999999999');
    utl_file.put_line(P_FILE, 'Header'||l_tab||'End');
    utl_file.put_line(P_FILE, 'Files'||l_tab||'Start');
    utl_file.put_line(P_FILE, 'create_company_cost_center'||l_tab||p_datfile);
    utl_file.put_line(P_FILE, 'Files'||l_tab||'End');

  Exception
    When no_data_found then
      writelog('Error in writeHeaderFile for business group id : '||p_bgId
              ,'E');
  END;
  hr_utility.set_location('Leaving : '||l_proc,20);
END;

Procedure writeDataFileHeader(p_file IN utl_file.file_type) IS
l_proc varchar2(50) := g_package||'.writeDataFileHeader';
l_tab varchar2(5) := fnd_global.tab;
BEGIN
  hr_utility.set_location('Entering : '||l_proc,10);

  utl_file.put_line(P_FILE, 'Descriptor'||l_tab||'Start');
  utl_file.put_line(P_FILE, 'API'||l_tab||'create_company_cost_center');
  utl_file.put_line(P_FILE, 'Title'||l_tab||'create company cost center');
  utl_file.put_line(P_FILE, 'Process Order'||l_tab||'10');
  utl_file.put_line(P_FILE, 'Descriptor'||l_tab||'End');
  utl_file.put_line(P_FILE, 'Data'||l_tab||'Start');

  utl_file.put_line(P_FILE, 'ID'||l_tab||'organization_name'||l_tab||
                    'costcenter_id'||l_tab||'costcenter_name'||l_tab||
		    'company_id'||l_tab||'company_name'||l_tab||
		    'costcenter_valueset_name'||l_tab||'company_valueset_name'||
		    l_tab||'start_date'||l_tab||'language_code');
  hr_utility.set_location('Leaving : '||l_proc,20);
END;

procedure spoolToFile(p_hr_cc_reporting_temp in varchar2) is

l_proc varchar2(50) := g_package||'.spoolToFile';

type curType is ref cursor;
c_list curType;
c_bg_list curType;

l_company_vs 		NUMBER		:= 0;
l_cc_vs	     		NUMBER		:= 0;

l_counter 		NUMBER		:= 1;
l_bg_id 		NUMBER		:= -1;
l_data_line_counter 	NUMBER		:= 1;

l_company_vsname 	VARCHAR2(80)	:= null;
l_cc_vsname 		VARCHAR2(80)	:= null;
l_company_id       	VARCHAR2(240)	:= null;
l_cost_center_id   	VARCHAR2(240)	:= null;
l_company_name     	VARCHAR2(240)	:= null;
l_cost_center_name 	VARCHAR2(240)	:= null;
l_org_name    		hr_all_organization_units_tl.name%type	:= null;
l_bg_name 		hr_all_organization_units_tl.name%type	:= null;
l_dir 			VARCHAR2(300)	:= null;
l_org_start_date    date ; -- Added by FS

l_hdr_file  		utl_file.file_type;
l_dat_file  		utl_file.file_type;
l_header_file           varchar2(80);
l_data_file             varchar2(80);
l_stmt 			VARCHAR2(3000) := null;
l_retcode               NUMBER;
l_tab                   VARCHAR2(5) := fnd_global.tab;
BEGIN
  hr_utility.set_location('Entering : '||l_proc,10);
  l_dir := fnd_profile.value('PER_DATA_EXCHANGE_DIR');

  writelog('HR profile PER_DATA_EXCHANGE_DIR is set to : '||l_dir,'D');

  IF (l_dir is null) THEN
    hr_utility.set_message(801,'HR_289427_NO_EXC_DIR');
    writelog(fnd_message.get_string('PER','HR_289427_NO_EXC_DIR'),'E');
  END IF;
  hr_utility.set_location(l_proc,20);

  open c_bg_list for 'select distinct rep.business_group_id,
                                      per.name
                        from '||p_hr_cc_reporting_temp ||' rep,
                                per_business_groups per
                       where rep.business_group_id=per.business_group_id';
  loop
    hr_utility.set_location(l_proc,30);
    fetch c_bg_list into l_bg_id, l_bg_name;
    exit when c_bg_list%NOTFOUND or l_bg_id is null;

    l_header_file := 'GLCC_'||replace(substr(l_bg_name,1,30),' ','_')||
                     to_char(l_bg_id)||'.hdr';
    l_data_file   := 'GLCC_'||replace(substr(l_bg_name,1,30),' ','_')||
                     to_char(l_bg_id)||'.txt';
    writelog('Header file name '||l_header_file,'D');
    writelog('Data file name '||l_data_file,'D');

    begin
      hr_utility.set_location(l_proc,50);
      l_hdr_file := utl_file.fopen(l_dir,l_header_file,'w');
    Exception
      when others then
        hr_utility.set_message(801,'HR_289426_INV_EXC_DIR');
	writelog(fnd_message.get_string('PER','HR_289426_INV_EXC_DIR'),'E');
    end;

    hr_utility.set_location(l_proc,60);
    writeHeaderFileHeader(l_hdr_file
                         ,l_bg_id
		         ,l_data_file);
    utl_file.fclose(l_hdr_file);
    hr_utility.set_location(l_proc,70);

    l_dat_file := utl_file.fopen(l_dir, l_data_file,'w');

    writeDataFileHeader(l_dat_file);

    l_stmt :=
        'select distinct reptemp.company_value_set,
                         comp.flex_value_set_name,
			 reptemp.cc_value_set,
                         cc.flex_value_set_name,
                         reptemp.company,
                         reptemp.cost_center,
                         reptemp.org_name,
                         compname.description,
                         ccname.description,
                         reptemp.org_start_date
           from fnd_flex_value_sets comp,
	        fnd_flex_value_sets cc,
                fnd_flex_values_vl compname,
                fnd_flex_values_vl ccname,
                (select distinct company_value_set,
                                 cc_value_set,
                                 company,
				 cost_center,
                                 org_name ,
                                 org_start_date
                   from '||p_hr_cc_reporting_temp|| ') reptemp
          where reptemp.company_value_set = comp.flex_value_set_id
            and reptemp.cc_value_set = cc.flex_value_set_id
            and comp.flex_value_set_id = compname.flex_value_set_id
            and cc.flex_value_set_id = ccname.flex_value_set_id
            and reptemp.company = compname.flex_value
            and reptemp.cost_center = ccname.flex_value ';

    open c_list for l_stmt;
    hr_utility.set_location(l_proc,80);

    loop
      fetch c_list
       into l_company_vs,
            l_company_vsname,
	    l_cc_vs,
	    l_cc_vsname,
            l_company_id,
	    l_cost_center_id,
	    l_org_name,
            l_company_name,
	    l_cost_center_name,
        l_org_start_date ;

      exit when c_list%notfound;

      -- Now Print it to the output file
      utl_file.put_line(l_dat_file,
                        l_data_line_counter||l_tab|| -- ID Column
                        l_org_name||l_tab||          -- Org Name
                        l_cost_center_id||l_tab||    -- Cost Center ID
                        l_cost_center_name||l_tab||  -- Cost Center Name
                        l_company_id||l_tab||        -- Company ID
                        l_company_name||l_tab||      -- Company Name
                        l_cc_vsname ||l_tab||        -- CC VS Name
                        l_company_vsname||l_tab||    -- Company VS Name
                        l_org_start_date||l_tab||
			                             -- Effective_date
                        'US' );                      -- Language_code

      l_data_line_counter := l_data_line_counter + 1;
    end loop;
    hr_utility.set_location(l_proc,90);
    utl_file.put_line(l_dat_file, 'Data'||l_tab||'End');
    utl_file.fclose(l_dat_file);
    writelog('Spooled '||l_data_line_counter||' lines in the data file','D');
    l_data_line_counter := 1;
    l_counter := l_counter +1;
    close c_list;
    hr_utility.set_location(l_proc,100);
  END LOOP;
  hr_utility.set_location(l_proc,110);
  close c_bg_list;

  writelog('Finished Spooling to file.','D');
end;



Function getSegmentForQualifier(p_chart_of_accounts_id in     NUMBER
                               ,p_qualifier            in     VARCHAR2
			       ,p_column_name          in out nocopy VARCHAR2)
return VARCHAR2 is
l_proc varchar2(50) := g_package||'.getSegmentForQualifier';

begin
  hr_utility.set_location('Entering : '||l_proc,10);
  if fnd_flex_apis.get_segment_column(101
                                     ,'GL#'
				     ,p_chart_of_accounts_id
				     ,p_qualifier
				     ,p_column_name) THEN
    hr_utility.set_location(p_qualifier||' segment : '||p_column_name,20);
    hr_utility.set_location('Leaving : '||l_proc,30);
    return 0;
  end if;
  hr_utility.set_location('Leaving : '||l_proc,40);
  return -2;
END;



Function getValueSetForSegment(p_chart_of_accounts_id in     NUMBER
                              ,p_segment              in     VARCHAR2
			      ,p_vs_id                in out nocopy VARCHAR2)
return NUMBER IS
l_proc varchar2(50) := g_package||'.getValueSetForSegment';

type curType is ref cursor;
c_list curType;

l_vs_name fnd_flex_value_sets.flex_value_set_name%TYPE;

BEGIN
  p_vs_id := -1;
  hr_utility.set_location('Entering : '||l_proc,10);
  hr_utility.set_location('coa ID '||p_chart_of_Accounts_id,10);
  hr_utility.set_location('segment '||p_segment,10);

  open c_list for  'select vs.flex_value_set_id,
                           vs.flex_value_set_name
                      from fnd_id_flex_segments_vl seg
	                 , fnd_flex_value_sets vs
	             where upper(seg.id_flex_code) = ''GL#''
	               and seg.application_id = 101
	               and seg.flex_value_set_id = vs.flex_value_set_id
	               and seg.enabled_flag = ''Y''
	               and id_flex_num = :1
	               and application_column_name = :2'
              using p_chart_of_accounts_id, p_segment;
  FETCH c_list into p_vs_id, l_vs_name;
  close c_list;
  hr_utility.set_location(p_segment||' valueset is '||
                          l_vs_name||'('||p_vs_id||')',20);
  hr_utility.set_location('Leaving : '||l_proc,30);
  return 0;
END;


/* ------------------------------------------------------------------------------------------
** --                                                                                      --
** --                      create_org_and_classification                                   --
** --                                                                                      --
** ------------------------------------------------------------------------------------------ */
Function create_org_and_classification (p_mode        in     varchar2
                                       ,p_bg_id       in     number
                                       ,p_company     in     VARCHAR2
				       ,p_cost_center in     VARCHAR2
				       ,p_company_vs  in     number
				       ,p_cc_vs       in     number
				       ,p_ccid        in     number
				       ,p_org_id         out nocopy number)
return NUMBER IS

l_proc varchar2(50) := g_package||'.create_org_and_classification';

l_organization_id number(15) := -1;
l_organization_name HR_ALL_ORGANIZATION_UNITS_TL.NAME%TYPE;
l_ori_ovn number := -1;
l_org_ovn number := -1;
l_ori_inf_id number := -1;
l_org_inf_id number := -1;
l_class_id number;
l_class_ovn number;
l_enabled_flag varchar2(10);
l_new_org_created boolean := FALSE;

l_number_of_retries number;

l_org_profile   varchar2(10) := 'CC';
l_class_profile varchar2(10);

l_company_desc  varchar2(150) := null;
l_cc_desc	varchar2(150) := null;
l_summary_flag  VARCHAR2(10) := null;
type curType is ref cursor;
c_list curType;
l_dummy         varchar2(100);

l_org_name HR_ALL_ORGANIZATION_UNITS_TL.NAME%TYPE := null;
l_orig_org_name HR_ALL_ORGANIZATION_UNITS_TL.NAME%TYPE := null;
l_org_name_format varchar2(60) := null;
l_org_name_suffix varchar2(5) := null;
l_message varchar2(2000);

l_company        varchar2(150);
l_company_vs     varchar2(150);
l_cost_center    varchar2(150);
l_cost_center_vs varchar2(150);
l_comp_start_dt  date; -- Bug# 3204851
l_cc_start_dt    date; -- Bug# 3204851
l_org_start_dt   date; -- BUg# 3208451


cursor csr_chk_org_name is
    select organization_id
     from hr_all_organization_units
    where name = l_org_name
      and business_group_id = p_bg_id;

cursor csr_chk_org_class(p_organization_id number,
                         p_classification  varchar2) is
    select org_information2, org_information_id, object_version_number
      from hr_organization_information ori
     where organization_id = p_organization_id
       and org_information_context = 'CLASS'
       and org_information1 = p_classification;

cursor csr_chk_info_type(p_organization_id number,
                         p_info_type       varchar2) is
    select org_information2,
           org_information3,
	   org_information4,
	   org_information5
      from hr_organization_information ori
     where organization_id = p_organization_id
       and org_information_context = p_info_type;

BEGIN
  hr_utility.set_location('Entering : '||l_proc,10);

  writelog('p_bg_id = '||p_bg_id||' , p_company = '||
           p_company||', p_cost_center = '||p_Cost_center||
	   ', p_company_vs = ' ||p_company_vs||', p_cc_vs = '||p_cc_vs,'D');

  l_org_profile := fnd_profile.value('HR_GENERATE_GL_OPTIONS');
  writelog('HR_GENERATE_GL_OPTIONS : '||l_org_profile,'D');
  if (l_org_profile = 'S') then
    hr_utility.set_location(l_proc,20);
    writelog(fnd_message.get_string('PER','HR_289509_NOT_GEN_GL_ORGS'),'W');
    return -1;
  end if;
  l_class_profile := fnd_profile.value('HR_GENERATE_GL_ORGS');
  writelog('HR_GENERATE_GL_ORGS : '||l_class_profile,'D');
  if     (l_org_profile = 'SC' or l_org_profile = 'SCO')
     and l_class_profile = 'N' then
     writelog(fnd_message.get_string('PER','HR_289478_PROF_OPTS_WARNING'),'E');
  end if;

  hr_utility.set_location(l_proc,30);

  if (p_mode = 'GL') then
    hr_utility.set_location(l_proc,40);
    begin
      select summary_flag
        into l_summary_flag
        from gl_code_combinations
       where code_combination_id = p_ccid;

      if (upper(l_summary_flag) = 'Y') then
        hr_utility.set_location(l_proc,50);
	writelog('PER_289624_SUMM_FLG_CCID');
        return -1;
      end if;

    exception
      when no_data_found then
        hr_utility.set_location(l_proc,60);
	/*
	** This message has got tokens so stick all the stuff
	** on the stack and then pull it off to get the fully
	** translated and token substituted string...
	*/
        hr_utility.set_message(800,'HR_289488_INV_CCID');
	fnd_message.set_token('CCID',p_ccid);
	l_message := fnd_message.get();
	/*
	** ... having got the translated and token substituted message
	** put it all back on the stack so it is found later when the error
	** is raised...
	*/
        hr_utility.set_message(800,'HR_289488_INV_CCID');
	fnd_message.set_token('CCID',p_ccid);
	/*
	** ...now pass the string to writelog and get the error raised.
	*/
	writelog(l_message,'E');
	hr_utility.raise_error;
    end;
  end if; /* p_mode = 'GL' */
  hr_utility.set_location(l_proc,70);

  /* Check if Org already exists using company and cost center valueset/value
  ** information
  */

  l_organization_id := -1;
  open c_list for 'select units.organization_id, units.name
                     from hr_all_organization_units_tl  units,
                          hr_organization_information class,
			  hr_organization_information cc
                    where units.organization_id = class.organization_id
                      and class.org_information_context=''CLASS''
		      and class.org_information1=''CC''
                      and class.organization_id = cc.organization_id
                      and cc.org_information_context = ''Company Cost Center''
                      and cc.org_information2 = :1
		      and cc.org_information4 = :2
                      and cc.org_information3 = :3
		      and cc.org_information5 = :4 '
              using to_char(p_company_vs), to_char(p_cc_vs), p_company,
	            p_cost_center;

  fetch c_list into l_organization_id,l_organization_name;
  close c_list;
  hr_utility.set_location(l_proc,80);

  if (l_organization_id <> -1) then
    hr_utility.set_location(l_proc,83);
    /*
    ** This message has got tokens so stick all the stuff
    ** on the stack and then pull it off to get the fully
    ** translated and token substituted string...
    */
    hr_utility.set_message(800,'HR_289600_ORG_ALRDY');
    fnd_message.set_token('NAME',l_organization_name);
    fnd_message.set_token('COMPANY',p_company);
    fnd_message.set_token('COST',p_cost_center);
    l_message := fnd_message.get();
    /*
    ** ...now pass the string to writelog.
    */
    writelog(l_message,'I');
    p_org_id := l_organization_id;
    return 0;
  end if; /* l_organization_id <> -1 */

  /*
  ** To get this far we failed to find an organization which has the the company and cost center
  ** information defined for it.  This means we are going to try and find it by name.  If we don't
  ** find it then we'll create a new org with the appropriate classification and info type.  If
  ** we don find a match by name we'll check for the CC classification and orig info and do the
  ** appropriate thing (see below what the "appropriate thing" is).
  */

  /* First derive the organization name....
  */
  open c_list for 'select description ,start_date_active
                     from fnd_flex_values_vl
		    where flex_value_set_id = :1
		      and flex_value = :2 '
              using p_company_vs, p_company;
  fetch c_list into l_company_desc,l_comp_start_dt;
  close c_list;
  hr_utility.set_location(l_proc,86);

  if (l_company_desc is null) then
    l_company_desc := p_company;
  end if;

  open c_list for 'select description ,start_date_active
                     from fnd_flex_values_vl
                     where flex_value_set_id = :1
		      and flex_value = :2'
              using p_cc_vs, p_cost_center;
  fetch c_list into l_cc_desc,l_cc_start_dt;
  close c_list;
  hr_utility.set_location(l_proc,90);

  if (l_cc_desc is null) then
    l_cc_desc := p_cost_center;
  end if;

  /* Bug   3208451
  ** Set the Org start date to the latest of company or cost center start date
  ** and Set it to default date 01/01/1990'  if the value fetched from abse table is null
  */

  l_org_start_dt := greatest(nvl(l_cc_start_dt,to_date('01/01/1990','DD/MM/RRRR')),nvl(l_comp_start_dt,to_date('01/01/1990','DD/MM/RRRR')));
  if to_char(l_org_start_dt ,'DD/MM/RRRR')= '01/01/1900' then
     l_org_start_dt := to_date('01/01/1990','DD/MM/RRRR');
  end if ;


  /* Read the Org Name Format */
  l_org_name_format := fnd_profile.value('HR_GL_ORG_NAME_FORMAT');
  if (l_org_name_format IS NULL) then
    hr_utility.set_location(l_proc,100);
    hr_utility.set_message(801,'HR_289489_NO_NAME_FORMAT');
    writelog(fnd_message.get_string('PER','HR_289489_NO_NAME_FORMAT'),'E');
  end if;

  hr_utility.set_location(l_proc,110);
  writelog('Org Format is : '||l_org_name_format,'D');
  /*
  ** Build the organization name by Substituting the available componenents
  ** using the organization name format string defined.
  */
  select substrb(
                REPLACE(
                 REPLACE(
                  REPLACE(
                   REPLACE(l_org_name_format,'$COC', p_company),
                          '$CCC', p_cost_center),
                     '$CON', l_company_desc),
                 '$CCN', l_cc_desc), 1, g_org_name_length)
    into l_org_name
    from dual;

  hr_utility.set_location(l_proc,120);
  l_org_name := substrb(l_org_name, 1, g_org_name_length);
  l_orig_org_name := l_org_name;
  writelog('Org to be created is : '||l_org_name,'D');

  /*
  ** We've got the Org name so look to see if an organization with
  ** this name already exists.
  */
  open csr_chk_org_name;
  fetch csr_chk_org_name into l_organization_id;

  if (csr_chk_org_name%NOTFOUND) then
    hr_utility.set_location(l_proc,125);

    if l_org_profile = 'SCO' then
      /*
      ** No organization exists with this name and we want to create missing
      ** organizations so go ahead and create one with the required
      ** classifications.
      */
      close csr_chk_org_name;

      begin
   	hr_utility.set_location(l_proc||' org name '||l_org_name,130);
   	hr_organization_api.create_organization
   				(p_effective_date => sysdate
   				,p_business_group_id => p_bg_id
   				,p_date_from =>  l_org_start_dt
   				,p_name => l_org_name
   				,p_internal_external_flag => 'INT'
   				,p_organization_id => l_organization_id
   				,p_object_version_number => l_org_ovn);
   	writelog('Completed create_organization, org_id = '||l_organization_id,'D');
	l_new_org_created := TRUE;
   	hr_utility.set_location(l_proc,140);
      exception
   	when OTHERS then
   	  /* We got an error in creating the org.  Write this to the log file and
   	  ** stop processing this company cost center.
   	  */
   	  writelog('Error while creating Organization, name = '|| l_org_name,'W');
   	  writelog('Error : '|| SQLCODE ||' - '|| SQLERRM,'W');
   	  return -1;
      end;

      if (l_class_profile LIKE 'CC%') then
   	/* The HR_GENERATE_GL_ORGS contains the token indicating we should create
   	** a Company Cost Center(Class = 'CC') classification/info type.
   	*/
   	begin
   	  hr_utility.set_location(l_proc,150);
   	  hr_organization_api.create_company_cost_center
   				(p_effective_date => sysdate
   				,p_organization_id=>l_organization_id
   				,p_company_valueset_id => p_company_vs
   				,p_company => p_company
   				,p_costcenter_valueset_id => p_cc_vs
   				,p_costcenter => p_cost_center
   				,p_ori_org_information_id => l_ori_inf_id
   				,p_ori_object_version_number => l_ori_ovn
   				,p_org_information_id => l_class_id
   				,p_object_version_number=>l_class_ovn);

   	  writelog('Completed creating CC classification, org_info_id = '||
   		   l_ori_inf_id,'D');
   	exception
   	  when OTHERS then
   	    /* We got an error in creating the classificationand info type.  Write this to
   	    ** the log file and stop processing this company cost center.
   	    */
   	    writelog('Error while creating CC classification, org_name = '|| l_org_name,'W');
   	    writelog('Error : '|| SQLCODE ||' - '|| SQLERRM, 'W');
   	    return -1;
   	end;
      end if;
      hr_utility.set_location(l_proc,160);

      if (l_class_profile = 'CCHR') then
   	/* The HR_GENERATE_GL_ORGS contains the token indicating we should create
   	** an HR Organization(Class = 'HR_ORG') classification.
   	*/
        open csr_chk_org_class(l_organization_id, 'HR_ORG');
        fetch csr_chk_org_class into l_enabled_flag, l_class_id, l_class_ovn;

        if csr_chk_org_class%NOTFOUND then
    	  hr_utility.set_location(l_proc,300);


           	begin
           	  hr_utility.set_location(l_proc,170);
           	  hr_organization_api.create_org_classification
           				(p_effective_date => sysdate
           				,p_organization_id=>l_organization_id
           				,p_org_classif_code =>'HR_ORG'
           				,p_org_information_id => l_class_id
           				,p_object_version_number => l_class_ovn);
           	exception
           	  when OTHERS then
              IF csr_chk_org_class%isopen then
                  close csr_chk_org_class;
              end if;
           	    /* We got an error in creating the classification.  Write this to
           	    ** the log file and stop processing this company cost center.
           	    */
           	    writelog('Error while creating Org classification, org_name = '|| l_org_name,'W');
           	    writelog('Error : '|| SQLCODE ||' - '|| SQLERRM, 'W');
           	    return -1;
           	end;
       	  end if; /* csr_chk_org_class */

          IF csr_chk_org_class%isopen then
             close csr_chk_org_class;
          end if;

      end if;

    end if; /* l_org_profile = 'SCO' */

  else /* csr_chk_org_name%NOTFOUND */

    /* We found an organization which matches by name so we'll do the following...
    **
    ** Check for the presence of a Company Cost Center org classification.
    ** If we have one then (A)
    **   check the classified org has the cost center info type.
    **   if the org info type is not present then (B)
    **      Add the cost center org info type
    **   if the org info type is present with no data then (C)
    **      Update the info type and link the org to the current cost center.
    **   if the org info type is present with data then (D)
    **      Derive an unique org name and create a new org with classification as required.
    ** if we don't have an org classification then (E)
    **   Create the Company Cost Center Org classification and info type.
    ** Add the HR_ORG classification if the profile indicates it's required and the
    ** organization does not have it already.
    */
    hr_utility.set_location(l_proc,180);
    close csr_chk_org_name;

    open csr_chk_org_class(l_organization_id, 'CC');
    fetch csr_chk_org_class into l_enabled_flag, l_class_id, l_class_ovn;

    if csr_chk_org_class%FOUND then --> A
      hr_utility.set_location(l_proc,190);
      close csr_chk_org_class;

      open csr_chk_info_type(l_organization_id, 'Company Cost Center');
      fetch csr_chk_info_type into l_company, l_company_vs, l_cost_center,
                                   l_cost_center_vs;

      if csr_chk_info_type%NOTFOUND then --> B
        /*
	** The org exists with the CC class but without the info type therefore
	** create the Company Cost Center org information type.
	*/
        hr_utility.set_location(l_proc,200);
	close csr_chk_info_type;

        begin
	  if l_enabled_flag = 'N' then
	    /* The class is disabled.  Temporarily enable it.
	    */
	    hr_organization_api.enable_org_classification(
	                 p_effective_date => sysdate,
			 p_org_information_id => l_class_id,
			 p_org_info_type_code => 'CC',
			 p_object_version_number => l_class_ovn);
	  end if;

          hr_utility.set_location(l_proc,210);
          hr_organization_api.create_org_information
                              (p_effective_date => sysdate
                              ,p_organization_id=>l_organization_id
			      ,p_org_info_type_code => 'Company Cost Center'
			      ,p_org_information2 => p_company_vs
			      ,p_org_information3 => p_company
			      ,p_org_information4 => p_cc_vs
			      ,p_org_information5 => p_cost_center
                              ,p_org_information_id => l_ori_inf_id
                              ,p_object_version_number=>l_ori_ovn);

          writelog('Completed creating CC classification, org_info_id = '||
                   l_ori_inf_id,'D');

	  if l_enabled_flag = 'N' then
	    /* The class is disabled.  Reset it....
	    */
	    hr_organization_api.disable_org_classification(
	                 p_effective_date => sysdate,
			 p_org_information_id => l_class_id,
			 p_org_info_type_code => 'CC',
			 p_object_version_number => l_class_ovn);

	  end if;

        exception
          when OTHERS then
	    /* We got an error in creating the info type.  Write this to
	    ** the log file and stop processing this company cost center.
	    */
            writelog('Error while creating Company Cost Center info type,
	              org_name = '||l_org_name,'W');
            writelog('Error : '|| SQLCODE ||' - '|| SQLERRM,'W');
            return -1;
        end;

        if (l_class_profile = 'CCHR') then
   	  /* The HR_GENERATE_GL_ORGS contains the token indicating we should create
   	  ** an HR Organization(Class = 'HR_ORG') classification.
   	  */
      open csr_chk_org_class(l_organization_id, 'HR_ORG');
      fetch csr_chk_org_class into l_enabled_flag, l_class_id, l_class_ovn;

      if csr_chk_org_class%NOTFOUND then
		hr_utility.set_location(l_proc,310);


       	  begin
       	    hr_utility.set_location(l_proc,220);
       	    hr_organization_api.create_org_classification
       				(p_effective_date => sysdate
       				,p_organization_id=>l_organization_id
       				,p_org_classif_code =>'HR_ORG'
       				,p_org_information_id => l_class_id
       				,p_object_version_number => l_class_ovn);
       	  exception
       	    when OTHERS then
              IF csr_chk_org_class%isopen then
                  close csr_chk_org_class;
              end if;
       	      /* We got an error in creating the classification.  Write this to
       	      ** the log file and stop processing this company cost center.
       	      */
       	      writelog('Error while creating Org classification, org_name = '|| l_org_name,'W');
       	      writelog('Error : '|| SQLCODE ||' - '|| SQLERRM, 'W');
       	      return -1;
       	  end;
      end if; /* csr_chk_org_class */
      IF csr_chk_org_class%isopen then
	     close csr_chk_org_class;
      end if;

   	end if; /* l_org_profile = 'CCHR' */

      else /* csr_chk_info_type%NOTFOUND */
        /*
	** Check the data on the info type and proceed as appropriate.
	*/
        hr_utility.set_location(l_proc,220);
        close csr_chk_info_type;

        if     l_company is null
	   and l_cost_center is null
	   and l_company_vs is null
	   and l_cost_center_vs is null then --> C
	  /*
	  ** The info type is present but empty.  This should never happen since
	  ** the Company Value Set segment is mandatory.
	  */
          hr_utility.set_location(l_proc,230);
	  null;
	else --> D
	  /*
	  ** The info type is present with data but to have got to this point
	  ** the data for the organization must be different to what we have
	  ** for the current cost center.  We need to derive a new org name
	  ** and create the org, the classification and the info type if we
	  ** are creating new orgs.
	  */
          hr_utility.set_location(l_proc,240);

	  /*
	  ** Reset the organization ID since the org we found is of no use
	  ** to us.
	  */
	  l_organization_id := -1;

	  if l_org_profile = 'SCO' then
	    /*
	    ** We are creating missing organizations so continue...
	    */

   	    l_number_of_retries := 1;
   	    /*
   	    ** We need to find an organization name which is not used and then create the org
   	    ** using that name. We will use a similar method to that used by FNDLOAD to resolve
   	    ** duplicate description/meaning values by suffixing "(n)" to the end of the derived
   	    ** org name increasing n until we find a unique name.
   	    **
   	    ** Since we already know an org exists with the name we derived modify the name
   	    ** we have to add the first possible suffix.
   	    */
   	    l_org_name_suffix := ' ('||to_char(l_number_of_retries)||')';
   	    l_org_name := substrb(l_org_name,1,
   				 g_org_name_length-length(l_org_name_suffix))||
   							  l_org_name_suffix;
   	    loop
   	      hr_utility.set_location(l_proc,250);
   	      l_organization_id := null;
   	      open csr_chk_org_name;
   	      fetch csr_chk_org_name into l_organization_id;
   	      close csr_chk_org_name;
   	      /*
   	      ** If the above did not find anything exit otherwise we'll carry on....
   	      ** but only so far, exit if we hit the max number of tries...
   	      */
   	      exit when l_organization_id is null;
   	      exit when l_number_of_retries = g_max_number_of_retries;

   	      /*
   	      ** To get this far the org name is already in use, so let's add
   	      ** a suffix and try that...
   	      */
   	      l_org_name_suffix := ' ('||to_char(l_number_of_retries)||')';
   	      l_org_name := substrb(l_org_name,1,
   				   g_org_name_length-length(l_org_name_suffix))||
   							    l_org_name_suffix;
   	      l_number_of_retries := l_number_of_retries + 1;

   	    end loop;

   	    if (    l_organization_id IS NULL
   		AND l_number_of_retries <> g_max_number_of_retries) then
   	      /*
   	      ** We got an unused org name so create the org...
   	      */
   	      hr_utility.set_location(l_proc,260);

   	      begin
   		hr_utility.set_location(l_proc||' org name '||l_org_name,130);
   		hr_organization_api.create_organization
   				(p_effective_date => sysdate
   				,p_business_group_id => p_bg_id
   				,p_date_from => l_org_start_dt
   				,p_name => l_org_name
   				,p_internal_external_flag => 'INT'
   				,p_organization_id => l_organization_id
   				,p_object_version_number => l_org_ovn);
   		writelog('Completed create_organization, org_id = '||l_organization_id,'D');
                l_new_org_created := TRUE;
   		hr_utility.set_location(l_proc,140);
   	      exception
   		when OTHERS then
   		  /* We got an error in creating the org.  Write this to the log file and
   		  ** stop processing this company cost center.
   		  */
   		  writelog('Error while creating Organization, name = '|| l_org_name,'W');
   		  writelog('Error : '|| SQLCODE ||' - '|| SQLERRM,'W');
   		  return -1;
   	      end;

   	      if (l_class_profile LIKE 'CC%') then
   		/* The HR_GENERATE_GL_ORGS contains the token indicating we should create
   		** a Company Cost Center(Class = 'CC') classification/info type.
   		*/
   		begin
   		  hr_utility.set_location(l_proc,150);
   		  hr_organization_api.create_company_cost_center
   				(p_effective_date => sysdate
   				,p_organization_id=>l_organization_id
   				,p_company_valueset_id => p_company_vs
   				,p_company => p_company
   				,p_costcenter_valueset_id => p_cc_vs
   				,p_costcenter => p_cost_center
   				,p_ori_org_information_id => l_ori_inf_id
   				,p_ori_object_version_number => l_ori_ovn
   				,p_org_information_id => l_class_id
   				,p_object_version_number=>l_class_ovn);

   		  writelog('Completed creating CC classification, org_info_id = '||
   			   l_ori_inf_id,'D');
   		exception
   		  when OTHERS then
   		   /* We got an error in creating the classificationand info type.  Write this to
   		   ** the log file and stop processing this company cost center.
   		   */
   		   writelog('Error while creating CC classification, org_name = '|| l_org_name,'W');
   		   writelog('Error : '|| SQLCODE ||' - '|| SQLERRM, 'W');
   		   return -1;
   		end;
   	      end if; /* l_org_profile LIKE 'CC%' */
   	      hr_utility.set_location(l_proc,160);

   	      if (l_class_profile = 'CCHR') then
   		/* The HR_GENERATE_GL_ORGS contains the token indicating we should create
   		** an HR Organization(Class = 'HR_ORG') classification.
   		*/
              open csr_chk_org_class(l_organization_id, 'HR_ORG');
              fetch csr_chk_org_class into l_enabled_flag, l_class_id, l_class_ovn;

            if csr_chk_org_class%NOTFOUND then
		        hr_utility.set_location(l_proc,315);

   		begin
   		  hr_utility.set_location(l_proc,170);
   		  hr_organization_api.create_org_classification
   				(p_effective_date => sysdate
   				,p_organization_id=>l_organization_id
   				,p_org_classif_code =>'HR_ORG'
   				,p_org_information_id => l_class_id
   				,p_object_version_number => l_class_ovn);
   		exception
   		  when OTHERS then
              IF csr_chk_org_class%isopen then
                  close csr_chk_org_class;
              end if;
   		    /* We got an error in creating the classification.  Write this to
   		    ** the log file and stop processing this company cost center.
   		    */
   		    writelog('Error while creating Org classification, org_name = '|| l_org_name,'W');
   		    writelog('Error : '|| SQLCODE ||' - '|| SQLERRM, 'W');
   		   return -1;
   		end;
        end if ;/* csr_chk_org_class */
          IF csr_chk_org_class%isopen then
             close csr_chk_org_class;
          end if;

   	      end if; /* l_org_profile = 'CCHR' */

   	    else
   	      /*
   	      ** We exited the loop above without finding a unique org name
   	      ** so raise an error to this effect.
   	      ** Need to do the same messing about as earlier as this has tokens....
   	      */
   	      hr_utility.set_message(801,'HR_289490_NO_UNIQ_NAME');
   	      fnd_message.set_token('ORG_NAME',l_orig_org_name);
   	      l_message := fnd_message.get();
   	      hr_utility.set_message(801,'HR_289490_NO_UNIQ_NAME');
   	      fnd_message.set_token('ORG_NAME',l_orig_org_name);
   	      writelog(l_message,'W');
   	      return -1;
   	    end if; /* l_organization_id IS NULL */

	  end if; /* l_org_profile = SCO */

	end if; /* l_company is null */

      end if; /* csr_chk_info_type%NOTFOUND */

    else /* --> E csr_chk_org_class%FOUND */
      /*
      ** We don't have a company cost center classification for this org so
      ** create it together with the info type data.
      */
      hr_utility.set_location(l_proc,250);
      IF csr_chk_org_class%isopen then
         close csr_chk_org_class;
      end if;

      if (l_class_profile LIKE 'CC%') then
        /* The HR_GENERATE_GL_ORGS contains the token indicating we should create
        ** a Company Cost Center(Class = 'CC') classification/info type.
        */
        begin
          hr_utility.set_location(l_proc,150);
          hr_organization_api.create_company_cost_center
                              (p_effective_date => sysdate
                              ,p_organization_id=>l_organization_id
                              ,p_company_valueset_id => p_company_vs
                              ,p_company => p_company
                              ,p_costcenter_valueset_id => p_cc_vs
                              ,p_costcenter => p_cost_center
                              ,p_ori_org_information_id => l_ori_inf_id
                              ,p_ori_object_version_number => l_ori_ovn
                              ,p_org_information_id => l_class_id
                              ,p_object_version_number=>l_class_ovn);

          writelog('Completed creating CC classification, org_info_id = '||
                   l_ori_inf_id,'D');
        exception
          when OTHERS then
    	    /* We got an error in creating the classificationand info type.  Write this to
	    ** the log file and stop processing this company cost center.
 	    */
            writelog('Error while creating CC classification, org_name = '|| l_org_name,'W');
            writelog('Error : '|| SQLCODE ||' - '|| SQLERRM, 'W');
            return -1;
        end;
      end if; /* l_org_profile LIKE 'CC%' */
      hr_utility.set_location(l_proc,160);

      if (l_class_profile = 'CCHR') then
        /* The HR_GENERATE_GL_ORGS contains the token indicating we should create
        ** an HR Organization(Class = 'HR_ORG') classification.  Only do this if
	** the org does not already have this classification.
        */
      open csr_chk_org_class(l_organization_id, 'HR_ORG');
      fetch csr_chk_org_class into l_enabled_flag, l_class_id, l_class_ovn;

      if csr_chk_org_class%NOTFOUND then
	   hr_utility.set_location(l_proc,320);
          begin
            hr_utility.set_location(l_proc,170);
            hr_organization_api.create_org_classification
                              (p_effective_date => sysdate
                              ,p_organization_id=>l_organization_id
                              ,p_org_classif_code =>'HR_ORG'
                              ,p_org_information_id => l_class_id
                              ,p_object_version_number => l_class_ovn);
          exception
            when OTHERS then
    	      /* We got an error in creating the classification.  Write this to
 	      ** the log file and stop processing this company cost center.
	      */
              IF csr_chk_org_class%isopen then
                  close csr_chk_org_class;
              end if;
              writelog('Error while creating Org classification, org_name = '||
	               l_org_name,'W');
              writelog('Error : '|| SQLCODE ||' - '|| SQLERRM, 'W');
              return -1;
          end;

        end if; /*csr_chk_org_class%NOTFOUND */
          IF csr_chk_org_class%isopen then
             close csr_chk_org_class;
          end if;

      end if; /* l_org_profile = 'CCHR' */

    end if; /* csr_chk_org_class%FOUND */

  end if; /* csr_chk_org_name%NOTFOUND */

  if l_organization_id > -1  then
    if l_new_org_created then
      hr_utility.set_message(800,'HR_289195_SYNCD_NEW_ORG');
      fnd_message.set_token('NAME',l_org_name);
      fnd_message.set_token('COMPANY',p_company);
      fnd_message.set_token('COST',p_cost_center);
      l_message := fnd_message.get();
    else
      hr_utility.set_message(800,'HR_289177_SYNCD_ORG');
      fnd_message.set_token('NAME',l_org_name);
      fnd_message.set_token('COMPANY',p_company);
      fnd_message.set_token('COST',p_cost_center);
      l_message := fnd_message.get();
    end if;
    /*
    ** ...now pass the string to writelog.
    */
    writelog(l_message,'I');
  end if;
  hr_utility.set_location('Leaving : '||l_proc,180);
  p_org_id := l_organization_id;
  return 0;

end create_org_and_classification;


function getBGID(p_company IN VARCHAR2
                ,p_companyvs IN NUMBER)
return NUMBER is
l_proc varchar2(50) := g_package||'getBGID';
l_bgid number := -1;
l_count		NUMBER := 0;

TYPE number_tab IS TABLE OF number;
l_bg_tab number_tab;

cursor company_bg  is
  select distinct units.business_group_id
    from hr_all_organization_units units,
         hr_organization_information class,
	 hr_organization_information cc
   where units.organization_id = class.organization_id
     and class.org_information_context='CLASS'
     and class.org_information1='CC'
     and class.organization_id = cc.organization_id
     and cc.org_information_context = 'Company Cost Center'
     and cc.org_information3 = p_company
     and cc.org_information2 = to_char(p_companyvs)
     and cc.org_information4 is null
     and cc.org_information5 is null;

begin
  hr_utility.set_location('Entering : '||l_proc,10);

  open company_bg;
  fetch company_bg bulk collect into l_bg_tab limit 10;
  close company_bg;

  hr_utility.set_location(l_proc,20);

  if (l_bg_tab.count > 1) then -- This company exists in more than 1 BG, so error
    hr_utility.set_location(l_proc,30);
    l_bgid:=-1;
    writelog(fnd_message.get_string('PER','HR_289491_CO_MULT_BG'),'E');
  elsif (l_bg_tab.count = 0) then -- This company does not exist in any BG so error
    hr_utility.set_location(l_proc,30);
    l_bgid:=-1;
    writelog('Company : '||p_company,'D');
    writelog('Company VS: '||to_char(p_companyvs),'D');
    writelog(fnd_message.get_string('PER','HR_289601_CO_NO_BG'),'E');
  elsif l_bg_tab.count = 1 then
    hr_utility.set_location(l_proc,40);
    l_bgid := l_bg_tab(1);
    writelog('bg id '||l_bgid,'D');
    hr_utility.set_location(l_proc||' BG id '||to_char(l_bgid),45);
  end if;

  hr_utility.set_location('Leaving : '||l_proc,50);
  return l_bgid;
END;


/*---------------------------------------------------------------------------
   Find all the different Chart of Accounts where company_cost_center_org_id is
   null.
   For each COA, get the distinct company cost center combinations for which
   company_cost_center_org_id is null.
   For each of these combinations, find the business group for the company.

 ---------------------------------------------------------------------------*/


function reportingMode(p_application_short_name in varchar2,
                       p_hr_cc_reporting_temp   in varchar2,
                       p_bgid                   in number,
                       p_coa                    in number)  -- Fix for Bug 2875915
return NUMBER is

l_proc VARCHAR2(50) := g_package||'.reportingMode';
l_no_flex_value exception;

l_company_segment VARCHAR2(40) := null;
l_cc_segment	  VARCHAR2(40) := null;
l_company         VARCHAR2(240) :=NULL;
l_cost_center     VARCHAR2(240) := NULL;
l_chart_of_accounts_id NUMBER := 0;
l_company_vs NUMBER := -1;
l_cc_vs NUMBER := -1;

l_schema varchar2(30) := null;
l_stmt varchar2(1000) := null;
l_stmt2 varchar2(1000) := null;

l_org_stmt   VARCHAR2(1000) := null;
l_temp_stmt  varchar2(300) := null;
l_org_name   HR_ALL_ORGANIZATION_UNITS_TL.NAME%TYPE := null;
l_retcode    number := 0;
l_retcode1   number :=0;
l_org_name_format varchar2(60) := null;
l_stmt1   varchar2(2000) :=null;
l_comp_start_date_active date;
l_cc_start_date_active  date;
l_company_name varchar2(240) := null;
l_cost_center_name varchar2(240) := null;

cursor c_coas is
     select distinct chart_of_accounts_id
       from gl_sets_of_books               --Bug 3264485
       where chart_of_accounts_id = p_coa
             or p_coa is null ; -- Fix for Bug 2875915

type curType is ref cursor;
c_list curType;
c_list2 curType;
l_rowcount number;
-----

cursor c_value(p_vs number, p_segment varchar2) is
   select description, start_date_active
   from fnd_flex_values_vl
   where flex_value_set_id= p_vs
     and p_segment = flex_value;

----
begin
  hr_utility.set_location('Entering : '||l_proc,10);

  begin
    droptable(p_hr_cc_reporting_temp,TRUE);
  end;
  hr_utility.set_location(l_proc,20);

  execute immediate 'create table '||p_hr_cc_reporting_temp ||'
                (cc_value_set         number,
		 company_value_set    number,
                 chart_of_accounts_id number,
		 company              varchar2(240),
                 cost_center          varchar2(240),
		 org_name             varchar2(240),
                 business_group_id    number,
		 business_group_name  varchar2(240),
		 company_name         varchar2(240),
		 cost_center_name     varchar2(240),
         org_start_date date)';  --  Bug Fix 3208451

  for l_coas in c_coas
  loop
  --

    hr_utility.set_location(l_proc||' chart of acct ID '||
                            to_char(l_coas.chart_of_accounts_id),30);

    l_retcode := getSegmentForQualifier(l_coas.chart_of_accounts_id,
                               'GL_BALANCING',
			       l_company_segment);
    l_retcode := getSegmentForQualifier(l_coas.chart_of_accounts_id,
                               'FA_COST_CTR',
			       l_cc_segment);
    l_retcode := getValueSetForSegment(l_coas.chart_of_accounts_id,
                              l_company_segment,
			      l_company_vs);
    l_retcode := getValueSetForSegment(l_coas.chart_of_accounts_id,
                              l_cc_segment,
      		              l_cc_vs);


    if (l_cc_segment is NOT NULL and
        l_company_segment IS NOT NULL and
        l_company_vs <> -1 and
	    l_cc_vs <> -1) then
      hr_utility.set_location(l_proc,40);

      open c_list2  for 'SELECT /*+ORDERED USE_NL(gcc)*/
		                distinct  gcc.'||l_company_segment||' company,
				        gcc.'||l_cc_segment ||' cost_center
                         FROM gl_code_combinations gcc
		         WHERE gcc.company_cost_center_org_id is null
		           AND gcc.summary_flag = ''N''
		           AND gcc.chart_of_accounts_id = '||l_coas.chart_of_accounts_id||
                          'AND  gcc.'||l_company_segment||' is not null
			   AND  gcc.'||l_cc_segment ||' is not null';

  --
 loop
  fetch c_list2 into l_company, l_cost_center;

    exit when c_list2%notfound;
    begin
        --
        --    writelog('l_coas.chart_of_accounts_id'||l_coas.chart_of_accounts_id);
        --    writelog('l_company '||l_company);
        --   writelog('l_cc '||l_cost_center);
        --   writelog('l_company_vs '||l_company_vs);
        --   writelog('l_cc_vs '||l_cc_vs);
        --
       open c_value (l_company_vs, l_company);
          fetch c_value into l_company_name,l_comp_start_date_active;
           if c_value%notfound then
              close c_value;
              raise l_no_flex_value;
           end if;
          close c_value;
       --
       open c_value (l_cc_vs, l_cost_center);
         fetch c_value into l_cost_center_name,l_cc_start_date_active;
          if c_value%notfound then
             close c_value;
             raise l_no_flex_value;
          end if;
       close c_value;
     --

  l_stmt := 'INSERT INTO '||p_hr_cc_reporting_temp ||'
	                     	      (cc_value_set,
                     		       company_value_set,
	                               chart_of_accounts_id,
                    		       company,
                    		       cost_center,
                    		       business_group_id,
                    		       company_name,
                        	       cost_center_name,
                                   org_start_date)
                      		VALUES (:1,
                    		        :2,
                        		:3,
                        		:4,
                    		        :5,
                                        :6,
                                        :7,
                                        :8,
                                    greatest(nvl(:9 ,to_date(''01/01/1900'',''DD/MM/RRRR'')),
                                    nvl(:10 ,to_date(''01/01/1900'',''DD/MM/RRRR''))))';
             -- writelog ('SUCCESS');
           execute immediate l_stmt using l_cc_vs,
                                          l_company_vs,
			                  l_coas.chart_of_accounts_id,
                        		  l_company,
                    		          l_cost_center,
                                          p_bgid,
                                          l_company_name,
                                          l_cost_center_name,
                                          l_cc_start_date_active,
                                          l_comp_start_date_active;

       --
    exception
    when l_no_flex_value then
       writelog('Error while processing for Code Combination Id:'||l_coas.chart_of_accounts_id, 'W' );
       writelog('having Cost Center Code :'||l_cost_center, 'W');
       writelog('and Company Code :'||l_company, 'W');
       writelog ('Processing is terminated for this combination', 'W');
       l_retcode1 := 1;
     end;

  end loop;
  close c_list2;
  --
  --
      hr_utility.set_location(l_proc,50);
      /*
      ** We have populated the temp table with company cost centers for the
      ** current COA. Now check the rows in the temp table. If we don't
      ** have any tell the user.
      */
      open c_list for 'select count(*) from '||p_hr_cc_reporting_temp;
      fetch c_list into l_rowcount;
      close c_list;
      if l_rowcount = 0 then
        writelog(fnd_message.get_string('PER','HR_289178_NO_CC_PROC'),'W');
        l_retcode := 1;
    	return l_retcode;
      end if;
    else
      l_retcode := reportMissingFlex(
                        p_chart_of_accounts_id => l_coas.chart_of_accounts_id,
                        p_company_segment      => l_company_segment,
			p_cc_segment           => l_cc_segment,
			p_company_vs           => l_company_vs,
			p_cc_vs                => l_cc_vs);
    end if;


  end loop;
  hr_utility.set_location(l_proc,70);

  /*
  ** Delete records from the working table which are for companies which do
  ** not exist in the business group. Because GL CC table spans multiple
  ** business groups you need to define the companies in the appropriate BG
  ** first(a manual setup step) and then run sync orgs. This enables you to
  ** run the sync orgs process for a business group and only pull in those
  ** company cost centers which relate to this business group (i.e those
  ** which are for companies already defined in this business group.
  **
  ** A possible enhancement here - instead of inserting all the data and then
  ** deleting some, merge this into a single insert which only inserts cost
  ** centers for companies in this business group.  We probably should not
  ** implement this enhancement as it would prevent us from determining if the
  ** temporary table was empty because there are no GL cost centers to process
  ** or because the setup is incorrect and no companies have been defined in
  ** the current BG.
  */
  l_stmt := 'delete from '||p_hr_cc_reporting_temp||' rep
                   where (company,company_value_set) not in
		( select distinct cc.org_information3,
		                  cc.org_information2
                    from hr_all_organization_units units,
		         hr_all_organization_units_tl unitstl,
			 hr_organization_information class,
			 hr_organization_information cc
                   where units.organization_id = class.organization_id
		     and units.organization_id = unitstl.organization_id
		     and class.org_information_context=''CLASS''
		     and class.org_information1=''CC''
		     and class.organization_id = cc.organization_id
		     and cc.org_information_context = ''Company Cost Center''
		     and units.business_group_id = :1
		     and cc.org_information4 is null
		     and cc.org_information5 is null)';

  execute immediate l_stmt using p_bgid;
  hr_utility.set_location(l_proc,80);

  /*
  ** We have populated the temp table and deleted records from it
  ** if no company organization has been defined in the business
  ** group. Now check the rows in the temp table. If we don't
  ** have any tell the user.
  */
  open c_list for 'select count(*) from '||p_hr_cc_reporting_temp;
  fetch c_list into l_rowcount;
  close c_list;
  if l_rowcount = 0 then
    writelog(fnd_message.get_string('PER','HR_289599_NO_CC_PROC'),'W');
    l_retcode := 1;
  else

    /* Read the Org Name Format */
    l_org_name_format := fnd_profile.value('HR_GL_ORG_NAME_FORMAT');
    if (l_org_name_format IS NULL) then
      hr_utility.set_location(l_proc,90);
      hr_utility.set_message(801,'HR_289489_NO_NAME_FORMAT');
      writelog(fnd_message.get_string('PER','HR_289489_NO_NAME_FORMAT'),'E');
    end if;

    writelog('Org Format is : '||l_org_name_format,'D');

    l_stmt := 'UPDATE '||p_hr_cc_reporting_temp||' rep set (org_name) =
		(select substrb(REPLACE(
		                  REPLACE(
				     REPLACE(
				        REPLACE(:l_org_name_format,''$COC'',
					               rep.company),
                                     ''$CCC'', rep.cost_center),
                                  ''$CON'', rep.company_name),
                               ''$CCN'', rep.cost_center_name), 1,
			                                  :g_org_name_length)
	           from dual)';

    execute immediate l_stmt using l_org_name_format, g_org_name_length;
    hr_utility.set_location(l_proc,80);

    -- Now check if Org Names are duplicated for different value sets

    l_stmt := 'update '||p_hr_cc_reporting_temp||' rep
	set org_name = substrb(org_name, 1, '||
	               to_char(g_org_name_length)||'-length(''-''||
		                                    company_value_set||
	                                            ''-''||cc_value_set))
		||''-''||company_value_set ||''-''||cc_value_set
	where rep.org_name in
	(select distinct a.org_name
	from '||p_hr_cc_reporting_temp||' a, '||p_hr_cc_reporting_temp||' b
	where a.org_name = b.org_name and
	(a.cc_value_set <> b.cc_value_set
	 or a.company_value_set<>b.company_value_set))';

    execute immediate l_stmt;

  /* Bug   3208451
  ** If the start date is '01/01/1900' then update it to default
  ** date 01/01/1990
  */
    execute immediate  'UPDATE '||p_hr_cc_reporting_temp||' rep
               set (org_start_date) = to_date(''01/01/1990'',''DD/MM/RRRR'')
               Where to_char(org_start_date,''DD/MM/RRRR'') = (''01/01/1900'')';

    writelog(' Done processing. Spooling to file now.','D');
    spoolToFile(p_hr_cc_reporting_temp);
  end if;
  hr_utility.set_location('Leaving : '||l_proc,100);
 -- commit;
   if l_retcode= 0 then
     return l_retcode1;
   end if;
    return l_retcode;
end;


function createSyncTempTable(p_hr_sync_temp in varchar2,
                             p_hr_sync_ccid in varchar2,
			     p_bgid         in number,
			     p_schema       in varchar2,
                             p_coa          in number)
return NUMBER is

l_proc VARCHAR2(50) := g_package||'.createSyncTempTable';

l_chart_of_accounts_id NUMBER :=0;
l_dummy1 varchar2(2000);
l_dummy2 varchar2(2000);
l_schema varchar2(400);
l_stmt VARCHAR2(3000);

l_company 	varchar2(240);    /* The column name of the segment holding the
                                     company value */
l_cost_center 	varchar2(240);    /* The column name of the segment  holding the
                                     cost center value */
l_company_vs	number(15) := -1; /* The ID of the company valueset. */
l_cc_vs		number(15) := -1; /* The ID of the cost center valueset. */

errbuf		varchar2(240);
l_retcode       varchar2(10);

l_temp_table	varchar2(30) := null;

cursor c_coas is
   select distinct chart_of_accounts_id
       from gl_sets_of_books               --Bug 3264485
       where chart_of_accounts_id = p_coa
             or p_coa is null ; -- Fix for Bug 2875915
--

type curType is ref cursor;
c_list curType;
l_rowcount number;

BEGIN
  hr_utility.set_location('Entering : '||l_proc,10);

  droptable(p_hr_sync_temp, TRUE );
  droptable(p_hr_sync_ccid, TRUE );

  /*
  ** This table is used to hold information about the company and cost center
  ** from gl_code_combinations table for all chart of accounts which do not
  ** have a value for company_cost_center_org_id.
  */
  execute immediate  'create table '||p_hr_sync_temp ||' (
		ccid number(15),
		chart_of_accounts_id number(15),
		company varchar2(240),
		company_vs number(15),
		cc_vs number(15),
		cost_center varchar2(240),
		org_id NUMBER(15),
		business_group_id NUMBER(15))';

  execute immediate 'create unique index '||p_hr_sync_temp||'_u1 on '||
		p_hr_sync_temp||'(ccid)';

  execute immediate 'create index '||p_hr_sync_temp||'_n1 on '||
		p_hr_sync_temp||' (chart_of_accounts_id)';

  hr_utility.set_location(l_proc,20);

  for l_coas in c_coas
  loop
    hr_utility.set_location(l_proc,30);
    l_retcode := getSegmentForQualifier(l_coas.chart_of_accounts_id,
                                        'GL_BALANCING',
					l_company);
    l_retcode := getSegmentForQualifier(l_coas.chart_of_accounts_id,
                                            'FA_COST_CTR',
					    l_cost_center);
    l_retcode := getValueSetForSegment(l_coas.chart_of_accounts_id,
                                          l_company,
					  l_company_vs);
    l_retcode := getValueSetForSegment(l_coas.chart_of_accounts_id,
                                     l_cost_center,
				     l_cc_vs);

    if (l_company     is NULL OR
        l_cost_center is null OR
        l_company_vs  = -1  OR
	l_cc_vs       = -1) then
      l_retcode := reportMissingFlex(
                        p_chart_of_accounts_id => l_coas.chart_of_accounts_id,
                        p_company_segment      => l_company,
			p_cc_segment           => l_cost_center,
			p_company_vs           => l_company_vs,
			p_cc_vs                => l_cc_vs);
    else
      hr_utility.set_location(l_proc,50);
      /*
      ** In the following SQL - l_company and l_cost_center hold the
      ** name of the segment column holding the company and cost center info
      ** cause the data from the corresponding column in the code comb table
      ** to be inserted into the temp table. i.e. if l_company holds the string
      ** 'SEGMENT1' then the value from GL_CODE_COMBINATIONS.SEGMENT1 is
      ** inserted into the tmp table.
      */
      execute immediate 'insert into '||p_hr_sync_temp ||'
	                      (ccid,
		               chart_of_accounts_id,
		               company,
		               company_vs,
		               cost_center,
		               cc_vs)
	                 select code_combination_id,
			        chart_of_accounts_id,'||
				l_company ||', '||l_company_vs||', '||
				l_cost_center||', '||l_cc_vs||'
			   from gl_code_combinations
			  where company_cost_center_org_id is null
			    and summary_flag = ''N''
			    and chart_of_accounts_id = :1'
	          using l_coas.chart_of_accounts_id;

      writelog('Inserted '||sql%rowcount||'  records for COA = '||
                l_coas.chart_of_accounts_id,'D');
      if sql%rowcount = 0 then
        writelog(fnd_message.get_string('PER','HR_289178_NO_CC_PROC'),'W');
        /*
        ** We've got no rows in the temp table so bail out of the processing
        ** now as doing any further work is just inefficient.
        */
        raise g_no_cc_proc_exc;
      end if;

    end if;

  end loop;
  hr_utility.set_location(l_proc,60);
--  commit;

  /*
  ** Remove those records for which no company organization can be found.
  */
  l_stmt := 'delete from '||p_hr_sync_temp||' rep
                   where (company,company_vs) not in
		( select distinct cc.org_information3,
		                  cc.org_information2
                    from hr_all_organization_units units,
		         hr_all_organization_units_tl unitstl,
			 hr_organization_information class,
			 hr_organization_information cc
                   where units.organization_id = class.organization_id
		     and units.organization_id = unitstl.organization_id
		     and class.org_information_context=''CLASS''
		     and class.org_information1=''CC''
		     and class.organization_id = cc.organization_id
		     and cc.org_information_context = ''Company Cost Center''
		     and units.business_group_id = :1
		     and cc.org_information4 is null
		     and cc.org_information5 is null)';
  execute immediate l_stmt using p_bgid;
  hr_utility.set_location(l_proc,62);

  /*
  ** We have populated the temp table and excluded records from it
  ** if no company organization has been defined in the business
  ** group. Now check the rows in the temp table. If we don't
  ** have any tell the user.
  */
  open c_list for 'select count(*) from '||p_hr_sync_temp;
  fetch c_list into l_rowcount;
  close c_list;
  if l_rowcount = 0 then
    hr_utility.set_location(l_proc,64);
    writelog(fnd_message.get_string('PER','HR_289599_NO_CC_PROC'),'W');
    /*
    ** We've got no rows in the temp table so bail out of the processing
    ** now as doing any further work is just inefficient.
    */
    raise g_no_cc_proc_exc;
  else
    /*
    ** This temp table cross-references CCID and org ID for each record in
    ** gl_code_combinations table for which an organization with matching
    ** company and cost center is already defined. i.e. regardless of org name
    ** if we find an organization which already has the Company Cost Center
    ** classification and the org information matches on company, cost center
    ** and valueset details then link the org to the GL code combinations
    ** record.
    **
    ** This SQL needs rewriting to use org_information1 in the search and not
    ** the individual segments.
    */
    hr_utility.set_location(l_proc,66);

    l_stmt := 'create table '||p_hr_sync_ccid||'(ccid, org_id) as
	            (select sync.ccid,
		            units.organization_id
	               from '||p_hr_sync_temp ||' sync ,
	                    hr_all_organization_units units,
	                    hr_organization_information class,
	                    hr_organization_information cc
	              where units.organization_id = class.organization_id
	                and units.business_group_id = '||p_bgid||'
	                and class.org_information_context=''CLASS''
	                and class.org_information1=''CC''
	                and class.organization_id = cc.organization_id
	                and cc.org_information_context = ''Company Cost Center''
	                and cc.org_information2 = to_char(sync.company_vs)
	                and cc.org_information3 = sync.company
	                and cc.org_information4 = to_char(sync.cc_vs)
	                and cc.org_information5 = sync.cost_center)';

    execute immediate l_stmt;
    hr_utility.set_location(l_proc,70);

    begin
      execute immediate 'create unique index '||p_hr_sync_ccid||'_u1 on '||
                                              p_hr_sync_ccid||'(ccid)';
    exception
      when others then
        if sqlcode = -1452 then
          /*  cannot CREATE UNIQUE INDEX; duplicate keys found */
          writelog(fnd_message.get_string('PER','HR_289492_DUP_CCIDS'),'E');
        end if;

    end;
    hr_utility.set_location(l_proc,80);
--    commit;

    -- Now analyze table for avoiding view sort

    l_temp_table := substr(p_hr_sync_temp, instr(p_hr_sync_temp, '.') + 1,
			  length(p_hr_sync_temp)) ;

    fnd_stats.gather_table_stats (errbuf,l_retcode, p_schema, l_temp_table, 10, 1);
    hr_utility.set_location(l_proc,90);

    l_temp_table := substr(p_hr_sync_ccid, instr(p_hr_sync_ccid, '.') + 1,
	  		   length(p_hr_sync_ccid)) ;
    fnd_stats.gather_table_stats (errbuf,l_retcode, p_schema, l_temp_table,10, 1);
  end if;

  hr_utility.set_location('Leaving : '||l_proc,100);

  return l_retcode;
end;


/*---------------------------------------------------------------------

This operates only on org_ids that are null in the gl_code_combinations table
For those that are null, first check if there is an Org with Company Cost Center
classification with the same company and cost center attributes.
If so, do nothing.
If this org does not exist then check for an organization with the same name
derived using the name format and the current values.  If it exists and it is
not already classified with the Company Cost Center classification then add
the classification with the current information.  If the classification does
exist then report this to the log file. (it is unlikely that we will find an
org which matches using the derived org name but which has been linked to a
different company cost center via the org info.
If we have no match on classification information or org name then create an
Org, add the HR and CC classifications.
For the last two cases update the GCC table with this org_id.

---------------------------------------------------------------------*/

function synchronizeMode(p_mode         in varchar2,
                         p_hr_sync_temp in varchar2,
                         p_hr_sync_ccid in varchar2,
			 p_start_date   in date,
			 p_bgid         in number,
			 p_schema       in varchar2,
                         p_coa          in number)
return NUMBER is

l_proc VARCHAR2(50) := g_package||'.synchronizeMode';

type curType is ref cursor;
c_list 		curType;
c_temp		curType;

l_schema 	varchar2(30) := null;

l_chart_of_accounts_id NUMBER(15) := 0;
l_company 	varchar2(240);
l_cost_center 	varchar2(240);
l_company_vs	number(15) := -1;
l_cc_vs		number(15) := -1;

l_bg_id		NUMBER(15) := 0;
l_org_id	NUMBER(15) := 0;
l_ver		NUMBER(15) := 0;
l_org_inf_id	NUMBER(15) := 0;
l_stmt 		VARCHAR2(3000) := null;

l_temp_comp	varchar2(240) := null;
l_temp_cc	varchar2(240) := null;
l_temp_compvs	NUMBER(15) := 0;
l_temp_ccvs	NUMBER(15) := 0;

l_org_profile  VARCHAR2(10) := null;
l_retcode      number := 0;
l_rowcount     number;

l_last_update_login number := 0;
l_message varchar2(1000);

BEGIN
  hr_utility.set_location('Entering : '||l_proc,10);
  /*
  ** Create and populate temporary tables which
  ** contain the company cost centers to be processed and the GL CCID's
  ** which already have a matching org(classified as company cost center with
  ** the company and cost center data) already defined.
  */
  l_retcode := createSyncTempTable(
                      p_hr_sync_temp => p_hr_sync_temp,
		      p_hr_sync_ccid => p_hr_sync_ccid,
		      p_bgid         => p_bgid,
		      p_schema       => p_schema,
                      p_coa          => p_coa); -- fix for bug 2875915

  dumpccidtable(p_hr_sync_ccid);
  dumptemptable(p_hr_sync_temp);
  writelog('Created '||p_hr_sync_temp||' table ','D');
  writelog('Created '||p_hr_sync_ccid||' table ','D');

  /*
  ** Update the GL code combinations table and set the org ID FK
  ** to the corresponding company cost center org.
  */
  l_stmt := 'update /*+ORDERED USE_NL(gcc)*/ gl_code_combinations gcc
                set (company_cost_center_org_id,
		     last_update_date,
		     last_updated_by ) =
	             (select sync.org_id,
		             sysdate, '||
			     l_last_update_login||
                     '  from '||p_hr_sync_ccid ||' sync
	               where gcc.code_combination_id = sync.ccid)
              where gcc.company_cost_center_org_id is null
                and gcc.code_combination_id in
                         (select ccid from '||p_hr_sync_ccid ||')';

  execute immediate l_stmt;

  writelog('Updated '||sql%rowcount||' rows in GL_CODE_COMBINATIONS','D');
  hr_utility.set_message(800,'HR_289179_COMB_ORG_ALRDY');
  fnd_message.set_token('ROWCOUNT',sql%rowcount);
  l_message := fnd_message.get();
  /*
  ** ...now pass the string to writelog.
  */
  writelog(l_message,'I');

  /*
  ** This marks the end of part 1 of the sync process.  We have found all the
  ** GL code comb records which map to existing organizations based on
  ** cost center org information.  We now start part 2 of the process which
  ** will deal with those code combinations which do not map to any existing
  ** organization.
  */

  /*
  ** Work out if we are just syncing with existing orgs based on current
  ** classifications.
  */
  l_org_profile := fnd_profile.value('HR_GENERATE_GL_OPTIONS');
  hr_utility.set_location('generate GL options '||l_org_profile,20);
  if (l_org_profile = 'S') then
    hr_utility.set_location(l_proc,25);
    writelog(fnd_message.get_string('PER','HR_289509_NOT_GEN_GL_ORGS'),'W');
    return 1;
  end if;

  /*
  ** Since we have just set the org ID on GL_CODE_COMBINATIONS for those
  ** records which have a matching cost center Org already defined
  ** we can remove the records from our other temp table for CCID's which
  ** now have a value for the org ID.
  */
  hr_utility.set_location(l_proc,30);
  execute immediate 'delete from '||p_hr_sync_temp ||'
                           where ccid in
			        (select code_combination_id
		                   from gl_code_combinations
		                  where company_cost_center_org_id is not null
		                    and last_update_date >= :1)'
          using p_start_date;

  writelog('deleted '||sql%rowcount||' rows from '||p_hr_sync_temp||
           ' where org_id is not null','D');
  dumpccidtable(p_hr_sync_ccid);
  dumptemptable(p_hr_sync_temp);

  open c_list for 'select count(*) from '||p_hr_sync_temp;
  fetch c_list into l_rowcount;
  close c_list;
  if l_rowcount > 0 then
--    hr_utility.set_message(800,'HR_289180_COMB_TO_SYNC');
--    fnd_message.set_token('ROWCOUNT',l_rowcount);
--    l_message := fnd_message.get();
    /*
    ** ...now pass the string to writelog.
    */
--    writelog(l_message,'I');

    /*
    ** For the remaining records in the temp table create new Orgs, add the
    ** cost center classification and if required an HR Org classification.
    */
    open c_list for 'select distinct company,
                                   cost_center,
				   company_vs,
				   cc_vs
                     from '||p_hr_sync_temp;
    loop
      fetch c_list into l_company,
                        l_cost_center,
	  	        l_temp_compvs,
		        l_temp_ccvs;
      exit when c_list%NOTFOUND;


      l_retcode := create_org_and_classification(p_mode,
                                                 p_bgid,
                                                 l_company,
		   			         l_cost_center,
					         l_temp_compvs,
					         l_temp_ccvs,
					         null,
					         l_org_id);

      if (l_retcode = -1) then
        l_retcode := 1;
        writelog('Problems with Create Org and Classification.','D');
      else

        /*
        ** Save this new Org ID in the temp table for later.
        */
        execute immediate 'update '||p_hr_sync_temp ||'
	  		      set (org_id) = :1
			    where company =:2 and cost_center=:3
			      and company_vs = :4 and cc_vs = :5'
                    using l_org_id, l_company, l_cost_center,
		          l_temp_compvs, l_temp_ccvs;


      end if;
    end loop;

    /*
    ** now update GL_CODE_COMBINATIONS and set the org ID FK.
    */
    l_stmt :=  'update gl_code_combinations gcc
		   set (company_cost_center_org_id,
		        last_update_date,
		        last_updated_by) =
		       (select org_id,
		               sysdate, '||
			       fnd_global.user_id||
                        ' from '||p_hr_sync_temp||' sync
		         where sync.ccid = gcc.code_combination_id
		           and sync.org_id <> -1
			   and sync.org_id is not null)
                 where gcc.code_combination_id in
		            (select ccid
		               from '||p_hr_sync_temp||'
		              where org_id is not null
		                and org_id <> -1)';

    execute immediate l_stmt;
    writelog('Updated '||sql%rowcount||
             ' rows in GL Code combinations with newly created Org ids','D');
    if sql%rowcount = 0 then
      writelog(fnd_message.get_String('PER','HR_289180_SYNC_SUMMARY_ZERO'),'I');
    else
      hr_utility.set_message(800,'HR_289184_SYNC_SUMMARY');
      fnd_message.set_token('ROWCOUNT',sql%rowcount);
      l_message := fnd_message.get();
      writelog(l_message,'I');
    end if;
  end if;

  return l_retcode;
exception
  when g_no_cc_proc_exc then
    /* There are no rows in the temp table so catch the exception and return
    ** a warning status.
    */
    return 1;
  when others then
    raise;
end;


/* Called by the Incremental GL API */

Procedure create_org(p_ccid in NUMBER) IS

l_proc VARCHAR2(50) := g_package ||'.create_org';

l_request_id number := -1;
l_application_short_name VARCHAR2(3) := 'PER';
l_incremental_enabled VARCHAR2(10) := 'N';
l_autoorgs_enabled varchar2(10) := 'N';

BEGIN
  hr_utility.set_location('Entering : '||l_proc,10);
--
-- >>> Code Change Start >>> (See change history for ver 115.46)
--
----------------------------------------------------------------------
--  This procedure is invoked as a code hook from GL when a new code
--  combination is created.
--
--  Amended procedure to be a wrapper which invokes the new sync orgs
--  code as follows -
--  Package   - HR_GL_SYNC_ORGS
--  Procedure - SYNC_SINGLE_ORG()
--  Source    - hrglsync.pk[hb]
--
--  NOTE that this introduces a dependency on package HR_GL_SYNC_ORGS
--  and hence files hrglsync.pkh and hrglsync.pkb
----------------------------------------------------------------------
--
--  l_incremental_enabled := fnd_profile.value('HR_SYNC_SINGLE_GL_ORG');
--  l_autoorgs_enabled := fnd_profile.value('HR_GENERATE_GL_OPTIONS');
--
--  IF (l_autoorgs_enabled = 'S' or
--     (l_autoorgs_enabled <> 'S' and
--     l_incremental_enabled = 'N')) THEN
--                return;
--  END IF;
--
--  hr_utility.set_location(l_proc,20);
--
--  l_request_id := fnd_request.submit_request(
--                l_application_short_name,
--		'HR_CCID_GL_COST_CENTERS',
--                null,
--                null,
--                false,
--                'GL',
--		-1,
--		p_ccid,
--                chr(0), NULL, NULL, NULL, NULL, NULL, NULL,
--                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL ,
--                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL ,
--                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL ,
--                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL ,
--                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL ,
--                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL ,
--                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL ,
--                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL ,
--                NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
--
   -- Invoke new sync orgs in single org mode.
   hr_gl_sync_orgs.sync_single_org(p_ccid);
--
-- <<< Code Change End <<<
--
  hr_utility.set_location('Leaving : '||l_proc,10);
end;

function incrementalOrgs(p_mode in varchar2,
                         p_ccid in NUMBER)
return NUMBER is

l_proc varchar2(50) := g_package||'.incrementalOrgs';

l_chart_of_accounts_id 	NUMBER(15) := 0;
l_company_segment 	VARCHAR2(30);
l_cc_segment 		VARCHAR2(30);
l_company 		VARCHAR2(240);
l_cost_center 		VARCHAR2(240);
l_company_vs 		NUMBER := -1;
l_cc_vs			NUMBER := -1;
l_retcode               NUMBER := 0;

type curType 		is ref cursor;
c_list 			curType;

l_org_id 		NUMBER := -1;
l_bg_id 		NUMBER := -1;

BEGIN
  hr_utility.set_location('Entering : '||l_proc,10);
  writelog('Inside incrementalOrgs for p_ccid = '||p_ccid,'D');

  select chart_of_accounts_id
    into l_chart_of_accounts_id
    from gl_code_combinations
   where code_combination_id = p_ccid;

  l_retcode := getSegmentForQualifier(l_chart_of_accounts_id,
                                              'GL_BALANCING',
					      l_company_segment);
  l_retcode := getSegmentForQualifier(l_chart_of_accounts_id,
                                         'FA_COST_CTR',
					 l_cc_segment);
  l_retcode := getValueSetForSegment(l_chart_of_accounts_id,
                                        l_company_segment,
					l_company_vs);
  l_retcode := getValueSetForSegment(l_chart_of_accounts_id,
                                   l_cc_segment,
				   l_cc_vs);

  if (l_cc_vs = -1 OR
      l_company_vs = -1 OR
      l_cc_segment is NULL OR
      l_company_segment is NULL) then
    l_retcode := reportMissingFlex(
                        p_chart_of_accounts_id => l_chart_of_accounts_id,
                        p_company_segment      => l_company_segment,
			p_cc_segment           => l_cc_segment,
			p_company_vs           => l_company_vs,
			p_cc_vs                => l_cc_vs);

    l_retcode := 2;
    return l_retcode;
  end if;
  /*
  ** Get the actual company and cost center segment values.
  */
  open c_list for 'select '||l_company_segment||', '||
                             l_cc_segment ||'
                     from gl_code_combinations
		    where code_combination_id =:1'
	      using  p_ccid;
  fetch c_list into l_company, l_cost_center ;
  close c_list;
  hr_utility.set_location(l_proc,30);

  -- Now Check if an Org already exists with a Cost Center Classification
  -- for this Company/Cost Center

  writelog('Checking to see if an Org already exists for the combination' ,'D');

  --
  -- This SQL needs to be tuned to use org_information1 rather than the
  -- individual segment values.
  --
  open c_list for 'select units.organization_id
	             from hr_all_organization_units  units,
		          hr_organization_information class,
			  hr_organization_information cc
                    where units.organization_id = class.organization_id
                      and class.org_information_context=''CLASS''
		      and class.org_information1=''CC''
                      and class.organization_id = cc.organization_id
                      and cc.org_information_context = ''Company Cost Center''
                      and cc.org_information2 = :1
		      and cc.org_information4 = :2
                      and cc.org_information3 = :2
		      and cc.org_information5 = :4 '
              using to_char(l_company_vs), to_char(l_cc_vs),
	            l_company, l_cost_center;
  hr_utility.set_location(l_proc,31);
  fetch c_list into l_org_id;
  hr_utility.set_location(l_proc,32);
  close c_list;
  hr_utility.set_location(l_proc,35);
  if (l_org_id = -1) then -- create new org
    hr_utility.set_location(l_proc,40);
    writelog('Org ID does not already exist ','D');

    l_bg_id := getBGID(l_company, l_company_vs);

    if (l_bg_id <> -1) then
      l_retcode := create_org_and_classification(p_mode,
                                                l_bg_id,
                                                l_company,
						l_cost_center,
						l_company_vs,
						l_cc_vs,
						p_ccid,
						l_org_id);
    else
      /*
      ** This error condition is identical to one inside getBGID
      ** which results in 289601 message being raised.  289493 message
      ** has beenremovd from seed115 but leaving this code in place
      ** just in case the 289601 error is not detected and we exit
      ** getBGID with l_bg_id = -1.
      */
      hr_utility.set_message(801,'HR_289493_NO_COMPANY_ORG');
      hr_utility.raise_error;
    end if;
  end if;

  if l_org_id <> -1 then
    hr_utility.set_location(l_proc,50);
    execute immediate 'update gl_code_combinations
                          set company_cost_center_org_id=:1,
			      last_update_date = sysdate,
			      last_updated_by = :2
		        where code_combination_id =:3'
            using l_org_id, fnd_global.user_id, p_ccid;

    writelog('Updated GL_CODE_COMBINATIONS. Set Company_cost_center_org_id = '||
			l_org_id ||' where code_Combination_id = '||p_ccid,'D');
  end if;

  hr_utility.set_location('Leaving : '||l_proc,60);
  return l_retcode;
end;

Procedure synch_orgs(errbuf              in out nocopy VARCHAR2
                    ,retcode             in out nocopy NUMBER
		    ,p_mode              in     VARCHAR2
		    ,p_business_group_id in     NUMBER default null
		    ,p_ccid              in     NUMBER default null
                    ,p_coa               in     NUMBER default null) is

l_dummy                number;
l_proc                 VARCHAR2(50)  := 'synch_orgs';
l_column_name	       VARCHAR2(40)  := null;
l_dir                  VARCHAR2(300) := null;
l_schema               VARCHAR2(10)  := null;
l_hr_cc_reporting_temp VARCHAR2(50)  := 'hr_cc_reporting_temp';
l_hr_cc_reporting_comp VARCHAR2(50)  := 'hr_cc_reporting_comp';
l_hr_sync_temp         VARCHAR2(50)  := 'hr_cc_temp';
l_hr_sync_ccid         VARCHAR2(50)  := 'hr_sync_gl_ccid';
l_retcode              NUMBER        := 0;
l_application_short_name VARCHAR2(50);
l_start_date             DATE;

cursor c_derive_name_length is
  select 1
    from user_triggers
   where trigger_name='HR_ALL_ORGANIZATION_UNITS_UTF8';

BEGIN
  hr_utility.set_location('Entering : '||l_proc,10);
  /*
  ** Set the Global holding the max length of an org name based
  ** on the existence of the UTF8 trigger. If it's there make the
  ** length 60, if it's not make it 240.
  */
  open c_derive_name_length;
  fetch c_derive_name_length into l_dummy;
  if c_derive_name_length%FOUND then
    hr_utility.set_location(l_proc,14);
    g_org_name_length := 60;
  else
    hr_utility.set_location(l_proc,18);
    g_org_name_length := 240;
  end if;
  close c_derive_name_length;

  l_start_date := sysdate;
  l_application_short_name := 'PER';
  l_schema 		 := getProductSchema(l_application_short_name);
  l_hr_cc_reporting_temp := l_schema||'.'|| l_hr_cc_reporting_temp;
  l_hr_cc_reporting_comp := l_schema||'.'||l_hr_cc_reporting_comp;
  l_hr_sync_temp	 := l_schema||'.'|| l_hr_sync_temp;
  l_hr_sync_ccid	 := l_schema||'.'|| l_hr_sync_ccid;

  if (p_mode = 'GL') then
    hr_utility.set_location(l_proc,20);
    if (p_ccid is null) then
      hr_utility.set_message(801,'HR_289494_NO_CCID');
      hr_utility.raise_error;
      retcode := 2;
      return;
    end if;
    fnd_file.put_names(p_mode||p_ccid||'.log'
                      ,p_mode||p_ccid||'.out'
		      ,l_dir);
    hr_utility.set_location(l_proc,30);
  else
    hr_utility.set_location(l_proc,40);
    if (p_business_group_id IS NULL) then
      writelog(fnd_message.get_string('PER','HR_289495_NO_BG'),'E');
    end if;

    fnd_file.put_names(p_mode||p_business_group_id||'.log'
                      ,p_mode||p_business_group_id||'.out'
                      ,l_dir);
    hr_utility.set_location(l_proc,50);

    l_hr_cc_reporting_temp := l_hr_cc_reporting_temp||'_'||p_business_group_id;
    l_hr_cc_reporting_comp := l_hr_cc_reporting_comp||'_'||p_business_group_id;
    l_hr_sync_temp         := l_hr_sync_temp||'_'||p_business_group_id;
    l_hr_sync_ccid         := l_hr_sync_ccid||'_'||p_business_group_id;
  end if;

  writelog('Beginning of Synchronize GL Cost Center program in '||p_mode ||' mode.','D');
  writelog('Start time is : '|| to_char(sysdate, 'dd-mm-yy hh24:mi:ss'),'D');
  writelog('p_mode is : '||p_mode,'D');
  writelog('Business Group Id is : '||p_business_group_id,'D');
  writelog('CCID is : '|| p_ccid,'D');

  begin
    if (p_mode = 'REPORT') then
      hr_utility.set_location(l_proc,60);
      l_retcode := reportingMode(
                     p_application_short_name => l_application_short_name,
		     p_hr_cc_reporting_temp   => l_hr_cc_reporting_temp,
		     p_bgid                   => p_business_group_id,
                     p_coa                    => p_coa);

      /* Drop tables. FALSE means only drop them if not in DEBUG mode.
      */
      droptable(l_hr_cc_reporting_temp, FALSE);
    elsif (p_mode = 'SYNCHRONIZE') then
      hr_utility.set_location(l_proc,70);
      l_retcode := synchronizeMode(
                     p_mode         => p_mode,
		     p_hr_sync_temp => l_hr_sync_temp,
		     p_hr_sync_ccid => l_hr_sync_ccid,
		     p_start_date   => l_start_date,
		     p_bgid         => p_business_group_id,
		     p_schema       => l_schema,
                     p_coa          => p_coa);
      hr_utility.set_location(l_proc, 72);
      /* Drop tables. FALSE means only drop them if not in DEBUG mode.
      */
      droptable(l_hr_sync_temp, FALSE);
      droptable(l_hr_sync_ccid, FALSE);
      hr_utility.set_location(l_proc, 78);
    else
      hr_utility.set_location(l_proc,80);
      l_retcode := incrementalOrgs(p_mode,
                                   p_ccid);
    end if;
  exception
    when others then
       /*
       ** I've hit an error and raised an exception so set retcode to
       ** indicate a failure and then continue to the exit code.
       */
       hr_utility.set_location(l_proc, 85);
       hr_utility.set_location(SQLERRM,86);
       l_retcode := 2;
  end;

  retcode := l_retcode;
  hr_utility.set_location(l_proc||' retcode '||to_char(retcode),90);
  if (retcode = 0) then
    writelog('Completed all operations for '||p_mode||' mode.','D');
  elsif retcode =1 then
    writelog('Completed with warnings.','D');
  elsif retcode = 2 then
    writelog('Program terminated with errors.','D');
  else
    writelog('Terminating with unknown code '||to_char(retcode),'D');
  end if;

  writelog('End time is : '||to_char(sysdate, 'dd-mm-yy hh24:mi:ss'),'D');

Exception
  when others then
    raise;

end;

END hr_gl_cost_centers;

/
