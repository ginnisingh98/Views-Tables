--------------------------------------------------------
--  DDL for Package PON_PRICE_ELEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_PRICE_ELEMENTS_PKG" AUTHID CURRENT_USER as
/* $Header: PONPETPS.pls 120.1 2006/04/13 09:53:46 sapandey noship $ */


PROCEDURE  insert_price_element(p_type_id       IN      NUMBER,
                                p_code 		IN	VARCHAR2,
	                        p_name 		IN	VARCHAR2,
                                p_description 	IN	VARCHAR2,
                                p_enabledFlag 	IN	VARCHAR2,
                                p_partyId 	IN	NUMBER,
                                p_source_language 	IN	VARCHAR2,
				p_pricingBasis	IN	VARCHAR2,
				p_contactId	IN	NUMBER,
				p_result	OUT	NOCOPY	NUMBER,
				p_err_code	OUT	NOCOPY	VARCHAR2,
				p_err_msg	OUT	NOCOPY	VARCHAR2);


PROCEDURE  update_price_element(p_typeId	IN	NUMBER,
				p_code 		IN	VARCHAR2,
            			p_name 		IN	VARCHAR2,
				p_description 	IN	VARCHAR2,
            			p_enabledFlag 	IN	VARCHAR2,
				p_partyId 	IN	NUMBER,
            			p_language 	IN	VARCHAR2,
				p_pricingBasis 	IN	VARCHAR2,
				p_contactId	IN	NUMBER,
				p_lastUpdate	IN	DATE,
				p_result 	OUT	NOCOPY	NUMBER,
				p_err_code	OUT	NOCOPY	VARCHAR2,
				p_err_msg	OUT 	NOCOPY	VARCHAR2);

-- ======================================================================
--   PROCEDURE : ADD_LANGUAGE
--   COMMENT    : Used to popluate the PON_PRICE_ELEMENT_TYPES_TL table when
--                         a new language is added. It is called from sql/PONNLINS.sql
-- ======================================================================
PROCEDURE  ADD_LANGUAGE;

end PON_PRICE_ELEMENTS_PKG;

 

/
