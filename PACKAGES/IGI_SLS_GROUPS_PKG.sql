--------------------------------------------------------
--  DDL for Package IGI_SLS_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_SLS_GROUPS_PKG" AUTHID CURRENT_USER as
-- $Header: igislsss.pls 120.4.12000000.1 2007/09/03 17:22:50 vspuli ship $


     PROCEDURE Insert_Row(
        X_Sls_Group                          VARCHAR2,
        X_Sls_Group_Type                     VARCHAR2,
        X_Description                        VARCHAR2,
        X_Date_Enabled                       DATE,
        X_Date_Disabled                      DATE,
	X_Date_Removed                       DATE,
        X_Date_Security_Applied              DATE,
        X_Creation_Date                      DATE,
        X_Created_By                         NUMBER
                          );



  END IGI_SLS_GROUPS_PKG;

 

/
