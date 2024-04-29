--------------------------------------------------------
--  DDL for Package GMO_DISPENSE_SETUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMO_DISPENSE_SETUP_PVT" 
-- $Header: GMOVDSSS.pls 120.3 2006/02/01 14:44:55 swasubra noship $

AUTHID CURRENT_USER AS

G_PKG_NAME CONSTANT VARCHAR2(30) := 'GMO_DISPENSE_SETUP_PVT';

-- Start of comments
-- API name             : GET_ITEM_DISPLAY_NAME
-- Type                 : Private Function.
-- Function             : This function is used to obtain the display name of the item
--                        identified by the item ID.
-- Pre-reqs             : None
--
-- IN                   : P_ITEM_ID - The item ID whose display name is to be fetched.
--
-- RETURN               : The display name of the item identified by the item ID.
--End of comments
FUNCTION GET_ITEM_DISPLAY_NAME(P_ITEM_ID NUMBER)
RETURN VARCHAR2;



-- Start of comments
-- API name             : GET_ITEM_DESCRIPTION
-- Type                 : Private Function.
-- Function             : This function is used to obtain the description of the item
--                        identified by the item ID.
--
-- Pre-reqs             : None
--
-- IN                   : P_ITEM_ID - The item ID whose description is to be fetched.
--
-- RETURN               : The description of the item identified by the item ID.
--End of comments
FUNCTION GET_ITEM_DESCRIPTION(P_ITEM_ID NUMBER)
RETURN VARCHAR2;


-- Start of comments
-- API name             : CREATE_DEFN_CONTEXT
-- Type                 : Private Procedure.
-- Function             : This procedure is used to create a definition context in Process Instructions
--                        for the specified entity name, entity key and instruction types. It would return
--                        a instruction process ID through its OUT parameter.
-- Pre-reqs             : None
--
-- IN                   : P_ENTITY_NAME              - The entity name
--                      : P_ENTITY_KEY               - The entity key
--                      : P_ENTITY_DISPLAYNAME       - The entity display name
--                      : P_INSTRUCTION_TYPE         - The instruction types associated with the entity
--                      : P_MODE                     - The mode (Update or Read Only)
--                      : P_CONTEXT_PARAMETER_NAMES  - The context parameter names associated with the entity
--                      : P_CONTEXT_PARAMETER_VALUES - The corresponding context parameter values.
--
-- OUT                  : X_INSTRUCTION_PROCESS_ID   - The instruction process ID that identified the newly
--                                                     created definition context.
--End of comments
PROCEDURE CREATE_DEFN_CONTEXT
(
  P_ENTITY_NAME                IN  VARCHAR2,
  P_ENTITY_KEY                 IN  VARCHAR2,
  P_ENTITY_DISPLAYNAME         IN  VARCHAR2,
  P_INSTRUCTION_TYPE           IN  FND_TABLE_OF_VARCHAR2_255,
  P_MODE                       IN  VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.G_INSTR_DEFN_MODE_UPDATE,
  P_CONTEXT_PARAMETER_NAMES    IN  FND_TABLE_OF_VARCHAR2_255,
  P_CONTEXT_PARAMETER_VALUES   IN  FND_TABLE_OF_VARCHAR2_255,
  P_CURR_INSTRUCTION_PROCESS_ID IN  NUMBER DEFAULT NULL,
  X_INSTRUCTION_PROCESS_ID     OUT NOCOPY NUMBER
);


-- Start of comments
-- API name             : UPDATE_CONTEXT_PARAMS
-- Type                 : Private Procedure.
-- Function             : This procedure is used to update the context parameters associated with the specified process ID and entity parameters
-- Pre-reqs             : None
--
-- IN                   : P_INSTRUCTION_PROCESS_ID   - The instruction process ID.
--                      : P_ENTITY_NAME              - The entity name.
--                      : P_ENTITY_KEY               - The entity key.
--                      : P_ENTITY_DISPLAYNAME       - The entity display name
--                      : P_INSTRUCTION_TYPE         - The instruction types associated with the entity
--                      : P_CONTEXT_PARAMETER_NAMES  - The updated context parameter names to be associated with the entity.
--                      : P_CONTEXT_PARAMETER_VALUES - The corresponding context parameter values.
--
--End of comments
PROCEDURE UPDATE_CONTEXT_PARAMS
(
  P_INSTRUCTION_PROCESS_ID     IN  NUMBER,
  P_ENTITY_NAME                IN  VARCHAR2,
  P_ENTITY_KEY                 IN  VARCHAR2,
  P_ENTITY_DISPLAYNAME         IN  VARCHAR2,
  P_INSTRUCTION_TYPE           IN  FND_TABLE_OF_VARCHAR2_255,
  P_CONTEXT_PARAMETER_NAMES    IN  FND_TABLE_OF_VARCHAR2_255,
  P_CONTEXT_PARAMETER_VALUES   IN  FND_TABLE_OF_VARCHAR2_255
);



