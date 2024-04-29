--------------------------------------------------------
--  DDL for Package Body DDR_EMD_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DDR_EMD_UTIL" AS
/* $Header: ddremdub.pls 120.9.12010000.2 2010/03/03 04:17:33 vbhave noship $ */

get_avg_sls_id1 ddr_b_rtl_sl_rtn_itm_day.org_bsns_unit_id%TYPE;
get_avg_sls_id2 ddr_b_rtl_sl_rtn_itm_day.mfg_sku_item_id%TYPE;
get_avg_sls_id3 ddr_b_rtl_sl_rtn_itm_day.rtl_sku_item_id%TYPE;
get_avg_sls_wk_strt_dt DATE;
get_avg_sls_avg_sls NUMBER;
get_sls_threshold_max_exp_sls NUMBER;

PROCEDURE create_exception(p_mfg_org_cd IN VARCHAR2
                         , p_rtl_org_cd IN VARCHAR2
                         , p_excptn_type IN VARCHAR2
                         , p_excptn_src_code IN VARCHAR2
                         , p_excptn_date IN VARCHAR2
                         , p_org_bsns_unit_id IN VARCHAR2
                         , p_mfg_sku_item_id IN VARCHAR2
                         , p_rtl_sku_item_id IN VARCHAR2
                         , p_user_id IN VARCHAR2
                         , p_excptn_qty IN VARCHAR2 DEFAULT NULL
                         , p_excptn_amt IN VARCHAR2 DEFAULT NULL) IS
BEGIN
  INSERT INTO DDR_B_EXCPTN_ITEM_DAY
    (MFG_ORG_CD,
     RTL_ORG_CD,
     ORG_BSNS_UNIT_ID,
     DAY_CD,
     MFG_SKU_ITEM_ID,
     RTL_SKU_ITEM_ID,
     EXCPTN_TYP,
     EXCPTN_QTY,
     EXCPTN_AMT,
     EXCPTN_SRC_CD,
     CRTD_BY_DSR,
     LAST_UPDT_BY_DSR,
     CREATED_BY,
     CREATION_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATE_LOGIN)
  VALUES
    (p_mfg_org_cd,
     p_rtl_org_cd,
     p_org_bsns_unit_id,
     to_char(to_date(p_excptn_date, 'YYYY-MM-DD'), 'YYYYMMDD'),
     p_mfg_sku_item_id,
     p_rtl_sku_item_id,
     p_excptn_type,
     p_excptn_qty,
     p_excptn_amt,
     p_excptn_src_code,
     p_user_id,
     p_user_id,
     -1,
     SYSDATE,
     -1,
     SYSDATE,
     -1);
  -- Bug#9275960 - Commented out Commit for every row inserted.
  -- COMMIT;
END create_exception;

PROCEDURE delete_exception(p_excptn_type IN VARCHAR2
                         , p_excptn_src_code IN VARCHAR2
                         , p_date_offset IN NUMBER DEFAULT 0) IS
BEGIN
  DELETE FROM DDR_B_EXCPTN_ITEM_DAY
  WHERE  EXCPTN_TYP = p_excptn_type
  AND    EXCPTN_SRC_CD = p_excptn_src_code
  AND    DAY_CD >= to_char(SYSDATE - p_date_offset, 'YYYYMMDD');

  -- Bug#9275960 - Commented out Commit.
  -- COMMIT;
END delete_exception;

PROCEDURE delete_all_exceptions(p_end_date        IN DATE
                               ,p_excptn_type     IN VARCHAR2 DEFAULT NULL
                               ,p_excptn_src_code IN VARCHAR2 DEFAULT NULL
                               ,x_return_status   OUT NOCOPY VARCHAR2
                               ,x_msg             OUT NOCOPY VARCHAR2
                               ) IS
BEGIN
  x_return_status := ddr_emd_util.success;

  DELETE FROM ddr_b_excptn_item_day
  WHERE  excptn_typ = NVL(p_excptn_type,excptn_typ)
  AND    excptn_src_cd = NVL(p_excptn_src_code,excptn_src_cd)
  AND    day_cd <= TO_CHAR(p_end_date, 'YYYYMMDD');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := ddr_emd_util.error;
    x_msg := 'Failed in ddr_emd_util.delete_all_exceptions '||SQLERRM;
END delete_all_exceptions;

PROCEDURE populate_new_items(p_date            DATE     DEFAULT SYSDATE
                            ,p_bsns_unit_id    NUMBER   DEFAULT NULL
                            ,p_mfg_sku_item_id NUMBER   DEFAULT NULL
                            ,p_rtl_org_cd      VARCHAR2 DEFAULT NULL
                            ,p_complete_refresh      BOOLEAN DEFAULT TRUE
                            ,x_return_status OUT NOCOPY VARCHAR2
                            ,x_msg OUT NOCOPY VARCHAR2
                            ) IS

