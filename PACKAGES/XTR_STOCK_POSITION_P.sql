--------------------------------------------------------
--  DDL for Package XTR_STOCK_POSITION_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_STOCK_POSITION_P" AUTHID CURRENT_USER as
/* $Header: xtrsposs.pls 120.1 2005/10/27 09:59:21 eaggarwa noship $*/

PROCEDURE MAINTAIN_STK_POSITION_HISTORY(
 P_START_DATE                   IN DATE,
 P_DEAL_NUMBER                  IN NUMBER,
 P_TRANSACTION_NUMBER           IN NUMBER,
 P_COMPANY_CODE                 IN VARCHAR2,
 P_CURRENCY                     IN VARCHAR2,
 P_DEAL_TYPE                    IN VARCHAR2,
 P_DEAL_SUBTYPE                 IN VARCHAR2,
 P_PRODUCT_TYPE                 IN VARCHAR2,
 P_PORTFOLIO_CODE               IN VARCHAR2,
 P_CPARTY_CODE                  IN VARCHAR2,
 P_CONTRA_CCY                   IN VARCHAR2,
 P_CURRENCY_COMBINATION         IN VARCHAR2,
 P_ACCOUNT_NO                   IN VARCHAR2,
 P_TRANSACTION_RATE             IN NUMBER,
 P_YEAR_CALC_TYPE               IN VARCHAR2,
 P_BASE_REF_AMOUNT              IN NUMBER,
 P_BASE_RATE                    IN NUMBER,
 P_STATUS_CODE                  IN VARCHAR2,
 P_INTEREST			IN NUMBER,
 P_ACTION                       IN VARCHAR2

   );

PROCEDURE SNAPSHOT_STK_POSITION_HISTORY(
  P_AS_AT_DATE                   IN DATE,
 P_DEAL_NUMBER                  IN NUMBER,
 P_TRANSACTION_NUMBER           IN NUMBER,
 P_COMPANY_CODE                 IN VARCHAR2,
 P_CURRENCY                     IN VARCHAR2,
 P_DEAL_TYPE                    IN VARCHAR2,
 P_DEAL_SUBTYPE                 IN VARCHAR2,
 P_PRODUCT_TYPE                 IN VARCHAR2,
 P_PORTFOLIO_CODE               IN VARCHAR2,
 P_CPARTY_CODE                  IN VARCHAR2,
 P_CONTRA_CCY                   IN VARCHAR2,
 P_CURRENCY_COMBINATION         IN VARCHAR2,
 P_ACCOUNT_NO                   IN VARCHAR2,
 P_TRANSACTION_RATE             IN NUMBER,
 P_YEAR_CALC_TYPE               IN VARCHAR2,
 P_BASE_REF_AMOUNT              IN NUMBER,
 P_BASE_RATE                    IN NUMBER,
 P_STATUS_CODE                  IN VARCHAR2,
 P_START_DATE			IN DATE,
 P_INTEREST                     IN NUMBER,
  P_START_AMOUNT     IN  NUMBER
  );


PROCEDURE SNAPSHOT_STK_COST_OF_FUNDS(errbuf   OUT NOCOPY VARCHAR2,
                                retcode OUT NOCOPY NUMBER,
                                p_deal_number IN  NUMBER default NULL);


END XTR_STOCK_POSITION_P;


 

/
