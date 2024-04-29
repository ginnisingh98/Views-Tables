--------------------------------------------------------
--  DDL for Package JAI_RCV_TRANSACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_RCV_TRANSACTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_rcv_trx.pls 120.1.12010000.2 2010/04/15 11:01:45 boboli ship $ */

PROCEDURE insert_row(
  p_shipment_header_id        IN JAI_RCV_TRANSACTIONS.SHIPMENT_HEADER_ID%TYPE,
  p_shipment_line_id          IN JAI_RCV_TRANSACTIONS.SHIPMENT_LINE_ID%TYPE,
  p_transaction_id            IN JAI_RCV_TRANSACTIONS.TRANSACTION_ID%TYPE,
  p_transaction_date          IN JAI_RCV_TRANSACTIONS.TRANSACTION_DATE%TYPE,
  p_transaction_type          IN JAI_RCV_TRANSACTIONS.TRANSACTION_TYPE%TYPE,
  p_quantity                  IN JAI_RCV_TRANSACTIONS.QUANTITY%TYPE,
  p_uom_code                  IN JAI_RCV_TRANSACTIONS.UOM_CODE%TYPE,
  p_parent_transaction_id     IN JAI_RCV_TRANSACTIONS.PARENT_TRANSACTION_ID%TYPE,
  p_parent_transaction_type   IN JAI_RCV_TRANSACTIONS.PARENT_TRANSACTION_TYPE%TYPE,
  p_destination_type_code     IN JAI_RCV_TRANSACTIONS.destination_type_code%TYPE,
  p_receipt_num               IN JAI_RCV_TRANSACTIONS.RECEIPT_NUM%TYPE,
  p_organization_id           IN JAI_RCV_TRANSACTIONS.ORGANIZATION_ID%TYPE,
  p_location_id               IN JAI_RCV_TRANSACTIONS.LOCATION_ID%TYPE,
  p_inventory_item_id         IN JAI_RCV_TRANSACTIONS.INVENTORY_ITEM_ID%TYPE,
  p_excise_invoice_no         IN JAI_RCV_TRANSACTIONS.excise_invoice_no%TYPE,
  p_excise_invoice_date       IN JAI_RCV_TRANSACTIONS.excise_invoice_date%TYPE,
  p_tax_amount                IN JAI_RCV_TRANSACTIONS.tax_amount%TYPE,
  p_assessable_value          IN JAI_RCV_TRANSACTIONS.assessable_value%TYPE,
  p_currency_conversion_rate  IN JAI_RCV_TRANSACTIONS.currency_conversion_rate%TYPE,
  p_item_class                IN JAI_RCV_TRANSACTIONS.ITEM_CLASS%TYPE,
  p_item_cenvatable           IN JAI_RCV_TRANSACTIONS.ITEM_cenvatABLE%TYPE,
  p_item_excisable            IN JAI_RCV_TRANSACTIONS.ITEM_EXCISABLE%TYPE,
  p_item_trading_flag         IN JAI_RCV_TRANSACTIONS.ITEM_TRADING_FLAG%TYPE,
  p_inv_item_flag             IN JAI_RCV_TRANSACTIONS.INV_ITEM_FLAG%TYPE,
  p_inv_asset_flag            IN JAI_RCV_TRANSACTIONS.INV_ASSET_FLAG%TYPE,
  p_loc_subinv_type           IN JAI_RCV_TRANSACTIONS.LOC_SUBINV_TYPE%TYPE,
  p_base_subinv_asset_flag    IN JAI_RCV_TRANSACTIONS.BASE_asset_inventory%TYPE,
  p_organization_type         IN JAI_RCV_TRANSACTIONS.ORGANIZATION_TYPE%TYPE,
  p_excise_in_trading         IN JAI_RCV_TRANSACTIONS.EXCISE_IN_TRADING%TYPE,
  p_costing_method            IN JAI_RCV_TRANSACTIONS.COSTING_METHOD%TYPE,
  p_boe_applied_flag          IN JAI_RCV_TRANSACTIONS.BOE_APPLIED_FLAG%TYPE,
  p_third_party_flag          IN JAI_RCV_TRANSACTIONS.THIRD_PARTY_FLAG%TYPE,
  --Added new parametersby Bo Li for bug9305067
  --remove the old attribute parameters   Begin
  -----------------------------------------------------------------------------
  p_trx_information           IN JAI_RCV_TRANSACTIONS.TRX_INFORMATION%TYPE,
  p_excise_inv_gen_status     IN JAI_RCV_TRANSACTIONS.EXCISE_INV_GEN_STATUS%TYPE,
  p_vat_inv_gen_status        IN JAI_RCV_TRANSACTIONS.VAT_INV_GEN_STATUS%TYPE,
  p_excise_inv_gen_number     IN JAI_RCV_TRANSACTIONS.EXCISE_INV_GEN_NUMBER%TYPE,
  p_vat_inv_gen_number        IN JAI_RCV_TRANSACTIONS.VAT_INV_GEN_NUMBER%TYPE,
  p_cenvat_costed_flag	      IN JAI_RCV_TRANSACTIONS.CENVAT_COSTED_FLAG%TYPE,
  -----------------------------------------------------------------------------
  --Added new parametersby Bo Li for bug9305067
  --remove the old attribute parameters   End
  p_tax_transaction_id        IN JAI_RCV_TRANSACTIONS.tax_transaction_id%TYPE     -- Vijay Shankar for Bug#3940588
);

