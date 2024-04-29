--------------------------------------------------------
--  DDL for Package CSTACPCS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTACPCS" AUTHID CURRENT_USER AS
/* $Header: CSTACPCS.pls 115.3 2002/11/08 01:17:15 awwang ship $ */

PROCEDURE summarize_value(
 i_org_id		IN		NUMBER,
 i_acct_period_id	IN		NUMBER,
 i_last_period_id	IN		NUMBER,
 i_user_id		IN		NUMBER,
 i_prog_id		IN		NUMBER,
 i_prog_appl_id		IN		NUMBER,
 err_num		OUT NOCOPY		NUMBER,
 err_code		OUT NOCOPY		VARCHAR2,
 err_msg		OUT NOCOPY		VARCHAR2);

END CSTACPCS;

 

/
