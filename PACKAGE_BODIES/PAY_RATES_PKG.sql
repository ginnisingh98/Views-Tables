--------------------------------------------------------
--  DDL for Package Body PAY_RATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_RATES_PKG" AS
/* $Header: pyrat01t.pkb 115.3 2002/12/17 13:55:52 dsaxby ship $ */

  PROCEDURE INSERT_ROW(P_ROWID IN OUT           NOCOPY VARCHAR2,
                       P_RATE_ID IN OUT         NOCOPY NUMBER,
                       P_BUSINESS_GROUP_ID      NUMBER,
                       P_PARENT_SPINE_ID        NUMBER,
                       P_NAME                   VARCHAR2,
                       P_RATE_TYPE              VARCHAR2,
                       P_RATE_UOM               VARCHAR2,
                       P_COMMENTS               VARCHAR2,
                       P_REQUEST_ID             NUMBER,
                       P_PROGRAM_APPLICATION_ID NUMBER,
                       P_PROGRAM_ID             NUMBER,
                       P_PROGRAM_UPDATE_DATE    DATE,
                       P_ATTRIBUTE_CATEGORY     VARCHAR2,
                       P_ATTRIBUTE1             VARCHAR2,
                       P_ATTRIBUTE2             VARCHAR2,
                       P_ATTRIBUTE3             VARCHAR2,
                       P_ATTRIBUTE4             VARCHAR2,
                       P_ATTRIBUTE5             VARCHAR2,
                       P_ATTRIBUTE6             VARCHAR2,
                       P_ATTRIBUTE7             VARCHAR2,
                       P_ATTRIBUTE8             VARCHAR2,
                       P_ATTRIBUTE9             VARCHAR2,
                       P_ATTRIBUTE10            VARCHAR2,
                       P_ATTRIBUTE11            VARCHAR2,
                       P_ATTRIBUTE12            VARCHAR2,
                       P_ATTRIBUTE13            VARCHAR2,
                       P_ATTRIBUTE14            VARCHAR2,
                       P_ATTRIBUTE15            VARCHAR2,
                       P_ATTRIBUTE16            VARCHAR2,
                       P_ATTRIBUTE17            VARCHAR2,
                       P_ATTRIBUTE18            VARCHAR2,
                       P_ATTRIBUTE19            VARCHAR2,
                       P_ATTRIBUTE20            VARCHAR2,
                       P_RATE_BASIS             VARCHAR2) IS

 CURSOR c1 IS

   SELECT PAY_RATES_S.NEXTVAL
   FROM SYS.DUAL;

 CURSOR c2 IS

   SELECT rowid
   FROM PAY_RATES
   WHERE RATE_ID = P_RATE_ID;

  BEGIN


   OPEN c1;
   FETCH c1 INTO P_RATE_ID;
   CLOSE c1;



    INSERT INTO PAY_RATES (RATE_ID, BUSINESS_GROUP_ID, PARENT_SPINE_ID,
                           NAME, RATE_TYPE, RATE_UOM, COMMENTS, REQUEST_ID,
                           PROGRAM_APPLICATION_ID, PROGRAM_ID,
                           PROGRAM_UPDATE_DATE, ATTRIBUTE_CATEGORY,
                           ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4,
                           ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8,
                           ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12,
                           ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15, ATTRIBUTE16,
                           ATTRIBUTE17, ATTRIBUTE18, ATTRIBUTE19, ATTRIBUTE20,
                           RATE_BASIS)
    VALUES (P_RATE_ID, P_BUSINESS_GROUP_ID, P_PARENT_SPINE_ID,
            P_NAME, P_RATE_TYPE, P_RATE_UOM, P_COMMENTS, P_REQUEST_ID,
            P_PROGRAM_APPLICATION_ID, P_PROGRAM_ID,
            P_PROGRAM_UPDATE_DATE, P_ATTRIBUTE_CATEGORY,
            P_ATTRIBUTE1, P_ATTRIBUTE2, P_ATTRIBUTE3, P_ATTRIBUTE4,
            P_ATTRIBUTE5, P_ATTRIBUTE6, P_ATTRIBUTE7, P_ATTRIBUTE8,
            P_ATTRIBUTE9, P_ATTRIBUTE10, P_ATTRIBUTE11, P_ATTRIBUTE12,
            P_ATTRIBUTE13, P_ATTRIBUTE14, P_ATTRIBUTE15, P_ATTRIBUTE16,
            P_ATTRIBUTE17, P_ATTRIBUTE18, P_ATTRIBUTE19, P_ATTRIBUTE20,
            P_RATE_BASIS);


   OPEN c2;
   FETCH c2 INTO P_ROWID;
   CLOSE c2;



         /* calling database package to insert database item     */

             hrdyndbi.create_grade_spine_dict(P_RATE_ID);


 END INSERT_ROW;
