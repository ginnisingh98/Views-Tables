--------------------------------------------------------
--  DDL for Package PA_EXPENDITURE_CATEGORIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_EXPENDITURE_CATEGORIES_PUB" AUTHID CURRENT_USER as
/* $Header: PAXECPBS.pls 120.1 2005/08/03 11:49:30 aaggarwa noship $ */


 PROCEDURE INSERT_ROW( X_Expenditure_Category 	    VARCHAR2,
		       X_Last_update_date 	    DATE,
		       X_Last_updated_by 	    NUMBER,
		       X_Creation_date	 	    DATE,
		       X_Created_by 		    NUMBER,
		       X_Last_update_login 	    NUMBER,
		       X_Start_date_active 	    DATE,
          	       X_Description 		    VARCHAR2,
	               X_End_date_active 	    DATE,
		       X_Attribute_category 	    VARCHAR2,
		       X_Attribute1 		    VARCHAR2,
		       X_Attribute2 		    VARCHAR2,
	 	       X_Attribute3 		    VARCHAR2,
                       X_Attribute4 		    VARCHAR2,
                       X_Attribute5 		    VARCHAR2,
                       X_Attribute6 		    VARCHAR2,
                       X_Attribute7 		    VARCHAR2,
                       X_Attribute8 		    VARCHAR2,
                       X_Attribute9 		    VARCHAR2,
                       X_Attribute10 		    VARCHAR2,
                       X_Attribute11 		    VARCHAR2,
                       X_Attribute12 		    VARCHAR2,
                       X_Attribute13 		    VARCHAR2,
                       X_Attribute14 		    VARCHAR2,
                       X_Attribute15		    VARCHAR2,
		       X_Return_Status	OUT NOCOPY	    VARCHAR2,
		       X_Msg_Count	OUT NOCOPY	    NUMBER,
		       X_Msg_Data       OUT NOCOPY         VARCHAR2
                      );

  PROCEDURE LOCK_ROW(  X_Expenditure_Category 	    VARCHAR2,
		       X_Last_update_date 	    DATE,
		       X_Last_updated_by 	    NUMBER,
		       X_Creation_date	 	    DATE,
		       X_Created_by 		    NUMBER,
		       X_Last_update_login 	    NUMBER,
		       X_Start_date_active 	    DATE,
          	       X_Description 		    VARCHAR2,
	               X_End_date_active 	    DATE,
		       X_Attribute_category 	    VARCHAR2,
		       X_Attribute1 		    VARCHAR2,
		       X_Attribute2 		    VARCHAR2,
	 	       X_Attribute3 		    VARCHAR2,
                       X_Attribute4		    VARCHAR2,
                       X_Attribute5 		    VARCHAR2,
                       X_Attribute6 		    VARCHAR2,
                       X_Attribute7		    VARCHAR2,
                       X_Attribute8 		    VARCHAR2,
                       X_Attribute9		    VARCHAR2,
                       X_Attribute10 		    VARCHAR2,
                       X_Attribute11 		    VARCHAR2,
                       X_Attribute12 		    VARCHAR2,
                       X_Attribute13 		    VARCHAR2,
                       X_Attribute14 		    VARCHAR2,
                       X_Attribute15		    VARCHAR2,
		       X_Return_Status	OUT NOCOPY	    VARCHAR2,
		       X_Msg_Count	OUT NOCOPY	    NUMBER,
		       X_Msg_Data       OUT NOCOPY         VARCHAR2
                      );


 PROCEDURE UPDATE_ROW( X_Expenditure_Category 	    VARCHAR2,
		       X_Last_update_date 	    DATE,
		       X_Last_updated_by 	    NUMBER,
		       X_Creation_date	 	    DATE,
		       X_Created_by		    NUMBER,
		       X_Last_update_login 	    NUMBER,
		       X_Start_date_active 	    DATE,
          	       X_Description		    VARCHAR2,
	               X_End_date_active 	    DATE,
		       X_Attribute_category 	    VARCHAR2,
		       X_Attribute1 		    VARCHAR2,
		       X_Attribute2 		    VARCHAR2,
	 	       X_Attribute3 		    VARCHAR2,
                       X_Attribute4 		    VARCHAR2,
                       X_Attribute5 		    VARCHAR2,
                       X_Attribute6 		    VARCHAR2,
                       X_Attribute7 		    VARCHAR2,
                       X_Attribute8 		    VARCHAR2,
                       X_Attribute9 		    VARCHAR2,
                       X_Attribute10 		    VARCHAR2,
                       X_Attribute11 		    VARCHAR2,
                       X_Attribute12 		    VARCHAR2,
                       X_Attribute13 		    VARCHAR2,
                       X_Attribute14		    VARCHAR2,
                       X_Attribute15		    VARCHAR2,
		       X_Return_Status	OUT NOCOPY	    VARCHAR2,
		       X_Msg_Count	OUT NOCOPY	    NUMBER,
		       X_Msg_Data       OUT NOCOPY         VARCHAR2
                      );


END PA_EXPENDITURE_CATEGORIES_PUB;
 

/
