--------------------------------------------------------
--  DDL for Package GMO_INSTRUCTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMO_INSTRUCTION_PVT" AUTHID CURRENT_USER AS
/* $Header: GMOVINTS.pls 120.5 2006/07/12 04:49:03 rahugupt noship $ */

-- This API is called to create a definition context with multiple
-- entity name, entity key, entity display names, and Instruction
-- types. It is called before definition UI is invoked to create
-- the necessary context for definition

-- Start of comments
-- API name             : CREATE_DEFN_CONTEXT
-- Type                 : Private API
-- Function             : Create the definition context for list
--                        of entity name and key pairs

-- Pre-reqs             : None.
-- Parameters

-- P_INSTRUCTION_PROCESS_ID Instruction Process Id for current Session.
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
    P_CURR_INSTR_PROCESS_ID IN NUMBER DEFAULT NULL,
    P_ENTITY_NAME           IN FND_TABLE_OF_VARCHAR2_255,
    P_ENTITY_KEY            IN FND_TABLE_OF_VARCHAR2_255,
    P_ENTITY_DISPLAYNAME    IN FND_TABLE_OF_VARCHAR2_255,
    P_INSTRUCTION_TYPE      IN FND_TABLE_OF_VARCHAR2_255,
    P_MODE                  IN VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.G_INSTR_DEFN_MODE_UPDATE,
    P_CONTEXT_PARAMETERS    IN GMO_DATATYPES_GRP.GMO_DEFINITION_PARAM_TBL_TYPE,
    X_INSTRUCTION_PROCESS_ID OUT NOCOPY NUMBER,
    X_RETURN_STATUS          OUT NOCOPY VARCHAR2,
    X_MSG_COUNT              OUT NOCOPY NUMBER,
    X_MSG_DATA               OUT NOCOPY VARCHAR2
);

-- This API is called to create a definition context with single
-- entity name, entity key, entity display name, and Instruction
-- type. It is called before definition UI is invoked to create
-- the necessary context for definition.

-- Start of comments
-- API name             : CREATE_DEFN_CONTEXT
-- Type                 : Private API
-- Function             : Create the definition context for single
--                        of entity name and key pair

-- Pre-reqs             : None
-- Parameters

-- P_INSTRUCTION_PROCESS_ID Instruction Process Id for current Session.
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
    P_CURR_INSTR_PROCESS_ID IN NUMBER DEFAULT NULL,
    P_ENTITY_NAME           IN VARCHAR2,
    P_ENTITY_KEY            IN VARCHAR2,
    P_ENTITY_DISPLAYNAME    IN VARCHAR2,
    P_INSTRUCTION_TYPE      IN VARCHAR2,
    P_MODE                  IN VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.G_INSTR_DEFN_MODE_UPDATE,
    P_CONTEXT_PARAMETERS    IN GMO_DATATYPES_GRP.GMO_DEFINITION_PARAM_TBL_TYPE,
    X_INSTRUCTION_PROCESS_ID OUT NOCOPY NUMBER,
    X_RETURN_STATUS          OUT NOCOPY VARCHAR2,
    X_MSG_COUNT              OUT NOCOPY NUMBER,
    X_MSG_DATA               OUT NOCOPY VARCHAR2
);

-- This API is called to create a definition context with multiple
-- entity name, entity key, entity display names, and Instruction
-- types. It is called before definition UI is invoked to create
-- the necessary context for definition. This flavor is used by
-- GMO_INSTR_GRP PLL Package, as FORMS does not support
-- FND_TABLE_OF_VARCHAR2_255

-- Start of comments
-- API name             : CREATE_DEFN_CONTEXT
-- Type                 : Private API
-- Function             : Create the definition context for list
--                        of entity name and key pairs

-- Pre-reqs             : None.
-- Parameters

-- P_INSTRUCTION_PROCESS_ID Instruction Process Id for current Session.
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
    P_CURR_INSTR_PROCESS_ID IN NUMBER DEFAULT NULL,
    P_ENTITY_NAME           IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
    P_ENTITY_KEY            IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
    P_ENTITY_DISPLAYNAME    IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
    P_INSTRUCTION_TYPE      IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
    P_MODE                  IN VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.G_INSTR_DEFN_MODE_UPDATE,
    P_CONTEXT_PARAMETERS    IN GMO_DATATYPES_GRP.GMO_DEFINITION_PARAM_TBL_TYPE,
    X_INSTRUCTION_PROCESS_ID OUT NOCOPY NUMBER,
    X_RETURN_STATUS          OUT NOCOPY VARCHAR2,
    X_MSG_COUNT              OUT NOCOPY NUMBER,
    X_MSG_DATA               OUT NOCOPY VARCHAR2
);

-- This API is called to delete the instructions related to an entity
-- from the Process Instructions System.
-- Start of comments
-- API name             : DELETE_ENTITY_FOR_PROCESS
-- Type                 : Group API
-- Function             : Create the definition context for list
--                        of entity name and key pairs

-- Pre-reqs             : None.
-- Parameters

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
       P_CURR_INSTR_PROCESS_ID   IN NUMBER,
       P_ENTITY_NAME             IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
       P_ENTITY_KEY              IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
       X_INSTRUCTION_PROCESS_ID  OUT NOCOPY NUMBER,
       X_RETURN_STATUS           OUT NOCOPY VARCHAR2,
       X_MSG_COUNT               OUT NOCOPY NUMBER,
       X_MSG_DATA                OUT NOCOPY VARCHAR2
);

