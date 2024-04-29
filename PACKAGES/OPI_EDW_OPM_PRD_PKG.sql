--------------------------------------------------------
--  DDL for Package OPI_EDW_OPM_PRD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_EDW_OPM_PRD_PKG" AUTHID CURRENT_USER AS
/* $Header: OPIEPRDS.pls 115.2 2002/05/07 13:29:04 pkm ship      $ */

                PKG_VAR_ITEM_ID_V		ic_item_mst.item_id%TYPE := 0;
		PKG_VAR_LOT_ID_V		ic_lots_mst.lot_id%TYPE := 0;
		PKG_VAR_QC_GRADE_V		ic_TRAN_CMP.QC_GRADE%TYPE := NULL;
                PKG_VAR_BATCH_ID_V1		PM_BTCH_HDR.BATCH_ID%TYPE := 0;
                PKG_VAR_BATCH_ID_V2		PM_BTCH_HDR.BATCH_ID%TYPE := 0;
                PKG_VAR_BATCH_ID_V3		PM_BTCH_HDR.BATCH_ID%TYPE := 0;
                PKG_VAR_BATCH_ID_V4		PM_BTCH_HDR.BATCH_ID%TYPE := 0;
                PKG_VAR_NO_OF_SAMPLES_V		INTEGER := 0;
                PKG_VAR_NO_OF_SMPL_CMPLT_V	INTEGER := 0;
                PKG_VAR_PASSED_SAMPLES_V	INTEGER := 0;
                PKG_VAR_ADJUST_BATCH_V	        INTEGER := 0;

  FUNCTION FIND_PROD_GRADE(TRANS_ID_VI IN INTEGER,ITEM_ID_VI IN INTEGER,LOT_ID_VI IN INTEGER)
           RETURN VARCHAR2;
  FUNCTION NO_OF_SAMPLES_TAKEN(BATCH_ID_VI IN INTEGER) RETURN INTEGER;
  FUNCTION NO_OF_SAMPLES_COMPLETE(BATCH_ID_VI IN INTEGER) RETURN INTEGER;
  FUNCTION NO_OF_SAMPLES_PASSED(BATCH_ID_VI IN INTEGER) RETURN INTEGER;
  FUNCTION NO_OF_TIMES_ADJUSTED(BATCH_ID_VI IN INTEGER) RETURN INTEGER;
  FUNCTION INGREDIENT_VALUE(BATCH_ID_VI IN INTEGER,ITEM_ID_VI INTEGER,LINE_NO_VI INTEGER,SOURCE IN VARCHAR2) RETURN NUMBER;
  FUNCTION BYPRODUCT_VALUE(BATCH_ID_VI IN INTEGER, SOURCE IN VARCHAR2) RETURN NUMBER;

  FUNCTION SCHD_WORK_DAYS(BATCH_ID_VI IN INTEGER,START_DATE IN DATE,CMPLT_DATE IN DATE) RETURN NUMBER;

END OPI_EDW_OPM_PRD_PKG;

 

/