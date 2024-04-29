--------------------------------------------------------
--  DDL for Package Body JAI_CMN_RGM_TERMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_CMN_RGM_TERMS_PKG" AS
/* $Header: jai_cmn_rgm_term.plb 120.1.12010000.4 2010/03/26 09:46:28 erma ship $ */

/* --------------------------------------------------------------------------------------
Filename:

Change History:

Date         Bug         Remarks
---------    ----------  -------------------------------------------------------------
08-Jun-2005  Version 116.2 jai_cmn_rgm_term -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
    as required for CASE COMPLAINCE.

14-Jun-2005   rchandan for bug#4428980, Version 116.3
              Modified the object to remove literals from DML statements and CURSORS.
09-Jul-2009   CSahoo for bug#8667768, File Version 120.1.12000000.2
              added code in the procedure jai_cmn_rgm_terms_pkg.generate_term_schedules to to
              calculate claim dates for the option "first day of financial year".

20-Mar-2010		Bo Li for the Flexible VAT Recovery Schedule
              This ER is to enhance the existing recovery of VAT Taxes in multiple installments in more generic scenarios.

*/

/***************************************************************************************************
CREATED BY       : rallamse
CREATED DATE     : 25-FEB-2005
ENHANCEMENT BUG  :
PURPOSE          : To provide and process claim term information
CALLED FROM      :

***************************************************************************************************/

/**************************************************
|| Generate the instalment date
|| Private procedure
***************************************************/
PROCEDURE set_date
                 (
                   pn_interval_days    IN            NUMBER ,
                   pn_interval_months  IN            NUMBER ,
                   pd_date             IN OUT NOCOPY DATE
                 )
IS

  ln_last_day  NUMBER ;
  ln_day       NUMBER ;

  /* Added by Ramananda for bug#4407165 */
  lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_rgm_terms_pkg.set_date';


BEGIN

  pd_date := add_months ( pd_date , pn_interval_months ) ;

  ln_last_day := to_number ( to_char ( LAST_DAY ( pd_date ) , 'DD' ) ) ;

  IF pn_interval_days > ln_last_day THEN

    ln_day := ln_last_day ;

  ELSE

    ln_day := pn_interval_days ;

  END IF ;

  pd_date := pd_date + ln_day - to_number ( to_char ( pd_date , 'DD' ) ) ;


   /* Added by Ramananda for bug#4407165 */
    EXCEPTION
     WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      app_exception.raise_exception;

END set_date ;


/**************************************************
|| Insert values into jai_rgm_trm_schedules_t
|| Private procedure
***************************************************/

PROCEDURE insert_jai_rgm_trm_schedules_t
                                       (
                                         pn_schedule_id     IN  JAI_RGM_TRM_SCHEDULES_T.SCHEDULE_ID%TYPE        ,
                                         pn_instalment_no   IN  JAI_RGM_TRM_SCHEDULES_T.INSTALLMENT_NO%TYPE     ,
                                         pn_instalment_amt  IN  JAI_RGM_TRM_SCHEDULES_T.INSTALLMENT_AMOUNT%TYPE ,
                                         pd_instalment_date IN  JAI_RGM_TRM_SCHEDULES_T.INSTALLMENT_DATE%TYPE
                                       )
IS

  /* Added by Ramananda for bug#4407165 */
  lv_object_name CONSTANT VARCHAR2(61) := 'jai_cmn_rgm_terms_pkg.insert_jai_rgm_trm_schedules_t';

BEGIN

  INSERT INTO jai_rgm_trm_schedules_t
  (
    SCHEDULE_ID         ,
    INSTALLMENT_NO      ,
    INSTALLMENT_AMOUNT  ,
    INSTALLMENT_DATE    ,
    CREATION_DATE       ,
    CREATED_BY          ,
    LAST_UPDATE_DATE    ,
    LAST_UPDATE_LOGIN   ,
    LAST_UPDATED_BY
  )
  VALUES
  (
    pn_schedule_id      ,
    pn_instalment_no    ,
    pn_instalment_amt   ,
    pd_instalment_date  ,
    SYSDATE             ,
    999999              ,
    SYSDATE             ,
    NULL                ,
    NULL
  ) ;
  /* Added by Ramananda for bug#4407165 */
    EXCEPTION
     WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('JA','JAI_EXCEPTION_OCCURED');
      FND_MESSAGE.SET_TOKEN('JAI_PROCESS_MSG', lv_object_name ||'. Err:'||sqlerrm );
      app_exception.raise_exception;

