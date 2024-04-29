--------------------------------------------------------
--  DDL for Package Body PA_CCD_TIEBACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CCD_TIEBACK" AS
/* $Header: PACCTIEB.pls 120.2 2006/02/10 03:46:40 avajain noship $ */

G_Debug_Mode             BOOLEAN ;
G_user_id                NUMBER;
G_concurrent_request_id  NUMBER;
G_concurrent_program_id  NUMBER;
G_conc_program_app_id    NUMBER;
G_concurrent_login_id    NUMBER;
G_je_category_name       VARCHAR2(30);
G_source_name            VARCHAR2(30);

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    PROCEDURE tieback_ccds_initialize  IS
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- JE Source Name
CURSOR c2 is
    SELECT user_je_source_name
    FROM GL_JE_SOURCES
    WHERE  je_source_name  =  'Project Accounting' ;

BEGIN
null;
END tieback_ccds_initialize;

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROCEDURE tieback_ccds_to_pa (
             P_Set_of_Books_id IN NUMBER,
             P_Sob_Type IN VARCHAR2,
             P_Debug_Mode IN VARCHAR2)  IS
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
l_bad_lines NUMBER;
l_out       NUMBER;           /*Bug# 2158443*/
l_error     VARCHAR2(20);     /*Bug# 2158443*/

BEGIN
null;
END tieback_ccds_to_pa ;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
FUNCTION get_reject_count RETURN NUMBER IS
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

BEGIN
   return null;
END get_reject_count;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROCEDURE log_message( p_message IN VARCHAR2) IS
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

BEGIN
 null;

END log_message;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROCEDURE set_curr_function(p_function IN VARCHAR2) IS
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

BEGIN

    null;
END;

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
PROCEDURE reset_curr_function IS
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

BEGIN

    null;

END;

END PA_CCD_TIEBACK;

/
