--------------------------------------------------------
--  DDL for Package Body GMO_DISPENSE_SETUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_DISPENSE_SETUP_PVT" 
-- $Header: GMOVDSSB.pls 120.3 2006/02/01 14:45:31 swasubra noship $
AS


--This function is used to obtain the display name of the item
--identified by the item ID.
FUNCTION GET_ITEM_DISPLAY_NAME(P_ITEM_ID NUMBER)
RETURN VARCHAR2

IS

--This cursor would fetch the item display name for the specified
--item ID.
CURSOR GET_ITEM_DISPLAY_NAME_CUR IS
  SELECT
    CONCATENATED_SEGMENTS
  FROM
    MTL_SYSTEM_ITEMS_VL
  WHERE
    INVENTORY_ITEM_ID = P_ITEM_ID;

--This variable would hold the item display name.
L_DISPLAY_NAME VARCHAR2(240);

BEGIN

  --Open the cursor.
  OPEN GET_ITEM_DISPLAY_NAME_CUR;

  --Fetch the item display name into the local variable.
  FETCH GET_ITEM_DISPLAY_NAME_CUR INTO L_DISPLAY_NAME;

  --Close the cursor.
  CLOSE GET_ITEM_DISPLAY_NAME_CUR;

  --Return the item display name.
  RETURN L_DISPLAY_NAME;

  EXCEPTION
    WHEN OTHERS THEN

      IF GET_ITEM_DISPLAY_NAME_CUR%ISOPEN THEN
        CLOSE GET_ITEM_DISPLAY_NAME_CUR;
      END IF;
      FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
      FND_MESSAGE.SET_TOKEN('PKG_NAME','GMO_DISPENSE_SETUP_PVT');
      FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','GET_ITEM_DISPLAY_NAME');
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                        'edr.plsql.GMO_DISPENSE_SETUP_PVT.GET_ITEM_DISPLAY_NAME',
                        FALSE
                       );
      END IF;
    --Diagnostics End

      APP_EXCEPTION.RAISE_EXCEPTION;

END GET_ITEM_DISPLAY_NAME;


--This function is used to obtain the description of the item
--identified by the item ID.
FUNCTION GET_ITEM_DESCRIPTION(P_ITEM_ID NUMBER)
RETURN VARCHAR2

IS

--This cursor would fetch the description for the specified
--item ID.
CURSOR GET_ITEM_DESCRIPTION_CUR IS
  SELECT
    DESCRIPTION
  FROM
    MTL_SYSTEM_ITEMS_VL
  WHERE
    INVENTORY_ITEM_ID = P_ITEM_ID;

--This variable would hold the item description.
L_DESCRIPTION VARCHAR2(240);

BEGIN

  --Open the cursor.
  OPEN GET_ITEM_DESCRIPTION_CUR;

  --Fetch the item description into the local variable.
  FETCH GET_ITEM_DESCRIPTION_CUR INTO L_DESCRIPTION;

  CLOSE GET_ITEM_DESCRIPTION_CUR;

  --Return the item description.
  RETURN L_DESCRIPTION;

  EXCEPTION
    WHEN OTHERS THEN

      IF GET_ITEM_DESCRIPTION_CUR%ISOPEN THEN
        CLOSE GET_ITEM_DESCRIPTION_CUR;
      END IF;
      FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
      FND_MESSAGE.SET_TOKEN('PKG_NAME','GMO_DISPENSE_SETUP_PVT');
      FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','GET_ITEM_DESCRIPTION');

      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                        'edr.plsql.GMO_DISPENSE_SETUP_PVT.GET_ITEM_DESCRIPTION',
                        FALSE
                       );
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

END GET_ITEM_DESCRIPTION;


--This procedure is used to create a definition context in Process Instructions
--for the specified entity name, entity key and instruction types. It would return
--a instruction process ID through its OUT parameter.
PROCEDURE CREATE_DEFN_CONTEXT
(
    P_ENTITY_NAME                IN VARCHAR2,
    P_ENTITY_KEY                 IN VARCHAR2,
    P_ENTITY_DISPLAYNAME         IN VARCHAR2,
    P_INSTRUCTION_TYPE           IN FND_TABLE_OF_VARCHAR2_255,
    P_MODE                       IN VARCHAR2,
    P_CONTEXT_PARAMETER_NAMES    IN FND_TABLE_OF_VARCHAR2_255,
    P_CONTEXT_PARAMETER_VALUES   IN FND_TABLE_OF_VARCHAR2_255,
    P_CURR_INSTRUCTION_PROCESS_ID IN  NUMBER DEFAULT NULL,
    X_INSTRUCTION_PROCESS_ID     OUT NOCOPY NUMBER
)

IS


L_ENTITY_NAME        FND_TABLE_OF_VARCHAR2_255;

L_ENTITY_KEY         FND_TABLE_OF_VARCHAR2_255;

L_ENTITY_DISPLAYNAME FND_TABLE_OF_VARCHAR2_255;


L_RETURN_STATUS VARCHAR2(10);
L_MSG_COUNT     NUMBER;
L_MSG_DATA      VARCHAR2(4000);


L_CONTEXT_PARAMETERS GMO_DATATYPES_GRP.GMO_DEFINITION_PARAM_TBL_TYPE;

i NUMBER;

CREATE_ERROR EXCEPTION;

