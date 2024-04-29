--------------------------------------------------------
--  DDL for Package Body PN_VAR_NATURAL_BP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_VAR_NATURAL_BP_PKG" AS
 -- $Header: PNVRNBPB.pls 120.0 2007/10/03 14:29:26 rthumma noship $

-------------------------------------------------------------------------------
-- NAME           :  BUILD_BKPT_DETAILS_MAIN
--
-- DESCRIPTION    :  This procedures calls  build_bkpt_details which creates
--                   Bkpt Detail records for a NATURAL Breakpoint. This is
--                   followed by calculation of group and period volumes and
--                   the inserting data into details defaults tables
--
-- ARGUMENTS      :
--
--    IN PARAM    :  p_var_rent_id (mandatory)
--
--    OUT PARM    :  1. Error Message
--                   2. Error Code
--
-- INVOKED FROM   :  PNXVAREN.pld (ON-COMMIT)
-- HISTORY        :
--
--   06-JUL-06  Pikhar  o Created
--   09-JAN-06  Pikhar  o Bug 5702932. Added NVL condition in bkpt_rate.
--   13-MAR-06  Pikhar  o Bug 5918092. Calculate volumes using headers rate
-------------------------------------------------------------------------------

PROCEDURE build_bkpt_details_main(errbuf              OUT NOCOPY VARCHAR2,
                                  retcode             OUT NOCOPY VARCHAR2,
                                  p_var_rent_id       IN  NUMBER)
IS
  l_bkpt_rec                      BKPT_REC_TYPE;
  l_lease_id                      NUMBER;
  l_var_rent_id                   NUMBER;
  l_bkpt_hdr_id                   NUMBER;
  l_bkpt_rate                     NUMBER;
  l_err                           VARCHAR2(2000);
  l_ret                           VARCHAR2(2000);
  l_counter                       NUMBER          := 0;
  l_rowid                         VARCHAR2(18)    := NULL;
  l_bkpt_default_Id               NUMBER          := NULL;
  l_bkpt_default_Num              NUMBER          := NULL;
  l_reporting_freq                VARCHAR2(30);
  l_reporting_periods             NUMBER;
  l_annual_basis_amount           NUMBER          := NULL;
  l_period_bkpt_vol               NUMBER          := 0;
  l_group_bkpt_vol                NUMBER          := 0;
  l_natural_break_rate            NUMBER;
  l_start_date                    DATE;
  l_end_date                      DATE;
  l_actual_amount                 NUMBER(20,4);
  l_head_dflt_id                  NUMBER;
  l_header_id                     NUMBER;
  l_det_break_rate                NUMBER(20,4);
  l_final_bkpt_rate               NUMBER(20,4);
  l_dummy                         VARCHAR2(1);
  l_null                          NUMBER          :=0;




  CURSOR process_all_defaults_cur
  IS
    SELECT bkhd_default_id, natural_break_rate
    FROM pn_var_bkhd_defaults_all
    WHERE var_rent_id   = p_var_rent_id
    AND break_type      = 'NATURAL';

  CURSOR detail_rate_cur (p_bkhd_def_id IN NUMBER,
                         p_bkhd_def_st_date IN DATE,
                         p_bkhd_def_end_date IN DATE,
                         p_bkhd_def_rate IN NUMBER)
  IS
    SELECT NVL(bkpt_rate,p_bkhd_def_rate) bkpt_rate
    FROM   pn_var_bkdt_defaults_all
    WHERE  bkhd_default_id = p_bkhd_def_id
    AND    p_bkhd_def_st_date <= bkdt_end_date
    AND    p_bkhd_def_end_date >= bkdt_start_date;


  CURSOR line_info_cur(p_line_item_id IN NUMBER)
  IS
    SELECT period_id, var_rent_id
    FROM pn_var_lines_all
    WHERE line_item_id = p_line_item_id;


  CURSOR line_cur(p_bkhd_default_id IN NUMBER) IS
    select line_item_id
    from pn_var_lines_all
    where line_default_id IN (select line_default_id
                              from pn_var_bkhd_defaults_all
                              where bkhd_default_id = p_bkhd_default_id);


