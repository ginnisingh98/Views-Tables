--------------------------------------------------------
--  DDL for Package LNS_EXT_LOAN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_EXT_LOAN_PUB" AUTHID CURRENT_USER as
/* $Header: LNS_EXT_LOAN_S.pls 120.0.12010000.1 2008/11/25 14:14:59 scherkas noship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

    TYPE LOAN_EXT_REC IS RECORD(
        LOAN_EXT_ID                 NUMBER,
        LOAN_ID                     NUMBER,
        DESCRIPTION                 VARCHAR2(30),
        EXT_TERM                    NUMBER,
        EXT_TERM_PERIOD             VARCHAR2(30),
        EXT_BALLOON_TYPE            VARCHAR2(30),
        EXT_BALLOON_AMOUNT          NUMBER,
        EXT_AMORT_TERM              NUMBER,
        EXT_RATE                    NUMBER,
        EXT_SPREAD                  NUMBER,
        EXT_IO_FLAG                 VARCHAR2(1),
        EXT_FLOATING_FLAG           VARCHAR2(1),
        EXT_INDEX_DATE              DATE
    );


    -- this record type is for calculating new loan terms
    TYPE NEW_TERM_REC IS RECORD(
        LOAN_ID                     NUMBER,   -- in/out; required
        EXT_TERM                    NUMBER,   -- in/out; required
        EXT_TERM_PERIOD             VARCHAR2(30),   -- in/out; required
        EXT_BALLOON_TYPE            VARCHAR2(30),   -- in/out; required
        EXT_BALLOON_AMOUNT          NUMBER,   -- in/out; required
        EXT_AMORT_TERM              NUMBER,   -- in/out; required
        OLD_TERM                    NUMBER,   -- out
        OLD_TERM_PERIOD             VARCHAR2(30),   -- out
        OLD_BALLOON_TYPE            VARCHAR2(30),   -- out
        OLD_BALLOON_AMOUNT          NUMBER,   -- out
        OLD_AMORT_TERM              NUMBER,   -- out
        OLD_MATURITY_DATE           DATE,   -- out
        OLD_INSTALLMENTS            NUMBER, -- out
        NEW_TERM                    NUMBER,   -- out
        NEW_TERM_PERIOD             VARCHAR2(30),   -- out
        NEW_BALLOON_TYPE            VARCHAR2(30),   -- out
        NEW_BALLOON_AMOUNT          NUMBER,   -- out
        NEW_AMORT_TERM              NUMBER,   -- out
        NEW_MATURITY_DATE           DATE,   -- out
--        BEGIN_EXT_INSTAL_NUMBER     NUMBER,   -- out
--        END_EXT_INSTAL_NUMBER       NUMBER,   -- out
        NEW_INSTALLMENTS            NUMBER -- out
    );



/*========================================================================
 | PUBLIC PROCEDURE SAVE_LOAN_EXTENSION
 |
 | DESCRIPTION
 |      This procedure inserts/updates loan extension in lns_loan_extensions table
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |    P_API_VERSION		    IN              Standard in parameter
 |    P_INIT_MSG_LIST		IN              Standard in parameter
 |    P_COMMIT			    IN              Standard in parameter
 |    P_VALIDATION_LEVEL	IN              Standard in parameter
 |    P_LOAN_EXT_REC        IN OUT NOCOPY   LNS_EXT_LOAN_PUB.LOAN_EXT_REC record
 |    X_RETURN_STATUS		OUT NOCOPY      Standard out parameter
 |    X_MSG_COUNT			OUT NOCOPY      Standard out parameter
 |    X_MSG_DATA	    	OUT NOCOPY      Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 09-25-2007            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE SAVE_LOAN_EXTENSION(
    P_API_VERSION		IN              NUMBER,
    P_INIT_MSG_LIST		IN              VARCHAR2,
    P_COMMIT			IN              VARCHAR2,
    P_VALIDATION_LEVEL	IN              NUMBER,
    P_LOAN_EXT_REC      IN OUT NOCOPY   LNS_EXT_LOAN_PUB.LOAN_EXT_REC,
    X_RETURN_STATUS		OUT NOCOPY      VARCHAR2,
    X_MSG_COUNT			OUT NOCOPY      NUMBER,
    X_MSG_DATA	    	OUT NOCOPY      VARCHAR2);



/*========================================================================
 | PUBLIC PROCEDURE APPROVE_LOAN_EXTENSION
 |
 | DESCRIPTION
 |      This procedure approves loan extension and updates loan term data in
 |      lns_loan_headers_all from lns_loan_extensions table
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |    P_API_VERSION		    IN              Standard in parameter
 |    P_INIT_MSG_LIST		IN              Standard in parameter
 |    P_COMMIT			    IN              Standard in parameter
 |    P_VALIDATION_LEVEL	IN              Standard in parameter
 |    P_LOAN_EXT_ID         IN              Loan extension ID
 |    X_RETURN_STATUS		OUT NOCOPY      Standard out parameter
 |    X_MSG_COUNT			OUT NOCOPY      Standard out parameter
 |    X_MSG_DATA	    	OUT NOCOPY      Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 09-25-2007            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE APPROVE_LOAN_EXTENSION(
    P_API_VERSION		IN          NUMBER,
    P_INIT_MSG_LIST		IN          VARCHAR2,
    P_COMMIT			IN          VARCHAR2,
    P_VALIDATION_LEVEL	IN          NUMBER,
    P_LOAN_EXT_ID       IN          NUMBER,
    X_RETURN_STATUS		OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	OUT NOCOPY  VARCHAR2);



/*========================================================================
 | PUBLIC PROCEDURE REJECT_LOAN_EXTENSION
 |
 | DESCRIPTION
 |      This procedure rejects loan extension. No changes is made in lns_loan_headers_all table
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |    P_API_VERSION		    IN              Standard in parameter
 |    P_INIT_MSG_LIST		IN              Standard in parameter
 |    P_COMMIT			    IN              Standard in parameter
 |    P_VALIDATION_LEVEL	IN              Standard in parameter
 |    P_LOAN_EXT_ID         IN              Loan extension ID
 |    X_RETURN_STATUS		OUT NOCOPY      Standard out parameter
 |    X_MSG_COUNT			OUT NOCOPY      Standard out parameter
 |    X_MSG_DATA	    	OUT NOCOPY      Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 09-25-2007            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE REJECT_LOAN_EXTENSION(
    P_API_VERSION		IN          NUMBER,
    P_INIT_MSG_LIST		IN          VARCHAR2,
    P_COMMIT			IN          VARCHAR2,
    P_VALIDATION_LEVEL	IN          NUMBER,
    P_LOAN_EXT_ID       IN          NUMBER,
    X_RETURN_STATUS		OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	OUT NOCOPY  VARCHAR2);



/*========================================================================
 | PUBLIC PROCEDURE CALC_NEW_TERMS
 |
 | DESCRIPTION
 |      This procedure calculates and returns new loan terms based on input extension loan term data.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |    P_API_VERSION		    IN              Standard in parameter
 |    P_INIT_MSG_LIST		IN              Standard in parameter
 |    P_COMMIT			    IN              Standard in parameter
 |    P_VALIDATION_LEVEL	IN              Standard in parameter
 |    P_EXT_LOAN_REC        IN OUT NOCOPY   LNS_EXT_LOAN_PUB.NEW_TERM_REC record
 |    X_RETURN_STATUS		OUT NOCOPY      Standard out parameter
 |    X_MSG_COUNT			OUT NOCOPY      Standard out parameter
 |    X_MSG_DATA	    	OUT NOCOPY      Standard out parameter
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 09-25-2007            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE CALC_NEW_TERMS(
    P_API_VERSION		IN          NUMBER,
    P_INIT_MSG_LIST		IN          VARCHAR2,
    P_COMMIT			IN          VARCHAR2,
    P_VALIDATION_LEVEL	IN          NUMBER,
    P_NEW_TERM_REC      IN OUT NOCOPY  LNS_EXT_LOAN_PUB.NEW_TERM_REC,
    X_RETURN_STATUS		OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	OUT NOCOPY  VARCHAR2);



END LNS_EXT_LOAN_PUB;

/