-- This API is called to create a definition from existing
-- definition. It is called by the entity application to create
-- a new definition from existing ones

-- Start of comments
-- API name             : CREATE_DEFN_FROM_DEFN
-- Type                 : Private API
-- Function             : Create the definition from existing definition

-- Pre-reqs             : None.
-- Parameters

-- P_SOURCE_ENTITY_NAME   Source entity name
-- P_SOURCE_ENTITY_KEY    Source entity key

-- P_TARGET_ENTITY_NAME   Target entity name
-- P_TARGET_ENTITY_KEY    Target entity key

-- P_INSTRUCTION_TYPE     Instruction Type

-- X_INSTRUCTION_SET_ID   The INSTRUCTION_SET_ID of newly created definition

-- X_RETURN_STATUS        The return status based on standard API convention
-- X_MSG_COUNT            Message count
-- X_MSG_DATA             Return messages

-- End of comments

PROCEDURE CREATE_DEFN_FROM_DEFN
(
    P_SOURCE_ENTITY_NAME   IN VARCHAR2,
    P_SOURCE_ENTITY_KEY    IN VARCHAR2,
    P_TARGET_ENTITY_NAME   IN VARCHAR2,
    P_TARGET_ENTITY_KEY    IN VARCHAR2,
    P_INSTRUCTION_TYPE     IN VARCHAR2,
    X_INSTRUCTION_SET_ID   OUT NOCOPY NUMBER,
    X_RETURN_STATUS        OUT NOCOPY VARCHAR2,
    X_MSG_COUNT            OUT NOCOPY NUMBER,
    X_MSG_DATA             OUT NOCOPY VARCHAR2
);

-- This API is called to send the definition acknowledgement
-- This API also copies the data from temporary tables to permenant
-- tables

-- Start of comments
-- API name             : SEND_DEFN_ACKN
-- Type                 : Private API
-- Function             : Send definition acknowledgement

-- Pre-reqs             : None
-- Parameters

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
    P_INSTRUCTION_PROCESS_ID    IN NUMBER,
    P_ENTITY_NAME               IN VARCHAR2,
    P_SOURCE_ENTITY_KEY         IN VARCHAR2,
    P_TARGET_ENTITY_KEY         IN VARCHAR2,
    X_RETURN_STATUS             OUT NOCOPY VARCHAR2,
    X_MSG_COUNT                 OUT NOCOPY NUMBER,
    X_MSG_DATA                  OUT NOCOPY VARCHAR2
);

-- This API is called to send the definition acknowledgement
-- for multiple entity name and key values

-- This API also copies the data from temporary tables to permenant
-- tables

-- Start of comments
-- API name             : SEND_DEFN_ACKN
-- Type                 : Private API
-- Function             : Send definition acknowledgement

-- Pre-reqs             : None
-- Parameters

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
    P_INSTRUCTION_PROCESS_ID    IN NUMBER,
    P_ENTITY_NAME               IN FND_TABLE_OF_VARCHAR2_255,
    P_SOURCE_ENTITY_KEY         IN FND_TABLE_OF_VARCHAR2_255,
    P_TARGET_ENTITY_KEY         IN FND_TABLE_OF_VARCHAR2_255,
    X_RETURN_STATUS             OUT NOCOPY VARCHAR2,
    X_MSG_COUNT                 OUT NOCOPY NUMBER,
    X_MSG_DATA                  OUT NOCOPY VARCHAR2
);

-- This API is called to send the definition acknowledgement
-- for multiple entity name and key values, from  FORMS

-- This API also copies the data from temporary tables to permenant
-- tables

-- Start of comments
-- API name             : SEND_DEFN_ACKN
-- Type                 : Private API
-- Function             : Send definition acknowledgement

-- Pre-reqs             : None
-- Parameters

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
    P_INSTRUCTION_PROCESS_ID    IN NUMBER,
    P_ENTITY_NAME               IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
    P_SOURCE_ENTITY_KEY         IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
    P_TARGET_ENTITY_KEY         IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
    X_RETURN_STATUS             OUT NOCOPY VARCHAR2,
    X_MSG_COUNT                 OUT NOCOPY NUMBER,
    X_MSG_DATA                  OUT NOCOPY VARCHAR2
);



-- This API is called to create instance from definition
-- for given entity name, entity key and instruction type

-- Start of comments
-- API name             : CREATE_INSTANCE_FROM_DEFN
-- Type                 : Private API
-- Function             : Creates an instance from the definition

-- Pre-reqs             : None
-- Parameters

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
    P_DEFINITION_ENTITY_NAME    IN VARCHAR2,
    P_DEFINITION_ENTITY_KEY     IN VARCHAR2,
    P_INSTANCE_ENTITY_NAME      IN VARCHAR2,
    P_INSTANCE_ENTITY_KEY       IN VARCHAR2,
    P_INSTRUCTION_TYPE          IN VARCHAR2,
    X_INSTRUCTION_SET_ID        OUT NOCOPY NUMBER,
    X_RETURN_STATUS             OUT NOCOPY VARCHAR2,
    X_MSG_COUNT                 OUT NOCOPY NUMBER,
    X_MSG_DATA                  OUT NOCOPY VARCHAR2
);

