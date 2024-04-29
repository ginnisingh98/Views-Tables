--------------------------------------------------------
--  DDL for Package Body MTL_CLIENT_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_CLIENT_PARAMETERS_PKG" AS
/* $Header: INVCTDFB.pls 120.0.12010000.1 2009/11/30 15:27:07 gjyoti noship $ */
/*#
 * This package provides routine for MTL_CLIENT_PARAMETERS table handler
 * LSP installation utilities
 * @rep:scope private
 * @rep:product INV
 * @rep:lifecycle active
 * @rep:displayname MTL Client Parameters pkg
 * @rep:category BUSINESS_ENTITY LSP
 */


/* Procedure to Lock record for MTL_CLIENT_PARAMETERS table
 */

PROCEDURE lock_row (X_Rowid                 VARCHAR2,
              p_client_id                   NUMBER,
              p_client_code                 VARCHAR2,
              p_client_number               VARCHAR2,
              p_trading_partner_site_id     NUMBER,
              p_receipt_asn_exists_code     VARCHAR2,
              p_rma_receipt_routing_id      NUMBER,
              p_group_by_customer_flag      VARCHAR2,
              p_group_by_freight_terms_flag VARCHAR2,
              p_group_by_fob_flag           VARCHAR2,
              p_group_by_ship_method_flag   VARCHAR2,
              p_otm_enabled                 VARCHAR2,
              p_ship_confirm_rule_id        NUMBER,
              p_autocreate_del_orders_flag  VARCHAR2,
              p_delivery_report_set_id      NUMBER,
              p_lpn_prefix                  VARCHAR2,
              p_lpn_suffix                  VARCHAR2,
              p_ucc_128_suffix_flag         VARCHAR2,
              p_total_lpn_length            NUMBER,
              p_lpn_starting_number         NUMBER,
              p_last_update_login           NUMBER
                 )
