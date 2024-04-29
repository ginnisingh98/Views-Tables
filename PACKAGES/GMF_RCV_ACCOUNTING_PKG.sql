--------------------------------------------------------
--  DDL for Package GMF_RCV_ACCOUNTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_RCV_ACCOUNTING_PKG" AUTHID CURRENT_USER AS
/* $Header: gmfrcvas.pls 120.0.12010000.2 2009/08/17 19:29:27 pmarada ship $ */

  RECEIVE                         CONSTANT  NUMBER  := 1;
  DELIVER                         CONSTANT  NUMBER  := 2;
  CORRECT                         CONSTANT  NUMBER  := 3;
  MATCH                           CONSTANT  NUMBER  := 4;
  RETURN_TO_RECEIVING             CONSTANT  NUMBER  := 5;
  RETURN_TO_VENDOR                CONSTANT  NUMBER  := 6;
  ADJUST_RECEIVE                  CONSTANT  NUMBER  := 7;
  ADJUST_DELIVER                  CONSTANT  NUMBER  := 8;
  LOGICAL_RECEIVE                 CONSTANT  NUMBER  := 9;
  LOGICAL_RETURN_TO_VENDOR        CONSTANT  NUMBER  := 10;
  INTERCOMPANY_INVOICE            CONSTANT  NUMBER  := 11;
  INTERCOMPANY_REVERSAL           CONSTANT  NUMBER  := 12;
  ENCUMBRANCE_REVERSAL            CONSTANT  NUMBER  := 13;

  TYPE rcv_accttxn_rec_type is RECORD
  (
  event_type_id                 NUMBER,
  event_source                  VARCHAR2(25),
  rcv_transaction_id            NUMBER          := NULL,
  direct_delivery_flag          VARCHAR2(1)     := 'N',
  inv_distribution_id           NUMBER          := NULL,
  transaction_date              DATE            := sysdate,
  po_header_id                  NUMBER          := NULL,
  po_release_id                 NUMBER          := NULL,
  po_line_id                    NUMBER          := NULL,
  po_line_location_id           NUMBER          := NULL,
  po_distribution_id            NUMBER          := NULL,
  trx_flow_header_id            NUMBER          := NULL,
  ledger_id                     NUMBER          := NULL,
  org_id                        NUMBER          := NULL,
  transfer_org_id               NUMBER          := NULL,
  organization_id               NUMBER          := NULL,
  transfer_organization_id      NUMBER          := NULL,
  item_id                       NUMBER          := NULL,
  unit_price                    NUMBER          := NULL,
  unit_nr_tax                   NUMBER          := NULL,
  unit_rec_tax                  NUMBER          := NULL,
  prior_unit_price              NUMBER          := NULL,
  prior_nr_tax                  NUMBER          := NULL,
  prior_rec_tax                 NUMBER          := NULL,
  intercompany_pricing_option   NUMBER          := 1,
  service_flag                  VARCHAR2(1)     := 'N',
  transaction_amount            NUMBER          := NULL,
  currency_code                 VARCHAR2(15)    := NULL,
  currency_conversion_type      VARCHAR2(30)    := NULL,
  currency_conversion_rate      NUMBER          := 1,
  currency_conversion_date      DATE            := sysdate,
  intercompany_price            NUMBER          := NULL,
  intercompany_curr_code        VARCHAR2(15)    := NULL,
  transaction_uom               VARCHAR2(25)    := NULL,
  trx_uom_code                  VARCHAR2(3)     := NULL,
  transaction_quantity          NUMBER          := NULL,
  primary_uom                   VARCHAR2(25)    := NULL,
  primary_quantity              NUMBER          := NULL,
  source_doc_uom                VARCHAR2(25)    := NULL,
  source_doc_quantity           NUMBER          := NULL,
  destination_type_code         VARCHAR2(25)    := NULL,
  cross_ou_flag                 VARCHAR2(1)     := 'N',
  procurement_org_flag          VARCHAR2(1)     := 'N',
  ship_to_org_flag              VARCHAR2(1)     := 'N',
  drop_ship_flag                NUMBER          := 0,
  debit_account_id              NUMBER          := NULL,
  credit_account_id             NUMBER          := NULL,
  intercompany_cogs_account_id  NUMBER          := NULL,
  ussgl_transaction_code        VARCHAR2(30)    := NULL,
  gl_group_id                   NUMBER          := NULL,
  /* start LCM-OPM Integration  */
  unit_landed_cost              NUMBER          := NULL
  /* end LCM-OPM Integration  */
  );

  TYPE rcv_accttxn_tbl_type is TABLE OF rcv_accttxn_rec_type INDEX BY BINARY_INTEGER;

  PROCEDURE CREATE_ACCOUNTING_TXNS
  (
  p_api_version                 IN          NUMBER,
  p_init_msg_list               IN          VARCHAR2,
  p_commit                      IN          VARCHAR2,
  p_validation_level            IN          NUMBER,
  x_return_status               OUT NOCOPY  VARCHAR2,
  x_msg_count                   OUT NOCOPY  NUMBER,
  x_msg_data                    OUT NOCOPY  VARCHAR2,
  p_source_type                 IN VARCHAR2,
  p_rcv_transaction_id          IN          NUMBER,
  p_direct_delivery_flag        IN          VARCHAR2
  );

  PROCEDURE CREATE_ADJUST_TXNS
  (
  p_api_version                 IN          NUMBER,
  p_init_msg_list               IN          VARCHAR2,
  p_commit                      IN          VARCHAR2,
  p_validation_level            IN          NUMBER,
  x_return_status               OUT NOCOPY  VARCHAR2,
  x_msg_count                   OUT NOCOPY  NUMBER,
  x_msg_data                    OUT NOCOPY  VARCHAR2,
  p_po_header_id                IN          NUMBER,
  p_po_release_id               IN          NUMBER,
  p_po_line_id                  IN          NUMBER,
  p_po_line_location_id         IN          NUMBER,
  p_old_po_price                IN          NUMBER,
  p_new_po_price                IN          NUMBER
  );
END GMF_RCV_ACCOUNTING_PKG;

/