-- This API is called to create instance from instance

-- Start of comments
-- API name             : CREATE_INSTANCE_FROM_INSTANCE
-- Type                 : Private API
-- Function             : Creates an instance from the instance

-- Pre-reqs             : None
-- Parameters

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
    P_SOURCE_ENTITY_NAME        IN VARCHAR2,
    P_SOURCE_ENTITY_KEY         IN VARCHAR2,
    P_TARGET_ENTITY_KEY         IN VARCHAR2,
    P_INSTRUCTION_TYPE          IN VARCHAR2,
    X_INSTRUCTION_SET_ID        OUT NOCOPY NUMBER,
    X_RETURN_STATUS             OUT NOCOPY VARCHAR2,
    X_MSG_COUNT                 OUT NOCOPY NUMBER,
    X_MSG_DATA                  OUT NOCOPY VARCHAR2
);

-- This API is called to get mode for entity
-- The mode for entity is returned READ if all
-- instructions are compeleted in instruction set.
-- It is UPDATE is some instructions are pending,
-- and INSERT if there are no instruction defined

-- Start of comments
-- API name             : GET_MODE_FOR_ENTITY
-- Type                 : Private API
-- Function             : Gets the mode for entity

-- Pre-reqs             : None
-- Parameters

-- P_ENTITY_NAME           The instance entity name
-- P_ENTITY_KEY            The instance entity key
-- P_INSTRUCTION_TYPE      The instruction type
-- X_MODE                  The MODE for entity

-- X_RETURN_STATUS         The return status based on
--                         standard API convention

-- X_MSG_COUNT             Message count
-- X_MSG_DATA              Return messages

-- End of comments


PROCEDURE GET_MODE_FOR_ENTITY
(
    P_ENTITY_NAME IN VARCHAR2,
    P_ENTITY_KEY IN VARCHAR2,
    P_INSTRUCTION_TYPE IN VARCHAR2,
    X_MODE OUT NOCOPY VARCHAR2,
    X_RETURN_STATUS             OUT NOCOPY VARCHAR2,
    X_MSG_COUNT                 OUT NOCOPY NUMBER,
    X_MSG_DATA                  OUT NOCOPY VARCHAR2
);

-- This API is called to get the list of all instructions
-- in a single table type for given entity name, entity key
-- and instruction type. It returns Definition Time Instructions

-- Start of comments
-- API name             : GET_DEFN_INSTRUCTIONS
-- Type                 : Private API
-- Function             : Gets all instructions for entity

-- Pre-reqs             : None
-- Parameters

-- P_API_VERSION	   API Version
-- P_INIT_MSG_LIST         Initialize message list default = FALSE
-- P_VALIDATION_LEVEL	   Default validation level = FULL

-- P_ENTITY_NAME           The Definition Entity name
-- P_ENTITY_KEY            The Definition Entity key
-- P_INSTRUCTION_TYPE      The Instruction type

-- X_INSTRUCTION_TABLE     GMO_INSTRUCTION_TBL_TYPE table of
--                         available instructions

-- X_RETURN_STATUS         The return status based on
--                         standard API convention

-- X_MSG_COUNT             Message count
-- X_MSG_DATA              Return messages

-- End of comments

PROCEDURE GET_DEFN_INSTRUCTIONS
(
    P_ENTITY_NAME IN VARCHAR2,
    P_ENTITY_KEY IN VARCHAR2,
    P_INSTRUCTION_TYPE VARCHAR2,
    X_INSTRUCTION_TABLE OUT NOCOPY GMO_DATATYPES_GRP.GMO_INSTRUCTION_TBL_TYPE,
    X_RETURN_STATUS             OUT NOCOPY VARCHAR2,
    X_MSG_COUNT                 OUT NOCOPY NUMBER,
    X_MSG_DATA                  OUT NOCOPY VARCHAR2
);

-- This API is checks if there are any pending instructions for
-- the given entity name, key and instruction type on instance
-- permenant tables

-- Start of comments
-- API name             : HAS_PENDING_INSTRUCTIONS
-- Type                 : Private API
-- Function             : Gets the number of pending instructions

-- Pre-reqs             : None

-- Parameters
-- P_ENTITY_NAME           The Instance Entity name
-- P_ENTITY_KEY            The Instance Entity key
-- P_INSTRUCTION_TYPE      The Instruction type

-- X_INSTRUCTION_PENDING   'Y' if there are pending instructions
--                         'N' otherwise

-- X_TOTAL_INSTRUCTIONS      Total number of instructions for entity
-- X_OPTIONAL_PENDING_INSTR  Number of optional instructions pending
-- X_MANDATORY_PENDING_INSTR Number of mandatory instructions pending

-- X_RETURN_STATUS         The return status based on standard API convention
-- X_MSG_COUNT             Message count
-- X_MSG_DATA              Return messages

-- End of comments

PROCEDURE HAS_PENDING_INSTRUCTIONS
(
    P_ENTITY_NAME IN VARCHAR2,
    P_ENTITY_KEY IN VARCHAR2,
    P_INSTRUCTION_TYPE IN VARCHAR2,
    X_INSTRUCTION_PENDING OUT NOCOPY VARCHAR2,
    X_TOTAL_INSTRUCTIONS OUT NOCOPY NUMBER,
    X_OPTIONAL_PENDING_INSTR OUT NOCOPY NUMBER,
    X_MANDATORY_PENDING_INSTR OUT NOCOPY NUMBER,
    X_RETURN_STATUS OUT NOCOPY VARCHAR2,
    X_MSG_COUNT                 OUT NOCOPY NUMBER,
    X_MSG_DATA                  OUT NOCOPY VARCHAR2
);

