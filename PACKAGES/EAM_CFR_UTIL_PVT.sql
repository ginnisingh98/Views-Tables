--------------------------------------------------------
--  DDL for Package EAM_CFR_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_CFR_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVCFRS.pls 120.1 2006/09/01 06:34:09 smrsharm noship $ */
 /***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVCFRS.pls
--
--  DESCRIPTION
--
--      Specifiacation of EAM_CFR_UTIL_PVT
--
--  NOTES
--
--  HISTORY
--
--  29-AUGUST-2006    Smriti Sharma     Initial Creation
***************************************************************************/



 PROCEDURE GET_DESC_FLEX_ALL_PROMPTS      (P_APPLICATION_ID IN VARCHAR2,
						P_DESC_FLEX_DEF_NAME IN  VARCHAR2,
						P_DESC_FLEX_CONTEXT IN VARCHAR2,
						P_PROMPT_TYPE IN VARCHAR2,
						P_COLUMN1_NAME IN VARCHAR2,
						P_COLUMN2_NAME IN VARCHAR2,
						P_COLUMN3_NAME IN VARCHAR2,
						P_COLUMN4_NAME IN VARCHAR2,
						P_COLUMN5_NAME IN VARCHAR2,
						P_COLUMN6_NAME IN VARCHAR2,
						P_COLUMN7_NAME IN VARCHAR2,
						P_COLUMN8_NAME IN VARCHAR2,
						P_COLUMN9_NAME IN VARCHAR2,
						P_COLUMN10_NAME IN VARCHAR2,
						P_COLUMN11_NAME IN VARCHAR2,
						P_COLUMN12_NAME IN VARCHAR2,
						P_COLUMN13_NAME IN VARCHAR2,
						P_COLUMN14_NAME IN VARCHAR2,
						P_COLUMN15_NAME IN VARCHAR2,
						P_COLUMN1_PROMPT out nocopy VARCHAR2,
						P_COLUMN2_PROMPT out nocopy VARCHAR2,
                                                P_COLUMN3_PROMPT out nocopy VARCHAR2,
						P_COLUMN4_PROMPT out nocopy VARCHAR2,
						P_COLUMN5_PROMPT out nocopy VARCHAR2,
						P_COLUMN6_PROMPT out nocopy VARCHAR2,
						P_COLUMN7_PROMPT out nocopy VARCHAR2,
						P_COLUMN8_PROMPT out nocopy VARCHAR2,
						P_COLUMN9_PROMPT out nocopy VARCHAR2,
						P_COLUMN10_PROMPT out nocopy VARCHAR2,
						P_COLUMN11_PROMPT out nocopy VARCHAR2,
						P_COLUMN12_PROMPT out nocopy VARCHAR2,
						P_COLUMN13_PROMPT out nocopy VARCHAR2,
						P_COLUMN14_PROMPT out nocopy VARCHAR2,
						P_COLUMN15_PROMPT out nocopy VARCHAR2
						);




END;


 

/
