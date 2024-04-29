--------------------------------------------------------
--  DDL for Package Body PAY_PAYMENT_METHODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYMENT_METHODS_PKG" AS
/* $Header: pyppm01t.pkb 120.0 2005/05/29 07:40:52 appldev noship $ */
   PROCEDURE INSERT_ROW(P_ROWID                         IN OUT NOCOPY VARCHAR2,
                        P_PERSONAL_PAYMENT_METHOD_ID    IN OUT NOCOPY NUMBER,
                        P_EFFECTIVE_START_DATE          DATE,
                        P_EFFECTIVE_END_DATE            DATE,
                        P_BUSINESS_GROUP_ID             NUMBER,
                        P_EXTERNAL_ACCOUNT_ID           NUMBER,
                        P_ASSIGNMENT_ID                 NUMBER,
                        P_PERSON_ID                     NUMBER,
                        P_RUN_TYPE_ID                   NUMBER,
                        P_ORG_PAYMENT_METHOD_ID         NUMBER,
                        P_AMOUNT                        NUMBER,
                        P_COMMENT_ID                    NUMBER,
                        P_PERCENTAGE                    NUMBER,
                        P_PRIORITY                      NUMBER,
                        P_PAYEE_TYPE                    VARCHAR2,
                        P_PAYEE_ID                      NUMBER,
                        P_ATTRIBUTE_CATEGORY            VARCHAR2,
                        P_ATTRIBUTE1                    VARCHAR2,
                        P_ATTRIBUTE2                    VARCHAR2,
                        P_ATTRIBUTE3                    VARCHAR2,
                        P_ATTRIBUTE4                    VARCHAR2,
                        P_ATTRIBUTE5                    VARCHAR2,
                        P_ATTRIBUTE6                    VARCHAR2,
                        P_ATTRIBUTE7                    VARCHAR2,
                        P_ATTRIBUTE8                    VARCHAR2,
                        P_ATTRIBUTE9                    VARCHAR2,
                        P_ATTRIBUTE10                   VARCHAR2,
                        P_ATTRIBUTE11                   VARCHAR2,
                        P_ATTRIBUTE12                   VARCHAR2,
                        P_ATTRIBUTE13                   VARCHAR2,
                        P_ATTRIBUTE14                   VARCHAR2,
                        P_ATTRIBUTE15                   VARCHAR2,
                        P_ATTRIBUTE16                   VARCHAR2,
                        P_ATTRIBUTE17                   VARCHAR2,
                        P_ATTRIBUTE18                   VARCHAR2,
                        P_ATTRIBUTE19                   VARCHAR2,
                        P_ATTRIBUTE20                   VARCHAR2,
                        P_PRENOTE_DATE                  DATE,
/** sbilling **/
                        P_TERRITORY_CODE                VARCHAR2,
                        P_PPM_INFORMATION_CATEGORY      VARCHAR2,
                        P_PPM_INFORMATION1              VARCHAR2,
                        P_PPM_INFORMATION2              VARCHAR2,
                        P_PPM_INFORMATION3              VARCHAR2,
                        P_PPM_INFORMATION4              VARCHAR2,
                        P_PPM_INFORMATION5              VARCHAR2,
                        P_PPM_INFORMATION6              VARCHAR2,
                        P_PPM_INFORMATION7              VARCHAR2,
                        P_PPM_INFORMATION8              VARCHAR2,
                        P_PPM_INFORMATION9              VARCHAR2,
                        P_PPM_INFORMATION10             VARCHAR2,
                        P_PPM_INFORMATION11             VARCHAR2,
                        P_PPM_INFORMATION12             VARCHAR2,
                        P_PPM_INFORMATION13             VARCHAR2,
                        P_PPM_INFORMATION14             VARCHAR2,
                        P_PPM_INFORMATION15             VARCHAR2,
                        P_PPM_INFORMATION16             VARCHAR2,
                        P_PPM_INFORMATION17             VARCHAR2,
                        P_PPM_INFORMATION18             VARCHAR2,
                        P_PPM_INFORMATION19             VARCHAR2,
                        P_PPM_INFORMATION20             VARCHAR2,
                        P_PPM_INFORMATION21             VARCHAR2,
                        P_PPM_INFORMATION22             VARCHAR2,
                        P_PPM_INFORMATION23             VARCHAR2,
                        P_PPM_INFORMATION24             VARCHAR2,
                        P_PPM_INFORMATION25             VARCHAR2,
                        P_PPM_INFORMATION26             VARCHAR2,
                        P_PPM_INFORMATION27             VARCHAR2,
                        P_PPM_INFORMATION28             VARCHAR2,
                        P_PPM_INFORMATION29             VARCHAR2,
                        P_PPM_INFORMATION30             VARCHAR2
) IS

   CURSOR C IS
   SELECT ROWID
   FROM   PAY_PERSONAL_PAYMENT_METHODS_F
   WHERE  PERSONAL_PAYMENT_METHOD_ID = P_PERSONAL_PAYMENT_METHOD_ID;

   CURSOR C2 IS
   SELECT pay_personal_payment_methods_s.nextval
   FROM   sys.dual;

   BEGIN

    OPEN C2;
    FETCH C2 INTO P_PERSONAL_PAYMENT_METHOD_ID;
    CLOSE C2;

    INSERT INTO PAY_PERSONAL_PAYMENT_METHODS_F (PERSONAL_PAYMENT_METHOD_ID,
                        EFFECTIVE_START_DATE,
                        EFFECTIVE_END_DATE,
                        BUSINESS_GROUP_ID,
                        EXTERNAL_ACCOUNT_ID,
                        ASSIGNMENT_ID,
			PERSON_ID,
			RUN_TYPE_ID,
                        ORG_PAYMENT_METHOD_ID,
                        AMOUNT,
                        COMMENT_ID,
                        PERCENTAGE,
                        PRIORITY,
                        PAYEE_TYPE,
                        PAYEE_ID,
                        ATTRIBUTE_CATEGORY,
                        ATTRIBUTE1,
                        ATTRIBUTE2,
                        ATTRIBUTE3,
                        ATTRIBUTE4,
                        ATTRIBUTE5,
                        ATTRIBUTE6,
                        ATTRIBUTE7,
                        ATTRIBUTE8,
                        ATTRIBUTE9,
                        ATTRIBUTE10,
                        ATTRIBUTE11,
                        ATTRIBUTE12,
                        ATTRIBUTE13,
                        ATTRIBUTE14,
                        ATTRIBUTE15,
                        ATTRIBUTE16,
                        ATTRIBUTE17,
                        ATTRIBUTE18,
                        ATTRIBUTE19,
                        ATTRIBUTE20,
                        PPM_INFORMATION_CATEGORY,
                        PPM_INFORMATION1,
                        PPM_INFORMATION2,
                        PPM_INFORMATION3,
                        PPM_INFORMATION4,
                        PPM_INFORMATION5,
                        PPM_INFORMATION6,
                        PPM_INFORMATION7,
                        PPM_INFORMATION8,
                        PPM_INFORMATION9,
                        PPM_INFORMATION10,
                        PPM_INFORMATION11,
                        PPM_INFORMATION12,
                        PPM_INFORMATION13,
                        PPM_INFORMATION14,
                        PPM_INFORMATION15,
                        PPM_INFORMATION16,
                        PPM_INFORMATION17,
                        PPM_INFORMATION18,
                        PPM_INFORMATION19,
                        PPM_INFORMATION20,
                        PPM_INFORMATION21,
                        PPM_INFORMATION22,
                        PPM_INFORMATION23,
                        PPM_INFORMATION24,
                        PPM_INFORMATION25,
                        PPM_INFORMATION26,
                        PPM_INFORMATION27,
                        PPM_INFORMATION28,
                        PPM_INFORMATION29,
                        PPM_INFORMATION30)

   VALUES(P_PERSONAL_PAYMENT_METHOD_ID,P_EFFECTIVE_START_DATE,
        P_EFFECTIVE_END_DATE,P_BUSINESS_GROUP_ID,P_EXTERNAL_ACCOUNT_ID,
        P_ASSIGNMENT_ID,P_PERSON_ID,P_RUN_TYPE_ID,P_ORG_PAYMENT_METHOD_ID,P_AMOUNT,P_COMMENT_ID,
        P_PERCENTAGE,P_PRIORITY,P_PAYEE_TYPE,P_PAYEE_ID,
        P_ATTRIBUTE_CATEGORY,P_ATTRIBUTE1,
        P_ATTRIBUTE2,P_ATTRIBUTE3,P_ATTRIBUTE4, P_ATTRIBUTE5,P_ATTRIBUTE6,
        P_ATTRIBUTE7,P_ATTRIBUTE8,P_ATTRIBUTE9,P_ATTRIBUTE10,P_ATTRIBUTE11,
        P_ATTRIBUTE12,P_ATTRIBUTE13,P_ATTRIBUTE14,P_ATTRIBUTE15,P_ATTRIBUTE16,
        P_ATTRIBUTE17,P_ATTRIBUTE18,P_ATTRIBUTE19,P_ATTRIBUTE20,
        P_PPM_INFORMATION_CATEGORY,P_PPM_INFORMATION1,P_PPM_INFORMATION2,
        P_PPM_INFORMATION3,P_PPM_INFORMATION4,P_PPM_INFORMATION5,P_PPM_INFORMATION6,
        P_PPM_INFORMATION7,P_PPM_INFORMATION8,P_PPM_INFORMATION9,P_PPM_INFORMATION10,
        P_PPM_INFORMATION11,P_PPM_INFORMATION12,P_PPM_INFORMATION13,P_PPM_INFORMATION14,
        P_PPM_INFORMATION15,P_PPM_INFORMATION16,P_PPM_INFORMATION17,P_PPM_INFORMATION18,
        P_PPM_INFORMATION19,P_PPM_INFORMATION20,P_PPM_INFORMATION21,P_PPM_INFORMATION22,
        P_PPM_INFORMATION23,P_PPM_INFORMATION24,P_PPM_INFORMATION25,P_PPM_INFORMATION26,
        P_PPM_INFORMATION27,P_PPM_INFORMATION28,P_PPM_INFORMATION29,P_PPM_INFORMATION30 );


  OPEN C;
  FETCH C INTO P_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','Insert_row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
  CLOSE C;