BEGIN

  --Initialize the the entity names array containing only one element.
  L_ENTITY_NAME        := FND_TABLE_OF_VARCHAR2_255();
  L_ENTITY_NAME.EXTEND;

  --Initialize the the entity keys array containing only one element.
  L_ENTITY_KEY         := FND_TABLE_OF_VARCHAR2_255();
  L_ENTITY_KEY.EXTEND;

  --Initialize the the entity display name array containing only one element.
  L_ENTITY_DISPLAYNAME := FND_TABLE_OF_VARCHAR2_255();
  L_ENTITY_DISPLAYNAME.EXTEND;

  --Set the entity name, key and display name values.
  L_ENTITY_NAME(1)        := P_ENTITY_NAME;
  L_ENTITY_KEY(1)         := P_ENTITY_KEY;
  L_ENTITY_DISPLAYNAME(1) := P_ENTITY_DISPLAYNAME;

  --Set the context parameter values.
  FOR i IN 1..P_CONTEXT_PARAMETER_NAMES.COUNT LOOP

    L_CONTEXT_PARAMETERS(i).name := P_CONTEXT_PARAMETER_NAMES(i);
    L_CONTEXT_PARAMETERS(i).value := P_CONTEXT_PARAMETER_VALUES(i);

  END LOOP;

  --Call the API to create a definition context.
  GMO_INSTRUCTION_GRP.CREATE_DEFN_CONTEXT
  (
    P_API_VERSION            => 1.0,
    P_INIT_MSG_LIST          => FND_API.G_FALSE,
    P_VALIDATION_LEVEL       => FND_API.G_VALID_LEVEL_NONE,
    P_ENTITY_NAME            => L_ENTITY_NAME,
    P_ENTITY_KEY             => L_ENTITY_KEY,
    P_ENTITY_DISPLAYNAME     => L_ENTITY_DISPLAYNAME,
    P_INSTRUCTION_TYPE       => P_INSTRUCTION_TYPE,
    P_MODE                   => P_MODE,
    P_CONTEXT_PARAMETERS     => L_CONTEXT_PARAMETERS,
    P_CURR_INSTR_PROCESS_ID  => P_CURR_INSTRUCTION_PROCESS_ID,
    X_INSTRUCTION_PROCESS_ID => X_INSTRUCTION_PROCESS_ID,
    X_RETURN_STATUS          => L_RETURN_STATUS,
    X_MSG_COUNT              => L_MSG_COUNT,
    X_MSG_DATA               => L_MSG_DATA
  );

  --If the return status is not success then raise an exception.
  IF L_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR OR L_RETURN_STATUS = FND_API.G_RET_STS_ERROR  THEN
    RAISE CREATE_ERROR;
  END IF;

EXCEPTION
  WHEN CREATE_ERROR THEN
    FND_MESSAGE.SET_ENCODED(L_MSG_DATA);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'edr.plsql.GMO_DISPENSE_SETUP_PVT.CREATE_DEFN_CONTEXT',
                      FALSE
                     );
    END IF;

    APP_EXCEPTION.RAISE_EXCEPTION;

  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
    FND_MESSAGE.SET_TOKEN('PKG_NAME','GMO_DISPENSE_SETUP_PVT');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','CREATE_DEFN_CONTEXT');

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'edr.plsql.GMO_DISPENSE_SETUP_PVT.CREATE_DEFN_CONTEXT',
                      FALSE
                     );
    END IF;

    APP_EXCEPTION.RAISE_EXCEPTION;

END CREATE_DEFN_CONTEXT;


--This procedure is used to update the context parameters associated with the specified process ID and entity parameters
PROCEDURE UPDATE_CONTEXT_PARAMS
(
  P_INSTRUCTION_PROCESS_ID     IN  NUMBER,
  P_ENTITY_NAME                IN  VARCHAR2,
  P_ENTITY_KEY                 IN  VARCHAR2,
  P_ENTITY_DISPLAYNAME         IN  VARCHAR2,
  P_INSTRUCTION_TYPE           IN  FND_TABLE_OF_VARCHAR2_255,
  P_CONTEXT_PARAMETER_NAMES    IN  FND_TABLE_OF_VARCHAR2_255,
  P_CONTEXT_PARAMETER_VALUES   IN  FND_TABLE_OF_VARCHAR2_255
)

IS

L_ENTITY_NAME        FND_TABLE_OF_VARCHAR2_255;

L_ENTITY_KEY         FND_TABLE_OF_VARCHAR2_255;

L_ENTITY_DISPLAYNAME FND_TABLE_OF_VARCHAR2_255;


L_RETURN_STATUS          VARCHAR2(10);
L_MSG_COUNT              NUMBER;
L_MSG_DATA               VARCHAR2(4000);

L_INSTRUCTION_PROCESS_ID NUMBER;


L_CONTEXT_PARAMETERS GMO_DATATYPES_GRP.GMO_DEFINITION_PARAM_TBL_TYPE;

i NUMBER;

UPDATE_ERROR EXCEPTION;

