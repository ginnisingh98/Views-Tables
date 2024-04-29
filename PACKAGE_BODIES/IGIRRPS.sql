--------------------------------------------------------
--  DDL for Package Body IGIRRPS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGIRRPS" AS
-- $Header: igirrpsb.pls 120.8.12000000.1 2007/08/31 05:53:27 mbremkum ship $

  l_debug_level number;
  l_state_level number;
  l_proc_level number;
  l_event_level number;
  l_excep_level number;
  l_error_level number;
  l_unexp_level number;

ALREADY_SYNC_STATUS  CONSTANT VARCHAR2(1) := 'Y';
NOT_SYNC_STATUS      CONSTANT VARCHAR2(1) := 'N';
SYNCHRONIZED_STATUS  CONSTANT VARCHAR2(1) := NOT_SYNC_STATUS;

CHARGE_STATUS        CONSTANT IGI_RPI_STANDING_CHARGES_ALL.STATUS%TYPE
  := 'ACTIVE';
INVOICING_RULE       CONSTANT
   IGI_RPI_STANDING_CHARGES_ALL.ADVANCE_ARREARS_IND%TYPE := 'ADVANCE';

--Commenting out WriteToLogFile as fnd_logging to be used bug 3199481 (Start)
/*
PROCEDURE WriteToLog ( pp_mesg in VARCHAR2) IS
  IsdebugMode BOOLEAN := FALSE;
BEGIN
  IF IsDebugMode THEN
    FND_FILE.put_line( FND_FILE.log, pp_mesg  );
  ELSE
    NULL;
  END IF;
END;
*/
--Commenting out WriteToLogFile as fnd_logging to be used bug 3199481 (End)


FUNCTION  GetNewPrevDate ( pp_component in varchar2
                          , pp_factor    in number
                          , pp_date in date )
return    DATE IS
  ld_date date;
BEGIN
    ld_date := NULL;
	SELECT DECODE(pp_component,'DAY'   , ( TO_NUMBER(pp_factor)* -1 )+ pp_date
                       ,'WEEK'  , ( TO_NUMBER(pp_factor)* -7 )+ pp_date
                       ,'MONTH' , ADD_MONTHS(pp_date,-1*TO_NUMBER(pp_factor))
                       ,'YEAR'  , ADD_MONTHS(pp_date, TO_NUMBER(pp_factor)* -12 )
                       )
    INTO   ld_date
    FROM   SYS.DUAL
    ;
    return ld_date;
END GetNewPrevDate;

FUNCTION  GetNewNextDate ( pp_component in varchar2
                          , pp_factor    in number
                          , pp_date in date )
return    DATE IS
  ld_date date;
BEGIN
    ld_date := NULL;
	SELECT DECODE(pp_component,'DAY'   , ( TO_NUMBER(pp_factor) )+ pp_date
                       ,'WEEK'  , ( TO_NUMBER(pp_factor)* 7 )+ pp_date
                       ,'MONTH' , ADD_MONTHS(pp_date,TO_NUMBER(pp_factor))
                       ,'YEAR'  , ADD_MONTHS(pp_date, TO_NUMBER(pp_factor)*12 )
                       )
    INTO   ld_date
    FROM   SYS.DUAL
    ;
    return ld_date;
END GetNewNextDate;

FUNCTION  GetNewSchedPrevDate ( pp_schedule_id in number, pp_date in date )
return    DATE IS
  CURSOR c_sched IS
    SELECT date1, date2, date3, date4
    FROM   igi_rpi_period_schedules
    WHERE  schedule_id  = pp_schedule_id
    AND    nvl(enabled_flag,'Y') = 'Y';
    l_Date date;
