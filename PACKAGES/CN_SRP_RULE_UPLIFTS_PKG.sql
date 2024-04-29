--------------------------------------------------------
--  DDL for Package CN_SRP_RULE_UPLIFTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SRP_RULE_UPLIFTS_PKG" AUTHID CURRENT_USER as
/* $Header: cnsrprus.pls 120.0 2005/06/06 17:45:17 appldev noship $ */

/*
Date      Name          Description
----------------------------------------------------------------------------+

Name

Purpose

Notes


*/

   PROCEDURE insert_record
  (
   p_srp_plan_assign_id      NUMBER
  ,p_quota_id                NUMBER
  ,p_quota_rule_id           NUMBER
   ,p_quota_rule_uplift_id   NUMBER := NULL
   ) ;

  -- Procedure Name
  -- Update_record
  -- Purpose
  -- Upate  the Quota Rule Uplift from from
  -- Notes
  --    +

  PROCEDURE update_record(
			  p_srp_rule_uplift_id           NUMBER
                          ,p_payment_factor              NUMBER
			  ,p_quota_factor                NUMBER
			  ,p_last_update_date		 DATE
			  ,p_last_updated_by		 NUMBER
			  ,p_last_update_login		 NUMBER) ;

  -- Procedure Name
  --  Delete_record
  -- Purpose
  -- Delete will be called from different place
  -- 1. Delete the srp_rule_uplift directly.
  -- 2. delete the srp_quota_rules
  -- 3. delete the srp_quota_assigns
  -- 4. delete the quota_assigns
  -- 5. delete the quota_rule_uplifts
  -- 6. delete the quota_rules
  -- 7. delete the quotas.

  -- Notes
  --   +

    PROCEDURE Delete_record
  (
   p_srp_plan_assign_id       NUMBER
   ,p_quota_id                NUMBER
   ,p_quota_rule_id           NUMBER
   ,p_quota_rule_uplift_id    NUMBER := NULL
   ) ;

  PROCEDURE update_record (p_quota_rule_uplift_id  NUMBER
			  ,p_quota_factor   NUMBER
                          ,p_payment_factor NUMBER) ;

END cn_srp_rule_uplifts_pkg;
 

/
