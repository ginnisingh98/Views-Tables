--------------------------------------------------------
--  DDL for Package LNS_FUNDING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_FUNDING_PUB" AUTHID CURRENT_USER as
/* $Header: LNS_FUNDING_S.pls 120.16.12010000.2 2010/03/17 14:19:55 scherkas ship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

    TYPE LNS_DISB_HEADERS_REC IS RECORD(
        DISB_HEADER_ID		        NUMBER,
        LOAN_ID		                NUMBER,
        ACTIVITY_CODE		        VARCHAR2(30),
        DISBURSEMENT_NUMBER		    NUMBER,
        HEADER_AMOUNT		        NUMBER,
        HEADER_PERCENT		        NUMBER,
        STATUS		                VARCHAR2(30),
        TARGET_DATE                 DATE,
        PAYMENT_REQUEST_DATE        DATE,
        OBJECT_VERSION_NUMBER       NUMBER,
        AUTOFUNDING_FLAG            VARCHAR2(1),
        PHASE                       VARCHAR2(30),
        DESCRIPTION                 VARCHAR2(250)
    );

    TYPE LNS_DISB_LINES_REC IS RECORD(
        DISB_LINE_ID                NUMBER,
        DISB_HEADER_ID              NUMBER,
        DISB_LINE_NUMBER            NUMBER,
        LINE_AMOUNT                 NUMBER,
        LINE_PERCENT                NUMBER,
        PAYEE_PARTY_ID              NUMBER,
        BANK_ACCOUNT_ID             NUMBER,
        PAYMENT_METHOD_CODE         VARCHAR2(30),
        STATUS		                VARCHAR2(30),
        REQUEST_DATE                DATE,
        DISBURSEMENT_DATE           DATE,
        OBJECT_VERSION_NUMBER       NUMBER,
        INVOICE_INTERFACE_ID        NUMBER,
        INVOICE_ID                  NUMBER
    );

    Type Trxn_Attributes_Rec_Type IS Record(
        Application_Id              NUMBER,
        Payer_Legal_Entity_Id       NUMBER,
        Payer_Org_Id                NUMBER,
        Payer_Org_Type              VARCHAR2(30),
        Payee_Party_Id              NUMBER,
        Payee_Party_Site_Id         NUMBER,
        Supplier_Site_Id            NUMBER,
        Pay_Proc_Trxn_Type_Code     VARCHAR2(30),
        Payment_Currency            VARCHAR2(10),
        Payment_Amount              NUMBER,
        Payment_Function            VARCHAR2(30)
    );

    Type Default_Pmt_Attrs_Rec_Type is Record(
        Payment_Method_Name         VARCHAR2(100),
        Payment_Method_Code         VARCHAR2(30),
        Payee_BankAccount_Id        NUMBER,
        Payee_BankAccount_Number    VARCHAR2(100),
        Payee_BankAccount_Name      VARCHAR2(80)
    );

/*========================================================================
 | PUBLIC FUNCTION IS_SUBMIT_DISB_ENABLED
 |
 | DESCRIPTION
 |      This function returns is submition of a disbursement header enabled or not.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_DISB_HEADER_D IN            Disbursement header
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 18-07-2005            scherkas          Created
 |
 *=======================================================================*/
FUNCTION IS_SUBMIT_DISB_ENABLED(P_DISB_HEADER_ID IN NUMBER) RETURN VARCHAR2;



/*========================================================================
 | PUBLIC FUNCTION IS_CANCEL_DISB_ENABLED
 |
 | DESCRIPTION
 |      This function returns is cancel of a disbursements enabled or not.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_LOAN_D IN            Loan
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 18-07-2005            scherkas          Created
 |
 *=======================================================================*/
FUNCTION IS_CANCEL_DISB_ENABLED(P_LOAN_ID IN NUMBER) RETURN VARCHAR2;



/*========================================================================
 | PUBLIC FUNCTION IS_DISB_HDR_READ_ONLY
 |
 | DESCRIPTION
 |      This function returns is disb header read only or not.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_DISB_HEADER_ID IN            Disbursement header
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 13-09-2005            scherkas          Created
 |
 *=======================================================================*/