BEGIN

  PNP_DEBUG_PKG.LOG ('pn_var_natural_bp_pkg.build_bkpt_details_main : (+)');

  IF p_var_rent_id IS NULL THEN

     PNP_DEBUG_PKG.LOG ('p_var_rent_id IS NULL');
     errbuf  := 'Var Rent ID is, Please enter Var Rent ID';
     retcode := 2;

  ELSE

     l_var_rent_id := p_var_rent_id;

     SELECT lease_id
     INTO l_lease_id
     FROM pn_var_rents_all
     WHERE var_rent_id = l_var_rent_id;

     SELECT reptg_freq_code
     INTO l_reporting_freq
     FROM pn_var_rent_dates_all
     WHERE var_rent_id = p_var_rent_id;

     l_reporting_periods   := NULL;
     l_reporting_periods   := NVL(pn_var_rent_pkg.find_reporting_periods(p_freq_code=>l_reporting_freq), 1);

     FOR bkhd_def_rec in process_all_defaults_cur
     LOOP

        l_head_dflt_id       := bkhd_def_rec.bkhd_default_id;
        l_natural_break_rate := bkhd_def_rec.natural_break_rate;

        build_bkpt_details(errbuf             => l_err,
                           retcode            => l_ret,
                           p_lease_id         => l_lease_id,
                           p_var_rent_id      => l_var_rent_id,
                           p_head_dflt_id     => l_head_dflt_id,
                           p_header_id        => NULL,
                           p_bkpt_rec         => l_bkpt_rec
                           );

        FOR l_counter IN l_bkpt_rec.FIRST .. l_bkpt_rec.LAST
        LOOP

           l_start_date          := l_bkpt_rec(l_counter).start_date;
           l_end_date            := l_bkpt_rec(l_counter).end_date;
           l_actual_amount       := l_bkpt_rec(l_counter).amount;
           l_annual_basis_amount := l_actual_amount;

           l_bkpt_rate := NULL;
           FOR det_rec IN detail_rate_cur(p_bkhd_def_id =>  l_head_dflt_id,
                                          p_bkhd_def_st_date => l_start_date,
                                          p_bkhd_def_end_date => l_end_date,
                                          p_bkhd_def_rate => l_natural_break_rate)
           LOOP
              l_bkpt_rate := det_rec.bkpt_rate;
           END LOOP;

           l_bkpt_rec(l_counter).bkpt_rate := l_bkpt_rate;

        END LOOP;


        DELETE FROM pn_var_bkpts_det_all
        WHERE  var_rent_id = p_var_rent_id
        AND    bkpt_header_id IN (SELECT bkpt_header_id
                                  FROM   pn_var_bkpts_head_all
                                  WHERE  bkhd_default_id = l_head_dflt_id);

        DELETE FROM PN_VAR_BKDT_DEFAULTS_ALL
        WHERE bkhd_default_id = l_head_dflt_id;

        DELETE FROM pn_var_bkpts_head_all
        WHERE  bkhd_default_id = l_head_dflt_id;

        FOR l_counter IN l_bkpt_rec.FIRST .. l_bkpt_rec.LAST
        LOOP

           l_start_date          := l_bkpt_rec(l_counter).start_date;
           l_end_date            := l_bkpt_rec(l_counter).end_date;
           l_actual_amount       := l_bkpt_rec(l_counter).amount;
           l_bkpt_rate           := l_bkpt_rec(l_counter).bkpt_rate;

           l_period_bkpt_vol     := ROUND((l_actual_amount / NVL(l_natural_break_rate,l_bkpt_rate)), 2);
           l_group_bkpt_vol      := ROUND((l_period_bkpt_vol/l_reporting_periods),2);

           BEGIN
              l_rowid                 := NULL;
              l_bkpt_default_Id       := NULL;
              l_bkpt_default_Num      := NULL;

              PN_VAR_BKDT_DEFAULTS_PKG.INSERT_ROW(x_rowid                  => l_rowId,
                                                  x_bkdt_default_id        => l_bkpt_default_Id,
                                                  x_bkdt_detail_num        => l_bkpt_default_Num,
                                                  x_bkhd_default_id        => l_head_dflt_id,
                                                  x_bkdt_start_date        => l_start_date,
                                                  x_bkdt_end_date          => l_end_date,
                                                  x_period_bkpt_vol_start  => l_period_bkpt_vol,
                                                  x_period_bkpt_vol_end    => null,
                                                  x_group_bkpt_vol_start   => l_group_bkpt_vol,
                                                  x_group_bkpt_vol_end     => null,
                                                  x_bkpt_rate              => NVL(l_bkpt_rate,l_natural_break_rate),
                                                  x_processed_flag         => null,
                                                  x_var_rent_id            => p_var_rent_id,
                                                  x_creation_date          => SYSDATE,
                                                  x_created_by             => NVL (FND_PROFILE.VALUE ('USER_ID'), 0),
                                                  x_last_update_date       => SYSDATE,
                                                  x_last_updated_by        => NVL (FND_PROFILE.VALUE ('USER_ID'), 0),
                                                  x_last_update_login      => NVL (FND_PROFILE.VALUE ('LOGIN_ID'), 0),
                                                  x_org_id                 => NVL (FND_PROFILE.VALUE ('ORG_ID'), 0 ),
                                                  x_annual_basis_amount    => l_actual_amount,
                                                  x_attribute_category     => NULL,
                                                  x_attribute1             => NULL,
                                                  x_attribute2             => NULL,
                                                  x_attribute3             => NULL,
                                                  x_attribute4             => NULL,
                                                  x_attribute5             => NULL,
                                                  x_attribute6             => NULL,
                                                  x_attribute7             => NULL,
                                                  x_attribute8             => NULL,
                                                  x_attribute9             => NULL,
                                                  x_attribute10            => NULL,
                                                  x_attribute11            => NULL,
                                                  x_attribute12            => NULL,
                                                  x_attribute13            => NULL,
                                                  x_attribute14            => NULL,
                                                  x_attribute15            => NULL);


              EXCEPTION
                WHEN OTHERS THEN
                /*DBMS_OUTPUT.PUT_LINE(SUBSTR('Error while PN_VAR_BKDT_DEFAULTS_PKG.INSERT_ROW - '||
                                     TO_CHAR(SQLCODE)||' : '||SQLERRM, 1, 244));*/
                errbuf := SQLERRM;
                retcode := 2;
                ROLLBACK;
           END;

        END LOOP;
     END LOOP;
  END IF;

  PNP_DEBUG_PKG.LOG ('pn_var_natural_bp_pkg.build_bkpt_details_main : (-)');

