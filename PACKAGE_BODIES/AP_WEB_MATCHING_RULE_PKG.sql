--------------------------------------------------------
--  DDL for Package Body AP_WEB_MATCHING_RULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_MATCHING_RULE_PKG" AS
/* $Header: apwmachb.pls 120.2 2006/05/24 20:08:34 abordia noship $ */

--
-- Cursor used to lock CARD record
cursor ccard(p_card_id number) is
select card_id from ap_cards_all where card_id = p_card_id
for update of card_id;


--
-- Breaks the employee name into first/last.
-- If the employee name consists of one strings, it is assumed to be
-- the last name.
-- If the employee name consists of exactly two strings, it matches
-- as the first name and last name.
-- If the employee name consists of more than two strings, it matches
-- the first two strings to the first and last name, and the rest
-- are ignored.
PROCEDURE GET_EMPLOYEE_NAME2(p_employee_name IN VARCHAR2,
                             p_first_name OUT NOCOPY VARCHAR2,
                             p_last_name OUT NOCOPY VARCHAR2)
IS
  space1 NUMBER;
  space2 NUMBER;
BEGIN
  p_first_name := null;
  p_last_name := null;

  space1 := 1;
  space2 := instr(p_employee_name, ' ');

  if space2 = 0 then
    p_last_name := p_employee_name;
    return;
  end if;

  p_first_name := substr(p_employee_name, space1, space2-space1);

  space1 := space2+1;
  space2 := instr(p_employee_name, ' ', space1);
  if space2 = 0 then
    p_last_name := substr(p_employee_name, space1);
  else
    p_last_name := substr(p_employee_name, space1, space2-space1);
  end if;
END GET_EMPLOYEE_NAME2;

--
-- Breaks the employee name into first/middle/last names.
-- If there is one string, it is the last name.
-- If there are two strings, it is the first and last names.
-- If there are three strings, it is the first/middle/last names.
-- If there are more than three strings, the first three strings
-- are matched to the first/middle/last, and the rest are ignored.
PROCEDURE GET_EMPLOYEE_NAME3(p_employee_name IN VARCHAR2,
                             p_first_name OUT NOCOPY VARCHAR2,
                             p_middle_name OUT NOCOPY VARCHAR2,
                             p_last_name OUT NOCOPY VARCHAR2)
IS
  space1 NUMBER;
  space2 NUMBER;
BEGIN
  space1 := 1;
  space2 := instr(p_employee_name, ' ');

  if space2 = 0 then
    p_last_name := p_employee_name;
    return;
  end if;
  p_first_name := substr(p_employee_name, space1, space2-space1);

  space1 := space2+1;
  space2 := instr(p_employee_name, ' ', space1);
  if space2 = 0 then
    p_last_name := substr(p_employee_name, space1);
    return;
  end if;
  p_middle_name := substr(p_employee_name, space1, space2-space1);

  space1 := space2+1;
  space2 := instr(p_employee_name, ' ', space1);
  if space2 = 0 then
    p_last_name := substr(p_employee_name, space1);
  else
    p_last_name := substr(p_employee_name, space1, space2-space1);
  end if;

END GET_EMPLOYEE_NAME3;

--
-- Locks the card so that multiple calls won't get in the way
-- of each other.
-- It essentially protects ap_card_emp_candidates table.
PROCEDURE LOCK_CARD(p_card_id NUMBER) IS
 l_card_id number;
BEGIN
  OPEN ccard(p_card_id);
  FETCH ccard INTO l_card_id;

  delete from ap_card_emp_candidates where card_id = p_card_id;
EXCEPTION
  WHEN OTHERS THEN
    IF ccard%ISOPEN then
      close ccard;
    END IF;
END lock_card;

--
-- Unlock the card.
PROCEDURE UNLOCK_CARD IS
BEGIN
  if (ccard%isopen) then
    CLOSE ccard;
  end if;
END UNLOCK_CARD;


--
-- Execute Query
PROCEDURE EXECUTE_QUERY(P_CARD_ID IN NUMBER,
                        P_FIRST_NAME IN VARCHAR2,
                        P_MIDDLE_NAME IN VARCHAR2,
                        P_LAST_NAME IN VARCHAR2,
                        P_NATIONAL_ID IN VARCHAR2,
                        P_EMPLOYEE_NUM IN VARCHAR2) IS
  l_full_name VARCHAR2(240);
  l_where_clause VARCHAR2(500);
  l_execute boolean := false; -- bug 5224047(2)