-- Start of comments
-- API name             : GET_TRANSACTION_XML
-- Type                 : Private Procedure.
-- Function             : This procedure is used to construct transaction XML to be send to ERES for processing.
--                      : In particular, it obtains the process instruction details (identified by the
--                      : instruction process ID) in XML format and merges the same with the current XML parameter.
--                      : This merged XML is returned as the output XML.
--
-- Pre-reqs             : None
--
-- IN                   : P_INSTR_PROCESS_ID - The instruction process ID that identifies the process instruction
--                      :                      details associated with the dispense setup.
--                      : P_CURRENT_XML      - The current transaction XML.

--
-- OUT                  : X_OUTPUT_XML       - The final merged transaction XML ready to be sent to ERES for
--                                           - processing.
--End of comments
PROCEDURE GET_TRANSACTION_XML
(
  P_INSTR_PROCESS_ID IN         NUMBER,
  P_CURRENT_XML      IN         CLOB,
  X_OUTPUT_XML       OUT NOCOPY CLOB
);

-- Start of comments
-- API name             : SEND_INSTR_ACKN
-- Type                 : Private Procedure.
-- Function             : This procedure used to send an acknowledgement back to process instructions to
--                        copy the details from the temp tables into the permanent tables for the specified
--                        instruction process ID and entity.
--
-- Pre-reqs             : None
--
-- IN                   : P_INSTR_PROCESS_ID - The instruction process ID.
--                      : P_ENTITY_NAME      - The entity name.
--                      : P_SOURCE_ENTITY_KEY       - The source entity key.
--                      : P_TARGET_ENTITY_KEY       - The target entity key.
--
--End of comments
PROCEDURE SEND_INSTR_ACKN
(
  P_INSTR_PROCESS_ID  IN NUMBER,
  P_ENTITY_NAME       IN VARCHAR2,
  P_SOURCE_ENTITY_KEY IN VARCHAR2,
  P_TARGET_ENTITY_KEY IN VARCHAR2
);


-- Start of comments
-- API name             : GET_DISPENSE_CONFIG
-- Type                 : Private Procedure.
-- Function             : This procedure is used to obtain the dispense configuration for the specified
--                      : item, organization and recipe.
--
-- Pre-reqs             : None
--
-- IN                   : P_INVENTORY_ID    - The item ID
--                      : P_ORGANIZATION_ID - The organization ID
--                      : P_RECIPE_ID       - The recipe ID
--
-- OUT                  : X_DISPENSE_CONFIG            - The dispense configuration
--                      : X_INSTRUCTION_DEFINITION_KEY - The associated instruction defninition key.
--End of comments
PROCEDURE GET_DISPENSE_CONFIG
(
  P_INVENTORY_ITEM_ID          IN         NUMBER,
  P_ORGANIZATION_ID            IN         NUMBER,
  P_RECIPE_ID                  IN         NUMBER,
  X_DISPENSE_CONFIG            OUT NOCOPY GMO_DISPENSE_CONFIG%ROWTYPE,
  X_INSTRUCTION_DEFINITION_KEY OUT NOCOPY VARCHAR2
);


-- Start of comments
-- API name             : IS_DISPENSE_ITEM
-- Type                 : Private Function.
-- Function             : This function is obtain the dispense UOM value for the specified item, organization and recipe.
--
-- Pre-reqs             : None
--
-- IN                   : P_INVENTORY_ITEM_ID - The item ID
--                      : P_ORGANIZATION_ID   - The organization ID
--                      : P_RECIPE_ID         - The recipe ID
--
-- RETURNS              : The dispense UOM value
--End of comments
FUNCTION GET_DISPENSE_UOM
(
  P_INVENTORY_ITEM_ID IN NUMBER,
  P_ORGANIZATION_ID   IN NUMBER,
  P_RECIPE_ID         IN NUMBER
) RETURN VARCHAR2;


-- Start of comments
-- API name             : IS_CONV_WITH_PRIMARY_UOM
-- Type                 : Private Function.
-- Function             : This function is used to verify if the specified UOM is convertible with the
--                        primary UOM value.
--
-- Pre-reqs             : None
--
-- IN                   : P_UOM             - The UOM value to be verified
--                      : P_ITEM_ID         - The item ID
--                      : P_ORGANIZATION_ID - The organization ID
--
-- Returns                  : A flag indicating if the specified uom is convertible with the primmary UOM value.
--End of comments
FUNCTION IS_CONV_WITH_PRIMARY_UOM
(
  P_UOM             VARCHAR2,
  P_ITEM_ID         NUMBER,
  P_ORGANIZATION_ID NUMBER
) RETURN VARCHAR2;



