--------------------------------------------------------
--  DDL for Package Body GMI_AUTOLOT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_AUTOLOT" AS
/* $Header: gmialotb.pls 115.3 2003/08/14 13:00:57 jdiiorio noship $ */
/*============================
    BUG#3097442 New function
  ===========================*/
FUNCTION insert_sublot_gen(p_i_item_id               IN   NUMBER,
                          p_i_lot_no                 IN   VARCHAR2,
                          p_i_sublot_suffix          IN   NUMBER)
   RETURN NUMBER IS
PRAGMA AUTONOMOUS_TRANSACTION;

l_userid                  FND_USER.USER_ID%TYPE;


BEGIN
   l_userid :=FND_GLOBAL.USER_ID;
   INSERT INTO GMI_SUBLOT_GENERATE
           (item_id, lot_no, next_sublot_suffix,
           creation_date, created_by,
           last_update_date, last_updated_by)
         VALUES (p_i_item_id, p_i_lot_no, p_i_sublot_suffix,
                  SYSDATE, l_userid, SYSDATE, l_userid);
   COMMIT;
   RETURN SQLCODE;

END insert_sublot_gen;

/*============================
    BUG#3097442 New function
  ===========================*/
FUNCTION update_sublot_gen(p_next_sublot           IN   NUMBER,
                           p_item_id               IN   NUMBER,
                           p_i_lot_no              IN   VARCHAR2)
   RETURN NUMBER IS
PRAGMA AUTONOMOUS_TRANSACTION;



BEGIN
   UPDATE GMI_SUBLOT_GENERATE
      set next_sublot_suffix = p_next_sublot
          where item_id = p_item_id AND
          lot_no = p_i_lot_no;
   COMMIT;
   RETURN 0;


END update_sublot_gen;


/*============================
    BUG#3097442 New function
  ===========================*/
FUNCTION update_item_suffix(p_item_id              IN   NUMBER,
                            p_suffix               IN   NUMBER)
   RETURN NUMBER IS
PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
   UPDATE IC_ITEM_MST_B
      set lot_suffix = p_suffix
      where item_id = p_item_id;
   COMMIT;
   RETURN 0;


END update_item_suffix;

FUNCTION check_if_lot_exists(p_f_item_id                IN   NUMBER,
                             p_f_lot_no                 IN   VARCHAR2,
                             p_f_sublot_no              IN   VARCHAR2)
   RETURN NUMBER IS

  CURSOR GET_LOT_MASTER IS
    SELECT lot_id
    FROM ic_lots_mst
    WHERE item_id = p_f_item_id AND
          lot_no = p_f_lot_no AND
          sublot_no = p_f_sublot_no;

  CURSOR GET_LOT_MASTER2 IS
    SELECT lot_id
    FROM ic_lots_mst
    WHERE item_id = p_f_item_id AND
          lot_no = p_f_lot_no;

w_lot_id        number := 0;

BEGIN
   IF (p_f_sublot_no IS NULL) THEN
      OPEN GET_LOT_MASTER2;
      FETCH GET_LOT_MASTER2 INTO w_lot_id;
      IF GET_LOT_MASTER2%NOTFOUND THEN
         CLOSE GET_LOT_MASTER2;
         RETURN 0;
      ELSE
         CLOSE GET_LOT_MASTER2;
         RETURN 1;
      END IF;
   ELSE
      OPEN GET_LOT_MASTER;
      FETCH GET_LOT_MASTER INTO w_lot_id;
      IF GET_LOT_MASTER%NOTFOUND THEN
         CLOSE GET_LOT_MASTER;
         RETURN 0;
      ELSE
         CLOSE GET_LOT_MASTER;
         RETURN 1;
      END IF;
   END IF;


END check_if_lot_exists;