-- This API is checks if there are any pending instructions for
-- the given entity name, key and instruction type on instance
-- process / temporary tables

-- Start of comments
-- API name             : HAS_PENDING_INSTR_FOR_PROCESS
-- Type                 : Private API
-- Function             : Gets number of pending instructions on
--                        particular process id

-- Pre-reqs             : None

-- Parameters

-- P_INSTRUCTION_PROCESS_ID  The instruction process id
-- X_INSTRUCTION_PENDING   'Y' if there are pending instructions
--                         'N' otherwise

-- X_TOTAL_INSTRUCTIONS      Total number of instructions for entity
-- X_OPTIONAL_PENDING_INSTR  Number of optional instructions pending
-- X_MANDATORY_PENDING_INSTR Number of mandatory instructions pending

-- X_RETURN_STATUS         The return status based on standard API convention
-- X_MSG_COUNT             Message count
-- X_MSG_DATA              Return messages

-- End of comments

PROCEDURE HAS_PENDING_INSTR_FOR_PROCESS
(
    P_INSTRUCTION_PROCESS_ID IN VARCHAR2,
    X_INSTRUCTION_PENDING OUT NOCOPY VARCHAR2,
    X_TOTAL_INSTRUCTIONS OUT NOCOPY NUMBER,
    X_OPTIONAL_PENDING_INSTR OUT NOCOPY NUMBER,
    X_MANDATORY_PENDING_INSTR OUT NOCOPY NUMBER,
    X_RETURN_STATUS OUT NOCOPY VARCHAR2,
    X_MSG_COUNT                 OUT NOCOPY NUMBER,
    X_MSG_DATA                  OUT NOCOPY VARCHAR2
);

-- This API is called to send the instance acknowledgment
-- It acknowledges the instruction set and copies the temporary
-- data to permenant instance tables. It also marks all DONE instructions
-- to COMPLETE

-- Start of comments
-- API name             : SEND_INSTANCE_ACKN
-- Type                 : Private API
-- Function             : Send instance acknowledgment

-- Pre-reqs             : None
-- Parameters

-- P_API_VERSION	   API Version
-- P_INIT_MSG_LIST         Initialize message list default = FALSE
-- P_VALIDATION_LEVEL	   Default validation level = FULL

-- P_INSTRUCTION_PROCESS_ID  The instruction process id
-- P_ENTITY_NAME	     The instance entity name
-- P_ENTITY_KEY              The instance entity key

-- X_RETURN_STATUS         The return status based on standard API convention
-- X_MSG_COUNT             Message count
-- X_MSG_DATA              Return messages

-- End of comments

PROCEDURE SEND_INSTANCE_ACKN
(
    P_INSTRUCTION_PROCESS_ID IN NUMBER,
    P_ENTITY_NAME IN VARCHAR2,
    P_ENTITY_KEY IN VARCHAR2,
    X_RETURN_STATUS OUT NOCOPY VARCHAR2,
    X_MSG_COUNT                 OUT NOCOPY NUMBER,
    X_MSG_DATA                  OUT NOCOPY VARCHAR2
);

-- This API is called to send the task acknowledgment
-- It acknowledges the task identifier, value and e-record
-- id into the GMO_INSTR_TASK_INSTANCE_T table

-- Start of comments
-- API name             : SEND_TASK_ACKN
-- Type                 : Private API
-- Function             : Send task acknowledgment

-- Pre-reqs             : None
-- Parameters

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
    P_INSTRUCTION_ID IN NUMBER,
    P_INSTRUCTION_PROCESS_ID IN NUMBER,
    P_ENTITY_KEY IN VARCHAR2 DEFAULT NULL,
    P_TASK_ERECORD_ID  IN FND_TABLE_OF_VARCHAR2_255,
    P_TASK_IDENTIFIER IN FND_TABLE_OF_VARCHAR2_255,
    P_TASK_VALUE IN FND_TABLE_OF_VARCHAR2_255,
    P_DISABLE_TASK IN VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.NO,
    P_MANUAL_ENTRY IN VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.NO,
    X_RETURN_STATUS OUT NOCOPY VARCHAR2,
    X_MSG_COUNT                 OUT NOCOPY NUMBER,
    X_MSG_DATA                  OUT NOCOPY VARCHAR2
);

-- This API marks the instruction set as CANCEL

-- Start of comments
-- API name             : NULLIFY_INSTR_FOR_ENTITY
-- Type                 : Private API
-- Function             : Nullifies instructions for entity

-- Pre-reqs             : None
-- Parameters


-- P_ENTITY_NAME           The INSTANCE entity name
-- P_ENTITY_KEY            The instance entity key
-- P_INSTRUCTION_TYPE      The instruction type

-- X_RETURN_STATUS         The return status based on standard API convention
-- X_MSG_COUNT             Message count
-- X_MSG_DATA              Return messages

-- End of comments