-- API name             : IS_DISPENSE_ITEM
-- Type                 : Private Procedure.
-- Function             : This procedure is used check if dispense is required for the specified item,
--                      : organization and recipe. If dispensing is required, it returns the corresponding
--                        dispense config ID that can be used to identify the dispense setup.
--
-- Pre-reqs             : None
--
-- IN                   : P_INVENTORY_ITEM_ID    - The item ID
--                      : P_ORGANIZATION_ID      - The organization ID
--                      : P_RECIPE_ID            - The recipe ID
--                      : X_IS_DISPENSE_REQUIRED - Return flag indicating if dispensing is required.
--                      : X_DISPENSE_CONFIG_ID   - The corresponding dispense config ID if dispensing is required.
--
-- RETURNS              : A flag indicating if dispense is required
--End of comments
PROCEDURE IS_DISPENSE_ITEM
(
  P_INVENTORY_ITEM_ID    IN         NUMBER,
  P_ORGANIZATION_ID      IN         NUMBER,
  P_RECIPE_ID            IN         NUMBER,
  X_IS_DISPENSE_REQUIRED OUT NOCOPY VARCHAR2,
  X_DISPENSE_CONFIG_ID   OUT NOCOPY VARCHAR2
);


-- Start of comments
-- API name             : GET_DISPENSE_CONFIG_INST
-- Type                 : Private Procedure.
-- Function             : This procedure is used to obtain the dispense configuration for the specified ENTITY_NAME and
--                        ENTITY_KEY from the instance tables.
--
-- Pre-reqs             : None
--
-- IN                   : P_ENTITY_NAME - The entity name.
--                      : P_ENTITY_KEY  - The entity key.
--
-- OUT                  : X_DISPENSE_CONFIG            - The dispense configuration
--                      : X_INSTRUCTION_DEFINITION_KEY - The associated instruction defninition key.
--End of comments
PROCEDURE GET_DISPENSE_CONFIG_INST
(
  P_ENTITY_NAME                IN         VARCHAR2,
  P_ENTITY_KEY                 IN         VARCHAR2,
  X_DISPENSE_CONFIG            OUT NOCOPY GMO_DISPENSE_CONFIG%ROWTYPE,
  X_INSTRUCTION_DEFINITION_KEY OUT NOCOPY VARCHAR2
);


-- Start of comments
-- API name             : INSTANTIATE_DISPENSE_SETUP
-- Type                 : Private Procedure.
-- Function             : This procedure is used to instantiate the dispense setup identified by the specified
--                        dispense config ID, entity name and entity key.
-- Pre-reqs             : None
--
-- IN                   : P_DISPENSE_CONFIG_ID.
--                      : P_ENTITY_NAME  - The entity name.
--                      : P_ENTITY_KEY  - The entity key.
--End of comments
PROCEDURE INSTANTIATE_DISPENSE_SETUP
(P_DISPENSE_CONFIG_ID IN  NUMBER,
 P_ENTITY_NAME        IN  VARCHAR2,
 P_ENTITY_KEY         IN  VARCHAR2,
 P_INIT_MSG_LIST      IN  VARCHAR2,
 P_AUTO_COMMIT        IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
 X_RETURN_STATUS      OUT NOCOPY VARCHAR2,
 X_MSG_COUNT          OUT NOCOPY NUMBER,
 X_MSG_DATA           OUT NOCOPY VARCHAR2);



-- Start of comments
-- API name             : INSTANTIATE_DISP_SETUP
-- Type                 : Private Procedure.
-- Function             : This procedure is used to instantiate the dispense setup identified by the specified
--                        dispense config ID, entity name and entity key. The transaction is committed autonomously.
-- Pre-reqs             : None
--
-- IN                   : P_DISPENSE_CONFIG_ID.
--                      : P_ENTITY_NAME  - The entity name.
--                      : P_ENTITY_KEY  - The entity key.
--End of comments
PROCEDURE INSTANTIATE_DISP_SETUP_AUTO
(P_DISPENSE_CONFIG_ID IN  NUMBER,
 P_ENTITY_NAME        IN  VARCHAR2,
 P_ENTITY_KEY         IN  VARCHAR2,
 P_INIT_MSG_LIST      IN  VARCHAR2,
 X_RETURN_STATUS      OUT NOCOPY VARCHAR2,
 X_MSG_COUNT          OUT NOCOPY NUMBER,
 X_MSG_DATA           OUT NOCOPY VARCHAR2);


--This function return the dispense setup status based on the specified start and end date values.
--The status value returned is one of possible lookup code values contained in the lookup type
--GMO_DISP_SETUP_STATUS.
FUNCTION GET_SETUP_STATUS(P_START_DATE DATE,
                          P_END_DATE   DATE)


RETURN VARCHAR2;

--This function checks if the the difference between the specified dates is atleast
--two seconds. Based on this condition it returns FND_API.G_TRUE or FND_API.G_FALSE.
FUNCTION IS_DATE_DIFF_SUFFICIENT(P_FIRST_DATE  DATE,
                                 P_SECOND_DATE DATE)

RETURN VARCHAR2;

--This function subtracts the specified number of seconds from the date provided.
FUNCTION SUBTRACT_SECONDS_FROM_DATE(P_DATE    DATE,
                                    P_SECONDS NUMBER)
RETURN DATE;

--This function adds the specified number of seconds from the date provided.
FUNCTION ADD_SECONDS_TO_DATE(P_DATE    DATE,
                             P_SECONDS NUMBER)
RETURN DATE;

END GMO_DISPENSE_SETUP_PVT;

 

/
