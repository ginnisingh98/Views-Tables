--------------------------------------------------------
--  DDL for Package ZX_TDS_APPLICABILITY_DETM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TDS_APPLICABILITY_DETM_PKG" AUTHID CURRENT_USER AS
/* $Header: zxditaxapplipkgs.pls 120.31 2006/01/28 06:20:57 hongliu ship $ */

/* TYPE classmap_rec_type is RECORD (
   tax_event_class_code zx_evnt_cls_mappings.tax_event_class_code%TYPE,
   normal_sign_flag     zx_evnt_cls_mappings.normal_sign_flag%TYPE
   total_tx_line_sum_template
                        zx_evnt_cls_mappings.total_tx_line_sum_template%TYPE,
   rec_tx_line_sum_template
                        zx_evnt_cls_mappings.rec_tx_line_sum_template%TYPE,
   nrec_tx_line_sum_template
                        zx_evnt_cls_mappings.nrec_tx_line_sum_template%TYPE,
   application_loop1_template
                        zx_evnt_cls_mappings.application_loop1_template%TYPE);
   g_classmap_rec classmap_rec_type; */

 TYPE country_tab_type is TABLE of zx_regimes_b.country_code%TYPE
                            INDEX BY BINARY_INTEGER;

PROCEDURE get_tax_date (
  p_trx_line_index	    IN     		BINARY_INTEGER,
  x_tax_date		    OUT NOCOPY   	DATE,
  x_tax_determine_date      OUT NOCOPY   	DATE,
  x_tax_point_date          OUT NOCOPY   	DATE,
  x_return_status           OUT NOCOPY   	VARCHAR2);

PROCEDURE get_applicable_regimes (
  p_trx_line_index     	    IN      		BINARY_INTEGER,
  p_event_class_rec	    IN     		zx_api_pub.event_class_rec_type,
  x_return_status           OUT NOCOPY 	  	VARCHAR2 );

PROCEDURE get_applicable_taxes (
  p_tax_regime_id           IN     	  	zx_regimes_b.tax_regime_id%type,
  p_tax_regime_code         IN     	  	zx_regimes_b.tax_regime_code%type,
  p_trx_line_index          IN     	  	BINARY_INTEGER,
--  p_sum_line_index        IN 	  	  	BINARY_INTEGER,
--  p_total_trx_amount	    IN 	  	  	NUMBER,
  p_event_class_rec         IN   	  	zx_api_pub.event_class_rec_type,
  p_tax_date		    IN   	  	DATE,
  p_tax_determine_date      IN   	  	DATE,
  p_tax_point_date          IN   	  	DATE,
  x_begin_index	            IN OUT NOCOPY 	BINARY_INTEGER,
  x_end_index	            IN OUT NOCOPY 	BINARY_INTEGER,
  x_return_status              OUT NOCOPY  	VARCHAR2);

PROCEDURE get_place_of_supply (
  p_event_class_rec             IN  	   zx_api_pub.event_class_rec_type,
  p_tax_regime_code             IN     	   zx_regimes_b.tax_regime_code%TYPE,
  p_tax_id                      IN         zx_taxes_b.tax_id%TYPE,
  p_tax            	        IN         zx_taxes_b.tax%TYPE,
  p_tax_determine_date          IN 	   DATE,
  p_def_place_of_supply_type_cd IN  	   zx_taxes_b.def_place_of_supply_type_code%TYPE,
  p_place_of_supply_rule_flag   IN   	   zx_taxes_b.place_of_supply_rule_flag%TYPE,
  p_applicability_rule_flag     IN   	   zx_taxes_b.applicability_rule_flag%TYPE,
  p_def_reg_type                IN   	   zx_taxes_b.def_registr_party_type_code%TYPE,
  p_reg_rule_flg                IN   	   zx_taxes_b.registration_type_rule_flag%TYPE,
  p_trx_line_index              IN   	   BINARY_INTEGER,
  p_direct_rate_result_id       IN         NUMBER,
  x_jurisdiction_rec           OUT NOCOPY  ZX_TCM_GEO_JUR_PKG.tax_jurisdiction_rec_type,
  x_jurisdictions_found        OUT NOCOPY  VARCHAR2,
  X_Place_Of_Supply_Type_Code   OUT NOCOPY zx_taxes_b.def_place_of_supply_type_code%TYPE,
  x_place_of_supply_result_id   OUT NOCOPY NUMBER,
  x_return_status               OUT NOCOPY VARCHAR2);