END build_bkpt_details_main;

-------------------------------------------------------------------------------
-- NAME        : BUILD_BKPT_DETAILS
--
-- DESCRIPTION : This procedure splits Bkpt Detail records for a NATURAL
--               lease based on Var Rent dates for re-distribution
--               whenever there is a change in term dates or number of terms
--               IF a lease has Var Rent Term T1 exists from 1/1/01 to 12/31/2002
--               and Var Rent Term T2 exists from 2/1/01 to 2/28/01
--               and Include in Var Rent has been checked then

--               T1 |--------------------|          T2 |----|
--               1/1/01             12/31/2002      2/1/01 2/28/01
--
--               Bkpt details will be created as follows.....
--               Bkpt detail BKPT1 for T1      :|---|
--                                          1/1/01  1/31/01
--               Bkpt detail BKPT2 for T1+ T2  :     |---|
--                                                2/1/01 2/28/01
--               Bkpt detail BKPT3 for T1      :          |----------|
--                                                       3/1/01   12/31/01
--               Bkpt detail BKPT4 for T1      :                      |-------------|
--                                                                  1/1/02      12/31/02
--
--
-- ARGUMENTS:
--
--    IN PARAM      1) p_lease_id (optional)
--                  2) p_var_rent_id (mandatory)
--                  3) Header_default_id (mandatory if Header_id is null)
--                  4) Header_id (mandatory if Header_default_id is null)
--    OUT PARM      1) Error Message
--                  2) Error Code
--                  3) bkpt detail start dates table
--                  4) bkpt detail end dates table
--                  5) bkpt detail actual amounts table
--
-- INVOKED FROM : ON-INSERT trigger at TERMS block level
-- HISTORY:

--    06-JUL-06  Pikhar  o Created
--    28-MAR-07  Pikhar  o Bug 5958344. Excluded DRAFT RI terms from NBB
-------------------------------------------------------------------------------