--

  PROCEDURE UPDATE_ROW(P_ROWID                  VARCHAR2,
                       P_RATE_ID                NUMBER,
                       P_BUSINESS_GROUP_ID      NUMBER,
                       P_PARENT_SPINE_ID        NUMBER,
                       P_NAME                   VARCHAR2,
                       P_RATE_TYPE              VARCHAR2,
                       P_RATE_UOM               VARCHAR2,
                       P_COMMENTS               VARCHAR2,
                       P_REQUEST_ID             NUMBER,
                       P_PROGRAM_APPLICATION_ID NUMBER,
                       P_PROGRAM_ID             NUMBER,
                       P_PROGRAM_UPDATE_DATE    DATE,
                       P_ATTRIBUTE_CATEGORY     VARCHAR2,
                       P_ATTRIBUTE1             VARCHAR2,
                       P_ATTRIBUTE2             VARCHAR2,
                       P_ATTRIBUTE3             VARCHAR2,
                       P_ATTRIBUTE4             VARCHAR2,
                       P_ATTRIBUTE5             VARCHAR2,
                       P_ATTRIBUTE6             VARCHAR2,
                       P_ATTRIBUTE7             VARCHAR2,
                       P_ATTRIBUTE8             VARCHAR2,
                       P_ATTRIBUTE9             VARCHAR2,
                       P_ATTRIBUTE10            VARCHAR2,
                       P_ATTRIBUTE11            VARCHAR2,
                       P_ATTRIBUTE12            VARCHAR2,
                       P_ATTRIBUTE13            VARCHAR2,
                       P_ATTRIBUTE14            VARCHAR2,
                       P_ATTRIBUTE15            VARCHAR2,
                       P_ATTRIBUTE16            VARCHAR2,
                       P_ATTRIBUTE17            VARCHAR2,
                       P_ATTRIBUTE18            VARCHAR2,
                       P_ATTRIBUTE19            VARCHAR2,
                       P_ATTRIBUTE20            VARCHAR2,
                       P_RATE_BASIS             VARCHAR2) IS
  BEGIN
     UPDATE PAY_RATES
     SET       RATE_ID                   =      P_RATE_ID   ,
               BUSINESS_GROUP_ID         =      P_BUSINESS_GROUP_ID  ,
               PARENT_SPINE_ID           =      P_PARENT_SPINE_ID    ,
               NAME                      =      P_NAME               ,
               RATE_TYPE                 =      P_RATE_TYPE          ,
               RATE_UOM                  =      P_RATE_UOM           ,
               COMMENTS                  =      P_COMMENTS           ,
               REQUEST_ID                =      P_REQUEST_ID         ,
               PROGRAM_APPLICATION_ID    =      P_PROGRAM_APPLICATION_ID ,
               PROGRAM_ID                =      P_PROGRAM_ID             ,
               PROGRAM_UPDATE_DATE       =      P_PROGRAM_UPDATE_DATE    ,
               ATTRIBUTE_CATEGORY        =      P_ATTRIBUTE_CATEGORY     ,
               ATTRIBUTE1                =      P_ATTRIBUTE1             ,
               ATTRIBUTE2                =      P_ATTRIBUTE2             ,
               ATTRIBUTE3                =      P_ATTRIBUTE3             ,
               ATTRIBUTE4                =      P_ATTRIBUTE4             ,
               ATTRIBUTE5                =      P_ATTRIBUTE5             ,
               ATTRIBUTE6                =      P_ATTRIBUTE6             ,
               ATTRIBUTE7                =      P_ATTRIBUTE7             ,
               ATTRIBUTE8                =      P_ATTRIBUTE8             ,
               ATTRIBUTE9                =      P_ATTRIBUTE9             ,
               ATTRIBUTE10               =      P_ATTRIBUTE10            ,
               ATTRIBUTE11               =      P_ATTRIBUTE11            ,
               ATTRIBUTE12               =      P_ATTRIBUTE12            ,
               ATTRIBUTE13               =      P_ATTRIBUTE13            ,
               ATTRIBUTE14               =      P_ATTRIBUTE14            ,
               ATTRIBUTE15               =      P_ATTRIBUTE15            ,
               ATTRIBUTE16               =      P_ATTRIBUTE16            ,
               ATTRIBUTE17               =      P_ATTRIBUTE17            ,
               ATTRIBUTE18               =      P_ATTRIBUTE18            ,
               ATTRIBUTE19               =      P_ATTRIBUTE19            ,
               ATTRIBUTE20               =      P_ATTRIBUTE20            ,
               RATE_BASIS                =      P_RATE_BASIS
        WHERE ROWID = P_ROWID;