FUNCTION get_pos_parameter_name (
  p_pos_type      IN         zx_taxes_b.def_place_of_supply_type_code%type,
  x_return_status OUT NOCOPY VARCHAR2
) RETURN VARCHAR2;

PROCEDURE get_tax_registration_info(
            p_structure_name         IN     VARCHAR2,
            p_structure_index        IN     BINARY_INTEGER,
            p_event_class_rec        IN     zx_api_pub.event_class_rec_type,
            p_tax_regime_code        IN     zx_regimes_b.tax_regime_code%TYPE,
            p_tax                    IN     zx_taxes_b.tax%TYPE,
            p_tax_determine_date     IN     zx_lines.tax_determine_date%TYPE,
            p_jurisdiction_code      IN     zx_jurisdictions_b.tax_jurisdiction_code%TYPE,
            p_reg_party_type         IN     zx_taxes_b.def_registr_party_type_code%TYPE,
            x_registration_rec       OUT NOCOPY zx_tcm_control_pkg.zx_registration_info_rec,
            x_return_status          OUT NOCOPY VARCHAR2
);

PROCEDURE get_tax_registration (
  p_event_class_rec             IN             zx_api_pub.event_class_rec_type,
  p_tax_regime_code             IN             zx_regimes_b.tax_regime_code%TYPE,
  p_tax_id                      IN             zx_taxes_b.tax_id%TYPE,
  p_tax                         IN             zx_taxes_b.tax%TYPE,
  p_tax_determine_date          IN             DATE,
  p_jurisdiction_code           IN             zx_jurisdictions_b.tax_jurisdiction_code%TYPE,
  p_def_reg_type                IN             zx_taxes_b.def_registr_party_type_code%TYPE,
  p_reg_rule_flg                IN             zx_taxes_b.registration_type_rule_flag%TYPE,
  p_trx_line_index              IN             BINARY_INTEGER,
  x_registration_number         IN OUT NOCOPY  zx_registrations.registration_number%TYPE,
  x_tax_inclusion_flag          IN OUT NOCOPY  zx_registrations.inclusive_tax_flag%TYPE,
  x_self_assessment_flg         IN OUT NOCOPY  zx_registrations.self_assess_flag%TYPE,
  x_tax_registration_result_id     OUT NOCOPY  NUMBER,
  x_rounding_rule_code             OUT NOCOPY  zx_registrations.rounding_rule_code%TYPE,
  x_registration_party_type        OUT NOCOPY  zx_taxes_b.def_registr_party_type_code%TYPE,
  x_return_status                  OUT NOCOPY  VARCHAR2);

PROCEDURE get_legal_entity_registration (
  p_event_class_rec	       IN            zx_api_pub.event_class_rec_type,
  p_trx_line_index	       IN	     BINARY_INTEGER,
  p_tax_line_index             IN            BINARY_INTEGER,
  x_return_status                 OUT NOCOPY VARCHAR2,
  x_error_buffer                  OUT NOCOPY VARCHAR2);

PROCEDURE get_det_tax_lines_from_applied(
  p_event_class_rec	  IN 		 zx_api_pub.event_class_rec_type,
  p_trx_line_index	  IN	         BINARY_INTEGER,
  p_tax_date		  IN   	 	 DATE,
  p_tax_determine_date    IN   	 	 DATE,
  p_tax_point_date        IN   	 	 DATE,
  x_begin_index 	  IN OUT NOCOPY  BINARY_INTEGER,
  x_end_index		  IN OUT NOCOPY  BINARY_INTEGER,
  x_return_status	     OUT NOCOPY	 VARCHAR2);

