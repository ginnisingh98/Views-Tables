--------------------------------------------------------
--  DDL for Package GMO_DOCUMENT_NUMBERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMO_DOCUMENT_NUMBERS_PVT" 
/* $Header: GMOVDNMS.pls 120.3 2006/01/19 09:22 swasubra noship $ */

AUTHID CURRENT_USER AS

--The package name
G_PKG_NAME           CONSTANT VARCHAR2(30) := 'GMO_DOCUMENT_NUMBERS_PVT';

--This PROCEDURE is used to obtain the document number type associated with the
--specified organization ID and transaction type.
PROCEDURE GET_DOCUMENT_NUMBER_TYPE
(P_ORGANIZATION_ID      IN         NUMBER,
 P_TRANSACTION_TYPE     IN         VARCHAR2,
 P_INIT_MSG_LIST        IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
 X_DOCUMENT_NUMBER_TYPE OUT NOCOPY VARCHAR2,
 X_RETURN_STATUS        OUT NOCOPY VARCHAR2,
 X_MSG_COUNT            OUT NOCOPY NUMBER,
 X_MSG_DATA             OUT NOCOPY VARCHAR2);


--This PROCEDURE is used to obtain the next document number in sequence associated with the
--specified organization ID and transaction type.
PROCEDURE GET_NEXT_VALUE
(P_ORGANIZATION_ID    IN         NUMBER,
 P_TRANSACTION_TYPE   IN         VARCHAR2,
 P_INIT_MSG_LIST      IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
 X_VALUE              OUT NOCOPY VARCHAR2,
 X_RETURN_STATUS      OUT NOCOPY VARCHAR2,
 X_MSG_COUNT          OUT NOCOPY NUMBER,
 X_MSG_DATA           OUT NOCOPY VARCHAR2);

--This procedure is used to check if a document number entry exists for the specified
--organization and transaction type.
PROCEDURE DOES_DOCUMENT_NUMBER_EXIST
(P_ORGANIZATION_ID        IN         NUMBER,
 P_TRANSACTION_TYPE       IN         VARCHAR2,
 P_INIT_MSG_LIST          IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
 X_DOCUMENT_NUMBER_EXISTS OUT NOCOPY VARCHAR2,
 X_RETURN_STATUS          OUT NOCOPY VARCHAR2,
 X_MSG_COUNT              OUT NOCOPY NUMBER,
 X_MSG_DATA               OUT NOCOPY VARCHAR2);

END GMO_DOCUMENT_NUMBERS_PVT;

 

/
