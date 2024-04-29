--------------------------------------------------------
--  DDL for Package Body PN_VAR_ABATEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_VAR_ABATEMENTS_PKG" AS
/* $Header: PNVRABTB.pls 120.7 2007/07/02 15:21:29 lbala noship $ */

-------------------------------------------------------------------------------
-- PROCDURE : INSERT_ROW
-- INVOKED FROM : INSERT_row procedure
-- PURPOSE      : INSERTs the row
-- HISTORY      :
-- 14-JUL-05  HRodda o Bug 4284035 - REPLACEd PN_VAR_ABATEMENTS with _ALL
-- 28-NOV-05  pikhar o fetched org_id using cursor
-------------------------------------------------------------------------------
procedure INSERT_ROW (
                     X_ROWID             IN out NOCOPY VARCHAR2,
                     X_VAR_ABATEMENT_ID  IN out NOCOPY NUMBER,
                     X_VAR_RENT_ID       IN NUMBER,
                     X_VAR_RENT_INV_ID   IN NUMBER,
                     X_PAYMENT_TERM_ID   IN NUMBER,
                     X_INCLUDE_TERM      IN VARCHAR2,
                     X_INCLUDE_INCREASES IN VARCHAR2,
                     X_UPDATE_FLAG       IN VARCHAR2,
                     X_CREATION_DATE     IN DATE,
                     X_CREATED_BY        IN NUMBER,
                     X_LAST_UPDATE_DATE  IN DATE,
                     X_LAST_UPDATED_BY   IN NUMBER,
                     X_LAST_UPDATE_LOGIN IN NUMBER,
                     X_ORG_ID            IN NUMBER
                     ) IS

  CURSOR var_abatements IS
  SELECT ROWID
  FROM   PN_VAR_ABATEMENTS_ALL
  WHERE  VAR_ABATEMENT_ID = X_VAR_ABATEMENT_ID;

  CURSOR org_cur IS
  SELECT org_id
  FROM   pn_payment_terms_all
  WHERE  payment_term_id = x_payment_term_id;

  l_org_id NUMBER;


BEGIN

        PNP_DEBUG_PKG.debug ('PN_VAR_ABATEMENTS_PKG.INSERT_ROW (+)');

        -------------------------------------------------------
        -- SELECT the nextval fOR var abatement id
        -------------------------------------------------------

        IF x_org_id IS NULL THEN
          FOR rec IN org_cur LOOP
            l_org_id := rec.org_id;
          END LOOP;
        ELSE
          l_org_id := x_org_id;
        END IF;

        IF ( X_VAR_ABATEMENT_ID IS NULL) THEN
          SELECT  pn_var_abatements_s.nextval
          INTO    X_VAR_ABATEMENT_ID
          FROM    dual;
        END IF;

        INSERT INTO PN_VAR_ABATEMENTS_ALL
        (         VAR_RENT_ID,
                  VAR_ABATEMENT_ID,
                  VAR_RENT_INV_ID,
                  PAYMENT_TERM_ID,
                  INCLUDE_TERM,
                  INCLUDE_INCREASES,
                  UPDATE_FLAG,
                  LAST_UPDATE_DATE,
                  LAST_UPDATED_BY,
                  CREATION_DATE,
                  CREATED_BY,
                  LAST_UPDATE_LOGIN,
                  ORG_ID
        )
        VALUES
        (         X_VAR_RENT_ID,
                  X_VAR_ABATEMENT_ID,
                  X_VAR_RENT_INV_ID,
                  X_PAYMENT_TERM_ID,
                  X_INCLUDE_TERM,
                  X_INCLUDE_INCREASES,
                  X_UPDATE_FLAG,
                  X_LAST_UPDATE_DATE,
                  X_LAST_UPDATED_BY,
                  X_CREATION_DATE,
                  X_CREATED_BY,
                  X_LAST_UPDATE_LOGIN,
                  l_ORG_ID
        );

        OPEN var_abatements;
        FETCH var_abatements INTO X_ROWID;
        IF (var_abatements%notfound) THEN
          CLOSE var_abatements;
          RAISE no_data_found;
        END IF;
        CLOSE var_abatements;

        PNP_DEBUG_PKG.debug ('PN_VAR_ABATEMENTS_PKG.INSERT_ROW (-)');

END INSERT_ROW;

-------------------------------------------------------------------------------
-- PROCDURE     : lock_row
-- INVOKED FROM : lock_row procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 14-JUL-05  hareesha o Bug 4284035 - REPLACEd pn_dIStributions with _ALL table.
-------------------------------------------------------------------------------
procedure LOCK_ROW
        (X_VAR_RENT_ID         IN NUMBER,
         X_VAR_RENT_INV_ID     IN NUMBER,
         X_PAYMENT_TERM_ID     IN NUMBER
         ) IS

