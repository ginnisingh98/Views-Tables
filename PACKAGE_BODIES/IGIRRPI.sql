--------------------------------------------------------
--  DDL for Package Body IGIRRPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGIRRPI" AS
-- $Header: igirrpib.pls 120.18.12010000.6 2010/03/23 10:43:09 gaprasad ship $


  l_state_level CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  l_proc_level  CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  l_event_level CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
  l_excep_level CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  l_error_level CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
  l_unexp_level CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

TYPE    DATE_RANGE IS RECORD
                      ( start_date        DATE
                      , end_date          DATE
                      , actual_start_date DATE
                      , factor NUMBER );
SUBTYPE RAIL IS  ra_interface_lines_all%ROWTYPE;
SUBTYPE RAID IS  ra_interface_distributions_all%ROWTYPE;

TYPE    RAID_TABLE       is table of RAID       index by binary_integer;
TYPE    DATE_RANGE_TABLE is table of DATE_RANGE index by binary_integer;
/*
-- The g_raid_Table which has global scope in this program
*/
g_raid_table      RAID_TABLE;
/*
-- ---------------------------------------------------------------------------
-- Row <0  is the 'REC' entry and there may be many entries per standing charge
-- Row >0  is the 'REV' entry and there may be more than 1 entry for each
-- standing charge line this should be neccessary to accomodate price breaks etc.
-- The reason we need a table is that we need to calculate the % based on the
-- amounts and then clear the amount columns based on the options set at the batch
-- source level.
-- ----------------------------------------------------------------------------
*/
g_curr_rec_idx BINARY_INTEGER ;
g_curr_rev_idx BINARY_INTEGER ;

rev_idx BINARY_INTEGER ;
/*
-- Note: We need the above index to keep track of the number of entries made per run into
-- the RAID_TABLE per RUN.
-- Assumptions
-- 1. Context and other transaction flexfield information is set
-- 2. revenue proration is done at transaction line level.
-- Algo:
-- For each standing charge
--    For each charge line
--       Process Charge :
--            Determine Billing Period
--            Determine the overall ratio
--            Process Price Breaks :
--               Create entry in Ra_interface_lines
--                   -- Also create a parallel entry in the Ra_interface_salescredits
--               Build Ra_interface_distribution information in PLSQL table
--               Consolidate the amount, percent entries for all the REV distributions in the PLSQL table
--       Process Distributions :
--            Consolidate the amount, percent entries for all the REC distributions in the PLSQL table
--            Delete the entries from the PL/SQL table.
--       Update Sequence
--   End For Charge line
-- End for Charge
-- Set up issues :
--    To ensure that the information is transferred from the standing charge lines to the invoice
--       Set the revenue allocation rule as 'Amount' and ensure that the standing charges do not
--       use any accounting rules.
*/
-- --------------------------------------------------------------------------
--           CONSTANTS - NEEDS VERIFICATION FOR NLS COMPLIANCE
-- --------------------------------------------------------------------------
STANDING_CHARGE_STATUS      CONSTANT VARCHAR2(30) :=  'ACTIVE';
ADVANCE_STATUS              CONSTANT VARCHAR2(30) :=  'ADVANCE';
ARREARS_STATUS              CONSTANT VARCHAR2(30) :=  'ARREARS';
REVENUE_CODE                CONSTANT VARCHAR2(30) :=  'REV';
RECEIVABLE_CODE             CONSTANT VARCHAR2(30) :=  'REC';
ALLOCATION_PERCENT_CODE     CONSTANT VARCHAR2(30) :=  'Percent';
ALLOCATION_AMOUNT_CODE      CONSTANT VARCHAR2(30) :=  'Amount';
LINE_CODE                   CONSTANT VARCHAR2(30) :=  'LINE';
USER_CODE                   CONSTANT VARCHAR2(30) :=  'User';
END_DATE_TIME               CONSTANT VARCHAR2(30) :=  ' 23:59:59';
BEGIN_DATE_TIME             CONSTANT VARCHAR2(30) :=  ' 00:00:00';
RPI_DATE_FORMAT             CONSTANT VARCHAR2(30) :=  'DD/MM/YYYY HH24:MI:SS';
DEF_DATE_FORMAT             CONSTANT VARCHAR2(30) :=  'DD/MM/YYYY';
-- ----------------------------------------------------------------------------
--  CUSTOM VALUES
-- ----------------------------------------------------------------------------
TRANSACTION_CODE       VARCHAR2(300);
FROM_DATE_INFO         VARCHAR2(300);
TO_DATE_INFO           VARCHAR2(300);
-- --------------------------------------------------------------------------
--                               CURSORS
-- --------------------------------------------------------------------------
CURSOR C_stand_charges ( cp_run_date in date
                       , cp_sob_id in number
                       , cp_batch_source_id in number )  IS
/*------------------------------------------------------*
 |                                                      |
 |       Cursor for Selecting Standing Charges          |
 |                                                      |
 *------------------------------------------------------*/
        SELECT DISTINCT
               sc.standing_charge_id
        ,      sc.set_of_books_id
        ,      sc.comments
        ,      sc.charge_reference
        ,      sc.description           desc_1
        ,      sc.bill_to_customer_id
        ,      sc.bill_to_site_use_id
        ,      sc.bill_to_contact_id
        ,      sc.ship_to_customer_id
        ,      sc.ship_to_address_id
        ,      sc.bill_to_address_id
        ,      sc.ship_to_site_use_id
        ,      sc.ship_to_contact_id
        ,      sc.start_date
        ,      sc.end_date
        ,      sc.standing_charge_date
        ,      sc.next_due_date
        ,      sc.suppress_inv_print
        ,      sc.cust_trx_type_id
        ,      sc.receipt_method_id
        ,      sc.batch_source_id
        ,      sc.salesrep_id
        ,      sc.advance_arrears_ind  -- change here to do testing
--      ,      sc.bank_account_id     -- Bug 9496038
	,      sc.payment_trxn_extension_id	/*Bug No 5905216 Payment Upgrade for R12*/
        ,      sc.previous_due_date    -- change here to do testing
        ,      sc.creation_date
        ,      sc.created_by
        ,      sc.last_update_date
        ,      sc.last_updated_by
        ,      sc.last_update_login
        ,      SYSDATE
        ,      sc.period_name          sc_period_name
        ,      sc.rowid                sc_rowid
        ,      sc.default_invoicing_rule
        ,      bs.name                 bs_name
        ,      nvl(sc.term_id,4) term_id
        ,      bs.rev_acc_allocation_rule
        ,      sob.currency_code
/*5905216*/
	,      sc.org_id
	,      sc.legal_entity_id
        FROM   gl_sets_of_books           sob
        ,      igi_rpi_standing_charges   sc
        ,      ar_system_parameters       sp
        ,      ra_batch_sources           bs
        ,      ra_cust_trx_types          ct
        ,      hz_cust_accounts           ca
        WHERE  sp.set_of_books_id    = cp_sob_id
        AND    sp.set_of_books_id    = sob.set_of_books_id
        AND    sp.set_of_books_id    = sc.set_of_books_id
        AND    bs.batch_source_id    = NVL(cp_batch_source_id,bs.batch_source_id)
        AND    nvl(bs.end_date,cp_run_date +1)   >= cp_run_date
        AND    nvl(bs.start_date,cp_run_date-1) <= cp_run_date
        AND    sc.batch_source_id            = bs.batch_source_id
        AND    sc.cust_trx_type_id           = ct.cust_trx_type_id
        AND    nvl(ct.end_date,cp_run_date+1)   >= cp_run_date
        AND    nvl(ct.start_date,cp_run_date-1) <= cp_run_date
        AND    nvl(sc.date_synchronized_flag,'Y') = 'Y'
        AND    sc.status                     = STANDING_CHARGE_STATUS
        /*changed the following AND clause for bug 4436839*/
        AND    (

                 (  nvl(sc.advance_arrears_ind,sc.default_invoicing_rule) = ARREARS_STATUS
                    AND nvl(sc.previous_due_date,sc.start_date) <= nvl(sc.end_date,sc.next_due_date)
                 )
                 OR
                 (   nvl(sc.advance_arrears_ind,sc.default_invoicing_rule)   = ADVANCE_STATUS
                     AND sc.next_due_date <= NVL(sc.end_date,sc.next_due_date)
                  )
               )
	AND    cp_run_date                   >= sc.next_due_date
        AND sc.bill_to_customer_id = ca.cust_account_id
        AND ca.status = 'A'
        ORDER BY sc.standing_charge_id;
--
CURSOR C_line_details (cp_standing_charge_id in number
                      ,cp_sob_id             in number ) IS
/*---------------------------------------------------------------------------*
 | Select Cursor for Line Details based on the Selected Standing Charge
 | cursor above
 *---------------------------------------------------------------------------*/
        SELECT NVL(ld.price,0)            price
        ,      NVL(ld.previous_price,0)   previous_price
        ,      NVL(ld.revised_price,0)    revised_price
        ,      ld.charge_item_number
        ,      ld.revised_effective_date
        ,      ld.current_effective_date
        ,      ld.previous_effective_date
        ,      ld.line_item_id
        ,      ld.item_id
        ,      ld.quantity
        ,      ld.description          desc_2
        ,      ld.vat_tax_id
        ,      ld.revenue_code_combination_id
        ,      ld.receivable_code_combination_id
        ,      ld.period_name          ld_period_name
        ,      ld.accounting_rule_id
        ,      decode( ld.accounting_rule_id, null, null,
                       ld.start_date )   start_date
        ,      decode( ld.accounting_rule_id, null, null,
                       ld.duration )   duration
        ,      uom.uom_code            uom_uom_code
        ,      uom.unit_of_measure     unit_of_measure
        ,      vt.tax_rate_code
        ,      vt.percentage_rate
        ,      nvl(vt.allow_adhoc_tax_rate_flag,'N')  validate_flag
        ,      ld.rowid ld_rowid
/*5905216*/
	,      ld.legal_entity_id
        FROM   igi_rpi_line_details     ld
        ,      mtl_units_of_measure       uom
        ,      igi_rpi_component_periods  rcp
        ,      ZX_RATES_B             vt                         			 /*Bug No 7606235*/
        WHERE  ld.standing_charge_id          = cp_standing_charge_id
        --AND    nvl(uom.disable_date,SYSDATE) >= SYSDATE
        AND    uom.unit_of_measure            = rcp.unit_of_measure
        AND    rcp.period_name                = ld.period_name
        AND    ld.vat_tax_id                  = vt.tax_rate_id(+)
        AND    NVL(vt.effective_from, SYSDATE)   <=  SYSDATE
        AND    NVL(vt.effective_to, SYSDATE)     >=  SYSDATE        ORDER BY ld.line_item_id ;

--
-- Set the Transaction Flexfield context and Line Transaction flexfield context
-- and other nls related stuff.
--
PROCEDURE  SetValuesForGlobals IS
     CURSOR c_rpi_globals IS
          SELECT  igiaso.rpi_header_context_code
          ,       igiaso.rpi_line_context_code
          FROM    igi_ar_system_options igiaso
          ;
    CURSOR C_rpi_labels (label_code in varchar2)
    IS
          SELECT  meaning
          FROM    igi_lookups
          WHERE   lookup_type = 'RPI_LABELS'
          AND     lookup_code = label_code
         ;

BEGIN
    FOR l_rpi in c_rpi_globals LOOP
        IF l_rpi.rpi_header_context_code IS NULL
        OR l_rpi.rpi_line_context_code IS NULL
        THEN
               return;
        END IF;

        IF l_rpi.rpi_header_context_code <> l_rpi.rpi_line_context_code THEN
           return;
        END IF;

        TRANSACTION_CODE := l_rpi.rpi_line_context_code;

        FOR l_label in c_rpi_labels ( 'FROM_DATE_LABEL' )
        LOOP
           FROM_DATE_INFO := ' '||l_label.meaning||' ';
        END LOOP;
        FOR l_label in c_rpi_labels ( 'TO_DATE_LABEL' )
        LOOP
           TO_DATE_INFO := ' '||l_label.meaning||' ';
        END LOOP;

    END LOOP;

END SetValuesForGlobals;
-- -----------------------------------------------------------------------------

  PROCEDURE WriteToLogFile ( pp_msg_level in number,pp_path in varchar2, pp_mesg in varchar2 ) IS
  BEGIN
     IF pp_msg_level >=  FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(pp_msg_level, pp_path, pp_mesg );
     END IF;
  END;

