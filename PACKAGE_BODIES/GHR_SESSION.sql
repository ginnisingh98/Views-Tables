--------------------------------------------------------
--  DDL for Package Body GHR_SESSION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_SESSION" as
/* $Header: ghstsess.pkb 120.0.12010000.2 2009/05/26 11:01:02 vmididho noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ghr_session.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< set_session_var_for_core  >------------------------|
-- ----------------------------------------------------------------------------
---- Make sure that there is an entry in the fnd_sessions table for the current session

 Procedure set_session_var_for_core
 (p_effective_date   in date
 )
 is

  l_exists                    boolean := FALSE;
  l_session_var               ghr_history_api.g_session_var_type;
  l_effective_date            date;
  l_session_id                fnd_sessions.session_id%type;

  Cursor c_session_id is
    select userenv('sessionid') sessionid
    from   dual;

  Cursor c_session_data is
    select effective_date,
           session_id
    from   fnd_sessions
    where  session_id = l_session_id;

Begin

  for session_id in C_session_id loop
     l_session_id    :=  session_id.sessionid;
  end loop;

  for session in c_session_data loop

    l_exists         := TRUE;
    l_effective_date :=  session.effective_date;
  end loop;

  If l_exists then

    If nvl(trunc(l_effective_date),hr_api.g_date) <>  p_effective_date then
      update fnd_sessions
      set    effective_date = p_effective_date
      where  session_id     = l_session_id;
    End if;
  Else
     Insert into fnd_sessions
     (session_id,effective_date)
     values
     (l_session_id,p_effective_date);
  End if;

  -- Set session variables

  ghr_history_api.reinit_g_session_var;
  l_session_var.program_name    :=  'core';
  l_session_var.fire_trigger    :=  'Y';
  ghr_history_api.set_g_session_var(l_session_var);

 End set_session_var_for_core;
End ghr_session;

/