CURSOR c1 IS
SELECT *
FROM PN_VAR_ABATEMENTS_ALL
WHERE VAR_RENT_ID = X_VAR_RENT_ID AND
      VAR_RENT_INV_ID = X_VAR_RENT_INV_ID AND
      PAYMENT_TERM_ID = X_PAYMENT_TERM_ID
FOR UPDATE OF VAR_ABATEMENT_ID NOWAIT;

tlINfo c1%ROWTYPE;

BEGIN

        PNP_DEBUG_PKG.debug ('PN_VAR_ABATEMENTS_PKG.LOCK_ROW (+)');

        OPEN c1;
            FETCH c1 INTO tlINfo;
            IF (c1%NOTFOUND) THEN
                    CLOSE c1;
                    RETURN;
            END IF;
        CLOSE c1;
        IF (tlINfo.VAR_RENT_ID = X_VAR_RENT_ID) THEN
           NULL;
        ELSE
           PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('VAR_RENT_ID',tlINfo.VAR_RENT_ID);
        END IF;


        IF (tlINfo.VAR_RENT_INV_ID = X_VAR_RENT_INV_ID) THEN
           NULL;
        ELSE
           PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('VAR_RENT_INV_ID',tlINfo.VAR_RENT_INV_ID);
        END IF;

        IF (tlINfo.PAYMENT_TERM_ID = X_PAYMENT_TERM_ID) THEN
           NULL;
        ELSE
           PN_VAR_RENT_PKG.LOCK_ROW_EXCEPTION('PAYMENT_TERM_ID',tlINfo.PAYMENT_TERM_ID);
        END IF;

        PNP_DEBUG_PKG.debug ('PN_VAR_ABATEMENTS_PKG.LOCK_ROW (-)');

END LOCK_ROW;

-----------------------------------------------------------------------
-- PROCDURE : UPDATE_ROW
-----------------------------------------------------------------------
procedure UPDATE_ROW
        (
           X_VAR_RENT_ID       IN NUMBER,
           X_VAR_RENT_INV_ID   IN NUMBER,
           X_PAYMENT_TERM_ID   IN NUMBER,
           X_INCLUDE_TERM      IN VARCHAR2,
           X_INCLUDE_INCREASES IN VARCHAR2,
           X_UPDATE_FLAG       IN VARCHAR2,
           X_LAST_UPDATE_DATE  IN DATE,
           X_LAST_UPDATED_BY   IN NUMBER,
           X_LAST_UPDATE_LOGIN IN NUMBER
        ) IS

BEGIN

        PNP_DEBUG_PKG.debug ('PN_VAR_ABATEMENTS_PKG.UPDATE_ROW (+)');

        UPDATE PN_VAR_ABATEMENTS_ALL SET
               VAR_RENT_ID       = X_VAR_RENT_ID,
               VAR_RENT_INV_ID   = X_VAR_RENT_INV_ID,
               PAYMENT_TERM_ID   = X_PAYMENT_TERM_ID,
               INCLUDE_TERM      = X_INCLUDE_TERM,
               INCLUDE_INCREASES = X_INCLUDE_INCREASES,
               UPDATE_FLAG       = X_UPDATE_FLAG,
               LAST_UPDATE_DATE  = X_LAST_UPDATE_DATE,
               LAST_UPDATED_BY   = X_LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
        WHERE VAR_RENT_ID = X_VAR_RENT_ID
        AND   VAR_RENT_INV_ID = X_VAR_RENT_INV_ID
        AND PAYMENT_TERM_ID = X_PAYMENT_TERM_ID;

        IF (SQL%NOTFOUND) THEN
          RAISE NO_DATA_FOUND;
        END IF;

        PNP_DEBUG_PKG.debug ('PN_VAR_ABATEMENTS_PKG.UPDATE_ROW (-)');

END UPDATE_ROW;

-------------------------------------------------------------------------------
-- PROCDURE     : delete_row
-- INVOKED FROM : delete_row procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 14-JUL-05  hareesha o Bug 4284035 - REPLACEd pn_dIStributions with _ALL table.
-------------------------------------------------------------------------------

procedure DELETE_ROW
        ( X_VAR_RENT_ID       IN NUMBER,
          X_VAR_RENT_INV_ID   IN NUMBER,
          X_PAYMENT_TERM_ID   IN NUMBER
        ) IS

BEGIN

        PNP_DEBUG_PKG.debug ('PN_VAR_ABATEMENTS_PKG.DELETE_ROW (+)');

        DELETE FROM PN_VAR_ABATEMENTS_ALL
        WHERE VAR_RENT_ID = X_VAR_RENT_ID
        AND VAR_RENT_INV_ID = X_VAR_RENT_INV_ID
        AND PAYMENT_TERM_ID = X_PAYMENT_TERM_ID;

        IF (SQL%NOTFOUND) THEN
           RAISE NO_DATA_FOUND;
        END IF;


        PNP_DEBUG_PKG.debug ('PN_VAR_ABATEMENTS_PKG.DELETE_ROW (-)');

