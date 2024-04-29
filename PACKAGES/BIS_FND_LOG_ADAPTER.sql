--------------------------------------------------------
--  DDL for Package BIS_FND_LOG_ADAPTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_FND_LOG_ADAPTER" AUTHID CURRENT_USER AS
/* $Header: BISMGPKS.pls 115.5 2003/09/26 18:25:38 ili noship $ */

 PROCEDURE  NEW_PROGRESS(p_logkey varchar2, p_progress varchar2);
 PROCEDURE  LOG(p_logkey varchar2, p_progress varchar2, p_message varchar2);
 PROCEDURE  ClOSE_PROGRESS(p_logkey varchar2, p_progress varchar2);

 LOG_KEY CONSTANT VARCHAR2(30) := 'BIS_LOG_KEY';
END BIS_FND_LOG_ADAPTER;

 

/
