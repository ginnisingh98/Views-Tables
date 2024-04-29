--------------------------------------------------------
--  DDL for Package IBY_TRXN_EXTENSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_TRXN_EXTENSIONS_PKG" AUTHID CURRENT_USER as
/* $Header: ibyfcits.pls 120.0 2005/09/02 17:34:18 syidner noship $ */

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_TRXN_EXTENSION_ID                NUMBER,
                     X_PAYMENT_CHANNEL_CODE             VARCHAR2,
                     X_INSTR_ASSIGNMENT_ID              NUMBER,
                     X_INSTRUMENT_SECURITY_CODE         VARCHAR2,
                     X_VOICE_AUTHORIZATION_FLAG         VARCHAR2,
                     X_VOICE_AUTHORIZATION_DATE         DATE,
                     X_VOICE_AUTHORIZATION_CODE         VARCHAR2,
                     X_ORIGIN_APPLICATION_ID            NUMBER,
                     X_ORDER_ID                         VARCHAR2,
                     X_PO_NUMBER                        VARCHAR2,
                     X_PO_LINE_NUMBER                   VARCHAR2,
                     X_TRXN_REF_NUMBER1                 VARCHAR2,
                     X_TRXN_REF_NUMBER2                 VARCHAR2,
                     X_ADDITIONAL_INFO                  VARCHAR2,
		     X_Calling_Sequence                 VARCHAR2);

END IBY_TRXN_EXTENSIONS_PKG;


 

/