--
  IF (P_EXTERNAL_ACCOUNT_ID IS NOT NULL) AND (P_PRENOTE_DATE IS NOT NULL) THEN
--
  UPDATE PAY_EXTERNAL_ACCOUNTS
  SET PRENOTE_DATE = P_PRENOTE_DATE
  WHERE EXTERNAL_ACCOUNT_ID = P_EXTERNAL_ACCOUNT_ID;
--
  END IF;

/** sbilling **/
-- always want to set territory code,
-- update api depends on territory code remaining unchanged
--
  IF (P_EXTERNAL_ACCOUNT_ID IS NOT NULL) AND (P_TERRITORY_CODE IS NOT NULL) THEN
    UPDATE PAY_EXTERNAL_ACCOUNTS
    SET TERRITORY_CODE = P_TERRITORY_CODE
    WHERE EXTERNAL_ACCOUNT_ID = P_EXTERNAL_ACCOUNT_ID;
  END IF;

END INSERT_ROW;
--
   PROCEDURE UPDATE_ROW(P_ROWID                         VARCHAR2,
                        P_PERSONAL_PAYMENT_METHOD_ID    NUMBER,
                        P_EFFECTIVE_START_DATE          DATE,
                        P_EFFECTIVE_END_DATE            DATE,
                        P_BUSINESS_GROUP_ID             NUMBER,
                        P_EXTERNAL_ACCOUNT_ID           NUMBER,
                        P_ASSIGNMENT_ID                 NUMBER,
                        P_PERSON_ID                     NUMBER,
                        P_RUN_TYPE_ID                   NUMBER,
                        P_ORG_PAYMENT_METHOD_ID         NUMBER,
                        P_AMOUNT                        NUMBER,
                        P_COMMENT_ID                    NUMBER,
                        P_PERCENTAGE                    NUMBER,
                        P_PRIORITY                      NUMBER,
                        P_PAYEE_TYPE                    VARCHAR2,
                        P_PAYEE_ID                      NUMBER,
                        P_ATTRIBUTE_CATEGORY            VARCHAR2,
                        P_ATTRIBUTE1                    VARCHAR2,
                        P_ATTRIBUTE2                    VARCHAR2,
                        P_ATTRIBUTE3                    VARCHAR2,
                        P_ATTRIBUTE4                    VARCHAR2,
                        P_ATTRIBUTE5                    VARCHAR2,
                        P_ATTRIBUTE6                    VARCHAR2,
                        P_ATTRIBUTE7                    VARCHAR2,
                        P_ATTRIBUTE8                    VARCHAR2,
                        P_ATTRIBUTE9                    VARCHAR2,
                        P_ATTRIBUTE10                   VARCHAR2,
                        P_ATTRIBUTE11                   VARCHAR2,
                        P_ATTRIBUTE12                   VARCHAR2,
                        P_ATTRIBUTE13                   VARCHAR2,
                        P_ATTRIBUTE14                   VARCHAR2,
                        P_ATTRIBUTE15                   VARCHAR2,
                        P_ATTRIBUTE16                   VARCHAR2,
                        P_ATTRIBUTE17                   VARCHAR2,
                        P_ATTRIBUTE18                   VARCHAR2,
                        P_ATTRIBUTE19                   VARCHAR2,
                        P_ATTRIBUTE20                   VARCHAR2,
                        P_PRENOTE_DATE                  DATE,
/** sbilling **/
                        P_TERRITORY_CODE                VARCHAR2,
                        P_PPM_INFORMATION_CATEGORY      VARCHAR2,
                        P_PPM_INFORMATION1              VARCHAR2,
                        P_PPM_INFORMATION2              VARCHAR2,
                        P_PPM_INFORMATION3              VARCHAR2,
                        P_PPM_INFORMATION4              VARCHAR2,
                        P_PPM_INFORMATION5              VARCHAR2,
                        P_PPM_INFORMATION6              VARCHAR2,
                        P_PPM_INFORMATION7              VARCHAR2,
                        P_PPM_INFORMATION8              VARCHAR2,
                        P_PPM_INFORMATION9              VARCHAR2,
                        P_PPM_INFORMATION10             VARCHAR2,
                        P_PPM_INFORMATION11             VARCHAR2,
                        P_PPM_INFORMATION12             VARCHAR2,
                        P_PPM_INFORMATION13             VARCHAR2,
                        P_PPM_INFORMATION14             VARCHAR2,
                        P_PPM_INFORMATION15             VARCHAR2,
                        P_PPM_INFORMATION16             VARCHAR2,
                        P_PPM_INFORMATION17             VARCHAR2,
                        P_PPM_INFORMATION18             VARCHAR2,
                        P_PPM_INFORMATION19             VARCHAR2,
                        P_PPM_INFORMATION20             VARCHAR2,
                        P_PPM_INFORMATION21             VARCHAR2,
                        P_PPM_INFORMATION22             VARCHAR2,
                        P_PPM_INFORMATION23             VARCHAR2,
                        P_PPM_INFORMATION24             VARCHAR2,
                        P_PPM_INFORMATION25             VARCHAR2,
                        P_PPM_INFORMATION26             VARCHAR2,
                        P_PPM_INFORMATION27             VARCHAR2,
                        P_PPM_INFORMATION28             VARCHAR2,
                        P_PPM_INFORMATION29             VARCHAR2,
                        P_PPM_INFORMATION30             VARCHAR2
) IS

   BEGIN
     UPDATE PAY_PERSONAL_PAYMENT_METHODS_F
     SET        PERSONAL_PAYMENT_METHOD_ID      =       P_PERSONAL_PAYMENT_METHOD_ID,
                EFFECTIVE_START_DATE            =       P_EFFECTIVE_START_DATE,
                        EFFECTIVE_END_DATE      =       P_EFFECTIVE_END_DATE,
                        BUSINESS_GROUP_ID       =       P_BUSINESS_GROUP_ID,
                        EXTERNAL_ACCOUNT_ID     =       P_EXTERNAL_ACCOUNT_ID,
                        ASSIGNMENT_ID           =       P_ASSIGNMENT_ID,
			PERSON_ID		=	P_PERSON_ID,
			RUN_TYPE_ID		=	P_RUN_TYPE_ID,
                        ORG_PAYMENT_METHOD_ID   =       P_ORG_PAYMENT_METHOD_ID,
                        AMOUNT                  =       P_AMOUNT,
                        COMMENT_ID              =       P_COMMENT_ID,
                        PERCENTAGE              =       P_PERCENTAGE,
                        PRIORITY                =       P_PRIORITY,
                        PAYEE_TYPE              =       P_PAYEE_TYPE,
                        PAYEE_ID                =       P_PAYEE_ID,
                        ATTRIBUTE_CATEGORY      =       P_ATTRIBUTE_CATEGORY,
                        ATTRIBUTE1              =       P_ATTRIBUTE1,
                        ATTRIBUTE2              =       P_ATTRIBUTE2,
                        ATTRIBUTE3              =       P_ATTRIBUTE3,
                        ATTRIBUTE4              =       P_ATTRIBUTE4,
                        ATTRIBUTE5              =       P_ATTRIBUTE5,
                        ATTRIBUTE6              =       P_ATTRIBUTE6,
                        ATTRIBUTE7              =       P_ATTRIBUTE7,
                        ATTRIBUTE8              =       P_ATTRIBUTE8,
                        ATTRIBUTE9              =       P_ATTRIBUTE9,
                        ATTRIBUTE10             =       P_ATTRIBUTE10,
                        ATTRIBUTE11             =       P_ATTRIBUTE11,
                        ATTRIBUTE12             =       P_ATTRIBUTE12,
                        ATTRIBUTE13             =       P_ATTRIBUTE13,
                        ATTRIBUTE14             =       P_ATTRIBUTE14,
                        ATTRIBUTE15             =       P_ATTRIBUTE15,
                        ATTRIBUTE16             =       P_ATTRIBUTE16,
                        ATTRIBUTE17             =       P_ATTRIBUTE17,
                        ATTRIBUTE18             =       P_ATTRIBUTE18,
                        ATTRIBUTE19             =       P_ATTRIBUTE19,
                        ATTRIBUTE20             =       P_ATTRIBUTE20,
                        PPM_INFORMATION_CATEGORY =      P_PPM_INFORMATION_CATEGORY,
                        PPM_INFORMATION1        =       P_PPM_INFORMATION1,
                        PPM_INFORMATION2        =       P_PPM_INFORMATION2,
                        PPM_INFORMATION3        =       P_PPM_INFORMATION3,
                        PPM_INFORMATION4        =       P_PPM_INFORMATION4,
                        PPM_INFORMATION5        =       P_PPM_INFORMATION5,
                        PPM_INFORMATION6        =       P_PPM_INFORMATION6,
                        PPM_INFORMATION7        =       P_PPM_INFORMATION7,
                        PPM_INFORMATION8        =       P_PPM_INFORMATION8,
                        PPM_INFORMATION9        =       P_PPM_INFORMATION9,
                        PPM_INFORMATION10       =       P_PPM_INFORMATION10,
                        PPM_INFORMATION11       =       P_PPM_INFORMATION11,
                        PPM_INFORMATION12       =       P_PPM_INFORMATION12,
                        PPM_INFORMATION13       =       P_PPM_INFORMATION13,
                        PPM_INFORMATION14       =       P_PPM_INFORMATION14,
                        PPM_INFORMATION15       =       P_PPM_INFORMATION15,
                        PPM_INFORMATION16       =       P_PPM_INFORMATION16,
                        PPM_INFORMATION17       =       P_PPM_INFORMATION17,
                        PPM_INFORMATION18       =       P_PPM_INFORMATION18,
                        PPM_INFORMATION19       =       P_PPM_INFORMATION19,
                        PPM_INFORMATION20       =       P_PPM_INFORMATION20,
                        PPM_INFORMATION21       =       P_PPM_INFORMATION21,
                        PPM_INFORMATION22       =       P_PPM_INFORMATION22,
                        PPM_INFORMATION23       =       P_PPM_INFORMATION23,
                        PPM_INFORMATION24       =       P_PPM_INFORMATION24,
                        PPM_INFORMATION25       =       P_PPM_INFORMATION25,
                        PPM_INFORMATION26       =       P_PPM_INFORMATION26,
                        PPM_INFORMATION27       =       P_PPM_INFORMATION27,
                        PPM_INFORMATION28       =       P_PPM_INFORMATION28,
                        PPM_INFORMATION29       =       P_PPM_INFORMATION29,
                        PPM_INFORMATION30       =       P_PPM_INFORMATION30
      WHERE ROWID = P_ROWID;
   IF (P_EXTERNAL_ACCOUNT_ID IS NOT NULL) THEN