PROCEDURE update_row(
  p_transaction_id            IN JAI_RCV_TRANSACTIONS.TRANSACTION_ID%TYPE,
  p_parent_transaction_type   IN JAI_RCV_TRANSACTIONS.PARENT_TRANSACTION_TYPE%TYPE   DEFAULT NULL,
  p_receipt_num               IN JAI_RCV_TRANSACTIONS.RECEIPT_NUM%TYPE               DEFAULT NULL,
  p_organization_id           IN JAI_RCV_TRANSACTIONS.ORGANIZATION_ID%TYPE           DEFAULT NULL,
  p_location_id               IN JAI_RCV_TRANSACTIONS.LOCATION_ID%TYPE               DEFAULT NULL,
  p_inventory_item_id         IN JAI_RCV_TRANSACTIONS.INVENTORY_ITEM_ID%TYPE         DEFAULT NULL,
  p_excise_invoice_no         IN JAI_RCV_TRANSACTIONS.excise_invoice_no%TYPE         DEFAULT NULL,
  p_excise_invoice_date       IN JAI_RCV_TRANSACTIONS.excise_invoice_date%TYPE       DEFAULT NULL,
  p_tax_amount                IN JAI_RCV_TRANSACTIONS.tax_amount%TYPE                DEFAULT NULL,
  p_assessable_value          IN JAI_RCV_TRANSACTIONS.assessable_value%TYPE          DEFAULT NULL,
  p_cenvat_amount             IN JAI_RCV_TRANSACTIONS.cenvat_amount%TYPE             DEFAULT NULL,
  p_currency_conversion_rate  IN JAI_RCV_TRANSACTIONS.currency_conversion_rate%TYPE  DEFAULT NULL,
  p_item_class                IN JAI_RCV_TRANSACTIONS.ITEM_CLASS%TYPE                DEFAULT NULL,
  p_item_cenvatable           IN JAI_RCV_TRANSACTIONS.ITEM_cenvatABLE%TYPE           DEFAULT NULL,
  p_item_excisable            IN JAI_RCV_TRANSACTIONS.ITEM_EXCISABLE%TYPE            DEFAULT NULL,
  p_item_trading_flag         IN JAI_RCV_TRANSACTIONS.ITEM_TRADING_FLAG%TYPE         DEFAULT NULL,
  p_inv_item_flag             IN JAI_RCV_TRANSACTIONS.INV_ITEM_FLAG%TYPE             DEFAULT NULL,
  p_inv_asset_flag            IN JAI_RCV_TRANSACTIONS.INV_ASSET_FLAG%TYPE            DEFAULT NULL,
  p_loc_subinv_type           IN JAI_RCV_TRANSACTIONS.LOC_SUBINV_TYPE%TYPE           DEFAULT NULL,
  p_base_subinv_asset_flag    IN JAI_RCV_TRANSACTIONS.BASE_asset_inventory%TYPE    DEFAULT NULL,
  p_organization_type         IN JAI_RCV_TRANSACTIONS.ORGANIZATION_TYPE%TYPE         DEFAULT NULL,
  p_excise_in_trading         IN JAI_RCV_TRANSACTIONS.EXCISE_IN_TRADING%TYPE         DEFAULT NULL,
  p_costing_method            IN JAI_RCV_TRANSACTIONS.COSTING_METHOD%TYPE            DEFAULT NULL,
  p_boe_applied_flag          IN JAI_RCV_TRANSACTIONS.BOE_APPLIED_FLAG%TYPE          DEFAULT NULL,
  p_third_party_flag          IN JAI_RCV_TRANSACTIONS.THIRD_PARTY_FLAG%TYPE          DEFAULT NULL,
   --Added new parametersby Bo Li for bug9305067
  --remove the old attribute parameters   Begin
  -----------------------------------------------------------------------------
  p_trx_information           IN JAI_RCV_TRANSACTIONS.TRX_INFORMATION%TYPE          DEFAULT NULL,
  p_excise_inv_gen_status     IN JAI_RCV_TRANSACTIONS.EXCISE_INV_GEN_STATUS%TYPE    DEFAULT NULL,
  p_vat_inv_gen_status        IN JAI_RCV_TRANSACTIONS.VAT_INV_GEN_STATUS%TYPE       DEFAULT NULL,
  p_excise_inv_gen_number     IN JAI_RCV_TRANSACTIONS.EXCISE_INV_GEN_NUMBER%TYPE    DEFAULT NULL,
  p_vat_inv_gen_number        IN JAI_RCV_TRANSACTIONS.VAT_INV_GEN_NUMBER%TYPE       DEFAULT NULL,
  p_cenvat_costed_flag	      IN JAI_RCV_TRANSACTIONS.CENVAT_COSTED_FLAG%TYPE       DEFAULT NULL,
  -----------------------------------------------------------------------------
  --Added new parametersby Bo Li for bug9305067
  --remove the old attribute parameters   End
  p_tax_transaction_id        IN JAI_RCV_TRANSACTIONS.tax_transaction_id%TYPE        DEFAULT NULL,   -- Vijay Shankar for Bug#3940588
  p_tax_apportion_factor			IN JAI_RCV_TRANSACTIONS.tax_apportion_factor%TYPE      DEFAULT NULL    -- Added by Sanjikum for Bug#4495135
);