END DELETE_ROW;

--------------------------------------------------------------------
--
--  NAME         : CHECK_CALC_INV_EXISTS()
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM : KEY-COMMIT trigger at block level
--  ARGUMENTS    : NONE
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--   27-NOV-06  Lokesh Bala   o Created
--
--------------------------------------------------------------------

FUNCTION  CHECK_CALC_INV_EXISTS(p_var_rent_inv_id IN NUMBER,
                                p_var_rent_id IN NUMBER
                               )
RETURN VARCHAR2 IS
   -- Get the invoice date
CURSOR get_inv_date(p1_var_rent_inv_id IN NUMBER)
IS
SELECT invoice_date
  FROM pn_var_rent_inv_all
 WHERE var_rent_inv_id=p1_var_rent_inv_id;

  -- Get calculated invoices after this invoice
CURSOR calc_inv_exists(p1_inv_date IN DATE,p1_var_rent_id IN NUMBER)
IS
SELECT 'Y' calc_inv
FROM dual WHERE EXISTS
(SELECT *
  FROM pn_var_rent_inv_all
 WHERE var_rent_id=p1_var_rent_id
   AND invoice_date > p1_inv_date);

l_inv_date DATE := NULL;
l_dummy VARCHAR2(1) :=NULL;

BEGIN
PNP_DEBUG_PKG.debug ('PNXVRENT_ABATEMENTS_CPG.CHECK_CALC_INV_EXISTS :'||' (+)');

FOR get_inv_date_rec IN get_inv_date(p_var_rent_inv_id) LOOP
   l_inv_date := get_inv_date_rec.invoice_date;
END LOOP;
FOR calc_inv_exists_rec IN calc_inv_exists(l_inv_date,p_var_rent_id)LOOP
   l_dummy := calc_inv_exists_rec.calc_inv;
END LOOP;
RETURN l_dummy;
PNP_DEBUG_PKG.debug ('PNXVRENT_ABATEMENTS_CPG.CHECK_CALC_INV_EXISTS :'||' (-)');
END check_calc_inv_exists;

--------------------------------------------------------------------
--
--  NAME         : ABTMT_EXISTS()
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM : KEY-COMMIT trigger at block level
--  ARGUMENTS    : NONE
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--   27-NOV-06  Lokesh Bala   o Created
--
--------------------------------------------------------------------

FUNCTION abtmt_exists(p_var_rentId      IN NUMBER,
                      p_var_rent_inv_id IN NUMBER,
                      p_pmt_term_id     IN NUMBER
                     )
RETURN VARCHAR2 IS
-- Get the details of
CURSOR abtmt_exists_cur(p_var_rentId IN NUMBER,
                        p_var_rent_inv_id IN NUMBER,
                        p_pmt_term_id IN NUMBER)
IS
  SELECT 'y'
    FROM dual
   WHERE exists ( select null from pn_var_abatements_all
                  where var_rent_id=p_var_rentId AND
                  var_rent_inv_id=p_var_rent_inv_id AND
                  payment_term_id=p_pmt_term_id);

l_abtmt_exists VARCHAR2(1):=NULL;

BEGIN
PNP_DEBUG_PKG.debug ('PNXVRENT_ABATEMENTS_CPG.ABTMT_EXISTS :'||' (+)');

OPEN abtmt_exists_cur(p_var_rentId ,p_var_rent_inv_id ,p_pmt_term_id );
FETCH abtmt_exists_cur INTO l_abtmt_exists;
CLOSE abtmt_exists_cur;

RETURN l_abtmt_exists;

PNP_DEBUG_PKG.debug ('PNXVRENT_ABATEMENTS_CPG.ABTMT_EXISTS :'||' (-)');
END abtmt_exists;
--------------------------------------------------------------------
--
--  NAME         : RESET_UPDATE_FLAG()
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM : ON-COMMIT trigger at form level
--  ARGUMENTS    : NONE
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--   27-NOV-06  Lokesh Bala   o Created
--
--------------------------------------------------------------------

PROCEDURE RESET_UPDATE_FLAG(p_var_rentId IN NUMBER,
                            p_var_rent_inv_id IN NUMBER
                           )
IS
-- Get the details of
CURSOR get_update_cur(p_var_rentId IN NUMBER,p_var_rent_inv_id IN NUMBER) IS
  SELECT *
    FROM pn_var_abatements_all
   WHERE var_rent_id= p_var_rentId
     AND var_rent_inv_id = p_var_rent_inv_id
     AND update_flag = 'Y';
