--------------------------------------------------------
--  DDL for Package Body OPI_EDW_COGS_FOPM_SZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_EDW_COGS_FOPM_SZ" AS
/* $Header: OPIPCGZB.pls 120.1 2005/06/16 03:53:24 appldev  $*/

PROCEDURE cnt_rows(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER) IS

BEGIN

  SELECT COUNT(*) INTO p_num_rows
  FROM (
     SELECT SH.order_id
     FROM
         OP_ORDR_HDR SH,
         OP_ORDR_DTL SD,
         SY_ORGN_MST OM,
         GL_PLCY_MST  PM
     WHERE SH.order_id = sd.order_id
      AND SH.orgn_code = OM.orgn_code
      AND OM.co_CODE  = PM.co_code
      AND SD.LINE_STATUS >= 20
      AND GREATEST(SH.LAST_UPDATE_DATE, SD.LAST_UPDATE_DATE,PM.LAST_UPDATE_DATE)
      between p_from_date and p_to_date);

    --dbms_output.put_line ('Number of rows : '||p_num_rows);
EXCEPTION
  WHEN OTHERS THEN
    p_num_rows := 0;
END;  -- procedure cnt_rows.



PROCEDURE est_row_len(p_from_date DATE,
                      p_to_date DATE,
                      p_avg_row_len OUT NOCOPY NUMBER) IS
 x_date                 number := 7;
 x_total                number := 0;
 x_constant             number := 6;

 CURSOR c_trans_dtl IS
    SELECT  avg(nvl(vsize(itp.trans_id), 0)) trx_id,
      avg(nvl(vsize(itp.trans_um), 0)) um,
      avg(nvl(vsize(itp.line_id), 0))   line_id,
      avg(nvl(vsize(itp.WHSE_CODE), 0)) WHSE_code,
      avg(nvl(vsize(itp.LOCATION), 0))   location,
      avg(nvl(vsize(itp.TRANS_QTY), 0))  qty,
      avg(nvl(vsize(ilm.lot_no),0)) Lot_no,
      avg(nvl(vsize(itp.item_id),0)) item_id
      FROM IC_TRAN_PND ITP,IC_LOTS_MST ILM
      WHERE ITP.last_update_date between p_from_date  and  p_to_date
         AND ITP.LOT_ID  = ILM.LOT_ID
         AND ITP.ITEM_ID = ILM.ITEM_ID
         AND ITP.COMPLETED_IND =1
         AND ITP.DOC_TYPE in ('OPSO');

 CURSOR c_order_dtl IS
    SELECT avg(nvl(vsize(ooh.order_no), 0))  order_no,
      avg(nvl(vsize(ood.line_no), 0))        line_no,
      avg(nvl(vsize(ood.BILLING_CURRENCY), 0))  CURRENCY,
      avg(nvl(vsize(OOD.SHIPCUST_ID), 0))       cust_id
      FROM op_ORDR_hdr ooh,
           op_ordr_Dtl ood
      WHERE GREATEST(ooh.last_update_date,ood.last_update_date) between p_from_date  and  p_to_date;


 CURSOR c_instance IS
    SELECT
      avg(nvl(vsize(instance_code), 0))
      FROM	EDW_LOCAL_INSTANCE ;

 CURSOR c_other_dtl IS
    SELECT AVG(Nvl(Vsize(EDW_TIME_PKG.CAL_DAY_FK(Sysdate, SOB_ID) ),0)) date_fk,
           AVG(NVL(VSIZE(SOB_ID),0)) SOB_ID,
           AVG(NVL(VSIZE(ORG_ID),0)) ORG_ID
      FROM gl_plcy_mst;

 x_instance_fk NUMBER;

 trans_dtl_rec c_trans_dtl%ROWTYPE;
 order_dtl_rec c_order_dtl%ROWTYPE;
 other_dtl_rec c_other_dtl%ROWTYPE;