PROCEDURE update_process_flags(
  p_transaction_id      IN JAI_RCV_TRANSACTIONS.transaction_id%TYPE,
  p_process_flag        IN JAI_RCV_TRANSACTIONS.PROCESS_status%TYPE,
  p_process_message     IN JAI_RCV_TRANSACTIONS.PROCESS_MESSAGE%TYPE,
  p_cenvat_rg_flag      IN JAI_RCV_TRANSACTIONS.CENVAT_RG_STATUS%TYPE,
  p_cenvat_claimed_ptg  IN JAI_RCV_TRANSACTIONS.CENVAT_claimed_ptg%TYPE  DEFAULT NULL  ,
  p_cenvat_rg_message   IN JAI_RCV_TRANSACTIONS.CENVAT_RG_MESSAGE%TYPE,
  p_process_date        IN JAI_RCV_TRANSACTIONS.PROCESS_DATE%TYPE,
  /* following two parameters introduced by Vijay Shankar for Bug#4250236(4245089). VAT Impl. */
  p_process_vat_flag    IN JAI_RCV_TRANSACTIONS.PROCESS_VAT_STATUS%TYPE     ,
  p_process_vat_message IN JAI_RCV_TRANSACTIONS.PROCESS_VAT_MESSAGE%TYPE
);

PROCEDURE update_excise_invoice_no(
  p_transaction_id            IN NUMBER,
  p_excise_invoice_no         IN JAI_RCV_TRANSACTIONS.excise_invoice_no%TYPE,
  p_excise_invoice_date       IN JAI_RCV_TRANSACTIONS.excise_invoice_date%TYPE
);

