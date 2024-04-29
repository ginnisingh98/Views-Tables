--------------------------------------------------------
--  DDL for Package Body AP_WEB_AMEX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_AMEX_PKG" as
/* $Header: apwamexb.pls 120.1.12010000.2 2009/04/06 12:11:56 meesubra ship $ */

PROCEDURE GET_EMPLOYEE_MATCHES(p_card_id IN NUMBER,
                               p_employee_name IN VARCHAR2,
                               p_employee_number IN VARCHAR2,
                               p_national_identifier IN VARCHAR2);

------------------------------------------------------------------
-- American Express sends us name, employee number, and
-- national identifier (e.g., social security number)
-- Match against all.
--
-- Special treatment is made for national identifier.
-- If national identifier starts with a 0, it matches the last
-- 9 characters only. The SSN number in the database needs to be
-- in the format AAA-GG-SSSS to automatically assign and activate
-- the Credit card Account.
-- NOTE: This works for social security numbers (US)
--       But could pose problems if used in countries with a 10
--       character id. It would fail to match the following
--       Feed = 0123456789, Database=0123456789
------------------------------------------------------------------
PROCEDURE GET_EMPLOYEE_MATCHES(p_card_id IN NUMBER) IS
  CURSOR ccard IS SELECT full_name, employee_number, national_identifier
                  FROM ap_card_details
                  WHERE card_id = p_card_id;
  l_full_name varchar2(80);
  l_employee_number varchar2(30);
  l_national_identifier varchar2(30);
BEGIN
  OPEN ccard;
  FETCH ccard INTO l_full_name, l_employee_number, l_national_identifier;
  IF ccard%FOUND THEN
    GET_EMPLOYEE_MATCHES(p_card_id, l_full_name, l_employee_number, l_national_identifier);
  END IF;
  CLOSE ccard;
END GET_EMPLOYEE_MATCHES;

PROCEDURE GET_EMPLOYEE_MATCHES(p_card_id IN NUMBER,
                               p_employee_name IN VARCHAR2,
                               p_employee_number IN VARCHAR2,
                               p_national_identifier IN VARCHAR2) IS

  l_first_name VARCHAR2(150);
  l_middle_name VARCHAR2(150);
  l_last_name VARCHAR2(150);
  l_social_security_num VARCHAR2(20);
  -- Bug 8349020 Formatting the SSN Number
  l_area_number VARCHAR2(3);
  l_group_number VARCHAR2(2);
  l_serial_number VARCHAR2(4);
BEGIN
   ap_web_matching_rule_pkg.get_employee_name3(p_employee_name,
                                               l_first_name,
                                               l_middle_name,
                                               l_last_name);
   IF Substr(p_national_identifier, 1, 1) = '0' THEN
      l_social_security_num := Substr(p_national_identifier, 2);
      -- Bug 8349020 Formatting the SSN Number to a standard format AAA-GG-SSSS
      IF length(l_social_security_num) = 9 THEN
	 l_area_number := Substr(l_social_security_num, 1,3);
	 l_group_number := Substr(l_social_security_num, 4,2);
	 l_serial_number := Substr(l_social_security_num, 6);
	 l_social_security_num := l_area_number || '-' || l_group_number || '-' || l_serial_number;
      END IF;
    ELSE
      l_social_security_num := p_national_identifier;
   END IF;

   ap_web_matching_rule_pkg.execute_query(p_card_id, l_first_name, l_middle_name, l_last_name, l_social_security_num, p_employee_number);
END GET_EMPLOYEE_MATCHES;

END AP_WEB_AMEX_PKG;

/