FUNCTION  UseSalesCreditsAtSystem return BOOLEAN IS

    CURSOR C_scredits IS
        SELECT 'x'
        FROM   ar_system_parameters
        WHERE  salesrep_required_flag = 'Y'
        ;

    -- check if autoaccounting is set up to use salesreps.
   CURSOR c_auto_acc IS
        select 'x'
        from ra_account_defaults rad,
            ra_account_default_segments rads
        where rads.gl_default_id = rad.gl_default_id
        and rads.table_name = 'RA_SALESREPS'
        ;

BEGIN

    FOR l_acc IN C_auto_acc LOOP
        return TRUE;
    END LOOP;

    FOR l_credits IN c_scredits LOOP
        return TRUE;
    END LOOP;


    return FALSE;
EXCEPTION WHEN OTHERS THEN return FALSE;
END UseSalesCreditsAtSystem;

FUNCTION UseSalesCreditsAtSource (p_source_id in number) return BOOLEAN IS
   CURSOR c_batch_sources (cp_source_id in number) IS
        SELECT 'x'
        FROM   ra_batch_sources
        WHERE  allow_sales_credit_flag = 'Y'
        AND    batch_source_id = cp_source_id
        ;
BEGIN
   FOR l_bs IN c_batch_sources (p_source_id) LOOP
       return TRUE;
   END LOOP;
   return FALSE;
EXCEPTION WHEN OTHERS THEN return FALSE;
END UseSalesCreditsAtSource;
/*
-- Sales Credits may be allowed at batch source and could override the system option
-- So see if enabled at system option then at batch source
--
*/
FUNCTION UseSalesCredits ( p_source_id in number) return BOOLEAN
IS
BEGIN
   IF UseSalesCreditsAtSystem THEN
      return TRUE;
   ELSIF UseSalesCreditsAtSource ( p_source_id ) THEN
      return TRUE;
   END IF;
   return FALSE;
END UseSalesCredits;

-- -----------------------------------------------------------------------------
FUNCTION  Get_invoicing_Rule (fp_name in varchar2) return NUMBER IS
  CURSOR c_rule IS
    SELECT rule_id
    FROM   ra_rules
    WHERE  rule_id IN (-2,-3)
    AND    type    = 'I'
    AND    UPPER(name) LIKE UPPER(fp_name)||'%'; -- Bug 2413794 vgadde added UPPER both sides
    l_rule c_rule%ROWTYPE;
BEGIN
    OPEN c_rule;
    FETCH c_rule INTO l_rule;
    CLOSE c_rule;
    RETURN l_rule.rule_id;
EXCEPTION WHEN OTHERS THEN RETURN -1;
END Get_invoicing_Rule;

PROCEDURE Next_Scheduled_Dates  ( pp_sched_id in number
                                , pp_period_name in varchar2
                                , pp_cur_next_due_date in date
                                , pp_new_next_due_date in out NOCOPY date
                                , pp_new_prev_due_date in out NOCOPY date
                                ) IS
CURSOR c_sched IS
    SELECT date1, date2, date3, date4
           , pp_cur_next_due_date old_date
    FROM   igi_rpi_period_schedules
    WHERE  schedule_id  = pp_sched_id
    AND    period_name  = pp_period_name
    AND    nvl(enabled_flag,'Y') = 'Y';
l_new_next_due_date_old   date;
l_new_prev_due_date_old   date;
BEGIN
    l_new_next_due_date_old := pp_new_next_due_date;
    l_new_prev_due_date_old := pp_new_prev_due_date;

    FOR l_s in C_sched LOOP

     /* next due date */

        if    to_date(to_char(l_s.date1,'DD/MM/')
              ||to_char(pp_cur_next_due_date,'YYYY'),DEF_DATE_FORMAT) >
              pp_cur_next_due_date
        then
              pp_new_next_due_date := to_date(to_char(l_s.date1,'DD/MM/')
              ||to_char(pp_cur_next_due_date,'YYYY'),DEF_DATE_FORMAT);
        elsif to_date(to_char(l_s.date2,'DD/MM/')
              ||to_char(pp_cur_next_due_date,'YYYY'),DEF_DATE_FORMAT) >
              pp_cur_next_due_date
        then
              pp_new_next_due_date := to_date(to_char(l_s.date2,'DD/MM/')
              ||to_char(pp_cur_next_due_date,'YYYY'),DEF_DATE_FORMAT);
        elsif to_date(to_char(l_s.date3,'DD/MM/')
              ||to_char(pp_cur_next_due_date,'YYYY'),DEF_DATE_FORMAT) >
              pp_cur_next_due_date
        then
              pp_new_next_due_date := to_date(to_char(l_s.date3,'DD/MM/')
              ||to_char(pp_cur_next_due_date,'YYYY'),DEF_DATE_FORMAT);
        elsif to_date(to_char(l_s.date4,'DD/MM/')
              ||to_char(pp_cur_next_due_date,'YYYY'),DEF_DATE_FORMAT) >
              pp_cur_next_due_date
        then
              pp_new_next_due_date := to_date(to_char(l_s.date4,'DD/MM/')
              ||to_char(pp_cur_next_due_date,'YYYY'),DEF_DATE_FORMAT);
        elsif to_date(to_char(l_s.date1,'DD/MM/')
              ||to_char(to_number(to_char(pp_cur_next_due_date,'YYYY'))+1),
                 DEF_DATE_FORMAT) >
              pp_cur_next_due_date
        then
              pp_new_next_due_date := to_date(to_char(l_s.date1,'DD/MM/')
              ||to_char(to_number(to_char(pp_cur_next_due_date,'YYYY'))+1),
                 DEF_DATE_FORMAT);
        end if;
  --       pp_new_prev_due_date := pp_cur_next_due_date;
     /* prev due date */

        if    to_date(to_char(l_s.date1,'DD/MM/')
              ||to_char(pp_cur_next_due_date,'YYYY'),DEF_DATE_FORMAT) >=
              pp_cur_next_due_date
        then
              pp_new_prev_due_date := to_date(to_char(l_s.date4,'DD/MM/')
              ||to_char(to_number(to_char(pp_cur_next_due_date,'YYYY'))-1),DEF_DATE_FORMAT);
        elsif to_date(to_char(l_s.date2,'DD/MM/')
              ||to_char(pp_cur_next_due_date,'YYYY'),DEF_DATE_FORMAT) >=
              pp_cur_next_due_date
        then
              pp_new_prev_due_date := to_date(to_char(l_s.date1,'DD/MM/')
              ||to_char(pp_cur_next_due_date,'YYYY'),DEF_DATE_FORMAT);
        elsif to_date(to_char(l_s.date3,'DD/MM/')
              ||to_char(pp_cur_next_due_date,'YYYY'),DEF_DATE_FORMAT) >=
              pp_cur_next_due_date
        then
              pp_new_prev_due_date := to_date(to_char(l_s.date2,'DD/MM/')
              ||to_char(pp_cur_next_due_date,'YYYY'),DEF_DATE_FORMAT);
        elsif to_date(to_char(l_s.date4,'DD/MM/')
              ||to_char(pp_cur_next_due_date,'YYYY'),DEF_DATE_FORMAT) >=
              pp_cur_next_due_date
        then
              pp_new_prev_due_date := to_date(to_char(l_s.date3,'DD/MM/')
              ||to_char(pp_cur_next_due_date,'YYYY'),DEF_DATE_FORMAT);
        elsif to_date(to_char(l_s.date1,'DD/MM/')
              ||to_char(to_number(to_char(pp_cur_next_due_date,'YYYY'))+1),
                 DEF_DATE_FORMAT) >=
              pp_cur_next_due_date
        then
              pp_new_prev_due_date := to_date(to_char(l_s.date4,'DD/MM/')
              ||to_char(pp_cur_next_due_date,'YYYY'),
                 DEF_DATE_FORMAT);
        end if;


    END LOOP;

    WriteToLogFile (l_state_level,'igi.plsql.igirrpi.next_scheduled_dates ',' --> New Next Due Date '|| pp_new_next_due_date );
    WriteToLogFile (l_state_level,'igi.plsql.igirrpi.next_scheduled_dates ',' --> Cur Next Due Date '|| pp_cur_next_due_date );
    WriteToLogFile (l_state_level,'igi.plsql.igirrpi.next_scheduled_dates', ' --> New Prev Due Date '|| pp_new_prev_due_date );
EXCEPTION
  WHEN OTHERS THEN
     pp_new_next_due_date := l_new_next_due_date_old;
     pp_new_prev_due_date := l_new_prev_due_date_old;
     app_exception.raise_exception;
END Next_Scheduled_Dates;
--
--
PROCEDURE Next_Due_Dates      (  pp_curr_next_due_date in date
                                ,pp_period_name        in varchar2
                                ,pp_advance_arrears_ind in varchar2
                                ,pp_new_prev_due_date  in out NOCOPY date
                                ,pp_new_next_due_date  in out NOCOPY date
                                ,pp_new_schedule_id    in out NOCOPY number
                                ,pp_new_factor         in out NOCOPY number
                                ,pp_new_component      in out NOCOPY varchar2
                                ) IS
CURSOR c_info is
     SELECT DECODE(component
            ,'DAY'   ,TO_NUMBER(factor)*1 + pp_curr_next_due_date
            ,'WEEK'  ,TO_NUMBER(factor)*7 + pp_curr_next_due_date
            ,'MONTH' ,ADD_MONTHS(pp_curr_next_due_date,TO_NUMBER(factor))
            ,'YEAR'  ,ADD_MONTHS(pp_curr_next_due_date,TO_NUMBER(factor)*12)
            ) new_next_due_date
     ,      DECODE(component,'DAY'   ,TO_NUMBER(factor)* -1 + pp_curr_next_due_date
            ,'WEEK'  ,TO_NUMBER(factor)* -7 + pp_curr_next_due_date
            ,'MONTH' ,ADD_MONTHS(pp_curr_next_due_date,TO_NUMBER(factor)* -1)
            ,'YEAR'  ,ADD_MONTHS(pp_curr_next_due_date,TO_NUMBER(factor)* -12)
            ) new_prev_due_date
     ,      nvl( schedule_id,0) schedule_id
     ,      period_name
     ,      use_schedules_flag
     ,      factor
     ,      component
     FROM   igi_rpi_component_periods
     WHERE  period_name = pp_period_name
     AND    nvl(enabled_flag,'Y') = 'Y' ;
 l_new_prev_due_date_old  date          ;
 l_new_next_due_date_old  date          ;
 l_new_schedule_id_old    number        ;
 l_new_factor_old         number        ;
 l_new_component_old      varchar2(25)  ;
BEGIN
 l_new_prev_due_date_old  :=  pp_new_prev_due_date;
 l_new_next_due_date_old  :=  pp_new_next_due_date;
 l_new_schedule_id_old    :=  pp_new_schedule_id;
 l_new_factor_old         :=  pp_new_factor;
 l_new_component_old      :=  pp_new_component;

  FOR l_info IN C_info LOOP

      pp_new_prev_due_date  :=  l_info.new_prev_due_date;
      pp_new_next_due_date  :=  l_info.new_next_due_date;
      pp_new_schedule_id    :=  l_info.schedule_id;
      pp_new_factor         :=  l_info.factor;
      pp_new_component      :=  l_info.component;

     IF l_info.use_schedules_flag = 'Y' and l_info.schedule_id <> 0
        and l_info.component = 'DAY'
     THEN
        /* the period is of type 1/4 Days so calculate the FACTOR */
        Next_Scheduled_Dates ( l_info.schedule_id
                           ,   l_info.period_name
                           ,   pp_curr_next_due_date
                           ,   pp_new_next_due_date
                           ,   pp_new_prev_due_date
                           );

           pp_new_factor := to_date(to_char(pp_new_next_due_date -1,DEF_DATE_FORMAT)||END_DATE_TIME,
                                   RPI_DATE_FORMAT)
                            -
                            to_date(to_char(pp_curr_next_due_date,DEF_DATE_FORMAT)||BEGIN_DATE_TIME,
                                    RPI_DATE_FORMAT)
                            ;

     END IF;
  END LOOP;

  RETURN;
EXCEPTION
   WHEN OTHERS THEN
     pp_new_prev_due_date  :=  l_new_prev_due_date_old;
     pp_new_next_due_date  :=  l_new_next_due_date_old;
     pp_new_schedule_id    :=  l_new_schedule_id_old;
     pp_new_factor         :=  l_new_factor_old;
     pp_new_component      :=  l_new_component_old;
     app_exception.raise_exception;
END Next_Due_Dates;
--
/*
-- Ensure that the charge component <> billing component
-- Before using this function.
*/

