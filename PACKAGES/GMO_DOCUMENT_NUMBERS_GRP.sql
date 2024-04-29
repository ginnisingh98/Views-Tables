--------------------------------------------------------
--  DDL for Package GMO_DOCUMENT_NUMBERS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMO_DOCUMENT_NUMBERS_GRP" 
/* $Header: GMOGDNMS.pls 120.4 2006/01/19 09:26 swasubra noship $ */

AUTHID CURRENT_USER AS

--The package name
G_PKG_NAME           CONSTANT VARCHAR2(30) := 'GMO_DOCUMENT_NUMBERS_GRP';

--This constant represents the valus of the zero pad option when padding used.
G_ZERO_PAD_YES       CONSTANT VARCHAR2(1) := 'Y';

--This constant represents the value of the zero pad option when padding is not used.
G_ZERO_PAD_NO        CONSTANT VARCHAR2(1) := 'N';

--This constant represents the value of the doc type when it set to automatic.
G_DOC_TYPE_AUTOMATIC CONSTANT VARCHAR2(1) := 'A';

--This constant represents the value of the doc type when it set to manual.
G_DOC_TYPE_MANUAL    CONSTANT VARCHAR2(1) := 'M';


-- Start of comments
-- API name             : GET_DOCUMENT_NUMBER_TYPE
-- Type                 : Public.
-- Function             : This PROCEDURE is used to obtain the document number type associated with the
--                        specified organization ID and transaction type.
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   :P_API_VERSION(Required)      - NUMBER   - Specifies the API version.

--                       P_INIT_MSG_LIST(Optional)    - VARCHAR2 - Specifies if the message list should be initialized.
--                       Default = FND_API.G_FALSE

--                       P_ORGANIZATION_ID(Optional)  - NUMBER   - The organization ID representing the transaction.
--
--                       P_TRANSACTION_TYPE(Required) - VARCHAR2 - The transaction type.

-- OUT                  :X_RETURN_STATUS              - VARCHAR2 - The return status.
--                       X_MSG_COUNT                  - NUMBER   - The message count.
--                       X_MSG_DATA                   - VARCHAR2 - The message data.
--
--                       X_DOCUMENT_NUMBER_TYPE       - VARCHAR2 - The document number type.
--
-- Version              :Current version        1.0
--                       Initial version        1.0
--
-- End of comments
PROCEDURE GET_DOCUMENT_NUMBER_TYPE
(P_API_VERSION          IN         NUMBER,
 P_INIT_MSG_LIST        IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
 X_RETURN_STATUS        OUT NOCOPY VARCHAR2,
 X_MSG_COUNT            OUT NOCOPY NUMBER,
 X_MSG_DATA             OUT NOCOPY VARCHAR2,
 P_ORGANIZATION_ID      IN         NUMBER,
 P_TRANSACTION_TYPE     IN         VARCHAR2,
 X_DOCUMENT_NUMBER_TYPE OUT NOCOPY VARCHAR2);



-- Start of comments
-- API name             : GET_VALUE
-- Type                 : Public.
-- Function             : This PROCEDURE is used to obtain the next document number in sequence associated with the
--                        specified organization ID and transaction type.
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   :P_API_VERSION(Required)      - NUMBER   - Specifies the API version.

--                       P_INIT_MSG_LIST(Optional)    - VARCHAR2 - Specifies if the message list should be initialized.
--                       Default = FND_API.G_FALSE

--                       P_ORGANIZATION_ID(Optional)  - NUMBER   - The organization ID representing the transaction.
--
--                       P_TRANSACTION_TYPE(Required) - VARCHAR2 - The transaction type.

-- OUT                  :X_RETURN_STATUS              - VARCHAR2 - The return status.
--                       X_MSG_COUNT                  - NUMBER   - The message count.
--                       X_MSG_DATA                   - VARCHAR2 - The message data.
--
--                       X_VALUE                      - VARCHAR2 - The next document number in sequence.
--
-- Version              :Current version        1.0
--                       Initial version        1.0
--
-- End of comments
PROCEDURE GET_NEXT_VALUE
(P_API_VERSION        IN         NUMBER,
 P_INIT_MSG_LIST      IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
 X_RETURN_STATUS      OUT NOCOPY VARCHAR2,
 X_MSG_COUNT          OUT NOCOPY NUMBER,
 X_MSG_DATA           OUT NOCOPY VARCHAR2,
 P_ORGANIZATION_ID    IN  NUMBER,
 P_TRANSACTION_TYPE   IN  VARCHAR2,
 X_VALUE              OUT NOCOPY VARCHAR2);


-- Start of comments
-- API name             : DOES_DOCUMENT_NUMBER_EXIST
-- Type                 : Public.
-- Function             : This procedure is used to check if a document number entry exists for the specified
--                        organization and transaction type.

-- Pre-reqs             : None.
-- Parameters           :
-- IN                   :P_API_VERSION(Required)      - NUMBER   - Specifies the API version.

--                       P_INIT_MSG_LIST(Optional)    - VARCHAR2 - Specifies if the message list should be initialized.
--                       Default = FND_API.G_FALSE

--                       P_ORGANIZATION_ID(Optional)  - NUMBER   - The organization ID representing the transaction.
--
--                       P_TRANSACTION_TYPE(Required) - VARCHAR2 - The transaction type.

-- OUT                  :X_RETURN_STATUS              - VARCHAR2 - The return status.
--                       X_MSG_COUNT                  - NUMBER   - The message count.
--                       X_MSG_DATA                   - VARCHAR2 - The message data.
--
--                       X_DOCUMENT_NUMBER_EXISTS     - VARCHAR2 - A flag that indicates if a document number exists for the specified
--                                                                 organization and transaction type.
--
-- Version              :Current version        1.0
--                       Initial version        1.0
--
-- End of comments
PROCEDURE DOES_DOCUMENT_NUMBER_EXIST
(P_API_VERSION            IN         NUMBER,
 P_INIT_MSG_LIST          IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
 X_RETURN_STATUS          OUT NOCOPY VARCHAR2,
 X_MSG_COUNT              OUT NOCOPY NUMBER,
 X_MSG_DATA               OUT NOCOPY VARCHAR2,
 P_ORGANIZATION_ID        IN         NUMBER,
 P_TRANSACTION_TYPE       IN         VARCHAR2,
 X_DOCUMENT_NUMBER_EXISTS OUT NOCOPY VARCHAR2);


END GMO_DOCUMENT_NUMBERS_GRP;

 

/