PROCEDURE NULLIFY_INSTR_FOR_ENTITY
(
    P_ENTITY_NAME IN VARCHAR2,
    P_ENTITY_KEY IN VARCHAR2,
    P_INSTRUCTION_TYPE IN VARCHAR2,
    X_RETURN_STATUS OUT NOCOPY VARCHAR2,
    X_MSG_COUNT     OUT NOCOPY NUMBER,
    X_MSG_DATA      OUT NOCOPY VARCHAR2
);

-- This API will mark all the optional instructions as complete

-- Start of comments
-- API name             : COMPLETE_OPTIONAL_INSTR
-- Type                 : Private API
-- Function             : mark all the optional instructions as complete
-- Pre-reqs             : None
-- Parameters


-- P_INSTRUCTION_PROCESS_ID  The Instruction Process Id
-- X_RETURN_STATUS         The return status based on standard API convention
-- X_MSG_COUNT             Message count
-- X_MSG_DATA              Return messages

-- End of comments

PROCEDURE COMPLETE_OPTIONAL_INSTR
(
    P_INSTRUCTION_PROCESS_ID IN NUMBER,
    X_RETURN_STATUS OUT NOCOPY VARCHAR2,
    X_MSG_COUNT     OUT NOCOPY NUMBER,
    X_MSG_DATA      OUT NOCOPY VARCHAR2
);


-- This API will get the definition status := MODIFIED | NO_CHANGE

-- Start of comments
-- API name             : GET_DEFN_STATUS
-- Type                 : Private API
-- Function             : get the definition status := MODIFIED | NO_CHANGE
-- Pre-reqs             : None
-- Parameters

-- P_INSTRUCTION_PROCESS_ID The definition time instruction_process_id
-- X_DEFINITION_STATUS      The definition status for given process id

-- X_RETURN_STATUS         The return status based on standard API convention
-- X_MSG_COUNT             Message count
-- X_MSG_DATA              Return messages

-- End of comments

PROCEDURE GET_DEFN_STATUS
(
    P_INSTRUCTION_PROCESS_ID IN NUMBER,
    X_DEFINITION_STATUS OUT NOCOPY VARCHAR2,
    X_RETURN_STATUS OUT NOCOPY VARCHAR2,
    X_MSG_COUNT OUT NOCOPY NUMBER,
    X_MSG_DATA  OUT NOCOPY VARCHAR2
);

-- This API will get the instance status := UNACKNOWLEDGED | ACKNOWLEDGED

-- Start of comments
-- API name             : GET_INSTANCE_STATUS
-- Type                 : Private API
-- Function             : get the instance tatus := UNACKNOWLEDGED | ACKNOWLEDGED
-- Pre-reqs             : None
-- Parameters

-- P_INSTRUCTION_PROCESS_ID The runtime instruction_process_id
-- X_DEFINITION_STATUS      The instance status for given process id

-- X_RETURN_STATUS         The return status based on standard API convention
-- X_MSG_COUNT             Message count
-- X_MSG_DATA              Return messages

-- End of comments

PROCEDURE GET_INSTANCE_STATUS
(
    P_INSTRUCTION_PROCESS_ID IN NUMBER,
    X_INSTANCE_STATUS OUT NOCOPY VARCHAR2,
    X_RETURN_STATUS OUT NOCOPY VARCHAR2,
    X_MSG_COUNT OUT NOCOPY NUMBER,
    X_MSG_DATA  OUT NOCOPY VARCHAR2
);

-- This API will capture the operator response and store it in Instance Temp Table

-- Start of comments
-- API name             : CAPTURE_OPERATOR_RESPONSE
-- Type                 : Private API
-- Function             : Capture operator response
-- Pre-reqs             : None
-- Parameters

-- IN  P_INSTRUCTION_PROCESS_ID : The runtime instruction_process_id
-- IN  P_INSTRUCTION_ID         : The instruction id of current instruction
-- IN  P_OPERATOR_ACKN          : The Operator Acknowledgment flag = Y or N
-- IN  P_INSTR_COMMENTS         : Instruction Comments entered by operator
-- IN  P_INSTR_STATUS           : Instruction Status

-- OUT X_RETURN_STATUS          : The return status based on standard API convention

-- End of comments

PROCEDURE CAPTURE_OPERATOR_RESPONSE
(
    P_INSTRUCTION_ID IN NUMBER,
    P_INSTRUCTION_PROCESS_ID IN NUMBER,
    P_OPERATOR_ACKN IN VARCHAR2,
    P_INSTR_COMMENTS IN VARCHAR2,
    P_INSTR_STATUS IN VARCHAR2,
    X_RETURN_STATUS OUT NOCOPY VARCHAR2
);

-- This API inserts instruction e-record details in e-records table

-- Start of comments
-- API name             : GET_INSTANCE_STATUS
-- Type                 : Private API
-- Function             : get the instance tatus := UNACKNOWLEDGED | ACKNOWLEDGED
-- Pre-reqs             : None
-- Parameters

-- IN  P_INSTRUCTION_PROCESS_ID : The runtime instruction_process_id
-- IN  P_INSTRUCTION_ID         : The instruction id of current instruction
-- IN  P_ERECORD_ID             : The instruction e-record Id

-- OUT X_RETURN_STATUS          : The return status based on standard API convention
-- OUT X_MSG_COUNT              : Message count
-- OUT X_MSG_DATA               : Return messages

-- End of comments

