--------------------------------------------------------
--  DDL for Package Body PER_RI_CONFIG_TECH_SUMMARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RI_CONFIG_TECH_SUMMARY" AS
/* $Header: perricts.pkb 120.14 2007/12/06 08:37:03 vdabgar noship $*/

  g_config_effective_date     date          := TRUNC(TO_DATE('1951/01/01', 'YYYY/MM/DD'));
  g_config_effective_end_date date          := TRUNC(TO_DATE('4712/12/31', 'YYYY/MM/DD'));
  g_package                   varchar2(30)  := 'per_ri_config_tech_summary.';


FUNCTION get_clob_locator(p_table_name in varchar2)
                            return clob IS

  l_clob_rec    per_ri_config_tech_summary.l_clob_rec_type;
  l_xmldoc_loc  clob;
  l_proc        varchar2(73) := g_package || 'get_clob_locator';

  BEGIN

    hr_utility.set_location('Entering: '|| l_proc, 10);

    l_clob_rec.table_name  := p_table_name;
    l_clob_rec.xmldoc      := null;
    l_xmldoc_loc           := l_clob_rec.xmldoc;

    hr_utility.set_location('Leaving: '|| l_proc, 20);

    return l_xmldoc_loc;
  EXCEPTION
    when no_data_found then
      null;
    when others then
      null;
END get_clob_locator;

FUNCTION get_business_grp_sql (p_business_grp_tab in out nocopy per_ri_config_tech_summary.bg_tab)
                            return clob IS

  l_bg_clob 		clob;
  l_ret_bg_clob 	clob;
  l_temp_sql 		varchar2(2000);
  queryCtx 		number;
  l_proc 		varchar2(200) 	:= 'get_business_grp_sql';
  l_style 		varchar2(10);
  i 			number(8) 	:= 0;
  l_bg_prejoin_sql 	varchar2(2000);
  l_bg_postjoin_sql 	varchar2(2000);


BEGIN

      hr_utility.set_location('Entering ' ||l_proc ,10);

      l_bg_clob := get_clob_locator('BUSINESS_GROUPS');
      dbms_lob.createtemporary(l_bg_clob,TRUE);

      -- dbms_lob.writeappend(l_bg_clob,length('<BusinessGroups>'),'<BusinessGroups>');
      l_bg_prejoin_sql := ' select Effective_Date,terr.TERRITORY_SHORT_NAME CountryName,Short_Name, '
			  ||' 	lookup1.meaning app_gen_method_val, '
			  ||' lookup2.meaning emp_gen_method_val,lookup3.meaning cwk_gen_method_val, '
			  ||' curr.name CurrencyName , grade_flex_stru_code,group_flex_stru_code,'
			  ||' job_flex_stru_code,cost_flex_stru_code, '
			  ||' position_flex_stru_code,competence_flex_stru_code from (';

      dbms_lob.writeappend(l_bg_clob,length(l_bg_prejoin_sql),l_bg_prejoin_sql);

      hr_utility.set_location('Entering BG Loop'||l_proc,15);

      IF p_business_grp_tab.count > 0 THEN
	   for i in p_business_grp_tab.first ..
		    p_business_grp_tab.last loop

		    l_temp_sql:= ' SELECT  '||
				  '''' || p_business_grp_tab(i).effective_date		||''''||' effective_date ,'||
				  '''' || p_business_grp_tab(i).language_code		||''''||' language_code ,'||
				  '''' || p_business_grp_tab(i).date_from		||''''||' date_from ,'||
				  '''' || REPLACE(p_business_grp_tab(i).name, '''', '''''') ||''''||' name ,'||
				  '''' || p_business_grp_tab(i).type			||''''||' type ,'||
				  '''' || p_business_grp_tab(i).internal_external_flag	||''''||' internal_external_flag ,'||
				  '''' || REPLACE(p_business_grp_tab(i).short_name, '''', '''''') ||''''||' short_name ,'||
				  '''' || p_business_grp_tab(i).emp_gen_method		||''''||' emp_gen_method ,'||
				  '''' || p_business_grp_tab(i).app_gen_method		||''''||' app_gen_method ,'||
				  '''' || p_business_grp_tab(i).cwk_gen_method		||''''||' cwk_gen_method ,'||
				  '''' || p_business_grp_tab(i).legislation_code	||''''||' legislation_code ,'||
				  '''' || p_business_grp_tab(i).currency_code		||''''||' currency_code ,'||
				  '''' || p_business_grp_tab(i).fiscal_year_start	||''''||' fiscal_year_start ,'||
				  '''' || p_business_grp_tab(i).min_work_age		||''''||' min_work_age ,'||
				  '''' || p_business_grp_tab(i).max_work_age		||''''||' max_work_age ,'||
				  '''' || p_business_grp_tab(i).location_code		||''''||' location_code ,'||
				  '''' || p_business_grp_tab(i).grade_flex_stru_code	||''''||' grade_flex_stru_code ,'||
				  '''' || p_business_grp_tab(i).group_flex_stru_code	||''''||' group_flex_stru_code ,'||
				  '''' || p_business_grp_tab(i).job_flex_stru_code	||''''||' job_flex_stru_code ,'||
				  '''' || p_business_grp_tab(i).cost_flex_stru_code	||''''||' cost_flex_stru_code ,'||
				  '''' || p_business_grp_tab(i).position_flex_stru_code	||''''||' position_flex_stru_code ,'||
				  '''' || p_business_grp_tab(i).security_group_name	||''''||' security_group_name ,'||
				  '''' || p_business_grp_tab(i).competence_flex_stru_code||''''||' competence_flex_stru_code '||
				  ' FROM DUAL UNION';

		    dbms_lob.writeappend(l_bg_clob,length(l_temp_sql),l_temp_sql);
		    end loop;
	end if;
	hr_utility.set_location('Leaving BG Loop',20);
	dbms_lob.trim(l_bg_clob,length(l_bg_clob)-5);

	l_bg_postjoin_sql := ' ) X ,FND_TERRITORIES_VL  terr ,fnd_lookup_values lookup1,  '
			     ||' 	fnd_lookup_values lookup2,fnd_lookup_values lookup3 , '
			     ||' fnd_currencies_vl curr '
			     ||' where  terr.TERRITORY_CODE  = X.Legislation_code  '
			     ||' and lookup1.lookup_code= app_gen_method  '
			     ||' and lookup2.lookup_code = emp_gen_method  '
			     ||' and lookup3.lookup_code= cwk_gen_method  '
			     ||' and lookup1.lookup_type = ''APL_NUM_GEN_METHOD''  '
			     ||' and lookup2.lookup_type = ''EMP_NUM_GEN_METHOD'' '
			     ||' and lookup3.lookup_type = ''CWK_NUM_GEN_METHOD'' '
			     ||' and curr.currency_code = X.Currency_code    '
			     ||' and lookup1.language = userenv(''LANG'')'
			     ||' and lookup2.language = userenv(''LANG'')'
			     ||' and lookup3.language = userenv(''LANG'')'
			     ||' order by  CountryName desc' ;

	dbms_lob.writeappend(l_bg_clob,length(l_bg_postjoin_sql),l_bg_postjoin_sql);

	l_ret_bg_clob := fetch_clob(l_bg_clob,'BusinessGroup','BusinessGroups');

	hr_utility.set_location('Leaving ' ||l_proc ,30);

	return l_ret_bg_clob;
 END get_business_grp_sql;


FUNCTION get_org_sql ( p_org_ent_tab 	in out nocopy per_ri_config_tech_summary.org_ent_tab
		      ,p_org_oc_tab 	in out nocopy per_ri_config_tech_summary.org_oc_tab
		      ,p_org_le_tab 	in out nocopy per_ri_config_tech_summary.org_le_tab)
                   return clob IS

  l_org_clob 		clob;
  l_ret_org_clob 	clob;
  l_temp_sql 		varchar2(2000);
  queryCtx 		number;
  l_proc 		varchar2(200) 	:= 'get_org_ent_sql';
  l_style 		varchar2(10);
  i 			number(8) 	:= 0;
  l_orderby		varchar2(200);

 begin

      hr_utility.set_location('Entering ' || l_proc ,10);

      l_org_clob := get_clob_locator('ORGANIZATIONS');
      dbms_lob.createtemporary(l_org_clob,TRUE);
      l_orderby := ' order by business_grp_name desc, name desc ';

      hr_utility.set_location('Before Org Enterprise Loop ' || l_proc ,10);

      IF p_org_ent_tab.count > 0 THEN
		   for i in p_org_ent_tab.first ..
			    p_org_ent_tab.last loop

		    l_temp_sql:= ' SELECT  '||
				  '''' || p_org_ent_tab(i).effective_date            ||''''||' effective_date ,'||
				  '''' || p_org_ent_tab(i).date_from                 ||''''||' date_from ,'||
				  '''' || REPLACE( p_org_ent_tab(i).business_grp_name, '''', '''''') ||''''||' business_grp_name ,'||
				  '''' || REPLACE( p_org_ent_tab(i).name	, '''', '''''') ||''''||' name ,'||
				  '''' || p_org_ent_tab(i).location_code             ||''''||' location_code ,'||
				  '''' || p_org_ent_tab(i).internal_external_flag    ||''''||' internal_external_flag '||
				  ' FROM DUAL UNION';

		    dbms_lob.writeappend(l_org_clob,length(l_temp_sql),l_temp_sql);
		    end loop;
       end if;

	hr_utility.set_location('Leaving Ent Loop',20);
	hr_utility.set_location('Entering OC Loop',30);

	IF p_org_oc_tab.count > 0 THEN
		   for i in p_org_oc_tab.first ..
			    p_org_oc_tab.last loop
		    hr_utility.set_location('Inside OC Loop',45);

		    l_temp_sql:= ' SELECT  '||
				  '''' || p_org_oc_tab(i).effective_date            ||''''||' effective_date ,'||
				  '''' || p_org_oc_tab(i).date_from                 ||''''||' date_from ,'||
				  '''' || REPLACE(p_org_oc_tab(i).business_grp_name , '''', '''''') ||''''||' business_grp_name ,'||
				  '''' || REPLACE(p_org_oc_tab(i).name , '''', '''''')      ||''''||' name ,'||
				  '''' || p_org_oc_tab(i).location_code             ||''''||' location_code ,'||
				  '''' || p_org_oc_tab(i).internal_external_flag    ||''''||' internal_external_flag '||
				  ' FROM DUAL UNION';

		    dbms_lob.writeappend(l_org_clob,length(l_temp_sql),l_temp_sql);
		    end loop;
	end if;

	hr_utility.set_location('Leaving OC Loop',40);
	hr_utility.set_location('Entering LE Loop',50);

	IF p_org_le_tab.count > 0 THEN
		   for i in p_org_le_tab.first ..
			    p_org_le_tab.last loop

		    l_temp_sql:= ' SELECT  '||
				  '''' || p_org_le_tab(i).effective_date            ||''''||' effective_date ,'||
				  '''' || p_org_le_tab(i).date_from                 ||''''||' date_from ,'||
				  '''' || REPLACE(p_org_le_tab(i).business_grp_name , '''', '''''') ||''''||' business_grp_name ,'||
				  '''' || REPLACE (p_org_le_tab(i).name, '''', '''''') ||''''||' name ,'||
				  '''' || p_org_le_tab(i).location_code		    ||''''||' location_code ,'||
				  '''' || p_org_le_tab(i).internal_external_flag    ||''''||' internal_external_flag '||
				  ' FROM DUAL UNION';

		    dbms_lob.writeappend(l_org_clob,length(l_temp_sql),l_temp_sql);
		    end loop;
	end if;

        hr_utility.set_location('Leaving LE Loop',60);
	dbms_lob.trim(l_org_clob,length(l_org_clob)-5);
	dbms_lob.writeappend(l_org_clob,length(l_orderby),l_orderby);

	l_ret_org_clob := fetch_clob(l_org_clob,'Organization','Organizations');
	return l_ret_org_clob;
end get_org_sql;

FUNCTION get_org_class_sql ( 	 p_org_ent_class_tab 		in out nocopy per_ri_config_tech_summary.org_ent_class_tab
			  	,p_org_oc_class_tab 		in out nocopy per_ri_config_tech_summary.org_oc_class_tab
			  	,p_org_le_class_tab 		in out nocopy per_ri_config_tech_summary.org_le_class_tab)
                            return clob IS

  l_org_class_clob 		clob;
  l_ret_org_class_clob 		clob;
  l_temp_sql 			varchar2(2000);
  queryCtx 			number;
  l_proc 			varchar2(200) 	:= 'get_org_class_sql';
  l_style 			varchar2(10);
  i 				number(8) 	:= 0;
  l_enabled 			varchar2(8);


  l_class_prejoin_sql varchar2(2000);
  l_class_postjoin_sql varchar2(2000);

BEGIN

	hr_utility.set_location('Entering ' || l_proc,10);

	select meaning into l_enabled from hr_lookups where lookup_type = 'YES_NO' and lookup_code = 'Y';
      	l_org_class_clob := get_clob_locator('ORGANIZATIONS');
      	dbms_lob.createtemporary(l_org_class_clob,TRUE);

	hr_utility.set_location('Entering Enterprise Classification ',15);

      	l_class_prejoin_sql:= '    	select effective_date,'
			    ||'	     date_from,'
			    ||'	     business_grp_name,'
			    ||'	     org_classif_code,'
			    ||'	     organization_name,'
			    ||'	     hrlkp.meaning org_classif_val,'
			    ||'	    ''Yes'' Enabled '
			    ||' from ( ';

      	dbms_lob.writeappend(l_org_class_clob,length(l_class_prejoin_sql),l_class_prejoin_sql);

       	IF p_org_ent_class_tab.count > 0 THEN
		   for i in p_org_ent_class_tab.first ..
			    p_org_ent_class_tab.last loop

		    l_temp_sql:= ' SELECT  '||
				  '''' || p_org_ent_class_tab(i).effective_date        ||''''||' effective_date ,'||
				  '''' || p_org_ent_class_tab(i).date_from             ||''''||' date_from ,'||
				  '''' || REPLACE(p_org_ent_class_tab(i).business_grp_name, '''', '''''')     ||''''||' business_grp_name ,'||
				  '''' || p_org_ent_class_tab(i).org_classif_code      ||''''||' org_classif_code ,'||
				  '''' || REPLACE(p_org_ent_class_tab(i).organization_name, '''', '''''')     ||''''||' organization_name '||
				  ' FROM DUAL UNION';

		    dbms_lob.writeappend(l_org_class_clob,length(l_temp_sql),l_temp_sql);
		    end loop;
       	end if;

	hr_utility.set_location('Leaving Enterprise Classification ',20);
	hr_utility.set_location('Entering OC Loop ',30);

       	IF p_org_oc_class_tab.count > 0 THEN
		   for i in p_org_oc_class_tab.first ..
			    p_org_oc_class_tab.last loop

		    l_temp_sql:= ' SELECT  '||
				  '''' || p_org_oc_class_tab(i).effective_date        ||''''||' effective_date ,'||
				  '''' || p_org_oc_class_tab(i).date_from             ||''''||' date_from ,'||
				  '''' || REPLACE(p_org_oc_class_tab(i).business_grp_name, '''', '''''')     ||''''||' business_grp_name ,'||
				  '''' || p_org_oc_class_tab(i).org_classif_code      ||''''||' org_classif_code ,'||
				  '''' || REPLACE(p_org_oc_class_tab(i).organization_name, '''', '''''')     ||''''||' organization_name '||
				  ' FROM DUAL UNION';

		    dbms_lob.writeappend(l_org_class_clob,length(l_temp_sql),l_temp_sql);
		    end loop;
       	end if;

	hr_utility.set_location('Leaving OC Loop',40);
	hr_utility.set_location('Entering LE Loop',50);

      	IF p_org_le_class_tab.count > 0 THEN
		   for i in p_org_le_class_tab.first ..
			    p_org_le_class_tab.last loop

		    l_temp_sql:= ' SELECT  '||
				  '''' || p_org_le_class_tab(i).effective_date       ||''''||' effective_date ,'||
				  '''' || p_org_le_class_tab(i).date_from            ||''''||' date_from ,'||
				  '''' || REPLACE(p_org_le_class_tab(i).business_grp_name, '''', '''''')    ||''''||' business_grp_name ,'||
				  '''' || p_org_le_class_tab(i).org_classif_code     ||''''||' org_classif_code ,'||
				  '''' || REPLACE (p_org_le_class_tab(i).organization_name, '''', '''''') ||''''||' organization_name '||
				  ' FROM DUAL UNION';

		    dbms_lob.writeappend(l_org_class_clob,length(l_temp_sql),l_temp_sql);
		    end loop;
       	end if;
        hr_utility.set_location('Leaving LE Loop',60);
	dbms_lob.trim(l_org_class_clob,length(l_org_class_clob)-5);

	l_class_postjoin_sql :=   ' ), hr_lookups hrlkp '
				||' where hrlkp.lookup_type= ''ORG_CLASS'''
				||' and hrlkp.lookup_code = org_classif_code ';

	dbms_lob.writeappend(l_org_class_clob,length(l_class_postjoin_sql),l_class_postjoin_sql);

	l_ret_org_class_clob := fetch_clob(l_org_class_clob,'OrgClassification','OrgClassifications');
	return l_ret_org_class_clob;

   END get_org_class_sql;

FUNCTION get_org_class_sql_for_pv ( p_org_ent_tab 		in per_ri_config_tech_summary.org_ent_tab
				    ,p_org_oc_tab 		in per_ri_config_tech_summary.org_oc_tab
	  		            ,p_org_le_tab 		in per_ri_config_tech_summary.org_le_tab
				    ,p_org_ent_class_tab 	in per_ri_config_tech_summary.org_ent_class_tab
				    ,p_org_oc_class_tab 	in per_ri_config_tech_summary.org_oc_class_tab
			  	    ,p_org_le_class_tab 	in per_ri_config_tech_summary.org_le_class_tab)
                            return clob IS

  l_org_class_clob_for_pv	 clob;
  l_org_class_append_clob_for_pv clob;
  l_temp_sql 			varchar2(32000);
  queryCtx 			number;
  l_proc 			varchar2(200) 	:= 'get_org_class_sql_for_pv';
  l_style 			varchar2(10);
  i 				number(8) 	:= 0;
  l_enabled 			varchar2(8);
  l_orderby		varchar2(200);

  l_org_classif_val varchar2(80);
  l_classification_exists  boolean := false;


BEGIN
      	hr_utility.set_location('Entering ' || l_proc,10);

	select meaning into l_enabled from hr_lookups where lookup_type = 'YES_NO' and lookup_code = 'Y';
	l_orderby := ' order by business_grp_name desc, name desc ';
      	l_org_class_clob_for_pv := get_clob_locator('ORGANIZATION_CLASSIF');
      	dbms_lob.createtemporary(l_org_class_clob_for_pv,TRUE);

	--For every org find all classifications
	IF p_org_ent_tab.count > 0 THEN
	   for j in p_org_ent_tab.first ..
		p_org_ent_tab.last loop

		l_classification_exists := false;
                l_temp_sql:= ' SELECT  '||
				  '''' || p_org_ent_tab(j).effective_date            ||''''||' effective_org_date ,'||
				  '''' || p_org_ent_tab(j).date_from                 ||''''||' org_date_from ,'||
				  '''' || p_org_ent_tab(j).location_code             ||''''||' location_code ,'||
				  '''' || p_org_ent_tab(j).internal_external_flag    ||''''||' internal_external_flag ';

		IF p_org_ent_class_tab.count > 0 THEN
		    for i in p_org_ent_class_tab.first ..
		        p_org_ent_class_tab.last loop

		    if  p_org_ent_tab(j).business_grp_name = p_org_ent_class_tab(i).business_grp_name
		    and  p_org_ent_tab(j).name	= p_org_ent_class_tab(i).organization_name   then

		    l_org_classif_val := p_org_ent_class_tab(i).org_classif_code;
		    if p_org_ent_class_tab(i).org_classif_code is not null then
		       begin
			select meaning into l_org_classif_val from hr_lookups where lookup_type= 'ORG_CLASS' and lookup_code = p_org_ent_class_tab(i).org_classif_code;
		       exception
		        when no_data_found then
		        null;
		        end;
		     end if;
		    l_classification_exists := true;
  		    l_temp_sql := l_temp_sql ||  ',' ||
				  '''' || p_org_ent_class_tab(i).effective_date        ||''''||' effective_date ,'||
				  '''' || p_org_ent_class_tab(i).date_from             ||''''||' date_from ,'||
				  '''' || REPLACE(p_org_ent_class_tab(i).business_grp_name, '''', '''''')     ||''''||' business_grp_name ,'||
				  '''' || p_org_ent_class_tab(i).org_classif_code      ||''''||' org_classif_code ,'||
				  '''' || REPLACE(p_org_ent_class_tab(i).organization_name, '''', '''''')     ||''''||' organization_name, '||
				  '''' || l_enabled				       ||''''||' enabled, '||
				  '''' || l_org_classif_val			     ||''''||' org_classif_val ';

		    end if;
	    end loop;
		l_temp_sql := l_temp_sql || ' FROM DUAL';
		if l_classification_exists then
		dbms_lob.writeappend(l_org_class_clob_for_pv,length(l_temp_sql),l_temp_sql);
		l_org_class_append_clob_for_pv := l_org_class_append_clob_for_pv || fetch_clob(l_org_class_clob_for_pv,'OrgClassificationForPV','OrgClassificationsForPV');
		dbms_lob.trim(l_org_class_clob_for_pv,0);
		end if;
	  end if;
	  end loop;
       	end if;
	hr_utility.set_location('Leaving Loop',20);
	hr_utility.set_location('Entering OC Loop',30);

	--For every org find all classifications
	IF p_org_oc_tab.count > 0 THEN
	   for j in p_org_oc_tab.first ..
		p_org_oc_tab.last loop

		l_temp_sql:= ' SELECT  '||
			     '''' || p_org_oc_tab(j).effective_date            ||''''||' effective_org_date ,'||
			     '''' || p_org_oc_tab(j).date_from                 ||''''||' org_date_from ,'||
			     '''' || p_org_oc_tab(j).location_code             ||''''||' location_code ,'||
			     '''' || p_org_oc_tab(j).internal_external_flag    ||''''||' internal_external_flag ';

       		IF p_org_oc_class_tab.count > 0 THEN
		   for i in p_org_oc_class_tab.first ..
			p_org_oc_class_tab.last loop

		    if  p_org_oc_tab(j).business_grp_name = p_org_oc_class_tab(i).business_grp_name
		    and  p_org_oc_tab(j).name	= p_org_oc_class_tab(i).organization_name   then

		    l_org_classif_val := p_org_oc_class_tab(i).org_classif_code;
		    if p_org_oc_class_tab(i).org_classif_code is not null then
		       begin
			select meaning into l_org_classif_val from hr_lookups where lookup_type= 'ORG_CLASS' and lookup_code = p_org_oc_class_tab(i).org_classif_code;
		       exception
		        when no_data_found then
		        null;
		        end;
		     end if;
			l_classification_exists := true;

			l_temp_sql := l_temp_sql || ',' ||
				  '''' || p_org_oc_class_tab(i).effective_date        ||''''||' effective_date ,'||
				  '''' || p_org_oc_class_tab(i).date_from             ||''''||' date_from ,'||
				  '''' || REPLACE(p_org_oc_class_tab(i).business_grp_name, '''', '''''')     ||''''||' business_grp_name ,'||
				  '''' || p_org_oc_class_tab(i).org_classif_code      ||''''||' org_classif_code ,'||
				  '''' || REPLACE(p_org_oc_class_tab(i).organization_name, '''', '''''')     ||''''||' organization_name, '||
				  '''' || l_enabled				       ||''''||' enabled, '||
				  '''' || l_org_classif_val			     ||''''||' org_classif_val ';

		    end if;
   	     end loop;

		l_temp_sql := l_temp_sql || ' FROM DUAL';
		if l_classification_exists then
		dbms_lob.writeappend(l_org_class_clob_for_pv,length(l_temp_sql),l_temp_sql);
		l_org_class_append_clob_for_pv := l_org_class_append_clob_for_pv || fetch_clob(l_org_class_clob_for_pv,'OrgClassificationForPV','OrgClassificationsForPV');
		dbms_lob.trim(l_org_class_clob_for_pv,0);
		end if;
 	  end if;
	  end loop;
       	end if;

	hr_utility.set_location('Leaving OC Loop',40);
	hr_utility.set_location('Entering LE Loop',50);

	--For every org find all classifications
	IF p_org_le_tab.count > 0 THEN
	   for j in p_org_le_tab.first ..
		p_org_le_tab.last loop

	    l_temp_sql:= ' SELECT  '||
				  '''' || p_org_le_tab(j).effective_date            ||''''||' effective_org_date ,'||
				  '''' || p_org_le_tab(j).date_from                 ||''''||' org_date_from ,'||
				  '''' || p_org_le_tab(j).location_code             ||''''||' location_code ,'||
				  '''' || p_org_le_tab(j).internal_external_flag    ||''''||' internal_external_flag ';

		IF p_org_le_class_tab.count > 0 THEN
		   for i in p_org_le_class_tab.first ..
			    p_org_le_class_tab.last loop

		    if  p_org_le_tab(j).business_grp_name = p_org_le_class_tab(i).business_grp_name
		    and  p_org_le_tab(j).name	= p_org_le_class_tab(i).organization_name   then

		    l_org_classif_val := p_org_le_class_tab(i).org_classif_code;

		    if p_org_le_class_tab(i).org_classif_code is not null then
		       begin
			select meaning into l_org_classif_val from hr_lookups where lookup_type= 'ORG_CLASS' and lookup_code = p_org_le_class_tab(i).org_classif_code;
		       exception
		       when no_data_found then
		       null;
		       end;

		    end if;
			l_classification_exists := true;
			l_temp_sql := l_temp_sql || ',' ||
				  '''' || p_org_le_class_tab(i).effective_date       ||''''||' effective_date,'||
				  '''' || p_org_le_class_tab(i).date_from            ||''''||' date_from ,'||
				  '''' || REPLACE (p_org_le_class_tab(i).business_grp_name , '''', '''''')  ||''''||' business_grp_name ,'||
				  '''' || p_org_le_class_tab(i).org_classif_code     ||''''||' org_classif_code ,'||
				  '''' || REPLACE (p_org_le_class_tab(i).organization_name , '''', '''''')   ||''''||' organization_name, '||
				  '''' || l_enabled				     ||''''||' enabled, '||
				  '''' || l_org_classif_val			     ||''''||' org_classif_val ';
		    end if;
	    end loop;
		l_temp_sql := l_temp_sql || ' FROM DUAL';
		if l_classification_exists then
		dbms_lob.writeappend(l_org_class_clob_for_pv,length(l_temp_sql),l_temp_sql);
		l_org_class_append_clob_for_pv := l_org_class_append_clob_for_pv || fetch_clob(l_org_class_clob_for_pv,'OrgClassificationForPV','OrgClassificationsForPV');
		dbms_lob.trim(l_org_class_clob_for_pv,0);
		end if;
	  end if;
	  end loop;
	end if;

	hr_utility.set_location('Leaving LE Loop',60);

	return l_org_class_append_clob_for_pv;
