--------------------------------------------------------
--  DDL for Package GMO_INSTRUCTION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMO_INSTRUCTION_GRP" AUTHID CURRENT_USER AS
/*$Header: GMOGINTS.pls 120.3 2006/07/12 04:50:43 rahugupt noship $*/

-- API Name constant
G_PKG_NAME CONSTANT VARCHAR2(30) := 'GMO_INSTRUCTION_GRP';

-- This API is called to create a definition context with multiple
-- entity name, entity key, entity display names, and Instruction
-- types. It is called before definition UI is invoked to create
-- the necessary context for definition

-- Start of comments
-- API name             : CREATE_DEFN_CONTEXT
-- Type                 : Group API
-- Function             : Create the definition context for list
--                        of entity name and key pairs

-- Pre-reqs             : None.
-- Parameters
-- P_API_VERSION	   API Version
-- P_INIT_MSG_LIST         Initialize message list default = false
-- P_VALIDATION_LEVEL	   Default validation level = FULL

-- P_CURR_INSTR_PROCSS_ID  Current instruction proces id for session
-- P_ENTITY_NAME	   Table of entity names to be used during definition
-- P_ENTITY_KEY		   Table of entity keys
-- P_ENTITY_DISPLAYNAME    Table of MLS Compliant Entity display names
-- P_INSTRUCTION_TYPE      Table of Instruction Types to support in definition
-- P_MODE                  Mode of operation in definition UI = READ | UPDATE
-- P_CONTEXT_PARAMETERS    Table of context parameters

-- X_INSTRUCTION_PROCESS_ID The transaction/ process id, used in the definition
--                          process to identify a particular session

-- X_RETURN_STATUS         The return status based on standard API convention
-- X_MSG_COUNT             Message count
-- X_MSG_DATA              Return messages

-- End of comments


PROCEDURE CREATE_DEFN_CONTEXT
(
    P_API_VERSION           IN NUMBER,
    P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_VALIDATION_LEVEL      IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2,

    P_CURR_INSTR_PROCESS_ID IN NUMBER DEFAULT NULL,
    P_ENTITY_NAME           IN FND_TABLE_OF_VARCHAR2_255,
    P_ENTITY_KEY            IN FND_TABLE_OF_VARCHAR2_255,
    P_ENTITY_DISPLAYNAME    IN FND_TABLE_OF_VARCHAR2_255,
    P_INSTRUCTION_TYPE      IN FND_TABLE_OF_VARCHAR2_255,
    P_MODE                  IN VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.G_INSTR_DEFN_MODE_UPDATE,
    P_CONTEXT_PARAMETERS    IN GMO_DATATYPES_GRP.GMO_DEFINITION_PARAM_TBL_TYPE,
    X_INSTRUCTION_PROCESS_ID OUT NOCOPY NUMBER

);


-- This API is called to create a definition context with single
-- entity name, entity key, entity display name, and Instruction
-- type. It is called before definition UI is invoked to create
-- the necessary context for definition.

-- Start of comments
-- API name             : CREATE_DEFN_CONTEXT
-- Type                 : Group API
-- Function             : Create the definition context for single
--                        of entity name and key pair

-- Pre-reqs             : None.
-- Parameters
-- P_API_VERSION	   API Version
-- P_INIT_MSG_LIST         Initialize message list default = false
-- P_VALIDATION_LEVEL	   Default validation level = FULL

-- P_CURR_INSTR_PROCSS_ID  Current instruction proces id for session
-- P_ENTITY_NAME	   Entity name to be used during definition
-- P_ENTITY_KEY		   Entity key
-- P_ENTITY_DISPLAYNAME    MLS Compliant Entity display name
-- P_INSTRUCTION_TYPE      Instruction Type to support in definition
-- P_MODE                  Mode of operation in definition UI = READ | UPDATE
-- P_CONTEXT_PARAMETERS    Table of context parameters