/* calling database package to first delete the existing database item
   and then call the database package to insert the updated database item */

      hrdyndbi.delete_grade_spine_dict(P_RATE_ID);
      hrdyndbi.create_grade_spine_dict(P_RATE_ID);

   END UPDATE_ROW;

--
  PROCEDURE DELETE_ROW(P_ROWID VARCHAR2,P_RATE_ID NUMBER,P_CHILD VARCHAR2) IS

  BEGIN

   IF P_CHILD = 'Y'
   THEN

    /* delete any children if they exist */
   DELETE FROM PAY_GRADE_RULES_F
   WHERE RATE_ID = P_RATE_ID;

   END IF;

   /* now delete the master */
   DELETE FROM PAY_RATES WHERE PAY_RATES.ROWID = P_ROWID;

   /* calling database package to delete database item */

   hrdyndbi.delete_grade_spine_dict(P_RATE_ID);

  END DELETE_ROW;


--
  PROCEDURE LOCK_ROW(P_ROWID                  VARCHAR2,
                       P_RATE_ID                NUMBER,
                       P_BUSINESS_GROUP_ID      NUMBER,
                       P_PARENT_SPINE_ID        NUMBER,
                       P_NAME                   VARCHAR2,
                       P_RATE_TYPE              VARCHAR2,
                       P_RATE_UOM               VARCHAR2,
                       P_COMMENTS               VARCHAR2,
                       P_REQUEST_ID             NUMBER,
                       P_PROGRAM_APPLICATION_ID NUMBER,
                       P_PROGRAM_ID             NUMBER,
                       P_PROGRAM_UPDATE_DATE    DATE,
                       P_ATTRIBUTE_CATEGORY     VARCHAR2,
                       P_ATTRIBUTE1             VARCHAR2,
                       P_ATTRIBUTE2             VARCHAR2,
                       P_ATTRIBUTE3             VARCHAR2,
                       P_ATTRIBUTE4             VARCHAR2,
                       P_ATTRIBUTE5             VARCHAR2,
                       P_ATTRIBUTE6             VARCHAR2,
                       P_ATTRIBUTE7             VARCHAR2,
                       P_ATTRIBUTE8             VARCHAR2,
                       P_ATTRIBUTE9             VARCHAR2,
                       P_ATTRIBUTE10            VARCHAR2,
                       P_ATTRIBUTE11            VARCHAR2,
                       P_ATTRIBUTE12            VARCHAR2,
                       P_ATTRIBUTE13            VARCHAR2,
                       P_ATTRIBUTE14            VARCHAR2,
                       P_ATTRIBUTE15            VARCHAR2,
                       P_ATTRIBUTE16            VARCHAR2,
                       P_ATTRIBUTE17            VARCHAR2,
                       P_ATTRIBUTE18            VARCHAR2,
                       P_ATTRIBUTE19            VARCHAR2,
                       P_ATTRIBUTE20            VARCHAR2,
                       P_CHILD_EXIST            VARCHAR2,
                       P_MODE                   VARCHAR2,
                       P_RATE_BASIS             VARCHAR2) IS


CURSOR C IS SELECT * FROM PAY_RATES WHERE ROWID = P_ROWID
            FOR UPDATE OF RATE_ID NOWAIT;

CURSOR C2 IS SELECT * FROM PAY_GRADE_RULES_F WHERE  RATE_ID = P_RATE_ID
            FOR UPDATE OF GRADE_RULE_ID NOWAIT;

RECINFO C%ROWTYPE;
BEGIN

     IF (P_CHILD_EXIST = 'Y') AND (P_MODE = 'D')
     THEN

      /* LOCK ALL THE CHILDREN RECORDS */
      FOR DUMMY IN C2
      LOOP
           NULL;
      END LOOP;


     END IF;

 OPEN C;
  FETCH C INTO RECINFO;
 CLOSE C;

