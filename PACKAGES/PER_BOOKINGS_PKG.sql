--------------------------------------------------------
--  DDL for Package PER_BOOKINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BOOKINGS_PKG" AUTHID CURRENT_USER as
/* $Header: pebkg01t.pkh 120.2 2008/01/02 08:05:05 uuddavol ship $ */
/*
   02-JAN-08   uuddavol 120.2                   set default values to
 					        X_Primary_Interviewer_Flag
*/
-- **************************************************************************
-- *** THIS PACKAGE IS USED BY THREE FORMS - PERWSERW, PERWSGEB, PERWSBEP ***
-- **************************************************************************

-- This procedure is used only by PERWSBEP to perfrom extra validation
-- when the session date is changed
PROCEDURE Validate_Person(P_Person_id           VARCHAR2,
                          P_Current_Flag        VARCHAR2,
                          P_New_Date            VARCHAR2);


PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Booking_Id                    IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                    NUMBER,
                     X_Person_Id                            NUMBER,
                     X_Event_Id                             NUMBER,
                     X_Message	                            VARCHAR2,
	             X_Token                                VARCHAR2,
                     X_Comments                             VARCHAR2,
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
                     X_Primary_Interviewer_Flag             VARCHAR2   default null);

PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Booking_Id                             NUMBER,
                   X_Business_Group_Id                      NUMBER,
                   X_Person_Id                              NUMBER,
                   X_Event_Id                               NUMBER,
                   X_Comments                               VARCHAR2,
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
                   X_Primary_Interviewer_Flag               VARCHAR2   default null
                   );

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Booking_Id                          NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Person_Id                           NUMBER,
                     X_Event_Id                            NUMBER,
                     X_Message                             VARCHAR2,
	             X_Token                               VARCHAR2,
                     X_Comments                            VARCHAR2,
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
                     X_Primary_Interviewer_Flag            VARCHAR2   default null);

PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END PER_BOOKINGS_PKG;

/