-- X_INSTRUCTION_PROCESS_ID The transaction/ process id, used in the definition
--                          process to identify a particular session

-- X_RETURN_STATUS         The return status based on standard API convention
-- X_MSG_COUNT             Message count
-- X_MSG_DATA              Return messages

-- End of comments


PROCEDURE CREATE_DEFN_CONTEXT
(
    P_API_VERSION           IN NUMBER,
    P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_VALIDATION_LEVEL      IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2,

    P_CURR_INSTR_PROCESS_ID IN NUMBER DEFAULT NULL,
    P_ENTITY_NAME           IN VARCHAR2,
    P_ENTITY_KEY            IN VARCHAR2,
    P_ENTITY_DISPLAYNAME    IN VARCHAR2,
    P_INSTRUCTION_TYPE      IN VARCHAR2,
    P_MODE                  IN VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.G_INSTR_DEFN_MODE_UPDATE,
    P_CONTEXT_PARAMETERS    IN GMO_DATATYPES_GRP.GMO_DEFINITION_PARAM_TBL_TYPE,
    X_INSTRUCTION_PROCESS_ID OUT NOCOPY NUMBER

);

-- This API is called to create a definition context with multiple
-- entity name, entity key, entity display names, and Instruction
-- types. It is called before definition UI is invoked to create
-- the necessary context for definition. This flavor is used by
-- GMO_INSTR_GRP PLL Package, as FORMS does not support
-- FND_TABLE_OF_VARCHAR2_255

-- Start of comments
-- API name             : CREATE_DEFN_CONTEXT
-- Type                 : Group API
-- Function             : Create the definition context for list
--                        of entity name and key pairs

-- Pre-reqs             : None.
-- Parameters
-- P_API_VERSION	   API Version
-- P_INIT_MSG_LIST         Initialize message list default = false
-- P_VALIDATION_LEVEL	   Default validation level = FULL

-- P_CURR_INSTR_PROCSS_ID  Current instruction proces id for session
-- P_ENTITY_NAME	   Table of entity names to be used during definition
-- P_ENTITY_KEY		   Table of entity keys
-- P_ENTITY_DISPLAYNAME    Table of MLS Compliant Entity display names
-- P_INSTRUCTION_TYPE      Table of Instruction Types to support in definition
-- P_MODE                  Mode of operation in definition UI = READ | UPDATE
-- P_CONTEXT_PARAMETERS    Table of context parameters

-- X_INSTRUCTION_PROCESS_ID The transaction/ process id, used in the definition
--                          process to identify a particular session

-- X_RETURN_STATUS         The return status based on standard API convention
-- X_MSG_COUNT             Message count
-- X_MSG_DATA              Return messages

-- End of comments

PROCEDURE CREATE_DEFN_CONTEXT
(
    P_API_VERSION           IN NUMBER,
    P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_VALIDATION_LEVEL      IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2,

    P_CURR_INSTR_PROCESS_ID IN NUMBER DEFAULT NULL,
    P_ENTITY_NAME           IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
    P_ENTITY_KEY            IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
    P_ENTITY_DISPLAYNAME    IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
    P_INSTRUCTION_TYPE      IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
    P_MODE                  IN VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.G_INSTR_DEFN_MODE_UPDATE,
    P_CONTEXT_PARAMETERS    IN GMO_DATATYPES_GRP.GMO_DEFINITION_PARAM_TBL_TYPE,
    X_INSTRUCTION_PROCESS_ID OUT NOCOPY NUMBER
);



-- This API is called to delete the instructions related to an entity
-- from the Process Instructions System.
-- Start of comments
-- API name             : CREATE_DEFN_CONTEXT
-- Type                 : Group API
-- Function             : Create the definition context for list
--                        of entity name and key pairs

-- Pre-reqs             : None.
-- Parameters
-- P_API_VERSION	   API Version
-- P_INIT_MSG_LIST         Initialize message list default = false
-- P_VALIDATION_LEVEL	   Default validation level = FULL