PROCEDURE build_bkpt_details(errbuf           OUT NOCOPY VARCHAR2,
                             retcode          OUT NOCOPY VARCHAR2,
                             p_lease_id       IN  NUMBER,
                             p_var_rent_id    IN  NUMBER,
                             p_head_dflt_id   IN  NUMBER,
                             p_header_id      IN  NUMBER,
                             p_bkpt_rec       IN  OUT NOCOPY bkpt_rec_type)
  IS

    l_counter                NUMBER;
    l_lease_id               NUMBER;
    l_bkhd_st_dt             DATE;
    l_bkhd_end_dt            DATE;
    l_bkpt_rate              NUMBER;
    l_date                   DATE;
    l_det_amt                NUMBER;
    l_act_amt                NUMBER;
    l_reporting_periods      NUMBER;

    l_bkpt_rec               bkpt_rec_type;


    /***************************************************************************
    *Cursor for Bkpt Header defaults data
    ***************************************************************************/

    CURSOR bkhd_def_cur
    IS
       SELECT bkhd_start_date,
              bkhd_end_date,
              bkhd_default_id,
              natural_break_rate
       FROM   pn_var_bkhd_defaults_all
       WHERE  bkhd_default_id = p_head_dflt_id
       AND    break_type = 'NATURAL'
       ORDER BY bkhd_start_date;

    /***************************************************************************
    * Cursor to get payment term data - used to build PL/SQL record            *
    ***************************************************************************/

    CURSOR term_cur (p_bkhd_start_date IN DATE,
                     p_bkhd_end_date IN DATE,
                     p_lease_id IN NUMBER,
                     p_bkhd_def_id IN NUMBER,
                     p_bkpt_rate IN NUMBER)
    IS
       SELECT DISTINCT start_date FROM(
          SELECT distinct GREATEST(start_date, p_bkhd_start_date) start_date
          FROM pn_payment_terms_all
          WHERE lease_id = p_lease_id
          AND include_in_var_rent IN  ('BASETERM','INCLUDE_RI')
          AND index_period_id IS NULL
          AND p_bkhd_start_date <= end_date
          AND p_bkhd_end_date >= start_date
       UNION
          SELECT distinct (LEAST(end_date, p_bkhd_end_date) + 1) start_date
          FROM pn_payment_terms_all
          WHERE lease_id = p_lease_id
          AND include_in_var_rent IN  ('BASETERM','INCLUDE_RI')
          AND index_period_id IS NULL
          AND p_bkhd_start_date <= end_date
          AND p_bkhd_end_date >= start_date
          AND (LEAST(end_date, p_bkhd_end_date) + 1) <= p_bkhd_end_date
       UNION
          SELECT distinct GREATEST(start_date, p_bkhd_start_date) start_date
          FROM pn_payment_terms_all
          WHERE lease_id = p_lease_id
          AND include_in_var_rent IN  ('INCLUDE_RI')
          AND index_period_id IS NOT NULL
          AND status = 'APPROVED'
          AND p_bkhd_start_date <= end_date
          AND p_bkhd_end_date >= start_date
       UNION
          SELECT distinct (LEAST(end_date, p_bkhd_end_date) + 1) start_date
          FROM pn_payment_terms_all
          WHERE lease_id = p_lease_id
          AND include_in_var_rent IN  ('INCLUDE_RI')
          AND index_period_id IS NOT NULL
          AND status = 'APPROVED'
          AND p_bkhd_start_date <= end_date
          AND p_bkhd_end_date >= start_date
          AND (LEAST(end_date, p_bkhd_end_date) + 1) <= p_bkhd_end_date
       UNION
          SELECT p_bkhd_start_date start_date
          FROM DUAL
       UNION
          SELECT distinct bkdt_start_date start_date
          FROM pn_var_bkdt_defaults_all
          WHERE bkhd_default_id = p_bkhd_def_id
          AND bkpt_rate <> p_bkpt_rate
       UNION
          SELECT distinct (bkdt_end_date +1) start_date
          FROM pn_var_bkdt_defaults_all
          WHERE bkhd_default_id = p_bkhd_def_id
          AND bkpt_rate <> p_bkpt_rate
          )
       WHERE start_date <= p_bkhd_end_date
       ORDER BY start_date;



    /***************************************************************************
    * Cursor to get payment term data - used to calculate annual basis amount  *
    ***************************************************************************/

   CURSOR paymt_terms_inner_cur(p_det_st_dt    IN DATE,
                                p_det_end_date IN DATE,
                                p_lease_id     IN NUMBER)
   IS
     SELECT DISTINCT * from (
        SELECT start_date, end_date, frequency_code, SUM(actual_amount) actual_amount
        FROM pn_payment_terms_all
        WHERE lease_id = p_lease_id
        AND include_in_var_rent in ('BASETERM','INCLUDE_RI')
        AND index_period_id IS NULL
        AND p_det_st_dt <= end_date
        AND p_det_end_date >= start_date
        GROUP by start_date, end_date, frequency_code, actual_amount
     UNION
        SELECT start_date, end_date, frequency_code, SUM(actual_amount) actual_amount
        FROM pn_payment_terms_all
        WHERE lease_id = p_lease_id
        AND include_in_var_rent in ('INCLUDE_RI')
        AND index_period_id IS NOT NULL
        AND status = 'APPROVED'
        AND p_det_st_dt <= end_date
        AND p_det_end_date >= start_date
        GROUP by start_date, end_date, frequency_code, actual_amount);


  BEGIN

    PNP_DEBUG_PKG.LOG ('pn_var_natural_bp_pkg.build_bkpt_details : (+)');

    IF p_var_rent_id IS NULL AND p_lease_id IS NULL THEN
       errbuf := 'Lease ID and Var Rent ID are NULL';
       retcode := 2;

    ELSE
       IF p_lease_id IS NULL AND p_var_rent_id IS NOT NULL THEN

             SELECT lease_id
             INTO l_lease_id
             FROM pn_var_rents_all
             WHERE var_rent_id = p_var_rent_id;

       ELSE
          l_lease_id := p_lease_id;
       END IF;
    END IF;

    FOR bkhd_def_rec IN bkhd_def_cur
    LOOP

       l_bkhd_st_dt    := bkhd_def_rec.bkhd_start_date;
       l_bkhd_end_dt   := bkhd_def_rec.bkhd_end_date;
       l_bkpt_rate     := bkhd_def_rec.natural_break_rate;

       l_bkpt_rec.DELETE;

       l_counter := 0;
       FOR term_rec IN term_cur (p_bkhd_start_date => l_bkhd_st_dt,
                                 p_bkhd_end_date   => l_bkhd_end_dt,
                                 p_lease_id        => l_lease_id,
                                 p_bkhd_def_id     => p_head_dflt_id,
                                 p_bkpt_rate       => l_bkpt_rate)
       LOOP
          l_bkpt_rec(l_counter).start_date := term_rec.start_date;
          l_counter := l_counter + 1;

       END LOOP;

       FOR l_counter in  l_bkpt_rec.FIRST.. l_bkpt_rec.LAST
       LOOP

          IF l_counter < l_bkpt_rec.LAST THEN
             /* Not the last record */
             l_bkpt_rec(l_counter).end_date := (l_bkpt_rec(l_counter+1).start_date -1);
          ELSE
             /* This is the last record. Hence end_date must be the header default end date */
             l_bkpt_rec(l_counter).end_date := l_bkhd_end_dt;
          END IF;

          l_det_amt := 0;
          l_act_amt := 0;

          FOR inner_rec IN paymt_terms_inner_cur(l_bkpt_rec(l_counter).start_date,
                                                 l_bkpt_rec(l_counter).end_date,
                                                 l_lease_id)
          LOOP

             l_det_amt     := inner_rec.actual_amount;
             --Get Billing Term Reporting Frequency
             IF inner_rec.frequency_code = 'OT' THEN
                l_reporting_periods := 1;
             ELSE
                l_reporting_periods   := NVL(pn_var_rent_pkg.find_reporting_periods(p_freq_code=>inner_rec.frequency_code), 1);
             END IF;

             l_det_amt := ROUND(l_det_amt * l_reporting_periods, 4);
             l_act_amt := l_act_amt + l_det_amt;

          END LOOP;

          l_bkpt_rec(l_counter).amount := l_act_amt;

       END LOOP;

    END LOOP;

    p_bkpt_rec := l_bkpt_rec;


  EXCEPTION
     WHEN OTHERS THEN
        PNP_DEBUG_PKG.LOG(SUBSTR('pn_var_natural_bp_pkg.build_bkpt_details - '||
                                     TO_CHAR(SQLCODE)||' : '||SQLERRM, 1, 244));
        errbuf := SQLERRM;
        retcode := 2;
        ROLLBACK;

  PNP_DEBUG_PKG.LOG ('pn_var_natural_bp_pkg.build_bkpt_details : (-)');

