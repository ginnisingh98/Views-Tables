--------------------------------------------------------
--  DDL for Package HR_JPDRB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_JPDRB" AUTHID CURRENT_USER AS
/* $Header: pyjpdrb.pkh 115.4 2004/05/14 02:48:47 keyazawa ship $ */
/* ------------------------------------------------------------------------------------ */
--Cached variables
cached_rows			NUMBER  := 0;
cached_assignment_id		NUMBER  := 0;
--
TYPE CachedTable IS TABLE OF NUMBER
     INDEX BY BINARY_INTEGER;
--
TYPE CachedDateTable IS TABLE OF DATE
     INDEX BY BINARY_INTEGER;
--
cached_defined_balances 	CachedTable;
cached_values			CachedTable;
cached_assignment_actions	CachedTable;
cached_expired_actions		CachedTable;
cached_expired_values		CachedTable;
cached_action_sequences		CachedTable;
cached_assignments		CachedTable;
cached_effective_dates		CachedDateTable;

--
-- Date Mode
FUNCTION get_balance (p_assignment_id   IN NUMBER,
                      p_defined_balance_id IN NUMBER,
                      p_effective_date     IN DATE)
RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
-- Assignment Action Mode
FUNCTION get_balance (p_assignment_action_id IN NUMBER,
                      p_defined_balance_id   IN NUMBER)
RETURN NUMBER;
/* ------------------------------------------------------------------------------------ */
FUNCTION balance_expired (p_assignment_action_id IN NUMBER,
                          p_defined_balance_id   IN NUMBER,
            			  p_dimension_name IN VARCHAR2,
                          p_effective_date       IN DATE,
             			  p_action_effective_date IN DATE)
--
RETURN BOOLEAN;
/* ------------------------------------------------------------------------------------ */
FUNCTION expired_period_date(p_assignment_action_id IN NUMBER)
--
RETURN DATE;
--
/* ------------------------------------------------------------------------------------ */
FUNCTION get_action_date(p_assignment_action_id IN NUMBER)
RETURN DATE;
/* ------------------------------------------------------------------------------------ */
--
END hr_jpdrb;

 

/
