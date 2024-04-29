--------------------------------------------------------
--  DDL for Package Body OPI_EDW_INV_DAILY_STAT_FOPM_SZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_EDW_INV_DAILY_STAT_FOPM_SZ" AS
/* $Header: OPIPINZB.pls 120.1 2005/06/07 03:14:06 appldev  $*/

PROCEDURE cnt_rows(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER) IS

BEGIN

  SELECT COUNT(*) INTO p_num_rows
  FROM (
      (SELECT
        org.CO_CODE,org.ORGN_CODE,cmp.WHSE_CODE,cmp.ITEM_ID,cmp.LOT_ID,
        nvl(cmp.LOCATION,'NONE'),trunc(cmp.TRANS_DATE),cmp.TRANS_UM
      from ic_tran_cmp cmp,ic_loct_inv loct, sy_orgn_mst org,ic_whse_mst whse
      where trunc(cmp.last_update_date) between p_from_date and p_to_date
        AND loct.item_id  = cmp.item_id   AND loct.lot_id   = cmp.lot_id
        AND loct.whse_code = cmp.whse_code AND loct.location = cmp.location
        AND cmp.whse_code is not null
        AND whse.whse_code = loct.whse_code
        AND whse.orgn_code = org.orgn_code
        and cmp.whse_code  = whse.whse_code
        AND cmp.location is not null
       GROUP BY org.CO_CODE,org.ORGN_CODE,cmp.WHSE_CODE,cmp.ITEM_ID,cmp.LOT_ID,
        nvl(cmp.LOCATION,'NONE'),trunc(cmp.TRANS_DATE),cmp.TRANS_UM)
      UNION ALL
       ( SELECT org.CO_CODE,org.ORGN_CODE,pnd.WHSE_CODE,pnd.ITEM_ID,pnd.LOT_ID,
        nvl(pnd.LOCATION,'NONE'),trunc(pnd.TRANS_DATE),pnd.TRANS_UM
        from ic_tran_pnd pnd ,ic_loct_inv loct , sy_orgn_mst org,ic_whse_mst whse
      where trunc(pnd.last_update_date) between p_from_date and p_to_date
        AND pnd.COMPLETED_IND = 1
        AND loct.item_id  = pnd.item_id
        AND loct.lot_id   = pnd.lot_id
        AND loct.whse_code = pnd.whse_code
        AND loct.location = pnd.location
        AND whse.whse_code = loct.whse_code
        AND whse.orgn_code = org.orgn_code
        and pnd.whse_code  = whse.whse_code
        AND pnd.delete_mark = 0
        GROUP BY org.CO_CODE,org.ORGN_CODE,pnd.WHSE_CODE,pnd.ITEM_ID,pnd.LOT_ID,
        nvl(pnd.LOCATION,'NONE'),trunc(pnd.TRANS_DATE),pnd.TRANS_UM));


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

x_INSTANCE_FK                              NUMBER;

--------

