--------------------------------------------------------
--  DDL for Package Body GMO_DOCUMENT_NUMBERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_DOCUMENT_NUMBERS_PVT" 
/* $Header: GMOVDNMB.pls 120.5 2006/01/19 09:23 swasubra noship $ */

AS


--This procedure is used to get the org name and transaction name for the specified
--org ID and transaction type.
PROCEDURE GET_ORG_TRANS_DETAILS
(P_ORGANIZATION_ID      IN         NUMBER,
 P_TRANSACTION_TYPE     IN         VARCHAR2,
 X_ORGANIZATION_NAME    OUT NOCOPY VARCHAR2,
 X_TRANSACTION_NAME     OUT NOCOPY VARCHAR2)

 IS

--This cursor is used to obtain the organization name for the specified organization ID.
--This cursor will be used only if no document number exists for the specified organization ID and transaction type.
CURSOR GET_ORG_NAME_C IS
  SELECT DISTINCT(OV.ORGANIZATION_CODE || ' ' || OV.ORGANIZATION_NAME)
  FROM   ORG_ACCESS_VIEW OV
  WHERE  OV.ORGANIZATION_ID = P_ORGANIZATION_ID;

--This cursor is used to obtain the transaction name for the specified transaction type code.
--This cursor will be used only if there exists no document numbers for the specified organization ID and transaction type.
CURSOR GET_TRANS_NAME_C IS
  SELECT LK.MEANING
  FROM   FND_LOOKUP_VALUES_VL LK
  WHERE  LK.LOOKUP_TYPE = 'GMO_TRANSACTION_TYPES'
  AND    LK.LOOKUP_CODE = P_TRANSACTION_TYPE;


BEGIN

  --Obtain the organization name only if organization ID exists.
  IF P_ORGANIZATION_ID IS NOT NULL THEN

    --Open the cursor that obtains the organization name.
    OPEN GET_ORG_NAME_C;

    --Fetch the organization name value.
    FETCH GET_ORG_NAME_C INTO X_ORGANIZATION_NAME;

    --If no row was found, then set the specified organization ID as tbe organization name.
    IF GET_ORG_NAME_C%NOTFOUND THEN
      X_ORGANIZATION_NAME := P_ORGANIZATION_ID;
    END IF;

    --CLose the cursor.
    CLOSE GET_ORG_NAME_C;

  ELSE

    --The organization ID is null.
    --Hence set organization name to null.
    X_ORGANIZATION_NAME := NULL;

  END IF;

  --Open the cursor that obtains the transaction name.
  OPEN GET_TRANS_NAME_C;

  --Fetch the transaction name value.
  FETCH GET_TRANS_NAME_C INTO X_TRANSACTION_NAME;

  --If no row was found, then set the specified transaction type code and the transaction name;
  IF GET_TRANS_NAME_C%NOTFOUND THEN
    X_TRANSACTION_NAME := P_TRANSACTION_TYPE;
  END IF;

  --Close the cursor;
  CLOSE GET_TRANS_NAME_C;

END GET_ORG_TRANS_DETAILS;


--This PROCEDURE is used to obtain the document number type associated with the
--specified organization ID and transaction type.
PROCEDURE GET_DOCUMENT_NUMBER_TYPE
(P_ORGANIZATION_ID      IN         NUMBER,
 P_TRANSACTION_TYPE     IN         VARCHAR2,
 P_INIT_MSG_LIST        IN         VARCHAR2,
 X_DOCUMENT_NUMBER_TYPE OUT NOCOPY VARCHAR2,
 X_RETURN_STATUS        OUT NOCOPY VARCHAR2,
 X_MSG_COUNT            OUT NOCOPY NUMBER,
 X_MSG_DATA             OUT NOCOPY VARCHAR2)

IS

--The API name.
L_API_NAME           CONSTANT VARCHAR2(30) := 'GET_DOCUMENT_NUMBER_TYPE';

--This variable would hold the value of the organization name returned if no document number exists for the specified
--organization ID and transaction type code.
L_INVALID_ORG_NAME   VARCHAR2(250);

