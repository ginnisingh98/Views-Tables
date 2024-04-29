--------------------------------------------------------
--  DDL for Package RCI_ORG_CERT_ETL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCI_ORG_CERT_ETL_PKG" AUTHID CURRENT_USER AS
--$Header: rciocrtetls.pls 120.6.12000000.1 2007/01/16 20:46:17 appldev ship $

---12.30.2005 npanandi: added new version of initial load and obsoleted original one
PROCEDURE initial_load(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER);

PROCEDURE initial_load_obsolete(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER);

---12.30.2005 npanandi: added new version of incremental load and obsoleted original one
PROCEDURE incr_load(
   errbuf  IN OUT NOCOPY VARCHAR2
  ,retcode IN OUT NOCOPY NUMBER);

PROCEDURE incr_load_obsolete(
   errbuf  IN OUT NOCOPY VARCHAR2
  ,retcode IN OUT NOCOPY NUMBER);

FUNCTION get_last_run_date ( p_fact_name VARCHAR2) RETURN DATE;

FUNCTION err_mesg (
   p_mesg      IN VARCHAR2
  ,p_proc_name IN VARCHAR2 DEFAULT NULL
  ,p_stmt_id   IN NUMBER DEFAULT -1) RETURN VARCHAR2 ;

PROCEDURE check_initial_load_setup (
   x_global_start_date OUT NOCOPY DATE
  ,x_rci_schema 	   OUT NOCOPY VARCHAR2);

----this is to determine number of processes with ineffective controls
---so need processId as a parameter
   cursor c_proc_w_ineff_ctrls (p_fin_certification_id in number
                               ,p_organization_id in number
							   ,p_process_id in number) is
      /*12.30.2005 npanandi: changed below query according to changes
	               in datamodel for financial statements */
      select 1 from dual where exists /*select count(process_id) from*/ (
	     SELECT DISTINCT ctrls.pk1 as certification_id /*fin_certification_id*/
      	 	   ,o.organization_id
			   ,ctrls.pk3
               ---,all_ctrls.control_id
		       ,op.audit_result_code
			   ,op.authored_by
			   ,op.authored_date
		  	   /*,(select aov.opinion_value_id from AMW_OPINION_LOG_DETAILS aod, AMW_OPINION_VALUES_TL aov
	           	  WHERE aov.language=userenv('LANG') and op.OPINION_LOG_ID = aod.OPINION_LOG_ID
			   	  	and aod.OPINION_VALUE_ID = aov.OPINION_VALUE_ID
			   		and aod.OPINION_COMPONENT_ID = (select OPINION_COMPONENT_ID from AMW_OPINION_COMPONTS_B
	                                               	 where OBJECT_OPINION_TYPE_ID = op.OBJECT_OPINION_TYPE_ID
												  	   and OPINION_COMPONENT_CODE = 'OPERATING')) op_eff_id
	      	   ,(select aov.opinion_value_id from AMW_OPINION_LOG_DETAILS aod, AMW_OPINION_VALUES_TL aov
	           	  WHERE aov.language=userenv('LANG') and op.OPINION_LOG_ID = aod.OPINION_LOG_ID
			   	    and aod.OPINION_VALUE_ID = aov.OPINION_VALUE_ID
			   		and aod.OPINION_COMPONENT_ID = (select OPINION_COMPONENT_ID from AMW_OPINION_COMPONTS_B
	                                                 where OBJECT_OPINION_TYPE_ID = op.OBJECT_OPINION_TYPE_ID
												  	   and OPINION_COMPONENT_CODE = 'DESIGN')) des_eff_id
                 ***/
	       FROM AMW_CONTROL_ASSOCIATIONS ctrls,
	            AMW_CONTROLS_ALL_VL all_ctrls,
		        HR_ALL_ORGANIZATION_UNITS o,
		        HR_ALL_ORGANIZATION_UNITS_TL otl,
		        AMW_OPINIONS_LOG_V op
		  WHERE ctrls.object_type = 'RISK_FINCERT'
		    and ctrls.control_rev_id = all_ctrls.control_rev_id
		    and all_ctrls.APPROVAL_STATUS = 'A'
		    and o.organization_id = ctrls.pk2
		    and o.organization_id = otl.organization_id
		    and otl.language = userenv('LANG')
		    and op.opinion_log_id(+)  = ctrls.pk5
		    and op.AUDIT_RESULT_CODE <> 'EFFECTIVE'
		    AND ctrls.pk1 = p_fin_certification_id
		    and o.ORGANIZATION_ID = p_organization_id
			and ctrls.pk3 = p_process_id

			/**
		select distinct aov2.pk2_value ---project_id
      ,aca.pk1 ----fin_certified_id
      ,haou.organization_id
      ,alrv.process_id
      ,aov1.audit_result_code ---certification_result_code
      ,aov1.authored_by ----certified_by_id
      ,aov2.audit_result_code -----evaluation_result_code
      ,aov2.authored_by -----last_evaluated_by_id
      ,aov2.authored_date -----last_evaluated_on
  from amw_control_associations aca
      ,amw_opinions_log_v aolv
      ,amw_latest_revisions_v alrv
      ,HR_ALL_ORGANIZATION_UNITS haou
      ,HR_ALL_ORGANIZATION_UNITS_TL haout
      ,amw_opinions_v aov1
      ,amw_opinions_v aov2
      ,amw_certification_b acb
 where aca.object_type='RISK_FINCERT'
   and aca.pk5=aolv.opinion_log_id
   and aca.pk3=alrv.process_id
   and aca.pk2=haou.organization_id
   and haou.organization_id=haout.organization_id
   and haout.language=userenv('LANG')
   and aov1.opinion_type_code='CERTIFICATION'
   and aov1.AUDIT_RESULT_CODE <> 'EFFECTIVE'
   and aov1.object_name='AMW_ORG_PROCESS'
   and aov1.pk1_value=alrv.process_id
   and aov1.pk3_value=aca.pk2
   and aov2.opinion_type_code='EVALUATION'
   and aov2.object_name='AMW_ORG_PROCESS'
   and aov2.pk1_value=alrv.process_id
   and aov2.pk3_value=aca.pk2
   and aca.pk1=acb.certification_id
   and aov2.authored_date in (select max(aov.authored_date)
                       from AMW_OPINIONS aov
                       where aov.object_opinion_type_id = aov2.object_opinion_type_id
                       and aov.pk1_value = aov2.pk1_value
                       and aov.pk3_value = aov2.pk3_value)
   and aca.pk1 = p_fin_certification_id and aca.pk2 = p_organization_id	and aov1.pk1_value = p_process_id
    **/);


