--------------------------------------------------------
--  DDL for Package PON_VALIDATE_ITEM_PRICES_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_VALIDATE_ITEM_PRICES_INT" AUTHID CURRENT_USER as
-- $Header: PONVAIPS.pls 120.2 2007/06/22 18:02:49 tarkumar ship $

g_xml_upload_mode CONSTANT VARCHAR2(3) := PON_AWARD_PKG.g_xml_upload_mode;
g_txt_upload_mode CONSTANT VARCHAR2(3) := PON_AWARD_PKG.g_txt_upload_mode;

PROCEDURE validate_bids (p_source VARCHAR2, p_batch_Id NUMBER, p_trading_partner_id NUMBER default null);

PROCEDURE validate(p_source VARCHAR2,
                   p_batch_Id NUMBER,
                   p_doctype_Id NUMBER,
		   p_user_Id NUMBER,
                   p_trading_partner_id NUMBER default NULL,
		   p_trading_partner_contact_id NUMBER default NULL,
		   p_language VARCHAR2 default 'US',
                   p_contract_type VARCHAR2 default 'STANDARD',
		   p_global_flag VARCHAR2 DEFAULT 'N',
                   p_org_id NUMBER);

PROCEDURE validateAwardBidXML(p_batch_id NUMBER,
        x_return_status         OUT NOCOPY NUMBER,
        x_return_code           OUT NOCOPY VARCHAR2);


END pon_validate_item_prices_int;

/
