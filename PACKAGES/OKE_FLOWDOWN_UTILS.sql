--------------------------------------------------------
--  DDL for Package OKE_FLOWDOWN_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_FLOWDOWN_UTILS" AUTHID CURRENT_USER AS
/* $Header: OKEFWDUS.pls 120.0 2005/05/25 17:33:49 appldev noship $ */
--
--  Name          : Flowdown_URL
--  Pre-reqs      : FND_GLOBAL.INITIALIZE
--  Function      : This function returns the URL for the flowdown viewer
--
--
--  Parameters    :
--  IN            : None
--  OUT           : None
--
--  Returns       : NUMBER
--

FUNCTION Flowdown_URL
( X_Business_Area        IN     VARCHAR2
, X_Object_Name          IN     VARCHAR2
, X_PK1                  IN     VARCHAR2
, X_PK2                  IN     VARCHAR2
) RETURN VARCHAR2;

PROCEDURE INSERT_ROW
( P_BUSINESS_AREA_CODE   IN  VARCHAR2
, P_FLOWDOWN_TYPE        IN  VARCHAR2
, P_FLOWDOWN_CODE        IN  VARCHAR2
, P_ATTRIBUTE_GROUP_TYPE IN  VARCHAR2
);

PROCEDURE DELETE_ROW
( P_BUSINESS_AREA_CODE   IN     VARCHAR2
, P_FLOWDOWN_TYPE        IN     VARCHAR2
, P_FLOWDOWN_CODE        IN     VARCHAR2
, P_ATTRIBUTE_GROUP_TYPE IN     VARCHAR2
) ;


END OKE_FLOWDOWN_UTILS;

 

/