---this is to determine the total number of ineffective controls, regardless
---of whether process is there or not, so don't need processId here
----01/03/2006 npanandi: new query for IneffectiveControls to conform to count columns
   cursor c_ineffective_ctrls(p_certification_id in number,p_organization_id in number) is
      select count(control_id) from (
	     SELECT DISTINCT ctrls.pk1 as certification_id /*fin_certification_id*/
      	 	   ,o.organization_id
               ,all_ctrls.control_id
		       ,op.audit_result_code
			   ,op.authored_by /*last_evaluated_by_id*/
			   ,op.authored_date /*last_evaluated_on*/
		  	   ,(select /*aov.OPINION_VALUE_NAME*/ aov.opinion_value_id from AMW_OPINION_LOG_DETAILS aod, AMW_OPINION_VALUES_TL aov
	           	  WHERE aov.language=userenv('LANG') and op.OPINION_LOG_ID = aod.OPINION_LOG_ID
			   	  	and aod.OPINION_VALUE_ID = aov.OPINION_VALUE_ID
			   		and aod.OPINION_COMPONENT_ID = (select OPINION_COMPONENT_ID from AMW_OPINION_COMPONTS_B
	                                               	 where OBJECT_OPINION_TYPE_ID = op.OBJECT_OPINION_TYPE_ID
												  	   and OPINION_COMPONENT_CODE = 'OPERATING')) op_eff_id
	      	   ,(select /*aov.OPINION_VALUE_NAME*/ aov.opinion_value_id from AMW_OPINION_LOG_DETAILS aod, AMW_OPINION_VALUES_TL aov
	           	  WHERE aov.language=userenv('LANG') and op.OPINION_LOG_ID = aod.OPINION_LOG_ID
			   	    and aod.OPINION_VALUE_ID = aov.OPINION_VALUE_ID
			   		and aod.OPINION_COMPONENT_ID = (select OPINION_COMPONENT_ID from AMW_OPINION_COMPONTS_B
	                                                 where OBJECT_OPINION_TYPE_ID = op.OBJECT_OPINION_TYPE_ID
												  	   and OPINION_COMPONENT_CODE = 'DESIGN')) des_eff_id
	       FROM AMW_CONTROL_ASSOCIATIONS ctrls,
	            AMW_CONTROLS_ALL_VL all_ctrls,
		        HR_ALL_ORGANIZATION_UNITS o,
		        HR_ALL_ORGANIZATION_UNITS_TL otl,
		        AMW_OPINIONS_LOG_V op
		  WHERE ctrls.object_type = 'RISK_FINCERT'
		    and ctrls.control_rev_id = all_ctrls.control_rev_id
		    and all_ctrls.APPROVAL_STATUS = 'A'
		    and o.organization_id = ctrls.pk2
		    and o.organization_id = otl.organization_id
		    and otl.language = userenv('LANG')
		    and op.opinion_log_id(+)  = ctrls.pk5
		    and op.AUDIT_RESULT_CODE <> 'EFFECTIVE'
		    AND ctrls.pk1 = p_certification_id
		    and o.ORGANIZATION_ID = p_organization_id);