FUNCTION Component_to_Days  ( p_component   in VARCHAR2
                            , p_start_date  in DATE
                            , p_factor      in number
                            )
RETURN NUMBER IS
      l_no_of_days NUMBER ;
BEGIN
      l_no_of_days := 0;
     IF p_component = 'YEAR' THEN
         return (add_months(p_start_date,12 * p_factor) - p_start_date) ;
      ELSIF p_component = 'MONTH' THEN
         return (add_months(p_start_date,1 * p_factor ) - p_start_date) ;
      ELSIF p_component = 'WEEK'  THEN
         return ( (p_start_date + (7* p_factor)) - p_start_date);
     ELSIF p_component = 'DAY'   THEN
         return p_factor;
     END If;
END Component_to_Days;


FUNCTION Component_factor  ( p_charge_component   in VARCHAR2
                           , p_bill_component     in VARCHAR2
                           , p_start_date         in DATE
                          )
RETURN NUMBER IS
      l_no_of_days NUMBER ;
BEGIN
     l_no_of_days := add_months(p_start_date,1) - p_start_date;

     IF p_charge_component = 'YEAR' THEN
         IF p_bill_component = 'MONTH' THEN
            return 1/12;
         ELSIF p_bill_component = 'WEEK' THEN
            return 1/(add_months(p_start_date,12) - p_start_date)/7 ;
         ELSIF p_bill_component = 'DAY'  THEN
            return 1/(add_months(p_start_date,12) - p_start_date) ;
         END IF;
      ELSIF p_charge_component = 'MONTH' THEN
         IF p_bill_component = 'YEAR' THEN
            return 12;
         ELSIF p_bill_component = 'WEEK' THEN
            return 1/(l_no_of_days/7) ;
         ELSIF p_bill_component = 'DAY'  THEN
            return 1/l_no_of_days;
         END IF;
      ELSIF p_charge_component = 'WEEK'  THEN
         IF p_bill_component = 'YEAR' THEN
            return (add_months(p_start_date,12) - p_start_date)/7;
         ELSIF p_bill_component = 'MONTH' THEN
            return  (l_no_of_days/7);
         ELSIF p_bill_component = 'DAY'  THEN
            return  1/7;
         END IF;
     ELSIF p_charge_component = 'DAY'   THEN
         IF p_bill_component = 'YEAR' THEN
            return (add_months(p_start_date,12)-p_start_date);
         ELSIF p_bill_component = 'MONTH' THEN
            return l_no_of_days;
         ELSIF p_bill_component = 'WEEK' THEN
            return 7;
         END IF;
     END If;
END Component_Factor;

FUNCTION Billing_Charge_Ratio  ( p_invoice_rule       in varchar2
                               , p_factor             in number
                               , p_from_date         in DATE
                               , p_to_date           in DATE
                               , p_charge_period     in varchar2
                               , p_charge_factor     in number
                               , p_charge_component  in varchar2
                               , p_bill_period    in varchar2
                               , p_bill_factor    in number
                               , p_bill_component in varchar2
                               )
RETURN NUMBER IS


   l_no_of_days NUMBER ; /** Number of days in one billing period **/
   l_factor NUMBER ; /* this factor is for 1 full charge period */
   l_ratio  NUMBER ;

   l_component_factor NUMBER;

BEGIN

    l_no_of_days := p_to_date - p_from_date;
    l_factor := 0;
    l_ratio  := 0;

    IF p_charge_factor = 0 OR p_bill_factor = 0 THEN
       return 0;
    END IF;

    IF (p_to_date - p_from_date) = 0 THEN
       return 0;
    END IF;
    l_factor := 1;


    if p_bill_component = p_charge_component then
                  if p_bill_factor <> 0 then
                     l_factor := ( p_bill_factor/ p_charge_factor ) ;
                  end if;
    else


           l_component_factor :=  Component_factor  ( p_charge_component
                                                    , p_bill_component
                                                    , p_from_date  );

           l_factor   :=      l_component_factor * ( p_bill_factor/p_charge_factor );

   end if;

  /*
  -- The factor is calculated for an ideal period
  -- use the number of days to ensure that this factor
  -- takes into consideration discrepancies between start date and next due dates
  */

        if    p_bill_component = 'DAY' then
              l_no_of_days := p_bill_factor;
        elsif p_bill_component = 'MONTH' then
            l_no_of_days := add_months(p_from_date, 1 * p_bill_factor) - p_from_date;
        elsif p_bill_component = 'WEEK' then
            l_no_of_days := 7 * p_bill_factor;
        elsif p_bill_component = 'YEAR' then
            l_no_of_days := add_months(p_from_date, 12 * p_bill_factor) - p_from_date;
        end if;


    WriteToLogFile ( l_state_level,'igi.plsql.igirrpi.billing_charge_ratio',' Factor due start date    : '|| p_factor );
    WriteToLogFile ( l_state_level,'igi.plsql.igirrpi.billing_charge_ratio',' factor due to components : '|| l_factor );
    WriteToLogFile ( l_state_level,'igi.plsql.igirrpi.billing_charge_ratio',' Number of Days           : '|| l_no_of_days );

--bug3564100 sdixit: round (p_to_date - p_from_date) difference to smoothen out
--the small error due to end date time component being 23:59:59 and not 24:00:00
    l_ratio :=  p_factor * l_factor *  round(p_to_date - p_from_date) / l_no_of_days;
    return ( l_ratio ) ;

EXCEPTION WHEN OTHERS THEN return -1;
END Billing_Charge_Ratio;
--
PROCEDURE ITEM_Interface_distributions (    pp_sc c_stand_charges%ROWTYPE
                                          , pp_ld c_line_details%ROWTYPE
                                          , pp_generate_sequence in number
                                          , pp_amount in number
                                          , pp_line_number in number
                                          , pp_raid_Table  in out NOCOPY RAID_TABLE
                                          , pp_curr_rec_idx in out NOCOPY BINARY_INTEGER
                                          , pp_curr_rev_idx in out NOCOPY BINARY_INTEGER
                                       ) IS
   l_raid_Table_old    RAID_TABLE      ;
   l_curr_rec_idx_old  BINARY_INTEGER  ;
   l_curr_rev_idx_old  BINARY_INTEGER  ;

BEGIN

   l_raid_Table_old    := pp_raid_Table;
   l_curr_rec_idx_old  := pp_curr_rec_idx;
   l_curr_rev_idx_old  := pp_curr_rev_idx;

/*
-- Build Receivable Account entry
*/
     IF pp_ld.RECEIVABLE_CODE_COMBINATION_ID IS NOT NULL THEN
           pp_raid_table ( pp_curr_rec_idx ).account_class             := RECEIVABLE_CODE;
           pp_raid_table ( pp_curr_rec_idx ).interface_line_context    := TRANSACTION_CODE;
           pp_raid_table ( pp_curr_rec_idx ).interface_line_attribute1 := pp_sc.standing_charge_id;
           pp_raid_table ( pp_curr_rec_idx ).interface_line_attribute2 := pp_generate_sequence;
           pp_raid_table ( pp_curr_rec_idx ).interface_line_attribute3 := pp_ld.charge_item_number;
           pp_raid_table ( pp_curr_rec_idx ).interface_line_attribute4 := pp_line_number;
           pp_raid_table ( pp_curr_rec_idx ).amount                    := pp_amount;
           pp_raid_table ( pp_curr_rec_idx ).percent                   := 0;
           pp_raid_table ( pp_curr_rec_idx ).code_combination_id       := pp_ld.RECEIVABLE_CODE_COMBINATION_ID;
           pp_raid_table ( pp_curr_rec_idx ).created_by                := pp_sc.created_by;
           pp_raid_table ( pp_curr_rec_idx ).creation_date             := sysdate;
           pp_raid_table ( pp_curr_rec_idx ).last_updated_by           := pp_sc.last_updated_by;
           pp_raid_table ( pp_curr_rec_idx ).last_update_date          := sysdate;
	   /*5905216*/
	   pp_raid_table ( pp_curr_rec_idx ).org_id		       := pp_sc.org_id;
          -- pp_curr_rec_idx := pp_curr_rec_idx -1;
          -- pp_curr_rec_idx := pp_curr_rec_idx +1;
     END IF;
/*
-- Generate the revenue account entries
*/
    IF pp_ld.REVENUE_CODE_COMBINATION_ID IS NOT NULL THEN
           pp_raid_table ( pp_curr_rev_idx ).account_class             := REVENUE_CODE;
           pp_raid_table ( pp_curr_rev_idx ).interface_line_context    := TRANSACTION_CODE;
           pp_raid_table ( pp_curr_rev_idx ).interface_line_attribute1 := pp_sc.standing_charge_id;
           pp_raid_table ( pp_curr_rev_idx ).interface_line_attribute2 := pp_generate_sequence;
           pp_raid_table ( pp_curr_rev_idx ).interface_line_attribute3 := pp_ld.charge_item_number;
           pp_raid_table ( pp_curr_rev_idx ).interface_line_attribute4 := pp_line_number;
           pp_raid_table ( pp_curr_rev_idx ).amount                    := pp_amount;
           pp_raid_table ( pp_curr_rev_idx ).code_combination_id       := pp_ld.REVENUE_CODE_COMBINATION_ID;
           pp_raid_table ( pp_curr_rev_idx ).created_by                := pp_sc.created_by;
           pp_raid_table ( pp_curr_rev_idx ).creation_date             := sysdate;
           pp_raid_table ( pp_curr_rev_idx ).last_updated_by           := pp_sc.last_updated_by;
           pp_raid_table ( pp_curr_rev_idx ).last_update_date          := sysdate;
	   /*5905216*/
	   pp_raid_table ( pp_curr_rev_idx ).org_id		       := pp_sc.org_id;
           IF nvl(pp_sc.rev_acc_allocation_rule,ALLOCATION_PERCENT_CODE)
           <> ALLOCATION_PERCENT_CODE
           AND nvl(pp_ld.accounting_rule_id,-1) = -1    THEN
               pp_raid_table ( pp_curr_rev_idx ).percent                   := NULL;
           ELSE
               pp_raid_table ( pp_curr_rev_idx ).percent                   := 0;
           END IF;
           pp_curr_rev_idx := pp_curr_rev_idx +1;
           --pp_curr_rev_idx := pp_curr_rev_idx -1;
   END IF;
EXCEPTION
  WHEN OTHERS THEN
   pp_raid_Table   := l_raid_Table_old;
   pp_curr_rec_idx := l_curr_rec_idx_old;
   pp_curr_rev_idx := l_curr_rev_idx_old;
   app_exception.raise_exception;
END ITEM_Interface_Distributions;

PROCEDURE   ITEM_Interface_salescredits ( pp_sc c_stand_charges%ROWTYPE
                                        , pp_rail in RAIL
                                        )
IS


    CURSOR   c_salescredits (cp_salesrep_id in number) IS
       SELECT ras.salesrep_id
            , ras.salesrep_number
            , ras.sales_credit_type_id
            , sct.name sales_credit_type_name
       FROM ra_salesreps ras
           , so_sales_credit_types sct
       WHERE ras.salesrep_id = cp_salesrep_id
       ;

    FUNCTION SalesCreditRuleAmt ( fp_batch_source_id in number) RETURN BOOLEAN
    IS
    CURSOR c_rule IS
        SELECT 'x'
        FROM   ra_batch_sources
        WHERE  batch_source_id = fp_batch_source_id
        AND    upper(sales_credit_rule) = upper('Amount')
        ;
    BEGIN
        FOR l_rule in c_rule LOOP
            return TRUE;
        END LOOP;

        return FALSE;
    EXCEPTION WHEN OTHERS THEN
                 return FALSE;
    END SalesCreditRuleAmt ;

    FUNCTION UseSalesCreditTypeValue ( fp_batch_source_id in number) RETURN BOOLEAN
    IS
       CURSOR c_typeid IS
        SELECT 'x'
        FROM   ra_batch_sources
        WHERE  batch_source_id = fp_batch_source_id
        AND    upper(sales_credit_type_rule) = upper('Value')
        ;
    BEGIN
        FOR l_type in c_typeid LOOP
            return TRUE;
        END LOOP;

        return FALSE;
    EXCEPTION WHEN OTHERS THEN
                 return FALSE;
    END UseSalesCreditTypeValue ;

    FUNCTION UseSalesRepNumber ( fp_batch_source_id in number) RETURN BOOLEAN
    IS
       CURSOR c_repid IS
        SELECT 'x'
        FROM   ra_batch_sources
        WHERE  batch_source_id = fp_batch_source_id
        AND    upper(salesperson_rule) = upper('Number')
        ;
    BEGIN
        FOR l_rep in c_repid LOOP
            return TRUE;
        END LOOP;

        return FALSE;
    EXCEPTION WHEN OTHERS THEN
                 return FALSE;
    END UseSalesRepNumber ;


    FUNCTION AlreadyExists  RETURN BOOLEAN IS
      CURSOR c_sales IS
        SELECT   'x'
        FROM     ra_interface_salescredits
        WHERE
            pp_rail.interface_line_context      = interface_line_context
        AND pp_rail.interface_line_attribute1   = interface_line_attribute1
        AND pp_rail.interface_line_attribute2   = interface_line_attribute2
        AND pp_rail.interface_line_attribute3   = interface_line_attribute3
        AND pp_rail.interface_line_attribute4   = interface_line_attribute4
        ;
    BEGIN
        FOR l_sales IN c_sales LOOP
            return TRUE;
        END LOOP;
        return FALSE;
    EXCEPTION WHEN OTHERS THEN
                 return FALSE;
    END AlreadyExists;