-- P_CURR_INSTR_PROCESS_ID The current instruction process id for session.
-- P_ENTITY_NAME	   Table of entity names to be used during definition
-- P_ENTITY_KEY		   Table of entity keys
-- X_INSTRUCTION_PROCESS_ID The transaction/ process id, used in the definition
--                          process to identify a particular session

-- X_RETURN_STATUS         The return status based on standard API convention
-- X_MSG_COUNT             Message count
-- X_MSG_DATA              Return messages

-- End of comments

PROCEDURE DELETE_ENTITY_FOR_PROCESS
(
       P_API_VERSION           IN NUMBER,
       P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
       P_VALIDATION_LEVEL      IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
       X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
       X_MSG_COUNT             OUT NOCOPY NUMBER,
       X_MSG_DATA              OUT NOCOPY VARCHAR2,

       P_CURR_INSTR_PROCESS_ID   IN NUMBER,
       P_ENTITY_NAME             IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
       P_ENTITY_KEY              IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
       X_INSTRUCTION_PROCESS_ID  OUT NOCOPY NUMBER
);

-- This API is called to create a definition from existing
-- definition. It is called by the entity application to create
-- a new definition from existing ones

-- Start of comments
-- API name             : CREATE_DEFN_FROM_DEFN
-- Type                 : Group API
-- Function             : Create the definition from existing definition

-- Pre-reqs             : None.
-- Parameters
-- P_API_VERSION	   API Version
-- P_INIT_MSG_LIST         Initialize message list default = false
-- P_VALIDATION_LEVEL	   Default validation level = FULL

-- P_SOURCE_ENTITY_NAME   Source entity name
-- P_SOURCE_ENTITY_KEY    Source entity key

-- P_TARGET_ENTITY_NAME   Target entity name
-- P_TARGET_ENTITY_KEY    Target entity key

-- P_INSTRUCTION_TYPE     Instruction Type

-- X_INSTRUCTION_SET_ID   The INSTRUCTION_SET_ID of newly created definition

-- X_RETURN_STATUS         The return status based on standard API convention
-- X_MSG_COUNT             Message count
-- X_MSG_DATA              Return messages

-- End of comments

PROCEDURE CREATE_DEFN_FROM_DEFN
(
    P_API_VERSION           IN NUMBER,
    P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_COMMIT                IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_VALIDATION_LEVEL      IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2,

    P_SOURCE_ENTITY_NAME   IN VARCHAR2,
    P_SOURCE_ENTITY_KEY    IN VARCHAR2,
    P_TARGET_ENTITY_NAME   IN VARCHAR2,
    P_TARGET_ENTITY_KEY    IN VARCHAR2,
    P_INSTRUCTION_TYPE      IN VARCHAR2,
    X_INSTRUCTION_SET_ID    OUT NOCOPY NUMBER

);

-- This API is called to send the definition acknowledgement
-- This API also copies the data from temporary tables to permenant
-- tables

-- Start of comments
-- API name             : SEND_DEFN_ACKN
-- Type                 : Group API
-- Function             : Send definition acknowledgement

-- Pre-reqs             : None
-- Parameters

-- P_API_VERSION	   API Version
-- P_INIT_MSG_LIST         Initialize message list default = FALSE
-- P_VALIDATION_LEVEL	   Default validation level = FULL

-- P_INSTRUCTION_PROCESS_ID  The instruction process id
-- P_ENTITY_NAME             The entity name

-- P_SOURCE_ENTITY_KEY    Source entity key
-- P_TARGET_ENTITY_KEY    Target entity key

-- X_RETURN_STATUS         The return status based on standard API convention
-- X_MSG_COUNT             Message count
-- X_MSG_DATA              Return messages

-- End of comments

