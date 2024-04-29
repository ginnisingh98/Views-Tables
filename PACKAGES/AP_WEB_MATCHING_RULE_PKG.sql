--------------------------------------------------------
--  DDL for Package AP_WEB_MATCHING_RULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_MATCHING_RULE_PKG" AUTHID CURRENT_USER as
  /* $Header: apwmachs.pls 115.1 2003/10/17 00:11:29 kmizuta noship $ */

  --
  -- Given a full name, the following two procedures
  -- breaks it apart into first/last or first/middle/last.
  PROCEDURE GET_EMPLOYEE_NAME2(p_employee_name IN VARCHAR2,
                             p_first_name OUT NOCOPY VARCHAR2,
                             p_last_name OUT NOCOPY VARCHAR2);
  PROCEDURE GET_EMPLOYEE_NAME3(p_employee_name IN VARCHAR2,
                             p_first_name OUT NOCOPY VARCHAR2,
                             p_middle_name OUT NOCOPY VARCHAR2,
                             p_last_name OUT NOCOPY VARCHAR2);

  --
  -- If the procedures above are not used to build the SQL statement
  -- and execute the matches, you should call the LOCK_CARD
  -- just prior to populating AP_CARD_EMP_CANDIDATES and call
  -- UNLOCK_CARD right after.
  PROCEDURE LOCK_CARD(p_card_id NUMBER);
  PROCEDURE UNLOCK_CARD;

  --
  -- Execute query
  PROCEDURE EXECUTE_QUERY(P_CARD_ID IN NUMBER,
                        P_FIRST_NAME IN VARCHAR2,
                        P_MIDDLE_NAME IN VARCHAR2,
                        P_LAST_NAME IN VARCHAR2,
                        P_NATIONAL_ID IN VARCHAR2,
                        P_EMPLOYEE_NUM IN VARCHAR2);

  --
  -- Default matching rule
  PROCEDURE GET_EMPLOYEE_MATCHES(p_card_id IN NUMBER);
end;

 

/
