--------------------------------------------------------
--  DDL for Package ZX_TRD_INTERNAL_SERVICES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TRD_INTERNAL_SERVICES_PVT" AUTHID CURRENT_USER AS
 /* $Header: zxmirecdmsrvpvts.pls 120.10.12010000.2 2008/11/12 12:34:40 spasala ship $ */

-- Tax Recovery Cache
--
TYPE zx_tax_recovery_info_cache_rec IS RECORD(
  tax_regime_code                 zx_taxes_b.tax_regime_code%TYPE,
  tax                             zx_taxes_b.tax%TYPE,
  tax_id                          zx_taxes_b.tax_id%TYPE,
  allow_recoverability_flag       zx_taxes_b.allow_recoverability_flag%TYPE,
  primary_recovery_type_code      zx_taxes_b.primary_recovery_type_code%TYPE,
  primary_rec_type_rule_flag      zx_taxes_b.primary_rec_type_rule_flag%TYPE,
  secondary_recovery_type_code    zx_taxes_b.secondary_recovery_type_code%TYPE,
  secondary_rec_type_rule_flag    zx_taxes_b.secondary_rec_type_rule_flag%TYPE,
  primary_rec_rate_det_rule_flag  zx_taxes_b.primary_rec_rate_det_rule_flag%TYPE,
  sec_rec_rate_det_rule_flag      zx_taxes_b.sec_rec_rate_det_rule_flag%TYPE,
  def_primary_rec_rate_code       zx_taxes_b.def_primary_rec_rate_code%TYPE,
  def_secondary_rec_rate_code     zx_taxes_b.def_secondary_rec_rate_code%TYPE,
  effective_from                  zx_taxes_b.effective_from%TYPE,
  effective_to                    zx_taxes_b.effective_to%TYPE,
  def_rec_settlement_option_code  zx_taxes_b.def_rec_settlement_option_code%TYPE,
  tax_account_source_tax          zx_taxes_b.tax_account_source_tax%TYPE);

TYPE zx_tax_recovery_info_cache IS TABLE OF zx_tax_recovery_info_cache_rec
  INDEX by BINARY_INTEGER;

g_tax_recovery_info_tbl           zx_tax_recovery_info_cache;

PROCEDURE CALC_TAX_DIST(
 p_detail_tax_line_tbl        IN      ZX_TRD_SERVICES_PUB_PKG.TAX_LINE_TBL_TYPE,
 p_tax_line_index             IN      NUMBER,
 p_trx_line_dist_index        IN      NUMBER,
 p_rec_nrec_dist_tbl          IN OUT NOCOPY ZX_TRD_SERVICES_PUB_PKG.REC_NREC_DIST_TBL_TYPE,
 p_rnd_begin_index            IN      NUMBER,
 p_rnd_end_index              IN OUT NOCOPY  NUMBER,
 p_event_class_rec      IN       ZX_API_PUB.event_class_rec_type,
 p_return_status              OUT    NOCOPY VARCHAR2,
 p_error_buffer               OUT    NOCOPY VARCHAR2);
/*
Procedure Reverse_Tax_Dist(
 p_rec_nrec_dist_tbl          OUT    NOCOPY ZX_TRD_SERVICES_PUB_PKG.REC_NREC_DIST_TBL_TYPE,
 p_rnd_begin_index            IN      NUMBER,
 p_rnd_end_index              IN OUT NOCOPY NUMBER,
 p_return_status              OUT    NOCOPY VARCHAR2,
 p_error_buffer               OUT    NOCOPY VARCHAR2);
*/
PROCEDURE cancel_tax_line(
 p_detail_tax_line_tbl        IN      ZX_TRD_SERVICES_PUB_PKG.TAX_LINE_TBL_TYPE,
 p_tax_line_index             IN      NUMBER,
 p_rec_nrec_dist_tbl          IN OUT  NOCOPY ZX_TRD_SERVICES_PUB_PKG.REC_NREC_DIST_TBL_TYPE,
 p_rnd_begin_index            IN      NUMBER,
 p_rnd_end_index              IN OUT  NOCOPY NUMBER,
 p_event_class_rec      IN       ZX_API_PUB.event_class_rec_type,
 p_return_status              OUT     NOCOPY VARCHAR2,
 p_error_buffer               OUT     NOCOPY VARCHAR2);

PROCEDURE calc_variance_factors(
 p_return_status              OUT     NOCOPY VARCHAR2,
 p_error_buffer               OUT     NOCOPY VARCHAR2);

