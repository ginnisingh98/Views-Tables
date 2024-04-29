--------------------------------------------------------
--  DDL for Package AR_TRX_GLOBAL_PROCESS_LINES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_TRX_GLOBAL_PROCESS_LINES" AUTHID CURRENT_USER AS
/* $Header: ARINGTLS.pls 115.2 2003/08/08 15:46:31 bsarkar noship $ */
PROCEDURE INSERT_ROW (
        p_trx_lines_tbl         IN      AR_INVOICE_API_PUB.trx_line_tbl_type,
	x_errmsg                    OUT NOCOPY  VARCHAR2,
	x_return_status             OUT NOCOPY  VARCHAR2 );

END AR_TRX_GLOBAL_PROCESS_LINES;

 

/
