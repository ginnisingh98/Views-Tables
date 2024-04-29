--------------------------------------------------------
--  DDL for Package AST_RATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_RATES_PKG" AUTHID CURRENT_USER AS
 /* $Header: astrtrts.pls 115.6 2002/02/07 15:24:45 pkm ship      $ */

FUNCTION CONVERT_AMOUNT( x_from_currency VARCHAR2,
					x_to_currency VARCHAR2,
					x_conversion_date DATE,
					x_amount NUMBER) return NUMBER;

END;

 

/
