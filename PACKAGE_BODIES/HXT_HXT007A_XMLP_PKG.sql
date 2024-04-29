--------------------------------------------------------
--  DDL for Package Body HXT_HXT007A_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_HXT007A_XMLP_PKG" AS
/* $Header: HXT007AB.pls 120.0 2007/12/03 10:34:58 amakrish noship $ */

FUNCTION CF_PAYROLLFormula return VARCHAR2 is
BEGIN
  DECLARE
    Cursor Dates_Cur Is
    Select Effective_Start_Date, Effective_End_Date
      From Pay_Payrolls_X
     Where Payroll_Id = P_Payroll_Id;

    CURSOR payroll_cur(ES_Date In Date, EE_Date In Date)IS
    SELECT pay.payroll_name
      FROM pay_payrolls_x pay
     WHERE pay.business_group_id = (Select Business_Group_Id
                                      From Pay_Payrolls_X
                                     Where Payroll_Id = P_Payroll_Id
                                       And Effective_Start_Date = ES_Date
                                       And Effective_End_Date   = EE_Date)
       AND pay.payroll_id = p_payroll_id
       And Effective_Start_Date = ES_Date
       And Effective_End_Date   = EE_Date;


      l_payroll_name pay_payrolls_f.payroll_name%TYPE;
      EStart_Date pay_payrolls_f.Effective_Start_Date%Type;
      EEnd_Date	pay_payrolls_f.Effective_Start_Date%Type;

  BEGIN
    Open Dates_Cur;
    If Dates_Cur%NotFound Then
       Close Dates_Cur;
       Return Null;
    End If;
    Fetch Dates_Cur Into EStart_Date, EEnd_Date;
    Close Dates_Cur;

    OPEN payroll_cur(EStart_Date, EEnd_Date);
    If Payroll_Cur%NotFound Then
       Close Payroll_Cur;
       Return Null;
    End If;
    FETCH payroll_cur INTO l_payroll_name;
    CLOSE payroll_cur;

    RETURN l_payroll_name;

  EXCEPTION when no_data_found then
    RETURN null;
  END;
END;

function cf_detail_hoursformula(P_BATCH_ID in number) return number is

  CURSOR details_hours_cur IS
  SELECT SUM(det.hours)
    FROM pay_element_types_f elt,
         hxt_pay_element_types_f_ddf_v eltv,
         hxt_det_hours_worked_f det,
         hxt_timecards_f tim
   WHERE det.element_type_id = elt.element_type_id
     AND det.date_worked BETWEEN elt.effective_start_date AND elt.effective_end_date
     AND elt.element_type_id = eltv.element_type_id
     AND det.date_worked BETWEEN eltv.effective_start_date AND eltv.effective_end_date
     AND eltv.hxt_earning_category IN ('REG','OVT','ABS')
     AND det.retro_batch_id IS NULL
     AND det.tim_id = tim.id
     AND tim.batch_id = P_BATCH_ID;

l_details_hours hxt_det_hours_worked_f.hours%TYPE := NULL;

begin
  OPEN details_hours_cur;
  FETCH details_hours_cur INTO l_details_hours;
  IF details_hours_cur%NOTFOUND THEN
    CLOSE details_hours_cur;
    RETURN 0;
  END IF;
  CLOSE details_hours_cur;

  IF l_details_hours IS NULL THEN
    RETURN 0;
  ELSE
    RETURN l_details_hours;
  END IF;
end;

