--------------------------------------------------------
--  DDL for Package IEC_WHERECLAUSE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_WHERECLAUSE_PVT" AUTHID CURRENT_USER AS
/* $Header: IECVWHCS.pls 115.5.1158.3 2002/10/02 18:12:48 lcrew ship $ */

PROCEDURE GETWHERECLAUSE
    (P_OWNER_ID                 NUMBER
    ,P_OWNER_TYPE               VARCHAR2
    ,WHERECLAUSE      OUT       VARCHAR2);

PROCEDURE GETWHERECLAUSEFORSUBSET
    (P_OWNER_ID                 NUMBER
    ,P_OWNER_TYPE               VARCHAR2
    ,WHERECLAUSE      OUT       VARCHAR2);

PROCEDURE getAMSView( listHeaderId number, viewName out varchar2);
END IEC_WHERECLAUSE_PVT;

 

/