CURSOR C_Trans_dtl IS
    SELECT  avg(nvl(vsize(tr_dtl.co_code),0)) co_code,
            avg(nvl(vsize(tr_dtl.orgn_code),0)) orgn_code,
            avg(nvl(vsize(tr_dtl.whse_code),0)) whse_code,
            avg(nvl(vsize(tr_dtl.mtl_orgn_id),0)) mtl_org_id,
            avg(nvl(vsize(tr_dtl.item_id),0)) item_id,
            avg(nvl(vsize(tr_dtl.Lot_id),0)) lot_id,
            avg(nvl(vsize(tr_dtl.Loct),0)) loct,
            avg(nvl(vsize(tr_dtl.trx_date),0)) trx_date,
            avg(nvl(vsize(tr_dtl.UOM),0)) uom,
            avg(nvl(vsize(tr_dtl.item_status),0)) item_status,
            avg(nvl(vsize(tr_dtl.item_type),0)) item_type,
            avg(nvl(vsize(tr_dtl.commodity),0)) commodity,
            avg(nvl(vsize(tr_dtl.qty),0)) trans_qty
   FROM
     ((SELECT
        org.CO_CODE co_code,org.ORGN_CODE orgn_code,cmp.WHSE_CODE whse_code,
        whse.mtl_organization_id mtl_orgn_id,cmp.ITEM_ID item_id,cmp.LOT_ID lot_id,
        nvl(cmp.LOCATION,'NONE') LOCT,trunc(cmp.TRANS_DATE) trx_date,cmp.TRANS_UM UOM,
        iim.inactive_ind item_status,iim.inv_type item_type,iim.commodity_code commodity,
        SUM(cmp.TRANS_QTY) QTY
      from ic_tran_cmp cmp,
           ic_loct_inv loct,
           sy_orgn_mst org,
           ic_whse_mst whse,
           ic_item_mst iim
      where trunc(cmp.last_update_date) between p_from_date and p_to_date
        AND loct.item_id  = cmp.item_id   AND loct.lot_id   = cmp.lot_id
        AND loct.whse_code = cmp.whse_code AND loct.location = cmp.location
        AND cmp.whse_code is not null
        AND whse.whse_code = loct.whse_code
        AND whse.orgn_code = org.orgn_code
        and cmp.whse_code  = whse.whse_code
        AND cmp.location is not null
        AND cmp.item_id   = iim.item_id
       GROUP BY org.CO_CODE,org.ORGN_CODE,cmp.WHSE_CODE,whse.mtl_organization_id,cmp.ITEM_ID,cmp.LOT_ID,
        nvl(cmp.LOCATION,'NONE'),trunc(cmp.TRANS_DATE),cmp.TRANS_UM,
        iim.inactive_ind,iim.inv_type,iim.commodity_code)
      UNION ALL
       ( SELECT org.CO_CODE co_code,org.ORGN_CODE org_code ,pnd.WHSE_CODE whse_code,
         whse.mtl_organization_id mtl_orgn_id,pnd.ITEM_ID item_id,pnd.LOT_ID lot_id,
        nvl(pnd.LOCATION,'NONE'),trunc(pnd.TRANS_DATE) trx_date,pnd.TRANS_UM UOM,
        iim.inactive_ind item_status,iim.inv_type item_type,iim.commodity_code commodity,SUM(TRANS_QTY) QTY
        from ic_tran_pnd pnd ,
             ic_loct_inv loct ,
             sy_orgn_mst org,
             ic_whse_mst whse ,
             ic_item_mst iim
      where trunc(pnd.last_update_date) between p_from_date and p_to_date
        AND pnd.COMPLETED_IND = 1
        AND pnd.item_id   = iim.item_id
        AND loct.item_id  = pnd.item_id
        AND loct.lot_id   = pnd.lot_id
        AND loct.whse_code = pnd.whse_code
        AND loct.location = pnd.location
        AND whse.whse_code = loct.whse_code
        AND whse.orgn_code = org.orgn_code
        and pnd.whse_code  = whse.whse_code
        AND pnd.delete_mark = 0
        GROUP BY org.CO_CODE,org.ORGN_CODE,pnd.WHSE_CODE,whse.mtl_organization_id,pnd.ITEM_ID,pnd.LOT_ID,
        nvl(pnd.LOCATION,'NONE'),trunc(pnd.TRANS_DATE),pnd.TRANS_UM,
        iim.inactive_ind,iim.inv_type,iim.commodity_code)) tr_dtl;

  CURSOR c_instance IS
	SELECT
	  avg(nvl(vsize(instance_code), 0))
	FROM	EDW_LOCAL_INSTANCE ;


 CURSOR c_sob_dtl IS
    SELECT AVG(Nvl(Vsize(EDW_TIME_PKG.CAL_DAY_FK(Sysdate, SOB_ID) ),0)) date_fk,
           AVG(Nvl(Vsize(EDW_TIME_PKG.CAL_DAY_TO_CAL_PERIOD_FK(Sysdate, SOB_ID) ),0)) perd_fk,
           AVG(NVL(VSIZE(SOB_ID),0)) SOB_ID,
           AVG(NVL(VSIZE(ORG_ID),0)) ORG_ID,
           AVG(NVL(VSIZE(BASE_CURRENCY_CODE),0))  CURRENCY
      FROM gl_plcy_mst;

 Trans_dtl_rec C_Trans_dtl%ROWTYPE;
 sob_dtl_rec   c_sob_dtl%ROWTYPE;
  BEGIN
    OPEN c_instance;
    FETCH c_instance INTO  x_instance_fk;
    CLOSE c_instance;

    OPEN C_Trans_dtl;
    FETCH C_Trans_dtl INTO Trans_dtl_rec;
    CLOSE C_Trans_dtl;

    OPEN c_sob_dtl;
    FETCH c_sob_dtl INTO sob_dtl_rec;
    CLOSE c_sob_dtl;


    x_total := 3 +
	    x_total +
          Ceil( Trans_dtl_rec.CO_CODE + 1) +
          Ceil( Trans_dtl_rec.ORGN_CODE + 1) +
          Ceil( Trans_dtl_rec.WHSE_CODE + 1) * 2 +
          Ceil( Trans_dtl_rec.loct + 1) * 2 +
          Ceil( Trans_dtl_rec.ITEM_ID + 1) * 3 +
          Ceil( Trans_dtl_rec.uom + 1) +
          Ceil( Trans_dtl_rec.mtl_org_id + 1) +
          Ceil( Trans_dtl_rec.lot_id + 1) +
          Ceil( Trans_dtl_rec.item_status + 1) +
          Ceil( Trans_dtl_rec.item_type + 1) +
          Ceil( Trans_dtl_rec.commodity + 1) +
          Ceil( x_date + 1) * 3 +
          Ceil( Trans_dtl_rec.trans_qty + 1) * 12 +
          Ceil( Trans_dtl_rec.trans_qty + 2) * 24+
          Ceil( x_instance_fk + 1) * 6+
          Ceil( sob_dtl_rec.currency + 1) +
          Ceil( sob_dtl_rec.date_fk + 1) +
          Ceil( sob_dtl_rec.perd_fk + 1) +
         -- All hardcoded  tokens
          Ceil( 44 + 1) ;


    p_avg_row_len := x_total;

  END;  -- procedure est_row_len.

END;  -- package body OPI_EDW_INV_DAILY_STAT_FOPM_SZ

/