IS
    CURSOR C IS
        SELECT *
        FROM   mtl_client_parameters
        WHERE  rowid = X_Rowid
        FOR UPDATE of client_id NOWAIT;
    Recinfo C%ROWTYPE;
  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (
           (Recinfo.client_id = p_client_id)
           AND (Recinfo.client_code = p_client_code)
           AND (Recinfo.client_number = p_client_number)
           AND (   (Recinfo.trading_partner_site_id = p_trading_partner_site_id)
                OR (    (Recinfo.trading_partner_site_id IS NULL)
                    AND (p_trading_partner_site_id IS NULL)))
           AND (   (Recinfo.receipt_asn_exists_code = p_receipt_asn_exists_code)
                OR (    (Recinfo.receipt_asn_exists_code IS NULL)
                    AND (p_receipt_asn_exists_code IS NULL)))
           AND (   (Recinfo.rma_receipt_routing_id = p_rma_receipt_routing_id)
                OR (    (Recinfo.rma_receipt_routing_id IS NULL)
                    AND (p_rma_receipt_routing_id IS NULL)))
           AND (   (Recinfo.group_by_customer_flag = p_group_by_customer_flag)
                OR (    (Recinfo.group_by_customer_flag IS NULL)
                    AND (p_group_by_customer_flag IS NULL)))
           AND (   (Recinfo.group_by_freight_terms_flag = p_group_by_freight_terms_flag)
                OR (    (Recinfo.group_by_freight_terms_flag IS NULL)
                    AND (p_group_by_freight_terms_flag IS NULL)))
           AND (   (Recinfo.group_by_fob_flag = p_group_by_fob_flag)
                OR (    (Recinfo.group_by_fob_flag IS NULL)
                    AND (p_group_by_fob_flag IS NULL)))
           AND (   (Recinfo.group_by_ship_method_flag = p_group_by_ship_method_flag)
                OR (    (Recinfo.group_by_ship_method_flag IS NULL)
                    AND (p_group_by_ship_method_flag IS NULL)))
           AND (   (Recinfo.otm_enabled = p_otm_enabled)
                OR (    (Recinfo.otm_enabled IS NULL)
                    AND (p_otm_enabled IS NULL)))
           AND (   (Recinfo.ship_confirm_rule_id = p_ship_confirm_rule_id)
                OR (    (Recinfo.ship_confirm_rule_id IS NULL)
                    AND (p_ship_confirm_rule_id IS NULL)))
           AND (   (Recinfo.autocreate_del_orders_flag = p_autocreate_del_orders_flag)
                OR (    (Recinfo.autocreate_del_orders_flag IS NULL)
                    AND (p_autocreate_del_orders_flag IS NULL)))
           AND (   (Recinfo.delivery_report_set_id = p_delivery_report_set_id)
                OR (    (Recinfo.delivery_report_set_id IS NULL)
                    AND (p_delivery_report_set_id IS NULL)))
           AND (   (Recinfo.lpn_prefix = p_lpn_prefix)
                OR (    (Recinfo.lpn_prefix IS NULL)
                    AND (p_lpn_prefix IS NULL)))
           AND (   (Recinfo.lpn_suffix = p_lpn_suffix)
                OR (    (Recinfo.lpn_suffix IS NULL)
                    AND (p_lpn_suffix IS NULL)))
           AND (   (Recinfo.ucc_128_suffix_flag = p_ucc_128_suffix_flag)
                OR (    (Recinfo.ucc_128_suffix_flag IS NULL)
                    AND (p_ucc_128_suffix_flag IS NULL)))
           AND (   (Recinfo.total_lpn_length = p_total_lpn_length)
                OR (    (Recinfo.total_lpn_length IS NULL)
                    AND (p_total_lpn_length IS NULL)))
           AND (   (Recinfo.lpn_starting_number = p_lpn_starting_number)
                OR (    (Recinfo.lpn_starting_number IS NULL)
                    AND (p_lpn_starting_number IS NULL)))
           AND (   (Recinfo.last_update_login = p_last_update_login)
                OR (    (Recinfo.last_update_login IS NULL)
                    AND (p_last_update_login IS NULL)))
           ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;
  END Lock_Row;


/* Procedure to Insert record for MTL_CLIENT_PARAMETERS table
 */

PROCEDURE insert_row (X_Rowid                  IN OUT NOCOPY VARCHAR2,
              p_client_id                   NUMBER,
              p_client_code                 VARCHAR2,
              p_client_number               VARCHAR2,
              p_trading_partner_site_id     NUMBER,
              p_receipt_asn_exists_code     VARCHAR2,
              p_rma_receipt_routing_id      NUMBER,
              p_group_by_customer_flag      VARCHAR2,
              p_group_by_freight_terms_flag VARCHAR2,
              p_group_by_fob_flag           VARCHAR2,
              p_group_by_ship_method_flag   VARCHAR2,
              p_otm_enabled                 VARCHAR2,
              p_ship_confirm_rule_id        NUMBER,
              p_autocreate_del_orders_flag  VARCHAR2,
              p_delivery_report_set_id      NUMBER,
              p_lpn_prefix                  VARCHAR2,
              p_lpn_suffix                  VARCHAR2,
              p_ucc_128_suffix_flag         VARCHAR2,
              p_total_lpn_length            NUMBER,
              p_lpn_starting_number         NUMBER,
              p_attribute_category          VARCHAR2,
              p_attribute1                  VARCHAR2,
              p_attribute2                  VARCHAR2,
              p_attribute3                  VARCHAR2,
              p_attribute4                  VARCHAR2,
              p_attribute5                  VARCHAR2,
              p_attribute6                  VARCHAR2,
              p_attribute7                  VARCHAR2,
              p_attribute8                  VARCHAR2,
              p_attribute9                  VARCHAR2,
              p_attribute10                 VARCHAR2,
              p_attribute11                 VARCHAR2,
              p_attribute12                 VARCHAR2,
              p_attribute13                 VARCHAR2,
              p_attribute14                 VARCHAR2,
              p_attribute15                 VARCHAR2,
              p_last_update_date            DATE,
              p_last_updated_by             NUMBER,
              p_creation_date               DATE,
              p_created_by                  NUMBER,
              p_last_update_login           NUMBER
     ) IS
       CURSOR C IS SELECT rowid FROM mtl_client_parameters
                   WHERE client_id = p_client_id;

      BEGIN

         INSERT INTO mtl_client_parameters(
              client_id,
              client_code,
              client_number,
              trading_partner_site_id,
              receipt_asn_exists_code,
              rma_receipt_routing_id,
              group_by_customer_flag,
              group_by_freight_terms_flag,
              group_by_fob_flag,
              group_by_ship_method_flag,
              otm_enabled,
              ship_confirm_rule_id,
              autocreate_del_orders_flag,
              delivery_report_set_id,
              lpn_prefix,
              lpn_suffix,
              ucc_128_suffix_flag,
              total_lpn_length,
              lpn_starting_number,
              attribute_category,
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              attribute6,
              attribute7,
              attribute8,
              attribute9,
              attribute10,
              attribute11,
              attribute12,
              attribute13,
              attribute14,
              attribute15,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login
               )
        VALUES (
              p_client_id,
              p_client_code,
              p_client_number,
              p_trading_partner_site_id,
              p_receipt_asn_exists_code,
              p_rma_receipt_routing_id,
              p_group_by_customer_flag,
              p_group_by_freight_terms_flag,
              p_group_by_fob_flag,
              p_group_by_ship_method_flag,
              p_otm_enabled,
              p_ship_confirm_rule_id,
              p_autocreate_del_orders_flag,
              p_delivery_report_set_id,
              p_lpn_prefix,
              p_lpn_suffix,
              p_ucc_128_suffix_flag,
              p_total_lpn_length,
              p_lpn_starting_number,
              p_attribute_category,
              p_attribute1,
              p_attribute2,
              p_attribute3,
              p_attribute4,
              p_attribute5,
              p_attribute6,
              p_attribute7,
              p_attribute8,
              p_attribute9,
              p_attribute10,
              p_attribute11,
              p_attribute12,
              p_attribute13,
              p_attribute14,
              p_attribute15,
              p_last_update_date,
              p_last_updated_by,
              p_creation_date,
              p_created_by,
              p_last_update_login);

      OPEN C;
      FETCH C INTO x_Rowid;
      if (C%NOTFOUND) then
        CLOSE C;
        Raise NO_DATA_FOUND;
      end if;
      CLOSE C;
    END Insert_Row;


/* Procedure to Update record for MTL_CLIENT_PARAMETERS table
 */

PROCEDURE update_row (X_Rowid               VARCHAR2,
              p_client_id                   NUMBER,
              p_client_code                 VARCHAR2,
              p_client_number               VARCHAR2,
              p_trading_partner_site_id     NUMBER,
              p_receipt_asn_exists_code     VARCHAR2,
              p_rma_receipt_routing_id      NUMBER,
              p_group_by_customer_flag      VARCHAR2,
              p_group_by_freight_terms_flag VARCHAR2,
              p_group_by_fob_flag           VARCHAR2,
              p_group_by_ship_method_flag   VARCHAR2,
              p_otm_enabled                 VARCHAR2,
              p_ship_confirm_rule_id        NUMBER,
              p_autocreate_del_orders_flag  VARCHAR2,
              p_delivery_report_set_id      NUMBER,
              p_lpn_prefix                  VARCHAR2,
              p_lpn_suffix                  VARCHAR2,
              p_ucc_128_suffix_flag         VARCHAR2,
              p_total_lpn_length            NUMBER,
              p_lpn_starting_number         NUMBER,
              p_attribute_category          VARCHAR2,
              p_attribute1                  VARCHAR2,
              p_attribute2                  VARCHAR2,
              p_attribute3                  VARCHAR2,
              p_attribute4                  VARCHAR2,
              p_attribute5                  VARCHAR2,
              p_attribute6                  VARCHAR2,
              p_attribute7                  VARCHAR2,
              p_attribute8                  VARCHAR2,
              p_attribute9                  VARCHAR2,
              p_attribute10                 VARCHAR2,
              p_attribute11                 VARCHAR2,
              p_attribute12                 VARCHAR2,
              p_attribute13                 VARCHAR2,
              p_attribute14                 VARCHAR2,
              p_attribute15                 VARCHAR2,
              p_last_update_date            DATE,
              p_last_updated_by             NUMBER,
              p_creation_date               DATE,
              p_created_by                  NUMBER,
              p_last_update_login           NUMBER

     ) IS

      BEGIN

         UPDATE mtl_client_parameters
         SET
            trading_partner_site_id = p_trading_partner_site_id,
            receipt_asn_exists_code = p_receipt_asn_exists_code,
            rma_receipt_routing_id  = p_rma_receipt_routing_id,
            group_by_customer_flag  = p_group_by_customer_flag,
            group_by_freight_terms_flag = p_group_by_freight_terms_flag,
            group_by_fob_flag  = p_group_by_fob_flag,
            group_by_ship_method_flag = p_group_by_ship_method_flag,
            otm_enabled  = p_otm_enabled,
            ship_confirm_rule_id = p_ship_confirm_rule_id,
            autocreate_del_orders_flag = p_autocreate_del_orders_flag,
            delivery_report_set_id = p_delivery_report_set_id,
            lpn_prefix = p_lpn_prefix,
            lpn_suffix = p_lpn_suffix,
            ucc_128_suffix_flag = p_ucc_128_suffix_flag,
            total_lpn_length = p_total_lpn_length,
            lpn_starting_number = p_lpn_starting_number,
            attribute_category = p_attribute_category,
            attribute1 = p_attribute1,
            attribute2 = p_attribute2,
            attribute3 = p_attribute3,
            attribute4 = p_attribute4,
            attribute5 = p_attribute5,
            attribute6 = p_attribute6,
            attribute7 = p_attribute7,
            attribute8 = p_attribute8,
            attribute9  = p_attribute9,
            attribute10 = p_attribute10,
            attribute11 = p_attribute11,
            attribute12 = p_attribute12,
            attribute13 = p_attribute13,
            attribute14  = p_attribute14,
            attribute15  = p_attribute15,
            last_update_date = p_last_update_date,
            last_updated_by = p_last_updated_by,
            last_update_login = p_last_update_login
    WHERE Rowid = X_Rowid;

      if (SQL%NOTFOUND) then
        Raise NO_DATA_FOUND;
      end if;

    END update_Row;

END  MTL_CLIENT_PARAMETERS_PKG;

/