RECINFO.name := rtrim(RECINFO.name);
RECINFO.rate_type := rtrim(RECINFO.rate_type);
RECINFO.rate_uom := rtrim(RECINFO.rate_uom);
RECINFO.comments := rtrim(RECINFO.comments);
RECINFO.attribute_category := rtrim(RECINFO.attribute_category);
RECINFO.attribute1 := rtrim(RECINFO.attribute1);
RECINFO.attribute2 := rtrim(RECINFO.attribute2);
RECINFO.attribute3 := rtrim(RECINFO.attribute3);
RECINFO.attribute4 := rtrim(RECINFO.attribute4);
RECINFO.attribute5 := rtrim(RECINFO.attribute5);
RECINFO.attribute6 := rtrim(RECINFO.attribute6);
RECINFO.attribute7 := rtrim(RECINFO.attribute7);
RECINFO.attribute8 := rtrim(RECINFO.attribute8);
RECINFO.attribute9 := rtrim(RECINFO.attribute9);
RECINFO.attribute10 := rtrim(RECINFO.attribute10);
RECINFO.attribute11 := rtrim(RECINFO.attribute11);
RECINFO.attribute12 := rtrim(RECINFO.attribute12);
RECINFO.attribute13 := rtrim(RECINFO.attribute13);
RECINFO.attribute14 := rtrim(RECINFO.attribute14);
RECINFO.attribute15 := rtrim(RECINFO.attribute15);
RECINFO.attribute16 := rtrim(RECINFO.attribute16);
RECINFO.attribute17 := rtrim(RECINFO.attribute17);
RECINFO.attribute18 := rtrim(RECINFO.attribute18);
RECINFO.attribute19 := rtrim(RECINFO.attribute19);
RECINFO.attribute20 := rtrim(RECINFO.attribute20);
RECINFO.rate_basis := rtrim(RECINFO.rate_basis);

