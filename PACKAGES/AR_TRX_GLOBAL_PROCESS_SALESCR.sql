--------------------------------------------------------
--  DDL for Package AR_TRX_GLOBAL_PROCESS_SALESCR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_TRX_GLOBAL_PROCESS_SALESCR" AUTHID CURRENT_USER AS
/* $Header: ARINGTSS.pls 120.2 2005/10/30 04:23:43 appldev noship $ */

PROCEDURE INSERT_ROW (
        p_trx_salescredits_tbl         IN      AR_INVOICE_API_PUB.trx_salescredits_tbl_type,
	x_errmsg                    OUT NOCOPY  VARCHAR2,
	x_return_status             OUT NOCOPY  VARCHAR2 );

END AR_TRX_GLOBAL_PROCESS_SALESCR;

 

/