v_org_cd_tbl           ddr_emd_util.varchar_tbl;
v_bsns_unit_id_tbl     ddr_emd_util.number_tbl;
v_mfg_sku_item_id_tbl  ddr_emd_util.number_tbl;
v_rtl_sku_item_id_tbl  ddr_emd_util.number_tbl;
v_new_item_strt_dt_tbl ddr_emd_util.date_tbl;
v_new_item_end_dt_tbl  ddr_emd_util.date_tbl;
v_first_sl_date_tbl    ddr_emd_util.date_tbl;

v_rec_count            NUMBER:= 0;

CURSOR new_items IS
SELECT *
FROM   ddr_r_item_bsns_unt_assc
WHERE  eff_from_dt > TRUNC(p_date) - ddr_emd_util.new_item_period
AND    rtl_org_cd = NVL(p_rtl_org_cd,rtl_org_cd)
AND    rtl_bsns_unit_id = NVL(p_bsns_unit_id,rtl_bsns_unit_id)
AND    mfg_sku_item_id = NVL(p_mfg_sku_item_id,mfg_sku_item_id)
AND    eff_to_dt IS NULL;

CURSOR rtl_sku(p_org_cd VARCHAR2
              ,p_glbl_item_id VARCHAR2
              ,p_glbl_item_id_typ VARCHAR2
              ) IS
SELECT MAX(rtl_sku_item_id) rtl_sku_item_id  -- This is temporary workaround. This is a bug
FROM   ddr_r_rtl_sku_item
WHERE  rtl_org_cd = p_org_cd
AND    glbl_item_id = p_glbl_item_id
AND    glbl_item_id_typ = p_glbl_item_id_typ;

CURSOR sls_rec (p_org_bsns_unit_id NUMBER
               ,p_mfg_sku_item_id  NUMBER
               ,p_rtl_sku_item_id  NUMBER
               ,p_from_day_cd      VARCHAR2) IS
SELECT MIN(day_cd) first_sl_date
FROM   ddr_b_rtl_sl_rtn_itm_day
WHERE  org_bsns_unit_id = p_org_bsns_unit_id
AND    mfg_sku_item_id  = p_mfg_sku_item_id
AND    rtl_sku_item_id  = p_rtl_sku_item_id
AND    day_cd           >= p_from_day_cd
AND    sls_qty_prmry    > 0;

BEGIN
  -- Truncate the table
  IF p_complete_refresh THEN  --{
    EXECUTE IMMEDIATE 'TRUNCATE TABLE ddr.ddr_b_new_item_no_sls';
  END IF;  --}
  -- Fetch new items and check first sale

  FOR rec IN new_items LOOP  --{
    FOR rec1 IN rtl_sku(rec.rtl_org_cd
                       ,rec.glbl_item_id
                       ,rec.glbl_item_id_typ) LOOP  --{

      v_rec_count := v_rec_count + 1;
      v_org_cd_tbl(v_rec_count) := rec.rtl_org_cd;
      v_bsns_unit_id_tbl(v_rec_count) := rec.rtl_bsns_unit_id;
      v_mfg_sku_item_id_tbl(v_rec_count) := rec.mfg_sku_item_id;
      v_rtl_sku_item_id_tbl(v_rec_count) := rec1.rtl_sku_item_id;
      v_new_item_strt_dt_tbl(v_rec_count) := TRUNC(rec.eff_from_dt);
      v_new_item_end_dt_tbl(v_rec_count) := v_new_item_strt_dt_tbl(v_rec_count)+ddr_emd_util.new_item_period;
      v_first_sl_date_tbl(v_rec_count) := NULL;

      FOR rec2 IN sls_rec(rec.rtl_bsns_unit_id
                  ,rec.mfg_sku_item_id
                  ,rec1.rtl_sku_item_id
                  ,TO_CHAR(rec.eff_from_dt,'YYYYMMDD')) LOOP  --{
        v_first_sl_date_tbl(v_rec_count) := TO_DATE(rec2.first_sl_date,'YYYYMMDD');
      END LOOP;  --}
      IF MOD(v_rec_count,ddr_emd_util.c_batch_size) = 0 THEN  --{
        FORALL i IN 1..v_rec_count
          INSERT INTO ddr_b_new_item_no_sls(rtl_org_cd
                                           ,rtl_bsns_unit_id
                                           ,mfg_sku_item_id
                                           ,rtl_sku_item_id
                                           ,new_item_srt_dt
                                           ,new_item_end_dt
                                           ,frst_sl_dt
                                           ) VALUES
                                           (v_org_cd_tbl(i)
                                           ,v_bsns_unit_id_tbl(i)
                                           ,v_mfg_sku_item_id_tbl(i)
                                           ,v_rtl_sku_item_id_tbl(i)
                                           ,v_new_item_strt_dt_tbl(i)
                                           ,v_new_item_end_dt_tbl(i)
                                           ,v_first_sl_date_tbl(i)
                                           );
        COMMIT;
        v_org_cd_tbl.DELETE;
        v_bsns_unit_id_tbl.DELETE;
        v_mfg_sku_item_id_tbl.DELETE;
        v_rtl_sku_item_id_tbl.DELETE;
        v_new_item_strt_dt_tbl.DELETE;
        v_new_item_end_dt_tbl.DELETE;
        v_first_sl_date_tbl.DELETE;
        v_rec_count := 0;
      END IF;  --}
    END LOOP;  --}
  END LOOP;  --}

  -- Insert the last batch rows
  FORALL i IN 1..v_rec_count
    INSERT INTO ddr_b_new_item_no_sls(rtl_org_cd
                                     ,rtl_bsns_unit_id
                                     ,mfg_sku_item_id
                                     ,rtl_sku_item_id
                                     ,new_item_srt_dt
                                     ,new_item_end_dt
                                     ,frst_sl_dt
                                     ) VALUES
                                     (v_org_cd_tbl(i)
                                     ,v_bsns_unit_id_tbl(i)
                                     ,v_mfg_sku_item_id_tbl(i)
                                     ,v_rtl_sku_item_id_tbl(i)
                                     ,v_new_item_strt_dt_tbl(i)
                                     ,v_new_item_end_dt_tbl(i)
                                     ,v_first_sl_date_tbl(i)
                                     );
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := ddr_emd_util.error;
    x_msg := 'Failed in populate_new_items'||' :'||SQLERRM;
