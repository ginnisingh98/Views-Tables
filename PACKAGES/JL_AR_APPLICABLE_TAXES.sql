--------------------------------------------------------
--  DDL for Package JL_AR_APPLICABLE_TAXES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_AR_APPLICABLE_TAXES" AUTHID CURRENT_USER AS
/* $Header: jlarpats.pls 120.0.12010000.1 2009/02/05 07:04:12 nivnaray noship $ */


P_START_DATE                    DATE;
P_END_DATE                      DATE;
P_VALIDATION_DATA               VARCHAR2(10);
P_REV_TEMP_DATA                 VARCHAR2(10);
P_FINALIZE_DATA                 VARCHAR2(10);
P_APPLN_RESP                    VARCHAR2(10);                     -- R12 change
P_AWT_TAX_TYPE                  VARCHAR2(10)  := 'TURN_BSAS';
P_PERCEPTION_TAX_TYPE           VARCHAR2(10)  := 'TOPBA';
table_name                      VARCHAR2(30);

 PROCEDURE Insert_Row  (l_PUBLISH_DATE             DATE,
                        l_START_DATE               DATE,
                        l_END_DATE                 DATE,
                        l_TAXPAYER_ID              NUMBER,
                        l_CONTRIBUTOR_TYPE_CODE    VARCHAR2,
                        l_NEW_CONTRIBUTOR_FLAG     VARCHAR2,
                        l_RATE_CHANGE_FLAG         VARCHAR2,
                        l_PERCEPTION_RATE          NUMBER,
                        l_WHT_RATE                 NUMBER,
                        l_PERCEPTION_GROUP_NUM     NUMBER,
                        l_WHT_GROUP_NUM            NUMBER,
                        l_WHT_DEFAULT_FLAG         VARCHAR2,
                        l_CALLING_RESP             VARCHAR2
                        );

FUNCTION FORMAT_DATE(INPUT_DATE IN DATE) RETURN DATE;

FUNCTION VALID_NUMBER(INPUT_NUM IN NUMBER) RETURN BOOLEAN;

FUNCTION BASIC_VALIDATION(l_TAXPAYERID IN NUMBER) RETURN BOOLEAN;

PROCEDURE FINAL_VALIDATION;

PROCEDURE VALIDATE_AWT_SETUP;

FUNCTION beforeReport RETURN BOOLEAN;


END JL_AR_APPLICABLE_TAXES;


/