--This variable would hold transaction name returned if no document number exists for the specified
--organization ID and transaction type code.
L_INVALID_TRANS_NAME VARCHAR2(100);

--This variable is used to add the return messages into the message queue.
L_MESG_TEXT          VARCHAR2(2000);

--This cursor obtains the document number type for the specified organization ID and transaction type.
CURSOR GET_DOC_NUM_TYPE_C IS
  SELECT DOC_TYPE
  FROM   GMO_DOCUMENT_NUMBERS
  WHERE  ORGANIZATION_ID  = P_ORGANIZATION_ID
  AND    TRANSACTION_TYPE = P_TRANSACTION_TYPE;

--This cursor obtains the document number type for the specified transaction type which is not bound to any organization.
CURSOR GET_DOC_NUM_TYPE_NO_ORG_C IS
  SELECT DOC_TYPE
  FROM   GMO_DOCUMENT_NUMBERS
  WHERE  ORGANIZATION_ID IS NULL
  AND    TRANSACTION_TYPE = P_TRANSACTION_TYPE;

--This exception will be raised if no document number exists for the specified organization ID and transaction type.
INVALID_PARAMS_ERROR EXCEPTION;

BEGIN


   --Initialize the message list if specified so.
  IF FND_API.TO_BOOLEAN( P_INIT_MSG_LIST ) THEN

    FND_MSG_PUB.INITIALIZE;

  END IF;

  --The cursor is chosen based on the availability of organization ID.
  IF P_ORGANIZATION_ID IS NOT NULL THEN

    --Open the cursor that obtains the document number type for a transaction type bound to a organization.
    OPEN GET_DOC_NUM_TYPE_C;

    --Fetch the document type value.
    FETCH GET_DOC_NUM_TYPE_C INTO X_DOCUMENT_NUMBER_TYPE;

    --If no row was found, then no document number exists for the specified organization ID and transaction type.
    IF GET_DOC_NUM_TYPE_C%NOTFOUND THEN

      --Obtain the organization and transaction names.
      GET_ORG_TRANS_DETAILS
      (P_ORGANIZATION_ID   => P_ORGANIZATION_ID,
       P_TRANSACTION_TYPE  => P_TRANSACTION_TYPE,
       X_ORGANIZATION_NAME => L_INVALID_ORG_NAME,
       X_TRANSACTION_NAME  => L_INVALID_TRANS_NAME);

      --Close the cursor used to obtain the document number type.
      CLOSE GET_DOC_NUM_TYPE_C;

      RAISE INVALID_PARAMS_ERROR;

    END IF;

    --Close the cursor.
    CLOSE GET_DOC_NUM_TYPE_C;

  ELSE

    --Open the cursor that obtains the document number type for a transaction type that is not bound to any organization.
    OPEN GET_DOC_NUM_TYPE_NO_ORG_C;

    --Fetch the document type value.
    FETCH GET_DOC_NUM_TYPE_NO_ORG_C INTO X_DOCUMENT_NUMBER_TYPE;
    --If no row was found, then no document number exists for the specified organization ID and transaction type.

    IF GET_DOC_NUM_TYPE_NO_ORG_C%NOTFOUND THEN

      --Obtain the transaction name.
      GET_ORG_TRANS_DETAILS
      (P_ORGANIZATION_ID   => P_ORGANIZATION_ID,
       P_TRANSACTION_TYPE  => P_TRANSACTION_TYPE,
       X_ORGANIZATION_NAME => L_INVALID_ORG_NAME,
       X_TRANSACTION_NAME  => L_INVALID_TRANS_NAME);

      --Close the cursor used to obtain the document number type.
      CLOSE GET_DOC_NUM_TYPE_NO_ORG_C;

      RAISE INVALID_PARAMS_ERROR;

    END IF;

    --Close the cursor.
    CLOSE GET_DOC_NUM_TYPE_NO_ORG_C;

  END IF;

  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

  --Get the message count.
  --If count is 1, then get the message data.
  FND_MSG_PUB.COUNT_AND_GET
  (P_COUNT => X_MSG_COUNT,
   P_DATA  => X_MSG_DATA);