----01/03/2006 npanandi: old query
/****
   cursor c_ineffective_ctrls(c_certification_id in number
                             ,c_organization_id in number) is
      select count(1) from (
         SELECT DISTINCT opinionstable.pk2_value as proj_id,
                ctrlassoc.pk1 as cert_id,
                orgtable.organization_id as org_id,
	            ctrlassoc.pk3 as process_id,
	            controltable.control_id as ctrl_id,
	            opinionstable.audit_result as eval,
	            ctrlassoc.control_rev_id as ctrl_rev_id,
	            opinionstable.audit_result_code as audit_result_code
           FROM amw_control_associations ctrlassoc,
                amw_controls_all_vl controltable,
                amw_audit_units_v orgtable,
                amw_opinions_log_v opinionstable,
                amw_execution_scope execs,
                AMW_PROCESS_ORGANIZATION_VL procorg
          WHERE execs.entity_id            = ctrlassoc.pk1
            AND execs.entity_type          = ctrlassoc.object_type
            AND execs.organization_id      = orgtable.organization_id
            AND procorg.process_org_rev_id(+) = execs.process_org_rev_id
            AND ctrlassoc.control_rev_id   = controltable.control_rev_id
            AND ctrlassoc.pk5              = opinionstable.opinion_log_id (+)
            AND ctrlassoc.object_type      = 'BUSIPROC_CERTIFICATION'
            AND ctrlassoc.pk2              = orgtable.organization_id
            AND nvl(ctrlassoc.pk3,-1)      = nvl(execs.process_id,-1)
            AND ctrlassoc.pk1              = c_certification_id
            AND ctrlassoc.pk2              = c_organization_id
			and opinionstable.audit_result_code <> 'EFFECTIVE'
			and opinionstable.OBJECT_NAME  = 'AMW_ORG_CONTROL'
			and opinionstable.OPINION_TYPE_CODE = 'EVALUATION');
***/