END get_org_class_sql_for_pv;

FUNCTION get_locations_sql (p_location_tab in out nocopy per_ri_config_tech_summary.location_tab)
                   return clob IS

  l_user_column_name            varchar2(200);
  l_proc                        varchar2(72) 	:= g_package || 'get_locations_sql';
  i 				number(8) 	:= 0;
  l_ret_location_clob		clob;
  l_temp_sql			varchar2(2000);
  l_location_clob		clob;
  queryCtx			number(8)	:= 0;
  l_style			varchar2(10);
  l_prejoin_sql			varchar2(2000);
  l_postjoin_sql		varchar2(2000);
  l_orderby			varchar2(200);
  l_style_val			varchar2(30);
  l_country                     varchar2(80);

  cursor csr_get_prm(cp_style          in varchar2
                     ,cp_app_col_name in varchar2) IS

    select end_user_column_name
    from fnd_descr_flex_col_usage_vl
    where descriptive_flexfield_name= 'Address Location'
    and   descriptive_flex_context_code = cp_style
    and   application_column_name       = cp_app_col_name;

  cursor csr_get_style(cp_style 	in varchar2) IS
   select terr.territory_short_name Address_Style
   from fnd_territories_vl terr
   where terr.territory_code = cp_style;

  BEGIN
    hr_utility.set_location('Entering ' || l_proc,10);
    l_location_clob := get_clob_locator('LOCATIONS');
    dbms_lob.createtemporary(l_location_clob,TRUE);

    l_prejoin_sql  := ' select decode(A.style,''GENERIC'',''Generic'',terr.territory_short_name) Address_Style '
		     ||' from ( ';
    l_postjoin_sql := ') A, fnd_territories_vl terr where terr.territory_code(+) = A.style ';
    l_orderby	   :=      ' order by style desc ,location_code desc ';

    if p_location_tab.count > 0 THEN
      for i in p_location_tab.first ..
                         p_location_tab.last loop

	l_style := p_location_tab(i).style;

        if(l_style = 'GENERIC')
         then
	  l_style_val := 'Generic';
	else
	 open csr_get_style(l_style);
	 fetch csr_get_style into l_style_val;
	 close  csr_get_style;
	end if;

	open csr_get_style(p_location_tab(i).country);
	fetch csr_get_style into l_country;
		if csr_get_style%NOTFOUND then
			l_country := p_location_tab(i).country;
		end if;
	close  csr_get_style;

        l_temp_sql:=' SELECT  '||
	   			'''' || replace(p_location_tab(i).location_code,'''','''''')	||''''||' LOCATION_CODE ,'||
	  			'''' || replace(p_location_tab(i).description,'''','''''')	||''''||' DESCRIPTION ,'||
	                        '''' || l_style_val						||''''||' STYLE ,'||
	   			'''' || replace(p_location_tab(i).address_line_1,'''','''''') ||''''||' ADDRESS_LINE_1 ,'||
	                        '''' || per_ri_config_utilities.get_location_prompt(l_style,'ADDRESS_LINE_1') 	||''''||' ADDRESS_LINE1_PROMPT ,'||
	  			'''' || nvl(replace(p_location_tab(i).address_line_2,'''',''''''),' ')	||''''	||' ADDRESS_LINE_2 ,'||
	                        '''' || per_ri_config_utilities.get_location_prompt(l_style,'ADDRESS_LINE_2') 	||''''||' ADDRESS_LINE2_PROMPT ,'||
	  			'''' || nvl(replace(p_location_tab(i).address_line_3,'''',''''''),' ')		||''''||' ADDRESS_LINE_3 ,'||
	  			'''' || per_ri_config_utilities.get_location_prompt(l_style,'ADDRESS_LINE_3') 	||''''||' ADDRESS_LINE3_PROMPT ,'||
	  			'''' || nvl(replace(p_location_tab(i).town_or_city,'''',''''''),' ')	      	||''''||' TOWN_OR_CITY ,'||
	  			'''' || per_ri_config_utilities.get_location_prompt(l_style,'TOWN_OR_CITY')   	||''''||' TOWN_OR_CITY_PROMPT ,'||
	  			'''' || nvl(replace(l_country,'''',''''''),' ')		      	||''''||' COUNTRY ,'||
	                        '''' || per_ri_config_utilities.get_location_prompt(l_style,'COUNTRY')	      	||''''||' COUNTRY_PROMPT ,'||
	  			'''' || nvl(replace(p_location_tab(i).postal_code,'''',''''''),' ')		||''''||' POSTAL_CODE ,'||
	  			'''' || per_ri_config_utilities.get_location_prompt(l_style,'POSTAL_CODE')	||''''||' POSTAL_CODE_PROMPT ,'||
	  			'''' || nvl(replace(p_location_tab(i).region_1,'''',''''''),' ')		||''''||' REGION1 ,'||
	  			'''' || per_ri_config_utilities.get_location_prompt(l_style,'REGION_1') 	||''''||' REGION1_PROMPT ,'||
	  			'''' || nvl(replace(p_location_tab(i).region_2,'''',''''''),' ')		||''''||' REGION2 ,'||
	  			'''' || per_ri_config_utilities.get_location_prompt(l_style,'REGION_2') 	||''''||' REGION2_PROMPT ,'||
	  			'''' || nvl(replace(p_location_tab(i).region_3,'''',''''''),' ')		||''''||' REGION3 ,'||
	  			'''' || per_ri_config_utilities.get_location_prompt(l_style,'REGION_3') 	||''''||' REGION3_PROMPT ,'||
	  			'''' || nvl(replace(p_location_tab(i).telephone_number_1,'''',''''''),' ')||''''||' TELEPHONE_NUMBER_1 ,'||
	  			'''' || per_ri_config_utilities.get_location_prompt(l_style,'TELEPHONE_NUMBER_1')||''''||' TELEPHONE_NUMBER1_PROMPT ,'||
	  			'''' || nvl(replace(p_location_tab(i).telephone_number_2,'''',''''''),' ')||''''||' TELEPHONE_NUMBER_2 ,'||
	  			'''' || per_ri_config_utilities.get_location_prompt(l_style,'TELEPHONE_NUMBER_2')||''''||' TELEPHONE_NUMBER2_PROMPT ,'||
	  			'''' || nvl(replace(p_location_tab(i).telephone_number_3,'''',''''''),' ')||''''||' TELEPHONE_NUMBER_3 ,'||
	  			'''' || per_ri_config_utilities.get_location_prompt(l_style,'TELEPHONE_NUMBER_3')||''''||' TELEPHONE_NUMBER3_PROMPT ,'||
	  			'''' || nvl(replace(p_location_tab(i).loc_information13,'''',''''''),' ')||''''||' LOC_INFORMATION13 ,'||
	  			'''' || per_ri_config_utilities.get_location_prompt(l_style,'LOC_INFORMATION13') ||''''||' LOC_INFORMATION13_PROMPT ,'||
	  			'''' || nvl(replace(p_location_tab(i).loc_information14,'''',''''''),' ')||''''||' LOC_INFORMATION14 ,'||
	  			'''' || per_ri_config_utilities.get_location_prompt(l_style,'LOC_INFORMATION14') ||''''||' LOC_INFORMATION14_PROMPT ,'||
	  			'''' || nvl(replace(p_location_tab(i).loc_information15,'''',''''''),' ')||''''||' LOC_INFORMATION15 ,'||
	  			'''' || per_ri_config_utilities.get_location_prompt(l_style,'LOC_INFORMATION15') ||''''||' LOC_INFORMATION15_PROMPT ,'||
	  			'''' || nvl(replace(p_location_tab(i).loc_information16,'''',''''''),' ')||''''||' LOC_INFORMATION16 ,'||
	  			'''' || per_ri_config_utilities.get_location_prompt(l_style,'LOC_INFORMATION16') ||''''||' LOC_INFORMATION16_PROMPT ,'||
	  			'''' || nvl(replace(p_location_tab(i).loc_information17,'''',''''''),' ')||''''||' LOC_INFORMATION17 ,'||
	  			'''' || per_ri_config_utilities.get_location_prompt(l_style,'LOC_INFORMATION17')||''''||' LOC_INFORMATION17_PROMPT  ,'||
	  			'''' || nvl(replace(p_location_tab(i).loc_information18,'''',''''''),' ')||''''||' LOC_INFORMATION18 ,'||
	  			'''' || per_ri_config_utilities.get_location_prompt(l_style,'LOC_INFORMATION18')||''''||' LOC_INFORMATION18_PROMPT  ,'||
	  			'''' || nvl(replace(p_location_tab(i).loc_information19,'''',''''''),' ')||''''||' LOC_INFORMATION19 ,'||
	  			'''' || per_ri_config_utilities.get_location_prompt(l_style,'LOC_INFORMATION19')||''''||' LOC_INFORMATION19_PROMPT  ,'||
	                        '''' || nvl(replace(p_location_tab(i).loc_information20,'''',''''''),' ')||''''||' LOC_INFORMATION20 ,'||
	                        '''' || per_ri_config_utilities.get_location_prompt(l_style,'LOC_INFORMATION20')||''''||' LOC_INFORMATION20_PROMPT  '||
                          ' FROM DUAL UNION';

                  dbms_lob.writeappend(l_location_clob,length(l_temp_sql),l_temp_sql);

   	 end loop;
    	end if;

	dbms_lob.trim(l_location_clob,length(l_location_clob)-5);
	dbms_lob.writeappend(l_location_clob,length(l_orderby),l_orderby);
	l_ret_location_clob := fetch_clob(l_location_clob,'Location','Locations');
 	hr_utility.set_location('Leaving ' || l_proc,20);
	return l_ret_location_clob;

END get_locations_sql;

FUNCTION get_user_sql (p_user_tab in out nocopy per_ri_config_tech_summary.user_tab)
                   return clob IS

  l_user_column_name            varchar2(200);
  l_proc                        varchar2(72) 	:= g_package || 'get_user_sql';
  i 				number(8) 	:= 0;
  l_ret_user_clob		clob;
  l_temp_sql			varchar2(2000);
  l_user_clob			clob;
  queryCtx			number(8)	:= 0;

  BEGIN

    hr_utility.set_location('Entering ' || l_proc,10);
    l_user_clob := get_clob_locator('USERS');
    dbms_lob.createtemporary(l_user_clob,TRUE);

    if p_user_tab.count > 0 THEN
      for i in p_user_tab.first ..
                         p_user_tab.last loop

        l_temp_sql:= ' SELECT ' ||
                     '''' || p_user_tab(i).user_name    ||''''||' user_name ,' ||
                     '''' || p_user_tab(i).start_date   ||''''||' start_date ,'||
                     '''' || p_user_tab(i).description  ||''''||' description '||
                     ' FROM DUAL UNION';

                  dbms_lob.writeappend(l_user_clob,length(l_temp_sql),l_temp_sql);
   	 end loop;
    	end if;

	dbms_lob.trim(l_user_clob,length(l_user_clob)-5);
	l_ret_user_clob := fetch_clob(l_user_clob,'User','Users');
	hr_utility.set_location('Leaving ' || l_proc,20);
	return l_ret_user_clob;

END get_user_sql;


FUNCTION get_resp_sql (
  			  p_resp_tab 		in out nocopy per_ri_config_tech_summary.resp_tab
  			 ,p_hrms_resp_tab 	in out nocopy per_ri_config_tech_summary.hrms_resp_tab
  			 ,p_hrms_misc_resp_tab	in out nocopy per_ri_config_tech_summary.hrms_resp_tab
  			)
                     return clob IS

    l_user_column_name          varchar2(200);
    l_proc                      varchar2(72) 	:= g_package || 'get_resp_sql';
    i 				number(8) 	:= 0;
    l_ret_resp_clob		clob;
    l_temp_sql			varchar2(2000);
    l_resp_clob			clob;
    queryCtx			number(8)	:= 0;
    l_prejoin_sql		varchar2(2000);
    l_postjoin_sql		varchar2(2000);

    BEGIN

      hr_utility.set_location('Entering ' || l_proc,10);
      l_resp_clob := get_clob_locator('RESPONSIBILITIES');
      dbms_lob.createtemporary(l_resp_clob,TRUE);

      l_prejoin_sql := ' select distinct A.user_name , A.resp_key ResponsibilityName ,'
	       	      ||' decode(A.security_group,''STANDARD'',''Standard'',A.security_group) SecurityGroupName, '
	       	      ||' app.APPLICATION_NAME ApplicationName, A.start_date from ( ';

      dbms_lob.writeappend(l_resp_clob,length(l_prejoin_sql),l_prejoin_sql);

      if p_resp_tab.count > 0 THEN
        for i in p_resp_tab.first ..
                           p_resp_tab.last loop

          l_temp_sql:= ' SELECT ' ||
                       '''' || p_resp_tab(i).user_name          ||''''||' user_name ,' 	||
                       '''' || p_resp_tab(i).resp_key           ||''''||' resp_key  ,'	||
                       '''' || p_resp_tab(i).app_short_name     ||''''||' app_short_name, '||
                       '''' || p_resp_tab(i).security_group     ||''''||' security_group,'||
                       '''' || p_resp_tab(i).owner              ||''''||' owner,'	||
                       '''' || g_config_effective_date          ||''''||' start_date,'||
                       '''' || p_resp_tab(i).end_date           ||''''||' end_date,'	||
                       '''' || p_resp_tab(i).description        ||''''||' description'	||
                       ' FROM DUAL UNION';

                    dbms_lob.writeappend(l_resp_clob,length(l_temp_sql),l_temp_sql);
     	 end loop;
      	end if;

       if p_hrms_resp_tab.count > 0 THEN
               for i in p_hrms_resp_tab.first ..
                                  p_hrms_resp_tab.last loop

                 l_temp_sql:= ' SELECT ' ||
                              '''' || p_hrms_resp_tab(i).user_name          		||''''||' user_name ,' 	||
                              '''' || p_hrms_resp_tab(i).resp_key           		||''''||' resp_key  ,'	||
                              '''' || nvl(p_hrms_resp_tab(i).app_short_name,'PER')     	||''''||' app_short_name, '	||
                              '''' || p_hrms_resp_tab(i).security_group     		||''''||' security_group,'	||
                              '''' || p_hrms_resp_tab(i).owner             		||''''||' owner,'		||
                              '''' || g_config_effective_date                           ||''''||' start_date,'  ||
                              '''' || p_hrms_resp_tab(i).end_date          		||''''||' end_date,'	||
                              '''' || p_hrms_resp_tab(i).description       		||''''||' description'	||
                              ' FROM DUAL UNION';

                           dbms_lob.writeappend(l_resp_clob,length(l_temp_sql),l_temp_sql);
            	 end loop;
      	end if;

      	/*if p_hrms_misc_resp_tab.count > 0 THEN
	               for i in p_hrms_misc_resp_tab.first ..
	                                  p_hrms_misc_resp_tab.last loop

		 l_temp_sql:= ' SELECT ' ||
			      '''' || p_hrms_misc_resp_tab(i).user_name          		||''''||' user_name ,' 	||
			      '''' || p_hrms_misc_resp_tab(i).resp_key           		||''''||' resp_key  ,'	||
			      '''' || nvl(p_hrms_misc_resp_tab(i).app_short_name,'PER')     	||''''||' app_short_name, '	||
			      '''' || p_hrms_misc_resp_tab(i).security_group     		||''''||' security_group,'	||
			      '''' || p_hrms_misc_resp_tab(i).owner             		||''''||' owner,'		||
                              '''' || g_config_effective_date                                   ||''''||' start_date,'  ||
			      '''' || p_hrms_misc_resp_tab(i).end_date          		||''''||' end_date,'	||
			      '''' || p_hrms_misc_resp_tab(i).description       		||''''||' description'	||
			      ' FROM DUAL UNION';

			   dbms_lob.writeappend(l_resp_clob,length(l_temp_sql),l_temp_sql);
		 end loop;
      	end if;*/

  	dbms_lob.trim(l_resp_clob,length(l_resp_clob)-5);
 	l_postjoin_sql := ' )A   ,fnd_responsibility_vl resp,FND_SECURITY_GROUPS_VL secgrp ,fnd_application_vl app '
 			||' where  '
  			||'  A.app_short_name = app.application_short_name  '
  			||' order by ResponsibilityName ,ApplicationName  , SecurityGroupName ';


  	dbms_lob.writeappend(l_resp_clob,length(l_postjoin_sql),l_postjoin_sql);
  	l_ret_resp_clob :=  fetch_clob(l_resp_clob,'Resp','Resps');

	hr_utility.set_location('Leaving ' || l_proc,20);
  	return l_ret_resp_clob;

END get_resp_sql;

--For site level profiles.
FUNCTION get_profile_sql (
      				 p_profile_tab 		in out nocopy per_ri_config_tech_summary.profile_tab,
      				 p_profile_dpe_ent_tab 	in out nocopy per_ri_config_tech_summary.profile_dpe_ent_tab
      			     )
                           return clob IS

          l_user_column_name         	varchar2(200);
          l_proc                     	varchar2(72) 	:= g_package || 'get_profile_sql';
          i 				number(8) 	:= 0;
          l_ret_profile_clob		clob;
          l_temp_sql			varchar2(2000);
          l_profile_clob		clob;
          queryCtx			number(8)	:= 0;
          l_prejoin_sql			varchar2(2000);
          l_postjoin_sql		varchar2(2000);
	  l_translated_prof_opt_value   hr_lookups.meaning%type;

BEGIN
	 hr_utility.set_location('Entering ' || l_proc,10);
	 l_profile_clob := get_clob_locator('Profiles');
	 dbms_lob.createtemporary(l_profile_clob,TRUE);

	 l_prejoin_sql := ' select A.level_x , fprf.user_profile_option_name UserProfileName,'||
			    ' decode(A.profile_option_value, ''Y'',''Yes'',''N'',''No'',A.profile_option_value) ProfileValue, '||
			    ' fapp.Application_Name, A.level_value from  (';

	 l_postjoin_sql :=' )A, FND_PROFILE_OPTIONS_VL fprf  '||
			    ' ,fnd_application_vl fapp '||
			    ' where fprf.profile_option_name = A.profile_name '||
			    ' and fapp.APPLICATION_SHORT_NAME = A.level_value_app '||
			    ' and level_x = ''1001'' '||			     --only for Site level profiles
			    ' order by UserProfileName desc';

	 dbms_lob.writeappend(l_profile_clob,length(l_prejoin_sql),l_prejoin_sql);

   	 if p_profile_tab.count > 0 THEN
     		 for i in p_profile_tab.first ..
			 p_profile_tab.last loop

		--Hardcoding for now
		if p_profile_tab(i).profile_name = 'BIS_WORKFORCE_MEASUREMENT_TYPE'
			and p_profile_tab(i).profile_option_value = 'HEAD' then
			select meaning into l_translated_prof_opt_value from hr_lookups where lookup_type = 'BUDGET_MEASUREMENT_TYPE' and lookup_code = 'HEAD';
		elsif p_profile_tab(i).profile_name =  'HR_GENERATE_GL_ORGS'
			and p_profile_tab(i).profile_option_value = 'CCHR' then
			select meaning into l_translated_prof_opt_value from hr_lookups where lookup_type like 'HR_GEN_GL_ORG' and lookup_code like 'CCHR';

		else
			l_translated_prof_opt_value := p_profile_tab(i).profile_option_value;
		end if;

		l_temp_sql:= ' SELECT ' ||
			     '''' || p_profile_tab(i).level                ||''''||' level_x,'              ||
			     '''' || p_profile_tab(i).level_value          ||''''||' level_value,'          ||
			     '''' || p_profile_tab(i).level_value_app      ||''''||' level_value_app,'      ||
			     '''' || p_profile_tab(i).profile_name         ||''''||' profile_name,'         ||
			     '''' || l_translated_prof_opt_value           ||''''||' profile_option_value ' ||
			     ' FROM DUAL UNION';

			  dbms_lob.writeappend(l_profile_clob,length(l_temp_sql),l_temp_sql);
		 end loop;
	end if;

	if p_profile_dpe_ent_tab.count > 0 THEN
		 for i in p_profile_dpe_ent_tab.first ..
			 p_profile_dpe_ent_tab.last loop

		--Hardcoding for now
		if p_profile_tab(i).profile_name = 'BIS_WORKFORCE_MEASUREMENT_TYPE'
			and p_profile_tab(i).profile_option_value = 'HEAD' then
			select meaning into l_translated_prof_opt_value from hr_lookups where lookup_type = 'BUDGET_MEASUREMENT_TYPE' and lookup_code = 'HEAD';
		else
			l_translated_prof_opt_value := p_profile_tab(i).profile_option_value;
		end if;


		l_temp_sql:= ' SELECT ' ||
			     '''' || p_profile_dpe_ent_tab(i).level                ||''''||' level_x,'              ||
			     '''' || p_profile_dpe_ent_tab(i).level_value          ||''''||' level_value,'          ||
			     '''' || p_profile_dpe_ent_tab(i).level_value_app      ||''''||' level_value_app,'      ||
			     '''' || p_profile_dpe_ent_tab(i).profile_name         ||''''||' profile_name,'         ||
			     '''' || l_translated_prof_opt_value                   ||''''||' profile_option_value ' ||
			     ' FROM DUAL UNION';

			  dbms_lob.writeappend(l_profile_clob,length(l_temp_sql),l_temp_sql);
		 end loop;
	end if;

	dbms_lob.trim(l_profile_clob,length(l_profile_clob)-5);
	dbms_lob.writeappend(l_profile_clob,length(l_postjoin_sql),l_postjoin_sql);
	l_ret_profile_clob := fetch_clob(l_profile_clob,'Profile','Profiles');
	hr_utility.set_location('Leaving ' || l_proc,20);
	return l_ret_profile_clob;

END get_profile_sql;



FUNCTION get_profile_apps_sql (
 				 p_profile_apps_tab in out nocopy per_ri_config_tech_summary.profile_apps_tab
 				)
                      return clob IS

	     l_user_column_name         varchar2(200);
	     l_proc                     varchar2(72) 	:= g_package || 'get_profile_apps_sql';
	     i 				number(8) 	:= 0;
	     l_ret_profile_apps_clob	clob;
	     l_temp_sql			varchar2(2000);
	     l_profile_apps_clob	clob;
	     queryCtx			number(8)	:= 0;
	     l_prejoin_sql		varchar2(2000);
	     l_postjoin_sql		varchar2(2000);

     BEGIN

       hr_utility.set_location('Entering ' || l_proc,10);
       l_profile_apps_clob := get_clob_locator('profile_appss');
       dbms_lob.createtemporary(l_profile_apps_clob,TRUE);

      l_prejoin_sql := ' select A.level_x , fprf.user_profile_option_name UserProfileName,'||
		       ' decode(A.profile_option_value, ''Y'',''Yes'',''N'',''No'',A.profile_option_value) ProfileValue, '||
		       ' fapp.Application_Name, A.level_value from  (';

      l_postjoin_sql :=' )A, FND_PROFILE_OPTIONS_VL fprf  '||
		       ' ,fnd_application_vl fapp '||
		       ' where fprf.profile_option_name = A.profile_name '||
		       ' and fapp.APPLICATION_SHORT_NAME = A.level_value_app ';

      dbms_lob.writeappend(l_profile_apps_clob,length(l_prejoin_sql),l_prejoin_sql);

       if p_profile_apps_tab.count > 0 THEN
	 for i in p_profile_apps_tab.first ..
			    p_profile_apps_tab.last loop

	   l_temp_sql:= ' SELECT ' ||
			'''' || p_profile_apps_tab(i).level                ||''''||' level_x,'              ||
			'''' || p_profile_apps_tab(i).level_value          ||''''||' level_value,'          ||
			'''' || p_profile_apps_tab(i).level_value_app      ||''''||' level_value_app,'      ||
			'''' || p_profile_apps_tab(i).profile_name         ||''''||' profile_name,'         ||
			'''' || p_profile_apps_tab(i).profile_option_value ||''''||' profile_option_value ' ||
			' FROM DUAL UNION';

		     dbms_lob.writeappend(l_profile_apps_clob,length(l_temp_sql),l_temp_sql);
	 end loop;
	end if;

	dbms_lob.trim(l_profile_apps_clob,length(l_profile_apps_clob)-5);
	dbms_lob.writeappend(l_profile_apps_clob,length(l_postjoin_sql),l_postjoin_sql);
	l_ret_profile_apps_clob := fetch_clob(l_profile_apps_clob,'profile_apps','profile_apps');
	hr_utility.set_location('Leaving ' || l_proc,20);
	return l_ret_profile_apps_clob;

END get_profile_apps_sql;

FUNCTION get_profile_resp_sql (
			     p_profile_resp_tab in out nocopy per_ri_config_tech_summary.profile_resp_tab
			   )
		   return clob IS

	  l_user_column_name         	varchar2(200);
	  l_proc                     	varchar2(72) 	:= g_package || 'get_profile_resp_sql';
	  i 				number(8) 	:= 0;
	  l_ret_profile_resp_clob	clob;
	  l_temp_sql			varchar2(2000);
	  l_profile_resp_clob		clob;
	  queryCtx			number(8)	:= 0;
	  l_prejoin_sql			varchar2(2000);
	  l_postjoin_sql		varchar2(2000);
	  l_prof_opt_value              fnd_lookup_values.meaning%type;

	  BEGIN
	   hr_utility.set_location('Entering ' || l_proc,10);
	   l_profile_resp_clob := get_clob_locator('profile_resp');
	   dbms_lob.createtemporary(l_profile_resp_clob,TRUE);

	   l_prejoin_sql := ' select A.level_x , fprf.user_profile_option_name UserProfileName,'||
			    ' decode(A.profile_option_value, ''Y'',''Yes'',''N'',''No'',A.profile_option_value) ProfileValue, '||
			    ' fapp.Application_Name, A.level_value from  (';

	   l_postjoin_sql :=' )A, FND_PROFILE_OPTIONS_VL fprf  '||
			    ' ,fnd_application_vl fapp '||
			    ' where fprf.profile_option_name = A.profile_name '||
			    ' and fapp.APPLICATION_SHORT_NAME = A.level_value_app ';

	   dbms_lob.writeappend(l_profile_resp_clob,length(l_prejoin_sql),l_prejoin_sql);

	    if p_profile_resp_tab.count > 0 THEN
	      for i in p_profile_resp_tab.first ..
				 p_profile_resp_tab.last loop

		if p_profile_resp_tab(i).profile_name = 'HR_USER_TYPE' then
			select meaning into l_prof_opt_value from fnd_lookup_values where lookup_type = 'HR_USER_TYPE' and language = userenv('LANG') and lookup_code like p_profile_resp_tab(i).profile_option_value;
		else
			l_prof_opt_value := p_profile_resp_tab(i).profile_option_value;
		end if;

		l_temp_sql:= ' SELECT ' ||
			     '''' || p_profile_resp_tab(i).level                ||''''||' level_x,'              ||
			     '''' || p_profile_resp_tab(i).level_value          ||''''||' level_value,'          ||
			     '''' || p_profile_resp_tab(i).level_value_app      ||''''||' level_value_app,'      ||
			     '''' || p_profile_resp_tab(i).profile_name         ||''''||' profile_name,'         ||
			     '''' || l_prof_opt_value                           ||''''||' profile_option_value ' ||
			     ' FROM DUAL UNION';


			  dbms_lob.writeappend(l_profile_resp_clob,length(l_temp_sql),l_temp_sql);
		 end loop;
		end if;

	    dbms_lob.trim(l_profile_resp_clob,length(l_profile_resp_clob)-5);
	    dbms_lob.writeappend(l_profile_resp_clob,length(l_postjoin_sql),l_postjoin_sql);
	    l_ret_profile_resp_clob := fetch_clob(l_profile_resp_clob,'profile_resp','profile_resp');

	    hr_utility.set_location('Leaving ' || l_proc,20);
	    return l_ret_profile_resp_clob;