EXCEPTION


  WHEN INVALID_PARAMS_ERROR THEN

    X_DOCUMENT_NUMBER_TYPE := NULL;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR ;

    IF L_INVALID_ORG_NAME IS NOT NULL THEN

      FND_MESSAGE.SET_NAME('GMO','GMO_DOC_NUM_PARAMS_ERR');
      FND_MESSAGE.SET_TOKEN('ORG',L_INVALID_ORG_NAME);
      FND_MESSAGE.SET_TOKEN('TRANS',L_INVALID_TRANS_NAME);

    ELSE

      FND_MESSAGE.SET_NAME('GMO','GMO_DOC_NUM_PARAMS_ERR1');
      FND_MESSAGE.SET_TOKEN('TRANS',L_INVALID_TRANS_NAME);

    END IF;

    FND_MSG_PUB.ADD;

    FND_MSG_PUB.COUNT_AND_GET
    (P_COUNT => X_MSG_COUNT,
     P_DATA  => X_MSG_DATA);

    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                      'gmo.plsql.GMO_DOCUMENT_NUMBERS_PVT.GET_DOCUMENT_NUMBER_TYPE',
                      FALSE);
    END IF;

  WHEN OTHERS THEN


    IF GET_DOC_NUM_TYPE_C%ISOPEN THEN

      --Close the cursor.
      CLOSE GET_DOC_NUM_TYPE_C;

    END IF;


    IF GET_DOC_NUM_TYPE_NO_ORG_C%ISOPEN THEN

      --Close the cursor.
      CLOSE GET_DOC_NUM_TYPE_NO_ORG_C;

    END IF;

    X_DOCUMENT_NUMBER_TYPE := NULL;
    X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;


    IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.ADD_EXC_MSG
      (G_PKG_NAME,
       L_API_NAME);
    END IF;

    FND_MSG_PUB.COUNT_AND_GET
    (P_COUNT => X_MSG_COUNT,
     P_DATA  => X_MSG_DATA);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'gmo.plsql.GMO_DOCUMENT_NUMBERS_PVT.GET_DOCUMENT_NUMBER_TYPE',
                      FALSE);
    END IF;

END GET_DOCUMENT_NUMBER_TYPE;


--This PROCEDURE is used to obtain the next document number in sequence associated with the
--specified organization ID and transaction type.
PROCEDURE GET_NEXT_VALUE
(P_ORGANIZATION_ID    IN  NUMBER,
 P_TRANSACTION_TYPE   IN  VARCHAR2,
 P_INIT_MSG_LIST      IN  VARCHAR2,
 X_VALUE              OUT NOCOPY VARCHAR2,
 X_RETURN_STATUS      OUT NOCOPY VARCHAR2,
 X_MSG_COUNT          OUT NOCOPY NUMBER,
 X_MSG_DATA           OUT NOCOPY VARCHAR2)

IS

--The API name.
L_API_NAME           CONSTANT VARCHAR2(30) := 'GET_NEXT_VALUE';

--This variable is used to add the return messages into the message queue.
L_MESG_TEXT          VARCHAR2(2000);

L_CURRENTVAL      NUMBER;

L_INCREMENT       NUMBER;

L_LENGTH          NUMBER;

L_DOC_TYPE        VARCHAR2(1);

L_ZERO_PAD_OPTION VARCHAR2(1);

L_PREFIX          VARCHAR2(10);

L_SUFFIX          VARCHAR2(10);

L_SEPARATOR       VARCHAR2(1);

L_START           NUMBER;

L_NEXTVAL         NUMBER;

L_NO_OF_DIGITS    NUMBER;

L_IDENTIFIER      NUMBER;

L_NO_OF_ZEROS     NUMBER;

L_INVALID_ORG_NAME   VARCHAR2(250);

L_INVALID_TRANS_NAME VARCHAR2(100);

--This exception if no document number exists for the specified organization ID and transaction type.
INVALID_PARAMS_ERROR EXCEPTION;