END insert_jai_rgm_trm_schedules_t ;

/**************************************************
|| Generate the payment schedule based upon
|| the term defined
***************************************************/
PROCEDURE generate_term_schedules
                               (
                                p_term_id       IN          JAI_RGM_TERMS.TERM_ID%TYPE                ,
                                p_amount        IN          NUMBER                                    ,
                                p_register_date IN          DATE                                      ,
                                p_schedule_id   OUT NOCOPY  JAI_RGM_TRM_SCHEDULES_T.SCHEDULE_ID%TYPE  ,
                                p_process_flag  OUT NOCOPY  VARCHAR2                                  ,
                                p_process_msg   OUT NOCOPY  VARCHAR2
                               )
IS

  --added by eric ma for VAT FLEX RECOVERY (Bug9494633)on Mar-09-2010,Begin
  -----------------------------------------------------------------------------
    CURSOR  cur_term_details ( pn_rgm_term_id NUMBER )
  IS
	  SELECT
      rgtm.term_id
    , rgtm.number_of_instalments
    , rgci.installment_number
    , rgci.claim_interval
    , rgci.day_of_claim
    , rgci.month_of_claim
    , rgci.day_of_month
    , rgci.claim_percentage
	  FROM
      jai_rgm_terms                 rgtm
    , jai_rgm_term_installments     rgci
	  WHERE rgtm.term_id = rgci.term_id
      AND rgtm.term_id = pn_rgm_term_id
    ORDER BY installment_number;
  -----------------------------------------------------------------------------
  --added by eric ma for VAT FLEX RECOVERY (Bug9494633)on Mar-09-2010,End

  CURSOR cur_sequence
  IS
  SELECT
         jai_rgm_trm_schedules_t_s.nextval
  FROM
         dual ;

  --added by eric ma for VAT FLEX RECOVERY (Bug9494633) on Mar-09-2010,Begin
  -----------------------------------------------------------------------------
  ln_installment_amount       NUMBER;
  ln_total_installment_amount NUMBER;
  ln_installment_number       NUMBER;
  ln_number_of_instalments    NUMBER;
  ld_register_date            DATE;
  ld_installment_date         DATE;
  lv_FIRST_DAY_OF_FISCAL_YEAR VARCHAR(20) :='01-APR-';
  lv_LAST_DAY_OF_FISCAL_YEAR  VARCHAR(20) :='31-MAR-';

  ln_rem_months_to_curr_qrtr NUMBER;
  ln_current_qrtr            NUMBER;
  ln_current_fiscal_year     NUMBER;
  ln_next_fiscal_year        NUMBER;
  ln_current_month           NUMBER;
  ln_month_number            NUMBER;
  ln_specify_qrtr            NUMBER;
  lv_month_of_claim          VARCHAR2(10);
  -----------------------------------------------------------------------------
  --added by eric ma for VAT FLEX RECOVERY (Bug9494633) on Mar-09-2010,End

  /*
  || Declare the rows to be extracted from table
  || based upon cursor
  */
  lv_start_period       JAI_RGM_TERMS.start_period          %TYPE ;
  lv_no_of_instalments  JAI_RGM_TERMS.number_of_instalments %TYPE ;
  lv_instalment_freq    JAI_RGM_TERMS.instalment_frequency  %TYPE ;
  lv_instalment_period  JAI_RGM_TERMS.instalment_period     %TYPE ;
  ln_day_of_month       JAI_RGM_TERMS.day_of_month          %TYPE ;
  lv_frequency_day      JAI_RGM_TERMS.frequency_day         %TYPE ;
  lv_st_day_of_month    JAI_RGM_TERMS.start_day_of_month    %TYPE ;
  lv_st_frequency_day    JAI_RGM_TERMS.start_frequency_day   %TYPE ;

  ln_instalment_amt     JAI_RGM_TRM_SCHEDULES_T.INSTALLMENT_AMOUNT%TYPE ;  /* Amount for each instalment       */
  ld_start_date         JAI_RGM_TRM_SCHEDULES_T.INSTALLMENT_DATE%TYPE ;    /* Stores date for 1st instalment   */
  ld_next_date          JAI_RGM_TRM_SCHEDULES_T.INSTALLMENT_DATE%TYPE ;    /* Date for subsequenct instalments */

  ln_interval_months        NUMBER ; /* Based upon instalment_period        */
  ln_st_interval_days       NUMBER ; /* Based upon st_instalment_perio      */
  ln_start_interval_months  NUMBER ; /* Interval based upon start period    */
  ln_interval_days          NUMBER ; /* Interval based upon frequency_day   */
  ln_start_date_month       NUMBER ; /* Month of the Instalment start date  */
  ln_start_date_year        NUMBER ; /* Year of the Instalment start date   */
