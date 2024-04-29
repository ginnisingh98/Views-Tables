--------------------------------------------------------
--  DDL for Package PER_ABT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ABT_PKG" AUTHID CURRENT_USER as
/* $Header: peabt01t.pkh 115.0 99/07/17 18:23:40 porting ship $ */
/*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +===========================================================================*/
PROCEDURE Insert_Row(X_Rowid                        IN OUT VARCHAR2,
                     X_Absence_Attendance_Type_Id          IN OUT NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Input_Value_Id                      NUMBER,
                     X_Date_Effective                      DATE,
                     X_Name                                VARCHAR2,
                     X_Absence_Category                    VARCHAR2,
                     X_Comments                            VARCHAR2,
                     X_Date_End                            IN OUT DATE,
                     X_Hours_Or_Days                       VARCHAR2,
                     X_Inc_Or_Dec_Flag                     VARCHAR2,
                     X_Attribute_Category                  VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Attribute16                         VARCHAR2,
                     X_Attribute17                         VARCHAR2,
                     X_Attribute18                         VARCHAR2,
                     X_Attribute19                         VARCHAR2,
                     X_Attribute20                         VARCHAR2,
                     X_Element_Type_ID                     NUMBER,
                     X_Element_End_Date                    DATE,
                     X_END_OF_TIME                         DATE
 );
--
PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Absence_Attendance_Type_Id            NUMBER,
                   X_Business_Group_Id                     NUMBER,
                   X_Input_Value_Id                        NUMBER,
                   X_Date_Effective                        DATE,
                   X_Name                                  VARCHAR2,
                   X_Absence_Category                      VARCHAR2,
                   X_Comments                              VARCHAR2,
                   X_Date_End                              DATE,
                   X_Hours_Or_Days                         VARCHAR2,
                   X_Inc_Or_Dec_Flag                       VARCHAR2,
                   X_Attribute_Category                    VARCHAR2,
                   X_Attribute1                            VARCHAR2,
                   X_Attribute2                            VARCHAR2,
                   X_Attribute3                            VARCHAR2,
                   X_Attribute4                            VARCHAR2,
                   X_Attribute5                            VARCHAR2,
                   X_Attribute6                            VARCHAR2,
                   X_Attribute7                            VARCHAR2,
                   X_Attribute8                            VARCHAR2,
                   X_Attribute9                            VARCHAR2,
                   X_Attribute10                           VARCHAR2,
                   X_Attribute11                           VARCHAR2,
                   X_Attribute12                           VARCHAR2,
                   X_Attribute13                           VARCHAR2,
                   X_Attribute14                           VARCHAR2,
                   X_Attribute15                           VARCHAR2,
                   X_Attribute16                           VARCHAR2,
                   X_Attribute17                           VARCHAR2,
                   X_Attribute18                           VARCHAR2,
                   X_Attribute19                           VARCHAR2,
                   X_Attribute20                           VARCHAR2
);
--
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Absence_Attendance_Type_Id          NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Input_Value_Id                      NUMBER,
                     X_Date_Effective                      DATE,
                     X_Name                                VARCHAR2,
                     X_Absence_Category                    VARCHAR2,
                     X_Comments                            VARCHAR2,
                     X_Date_End                            IN OUT DATE,
                     X_Hours_Or_Days                       VARCHAR2,
                     X_Inc_Or_Dec_Flag                     VARCHAR2,
                     X_Attribute_Category                  VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Attribute16                         VARCHAR2,
                     X_Attribute17                         VARCHAR2,
                     X_Attribute18                         VARCHAR2,
                     X_Attribute19                         VARCHAR2,
                     X_Attribute20                         VARCHAR2,
                     X_Element_Type_ID                     NUMBER,
                     X_Element_End_Date                    DATE,
                     X_END_OF_TIME                         DATE,
                     X_old_absence_category                VARCHAR2,
                     X_Old_Name                            VARCHAR2
);
--
PROCEDURE Delete_Row(X_Rowid VARCHAR2
                    ,X_Absence_attendance_type_id NUMBER);
--
procedure check_unique_name(p_rowid varchar2
                           ,p_business_group_id number
                           ,p_name varchar2);
--
procedure validate_date_effective(p_date_effective DATE
                                 ,p_element_type_id NUMBER
                                 ,p_absence_attendance_type_id NUMBER);
--
procedure validate_element_name(p_element_type_id NUMBER
                               ,p_date_effective DATE
                               ,p_rowid VARCHAR2
                               ,p_default_value IN OUT VARCHAR2
                               ,p_input_value_name IN OUT VARCHAR2
                               ,p_input_value_id IN OUT NUMBER
                               ,p_value_uom IN OUT VARCHAR2
                               ,p_element_end_date IN OUT DATE);
--
procedure get_uom(p_value_uom varchar2
                 ,p_hours_or_days IN OUT varchar2);
--
procedure ensure_fields_populated(p_inc_or_dec_flag VARCHAR2
                                 ,p_hours_or_days VARCHAR2
                                 ,p_input_value_id NUMBER
                                 ,p_element_type_id NUMBER);
--
procedure check_inputs_required(p_element_type_id NUMBER
                               ,p_input_value_id NUMBER);
--
procedure check_category(p_old_absence_category VARCHAR2
                        ,p_new_absence_category VARCHAR2
                        ,p_absence_attendance_type_id NUMBER);
--
procedure val_date_end(p_date_end IN OUT DATE
                      ,p_element_end_date DATE
                      ,p_end_of_time DATE);
--
procedure abt_del_validation(p_absence_attendance_type_id NUMBER);
--
END PER_ABT_PKG;

 

/
