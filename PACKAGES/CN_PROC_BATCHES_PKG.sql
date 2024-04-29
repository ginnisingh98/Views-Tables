--------------------------------------------------------
--  DDL for Package CN_PROC_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PROC_BATCHES_PKG" AUTHID CURRENT_USER as
/* $Header: cnsybats.pls 120.2 2005/08/02 17:54:49 ymao ship $ */


 -- Procedure Name
 --   find_srp_incomplete_plan
 -- Purpose
 --
 -- Notes
 FUNCTION find_srp_incomplete_plan (p_calc_sub_batch_id NUMBER) RETURN boolean;

 PROCEDURE Calculate_Batch
  (errbuf                 OUT NOCOPY    	   VARCHAR2,
   retcode                OUT NOCOPY    	   NUMBER,
   p_calc_sub_batch_id    IN  cn_calc_submission_batches.calc_sub_batch_id%TYPE);

  PROCEDURE calc(  errbuf      OUT NOCOPY    	   VARCHAR2,
		   retcode     OUT NOCOPY    	   NUMBER,
		   p_batch_name            VARCHAR2,
		   p_start_date            DATE,
		   p_end_date              DATE,
		   p_calc_type             VARCHAR2,
		   p_salesrep_option       VARCHAR2,
		   p_hierarchy_flag        VARCHAR2,
		   p_intelligent_flag      VARCHAR2,
		   p_interval_type_id      NUMBER,
		   p_salesrep_id           NUMBER,
		   p_quota_id              NUMBER  );

  PROCEDURE calc_curr(errbuf      OUT NOCOPY  	   VARCHAR2,
		   retcode        OUT NOCOPY 	   NUMBER,
		   p_batch_name            VARCHAR2,
		   p_start_date            VARCHAR2,
		   p_end_date              VARCHAR2,
		   p_calc_type             VARCHAR2,
		   p_salesrep_option       VARCHAR2,
		   p_hierarchy_flag        VARCHAR2,
		   p_intelligent_flag      VARCHAR2,
		   p_salesrep_id           NUMBER);

 PROCEDURE collection(
		    errbuf      OUT NOCOPY    	   VARCHAR2
		   ,retcode     OUT NOCOPY    	   NUMBER
		   ,p_start_date           DATE
		   ,p_end_date             DATE
		   ,p_salesrep_id          NUMBER
		   ,p_comp_plan_id         NUMBER);

 -- Name
 --
 -- Purpose
 --
 -- Notes
 --   Called from calculation submission form CNSBCS
 --
 PROCEDURE calculation_submission(	p_calc_sub_batch_id 	NUMBER,
					x_process_audit_id  OUT NOCOPY NUMBER,
					x_process_status_code OUT NOCOPY VARCHAR2 );


 -- Name
 --
 -- Purpose
 --
 -- Notes
 --
 --
 PROCEDURE runner( errbuf       OUT NOCOPY     VARCHAR2
		   ,retcode      OUT NOCOPY     NUMBER
		   ,p_parent_proc_audit_id      NUMBER
		   ,p_logical_process		VARCHAR2
		   ,p_physical_process  	VARCHAR2
		   ,p_physical_batch_id 	NUMBER
		   ,p_salesrep_id               NUMBER   := NULL
		   ,p_start_date                DATE     := NULL
		   ,p_end_date                  DATE     := NULL
		   ,p_cls_rol_flag              VARCHAR2 := NULL);

 -- Name
 --
 -- Purpose
 --
 -- Notes
 --
 --
 PROCEDURE processor(
		    errbuf      OUT NOCOPY    	   VARCHAR2
		   ,retcode     OUT NOCOPY    	   NUMBER
		   ,p_parent_proc_audit_id NUMBER
		   ,p_concurrent_flag	   VARCHAR2
		   ,p_process_name     	   VARCHAR2
		   ,p_logical_batch_id 	   NUMBER
		   ,p_start_date           DATE
		   ,p_end_date             DATE
		   ,p_salesrep_id          NUMBER
		   ,p_comp_plan_id         NUMBER);

 -- processor concurrent wrapper on top of processor, called by the concurrent program CN_BATPROC.
 -- Do the Canonical-to-Date conversion on the date prarmeters, bug 2610735

  PROCEDURE processor_curr(
		    errbuf      OUT NOCOPY    	   VARCHAR2
		   ,retcode     OUT NOCOPY    	   NUMBER
		   ,p_parent_proc_audit_id NUMBER
		   ,p_concurrent_flag	   VARCHAR2
		   ,p_process_name     	   VARCHAR2
		   ,p_logical_batch_id 	   NUMBER
		   ,p_start_date           VARCHAR2
		   ,p_end_date             VARCHAR2
		   ,p_salesrep_id          NUMBER
		   ,p_comp_plan_id         NUMBER);

 -- Name
 --
 -- Purpose
 --
 -- Notes
 --
 --

 PROCEDURE main(   p_concurrent_flag           	VARCHAR2 DEFAULT 'N'
		   ,p_process_name     		VARCHAR2 DEFAULT 'CALCULATION'
		   ,p_logical_batch_id 		NUMBER
		   ,p_start_date                DATE
		   ,p_end_date                  DATE
		   ,p_salesrep_id      		NUMBER
		   ,p_comp_plan_id     		NUMBER
		   ,x_process_audit_id	 IN OUT NOCOPY NUMBER
		   ,x_process_status_code   OUT NOCOPY VARCHAR2);

  FUNCTION get_period_name (	x_period_id IN NUMBER,
                                    p_org_id IN NUMBER  ) RETURN VARCHAR2;

  PROCEDURE get_person_name_num (   x_salesrep_id NUMBER,
                                    p_org_id NUMBER,
				    x_name  IN OUT NOCOPY  VARCHAR2,
				    x_num   IN OUT NOCOPY  varchar2);

  PROCEDURE populate_process_batch(p_calc_sub_batch_id NUMBER);

  FUNCTION  validate_ruleset_status(p_start_date  DATE,
                                    p_end_date DATE,
                                    p_org_id NUMBER  ) RETURN BOOLEAN;

  -- Name
  --   check_end_of_interval
  -- Purpose
  --   Returns 1 if the specified period is the end of an interval of the
  --  type listed int he X_Interval string.
  -- History
  --  06/13/95	Created 	Rjin
  --
  FUNCTION check_end_of_interval(p_period_id NUMBER,
                                 p_interval_type_id NUMBER,
                                 p_org_id NUMBER) RETURN BOOLEAN;


END CN_PROC_BATCHES_PKG;
 

/
