--------------------------------------------------------
--  DDL for Package ZX_VALID_INIT_PARAMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_VALID_INIT_PARAMS_PKG" AUTHID CURRENT_USER AS
/* $Header: zxifvaldinitpkgs.pls 120.21 2006/09/22 00:50:19 nipatel ship $ */

Type Source_rec_Type is record
(
 SHIP_TO_PARTY_TYPE                     VARCHAR2(30),
 SHIP_FROM_PARTY_TYPE                   VARCHAR2(30),
 POA_PARTY_TYPE                         VARCHAR2(30),
 POO_PARTY_TYPE                         VARCHAR2(30),
 PAYING_PARTY_TYPE                      VARCHAR2(30),
 OWN_HQ_PARTY_TYPE                      VARCHAR2(30),
 TRAD_HQ_PARTY_TYPE                     VARCHAR2(30),
 POI_PARTY_TYPE                         VARCHAR2(30),
 POD_PARTY_TYPE                         VARCHAR2(30),
 BILL_TO_PARTY_TYPE                     VARCHAR2(30),
 BILL_FROM_PARTY_TYPE                   VARCHAR2(30),
 TTL_TRNS_PARTY_TYPE                    VARCHAR2(30),
 MERCHANT_PARTY_TYPE                    VARCHAR2(30),
 SHIP_TO_PTY_SITE_TYPE                  VARCHAR2(30),
 SHIP_FROM_PTY_SITE_TYPE                VARCHAR2(30),
 POA_PTY_SITE_TYPE                      VARCHAR2(30),
 POO_PTY_SITE_TYPE                      VARCHAR2(30),
 PAYING_PTY_SITE_TYPE                   VARCHAR2(30),
 OWN_HQ_PTY_SITE_TYPE                   VARCHAR2(30),
 TRAD_HQ_PTY_SITE_TYPE                  VARCHAR2(30),
 POI_PTY_SITE_TYPE                      VARCHAR2(30),
 POD_PTY_SITE_TYPE                      VARCHAR2(30),
 BILL_TO_PTY_SITE_TYPE                  VARCHAR2(30),
 BILL_FROM_PTY_SITE_TYPE                VARCHAR2(30),
 TTL_TRNS_PTY_SITE_TYPE                 VARCHAR2(30));

 Source_rec Source_Rec_Type;

/*----------------------------------------------------------------------------*
 |   PRIVATE FUNCTIONS/PROCEDURES                                             |
 *----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*
 |   PUBLIC  FUNCTIONS/PROCEDURES                                             |
 *----------------------------------------------------------------------------*/
/* ======================================================================*
 | FUNCTION is_doc_to_be_recorded: Determine if record should be recorded|
 * ======================================================================*/

 Function is_doc_to_be_recorded
 (p_application_id    IN NUMBER,
  p_entity_code       IN VARCHAR2,
  p_event_class_code  IN VARCHAR2,
  p_quote_flag        IN VARCHAR2,
  x_return_status     OUT NOCOPY VARCHAR2)
 Return VARCHAR2;
/* ========================================================================*
 | PROCEDURE Calculate_Tax : Validates and initializes parameters for      |
 |                           calculate_tax published service               |
 * =======================================================================*/

  PROCEDURE calculate_tax
  (
    x_return_status    OUT    NOCOPY  VARCHAR2,
    p_event_class_rec  IN OUT NOCOPY  zx_api_pub.event_class_rec_type
   );


/* ==========================================================================*
 | PROCEDURE Import_Document_With_Tax : Validates and initializes parameters |
 |                           for import_document_with_tax published service  |
 * ==========================================================================*/

  PROCEDURE import_document_with_tax
  (
    x_return_status       OUT  	 NOCOPY  VARCHAR2,
    p_event_class_rec     IN OUT NOCOPY  zx_api_pub.event_class_rec_type
  );


/* ======================================================================*
 | PROCEDURE Override_Tax  : Validates and initializes parameters for    |
 |                           override_tax  published service             |
 * ======================================================================*/

  PROCEDURE override_tax
  (
    x_return_status       OUT    NOCOPY  VARCHAR2,
    p_override            IN             VARCHAR2,
    p_event_class_rec     IN OUT NOCOPY  zx_api_pub.event_class_rec_type,
    p_trx_rec          IN                zx_api_pub.transaction_rec_type
  );



/* ========================================================================*
 | PROCEDURE Global_Document_Update : Validates and initializes parameters |
 |                           for global_document_update published service  |
 * ========================================================================*/

  PROCEDURE global_document_update
  (
    x_return_status    OUT NOCOPY     VARCHAR2,
    p_event_class_rec  OUT NOCOPY     zx_api_pub.event_class_rec_type,
    p_trx_rec          IN             zx_api_pub.transaction_rec_type
  );


/* ======================================================================*
 |PROCEDURE mark_tax_lines_deleted :   Validates input parameters of the |
 |                                    mark_tax_lines_deleted published   |
 |                                    service                            |
 * ======================================================================*/

  PROCEDURE mark_tax_lines_deleted
  (
    x_return_status         OUT NOCOPY VARCHAR2,
    p_transaction_line_rec  IN zx_api_pub.transaction_line_rec_type
  );


/* ======================================================================*
 | PROCEDURE Reverse_Document : Validates and initializes parameters for |
 |                              reverse_document published service       |
 * ======================================================================*/

  PROCEDURE reverse_document
  (
    x_return_status         OUT NOCOPY  VARCHAR2 ,
    p_event_class_rec       OUT NOCOPY  zx_api_pub.event_class_rec_type
  );

