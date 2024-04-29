--------------------------------------------------------
--  DDL for Package GMF_AR_GET_CUST_CURRENCY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_AR_GET_CUST_CURRENCY" AUTHID CURRENT_USER as
/* $Header: gmfcstus.pls 115.1 99/07/16 04:16:24 porting shi $ */
    procedure AR_GET_CUST_CURRENCY (cust_id            in number,
                                         site_use_id          in number,
                                         currency_code      out    varchar2,
					 porg_id	    in number,
                                         row_to_fetch       in out number,
                                         error_status       out    number);

END GMF_AR_GET_CUST_CURRENCY;

 

/
