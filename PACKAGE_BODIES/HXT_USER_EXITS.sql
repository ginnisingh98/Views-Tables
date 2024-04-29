--------------------------------------------------------
--  DDL for Package Body HXT_USER_EXITS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_USER_EXITS" AS
/* $Header: hxtuserx.pkb 120.0 2005/05/29 06:06:07 appldev noship $ */


/*****************************************************************
*                                                                *
*  CUSTOMER: Base Version                                        *
*                                                                *
*  This package is designed for creation of customer exit points *
*  that will allow customer specific procedures to be implemented*
*                                                                *
*  Initial code    SPR C167 by BC on 06-05-96                    *
*  Timeclock code added     by BC on 07-23-96
*****************************************************************/
/*--------------------------------------------------------------*/
/*****************************************************************
*  Procedure Define_Reference_Number()is called at the timecard  *
*  level. It allows flexibilty in grouping batches together by   *
*  any reference critieria deemed necessary by the customer.     *
******************************************************************
*  The default set's a string composed or the current user's id  *
*  and period end date when called from HXT_TIME_GEN.generate_time*
*                                                                *
*  The default for timeclock timecard generation will add the    *
*  'CLOCK:' identifier. Coupled with the period end date, this   *
*   will identify the batches created for timeclock entries.     *
*****************************************************************/
PROCEDURE Define_Reference_Number(i_payroll_id IN NUMBER,
                                  i_time_period_id IN NUMBER,
                                  i_assignment_id IN NUMBER,
                                  i_person_id IN NUMBER,
                                  i_user_id IN VARCHAR2,
                                  i_source_flag IN CHAR,
                                  o_reference_number OUT NOCOPY VARCHAR2,
                                  o_error_message OUT NOCOPY VARCHAR2)IS

--BEGIN GLOBAL
--  l_source_description pay_pdt_batch_headers.reference_num%TYPE := 'MAN_';
  l_source_description pay_batch_headers.batch_reference%TYPE := 'MAN_';
--END GLOBAL
  l_date DATE;

BEGIN
      l_date := hxt_util.Get_Period_End(i_time_period_id);

      IF i_source_flag = 'C' THEN
        l_source_description := 'C_'||fnd_date.date_to_chardate(l_date)||'/'||i_user_id;  --FORMS60
      ELSIF i_source_flag = 'A' THEN
        l_source_description := 'A_'||fnd_date.date_to_chardate(l_date)||'/'||i_user_id;  --FORMS60
      ELSIF i_source_flag = 'M' THEN
        l_source_description := 'M_'||fnd_date.date_to_chardate(l_date)||'/'||i_user_id;  --FORMS60
      ELSIF i_source_flag = 'R' THEN           -- RETROPAY
        l_source_description := 'RETRO';      -- RETROPAY

      END IF;

      o_reference_number := l_source_description;
--                            to_char(HXT_util.Get_Period_End(i_time_period_id))||
--                            '/'||
--                            i_user_id;

  EXCEPTION
    WHEN OTHERS THEN
      --HXT11o_error_message := 'Error('||SQLERRM||') occured creating in Define Reference Number (person id: '||TO_CHAR(i_person_id)||')';
      fnd_message.set_name('HXT','HXT_39299_ERR_CRT_REF_NUM'); --HXT11
      fnd_message.set_token('SQLERR',SQLERRM); --HXT11
      fnd_message.set_token('PERSON_ID',TO_CHAR(i_person_id)); --HXT11
      o_error_message := FND_MESSAGE.GET;    --HXT11
      FND_MESSAGE.CLEAR;                 --HXT11

END Define_Reference_Number;
--BEGIN GLOBAL
/*****************************************************************
*  Procedure Define_Batch_Name()is called wherever batches are   *
*  created in OTM. It will create a unique batch name based on   *
*  batch ID.                                                     *
*****************************************************************/
PROCEDURE Define_Batch_Name(i_batch_id IN NUMBER,
                            o_batch_name OUT NOCOPY VARCHAR2,
                            o_error_message OUT NOCOPY VARCHAR2) IS

BEGIN
  o_batch_name := 'Batch #' || to_char(i_batch_id);

EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('HXT','HXT_39485_ERR_DEF_BATCH_NAME');
    fnd_message.set_token('SQLERR',SQLERRM);
    o_error_message := FND_MESSAGE.GET;
    FND_MESSAGE.CLEAR;
END Define_Batch_Name;
/******************************************************************************************************
FUNCTION retro_hours()

  Designed to obtain hours for completed retro transactions.

******************************************************************************************************/
FUNCTION retro_hours(i_row_id IN VARCHAR2) RETURN NUMBER IS

CURSOR new_hours IS
SELECT retro.hours - expired.hours
  FROM hxt_det_hours_worked_f expired,
       hxt_det_hours_worked_f retro
 WHERE retro.rowid = CHARTOROWID(i_row_id)
   AND retro.parent_id = expired.parent_id
   AND retro.element_type_id = expired.element_type_id
   AND expired.pay_status = 'A'
   AND expired.effective_end_date = (SELECT MAX(ex.effective_end_date)
                                       FROM hxt_det_hours_worked_f ex
                                      WHERE ex.effective_end_date < retro.effective_start_date
                                        AND ex.parent_id = retro.parent_id
                                        AND ex.pay_status = 'A'
                                        AND ex.element_type_id = retro.element_type_id);

l_hours NUMBER DEFAULT NULL;

BEGIN
  OPEN new_hours;
  FETCH new_hours INTO l_hours;
  CLOSE new_hours;
  RETURN l_hours;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END retro_hours;
/******************************************************************************************************
FUNCTION retro_amount()

  Designed to obtain amounts for completed retro transactions.

******************************************************************************************************/
FUNCTION retro_amount(i_row_id IN VARCHAR2) RETURN NUMBER IS

CURSOR new_amount IS
SELECT retro.amount - expired.amount
  FROM hxt_det_hours_worked_f expired,
       hxt_det_hours_worked_f retro
 WHERE retro.rowid = CHARTOROWID(i_row_id)
   AND retro.parent_id = expired.parent_id
   AND retro.element_type_id = expired.element_type_id
   AND expired.pay_status = 'A'
   AND expired.effective_end_date = (SELECT MAX(ex.effective_end_date)
                                       FROM hxt_det_hours_worked_f ex
                                      WHERE ex.effective_end_date < retro.effective_start_date
                                        AND ex.parent_id = retro.parent_id
                                        AND ex.pay_status = 'A'
                                        AND ex.element_type_id = retro.element_type_id);

l_amount NUMBER DEFAULT NULL;

BEGIN
  OPEN new_amount;
  FETCH new_amount INTO l_amount;
  CLOSE new_amount;
  RETURN l_amount;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END retro_amount;
/*END RETROPAY*/
/*END SIR015*/
END HXT_USER_EXITS;

/
