--------------------------------------------------------
--  DDL for Package IGI_SLS_ALLOCATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_SLS_ALLOCATIONS_PKG" AUTHID CURRENT_USER as
--  $Header: igislsas.pls 120.3.12000000.1 2007/09/03 17:21:59 vspuli ship $


     PROCEDURE Insert_Row(
        X_Sls_Group                          VARCHAR2,
        X_Sls_Group_Type                     VARCHAR2,
        X_Sls_Allocation                     VARCHAR2,
        X_Sls_Allocation_Type                VARCHAR2,
        X_Date_Enabled                       DATE,
        X_Date_Disabled                      DATE,
        X_Date_Removed                       DATE,
        X_Creation_Date                      DATE,
        X_Created_By                         NUMBER

                          );



  END IGI_SLS_ALLOCATIONS_PKG;

 

/
