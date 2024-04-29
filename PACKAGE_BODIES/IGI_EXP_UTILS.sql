--------------------------------------------------------
--  DDL for Package Body IGI_EXP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_EXP_UTILS" AS
-- $Header: igiexpqb.pls 120.6.12000000.2 2007/09/21 07:10:18 dvjoshi ship $
   --

   --
   -- Procedure
   --   Generate_Number
   -- History
   --   27-NOV-2001 L Silveira  Initial Version

   --
   PROCEDURE Generate_Number(pi_number_type   IN  VARCHAR2,
                             pi_number_class  IN  VARCHAR2,
                             pi_du_tu_type_id IN  NUMBER,
                             pi_fiscal_year   IN  NUMBER,
                             po_du_tu_number  OUT NOCOPY VARCHAR2,
                             po_error_message OUT NOCOPY VARCHAR2) IS

      CURSOR c_num_scheme IS
         SELECT num_scheme_id,
                prefix,
                suffix,
                next_seq_val
         FROM   igi_exp_num_schemes
         WHERE  numbering_type = pi_number_type
         AND    numbering_class = pi_number_class
         AND    du_tu_type_id = pi_du_tu_type_id
         AND    fiscal_year = pi_fiscal_year
         FOR UPDATE OF next_seq_val; --bug3589744 sdixit

      l_num_scheme_id NUMBER;
      l_prefix        VARCHAR2(100);
      l_suffix        VARCHAR2(100);
      l_next_seq_val  NUMBER;

      e_invalid_parameters   EXCEPTION;
      e_num_scheme_not_found EXCEPTION;
   BEGIN
      --
      -- Validate passed parameter values
      --
      IF pi_number_type   IS NULL OR
         pi_number_class  IS NULL OR
         pi_du_tu_type_id IS NULL OR
         pi_fiscal_year   IS NULL
      THEN
         RAISE e_invalid_parameters;
      END IF;

      IF pi_number_type <> 'DU' AND pi_number_type <> 'TU'
      THEN
         RAISE e_invalid_parameters;
      END IF;

      IF pi_number_class <> 'O' AND pi_number_class <> 'L'
      THEN
         RAISE e_invalid_parameters;
      END IF;

      IF LENGTH(TO_CHAR(pi_fiscal_year)) <> 4
      THEN
         RAISE e_invalid_parameters;
      END IF;

      --
      -- Fetch numbering scheme
      --
      OPEN c_num_scheme;

      FETCH c_num_scheme INTO l_num_scheme_id,
                              l_prefix,
                              l_suffix,
                              l_next_seq_val;
      IF c_num_scheme%NOTFOUND THEN
         RAISE e_num_scheme_not_found;
      END IF;

      CLOSE c_num_scheme;

      --
      -- Update Next Sequence Value
      --

      UPDATE igi_exp_num_schemes_all
      SET    next_seq_val = (next_seq_val + 1)
      WHERE  num_scheme_id = l_num_scheme_id;

      --
      -- Build number
      --
      po_du_tu_number := l_prefix||TO_CHAR(l_next_seq_val)||l_suffix||
                         TO_CHAR(pi_fiscal_year);

   EXCEPTION

      WHEN e_invalid_parameters THEN
          po_du_tu_number := '';
          po_error_message := 'Error: Invalid parameters passed ('||
                              'Number Type:'||pi_number_type||','||
                              'Number Class:'||pi_number_class||','||
                              'DU/TU Type Id:'||TO_CHAR(pi_du_tu_type_id)||','||
                              'Fiscal Year:'||TO_CHAR(pi_fiscal_year)||')';

      WHEN e_num_scheme_not_found THEN
          IF c_num_scheme%ISOPEN THEN
             CLOSE c_num_scheme;
          END IF;

          po_du_tu_number := '';
          po_error_message := 'Error: Numbering Scheme not found ('||
                              'Number Type:'||pi_number_type||','||
                              'Number Class:'||pi_number_class||','||
                              'DU/TU Type Id:'||TO_CHAR(pi_du_tu_type_id)||','||
                              'Fiscal Year:'||TO_CHAR(pi_fiscal_year)||')';

      WHEN OTHERS THEN
          IF c_num_scheme%ISOPEN THEN
             CLOSE c_num_scheme;
          END IF;

          po_du_tu_number := '';
   --bug 3199481 fnd logging changes: sdixit: start block
   --as display of the error is being handled in the form that calls this package,
   -- just set the standard message here
          FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          po_error_message := FND_MESSAGE.GET;
   --bug 3199481 fnd logging changes: sdixit: end block


   END Generate_Number;

   --
   -- Procedure
   --   Get Fiscal Year
   -- History
   --   03-DEC-2001 L Silveira  Initial Version
   --
   PROCEDURE Get_Fiscal_Year(pi_gl_date       IN  DATE,
                             po_fiscal_year   OUT NOCOPY NUMBER,
                             po_error_message OUT NOCOPY VARCHAR2) IS

      CURSOR c_fiscal_year(p_sob_id NUMBER) IS
         SELECT period_year
         FROM   gl_periods       gp
               ,gl_sets_of_books gsob
         WHERE  gp.period_set_name = gsob.period_set_name
         AND    gp.period_type = gsob.accounted_period_type