BEGIN
    l_Date := NULL;
	FOR l_s in C_sched LOOP

 /* prev due date */

        if    to_date(to_char(l_s.date1,'DD/MM/')
              ||to_char(pp_date,'YYYY'),'DD/MM/YYYY') >=
              pp_date
        then
              l_date := to_date(to_char(l_s.date4,'DD/MM/')
              ||to_char(to_number(to_char(pp_date,'YYYY'))-1),'DD/MM/YYYY');
        elsif to_date(to_char(l_s.date2,'DD/MM/')
              ||to_char(pp_date,'YYYY'),'DD/MM/YYYY') >=
              pp_date
        then
              l_date := to_date(to_char(l_s.date1,'DD/MM/')
              ||to_char(pp_date,'YYYY'),'DD/MM/YYYY');
        elsif to_date(to_char(l_s.date3,'DD/MM/')
              ||to_char(pp_date,'YYYY'),'DD/MM/YYYY') >=
              pp_date
        then
              l_date := to_date(to_char(l_s.date2,'DD/MM/')
              ||to_char(pp_date,'YYYY'),'DD/MM/YYYY');
        elsif to_date(to_char(l_s.date4,'DD/MM/')
              ||to_char(pp_date,'YYYY'),'DD/MM/YYYY') >=
              pp_date
        then
              l_date := to_date(to_char(l_s.date3,'DD/MM/')
              ||to_char(pp_date,'YYYY'),'DD/MM/YYYY');
        elsif to_date(to_char(l_s.date1,'DD/MM/')
              ||to_char(to_number(to_char(pp_date,'YYYY'))+1),
                 'DD/MM/YYYY') >=
              pp_date
        then
              l_date := to_date(to_char(l_s.date4,'DD/MM/')
              ||to_char(pp_date,'YYYY'),'DD/MM/YYYY');
        end if;


    END LOOP;

    return l_date;
END GetNewSchedPrevDate;

FUNCTION  GetNewSchedNextDate ( pp_schedule_id in number, pp_date in date )
return    DATE IS
  CURSOR c_sched IS
    SELECT date1, date2, date3, date4
    FROM   igi_rpi_period_schedules
    WHERE  schedule_id  = pp_schedule_id
    AND    nvl(enabled_flag,'Y') = 'Y';
  l_Date date;
BEGIN
    l_Date := NULL;
	FOR l_s in C_sched LOOP

     /* next due date */

        if    to_date(to_char(l_s.date1,'DD/MM/')
              ||to_char(pp_date,'YYYY'),'DD/MM/YYYY') >
              pp_date
        then
              l_Date := to_date(to_char(l_s.date1,'DD/MM/')
              ||to_char(pp_date,'YYYY'),'DD/MM/YYYY');
        elsif to_date(to_char(l_s.date2,'DD/MM/')
              ||to_char(pp_date,'YYYY'),'DD/MM/YYYY') >
              pp_date
        then
              l_Date := to_date(to_char(l_s.date2,'DD/MM/')
              ||to_char(pp_date,'YYYY'),'DD/MM/YYYY');
        elsif to_date(to_char(l_s.date3,'DD/MM/')
              ||to_char(pp_date,'YYYY'),'DD/MM/YYYY') >
              pp_date
        then
              l_Date := to_date(to_char(l_s.date3,'DD/MM/')
              ||to_char(pp_date,'YYYY'),'DD/MM/YYYY');
        elsif to_date(to_char(l_s.date4,'DD/MM/')
              ||to_char(pp_date,'YYYY'),'DD/MM/YYYY') >
              pp_date
        then
              l_Date := to_date(to_char(l_s.date4,'DD/MM/')
              ||to_char(pp_date,'YYYY'),'DD/MM/YYYY');
        elsif to_date(to_char(l_s.date1,'DD/MM/')
              ||to_char(to_number(to_char(pp_date,'YYYY'))+1),
                 'DD/MM/YYYY') >
              pp_date
        then
              l_Date := to_date(to_char(l_s.date1,'DD/MM/')
              ||to_char(to_number(to_char(pp_date,'YYYY'))+1),
                 'DD/MM/YYYY');
        end if;

    END LOOP;

    return l_date;
END GetNewSchedNextDate;

FUNCTION  GetNewPrevDate ( pp_standing_charge_id in number
                         , pp_date  in date
                         )
RETURN DATE IS
   CURSOR c_sc IS
       SELECT  sc.period_name
       FROM    igi_rpi_standing_charges sc
       WHERE   sc.standing_charge_id = pp_standing_charge_id
       AND     sc.set_of_books_id          = ( select set_of_books_id
                                    from   ar_system_parameters )
       AND  sc.status = CHARGE_STATUS
       ;
   CURSOR C_periods ( pp_period_name in varchar2) IS
       SELECT nvl(js.schedule_id,0) schedule_id
               , jr.component
               , jr.factor
     FROM    igi_rpi_component_periods       jr
     ,       igi_rpi_period_schedules js
     WHERE jr.period_name =   pp_period_name
     AND  jr.schedule_id =   js.schedule_id
     AND  js.period_name  = pp_period_name
     UNION
     SELECT  0 schedule_id, jr.component, jr.factor
     FROM    igi_rpi_component_periods   jr
     WHERE    jr.period_name  = pp_period_name
     AND    NOT EXISTS ( select 'x'
                         from igi_rpi_period_schedules js
                         where js.period_name = jr.period_name
                           and js.schedule_id = jr.schedule_id
                      )
     ;


