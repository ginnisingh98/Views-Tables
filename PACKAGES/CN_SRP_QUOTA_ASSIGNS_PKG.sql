--------------------------------------------------------
--  DDL for Package CN_SRP_QUOTA_ASSIGNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SRP_QUOTA_ASSIGNS_PKG" AUTHID CURRENT_USER as
-- $Header: cnsrplbs.pls 115.5 2002/01/23 05:39:49 hlchen ship $
--
-- Package Body Name
--   CNSRPL_quota_assign_PKG
-- Purpose
--   Form	- CNSRPL
--   Block	- quota_assign
-- History
--   01/26/94		Tony Lower		Created
--   06/02/99           Kumar Sivasankaran      Modified

PROCEDURE insert_record(
                        x_srp_plan_assign_id           NUMBER
			,x_quota_id                    NUMBER);

PROCEDURE lock_record(
		       x_srp_quota_assign_id           NUMBER
                       ,x_target                       NUMBER
		       ,x_customized_flag	       VARCHAR2
		       ,x_period_target_dist_rule_code VARCHAR2
		       ,x_payment_amount	       NUMBER
                       ,x_performance_goal             NUMBER
		       ,x_period_target_unit_code      VARCHAR2);

PROCEDURE update_srp_quota(
			   x_quota_id		        NUMBER
			   ,x_target                    NUMBER
			   ,x_payment_amount	        NUMBER
			   ,x_performance_goal          NUMBER
			   ,x_rate_schedule_id	        NUMBER
			   ,x_rate_schedule_id_old      NUMBER
			   ,x_disc_rate_schedule_id     NUMBER
			   ,x_disc_rate_schedule_id_old NUMBER
			   ,x_payment_type_code		VARCHAR2
			   ,x_payment_type_code_old	VARCHAR2
			   ,x_quota_type_code		VARCHAR2
			   ,x_quota_type_code_old	VARCHAR2
			   ,x_period_type_code	        VARCHAR2
			   ,x_calc_formula_id           NUMBER := NULL
			   ,x_calc_formula_id_old       NUMBER := NULL);

PROCEDURE update_record(
			 x_srp_quota_assign_id           NUMBER
			 ,x_target                       NUMBER
			 ,x_target_old                   NUMBER
			 ,x_start_period_id		 NUMBER
			 ,x_salesrep_id			 NUMBER
			 ,x_Customized_Flag              VARCHAR2
			 ,x_Customized_Flag_old          VARCHAR2
			 ,x_quota_id			 NUMBER
			 ,x_rate_schedule_id		 NUMBER
			 ,x_period_target_dist_rule_code VARCHAR2
			 ,x_attributes_changed		 VARCHAR2
			 ,x_distribute_target_flag	 VARCHAR2
			 ,x_payment_amount		 NUMBER
			 ,x_payment_amount_old		 NUMBER
			 ,x_performance_goal             NUMBER
			 ,x_performance_goal_old         NUMBER
			 ,x_quota_type_code	         VARCHAR2
			 ,x_period_target_unit_code	 VARCHAR2
			 ,x_last_update_date		 DATE
			 ,x_last_updated_by		 NUMBER
			 ,x_last_update_login		 NUMBER);

PROCEDURE Delete_Record(
			 x_srp_plan_assign_id  		 NUMBER
			 ,x_quota_id	       		 NUMBER);


  END cn_srp_quota_assigns_pkg;

 

/