END get_profile_resp_sql;

FUNCTION  get_keyflex_structure_sql
				 (
				    p_kf_job_tab 		in out nocopy per_ri_config_tech_summary.kf_job_tab,
				    p_kf_job_rv_tab 		in out nocopy per_ri_config_tech_summary.kf_job_rv_tab,
				    p_kf_job_no_rv_tab 		in out nocopy per_ri_config_tech_summary.kf_job_no_rv_tab,
				    p_kf_pos_tab 		in out nocopy per_ri_config_tech_summary.kf_pos_tab,
				    p_kf_pos_rv_tab 		in out nocopy per_ri_config_tech_summary.kf_pos_rv_tab,
				    p_kf_pos_no_rv_tab 		in out nocopy per_ri_config_tech_summary.kf_pos_no_rv_tab,
				    p_kf_grd_tab 		in out nocopy per_ri_config_tech_summary.kf_grd_tab,
				    p_kf_grd_rv_tab 		in out nocopy per_ri_config_tech_summary.kf_grd_rv_tab,
				    p_kf_grd_no_rv_tab 		in out nocopy per_ri_config_tech_summary.kf_grd_no_rv_tab,
				    p_kf_cmp_tab 		in out nocopy per_ri_config_tech_summary.kf_cmp_tab,
				    p_kf_grp_tab 		in out nocopy per_ri_config_tech_summary.kf_grp_tab,
				    p_kf_cost_tab 		in out nocopy per_ri_config_tech_summary.kf_cost_tab,
				    p_kf_job_str_clob 		out nocopy clob,
				    p_kf_job_rv_str_clob 	out nocopy clob,
				    p_kf_job_no_rv_str_clob 	out nocopy clob,
				    p_kf_pos_str_clob 		out nocopy clob,
				    p_kf_pos_rv_str_clob  	out nocopy clob,
				    p_kf_pos_no_rv_str_clob 	out nocopy clob,
				    p_kf_grd_str_clob  		out nocopy clob,
				    p_kf_cmp_str_clob 		out nocopy clob,
				    p_kf_grp_str_clob 		out nocopy clob,
				    p_kf_cost_str_clob 		out nocopy clob
				  )
				return clob IS
 l_proc                         varchar2(72) 	:= g_package || 'get_keyflex_structure_sql';
 i 				number(8) 	:= 0;
 l_ret_kf_str_clob		clob;
 l_temp_sql			varchar2(2000);
 l_kf_str_clob			clob;
 queryCtx			number(8)	:= 0;
 l_prejoin_sql			varchar2(2000);
 l_postjoin_sql			varchar2(2000);
 l_allow_dynamic		varchar2(8)	:= 'Y';
 l_segment_separator		varchar2(20)	:= 'Period (.)';
 l_enabled			varchar2(8)	:= 'Y';
 l_freeze_flex_def              varchar2(8)     := 'Y';


  BEGIN
      hr_utility.set_location('Entering ' || l_proc,10);

       select meaning into l_allow_dynamic from hr_lookups where lookup_type = 'YES_NO' and lookup_code = 'Y';
       l_enabled         := l_allow_dynamic;
       l_freeze_flex_def := l_enabled;

       l_kf_str_clob := get_clob_locator('JobKeyFlexStruct');
       dbms_lob.createtemporary(l_kf_str_clob,TRUE);

      l_prejoin_sql := ' select A.appl_short_name , A.flex_code ,A.structure_code,A.structure_title,A.description, A.allow_dynamic_inserts,A.segment_separator,A.enabled,A.freeze_flex_def,'||
                       ' fapp.Application_Name from( ';

      l_postjoin_sql := ' )A, fnd_application_vl fapp '||
                       ' where fapp.APPLICATION_SHORT_NAME = A.appl_short_name '||
                       ' order by Application_Name desc,structure_title desc';

       dbms_lob.writeappend(l_kf_str_clob,length(l_prejoin_sql),l_prejoin_sql);

       hr_utility.set_location('Before Main Job Keyflex Structure ' || l_proc,20);
       if p_kf_job_tab.count > 0 THEN
         for i in p_kf_job_tab.first ..
                            p_kf_job_tab.last loop

           l_temp_sql:= ' SELECT ' ||
                        '''' || p_kf_job_tab(i).appl_short_name ||''''||' appl_short_name,'  ||
                        '''' || p_kf_job_tab(i).flex_code       ||''''||' flex_code,' 	     ||
                        '''' || p_kf_job_tab(i).structure_code  ||''''||' structure_code,'   ||
                        '''' || p_kf_job_tab(i).structure_title ||''''||' structure_title,'  ||
                        '''' || p_kf_job_tab(i).description     ||''''||' description, '      ||
			'''' || l_allow_dynamic			||''''||' allow_dynamic_inserts,' ||
			'''' || l_segment_separator   		||''''||' segment_separator,'  	  ||
 			'''' || l_freeze_flex_def   		||''''||' freeze_flex_def, '  ||
			'''' || l_enabled   			||''''||' enabled '  	  ||
                        ' FROM DUAL UNION';

                     dbms_lob.writeappend(l_kf_str_clob,length(l_temp_sql),l_temp_sql);
      	 end loop;
       	end if;

        hr_utility.set_location('Before RV Job Keyflex Structure ' || l_proc,30);

        if p_kf_job_rv_tab.count > 0 THEN
		 for i in p_kf_job_rv_tab.first ..
				    p_kf_job_rv_tab.last loop

		   l_temp_sql:= ' SELECT ' ||
				'''' || p_kf_job_rv_tab(i).appl_short_name ||''''||' appl_short_name,'  ||
				'''' || p_kf_job_rv_tab(i).flex_code       ||''''||' flex_code,' 	||
				'''' || p_kf_job_rv_tab(i).structure_code  ||''''||' structure_code,'   ||
				'''' || p_kf_job_rv_tab(i).structure_title ||''''||' structure_title,'  ||
				'''' || p_kf_job_rv_tab(i).description     ||''''||' description, '      ||
				'''' || l_allow_dynamic			||''''||' allow_dynamic_inserts,' ||
				'''' || l_segment_separator   		||''''||' segment_separator,'  	  ||
 				'''' || l_freeze_flex_def   		||''''||' freeze_flex_def, '  ||
				'''' || l_enabled   			||''''||' enabled '  	  ||
				' FROM DUAL UNION';

			     dbms_lob.writeappend(l_kf_str_clob,length(l_temp_sql),l_temp_sql);
		 end loop;
       	end if;

       hr_utility.set_location('Before No RV Job Keyflex Structure ' || l_proc,40);

       if p_kf_job_no_rv_tab.count > 0 THEN
	 for i in p_kf_job_no_rv_tab.first ..
			    p_kf_job_no_rv_tab.last loop

	   l_temp_sql:= ' SELECT ' ||
			'''' || p_kf_job_no_rv_tab(i).appl_short_name ||''''||' appl_short_name,'  ||
			'''' || p_kf_job_no_rv_tab(i).flex_code       ||''''||' flex_code,' 	   ||
			'''' || p_kf_job_no_rv_tab(i).structure_code  ||''''||' structure_code,'   ||
			'''' || p_kf_job_no_rv_tab(i).structure_title ||''''||' structure_title,'  ||
			'''' || p_kf_job_no_rv_tab(i).description     ||''''||' description, '     ||
			'''' || l_allow_dynamic			||''''||' allow_dynamic_inserts,' ||
			'''' || l_segment_separator   		||''''||' segment_separator,'  	  ||
 			'''' || l_freeze_flex_def   		||''''||' freeze_flex_def, '  ||
			'''' || l_enabled   			||''''||' enabled '  	  ||
			' FROM DUAL UNION';

		     dbms_lob.writeappend(l_kf_str_clob,length(l_temp_sql),l_temp_sql);
	 end loop;
       	end if;

        dbms_lob.trim(l_kf_str_clob,length(l_kf_str_clob)-5);
	dbms_lob.writeappend(l_kf_str_clob,length(l_postjoin_sql),l_postjoin_sql);

	if p_kf_job_tab.count > 0 or  p_kf_job_rv_tab.count > 0 or  p_kf_job_no_rv_tab.count > 0  THEN
	p_kf_job_str_clob := fetch_clob(l_kf_str_clob,'JobKeyFlexStruct','JobKeyFlexStructures');
	end if;

	l_kf_str_clob := null;
	l_kf_str_clob := get_clob_locator('PosKeyFlexStruct');
	dbms_lob.createtemporary(l_kf_str_clob,TRUE);
	dbms_lob.writeappend(l_kf_str_clob,length(l_prejoin_sql),l_prejoin_sql);

       hr_utility.set_location('Before Main Pos Keyflex Structure ' || l_proc,50);

        if p_kf_pos_tab.count > 0 THEN
		 for i in p_kf_pos_tab.first ..
				    p_kf_pos_tab.last loop

 	   l_temp_sql:= ' SELECT ' ||
			'''' || p_kf_pos_tab(i).appl_short_name ||''''||' appl_short_name,'  ||
			'''' || p_kf_pos_tab(i).flex_code       ||''''||' flex_code,' 	     ||
			'''' || p_kf_pos_tab(i).structure_code  ||''''||' structure_code,'   ||
			'''' || p_kf_pos_tab(i).structure_title ||''''||' structure_title,'  ||
			'''' || p_kf_pos_tab(i).description     ||''''||' description, '     ||
			'''' || l_allow_dynamic			||''''||' allow_dynamic_inserts,' ||
			'''' || l_segment_separator   		||''''||' segment_separator,'  	  ||
			'''' || l_enabled   			||''''||' enabled, '  	  ||
 			'''' || l_freeze_flex_def   		||''''||' freeze_flex_def '  ||
			' FROM DUAL UNION';


		     dbms_lob.writeappend(l_kf_str_clob,length(l_temp_sql),l_temp_sql);
		 end loop;
       	end if;

        hr_utility.set_location('Before RV Pos Keyflex Structure ' || l_proc,60);
        if p_kf_pos_rv_tab.count > 0 THEN
	       	 for i in p_kf_pos_rv_tab.first ..
	       			    p_kf_pos_rv_tab.last loop

	       	   l_temp_sql:= ' SELECT ' ||
	       			'''' || p_kf_pos_rv_tab(i).appl_short_name ||''''||' appl_short_name,'  ||
	       			'''' || p_kf_pos_rv_tab(i).flex_code       ||''''||' flex_code,' 	||
	       			'''' || p_kf_pos_rv_tab(i).structure_code  ||''''||' structure_code,'   ||
	       			'''' || p_kf_pos_rv_tab(i).structure_title ||''''||' structure_title,'  ||
	       			'''' || p_kf_pos_rv_tab(i).description     ||''''||' description, '     ||
				'''' || l_allow_dynamic			||''''||' allow_dynamic_inserts,' ||
				'''' || l_segment_separator   		||''''||' segment_separator,'  	  ||
				'''' || l_enabled   			||''''||' enabled, '  	  ||
 				'''' || l_freeze_flex_def   		||''''||' freeze_flex_def '  ||
	       			' FROM DUAL UNION';


	       		     dbms_lob.writeappend(l_kf_str_clob,length(l_temp_sql),l_temp_sql);
	       	 end loop;
       	end if;

        hr_utility.set_location('Before NO RV Pos Keyflex Structure ' || l_proc,70);

       	if p_kf_pos_no_rv_tab.count > 0 THEN
	       	 for i in p_kf_pos_no_rv_tab.first ..
	       			    p_kf_pos_no_rv_tab.last loop

	       	   l_temp_sql:= ' SELECT ' ||
	       			'''' || p_kf_pos_no_rv_tab(i).appl_short_name ||''''||' appl_short_name,'  ||
	       			'''' || p_kf_pos_no_rv_tab(i).flex_code       ||''''||' flex_code,' 	   ||
	       			'''' || p_kf_pos_no_rv_tab(i).structure_code  ||''''||' structure_code,'   ||
	       			'''' || p_kf_pos_no_rv_tab(i).structure_title ||''''||' structure_title,'  ||
	       			'''' || p_kf_pos_no_rv_tab(i).description     ||''''||' description, '     ||
				'''' || l_allow_dynamic				||''''||' allow_dynamic_inserts,' ||
				'''' || l_segment_separator   			||''''||' segment_separator,'  	  ||
				'''' || l_enabled   			||''''||' enabled, '  	  ||
 				'''' || l_freeze_flex_def   		    ||''''||' freeze_flex_def '  ||
	       			' FROM DUAL UNION';


	       		     dbms_lob.writeappend(l_kf_str_clob,length(l_temp_sql),l_temp_sql);
	       	 end loop;
       	end if;

        dbms_lob.trim(l_kf_str_clob,length(l_kf_str_clob)-5);
	dbms_lob.writeappend(l_kf_str_clob,length(l_postjoin_sql),l_postjoin_sql);

	if  p_kf_pos_tab.count > 0 or p_kf_pos_rv_tab.count > 0 or  p_kf_pos_no_rv_tab.count > 0 then
	p_kf_pos_str_clob := fetch_clob(l_kf_str_clob,'PosKeyFlexStruct','PosKeyFlexStructures');
	end if;

	l_kf_str_clob := null;
	l_kf_str_clob := get_clob_locator('GrdKeyFlexStruct');
	dbms_lob.createtemporary(l_kf_str_clob,TRUE);
	dbms_lob.writeappend(l_kf_str_clob,length(l_prejoin_sql),l_prejoin_sql);

        hr_utility.set_location('Before Main Grd Keyflex Structure ' || l_proc,80);

        if p_kf_grd_tab.count > 0 THEN
		 for i in p_kf_grd_tab.first ..
				    p_kf_grd_tab.last loop

		   l_temp_sql:= ' SELECT ' ||
				'''' || p_kf_grd_tab(i).appl_short_name ||''''||' appl_short_name,'  ||
				'''' || p_kf_grd_tab(i).flex_code       ||''''||' flex_code,' 	   ||
				'''' || p_kf_grd_tab(i).structure_code  ||''''||' structure_code,'   ||
				'''' || p_kf_grd_tab(i).structure_title ||''''||' structure_title,'  ||
				'''' || p_kf_grd_tab(i).description     ||''''||' description,'      ||
				'''' || l_allow_dynamic			||''''||' allow_dynamic_inserts,' ||
				'''' || l_segment_separator   		||''''||' segment_separator,'  	  ||
				'''' || l_enabled   			||''''||' enabled, '  	  ||
	 			'''' || l_freeze_flex_def   		    ||''''||' freeze_flex_def '  ||
				' FROM DUAL UNION';


		     dbms_lob.writeappend(l_kf_str_clob,length(l_temp_sql),l_temp_sql);
		 end loop;
       	end if;

       hr_utility.set_location('Before RV Grd Keyflex Structure ' || l_proc,90);

	if p_kf_grd_rv_tab.count > 0 THEN
		 for i in p_kf_grd_rv_tab.first ..
				    p_kf_grd_rv_tab.last loop

		   l_temp_sql:= ' SELECT ' ||
				'''' || p_kf_grd_rv_tab(i).appl_short_name ||''''||' appl_short_name,'  ||
				'''' || p_kf_grd_rv_tab(i).flex_code       ||''''||' flex_code,' 	||
				'''' || p_kf_grd_rv_tab(i).structure_code  ||''''||' structure_code,'   ||
				'''' || p_kf_grd_rv_tab(i).structure_title ||''''||' structure_title,'  ||
				'''' || p_kf_grd_rv_tab(i).description     ||''''||' description,'      ||
				'''' || l_allow_dynamic			   ||''''||' allow_dynamic_inserts,' ||
				'''' || l_segment_separator   		   ||''''||' segment_separator,'  	  ||
				'''' || l_enabled   			   ||''''||' enabled, '  	  ||
	 			'''' || l_freeze_flex_def   		   ||''''||' freeze_flex_def '  ||
				' FROM DUAL UNION';


			     dbms_lob.writeappend(l_kf_str_clob,length(l_temp_sql),l_temp_sql);
		 end loop;
       	end if;

       hr_utility.set_location('Before NO RV Grd Keyflex Structure ' || l_proc,100);

       if p_kf_grd_no_rv_tab.count > 0 THEN
	 for i in p_kf_grd_no_rv_tab.first ..
			    p_kf_grd_no_rv_tab.last loop

	   l_temp_sql:= ' SELECT ' ||
			'''' || p_kf_grd_no_rv_tab(i).appl_short_name ||''''||' appl_short_name,'  ||
			'''' || p_kf_grd_no_rv_tab(i).flex_code       ||''''||' flex_code,' 	   ||
			'''' || p_kf_grd_no_rv_tab(i).structure_code  ||''''||' structure_code,'   ||
			'''' || p_kf_grd_no_rv_tab(i).structure_title ||''''||' structure_title,'  ||
			'''' || p_kf_grd_no_rv_tab(i).description     ||''''||' description,'      ||
			'''' || l_allow_dynamic			      ||''''||' allow_dynamic_inserts,' ||
			'''' || l_segment_separator   		      ||''''||' segment_separator,'  	  ||
			'''' || l_enabled   			      ||''''||' enabled, '  	  ||
 			'''' || l_freeze_flex_def   		      ||''''||' freeze_flex_def '  ||
			' FROM DUAL UNION';

		     dbms_lob.writeappend(l_kf_str_clob,length(l_temp_sql),l_temp_sql);
	 end loop;
       	end if;

        dbms_lob.trim(l_kf_str_clob,length(l_kf_str_clob)-5);
	dbms_lob.writeappend(l_kf_str_clob,length(l_postjoin_sql),l_postjoin_sql);

	if p_kf_grd_tab.count > 0 or p_kf_grd_rv_tab.count > 0 or p_kf_grd_no_rv_tab.count > 0 then
	p_kf_grd_str_clob := fetch_clob(l_kf_str_clob,'GrdKeyFlexStruct','GrdKeyFlexStructures');
	end if;

	l_kf_str_clob := null;
	l_kf_str_clob := get_clob_locator('CmpKeyFlexStruct');
	dbms_lob.createtemporary(l_kf_str_clob,TRUE);
	dbms_lob.writeappend(l_kf_str_clob,length(l_prejoin_sql),l_prejoin_sql);

       hr_utility.set_location('Before Cmp Keyflex Structure ' || l_proc,110);

        if p_kf_cmp_tab.count > 0 THEN
		 for i in p_kf_cmp_tab.first ..
				    p_kf_cmp_tab.last loop

		   l_temp_sql:= ' SELECT ' ||
				'''' || p_kf_cmp_tab(i).appl_short_name ||''''||' appl_short_name,'  ||
				'''' || p_kf_cmp_tab(i).flex_code       ||''''||' flex_code,' 	   ||
				'''' || p_kf_cmp_tab(i).structure_code  ||''''||' structure_code,'   ||
				'''' || p_kf_cmp_tab(i).structure_title ||''''||' structure_title,'  ||
				'''' || p_kf_cmp_tab(i).description     ||''''||' description, '      ||
				'''' || l_allow_dynamic			||''''||' allow_dynamic_inserts,' ||
				'''' || l_segment_separator   		||''''||' segment_separator,'  	  ||
				'''' || l_enabled   			||''''||' enabled, '  	  ||
 				'''' || l_freeze_flex_def   		||''''||' freeze_flex_def '  ||
				' FROM DUAL UNION';


		     dbms_lob.writeappend(l_kf_str_clob,length(l_temp_sql),l_temp_sql);
		 end loop;
       	end if;

        dbms_lob.trim(l_kf_str_clob,length(l_kf_str_clob)-5);
	dbms_lob.writeappend(l_kf_str_clob,length(l_postjoin_sql),l_postjoin_sql);

	if  p_kf_cmp_tab.count > 0 then
	p_kf_cmp_str_clob := fetch_clob(l_kf_str_clob,'CmpKeyFlexStruct','CmpKeyFlexStructures');
	end if;

	l_kf_str_clob := null;
	l_kf_str_clob := get_clob_locator('GrpKeyFlexStruct');
	dbms_lob.createtemporary(l_kf_str_clob,TRUE);
	dbms_lob.writeappend(l_kf_str_clob,length(l_prejoin_sql),l_prejoin_sql);

       hr_utility.set_location('Before Grp Keyflex Structure ' || l_proc,120);

       if p_kf_grp_tab.count > 0 THEN
			 for i in p_kf_grp_tab.first ..
					    p_kf_grp_tab.last loop

			   l_temp_sql:= ' SELECT ' ||
					'''' || p_kf_grp_tab(i).appl_short_name ||''''||' appl_short_name,'  ||
					'''' || p_kf_grp_tab(i).flex_code       ||''''||' flex_code,' 	   ||
					'''' || p_kf_grp_tab(i).structure_code  ||''''||' structure_code,'   ||
					'''' || p_kf_grp_tab(i).structure_title ||''''||' structure_title,'  ||
					'''' || p_kf_grp_tab(i).description     ||''''||' description,'      ||
					'''' || l_allow_dynamic			||''''||' allow_dynamic_inserts,' ||
					'''' || l_segment_separator   		||''''||' segment_separator,'  	  ||
					'''' || l_enabled   			||''''||' enabled, '  	  ||
 					'''' || l_freeze_flex_def   		||''''||' freeze_flex_def '  ||
					' FROM DUAL UNION';


			     dbms_lob.writeappend(l_kf_str_clob,length(l_temp_sql),l_temp_sql);
			 end loop;
       	end if;

        dbms_lob.trim(l_kf_str_clob,length(l_kf_str_clob)-5);
	dbms_lob.writeappend(l_kf_str_clob,length(l_postjoin_sql),l_postjoin_sql);

	if  p_kf_grp_tab.count > 0 then
	p_kf_grp_str_clob := fetch_clob(l_kf_str_clob,'GrpKeyFlexStruct','GrpKeyFlexStructures');
	end if;

	l_kf_str_clob := null;
	l_kf_str_clob := get_clob_locator('CostKeyFlexStruct');
	dbms_lob.createtemporary(l_kf_str_clob,TRUE);
	dbms_lob.writeappend(l_kf_str_clob,length(l_prejoin_sql),l_prejoin_sql);

        hr_utility.set_location('Before Cost Keyflex Structure ' || l_proc,130);

        if p_kf_cost_tab.count > 0 THEN
			 for i in p_kf_cost_tab.first ..
					    p_kf_cost_tab.last loop

			   l_temp_sql:= ' SELECT ' ||
					'''' || p_kf_cost_tab(i).appl_short_name ||''''||' appl_short_name,'  ||
					'''' || p_kf_cost_tab(i).flex_code       ||''''||' flex_code,' 	   ||
					'''' || p_kf_cost_tab(i).structure_code  ||''''||' structure_code,'   ||
					'''' || p_kf_cost_tab(i).structure_title ||''''||' structure_title,'  ||
					'''' || p_kf_cost_tab(i).description     ||''''||' description,'      ||
					'''' || l_allow_dynamic			||''''||' allow_dynamic_inserts,' ||
					'''' || l_segment_separator   		||''''||' segment_separator,'  	  ||
					'''' || l_enabled   			||''''||' enabled, '  	  ||
 					'''' || l_freeze_flex_def   		||''''||' freeze_flex_def '  ||
					' FROM DUAL UNION';


			     dbms_lob.writeappend(l_kf_str_clob,length(l_temp_sql),l_temp_sql);
			 end loop;
       	end if;

        dbms_lob.trim(l_kf_str_clob,length(l_kf_str_clob)-5);
	dbms_lob.writeappend(l_kf_str_clob,length(l_postjoin_sql),l_postjoin_sql);

	if p_kf_cost_tab.count > 0 then
		p_kf_cost_str_clob := fetch_clob(l_kf_str_clob,'CostKeyFlexStruct','CostKeyFlexStructures');
	end if;

   	hr_utility.set_location('Leaving ' ||l_proc,140);
   	return l_ret_kf_str_clob;

END get_keyflex_structure_sql;