BEGIN
    FOR l_sc in c_sc LOOP
      FOR l_per in c_periods ( l_sc.period_name ) LOOP
       IF l_per.schedule_id <> 0 THEN
          return GetNewSchedPrevDate ( l_per.schedule_id
                                 , pp_Date
                                 );
       ELSE
          return  GetNewPrevDate ( l_per.component
                          , l_per.factor
                          , pp_date );
       END IF;

      END LOOP;
     END LOOP;
     return NULL;
END GetNewPrevDate;

FUNCTION  GetNewNextDate ( pp_standing_charge_id in number
                         , pp_date  in date
                            )
RETURN    DATE IS

   CURSOR c_sc IS
       SELECT  sc.period_name
       FROM    igi_rpi_standing_charges sc
       WHERE   sc.standing_charge_id = pp_standing_charge_id
       AND     sc.set_of_books_id          = ( select set_of_books_id
                                    from   ar_system_parameters )
       AND  sc.status = CHARGE_STATUS
       ;
   CURSOR C_periods ( pp_period_name in varchar2) IS
       SELECT nvl(js.schedule_id,-1) schedule_id
               , jr.component
               , jr.factor
     FROM    igi_rpi_component_periods       jr
     ,       igi_rpi_period_schedules js
     WHERE jr.period_name =   pp_period_name
     AND  jr.schedule_id =   js.schedule_id
     AND  js.period_name  = pp_period_name
     UNION
     SELECT   0 schedule_id, jr.component, jr.factor
     FROM    igi_rpi_component_periods   jr
     WHERE    jr.period_name  = pp_period_name
     AND    NOT EXISTS ( select 'x'
                         from igi_rpi_period_schedules js
                         where js.period_name = jr.period_name
                           and js.schedule_id = jr.schedule_id )
    ;
    l_Date date;
BEGIN
    l_Date := NULL;
	FOR l_sc in c_sc LOOP
      FOR l_per in c_periods ( l_sc.period_name ) LOOP
       IF l_per.schedule_id <> 0 THEN
          return GetNewSchedNextDate ( l_per.schedule_id
                                 , pp_Date
                                 );
       ELSE
          return  GetNewNextDate ( l_per.component
                          , l_per.factor
                          , pp_date );
       END IF;

      END LOOP;
     END LOOP;
     return NULL;
END GetNewNextDate;

PROCEDURE UpdateStandingCharges
        ( pp_standing_charge_id  IN NUMBER
        , pp_generate_sequence IN NUMBER )
IS
CURSOR C_UpdateStandingCharges (cp_standing_charge_id IN NUMBER
                               ,cp_generate_sequence IN NUMBER )
IS
SELECT sc.standing_charge_id , sc.rowid sc_rowid, sc.charge_reference,
       sc.start_date, sc.standing_charge_date
,      sc.end_date , sc.next_due_date , sc.previous_due_date
,      sc.advance_arrears_ind
,      nvl(sc.date_synchronized_flag,ALREADY_SYNC_STATUS) date_synchronized_flag
FROM     igi_rpi_standing_charges  sc
WHERE sc.standing_charge_id     = cp_standing_charge_id
AND sc.generate_sequence        = cp_generate_sequence
AND sc.set_of_books_id          = ( select set_of_books_id
                                    from   ar_system_parameters )
AND  sc.status = CHARGE_STATUS
;
CURSOR c_lines ( cp_standing_charge_id in number) IS
   select rowid row_id, start_date
   from   igi_rpi_line_details
   where  standing_charge_id = cp_standing_charge_id
   and    start_date is not null
   ;
lv_update_sc    C_UpdateStandingCharges%ROWTYPE;
ld_new_next_due_Date date;
ld_new_sc_date date; -- gl date
ld_new_ld_date date; -- line details start date