BEGIN

  --Initialize the the entity names array containing only one element.
  L_ENTITY_NAME        := FND_TABLE_OF_VARCHAR2_255();
  L_ENTITY_NAME.EXTEND;

  --Initialize the the entity keys array containing only one element.
  L_ENTITY_KEY         := FND_TABLE_OF_VARCHAR2_255();
  L_ENTITY_KEY.EXTEND;

  --Initialize the the entity display name array containing only one element.
  L_ENTITY_DISPLAYNAME := FND_TABLE_OF_VARCHAR2_255();
  L_ENTITY_DISPLAYNAME.EXTEND;

  --Set the entity name, key and display name values.
  L_ENTITY_NAME(1)        := P_ENTITY_NAME;
  L_ENTITY_KEY(1)         := P_ENTITY_KEY;
  L_ENTITY_DISPLAYNAME(1) := P_ENTITY_DISPLAYNAME;

  --Set the context parameter values.
  FOR i IN 1..P_CONTEXT_PARAMETER_NAMES.COUNT LOOP

    L_CONTEXT_PARAMETERS(i).name := P_CONTEXT_PARAMETER_NAMES(i);
    L_CONTEXT_PARAMETERS(i).value := P_CONTEXT_PARAMETER_VALUES(i);

  END LOOP;

  --Call the API to update the context parameters of the existing definition context.
  GMO_INSTRUCTION_GRP.CREATE_DEFN_CONTEXT
  (
    P_API_VERSION            => 1.0,
    P_INIT_MSG_LIST          => FND_API.G_FALSE,
    P_VALIDATION_LEVEL       => FND_API.G_VALID_LEVEL_NONE,
    P_CURR_INSTR_PROCESS_ID  => P_INSTRUCTION_PROCESS_ID,
    P_ENTITY_NAME            => L_ENTITY_NAME,
    P_ENTITY_KEY             => L_ENTITY_KEY,
    P_ENTITY_DISPLAYNAME     => L_ENTITY_DISPLAYNAME,
    P_INSTRUCTION_TYPE       => P_INSTRUCTION_TYPE,
    P_MODE                   => GMO_CONSTANTS_GRP.G_INSTR_DEFN_MODE_UPDATE,
    P_CONTEXT_PARAMETERS     => L_CONTEXT_PARAMETERS,
    X_INSTRUCTION_PROCESS_ID => L_INSTRUCTION_PROCESS_ID,
    X_RETURN_STATUS          => L_RETURN_STATUS,
    X_MSG_COUNT              => L_MSG_COUNT,
    X_MSG_DATA               => L_MSG_DATA
  );

  --If the return status is not success then raise an exception.
  IF L_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR OR L_RETURN_STATUS = FND_API.G_RET_STS_ERROR  THEN
    RAISE UPDATE_ERROR;
  END IF;

EXCEPTION
  WHEN UPDATE_ERROR THEN
    FND_MESSAGE.SET_ENCODED(L_MSG_DATA);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'edr.plsql.GMO_DISPENSE_SETUP_PVT.UPDATE_CONTEXT_PARAMS',
                      FALSE
                     );
    END IF;

    APP_EXCEPTION.RAISE_EXCEPTION;

  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
    FND_MESSAGE.SET_TOKEN('PKG_NAME','GMO_DISPENSE_SETUP_PVT');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','CREATE_DEFN_CONTEXT');

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'edr.plsql.GMO_DISPENSE_SETUP_PVT.UPDATE_CONTEXT_PARAMS',
                      FALSE
                     );
    END IF;

    APP_EXCEPTION.RAISE_EXCEPTION;

END UPDATE_CONTEXT_PARAMS;


--This procedure is used to construct transaction XML to be send to ERES for processing.
--In particular, it obtains the process instruction details (identified by the
--instruction process ID) in XML format and merges the same with the current XML parameter.
--This merged XML is returned as the output XML.
PROCEDURE GET_TRANSACTION_XML(P_INSTR_PROCESS_ID IN         NUMBER,
                               P_CURRENT_XML      IN         CLOB,
                              X_OUTPUT_XML       OUT NOCOPY CLOB)

IS

L_PROCESS_STATUS VARCHAR2(20);

L_RETURN_STATUS  VARCHAR2(10);

L_MSG_COUNT      NUMBER;

L_MSG_DATA       VARCHAR2(4000);

L_INSTR_XML      CLOB;

XML_ERROR        EXCEPTION;

BEGIN

--Create a temporary CLOB that would hold the final transaction XML.
DBMS_LOB.CREATETEMPORARY(X_OUTPUT_XML, TRUE, DBMS_LOB.SESSION);

--Append the contents of the current XML.
DBMS_LOB.APPEND(X_OUTPUT_XML,P_CURRENT_XML);

--Call the PL/SQL API to fetch the instruction set details in XML format for the specified
--process ID.
GMO_INSTRUCTION_GRP.GET_INSTR_XML
(P_API_VERSION            => 1.0,
 P_INIT_MSG_LIST          => FND_API.G_FALSE,
 P_VALIDATION_LEVEL       => FND_API.G_VALID_LEVEL_NONE,
 P_INSTRUCTION_PROCESS_ID => P_INSTR_PROCESS_ID,
 X_OUTPUT_XML             => L_INSTR_XML,
 X_RETURN_STATUS          => L_RETURN_STATUS,
 X_MSG_COUNT              => L_MSG_COUNT,
 X_MSG_DATA               => L_MSG_DATA);

--If the return status is not success then raise an error.
IF L_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR OR L_RETURN_STATUS = FND_API.G_RET_STS_ERROR  THEN
  RAISE XML_ERROR;
END IF;

--Append the XML of instruction set details to the final XML.
DBMS_LOB.APPEND(X_OUTPUT_XML,L_INSTR_XML);

--Append the XML Footer to the FINAL XML.
DBMS_LOB.WRITEAPPEND(X_OUTPUT_XML,length(EDR_CONSTANTS_GRP.G_ERECORD_XML_FOOTER),EDR_CONSTANTS_GRP.G_ERECORD_XML_FOOTER);

EXCEPTION
  WHEN XML_ERROR THEN
    FND_MESSAGE.SET_ENCODED(L_MSG_DATA);
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'edr.plsql.GMO_DISPENSE_SETUP_PVT.GET_TRANSACTION_XML',
                      FALSE
                     );
    END IF;

    APP_EXCEPTION.RAISE_EXCEPTION;

  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
    FND_MESSAGE.SET_TOKEN('PKG_NAME','GMO_DISPENSE_SETUP_PVT');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','GET_TRANSACTION_XML');

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'edr.plsql.GMO_DISPENSE_SETUP_PVT.GET_TRANSACTION_XML',
                      FALSE
                     );
    END IF;

    APP_EXCEPTION.RAISE_EXCEPTION;



END GET_TRANSACTION_XML;