BEGIN
--
FOR get_update_rec IN get_update_cur(p_var_rentId,p_var_rent_inv_id) LOOP
  PN_VAR_ABATEMENTS_PKG.UPDATE_ROW (
  X_VAR_RENT_ID       =>  p_var_rentId  ,
  X_VAR_RENT_INV_ID   => p_var_rent_inv_id,
  X_PAYMENT_TERM_ID   => get_update_rec.PAYMENT_TERM_ID,
  X_INCLUDE_TERM      => get_update_rec.INCLUDE_TERM ,
  X_INCLUDE_INCREASES => get_update_rec.INCLUDE_INCREASES,
  X_UPDATE_FLAG       => NULL,
  X_LAST_UPDATE_DATE  => sysdate,
  X_LAST_UPDATED_BY   => NVL(fnd_profile.value('USER_ID'),-1),
  X_LAST_UPDATE_LOGIN => NVL(fnd_profile.value('USER_ID'),-1)
  );
END LOOP;

END RESET_UPDATE_FLAG;

--------------------------------------------------------------------
--
--  NAME         : ROLL_FWD_ON_UPD()
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM : ON-UPDATE trigger at block level,ON-COMMIT trigger
--                 at form level
--  ARGUMENTS    : NONE
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--   27-NOV-06  Lokesh Bala   o Created
--
--------------------------------------------------------------------

PROCEDURE ROLL_FWD_ON_UPD(p_var_rentId      IN NUMBER,
                          p_var_rent_inv_id IN NUMBER,
                          p_pmt_term_id     IN NUMBER,
                          flag              IN NUMBER
                          )
IS

l_inv_id            NUMBER :=NULL;
l_row_id            VARCHAR2(18):=NULL;
l_var_abmt_id       NUMBER :=NULL;
l_inv_dt            DATE :=NULL;
l_pmt_exists        VARCHAR2(2):=NULL;
l_abtmt_exists      VARCHAR2(2):=NULL;

-- Get invoice date
CURSOR get_inv_dt(p_var_rent_inv_id IN NUMBER) IS
  SELECT invoice_date
    FROM pn_var_rent_inv_all
   WHERE var_rent_inv_id=p_var_rent_inv_id;

/*Cursor to get all invoices*/
CURSOR get_all_inv(p_var_rent_id IN NUMBER,l_invoice_dt IN DATE) IS
  SELECT distinct gd1.invoice_date,decode(temp.inv_id,NULL,-1,temp.inv_id) v_inv_id
    FROM pn_var_grp_dates_all gd1,
    (SELECT gd.invoice_date inv_dt,vinv.var_rent_inv_id inv_id
     FROM pn_var_grp_dates_all gd , pn_var_rent_inv_all vinv
     WHERE vinv.var_rent_id=gd.var_rent_id
     AND vinv.invoice_date=gd.invoice_date
     AND vinv.period_id=gd.period_id
     AND gd.var_rent_id=p_var_rent_id
     AND vinv.adjust_num=0
     ) temp
    WHERE gd1.var_rent_id=p_var_rent_id
    AND gd1.invoice_date=temp.inv_dt(+)
    AND gd1.invoice_date>l_invoice_dt
    ORDER BY gd1.invoice_date;


/*Cursor to check if a pmt term exists for a particular invoice*/
CURSOR check_pmt_terms(p_inv_id IN NUMBER,p_term_id IN NUMBER) IS
  SELECT 'x' pterm_exists
  FROM dual WHERE EXISTS
  (SELECT  NULL
  FROM pn_payment_terms_all pterm,
     pn_var_rents_all vrent,
     pn_var_rent_inv_all vinv
  WHERE
    vrent.lease_id = pterm.lease_id
  AND vrent.var_rent_id = vinv.var_rent_id
  AND pterm.start_date <=
  (SELECT MAX(gd.grp_end_date)
   FROM pn_var_grp_dates_all gd
   WHERE gd.period_id = vinv.period_id
   AND gd.invoice_date = vinv.invoice_date
  )
  AND pterm.end_date >=
  (SELECT MIN(gd1.grp_start_date)
   FROM pn_var_grp_dates_all gd1
   WHERE gd1.period_id = vinv.period_id
   AND gd1.invoice_date = vinv.invoice_date
  )
  AND pterm.var_rent_inv_id IS NULL
  AND pterm.index_period_id IS NULL
  AND vinv.adjust_num = 0
  AND vinv.var_rent_inv_id=p_inv_id
  AND pterm.payment_term_id=p_term_id);

/*Cursor to check if an abtmt exists for a particular invoice*/
CURSOR check_abtmt_terms_inv(p_inv_id IN NUMBER,p_term_id IN NUMBER) IS
  SELECT 'x' abatement_exists
  FROM dual
  WHERE EXISTS (SELECT  payment_term_id
                FROM pn_var_abatements_all
                WHERE var_rent_inv_id=p_inv_id
                AND payment_term_id=p_term_id);

