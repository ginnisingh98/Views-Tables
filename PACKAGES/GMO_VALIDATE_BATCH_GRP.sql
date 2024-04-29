--------------------------------------------------------
--  DDL for Package GMO_VALIDATE_BATCH_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMO_VALIDATE_BATCH_GRP" 
/* $Header: GMOBAVAS.pls 120.2 2006/02/23 03:17:37 srpuri noship $ */
AUTHID CURRENT_USER AS

--The package name
G_PKG_NAME           CONSTANT VARCHAR2(30) := 'GMO_VALIDATE_BATCH_GRP';





-- Start of comments
-- API name             : VALIDATE_BATCH_COMPLIANCE
-- Type                 : Public.

-- Function             : This procedure implements the following:
--                        1. Validates the batch ID or batch step ID. If validation fails it returns an error status.

--                        2. Navigates through the batch hierarchy to identify any pending instructions.
--                           If pending instructions

--                           do exist then an entry is made for the same in the Audit table.
--                        3. Navigates through the batch hierarchy to identify any pending deviations and audits the same.

--                        4. Returns a unique validation ID and a validation status back to the calling program.


-- Pre-reqs             : None.
-- Parameters           :
-- IN                   :P_API_VERSION(Required)      - NUMBER   - Specifies the API version.

--                       P_INIT_MSG_LIST(Optional)    - VARCHAR2 - Specifies if the message list should be initialized.

--                       Default = FND_API.G_FALSE

--                       P_ENTITY_NAME(Required)      - VARCHAR2 - The entity to be validated. It takes only the following values.

--                       - 1. GMO_CONSTANTS_GRP.ENTITY_BATCH for validating a batch

--                       - 2. GMO_CONSTANTS_GRP.ENTITY_OPERATION for validating a batch step.

--                       - If any other value is provided then the API will error out.


PROCEDURE VALIDATE_BATCH_COMPLIANCE
(P_API_VERSION          IN         NUMBER,
 P_INIT_MSG_LIST        IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
 X_RETURN_STATUS        OUT NOCOPY VARCHAR2,
 X_MSG_COUNT            OUT NOCOPY NUMBER,
 X_MSG_DATA             OUT NOCOPY VARCHAR2,
 P_ENTITY_NAME          IN         VARCHAR2,
 P_ENTITY_KEY           IN         VARCHAR2,
 X_VALIDATION_ID        OUT NOCOPY NUMBER,
 X_VALIDATION_STATUS    OUT NOCOPY VARCHAR2);

END GMO_VALIDATE_BATCH_GRP;

 

/
