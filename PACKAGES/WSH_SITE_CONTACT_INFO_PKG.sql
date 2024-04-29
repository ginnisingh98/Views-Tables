--------------------------------------------------------
--  DDL for Package WSH_SITE_CONTACT_INFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_SITE_CONTACT_INFO_PKG" AUTHID CURRENT_USER as
/* $Header: WSHSITHS.pls 115.1 2002/11/12 01:51:49 nparikh noship $ */


PROCEDURE CREATE_CONTACTINFO
 (
    P_RELATIONSHIP_PARTY_ID     IN  NUMBER,
    P_COUNTRY_CODE              IN  VARCHAR2,
    P_AREA_CODE                 IN  VARCHAR2,
    P_PHONE_NUMBER              IN  VARCHAR2 DEFAULT NULL,
    P_EXTENSION                 IN  VARCHAR2,
    P_PHONE_LINE_TYPE           IN  VARCHAR2,
    X_CONTACT_POINT_ID          OUT NOCOPY  NUMBER,
    X_RETURN_STATUS             OUT NOCOPY  VARCHAR2,
    X_EXCEPTION_MSG             OUT NOCOPY  VARCHAR2,
    X_SQLERR                    OUT NOCOPY  VARCHAR2,
    X_SQL_CODE                  OUT NOCOPY  VARCHAR2,
    X_POSITION                  OUT NOCOPY  NUMBER,
    X_PROCEDURE                 OUT NOCOPY  VARCHAR2
  );


PROCEDURE UPDATE_CONTACTINFO(
    P_CONTACT_POINT_ID          IN  NUMBER,
    P_COUNTRY_CODE              IN  VARCHAR2,
    P_AREA_CODE                 IN  VARCHAR2,
    P_PHONE_NUMBER              IN  VARCHAR2 DEFAULT NULL,
    P_EXTENSION                 IN  VARCHAR2,
    P_PHONE_LINE_TYPE           IN  VARCHAR2,
    X_RETURN_STATUS             OUT NOCOPY  VARCHAR2,
    X_EXCEPTION_MSG             OUT NOCOPY  VARCHAR2,
    X_POSITION                  OUT NOCOPY  NUMBER,
    X_PROCEDURE                 OUT NOCOPY  VARCHAR2,
    X_SQLERR                    OUT NOCOPY  VARCHAR2,
    X_SQL_CODE                  OUT NOCOPY  VARCHAR2
);

END WSH_SITE_CONTACT_INFO_PKG;

 

/