FUNCTION   get_keyflex_segment_sql
                                 (
                                    p_kf_job_seg_tab 		in out nocopy per_ri_config_tech_summary.kf_job_seg_tab,
                                    p_kf_job_rv_seg_tab 	in out nocopy per_ri_config_tech_summary.kf_job_rv_seg_tab,
                                    p_kf_job_no_rv_seg_tab 	in out nocopy per_ri_config_tech_summary.kf_job_no_rv_seg_tab,
                                    p_kf_pos_seg_tab 		in out nocopy per_ri_config_tech_summary.kf_pos_seg_tab,
                                    p_kf_pos_rv_seg_tab 	in out nocopy per_ri_config_tech_summary.kf_pos_rv_seg_tab,
                                    p_kf_pos_no_rv_seg_tab 	in out nocopy per_ri_config_tech_summary.kf_pos_no_rv_seg_tab,
                                    p_kf_grd_seg_tab 		in out nocopy per_ri_config_tech_summary.kf_grd_seg_tab,
                                    p_kf_grd_rv_seg_tab 	in out nocopy per_ri_config_tech_summary.kf_grd_rv_seg_tab,
                                    p_kf_grd_no_rv_seg_tab 	in out nocopy per_ri_config_tech_summary.kf_grd_no_rv_seg_tab,
                                    p_kf_grp_seg_tab 		in out nocopy per_ri_config_tech_summary.kf_grp_seg_tab,
                                    p_kf_cmp_seg_tab 		in out nocopy per_ri_config_tech_summary.kf_cmp_seg_tab,
                                    p_kf_cost_seg_tab 		in out nocopy per_ri_config_tech_summary.kf_cost_seg_tab,
                                    p_kf_job_seg_clob 		out nocopy clob,
                                    p_kf_job_rv_seg_clob 	out nocopy clob,
                                    p_kf_job_no_rv_seg_clob 	out nocopy clob,
                                    p_kf_pos_seg_clob 		out nocopy clob,
                                    p_kf_pos_rv_seg_clob 	out nocopy clob,
                                    p_kf_pos_no_rv_seg_clob 	out nocopy clob,
                                    p_kf_grd_seg_clob 		out nocopy clob,
                                    p_kf_grd_rv_seg_clob 	out nocopy clob,
                                    p_kf_grd_no_rv_seg_clob 	out nocopy clob,
                                    p_kf_grp_seg_clob 		out nocopy clob,
                                    p_kf_cmp_seg_clob 		out nocopy clob,
                                    p_kf_cost_seg_clob 		out nocopy clob
                                  )
				return clob IS

 l_proc                         varchar2(72) 	:= g_package || 'get_keyflex_segment_sql';
 i 				number(8) 	:= 0;
 l_ret_kf_seg_clob		clob;
 l_temp_sql			varchar2(2000);
 l_kf_seg_clob			clob;
 queryCtx			number(8)	:= 0;

 l_required			varchar2(8);
 l_display			varchar2(8);
 l_enabled			varchar2(8);

 l_orderby			varchar2(200);
 l_vs_security_available        varchar2(80);
 l_vs_enable_longlist           varchar2(80);
 l_vs_format_type               varchar2(80);
 l_vs_validation_type           varchar2(80);


  BEGIN
       hr_utility.set_location('Entering ' ||l_proc,20);

       select meaning into l_required from hr_lookups where lookup_type = 'YES_NO' and lookup_code = 'Y';
       l_display := l_required;
       l_enabled := l_required;
       select meaning into l_vs_validation_type from fnd_lookups where  lookup_type = 'SEG_VAL_TYPES' and lookup_code = 'I';


       l_kf_seg_clob := get_clob_locator('JobKeyFlexSegment');
       dbms_lob.createtemporary(l_kf_seg_clob,TRUE);

       l_orderby := ' order by segment_number ';

       hr_utility.set_location('Before Job Keyflex Segment ' ||l_proc,20);

       if p_kf_job_seg_tab.count > 0 THEN
         for i in p_kf_job_seg_tab.first ..
                            p_kf_job_seg_tab.last loop
	   if  p_kf_job_seg_tab(i).vs_security_available is not null then
		   select meaning into l_vs_security_available from hr_lookups where lookup_type  = 'YES_NO' and lookup_code = p_kf_job_seg_tab(i).vs_security_available;
	   end if;
	   if  p_kf_job_seg_tab(i).vs_enable_longlist is not null then
		   select meaning into l_vs_enable_longlist from fnd_lookups where lookup_type  = 'FLEX_VALUESET_LONGLIST_FLAG' and lookup_code = p_kf_job_seg_tab(i).vs_enable_longlist;
	   end if;
	   if  p_kf_job_seg_tab(i).vs_format_type is not null then
		   select meaning into l_vs_format_type from fnd_lookups where lookup_type  = 'FIELD_TYPE' and lookup_code = p_kf_job_seg_tab(i).vs_format_type;
	   end if;

	   l_temp_sql:= ' SELECT ' ||
			'''' || p_kf_job_seg_tab(i).appl_short_name ||''''||' appl_short_name,'   ||
			'''' || p_kf_job_seg_tab(i).flex_code       ||''''||' flex_code,'         ||
			'''' || p_kf_job_seg_tab(i).structure_code  ||''''||' structure_code,'    ||
			'''' || p_kf_job_seg_tab(i).segment_name    ||''''||' segment_name,'	  ||
			'''' || p_kf_job_seg_tab(i).column_name     ||''''||' column_name,'       ||
			'''' || p_kf_job_seg_tab(i).segment_number  ||''''||' segment_number,' 	  ||
			'''' || p_kf_job_seg_tab(i).value_set       ||''''||' value_set,'      	  ||
			'''' || p_kf_job_seg_tab(i).lov_prompt      ||''''||' lov_prompt,'     	  ||
			'''' || p_kf_job_seg_tab(i).segment_type    ||''''||' segment_type,'   	  ||
			'''' || p_kf_job_seg_tab(i).window_prompt   ||''''||' window_prompt,' 	  ||
			'''' || l_required			    ||''''||' required,'  	  ||
			'''' || l_display   			    ||''''||' display,'  	  ||
			'''' || l_enabled   			    ||''''||' enabled, '  	  ||
 			'''' || l_vs_validation_type   		    ||''''||' vs_validation_type, '  ||
                        '''' || p_kf_job_seg_tab(i).vs_description             ||''''||' vs_description,'              ||
                        '''' || l_vs_security_available                        ||''''||' vs_security_available,'       ||
                        '''' || l_vs_enable_longlist                           ||''''||' vs_list_type,'        || --List type
                        '''' || l_vs_format_type                               ||''''||' vs_format_type,'              || --validation type
                        '''' || p_kf_job_seg_tab(i).vs_maximum_size            ||''''||' vs_maximum_size,'             ||
                        '''' || p_kf_job_seg_tab(i).vs_precision               ||''''||' vs_precision,'                ||
                        '''' || p_kf_job_seg_tab(i).vs_numbers_only            ||''''||' vs_numbers_only,'             ||
                        '''' || p_kf_job_seg_tab(i).vs_uppercase_only          ||''''||' vs_uppercase_only,'           ||
                        '''' || p_kf_job_seg_tab(i).vs_right_justify_zero_fill ||''''||' vs_right_justify_zero_fill,'  ||
                        '''' || p_kf_job_seg_tab(i).vs_min_value               ||''''||' vs_min_value,'                ||
                        '''' || p_kf_job_seg_tab(i).vs_max_value               ||''''||' vs_max_value,'                ||
		        '''' || p_kf_job_seg_tab(i).vs_value_set_name             ||''''||' value_set_name'                ||
			' FROM DUAL UNION';

                     dbms_lob.writeappend(l_kf_seg_clob,length(l_temp_sql),l_temp_sql);
      	 end loop;
       	end if;


       if p_kf_job_rv_seg_tab.count > 0 THEN
                for i in p_kf_job_rv_seg_tab.first ..
                                   p_kf_job_rv_seg_tab.last loop

	   if  p_kf_job_rv_seg_tab(i).vs_security_available is not null then
		   select meaning into l_vs_security_available from hr_lookups where lookup_type  = 'YES_NO' and lookup_code = p_kf_job_rv_seg_tab(i).vs_security_available;
	   end if;
	   if  p_kf_job_rv_seg_tab(i).vs_enable_longlist is not null then
		   select meaning into l_vs_enable_longlist from fnd_lookups where lookup_type  = 'FLEX_VALUESET_LONGLIST_FLAG' and lookup_code = p_kf_job_rv_seg_tab(i).vs_enable_longlist;
	   end if;
	   if  p_kf_job_rv_seg_tab(i).vs_format_type is not null then
		   select meaning into l_vs_format_type from fnd_lookups where lookup_type  = 'FIELD_TYPE' and lookup_code = p_kf_job_rv_seg_tab(i).vs_format_type;
	   end if;

                  l_temp_sql:= ' SELECT ' ||
                               '''' || p_kf_job_rv_seg_tab(i).appl_short_name ||''''||' appl_short_name,'   ||
                               '''' || p_kf_job_rv_seg_tab(i).flex_code       ||''''||' flex_code,'         ||
                               '''' || p_kf_job_rv_seg_tab(i).structure_code  ||''''||' structure_code,'    ||
                               '''' || p_kf_job_rv_seg_tab(i).segment_name    ||''''||' segment_name,'	    ||
                               '''' || p_kf_job_rv_seg_tab(i).column_name     ||''''||' column_name,'       ||
                               '''' || p_kf_job_rv_seg_tab(i).segment_number  ||''''||' segment_number,'    ||
                               '''' || p_kf_job_rv_seg_tab(i).value_set       ||''''||' value_set,'         ||
                               '''' || p_kf_job_rv_seg_tab(i).lov_prompt      ||''''||' lov_prompt,'        ||
                               '''' || p_kf_job_rv_seg_tab(i).segment_type    ||''''||' segment_type,'      ||
                               '''' || p_kf_job_rv_seg_tab(i).window_prompt   ||''''||' window_prompt,'     ||
                               '''' || l_required			      ||''''||' required,'  	    ||
			       '''' || l_display   			      ||''''||' display,'  	    ||
			       '''' || l_enabled   			      ||''''||' enabled, '  	    ||
	 			'''' || l_vs_validation_type   		    ||''''||' vs_validation_type, '  ||
			       '''' || p_kf_job_rv_seg_tab(i).vs_description             ||''''||' vs_description,'              ||
			       '''' || l_vs_security_available                        ||''''||' vs_security_available,'       ||
                               '''' || l_vs_enable_longlist                           ||''''||' vs_list_type,'        || --List type
                               '''' || l_vs_format_type                               ||''''||' vs_format_type,'              || --validation type
                               '''' || p_kf_job_rv_seg_tab(i).vs_maximum_size            ||''''||' vs_maximum_size,'             ||
                               '''' || p_kf_job_rv_seg_tab(i).vs_precision               ||''''||' vs_precision,'                ||
                               '''' || p_kf_job_rv_seg_tab(i).vs_numbers_only            ||''''||' vs_numbers_only,'             ||
                               '''' || p_kf_job_rv_seg_tab(i).vs_uppercase_only          ||''''||' vs_uppercase_only,'           ||
                               '''' || p_kf_job_rv_seg_tab(i).vs_right_justify_zero_fill ||''''||' vs_right_justify_zero_fill,'  ||
                               '''' || p_kf_job_rv_seg_tab(i).vs_min_value               ||''''||' vs_min_value,'                ||
                               '''' || p_kf_job_rv_seg_tab(i).vs_max_value               ||''''||' vs_max_value,'                ||
			       '''' || p_kf_job_rv_seg_tab(i).vs_value_set_name             ||''''||' value_set_name'               ||
                               ' FROM DUAL UNION';

                            dbms_lob.writeappend(l_kf_seg_clob,length(l_temp_sql),l_temp_sql);
             	 end loop;
       	end if;

       	if p_kf_job_no_rv_seg_tab.count > 0 THEN
		for i in p_kf_job_no_rv_seg_tab.first ..
				   p_kf_job_no_rv_seg_tab.last loop

	   if  p_kf_job_no_rv_seg_tab(i).vs_security_available is not null then
		   select meaning into l_vs_security_available from hr_lookups where lookup_type  = 'YES_NO' and lookup_code = p_kf_job_no_rv_seg_tab(i).vs_security_available;
	   end if;
	   if  p_kf_job_no_rv_seg_tab(i).vs_enable_longlist is not null then
		   select meaning into l_vs_enable_longlist from fnd_lookups where lookup_type  = 'FLEX_VALUESET_LONGLIST_FLAG' and lookup_code = p_kf_job_no_rv_seg_tab(i).vs_enable_longlist;
	   end if;
	   if  p_kf_job_no_rv_seg_tab(i).vs_format_type is not null then
		   select meaning into l_vs_format_type from fnd_lookups where lookup_type  = 'FIELD_TYPE' and lookup_code = p_kf_job_no_rv_seg_tab(i).vs_format_type;
	   end if;

		  l_temp_sql:= ' SELECT ' ||
			       '''' || p_kf_job_no_rv_seg_tab(i).appl_short_name ||''''||' appl_short_name,'   ||
			       '''' || p_kf_job_no_rv_seg_tab(i).flex_code       ||''''||' flex_code,'         ||
			       '''' || p_kf_job_no_rv_seg_tab(i).structure_code  ||''''||' structure_code,'    ||
			       '''' || p_kf_job_no_rv_seg_tab(i).segment_name    ||''''||' segment_name,'      ||
			       '''' || p_kf_job_no_rv_seg_tab(i).column_name     ||''''||' column_name,'       ||
			       '''' || p_kf_job_no_rv_seg_tab(i).segment_number  ||''''||' segment_number,'    ||
			       '''' || p_kf_job_no_rv_seg_tab(i).value_set       ||''''||' value_set,'         ||
			       '''' || p_kf_job_no_rv_seg_tab(i).lov_prompt      ||''''||' lov_prompt,'        ||
			       '''' || p_kf_job_no_rv_seg_tab(i).segment_type    ||''''||' segment_type,'      ||
			       '''' || p_kf_job_no_rv_seg_tab(i).window_prompt   ||''''||' window_prompt,'     ||
			       '''' || l_required			   	 ||''''||' required,'  	       ||
			       '''' || l_display   			    	 ||''''||' display,'  	       ||
			       '''' || l_enabled   			    	 ||''''||' enabled,'  	       ||
	 			'''' || l_vs_validation_type   		    ||''''||' vs_validation_type, '  ||
			       '''' || p_kf_job_no_rv_seg_tab(i).vs_description             ||''''||' vs_description,'              ||
			       '''' || l_vs_security_available				    ||''''||' vs_security_available,'       ||
			       '''' || l_vs_enable_longlist                                 ||''''||' vs_list_type,'        || --List type
			       '''' || l_vs_format_type                                     ||''''||' vs_format_type,'              || --validation type
	                       '''' || p_kf_job_no_rv_seg_tab(i).vs_maximum_size            ||''''||' vs_maximum_size,'             ||
		               '''' || p_kf_job_no_rv_seg_tab(i).vs_precision               ||''''||' vs_precision,'                ||
			       '''' || p_kf_job_no_rv_seg_tab(i).vs_numbers_only            ||''''||' vs_numbers_only,'             ||
	                       '''' || p_kf_job_no_rv_seg_tab(i).vs_uppercase_only          ||''''||' vs_uppercase_only,'           ||
		               '''' || p_kf_job_no_rv_seg_tab(i).vs_right_justify_zero_fill ||''''||' vs_right_justify_zero_fill,'  ||
			       '''' || p_kf_job_no_rv_seg_tab(i).vs_min_value               ||''''||' vs_min_value,'                ||
	                       '''' || p_kf_job_no_rv_seg_tab(i).vs_max_value               ||''''||' vs_max_value,'                ||
		               '''' || p_kf_job_no_rv_seg_tab(i).vs_value_set_name             ||''''||' value_set_name'               ||
			       ' FROM DUAL UNION';

			    dbms_lob.writeappend(l_kf_seg_clob,length(l_temp_sql),l_temp_sql);
		 end loop;
       	end if;

	if p_kf_job_seg_tab.count > 0 or p_kf_job_rv_seg_tab.count > 0 or p_kf_job_no_rv_seg_tab.count > 0 then
        dbms_lob.trim(l_kf_seg_clob,length(l_kf_seg_clob)-5);

	--Added to order the segments display in technical summary report for Job ff
        l_temp_sql := ' ORDER BY column_name ';
        dbms_lob.writeappend(l_kf_seg_clob,length(l_temp_sql),l_temp_sql);

	p_kf_job_seg_clob := fetch_clob(l_kf_seg_clob,'JobKeyFlexSegment','JobKeyFlexSegments');
	end if;

        hr_utility.set_location('Done with Job Keyflex Segment ' ||l_proc,20);
	hr_utility.set_location('Before Pos Keyflex Segment ' ||l_proc,20);

	l_kf_seg_clob := null;
	l_kf_seg_clob := get_clob_locator('PosKeyFlexSegment');
	dbms_lob.createtemporary(l_kf_seg_clob,TRUE);

      if p_kf_pos_seg_tab.count > 0 THEN
	       for i in p_kf_pos_seg_tab.first ..
				  p_kf_pos_seg_tab.last loop

	   if  p_kf_pos_seg_tab(i).vs_security_available is not null then
		   select meaning into l_vs_security_available from hr_lookups where lookup_type  = 'YES_NO' and lookup_code = p_kf_pos_seg_tab(i).vs_security_available;
	   end if;
	   if  p_kf_pos_seg_tab(i).vs_enable_longlist is not null then
		   select meaning into l_vs_enable_longlist from fnd_lookups where lookup_type  = 'FLEX_VALUESET_LONGLIST_FLAG' and lookup_code = p_kf_pos_seg_tab(i).vs_enable_longlist;
	   end if;
	   if  p_kf_pos_seg_tab(i).vs_format_type is not null then
		   select meaning into l_vs_format_type from fnd_lookups where lookup_type  = 'FIELD_TYPE' and lookup_code = p_kf_pos_seg_tab(i).vs_format_type;
	   end if;

		 l_temp_sql:= ' SELECT ' ||
			      '''' || p_kf_pos_seg_tab(i).appl_short_name ||''''||' appl_short_name,'   ||
			      '''' || p_kf_pos_seg_tab(i).flex_code       ||''''||' flex_code,'         ||
			      '''' || p_kf_pos_seg_tab(i).structure_code  ||''''||' structure_code,'    ||
			      '''' || p_kf_pos_seg_tab(i).segment_name    ||''''||' segment_name,'	||
			      '''' || p_kf_pos_seg_tab(i).column_name     ||''''||' column_name,'       ||
			      '''' || p_kf_pos_seg_tab(i).segment_number  ||''''||' segment_number,' 	||
			      '''' || p_kf_pos_seg_tab(i).value_set       ||''''||' value_set,'      	||
			      '''' || p_kf_pos_seg_tab(i).lov_prompt      ||''''||' lov_prompt,'     	||
			      '''' || p_kf_pos_seg_tab(i).segment_type    ||''''||' segment_type,'   	||
			      '''' || p_kf_pos_seg_tab(i).window_prompt   ||''''||' window_prompt,'  	||
			      '''' || l_required			  ||''''||' required,'  	||
			      '''' || l_display   			  ||''''||' display,'  	  	||
			      '''' || l_enabled   			  ||''''||' enabled, '  	  	||
	 			'''' || l_vs_validation_type   		    ||''''||' vs_validation_type, '  ||
			      '''' || p_kf_pos_seg_tab(i).vs_description             ||''''||' vs_description,'              ||
			      '''' || l_vs_security_available			      ||''''||' vs_security_available,'       ||
	                      '''' || l_vs_enable_longlist                           ||''''||' vs_list_type,'        || --List type
		              '''' || l_vs_format_type                               ||''''||' vs_format_type,'              || --validation type
			      '''' || p_kf_pos_seg_tab(i).vs_maximum_size            ||''''||' vs_maximum_size,'             ||
	                      '''' || p_kf_pos_seg_tab(i).vs_precision               ||''''||' vs_precision,'                ||
		              '''' || p_kf_pos_seg_tab(i).vs_numbers_only            ||''''||' vs_numbers_only,'             ||
			      '''' || p_kf_pos_seg_tab(i).vs_uppercase_only          ||''''||' vs_uppercase_only,'           ||
	                      '''' || p_kf_pos_seg_tab(i).vs_right_justify_zero_fill ||''''||' vs_right_justify_zero_fill,'  ||
		              '''' || p_kf_pos_seg_tab(i).vs_min_value               ||''''||' vs_min_value,'                ||
			      '''' || p_kf_pos_seg_tab(i).vs_max_value               ||''''||' vs_max_value,'                ||
			      '''' || p_kf_pos_seg_tab(i).vs_value_set_name          ||''''||' value_set_name'               ||
			      ' FROM DUAL UNION';

			   dbms_lob.writeappend(l_kf_seg_clob,length(l_temp_sql),l_temp_sql);
		 end loop;
	end if;

        if p_kf_pos_rv_seg_tab.count > 0 THEN
	         for i in p_kf_pos_rv_seg_tab.first ..
	                            p_kf_pos_rv_seg_tab.last loop

	   if  p_kf_pos_rv_seg_tab(i).vs_security_available is not null then
		   select meaning into l_vs_security_available from hr_lookups where lookup_type  = 'YES_NO' and lookup_code = p_kf_pos_rv_seg_tab(i).vs_security_available;
	   end if;
	   if  p_kf_pos_rv_seg_tab(i).vs_enable_longlist is not null then
		   select meaning into l_vs_enable_longlist from fnd_lookups where lookup_type  = 'FLEX_VALUESET_LONGLIST_FLAG' and lookup_code = p_kf_pos_rv_seg_tab(i).vs_enable_longlist;
	   end if;
	   if  p_kf_pos_rv_seg_tab(i).vs_format_type is not null then
		   select meaning into l_vs_format_type from fnd_lookups where lookup_type  = 'FIELD_TYPE' and lookup_code = p_kf_pos_rv_seg_tab(i).vs_format_type;
	   end if;

		   l_temp_sql:= ' SELECT ' ||
	                        '''' || p_kf_pos_rv_seg_tab(i).appl_short_name ||''''||' appl_short_name,'   ||
	                        '''' || p_kf_pos_rv_seg_tab(i).flex_code       ||''''||' flex_code,'         ||
	                        '''' || p_kf_pos_rv_seg_tab(i).structure_code  ||''''||' structure_code,'    ||
	                        '''' || p_kf_pos_rv_seg_tab(i).segment_name    ||''''||' segment_name,'	     ||
	                        '''' || p_kf_pos_rv_seg_tab(i).column_name     ||''''||' column_name,'       ||
	                        '''' || p_kf_pos_rv_seg_tab(i).segment_number  ||''''||' segment_number,'    ||
	                        '''' || p_kf_pos_rv_seg_tab(i).value_set       ||''''||' value_set,'         ||
	                        '''' || p_kf_pos_rv_seg_tab(i).lov_prompt      ||''''||' lov_prompt,'        ||
	                        '''' || p_kf_pos_rv_seg_tab(i).segment_type    ||''''||' segment_type,'      ||
	                        '''' || p_kf_pos_rv_seg_tab(i).window_prompt   ||''''||' window_prompt,'     ||
	                        '''' || l_required			       ||''''||' required,'  	     ||
				'''' || l_display   			       ||''''||' display,'  	     ||
				'''' || l_enabled   			       ||''''||' enabled, '  	     ||
	 			'''' || l_vs_validation_type   		    ||''''||' vs_validation_type, '  ||
				'''' || p_kf_pos_rv_seg_tab(i).vs_description             ||''''||' vs_description, '              ||
			        '''' || l_vs_security_available			         ||''''||' vs_security_available,'       ||
			        '''' || l_vs_enable_longlist                              ||''''||' vs_list_type,'        || --List type
	                        '''' || l_vs_format_type                                  ||''''||' vs_format_type,'              || --validation type
		                '''' || p_kf_pos_rv_seg_tab(i).vs_maximum_size            ||''''||' vs_maximum_size,'             ||
		                '''' || p_kf_pos_rv_seg_tab(i).vs_precision               ||''''||' vs_precision,'                ||
		                '''' || p_kf_pos_rv_seg_tab(i).vs_numbers_only            ||''''||' vs_numbers_only,'             ||
			        '''' || p_kf_pos_rv_seg_tab(i).vs_uppercase_only          ||''''||' vs_uppercase_only,'           ||
	                        '''' || p_kf_pos_rv_seg_tab(i).vs_right_justify_zero_fill ||''''||' vs_right_justify_zero_fill,'  ||
		                '''' || p_kf_pos_rv_seg_tab(i).vs_min_value               ||''''||' vs_min_value,'                ||
			        '''' || p_kf_pos_rv_seg_tab(i).vs_max_value               ||''''||' vs_max_value,'                ||
		                '''' || p_kf_pos_rv_seg_tab(i).vs_value_set_name             ||''''||' value_set_name'               ||
	                        ' FROM DUAL UNION';

	                     dbms_lob.writeappend(l_kf_seg_clob,length(l_temp_sql),l_temp_sql);
	      	 end loop;
       	end if;

        if p_kf_pos_no_rv_seg_tab.count > 0 THEN
	         for i in p_kf_pos_no_rv_seg_tab.first ..
	                            p_kf_pos_no_rv_seg_tab.last loop

	   if  p_kf_pos_no_rv_seg_tab(i).vs_security_available is not null then
		   select meaning into l_vs_security_available from hr_lookups where lookup_type  = 'YES_NO' and lookup_code = p_kf_pos_no_rv_seg_tab(i).vs_security_available;
	   end if;
	   if  p_kf_pos_no_rv_seg_tab(i).vs_enable_longlist is not null then
		   select meaning into l_vs_enable_longlist from fnd_lookups where lookup_type  = 'FLEX_VALUESET_LONGLIST_FLAG' and lookup_code = p_kf_pos_no_rv_seg_tab(i).vs_enable_longlist;
	   end if;
	   if  p_kf_pos_no_rv_seg_tab(i).vs_format_type is not null then
		   select meaning into l_vs_format_type from fnd_lookups where lookup_type  = 'FIELD_TYPE' and lookup_code = p_kf_pos_no_rv_seg_tab(i).vs_format_type;
	   end if;

		   l_temp_sql:= ' SELECT ' ||
	                        '''' || p_kf_pos_no_rv_seg_tab(i).appl_short_name ||''''||' appl_short_name,'   ||
	                        '''' || p_kf_pos_no_rv_seg_tab(i).flex_code       ||''''||' flex_code,'         ||
	                        '''' || p_kf_pos_no_rv_seg_tab(i).structure_code  ||''''||' structure_code,'    ||
	                        '''' || p_kf_pos_no_rv_seg_tab(i).segment_name    ||''''||' segment_name,'	||
	                        '''' || p_kf_pos_no_rv_seg_tab(i).column_name     ||''''||' column_name,'       ||
	                        '''' || p_kf_pos_no_rv_seg_tab(i).segment_number  ||''''||' segment_number,' 	||
	                        '''' || p_kf_pos_no_rv_seg_tab(i).value_set       ||''''||' value_set,'      	||
	                        '''' || p_kf_pos_no_rv_seg_tab(i).lov_prompt      ||''''||' lov_prompt,'     	||
	                        '''' || p_kf_pos_no_rv_seg_tab(i).segment_type    ||''''||' segment_type,'   	||
	                        '''' || p_kf_pos_no_rv_seg_tab(i).window_prompt   ||''''||' window_prompt,'  	||
	                        '''' || l_required			    	  ||''''||' required,'  	||
				'''' || l_display   			          ||''''||' display,'  	  	||
				'''' || l_enabled   			          ||''''||' enabled, '  	  	||
	 			'''' || l_vs_validation_type   		    ||''''||' vs_validation_type, '  ||
				'''' || p_kf_pos_no_rv_seg_tab(i).vs_description             ||''''||' vs_description, '              ||
			        '''' || l_vs_security_available			            ||''''||' vs_security_available,'       ||
			        '''' || l_vs_enable_longlist                                 ||''''||' vs_list_type,'        || --List type
	                        '''' || l_vs_format_type                                     ||''''||' vs_format_type,'              || --validation type
		                '''' || p_kf_pos_no_rv_seg_tab(i).vs_maximum_size            ||''''||' vs_maximum_size,'             ||
			        '''' || p_kf_pos_no_rv_seg_tab(i).vs_precision               ||''''||' vs_precision,'                ||
	                        '''' || p_kf_pos_no_rv_seg_tab(i).vs_numbers_only            ||''''||' vs_numbers_only,'             ||
		                '''' || p_kf_pos_no_rv_seg_tab(i).vs_uppercase_only          ||''''||' vs_uppercase_only,'           ||
			        '''' || p_kf_pos_no_rv_seg_tab(i).vs_right_justify_zero_fill ||''''||' vs_right_justify_zero_fill,'  ||
	                        '''' || p_kf_pos_no_rv_seg_tab(i).vs_min_value               ||''''||' vs_min_value,'                ||
		                '''' || p_kf_pos_no_rv_seg_tab(i).vs_max_value               ||''''||' vs_max_value,'                ||
           		        '''' || p_kf_pos_no_rv_seg_tab(i).vs_value_set_name             ||''''||' value_set_name'               ||
	                        ' FROM DUAL UNION';

	                     dbms_lob.writeappend(l_kf_seg_clob,length(l_temp_sql),l_temp_sql);
	      	 end loop;
       	end if;

	if p_kf_pos_seg_tab.count > 0 or p_kf_pos_rv_seg_tab.count > 0 or p_kf_pos_no_rv_seg_tab.count > 0 then
	dbms_lob.trim(l_kf_seg_clob,length(l_kf_seg_clob)-5);

         --Added to order the segments display in technical summary report for position ff
        l_temp_sql := ' ORDER BY column_name ';
        dbms_lob.writeappend(l_kf_seg_clob,length(l_temp_sql),l_temp_sql);

	p_kf_pos_seg_clob := fetch_clob(l_kf_seg_clob,'PosNoRVKeyFlexSegment','PosNoRVKeyFlexSegments');
	end if;


       hr_utility.set_location('Done with Pos Keyflex Segment ' ||l_proc,20);
       hr_utility.set_location('Before Grade Keyflex Segment ' ||l_proc,20);

	l_kf_seg_clob := null;
	l_kf_seg_clob := get_clob_locator('GrdKeyFlexSegment');
	dbms_lob.createtemporary(l_kf_seg_clob,TRUE);

        if p_kf_grd_seg_tab.count > 0 THEN
	         for i in p_kf_grd_seg_tab.first ..
	                            p_kf_grd_seg_tab.last loop

	   if  p_kf_grd_seg_tab(i).vs_security_available is not null then
		   select meaning into l_vs_security_available from hr_lookups where lookup_type  = 'YES_NO' and lookup_code = p_kf_grd_seg_tab(i).vs_security_available;
	   end if;
	   if  p_kf_grd_seg_tab(i).vs_enable_longlist is not null then
		   select meaning into l_vs_enable_longlist from fnd_lookups where lookup_type  = 'FLEX_VALUESET_LONGLIST_FLAG' and lookup_code = p_kf_grd_seg_tab(i).vs_enable_longlist;
	   end if;
	   if  p_kf_grd_seg_tab(i).vs_format_type is not null then
		   select meaning into l_vs_format_type from fnd_lookups where lookup_type  = 'FIELD_TYPE' and lookup_code = p_kf_grd_seg_tab(i).vs_format_type;
	   end if;

		   l_temp_sql:= ' SELECT ' ||
	                        '''' || p_kf_grd_seg_tab(i).appl_short_name ||''''||' appl_short_name,'   ||
	                        '''' || p_kf_grd_seg_tab(i).flex_code       ||''''||' flex_code,'         ||
	                        '''' || p_kf_grd_seg_tab(i).structure_code  ||''''||' structure_code,'    ||
	                        '''' || p_kf_grd_seg_tab(i).segment_name    ||''''||' segment_name,'	  ||
	                        '''' || p_kf_grd_seg_tab(i).column_name     ||''''||' column_name,'       ||
	                        '''' || p_kf_grd_seg_tab(i).segment_number  ||''''||' segment_number,' 	  ||
	                        '''' || p_kf_grd_seg_tab(i).value_set       ||''''||' value_set,'      	  ||
	                        '''' || p_kf_grd_seg_tab(i).lov_prompt      ||''''||' lov_prompt,'     	  ||
	                        '''' || p_kf_grd_seg_tab(i).segment_type    ||''''||' segment_type,'   	  ||
	                        '''' || p_kf_grd_seg_tab(i).window_prompt   ||''''||' window_prompt,'  	  ||
	                        '''' || l_required			    ||''''||' required,'  	  ||
				'''' || l_display   			    ||''''||' display,'  	  ||
				'''' || l_enabled   			    ||''''||' enabled ,'  	  ||
	 			'''' || l_vs_validation_type   		    ||''''||' vs_validation_type, '  ||
				'''' || p_kf_grd_seg_tab(i).vs_description             ||''''||' vs_description,'              ||
			        '''' || l_vs_security_available			      ||''''||' vs_security_available,'       ||
			        '''' || l_vs_enable_longlist                           ||''''||' vs_list_type,'        || --List type
	                        '''' || l_vs_format_type                               ||''''||' vs_format_type,'              || --validation type
		                '''' || p_kf_grd_seg_tab(i).vs_maximum_size            ||''''||' vs_maximum_size,'             ||
			        '''' || p_kf_grd_seg_tab(i).vs_precision               ||''''||' vs_precision,'                ||
	                        '''' || p_kf_grd_seg_tab(i).vs_numbers_only            ||''''||' vs_numbers_only,'             ||
		                '''' || p_kf_grd_seg_tab(i).vs_uppercase_only          ||''''||' vs_uppercase_only,'           ||
			        '''' || p_kf_grd_seg_tab(i).vs_right_justify_zero_fill ||''''||' vs_right_justify_zero_fill,'  ||
	                        '''' || p_kf_grd_seg_tab(i).vs_min_value               ||''''||' vs_min_value,'                ||
		                '''' || p_kf_grd_seg_tab(i).vs_max_value               ||''''||' vs_max_value,'                ||
			        '''' || p_kf_grd_seg_tab(i).vs_value_set_name             ||''''||' value_set_name'               ||
	                        ' FROM DUAL UNION';

	                     dbms_lob.writeappend(l_kf_seg_clob,length(l_temp_sql),l_temp_sql);
	      	 end loop;
       	end if;

       if p_kf_grd_rv_seg_tab.count > 0 THEN
                for i in p_kf_grd_rv_seg_tab.first ..
                                   p_kf_grd_rv_seg_tab.last loop

	   if  p_kf_grd_rv_seg_tab(i).vs_security_available is not null then
		   select meaning into l_vs_security_available from hr_lookups where lookup_type  = 'YES_NO' and lookup_code = p_kf_grd_rv_seg_tab(i).vs_security_available;
	   end if;
	   if  p_kf_grd_rv_seg_tab(i).vs_enable_longlist is not null then
		   select meaning into l_vs_enable_longlist from fnd_lookups where lookup_type  = 'FLEX_VALUESET_LONGLIST_FLAG' and lookup_code = p_kf_grd_rv_seg_tab(i).vs_enable_longlist;
	   end if;
	   if  p_kf_grd_rv_seg_tab(i).vs_format_type is not null then
		   select meaning into l_vs_format_type from fnd_lookups where lookup_type  = 'FIELD_TYPE' and lookup_code = p_kf_grd_rv_seg_tab(i).vs_format_type;
	   end if;

		  l_temp_sql:= ' SELECT ' ||
                               '''' || p_kf_grd_rv_seg_tab(i).appl_short_name ||''''||' appl_short_name,'   ||
                               '''' || p_kf_grd_rv_seg_tab(i).flex_code       ||''''||' flex_code,'         ||
                               '''' || p_kf_grd_rv_seg_tab(i).structure_code  ||''''||' structure_code,'    ||
                               '''' || p_kf_grd_rv_seg_tab(i).segment_name    ||''''||' segment_name,'	    ||
                               '''' || p_kf_grd_rv_seg_tab(i).column_name     ||''''||' column_name,'       ||
                               '''' || p_kf_grd_rv_seg_tab(i).segment_number  ||''''||' segment_number,'    ||
                               '''' || p_kf_grd_rv_seg_tab(i).value_set       ||''''||' value_set,'         ||
                               '''' || p_kf_grd_rv_seg_tab(i).lov_prompt      ||''''||' lov_prompt,'        ||
                               '''' || p_kf_grd_rv_seg_tab(i).segment_type    ||''''||' segment_type,'      ||
                               '''' || p_kf_grd_rv_seg_tab(i).window_prompt   ||''''||' window_prompt,'     ||
                               '''' || l_required			      ||''''||' required,'  	    ||
			       '''' || l_display   			      ||''''||' display,'  	    ||
			       '''' || l_enabled   			      ||''''||' enabled, '  	    ||
	 			'''' || l_vs_validation_type   		    ||''''||' vs_validation_type, '  ||
			       '''' || p_kf_grd_rv_seg_tab(i).vs_description             ||''''||' vs_description, '              ||
			       '''' || l_vs_security_available			         ||''''||' vs_security_available,'       ||
			       '''' || l_vs_enable_longlist                              ||''''||' vs_list_type,'        || --List type
	                       '''' || l_vs_format_type                                  ||''''||' vs_format_type,'              || --validation type
		               '''' || p_kf_grd_rv_seg_tab(i).vs_maximum_size            ||''''||' vs_maximum_size,'             ||
			       '''' || p_kf_grd_rv_seg_tab(i).vs_precision               ||''''||' vs_precision,'                ||
	                       '''' || p_kf_grd_rv_seg_tab(i).vs_numbers_only            ||''''||' vs_numbers_only,'             ||
		               '''' || p_kf_grd_rv_seg_tab(i).vs_uppercase_only          ||''''||' vs_uppercase_only,'           ||
			       '''' || p_kf_grd_rv_seg_tab(i).vs_right_justify_zero_fill ||''''||' vs_right_justify_zero_fill,'  ||
	                       '''' || p_kf_grd_rv_seg_tab(i).vs_min_value               ||''''||' vs_min_value,'                ||
		               '''' || p_kf_grd_rv_seg_tab(i).vs_max_value               ||''''||' vs_max_value,'                ||
			       '''' || p_kf_grd_rv_seg_tab(i).vs_value_set_name                ||''''||' value_set_name'               ||
                               ' FROM DUAL UNION';

                            dbms_lob.writeappend(l_kf_seg_clob,length(l_temp_sql),l_temp_sql);

             	 end loop;
       	end if;

       if p_kf_grd_no_rv_seg_tab.count > 0 THEN
                for i in p_kf_grd_no_rv_seg_tab.first ..
                                   p_kf_grd_no_rv_seg_tab.last loop

	   if  p_kf_grd_no_rv_seg_tab(i).vs_security_available is not null then
		   select meaning into l_vs_security_available from hr_lookups where lookup_type  = 'YES_NO' and lookup_code = p_kf_grd_no_rv_seg_tab(i).vs_security_available;
	   end if;
	   if  p_kf_grd_no_rv_seg_tab(i).vs_enable_longlist is not null then
		   select meaning into l_vs_enable_longlist from fnd_lookups where lookup_type  = 'FLEX_VALUESET_LONGLIST_FLAG' and lookup_code = p_kf_grd_no_rv_seg_tab(i).vs_enable_longlist;
	   end if;
	   if  p_kf_grd_no_rv_seg_tab(i).vs_format_type is not null then
		   select meaning into l_vs_format_type from fnd_lookups where lookup_type  = 'FIELD_TYPE' and lookup_code = p_kf_grd_no_rv_seg_tab(i).vs_format_type;
	   end if;

                  l_temp_sql:= ' SELECT ' ||
                               '''' || p_kf_grd_no_rv_seg_tab(i).appl_short_name ||''''||' appl_short_name,'   ||
                               '''' || p_kf_grd_no_rv_seg_tab(i).flex_code       ||''''||' flex_code,'         ||
                               '''' || p_kf_grd_no_rv_seg_tab(i).structure_code  ||''''||' structure_code,'    ||
                               '''' || p_kf_grd_no_rv_seg_tab(i).segment_name    ||''''||' segment_name,'      ||
                               '''' || p_kf_grd_no_rv_seg_tab(i).column_name     ||''''||' column_name,'       ||
                               '''' || p_kf_grd_no_rv_seg_tab(i).segment_number  ||''''||' segment_number,'    ||
                               '''' || p_kf_grd_no_rv_seg_tab(i).value_set       ||''''||' value_set,'         ||
                               '''' || p_kf_grd_no_rv_seg_tab(i).lov_prompt      ||''''||' lov_prompt,'        ||
                               '''' || p_kf_grd_no_rv_seg_tab(i).segment_type    ||''''||' segment_type,'      ||
                               '''' || p_kf_grd_no_rv_seg_tab(i).window_prompt   ||''''||' window_prompt,'     ||
                               '''' || l_required			    	 ||''''||' required,'  	       ||
			       '''' || l_display   			    	 ||''''||' display,'  	       ||
			       '''' || l_enabled   			         ||''''||' enabled,'  	       ||
	 			'''' || l_vs_validation_type   		    ||''''||' vs_validation_type, '  ||
			       '''' || p_kf_grd_no_rv_seg_tab(i).vs_description             ||''''||' vs_description,'              ||
			       '''' || l_vs_security_available			            ||''''||' vs_security_available,'       ||
			       '''' || l_vs_enable_longlist                                 ||''''||' vs_list_type,'        || --List type
	                       '''' || l_vs_format_type                                     ||''''||' vs_format_type,'              || --validation type
		               '''' || p_kf_grd_no_rv_seg_tab(i).vs_maximum_size            ||''''||' vs_maximum_size,'             ||
			       '''' || p_kf_grd_no_rv_seg_tab(i).vs_precision               ||''''||' vs_precision,'                ||
	                       '''' || p_kf_grd_no_rv_seg_tab(i).vs_numbers_only            ||''''||' vs_numbers_only,'             ||
		               '''' || p_kf_grd_no_rv_seg_tab(i).vs_uppercase_only          ||''''||' vs_uppercase_only,'           ||
			       '''' || p_kf_grd_no_rv_seg_tab(i).vs_right_justify_zero_fill ||''''||' vs_right_justify_zero_fill,'  ||
	                       '''' || p_kf_grd_no_rv_seg_tab(i).vs_min_value               ||''''||' vs_min_value,'                ||
		               '''' || p_kf_grd_no_rv_seg_tab(i).vs_max_value               ||''''||' vs_max_value,'                ||
		               '''' || p_kf_grd_no_rv_seg_tab(i).vs_value_set_name             ||''''||' value_set_name'                ||
                               ' FROM DUAL UNION';

                            dbms_lob.writeappend(l_kf_seg_clob,length(l_temp_sql),l_temp_sql);

            	 end loop;
       	end if;


	if p_kf_grd_seg_tab.count > 0 or p_kf_grd_rv_seg_tab.count > 0 or p_kf_grd_no_rv_seg_tab.count > 0 then
	dbms_lob.trim(l_kf_seg_clob,length(l_kf_seg_clob)-5);

        --Added to order the segments display in technical summary report for grade ff
        l_temp_sql := ' ORDER BY column_name ';
        dbms_lob.writeappend(l_kf_seg_clob,length(l_temp_sql),l_temp_sql);

	p_kf_grd_seg_clob := fetch_clob(l_kf_seg_clob,'GrdNoRVKeyFlexSegment','GrdNoRVKeyFlexSegments');
	end if;

       hr_utility.set_location('Done with Grade Keyflex Segment ' ||l_proc,20);
       hr_utility.set_location('Before Grp Keyflex Segment ' ||l_proc,20);

	l_kf_seg_clob := null;
	l_kf_seg_clob := get_clob_locator('GrpKeyFlexSegment');
	dbms_lob.createtemporary(l_kf_seg_clob,TRUE);


        if p_kf_grp_seg_tab.count > 0 THEN
                       for i in p_kf_grp_seg_tab.first ..
                                          p_kf_grp_seg_tab.last loop

	   if  p_kf_grp_seg_tab(i).vs_security_available is not null then
		   select meaning into l_vs_security_available from hr_lookups where lookup_type  = 'YES_NO' and lookup_code = p_kf_grp_seg_tab(i).vs_security_available;
	   end if;
	   if  p_kf_grp_seg_tab(i).vs_enable_longlist is not null then
		   select meaning into l_vs_enable_longlist from fnd_lookups where lookup_type  = 'FLEX_VALUESET_LONGLIST_FLAG' and lookup_code = p_kf_grp_seg_tab(i).vs_enable_longlist;
	   end if;
	   if  p_kf_grp_seg_tab(i).vs_format_type is not null then
		   select meaning into l_vs_format_type from fnd_lookups where lookup_type  = 'FIELD_TYPE' and lookup_code = p_kf_grp_seg_tab(i).vs_format_type;
	   end if;

		 l_temp_sql:= ' SELECT ' ||
			      '''' || p_kf_grp_seg_tab(i).appl_short_name ||''''||' appl_short_name,'   ||
			      '''' || p_kf_grp_seg_tab(i).flex_code       ||''''||' flex_code,'         ||
			      '''' || p_kf_grp_seg_tab(i).structure_code  ||''''||' structure_code,'    ||
			      '''' || p_kf_grp_seg_tab(i).segment_name    ||''''||' segment_name,'	||
			      '''' || p_kf_grp_seg_tab(i).column_name     ||''''||' column_name,'       ||
			      '''' || p_kf_grp_seg_tab(i).segment_number  ||''''||' segment_number,'    ||
			      '''' || p_kf_grp_seg_tab(i).value_set       ||''''||' value_set,'         ||
			      '''' || p_kf_grp_seg_tab(i).lov_prompt      ||''''||' lov_prompt,'        ||
			      '''' || p_kf_grp_seg_tab(i).segment_type    ||''''||' segment_type,'      ||
			      '''' || p_kf_grp_seg_tab(i).window_prompt   ||''''||' window_prompt,'     ||
			      '''' || l_required		          ||''''||' required,'  	||
			      '''' || l_display   		          ||''''||' display,'  	  	||
			      '''' || l_enabled   		          ||''''||' enabled, '  	  	||
	 			'''' || l_vs_validation_type   		    ||''''||' vs_validation_type, '  ||
			      '''' || p_kf_grp_seg_tab(i).vs_description             ||''''||' vs_description,'              ||
			      '''' || l_vs_security_available			      ||''''||' vs_security_available,'       ||
			      '''' || l_vs_enable_longlist                           ||''''||' vs_list_type,'        || --List type
	                      '''' || l_vs_format_type                               ||''''||' vs_format_type,'              || --validation type
		              '''' || p_kf_grp_seg_tab(i).vs_maximum_size            ||''''||' vs_maximum_size,'             ||
			      '''' || p_kf_grp_seg_tab(i).vs_precision               ||''''||' vs_precision,'                ||
	                      '''' || p_kf_grp_seg_tab(i).vs_numbers_only            ||''''||' vs_numbers_only,'             ||
		              '''' || p_kf_grp_seg_tab(i).vs_uppercase_only          ||''''||' vs_uppercase_only,'           ||
			      '''' || p_kf_grp_seg_tab(i).vs_right_justify_zero_fill ||''''||' vs_right_justify_zero_fill,'  ||
	                      '''' || p_kf_grp_seg_tab(i).vs_min_value               ||''''||' vs_min_value,'                ||
		              '''' || p_kf_grp_seg_tab(i).vs_max_value               ||''''||' vs_max_value,'                ||
			      '''' || p_kf_grp_seg_tab(i).vs_value_set_name             ||''''||' value_set_name'                ||
			      ' FROM DUAL UNION';

                          dbms_lob.writeappend(l_kf_seg_clob,length(l_temp_sql),l_temp_sql);
                    	 end loop;
       	end if;

	if p_kf_grp_seg_tab.count > 0  then
	dbms_lob.trim(l_kf_seg_clob,length(l_kf_seg_clob)-5);

        --Added to order the segments display in technical summary report for grp ff
        l_temp_sql := ' ORDER BY column_name ';
        dbms_lob.writeappend(l_kf_seg_clob,length(l_temp_sql),l_temp_sql);

	p_kf_grp_seg_clob := fetch_clob(l_kf_seg_clob,'GrpKeyFlexSegment','GrpKeyFlexSegment');
	end if;


       hr_utility.set_location('Done with Grp Keyflex Segment ' ||l_proc,20);
       hr_utility.set_location('Before Cmp Keyflex Segment ' ||l_proc,20);

	l_kf_seg_clob := null;
	l_kf_seg_clob := get_clob_locator('CmpKeyFlexSegment');
	dbms_lob.createtemporary(l_kf_seg_clob,TRUE);

       	 if p_kf_cmp_seg_tab.count > 0 THEN
	                for i in p_kf_cmp_seg_tab.first ..
	                                   p_kf_cmp_seg_tab.last loop

	   if  p_kf_cmp_seg_tab(i).vs_security_available is not null then
		   select meaning into l_vs_security_available from hr_lookups where lookup_type  = 'YES_NO' and lookup_code = p_kf_cmp_seg_tab(i).vs_security_available;
	   end if;
	   if  p_kf_cmp_seg_tab(i).vs_enable_longlist is not null then
		   select meaning into l_vs_enable_longlist from fnd_lookups where lookup_type  = 'FLEX_VALUESET_LONGLIST_FLAG' and lookup_code = p_kf_cmp_seg_tab(i).vs_enable_longlist;
	   end if;
	   if  p_kf_cmp_seg_tab(i).vs_format_type is not null then
		   select meaning into l_vs_format_type from fnd_lookups where lookup_type  = 'FIELD_TYPE' and lookup_code = p_kf_cmp_seg_tab(i).vs_format_type;
	   end if;

		  l_temp_sql:= ' SELECT ' ||
			       '''' || p_kf_cmp_seg_tab(i).appl_short_name ||''''||' appl_short_name,'   ||
			       '''' || p_kf_cmp_seg_tab(i).flex_code       ||''''||' flex_code,'         ||
			       '''' || p_kf_cmp_seg_tab(i).structure_code  ||''''||' structure_code,'    ||
			       '''' || p_kf_cmp_seg_tab(i).segment_name    ||''''||' segment_name,'	 ||
			       '''' || p_kf_cmp_seg_tab(i).column_name     ||''''||' column_name,'       ||
			       '''' || p_kf_cmp_seg_tab(i).segment_number  ||''''||' segment_number,'    ||
			       '''' || p_kf_cmp_seg_tab(i).value_set       ||''''||' value_set,'         ||
			       '''' || p_kf_cmp_seg_tab(i).lov_prompt      ||''''||' lov_prompt,'        ||
			       '''' || p_kf_cmp_seg_tab(i).segment_type    ||''''||' segment_type,'      ||
			       '''' || p_kf_cmp_seg_tab(i).window_prompt   ||''''||' window_prompt,'  	 ||
			       '''' || l_required			   ||''''||' required,'  	 ||
			       '''' || l_display   			   ||''''||' display,'  	 ||
			       '''' || l_enabled   			   ||''''||' enabled, '  	 ||
	 			'''' || l_vs_validation_type   		    ||''''||' vs_validation_type, '  ||
			       '''' || p_kf_cmp_seg_tab(i).vs_description             ||''''||' vs_description, '              ||
			       '''' || l_vs_security_available			      ||''''||' vs_security_available,'       ||
			       '''' || l_vs_enable_longlist                           ||''''||' vs_list_type,'        || --List type
	                       '''' || l_vs_format_type                               ||''''||' vs_format_type,'              || --validation type
		               '''' || p_kf_cmp_seg_tab(i).vs_maximum_size            ||''''||' vs_maximum_size,'             ||
			       '''' || p_kf_cmp_seg_tab(i).vs_precision               ||''''||' vs_precision,'                ||
	                       '''' || p_kf_cmp_seg_tab(i).vs_numbers_only            ||''''||' vs_numbers_only,'             ||
		               '''' || p_kf_cmp_seg_tab(i).vs_uppercase_only          ||''''||' vs_uppercase_only,'           ||
			       '''' || p_kf_cmp_seg_tab(i).vs_right_justify_zero_fill ||''''||' vs_right_justify_zero_fill,'  ||
	                       '''' || p_kf_cmp_seg_tab(i).vs_min_value               ||''''||' vs_min_value,'                ||
		               '''' || p_kf_cmp_seg_tab(i).vs_max_value               ||''''||' vs_max_value,'                ||
			       '''' || p_kf_cmp_seg_tab(i).vs_value_set_name             ||''''||' value_set_name'                ||
			       ' FROM DUAL UNION';

                           dbms_lob.writeappend(l_kf_seg_clob,length(l_temp_sql),l_temp_sql);
	             	 end loop;
       	end if;

	if p_kf_cmp_seg_tab.count > 0  then
	dbms_lob.trim(l_kf_seg_clob,length(l_kf_seg_clob)-5);

        --Added to order the segments display in technical summary report for cmp ff
        l_temp_sql := ' ORDER BY column_name ';
        dbms_lob.writeappend(l_kf_seg_clob,length(l_temp_sql),l_temp_sql);

	p_kf_cmp_seg_clob := fetch_clob(l_kf_seg_clob,'CmpKeyFlexSegment','CmpKeyFlexSegments');
	end if;


       hr_utility.set_location('Done with Cmp Keyflex Segment ' ||l_proc,20);
       hr_utility.set_location('Before Cost Keyflex Segment ' ||l_proc,20);

	l_kf_seg_clob := null;
	l_kf_seg_clob := get_clob_locator('CostKeyFlexSegment');
	dbms_lob.createtemporary(l_kf_seg_clob,TRUE);

      	 if p_kf_cost_seg_tab.count > 0 THEN
		                for i in p_kf_cost_seg_tab.first ..
		                                   p_kf_cost_seg_tab.last loop

	   if  p_kf_cost_seg_tab(i).vs_security_available is not null then
		   select meaning into l_vs_security_available from hr_lookups where lookup_type  = 'YES_NO' and lookup_code = p_kf_cost_seg_tab(i).vs_security_available;
	   end if;
	   if  p_kf_cost_seg_tab(i).vs_enable_longlist is not null then
		   select meaning into l_vs_enable_longlist from fnd_lookups where lookup_type  = 'FLEX_VALUESET_LONGLIST_FLAG' and lookup_code = p_kf_cost_seg_tab(i).vs_enable_longlist;
	   end if;
	   if  p_kf_cost_seg_tab(i).vs_format_type is not null then
		   select meaning into l_vs_format_type from fnd_lookups where lookup_type  = 'FIELD_TYPE' and lookup_code = p_kf_cost_seg_tab(i).vs_format_type;
	   end if;

		  l_temp_sql:= ' SELECT ' ||
			       '''' || p_kf_cost_seg_tab(i).appl_short_name ||''''||' appl_short_name,'   ||
			       '''' || p_kf_cost_seg_tab(i).flex_code       ||''''||' flex_code,'         ||
			       '''' || p_kf_cost_seg_tab(i).structure_code  ||''''||' structure_code,'    ||
			       '''' || p_kf_cost_seg_tab(i).segment_name    ||''''||' segment_name,'	 ||
			       '''' || p_kf_cost_seg_tab(i).column_name     ||''''||' column_name,'       ||
			       '''' || p_kf_cost_seg_tab(i).segment_number  ||''''||' segment_number,'    ||
			       '''' || p_kf_cost_seg_tab(i).value_set       ||''''||' value_set,'         ||
			       '''' || p_kf_cost_seg_tab(i).lov_prompt      ||''''||' lov_prompt,'        ||
			       '''' || p_kf_cost_seg_tab(i).segment_type    ||''''||' segment_type,'      ||
			       '''' || p_kf_cost_seg_tab(i).window_prompt   ||''''||' window_prompt,'  	 ||
			       '''' || l_required			    ||''''||' required,'  	 ||
			       '''' || l_display   			    ||''''||' display,'  	 ||
			       '''' || l_enabled   			    ||''''||' enabled, '  	 ||
	 		       '''' || l_vs_validation_type   		    ||''''||' vs_validation_type, '  ||
			       '''' || p_kf_cost_seg_tab(i).vs_description             ||''''||' vs_description,'              ||
			       '''' || l_vs_security_available			       ||''''||' vs_security_available,'       ||
			       '''' || l_vs_enable_longlist                            ||''''||' vs_list_type,'        || --List type
	                       '''' || l_vs_format_type                                ||''''||' vs_format_type,'              || --validation type
		               '''' || p_kf_cost_seg_tab(i).vs_maximum_size            ||''''||' vs_maximum_size,'             ||
			       '''' || p_kf_cost_seg_tab(i).vs_precision               ||''''||' vs_precision,'                ||
	                       '''' || p_kf_cost_seg_tab(i).vs_numbers_only            ||''''||' vs_numbers_only,'             ||
		               '''' || p_kf_cost_seg_tab(i).vs_uppercase_only          ||''''||' vs_uppercase_only,'           ||
			       '''' || p_kf_cost_seg_tab(i).vs_right_justify_zero_fill ||''''||' vs_right_justify_zero_fill,'  ||
	                       '''' || p_kf_cost_seg_tab(i).vs_min_value               ||''''||' vs_min_value,'                ||
		               '''' || p_kf_cost_seg_tab(i).vs_max_value               ||''''||' vs_max_value,'                ||
			       '''' || p_kf_cost_seg_tab(i).vs_value_set_name          ||''''||' value_set_name'                ||
			       ' FROM DUAL UNION';

			   dbms_lob.writeappend(l_kf_seg_clob,length(l_temp_sql),l_temp_sql);
		   	 end loop;
       	end if;

       hr_utility.set_location('Done with Cost Keyflex Segment ' ||l_proc,20);

	if p_kf_cost_seg_tab.count > 0  then
	dbms_lob.trim(l_kf_seg_clob,length(l_kf_seg_clob)-5);

        --Added to order the segments display in technical summary report for cost ff
        l_temp_sql := ' ORDER BY column_name ';
        dbms_lob.writeappend(l_kf_seg_clob,length(l_temp_sql),l_temp_sql);

	p_kf_cost_seg_clob := fetch_clob(l_kf_seg_clob,'CostKeyFlexSegment','CostKeyFlexSegments');
	end if;


   	hr_utility.set_location('Leaving ' ||l_proc,20);
	return l_ret_kf_seg_clob;

