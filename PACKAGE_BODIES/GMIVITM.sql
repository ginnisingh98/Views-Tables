--------------------------------------------------------
--  DDL for Package Body GMIVITM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMIVITM" AS
/* $Header: GMIVITMB.pls 115.28 2003/10/13 16:47:01 jsrivast ship $ */


/*  Global variables */
G_PKG_NAME  CONSTANT  VARCHAR2(30) := 'GMIVITM';

FUNCTION v_classes (p_item_rec IN GMIGAPI.item_rec_typ)
RETURN BOOLEAN
IS
  row_count number;

/*=====================================================
  01/14/02   Joe DiIorio - BUG#2177942 11.5.1I
 ====================================================*/
  wk_rank_count    number;

CURSOR Get_rank
IS
Select count(*)
from   ic_rank_mst
where  abc_code=p_item_rec.item_abccode and delete_mark = 0;



BEGIN

 IF (p_item_rec.alloc_class IS NOT NULL) THEN
       -- BUG#2461984 VAK
       select 1 into row_count from ic_allc_cls
       where alloc_class=RTRIM(p_item_rec.alloc_class) and delete_mark = 0;

       IF (row_count <> 1) THEN
           Return FALSE;
       END IF;

END IF;

IF (p_item_rec.itemcost_class IS NOT NULL) THEN
       -- BUG#2461984 VAK
       select 1 into row_count from ic_cost_cls
       where itemcost_class=RTRIM(p_item_rec.itemcost_class) and delete_mark = 0;

       IF (row_count <> 1) THEN
           Return FALSE;
       END IF;

END IF;

IF (p_item_rec.customs_class IS NOT NULL) THEN
       -- BUG#2461984 VAK
       select 1 into row_count from ic_ctms_cls
       where iccustoms_class=RTRIM(p_item_rec.customs_class) and delete_mark = 0;

       IF (row_count <> 1) THEN
           Return FALSE;
       END IF;

END IF;


IF (p_item_rec.frt_class IS NOT NULL) THEN
       -- BUG#2461984 VAK
       select 1 into row_count from ic_frgt_cls
       where icfrt_class=RTRIM(p_item_rec.frt_class) and delete_mark = 0;

       IF (row_count <> 1) THEN
           Return FALSE;
       END IF;

END IF;


IF (p_item_rec.gl_class IS NOT NULL) THEN
       -- BUG#2461984 VAK
       select 1 into row_count from ic_gled_cls
       where icgl_class=RTRIM(p_item_rec.gl_class) and delete_mark = 0;

       IF (row_count <> 1) THEN
           Return FALSE;
       END IF;

END IF;

IF (p_item_rec.inv_class IS NOT NULL) THEN
       -- BUG#2461984 VAK
       select 1 into row_count from ic_invn_cls
       where icinv_class=RTRIM(p_item_rec.inv_class) and delete_mark = 0;

       IF (row_count <> 1) THEN
           Return FALSE;
       END IF;

END IF;

IF (p_item_rec.price_class IS NOT NULL) THEN
       -- BUG#2461984 VAK
       select 1 into row_count from ic_prce_cls
       where icprice_class=RTRIM(p_item_rec.price_class) and delete_mark = 0;

       IF (row_count <> 1) THEN
           Return FALSE;
       END IF;

END IF;

IF (p_item_rec.purch_class IS NOT NULL) THEN
       -- BUG#2461984 VAK
       select 1 into row_count from ic_prch_cls
       where icpurch_class=RTRIM(p_item_rec.purch_class) and delete_mark = 0;

       IF (row_count <> 1) THEN
           Return FALSE;
       END IF;

END IF;


/*=====================================================
  01/14/02   Joe DiIorio - BUG#2177942 11.5.1I
 ====================================================*/
IF (p_item_rec.item_abccode IS NOT NULL) THEN
       OPEN Get_rank;
       FETCH Get_rank into wk_rank_count;
       CLOSE Get_rank;
       IF (wk_rank_count = 0) THEN
           Return FALSE;
       END IF;
END IF;

IF (p_item_rec.sales_class IS NOT NULL) THEN
       -- BUG#2461984 VAK
       select 1 into row_count from ic_sale_cls
       where icsales_class=RTRIM(p_item_rec.sales_class) and delete_mark = 0;

       IF (row_count <> 1) THEN
           Return FALSE;
       END IF;

END IF;


IF (p_item_rec.ship_class IS NOT NULL) THEN
       -- BUG#2461984 VAK
       select 1 into row_count from ic_ship_cls
       where icship_class=RTRIM(p_item_rec.ship_class) and delete_mark = 0;

       IF (row_count <> 1) THEN
           Return FALSE;
       END IF;

END IF;


