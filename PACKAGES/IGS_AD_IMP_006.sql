--------------------------------------------------------
--  DDL for Package IGS_AD_IMP_006
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_IMP_006" AUTHID CURRENT_USER AS
/* $Header: IGSAD84S.pls 115.4 2002/11/01 10:14:19 sjalasut ship $ */

PROCEDURE PRC_PE_ALIAS (
    P_SOURCE_TYPE_ID IN	NUMBER,
   P_BATCH_ID IN NUMBER  );

PROCEDURE Prc_Pe_Empnt_Dtls (
 P_SOURCE_TYPE_ID IN NUMBER,
 P_BATCH_ID IN VARCHAR2 );

 PROCEDURE Prc_Pe_Extclr_Dtls
(P_SOURCE_TYPE_ID IN NUMBER,
 P_BATCH_ID IN VARCHAR2 );
END IGS_AD_IMP_006;

 

/
