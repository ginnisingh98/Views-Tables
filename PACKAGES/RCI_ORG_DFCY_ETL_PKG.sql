--------------------------------------------------------
--  DDL for Package RCI_ORG_DFCY_ETL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCI_ORG_DFCY_ETL_PKG" AUTHID CURRENT_USER AS
--$Header: rciodfcyetls.pls 120.3.12000000.1 2007/01/16 20:46:25 appldev ship $

/**01.01.2006 npanandi: made a copy of initial_load and obsoleted earlier one **/
PROCEDURE initial_load(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER);

PROCEDURE initial_load_obsolete(
   errbuf    IN OUT NOCOPY  VARCHAR2
  ,retcode   IN OUT NOCOPY  NUMBER);

/**01.01.2006 npanandi: made a copy of incremental_load and obsoleted earlier one **/
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

----this is to determine number of unmitigated_risks
---per process, per organization, per certification
   cursor c_unmitigated_risks (c_certification_id in number
                              ,c_organization_id in number
							  ,c_process_id in number) is
      SELECT count(1)
  FROM (SELECT DISTINCT ara.pk1 certification_id, ara.pk2 organization_id, ara.pk3 process_id, ara.risk_id
	      FROM amw_risk_associations ara, amw_opinions_v aov
	     WHERE ara.object_type = 'BUSIPROC_CERTIFICATION'
	       AND ara.pk1 = c_certification_id
	       AND ara.pk2 = c_organization_id
	       AND ara.pk3 IN (SELECT DISTINCT process_id
				             FROM amw_execution_scope
				            START WITH process_id = c_process_id
							  AND organization_id = c_organization_id
							  AND entity_id = c_certification_id
							  and entity_type='BUSIPROC_CERTIFICATION'
						  CONNECT BY PRIOR process_id = parent_process_id
							  AND organization_id = PRIOR organization_id
							  AND entity_id = PRIOR entity_id
							  and entity_type=prior entity_type)
		   AND aov.object_name = 'AMW_ORG_PROCESS_RISK'
		   AND aov.opinion_type_code = 'EVALUATION'
		   AND aov.pk3_value = ara.pk2 --org_id
		   AND aov.pk4_value = ara.pk3 --process_id
		   AND aov.pk1_value = ara.risk_id
	       AND aov.authored_date = (SELECT MAX(aov2.authored_date)
				                      FROM amw_opinions aov2
				                     WHERE aov2.object_opinion_type_id = aov.object_opinion_type_id
				                       AND aov2.pk4_value = aov.pk4_value
				                       AND aov2.pk3_value = aov.pk3_value
				                       AND aov2.pk1_value = aov.pk1_value)
	       AND aov.audit_result_code <> 'EFFECTIVE');


----this is to determine number of ineffective controls
---per process, per organization, per certification
   cursor c_ineffective_controls (c_certification_id in number
                                 ,c_organization_id in number
							     ,c_process_id in number) is
      SELECT count(1) FROM
	     (SELECT DISTINCT aca.pk1 certification_id,
		         aca.pk2 organization_id,
				 aca.pk3 process_id,
				 aca.pk4 risk_id,
				 aca.control_id
	        FROM amw_control_associations aca,
			     amw_opinions_v aov
	       WHERE aca.object_type = 'BUSIPROC_CERTIFICATION'
	         AND aca.pk1 = c_certification_id
	         AND aca.pk2 = c_organization_id
	         AND aca.pk3 IN (SELECT DISTINCT process_id
	 	 		  	           FROM amw_execution_scope
	 	 		  	          START WITH process_id = c_process_id
	 	 		  	            AND organization_id = c_organization_id
	 	 		  	            AND entity_id = c_certification_id
						        and entity_type='BUSIPROC_CERTIFICATION'
	 	 		  	        CONNECT BY PRIOR process_id = parent_process_id
	 	 		  	            AND organization_id = PRIOR organization_id
	 	 		  	            AND entity_id = PRIOR entity_id
						        and entity_type=prior entity_type)
	         AND aov.object_name       = 'AMW_ORG_CONTROL'
			 AND aov.opinion_type_code = 'EVALUATION'
			 AND aov.pk3_value         = c_organization_id
			 AND aov.pk1_value         = aca.control_id
			 AND aov.audit_result_code <> 'EFFECTIVE'
			 AND aov.authored_date = (SELECT MAX(aov2.authored_date)
				                        FROM amw_opinions aov2
				                       WHERE aov2.object_opinion_type_id = aov.object_opinion_type_id
									     AND aov2.pk3_value = aov.pk3_value
									     AND aov2.pk1_value = aov.pk1_value));



END RCI_ORG_DFCY_ETL_PKG;

 

/