IF (p_item_rec.storage_class IS NOT NULL) THEN
       -- BUG#2461984 VAK
       select 1 into row_count from ic_stor_cls
       where icstorage_class=RTRIM(p_item_rec.storage_class) and delete_mark = 0;

       IF (row_count <> 1) THEN
           Return FALSE;
       END IF;

END IF;


IF (p_item_rec.tax_class IS NOT NULL) THEN
       -- BUG#2461984 VAK
       select 1 into row_count from ic_taxn_cls
       where ictax_class=RTRIM(p_item_rec.tax_class) and delete_mark = 0;

       IF (row_count <> 1) THEN
           Return FALSE;
       END IF;

END IF;


IF (p_item_rec.planning_class IS NOT NULL) THEN
       -- BUG#2461984 VAK
       select 1 into row_count from ps_plng_cls
       where planning_class=RTRIM(p_item_rec.planning_class) and delete_mark = 0;

       IF (row_count <> 1) THEN
           Return FALSE;
       END IF;

END IF;


IF (p_item_rec.qchold_res_code IS NOT NULL) THEN
       -- BUG#2461984 VAK
       select 1 into row_count from qc_hres_mst
       where qchold_res_code=RTRIM(p_item_rec.qchold_res_code) and delete_mark = 0;

       IF (row_count <> 1) THEN
           Return FALSE;
       END IF;

END IF;


IF (p_item_rec.seq_dpnd_class IS NOT NULL) THEN
       -- BUG#2461984 VAK
       select 1 into row_count from cr_sqdt_cls
       where seq_dpnd_class=RTRIM(p_item_rec.seq_dpnd_class) and delete_mark = 0;

       IF (row_count <> 1) THEN
           Return FALSE;
       END IF;

END IF;


IF (p_item_rec.inv_type IS NOT NULL) THEN
       -- BUG#2461984 VAK
       select 1 into row_count from ic_invn_typ
       where inv_type=RTRIM(p_item_rec.inv_type) and delete_mark = 0;

       IF (row_count <> 1) THEN
           Return FALSE;
       END IF;

END IF;


IF (p_item_rec.cost_mthd_code IS NOT NULL) THEN
       -- BUG#2461984 VAK
       select 1 into row_count from cm_mthd_mst
       where cost_mthd_code=RTRIM(p_item_rec.cost_mthd_code) and delete_mark = 0;

       IF (row_count <> 1) THEN
           Return FALSE;
       END IF;

END IF;


-- TKW 9/11/2003 B2378017
-- Added validation for four new classes.
IF (p_item_rec.gl_business_class IS NOT NULL) THEN

       select 1 into row_count from gl_business_cls_vw
       where gl_business_class=RTRIM(p_item_rec.gl_business_class) and delete_mark = 0;

       IF (row_count <> 1) THEN
           Return FALSE;
       END IF;

END IF;


IF (p_item_rec.gl_prod_line IS NOT NULL) THEN

       select 1 into row_count from gl_prod_line_vw
       where gl_product_line=RTRIM(p_item_rec.gl_prod_line) and delete_mark = 0;

       IF (row_count <> 1) THEN
           Return FALSE;
       END IF;

END IF;


IF (p_item_rec.sub_standard_class IS NOT NULL) THEN

       select 1 into row_count from sub_std_item_cls_vw
       where sub_standard_class=RTRIM(p_item_rec.sub_standard_class) and delete_mark = 0;

       IF (row_count <> 1) THEN
           Return FALSE;
       END IF;

END IF;


IF (p_item_rec.tech_class IS NOT NULL) THEN

       select 1 into row_count from tech_cls_subcls_vw
       where tech_class=RTRIM(p_item_rec.tech_class) and delete_mark = 0;

       IF (row_count <> 1) THEN
           Return FALSE;
       END IF;

END IF;


  RETURN TRUE;

  EXCEPTION
  WHEN OTHERS
  THEN
    RETURN FALSE;
END v_classes;

FUNCTION v_commodity_code(p_item_rec IN GMIGAPI.item_rec_typ)
RETURN BOOLEAN
IS
  l_row_count NUMBER;
BEGIN
  SELECT 1 INTO l_row_count
  FROM ic_comd_cds
  WHERE commodity_code=UPPER(p_item_rec.commodity_code)
  AND   delete_mark = 0;

  IF l_row_count > 0
  THEN
    RETURN TRUE;
  END IF;

  RETURN FALSE;

  EXCEPTION
  WHEN OTHERS
  THEN RETURN FALSE;
END v_commodity_code;




