--------------------------------------------------------
--  DDL for Package BOM_COMPARISON_TEMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_COMPARISON_TEMP_PKG" AUTHID CURRENT_USER as
/* $Header: bompbcps.pls 115.1 99/07/16 05:47:18 porting ship $ */


PROCEDURE Get_Sequence_and_Commons ( X_Sequence_Id 	         IN OUT NUMBER,
				     X_Common_Bill_Sequence_Id1  IN OUT NUMBER,
				     X_Common_Bill_Sequence_Id2  IN OUT NUMBER,
				     X_Organization_Id1 NUMBER,
				     X_Organization_Id2 NUMBER,
				     X_Assembly_Item_Id1 NUMBER,
				     X_Assembly_Item_Id2 NUMBER,
				     X_Alternate1 VARCHAR2,
				     X_Alternate2 VARCHAR2 );


FUNCTION Get_Bill_Type ( X_Organization_Id NUMBER,
			 X_Assembly_Item_Id NUMBER,
			 X_Alternate VARCHAR2 ) RETURN NUMBER;


END BOM_COMPARISON_TEMP_PKG;

 

/
