--------------------------------------------------------
--  DDL for Package Body JAI_RCV_TRANSACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_RCV_TRANSACTIONS_PKG" AS
/* $Header: jai_rcv_trx.plb 120.1.12010000.2 2010/04/15 11:03:01 boboli ship $ */
/*----------------------------------------------------------------------------------------------------------------------------
CHANGE HISTORY for FILENAME: jai_rcv_transactions_pkg.sql
S.No  dd/mm/yyyy   Author and Details
------------------------------------------------------------------------------------------------------------------------------
1     16/07/2004   Vijay Shankar for Bug# 3496408, Version:115.0
                    Table handler Package for JAI_RCV_TRANSACTIONS table

2     03/01/2005   Vijay Shankar for Bug# 3940588, Version:115.1
                    Added tax_transaction_id for JAI_RCV_TRANSACTIONS table. as a result of the change, we added the corresponding
                    parameters in insert_row and update_row procedures

3     19/03/2005   Vijay Shankar for Bug#4250236(4245089). FileVersion: 115.2
                    added two more parameters in update_process_flags procedure as part of VAT Implementation to update
                    process_vat_flag and related message

4. 08-Jun-2005  Version 116.1 jai_rcv_trx -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
		as required for CASE COMPLAINCE.

5. 13-Jun-2005    File Version: 116.2
                  Ramananda for bug#4428980. Removal of SQL LITERALs is done

6. 17-Jul-2005    Sanjikum for Bug#4495135, File Version 117.1
                  1) In the procedure update_row, added parameter - p_tax_apportion_factor.
                     And added the update for jai_rcv_transactions.tax_apportion_factor

7. 15-Apr-2010  Bug#9305067     Change the parameter of procedure insert_row and update_row
                                and replce the old attributes columns with new meaningful columns parameter
                                Add new procedure to update the new columns to replace the procedure update_attribtues


Dependancy:
-----------
IN60105D2 + 3496408
IN60106   + 3940588 +  4245089
----------------------------------------------------------------------------------------------------------------------------*/

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
    p_base_subinv_asset_flag    IN JAI_RCV_TRANSACTIONS.BASE_ASSET_INVENTORY%TYPE,
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
  ) IS

    lv_creation_date DATE;
    lv_created_by NUMBER(15);
    lv_last_update_date DATE;
    lv_last_updated_by NUMBER(15);
    lv_last_update_login NUMBER(15);

  BEGIN

    lv_creation_date    := SYSDATE;
    lv_created_by       := FND_GLOBAL.user_id;
    lv_last_update_date   := SYSDATE;
    lv_last_updated_by    := lv_created_by;
    lv_last_update_login  := FND_GLOBAL.login_id;

    INSERT INTO JAI_RCV_TRANSACTIONS(
      shipment_header_id,  shipment_line_id,  transaction_id,  transaction_type,  quantity,  uom_code,
      transaction_date,  parent_transaction_id,  parent_transaction_type,  receipt_num,  organization_id,
      location_id,  inventory_item_id,  item_class,  item_cenvatable,  item_excisable,  item_trading_flag,
      inv_item_flag,  inv_asset_flag,  loc_subinv_type,  BASE_ASSET_INVENTORY,  organization_type,
      excise_in_trading,  costing_method, boe_applied_flag, third_party_flag,
      --Added new parametersby Bo Li for bug9305067
      --remove the old attribute parameters   Begin
      -----------------------------------------------------------------------------
      trx_information,excise_inv_gen_status,vat_inv_gen_status,excise_inv_gen_number,
      vat_inv_gen_number, cenvat_costed_flag,
      -----------------------------------------------------------------------------
      --Added new parametersby Bo Li for bug9305067
      --remove the old attribute parameters   End
      creation_date,  created_by,  last_update_date,  last_updated_by,  last_update_login,
      destination_type_code, assessable_value, currency_conversion_rate,
      excise_invoice_no, excise_invoice_date, tax_amount, cenvat_claimed_ptg, tax_transaction_id
    ) VALUES (
      p_shipment_header_id,  p_shipment_line_id,  p_transaction_id,  p_transaction_type,  p_quantity,  p_uom_code,
      p_transaction_date,  p_parent_transaction_id,  p_parent_transaction_type,  p_receipt_num,  p_organization_id,
      p_location_id,  p_inventory_item_id,  p_item_class,  p_item_cenvatable,  p_item_excisable,  p_item_trading_flag,
      p_inv_item_flag,  p_inv_asset_flag,  p_loc_subinv_type,  p_base_subinv_asset_flag,  p_organization_type,
      p_excise_in_trading,  p_costing_method, p_boe_applied_flag,  p_third_party_flag,
      --Added new parametersby Bo Li for bug9305067
      --remove the old attribute parameters   Begin
      -----------------------------------------------------------------------------
      p_trx_information,p_excise_inv_gen_status,p_vat_inv_gen_status,p_excise_inv_gen_number,
      p_vat_inv_gen_number,p_cenvat_costed_flag,
     -----------------------------------------------------------------------------
      --Added new parametersby Bo Li for bug9305067
      --remove the old attribute parameters   End
      lv_creation_date,  lv_created_by,  lv_last_update_date,  lv_last_updated_by,  lv_last_update_login,
      p_destination_type_code, p_assessable_value, p_currency_conversion_rate,
      p_excise_invoice_no, p_excise_invoice_date, p_tax_amount, 0, p_tax_transaction_id
    );

  END insert_row;

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
    p_base_subinv_asset_flag    IN JAI_RCV_TRANSACTIONS.BASE_ASSET_INVENTORY%TYPE    DEFAULT NULL,
    p_organization_type         IN JAI_RCV_TRANSACTIONS.ORGANIZATION_TYPE%TYPE         DEFAULT NULL,
    p_excise_in_trading         IN JAI_RCV_TRANSACTIONS.EXCISE_IN_TRADING%TYPE         DEFAULT NULL,
    p_costing_method            IN JAI_RCV_TRANSACTIONS.COSTING_METHOD%TYPE            DEFAULT NULL,
    p_boe_applied_flag          IN JAI_RCV_TRANSACTIONS.BOE_APPLIED_FLAG%TYPE          DEFAULT NULL,
    p_third_party_flag          IN JAI_RCV_TRANSACTIONS.THIRD_PARTY_FLAG%TYPE          DEFAULT NULL,
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
    p_tax_transaction_id        IN JAI_RCV_TRANSACTIONS.tax_transaction_id%TYPE        DEFAULT NULL,   -- Vijay Shankar for Bug#3940588
    p_tax_apportion_factor			IN JAI_RCV_TRANSACTIONS.tax_apportion_factor%TYPE      DEFAULT NULL    -- Added by Sanjikum for Bug#4495135
  ) IS

    lv_last_update_date DATE;
    lv_last_updated_by NUMBER(15);
    lv_last_update_login NUMBER(15);

  BEGIN

    lv_last_update_date   := SYSDATE;
    lv_last_updated_by    := FND_GLOBAL.user_id;
    lv_last_update_login  := FND_GLOBAL.login_id;

    UPDATE JAI_RCV_TRANSACTIONS SET
      PARENT_TRANSACTION_TYPE  = nvl(P_PARENT_TRANSACTION_TYPE, PARENT_TRANSACTION_TYPE),
      RECEIPT_NUM              = nvl(P_RECEIPT_NUM, RECEIPT_NUM),
      ORGANIZATION_ID          = nvl(P_ORGANIZATION_ID, ORGANIZATION_ID),
      LOCATION_ID              = nvl(P_LOCATION_ID, LOCATION_ID),
      INVENTORY_ITEM_ID        = nvl(P_INVENTORY_ITEM_ID, INVENTORY_ITEM_ID),
      excise_invoice_no        = nvl(p_excise_invoice_no, excise_invoice_no),
      excise_invoice_date      = nvl(p_excise_invoice_date, excise_invoice_date),
      tax_amount               = nvl(p_tax_amount, tax_amount),
      assessable_value         = nvl(p_assessable_value, assessable_value),
      cenvat_amount            = nvl(p_cenvat_amount, cenvat_amount),
      currency_conversion_rate = nvl(p_currency_conversion_rate, currency_conversion_rate),
      ITEM_CLASS               = nvl(P_ITEM_CLASS, ITEM_CLASS),
      ITEM_cenvatABLE          = nvl(P_ITEM_cenvatABLE, ITEM_cenvatABLE),
      ITEM_EXCISABLE           = nvl(P_ITEM_EXCISABLE, ITEM_EXCISABLE),
      ITEM_TRADING_FLAG        = nvl(P_ITEM_TRADING_FLAG, ITEM_TRADING_FLAG),
      INV_ITEM_FLAG            = nvl(P_INV_ITEM_FLAG, INV_ITEM_FLAG),
      INV_ASSET_FLAG           = nvl(P_INV_ASSET_FLAG, INV_ASSET_FLAG),
      LOC_SUBINV_TYPE          = nvl(P_LOC_SUBINV_TYPE, LOC_SUBINV_TYPE),
      BASE_ASSET_INVENTORY   = nvl(P_BASE_SUBINV_ASSET_FLAG, BASE_ASSET_INVENTORY),
      ORGANIZATION_TYPE        = nvl(P_ORGANIZATION_TYPE, ORGANIZATION_TYPE),
      EXCISE_IN_TRADING        = nvl(P_EXCISE_IN_TRADING, EXCISE_IN_TRADING),
      COSTING_METHOD           = nvl(P_COSTING_METHOD, COSTING_METHOD),
      BOE_APPLIED_FLAG         = nvl(P_BOE_APPLIED_FLAG, BOE_APPLIED_FLAG),
      THIRD_PARTY_FLAG         = nvl(P_THIRD_PARTY_FLAG, THIRD_PARTY_FLAG),
      --Added new parametersby Bo Li for bug9305067
      --remove the old attribute parameters   Begin
      -----------------------------------------------------------------------------
      TRX_INFORMATION          = nvl(P_TRX_INFORMATION, TRX_INFORMATION),
      EXCISE_INV_GEN_STATUS    = nvl(P_EXCISE_INV_GEN_STATUS, EXCISE_INV_GEN_STATUS),
      VAT_INV_GEN_STATUS       = nvl(P_VAT_INV_GEN_STATUS, VAT_INV_GEN_STATUS),
      EXCISE_INV_GEN_NUMBER    = nvl(P_EXCISE_INV_GEN_NUMBER, EXCISE_INV_GEN_NUMBER),
      VAT_INV_GEN_NUMBER       = nvl(P_VAT_INV_GEN_NUMBER, VAT_INV_GEN_NUMBER),
      CENVAT_COSTED_FLAG       = nvl(P_CENVAT_COSTED_FLAG, CENVAT_COSTED_FLAG),
      -----------------------------------------------------------------------------
      --Added new parametersby Bo Li for bug9305067
      --remove the old attribute parameters   End

      LAST_UPDATE_DATE         = lv_last_update_date,
      LAST_UPDATED_BY          = lv_last_updated_by,
      LAST_UPDATE_LOGIN        = lv_last_update_login,
      tax_transaction_id       = nvl(p_tax_transaction_id, tax_transaction_id),
      tax_apportion_factor     = NVL(p_tax_apportion_factor, tax_apportion_factor) --Added by Sanjikum for Bug#4495135
    WHERE transaction_id = p_transaction_id;

  END update_row;

  PROCEDURE update_process_flags(
    p_transaction_id      IN JAI_RCV_TRANSACTIONS.transaction_id%TYPE,
    p_process_flag        IN JAI_RCV_TRANSACTIONS.PROCESS_STATUS%TYPE     ,
    p_process_message     IN JAI_RCV_TRANSACTIONS.PROCESS_MESSAGE%TYPE  ,
    p_cenvat_rg_flag      IN JAI_RCV_TRANSACTIONS.CENVAT_RG_STATUS%TYPE   ,
    p_cenvat_claimed_ptg  IN JAI_RCV_TRANSACTIONS.CENVAT_claimed_ptg%TYPE DEFAULT NULL  ,
    p_cenvat_rg_message   IN JAI_RCV_TRANSACTIONS.CENVAT_RG_MESSAGE%TYPE,
    p_process_date        IN JAI_RCV_TRANSACTIONS.PROCESS_DATE%TYPE,
    /* following two parameters introduced by Vijay Shankar for Bug#4250236(4245089). VAT Impl. */
    p_process_vat_flag    IN JAI_RCV_TRANSACTIONS.PROCESS_VAT_STATUS%TYPE     ,
    p_process_vat_message IN JAI_RCV_TRANSACTIONS.PROCESS_VAT_MESSAGE%TYPE
  ) IS

  BEGIN
    UPDATE JAI_RCV_TRANSACTIONS
    SET
      PROCESS_STATUS      = nvl(p_process_flag, PROCESS_STATUS),
      process_message   = nvl(p_process_message, process_message),
      CENVAT_RG_STATUS    = nvl(p_cenvat_rg_flag, CENVAT_RG_STATUS),
      cenvat_claimed_ptg= nvl(p_cenvat_claimed_ptg, cenvat_claimed_ptg),
      cenvat_rg_message = nvl(p_cenvat_rg_message, cenvat_rg_message),
      process_date      = nvl(p_process_date, process_date),
      /* following two parameters introduced by Vijay Shankar for Bug#4250236(4245089). VAT Impl. */
      PROCESS_VAT_STATUS  = nvl(p_process_vat_flag, PROCESS_VAT_STATUS),
      process_vat_message = nvl(p_process_vat_message, process_vat_message),
      last_updated_by   = fnd_global.user_id,
      last_update_login = fnd_global.login_id,
      last_update_date  = SYSDATE
    WHERE transaction_id  = p_transaction_id;

  END update_process_flags;

  PROCEDURE update_excise_invoice_no(
    p_transaction_id      IN NUMBER,
    p_excise_invoice_no   IN JAI_RCV_TRANSACTIONS.excise_invoice_no%TYPE,
    p_excise_invoice_date IN JAI_RCV_TRANSACTIONS.excise_invoice_date%TYPE
  ) IS

  BEGIN
    UPDATE JAI_RCV_TRANSACTIONS
    SET excise_invoice_no   = p_excise_invoice_no,
        excise_invoice_date = p_excise_invoice_date,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.login_id,
        last_update_date  = SYSDATE
    WHERE transaction_id = p_transaction_id;

  END update_excise_invoice_no;

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
  ) IS

  BEGIN
    UPDATE JAI_RCV_TRANSACTIONS SET
      ATTRIBUTE_CATEGORY       = nvl(P_ATTRIBUTE_CATEGORY, ATTRIBUTE_CATEGORY),
      ATTRIBUTE1               = nvl(P_ATTRIBUTE1, ATTRIBUTE1),
      ATTRIBUTE2               = nvl(P_ATTRIBUTE2, ATTRIBUTE2),
      ATTRIBUTE3               = nvl(P_ATTRIBUTE3, ATTRIBUTE3),
      ATTRIBUTE4               = nvl(P_ATTRIBUTE4, ATTRIBUTE4),
      ATTRIBUTE5               = nvl(P_ATTRIBUTE5, ATTRIBUTE5),
      ATTRIBUTE6               = nvl(P_ATTRIBUTE6, ATTRIBUTE6),
      ATTRIBUTE7               = nvl(P_ATTRIBUTE7, ATTRIBUTE7),
      ATTRIBUTE8               = nvl(P_ATTRIBUTE8, ATTRIBUTE8),
      ATTRIBUTE9               = nvl(P_ATTRIBUTE9, ATTRIBUTE9),
      ATTRIBUTE10              = nvl(P_ATTRIBUTE10, ATTRIBUTE10),
      LAST_UPDATE_DATE         = sysdate,
      LAST_UPDATED_BY          = fnd_global.user_id,
      LAST_UPDATE_LOGIN        = fnd_global.login_id
    WHERE transaction_id = p_transaction_id;

  END update_attributes;

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
    p_transaction_id           IN JAI_RCV_TRANSACTIONS.transaction_id%TYPE,
    p_trx_information          IN JAI_RCV_TRANSACTIONS.TRX_INFORMATION%TYPE DEFAULT NULL,
    p_excise_inv_gen_status    IN JAI_RCV_TRANSACTIONS.EXCISE_INV_GEN_STATUS%TYPE DEFAULT NULL,
    p_vat_inv_gen_status       IN JAI_RCV_TRANSACTIONS.VAT_INV_GEN_STATUS%TYPE DEFAULT NULL,
    p_excise_inv_gen_number    IN JAI_RCV_TRANSACTIONS.EXCISE_INV_GEN_NUMBER%TYPE DEFAULT NULL,
    p_vat_inv_gen_number        IN JAI_RCV_TRANSACTIONS.VAT_INV_GEN_NUMBER%TYPE DEFAULT NULL
  ) IS

  BEGIN
    UPDATE JAI_RCV_TRANSACTIONS
    SET
      TRX_INFORMATION          = nvl(P_TRX_INFORMATION, TRX_INFORMATION),
      EXCISE_INV_GEN_STATUS    = nvl(P_EXCISE_INV_GEN_STATUS, EXCISE_INV_GEN_STATUS),
      VAT_INV_GEN_STATUS       = nvl(P_VAT_INV_GEN_STATUS, VAT_INV_GEN_STATUS),
      EXCISE_INV_GEN_NUMBER    = nvl(P_EXCISE_INV_GEN_NUMBER, EXCISE_INV_GEN_NUMBER),
      VAT_INV_GEN_NUMBER       = nvl(P_VAT_INV_GEN_NUMBER, VAT_INV_GEN_NUMBER),
      LAST_UPDATE_DATE         = sysdate,
      LAST_UPDATED_BY          = fnd_global.user_id,
      LAST_UPDATE_LOGIN        = fnd_global.login_id
    WHERE transaction_id = p_transaction_id;

  END update_inv_stat_and_no;

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
  ) IS

  BEGIN
    UPDATE JAI_RCV_TRANSACTIONS SET
       CENVAT_COSTED_FLAG      = nvl(P_CENVAT_COSTED_FLAG, CENVAT_COSTED_FLAG),
       LAST_UPDATE_DATE        = sysdate,
      LAST_UPDATED_BY          = fnd_global.user_id,
      LAST_UPDATE_LOGIN        = fnd_global.login_id
    WHERE transaction_id = p_transaction_id;

  END update_cenvat_costed_flag;


END jai_rcv_transactions_pkg;

/