PROCEDURE INSERT_ERECORD_DETAILS
(
    P_INSTRUCTION_ID IN NUMBER,
    P_INSTRUCTION_PROCESS_ID IN NUMBER,
    P_INSTRUCTION_ERECORD_ID IN NUMBER,
    X_RETURN_STATUS OUT NOCOPY VARCHAR2,
    X_MSG_COUNT OUT NOCOPY VARCHAR2,
    X_MSG_DATA OUT NOCOPY VARCHAR2
);

-- This API creates instance context when called by entity application
-- and returns an Instruction Process Id

-- Start of comments
-- API name             : CREATE_INSTANCE_CONTEXT
-- Type                 : Private API
-- Function             : Create temporary instance for execution purposes
-- Pre-reqs             : None
-- Parameters

-- IN  P_ENTITY_NAME            : The Entity Name
-- IN  P_ENTITY_KEY             : The Entity Key
-- IN  P_INSTRUCTION_TYPE       : The Instruction Type
-- IN  P_CONTEXT_PARAM_NAME     : Context parameter name
-- IN  P_CONTEXT_PARAM_VALUE    : Context parameter value

-- OUT X_INSTRUCTION_PROCESS_ID : The runtime instruction_process_id
-- OUT X_RETURN_STATUS          : The return status based on standard API convention
-- OUT X_ERR_CODE               : SQL Error Code
-- OUT X_ERR_MSG                : Error message

-- End of comments

PROCEDURE CREATE_INSTANCE_CONTEXT
(
    P_ENTITY_NAME IN VARCHAR2,
    P_ENTITY_KEY IN VARCHAR2,
    P_INSTRUCTION_TYPE IN VARCHAR2,
    P_CONTEXT_PARAM_NAME IN FND_TABLE_OF_VARCHAR2_255,
    P_CONTEXT_PARAM_VALUE IN FND_TABLE_OF_VARCHAR2_255,
    X_INSTRUCTION_PROCESS_ID OUT NOCOPY NUMBER,
    X_INSTRUCTION_SET_ID OUT NOCOPY NUMBER,
    X_RETURN_STATUS OUT NOCOPY VARCHAR2,
    X_MSG_COUNT OUT NOCOPY NUMBER,
    X_MSG_DATA OUT NOCOPY VARCHAR2
);

-- This API creates instance context when called by entity application
-- and returns an Instruction Process Id

-- Start of comments
-- API name             : CREATE_INSTANCE_CONTEXT
-- Type                 : Private API
-- Function             : Create temporary instance for execution purposes
-- Pre-reqs             : None
-- Parameters

-- IN  P_INSTRUCTION_SET_ID     : The Instance Instruction Set Id

-- IN  P_CONTEXT_PARAM_NAME     : Context parameter name
-- IN  P_CONTEXT_PARAM_VALUE    : Context parameter value

-- OUT X_ENTITY_NAME            : The Entity Name
-- OUT X_ENTITY_KEY             : The Entity Key
-- OUT X_INSTRUCTION_TYPE       : The Instruction Type
-- OUT X_INSTRUCTION_PROCESS_ID : The runtime instruction_process_id
-- OUT X_RETURN_STATUS          : The return status based on standard API convention
-- OUT X_ERR_CODE               : SQL Error Code
-- OUT X_ERR_MSG                : Error message

-- End of comments

PROCEDURE CREATE_INSTANCE_CONTEXT
(
    P_INSTRUCTION_SET_ID IN NUMBER,
    P_CONTEXT_PARAM_NAME IN FND_TABLE_OF_VARCHAR2_255,
    P_CONTEXT_PARAM_VALUE IN FND_TABLE_OF_VARCHAR2_255,
    X_INSTRUCTION_PROCESS_ID OUT NOCOPY NUMBER,
    X_ENTITY_NAME OUT NOCOPY VARCHAR2,
    X_ENTITY_KEY OUT NOCOPY VARCHAR2,
    X_INSTRUCTION_TYPE OUT NOCOPY VARCHAR2,
    X_RETURN_STATUS OUT NOCOPY VARCHAR2,
    X_MSG_COUNT OUT NOCOPY NUMBER,
    X_MSG_DATA OUT NOCOPY VARCHAR2
);

-- This API updates the definition status to ERROR or SUCCESS or CANCEL

-- Start of comments
-- API name             : UPDATE_INSTR_ATTRIBUTES
-- Type                 : Private API
-- Function             : Update definition process status
-- Pre-reqs             : None
-- Parameters

-- P_INSTRUCTION_PROCESS_ID  : The runtime instruction_process_id
-- P_UPDATE_DEFN_STATUS      : The definition status

-- End of comments

PROCEDURE UPDATE_INSTR_ATTRIBUTES(P_INSTRUCTION_PROCESS_ID IN VARCHAR2,
                                  P_UPDATE_DEFN_STATUS     IN VARCHAR2);


-- This API sets the instruction status attribute values for the specified
-- instruction process ID.

-- Start of comments
-- API name             : SET_INSTR_STATUS_ATTRIBUTES
-- Type                 : Private API
-- Function             : Update definition process status
-- Pre-reqs             : None
-- Parameters

-- P_INSTRUCTION_PROCESS_ID  : The runtime instruction_process_id
-- P_UPDATE_DEFN_STATUS      : The definition status

-- End of comments

PROCEDURE SET_INSTR_STATUS_ATTRIBUTES(P_INSTRUCTION_PROCESS_ID IN VARCHAR2,
                                          P_UPDATE_DEFN_STATUS     IN VARCHAR2);

