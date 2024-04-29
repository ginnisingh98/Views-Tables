--------------------------------------------------------
--  DDL for Package FUN_AR_BATCH_TRANSFER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_AR_BATCH_TRANSFER" AUTHID CURRENT_USER AS
/* $Header: funartrs.pls 120.3 2006/05/25 11:28:39 cjain noship $ */

    -- The record type for AR transfer

     TYPE AR_interface_line IS RECORD(
     AMOUNT NUMBER,
     BATCH_SOURCE_NAME Varchar2(50),
     CONVERSION_TYPE Varchar2(30),
     CURRENCY_CODE Varchar2(15),
     CUSTOMER_TRX_TYPE_ID Number,
     DESCRIPTION Varchar2(240),
     GL_DATE Date,
     INTERFACE_LINE_ATTRIBUTE1 Varchar2(30),
     INTERFACE_LINE_ATTRIBUTE2 Varchar2(30),
     INTERFACE_LINE_ATTRIBUTE3 Varchar2(30),
     INTERFACE_LINE_CONTEXT Varchar2(30),
     LINE_TYPE Varchar2(20) ,
     MEMO_LINE_ID Number,
     ORG_ID Number,
     ORIG_SYSTEM_BILL_ADDRESS_ID Number,
     ORIG_SYSTEM_BILL_CUSTOMER_ID Number,
     SET_OF_BOOKS_ID Number,
     TRX_DATE Date,
     UOM_NAME Varchar2(25)
     );

     TYPE AR_interface_Dist_line IS RECORD(
     ACCOUNT_CLASS RA_CUST_TRX_LINE_GL_DIST_ALL.account_class%TYPE,
     AMOUNT NUMBER,
     percent RA_CUST_TRX_LINE_GL_DIST_ALL.percent%TYPE,
     CODE_COMBINATION_ID Number,
     INTERFACE_LINE_ATTRIBUTE1 Varchar2(30),
     INTERFACE_LINE_ATTRIBUTE2 Varchar2(30),
     INTERFACE_LINE_ATTRIBUTE3 Varchar2(30),
     INTERFACE_LINE_CONTEXT Varchar2(30),
     ORG_ID Number
     );


	FUNCTION has_valid_conversion_rate (
	    p_from_currency IN varchar2,
	    p_to_currency   IN varchar2,
	    p_exchange_type IN varchar2,
	    p_exchange_date IN date) RETURN NUMBER;

	Procedure ar_batch_transfer  (errbuf    OUT NOCOPY VARCHAR2,
                                retcode     OUT NOCOPY NUMBER,
                                p_org_id    IN VARCHAR2 DEFAULT NULL,
                                p_le_id     IN VARCHAR2 DEFAULT NULL,
                                p_date_low  IN VARCHAR2 DEFAULT NULL,
                                p_date_high IN VARCHAR2 DEFAULT NULL,
                                p_run_autoinvoice_import IN VARCHAR2 DEFAULT 'N'
                                );



    END;


 

/