PROCEDURE SEND_DEFN_ACKN
(
    P_API_VERSION           IN NUMBER,
    P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_COMMIT                IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_VALIDATION_LEVEL      IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2,

    P_INSTRUCTION_PROCESS_ID    IN NUMBER,
    P_ENTITY_NAME               IN VARCHAR2,
    P_SOURCE_ENTITY_KEY         IN VARCHAR2,
    P_TARGET_ENTITY_KEY         IN VARCHAR2

);

-- This API is called to send the definition acknowledgement
-- for multiple entity name and key values

-- This API also copies the data from temporary tables to permenant
-- tables

-- Start of comments
-- API name             : SEND_DEFN_ACKN
-- Type                 : Group API
-- Function             : Send definition acknowledgement

-- Pre-reqs             : None
-- Parameters

-- P_API_VERSION	   API Version
-- P_INIT_MSG_LIST         Initialize message list default = FALSE
-- P_VALIDATION_LEVEL	   Default validation level = FULL

-- P_INSTRUCTION_PROCESS_ID  The instruction process id
-- P_ENTITY_NAME          The entity name as FND_TABLE_OF_VARCHAR2_255
-- P_SOURCE_ENTITY_KEY    Source entity key
-- P_TARGET_ENTITY_KEY    Target entity key

-- X_RETURN_STATUS         The return status based on standard API convention
-- X_MSG_COUNT             Message count
-- X_MSG_DATA              Return messages

-- End of comments

PROCEDURE SEND_DEFN_ACKN
(
    P_API_VERSION           IN NUMBER,
    P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_COMMIT                IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_VALIDATION_LEVEL      IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2,

    P_INSTRUCTION_PROCESS_ID    IN NUMBER,
    P_ENTITY_NAME               IN FND_TABLE_OF_VARCHAR2_255,
    P_SOURCE_ENTITY_KEY         IN FND_TABLE_OF_VARCHAR2_255,
    P_TARGET_ENTITY_KEY         IN FND_TABLE_OF_VARCHAR2_255

);

-- This API is called to send the definition acknowledgement
-- for multiple entity name and key values
-- This flavor is used by GMO_INSTR pll interface

-- This API also copies the data from temporary tables to permenant
-- tables

-- Start of comments
-- API name             : SEND_DEFN_ACKN
-- Type                 : Group API
-- Function             : Send definition acknowledgement

-- Pre-reqs             : None
-- Parameters

-- P_API_VERSION	   API Version
-- P_INIT_MSG_LIST         Initialize message list default = FALSE
-- P_VALIDATION_LEVEL	   Default validation level = FULL

-- P_INSTRUCTION_PROCESS_ID  The instruction process id
-- P_ENTITY_NAME          The entity name as GMO_TABLE_OF_VARCHAR2_255
-- P_SOURCE_ENTITY_KEY    Source entity key
-- P_TARGET_ENTITY_KEY    Target entity key

-- X_RETURN_STATUS         The return status based on standard API convention
-- X_MSG_COUNT             Message count
-- X_MSG_DATA              Return messages

-- End of comments

PROCEDURE SEND_DEFN_ACKN
(
    P_API_VERSION           IN NUMBER,
    P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_COMMIT                IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_VALIDATION_LEVEL      IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2,

    P_INSTRUCTION_PROCESS_ID    IN NUMBER,
    P_ENTITY_NAME               IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
    P_SOURCE_ENTITY_KEY         IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
    P_TARGET_ENTITY_KEY         IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255

);

-- This API will get the definition status := MODIFIED | NO_CHANGE

-- Start of comments
-- API name             : GET_DEFN_STATUS
-- Type                 : Group API
-- Function             : get the definition status := MODIFIED | NO_CHANGE
-- Pre-reqs             : None
-- Parameters

-- P_API_VERSION	   API Version
-- P_INIT_MSG_LIST         Initialize message list default = FALSE
-- P_VALIDATION_LEVEL	   Default validation level = FULL

-- P_INSTRUCTION_PROCESS_ID The definition time instruction_process_id
-- X_DEFINITION_STATUS      The definition status for given process id

