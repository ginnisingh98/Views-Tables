--------------------------------------------------------
--  DDL for Package Body PJI_FM_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_FM_DEBUG" as
  /* $Header: PJISF11B.pls 120.0 2005/05/29 12:42:15 appldev noship $ */

  -- -----------------------------------------------------
  -- procedure CONC_REQUEST_HOOK
  -- -----------------------------------------------------
  procedure CONC_REQUEST_HOOK (p_process in varchar2) is

  begin

    --
    --  Uncomment these execute immediate statements to create database
    --  trace files for all of the summarization workers.
    --
    --
    -- execute immediate 'alter session set sql_trace TRUE';
    -- execute immediate 'alter session set timed_statistics=TRUE';

    if (p_process = PJI_FM_SUM_MAIN.g_process) then

      -- dispatcher

      null;

    elsif (p_process like PJI_FM_SUM_MAIN.g_process || '%') then

      -- phase 1 worker

      null;

    end if;

    exception when others then null;

  end CONC_REQUEST_HOOK;

  -- -----------------------------------------------------
  -- procedure CLEANUP_HOOK
  -- -----------------------------------------------------
  procedure CLEANUP_HOOK (p_process in varchar2) is

  begin

    if (p_process = PJI_FM_SUM_MAIN.g_process) then

      -- dispatcher

      null;

    elsif (p_process like PJI_FM_SUM_MAIN.g_process || '%') then

      -- phase 1 worker

      null;

    end if;

    exception when others then null;

  end CLEANUP_HOOK;

end PJI_FM_DEBUG;

/
