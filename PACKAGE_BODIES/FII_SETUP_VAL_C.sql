--------------------------------------------------------
--  DDL for Package Body FII_SETUP_VAL_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_SETUP_VAL_C" AS
/* $Header: FIISVALB.pls 120.2.12000000.3 2007/10/16 04:05:05 wywong noship $ */

        g_retcode              VARCHAR2(20)    := NULL;
        g_phase                VARCHAR2(120);


-------------------------------------------------------------------------------
-- FUNCTION detect_unmapped_local_vs
-------------------------------------------------------------------------------
FUNCTION detect_unmapped_local_vs( p_dim_short_name VARCHAR2 ) RETURN NUMBER IS

	l_master_vs_id NUMBER(15);

	cursor missing_csr is
	select
		rpad(fvs.flex_value_set_name, 30, ' ') vs_name,
		ifs.id_flex_structure_name coa_name
	from ( select distinct sas.chart_of_accounts_id
	       from fii_slg_assignments sas,
	            fii_source_ledger_groups slg
	       where slg.usage_code = 'DBI'
	       and slg.source_ledger_group_id = sas.source_ledger_group_id
	     ) coa_list,
		 fii_dim_mapping_rules dmr,
		 fnd_flex_value_sets fvs,
		 fnd_id_flex_structures_v ifs
	where coa_list.chart_of_accounts_id = dmr.chart_of_accounts_id
	and dmr.dimension_short_name = p_dim_short_name
	and not exists (
	    select 1
	    from fii_dim_norm_hierarchy dnh
	    where dnh.parent_flex_value_set_id = l_master_vs_id
	    and dnh.child_flex_value_set_id = dmr.flex_value_set_id1
	    and rownum = 1
	)
	and dmr.flex_value_set_id1 = fvs.flex_value_set_id
	and dmr.chart_of_accounts_id = ifs.id_flex_num
	and ifs.application_id = 101
	and ifs.id_flex_code = 'GL#'
	and ifs.enabled_flag = 'Y';

	l_missing_cnt NUMBER := 0;

BEGIN
  BEGIN
    SELECT master_value_set_id
    INTO   l_master_vs_id
    FROM   fii_financial_dimensions
    WHERE  dimension_short_name = p_dim_short_name;
  EXCEPTION
    WHEN no_data_found THEN
      fii_util.write_log('No master_value_set_id found for ' ||
                         p_dim_short_name );
      raise;
    WHEN others THEN
      raise;
  END;

  FOR missing_csr_rec in missing_csr LOOP
    l_missing_cnt := l_missing_cnt + 1;

    IF (l_missing_cnt = 1) THEN
      fii_message.write_log( msg_name  => 'FII_UNMAPPED_LVS_LIST',
        		     token_num => 0 );
    END IF;

    fii_util.write_log( missing_csr_rec.vs_name || '    ' ||
	  	        missing_csr_rec.coa_name );
  END LOOP;

  RETURN l_missing_cnt;

EXCEPTION
  WHEN others THEN
    fii_util.write_log('Exception in detect_unmapped_local_vs: ' || sqlerrm );
    fii_message.func_fail('FII_SETUP_VAL_C.detect_unmapped_local_vs');
    RETURN -1;
END detect_unmapped_local_vs;

-------------------------------------------------------------------------------
-- PROCEDURE find_dup_ccc_org
-- -- Find out if there are multiple organizations in HR that are assigned
-- -- to the same company and cost center combinations.
-------------------------------------------------------------------------------
FUNCTION FIND_DUP_CCC_ORG RETURN NUMBER IS
  l_count   NUMBER(15) :=0;
  p_status  VARCHAR2(1) := NULL;

  --this cursor prints out all (company, cost_center) with
  --multiple orgs in table fii_ccc_mgr_gt
  Cursor c_duplicate_org is
    select  count(*) cnt,
            company_id,
            cost_center_id
    from  fii_ccc_mgr_gt
    where company_id     is not null
    and cost_center_id is not null
    group by company_id, cost_center_id
    having count(*) > 1;

  --this cursor prints out all org for a given (company, cost_center)
  Cursor c_list_dup_org (p_com_id number, p_cc_id number) is
    select org.name       organization,
           com.flex_value company,
           cc.flex_value  cost_center,
           per.full_name  manager,
           fnd_date.canonical_to_date(hoi.org_information3) eff_date
    from fii_ccc_mgr_gt            gt,
         hr_all_organization_units org,
         fnd_flex_values           com,
         fnd_flex_values           cc,
         per_all_people_f          per,
         hr_organization_information hoi
    where gt.company_id   = p_com_id
    and gt.cost_center_id = p_cc_id
    and gt.ccc_org_id     = org.organization_id
    and gt.company_id     = com.flex_value_id
    and gt.cost_center_id = cc.flex_value_id
    and gt.manager        = per.person_id
    and hoi.org_information_context = 'Organization Name Alias'
    and hoi.organization_id = gt.ccc_org_id;

BEGIN
  -- Populate FII_CCC_MGR_GT
  FII_GL_EXTRACTION_UTIL.LOAD_CCC_MGR (p_status);

  IF p_status = -1 then
    fii_util.write_log('Error in FII_GL_EXTRACTION_UTIL.LOAD_CCC_MGR ...');
    fii_util.write_log('Table FII_CCC_MGR_GT is not populated');
    raise NO_DATA_FOUND;
  END IF;

  l_count := 0;
  FOR r_dup_org IN c_duplicate_org LOOP
    IF l_count = 0 THEN

      FII_MESSAGE.write_log (msg_name   => 'FII_COM_CC_DUP_ORG',
                             token_num  => 0);
      fii_util.put_line(
      'Org Name    Company   Cost Center   Manager            Effective Date');
      fii_util.put_line(
      '----------- --------  -----------   ------------------ --------------');
    END IF;

    l_count := l_count + 1;
    FOR r_list_org IN c_list_dup_org (r_dup_org.company_id,
                                      r_dup_org.cost_center_id) LOOP
      FII_UTIL.write_log ( r_list_org.organization  || '  ' ||
                           r_list_org.company       || '  ' ||
                           r_list_org.cost_center   || '  ' ||
                           r_list_org.manager       || '  ' ||
                           r_list_org.eff_date  );
    END LOOP;
  END LOOP;

  RETURN l_count;

EXCEPTION
    WHEN OTHERS THEN
    fii_util.write_log('Exception in find_dup_ccc_org: ' || sqlerrm );
    fii_message.func_fail('FII_SETUP_VAL_C.find_dup_ccc_org');
    RETURN -1;

END FIND_DUP_CCC_ORG;

-------------------------------------------------------------------------------
-- PROCEDURE VALIDATE_USER_SETUP
-- This procedure will perform user setup validations.
-------------------------------------------------------------------------------
PROCEDURE VALIDATE_USER_SETUP (p_user_name VARCHAR2) IS
  l_user_id		    NUMBER(15) := NULL;
  l_status                  NUMBER(15) := 0;
  l_security_profile_id     NUMBER;
  l_security_org_id         NUMBER;
  l_business_group_id       NUMBER;
  l_all_org_flag            VARCHAR2(30);
  l_org_id                  NUMBER;
  l_org_name                VARCHAR2(240);
  l_sec_profile_name        VARCHAR2(240);
  l_sec_warn_flag           VARCHAR2(1);
  l_cnt                     NUMBER;

  CURSOR mgr_status_cur(user_id NUMBER) IS
    SELECT 1
    FROM dual
    WHERE NOT EXISTS (
      SELECT DISTINCT  suph.sup_person_id
      FROM (SELECT    to_number (mgr_tbl.org_information2)  manager,
                      ccc_tbl.organization_id               ccc_org_id
            FROM      hr_organization_information ccc_tbl,
                    ( SELECT organization_id, org_information2
                      FROM hr_organization_information b
                      WHERE org_information_context = 'Organization Name Alias'
                      AND nvl( fnd_date.canonical_to_date( org_information3 ),
                               sysdate + 1 ) <= sysdate
                      AND nvl( fnd_date.canonical_to_date( org_information4 ),
                               sysdate + 1 ) >= sysdate
                     ) mgr_tbl,
                      hr_organization_information org,
                      fnd_flex_values    fv1,
                      fnd_flex_values    fv2
             WHERE    ccc_tbl.org_information_context = 'CLASS'
             AND      ccc_tbl.org_information1 = 'CC'
             AND      ccc_tbl.org_information2 = 'Y'
             AND      ccc_tbl.organization_id = mgr_tbl.organization_id (+)
             AND      org.org_information_context = 'Company Cost Center'
             AND      org.organization_id   = ccc_tbl.organization_id
             AND      fv1.flex_value_set_id = org.org_information2
             AND      fv1.flex_value        = org.org_information3
             AND      fv2.flex_value_set_id = org.org_information4
             AND      fv2.flex_value        = org.org_information5) ct,
             hri_cs_suph                 suph,
             per_assignment_status_types ast
      WHERE ct.manager = suph.sub_person_id
      AND sysdate between suph.effective_start_date and suph.effective_end_date
      AND suph.sup_assignment_status_type_id = ast.assignment_status_type_id
      AND ast.per_system_status IN ('ACTIVE_ASSIGN', 'SUSP_ASSIGN')
      AND ct.manager = user_id);

  CURSOR sec_org_cur IS
    SELECT security_profile_name
    FROM   per_security_profiles
    WHERE security_profile_id NOT IN (SELECT security_profile_id
                                      FROM per_organization_list);