--This exception is raised if the document identified by the orgsanization ID and transaction type has reached its
--maximum allowed value.
MAX_VALUE_ERROR      EXCEPTION;

--This exception is raised if the type of the document number identified by the organization ID and transaction type is
--set to manual.
DOC_TYPE_ERROR       EXCEPTION;

--This cursor obtains the details of the document number associated with the organization ID and
--transaction type.
CURSOR GET_DOC_NUM_DETAILS_C IS
  SELECT DOC_TYPE,
         DOC_ZERO_PAD,
         DOC_START,
         DOC_CURRENTVAL,
         DOC_INCREMENT,
         DOC_LENGTH,
         DOC_PREFIX,
         DOC_SUFFIX,
         DOC_SEPARATOR
  FROM   GMO_DOCUMENT_NUMBERS
  WHERE  ORGANIZATION_ID  = P_ORGANIZATION_ID
  AND    TRANSACTION_TYPE = P_TRANSACTION_TYPE;

--This cursor obtains the details of the document number associated with the
--transaction type with no organization.
CURSOR GET_DOC_NUM_DETAILS_NO_ORG_C IS
  SELECT DOC_TYPE,
         DOC_ZERO_PAD,
         DOC_START,
         DOC_CURRENTVAL,
         DOC_INCREMENT,
         DOC_LENGTH,
         DOC_PREFIX,
         DOC_SUFFIX,
         DOC_SEPARATOR
  FROM   GMO_DOCUMENT_NUMBERS
  WHERE  ORGANIZATION_ID IS NULL
  AND    TRANSACTION_TYPE = P_TRANSACTION_TYPE;

  PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

  --Initialize the message list if specified so.
  IF FND_API.TO_BOOLEAN( P_INIT_MSG_LIST ) THEN

    FND_MSG_PUB.INITIALIZE;

  END IF;

  --Check if organization ID exists.
  IF P_ORGANIZATION_ID IS NOT NULL THEN

    --Open the cursor.
    OPEN GET_DOC_NUM_DETAILS_C;

    --Fetch the document details.
    FETCH GET_DOC_NUM_DETAILS_C
    INTO  L_DOC_TYPE,
          L_ZERO_PAD_OPTION,
          L_START,
          L_CURRENTVAL,
          L_INCREMENT,
          L_LENGTH,
          L_PREFIX,
          L_SUFFIX,
          L_SEPARATOR;


    IF GET_DOC_NUM_DETAILS_C%NOTFOUND THEN

      --Obtain the organization and transaction names.
      GET_ORG_TRANS_DETAILS
      (P_ORGANIZATION_ID   => P_ORGANIZATION_ID,
       P_TRANSACTION_TYPE  => P_TRANSACTION_TYPE,
       X_ORGANIZATION_NAME => L_INVALID_ORG_NAME,
       X_TRANSACTION_NAME  => L_INVALID_TRANS_NAME);

      --Close the cursor.
      CLOSE GET_DOC_NUM_DETAILS_C;

      --No document number was found. Hence raise an exception.
      RAISE INVALID_PARAMS_ERROR;

    END IF;

    --Close the cursor.
    CLOSE GET_DOC_NUM_DETAILS_C;

  ELSE

    --Open the cursor.
    OPEN GET_DOC_NUM_DETAILS_NO_ORG_C;

    --Fetch the document details.
    FETCH GET_DOC_NUM_DETAILS_NO_ORG_C
    INTO  L_DOC_TYPE,
          L_ZERO_PAD_OPTION,
          L_START,
          L_CURRENTVAL,
          L_INCREMENT,
          L_LENGTH,
          L_PREFIX,
          L_SUFFIX,
          L_SEPARATOR;


    IF GET_DOC_NUM_DETAILS_NO_ORG_C%NOTFOUND THEN

      --Obtain the organization and transaction names.
      GET_ORG_TRANS_DETAILS
      (P_ORGANIZATION_ID   => P_ORGANIZATION_ID,
       P_TRANSACTION_TYPE  => P_TRANSACTION_TYPE,
       X_ORGANIZATION_NAME => L_INVALID_ORG_NAME,
       X_TRANSACTION_NAME  => L_INVALID_TRANS_NAME);

      --Close the cursor.
      CLOSE GET_DOC_NUM_DETAILS_NO_ORG_C;

      --No document number was found. Hence raise an exception.
      RAISE INVALID_PARAMS_ERROR;

    END IF;

    --Close the cursor.
    CLOSE GET_DOC_NUM_DETAILS_NO_ORG_C;

  END IF;


  IF L_DOC_TYPE = GMO_DOCUMENT_NUMBERS_GRP.G_DOC_TYPE_MANUAL THEN

    --The document type is set to Manual.

    --Obtain the organization and transaction names.
    GET_ORG_TRANS_DETAILS
    (P_ORGANIZATION_ID   => P_ORGANIZATION_ID,
     P_TRANSACTION_TYPE  => P_TRANSACTION_TYPE,
     X_ORGANIZATION_NAME => L_INVALID_ORG_NAME,
     X_TRANSACTION_NAME  => L_INVALID_TRANS_NAME);

    --Hence raise an exception.
    RAISE DOC_TYPE_ERROR;

  ELSE

    --Set the value to an empty field.
    X_VALUE := '';

    --If the prefix exists then append the same to the next value
    IF LENGTH(L_PREFIX) > 0 THEN
      X_VALUE := X_VALUE || L_PREFIX;

      --If the separator exists then append the same to the next value.
      IF LENGTH(L_SEPARATOR) > 0 THEN
        X_VALUE := X_VALUE || L_SEPARATOR;
      END IF;

    END IF;


    --If the current val is -1 then the sequence has not started.
    IF L_CURRENTVAL = -1 THEN

      --The sequencing has not started for this document number.
      --Set the next val sequence to the start value.
      L_NEXTVAL := L_START;

    ELSE

      --The sequencing has started for this document number.
      --Set the next val sequence by incrementing the current val appropriately.
      L_NEXTVAL := L_CURRENTVAL + L_INCREMENT;

    END IF;

    --Count the number of digits used in the next val sequence if length value is greater than zero.
    IF L_LENGTH > 0 THEN
      L_NO_OF_DIGITS := 0;

      L_IDENTIFIER := L_NEXTVAL;

      WHILE L_IDENTIFIER >= 1 LOOP
        L_NO_OF_DIGITS := L_NO_OF_DIGITS + 1;
        L_IDENTIFIER := L_IDENTIFIER / 10;
      END LOOP;

      IF L_NO_OF_DIGITS > L_LENGTH THEN

        --Obtain the organization and transaction names.
        GET_ORG_TRANS_DETAILS
        (P_ORGANIZATION_ID   => P_ORGANIZATION_ID,
         P_TRANSACTION_TYPE  => P_TRANSACTION_TYPE,
         X_ORGANIZATION_NAME => L_INVALID_ORG_NAME,
         X_TRANSACTION_NAME  => L_INVALID_TRANS_NAME);

        --The document number has reached its maximum value. Hence raise an exception.
        RAISE MAX_VALUE_ERROR;

      ELSE

        --If the zero pad is used then set the zero padding appropriately.
        IF L_ZERO_PAD_OPTION = GMO_DOCUMENT_NUMBERS_GRP.G_ZERO_PAD_YES THEN

          L_NO_OF_ZEROS := L_LENGTH - L_NO_OF_DIGITS;

          FOR i IN 1..L_NO_OF_ZEROS LOOP

            X_VALUE := X_VALUE || '0';

          END LOOP;
        END IF;
      END IF;
    END IF;

    --Append the computed next val sequence to the next value variable.
    X_VALUE := X_VALUE || L_NEXTVAL;

    --Append the suffix if it exists.
    IF LENGTH(L_SUFFIX) > 0 THEN

      --Append the separator if it exists.
      IF LENGTH(L_SEPARATOR) > 0 THEN
        X_VALUE := X_VALUE || L_SEPARATOR;
      END IF;

      X_VALUE := X_VALUE || L_SUFFIX;

    END IF;

    --Update the table with the newly computed next val sequence.
    IF P_ORGANIZATION_ID IS NOT NULL THEN

      UPDATE GMO_DOCUMENT_NUMBERS
      SET    DOC_CURRENTVAL    = L_NEXTVAL,
             LAST_UPDATE_DATE  = SYSDATE,
             LAST_UPDATED_BY   = FND_GLOBAL.USER_ID,
             LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
      WHERE  ORGANIZATION_ID  = P_ORGANIZATION_ID
      AND    TRANSACTION_TYPE = P_TRANSACTION_TYPE;

    ELSE

      UPDATE GMO_DOCUMENT_NUMBERS
      SET    DOC_CURRENTVAL    = L_NEXTVAL,
             LAST_UPDATE_DATE  = SYSDATE,
             LAST_UPDATED_BY   = FND_GLOBAL.USER_ID,
             LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
      WHERE  ORGANIZATION_ID  IS NULL
      AND    TRANSACTION_TYPE = P_TRANSACTION_TYPE;

    END IF;

    --Commit the transaction.
    COMMIT;

    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

  END IF;


