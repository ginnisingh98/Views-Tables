--------------------------------------------------------
--  DDL for Package AR_TRX_GLOBAL_PROCESS_TMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_TRX_GLOBAL_PROCESS_TMP" AUTHID CURRENT_USER AS
/* $Header: ARINGTTS.pls 120.1 2005/08/01 12:03:16 mantani noship $ */


PROCEDURE INSERT_ROWS (
    p_trx_header_tbl        IN   AR_INVOICE_API_PUB.trx_header_tbl_type,
    p_trx_lines_tbl         IN   AR_INVOICE_API_PUB.trx_line_tbl_type,
    p_trx_dist_tbl          IN   AR_INVOICE_API_PUB.trx_dist_tbl_type,
    p_trx_salescredits_tbl  IN   AR_INVOICE_API_PUB.trx_salescredits_tbl_type,
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2);


PROCEDURE GET_ROWS (
    p_org_id                IN   NUMBER DEFAULT NULL,
    p_trx_header_tbl        OUT NOCOPY   AR_INVOICE_API_PUB.trx_header_tbl_type,
    p_trx_lines_tbl         OUT NOCOPY   AR_INVOICE_API_PUB.trx_line_tbl_type,
    p_trx_dist_tbl          OUT NOCOPY   AR_INVOICE_API_PUB.trx_dist_tbl_type,
    p_trx_salescredits_tbl  OUT NOCOPY   AR_INVOICE_API_PUB.trx_salescredits_tbl_type,
    x_errmsg                OUT NOCOPY  VARCHAR2,
    x_return_status         OUT NOCOPY  VARCHAR2
    );


END AR_TRX_GLOBAL_PROCESS_TMP;

 

/