BEGIN
    --WriteToLog ( ' Beginning of UpdateStandingCharges...');
    -- bug 3199481, start block
    IF (l_state_level >= l_debug_level) THEN
        FND_LOG.STRING(l_state_level, 'igi.plsql.igirrps.update_standing_charges.Msg1',
                                      ' Beginning of UpdateStandingCharges...');
    END IF;
    -- bug 3199481, end block
    FOR lv_update_sc IN  C_UpdateStandingCharges (pp_standing_charge_id,pp_generate_sequence)
    LOOP

        --WriteToLog ( ' ------------------------------------------------------- ');
        --WriteToLog ( ' Standing Charge ID  '|| lv_update_sc.standing_charge_id );
        --WriteToLog ( ' Standing Charge Ref '|| lv_update_sc.charge_reference );
        --WriteToLog ( ' Old  Next Due Date  '|| lv_update_sc.next_due_date );
        --WriteToLog ( ' ------------------------------------------------------- ');

        -- bug 3199481, start block
        IF (l_state_level >= l_debug_level) THEN
            FND_LOG.STRING(l_state_level, 'igi.plsql.igirrps.update_standing_charges.Msg2',
                                          ' Standing Charge ID  '|| lv_update_sc.standing_charge_id );
            FND_LOG.STRING(l_state_level, 'igi.plsql.igirrps.update_standing_charges.Msg3',
                                          ' Standing Charge Ref '|| lv_update_sc.charge_reference );
            FND_LOG.STRING(l_state_level, 'igi.plsql.igirrps.update_standing_charges.Msg4',
                                          ' Old  Next Due Date  '|| lv_update_sc.next_due_date );
        END IF;
        -- bug 3199481, end block

          if lv_update_sc.date_synchronized_flag = SYNCHRONIZED_STATUS
          then
            ld_new_next_due_date  :=  GetNewNextDate ( lv_update_sc.standing_charge_id
                                                 , lv_update_sc.next_due_date
                                                 );

             /*Bug no 2688741  ,Fixed by shsaxena*/
             IF (lv_update_sc.standing_charge_date IS NOT NULL) THEN
            ld_new_sc_date         :=  GetNewNextDate ( lv_update_sc.standing_charge_id
                                                 , lv_update_sc.standing_charge_date
                                                 );
             ELSE
            ld_new_sc_date := NULL;
	    END IF;
            --WriteToLog ( ' New Next due Date   '|| ld_new_next_due_date );
            --WriteToLog ( ' New GL Date         '|| ld_new_sc_date );

            -- bug 3199481, start block
            IF (l_state_level >= l_debug_level) THEN
                FND_LOG.STRING(l_state_level, 'igi.plsql.igirrps.update_standing_charges.Msg5',
                                              ' New Next due Date   '|| ld_new_next_due_date );
                FND_LOG.STRING(l_state_level, 'igi.plsql.igirrps.update_standing_charges.Msg6',
                                              ' New GL Date         '|| ld_new_sc_date );
            END IF;
            -- bug 3199481, end block

            IF ld_new_next_due_date is NULL THEN
               --WriteToLog ( 'New Next due date is null.');
               -- bug 3199481, start block
               IF (l_state_level >= l_debug_level) THEN
                   FND_LOG.STRING(l_state_level, 'igi.plsql.igirrps.update_standing_charges.Msg7',
                                                 'New Next due date is null.');
               END IF;
               -- bug 3199481, end block
               return ;
            END IF;

            IF ld_new_sc_date is NULL THEN
               --WriteToLog ( 'New GL date is null ');
               -- bug 3199481, start block
               IF (l_state_level >= l_debug_level) THEN
                   FND_LOG.STRING(l_state_level, 'igi.plsql.igirrps.update_standing_charges.Msg8',
                                                 'New GL date is null ');
               END IF;
               -- bug 3199481, end block
            /*Bug no 2688741 Commented by shsaxena*/
              -- return ;
            END IF;

            UPDATE IGI_RPI_STANDING_CHARGES
            SET   next_due_date     = ld_new_next_due_date,
              standing_charge_date  = ld_new_sc_date,
              previous_due_date = lv_update_sc.next_due_date,
              date_synchronized_flag = ALREADY_SYNC_STATUS
            WHERE ROWID           = lv_update_sc.sc_rowid
            ;

            FOR l_lines in C_lines( lv_update_sc.standing_charge_id)
            LOOP
                ld_new_ld_date :=  GetNewNextDate
                                   ( lv_update_sc.standing_charge_id
                                   ,  l_lines.start_date
                                   );
                IF ld_new_next_due_date is NULL THEN
                   --WriteToLog  ( 'New Next due date is null.');
                   -- bug 3199481, start block
                   IF (l_state_level >= l_debug_level) THEN
                       FND_LOG.STRING(l_state_level, 'igi.plsql.igirrps.update_standing_charges.Msg9',
                                                     'New Next due date is null.');
                   END IF;
                   -- bug 3199481, end block
                   return ;
                END IF;

                UPDATE igi_rpi_line_details
                SET    start_date = ld_new_ld_date
                WHERE  rowid      = l_lines.row_id
                ;

            END LOOP;
        end if;

    END LOOP;
    --WriteToLog ( 'End UpateStandingCharges...');
    -- bug 3199481, start block
    IF (l_state_level >= l_debug_level) THEN
        FND_LOG.STRING(l_state_level, 'igi.plsql.igirrps.update_standing_charges.Msg10',
                                      'End UpateStandingCharges...');
    END IF;
    -- bug 3199481, end block