/* +==========================================================================+
 | PROCEDURE NAME                                                           |
 |    Validate_Item                                                         |
 |                                                                          |
 | TYPE                                                                     |
 |    Private                                                               |
 |                                                                          |
 | USAGE                                                                    |
 |  Validate item record                                                    |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_api_version      IN  NUMBER       - Api Version                     |
 |    p_validation_level IN  VARCHAR2     - Validation Level Indicator      |
 |    p_item_rec         IN  item_rec_typ - Item Master details             |
 |    x_ic_item_mst_row  OUT ic_item_mst%ROWTYPE                            |
 |    x_ic_item_cpg_row  OUT ic_item_cpg%ROWTYPE                            |
 |    x_return_status    OUT VARCHAR2     - Return Status                   |
 |    x_msg_count        OUT NUMBER       - Number of messages              |
 |    x_msg_data         OUT VARCHAR2     - Messages in encoded format      |
 |                                                                          |
 | RETURNS                                                                  |
 |    Via x_ parameters                                                     |
 |                                                                          |
 | HISTORY                                                                  |
 |                                                                          |
 | 21/Feb/2002  P Lowe           Bug 2233859 - Field ont_pricing_qty_source |
 |                               added - (no validation (default is 0))in   |
 |				 item_rec_typ record for the       	    |
 |  				 Pricing by Quantity 2 project.             |
 |                                                                          |
 |  07-18-2002  V. Ajay Kumar    BUG#2461984  Prefixed the 'RTRIM'          |
 |                               function for all the VARCHAR2 type fields  |
 |                               in order to suppress the trailing spaces.  |
 |																									 |
 |	 13-Aug-2002 A. Mundhe			Bug 2506207 - Removed the 'UPPER' function |
 |                               on all attribute columns.                  |
 +==========================================================================+
 */
PROCEDURE Validate_item
( p_api_version      IN NUMBER
, p_validation_level IN VARCHAR2 :=FND_API.G_VALID_LEVEL_FULL
, p_item_rec         IN GMIGAPI.item_rec_typ
, x_ic_item_mst_row  OUT NOCOPY ic_item_mst%ROWTYPE
, x_ic_item_cpg_row  OUT NOCOPY ic_item_cpg%ROWTYPE
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
)
IS
  l_ic_item_mst_row  ic_item_mst%ROWTYPE;
  l_ic_item_cpg_row  ic_item_cpg%ROWTYPE;
  l_sy_uoms_mst_row  sy_uoms_mst%ROWTYPE;
  l_sy_uoms_typ_row  sy_uoms_typ%ROWTYPE;
  l_qc_grad_mst_row  qc_grad_mst%ROWTYPE;
  l_qc_actn_mst_row  qc_actn_mst%ROWTYPE;
  l_ic_lots_sts_row  ic_lots_sts%ROWTYPE;
  l_api_name VARCHAR2(30) := 'Validate Item';