/* ***************************************************************************
 FUNCTION NAME
	generate_lot_number

 INPUT PARAMETERS
  p_item_id        - Item id for which a lot is to be generated.
  p_in_lot_no      - Lot no for which a sublot is to be generated.
  p_orgn_code      - Optional for use in user routine.
  p_doc_id         - Optional for use in user routine.
  p_line_id        - Optional for use in user routine.
  p_doc_type       - Optional for use in user routine.

 RETURNS
  p_out_lot_no     - generated lot number.
  p_sublot_no      - generated sublot number.
  p_return_status  - return code.

 DESCRIPTION
    This procedure attempts to generate a lot or sublot for an item.
    If a user routine is requested, it will be invoked instead of
    the OPM lot generation logic.
    The procedure will validate the input and pad the generated lot
    if required.  It will also verify that the generated lot does
    not exist.

 AUTHOR
    Joe DiIorio - 03/01/2003

 HISTORY
    Joe DiIorio - 08/14/2003  - BUG#3097442 - 11.5.10L
                                Removed autonomous pragma.
**********************************************************************/

PROCEDURE generate_lot_number(p_item_id                    IN   NUMBER,
                             p_in_lot_no                   IN   VARCHAR2,
                             p_orgn_code                   IN   VARCHAR2,
                             p_doc_id                      IN   NUMBER,
                             p_line_id                     IN   NUMBER,
                             p_doc_type                    IN   VARCHAR2,
                             p_out_lot_no                  OUT  NOCOPY VARCHAR2,
                             p_sublot_no                   OUT  NOCOPY VARCHAR2,
                             p_return_status               OUT  NOCOPY NUMBER)



IS

  w_lot_ctl                 ic_item_mst_b.lot_ctl%TYPE;
  w_sublot_ctl              ic_item_mst_b.sublot_ctl%TYPE;
  w_lot_cnt                 NUMBER;
  w_next_lot                NUMBER;
  w_next_sublot             NUMBER;
  x_found                   NUMBER;
  w_lotpref_length          NUMBER;
  w_lotsuff_length          NUMBER;
  w_sub_pref_length         NUMBER;
  w_sub_suff_length         NUMBER;
  db_autolot_active         ic_item_mst_b.autolot_active_indicator%TYPE;
  db_lot_prefix             ic_item_mst_b.lot_prefix%TYPE;
  db_lot_suffix             ic_item_mst_b.lot_suffix%TYPE;
  w_pad_lot_suffix          VARCHAR2(32);
  db_sublot_prefix          ic_item_mst_b.sublot_prefix%TYPE;
  db_sublot_suffix          ic_item_mst_b.sublot_suffix%TYPE;
  w_pad_sublot_suffix       VARCHAR2(32);
  db_next_sublot_suffix     gmi_sublot_generate.next_sublot_suffix%TYPE;

  profile_user_routine      NUMBER := 0;
  prof_lot_pad              NUMBER;
  prof_lot_max              NUMBER;
  prof_sublot_pad           NUMBER;
  prof_sublot_max           NUMBER;
  X_msg                     VARCHAR2(100);
  w_userid                  FND_USER.USER_ID%TYPE;
  w_err_code                NUMBER;
/*========================================
   BUG#3097442 - new return code holders
  ======================================*/

  l_retcode                 NUMBER;
  l_updcode                 NUMBER;
  l_itmcode                 NUMBER;

/*=============================
   User Routine Variables
  =============================*/
  p_u_out_lot_no            ic_lots_mst.lot_no%TYPE;
  p_u_sublot_no             ic_lots_mst.sublot_no%TYPE;
  p_u_return_status         NUMBER;

/*=============================
       Exceptions
  =============================*/
  e_noitem_id               EXCEPTION;
  e_item_not_found          EXCEPTION;
  e_nolot_ctl               EXCEPTION;
  e_invalid_sublot          EXCEPTION;
  e_lot_length_error        EXCEPTION;
  e_sublot_length_error     EXCEPTION;
  e_user_prof_error         EXCEPTION;
  e_prof_lot_max            EXCEPTION;
  e_prof_sublot_max         EXCEPTION;
  e_sublot_insert           EXCEPTION;

  CURSOR GET_ITEM_INFO IS
    SELECT lot_ctl, sublot_ctl,
       autolot_active_indicator, lot_prefix,
       lot_suffix, sublot_prefix, sublot_suffix
    FROM ic_item_mst_b
    WHERE item_id = p_item_id;

  CURSOR GET_SUBLOT_INFO IS
    SELECT next_sublot_suffix
    FROM gmi_sublot_generate
    WHERE item_id = p_item_id AND
          lot_no = p_in_lot_no;