-- X_RETURN_STATUS         The return status based on standard API convention
-- X_MSG_COUNT             Message count
-- X_MSG_DATA              Return messages

-- End of comments

PROCEDURE GET_DEFN_STATUS
(
    P_API_VERSION           IN NUMBER,
    P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_VALIDATION_LEVEL      IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2,

    P_INSTRUCTION_PROCESS_ID IN NUMBER,
    X_DEFINITION_STATUS OUT NOCOPY VARCHAR2

);

-- Start of comments
-- API name             : GET_INSTR_XML
-- Type                 : Group
-- Function             : This procedure returns the instruction set and all the related instruction details
--                      : in XML format for the specified instruction process ID.
-- Pre-reqs             : None
--
-- Parameters
-- IN                   : P_INSTRUCTION_PROCESS_ID  - The instruction process ID.
-- OUT                  : X_OUTPUT_XML              - The final XML.

-- P_API_VERSION	   API Version
-- P_INIT_MSG_LIST         Initialize message list default = FALSE
-- P_VALIDATION_LEVEL	   Default validation level = FULL

-- X_RETURN_STATUS         The return status based on standard API convention
-- X_MSG_COUNT             Message count
-- X_MSG_DATA              Return messages

-- End of comments

PROCEDURE GET_INSTR_XML
(
    P_API_VERSION           IN NUMBER,
    P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_VALIDATION_LEVEL      IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2,


    P_INSTRUCTION_PROCESS_ID IN NUMBER,
    X_OUTPUT_XML             OUT NOCOPY CLOB
);

-- Start of comments
-- API name             : GET_INSTR_XML
-- Type                 : Group
-- Function             : This procedure returns the instruction instance details in XML format for the specified
--                        instruction process ID.
-- Pre-reqs             : None
--
-- Parameters
-- IN                   : P_INSTRUCTION_PROCESS_ID  - The instruction process ID.
-- OUT                  : X_OUTPUT_XML              - The final XML.

-- P_API_VERSION           API Version
-- P_INIT_MSG_LIST         Initialize message list default = FALSE
-- P_VALIDATION_LEVEL      Default validation level = FULL

-- X_RETURN_STATUS         The return status based on standard API convention
-- X_MSG_COUNT             Message count
-- X_MSG_DATA              Return messages

-- End of comments

PROCEDURE GET_INSTR_INSTANCE_XML
(
    P_API_VERSION           IN NUMBER,
    P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_VALIDATION_LEVEL      IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2,


    P_INSTRUCTION_PROCESS_ID IN NUMBER,
    X_OUTPUT_XML             OUT NOCOPY CLOB
);


-- This API is called to create instance from definition
-- for given entity name, entity key and instruction type

-- Start of comments
-- API name             : CREATE_INSTANCE_FROM_DEFN
-- Type                 : Group API
-- Function             : Creates an instance from the definition

-- Pre-reqs             : None
-- Parameters

-- P_API_VERSION	   API Version
-- P_INIT_MSG_LIST         Initialize message list default = FALSE
-- P_VALIDATION_LEVEL	   Default validation level = FULL

-- P_DEFINITION_ENTITY_NAME  The definition entity name
-- P_DEFINITION_ENTITY_KEY   The definition entity key
-- P_INSTANCE_ENTITY_NAME    The instance entity name
-- P_INSTANCE_ENTITY_KEY     The instance entity key

-- P_INSTRUCTION_TYPE        The instruction type
-- X_INSTRUCTION_SET_ID      The instruction set id output

-- X_RETURN_STATUS         The return status based on
--                         standard API convention

-- X_MSG_COUNT             Message count
-- X_MSG_DATA              Return messages

-- End of comments

