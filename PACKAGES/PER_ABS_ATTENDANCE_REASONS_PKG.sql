--------------------------------------------------------
--  DDL for Package PER_ABS_ATTENDANCE_REASONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ABS_ATTENDANCE_REASONS_PKG" AUTHID CURRENT_USER as
/* $Header: peaar01t.pkh 115.0 99/07/17 18:23:05 porting ship $ */
/*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +===========================================================================*/
PROCEDURE Insert_Row(X_Rowid                         IN OUT VARCHAR2,
                     X_Abs_Attendance_Reason_Id             IN OUT NUMBER,
                     X_Business_Group_Id                    NUMBER,
                     X_Absence_Attendance_Type_Id           NUMBER,
                     X_Name                                 VARCHAR2,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Created_By                           NUMBER,
                     X_Creation_Date                        DATE
                     );
--
PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Abs_Attendance_Reason_Id               NUMBER,
                   X_Business_Group_Id                      NUMBER,
                   X_Absence_Attendance_Type_Id             NUMBER,
                   X_Name                                   VARCHAR2
                   );
--
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Abs_Attendance_Reason_Id            NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Absence_Attendance_Type_Id          NUMBER,
                     X_Name                                VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER
                     );
--
PROCEDURE Delete_Row(X_Rowid VARCHAR2
                    ,X_Abs_Attendance_Reason_Id NUMBER);
--
PROCEDURE Get_Name(X_CODE Varchar2
                  ,X_MEANING IN OUT Varchar2);
--
PROCEDURE abr_del_validation(p_abs_attendance_reason_id NUMBER);
--
PROCEDURE check_unique_reason(p_rowid VARCHAR2
                             ,p_name VARCHAR2
                             ,p_absence_attendance_type_id NUMBER);
--
END PER_ABS_ATTENDANCE_REASONS_PKG;

 

/
