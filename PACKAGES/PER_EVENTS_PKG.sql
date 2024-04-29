--------------------------------------------------------
--  DDL for Package PER_EVENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_EVENTS_PKG" AUTHID CURRENT_USER as
/* $Header: peevt01t.pkh 120.0.12010000.1 2008/07/28 04:39:39 appldev ship $ */

-- *****************************************************************
-- * Table handler for per_events
-- *****************************************************************

PROCEDURE CHECK_VALIDITY(X_INTERNAL_CONTACT_PERSON_ID NUMBER,
		    	  X_DATE_START                 DATE,
			  X_ORGANIZATION_RUN_BY_ID     NUMBER,
			  X_BUSINESS_GROUP_ID          NUMBER,
			  X_CTL_GLOBALS_END_OF_TIME    DATE,
			  X_LOCATION_ID                NUMBER,
                          X_EVENT_ID                   NUMBER);

--------------------------------------------------------------------------------
function INTERVIEWERS_ARE_BOOKED (	p_event_id	number,
					p_error_if_true	boolean default FALSE)
return boolean;
--------------------------------------------------------------------------------
procedure CHECK_CURRENT_INTERVIEWERS (	p_event_id			number,
					p_new_interview_start_date	date);
--------------------------------------------------------------------------------
procedure REQUEST_LETTER (
	p_business_group_id     	number,
        p_session_date          	date,
        p_user                  	number,
        p_login_id              	number,
        p_assignment_status_type_id     number,
        p_person_id                     number,
        p_assignment_id                 number);
--------------------------------------------------------------------------------
function EVENT_CAUSES_ASSIGNMENT_CHANGE (	p_event_date	date,
						p_assignment_id	number)
return boolean;
--------------------------------------------------------------------------------
function INTERVIEW_DOUBLE_BOOKED (
--
--******************************************************************************
--* Returns TRUE if the applicant already has an interview at the time required*
--******************************************************************************
--
	p_person_id		number,
	p_interview_start_date	date,
        p_time_start            varchar2,  -- Added for bug 3270091.
        p_time_end              varchar2,  -- Added for bug 3270091.
	p_rowid			varchar2 default null) return boolean;
--------------------------------------------------------------------------------


PROCEDURE INSERT_ROW(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Event_Id                      IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                    NUMBER,
                     X_Location_Id                          NUMBER,
                     X_Internal_Contact_Person_Id           NUMBER,
                     X_Organization_Run_By_Id               NUMBER,
                     X_Assignment_Id                        NUMBER,
                     X_Date_Start                           DATE,
                     X_Type                                 VARCHAR2,
                     X_Comments                             VARCHAR2,
                     X_Contact_Telephone_Number             VARCHAR2,
                     X_Date_End                             DATE,
                     X_Emp_Or_Apl                           VARCHAR2,
                     X_Event_Or_Interview                   VARCHAR2,
                     X_External_Contact                     VARCHAR2,
                     X_Time_End                             VARCHAR2,
                     X_Time_Start                           VARCHAR2,
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
                     X_ctl_globals_end_of_time              DATE);

PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Event_Id                               NUMBER,
                   X_Business_Group_Id                      NUMBER,
                   X_Location_Id                            NUMBER,
                   X_Internal_Contact_Person_Id             NUMBER,
                   X_Organization_Run_By_Id                 NUMBER,
                   X_Assignment_Id                          NUMBER,
                   X_Date_Start                             DATE,
                   X_Type                                   VARCHAR2,
                   X_Comments                               VARCHAR2,
                   X_Contact_Telephone_Number               VARCHAR2,
                   X_Date_End                               DATE,
                   X_Emp_Or_Apl                             VARCHAR2,
                   X_Event_Or_Interview                     VARCHAR2,
                   X_External_Contact                       VARCHAR2,
                   X_Time_End                               VARCHAR2,
                   X_Time_Start                             VARCHAR2,
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
                   X_Attribute20                            VARCHAR2
                   );

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Event_Id                            NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Location_Id                         NUMBER,
                     X_Internal_Contact_Person_Id          NUMBER,
                     X_Organization_Run_By_Id              NUMBER,
                     X_Assignment_Id                       NUMBER,
                     X_Date_Start                          DATE,
                     X_Type                                VARCHAR2,
                     X_Comments                            VARCHAR2,
                     X_Contact_Telephone_Number            VARCHAR2,
                     X_Date_End                            DATE,
                     X_Emp_Or_Apl                          VARCHAR2,
                     X_Event_Or_Interview                  VARCHAR2,
                     X_External_Contact                    VARCHAR2,
                     X_Time_End                            VARCHAR2,
                     X_Time_Start                          VARCHAR2,
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
                     X_ctl_globals_end_of_time             DATE);

PROCEDURE Delete_Row(X_Rowid VARCHAR2,
                     X_Event_Id NUMBER,
                     X_Business_Group_Id NUMBER,
		     X_Message  VARCHAR2,
                     X_Form     VARCHAR2);

END PER_EVENTS_PKG;

/