BEGIN

    /*
    || Validate the input parameters term_id and amount
    */

    IF NVL(p_term_id,0) = 0  THEN

      p_process_flag := jai_constants.expected_error;
      p_process_msg  := 'jai_rgm_claims_pkg.prepare_term_schedules => Term Id cannot be NULL' ;
      return;

    END IF;

    IF NVL(p_amount,-1) <= 0  THEN

      p_process_flag := jai_constants.expected_error;
      p_process_msg  := 'jai_rgm_claims_pkg.prepare_term_schedules => Amount should not be NULL or Zero or Negative' ;
      return;

    END IF ;

    --added by eric ma for VAT FLEX RECOVERY (Bug9494633) on Mar-09-2010,Begin
  -----------------------------------------------------------------------------
   ld_register_date := TRUNC(p_register_date);

      OPEN   cur_sequence ;
      FETCH  cur_sequence INTO p_schedule_id ;
      CLOSE  cur_sequence ;

   FOR rec_cur_term_details  IN cur_term_details(p_term_id)
    LOOP

      ln_installment_number     := rec_cur_term_details.installment_number;
      ln_number_of_instalments  := rec_cur_term_details.number_of_instalments;


      ln_installment_amount := p_amount * (rec_cur_term_details.claim_percentage/100);

      IF (rec_cur_term_details.claim_interval = 'IMMEDIATE')
      THEN
        ld_installment_date := ld_register_date;
      ELSIF (rec_cur_term_details.claim_interval = 'NEXT_MONTH')
      THEN
        IF rec_cur_term_details.day_of_claim = 'SAME_DAY'
        THEN
          --There are 2 cases
          --1) current day of month does not exists in next month.
          -- E.g: current day = Jan-30, Feb-30 is not validated.
          --2) current day of month exists in next month.
          -- E.g: current day = Feb-29, Mar-29 is reasonalbe

          ld_installment_date := ADD_MONTHS(ld_register_date,1);

          --If the ld_register_date is the last day of the month,
          --add_months(,1)will return the last day of next month. e.g Feb-28 , next_month = Mar-31
          --To avoid this bug, add the below logic comparing the current day of month
          --with the max days of next month,
          IF EXTRACT(DAY FROM ld_register_date)< EXTRACT(DAY FROM ADD_MONTHS(ld_register_date,1))
          THEN
            ld_installment_date := TO_DATE( EXTRACT(DAY   FROM ld_register_date   )||'-'||
                                            EXTRACT(MONTH FROM ld_installment_date)||'-'||
                                            EXTRACT(YEAR  FROM ld_installment_date)
                                          , 'DD-MM-YYYY'
                                          );
          END IF;
        ELSIF rec_cur_term_details.day_of_claim = 'FIRST_DAY'
        THEN
          ld_installment_date := last_day(ld_register_date)+1;
        ELSIF rec_cur_term_details.day_of_claim = 'LAST_DAY'
        THEN
          ld_installment_date := last_day(add_months(ld_register_date, 1));
        ELSIF rec_cur_term_details.day_of_claim = 'OTHER_DAY'
        THEN
          -- there are 2 cases:
          -- 1)specified other day >= last day of next month , use the last day of next month
          -- 2)specified other day <  last day of next month , use the specified day of next month


          --Get the last_day of next month
          --Handle case 1:
          --IF the specified  day >= last_day of next month,use the last_day of next month
          ld_installment_date :=  last_day(add_months(ld_register_date, 1));

          --Handle case 2:
          --If the specified  day < max days of next month , use the specified day
          IF(rec_cur_term_details.day_of_month < EXTRACT(DAY FROM ld_installment_date))
          THEN
            ld_installment_date := TO_DATE( rec_cur_term_details.day_of_month      ||'-'||
                                            EXTRACT(MONTH FROM ld_installment_date)||'-'||
                                            EXTRACT(YEAR  FROM ld_installment_date)
                                          , 'DD-MM-YYYY'
                                          );
          END IF;--(rec_cur_term_details.day_of_month < EXTRACT(DAY FROM ld_installment_date))
        END IF; --(rec_cur_term_details.day_of_claim = 'SAME_DAY' )

      ELSIF (rec_cur_term_details.claim_interval = 'NEXT_QRTR')
      THEN
        --get the reminder months to current quarter = 3- (month- (quater-1)*3)
        --EXTRACT(MONTH FROM ld_register_date) is used for getting current month
        --TO_NUMBER(TO_CHAR(ld_register_date,'Q') is used for getting current quarter
        ln_rem_months_to_curr_qrtr:= 3*(TO_NUMBER(TO_CHAR(ld_register_date,'Q')))-(EXTRACT(MONTH FROM ld_register_date));


        IF (rec_cur_term_details.day_of_claim = 'FIRST_DAY')
        THEN
          --first day of next quarter = last_day of this quarter +1
          ld_installment_date := last_day(add_months(ld_register_date,ln_rem_months_to_curr_qrtr))+1;
        ELSIF (rec_cur_term_details.day_of_claim = 'LAST_DAY')
        THEN
          --ln_rem_months_to_curr_qrtr +3 = last month of next quarter
          ld_installment_date := last_day(add_months(ld_register_date,ln_rem_months_to_curr_qrtr+3));
        END IF; --(rec_cur_term_details.day_of_claim = 'FIRST_DAY')

      ELSIF (rec_cur_term_details.claim_interval = 'NEXT_FIN_YEAR')
      THEN
        --If the register day in the first quarter , the fiscal_year= current year -1,
        --else fiscal_year= current year

        --get the quarter number
        ln_current_qrtr:= TO_NUMBER(TO_CHAR(ld_register_date,'Q'));

        --calc the fiscal year
        IF (ln_current_qrtr > 1)
        THEN
          ln_current_fiscal_year := EXTRACT(YEAR FROM ld_register_date);
        ELSE
          ln_current_fiscal_year := EXTRACT(YEAR FROM ld_register_date) -1;
        END IF;

        --calc the next fiscal year
        ln_next_fiscal_year := ln_current_fiscal_year+1;

        --first day of fiscal year = "APR-01-"|| fiscal_year ,
        --last day of  fiscal year = "MAR-31-"|| (fiscal_year+1)
        --same day of  fiscal year
        --1) same day exist in the next fiscal year
        --2) same day does not exist in the next fiscal year

        IF (rec_cur_term_details.day_of_claim = 'FIRST_DAY')
        THEN
          ld_installment_date := TO_DATE(lv_FIRST_DAY_OF_FISCAL_YEAR || TO_CHAR(ln_next_fiscal_year)  ,'DD-MM-YYYY');
        ELSIF (rec_cur_term_details.day_of_claim = 'LAST_DAY')
        THEN
          ld_installment_date := TO_DATE(lv_LAST_DAY_OF_FISCAL_YEAR  || TO_CHAR(ln_next_fiscal_year+1),'DD-MM-YYYY');
        ELSIF (rec_cur_term_details.day_of_claim = 'SAME_DAY')
        THEN
          --get the same day of next month
          ld_installment_date := ADD_MONTHS(ld_register_date,12);

          --If the ld_register_date is the last day of the month,
          --add_months(,12)will return the last day of next year. e.g Feb-28 , next_year_same day = Feb-29 (year is leap year)
          --To avoid this bug, add the below logic comparing the current day of month
          --with the max days of next year,
          IF EXTRACT(DAY FROM ld_register_date)< EXTRACT(DAY FROM ADD_MONTHS(ld_register_date,12))
          THEN
            ld_installment_date := TO_DATE( EXTRACT(DAY   FROM ld_register_date   )||'-'||
                                            EXTRACT(MONTH FROM ld_installment_date)||'-'||
                                            EXTRACT(YEAR  FROM ld_installment_date)
                                          , 'DD-MM-YYYY'
                                          );
          END IF;

        ELSIF (rec_cur_term_details.day_of_claim = 'OTHER_DAY')
        THEN
          --check the specify day is in the first quarter or not
          --if it is in the fist quarter  then  next calendar year :=next fiscal year+1
          --else  next calendar year :=next fiscal year
          IF rec_cur_term_details.month_of_claim = 'OTH'
          THEN
           ln_specify_qrtr := to_number(to_char(ld_register_date,'Q'));
          ELSE
           ln_specify_qrtr := to_number(to_char(to_date(rec_cur_term_details.month_of_claim,'MM'),'Q'));
          END IF;

          -- calc the next fiscal calendar year
          -- If the specific month is in the first quarter,
          -- the calendar year of next financial year is equal to ln_next_fiscal_year +1
          -- in this situation we calculate the calendar year of next fiscal year
          IF (ln_specify_qrtr = 1)
          THEN
            ln_next_fiscal_year := ln_next_fiscal_year+1;
          END IF;

          -- Get the speicify month
          IF rec_cur_term_details.month_of_claim = 'OTH'
          THEN
           lv_month_of_claim := to_char(ld_register_date,'MON');
          ELSE
           lv_month_of_claim := rec_cur_term_details.month_of_claim;
          END IF;

          -- If the sepcific the day of month is greater than the last day of sepcific month
          -- get the last day of sepcific month in the next fiscal year
          IF (EXTRACT(DAY FROM last_day(to_date(lv_month_of_claim||'-'||ln_next_fiscal_year,'MM-YYYY')))
             < rec_cur_term_details.day_of_month)
          THEN

            ld_installment_date := last_day(to_date(lv_month_of_claim||'-'||ln_next_fiscal_year,'MM-YYYY'));
          ELSE

            ld_installment_date := TO_DATE( rec_cur_term_details.day_of_month||'-'||
                                            EXTRACT(MONTH FROM to_date(lv_month_of_claim,'MM'))||'-'||
                                            ln_next_fiscal_year
                                          , 'DD-MM-YYYY'
                                          );
          END IF;
        END IF;

        --If the current month< specified month , the fiscal year= current year -1
        --if the specified month > =current month, so specified month is in current year . Add month directly
        --if the specified month < current month , so specified month is in the next year .



      ELSIF (rec_cur_term_details.claim_interval = 'SP_MONTH')
      THEN
          -- Get the speicify month
          IF (rec_cur_term_details.month_of_claim = 'OTH')
          THEN
           lv_month_of_claim := to_char(ld_register_date,'MON');
          ELSE
           lv_month_of_claim := rec_cur_term_details.month_of_claim;
          END IF;-- IF (rec_cur_term_details.month_of_claim = 'OTH')

        ln_current_month:= EXTRACT(MONTH FROM ld_register_date);
        ln_month_number := EXTRACT(MONTH FROM to_date(lv_month_of_claim,'MM')) -ln_current_month ;

        --cal the year of installment_date for the specified month

        --if the specified month > current month, so specified month should be in current year . Add month directly
        --if the specified month < current month, so specified month should be in the next year .
        --if the specified month = current month,
          --for LAST_DAY  AND SAME_DAY , the specified month is in the current year.
          --for FIRST_DAY AND OTHER_DAY, compare the register day and specified day
            --IF the current day is greater than the specified day, so specified month should be in the next year
            --ELSE  specified month is in the current year.

        IF (ln_month_number >0)
        THEN
          ld_installment_date := add_months(ld_register_date,ln_month_number);
        ELSIF (ln_month_number <0)
        THEN
          ld_installment_date := add_months(ld_register_date,ln_month_number+12);
        ELSIF (ln_month_number =0)
        THEN
          IF (  rec_cur_term_details.day_of_claim ='LAST_DAY'
             OR rec_cur_term_details.day_of_claim ='SAME_DAY'
             )
          THEN
            ld_installment_date := ld_register_date;
          END IF;--(  rec_cur_term_details.day_of_claim ='LAST_DAY')

          IF (  rec_cur_term_details.day_of_claim ='FIRST_DAY' )
          THEN
            --IF   ld_register_date IS NOT THE FIRST DAY,so specified month should be in the next year .
            --ELSE specified month is in the same year .
            IF (EXTRACT(DAY FROM ld_register_date)>1)
            THEN
              ld_installment_date := add_months(ld_register_date,ln_month_number+12);
            ELSE
              ld_installment_date := ld_register_date;
            END IF;--(EXTRACT(DAY FROM ld_register_date)>1)
          END IF;--(  rec_cur_term_details.day_of_claim ='FIRST_DAY' )

          IF (  rec_cur_term_details.day_of_claim ='OTHER_DAY' )
          THEN
            --IF ld_register_date is greater than the specified day(the specified day is passed),so specified month should be in the next year .
            --ELSE specified month is in the same year .
            IF (EXTRACT(DAY FROM ld_register_date)>rec_cur_term_details.day_of_month)
            THEN
              ld_installment_date := add_months(ld_register_date,ln_month_number+12);
            ELSE
              ld_installment_date := ld_register_date;
            END IF;--(EXTRACT(DAY FROM ld_register_date)>rec_cur_term_details.day_of_month)
          END IF; --(  rec_cur_term_details.day_of_claim ='OTHER_DAY' )
        END IF;--(ln_month_number >0)

        --cal the day of installment_date for the specified month
        IF (rec_cur_term_details.day_of_claim = 'SAME_DAY')
        THEN
          --If the ld_register_date >= last day of specified month, use add_month() to calc installment day
          --logic is already handled when calculating the year of installment_date

          --If the ld_register_date < last day of specified month ,use the register day as installment day
          IF (EXTRACT(DAY FROM ld_register_date)< EXTRACT(DAY FROM last_day(ld_installment_date)))
          THEN
            ld_installment_date := TO_DATE( EXTRACT(DAY   FROM ld_register_date   )||'-'||
                                            EXTRACT(MONTH FROM ld_installment_date)||'-'||
                                            EXTRACT(YEAR  FROM ld_installment_date)
                                          , 'DD-MM-YYYY'
                                          );
          END IF;--(EXTRACT(DAY FROM ld_register_date)< EXTRACT(DAY FROM last_day(ld_installment_date)))

        ELSIF rec_cur_term_details.day_of_claim = 'FIRST_DAY'
        THEN
          --first_day of specified month = the last day of last month +1
          --ld_installment_date is a day in the specified month and year
          --add_month(,-1) get the last month
          ld_installment_date := last_day(add_months(ld_installment_date,-1))+1;
        ELSIF (rec_cur_term_details.day_of_claim = 'LAST_DAY')
        THEN
          -- last_day of specified month = last_day(specified_month)
          --ld_installment_date is a day in the specified month and year
          ld_installment_date := last_day(ld_installment_date);
        ELSIF (rec_cur_term_details.day_of_claim = 'OTHER_DAY')
        THEN
          -- there are 2 cases:
          -- 1)specified other day >= last day of specified month , use the last day of next month
          -- 2)specified other day <  last day of specified month , use the specified day of next month


          --Get the last_day of specified month
          --Handle case 1:
          --IF the specified  day >= last_day of specified month,use the last_day of next month
          ld_installment_date :=  last_day(ld_installment_date);


          --Handle case 2:
          --If the specified  day < max days of specified month , use the specified day
          --override the variable ld_installment_date
          IF(rec_cur_term_details.day_of_month < EXTRACT(DAY FROM ld_installment_date))
          THEN
            ld_installment_date := TO_DATE( rec_cur_term_details.day_of_month      ||'-'||
                                            EXTRACT(MONTH FROM ld_installment_date)||'-'||
                                            EXTRACT(YEAR  FROM ld_installment_date)
                                          , 'DD-MM-YYYY'
                                          );
          END IF; --(rec_cur_term_details.day_of_month < EXTRACT(DAY FROM ld_installment_date))
        END IF; --(rec_cur_term_details.day_of_claim = 'FIRST_DAY')
      END IF;--(rec_cur_term_details.claim_interval = 'IMMEDIATE')

      ld_register_date := ld_installment_date;


      /* Insert into the temp table*/
      insert_jai_rgm_trm_schedules_t( p_schedule_id
                                    , ln_installment_number
                                    , ln_installment_amount
                                    , ld_installment_date
                                    );
    END LOOP;--rec_cur_term_details  IN cur_term_details(p_term_id)
    -----------------------------------------------------------------------------
    --added by eric ma for VAT FLEX RECOVERY (Bug9494633) on Mar-09-2010,End


    p_process_flag := jai_constants.successful ;
    return ;

