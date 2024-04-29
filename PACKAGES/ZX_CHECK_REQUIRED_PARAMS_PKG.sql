--------------------------------------------------------
--  DDL for Package ZX_CHECK_REQUIRED_PARAMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_CHECK_REQUIRED_PARAMS_PKG" AUTHID CURRENT_USER AS
/* $Header: zxifreqparampkgs.pls 120.5 2005/04/21 21:02:31 vsidhart ship $ */

/*----------------------------------------------------------------------------*
 |   PRIVATE FUNCTIONS/PROCEDURES                                             |
 *----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*
 |   PUBLIC  FUNCTIONS/PROCEDURES                                             |
 *----------------------------------------------------------------------------*/

/* ===========================================================================*
 | PROCEDURE Check_trx_line_tbl : Checks the required elements of the         |
 |                                transaction line                            |
 | Called by:                                                                 |
 |     zx_valid_init_params_pkg.calculate_tax (GTT version)                   |
 |     zx_valid_init_params_pkg.import_document_with_tax                      |
 * ===========================================================================*/

  PROCEDURE Check_trx_line_tbl
  (
    x_return_status             OUT NOCOPY  VARCHAR2,
    p_event_class_rec           IN          ZX_API_PUB.event_class_rec_type
  );

/* ===========================================================================*
 | PROCEDURE Check_trx_lines : Checks the required elements of the            |
 |                             transaction line in structure                  |
 | Called by:                                                                 |
 |     zx_valid_init_params_pkg.calculate_tax (PLS/WIN version)               |
 |     zx_valid_init_params_pkg.insupd_line_det_factors                       |
 * ===========================================================================*/

  PROCEDURE Check_trx_lines
  (
    x_return_status             OUT NOCOPY  VARCHAR2,
    p_event_class_rec           IN          ZX_API_PUB.event_class_rec_type
  );


/* ===========================================================================*
 | PROCEDURE Check_trx_rec : Checks the required elements of the transaction  |
 |                           record                                           |
 | Called by:                                                                 |
 |     zx_valid_init_params_pkg.override_tax                                  |
 |     zx_valid_init_params_pkg.global_document_update                        |
 |     zx_valid_init_params_pkg.override_recovery                             |
 |     zx_valid_init_params_pkg.freeze_distribution_lines                     |
 |     zx_valid_init_params_pkg.validate_document_for_tax                     |
 |     zx_valid_init_params_pkg.discard_tax_only_lines                        |
 * ===========================================================================*/

  PROCEDURE Check_trx_rec
  (
    x_return_status  OUT NOCOPY  VARCHAR2,
    p_trx_rec        IN          ZX_API_PUB.transaction_rec_type
  );

/*==============================================================================*
 | PROCEDURE Check_trx_line_rec : Checks the required elements of the specified |
 |                                transaction line have values                  |
 | Called by:                                                                   |
 |     zx_valid_init_params_pkg.mark_tax_lines_deleted                          |
 * ============================================================================*/

  PROCEDURE Check_trx_line_rec
  (
    x_return_status 	OUT  NOCOPY  VARCHAR2 ,
    p_trx_line_rec      IN           zx_api_pub.transaction_line_rec_type
  );


/* ===========================================================================*
 | PROCEDURE Check_trx_headers_tbl : Checks the required elements of the      |
 |                                   Transaction Header                       |
 | Called by:                                                                 |
 |     zx_valid_init_params_pkg.calculate_tax (GTT version)                   |
 |     zx_valid_init_params_pkg.import_document_with_tax                      |
 |     zx_valid_init_params_pkg.determine_recovery                            |
 |     zx_valid_init_params_pkg.insupd_line_det_factors                       |
 * ===========================================================================*/

  PROCEDURE Check_trx_headers_tbl
  (
    x_return_status                OUT NOCOPY  VARCHAR2,
    p_event_class_rec           IN OUT NOCOPY  ZX_API_PUB.event_class_rec_type
  );


END zx_check_required_params_pkg;

 

/