FUNCTION IS_DISB_HDR_READ_ONLY(P_DISB_HEADER_ID IN NUMBER) RETURN VARCHAR2;



/*========================================================================
 | PUBLIC FUNCTION IS_DISB_LINE_READ_ONLY
 |
 | DESCRIPTION
 |      This function returns is disb line read only or not.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_DISB_LINE_ID IN            Disbursement line
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 13-09-2005            scherkas          Created
 |
 *=======================================================================*/
FUNCTION IS_DISB_LINE_READ_ONLY(P_DISB_LINE_ID IN NUMBER) RETURN VARCHAR2;



/*========================================================================
 | PUBLIC FUNCTION IS_LAST_DISB_BEFORE_CONV
 |
 | DESCRIPTION
 |      This function returns is it last disb header before loan conversion.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_DISB_HEADER_ID IN            Disbursement header
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 13-09-2005            scherkas          Created
 |
 *=======================================================================*/
FUNCTION IS_LAST_DISB_BEFORE_CONV(P_DISB_HEADER_ID IN NUMBER) RETURN VARCHAR2;



/*========================================================================
 | PUBLIC PROCEDURE Get_Default_Payment_Attributes
 |
 | DESCRIPTION
 |      This procedure returns default payment attributes from Oracle Payments
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_Trxn_Attributes_Rec   IN          LNS_FUNDING_PUB.Trxn_Attributes_Rec_Type,
 |      X_default_pmt_attrs_rec OUT NOCOPY  LNS_FUNDING_PUB.Default_Pmt_Attrs_Rec_Type,
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 06-07-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE Get_Default_Payment_Attributes(
    P_API_VERSION		    IN              NUMBER,
    P_INIT_MSG_LIST		    IN              VARCHAR2,
    P_COMMIT			    IN              VARCHAR2,
    P_VALIDATION_LEVEL	    IN              NUMBER,
    P_Trxn_Attributes_Rec   IN              LNS_FUNDING_PUB.Trxn_Attributes_Rec_Type,
    X_default_pmt_attrs_rec OUT NOCOPY      LNS_FUNDING_PUB.Default_Pmt_Attrs_Rec_Type,
    X_RETURN_STATUS		    OUT NOCOPY      VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY      NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY      VARCHAR2);



 /*========================================================================
 | PUBLIC PROCEDURE INSERT_DISB_HEADER
 |
 | DESCRIPTION
 |      This procedure inserts new disbursement header
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_DISB_HEADER_REC       IN          LNS_FUNDING_PUB.LNS_DISB_HEADERS_REC,
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 06-07-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE INSERT_DISB_HEADER(
    P_API_VERSION		    IN              NUMBER,
    P_INIT_MSG_LIST		    IN              VARCHAR2,
    P_COMMIT			    IN              VARCHAR2,
    P_VALIDATION_LEVEL	    IN              NUMBER,
    P_DISB_HEADER_REC       IN              LNS_FUNDING_PUB.LNS_DISB_HEADERS_REC,
    X_RETURN_STATUS		    OUT NOCOPY      VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY      NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY      VARCHAR2);



 /*========================================================================
 | PUBLIC PROCEDURE UPDATE_DISB_HEADER
 |
 | DESCRIPTION
 |      This procedure updates disbursement header
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_DISB_HEADER_REC       IN          LNS_FUNDING_PUB.LNS_DISB_HEADERS_REC,
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 06-07-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE UPDATE_DISB_HEADER(
    P_API_VERSION		    IN              NUMBER,
    P_INIT_MSG_LIST		    IN              VARCHAR2,
    P_COMMIT			    IN              VARCHAR2,
    P_VALIDATION_LEVEL	    IN              NUMBER,
    P_DISB_HEADER_REC       IN              LNS_FUNDING_PUB.LNS_DISB_HEADERS_REC,
    X_RETURN_STATUS		    OUT NOCOPY      VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY      NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY      VARCHAR2);



 /*========================================================================
 | PUBLIC PROCEDURE DELETE_DISB_HEADER
 |
 | DESCRIPTION
 |      This procedure deletes disbursement header
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_DISB_HEADER_ID        IN          Disbursement Header ID
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 06-07-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE DELETE_DISB_HEADER(
    P_API_VERSION		    IN              NUMBER,
    P_INIT_MSG_LIST		    IN              VARCHAR2,
    P_COMMIT			    IN              VARCHAR2,
    P_VALIDATION_LEVEL	    IN              NUMBER,
    P_DISB_HEADER_ID        IN              NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY      VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY      NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY      VARCHAR2);



 /*========================================================================
 | PUBLIC PROCEDURE INSERT_DISB_LINE
 |
 | DESCRIPTION
 |      This procedure inserts new disbursement line
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_DISB_LINE_REC         IN  OUT NOCOPY        LNS_FUNDING_PUB.LNS_DISB_LINES_REC
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 06-07-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE INSERT_DISB_LINE(
    P_API_VERSION		    IN              NUMBER,
    P_INIT_MSG_LIST		    IN              VARCHAR2,
    P_COMMIT			    IN              VARCHAR2,
    P_VALIDATION_LEVEL	    IN              NUMBER,
    P_DISB_LINE_REC         IN              LNS_FUNDING_PUB.LNS_DISB_LINES_REC,
    X_RETURN_STATUS		    OUT NOCOPY      VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY      NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY      VARCHAR2);



 /*========================================================================
 | PUBLIC PROCEDURE UPDATE_DISB_LINE
 |
 | DESCRIPTION
 |      This procedure updates disbursement line
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_DISB_LINE_REC         IN          LNS_FUNDING_PUB.LNS_DISB_LINES_REC
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 06-07-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE UPDATE_DISB_LINE(
    P_API_VERSION		    IN              NUMBER,
    P_INIT_MSG_LIST		    IN              VARCHAR2,
    P_COMMIT			    IN              VARCHAR2,
    P_VALIDATION_LEVEL	    IN              NUMBER,
    P_DISB_LINE_REC         IN              LNS_FUNDING_PUB.LNS_DISB_LINES_REC,
    X_RETURN_STATUS		    OUT NOCOPY      VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY      NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY      VARCHAR2);



 /*========================================================================
 | PUBLIC PROCEDURE DELETE_DISB_LINE
 |
 | DESCRIPTION
 |      This procedure deletes disbursement line
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_DISB_LINE_ID          IN          Disbursement Line ID
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 06-07-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE DELETE_DISB_LINE(
    P_API_VERSION		    IN              NUMBER,
    P_INIT_MSG_LIST		    IN              VARCHAR2,
    P_COMMIT			    IN              VARCHAR2,
    P_VALIDATION_LEVEL	    IN              NUMBER,
    P_DISB_LINE_ID          IN              NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY      VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY      NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY      VARCHAR2);



/*========================================================================
 | PUBLIC PROCEDURE SUBMIT_DISBURSEMENT
 |
 | DESCRIPTION
 |      This procedure submits disbursement to AP.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_DISB_HEADER_ID        IN          Disbursement Header ID
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 06-23-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE SUBMIT_DISBURSEMENT(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_DISB_HEADER_ID        IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);



/*========================================================================
 | PUBLIC PROCEDURE VALIDATE_DISB_LINES
 |
 | DESCRIPTION
 |      This procedure validates all disbursement lines for a specific disbursement header.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_DISB_HEADER_ID        IN          Disbursement Header ID
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 11-08-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE VALIDATE_DISB_LINES(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_DISB_HEADER_ID        IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);



/*========================================================================
 | PUBLIC PROCEDURE VALIDATE_DISB_HEADERS
 |
 | DESCRIPTION
 |      This procedure validates all disbursement headers.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_LOAN_ID               IN          Loan ID
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 11-08-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE VALIDATE_DISB_HEADERS(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);



/*========================================================================
 | PUBLIC PROCEDURE DEFAULT_PROD_DISBURSEMENTS
 |
 | DESCRIPTION
 |      This procedure Defaults Disbursements for a loan based on product setup.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_LOAN_ID                   IN          Loan ID
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 12-07-2005            gbellary          Created
 |
 *=======================================================================*/