IF (((RECINFO.RATE_ID = P_RATE_ID)
 OR(RECINFO.RATE_ID IS NULL AND P_RATE_ID IS NULL))
AND((RECINFO.BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID)
 OR(RECINFO.BUSINESS_GROUP_ID IS NULL AND P_BUSINESS_GROUP_ID IS NULL))
AND((RECINFO.PARENT_SPINE_ID = P_PARENT_SPINE_ID)
 OR(RECINFO.PARENT_SPINE_ID IS NULL AND P_PARENT_SPINE_ID IS NULL))
AND((RECINFO.NAME = P_NAME)
 OR(RECINFO.NAME IS NULL AND P_NAME IS NULL))
AND((RECINFO.RATE_TYPE = P_RATE_TYPE)
 OR(RECINFO.RATE_TYPE IS NULL AND P_RATE_TYPE IS NULL))
AND((RECINFO.RATE_UOM = P_RATE_UOM)
 OR(RECINFO.RATE_UOM IS NULL AND P_RATE_UOM IS NULL))
AND((RECINFO.COMMENTS = P_COMMENTS)
 OR(RECINFO.COMMENTS IS NULL AND P_COMMENTS IS NULL))
AND((RECINFO.REQUEST_ID = P_REQUEST_ID)
 OR(RECINFO.REQUEST_ID IS NULL AND P_REQUEST_ID IS NULL))
AND((RECINFO.PROGRAM_APPLICATION_ID = P_PROGRAM_APPLICATION_ID)
 OR(RECINFO.PROGRAM_APPLICATION_ID IS NULL AND P_PROGRAM_APPLICATION_ID IS NULL))
AND((RECINFO.PROGRAM_ID = P_PROGRAM_ID)
 OR(RECINFO.PROGRAM_ID IS NULL AND P_PROGRAM_ID IS NULL))
AND((RECINFO.PROGRAM_UPDATE_DATE = P_PROGRAM_UPDATE_DATE)
 OR(RECINFO.PROGRAM_UPDATE_DATE IS NULL AND P_PROGRAM_UPDATE_DATE IS NULL))
AND((RECINFO.ATTRIBUTE_CATEGORY = P_ATTRIBUTE_CATEGORY)
 OR(RECINFO.ATTRIBUTE_CATEGORY IS NULL AND P_ATTRIBUTE_CATEGORY IS NULL))
AND((RECINFO.ATTRIBUTE1 = P_ATTRIBUTE1)
 OR(RECINFO.ATTRIBUTE1 IS NULL AND P_ATTRIBUTE1 IS NULL))
AND((RECINFO.ATTRIBUTE2 = P_ATTRIBUTE2)
 OR(RECINFO.ATTRIBUTE2 IS NULL AND P_ATTRIBUTE2 IS NULL))
AND((RECINFO.ATTRIBUTE3 = P_ATTRIBUTE3)
OR(RECINFO.ATTRIBUTE3 IS NULL AND P_ATTRIBUTE3 IS NULL))
AND((RECINFO.ATTRIBUTE4 = P_ATTRIBUTE4)
 OR(RECINFO.ATTRIBUTE4 IS NULL AND P_ATTRIBUTE4 IS NULL))
AND((RECINFO.ATTRIBUTE5 = P_ATTRIBUTE5)
 OR(RECINFO.ATTRIBUTE5 IS NULL AND P_ATTRIBUTE5 IS NULL))
AND((RECINFO.ATTRIBUTE6 = P_ATTRIBUTE6)
 OR(RECINFO.ATTRIBUTE6 IS NULL AND P_ATTRIBUTE6 IS NULL))
AND((RECINFO.ATTRIBUTE7 = P_ATTRIBUTE7)
 OR(RECINFO.ATTRIBUTE7 IS NULL AND P_ATTRIBUTE7 IS NULL))
AND((RECINFO.ATTRIBUTE8 = P_ATTRIBUTE8)
 OR(RECINFO.ATTRIBUTE8 IS NULL AND P_ATTRIBUTE8 IS NULL))
AND((RECINFO.ATTRIBUTE9 = P_ATTRIBUTE9)
 OR(RECINFO.ATTRIBUTE9 IS NULL AND P_ATTRIBUTE9 IS NULL))
AND((RECINFO.ATTRIBUTE10 = P_ATTRIBUTE10)
 OR(RECINFO.ATTRIBUTE10 IS NULL AND P_ATTRIBUTE10 IS NULL))
AND((RECINFO.ATTRIBUTE11 = P_ATTRIBUTE11)
 OR(RECINFO.ATTRIBUTE11 IS NULL AND P_ATTRIBUTE11 IS NULL))
AND((RECINFO.ATTRIBUTE12 = P_ATTRIBUTE13)
 OR(RECINFO.ATTRIBUTE12 IS NULL AND P_ATTRIBUTE12 IS NULL))
AND((RECINFO.ATTRIBUTE13 = P_ATTRIBUTE13)
 OR(RECINFO.ATTRIBUTE13 IS NULL AND P_ATTRIBUTE13 IS NULL))
AND((RECINFO.ATTRIBUTE14 = P_ATTRIBUTE14)
 OR(RECINFO.ATTRIBUTE14 IS NULL AND P_ATTRIBUTE14 IS NULL))
AND((RECINFO.ATTRIBUTE15 = P_ATTRIBUTE15)
 OR(RECINFO.ATTRIBUTE15 IS NULL AND P_ATTRIBUTE15 IS NULL))
AND((RECINFO.ATTRIBUTE16 = P_ATTRIBUTE16)
 OR(RECINFO.ATTRIBUTE16 IS NULL AND P_ATTRIBUTE16 IS NULL))
AND((RECINFO.ATTRIBUTE17 = P_ATTRIBUTE17)
 OR(RECINFO.ATTRIBUTE17 IS NULL AND P_ATTRIBUTE17 IS NULL))
AND((RECINFO.ATTRIBUTE18 = P_ATTRIBUTE18)
 OR(RECINFO.ATTRIBUTE18 IS NULL AND P_ATTRIBUTE18 IS NULL))
AND((RECINFO.ATTRIBUTE19 = P_ATTRIBUTE19)
 OR(RECINFO.ATTRIBUTE19 IS NULL AND P_ATTRIBUTE19 IS NULL))
AND((RECINFO.ATTRIBUTE20 = P_ATTRIBUTE20)
 OR(RECINFO.ATTRIBUTE20 IS NULL AND P_ATTRIBUTE20 IS NULL))
AND((RECINFO.RATE_BASIS = P_RATE_BASIS)
 OR(RECINFO.RATE_BASIS IS NULL AND P_RATE_BASIS IS NULL)))
THEN
  RETURN;
ELSE
   FND_MESSAGE.SET_NAME('FND','FORM_RECORD_CHANGED');
   APP_EXCEPTION.RAISE_EXCEPTION;

 END IF;
END LOCK_ROW;

END PAY_RATES_PKG;

/
