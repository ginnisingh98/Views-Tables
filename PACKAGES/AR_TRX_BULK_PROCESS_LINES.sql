--------------------------------------------------------
--  DDL for Package AR_TRX_BULK_PROCESS_LINES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_TRX_BULK_PROCESS_LINES" AUTHID CURRENT_USER AS
/* $Header: ARINBLLS.pls 115.2 2003/07/28 03:50:33 bsarkar noship $ */
PROCEDURE INSERT_ROW(
    p_trx_header_id         IN      NUMBER DEFAULT NULL,
    p_trx_line_id           IN      NUMBER  DEFAULT NULL,
    x_errmsg                    OUT NOCOPY  VARCHAR2,
    x_return_status             OUT NOCOPY  VARCHAR2);

END AR_TRX_BULK_PROCESS_LINES;

 

/