PROCEDURE DEFAULT_PROD_DISBURSEMENTS(
    P_LOAN_ID               IN          NUMBER);
    TYPE LOAN_PAYEE_REC IS RECORD(
        PAYEE_NAME                  VARCHAR2(240),
        TAXPAYER_ID                 VARCHAR2(30),
        TAX_REGISTRATION_ID         VARCHAR2(20),
        SUPPLIER_TYPE               VARCHAR2(30),
        PAYEE_NUMBER                VARCHAR2(30)
    );

/*========================================================================
 | PUBLIC PROCEDURE SubscribeTo_Payment_Event
 |
 | DESCRIPTION
 |      This procedure called by AP to confirm payment on invoice
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_Event_Type		    IN          Event type
 |      P_Check_ID  		    IN          Check ID
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 07-25-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE SubscribeTo_Payment_Event
    (P_Event_Type               IN             VARCHAR2,
    P_Check_ID                 IN             NUMBER,
    P_Return_Status            OUT     NOCOPY VARCHAR2,
    P_Msg_Count                OUT     NOCOPY NUMBER,
    P_Msg_Data                 OUT     NOCOPY VARCHAR2);



/*========================================================================
 | PUBLIC PROCEDURE COMPLETE_ALL_DISB
 |
 | DESCRIPTION
 |      This procedure is for testing purpose only.
 |      It completes all available disbursements for a loan and sets all to status fully paid.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_LOAN_ID               IN          Loan
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 07-26-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE COMPLETE_ALL_DISB(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);



/*========================================================================
 | PUBLIC PROCEDURE SUBMIT_AUTODISBURSEMENT
 |
 | DESCRIPTION
 |      This procedure submits 1-st disbursement of a loan
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_LOAN_ID               IN          Loan ID
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 07-26-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE SUBMIT_AUTODISBURSEMENT(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);



/*========================================================================
 | PUBLIC PROCEDURE APPROVE_CANCEL_REM_DISB
 |
 | DESCRIPTION
 |      This procedure to be called after approval of cancelation of disbursement schedule and
 |      cancels all remaining disbursements of a loan
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_LOAN_ID               IN          Loan
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 07-26-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE APPROVE_CANCEL_REM_DISB(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);



/*========================================================================
 | PUBLIC PROCEDURE SET_AUTOFUNDING
 |
 | DESCRIPTION
 |      This procedure sets autofunding flag for a loan.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_LOAN_ID               IN          Loan ID
 |      P_AUTOFUNDING_FLAG      IN          Autofunding flag
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 11-15-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE SET_AUTOFUNDING(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    P_AUTOFUNDING_FLAG      IN          VARCHAR2,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);



/*========================================================================
 | PUBLIC PROCEDURE REJECT_CANCEL_DISB
 |
 | DESCRIPTION
 |      This procedure to be called after rejection of cancelation of disbursement schedule and
 |      reactivate disbursement schedule of a loan
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_LOAN_ID               IN          Loan
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 07-26-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE REJECT_CANCEL_DISB(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);



/*========================================================================
 | PUBLIC PROCEDURE CANCEL_DISB_SCHEDULE
 |
 | DESCRIPTION
 |      This procedure only sets loan status to PENDING_CANCELLATION
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_LOAN_ID               IN          Loan
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 07-26-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE CANCEL_DISB_SCHEDULE(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);



/*========================================================================
 | PUBLIC PROCEDURE VALIDATE_DISB_FOR_APPR
 |
 | DESCRIPTION
 |      This procedure validates disbursement schedule for approval process.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_LOAN_ID               IN          Loan ID
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 11-08-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE VALIDATE_DISB_FOR_APPR(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);

/*************************** Old Stuff ******************************************/

    TYPE LOAN_PAYEE_SITE_REC IS RECORD(
        PAYEE_SITE_CODE             VARCHAR2(15),
        PAYEE_ID                    NUMBER,
        ADDRESS_LINE1               VARCHAR2(240),
        ADDRESS_LINE2               VARCHAR2(240),
        ADDRESS_LINE3               VARCHAR2(240),
        CITY                        VARCHAR2(25),
        STATE                       VARCHAR2(150),
        ZIP                         VARCHAR2(20),
        PROVINCE                    VARCHAR2(150),
        COUNTY                      VARCHAR2(150),
        COUNTRY                     VARCHAR2(25)
    );

    TYPE SITE_CONTACT_REC IS RECORD(
        PAYEE_SITE_ID               NUMBER,
        FIRST_NAME                  VARCHAR2(15),
        LAST_NAME                   VARCHAR2(20),
        TITLE                       VARCHAR2(30),
        PHONE                       VARCHAR2(15),
        FAX                         VARCHAR2(15),
        EMAIL                       VARCHAR2(2000)
    );

    TYPE BANK_ACCOUNT_USE_REC IS RECORD(
        PAYEE_ID                    NUMBER,
        PAYEE_SITE_ID               NUMBER,
        BANK_ACCOUNT_ID             NUMBER,
        PRIMARY_FLAG                VARCHAR2(1)
    );

    TYPE FUNDING_ADVICE_REC IS RECORD(
        FUNDING_ADVICE_ID           NUMBER,             /* optional: if null - will insert new advice; otherwise - update advice */
        LOAN_ID                     NUMBER,             /* required */
        LOAN_START_DATE             DATE,               /* required */
        FIRST_PAYMENT_DATE          DATE,               /* required */
        APPROVED_DATE               DATE,               /* for internal use - do not pass */
        DUE_DATE                    DATE,               /* required */
        AMOUNT                      NUMBER,             /* required */
        CURRENCY                    VARCHAR2(15),       /* required */
        DESCRIPTION                 VARCHAR2(255),      /* optional, if not passed - standard value will be assigned */
        PAYMENT_METHOD              VARCHAR2(30),       /* required */
        PAYEE_ID                    NUMBER,             /* required */
        PAYEE_SITE_ID               NUMBER,             /* required */
        SITE_CONTACT_ID             NUMBER,             /* optional */
        BANK_BRANCH_ID              NUMBER,             /* required */
        BANK_ACCOUNT_ID             NUMBER,             /* required */
        INVOICE_ID                  NUMBER,             /* for internal use - do not pass */
        REQUEST_ID                  NUMBER,             /* for internal use - do not pass */
        ADVICE_NUMBER               VARCHAR2(60),       /* optional, if not passed - standard value will be assigned */
        INVOICE_NUMBER              VARCHAR2(50),       /* optional, if not passed - standard value will be assigned */
        LOAN_STATUS                 VARCHAR2(30)        /* for internal use - do not pass */
    );

    TYPE INIT_FUNDING_ADVICE_REC IS RECORD(
        LOAN_ID                     NUMBER,             /* required */
        PAYMENT_METHOD              VARCHAR2(30),       /* required */
        PAYEE_ID                    NUMBER,             /* required */
        PAYEE_SITE_ID               NUMBER,             /* required */
        SITE_CONTACT_ID             NUMBER,             /* optional */
        BANK_BRANCH_ID              NUMBER,             /* required */
        BANK_ACCOUNT_ID             NUMBER             /* required */
    );


 /*========================================================================
 | PUBLIC PROCEDURE CREATE_PAYEE
 |
 | DESCRIPTION
 |      This procedure creates loan payee in AP
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_PAYEE_REC             IN          Payee record
 |      X_PAYEE_ID  		    OUT NOCOPY  Return payee id
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 09-22-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE CREATE_PAYEE(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_PAYEE_REC             IN          LNS_FUNDING_PUB.LOAN_PAYEE_REC,
    X_PAYEE_ID  		    OUT NOCOPY  NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);



 /*========================================================================
 | PUBLIC PROCEDURE CREATE_PAYEE_SITE
 |
 | DESCRIPTION
 |      This procedure creates loan payee site in AP
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_PAYEE_SITE_REC        IN          Payee record
 |      X_PAYEE_SITE_ID		    OUT NOCOPY  Returns payee site id
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 09-22-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE CREATE_PAYEE_SITE(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_PAYEE_SITE_REC        IN          LNS_FUNDING_PUB.LOAN_PAYEE_SITE_REC,
    X_PAYEE_SITE_ID 	    OUT NOCOPY  NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);



/*========================================================================
 | PUBLIC PROCEDURE CREATE_SITE_CONTACT
 |
 | DESCRIPTION
 |      This procedure creates site contact in AP
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_SITE_CONTACT_REC      IN          Site contact record
 |      X_SITE_CONTACT_ID	    OUT NOCOPY  Returns site contact id
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 09-22-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE CREATE_SITE_CONTACT(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_SITE_CONTACT_REC      IN          LNS_FUNDING_PUB.SITE_CONTACT_REC,
    X_SITE_CONTACT_ID 	    OUT NOCOPY  NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);



/*========================================================================
 | PUBLIC PROCEDURE CREATE_BANK_ACC_USE
 |
 | DESCRIPTION
 |      This procedure creates bank account use.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_BANK_ACC_USE_REC      IN          Bank account use record
 |      X_BANK_ACC_USE_ID	    OUT NOCOPY  Returns bank account use id
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 11-12-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE CREATE_BANK_ACC_USE(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_BANK_ACC_USE_REC      IN          LNS_FUNDING_PUB.BANK_ACCOUNT_USE_REC,
    X_BANK_ACC_USE_ID 	    OUT NOCOPY  NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);



/*========================================================================
 | PUBLIC PROCEDURE INIT_FUNDING_ADVICE
 |
 | DESCRIPTION
 |      This procedure inits funding advice.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_INIT_FUNDING_REC      IN          Init funding advice record
 |      X_FUNDING_ADVICE_ID	    OUT NOCOPY  Returns funding advice id
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 11-03-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE INIT_FUNDING_ADVICE(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_INIT_FUNDING_REC      IN          LNS_FUNDING_PUB.INIT_FUNDING_ADVICE_REC,
    X_FUNDING_ADVICE_ID     OUT NOCOPY  NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);




/*========================================================================
 | PUBLIC PROCEDURE VALIDATE_FUNDING_ADVICE
 |
 | DESCRIPTION
 |      This procedure validates funding advice.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_LOAN_ID               IN          Loan ID
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 11-08-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE VALIDATE_FUNDING_ADVICE(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);



/*========================================================================
 | PUBLIC PROCEDURE CREATE_FUNDING_ADVICE
 |
 | DESCRIPTION
 |      This procedure is for automatic funding advice creation.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_LOAN_ID               IN          Loan ID
 |      X_FUNDING_ADVICE_ID	    OUT NOCOPY  Returns funding advice id
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 11-03-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE CREATE_FUNDING_ADVICE(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    X_FUNDING_ADVICE_ID     OUT NOCOPY  NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);




/*========================================================================
 | PUBLIC PROCEDURE CREATE_FUNDING_ADVICE
 |
 | DESCRIPTION
 |      This procedure creates funding advice.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_FUNDING_ADVICE_REC    IN          Funding advice record
 |      X_FUNDING_ADVICE_ID	    OUT NOCOPY  Returns funding advice id
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 11-03-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE CREATE_FUNDING_ADVICE(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_FUNDING_ADVICE_REC    IN          LNS_FUNDING_PUB.FUNDING_ADVICE_REC,
    X_FUNDING_ADVICE_ID     OUT NOCOPY  NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);



/*========================================================================
 | PUBLIC FUNCTION GET_FUNDING_ADVICE_NUMBER
 |
 | DESCRIPTION
 |      This procedure generates new funding advice number.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_LOAN_ID IN    Loan ID
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 11-03-2004            scherkas          Created
 |
 *=======================================================================*/