END build_bkpt_details;


-------------------------------------------------------------------------------
-- NAME           :  PN_VAR_NAT_TO_ARTIFICIAL
--
-- DESCRIPTION    :  This procedure is a CP run from SRS screen. In Diagnostic
--                   mode, it lists to the user, all breakpoint headers which
--                   has break type as Natural and not null value of Base Rent.
--                   In update mode,  it updates for the break_type from
--                   Natural to Artificial for the breakpoints headers
--
--
-- ARGUMENTS
--  IN PARAM      :  p_mode        (mandatory)
--                   p_prop_id     (optional)
--                   p_loc_id      (optional)
--                   p_lease_id    (optional)
--                   p_var_rent_id (optional)
--
--  OUT PARM      :  None
--
-- INVOKED FROM   :
--
-- HISTORY
--
--   07-AUG-06   Pikhar  o Created
--   28-MAR-07   Pikhar  o Bug 5956725. Converted Natural Breakpoints to FLAT
--   07-May-07   Pikhar  o Bug 6033669. Converted Natural Breakpoint should not
--                         have annualised basis amount
--   07-May-07   Pikhar  o Bug 6033314. Modified query for lease_loc_cur
-------------------------------------------------------------------------------

procedure PN_VAR_NAT_TO_ARTIFICIAL(errbuf         OUT NOCOPY VARCHAR2
                                  ,retcode        OUT NOCOPY VARCHAR2
                                  ,p_mode         IN VARCHAR2
                                  ,p_prop_id      IN NUMBER
                                  ,p_loc_id       IN NUMBER
                                  ,p_lease_id     IN NUMBER
                                  ,p_var_rent_id  IN NUMBER) IS


