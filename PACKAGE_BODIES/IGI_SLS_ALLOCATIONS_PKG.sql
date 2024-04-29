--------------------------------------------------------
--  DDL for Package Body IGI_SLS_ALLOCATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_SLS_ALLOCATIONS_PKG" as
--  $Header: igislsab.pls 120.3.12000000.1 2007/09/03 17:21:55 vspuli ship $


     PROCEDURE Insert_Row(
                          X_Sls_Group           VARCHAR2,
                          X_Sls_Group_Type      VARCHAR2,
                          X_Sls_Allocation      VARCHAR2,
                          X_Sls_Allocation_Type VARCHAR2,
                          X_Date_Enabled        DATE,
                          X_Date_Disabled       DATE,
                          X_Date_Removed        DATE,
                          X_Creation_Date       DATE,
                          X_Created_By          NUMBER
      ) IS

        BEGIN

            INSERT INTO igi_sls_allocations_audit(
                           sls_group,
                           sls_group_type,
                           sls_allocation,
                           sls_allocation_type,
                           date_enabled,
                           date_disabled,
                           date_removed,
                           created_by,
                           creation_date
                         )
                  VALUES (
                           X_Sls_Group,
                           X_Sls_Group_Type,
                           X_Sls_Allocation,
                           X_Sls_Allocation_Type,
                           X_Date_Enabled,
                           X_Date_Disabled,
                           X_Date_Removed,
                           X_Created_By,
                           X_Creation_Date
                         );

     END Insert_Row;


END IGI_SLS_ALLOCATIONS_PKG;

/