BEGIN

  /*  Standard call to check for call compatibility. */
  IF NOT FND_API.Compatible_API_CALL
    (GMIGUTL.API_VERSION, p_api_version, 'Validate_Item', G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /*  Validate input record and setup output rows */

  /*  Item ID/Number/Descriptions/Alternatives */
  x_ic_item_mst_row.item_id            := NULL;
  -- BEGIN BUG#2461984 VAK
  x_ic_item_mst_row.item_no            := UPPER(RTRIM(p_item_rec.item_no));
  x_ic_item_mst_row.item_desc1         := RTRIM(p_item_rec.item_desc1);
  IF NVL(p_item_rec.item_desc1, ' ') = ' '
  THEN
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_ITEM_DESC1');

    FND_MESSAGE.SET_TOKEN('ITEM_NO',p_item_rec.item_no);
    FND_MSG_PUB.Add;
  ELSE
    x_ic_item_mst_row.item_desc2         := RTRIM(p_item_rec.item_desc2);
  END IF;

  x_ic_item_mst_row.alt_itema          := RTRIM(p_item_rec.alt_itema);
  x_ic_item_mst_row.alt_itemb          := RTRIM(p_item_rec.alt_itemb);

  /*  Unit of Measure */

  GMIGUTL.get_um(RTRIM(p_item_rec.item_um), l_sy_uoms_mst_row, l_sy_uoms_typ_row);
  IF l_sy_uoms_mst_row.um_code IS NOT NULL
  THEN
    x_ic_item_mst_row.item_um := RTRIM(l_sy_uoms_mst_row.um_code);
  ELSE
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_UOM');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',p_item_rec.item_no);
    FND_MESSAGE.SET_TOKEN('UOM',p_item_rec.item_um);
    FND_MSG_PUB.Add;
  END IF;
  -- END BUG#2461984 VAK
  /*  Dual unit of measure indicator                                                */
  IF p_item_rec.dualum_ind BETWEEN 0 AND 3
  THEN
    x_ic_item_mst_row.dualum_ind := p_item_rec.dualum_ind;
  ELSE
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_DUALUM_IND');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',p_item_rec.item_no);
    FND_MSG_PUB.Add;
  END IF;

  /*  Secondary Unit of Measure - ignore if dualum_ind=0 */
  /*  For any other case, ensure it's present and not the */
  /*  same as the primary um. If the unit of meaure conversion */
  /*  is not fixed then validate the deviations too. As these */
  /*  columns are not null, set them to zero before continuing. */

  x_ic_item_mst_row.deviation_lo := 0;
  x_ic_item_mst_row.deviation_hi := 0;

  IF x_ic_item_mst_row.dualum_ind > 0
  THEN
    IF NVL(p_item_rec.item_um2, x_ic_item_mst_row.item_um) <>
       x_ic_item_mst_row.item_um
    THEN
      -- BUG#2461984 VAK
      GMIGUTL.get_um(RTRIM(p_item_rec.item_um2), l_sy_uoms_mst_row, l_sy_uoms_typ_row);
      IF l_sy_uoms_mst_row.um_code IS NOT NULL
      THEN
        -- BUG#2461984 VAK
        x_ic_item_mst_row.item_um2 := RTRIM(l_sy_uoms_mst_row.um_code);
      END IF;
    END IF;

    IF x_ic_item_mst_row.item_um2 IS NULL
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_UOM');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',p_item_rec.item_no);
      FND_MESSAGE.SET_TOKEN('UOM',p_item_rec.item_um2);
      FND_MSG_PUB.Add;
    ELSE
      IF x_ic_item_mst_row.dualum_ind > 1
      THEN
        IF NVL(p_item_rec.deviation_lo,0) <= 0 OR
           NVL(p_item_rec.deviation_hi,0) <= 0
        THEN
          FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_DEVIATION');
          FND_MESSAGE.SET_TOKEN('ITEM_NO',p_item_rec.item_no);
          FND_MSG_PUB.Add;
        ELSE
          x_ic_item_mst_row.deviation_lo := p_item_rec.deviation_lo;
          x_ic_item_mst_row.deviation_hi := p_item_rec.deviation_hi;
        END IF;
      END IF;
    END IF;
  ELSE
    x_ic_item_mst_row.deviation_lo := 0;
    x_ic_item_mst_row.deviation_hi := 0;
  END IF;

  /*  Level Code. Unused, so use 'as is'       */
  x_ic_item_mst_row.level_code         := p_item_rec.level_code;

