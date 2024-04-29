--------------------------------------------------------
--  DDL for Package ZX_TRD_SERVICES_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TRD_SERVICES_PUB_PKG" AUTHID CURRENT_USER AS
/* $Header: zxmwrecdmsrvpubs.pls 120.26 2006/10/13 19:11:11 hsi ship $ */

TYPE rec_nrec_dist_tbl_type IS TABLE of ZX_REC_NREC_DIST%ROWTYPE
     INDEX BY BINARY_INTEGER;

TYPE tax_line_tbl_type IS TABLE OF zx_lines%ROWTYPE
     INDEX BY BINARY_INTEGER;

TYPE tax_hold_status IS RECORD(
  no_hold                        VARCHAR2(1),
  tax_variance		         VARCHAR2(1),
  tax_amount_range	         VARCHAR2(1),
  natural_account_tax	         VARCHAR2(1));

TYPE tax_variance_info_rec_type IS RECORD(
  trx_line_dist_qty              NUMBER,
  price_diff                     NUMBER,
  ref_doc_trx_line_dist_qty      NUMBER,
  ref_doc_curr_conv_rate         NUMBER,
  applied_to_doc_curr_conv_rate  NUMBER);

TYPE tax_variance_info_tbl_type IS TABLE OF
     tax_variance_info_rec_type INDEX BY BINARY_INTEGER;

g_tax_dist_id                    NUMBER;
g_tax_variance_info_tbl          tax_variance_info_tbl_type;
g_variance_calc_flag             VARCHAR2(1);

PROCEDURE determine_recovery(
	p_event_class_rec       IN      ZX_API_PUB.EVENT_CLASS_REC_TYPE,
	x_return_status         OUT NOCOPY     VARCHAR2);

PROCEDURE override_recovery(
	p_event_class_rec       IN      ZX_API_PUB.EVENT_CLASS_REC_TYPE,
	x_return_status         OUT NOCOPY     VARCHAR2
);

PROCEDURE reverse_tax_dist(
 p_rec_nrec_dist_tbl          OUT NOCOPY 	REC_NREC_DIST_TBL_TYPE,
 x_return_status              OUT NOCOPY    	VARCHAR2);

PROCEDURE validate_document_for_tax(
        p_event_class_rec      IN       ZX_API_PUB.EVENT_CLASS_REC_TYPE,
	p_transaction_rec      IN 	ZX_API_PUB.transaction_rec_type,
	x_hold_status	       OUT NOCOPY   	zx_api_pub.hold_codes_tbl_type,
        x_validate_status      OUT NOCOPY       VARCHAR2,
        x_return_status        OUT NOCOPY      VARCHAR2);

PROCEDURE reverse_distributions(
 x_return_status              OUT NOCOPY    	VARCHAR2);

PROCEDURE update_exchange_rate (
  p_event_class_rec      	IN          ZX_API_PUB.EVENT_CLASS_REC_TYPE,
  p_ledger_id			IN          NUMBER,
  p_currency_conversion_rate    IN          NUMBER,
  p_currency_conversion_type    IN          VARCHAR2,
  p_currency_conversion_date    IN          DATE,
  x_return_status        	OUT NOCOPY  VARCHAR2 );

PROCEDURE GET_CCID(
        p_gl_date               IN              DATE,
        p_tax_rate_id           IN              NUMBER,
        p_rec_rate_id           IN              NUMBER,
        p_Self_Assessed_Flag     IN              VARCHAR2,
        p_Recoverable_Flag       IN              VARCHAR2,
        p_tax_jurisdiction_id   IN              NUMBER,
        p_tax_regime_id         IN              NUMBER,
        p_tax_id                IN              NUMBER,
        p_tax_status_id         IN              NUMBER,
        p_org_id                IN              NUMBER,
        p_revenue_expense_ccid  IN              NUMBER,
        p_ledger_id             IN              NUMBER,
        p_account_source_tax_rate_id  IN        NUMBER,
        p_rec_nrec_tax_dist_id   IN             NUMBER,
        p_rec_nrec_ccid         OUT NOCOPY      NUMBER,
        p_tax_liab_ccid         OUT NOCOPY      NUMBER,
        x_return_status         OUT NOCOPY      VARCHAR2);

PROCEDURE GET_OUTPUT_TAX_CCID(
        p_gl_date               IN              DATE,
        p_tax_rate_id           IN              NUMBER,
        p_location_segment_id   IN              NUMBER,
        p_tax_line_id           IN              NUMBER,
        p_org_id                IN              NUMBER,
        p_ledger_id             IN              NUMBER,
        p_event_class_code      IN              VARCHAR2,
        p_entity_code           IN              VARCHAR2,
        p_application_id        IN              NUMBER,
        p_document_id           IN              NUMBER,
        p_document_line_id      IN              NUMBER,
        p_trx_level_type        IN              VARCHAR2,
        p_tax_account_ccid      OUT NOCOPY      NUMBER,
        p_interim_tax_ccid      OUT NOCOPY      NUMBER,
        p_adj_ccid              OUT NOCOPY      NUMBER,
        p_edisc_ccid            OUT NOCOPY      NUMBER,
        p_unedisc_ccid          OUT NOCOPY      NUMBER,
        p_finchrg_ccid          OUT NOCOPY      NUMBER,
        p_adj_non_rec_tax_ccid  OUT NOCOPY      NUMBER,
        p_edisc_non_rec_tax_ccid   OUT NOCOPY      NUMBER,
        p_unedisc_non_rec_tax_ccid OUT NOCOPY      NUMBER,
        p_finchrg_non_rec_tax_ccid OUT NOCOPY      NUMBER,
        x_return_status         OUT NOCOPY      VARCHAR2);

FUNCTION GET_RECOVERABLE_CCID(
        p_rec_nrec_dist_id      IN              NUMBER,
        p_tax_line_id           IN              NUMBER,
        p_gl_date               IN              DATE,
	p_tax_rate_id		IN		NUMBER,
	p_rec_rate_id		IN 		NUMBER,
        p_ledger_id             IN              NUMBER,
        p_source_rate_id        IN              NUMBER,
	p_content_owner_id	IN		NUMBER) RETURN NUMBER;



FUNCTION round_amt_to_mau (
  p_ledger_id			                NUMBER,
  p_unrounded_amt                               NUMBER ) RETURN NUMBER;

FUNCTION get_tax_hold_rls_val_frm_code (
  p_tax_hold_released_code IN VARCHAR2
) RETURN NUMBER;

FUNCTION get_prod_total_tax_amt(
  p_prepay_tax_amt     NUMBER,
  p_line_amt           NUMBER,
  p_prepay_line_amt    NUMBER ) RETURN NUMBER;

PROCEDURE is_recoverability_affected(
  p_pa_item_info_tbl IN OUT NOCOPY ZX_API_PUB.pa_item_info_tbl_type,
  x_return_status       OUT NOCOPY VARCHAR2);

PROCEDURE update_posting_flag(
 p_tax_dist_id_tbl            IN  		ZX_API_PUB.TAX_DIST_ID_TBL_TYPE,
 x_return_status              OUT NOCOPY    	VARCHAR2);

END  ZX_TRD_SERVICES_PUB_PKG;


 

/