/* Data Structures */
TYPE NUM_TBL IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE DATE_TBL IS TABLE OF DATE INDEX BY BINARY_INTEGER;

/* Variables */
l_var_rent_id   NUMBER           :=0;
l_per_print     NUMBER           :=0;
l_var_print     NUMBER           :=0;
l_lease_print   NUMBER           :=0;
l_prop_id       NUMBER;
l_loc_id        NUMBER;
l_lease_id      NUMBER;
l_lease_num     VARCHAR2(80);
l_counter       NUMBER;
l_var_rent_num  VARCHAR2(30);
l_sales_type    VARCHAR2(30);
l_item_category VARCHAR2(30);
l_message       VARCHAR2(2000);
l_message1      VARCHAR2(2000);
l_update_count  NUMBER           :=0;
l_diagnostic    NUMBER           :=0;
l_lease_tab     NUM_TBL;
l_var_lease_tab VAR_LEASE_TYPE;


/* Cursors */

CURSOR lease_loc_cur (p_prop_id IN NUMBER)
IS
   SELECT distinct lease_id
   FROM
   (
   SELECT lease_id
   FROM pn_leases_all
   WHERE location_id in (SELECT location_id
                         FROM   pn_locations_all loc
                         START with loc.location_id in (SELECT location_id
                                                        FROM pn_locations_all
                                                        WHERE property_id = p_prop_id)
                         CONNECT by prior loc.location_id = parent_location_id)
   UNION
   SELECT lease_id
   FROM pn_tenancies_all
   WHERE location_id in (SELECT location_id
                         FROM   pn_locations_all loc
                         START with loc.location_id in (SELECT location_id
                                                        FROM pn_locations_all
                                                        WHERE property_id = p_prop_id)
                         CONNECT by prior loc.location_id = parent_location_id)
   );

CURSOR lease_cur(p_loc_id IN NUMBER)
IS
   SELECT lease_id from
   (SELECT lease_id
    FROM pn_tenancies_all
    WHERE location_id = p_loc_id
    UNION
    SELECT lease_id
    FROM pn_leases_all
    WHERE location_id = p_loc_id
    );


CURSOR lease_var_cur (p_var_rent_id IN NUMBER)
IS
SELECT lease_id, rent_num
FROM PN_VAR_RENTS_ALL
WHERE var_rent_id = p_var_rent_id;

CURSOR var_cur(p_lease_id IN NUMBER)
IS
   SELECT var_rent_id,rent_num
   FROM pn_var_rents_All
   WHERE lease_id = p_lease_id
   ORDER BY var_rent_id DESC;

CURSOR periods_cur (p_var_rent_id IN NUMBER)
IS
   SELECT period_id, start_date, end_date
   FROM pn_var_periods_all
   WHERE var_rent_id = p_var_rent_id;


CURSOR lines_cur (p_period_id IN NUMBER)
IS
   SELECT line_item_id, sales_type_code, item_category_code
   FROM pn_var_lines_all
   WHERE period_id = p_period_id;


CURSOR bkhd_head_cur (p_line_item_id IN NUMBER)
IS
   SELECT bkpt_header_id, base_rent, natural_break_rate
   FROM pn_var_bkpts_head_all
   WHERE line_item_id = p_line_item_id
   AND break_type = 'NATURAL'
   AND base_rent IS NOT NULL;


CURSOR sales_type_cur(p_sales_code IN VARCHAR2)
IS
   SELECT fnd1.meaning
   FROM fnd_lookups fnd1
   WHERE lookup_type='PN_SALES_CHANNEL'
   AND lookup_code = p_sales_code
   AND sysdate between
       nvl(start_date_active,sysdate) and nvl(end_date_active,sysdate)
   AND enabled_flag='Y';


CURSOR item_category_cur(p_item_code IN VARCHAR2)
IS
   SELECT fnd2.meaning
   FROM fnd_lookups fnd2
   WHERE lookup_type='PN_ITEM_CATEGORY'
   AND lookup_code = p_item_code
   AND sysdate between
       nvl(start_date_active,sysdate) and nvl(end_date_active,sysdate)
   AND enabled_flag='Y';


/* Exceptions */
BAD_CALL_EXCEPTION EXCEPTION;



BEGIN

pnp_debug_pkg.log('pn_var_natural_bp_pkg.pn_var_nat_to_artificial  (+)  : ');

l_prop_id :=  p_prop_id;
l_loc_id := p_loc_id;
l_var_rent_id := p_var_rent_id;