END ;

PROCEDURE    synchronize_dates ( errbuf            OUT NOCOPY VARCHAR2
                               , retcode           OUT NOCOPY NUMBER
                               , p_run_date1        in VARCHAR2
                               , p_set_of_books_id in NUMBER
                               , p_batch_source_id in NUMBER
                               , p_standing_charge_id in number
                               , p_undo_last_change in varchar2

                                  ) IS
l_next_due_date date;
b_no_recs boolean;
lv_rowid varchar2(25);

/*Modified by panaraya Start*/
p_run_date DATE;
/*Modified by panaraya End */


CURSOR c_undo_sc IS
       SELECT   sc.standing_charge_id, sc.generate_sequence
                , sc.batch_source_id
                , sc.charge_reference
       FROM     igi_rpi_standing_charges sc
       WHERE    sc.set_of_books_id  = p_set_of_books_id
       AND      sc.standing_charge_id = nvl( p_standing_charge_id
                                         , sc.standing_charge_id )
       AND      sc.batch_source_id  = nvl(p_batch_source_id,
                                      sc.batch_source_id)
       AND      sc.status = CHARGE_STATUS
       AND      sc.next_due_date   <= p_run_date
       and      sc.date_synchronized_flag = NOT_SYNC_STATUS
       ;
-- CURSOR C_successful_trx (cp_batch_source_id in number)  IS
CURSOR C_successful_trx (cp_batch_source_id in number, cp_standing_charge_id in number)  IS /* Bug 3951039 agovil */
       SELECT   rct.interface_header_attribute1 trx_sc_id
       ,        rct.interface_header_attribute2 trx_seq
       ,        rct.customer_Trx_id
       ,        rct.trx_date
       ,        rsc.next_due_date
       ,        rsc.advance_arrears_ind
       ,        rsc.batch_source_id
       ,	rsc.default_invoicing_rule
       from     ra_customer_trx rct
       ,        igi_rpi_standing_charges rsc
       where    rct.batch_source_id  = nvl(cp_batch_source_id,
                                        rct.batch_source_id )
       and      rct.set_of_books_id  = p_set_of_books_id
       and      to_char(rsc.standing_charge_id) = rct.interface_header_attribute1
       and      to_char(rsc.generate_sequence)  = rct.interface_header_attribute2
       and      rsc.set_of_books_id    = p_set_of_books_id
--     AND      rsc.standing_charge_id = nvl( p_standing_charge_id
--                                         , rsc.standing_charge_id )
       AND      rsc.standing_charge_id = nvl( cp_standing_charge_id
                                         , rsc.standing_charge_id ) /* BUG 3951309 agovil */
       AND      rsc.batch_source_id    = nvl(cp_batch_source_id
                                         , rsc.batch_source_id )
       and      trunc(rsc.next_due_date)      <= trunc(p_run_date)
       and      rsc.date_synchronized_flag = NOT_SYNC_STATUS
       and      exists
                ( select 'x'
                  from   igi_ar_system_options
                  where  rpi_header_context_code = rct.interface_header_context
                )
       and      exists
                ( select 'x'
                  from   ra_customer_trx_lines rctl
                  where  rctl.customer_trx_id = rct.customer_trx_id
                )
       ;

