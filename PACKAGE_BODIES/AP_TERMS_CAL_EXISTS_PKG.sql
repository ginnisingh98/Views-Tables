--------------------------------------------------------
--  DDL for Package Body AP_TERMS_CAL_EXISTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_TERMS_CAL_EXISTS_PKG" AS
/*$Header: aptmcalb.pls 120.4 2005/05/12 11:21:25 sguddeti noship $*/

PROCEDURE Check_For_Calendar
             (p_terms_name        IN       varchar2,
              p_terms_date        IN       date,
              p_no_cal            IN OUT NOCOPY  varchar2,
              p_calling_sequence  IN       varchar2) IS
CURSOR c IS
  SELECT calendar
  FROM   ap_terms,
         ap_terms_lines
  WHERE  ap_terms.term_id = ap_terms_lines.term_id
  AND    ap_terms.name = p_terms_name
  AND    ap_terms_lines.calendar is not null;

l_calendar               VARCHAR2(30);
l_cal_exists             VARCHAR2(1);
l_debug_info             VARCHAR2(100);
l_curr_calling_sequence  VARCHAR2(2000);

BEGIN
  -- Update the calling sequence
  --
  l_curr_calling_sequence :=
  'AP_TERMS_CAL_EXISTS_PKG.Check_For_Calendar<-'||p_calling_sequence;

  --------------------------------------------------------
  l_debug_info := 'OPEN  cursor c';
  --------------------------------------------------------

  l_cal_exists := '';
  OPEN c;

  LOOP
     --------------------------------------------------------
     l_debug_info := 'Fetch cursor C';
     --------------------------------------------------------
     FETCH c INTO l_calendar;
     EXIT WHEN c%NOTFOUND;

     --------------------------------------------------------
     l_debug_info := 'Check for calendar';
     --------------------------------------------------------
     BEGIN

       -- Bug1769230 Added truncate function to eliminate time part
       -- from p_terms_date variable.
       SELECT 'Y'
       INTO   l_cal_exists
       FROM   ap_other_periods aop,
              ap_other_period_types aopt
       WHERE  aopt.period_type = l_calendar
       AND    aopt.module = 'PAYMENT TERMS'
       AND    aopt.module = aop.module -- bug 2902681
       AND    aopt.period_type = aop.period_type
       AND    aop.start_date <= trunc(p_terms_date)
       AND    aop.end_date >= trunc(p_terms_date);
     EXCEPTION
       WHEN NO_DATA_FOUND then
         null;
     END;

     if (l_cal_exists <> 'Y') or (l_cal_exists is null) then
         p_no_cal := 'Y';
         return;
     end if;

  END LOOP;
  --------------------------------------------------------
  l_debug_info := 'CLOSE  cursor c';
  --------------------------------------------------------
  CLOSE c;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                    'Payment Terms = '|| p_terms_name
                 ||' Terms date = '||to_char(p_terms_date));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
End Check_For_Calendar;

END Ap_Terms_Cal_Exists_Pkg;

/
