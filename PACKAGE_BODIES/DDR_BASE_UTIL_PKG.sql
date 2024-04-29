--------------------------------------------------------
--  DDL for Package Body DDR_BASE_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DDR_BASE_UTIL_PKG" AS
/* $Header: ddrubasb.pls 120.1.12010000.4 2010/03/03 04:20:34 vbhave ship $ */

FUNCTION set_load_id RETURN NUMBER
AS
  v_load_id NUMBER;
BEGIN
  select DDR_LOAD_SEQ.NEXTVAL
  into v_load_id
  from dual;
RETURN v_load_id;
END set_load_id;


FUNCTION RTL_INV_ITEM_DUPS_FNC(p_load_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2 AS
v_load_id NUMBER := NVL(p_load_id, set_load_id);
BEGIN

-- INSERT DUPLICATE RECORDS IN THE ERROR TABLE --

INSERT INTO DDR_E_RTL_INV_ITEM
    (REC_ID, LOAD_ID, ERR_REASON,
    GLBL_ITEM_ID, GLBL_ITEM_ID_TYP,RTL_BSNS_UNIT_CD,
    RTL_SKU_ITEM_NBR,INV_LOC_CD,UOM, ON_HAND_QTY,RECVD_QTY,
    IN_TRANSIT_QTY,BCK_ORDR_QTY,QLTY_HOLD_QTY,
    ON_HAND_NET_COST_AMT, RECVD_NET_COST_AMT,
    IN_TRANSIT_NET_COST_AMT, BCKORDR_NET_COST_AMT,
    QLTY_HOLD_NET_COST_AMT, ON_HAND_RTL_AMT, RECVD_RTL_AMT,
    IN_TRANSIT_RTL_AMT,BCKORDR_RTL_AMT,
    QLTY_HOLD_RTL_AMT,SRC_SYS_IDNT, SRC_SYS_DT,
    SRC_IDNT_FLAG, ACTION_FLAG, TRANS_DT, RTL_ORG_CD
     )
    SELECT REC_ID, v_load_id,'Duplicate Record',
    GLBL_ITEM_ID,GLBL_ITEM_ID_TYP,  RTL_BSNS_UNIT_CD,
    RTL_SKU_ITEM_NBR, INV_LOC_CD,UOM,
    ON_HAND_QTY, RECVD_QTY,
    IN_TRANSIT_QTY, BCK_ORDR_QTY,
    QLTY_HOLD_QTY, ON_HAND_NET_COST_AMT,
    RECVD_NET_COST_AMT, IN_TRANSIT_NET_COST_AMT,
    BCKORDR_NET_COST_AMT, QLTY_HOLD_NET_COST_AMT,
    ON_HAND_RTL_AMT, RECVD_RTL_AMT,
    IN_TRANSIT_RTL_AMT, BCKORDR_RTL_AMT,
    QLTY_HOLD_RTL_AMT, SRC_SYS_IDNT,
    SRC_SYS_DT,'I','N',TRANS_DT, RTL_ORG_CD
      FROM DDR_I_RTL_INV_ITEM
       WHERE
           (RTL_BSNS_UNIT_CD,
          TRANS_DT,
          GLBL_ITEM_ID,
          RTL_SKU_ITEM_NBR,
          GLBL_ITEM_ID_TYP,
          INV_LOC_CD, RTL_ORG_CD)
          IN (
             SELECT
            RTL_BSNS_UNIT_CD,
          TRANS_DT,
          GLBL_ITEM_ID,
          RTL_SKU_ITEM_NBR,
          GLBL_ITEM_ID_TYP,
          INV_LOC_CD, RTL_ORG_CD
          FROM DDR_I_RTL_INV_ITEM
          GROUP BY
              RTL_BSNS_UNIT_CD,
          TRANS_DT,
          GLBL_ITEM_ID,
          RTL_SKU_ITEM_NBR,
          GLBL_ITEM_ID_TYP,
          INV_LOC_CD, RTL_ORG_CD
             HAVING COUNT(*) > 1
         );
COMMIT;


-- DELETE DUPLICATE RECORDS FROM INTERFACE TABLE --


DELETE FROM DDR_I_RTL_INV_ITEM
    WHERE
      (RTL_BSNS_UNIT_CD,
   TRANS_DT,
   GLBL_ITEM_ID,
   RTL_SKU_ITEM_NBR,
   GLBL_ITEM_ID_TYP,
   INV_LOC_CD, RTL_ORG_CD)
    IN (
     SELECT
       RTL_BSNS_UNIT_CD,
    TRANS_DT,
    GLBL_ITEM_ID,
    RTL_SKU_ITEM_NBR,
    GLBL_ITEM_ID_TYP,
    INV_LOC_CD, RTL_ORG_CD
    FROM DDR_E_RTL_INV_ITEM
    GROUP BY
        RTL_BSNS_UNIT_CD,
      TRANS_DT,
      GLBL_ITEM_ID,
      RTL_SKU_ITEM_NBR,
      GLBL_ITEM_ID_TYP,
      INV_LOC_CD, RTL_ORG_CD
         HAVING COUNT(*) > 1
    );
COMMIT;

RETURN('Y');

END RTL_INV_ITEM_DUPS_FNC;


FUNCTION PRMTN_PLN_DUPS_FNC(p_load_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2
AS
v_load_id NUMBER := NVL(p_load_id, set_load_id);
BEGIN
-- INSERT DUPLICATE RECORDS IN THE ERROR TABLE --
INSERT INTO DDR_E_PRMTN_PLN
    (REC_ID, LOAD_ID, ERR_REASON,RTL_BSNS_UNIT_CD,
     PRMTN_TYP,
  PRMTN_FROM_DT,
  PRMTN_TO_DT,
  GLBL_ITEM_ID,
  RTL_SKU_ITEM_NBR,
  GLBL_ITEM_ID_TYP,
  PRMTN_PRICE_AMT,
  SRC_SYS_IDNT,
  SRC_SYS_DT,
  SRC_IDNT_FLAG,
  ACTION_FLAG,
  TRANS_DT,
  RTL_ORG_CD,
  ATTRIBUTE1,
  ATTRIBUTE2,
  ATTRIBUTE3,
  ATTRIBUTE4,
  ATTRIBUTE5,
  ATTRIBUTE6,
  ATTRIBUTE7,
  ATTRIBUTE8,
  ATTRIBUTE9,
  ATTRIBUTE10,
  ATTRIBUTE11,
  ATTRIBUTE12,
  ATTRIBUTE13,
  ATTRIBUTE14,
  ATTRIBUTE15,
  ATTRIBUTE16,
  ATTRIBUTE17,
  ATTRIBUTE18,
  ATTRIBUTE19,
  ATTRIBUTE20
     )
    SELECT REC_ID, v_load_id,'Duplicate Record',
    RTL_BSNS_UNIT_CD,
    PRMTN_TYP,
    PRMTN_FROM_DT,
    PRMTN_TO_DT,
    GLBL_ITEM_ID,
    RTL_SKU_ITEM_NBR,
    GLBL_ITEM_ID_TYP,
    PRMTN_PRICE_AMT,
    SRC_SYS_IDNT,
    SRC_SYS_DT,
    'I','N',TRANS_DT, RTL_ORG_CD,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    ATTRIBUTE16,
    ATTRIBUTE17,
    ATTRIBUTE18,
    ATTRIBUTE19,
    ATTRIBUTE20
      FROM DDR_I_PRMTN_PLN
       WHERE
           (GLBL_ITEM_ID,
        RTL_BSNS_UNIT_CD,
        PRMTN_TYP,
        PRMTN_FROM_DT,
        PRMTN_TO_DT,
        RTL_SKU_ITEM_NBR,
        GLBL_ITEM_ID_TYP,
        TRANS_DT, RTL_ORG_CD)
          IN (
             SELECT
            GLBL_ITEM_ID,
          RTL_BSNS_UNIT_CD,
          PRMTN_TYP,
          PRMTN_FROM_DT,
          PRMTN_TO_DT,
          RTL_SKU_ITEM_NBR,
          GLBL_ITEM_ID_TYP,
          TRANS_DT, RTL_ORG_CD
          FROM DDR_I_PRMTN_PLN
          GROUP BY
              GLBL_ITEM_ID,
          RTL_BSNS_UNIT_CD,
          PRMTN_TYP,
          PRMTN_FROM_DT,
          PRMTN_TO_DT,
          RTL_SKU_ITEM_NBR,
          GLBL_ITEM_ID_TYP,
          TRANS_DT, RTL_ORG_CD
             HAVING COUNT(*) > 1
         );
COMMIT;

-- DELETE DUPLICATE RECORDS FROM INTERFACE TABLE --


DELETE FROM DDR_I_PRMTN_PLN
    WHERE
      (GLBL_ITEM_ID,
   RTL_BSNS_UNIT_CD,
   PRMTN_TYP,
   PRMTN_FROM_DT,
   PRMTN_TO_DT,
   RTL_SKU_ITEM_NBR,
   GLBL_ITEM_ID_TYP,
   TRANS_DT, RTL_ORG_CD)
    IN (
     SELECT
       GLBL_ITEM_ID,
    RTL_BSNS_UNIT_CD,
    PRMTN_TYP,
    PRMTN_FROM_DT,
    PRMTN_TO_DT,
    RTL_SKU_ITEM_NBR,
    GLBL_ITEM_ID_TYP,
    TRANS_DT, RTL_ORG_CD
    FROM DDR_E_PRMTN_PLN
    GROUP BY
        GLBL_ITEM_ID,
      RTL_BSNS_UNIT_CD,
      PRMTN_TYP,
      PRMTN_FROM_DT,
      PRMTN_TO_DT,
      RTL_SKU_ITEM_NBR,
      GLBL_ITEM_ID_TYP,
      TRANS_DT, RTL_ORG_CD
         HAVING COUNT(*) > 1
    );
COMMIT;

RETURN('Y');

END PRMTN_PLN_DUPS_FNC;


FUNCTION RTL_ORDR_ITEM_DUPS_FNC(p_load_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2
AS
v_load_id NUMBER := NVL(p_load_id, set_load_id);
BEGIN
-- INSERT DUPLICATE RECORDS IN THE ERROR TABLE --


INSERT INTO DDR_E_RTL_ORDR_ITEM
    (REC_ID, LOAD_ID, ERR_REASON,
    RTL_BSNS_UNIT_CD,GLBL_ITEM_ID,
    RTL_SKU_ITEM_NBR, GLBL_ITEM_ID_TYP, UOM,
    ORDR_QTY,ORDR_AMT,SRC_SYS_IDNT,
    SRC_SYS_DT, TRANS_DT, SRC_IDNT_FLAG,
    ACTION_FLAG, RTL_ORG_CD
     )
    SELECT REC_ID, v_load_id,'Duplicate Record',
    RTL_BSNS_UNIT_CD,GLBL_ITEM_ID,
       RTL_SKU_ITEM_NBR, GLBL_ITEM_ID_TYP, UOM,
      ORDR_QTY,ORDR_AMT,SRC_SYS_IDNT,
      SRC_SYS_DT, TRANS_DT,'I','N', RTL_ORG_CD
      FROM DDR_I_RTL_ORDR_ITEM
       WHERE
           (RTL_BSNS_UNIT_CD,
          GLBL_ITEM_ID,
          RTL_SKU_ITEM_NBR,
          GLBL_ITEM_ID_TYP,
          TRANS_DT, RTL_ORG_CD)
          IN (
             SELECT
            RTL_BSNS_UNIT_CD,
          GLBL_ITEM_ID,
          RTL_SKU_ITEM_NBR,
          GLBL_ITEM_ID_TYP,
          TRANS_DT, RTL_ORG_CD
          FROM DDR_I_RTL_ORDR_ITEM
          GROUP BY
              RTL_BSNS_UNIT_CD,
          GLBL_ITEM_ID,
          RTL_SKU_ITEM_NBR,
          GLBL_ITEM_ID_TYP,
          TRANS_DT, RTL_ORG_CD
             HAVING COUNT(*) > 1
         );
COMMIT;


-- DELETE DUPLICATE RECORDS FROM INTERFACE TABLE --


DELETE FROM DDR_I_RTL_ORDR_ITEM
    WHERE
      (RTL_BSNS_UNIT_CD,
   GLBL_ITEM_ID,
   RTL_SKU_ITEM_NBR,
   GLBL_ITEM_ID_TYP,
   TRANS_DT, RTL_ORG_CD)
    IN (
     SELECT
       RTL_BSNS_UNIT_CD,
    GLBL_ITEM_ID,
    RTL_SKU_ITEM_NBR,
    GLBL_ITEM_ID_TYP,
    TRANS_DT, RTL_ORG_CD
    FROM DDR_E_RTL_ORDR_ITEM
    GROUP BY
        RTL_BSNS_UNIT_CD,
      GLBL_ITEM_ID,
      RTL_SKU_ITEM_NBR,
      GLBL_ITEM_ID_TYP,
      TRANS_DT, RTL_ORG_CD
         HAVING COUNT(*) > 1
    );
COMMIT;

RETURN('Y');

END RTL_ORDR_ITEM_DUPS_FNC;

FUNCTION RTL_SHIP_ITEM_DUPS_FNC(p_load_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2
AS
v_load_id NUMBER := NVL(p_load_id, set_load_id);
BEGIN
-- INSERT DUPLICATE RECORDS IN THE ERROR TABLE --


INSERT INTO DDR_E_RTL_SHIP_ITEM
    (REC_ID, LOAD_ID, ERR_REASON,
    RTL_BSNS_UNIT_CD,GLBL_ITEM_ID,
    RTL_SKU_ITEM_NBR, GLBL_ITEM_ID_TYP,
    UOM,SHIP_QTY, SHIP_AMT, SRC_SYS_IDNT,
    SRC_SYS_DT, SRC_IDNT_FLAG, ACTION_FLAG, TRANS_DT,
    RTL_ORG_CD, SHIP_TO_ORG_CD, SHIP_TO_BSNS_UNIT_CD, SHIP_COST
     )
    SELECT REC_ID, v_load_id,'Duplicate Record',
    RTL_BSNS_UNIT_CD,GLBL_ITEM_ID,
       RTL_SKU_ITEM_NBR, GLBL_ITEM_ID_TYP,
       UOM,SHIP_QTY, SHIP_AMT, SRC_SYS_IDNT,
       SRC_SYS_DT,'I','N', TRANS_DT,
       RTL_ORG_CD, SHIP_TO_ORG_CD, SHIP_TO_BSNS_UNIT_CD, SHIP_COST
      FROM DDR_I_RTL_SHIP_ITEM
       WHERE
           (GLBL_ITEM_ID,
          RTL_BSNS_UNIT_CD,
          RTL_SKU_ITEM_NBR,
          GLBL_ITEM_ID_TYP,
          TRANS_DT, RTL_ORG_CD,
          SHIP_TO_ORG_CD, SHIP_TO_BSNS_UNIT_CD )
          IN (
             SELECT
            GLBL_ITEM_ID,
          RTL_BSNS_UNIT_CD,
          RTL_SKU_ITEM_NBR,
          GLBL_ITEM_ID_TYP,
          TRANS_DT, RTL_ORG_CD,
          SHIP_TO_ORG_CD, SHIP_TO_BSNS_UNIT_CD
          FROM DDR_I_RTL_SHIP_ITEM
          GROUP BY
              GLBL_ITEM_ID,
          RTL_BSNS_UNIT_CD,
          RTL_SKU_ITEM_NBR,
          GLBL_ITEM_ID_TYP,
          TRANS_DT, RTL_ORG_CD,
          SHIP_TO_ORG_CD, SHIP_TO_BSNS_UNIT_CD
             HAVING COUNT(*) > 1
         );
COMMIT;


-- DELETE DUPLICATE RECORDS FROM INTERFACE TABLE --


DELETE FROM DDR_I_RTL_SHIP_ITEM
    WHERE
      (GLBL_ITEM_ID,
   RTL_BSNS_UNIT_CD,
   RTL_SKU_ITEM_NBR,
   GLBL_ITEM_ID_TYP,
   TRANS_DT, RTL_ORG_CD,
   SHIP_TO_ORG_CD, SHIP_TO_BSNS_UNIT_CD)
    IN (
     SELECT
       GLBL_ITEM_ID,
    RTL_BSNS_UNIT_CD,
    RTL_SKU_ITEM_NBR,
    GLBL_ITEM_ID_TYP,
    TRANS_DT, RTL_ORG_CD,
    SHIP_TO_ORG_CD, SHIP_TO_BSNS_UNIT_CD
    FROM DDR_E_RTL_SHIP_ITEM
    GROUP BY
        GLBL_ITEM_ID,
      RTL_BSNS_UNIT_CD,
      RTL_SKU_ITEM_NBR,
      GLBL_ITEM_ID_TYP,
      TRANS_DT, RTL_ORG_CD,
      SHIP_TO_ORG_CD, SHIP_TO_BSNS_UNIT_CD
         HAVING COUNT(*) > 1
    );
COMMIT;

RETURN('Y');

END RTL_SHIP_ITEM_DUPS_FNC;

FUNCTION RTL_SL_RTN_DUPS_FNC(p_load_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2
AS
v_load_id NUMBER := NVL(p_load_id, set_load_id);
v_FUNC_MSG VARCHAR2(1) := 'N';

BEGIN

-- INSERT DUPLICATE RECORDS IN THE ERROR TABLE --


INSERT INTO DDR_E_RTL_SL_RTN_ITEM
    (REC_ID, LOAD_ID, ERR_REASON,
     GLBL_ITEM_ID, RTL_SKU_ITEM_NBR,
  GLBL_ITEM_ID_TYP, UOM, SLS_QTY,
  SLS_AMT, SLS_COST_AMT,RTRN_QTY,
  RTRN_AMT,RTRN_COST_AMT,SRC_SYS_IDNT,
  SRC_SYS_DT, PERIOD_TYP_FLAG,
  LOC_IDNT_CD, LOC_IDNT_FLAG,
  ORG_LVL_CD,SRC_IDNT_FLAG, ACTION_FLAG,
  TRANS_DT, PRMTN_FLAG, RTL_ORG_CD)
     SELECT REC_ID, v_load_id,'Duplicate Record',
     GLBL_ITEM_ID,RTL_SKU_ITEM_NBR,
     GLBL_ITEM_ID_TYP, UOM, SLS_QTY,
     SLS_AMT,SLS_COST_AMT,
     RTRN_QTY, RTRN_AMT,
     RTRN_COST_AMT, SRC_SYS_IDNT,
     SRC_SYS_DT, PERIOD_TYP_FLAG,
     LOC_IDNT_CD, LOC_IDNT_FLAG,
     ORG_LVL_CD,'I','N',TRANS_DT, PRMTN_FLAG, RTL_ORG_CD
      FROM DDR_I_RTL_SL_RTN_ITEM
       WHERE
           (LOC_IDNT_CD, GLBL_ITEM_ID,
          RTL_SKU_ITEM_NBR, GLBL_ITEM_ID_TYP,
             TRANS_DT, PERIOD_TYP_FLAG,
          LOC_IDNT_FLAG, ORG_LVL_CD, RTL_ORG_CD)
          IN (
             SELECT
          LOC_IDNT_CD, GLBL_ITEM_ID,
          RTL_SKU_ITEM_NBR, GLBL_ITEM_ID_TYP,
             TRANS_DT, PERIOD_TYP_FLAG,
          LOC_IDNT_FLAG, ORG_LVL_CD, RTL_ORG_CD
          FROM DDR_I_RTL_SL_RTN_ITEM
          GROUP BY
             LOC_IDNT_CD, GLBL_ITEM_ID,
           RTL_SKU_ITEM_NBR, GLBL_ITEM_ID_TYP,
           TRANS_DT, PERIOD_TYP_FLAG,
           LOC_IDNT_FLAG, ORG_LVL_CD, RTL_ORG_CD
             HAVING COUNT(*) > 1
         );
COMMIT;


-- DELETE DUPLICATE RECORDS FROM INTERFACE TABLE --


DELETE FROM DDR_I_RTL_SL_RTN_ITEM
    WHERE
       (LOC_IDNT_CD, GLBL_ITEM_ID,
    RTL_SKU_ITEM_NBR, GLBL_ITEM_ID_TYP,
       TRANS_DT, PERIOD_TYP_FLAG,
    LOC_IDNT_FLAG, ORG_LVL_CD, RTL_ORG_CD)
    IN (
     SELECT
       LOC_IDNT_CD, GLBL_ITEM_ID,
    RTL_SKU_ITEM_NBR, GLBL_ITEM_ID_TYP,
       TRANS_DT, PERIOD_TYP_FLAG,
    LOC_IDNT_FLAG, ORG_LVL_CD, RTL_ORG_CD
    FROM DDR_E_RTL_SL_RTN_ITEM
    GROUP BY
         LOC_IDNT_CD, GLBL_ITEM_ID,
       RTL_SKU_ITEM_NBR, GLBL_ITEM_ID_TYP,
         TRANS_DT, PERIOD_TYP_FLAG,
       LOC_IDNT_FLAG, ORG_LVL_CD, RTL_ORG_CD
         HAVING COUNT(*) > 1
    );
COMMIT;

RETURN('Y');

END RTL_SL_RTN_DUPS_FNC;

FUNCTION SLS_FRCST_ITEM_DUPS_FNC(p_load_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2
AS
v_load_id NUMBER := NVL(p_load_id, set_load_id);
BEGIN
-- INSERT DUPLICATE RECORDS IN THE ERROR TABLE --


INSERT INTO DDR_E_SLS_FRCST_ITEM
    (REC_ID, LOAD_ID, ERR_REASON,
    FRCST_SLS_UOM, FRCST_NBR,
    FRCST_TYP, GLBL_ITEM_ID,
    RTL_SKU_ITEM_NBR, GLBL_ITEM_ID_TYP,
    FRCST_SLS_QTY, FRCST_SLS_AMT,
    SRC_SYS_IDNT, SRC_SYS_DT,
    PERIOD_TYP_FLAG, LOC_IDNT_CD,
    LOC_IDNT_FLAG, ORG_LVL_CD,
    SRC_IDNT_FLAG, ACTION_FLAG,
    TRANS_DT, RTL_ORG_CD,FRCST_PURP
     )
    SELECT REC_ID,v_load_id,'Duplicate Record',
    FRCST_SLS_UOM, FRCST_NBR,
    FRCST_TYP, GLBL_ITEM_ID,
    RTL_SKU_ITEM_NBR, GLBL_ITEM_ID_TYP,
    FRCST_SLS_QTY, FRCST_SLS_AMT,
    SRC_SYS_IDNT, SRC_SYS_DT,
    PERIOD_TYP_FLAG, LOC_IDNT_CD,
    LOC_IDNT_FLAG, ORG_LVL_CD,
    'I','N', TRANS_DT, RTL_ORG_CD,FRCST_PURP
      FROM DDR_I_SLS_FRCST_ITEM
       WHERE
           (TRANS_DT, FRCST_NBR,
          FRCST_TYP, LOC_IDNT_CD,
          GLBL_ITEM_ID, RTL_SKU_ITEM_NBR,
          GLBL_ITEM_ID_TYP, PERIOD_TYP_FLAG,
          LOC_IDNT_FLAG, ORG_LVL_CD, SRC_SYS_DT, RTL_ORG_CD,FRCST_PURP)
          IN (
             SELECT
            TRANS_DT, FRCST_NBR,
          FRCST_TYP, LOC_IDNT_CD,
          GLBL_ITEM_ID, RTL_SKU_ITEM_NBR,
          GLBL_ITEM_ID_TYP, PERIOD_TYP_FLAG,
          LOC_IDNT_FLAG, ORG_LVL_CD, SRC_SYS_DT, RTL_ORG_CD,FRCST_PURP
          FROM DDR_I_SLS_FRCST_ITEM
          GROUP BY
              TRANS_DT, FRCST_NBR,
          FRCST_TYP, LOC_IDNT_CD,
          GLBL_ITEM_ID, RTL_SKU_ITEM_NBR,
          GLBL_ITEM_ID_TYP, PERIOD_TYP_FLAG,
          LOC_IDNT_FLAG, ORG_LVL_CD, SRC_SYS_DT, RTL_ORG_CD,FRCST_PURP
             HAVING COUNT(*) > 1
         );
COMMIT;


-- DELETE DUPLICATE RECORDS FROM INTERFACE TABLE --


DELETE FROM DDR_I_SLS_FRCST_ITEM
    WHERE
      (TRANS_DT, FRCST_NBR,
   FRCST_TYP, LOC_IDNT_CD,
   GLBL_ITEM_ID, RTL_SKU_ITEM_NBR,
   GLBL_ITEM_ID_TYP, PERIOD_TYP_FLAG,
   LOC_IDNT_FLAG, ORG_LVL_CD, SRC_SYS_DT, RTL_ORG_CD,FRCST_PURP)
    IN (
     SELECT
       TRANS_DT, FRCST_NBR, FRCST_TYP, LOC_IDNT_CD,
    GLBL_ITEM_ID, RTL_SKU_ITEM_NBR,
    GLBL_ITEM_ID_TYP, PERIOD_TYP_FLAG,
    LOC_IDNT_FLAG, ORG_LVL_CD, SRC_SYS_DT, RTL_ORG_CD,FRCST_PURP
    FROM DDR_E_SLS_FRCST_ITEM
    GROUP BY
        TRANS_DT, FRCST_NBR, FRCST_TYP,
      LOC_IDNT_CD, GLBL_ITEM_ID,
      RTL_SKU_ITEM_NBR, GLBL_ITEM_ID_TYP, PERIOD_TYP_FLAG,
      LOC_IDNT_FLAG, ORG_LVL_CD, SRC_SYS_DT, RTL_ORG_CD,FRCST_PURP
         HAVING COUNT(*) > 1
    );
COMMIT;

RETURN('Y');

END SLS_FRCST_ITEM_DUPS_FNC;

FUNCTION decide_dedup_chk RETURN VARCHAR2 IS
RT VARCHAR2(5);
BEGIN
select LKUP_NAME into RT  from DDR_R_LKUP_MST
where LKUP_TYP_CD='SYS_PARAM'
and LKUP_CD='PERFORM_DUP_CHECK';

RETURN RT;
END decide_dedup_chk;

FUNCTION decide_discover_mode RETURN VARCHAR2 IS
RT VARCHAR2(5);
BEGIN
select LKUP_NAME into RT  from DDR_R_LKUP_MST
where LKUP_TYP_CD='SYS_PARAM'
and LKUP_CD='DISCOVERY_MODE';
RETURN RT;
END decide_discover_mode;

FUNCTION DECIDE_RUN_MAP_ERR(map_nm IN VARCHAR2, map_stg IN VARCHAR2) RETURN NUMBER IS
cnt_rows Number;
tab_name_ Varchar2(250);
BEGIN
cnt_rows := 0;
tab_name_ := 'select count(1) from '||map_nm || ', ' || map_stg || ' where '|| map_nm||'.load_id = '|| map_stg || '.load_id and rownum <2';
execute immediate tab_name_ into cnt_rows;
RETURN cnt_rows;
END DECIDE_RUN_MAP_ERR;

FUNCTION decide_run_typ RETURN VARCHAR2 IS
RT VARCHAR2(5);
BEGIN
select LKUP_NAME into RT  from DDR_R_LKUP_MST
where LKUP_TYP_CD='SYS_PARAM'
and LKUP_CD='RUN_TYPE_FACT';

RETURN RT;
END decide_run_typ;

FUNCTION decide_SF_MAP RETURN VARCHAR2 IS
RT VARCHAR2(5);
BEGIN
select LKUP_NAME into RT  from DDR_R_LKUP_MST
where LKUP_TYP_CD='SYS_PARAM'
and LKUP_CD='STAGE_TO_TARGET_VALIDATION';

RETURN RT;
END decide_SF_MAP;

FUNCTION DECIDE_RUN_CNT_STG(map_nm IN VARCHAR2) RETURN NUMBER IS
cnt_rows Number;
tab_name_ Varchar2(250);
BEGIN
cnt_rows := 0;
tab_name_ := 'select count(1) from '||map_nm|| ' where rownum <2';
execute immediate tab_name_ into cnt_rows;
RETURN cnt_rows;
END DECIDE_RUN_CNT_STG;

FUNCTION DECIDE_RUN_MAP(map_nm IN VARCHAR2) RETURN NUMBER IS
cnt_rows Number;
tab_name_ Varchar2(250);
BEGIN
cnt_rows := 0;
tab_name_ := 'select count(1) from '||map_nm|| ' where rownum <2';
execute immediate tab_name_ into cnt_rows;
RETURN cnt_rows;
END DECIDE_RUN_MAP;

PROCEDURE trunc_tble_pub( p_tbl_name IN VARCHAR2)
as
Begin
   EXECUTE IMMEDIATE 'TRUNCATE TABLE '|| 'DDR.' || p_tbl_name;
End trunc_tble_pub;


FUNCTION get_map_run_id(p_audit_id VARCHAR2) RETURN NUMBER IS

BEGIN
  IF p_audit_id = c_audit_id THEN  --{
    RETURN c_map_id;
  ELSE  --}{
    c_audit_id := p_audit_id;
    c_map_id := set_load_id;
    RETURN c_map_id;
  END IF;  --}

END get_map_run_id;

FUNCTION rtl_sl_rtn_dups_s_fnc(p_load_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2
AS
v_load_id NUMBER := NVL(p_load_id, set_load_id);
v_FUNC_MSG VARCHAR2(1) := 'N';

CURSOR c1 IS
SELECT *
FROM   ddr_s_rtl_sl_rtn_item
WHERE  (day_cd,org_bsns_unit_id,mfg_sku_item_id,rtl_sku_item_id)
IN (SELECT day_cd,org_bsns_unit_id,mfg_sku_item_id,rtl_sku_item_id
    FROM ddr_s_rtl_sl_rtn_item
    GROUP BY day_cd,org_bsns_unit_id,mfg_sku_item_id,rtl_sku_item_id
    HAVING count(*) > 1)
FOR UPDATE;
BEGIN

-- INSERT DUPLICATE RECORDS IN THE ERROR TABLE --

FOR rec IN c1 LOOP  --{
INSERT INTO ddr_e_rtl_sl_rtn_item
     (crncy_cd
     ,day_cd
     ,eff_from_dt
     ,eff_to_dt
     ,glbl_item_id
     ,glbl_item_id_typ
     ,item_bsns_unt_assc_id
     ,itm_typ
     ,load_id
     ,mfg_org_cd
     ,mfg_sku_item_id
     ,mfg_sku_item_nbr
     ,org_bsns_unit_id
     ,prmtn_flag
     ,rec_id
     ,rtl_bsns_unit_cd
     ,rtl_org_cd
     ,rtl_sku_item_id
     ,rtl_sku_item_nbr
     ,rtrn_amt
     ,rtrn_amt_lcl
     ,rtrn_amt_rpt
     ,rtrn_cost_amt
     ,rtrn_cost_amt_lcl
     ,rtrn_cost_amt_rpt
     ,rtrn_qty
     ,rtrn_qty_alt
     ,rtrn_qty_prmry
     ,sls_amt
     ,sls_amt_lcl
     ,sls_amt_rpt
     ,sls_cost_amt
     ,sls_cost_amt_lcl
     ,sls_cost_amt_rpt
     ,sls_qty
     ,sls_qty_alt
     ,sls_qty_prmry
     ,src_sys_dt
     ,src_sys_idnt
     ,trans_dt
     ,uom_cd
     ,uom_cd_alt
     ,uom_cd_prmry
     ,src_idnt_flag
     ,action_flag
     ,err_reason
     ) VALUES
     (rec.crncy_cd
     ,rec.day_cd
     ,rec.eff_from_dt
     ,rec.eff_to_dt
     ,rec.glbl_item_id
     ,rec.glbl_item_id_typ
     ,rec.item_bsns_unt_assc_id
     ,rec.itm_typ
     ,v_load_id
     ,rec.mfg_org_cd
     ,rec.mfg_sku_item_id
     ,rec.mfg_sku_item_nbr
     ,rec.org_bsns_unit_id
     ,rec.prmtn_flag
     ,rec.rec_id
     ,rec.rtl_bsns_unit_cd
     ,rec.rtl_org_cd
     ,rec.rtl_sku_item_id
     ,rec.rtl_sku_item_nbr
     ,rec.rtrn_amt
     ,rec.rtrn_amt_lcl
     ,rec.rtrn_amt_rpt
     ,rec.rtrn_cost_amt
     ,rec.rtrn_cost_amt_lcl
     ,rec.rtrn_cost_amt_rpt
     ,rec.rtrn_qty
     ,rec.rtrn_qty_alt
     ,rec.rtrn_qty_prmry
     ,rec.sls_amt
     ,rec.sls_amt_lcl
     ,rec.sls_amt_rpt
     ,rec.sls_cost_amt
     ,rec.sls_cost_amt_lcl
     ,rec.sls_cost_amt_rpt
     ,rec.sls_qty
     ,rec.sls_qty_alt
     ,rec.sls_qty_prmry
     ,rec.src_sys_dt
     ,rec.src_sys_idnt
     ,rec.trans_dt
     ,rec.uom_cd
     ,rec.uom_cd_alt
     ,rec.uom_cd_prmry
     ,'S'
     ,'N'
     ,'Duplicate record - Staging'
     );

-- delete duplicate records from staging table --
DELETE ddr_s_rtl_sl_rtn_item
WHERE CURRENT OF c1;

END LOOP;  --}

COMMIT;

RETURN('Y');

END rtl_sl_rtn_dups_s_fnc;


FUNCTION rtl_inv_item_dups_s_fnc(p_load_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2
AS
v_load_id NUMBER := NVL(p_load_id, set_load_id);
v_FUNC_MSG VARCHAR2(1) := 'N';

CURSOR c1 IS
SELECT *
FROM   ddr_s_rtl_inv_item
WHERE  (day_cd,org_bsns_unit_id,mfg_sku_item_id,rtl_sku_item_id,inv_loc_id)
IN (SELECT day_cd,org_bsns_unit_id,mfg_sku_item_id,rtl_sku_item_id,inv_loc_id
    FROM ddr_s_rtl_inv_item
    GROUP BY day_cd,org_bsns_unit_id,mfg_sku_item_id,rtl_sku_item_id,inv_loc_id
    HAVING count(*) > 1)
FOR UPDATE;
BEGIN

-- INSERT DUPLICATE RECORDS IN THE ERROR TABLE --

FOR rec IN c1 LOOP  --{
INSERT INTO ddr_e_rtl_inv_item
     (bck_ordr_qty
     ,bck_ordr_qty_alt
     ,bck_ordr_qty_prmry
     ,bckordr_net_cost_amt
     ,bckordr_net_cost_amt_lcl
     ,bckordr_net_cost_amt_rpt
     ,bckordr_rtl_amt
     ,bckordr_rtl_amt_lcl
     ,bckordr_rtl_amt_rpt
     ,crncy_cd
     ,day_cd
     ,glbl_item_id
     ,glbl_item_id_typ
     ,in_transit_net_cost_amt
     ,in_transit_net_cost_amt_lcl
     ,in_transit_net_cost_amt_rpt
     ,in_transit_qty
     ,in_transit_qty_alt
     ,in_transit_qty_prmry
     ,in_transit_rtl_amt
     ,in_transit_rtl_amt_lcl
     ,in_transit_rtl_amt_rpt
     ,inv_loc_cd
     ,inv_loc_id
     ,inv_loc_typ_cd
     ,itm_typ
     ,load_id
     ,mfg_org_cd
     ,mfg_sku_item_id
     ,on_hand_net_cost_amt
     ,on_hand_net_cost_amt_lcl
     ,on_hand_net_cost_amt_rpt
     ,on_hand_qty
     ,on_hand_qty_alt
     ,on_hand_qty_prmry
     ,on_hand_rtl_amt
     ,on_hand_rtl_amt_lcl
     ,on_hand_rtl_amt_rpt
     ,org_bsns_unit_id
     ,qlty_hold_net_cost_amt
     ,qlty_hold_net_cost_amt_lcl
     ,qlty_hold_net_cost_amt_rpt
     ,qlty_hold_qty
     ,qlty_hold_qty_alt
     ,qlty_hold_qty_prmry
     ,qlty_hold_rtl_amt
     ,qlty_hold_rtl_amt_lcl
     ,qlty_hold_rtl_amt_rpt
     ,rec_id
     ,recvd_net_cost_amt
     ,recvd_net_cost_amt_lcl
     ,recvd_net_cost_amt_rpt
     ,recvd_qty
     ,recvd_qty_alt
     ,recvd_qty_prmry
     ,recvd_rtl_amt
     ,recvd_rtl_amt_lcl
     ,recvd_rtl_amt_rpt
     ,rtl_bsns_unit_cd
     ,rtl_org_cd
     ,rtl_sku_item_id
     ,rtl_sku_item_nbr
     ,src_sys_dt
     ,src_sys_idnt
     ,trans_dt
     ,uom_cd
     ,uom_cd_alt
     ,uom_cd_prmry
     ,src_idnt_flag
     ,action_flag
     ,err_reason
     ) VALUES
     (rec.bck_ordr_qty
     ,rec.bck_ordr_qty_alt
     ,rec.bck_ordr_qty_prmry
     ,rec.bckordr_net_cost_amt
     ,rec.bckordr_net_cost_amt_lcl
     ,rec.bckordr_net_cost_amt_rpt
     ,rec.bckordr_rtl_amt
     ,rec.bckordr_rtl_amt_lcl
     ,rec.bckordr_rtl_amt_rpt
     ,rec.crncy_cd
     ,rec.day_cd
     ,rec.glbl_item_id
     ,rec.glbl_item_id_typ
     ,rec.in_transit_net_cost_amt
     ,rec.in_transit_net_cost_amt_lcl
     ,rec.in_transit_net_cost_amt_rpt
     ,rec.in_transit_qty
     ,rec.in_transit_qty_alt
     ,rec.in_transit_qty_prmry
     ,rec.in_transit_rtl_amt
     ,rec.in_transit_rtl_amt_lcl
     ,rec.in_transit_rtl_amt_rpt
     ,rec.inv_loc_cd
     ,rec.inv_loc_id
     ,rec.inv_loc_typ_cd
     ,rec.itm_typ
     ,v_load_id
     ,rec.mfg_org_cd
     ,rec.mfg_sku_item_id
     ,rec.on_hand_net_cost_amt
     ,rec.on_hand_net_cost_amt_lcl
     ,rec.on_hand_net_cost_amt_rpt
     ,rec.on_hand_qty
     ,rec.on_hand_qty_alt
     ,rec.on_hand_qty_prmry
     ,rec.on_hand_rtl_amt
     ,rec.on_hand_rtl_amt_lcl
     ,rec.on_hand_rtl_amt_rpt
     ,rec.org_bsns_unit_id
     ,rec.qlty_hold_net_cost_amt
     ,rec.qlty_hold_net_cost_amt_lcl
     ,rec.qlty_hold_net_cost_amt_rpt
     ,rec.qlty_hold_qty
     ,rec.qlty_hold_qty_alt
     ,rec.qlty_hold_qty_prmry
     ,rec.qlty_hold_rtl_amt
     ,rec.qlty_hold_rtl_amt_lcl
     ,rec.qlty_hold_rtl_amt_rpt
     ,rec.rec_id
     ,rec.recvd_net_cost_amt
     ,rec.recvd_net_cost_amt_lcl
     ,rec.recvd_net_cost_amt_rpt
     ,rec.recvd_qty
     ,rec.recvd_qty_alt
     ,rec.recvd_qty_prmry
     ,rec.recvd_rtl_amt
     ,rec.recvd_rtl_amt_lcl
     ,rec.recvd_rtl_amt_rpt
     ,rec.rtl_bsns_unit_cd
     ,rec.rtl_org_cd
     ,rec.rtl_sku_item_id
     ,rec.rtl_sku_item_nbr
     ,rec.src_sys_dt
     ,rec.src_sys_idnt
     ,rec.trans_dt
     ,rec.uom_cd
     ,rec.uom_cd_alt
     ,rec.uom_cd_prmry
     ,'S'
     ,'N'
     ,'Duplicate record - Staging'
     );

-- delete duplicate records from staging table --
DELETE ddr_s_rtl_inv_item
WHERE CURRENT OF c1;

END LOOP;  --}

COMMIT;

RETURN('Y');

END rtl_inv_item_dups_s_fnc;

FUNCTION rtl_ship_item_dups_s_fnc(p_load_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2
AS
v_load_id NUMBER := NVL(p_load_id, set_load_id);
v_FUNC_MSG VARCHAR2(1) := 'N';

CURSOR c1 IS
SELECT *
FROM   ddr_s_rtl_ship_item
WHERE
(day_cd,org_bsns_unit_id,mfg_sku_item_id,rtl_sku_item_id,ship_to_bsns_unit_id)
IN (SELECT day_cd,org_bsns_unit_id,mfg_sku_item_id,rtl_sku_item_id,ship_to_bsns_unit_id
    FROM ddr_s_rtl_ship_item
    GROUP BY day_cd,org_bsns_unit_id,mfg_sku_item_id,rtl_sku_item_id,ship_to_bsns_unit_id
    HAVING count(*) > 1)
FOR UPDATE;
BEGIN

-- INSERT DUPLICATE RECORDS IN THE ERROR TABLE --

FOR rec IN c1 LOOP  --{
INSERT INTO ddr_e_rtl_ship_item
     (crncy_cd
     ,day_cd
     ,glbl_item_id
     ,glbl_item_id_typ
     ,itm_typ
     ,load_id
     ,mfg_org_cd
     ,mfg_sku_item_id
     ,org_bsns_unit_id
     ,rec_id
     ,rtl_bsns_unit_cd
     ,rtl_org_cd
     ,rtl_sku_item_id
     ,rtl_sku_item_nbr
     ,ship_amt
     ,ship_amt_lcl
     ,ship_amt_rpt
     ,ship_qty
     ,ship_qty_alt
     ,ship_qty_prmry
     ,src_sys_dt
     ,src_sys_idnt
     ,trans_dt
     ,uom_cd
     ,uom_cd_alt
     ,uom_cd_prmry
     ,src_idnt_flag
     ,action_flag
     ,err_reason
     ,ship_to_org_cd
     ,ship_to_bsns_unit_id
     ,ship_to_bsns_unit_cd
     ,ship_cost
     ,ship_cost_rpt
     ,ship_cost_lcl
     ) VALUES
     (rec.crncy_cd
     ,rec.day_cd
     ,rec.glbl_item_id
     ,rec.glbl_item_id_typ
     ,rec.itm_typ
     ,v_load_id
     ,rec.mfg_org_cd
     ,rec.mfg_sku_item_id
     ,rec.org_bsns_unit_id
     ,rec.rec_id
     ,rec.rtl_bsns_unit_cd
     ,rec.rtl_org_cd
     ,rec.rtl_sku_item_id
     ,rec.rtl_sku_item_nbr
     ,rec.ship_amt
     ,rec.ship_amt_lcl
     ,rec.ship_amt_rpt
     ,rec.ship_qty
     ,rec.ship_qty_alt
     ,rec.ship_qty_prmry
     ,rec.src_sys_dt
     ,rec.src_sys_idnt
     ,rec.trans_dt
     ,rec.uom_cd
     ,rec.uom_cd_alt
     ,rec.uom_cd_prmry
     ,'S'
     ,'N'
     ,'Duplicate record - Staging'
     ,rec.ship_to_org_cd
     ,rec.ship_to_bsns_unit_id
     ,rec.ship_to_bsns_unit_cd
     ,rec.ship_cost
     ,rec.ship_cost_rpt
     ,rec.ship_cost_lcl
     );

-- delete duplicate records from staging table --
DELETE ddr_s_rtl_ship_item
WHERE CURRENT OF c1;

END LOOP;  --}

COMMIT;

RETURN('Y');

END rtl_ship_item_dups_s_fnc;

FUNCTION rtl_ordr_item_dups_s_fnc(p_load_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2
AS
v_load_id NUMBER := NVL(p_load_id, set_load_id);
v_FUNC_MSG VARCHAR2(1) := 'N';

CURSOR c1 IS
SELECT *
FROM   ddr_s_rtl_ordr_item
WHERE  (day_cd,org_bsns_unit_id,mfg_sku_item_id,rtl_sku_item_id)
IN (SELECT day_cd,org_bsns_unit_id,mfg_sku_item_id,rtl_sku_item_id
    FROM ddr_s_rtl_ordr_item
    GROUP BY day_cd,org_bsns_unit_id,mfg_sku_item_id,rtl_sku_item_id
    HAVING count(*) > 1)
FOR UPDATE;
BEGIN

-- INSERT DUPLICATE RECORDS IN THE ERROR TABLE --

FOR rec IN c1 LOOP  --{
INSERT INTO ddr_e_rtl_ordr_item
     (crncy_cd
     ,day_cd
     ,glbl_item_id
     ,glbl_item_id_typ
     ,itm_typ
     ,load_id
     ,mfg_org_cd
     ,mfg_sku_item_id
     ,ordr_amt
     ,ordr_amt_lcl
     ,ordr_amt_rpt
     ,ordr_qty
     ,ordr_qty_alt
     ,ordr_qty_prmry
     ,org_bsns_unit_id
     ,rec_id
     ,rtl_bsns_unit_cd
     ,rtl_org_cd
     ,rtl_sku_item_id
     ,rtl_sku_item_nbr
     ,src_sys_dt
     ,src_sys_idnt
     ,trans_dt
     ,uom_cd
     ,uom_cd_alt
     ,uom_cd_prmry
     ,src_idnt_flag
     ,action_flag
     ,err_reason
     ) VALUES
     (rec.crncy_cd
     ,rec.day_cd
     ,rec.glbl_item_id
     ,rec.glbl_item_id_typ
     ,rec.itm_typ
     ,v_load_id
     ,rec.mfg_org_cd
     ,rec.mfg_sku_item_id
     ,rec.ordr_amt
     ,rec.ordr_amt_lcl
     ,rec.ordr_amt_rpt
     ,rec.ordr_qty
     ,rec.ordr_qty_alt
     ,rec.ordr_qty_prmry
     ,rec.org_bsns_unit_id
     ,rec.rec_id
     ,rec.rtl_bsns_unit_cd
     ,rec.rtl_org_cd
     ,rec.rtl_sku_item_id
     ,rec.rtl_sku_item_nbr
     ,rec.src_sys_dt
     ,rec.src_sys_idnt
     ,rec.trans_dt
     ,rec.uom_cd
     ,rec.uom_cd_alt
     ,rec.uom_cd_prmry
     ,'S'
     ,'N'
     ,'Duplicate record - Staging'
     );

-- delete duplicate records from staging table --
DELETE ddr_s_rtl_ordr_item
WHERE CURRENT OF c1;

END LOOP;  --}

COMMIT;

RETURN('Y');

END rtl_ordr_item_dups_s_fnc;

FUNCTION sls_frcst_item_dups_s_fnc(p_load_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2
AS
v_load_id NUMBER := NVL(p_load_id, set_load_id);
v_FUNC_MSG VARCHAR2(1) := 'N';

CURSOR c1 IS
SELECT *
FROM   ddr_s_sls_frcst_item
WHERE (frcst_vrsn,day_cd,org_bsns_unit_id,mfg_sku_item_id,rtl_sku_item_id,frcst_purp,frcst_typ)
IN (SELECT frcst_vrsn,day_cd,org_bsns_unit_id,mfg_sku_item_id,rtl_sku_item_id,frcst_purp,frcst_typ
    FROM ddr_s_sls_frcst_item
    GROUP BY frcst_vrsn,day_cd,org_bsns_unit_id,mfg_sku_item_id,rtl_sku_item_id,frcst_purp,frcst_typ
    HAVING count(*) > 1)
FOR UPDATE;
BEGIN

-- INSERT DUPLICATE RECORDS IN THE ERROR TABLE --

FOR rec IN c1 LOOP  --{
INSERT INTO ddr_e_sls_frcst_item
     (crncy_cd
     ,day_cd
     ,frcst_nbr
     ,frcst_sls_amt
     ,frcst_sls_amt_lcl
     ,frcst_sls_amt_rpt
     ,frcst_sls_qty
     ,frcst_sls_qty_alt
     ,frcst_sls_qty_prmry
     ,frcst_sls_uom_cd
     ,frcst_sls_uom_cd_alt
     ,frcst_sls_uom_cd_prmry
     ,frcst_typ
     ,frcst_vrsn
     ,glbl_item_id
     ,glbl_item_id_typ
     ,itm_typ
     ,load_id
     ,mfg_org_cd
     ,mfg_sku_item_id
     ,org_bsns_unit_id
     ,rec_id
     ,bsns_unit_cd
     ,rtl_org_cd
     ,rtl_sku_item_id
     ,rtl_sku_item_nbr
     ,src_sys_dt
     ,src_sys_idnt
     ,trans_dt
     ,src_idnt_flag
     ,action_flag
     ,err_reason
     ,frcst_purp
     ) VALUES
     (rec.crncy_cd
     ,rec.day_cd
     ,rec.frcst_nbr
     ,rec.frcst_sls_amt
     ,rec.frcst_sls_amt_lcl
     ,rec.frcst_sls_amt_rpt
     ,rec.frcst_sls_qty
     ,rec.frcst_sls_qty_alt
     ,rec.frcst_sls_qty_prmry
     ,rec.frcst_sls_uom_cd
     ,rec.frcst_sls_uom_cd_alt
     ,rec.frcst_sls_uom_cd_prmry
     ,rec.frcst_typ
     ,rec.frcst_vrsn
     ,rec.glbl_item_id
     ,rec.glbl_item_id_typ
     ,rec.itm_typ
     ,v_load_id
     ,rec.mfg_org_cd
     ,rec.mfg_sku_item_id
     ,rec.org_bsns_unit_id
     ,rec.rec_id
     ,rec.bsns_unit_cd
     ,rec.rtl_org_cd
     ,rec.rtl_sku_item_id
     ,rec.rtl_sku_item_nbr
     ,rec.src_sys_dt
     ,rec.src_sys_idnt
     ,rec.trans_dt
     ,'S'
     ,'N'
     ,'Duplicate record - Staging'
     ,rec.frcst_purp
     );

-- delete duplicate records from staging table --
DELETE ddr_s_sls_frcst_item
WHERE CURRENT OF c1;

END LOOP;  --}

COMMIT;

RETURN('Y');

END sls_frcst_item_dups_s_fnc;

FUNCTION prmtn_pln_dups_s_fnc(p_load_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2
AS
v_load_id NUMBER := NVL(p_load_id, set_load_id);
v_FUNC_MSG VARCHAR2(1) := 'N';

CURSOR c1 IS
SELECT *
FROM   ddr_s_prmtn_pln
WHERE  (prmtn_typ,prmtn_from_dt,prmtn_to_dt,org_bsns_unit_id,mfg_sku_item_id,rtl_sku_item_id)
IN (SELECT prmtn_typ,prmtn_from_dt,prmtn_to_dt,org_bsns_unit_id,mfg_sku_item_id,rtl_sku_item_id
    FROM ddr_s_prmtn_pln
    GROUP BY prmtn_typ,prmtn_from_dt,prmtn_to_dt,org_bsns_unit_id,mfg_sku_item_id,rtl_sku_item_id
    HAVING count(*) > 1)
FOR UPDATE;
BEGIN

-- INSERT DUPLICATE RECORDS IN THE ERROR TABLE --

FOR rec IN c1 LOOP  --{
INSERT INTO ddr_e_prmtn_pln
     (crncy_cd
     ,glbl_item_id
     ,glbl_item_id_typ
     ,itm_typ
     ,load_id
     ,mfg_org_cd
     ,mfg_sku_item_id
     ,org_bsns_unit_id
     ,prmtn_from_dt
     ,prmtn_price_amt
     ,prmtn_price_amt_lcl
     ,prmtn_price_amt_rpt
     ,prmtn_to_dt
     ,prmtn_typ
     ,rec_id
     ,rtl_bsns_unit_cd
     ,rtl_org_cd
     ,rtl_sku_item_id
     ,rtl_sku_item_nbr
     ,src_sys_dt
     ,src_sys_idnt
     ,trans_dt
     ,src_idnt_flag
     ,action_flag
     ,err_reason
     ,ATTRIBUTE1
     ,ATTRIBUTE2
     ,ATTRIBUTE3
     ,ATTRIBUTE4
     ,ATTRIBUTE5
     ,ATTRIBUTE6
     ,ATTRIBUTE7
     ,ATTRIBUTE8
     ,ATTRIBUTE9
     ,ATTRIBUTE10
     ,ATTRIBUTE11
     ,ATTRIBUTE12
     ,ATTRIBUTE13
     ,ATTRIBUTE14
     ,ATTRIBUTE15
     ,ATTRIBUTE16
     ,ATTRIBUTE17
     ,ATTRIBUTE18
     ,ATTRIBUTE19
     ,ATTRIBUTE20
     ) VALUES
     (rec.crncy_cd
     ,rec.glbl_item_id
     ,rec.glbl_item_id_typ
     ,rec.itm_typ
     ,v_load_id
     ,rec.mfg_org_cd
     ,rec.mfg_sku_item_id
     ,rec.org_bsns_unit_id
     ,rec.prmtn_from_dt
     ,rec.prmtn_price_amt
     ,rec.prmtn_price_amt_lcl
     ,rec.prmtn_price_amt_rpt
     ,rec.prmtn_to_dt
     ,rec.prmtn_typ
     ,rec.rec_id
     ,rec.rtl_bsns_unit_cd
     ,rec.rtl_org_cd
     ,rec.rtl_sku_item_id
     ,rec.rtl_sku_item_nbr
     ,rec.src_sys_dt
     ,rec.src_sys_idnt
     ,rec.trans_dt
     ,'S'
     ,'N'
     ,'Duplicate record - Staging'
     ,rec.ATTRIBUTE1
     ,rec.ATTRIBUTE2
     ,rec.ATTRIBUTE3
     ,rec.ATTRIBUTE4
     ,rec.ATTRIBUTE5
     ,rec.ATTRIBUTE6
     ,rec.ATTRIBUTE7
     ,rec.ATTRIBUTE8
     ,rec.ATTRIBUTE9
     ,rec.ATTRIBUTE10
     ,rec.ATTRIBUTE11
     ,rec.ATTRIBUTE12
     ,rec.ATTRIBUTE13
     ,rec.ATTRIBUTE14
     ,rec.ATTRIBUTE15
     ,rec.ATTRIBUTE16
     ,rec.ATTRIBUTE17
     ,rec.ATTRIBUTE18
     ,rec.ATTRIBUTE19
     ,rec.ATTRIBUTE20
     );

-- delete duplicate records from staging table --
DELETE ddr_s_prmtn_pln
WHERE CURRENT OF c1;

END LOOP;  --}

      COMMIT;

RETURN('Y');

END prmtn_pln_dups_s_fnc;


FUNCTION SYND_CNSMPTN_DATA_DUPS_FNC(p_load_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2 AS

v_load_id NUMBER := NVL(p_load_id, set_load_id);

BEGIN

-- INSERT DUPLICATE RECORDS IN THE ERROR TABLE --

INSERT INTO DDR_E_SYND_CNSMPTN_DATA
     (REC_ID, LOAD_ID, ERR_REASON,
      SRC_CD, PROD_KEY, MFG_ITM_HCHY_LVL,
      MFG_ITM_HCHY_CD, GEO_KEY, MKT_AREA_CD,MKT_AREA_TYP, RTL_ORG_HCHY_LVL,
      RTL_ORG_HCHY_CD, GEO_RGN_CD, GEO_SUB_RGN_CD, CHNL_TYP_CD,
      PERIOD_END_DATE, TIME_HCHY_LVL, SRC_SYS_IDNT,
      SRC_SYS_DT, SRC_IDNT_FLAG, ACTION_FLAG, MEASURE_SET,
      MEASURE1, MEASURE2, MEASURE3, MEASURE4, MEASURE5,
      MEASURE6, MEASURE7, MEASURE8, MEASURE9, MEASURE10,
      MEASURE11, MEASURE12, MEASURE13, MEASURE14, MEASURE15,
      MEASURE16, MEASURE17, MEASURE18, MEASURE19, MEASURE20,
      MEASURE21, MEASURE22, MEASURE23, MEASURE24, MEASURE25,
      MEASURE26, MEASURE27, MEASURE28, MEASURE29, MEASURE30,
      MEASURE31, MEASURE32, MEASURE33, MEASURE34, MEASURE35,
      MEASURE36, MEASURE37, MEASURE38, MEASURE39, MEASURE40,
      MEASURE41, MEASURE42, MEASURE43, MEASURE44, MEASURE45,
      MEASURE46, MEASURE47, MEASURE48, MEASURE49, MEASURE50,
      MEASURE51, MEASURE52, MEASURE53, MEASURE54, MEASURE55,
      MEASURE56, MEASURE57, MEASURE58, MEASURE59, MEASURE60,
      MEASURE61, MEASURE62, MEASURE63, MEASURE64, MEASURE65,
      MEASURE66, MEASURE67, MEASURE68, MEASURE69, MEASURE70,
      MEASURE71, MEASURE72, MEASURE73, MEASURE74, MEASURE75,
      MEASURE76, MEASURE77, MEASURE78, MEASURE79, MEASURE80,
      MEASURE81, MEASURE82, MEASURE83, MEASURE84, MEASURE85,
      MEASURE86, MEASURE87, MEASURE88, MEASURE89, MEASURE90,
      MEASURE91, MEASURE92, MEASURE93, MEASURE94, MEASURE95,
      MEASURE96, MEASURE97, MEASURE98, MEASURE99, MEASURE100,
      RTL_ORG_CD,AO_HCHY_CD,ACCT_CD
     )
    SELECT REC_ID, v_load_id,'Duplicate Record',
           SRC_CD, PROD_KEY, MFG_ITM_HCHY_LVL,
           MFG_ITM_HCHY_CD, GEO_KEY, MKT_AREA_CD,MKT_AREA_TYP, RTL_ORG_HCHY_LVL,
           RTL_ORG_HCHY_CD, GEO_RGN_CD, GEO_SUB_RGN_CD, CHNL_TYP_CD,
           PERIOD_END_DATE, TIME_HCHY_LVL, SRC_SYS_IDNT,
           SRC_SYS_DT, 'I','N', MEASURE_SET,
           MEASURE1, MEASURE2, MEASURE3, MEASURE4, MEASURE5,
           MEASURE6, MEASURE7, MEASURE8, MEASURE9, MEASURE10,
           MEASURE11, MEASURE12, MEASURE13, MEASURE14, MEASURE15,
           MEASURE16, MEASURE17, MEASURE18, MEASURE19, MEASURE20,
           MEASURE21, MEASURE22, MEASURE23, MEASURE24, MEASURE25,
           MEASURE26, MEASURE27, MEASURE28, MEASURE29, MEASURE30,
           MEASURE31, MEASURE32, MEASURE33, MEASURE34, MEASURE35,
           MEASURE36, MEASURE37, MEASURE38, MEASURE39, MEASURE40,
           MEASURE41, MEASURE42, MEASURE43, MEASURE44, MEASURE45,
           MEASURE46, MEASURE47, MEASURE48, MEASURE49, MEASURE50,
           MEASURE51, MEASURE52, MEASURE53, MEASURE54, MEASURE55,
           MEASURE56, MEASURE57, MEASURE58, MEASURE59, MEASURE60,
           MEASURE61, MEASURE62, MEASURE63, MEASURE64, MEASURE65,
           MEASURE66, MEASURE67, MEASURE68, MEASURE69, MEASURE70,
           MEASURE71, MEASURE72, MEASURE73, MEASURE74, MEASURE75,
           MEASURE76, MEASURE77, MEASURE78, MEASURE79, MEASURE80,
           MEASURE81, MEASURE82, MEASURE83, MEASURE84, MEASURE85,
           MEASURE86, MEASURE87, MEASURE88, MEASURE89, MEASURE90,
           MEASURE91, MEASURE92, MEASURE93, MEASURE94, MEASURE95,
           MEASURE96, MEASURE97, MEASURE98, MEASURE99, MEASURE100,
           RTL_ORG_CD,AO_HCHY_CD,ACCT_CD
      FROM DDR_I_SYND_CNSMPTN_DATA
       WHERE
          (MEASURE_SET, SRC_CD, NVL(PROD_KEY,'PROD'), NVL(GEO_KEY,'GEO'),
           NVL(CHNL_TYP_CD,'CHNL'), NVL(GEO_SUB_RGN_CD,'SUB'),
           NVL(GEO_RGN_CD,'RGN'), NVL(MFG_ITM_HCHY_LVL,'LVL'),
           NVL(MFG_ITM_HCHY_CD,'HCHY'), NVL(MKT_AREA_CD,'MKT'),NVL(MKT_AREA_TYP,'MKT_TYP'),
           NVL(RTL_ORG_HCHY_LVL,'ORG_LVL'), NVL(RTL_ORG_HCHY_CD,'ORG_HCHY'),
           PERIOD_END_DATE, NVL(RTL_ORG_CD,'ORG_CD'), NVL(AO_HCHY_CD,'AO_HCHY'),NVL(ACCT_CD,'ACCT_CD'))
        IN (
           SELECT
              MEASURE_SET, SRC_CD, NVL(PROD_KEY,'PROD'), NVL(GEO_KEY,'GEO'),
              NVL(CHNL_TYP_CD,'CHNL'), NVL(GEO_SUB_RGN_CD,'SUB'),
              NVL(GEO_RGN_CD,'RGN'), NVL(MFG_ITM_HCHY_LVL,'LVL'),
              NVL(MFG_ITM_HCHY_CD,'HCHY'), NVL(MKT_AREA_CD,'MKT'),NVL(MKT_AREA_TYP,'MKT_TYP'),
              NVL(RTL_ORG_HCHY_LVL,'ORG_LVL'), NVL(RTL_ORG_HCHY_CD,'ORG_HCHY'),
              PERIOD_END_DATE, NVL(RTL_ORG_CD,'ORG_CD') ,NVL(AO_HCHY_CD,'AO_HCHY'),NVL(ACCT_CD,		'ACCT_CD')
           FROM DDR_I_SYND_CNSMPTN_DATA
           GROUP BY
              MEASURE_SET, SRC_CD, NVL(PROD_KEY,'PROD'), NVL(GEO_KEY,'GEO'),
              NVL(CHNL_TYP_CD,'CHNL'), NVL(GEO_SUB_RGN_CD,'SUB'),
              NVL(GEO_RGN_CD,'RGN'), NVL(MFG_ITM_HCHY_LVL,'LVL'),
              NVL(MFG_ITM_HCHY_CD,'HCHY'), NVL(MKT_AREA_CD,'MKT'),NVL(MKT_AREA_TYP,'MKT_TYP'),
              NVL(RTL_ORG_HCHY_LVL,'ORG_LVL'), NVL(RTL_ORG_HCHY_CD,'ORG_HCHY'),
              PERIOD_END_DATE, NVL(RTL_ORG_CD,'ORG_CD'), NVL(AO_HCHY_CD,'AO_HCHY'),NVL(ACCT_CD,'ACCT_CD')
           HAVING COUNT(*) > 1
         );
COMMIT;


-- DELETE DUPLICATE RECORDS FROM INTERFACE TABLE --


DELETE FROM DDR_I_SYND_CNSMPTN_DATA
    WHERE
      (MEASURE_SET, SRC_CD, NVL(PROD_KEY,'PROD'), NVL(GEO_KEY,'GEO'),
       NVL(CHNL_TYP_CD,'CHNL'), NVL(GEO_SUB_RGN_CD,'SUB'),
       NVL(GEO_RGN_CD,'RGN'), NVL(MFG_ITM_HCHY_LVL,'LVL'),
       NVL(MFG_ITM_HCHY_CD,'HCHY'), NVL(MKT_AREA_CD,'MKT'),NVL(MKT_AREA_TYP,'MKT_TYP'),
       NVL(RTL_ORG_HCHY_LVL,'ORG_LVL'), NVL(RTL_ORG_HCHY_CD,'ORG_HCHY'),
       PERIOD_END_DATE, NVL(RTL_ORG_CD,'ORG_CD'), NVL(AO_HCHY_CD,'AO_HCHY'),NVL(ACCT_CD,'ACCT_CD'))
    IN (
      SELECT
         MEASURE_SET, SRC_CD, NVL(PROD_KEY,'PROD'), NVL(GEO_KEY,'GEO'),
         NVL(CHNL_TYP_CD,'CHNL'), NVL(GEO_SUB_RGN_CD,'SUB'),
         NVL(GEO_RGN_CD,'RGN'), NVL(MFG_ITM_HCHY_LVL,'LVL'),
         NVL(MFG_ITM_HCHY_CD,'HCHY'), NVL(MKT_AREA_CD,'MKT'),NVL(MKT_AREA_TYP,'MKT_TYP'),
         NVL(RTL_ORG_HCHY_LVL,'ORG_LVL'), NVL(RTL_ORG_HCHY_CD,'ORG_HCHY'),
         PERIOD_END_DATE, NVL(RTL_ORG_CD,'ORG_CD'), NVL(AO_HCHY_CD,'AO_HCHY'),NVL(ACCT_CD,'ACCT_CD')
      FROM DDR_E_SYND_CNSMPTN_DATA
      GROUP BY
          MEASURE_SET, SRC_CD, NVL(PROD_KEY,'PROD'), NVL(GEO_KEY,'GEO'),
          NVL(CHNL_TYP_CD,'CHNL'), NVL(GEO_SUB_RGN_CD,'SUB'),
          NVL(GEO_RGN_CD,'RGN'), NVL(MFG_ITM_HCHY_LVL,'LVL'),
          NVL(MFG_ITM_HCHY_CD,'HCHY'), NVL(MKT_AREA_CD,'MKT'),NVL(MKT_AREA_TYP,'MKT_TYP'),
          NVL(RTL_ORG_HCHY_LVL,'ORG_LVL'), NVL(RTL_ORG_HCHY_CD,'ORG_HCHY'),
          PERIOD_END_DATE, NVL(RTL_ORG_CD,'ORG_CD'), NVL(AO_HCHY_CD,'AO_HCHY'),NVL(ACCT_CD,'ACCT_CD')
      HAVING COUNT(*) > 1
    );
COMMIT;

RETURN('Y');

END SYND_CNSMPTN_DATA_DUPS_FNC;


FUNCTION synd_cnsmptn_data_dups_s_fnc(p_load_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2
AS

v_load_id NUMBER := NVL(p_load_id, set_load_id);
v_FUNC_MSG VARCHAR2(1) := 'N';

CURSOR c1 IS
SELECT *
FROM   ddr_s_synd_cnsmptn_data
WHERE (MEASURE_SET, SRC_CD, CHNL_TYP_CD, GEO_SUB_RGN_ID, GEO_RGN_ID,MFG_ITM_HCHY_LVL,
       MFG_ITM_HCHY_ID, MKT_AREA_ID, RTL_ORG_HCHY_LVL, RTL_ORG_HCHY_ID,RTL_ORG_CD, PERIOD_ID,AO_HCHY_CD		  ,ACCT_CD)
IN (SELECT MEASURE_SET, SRC_CD, CHNL_TYP_CD, GEO_SUB_RGN_ID, GEO_RGN_ID,MFG_ITM_HCHY_LVL,
           MFG_ITM_HCHY_ID, MKT_AREA_ID, RTL_ORG_HCHY_LVL, RTL_ORG_HCHY_ID,RTL_ORG_CD, PERIOD_ID,			AO_HCHY_CD,ACCT_CD
    FROM ddr_s_synd_cnsmptn_data
    GROUP BY MEASURE_SET, SRC_CD, CHNL_TYP_CD, GEO_SUB_RGN_ID, GEO_RGN_ID,MFG_ITM_HCHY_LVL,
             MFG_ITM_HCHY_ID, MKT_AREA_ID, RTL_ORG_HCHY_LVL, RTL_ORG_HCHY_ID,RTL_ORG_CD, PERIOD_ID, 			AO_HCHY_CD,ACCT_CD
    HAVING COUNT(*) > 1)
FOR UPDATE;
BEGIN

-- INSERT DUPLICATE RECORDS IN THE ERROR TABLE --

FOR rec IN c1 LOOP  --{
INSERT INTO ddr_e_synd_cnsmptn_data
     (REC_ID, LOAD_ID, ERR_REASON, SRC_CD,
      RTL_ORG_HCHY_ID, RTL_ORG_HCHY_LVL, MFG_ITM_HCHY_ID,
      MFG_ITM_HCHY_LVL, MKT_AREA_ID, GEO_RGN_ID,
      GEO_SUB_RGN_ID, CHNL_TYP_CD, PERIOD_ID, TIME_HCHY_LVL,
      SRC_SYS_IDNT, SRC_SYS_DT, SRC_IDNT_FLAG, ACTION_FLAG, MEASURE_SET,
      MEASURE1, MEASURE2, MEASURE3, MEASURE4, MEASURE5,
      MEASURE6, MEASURE7, MEASURE8, MEASURE9, MEASURE10,
      MEASURE11, MEASURE12, MEASURE13, MEASURE14, MEASURE15,
      MEASURE16, MEASURE17, MEASURE18, MEASURE19, MEASURE20,
      MEASURE21, MEASURE22, MEASURE23, MEASURE24, MEASURE25,
      MEASURE26, MEASURE27, MEASURE28, MEASURE29, MEASURE30,
      MEASURE31, MEASURE32, MEASURE33, MEASURE34, MEASURE35,
      MEASURE36, MEASURE37, MEASURE38, MEASURE39, MEASURE40,
      MEASURE41, MEASURE42, MEASURE43, MEASURE44, MEASURE45,
      MEASURE46, MEASURE47, MEASURE48, MEASURE49, MEASURE50,
      MEASURE51, MEASURE52, MEASURE53, MEASURE54, MEASURE55,
      MEASURE56, MEASURE57, MEASURE58, MEASURE59, MEASURE60,
      MEASURE61, MEASURE62, MEASURE63, MEASURE64, MEASURE65,
      MEASURE66, MEASURE67, MEASURE68, MEASURE69, MEASURE70,
      MEASURE71, MEASURE72, MEASURE73, MEASURE74, MEASURE75,
      MEASURE76, MEASURE77, MEASURE78, MEASURE79, MEASURE80,
      MEASURE81, MEASURE82, MEASURE83, MEASURE84, MEASURE85,
      MEASURE86, MEASURE87, MEASURE88, MEASURE89, MEASURE90,
      MEASURE91, MEASURE92, MEASURE93, MEASURE94, MEASURE95,
      MEASURE96, MEASURE97, MEASURE98, MEASURE99, MEASURE100,
      RTL_ORG_CD,AO_HCHY_CD,ACCT_CD)
   VALUES (
      rec.REC_ID, v_load_id, 'Duplicate record - Staging', rec.SRC_CD,
      rec.RTL_ORG_HCHY_ID, rec.RTL_ORG_HCHY_LVL, rec.MFG_ITM_HCHY_ID,
      rec.MFG_ITM_HCHY_LVL, rec.MKT_AREA_ID, rec.GEO_RGN_ID,
      rec.GEO_SUB_RGN_ID, rec.CHNL_TYP_CD, rec.PERIOD_ID, rec.TIME_HCHY_LVL,
      rec.SRC_SYS_IDNT, rec.SRC_SYS_DT, 'S', 'N', rec.MEASURE_SET,
      rec.MEASURE1, rec.MEASURE2, rec.MEASURE3, rec.MEASURE4, rec.MEASURE5,
      rec.MEASURE6, rec.MEASURE7, rec.MEASURE8, rec.MEASURE9, rec.MEASURE10,
      rec.MEASURE11, rec.MEASURE12, rec.MEASURE13, rec.MEASURE14, rec.MEASURE15,
      rec.MEASURE16, rec.MEASURE17, rec.MEASURE18, rec.MEASURE19, rec.MEASURE20,
      rec.MEASURE21, rec.MEASURE22, rec.MEASURE23, rec.MEASURE24, rec.MEASURE25,
      rec.MEASURE26, rec.MEASURE27, rec.MEASURE28, rec.MEASURE29, rec.MEASURE30,
      rec.MEASURE31, rec.MEASURE32, rec.MEASURE33, rec.MEASURE34, rec.MEASURE35,
      rec.MEASURE36, rec.MEASURE37, rec.MEASURE38, rec.MEASURE39, rec.MEASURE40,
      rec.MEASURE41, rec.MEASURE42, rec.MEASURE43, rec.MEASURE44, rec.MEASURE45,
      rec.MEASURE46, rec.MEASURE47, rec.MEASURE48, rec.MEASURE49, rec.MEASURE50,
      rec.MEASURE51, rec.MEASURE52, rec.MEASURE53, rec.MEASURE54, rec.MEASURE55,
      rec.MEASURE56, rec.MEASURE57, rec.MEASURE58, rec.MEASURE59, rec.MEASURE60,
      rec.MEASURE61, rec.MEASURE62, rec.MEASURE63, rec.MEASURE64, rec.MEASURE65,
      rec.MEASURE66, rec.MEASURE67, rec.MEASURE68, rec.MEASURE69, rec.MEASURE70,
      rec.MEASURE71, rec.MEASURE72, rec.MEASURE73, rec.MEASURE74, rec.MEASURE75,
      rec.MEASURE76, rec.MEASURE77, rec.MEASURE78, rec.MEASURE79, rec.MEASURE80,
      rec.MEASURE81, rec.MEASURE82, rec.MEASURE83, rec.MEASURE84, rec.MEASURE85,
      rec.MEASURE86, rec.MEASURE87, rec.MEASURE88, rec.MEASURE89, rec.MEASURE90,
      rec.MEASURE91, rec.MEASURE92, rec.MEASURE93, rec.MEASURE94, rec.MEASURE95,
      rec.MEASURE96, rec.MEASURE97, rec.MEASURE98, rec.MEASURE99, rec.MEASURE100,
      rec.RTL_ORG_CD,rec.AO_HCHY_CD,rec.ACCT_CD
     );

-- delete duplicate records from staging table --
DELETE ddr_s_synd_cnsmptn_data
WHERE CURRENT OF c1;

END LOOP;  --}

COMMIT;

RETURN('Y');

END synd_cnsmptn_data_dups_s_fnc;


FUNCTION MFG_SHIP_ITEM_DUPS_FNC(p_load_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2
AS
v_load_id NUMBER := NVL(p_load_id, set_load_id);
BEGIN
-- INSERT DUPLICATE RECORDS IN THE ERROR TABLE --


INSERT INTO DDR_E_MFG_SHIP_ITEM
    (REC_ID, LOAD_ID, ERR_REASON,
    BSNS_UNIT_CD, MFG_SKU_ITEM_NBR,
    UOM,SHIP_QTY, SHIP_AMT, SRC_SYS_IDNT,
    SRC_SYS_DT, SRC_IDNT_FLAG, ACTION_FLAG, TRANS_DT,
    SHIP_TO_ORG_CD, SHIP_TO_BSNS_UNIT_CD, SHIP_COST
     )
    SELECT REC_ID, v_load_id,'Duplicate Record',
       BSNS_UNIT_CD, MFG_SKU_ITEM_NBR,
       UOM,SHIP_QTY, SHIP_AMT, SRC_SYS_IDNT,
       SRC_SYS_DT,'I','N', TRANS_DT,
       SHIP_TO_ORG_CD, SHIP_TO_BSNS_UNIT_CD, SHIP_COST
      FROM DDR_I_MFG_SHIP_ITEM
       WHERE
         (BSNS_UNIT_CD,
          MFG_SKU_ITEM_NBR,
          TRANS_DT, SHIP_TO_ORG_CD,
          SHIP_TO_BSNS_UNIT_CD )
          IN (
             SELECT
               BSNS_UNIT_CD,
               MFG_SKU_ITEM_NBR,
               TRANS_DT, SHIP_TO_ORG_CD,
               SHIP_TO_BSNS_UNIT_CD
          FROM DDR_I_MFG_SHIP_ITEM
          GROUP BY
               BSNS_UNIT_CD,
               MFG_SKU_ITEM_NBR,
               TRANS_DT, SHIP_TO_ORG_CD,
               SHIP_TO_BSNS_UNIT_CD
             HAVING COUNT(*) > 1);
COMMIT;

-- DELETE DUPLICATE RECORDS FROM INTERFACE TABLE --

DELETE FROM DDR_I_MFG_SHIP_ITEM
    WHERE
      (BSNS_UNIT_CD,
       MFG_SKU_ITEM_NBR,
       TRANS_DT, SHIP_TO_ORG_CD,
       SHIP_TO_BSNS_UNIT_CD)
    IN (
     SELECT
       BSNS_UNIT_CD,
       MFG_SKU_ITEM_NBR,
       TRANS_DT, SHIP_TO_ORG_CD,
       SHIP_TO_BSNS_UNIT_CD
    FROM DDR_E_MFG_SHIP_ITEM
    GROUP BY
       BSNS_UNIT_CD,
       MFG_SKU_ITEM_NBR,
       TRANS_DT, SHIP_TO_ORG_CD,
       SHIP_TO_BSNS_UNIT_CD
     HAVING COUNT(*) > 1
    );
COMMIT;

RETURN('Y');

END MFG_SHIP_ITEM_DUPS_FNC;


FUNCTION mfg_ship_item_dups_s_fnc(p_load_id IN NUMBER DEFAULT NULL) RETURN
VARCHAR2
AS
v_load_id NUMBER := NVL(p_load_id, set_load_id);
v_FUNC_MSG VARCHAR2(1) := 'N';

CURSOR c1 IS
SELECT *
FROM   ddr_s_mfg_ship_item
WHERE
(day_cd,bsns_unit_id,mfg_sku_item_id,ship_to_bsns_unit_id)
IN (SELECT
day_cd,bsns_unit_id,mfg_sku_item_id,ship_to_bsns_unit_id
    FROM ddr_s_mfg_ship_item
    GROUP BY
day_cd,bsns_unit_id,mfg_sku_item_id,ship_to_bsns_unit_id
    HAVING count(*) > 1)
FOR UPDATE;
BEGIN

-- INSERT DUPLICATE RECORDS IN THE ERROR TABLE --

FOR rec IN c1 LOOP  --{
INSERT INTO ddr_e_mfg_ship_item
     (crncy_cd
     ,day_cd
     ,load_id
     ,mfg_sku_item_id
     ,bsns_unit_id
     ,rec_id
     ,bsns_unit_cd
     ,ship_amt
     ,ship_amt_lcl
     ,ship_qty
     ,ship_qty_alt
     ,ship_qty_prmry
     ,src_sys_dt
     ,src_sys_idnt
     ,trans_dt
     ,uom_cd
     ,uom_cd_alt
     ,uom_cd_prmry
     ,src_idnt_flag
     ,action_flag
     ,err_reason
     ,ship_to_org_cd
     ,ship_to_bsns_unit_id
     ,ship_to_bsns_unit_cd
     ,ship_cost
     ,ship_cost_lcl
     ) VALUES
     (rec.crncy_cd
     ,rec.day_cd
     ,v_load_id
     ,rec.mfg_sku_item_id
     ,rec.bsns_unit_id
     ,rec.rec_id
     ,rec.bsns_unit_cd
     ,rec.ship_amt
     ,rec.ship_amt_lcl
     ,rec.ship_qty
     ,rec.ship_qty_alt
     ,rec.ship_qty_prmry
     ,rec.src_sys_dt
     ,rec.src_sys_idnt
     ,rec.trans_dt
     ,rec.uom_cd
     ,rec.uom_cd_alt
     ,rec.uom_cd_prmry
     ,'S'
     ,'N'
     ,'Duplicate record - Staging'
     ,rec.ship_to_org_cd
     ,rec.ship_to_bsns_unit_id
     ,rec.ship_to_bsns_unit_cd
     ,rec.ship_cost
     ,rec.ship_cost_lcl
     );

-- delete duplicate records from staging table --
DELETE ddr_s_mfg_ship_item
WHERE CURRENT OF c1;

END LOOP;  --}

COMMIT;

RETURN('Y');

END mfg_ship_item_dups_s_fnc;


FUNCTION get_load_id(p_run_id IN NUMBER) RETURN NUMBER
AS
  v_run_id NUMBER;
BEGIN
  v_run_id := NVL(p_run_id, set_load_id);
RETURN v_run_id;
END get_load_id;


END ddr_base_util_pkg;

/