--This procedure used to send an acknowledgement back to process instructions to
--copy the details from the temp tables into the permanent tables for the specified
--instruction process ID and entity.
PROCEDURE SEND_INSTR_ACKN(P_INSTR_PROCESS_ID  IN NUMBER,
                          P_ENTITY_NAME       IN VARCHAR2,
                          P_SOURCE_ENTITY_KEY IN VARCHAR2,
                          P_TARGET_ENTITY_KEY IN VARCHAR2)
IS

L_MSG_DATA VARCHAR2(4000);
L_MSG_COUNT NUMBER;
L_RETURN_STATUS VARCHAR2(10);
L_INSTRUCTION_TYPE VARCHAR2(4000);
L_INSTRUCTION_SET_ID NUMBER;
SEND_ACKN_ERROR EXCEPTION;

CURSOR DISPENSE_INSTR_TYPES_CSR IS
  SELECT LOOKUP_CODE
  FROM FND_LOOKUPS
  WHERE LOOKUP_TYPE = 'GMO_INSTR_' || P_ENTITY_NAME;

BEGIN


  --If the source and target entity keys are different then call PI's SEND_DEFN_FROM_DEFN
  --to ensure proper versioning.
  IF P_SOURCE_ENTITY_KEY <> P_TARGET_ENTITY_KEY THEN

    --Open the cursor.
    OPEN DISPENSE_INSTR_TYPES_CSR;

    LOOP
      FETCH DISPENSE_INSTR_TYPES_CSR INTO L_INSTRUCTION_TYPE;
      EXIT WHEN DISPENSE_INSTR_TYPES_CSR%NOTFOUND;

      --Create a definition from definition for each instruction type.
      GMO_INSTRUCTION_GRP.CREATE_DEFN_FROM_DEFN
      (
        P_API_VERSION           => 1.0,
        P_INIT_MSG_LIST         => FND_API.G_TRUE,
        P_COMMIT                => FND_API.G_FALSE,
        P_VALIDATION_LEVEL      => FND_API.G_VALID_LEVEL_NONE,
        P_SOURCE_ENTITY_NAME    => P_ENTITY_NAME,
        P_SOURCE_ENTITY_KEY     => P_SOURCE_ENTITY_KEY,
        P_TARGET_ENTITY_NAME    => P_ENTITY_NAME,
        P_TARGET_ENTITY_KEY     => P_TARGET_ENTITY_KEY,
        P_INSTRUCTION_TYPE      => L_INSTRUCTION_TYPE,
        X_RETURN_STATUS         => L_RETURN_STATUS,
        X_MSG_COUNT             => L_MSG_COUNT,
        X_MSG_DATA              => L_MSG_DATA,
        X_INSTRUCTION_SET_ID    => L_INSTRUCTION_SET_ID
      );

      --If the return status is not success then raise an exception.
      IF L_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR OR L_RETURN_STATUS = FND_API.G_RET_STS_ERROR  THEN
        RAISE SEND_ACKN_ERROR;
      END IF;
    END LOOP;

    CLOSE DISPENSE_INSTR_TYPES_CSR;

  END IF;

  --Call the PL/SQL API to send the definition acknowledgement.
  GMO_INSTRUCTION_GRP.SEND_DEFN_ACKN
  (
    P_API_VERSION            => 1.0,
    P_INIT_MSG_LIST          => FND_API.G_FALSE,
    P_VALIDATION_LEVEL       => FND_API.G_VALID_LEVEL_NONE,
    P_INSTRUCTION_PROCESS_ID => P_INSTR_PROCESS_ID,
    P_ENTITY_NAME            => P_ENTITY_NAME,
    P_SOURCE_ENTITY_KEY      => P_SOURCE_ENTITY_KEY,
    P_TARGET_ENTITY_KEY      => P_TARGET_ENTITY_KEY,
    X_RETURN_STATUS          => L_RETURN_STATUS,
    X_MSG_COUNT              => L_MSG_COUNT,
    X_MSG_DATA               => L_MSG_DATA
  );

  --If the return status is not success then raise an exception.
  IF L_RETURN_STATUS = FND_API.G_RET_STS_UNEXP_ERROR OR L_RETURN_STATUS = FND_API.G_RET_STS_ERROR  THEN
    RAISE SEND_ACKN_ERROR;
  END IF;

EXCEPTION
  WHEN SEND_ACKN_ERROR THEN

    IF DISPENSE_INSTR_TYPES_CSR%ISOPEN THEN
      CLOSE DISPENSE_INSTR_TYPES_CSR;
    END IF;

    FND_MESSAGE.SET_ENCODED(L_MSG_DATA);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'edr.plsql.GMO_DISPENSE_SETUP_PVT.SEND_INSTR_ACKN',
                      FALSE
                     );
    END IF;

    APP_EXCEPTION.RAISE_EXCEPTION;

  WHEN OTHERS THEN

    IF DISPENSE_INSTR_TYPES_CSR%ISOPEN THEN
      CLOSE DISPENSE_INSTR_TYPES_CSR;
    END IF;

    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
    FND_MESSAGE.SET_TOKEN('PKG_NAME','GMO_DISPENSE_SETUP_PVT');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','SEND_INSTR_ACKN');

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'edr.plsql.GMO_DISPENSE_SETUP_PVT.SEND_INSTR_ACKN',
                      FALSE
                     );
    END IF;

    APP_EXCEPTION.RAISE_EXCEPTION;
    null;

END SEND_INSTR_ACKN;

--This procedure is used to obtain the dispense configuration for the specified
--item, organization and recipe.
PROCEDURE GET_DISPENSE_CONFIG
(
  P_INVENTORY_ITEM_ID          IN         NUMBER,
  P_ORGANIZATION_ID            IN         NUMBER,
  P_RECIPE_ID                  IN         NUMBER,
  X_DISPENSE_CONFIG            OUT NOCOPY GMO_DISPENSE_CONFIG%ROWTYPE,
  X_INSTRUCTION_DEFINITION_KEY OUT NOCOPY VARCHAR2
)