function cf_bee_line_hoursformula(ELEMENT_TYPE_ID in number, VALUE_1 in varchar2, VALUE_2 in varchar2, VALUE_3 in varchar2, VALUE_4 in varchar2, VALUE_5 in varchar2, VALUE_6 in varchar2, VALUE_7 in varchar2,
VALUE_8 in varchar2, VALUE_9 in varchar2, VALUE_10 in varchar2, VALUE_11 in varchar2, VALUE_12 in varchar2, VALUE_13 in varchar2, VALUE_14 in varchar2, VALUE_15 in varchar2) return number is
  seq1      PAY_INPUT_VALUES_F.INPUT_VALUE_ID%TYPE := NULL;
  seq2      PAY_INPUT_VALUES_F.INPUT_VALUE_ID%TYPE := NULL;
  seq3      PAY_INPUT_VALUES_F.INPUT_VALUE_ID%TYPE := NULL;
  seq4      PAY_INPUT_VALUES_F.INPUT_VALUE_ID%TYPE := NULL;
  seq5      PAY_INPUT_VALUES_F.INPUT_VALUE_ID%TYPE := NULL;
  seq6      PAY_INPUT_VALUES_F.INPUT_VALUE_ID%TYPE := NULL;
  seq7      PAY_INPUT_VALUES_F.INPUT_VALUE_ID%TYPE := NULL;
  seq8      PAY_INPUT_VALUES_F.INPUT_VALUE_ID%TYPE := NULL;
  seq9      PAY_INPUT_VALUES_F.INPUT_VALUE_ID%TYPE := NULL;
  seq10     PAY_INPUT_VALUES_F.INPUT_VALUE_ID%TYPE := NULL;
  seq11     PAY_INPUT_VALUES_F.INPUT_VALUE_ID%TYPE := NULL;
  seq12     PAY_INPUT_VALUES_F.INPUT_VALUE_ID%TYPE := NULL;
  seq13     PAY_INPUT_VALUES_F.INPUT_VALUE_ID%TYPE := NULL;
  seq14     PAY_INPUT_VALUES_F.INPUT_VALUE_ID%TYPE := NULL;
  seq15     PAY_INPUT_VALUES_F.INPUT_VALUE_ID%TYPE := NULL;
  name1     PAY_INPUT_VALUES_F_TL.NAME%TYPE := NULL;
  name2     PAY_INPUT_VALUES_F_TL.NAME%TYPE := NULL;
  name3     PAY_INPUT_VALUES_F_TL.NAME%TYPE := NULL;
  name4     PAY_INPUT_VALUES_F_TL.NAME%TYPE := NULL;
  name5     PAY_INPUT_VALUES_F_TL.NAME%TYPE := NULL;
  name6     PAY_INPUT_VALUES_F_TL.NAME%TYPE := NULL;
  name7     PAY_INPUT_VALUES_F_TL.NAME%TYPE := NULL;
  name8     PAY_INPUT_VALUES_F_TL.NAME%TYPE := NULL;
  name9     PAY_INPUT_VALUES_F_TL.NAME%TYPE := NULL;
  name10    PAY_INPUT_VALUES_F_TL.NAME%TYPE := NULL;
  name11    PAY_INPUT_VALUES_F_TL.NAME%TYPE := NULL;
  name12    PAY_INPUT_VALUES_F_TL.NAME%TYPE := NULL;
  name13    PAY_INPUT_VALUES_F_TL.NAME%TYPE := NULL;
  name14    PAY_INPUT_VALUES_F_TL.NAME%TYPE := NULL;
  name15    PAY_INPUT_VALUES_F_TL.NAME%TYPE := NULL;
  lookup1   PAY_INPUT_VALUES_F.LOOKUP_TYPE%TYPE := NULL;
  lookup2   PAY_INPUT_VALUES_F.LOOKUP_TYPE%TYPE := NULL;
  lookup3   PAY_INPUT_VALUES_F.LOOKUP_TYPE%TYPE := NULL;
  lookup4   PAY_INPUT_VALUES_F.LOOKUP_TYPE%TYPE := NULL;
  lookup5   PAY_INPUT_VALUES_F.LOOKUP_TYPE%TYPE := NULL;
  lookup6   PAY_INPUT_VALUES_F.LOOKUP_TYPE%TYPE := NULL;
  lookup7   PAY_INPUT_VALUES_F.LOOKUP_TYPE%TYPE := NULL;
  lookup8   PAY_INPUT_VALUES_F.LOOKUP_TYPE%TYPE := NULL;
  lookup9   PAY_INPUT_VALUES_F.LOOKUP_TYPE%TYPE := NULL;
  lookup10  PAY_INPUT_VALUES_F.LOOKUP_TYPE%TYPE := NULL;
  lookup11  PAY_INPUT_VALUES_F.LOOKUP_TYPE%TYPE := NULL;
  lookup12  PAY_INPUT_VALUES_F.LOOKUP_TYPE%TYPE := NULL;
  lookup13  PAY_INPUT_VALUES_F.LOOKUP_TYPE%TYPE := NULL;
  lookup14  PAY_INPUT_VALUES_F.LOOKUP_TYPE%TYPE := NULL;
  lookup15  PAY_INPUT_VALUES_F.LOOKUP_TYPE%TYPE := NULL;
  l_meaning HR_LOOKUPS.MEANING%TYPE;
  l_value   PAY_BATCH_LINES.VALUE_1%TYPE;
  l_hours   HXT_DET_HOURS_WORKED_F.HOURS%TYPE := 0;
  l_amount  VARCHAR2(80) := NULL;
  l_dummy   NUMBER;

  CURSOR hours_value(p_meaning VARCHAR2, p_date DATE) IS
    SELECT 1
      FROM hr_lookups
     WHERE lookup_code = 'HOURS'
       AND meaning = p_meaning
       AND lookup_type = 'NAME_TRANSLATIONS'
       AND enabled_flag = 'Y'
       AND p_date BETWEEN nvl(start_date_active, p_date) AND nvl(end_date_active, p_date);

  CURSOR amount_value(p_meaning VARCHAR2, p_date DATE) IS
    SELECT 1
      FROM hr_lookups
     WHERE lookup_code = 'PAY VALUE'
       AND meaning = p_meaning
       AND lookup_type = 'NAME_TRANSLATIONS'
       AND enabled_flag = 'Y'
       AND p_date BETWEEN nvl(start_date_active, p_date) AND nvl(end_date_active, p_date);

