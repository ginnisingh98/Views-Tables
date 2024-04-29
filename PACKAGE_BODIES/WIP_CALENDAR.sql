--------------------------------------------------------
--  DDL for Package Body WIP_CALENDAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_CALENDAR" AS
/* $Header: wipltesb.pls 115.13 2004/02/17 13:45:48 panagara ship $ */

  PROCEDURE ESTIMATE_LEADTIME
	   (x_org_id      in number,
            x_fixed_lead  in number DEFAULT 0,
            x_var_lead    in number DEFAULT 0,
            x_quantity    in number,
            x_proc_days   in number,
            x_entity_type in number,
            x_fusd        in date,
            x_fucd        in date,
            x_lusd        in date,
            x_lucd        in date,
            x_sched_dir   in number,
            x_est_date    out nocopy date ) IS
  new_date       date;
  lt             number;
  new_quantity   number;
  new_fixed_lead number;
  new_proc_days  number;
  x_sched_date   date;

  x_working_day  number; /* Fix for bug 3410450.*/

  cursor cursor_forward is
    SELECT BCD1.CALENDAR_DATE
    FROM   BOM_CALENDAR_DATES BCD1,
           BOM_CALENDAR_DATES BCD2,
           MTL_PARAMETERS MP
    WHERE  MP.ORGANIZATION_ID    = x_org_id
      AND  BCD1.CALENDAR_CODE    = MP.CALENDAR_CODE
      AND  BCD2.CALENDAR_CODE    = MP.CALENDAR_CODE
      AND  BCD1.EXCEPTION_SET_ID = MP.CALENDAR_EXCEPTION_SET_ID
      AND  BCD2.EXCEPTION_SET_ID = MP.CALENDAR_EXCEPTION_SET_ID
      AND  BCD2.CALENDAR_DATE    = TRUNC(x_sched_date)
     AND  BCD1.SEQ_NUM = NVL(BCD2.SEQ_NUM, BCD2.NEXT_SEQ_NUM) + CEIL(lt);

  cursor cursor_backward is
    SELECT BCD1.CALENDAR_DATE
    FROM   BOM_CALENDAR_DATES BCD1,
           BOM_CALENDAR_DATES BCD2,
           MTL_PARAMETERS MP
    WHERE  MP.ORGANIZATION_ID    = x_org_id
      AND  BCD1.CALENDAR_CODE    = MP.CALENDAR_CODE
      AND  BCD2.CALENDAR_CODE    = MP.CALENDAR_CODE
      AND  BCD1.EXCEPTION_SET_ID = MP.CALENDAR_EXCEPTION_SET_ID
      AND  BCD2.EXCEPTION_SET_ID = MP.CALENDAR_EXCEPTION_SET_ID
      AND  BCD2.CALENDAR_DATE    = TRUNC(x_sched_date)
      AND  BCD1.SEQ_NUM = NVL(BCD2.SEQ_NUM, BCD2.PRIOR_SEQ_NUM) -
                             --(new_proc_days) + 1 - CEIL(lt); --Bug2331915
                             (new_proc_days) - FLOOR(lt);

/* Fix for bug 3410450. Added the following cursor 'cursor_working_day' to determine
   if the scheduled completion date is a working/non-working day.
*/
  cursor cursor_working_day is
      SELECT nvl(BCD.SEQ_NUM,-1)
      FROM   BOM_CALENDAR_DATES BCD,
             MTL_PARAMETERS MP
      WHERE  MP.ORGANIZATION_ID   = x_org_id
        AND  BCD.CALENDAR_CODE    = MP.CALENDAR_CODE
        AND  BCD.EXCEPTION_SET_ID = MP.CALENDAR_EXCEPTION_SET_ID
        AND  BCD.CALENDAR_DATE    = TRUNC(x_sched_date);
BEGIN
  new_quantity := x_quantity;
  new_fixed_lead := NVL(x_fixed_lead,0);
  new_proc_days := x_proc_days;
  IF (x_sched_dir = WIP_CONSTANTS.FUSD) THEN
    x_sched_date := x_fusd;
  ELSIF(x_sched_dir = WIP_CONSTANTS.FUCD) THEN
    x_sched_date := x_fucd;
  ELSIF(x_sched_dir = WIP_CONSTANTS.LUSD) THEN
    x_sched_date := x_lusd;
  ELSIF(x_sched_dir = WIP_CONSTANTS.LUCD) THEN
    x_sched_date := x_lucd;
  END IF;

  IF (x_entity_type = WIP_CONSTANTS.REPETITIVE) THEN
    IF (x_sched_dir = WIP_CONSTANTS.LUSD)  /* LUSD = 3 */ THEN
      new_quantity   := 0.0;
      new_fixed_lead := 0.0;
    ELSE
      new_quantity := 1.0;
    END IF;
  END IF;

  IF (((x_sched_dir = WIP_CONSTANTS.FUCD) /* FUCD = 2 */ AND
       (x_entity_type = WIP_CONSTANTS.REPETITIVE)) OR
    -- anything other than repetitive is scheduled the same
      (nvl(x_entity_type, WIP_CONSTANTS.DISCRETE)
       <> WIP_CONSTANTS.REPETITIVE)) THEN
    new_proc_days := 1.0;
  END IF;

  lt := new_fixed_lead + NVL(x_var_lead,0) * new_quantity;

/* Fix for bug 3410450. The following piece of code is added for the specific case of
   LUCD for all entity types other than 'REPETITIVE'.
*/

  IF((x_sched_dir = WIP_CONSTANTS.LUCD) AND
     (nvl(x_entity_type, WIP_CONSTANTS.DISCRETE)
       <> WIP_CONSTANTS.REPETITIVE)) THEN

/* To check if total lead time is an integer.
   If the total lead time is integral, new_proc_days is set to 0 otherwise
   it retains the prior value 1.
 */
     IF(mod(lt,1)=0) THEN
        new_proc_days :=0;
     END IF;

/* To check if scheduled completion date is a working or non working day.
   If its a non working day, new_proc_days is reduced by 1. The exception is
   when total lead time is 0.
*/
     open cursor_working_day;
     fetch cursor_working_day into x_working_day;

     IF(x_working_day = -1 and lt<>0) THEN
         new_proc_days := new_proc_days - 1;
     END IF;

     close cursor_working_day;
 END IF;

/*End of fix for bug 3410450 */
  IF (x_sched_dir = WIP_CONSTANTS.FUSD) /* FUSD = 1 */ THEN
    new_date := x_sched_date;
    open cursor_forward;
    fetch cursor_forward into new_date;
        IF (cursor_forward%NOTFOUND) THEN
            x_est_date := NULL;
            close cursor_forward;
            return;
        END IF;
    close cursor_forward;
  ELSE  /* x_sched_dir <> FUSD */
    new_date := x_sched_date;

    open cursor_backward;
    fetch cursor_backward into new_date;
        IF (cursor_backward%NOTFOUND) THEN
            x_est_date := NULL;
            close cursor_backward;
            return;
        END IF;
    close cursor_backward;
  END IF;
  x_est_date := new_date + (x_sched_date - TRUNC(x_sched_date));

END ESTIMATE_LEADTIME;

END WIP_CALENDAR;

/