IS

BEGIN

  X_INSTRUCTION_DEFINITION_KEY := NULL;

  --Obtain the dispense configuration for the case where both organization and recipe are specified.
  BEGIN
    SELECT * INTO X_DISPENSE_CONFIG
    FROM  GMO_DISPENSE_CONFIG
    WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID
    AND   ORGANIZATION_ID = P_ORGANIZATION_ID
    AND   RECIPE_ID = P_RECIPE_ID
    AND   DISPENSE_REQUIRED_FLAG = 'Y'
    AND   SYSDATE BETWEEN START_DATE AND NVL(END_DATE,START_DATE);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      X_DISPENSE_CONFIG := NULL;
  END;


  IF (X_DISPENSE_CONFIG.CONFIG_ID IS NOT NULL) THEN

    --A valid dispense configuration has been found.
    --Obtain the instruction defninition key and exit.
    X_INSTRUCTION_DEFINITION_KEY := X_DISPENSE_CONFIG.CONFIG_ID;
    RETURN;

  END IF;

  --Obtain the dispense configuration for the case where organization is specified, but recipe is null.
  BEGIN
    SELECT * INTO X_DISPENSE_CONFIG
    FROM  GMO_DISPENSE_CONFIG
    WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID
    AND   ORGANIZATION_ID=P_ORGANIZATION_ID
    AND   DISPENSE_REQUIRED_FLAG = 'Y'
    AND   RECIPE_ID IS NULL
    AND   SYSDATE BETWEEN START_DATE AND NVL(END_DATE,START_DATE);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      X_DISPENSE_CONFIG := NULL;
  END;

  IF (X_DISPENSE_CONFIG.CONFIG_ID IS NOT NULL) THEN

    --A valid dispense configuration has been found.
    --Obtain the instruction defninition key and exit.
    X_INSTRUCTION_DEFINITION_KEY := X_DISPENSE_CONFIG.CONFIG_ID;
    RETURN;

  END IF;

  --Obtain the dispense configuration for the case where organization and recipe is null.
  BEGIN
    SELECT * INTO X_DISPENSE_CONFIG
    FROM  GMO_DISPENSE_CONFIG
    WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID
    AND   DISPENSE_REQUIRED_FLAG = 'Y'
    AND   ORGANIZATION_ID IS NULL
    AND   RECIPE_ID IS NULL
    AND   SYSDATE BETWEEN START_DATE AND NVL(END_DATE,START_DATE);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    X_DISPENSE_CONFIG := NULL;
  END;

  IF (X_DISPENSE_CONFIG.CONFIG_ID IS NOT NULL) THEN

    --A valid dispense configuration has been found.
    --Obtain the instruction defninition key and exit.
    X_INSTRUCTION_DEFINITION_KEY := X_DISPENSE_CONFIG.CONFIG_ID;

  END IF;

END GET_DISPENSE_CONFIG;


--This function is obtain the dispense UOM value for the specified item, organization and recipe.
FUNCTION GET_DISPENSE_UOM
(
  P_INVENTORY_ITEM_ID IN NUMBER,
  P_ORGANIZATION_ID   IN NUMBER,
  P_RECIPE_ID         IN NUMBER
) RETURN VARCHAR2

IS

--This variable would hold the dispense uom value.
L_RETURN_VALUE VARCHAR2(240);

--This variable would hold the dispense configuration details for the specified item, organization and recipe.
L_DISPENSE_CONFIG GMO_DISPENSE_CONFIG%ROWTYPE;

--This variable sould hold the instruction key.
L_INSTRUCTION_KEY VARCHAR2(240);
BEGIN

  L_RETURN_VALUE := NULL;

  --Obtain the dispense configuration details for the specified item, org and recipe.
  GET_DISPENSE_CONFIG(P_INVENTORY_ITEM_ID          => P_INVENTORY_ITEM_ID,
                      P_ORGANIZATION_ID            => P_ORGANIZATION_ID,
                      P_RECIPE_ID                  => P_RECIPE_ID,
                      X_DISPENSE_CONFIG            => L_DISPENSE_CONFIG,
                      X_INSTRUCTION_DEFINITION_KEY => L_INSTRUCTION_KEY);

  --If the dispense UOM value was found then set the same on the return value.
  IF(L_DISPENSE_CONFIG.DISPENSE_UOM IS NOT NULL) THEN
    L_RETURN_VALUE := L_DISPENSE_CONFIG.DISPENSE_UOM;
  END IF;

  --Return the dispense UOM value.
  RETURN L_RETURN_VALUE;

END GET_DISPENSE_UOM;


--This function is used to verify if the specified UOM is convertible with the
--primary UOM value.
FUNCTION IS_CONV_WITH_PRIMARY_UOM
(
  P_UOM VARCHAR2,
  P_ITEM_ID NUMBER,
  P_ORGANIZATION_ID NUMBER
) RETURN VARCHAR2

IS

L_ITEM_UOM VARCHAR2(10);
L_RETURN_VALUE NUMBER;
BEGIN

  SELECT PRIMARY_UOM_CODE INTO L_ITEM_UOM
  FROM   MTL_SYSTEM_ITEMS
  WHERE  INVENTORY_ITEM_ID = P_ITEM_ID
  AND    ORGANIZATION_ID = NVL(P_ORGANIZATION_ID, ORGANIZATION_ID)
  AND    ROWNUM =1;

  IF P_ORGANIZATION_ID IS NOT NULL THEN

    L_RETURN_VALUE := INV_CONVERT.INV_UM_CONVERT(P_ITEM_ID,
                                                 NULL,
                                                 P_ORGANIZATION_ID,
                                                 1,
                                                 1,
                                                 L_ITEM_UOM,
                                                 P_UOM,
                                                 NULL,
                                                 NULL);
  ELSE
    L_RETURN_VALUE := INV_CONVERT.INV_UM_CONVERT(P_ITEM_ID,
                                                 1,
                                                 1,
                                                 L_ITEM_UOM,
                                                 P_UOM,
                                                 NULL,
                                                 NULL);
  END IF;

  IF  (L_RETURN_VALUE = -99999) THEN
    RETURN FND_API.G_FALSE;
  END IF;

  RETURN FND_API.G_TRUE;

  EXCEPTION WHEN OTHERS THEN
    RETURN FND_API.G_FALSE;