-- Get all abatement terms for an invoice with update_flag='Y'
CURSOR get_upd_terms(p_var_rentId IN NUMBER,p_var_rent_inv_id IN NUMBER) IS
  SELECT payment_term_id,include_term,include_increases
    FROM pn_var_abatements_all pva
   WHERE pva.var_rent_id= p_var_rentId
     AND pva.var_rent_inv_id = p_var_rent_inv_id
     AND update_flag = 'Y';

CURSOR org_cur(p_var_rentId IN NUMBER) IS
  SELECT org_id
  FROM   pn_var_rents_all
  WHERE  var_rent_id =p_var_rentId;

l_org_id NUMBER;

BEGIN

FOR rec IN org_cur(p_var_rentId) LOOP
  l_org_id := rec.org_id;
END LOOP;

--Get invoice date for the invoice id passed as parameter to this procedure
FOR get_inv_dt_rec IN get_inv_dt(p_var_rent_inv_id) LOOP
  l_inv_dt := get_inv_dt_rec.invoice_date;
END LOOP;

--Get all invoices with invoice_date > l_inv_dt
FOR get_inv_rec IN get_all_inv(p_var_rentId,l_inv_dt) LOOP
  l_inv_id := get_inv_rec.v_inv_id;

-- If gap exists between 2 invoices then stop roll forward
  IF ( l_inv_id=-1 ) THEN
    EXIT;
  END IF;

--Case 1 : p_pmt_term_id passed IS NULL , so roll fwd all abtmt terms with update_flag='y'
  IF p_pmt_term_id IS NULL  THEN

    FOR upd_rec IN get_upd_terms(p_var_rentId ,p_var_rent_inv_id) LOOP

       l_pmt_exists:=NULL;
       l_abtmt_exists:=NULL;

       FOR pmt_term_rec IN check_pmt_terms(l_inv_id,upd_rec.payment_term_id) LOOP
         l_pmt_exists := pmt_term_rec.pterm_exists;
       END LOOP;

       IF l_pmt_exists IS NOT NULL THEN

          FOR abtmt_rec IN check_abtmt_terms_inv(l_inv_id,upd_rec.payment_term_id) LOOP
            l_abtmt_exists := abtmt_rec.abatement_exists;
          END LOOP;

          IF  l_abtmt_exists IS NULL THEN
            l_row_id := NULL;
            l_var_abmt_id :=NULL;

            PN_VAR_ABATEMENTS_PKG.INSERT_ROW(
            X_ROWID             => l_row_id,
            X_VAR_ABATEMENT_ID  => l_var_abmt_id,
            X_VAR_RENT_ID       => p_var_rentId,
            X_VAR_RENT_INV_ID   => l_inv_id,
            X_PAYMENT_TERM_ID   => upd_rec.payment_term_id,
            X_INCLUDE_TERM      => upd_rec.include_term,
            X_INCLUDE_INCREASES => upd_rec.include_increases,
            X_UPDATE_FLAG       => NULL,
            X_CREATION_DATE     => sysdate,
            X_CREATED_BY        => NVL(fnd_profile.value('USER_ID'),-1),
            X_LAST_UPDATE_DATE  => sysdate,
            X_LAST_UPDATED_BY   => NVL(fnd_profile.value('USER_ID'),-1),
            X_LAST_UPDATE_LOGIN => NVL(fnd_profile.value('USER_ID'),-1),
            X_ORG_ID            => l_org_id  );

          ELSE
             PN_VAR_ABATEMENTS_PKG.UPDATE_ROW(
             X_VAR_RENT_ID       => p_var_rentId,
             X_VAR_RENT_INV_ID   => l_inv_id,
             X_PAYMENT_TERM_ID   => upd_rec.payment_term_id,
             X_INCLUDE_TERM      => upd_rec.include_term,
             X_INCLUDE_INCREASES => upd_rec.include_increases,
             X_UPDATE_FLAG       => NULL,
             X_LAST_UPDATE_DATE  => sysdate,
             X_LAST_UPDATED_BY   => NVL(fnd_profile.value('USER_ID'),-1),
             X_LAST_UPDATE_LOGIN => NVL(fnd_profile.value('USER_ID'),-1));
          END IF;
       END IF;
    END LOOP;

 --Case 2   : p_pmt_term_id IS NOT NULL and flag=0 , candidate for delete_row
  ELSIF flag=0  THEN

    l_pmt_exists:=NULL;
    l_abtmt_exists:=NULL;

    FOR pmt_term_rec IN check_pmt_terms(l_inv_id,p_pmt_term_id) LOOP
      l_pmt_exists := pmt_term_rec.pterm_exists;
    END LOOP;

    IF   l_pmt_exists IS NOT NULL THEN
      FOR abtmt_rec IN check_abtmt_terms_inv(l_inv_id,p_pmt_term_id) LOOP
         l_abtmt_exists := abtmt_rec.abatement_exists;
      END LOOP;

      IF  l_abtmt_exists IS NOT NULL THEN

         PN_VAR_ABATEMENTS_PKG.DELETE_ROW(
            X_VAR_RENT_ID       =>  p_var_rentId,
            X_VAR_RENT_INV_ID   =>  l_inv_id,
            X_PAYMENT_TERM_ID   =>  p_pmt_term_id);

      END IF;
    END IF;


  END IF;

