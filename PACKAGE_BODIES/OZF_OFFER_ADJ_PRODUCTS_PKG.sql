--------------------------------------------------------
--  DDL for Package Body OZF_OFFER_ADJ_PRODUCTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_OFFER_ADJ_PRODUCTS_PKG" AS
/* $Header: ozftoadpb.pls 120.3 2005/08/25 04:14 rssharma noship $ */

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
 )
IS
BEGIN
px_object_version_number := nvl(px_object_version_number,1);
INSERT INTO OZF_OFFER_ADJUSTMENT_PRODUCTS
(
offer_adjustment_product_id
, offer_adjustment_id
, offer_discount_line_id
, off_discount_product_id
, product_context
, product_attribute
, product_attr_value
, excluder_flag
, apply_discount_flag
, include_volume_flag
, object_version_number
, creation_date
, created_by
, last_update_date
, last_updated_by
, last_update_login
)
values
(
DECODE(px_offer_adjustment_product_id , FND_API.G_MISS_NUM , NULL,  px_offer_adjustment_product_id)
, DECODE(p_offer_adjustment_id , FND_API.G_MISS_NUM, NULL, p_offer_adjustment_id)
, DECODE(p_offer_discount_line_id , FND_API.G_MISS_NUM, NULL, p_offer_discount_line_id)
, DECODE(p_off_discount_product_id , FND_API.G_MISS_NUM , NULL, p_off_discount_product_id)
, DECODE(p_product_context, FND_API.G_MISS_CHAR, NULL, p_product_context)
, DECODE(p_product_attribute, FND_API.G_MISS_CHAR, null, p_product_attribute)
, DECODE(p_product_attr_value, fnd_api.g_miss_char, null, p_product_attr_value)
, DECODE(p_excluder_flag, FND_API.g_miss_char, null, p_excluder_flag )
, DECODE(p_apply_discount_flag , FND_API.G_MISS_CHAR, null, p_apply_discount_flag)
, DECODE(p_include_volume_flag, FND_API.G_MISS_CHAR, NULL, p_include_volume_flag)
, DECODE(px_object_version_number, FND_API.G_MISS_NUM, null, px_object_version_number)
, DECODE(p_creation_date, FND_API.G_MISS_DATE, sysdate, p_creation_date)
, DECODE(p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.user_id, p_created_by)
, DECODE(p_last_update_date, FND_API.G_MISS_DATE, sysdate, p_last_update_date)
, DECODE(p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.user_id, p_last_updated_by)
, DECODE(p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.conc_login_id, p_last_update_login)

);
END INSERT_ROW;

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
)IS
BEGIN

UPDATE OZF_OFFER_ADJUSTMENT_PRODUCTS
SET
offer_adjustment_product_id     = DECODE(p_offer_adjustment_product_id, null, offer_adjustment_product_id, FND_API.G_MISS_NUM, null,  p_offer_adjustment_product_id)
, offer_adjustment_id           = DECODE(P_offer_adjustment_id , null, offer_adjustment_id , FND_API.G_MISS_NUM,null, p_offer_adjustment_id)
, offer_discount_line_id        = DECODE(P_OFFER_DISCOUNT_LINE_ID, NULL, OFFER_DISCOUNT_LINE_ID, FND_API.G_MISS_NUM, NULL, p_offer_discount_line_id)
, off_discount_product_id       = DECODE(p_off_discount_product_id , NULL, off_discount_product_id, FND_API.G_MISS_NUM, NULL, p_off_discount_product_id)
, product_context               = DECODE(p_product_context, null , product_context, FND_API.G_MISS_CHAR, null, p_product_context)
, product_attribute             = DECODE(p_product_attribute, NULL, product_attribute, FND_API.G_MISS_char, NULL , p_product_attribute)
, product_attr_value            = DECODE(p_product_attr_value, NULL, product_attr_value, FND_API.G_MISS_CHAR, null, p_product_attr_value)
, excluder_flag                 = DECODE(P_EXCLUDER_FLAG , NULL,excluder_flag , FND_API.G_MISS_CHAR, null, p_excluder_flag)
, apply_discount_flag           = DECODE(p_apply_discount_flag , NULL, apply_discount_flag, FND_API.G_MISS_CHAR, null, p_apply_discount_flag)
, include_volume_flag           = DECODE(P_INCLUDE_VOLUME_FLAG, NULL, INCLUDE_VOLUME_FLAG, fnd_api.g_miss_char, null, p_include_volume_flag)
, object_version_number         = NVL(p_object_version_number , 0)+1
, last_update_date              = DECODE(p_last_update_date, to_date(NULL), last_update_date, FND_API.G_MISS_DATE, to_date(null), p_last_update_date )
, last_update_login             = DECODE(P_LAST_UPDATE_LOGIN, null, last_update_login, FND_API.G_MISS_NUM, fnd_global.user_id, p_last_update_login)
, last_updated_by               = DECODE(P_LAST_UPDATED_BY, null, last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.conc_login_id, p_last_update_login)
WHERE offer_adjustment_product_id = p_offer_adjustment_product_id
AND object_version_number = p_object_version_number;

IF SQL%NOTFOUND THEN
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

END UPDATE_ROW;

PROCEDURE delete_row
(
p_offer_adjustment_product_id NUMBER
, p_object_version_number NUMBER
)
IS
BEGIN
delete FROM ozf_offer_adjustment_products
WHERE offer_adjustment_product_id = p_offer_adjustment_product_id
AND object_version_number = p_object_version_number;

IF sql%notfound THEN
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
END delete_row;


procedure LOCK_ROW
(
p_offer_adjustment_product_id NUMBER
, p_object_version_number NUMBER
)
IS
CURSOR C is SELECT * FROM ozf_offer_adjustment_products
WHERE offer_adjustment_product_id = p_offer_adjustment_product_id
AND object_version_number = p_object_version_number
FOR UPDATE OF offer_adjustment_product_id NOWAIT;

recinfo c%ROWTYPE;

BEGIN
OPEN c;
FETCH c INTO recinfo;
   IF (c%NOTFOUND) THEN
      CLOSE c;
      AMS_Utility_PVT.error_message ('AMS_API_RECORD_NOT_FOUND');
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c;

END LOCK_ROW;


END OZF_OFFER_ADJ_PRODUCTS_PKG;

/