BEGIN

    IF  NOT UseSalesCredits ( pp_sc.batch_source_id ) THEN
             return;
    END IF;

 FOR l_sc in c_salescredits ( pp_sc.salesrep_id ) LOOP

    IF NOT AlreadyExists THEN

         INSERT INTO ra_interface_salescredits
                  (  interface_line_context
                  ,  interface_line_attribute1
                  ,  interface_line_attribute2
                  ,  interface_line_attribute3
                  ,  interface_line_attribute4
                  ,  sales_credit_amount_split
                  ,  sales_credit_percent_split
                  ,  sales_credit_type_name
                  ,   sales_credit_type_id
                  ,   salesrep_id
                  ,  salesrep_number
                  ,  created_by
                  ,  creation_date
                  ,  last_updated_by
                  ,  last_update_date
		/*5905216*/
		  ,  org_id
                                      )
         VALUES (   pp_rail.interface_line_context
                 ,  pp_rail.interface_line_attribute1
                 ,  pp_rail.interface_line_attribute2
                 ,  pp_rail.interface_line_attribute3
                 ,  pp_rail.interface_line_attribute4
                 ,  pp_rail.amount
                 ,  100
                 ,  l_sc.sales_credit_type_name
                 ,  l_sc.sales_credit_type_id
                 ,  l_sc.salesrep_id
                 ,  l_sc.salesrep_number
                 ,  pp_rail.created_by
                 ,  pp_rail.creation_date
                 ,  pp_rail.last_updated_by
                 ,  pp_rail.last_update_date
		 ,  pp_rail.org_id
               );
     END IF;

     END LOOP;
EXCEPTION
WHEN OTHERS THEN
return;

END         ITEM_Interface_salescredits  ;
-- ----------------------------------------------------------------------------------
PROCEDURE ITEM_Interface_taxes     (  pp_rail in   RAIL
       , pp_line_number in out NOCOPY number, pp_adhoc_tax in boolean ) IS

     l_rail RAIL;
     l_line_number NUMBER ;
     l_line_number_old NUMBER ;
BEGIN
     l_rail := pp_rail;
     l_line_number := pp_line_number + 1;
     l_line_number_old := pp_line_number;
     l_rail.line_type := 'TAX';

     IF l_rail.tax_code is null or (not pp_adhoc_tax) or
        l_rail.amount is null
     THEN
        return;
     END IF;

     INSERT INTO ra_interface_lines( batch_source_name     -- Mandatory
                                      , currency_code         -- Mandatory
                                      , line_type             -- Mandatory
                                      , set_of_books_id       -- Mandatory
                                      , description           -- Mandatory
                                      , conversion_type       -- MandatorY
                                      , tax_code
                                      , tax_rate
                                      , link_to_line_context
                                      , conversion_rate
                                      , cust_trx_type_id
                                      , interface_line_attribute1
                                      , interface_line_attribute2
                                      , interface_line_attribute3
                                      , interface_line_attribute4
                                      , link_to_line_attribute1
                                      , link_to_line_attribute2
                                      , link_to_line_attribute3
                                      , link_to_line_attribute4
                                      , interface_line_context
                                      , created_by
                                      , creation_date
                                      , last_updated_by
                                      , last_update_date
					/*5905216*/
				      , org_id
				      , legal_entity_id	)
              VALUES
                               (   l_rail.batch_source_name     -- Mandatory
                                 , l_rail.currency_code         -- Mandatory
                                 , l_rail.line_type             -- Mandatory
                                 , l_rail.set_of_books_id       -- Mandatory
                                 , l_rail.description           -- Mandatory
                                 , l_rail.conversion_type       -- MandatorY
                                 , l_rail.tax_code
                                 , l_rail.tax_rate
                                 , l_rail.link_to_line_context
                                 , l_rail.conversion_rate
                                 , l_rail.cust_trx_type_id
                                 , l_rail.interface_line_attribute1
                                 , l_rail.interface_line_attribute2
                                 , l_rail.interface_line_attribute3
                                 , l_line_number
                                 , l_rail.interface_line_attribute1
                                 , l_rail.interface_line_attribute2
                                 , l_rail.interface_line_attribute3
                                 , pp_line_number
                                 , l_rail.interface_line_context
                                 , l_rail.created_by
                                 , l_rail.creation_date
                                 , l_rail.last_updated_by
                                 , l_rail.last_update_date
				 , l_rail.org_id
				 , l_rail.legal_entity_id
                                );
               if sql%found then
                 pp_line_number := l_line_number + 1;
               end if;
EXCEPTION
  WHEN OTHERS THEN
    pp_line_number := l_line_number_old;
    app_exception.raise_exception;
END ITEM_Interface_taxes;
-- -------------------------------------------------------------------------------
PROCEDURE ITEM_Interface_lines     (  pp_rail in   RAIL
                                    , pp_price in number
                                    , pp_quantity in  number
                                    , pp_line_number in out NOCOPY number
                                    , pp_comment in varchar2
                                    , pp_sc c_stand_charges%ROWTYPE
                                    , pp_ld c_line_details%ROWTYPE
                                    , pp_from_date in date
                                    , pp_to_date   in date
                                   ) IS
  l_org_id    NUMBER;
  l_rail      RAIL ;
  l_date_info VARCHAR2(40);
  l_date_info_len NUMBER;
  l_line_number_old NUMBER ;
  v_precision NUMBER(1);
  v_min_acc_unit NUMBER;
BEGIN
  l_rail      := pp_rail;
  l_date_info := rtrim(pp_from_date||' - '||pp_to_date) ;
  l_date_info_len := 240 - (length ( l_date_info ) + length(' : '));
  l_line_number_old := pp_line_number;
/*Commeneted for Bug 5905216 - Used MO_GLOBAL instead of reading from profile*/
--  FND_PROFILE.GET( 'ORG_ID', l_org_id );
  l_org_id := mo_global.get_current_org_id();
  l_rail.org_id             := l_org_id;
  l_rail.unit_selling_price := round(pp_price,2);
  l_rail.quantity           := pp_quantity;
/* Code added for Amount validation against Precision by Shantanu for bug 6847437*/
/*Code Start*/
  SELECT C.PRECISION, C.MINIMUM_ACCOUNTABLE_UNIT
	INTO v_precision, v_min_acc_unit
	FROM FND_CURRENCIES C
	WHERE C.CURRENCY_CODE = l_rail.currency_code;

  If v_min_acc_unit IS NULL then
      l_rail.amount := ROUND((l_rail.unit_selling_price * pp_quantity),v_precision);
  else
      l_rail.amount := ROUND((l_rail.unit_selling_price * pp_quantity)/v_min_acc_unit) * v_min_acc_unit;
  end if;
/*Code End*/

/*Code commented by Shantanu for bug 6847437*/
  --l_rail.amount             := l_rail.unit_selling_price * pp_quantity;
  l_rail.line_number        := pp_line_number;
/* Removed the comments concatenated to the description  by Panaraya for bug 2413756*/
  l_rail.comments           := substr( rtrim(pp_sc.desc_1)
                            ,1,l_date_info_len);
  l_rail.comments           := l_rail.comments || ' : ' || l_date_info;
  -- Trim the spaces of the description!
  l_rail.description         := rtrim(pp_comment);
  l_rail.interface_line_attribute4 := pp_line_number ;
  l_rail.uom_name            := pp_ld.unit_of_measure;

  WriteToLogFile (l_state_level, 'igi.plsql.igirrpi.item_interface_lines.Msg1',
                                    'Item Amount to be invoiced '|| l_rail.amount );
  /** Insert normal LINE for this ITEM **/

  INSERT INTO ra_interface_lines_all ( accounting_rule_id
                                    , amount
                                    , batch_source_name       -- Mandatory
                                    , comments
                                    , description             -- Mandatory
                                    , currency_code           -- Mandatory
                                    , conversion_rate
                                    , conversion_type         -- Mandatory
--                                  , customer_bank_account_id  -- Bug 9496038  This column is obsolete
				    , PAYMENT_TRXN_EXTENSION_ID	/*Bug No 5905216 Payment Upgrade - for R12*/
                                    , cust_trx_type_id
                                    , interface_line_attribute1
                                    , interface_line_attribute2
                                    , interface_line_attribute3
                                    , interface_line_attribute4
                                    , interface_line_context
                                    , tax_code
                                    , tax_rate
                                    , link_to_line_context
                                    , invoicing_rule_id
                                    , line_number
                                    , line_type               -- Mandatory
                                    , orig_system_bill_customer_id
                                    , orig_system_bill_address_id
                                    , orig_system_bill_contact_id
                                    , orig_system_ship_customer_id
                                    , orig_system_ship_address_id
                                    , orig_system_ship_contact_id
                                    , primary_salesrep_id
                                    , printing_option
                                    , quantity
                                    , receipt_method_id
                                    , set_of_books_id         -- Mandatory
                                    , trx_date
                                    , uom_name
                                    , uom_code
                                    , unit_selling_price
                                    , created_by
                                    , creation_date
                                    , last_updated_by
                                    , last_update_date
                                    , accounting_rule_duration
                                    , rule_start_date
                                    , gl_date
                                    , term_id
					/*5905216*/
				    , org_id
				    , legal_entity_id
                            , TAX_RATE_CODE           /*Bug No 7606235*/
                            , TAXABLE_AMOUNT 	      /*Bug No 7606235*/ )
                     VALUES
                               ( l_rail.accounting_rule_id
                                    , l_rail.amount
                                    , l_rail.batch_source_name       -- Mandatory
                                    , l_rail.comments
                                    , l_rail.description             -- Mandatory
                                    , l_rail.currency_code           -- Mandatory
                                    , l_rail.conversion_rate
                                    , l_rail.conversion_type         -- Mandatory
--                                  , l_rail.customer_bank_account_id  -- Bug 9496038.This column is obsolete
				    , l_rail.payment_trxn_extension_id		/*Bug No 5905216 Payment Upgrade for R12*/
                                    , l_rail.cust_trx_type_id
                                    , l_rail.interface_line_attribute1
                                    , l_rail.interface_line_attribute2
                                    , l_rail.interface_line_attribute3
                                    , l_rail.interface_line_attribute4
                                    , l_rail.interface_line_context
                                    , l_rail.tax_code
                                    , l_rail.tax_rate
                                    , l_rail.link_to_line_context
                                    , l_rail.invoicing_rule_id
                                    , l_rail.line_number
                                    , l_rail.line_type               -- Mandatory
                                    , l_rail.orig_system_bill_customer_id
                                    , l_rail.orig_system_bill_address_id
                                    , l_rail.orig_system_bill_contact_id
                                    , l_rail.orig_system_ship_customer_id
                                    , l_rail.orig_system_ship_address_id
                                    , l_rail.orig_system_ship_contact_id
                                    , l_rail.primary_salesrep_id
                                    , l_rail.printing_option
                                    , l_rail.quantity
                                    , l_rail.receipt_method_id
                                    , l_rail.set_of_books_id         -- Mandatory
                                    , l_rail.trx_date
                                    , l_rail.uom_name
                                    , l_rail.uom_code
                                    , l_rail.unit_selling_price
                                    , l_rail.created_by
                                    , l_rail.creation_date
                                    , l_rail.last_updated_by
                                    , l_rail.last_update_date
                                    , l_rail.accounting_rule_duration
                                    , l_rail.rule_start_date
                                    , l_rail.gl_date
                                    , l_rail.term_id
				    , l_rail.org_id
				    , l_rail.legal_entity_id
 				    , l_rail.tax_code             /*Bug No 7606235*/
 				    , l_rail.amount	          /*Bug No 7606235*/ );
         -- CREATE THE ASSOCIATED DISTRIBUTION LINES FOR EACH ITEM