END LOOP;

PNP_DEBUG_PKG.debug ('PNXVRENT_ABATEMENTS_CPG.ROLL_FWD_ON_UPD :'||' (-)');

END ROLL_FWD_ON_UPD;
--------------------------------------------------------------------
--
--  NAME         : get_include_term()
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM : form view of ABATEMENTS_BLK
--  ARGUMENTS    : NONE
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--   27-NOV-06  Lokesh Bala   o Created
--
--------------------------------------------------------------------

FUNCTION get_include_term(p_payment_term_id IN NUMBER,
                          p_var_rent_inv_id IN NUMBER,
                          p_var_rent_id IN NUMBER
                          )
RETURN VARCHAR2 IS
-- Get the details of
CURSOR incl_term_cur(p_payment_term_id IN NUMBER,p_var_rent_inv_id IN NUMBER,
                     p_var_rent_id IN NUMBER) IS
  SELECT include_term
    FROM pn_var_abatements_all
   WHERE var_rent_id=p_var_rent_id
     AND payment_term_id=p_payment_term_id
     AND var_rent_inv_id=p_var_rent_inv_id;

l_incl_term VARCHAR2(1):='N';

BEGIN
  OPEN incl_term_cur(p_payment_term_id,p_var_rent_inv_id,p_var_rent_id);
  FETCH incl_term_cur INTO l_incl_term;
    IF (incl_term_cur%notfound OR l_incl_term IS NULL) THEN
        l_incl_term := 'N';
    END IF;
  CLOSE incl_term_cur;

  RETURN l_incl_term;

EXCEPTION
WHEN no_data_found THEN
RETURN 'N';
END get_include_term;
--------------------------------------------------------------------
--
--  NAME         : get_include_increases()
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM : form view of ABATEMENTS_BLK
--  ARGUMENTS    : NONE
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--   27-NOV-06  Lokesh Bala   o Created
--
--------------------------------------------------------------------

FUNCTION get_include_increases(p_payment_term_id IN NUMBER,
                               p_var_rent_inv_id IN NUMBER,
                               p_var_rent_id IN NUMBER)
RETURN VARCHAR2 IS
-- Get the details of
CURSOR incl_increases_cur(p_payment_term_id IN NUMBER,p_var_rent_inv_id IN NUMBER,
                          p_var_rent_id IN NUMBER) IS
  SELECT include_increases
    FROM pn_var_abatements_all
   WHERE var_rent_id=p_var_rent_id
     AND payment_term_id=p_payment_term_id
     AND var_rent_inv_id=p_var_rent_inv_id;
l_incl_incr VARCHAR2(1):='N';

BEGIN
  OPEN incl_increases_cur(p_payment_term_id,p_var_rent_inv_id,p_var_rent_id);
  FETCH incl_increases_cur INTO l_incl_incr;
    IF (incl_increases_cur%notfound OR l_incl_incr IS NULL) THEN
        l_incl_incr := 'N';
    END IF;
  CLOSE incl_increases_cur;

  RETURN l_incl_incr;

EXCEPTION
WHEN no_data_found THEN
RETURN 'N';
END get_include_increases;
--------------------------------------------------------------------
--
--  NAME         : ROLL_FWD_FST_ON_UPD()
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM : ON-UPDATE trigger at block level,ON-COMMIT trigger
--                 at form level for 1st partial period
--  ARGUMENTS    : NONE
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--   27-NOV-06  Lokesh Bala   o Created
--
--------------------------------------------------------------------
PROCEDURE ROLL_FWD_FST_ON_UPD(p_var_rentId IN NUMBER,
                              p_var_rent_inv_id IN NUMBER,
                              p_pmt_term_id IN NUMBER,
                              flag IN NUMBER
                              )
IS
l_inv_id            NUMBER :=NULL;
l_row_id            ROWID  :=NULL;
l_var_abmt_id       NUMBER :=NULL;
l_inv_dt            DATE :=NULL;
l_pmt_exists        VARCHAR2(2):=NULL;
l_abtmt_exists      VARCHAR2(2):=NULL;

