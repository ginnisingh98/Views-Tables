--------------------------------------------------------
--  DDL for Package PA_PWP_INVOICE_REL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PWP_INVOICE_REL" AUTHID CURRENT_USER AS
--  $Header: PAPWPRIS.pls 120.0.12010000.3 2008/11/24 06:50:29 jjgeorge noship $

   G_ORG_ID                         NUMBER;
   G_REQUEST_ID                     NUMBER;
   P_DEBUG_MODE                     VARCHAR(1);
 /* TYPE OF MESSAGE */
   LOG                      NUMBER := 1;
   DEBUG                    NUMBER := 2;


Type InvoiceId Is Table Of AP_INVOICES_ALL.INVOICE_ID%Type Index By Binary_Integer;

PROCEDURE  RELEASE_INVOICE (  ERRBUF                  OUT NOCOPY VARCHAR2
                             ,RETCODE                 OUT NOCOPY VARCHAR2
                             ,P_MODE           VARCHAR2
                             ,P_PROJECT_TYPE       VARCHAR2
                             ,P_PROJ_NUM          VARCHAR2
                             ,P_FROM_PROJ_NUM    VARCHAR2
                             ,P_TO_PROJ_NUM      VARCHAR2
                             ,P_CUSTOMER_NAME    VARCHAR2
                             ,P_CUSTOMER_NUMBER  NUMBER
                             ,P_REC_DATE_FROM    VARCHAR2
                             ,P_REC_DATE_TO      VARCHAR2
			                       ,P_SORT VARCHAR2
			    );


PROCEDURE PAAP_RELEASE_HOLD (P_INV_TBL          IN INVOICEID
                              ,X_RETURN_STATUS   OUT NOCOPY VARCHAR2
                              ,X_MSG_COUNT       OUT NOCOPY NUMBER
                              ,X_MSG_DATA        OUT NOCOPY VARCHAR2);


PROCEDURE WRITE_LOG (   P_MESSAGE_TYPE   IN NUMBER,
                        P_MESSAGE     IN VARCHAR2);

FUNCTION IS_PROCESSED ( P_INVOICE_ID IN NUMBER )
	RETURN VARCHAR2 ;

FUNCTION IS_ELIGIBLE ( P_INVOICE_ID IN NUMBER )
	RETURN VARCHAR2 ;

FUNCTION IS_BILLED ( P_INVOICE_ID IN NUMBER )
	RETURN VARCHAR2 ;
END PA_PWP_INVOICE_REL;

/
