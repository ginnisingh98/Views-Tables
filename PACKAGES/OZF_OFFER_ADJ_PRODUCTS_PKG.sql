--------------------------------------------------------
--  DDL for Package OZF_OFFER_ADJ_PRODUCTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_OFFER_ADJ_PRODUCTS_PKG" AUTHID CURRENT_USER AS
/* $Header: ozftoadps.pls 120.3 2005/08/25 04:15 rssharma noship $ */

PROCEDURE INSERT_ROW
(
 px_offer_adjustment_product_id   IN OUT NOCOPY NUMBER
 , p_offer_adjustment_id         NUMBER
 , p_offer_discount_line_id      NUMBER
 , p_off_discount_product_id     NUMBER
 , p_product_context             VARCHAR2
 , p_product_attribute           VARCHAR2
 , p_product_attr_value          VARCHAR2
 , p_excluder_flag               VARCHAR2
 , p_apply_discount_flag         VARCHAR2
 , p_include_volume_flag         VARCHAR2
 , px_object_version_number      IN OUT NOCOPY NUMBER
 , p_last_update_date            DATE
 , p_last_updated_by             NUMBER
 , p_creation_date               DATE
 , p_created_by                  NUMBER
 , p_last_update_login           NUMBER
 );

PROCEDURE UPDATE_ROW
(
p_offer_adjustment_product_id NUMBER
, p_offer_adjustment_id NUMBER
, p_offer_discount_line_id NUMBER
, p_off_discount_product_id  NUMBER
, p_product_context VARCHAR2
, p_product_attribute VARCHAR2
, p_product_attr_value VARCHAR2
, p_excluder_flag VARCHAR2
, p_apply_discount_flag VARCHAR2
, p_include_volume_flag VARCHAR2
, p_object_version_number NUMBER
, p_last_update_date DATE
, p_last_updated_by NUMBER
, p_last_update_login NUMBER
);

PROCEDURE delete_row
(
p_offer_adjustment_product_id NUMBER
, p_object_version_number NUMBER
);

procedure LOCK_ROW
(
p_offer_adjustment_product_id NUMBER
, p_object_version_number NUMBER
);


END OZF_OFFER_ADJ_PRODUCTS_PKG;

 

/