PROCEDURE DET_APPL_REC_TYPE(
 p_detail_tax_line_tbl        IN      ZX_TRD_SERVICES_PUB_PKG.TAX_LINE_TBL_TYPE,
 p_tax_line_index             IN      NUMBER,
 p_trx_line_dist_index        IN      NUMBER,
 p_rec_nrec_dist_tbl          IN OUT  NOCOPY ZX_TRD_SERVICES_PUB_PKG.REC_NREC_DIST_TBL_TYPE,
 p_rnd_begin_index            IN      NUMBER,
 p_rnd_end_index              OUT     NOCOPY NUMBER,
 p_return_status              OUT     NOCOPY VARCHAR2,
 p_error_buffer               OUT     NOCOPY VARCHAR2);

PROCEDURE GET_TAX_RELATED_COLUMNS_STA(
 p_detail_tax_line_tbl        IN      ZX_TRD_SERVICES_PUB_PKG.TAX_LINE_TBL_TYPE,
 p_tax_line_index             IN      NUMBER,
 p_trx_line_dist_index        IN      NUMBER,
 p_rec_nrec_dist_tbl          IN OUT  NOCOPY ZX_TRD_SERVICES_PUB_PKG.REC_NREC_DIST_TBL_TYPE,
 p_rnd_begin_index            IN      NUMBER,
 p_rnd_end_index              IN      NUMBER,
 p_return_status              OUT     NOCOPY VARCHAR2,
 p_error_buffer               OUT     NOCOPY VARCHAR2);

PROCEDURE GET_TAX_RELATED_COLUMNS_VAR(
 p_detail_tax_line_tbl        IN      ZX_TRD_SERVICES_PUB_PKG.TAX_LINE_TBL_TYPE,
 p_tax_line_index             IN      NUMBER,
 p_trx_line_dist_index        IN      NUMBER,
 p_rec_nrec_dist_tbl          IN OUT  NOCOPY ZX_TRD_SERVICES_PUB_PKG.REC_NREC_DIST_TBL_TYPE,
 p_rnd_begin_index            IN      NUMBER,
 p_rnd_end_index              IN      NUMBER,
 p_return_status              OUT     NOCOPY VARCHAR2,
 p_error_buffer               OUT     NOCOPY VARCHAR2);

PROCEDURE GET_REC_RATE(
 p_detail_tax_line_tbl        IN      ZX_TRD_SERVICES_PUB_PKG.TAX_LINE_TBL_TYPE,
 p_tax_line_index             IN      NUMBER,
 p_trx_line_dist_index        IN      NUMBER,
 p_event_class_rec            IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
 p_rec_nrec_dist_tbl          IN OUT  NOCOPY ZX_TRD_SERVICES_PUB_PKG.REC_NREC_DIST_TBL_TYPE,
 p_rnd_begin_index            IN      NUMBER,
 p_rnd_end_index              IN OUT  NOCOPY     NUMBER,
 p_return_status              OUT     NOCOPY VARCHAR2,
 p_error_buffer               OUT     NOCOPY VARCHAR2);

PROCEDURE get_rec_nrec_dist_amt(
 p_detail_tax_line_tbl        IN      ZX_TRD_SERVICES_PUB_PKG.TAX_LINE_TBL_TYPE,
 p_tax_line_index             IN      NUMBER,
 p_rec_nrec_dist_tbl          IN OUT  NOCOPY ZX_TRD_SERVICES_PUB_PKG.REC_NREC_DIST_TBL_TYPE,
 p_rnd_begin_index            IN      NUMBER,
 p_rnd_end_index              IN      NUMBER,
 p_return_status              OUT     NOCOPY VARCHAR2,
 p_error_buffer               OUT     NOCOPY VARCHAR2);

PROCEDURE round_rec_nrec_amt(
 p_rec_nrec_dist_tbl       IN OUT NOCOPY ZX_TRD_SERVICES_PUB_PKG.REC_NREC_DIST_TBL_TYPE,
 p_rnd_begin_index         IN            NUMBER,
 p_rnd_end_index           IN            NUMBER,
 p_tax_line_amt            IN            NUMBER,
 p_tax_line_amt_tax_curr   IN            NUMBER,
 p_tax_line_amt_funcl_curr IN            NUMBER,
 p_return_status              OUT NOCOPY VARCHAR2,
 p_error_buffer               OUT NOCOPY VARCHAR2);

PROCEDURE create_mrc_tax_dists (
 p_event_class_rec   IN             zx_api_pub.event_class_rec_type,
 p_rec_nrec_dist_tbl IN OUT NOCOPY  ZX_TRD_SERVICES_PUB_PKG.rec_nrec_dist_tbl_type,
 p_rnd_begin_index   IN             NUMBER,
 p_rnd_end_index     IN OUT NOCOPY  NUMBER,
 p_return_status        OUT NOCOPY  VARCHAR2,
 p_error_buffer         OUT NOCOPY  VARCHAR2);

END ZX_TRD_INTERNAL_SERVICES_PVT;


/
