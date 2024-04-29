--------------------------------------------------------
--  DDL for Package Body PQP_UK_PS_FF_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_UK_PS_FF_FUNCTIONS" as
/* $Header: pqukpsfn.pkb 120.1 2005/05/30 00:12:51 rvishwan noship $ */
FUNCTION date_diff(p_greater_date  IN DATE ,
                   p_smaller_date  IN DATE ) RETURN NUMBER IS
l_diff_days NUMBER;
BEGIN
    IF (p_greater_date >= p_smaller_date) THEN
        l_diff_days := p_greater_date - p_smaller_date + 1;
    ELSE
        l_diff_days := 9999999;
    END IF;
    RETURN l_diff_days;
END date_diff;
END pqp_uk_ps_ff_functions;

/