FUNCTION GET_FUNDING_ADVICE_NUMBER(P_LOAN_ID IN NUMBER) RETURN VARCHAR2;



/*========================================================================
 | PUBLIC FUNCTION GET_FUNDING_ADVICE_DESC
 |
 | DESCRIPTION
 |      This procedure generates new funding advice description.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_LOAN_ID IN    Loan ID
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 11-03-2004            scherkas          Created
 |
 *=======================================================================*/
FUNCTION GET_FUNDING_ADVICE_DESC(P_LOAN_ID IN NUMBER) RETURN VARCHAR2;


/*========================================================================
 | PUBLIC PROCEDURE CHECK_FUNDING_STATUS
 |
 | DESCRIPTION
 |      This procedure checks for funding status of:
 |          - all funding advices or
 |          - all funding advices for particular loan or
 |          - one particular funding advice
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_LOAN_ID               IN          Loan ID
 |      P_FUNDING_ADVICE_ID     IN          Funding advice ID
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 11-30-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE CHECK_FUNDING_STATUS(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    P_FUNDING_ADVICE_ID     IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);




/*========================================================================
 | PUBLIC PROCEDURE LNS_CHK_FUND_STAT_CONCUR
 |
 | DESCRIPTION
 |      This procedure got called from concurent manager to check funding status
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      ERRBUF              OUT     Returns errors to CM
 |      RETCODE             OUT     Returns error code to CM
 |      LOAN_ID             IN      Inputs loan
 |      FUNDING_ADVICE_ID   IN      Input funding advice
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 12-02-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE LNS_CHK_FUND_STAT_CONCUR(
	    ERRBUF              OUT NOCOPY     VARCHAR2,
	    RETCODE             OUT NOCOPY     VARCHAR2,
        LOAN_ID             IN             NUMBER,
        FUNDING_ADVICE_ID   IN             NUMBER);



/*========================================================================
 | PUBLIC PROCEDURE VALIDATE_DISB_FOR_PAYOFF
 |
 | DESCRIPTION
 |      This procedure validates disbursements for payoff process
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_LOAN_ID               IN          Loan ID
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 12-08-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE VALIDATE_DISB_FOR_PAYOFF(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);



/*========================================================================
 | PUBLIC PROCEDURE CANCEL_SINGLE_DISB
 |
 | DESCRIPTION
 |      This procedure cancels single disbursement header with lines
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_INVOICE_ID  		    IN          Check ID
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 07-25-2005            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE CANCEL_SINGLE_DISB(
    P_API_VERSION               IN      NUMBER,
    P_INIT_MSG_LIST             IN      VARCHAR2,
    P_COMMIT                    IN      VARCHAR2,
    P_VALIDATION_LEVEL          IN      NUMBER,
    P_DISB_HEADER_ID            IN      NUMBER,
    X_Return_Status             OUT     NOCOPY VARCHAR2,
    X_Msg_Count                 OUT     NOCOPY NUMBER,
    X_Msg_Data                  OUT     NOCOPY VARCHAR2);



/*========================================================================
 | PUBLIC PROCEDURE CHECK_FOR_VOIDED_INVOICES
 |
 | DESCRIPTION
 |      This procedure checks for voided AP invoices and cancelles appropriate disb lines and headers in Loans
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_API_VERSION		    IN          Standard in parameter
 |      P_INIT_MSG_LIST		    IN          Standard in parameter
 |      P_COMMIT			    IN          Standard in parameter
 |      P_VALIDATION_LEVEL	    IN          Standard in parameter
 |      P_LOAN_ID               IN          Loan ID
 |      X_RETURN_STATUS		    OUT NOCOPY  Standard out parameter
 |      X_MSG_COUNT			    OUT NOCOPY  Standard out parameter
 |      X_MSG_DATA	    	    OUT NOCOPY  Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 01-25-2010            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE CHECK_FOR_VOIDED_INVOICES(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);



/*========================================================================
 | PUBLIC PROCEDURE CREATE_DISBURSEMENT
 |
 | DESCRIPTION
 |      This procedure creates quick disbursement
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_LOAN_ID                   IN          Loan ID
 |      P_DESCRIPTION               IN          Descrition
 |      P_AMOUNT                    IN          Amount
 |      P_DUE_DATE                  IN          Due Date
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 02-02-2010            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE CREATE_DISBURSEMENT(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    P_DESCRIPTION           IN          VARCHAR2,
    P_AMOUNT                IN          NUMBER,
    P_DUE_DATE              IN          DATE,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);



END LNS_FUNDING_PUB;

/
