--------------------------------------------------------
--  DDL for Package QP_CUSTOM_IGNORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_CUSTOM_IGNORE" AUTHID CURRENT_USER AS
/* $Header: QPXCTIGS.pls 120.0.12010000.1 2009/02/02 12:15:07 cmsops noship $ */
/*#
 * This package contains the specification for the IGNORE_ITEMLINE_FOR_PRICING API.
 * The package body is not shipped with Oracle Advanced Pricing.  The
 * user must create the Package Body for QP_CUSTOM_IGNORE containing the procedure
 * for IGNORE_ITEMLINE_FOR_PRICING which must adhere to the specification
 * provided in the QP_CUSTOM_IGNORE package specification.
 *
 * @rep:scope public
 * @rep:product QP
 * @rep:displayname Custom Ignore Pricing
 * @rep:category BUSINESS_ENTITY QP_PRICING_ENGINE
 */

 /*Customizable Public Procedure*/
 /*#
 * The IGNORE_ITEMLINE_FOR_PRICING API is a customizable procedure to which the user
 * may add custom code.The API is called when the profile value QP: Custom Ignore Pricing
 * is set to Y.It is called by the pricing engine for each line while sourcing line level attributes.
 * Based on the p_request_type_code, the respective line structure would be available.
 * For Example:
 * OE_ORDER_PUB.G_LINE would be available for  ONT request_type_code
 * ASO_PRICING_INT.G_LINE_REC would be available for ASO request_type_code
 * From the above structure the customer can access  inventory_item_id, line_id,
 * line_type_code, etc
 * Using the above data in structure the customer API can decide and return x_ignore
 * true or false. If true, the price would be defaulted to 0 and the price list
 * of the line would be defaulted as x_default_price_list_id
 *
 * @param p_request_type_code - Request Type Code
 * @param x_ignore - set to Y if the Item-line is ignored by pricing
 * @param x_default_price_list_id - if x_ignore is Y, x_default_price_list_id has
 *                                      to be set to the list_header_id value of a
 *                                      dummy Price List (as Price List is mandatory
 *                                      in Sales Order form)
 *
 * @rep:displayname Custom Ignore Pricing
 */

PROCEDURE IGNORE_ITEMLINE_FOR_PRICING(p_request_type_code IN VARCHAR2
		       ,x_ignore OUT NOCOPY VARCHAR2
		       ,x_default_price_list_id OUT NOCOPY NUMBER
		       );
END QP_CUSTOM_IGNORE;

/