END populate_new_items;


PROCEDURE get_exp_sls(p_sls_rec ddr_b_rtl_sl_rtn_itm_day%ROWTYPE
                     ,p_exp_sls  OUT NOCOPY NUMBER
                     ,x_return_status OUT NOCOPY VARCHAR2
                     ,x_msg OUT NOCOPY VARCHAR2
                     ) IS

v_day  DATE := NULL;

CURSOR c1 IS
SELECT frcst_sls_qty_prmry
FROM   ddr_b_sls_frcst_item_day
WHERE  day_cd = p_sls_rec.day_cd
AND    org_bsns_unit_id = p_sls_rec.org_bsns_unit_id
AND    mfg_sku_item_id = p_sls_rec.mfg_sku_item_id
AND    rtl_sku_item_id = p_sls_rec.rtl_sku_item_id
AND    frcst_typ = 'TOTAL'
AND    frcst_purp = 'SALES'
ORDER  BY frcst_vrsn desc;

CURSOR c2 IS
SELECT median(sls_qty_prmry) median_sales
FROM   ddr_b_rtl_sl_rtn_itm_day
WHERE  (day_cd = TO_CHAR(v_day-7,'YYYYMMDD')
       OR day_cd = TO_CHAR(v_day-14,'YYYYMMDD')
       OR day_cd = TO_CHAR(v_day-21,'YYYYMMDD')
       OR day_cd = TO_CHAR(v_day-28,'YYYYMMDD')
       OR day_cd = TO_CHAR(v_day-35,'YYYYMMDD')
       )
AND    org_bsns_unit_id = p_sls_rec.org_bsns_unit_id
AND    mfg_sku_item_id  = p_sls_rec.mfg_sku_item_id
AND    rtl_sku_item_id  = p_sls_rec.rtl_sku_item_id;