EXCEPTION

  WHEN INVALID_PARAMS_ERROR THEN
    ROLLBACK;
    X_VALUE := NULL;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

    IF L_INVALID_ORG_NAME IS NOT NULL THEN

      FND_MESSAGE.SET_NAME('GMO','GMO_DOC_NUM_PARAMS_ERR');
      FND_MESSAGE.SET_TOKEN('ORG',L_INVALID_ORG_NAME);
      FND_MESSAGE.SET_TOKEN('TRANS',L_INVALID_TRANS_NAME);

    ELSE

      FND_MESSAGE.SET_NAME('GMO','GMO_DOC_NUM_PARAMS_ERR1');
      FND_MESSAGE.SET_TOKEN('TRANS',L_INVALID_TRANS_NAME);

    END IF;

    FND_MSG_PUB.ADD;

    FND_MSG_PUB.COUNT_AND_GET
    (P_COUNT => X_MSG_COUNT,
     P_DATA  => X_MSG_DATA);

    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                      'gmo.plsql.GMO_DOCUMENT_NUMBERS_PVT.GET_NEXT_VALUE',
                      FALSE);
    END IF;

  WHEN DOC_TYPE_ERROR THEN

    ROLLBACK;

    X_VALUE := NULL;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

    IF L_INVALID_ORG_NAME IS NOT NULL THEN

      FND_MESSAGE.SET_NAME('GMO','GMO_DOC_NUM_DOC_TYPE_ERR');
      FND_MESSAGE.SET_TOKEN('ORG',L_INVALID_ORG_NAME);
      FND_MESSAGE.SET_TOKEN('TRANS',L_INVALID_TRANS_NAME);

    ELSE

      FND_MESSAGE.SET_NAME('GMO','GMO_DOC_NUM_DOC_TYPE_ERR1');
      FND_MESSAGE.SET_TOKEN('TRANS',L_INVALID_TRANS_NAME);

    END IF;


    FND_MSG_PUB.ADD;

    FND_MSG_PUB.COUNT_AND_GET
    (P_COUNT => X_MSG_COUNT,
     P_DATA  => X_MSG_DATA);

    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                      'gmo.plsql.GMO_DOCUMENT_NUMBERS_PVT.GET_NEXT_VALUE',
                      FALSE);
    END IF;

  WHEN MAX_VALUE_ERROR THEN

    ROLLBACK;
    X_VALUE := NULL;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

    IF L_INVALID_ORG_NAME IS NOT NULL THEN

      FND_MESSAGE.SET_NAME('GMO','GMO_DOC_NUM_MAX_VALUE_ERR');
      FND_MESSAGE.SET_TOKEN('ORG',L_INVALID_ORG_NAME);
      FND_MESSAGE.SET_TOKEN('TRANS',L_INVALID_TRANS_NAME);

    ELSE

      FND_MESSAGE.SET_NAME('GMO','GMO_DOC_NUM_MAX_VALUE_ERR1');
      FND_MESSAGE.SET_TOKEN('TRANS',L_INVALID_TRANS_NAME);

    END IF;

    FND_MSG_PUB.ADD;

    FND_MSG_PUB.COUNT_AND_GET
    (P_COUNT => X_MSG_COUNT,
     P_DATA  => X_MSG_DATA);

    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                      'gmo.plsql.GMO_DOCUMENT_NUMBERS_PVT.GET_NEXT_VALUE',
                      FALSE);
    END IF;

  WHEN OTHERS THEN
    ROLLBACK;

    X_VALUE := NULL;
    X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF GET_DOC_NUM_DETAILS_C%ISOPEN THEN

      --Close the cursor.
      CLOSE GET_DOC_NUM_DETAILS_C;

    END IF;


    IF GET_DOC_NUM_DETAILS_NO_ORG_C%ISOPEN THEN

      --Close the cursor.
      CLOSE GET_DOC_NUM_DETAILS_NO_ORG_C;

    END IF;


    IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.ADD_EXC_MSG
      (G_PKG_NAME,
       L_API_NAME);
    END IF;

    FND_MSG_PUB.COUNT_AND_GET
    (P_COUNT => X_MSG_COUNT,
     P_DATA  => X_MSG_DATA);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'gmo.plsql.GMO_DOCUMENT_NUMBERS_PVT.GET_NEXT_VALUE',
                      FALSE);
    END IF;