BEGIN
    ----------------------------------------------------------------------
    -- User Setup Validations
    ----------------------------------------------------------------------
    -- Make sure that the username pass in exists in fii_cc_mgr_sup_v
    ----------------------------------------------------------------------
    fii_util.put_line(' ');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    fii_util.put_line(' ');
    fii_util.put_line(
    '***********************************************************************');
    fii_util.put_line(
    '**********************  User Setup Validations ************************');
    fii_util.put_line(
    '***********************************************************************');
    fii_util.put_line(' ');
    fii_util.put_line('Performing Check for: User exists in fii_cc_mgr_sup_v');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    -- Check if user exists in manager view
    fii_util.put_line('START CHECK: User exists in fii_cc_mgr_sup_v');
    fii_util.put_line(' ');

    -- Set a default value for l_user_id
    l_user_id := -1;

    -- Retrieve fnd user ID from the username if it exists in fii_cc_mgr_sup_v
    BEGIN
      SELECT DISTINCT employee_id
      INTO  l_user_id
      FROM  fnd_user a,
            fii_cc_mgr_sup_v b
      WHERE a.user_name = UPPER(p_user_name)
      AND   a.employee_id = b.id;
    EXCEPTION
      WHEN no_data_found THEN
        fii_util.put_line('The username '|| p_user_name ||
                          'is not found in fii_cc_mgr_sup_v');

    END;

    fii_util.put_line('Username parameter = ' || p_user_name ||
                      ' and its user_id = ' || l_user_id);

    fii_util.put_line(' ');
    IF (l_user_id = -1) THEN
      fii_util.put_line('DIAGNOSIS: The user ' || p_user_name ||
' does not have a person attached to it or the person does not exist in fii_cc_mgr_sup_v');

    ELSE
      fii_util.put_line('DIAGNOSIS: A person is attached to the user ' || p_user_name ||
             ' and this person exists in fii_cc_mgr_sup_v');
      fii_util.put_line('DIAGNOSIS: NO ACTION is needed.');
    END IF;

    fii_util.put_line(' ');
    fii_util.put_line('END CHECK: User exists in fii_cc_mgr_sup_v');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');

    ----------------------------------------------------------------------
    -- Check to see if manager assignment status is either Active Assignment
    -- or Suspended Assignment for the manager attached to the user logged in
    ----------------------------------------------------------------------
    fii_util.put_line(' ');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    fii_util.put_line('Performing Check for: Manager Assignment Status');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    -- Check the manager assignment status
    fii_util.put_line('START CHECK: Manager Assignment Status');
    fii_util.put_line(' ');

    OPEN mgr_status_cur(l_user_id);
    FETCH mgr_status_cur INTO l_status;

    IF mgr_status_cur%NOTFOUND THEN
      fii_util.put_line('DIAGNOSIS: Manager Assignment Status for user '''||
                        p_user_name||
                        ''' is ''Active'' or ''Suspended''');
      fii_util.put_line('DIAGNOSIS: NO ACTION is needed.');
    ELSE
      fii_util.put_line('DIAGNOSIS: Manager Assignment Status for user '''||
                        p_user_name||
                        ''' is neither ''Active'' nor ''Suspended''.  Please review.');
    END IF;


    CLOSE mgr_status_cur;

    fii_util.put_line(' ');
    fii_util.put_line('END CHECK: Manager Assignment Status');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');

    ----------------------------------------------------------------------
    -- Check to see if we have operating units assigned to the security profile
    ----------------------------------------------------------------------
    fii_util.put_line(' ');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    fii_util.put_line('Performing Check for: Profile-Operating Unit Assignment');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    -- Check the profile-operating unit assignment
    fii_util.put_line('START CHECK: Profile-Operating Unit Assignment Analysis');
    fii_util.put_line(' ');

    l_cnt := 0;
    OPEN sec_org_cur;
    LOOP
      FETCH sec_org_cur INTO l_sec_profile_name;
      EXIT WHEN sec_org_cur%NOTFOUND;

      IF (l_cnt = 0) THEN
        fii_util.put_line('Profile Name ');
        fii_util.put_line(
        '-----------------------------------------------------------------------');
        l_cnt := l_cnt + 1;
      END IF;
      fii_util.put_line(l_sec_profile_name);
    END LOOP;
    CLOSE sec_org_cur;

    fii_util.put_line(' ');
    IF l_cnt > 0 THEN
      fii_util.put_line(
      'DIAGNOSIS: Please assign Operating units for the above profiles.');
    ELSE
      fii_util.put_line(
      'DIAGNOSIS: Profile-Operating Unit Assignments Verified.');
      fii_util.put_line('DIAGNOSIS: NO ACTION is needed.');
    END IF;

    fii_util.put_line(' ');
    fii_util.put_line(
    'END CHECK: Profile-Organization Unit Assignment Analysis.');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');

END VALIDATE_USER_SETUP;


/************************************************************************
     			 PUBLIC PROCEDURES
************************************************************************/

-------------------------------------------------------------------------------

  -- Procedure
  --   	Main
  -- Purpose
  --   	This is the main routine of the Validate Setup program
  -- History
  --   	08-30-06	 W Wong	        Created
  -- Arguments
  --    X_User     User Name used for checking user setup
  -- Example
  --    result := FII_SETUP_VAL_C.Main(Errbuf, Retcode, X_User);
  -- Notes
  --
  PROCEDURE Main (Errbuf  IN OUT NOCOPY VARCHAR2,
                  Retcode IN OUT NOCOPY VARCHAR2,
                  X_User  IN VARCHAR2) IS
    l_prim_curr_code	    VARCHAR2(15) := NULL;
    l_sec_curr_code	    VARCHAR2(15) := NULL;
    l_prim_curr_mau	    NUMBER	 := NULL;
    l_sec_curr_mau	    NUMBER	 := NULL;
    l_budget_time_unit	    VARCHAR2(1)  := NULL;
    l_forecast_time_unit    VARCHAR2(1)  := NULL;
    l_user_id		    NUMBER(15)   := NULL;
    l_login_id		    NUMBER(15)   := NULL;
    l_req_id		    NUMBER(15)   := NULL;
    l_global_start_date     VARCHAR2(15) := NULL;
    l_unassigned_udd_id     NUMBER(15)   := NULL;
    l_industry_profile      VARCHAR2(1);
    l_budget_source         VARCHAR2(15);
    l_start_time            VARCHAR2(30);
    l_end_time              VARCHAR2(30);
    l_period_set_name       VARCHAR2(15);
    l_period_type           VARCHAR2(15);
    l_year                  NUMBER;
    l_min_start_date        DATE;
    l_max_end_date          DATE := sysdate;

    l_db_version            VARCHAR2(100);
    l_sys_date              DATE;
    l_day                   DATE;
    l_start_day             DATE;
    l_cnt                   NUMBER;
    l_dummy                 NUMBER;
    l_fiscal_year_day       NUMBER;
    l_dim_name              VARCHAR2(4000);
    l_dim_short_name        VARCHAR2(30);
    l_fin_type_name         VARCHAR2(30);
    l_co_name               VARCHAR2(150);
    l_co_id                 NUMBER;
    l_cc_name               VARCHAR2(150);
    l_cc_id                 NUMBER;
    l_fc_name               VARCHAR2(150);
    l_fc_id                 NUMBER;
    l_udd1_name             VARCHAR2(150);
    l_udd1_id               NUMBER;
    l_udd2_name             VARCHAR2(150);
    l_udd2_id               NUMBER;
    l_vs_name               VARCHAR2(60);
    l_vs_id                 NUMBER;
    l_mgr                   VARCHAR2(240);
    l_emp_num               NUMBER;
    l_eff_start             VARCHAR2(30);
    l_eff_end               VARCHAR2(30);
    l_org_name              VARCHAR2(240);
    l_org_id                NUMBER;
    l_status                VARCHAR2(30);
    l_enabled_flag          VARCHAR2(1);
    l_profile_value         VARCHAR2(1);
    l_dashboard_warn_flag   VARCHAR2(1);
    l_mv_name               VARCHAR2(100);
    l_mv_row_ct             NUMBER;
    l_stmt                  VARCHAR2(2000);
    l_udd_enabled_flag      VARCHAR2(1);
    l_lookup_code           VARCHAR2(30);
    l_lookup_type           VARCHAR2(30);

  CURSOR ent_period_cur (day date) IS
     select 1
     from   gl_periods
     where  adjustment_period_flag = 'N'
     and    period_set_name = l_period_set_name
     and    period_type = l_period_type
     and    day between start_date and end_date;

  CURSOR fiscal_year_cur (year number) IS
    select min(a.start_date), max(end_date)
    from gl_periods a
    where a.period_set_name = l_period_set_name
    and a.period_type = l_period_type
    and a.adjustment_period_flag = 'N'
    and a.period_year = year;

  CURSOR enabled_dim_cur IS
    select dimension_name, dimension_short_name
    from fii_financial_dimensions_v
    where dbi_enabled_flag = 'Y';

  CURSOR fin_type_cur IS
    select 'R'
    from dual
    where not exists (select 1 from fii_fin_cat_type_assgns
                      where fin_cat_type_code = 'R')
    union
    select 'OE'
    from dual
    where not exists (select 1 from fii_fin_cat_type_assgns
                      where fin_cat_type_code = 'OE')
    union
    select 'TE'
    from dual
    where not exists (select 1 from fii_fin_cat_type_assgns
                      where fin_cat_type_code = 'TE')
    union
    select 'CGS'
    from dual
    where not exists (select 1 from fii_fin_cat_type_assgns
                      where fin_cat_type_code = 'CGS')
    union
    select 'DR'
    from dual
    where not exists (select 1 from fii_fin_cat_type_assgns
                      where fin_cat_type_code = 'DR');

  --this cursor prints out all company, cost_center with no orgs assigned
  Cursor no_org_cur is
  select  fv_co.flex_value     company,
          fv_co.flex_value_id  com_id,
          fv_cc.flex_value     cost_center,
          fv_cc.flex_value_id  cc_id
  from   (select distinct company_id, cost_center_id
          from fii_gl_je_summary_b) b,
         fnd_flex_values     fv_co,
         fnd_flex_values     fv_cc
  where  fv_co.flex_value_id = b.company_id
  and    fv_cc.flex_value_id = b.cost_center_id
  and   not exists (select 1 from hr_organization_information
                    where org_information_context = 'Company Cost Center'
                    and   org_information2 = fv_co.flex_value_set_id
                    and   org_information3 = fv_co.flex_value
                    and   org_information4 = fv_cc.flex_value_set_id
                    and   org_information5 = fv_cc.flex_value);

  CURSOR org_no_cc_cur IS
    select fv_co.flex_value_id co_id,
           fv_co.flex_value co,
           org.organization_id,
           org2.name
    from (select distinct company_id
          from fii_gl_je_summary_b) b,
         fnd_flex_values fv_co,
         hr_organization_information org,
         hr_all_organization_units org2
    where fv_co.flex_value_id = b.company_id
    and   org_information_context = 'Company Cost Center'
    and   org_information2 = fv_co.flex_value_set_id
    and   org_information3 = fv_co.flex_value
    and   org_information4 is null
    and   org_information5 is null
    and   org2.organization_id = org.organization_id;

  CURSOR mgr_assgn_cur IS
    select fv_co.flex_value co,
           fv_cc.flex_value cc,
           org.organization_id,
           org2.name organization
    from (select distinct company_id, cost_center_id
          from fii_gl_je_summary_b) b,
          fnd_flex_values fv_co,
          fnd_flex_values fv_cc,
          hr_organization_information org,
          hr_all_organization_units org2
    where fv_co.flex_value_id = b.company_id
    and   fv_cc.flex_value_id = b.cost_center_id
    and   org_information_context = 'Company Cost Center'
    and   org_information2 = fv_co.flex_value_set_id
    and   org_information3 = fv_co.flex_value
    and   org_information4 = fv_cc.flex_value_set_id
    and   org_information5 = fv_cc.flex_value
    and   org2.organization_id = org.organization_id
    and   not exists
            (select 1
             from hr_organization_information mgr
             where mgr.org_information_context = 'Organization Name Alias'
             and   (nvl( fnd_date.canonical_to_date( mgr.org_information3 ),
                         sysdate + 1 ) <= sysdate
                 or nvl( fnd_date.canonical_to_date( mgr.org_information4 ),
                         sysdate + 1 ) >= sysdate)
             and   mgr.org_information2 is not null
             and   mgr.organization_id = org.organization_id);

    CURSOR mgr_eff_cur IS
      select per2.first_name || ' ' || per2.last_name name,
             org.name organization,
             per2.effective_end_date
      from
          ( select organization_id, org_information2
            from   hr_organization_information b
            where org_information_context = 'Organization Name Alias'
            and   (nvl( fnd_date.canonical_to_date( org_information3 ),
                        sysdate + 1 ) <= sysdate
                or nvl( fnd_date.canonical_to_date( org_information4 ),
                        sysdate + 1 ) >= sysdate)
            and   org_information2 is not null
          ) mgr_tbl,
          hr_all_organization_units org,
          per_all_people_f per2
      where org.organization_id = mgr_tbl.organization_id
      and   per2.person_id = mgr_tbl.org_information2
      and   not exists (select 1
                        from per_all_people_f per
                        where per.person_id = mgr_tbl.org_information2
                        and   per.effective_end_date > sysdate);

    CURSOR mgr_status_cur IS
      select distinct per.full_name, ast.per_system_status
      from ( select organization_id, org_information2
             from   hr_organization_information b
             where org_information_context = 'Organization Name Alias'
             and   (nvl( fnd_date.canonical_to_date( org_information3 ),
                         sysdate + 1 ) <= sysdate
                 or nvl( fnd_date.canonical_to_date( org_information4 ),
                         sysdate + 1 ) >= sysdate)
             and   org_information2 is not null) ct,
           hri_cs_suph                 suph,
           per_assignment_status_types ast,
           per_all_people_f            per
      where ct.org_information2 = suph.sub_person_id
      and   per.person_id       = suph.sub_person_id
      and sysdate between suph.effective_start_date
                      and suph.effective_end_date
      and suph.sup_assignment_status_type_id = ast.assignment_status_type_id
      and ast.per_system_status NOT IN ('ACTIVE_ASSIGN', 'SUSP_ASSIGN');

    CURSOR trans_ccc_no_mgr_cur IS
      SELECT  ccc_tbl.organization_id ccc_org_id,
              rpad(hou.name, 40, ' '), fgj.company_id, fv1.flex_value co,
              fgj.cost_center_id, fv2.flex_value cc
      FROM    hr_organization_information ccc_tbl,
            ( select organization_id, org_information2
              from hr_organization_information
              where org_information_context = 'Organization Name Alias'
              and nvl( fnd_date.canonical_to_date( org_information3 ),
                       sysdate + 1 ) <= sysdate
              and nvl( fnd_date.canonical_to_date( org_information4 ),
                       sysdate + 1 ) >= sysdate
             ) mgr_tbl,
             hr_organization_information org,
             hr_all_organization_units   hou,
             fnd_flex_values    fv1,
             fnd_flex_values    fv2,
             (select distinct company_id, cost_center_id
              from fii_gl_je_summary_b) fgj
      WHERE  ccc_tbl.org_information_context = 'CLASS'
      AND    ccc_tbl.org_information1 = 'CC'
      AND    ccc_tbl.org_information2 = 'Y'
      AND    ccc_tbl.organization_id = mgr_tbl.organization_id (+)
      AND    org.org_information_context = 'Company Cost Center'
      AND    org.organization_id   = ccc_tbl.organization_id
      AND    hou.organization_id = ccc_tbl.organization_id
      AND    fv1.flex_value_set_id = org.org_information2
      AND    fv1.flex_value        = org.org_information3
      AND    fv2.flex_value_set_id = org.org_information4
      AND    fv2.flex_value        = org.org_information5
      AND    fv1.flex_value_id     = fgj.company_id
      AND    fv2.flex_value_id     = fgj.cost_center_id
      AND    fgj.company_id IS NOT NULL
      AND    fgj.cost_center_id IS NOT NULL
      AND    mgr_tbl.org_information2 IS NULL;

    CURSOR trans_no_fc_cur IS
      SELECT  b.flex_value_set_id, rpad(e.flex_value_set_name, 40, ' '),
              c.fin_category_id, d.flex_value
      FROM fnd_segment_attribute_values a,
           fnd_id_flex_segments b,
          (select distinct v.fin_category_id, v.chart_of_accounts_id
           from
         ( select  distinct fgj.fin_category_id, fgj.chart_of_accounts_id
           from  hr_organization_information ccc_tbl,
               ( select organization_id, org_information2
                 from hr_organization_information
                 where org_information_context = 'Organization Name Alias'
                 and nvl( fnd_date.canonical_to_date( org_information3 ),
                          sysdate + 1 ) <= sysdate
                 and nvl( fnd_date.canonical_to_date( org_information4 ),
                          sysdate + 1 ) >= sysdate
               ) mgr_tbl,
                 hr_organization_information org,
                 fnd_flex_values    fv1,
                 fnd_flex_values    fv2,
                (select distinct company_id, cost_center_id, fin_category_id,
                                 chart_of_accounts_id
                 from fii_gl_je_summary_b) fgj
                 where  ccc_tbl.org_information_context = 'CLASS'
                 and    ccc_tbl.org_information1 = 'CC'
                 and    ccc_tbl.org_information2 = 'Y'
                 and    ccc_tbl.organization_id = mgr_tbl.organization_id (+)
                 and    org.org_information_context = 'Company Cost Center'
                 and    org.organization_id   = ccc_tbl.organization_id
                 and    fv1.flex_value_set_id = org.org_information2
                 and    fv1.flex_value        = org.org_information3
                 and    fv2.flex_value_set_id = org.org_information4
                 and    fv2.flex_value        = org.org_information5
                 and    fv1.flex_value_id        = fgj.company_id
                 and    fv2.flex_value_id        = fgj.cost_center_id) v
           where not exists (select fcm.child_fin_cat_id
                             from fii_fin_cat_mappings fcm
                             where fcm.child_fin_cat_id = v.fin_category_id )) c,
           fnd_flex_values d,
           fnd_flex_value_sets e
      WHERE a.application_id = 101
      AND   a.id_flex_code = 'GL#'
      AND   a.id_flex_num = c.chart_of_accounts_id
      AND   a.segment_attribute_type = 'GL_ACCOUNT'
      AND   a.attribute_value = 'Y'
      AND   b.application_id = a.application_id
      AND   b.id_flex_code = a.id_flex_code
      AND   b.id_flex_num = a.id_flex_num
      AND   b.application_column_name = a.application_column_name
      AND   d.flex_value_set_id = b.flex_value_set_id
      AND   d.flex_value_id = c.fin_category_id
      AND   e.flex_value_set_id = b.flex_value_set_id;

    CURSOR unmapped_udd1_cur IS
      SELECT fvs.flex_value_set_id, fvs.flex_value_set_name,
             fv.flex_value_id, fv.flex_value
      FROM fnd_flex_values fv,
           fnd_flex_value_sets fvs,
          ( SELECT DISTINCT user_dim1_id flex_value_id
            FROM fii_gl_ccid_dimensions
            MINUS
            SELECT child_value_id flex_value_id
            FROM fii_full_udd1_hiers
            WHERE parent_value_id = child_value_id) udd1
      WHERE fv.flex_value_id = udd1.flex_value_id
      AND   fvs.flex_value_set_id = fv.flex_value_set_id;

    CURSOR unmapped_udd2_cur IS
      SELECT fvs.flex_value_set_id, fvs.flex_value_set_name,
             fv.flex_value_id, fv.flex_value
      FROM fnd_flex_values fv,
           fnd_flex_value_sets fvs,
           ( SELECT distinct user_dim2_id flex_value_id
             From fii_gl_ccid_dimensions
             MINUS
             SELECT child_value_id flex_value_id
             FROM fii_full_udd2_hiers
             WHERE parent_value_id = child_value_id) udd2
     WHERE fv.flex_value_id = udd2.flex_value_id
     AND   fvs.flex_value_set_id = fv.flex_value_set_id;

    CURSOR fc_no_fctype_cur IS
      SELECT b.flex_value_set_id, rpad(e.flex_value_set_name, 40, ' '),
             c.fin_category_id, d.flex_value
      FROM fnd_segment_attribute_values a,
           fnd_id_flex_segments b,
          (select v.fin_category_id, v.chart_of_accounts_id
           from
                (select  distinct fgj.fin_category_id,
                                  fgj.chart_of_accounts_id
                 from  hr_organization_information ccc_tbl,
                     ( select organization_id, org_information2
                       from hr_organization_information
                       where org_information_context = 'Organization Name Alias'
                       and nvl( fnd_date.canonical_to_date( org_information3 ),
                                sysdate + 1 ) <= sysdate
                       and nvl( fnd_date.canonical_to_date( org_information4 ),
                                sysdate + 1 ) >= sysdate
                      ) mgr_tbl,
                       hr_organization_information org,
                       fnd_flex_values    fv1,
                       fnd_flex_values    fv2,
                      (select distinct company_id, cost_center_id, fin_category_id,
                                       chart_of_accounts_id
                       from fii_gl_je_summary_b) fgj,
                       fii_fin_cat_mappings fcm
                 where  ccc_tbl.org_information_context = 'CLASS'
                 and    ccc_tbl.org_information1 = 'CC'
                 and    ccc_tbl.org_information2 = 'Y'
                 and    ccc_tbl.organization_id = mgr_tbl.organization_id (+)
                 and    org.org_information_context = 'Company Cost Center'
                 and    org.organization_id   = ccc_tbl.organization_id
                 and    fv1.flex_value_set_id = org.org_information2
                 and    fv1.flex_value        = org.org_information3
                 and    fv2.flex_value_set_id = org.org_information4
                 and    fv2.flex_value        = org.org_information5
                 and    fv1.flex_value_id        = fgj.company_id
                 and    fv2.flex_value_id        = fgj.cost_center_id
                 and    fcm.child_fin_cat_id  = fgj.fin_category_id ) v
             WHERE NOT EXISTS (select fct.fin_category_id
                        from   fii_fin_cat_type_assgns fct
                        where  fct.fin_category_id = v.fin_category_id))c,
             fnd_flex_values d,
             fnd_flex_value_sets e
      WHERE a.application_id = 101
      AND   a.id_flex_code = 'GL#'
      AND   a.id_flex_num = c.chart_of_accounts_id
      AND   a.segment_attribute_type = 'GL_ACCOUNT'
      AND   a.attribute_value = 'Y'
      AND   b.application_id = a.application_id
      AND   b.id_flex_code = a.id_flex_code
      AND   b.id_flex_num = a.id_flex_num
      AND   b.application_column_name = a.application_column_name
      AND   d.flex_value_set_id = b.flex_value_set_id
      AND   d.flex_value_id = c.fin_category_id
      AND   e.flex_value_set_id = b.flex_value_set_id;

    CURSOR invalid_lookup_cur IS
    SELECT a.lookup_code,
           decode(a.lookup_type,
                  'FII_PSI_ENCUM_TYPES_OBLIGATION', 'Obligation',
                  'FII_PSI_ENCUM_TYPES_COMMITMENT', 'Commitment') lookup_type
    FROM  fnd_lookup_values a
    WHERE a.lookup_type in ( 'FII_PSI_ENCUM_TYPES_OBLIGATION',
                             'FII_PSI_ENCUM_TYPES_COMMITMENT')
    AND a.view_application_id = 450
    AND a.language = userenv('LANG')
    AND upper(a.lookup_code) not in (select upper(encumbrance_type)
                                     from gl_encumbrance_types);

    CURSOR gl_mv_cur IS
      SELECT object_name
      FROM sys.dba_objects
      WHERE object_name IN (  'FII_GL_AGRT_SUM_MV', 'FII_GL_BASE_MAP_MV',
                              'FII_GL_BASE_MV',     'FII_GL_MGMT_CCC_MV',
                              'FII_GL_MGMT_SUM_MV', 'FII_GL_TREND_SUM_MV')
      AND object_type = 'MATERIALIZED VIEW';

    CURSOR ap_mv_cur IS
      SELECT object_name
      FROM sys.dba_objects
      WHERE object_name IN ( 'FII_AP_HATY_XB_MV', 'FII_AP_HCAT_B_MV',
                             'FII_AP_HCAT_IB_MV', 'FII_AP_HCAT_I_MV',
                             'FII_AP_HHIST_B_MV', 'FII_AP_HHIST_IB_MV',
                             'FII_AP_HHIST_I_MV', 'FII_AP_HLIA_IB_MV',
                             'FII_AP_HLIA_I_MV',  'FII_AP_HLWAG_IB_MV',
                             'FII_AP_INV_B_MV',   'FII_AP_IVATY_B_MV',
                             'FII_AP_IVATY_XB_MV','FII_AP_LIA_B_MV',
                             'FII_AP_LIA_IB_MV',  'FII_AP_LIA_I_MV',
                             'FII_AP_LIA_KPI_MV', 'FII_AP_LIWAG_IB_MV',
                             'FII_AP_MGT_KPI_MV', 'FII_AP_PAID_XB_MV',
                             'FII_AP_PAYOL_XB_MV')
      AND object_type = 'MATERIALIZED VIEW';

    CURSOR ar_mv_cur IS
      SELECT object_name
      FROM sys.dba_objects
      WHERE object_name IN ( 'FII_AR_BILLING_ACT_AGRT_MV',
                             'FII_AR_BILLING_ACT_BASE_MV',
                             'FII_AR_DIMENSIONS_MV',
                             'FII_AR_DISPUTES_AGRT_MV',
                             'FII_AR_DISPUTES_BASE_MV',
                             'FII_AR_NET_REC_AGRT_MV',
                             'FII_AR_NET_REC_BASE_MV',
                             'FII_AR_RCT_AGING_AGRT_MV',
                             'FII_AR_RCT_AGING_BASE_MV',
                             'FII_AR_REV_SUM_MV')
      AND object_type = 'MATERIALIZED VIEW';

    CURSOR dim_enabled_cur1 IS
      select rpad(dimension_name, 40), dimension_short_name, dbi_enabled_flag
      from fii_financial_dimensions_v
      where dimension_short_name in ('FII_LOB', 'GL_FII_FIN_ITEM')
      order by (decode (dimension_short_name, 'FII_LOB', 1, 'GL_FII_FIN_ITEM', 2));

    CURSOR dim_enabled_cur2 IS
      select rpad(dimension_name, 40), dimension_short_name, dbi_enabled_flag
      from fii_financial_dimensions_v
      where dimension_short_name in ('FII_COMPANIES', 'HRI_CL_ORGCC',
                                     'FII_USER_DEFINED_1', 'GL_FII_FIN_ITEM')
      order by (decode (dimension_short_name,
                        'FII_COMPANIES',      1,
                        'HRI_CL_ORGCC',       2,
                        'FII_USER_DEFINED_1', 3,
                        'GL_FII_FIN_ITEM',    4));

  BEGIN

    -- Retrive current system time as the start time of the program
    SELECT to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'), sysdate
    INTO l_start_time, l_sys_date
    FROM dual;

    -----------------------------------------------------------------------
    -- Print report header in logfile
    -----------------------------------------------------------------------
    fii_util.put_line(' ');
    fii_util.put_line(
    '+=====================================================================+');
    fii_util.put_line('+  DBI Financials Diagnostics ');
    fii_util.put_line(
  '+  DBI_DIAGNOSTIC module: Daily Business Intelligence Diagnostic Program ');
    fii_util.put_line('+  Current System Time is ' || l_start_time);
    fii_util.put_line(
    '+=====================================================================+');
    fii_util.put_line(' ');
    fii_util.put_line('** Diagnostics Starts ** '|| l_start_time);
    fii_util.put_line
    ('** Start of log messages from DBI Financials Validation ***');
    fii_util.put_line(' ');

    -----------------------------------------------------------------------
    -- Retrieve setup information
    -----------------------------------------------------------------------
    l_prim_curr_code:= BIS_COMMON_PARAMETERS.get_currency_code;
    l_sec_curr_code := BIS_COMMON_PARAMETERS.get_secondary_currency_code;
    l_prim_curr_mau := FII_CURRENCY.get_mau_primary;
    l_sec_curr_mau  := FII_CURRENCY.get_mau_secondary;
    l_user_id 	    := FND_GLOBAL.User_Id;
    l_login_id	    := FND_GLOBAL.Login_Id;
    l_req_id	    := FND_GLOBAL.Conc_Request_Id;

    l_global_start_date  := FND_PROFILE.Value('BIS_GLOBAL_START_DATE');
    l_budget_time_unit   := FND_PROFILE.Value('FII_BUDGET_TIME_UNIT');
    l_forecast_time_unit := FND_PROFILE.Value('FII_FORECAST_TIME_UNIT');

    -- Print setup information to the logfile
    fii_util.put_line(' ');
    fii_util.put_line('Checking for missing setup information...');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    fii_util.put_line('INIT: Global Start Date      = '||l_global_start_date);
    fii_util.put_line('INIT: Primary Currency       = '||l_prim_curr_code);
    fii_util.put_line('INIT: Primary MAU            = '||l_prim_curr_mau);
    fii_util.put_line('INIT: User ID                = '||l_user_id);
    fii_util.put_line('INIT: Login ID               = '||l_login_id);
    fii_util.put_line('INIT: Request ID             = '||l_req_id);
    fii_util.put_line('INIT: Budget Period Type     = '||l_budget_time_unit);
    fii_util.put_line('INIT: Forecast Period Type   = '||l_forecast_time_unit);
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    fii_util.put_line(' ');

    ----------------------------------------------------------------------
    -- If any of the above values is not set (except secondary currency).
    -- Note that we will not error out when secondary currency is not set
    -- because it is optional.
    ----------------------------------------------------------------------
    IF (l_user_id is NULL OR
	l_login_id is NULL OR
	l_req_id is NULL OR
	l_prim_curr_code is NULL OR
 	l_prim_curr_mau is NULL OR
	l_budget_time_unit is NULL OR
	l_forecast_time_unit is NULL) THEN

      fii_util.put_line(
      'DIAGNOSIS: Please make sure all of the above setup information are defined.');

    ELSE

      fii_util.put_line('DIAGNOSIS: All mandatory setup information are defined.');
      fii_util.put_line('DIAGNOSIS: NO ACTION is needed.');
    END IF;

    fii_util.put_line(' ');
    fii_util.put_line('Listing of other setup information...');

    -- Print out secondary currency info to logfile
    fii_util.put_line('INIT: Secondary Currency     = '|| l_sec_curr_code);
    fii_util.put_line('INIT: Secondary MAU          = '|| l_sec_curr_mau);


    -- Print out the Enterprise Calendar setup
    l_period_set_name := bis_common_parameters.get_period_set_name;
    l_period_type     := bis_common_parameters.get_period_type;

    fii_util.put_line('INIT: Enterprise Calendar    = '|| l_period_set_name);
    fii_util.put_line('INIT: Period Type            = '|| l_period_type);

    -- Print out if this is commercial or government install
    l_industry_profile := FND_PROFILE.value('INDUSTRY');

    fii_util.put_line('INIT: Industry profile       = '|| l_industry_profile);

    -- Print out budget/forecast source
    l_budget_source := FND_PROFILE.value('FII_BUDGET_SOURCE');

    fii_util.put_line('INIT: Budget/Forecast Source = '|| l_budget_source);
    fii_util.put_line(' ');

    IF (X_User IS NULL) THEN
      fii_util.put_line('INIT: User Name parameter value is not provided.');
    ELSE
      fii_util.put_line('INIT: Parameter passed       = ' || X_User);
    END IF;

    fii_util.put_line(' ');

    -- Find out database version
    SELECT banner
    INTO l_db_version
    FROM v$version
    WHERE upper(banner) like 'ORACLE%';

    fii_util.put_line('INIT: Database version = ' || l_db_version);

    ----------------------------------------------------------------------
    -- Generic Setup Validations
    ----------------------------------------------------------------------
    ----------------------------------------------------------------------
    -- Check for GL Periods:
    -- 1. Make sure one year before Global Start Date to sysdate have all
    --    defined in Enterprise Calendar.
    ----------------------------------------------------------------------
    fii_util.put_line(' ');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    fii_util.put_line('Performing Check for: GL Periods');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    fii_util.put_line(
    'START CHECK: Looking for GL Periods not defined within start and end range.');
    fii_util.put_line(' ');

    l_day       := to_date(l_global_start_date, 'MM/DD/YYYY');
    l_cnt       := 0;

    BEGIN
      -- Find out the period year of the global start date
      SELECT period_year
      INTO l_year
      FROM gl_periods a
      WHERE a.period_set_name = l_period_set_name
      AND   a.period_type = l_period_type
      AND   a.adjustment_period_flag = 'N'
      AND   l_day between a.start_date and a.end_date;

    EXCEPTION
      WHEN no_data_found THEN
        fii_util.put_line(
        'Global start date is not defined in your Enterprise Calendar.');
    END;

    BEGIN
      SELECT start_date
      INTO l_day
      FROM gl_periods
      WHERE period_set_name = l_period_set_name
      AND period_type = l_period_type
      AND period_num = 1
      AND period_year = l_year - 1;

    EXCEPTION
      WHEN no_data_found THEN
        fii_util.put_line('The start date of the year (' || l_global_start_date || ') prior to global start date is not defined in your Enterprise Calendar.');

    END;

    -- Storing the year start day a year prior to global start date
    l_start_day := l_day;

    fii_util.put_line('Start Range: ' || to_char(l_day, 'DD/MM/YYYY') );
    fii_util.put_line('  End Range: ' || to_char(l_sys_date, 'DD/MM/YYYY'));

    WHILE l_day <= l_sys_date LOOP
      OPEN ent_period_cur(l_day);
      FETCH ent_period_cur INTO l_dummy;

      IF ent_period_cur%NOTFOUND THEN
        IF (l_cnt = 0) THEN
          fii_util.put_line(' ');
          fii_util.put_line('General Ledger Date');
          fii_util.put_line('------------------------------------------');
          l_cnt := l_cnt + 1;
        END IF;
        fii_util.put_line(to_char(l_day, 'DD/MM/YYYY'));
      END IF;

      CLOSE ent_period_cur;
      l_day := l_day + 1;
    END LOOP;

    fii_util.put_line(' ');
    IF (l_cnt = 0) THEN
      -- All days between one year prior to global start date and sysdate have
      -- been defined in the Enterprise Calendar
      fii_util.put_line('All GL Periods between '||to_char(l_start_day, 'DD/MM/YYYY') ||
                        ' and '||to_char(l_sys_date, 'DD/MM/YYYY') ||
                        ' have been defined.  ');
      fii_util.put_line('DIAGNOSIS: GL Periods are valid');
      fii_util.put_line('DIAGNOSIS: NO ACTION is needed.');

    ELSE
      -- Print a message asking customer to define missing dates found
      fii_util.put_line(
      'DIAGNOSIS: Please define the above dates in your Enterprise Calendar.');
    END IF;

    fii_util.put_line(' ');
    fii_util.put_line('END CHECK: Looking for GL Periods not defined.');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');

    ----------------------------------------------------------------------
    -- Check for GL Periods:
    -- 2. Also check that Fiscal Year are defined correctly
    ----------------------------------------------------------------------
    fii_util.put_line(
    'START CHECK: Fiscal Year contains valid number of weeks.');
    fii_util.put_line(' ');

    -- Initialize l_min_start_date to be the minimum start date of the fiscal year
    BEGIN

    SELECT year_start_date
    INTO   l_min_start_date
    FROM   gl_periods
    WHERE period_set_name = l_period_set_name
    AND   period_type = l_period_type
    AND   period_year = l_year - 1
    AND   period_num = 1
    AND   adjustment_period_flag = 'N';

    l_cnt       := 0;
    WHILE (l_min_start_date is NOT NULL and l_min_start_date <=l_sys_date) LOOP

      OPEN fiscal_year_cur(l_year);
      FETCH fiscal_year_cur INTO l_min_start_date, l_max_end_date;
      l_fiscal_year_day  := (l_max_end_date - l_min_start_date) +1;

      IF (l_fiscal_year_day < 352 OR l_fiscal_year_day > 379) THEN
        l_cnt := l_cnt + 1;
        fii_util.put_line('FISCAL YEAR: '|| l_year || ' contains '||
                          round(l_fiscal_year_day/7, 0) || ' weeks.');

      ELSE
        fii_util.put_line('FISCAL YEAR: '|| l_year || ' contains '||
                          round(l_fiscal_year_day/7, 0) ||
                          ' weeks and is OK.');
      END IF;

      CLOSE fiscal_year_cur;
      l_year := l_year + 1;

    END LOOP;

    fii_util.put_line(' ');
    IF (l_cnt > 0) THEN
        fii_util.put_line('DIAGNOSIS: Please make sure that the number of weeks in your Fiscal Years are between the ranges of 50 and 54 weeks.  Otherwise, the DBI Update Time Dimension program will have issues.');

    ELSE
        fii_util.put_line(
        'DIAGNOSIS: All Fiscal Years are between the ranges of 50 and 54 weeks');
        fii_util.put_line('DIAGNOSIS: NO ACTION is needed.');
    END IF;

    EXCEPTION
      WHEN no_data_found THEN
      fii_util.put_line('The year prior to the global start date is not defined in your Enterprise Calendar.');

    END;


    fii_util.put_line(' ');
    fii_util.put_line('END CHECK: Fiscal Year contains valid number of weeks.');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');

    ----------------------------------------------------------------------
    -- Check for Master Value Set.
    -- For each dimension, verify that we have a master value set assigned to it.
    ----------------------------------------------------------------------
    fii_util.put_line(' ');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    fii_util.put_line('Performing Check for: Master value set assignment.');

    -- Find out all the enabled dimensions and check if we
    -- have done mapping from local value sets to master value set
    OPEN enabled_dim_cur;
    LOOP
      FETCH enabled_dim_cur INTO l_dim_name, l_dim_short_name;
      EXIT WHEN enabled_dim_cur%NOTFOUND;

      fii_util.put_line(' ');
      fii_util.put_line('--------------------------------------------------');
      fii_util.put_line('Dimension Enabled: '|| l_dim_name);
      fii_util.put_line('--------------------------------------------------');

      -- Check if we have unmapped local value set for this dimension
      l_cnt := FII_SETUP_VAL_C.detect_unmapped_local_vs(l_dim_short_name);

      fii_util.put_line(' ');
      IF l_cnt > 0 THEN
        fii_util.put_line('DIAGNOSIS: Please map the above Local Value Sets to a Master Value Set');

      ELSE
        fii_util.put_line(
        'DIAGNOSIS: All Local Value Sets have been mapped to Master Value Sets');
        fii_util.put_line('DIAGNOSIS: NO ACTION is needed.');
      END IF;

    END LOOP;
    CLOSE enabled_dim_cur;

    fii_util.put_line(' ');
    fii_util.put_line('END CHECK: Master value set assignment.');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');

    ----------------------------------------------------------------------
    -- Check for Financial Category and Type Setup
    ----------------------------------------------------------------------
    fii_util.put_line(' ');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    fii_util.put_line(
    'Performing Check for: Financial Category and Type Setup');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    fii_util.put_line('START CHECK: Financial Category Types');

    -- Find out if we have at least one node assigned per financial category type
    l_cnt := 0;
    OPEN fin_type_cur;
    LOOP
      FETCH fin_type_cur INTO l_fin_type_name;
      EXIT WHEN fin_type_cur%NOTFOUND;

      IF (l_cnt = 0) THEN
        fii_util.put_line(' ');
        fii_util.put_line('Financial Category Type');
        fii_util.put_line('--------------------------------------------------');
        l_cnt := l_cnt + 1;
      END IF;
      fii_util.put_line(l_fin_type_name);
    END LOOP;
    CLOSE fin_type_cur;

    fii_util.put_line(' ');
    IF l_cnt > 0 THEN
      fii_util.put_line(
      'DIAGNOSIS: There are no existing nodes for the above data type(s).');

    ELSE
      fii_util.put_line(
      'DIAGNOSIS: All Financial Category have associated data types (Revenue, COGS,etc.)');
      fii_util.put_line('DIAGNOSIS: NO ACTION is needed.');
    END IF;

    fii_util.put_line(' ');
    fii_util.put_line('END CHECK: Financial Category Dimension Types.');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');

    ----------------------------------------------------------------------
    -- Check for Duplicate Organization Setup
    -- Validate if there are more than one CCC for each company cost center
    ----------------------------------------------------------------------
    fii_util.put_line(' ');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    fii_util.put_line('Performing Check for: More than one Organization for a Company Cost Center');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    fii_util.put_line(
    'START CHECK: Duplicate Organization Assignments for Company Cost Center');

    -- Find out if we have duplicate ccc org assigned to a company cost center
    l_cnt := FIND_DUP_CCC_ORG;

    fii_util.put_line(' ');
    IF (l_cnt > 0 or l_cnt = -1)THEN
      fii_util.put_line('DIAGNOSIS: Please resolve the above duplicate Organization and Company Cost Center combinations.');

    ELSE
      fii_util.put_line(
      'DIAGNOSIS: No duplicate Organization - Company Cost Centers found');
      fii_util.put_line('DIAGNOSIS: NO ACTION is needed.');
    END IF;

    fii_util.put_line(' ');
    fii_util.put_line(
    'END CHECK: Duplicate Organization Assignments for Company Cost Center.');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');

    ----------------------------------------------------------------------
    -- Check for Missing Organization Setup
    -- Validate if there are company cost centers with no org assigned
    ----------------------------------------------------------------------
    fii_util.put_line(' ');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    fii_util.put_line(
    'Performing Check for Organization - Company Cost Center Assignments');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    fii_util.put_line('START CHECK: ORG - Company Cost Center Assignments.');

    -- Find out if we have company cost centers with no org assigned
    l_cnt := 0;
    OPEN no_org_cur;
    LOOP
      FETCH no_org_cur INTO l_co_name, l_co_id, l_cc_name, l_cc_id;
      EXIT WHEN no_org_cur%NOTFOUND;

      IF (l_cnt = 0) THEN
        fii_util.put_line(' ');
        fii_util.put_line(
        'Company     Company ID  Cost Center    Cost Center ID ');
        fii_util.put_line(
        '-------     ----------  -----------    -------------- ');
        l_cnt := l_cnt + 1;
      END IF;
      FII_UTIL.write_log(l_co_name || '  '|| l_co_id || '  '||
                         l_cc_name || '  '|| l_cc_id);
    END LOOP;
    CLOSE no_org_cur;

    fii_util.put_line(' ');
    IF (l_cnt > 0 or l_cnt = -1)THEN
      fii_util.put_line('DIAGNOSIS: Please assign an Organization to the Company Cost Centers listed above.');

    ELSE
      fii_util.put_line('DIAGNOSIS: No missing Organization - Company Cost Centers found');
      fii_util.put_line('DIAGNOSIS: NO ACTION is needed.');
    END IF;

    fii_util.put_line(' ');
    fii_util.put_line('END CHECK: ORG - Company Cost Center Assignments.');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');

    ----------------------------------------------------------------------
    -- Validate if there are company cost centers which only has company
    -- assigned but cost center is null
    ----------------------------------------------------------------------
    fii_util.put_line(' ');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    fii_util.put_line(
    'Performing Check for Company Cost Center Organizations with only Company assigned');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    fii_util.put_line('START CHECK: CCC Org with no Cost Center Assigned.');

    -- Find out if we have company cost centers with no cost center assigned
    l_cnt := 0;
    OPEN org_no_cc_cur;
    LOOP
      FETCH org_no_cc_cur INTO l_co_id, l_co_name, l_org_id, l_org_name;
      EXIT WHEN org_no_cc_cur%NOTFOUND;

      IF (l_cnt = 0) THEN
        fii_util.put_line(' ');
        fii_util.put_line(
        'Company ID  Company    Organization ID   Organization');
        fii_util.put_line(
        '-------     ----------  -----------    -------------- ');
        l_cnt := l_cnt + 1;
      END IF;
      FII_UTIL.write_log(l_co_id  || '  '|| l_co_name || '  '||
                         l_org_id || '  '|| l_org_name);
    END LOOP;
    CLOSE org_no_cc_cur;

    fii_util.put_line(' ');
    IF (l_cnt > 0 or l_cnt = -1)THEN
      fii_util.put_line('DIAGNOSIS: Please assign Cost Centers to the above listed Organizations except for the place holder organizations.');

    ELSE
      fii_util.put_line('DIAGNOSIS: No Company Cost Center Organizations with missing Cost Center values found.');
      fii_util.put_line('DIAGNOSIS: NO ACTION is needed.');
    END IF;

    fii_util.put_line(' ');
    fii_util.put_line('END CHECK: CCC Org with no Cost Center Assigned.');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');

    ----------------------------------------------------------------------
    -- Validate that company cost center organizations have valid manager
    -- assigned to it.
    ----------------------------------------------------------------------
    fii_util.put_line(' ');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    fii_util.put_line('Performing Check for Manager Assignments');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    fii_util.put_line('START CHECK: Valid Manager Assignments.');

    -- Find out if manager assignment dates are current or not
    l_cnt := 0;
    OPEN mgr_assgn_cur;
    LOOP
      FETCH mgr_assgn_cur INTO l_co_name, l_cc_name, l_org_id, l_org_name;
      EXIT WHEN mgr_assgn_cur%NOTFOUND;

      IF (l_cnt = 0) THEN
        fii_util.put_line(' ');
        fii_util.put_line(
        'The following Company Cost Center Organizations does not have a valid manager assigned:');
        fii_util.put_line(
        'Company   Cost Center  Org ID   Organization Name ');
        fii_util.put_line(
        '--------- ------------ -------- -----------------');
        l_cnt := l_cnt + 1;
      END IF;
      fii_util.put_line(l_co_name || '  ' || l_cc_name || '  ' ||
                        l_org_id  || '  ' || l_org_name);
    END LOOP;
    CLOSE mgr_assgn_cur;

    fii_util.put_line(' ');
    IF (l_cnt > 0 or l_cnt = -1)THEN
      fii_util.put_line('DIAGNOSIS: Please make sure we have valid managers assigned to the above Company Cost Center Organizations.');

    ELSE
      fii_util.put_line(
      'DIAGNOSIS: All Company Cost Center organizations with data have valid managers assigned');
      fii_util.put_line('DIAGNOSIS: NO ACTION is needed.');
    END IF;

    fii_util.put_line(' ');
    fii_util.put_line('END CHECK: Valid Manager Assignments');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');

    fii_util.put_line(' ');
    fii_util.put_line('START CHECK: Valid Manager Assignment HR Orgs.');

    -- Find out if manager assigned to HR organization has a valid
    -- effective date or not
    l_cnt := 0;
    OPEN mgr_eff_cur;
    LOOP
      FETCH mgr_eff_cur INTO l_mgr, l_org_name, l_eff_end;
      EXIT WHEN mgr_eff_cur%NOTFOUND;

      IF (l_cnt = 0) THEN
        fii_util.put_line(' ');
      END IF;

      fii_util.put_line('MANAGER: '''|| l_mgr || ''' assigned to '''||
                        l_org_name || ''' is not current in HR, END DATE = '||
                        l_eff_end );
      l_cnt := l_cnt + 1;

    END LOOP;
    CLOSE mgr_eff_cur;

    fii_util.put_line(' ');
    IF (l_cnt > 0 or l_cnt = -1)THEN
      fii_util.put_line('DIAGNOSIS: Please check the managers found above for valid employement dates.');

    ELSE
      fii_util.put_line('DIAGNOSIS: All managers are active employees');
      fii_util.put_line('DIAGNOSIS: NO ACTION is needed.');
    END IF;

    fii_util.put_line(' ');
    fii_util.put_line('END CHECK: Valid Manager Assignments HR Orgs');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');

    -- Find out if manager assigned in HR organization has a valid status
    -- in HR or not
    fii_util.put_line(' ');
    fii_util.put_line('START CHECK Valid Manager Assignment HR Status');

    -- Find out if manager assignment dates are current or not
    l_cnt := 0;
    OPEN mgr_status_cur;
    LOOP
      FETCH mgr_status_cur INTO l_mgr, l_status;
      EXIT WHEN mgr_status_cur%NOTFOUND;

      IF (l_cnt = 0) THEN
        fii_util.put_line(' ');
      END IF;

      fii_util.put_line('MANAGER: ' || l_mgr ||
                        ' is not an active employee in HR, STATUS = ' ||
                        l_status);
      l_cnt := l_cnt + 1;

    END LOOP;
    CLOSE mgr_status_cur;

    fii_util.put_line(' ');
    IF (l_cnt > 0 or l_cnt = -1)THEN
      fii_util.put_line('DIAGNOSIS: Please check the managers found above for valid employment status.');

    ELSE
      fii_util.put_line('DIAGNOSIS: All managers in HR are active');
      fii_util.put_line('DIAGNOSIS: NO ACTION is needed.');
    END IF;

    fii_util.put_line(' ');
    fii_util.put_line('END CHECK: Valid Manager Assignment HR Status');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');

    ----------------------------------------------------------------------
    -- Validate if we have any transaction where the corresponding Company
    -- Cost Centers does not have a manager assigned to it yet.
    ----------------------------------------------------------------------
    fii_util.put_line(' ');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    fii_util.put_line('Performing Check for: CCC has transactions but no manager assigned.');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    -- Check if we have any transactions where CCC org is not yet mapped.
    fii_util.put_line('START CHECK: CCC has transactions but no manager assigned.');
    fii_util.put_line(' ');

    -- Find out if we have CCC that has transactions but no manager assigned
    l_cnt := 0;
    OPEN trans_ccc_no_mgr_cur;

    LOOP
      FETCH trans_ccc_no_mgr_cur INTO l_org_id, l_org_name, l_co_id, l_co_name,
                                      l_cc_id, l_cc_name;
      EXIT WHEN trans_ccc_no_mgr_cur%NOTFOUND;

      IF (l_cnt = 0) THEN
        fii_util.put_line('The following Company Cost Center Organization has some GL transactions but their corresponding Company Cost Center Organization does not have a manager assigned to it.');
        fii_util.put_line(
        'Org ID  Organization           Company ID  Company  Cost Center ID  Cost Center');
        fii_util.put_line(
        '------  ---------------------  ----------  -------  --------------  -----------');
        l_cnt := l_cnt + 1;
      END IF;
      fii_util.put_line(l_org_id  || ' '|| l_org_name || ' ' || l_co_id || ' ' ||
                        l_co_name || ' '|| l_cc_id    || ' ' || l_cc_name);
    END LOOP;

    CLOSE trans_ccc_no_mgr_cur;

    fii_util.put_line(' ');
    IF (l_cnt > 0 or l_cnt = -1)THEN
        fii_util.put_line('The above Organization has some GL transactions but their corresponding Organization does not have a manager assigned to it.  Please review.');

    ELSE
      fii_util.put_line('DIAGNOSIS: All company and cost center combinations with some GL transactions have a manager assigned to it already.');
      fii_util.put_line('DIAGNOSIS: NO ACTION is needed.');
    END IF;

    fii_util.put_line(' ');
    fii_util.put_line('END CHECK: CCC has transactions but no manager assigned.');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');

    ----------------------------------------------------------------------
    -- Validate if we have any transaction where the corresponding Financial
    -- Categories not mapped using FDHM
    ----------------------------------------------------------------------
    fii_util.put_line(' ');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    fii_util.put_line('Performing Check for: Transactions with FC not mapped');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    -- Check if there is any transactions where the corresponding FC is not mapped
    fii_util.put_line('START CHECK: Transactions with FC not mapped');
    fii_util.put_line(' ');

    -- Find out if we have transactions with FC not mapped
    l_cnt := 0;
    OPEN trans_no_fc_cur;

    LOOP
      FETCH trans_no_fc_cur INTO l_vs_id, l_vs_name, l_fc_id, l_fc_name;
      EXIT WHEN trans_no_fc_cur%NOTFOUND;

      IF (l_cnt = 0) THEN
        fii_util.put_line('The following Financial Categories has some GL transactions but their corresponding Financial Categories are not set up.');
        fii_util.put_line(
        'FC Value Set ID FC Value Set Name            FC ID    Financial Category');
        fii_util.put_line(
        '--------------- ---------------------------- -----    ---------------------');
        l_cnt := l_cnt + 1;
      END IF;
      fii_util.put_line(l_vs_id || ' ' || l_vs_name || ' ' || l_fc_id || ' ' || l_fc_name);
    END LOOP;

    CLOSE trans_no_fc_cur;

    fii_util.put_line(' ');
    IF (l_cnt > 0 or l_cnt = -1)THEN
      fii_util.put_line('DIAGNOSIS: The financial category in the above list have been found with a transactions in GL but have not setup the corresponding Financial Category yet.  Please review.');

    ELSE
      fii_util.put_line('DIAGNOSIS: All financial categories with a transactions have been mapped to a corresponding Financial Category');
      fii_util.put_line('DIAGNOSIS: NO ACTION is needed.');
    END IF;

    fii_util.put_line(' ');
    fii_util.put_line('END CHECK: Transactions with FC not mapped');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');

    ----------------------------------------------------------------------
    -- Validate if we have any UDD1 values that has not been mapped
    ----------------------------------------------------------------------
    select dbi_enabled_flag
    into l_udd_enabled_flag
    from fii_financial_dimensions_v
    where dimension_short_name = 'FII_USER_DEFINED_1';

    IF (l_udd_enabled_flag = 'Y') THEN
      fii_util.put_line(' ');
      fii_util.put_line(
      '+---------------------------------------------------------------------+');
      fii_util.put_line('Performing Check for: UDD1 setup in FDHM');
      fii_util.put_line(
      '+---------------------------------------------------------------------+');
      -- Check user defined dimension 1 hierarhichy setup
      fii_util.put_line('START CHECK: User-defined dimension 1 that has not been mapped in FDHM');
      -- Find out if we have transactions with UDD1 not mapped
      l_cnt := 0;
      OPEN unmapped_udd1_cur;

      LOOP
        FETCH unmapped_udd1_cur INTO l_vs_id, l_vs_name, l_udd1_id, l_udd1_name;
        EXIT WHEN unmapped_udd1_cur%NOTFOUND;

        IF (l_cnt = 0) THEN
          fii_util.put_line('The following User-defined dimension 1 values have not been mapped in the user-defined dimension hierarchy.');
          fii_util.put_line(
          'UDD1 Value Set ID UDD1 Value Set Name            UDD1 ID    UDD1');
          fii_util.put_line(
          '----------------- ----------------------------   -------    ---------------------');
          l_cnt := l_cnt + 1;
        END IF;
        fii_util.put_line(l_vs_id || ' ' || l_vs_name || ' ' || l_udd1_id || ' ' || l_udd1_name);
      END LOOP;

      CLOSE unmapped_udd1_cur;

      fii_util.put_line(' ');
      IF (l_cnt > 0 or l_cnt = -1)THEN
        fii_util.put_line('DIAGNOSIS: The user-defined dimension 1 values in the above list have not been mapped in the UDD1 hierarchy yet.  Please review.');

      ELSE
        fii_util.put_line('DIAGNOSIS: All user-defined dimension 1 values in the above list have been mapped in the UDD1 hierarchy.');
        fii_util.put_line('DIAGNOSIS: NO ACTION is needed.');
      END IF;

      fii_util.put_line(' ');

      fii_util.put_line(' ');
      fii_util.put_line('END CHECK: User-defined dimension 1 set up in FDHM');
      fii_util.put_line(
      '+---------------------------------------------------------------------+');
   ELSE
      fii_util.put_line(' ');
      fii_util.put_line(
      '+---------------------------------------------------------------------+');
     fii_util.put_line('User-defined dimension 1 is not enabled. ');
     fii_util.put_line('Skipping the check for UDD1 setup.');
      fii_util.put_line(' ');
   END IF;

    ----------------------------------------------------------------------
    -- Validate if we have any UDD2 values that has not been mapped
    ----------------------------------------------------------------------
    select dbi_enabled_flag
    into l_udd_enabled_flag
    from fii_financial_dimensions_v
    where dimension_short_name = 'FII_USER_DEFINED_2';

    IF (l_udd_enabled_flag = 'Y') THEN
      fii_util.put_line(' ');
      fii_util.put_line(
      '+---------------------------------------------------------------------+');
      fii_util.put_line('Performing Check for: UDD2 setup in FDHM');
      fii_util.put_line(
      '+---------------------------------------------------------------------+');
      -- Check user defined dimension 2 hierarhichy setup
      fii_util.put_line('START CHECK: User-defined dimension 2 that has not been mapped in FDHM');

      -- Find out if we have transactions with UDD2 not mapped
      l_cnt := 0;
      OPEN unmapped_udd2_cur;

      LOOP
        FETCH unmapped_udd2_cur INTO l_vs_id, l_vs_name, l_udd2_id, l_udd2_name;
        EXIT WHEN unmapped_udd2_cur%NOTFOUND;

        IF (l_cnt = 0) THEN
          fii_util.put_line('The following User-defined dimension 2 values have not been mapped in the user-defined dimension hierarchy.');
          fii_util.put_line(
          'UDD2 Value Set ID UDD2 Value Set Name            UDD2 ID    UDD2');
          fii_util.put_line(
          '----------------- ----------------------------   -------    ---------------------');
          l_cnt := l_cnt + 1;
        END IF;
        fii_util.put_line(l_vs_id || ' ' || l_vs_name || ' ' || l_udd2_id || ' ' || l_udd2_name);
      END LOOP;

      CLOSE unmapped_udd2_cur;

      fii_util.put_line(' ');
      IF (l_cnt > 0 or l_cnt = -1)THEN
        fii_util.put_line('DIAGNOSIS: The user-defined dimension 2 values in the above list have not been mapped in the UDD2 hierarchy yet.  Please review.');

      ELSE
        fii_util.put_line('DIAGNOSIS: All user-defined dimension 2 values in the above list have been mapped in the UDD2 hierarchy.');
        fii_util.put_line('DIAGNOSIS: NO ACTION is needed.');
      END IF;

      fii_util.put_line(' ');

      fii_util.put_line(' ');
      fii_util.put_line('END CHECK: User-defined dimension 2 set up in FDHM');
      fii_util.put_line(
      '+---------------------------------------------------------------------+');
   ELSE
      fii_util.put_line(' ');
      fii_util.put_line(
      '+---------------------------------------------------------------------+');
     fii_util.put_line('User-defined dimension 2 is not enabled. ');
     fii_util.put_line('Skipping the check for UDD2 setup.');
      fii_util.put_line(' ');
   END IF;

    ----------------------------------------------------------------------
    -- Validate if we have any Financial Category without a financial
    -- category type assigned.
    ----------------------------------------------------------------------
    fii_util.put_line(' ');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    fii_util.put_line('Performing Check for: Financial Category without a financial category type.');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    -- Check the user security profile
    fii_util.put_line('START CHECK: Financial Category without a financial category type.');
    -- Find out if we have transactions with FC not mapped
    l_cnt := 0;
    OPEN fc_no_fctype_cur;

    LOOP
      FETCH fc_no_fctype_cur INTO l_vs_id, l_vs_name, l_fc_id, l_fc_name;
      EXIT WHEN fc_no_fctype_cur%NOTFOUND;

      IF (l_cnt = 0) THEN
        fii_util.put_line('The following Financial Categories has some GL transactions but their corresponding financial categoriy types are not set up.');
        fii_util.put_line(
        'FC Value Set ID FC Value Set Name            FC ID    Financial Category');
        fii_util.put_line(
        '--------------- ---------------------------- -----    ---------------------');
        l_cnt := l_cnt + 1;
      END IF;
      fii_util.put_line(l_vs_id || ' ' || l_vs_name || ' ' || l_fc_id || ' ' || l_fc_name);
    END LOOP;

    CLOSE fc_no_fctype_cur;

    fii_util.put_line(' ');
    IF (l_cnt > 0 or l_cnt = -1)THEN
      fii_util.put_line('DIAGNOSIS: The financial category in the above list have been found with a transactions in GL but have not setup the corresponding Financial Category yet.  Please review.');

    ELSE
      fii_util.put_line('DIAGNOSIS: All financial categories with a transactions have has their corresponding financial category and financial category types set up');
      fii_util.put_line('DIAGNOSIS: NO ACTION is needed.');
    END IF;

    fii_util.put_line(' ');

    fii_util.put_line(' ');
    fii_util.put_line('END CHECK: Financial Category without a financial category type.');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');

    ----------------------------------------------------------------------
    -- Validate encumbrance type mappings for PSI customers (R12 only)
    ----------------------------------------------------------------------
    SELECT count(*)
    INTO l_cnt
    FROM sys.dba_objects
    WHERE object_name = 'FII_ENCUM_TYPE_MAPPINGS';

    IF ((l_cnt > 0) AND (l_industry_profile = 'G')) THEN
      fii_util.put_line(' ');
      fii_util.put_line(
      '+---------------------------------------------------------------------+');
      fii_util.put_line('Performing Check for: Encumbrance Type Mappings');
      fii_util.put_line(
      '+---------------------------------------------------------------------+');
      -- Check if encumbrance type mappings have been defined.
      fii_util.put_line('START CHECK: Encumbrance Type Mappings');

      SELECT count(*)
      INTO l_cnt
      FROM  fnd_lookup_values a,
            gl_encumbrance_types b
      WHERE a.lookup_type in ( 'FII_PSI_ENCUM_TYPES_OBLIGATION',
                               'FII_PSI_ENCUM_TYPES_COMMITMENT')
      AND a.view_application_id = 450
      AND a.language = userenv('LANG')
      AND upper(a.lookup_code) = upper(b.encumbrance_type);

      IF (l_cnt = 0) THEN
        fii_util.put_line('DIAGNOSIS: Encumbrance Type Mappings has not been defined yet.  Please define them before running the Funds Management reports.');
      ELSE
        fii_util.put_line('DIAGNOSIS: Some valid encumbrance type mappings have been defined.  NO ACTION is needed.');
      END IF;

      -- Check for invalid encumbrance type mappings defined
      l_cnt := 0;
      OPEN invalid_lookup_cur;
      LOOP
        FETCH invalid_lookup_cur INTO l_lookup_code, l_lookup_type;
        EXIT WHEN invalid_lookup_cur%NOTFOUND;

        IF (l_cnt = 0) THEN
          fii_util.put_line(
          'DIAGNOSIS: Invalid lookup codes found in the encumbrance type mappings. ');
          fii_util.put_line('Lookup Type     Lookup Code ');
          fii_util.put_line('-----------     -----------');
          l_cnt := l_cnt + 1;
        END IF;

        fii_util.put_line(l_lookup_code ||'  ' || l_lookup_type);
      END LOOP;
      CLOSE invalid_lookup_cur;

      IF (l_cnt = 0) THEN
        fii_util.put_line('DIAGNOSIS: No invalid lookup codes found in the encumbrance type mappings.  NO ACTION is needed.');
      END IF;

      fii_util.put_line(' ');
      fii_util.put_line('END CHECK: Encumbrance Type Mappings');
      fii_util.put_line(
      '+---------------------------------------------------------------------+');
    END IF;

    ----------------------------------------------------------------------
    -- Validate if the MV has any data
    ----------------------------------------------------------------------
    fii_util.put_line(' ');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    fii_util.put_line(
    'Performing Check to see if MVs needed for FII reports have data.');

    -- Find out if MV has data for FII reports
    -- MVs for GL
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    fii_util.put_line('START CHECK: Data in GL MV needed for FII reports');

    l_cnt := 0;
    OPEN gl_mv_cur;
    LOOP
      FETCH gl_mv_cur INTO l_mv_name;
      EXIT WHEN gl_mv_cur%NOTFOUND;

      l_stmt := 'SELECT COUNT(*) FROM '|| l_mv_name;
      execute immediate l_stmt INTO l_mv_row_ct;

      IF (l_mv_row_ct = 0) THEN
        l_cnt := l_cnt + 1;
        fii_util.put_line('  The MV '''||l_mv_name||''' has no data.');
      END IF;
    END LOOP;
    CLOSE gl_mv_cur;

    IF (l_cnt = 0) THEN
     fii_util.put_line('DIAGNOSIS:All GL MVs have data. NO ACTION is needed.');
    ELSE
     fii_util.put_line(
       'DIAGNOSIS: Please try to refresh the above MV(s) manually.');
    END IF;

    fii_util.put_line(' ');
    fii_util.put_line('END CHECK: Data in GL MV needed for FII reports');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');

    -- MVs for AP
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    fii_util.put_line('START CHECK: Data in AP MV needed for FII reports');

    l_cnt := 0;
    OPEN ap_mv_cur;
    LOOP
      FETCH ap_mv_cur INTO l_mv_name;
      EXIT WHEN ap_mv_cur%NOTFOUND;

      l_stmt := 'SELECT COUNT(*) FROM '|| l_mv_name;
      execute immediate l_stmt INTO l_mv_row_ct;

      IF (l_mv_row_ct = 0) THEN
        l_cnt := l_cnt + 1;
        fii_util.put_line('  The MV '''|| l_mv_name || ''' has no data.');
      END IF;
    END LOOP;
    CLOSE ap_mv_cur;

    IF (l_cnt = 0) THEN
     fii_util.put_line('DIAGNOSIS:All AP MVs have data. NO ACTION is needed.');
    ELSE
     fii_util.put_line(
       'DIAGNOSIS: Please try to refresh the above MV(s) manually.');
    END IF;

    fii_util.put_line(' ');
    fii_util.put_line('END CHECK: Data in AP needed for FII reports');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');

    -- MVs for AR
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    fii_util.put_line('START CHECK: Data in AR MV needed for FII reports');

    l_cnt := 0;
    OPEN ar_mv_cur;
    LOOP
      FETCH ar_mv_cur INTO l_mv_name;
      EXIT WHEN ar_mv_cur%NOTFOUND;

      l_stmt := 'SELECT COUNT(*) FROM '|| l_mv_name;
      execute immediate l_stmt INTO l_mv_row_ct;

      IF (l_mv_row_ct = 0) THEN
        l_cnt := l_cnt + 1;
        fii_util.put_line('  The MV '''|| l_mv_name || ''' has no data.');
      END IF;
    END LOOP;
    CLOSE ar_mv_cur;

    IF (l_cnt = 0) THEN
     fii_util.put_line('DIAGNOSIS:All AR MVs have data. NO ACTION is needed.');
    ELSE
     fii_util.put_line(
       'DIAGNOSIS: Please try to refresh the above MV(s) manually.');
    END IF;

    fii_util.put_line(' ');
    fii_util.put_line('END CHECK: Data in AR needed for FII reports');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');

    ----------------------------------------------------------------------
    -- Validate Dimension for Dashboards that are enabled
    ----------------------------------------------------------------------
    fii_util.put_line(' ');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    fii_util.put_line('Performing Dashboard Check for:Dashboard Requirements');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    fii_util.put_line(
    'START CHECK: Profit and Loss, Profit and Loss by Manager');

    -- Check if Profit and Loss, Profit and Loss by Manager Dashboard
    -- is enabled or not
    SELECT max(implementation_flag)
    INTO l_enabled_flag
    FROM bis_obj_properties
    WHERE object_name in ('FII_GL_PROFIT_AND_LOSS_PAGE', 'FII_PL_BY_MGR_PAGE')
    and object_type = 'PAGE';

    fii_util.put_line('Dashboard implementation flag = ' || l_enabled_flag );

    -- Find out dimensions enabled for each dashboard
    IF (l_enabled_flag = 'Y') THEN
      l_cnt := 0;
      l_dashboard_warn_flag := 'N';

      OPEN dim_enabled_cur1;

      LOOP
        FETCH dim_enabled_cur1
        INTO l_dim_name, l_dim_short_name, l_enabled_flag;

        EXIT WHEN dim_enabled_cur1%NOTFOUND;

        IF (l_cnt = 0) THEN
          fii_util.put_line(' ');
          fii_util.put_line('Supporting Dimensions     Enabled / Disabled? ');
          fii_util.put_line('------------------------- --------------------');
          l_cnt := l_cnt + 1;
        END IF;
        fii_util.put_line(l_dim_name || '  '|| l_enabled_flag);

        -- Check if the required dimension is disabled
        IF (l_dim_short_name = 'GL_FII_FIN_ITEM' and l_enabled_flag = 'N') THEN
          l_dashboard_warn_flag := 'Y';
        END IF;
      END LOOP;

      CLOSE dim_enabled_cur1;

      fii_util.put_line(' ');
      IF (l_dashboard_warn_flag = 'Y') THEN
        fii_util.put_line('DIAGNOSIS: The Financial Category Dimension is required for the Profit and Loss Dashboards.  Please make sure it is enabled.');

      ELSE
        fii_util.put_line('DIAGNOSIS: The required dimension (Financial Category) has been enabled for the Profit and Loss Dashboards.');
        fii_util.put_line('DIAGNOSIS: NO ACTION is needed.');
      END IF;

    ELSE
      fii_util.put_line('Skipping check for Profit and Loss, Profit and Loss by Manager page as they are not implementated.');
    END IF;

    fii_util.put_line(' ');
    fii_util.put_line(
    'END CHECK: Profit and Loss, Profit and Loss by Manager.');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    fii_util.put_line(' ');

    fii_util.put_line('START CHECK: Expense Management.');

    -- Check if Expense Management Dashboard is enabled or not
    SELECT implementation_flag
    INTO l_enabled_flag
    FROM bis_obj_properties
    WHERE object_name  = 'FII_EXP_MGMT_PAGE_P'
    and object_type = 'PAGE';

    fii_util.put_line('Dashboard implementation flag = ' || l_enabled_flag );

    -- Find out dimensions enabled for each dashboard
    IF (l_enabled_flag = 'Y') THEN
      l_cnt := 0;
      l_dashboard_warn_flag := 'N';

      OPEN dim_enabled_cur1;

      LOOP
        FETCH dim_enabled_cur1
        INTO l_dim_name, l_dim_short_name, l_enabled_flag;

        EXIT WHEN dim_enabled_cur1%NOTFOUND;

        IF (l_cnt = 0) THEN
          fii_util.put_line(' ');
          fii_util.put_line('Supporting Dimensions     Enabled / Disabled? ');
          fii_util.put_line('------------------------- --------------------');
          l_cnt := l_cnt + 1;
        END IF;
        fii_util.put_line(l_dim_name || '  '|| l_enabled_flag);

        -- Check if the required dimension is disabled
        IF (l_dim_short_name = 'GL_FII_FIN_ITEM' and l_enabled_flag = 'N') THEN
          l_dashboard_warn_flag := 'Y';
        END IF;
      END LOOP;

      CLOSE dim_enabled_cur1;

      fii_util.put_line(' ');
      IF (l_dashboard_warn_flag = 'Y') THEN
        fii_util.put_line('DIAGNOSIS: The Financial Category Dimension is required for the Expense Management Dashboards.  Please make sure it is enabled.');

      ELSE
        fii_util.put_line('DIAGNOSIS: The required dimension (Financial Category) has been enabled for the Expense Management Dashboards.');
        fii_util.put_line('DIAGNOSIS: NO ACTION is needed.');
      END IF;

    ELSE
      fii_util.put_line('Skipping check for Expense Management page as they are not implementated');
    END IF;

    fii_util.put_line(' ');
    fii_util.put_line('END CHECK: Expense Management.');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    fii_util.put_line(' ');

    fii_util.put_line('START CHECK: Expense Analysis.');

    -- Check if Expense Analysis Dashboard is enabled or not
    SELECT implementation_flag
    INTO l_enabled_flag
    FROM bis_obj_properties
    WHERE object_name  = 'FII_EA_EXPENSE_ANALYSIS_PAGE'
    and object_type = 'PAGE';

    fii_util.put_line('Dashboard implementation flag = ' || l_enabled_flag );

    -- Find out dimensions enabled for each dashboard
    IF (l_enabled_flag = 'Y') THEN
      l_cnt := 0;
      l_dashboard_warn_flag := 'N';

      OPEN dim_enabled_cur2;

      LOOP
        FETCH dim_enabled_cur2
        INTO l_dim_name, l_dim_short_name, l_enabled_flag;

        EXIT WHEN dim_enabled_cur2%NOTFOUND;

        IF (l_cnt = 0) THEN
          fii_util.put_line(' ');
          fii_util.put_line('Supporting Dimensions     Enabled / Disabled? ');
          fii_util.put_line('------------------------- --------------------');
          l_cnt := l_cnt + 1;
        END IF;
        fii_util.put_line(l_dim_name || '  '|| l_enabled_flag);

       -- Check if the required dimension is disabled
        IF (l_dim_short_name IN ('FII_COMPANIES', 'HRI_CL_ORGCC', 'GL_FII_FIN_ITEM')
            and l_enabled_flag = 'N') THEN
          l_dashboard_warn_flag := 'Y';
        END IF;

      END LOOP;

      CLOSE dim_enabled_cur2;

      fii_util.put_line(' ');
      IF (l_dashboard_warn_flag = 'Y') THEN
      fii_util.put_line('DIAGNOSIS: Company, Cost Center and Financial Category Dimensions are required for the Expense Analysis Dashboard.  Please make sure they are enabled.');

      ELSE
        fii_util.put_line('DIAGNOSIS: The required dimensions (Company, Cost Center and Financial Category) have been enabled for the Expense Analysis Dashboards.');
        fii_util.put_line('DIAGNOSIS: NO ACTION is needed.');
      END IF;

    ELSE
      fii_util.put_line('Skipping check for Expense Analysis page as they are not implementated');
    END IF;

    fii_util.put_line(' ');
    fii_util.put_line('END CHECK: Expense Analysis.');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    fii_util.put_line(' ');

    fii_util.put_line('START CHECK: Funds Management.');

    -- Check if Funds Management Dashboard is enabled or not
    SELECT implementation_flag
    INTO l_enabled_flag
    FROM bis_obj_properties
    WHERE object_name  = 'FII_PSI_FUNDS_MANAGEMENT_PAGE'
    and object_type = 'PAGE';

    fii_util.put_line('Dashboard implementation flag = ' || l_enabled_flag );

    -- Find out dimensions enabled for each dashboard
    IF (l_enabled_flag = 'Y') THEN
      l_cnt := 0;
      l_dashboard_warn_flag := 'N';

      OPEN dim_enabled_cur2;

      LOOP
        FETCH dim_enabled_cur2
        INTO l_dim_name, l_dim_short_name, l_enabled_flag;

        EXIT WHEN dim_enabled_cur2%NOTFOUND;

        IF (l_cnt = 0) THEN
          fii_util.put_line(' ');
          fii_util.put_line('Supporting Dimensions     Enabled / Disabled? ');
          fii_util.put_line('------------------------- --------------------');
          l_cnt := l_cnt + 1;
        END IF;
        fii_util.put_line(l_dim_name || '  '|| l_enabled_flag);

       -- Check if the required dimension is disabled
        IF (l_dim_short_name IN ('FII_COMPANIES', 'HRI_CL_ORGCC', 'GL_FII_FIN_ITEM')
            and l_enabled_flag = 'N') THEN
          l_dashboard_warn_flag := 'Y';
        END IF;

      END LOOP;

      CLOSE dim_enabled_cur2;

      fii_util.put_line(' ');
      IF (l_dashboard_warn_flag = 'Y') THEN
      fii_util.put_line('DIAGNOSIS: Company, Cost Center and Financial Category Dimensions are required for the Funds Management Dashboard.  Please make sure they are enabled.');

      ELSE
        fii_util.put_line('DIAGNOSIS: The required dimensions (Company, Cost Center and Financial Category) have been enabled for the Funds Management Dashboards.');
        fii_util.put_line('DIAGNOSIS: NO ACTION is needed.');
      END IF;

    ELSE
      fii_util.put_line('Skipping check for Funds Management page as they are not implementated');
    END IF;

    fii_util.put_line(' ');
    fii_util.put_line('END CHECK: Funds Management.');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');

    ----------------------------------------------------------------------
    -- Validate Profile Option Settings
    ----------------------------------------------------------------------
    fii_util.put_line(' ');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    fii_util.put_line('Performing Check for: Profile Options');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');
    -- Check the budget profile option
    fii_util.put_line('START CHECK: Budget Profile Check');
    fii_util.put_line(' ');

    l_budget_source := FND_PROFILE.value('FII_BUDGET_SOURCE');
    l_budget_time_unit := FND_PROFILE.Value('FII_BUDGET_TIME_UNIT');
    l_forecast_time_unit := FND_PROFILE.Value('FII_FORECAST_TIME_UNIT');

    fii_util.put_line('The profile option ''FII: Budget/Foreacst Source'' = '
                      || l_budget_source);

    fii_util.put_line('The profile option ''FII: Budget Period Type'' = '
                      || l_budget_time_unit);

    fii_util.put_line('The profile option ''FII: Forecast Period Type'' = '
                      || l_forecast_time_unit );

    fii_util.put_line(' ');
    IF (   l_budget_source IS NULL OR l_budget_time_unit IS NULL
        OR l_forecast_time_unit IS NULL) THEN
      fii_util.put_line('Diagnosis: Warning - some of the above budget profile option has not been set.  Please make sure to set the profile options listed.');

    ELSE
      fii_util.put_line('DIAGNOSIS: Budget profile options have been set correctly');
      fii_util.put_line('DIAGNOSIS: NO ACTION is needed.');
    END IF;

    fii_util.put_line(' ');
    fii_util.put_line('END CHECK: Budget Profile Check');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');

    -- Check the Industry option
    fii_util.put_line('  ');
    fii_util.put_line('START CHECK: Industry Profile Option Check');
    fii_util.put_line(' ');

    l_profile_value := FND_PROFILE.value('INDUSTRY');

    fii_util.put_line('The profile option ''Industry'' = '
                      || l_profile_value);

    fii_util.put_line(' ');
    IF (l_profile_value = 'G') THEN
      fii_util.put_line('DIAGNOSIS: The ''Industry'' profile option has been set to ''Government''.  The Company dimension will be renamed to ''Fund''. ');
      fii_util.put_line('If you are not using the Funds Management Dashboard, it is recommended to set the ''Industry'' profile option to '' ''');

    ELSE
      fii_util.put_line(
      'DIAGNOSIS: The ''Industry'' profile option has been defined correctly.');
      fii_util.put_line('DIAGNOSIS: NO ACTION is needed.');
    END IF;

    fii_util.put_line(' ');
    fii_util.put_line('END CHECK:  Industry Profile Option Check');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');

    -- Check the Debug mode option
    fii_util.put_line('  ');
    fii_util.put_line('START CHECK: ''FII: Debug Mode'' Profile Option Check');
    fii_util.put_line(' ');

    l_profile_value := FND_PROFILE.value('FII_DEBUG_MODE');

    IF (l_profile_value IS NOT NULL) THEN
      fii_util.put_line('The profile option ''FII: Debug Mode'' = '
                        || l_profile_value);
    ELSE
      fii_util.put_line('The profile option ''FII: Debug Mode'' has not been set up.');
    END IF;

    fii_util.put_line(' ');
    IF (l_profile_value = 'Y') THEN
      fii_util.put_line('DIAGNOSIS: The ''FII:Debug Mode'' profile option is set to YES.  It is recommended that this profile option is set to ''No''.');

    ELSE
      fii_util.put_line('DIAGNOSIS: NO ACTION is needed.');
    END IF;

    fii_util.put_line(' ');
    fii_util.put_line('END CHECK: ''FII:Debug Mode'' Profile Option Check');
    fii_util.put_line(
    '+---------------------------------------------------------------------+');

    -- Perform user setup validations if a username parameter is passed in
    IF (X_User IS NOT NULL) THEN
      VALIDATE_USER_SETUP(X_User);
    END IF;

    -----------------------------------------------------------------------
    -- Print report footer in logfile
    -----------------------------------------------------------------------
    -- Retrive current system time as the end time of the program
    SELECT to_char(sysdate, 'DD-MON-YYYY HH:MI:SS')
    INTO l_end_time
    FROM dual;

    fii_util.put_line(' ');
    fii_util.put_line('** Diagnostics Ends ** '|| l_end_time);
    fii_util.put_line(
    '** End of log messages from DBI Financials Validation **');

    fii_util.put_line(' ');
    fii_util.put_line(
    '+=====================================================================+');
    fii_util.put_line('+ End of DBI Financials Diagnostics ');
    fii_util.put_line(
    '+ DBI_DIAGNOSTIC module: Daily Business Intelligence Diagnostic Program');
    fii_util.put_line('+ Current System Time is '|| l_end_time);
    fii_util.put_line(
    '+=====================================================================+');

  END Main;


END FII_SETUP_VAL_C;

/
