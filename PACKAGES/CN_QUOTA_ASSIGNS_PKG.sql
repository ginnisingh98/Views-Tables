--------------------------------------------------------
--  DDL for Package CN_QUOTA_ASSIGNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_QUOTA_ASSIGNS_PKG" AUTHID CURRENT_USER as
/* $Header: cnpliqas.pls 120.2 2005/07/05 09:12:07 appldev ship $ */

  PROCEDURE Begin_Record(
		    X_Operation			VARCHAR2 ,
                    X_Quota_Id        		NUMBER	 ,
                    X_Comp_Plan_Id      	NUMBER	 ,
		    X_Quota_Assign_Id   IN OUT NOCOPY 	NUMBER	 ,
		    X_Quota_Sequence            NUMBER   ,
		    x_quota_id_old		NUMBER,
        x_org_id          NUMBER	 );

  PROCEDURE Check_exists(  X_Quota_Id	     NUMBER);


  PROCEDURE Check_duplicate( x_quota_id	       NUMBER
			    ,x_quota_assign_id NUMBER
			    ,x_comp_plan_id    NUMBER);

  -- Name
  --
  -- Purpose
  --
  -- Notes
  --
  --

  PROCEDURE get_quota_info( x_quota_id		NUMBER
			   ,x_name	IN OUT NOCOPY 	VARCHAR2
			   ,x_quota_type_code	IN OUT NOCOPY VARCHAR2);
/*
  -- Name
  --
  -- Purpose
  --
  -- Notes
  --
  --
  PROCEDURE Delete_Record( X_Quota_Assign_Id  	NUMBER
			  ,X_Comp_Plan_Id     	NUMBER
			  ,x_quota_id		NUMBER);
*/
END CN_QUOTA_ASSIGNS_PKG;
 

/
