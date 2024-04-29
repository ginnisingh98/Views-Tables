--------------------------------------------------------
--  DDL for Package AR_TRX_BULK_PROCESS_HEADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_TRX_BULK_PROCESS_HEADER" AUTHID CURRENT_USER AS
/* $Header: ARINBLHS.pls 115.1 2003/07/28 03:49:55 bsarkar noship $ */

PROCEDURE INSERT_ROW (
        p_trx_header_id         IN      NUMBER DEFAULT NULL,
	x_errmsg                    OUT NOCOPY  VARCHAR2,
	x_return_status             OUT NOCOPY  VARCHAR2) ;


END AR_TRX_BULK_PROCESS_HEADER;

 

/
