--------------------------------------------------------
--  DDL for Package CN_SRP_RATE_ASSIGNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SRP_RATE_ASSIGNS_PKG" AUTHID CURRENT_USER as
-- $Header: cnsrplcs.pls 115.7 2002/01/23 05:39:56 hlchen ship $
--
-- Package Body Name
--
-- Purpose
--   Form	- cnsrmt cnpldf
--   Block	- rate_assign
-- History
-- 26-JAN-94	Tony Lower	Created
-- 10-FEB-94	P Cook		Table handler conversion and unit test
-- 10-JUN-99    S Kumar         Modified the Table handler for the New reqmts

  PROCEDURE Insert_Record(
                        X_Srp_Plan_Assign_Id             NUMBER
                       ,X_Srp_Quota_Assign_Id            NUMBER
                       ,X_Srp_Rate_Assign_Id             NUMBER
		       ,X_quota_id			 NUMBER
		       ,X_rate_schedule_id  		 NUMBER
                       ,x_rt_quota_asgn_id               NUMBER := null
		       ,X_Rate_Tier_Id                   NUMBER
                       ,X_Commission_Rate                NUMBER
		       ,x_commission_amount		 NUMBER
		       ,x_disc_rate_table_flag		 VARCHAR2
                       ,x_rate_sequence                  NUMBER := null
                      );

  PROCEDURE Lock_Record(
                        X_Srp_Plan_Assign_Id             NUMBER
                       ,X_Srp_Quota_Assign_Id            NUMBER
                       ,X_Srp_Rate_Assign_Id             NUMBER
                       ,X_Rate_Tier_Id                   NUMBER
                       ,X_Commission_Rate                NUMBER
		       ,x_commission_amount		 NUMBER);

  PROCEDURE Update_Record(
                        X_Srp_Plan_Assign_Id             NUMBER
                       ,X_Srp_Quota_Assign_Id            NUMBER
                       ,X_Srp_Rate_Assign_Id             NUMBER
                       ,X_Rate_Tier_Id                   NUMBER
                       ,X_Commission_Rate                NUMBER
                       ,X_Commission_Rate_old            NUMBER
		       ,x_start_period_id		 NUMBER
		       ,x_salesrep_id			 NUMBER
		       ,x_commission_amount		 NUMBER
		       ,x_commission_amount_old		 NUMBER
      			,x_last_update_date		 DATE
      			,x_last_updated_by		 NUMBER
     			,x_last_update_login		 NUMBER);

  PROCEDURE Delete_record(
			x_srp_plan_assign_id  	NUMBER
		       ,x_srp_rate_assign_id	NUMBER
		       ,x_quota_id		NUMBER
		       ,x_rate_schedule_id	NUMBER
                       ,x_rt_quota_asgn_id      NUMBER := null
		       ,x_rate_tier_id	  	NUMBER);

  PROCEDURE synch_rate(
			  x_srp_plan_assign_id  NUMBER
			 ,x_srp_quota_assign_id NUMBER
			 ,x_rate_schedule_id	NUMBER
			 ,x_rate_tier_id	NUMBER
			 ,x_commission_rate	NUMBER
			 ,x_salesrep_id		NUMBER
			 ,x_start_period_id	NUMBER
			 ,x_commission_amount   NUMBER);


END cn_srp_rate_assigns_pkg;

 

/
