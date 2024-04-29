--------------------------------------------------------
--  DDL for Package AMW_ASSERTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_ASSERTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: amwtasts.pls 120.0 2005/05/31 20:26:46 appldev noship $ */
-- ===============================================================
-- Function name
--          ACCT_ASSERTIONS_PRESENT
-- Purpose
-- 		    return non translated character (Y/N) to indicate the
--          selected(associated) Assertion
-- ===============================================================
FUNCTION ACCT_ASSERTIONS_PRESENT (
    p_natural_account_id  IN         NUMBER,
    p_assertion_code      IN         VARCHAR2
) RETURN VARCHAR2;


-- ===============================================================
-- Function name
--          ACCT_ASSERTIONS_PRESENT_MEAN
-- Purpose
-- 		    return translated meaning (Yes/No) to indicate the
--          selected(associated) Compliance Environment
-- ===============================================================
FUNCTION ACCT_ASSERTIONS_PRESENT_MEAN (
    p_natural_account_id  IN         NUMBER,
    p_assertion_code      IN         VARCHAR2
) RETURN VARCHAR2;

-- ===============================================================
-- Procedure name
--          PROCESS_ACCT_ASSERTION_ASSOCS
-- Purpose
-- 		    Update the Account Assertion associations depending
--          on the specified p_select_flag .
-- ===============================================================
PROCEDURE PROCESS_ACCT_ASSERTION_ASSOCS (
                   p_select_flag         IN         VARCHAR2,
                   p_natural_account_id  IN         NUMBER,
                   p_assertion_code      IN         VARCHAR2
);

-- ----------------------------------------------------------------------
END  AMW_ASSERTIONS_PKG;

 

/