END get_keyflex_segment_sql;

FUNCTION get_keyflex_str_seg_sql_for_pv (p_kf_job_tab 		in per_ri_config_tech_summary.kf_job_tab,
				    p_kf_job_rv_tab 		in per_ri_config_tech_summary.kf_job_rv_tab,
				    p_kf_job_no_rv_tab 		in per_ri_config_tech_summary.kf_job_no_rv_tab,
				    p_kf_pos_tab 		in per_ri_config_tech_summary.kf_pos_tab,
				    p_kf_pos_rv_tab 		in per_ri_config_tech_summary.kf_pos_rv_tab,
				    p_kf_pos_no_rv_tab 		in per_ri_config_tech_summary.kf_pos_no_rv_tab,
				    p_kf_grd_tab 		in per_ri_config_tech_summary.kf_grd_tab,
				    p_kf_grd_rv_tab 		in per_ri_config_tech_summary.kf_grd_rv_tab,
				    p_kf_grd_no_rv_tab 		in per_ri_config_tech_summary.kf_grd_no_rv_tab,
				    p_kf_cmp_tab 		in per_ri_config_tech_summary.kf_cmp_tab,
				    p_kf_grp_tab 		in per_ri_config_tech_summary.kf_grp_tab,
				    p_kf_cost_tab 		in per_ri_config_tech_summary.kf_cost_tab,
				    p_kf_job_seg_tab 		in per_ri_config_tech_summary.kf_job_seg_tab,
                                    p_kf_job_rv_seg_tab 	in per_ri_config_tech_summary.kf_job_rv_seg_tab,
                                    p_kf_job_no_rv_seg_tab 	in per_ri_config_tech_summary.kf_job_no_rv_seg_tab,
                                    p_kf_pos_seg_tab 		in per_ri_config_tech_summary.kf_pos_seg_tab,
                                    p_kf_pos_rv_seg_tab 	in per_ri_config_tech_summary.kf_pos_rv_seg_tab,
                                    p_kf_pos_no_rv_seg_tab 	in per_ri_config_tech_summary.kf_pos_no_rv_seg_tab,
                                    p_kf_grd_seg_tab 		in per_ri_config_tech_summary.kf_grd_seg_tab,
                                    p_kf_grd_rv_seg_tab 	in per_ri_config_tech_summary.kf_grd_rv_seg_tab,
                                    p_kf_grd_no_rv_seg_tab 	in per_ri_config_tech_summary.kf_grd_no_rv_seg_tab,
                                    p_kf_grp_seg_tab 		in per_ri_config_tech_summary.kf_grp_seg_tab,
                                    p_kf_cmp_seg_tab 		in per_ri_config_tech_summary.kf_cmp_seg_tab,
                                    p_kf_cost_seg_tab 		in per_ri_config_tech_summary.kf_cost_seg_tab)
			return clob IS
 l_str_seg_append_clob_for_pv		clob;
 l_proc 				varchar2(200) 	:= 'get_keyflex_str_seg_sql_for_pv';
 l_structure_tab			per_ri_config_tech_summary.kf_structure_tab;
 l_segment_tab				per_ri_config_tech_summary.kf_segment_tab;



