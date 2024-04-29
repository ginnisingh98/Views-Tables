--------------------------------------------------------
--  DDL for Package AR_TRX_GLOBAL_PROCESS_HEADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_TRX_GLOBAL_PROCESS_HEADER" AUTHID CURRENT_USER AS
/* $Header: ARINGTHS.pls 115.2 2003/08/08 15:43:51 bsarkar noship $ */

PROCEDURE INSERT_ROW (
    p_trx_header_tbl            IN      AR_INVOICE_API_PUB.trx_header_tbl_type,
    p_batch_source_rec          IN      AR_INVOICE_API_PUB.batch_source_rec_type default null,
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2);
END AR_TRX_GLOBAL_PROCESS_HEADER;

 

/
