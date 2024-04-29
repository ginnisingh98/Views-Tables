--------------------------------------------------------
--  DDL for Package QLTCPDFB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QLTCPDFB" AUTHID CURRENT_USER as
/* $Header: qltcpdfb.pls 115.2 2002/11/27 19:24:02 jezheng ship $ */

-- Copy Defaults
--
-- Called by QLTPLMDF form (Quality Plan Workbench) to copy default
-- values, action triggers, and actions from qa_char_value_lookups,
-- qa_char_action_triggers, and qa_char_actions into qa_plan_char_xxxx
-- tables.

-- dmaggard 110.17/94 created.


  PROCEDURE Insert_Rows (
			X_Copy_Values			NUMBER,
			X_Copy_Actions			NUMBER,
		       	X_Plan_Id                       NUMBER,
		       	X_Char_Id			NUMBER,
                       	X_Last_Update_Date              DATE,
                      	X_Last_Updated_By               NUMBER,
                       	X_Creation_Date                 DATE,
                       	X_Created_By                    NUMBER,
                       	X_Last_Update_Login             NUMBER DEFAULT NULL,
			X_values_found		IN OUT	NOCOPY NUMBER,
			X_actions_found		IN OUT	NOCOPY NUMBER
		      	);

END QLTCPDFB;

 

/
