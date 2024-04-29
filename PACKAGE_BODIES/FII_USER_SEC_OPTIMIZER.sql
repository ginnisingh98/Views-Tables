--------------------------------------------------------
--  DDL for Package Body FII_USER_SEC_OPTIMIZER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_USER_SEC_OPTIMIZER" AS
/*$Header: FIIUSECB.pls 120.2 2006/01/12 22:50:08 mmanasse noship $*/

   g_debug_flag VARCHAR2(1) := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');
   g_phase VARCHAR2(100);
   g_fii_user_id NUMBER(15);
   g_fii_login_id NUMBER(15);
   g_schema_name VARCHAR2(150) := 'FII';


PROCEDURE Main (errbuf              IN OUT NOCOPY VARCHAR2,
                retcode             IN OUT NOCOPY VARCHAR2)
IS

   FIIUSECB_fatal_err EXCEPTION;
   l_dir VARCHAR2(400);
   l_retcode varchar2(15) := 0;
   ret_val BOOLEAN := FALSE;
   l_company_top_node_id NUMBER(15);
   l_cost_ctr_top_node_id NUMBER(15);

BEGIN
     --errbuf := NULL;
     --retcode := 0;

     g_phase := 'Do set up for log file';
     ----------------------------------------------
     -- Do set up for log file
     ----------------------------------------------

     l_dir := fnd_profile.value('BIS_DEBUG_LOG_DIRECTORY');
     ------------------------------------------------------
     -- Set default directory in case if the profile option
     -- BIS_DEBUG_LOG_DIRECTORY is not set up
     ------------------------------------------------------
     if l_dir is NULL then
       l_dir := FII_UTIL.get_utl_file_dir;
     end if;

     FII_UTIL.initialize('FII_USER_SEC_OPTIMIZER.log',
                         'FII_USER_SEC_OPTIMIZER.out',l_dir,
                         'FII_USER_SEC_OPTIMIZER');


 	g_fii_user_id := FND_GLOBAL.User_Id;
	g_fii_login_id := FND_GLOBAL.Login_Id;

  	IF g_debug_flag = 'Y' THEN
    	FII_UTIL.Write_Log ('Inserted ' || SQL%ROWCOUNT || ' rows into fii_cost_center_grants.');
  	END IF;


   -------------------------------------------------------------
    --- Truncate grants tables ---------------------------------
	------------------------------------------------------------
    g_phase := 'Truncating grants tables FII_COMPANY_GRANTS and FII_COST_CENTER_GRANTS...';
   	if g_debug_flag = 'Y' then
    	FII_UTIL.write_log(g_phase);
    end if;

	fii_util.truncate_table('FII_COMPANY_GRANTS', 'FII', l_retcode);
    IF l_retcode = -1 then
      fii_util.write_log('Error in fii_util.truncate_table(''FII_COMPANY_GRANTS'', ''FII'', l_retcode)');
      raise FIIUSECB_fatal_err;
    END IF;
	fii_util.truncate_table('FII_COST_CENTER_GRANTS', 'FII', l_retcode);
    IF l_retcode = -1 then
      fii_util.write_log('Error in fii_util.truncate_table(''FII_COST_CENTER_GRANTS'', ''FII'', l_retcode)');
      raise FIIUSECB_fatal_err;
    END IF;

    g_phase := 'Selecting top nodes for company and cost center dimensions from fii_financial_dimensions.';

    select dbi_hier_top_node_id into l_company_top_node_id from fii_financial_dimensions where dimension_short_name='FII_COMPANIES';
	select dbi_hier_top_node_id into l_cost_ctr_top_node_id from fii_financial_dimensions where dimension_short_name='HRI_CL_ORGCC';

	IF (l_company_top_node_id is null) or (l_cost_ctr_top_node_id is null) THEN
      fii_util.write_log('Error: Top node for the company or cost center dimension is not assigned.');
      raise FIIUSECB_fatal_err;
    END IF;

    g_phase := 'Inserting into fii_company_grants from bis_grants_v.';


	INSERT INTO fii_company_grants
	(user_id,
	 report_region_code,
	 company_id,
	 aggregated_flag,
	 last_update_date, last_updated_by,
	 creation_date, created_by, last_update_login)
	(SELECT DISTINCT u.user_id,
			s.report_region_code,
			decode(s.granted_for,
				   -999, l_company_top_node_id,
				   s.granted_for),
            h.aggregated_flag,
	        sysdate, g_fii_user_id,
			sysdate, g_fii_user_id, g_fii_login_id
 	 FROM bis_grants_v s, --user_security_initial2 s,
          fii_com_pmv_agrt_nodes h,
          fnd_user u
 	 WHERE decode(s.granted_for,
				   -999, l_company_top_node_id,
				   s.granted_for) = h.company_id
     AND s.delegation_parameter='FII_COMPANIES'
	 AND (sysdate BETWEEN TRUNC(s.start_date) AND nvl(TRUNC(s.end_date),to_date('12-31-9999','MM-DD-YYYY')))
     AND s.granted_to = u.employee_id);

  	IF g_debug_flag = 'Y' THEN
    	FII_UTIL.Write_Log ('Inserted ' || SQL%ROWCOUNT || ' rows into fii_company_grants.');
  	END IF;
	--DBMS_OUTPUT.PUT_LINE('Inserted ' || SQL%ROWCOUNT || ' rows into fii_company_grants.');

    g_phase := 'Inserting into fii_cost_center_grants from bis_grants_v.';

	INSERT INTO fii_cost_center_grants
	(user_id,
     report_region_code,
     cost_center_id,
     aggregated_flag,
	 last_update_date, last_updated_by,
	 creation_date, created_by, last_update_login)
	(SELECT DISTINCT u.user_id,
            s.report_region_code,
            decode(s.granted_for,
				   -999, l_cost_ctr_top_node_id,
				   s.granted_for),
            h.aggregated_flag,
	        sysdate, g_fii_user_id,
			sysdate, g_fii_user_id, g_fii_login_id
 	 FROM bis_grants_v s,  --user_security_initial2 s,
          fii_cc_pmv_agrt_nodes h,
          fnd_user u
 	 WHERE decode(s.granted_for,
				   -999, l_cost_ctr_top_node_id,
				   s.granted_for) = h.cost_center_id
     AND s.delegation_parameter='HRI_CL_ORGCC'
	 AND (sysdate BETWEEN TRUNC(s.start_date) AND nvl(TRUNC(s.end_date),to_date('12-31-9999','MM-DD-YYYY')))
     AND s.granted_to = u.employee_id);

  	IF g_debug_flag = 'Y' THEN
    	FII_UTIL.Write_Log ('Inserted ' || SQL%ROWCOUNT || ' rows into fii_cost_center_grants.');
  	END IF;
	--DBMS_OUTPUT.PUT_LINE('Inserted ' || SQL%ROWCOUNT || ' rows into fii_cost_center_grants.');

    g_phase := 'Filtering out child company assignments from fii_company_grants.';

	DELETE FROM fii_company_grants
	WHERE (user_id, report_region_code, company_id) IN
	(SELECT s.user_id, s.report_region_code, s.company_id FROM fii_company_grants s, fii_company_hierarchies h
	 WHERE s.company_id = h.child_company_id
 	   AND h.parent_company_id IN (SELECT company_id from fii_company_grants where user_id=s.user_id and report_region_code=s.report_region_code)
 	   AND h.parent_company_id <> h.child_company_id);

  	IF g_debug_flag = 'Y' THEN
    	FII_UTIL.Write_Log ('Deleted ' || SQL%ROWCOUNT || ' rows from fii_company_grants.');
  	END IF;
	--DBMS_OUTPUT.PUT_LINE('Deleted ' || SQL%ROWCOUNT || ' rows from fii_company_grants.');

    g_phase := 'Filtering out child cost center assignments from fii_cost_center_grants.';

	DELETE FROM fii_cost_center_grants
	WHERE (user_id, report_region_code, cost_center_id) IN
	(SELECT s.user_id, s.report_region_code, s.cost_center_id FROM fii_cost_center_grants s, fii_cost_ctr_hierarchies h
	 WHERE s.cost_center_id = h.child_cc_id
	   AND h.parent_cc_id IN (SELECT cost_center_id from fii_cost_center_grants where user_id=s.user_id and report_region_code=s.report_region_code)
 	   AND h.parent_cc_id <> h.child_cc_id);

    IF g_debug_flag = 'Y' THEN
    	FII_UTIL.Write_Log ('Deleted ' || SQL%ROWCOUNT || ' rows from fii_cost_center_grants.');
  	END IF;
	--DBMS_OUTPUT.PUT_LINE('Deleted ' || SQL%ROWCOUNT || ' rows from fii_cost_center_grants.');

    --Call FND_STATS to collect statistics after populating the table
    g_phase := 'gather_table_stats for fii_cost_center_grants';
    FND_STATS.gather_table_stats
  	       (ownname	=> g_schema_name,
	        tabname	=> 'fii_cost_center_grants');