BEGIN
	hr_utility.set_location('Entering ' || l_proc,10);

	/* make a copy of job before calling*/
	IF p_kf_job_tab.count > 0 THEN
	   for j in p_kf_job_tab.first ..
		p_kf_job_tab.last loop
			l_structure_tab(j).appl_short_name	:= p_kf_job_tab(j).appl_short_name;
			l_structure_tab(j).flex_code		:= p_kf_job_tab(j).flex_code;
			l_structure_tab(j).structure_code	:= p_kf_job_tab(j).structure_code;
			l_structure_tab(j).structure_title	:= p_kf_job_tab(j).structure_title;
			l_structure_tab(j).description		:= p_kf_job_tab(j).description;
	    end loop;
	end if;
	IF p_kf_job_seg_tab.count > 0 THEN
	   for j in p_kf_job_seg_tab.first ..
		p_kf_job_seg_tab.last loop

			l_segment_tab(j).appl_short_name	:= p_kf_job_seg_tab(j).appl_short_name;
			l_segment_tab(j).flex_code		:= p_kf_job_seg_tab(j).flex_code;
			l_segment_tab(j).structure_code		:= p_kf_job_seg_tab(j).structure_code;
			l_segment_tab(j).segment_name		:= p_kf_job_seg_tab(j).segment_name;
			l_segment_tab(j).column_name		:= p_kf_job_seg_tab(j).column_name;
			l_segment_tab(j).segment_number		:= p_kf_job_seg_tab(j).segment_number;
			l_segment_tab(j).value_set		:= p_kf_job_seg_tab(j).value_set;
			l_segment_tab(j).lov_prompt		:= p_kf_job_seg_tab(j).lov_prompt;
			l_segment_tab(j).segment_type		:= p_kf_job_seg_tab(j).segment_type;
			l_segment_tab(j).window_prompt		:= p_kf_job_seg_tab(j).window_prompt;
			l_segment_tab(j).vs_value_set_name	:= p_kf_job_seg_tab(j).vs_value_set_name;
			l_segment_tab(j).vs_description		:= p_kf_job_seg_tab(j).vs_description;
			l_segment_tab(j).vs_security_available  := p_kf_job_seg_tab(j).vs_security_available;
			l_segment_tab(j).vs_enable_longlist	:= p_kf_job_seg_tab(j).vs_enable_longlist;
			l_segment_tab(j).vs_format_type		:= p_kf_job_seg_tab(j).vs_format_type;
			l_segment_tab(j).vs_maximum_size	:= p_kf_job_seg_tab(j).vs_maximum_size;
			l_segment_tab(j).vs_precision		:= p_kf_job_seg_tab(j).vs_precision;
			l_segment_tab(j).vs_numbers_only	:= p_kf_job_seg_tab(j).vs_numbers_only;
			l_segment_tab(j).vs_uppercase_only	:= p_kf_job_seg_tab(j).vs_uppercase_only;
			l_segment_tab(j).vs_right_justify_zero_fill := p_kf_job_seg_tab(j).vs_right_justify_zero_fill;
			l_segment_tab(j).vs_min_value		:= p_kf_job_seg_tab(j).vs_min_value;
			l_segment_tab(j).vs_max_value		:= p_kf_job_seg_tab(j).vs_max_value;

	    end loop;
	end if;

	IF p_kf_job_tab.count > 0 THEN
	l_str_seg_append_clob_for_pv := get_keyflex_str_seg_dat_for_pv ( l_structure_tab, l_segment_tab ,'Job');
	END if;
	l_structure_tab.delete;
	l_segment_tab.delete;
----------------------------------------------------------------------------------------------------------------------------------

	/* make a copy of job rv before calling*/
	IF p_kf_job_rv_tab.count > 0 THEN
	   for j in p_kf_job_rv_tab.first ..
		p_kf_job_rv_tab.last loop
			l_structure_tab(j).appl_short_name	:= p_kf_job_rv_tab(j).appl_short_name;
			l_structure_tab(j).flex_code		:= p_kf_job_rv_tab(j).flex_code;
			l_structure_tab(j).structure_code	:= p_kf_job_rv_tab(j).structure_code;
			l_structure_tab(j).structure_title	:= p_kf_job_rv_tab(j).structure_title;
			l_structure_tab(j).description		:= p_kf_job_rv_tab(j).description;
	    end loop;
	end if;
	IF p_kf_job_rv_seg_tab.count > 0 THEN
	   for j in p_kf_job_rv_seg_tab.first ..
		p_kf_job_rv_seg_tab.last loop

			l_segment_tab(j).appl_short_name	:= p_kf_job_rv_seg_tab(j).appl_short_name;
			l_segment_tab(j).flex_code		:= p_kf_job_rv_seg_tab(j).flex_code;
			l_segment_tab(j).structure_code		:= p_kf_job_rv_seg_tab(j).structure_code;
			l_segment_tab(j).segment_name		:= p_kf_job_rv_seg_tab(j).segment_name;
			l_segment_tab(j).column_name		:= p_kf_job_rv_seg_tab(j).column_name;
			l_segment_tab(j).segment_number		:= p_kf_job_rv_seg_tab(j).segment_number;
			l_segment_tab(j).value_set		:= p_kf_job_rv_seg_tab(j).value_set;
			l_segment_tab(j).lov_prompt		:= p_kf_job_rv_seg_tab(j).lov_prompt;
			l_segment_tab(j).segment_type		:= p_kf_job_rv_seg_tab(j).segment_type;
			l_segment_tab(j).window_prompt		:= p_kf_job_rv_seg_tab(j).window_prompt;
			l_segment_tab(j).vs_value_set_name	:= p_kf_job_rv_seg_tab(j).vs_value_set_name;
			l_segment_tab(j).vs_description		:= p_kf_job_rv_seg_tab(j).vs_description;
			l_segment_tab(j).vs_security_available  := p_kf_job_rv_seg_tab(j).vs_security_available;
			l_segment_tab(j).vs_enable_longlist	:= p_kf_job_rv_seg_tab(j).vs_enable_longlist;
			l_segment_tab(j).vs_format_type		:= p_kf_job_rv_seg_tab(j).vs_format_type;
			l_segment_tab(j).vs_maximum_size	:= p_kf_job_rv_seg_tab(j).vs_maximum_size;
			l_segment_tab(j).vs_precision		:= p_kf_job_rv_seg_tab(j).vs_precision;
			l_segment_tab(j).vs_numbers_only	:= p_kf_job_rv_seg_tab(j).vs_numbers_only;
			l_segment_tab(j).vs_uppercase_only	:= p_kf_job_rv_seg_tab(j).vs_uppercase_only;
			l_segment_tab(j).vs_right_justify_zero_fill := p_kf_job_rv_seg_tab(j).vs_right_justify_zero_fill;
			l_segment_tab(j).vs_min_value		:= p_kf_job_rv_seg_tab(j).vs_min_value;
			l_segment_tab(j).vs_max_value		:= p_kf_job_rv_seg_tab(j).vs_max_value;

	    end loop;
	end if;

	IF p_kf_job_rv_tab.count > 0 THEN
	l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv || get_keyflex_str_seg_dat_for_pv ( l_structure_tab, l_segment_tab ,'Job');
	END if;

	l_structure_tab.delete;
	l_segment_tab.delete;

----------------------------------------------------------------------------------------------------------------------------------

	/* make a copy of job no rv before calling*/
	IF p_kf_job_no_rv_tab.count > 0 THEN
	   for j in p_kf_job_no_rv_tab.first ..
		p_kf_job_no_rv_tab.last loop
			l_structure_tab(j).appl_short_name	:= p_kf_job_no_rv_tab(j).appl_short_name;
			l_structure_tab(j).flex_code		:= p_kf_job_no_rv_tab(j).flex_code;
			l_structure_tab(j).structure_code	:= p_kf_job_no_rv_tab(j).structure_code;
			l_structure_tab(j).structure_title	:= p_kf_job_no_rv_tab(j).structure_title;
			l_structure_tab(j).description		:= p_kf_job_no_rv_tab(j).description;
	    end loop;
	end if;
	IF p_kf_job_no_rv_seg_tab.count > 0 THEN
	   for j in p_kf_job_no_rv_seg_tab.first ..
		p_kf_job_no_rv_seg_tab.last loop

			l_segment_tab(j).appl_short_name	:= p_kf_job_no_rv_seg_tab(j).appl_short_name;
			l_segment_tab(j).flex_code		:= p_kf_job_no_rv_seg_tab(j).flex_code;
			l_segment_tab(j).structure_code		:= p_kf_job_no_rv_seg_tab(j).structure_code;
			l_segment_tab(j).segment_name		:= p_kf_job_no_rv_seg_tab(j).segment_name;
			l_segment_tab(j).column_name		:= p_kf_job_no_rv_seg_tab(j).column_name;
			l_segment_tab(j).segment_number		:= p_kf_job_no_rv_seg_tab(j).segment_number;
			l_segment_tab(j).value_set		:= p_kf_job_no_rv_seg_tab(j).value_set;
			l_segment_tab(j).lov_prompt		:= p_kf_job_no_rv_seg_tab(j).lov_prompt;
			l_segment_tab(j).segment_type		:= p_kf_job_no_rv_seg_tab(j).segment_type;
			l_segment_tab(j).window_prompt		:= p_kf_job_no_rv_seg_tab(j).window_prompt;
			l_segment_tab(j).vs_value_set_name	:= p_kf_job_no_rv_seg_tab(j).vs_value_set_name;
			l_segment_tab(j).vs_description		:= p_kf_job_no_rv_seg_tab(j).vs_description;
			l_segment_tab(j).vs_security_available  := p_kf_job_no_rv_seg_tab(j).vs_security_available;
			l_segment_tab(j).vs_enable_longlist	:= p_kf_job_no_rv_seg_tab(j).vs_enable_longlist;
			l_segment_tab(j).vs_format_type		:= p_kf_job_no_rv_seg_tab(j).vs_format_type;
			l_segment_tab(j).vs_maximum_size	:= p_kf_job_no_rv_seg_tab(j).vs_maximum_size;
			l_segment_tab(j).vs_precision		:= p_kf_job_no_rv_seg_tab(j).vs_precision;
			l_segment_tab(j).vs_numbers_only	:= p_kf_job_no_rv_seg_tab(j).vs_numbers_only;
			l_segment_tab(j).vs_uppercase_only	:= p_kf_job_no_rv_seg_tab(j).vs_uppercase_only;
			l_segment_tab(j).vs_right_justify_zero_fill := p_kf_job_no_rv_seg_tab(j).vs_right_justify_zero_fill;
			l_segment_tab(j).vs_min_value		:= p_kf_job_no_rv_seg_tab(j).vs_min_value;
			l_segment_tab(j).vs_max_value		:= p_kf_job_no_rv_seg_tab(j).vs_max_value;

	    end loop;
	end if;

	IF p_kf_job_no_rv_tab.count > 0 THEN
	l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv || get_keyflex_str_seg_dat_for_pv ( l_structure_tab, l_segment_tab ,'Job');
	END if;

	l_structure_tab.delete;
	l_segment_tab.delete;


--------------------------------------------------------------------------------------------------------------------------------------------

	/* make a copy of pos before calling*/
	IF p_kf_pos_tab.count > 0 THEN
	   for j in p_kf_pos_tab.first ..
		p_kf_pos_tab.last loop
			l_structure_tab(j).appl_short_name	:= p_kf_pos_tab(j).appl_short_name;
			l_structure_tab(j).flex_code		:= p_kf_pos_tab(j).flex_code;
			l_structure_tab(j).structure_code	:= p_kf_pos_tab(j).structure_code;
			l_structure_tab(j).structure_title	:= p_kf_pos_tab(j).structure_title;
			l_structure_tab(j).description		:= p_kf_pos_tab(j).description;
	    end loop;
	end if;
	IF p_kf_pos_seg_tab.count > 0 THEN
	   for j in p_kf_pos_seg_tab.first ..
		p_kf_pos_seg_tab.last loop
			l_segment_tab(j).appl_short_name	:= p_kf_pos_seg_tab(j).appl_short_name;
			l_segment_tab(j).flex_code		:= p_kf_pos_seg_tab(j).flex_code;
			l_segment_tab(j).structure_code		:= p_kf_pos_seg_tab(j).structure_code;
			l_segment_tab(j).segment_name		:= p_kf_pos_seg_tab(j).segment_name;
			l_segment_tab(j).column_name		:= p_kf_pos_seg_tab(j).column_name;
			l_segment_tab(j).segment_number		:= p_kf_pos_seg_tab(j).segment_number;
			l_segment_tab(j).value_set		:= p_kf_pos_seg_tab(j).value_set;
			l_segment_tab(j).lov_prompt		:= p_kf_pos_seg_tab(j).lov_prompt;
			l_segment_tab(j).segment_type		:= p_kf_pos_seg_tab(j).segment_type;
			l_segment_tab(j).window_prompt		:= p_kf_pos_seg_tab(j).window_prompt;
			l_segment_tab(j).vs_value_set_name	:= p_kf_pos_seg_tab(j).vs_value_set_name;
			l_segment_tab(j).vs_description		:= p_kf_pos_seg_tab(j).vs_description;
			l_segment_tab(j).vs_security_available  := p_kf_pos_seg_tab(j).vs_security_available;
			l_segment_tab(j).vs_enable_longlist	:= p_kf_pos_seg_tab(j).vs_enable_longlist;
			l_segment_tab(j).vs_format_type		:= p_kf_pos_seg_tab(j).vs_format_type;
			l_segment_tab(j).vs_maximum_size	:= p_kf_pos_seg_tab(j).vs_maximum_size;
			l_segment_tab(j).vs_precision		:= p_kf_pos_seg_tab(j).vs_precision;
			l_segment_tab(j).vs_numbers_only	:= p_kf_pos_seg_tab(j).vs_numbers_only;
			l_segment_tab(j).vs_uppercase_only	:= p_kf_pos_seg_tab(j).vs_uppercase_only;
			l_segment_tab(j).vs_right_justify_zero_fill := p_kf_pos_seg_tab(j).vs_right_justify_zero_fill;
			l_segment_tab(j).vs_min_value		:= p_kf_pos_seg_tab(j).vs_min_value;
			l_segment_tab(j).vs_max_value		:= p_kf_pos_seg_tab(j).vs_max_value;

	    end loop;
	end if;

	IF p_kf_pos_tab.count > 0 THEN
	l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||get_keyflex_str_seg_dat_for_pv ( l_structure_tab, l_segment_tab ,'Pos');
	END if;
	l_structure_tab.delete;
	l_segment_tab.delete;

----------------------------------------------------------------------------------------------------------------------------------

	/* make a copy of pos rv before calling*/
	IF p_kf_pos_rv_tab.count > 0 THEN
	   for j in p_kf_pos_rv_tab.first ..
		p_kf_pos_rv_tab.last loop
			l_structure_tab(j).appl_short_name	:= p_kf_pos_rv_tab(j).appl_short_name;
			l_structure_tab(j).flex_code		:= p_kf_pos_rv_tab(j).flex_code;
			l_structure_tab(j).structure_code	:= p_kf_pos_rv_tab(j).structure_code;
			l_structure_tab(j).structure_title	:= p_kf_pos_rv_tab(j).structure_title;
			l_structure_tab(j).description		:= p_kf_pos_rv_tab(j).description;
	    end loop;
	end if;
	IF p_kf_pos_rv_seg_tab.count > 0 THEN
	   for j in p_kf_pos_rv_seg_tab.first ..
		p_kf_pos_rv_seg_tab.last loop
			l_segment_tab(j).appl_short_name	:= p_kf_pos_rv_seg_tab(j).appl_short_name;
			l_segment_tab(j).flex_code		:= p_kf_pos_rv_seg_tab(j).flex_code;
			l_segment_tab(j).structure_code		:= p_kf_pos_rv_seg_tab(j).structure_code;
			l_segment_tab(j).segment_name		:= p_kf_pos_rv_seg_tab(j).segment_name;
			l_segment_tab(j).column_name		:= p_kf_pos_rv_seg_tab(j).column_name;
			l_segment_tab(j).segment_number		:= p_kf_pos_rv_seg_tab(j).segment_number;
			l_segment_tab(j).value_set		:= p_kf_pos_rv_seg_tab(j).value_set;
			l_segment_tab(j).lov_prompt		:= p_kf_pos_rv_seg_tab(j).lov_prompt;
			l_segment_tab(j).segment_type		:= p_kf_pos_rv_seg_tab(j).segment_type;
			l_segment_tab(j).window_prompt		:= p_kf_pos_rv_seg_tab(j).window_prompt;
			l_segment_tab(j).vs_value_set_name	:= p_kf_pos_rv_seg_tab(j).vs_value_set_name;
			l_segment_tab(j).vs_description		:= p_kf_pos_rv_seg_tab(j).vs_description;
			l_segment_tab(j).vs_security_available  := p_kf_pos_rv_seg_tab(j).vs_security_available;
			l_segment_tab(j).vs_enable_longlist	:= p_kf_pos_rv_seg_tab(j).vs_enable_longlist;
			l_segment_tab(j).vs_format_type		:= p_kf_pos_rv_seg_tab(j).vs_format_type;
			l_segment_tab(j).vs_maximum_size	:= p_kf_pos_rv_seg_tab(j).vs_maximum_size;
			l_segment_tab(j).vs_precision		:= p_kf_pos_rv_seg_tab(j).vs_precision;
			l_segment_tab(j).vs_numbers_only	:= p_kf_pos_rv_seg_tab(j).vs_numbers_only;
			l_segment_tab(j).vs_uppercase_only	:= p_kf_pos_rv_seg_tab(j).vs_uppercase_only;
			l_segment_tab(j).vs_right_justify_zero_fill := p_kf_pos_rv_seg_tab(j).vs_right_justify_zero_fill;
			l_segment_tab(j).vs_min_value		:= p_kf_pos_rv_seg_tab(j).vs_min_value;
			l_segment_tab(j).vs_max_value		:= p_kf_pos_rv_seg_tab(j).vs_max_value;

	    end loop;
	end if;

	IF p_kf_pos_rv_tab.count > 0 THEN
	l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv || get_keyflex_str_seg_dat_for_pv ( l_structure_tab, l_segment_tab ,'Pos');
	END if;
	l_structure_tab.delete;
	l_segment_tab.delete;

----------------------------------------------------------------------------------------------------------------------------------

	/* make a copy of pos no rv before calling*/
	IF p_kf_pos_no_rv_tab.count > 0 THEN
	   for j in p_kf_pos_no_rv_tab.first ..
		p_kf_pos_no_rv_tab.last loop
			l_structure_tab(j).appl_short_name	:= p_kf_pos_no_rv_tab(j).appl_short_name;
			l_structure_tab(j).flex_code		:= p_kf_pos_no_rv_tab(j).flex_code;
			l_structure_tab(j).structure_code	:= p_kf_pos_no_rv_tab(j).structure_code;
			l_structure_tab(j).structure_title	:= p_kf_pos_no_rv_tab(j).structure_title;
			l_structure_tab(j).description		:= p_kf_pos_no_rv_tab(j).description;
	    end loop;
	end if;
	IF p_kf_pos_no_rv_seg_tab.count > 0 THEN
	   for j in p_kf_pos_no_rv_seg_tab.first ..
		p_kf_pos_no_rv_seg_tab.last loop
			l_segment_tab(j).appl_short_name	:= p_kf_pos_no_rv_seg_tab(j).appl_short_name;
			l_segment_tab(j).flex_code		:= p_kf_pos_no_rv_seg_tab(j).flex_code;
			l_segment_tab(j).structure_code		:= p_kf_pos_no_rv_seg_tab(j).structure_code;
			l_segment_tab(j).segment_name		:= p_kf_pos_no_rv_seg_tab(j).segment_name;
			l_segment_tab(j).column_name		:= p_kf_pos_no_rv_seg_tab(j).column_name;
			l_segment_tab(j).segment_number		:= p_kf_pos_no_rv_seg_tab(j).segment_number;
			l_segment_tab(j).value_set		:= p_kf_pos_no_rv_seg_tab(j).value_set;
			l_segment_tab(j).lov_prompt		:= p_kf_pos_no_rv_seg_tab(j).lov_prompt;
			l_segment_tab(j).segment_type		:= p_kf_pos_no_rv_seg_tab(j).segment_type;
			l_segment_tab(j).window_prompt		:= p_kf_pos_no_rv_seg_tab(j).window_prompt;
			l_segment_tab(j).vs_value_set_name	:= p_kf_pos_no_rv_seg_tab(j).vs_value_set_name;
			l_segment_tab(j).vs_description		:= p_kf_pos_no_rv_seg_tab(j).vs_description;
			l_segment_tab(j).vs_security_available  := p_kf_pos_no_rv_seg_tab(j).vs_security_available;
			l_segment_tab(j).vs_enable_longlist	:= p_kf_pos_no_rv_seg_tab(j).vs_enable_longlist;
			l_segment_tab(j).vs_format_type		:= p_kf_pos_no_rv_seg_tab(j).vs_format_type;
			l_segment_tab(j).vs_maximum_size	:= p_kf_pos_no_rv_seg_tab(j).vs_maximum_size;
			l_segment_tab(j).vs_precision		:= p_kf_pos_no_rv_seg_tab(j).vs_precision;
			l_segment_tab(j).vs_numbers_only	:= p_kf_pos_no_rv_seg_tab(j).vs_numbers_only;
			l_segment_tab(j).vs_uppercase_only	:= p_kf_pos_no_rv_seg_tab(j).vs_uppercase_only;
			l_segment_tab(j).vs_right_justify_zero_fill := p_kf_pos_no_rv_seg_tab(j).vs_right_justify_zero_fill;
			l_segment_tab(j).vs_min_value		:= p_kf_pos_no_rv_seg_tab(j).vs_min_value;
			l_segment_tab(j).vs_max_value		:= p_kf_pos_no_rv_seg_tab(j).vs_max_value;

	    end loop;
	end if;

	IF p_kf_pos_no_rv_tab.count > 0 THEN
	l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv || get_keyflex_str_seg_dat_for_pv ( l_structure_tab, l_segment_tab ,'Pos');
	END if;
	l_structure_tab.delete;
	l_segment_tab.delete;

