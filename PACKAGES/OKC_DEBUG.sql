--------------------------------------------------------
--  DDL for Package OKC_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_DEBUG" AUTHID CURRENT_USER AS
/* $Header: OKCDBUGS.pls 120.0 2005/05/25 19:30:36 appldev noship $ */

  g_session_id  Varchar2(255):= OKC_API.G_MISS_CHAR;
  g_profile_log_level Number := 0;
  g_set_trace_off boolean := FALSE;

  Procedure Set_Indentation(p_proc_name Varchar2);
  Procedure Reset_Indentation;
  Procedure set_connection_context;
  Procedure Log(p_msg      IN VARCHAR2,
                p_level    IN NUMBER   DEFAULT 1,
                p_module   IN VARCHAR2 DEFAULT 'OKC');
  Procedure Set_trace_off;
  Procedure Set_trace_on;
END OKC_DEBUG;

 

/