/*
-- Note here that the global variables are passed to this routine so that a
-- table is built with the 'REV' and 'REC' entries
-- g_raid_table is the TABLE
-- g_curr_rec_idx is the idx to show the last empty slot available for the next
-- 'REC' entry. This is -ve in value.
-- g_curr_rev_idx is the idx to show the last empty slot available for the next
-- 'REV' entry. This is +ve in value
--  ------------------------------------------------------------------------------
--    -M                                        0                                  N
--     <-      g_curr_rec_idx                   |         g_curr_rev_idx          ->
--             ( 'REC' entries )                |         ( 'REV' entries)
*/
            ITEM_Interface_taxes         ( pp_rail , pp_line_number, pp_ld.validate_flag = 'Y');

            ITEM_Interface_distributions (    pp_sc
                                          ,   pp_ld
                                          ,   pp_rail.interface_line_attribute2
                                          ,   l_rail.amount
                                          ,   l_rail.interface_line_attribute4
                                          ,   G_raid_Table
                                          ,   g_curr_rec_idx
                                          ,   g_curr_rev_idx
                                       ) ;

           ITEM_Interface_salescredits ( pp_sc
                                        , l_rail
                                        );
EXCEPTION WHEN OTHERS THEN
  pp_line_number := l_line_number_old;
  RAISE_APPLICATION_ERROR( - 20601, SQLERRM );
END ITEM_Interface_lines;
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
PROCEDURE PROCESS_PRICE_BREAKS ( pp_sc c_stand_charges%ROWTYPE
                               , pp_ld c_line_details%ROWTYPE
                               , pp_rail in out NOCOPY RAIL
                               , pp_ratio in NUMBER
                               , pp_from_date IN DATE
                               , pp_to_date   IN DATE
                               , pp_line_number in out NOCOPY number
                               ) IS
          l_break_ratio              number;
          l_break_start_date         date   ;
          l_break_end_date           date   ;
          l_break_number             integer ;
          l_break_info               varchar2(500) ;
          l_break_price              igi_rpi_line_details.price%TYPE;
          l_rail_old                 rail   ;
          l_line_number_old          number ;
BEGIN
          l_break_ratio              := pp_ratio;
          l_break_start_date         := pp_from_date;
          l_break_end_date           := pp_to_date;
          l_break_number             := 0;
          l_break_info               := null;
          l_rail_old                 := pp_rail;
          l_line_number_old          := pp_line_number;

          WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg1',
                                             'BEGIN Price Break Processing');
          WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg2',
                                             'Start Date '||l_Break_start_date||' End Date '||l_break_end_date);

         IF  pp_from_date = pp_to_date or pp_ratio = 0
             OR pp_from_date is null or pp_to_date is null THEN
             WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg3',
                                             'END Price Break Processing : Incorrect Parameters.');
             return;
         END IF;

         WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg4',
                                       'Previous Effective date '|| pp_ld.previous_effective_date );
         WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg5',
                                       'Previous Price          '|| pp_ld.previous_price );
         WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg6',
                                       'Current Effective date  '|| pp_ld.current_effective_Date );
         WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg7',
                                       'Current Price           '|| pp_ld.price );
         WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg8',
                                       'Revised Effective date  '|| pp_ld.revised_effective_date );
         WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg9',
                                       'Revised Price           '|| pp_ld.revised_price );

         --aa
         IF    pp_from_date  <=  nvl(pp_ld.current_effective_date, pp_from_date+1) THEN /**main **/
            WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg10',
                                          'From Date is Equal to or prior to the Current Eff Date');
            WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg11',
                                          'pp_to_date  '||pp_to_date||'    '||'effdat'||pp_ld.current_effective_date);
            --bb
            IF pp_to_date    >=   pp_ld.current_effective_date THEN
               pp_line_number        := pp_line_number +1;
               l_break_start_date   := pp_from_date;
               l_break_end_date     := pp_ld.current_effective_date - 1;

               WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg12',
                                  'l_break_end_date'||l_break_end_date);

               l_break_start_date   :=
                to_date(to_char(l_break_start_date,DEF_DATE_FORMAT)||BEGIN_DATE_TIME,RPI_DATE_FORMAT);

               WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg13',
                                  'l_break_start_date'||l_break_start_date);

               l_break_end_date   :=
               to_date(to_char(l_break_end_date,DEF_DATE_FORMAT)||END_DATE_TIME,RPI_DATE_FORMAT);


               WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg14',
                                  'l_break_end_date'||l_break_end_date);

               l_break_number       := l_break_number + 1;
               l_break_ratio        := pp_ratio * ( ( l_break_end_date - l_break_start_date)
                                              / ( pp_to_date - pp_from_date) );
               l_break_price        := pp_ld.previous_price;
               l_break_info         := pp_ld.desc_2||
                                 FROM_DATE_INFO||to_char(l_break_start_date)||
                                 TO_DATE_INFO||to_char(l_break_end_date);

               IF l_break_price * l_break_ratio <> 0 then
           	 WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg16',
                                          'in Break #1  before interface');

             	ITEM_Interface_lines     (  pp_rail
                                    , l_break_price * l_break_ratio
                                    , pp_ld.quantity
                                    , pp_line_number
                                    , substr(l_break_info,1,240)
                                    , pp_sc
                                    , pp_ld
                                    , pp_from_date
                                    , pp_to_date
                                   ) ;
         	END IF;
         	WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg17',
                                  'in cc');
         	WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg18',
                                  'pp_to_date='||pp_to_date||'   '||'effdat'||pp_ld.revised_effective_date);

                IF pp_to_date >=  pp_ld.revised_effective_date THEN
                   pp_line_number        := pp_line_number +1;
                   l_break_start_date   := pp_ld.current_effective_date;
                   IF pp_to_date > pp_ld.revised_effective_Date THEN
                       l_break_end_date     := pp_ld.revised_effective_date -1 ;
                   ELSE
                       l_break_end_date     := pp_to_Date;
                   END IF;
               l_break_start_date   :=
           	 to_date(to_char(l_break_start_date,DEF_DATE_FORMAT)||BEGIN_DATE_TIME,RPI_DATE_FORMAT);
       	       l_break_end_date   :=
                 to_date(to_char(l_break_end_date,DEF_DATE_FORMAT)||END_DATE_TIME,RPI_DATE_FORMAT);
               l_break_number       := l_break_number + 1;
               l_break_ratio        := pp_ratio * ( ( l_break_end_date - l_break_start_date)
                                              / ( pp_to_date - pp_from_date) );
               l_break_price        := pp_ld.price;
               l_break_info         :=  pp_ld.desc_2||
                                 FROM_DATE_INFO||to_char(l_break_start_date)||
                                 TO_DATE_INFO||to_char(l_break_end_date);
               WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg19',
                                              'Break #2 '||l_break_info );
               WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg20',
                                              'diff='||to_char(l_break_end_date-l_break_start_date));


               ITEM_Interface_lines     (  pp_rail
                                    , l_break_price * l_break_ratio
                                    , pp_ld.quantity
                                    , pp_line_number
                                    , substr(l_break_info,1,240)
                                    , pp_sc
                                    , pp_ld
                                    , pp_from_date
                                    , pp_to_date
                                   ) ;
               WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg21',
                                  'pp_to_date='||to_char(pp_to_date,'dd-mm-yyyy hh24:mi:ss'));
 		   WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg22',
                                  'l_break_end_date='||to_char(l_break_end_date,'dd-mm-yyyy hh24:mi:ss'));
   		 WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg23',
                                  'pp_ld.revised_effective_date='||to_char(pp_ld.revised_effective_date,'dd-mm-yyyy hh24:mi:ss'));

               IF pp_to_date > l_break_end_date
                  and pp_from_date <> pp_ld.revised_effective_date THEN --4525139
                  pp_line_number        := pp_line_number +1;
            	l_break_start_date   := pp_ld.revised_effective_date;
            	l_break_end_date     := pp_to_date ;
            	l_break_start_date   :=
	            to_date(to_char(l_break_start_date,DEF_DATE_FORMAT)||BEGIN_DATE_TIME,RPI_DATE_FORMAT);
        	    l_break_end_date   :=
	            to_date(to_char(l_break_end_date,DEF_DATE_FORMAT)||END_DATE_TIME,RPI_DATE_FORMAT);
	            l_break_number       := l_break_number + 1;
	    WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg24',
                                  'diff='||to_char(l_break_end_date-l_break_start_date));
            l_break_ratio        := pp_ratio * ( ( l_break_end_date - l_break_start_date)
                                              / ( pp_to_date - pp_from_date) );
            l_break_price        := pp_ld.revised_price;
            l_break_info         :=  pp_ld.desc_2||
                                 FROM_DATE_INFO||to_char(l_break_start_date)||
                                 TO_DATE_INFO||to_char(l_break_end_date);
            WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg25',
                                                     'Break #3 '|| l_break_info );
                   if l_break_price * l_break_ratio <> 0 then


                             ITEM_Interface_lines     (  pp_rail
                                    , l_break_price * l_break_ratio
                                    , pp_ld.quantity
                                    , pp_line_number
                                    , substr(l_break_info,1,240)
                                    , pp_sc
                                    , pp_ld
                                    , pp_from_date
                                    , pp_to_date
                                   ) ;
                  end if;
           END IF;
         ELSE
            pp_line_number        := pp_line_number +1;
            l_break_start_date   := pp_ld.current_effective_date;
            l_break_end_date     := pp_to_date ;
            l_break_start_date   :=
            to_date(to_char(l_break_start_date,DEF_DATE_FORMAT)||BEGIN_DATE_TIME,RPI_DATE_FORMAT);
            l_break_end_date   :=
            to_date(to_char(l_break_end_date,DEF_DATE_FORMAT)||END_DATE_TIME,RPI_DATE_FORMAT);
            l_break_number       := l_break_number + 1;
            l_break_ratio        := pp_ratio * ( ( l_break_end_date - l_break_start_date)
                                              / ( pp_to_date - pp_from_date) );
            l_break_price        := pp_ld.price;
            l_break_info         :=  pp_ld.desc_2||
                                 FROM_DATE_INFO||to_char(l_break_start_date)||
                                 TO_DATE_INFO||to_char(l_break_end_date);
                WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg26',
                                              'Break #4 '|| l_break_info );
                   if l_break_price * l_break_ratio <> 0 then


                             ITEM_Interface_lines     (  pp_rail
                                    , l_break_price * l_break_ratio
                                    , pp_ld.quantity
                                    , pp_line_number
                                    , substr(l_break_info,1,240)
                                    , pp_sc
                                    , pp_ld
                                    , pp_from_date
                                    , pp_to_date
                                   ) ;
                  end if;
         END IF; -- cc
     ELSE  -- bb
         WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg27',
                                           ' From date is being processed here.');
         pp_line_number        := pp_line_number +1;
         l_break_start_date   := pp_from_date;
         l_break_end_date     := pp_to_date;
         l_break_start_date   :=
            to_date(to_char(l_break_start_date,DEF_DATE_FORMAT)||BEGIN_DATE_TIME,RPI_DATE_FORMAT);
         l_break_end_date   :=
            to_date(to_char(l_break_end_date,DEF_DATE_FORMAT)||END_DATE_TIME,RPI_DATE_FORMAT);
         l_break_ratio        := pp_ratio * ( ( l_break_end_date - l_break_start_date)
                                              / ( pp_to_date - pp_from_date) );
         l_break_info         :=  pp_ld.desc_2||
                                 FROM_DATE_INFO||to_char(l_break_start_date)||
                                 TO_DATE_INFO||to_char(l_break_end_date);
         l_break_price        := pp_ld.previous_price;
         WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg28',
                                                     'Break #6 '|| l_break_info );
                   if l_break_price * l_break_ratio <> 0 then


                             ITEM_Interface_lines     (  pp_rail
                                    , l_break_price * l_break_ratio
                                    , pp_ld.quantity
                                    , pp_line_number
                                    , substr(l_break_info,1,240)
                                    , pp_sc
                                    , pp_ld
                                    , pp_from_date
                                    , pp_to_date
                                   ) ;
                  end if;
      END IF;  -- bb

   END IF; -- aa

   IF pp_from_date <= nvl(pp_ld.revised_effective_date-1,pp_to_date) -- aa
         AND pp_from_date > pp_ld.current_effective_date
   THEN
     -- dd
         WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg29',
                                       'From Date is Equal to or prior to the Rev Eff Date -1');

     IF pp_to_date    >=   pp_ld.revised_effective_date-1 and
        pp_ld.revised_effective_date is not null
     THEN
         pp_line_number        := pp_line_number +1;
         l_break_start_date   := pp_from_date;
         l_break_end_date     := pp_ld.revised_effective_date-1;
         l_break_start_date   :=
            to_date(to_char(l_break_start_date,DEF_DATE_FORMAT)||BEGIN_DATE_TIME,RPI_DATE_FORMAT);
         l_break_end_date   :=
            to_date(to_char(l_break_end_date,DEF_DATE_FORMAT)||END_DATE_TIME,RPI_DATE_FORMAT);
         l_break_number       := l_break_number + 1;
         l_break_ratio        := pp_ratio * ( ( l_break_end_date - l_break_start_date)
                                              / ( pp_to_date - pp_from_date) );
         l_break_price        := pp_ld.price;
         l_break_info         :=  pp_ld.desc_2||
                                 FROM_DATE_INFO||to_char(l_break_start_date)||
                                 TO_DATE_INFO||to_char(l_break_end_date);
         WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg30',
                                                     'Break #7 '||l_break_info );
                   if l_break_price * l_break_ratio <> 0 then

                             ITEM_Interface_lines     (  pp_rail
                                    , l_break_price * l_break_ratio
                                    , pp_ld.quantity
                                    , pp_line_number
                                    , substr(l_break_info,1,240)
                                    , pp_sc
                                    , pp_ld
                                    , pp_from_date
                                    , pp_to_date
                                   ) ;
                  end if;
         -- ee
         IF pp_to_date >=  pp_ld.revised_effective_date THEN
            pp_line_number        := pp_line_number +1;
            l_break_start_date   := pp_ld.revised_effective_date;
            l_break_end_date     := pp_to_date ;
            l_break_number       := l_break_number + 1;
         l_break_start_date   :=
            to_date(to_char(l_break_start_date,DEF_DATE_FORMAT)||BEGIN_DATE_TIME,RPI_DATE_FORMAT);
         l_break_end_date   :=
            to_date(to_char(l_break_end_date,DEF_DATE_FORMAT)||END_DATE_TIME,RPI_DATE_FORMAT);
            l_break_ratio        := pp_ratio * ( ( l_break_end_date - l_break_start_date)
                                              / ( pp_to_date - pp_from_date) );
            l_break_price        := pp_ld.revised_price;
            l_break_info         :=  pp_ld.desc_2||
                                 FROM_DATE_INFO||to_char(l_break_start_date)||
                                 TO_DATE_INFO||to_char(l_break_end_date);
                          WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg31',
                                                        'Break #8 '||l_break_info );
                   if l_break_price * l_break_ratio <> 0 then


                             ITEM_Interface_lines     (  pp_rail
                                    , l_break_price * l_break_ratio
                                    , pp_ld.quantity
                                    , pp_line_number
                                    , substr(l_break_info,1,240)
                                    , pp_sc
                                    , pp_ld
                                    , pp_from_date
                                    , pp_to_date
                                   ) ;
                  end if;
         END IF;
       ELSE   -- dd
            pp_line_number        := pp_line_number +1;
            l_break_start_date   := pp_from_date;
            l_break_end_date     := pp_to_date ;
         l_break_start_date   :=
            to_date(to_char(l_break_start_date,DEF_DATE_FORMAT)||BEGIN_DATE_TIME,RPI_DATE_FORMAT);
         l_break_end_date   :=
            to_date(to_char(l_break_end_date,DEF_DATE_FORMAT)||END_DATE_TIME,RPI_DATE_FORMAT);
            l_break_ratio        := pp_ratio * ( ( l_break_end_date - l_break_start_date)
                                              / ( pp_to_date - pp_from_date) );
                WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg32',
                                              'Ratio for NPBUCP is '||l_Break_ratio);
            l_break_price        := pp_ld.price;
            l_break_info         :=  pp_ld.desc_2||
                                 FROM_DATE_INFO||to_char(l_break_start_date)||
                                 TO_DATE_INFO||to_char(l_break_end_date);
                          WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg33',
                                                        'Break #9 '||l_break_info );
                   if l_break_price * l_break_ratio <> 0 then


                             ITEM_Interface_lines     (  pp_rail
                                    , l_break_price * l_break_ratio
                                    , pp_ld.quantity
                                    , pp_line_number
                                    , substr(l_break_info,1,240)
                                    , pp_sc
                                    , pp_ld
                                    , pp_from_date
                                    , pp_to_date
                                   ) ;
                  end if;
       END IF; -- dd
   END IF; -- aa

   IF pp_from_date  >= pp_ld.revised_effective_date THEN
          pp_line_number        := pp_line_number +1;
            l_break_start_date   := pp_from_date;
            l_break_end_date     := pp_to_date ;
         l_break_start_date   :=
            to_date(to_char(l_break_start_date,DEF_DATE_FORMAT)||BEGIN_DATE_TIME,RPI_DATE_FORMAT);
         l_break_end_date   :=
            to_date(to_char(l_break_end_date,DEF_DATE_FORMAT)||END_DATE_TIME,RPI_DATE_FORMAT);

                        l_break_ratio        := pp_ratio * ( ( l_break_end_date - l_break_start_date)
                                              / ( pp_to_date - pp_from_date) );

            l_break_price        := pp_ld.revised_price;
            l_break_info         :=  pp_ld.desc_2||
                                 FROM_DATE_INFO||to_char(l_break_start_date)||
                                 TO_DATE_INFO||to_char(l_break_end_date);
                  WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg34',
                                                'Break #10'||l_break_info);
                  WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg35',
                                                'price in 10='||l_break_price*l_break_ratio);

                   if l_break_price * l_break_ratio <> 0 then


                             ITEM_Interface_lines     (  pp_rail
                                    , l_break_price * l_break_ratio
                                    , pp_ld.quantity
                                    , pp_line_number
                                    , substr(l_break_info,1,240)
                                    , pp_sc
                                    , pp_ld
                                    , pp_from_date
                                    , pp_to_date
                                   ) ;

                  end if;
   END IF; -- aa
       WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg36',
                                     'END (Successful) Price Break Processing');

