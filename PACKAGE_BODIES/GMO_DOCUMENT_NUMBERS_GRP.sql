--------------------------------------------------------
--  DDL for Package Body GMO_DOCUMENT_NUMBERS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_DOCUMENT_NUMBERS_GRP" AS
/* $Header: GMOGDNMB.pls 120.3 2006/01/19 09:27 swasubra noship $ */

--This PROCEDURE is used to obtain the document number type associated with the
--specified organization ID and transaction type.
PROCEDURE GET_DOCUMENT_NUMBER_TYPE
(P_API_VERSION          IN         NUMBER,
 P_INIT_MSG_LIST        IN         VARCHAR2,
 X_RETURN_STATUS        OUT NOCOPY VARCHAR2,
 X_MSG_COUNT            OUT NOCOPY NUMBER,
 X_MSG_DATA             OUT NOCOPY VARCHAR2,
 P_ORGANIZATION_ID      IN         NUMBER,
 P_TRANSACTION_TYPE     IN         VARCHAR2,
 X_DOCUMENT_NUMBER_TYPE OUT NOCOPY VARCHAR2)

IS

--The API name.
L_API_NAME           CONSTANT VARCHAR2(30) := 'GET_DOCUMENT_NUMBER_TYPE';

--The API version.
L_API_VERSION        CONSTANT NUMBER   := 1.0;

BEGIN

  --Validate the API versions.
  IF NOT FND_API.COMPATIBLE_API_CALL(L_API_VERSION,
                                     P_API_VERSION,
                                     L_API_NAME,
                                     G_PKG_NAME)
  THEN

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

  --Initialize the message list if specified so.
  IF FND_API.TO_BOOLEAN( P_INIT_MSG_LIST ) THEN

    FND_MSG_PUB.INITIALIZE;

  END IF;

  --Call a private API to obtain the document number type.
  GMO_DOCUMENT_NUMBERS_PVT.GET_DOCUMENT_NUMBER_TYPE
  (P_ORGANIZATION_ID      => P_ORGANIZATION_ID,
   P_TRANSACTION_TYPE     => P_TRANSACTION_TYPE,
   P_INIT_MSG_LIST        => P_INIT_MSG_LIST,
   X_DOCUMENT_NUMBER_TYPE => X_DOCUMENT_NUMBER_TYPE,
   X_RETURN_STATUS        => X_RETURN_STATUS,
   X_MSG_COUNT            => X_MSG_COUNT,
   X_MSG_DATA             => X_MSG_DATA);


  --Get the message count.
  --If count is 1, then get the message data.
  FND_MSG_PUB.COUNT_AND_GET
  (P_COUNT => X_MSG_COUNT,
   P_DATA  => X_MSG_DATA);


EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR ;

    FND_MSG_PUB.COUNT_AND_GET
    (P_COUNT => X_MSG_COUNT,
     P_DATA  => X_MSG_DATA);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'gmo.plsql.GMO_DOCUMENT_NUMBERS_GRP.GET_DOCUMENT_NUMBER_TYPE',
                      FALSE);
    END IF;

  WHEN OTHERS THEN

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
                      'gmo.plsql.GMO_DOCUMENT_NUMBERS_GRP.GET_DOCUMENT_NUMBER_TYPE',
                      FALSE);
    END IF;

END GET_DOCUMENT_NUMBER_TYPE;



--This PROCEDURE is used to obtain the next document number in sequence associated with the
--specified organization ID and transaction type.
PROCEDURE GET_NEXT_VALUE
(P_API_VERSION        IN         NUMBER,
 P_INIT_MSG_LIST      IN         VARCHAR2,
 X_RETURN_STATUS      OUT NOCOPY VARCHAR2,
 X_MSG_COUNT          OUT NOCOPY NUMBER,
 X_MSG_DATA           OUT NOCOPY VARCHAR2,
 P_ORGANIZATION_ID    IN  NUMBER,
 P_TRANSACTION_TYPE   IN  VARCHAR2,
 X_VALUE              OUT NOCOPY VARCHAR2)

IS

--This constant holds the API name.
L_API_NAME           CONSTANT VARCHAR2(30) := 'GET_NEXT_VALUE';

--This constant holds the API version.
L_API_VERSION        CONSTANT NUMBER   := 1.0;