EXCEPTION
  WHEN OTHERS THEN
    p_process_flag := jai_constants.unexpected_error ;
    p_process_msg  := 'Error Occured in jai_rgm_claims_pkg.prepare_term_schedules - ' || substr(sqlerrm,1,900) ;

END generate_term_schedules ;


/**************************************************
|| Get the term defined for the assignment and
|| if not defined return the default term
|| If default term does not exist return Error
***************************************************/

PROCEDURE get_term_id
                    (
                     p_regime_id         IN           JAI_RGM_TERM_ASSIGNS.REGIME_ID         %TYPE  ,
                     p_item_id           IN           NUMBER                                        ,
                     p_organization_id   IN           JAI_RGM_TERM_ASSIGNS.ORGANIZATION_ID   %TYPE  ,
                     p_party_type        IN           JAI_RGM_TERM_ASSIGNS.ORGANIZATION_TYPE %TYPE  ,
                     p_location_id       IN           JAI_RGM_TERM_ASSIGNS.LOCATION_ID       %TYPE  ,
                     p_term_id           OUT  NOCOPY  JAI_RGM_TERM_ASSIGNS.TERM_ID           %TYPE  ,
                     p_process_flag      OUT  NOCOPY  VARCHAR2                                      ,
                     p_process_msg       OUT  NOCOPY  VARCHAR2
                    )
