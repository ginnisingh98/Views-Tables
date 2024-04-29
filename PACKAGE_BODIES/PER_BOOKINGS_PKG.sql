--------------------------------------------------------
--  DDL for Package Body PER_BOOKINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BOOKINGS_PKG" as
/* $Header: pebkg01t.pkb 120.2 2008/01/02 08:06:23 uuddavol ship $ */
/*

   25-JUL-95   AForte	70.3			Changed tokenised message
						HR_7149_BOOKINGS_FLAG_CHANGE
						to tokenised messages
						HR_7676_BOOKING_FLAG_CHANGE
						HR_7677_BOOKING_FLAG_CHANGE
						HR_7678_BOOKING_FLAG_CHANGE
   17-OCT-00   DCasemor 115.2	Bug 1432014     Removed hard-coded date
   						format and used the
 						canonical function to convert
 						p_new_date parameter.
   26-OCT-07   uuddavol 115.3                   Interview Management changes
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
                          P_New_Date            VARCHAR2) is


D_DUMMY NUMBER(1);
l_New_Date date;

CURSOR C1 IS
SELECT 1
FROM   PER_PEOPLE_F PPF
WHERE  PPF.PERSON_ID         = to_number(P_Person_id)
AND    PPF.CURRENT_EMPLOYEE_FLAG = 'Y'
AND    l_New_Date between PPF.EFFECTIVE_START_DATE AND
       PPF.EFFECTIVE_END_DATE;

CURSOR C2 IS
SELECT 1
FROM   PER_PEOPLE_F PPF
WHERE  PPF.PERSON_ID         = to_number(P_Person_id)
AND    PPF.CURRENT_APPLICANT_FLAG = 'Y'
AND    l_New_Date between PPF.EFFECTIVE_START_DATE AND
       PPF.EFFECTIVE_END_DATE;

CURSOR C3 IS
SELECT 1
FROM   PER_PEOPLE_F PPF
WHERE  PPF.PERSON_ID         = to_number(P_Person_id)
AND    PPF.CURRENT_APPLICANT_FLAG = 'Y'
AND    PPF.CURRENT_EMPLOYEE_FLAG  = 'Y'
AND    l_New_Date between PPF.EFFECTIVE_START_DATE AND
       PPF.EFFECTIVE_END_DATE;

BEGIN

l_New_Date := fnd_date.canonical_to_date(P_New_Date);

IF P_Current_Flag = 'E' THEN
    OPEN C1;
    FETCH C1 INTO D_DUMMY;
    IF C1%NOTFOUND THEN
     CLOSE C1;
     HR_UTILITY.SET_MESSAGE('801','HR_7676_BOOKING_FLAG_CHANGE');
     HR_UTILITY.RAISE_ERROR;
    END IF;
    CLOSE C1;
 END IF;

 IF P_Current_Flag = 'A' THEN
    OPEN C2;
    FETCH C2 INTO D_DUMMY;
    IF C2%NOTFOUND THEN
     CLOSE C2;
     HR_UTILITY.SET_MESSAGE('801','HR_7677_BOOKING_FLAG_CHANGE');
     HR_UTILITY.RAISE_ERROR;
    END IF;
    CLOSE C2;
  END IF;

  IF P_Current_Flag = 'B' THEN
    OPEN C3;
    FETCH C3 INTO D_DUMMY;
    IF C3%NOTFOUND THEN
     CLOSE C3;
     HR_UTILITY.SET_MESSAGE('801','HR_7678_BOOKING_FLAG_CHANGE');
     HR_UTILITY.RAISE_ERROR;
    END IF;
    CLOSE C3;
 END IF;

END Validate_Person;


PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Booking_Id                   IN OUT NOCOPY NUMBER,
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
                     X_Primary_Interviewer_Flag            VARCHAR2   default null
 ) IS

   L_DUMMY NUMBER;

   CURSOR C IS
   SELECT rowid FROM PER_BOOKINGS
   WHERE booking_id = X_Booking_Id;

   CURSOR C2 IS
   SELECT PER_BOOKINGS_S.NEXTVAL
   FROM SYS.DUAL;

   CURSOR UNIQUE_CHECK IS
   SELECT 1
   FROM  PER_BOOKINGS PB
   WHERE (PB.ROWID <> X_Rowid OR X_Rowid IS NULL)
   AND   PB.PERSON_ID = X_PERSON_ID
   AND   PB.BUSINESS_GROUP_ID + 0 = X_BUSINESS_GROUP_ID
   AND   PB.EVENT_ID = X_EVENT_ID;

BEGIN
  OPEN UNIQUE_CHECK;
  FETCH UNIQUE_CHECK INTO L_DUMMY;
  IF UNIQUE_CHECK%FOUND THEN
    CLOSE UNIQUE_CHECK;
    -- Check to see if X_Token is an EMPLOYEE or an APPLICANT
    -- and then an error message is raised for that person type.
    if X_Token = 'EMPLOYEE' then
      FND_MESSAGE.SET_NAME('PER', 'PER_51973_EMP_EVENT_ONCE');
    elsif X_Token = 'APPLICANT' then
      FND_MESSAGE.SET_NAME('PER', 'PER_51974_APP_EVENT_ONCE');
    end if;
    FND_MESSAGE.RAISE_ERROR;
  ELSE
    CLOSE UNIQUE_CHECK;
  END IF;

  OPEN  C2;
  FETCH C2 INTO X_Booking_Id;
  CLOSE C2;

  INSERT INTO PER_BOOKINGS(
          booking_id,
          business_group_id,
          person_id,
          event_id,
          comments,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          attribute16,
          attribute17,
          attribute18,
          attribute19,
          attribute20,
          primary_interviewer_flag
         ) VALUES (
          X_Booking_Id,
          X_Business_Group_Id,
          X_Person_Id,
          X_Event_Id,
          X_Comments,
          X_Attribute_Category,
          X_Attribute1,
          X_Attribute2,
          X_Attribute3,
          X_Attribute4,
          X_Attribute5,
          X_Attribute6,
          X_Attribute7,
          X_Attribute8,
          X_Attribute9,
          X_Attribute10,
          X_Attribute11,
          X_Attribute12,
          X_Attribute13,
          X_Attribute14,
          X_Attribute15,
          X_Attribute16,
          X_Attribute17,
          X_Attribute18,
          X_Attribute19,
          X_Attribute20,
          X_Primary_Interviewer_Flag
  );

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    HR_UTILITY.SET_MESSAGE(801,'HR_6153_ALL_PROCEDURE_FAIL');
    HR_UTILITY.SET_MESSAGE_TOKEN('PROCEDURE','INSERT_ROW');
    HR_UTILITY.SET_MESSAGE_TOKEN('STEP','1');
    HR_UTILITY.RAISE_ERROR;
  end if;
  CLOSE C;
END Insert_Row;

PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Booking_Id                            NUMBER,
                   X_Business_Group_Id                     NUMBER,
                   X_Person_Id                             NUMBER,
                   X_Event_Id                              NUMBER,
                   X_Comments                              VARCHAR2,
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
                   X_Attribute20                           VARCHAR2,
                   X_Primary_Interviewer_Flag              VARCHAR2   default null
) IS

  CURSOR C IS
      SELECT *
      FROM   PER_BOOKINGS
      WHERE  rowid = X_Rowid
      FOR UPDATE of Booking_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
   CLOSE C;
   HR_UTILITY.SET_MESSAGE(801,'HR_6153_ALL_PROCEDURE_FAIL');
   HR_UTILITY.SET_MESSAGE_TOKEN('PROCEDURE','LOCK_ROW');
   HR_UTILITY.SET_MESSAGE_TOKEN('STEP','1');
   HR_UTILITY.RAISE_ERROR;
  end if;
  CLOSE C;

Recinfo.comments := rtrim(Recinfo.comments);
Recinfo.attribute_category := rtrim(Recinfo.attribute_category);
Recinfo.attribute1 := rtrim(Recinfo.attribute1);
Recinfo.attribute2 := rtrim(Recinfo.attribute2);
Recinfo.attribute3 := rtrim(Recinfo.attribute3);
Recinfo.attribute4 := rtrim(Recinfo.attribute4);
Recinfo.attribute5 := rtrim(Recinfo.attribute5);
Recinfo.attribute6 := rtrim(Recinfo.attribute6);
Recinfo.attribute7 := rtrim(Recinfo.attribute7);
Recinfo.attribute8 := rtrim(Recinfo.attribute8);
Recinfo.attribute9 := rtrim(Recinfo.attribute9);
Recinfo.attribute10 := rtrim(Recinfo.attribute10);
Recinfo.attribute11 := rtrim(Recinfo.attribute11);
Recinfo.attribute12 := rtrim(Recinfo.attribute12);
Recinfo.attribute13 := rtrim(Recinfo.attribute13);
Recinfo.attribute14 := rtrim(Recinfo.attribute14);
Recinfo.attribute15 := rtrim(Recinfo.attribute15);
Recinfo.attribute16 := rtrim(Recinfo.attribute16);
Recinfo.attribute17 := rtrim(Recinfo.attribute17);
Recinfo.attribute18 := rtrim(Recinfo.attribute18);
Recinfo.attribute19 := rtrim(Recinfo.attribute19);
Recinfo.attribute20 := rtrim(Recinfo.attribute20);

  if (
          (   (Recinfo.booking_id = X_Booking_Id)
           OR (    (Recinfo.booking_id IS NULL)
               AND (X_Booking_Id IS NULL)))
      AND (   (Recinfo.business_group_id = X_Business_Group_Id)
           OR (    (Recinfo.business_group_id IS NULL)
               AND (X_Business_Group_Id IS NULL)))
      AND (   (Recinfo.person_id = X_Person_Id)
           OR (    (Recinfo.person_id IS NULL)
               AND (X_Person_Id IS NULL)))
      AND (   (Recinfo.event_id = X_Event_Id)
           OR (    (Recinfo.event_id IS NULL)
               AND (X_Event_Id IS NULL)))
      AND (   (Recinfo.comments = X_Comments)
           OR (    (Recinfo.comments IS NULL)
               AND (X_Comments IS NULL)))
      AND (   (Recinfo.attribute_category = X_Attribute_Category)
           OR (    (Recinfo.attribute_category IS NULL)
               AND (X_Attribute_Category IS NULL)))
      AND (   (Recinfo.attribute1 = X_Attribute1)
           OR (    (Recinfo.attribute1 IS NULL)
               AND (X_Attribute1 IS NULL)))
      AND (   (Recinfo.attribute2 = X_Attribute2)
           OR (    (Recinfo.attribute2 IS NULL)
               AND (X_Attribute2 IS NULL)))
      AND (   (Recinfo.attribute3 = X_Attribute3)
           OR (    (Recinfo.attribute3 IS NULL)
               AND (X_Attribute3 IS NULL)))
      AND (   (Recinfo.attribute4 = X_Attribute4)
           OR (    (Recinfo.attribute4 IS NULL)
               AND (X_Attribute4 IS NULL)))
      AND (   (Recinfo.attribute5 = X_Attribute5)
           OR (    (Recinfo.attribute5 IS NULL)
               AND (X_Attribute5 IS NULL)))
      AND (   (Recinfo.attribute6 = X_Attribute6)
           OR (    (Recinfo.attribute6 IS NULL)
               AND (X_Attribute6 IS NULL)))
      AND (   (Recinfo.attribute7 = X_Attribute7)
           OR (    (Recinfo.attribute7 IS NULL)
               AND (X_Attribute7 IS NULL)))
      AND (   (Recinfo.attribute8 = X_Attribute8)
           OR (    (Recinfo.attribute8 IS NULL)
               AND (X_Attribute8 IS NULL)))
      AND (   (Recinfo.attribute9 = X_Attribute9)
           OR (    (Recinfo.attribute9 IS NULL)
               AND (X_Attribute9 IS NULL)))
      AND (   (Recinfo.attribute10 = X_Attribute10)
           OR (    (Recinfo.attribute10 IS NULL)
               AND (X_Attribute10 IS NULL)))
      AND (   (Recinfo.attribute11 = X_Attribute11)
           OR (    (Recinfo.attribute11 IS NULL)
               AND (X_Attribute11 IS NULL)))
      AND (   (Recinfo.attribute12 = X_Attribute12)
           OR (    (Recinfo.attribute12 IS NULL)
               AND (X_Attribute12 IS NULL)))
      AND (   (Recinfo.attribute13 = X_Attribute13)
           OR (    (Recinfo.attribute13 IS NULL)
               AND (X_Attribute13 IS NULL)))
      AND (   (Recinfo.attribute14 = X_Attribute14)
           OR (    (Recinfo.attribute14 IS NULL)
               AND (X_Attribute14 IS NULL)))
      AND (   (Recinfo.attribute15 = X_Attribute15)
           OR (    (Recinfo.attribute15 IS NULL)
               AND (X_Attribute15 IS NULL)))
      AND (   (Recinfo.attribute16 = X_Attribute16)
           OR (    (Recinfo.attribute16 IS NULL)
               AND (X_Attribute16 IS NULL)))
      AND (   (Recinfo.attribute17 = X_Attribute17)
           OR (    (Recinfo.attribute17 IS NULL)
               AND (X_Attribute17 IS NULL)))
      AND (   (Recinfo.attribute18 = X_Attribute18)
           OR (    (Recinfo.attribute18 IS NULL)
               AND (X_Attribute18 IS NULL)))
      AND (   (Recinfo.attribute19 = X_Attribute19)
           OR (    (Recinfo.attribute19 IS NULL)
               AND (X_Attribute19 IS NULL)))
      AND (   (Recinfo.attribute20 = X_Attribute20)
           OR (    (Recinfo.attribute20 IS NULL)
               AND (X_Attribute20 IS NULL)))
      AND (   (Recinfo.primary_interviewer_flag = X_Primary_Interviewer_Flag)
           OR (    (Recinfo.primary_interviewer_flag IS NULL)
               AND (X_Primary_Interviewer_Flag IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;

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
                     X_Primary_Interviewer_Flag            VARCHAR2   default null
) IS

   L_DUMMY NUMBER;

   CURSOR UNIQUE_CHECK IS
   SELECT 1
   FROM  PER_BOOKINGS PB
   WHERE (PB.ROWID <> X_Rowid OR X_Rowid IS NULL)
   AND   PB.PERSON_ID = X_PERSON_ID
   AND   PB.BUSINESS_GROUP_ID + 0 = X_BUSINESS_GROUP_ID
   AND   PB.EVENT_ID = X_EVENT_ID;


BEGIN
  OPEN UNIQUE_CHECK;
  FETCH UNIQUE_CHECK INTO L_DUMMY;
  IF UNIQUE_CHECK%FOUND THEN
    CLOSE UNIQUE_CHECK;
    -- Check to see if X_Token is an EMPLOYEE or an APPLICANT
    -- and then an error message is raised for that person type.
    if X_Token = 'EMPLOYEE' then
      HR_UTILITY.SET_MESSAGE('801', 'PER_51973_EMP_EVENT_ONCE');
    elsif X_Token = 'APPLICANT' then
      HR_UTILITY.SET_MESSAGE('801', 'PER_51974_APP_EVENT_ONCE');
    end if;
    HR_UTILITY.RAISE_ERROR;
  ELSE
    CLOSE UNIQUE_CHECK;
  END IF;

  UPDATE PER_BOOKINGS
  SET

    booking_id                                =    X_Booking_Id,
    business_group_id                         =    X_Business_Group_Id,
    person_id                                 =    X_Person_Id,
    event_id                                  =    X_Event_Id,
    comments                                  =    X_Comments,
    attribute_category                        =    X_Attribute_Category,
    attribute1                                =    X_Attribute1,
    attribute2                                =    X_Attribute2,
    attribute3                                =    X_Attribute3,
    attribute4                                =    X_Attribute4,
    attribute5                                =    X_Attribute5,
    attribute6                                =    X_Attribute6,
    attribute7                                =    X_Attribute7,
    attribute8                                =    X_Attribute8,
    attribute9                                =    X_Attribute9,
    attribute10                               =    X_Attribute10,
    attribute11                               =    X_Attribute11,
    attribute12                               =    X_Attribute12,
    attribute13                               =    X_Attribute13,
    attribute14                               =    X_Attribute14,
    attribute15                               =    X_Attribute15,
    attribute16                               =    X_Attribute16,
    attribute17                               =    X_Attribute17,
    attribute18                               =    X_Attribute18,
    attribute19                               =    X_Attribute19,
    attribute20                               =    X_Attribute20,
    primary_interviewer_flag                  =    X_Primary_Interviewer_Flag
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    HR_UTILITY.SET_MESSAGE(801,'HR_6153_ALL_PROCEDURE_FAIL');
    HR_UTILITY.SET_MESSAGE_TOKEN('PROCEDURE','UPDATE_ROW');
    HR_UTILITY.SET_MESSAGE_TOKEN('STEP','1');
    HR_UTILITY.RAISE_ERROR;
  end if;

END Update_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM PER_BOOKINGS
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    HR_UTILITY.SET_MESSAGE(801,'HR_6153_ALL_PROCEDURE_FAIL');
    HR_UTILITY.SET_MESSAGE_TOKEN('PROCEDURE','DELETE_ROW');
    HR_UTILITY.SET_MESSAGE_TOKEN('STEP','1');
    HR_UTILITY.RAISE_ERROR;
  end if;
END Delete_Row;

END PER_BOOKINGS_PKG;

/