/*Added additional columns in line_det for retrieving price and effective date to update
the Standing Charges and Price History - RPI Enhancement.*/
cursor line_det ( cp_sc_id in  number)  is
       select   line_item_id,
		revised_price,
		revised_effective_date,
		run_id,
		org_id,
		charge_item_number,
		item_id,
		price,
		current_effective_date
       from igi_rpi_line_details_all
       where standing_charge_id = cp_sc_id
       ;

BEGIN
  b_no_recs := false;
  p_run_date := to_date(p_run_date1,'YYYY/MM/DD HH24:MI:SS');
  IF  IGI_GEN.Is_Req_Installed('RPI') THEN
      NULL;
  ELSE
      fnd_message.set_name( 'IGI', 'IGI_RPI_IS_DISABLED');
      --Bug 3199481 (start)
      If (l_unexp_level >= l_debug_level) then
         FND_LOG.MESSAGE(l_unexp_level,'igi.plsql.igirrps.synchronize_dates.Msg0',FALSE);
      End if;
      --Bug 3199481 (end)
      errbuf := fnd_message.get;
      retcode := 2;
      return;
  END IF;
/*Added p_undo_last_change = 'N' in the If condn since parameter passed from the requst is N
Added by Panarayaa for RPI Enhancement*/

  IF (p_undo_last_change = 'NO'OR p_undo_last_change = 'N' ) THEN
     null;
  ELSE
    FOR l_sc in c_undo_sc LOOP
       b_no_recs := TRUE;

       --WriteToLog ( ' Verifying  Standing charge ref '||
       --             l_sc.charge_reference );
       --WriteToLog ( '             Generate sequence  '||
       --             l_sc.generate_sequence );

       -- bug 3199481, start block
       IF (l_state_level >= l_debug_level) THEN
           FND_LOG.STRING(l_state_level, 'igi.plsql.igirrps.synchronize_dates.Msg1',
                                         ' Verifying  Standing charge ref '||
                                           l_sc.charge_reference );
            FND_LOG.STRING(l_state_level, 'igi.plsql.igirrps.synchronize_dates.Msg2',
                                         '             Generate sequence  '||
                                          l_sc.generate_sequence );
       END IF;
       -- bug 3199481, end block
        -- FOR l_s_trx in c_successful_trx ( l_sc.batch_source_id ) LOOP
        FOR l_s_trx in c_successful_trx ( l_sc.batch_source_id, l_sc.standing_charge_id ) LOOP /* Bug 3951309 agovil */
	        b_no_recs := FALSE;
            --WriteToLog ( ' Invoice Generated for this standing charge '||
             --       l_sc.standing_charge_id );
             -- bug 3199481, start block
             IF (l_state_level >= l_debug_level) THEN
                 FND_LOG.STRING(l_state_level, 'igi.plsql.igirrps.synchronize_dates.Msg3',
                                               ' Invoice Generated for this standing charge '||
                                                 l_sc.standing_charge_id );
             END IF;
             -- bug 3199481, end block
        END LOOP;

        IF b_no_recs THEN
            --WriteToLog ( ' Evaluating interface information for  '||
            --        l_sc.standing_charge_id );
            -- bug 3199481, start block
            IF (l_state_level >= l_debug_level) THEN
                 FND_LOG.STRING(l_state_level, 'igi.plsql.igirrps.synchronize_dates.Msg4',
                                               ' Evaluating interface information for  '||
                                                 l_sc.standing_charge_id );
             END IF;
             -- bug 3199481, end block

           declare
              cursor c_xface is
                 SELECT interface_line_id
                 FROM   ra_interface_lines
                 WHERE  interface_line_attribute1 = to_char(l_sc.standing_charge_id)
                 AND    interface_line_attribute2 = to_char(l_sc.generate_sequence)
                 ;
           begin
              FOR l_xface in c_xface LOOP
                  --WriteToLog ( ' Found the errors information.');
                  -- bug 3199481, start block
                  IF (l_state_level >= l_debug_level) THEN
                      FND_LOG.STRING(l_state_level, 'igi.plsql.igirrps.synchronize_dates.Msg5',
                                                    ' Found the errors information.');
                  END IF;
                  -- bug 3199481, end block
                  delete from ra_interface_errors
                  where  interface_line_id = l_xface.interface_line_id
                  ;
                   if sql%found then
                     --WriteToLog ( ' Deleted the errors information.');
                     -- bug 3199481, start block
                     IF (l_state_level >= l_debug_level) THEN
                         FND_LOG.STRING(l_state_level, 'igi.plsql.igirrps.synchronize_dates.Msg6',
                                                       ' Deleted the errors information.');
                     END IF;
                     -- bug 3199481, end block
                   end if;

              END LOOP;

              delete from ra_interface_salescredits
                 WHERE  interface_line_attribute1 = to_char(l_sc.standing_charge_id)
                 AND    interface_line_attribute2 = to_char(l_sc.generate_sequence)
              ;
              if sql%found then
                     --WriteToLog ( ' Deleted the Sales information.');
                     -- bug 3199481, start block
                     IF (l_state_level >= l_debug_level) THEN
                         FND_LOG.STRING(l_state_level, 'igi.plsql.igirrps.synchronize_dates.Msg7',
                                                       ' Deleted the Sales information.');
                     END IF;
                     -- bug 3199481, end block
              end if;
              delete from ra_interface_distributions
                 WHERE  interface_line_attribute1 = to_char(l_sc.standing_charge_id)
                 AND    interface_line_attribute2 = to_char(l_sc.generate_sequence)
              ;
              if sql%found then
                     --WriteToLog ( ' Deleted the Distribution information.');
                     -- bug 3199481, start block
                     IF (l_state_level >= l_debug_level) THEN
                         FND_LOG.STRING(l_state_level, 'igi.plsql.igirrps.synchronize_dates.Msg8',
                                                       ' Deleted the Distribution information.');
                     END IF;
                     -- bug 3199481, end block
              end if;
              delete from ra_interface_lines
                 WHERE  interface_line_attribute1 = to_char(l_sc.standing_charge_id)
                 AND    interface_line_attribute2 = to_char(l_sc.generate_sequence)
              ;
              --WriteToLog ( ' Interface information deleted for '||
              --      l_sc.standing_charge_id );
              -- bug 3199481, start block
              IF (l_state_level >= l_debug_level) THEN
                  FND_LOG.STRING(l_state_level, 'igi.plsql.igirrps.synchronize_dates.Msg9',
                                                ' Interface information deleted for '||
                                                  l_sc.standing_charge_id );
              END IF;
              -- bug 3199481, end block
              update igi_rpi_standing_charges
              set    date_synchronized_flag = ALREADY_SYNC_STATUS
              where  standing_charge_id     = l_sc.standing_charge_id
              and    generate_sequence      = l_sc.generate_sequence
              and    date_synchronized_flag = NOT_SYNC_STATUS
              ;

              --fnd_file.put_line ( fnd_file.log, ' Synchronization flag reset for '||
              --      l_sc.charge_reference );
              -- bug 3199481, start block
              IF (l_state_level >= l_debug_level) THEN
                  FND_LOG.STRING(l_state_level, 'igi.plsql.igirrps.synchronize_dates.Msg9',
                                                ' Synchronization flag reset for '||
                                                  l_sc.charge_reference );
              END IF;
              -- bug 3199481, end block
           exception when others then null;
           end;

       END IF ;
    END LOOP;
  END IF;
  /* process successful trx */
  -- FOR l_trx in C_successful_trx  (p_batch_source_id) LOOP
  FOR l_trx in C_successful_trx  (p_batch_source_id, p_standing_charge_id) LOOP  /* Bug 3951309 agovil */

     -- WriteToLog ( 'Trx Date      = '|| l_trx.trx_date );
     -- WriteToLog ( 'Next due Date = '|| l_trx.next_due_date );
     -- WriteToLog ( 'Charge ID     = '|| l_trx.trx_sc_id );
     -- WriteToLog ( 'Sequence      = '|| l_trx.trx_seq );

      -- bug 3199481, start block
      IF (l_state_level >= l_debug_level) THEN
          FND_LOG.STRING(l_state_level, 'igi.plsql.igirrps.synchronize_dates.Msg10',
                                        'Trx Date      = '|| l_trx.trx_date );
          FND_LOG.STRING(l_state_level, 'igi.plsql.igirrps.synchronize_dates.Msg11',
                                        'Next due Date = '|| l_trx.next_due_date );
          FND_LOG.STRING(l_state_level, 'igi.plsql.igirrps.synchronize_dates.Msg12',
                                        'Charge ID     = '|| l_trx.trx_sc_id );
          FND_LOG.STRING(l_state_level, 'igi.plsql.igirrps.synchronize_dates.Msg13',
                                        'Sequence      = '|| l_trx.trx_seq );
      END IF;
      -- bug 3199481, end block

      -- if trunc(l_trx.trx_date) = trunc(l_trx.next_due_date) then  /* commented line for bug 3938731 agovil */
            /* WriteToLog ( 'Trx Date = Nxt Due Date ...');*/
            if nvl(l_trx.advance_arrears_ind, l_trx.DEFAULT_INVOICING_RULE )  = INVOICING_RULE then
               /* WriteToLog ( 'Advance  ... Updating...');*/
               UpdateStandingCharges  ( l_trx.trx_sc_id ,l_trx.trx_seq ) ;
            end if;
      -- end if; /* commented line for bug 3938731 agovil */

	  /* fetch new value of next due date*/
      Select next_due_date
      into   l_next_due_date
      From   igi_rpi_standing_charges
      Where  standing_charge_id = l_trx.trx_sc_id
      And    generate_sequence =  l_trx.trx_seq
            ;
      for line_rec in line_det ( l_trx.trx_sc_id )   loop