IS

  CURSOR cur_get_regime_regno
                            ( p_regime_id NUMBER ,
                              p_org_id    NUMBER ,
                              p_loc_id    NUMBER ,
            p_att_code  jai_rgm_registrations.attribute_code%TYPE ,    --rchandan for bug#4428980
            p_att_type_code jai_rgm_registrations.attribute_type_code%TYPE--rchandan for bug#4428980
                             )
  IS
  SELECT attribute_value
  FROM   JAI_RGM_ORG_REGNS_V jorrv
  WHERE  jorrv.regime_id                 = p_regime_id
  AND    jorrv.attribute_code            = p_att_code
  AND    jorrv.attribute_type_code       = p_att_type_code
  AND    jorrv.organization_id           = p_org_id
  AND    jorrv.organization_type         = p_party_type
  AND    jorrv.location_id               = nvl ( p_loc_id , jorrv.location_id ) ;

  CURSOR cur_get_regime_code (  p_regime_id NUMBER  )
  IS
  SELECT regime_code
  FROM   JAI_RGM_DEFINITIONS
  WHERE  regime_id = p_regime_id ;

  CURSOR cur_term_id
                   (
                     p_reg_id         NUMBER   ,
                     p_reg_item_class VARCHAR2 ,
                     p_reg_regno      VARCHAR2 ,
                     p_org_id         NUMBER   ,
                     p_party_type     VARCHAR2 ,
                     p_loc_id         NUMBER
                    )
  IS
  SELECT term_id
  FROM   JAI_RGM_TERM_ASSIGNS
  WHERE  NVL ( location_id       , p_loc_id         ) = p_loc_id
  AND    NVL ( organization_type , p_party_type     ) = p_party_type
  AND    NVL ( organization_id   , p_org_id         ) = p_org_id
  AND    NVL ( regime_regno      , p_reg_regno      ) = p_reg_regno
  AND    NVL ( regime_item_class , p_reg_item_class ) = p_reg_item_class
  AND    regime_id                                    = p_reg_id ;


  lv_reg_item_class  JAI_RGM_TERM_ASSIGNS.REGIME_ITEM_CLASS%TYPE ;
  lv_regime_regno    JAI_RGM_TERM_ASSIGNS.REGIME_REGNO     %TYPE ;
  lv_regime_code     JAI_RGM_DEFINITIONS.REGIME_CODE               %TYPE ;
  lv_process_flag    VARCHAR2(3) ;
  lv_process_msg     VARCHAR2(1000);

