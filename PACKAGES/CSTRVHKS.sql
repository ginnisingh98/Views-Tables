--------------------------------------------------------
--  DDL for Package CSTRVHKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTRVHKS" AUTHID CURRENT_USER AS
/* $Header: CSTRVHKS.pls 115.3 2002/11/11 22:44:56 awwang ship $ */

FUNCTION disable_accrual (
	   ERR_NUM			OUT NOCOPY	NUMBER,
	   ERR_CODE			OUT NOCOPY	VARCHAR2,
	   ERR_MSG			OUT NOCOPY	VARCHAR2)
RETURN integer;

END CSTRVHKS;

 

/
