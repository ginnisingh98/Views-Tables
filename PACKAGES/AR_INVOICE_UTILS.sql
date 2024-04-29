--------------------------------------------------------
--  DDL for Package AR_INVOICE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_INVOICE_UTILS" AUTHID CURRENT_USER AS
/* $Header: ARXVINUS.pls 115.5 2004/02/12 23:24:39 bsarkar noship $ */

PROCEDURE validate_header (
  p_trx_system_param_rec AR_INVOICE_DEFAULT_PVT.trx_system_parameters_rec_type,
  p_trx_profile_rec      AR_INVOICE_DEFAULT_PVT.trx_profile_rec_type,
  x_errmsg               OUT NOCOPY  VARCHAR2,
  x_return_status        OUT NOCOPY  VARCHAR2 );

PROCEDURE validate_lines (
	x_errmsg                    OUT NOCOPY  VARCHAR2,
	x_return_status             OUT NOCOPY  VARCHAR2);

PROCEDURE validate_salescredits (
  p_trx_system_param_rec ar_invoice_default_pvt.trx_system_parameters_rec_type,
  x_errmsg               OUT NOCOPY  VARCHAR2,
  x_return_status        OUT NOCOPY  VARCHAR2 );

PROCEDURE validate_distributions (
  p_trx_system_parameters_rec
                  AR_INVOICE_DEFAULT_PVT.trx_system_parameters_rec_type,
  x_errmsg        OUT NOCOPY  VARCHAR2,
  x_return_status OUT NOCOPY  VARCHAR2);

PROCEDURE debug (
    p_message                   IN      VARCHAR2,
    p_log_level                 IN      NUMBER default FND_LOG.LEVEL_STATEMENT,
    p_module_name               IN      VARCHAR2 default 'ar.plsql.InvoiceAPI')
;

PROCEDURE validate_dependent_parameters (
  p_trx_system_param_rec ar_invoice_default_pvt.trx_system_parameters_rec_type,
  x_errmsg          OUT NOCOPY  VARCHAR2,
  x_return_status   OUT NOCOPY  VARCHAR2 );

PROCEDURE validate_master_detail (
  x_errmsg                    OUT NOCOPY  VARCHAR2,
  x_return_status             OUT NOCOPY  VARCHAR2);


PROCEDURE validate_gdf(
      p_request_id           NUMBER,
      x_errmsg               OUT NOCOPY VARCHAR2,
      x_return_status        OUT NOCOPY VARCHAR2);

END;

 

/