--        AND    TRUNC(TO_DATE(pi_gl_date, 'DD-MON-RRRR'))
   AND  TRUNC(pi_gl_date)
                BETWEEN TRUNC(gp.start_date)
                AND     TRUNC(gp.end_date)
         AND    gsob.set_of_books_id = p_sob_id;

      l_sob_id gl_sets_of_books.set_of_books_id%TYPE;
      l_sob_name gl_sets_of_books.name%TYPE;

      e_invalid_params        EXCEPTION;
      e_sob_not_found         EXCEPTION;
      e_fiscal_year_not_found EXCEPTION;
      l_current_org_id hr_operating_units.organization_id%type;

   BEGIN
      -- Validate input parameters
      IF pi_gl_date IS NULL
      THEN
         RAISE e_invalid_params;
      END IF;

      -- Get the set of books attached to the responsibility
      --FND_PROFILE.Get('GL_SET_OF_BKS_ID', l_sob_id);
      /*Bug#5905190 - MOAC changes start*/
      -- Get current org_id
      l_current_org_id := mo_global.get_current_org_id();
      IF l_current_org_id is NULL THEN
        l_sob_id := NULL;
      ELSE
        mo_utils.Get_Set_Of_Books_Info(l_current_org_id,l_sob_id,l_sob_name);
      END IF;

      /*Bug#5905190 end */

      IF l_sob_id IS NULL
      THEN
         RAISE e_sob_not_found;
      END IF;

      -- Get the fiscal year
      OPEN c_fiscal_year(l_sob_id);

      FETCH c_fiscal_year INTO po_fiscal_year;
      IF c_fiscal_year%NOTFOUND
      THEN
         RAISE e_fiscal_year_not_found;
      END IF;

      CLOSE c_fiscal_year;
   EXCEPTION
      WHEN e_invalid_params THEN
         po_fiscal_year := '';
         po_error_message := 'Error: Invalid parameters passed ('||
                             'GL Date:'||TO_CHAR(pi_gl_date)||')';

      WHEN e_sob_not_found THEN
         po_fiscal_year := '';
         po_error_message := 'Error: GL Set of Books not found ('||
                             'GL Date:'||TO_CHAR(pi_gl_date)||')';

      WHEN e_fiscal_year_not_found THEN
         IF c_fiscal_year%ISOPEN THEN
            CLOSE c_fiscal_year;
         END IF;

         po_fiscal_year := '';
         po_error_message := 'Error: GL Period Record not found ('||
                             'GL Date:'||TO_CHAR(pi_gl_date)||')';

      WHEN OTHERS THEN
         IF c_fiscal_year%ISOPEN THEN
            CLOSE c_fiscal_year;
         END IF;

         po_fiscal_year := '';
   --bug 3199481 fnd logging changes: sdixit: start block
   --as display of the error is being handled in the form that calls this package,
   -- just set the standard message here
          FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          po_error_message := FND_MESSAGE.GET;
   --bug 3199481 fnd logging changes: sdixit: end block
   --      po_error_message := 'Unknown Error Code: '||SQLCODE||
     --                        ' Error Message: '||SQLERRM;

   END Get_Fiscal_Year;

   --
   -- Procedure
   --    Ar_Complete
   -- History
   --   11-DEC-2001 A Smales    Initial Version
   --

   Procedure Ar_Complete (p_customer_trx  IN     NUMBER,
                          p_result        IN OUT NOCOPY NUMBER)
   IS

      v_count   NUMBER;
      v_status  fnd_product_installations.status%TYPE;
      v_source  VARCHAR2(50) ;
      v_next_pay  NUMBER ;
      l_debug_info    VARCHAR2(2000);

      CURSOR c_get_trx_info(p_trx_id  RA_CUSTOMER_TRX.CUSTOMER_TRX_ID%TYPE)
      IS
         SELECT trx.previous_customer_trx_id
         ,      trx.complete_flag
         ,      ctt.accounting_affect_flag
         ,      ctt.creation_sign
         ,      ctt.allow_overapplication_flag
         ,      ctt.natural_application_only_flag
         FROM   ra_customer_trx_all trx
         ,      ra_cust_trx_types_all ctt
         WHERE  trx.customer_trx_id = p_trx_id
         AND    trx.cust_trx_type_id = ctt.cust_trx_type_id
         AND    trx.org_id = ctt.org_id;

      l_previous_customer_trx_id    ra_customer_trx.previous_customer_trx_id%TYPE;
      l_complete_flag               ra_customer_trx.complete_flag%TYPE;
      l_trx_open_receivables_flag   ra_cust_trx_types.accounting_affect_flag%TYPE;
      l_creation_sign               ra_cust_trx_types.creation_sign%TYPE;
      l_allow_overapplication_flag  ra_cust_trx_types.allow_overapplication_flag%TYPE;
      l_natural_application_flag    ra_cust_trx_types.natural_application_only_flag%TYPE;
      p_error_message    VARCHAR2(2000);


      CURSOR c_get_prev_trx_info(p_trx_id RA_CUSTOMER_TRX.CUSTOMER_TRX_ID%TYPE)
      IS
         SELECT ctt.accounting_affect_flag
         FROM   ra_customer_trx_all trx
         ,      ra_cust_trx_types_all ctt
         WHERE  trx.customer_trx_id = p_trx_id
         AND    trx.cust_trx_type_id = ctt.cust_trx_type_id
         AND    trx.org_id = ctt.org_id;

      l_prev_open_receivables_flag  ra_cust_trx_types.accounting_affect_flag%TYPE;

      e_no_trx_info                 EXCEPTION;
      e_no_prev_trx_info            EXCEPTION;

   BEGIN
      v_count    := 0;
      v_source   := NULL;
      v_next_pay := NULL;
   -----------------------------
   l_debug_info := 'BEGIN ar_complete';
   --dbms_output.put_line(l_debug_info);
   ----------------------------------

      SELECT status
      INTO   v_status
      FROM   fnd_product_installations
      WHERE  application_id = 300;

   -----------------------------
   l_debug_info := 'v_status is: ';
   --dbms_output.put_line(l_debug_info||','||v_status);
   ----------------------------------

      FND_PROFILE.GET('SO_SOURCE_CODE',v_source);


   -----------------------------
   l_debug_info := ' FND_PROFILE.GET(SO_SOURCE_CODE is :';
   --dbms_output.put_line(l_debug_info||','||v_source);
   ----------------------------------

      v_count := 0;

      arp_trx_complete_chk.do_completion_checking(p_customer_trx,
                                                 v_source,
                                                 v_status,
                                                 v_count
                                                 );

   -----------------------------
   l_debug_info := 'open c_open_period';
   --dbms_output.put_line(l_debug_info);
   ----------------------------------
      IF  v_count = 0 THEN

   -----------------------------
   l_debug_info := ' v_count = 0';
   --dbms_output.put_line(l_debug_info);
   ----------------------------------
      UPDATE  ra_customer_trx
      SET       complete_flag = 'Y'
      WHERE     customer_trx_id = p_customer_trx;

   -----------------------------
   l_debug_info := 'UPDATE ra_customer_trx complete';
   --dbms_output.put_line(l_debug_info);
   ----------------------------------

      OPEN c_get_trx_info(p_customer_trx);
      FETCH c_get_trx_info INTO
      l_previous_customer_trx_id
      ,l_complete_flag
      ,l_trx_open_receivables_flag
      ,l_creation_sign
      ,l_allow_overapplication_flag
      ,l_natural_application_flag;

         IF c_get_trx_info%NOTFOUND THEN
            RAISE e_no_trx_info;
         END IF;
      CLOSE c_get_trx_info;


         IF l_previous_customer_trx_id is not null THEN
   -----------------------------
   l_debug_info := 'l_previous_customer_trx_id is : ';
   --dbms_output.put_line(l_debug_info||','||l_previous_customer_trx_id);
   ----------------------------------
         OPEN c_get_prev_trx_info(l_previous_customer_trx_id);
         FETCH c_get_prev_trx_info
         INTO l_prev_open_receivables_flag;

            IF c_get_prev_trx_info%NOTFOUND THEN
               RAISE e_no_prev_trx_info;
            END IF;
         CLOSE c_get_prev_trx_info;
         END IF; --l_previous_customer_trx_id is not null

   -----------------------------
   l_debug_info := 'doing arp_process_header.post_commit ';
   --dbms_output.put_line(l_debug_info);
   ----------------------------------

         arp_process_header.post_commit('IGIPEPDU',12.0
         ,p_customer_trx
         ,l_previous_customer_trx_id
         ,l_complete_flag
         ,l_trx_open_receivables_flag
         ,l_prev_open_receivables_flag
         ,l_creation_sign
         ,l_allow_overapplication_flag
         ,l_natural_application_flag
         ,NULL);

     p_result := 0; --success
      ELSE
    p_result := -5; -- failure
      END IF; -- v_count = 0

   -----------------------------
   l_debug_info := 'p_result is :';
   --dbms_output.put_line(l_debug_info||','|| p_result);
   ----------------------------------
   EXCEPTION

      WHEN e_no_trx_info THEN   p_result := -5;
         IF c_get_trx_info%ISOPEN THEN
            CLOSE c_get_trx_info;
         END IF;

      WHEN   e_no_prev_trx_info THEN   p_result := -5;
         IF c_get_prev_trx_info%ISOPEN THEN
            CLOSE c_get_prev_trx_info;
         END IF;

      WHEN OTHERS THEN
         p_result := -5;
         IF c_get_prev_trx_info%ISOPEN THEN
            CLOSE c_get_prev_trx_info;
         ELSIF c_get_trx_info%ISOPEN THEN
            CLOSE c_get_trx_info;
         END IF;

   --bug 3199481 fnd logging changes: sdixit: start block
   --as display of the error is being handled in the form that calls this package,
   -- just set the standard message here
          FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          p_error_message := FND_MESSAGE.GET;
   --bug 3199481 fnd logging changes: sdixit: end block
   --      p_error_message := 'Unknown Error Code: '||SQLCODE||
     --                       'Error Message: '||SQLERRM;
   END Ar_Complete;

   --
   -- Procedure
   --    ValidateGLDate
   -- History
   --   11-DEC-2001 A Smales    Initial Version
   --   Old logic
   --           Checks to see if the date passed is valid exists in an open period
   --           IF not checks if the date exists within the last open period
   --           IF not assigns date to sysdate
   --           IF p_app_id passed in is 200 then checks if encumbrance is on
   --           IF on checks if the period year is greater than the encumbrance year
   --           IF so, sets p_update_gl_date flag to 'N'
   --   8-APR-2003 SHSAXENA
   --   New logic
   /* =========================================================================================
   ##
   ##    By default p_gl_date is sysdate.
   ##
   ##    This logic is implemented based on the assumption that the fiscal year is as same as
   ##    the Calendar year
   ##
   ##    IF Current fiscal year = DU's fiscal year then,
   ##       IF p_gl_date falls with in the CURRENT period which is OPEN,
   ##          then p_gl_date (sysdate)  is returned.
   ##       IF p_gl_date falls with in the CURRENT period and the CURRENT period is not OPEN,
   ##          then pick up the latest open period of CURRENT fiscal year.
   ##               IF there is a latest OPEN Period
   ##                  then return the END DATE.
   ##               IF there are no OPEN period in the Current fiscal year
   ##                  then Raise exception.
   ##
   ##    IF Current fiscal year <> DU's fiscal year then,
   ##       Pick up the END DATE of previous fiscal year.
   ##       Check Whether the END DATE falls with in the OPEN period.
   ##         IF END DATE is with in the OPEN period then
   ##            return END DATE.
   ##         IF END DATE is not with in the OPEN period then
   ##            pickup the latest OPEN period of the Current fiscal year.
   ##            return the END DATE of the latest OPEN period.
   ##         IF there are no OPEN period in the CURRENT fiscal year
   ##            then  Raise Exception.
   ##
   ## ======================================================================================== */


   PROCEDURE ValidateGLDate(p_app_id          IN             VARCHAR2,
                            p_gl_date         IN OUT NOCOPY  DATE,
                            p_update_gl_date  OUT    NOCOPY  VARCHAR2,
                            p_du_id           IN             VARCHAR2) -- shsaxena Bug 2777575
    Is

       CURSOR c_get_encum_flag
       IS
          SELECT purch_encumbrance_flag
          FROM financials_system_parameters;

       CURSOR c_open_period(pv_sob_id gl_sets_of_books.set_of_books_id%TYPE,
                            pv_app_id igi_exp_du_type_headers.application_id%TYPE,
                            pv_gl_date  DATE)
       IS
          SELECT gps.period_year,
                 gsob.latest_encumbrance_year
          FROM   gl_period_statuses gps,
                 gl_sets_of_books gsob
          WHERE  gps.application_id = pv_app_id
          AND    gps.set_of_books_id = pv_sob_id
          AND    gps.set_of_books_id = gsob.set_of_books_id
          AND    trunc(pv_gl_date) BETWEEN trunc(gps.start_date) AND trunc(gps.end_date) --Bug5705031
          AND    gps.closing_status IN ('O', 'F')
          AND    NVL(gps.adjustment_period_flag, 'N') = 'N';

      CURSOR c_last_open_period(pv_sob_id gl_sets_of_books.set_of_books_id%TYPE,
                                pv_app_id igi_exp_du_type_headers.application_id%TYPE,
                                pv_period_year number)
      IS
         SELECT gps.period_year,
                gsob.latest_encumbrance_year,
                gps.end_date
         FROM   gl_period_statuses gps,
                gl_sets_of_books gsob
         WHERE  gps.application_id  = pv_app_id
         AND    gps.set_of_books_id = pv_sob_id
         AND    gps.set_of_books_id = gsob.set_of_books_id
         AND    gsob.latest_opened_period_name = gps.period_name
         AND    gps.period_year = pv_period_year;    -- shsaxena Bug 2777575.

      /*  shsaxena Bug 2777575 START */
     CURSOR Cur_current_fis_year (pv_sob_id gl_sets_of_books.set_of_books_id%TYPE,
                                  pv_app_id igi_exp_du_type_headers.application_id%TYPE,
                                  pv_gl_date  DATE)
     IS
          SELECT gps.period_year
          FROM   gl_period_statuses gps,
                 gl_sets_of_books gsob
          WHERE  gps.application_id  = pv_app_id
          AND    gps.set_of_books_id = pv_sob_id
          AND    gps.set_of_books_id = gsob.set_of_books_id
          AND    trunc(pv_gl_date) BETWEEN trunc(gps.start_date) AND trunc(gps.end_date);


      CURSOR Cur_prev_year_end_date (pv_sob_id      gl_sets_of_books.set_of_books_id%TYPE,
                                     pv_app_id      igi_exp_du_type_headers.application_id%TYPE,
                                     pv_period_year number)
      IS
         SELECT gps.end_date
         FROM   gl_period_statuses gps
         WHERE  gps.application_id  = pv_app_id
         AND    gps.set_of_books_id = pv_sob_id
         AND    gps.period_year     = pv_period_year
         AND    gps.period_num =
                (SELECT max(gps1.period_num) from gl_period_statuses gps1
                 WHERE  gps1.application_id  = pv_app_id
                 AND    gps1.set_of_books_id = pv_sob_id
                 AND    gps1.period_year     = pv_period_year);


      CURSOR Cur_du_fiscal_year (p_du_id NUMBER) IS
             SELECT du_fiscal_year from igi_exp_dus_v
             WHERE  du_id = p_du_id;

      l_current_fiscal_year      igi_exp_dus_v.du_fiscal_year%TYPE;
      l_du_fiscal_year           igi_exp_dus_v.du_fiscal_year%TYPE;
      /* shsaxena Bug 2777575 END */

      l_latest_encumbrance_year  gl_sets_of_books.latest_encumbrance_year%TYPE ;
      l_period_year              gl_period_statuses.period_year%TYPE ;
      l_purch_encumbrance_flag   financials_system_parameters.purch_encumbrance_flag%TYPE ;
      l_sob_id                   gl_sets_of_books.set_of_books_id%TYPE ;
      l_debug_info               VARCHAR2(2000);
      l_gl_date                  DATE;
      p_error_message            VARCHAR2(2000);

      NO_OPEN_PERIOD             Exception;  -- shsaxena Bug 2777575.

      l_sob_name gl_sets_of_books.name%TYPE;
      l_current_org_id hr_operating_units.organization_id%type;


   BEGIN

   p_update_gl_date := 'Y';

   -- get set of books id
   --fnd_profile.get('GL_SET_OF_BKS_ID', l_sob_id) ; -- commented for Bug 5905190

   /*Bug#5905190 - MOAC changes start*/
   -- Get current org_id
   l_current_org_id := mo_global.get_current_org_id();
   IF l_current_org_id is NULL THEN
     l_sob_id := NULL;
   ELSE
     mo_utils.Get_Set_Of_Books_Info(l_current_org_id,l_sob_id,l_sob_name);
   END IF;

   /*Bug#5905190 end */

   /* shsaxena Bug 2777575 START */
   -- Getting DU's fiscal year.
   OPEN  Cur_du_fiscal_year (p_du_id);
   FETCH Cur_du_fiscal_year INTO l_du_fiscal_year;
   CLOSE Cur_du_fiscal_year;

   -- Getting the current fiscal year.
   OPEN  Cur_current_fis_year (l_sob_id, p_app_id, p_gl_date);
   FETCH Cur_current_fis_year INTO l_current_fiscal_year;
   CLOSE Cur_current_fis_year;

   IF (l_current_fiscal_year = l_du_fiscal_year) THEN

      OPEN  c_open_period (l_sob_id, p_app_id, p_gl_date);
      FETCH c_open_period INTO l_period_year, l_latest_encumbrance_year;

      -- if current period is not open.
      IF (c_open_period%NOTFOUND) THEN
         CLOSE c_open_period;

         OPEN  c_last_open_period (l_sob_id, p_app_id, l_current_fiscal_year);
         FETCH c_last_open_period INTO l_period_year, l_latest_encumbrance_year, l_gl_date;

         -- if there is no latest open period for the current year.
         IF (c_last_open_period%NOTFOUND) THEN

            CLOSE  c_last_open_period;
            RAISE  NO_OPEN_PERIOD;                          -- Exception
         ELSE

            IF (c_last_open_period%ISOPEN) THEN
                CLOSE c_last_open_period;
            END IF;

            -- l_gl_date has the latest open period's end date.
            p_gl_date := l_gl_date;

         END IF;

      ELSE

         IF (c_open_period%ISOPEN) THEN
            CLOSE c_open_period;
         END IF;

         -- assign the current period's date .
         p_gl_date := TRUNC(sysdate);

      END IF;

  ELSE  -- if fiscal year and du's fiscal year is not same then

     -- Getting the end date of the previous fiscal year.
     OPEN  Cur_prev_year_end_date (l_sob_id, p_app_id, l_du_fiscal_year);
     FETCH Cur_prev_year_end_date INTO l_gl_date;
     CLOSE Cur_prev_year_end_date;

     -- checking whether the end date of the previous fiscal year is OPEN.
     OPEN  c_open_period (l_sob_id, p_app_id, l_gl_date);
     FETCH c_open_period INTO l_period_year, l_latest_encumbrance_year;

      -- if end date of the previous fiscal year does not fall with in the OPEN period.
      IF (c_open_period%NOTFOUND) THEN
         CLOSE c_open_period;

         -- Get the latest OPEN period of the current fiscal year.
         OPEN  c_last_open_period (l_sob_id, p_app_id, l_current_fiscal_year);
         FETCH c_last_open_period INTO l_period_year, l_latest_encumbrance_year, l_gl_date;

         -- if there is no latest open period for the current year.
         IF (c_last_open_period%NOTFOUND) THEN

            CLOSE  c_last_open_period;
            RAISE  NO_OPEN_PERIOD;                      -- Exception

         ELSE

            IF (c_last_open_period%ISOPEN) THEN
                CLOSE c_last_open_period;
            END IF;

            -- l_gl_date has the latest open period's end date.
            p_gl_date := l_gl_date;

         END IF;

     ELSE    -- then set the end date of the previous fiscal year's OPEN period.

         IF (c_last_open_period%ISOPEN) THEN
            CLOSE c_last_open_period;
         END IF;

         -- assign 31-DEC to p_gl_date.
         p_gl_date := l_gl_date;

     END IF;
  END IF;
  /* Shsaxena Bug 2777575 END */

   IF p_app_id = 200 THEN -- check encumbrance for AP gl_date

   ----------------------------------------------------
   -- Get the period year for l_gl_date
   ----------------------------------------------------

      OPEN c_get_encum_flag ;
      FETCH c_get_encum_flag INTO l_purch_encumbrance_flag ;
      CLOSE c_get_encum_flag ;

   ------------------------------------------------------------
   -- If encumbrance is on, check that the GL date to be is not
   -- in a period_year beyond the latest encumbrance year.
   ------------------------------------------------------------

      IF ( NVL(l_purch_encumbrance_flag, 'N') = 'Y') THEN
         IF TO_NUMBER(l_period_year) > TO_NUMBER(l_latest_encumbrance_year) THEN
            p_update_gl_date:= 'N';    -- update gl_date for AP doc's set to No
         END IF;                       --GL date is not in a period_year beyond the latest encumberance year
      END IF;                          -- if purchasing encumberance is on
   END IF;                             --p_app_id = 200

  EXCEPTION
      WHEN NO_OPEN_PERIOD THEN   -- shsaxena Bug 2777575
         p_gl_date := NULL;

      WHEN OTHERS THEN
         IF c_get_encum_flag%ISOPEN THEN
            CLOSE c_get_encum_flag ;
         END IF ;
         IF c_open_period%ISOPEN THEN
            CLOSE c_open_period ;
         END IF ;
         IF c_last_open_period%ISOPEN THEN
            CLOSE c_last_open_period ;
         END IF;

   --bug 3199481 fnd logging changes: sdixit: start block
   --as display of the error is being handled in the form that calls this package,
   -- just set the standard message here
          FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          p_error_message := FND_MESSAGE.GET;
   --bug 3199481 fnd logging changes: sdixit: end block
   --      p_error_message := 'Unknown Error Code: '||SQLCODE||
     --                       ' Error Message: '||SQLERRM;
   END ValidateGLDate ;

   --
   -- Procedure
   --    CompleteDU
   -- History
   --   11-DEC-2001 A Smales    Initial Version
   --


   PROCEDURE Complete_Du(p_du_id           IN     NUMBER,
                         p_app_id          IN     NUMBER,
                         p_gl_date         IN OUT NOCOPY DATE,
                         p_error_message   IN OUT NOCOPY VARCHAR2,
                         p_trx_id          OUT NOCOPY    NUMBER
                         )
   IS

      l_dummy          NUMBER;
      l_ar_trans       NUMBER;
      l_ap_trans       NUMBER;
      l_gl_date        DATE;
      l_update_gl_date VARCHAR2(1);
      p_result         NUMBER;
      l_debug_info     VARCHAR2(2000);
      l_gl_date        DATE;
      l_trx_id         NUMBER;

      CURSOR c_ap_invoices(pv_du_id  igi_exp_dus_all.du_id%TYPE)
      IS
         SELECT a.invoice_id,
                a.source,
                a.cancelled_date,
                a.gl_date                   -- shsaxena bug2777575.
         FROM   igi_exp_ap_trans i,
                ap_invoices_all a
         WHERE  i.invoice_id               = a.invoice_id
         AND    i.du_id                    = pv_du_id;

     CURSOR c_ar_trx(pv_du_id igi_exp_dus_all.du_id%TYPE)
     IS
        SELECT rct.customer_trx_id
        ,      rct.trx_number
        ,      rctt.name
        ,      arl.meaning
        FROM   ra_customer_trx_all rct
        ,      igi_exp_ar_trans i
        ,      ar_lookups arl
        ,      ra_cust_trx_types_all rctt
        WHERE  i.du_id                = pv_du_id
        AND    rct.customer_trx_id    = i.customer_trx_id
        AND    rctt.cust_trx_type_id  = rct.cust_trx_type_id
        AND    rctt.org_id            = rct.org_id
        AND    arl.lookup_code        = rct.status_trx
        AND    arl.lookup_type        ='INVOICE_TRX_STATUS' ;

      e_no_open_gl_date         EXCEPTION;  -- shsaxena bug.2777575
      e_null_param              EXCEPTION;
      e_invalid_p_du_id         EXCEPTION;
      e_ar_trans                EXCEPTION;
      e_ap_trans                EXCEPTION;
      e_invalid_p_app_id        EXCEPTION;
      e_ar_complete_flag_failed EXCEPTION;

   BEGIN
      l_dummy          := 0;
      l_ar_trans       := 0;
      l_ap_trans       := 0;
      p_result         := 0;
     ------------------------------------------------
     -- Validate passed parameter values
     -- check for NULL
     ------------------------------------------------
      IF p_du_id   IS NULL THEN -- null p_du_id
         RAISE e_null_param  ;
      END IF;

      IF p_app_id  IS NULL THEN -- null p_app_id
         RAISE e_null_param  ;
      END IF;
     ------------------------------------------------
     -- Validate passed parameter values
     -- check for Valid/Invalid p_du_id
     ------------------------------------------------
   -----------------------------
   l_debug_info := 'check valid du';
   --dbms_output.put_line(l_debug_info);
   ----------------------------------
      SELECT COUNT(1)
      INTO l_dummy
      FROM igi_exp_dus
      WHERE du_id = p_du_id;

      IF l_dummy = 0 THEN -- invalid p_du_id
         RAISE e_invalid_p_du_id;
      ELSE -- valid p_du_id

     ------------------------------------------------------
     --  Call Procedure ValidateGLDate to check GL Date
     -------------------------------------------------------
   -----------------------------
   l_debug_info := 'check gl_dates';
   --dbms_output.put_line(l_debug_info);
   ----------------------------------


      ValidateGLDate(p_app_id,
                     p_gl_date,
                     l_update_gl_date,
                     p_du_id);   --  shsaxena Bug 2777575.

      --  shsaxena Bug 2777575.
      -- checking for a valid date in p_gl_date.
      IF (p_gl_date is NULL) THEN
         Raise e_no_open_gl_date;
      END IF;


   -----------------------------
   l_debug_info := 'p_gl_date = ';
   --dbms_output.put_line(l_debug_info||','||p_gl_date);
   ----------------------------------
   -----------------------------
   l_debug_info := 'l_update_gl_date = ';
   --dbms_output.put_line('l_update_gl_date : '||l_update_gl_date);
   ----------------------------------
     ------------------------------------------------
     -- Validate passed parameter values
     -- check for Valid/Invalid p_app_id
     ------------------------------------------------

   -----------------------------
   l_debug_info := 'check valid p_app_id';
   --dbms_output.put_line(l_debug_info||' '||p_app_id );
   ----------------------------------
         IF p_app_id = 200 THEN  -- this is a AP Dialog Unit

     -------------------------------------------------------
     -- Check the documents contained within the Dialog Unit
     -- are all within the igi_exp_ap_trans table
     -------------------------------------------------------
   -----------------------------
   l_debug_info := 'p_app_id = 200';
   --dbms_output.put_line(l_debug_info);
   ----------------------------------
         SELECT COUNT(1)
         INTO l_ar_trans
         FROM igi_exp_ar_trans_all
         WHERE du_id = p_du_id;

            IF l_ar_trans > 0 THEN -- there are AR transactions within the AP Dialog unit
               RAISE e_ar_trans;
            ELSE

   -----------------------------
   l_debug_info := 'check for ar trans in ap du ';
   --dbms_output.put_line(l_debug_info);
   ----------------------------------
     -----------------------------------------------
     -- only AP documents within the AP Dialog Unit
     -- Dialog unit exists within igi_exp_dus
     -- p_app_id is 200
     --
     -- Loop through invoices in Dialog Unit
     --   1. Release the EXP hold for all invoices within the
     --      Dialog Unit
     --   2. Update the GL date
     -------------------------------------------------------

            FOR r_ap_invoices IN c_ap_invoices(p_du_id)LOOP
   -----------------------------
   l_debug_info := 'in ap loop';
   --dbms_output.put_line(l_debug_info);
   ----------------------------------
     --------------------------------------------------------
     --   1. Release the EXP hold for this invoice
     --------------------------------------------------------
   -----------------------------
   l_debug_info := 'release holds';
   --dbms_output.put_line(l_debug_info);
   ----------------------------------

            IGI_EXP_HOLDS.Place_Release_Hold(r_ap_invoices.invoice_id,
                                             '', -- invoice amount Bug 2469158
                                             r_ap_invoices.source,
                                             r_ap_invoices.cancelled_date,
                                             'R',
                                             'AWAIT EXP APP',
                                             'IGI EXP WORKFLOW'
                                             );

     --------------------------------------------------------------------
     --  2. If l_update_gl_date = 'Y' Update the GL Date for this invoice
     --------------------------------------------------------------------

               IF l_update_gl_date = 'Y' THEN

                  /* shsaxena bug.2777575 START */

                  UPDATE ap_invoice_distributions apd
                  SET    apd.accounting_date    = TRUNC(p_gl_date),
                         apd.last_update_login  = NVL(fnd_profile.value('LOGIN_ID'),-1),
                         apd.last_update_date   = SYSDATE,
                         apd.last_updated_by    = NVL(fnd_profile.value('USER_ID'),-1)
                  WHERE  apd.invoice_id       = r_ap_invoices.invoice_id
                  AND    apd.posted_flag      = 'N';


                  /* dvjoshi bug#5905190 START

                  UPDATE ap_invoice_lines apl
                  SET    apl.gl_date            = TRUNC(p_gl_date),
                         apl.last_update_login  = NVL(fnd_profile.value('LOGIN_ID'),-1),
                         apl.last_update_date   = SYSDATE,
                         apl.last_updated_by    = NVL(fnd_profile.value('USER_ID'),-1)
                  WHERE  apl.invoice_id       = r_ap_invoices.invoice_id
                  AND    EXISTS
                         (SELECT 'x' FROM ap_invoice_distributions aid
                          WHERE aid.invoice_id = apl.invoice_id
                          AND   aid.posted_flag = 'N');

                  dvjoshi bug#5905190 END */

                  UPDATE ap_invoices api
                  SET    api.gl_date            = TRUNC(p_gl_date),
                         api.last_update_login  = NVL(fnd_profile.value('LOGIN_ID'),-1),
                         api.last_update_date   = SYSDATE,
                         api.last_updated_by    = NVL(fnd_profile.value('USER_ID'),-1)
                  WHERE  api.invoice_id       = r_ap_invoices.invoice_id
                  AND    EXISTS
                         (SELECT 'x' FROM ap_invoice_distributions aid
                          WHERE aid.invoice_id = api.invoice_id
                          AND   aid.posted_flag = 'N');

                  /* shsaxena bug.2777575 END */

               END IF; --l_update_gl_date = 'Y'

            END LOOP;
            END IF; -- there are AR transactions within the AP Dialog unit


         ELSIF p_app_id = 222 THEN -- this is an AR Dialog Unit
     -------------------------------------------------------
     -- Check the documents contained within the Dialog Unit
     -- are all within the igi_exp_ar_trans table
     -------------------------------------------------------
         SELECT COUNT(1)
         INTO l_ap_trans
         FROM igi_exp_ap_trans
         WHERE du_id = p_du_id;

            IF l_ap_trans > 0 THEN -- there are AP transactions within the AR Dialog unit
               RAISE e_ap_trans;
            ELSE
     -----------------------------------------------
     -- only AR documents within the AR Dialog Unit
     -- Dialog unit exists within igi_exp_dus
     -- p_app_id is 222
     --
     -- Loop through AR transactions in the Dialog Unit
     --   1. Update the complete flag
     --   2. Update the GL date
     -------------------------------------------------------

            FOR r_ar_trx IN c_ar_trx(p_du_id)LOOP

     -------------------------------------------------------
     --   1. Update the complete flag for this transaction
     -------------------------------------------------------
            Ar_Complete(r_ar_trx.customer_trx_id,
                        p_result);
   -----------------------------
   l_debug_info := 'P_result is ';
   --dbms_output.put_line(l_debug_info||' '||p_result);
   ----------------------------------

               IF p_result = -5 THEN
                  l_trx_id :=r_ar_trx.customer_trx_id;
                  RAISE e_ar_complete_flag_failed;
               END IF;

     -------------------------------------------------------
     --  2. Update the GL Date for this transaction
     -------------------------------------------------------

               /* shsaxena bug.2777575 START */

                  UPDATE ra_cust_trx_line_gl_dist rgd
                  SET   rgd.gl_date               = TRUNC(p_gl_date),
                        rgd.last_update_login     = NVL(fnd_profile.value('LOGIN_ID'),-1),
                        rgd.last_update_date      = SYSDATE,
                        rgd.last_updated_by       = NVL(fnd_profile.value('USER_ID'),-1)
                  WHERE rgd.customer_trx_id = r_ar_trx.customer_trx_id
                  AND   rgd.gl_posted_date IS NULL;

                  UPDATE ra_customer_trx rct
                  SET   rct.trx_date              = TRUNC(p_gl_date),
                        rct.last_update_login     = NVL(fnd_profile.value('LOGIN_ID'),-1),
                        rct.last_update_date      = SYSDATE,
                        rct.last_updated_by       = NVL(fnd_profile.value('USER_ID'),-1)
                  WHERE rct.customer_trx_id = r_ar_trx.customer_trx_id
                  AND   EXISTS
                        (SELECT 'x' FROM ra_cust_trx_line_gl_dist rgd
                         WHERE  rgd.customer_trx_id = rct.customer_trx_id
                         AND    rgd.gl_posted_date IS NULL);

               /* shsaxena bug.2777575 END */

            END LOOP;
            END IF; -- there are AP doc's in this AR dialog unit
         ELSE -- this is an invalid application id
            RAISE e_invalid_p_app_id;
         END IF; -- this is an invalid application id
      END IF; --l_dummy =0

      p_error_message:= 'Success' ;

   EXCEPTION
      WHEN e_no_open_gl_date THEN     -- shsaxena bug.2777575.
         p_error_message  := 'Error: There is no Open GL date for the current fiscal year.' ||
                             'Please Open the GL period and Approve the DU. ';

      WHEN e_null_param   THEN
         p_error_message := 'Error: Parameter was passed was null p_du_id: '||TO_CHAR(p_du_id)||
                            ' p_app_id: '||TO_CHAR(p_app_id);


      WHEN e_invalid_p_du_id THEN
         p_error_message := 'Error: Parameter p_du_id '||TO_CHAR(p_du_id) ||
                                ' does not exist within the table igi_exp_dus.'||
                                ' This is an invalid Dialog Unit';

      WHEN e_ar_trans THEN
         p_trx_id :=l_trx_id;
         p_error_message := 'Error: The dialog unit has an application_id of 200, indicating that '||
                            'the dialog unit contains only AP document.  However, there is an AR '||
                            'transaction held within this dialog unit';

      WHEN e_ap_trans THEN
         p_error_message := 'Error: The dialog unit has an application_id of 222, indicating '||
                                'that the dialog unit contains only AR document.  However, there is '||
                                'an AP transaction held within this dialog unit';

      WHEN e_ar_complete_flag_failed THEN
         p_trx_id :=l_trx_id;
         IF c_ar_trx%ISOPEN THEN
            CLOSE c_ar_trx;
         END IF;

         p_error_message := 'Error: The procedure ar_complete within package igi_exp_complete_du '||
                            'did not complete successfully. The customer_trx_id: ' || l_trx_id||
                            ' has not been completed and the gl date has not been updated';


      WHEN e_invalid_p_app_id THEN

         p_error_message := 'Error: The p_app_id is not 200 or 222 and therefore is invalid.';


      WHEN OTHERS THEN

         IF c_ap_invoices%ISOPEN THEN
            CLOSE c_ap_invoices;
         ELSIF c_ar_trx%ISOPEN THEN
            CLOSE c_ar_trx;
         END IF;

         --dbms_output.put_line('in OTHERS exception');
   --bug 3199481 fnd logging changes: sdixit: start block
   --as display of the error is being handled in the form that calls this package,
   -- just set the standard message here
          FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          p_error_message := FND_MESSAGE.GET;
   --bug 3199481 fnd logging changes: sdixit: end block
   --       p_error_message := 'Unknown Error Code: '||SQLCODE||
     --                        ' Error Message: '||SQLERRM;

   END Complete_Du;

END igi_exp_utils;

/