/*  lot/sublot/indivisible/Noninv flags */

  x_ic_item_mst_row.noninv_ind := NVL(p_item_rec.noninv_ind,0);

  IF x_ic_item_mst_row.noninv_ind BETWEEN 0 AND 1
  THEN
    NULL;
  ELSE
    x_ic_item_mst_row.noninv_ind:= NULL;
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_NONINV_IND');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',p_item_rec.item_no);
    FND_MSG_PUB.Add;
  END IF;

  IF NVL(p_item_rec.lot_ctl, -1) BETWEEN 0 AND 1
  THEN
    x_ic_item_mst_row.lot_ctl := p_item_rec.lot_ctl;

    IF x_ic_item_mst_row.lot_ctl = 1
    THEN
      IF NVL(p_item_rec.sublot_ctl, -1) BETWEEN 0 AND 1
      THEN
        x_ic_item_mst_row.sublot_ctl := p_item_rec.sublot_ctl;
      ELSE
        FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_SUBLOT_CTL');
        FND_MESSAGE.SET_TOKEN('ITEM_NO',p_item_rec.item_no);
        FND_MSG_PUB.Add;
      END IF;

      IF NVL(p_item_rec.lot_indivisible, -1) BETWEEN 0 AND 1
      THEN
        x_ic_item_mst_row.lot_indivisible := p_item_rec.lot_indivisible;
      ELSE
        FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_INDIVISIBLE');
        FND_MESSAGE.SET_TOKEN('ITEM_NO',p_item_rec.item_no);
        FND_MSG_PUB.Add;
      END IF;

      IF x_ic_item_mst_row.noninv_ind = 1
      THEN
        FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_NONINV_IND');
        FND_MESSAGE.SET_TOKEN('ITEM_NO',p_item_rec.item_no);
        FND_MSG_PUB.Add;
      END IF;
    ELSE
      x_ic_item_mst_row.sublot_ctl := 0;
      x_ic_item_mst_row.lot_indivisible := 0;
    END IF;
  ELSE
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_CTL');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',p_item_rec.item_no);
    FND_MSG_PUB.Add;
  END IF;

  /*  Match type is not used(?) */
  x_ic_item_mst_row.match_type := 3;

  /*  Inactive indicator */
  x_ic_item_mst_row.inactive_ind := NVL(p_item_rec.inactive_ind,0);
  IF x_ic_item_mst_row.inactive_ind BETWEEN 0 AND 1
  THEN
    NULL;
  ELSE
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_INACTIVE_IND');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',p_item_rec.item_no);
    FND_MSG_PUB.Add;
  END IF;

  /*  Location control flag */
  x_ic_item_mst_row.loct_ctl := NVL(p_item_rec.loct_ctl,0);
  IF x_ic_item_mst_row.loct_ctl BETWEEN 0 AND 2
  THEN
    NULL;
  ELSE
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOCT_CTL');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',p_item_rec.item_no);
    FND_MSG_PUB.Add;
  END IF;

  /*  Grade, status control etc. If item is lot controlled,  */
  /*  validate everything, else default it. */

  IF x_ic_item_mst_row.lot_ctl = 1
  THEN
    x_ic_item_mst_row.grade_ctl := NVL(p_item_rec.grade_ctl,0);
    x_ic_item_mst_row.shelf_life := NVL(p_item_rec.shelf_life,0);
    x_ic_item_mst_row.retest_interval := NVL(p_item_rec.retest_interval,0);
    x_ic_item_mst_row.expaction_interval := NVL(p_item_rec.expaction_interval,0);

    IF x_ic_item_mst_row.grade_ctl BETWEEN 0 AND 1
    THEN
      IF x_ic_item_mst_row.grade_ctl = 1
      THEN
        IF NVL(p_item_rec.qc_grade, ' ') <> ' '
        THEN
          -- BUG#2461984 VAK
          IF GMIGUTL.v_qc_grade(UPPER(RTRIM(p_item_rec.qc_grade)), l_qc_grad_mst_row)
          THEN
            x_ic_item_mst_row.qc_grade := l_qc_grad_mst_row.qc_grade;
          END IF;
        END IF;

        IF x_ic_item_mst_row.qc_grade IS NULL
        THEN
          FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_QC_GRADE');
          FND_MESSAGE.SET_TOKEN('ITEM_NO',p_item_rec.item_no);
          FND_MSG_PUB.Add;
        END IF;
      END IF;    /* moved here for bug#1653385  */

        x_ic_item_mst_row.retest_interval := NVL(p_item_rec.retest_interval,0);
        IF x_ic_item_mst_row.retest_interval < 0
        THEN
          FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_RETEST_INTERVAL');
          FND_MESSAGE.SET_TOKEN('ITEM_NO',p_item_rec.item_no);
          FND_MSG_PUB.Add;
        END IF;

        x_ic_item_mst_row.shelf_life := NVL(p_item_rec.shelf_life,0);
        IF x_ic_item_mst_row.shelf_life < 0
        THEN
          FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_SHELF_LIFE');
          FND_MESSAGE.SET_TOKEN('ITEM_NO',p_item_rec.item_no);
          FND_MSG_PUB.Add;
        END IF;

        IF NVL(p_item_rec.expaction_code, ' ') <> ' '
        THEN
          -- BUG#2461984 VAK
          IF GMIGUTL.v_expaction_code(UPPER(RTRIM(p_item_rec.expaction_code)),l_qc_actn_mst_row)
          THEN
            x_ic_item_mst_row.expaction_code := l_qc_actn_mst_row.action_code;
          END IF;
        END IF;

