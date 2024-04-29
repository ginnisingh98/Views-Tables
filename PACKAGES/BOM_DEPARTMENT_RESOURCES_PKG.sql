--------------------------------------------------------
--  DDL for Package BOM_DEPARTMENT_RESOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_DEPARTMENT_RESOURCES_PKG" AUTHID CURRENT_USER as
/* $Header: bompbdrs.pls 120.0 2005/05/25 05:20:45 appldev noship $ */

PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                     X_Department_Id                  NUMBER,
                     X_Resource_Id                    NUMBER,
                     X_Last_Update_Date               DATE,
                     X_Last_Updated_By                NUMBER,
                     X_Creation_Date                  DATE,
                     X_Created_By                     NUMBER,
                     X_Last_Update_Login              NUMBER DEFAULT NULL,
                     X_Share_Capacity_Flag            NUMBER,
                     X_Share_From_Dept_Id             NUMBER DEFAULT NULL,
                     X_Capacity_Units                 NUMBER DEFAULT NULL,
                     X_Resource_Group_Name            VARCHAR2 DEFAULT NULL,
                     X_Available_24_Hours_Flag        NUMBER,
		     X_Ctp_Flag			      NUMBER,
                     X_Attribute_Category             VARCHAR2 DEFAULT NULL,
                     X_Attribute1                     VARCHAR2 DEFAULT NULL,
                     X_Attribute2                     VARCHAR2 DEFAULT NULL,
                     X_Attribute3                     VARCHAR2 DEFAULT NULL,
                     X_Attribute4                     VARCHAR2 DEFAULT NULL,
                     X_Attribute5                     VARCHAR2 DEFAULT NULL,
                     X_Attribute6                     VARCHAR2 DEFAULT NULL,
                     X_Attribute7                     VARCHAR2 DEFAULT NULL,
                     X_Attribute8                     VARCHAR2 DEFAULT NULL,
                     X_Attribute9                     VARCHAR2 DEFAULT NULL,
                     X_Attribute10                    VARCHAR2 DEFAULT NULL,
                     X_Attribute11                    VARCHAR2 DEFAULT NULL,
                     X_Attribute12                    VARCHAR2 DEFAULT NULL,
                     X_Attribute13                    VARCHAR2 DEFAULT NULL,
                     X_Attribute14                    VARCHAR2 DEFAULT NULL,
                     X_Attribute15                    VARCHAR2 DEFAULT NULL,
		     X_Exception_Set_Name	      VARCHAR2 DEFAULT NULL,
		     X_ATP_Rule_Id		      NUMBER DEFAULT NULL,
		     X_Utilization		      NUMBER DEFAULT NULL,
		     X_Efficiency		      NUMBER DEFAULT NULL,
		     X_Schedule_To_Instance	      NUMBER,
		     X_Sequencing_Window	      NUMBER DEFAULT NULL,       --APS Enhancement for Routings
	             X_Idle_Time_Tolerance	      NUMBER DEFAULT NULL        --APS Enhancement for Routings
                    );


PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                   X_Department_Id                    NUMBER,
                   X_Resource_Id                      NUMBER,
                   X_Share_Capacity_Flag              NUMBER,
                   X_Share_From_Dept_Id               NUMBER DEFAULT NULL,
                   X_Capacity_Units                   NUMBER DEFAULT NULL,
                   X_Resource_Group_Name              VARCHAR2 DEFAULT NULL,
                   X_Available_24_Hours_Flag          NUMBER,
		   X_Ctp_Flag                         NUMBER,
                   X_Attribute_Category               VARCHAR2 DEFAULT NULL,
                   X_Attribute1                       VARCHAR2 DEFAULT NULL,
                   X_Attribute2                       VARCHAR2 DEFAULT NULL,
                   X_Attribute3                       VARCHAR2 DEFAULT NULL,
                   X_Attribute4                       VARCHAR2 DEFAULT NULL,
                   X_Attribute5                       VARCHAR2 DEFAULT NULL,
                   X_Attribute6                       VARCHAR2 DEFAULT NULL,
                   X_Attribute7                       VARCHAR2 DEFAULT NULL,
                   X_Attribute8                       VARCHAR2 DEFAULT NULL,
                   X_Attribute9                       VARCHAR2 DEFAULT NULL,
                   X_Attribute10                      VARCHAR2 DEFAULT NULL,
                   X_Attribute11                      VARCHAR2 DEFAULT NULL,
                   X_Attribute12                      VARCHAR2 DEFAULT NULL,
                   X_Attribute13                      VARCHAR2 DEFAULT NULL,
                   X_Attribute14                      VARCHAR2 DEFAULT NULL,
                   X_Attribute15                      VARCHAR2 DEFAULT NULL,
		   X_Exception_Set_Name		      VARCHAR2 DEFAULT NULL,
                   X_ATP_Rule_Id                      NUMBER DEFAULT NULL,
                   X_Utilization                      NUMBER DEFAULT NULL,
                   X_Efficiency                       NUMBER DEFAULT NULL,
		   X_Schedule_To_Instance	      NUMBER,
		   X_Sequencing_Window	              NUMBER DEFAULT NULL,       --APS Enhancement for Routings
	           X_Idle_Time_Tolerance	      NUMBER DEFAULT NULL        --APS Enhancement for Routings
                  );


PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                     X_Department_Id                  NUMBER,
                     X_Resource_Id                    NUMBER,
                     X_Last_Update_Date               DATE,
                     X_Last_Updated_By                NUMBER,
                     X_Last_Update_Login              NUMBER DEFAULT NULL,
                     X_Share_Capacity_Flag            NUMBER,
                     X_Share_From_Dept_Id             NUMBER DEFAULT NULL,
                     X_Capacity_Units                 NUMBER DEFAULT NULL,
                     X_Resource_Group_Name            VARCHAR2 DEFAULT NULL,
                     X_Available_24_Hours_Flag        NUMBER,
		     X_Ctp_Flag                       NUMBER,
                     X_Attribute_Category             VARCHAR2 DEFAULT NULL,
                     X_Attribute1                     VARCHAR2 DEFAULT NULL,
                     X_Attribute2                     VARCHAR2 DEFAULT NULL,
                     X_Attribute3                     VARCHAR2 DEFAULT NULL,
                     X_Attribute4                     VARCHAR2 DEFAULT NULL,
                     X_Attribute5                     VARCHAR2 DEFAULT NULL,
                     X_Attribute6                     VARCHAR2 DEFAULT NULL,
                     X_Attribute7                     VARCHAR2 DEFAULT NULL,
                     X_Attribute8                     VARCHAR2 DEFAULT NULL,
                     X_Attribute9                     VARCHAR2 DEFAULT NULL,
                     X_Attribute10                    VARCHAR2 DEFAULT NULL,
                     X_Attribute11                    VARCHAR2 DEFAULT NULL,
                     X_Attribute12                    VARCHAR2 DEFAULT NULL,
                     X_Attribute13                    VARCHAR2 DEFAULT NULL,
                     X_Attribute14                    VARCHAR2 DEFAULT NULL,
                     X_Attribute15                    VARCHAR2 DEFAULT NULL,
		     X_Exception_Set_Name	      VARCHAR2 DEFAULT NULL,
                     X_ATP_Rule_Id                    NUMBER DEFAULT NULL,
                     X_Utilization                    NUMBER DEFAULT NULL,
                     X_Efficiency                     NUMBER DEFAULT NULL,
		     X_Schedule_To_Instance	      NUMBER,
		     X_Sequencing_Window	      NUMBER DEFAULT NULL,       --APS Enhancement for Routings
	             X_Idle_Time_Tolerance	      NUMBER DEFAULT NULL        --APS Enhancement for Routings
                    );


PROCEDURE Delete_Row(X_Rowid VARCHAR2);


PROCEDURE Check_Unique(X_Rowid VARCHAR2,
		       X_Department_Id NUMBER,
		       X_Resource_Id NUMBER);


PROCEDURE Check_References(X_Rowid VARCHAR2,
		 	   X_Resource_Id NUMBER,
			   X_Department_Id NUMBER);



END BOM_DEPARTMENT_RESOURCES_PKG;

 

/
