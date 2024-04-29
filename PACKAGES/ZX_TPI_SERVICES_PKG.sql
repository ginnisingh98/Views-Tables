--------------------------------------------------------
--  DDL for Package ZX_TPI_SERVICES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TPI_SERVICES_PKG" AUTHID CURRENT_USER AS
/* $Header: zxiftpisrvcpkgs.pls 120.13.12010000.2 2009/04/01 13:07:24 tsen ship $ */
/* ======================================================================*
 | Global Data Types                                                     |
 * ======================================================================*/

/* Bug 5515283: To determine if provider is applicable (get_service_subscriber procedure) for a given regime,
  we are currently looping over the detail tax lines since it returns the regimes applicable
  for a transaction line. In order to avoid unwanted multiple calls to the procedure for same regime
  we are storing hit regimes in a temporary structure*/
TYPE tax_regime_prvdr_rec_type is record(
     srvc_provider_id   zx_srvc_subscriptions.SRVC_PROVIDER_ID%type,
     application_id     zx_lines.application_id%type,
     entity_code        zx_lines.entity_code%type,
     event_class_code   zx_lines.event_class_code%type,
     first_pty_org_id   zx_party_tax_profile.party_tax_profile_id%type,
     tax_regime_code    zx_regimes_b.tax_regime_code%type
);
TYPE tax_regime_tmp_tbl_type is table of tax_regime_prvdr_rec_type index by BINARY_INTEGER;
tax_regime_tmp_tbl       tax_regime_tmp_tbl_type;


/* ==============================================*
 |           Procedure definition                |
 * ==============================================*/

PROCEDURE popl_pvrdr_info_tax_reg_tbl (
 p_event_class_rec    IN  ZX_API_PUB.event_class_rec_type,
 p_trx_line_index     IN  BINARY_INTEGER,
 x_return_status      OUT NOCOPY VARCHAR2
 ) ;

PROCEDURE derive_ext_attrs (
  p_event_class_rec   IN  ZX_API_PUB.event_class_rec_type,
  p_tax_regime_code   IN  VARCHAR2,
  p_provider_id       IN  NUMBER,
  p_service_type_code IN  VARCHAR2,
  x_return_status     OUT NOCOPY  VARCHAR2
  );

PROCEDURE partner_pre_processing(
  p_tax_regime_id         IN  NUMBER,
  p_tax_regime_code       IN  VARCHAR2,
  p_tax_provider_id       IN  NUMBER,
  p_ptnr_processing_flag  IN  VARCHAR2,
  p_event_class_rec       IN  ZX_API_PUB.event_class_rec_type,
  x_return_status         OUT NOCOPY VARCHAR2
  );


PROCEDURE call_partner_service(
  p_tax_regime_code       IN  VARCHAR2,
  p_tax_provider_id       IN  NUMBER,
  p_service_type_code     IN  VARCHAR2,
  p_event_class_rec       IN ZX_API_PUB.event_class_rec_type,
  x_return_status         OUT NOCOPY VARCHAR2
  );

PROCEDURE ptnr_post_processing_calc_tax(
  p_tax_regime_code       IN VARCHAR2,
  p_tax_provider_id       IN NUMBER,
  p_event_class_rec       IN ZX_API_PUB.event_class_rec_type,
  x_return_status         OUT NOCOPY VARCHAR2
  );

PROCEDURE ptnr_post_proc_sync_tax(
  p_tax_regime_code       IN VARCHAR2,
  p_tax_provider_id       IN NUMBER,
  p_event_class_rec       IN ZX_API_PUB.event_class_rec_type,
  x_return_status         OUT NOCOPY VARCHAR2
  );

/* Table handler routines to insert/update/delete on zx_trx_line_app_Regimes*/
PROCEDURE trx_line_app_regimes_tbl_hdl(
 p_event_class_rec        IN  ZX_API_PUB.event_class_rec_type,
 p_event                  IN  VARCHAR2,
 p_tax_regime_code        IN  VARCHAR2,
 p_provider_id            IN  NUMBER,
 p_trx_line_id            IN  NUMBER,
 p_trx_level_type         IN  VARCHAR2,
 x_return_status          OUT NOCOPY VARCHAR2
 );


PROCEDURE get_service_provider (
 p_application_id     IN         NUMBER,
 p_entity_code        IN         VARCHAR2,
 p_event_class_code   IN         VARCHAR2,
 p_tax_regime_code    IN         VARCHAR2,
 x_provider_id        OUT NOCOPY NUMBER,
 x_return_status      OUT NOCOPY VARCHAR2
);

/*Overloaded version of above*/
PROCEDURE get_service_provider(
 p_tax_regime_code    IN         VARCHAR2,
 x_provider_id        OUT NOCOPY NUMBER,
 x_return_status      OUT NOCOPY VARCHAR2
  );

FUNCTION get_incl_tax_amt (
p_application_id   IN NUMBER,
p_entity_code      IN VARCHAR2,
p_event_class_code IN VARCHAR2,
p_trx_id           IN NUMBER,
p_trx_line_id      IN NUMBER,
p_trx_level_type   IN VARCHAR2,
p_tax_provider_id  IN NUMBER
)RETURN NUMBER;

END ZX_TPI_SERVICES_PKG;

/