PROCEDURE CREATE_INSTANCE_FROM_DEFN
(
    P_API_VERSION           IN NUMBER,
    P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_COMMIT                IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_VALIDATION_LEVEL      IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2,

    P_DEFINITION_ENTITY_NAME    IN VARCHAR2,
    P_DEFINITION_ENTITY_KEY     IN VARCHAR2,
    P_INSTANCE_ENTITY_NAME      IN VARCHAR2,
    P_INSTANCE_ENTITY_KEY       IN VARCHAR2,
    P_INSTRUCTION_TYPE          IN VARCHAR2,
    X_INSTRUCTION_SET_ID        OUT NOCOPY NUMBER

);

-- This API is called to create instance from instance

-- Start of comments
-- API name             : CREATE_INSTANCE_FROM_INSTANCE
-- Type                 : Group API
-- Function             : Creates an instance from the instance

-- Pre-reqs             : None
-- Parameters

-- P_API_VERSION	   API Version
-- P_INIT_MSG_LIST         Initialize message list default = FALSE
-- P_VALIDATION_LEVEL	   Default validation level = FULL

-- P_SOURCE_ENTITY_NAME   The INSTANCE entity name
-- P_SOURCE_ENTITY_KEY    The INSTANCE entity key
-- P_TARGET_ENTITY_KEY    The instance TARGET  entity key

-- P_INSTRUCTION_TYPE     The instruction type
-- X_INSTRUCTION_SET_ID   The instruction set id

-- X_RETURN_STATUS         The return status based on
--                         standard API convention

-- X_MSG_COUNT             Message count
-- X_MSG_DATA              Return messages

-- End of comments

PROCEDURE CREATE_INSTANCE_FROM_INSTANCE
(

    P_API_VERSION           IN NUMBER,
    P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_COMMIT                IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_VALIDATION_LEVEL      IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2,

    P_SOURCE_ENTITY_NAME        IN VARCHAR2,
    P_SOURCE_ENTITY_KEY         IN VARCHAR2,
    P_TARGET_ENTITY_KEY         IN VARCHAR2,
    P_INSTRUCTION_TYPE          IN VARCHAR2,
    X_INSTRUCTION_SET_ID        OUT NOCOPY NUMBER

);


-- This API is called to send the instance acknowledgment
-- It acknowledges the instruction set and copies the temporary
-- data to permenant instance tables. It also marks all DONE instructions
-- to COMPLETE

-- Start of comments
-- API name             : SEND_TASK_ACKN
-- Type                 : Group API
-- Function             : Send task acknowledgment

-- Pre-reqs             : None
-- Parameters

-- P_API_VERSION	   API Version
-- P_INIT_MSG_LIST         Initialize message list default = FALSE
-- P_VALIDATION_LEVEL	   Default validation level = FULL

-- P_INSTRUCTION_PROCESS_ID  The instruction process id
-- P_ENTITY_KEY              The instance entity key

-- P_TASK_ERECORD_ID       The task e-record id array
-- P_TASK_IDENTIFIER       The task identifier array
-- P_TASK_VALUE            The task value array

-- P_DISABLE_TASK          The default value is 'N', set this to 'Y', if the
--                         manual entry from task is to be disabled

-- P_MANUAL_ENTRY          Whether, the task details being submitted are manually entered
--                         This parameter IS FOR internal USE only

-- X_RETURN_STATUS         The return status based on standard API convention
-- X_MSG_COUNT             Message count
-- X_MSG_DATA              Return messages

-- End of comments

PROCEDURE SEND_TASK_ACKN
(
    P_API_VERSION           IN NUMBER,
    P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_VALIDATION_LEVEL      IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2,

    P_INSTRUCTION_ID IN NUMBER,
    P_INSTRUCTION_PROCESS_ID IN NUMBER,
    P_ENTITY_KEY IN VARCHAR2 DEFAULT NULL,
    P_TASK_ERECORD_ID  IN FND_TABLE_OF_VARCHAR2_255,
    P_TASK_IDENTIFIER IN FND_TABLE_OF_VARCHAR2_255,
    P_TASK_VALUE IN FND_TABLE_OF_VARCHAR2_255,
    P_DISABLE_TASK IN VARCHAR2 DEFAULT 'N'
);