--
   UPDATE PAY_EXTERNAL_ACCOUNTS
   SET PRENOTE_DATE = P_PRENOTE_DATE
   WHERE EXTERNAL_ACCOUNT_ID = P_EXTERNAL_ACCOUNT_ID;
--
   END IF;

/** sbilling **/
-- always want to set territory code,
-- update api depends on territory code remaining unchanged
--
  IF (P_EXTERNAL_ACCOUNT_ID IS NOT NULL) AND (P_TERRITORY_CODE IS NOT NULL) THEN
    UPDATE PAY_EXTERNAL_ACCOUNTS
    SET TERRITORY_CODE = P_TERRITORY_CODE
    WHERE EXTERNAL_ACCOUNT_ID = P_EXTERNAL_ACCOUNT_ID;
  END IF;

--
   END UPDATE_ROW;

--
   PROCEDURE DELETE_ROW(P_ROWID                 VARCHAR2,
                        P_PPM_ID                NUMBER,
                        P_AFTER_THIS_DATE       DATE,
                        P_PAYEE_TYPE            VARCHAR2) IS
   --
   CURSOR el_ent_check IS
   SELECT 'el_ents_exist'
   FROM   pay_element_entries_f
   WHERE  personal_payment_method_id = p_ppm_id
   AND    effective_end_date         > p_after_this_date;
   --
   l_after_this_date varchar(20);
   l_dummy           varchar(15);
   --
   BEGIN
      --
      -- Check there are no prepayments belonging to the PPM:
      -- - at all, if the delete is a ZAP;
      -- - after the end date, if it's a date effective delete.
      --
      -- The kind of delete is worked out on the client, and the
      -- date parameter passed in is set to start_of_time or session
      -- date accordingly. Change the date passed in to a char first,
      -- because that's what check_pp expects.
      --
      -- Also do a similar check that there are no orphaned element
      -- entries, if this is a 3rd party PPM (i.e. the payee type is
      -- not null). Note that element entries don't apply to non-3rd
      -- party PPMs.
      --
      IF p_payee_type is not null then
        open  el_ent_check;
        fetch el_ent_check into l_dummy;
        --
        IF el_ent_check%FOUND THEN
          close el_ent_check;
          hr_utility.set_message('801', 'HR_7790_PAY_DEL_ENTRIES');
          hr_utility.raise_error;
        ELSE
          close el_ent_check;
        END IF;
      END IF;
      --
      l_after_this_date := fnd_date.date_to_canonical(p_after_this_date);
      --
      IF hr_payments.check_pp (to_char (P_PPM_ID), l_after_this_date) THEN
        DELETE FROM PAY_PERSONAL_PAYMENT_METHODS_F
        WHERE ROWID = P_ROWID;
      ELSE
        hr_utility.set_message('801', 'HR_6498_PAY_DEL_PREPAY');
        hr_utility.raise_error;
      END IF;
   END DELETE_ROW;