EXCEPTION WHEN OTHERS THEN

    pp_rail        := l_rail_old;
    pp_line_number := l_line_number_old;
    WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_price_breaks.Msg37',
                                     'END (Error) Price Break Processing');
    RAISE_APPLICATION_ERROR (-20301, SQLERRM );
END PROCESS_PRICE_BREAKS;
--
-- Prorate Revenue at distribution level
--
PROCEDURE PROCESS_REC_DISTRIBUTIONS ( pp_sc c_stand_charges%ROWTYPE
                                , pp_curr_rec_idx       in BINARY_INTEGER
                                , pp_curr_rev_idx       in BINARY_INTEGER
                                , pp_raid_table         in out NOCOPY RAID_TABLE
                                 ) IS
    idx BINARY_INTEGER;
    l_total_rev_amt NUMBER ;
    l_total_rec_amt NUMBER ;
    l_raid_table_old RAID_TABLE ;
err_msg VARCHAR2(512);
BEGIN
    l_total_rev_amt := 0;
    l_total_rec_amt := 0;
    l_raid_table_old := pp_raid_table;
/*
-- Get the totals for all 'REV' entries
*/


l_total_rec_amt := 0;
               idx := 0;

             while idx < pp_curr_rev_idx  LOOP
                IF pp_raid_table.exists( idx ) THEN
                   IF pp_raid_table( idx ).account_class = REVENUE_CODE THEN
                      l_total_rec_amt := l_total_rec_amt + pp_raid_table( idx ).
amount;
                   END IF;
                END IF;
                idx :=  pp_raid_Table.next ( idx );
            END LOOP;

           idx := pp_curr_rec_idx;


              WHILE idx < 0 LOOP
                IF pp_raid_table.exists( idx ) THEN

                   IF  pp_raid_table( idx).account_class = RECEIVABLE_CODE THEN
                           pp_raid_table( idx ).percent :=  100;
                           pp_raid_table(idx).amount :=l_total_rec_amt;
                   END IF;
                END IF;
                idx :=  pp_raid_Table.next ( idx );

            END LOOP;

             --idx := 0;
             idx := g_curr_rec_idx;

               WHILE  idx < 0 LOOP


                IF pp_raid_table.exists( idx ) THEN


                    INSERT INTO ra_interface_distributions(  account_class    -- Mandatory
                                      ,  interface_line_context
                                      ,  interface_line_attribute1
                                      ,  interface_line_attribute2
                                      ,  interface_line_attribute3
                                      ,  interface_line_attribute4
                                      ,  amount
                                      ,  percent
                                      ,  code_combination_id
                                      ,  created_by
                                      ,  creation_date
                                      ,  last_updated_by
                                      ,  last_update_date
					/*5905216*/
				      ,  org_id
                                      )
                     VALUES
                                    (    pp_raid_table ( idx ).account_class    -- Mandatory
                                      ,  pp_raid_table ( idx ).interface_line_context
                                      ,  pp_raid_table ( idx ).interface_line_attribute1
                                      ,  pp_raid_table ( idx ).interface_line_attribute2
                                      ,  pp_raid_table ( idx ).interface_line_attribute3
                                      ,  pp_raid_table ( idx ).interface_line_attribute4
                                      ,  pp_raid_table ( idx ).amount
                                      ,  pp_raid_table ( idx ).percent
                                      ,  pp_raid_table ( idx ).code_combination_id
                                      ,  pp_raid_table ( idx ).created_by
                                      ,  pp_raid_table ( idx ).creation_date
                                      ,  pp_raid_table ( idx ).last_updated_by
                                      ,  pp_raid_table ( idx ).last_update_date
				      ,  pp_raid_table ( idx ).org_id
                                      );

                END IF;
                idx :=  pp_raid_Table.next ( idx );
             END LOOP;

                    idx := g_curr_rec_idx;
                   WHILE idx < 0 LOOP
                IF pp_raid_table.exists( idx ) THEN
                   pp_raid_table.delete( idx );
                END IF;
                idx := pp_raid_Table.next ( idx );
             END LOOP;

              idx := 0;
             WHILE idx <= pp_curr_rev_idx LOOP
                IF pp_raid_table.exists( idx ) THEN
                   pp_raid_table.delete( idx );
                END IF;
                idx := pp_raid_Table.next ( idx );
             END LOOP;
EXCEPTION
  WHEN OTHERS THEN
     pp_raid_table := l_raid_table_old;
     app_exception.raise_exception;
END PROCESS_REC_DISTRIBUTIONS;
/*
--
-- Distribute the receivables accounts and ensure that it follows
-- all the rules as explained in the Open Interfaces Manual.
--
*/
PROCEDURE PROCESS_REV_DISTRIBUTIONS ( pp_sc c_stand_charges%ROWTYPE
                                , pp_curr_rev_idx       in BINARY_INTEGER
                                , pp_raid_table         in out NOCOPY RAID_TABLE
                                 ) IS
    idx BINARY_INTEGER;
    l_total_rec_amt NUMBER ;
    l_total_rev_amt NUMBER ;
    l_raid_table_old RAID_TABLE ;
err_msg VARCHAR2(512);
BEGIN
    l_total_rec_amt := 0;
    l_total_rev_amt := 0;
    l_raid_table_old := pp_raid_table;