BEGIN
  p_return_status := 0;
  p_out_lot_no := NULL;
  p_sublot_no := NULL;

  /*=========================================
    If item not passed it is an error.
    =========================================*/

  IF (p_item_id IS NULL) THEN
    RAISE e_noitem_id;
  END IF;

  /*=========================================
    Retrieve Item Information.
    =========================================*/

  OPEN GET_ITEM_INFO;
  FETCH GET_ITEM_INFO INTO w_lot_ctl, w_sublot_ctl,
       db_autolot_active, db_lot_prefix,
       db_lot_suffix, db_sublot_prefix, db_sublot_suffix;
  IF GET_ITEM_INFO%NOTFOUND THEN
     CLOSE GET_ITEM_INFO;
     RAISE e_item_not_found;
  END IF;
  CLOSE GET_ITEM_INFO;

  /*=========================================
    Check if Autolot Rules Exist.
    =========================================*/

  IF (db_autolot_active = 0 OR db_autolot_active IS NULL) THEN
     /*===================================================
       Commented out message so it stays off stack.
     FND_MESSAGE.SET_NAME ('GMI','GMI_AUTOLOT_NO_SETUP');
       ===================================================*/
     p_return_status := 5;
     RETURN;
  END IF;


  /*=========================================
    Check for Lot Controlled Item.
    =========================================*/

  IF (w_lot_ctl < 1) THEN
    RAISE e_nolot_ctl;
  END IF;

  /*=========================================
    Check for Invalid Sublot Request.
    =========================================*/

  IF (p_in_lot_no IS NOT NULL and w_sublot_ctl = 0) THEN
    RAISE e_invalid_sublot;
  END IF;

  /*=========================================
    Check for User Routine
    =========================================*/


    IF FND_PROFILE.DEFINED('GMI_USER_LOT_AUTO_ROUTINE') THEN
        profile_user_routine := NVL(FND_PROFILE.VALUE('GMI_USER_LOT_AUTO_ROUTINE'),0);
    ELSE
        profile_user_routine := 0;
    END IF;

   IF (profile_user_routine = 1) THEN
      gmi_user_autolot.user_lot_number(p_item_id,
                        p_in_lot_no,
                        p_orgn_code,
                        p_doc_id,
                        p_line_id,
                        p_doc_type,
                        p_u_out_lot_no,
                        p_u_sublot_no,
                        p_u_return_status);
         IF (p_u_return_status = 0) THEN
             p_out_lot_no := p_u_out_lot_no;
             p_sublot_no := p_u_sublot_no;
             p_return_status := 5;
             RETURN;
         ELSE
             IF (p_u_return_status < 0) THEN -- fatal
                 p_return_status := -99;
                 ROLLBACK;
                 RETURN;
             ELSE                             -- nonfatal
                 p_out_lot_no := p_u_out_lot_no;
                 p_sublot_no := p_u_sublot_no;
                 p_return_status := 12;
                 RETURN;
             END IF;
         END IF;
   END IF;

  /*=========================================
    Retrieve Profile Padding Rules
    =========================================*/

    IF FND_PROFILE.DEFINED('GMI_LOT_PAD_INDICATOR') THEN
        prof_lot_pad := NVL(FND_PROFILE.VALUE('GMI_LOT_PAD_INDICATOR'),0);
        IF (prof_lot_pad = '1') THEN
           IF FND_PROFILE.DEFINED('GMI_MAX_LOT_LENGTH') THEN
              prof_lot_max := FND_PROFILE.VALUE('GMI_MAX_LOT_LENGTH');
           ELSE
              RAISE e_prof_lot_max;
           END IF;
        ELSE
           prof_lot_max := 32;
        END IF;
    ELSE
        prof_lot_pad := 0;
        prof_lot_max := 32;
    END IF;


    IF FND_PROFILE.DEFINED('GMI_SUBLOT_PAD_INDICATOR') THEN
        prof_sublot_pad := NVL(FND_PROFILE.VALUE('GMI_SUBLOT_PAD_INDICATOR'),0);
        IF (prof_sublot_pad = 1) THEN
           IF FND_PROFILE.DEFINED('GMI_MAX_SUBLOT_LENGTH') THEN
             prof_sublot_max := FND_PROFILE.VALUE('GMI_MAX_SUBLOT_LENGTH');
           ELSE
              RAISE e_prof_sublot_max;
           END IF;
        ELSE
           prof_sublot_max := 32;
        END IF;
    ELSE
        prof_sublot_pad := 0;
        prof_sublot_max := 32;
    END IF;


  /*=========================================
       Generate Lot Numbers
    =======================================*/

  IF (p_in_lot_no IS NOT NULL) THEN   -- generate the sublot
      OPEN GET_SUBLOT_INFO;
      FETCH GET_SUBLOT_INFO INTO w_next_sublot;
      IF GET_SUBLOT_INFO%NOTFOUND THEN
         CLOSE GET_SUBLOT_INFO;
         /*========================================
            BUG#3097442 - Replace inline code
            with code to autonomous function.
           ======================================*/
         l_retcode := insert_sublot_gen(p_item_id,
                          p_in_lot_no,
                          db_sublot_suffix);

         IF (l_retcode <> 0) THEN
           RAISE e_sublot_insert;
         END IF;
         w_next_sublot := db_sublot_suffix;
      ELSE
         CLOSE GET_SUBLOT_INFO;
      END IF;
      p_out_lot_no := p_in_lot_no;
      x_found := 1;    -- 1 means ic_lots_mst exists
      WHILE (x_found = 1)
           LOOP
              w_sub_pref_length := nvl(LENGTHB(db_sublot_prefix),0);
              w_sub_suff_length := LENGTHB(w_next_sublot);
              IF ((w_sub_pref_length + w_sub_suff_length) <= prof_sublot_max) THEN
                  IF (prof_sublot_pad = 1) THEN
                    w_pad_sublot_suffix := LPAD(w_next_sublot,(prof_sublot_max - w_sub_pref_length),'0');
                    p_sublot_no := db_sublot_prefix||w_pad_sublot_suffix;
                  ELSE
                    p_sublot_no := db_sublot_prefix||w_next_sublot;
                  END IF;
                  x_found := check_if_lot_exists(p_item_id, p_out_lot_no, p_sublot_no);
                  w_next_sublot := w_next_sublot + 1;
                  IF (x_found = 0) THEN
                     EXIT;
                  END IF;
              ELSE   -- field will be truncated
                  RAISE e_sublot_length_error;
              END IF;
           END LOOP;
           /*========================================
              BUG#3097442 - Replace inline code
              with code to autonomous function.
             ======================================*/
         l_updcode := update_sublot_gen(w_next_sublot, p_item_id, p_in_lot_no);
  ELSE   -- input lot number is null
      w_next_lot := db_lot_suffix;
      x_found := 1;
      WHILE (x_found = 1)
           LOOP
              w_lotpref_length := nvl(LENGTHB(db_lot_prefix),0);
              w_lotsuff_length := LENGTHB(w_next_lot);
              IF ((w_lotpref_length + w_lotsuff_length) <= prof_lot_max) THEN
                  IF (prof_lot_pad = 1) THEN
                    w_pad_lot_suffix := LPAD(w_next_lot,(prof_lot_max - w_lotpref_length),'0');
                    p_out_lot_no := db_lot_prefix||w_pad_lot_suffix;
                  ELSE
                    p_out_lot_no := db_lot_prefix||w_next_lot;
                  END IF;
                  x_found := check_if_lot_exists(p_item_id, p_out_lot_no, NULL);
                  w_next_lot := w_next_lot + 1;
                  IF (x_found = 0) THEN
                      EXIT;
                  END IF;
              ELSE   -- field will be truncated
                  RAISE e_lot_length_error;
              END IF;
           END LOOP;
           /*========================================
              BUG#3097442 - Replace inline code
              with code to autonomous function.
             ======================================*/
	l_itmcode := update_item_suffix(p_item_id, w_next_lot);

  END IF;

    /*========================================
       BUG#3097442 - Removed commit from here.
      ======================================*/