-- This API deletes all the data for given instruction process id
-- from temporary tables

-- Start of comments
-- API name             : DELETE_INSTR_SET_DETAILS
-- Type                 : Private API
-- Function             : Delete temp data from process tables at definition time
-- Pre-reqs             : None
-- Parameters

-- P_INSTRUCTION_PROCESS_ID  : The runtime instruction_process_id

-- End of comments

PROCEDURE DELETE_INSTR_SET_DETAILS(P_INSTRUCTION_PROCESS_ID IN VARCHAR2);

-- This API gets the value of temporary variable
-- from temporary tables

-- Start of comments
-- API name             : GET_PROCESS_VARIABLE
-- Type                 : Private API
-- Function             : Gets value of process variable
-- Pre-reqs             : None
-- Parameters

-- P_INSTRUCTION_PROCESS_ID  : The runtime instruction_process_id
-- P_ATTRIBUTE_NAME          : Name of process variable
-- P_ATTRIBUTE_TYPE          : Type of process variable

-- End of comments

FUNCTION GET_PROCESS_VARIABLE
(
  P_INSTRUCTION_PROCESS_ID IN NUMBER ,
  P_ATTRIBUTE_NAME IN  VARCHAR2 ,
  P_ATTRIBUTE_TYPE IN VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.G_PARAM_INTERNAL
)
RETURN VARCHAR2;

-- This API inserts name and value of temporary variable
-- into temporary tables, alongwith type

-- Start of comments
-- API name             : INSERT_PROCESS_VARIABLE
-- Type                 : Private API
-- Function             : Gets value of process variable
-- Pre-reqs             : None
-- Parameters

-- P_INSTRUCTION_PROCESS_ID  : The runtime instruction_process_id
-- P_ATTRIBUTE_NAME          : Name of process variable
-- P_ATTRIBUTE_VALUE         : Value of process variable
-- P_ATTRIBUTE_TYPE          : Type of process variable

-- End of comments

FUNCTION INSERT_PROCESS_VARIABLE
(
  P_INSTRUCTION_PROCESS_ID IN NUMBER ,
  P_ATTRIBUTE_NAME IN VARCHAR2 ,
  P_ATTRIBUTE_VALUE IN VARCHAR2,
  P_ATTRIBUTE_TYPE IN VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.G_PARAM_INTERNAL
)
RETURN VARCHAR2;

-- This API inserts / updates name and value of temporary variable
-- into temporary tables, alongwith type

-- Start of comments
-- API name             : SET_PROCESS_VARIABLE
-- Type                 : Private API
-- Function             : Gets value of process variable
-- Pre-reqs             : None
-- Parameters

-- P_INSTRUCTION_PROCESS_ID  : The runtime instruction_process_id
-- P_ATTRIBUTE_NAME          : Name of process variable
-- P_ATTRIBUTE_VALUE         : Value of process variable
-- P_ATTRIBUTE_TYPE          : Type of process variable

-- End of comments

FUNCTION SET_PROCESS_VARIABLE
( P_INSTRUCTION_PROCESS_ID IN NUMBER ,
  P_ATTRIBUTE_NAME IN VARCHAR2 ,
  P_ATTRIBUTE_VALUE IN VARCHAR2,
  P_ATTRIBUTE_TYPE IN VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.G_PARAM_INTERNAL
 )
RETURN VARCHAR2;

-- This API inserts / updates name and value of temporary variable
-- into temporary tables, alongwith type

-- Start of comments
-- API name             : SET_PROCESS_VARIABLE
-- Type                 : Private API
-- Function             : Gets value of process variable
-- Pre-reqs             : None
-- Parameters

-- P_INSTRUCTION_PROCESS_ID  : The runtime instruction_process_id
-- P_ATTRIBUTE_NAME          : Name of process variable
-- P_ATTRIBUTE_VALUE         : Value of process variable
-- P_ATTRIBUTE_TYPE          : Type of process variable

-- End of comments

FUNCTION SET_PROCESS_ATTRIBUTES
(
   P_INSTRUCTION_PROCESS_ID IN NUMBER,
   P_ATTRIBUTE_NAME IN FND_TABLE_OF_VARCHAR2_255,
   P_ATTRIBUTE_VALUE IN FND_TABLE_OF_VARCHAR2_255,
   P_ATTRIBUTE_TYPE IN VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.G_PARAM_INTERNAL
)
RETURN VARCHAR2;

-- This API validates the input e-record id's using ERES Public API

-- Start of comments
-- API name             : VALIDATE_TASK_ERECORD_ID
-- Type                 : Private API
-- Function             : Validates the input e-record id
-- Pre-reqs             : None
-- Parameters

-- P_TASk_ERECORD_ID         : Table of e-record id's
-- X_ERECORD_ID_INVALID      : Y if there is any invalid e-record id, other wise N
-- X_ERECORD_LIST_STR        : List of invalid e-record id's

-- OUT X_RETURN_STATUS          : The return status based on standard API convention
-- OUT X_MSG_COUNT              : Message count
-- OUT X_MSG_DATA               : Return messages

-- End of comments