/*Cursor to get all invoices from 2nd annual period*/
CURSOR get_all_inv(p_var_rent_id IN NUMBER) IS
  SELECT distinct gd1.invoice_date,decode(temp.inv_id,NULL,-1,temp.inv_id) v_inv_id
    FROM pn_var_grp_dates_all gd1,
         pn_var_periods_all vp,
    (SELECT gd.invoice_date inv_dt,vinv.var_rent_inv_id inv_id
     FROM pn_var_grp_dates_all gd , pn_var_rent_inv_all vinv
     WHERE vinv.var_rent_id=gd.var_rent_id
     AND vinv.invoice_date=gd.invoice_date
     AND vinv.period_id=gd.period_id
     AND gd.var_rent_id=p_var_rent_id
     AND adjust_num=0
    ) temp
     WHERE gd1.var_rent_id=p_var_rent_id
     AND gd1.invoice_date=temp.inv_dt(+)
     AND gd1.period_id=vp.period_id
     AND vp.period_num >1
     --AND gd1.invoice_date>l_invoice_dt
     ORDER BY gd1.invoice_date;

/*Cursor to check if a pmt term exists for a particular invoice*/
CURSOR check_pmt_terms(p_inv_id IN NUMBER,p_term_id IN NUMBER) IS
  SELECT 'x' pterm_exists
  FROM dual WHERE EXISTS
  (SELECT  NULL
  FROM pn_payment_terms_all pterm,
     pn_var_rents_all vrent,
     pn_var_rent_inv_all vinv
  WHERE
    vrent.lease_id = pterm.lease_id
  AND vrent.var_rent_id = vinv.var_rent_id
  AND pterm.start_date <=
  (SELECT MAX(gd.grp_end_date)
   FROM pn_var_grp_dates_all gd
   WHERE gd.period_id = vinv.period_id
   AND gd.invoice_date = vinv.invoice_date
  )
  AND pterm.end_date >=
  (SELECT MIN(gd1.grp_start_date)
   FROM pn_var_grp_dates_all gd1
   WHERE gd1.period_id = vinv.period_id
   AND gd1.invoice_date = vinv.invoice_date
  )
  AND pterm.var_rent_inv_id IS NULL
  AND pterm.index_period_id IS NULL
  AND vinv.adjust_num = 0
  AND vinv.var_rent_inv_id=p_inv_id
  AND pterm.payment_term_id=p_term_id);

/*Cursor to check if an abtmt exists for a particular invoice*/
CURSOR check_abtmt_terms_inv(p_inv_id IN NUMBER,p_term_id IN NUMBER) IS
  SELECT 'x' abatement_exists
  FROM dual
  WHERE exists (select  payment_term_id
  FROM pn_var_abatements_all
  WHERE var_rent_inv_id=p_inv_id
  AND payment_term_id=p_term_id);

-- Get all abatement terms for an invoice with update_flag='Y'
CURSOR get_upd_terms(p_var_rentId IN NUMBER,p_var_rent_inv_id IN NUMBER) IS
  SELECT payment_term_id,include_term,include_increases
    FROM pn_var_abatements_all pva
   WHERE pva.var_rent_id= p_var_rentId
     AND pva.var_rent_inv_id = p_var_rent_inv_id
     AND update_flag = 'Y';

CURSOR org_cur(p_var_rentId IN NUMBER) IS
  SELECT org_id
  FROM   pn_var_rents_all
  WHERE  var_rent_id =p_var_rentId;

l_org_id NUMBER;

BEGIN
pnp_debug_pkg.debug ('PNXVRENT_ABATEMENTS_CPG.ROLL_FWD_FST_ON_UPD :'||' (+)');
FOR rec IN org_cur(p_var_rentId) LOOP
    l_org_id := rec.org_id;
END LOOP;

/* Get all invoices from 2nd annual period*/
FOR get_inv_rec IN get_all_inv(p_var_rentId) LOOP
  l_inv_id := get_inv_rec.v_inv_id;

-- If gap exists between 2 invoices then stop roll forward
  IF ( l_inv_id=-1 ) THEN
    EXIT;
  END IF;

