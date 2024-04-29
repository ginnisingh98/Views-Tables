--------------------------------------------------------
--  DDL for Package CN_SRP_PERIOD_QUOTAS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SRP_PERIOD_QUOTAS_PKG" AUTHID CURRENT_USER as
/* $Header: cnsrpqos.pls 120.0 2005/06/06 17:59:19 appldev noship $ */

/*
Date      Name          Description
  ----------------------------------------------------------------------------+
  10-JUN-99 S. Kumar    Modifiying the Package from Period ID to Date Effty

  Name

  Purpose

  Notes

  10-JUN-99 Modifying this package

  10-AUG-99 Added the Performance Goal Column and the begin record parameter

  */
  ----------------------------------------------------------------------------+
  -- PROCEDURE BEGIN_RECORD
  ----------------------------------------------------------------------------+
  PROCEDURE Begin_Record(
			 x_operation  	     		VARCHAR2
			 ,x_period_target_unit_code	VARCHAR2
			 ,x_srp_period_quota_id 	NUMBER
			 ,x_srp_quota_assign_id 	NUMBER
			 ,x_srp_plan_assign_id  	NUMBER
			 ,x_quota_id            	NUMBER
			 ,x_period_id           	NUMBER
			 ,x_target_amount       	NUMBER
			 ,x_period_payment		NUMBER
                         ,x_performance_goal            NUMBER
			 ,x_quarter_num	     		NUMBER
			 ,x_period_year 	     	NUMBER
			 ,x_quota_type_code     	VARCHAR2
                         ,x_salesrep_id                 NUMBER := NULL -- only for bonus pay
                         ,x_end_date                    DATE   := NULL -- only for bonus pay
                         ,x_commission_payed_ptd        NUMBER := NULL -- only for bonus pay
			 ,x_creation_date		DATE
			 ,x_created_by			NUMBER
			 ,x_last_update_date		DATE
			 ,x_last_updated_by		NUMBER
			 ,x_last_update_login		NUMBER);

-- Name
--
-- Purpose
--
-- Notes
--  Not called by srmt form
--
----------------------------------------------------------------------------+
-- PROCEDURE INSERT_RECORD
-- DESC: called from cn_srp_quota_assigns with srp_plan_assign_id,x_quota_id
--       x_start_period_id is Null, x_end_period_id null
--       for more info set the body
----------------------------------------------------------------------------+
PROCEDURE Insert_Record(
 		        x_srp_plan_assign_id           NUMBER
			,x_quota_id		       NUMBER
			,x_start_period_id	       NUMBER := NULL
			,x_end_period_id	       NUMBER := NULL
			,x_start_date                  DATE   := NULL
			,x_end_date                    DATE   := NULL);
-- Name
--
-- Purpose
--
-- Notes
--  Not called by srmt form
--
  ----------------------------------------------------------------------------+
  -- PROCEDURE DELETE_RECORD
  ----------------------------------------------------------------------------+
PROCEDURE Delete_Record( x_srp_plan_assign_id         NUMBER
			 ,x_quota_id                  NUMBER
			 ,x_start_period_id	      NUMBER
			 ,x_end_period_id	      NUMBER
                         ,x_start_date                DATE := NULL
                         ,x_end_date                  DATE := NULL);

  ----------------------------------------------------------------------------+
  -- PROCEDURE to populate cn_srp_period_quotas_ext table
  ----------------------------------------------------------------------------+

PROCEDURE populate_srp_period_quotas_ext
  (x_operation  	        VARCHAR2,
   x_srp_period_quota_id 	NUMBER,
   x_org_id                     NUMBER,
   x_number_dim                 NUMBER := fnd_api.g_miss_num);


  ----------------------------------------------------------------------------+
  -- PROCEDURE DISTRIBUTE_TARGET
  ----------------------------------------------------------------------------+
PROCEDURE Distribute_Target(
			     x_srp_quota_assign_id    NUMBER
			     ,x_target	              NUMBER
			     ,x_period_target_unit_code VARCHAR2);
  ----------------------------------------------------------------------------+
  -- PROCEDURE SELECT_SUMMARY
  ----------------------------------------------------------------------------+
PROCEDURE Select_Summary( x_srp_quota_assign_id	      NUMBER
			  ,x_total	       IN OUT NOCOPY NUMBER
			  ,x_total_rtot_db     IN OUT NOCOPY NUMBER);
  ----------------------------------------------------------------------------+
  -- PROCEDURE SYNCH_TARGET
  ----------------------------------------------------------------------------+
PROCEDURE Synch_Target ( x_srp_plan_assign_id  	      NUMBER
			 ,x_quota_id                  NUMBER);

PROCEDURE sync_ITD_values (X_Quota_Id  	 NUMBER);

PROCEDURE populate_itd_values (x_start_srp_period_quota_id NUMBER);
--| ---------------------------------------------------------------------+
--| Function Name :  next_period
--| ---------------------------------------------------------------------+
FUNCTION cn_end_date_period(p_end_date DATE, p_org_id NUMBER)
   RETURN cn_acc_period_statuses_v.end_date%TYPE ;

END CN_SRP_PERIOD_QUOTAS_PKG;
 

/