/*
-- Get the totals for all 'REC' and 'REV' entries
*/
             l_total_rec_amt := 0;

               idx := 0;

             while idx < pp_curr_rev_idx  LOOP
                IF pp_raid_table.exists( idx ) THEN
                   IF pp_raid_table( idx ).account_class = REVENUE_CODE THEN
                      l_total_rec_amt := l_total_rec_amt + pp_raid_table( idx ).amount;
                   END IF;
                END IF;
                idx :=  pp_raid_Table.next ( idx );
            END LOOP;



              idx := 0;

                while idx <= pp_curr_rev_idx LOOP
                IF pp_raid_table.exists( idx ) THEN
                   IF pp_raid_table( idx ).account_class = REVENUE_CODE THEN
                       pp_raid_table(idx).percent := 100;
                   END IF;
                END IF;
                idx :=  pp_raid_Table.next ( idx );
            END LOOP;

         idx := 0;

            WHILE rev_idx < g_curr_rev_idx LOOP



                IF pp_raid_table.exists( rev_idx ) THEN

                    INSERT INTO ra_interface_distributions(  account_class    -- Mandatory
                                      ,  interface_line_context
                                      ,  interface_line_attribute1
                                      ,  interface_line_attribute2
                                      ,  interface_line_attribute3
                                      ,  interface_line_attribute4
                                      ,  amount
                                      ,  percent
                                      ,  code_combination_id
                                      ,  created_by
                                      ,  creation_date
                                      ,  last_updated_by
                                      ,  last_update_date
					/*5905216*/
				      ,  org_id
                                      )
                     VALUES
                                    (    pp_raid_table ( rev_idx ).account_class    -- Mandatory
                                      ,  pp_raid_table ( rev_idx ).interface_line_context
                                      ,  pp_raid_table ( rev_idx ).interface_line_attribute1
                                      ,  pp_raid_table ( rev_idx ).interface_line_attribute2
                                      ,  pp_raid_table ( rev_idx ).interface_line_attribute3
                                      ,  pp_raid_table ( rev_idx ).interface_line_attribute4
                                      ,  pp_raid_table ( rev_idx ).amount
                                      ,  pp_raid_table ( rev_idx ).percent
                                      ,  pp_raid_table ( rev_idx ).code_combination_id
                                      ,  pp_raid_table ( rev_idx ).created_by
                                      ,  pp_raid_table ( rev_idx ).creation_date
                                      ,  pp_raid_table ( rev_idx ).last_updated_by
                                      ,  pp_raid_table ( rev_idx ).last_update_date
				      ,  pp_raid_table ( rev_idx ).org_id
                                      );


                END IF;

        rev_idx := rev_idx+1;
             END LOOP;

                  idx := 0;
EXCEPTION
  WHEN OTHERS THEN
     pp_raid_table := l_raid_table_old;
     app_exception.raise_exception;
END PROCESS_REV_DISTRIBUTIONS;
PROCEDURE PROCESS_DATE_RANGES( pp_sc_period_name         in varchar2
                             , pp_sc_advance_arrears_ind in varchar2
                             , pp_sc_start_date          in date
                             , pp_sc_end_date            in date
                             , pp_sc_next_due_date       in date
                             , pp_sc_prev_due_date       in date
                             , pp_date_range_idx         in out NOCOPY binary_integer
                             , pp_date_range_table       in out NOCOPY DATE_RANGE_TABLE
                             )
IS
      l_start_date date;
  --     l_date_end date;
      l_temp_Date date;
      l_final_date date ;
      l_prev_date  date ;
      l_new_prev_due_date date;
      l_new_next_due_date date;
      l_schedule_id       number;
      l_factor            number;
      l_ratio             number;
      l_component         varchar2(40);
      l_range             number;
      l_dummy             number;
      l_date_range_idx_old binary_integer      ;
      l_date_range_table_old DATE_RANGE_TABLE  ;

  BEGIN

      l_final_date := pp_sc_next_due_date;
      l_date_range_idx_old := pp_date_range_idx;
      l_date_range_table_old := pp_date_range_table;

      Next_Due_Dates (  pp_curr_next_due_date    => pp_sc_next_due_date
                       ,  pp_period_name         => pp_sc_period_name
                       ,  pp_advance_arrears_ind => pp_sc_advance_arrears_ind
                       ,  pp_new_prev_due_date   => l_prev_date
                       ,  pp_new_next_due_date   => l_final_date
                       ,  pp_new_schedule_id     => l_schedule_id
                       ,  pp_new_factor          => l_factor
                       ,  pp_new_component       => l_component
                       );

     pp_date_range_idx := 1;
         WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_date_ranges.Msg1',
                                       'New  Next Due date '|| l_final_date );
         WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_date_ranges.Msg2',
                                       'New  Prev Due date '|| l_prev_date);
         WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_date_ranges.Msg3',
                                       'Curr Prev Due date '|| pp_sc_prev_due_date);
         WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_date_ranges.Msg4',
                                       'Curr Next Due date '|| pp_sc_next_due_date);
         WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_date_ranges.Msg5',
                                       'Start date         '|| pp_sc_start_date );
         WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_date_ranges.Msg6',
                                       'End   date         '|| pp_sc_end_date   );


     if nvl(pp_sc_advance_arrears_ind,'ADVANCE') = 'ADVANCE'
     then
             WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_date_ranges.Msg7',
                                           'End date = '||pp_sc_end_date);
         IF pp_sc_end_date < l_final_date THEN
           l_final_date := pp_sc_end_date+1;
               WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_date_ranges.Msg8',
                                             'Final date = '||l_final_date);
         END IF;

             WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_date_ranges.Msg9',
                                           pp_sc_next_due_date||'          '||l_final_date ||' a ' );

         IF (pp_sc_next_due_date < pp_sc_start_date) THEN
           pp_date_range_table(pp_date_range_idx).start_date        := pp_sc_start_date;
         ELSE
           pp_date_range_table(pp_date_range_idx).start_date        := pp_sc_next_due_date;
         END IF;

         pp_date_range_table(pp_date_range_idx).actual_start_date   := pp_sc_next_due_date;
         pp_date_range_table(pp_date_range_idx).end_date            := l_final_date -1;

     else /* for arrears */

         pp_date_range_table(pp_date_range_idx).start_date          := l_prev_date;
         pp_date_range_table(pp_date_range_idx).actual_start_date   := l_prev_date;
             WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_date_ranges.Msg10',
                                           'Prev due date '|| l_prev_date );
             WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_date_ranges.Msg11',
                                           'Start date    '|| pp_sc_start_date );

         if (pp_sc_start_date > l_prev_date) -- and (pp_sc_prev_due_date is null)
         then
           pp_date_range_table(pp_date_range_idx).start_date   := pp_sc_start_date;
               WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_date_ranges.Msg12',
                                             'start date '|| pp_sc_start_date );
         end if;

         /* Bug 2436978 ssemwal added if condition for end date validation */
         IF pp_sc_end_date < pp_sc_next_due_date THEN
	           pp_date_range_table(pp_date_range_idx).end_date := pp_sc_end_date;
                    WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_date_ranges.Msg13',
                                                  'Final date = '||pp_sc_end_date);
          ELSE
          	pp_date_range_table(pp_date_range_idx).end_date     := pp_sc_next_due_date - 1;
          END IF;
     end if;
EXCEPTION
  WHEN OTHERS THEN
    pp_date_range_idx    := l_date_range_idx_old;
    pp_date_range_table  := l_date_range_table_old;
    app_exception.raise_exception;
END PROCESS_DATE_RANGES;

PROCEDURE PROCESS_CHARGES ( pp_sc c_stand_charges%ROWTYPE
                          , pp_ld c_line_details%ROWTYPE
                          , pp_generate_sequence in number
                          , pp_date_range_table IN OUT NOCOPY DATE_RANGE_TABLE
                          , pp_date_range_idx   IN OUT NOCOPY BINARY_INTEGER
                          ) IS
     l_rail   RAIL;  -- Ra interface ITEM lines record
     l_from_date date;  -- Start date for billing
     l_end_date  date;  -- End   date for billing
     l_ratio     number; -- Ratio of charge vs billing period
     l_quarter_days number;       --billing schedule info for 1/4 Days.

     l_date_range_idx_old binary_integer     ;
     l_date_range_table_old DATE_RANGE_TABLE ;

     FUNCTION IsVariableRule ( fp_rule_id in number)
     return BOOLEAN IS
       CURSOR c_var is
           select 'x'
           from   ra_rules
           where  rule_id = fp_rule_id
           and    type    = 'ACC_DUR'
           ;
     BEGIN
       for l_var in c_var loop
          return TRUE;
       end loop;
       return FALSE;
     END IsVariableRule;
 BEGIN

     l_quarter_days := 0;
     l_date_range_idx_old := pp_date_range_idx;
     l_date_range_table_old := pp_date_range_table;
        WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_charges.Msg1',
                                      'BEGIN  Process Standing Charges');
    /** Initialize the interface lines grouping information **/
        WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_charges.Msg2',
                                      'Charge reference '|| pp_sc.charge_reference );
    l_rail.interface_line_attribute1 := pp_sc.standing_charge_id;
    l_rail.interface_line_attribute2 := pp_generate_sequence      ;
    l_rail.interface_line_attribute3 := pp_ld.charge_item_number  ;
    l_rail.interface_line_attribute4 := pp_generate_sequence      ;
    l_rail.interface_line_context    := TRANSACTION_CODE;
    l_rail.accounting_rule_id        := pp_ld.accounting_rule_id ;
    l_rail.batch_source_name         := pp_sc.bs_name;
    l_rail.comments                  := null;
    l_rail.description               := pp_sc.desc_1;
    l_rail.currency_code             := pp_sc.currency_code;
    l_rail.conversion_rate           := '1';
    l_rail.conversion_type           := USER_CODE;
--  l_rail.customer_bank_account_id  := pp_sc.bank_account_id;     -- Bug 9496038.This column is obsolete
    l_rail.payment_trxn_extension_id := pp_sc.payment_trxn_extension_id;
    l_rail.cust_trx_type_id          := pp_sc.cust_trx_type_id;
    l_rail.tax_code                  := pp_ld.tax_rate_code;                /* Bug 7606235 */
    l_rail.tax_rate                  := pp_ld.percentage_rate;              /* Bug 7606235 */
    l_rail.link_to_line_context      := TRANSACTION_CODE;
/*  Line number and tax line number depends on price breaks */
/*  Defaulting values here                                  */
    l_rail.line_number               := '1';
    l_rail.line_type                 :=  LINE_CODE;
    l_rail.orig_system_bill_customer_id :=  pp_sc.bill_to_customer_id;
    l_rail.orig_system_bill_address_id  :=  pp_sc.bill_to_address_id;
    l_rail.orig_system_bill_contact_id  :=  pp_sc.bill_to_contact_id;
    l_rail.orig_system_ship_customer_id :=  pp_sc.ship_to_customer_id;
    l_rail.orig_system_ship_address_id  :=  pp_sc.ship_to_address_id;
    l_rail.orig_system_ship_contact_id  :=  pp_sc.ship_to_contact_id;
    l_rail.primary_salesrep_id          :=  pp_sc.salesrep_id;
     SELECT decode(pp_sc.suppress_inv_print,'Y','PRI','NOT')
     INTO l_rail.printing_option
     FROM sys.dual;
    l_rail.quantity                     :=  pp_ld.quantity;
    l_rail.set_of_books_id              :=  pp_sc.set_of_books_id;
    l_rail.receipt_method_id            :=  pp_sc.receipt_method_id;
    l_rail.trx_date                     :=  pp_sc.next_due_date;
    l_rail.uom_code                     :=  pp_ld.uom_uom_code;
    l_rail.uom_name                     :=  pp_ld.ld_period_name;
    l_rail.term_id                      :=  pp_sc.term_id;
    l_rail.created_by                   :=  pp_sc.created_by;
    l_rail.creation_date                :=  pp_sc.sysdate;
    l_rail.last_updated_by              :=  pp_sc.created_by;
    l_rail.last_update_date             :=  pp_sc.sysdate;
    l_rail.gl_date                      :=  pp_sc.standing_charge_date;
/*5905216*/
    l_rail.legal_entity_id		:= pp_sc.legal_entity_id;
    IF pp_sc.advance_arrears_ind  IS NULL THEN
       l_rail.accounting_rule_id := null;
       l_rail.invoicing_rule_id  := null;
       l_rail.rule_start_date := null;
       l_rail.accounting_rule_duration   := null;
    ELSE
       IF  l_rail.accounting_rule_id is not null
       then
           l_rail.invoicing_rule_id := Get_invoicing_rule
                                     ( pp_sc.advance_arrears_ind );
              WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_charges.Msg3',
                                            'Charge reference '|| pp_sc.charge_reference );
/* Added by Panaraya for bug 2439363 - Start */
	 IF (nvl(pp_sc.advance_arrears_ind,'ARREARS')= ARREARS_STATUS ) THEN
            l_rail.gl_date := null;
	 END IF;
/* Added by Panaraya for bug 2439363 - End */
--for bug 2706422, praghura . start.
        l_rail.accounting_rule_duration := pp_ld.duration;
        l_rail.rule_start_date := pp_ld.start_date;
