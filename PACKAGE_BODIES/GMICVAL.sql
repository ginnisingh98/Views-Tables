--------------------------------------------------------
--  DDL for Package Body GMICVAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMICVAL" AS
/* $Header: gmicvalb.pls 115.6 2004/04/30 17:40:42 adeshmuk ship $ */
  /* =============================================
  PROCEDURE:
  trans_date_val

  DESCRIPTION:
  This PL/SQL function is responsible for
  validating that a transaction date is in
  an open warehouse and inventory calendar period.

  SYNOPSIS:
  iret := GMICVAL.trans_date_val(ptrans_date,
  porgn_code, pwhse_code);

  ptrans_date - transaction date
  porgn_code  - organization associated to the warehouse.
  pwhse_code  - warehouse affected by the transaction.

  RETURNS:
  0 Success
  ============================================= */
  PROCEDURE trans_date_val(ptrans_date DATE,
                           porgn_code  VARCHAR2,
                           pwhse_code  VARCHAR2) IS

    /* Local variable initialization and
    declarations.
    =================================*/
    l_iret   NUMBER       := -1;

    BEGIN

      l_iret := GMICCAL.trans_date_validate(ptrans_date,
                  porgn_code, pwhse_code);

      IF (l_iret = -21) THEN
        FND_MESSAGE.set_name('GMI', 'INVCAL_FISCALYR_ERR');
        APP_EXCEPTION.raise_exception;

      ELSIF (l_iret = -22) THEN
        FND_MESSAGE.set_name('GMI', 'INVCAL_PERIOD_ERR');
        APP_EXCEPTION.raise_exception;

      ELSIF (l_iret = -23) THEN
        FND_MESSAGE.set_name('GMI', 'INVCAL_CLOSED_PERIOD_ERR');
        APP_EXCEPTION.raise_exception;

      ELSIF (l_iret = -24) THEN
        FND_MESSAGE.set_name('GMI', 'INVCAL_INVALIDCO_ERR');
        APP_EXCEPTION.raise_exception;

      ELSIF (l_iret = -25) THEN
        FND_MESSAGE.set_name('GMI', 'INVCAL_WHSE_CLOSED_ERR');
        APP_EXCEPTION.raise_exception;

      ELSIF (l_iret = -26) THEN
        FND_MESSAGE.set_name('GMI', 'INVCAL_TRANS_DATE_ERR');
        APP_EXCEPTION.raise_exception;

      ELSIF (l_iret = -27) THEN
        FND_MESSAGE.set_name('GMI', 'INVCAL_INVALIDORGN_ERR');
        APP_EXCEPTION.raise_exception;

      ELSIF (l_iret = -28) THEN
        FND_MESSAGE.set_name('GMI', 'INVCAL_WHSEPARM_ERR');
        APP_EXCEPTION.raise_exception;

      ELSIF (l_iret = -29) THEN
        FND_MESSAGE.set_name('GMI', 'INVCAL_WHSE_ERR');
        APP_EXCEPTION.raise_exception;

      ELSIF (l_iret < -29) THEN
        FND_MESSAGE.set_name('GMI', 'INVCAL_GENL_ERR');
        APP_EXCEPTION.raise_exception;

      END IF;

    END trans_date_val;
  /* =============================================
      PROCEDURE:
        deviation_val

      DESCRIPTION:
        This PL/SQL procedure is responsible for
        calling the unit of measure deviation function
        contained in this package and handling all
        error messaging centrally.

      SYNOPSIS:
        GMICVAL.deviation_val(pitem_id, plot_id, pcur_qty,
                        pcur_uom, pnew_qty, pnew_uom);

      ============================================= */
  PROCEDURE deviation_val(pitem_id     NUMBER,
                          plot_id      NUMBER,
                          pcur_qty     NUMBER,
                          pcur_uom     VARCHAR2,
                          pnew_qty     NUMBER,
                          pnew_uom     VARCHAR2) IS

    /* Local variable initialization and
    declarations.
    =================================*/
    l_iret     NUMBER       := -1;
    l_atomic   NUMBER       :=  0;
    l_neg_flag NUMBER       :=  0;
    l_cur_qty  NUMBER       :=  0;
    l_new_qty  NUMBER       :=  0;

    BEGIN

      /* Now let's check for dualum types 2 and 3 deviation
      if appropriate.
      ==================================================*/
      IF(pcur_qty < 0) THEN
        l_cur_qty := (pcur_qty * -1);
      ELSE
        l_cur_qty := pcur_qty;
      END IF;

      l_new_qty := pnew_qty;

      l_iret := GMICVAL.dev_validation(pitem_id, plot_id, l_cur_qty,
                  pcur_uom, l_new_qty, pnew_uom, l_atomic);

      IF(l_iret = -68) THEN
        FND_MESSAGE.set_name('GMI', 'IC_DEVIATION_HI_ERR');
        APP_EXCEPTION.raise_exception;

      ELSIF (l_iret = -69) THEN
        FND_MESSAGE.set_name('GMI', 'IC_DEVIATION_LO_ERR');
        APP_EXCEPTION.raise_exception;
      END IF;

    END deviation_val;
  /* =============================================
      PROCEDURE:
        itm_loct_validation

      DESCRIPTION:
        This PL/SQL function is responsible for
        validating that a location is properly
        validated.  Please refer to the below grid.

       XXXXX | whse0 | whse1 | whse2
       ======= =====================
       item0 |   0   |  0    |  0        0 = NO control
       =============================     1 = Location Controlled
       item1 |   0   |  1    |  2        2 = Non-Validated
       =============================
       item2 |   0   |  2    |  2

      SYNOPSIS:
        iret := GMICVAL.location_validation(plocation,
                  pwhse_code,ploct_ctl);

        plocation   - location to be validated
        pwhse_code  - warehouse where the location resides.
        ploct_ctl   - the items loction control indicator
                      as found in ic_item_mst.

      RETURNS:
          0 Success
        -62 Location is not valid.
        -65 Warehouse is not valid.
        -76 Cannot retrieve warehouse controls.
        -77 System default LOCATION not found.
        -78 Using default location ERROR.
        -82 The item is not location controlled.
      ============================================= */
  PROCEDURE itm_loct_validation(plocation   VARCHAR2,
                                pwhse_code  VARCHAR2,
                                ploct_ctl   NUMBER) IS

    /* Local variable initialization and
    declarations.
    =================================*/
    l_iret  NUMBER := -1;

    BEGIN

        l_iret := GMICVAL.itm_location_val(plocation,
                    pwhse_code, ploct_ctl);

        IF (l_iret = -62) THEN
          FND_MESSAGE.set_name('GMI', 'IC_LOCATION_ERR');
          FND_MESSAGE.set_token('ERRNO', TO_CHAR(l_iret));
          APP_EXCEPTION.raise_exception;
        ELSIF (l_iret = -65) THEN
          FND_MESSAGE.set_name('GMI', 'IC_WHSE_ERR');
          FND_MESSAGE.set_token('ERRNO', TO_CHAR(l_iret));
          APP_EXCEPTION.raise_exception;
        ELSIF (l_iret = -76) THEN
          FND_MESSAGE.set_name('GMI', 'IC_WHSE_CNTLS_ERR');
          FND_MESSAGE.set_token('ERRNO', TO_CHAR(l_iret));
          APP_EXCEPTION.raise_exception;
        ELSIF (l_iret = -77) THEN
          FND_MESSAGE.set_name('GMI', 'IC_DEFAULT_LOCT_ERR');
          FND_MESSAGE.set_token('ERRNO', TO_CHAR(l_iret));
          APP_EXCEPTION.raise_exception;
        ELSIF (l_iret = -78) THEN
          FND_MESSAGE.set_name('GMI', 'IC_USING_DEFAULT_LOCT_ERR');
          FND_MESSAGE.set_token('ERRNO', TO_CHAR(l_iret));
          APP_EXCEPTION.raise_exception;
        ELSIF (l_iret = -82) THEN
          FND_MESSAGE.set_name('GMI', 'IC_NOT_LOCT_CTL_ERR');
          FND_MESSAGE.set_token('ERRNO', TO_CHAR(l_iret));
          APP_EXCEPTION.raise_exception;
        END IF;

    END itm_loct_validation;
  /* =============================================
      FUNCTION:
        item_val                OVER LOADED FUNCTION!

      DESCRIPTION:
        This PL/SQL function is responsible for
        validating items based on item_id passed.
        This is an over loaded function call.
        The second way to call this validation is
        by item_no. See below function.

      SYNOPSIS:
        iret := GMICVAL.item_val(pitem_id);

        pitem_id     the item surrogate of the item you
                     are validating.

      RETURNS:
          0 Success
        -75 Reason code not valid.
      ============================================= */
  FUNCTION item_val(pitem_id NUMBER)
    RETURN NUMBER IS

    /* Cursor Definitions
    ==================*/
    CURSOR validate_item IS
      SELECT item_no
      FROM   ic_item_mst
      WHERE  item_id = pitem_id
      AND    delete_mark = 0;

    /* Local variables.
    ================*/
    l_item_no ic_item_mst.item_no%TYPE;

    /* ================================================*/
    BEGIN


      /* ==================================

       Initialize Variables
      ==================== */
      l_item_no := NULL;


      OPEN validate_item;
      FETCH validate_item INTO
        l_item_no;

      IF(validate_item%NOTFOUND) THEN

        CLOSE validate_item;
        RETURN VAL_ITEM_ERR;

      END IF;
      CLOSE validate_item;
      RETURN 0;


      EXCEPTION
        WHEN OTHERS THEN

          RETURN SQLCODE;
    END item_val;
  /* =============================================
      FUNCTION:
        item_val                OVER LOADED FUNCTION!

      DESCRIPTION:
        This PL/SQL function is responsible for
        validating items based on item_id passed.
        This is an over loaded function call.
        The second way to call this validation is
        by item_id. See above function.

      SYNOPSIS:
        iret := GMICVAL.item_val(pitem_no);

        pitem_no     the item number of the item you
                     are validating.

      RETURNS:
          0 Success
        -75 Reason code not valid.
      ============================================= */
  FUNCTION item_val(pitem_no VARCHAR2)
    RETURN NUMBER IS

    /* Cursor Definitions
    ==================*/
    CURSOR validate_item IS
      SELECT item_id
      FROM   ic_item_mst
      WHERE  item_no = UPPER(pitem_no)
      AND    delete_mark = 0;

    /* Local variables.
    ================*/
    l_item_id item_surg_type;

    /* ================================================ */
    BEGIN


      /* ==================================

      Initialize Variables
      ====================*/
      l_item_id := 0;


      OPEN validate_item;
      FETCH validate_item INTO
        l_item_id;

      IF(validate_item%NOTFOUND) THEN

        CLOSE validate_item;
        RETURN VAL_ITEM_ERR;

      END IF;
      CLOSE validate_item;
      RETURN 0;


      EXCEPTION
        WHEN OTHERS THEN

          RETURN SQLCODE;
    END item_val;
  /* =============================================
      FUNCTION:
        reason_code_val

      DESCRIPTION:
        This PL/SQL function is responsible for
        validating valid reason codes.

      SYNOPSIS:
        iret := GMICVAL.reason_code_val(preason_code);

        preason_code     the reason code you are working on.

      RETURNS:
          0 Success
        -61 Reason code not valid.
      ============================================= */
  FUNCTION reason_code_val(preason_code VARCHAR2)
    RETURN NUMBER IS

    /* Cursor Definitions
    ================== */
    CURSOR validate_reason IS
      SELECT reason_desc1
      FROM   sy_reas_cds
      WHERE  reason_code = UPPER(preason_code)
      AND    delete_mark = 0;

    /* Local variables.
    ================*/
    -- Shikha Nagar B2464367 made variable to VARCHAR2(80) from reason_type
    l_reason_desc1 VARCHAR2(40);

    BEGIN


      /* Initialize Variables
      ==================== */
      l_reason_desc1 := NULL;


      OPEN validate_reason;
      FETCH validate_reason INTO
        l_reason_desc1;

      IF(validate_reason%NOTFOUND) THEN

        CLOSE validate_reason;
        RETURN VAL_REASONCODE_ERR;

      END IF;
      CLOSE validate_reason;
      RETURN 0;


      EXCEPTION
        WHEN OTHERS THEN

          RETURN SQLCODE;
    END reason_code_val;
  /* =============================================
      FUNCTION:
        itm_location_val

      DESCRIPTION:
        This PL/SQL function is responsible for
        validating an items inventory location.

      SYNOPSIS:
        iret := GMICVAL.itm_location_val(plocation, pwhse_code,
                  ploct_ctl);

        plocation  the location you are working on.
        pwhse_code the warehouse associated with the location.
        ploct_ctl  The location control of the item.

      RETURNS:
        -62 Location is not valid.
        -65 Warehouse is not valid.
        -76 Cannot retrieve warehouse controls.
        -77 System default LOCATION not found.
        -78 Using default location ERROR.
        -82 The item is not location controlled.
          0 Success
      ============================================= */
  FUNCTION itm_location_val(plocation  VARCHAR2,
                            pwhse_code VARCHAR2,
                            ploct_ctl  NUMBER)
    RETURN NUMBER IS

    /* Local Variable declaration:
    ===========================*/
    --l_loct_desc   ic_loct_mst.loct_desc%TYPE; -- Bug 3585309
    l_location      ic_loct_mst.location%TYPE;  -- Bug 3585309
    l_default_loct  ic_loct_mst.location%TYPE;
    l_whse_loct_ctl ic_whse_mst.loct_ctl%TYPE;
    l_whse          ic_whse_mst.whse_code%TYPE;

    /* Cursor Definitions
    ==================*/
    CURSOR validate_whse IS
      SELECT whse_code
      FROM   ic_whse_mst
      WHERE  whse_code = UPPER(pwhse_code)
      AND    delete_mark = 0;

    CURSOR validate_location IS
      SELECT location
      FROM   ic_loct_mst
      WHERE  location = UPPER(plocation)
      AND    whse_code = UPPER(pwhse_code)
      AND    delete_mark = 0;

    CURSOR get_whse_ctl IS
      SELECT loct_ctl
      FROM   ic_whse_mst
      WHERE  whse_code = UPPER(pwhse_code);

    BEGIN


      /* ==================================
      Initialize local Variables
      ==================================*/
      --l_loct_desc   := NULL; -- Bug 3585309
      l_location      := NULL;
      l_default_loct  := NULL;
      l_whse          := NULL;
      l_whse_loct_ctl := 0;

      /* Is the item location controlled?
      If not this is an error.
      =============================================*/
      IF(ploct_ctl = 0) THEN
        RETURN VAL_NOTLOCATION_CTL_ERR;
      END IF;

      /* ========================================
      OK .. First determine if the warehouse
      code passed is valid.
      ========================================== */
      OPEN validate_whse;
      FETCH validate_whse INTO
        l_whse;
      IF(validate_whse%NOTFOUND) THEN

        CLOSE validate_whse;
        RETURN VAL_WHSE_ERR;

      END IF;
      CLOSE validate_whse;

      /* ========================================
      OK .. Second determine the type of location
      control we have for the warehouse.
      ========================================== */
      OPEN get_whse_ctl;
      FETCH get_whse_ctl INTO
        l_whse_loct_ctl;
      IF(get_whse_ctl%NOTFOUND) THEN

        CLOSE get_whse_ctl;
        RETURN VAL_CONTROLS_ERR;

      END IF;
      CLOSE get_whse_ctl;

      /* OK .. first let's get the system default
      location BUSINESS RULE. NO LOCATION BEING
      VALIDATED MAY HAVE THE SAME LOCATION AS
      THE SYSTEM DEFAULT LOCATION.
      ========================================== */
      l_default_loct := FND_PROFILE.value('IC$DEFAULT_LOCT');

      IF(l_default_loct IS NULL) THEN

        RETURN VAL_DEFAULT_LOCT_ERR;
      END IF;

      IF((ploct_ctl = 1 AND l_whse_loct_ctl = 2) OR
         (l_whse_loct_ctl > 1)) THEN
        /* ========================================
        NON Validated Location
        Let it go.
        ========================================*/

        IF(plocation = l_default_loct) THEN
          RETURN VAL_USING_DEFAULT_ERR;
        END IF;
        RETURN 0;
      END IF;

      /* If the location passed is the same
      as the default location, do not bother
      validating cause this is an error!
      ====================================== */
      IF(plocation = l_default_loct) THEN

        RETURN VAL_USING_DEFAULT_ERR;
      END IF;

      /* Validate please!
      ================ */
      OPEN validate_location;
      FETCH validate_location INTO
        l_location;

      IF(validate_location%NOTFOUND) THEN

        CLOSE validate_location;
        RETURN VAL_LOCATION_ERR;

      END IF;
      CLOSE validate_location;

      -- Bug 3585309
      -- Commented the following as desc is a nullable field.
      --IF(l_loct_desc IS NULL) THEN
      -- RETURN VAL_LOCATION_ERR;
      --END IF;

      RETURN 0;


      EXCEPTION
        WHEN OTHERS THEN

          RETURN SQLCODE;
    END itm_location_val;
  /* =============================================
      FUNCTION:
        whse_location_val

      DESCRIPTION:
        This PL/SQL function is responsible for
        validating an location in a particular warehouse.

      SYNOPSIS:
        iret := GMICVAL.whse_location_val(porgn_code, pwhse_code,
                  plocation);

        porgn_code the organization associated to the whse.
        pwhse_code the warehouse associated with the location.
        plocation  The location in the warehouse.

      RETURNS:
          0 Success
        -62 Location is not valid.
        -65 Warehouse is not valid.
        -77 System default LOCATION not found.
        -78 Using default location ERROR.
      ============================================= */
  FUNCTION whse_location_val(porgn_code   VARCHAR2,
                             pwhse_code   VARCHAR2,
                             plocation    VARCHAR2)
    RETURN NUMBER IS

    /* Local Variable declaration:
    =========================== */
    --l_loct_desc     ic_loct_mst.loct_desc%TYPE; -- Bug 3585309
    l_location      ic_loct_mst.location%TYPE;    -- Bug 3585309
    l_default_loct  ic_loct_mst.location%TYPE;
    l_whse_loct_ctl ic_whse_mst.loct_ctl%TYPE;
    l_whse          ic_whse_mst.whse_code%TYPE;

    /* Cursor Definitions
    ================== */
    CURSOR validate_whse IS
      SELECT whse_code
      FROM   ic_whse_mst
      WHERE  whse_code = UPPER(pwhse_code)
      AND    orgn_code = UPPER(porgn_code)
      AND    delete_mark = 0;

    CURSOR validate_location IS
      SELECT location
      FROM   ic_loct_mst
      WHERE  location = UPPER(plocation)
      AND    whse_code = UPPER(pwhse_code)
      AND    delete_mark = 0;

    BEGIN


      /* ==================================
      Initialize local Variables
      ================================== */
      --l_loct_desc   := NULL; -- Bug 3585309
      l_location      := NULL;
      l_default_loct  := NULL;
      l_whse          := NULL;
      l_whse_loct_ctl := 0;

      /* ========================================
      OK .. First determine if the warehouse
      code passed is valid.
      ========================================== */
      OPEN validate_whse;
      FETCH validate_whse INTO
        l_whse;
      IF(validate_whse%NOTFOUND) THEN

        CLOSE validate_whse;
        RETURN VAL_WHSE_ERR;

      END IF;
      CLOSE validate_whse;

      /* OK .. first let's get the system default
      location BUSINESS RULE. NO LOCATION BEING
      VALIDATED MAY HAVE THE SAME LOCATION AS
      THE SYSTEM DEFAULT LOCATION.
      ========================================== */
      l_default_loct := FND_PROFILE.value('IC$DEFAULT_LOCT');

      IF(l_default_loct IS NULL) THEN

        RETURN VAL_DEFAULT_LOCT_ERR;
      END IF;

      IF(plocation = l_default_loct) THEN

        RETURN VAL_USING_DEFAULT_ERR;
      END IF;

      OPEN validate_location;
      FETCH validate_location INTO
        l_location;

      IF(validate_location%NOTFOUND) THEN

        CLOSE validate_location;
        RETURN VAL_LOCATION_ERR;

      END IF;
      CLOSE validate_location;

      -- Bug 3585309
      -- Commented the following as desc is a nullable field.
      --IF(l_loct_desc IS NULL) THEN
      -- RETURN VAL_LOCATION_ERR;
      --END IF;

      RETURN 0;


      EXCEPTION
        WHEN OTHERS THEN

          RETURN SQLCODE;
    END whse_location_val;
  /* =============================================
      FUNCTION:
        grade_val

      DESCRIPTION:
        This PL/SQL function is responsible for
        validating an item's QC grade.

      SYNOPSIS:
        iret := GMICVAL.grade_val(pqc_grade);

        pqc_grade     the QC grade of an item.

      RETURNS:
        -63 QC Grade is not valid.
          0 Success
      ============================================= */
  FUNCTION grade_val(pqc_grade  VARCHAR2)
    RETURN NUMBER IS

    /* Cursor Definitions
    ================== */
    CURSOR validate_grade IS
      SELECT qc_grade_desc
      FROM   qc_grad_mst
      WHERE  qc_grade = UPPER(pqc_grade)
      AND    delete_mark = 0;

    /* Local Variable Declaration:
    =========================== */
    l_qc_grade_desc  qc_grad_mst.qc_grade_desc%TYPE;


    BEGIN


      /* Initialize Local Variables
       ========================== */

      l_qc_grade_desc := NULL;


      OPEN validate_grade;
      FETCH validate_grade INTO
        l_qc_grade_desc;

      IF(validate_grade%NOTFOUND) THEN

        CLOSE validate_grade;
        RETURN VAL_GRADE_ERR;

      END IF;
      CLOSE validate_grade;
      RETURN 0;


      EXCEPTION
        WHEN OTHERS THEN

          RETURN SQLCODE;
    END grade_val;
   /* =============================================
      FUNCTION:
        lot_status_val

      DESCRIPTION:
        This PL/SQL function is responsible for
        validating the lot status of a lot controlled
        and lot status controlled item.

      SYNOPSIS:
        iret := GMICVAL.lot_status_val(plot_status);

        pclot_status  the Lot Status of the item.

      RETURNS:
        -64 Lot Status is not valid.
          0 Success
      ============================================= */
  FUNCTION lot_status_val(plot_status  VARCHAR2)
    RETURN NUMBER IS

    /* Cursor Definitions
    ================== */
    CURSOR validate_status IS
      SELECT status_desc
      FROM   ic_lots_sts
      WHERE  lot_status = UPPER(plot_status)
      AND    delete_mark = 0;

    /* Local Variable Declaration:
    =========================== */
    l_status_desc  ic_lots_sts.status_desc%TYPE;


    BEGIN


      /* ==================================
      Local Variable Initialization
      ============================= */
      l_status_desc := NULL;


      OPEN validate_status;
      FETCH validate_status INTO
        l_status_desc;

      IF(validate_status%NOTFOUND) THEN

        CLOSE validate_status;
        RETURN VAL_LOTSTATUS_ERR;

      END IF;
      CLOSE validate_status;
      RETURN 0;


      EXCEPTION
        WHEN OTHERS THEN

          RETURN SQLCODE;
    END lot_status_val;
  /* =============================================
      FUNCTION:
        whse_val

      DESCRIPTION:
        This PL/SQL function is responsible for
        validating valid warehouse codes.

      SYNOPSIS:
        iret := GMICVAL.whse_val(pwhse_code, porgn_code);

        pwhse_code     the warehouse code you are working on.
        porgn_code     The organization associated with the
                       warehouse being validated.

      RETURNS:
        -65 Reason code not valid.
          0 Success
      ============================================= */
  FUNCTION whse_val(pwhse_code VARCHAR2, porgn_code VARCHAR2)
    RETURN NUMBER IS

    /* Cursor Definitions
    ================== */
    CURSOR validate_whse IS
      SELECT whse_code
      FROM   ic_whse_mst
      WHERE  whse_code = UPPER(pwhse_code)
      AND    orgn_code = UPPER(porgn_code)
      AND    delete_mark = 0;

    /* Local variables.
    ================ */
    l_whse_code whse_type;

    BEGIN


      /* ==================================

      Initialize Variables
      ==================== */
      l_whse_code := NULL;


      OPEN validate_whse;
      FETCH validate_whse INTO
        l_whse_code;

      IF(validate_whse%NOTFOUND) THEN

        CLOSE validate_whse;
        RETURN VAL_WHSE_ERR;

      END IF;
      CLOSE validate_whse;

      IF(l_whse_code IS NULL) THEN
        RETURN VAL_WHSE_ERR;
      END IF;

      RETURN 0;


      EXCEPTION
        WHEN OTHERS THEN

          RETURN SQLCODE;
    END whse_val;
  /* =============================================
      FUNCTION:
        lot_validate

      DESCRIPTION:
        This PL/SQL function is responsible for
        validating valid lot surrogates, lot numbers,
        sulot numbers or combinations.

      SYNOPSIS:
        iret := GMICVAL.lot_validate(pitem_no, plot_no, psublot_no);

        pitem_no     the item number are working on.
        plot_no      the lot number you want to validate.
        psublot_no   the sublot number you want to validate.

      RETURNS:
        -66 Reason code not valid.
          0 Success
      ============================================= */
  FUNCTION lot_validate(pitem_no VARCHAR2, plot_no VARCHAR2,
                        psublot_no VARCHAR2)
    RETURN NUMBER IS

    /* Local variables.
    ================ */
    l_item_id    ic_item_mst.item_id%TYPE;
    l_lot_ctl    ic_item_mst.lot_ctl%TYPE;
    l_sublot_ctl ic_item_mst.sublot_ctl%TYPE;
    l_lot_id     ic_lots_mst.lot_id%TYPE;


    CURSOR get_item_attributes IS
      SELECT item_id, lot_ctl, sublot_ctl
      FROM   ic_item_mst
      WHERE  item_no = UPPER(pitem_no)
      AND    delete_mark = 0;

    CURSOR validate_lot IS
      SELECT lot_id
      FROM   ic_lots_mst
      where  item_id = l_item_id
      AND    lot_no  = UPPER(plot_no)
      AND    delete_mark = 0;

    CURSOR validate_sublot IS
      SELECT lot_id
      FROM   ic_lots_mst
      WHERE  item_id = l_item_id
      AND    lot_no  = UPPER(plot_no)
      AND    sublot_no = UPPER(psublot_no)
      AND    delete_mark = 0;


    BEGIN


      /* ==================================

      Initialize Variables
      ==================== */
      l_item_id := 0;
      l_lot_id  := 0;
      l_lot_ctl := 0;
      l_sublot_ctl := 0;


      OPEN get_item_attributes;
      FETCH get_item_attributes INTO
        l_item_id, l_lot_ctl, l_sublot_ctl;

      IF(get_item_attributes%NOTFOUND) THEN

        CLOSE get_item_attributes;
        RETURN VAL_ITEMATTR_ERR;

      END IF;
      CLOSE get_item_attributes;

      IF(l_lot_ctl = 0) THEN
        RETURN VAL_NOTLOT_CTL_ERR;
      END IF;

      IF(l_lot_ctl = 1 AND plot_no IS NULL) THEN
        RETURN VAL_LOT_PARM_ERR;
      END IF;

      IF(l_lot_ctl = 1 AND l_sublot_ctl = 0) THEN
        OPEN validate_lot;
        FETCH validate_lot INTO
        l_lot_id;

        IF(validate_lot%NOTFOUND) THEN

          CLOSE validate_lot;
          RETURN VAL_LOT_ERR;
        END IF;

      CLOSE validate_lot;
      RETURN 0;

      ELSIF(l_lot_ctl = 1 AND l_sublot_ctl = 1) THEN
        /* =========================================
        BUSINESS RULE:
        If a sublot controlled item is passed a
        NULL sublot, only validate the lot number
        ========================================= */
        IF(psublot_no IS NULL OR psublot_no = ' ') THEN
          OPEN validate_lot;
          FETCH validate_lot INTO
          l_lot_id;

          IF(validate_lot%NOTFOUND) THEN

            CLOSE validate_lot;
            RETURN VAL_LOT_ERR;
          END IF;

          CLOSE validate_lot;
          RETURN 0;
        ELSE
          /* =======================================
          Perform normal sublot validation.
          ======================================= */
          OPEN validate_sublot;
          FETCH validate_sublot INTO
          l_lot_id;

          IF(validate_sublot%NOTFOUND) THEN

            CLOSE validate_sublot;
            RETURN VAL_SUBLOT_ERR;
          END IF;

          CLOSE validate_sublot;
          RETURN 0;
        END IF;
      END IF;

      EXCEPTION
        WHEN OTHERS THEN

          RETURN SQLCODE;
    END lot_validate;
  /* =============================================
      FUNCTION:
        lot_validate

      DESCRIPTION:
        This PL/SQL function is responsible for
        validating valid lot surrogates, lot numbers,
        sulot numbers or combinations.

      SYNOPSIS:
        iret := GMICVAL.lot_validate(pitem_no, plot_no, psublot_no);

        pitem_no     the item number are working on.
        plot_no      the lot number you want to validate.
        psublot_no   the sublot number you want to validate.

      RETURNS:
        -66 Reason code not valid.
          0 Success
      ============================================= */
  FUNCTION lot_validate(pitem_id NUMBER,
                        plot_id  NUMBER)
    RETURN NUMBER IS

    /* Local variables.
    ================ */
    l_item_id    ic_item_mst.item_id%TYPE;
    l_lot_ctl    ic_item_mst.lot_ctl%TYPE;
    l_sublot_ctl ic_item_mst.sublot_ctl%TYPE;
    l_lot_id     ic_lots_mst.lot_id%TYPE;
    /* Cursor Definitions


    ================== */
    CURSOR get_item_attributes IS
      SELECT item_id, lot_ctl, sublot_ctl
      FROM   ic_item_mst
      WHERE  item_no = UPPER(pitem_id)
      AND    delete_mark = 0;

    CURSOR validate_lot IS
      SELECT lot_id
      FROM   ic_lots_mst
      where  item_id = pitem_id
      AND    lot_id  = plot_id
      AND    delete_mark = 0;

    BEGIN


      /* ==================================

      Initialize Variables
      ==================== */
      l_item_id := 0;
      l_lot_id  := 0;
      l_lot_ctl := 0;
      l_sublot_ctl := 0;


      OPEN get_item_attributes;
      FETCH get_item_attributes INTO
        l_item_id, l_lot_ctl, l_sublot_ctl;

      IF(get_item_attributes%NOTFOUND) THEN

        CLOSE get_item_attributes;
        RETURN VAL_ITEMATTR_ERR;

      END IF;
      CLOSE get_item_attributes;

      IF(l_lot_ctl = 0) THEN
        RETURN VAL_NOTLOT_CTL_ERR;
      END IF;


      IF(l_lot_ctl = 1) THEN
        OPEN validate_lot;
        FETCH validate_lot INTO
        l_lot_id;

        IF(validate_lot%NOTFOUND) THEN

          CLOSE validate_lot;
          RETURN VAL_LOT_ERR;
        END IF;
      END IF;
      CLOSE validate_lot;
      RETURN 0;

      EXCEPTION
        WHEN OTHERS THEN

          RETURN SQLCODE;
    END lot_validate;
  /* =============================================
      FUNCTION:
        co_code_val

      DESCRIPTION:
        This PL/SQL function is responsible for
        validating that an organization passed is
        a company.

      SYNOPSIS:
        iret := GMICVAL.co_code_val(porgn_code);

        porgn_code   the organization code you are working on.

      RETURNS:
       <-79 RDBMS Oracle Error.
        -79 The orgnization code passed is not valid.
         0 Success
      ============================================= */
  FUNCTION co_code_val(porgn_code VARCHAR2)
    RETURN NUMBER IS

    /* Cursor Definitions
    ================== */
    CURSOR validate_orgn IS
      SELECT orgn_name
      FROM   sy_orgn_mst
      WHERE  co_code   = UPPER(porgn_code)
      AND    orgn_code = UPPER(porgn_code)
      AND    delete_mark = 0;

    /* Local variables.
    ================ */
    l_orgn_name sy_orgn_mst.orgn_name%TYPE;

    BEGIN


      /* ==================================

      Initialize Variables
      ==================== */
      l_orgn_name := NULL;


      OPEN validate_orgn;
      FETCH validate_orgn INTO
        l_orgn_name;

      IF(validate_orgn%NOTFOUND) THEN

        CLOSE validate_orgn;
        RETURN VAL_CO_CODE_ERR;

      END IF;
      CLOSE validate_orgn;

      IF(l_orgn_name IS NULL) THEN
        RETURN VAL_CO_CODE_ERR;
      END IF;

      RETURN 0;


      EXCEPTION
        WHEN OTHERS THEN

          RETURN SQLCODE;
    END co_code_val;
  /* =============================================
      FUNCTION:
        orgn_code_val

      DESCRIPTION:
        This PL/SQL function is responsible for
        validating organizations.

      SYNOPSIS:
        iret := GMICVAL.orgn_code_val(porgn_code);

        porgn_code     the orgn_code you are working on.

      RETURNS:
       <-80 RDBMS Oracle Error.
        -80 The orgn_code passed is not valid.
         0 Success
      ============================================= */
  FUNCTION orgn_code_val(porgn_code VARCHAR2)
    RETURN NUMBER IS

    /* Cursor Definitions
    ================== */
    CURSOR validate_orgn IS
      SELECT orgn_name
      FROM   sy_orgn_mst
      WHERE  orgn_code  = UPPER(porgn_code)
      AND    delete_mark = 0;

    /* Local variables.
    ================ */
    l_orgn_name sy_orgn_mst.orgn_name%TYPE;

    BEGIN


      /* ==================================

      Initialize Variables
      ==================== */
      l_orgn_name := NULL;


      OPEN validate_orgn;
      FETCH validate_orgn INTO
        l_orgn_name;

      IF(validate_orgn%NOTFOUND) THEN

        CLOSE validate_orgn;
        RETURN VAL_ORGN_CODE_ERR;

      END IF;
      CLOSE validate_orgn;

      IF(l_orgn_name IS NULL) THEN
        RETURN VAL_ORGN_CODE_ERR;
      END IF;

      RETURN 0;


      EXCEPTION
        WHEN OTHERS THEN

          RETURN SQLCODE;
    END orgn_code_val;
  /* =============================================
      FUNCTION:
        uomcode_val

      DESCRIPTION:
        This PL/SQL function is responsible for
        validating a unit of measure code (ie. LBS).

      SYNOPSIS:
        iret := GMICVAL.uomcode_val(puom_code);

        puom_code the uom code you are working on.

      RETURNS:
       <-81 RDBMS Oracle Error.
        -81 The UOM CODE passed is not valid.
         0 Success
      ============================================= */
  FUNCTION uomcode_val(puom_code VARCHAR2)
    RETURN NUMBER IS

    /* Cursor Definitions
    ================== */
    CURSOR validate_uomcode IS
      SELECT um_desc
      FROM   sy_uoms_mst
      WHERE  um_code  = puom_code
      AND    delete_mark = 0;

    /* Local variables.
    ================ */
    l_um_desc sy_uoms_mst.um_desc%TYPE;

    BEGIN


      /* ==================================

      Initialize Variables
      ==================== */
      l_um_desc := NULL;


      OPEN validate_uomcode;
      FETCH validate_uomcode INTO
        l_um_desc;

      IF(validate_uomcode%NOTFOUND) THEN

        CLOSE validate_uomcode;
        RETURN VAL_UOMCODE_ERR;

      END IF;
      CLOSE validate_uomcode;

      IF(l_um_desc IS NULL) THEN
        RETURN VAL_UOMCODE_ERR;
      END IF;

      RETURN 0;


      EXCEPTION
        WHEN OTHERS THEN

          RETURN SQLCODE;
    END uomcode_val;
  /* =============================================
      FUNCTION:
        dev_validation

      DESCRIPTION:
        This PL/SQL function is responsible for
        dualum indicator type 2 and 3 ONLY!

        The purpose of the function is to validate
        that the secondary quantity is within the
        standard deviation high and low for an item
        as defined by the item in the ic_item_mst table.

      PARAMETERS:
        pitem_id     The surrogate key of the item number

        plot_id      The surrogate key for the lot number/
                     sublot of the item number being converted.

        ptrans_qty1  The quantity in the primary UOM for the
                     item.

        pprim_uom    The UOM of trans_qty1.

        ptrans_qty2  The quantity in the secondary UOM for the
                     item.
        psec_uom     The UOM of trans_qty2.

        patomic      Flag to signify if integer or full
                     conversion with percision should be performed.
                       0 - Full percision
                       1 - Integer conversion.

      SPECIAL NOTES:

      RETURNS:
        0 - SUCCESS
       -1 - Package problem.
       -2 - Lab Type not passed for LAB conversion.
       -3 - UM_TYPE and conversion factor for current UOM not found.
       -4 - UM_TYPE and conversion factor for NEW UOM not found.
       -5 - Cannot determine INVENTORY UOM for item.
       -6 - UM_TYPE and conversion factor for INV UOM not found.
       -7 - Cannot find conversion factor for CURRENT UOM.
       -8 - LAB CONVERSION - LM$DENSITY variable not found.
       -9 - LAB CONVERSION - conversion factor not found.
      -10 - Cannot find conversion factor for NEW UOM.
      -11 - Package/Security Issue to gmicitm Package.
      -12 - Package/Security Issue to gmicuom Package.
      -13 - Quantity is GREATER than allowed deviation.
      -14 - Quantity is LESS THAN allowed deviation.

      HISTORY:
      WJ Harris III 26-JUN-98 rel 4.01.06
      Changes to function dev_validation().
      Added parameters pprim_uom and psec_uom.
      Removed all references to OUT type parameters as
      well as rewriting functionality.
      ============================================= */
  FUNCTION dev_validation(pitem_id    NUMBER,
                          plot_id     NUMBER,
                          ptrans_qty1 NUMBER,
                          pprim_uom   VARCHAR2,
                          ptrans_qty2 NUMBER,
                          psec_uom    VARCHAR2,
                          patomic     NUMBER)
    RETURN NUMBER IS

    /* Variable Declarations
    ===================== */
    l_converted_qty   quantity_type;
    l_iret            NUMBER;
    BEGIN

    /* ===============================
    Initialize Variables
    =============================== */
    l_converted_qty  := 0;
    l_iret           := -1;


    /* ============================================
    OK .... first let's go out and grab the
    required attributes we need for the item.
    ============================================ */
    l_iret := GMICVAL.det_dualum_ind(pitem_id);

    IF(l_iret < -1) THEN
      RETURN l_iret;
    ELSIF(l_iret = -1) THEN
      RETURN VAL_PACKAGE_ERR;
    END IF;

    /* =================================================
    If the item is either NOT DUAL controlled or DUAL
    Controlled type one .... we have nothing to do!.
    ================================================= */
    IF(l_iret = 0 OR l_iret = 1) THEN
      RETURN 0;
    END IF;

    /* ==================================================
    Next .... let's perform  a unit of measure
    conversion to determine the base converted amount.
    ================================================== */
    l_iret := -1;
    l_iret := GMICUOM.uom_conversion(pitem_id, plot_id,
                ptrans_qty1, pprim_uom, psec_uom, patomic);

    IF(l_iret < -1) THEN
      RETURN l_iret;
    ELSIF(l_iret = -1) THEN
      RETURN VAL_PACKAGE_ERR;
    END IF;

    /* ======================================================
    If the passed in secondary quantity is greater than
    the deviation high boundary OR less than the deviation
    low boundary, we have an error!
    ====================================================== */
    l_converted_qty := l_iret;
    l_iret := -1;
    l_iret := GMICVAL.calc_deviation(pitem_id, ptrans_qty2,
                                     l_converted_qty);

    IF(l_iret = VAL_CALCDEV_HIGH_ERR) THEN
      RETURN l_iret;
    ELSIF(l_iret = VAL_CALCDEV_LO_ERR) THEN
      RETURN l_iret;
    ELSIF(l_iret = -1) THEN
      RETURN VAL_PACKAGE_ERR;
    END IF;

    RETURN 0;

    EXCEPTION
      WHEN OTHERS THEN

      RETURN SQLCODE;
    END dev_validation;
  /* =============================================
      FUNCTION:
        det_dualum_ind

      DESCRIPTION:
        This PL/SQL function is responsible for
        returning  the dual unit of measure indicator
        of an item.

      SYNOPSIS:
        iret := GMICVAL.det_dualum_ind(pitem_id);

        pitem_id     the item surrogate you are working on.
        iodualum_ind The dual UOM indicator of the item.
                     Valid values are:
                     o 0 - Denotes single UOM controlled.
                     o 1 - Denotes Dual UOM auto calculated.
                     o 2 - Denotes Dual UOM auto calculated.
                     o 3 - Denotes Dual UOM entry required.

        SPECIAL NOTE:
        DUALUM 2 is auto calculated by the system HOWEVER allows
        the user to modify the quantity which is then compared to a
        high/low deviation.  If the quantity entered by the
        user is outside these boundaries, this is an error.

        DUALUM 3 requires entry from the user.  NO CALCULATION IS
        DONE BY THE SYSTEM.  The quantity entered is then
        validated the same as DUALUM 2.

      RETURNS:
        -67 Whse code not passed.
         >0 Success
      ============================================= */
  FUNCTION det_dualum_ind(pitem_id    NUMBER)
    RETURN NUMBER IS

    /* Local variable definitions
    ========================== */
    l_dualum_ind dualum_type;

    /* Cursor Definitions
    ================== */
    CURSOR item_uom_attr IS
      SELECT dualum_ind
      FROM   ic_item_mst
      WHERE  item_id = pitem_id
      AND    delete_mark = 0;

    BEGIN


      OPEN item_uom_attr;
      FETCH item_uom_attr INTO
        l_dualum_ind;

      IF(item_uom_attr%NOTFOUND) THEN

        CLOSE item_uom_attr;
        RETURN VAL_DUALUM_ERR;

      END IF;
      CLOSE item_uom_attr;

      RETURN l_dualum_ind;


      EXCEPTION
        WHEN OTHERS THEN

          RETURN SQLCODE;
    END det_dualum_ind;
  /* =============================================
      FUNCTION:
        calc_deviation

      DESCRIPTION:
        This PL/SQL function is responsible for
        determining whether an entered quantity
        is within the allowable deviation + or -
        of an item.

      SYNOPSIS:
        iret := GMICVAL.calc_deviation(pitem_id, ptrans_qty2,
                                       pconverted_qty);

        pitem_id     the item surrogate you are working on.
        ptrans_qty2  the secondary quantity entered by the user.
        pconverted_qty the system calculated secondary quantity.

        SPECIAL NOTE:
        l_dev_hi     The returned high boundary for allowed
                     deviation percentage expressed as a decimal.
                     (ie 20% is represented as .20)
        l_dev_lo     The returned low boundary for allowed
                     deviation percentage expressed as a decimal.
                     (ie 20% is represented as .20)

        DUALUM 2 is auto calculated by the system HOWEVER allows
        the user to modify the quantity which is then compared to a
        high/low deviation.  If the quantity entered by the
        user is outside these boundaries, this is an error.

        DUALUM 3 requires entry from the user.  NO CALCULATION IS
        DONE BY THE SYSTEM.  The quantity entered is then
        validated the same as DUALUM 2.

      RETURNS:
        -1 Whse code not passed.
       > 0 Success
      ============================================= */
  FUNCTION calc_deviation(pitem_id       NUMBER,
                          ptrans_qty2    NUMBER,
                          pconverted_qty NUMBER)
    RETURN NUMBER IS

    /* Local variable definitions
    ========================== */
    l_deviation_hi      dev_type;
    l_deviation_lo      dev_type;
    l_hi_boundary NUMBER;
    l_lo_boundary NUMBER;
    ltrans_qty2   NUMBER;


    /* Cursor Definitions
    ================== */
    CURSOR item_uom_attr IS
      SELECT deviation_hi, deviation_lo
      FROM   ic_item_mst
      WHERE  item_id = pitem_id
      AND    delete_mark = 0;

    BEGIN

      /* Local Variable Initialization
      ============================= */
      l_deviation_hi      := 0.0;
      l_deviation_lo      := 0.0;
      l_hi_boundary := 0;
      l_lo_boundary := 0;



      OPEN item_uom_attr;
      FETCH item_uom_attr INTO
        l_deviation_hi, l_deviation_lo;

      IF(item_uom_attr%NOTFOUND) THEN

        CLOSE item_uom_attr;
        RETURN VAL_UOMATTR_ERR;

      END IF;
      CLOSE item_uom_attr;

      /* ========================
      Set temporary boundaries
      ======================== */
      l_hi_boundary    := (pconverted_qty * (1 + l_deviation_hi));
      l_lo_boundary    := (pconverted_qty * (1 - l_deviation_lo));


      /* ======================================================
      If the passed in secondary quantity is greater than
      the deviation high boundary OR less than the deviation
      low boundary, we have an error!
      ====================================================== */
      /* =====================================================
         Deviation check should restrict only to 9 precision
         as round till 9 is the apps standard
         ====================================================*/
      ltrans_qty2 :=  round(ptrans_qty2,9);
      IF(ltrans_qty2 > round(l_hi_boundary,9)) THEN
        RETURN VAL_CALCDEV_HIGH_ERR;
      ELSIF(ltrans_qty2 < round(l_lo_boundary,9)) THEN
        RETURN VAL_CALCDEV_LO_ERR;
      END IF;

      RETURN 0;

      EXCEPTION
        WHEN OTHERS THEN

        RETURN SQLCODE;
    END calc_deviation;
  END;

/
