--------------------------------------------------------
--  DDL for Package JL_BR_INTEREST_HANDLING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_BR_INTEREST_HANDLING" AUTHID CURRENT_USER AS
/* $Header: jlbrsins.pls 120.4.12010000.2 2009/07/09 11:44:22 vspuli ship $ */

  -- bug 8621688
  PROCEDURE JL_BR_INTEREST(X_Interest_Type           IN VARCHAR2,
                           X_Interest_Rate_Amount    IN NUMBER,
                           X_Period_Days             IN NUMBER,
                           X_Interest_Formula 	   IN VARCHAR2,
                           X_Grace_Days   		   IN NUMBER,
                           X_Penalty_Type		   IN VARCHAR2,
                           X_Penalty_Rate_Amount     IN NUMBER,
                           X_Due_Date                IN DATE,
                           X_Payment_Date            IN DATE,
                           X_Invoice_Amount          IN NUMBER,
                           X_JLBR_Calendar     	   IN VARCHAR2,
                           X_JLBR_Local_Holiday      IN VARCHAR2,
                           X_JLBR_Action_Non_Workday IN VARCHAR2,
                           X_Interest_Calculated     IN OUT NOCOPY NUMBER,
                           X_Days_Late               IN OUT NOCOPY NUMBER,
                           X_Exit_Code               OUT NOCOPY NUMBER,
                           X_ORG_ID                  IN NUMBER
                           );


  PROCEDURE JL_BR_INTEREST(X_Interest_Type           IN VARCHAR2,
                           X_Interest_Rate_Amount    IN NUMBER,
                           X_Period_Days             IN NUMBER,
                           X_Interest_Formula 	   IN VARCHAR2,
                           X_Grace_Days   		   IN NUMBER,
                           X_Penalty_Type		   IN VARCHAR2,
                           X_Penalty_Rate_Amount     IN NUMBER,
                           X_Due_Date                IN DATE,
                           X_Payment_Date            IN DATE,
                           X_Invoice_Amount          IN NUMBER,
                           X_JLBR_Calendar     	   IN VARCHAR2,
                           X_JLBR_Local_Holiday      IN VARCHAR2,
                           X_JLBR_Action_Non_Workday IN VARCHAR2,
                           X_Interest_Calculated     IN OUT NOCOPY NUMBER,
                           X_Days_Late               IN OUT NOCOPY NUMBER,
                           X_Exit_Code               OUT NOCOPY NUMBER);

  PROCEDURE JL_BR_CHANGE_INT_DES(P_invoice_related  NUMBER,
                                 P_invoice_original NUMBER,
                                 P_payment_num_org  NUMBER);

  PROCEDURE JL_BR_INTEREST(X_Interest_Type           IN VARCHAR2,
                           X_Interest_Rate_Amount    IN NUMBER,
                           X_Period_Days             IN NUMBER,
                           X_Interest_Formula 	   IN VARCHAR2,
                           X_Grace_Days   		   IN NUMBER,
                           X_Penalty_Type		   IN VARCHAR2,
                           X_Penalty_Rate_Amount     IN NUMBER,
                           X_Due_Date                IN DATE,
                           X_Payment_Date            IN DATE,
                           X_Invoice_Amount          IN NUMBER,
                           X_JLBR_Calendar     	   IN VARCHAR2,
                           X_JLBR_Local_Holiday      IN VARCHAR2,
                           X_JLBR_Action_Non_Workday IN VARCHAR2,
                           X_Interest_Calculated     IN OUT NOCOPY NUMBER,
                           X_Days_Late               IN OUT NOCOPY NUMBER,
                           X_Exit_Code               OUT NOCOPY NUMBER,
                           X_JLBR_State              IN VARCHAR2); --Bug 2319552

END JL_BR_INTEREST_HANDLING;

/