PROCEDURE VALIDATE_TASK_ERECORD_ID (
  P_TASK_ERECORD_ID   IN FND_TABLE_OF_VARCHAR2_255,
  X_ERECORD_ID_INVALID OUT NOCOPY VARCHAR2,
  X_ERECORD_LIST_STR OUT NOCOPY VARCHAR2,
  X_RETURN_STATUS  OUT NOCOPY VARCHAR2,
  X_MSG_COUNT  OUT NOCOPY NUMBER,
  X_MSG_DATA  OUT NOCOPY VARCHAR2
);

-- Start of comments
-- API name             : GET_INSTR_XML
-- Type                 : Private
-- Function             : This procedure returns the instruction set and all the related instruction details
--                      : in XML format for the specified instruction process ID.
-- Pre-reqs             : None
--
-- Parameters
-- IN                   : P_INSTRUCTION_PROCESS_ID  - The instruction process ID.
-- OUT                  : X_OUTPUT_XML              - The final XML.

-- End of comments

PROCEDURE GET_INSTR_XML( P_INSTRUCTION_PROCESS_ID IN NUMBER,
                          X_OUTPUT_XML             OUT NOCOPY CLOB
			);


-- Start of comments
-- API name             : GET_TASK_PARAMETER
-- Type                 : Private
-- Function             : This function returns the task parameter
-- Pre-reqs             : None
--
-- Parameters
-- IN                   : P_INSTRUCTION_PROCESS_ID  - The instruction process ID.
-- OUT                  : P_ATTRIBUTE_NAME          - The attribute name

-- End of comments

FUNCTION GET_TASK_PARAMETER
(
  P_INSTRUCTION_PROCESS_ID IN NUMBER,
  P_ATTRIBUTE_NAME IN VARCHAR2
)
RETURN VARCHAR2;

-- Start of comments

-- API name             : ADD_INSTRUCTIONS
-- Type                 : Private
-- Function             : This procedure appends instructions after the instruction id specified in P_INSTRUCTION_ID
-- Pre-reqs             : None
--
-- Parameters
-- IN                   : P_INSTRUCTION_PROCESS_ID  - The instruction process ID.
-- IN                   : P_INSTRUCTION_ID          - Instruction id after which to add new instructions.
-- IN                   : P_INSTRUCTION_SET_ID      - Instruction set id
-- IN                   : P_ADD_MODE                - MOde of addition AFTER or BEFORE
-- IN                   : P_INSTRUCTION_NOS         - The instruction numbers to be set.

-- X_RETURN_STATUS      :  The return status based on standard API convention
-- X_MSG_COUNT          :  Message count
-- X_MSG_DATA           :  Return messages

-- End of comments

PROCEDURE ADD_INSTRUCTIONS
(
       P_INSTRUCTION_PROCESS_ID IN NUMBER,
       P_INSTRUCTION_SET_ID IN NUMBER,
       P_INSTRUCTION_ID IN NUMBER,
       P_ADD_MODE IN VARCHAR2,
       P_INSTRUCTIONS IN FND_TABLE_OF_VARCHAR2_255,
       P_INSTRUCTION_NOS IN FND_TABLE_OF_VARCHAR2_255,
       X_RETURN_STATUS OUT NOCOPY VARCHAR2,
       X_MSG_COUNT OUT NOCOPY NUMBER,
       X_MSG_DATA OUT NOCOPY VARCHAR2
);


-- Start of comments
-- API name             : GET_INSTR_INSTANCE_XML
-- Type                 : Private Function.
-- Function             : This function is used to obtain the instance details of instructions in XML format for the
--                        specified instruction process ID.
-- Pre-reqs             : None
--
-- IN                   : P_INSTRUCTION_PROCESS_ID - The instruction process ID
--
-- OUT                   : X_OUTPUT_XML - The instance instruction details in XML format.
--End of comments

PROCEDURE GET_INSTR_INSTANCE_XML
(
   P_INSTRUCTION_PROCESS_ID IN NUMBER,
   X_OUTPUT_XML OUT NOCOPY CLOB
);

-- Start of comments
-- API name             : TERMINATE_INSTR_DEFN_PROCESS
-- Type                 : Private Procedure.
-- Function             : This procedure is used to terminate the instruction definition process identified by the
--                        specified process ID.
-- Pre-reqs             : None
--
-- IN                   : P_INSTRUCTION_PROCESS_ID - The instruction process ID
--End of comments
PROCEDURE TERMINATE_INSTR_DEFN_PROCESS
(P_INSTRUCTION_PROCESS_ID NUMBER);

--Bug 5383022: start

-- Start of comments
-- API name             : is_task_attribute_used
-- Type                 : Private Procedure.
-- Function             : This procedure is used to check if the task attribute is used
-- Pre-reqs             : None
--
-- IN                   : P_INSTRUCTION_PROCESS_ID - The instruction process ID
--                        p_attribute_name - attribute name
--                        p_attribute_key - attribute key
-- OUT                  : x_used_flag - used flag
--                        x_return_status - return status
--                        x_msg_count - message count
--                        x_msg_data - message data
--End of comments

procedure is_task_attribute_used
(
	p_instruction_process_id IN number,
	p_attribute_name IN varchar2,
	p_attribute_key IN varchar2,
	x_used_flag OUT NOCOPY varchar2,
	x_return_status OUT NOCOPY varchar2,
	x_msg_count OUT NOCOPY number,
	x_msg_data OUT NOCOPY varchar2
);

--Bug 5383022: end

END GMO_INSTRUCTION_PVT;

 

/