PROCEDURE get_det_tax_lines_from_adjust (
  p_event_class_rec	  IN 		 zx_api_pub.event_class_rec_type,
  p_trx_line_index	  IN	         BINARY_INTEGER,
  p_tax_date		  IN   	 	 DATE,
  p_tax_determine_date    IN   	 	 DATE,
  p_tax_point_date        IN   	 	 DATE,
  x_begin_index		  IN OUT NOCOPY  BINARY_INTEGER,
  x_end_index		  IN OUT NOCOPY  BINARY_INTEGER,
  x_return_status  	     OUT NOCOPY	 VARCHAR2);

PROCEDURE get_tax_from_account(
 p_event_class_rec       IN             zx_api_pub.event_class_rec_type,
 p_trx_line_index        IN             BINARY_INTEGER,
 p_tax_date              IN             DATE,
 p_tax_determine_date    IN             DATE,
 p_tax_point_date        IN             DATE,
 x_begin_index           IN OUT NOCOPY  BINARY_INTEGER,
 x_end_index             IN OUT NOCOPY  BINARY_INTEGER,
 x_return_status         OUT NOCOPY     VARCHAR2);

PROCEDURE fetch_tax_lines (
  p_event_class_rec      IN             zx_api_pub.event_class_rec_type,
  p_trx_line_index       IN             NUMBER,
  p_tax_date             IN             DATE,
  p_tax_determine_date   IN             DATE,
  p_tax_point_date       IN             DATE,
  x_begin_index          IN OUT NOCOPY  NUMBER,
  x_end_index            IN OUT NOCOPY  NUMBER,
  x_return_status           OUT NOCOPY  VARCHAR2);

PROCEDURE get_taxes_for_intercomp_trx (
  p_event_class_rec      IN             zx_api_pub.event_class_rec_type,
  p_trx_line_index       IN             NUMBER,
  p_tax_date             IN             DATE,
  p_tax_determine_date   IN             DATE,
  p_tax_point_date       IN             DATE,
  x_begin_index          IN OUT NOCOPY  NUMBER,
  x_end_index            IN OUT NOCOPY  NUMBER,
  x_return_status           OUT NOCOPY  VARCHAR2);

/* Begin: Added for Bug4959835 */
PROCEDURE get_process_results(
  p_trx_line_index        IN          BINARY_INTEGER,
  p_tax_date			  IN 		  DATE,
  p_tax_determine_date    IN		  DATE,
  p_tax_point_date		  IN 		  DATE,
  p_event_class_rec       IN          zx_api_pub.event_class_rec_type,
  x_begin_index           IN OUT NOCOPY BINARY_INTEGER,
  x_end_index             IN OUT NOCOPY BINARY_INTEGER,
  x_return_status            OUT NOCOPY  VARCHAR2);

TYPE tax_regime_code_tbl IS TABLE OF
    ZX_SCO_RULES.tax_regime_code%TYPE
INDEX BY BINARY_INTEGER;

TYPE tax_tbl IS TABLE OF
    ZX_SCO_RULES.tax%TYPE
INDEX BY BINARY_INTEGER;

TYPE status_result_tbl IS TABLE OF
    ZX_PROCESS_RESULTS.status_result%TYPE
INDEX BY BINARY_INTEGER;

TYPE rate_result_tbl IS TABLE OF
    ZX_PROCESS_RESULTS.rate_result%TYPE
INDEX BY BINARY_INTEGER;

TYPE condition_set_tbl IS TABLE OF
    ZX_PROCESS_RESULTS.condition_set_id%TYPE
INDEX BY BINARY_INTEGER;

TYPE exception_set_tbl IS TABLE OF
    ZX_PROCESS_RESULTS.exception_set_id%TYPE
INDEX BY BINARY_INTEGER;

TYPE result_id_tbl IS TABLE OF
   ZX_PROCESS_RESULTS.result_id%TYPE
INDEX BY BINARY_INTEGER;


c_lines_per_commit CONSTANT NUMBER := ZX_TDS_CALC_SERVICES_PUB_PKG.G_LINES_PER_COMMIT;

/* End: Added for Bug4959835 */

END ZX_TDS_APPLICABILITY_DETM_PKG;

 

/
