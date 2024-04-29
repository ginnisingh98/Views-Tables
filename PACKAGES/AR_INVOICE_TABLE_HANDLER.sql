--------------------------------------------------------
--  DDL for Package AR_INVOICE_TABLE_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_INVOICE_TABLE_HANDLER" AUTHID CURRENT_USER AS
/* $Header: ARXVINTS.pls 120.5.12000000.2 2007/06/15 21:20:27 mraymond ship $ */

g_batch_id      NUMBER;
g_request_id    NUMBER;

PROCEDURE INSERT_ROW(
        p_trx_system_parameters_rec     IN      AR_INVOICE_DEFAULT_PVT.trx_system_parameters_rec_type,
        p_trx_profile_rec               IN      AR_INVOICE_DEFAULT_PVT.trx_profile_rec_type,
        p_batch_source_rec              IN      AR_INVOICE_API_PUB.batch_source_rec_type DEFAULT NULL,
	x_errmsg                    OUT NOCOPY  VARCHAR2,
	x_return_status             OUT NOCOPY  VARCHAR2) ;

PROCEDURE create_batch(
    p_trx_system_parameters_rec     IN      AR_INVOICE_DEFAULT_PVT.trx_system_parameters_rec_type,
    p_trx_profile_rec               IN      AR_INVOICE_DEFAULT_PVT.trx_profile_rec_type,
    p_batch_source_rec              IN      AR_INVOICE_API_PUB.batch_source_rec_type DEFAULT NULL,
    p_batch_id                      OUT NOCOPY NUMBER,
    x_errmsg                        OUT NOCOPY  VARCHAR2,
    x_return_status                 OUT NOCOPY  VARCHAR2 );

END AR_INVOICE_TABLE_HANDLER;

 

/