BEGIN

  p_term_id         := NULL ;
  lv_reg_item_class := NULL ;
  lv_regime_code    := NULL ;
  lv_process_flag   := NULL ;
  lv_process_msg    := NULL ;

  /*
  || Validate the input parameters
  */

  IF p_regime_id IS NULL  THEN

    p_process_flag := jai_constants.expected_error;
    p_process_msg  := 'jai_rgm_claims_pkg.get_term_id => Regime ID cannot be NULL' ;
    return;

  END IF;

  IF p_item_id IS NULL  THEN

    p_process_flag := jai_constants.expected_error;
    p_process_msg  := 'jai_rgm_claims_pkg.get_term_id => Item ID cannot be NULL' ;
    return;

  END IF ;

  IF p_organization_id IS NULL  THEN

    p_process_flag := jai_constants.expected_error;
    p_process_msg  := 'jai_rgm_claims_pkg.get_term_id => Organization ID cannot be NULL' ;
    return;

  END IF ;

  IF p_party_type IS NULL  THEN

    p_process_flag := jai_constants.expected_error;
    p_process_msg  := 'jai_rgm_claims_pkg.get_term_id => Party Type cannot be NULL' ;
    return;

  END IF ;


  IF p_location_id IS NULL  THEN

    p_process_flag := jai_constants.expected_error;
    p_process_msg  := 'jai_rgm_claims_pkg.get_term_id => Location ID cannot be NULL' ;
    return;

  END IF ;

  OPEN  cur_get_regime_regno
                           (
                               p_regime_id => p_regime_id       ,
                               p_org_id    => p_organization_id ,
                               p_loc_id    => p_location_id,
             p_att_code  => 'REGISTRATION_NO',   --rchandan for bug#4428980
             p_att_type_code => 'PRIMARY'            --rchandan for bug#4428980
                           ) ;
  FETCH cur_get_regime_regno INTO lv_regime_regno ;
  CLOSE cur_get_regime_regno ;


  OPEN  cur_get_regime_code ( p_regime_id ) ;
  FETCH cur_get_regime_code INTO lv_regime_code ;
  CLOSE cur_get_regime_code ;

  jai_inv_items_pkg.jai_get_attrib
                             (
                               p_regime_code       => lv_regime_code    ,
                               p_organization_id   => p_organization_id ,
                               p_inventory_item_id => p_item_id         ,
                               p_attribute_code    => 'ITEM CLASS'      ,
                               p_attribute_value   => lv_reg_item_class ,
                               p_process_flag      => lv_process_flag   ,
                               p_process_msg       => lv_process_msg
                             );

  IF ( lv_reg_item_class IS NULL ) OR ( lv_process_flag <> jai_constants.successful ) THEN

    p_process_flag := jai_constants.expected_error;
    p_process_msg  := 'jai_rgm_claims_pkg.get_term_id => jai_inv_items_pkg.jai_get_attrib => p_process_flag :: lv_process_msg' ;
    return;

  END IF ;


  OPEN  cur_term_id ( p_reg_id          => p_regime_id       ,
                      p_reg_item_class  => lv_reg_item_class ,
                      p_reg_regno       => lv_regime_regno   ,
                      p_org_id          => p_organization_id ,
                      p_party_type      => p_party_type      ,
                      p_loc_id          => p_location_id
                     ) ;
  FETCH cur_term_id INTO p_term_id ;
  CLOSE cur_term_id ;

  IF p_term_id IS NULL THEN

       p_process_flag  := jai_constants.expected_error ;
       p_process_msg   := 'jai_rgm_claims_pkg.get_term_id => No term defined' ;
       RETURN ;

  END IF ;

  p_process_flag := jai_constants.successful ;
  p_process_msg  := NULL;

