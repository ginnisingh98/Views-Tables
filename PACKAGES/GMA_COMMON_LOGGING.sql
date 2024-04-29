--------------------------------------------------------
--  DDL for Package GMA_COMMON_LOGGING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMA_COMMON_LOGGING" AUTHID CURRENT_USER As
/*$Header: GMAMCLS.pls 120.2 2005/09/15 03:47:38 kshukla noship $*/
Procedure Gma_Migration_CentraL_Log(
                       P_Run_Id         VARCHAR2,
                       P_log_level      VARCHAR2,
                       P_App_short_name VARCHAR2,
                       P_Message_Token  VARCHAR2,
                       P_context	VARCHAR2,
                       P_Table_Name     VARCHAR2 DEFAULT NULL,
                       P_Param1         VARCHAR2 DEFAULT NULL,
                       P_Param2         VARCHAR2 DEFAULT NULL,
                       P_Param3         VARCHAR2 DEFAULT NULL,
                       P_Param4         VARCHAR2 DEFAULT NULL,
                       P_Param5         VARCHAR2 DEFAULT NULL,
                       P_Db_Error       VARCHAR2 DEFAULT NULL,
                       P_Token1		VARCHAR2 DEFAULT NULL,
                       P_Token2		VARCHAR2 DEFAULT NULL,
                       P_Token3		VARCHAR2 DEFAULT NULL,
                       P_Token4		VARCHAR2 DEFAULT NULL,
                       P_Token5		VARCHAR2 DEFAULT NULL,
                       P_Param6		VARCHAR2 DEFAULT NULL,
                       P_Token6         VARCHAR2 DEFAULT NULL);
End GMA_COMMON_LOGGING;

 

/
