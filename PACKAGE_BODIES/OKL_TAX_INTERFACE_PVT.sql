--------------------------------------------------------
--  DDL for Package Body OKL_TAX_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TAX_INTERFACE_PVT" AS
/* $Header: OKLRTEIB.pls 120.14.12010000.2 2009/12/03 18:36:35 sachandr ship $ */

-- GENERATE PRIMARY KEY
FUNCTION get_seq_id RETURN NUMBER IS
BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
END get_seq_id;

/*========================================================================
 | PUBLIC PROCEDURE calculate_tax
 |
 | DESCRIPTION
 |    This procedure is called from OKL_PROCESS_TAX_PVT to calculate
 |    tax for OLM Tax events
 |
 | CALLED FROM PROCEDURES/FUNCTIONS
 |
 |
 | CALLS PROCEDURES/FUNCTIONS
 |       ZX_API_PUB.calculate_tax
 |
 | PARAMETERS
 |      p_trx_rec_tbl    -- tax source transactions
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 08-APR-05            SECHAWLA           Created
 |
 *=======================================================================*/
  PROCEDURE calculate_tax(
    p_api_version                  	IN  NUMBER,
    p_init_msg_list                	IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_hdr_params_rec                IN  hdr_params_rec_type,
    p_line_params_tbl				IN  line_params_tbl_type) IS

    /*-----------------------------------------------------------------------+
    | Local Variable Declarations and initializations                       |
    +-----------------------------------------------------------------------*/
    l_api_version            CONSTANT NUMBER := 1;
    l_api_name               CONSTANT VARCHAR2(30) := 'calculate_tax';
    l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    j                        NUMBER;
    lx_doc_level_recalc_flag VARCHAR2(1);

    lp_hdr_params_rec        hdr_params_rec_type;
    lp_line_params_tbl		 line_params_tbl_type;
    lp_transaction_rec       transaction_rec_type;

  BEGIN

    IF (G_DEBUG_LEVEL_PROCEDURE >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_DEBUG_LEVEL_PROCEDURE,'OKL_TAX_INTERFACE_PVT.calculate_tax','Begin(+)');
    END IF;

    --Print Input Variables
    IF (G_DEBUG_LEVEL_STATEMENT >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
              'p_init_msg_list :'||p_init_msg_list);
      FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
              'p_line_params_tbl.COUNT :'||p_line_params_tbl.COUNT);
    END IF;

    lp_hdr_params_rec  := p_hdr_params_rec;
    lp_line_params_tbl := p_line_params_tbl;

    -- Populate transaction header record -- start
    lp_transaction_rec.application_id           := lp_hdr_params_rec.application_id;
    lp_transaction_rec.trx_id                   := lp_hdr_params_rec.trx_id;
    lp_transaction_rec.internal_organization_id := lp_hdr_params_rec.internal_organization_id;
    lp_transaction_rec.entity_code              := lp_hdr_params_rec.entity_code ;
    lp_transaction_rec.event_class_code         := lp_hdr_params_rec.event_class_code;
    lp_transaction_rec.event_type_code          := lp_hdr_params_rec.event_type_code ;
    -- Populate transaction header record -- end

    IF (G_DEBUG_LEVEL_STATEMENT >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
            	  ' lp_transaction_rec.application_id '|| lp_transaction_rec.application_id);
      FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
            	  ' lp_transaction_rec.trx_id '|| lp_transaction_rec.trx_id);
      FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
            	  ' lp_transaction_rec.internal_organization_id '|| lp_transaction_rec.internal_organization_id);
      FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
            	  ' lp_transaction_rec.entity_code '|| lp_transaction_rec.entity_code);
      FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
            	  ' lp_transaction_rec.event_class_code '|| lp_transaction_rec.event_class_code);
      FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
            	  ' lp_transaction_rec.event_type_code '|| lp_transaction_rec.event_type_code);
    END IF;

    -- Populate ZX global structure -- start
    IF (lp_line_params_tbl.COUNT > 0) THEN
      FOR j IN lp_line_params_tbl.FIRST .. lp_line_params_tbl.LAST LOOP

        ZX_GLOBAL_STRUCTURES_PKG.INIT_TRX_LINE_DIST_TBL(j);

        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.internal_organization_id(j)              := lp_line_params_tbl(j).internal_organization_id;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.application_id(j)                        := lp_line_params_tbl(j).application_id ;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.entity_code(j)                           := lp_line_params_tbl(j).entity_code;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.event_class_code(j)                      := lp_line_params_tbl(j).event_class_code;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.event_type_code(j)                       := lp_line_params_tbl(j).event_type_code;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trx_id(j)                                := lp_transaction_rec.trx_id;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trx_date(j)                              := lp_line_params_tbl(j).trx_date;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ledger_id(j)                             := lp_line_params_tbl(j).ledger_id;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.legal_entity_id(j)                       := lp_line_params_tbl(j).legal_entity_id;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trx_level_type(j)                        := lp_line_params_tbl(j).trx_level_type;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.line_level_action(j)                     := lp_line_params_tbl(j).line_level_action;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trx_line_id(j)                           := lp_line_params_tbl(j).trx_line_id;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.line_amt(j)                              := lp_line_params_tbl(j).line_amt;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trx_business_category(j)                 := lp_line_params_tbl(j).trx_business_category ;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.product_category(j)                      := lp_line_params_tbl(j).product_category ;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.user_defined_fisc_class(j)               := lp_line_params_tbl(j).user_defined_fisc_class ;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.line_intended_use(j)                     := lp_line_params_tbl(j).line_intended_use ;

        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.tax_reporting_flag(j)                    := lp_line_params_tbl(j).tax_reporting_flag;

        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.default_taxation_country(j)              := lp_line_params_tbl(j).default_taxation_country;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.product_type(j)                          := lp_line_params_tbl(j).product_type;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.output_tax_classification_code(j)        := lp_line_params_tbl(j).output_tax_classification_code;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.assessable_value(j)                      := lp_line_params_tbl(j).assessable_value;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.receivables_trx_type_id(j)               := lp_line_params_tbl(j).receivables_trx_type_id;

        -- Product fiscal classification will be derived in eBTax using inventory item id
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.product_id(j)                            := lp_line_params_tbl(j).product_id;

        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.adjusted_doc_entity_code(j)              := lp_line_params_tbl(j).adjusted_doc_entity_code;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.adjusted_doc_event_class_code(j)         := lp_line_params_tbl(j).adjusted_doc_event_class_code;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.adjusted_doc_trx_id(j)                   := lp_line_params_tbl(j).adjusted_doc_trx_id;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.adjusted_doc_line_id(j)                  := lp_line_params_tbl(j).adjusted_doc_line_id;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.adjusted_doc_trx_level_type(j)           := lp_line_params_tbl(j).adjusted_doc_trx_level_type;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.adjusted_doc_number(j)                   := lp_line_params_tbl(j).adjusted_doc_number;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.adjusted_doc_date(j)                     := lp_line_params_tbl(j).adjusted_doc_date;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.line_amt_includes_tax_flag(j)            := lp_line_params_tbl(j).line_amt_includes_tax_flag;

        -- Populate ZX Global Structure with Location and Party Identifiers
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ship_to_cust_acct_site_use_id(j)         := lp_line_params_tbl(j).ship_to_cust_acct_site_use_id;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.bill_to_cust_acct_site_use_id(j)         := lp_line_params_tbl(j).bill_to_cust_acct_site_use_id;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.bill_to_party_site_id(j)                 := lp_line_params_tbl(j).bill_to_party_site_id;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.bill_to_location_id(j)                   := lp_line_params_tbl(j).bill_to_location_id;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.bill_to_party_id(j)                      := lp_line_params_tbl(j).bill_to_party_id;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ship_to_party_site_id(j)                 := lp_line_params_tbl(j).ship_to_party_site_id;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ship_to_location_id(j)                   := lp_line_params_tbl(j).ship_to_location_id;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ship_to_party_id(j)                      := lp_line_params_tbl(j).ship_to_party_id;

        -- Rounding identifiers
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.rounding_ship_to_party_id(j)             := lp_line_params_tbl(j).rounding_ship_to_party_id;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.rounding_bill_to_party_id(j)             := lp_line_params_tbl(j).rounding_bill_to_party_id;

        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trx_currency_code(j)                     := lp_line_params_tbl(j).trx_currency_code;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.precision(j)                             := lp_line_params_tbl(j).precision;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.minimum_accountable_unit(j)              := lp_line_params_tbl(j).minimum_accountable_unit;

        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.currency_conversion_date(j)              := lp_line_params_tbl(j).currency_conversion_date;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.currency_conversion_rate(j)              := lp_line_params_tbl(j).currency_conversion_rate;
        ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.currency_conversion_type(j)              := lp_line_params_tbl(j).currency_conversion_type;

        IF (lp_line_params_tbl(j).provnl_tax_determination_date IS NOT NULL) THEN
          ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.provnl_tax_determination_date(j)       := lp_line_params_tbl(j).provnl_tax_determination_date;
        END IF;

        IF (lp_line_params_tbl(j).ctrl_total_hdr_tax_amt IS NOT NULL) THEN
          ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ctrl_total_hdr_tx_amt(j)               := lp_line_params_tbl(j).ctrl_total_hdr_tax_amt;
        END IF;

        -- Populate 'ICX_SESSION_ID' for Quote calls
        IF (lp_hdr_params_rec.quote_flag = 'Y') THEN
          ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.icx_session_id(j)                      := FND_GLOBAL.SESSION_ID;
        END IF;

        IF (G_DEBUG_LEVEL_STATEMENT >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' internal_organization_id '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.internal_organization_id(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' application_id '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.application_id(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' entity_code '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.entity_code(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' event_class_code '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.event_class_code(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' event_type_code '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.event_type_code(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' trx_id '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trx_id(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' trx_date '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trx_date(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' ledger_id '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ledger_id(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' legal_entity_id '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.legal_entity_id(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' trx_level_type '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trx_level_type(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' line_level_action '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.line_level_action(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' trx_line_id '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trx_line_id(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' line_amt '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.line_amt(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' trx_business_category '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trx_business_category(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' product_category '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.product_category(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' user_defined_fisc_class '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.user_defined_fisc_class(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' line_intended_use '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.line_intended_use(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' tax_reporting_flag '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.tax_reporting_flag(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' default_taxation_country '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.default_taxation_country(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' product_type '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.product_type(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' output_tax_classification_code '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.output_tax_classification_code(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' assessable_value '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.assessable_value(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' receivables_trx_type_id '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.receivables_trx_type_id(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' product_id '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.product_id(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' adjusted_doc_entity_code '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.adjusted_doc_entity_code(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' adjusted_doc_event_class_code '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.adjusted_doc_event_class_code(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' adjusted_doc_trx_id '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.adjusted_doc_trx_id(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' adjusted_doc_line_id '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.adjusted_doc_line_id(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' adjusted_doc_trx_level_type '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.adjusted_doc_trx_level_type(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' adjusted_doc_number '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.adjusted_doc_number(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' adjusted_doc_date '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.adjusted_doc_date(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' line_amt_includes_tax_flag '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.line_amt_includes_tax_flag(j));

          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' ship_to_cust_acct_site_use_id '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ship_to_cust_acct_site_use_id(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' bill_to_cust_acct_site_use_id '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.bill_to_cust_acct_site_use_id(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' bill_to_party_site_id '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.bill_to_party_site_id(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' bill_to_location_id '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.bill_to_location_id(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' bill_to_party_id '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.bill_to_party_id(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' ship_to_party_site_id '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ship_to_party_site_id(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' ship_to_location_id '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ship_to_location_id(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' ship_to_party_id '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ship_to_party_id(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' rounding_ship_to_party_id '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.rounding_ship_to_party_id(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' rounding_bill_to_party_id '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.rounding_bill_to_party_id(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' trx_currency_code '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trx_currency_code(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' precision '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.precision(j));

          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' minimum_accountable_unit '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.minimum_accountable_unit(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' currency_conversion_date '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.currency_conversion_date(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' currency_conversion_rate '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.currency_conversion_rate(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' currency_conversion_type '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.currency_conversion_type(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' provnl_tax_determination_date '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.provnl_tax_determination_date(j));
          FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
         	  ' ctrl_total_hdr_tx_amt '|| ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ctrl_total_hdr_tx_amt(j));
        END IF;
      END LOOP;
    END IF;
    -- Populate ZX global structure -- end

    -- Calculate Tax
    IF (G_DEBUG_LEVEL_STATEMENT >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
          'Calling ZX_API_PUB.calculate_tax ..');
    END IF;

    ZX_API_PUB.calculate_tax
        (p_api_version            => p_api_version,
         p_init_msg_list          => p_init_msg_list,
         p_commit                 => 'F',
         p_validation_level       => 1,
         x_return_status          => l_return_status,
         x_msg_count              => x_msg_count,
         x_msg_data               => x_msg_data,
         p_transaction_rec        => lp_transaction_rec,
         p_quote_flag             => lp_hdr_params_rec.quote_flag,
         p_data_transfer_mode     => 'PLS',
         x_doc_level_recalc_flag  => lx_doc_level_recalc_flag);

    IF (G_DEBUG_LEVEL_STATEMENT >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
            	  'After calling ZX_API_PUB.calculate_tax '||l_return_status);
      FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.calculate_tax.',
            	  'lx_doc_level_recalc_flag '||lx_doc_level_recalc_flag);
    END IF;

    IF ( l_return_status <> OKL_API.G_RET_STS_SUCCESS ) THEN
      -- Tax Calculation Failed
      OKL_API.set_message( p_app_name      => 'OKL',
                           p_msg_name      => 'OKL_TX_TAX_ENGINE_ERR');
    END IF;
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;

    IF (G_DEBUG_LEVEL_PROCEDURE >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_DEBUG_LEVEL_PROCEDURE,'OKL_TAX_INTERFACE_PVT.calculate_tax ','End(-)');
    END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_TAX_INTERFACE_PVT.calculate_tax ',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_ERROR');
      END IF;

      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_TAX_INTERFACE_PVT.calculate_tax ',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_UNEXPECTED_ERROR');
      END IF;

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN

      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'OKL_TAX_INTERFACE_PVT.calculate_tax ',
                  'EXCEPTION :'||sqlerrm);
      END IF;

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      -- unexpected error
      OKL_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

  END calculate_tax;

/*========================================================================
 | PUBLIC PROCEDURE get_tax_classification_code
 |
 | DESCRIPTION
 |    This procedure retrives the tax classification code
 |
 | CALLED FROM
 |
 |
 | CALLS PROCEDURES/FUNCTIONS
 |       ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification
 |
 | PARAMETERS
 |   p_ship_to_site_use_id
 |   p_bill_to_site_use_id
 |   p_inventory_item_id
 |   p_organization_id
 |   p_set_of_books_id
 |   p_trx_date
 |   p_trx_type_id
 |   p_entity_code
 |   p_event_class_code
 |   p_application_id
 |   p_internal_organization_id
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date          Author     Description of Changes
 | 24-APR-07    RRAVIKIR      Created
 |
 *=======================================================================*/
  PROCEDURE get_tax_classification_code (
    x_return_status                 OUT NOCOPY VARCHAR2,
    p_ship_to_site_use_id           IN  NUMBER,
    p_bill_to_site_use_id           IN  NUMBER,
    p_inventory_item_id             IN  NUMBER,
    p_organization_id               IN  NUMBER,
    p_set_of_books_id               IN  NUMBER,
    p_trx_date                      IN DATE,
    p_trx_type_id                   IN NUMBER,
    p_entity_code                   IN VARCHAR2,
    p_event_class_code              IN VARCHAR2,
    p_application_id                IN NUMBER,
    p_internal_organization_id      IN NUMBER,
    p_vendor_id                     IN NUMBER DEFAULT NULL,
    p_vendor_site_id                IN NUMBER DEFAULT NULL,
    x_tax_classification_code       OUT NOCOPY VARCHAR2 ) IS

    -- Local variables
    l_api_name                      CONSTANT VARCHAR2(30) := 'get_tax_classification_code';

    lx_tax_classification_code      VARCHAR2(50);
    lx_allow_tax_code_flag          VARCHAR2(1);

  BEGIN

    IF (G_DEBUG_LEVEL_PROCEDURE >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_DEBUG_LEVEL_PROCEDURE,'OKL_TAX_INTERFACE_PVT.get_tax_classification_code','Begin(+)');
    END IF;

    --Print Input Variables
    IF (G_DEBUG_LEVEL_STATEMENT >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.get_tax_classification_code.',
              'p_ship_to_site_use_id :'||p_ship_to_site_use_id);
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.get_tax_classification_code.',
              'p_bill_to_site_use_id :'||p_bill_to_site_use_id);
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.get_tax_classification_code.',
              'p_inventory_item_id :'||p_inventory_item_id);
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.get_tax_classification_code.',
              'p_organization_id :'||p_organization_id);
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.get_tax_classification_code.',
              'p_set_of_books_id :'||p_set_of_books_id);
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.get_tax_classification_code.',
              'p_trx_date :'||p_trx_date);
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.get_tax_classification_code.',
              'p_trx_type_id :'||p_trx_type_id);
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.get_tax_classification_code.',
              'p_entity_code :'||p_entity_code);
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.get_tax_classification_code.',
              'p_event_class_code :'||p_event_class_code);
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.get_tax_classification_code.',
              'p_application_id :'||p_application_id);
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.get_tax_classification_code.',
              'p_internal_organization_id :'||p_internal_organization_id);
    END IF;

    IF (G_DEBUG_LEVEL_STATEMENT >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.get_tax_classification_code.',
              'Calling ZX_TRX_DETAIL.mark_reporting_only_flag');
    END IF;

    IF (p_entity_code = OKL_PROCESS_SALES_TAX_PVT.G_AR_ENTITY_CODE) THEN
      ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification (
                      p_ship_to_site_use_id      => p_ship_to_site_use_id
                     ,p_bill_to_site_use_id      => p_bill_to_site_use_id
                     ,p_inventory_item_id        => p_inventory_item_id
                     ,p_organization_id          => p_organization_id
                     ,p_set_of_books_id          => p_set_of_books_id
                     ,p_trx_date                 => p_trx_date
                     ,p_trx_type_id              => p_trx_type_id
                     ,p_tax_classification_code  => lx_tax_classification_code
                     ,p_entity_code              => p_entity_code
                     ,p_event_class_code         => p_event_class_code
                     ,p_application_id           => p_application_id
                     ,p_internal_organization_id => p_internal_organization_id);

    ELSIF (p_entity_code = OKL_PROCESS_SALES_TAX_PVT.G_AP_ENTITY_CODE) THEN
      ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification(
                      p_ref_doc_application_id       => null
                     ,p_ref_doc_entity_code          => null
                     ,p_ref_doc_event_class_code     => null
                     ,p_ref_doc_trx_id               => null
                     ,p_ref_doc_line_id              => null
                     ,p_ref_doc_trx_level_type       => null
                     ,p_vendor_id			         => p_vendor_id
                     ,p_vendor_site_id 		         => p_vendor_site_id
                     ,p_code_combination_id  	     => null
                     ,p_concatenated_segments	     => null
                     ,p_templ_tax_classification_cd  => null
                     ,p_ship_to_location_id		     => null
                     ,p_ship_to_loc_org_id   	     => null
                     ,p_inventory_item_id   		 => p_inventory_item_id
                     ,p_item_org_id   		         => p_organization_id
                     ,p_tax_classification_code	     => lx_tax_classification_code
                     ,p_allow_tax_code_override_flag => lx_allow_tax_code_flag
                     ,appl_short_name		         => 'SQLAP'
                     ,func_short_name		         => null
                     ,p_calling_sequence		     => null
                     ,p_event_class_code             => p_event_class_code
                     ,p_entity_code                  => p_entity_code
                     ,p_application_id               => p_application_id
                     ,p_internal_organization_id     => p_internal_organization_id);
    END IF;

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF (G_DEBUG_LEVEL_PROCEDURE >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_DEBUG_LEVEL_PROCEDURE,'OKL_TAX_INTERFACE_PVT.get_tax_classification_code ','End(-)');
    END IF;

    x_tax_classification_code := lx_tax_classification_code;

  EXCEPTION
    WHEN OTHERS THEN

      IF (G_DEBUG_LEVEL_EXCEPTION >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_EXCEPTION,'OKL_TAX_INTERFACE_PVT.get_tax_classification_code ',
                  'EXCEPTION :'||sqlerrm);
      END IF;

      OKL_API.set_message(p_app_name      => 'OKL',
                          p_msg_name      => 'OKL_TX_TAX_CLASS_CODE_ERR'); --'Error getting Default Tax Classification Code.'
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      -- unexpected error
      OKL_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

  END get_tax_classification_code;

/*========================================================================
 | PUBLIC PROCEDURE mark_reporting_flag
 |
 | DESCRIPTION
 |    This procedure is called by billing and disbursement modules to fetch tax
 |    determinants
 |
 | CALLED FROM
 |
 |
 | CALLS PROCEDURES/FUNCTIONS
 |       ZX_TRX_DETAIL.mark_reporting_only_flag
 |
 | PARAMETERS
 |      p_trx_id		    -- Transaction identifier
 |      p_application_id    -- Application identifier
 |      p_entity_code       -- Entity code
 |      p_event_class_code  -- Event class code
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date          Author     Description of Changes
 | 01-MAR-07    RRAVIKIR      Created
 |
 *=======================================================================*/
  PROCEDURE mark_reporting_flag( p_api_version         IN  NUMBER,
                                 p_init_msg_list       IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                 x_return_status       OUT NOCOPY VARCHAR2,
                                 x_msg_count           OUT NOCOPY NUMBER,
                                 x_msg_data            OUT NOCOPY VARCHAR2,
                                 p_trx_id              IN  NUMBER,
                                 p_application_id      IN  NUMBER,
                                 p_entity_code         IN  VARCHAR2,
                                 p_event_class_code    IN  VARCHAR2) IS

    -- Local variables
    l_api_version                   CONSTANT NUMBER := 1;
    l_api_name                      CONSTANT VARCHAR2(30) := 'mark_reporting_flag';
    l_return_status                 VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN
    IF (G_DEBUG_LEVEL_PROCEDURE >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_DEBUG_LEVEL_PROCEDURE,'OKL_TAX_INTERFACE_PVT.mark_reporting_flag','Begin(+)');
    END IF;

    --Print Input Variables
    IF (G_DEBUG_LEVEL_STATEMENT >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.mark_reporting_flag.',
              'p_init_msg_list :'||p_init_msg_list);
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.mark_reporting_flag.',
              'p_trx_id :'||p_trx_id);
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.mark_reporting_flag.',
              'p_application_id :'||p_application_id);
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.mark_reporting_flag.',
              'p_entity_code :'||p_entity_code);
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.mark_reporting_flag.',
              'p_event_class_code :'||p_event_class_code);
    END IF;

    IF (G_DEBUG_LEVEL_STATEMENT >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.mark_reporting_flag.',
              'Calling ZX_TRX_DETAIL.mark_reporting_only_flag');
    END IF;

    ZX_TRX_DETAIL.mark_reporting_only_flag( p_trx_id           => p_trx_id,
                                            p_application_id   => p_application_id,
                                            p_entity_code      => p_entity_code,
                                            p_event_class_code => p_event_class_code,
                                            p_return_status    => l_return_status,
                                            p_error_buffer     => x_msg_data,
                                            p_reporting_flag   => 'Y');

    IF (G_DEBUG_LEVEL_STATEMENT >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.mark_reporting_flag.',
              'Return Status' || l_return_status);
    END IF;

    IF ( l_return_status <> OKL_API.G_RET_STS_SUCCESS ) THEN
      -- mark reporting flag failed
      OKL_API.set_message( p_app_name      => 'OKL',
                           p_msg_name      => 'OKL_TX_MARK_REPORT_FLAG_ERR');
    END IF;

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;

    IF (G_DEBUG_LEVEL_PROCEDURE >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_DEBUG_LEVEL_PROCEDURE,'OKL_TAX_INTERFACE_PVT.mark_reporting_flag ','End(-)');
    END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF (G_DEBUG_LEVEL_EXCEPTION >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_EXCEPTION,'OKL_TAX_INTERFACE_PVT.mark_reporting_flag ',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_ERROR');
      END IF;

      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF (G_DEBUG_LEVEL_EXCEPTION >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_EXCEPTION,'OKL_TAX_INTERFACE_PVT.mark_reporting_flag ',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_UNEXPECTED_ERROR');
      END IF;

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      IF (G_DEBUG_LEVEL_EXCEPTION >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_EXCEPTION,'OKL_TAX_INTERFACE_PVT.mark_reporting_flag ',
                  'EXCEPTION :'||sqlerrm);
      END IF;

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      -- unexpected error
      OKL_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

  END mark_reporting_flag;


/*========================================================================
 | PUBLIC PROCEDURE set_tax_security_context
 |
 | DESCRIPTION
 |    This procedure is called by update tax common components for setting the
 |    tax security context before invoking Tax Determinant Lov's
 |
 | CALLED FROM 					Tax Common components
 |
 |
 | CALLS PROCEDURES/FUNCTIONS
 |     zx_api_pub.set_tax_security_context()
 |
 |
 | PARAMETERS
 |      p_internal_org_id		-- Operatng Unit Identifier
 |      p_legal_entity_id       -- Legal Entity Identifier
 |      p_transaction_date      -- Transaction Date
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date          Author     Description of Changes
 | 24-JAN-07    RRAVIKIR      Created
 *=======================================================================*/
  PROCEDURE set_tax_security_context(
    p_api_version                  	IN  NUMBER,
    p_init_msg_list                	IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_internal_org_id			 	IN  NUMBER,
    p_legal_entity_id               IN  NUMBER,
    p_transaction_date              IN  DATE) IS

    l_api_version            CONSTANT NUMBER := 1;
    l_api_name               CONSTANT VARCHAR2(30) := 'set_tax_security_context';
    l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    x_effective_date         DATE;

  BEGIN

    IF (G_DEBUG_LEVEL_PROCEDURE >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_DEBUG_LEVEL_PROCEDURE,'OKL_TAX_INTERFACE_PVT.set_tax_security_context','Begin(+)');
    END IF;

    --Print Input Variables
    IF (G_DEBUG_LEVEL_STATEMENT >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.set_tax_security_context.',
              'p_init_msg_list :'||p_init_msg_list);
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.set_tax_security_context.',
              'p_internal_org_id :'||to_char(p_internal_org_id));
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.set_tax_security_context.',
              'p_legal_entity_id :'||p_legal_entity_id);
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.set_tax_security_context.',
              'p_transaction_date :'||p_transaction_date);
    END IF;

    IF (G_DEBUG_LEVEL_STATEMENT >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.set_tax_security_context.',
              'Calling ZX_API_PUB.set_tax_security_context');
    END IF;

    -- Set Tax Security Context
    ZX_API_PUB.set_tax_security_context(p_api_version           => p_api_version,
                                        p_init_msg_list         => p_init_msg_list,
                                        p_commit                => 'F',
                                        p_validation_level      => 1,
                                        x_return_status         => l_return_status,
                                        x_msg_count             => x_msg_count,
                                        x_msg_data              => x_msg_data,
                                        p_internal_org_id       => p_internal_org_id,
                                        p_legal_entity_id       => p_legal_entity_id,
                                        p_transaction_date      => p_transaction_date,
                                        p_related_doc_date      => NULL,
                                        p_adjusted_doc_date     => NULL,
                                        p_provnl_tax_det_date   => NULL,
                                        x_effective_date        => x_effective_date);

    IF (G_DEBUG_LEVEL_STATEMENT >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.set_tax_security_context.',
              'Return Status' || l_return_status);
    END IF;

    IF ( l_return_status <> OKL_API.G_RET_STS_SUCCESS ) THEN
      -- set tax security context failed
      OKL_API.set_message( p_app_name      => 'OKL',
                           p_msg_name      => 'OKL_TX_SET_TAX_CNTXT_ERR');
    END IF;

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;

    IF (G_DEBUG_LEVEL_PROCEDURE >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_DEBUG_LEVEL_PROCEDURE,'OKL_TAX_INTERFACE_PVT.set_tax_security_context ','End(-)');
    END IF;

   EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF (G_DEBUG_LEVEL_EXCEPTION >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_EXCEPTION,'OKL_TAX_INTERFACE_PVT.set_tax_security_context ',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_ERROR');
      END IF;

      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF (G_DEBUG_LEVEL_EXCEPTION >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_EXCEPTION,'OKL_TAX_INTERFACE_PVT.set_tax_security_context ',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_UNEXPECTED_ERROR');
      END IF;

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      IF (G_DEBUG_LEVEL_EXCEPTION >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_EXCEPTION,'OKL_TAX_INTERFACE_PVT.set_tax_security_context ',
                  'EXCEPTION :'||sqlerrm);
      END IF;

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      -- unexpected error
      OKL_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

  END set_tax_security_context;

/*========================================================================
 | PUBLIC PROCEDURE process_tax_determ_override
 |
 | DESCRIPTION
 |    This procedure is called by 'BOOKING', 'REBOOK' and 'ASSET LOCATION
 |    CHANGE' transactions to override tax determinants
 |
 | CALLED FROM 					OLM Tax Events
 |
 |
 | CALLS PROCEDURES/FUNCTIONS
 |       ZX_API_PUB.calculate_tax
 |
 | PARAMETERS
 |      p_trx_id                     -- Transaction Identifier
 |      p_tax_sources_id	         -- Tax Sources table unique Identifier
 |      p_trx_business_category      -- Transaction Business Category (Tax Determinant)
 |      p_product_category           -- Product Category (Tax Determinant)
 |      p_user_defined_fisc_class    -- User defined fiscal class (Tax Determinant)
 |      p_line_intended_use          -- Line intended use (Tax Determinant)
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date          Author     Description of Changes
 | 01-FEB-07    RRAVIKIR      Created
 |
 *=======================================================================*/
  PROCEDURE process_tax_determ_override(
    p_api_version                   IN  NUMBER,
    p_init_msg_list                 IN  VARCHAR2,
    x_return_status                 OUT NOCOPY VARCHAR2 ,
    x_msg_count                     OUT NOCOPY NUMBER ,
    x_msg_data                      OUT NOCOPY VARCHAR2,
    p_trx_id                        IN  NUMBER,
    p_tax_sources_id                IN  NUMBER,
    p_trx_business_category         IN  VARCHAR2,
    p_product_category			 	IN  VARCHAR2,
    p_user_defined_fisc_class       IN  VARCHAR2,
    p_line_intended_use             IN  VARCHAR2,
    p_transaction_rec               IN  transaction_rec_type,
    x_doc_level_recalc_flag         OUT NOCOPY VARCHAR2) IS

    l_api_version            CONSTANT NUMBER := 1;
    l_api_name               CONSTANT VARCHAR2(30) := 'process_tax_determ';
    l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    x_effective_date         DATE;
    l_ledger_id              NUMBER;
    l_cust_trx_type_id       NUMBER;

    l_transaction_rec        transaction_rec_type;

    -- Cursors
    CURSOR l_taxsources_csr(cp_tax_sources_id IN NUMBER) IS
    SELECT trx_line_id, application_id, event_class_code, entity_code, trx_date,
           khr_id, trx_currency_code, currency_conversion_type,
           currency_conversion_rate, currency_conversion_date, org_id,
           legal_entity_id, trx_level_type, line_amt, bill_to_cust_acct_id,
           default_taxation_country, tax_classification_code, assessable_value,
           inventory_item_id, product_type, ship_to_cust_acct_site_use_id,
           bill_to_cust_acct_site_use_id, bill_to_party_site_id, bill_to_location_id,
           bill_to_party_id, ship_to_party_site_id, ship_to_location_id,
           ship_to_party_id, adjusted_doc_entity_code, adjusted_doc_event_class_code,
           adjusted_doc_trx_id, adjusted_doc_trx_line_id, adjusted_doc_trx_level_type,
           adjusted_doc_number, adjusted_doc_date, tax_reporting_flag
    FROM  okl_tax_sources
    WHERE id = cp_tax_sources_id;

    CURSOR l_racusttrxtypes_csr IS
    SELECT cust_trx_type_id
	FROM   ra_cust_trx_types_all
	WHERE  name = 'Invoice-OKL';

    CURSOR l_fndcurrency_csr(cp_currency_code IN VARCHAR2) IS
    SELECT precision, minimum_accountable_unit
    FROM   fnd_currencies
    WHERE  currency_code = cp_currency_code
	AND    enabled_flag = 'Y'
    AND    nvl(start_date_active, sysdate) <= sysdate
    AND    nvl(end_date_active, sysdate) >= sysdate;

    -- Cursor Records
    l_taxsources_rec         l_taxsources_csr%ROWTYPE;
    l_fndcurrency_rec        l_fndcurrency_csr%ROWTYPE;

  BEGIN

    IF (G_DEBUG_LEVEL_PROCEDURE >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_DEBUG_LEVEL_PROCEDURE,'OKL_TAX_INTERFACE_PVT.process_tax_determ_override','Begin(+)');
    END IF;

    --Print Input Variables
    IF (G_DEBUG_LEVEL_STATEMENT >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.process_tax_determ_override.',
              'p_init_msg_list :'||p_init_msg_list);
    END IF;

    -- Tax Determinants override
    l_transaction_rec := p_transaction_rec;

    -- Fetch Tax Sources details
    OPEN l_taxsources_csr(cp_tax_sources_id  =>  p_tax_sources_id);
    FETCH l_taxsources_csr INTO l_taxsources_rec;
    CLOSE l_taxsources_csr;

    -- Fetch AR Customer Account Trx Type
    OPEN  l_racusttrxtypes_csr;
    FETCH l_racusttrxtypes_csr INTO l_cust_trx_type_id;
    IF l_racusttrxtypes_csr%NOTFOUND THEN
      -- AR Customer Account Trx Type is required
      OKL_API.set_message( p_msg_name      => G_REQUIRED_VALUE,
                           p_token1        => G_COL_NAME_TOKEN,
                           p_token1_value  => 'CUST_TRX_TYPE_ID');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    CLOSE l_racusttrxtypes_csr;

    -- Retrieve Ledger Id
    l_ledger_id := okl_accounting_util.get_set_of_books_id;

    -- Initialize ZX Global Structure
    ZX_GLOBAL_STRUCTURES_PKG.INIT_TRX_LINE_DIST_TBL(1);

    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.internal_organization_id (1) := l_taxsources_rec.org_id;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.application_id (1)           := l_taxsources_rec.application_id ;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.entity_code (1)              := l_transaction_rec.entity_code;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.event_class_code (1)         := l_transaction_rec.event_class_code;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.event_type_code (1)          := l_transaction_rec.event_type_code;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trx_id (1)                   := p_trx_id;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trx_date (1)                 := l_taxsources_rec.trx_date;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ledger_id (1)                := l_ledger_id;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.legal_entity_id (1)          := l_taxsources_rec.legal_entity_id;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trx_level_type (1)           := l_taxsources_rec.trx_level_type;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.line_level_action (1)        := OKL_PROCESS_SALES_TAX_PVT.G_UPDATE_LINE_LEVEL_ACTION ;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trx_line_id (1)              := l_taxsources_rec.trx_line_id;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.line_amt (1)                 := l_taxsources_rec.line_amt;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trx_business_category (1)    := p_trx_business_category ;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.product_category (1)         := p_product_category ;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.user_defined_fisc_class (1)  := p_user_defined_fisc_class ;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.line_intended_use (1)        := p_line_intended_use ;

    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.tax_reporting_flag (1)       := l_taxsources_rec.tax_reporting_flag;

    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.default_taxation_country (1) := l_taxsources_rec.default_taxation_country;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.product_type (1)             := l_taxsources_rec.product_type;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.output_tax_classification_code (1) := l_taxsources_rec. tax_classification_code;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.assessable_value (1)         := l_taxsources_rec.assessable_value;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.receivables_trx_type_id (1)  := l_cust_trx_type_id;

    -- Product fiscal classification will be derived in eBTax using inventory item id
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.product_id (1)               := l_taxsources_rec.inventory_item_id;

    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.adjusted_doc_entity_code (1) := l_taxsources_rec.adjusted_doc_entity_code;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.adjusted_doc_event_class_code (1) := l_taxsources_rec.adjusted_doc_event_class_code;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.adjusted_doc_trx_id (1)      := l_taxsources_rec.adjusted_doc_trx_id;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.adjusted_doc_line_id (1)     := l_taxsources_rec.adjusted_doc_trx_line_id;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.adjusted_doc_trx_level_type (1) := l_taxsources_rec.adjusted_doc_trx_level_type;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.adjusted_doc_number (1)      := l_taxsources_rec.adjusted_doc_number;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.adjusted_doc_date (1)        := l_taxsources_rec.adjusted_doc_date;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.line_amt_includes_tax_flag (1) := 'N';

    -- Populate ZX Global Structure with Location and Party Identifiers
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ship_to_cust_acct_site_use_id (1) := l_taxsources_rec.ship_to_cust_acct_site_use_id;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.bill_to_cust_acct_site_use_id (1) := l_taxsources_rec.bill_to_cust_acct_site_use_id;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.bill_to_party_site_id (1)         := l_taxsources_rec.bill_to_party_site_id;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.bill_to_location_id (1)           := l_taxsources_rec.bill_to_location_id;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.bill_to_party_id (1)              := l_taxsources_rec.bill_to_party_id;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ship_to_party_site_id (1)         := l_taxsources_rec.ship_to_party_site_id;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ship_to_location_id (1)           := l_taxsources_rec.ship_to_location_id;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ship_to_party_id (1)              := l_taxsources_rec.ship_to_party_id;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.rounding_ship_to_party_id (1)     := l_taxsources_rec.ship_to_party_id;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.rounding_bill_to_party_id (1)     := l_taxsources_rec.bill_to_party_id;

    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.insert_update_flag (1)            := 'U';

    -- Populate Currency values
    OPEN  l_fndcurrency_csr(cp_currency_code => l_taxsources_rec.trx_currency_code);
    FETCH l_fndcurrency_csr INTO l_fndcurrency_rec;

    IF l_fndcurrency_csr%NOTFOUND THEN
      OKL_API.set_message( p_msg_name      => G_REQUIRED_VALUE,
                           p_token1        => G_COL_NAME_TOKEN,
                           p_token1_value  => 'CURRENCY_CODE');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    CLOSE l_fndcurrency_csr;
    -- End Populate Currency values

    -- Populate ZX Global Structure with Currency Identifiers
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trx_currency_code(1)         := l_taxsources_rec.trx_currency_code;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.precision (1)                := l_fndcurrency_rec.precision;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.minimum_accountable_unit (1) := l_fndcurrency_rec.minimum_accountable_unit;

    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.currency_conversion_date (1) := l_taxsources_rec.currency_conversion_date;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.currency_conversion_rate (1) := l_taxsources_rec.currency_conversion_rate;
    ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.currency_conversion_type (1) := l_taxsources_rec.currency_conversion_type;

    IF (G_DEBUG_LEVEL_STATEMENT >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.process_tax_determ_override.',
              'Calling ZX_API_PUB.calculate_tax');
    END IF;

    ZX_API_PUB.calculate_tax
        (p_api_version           => p_api_version,
         p_init_msg_list         => p_init_msg_list,
         p_commit                => 'F',
         p_validation_level      => 1,
         x_return_status         => l_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data,
         p_transaction_rec       => l_transaction_rec,
         p_quote_flag            => 'N',
         p_data_transfer_mode    => 'PLS',
         x_doc_level_recalc_flag  => x_doc_level_recalc_flag );

    IF (G_DEBUG_LEVEL_STATEMENT >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.process_tax_determ_override.',
              'Return Status' || l_return_status);
    END IF;

    IF ( l_return_status <> OKL_API.G_RET_STS_SUCCESS ) THEN
      -- Tax Calculation Failed
      OKL_API.set_message( p_app_name      => 'OKL',
                           p_msg_name      => 'OKL_TX_TAX_ENGINE_ERR');
    END IF;

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;

    IF (G_DEBUG_LEVEL_PROCEDURE >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_DEBUG_LEVEL_PROCEDURE,'OKL_TAX_INTERFACE_PVT.process_tax_determ_override ','End(-)');
    END IF;

   EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF (l_taxsources_csr%ISOPEN) THEN
        CLOSE l_taxsources_csr;
      END IF;

      IF (l_racusttrxtypes_csr%ISOPEN) THEN
        CLOSE l_racusttrxtypes_csr;
      END IF;

      IF (l_fndcurrency_csr%ISOPEN) THEN
        CLOSE l_fndcurrency_csr;
      END IF;

      IF (G_DEBUG_LEVEL_EXCEPTION >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_EXCEPTION,'OKL_TAX_INTERFACE_PVT.process_tax_determ_override ',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_ERROR');
      END IF;

      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF (l_taxsources_csr%ISOPEN) THEN
        CLOSE l_taxsources_csr;
      END IF;

      IF (l_racusttrxtypes_csr%ISOPEN) THEN
        CLOSE l_racusttrxtypes_csr;
      END IF;

      IF (l_fndcurrency_csr%ISOPEN) THEN
        CLOSE l_fndcurrency_csr;
      END IF;

      IF (G_DEBUG_LEVEL_EXCEPTION >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_EXCEPTION,'OKL_TAX_INTERFACE_PVT.process_tax_determ_override ',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_UNEXPECTED_ERROR');
      END IF;

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      IF (l_taxsources_csr%ISOPEN) THEN
        CLOSE l_taxsources_csr;
      END IF;

      IF (l_racusttrxtypes_csr%ISOPEN) THEN
        CLOSE l_racusttrxtypes_csr;
      END IF;

      IF (l_fndcurrency_csr%ISOPEN) THEN
        CLOSE l_fndcurrency_csr;
      END IF;

      IF (G_DEBUG_LEVEL_EXCEPTION >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_EXCEPTION,'OKL_TAX_INTERFACE_PVT.process_tax_determ_override ',
                  'EXCEPTION :'||sqlerrm);
      END IF;

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      -- unexpected error
      OKL_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

  END process_tax_determ_override;

/*========================================================================
 | PUBLIC PROCEDURE process_tax_details_override
 |
 | DESCRIPTION
 |    This procedure is called by 'BOOKING', 'REBOOK' transactions to override
 |    tax details
 |
 | CALLED FROM 					OLM Tax Events
 |
 |
 | CALLS PROCEDURES/FUNCTIONS
 |       ZX_API_PUB.override_tax
 |
 | PARAMETERS
 |      p_event_id			         -- Tax Lines window will return an event id
 |                                      when there are any user overrides. It is
 |                                      this event id value that needs to be passed
 |                                      by OA Tax Override and Forms Tax Override Uis,
 |                                      to this API
 |      p_internal_organization_id   -- Organization Identifier
 |      p_trx_id                     -- Transaction Identifier
 |      p_application_id             -- Application Identifier
 |      p_entity_code                -- Entity code
 |      p_event_class_code           -- Event class code
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date          Author     Description of Changes
 | 22-FEB-07    RRAVIKIR      Created
 |
 *=======================================================================*/
  PROCEDURE process_tax_details_override(
    p_api_version           IN         NUMBER,
    p_init_msg_list         IN         VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2 ,
    x_msg_count             OUT NOCOPY NUMBER ,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_transaction_rec       IN         transaction_rec_type,
    p_override_level        IN         VARCHAR2,
    p_event_id              IN         NUMBER) IS

    l_api_version            CONSTANT NUMBER := 1;
    l_api_name               CONSTANT VARCHAR2(30) := 'process_tax_details';
    l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    x_effective_date         DATE;

    l_transaction_rec        transaction_rec_type;

  BEGIN

    IF (G_DEBUG_LEVEL_PROCEDURE >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_DEBUG_LEVEL_PROCEDURE,'OKL_TAX_INTERFACE_PVT.process_tax_details_override','Begin(+)');
    END IF;

    --Print Input Variables
    IF (G_DEBUG_LEVEL_STATEMENT >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.process_tax_details_override.',
              'p_init_msg_list :'||p_init_msg_list);
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.process_tax_details_override.',
              'p_override_level :'||to_char(p_override_level));
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.process_tax_details_override.',
              'p_event_id :'||p_event_id);
    END IF;

    -- Override Tax
    l_transaction_rec := p_transaction_rec;

    IF (G_DEBUG_LEVEL_STATEMENT >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.process_tax_details_override.',
              'Calling ZX_API_PUB.override_tax');
    END IF;

    ZX_API_PUB.override_tax
        (p_api_version           => p_api_version,
         p_init_msg_list         => p_init_msg_list,
         p_commit                => 'F',
         p_validation_level      => 1,
         x_return_status         => l_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data,
         p_transaction_rec       => l_transaction_rec,
         p_override_level        => p_override_level,
         p_event_id              => p_event_id);

    IF (G_DEBUG_LEVEL_STATEMENT >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.process_tax_details_override.',
              'Return Status' || l_return_status);
    END IF;

    IF ( l_return_status <> OKL_API.G_RET_STS_SUCCESS ) THEN
      -- oevrride tax failed
      OKL_API.set_message( p_app_name      => 'OKL',
                           p_msg_name      => 'OKL_TX_TAX_ENGINE_ERR');
    END IF;

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;

    IF (G_DEBUG_LEVEL_PROCEDURE >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_DEBUG_LEVEL_PROCEDURE,'OKL_TAX_INTERFACE_PVT.process_tax_details_override ','End(-)');
    END IF;

   EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF (G_DEBUG_LEVEL_EXCEPTION >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_EXCEPTION,'OKL_TAX_INTERFACE_PVT.process_tax_details_override ',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_ERROR');
      END IF;

      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF (G_DEBUG_LEVEL_EXCEPTION >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_EXCEPTION,'OKL_TAX_INTERFACE_PVT.process_tax_details_override ',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_UNEXPECTED_ERROR');
      END IF;

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      IF (G_DEBUG_LEVEL_EXCEPTION >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_EXCEPTION,'OKL_TAX_INTERFACE_PVT.process_tax_details_override ',
                  'EXCEPTION :'||sqlerrm);
      END IF;

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      -- unexpected error
      OKL_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

  END process_tax_details_override;

/*========================================================================
 | PUBLIC PROCEDURE copy_global_tax_data
 |
 | DESCRIPTION
 |    This procedure is called by tax module to populate tax data into ZX global
 |    session table. eBtax uses this table to show the tax data for Quote
 |    objects (Sales Quote, Lease Application and Termination Quote)
 |
 | CALLED FROM 					OLM Tax Module
 |
 |
 | CALLS PROCEDURES/FUNCTIONS
 |
 |
 | PARAMETERS
 |      p_trx_id                     -- Transaction Identifier
 |      p_trx_line_id                -- Transaction Line Identifier
 |      p_application_id             -- Application Identifier
 |      p_trx_level_type             -- Transaction level type
 |      p_entity_code                -- Entity code
 |      p_event_class_code           -- Event class code
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date          Author     Description of Changes
 | 04-APR-07    RRAVIKIR      Created
 |
 *=======================================================================*/
  PROCEDURE copy_global_tax_data (
    p_api_version                   IN NUMBER,
    p_init_msg_list                 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                 OUT NOCOPY VARCHAR2,
    x_msg_count                     OUT NOCOPY NUMBER,
    x_msg_data                      OUT NOCOPY VARCHAR2,
    p_trx_id                        IN  NUMBER,
    p_trx_line_id                   IN  NUMBER,
    p_application_id                IN  NUMBER,
    p_trx_level_type		 	    IN  VARCHAR2,
    p_entity_code			 	    IN  VARCHAR2,
    p_event_class_code              IN  VARCHAR2) IS

    -- Local variables
    l_api_version                   CONSTANT NUMBER := 1;
    l_api_name                      CONSTANT VARCHAR2(30) := 'copy_global_tax_data';

    -- Cursor to retrieve tax data
    CURSOR l_get_tax_data_csr IS
    SELECT tax_determine_date,
           tax_rate_id,
           tax_rate_code,
           taxable_amt,
           tax_exemption_id,
           tax_rate,
           tax_amt,
           tax_date,
           line_amt,
           internal_organization_id,
           application_id,
           entity_code,
           event_class_code,
           event_type_code ,
           trx_id,
           trx_line_id,
           trx_level_type,
           trx_line_number,
           tax_line_number ,
           tax_regime_id ,
           tax_regime_code ,
           tax_id,
           tax,
           tax_status_id,
           tax_status_code,
           tax_apportionment_line_number,
           legal_entity_id,
           trx_number,
           trx_date,
           tax_jurisdiction_id,
           tax_jurisdiction_code,
           tax_type_code,
           tax_currency_code ,
           taxable_amt_tax_curr,
           trx_currency_code,
           minimum_accountable_unit,
           precision,
           currency_conversion_type,
           currency_conversion_rate,
           currency_conversion_date
    FROM okl_tax_trx_details
    WHERE trx_id = p_trx_id
    AND   trx_line_id = p_trx_line_id
    AND   application_id = p_application_id
    AND   trx_level_type = p_trx_level_type
    AND   entity_code = p_entity_code
    AND   event_class_code = p_event_class_code;

  BEGIN
    IF (G_DEBUG_LEVEL_PROCEDURE >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_DEBUG_LEVEL_PROCEDURE,'OKL_TAX_INTERFACE_PVT.copy_global_tax_data','Begin(+)');
    END IF;

    --Print Input Variables
    IF (G_DEBUG_LEVEL_STATEMENT >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.copy_global_tax_data.',
              'p_init_msg_list :'||p_init_msg_list);
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.copy_global_tax_data.',
              'p_trx_id :'||p_trx_id);
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.copy_global_tax_data.',
              'p_trx_line_id :'||p_trx_line_id);
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.copy_global_tax_data.',
              'p_application_id :'||p_application_id);
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.copy_global_tax_data.',
              'p_trx_level_type :'||p_trx_level_type);
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.copy_global_tax_data.',
              'p_entity_code :'||p_entity_code);
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.copy_global_tax_data.',
              'p_event_class_code :'||p_event_class_code);
    END IF;

    -- Populate the tax data into eBtax global session table
    IF (G_DEBUG_LEVEL_STATEMENT >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.copy_global_tax_data.',
              'INSERT INTO zx_detail_tax_lines_gt');
    END IF;

    -- Clear the table before insertion
    DELETE
    FROM zx_detail_tax_lines_gt
    WHERE trx_id = p_trx_id
    AND trx_line_id = p_trx_line_id;

    FOR l_get_tax_data_rec IN l_get_tax_data_csr LOOP
      INSERT INTO zx_detail_tax_lines_gt(
           tax_line_id,
           tax_determine_date,
           tax_rate_id,
           tax_rate_code,
           taxable_amt,
           tax_exemption_id,
           tax_rate,
           tax_amt,
           tax_date,
           line_amt,
           internal_organization_id,
           application_id,
           entity_code,
           event_class_code,
           event_type_code ,
           trx_id,
           trx_line_id,
           trx_level_type,
           trx_line_number,
           tax_line_number ,
           tax_regime_id ,
           tax_regime_code ,
           tax_id,
           tax,
           tax_status_id,
           tax_status_code,
           tax_apportionment_line_number,
           legal_entity_id,
           trx_number,
           trx_date,
           tax_jurisdiction_id,
           tax_jurisdiction_code,
           tax_type_code,
           tax_currency_code ,
           taxable_amt_tax_curr,
           trx_currency_code,
           minimum_accountable_unit,
           precision,
           currency_conversion_type,
           currency_conversion_rate,
           currency_conversion_date,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           object_version_number) VALUES
           (
           zx_lines_s.nextval,
           l_get_tax_data_rec.tax_determine_date,
           l_get_tax_data_rec.tax_rate_id,
           l_get_tax_data_rec.tax_rate_code,
           l_get_tax_data_rec.taxable_amt,
           l_get_tax_data_rec.tax_exemption_id,
           l_get_tax_data_rec.tax_rate,
           l_get_tax_data_rec.tax_amt,
           l_get_tax_data_rec.tax_date,
           l_get_tax_data_rec.line_amt,
           l_get_tax_data_rec.internal_organization_id,
           l_get_tax_data_rec.application_id,
           l_get_tax_data_rec.entity_code,
           l_get_tax_data_rec.event_class_code,
           l_get_tax_data_rec.event_type_code ,
           l_get_tax_data_rec.trx_id,
           l_get_tax_data_rec.trx_line_id,
           l_get_tax_data_rec.trx_level_type,
           l_get_tax_data_rec.trx_line_number,
           l_get_tax_data_rec.tax_line_number ,
           l_get_tax_data_rec.tax_regime_id ,
           l_get_tax_data_rec.tax_regime_code ,
           l_get_tax_data_rec.tax_id,
           l_get_tax_data_rec.tax,
           l_get_tax_data_rec.tax_status_id,
           l_get_tax_data_rec.tax_status_code,
           l_get_tax_data_rec.tax_apportionment_line_number,
           l_get_tax_data_rec.legal_entity_id,
           l_get_tax_data_rec.trx_number,
           l_get_tax_data_rec.trx_date,
           l_get_tax_data_rec.tax_jurisdiction_id,
           l_get_tax_data_rec.tax_jurisdiction_code,
           l_get_tax_data_rec.tax_type_code,
           l_get_tax_data_rec.tax_currency_code,
           l_get_tax_data_rec.taxable_amt_tax_curr,
           l_get_tax_data_rec.trx_currency_code,
           l_get_tax_data_rec.minimum_accountable_unit,
           l_get_tax_data_rec.precision,
           l_get_tax_data_rec.currency_conversion_type,
           l_get_tax_data_rec.currency_conversion_rate,
           l_get_tax_data_rec.currency_conversion_date,
           G_USER_ID,
           SYSDATE,
           G_USER_ID,
           SYSDATE,
           G_LOGIN_ID,
           1);
    END LOOP;

    IF (G_DEBUG_LEVEL_STATEMENT >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.copy_global_tax_data.',
              'Return Status' || x_return_status);
    END IF;

    IF (G_DEBUG_LEVEL_PROCEDURE >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_DEBUG_LEVEL_PROCEDURE,'OKL_TAX_INTERFACE_PVT.copy_global_tax_data ','End(-)');
    END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF (G_DEBUG_LEVEL_EXCEPTION >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_EXCEPTION,'OKL_TAX_INTERFACE_PVT.copy_global_tax_data ',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_ERROR');
      END IF;

      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF (G_DEBUG_LEVEL_EXCEPTION >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_EXCEPTION,'OKL_TAX_INTERFACE_PVT.copy_global_tax_data ',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_UNEXPECTED_ERROR');
      END IF;

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN

      IF (G_DEBUG_LEVEL_EXCEPTION >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_EXCEPTION,'OKL_TAX_INTERFACE_PVT.copy_global_tax_data ',
                  'EXCEPTION :'||sqlerrm);
      END IF;

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      -- unexpected error
      OKL_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

  END copy_global_tax_data;

/*========================================================================
 | PUBLIC PROCEDURE update_document
 |
 | DESCRIPTION
 |    This procedure is called by billing and disbursement modules to fetch tax
 |    determinants
 |
 | CALLED FROM
 |
 |
 | CALLS PROCEDURES/FUNCTIONS
 |       ZX_API_PUB.global_document_update
 |
 | PARAMETERS
 |      p_source_trx_id		- ID of Pre-Rebook or Rebook transaction in okl_trx_contracts
 |      p_source_trx_name  - Pre-Rebook or Rebook
 |      p_source_table      - OKL_TRX_CONTRACTS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date          Author     Description of Changes
 | 01-MAR-07    RRAVIKIR      Created
 |
 *=======================================================================*/
  PROCEDURE update_document (
    p_api_version                   IN NUMBER,
    p_init_msg_list                 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                 OUT NOCOPY VARCHAR2,
    x_msg_count                     OUT NOCOPY NUMBER,
    x_msg_data                      OUT NOCOPY VARCHAR2,
    p_transaction_rec               transaction_rec_type) IS

    -- Local variables
    l_api_version                   CONSTANT NUMBER := 1;
    l_api_name                      CONSTANT VARCHAR2(30) := 'update_document';
    l_return_status                 VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    -- Local dats structure
    l_transaction_rec               transaction_rec_type;

  BEGIN
    IF (G_DEBUG_LEVEL_PROCEDURE >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_DEBUG_LEVEL_PROCEDURE,'OKL_TAX_INTERFACE_PVT.update_document','Begin(+)');
    END IF;

    --Print Input Variables
    IF (G_DEBUG_LEVEL_STATEMENT >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.update_document.',
              'p_init_msg_list :'||p_init_msg_list);
    END IF;

    l_transaction_rec := p_transaction_rec;

    IF (G_DEBUG_LEVEL_STATEMENT >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.update_document.',
              'Calling ZX_API_PUB.global_document_update');
    END IF;

    ZX_API_PUB.global_document_update(p_api_version           => p_api_version,
                                      p_init_msg_list         => p_init_msg_list,
                                      p_commit                => 'F' ,
                                      p_validation_level      => 1,
                                      x_return_status         => l_return_status,
                                      x_msg_count             => x_msg_count,
                                      x_msg_data              => x_msg_data,
                                      p_transaction_rec       => l_transaction_rec);

    IF (G_DEBUG_LEVEL_STATEMENT >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.update_document.',
              'Return Status' || l_return_status);
    END IF;

    IF ( l_return_status <> OKL_API.G_RET_STS_SUCCESS ) THEN
      -- update document failed
      OKL_API.set_message( p_app_name      => 'OKL',
                           p_msg_name      => 'OKL_TX_CANCEL_TAX_ERR');
    END IF;

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;

    IF (G_DEBUG_LEVEL_PROCEDURE >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_DEBUG_LEVEL_PROCEDURE,'OKL_TAX_INTERFACE_PVT.update_document ','End(-)');
    END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF (G_DEBUG_LEVEL_EXCEPTION >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_EXCEPTION,'OKL_TAX_INTERFACE_PVT.update_document ',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_ERROR');
      END IF;

      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF (G_DEBUG_LEVEL_EXCEPTION >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_EXCEPTION,'OKL_TAX_INTERFACE_PVT.update_document ',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_UNEXPECTED_ERROR');
      END IF;

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      IF (G_DEBUG_LEVEL_EXCEPTION >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_EXCEPTION,'OKL_TAX_INTERFACE_PVT.update_document ',
                  'EXCEPTION :'||sqlerrm);
      END IF;

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      -- unexpected error
      OKL_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

  END update_document;

/*========================================================================
 | PUBLIC PROCEDURE reverse_document
 |
 | DESCRIPTION
 |    This procedure is called by tax module to populate tax data for reverse
 |    contract into ZX reverse transactions table.
 |
 | CALLED FROM 			OKL_PROCESS_SALES_TAX_PVT.process_contract_reversal_tax
 |
 |
 | CALLS PROCEDURES/FUNCTIONS
 |       ZX_API_PUB.reverse_document
 |
 | PARAMETERS
 |      p_source_trx_id              -- Transaction Identifier
 |      p_org_id                     -- Organization Identifier
 |      p_legal_entity_id            -- Legal Entity Identifier
 |      p_tax_data_tbl               -- ZX reverse transactions table
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | Date          Author     Description of Changes
 | 12-APR-07    RRAVIKIR      Created
 |
 *=======================================================================*/
  PROCEDURE reverse_document (
    p_api_version                   IN NUMBER,
    p_init_msg_list                 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                 OUT NOCOPY VARCHAR2,
    x_msg_count                     OUT NOCOPY NUMBER,
    x_msg_data                      OUT NOCOPY VARCHAR2,
    p_rev_trx_hdr_rec               IN  line_params_rec_type,
    p_rev_trx_lines_tbl             IN  zx_trx_lines_tbl_type) IS

    -- Local variables
    l_api_version                   CONSTANT NUMBER := 1;
    l_api_name                      CONSTANT VARCHAR2(30) := 'reverse_document';
    l_return_status                 VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    -- Local data structure
    l_rev_trx_lines_tbl             zx_trx_lines_tbl_type;
    k                               NUMBER;

  BEGIN
    IF (G_DEBUG_LEVEL_PROCEDURE >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_DEBUG_LEVEL_PROCEDURE,'OKL_TAX_INTERFACE_PVT.reverse_document','Begin(+)');
    END IF;

    --Print Input Variables
    IF (G_DEBUG_LEVEL_STATEMENT >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.reverse_document.',
              'p_init_msg_list :'||p_init_msg_list);
    END IF;

    -- Populate the tax data into eBtax reverse transaction table
    IF (G_DEBUG_LEVEL_STATEMENT >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.reverse_document.',
              'INSERT INTO zx_rev_trx_headers_gt');
    END IF;

    -- Populate ZX reverse transaction header table
    INSERT INTO zx_rev_trx_headers_gt(internal_organization_id,
	                                  reversing_appln_id,
	                                  reversing_entity_code,
	                                  reversing_evnt_cls_code,
	                                  reversing_trx_id,
	                                  legal_entity_id)
	VALUES
	(p_rev_trx_hdr_rec.internal_organization_id,
	 p_rev_trx_hdr_rec.application_id,
	 p_rev_trx_hdr_rec.entity_code,
	 p_rev_trx_hdr_rec.event_class_code,
	 p_rev_trx_hdr_rec.trx_id,
	 p_rev_trx_hdr_rec.legal_entity_id);

    IF (G_DEBUG_LEVEL_STATEMENT >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.reverse_document.',
              'INSERT INTO zx_reverse_trx_lines_gt');
    END IF;

    -- Populate ZX reverse transaction lines table
    l_rev_trx_lines_tbl := p_rev_trx_lines_tbl;
    IF l_rev_trx_lines_tbl.COUNT > 0 THEN
      FOR k IN l_rev_trx_lines_tbl.FIRST..l_rev_trx_lines_tbl.LAST LOOP
        INSERT INTO ZX_REVERSE_TRX_LINES_GT(internal_organization_id,
                                            reversing_appln_id,
                                            reversing_entity_code,
                                            reversing_evnt_cls_code,
                                            reversing_trx_id,
                                            reversing_trx_level_type,
                                            reversing_trx_line_id,
                                            reversed_appln_id,
                                            reversed_entity_code,
                                            reversed_evnt_cls_code,
                                            reversed_trx_id,
                                            reversed_trx_level_type,
                                            reversed_trx_line_id)
        VALUES
       (l_rev_trx_lines_tbl(k).internal_organization_id,
        l_rev_trx_lines_tbl(k).reversing_appln_id,
        l_rev_trx_lines_tbl(k).reversing_entity_code,
        l_rev_trx_lines_tbl(k).reversing_evnt_cls_code,
        l_rev_trx_lines_tbl(k).reversing_trx_id,
        l_rev_trx_lines_tbl(k).reversing_trx_level_type,
        l_rev_trx_lines_tbl(k).reversing_trx_line_id,
        l_rev_trx_lines_tbl(k).reversed_appln_id,
        l_rev_trx_lines_tbl(k).reversed_entity_code,
        l_rev_trx_lines_tbl(k).reversed_evnt_cls_code,
        l_rev_trx_lines_tbl(k).reversed_trx_id,
        l_rev_trx_lines_tbl(k).reversed_trx_level_type,
        l_rev_trx_lines_tbl(k).reversed_trx_line_id );
      END LOOP;
    END IF;

    IF (G_DEBUG_LEVEL_STATEMENT >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.reverse_document.',
              'Return Status' || l_return_status);
    END IF;

    -- call ZX reverse document api -- start
    IF (G_DEBUG_LEVEL_STATEMENT >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.reverse_document.',
              'Calling ZX_API_PUB.reverse_document');
    END IF;

    ZX_API_PUB.reverse_document
      (p_api_version        => p_api_version,
       p_init_msg_list      => p_init_msg_list,
       p_commit             => 'F',
       p_validation_level   => 1,
       x_return_status      => l_return_status,
       x_msg_count          => x_msg_count,
       x_msg_data           => x_msg_data);

    IF (G_DEBUG_LEVEL_STATEMENT >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_STATEMENT,'OKL_TAX_INTERFACE_PVT.reverse_document.',
              'Return Status' || l_return_status);
    END IF;

    IF ( l_return_status <> OKL_API.G_RET_STS_SUCCESS ) THEN
      -- reverse document failed
      OKL_API.set_message( p_app_name      => 'OKL',
                           p_msg_name      => 'OKL_TX_REVERSE_DOC_ERR');
    END IF;

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- call ZX reverse document api -- end

    x_return_status := l_return_status;

    IF (G_DEBUG_LEVEL_PROCEDURE >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_DEBUG_LEVEL_PROCEDURE,'OKL_TAX_INTERFACE_PVT.reverse_document ','End(-)');
    END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF (G_DEBUG_LEVEL_EXCEPTION >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_EXCEPTION,'OKL_TAX_INTERFACE_PVT.reverse_document ',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_ERROR');
      END IF;

      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF (G_DEBUG_LEVEL_EXCEPTION >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_EXCEPTION,'OKL_TAX_INTERFACE_PVT.reverse_document ',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_UNEXPECTED_ERROR');
      END IF;

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      IF (G_DEBUG_LEVEL_EXCEPTION >= G_DEBUG_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_DEBUG_LEVEL_EXCEPTION,'OKL_TAX_INTERFACE_PVT.reverse_document ',
                  'EXCEPTION :'||sqlerrm);
      END IF;

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      -- unexpected error
      OKL_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);

  END reverse_document;

END OKL_TAX_INTERFACE_PVT;

/
