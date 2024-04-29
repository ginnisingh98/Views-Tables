--------------------------------------------------------
--  DDL for Package PO_TAX_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_TAX_SUMMARY_PKG" AUTHID CURRENT_USER as
/* $Header: POXTAXDS.pls 115.4 2004/02/11 19:23:48 bao ship $ */


  FUNCTION get_recoverable_tax(X_header_id NUMBER, x_line_id NUMBER, x_shipment_id NUMBER, object_type VARCHAR2, object_location VARCHAR2)
	   return number;

  FUNCTION get_nonrecoverable_tax(X_header_id NUMBER, x_line_id NUMBER, x_shipment_id NUMBER, object_type VARCHAR2, object_location VARCHAR2)
	   return number;

/* Bug#2767208 : Added third argument X_currency_code in the following
                 function get_header_amount */
  FUNCTION get_header_amount(X_header_id NUMBER, object_type VARCHAR2,
                              X_currency_code     varchar2)
	   return number;

-- bug3426902 START

FUNCTION get_line_amount (p_line_id IN VARCHAR2,
                          p_currency_code IN VARCHAR2)

-- bug3426902 END

RETURN NUMBER;

--  pragma restrict_references (get_recoverable_tax,WNDS,RNPS,WNPS);
--  pragma restrict_references (get_nonrecoverable_tax,WNDS,RNPS,WNPS);
--  pragma restrict_references (get_header_amount,WNDS,RNPS,WNPS);
END PO_TAX_SUMMARY_PKG;

 

/