--Jalaj Srivastava Bug 1617398
--expaction code should not be a required field
      /*  IF x_ic_item_mst_row.expaction_code IS NULL
        THEN
          FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_EXPACTION_CODE');
          FND_MESSAGE.SET_TOKEN('ITEM_NO',p_item_rec.item_no);
          FND_MSG_PUB.Add;
        END IF;   */

        x_ic_item_mst_row.expaction_interval := NVL(p_item_rec.expaction_interval,0);
        IF x_ic_item_mst_row.expaction_interval < 0
        THEN
          FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_EXPACTION_INTERVAL');
          FND_MESSAGE.SET_TOKEN('ITEM_NO',p_item_rec.item_no);
          FND_MSG_PUB.Add;
        END IF;
        /*************************************************
           BUG#1653385 - moved this end if up.
         END IF;
         ************************************************/
    ELSE
      FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_GRADE_CTL');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',p_item_rec.item_no);
      FND_MSG_PUB.Add;
    END IF;

    x_ic_item_mst_row.status_ctl := NVL(p_item_rec.status_ctl,0);

    IF x_ic_item_mst_row.status_ctl BETWEEN 0 AND 1
    THEN
      IF x_ic_item_mst_row.status_ctl = 1
      THEN
        IF NVL(p_item_rec.lot_status, ' ') <> ' '
        THEN
          IF GMIGUTL.v_lot_status(UPPER(p_item_rec.lot_status), l_ic_lots_sts_row)
          THEN
            x_ic_item_mst_row.lot_status := l_ic_lots_sts_row.lot_status;
          END IF;
        END IF;

        IF x_ic_item_mst_row.lot_status IS NULL
        THEN
          FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_LOT_STATUS');
          FND_MESSAGE.SET_TOKEN('ITEM_NO',p_item_rec.item_no);
          FND_MESSAGE.SET_TOKEN('LOT_STATUS', p_item_rec.lot_status);
          FND_MSG_PUB.Add;
        END IF;
      END IF;
    ELSE
      FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_STATUS_CTL');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',p_item_rec.item_no);
      FND_MSG_PUB.Add;
    END IF;
  ELSE
    x_ic_item_mst_row.grade_ctl := 0;
    x_ic_item_mst_row.qc_grade := NULL;
    x_ic_item_mst_row.status_ctl := 0;
    x_ic_item_mst_row.lot_status := NULL;
    x_ic_item_mst_row.expaction_interval := 0;
    x_ic_item_mst_row.retest_interval := 0;
    x_ic_item_mst_row.expaction_code := NULL;
    x_ic_item_mst_row.shelf_life := 0;
  END IF;

  /*  Experimental Indicator */

  x_ic_item_mst_row.experimental_ind := NVL(p_item_rec.experimental_ind,0);
  IF x_ic_item_mst_row.experimental_ind BETWEEN 0 AND 1
  THEN
    NULL;
  ELSE
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_EXPERIMENTAL');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',p_item_rec.item_no);
    FND_MSG_PUB.Add;
  END IF;

  /*  GL class/Inv Class/Sales Class/Ship Class/Frt Class/ */
  /*  Price Class/Storage Class/Purch Class/Tax Class/Customs Class/ */
  /*  Alloc Class/Planning Class/Itemcost Class/Cost Mthd Code/UPC Code/ */
  /*  ABC Code */

  IF GMIVITM.v_classes(p_item_rec)
  THEN
    --BEGIN BUG#2461984 VAK
    x_ic_item_mst_row.item_abccode       := UPPER(RTRIM(p_item_rec.item_abccode));
    x_ic_item_mst_row.gl_class           := UPPER(RTRIM(p_item_rec.gl_class));
    x_ic_item_mst_row.inv_class          := UPPER(RTRIM(p_item_rec.inv_class));
    x_ic_item_mst_row.sales_class        := UPPER(RTRIM(p_item_rec.sales_class));
    x_ic_item_mst_row.ship_class         := UPPER(RTRIM(p_item_rec.ship_class));
    x_ic_item_mst_row.frt_class          := UPPER(RTRIM(p_item_rec.frt_class));
    x_ic_item_mst_row.price_class        := UPPER(RTRIM(p_item_rec.price_class));
    x_ic_item_mst_row.storage_class      := UPPER(RTRIM(p_item_rec.storage_class));
    x_ic_item_mst_row.purch_class        := UPPER(RTRIM(p_item_rec.purch_class));
    x_ic_item_mst_row.tax_class          := UPPER(RTRIM(p_item_rec.tax_class));
    x_ic_item_mst_row.customs_class      := UPPER(RTRIM(p_item_rec.customs_class));
    x_ic_item_mst_row.alloc_class        := UPPER(RTRIM(p_item_rec.alloc_class));
    x_ic_item_mst_row.planning_class     := UPPER(RTRIM(p_item_rec.planning_class));
    x_ic_item_mst_row.itemcost_class     := UPPER(RTRIM(p_item_rec.itemcost_class));
    x_ic_item_mst_row.cost_mthd_code     := UPPER(RTRIM(p_item_rec.cost_mthd_code));
    -- x_ic_item_mst_row.item_abccode       := UPPER(p_item_rec.item_abccode);
    x_ic_item_mst_row.qchold_res_code    := UPPER(RTRIM(p_item_rec.qchold_res_code));
    x_ic_item_mst_row.seq_dpnd_class     := UPPER(RTRIM(p_item_rec.seq_dpnd_class));
    x_ic_item_mst_row.inv_type           := UPPER(RTRIM(p_item_rec.inv_type));
    --END BUG#2461984
  ELSE
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_CLASS');
    FND_MSG_PUB.Add;
  END IF;

  /*=================================================
    Joe DiIorio 10/23/2001 BUG#1989860 11.5.1H
    Removed intrastat check and always set commodity
    code to null.
    ================================================*/
  x_ic_item_mst_row.commodity_code := NULL;


 /*=====================================================
   Joe DiIorio 01/02/2001 BUG#2106212
   Changed this line to get input upccode..
   ====================================================*/
  -- BUG#2461984 VAK
  x_ic_item_mst_row.upc_code           := UPPER(RTRIM(p_item_rec.upc_code));

  /*  Unused columns, although some of these are not null on the databse */
  x_ic_item_mst_row.bulk_id            := NULL;
  x_ic_item_mst_row.pkg_id             := NULL;
  x_ic_item_mst_row.fill_qty           := 0;
  x_ic_item_mst_row.fill_um            := NULL;
  x_ic_item_mst_row.phantom_type       := 0;


  /*  warehouse item and QC reference item */

  IF NVL(p_item_rec.whse_item_no,p_item_rec.item_no) = p_item_rec.item_no
  THEN
    x_ic_item_mst_row.whse_item_id:= NULL;
  ELSE
    -- BUG#2461984 VAK
    GMIGUTL.get_item(UPPER(RTRIM(p_item_rec.whse_item_no)), l_ic_item_mst_row, l_ic_item_cpg_row);
    IF l_ic_item_mst_row.item_id IS NOT NULL
    THEN
      x_ic_item_mst_row.whse_item_id := l_ic_item_mst_row.item_id;
    ELSE
      FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_WHSE_ITEM_NO');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',p_item_rec.item_no);
      FND_MSG_PUB.Add;
    END IF;
  END IF;


  IF NVL(p_item_rec.qcitem_no,' ') = ' '
  THEN
    x_ic_item_mst_row.qcitem_id:= NULL;
  ELSE
    -- BUG#2461984 VAK
    GMIGUTL.get_item(UPPER(RTRIM(p_item_rec.qcitem_no)),l_ic_item_mst_row, l_ic_item_cpg_row);
    IF l_ic_item_mst_row.item_id IS NOT NULL
    THEN
      x_ic_item_mst_row.qcitem_id := l_ic_item_mst_row.item_id;
    ELSE
      FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_QCITEM_NO');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',p_item_rec.qcitem_no);
      FND_MSG_PUB.Add;
    END IF;
  END IF;

  /*  Exported date */
  x_ic_item_mst_row.exported_date      := GMA_GLOBAL_GRP.SY$MIN_DATE;

  /*  Audit columns */
  x_ic_item_mst_row.creation_date      := SYSDATE;
  x_ic_item_mst_row.last_update_date   := SYSDATE;
  x_ic_item_mst_row.created_by         := GMIGUTL.DEFAULT_USER_ID;
  x_ic_item_mst_row.last_updated_by    := GMIGUTL.DEFAULT_USER_ID;
  x_ic_item_mst_row.last_update_login  := GMIGUTL.DEFAULT_LOGIN;
  x_ic_item_mst_row.delete_mark        := 0;
  x_ic_item_mst_row.trans_cnt          := 1;

  /* Bug 2506207 */
  /* Removed UPPER function on all attribute columns */
  /*  Setup attributes 'as is' */
  --BEGIN BUG#2461984 VAK
  x_ic_item_mst_row.attribute1         := RTRIM(p_item_rec.attribute1);
  x_ic_item_mst_row.attribute2         := RTRIM(p_item_rec.attribute2);
  x_ic_item_mst_row.attribute3         := RTRIM(p_item_rec.attribute3);
  x_ic_item_mst_row.attribute4         := RTRIM(p_item_rec.attribute4);
  x_ic_item_mst_row.attribute5         := RTRIM(p_item_rec.attribute5);
  x_ic_item_mst_row.attribute6         := RTRIM(p_item_rec.attribute6);
  x_ic_item_mst_row.attribute7         := RTRIM(p_item_rec.attribute7);
  x_ic_item_mst_row.attribute8         := RTRIM(p_item_rec.attribute8);
  x_ic_item_mst_row.attribute9         := RTRIM(p_item_rec.attribute9);
  x_ic_item_mst_row.attribute10        := RTRIM(p_item_rec.attribute10);
  x_ic_item_mst_row.attribute11        := RTRIM(p_item_rec.attribute11);
  x_ic_item_mst_row.attribute12        := RTRIM(p_item_rec.attribute12);
  x_ic_item_mst_row.attribute13        := RTRIM(p_item_rec.attribute13);
  x_ic_item_mst_row.attribute14        := RTRIM(p_item_rec.attribute14);
  x_ic_item_mst_row.attribute15        := RTRIM(p_item_rec.attribute15);
  x_ic_item_mst_row.attribute16        := RTRIM(p_item_rec.attribute16);
  x_ic_item_mst_row.attribute17        := RTRIM(p_item_rec.attribute17);
  x_ic_item_mst_row.attribute18        := RTRIM(p_item_rec.attribute18);
  x_ic_item_mst_row.attribute19        := RTRIM(p_item_rec.attribute19);
  x_ic_item_mst_row.attribute20        := RTRIM(p_item_rec.attribute20);
  x_ic_item_mst_row.attribute21        := RTRIM(p_item_rec.attribute21);
  x_ic_item_mst_row.attribute22        := RTRIM(p_item_rec.attribute22);
  x_ic_item_mst_row.attribute23        := RTRIM(p_item_rec.attribute23);
  x_ic_item_mst_row.attribute24        := RTRIM(p_item_rec.attribute24);
  x_ic_item_mst_row.attribute25        := RTRIM(p_item_rec.attribute25);
  x_ic_item_mst_row.attribute26        := RTRIM(p_item_rec.attribute26);
  x_ic_item_mst_row.attribute27        := RTRIM(p_item_rec.attribute27);
  x_ic_item_mst_row.attribute28        := RTRIM(p_item_rec.attribute28);
  x_ic_item_mst_row.attribute29        := RTRIM(p_item_rec.attribute29);
  x_ic_item_mst_row.attribute30        := RTRIM(p_item_rec.attribute30);
  x_ic_item_mst_row.attribute_category := RTRIM(p_item_rec.attribute_category);
  --END BUG#2461984
