--------------------------------------------------------
--  DDL for Package CCT_BASIC_WEBCALLBACK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_BASIC_WEBCALLBACK_PUB" AUTHID CURRENT_USER AS
/* $Header: cctwebps.pls 115.0 2003/02/12 20:12:07 edwang noship $ */
    PROCEDURE CCT_BASIC_WEB_ENUM_NODES
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

END CCT_BASIC_WEBCALLBACK_PUB;

 

/
