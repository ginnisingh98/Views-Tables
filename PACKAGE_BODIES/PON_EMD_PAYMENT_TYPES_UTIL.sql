--------------------------------------------------------
--  DDL for Package Body PON_EMD_PAYMENT_TYPES_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_EMD_PAYMENT_TYPES_UTIL" AS
/* $Header: ponemdutilb.pls 120.0.12010000.3 2010/03/17 09:40:37 puppulur noship $ */

PROCEDURE Insert_Row(
                      X_PAYMENT_TYPE_CODE      IN VARCHAR2,
                      X_ORG_ID                 IN NUMBER,
                      X_NAME                   IN VARCHAR2,
                      X_DESCRIPTION            IN VARCHAR2,
                      X_START_DATE_ACTIVE      IN DATE,
                      X_END_DATE_ACTIVE        IN DATE,
                      X_ENABLED_FLAG           IN VARCHAR2,
                      X_RECEIPT_METHOD_ID      IN NUMBER,
                      X_REFUND_PAYMENT_METHOD  IN VARCHAR2,
                      X_CREATION_DATE          IN VARCHAR2,
                      X_CREATED_BY             IN NUMBER,
                      X_LAST_UPDATE_DATE       IN DATE,
                      X_LAST_UPDATED_BY        IN NUMBER,
                      X_LAST_UPDATE_LOGIN      IN NUMBER,
                      X_REQUEST_ID             IN NUMBER,
                      X_PROGRAM_APPLICATION_ID IN NUMBER,
                      X_PROGRAM_ID			       IN NUMBER,
                      X_PROGRAM_UPDATE_DATE		 IN DATE
                      ) IS
  --  CURSOR C IS SELECT rowid FROM oe_system_parameters_all
                 /** WHERE nvl(org_id, -99) = nvl(X_Organization_Id, -99); **/
                -- NVL of -99 is removed as per SSA
                -- WHERE org_id = X_Organization_Id;
   --              WHERE nvl(org_id, -99) = nvl(X_Organization_Id, -99);

L_LANGUAGE		VARCHAR2(4);
L_SOURCE_LANG		VARCHAR2(4);
L_ORG_ID NUMBER := 0;

BEGIN

L_ORG_ID := X_ORG_ID;


 INSERT INTO PON_EMD_PAYMENT_TYPES_ALL
  (
  PAYMENT_TYPE_CODE     ,
  ORG_ID                ,
  START_DATE_ACTIVE     ,
  END_DATE_ACTIVE       ,
  ENABLED_FLAG          ,
  RECEIPT_METHOD_ID     ,
  REFUND_PAYMENT_METHOD ,
  CREATION_DATE         ,
  CREATED_BY            ,
  LAST_UPDATE_DATE      ,
  LAST_UPDATED_BY       ,
  LAST_UPDATE_LOGIN     ,
  REQUEST_ID            ,
  PROGRAM_APPLICATION_ID,
  PROGRAM_ID			      ,
  PROGRAM_UPDATE_DATE
  )
  VALUES
  (
  X_PAYMENT_TYPE_CODE     ,
  X_ORG_ID                ,
  X_START_DATE_ACTIVE     ,
  X_END_DATE_ACTIVE       ,
  X_ENABLED_FLAG          ,
  X_RECEIPT_METHOD_ID     ,
  X_REFUND_PAYMENT_METHOD ,
  X_CREATION_DATE         ,
  X_CREATED_BY            ,
  X_LAST_UPDATE_DATE      ,
  X_LAST_UPDATED_BY       ,
  X_LAST_UPDATE_LOGIN     ,
  X_REQUEST_ID            ,
  X_PROGRAM_APPLICATION_ID,
  X_PROGRAM_ID			      ,
  X_PROGRAM_UPDATE_DATE
  );