begin
    pay_paywsqee_pkg.GET_INPUT_VALUE_DETAILS(ELEMENT_TYPE_ID,
                                           P_DATE_EARNED,
                                           seq1,
                                           seq2,
                                           seq3,
                                           seq4,
                                           seq5,
                                           seq6,
                                           seq7,
                                           seq8,
                                           seq9,
                                           seq10,
                                           seq11,
                                           seq12,
                                           seq13,
                                           seq14,
                                           seq15,
                                           name1,
                                           name2,
                                           name3,
                                           name4,
                                           name5,
                                           name6,
                                           name7,
                                           name8,
                                           name9,
                                           name10,
                                           name11,
                                           name12,
                                           name13,
                                           name14,
                                           name15,
                                           lookup1,
                                           lookup2,
                                           lookup3,
                                           lookup4,
                                           lookup5,
                                           lookup6,
                                           lookup7,
                                           lookup8,
                                           lookup9,
                                           lookup10,
                                           lookup11,
                                           lookup12,
                                           lookup13,
                                           lookup14,
                                           lookup15);

  FOR i in 1..15 LOOP
    IF i = 1 THEN
      l_meaning := name1;
      l_value := VALUE_1;
    ELSIF i = 2 THEN
      l_meaning := name2;
      l_value := VALUE_2;
    ELSIF i = 3 THEN
      l_meaning := name3;
      l_value := VALUE_3;
    ELSIF i = 4 THEN
      l_meaning := name4;
      l_value := VALUE_4;
    ELSIF i = 5 THEN
      l_meaning := name5;
      l_value := VALUE_5;
    ELSIF i = 6 THEN
      l_meaning := name6;
      l_value := VALUE_6;
    ELSIF i = 7 THEN
      l_meaning := name7;
      l_value := VALUE_7;
    ELSIF i = 8 THEN
      l_meaning := name8;
      l_value := VALUE_8;
    ELSIF i = 9 THEN
      l_meaning := name9;
      l_value := VALUE_9;
    ELSIF i = 10 THEN
      l_meaning := name10;
      l_value := VALUE_10;
    ELSIF i = 11 THEN
      l_meaning := name11;
      l_value := VALUE_11;
    ELSIF i = 12 THEN
      l_meaning := name12;
      l_value := VALUE_12;
    ELSIF i = 13 THEN
      l_meaning := name13;
      l_value := VALUE_13;
    ELSIF i = 14 THEN
      l_meaning := name14;
      l_value := VALUE_14;
    ELSIF i = 15 THEN
      l_meaning := name15;
      l_value := VALUE_15;
    END IF;

    OPEN hours_value(l_meaning, P_DATE_EARNED);
    FETCH hours_value INTO l_dummy;
    IF hours_value%FOUND THEN
      l_hours := to_number(l_value);
    ELSE
      OPEN amount_value(l_meaning, P_DATE_EARNED);
      FETCH amount_value INTO l_dummy;
      IF amount_value%FOUND THEN
        l_amount := l_value;
      END IF;
      CLOSE amount_value;
    END IF;
    CLOSE hours_value;
  END LOOP;

  IF l_amount IS NULL THEN
    RETURN l_hours;
  ELSE
    RETURN 0;
  END IF;
end;

function BeforeReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  return (TRUE);
end;

function AfterReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWEXIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_REPORT_SUBTITLE_p return varchar2 is
	Begin
	 return C_REPORT_SUBTITLE;
	 END;
END HXT_HXT007A_XMLP_PKG ;

/