CURSOR c3 IS
SELECT median(sls_qty_prmry) median_sales
FROM   ddr_b_rtl_sl_rtn_itm_day
WHERE  day_cd > TO_CHAR(v_day-180,'YYYYMMDD')
AND    day_cd < TO_CHAR(v_day,'YYYYMMDD')
AND    org_bsns_unit_id = p_sls_rec.org_bsns_unit_id
AND    mfg_sku_item_id  = p_sls_rec.mfg_sku_item_id
AND    rtl_sku_item_id  = p_sls_rec.rtl_sku_item_id
AND    prmtn_flag = 'Y';
BEGIN

  x_return_status := ddr_emd_util.success;
  p_exp_sls := NULL;

  v_day := TO_DATE(p_sls_rec.day_cd,'YYYYMMDD');

  OPEN c1;
  FETCH c1 INTO p_exp_sls;
  CLOSE c1;

  IF p_exp_sls IS NOT NULL THEN  --{
    RETURN;
  END IF;  --{

  IF p_sls_rec.prmtn_flag = 'N' THEN  --{
    FOR rec IN c2 LOOP  --{
      p_exp_sls := rec.median_sales;
    END LOOP;  --}
  ELSE  --}{
    FOR rec IN c3 LOOP  --{
      p_exp_sls := rec.median_sales;
    END LOOP;  --}
  END IF;  --}
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := ddr_emd_util.error;
    x_msg := 'Failed in get_exp_sls'||' :'||SQLERRM;
END get_exp_sls;

PROCEDURE get_avg_sls(p_sls_rec ddr_b_rtl_sl_rtn_itm_day%ROWTYPE
                     ,p_avg_sls  OUT NOCOPY NUMBER
                     ,x_return_status OUT NOCOPY VARCHAR2
                     ,x_msg OUT NOCOPY VARCHAR2
                     ) IS

v_wk_strt_dt DATE:= NULL;

BEGIN
  x_return_status := ddr_emd_util.success;
  p_avg_sls := NULL;

  IF p_sls_rec.prmtn_flag = 'N' THEN  --{
    p_avg_sls :=  NULL;
    RETURN;
  END IF;  --}

  SELECT wk_strt_dt
  INTO   v_wk_strt_dt
  FROM   ddr_r_base_day_dn_mv
  WHERE  day_cd = p_sls_rec.day_cd
  AND    clndr_cd = mfg_org_cd||'-BSNS';

  IF (p_sls_rec.org_bsns_unit_id   = get_avg_sls_id1
     AND p_sls_rec.mfg_sku_item_id = get_avg_sls_id2
     AND p_sls_rec.rtl_sku_item_id = get_avg_sls_id3)  THEN  --{

     IF v_wk_strt_dt = get_avg_sls_wk_strt_dt THEN  --{
       p_avg_sls := get_avg_sls_avg_sls;
       RETURN;
     END IF;  --}
  END IF;  --}

     SELECT AVG(sls_qty_prmry)
     INTO   p_avg_sls
     FROM   ddr_b_rtl_sl_rtn_itm_day
     WHERE  day_cd BETWEEN TO_CHAR(v_wk_strt_dt-28,'YYYYMMDD')
                   AND TO_CHAR(v_wk_strt_dt,'YYYYMMDD')
     AND    org_bsns_unit_id = p_sls_rec.org_bsns_unit_id
     AND    mfg_sku_item_id  = p_sls_rec.mfg_sku_item_id
     AND    rtl_sku_item_id  = p_sls_rec.rtl_sku_item_id;

     get_avg_sls_id1 := p_sls_rec.org_bsns_unit_id;
     get_avg_sls_id2 := p_sls_rec.mfg_sku_item_id;
     get_avg_sls_id3 := p_sls_rec.rtl_sku_item_id;
     get_avg_sls_wk_strt_dt := v_wk_strt_dt;
     get_avg_sls_avg_sls := p_avg_sls;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := ddr_emd_util.error;
    x_msg := 'Failed in get_avg_sls'||' :'||SQLERRM;
END get_avg_sls;

PROCEDURE get_prmtn_price(p_sls_rec ddr_b_rtl_sl_rtn_itm_day%ROWTYPE
                         ,p_prmtn_price  OUT NOCOPY NUMBER
                         ,x_return_status OUT NOCOPY VARCHAR2
                         ,x_msg OUT NOCOPY VARCHAR2
                         ) IS
CURSOR c1 IS
SELECT MIN(prmtn_price_amt_rpt) min_prmtn_price
FROM   ddr_b_prmtn_pln
WHERE  org_bsns_unit_id = p_sls_rec.org_bsns_unit_id
AND    mfg_sku_item_id = p_sls_rec.mfg_sku_item_id
AND    rtl_sku_item_id = p_sls_rec.rtl_sku_item_id
AND    TO_DATE(p_sls_rec.day_cd,'YYYYMMDD') BETWEEN prmtn_from_dt AND prmtn_to_dt;

BEGIN

  x_return_status := ddr_emd_util.success;
  p_prmtn_price := NULL;

  IF p_sls_rec.prmtn_flag = 'N' THEN  --{
    RETURN;
  END IF;  --}

  FOR rec IN c1 LOOP  --{
    p_prmtn_price := rec.min_prmtn_price;
  END LOOP;  --}
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := ddr_emd_util.error;
    x_msg := 'Failed in get_prmtn_price'||' :'||SQLERRM;
END get_prmtn_price;

PROCEDURE get_sls_threshold(p_exp_sls       NUMBER
                           ,p_sls_threshold OUT NOCOPY NUMBER
                           ,x_return_status OUT NOCOPY VARCHAR2
                           ,x_msg OUT NOCOPY VARCHAR2
                           ) IS
  v_exp_sls NUMBER;
BEGIN
  x_return_status := ddr_emd_util.success;
  p_sls_threshold := NULL;
  v_exp_sls := p_exp_sls;

  IF get_sls_threshold_max_exp_sls IS NULL THEN  --{
    SELECT MAX(expctd_sls)
    INTO   get_sls_threshold_max_exp_sls
    FROM   ddr_r_excptn_sls_thrshld;
  END IF;

  IF v_exp_sls IS NULL THEN  --{
    RETURN;
  END IF;  --}

  IF v_exp_sls > get_sls_threshold_max_exp_sls THEN  --{
    v_exp_sls := get_sls_threshold_max_exp_sls;
  END IF;  --}

  IF v_exp_sls < 1 THEN  --{
    v_exp_sls := 1;
  END IF;  --}

  SELECT min_thrshld_actl_sls
  INTO   p_sls_threshold
  FROM   ddr_r_excptn_sls_thrshld
  WHERE  expctd_sls = ROUND(v_exp_sls);
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := ddr_emd_util.error;
    x_msg := 'Failed in get_sls_threshold'||' :'||SQLERRM;
END get_sls_threshold;

-- This procedure populates ddr_b_sl_rtl_addtnl_msrs table
-- measure3  => expected sales for the day
-- measure4  => avg price for last four weeks (used to calculate promotion lift)
-- measure5  => promotion price for the promo day
-- measure6  => Actual sales threshold (Poisson distribution number)

PROCEDURE populate_addtnl_sl_msrs_pvt(p_start_date      DATE
                                     ,p_end_date        DATE
                                     ,p_bsns_unit_id    NUMBER   DEFAULT NULL
                                     ,p_mfg_sku_item_id NUMBER   DEFAULT NULL
                                     ,p_rtl_sku_item_id NUMBER   DEFAULT NULL
                                     ,p_rtl_org_cd      VARCHAR2 DEFAULT NULL
                                     ,p_populate_m1     VARCHAR2 DEFAULT NULL
                                     ,p_populate_m2     VARCHAR2 DEFAULT NULL
                                     ,p_populate_m3     VARCHAR2 DEFAULT NULL
                                     ,p_populate_m4     VARCHAR2 DEFAULT NULL
                                     ,p_populate_m5     VARCHAR2 DEFAULT NULL
                                     ,p_populate_m6     VARCHAR2 DEFAULT NULL
                                     ,p_populate_m7     VARCHAR2 DEFAULT NULL
                                     ,p_populate_m8     VARCHAR2 DEFAULT NULL
                                     ,p_populate_m9     VARCHAR2 DEFAULT NULL
                                     ,p_populate_m10    VARCHAR2 DEFAULT NULL
                                     ,p_complete_refresh BOOLEAN DEFAULT TRUE
                                     ,x_return_status   OUT NOCOPY VARCHAR2
                                     ,x_msg             OUT NOCOPY VARCHAR2
                                     ) IS

  v_org_cd_tbl           ddr_emd_util.varchar_tbl;
  v_bsns_unit_id_tbl     ddr_emd_util.number_tbl;
  v_mfg_sku_item_id_tbl  ddr_emd_util.number_tbl;
  v_rtl_sku_item_id_tbl  ddr_emd_util.number_tbl;
  v_day_cd_tbl           ddr_emd_util.varchar_tbl;

  v_m1_tbl ddr_emd_util.date_tbl;
  v_m2_tbl ddr_emd_util.date_tbl;
  v_m3_tbl ddr_emd_util.number_tbl;
  v_m4_tbl ddr_emd_util.number_tbl;
  v_m5_tbl ddr_emd_util.number_tbl;
  v_m6_tbl ddr_emd_util.number_tbl;
  v_m7_tbl ddr_emd_util.number_tbl;
  v_m8_tbl ddr_emd_util.number_tbl;
  v_m9_tbl ddr_emd_util.number_tbl;
  v_m10_tbl ddr_emd_util.number_tbl;

  v_rec_count       NUMBER:= 0;

  sls_rec ddr_b_rtl_sl_rtn_itm_day%ROWTYPE;

  CURSOR sales_records IS
  SELECT *
  FROM  ddr_b_rtl_sl_rtn_itm_day
  WHERE day_cd > TO_CHAR((p_start_date-1),'YYYYMMDD')
  AND   day_cd < TO_CHAR((p_end_date+1),'YYYYMMDD')
  AND   rtl_org_cd = NVL(p_rtl_org_cd,rtl_org_cd)
  AND   org_bsns_unit_id = NVL(p_bsns_unit_id,org_bsns_unit_id)
  AND   mfg_sku_item_id = NVL(p_mfg_sku_item_id,mfg_sku_item_id)
  AND   rtl_sku_item_id = NVL(p_rtl_sku_item_id,rtl_sku_item_id)
  ORDER BY org_bsns_unit_id,mfg_sku_item_id,rtl_sku_item_id,day_cd asc;

BEGIN
  x_return_status := NULL;
  -- Truncate the table
  IF p_complete_refresh THEN  --{
    EXECUTE IMMEDIATE 'TRUNCATE TABLE ddr.ddr_b_rtl_sl_addtnl_msrs';
  END IF;  --}

  -- Start processing sales records
  --OPEN sales_records;
  --LOOP  --{
   -- FETCH sales_records INTO sls_rec;

    --EXIT WHEN sales_records%NOTFOUND;

  FOR sls_rec IN sales_records LOOP --{

    v_rec_count := v_rec_count+1;

    v_org_cd_tbl(v_rec_count)          := sls_rec.rtl_org_cd;
    v_bsns_unit_id_tbl(v_rec_count)    := sls_rec.org_bsns_unit_id;
    v_mfg_sku_item_id_tbl(v_rec_count) := sls_rec.mfg_sku_item_id;
    v_rtl_sku_item_id_tbl(v_rec_count) := sls_rec.rtl_sku_item_id;
    v_day_cd_tbl(v_rec_count)          := sls_rec.day_cd;

    -- Populate measure1  --{
    IF p_populate_m1 = ddr_emd_util.c_populate_custom THEN  --{
       /*
       ddr_custom_pkg.populate_addtnl_sl_msrs(sls_rec
                                             ,ddr_emd_util.m1
                                             ,v_m1_tbl(v_rec_count)
                                             ,x_return_status
                                             ,x_msg
                                             );
      */
      NULL;
    ELSIF p_populate_m1 = ddr_emd_util.c_populate_standard THEN --}{
      NULL;
    ELSE  --}{
      v_m1_tbl(v_rec_count):= NULL;
    END IF;  --}
    IF x_return_status = ddr_emd_util.error THEN  --{
      RETURN;
    END IF;  --}
    -- Populate measure1  --}

    -- Populate measure2  --{
    IF p_populate_m2 = ddr_emd_util.c_populate_custom THEN  --{
       /*
       ddr_custom_pkg.populate_addtnl_sl_msrs(sls_rec
                                             ,ddr_emd_util.m2
                                             ,v_m2_tbl(v_rec_count)
                                             ,x_return_status
                                             ,x_msg
                                             );
      */
      NULL;
    ELSIF p_populate_m2 = ddr_emd_util.c_populate_standard THEN --}{
      NULL;
    ELSE  --}{
      v_m2_tbl(v_rec_count):= NULL;
    END IF;  --}
    IF x_return_status = ddr_emd_util.error THEN  --{
      RETURN;
    END IF;  --}
    -- Populate measure2  --}

    -- Populate measure3  --{
    IF p_populate_m3 = ddr_emd_util.c_populate_custom THEN  --{
       /*
       ddr_custom_pkg.populate_addtnl_sl_msrs(sls_rec
                                             ,ddr_emd_util.m3
                                             ,v_m3_tbl(v_rec_count)
                                             ,x_return_status
                                             ,x_msg
                                             );
      */
      NULL;
    ELSIF p_populate_m3 = ddr_emd_util.c_populate_standard THEN --}{
      get_exp_sls(sls_rec
                 ,v_m3_tbl(v_rec_count)
                 ,x_return_status
                 ,x_msg
                 );
    ELSE  --}{
      v_m3_tbl(v_rec_count):= NULL;
    END IF;  --}
    IF x_return_status = ddr_emd_util.error THEN  --{
      RETURN;
    END IF;  --}
    -- Populate measure3  --}

    -- Populate measure4  --{
    IF p_populate_m4 = ddr_emd_util.c_populate_custom THEN  --{
       /*
       ddr_custom_pkg.populate_addtnl_sl_msrs(sls_rec
                                             ,ddr_emd_util.m4
                                             ,v_m4_tbl(v_rec_count)
                                             ,x_return_status
                                             ,x_msg
                                             );
      */
      NULL;
    ELSIF p_populate_m4 = ddr_emd_util.c_populate_standard THEN --}{
      get_avg_sls(sls_rec
                 ,v_m4_tbl(v_rec_count)
                 ,x_return_status
                 ,x_msg
                 );
    ELSE  --}{
      v_m4_tbl(v_rec_count):= NULL;
    END IF;  --}
    IF x_return_status = ddr_emd_util.error THEN  --{
      RETURN;
    END IF;  --}
    -- Populate measure4  --}

    -- Populate measure5  --{
    IF p_populate_m5 = ddr_emd_util.c_populate_custom THEN  --{
       /*
       ddr_custom_pkg.populate_addtnl_sl_msrs(sls_rec
                                             ,ddr_emd_util.m5
                                             ,v_m5_tbl(v_rec_count)
                                             ,x_return_status
                                             ,x_msg
                                             );
      */
      NULL;
    ELSIF p_populate_m5 = ddr_emd_util.c_populate_standard THEN --}{
      get_prmtn_price(sls_rec
                     ,v_m5_tbl(v_rec_count)
                     ,x_return_status
                     ,x_msg
                     );
      IF x_return_status = ddr_emd_util.error THEN  --{
        NULL;
      END IF;  --}
    ELSE  --}{
      v_m5_tbl(v_rec_count):= NULL;
    END IF;  --}
    IF x_return_status = ddr_emd_util.error THEN  --{
      RETURN;
    END IF;  --}
    -- Populate measure5  --}

    -- Populate measure6  --{
    IF p_populate_m6 = ddr_emd_util.c_populate_custom THEN  --{
       /*
       ddr_custom_pkg.populate_addtnl_sl_msrs(sls_rec
                                             ,ddr_emd_util.m6
                                             ,v_m6_tbl(v_rec_count)
                                             ,x_return_status
                                             ,x_msg
                                             );
      */
      NULL;
    ELSIF p_populate_m6 = ddr_emd_util.c_populate_standard THEN --}{
      get_sls_threshold(v_m3_tbl(v_rec_count)
                       ,v_m6_tbl(v_rec_count)
                       ,x_return_status
                       ,x_msg
                       );
    ELSE  --}{
      v_m6_tbl(v_rec_count):= NULL;
    END IF;  --}
    IF x_return_status = ddr_emd_util.error THEN  --{
      RETURN;
    END IF;  --}
    -- Populate measure6  --}

    -- Populate measure7  --{
    IF p_populate_m7 = ddr_emd_util.c_populate_custom THEN  --{
       /*
       ddr_custom_pkg.populate_addtnl_sl_msrs(sls_rec
                                             ,ddr_emd_util.m7
                                             ,v_m7_tbl(v_rec_count)
                                             ,x_return_status
                                             ,x_msg
                                             );
      */
      NULL;
    ELSIF p_populate_m7 = ddr_emd_util.c_populate_standard THEN --}{
      NULL;
    ELSE  --}{
      v_m7_tbl(v_rec_count):= NULL;
    END IF;  --}
    IF x_return_status = ddr_emd_util.error THEN  --{
      RETURN;
    END IF;  --}
    -- Populate measure7  --}

    -- Populate measure8  --{
    IF p_populate_m8 = ddr_emd_util.c_populate_custom THEN  --{
       /*
       ddr_custom_pkg.populate_addtnl_sl_msrs(sls_rec
                                             ,ddr_emd_util.m8
                                             ,v_m8_tbl(v_rec_count)
                                             ,x_return_status
                                             ,x_msg
                                             );
      */
      NULL;
    ELSIF p_populate_m8 = ddr_emd_util.c_populate_standard THEN --}{
      NULL;
    ELSE  --}{
      v_m8_tbl(v_rec_count):= NULL;
    END IF;  --}
    IF x_return_status = ddr_emd_util.error THEN  --{
      RETURN;
    END IF;  --}
    -- Populate measure8  --}

    -- Populate measure9  --{
    IF p_populate_m9 = ddr_emd_util.c_populate_custom THEN  --{
       /*
       ddr_custom_pkg.populate_addtnl_sl_msrs(sls_rec
                                             ,ddr_emd_util.m9
                                             ,v_m9_tbl(v_rec_count)
                                             ,x_return_status
                                             ,x_msg
                                             );
      */
      NULL;
    ELSIF p_populate_m9 = ddr_emd_util.c_populate_standard THEN --}{
      NULL;
    ELSE  --}{
      v_m9_tbl(v_rec_count):= NULL;
    END IF;  --}
    IF x_return_status = ddr_emd_util.error THEN  --{
      RETURN;
    END IF;  --}
    -- Populate measure9  --}

    -- Populate measure10  --{
    IF p_populate_m10 = ddr_emd_util.c_populate_custom THEN  --{
       /*
       ddr_custom_pkg.populate_addtnl_sl_msrs(sls_rec
                                             ,ddr_emd_util.m10
                                             ,v_m10_tbl(v_rec_count)
                                             ,x_return_status
                                             ,x_msg
                                             );
      */
      NULL;
    ELSIF p_populate_m10 = ddr_emd_util.c_populate_standard THEN --}{
      NULL;
    ELSE  --}{
      v_m10_tbl(v_rec_count):= NULL;
    END IF;  --}
    IF x_return_status = ddr_emd_util.error THEN  --{
      RETURN;
    END IF;  --}
    -- Populate measure10  --}

    IF MOD(v_rec_count,ddr_emd_util.c_batch_size) = 0 THEN  --{
      FORALL i IN 1..v_rec_count
        INSERT INTO ddr_b_rtl_sl_addtnl_msrs(rtl_org_cd
                                            ,org_bsns_unit_id
                                            ,mfg_sku_item_id
                                            ,rtl_sku_item_id
                                            ,day_cd
                                            ,measure1
                                            ,measure2
                                            ,measure3
                                            ,measure4
                                            ,measure5
                                            ,measure6
                                            ,measure7
                                            ,measure8
                                            ,measure9
                                            ,measure10
                                            ) VALUES
                                            (v_org_cd_tbl(i)
                                            ,v_bsns_unit_id_tbl(i)
                                            ,v_mfg_sku_item_id_tbl(i)
                                            ,v_rtl_sku_item_id_tbl(i)
                                            ,v_day_cd_tbl(i)
                                            ,v_m1_tbl(i)
                                            ,v_m2_tbl(i)
                                            ,v_m3_tbl(i)
                                            ,v_m4_tbl(i)
                                            ,v_m5_tbl(i)
                                            ,v_m6_tbl(i)
                                            ,v_m7_tbl(i)
                                            ,v_m8_tbl(i)
                                            ,v_m9_tbl(i)
                                            ,v_m10_tbl(i)
                                            );
      COMMIT;
      v_org_cd_tbl.DELETE;
      v_bsns_unit_id_tbl.DELETE;
      v_mfg_sku_item_id_tbl.DELETE;
      v_rtl_sku_item_id_tbl.DELETE;
      v_day_cd_tbl.DELETE;
      v_m1_tbl.DELETE;
      v_m2_tbl.DELETE;
      v_m3_tbl.DELETE;
      v_m4_tbl.DELETE;
      v_m5_tbl.DELETE;
      v_m6_tbl.DELETE;
      v_m7_tbl.DELETE;
      v_m8_tbl.DELETE;
      v_m9_tbl.DELETE;
      v_m10_tbl.DELETE;

      v_rec_count := 0;
    END IF;  --}

  END LOOP;  --}

  --CLOSE sales_records;

  FORALL i IN 1..v_rec_count
    INSERT INTO ddr_b_rtl_sl_addtnl_msrs(rtl_org_cd
                                        ,org_bsns_unit_id
                                        ,mfg_sku_item_id
                                        ,rtl_sku_item_id
                                        ,day_cd
                                        ,measure1
                                        ,measure2
                                        ,measure3
                                        ,measure4
                                        ,measure5
                                        ,measure6
                                        ,measure7
                                        ,measure8
                                        ,measure9
                                        ,measure10
                                        ) VALUES
                                        (v_org_cd_tbl(i)
                                        ,v_bsns_unit_id_tbl(i)
                                        ,v_mfg_sku_item_id_tbl(i)
                                        ,v_rtl_sku_item_id_tbl(i)
                                        ,v_day_cd_tbl(i)
                                        ,v_m1_tbl(i)
                                        ,v_m2_tbl(i)
                                        ,v_m3_tbl(i)
                                        ,v_m4_tbl(i)
                                        ,v_m5_tbl(i)
                                        ,v_m6_tbl(i)
                                        ,v_m7_tbl(i)
                                        ,v_m8_tbl(i)
                                        ,v_m9_tbl(i)
                                        ,v_m10_tbl(i)
                                        );
  COMMIT;

END populate_addtnl_sl_msrs_pvt;

PROCEDURE calc_exception_measures(p_date_offset          IN NUMBER
                                 ,p_bsns_unit_cd         IN VARCHAR2 DEFAULT NULL
                                 ,p_rtl_org_cd           IN VARCHAR2 DEFAULT NULL
                                 ,p_calc_ifpl_excptn     IN BOOLEAN
                                 ,p_calc_oosim_excptn    IN BOOLEAN
                                 ,p_calc_npisales_excptn IN BOOLEAN
                                 ,x_return_status    OUT NOCOPY VARCHAR2
                                 ,x_msg              OUT NOCOPY VARCHAR2
                                 ) IS
v_bsns_unit_id  ddr_r_org_bsns_unit.org_bsns_unit_id%TYPE;
v_calc_ifpl_excptn  VARCHAR(1):= NULL;
v_calc_oosim_excptn VARCHAR(1):= NULL;

BEGIN
  IF p_bsns_unit_cd IS NOT NULL THEN  --{
    BEGIN
      SELECT org_bsns_unit_id
      INTO   v_bsns_unit_id
      FROM   ddr_r_org_bsns_unit
      WHERE  org_cd = NVL(p_rtl_org_cd,org_cd)
      AND    bsns_unit_cd = p_bsns_unit_cd
      AND    eff_to_dt IS NULL;
    EXCEPTION
      WHEN TOO_MANY_ROWS THEN
         x_return_status := ddr_emd_util.error;
         x_msg := 'org_cd and bsns_unit_cd combination not unique';
         RETURN;
    END;
  END IF;  --}
  IF p_calc_npisales_excptn THEN  --{
    populate_new_items(p_date=>TRUNC(SYSDATE)
                      ,p_bsns_unit_id=>v_bsns_unit_id
                      ,p_mfg_sku_item_id=>NULL
                      ,p_rtl_org_cd=>p_rtl_org_cd
                      ,p_complete_refresh=>TRUE
                      ,x_return_status=>x_return_status
                      ,x_msg=>x_msg
                      );
    IF x_return_status = ddr_emd_util.error THEN  --{
      RETURN;
    END IF;
  END IF;  --}


  IF p_calc_ifpl_excptn THEN  --{
    v_calc_ifpl_excptn := ddr_emd_util.c_populate_standard;
  END IF;
  IF p_calc_oosim_excptn THEN  --{
    v_calc_oosim_excptn := ddr_emd_util.c_populate_standard;
  END IF;

  populate_addtnl_sl_msrs_pvt(p_start_date=>TRUNC(SYSDATE - p_date_offset)
                             ,p_end_date=>SYSDATE
                             ,p_bsns_unit_id=>v_bsns_unit_id
                             ,p_mfg_sku_item_id=>NULL
                             ,p_rtl_sku_item_id=>NULL
                             ,p_rtl_org_cd=>p_rtl_org_cd
                             ,p_populate_m1=>NULL
                             ,p_populate_m2=>NULL
                             ,p_populate_m3=>v_calc_oosim_excptn
                             ,p_populate_m4=>v_calc_ifpl_excptn
                             ,p_populate_m5=>NULL
                             ,p_populate_m6=>v_calc_oosim_excptn
                             ,p_populate_m7=>NULL
                             ,p_populate_m8=>NULL
                             ,p_populate_m9=>NULL
                             ,p_populate_m10=>NULL
                             ,p_complete_refresh=>TRUE
                             ,x_return_status=>x_return_status
                             ,x_msg=>x_msg
                             );
  x_return_status := NVL(x_return_status,ddr_emd_util.success);
EXCEPTION
  WHEN OTHERS THEN
       x_return_status := NVL(x_return_status,ddr_emd_util.error);
       x_msg := NVL(x_msg,SQLERRM); --'Exception raised while processing the request');
END calc_exception_measures;

END ddr_emd_util;

/
