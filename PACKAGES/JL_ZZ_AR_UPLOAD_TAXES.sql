--------------------------------------------------------
--  DDL for Package JL_ZZ_AR_UPLOAD_TAXES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_AR_UPLOAD_TAXES" AUTHID CURRENT_USER AS
/* $Header: jlzzutxs.pls 120.0.12010000.1 2009/02/05 07:05:06 nivnaray noship $ */

  PROCEDURE JL_AR_UPDATE_CUST_SITE_TAX(P_TAXPAYER_ID IN NUMBER,
                                       P_TAX_TYPE IN VARCHAR2 := 'TURN_BSAS',
                                       P_CATEG IN VARCHAR2 := 'TOPBA',
                                       P_ORG_ID IN NUMBER,
                                       P_PUBLISH_DATE IN DATE,
                                       P_START_DATE IN DATE,
                                       P_END_DATE IN DATE,
                                       X_RETURN_STATUS OUT NOCOPY VARCHAR2);
  PROCEDURE INITIALIZE;

END JL_ZZ_AR_UPLOAD_TAXES;

/
