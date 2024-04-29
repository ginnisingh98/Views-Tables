--------------------------------------------------------
--  DDL for Package INV_LOG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_LOG_UTIL" AUTHID CURRENT_USER AS
/* $Header: INVLOGUS.pls 120.1 2006/09/26 20:46:33 rambrose noship $ */

/* BUG 5558315 - added to improve performance, by not checking profile values during pick release */
g_maintain_log_profile   BOOLEAN  := False;

PROCEDURE trace(p_message VARCHAR2,
		p_module  VARCHAR2,
		p_level   NUMBER := 9);

END inv_log_util;

 

/