--for bug 2706422, praghura . end.
        IF IsVariableRule( l_rail.accounting_rule_id )
           then
               l_rail.accounting_rule_duration
                           := pp_ld.duration;
               l_rail.rule_start_date
                           := nvl(pp_ld.start_date,pp_sc.standing_charge_date);
           else
               l_rail.accounting_rule_duration := null;
               l_rail.rule_start_date := null;
           END IF;
       ELSE
           l_rail.invoicing_rule_id := NULL;
           l_rail.rule_start_date := null;
           l_rail.accounting_rule_duration   := null;
           l_rail.gl_date := pp_sc.standing_charge_date;
       END IF;
    END IF;
    /** Now start computing the date ranges **/
         WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_charges.Msg3',
                                       '*** Begin of Process date ranges *** ');

    PROCESS_DATE_RANGES( pp_sc_period_name         => pp_sc.sc_period_name
                       , pp_sc_advance_arrears_ind => nvl(pp_sc.advance_arrears_ind,pp_sc.default_invoicing_rule)
                       , pp_sc_start_date          => pp_sc.start_date
                       , pp_sc_end_date            => pp_sc.end_date
                       , pp_sc_next_due_date       => pp_sc.next_due_date
                       , pp_sc_prev_due_date       => pp_sc.previous_due_date
                       , pp_date_range_idx         => pp_date_range_idx
                       , pp_date_range_table       => pp_date_range_table
                       );

         WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_charges.Msg4',
                                       '*** End of Process date ranges *** ');

    declare
      l_binary_idx binary_integer ;
      io_ratio    number;
      l_new_prev_due_date2 date;
      l_new_next_due_date2 date;
      l_new_prev_due_date  date;
      l_new_next_due_date  date;
      l_charge_schedule number;
      l_charge_factor   number;
      l_charge_component varchar2(40);
      l_billing_schedule number;
      l_billing_factor   number;
      l_billing_component varchar2(40);
      l_days_ratio       number ;
      l_line_number      number ;

      FUNCTION Get_Days_Ratio ( pp_start_date in date,
                                pp_actual_start_date in date,
                                pp_end_date   in date )
      RETURN NUMBER IS
         l_factor number := 1;
      BEGIN
           select   (  to_date(to_char(pp_end_date,DEF_DATE_FORMAT)||END_DATE_TIME,RPI_DATE_FORMAT)
                     - to_date(to_char(pp_start_date,DEF_DATE_FORMAT)||BEGIN_DATE_TIME,RPI_DATE_FORMAT)
                    )
                   / (  to_date(to_char(pp_end_date,DEF_DATE_FORMAT)||END_DATE_TIME,RPI_DATE_FORMAT)
                     - to_date(to_char(pp_actual_start_date,DEF_DATE_FORMAT)||BEGIN_DATE_TIME,RPI_DATE_FORMAT)
                     )
           into   l_factor
           from    sys.dual
           ;
           return l_factor;
      END Get_Days_Ratio;

    begin

      l_binary_idx := pp_date_range_table.FIRST;
      l_days_ratio       := 0;
      l_line_number      := 1;
               WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_charges.Msg5',
                                             '*** Binary idx *** '|| l_binary_idx );
               WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_charges.Msg6',
                                             '*** End idx    *** '|| pp_date_range_idx );

           while l_binary_idx <=  pp_date_range_idx loop

                 WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_charges.Msg7',
                                               'LHS 2 '|| pp_date_range_table(l_binary_idx).start_date
                                                         || '   RHS 2 '|| pp_date_range_table(l_binary_idx).end_date );

              /* Bug 2403906 vgadde 14/06/2002 modified < to <= to process standing charges with billing frequency DAY */
              if pp_date_range_table(l_binary_idx).start_date  <=
                pp_date_range_table(l_binary_idx).end_date  then

                    WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_charges.Msg8',
                                                  ' Actual Date '|| pp_date_range_table(l_binary_idx).actual_start_date );
                    WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_charges.Msg9',
                                                  ' Start Date  '|| pp_date_range_table(l_binary_idx).start_date );
                    WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_charges.Msg10',
                                                  ' End   date  '|| pp_date_range_table(l_binary_idx).end_date );

                l_days_ratio := Get_Days_Ratio ( pp_date_range_table(l_binary_idx).start_date,
                                                pp_date_range_table(l_binary_idx).actual_start_date,
                                                pp_date_range_table(l_binary_idx).end_date )
                                ;

                    WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_charges.Msg11',
                                                  '** Days Ratio *** '|| l_days_ratio );


                Next_Due_Dates    ( to_date(to_char(pp_date_range_table(l_binary_idx).start_date,DEF_DATE_FORMAT)
                                    ||BEGIN_DATE_TIME,RPI_DATE_FORMAT)
                                  ,  pp_ld.ld_period_name
                                  ,  nvl(pp_sc.advance_arrears_ind,pp_sc.default_invoicing_rule)
                                  ,  l_new_prev_due_date2
                                  ,  l_new_next_due_date2
                                  ,  l_charge_schedule
                                  ,  l_charge_factor
                                  ,  l_charge_component
                                  ) ;

              /** Get the billing dates etc **/
              Next_Due_Dates      ( to_date(to_char(pp_date_range_table(l_binary_idx).start_date,DEF_DATE_FORMAT)
                                    ||BEGIN_DATE_TIME,RPI_DATE_FORMAT)
                                  ,  pp_sc.sc_period_name
                                  ,  nvl(pp_sc.advance_arrears_ind,pp_sc.default_invoicing_rule)
                                  ,  l_new_prev_due_date
                                  ,  l_new_next_due_date
                                  ,  l_billing_schedule
                                  ,  l_billing_factor
                                  ,  l_billing_component
                                  ) ;

                 WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_charges.Msg12',
                                               '** Billing Schedule ** '|| l_billing_schedule );

             if l_billing_schedule = 0 then
                l_days_ratio := 1;
             end if;


             io_ratio :=  Billing_Charge_Ratio
                  (  nvl(pp_sc.advance_arrears_ind,pp_sc.default_invoicing_rule)
                   , l_days_ratio
                   , to_date(to_char(pp_date_range_table(l_binary_idx).start_date,DEF_DATE_FORMAT)
                     ||BEGIN_DATE_TIME,RPI_DATE_FORMAT)
                   , to_date(to_char(pp_date_range_table(l_binary_idx).end_date,DEF_DATE_FORMAT)
                     ||END_DATE_TIME,RPI_DATE_FORMAT)
                   , pp_ld.ld_period_name
                   , l_charge_factor
                   , l_charge_component
                   , pp_sc.sc_period_name
                   , l_billing_factor
                   , l_billing_component
                  );

                  WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_charges.Msg13',
                                                ' RATIO '|| io_ratio );



              PROCESS_PRICE_BREAKS ( pp_sc
                           , pp_ld
                           , l_rail
                           , io_ratio
                           , to_date(to_char(pp_date_range_table(l_binary_idx).start_date,DEF_DATE_FORMAT)
                             ||BEGIN_DATE_TIME,RPI_DATE_FORMAT)
                           , to_date(to_char(pp_date_range_table(l_binary_idx).end_date,DEF_DATE_FORMAT)
                             ||END_DATE_TIME,RPI_DATE_FORMAT)
                           , l_line_number
                           ) ;


        end if;
        l_binary_idx := l_binary_idx + 1;
      end loop;

    end;
        WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.process_charges.Msg14',
                                      'END (Successful)  Process Standing Charges');
EXCEPTION
  WHEN OTHERS THEN

    pp_date_range_idx    := l_date_range_idx_old;
    pp_date_range_table  := l_date_range_table_old;
    app_exception.raise_exception;
END PROCESS_CHARGES;
--
PROCEDURE AUTO_INVOICE ( errbuf            OUT NOCOPY VARCHAR2
                       , retcode           OUT NOCOPY NUMBER
                       , p_run_date1       IN  VARCHAR2
                       , p_set_of_books_id IN  NUMBER
                       , p_batch_source_id IN  NUMBER
                       , p_debug_mode IN VARCHAR2
                       )
IS
--
--OPSF(I) RPI Bug 2068218 24-Oct-2001 S Brewer Start(1)
-- p_run_date parameter was changed to p_run_date1 for fnd_standart_date format
-- so assigning value to p_run_Date here
-- commenting out following bug fix so that old date format can be used and
-- patch can be released to customer immediately
-- OPSF(I) RPI Bug 2068218 24-Oct-2001 S Brewer End(1)
 p_run_date DATE;
-- Changed parameter back to follow standards.
 l_total_lines           number ;       -- total count of standing charge lines processed
 l_line_count            number ;       -- Number of lines in the standing charges
 l_run_sequence          number ;      -- Sequence to indentify this
 lv_mesg                 varchar2(200) ;

 l_date_range_table DATE_RANGE_TABLE;
 l_date_range_idx   BINARY_INTEGER  ;
 l_debug_mode       VARCHAR2(1);


BEGIN
 p_run_date              := to_date(p_run_date1,'YYYY/MM/DD HH24:MI:SS');
 l_total_lines           := 0;
 l_line_count            := 0;
 lv_mesg                 := null;
 l_debug_mode := nvl(p_debug_mode,'N');


    IF igi_gen.is_req_installed('RPI') THEN
       null;
    ELSE
       fnd_message.set_name( 'IGI', 'IGI_RPI_IS_DISABLED');
       lv_mesg := fnd_message.get;
           WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.auto_invoice.Msg1',
                                         lv_mesg);
       retcode := 2;
       errbuf  := lv_mesg;
       RETURN;
    END IF;

        WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.auto_invoice.Msg2',
                                      'BEGIN Generate Interface Data.');
    /** issue a savepoint       **/
    savepoint rpi_txns;
    /** Load the Global Custom Values **/
    SetValuesForGlobals;
    /** initialize the counters **/
    l_total_lines           := 0;  -- total number of charge lines processed for this run
    /** get the sequences **/

    BEGIN
        SELECT igi_rpi_generate_s.nextval
        INTO   l_run_sequence
        FROM   sys.dual ;
    END;

    BEGIN
            WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.auto_invoice.Msg3',
                                          'Next due date : '|| p_run_date );

        FOR std_rec IN c_stand_charges ( p_run_date, p_set_of_books_id, p_batch_source_id )  LOOP

                WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.auto_invoice.Msg4',
                                              'Processing Charge : '|| std_rec.charge_reference);



            l_line_count := 0;
            FOR ld_rec IN C_line_details ( std_rec.standing_charge_id, std_rec.set_of_books_id ) LOOP



                l_line_count              := l_line_count + 1;
                l_total_lines             := l_total_lines + 1;
                    WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.auto_invoice.Msg5',
                                                  'Line count : '|| l_line_count );
                l_date_range_table.delete;
                l_date_range_idx  := 0;



                PROCESS_CHARGES ( std_rec,  ld_rec,  l_run_sequence
                               , l_date_range_table, l_date_range_idx );
                -- Prorate invoices at line leve if not processed at invoice level.

                    PROCESS_REV_DISTRIBUTIONS ( std_rec
                            , g_curr_rev_idx
                            , g_raid_table
                            );

            END LOOP;
            PROCESS_REC_DISTRIBUTIONS ( std_rec
                            , g_curr_rec_idx
                             ,g_curr_rev_idx
                            , g_raid_table
                            );

            IF l_line_count <> 0 and l_debug_mode <> 'Y' THEN
                Update igi_rpi_standing_charges
                set     generate_sequence = l_run_sequence
                ,       date_synchronized_flag = 'N'
                where   standing_charge_id = std_rec.standing_charge_id
                and     set_of_books_id    = std_rec.set_of_books_id;
            END IF;
            rev_idx :=0;
            g_curr_rec_idx := -1;
            g_curr_rev_idx := 1 ;

        END LOOP;
    EXCEPTION WHEN OTHERS THEN RAISE; -- throw the message to the outermost handler.
    END;
    /** save the changes if and only if some standing charge lines have been processed **/
    IF l_total_lines <> 0  THEN
        if l_debug_mode = 'Y' then
           rollback to rpi_txns;
        else
           COMMIT ;
        end if;

        -- Submit_RAXMTR ( p_batch_source_id , p_run_date );
    ELSE
         rollback to rpi_txns;
    END IF;
    -- Signal Normal completion.
    WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.auto_invoice.Msg6',
                                      'END (Successful) Generate Interface Data.');
    errbuf := null;
    retcode := 0;

EXCEPTION WHEN OTHERS THEN
   rollback;
       WriteToLogFile(l_state_level, 'igi.plsql.igirrpi.auto_invoice.Msg7',
                                     'END (Error) Generate Interface Data.');
   errbuf := SQLERRM;
   retcode := 2;

END AUTO_INVOICE;
--
BEGIN
  g_curr_rec_idx := -1;
  g_curr_rev_idx   := 1 ;
  rev_idx := 0;
  TRANSACTION_CODE       :=  'PERIODICS';
  FROM_DATE_INFO         :=  ' From Date ';
  TO_DATE_INFO           :=  ' To Date ';
END IGIRRPI;

/