---this cursor is used to compute the number of unmitigated risks
---per process, per organization, per certification
---so, depending on the parameters chosen, the numbers will be
---summed up at run-time
/*** 01.03.2006 npanandi: changed the below cursor query ***/
cursor c_unmitigated_risks(p_certification_id in number,p_organization_id in number) is
   select count(risk_id) from (

   SELECT DISTINCT op.pk2_value, /*project_id*/
	   /*risks.pk1 as certification_id,*/ /*fin_certification_id*/
	   proc.organization_id,
	   proc.process_id,
	   all_risks.risk_id,
	   nvl(all_risks.material,'N'),
	   all_risks.risk_impact,
	   all_risks.likelihood,
	   op.last_updated_by, /*last_evaluator_id*/
	   op.authored_date, /*last_evaluated_on*/
	   all_risks.risk_rev_id,
	   op.audit_result_code
  FROM AMW_RISK_ASSOCIATIONS risks,
       AMW_RISKS_ALL_VL all_risks,
	   AMW_PROCESS_ORGANIZATION_VL proc,
	   HR_ALL_ORGANIZATION_UNITS o,
       HR_ALL_ORGANIZATION_UNITS_TL otl,
       AMW_OPINIONS_LOG_V op,
	   (select pk1,pk2,NATURAL_ACCOUNT_ID from AMW_ACCT_ASSOCIATIONS where object_type='PROCESS_ORG' and approval_date is not null and deletion_approval_date is null) aaa
 WHERE risks.object_type = 'PROCESS_FINCERT'
   and all_risks.risk_rev_id = risks.risk_rev_id
   and o.organization_id = risks.pk2
   and o.organization_id = otl.organization_id
   and otl.language = userenv('LANG')
   and proc.organization_id = risks.pk2
   and proc.process_id = risks.pk3
   and risks.approval_date is not null
   and proc.approval_status = 'A'
   and proc.approval_date = risks.approval_date
   and op.opinion_log_id(+)  = risks.pk4
   and op.audit_result_code <> 'EFFECTIVE'
   and risks.pk1 = p_certification_id
   and proc.organization_id = p_organization_id);

/**** original query ***/
/****
cursor c_unmitigated_risks(c_certification_id in number
                             ,c_organization_id in number
							 ,c_process_id in number) is
      SELECT count(distinct risk_id) FROM (
         SELECT DISTINCT assoctable.pk1 cert_id,
                orgtable.organization_id as org_id,
                assoctable.pk3 as process_id,
                assoctable.risk_id as risk_id,
		        opinionstable.audit_result as eval,
		        procorg.display_name as process_name,
		        assoctable.risk_rev_id as risk_rev_id,
		        opinionstable.audit_result_code as audit_result_code
		   FROM amw_risk_associations assoctable,
		        amw_risks_all_vl risktable,
		        amw_audit_units_v orgtable,
		        amw_opinions_log_v opinionstable,
		        amw_execution_scope execs,
		        AMW_PROCESS_ORGANIZATION_VL procorg
		  WHERE execs.entity_id            = assoctable.pk1
		    AND execs.entity_type          = assoctable.object_type
		    AND execs.organization_id      = orgtable.organization_id
		    AND assoctable.object_type     = 'BUSIPROC_CERTIFICATION'
		    AND procorg.process_org_rev_id(+) = execs.process_org_rev_id
		    AND assoctable.pk4             = opinionstable.opinion_log_id(+)
		    AND assoctable.pk2             = orgtable.organization_id
		    AND NVL(assoctable.pk3, -1)    = NVL(execs.process_id,-1)
		    AND assoctable.risk_rev_id     = risktable.risk_rev_id
		    AND assoctable.pk1             = c_certification_id ---10000 ---:1
		    AND assoctable.pk2             = c_organization_id ---5190 ----NVL(:2, assoctable.pk2)
		    and assoctable.pk3             = c_process_id ---3045
		    and opinionstable.audit_result_code <> 'EFFECTIVE'
			and opinionstable.OBJECT_NAME  = 'AMW_ORG_PROCESS_RISK'
			and opinionstable.OPINION_TYPE_CODE = 'EVALUATION');
***/

---this cursor is used to compute the number of open issues
---per certification, per organization
---the numbers will be summed up at run-time
cursor c_open_org_issues(c_certification_id in number
                        ,c_organization_id in number) is
      select /**acv.certification_id
	        ,aauv.organization_id
			,**/sum(open) as open_issues
		from (select change_id,
				     change_name,
				     description,
				     status_type,
				     status_code,
				     change_order_type_id,
				     change_mgmt_type_code,
				     initiation_date,
				     need_by_date,
				     priority_code,
				     reason_code,
				     (select pk1_value from eng_change_subjects ecs where ecs.entity_name='CERTIFICATION' and ecs.change_id=eec.change_id) certification_id,
				     (select pk1_value from eng_change_subjects ecs where ecs.entity_name='ORGANIZATION' and ecs.change_id=eec.change_id) as organization_id,
				     (select pk1_value from eng_change_subjects ecs where ecs.entity_name='PROCESS' and ecs.change_id=eec.change_id) as process_id,
				     decode(status_code, 0, 0, 11, 0, 1) as open
				from eng_engineering_changes eec
			   where change_order_type_id in (select change_order_type_id
				                                from eng_change_order_types
				                               where type_classification='HEADER'
                                                 and change_mgmt_type_code='AMW_PROC_CERT_ISSUES')) open_issues,
             amw_audit_units_v aauv,
			 amw_certification_vl acv
			 ---amw_latest_revisions_v alrv
       where aauv.organization_id=open_issues.organization_id
	     and open_issues.certification_id = acv.certification_id
	     ---and open_issues.process_id = alrv.process_id
	     and open_issues.certification_id is not null
	     and open_issues.organization_id is not null
	     ---and open_issues.process_id is null
		 and open_issues.certification_id = c_certification_id
		 and open_issues.organization_id = c_organization_id
	   group by acv.certification_id, aauv.organization_id;