END IS_CONV_WITH_PRIMARY_UOM;


--Yhis procedure is used check if dispense is required for the specified item,
--organization and recipe. If dispensing is required, it returns the corresponding
--dispense config ID that can be used to identify the dispense setup.
PROCEDURE IS_DISPENSE_ITEM
(
  P_INVENTORY_ITEM_ID    IN  NUMBER,
  P_ORGANIZATION_ID      IN  NUMBER,
  P_RECIPE_ID            IN  NUMBER,
  X_IS_DISPENSE_REQUIRED OUT NOCOPY VARCHAR2,
  X_DISPENSE_CONFIG_ID   OUT NOCOPY VARCHAR2
)

IS

BEGIN

  --Obtain the value of the dispense required flag for the case where organization and recipe are specified.
  BEGIN
    SELECT DISPENSE_REQUIRED_FLAG,CONFIG_ID
    INTO   X_IS_DISPENSE_REQUIRED,X_DISPENSE_CONFIG_ID
    FROM GMO_DISPENSE_CONFIG
    WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID
    AND ORGANIZATION_ID=P_ORGANIZATION_ID
    AND RECIPE_ID=P_RECIPE_ID
    AND SYSDATE BETWEEN START_DATE AND NVL(END_DATE,SYSDATE);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      X_IS_DISPENSE_REQUIRED := 'N';
  END;

  IF (X_IS_DISPENSE_REQUIRED = 'Y' ) THEN

    --If the flag is set to 'Y' then return.
    RETURN;

  END IF;

  --Obtain the value of the dispense required flag for the case where organization is specified, but recipe is null.
  BEGIN
    SELECT DISPENSE_REQUIRED_FLAG,CONFIG_ID
    INTO   X_IS_DISPENSE_REQUIRED,X_DISPENSE_CONFIG_ID
    FROM GMO_DISPENSE_CONFIG
    WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID
    AND ORGANIZATION_ID=P_ORGANIZATION_ID
    AND RECIPE_ID IS NULL
    AND SYSDATE BETWEEN START_DATE AND NVL(END_DATE,SYSDATE);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    X_IS_DISPENSE_REQUIRED := 'N';
  END;

  IF X_IS_DISPENSE_REQUIRED = 'Y' THEN

    --If the flag is set to 'Y' then return.
    RETURN;
  END IF;

  --Obtain the value of the dispense required flag for the case where both organization and recipe are null.
  BEGIN
    SELECT DISPENSE_REQUIRED_FLAG,CONFIG_ID
    INTO   X_IS_DISPENSE_REQUIRED,X_DISPENSE_CONFIG_ID
    FROM   GMO_DISPENSE_CONFIG
    WHERE  INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID
    AND    ORGANIZATION_ID IS NULL
    AND    RECIPE_ID IS NULL
    AND    SYSDATE BETWEEN START_DATE AND NVL(END_DATE,SYSDATE);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    X_IS_DISPENSE_REQUIRED := 'N';
  END;

  IF X_IS_DISPENSE_REQUIRED = 'N' THEN
    X_DISPENSE_CONFIG_ID := NULL;
  END IF;

END IS_DISPENSE_ITEM;


--This procedure is used to obtain the dispense configuration for the specified ENTITY_NAME and
--ENTITY_KEY from the instance tables.
PROCEDURE GET_DISPENSE_CONFIG_INST
(
  P_ENTITY_NAME                IN         VARCHAR2,
  P_ENTITY_KEY                 IN         VARCHAR2,
  X_DISPENSE_CONFIG            OUT NOCOPY GMO_DISPENSE_CONFIG%ROWTYPE,
  X_INSTRUCTION_DEFINITION_KEY OUT NOCOPY VARCHAR2
)
IS

L_DISPENSE_CONFIG_ID NUMBER;

BEGIN

  X_INSTRUCTION_DEFINITION_KEY := NULL;

  SELECT DISPENSE_CONFIG_ID INTO L_DISPENSE_CONFIG_ID
  FROM   GMO_DISPENSE_CONFIG_INST
  WHERE  ENTITY_NAME = P_ENTITY_NAME
  AND    ENTITY_KEY  = P_ENTITY_KEY;

  IF L_DISPENSE_CONFIG_ID IS NOT NULL THEN
    SELECT * INTO X_DISPENSE_CONFIG FROM GMO_DISPENSE_CONFIG
    WHERE  CONFIG_ID = L_DISPENSE_CONFIG_ID;

    IF (X_DISPENSE_CONFIG.CONFIG_ID IS NOT NULL) THEN

      --A valid dispense configuration has been found.
      --Obtain the instruction defninition key.
      X_INSTRUCTION_DEFINITION_KEY := X_DISPENSE_CONFIG.CONFIG_ID;

    END IF;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
END GET_DISPENSE_CONFIG_INST;