--Case 1 : p_pmt_term_id passed IS NULL , so roll fwd all abtmt terms with update_flag='y'
  IF p_pmt_term_id IS NULL  THEN

    FOR upd_rec IN get_upd_terms(p_var_rentId ,p_var_rent_inv_id) LOOP

       l_pmt_exists:=NULL;
       l_abtmt_exists:=NULL;

       FOR pmt_term_rec IN check_pmt_terms(l_inv_id,upd_rec.payment_term_id) LOOP
         l_pmt_exists := pmt_term_rec.pterm_exists;
       END LOOP;

       IF l_pmt_exists IS NOT NULL THEN

          FOR abtmt_rec IN check_abtmt_terms_inv(l_inv_id,upd_rec.payment_term_id) LOOP
            l_abtmt_exists := abtmt_rec.abatement_exists;
          END LOOP;

          IF  l_abtmt_exists IS NULL THEN
            l_row_id := NULL;
            l_var_abmt_id :=NULL;

            PN_VAR_ABATEMENTS_PKG.INSERT_ROW(
            X_ROWID             => l_row_id,
            X_VAR_ABATEMENT_ID  => l_var_abmt_id,
            X_VAR_RENT_ID       => p_var_rentId,
            X_VAR_RENT_INV_ID   => l_inv_id,
            X_PAYMENT_TERM_ID   => upd_rec.payment_term_id,
            X_INCLUDE_TERM      => upd_rec.include_term,
            X_INCLUDE_INCREASES => upd_rec.include_increases,
            X_UPDATE_FLAG       => NULL,
            X_CREATION_DATE     => sysdate,
            X_CREATED_BY        => NVL(fnd_profile.value('USER_ID'),-1),
            X_LAST_UPDATE_DATE  => sysdate,
            X_LAST_UPDATED_BY   => NVL(fnd_profile.value('USER_ID'),-1),
            X_LAST_UPDATE_LOGIN => NVL(fnd_profile.value('USER_ID'),-1),
            X_ORG_ID            => l_org_id  );

          ELSE
             PN_VAR_ABATEMENTS_PKG.UPDATE_ROW(
             X_VAR_RENT_ID       => p_var_rentId,
             X_VAR_RENT_INV_ID   => l_inv_id,
             X_PAYMENT_TERM_ID   => upd_rec.payment_term_id,
             X_INCLUDE_TERM      => upd_rec.include_term,
             X_INCLUDE_INCREASES => upd_rec.include_increases,
             X_UPDATE_FLAG       => NULL,
             X_LAST_UPDATE_DATE  => sysdate,
             X_LAST_UPDATED_BY   => NVL(fnd_profile.value('USER_ID'),-1),
             X_LAST_UPDATE_LOGIN => NVL(fnd_profile.value('USER_ID'),-1));
          END IF;
       END IF;
    END LOOP;

 --Case 2   : p_pmt_term_id IS NOT NULL and flag=0 , candidate for delete_row
  ELSIF flag=0  THEN

    l_pmt_exists:=NULL;
    l_abtmt_exists:=NULL;

    FOR pmt_term_rec IN check_pmt_terms(l_inv_id,p_pmt_term_id) LOOP
       l_pmt_exists := pmt_term_rec.pterm_exists;
    END LOOP;

    IF   l_pmt_exists IS NOT NULL THEN
      FOR abtmt_rec IN check_abtmt_terms_inv(l_inv_id,p_pmt_term_id) LOOP
         l_abtmt_exists := abtmt_rec.abatement_exists;
      END LOOP;

      IF  l_abtmt_exists IS NOT NULL THEN

         PN_VAR_ABATEMENTS_PKG.DELETE_ROW(
            X_VAR_RENT_ID       => p_var_rentId,
            X_VAR_RENT_INV_ID  =>  l_inv_id,
            X_PAYMENT_TERM_ID  =>  p_pmt_term_id);

      END IF;
    END IF;

  END IF;

END LOOP;
pnp_debug_pkg.debug ('PNXVRENT_ABATEMENTS_CPG.ROLL_FWD_FST_ON_UPD :'||' (-)');

END ROLL_FWD_FST_ON_UPD;

FUNCTION CHECK_TRUE_UP_INVOICE(p_var_rent_inv_id IN NUMBER)
RETURN  VARCHAR2
IS
--------------------------------------------------------------------
--
--  NAME         : CHECK_TRUE_UP_INVOICE
--  DESCRIPTION  :
--  PURPOSE      :
--  INVOKED FROM : WHEN-BUTTON-PRESSED on PERIODS_INV_BLK.ABT_DETAILS_BTN
--  ARGUMENTS    : NONE
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--   02-JUL-2007   lbala  o Determines whether it is a true-up invoice or not
--------------------------------------------------------------------

-- Get the details of
CURSOR get_true_up_cur
IS
  SELECT 'Y' as true_up_flag
  FROM dual
  WHERE EXISTS(SELECT NULL
               FROM pn_var_rent_inv_all
               WHERE var_rent_inv_id = p_var_rent_inv_id
               AND true_up_amt IS NOT NULL
               );
l_true_up_flag VARCHAR2(1) := 'N';

BEGIN

  FOR rec IN  get_true_up_cur LOOP
    l_true_up_flag := rec.true_up_flag ;
  END LOOP;

  RETURN l_true_up_flag;

EXCEPTION
  WHEN others THEN
    NULL;
END CHECK_TRUE_UP_INVOICE;

END PN_VAR_ABATEMENTS_PKG;

/
