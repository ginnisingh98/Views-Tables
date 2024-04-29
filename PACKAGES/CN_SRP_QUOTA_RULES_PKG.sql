--------------------------------------------------------
--  DDL for Package CN_SRP_QUOTA_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SRP_QUOTA_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: cnsrpqrs.pls 115.6 2002/01/23 05:40:12 hlchen ship $ */

/*
Date      Name          Description
----------------------------------------------------------------------------+
10-JUN-99 S.Kumar
Name

Purpose

Notes

*/

 PROCEDURE synch_target ( x_srp_quota_assign_id NUMBER);

 PROCEDURE update_record ( x_quota_rule_id    NUMBER
                           ,x_srp_quota_rule_id NUMBER := NULL
			   ,x_target	      NUMBER
			  ,x_payment_amount   NUMBER
			  ,x_performance_goal NUMBER);

  -- Name
  --+
  -- Purpose
  --+
  -- Notes
  --  Not called by srmt form
  --+
  PROCEDURE insert_record(
 		        x_srp_plan_assign_id    NUMBER
		       ,x_quota_id		NUMBER
		       ,x_quota_rule_id		NUMBER
		       ,x_revenue_class_id	NUMBER);

  -- Name
  --+
  -- Purpose
  --+
  -- Notes
  --  Not called by srmt form
  --+
  PROCEDURE delete_record( x_srp_plan_assign_id	 NUMBER
		          ,x_srp_quota_assign_id NUMBER
		          ,x_quota_id            NUMBER
		          ,x_quota_rule_id	 NUMBER
			  ,x_revenue_class_id	 NUMBER);


  -- Name
  --+
  -- Purpose lock the record from the FORM
  --+
  -- Notes
  -- +
  --+
    PROCEDURE lock_record
    (  x_srp_quota_rule_id       NUMBER
      ,x_target                  NUMBER
      ,x_payment_amount          NUMBER
      ,x_performance_goal        NUMBER ) ;

END cn_srp_quota_rules_pkg;

 

/
