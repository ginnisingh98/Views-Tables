--------------------------------------------------------
--  DDL for Package GMF_AR_INVOICE_HEADER_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_AR_INVOICE_HEADER_INFO" AUTHID CURRENT_USER AS
/* $Header: gmfinvhs.pls 115.1 2002/11/11 00:39:41 rseshadr ship $ */
PROCEDURE GET_INVOICE_HEADER_INFO
          (STARTDATE              IN            DATE,
           ENDDATE                IN            DATE,
           INVOICEID              IN OUT NOCOPY NUMBER,
           LASTUPDATEDATE         OUT    NOCOPY DATE,
           VENDORID               OUT    NOCOPY NUMBER,
           INVOICENUM             IN OUT NOCOPY VARCHAR2,
           INVOICEAMOUNT          OUT    NOCOPY NUMBER,
           INVOICEDATE            IN OUT NOCOPY DATE,
           SOURC                  OUT    NOCOPY VARCHAR2,
           INVOICETYPELOOKUPCODE  OUT    NOCOPY VARCHAR2,
           DESCR                  OUT    NOCOPY VARCHAR2,
           CURRENCYCODE           OUT    NOCOPY VARCHAR2,
           TERMSCODE              OUT    NOCOPY VARCHAR2,
           HOLDREASON             OUT    NOCOPY VARCHAR2,
           BALANCEAMOUNT          IN OUT NOCOPY NUMBER,
           ROW_TO_FETCH           IN OUT NOCOPY NUMBER,
           STATUSCODE             OUT    NOCOPY NUMBER);
END GMF_AR_INVOICE_HEADER_INFO;

 

/
