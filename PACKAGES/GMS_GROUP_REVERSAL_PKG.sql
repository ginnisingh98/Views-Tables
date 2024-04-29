--------------------------------------------------------
--  DDL for Package GMS_GROUP_REVERSAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_GROUP_REVERSAL_PKG" AUTHID CURRENT_USER AS
--$Header: gmsrevas.pls 115.13 2000/06/28 20:28:05 pkm ship    $

 PROCEDURE GMS_CREATE_ADLS(X_REVERSE_GROUP IN  VARCHAR2 ) ;
-- To create adls while coping the batch
 PROCEDURE GMS_COPY_EXP(X_NEW_GROUP IN  VARCHAR2, X_ORG_GROUP IN VARCHAR2, P_OUTCOME IN OUT VARCHAR2  ) ;

 PROCEDURE GMS_CREATE_ENC_REV_ADLS(X_NEW_GROUP IN  VARCHAR2 ) ;

 PROCEDURE GMS_CREATE_ENC_COPY_ADLS(X_NEW_GROUP IN  VARCHAR2, X_ORG_GROUP IN VARCHAR2 ,P_OUTCOME IN OUT VARCHAR2  ) ;

END GMS_GROUP_REVERSAL_PKG;

 

/