EXCEPTION
 WHEN others THEN

   p_process_flag := jai_constants.unexpected_error;
   p_process_msg  := 'JAI_CMN_RG_OTHERS.get_term_id => Error Occured : ' || substr(sqlerrm,1,1000) ;

END get_term_id ;

PROCEDURE set_term_in_use
                       (
                        p_term_id       IN          JAI_RGM_TERMS.TERM_ID%TYPE ,
                        p_process_flag  OUT NOCOPY  VARCHAR2                   ,
                        p_process_msg   OUT NOCOPY  VARCHAR2
                       )
IS

CURSOR  cur_term_flag ( cp_term_id NUMBER )
IS
SELECT term_in_use_flag
FROM   jai_rgm_terms
WHERE  term_id = p_term_id ;


lv_term_in_use_flag VARCHAR2(1) ;

BEGIN

  /*
  || Validate the input parameters
  */

  IF p_term_id IS NULL  THEN

    p_process_flag := jai_constants.expected_error;
    p_process_msg  := 'jai_rgm_claims_pkg.set_term_in_use_flag => Term ID cannot be NULL' ;
    return;

  END IF;

  OPEN  cur_term_flag ( cp_term_id => p_term_id );
  FETCH cur_term_flag INTO lv_term_in_use_flag ;
  IF  NOT ( cur_term_flag%FOUND ) THEN

    p_process_flag := jai_constants.expected_error;
    p_process_msg  := 'jai_rgm_claims_pkg.set_term_in_use_flag => Term ID does not exist in database' ;
    CLOSE cur_term_flag ;
    return;

  END IF;
  CLOSE cur_term_flag ;

  IF lv_term_in_use_flag <> 'Y' THEN

    UPDATE  jai_rgm_terms
    SET     term_in_use_flag  = 'Y' ,
            last_update_date  = sysdate ,
            last_update_login = fnd_global.login_id ,
            last_updated_by   = fnd_global.user_id
    WHERE   term_id = p_term_id ;

  END IF ;

  p_process_flag := jai_constants.successful ;
  p_process_msg  := NULL;

  EXCEPTION
  WHEN others THEN

    p_process_flag := jai_constants.unexpected_error;
    p_process_msg  := 'JAI_CMN_RG_OTHERS.set_term_in_use_flag => Error Occured : ' || substr(sqlerrm,1,1000) ;

END set_term_in_use ;

END jai_cmn_rgm_terms_pkg ;

/
