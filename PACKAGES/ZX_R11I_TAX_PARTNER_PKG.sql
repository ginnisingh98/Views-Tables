--------------------------------------------------------
--  DDL for Package ZX_R11I_TAX_PARTNER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_R11I_TAX_PARTNER_PKG" AUTHID CURRENT_USER AS
/* $Header: zxir11ipartnerpkgs.pls 120.7.12010000.2 2010/03/23 06:00:55 tsen ship $ */



error_message_tbl ZX_API_PRVDR_PUB.ERROR_MESSAGES_TBL;

Function IS_CITY_LIMIT_VALID(p_organization_id IN NUMBER,
                             p_legal_entity_id IN NUMBER,
                             p_city_limit IN VARCHAR2) return BOOLEAN;

FUNCTION IS_GEOCODE_VALID(p_organization_id IN NUMBER,
                          p_legal_entity_id IN NUMBER,
                          p_geocode IN VARCHAR2) return BOOLEAN;

FUNCTION TAX_VENDOR_EXTENSION(p_organization_id IN NUMBER,
                              p_legal_entity_id IN NUMBER)return BOOLEAN;

/* Bug 5139634: Overloaded APIs created as OU/LE info may not be available at the time of address entry */

FUNCTION IS_CITY_LIMIT_VALID (p_city_limit IN VARCHAR2) return BOOLEAN;

FUNCTION IS_GEOCODE_VALID (p_geocode IN VARCHAR2) return BOOLEAN;

FUNCTION TAX_VENDOR_EXTENSION return BOOLEAN;

PROCEDURE COPY_PTNR_TAX_LINE_BEF_UPD
(p_tax_line_id       IN   ZX_LINES.tax_line_id%type,
 x_return_status     OUT  NOCOPY VARCHAR2) ;

PROCEDURE COPY_TRX_LINE_FOR_PTNR_BEF_UPD
(p_trx_line_dist_tbl       IN   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl%TYPE,
 p_event_class_rec         IN   ZX_API_PUB.event_class_rec_type,
 p_update_index            IN   NUMBER,
 p_trx_copy_for_tax_update IN   VARCHAR2,
 p_regime_code             IN   VARCHAR2,
 p_tax_provider_id         IN   VARCHAR2,
 x_return_status    OUT  NOCOPY VARCHAR2);

  PROCEDURE CREATE_SRVC_REGISTN_FROM_UI
 (p_api_version            IN   NUMBER,
  x_error_msg       OUT  NOCOPY VARCHAR2,
  x_return_status   OUT  NOCOPY VARCHAR2,
  p_srvc_prvdr_id           IN  NUMBER,
  p_regime_usage_id         IN  NUMBER,
  p_business_flow           IN  VARCHAR2);

  procedure CREATE_EXTN_REGISTN_FROM_UI
  (p_api_version            IN  NUMBER,
   x_error_msg		OUT NOCOPY  VARCHAR2,
   x_return_status	OUT NOCOPY VARCHAR2,
   p_srvc_prvdr_id	 IN  NUMBER,
   p_regime_usage_id	 IN  NUMBER,
   p_code_generator_flag IN  VARCHAR2);

  Procedure EXECUTE_EXTN_PLUGIN_FROM_UI
(  p_api_version	IN  NUMBER,
   x_error_msg		OUT NOCOPY  VARCHAR2,
   x_return_status	OUT NOCOPY VARCHAR2,
   p_api_owner_id	IN  number,
   p_context_cc_id	IN  number);

PROCEDURE FLUSH_TABLE_INFORMATION;

End zx_r11i_tax_partner_pkg;

/
