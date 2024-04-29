--------------------------------------------------------
--  DDL for Package Body IGI_SLS_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_SLS_GROUPS_PKG" as
--  $Header: igislssb.pls 120.3.12000000.1 2007/09/03 17:22:46 vspuli ship $


     PROCEDURE Insert_Row(
                         X_Sls_Group             VARCHAR2,
                         X_Sls_Group_Type        VARCHAR2,
                         X_Description           VARCHAR2,
                         X_Date_Enabled          DATE,
                         X_Date_Disabled         DATE,
		         X_Date_Removed          DATE,
                         X_Date_Security_Applied DATE,
                         X_Creation_Date         DATE,
                         X_Created_By            NUMBER
      ) IS

        BEGIN

            INSERT INTO igi_sls_groups_audit(
                           sls_group,
                           sls_group_type,
                           description,
                           date_enabled,
                           date_disabled,
                           date_removed,
                           date_security_applied,
                           creation_date,
                           created_by
                         )
                  VALUES (
                           X_Sls_Group,
                           X_Sls_Group_Type,
                           X_Description,
                           X_Date_Enabled,
                           X_Date_Disabled,
			   X_Date_Removed,
                           X_Date_Security_Applied,
                           X_Creation_Date,
                           X_Created_By
                         );

     END Insert_Row;


END IGI_SLS_GROUPS_PKG;

/