--This procedure is used to instantiate the dispense setup identified by the specified
--dispense config ID, entity name and entity key.
PROCEDURE INSTANTIATE_DISPENSE_SETUP
(P_DISPENSE_CONFIG_ID IN  NUMBER,
 P_ENTITY_NAME        IN  VARCHAR2,
 P_ENTITY_KEY         IN  VARCHAR2,
 P_INIT_MSG_LIST      IN  VARCHAR2,
 P_AUTO_COMMIT        IN  VARCHAR2,
 X_RETURN_STATUS      OUT NOCOPY VARCHAR2,
 X_MSG_COUNT          OUT NOCOPY NUMBER,
 X_MSG_DATA           OUT NOCOPY VARCHAR2)

IS

L_API_NAME           CONSTANT VARCHAR2(40) := 'INSTANTIATE_DISPENSE_SETUP';


L_COUNT NUMBER;

GMO_NO_DISPENSE_CONFIG_ERR EXCEPTION;

BEGIN

  --Initialize the message list if specified so.
  IF FND_API.TO_BOOLEAN( P_INIT_MSG_LIST ) THEN

    FND_MSG_PUB.INITIALIZE;

  END IF;

  IF P_AUTO_COMMIT = FND_API.G_TRUE THEN
    INSTANTIATE_DISP_SETUP_AUTO
    (P_DISPENSE_CONFIG_ID => P_DISPENSE_CONFIG_ID,
     P_ENTITY_NAME        => P_ENTITY_NAME,
     P_ENTITY_KEY         => P_ENTITY_KEY,
     P_INIT_MSG_LIST      => P_INIT_MSG_LIST,
     X_RETURN_STATUS      => X_RETURN_STATUS,
     X_MSG_COUNT          => X_MSG_COUNT,
     X_MSG_DATA           => X_MSG_DATA);
  ELSE
    --Check if a dispense setup exists for the specified config ID.
    SELECT COUNT(*) INTO L_COUNT
    FROM   GMO_DISPENSE_CONFIG
    WHERE  CONFIG_ID = P_DISPENSE_CONFIG_ID;

    IF L_COUNT > 0 THEN
      INSERT INTO GMO_DISPENSE_CONFIG_INST(INSTANCE_ID,
                                           DISPENSE_CONFIG_ID,
	   				   ENTITY_NAME,
					   ENTITY_KEY,
                                           CREATION_DATE,
                                           CREATED_BY,
					   LAST_UPDATE_DATE,
					   LAST_UPDATED_BY,
					   LAST_UPDATE_LOGIN)

      VALUES (GMO_DISPENSE_CONFIG_INST_S.NEXTVAL,
              P_DISPENSE_CONFIG_ID,
	      P_ENTITY_NAME,
	      P_ENTITY_KEY,
	      SYSDATE,
	      FND_GLOBAL.USER_ID(),
	      SYSDATE,
	      FND_GLOBAL.LOGIN_ID(),
	      FND_GLOBAL.LOGIN_ID());
    ELSE
      RAISE GMO_NO_DISPENSE_CONFIG_ERR;
    END IF;

    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

  END IF;

EXCEPTION
  WHEN GMO_NO_DISPENSE_CONFIG_ERR THEN

    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

    FND_MESSAGE.SET_NAME('GMO','GMO_INVALID_DISPENSE_CONFIG_ID');
    FND_MESSAGE.SET_TOKEN('CONFIG_ID',P_DISPENSE_CONFIG_ID);
    FND_MESSAGE.SET_TOKEN('ENTITY_NAME',P_ENTITY_NAME);
    FND_MESSAGE.SET_TOKEN('ENTITY_NAME',P_ENTITY_NAME);

    FND_MSG_PUB.ADD;

    FND_MSG_PUB.COUNT_AND_GET
    (P_COUNT => X_MSG_COUNT,
     P_DATA  => X_MSG_DATA);

    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                      'gmo.plsql.GMO_DISPENSE_SETUP_PVT.INSTANTIATE_DISPENSE_SETUP',
                      FALSE);
    END IF;

  WHEN OTHERS THEN

    X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR ;

    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
    FND_MESSAGE.SET_TOKEN('PKG_NAME','GMO_DISPENSE_SETUP_PVT');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','INSTANTIATE_DISPENSE_SETUP');

    FND_MSG_PUB.ADD;

    IF  FND_MSG_PUB.CHECK_MSG_LEVEL( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)  THEN

      FND_MSG_PUB.ADD_EXC_MSG (G_PKG_NAME,
                               L_API_NAME );

    END IF;

    FND_MSG_PUB.COUNT_AND_GET
    (P_COUNT => X_MSG_COUNT,
     P_DATA  => X_MSG_DATA);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'gmo.plsql.GMO_DISPENSE_SETUP_PVT.INSTANTIATE_DISPENSE_SETUP',
                      FALSE);
    END IF;

END INSTANTIATE_DISPENSE_SETUP;


--This procedure is used to instantiate the dispense setup identified by the specified
--dispense config ID, entity name and entity key. The transaction is committed autonomously.
PROCEDURE INSTANTIATE_DISP_SETUP_AUTO
(P_DISPENSE_CONFIG_ID IN  NUMBER,
 P_ENTITY_NAME        IN  VARCHAR2,
 P_ENTITY_KEY         IN  VARCHAR2,
 P_INIT_MSG_LIST      IN  VARCHAR2,
 X_RETURN_STATUS      OUT NOCOPY VARCHAR2,
 X_MSG_COUNT          OUT NOCOPY NUMBER,
 X_MSG_DATA           OUT NOCOPY VARCHAR2)

IS

L_API_NAME           CONSTANT VARCHAR2(40) := 'INSTANTIATE_DISPENSE_SETUP';


L_COUNT NUMBER;