EXCEPTION
  WHEN e_noitem_id THEN
    FND_MESSAGE.SET_NAME ('GMI','GMI_AUTOLOT_NO_ITEM_ID');
    p_return_status := -80;
    RETURN;
  WHEN e_item_not_found THEN
    FND_MESSAGE.SET_NAME ('GMI','GMI_AUTOLOT_ITEM_NOTFOUND');
    FND_MESSAGE.SET_TOKEN ('BADITEM',to_char(p_item_id));
    p_return_status := -82;
    RETURN;
  WHEN e_nolot_ctl THEN
    FND_MESSAGE.SET_NAME ('GMI','GMI_AUTOLOT_NOLOT_CTL_ITEM');
    p_return_status := -84;
    RETURN;
  WHEN e_invalid_sublot THEN
    FND_MESSAGE.SET_NAME ('GMI','GMI_AUTOLOT_INVALID_SUBLOT_REQ');
    p_return_status := -86;
    RETURN;
  WHEN e_prof_lot_max THEN
    FND_MESSAGE.SET_NAME('GMI','GMI_AUTOLOT_LOT_MAX_ERROR');
    p_return_status := -88;
    RETURN;
  WHEN e_prof_sublot_max THEN
    FND_MESSAGE.SET_NAME('GMI','GMI_AUTOLOT_SUBLOT_MAX_ERROR');
    p_return_status := -90;
    RETURN;
  WHEN e_lot_length_error THEN
    FND_MESSAGE.SET_NAME ('GMI','GMI_AUTOLOT_LOT_LENGTH_ERROR');
    p_return_status := -120;
    ROLLBACK;
    RETURN;
  WHEN e_sublot_length_error THEN
    FND_MESSAGE.SET_NAME ('GMI','GMI_AUTOLOT_SUBLOT_LENGTH_ERR');
    p_return_status := -122;
    ROLLBACK;
    RETURN;
  WHEN e_sublot_insert THEN
    FND_MESSAGE.SET_NAME ('GMI','GMI_AUTOLOT_INSERT_SUBLOT_ERR');
    p_return_status := -126;
    ROLLBACK;
    RETURN;
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME ('GMI','GMI_AUTOLOT_UNHANDLED');
    w_err_code := SQLCODE;
    FND_MESSAGE.SET_TOKEN ('BADCODE',to_char(w_err_code));
    p_return_status := -136;
    ROLLBACK;
    RAISE;

