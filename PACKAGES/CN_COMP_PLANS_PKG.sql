--------------------------------------------------------
--  DDL for Package CN_COMP_PLANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_COMP_PLANS_PKG" AUTHID CURRENT_USER as
/* $Header: cnplipls.pls 120.0.12010000.2 2008/08/30 08:01:51 ramchint ship $ */
--
--Date      Name          Description
----------------------------------------------------------------------------+
--  Modified the table handler with the start date and end date for periods
--  Modified Date 06/30/99
--Name
--
--Purpose
--
--Notes

-- Name
--
-- Purpose
--
-- Notes
--
--
 PROCEDURE Begin_Record
  (
   X_Operation                VARCHAR2
   ,X_Rowid            IN OUT NOCOPY  VARCHAR2
   ,X_Comp_Plan_Id     IN OUT NOCOPY  NUMBER
   ,X_Name                     VARCHAR2
   ,X_Last_Update_Date         DATE
   ,X_Last_Updated_By          NUMBER
   ,X_Creation_Date            DATE
   ,X_Created_By               NUMBER
   ,X_Last_Update_Login        NUMBER
   ,X_Description              VARCHAR2
   ,X_Start_date               DATE
   ,X_Start_date_old           DATE
   ,X_end_date                 DATE
   ,X_end_date_old             DATE
   ,X_Program_Type             VARCHAR2
   ,x_status_code              VARCHAR2
   ,x_allow_rev_class_overlap  VARCHAR2
   ,x_allow_rev_class_overlap_old VARCHAR2
   ,x_sum_trx_flag                VARCHAR2
   ,x_attribute_category       VARCHAR2
   ,x_attribute1               VARCHAR2
   ,x_attribute2               VARCHAR2
   ,x_attribute3               VARCHAR2
   ,x_attribute4               VARCHAR2
   ,x_attribute5               VARCHAR2
   ,x_attribute6               VARCHAR2
   ,x_attribute7               VARCHAR2
   ,x_attribute8               VARCHAR2
   ,x_attribute9               VARCHAR2
   ,x_attribute10              VARCHAR2
   ,x_attribute11              VARCHAR2
   ,x_attribute12              VARCHAR2
   ,x_attribute13              VARCHAR2
   ,x_attribute14              VARCHAR2
   ,x_attribute15              VARCHAR2
   ,x_ORG_ID                   NUMBER
  ) ;
-- Name
--
-- Purpose
--
-- Notes
--
--
PROCEDURE End_Record(
		     X_Rowid       	 	VARCHAR2  ,
		     X_Comp_Plan_Id       	NUMBER    ,
		     X_Name                   	VARCHAR2  ,
		     X_Description            	VARCHAR2  ,
		     x_start_date         	DATE      ,
		     X_End_date          	DATE      ,
		     X_Program_Type		VARCHAR2  ,
		     x_status_code		VARCHAR2  ,
		     x_allow_rev_class_overlap	VARCHAR2,
         x_sum_trx_flag             VARCHAR2
		     );

-- Name
--
-- Purpose
--
-- Notes
--  Must be public as called on when-validate-item
--  debug remove this
FUNCTION Check_Unique( X_Comp_Plan_Id   NUMBER
			,X_Name  	 VARCHAR2) RETURN BOOLEAN;

-- Procedure Name
--  Check_unique_rev_class
-- Purpose
--  Ensure there are no duplicate revenue classes assigned to a comp plan.
FUNCTION check_unique_rev_class
  ( x_comp_plan_id             NUMBER
    ,x_name                     VARCHAR2
    ,x_allow_rev_class_overlap  VARCHAR2
    ,x_sum_trx_flag VARCHAR2) RETURN BOOLEAN;


-- Name
--
-- Purpose
--
-- Notes
--
--
PROCEDURE Set_Status(  x_comp_plan_id        	NUMBER
		       ,x_quota_id		NUMBER
		       ,x_rate_schedule_id	NUMBER
		       ,x_status_code   	VARCHAR2
		       ,x_event		        VARCHAR2);
-- Name
--
-- Purpose
--
-- Notes
--
--
PROCEDURE Get_status( X_Comp_Plan_Id           NUMBER
		      ,X_status_code	IN OUT NOCOPY VARCHAR2
		      ,x_status	IN OUT NOCOPY         VARCHAR2);
-- Name
--
-- Purpose
--
-- Notes
--  Must be public as called on key-delrec
--
FUNCTION Check_Assigned( X_Comp_Plan_Id  NUMBER) RETURN BOOLEAN;

-- Name
--
-- Purpose
--
-- Notes
--
--
FUNCTION Check_period_range(  X_Comp_Plan_Id  	NUMBER
			       ,x_start_date    DATE
			       ,x_end_date      DATE ) RETURN BOOLEAN;

END CN_COMP_PLANS_PKG;

/