--
   PROCEDURE LOCK_ROW(P_ROWID                           VARCHAR2,
                        P_PERSONAL_PAYMENT_METHOD_ID    NUMBER,
                        P_EFFECTIVE_START_DATE          DATE,
                        P_EFFECTIVE_END_DATE            DATE,
                        P_BUSINESS_GROUP_ID             NUMBER,
                        P_EXTERNAL_ACCOUNT_ID           NUMBER,
                        P_ASSIGNMENT_ID                 NUMBER,
                        P_PERSON_ID                     NUMBER,
                        P_RUN_TYPE_ID                   NUMBER,
                        P_ORG_PAYMENT_METHOD_ID         NUMBER,
                        P_AMOUNT                        NUMBER,
                        P_COMMENT_ID                    NUMBER,
                        P_PERCENTAGE                    NUMBER,
                        P_PRIORITY                      NUMBER,
                        P_PAYEE_TYPE                    VARCHAR2,
                        P_PAYEE_ID                      NUMBER,
                        P_ATTRIBUTE_CATEGORY            VARCHAR2,
                        P_ATTRIBUTE1                    VARCHAR2,
                        P_ATTRIBUTE2                    VARCHAR2,
                        P_ATTRIBUTE3                    VARCHAR2,
                        P_ATTRIBUTE4                    VARCHAR2,
                        P_ATTRIBUTE5                    VARCHAR2,
                        P_ATTRIBUTE6                    VARCHAR2,
                        P_ATTRIBUTE7                    VARCHAR2,
                        P_ATTRIBUTE8                    VARCHAR2,
                        P_ATTRIBUTE9                    VARCHAR2,
                        P_ATTRIBUTE10                   VARCHAR2,
                        P_ATTRIBUTE11                   VARCHAR2,
                        P_ATTRIBUTE12                   VARCHAR2,
                        P_ATTRIBUTE13                   VARCHAR2,
                        P_ATTRIBUTE14                   VARCHAR2,
                        P_ATTRIBUTE15                   VARCHAR2,
                        P_ATTRIBUTE16                   VARCHAR2,
                        P_ATTRIBUTE17                   VARCHAR2,
                        P_ATTRIBUTE18                   VARCHAR2,
                        P_ATTRIBUTE19                   VARCHAR2,
                        P_ATTRIBUTE20                   VARCHAR2,
                        P_PRENOTE_DATE                  DATE,
                        P_PPM_INFORMATION_CATEGORY      VARCHAR2,
                        P_PPM_INFORMATION1              VARCHAR2,
                        P_PPM_INFORMATION2              VARCHAR2,
                        P_PPM_INFORMATION3              VARCHAR2,
                        P_PPM_INFORMATION4              VARCHAR2,
                        P_PPM_INFORMATION5              VARCHAR2,
                        P_PPM_INFORMATION6              VARCHAR2,
                        P_PPM_INFORMATION7              VARCHAR2,
                        P_PPM_INFORMATION8              VARCHAR2,
                        P_PPM_INFORMATION9              VARCHAR2,
                        P_PPM_INFORMATION10             VARCHAR2,
                        P_PPM_INFORMATION11             VARCHAR2,
                        P_PPM_INFORMATION12             VARCHAR2,
                        P_PPM_INFORMATION13             VARCHAR2,
                        P_PPM_INFORMATION14             VARCHAR2,
                        P_PPM_INFORMATION15             VARCHAR2,
                        P_PPM_INFORMATION16             VARCHAR2,
                        P_PPM_INFORMATION17             VARCHAR2,
                        P_PPM_INFORMATION18             VARCHAR2,
                        P_PPM_INFORMATION19             VARCHAR2,
                        P_PPM_INFORMATION20             VARCHAR2,
                        P_PPM_INFORMATION21             VARCHAR2,
                        P_PPM_INFORMATION22             VARCHAR2,
                        P_PPM_INFORMATION23             VARCHAR2,
                        P_PPM_INFORMATION24             VARCHAR2,
                        P_PPM_INFORMATION25             VARCHAR2,
                        P_PPM_INFORMATION26             VARCHAR2,
                        P_PPM_INFORMATION27             VARCHAR2,
                        P_PPM_INFORMATION28             VARCHAR2,
                        P_PPM_INFORMATION29             VARCHAR2,
                        P_PPM_INFORMATION30             VARCHAR2 ) IS
   CURSOR C IS SELECT *
               FROM PAY_PERSONAL_PAYMENT_METHODS_F
               WHERE ROWID = P_ROWID
               FOR UPDATE OF PERSONAL_PAYMENT_METHOD_ID NOWAIT;

   CURSOR PRENOTE IS SELECT *
               FROM PAY_EXTERNAL_ACCOUNTS
               WHERE EXTERNAL_ACCOUNT_ID = P_EXTERNAL_ACCOUNT_ID
               FOR UPDATE OF PRENOTE_DATE NOWAIT;

   RECINFO C%ROWTYPE;
   PNINFO  PRENOTE%ROWTYPE;

   BEGIN
   OPEN C;
   FETCH C INTO RECINFO;
   CLOSE C;
    recinfo.payee_type := rtrim(recinfo.payee_type);
    recinfo.attribute_category := rtrim(recinfo.attribute_category);
    recinfo.attribute1 := rtrim(recinfo.attribute1);
    recinfo.attribute2 := rtrim(recinfo.attribute2);
    recinfo.attribute3 := rtrim(recinfo.attribute3);
    recinfo.attribute4 := rtrim(recinfo.attribute4);
    recinfo.attribute5 := rtrim(recinfo.attribute5);
    recinfo.attribute6 := rtrim(recinfo.attribute6);
    recinfo.attribute7 := rtrim(recinfo.attribute7);
    recinfo.attribute8 := rtrim(recinfo.attribute8);
    recinfo.attribute9 := rtrim(recinfo.attribute9);
    recinfo.attribute10 := rtrim(recinfo.attribute10);
    recinfo.attribute11 := rtrim(recinfo.attribute11);
    recinfo.attribute12 := rtrim(recinfo.attribute12);
    recinfo.attribute13 := rtrim(recinfo.attribute13);
    recinfo.attribute14 := rtrim(recinfo.attribute14);
    recinfo.attribute15 := rtrim(recinfo.attribute15);
    recinfo.attribute16 := rtrim(recinfo.attribute16);
    recinfo.attribute17 := rtrim(recinfo.attribute17);
    recinfo.attribute18 := rtrim(recinfo.attribute18);
    recinfo.attribute19 := rtrim(recinfo.attribute19);
    recinfo.attribute20 := rtrim(recinfo.attribute20);
    recinfo.ppm_information_category  := rtrim(recinfo.ppm_information_category);
    recinfo.ppm_information1          := rtrim(recinfo.ppm_information1);
    recinfo.ppm_information2          := rtrim(recinfo.ppm_information2);
    recinfo.ppm_information3          := rtrim(recinfo.ppm_information3);
    recinfo.ppm_information4          := rtrim(recinfo.ppm_information4);
    recinfo.ppm_information5          := rtrim(recinfo.ppm_information5);
    recinfo.ppm_information6          := rtrim(recinfo.ppm_information6);
    recinfo.ppm_information7          := rtrim(recinfo.ppm_information7);
    recinfo.ppm_information8          := rtrim(recinfo.ppm_information8);
    recinfo.ppm_information9          := rtrim(recinfo.ppm_information9);
    recinfo.ppm_information10         := rtrim(recinfo.ppm_information10);
    recinfo.ppm_information11         := rtrim(recinfo.ppm_information11);
    recinfo.ppm_information12         := rtrim(recinfo.ppm_information12);
    recinfo.ppm_information13         := rtrim(recinfo.ppm_information13);
    recinfo.ppm_information14         := rtrim(recinfo.ppm_information14);
    recinfo.ppm_information15         := rtrim(recinfo.ppm_information15);
    recinfo.ppm_information16         := rtrim(recinfo.ppm_information16);
    recinfo.ppm_information17         := rtrim(recinfo.ppm_information17);
    recinfo.ppm_information18         := rtrim(recinfo.ppm_information18);
    recinfo.ppm_information19         := rtrim(recinfo.ppm_information19);
    recinfo.ppm_information20         := rtrim(recinfo.ppm_information20);
    recinfo.ppm_information21         := rtrim(recinfo.ppm_information21);
    recinfo.ppm_information22         := rtrim(recinfo.ppm_information22);
    recinfo.ppm_information23         := rtrim(recinfo.ppm_information23);
    recinfo.ppm_information24         := rtrim(recinfo.ppm_information24);
    recinfo.ppm_information25         := rtrim(recinfo.ppm_information25);
    recinfo.ppm_information26         := rtrim(recinfo.ppm_information26);
    recinfo.ppm_information27         := rtrim(recinfo.ppm_information27);
    recinfo.ppm_information28         := rtrim(recinfo.ppm_information28);
    recinfo.ppm_information29         := rtrim(recinfo.ppm_information29);
    recinfo.ppm_information30         := rtrim(recinfo.ppm_information30);

    IF (
        ( (P_PERSONAL_PAYMENT_METHOD_ID = RECINFO.PERSONAL_PAYMENT_METHOD_ID)
          OR ( (P_PERSONAL_PAYMENT_METHOD_ID IS NULL)
                AND (RECINFO.PERSONAL_PAYMENT_METHOD_ID IS NULL) ) ) AND
        ( (P_EFFECTIVE_START_DATE = RECINFO.EFFECTIVE_START_DATE)
          OR ( (P_EFFECTIVE_START_DATE IS NULL)
                AND (RECINFO.EFFECTIVE_START_DATE IS NULL) ) ) AND
        ( (P_EFFECTIVE_END_DATE = RECINFO.EFFECTIVE_END_DATE)
          OR ( (P_EFFECTIVE_END_DATE IS NULL)
               AND (RECINFO.EFFECTIVE_END_DATE IS NULL) ) ) AND
        ( (P_BUSINESS_GROUP_ID = RECINFO.BUSINESS_GROUP_ID)
          OR ( (P_BUSINESS_GROUP_ID IS NULL)
               AND (RECINFO.BUSINESS_GROUP_ID IS NULL) ) ) AND
        ( (P_EXTERNAL_ACCOUNT_ID = RECINFO.EXTERNAL_ACCOUNT_ID)
          OR ( (P_EXTERNAL_ACCOUNT_ID IS NULL)
               AND (RECINFO.EXTERNAL_ACCOUNT_ID IS NULL) ) ) AND
        ( (P_ASSIGNMENT_ID = RECINFO.ASSIGNMENT_ID)
          OR ( (P_ASSIGNMENT_ID IS NULL)
               AND (RECINFO.ASSIGNMENT_ID IS NULL) ) ) AND
        ( (P_PERSON_ID = RECINFO.PERSON_ID)
          OR ( (P_PERSON_ID IS NULL)
               AND (RECINFO.PERSON_ID IS NULL) ) ) AND
        ( (P_RUN_TYPE_ID = RECINFO.RUN_TYPE_ID)
          OR ( (P_RUN_TYPE_ID IS NULL)
               AND (RECINFO.RUN_TYPE_ID IS NULL) ) ) AND
        ( (P_ORG_PAYMENT_METHOD_ID = RECINFO.ORG_PAYMENT_METHOD_ID)
          OR ( (P_ORG_PAYMENT_METHOD_ID IS NULL)
               AND (RECINFO.ORG_PAYMENT_METHOD_ID IS NULL) ) ) AND
        ( (P_AMOUNT = RECINFO.AMOUNT)
          OR ( (P_AMOUNT IS NULL)
               AND (RECINFO.AMOUNT IS NULL) ) ) AND
        ( (P_COMMENT_ID = RECINFO.COMMENT_ID)
          OR ( (P_COMMENT_ID IS NULL)
               AND (RECINFO.COMMENT_ID IS NULL) ) ) AND
        ( (P_PERCENTAGE = RECINFO.PERCENTAGE)
          OR ( (P_PERCENTAGE IS NULL)
               AND (RECINFO.PERCENTAGE IS NULL) ) ) AND
        ( (P_PRIORITY = RECINFO.PRIORITY)
          OR ( (P_PRIORITY IS NULL)
               AND (RECINFO.PRIORITY IS NULL) ) ) AND
        ( (P_PAYEE_TYPE = RECINFO.PAYEE_TYPE)
          OR ( (P_PAYEE_TYPE IS NULL)
               AND (RECINFO.PAYEE_TYPE IS NULL) ) ) AND
        ( (P_PAYEE_ID = RECINFO.PAYEE_ID)
          OR ( (P_PAYEE_ID IS NULL)
               AND (RECINFO.PAYEE_ID IS NULL) ) ) AND
        ( (P_ATTRIBUTE_CATEGORY = RECINFO.ATTRIBUTE_CATEGORY)
          OR ( (P_ATTRIBUTE_CATEGORY IS NULL)
               AND (RECINFO.ATTRIBUTE_CATEGORY IS NULL) ) ) AND
        ( (P_ATTRIBUTE1 = RECINFO.ATTRIBUTE1)
          OR ( (P_ATTRIBUTE1 IS NULL)
               AND (RECINFO.ATTRIBUTE1 IS NULL) ) ) AND
        ( (P_ATTRIBUTE2 = RECINFO.ATTRIBUTE2)
          OR ( (P_ATTRIBUTE2 IS NULL)
               AND (RECINFO.ATTRIBUTE2 IS NULL) ) ) AND
        ( (P_ATTRIBUTE3 = RECINFO.ATTRIBUTE3)
          OR ( (P_ATTRIBUTE3 IS NULL)
               AND (RECINFO.ATTRIBUTE3 IS NULL) ) ) AND
        ( (P_ATTRIBUTE4 = RECINFO.ATTRIBUTE4)
          OR ( (P_ATTRIBUTE4 IS NULL)
               AND (RECINFO.ATTRIBUTE4 IS NULL) ) ) AND
        ( (P_ATTRIBUTE5 = RECINFO.ATTRIBUTE5)
          OR ( (P_ATTRIBUTE5 IS NULL)
               AND (RECINFO.ATTRIBUTE5 IS NULL) ) ) AND
        ( (P_ATTRIBUTE6 = RECINFO.ATTRIBUTE6)
          OR ( (P_ATTRIBUTE6 IS NULL)
               AND (RECINFO.ATTRIBUTE6 IS NULL) ) ) AND
        ( (P_ATTRIBUTE7 = RECINFO.ATTRIBUTE7)
          OR ( (P_ATTRIBUTE7 IS NULL)
               AND (RECINFO.ATTRIBUTE7 IS NULL) ) ) AND
        ( (P_ATTRIBUTE8 = RECINFO.ATTRIBUTE8)
          OR ( (P_ATTRIBUTE8 IS NULL)
               AND (RECINFO.ATTRIBUTE8 IS NULL) ) ) AND
        ( (P_ATTRIBUTE9 = RECINFO.ATTRIBUTE9)
          OR ( (P_ATTRIBUTE9 IS NULL)
               AND (RECINFO.ATTRIBUTE9 IS NULL) ) ) AND
        ( (P_ATTRIBUTE10 = RECINFO.ATTRIBUTE10)
          OR ( (P_ATTRIBUTE10 IS NULL)
               AND (RECINFO.ATTRIBUTE10 IS NULL) ) ) AND
        ( (P_ATTRIBUTE11 = RECINFO.ATTRIBUTE11)
          OR ( (P_ATTRIBUTE11 IS NULL)
               AND (RECINFO.ATTRIBUTE11 IS NULL) ) ) AND
        ( (P_ATTRIBUTE12 = RECINFO.ATTRIBUTE12)
          OR ( (P_ATTRIBUTE12 IS NULL)
               AND (RECINFO.ATTRIBUTE12 IS NULL) ) ) AND
        ( (P_ATTRIBUTE13 = RECINFO.ATTRIBUTE13)
          OR ( (P_ATTRIBUTE13 IS NULL)
               AND (RECINFO.ATTRIBUTE13 IS NULL) ) ) AND
        ( (P_ATTRIBUTE14 = RECINFO.ATTRIBUTE14)
          OR ( (P_ATTRIBUTE14 IS NULL)
               AND (RECINFO.ATTRIBUTE14 IS NULL) ) ) AND
        ( (P_ATTRIBUTE15 = RECINFO.ATTRIBUTE15)
          OR ( (P_ATTRIBUTE15 IS NULL)
               AND (RECINFO.ATTRIBUTE15 IS NULL) ) ) AND
        ( (P_ATTRIBUTE16 = RECINFO.ATTRIBUTE16)
          OR ( (P_ATTRIBUTE16 IS NULL)
               AND (RECINFO.ATTRIBUTE16 IS NULL) ) ) AND
        ( (P_ATTRIBUTE17 = RECINFO.ATTRIBUTE17)
          OR ( (P_ATTRIBUTE17 IS NULL)
               AND (RECINFO.ATTRIBUTE17 IS NULL) ) ) AND
        ( (P_ATTRIBUTE18 = RECINFO.ATTRIBUTE18)
          OR ( (P_ATTRIBUTE18 IS NULL)
               AND (RECINFO.ATTRIBUTE18 IS NULL) ) ) AND
        ( (P_ATTRIBUTE19 = RECINFO.ATTRIBUTE19)
          OR ( (P_ATTRIBUTE19 IS NULL)
               AND (RECINFO.ATTRIBUTE19 IS NULL) ) ) AND
        ( (P_ATTRIBUTE20 = RECINFO.ATTRIBUTE20)
          OR ( (P_ATTRIBUTE20 IS NULL)
               AND (RECINFO.ATTRIBUTE20 IS NULL) ) ) AND
          ((recinfo.PPM_INFORMATION_CATEGORY = P_PPM_INFORMATION_CATEGORY)
           OR ((recinfo.PPM_INFORMATION_CATEGORY is null) AND (P_PPM_INFORMATION_CATEGORY is null)))
      AND ((recinfo.PPM_INFORMATION1 = P_PPM_INFORMATION1)
           OR ((recinfo.PPM_INFORMATION1 is null) AND (P_PPM_INFORMATION1 is null)))
      AND ((recinfo.PPM_INFORMATION2 = P_PPM_INFORMATION2)
           OR ((recinfo.PPM_INFORMATION2 is null) AND (P_PPM_INFORMATION2 is null)))
      AND ((recinfo.PPM_INFORMATION3 = P_PPM_INFORMATION3)
           OR ((recinfo.PPM_INFORMATION3 is null) AND (P_PPM_INFORMATION3 is null)))
      AND ((recinfo.PPM_INFORMATION4 = P_PPM_INFORMATION4)
           OR ((recinfo.PPM_INFORMATION4 is null) AND (P_PPM_INFORMATION4 is null)))
      AND ((recinfo.PPM_INFORMATION5 = P_PPM_INFORMATION5)
           OR ((recinfo.PPM_INFORMATION5 is null) AND (P_PPM_INFORMATION5 is null)))
      AND ((recinfo.PPM_INFORMATION6 = P_PPM_INFORMATION6)
           OR ((recinfo.PPM_INFORMATION6 is null) AND (P_PPM_INFORMATION6 is null)))
      AND ((recinfo.PPM_INFORMATION7 = P_PPM_INFORMATION7)
           OR ((recinfo.PPM_INFORMATION7 is null) AND (P_PPM_INFORMATION7 is null)))
      AND ((recinfo.PPM_INFORMATION8 = P_PPM_INFORMATION8)
           OR ((recinfo.PPM_INFORMATION8 is null) AND (P_PPM_INFORMATION8 is null)))
      AND ((recinfo.PPM_INFORMATION9 = P_PPM_INFORMATION9)
           OR ((recinfo.PPM_INFORMATION9 is null) AND (P_PPM_INFORMATION9 is null)))
      AND ((recinfo.PPM_INFORMATION10 = P_PPM_INFORMATION10)
           OR ((recinfo.PPM_INFORMATION10 is null) AND (P_PPM_INFORMATION10 is null)))
      AND ((recinfo.PPM_INFORMATION11 = P_PPM_INFORMATION11)
           OR ((recinfo.PPM_INFORMATION11 is null) AND (P_PPM_INFORMATION11 is null)))
      AND ((recinfo.PPM_INFORMATION12 = P_PPM_INFORMATION12)
           OR ((recinfo.PPM_INFORMATION12 is null) AND (P_PPM_INFORMATION12 is null)))
      AND ((recinfo.PPM_INFORMATION13 = P_PPM_INFORMATION13)
           OR ((recinfo.PPM_INFORMATION13 is null) AND (P_PPM_INFORMATION13 is null)))
      AND ((recinfo.PPM_INFORMATION14 = P_PPM_INFORMATION14)
           OR ((recinfo.PPM_INFORMATION14 is null) AND (P_PPM_INFORMATION14 is null)))
      AND ((recinfo.PPM_INFORMATION15 = P_PPM_INFORMATION15)
           OR ((recinfo.PPM_INFORMATION15 is null) AND (P_PPM_INFORMATION15 is null)))
      AND ((recinfo.PPM_INFORMATION16 = P_PPM_INFORMATION16)
           OR ((recinfo.PPM_INFORMATION16 is null) AND (P_PPM_INFORMATION16 is null)))
      AND ((recinfo.PPM_INFORMATION17 = P_PPM_INFORMATION17)
           OR ((recinfo.PPM_INFORMATION17 is null) AND (P_PPM_INFORMATION17 is null)))
      AND ((recinfo.PPM_INFORMATION18 = P_PPM_INFORMATION18)
           OR ((recinfo.PPM_INFORMATION18 is null) AND (P_PPM_INFORMATION18 is null)))
      AND ((recinfo.PPM_INFORMATION19 = P_PPM_INFORMATION19)
           OR ((recinfo.PPM_INFORMATION19 is null) AND (P_PPM_INFORMATION19 is null)))
      AND ((recinfo.PPM_INFORMATION20 = P_PPM_INFORMATION20)
           OR ((recinfo.PPM_INFORMATION20 is null) AND (P_PPM_INFORMATION20 is null)))
      AND ((recinfo.PPM_INFORMATION21 = P_PPM_INFORMATION21)
           OR ((recinfo.PPM_INFORMATION21 is null) AND (P_PPM_INFORMATION21 is null)))
      AND ((recinfo.PPM_INFORMATION22 = P_PPM_INFORMATION22)
           OR ((recinfo.PPM_INFORMATION22 is null) AND (P_PPM_INFORMATION22 is null)))
      AND ((recinfo.PPM_INFORMATION23 = P_PPM_INFORMATION23)
           OR ((recinfo.PPM_INFORMATION23 is null) AND (P_PPM_INFORMATION23 is null)))
      AND ((recinfo.PPM_INFORMATION24 = P_PPM_INFORMATION24)
           OR ((recinfo.PPM_INFORMATION24 is null) AND (P_PPM_INFORMATION24 is null)))
      AND ((recinfo.PPM_INFORMATION25 = P_PPM_INFORMATION25)
           OR ((recinfo.PPM_INFORMATION25 is null) AND (P_PPM_INFORMATION25 is null)))
      AND ((recinfo.PPM_INFORMATION26 = P_PPM_INFORMATION26)
           OR ((recinfo.PPM_INFORMATION26 is null) AND (P_PPM_INFORMATION26 is null)))
      AND ((recinfo.PPM_INFORMATION27 = P_PPM_INFORMATION27)
           OR ((recinfo.PPM_INFORMATION27 is null) AND (P_PPM_INFORMATION27 is null)))
      AND ((recinfo.PPM_INFORMATION28 = P_PPM_INFORMATION28)
           OR ((recinfo.PPM_INFORMATION28 is null) AND (P_PPM_INFORMATION28 is null)))
      AND ((recinfo.PPM_INFORMATION29 = P_PPM_INFORMATION29)
           OR ((recinfo.PPM_INFORMATION29 is null) AND (P_PPM_INFORMATION29 is null)))
      AND ((recinfo.PPM_INFORMATION30 = P_PPM_INFORMATION30)
           OR ((recinfo.PPM_INFORMATION30 is null) AND (P_PPM_INFORMATION30 is null)))
       ) THEN
      --
      -- Now take out the lock on the external_account record in
      -- in case the prenote_date gets changed.
      --
      open prenote;
      fetch prenote into pninfo;
      if prenote%notfound then
        --
        -- no problem: pay method is not prenoted. Can return now.
        --
        close prenote;
        return;
      else
        close prenote;
      end if;
      if ( (P_PRENOTE_DATE = PNINFO.PRENOTE_DATE)
            OR ( (P_PRENOTE_DATE IS NULL)
                AND (PNINFO.PRENOTE_DATE IS NULL) ) ) THEN
        --
        -- OK. Neither the pay method rec nor the external a/c rec has
        -- changed, so we can return with success.
        --
        return;
      else
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
        APP_EXCEPTION.RAISE_EXCEPTION;
      end if;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;
