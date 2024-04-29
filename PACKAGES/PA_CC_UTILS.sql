--------------------------------------------------------
--  DDL for Package PA_CC_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CC_UTILS" AUTHID CURRENT_USER as
-- $Header: PAXCCUTS.pls 115.6 2002/12/13 22:22:46 vgade ship $
--
-- Global variables used by the Borrowed and Lent and
-- IC Billing process
--

  g_login_id                NUMBER;
  g_program_application_id  NUMBER;
  g_program_id              NUMBER;
  g_request_id              NUMBER;
  g_user_id                 NUMBER;

  g_primary_sob_id          gl_sets_of_books.set_of_books_id%TYPE;
  g_prvdr_org_id            pa_implementations_all.org_id%TYPE;
  g_reporting_sob_id        PA_PLSQL_DATATYPES.IDTabTyp;
  g_reporting_curr_code     PA_PLSQL_DATATYPES.Char15TabTyp;
  g_debug_mode              BOOLEAN;

--  FUNCTION
--              is_receiver_control_setup
--
--
Function is_receiver_control_setup (x_provider_org_id  IN number,
x_receiver_org_id  IN number) Return number;
--Bug2698541
--pragma RESTRICT_REFERENCES (is_receiver_control_setup, WNDS, WNPS);
--
--  FUNCTION
--              check_pvdr_rcvr_control_exist
--
--
Function check_pvdr_rcvr_control_exist (x_project_id  IN number)
return number;
--Bug2698541
--pragma RESTRICT_REFERENCES (check_pvdr_rcvr_control_exist, WNDS, WNPS);

-- Procedure log_message
-- Displays a message using the current function set by the
-- procedure set_curr_function
-- in addition to that, it sends the write mode
-- write mode: 0 print in debug mode
--             1 print always

PROCEDURE log_message(p_message IN VARCHAR2, p_write_mode IN NUMBER DEFAULT 0);

-- Procedure set_curr_function
-- Sets the current function name passed in and also sets the stack
-- information.  Always call this at the beginning of each procedure

PROCEDURE set_curr_function(p_function IN VARCHAR2);

-- Procedure reset_curr_function
-- Resets the current function name and also resets the stack
-- information.  Always call this at the end of each procedure.
-- Has no arguments

PROCEDURE reset_curr_function;

end PA_CC_UTILS;

 

/
