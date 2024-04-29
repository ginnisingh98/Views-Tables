--------------------------------------------------------
--  DDL for Package AR_TRX_BULK_PROCESS_SALESCR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_TRX_BULK_PROCESS_SALESCR" AUTHID CURRENT_USER AS
/* $Header: ARINBLSS.pls 120.2 2005/10/30 04:23:39 appldev noship $ */


PROCEDURE INSERT_ROW (
        p_trx_salescredit_id         IN      NUMBER ,
	x_errmsg                    OUT NOCOPY  VARCHAR2,
	x_return_status             OUT NOCOPY  VARCHAR2);


END AR_TRX_BULK_PROCESS_SALESCR;

 

/