/* ======================================================================*
 | PROCEDURE Reverse_distributions : Validates and initializes parameters|
 |                                   for reverse_distributions           |
 |                                   published service                   |
 * ======================================================================*/

  PROCEDURE reverse_distributions
  (
    x_return_status         OUT     NOCOPY  VARCHAR2
  );


/* ======================================================================*
 | PROCEDURE Determine_Recovery :  Validates input parameters of the     |
 |                                 Determine_recovery published service  |
 * ======================================================================*/

  PROCEDURE determine_recovery
  (
    x_return_status    OUT NOCOPY VARCHAR2,
    p_event_class_rec  IN OUT NOCOPY zx_api_pub.event_class_rec_type
  );



/* ======================================================================*
 | PROCEDURE Override_Recovery :  Validates input parameters of the      |
 |                                 Override_Recovery published service   |
 * ======================================================================*/

  PROCEDURE override_recovery
  (
    x_return_status    OUT NOCOPY VARCHAR2,
    p_event_class_rec  IN OUT NOCOPY zx_api_pub.event_class_rec_type,
    p_trx_rec          IN OUT   NOCOPY zx_api_pub.transaction_rec_type
  );


/* ======================================================================*
 |PROCEDURE Freeze_distribution_lines :Validates input parameters of the |
 |                                    Freeze_distribution_lines published|
 |                                    service                            |
 * ======================================================================*/

  PROCEDURE freeze_distribution_lines
  (
    x_return_status   OUT    NOCOPY VARCHAR2,
    p_event_class_rec OUT    NOCOPY zx_api_pub.event_class_rec_type,
    p_trx_rec         IN OUT NOCOPY zx_api_pub.transaction_rec_type
  );


/* ==========================================================================*
 | PROCEDURE Validate_document_for_tax :Validates input parameters for       |
 |                            validate_document_for_tax published service    |
 *===========================================================================*/
  PROCEDURE Validate_document_for_Tax
  (
    x_return_status      OUT     NOCOPY  VARCHAR2,
    p_event_class_rec    OUT    NOCOPY zx_api_pub.event_class_rec_type,
    p_trx_rec            IN OUT  NOCOPY zx_api_pub.transaction_rec_type
  );


/* ======================================================================*
 |PROCEDURE Discard_tax_only_lines :                                     |
 |                                                                       |
 * ======================================================================*/

  PROCEDURE Discard_tax_only_lines
  (
     x_return_status    OUT NOCOPY VARCHAR2,
     p_trx_rec  IN zx_api_pub.transaction_rec_type
  );

/* =============================================================================*
 | PROCEDURE Insupd_line_det_factors : Validates and initializes parameters for |
 |                                     insert_line_det_factors/                 |
 |                                     update_line_det_factors published service|
 * ============================================================================*/

  PROCEDURE insupd_line_det_factors
  ( x_return_status    OUT    NOCOPY VARCHAR2,
    p_event_class_rec  IN OUT NOCOPY ZX_API_PUB.event_class_rec_type,
    p_trx_line_index   IN     NUMBER
  );


/* =============================================================================*
 | PROCEDURE get_default_tax_det_attrs : Initializes parameters for get_default_|
 |                                       tax_det_attrs published service        |
 * ============================================================================*/
  PROCEDURE get_default_tax_det_attrs
  (
    x_return_status    OUT    NOCOPY VARCHAR2,
    p_event_class_rec  IN OUT NOCOPY ZX_API_PUB.event_class_rec_type
  );


PROCEDURE determine_effective_date
  ( p_event_class_rec IN         ZX_API_PUB.event_class_rec_type,
    x_effective_date  OUT NOCOPY DATE,
    x_return_status   OUT NOCOPY VARCHAR2
  );

  PROCEDURE get_tax_subscriber
  ( p_event_class_rec      IN OUT NOCOPY      ZX_API_PUB.event_class_rec_type,
    p_effective_date       IN                 DATE,
    x_return_status        OUT    NOCOPY      VARCHAR2
  );

  PROCEDURE get_tax_subscriber
  ( p_event_class_rec  IN OUT NOCOPY ZX_API_PUB.event_class_rec_type,
    x_return_status    OUT    NOCOPY VARCHAR2
  );

  PROCEDURE Get_Tax_Event_Type
  ( x_return_status    OUT NOCOPY VARCHAR2,
    p_evnt_cls_code    IN         VARCHAR2,
    p_appln_id         IN         NUMBER,
    p_entity_code      IN         VARCHAR2,
    p_evnt_typ_code    IN         VARCHAR2,
    p_tx_evnt_cls_code IN         VARCHAR2,
    x_tx_evnt_typ_code OUT NOCOPY VARCHAR2,
    x_doc_status       OUT NOCOPY VARCHAR2
  );

  PROCEDURE populate_event_class_options
  ( x_return_status   OUT NOCOPY    VARCHAR2,
    p_trx_date        IN            DATE,
    p_event_class_rec IN OUT NOCOPY ZX_API_PUB.event_class_rec_type
  );

  PROCEDURE get_loc_id_and_ptp_ids(
   p_event_class_rec  IN OUT NOCOPY ZX_API_PUB.event_class_rec_type,
   p_trx_line_index   IN NUMBER,
   x_return_status    OUT    NOCOPY VARCHAR2
  );

END zx_valid_init_params_pkg;

 

/