l_var_lease_tab.DELETE;

IF p_var_rent_id IS NOT NULL THEN

   l_var_lease_tab(1).var_rent_id := p_var_rent_id;
   OPEN lease_var_cur(p_var_rent_id);
   FETCH lease_var_cur INTO l_var_lease_tab(1).lease_id,l_var_lease_tab(1).var_rent_num ;
   CLOSE lease_var_cur;

ELSE

   l_lease_tab.DELETE;

   IF p_lease_id IS NOT NULL THEN

      l_lease_tab(1) := p_lease_id;

   ELSIF p_loc_id IS NOT NULL THEN

      OPEN lease_cur(p_loc_id => l_loc_id);
      FETCH lease_cur BULK COLLECT INTO l_lease_tab;
      CLOSE lease_cur;

   ELSIF p_prop_id IS NOT NULL THEN

      OPEN lease_loc_cur(p_prop_id => l_prop_id);
      FETCH lease_loc_cur BULK COLLECT INTO l_lease_tab;
      CLOSE lease_loc_cur;

   ELSE
      RAISE BAD_CALL_EXCEPTION;
   END IF;

   l_counter := 0; /* used to populate PL/SQL table */

   IF l_lease_tab.count >0 THEN
      FOR lease_rec IN l_lease_tab.FIRST .. l_lease_tab.LAST
      LOOP

         FOR var_rec in var_cur(l_lease_tab(lease_rec))
         LOOP
            l_var_lease_tab(l_counter).var_rent_id := var_rec.var_rent_id;
            l_var_lease_tab(l_counter).lease_id := l_lease_tab(lease_rec);
            l_var_lease_tab(l_counter).var_rent_num := var_rec.rent_num;
            l_counter := l_counter + 1;
         END LOOP;

      END LOOP;
   END IF;

END IF;


