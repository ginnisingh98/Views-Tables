--------------------------------------------------------
--  DDL for Package MTL_CLIENT_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_CLIENT_PARAMETERS_PKG" AUTHID CURRENT_USER AS
/* $Header: INVCTDFS.pls 120.0.12010000.1 2009/11/30 13:55:10 gjyoti noship $ */
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

PROCEDURE lock_row (
          X_Rowid                       VARCHAR2,
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
              );


/* Procedure to Insert record for MTL_CLIENT_PARAMETERS table
 */

PROCEDURE insert_row (
          X_Rowid                     IN OUT NOCOPY VARCHAR2,
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
        );


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
        );

END  MTL_CLIENT_PARAMETERS_PKG;

/