END generate_lot_number;

/****************************************************************************
 FUNCTION NAME
  check_for_autolot

 INPUT PARAMETERS
  p_item_id        - Item id for which a lot is to be generated.

 RETURNS
  Number indicating if the item is autolot controlled or not.
  1 = Item has autolot activated, 0 = not activated.
  Returns a negative number if an error was detected.

 DESCRIPTION
  This function determines whether automatic lot numbering is
  active for a given item.

 AUTHOR
  Joe DiIorio - 03/01/2003

 HISTORY
**********************************************************************/

FUNCTION check_for_autolot(p_item_id                IN   NUMBER)
   RETURN NUMBER IS

CURSOR GET_AUTOLOT_INFO IS
    SELECT autolot_active_indicator
    FROM ic_item_mst_b
    WHERE item_id = p_item_id;

w_autolot                NUMBER;

e_noitem_passed           EXCEPTION;
e_item_not_found          EXCEPTION;

BEGIN

  /*=========================================
    If item not passed it is an error.
    =========================================*/

  IF (p_item_id IS NULL) THEN
    RAISE e_noitem_passed;
  END IF;

  /*=========================================
    Retrieve Autolot Information.
    =========================================*/

  OPEN GET_AUTOLOT_INFO;
  FETCH GET_AUTOLOT_INFO INTO w_autolot;
  IF GET_AUTOLOT_INFO%NOTFOUND THEN
     CLOSE GET_AUTOLOT_INFO;
     RAISE e_item_not_found;
  ELSE
     CLOSE GET_AUTOLOT_INFO;
     RETURN w_autolot;
  END IF;

EXCEPTION
  WHEN e_noitem_passed THEN
    FND_MESSAGE.SET_NAME ('GMI','GMI_AUTOLOT_NO_ITEM_ID');
    RETURN -80;
  WHEN e_item_not_found THEN
    FND_MESSAGE.SET_NAME ('GMI','GMI_AUTOLOT_ITEM_NOTFOUND');
    RETURN -82;


END check_for_autolot;
END;



/