IF l_var_lease_tab.count > 0 THEN

   FOR var_rec in l_var_lease_tab.FIRST .. l_var_lease_tab.LAST
   LOOP

      l_var_rent_id := l_var_lease_tab(var_rec).var_rent_id;
      l_var_rent_num := l_var_lease_tab(var_rec).var_rent_num;
      l_lease_id := l_var_lease_tab(var_rec).lease_id;
      l_var_print   := 0;

      IF l_var_lease_tab.EXISTS(var_rec -1) THEN
         IF l_lease_id <> l_var_lease_tab(var_rec - 1 ).lease_id THEN
            l_lease_print := 0;
         END IF;
      END IF;


      FOR per_rec in periods_cur (p_var_rent_id => l_var_rent_id)
      LOOP

         l_per_print := 0;
         FOR lines_rec in lines_cur (p_period_id => per_rec.period_id)
         LOOP


            OPEN sales_type_cur(p_sales_code => lines_rec.sales_type_code);
            FETCH sales_type_cur INTO l_sales_type;
            CLOSE sales_type_cur;
            IF l_sales_type IS NULL THEN
               l_sales_type := lines_rec.sales_type_code;
            END IF;

            OPEN item_category_cur(p_item_code => lines_rec.item_category_code);
            FETCH item_category_cur INTO l_item_category;
            CLOSE item_category_cur;
            IF l_item_category IS NULL THEN
               l_item_category := lines_rec.item_category_code;
            END IF;


            FOR bkhd_rec in bkhd_head_cur (lines_rec.line_item_id)
            LOOP

               IF p_mode = 'D' THEN

                  IF l_lease_print = 0 THEN

                     fnd_message.set_name ('PN','PN_LEASE_NUMBER');
                     l_message := fnd_message.get;
                     Fnd_File.Put_Line ( Fnd_File.OutPut,'  ');
                     Fnd_File.Put_Line ( Fnd_File.OutPut,'  ');
                     Fnd_File.Put_Line ( Fnd_File.OutPut,'  ');
                     Fnd_File.Put_Line ( Fnd_File.OutPut,'================================================================================');
                     Fnd_File.Put_Line ( Fnd_File.OutPut,' '||l_message ||' : ' || l_lease_id);
                     Fnd_File.Put_Line ( Fnd_File.OutPut,'================================================================================');
                     l_message := NULL;
                     l_lease_print := 1; /* This is to ensure that the lease name is printed
                                            just once for all VRs belonging to that lease*/

                  END IF;


                  IF l_var_print = 0 THEN

                     fnd_message.set_name ('PN','PN_VARENT_NUM');
                     fnd_message.set_token('VAR_RENT_NUM',l_var_rent_num);
                     l_message := fnd_message.get;
                     Fnd_File.Put_Line ( Fnd_File.OutPut,'  ');
                     Fnd_File.Put_Line ( Fnd_File.OutPut,'  ');
                     Fnd_File.Put_Line ( Fnd_File.OutPut,'     ---------------------------------------------------------------------------');
                     Fnd_File.Put_Line ( Fnd_File.OutPut,'      ' || l_message);
                     Fnd_File.Put_Line ( Fnd_File.OutPut,'     ---------------------------------------------------------------------------');
                     l_message := NULL;
                     l_var_print := 1; /* This is to ensure that the VR name is printed
                                          just once for all periods belonging to that VR*/

                  END IF;


                  IF l_per_print = 0 THEN

                     fnd_message.set_name ('PN','PN_VAR_PER_ST_DT');
                     l_message := fnd_message.get;
                     fnd_message.set_name ('PN','PN_VAR_PER_END_DT');
                     l_message := l_message||'        '||fnd_message.get;

                     fnd_message.set_name ('PN','PN_VAR_SALES_TYPE');
                     l_message1 := fnd_message.get;
                     fnd_message.set_name ('PN','PN_VAR_ITEM_CATEGORY');
                     l_message1 := l_message1|| '    '||fnd_message.get;
                     fnd_message.set_name ('PN','PN_VAR_NAT_BREAK_RATE');
                     l_message1 := l_message1|| '    '||fnd_message.get;
                     fnd_message.set_name ('PN','PN_VAR_BASE_RENT');
                     l_message1 := l_message1||'    '||fnd_message.get;

                     Fnd_File.Put_Line ( Fnd_File.OutPut,  '  ');
                     Fnd_File.Put_Line ( Fnd_File.OutPut,  '           ---------------------------------------------------------------------');
                     Fnd_File.Put_Line ( Fnd_File.OutPut,  '            '||l_message);
                     Fnd_File.Put_Line ( Fnd_File.OutPut,  '            '||per_rec.start_date||'                '||per_rec.end_date);
                     Fnd_File.Put_Line ( Fnd_File.OutPut,  '           ---------------------------------------------------------------------');
                     Fnd_File.Put_Line ( Fnd_File.OutPut,  '                  '||l_message1);
                     Fnd_File.Put_Line ( Fnd_File.OutPut,  '                 ---------------------------------------------------------------');

                     l_per_print :=1; /* This is to ensure that the period Header is printed
                                         just once for all lines belonging to that period */

                  END IF;

                  Fnd_File.Put_Line ( Fnd_File.OutPut,'                  '
                                                    ||RPAD(l_sales_type,13,' ')||' '
                                                    ||RPAD(l_item_category,17,' ')||' '
                                                    ||LPAD(bkhd_rec.natural_break_rate,17,' ')
                                                    ||LPAD(bkhd_rec.base_rent,13,' '));

                  l_diagnostic := l_diagnostic +1;

               ELSIF p_mode = 'U' THEN

                  UPDATE PN_VAR_BKPTS_HEAD_ALL
                  SET break_type = 'ARTIFICIAL'
                    , natural_break_rate = NULL
                  WHERE bkpt_header_id = bkhd_rec.bkpt_header_id;

                  UPDATE PN_VAR_BKPTS_HEAD_ALL
                  SET breakpoint_type = 'FLAT'
                  WHERE bkpt_header_id = bkhd_rec.bkpt_header_id;

                  UPDATE PN_VAR_BKPTS_DET_ALL
                  SET ANNUAL_BASIS_AMOUNT = NULL
                  WHERE bkpt_header_id = bkhd_rec.bkpt_header_id;

                  l_update_count := l_update_count + 1;

               ELSE
                  pnp_debug_pkg.log('BAD_CALL_EXCEPTION');
                  RAISE BAD_CALL_EXCEPTION;
               END IF;

            END LOOP; /* Headers */

         END LOOP; /* lines*/

      END LOOP; /* periods */

   END LOOP; /* var rent */

END IF;

   IF p_mode = 'U' and l_update_count > 0 THEN
      pnp_debug_pkg.log(l_update_count||' records updated' );
      COMMIT;
   ELSIF p_mode = 'D' and l_diagnostic > 0 THEN
      Fnd_File.Put_Line ( Fnd_File.OutPut,' ');
      Fnd_File.Put_Line ( Fnd_File.OutPut,'================================================================================');
   END IF;


pnp_debug_pkg.log('pn_var_natural_bp_pkg.pn_var_nat_to_artificial  (-)  : ');

EXCEPTION
      WHEN BAD_CALL_EXCEPTION
      THEN
         NULL;

END PN_VAR_NAT_TO_ARTIFICIAL;



END pn_var_natural_bp_pkg;

/
