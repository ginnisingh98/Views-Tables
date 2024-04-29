--------------------------------------------------------
--  DDL for Package Body AP_WEB_EMP_NUM_MATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_EMP_NUM_MATCH_PKG" as
/* $Header: apwenmhb.pls 120.1 2006/03/24 17:07:14 abordia noship $ */

PROCEDURE GET_EMPLOYEE_MATCHES(p_card_id IN NUMBER,
                               p_employee_number IN VARCHAR2);


PROCEDURE GET_EMPLOYEE_MATCHES(p_card_id IN NUMBER) IS
  CURSOR ccard IS SELECT employee_number
                  FROM ap_card_details
                  WHERE card_id = p_card_id
                  AND EMPLOYEE_NUMBER IS NOT NULL;
  l_full_name varchar2(80);
  l_employee_number varchar2(30);
  l_national_identifier varchar2(30);
BEGIN
  OPEN ccard;
  FETCH ccard INTO l_employee_number;
  IF ccard%FOUND THEN
    GET_EMPLOYEE_MATCHES(p_card_id, l_employee_number);
  END IF;
  CLOSE ccard;
END GET_EMPLOYEE_MATCHES;

-- matches only on employee number
PROCEDURE GET_EMPLOYEE_MATCHES(p_card_id IN NUMBER,
                               p_employee_number IN VARCHAR2) IS

BEGIN
    AP_WEB_MATCHING_RULE_PKG.lock_card(p_card_id);
    INSERT INTO ap_card_emp_candidates(card_id, employee_id, created_by, creation_date, last_updated_by, last_update_date, last_update_login)
    SELECT card.card_id,
         pap.person_id,
         fnd_global.user_id,
         trunc(sysdate),
         fnd_global.user_id,
         trunc(sysdate),
         fnd_global.login_id
    FROM PER_ALL_PEOPLE_F pap, FINANCIALS_SYSTEM_PARAMS_ALL fsp, PER_PERSON_TYPES ppt, AP_CARDS_ALL card
    WHERE
        card.CARD_ID = p_card_id
    AND card.ORG_ID = fsp.ORG_ID
    AND TRUNC(sysdate) BETWEEN pap.effective_start_date AND pap.effective_end_date
    AND pap.business_group_id = fsp.business_group_id
    AND pap.business_group_id = ppt.business_group_id
    AND UPPER(ppt.user_person_type) <> 'CONTACT'
    AND pap.person_type_id = ppt.person_type_id
    AND EMPLOYEE_NUMBER = p_employee_number
   ;

  AP_WEB_MATCHING_RULE_PKG.unlock_card;
END GET_EMPLOYEE_MATCHES;

END AP_WEB_EMP_NUM_MATCH_PKG;

/