END LOCK_ROW;
--
  procedure check_asg_on_payroll (p_asg_id     varchar2,
                                  p_new_date   varchar2) is
  --
  l_payroll_id  number(9);
  --
  -- This procedure is called when changing session date, to make sure the
  -- asg still has a payroll as of the new session date. If it hasn't, the
  -- user is not meant to have access to the form, so raise an error and
  -- refuse to allow the date change. #293382.
  --
  cursor payroll_on_new_date is
  select payroll_id
  from   per_all_assignments_f
  where  assignment_id = to_number (p_asg_id)
  and    fnd_date.canonical_to_date(p_new_date) between effective_start_date
                                             and     effective_end_date;
  --
  begin
    open  payroll_on_new_date;
    fetch payroll_on_new_date into l_payroll_id;
    --
    -- check for the case that the asg simply doesn't exist at the date
    --
    if payroll_on_new_date%notfound then
      close payroll_on_new_date;
      hr_utility.set_message('801', 'HR_51029_ASG_NO_PAYROLL');
      hr_utility.raise_error;
    else
      close payroll_on_new_date;
      --
      -- the asg exists: now check for a null payroll
      --
      if l_payroll_id is null then
        hr_utility.set_message('801', 'HR_51029_ASG_NO_PAYROLL');
        hr_utility.raise_error;
      end if;
    end if;
  end check_asg_on_payroll;
--
END PAY_PAYMENT_METHODS_PKG;

/