/** 01.01.2006 npanandi: added the below 3 cursors for computing
    processes_certified_with_issues, processes_certified and processes_not_certified
 **/
   cursor c_proc_certified_w_issues(p_fin_certification_id in number,p_organization_id in number
                                   ,p_process_id in number)
   is
      select /*count(process_id)*/ 1 from dual where exists (
	     select distinct o.organization_id,
	   proc.process_id,
	   finprocsum.FIN_CERTIFICATION_ID,
       evalopn.pk2_value, /*project_id*/
       proc.process_org_rev_id,
       certopn.audit_result_code, /*certification_result_code*/
       certopn.authored_by, /*certified_by_id*/
       certopn.authored_date, /*certified_on*/
       evalopn.audit_result_code, /*evaluation_result_code*/
       evalopn.authored_by, /*evaluated_by_id*/
       evalopn.authored_date /*last_evaluated_on*/
  from AMW_FIN_CERT_SCOPE finscope,
       AMW_FIN_PROC_CERT_RELAN REL,
       AMW_FIN_PROCESS_EVAL_SUM finprocsum,
       HR_ALL_ORGANIZATION_UNITS o,
       HR_ALL_ORGANIZATION_UNITS_TL otl,
       AMW_PROCESS_ORGANIZATION_VL proc,
       /*AMW_OPINIONS_V*/ AMW_OPINIONS_LOG_V certopn,
       /*AMW_OPINIONS_V*/ AMW_OPINIONS_LOG_V evalopn
 where rel.FIN_STMT_CERT_ID = finprocsum.FIN_CERTIFICATION_ID
   and rel.end_date is null
   and finprocsum.FIN_CERTIFICATION_ID = finscope.fin_certification_id
   and finprocsum.ORGANIZATION_ID = finscope.ORGANIZATION_ID
   and finprocsum.PROCESS_ID  = finscope.PROCESS_ID
   and finprocsum.PROCESS_ORG_REV_ID = proc.PROCESS_ORG_REV_ID
   and o.organization_id = finscope.organization_id
   and o.organization_id = otl.organization_id
   and otl.language = userenv('LANG')
   and finprocsum.EVAL_OPINION_LOG_ID = evalopn.opinion_log_id(+)
   and finprocsum.cert_opinion_log_id = certopn.opinion_log_id(+)
   and certopn.audit_result_code = 'INEFFECTIVE'
   and finprocsum.FIN_CERTIFICATION_ID=p_fin_certification_id
   and finprocsum.ORGANIZATION_ID=p_organization_id
   and finprocsum.PROCESS_ID=p_process_id);

   cursor c_proc_certified(p_fin_certification_id in number,p_organization_id in number
                          ,p_process_id in number)
   is
      select /*count(process_id)*/ 1 from dual where exists (
	     select distinct o.organization_id,
	   proc.process_id,
	   finprocsum.FIN_CERTIFICATION_ID,
       evalopn.pk2_value, /*project_id*/
       proc.process_org_rev_id,
       certopn.audit_result_code, /*certification_result_code*/
       certopn.authored_by, /*certified_by_id*/
       certopn.authored_date, /*certified_on*/
       evalopn.audit_result_code, /*evaluation_result_code*/
       evalopn.authored_by, /*evaluated_by_id*/
       evalopn.authored_date /*last_evaluated_on*/
  from AMW_FIN_CERT_SCOPE finscope,
       AMW_FIN_PROC_CERT_RELAN REL,
       AMW_FIN_PROCESS_EVAL_SUM finprocsum,
       HR_ALL_ORGANIZATION_UNITS o,
       HR_ALL_ORGANIZATION_UNITS_TL otl,
       AMW_PROCESS_ORGANIZATION_VL proc,
       /*AMW_OPINIONS_V*/ AMW_OPINIONS_LOG_V certopn,
       /*AMW_OPINIONS_V*/ AMW_OPINIONS_LOG_V evalopn
 where rel.FIN_STMT_CERT_ID = finprocsum.FIN_CERTIFICATION_ID
   and rel.end_date is null
   and finprocsum.FIN_CERTIFICATION_ID = finscope.fin_certification_id
   and finprocsum.ORGANIZATION_ID = finscope.ORGANIZATION_ID
   and finprocsum.PROCESS_ID  = finscope.PROCESS_ID
   and finprocsum.PROCESS_ORG_REV_ID = proc.PROCESS_ORG_REV_ID
   and o.organization_id = finscope.organization_id
   and o.organization_id = otl.organization_id
   and otl.language = userenv('LANG')
   and finprocsum.EVAL_OPINION_LOG_ID = evalopn.opinion_log_id(+)
   and finprocsum.cert_opinion_log_id = certopn.opinion_log_id(+)
   and certopn.audit_result_code = 'EFFECTIVE'
   and finprocsum.FIN_CERTIFICATION_ID=p_fin_certification_id
   and finprocsum.ORGANIZATION_ID=p_organization_id
   and finprocsum.PROCESS_ID=p_process_id);

   cursor c_proc_not_certified(p_fin_certification_id in number,p_organization_id in number
                              ,p_process_id in number)
   is
      select /*count(process_id)*/ 1 from dual where exists (
	     select distinct o.organization_id,
	   proc.process_id,
	   finprocsum.FIN_CERTIFICATION_ID,
       evalopn.pk2_value, /*project_id*/
       proc.process_org_rev_id,
       certopn.audit_result_code, /*certification_result_code*/
       certopn.authored_by, /*certified_by_id*/
       certopn.authored_date, /*certified_on*/
       evalopn.audit_result_code, /*evaluation_result_code*/
       evalopn.authored_by, /*evaluated_by_id*/
       evalopn.authored_date /*last_evaluated_on*/
  from AMW_FIN_CERT_SCOPE finscope,
       AMW_FIN_PROC_CERT_RELAN REL,
       AMW_FIN_PROCESS_EVAL_SUM finprocsum,
       HR_ALL_ORGANIZATION_UNITS o,
       HR_ALL_ORGANIZATION_UNITS_TL otl,
       AMW_PROCESS_ORGANIZATION_VL proc,
       /*AMW_OPINIONS_V*/ AMW_OPINIONS_LOG_V certopn,
       /*AMW_OPINIONS_V*/ AMW_OPINIONS_LOG_V evalopn
 where rel.FIN_STMT_CERT_ID = finprocsum.FIN_CERTIFICATION_ID
   and rel.end_date is null
   and finprocsum.FIN_CERTIFICATION_ID = finscope.fin_certification_id
   and finprocsum.ORGANIZATION_ID = finscope.ORGANIZATION_ID
   and finprocsum.PROCESS_ID  = finscope.PROCESS_ID
   and finprocsum.PROCESS_ORG_REV_ID = proc.PROCESS_ORG_REV_ID
   and o.organization_id = finscope.organization_id
   and o.organization_id = otl.organization_id
   and otl.language = userenv('LANG')
   and finprocsum.EVAL_OPINION_LOG_ID = evalopn.opinion_log_id(+)
   and finprocsum.cert_opinion_log_id = certopn.opinion_log_id(+)
   and certopn.audit_result_code IS NULL
   and finprocsum.FIN_CERTIFICATION_ID=p_fin_certification_id
   and finprocsum.ORGANIZATION_ID=p_organization_id
   and finprocsum.PROCESS_ID=p_process_id);
END RCI_ORG_CERT_ETL_PKG;

 

/