GMO_NO_DISPENSE_CONFIG_ERR EXCEPTION;

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

  --Initialize the message list if specified so.
  IF FND_API.TO_BOOLEAN( P_INIT_MSG_LIST ) THEN

    FND_MSG_PUB.INITIALIZE;

  END IF;

  --Check if a dispense setup exists for the specified config ID.
  SELECT COUNT(*) INTO L_COUNT
  FROM   GMO_DISPENSE_CONFIG
  WHERE  CONFIG_ID = P_DISPENSE_CONFIG_ID;

  IF L_COUNT > 0 THEN
    INSERT INTO GMO_DISPENSE_CONFIG_INST(INSTANCE_ID,
                                         DISPENSE_CONFIG_ID,
					 ENTITY_NAME,
					 ENTITY_KEY,
                                         CREATION_DATE,
                                         CREATED_BY,
					 LAST_UPDATE_DATE,
					 LAST_UPDATED_BY,
					 LAST_UPDATE_LOGIN)

     VALUES (GMO_DISPENSE_CONFIG_INST_S.NEXTVAL,
             P_DISPENSE_CONFIG_ID,
	     P_ENTITY_NAME,
	     P_ENTITY_KEY,
	     SYSDATE,
	     FND_GLOBAL.USER_ID(),
	     SYSDATE,
	     FND_GLOBAL.LOGIN_ID(),
	     FND_GLOBAL.LOGIN_ID());
  ELSE
    RAISE GMO_NO_DISPENSE_CONFIG_ERR;
  END IF;

  COMMIT;

  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN GMO_NO_DISPENSE_CONFIG_ERR THEN
    ROLLBACK;

    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

    FND_MESSAGE.SET_NAME('GMO','GMO_INVALID_DISPENSE_CONFIG_ID');
    FND_MESSAGE.SET_TOKEN('CONFIG_ID',P_DISPENSE_CONFIG_ID);
    FND_MESSAGE.SET_TOKEN('ENTITY_NAME',P_ENTITY_NAME);
    FND_MESSAGE.SET_TOKEN('ENTITY_NAME',P_ENTITY_NAME);

    FND_MSG_PUB.ADD;

    FND_MSG_PUB.COUNT_AND_GET
    (P_COUNT => X_MSG_COUNT,
     P_DATA  => X_MSG_DATA);

    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                      'gmo.plsql.GMO_DISPENSE_SETUP_PVT.INSTANTIATE_DISP_SETUP',
                      FALSE);
    END IF;

  WHEN OTHERS THEN
    ROLLBACK;

    X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR ;

    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
    FND_MESSAGE.SET_TOKEN('PKG_NAME','GMO_DISPENSE_SETUP_PVT');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','INSTANTIATE_DISP_SETUP');

    FND_MSG_PUB.ADD;

    IF  FND_MSG_PUB.CHECK_MSG_LEVEL( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)  THEN

      FND_MSG_PUB.ADD_EXC_MSG (G_PKG_NAME,
                               L_API_NAME );

    END IF;

    FND_MSG_PUB.COUNT_AND_GET
    (P_COUNT => X_MSG_COUNT,
     P_DATA  => X_MSG_DATA);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'gmo.plsql.GMO_DISPENSE_SETUP_PVT.INSTANTIATE_DISP_SETUP',
                      FALSE);
    END IF;

END INSTANTIATE_DISP_SETUP_AUTO;

--This function return the dispense setup status based on the specified start and end date values.
--The status value returned is one of possible lookup code values contained in the lookup type
--GMO_DISP_SETUP_STATUS.
FUNCTION GET_SETUP_STATUS(P_START_DATE DATE,
                          P_END_DATE   DATE)

RETURN VARCHAR2

IS

BEGIN

  IF SYSDATE BETWEEN P_START_DATE AND NVL(P_END_DATE,SYSDATE) OR P_START_DATE > SYSDATE THEN
    RETURN 'N';
  ELSE
    RETURN 'P';
  END IF;

END GET_SETUP_STATUS;

--This function checks if the the difference between the specified dates is atleast
--two seconds. Based on this condition it returns FND_API.G_TRUE or FND_API.G_FALSE.
FUNCTION IS_DATE_DIFF_SUFFICIENT(P_FIRST_DATE    DATE,
                                 P_SECOND_DATE   DATE)

RETURN VARCHAR2

IS

L_DIFF NUMBER;

BEGIN

  IF P_FIRST_DATE IS NOT NULL AND P_SECOND_DATE IS NOT NULL THEN
    L_DIFF := P_SECOND_DATE - P_FIRST_DATE;

    IF L_DIFF > 1/86400 THEN
      RETURN FND_API.G_TRUE;
    ELSE
      RETURN FND_API.G_FALSE;
    END IF;
  ELSE
    RETURN FND_API.G_TRUE;
  END IF;

END IS_DATE_DIFF_SUFFICIENT;


--This function subtracts the specified number of seconds from the date provided.
FUNCTION SUBTRACT_SECONDS_FROM_DATE(P_DATE    DATE,
                                    P_SECONDS NUMBER)

RETURN DATE

IS

L_DATE DATE;

BEGIN

  IF P_DATE IS NOT NULL THEN

    L_DATE := P_DATE;

    L_DATE := L_DATE - P_SECONDS/86400;
  ELSE
    L_DATE := NULL;
  END IF;

  RETURN L_DATE;
END SUBTRACT_SECONDS_FROM_DATE;

--This function adds the specified number of seconds from the date provided.
FUNCTION ADD_SECONDS_TO_DATE(P_DATE    DATE,
                             P_SECONDS NUMBER)

RETURN DATE

IS

L_DATE DATE;

BEGIN

  IF P_DATE IS NOT NULL THEN

    L_DATE := P_DATE;

    L_DATE := L_DATE + P_SECONDS/86400;
  ELSE
    L_DATE := NULL;
  END IF;

  RETURN L_DATE;
END ADD_SECONDS_TO_DATE;


END GMO_DISPENSE_SETUP_PVT;

/
