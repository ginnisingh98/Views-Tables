--------------------------------------------------------
--  DDL for Package FND_JOBS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_JOBS_PKG" AUTHID CURRENT_USER as
/* $Header: AFJOBPKS.pls 120.1 2005/07/02 04:08:48 appldev noship $ */
--
  procedure APPS_INITIALIZE_SYSADMIN;
--
  function SUBMIT_JOB(P_APPLICATION_SHORT_NAME  in varchar2,
                      P_CONCURRENT_PROGRAM_NAME in varchar2,
                      P_ALTERNATE_PROGRAM       in varchar2)
    return number;
--
  function SUBMIT_MENU_COMPILE return varchar2;
--
  procedure SUBMIT_MENU_COMPILE;
--
end FND_JOBS_PKG;

 

/