PROCEDURE update_attributes(
  p_transaction_id      IN JAI_RCV_TRANSACTIONS.transaction_id%TYPE,
  p_attribute_category        IN JAI_RCV_TRANSACTIONS.ATTRIBUTE_CATEGORY%TYPE        DEFAULT NULL,
  p_attribute1                IN JAI_RCV_TRANSACTIONS.ATTRIBUTE1%TYPE                DEFAULT NULL,
  p_attribute2                IN JAI_RCV_TRANSACTIONS.ATTRIBUTE2%TYPE                DEFAULT NULL,
  p_attribute3                IN JAI_RCV_TRANSACTIONS.ATTRIBUTE3%TYPE                DEFAULT NULL,
  p_attribute4                IN JAI_RCV_TRANSACTIONS.ATTRIBUTE4%TYPE                DEFAULT NULL,
  p_attribute5                IN JAI_RCV_TRANSACTIONS.ATTRIBUTE5%TYPE                DEFAULT NULL,
  p_attribute6                IN JAI_RCV_TRANSACTIONS.ATTRIBUTE6%TYPE                DEFAULT NULL,
  p_attribute7                IN JAI_RCV_TRANSACTIONS.ATTRIBUTE7%TYPE                DEFAULT NULL,
  p_attribute8                IN JAI_RCV_TRANSACTIONS.ATTRIBUTE8%TYPE                DEFAULT NULL,
  p_attribute9                IN JAI_RCV_TRANSACTIONS.ATTRIBUTE9%TYPE                DEFAULT NULL,
  p_attribute10               IN JAI_RCV_TRANSACTIONS.ATTRIBUTE10%TYPE               DEFAULT NULL
);

--==========================================================================
--  PROCEDURE NAME:
--    update_inv_stat_and_no                        Public
--
--  DESCRIPTION:
--    This procedure is written for replace the update_attributes procedure
--
--  ER NAME/BUG#
--    Enable DFF Batch2
--    Bug bug9305067
--
--  PARAMETERS:
--      In:   p_transaction_id               Identifier of transaction
--            p_trx_information              Trx Information
--            p_excise_inv_gen_status        Excise invoice generation status
--            p_vat_inv_gen_status           Vat invoice generation status
--            p_excise_inv_gen_number        Excise invoice generation number
--            p_vat_inv_gen_number           Vat invoice generation number
--
--
--  DESIGN REFERENCES:
--       TD named "TDD_1213_JAI_Enhanced_DFF.doc"
--
--  CALL FROM
--
--  CHANGE HISTORY:
--  15-Apr-2010                Created by Bo Li
--==========================================================================
 PROCEDURE update_inv_stat_and_no (
    p_transaction_id          IN JAI_RCV_TRANSACTIONS.transaction_id%TYPE,
    p_trx_information          IN JAI_RCV_TRANSACTIONS.TRX_INFORMATION%TYPE DEFAULT NULL,
    p_excise_inv_gen_status    IN JAI_RCV_TRANSACTIONS.EXCISE_INV_GEN_STATUS%TYPE DEFAULT NULL,
    p_vat_inv_gen_status        IN JAI_RCV_TRANSACTIONS.VAT_INV_GEN_STATUS%TYPE DEFAULT NULL,
    p_excise_inv_gen_number    IN JAI_RCV_TRANSACTIONS.EXCISE_INV_GEN_NUMBER%TYPE DEFAULT NULL,
    p_vat_inv_gen_number      IN JAI_RCV_TRANSACTIONS.VAT_INV_GEN_NUMBER%TYPE DEFAULT NULL
  );

--==========================================================================
--  PROCEDURE NAME:
--    update_cenvat_costed_flag                        Public
--
--  DESCRIPTION:
--    This procedure is written for replace the update_attributes procedure
--
--  ER NAME/BUG#
--    Enable DFF Batch2
--    Bug bug9305067
--
--  PARAMETERS:
--      In:   p_transaction_id               Identifier of transaction
--            p_cenvat_costed_flag           CENVAT costed Flag

--
--
--  DESIGN REFERENCES:
--       TD named "TDD_1213_JAI_Enhanced_DFF.doc"
--
--  CALL FROM
--
--  CHANGE HISTORY:
--  15-Apr-2010                Created by Bo Li
--==========================================================================
   PROCEDURE update_cenvat_costed_flag (
    p_transaction_id      IN JAI_RCV_TRANSACTIONS.transaction_id%TYPE,
    p_cenvat_costed_flag          IN JAI_RCV_TRANSACTIONS.CENVAT_COSTED_FLAG%TYPE DEFAULT NULL
  );



END jai_rcv_transactions_pkg;

/
