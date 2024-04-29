--------------------------------------------------------
--  DDL for Package CCT_BASIC_TELE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_BASIC_TELE_PUB" AUTHID CURRENT_USER AS
/* $Header: cctsdkps.pls 115.2 2002/09/05 00:03:04 edwang noship $ */
    PROCEDURE CCT_BASIC_TELE_ENUM_NODES
    (
        P_RESOURCE_ID IN NUMBER,
        P_LANGUAGE    IN VARCHAR2,
        P_SOURCE_LANG IN VARCHAR2,
        P_SEL_ENUM_ID IN NUMBER
    );

    PROCEDURE UPDATE_RT_STATS
    (
        P_RESOURCE_ID IN NUMBER,
        P_COUNT       IN NUMBER
    );

END CCT_BASIC_TELE_PUB;

 

/