INSERT INTO PON_EMD_PAYMENT_TYPES_TL
  (
  PAYMENT_TYPE_CODE     ,
  ORG_ID                ,
  NAME                  ,
  DESCRIPTION           ,
  CREATION_DATE         ,
  CREATED_BY            ,
  LAST_UPDATE_DATE      ,
  LAST_UPDATED_BY       ,
  LAST_UPDATE_LOGIN     ,
  REQUEST_ID            ,
  PROGRAM_APPLICATION_ID,
  PROGRAM_ID			      ,
  PROGRAM_UPDATE_DATE		,
  LANGUAGE              ,
  SOURCE_LANG
  )
 SELECT
        X_PAYMENT_TYPE_CODE,
        X_ORG_ID,
        X_NAME,
        X_DESCRIPTION,
        X_CREATION_DATE,
        X_CREATED_BY,
        X_LAST_UPDATE_DATE,
        X_LAST_UPDATED_BY,
        X_LAST_UPDATE_LOGIN,
        X_PROGRAM_APPLICATION_ID,
        X_PROGRAM_ID,
        X_REQUEST_ID,
        X_PROGRAM_UPDATE_DATE,
        L.LANGUAGE_CODE,
        USERENV('LANG')
 FROM FND_LANGUAGES L
 WHERE
 L.INSTALLED_FLAG IN ('I', 'B')
 AND NOT EXISTS
   (
    SELECT 1
    FROM
    PON_EMD_PAYMENT_TYPES_TL T
    WHERE
    T.PAYMENT_TYPE_CODE = X_PAYMENT_TYPE_CODE
    AND
    T.LANGUAGE = L.LANGUAGE_CODE
    AND
    ORG_ID=L_ORG_ID
   );

END Insert_Row;


PROCEDURE  Update_Row(
                      X_PAYMENT_TYPE_CODE      IN VARCHAR2,
                      X_ORG_ID                 IN NUMBER,
                      X_NAME                   IN VARCHAR2,
                      X_DESCRIPTION            IN VARCHAR2,
                      X_START_DATE_ACTIVE      IN DATE,
                      X_END_DATE_ACTIVE        IN DATE,
                      X_ENABLED_FLAG           IN VARCHAR2,
                      X_RECEIPT_METHOD_ID      IN NUMBER,
                      X_REFUND_PAYMENT_METHOD  IN VARCHAR2,
                      X_LAST_UPDATE_DATE       IN DATE,
                      X_LAST_UPDATED_BY        IN NUMBER,
                      X_LAST_UPDATE_LOGIN      IN NUMBER,
                      X_REQUEST_ID             IN NUMBER,
                      X_PROGRAM_APPLICATION_ID IN NUMBER,
                      X_PROGRAM_ID			       IN NUMBER,
                      X_PROGRAM_UPDATE_DATE		 IN DATE
                      ) IS
