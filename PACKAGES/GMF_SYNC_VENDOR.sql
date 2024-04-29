--------------------------------------------------------
--  DDL for Package GMF_SYNC_VENDOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_SYNC_VENDOR" AUTHID CURRENT_USER as
/* $Header: gmfvnsys.pls 115.3 2002/12/04 17:04:39 umoogala ship $ */
	procedure gmf_sync_vendor(error_buf out nocopy varchar2,
				  retcode   out nocopy number,
				  p_co_code in varchar2);
	--Mohit Bug#1677297 Added two new procedures.
	PROCEDURE PRINT_LINE(
	line_text		IN	VARCHAR2);

   PROCEDURE PRINT(
	line_text		IN	VARCHAR2);
end gmf_sync_vendor;

 

/
