--------------------------------------------------------
--  DDL for Package AR_TRX_GLOBAL_PROCESS_DIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_TRX_GLOBAL_PROCESS_DIST" AUTHID CURRENT_USER AS
/* $Header: ARINGTDS.pls 120.2 2005/10/30 04:23:40 appldev noship $ */

PROCEDURE INSERT_ROW (
        p_trx_dist_tbl         IN      AR_INVOICE_API_PUB.trx_dist_tbl_type,
	x_errmsg                    OUT NOCOPY  VARCHAR2,
	x_return_status             OUT NOCOPY  VARCHAR2 );

END AR_TRX_GLOBAL_PROCESS_DIST;

 

/