BEGIN

  --Validate the API versions.
  IF NOT FND_API.COMPATIBLE_API_CALL(L_API_VERSION,
                                     P_API_VERSION,
                                     L_API_NAME,
                                     G_PKG_NAME)
  THEN

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

  --Initialized the message list if specified so.
  IF FND_API.TO_BOOLEAN(P_INIT_MSG_LIST) THEN

    FND_MSG_PUB.INITIALIZE;

  END IF;

  --Call a private API to obtain the next value of the document number associated with
  --the specified organization ID and transaction type.
  GMO_DOCUMENT_NUMBERS_PVT.GET_NEXT_VALUE
  (P_ORGANIZATION_ID      => P_ORGANIZATION_ID,
   P_TRANSACTION_TYPE     => P_TRANSACTION_TYPE,
   P_INIT_MSG_LIST        => P_INIT_MSG_LIST,
   X_VALUE                => X_VALUE,
   X_RETURN_STATUS        => X_RETURN_STATUS,
   X_MSG_COUNT            => X_MSG_COUNT,
   X_MSG_DATA             => X_MSG_DATA);

  --Get the message count.
  --If count is 1, then get the message data.
  FND_MSG_PUB.COUNT_AND_GET
  (P_COUNT => X_MSG_COUNT,
   P_DATA  => X_MSG_DATA);


EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR ;

    FND_MSG_PUB.COUNT_AND_GET
    (P_COUNT => X_MSG_COUNT,
     P_DATA  => X_MSG_DATA);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'gmo.plsql.GMO_DOCUMENT_NUMBERS_GRP.GET_NEXT_VALUE',
                      FALSE);
    END IF;

  WHEN OTHERS THEN

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
                      'gmo.plsql.GMO_DOCUMENT_NUMBERS_GRP.GET_NEXT_VALUE',
                      FALSE);
    END IF;


END GET_NEXT_VALUE;

--This procedure is used to check if a document number exists for the specified
--organization and transaction type.
PROCEDURE DOES_DOCUMENT_NUMBER_EXIST
(P_API_VERSION            IN         NUMBER,
 P_INIT_MSG_LIST          IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
 X_RETURN_STATUS          OUT NOCOPY VARCHAR2,
 X_MSG_COUNT              OUT NOCOPY NUMBER,
 X_MSG_DATA               OUT NOCOPY VARCHAR2,
 P_ORGANIZATION_ID        IN         NUMBER,
 P_TRANSACTION_TYPE       IN         VARCHAR2,
 X_DOCUMENT_NUMBER_EXISTS OUT NOCOPY VARCHAR2)

IS

--This constant holds the API name.
L_API_NAME           CONSTANT VARCHAR2(30) := 'DOES_DOCUMENT_NUMBER_EXIST';

--This constant holds the API version.
L_API_VERSION        CONSTANT NUMBER   := 1.0;

BEGIN


  --Validate the API versions.
  IF NOT FND_API.COMPATIBLE_API_CALL(L_API_VERSION,
                                     P_API_VERSION,
                                     L_API_NAME,
                                     G_PKG_NAME)
  THEN

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

  --Initialized the message list if specified so.
  IF FND_API.TO_BOOLEAN(P_INIT_MSG_LIST) THEN

    FND_MSG_PUB.INITIALIZE;

  END IF;

  --Call the private API to perform the required operation.
  GMO_DOCUMENT_NUMBERS_PVT.DOES_DOCUMENT_NUMBER_EXIST
  (P_ORGANIZATION_ID        => P_ORGANIZATION_ID,
   P_TRANSACTION_TYPE       => P_TRANSACTION_TYPE,
   P_INIT_MSG_LIST          => P_INIT_MSG_LIST,
   X_DOCUMENT_NUMBER_EXISTS => X_DOCUMENT_NUMBER_EXISTS,
   X_RETURN_STATUS          => X_RETURN_STATUS,
   X_MSG_COUNT              => X_MSG_COUNT,
   X_MSG_DATA               => X_MSG_DATA);

  --Get the message count.
  --If count is 1, then get the message data.
  FND_MSG_PUB.COUNT_AND_GET
  (P_COUNT => X_MSG_COUNT,
   P_DATA  => X_MSG_DATA);

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR ;

    FND_MSG_PUB.COUNT_AND_GET
    (P_COUNT => X_MSG_COUNT,
     P_DATA  => X_MSG_DATA);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'gmo.plsql.GMO_DOCUMENT_NUMBERS_GRP.DOES_DOCUMENT_NUMBER_EXIST',
                      FALSE);
    END IF;

  WHEN OTHERS THEN

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
                      'gmo.plsql.GMO_DOCUMENT_NUMBERS_GRP.DOES_DOCUMENT_NUMBER_EXIST',
                      FALSE);
    END IF;


END DOES_DOCUMENT_NUMBER_EXIST;

END GMO_DOCUMENT_NUMBERS_GRP;

/