END GET_NEXT_VALUE;

--This procedure is used to check if a document number entry exists for the specified
--organization and transaction type.
PROCEDURE DOES_DOCUMENT_NUMBER_EXIST
(P_ORGANIZATION_ID        IN         NUMBER,
 P_TRANSACTION_TYPE       IN         VARCHAR2,
 P_INIT_MSG_LIST          IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
 X_DOCUMENT_NUMBER_EXISTS OUT NOCOPY VARCHAR2,
 X_RETURN_STATUS          OUT NOCOPY VARCHAR2,
 X_MSG_COUNT              OUT NOCOPY NUMBER,
 X_MSG_DATA               OUT NOCOPY VARCHAR2)

IS

--This is a sandbox variable to store a count of the document numbers that exist
--for the specified organization ID and transaction type.
--Its value must be either 0 or 1.
L_COUNT NUMBER;

--The API name.
L_API_NAME           CONSTANT VARCHAR2(30) := 'DOES_DOCUMENT_NUMBER_EXIST';

BEGIN


  --Obtain a count of the document numbers that exist based on the specified
  --organization ID and transaction type.
  IF P_ORGANIZATION_ID IS NULL THEN

    SELECT COUNT(*) INTO L_COUNT
    FROM   GMO_DOCUMENT_NUMBERS
    WHERE  ORGANIZATION_ID IS NULL
    AND    TRANSACTION_TYPE = P_TRANSACTION_TYPE;

  ELSE

    SELECT COUNT(*) INTO L_COUNT
    FROM   GMO_DOCUMENT_NUMBERS
    WHERE  ORGANIZATION_ID = P_ORGANIZATION_ID
    AND    TRANSACTION_TYPE = P_TRANSACTION_TYPE;

  END IF;

  --Return the status value based on the count parameter.
  IF L_COUNT > 0 THEN
    X_DOCUMENT_NUMBER_EXISTS := FND_API.G_TRUE;
  ELSE
    X_DOCUMENT_NUMBER_EXISTS := FND_API.G_FALSE;
  END IF;

  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION

  WHEN OTHERS THEN

    X_DOCUMENT_NUMBER_EXISTS := FND_API.G_FALSE;

    X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.ADD_EXC_MSG
      (G_PKG_NAME,
       L_API_NAME);
    END IF;

    FND_MSG_PUB.COUNT_AND_GET
    (P_COUNT => X_MSG_COUNT,
     P_DATA  => X_MSG_DATA);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'gmo.plsql.GMO_DOCUMENT_NUMBERS_PVT.DOES_DOCUMENT_NUMBER_EXIST',
                      FALSE);
    END IF;

END DOES_DOCUMENT_NUMBER_EXIST;

END GMO_DOCUMENT_NUMBERS_PVT;

/