BEGIN


    UPDATE PON_EMD_PAYMENT_TYPES_TL
    SET
       NAME                     = X_NAME,
       DESCRIPTION		= X_DESCRIPTION,
       REFUND_PAYMENT_METHOD    = X_REFUND_PAYMENT_METHOD,
       LAST_UPDATE_DATE         = X_LAST_UPDATE_DATE,
       LAST_UPDATED_BY          = X_LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN        = X_LAST_UPDATE_LOGIN,
       SOURCE_LANG              = USERENV('LANG')
    WHERE
    NVL(ORG_ID,-1) = NVL(X_ORG_ID, -1)
    AND
    PAYMENT_TYPE_CODE = X_PAYMENT_TYPE_CODE
    AND
    USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

    UPDATE PON_EMD_PAYMENT_TYPES_ALL
    SET
      PAYMENT_TYPE_CODE	      = X_PAYMENT_TYPE_CODE,
      START_DATE_ACTIVE       = X_START_DATE_ACTIVE,
      END_DATE_ACTIVE         = X_END_DATE_ACTIVE,
      ENABLED_FLAG            = X_ENABLED_FLAG,
      RECEIPT_METHOD_ID       = X_RECEIPT_METHOD_ID,
      REFUND_PAYMENT_METHOD   = X_REFUND_PAYMENT_METHOD,
      LAST_UPDATE_DATE        = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY         = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN       = X_LAST_UPDATE_LOGIN,
      REQUEST_ID              = X_REQUEST_ID,
      PROGRAM_ID              = X_PROGRAM_ID,
      PROGRAM_APPLICATION_ID  = X_PROGRAM_APPLICATION_ID,
      PROGRAM_UPDATE_DATE     = X_PROGRAM_UPDATE_DATE
    WHERE
    NVL(ORG_ID,-1) = NVL(X_ORG_ID, -1)
    AND
    PAYMENT_TYPE_CODE = X_PAYMENT_TYPE_CODE;

    IF (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    END IF;
END Update_Row;


PROCEDURE Translate_Row(
                        X_PAYMENT_TYPE_CODE IN VARCHAR2,
                        X_ORG_ID            IN NUMBER,
                        X_NAME              IN VARCHAR2,
                        X_DESCRIPTION       IN VARCHAR2,
                        X_OWNER             IN VARCHAR2
                       ) IS
   L_USER_ID NUMBER :=0;
BEGIN
   L_USER_ID :=FND_LOAD_UTIL.OWNER_ID(X_OWNER); --SEED DATA VERSION CHANGES

   UPDATE PON_EMD_PAYMENT_TYPES_TL
    SET
       ORG_ID                   = X_ORG_ID,
       PAYMENT_TYPE_CODE	      = X_PAYMENT_TYPE_CODE,
       NAME                     = X_NAME,
       DESCRIPTION		          = X_DESCRIPTION,
       LAST_UPDATE_DATE         = SYSDATE,
       LAST_UPDATED_BY          = L_USER_ID,
       LAST_UPDATE_LOGIN        = L_USER_ID,
       SOURCE_LANG              = USERENV('LANG')
    WHERE
    NVL(ORG_ID,-1) = NVL(X_ORG_ID, -1)
    AND
    PAYMENT_TYPE_CODE	= X_PAYMENT_TYPE_CODE
    AND
    USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

END Translate_Row;


PROCEDURE LOAD_ROW(
                    X_PAYMENT_TYPE_CODE      IN VARCHAR2,
                    X_ORG_ID                 IN NUMBER,
                    X_OWNER                  IN VARCHAR2,
                    X_NAME                   IN VARCHAR2,
                    X_DESCRIPTION            IN VARCHAR2,
                    X_START_DATE_ACTIVE      IN DATE,
                    X_END_DATE_ACTIVE        IN DATE,
                    X_ENABLED_FLAG           IN VARCHAR2,
                    X_RECEIPT_METHOD_ID      IN NUMBER,
                    X_REFUND_PAYMENT_METHOD  IN VARCHAR2,
                    X_LAST_UPDATE_DATE       IN DATE,
                    X_LAST_UPDATED_BY        IN NUMBER,
                    X_LAST_UPDATE_LOGIN      IN NUMBER,
                    X_REQUEST_ID             IN NUMBER,
                    X_PROGRAM_APPLICATION_ID IN NUMBER,
                    X_PROGRAM_ID	           IN NUMBER,
                    X_PROGRAM_UPDATE_DATE    IN DATE
                    ) IS

L_USER_ID             NUMBER        := 0;
L_ORG_ID              NUMBER        := 0;
L_TRANSACTION_TYPE_ID NUMBER        := 0;
L_ROWID               VARCHAR2(240) := NULL;
L_DB_USER_ID          NUMBER        := 0;
L_VALID_RELEASE       BOOLEAN       :=FALSE;

BEGIN

   L_USER_ID :=FND_LOAD_UTIL.OWNER_ID(X_OWNER);

     SELECT ORG_ID,LAST_UPDATED_BY INTO L_ORG_ID,L_DB_USER_ID
     FROM
     PON_EMD_PAYMENT_TYPES_ALL
     WHERE
     PAYMENT_TYPE_CODE=X_PAYMENT_TYPE_CODE
     AND
     Nvl(ORG_ID,-1)=Nvl(X_ORG_ID,-1)
     AND
     ROWNUM=1;

     --seed data version start
     IF (L_DB_USER_ID <= L_USER_ID)
           OR (L_DB_USER_ID IN (0,1,2)
              AND L_USER_ID IN (0,1,2))
     THEN
	   L_VALID_RELEASE :=TRUE ;
     END IF;
     IF L_VALID_RELEASE THEN
     --seed data version end
            Update_Row(
                      X_PAYMENT_TYPE_CODE      => X_PAYMENT_TYPE_CODE,
                      X_ORG_ID                 => X_ORG_ID,
                      X_NAME                   => X_NAME,
                      X_DESCRIPTION            => X_DESCRIPTION,
                      X_START_DATE_ACTIVE      => X_START_DATE_ACTIVE,
                      X_END_DATE_ACTIVE        => X_END_DATE_ACTIVE,
                      X_ENABLED_FLAG           => X_ENABLED_FLAG,
                      X_RECEIPT_METHOD_ID      => X_RECEIPT_METHOD_ID,
                      X_REFUND_PAYMENT_METHOD  => X_REFUND_PAYMENT_METHOD,
                      X_LAST_UPDATE_DATE       => X_LAST_UPDATE_DATE,
                      X_LAST_UPDATED_BY        => X_LAST_UPDATED_BY,
                      X_LAST_UPDATE_LOGIN      => X_LAST_UPDATE_LOGIN,
                      X_REQUEST_ID             => X_REQUEST_ID,
                      X_PROGRAM_APPLICATION_ID => X_PROGRAM_APPLICATION_ID,
                      X_PROGRAM_ID	       => X_PROGRAM_ID,
                      X_PROGRAM_UPDATE_DATE    => X_PROGRAM_UPDATE_DATE
                      );
       end if;
      exception

         when no_data_found then

           Begin

              Insert_Row(
                      X_PAYMENT_TYPE_CODE      => X_PAYMENT_TYPE_CODE,
                      X_ORG_ID                 => X_ORG_ID,
                      X_NAME                   => X_NAME,
                      X_DESCRIPTION            => X_DESCRIPTION,
                      X_START_DATE_ACTIVE      => X_START_DATE_ACTIVE,
                      X_END_DATE_ACTIVE        => X_END_DATE_ACTIVE,
                      X_ENABLED_FLAG           => X_ENABLED_FLAG,
                      X_RECEIPT_METHOD_ID      => X_RECEIPT_METHOD_ID,
                      X_REFUND_PAYMENT_METHOD  => X_REFUND_PAYMENT_METHOD,
                      X_CREATION_DATE          => SYSDATE,
                      X_CREATED_BY             => l_user_id,
                      X_LAST_UPDATE_DATE       => X_LAST_UPDATE_DATE,
                      X_LAST_UPDATED_BY        => X_LAST_UPDATED_BY,
                      X_LAST_UPDATE_LOGIN      => X_LAST_UPDATE_LOGIN,
                      X_REQUEST_ID             => X_REQUEST_ID,
                      X_PROGRAM_APPLICATION_ID => X_PROGRAM_APPLICATION_ID,
                      X_PROGRAM_ID	       => X_PROGRAM_ID,
                      X_PROGRAM_UPDATE_DATE    => X_PROGRAM_UPDATE_DATE
                      );
             Exception

                 when others then
                      raise;

             END;


END LOAD_ROW;

PROCEDURE add_language IS

BEGIN

INSERT INTO PON_EMD_PAYMENT_TYPES_TL
  (
  PAYMENT_TYPE_CODE     ,
  ORG_ID                ,
  NAME                  ,
  DESCRIPTION           ,
  CREATION_DATE         ,
  CREATED_BY            ,
  LAST_UPDATE_DATE      ,
  LAST_UPDATED_BY       ,
  LAST_UPDATE_LOGIN     ,
  REQUEST_ID            ,
  PROGRAM_APPLICATION_ID,
  PROGRAM_ID			      ,
  PROGRAM_UPDATE_DATE		,
  LANGUAGE              ,
  SOURCE_LANG
  )
 SELECT
        EMDTL1.PAYMENT_TYPE_CODE,
        EMDTL1.ORG_ID,
        EMDTL1.NAME,
        EMDTL1.DESCRIPTION,
        EMDTL1.CREATION_DATE,
        EMDTL1.CREATED_BY,
        EMDTL1.LAST_UPDATE_DATE,
        EMDTL1.LAST_UPDATED_BY,
        EMDTL1.LAST_UPDATE_LOGIN,
        EMDTL1.PROGRAM_APPLICATION_ID,
        EMDTL1.PROGRAM_ID,
        EMDTL1.REQUEST_ID,
        EMDTL1.PROGRAM_UPDATE_DATE,
        LANG.LANGUAGE_CODE,
        EMDTL1.SOURCE_LANG
 FROM PON_EMD_PAYMENT_TYPES_TL EMDTL1,
      FND_LANGUAGES LANG
 WHERE
 EMDTL1.LANGUAGE=UserEnv('LANG')
 AND
 LANG.INSTALLED_FLAG IN ('I', 'B')
 AND NOT EXISTS  (SELECT NULL FROM PON_EMD_PAYMENT_TYPES_TL EMDTL2
                  WHERE
                  EMDTL2.ORG_ID=EMDTL1.ORG_ID
                  AND
                  EMDTL2.PAYMENT_TYPE_CODE=EMDTL1.PAYMENT_TYPE_CODE
                  AND
                  EMDTL2.LANGUAGE=LANG.LANGUAGE_CODE
                  );

END;

END PON_EMD_PAYMENT_TYPES_UTIL;

/
