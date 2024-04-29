--------------------------------------------------------
--  DDL for Package CN_SRP_PER_QUOTA_RC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SRP_PER_QUOTA_RC_PKG" AUTHID CURRENT_USER as
/* $Header: cnsrprcs.pls 120.0 2005/06/06 17:46:43 appldev noship $ */
--
-- 08-SEP-99 Modified the package with new parameters, start_date, end_date
--           Modified the packages with new tables.

--Date      Name          Description
----------------------------------------------------------------------------+
--Name

--Purpose

--Notes
--
-- Procedure Name
--
-- History
--
--
PROCEDURE insert_record( x_srp_plan_assign_id NUMBER
			 ,x_quota_id	      NUMBER
			 ,x_revenue_class_id  NUMBER
			 ,x_start_period_id   NUMBER
			 ,x_end_period_id     NUMBER
			 ,x_start_date        DATE := NULL
			 ,x_end_date          DATE := NULL );
--
-- Procedure Name
--
-- History
--
--
PROCEDURE delete_record( x_srp_plan_assign_id NUMBER
			 ,x_quota_id	      NUMBER
			 ,x_revenue_class_id  NUMBER
			 ,x_start_period_id   NUMBER
			 ,x_end_period_id     NUMBER
			 ,x_start_date        DATE := NULL
			 ,x_end_date          DATE := NULL );

END CN_SRP_PER_QUOTA_RC_PKG;
 

/
