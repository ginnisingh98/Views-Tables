--------------------------------------------------------
--  DDL for Package WSH_CARRIER_CONTACT_INFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_CARRIER_CONTACT_INFO_PKG" AUTHID CURRENT_USER as
/* $Header: WSHCITHS.pls 120.1 2006/06/09 09:11:43 jnpinto noship $ */


PROCEDURE CREATE_CONTACTINFO
 (
    P_RELATIONSHIP_PARTY_ID     IN  NUMBER,
    P_COUNTRY_CODE              IN  VARCHAR2,
    P_AREA_CODE                 IN  VARCHAR2,
    P_PHONE_NUMBER              IN  VARCHAR2 DEFAULT NULL,
    P_EXTENSION                 IN  VARCHAR2,
    P_PRIMARY                   IN  VARCHAR2,
    P_STATUS                    IN  VARCHAR2,
    P_CONTACT_TYPE              IN  VARCHAR2,
    X_CONTACT_POINT_ID          OUT NOCOPY  NUMBER,
    X_RETURN_STATUS             OUT NOCOPY  VARCHAR2,
    X_EXCEPTION_MSG             OUT NOCOPY  VARCHAR2,
    X_SQLERR                    OUT NOCOPY  VARCHAR2,
    X_SQL_CODE                  OUT NOCOPY  VARCHAR2,
    X_POSITION                  OUT NOCOPY  NUMBER,
    X_PROCEDURE                 OUT NOCOPY  VARCHAR2
  );


PROCEDURE UPDATE_CONTACTINFO(
    P_CARRIER_PARTY_ID          IN NUMBER,
    P_CONTACT_POINT_ID          IN NUMBER,
    P_COUNTRY_CODE              IN  VARCHAR2,
    P_AREA_CODE                 IN  VARCHAR2,
    P_PHONE_NUMBER              IN  VARCHAR2 DEFAULT NULL,
    P_EXTENSION                 IN  VARCHAR2,
    P_PRIMARY                   IN  VARCHAR2,
    P_STATUS                    IN  VARCHAR2,
    P_CONTACT_TYPE              IN  VARCHAR2,        -- Added parameter for conatct type - Bug 5298638
    X_RETURN_STATUS             OUT NOCOPY  VARCHAR2,
    X_EXCEPTION_MSG             OUT NOCOPY  VARCHAR2,
    X_POSITION                  OUT NOCOPY  NUMBER,
    X_PROCEDURE                 OUT NOCOPY  VARCHAR2,
    X_SQLERR                    OUT NOCOPY  VARCHAR2,
    X_SQL_CODE                  OUT NOCOPY  VARCHAR2

);

END WSH_CARRIER_CONTACT_INFO_PKG;

 

/