--  21/Feb/2002 P Lowe           Bug 2233859 - Field ont_pricing_qty_source


  IF p_item_rec.ont_pricing_qty_source BETWEEN 0 AND 1
  THEN
        x_ic_item_mst_row.ont_pricing_qty_source := NVL(p_item_rec.ont_pricing_qty_source,0);
  ELSE
    FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_ONT_SOURCE');
    FND_MESSAGE.SET_TOKEN('ITEM_NO',p_item_rec.item_no);
    FND_MSG_PUB.Add;
  END IF;

  IF (p_item_rec.ont_pricing_qty_source > 0
  and x_ic_item_mst_row.dualum_ind < 1 )
  or (p_item_rec.ont_pricing_qty_source > 0
  and UPPER(NVL(FND_PROFILE.VALUE('GML_OM_INTEGRATION'),'N')) = 'N' )

  THEN
       FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_ONT_SOURCE');
       FND_MESSAGE.SET_TOKEN('ITEM_NO',p_item_rec.item_no);
       FND_MSG_PUB.Add;
  END IF;

  x_ic_item_mst_row.ont_pricing_qty_source := NVL(p_item_rec.ont_pricing_qty_source,0);

  /* Jalaj Srivastava Bug 3158806
     Replace check for CPG_INSTALL with lot control */
  IF p_item_rec.lot_ctl = 1
  THEN
    /*  Validate/setup CPG fields */
    x_ic_item_cpg_row.item_id            := NULL;
    x_ic_item_cpg_row.ic_matr_days       := NVL(p_item_rec.ic_matr_days,0);
    IF x_ic_item_cpg_row.ic_matr_days < 0
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_MATR_DAYS');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',p_item_rec.item_no);
      FND_MSG_PUB.Add;
    END IF;

    x_ic_item_cpg_row.ic_hold_days       := p_item_rec.ic_hold_days;
    /* Jalaj Srivastava Bug 3158806
     Removed nvl above so that hold days in cpg table go as null if user did not sepcify
     hold days.
     Populate dummy column level code in ic_item_mst with hold days. */
    x_ic_item_mst_row.level_code         := x_ic_item_cpg_row.ic_hold_days;

    IF x_ic_item_cpg_row.ic_matr_days < 0
    THEN
      FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_HOLD_DAYS');
      FND_MESSAGE.SET_TOKEN('ITEM_NO',p_item_rec.item_no);
      FND_MSG_PUB.Add;
    END IF;
  END IF;
  /*  See how we got on: */

  FND_MSG_PUB.Count_AND_GET (  p_count =>  x_msg_count
                               , p_data  =>  x_msg_data
                              );
  IF x_msg_count > 0
  THEN
    /*  dbms_output.put_line(x_msg_data); */
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  /* Jalaj Srivastava Bug 3158806
     Replace check for CPG_INSTALL with lot control */
  IF p_item_rec.lot_ctl = 1
  THEN
    x_ic_item_cpg_row.creation_date      := SYSDATE;
    x_ic_item_cpg_row.last_update_date   := SYSDATE;
    x_ic_item_cpg_row.created_by         := GMIGUTL.DEFAULT_USER_ID;
    x_ic_item_cpg_row.last_updated_by    := GMIGUTL.DEFAULT_USER_ID;
    x_ic_item_cpg_row.last_update_login  := GMIGUTL.DEFAULT_LOGIN;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_AND_GET (  p_count =>  x_msg_count
                               , p_data  =>  x_msg_data
                              );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_AND_GET (  p_count =>  x_msg_count
                               , p_data  =>  x_msg_data
                              );
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
/*        IF   FND_MSG_PUB.check_msg_level                    */
/*            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)     */
/*        THEN           */

    FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME
                             , l_api_name
                            );

/*       END IF;     */
    FND_MSG_PUB.Count_AND_GET (  p_count =>  x_msg_count
                               , p_data  =>  x_msg_data
                              );

END Validate_Item;
END GMIVITM;

/