/*Added  the IF condn and the TBH call for audit table IGI_RPI_LINE_AUDIT_DET_ALL
Added by Panaraya for RPI Enhancement - Start

Modified the condition for IF condn to (trunc(line_rec.revised_effective_date) <= trunc(p_run_date))
and the where condn for next due date in update statement
for Bug NO 2454958 */
	IF (trunc(line_rec.revised_effective_date) <= trunc(p_run_date)) THEN

		igi_rpi_line_audit_det_all_pkg.insert_row (
             x_mode                              => 'R',
             x_rowid                             => lv_rowid,
             x_standing_charge_id                => TO_NUMBER (l_trx.trx_sc_id),
             x_line_item_id                      => TO_NUMBER (line_rec.LINE_ITEM_ID),
             x_charge_item_number                => TO_NUMBER (line_rec.CHARGE_ITEM_NUMBER),
             x_item_id                           => TO_NUMBER (line_rec.ITEM_ID),
             x_price                             => line_rec.REVISED_PRICE,
             x_effective_date                    => line_rec.REVISED_EFFECTIVE_DATE,
             x_revised_price                     => null,
             x_revised_effective_date            => null,
             x_run_id                            => TO_NUMBER (line_rec.RUN_ID),
             x_org_id                            => TO_NUMBER (line_rec.ORG_ID),
	     x_previous_price                    => line_rec.PRICE,
      	     x_previous_effective_date           => line_rec.CURRENT_EFFECTIVE_DATE

           );
               update igi_rpi_line_details_all
               set previous_price           = price,
                  previous_effective_date  = current_effective_date,
                  price                    = revised_price,
                  current_effective_date   = revised_effective_date,
                  revised_price            = '',
                  revised_effective_date   = ''
               where line_item_id           = line_rec.line_item_id
               and trunc(revised_effective_date)
                       <= trunc(p_run_date);


	END IF;
/*Added by Panaraya for RPI Enhancement - End */
      end loop;

      if nvl(l_trx.advance_arrears_ind,l_trx.default_invoicing_rule) = 'ARREARS' then
               UpdateStandingCharges  ( l_trx.trx_sc_id ,l_trx.trx_seq ) ;
      end if;



  END LOOP;
  COMMIT;

  errbuf := 'Normal Completion';
  retcode := 0;

  EXCEPTION  WHEN OTHERS THEN
       rollback;
       errbuf := SQLERRM;
       retcode := 2;
  END ;

BEGIN

  l_debug_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_state_level := FND_LOG.LEVEL_STATEMENT;
  l_proc_level  := FND_LOG.LEVEL_PROCEDURE;
  l_event_level := FND_LOG.LEVEL_EVENT;
  l_excep_level := FND_LOG.LEVEL_EXCEPTION;
  l_error_level := FND_LOG.LEVEL_ERROR;
  l_unexp_level := FND_LOG.LEVEL_UNEXPECTED;

END ;

/
