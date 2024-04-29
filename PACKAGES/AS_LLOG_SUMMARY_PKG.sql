--------------------------------------------------------
--  DDL for Package AS_LLOG_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_LLOG_SUMMARY_PKG" AUTHID CURRENT_USER AS
/* $Header: asxopsls.pls 115.3 2002/12/18 19:21:18 xding ship $ */

-- Constants
   G_PKG_NAME               Constant VARCHAR2(30):='AS_LLOG_SUMMARY_PKG';
   G_FILE_NAME              Constant VARCHAR2(12):='asxopsls.pls';

   -- The following two variables are used to indicate debug message is
   -- written to message stack(G_DEBUG_TRIGGER) or to log/output file
   -- (G_DEBUG_CONCURRENT).
   G_DEBUG_CONCURRENT       CONSTANT NUMBER := 1;
   G_DEBUG_TRIGGER          CONSTANT NUMBER := 2;

 -- Global variables
   G_Debug                  Boolean := True;

Procedure Refresh_Status_Summary(
    ERRBUF       OUT Varchar2,
    RETCODE      OUT Varchar2,
    p_debug_mode IN  Varchar2,
    p_trace_mode IN  Varchar2);




END AS_LLOG_SUMMARY_PKG;

 

/
