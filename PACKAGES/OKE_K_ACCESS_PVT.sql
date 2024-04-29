--------------------------------------------------------
--  DDL for Package OKE_K_ACCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_K_ACCESS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKEVKASS.pls 115.4 2002/11/20 20:44:14 who ship $ */
PROCEDURE CREATE_CONTRACT_ACCESS
( P_COMMIT                     IN      VARCHAR2
, P_OBJECT_TYPE                IN      VARCHAR2
, P_OBJECT_ID                  IN      NUMBER
, P_ROLE_ID                    IN      NUMBER
, P_PERSON_ID                  IN      NUMBER
, P_START_DATE_ACTIVE          IN      DATE
, P_END_DATE_ACTIVE            IN OUT  NOCOPY DATE
, X_PROJECT_PARTY_ID           OUT     NOCOPY NUMBER
, X_RESOURCE_ID                OUT     NOCOPY NUMBER
, X_ASSIGNMENT_ID              OUT     NOCOPY NUMBER
, X_RECORD_VERSION_NUMBER      OUT     NOCOPY NUMBER
, X_RETURN_STATUS              OUT     NOCOPY VARCHAR2
, X_MSG_COUNT                  OUT     NOCOPY NUMBER
, X_MSG_DATA                   OUT     NOCOPY VARCHAR2
);


PROCEDURE LOCK_ROW
( P_OBJECT_TYPE                IN      VARCHAR2
, P_OBJECT_ID                  IN      NUMBER
, P_ROLE_ID                    IN      NUMBER
, P_PERSON_ID                  IN      NUMBER
, P_START_DATE_ACTIVE          IN      DATE
, P_END_DATE_ACTIVE            IN      DATE
, P_PROJECT_PARTY_ID           IN      NUMBER
, P_RESOURCE_ID                IN      NUMBER
);


PROCEDURE UPDATE_CONTRACT_ACCESS
( P_COMMIT                     IN      VARCHAR2
, P_OBJECT_TYPE                IN      VARCHAR2
, P_OBJECT_ID                  IN      NUMBER
, P_ROLE_ID                    IN      NUMBER
, P_PERSON_ID                  IN      NUMBER
, P_START_DATE_ACTIVE          IN      DATE
, P_END_DATE_ACTIVE            IN OUT  NOCOPY DATE
, P_PROJECT_PARTY_ID           IN      NUMBER
, P_RECORD_VERSION_NUMBER      IN      NUMBER
, P_RESOURCE_ID                IN      NUMBER
, P_ASSIGNMENT_ID              IN      NUMBER
, X_ASSIGNMENT_ID              OUT     NOCOPY NUMBER
, X_RETURN_STATUS              OUT     NOCOPY VARCHAR2
, X_MSG_COUNT                  OUT     NOCOPY NUMBER
, X_MSG_DATA                   OUT     NOCOPY VARCHAR2
);

END OKE_K_ACCESS_PVT;

 

/
