--------------------------------------------------------
--  DDL for Package PER_BUDGET_ELEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BUDGET_ELEMENTS_PKG" AUTHID CURRENT_USER as
/* $Header: pebge01t.pkh 115.3 2004/02/16 10:52:40 nsanghal ship $ */

PROCEDURE Insert_Row(X_Rowid                          IN  OUT NOCOPY VARCHAR2,
                     X_Budget_Element_Id              IN  OUT NOCOPY NUMBER,
                     X_Business_Group_Id                    NUMBER,
                     X_Grade_Id                             NUMBER,
                     X_Job_Id                               NUMBER,
                     X_Position_Id                          NUMBER,
                     X_Organization_Id                      NUMBER,
                     X_Budget_Version_Id                    NUMBER,
		     X_Training_Plan_Id                     NUMBER,
	             X_Training_Plan_Member_Id              NUMBER,
                     X_Event_Id                             NUMBER);

PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Budget_Element_Id                      NUMBER,
                   X_Business_Group_Id                      NUMBER,
                   X_Grade_Id                               NUMBER,
                   X_Job_Id                                 NUMBER,
                   X_Position_Id                            NUMBER,
                   X_Organization_Id                        NUMBER,
                   X_Budget_Version_Id                      NUMBER,
		   X_Training_Plan_Id                       NUMBER,
	           X_Training_Plan_Member_Id                NUMBER,
                   X_Event_Id                               NUMBER);

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Budget_Element_Id                   NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Grade_Id                            NUMBER,
                     X_Job_Id                              NUMBER,
                     X_Position_Id                         NUMBER,
                     X_Organization_Id                     NUMBER,
                     X_Budget_Version_Id                   NUMBER,
		     X_Training_Plan_Id                    NUMBER,
	             X_Training_Plan_Member_Id             NUMBER,
                     X_Event_Id                            NUMBER);

PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END PER_BUDGET_ELEMENTS_PKG;

 

/
