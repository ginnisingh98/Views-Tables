--------------------------------------------------------
--  DDL for Package PER_POSITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_POSITIONS_PKG" AUTHID CURRENT_USER as
/* $Header: pepos01t.pkh 120.0 2005/05/31 14:51:40 appldev noship $ */
function exists_in_hierarchy(X_Pos_Structure_Version_Id NUMBER,
			     X_Position_Id NUMBER) return VARCHAR2;

PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Position_Id                   IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                    NUMBER,
                     X_Job_Id                               NUMBER,
                     X_Organization_Id                      NUMBER,
                     X_Successor_Position_Id                NUMBER,
                     X_Relief_Position_Id                   NUMBER,
                     X_Location_Id                          NUMBER,
                     X_Position_Definition_Id               NUMBER,
                     X_Date_Effective                       DATE,
                     X_Comments                             VARCHAR2,
                     X_Date_End                             DATE,
                     X_Frequency                            VARCHAR2,
                     X_Name                                 VARCHAR2,
                     X_Probation_Period                     NUMBER,
                     X_Probation_Period_Units               VARCHAR2,
                     X_Replacement_Required_Flag            VARCHAR2,
                     X_Time_Normal_Finish                   VARCHAR2,
                     X_Time_Normal_Start                    VARCHAR2,
                     X_Working_Hours                        NUMBER,
                     X_Status                               VARCHAR2,
                     X_Attribute_Category                   VARCHAR2,
                     X_Attribute1                           VARCHAR2,
                     X_Attribute2                           VARCHAR2,
                     X_Attribute3                           VARCHAR2,
                     X_Attribute4                           VARCHAR2,
                     X_Attribute5                           VARCHAR2,
                     X_Attribute6                           VARCHAR2,
                     X_Attribute7                           VARCHAR2,
                     X_Attribute8                           VARCHAR2,
                     X_Attribute9                           VARCHAR2,
                     X_Attribute10                          VARCHAR2,
                     X_Attribute11                          VARCHAR2,
                     X_Attribute12                          VARCHAR2,
                     X_Attribute13                          VARCHAR2,
                     X_Attribute14                          VARCHAR2,
                     X_Attribute15                          VARCHAR2,
                     X_Attribute16                          VARCHAR2,
                     X_Attribute17                          VARCHAR2,
                     X_Attribute18                          VARCHAR2,
                     X_Attribute19                          VARCHAR2,
                     X_Attribute20                          VARCHAR2,
                     X_View_All_Psts                        VARCHAR2,
                     X_Security_Profile_id                  NUMBER
                     );

PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Position_Id                            NUMBER,
                   X_Business_Group_Id                      NUMBER,
                   X_Job_Id                                 NUMBER,
                   X_Organization_Id                        NUMBER,
                   X_Successor_Position_Id                  NUMBER,
                   X_Relief_Position_Id                     NUMBER,
                   X_Location_Id                            NUMBER,
                   X_Position_Definition_Id                 NUMBER,
                   X_Date_Effective                         DATE,
                   X_Comments                               VARCHAR2,
                   X_Date_End                               DATE,
                   X_Frequency                              VARCHAR2,
                   X_Name                                   VARCHAR2,
                   X_Probation_Period                       NUMBER,
                   X_Probation_Period_Units                 VARCHAR2,
                   X_Replacement_Required_Flag              VARCHAR2,
                   X_Time_Normal_Finish                     VARCHAR2,
                   X_Time_Normal_Start                      VARCHAR2,
                   X_Working_Hours                          NUMBER,
                   X_Attribute_Category                     VARCHAR2,
                   X_Attribute1                             VARCHAR2,
                   X_Attribute2                             VARCHAR2,
                   X_Attribute3                             VARCHAR2,
                   X_Attribute4                             VARCHAR2,
                   X_Attribute5                             VARCHAR2,
                   X_Attribute6                             VARCHAR2,
                   X_Attribute7                             VARCHAR2,
                   X_Attribute8                             VARCHAR2,
                   X_Attribute9                             VARCHAR2,
                   X_Attribute10                            VARCHAR2,
                   X_Attribute11                            VARCHAR2,
                   X_Attribute12                            VARCHAR2,
                   X_Attribute13                            VARCHAR2,
                   X_Attribute14                            VARCHAR2,
                   X_Attribute15                            VARCHAR2,
                   X_Attribute16                            VARCHAR2,
                   X_Attribute17                            VARCHAR2,
                   X_Attribute18                            VARCHAR2,
                   X_Attribute19                            VARCHAR2,
                   X_Attribute20                            VARCHAR2,
                   X_Status                                 VARCHAR2
                   );

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Position_Id                         NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Job_Id                              NUMBER,
                     X_Organization_Id                     NUMBER,
                     X_Successor_Position_Id               NUMBER,
                     X_Relief_Position_Id                  NUMBER,
                     X_Location_Id                         NUMBER,
                     X_Position_Definition_Id              NUMBER,
                     X_Date_Effective                      DATE,
                     X_Comments                            VARCHAR2,
                     X_Date_End                            DATE,
                     X_Frequency                           VARCHAR2,
                     X_Name                                VARCHAR2,
                     X_Probation_Period                    NUMBER,
                     X_Probation_Period_Units              VARCHAR2,
                     X_Replacement_Required_Flag           VARCHAR2,
                     X_Time_Normal_Finish                  VARCHAR2,
                     X_Time_Normal_Start                   VARCHAR2,
                     X_Working_Hours                       NUMBER,
                     X_Status                               VARCHAR2,
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
                     X_Attribute20                         VARCHAR2
                     );

PROCEDURE Delete_Row(X_Rowid VARCHAR2,
                     X_Position_id number,
                     X_business_group_id number,
                     X_Hr_Ins varchar2,
                     X_Po_Ins varchar2,
		     X_View_All_Psts varchar2);
--
PROCEDURE pre_delete_checks(p_rowid                       VARCHAR2,
                            p_position_id                 NUMBER,
                            p_business_group_id           NUMBER,
                            p_hr_ins                      VARCHAR2,
                            p_po_ins                      VARCHAR2,
                            p_delete_row              OUT NOCOPY BOOLEAN);
--
FUNCTION check_id_flex_struct ( p_id_flex_code VARCHAR2,
                                p_id_flex_num  NUMBER ) RETURN BOOLEAN;
--
PROCEDURE check_date_effective ( p_position_id    NUMBER,
			         p_date_effective DATE);
--
PROCEDURE check_valid_grades ( p_position_id NUMBER,
		               p_end_of_time DATE,
		               p_date_end    DATE,
		               p_before_date_to IN OUT NOCOPY BOOLEAN,
		               p_before_date_from IN OUT NOCOPY BOOLEAN,
                               p_end_date_blank IN OUT NOCOPY BOOLEAN,
                               p_after_date_to  IN OUT NOCOPY BOOLEAN );

--
PROCEDURE maintain_valid_grades(p_position_id NUMBER,
		                p_date_end    DATE,
		                p_end_of_time DATE,
				p_before_date_to   BOOLEAN,
				p_before_date_from BOOLEAN,
                                p_end_date_blank   BOOLEAN,
                                p_after_date_to    BOOLEAN );

--
FUNCTION GET_SHARED_POS_WARN_FLAG(p_user_id number) RETURN varchar2;
--
PROCEDURE SET_SHARED_POS_WARN_FLAG(p_user_id number,
                                   p_show_again_flag varchar2);
--
END PER_POSITIONS_PKG;

 

/