EXCEPTION
	WHEN FIIUSECB_fatal_err THEN
      FII_UTIL.write_log('Fatal errors occured:');
	  FII_UTIL.Write_Log ( 'G_PHASE: ' || g_phase);

	  FND_CONCURRENT.Af_Rollback;
	  retcode := sqlcode;
	  errbuf  := sqlerrm;
	  ret_val := FND_CONCURRENT.Set_Completion_Status
		           (status => 'ERROR', message => substr(errbuf,1,180));
/*        DBMS_OUTPUT.put_line('Fatal errors occured during the upload process.');  */

    WHEN OTHERS THEN
	    FII_UTIL.Write_Log ('Other error in Main ');
	    FII_UTIL.Write_Log ( 'G_PHASE: ' || g_phase);
	    FII_UTIL.Write_Log ('-->'|| sqlcode ||':'|| substr(sqlerrm,1,180));

	    FND_CONCURRENT.Af_Rollback;
	    retcode := sqlcode;
	    errbuf  := sqlerrm;
	    ret_val := FND_CONCURRENT.Set_Completion_Status
		           (status => 'ERROR', message => substr(errbuf,1,180));

		--DBMS_OUTPUT.PUT_LINE('Error: ' || sqlerrm);

END Main;

END FII_USER_SEC_OPTIMIZER;

/