BEGIN
   OPEN c_instance;
   FETCH c_instance INTO  x_instance_fk;
   CLOSE c_instance;

   OPEN c_trans_dtl;
   FETCH c_trans_dtl INTO trans_dtl_rec;
   CLOSE c_trans_dtl;

   OPEN c_order_dtl;
   FETCH c_order_dtl INTO order_dtl_rec;
   CLOSE c_order_dtl;

   OPEN c_other_dtl;
   FETCH c_other_dtl INTO other_dtl_rec;
   CLOSE c_other_dtl;


   x_total := 3 + x_total
     -- COGS_PK
     + Ceil( trans_dtl_rec.trx_id + trans_dtl_rec.line_id + x_instance_fk + 10 + 1)
     -- INSTANCE_FK
     + Ceil( x_instance_fk + 1)
     -- TOP_MODEL_ITEM_FK  ITEM_ORG_FK
     + 2 * Ceil( trans_dtl_rec.item_id + other_dtl_rec.org_id + x_instance_fk + 7 +1)
     -- OPERATING_UNIT_FK  INV_ORG_FK
     + 2* Ceil( other_dtl_rec.org_id + x_instance_fk + 1)
     -- CUSTOMER_FK
     + Ceil(order_dtl_rec.cust_id + x_instance_fk+ 16+ 1)
    + Ceil( 6 * 23 +1);
     -- All NA_EDW FKs
     -- PROJECT_FK SALESCHANNEL
     -- TASK_FK SALESREP
     -- CAMPAIGN_INIT_FK  CAMPAIGN_ACTL_FK
     -- MEDCHN_INIT_FK  MEDCHN_ACTL_FK
     -- OFFER_HDR_FK    OFFER_LINE_FK
     -- TARGET_SEGMENT_INIT_FK  TARGET_SEGMENT_ACTL_FK
     -- CAMPAIGN_STATUS_ACTL_FK  CAMPAIGN_STATUS_INIT_FK
     -- ORDER_CATEGORY_FK   ORDER_TYPE_FK  ORDER_SOURCE_FK
     -- 5 USER FKs

   x_total := x_total
     -- BILL_TO_LOC_FK  SHIP_TO_LOC_FK
     + 2* Ceil(other_dtl_rec.org_id + x_instance_fk + 12 + 1)

     -- BASE_UOM_FK
     + Ceil( trans_dtl_rec.um + 1)
     -- TRX_CURRENCY_FK  BASE_CURRENCY_FK
     + Ceil( order_dtl_rec.currency + 1)
     -- BILL_TO_SITE_FK   SHIP_TO_SITE_FK
     + 2* Ceil(other_dtl_rec.org_id + x_instance_fk + 15 +1)
     -- MONTH_BOOKED_FK  DATE_BOOKED_FK  DATE_PROMISED_FK
     -- DATE_REQUESTED_FK  DATE_SCHEDULED_FK   DATE_SHIPPED_FK COGS_DATE_FK
     + 7* Ceil( other_dtl_rec.date_fk + 1)
     -- LOCATOR_FK    SHIP_INV_LOCATOR_FK
     + Ceil(trans_dtl_rec.WHSE_CODE * 2 + trans_dtl_rec.LOCATION+ 2 *  x_instance_fk + 5+ 7 +1)
     -- SET_OF_BOOKS_FK
     + Ceil( 3 + x_instance_fk + 1);


   x_total := x_total
     -- ORDER_LINE_ID
     + Ceil(trans_dtl_rec.line_id + x_instance_fk + 1 + 1)
     -- COGS_DATE  ORDER_DATE
     + 2 * x_date
     -- SHIPPED_QTY_B
     + Ceil(trans_dtl_rec.qty + 1)
     -- COGS_B COGS_G
     + 2 * Ceil(trans_dtl_rec.qty  + 3)
     -- LAST_UPDATE_DATE,
     + x_date
     -- ORDER_NUMBER
     + Ceil(order_dtl_rec.order_no + 1)
     -- LOT
     + Ceil(trans_dtl_rec.lot_no + 1)
     -- SERIAL_NUMBER
     + Ceil(order_dtl_rec.line_no + 1);

   -- dbms_output.put_line('1 x_total is ' || x_total );

   p_avg_row_len := x_total;


  END;  -- procedure est_row_len.

END;  -- package body OPI_EDW_COGS_FOPM_SZ

/
