--------------------------------------------------------
--  DDL for Package Body IGI_ITR_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_ITR_UTILS_PKG" as
-- $Header: igiitrvb.pls 120.8.12000000.1 2007/09/12 10:33:11 mbremkum ship $
--

  FUNCTION  find_originators_segment_value(X_segment_number IN VARCHAR2,
                                           X_originator_id IN NUMBER,
	  				   X_charge_center IN NUMBER,
	 				-- Parameter added for Bug 3977858
                                           X_segment_value OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS

    l_segment_value VARCHAR2(30);

  BEGIN

    EXECUTE immediate 'SELECT '|| X_segment_number ||' FROM igi_itr_charge_orig WHERE originator_id = :x_orig_id and  sysdate>start_date and nvl(end_date,sysdate) >= sysdate and charge_center_id = :x_charge_center'
    INTO l_segment_value
    USING IN  X_originator_id, X_charge_center;	--Bug 3977858

    X_segment_value := l_segment_value;
    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;

  END find_originators_segment_value;


  FUNCTION find_segment_value(X_segment_number       IN VARCHAR2
                             ,X_code_combination_id  IN NUMBER
                             ,X_chart_of_accounts_id IN NUMBER
                             ,X_segment_value        OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS

    l_segment_value VARCHAR2(30);

  BEGIN

    EXECUTE immediate
    'SELECT '|| X_segment_number ||' FROM  gl_code_combinations_kfv WHERE code_combination_id = :x_code_combination_id '||
    ' AND   chart_of_accounts_id = :x_chart_of_accounts_id '
    INTO    l_segment_value
    USING   IN X_code_combination_id, IN X_chart_of_accounts_id;

    X_segment_value := l_segment_value;
    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
    RETURN FALSE;

  END find_segment_value;


END IGI_ITR_UTILS_PKG;

/