--------------------------------------------------------------------------------------------------------------------------------------------

	/* make a copy of grd before calling*/
	IF p_kf_grd_tab.count > 0 THEN
	   for j in p_kf_grd_tab.first ..
		p_kf_grd_tab.last loop
			l_structure_tab(j).appl_short_name	:= p_kf_grd_tab(j).appl_short_name;
			l_structure_tab(j).flex_code		:= p_kf_grd_tab(j).flex_code;
			l_structure_tab(j).structure_code	:= p_kf_grd_tab(j).structure_code;
			l_structure_tab(j).structure_title	:= p_kf_grd_tab(j).structure_title;
			l_structure_tab(j).description		:= p_kf_grd_tab(j).description;
	    end loop;
	end if;
	IF p_kf_grd_seg_tab.count > 0 THEN
	   for j in p_kf_grd_seg_tab.first ..
		p_kf_grd_seg_tab.last loop
			l_segment_tab(j).appl_short_name	:= p_kf_grd_seg_tab(j).appl_short_name;
			l_segment_tab(j).flex_code		:= p_kf_grd_seg_tab(j).flex_code;
			l_segment_tab(j).structure_code		:= p_kf_grd_seg_tab(j).structure_code;
			l_segment_tab(j).segment_name		:= p_kf_grd_seg_tab(j).segment_name;
			l_segment_tab(j).column_name		:= p_kf_grd_seg_tab(j).column_name;
			l_segment_tab(j).segment_number		:= p_kf_grd_seg_tab(j).segment_number;
			l_segment_tab(j).value_set		:= p_kf_grd_seg_tab(j).value_set;
			l_segment_tab(j).lov_prompt		:= p_kf_grd_seg_tab(j).lov_prompt;
			l_segment_tab(j).segment_type		:= p_kf_grd_seg_tab(j).segment_type;
			l_segment_tab(j).window_prompt		:= p_kf_grd_seg_tab(j).window_prompt;
			l_segment_tab(j).vs_value_set_name	:= p_kf_grd_seg_tab(j).vs_value_set_name;
			l_segment_tab(j).vs_description		:= p_kf_grd_seg_tab(j).vs_description;
			l_segment_tab(j).vs_security_available  := p_kf_grd_seg_tab(j).vs_security_available;
			l_segment_tab(j).vs_enable_longlist	:= p_kf_grd_seg_tab(j).vs_enable_longlist;
			l_segment_tab(j).vs_format_type		:= p_kf_grd_seg_tab(j).vs_format_type;
			l_segment_tab(j).vs_maximum_size	:= p_kf_grd_seg_tab(j).vs_maximum_size;
			l_segment_tab(j).vs_precision		:= p_kf_grd_seg_tab(j).vs_precision;
			l_segment_tab(j).vs_numbers_only	:= p_kf_grd_seg_tab(j).vs_numbers_only;
			l_segment_tab(j).vs_uppercase_only	:= p_kf_grd_seg_tab(j).vs_uppercase_only;
			l_segment_tab(j).vs_right_justify_zero_fill := p_kf_grd_seg_tab(j).vs_right_justify_zero_fill;
			l_segment_tab(j).vs_min_value		:= p_kf_grd_seg_tab(j).vs_min_value;
			l_segment_tab(j).vs_max_value		:= p_kf_grd_seg_tab(j).vs_max_value;

	    end loop;
	end if;

	IF p_kf_grd_tab.count > 0 THEN
	l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||get_keyflex_str_seg_dat_for_pv ( l_structure_tab, l_segment_tab ,'Grd');
	END if;
	l_structure_tab.delete;
	l_segment_tab.delete;

----------------------------------------------------------------------------------------------------------------------------------

	/* make a copy of grd rv before calling*/
	IF p_kf_grd_rv_tab.count > 0 THEN
	   for j in p_kf_grd_rv_tab.first ..
		p_kf_grd_rv_tab.last loop
			l_structure_tab(j).appl_short_name	:= p_kf_grd_rv_tab(j).appl_short_name;
			l_structure_tab(j).flex_code		:= p_kf_grd_rv_tab(j).flex_code;
			l_structure_tab(j).structure_code	:= p_kf_grd_rv_tab(j).structure_code;
			l_structure_tab(j).structure_title	:= p_kf_grd_rv_tab(j).structure_title;
			l_structure_tab(j).description		:= p_kf_grd_rv_tab(j).description;
	    end loop;
	end if;
	IF p_kf_grd_rv_seg_tab.count > 0 THEN
	   for j in p_kf_grd_rv_seg_tab.first ..
		p_kf_grd_rv_seg_tab.last loop
			l_segment_tab(j).appl_short_name	:= p_kf_grd_rv_seg_tab(j).appl_short_name;
			l_segment_tab(j).flex_code		:= p_kf_grd_rv_seg_tab(j).flex_code;
			l_segment_tab(j).structure_code		:= p_kf_grd_rv_seg_tab(j).structure_code;
			l_segment_tab(j).segment_name		:= p_kf_grd_rv_seg_tab(j).segment_name;
			l_segment_tab(j).column_name		:= p_kf_grd_rv_seg_tab(j).column_name;
			l_segment_tab(j).segment_number		:= p_kf_grd_rv_seg_tab(j).segment_number;
			l_segment_tab(j).value_set		:= p_kf_grd_rv_seg_tab(j).value_set;
			l_segment_tab(j).lov_prompt		:= p_kf_grd_rv_seg_tab(j).lov_prompt;
			l_segment_tab(j).segment_type		:= p_kf_grd_rv_seg_tab(j).segment_type;
			l_segment_tab(j).window_prompt		:= p_kf_grd_rv_seg_tab(j).window_prompt;
			l_segment_tab(j).vs_value_set_name	:= p_kf_grd_rv_seg_tab(j).vs_value_set_name;
			l_segment_tab(j).vs_description		:= p_kf_grd_rv_seg_tab(j).vs_description;
			l_segment_tab(j).vs_security_available  := p_kf_grd_rv_seg_tab(j).vs_security_available;
			l_segment_tab(j).vs_enable_longlist	:= p_kf_grd_rv_seg_tab(j).vs_enable_longlist;
			l_segment_tab(j).vs_format_type		:= p_kf_grd_rv_seg_tab(j).vs_format_type;
			l_segment_tab(j).vs_maximum_size	:= p_kf_grd_rv_seg_tab(j).vs_maximum_size;
			l_segment_tab(j).vs_precision		:= p_kf_grd_rv_seg_tab(j).vs_precision;
			l_segment_tab(j).vs_numbers_only	:= p_kf_grd_rv_seg_tab(j).vs_numbers_only;
			l_segment_tab(j).vs_uppercase_only	:= p_kf_grd_rv_seg_tab(j).vs_uppercase_only;
			l_segment_tab(j).vs_right_justify_zero_fill := p_kf_grd_rv_seg_tab(j).vs_right_justify_zero_fill;
			l_segment_tab(j).vs_min_value		:= p_kf_grd_rv_seg_tab(j).vs_min_value;
			l_segment_tab(j).vs_max_value		:= p_kf_grd_rv_seg_tab(j).vs_max_value;

	    end loop;
	end if;

	IF p_kf_grd_rv_tab.count > 0 THEN
	l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv || get_keyflex_str_seg_dat_for_pv ( l_structure_tab, l_segment_tab ,'Grd');
	END if;
	l_structure_tab.delete;
	l_segment_tab.delete;

----------------------------------------------------------------------------------------------------------------------------------

	/* make a copy of grd no rv before calling*/
	IF p_kf_grd_no_rv_tab.count > 0 THEN
	   for j in p_kf_grd_no_rv_tab.first ..
		p_kf_grd_no_rv_tab.last loop
			l_structure_tab(j).appl_short_name	:= p_kf_grd_no_rv_tab(j).appl_short_name;
			l_structure_tab(j).flex_code		:= p_kf_grd_no_rv_tab(j).flex_code;
			l_structure_tab(j).structure_code	:= p_kf_grd_no_rv_tab(j).structure_code;
			l_structure_tab(j).structure_title	:= p_kf_grd_no_rv_tab(j).structure_title;
			l_structure_tab(j).description		:= p_kf_grd_no_rv_tab(j).description;
	    end loop;
	end if;
	IF p_kf_grd_no_rv_seg_tab.count > 0 THEN
	   for j in p_kf_grd_no_rv_seg_tab.first ..
		p_kf_grd_no_rv_seg_tab.last loop
			l_segment_tab(j).appl_short_name	:= p_kf_grd_no_rv_seg_tab(j).appl_short_name;
			l_segment_tab(j).flex_code		:= p_kf_grd_no_rv_seg_tab(j).flex_code;
			l_segment_tab(j).structure_code		:= p_kf_grd_no_rv_seg_tab(j).structure_code;
			l_segment_tab(j).segment_name		:= p_kf_grd_no_rv_seg_tab(j).segment_name;
			l_segment_tab(j).column_name		:= p_kf_grd_no_rv_seg_tab(j).column_name;
			l_segment_tab(j).segment_number		:= p_kf_grd_no_rv_seg_tab(j).segment_number;
			l_segment_tab(j).value_set		:= p_kf_grd_no_rv_seg_tab(j).value_set;
			l_segment_tab(j).lov_prompt		:= p_kf_grd_no_rv_seg_tab(j).lov_prompt;
			l_segment_tab(j).segment_type		:= p_kf_grd_no_rv_seg_tab(j).segment_type;
			l_segment_tab(j).window_prompt		:= p_kf_grd_no_rv_seg_tab(j).window_prompt;
			l_segment_tab(j).vs_value_set_name	:= p_kf_grd_no_rv_seg_tab(j).vs_value_set_name;
			l_segment_tab(j).vs_description		:= p_kf_grd_no_rv_seg_tab(j).vs_description;
			l_segment_tab(j).vs_security_available  := p_kf_grd_no_rv_seg_tab(j).vs_security_available;
			l_segment_tab(j).vs_enable_longlist	:= p_kf_grd_no_rv_seg_tab(j).vs_enable_longlist;
			l_segment_tab(j).vs_format_type		:= p_kf_grd_no_rv_seg_tab(j).vs_format_type;
			l_segment_tab(j).vs_maximum_size	:= p_kf_grd_no_rv_seg_tab(j).vs_maximum_size;
			l_segment_tab(j).vs_precision		:= p_kf_grd_no_rv_seg_tab(j).vs_precision;
			l_segment_tab(j).vs_numbers_only	:= p_kf_grd_no_rv_seg_tab(j).vs_numbers_only;
			l_segment_tab(j).vs_uppercase_only	:= p_kf_grd_no_rv_seg_tab(j).vs_uppercase_only;
			l_segment_tab(j).vs_right_justify_zero_fill := p_kf_grd_no_rv_seg_tab(j).vs_right_justify_zero_fill;
			l_segment_tab(j).vs_min_value		:= p_kf_grd_no_rv_seg_tab(j).vs_min_value;
			l_segment_tab(j).vs_max_value		:= p_kf_grd_no_rv_seg_tab(j).vs_max_value;

	    end loop;
	end if;

	IF p_kf_grd_no_rv_tab.count > 0 THEN
	l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv || get_keyflex_str_seg_dat_for_pv ( l_structure_tab, l_segment_tab ,'Grd');
	END if;
	l_structure_tab.delete;
	l_segment_tab.delete;

--------------------------------------------------------------------------------------------------------------------------------------------

	/* make a copy of grp before calling*/
	IF p_kf_grp_tab.count > 0 THEN
	   for j in p_kf_grp_tab.first ..
		p_kf_grp_tab.last loop
			l_structure_tab(j).appl_short_name	:= p_kf_grp_tab(j).appl_short_name;
			l_structure_tab(j).flex_code		:= p_kf_grp_tab(j).flex_code;
			l_structure_tab(j).structure_code	:= p_kf_grp_tab(j).structure_code;
			l_structure_tab(j).structure_title	:= p_kf_grp_tab(j).structure_title;
			l_structure_tab(j).description		:= p_kf_grp_tab(j).description;
	    end loop;
	end if;
	IF p_kf_grp_seg_tab.count > 0 THEN
	   for j in p_kf_grp_seg_tab.first ..
		p_kf_grp_seg_tab.last loop
			l_segment_tab(j).appl_short_name	:= p_kf_grp_seg_tab(j).appl_short_name;
			l_segment_tab(j).flex_code		:= p_kf_grp_seg_tab(j).flex_code;
			l_segment_tab(j).structure_code		:= p_kf_grp_seg_tab(j).structure_code;
			l_segment_tab(j).segment_name		:= p_kf_grp_seg_tab(j).segment_name;
			l_segment_tab(j).column_name		:= p_kf_grp_seg_tab(j).column_name;
			l_segment_tab(j).segment_number		:= p_kf_grp_seg_tab(j).segment_number;
			l_segment_tab(j).value_set		:= p_kf_grp_seg_tab(j).value_set;
			l_segment_tab(j).lov_prompt		:= p_kf_grp_seg_tab(j).lov_prompt;
			l_segment_tab(j).segment_type		:= p_kf_grp_seg_tab(j).segment_type;
			l_segment_tab(j).window_prompt		:= p_kf_grp_seg_tab(j).window_prompt;
			l_segment_tab(j).vs_value_set_name	:= p_kf_grp_seg_tab(j).vs_value_set_name;
			l_segment_tab(j).vs_description		:= p_kf_grp_seg_tab(j).vs_description;
			l_segment_tab(j).vs_security_available  := p_kf_grp_seg_tab(j).vs_security_available;
			l_segment_tab(j).vs_enable_longlist	:= p_kf_grp_seg_tab(j).vs_enable_longlist;
			l_segment_tab(j).vs_format_type		:= p_kf_grp_seg_tab(j).vs_format_type;
			l_segment_tab(j).vs_maximum_size	:= p_kf_grp_seg_tab(j).vs_maximum_size;
			l_segment_tab(j).vs_precision		:= p_kf_grp_seg_tab(j).vs_precision;
			l_segment_tab(j).vs_numbers_only	:= p_kf_grp_seg_tab(j).vs_numbers_only;
			l_segment_tab(j).vs_uppercase_only	:= p_kf_grp_seg_tab(j).vs_uppercase_only;
			l_segment_tab(j).vs_right_justify_zero_fill := p_kf_grp_seg_tab(j).vs_right_justify_zero_fill;
			l_segment_tab(j).vs_min_value		:= p_kf_grp_seg_tab(j).vs_min_value;
			l_segment_tab(j).vs_max_value		:= p_kf_grp_seg_tab(j).vs_max_value;

	    end loop;
	end if;

	IF p_kf_grp_tab.count > 0 THEN
	l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||get_keyflex_str_seg_dat_for_pv ( l_structure_tab, l_segment_tab ,'Grp');
	END if;
	l_structure_tab.delete;
	l_segment_tab.delete;

--------------------------------------------------------------------------------------------------------------------------------------------

	/* make a copy of cmp before calling*/
	IF p_kf_cmp_tab.count > 0 THEN
	   for j in p_kf_cmp_tab.first ..
		p_kf_cmp_tab.last loop
			l_structure_tab(j).appl_short_name	:= p_kf_cmp_tab(j).appl_short_name;
			l_structure_tab(j).flex_code		:= p_kf_cmp_tab(j).flex_code;
			l_structure_tab(j).structure_code	:= p_kf_cmp_tab(j).structure_code;
			l_structure_tab(j).structure_title	:= p_kf_cmp_tab(j).structure_title;
			l_structure_tab(j).description		:= p_kf_cmp_tab(j).description;
	    end loop;
	end if;
	IF p_kf_cmp_seg_tab.count > 0 THEN
	   for j in p_kf_cmp_seg_tab.first ..
		p_kf_cmp_seg_tab.last loop
			l_segment_tab(j).appl_short_name	:= p_kf_cmp_seg_tab(j).appl_short_name;
			l_segment_tab(j).flex_code		:= p_kf_cmp_seg_tab(j).flex_code;
			l_segment_tab(j).structure_code		:= p_kf_cmp_seg_tab(j).structure_code;
			l_segment_tab(j).segment_name		:= p_kf_cmp_seg_tab(j).segment_name;
			l_segment_tab(j).column_name		:= p_kf_cmp_seg_tab(j).column_name;
			l_segment_tab(j).segment_number		:= p_kf_cmp_seg_tab(j).segment_number;
			l_segment_tab(j).value_set		:= p_kf_cmp_seg_tab(j).value_set;
			l_segment_tab(j).lov_prompt		:= p_kf_cmp_seg_tab(j).lov_prompt;
			l_segment_tab(j).segment_type		:= p_kf_cmp_seg_tab(j).segment_type;
			l_segment_tab(j).window_prompt		:= p_kf_cmp_seg_tab(j).window_prompt;
			l_segment_tab(j).vs_value_set_name	:= p_kf_cmp_seg_tab(j).vs_value_set_name;
			l_segment_tab(j).vs_description		:= p_kf_cmp_seg_tab(j).vs_description;
			l_segment_tab(j).vs_security_available  := p_kf_cmp_seg_tab(j).vs_security_available;
			l_segment_tab(j).vs_enable_longlist	:= p_kf_cmp_seg_tab(j).vs_enable_longlist;
			l_segment_tab(j).vs_format_type		:= p_kf_cmp_seg_tab(j).vs_format_type;
			l_segment_tab(j).vs_maximum_size	:= p_kf_cmp_seg_tab(j).vs_maximum_size;
			l_segment_tab(j).vs_precision		:= p_kf_cmp_seg_tab(j).vs_precision;
			l_segment_tab(j).vs_numbers_only	:= p_kf_cmp_seg_tab(j).vs_numbers_only;
			l_segment_tab(j).vs_uppercase_only	:= p_kf_cmp_seg_tab(j).vs_uppercase_only;
			l_segment_tab(j).vs_right_justify_zero_fill := p_kf_cmp_seg_tab(j).vs_right_justify_zero_fill;
			l_segment_tab(j).vs_min_value		:= p_kf_cmp_seg_tab(j).vs_min_value;
			l_segment_tab(j).vs_max_value		:= p_kf_cmp_seg_tab(j).vs_max_value;

	    end loop;
	end if;

	IF p_kf_cmp_tab.count > 0 THEN
	l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||get_keyflex_str_seg_dat_for_pv ( l_structure_tab, l_segment_tab ,'Cmp');
	END if;
	l_structure_tab.delete;
	l_segment_tab.delete;

--------------------------------------------------------------------------------------------------------------------------------------------

	/* make a copy of cost before calling*/
	IF p_kf_cost_tab.count > 0 THEN
	   for j in p_kf_cost_tab.first ..
		p_kf_cost_tab.last loop
			l_structure_tab(j).appl_short_name	:= p_kf_cost_tab(j).appl_short_name;
			l_structure_tab(j).flex_code		:= p_kf_cost_tab(j).flex_code;
			l_structure_tab(j).structure_code	:= p_kf_cost_tab(j).structure_code;
			l_structure_tab(j).structure_title	:= p_kf_cost_tab(j).structure_title;
			l_structure_tab(j).description		:= p_kf_cost_tab(j).description;
	    end loop;
	end if;
	IF p_kf_cost_seg_tab.count > 0 THEN
	   for j in p_kf_cost_seg_tab.first ..
		p_kf_cost_seg_tab.last loop
			l_segment_tab(j).appl_short_name	:= p_kf_cost_seg_tab(j).appl_short_name;
			l_segment_tab(j).flex_code		:= p_kf_cost_seg_tab(j).flex_code;
			l_segment_tab(j).structure_code		:= p_kf_cost_seg_tab(j).structure_code;
			l_segment_tab(j).segment_name		:= p_kf_cost_seg_tab(j).segment_name;
			l_segment_tab(j).column_name		:= p_kf_cost_seg_tab(j).column_name;
			l_segment_tab(j).segment_number		:= p_kf_cost_seg_tab(j).segment_number;
			l_segment_tab(j).value_set		:= p_kf_cost_seg_tab(j).value_set;
			l_segment_tab(j).lov_prompt		:= p_kf_cost_seg_tab(j).lov_prompt;
			l_segment_tab(j).segment_type		:= p_kf_cost_seg_tab(j).segment_type;
			l_segment_tab(j).window_prompt		:= p_kf_cost_seg_tab(j).window_prompt;
			l_segment_tab(j).vs_value_set_name	:= p_kf_cost_seg_tab(j).vs_value_set_name;
			l_segment_tab(j).vs_description		:= p_kf_cost_seg_tab(j).vs_description;
			l_segment_tab(j).vs_security_available  := p_kf_cost_seg_tab(j).vs_security_available;
			l_segment_tab(j).vs_enable_longlist	:= p_kf_cost_seg_tab(j).vs_enable_longlist;
			l_segment_tab(j).vs_format_type		:= p_kf_cost_seg_tab(j).vs_format_type;
			l_segment_tab(j).vs_maximum_size	:= p_kf_cost_seg_tab(j).vs_maximum_size;
			l_segment_tab(j).vs_precision		:= p_kf_cost_seg_tab(j).vs_precision;
			l_segment_tab(j).vs_numbers_only	:= p_kf_cost_seg_tab(j).vs_numbers_only;
			l_segment_tab(j).vs_uppercase_only	:= p_kf_cost_seg_tab(j).vs_uppercase_only;
			l_segment_tab(j).vs_right_justify_zero_fill := p_kf_cost_seg_tab(j).vs_right_justify_zero_fill;
			l_segment_tab(j).vs_min_value		:= p_kf_cost_seg_tab(j).vs_min_value;
			l_segment_tab(j).vs_max_value		:= p_kf_cost_seg_tab(j).vs_max_value;

	    end loop;
	end if;

	IF p_kf_cost_tab.count > 0 THEN
		l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||get_keyflex_str_seg_dat_for_pv ( l_structure_tab, l_segment_tab ,'Cost');
	END If;
	l_structure_tab.delete;
	l_segment_tab.delete;

	--insert into temp(data) values (l_str_seg_append_clob_for_pv);
	--commit;

	hr_utility.set_location('Leaving ' ||l_proc ,20);
	return l_str_seg_append_clob_for_pv;

END get_keyflex_str_seg_sql_for_pv;