-- This API will mark all the instruction set  for given entity
-- as CANCEL

-- Start of comments
-- API name             : NULLIFY_INSTR_FOR_ENTITY
-- Type                 : Group API
-- Function             : Nullifies instructions for entity

-- Pre-reqs             : None
-- Parameters

-- P_API_VERSION	   API Version
-- P_INIT_MSG_LIST         Initialize message list default = FALSE
-- P_VALIDATION_LEVEL	   Default validation level = FULL

-- P_ENTITY_NAME           The INSTANCE entity name
-- P_ENTITY_KEY            The instance entity key
-- P_INSTRUCTION_TYPE      The instruction type

-- X_RETURN_STATUS         The return status based on standard API convention
-- X_MSG_COUNT             Message count
-- X_MSG_DATA              Return messages

-- End of comments

PROCEDURE NULLIFY_INSTR_FOR_ENTITY
(

    P_API_VERSION           IN NUMBER,
    P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_VALIDATION_LEVEL      IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY NUMBER,
    X_MSG_DATA              OUT NOCOPY VARCHAR2,

    P_ENTITY_NAME IN VARCHAR2,
    P_ENTITY_KEY IN VARCHAR2,
    P_INSTRUCTION_TYPE IN VARCHAR2

);

-- This API returns the task parameter value for passed
-- task parameter name

-- Start of comments
-- API name             :
-- Type                 : Group API
-- Function             : Returns Task Parameter Value

-- Pre-reqs             : None
-- Parameters

-- P_API_VERSION	   API Version
-- P_INIT_MSG_LIST         Initialize message list default = FALSE
-- P_VALIDATION_LEVEL	   Default validation level = FULL

-- P_INSTRUCTION_PROCESS_ID  The Instruction Process Id
-- P_ATTRIBUTE_NAME          Task Parameter Name

-- X_RETURN_STATUS         The return status based on standard API convention
-- X_MSG_COUNT             Message count
-- X_MSG_DATA              Return messages

-- End of comments

PROCEDURE GET_TASK_PARAMETER
(
  P_API_VERSION           IN NUMBER,
  P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  P_VALIDATION_LEVEL      IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
  X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
  X_MSG_COUNT             OUT NOCOPY NUMBER,
  X_MSG_DATA              OUT NOCOPY VARCHAR2,

  P_INSTRUCTION_PROCESS_ID IN NUMBER,
  P_ATTRIBUTE_NAME IN VARCHAR2,
  X_ATTRIBUTE_VALUE OUT NOCOPY VARCHAR2

);

--Bug 5383022: start

-- Start of comments
-- API name             : is_task_attribute_used
-- Type                 : Group API
-- Function             : This procedure is used to check if the task attribute is used
-- Pre-reqs             : None
--
-- IN                   : P_API_VERSION           API Version
--                        P_INIT_MSG_LIST         Initialize message list default = FALSE
--                        P_VALIDATION_LEVEL      Default validation level = FULL
--                        P_INSTRUCTION_PROCESS_ID - The instruction process ID
--                        p_attribute_name - attribute name
--                        p_attribute_key - attribute key
-- OUT                  : x_used_flag - used flag
--                        x_return_status - return status
--                        x_msg_count - message count
--                        x_msg_data - message data
--End of comments

procedure is_task_attribute_used
(
	P_API_VERSION		IN NUMBER,
	P_INIT_MSG_LIST         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
	P_VALIDATION_LEVEL      IN NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
	X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
	X_MSG_COUNT             OUT NOCOPY NUMBER,
	X_MSG_DATA              OUT NOCOPY VARCHAR2,

	p_instruction_process_id IN number,
	p_attribute_name IN varchar2,
	p_attribute_key IN varchar2,
	x_used_flag OUT NOCOPY varchar2
);
--Bug 5383022: end
END GMO_INSTRUCTION_GRP;


 

/