BEGIN
  IF p_card_id IS NULL THEN
    RETURN;
  END IF;

  IF p_last_name IS NOT NULL OR p_first_name IS NOT NULL OR p_middle_name IS NOT NULL THEN
     l_where_clause := ' AND UPPER(FULL_NAME) LIKE :fullName';
     l_full_name := upper(p_last_name) ||'%' ||upper(p_first_name)||'%'||upper(p_middle_name);
     l_execute := true;
   ELSE
     l_where_clause := ' AND FULL_NAME IS NULL AND :fullName IS NULL';
     l_full_name := NULL;
  END IF;
  IF p_national_id IS NOT NULL THEN
     l_where_clause := l_where_clause || ' AND NATIONAL_IDENTIFIER = :nationalId';
     l_execute := true;
   ELSE
     l_where_clause := l_where_clause || ' AND NATIONAL_IDENTIFIER IS NULL AND :nationalId IS NULL';
  END IF;
  IF p_employee_num IS NOT NULL THEN
     l_where_clause := l_where_clause || ' AND EMPLOYEE_NUMBER = :empNum';
     l_execute := true;
   ELSE
     l_where_clause := l_where_clause || ' AND EMPLOYEE_NUMBER IS NULL AND :empNum IS NULL';
  END IF;

  IF (l_execute) THEN
     lock_card(p_card_id);
     execute immediate
             'INSERT INTO ap_card_emp_candidates(card_id, employee_id, created_by, creation_date, last_updated_by, last_update_date, last_update_login)
             SELECT card.card_id,
             pap.person_id,
             fnd_global.user_id,
             trunc(sysdate),
             fnd_global.user_id,
             trunc(sysdate),
             fnd_global.login_id
        FROM PER_ALL_PEOPLE_F pap, FINANCIALS_SYSTEM_PARAMS_ALL fsp, PER_PERSON_TYPES ppt, AP_CARDS_ALL card
        WHERE
            card.CARD_ID = :cardId
        AND card.ORG_ID = fsp.ORG_ID
        AND TRUNC(sysdate) BETWEEN pap.effective_start_date AND pap.effective_end_date
        AND pap.business_group_id = fsp.business_group_id
        AND pap.business_group_id = ppt.business_group_id
        AND UPPER(ppt.user_person_type) <> ''CONTACT''
        AND pap.person_type_id = ppt.person_type_id'||l_where_clause
        using p_card_id, l_full_name, p_national_id, p_employee_num;

      unlock_card;
  END IF;
END EXECUTE_QUERY;

------------------------------------------------------------
-- Default matching rule
-- If FIRST_NAME, MIDDLE_NAME, or LAST_NAME is populated
-- then it uses that to match employee name. Otherwise it uses
-- the FULL_NAME and tries to break it apart into its component
-- assuming a "First Middle Last" format. Name always uses
-- case insensitive matching.
-- National identifier and employee number are passed directly.
-------------------------------------------------------------
PROCEDURE GET_EMPLOYEE_MATCHES(p_card_id IN NUMBER) IS
  CURSOR ccard IS SELECT full_name, first_name, middle_name, last_name, employee_number, national_identifier
                  FROM ap_card_details
                  WHERE card_id = p_card_id;
  l_full_name varchar2(80);
  l_employee_number varchar2(30);
  l_national_identifier varchar2(30);
  l_first_name VARCHAR2(150);
  l_middle_name VARCHAR2(150);
  l_last_name VARCHAR2(150);
BEGIN
  OPEN ccard;
  FETCH ccard INTO l_full_name, l_first_name, l_middle_name, l_last_name, l_employee_number, l_national_identifier;
  IF ccard%FOUND THEN
    IF l_first_name IS NULL AND l_middle_name IS NULL AND l_last_name IS NULL AND
       l_full_name IS NOT NULL
    THEN
      get_employee_name3(l_full_name,
                         l_first_name,
                         l_middle_name,
                         l_last_name);
    END IF;
    execute_query(p_card_id, l_first_name, l_middle_name, l_last_name, l_national_identifier, l_employee_number);
  END IF;
  CLOSE ccard;
END GET_EMPLOYEE_MATCHES;


END AP_WEB_MATCHING_RULE_PKG;

/