FUNCTION   get_keyflex_str_seg_dat_for_pv
                                 (  p_kf_structure_tab 		in per_ri_config_tech_summary.kf_structure_tab,
				    p_kf_segment_tab 		in per_ri_config_tech_summary.kf_segment_tab,
				    p_keyflex_name		in varchar2
                                  ) return clob IS

  l_str_seg_append_clob_for_pv		clob;
  l_temp_sql 				varchar2(32000);
  queryCtx 				number;
  l_proc 				varchar2(200) 	:= 'get_keyflex_str_seg_data_for_pv';
  l_style 				varchar2(10);
  i 					number(8) 	:= 0;
  j					number(8)       := 0;
  l_orderby				varchar2(200);

  l_allow_dynamic			varchar2(8)	:= 'Y';
  l_segment_separator			varchar2(20)	:= 'Period (.)';
  l_enabled				varchar2(8)	:= 'Y';
  l_required				varchar2(8)	:= 'Y';
  l_display				varchar2(8)	:= 'Y';
  l_freeze_flex_def                     varchar2(8)     := 'Y';
  l_vs_validation_type                  varchar2(80);


  l_vs_security_available		varchar2(80);
  l_vs_enable_longlist			varchar2(80);

  l_vs_format_type			varchar2(80);
  l_appl_name                           fnd_application_vl.application_name%type;

  BEGIN
       hr_utility.set_location('Entering ' ||l_proc,10);

       select meaning into l_allow_dynamic from hr_lookups where lookup_type = 'YES_NO' and lookup_code = 'Y';
       select meaning into l_vs_validation_type from fnd_lookups where  lookup_type = 'SEG_VAL_TYPES' and lookup_code = 'I';
       l_enabled  := l_allow_dynamic;
       l_required := l_allow_dynamic;
       l_display  := l_allow_dynamic;
       l_freeze_flex_def := l_allow_dynamic;

       select application_name into l_appl_name from fnd_application_vl where application_short_name =  p_kf_structure_tab(j).appl_short_name;

	--For every cost Structure find all Segments
	IF p_kf_structure_tab.count > 0 THEN
	   for j in p_kf_structure_tab.first ..
		p_kf_structure_tab.last loop

		-- Start the topmost structure node
		l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
						form_xml('CS',p_keyflex_name||'KeyflexStructure','');

		-- Start populating the structure nodes and their values
		l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
						form_xml('CS','APPL_SHORT_NAME','') ||
						form_xml('D','',l_appl_name) ||
						form_xml('CE','APPL_SHORT_NAME','');

		l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
						form_xml('CS','FLEX_CODE','') ||
						form_xml('D','',p_kf_structure_tab(j).flex_code)||
						form_xml('CE','FLEX_CODE','');

		l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
						form_xml('CS','STRUCTURE_CODE','') ||
						form_xml('D','',p_kf_structure_tab(j).structure_code)||
						form_xml('CE','STRUCTURE_CODE','');

		l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
						form_xml('CS','STRUCTURE_TITLE','') ||
						form_xml('D','',p_kf_structure_tab(j).structure_title)||
						form_xml('CE','STRUCTURE_TITLE','');

		l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
						form_xml('CS','DESCRIPTION','') ||
						form_xml('D','',p_kf_structure_tab(j).description)||
						form_xml('CE','DESCRIPTION','');

		l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
						form_xml('CS','ALLOW_DYNAMIC_INSERTS','') ||
						form_xml('D','',l_allow_dynamic)||
						form_xml('CE','ALLOW_DYNAMIC_INSERTS','');

		l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
						form_xml('CS','SEGMENT_SEPARATOR','') ||
						form_xml('D','',l_segment_separator)||
						form_xml('CE','SEGMENT_SEPARATOR','');

		l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
						form_xml('CS','ENABLED','') ||
						form_xml('D','',l_enabled)||
						form_xml('CE','ENABLED','');

		l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
						form_xml('CS','FREEZE_FLEX_DEF','') ||
						form_xml('D','',l_freeze_flex_def)||
						form_xml('CE','FREEZE_FLEX_DEF','');


		if p_kf_segment_tab.count > 0 THEN
		     for i in p_kf_segment_tab.first ..
			p_kf_segment_tab.last loop

		    -- When segment belongs to a structure

		    hr_utility.set_location(p_kf_structure_tab(j).structure_code  || ' ' ||p_kf_segment_tab(i).structure_code ,10);

		    if  p_kf_structure_tab(j).appl_short_name  = p_kf_segment_tab(i).appl_short_name
		    and  p_kf_structure_tab(j).flex_code       = p_kf_segment_tab(i).flex_code
		    and  p_kf_structure_tab(j).structure_code  =  p_kf_segment_tab(i).structure_code then

			 -- When there is no data found error in the following places then do nothing
			 begin
			 if  p_kf_segment_tab(i).vs_security_available is not null then
				select meaning into l_vs_security_available from hr_lookups where lookup_type  = 'YES_NO' and lookup_code = p_kf_segment_tab(i).vs_security_available;
			 end if;
			 if  p_kf_segment_tab(i).vs_enable_longlist is not null then
				select meaning into l_vs_enable_longlist from fnd_lookups where lookup_type  = 'FLEX_VALUESET_LONGLIST_FLAG' and lookup_code = p_kf_segment_tab(i).vs_enable_longlist;
			 end if;
			 if  p_kf_segment_tab(i).vs_format_type is not null then
			   select meaning into l_vs_format_type from fnd_lookups where lookup_type  = 'FIELD_TYPE' and lookup_code = p_kf_segment_tab(i).vs_format_type;
			 end if;
			 exception
				when no_data_found then
				null;
			 end;

			-- Here open a segment node start
			l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
						form_xml('CS',p_keyflex_name||'KeyflexSegment','');


			l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
							form_xml('CS','SEGMENT_NAME','') ||
							form_xml('D','',p_kf_segment_tab(i).segment_name)||
							form_xml('CE','SEGMENT_NAME','');

			l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
							form_xml('CS','COLUMN_NAME','') ||
							form_xml('D','',p_kf_segment_tab(i).column_name)||
							form_xml('CE','COLUMN_NAME','');

			l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
							form_xml('CS','SEGMENT_NUMBER','') ||
							form_xml('D','',p_kf_segment_tab(i).segment_number)||
							form_xml('CE','SEGMENT_NUMBER','');

			l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
							form_xml('CS','VALUE_SET','') ||
							form_xml('D','',p_kf_segment_tab(i).value_set)||
							form_xml('CE','VALUE_SET','');

			l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
							form_xml('CS','LOV_PROMPT','') ||
							form_xml('D','',p_kf_segment_tab(i).lov_prompt)||
							form_xml('CE','LOV_PROMPT','');

			l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
							form_xml('CS','SEGMENT_TYPE','') ||
							form_xml('D','',p_kf_segment_tab(i).segment_type)||
							form_xml('CE','SEGMENT_TYPE','');

			l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
							form_xml('CS','WINDOW_PROMPT','') ||
							form_xml('D','',p_kf_segment_tab(i).window_prompt)||
							form_xml('CE','WINDOW_PROMPT','');

			l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
							form_xml('CS','REQUIRED','') ||
							form_xml('D','',l_required)||
							form_xml('CE','REQUIRED','');

			l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
							form_xml('CS','DISPLAY','') ||
							form_xml('D','',l_display)||
							form_xml('CE','DISPLAY','') ;

			l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
							form_xml('CS','SEG_ENABLED','') ||
							form_xml('D','',l_enabled)||
							form_xml('CE','SEG_ENABLED','');

			l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
							form_xml('CS','VS_DESCRIPTION','') ||
							form_xml('D','',p_kf_segment_tab(i).vs_description)||
							form_xml('CE','VS_DESCRIPTION','');

			l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
							form_xml('CS','VS_SECURITY_AVAILABLE','') ||
							form_xml('D','',l_vs_security_available)||
							form_xml('CE','VS_SECURITY_AVAILABLE','');

			l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
							form_xml('CS','VS_LIST_TYPE','') ||
							form_xml('D','',l_vs_enable_longlist)||
							form_xml('CE','VS_LIST_TYPE','');

			l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
							form_xml('CS','VS_FORMAT_TYPE','') ||
							form_xml('D','',l_vs_format_type)||
							form_xml('CE','VS_FORMAT_TYPE','');

			l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
							form_xml('CS','VS_VALIDATION_TYPE','') ||
							form_xml('D','',l_vs_validation_type)||
							form_xml('CE','VS_VALIDATION_TYPE','');

			l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
							form_xml('CS','VS_MAXIMUM_SIZE','') ||
							form_xml('D','',p_kf_segment_tab(i).vs_maximum_size )||
							form_xml('CE','VS_MAXIMUM_SIZE','');

			l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
							form_xml('CS','VS_PRECISION','') ||
							form_xml('D','',p_kf_segment_tab(i).vs_precision )||
							form_xml('CE','VS_PRECISION','');

			l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
							form_xml('CS','VS_NUMBERS_ONLY','') ||
							form_xml('D','',p_kf_segment_tab(i).vs_numbers_only )||
							form_xml('CE','VS_NUMBERS_ONLY','');

			l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
							form_xml('CS','VS_UPPERCASE_ONLY','') ||
							form_xml('D','',p_kf_segment_tab(i).vs_uppercase_only )||
							form_xml('CE','VS_UPPERCASE_ONLY','');

			l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
							form_xml('CS','VS_RIGHT_JUSTIFY_ZERO_FILL','') ||
							form_xml('D','',p_kf_segment_tab(i).vs_right_justify_zero_fill)||
							form_xml('CE','VS_RIGHT_JUSTIFY_ZERO_FILL','');

			l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
							form_xml('CS','VS_MIN_VALUE','') ||
							form_xml('D','',p_kf_segment_tab(i).vs_min_value)||
							form_xml('CE','VS_MIN_VALUE','');

			l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
							form_xml('CS','VS_MAX_VALUE','') ||
							form_xml('D','',p_kf_segment_tab(i).vs_max_value)||
							form_xml('CE','VS_MAX_VALUE','');

			l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
							form_xml('CS','VALUE_SET_NAME','') ||
							form_xml('D','',p_kf_segment_tab(i).vs_value_set_name)||
							form_xml('CE','VALUE_SET_NAME','');

			-- End one segment detail
			l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
						form_xml('CE',p_keyflex_name||'KeyflexSegment','');


		        end if;
		end loop;

		--End the structure Loop
		l_str_seg_append_clob_for_pv := l_str_seg_append_clob_for_pv ||
						form_xml('CE',p_keyflex_name||'KeyflexStructure','');
	  end if;
	  end loop;

       	end if;
	hr_utility.set_location('Leaving ' || l_proc,20);
	return l_str_seg_append_clob_for_pv;

END get_keyflex_str_seg_dat_for_pv;

FUNCTION form_xml(P_NODE_TYPE IN varchar2,  -- Indicates the node type (i.e start_tag/end_tag/value)
		  P_NODE IN VARCHAR2, -- Indicates the node value
		  P_DATA IN VARCHAR2) -- Indicates the data value
		  return clob
IS
	l_ret_clob               CLOB;
	l_data                   varchar2(2000);
	l_proc                   varchar2(100) := 'form_xml';
BEGIN
hr_utility.set_location('Entering ' || l_proc,10);
    IF p_node_type = 'CS' THEN
	l_ret_clob := '<'||p_node||'>';
    ELSIF p_node_type = 'CE' THEN
	l_ret_clob := '</'||p_node||'>';
    ELSIF p_node_type = 'D' THEN
        l_data := REPLACE (p_data, '&', '&amp;');
        l_data := REPLACE (l_data, '>', '&gt;');
        l_data := REPLACE (l_data, '<', '&lt;');
        l_data := REPLACE (l_data, '''', '&apos;');
        l_data := REPLACE (l_data, '"', '&quot;');
     END IF;

	l_ret_clob := l_ret_clob || l_data;
hr_utility.set_location('Leaving ' || l_proc,20);
return l_ret_clob;

END form_xml;



FUNCTION  get_int_hrms_setup_sql (
				    p_int_hrms_setup_tab  in out nocopy per_ri_config_tech_summary.int_hrms_setup_tab
				  )
				return clob IS


 l_proc                         varchar2(72) 	:= g_package || 'get_int_hrms_setup_sql';
 i 				number(8)	:= 0;
 l_ret_kf_int_hr_clob		clob ;
 l_temp_sql			varchar2(2000);
 l_kf_int_hr_clob		clob;
 queryCtx			number(8)	:= 0;
 l_prejoin_sql			varchar2(2000);
 l_postjoin_sql			varchar2(2000);

  BEGIN

      hr_utility.set_location('Entering ' ||l_proc,10);
      l_kf_int_hr_clob := get_clob_locator('IntlHRMSSetup');
      dbms_lob.createtemporary(l_kf_int_hr_clob,TRUE);

      l_prejoin_sql :=  ' select terr.TERRITORY_SHORT_NAME Legislation , curr.name Currency, A.Tax_Start_Date, '
      			||' lookup.meaning Install_Tax_Unit_Val '
                        ||' from ( ';

      l_postjoin_sql := ' )A , FND_TERRITORIES_VL  terr ,fnd_currencies_vl curr,hr_lookups lookup '
                        ||' where terr.TERRITORY_CODE  = A.legislation_code '
                        ||' and curr.currency_code = A.currency_code '
                        ||' and lookup.lookup_code = A.install_tax_unit '
                        ||' and lookup.lookup_type=''YES_NO'' and lookup.application_id=800 '
                        ||' order by Legislation desc';

       dbms_lob.writeappend(l_kf_int_hr_clob,length(l_prejoin_sql),l_prejoin_sql);

       if p_int_hrms_setup_tab.count > 0 THEN
         for i in p_int_hrms_setup_tab.first ..
                            p_int_hrms_setup_tab.last loop

	   l_temp_sql:= ' SELECT ' ||
			'''' || p_int_hrms_setup_tab(i).legislation_code  ||''''||' legislation_code,'  ||
			'''' || p_int_hrms_setup_tab(i).currency_code     ||''''||' currency_code,'     ||
			'''' || p_int_hrms_setup_tab(i).tax_start_date    ||''''||' tax_start_date,'    ||
			'''' || p_int_hrms_setup_tab(i).install_tax_unit  ||''''||' install_tax_unit'   ||
			' FROM DUAL UNION';

            dbms_lob.writeappend(l_kf_int_hr_clob,length(l_temp_sql),l_temp_sql);
      	 end loop;
       	end if;

       	if (length(l_kf_int_hr_clob)>length(l_prejoin_sql)+ 5)
       	then

	dbms_lob.trim(l_kf_int_hr_clob,length(l_kf_int_hr_clob)-5);
	dbms_lob.writeappend(l_kf_int_hr_clob,length(l_postjoin_sql),l_postjoin_sql);
	l_ret_kf_int_hr_clob := fetch_clob(l_kf_int_hr_clob,'IntlHRMSSetup','IntlHRMSSetups');

	end if;

        hr_utility.set_location('Leaving '|| l_proc,20);
	return l_ret_kf_int_hr_clob;
END get_int_hrms_setup_sql;

FUNCTION  get_security_profile_sql (
				    p_security_profile_tab in out nocopy per_ri_config_tech_summary.sg_tab
				  )
				return clob IS

 l_proc                         varchar2(72) 	:= g_package || ' get_security_profile_sql';
 i 				number(8) 	:= 0;
 l_secprf_clob			clob ;
 l_temp_sql			varchar2(2000);
 l_ret_secprf_clob		clob;
 queryCtx			number(8)	:= 0;
 l_option			varchar2(20) 	:= 'All';
 l_orderby			varchar2(200);

  BEGIN

       hr_utility.set_location('Entering ' ||l_proc,10);
       l_secprf_clob := get_clob_locator('SecurityProfile');
       dbms_lob.createtemporary(l_secprf_clob,TRUE);

       l_orderby := ' order by business_group_name desc ,security_group_name desc ';

       if p_security_profile_tab.count > 0 THEN
         for i in p_security_profile_tab.first ..
                            p_security_profile_tab.last loop

	   l_temp_sql:= ' SELECT ' ||
			'''' || p_security_profile_tab(i).security_group_name	  ||''''||' security_group_name,	'  ||
			'''' || p_security_profile_tab(i).business_group_name	  ||''''||' business_group_name, '  ||
			'''' ||l_option						  ||''''||' Employees, '	    ||
			'''' ||l_option						  ||''''||' Contingent_Workers, '   ||
			'''' ||l_option						  ||''''||' Applicants, '	    ||
			'''' ||l_option						  ||''''||' Contact '		    ||
			' FROM DUAL UNION';



            dbms_lob.writeappend(l_secprf_clob,length(l_temp_sql),l_temp_sql);
      	 end loop;
       	end if;

       	if length(l_secprf_clob)> 5
       	then
       	dbms_lob.trim(l_secprf_clob,length(l_secprf_clob)-5);
	dbms_lob.writeappend(l_secprf_clob,length(l_orderby),l_orderby);

	l_ret_secprf_clob := fetch_clob(l_secprf_clob,'SecurityProfile','SecurityProfiles');
	end if;

	hr_utility.set_location('Leaving ' ||l_proc,20);
	return l_ret_secprf_clob;

END get_security_profile_sql;


FUNCTION  get_org_hierarchy_sql (
				    p_org_hierarchy_tab in out nocopy per_ri_config_tech_summary.org_hierarchy_tab
				  )
				return clob IS

 l_proc                         varchar2(72) 	:= g_package || ' get_org_hierarchy_sql';
 i 				number(8) 	:= 0;
 l_org_hier_clob		clob ;
 l_temp_sql			varchar2(2000);
 l_ret_org_hier_clob		clob;
 queryCtx			number(8)	:= 0;

  BEGIN

       hr_utility.set_location('Entering ' ||l_proc,10);
       l_org_hier_clob := get_clob_locator('OrgHierarchy');
       dbms_lob.createtemporary(l_org_hier_clob,TRUE);

       if p_org_hierarchy_tab.count > 0 THEN
         for i in p_org_hierarchy_tab.first ..
                            p_org_hierarchy_tab.last loop

	   l_temp_sql:= ' SELECT ' ||
			'''' || p_org_hierarchy_tab(i).name                      ||''''||' name ,	'  ||
			'''' || p_org_hierarchy_tab(i).org_structure_version_id  ||''''||' org_structure_version_id '   ||
			' FROM DUAL UNION';

            dbms_lob.writeappend(l_org_hier_clob,length(l_temp_sql),l_temp_sql);
      	 end loop;
       	end if;

       	if length(l_org_hier_clob)> 5
       	then
       	dbms_lob.trim(l_org_hier_clob,length(l_org_hier_clob)-5);
	l_ret_org_hier_clob := fetch_clob(l_org_hier_clob,'OrgHierarchy','OrgHierarchies');

	end if;
	hr_utility.set_location('Leaving ' ||l_proc,20);
	return l_ret_org_hier_clob;

END get_org_hierarchy_sql;

FUNCTION  get_org_hierarchy_ele_sql (
				     p_org_hierarchy_ele_oc_tab in out nocopy per_ri_config_tech_summary.org_hierarchy_ele_oc_tab
				    ,p_org_hierarchy_ele_le_tab in out nocopy per_ri_config_tech_summary.org_hierarchy_ele_le_tab
				  )
				return clob IS
 l_proc                         varchar2(72) 	:= g_package || ' get_org_hierarchy_ele_sql';
 i 				number(8) 	:= 0;
 l_org_hier_ele_clob		clob ;
 l_temp_sql			varchar2(2000);
 l_ret_org_hier_ele_clob	clob;
 queryCtx			number(8)	:= 0;

  BEGIN

      hr_utility.set_location('Entering '||l_proc,10);
      l_org_hier_ele_clob := get_clob_locator('OrgHierarchyEle');
      dbms_lob.createtemporary(l_org_hier_ele_clob,TRUE);

      if p_org_hierarchy_ele_oc_tab.count > 0 THEN
         for i in p_org_hierarchy_ele_oc_tab.first ..
                            p_org_hierarchy_ele_oc_tab.last loop

	   l_temp_sql:= ' SELECT ' ||
			'''' || p_org_hierarchy_ele_oc_tab(i).org_structure_version_id  ||''''||' org_structure_version_id,'||
			'''' || REPLACE ( p_org_hierarchy_ele_oc_tab(i).parent_organization_name  , '''', '''''')  ||''''||' parent_organization_name,'||
			'''' || REPLACE (p_org_hierarchy_ele_oc_tab(i).child_organization_name, '''', '''''')  ||''''||' child_organization_name  '||
			' FROM DUAL UNION';

            dbms_lob.writeappend(l_org_hier_ele_clob,length(l_temp_sql),l_temp_sql);
      	 end loop;
       	end if;

       	if p_org_hierarchy_ele_le_tab.count > 0 THEN
	  for i in p_org_hierarchy_ele_le_tab.first ..
	                            p_org_hierarchy_ele_le_tab.last loop

	   l_temp_sql:= ' SELECT ' ||
			'''' || p_org_hierarchy_ele_le_tab(i).org_structure_version_id  ||''''||' org_structure_version_id,'||
			'''' || REPLACE ( p_org_hierarchy_ele_le_tab(i).parent_organization_name , '''', '''''')  ||''''||' parent_organization_name,'||
			'''' || REPLACE ( p_org_hierarchy_ele_le_tab(i).child_organization_name, '''','''''')  ||''''||' child_organization_name  '||
			' FROM DUAL UNION';

	    dbms_lob.writeappend(l_org_hier_ele_clob,length(l_temp_sql),l_temp_sql);
	  end loop;
       	end if;

        if length(l_org_hier_ele_clob)> 5
       	then
       	dbms_lob.trim(l_org_hier_ele_clob,length(l_org_hier_ele_clob)-5);
	l_ret_org_hier_ele_clob := fetch_clob(l_org_hier_ele_clob,'OrgHierarchyEle','OrgHierarchyEles');

	end if;

	hr_utility.set_location('Leaving '||l_proc,20);
	return l_ret_org_hier_ele_clob;

END get_org_hierarchy_ele_sql;

FUNCTION  get_org_hier_ele_sql_for_pv (
				     p_org_hierarchy_ele_oc_tab in out nocopy per_ri_config_tech_summary.org_hierarchy_ele_oc_tab
				    ,p_org_hierarchy_ele_le_tab in out nocopy per_ri_config_tech_summary.org_hierarchy_ele_le_tab
				  )
				return clob IS
 l_proc                         varchar2(72) 	:= g_package || ' get_org_hierarchy_ele_sql_for_pv';
 i 				number(8) 	:= 0;
 j                              number(8)       := 0;
 l_org_hier_ele_clob		clob ;
 l_org_hier_append_clob         clob ;
 l_temp_clob			clob ;
 l_temp_sql			varchar2(32000);
 l_parent_org_name              varchar2(2000);
 l_ret_org_hier_ele_clob	clob;
 l_oc_name                      varchar2(60)    := '';
 queryCtx			number(8)	:= 0;
 l_le_exists                    boolean := false;

  BEGIN

      hr_utility.set_location('Entering '||l_proc,10);

       l_org_hier_ele_clob := get_clob_locator('OrgHierarchyEleForPV');
       l_temp_clob         := get_clob_locator('OrgHierarchyEleForPV');
       dbms_lob.createtemporary(l_org_hier_ele_clob,TRUE);

       if p_org_hierarchy_ele_oc_tab.count > 0 THEN

	l_parent_org_name := ' SELECT ' ||
		             '''' || REPLACE ( p_org_hierarchy_ele_oc_tab(0).parent_organization_name , '''', '''''')  ||''''||' parent_organization_name';

	--hr_utility.set_location('parent_organization_name : ' ||p_org_hierarchy_ele_oc_tab(0).parent_organization_name,6000);

         for i in p_org_hierarchy_ele_oc_tab.first ..
                            p_org_hierarchy_ele_oc_tab.last loop

		l_temp_sql := l_parent_org_name || ',' ||
		              '''' ||REPLACE ( p_org_hierarchy_ele_oc_tab(i).child_organization_name   , '''', '''''')  ||''''||' oc_name';

              	--hr_utility.set_location('oc_name : ' ||p_org_hierarchy_ele_oc_tab(i).child_organization_name,6000);

       			if p_org_hierarchy_ele_le_tab.count > 0 THEN
			     for j in p_org_hierarchy_ele_le_tab.first ..
				 p_org_hierarchy_ele_le_tab.last loop

					-- Case when LE is under an OC
					if  p_org_hierarchy_ele_oc_tab(i).child_organization_name = p_org_hierarchy_ele_le_tab(j).parent_organization_name THEN

					l_temp_sql := l_temp_sql || ',' ||
	 		                              '''' ||REPLACE ( p_org_hierarchy_ele_le_tab(j).child_organization_name  , '''', '''''')   ||''''||' le_name';
					--hr_utility.set_location('le_name : ' ||p_org_hierarchy_ele_le_tab(j).child_organization_name,6000);
					end if;
			 end loop;
			end if;
		l_temp_sql := l_temp_sql || ' FROM DUAL';
		dbms_lob.writeappend(l_org_hier_ele_clob,length(l_temp_sql),l_temp_sql);
		l_org_hier_append_clob := l_org_hier_append_clob || fetch_clob(l_org_hier_ele_clob,'OrgHierarchyEleForPV','OrgHierarchyElementsForPV');
		dbms_lob.trim(l_org_hier_ele_clob,0);
      	 end loop;

		l_temp_sql := l_parent_org_name;

			if p_org_hierarchy_ele_le_tab.count > 0 THEN
			     for j in p_org_hierarchy_ele_le_tab.first ..
				 p_org_hierarchy_ele_le_tab.last loop

					-- Case when LE is directly under an org
					if  p_org_hierarchy_ele_oc_tab(i).parent_organization_name = p_org_hierarchy_ele_le_tab(j).parent_organization_name THEN

					l_temp_sql := l_temp_sql || ',' ||
	 		                              '''' ||REPLACE ( p_org_hierarchy_ele_le_tab(j).child_organization_name  , '''', '''''')   ||''''||' le_name';

					l_le_exists := true;
					end if;

			 end loop;
			end if;
		l_temp_sql := l_temp_sql ||
                              ' FROM DUAL';

		if l_le_exists then
		dbms_lob.writeappend(l_org_hier_ele_clob,length(l_temp_sql),l_temp_sql);
		l_org_hier_append_clob := l_org_hier_append_clob || fetch_clob(l_org_hier_ele_clob,'OrgHierarchyEleForPV','OrgHierarchyElementsForPV');
		end if;
       	end if;

	hr_utility.set_location('Leaving '||l_proc,20);
	return l_org_hier_append_clob;

END get_org_hier_ele_sql_for_pv;


FUNCTION  get_post_install_sql (
				    p_post_install_tab  in out nocopy per_ri_config_tech_summary.post_install_tab
				  )
				return clob IS
 l_proc                         varchar2(72) 	:= g_package || 'get_post_install_sql';
 i 				number(8) 	:= 0;
 l_ret_post_install_clob	clob ;
 l_temp_sql			varchar2(2000);
 l_post_install_clob		clob;
 queryCtx			number(8)	:= 0;
 l_prejoin_sql			varchar2(2000);
 l_postjoin_sql			varchar2(2000);

  BEGIN

      hr_utility.set_location('Entering ' ||l_proc,10);
      l_post_install_clob := get_clob_locator('PostInstall');
      dbms_lob.createtemporary(l_post_install_clob,TRUE);

      l_prejoin_sql :=  ' select decode(A.legislation_code,''BF'',''International'',terr.TERRITORY_SHORT_NAME) Legislation , '
      			||' fapp.application_name  '
                        ||' from ( ';

      l_postjoin_sql := ' )A , FND_TERRITORIES_VL  terr ,fnd_application_vl fapp '
                        ||' where terr.TERRITORY_CODE  = A.legislation_code '
                        ||' and fapp.application_short_name = A.application_short_name '
                        ||' order by Legislation desc , fapp.application_name desc';

       dbms_lob.writeappend(l_post_install_clob,length(l_prejoin_sql),l_prejoin_sql);

       if p_post_install_tab.count > 0 THEN
         for i in p_post_install_tab.first ..
                            p_post_install_tab.last loop

	   l_temp_sql:= ' SELECT ' ||
			'''' || p_post_install_tab(i).legislation_code      ||''''||' legislation_code,'  	  ||
			'''' || p_post_install_tab(i).applicaton_short_name ||''''||' application_short_name '     ||
			' FROM DUAL UNION';

            dbms_lob.writeappend(l_post_install_clob,length(l_temp_sql),l_temp_sql);
      	 end loop;
       	end if;

       	if (length(l_post_install_clob)>length(l_prejoin_sql)+ 5)
       	then
       	dbms_lob.trim(l_post_install_clob,length(l_post_install_clob)-5);
	dbms_lob.writeappend(l_post_install_clob,length(l_postjoin_sql),l_postjoin_sql);
	l_ret_post_install_clob := fetch_clob(l_post_install_clob,'PostInstall','PostInstalls');

	end if;

	hr_utility.set_location('Leaving ' || l_proc,20);
	return l_ret_post_install_clob;

END get_post_install_sql;

  FUNCTION fetch_clob(p_in_clob IN CLOB, p_row_tag IN VARCHAR2, p_row_set_tag IN VARCHAR2)
              return clob IS
    l_in_clob              clob := p_in_clob;
    l_ret_in_clob          clob;
    queryCtx               number(8) := 0;
    l_proc                 varchar2(73) := g_package || 'fetch_clob';

  BEGIN
    hr_utility.set_location('Entering ' || l_proc,10);
    if p_in_clob is not null then
      queryCtx     := DBMS_XMLQuery.newContext(l_in_clob);
      DBMS_XMLQuery.setRowtag(queryCtx,p_row_tag);
      DBMS_XMLQuery.setRowSettag(queryCtx,p_row_set_tag);
      l_ret_in_clob := DBMS_XMLQuery.getXML(queryCtx);
    end if;
    hr_utility.set_location('Leaving ' || l_proc,20);
    return l_ret_in_clob;
  END fetch_clob;

END per_ri_config_tech_summary;

/
