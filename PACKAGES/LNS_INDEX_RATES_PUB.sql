--------------------------------------------------------
--  DDL for Package LNS_INDEX_RATES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_INDEX_RATES_PUB" AUTHID CURRENT_USER as
/* $Header: LNS_FLOATRATE_S.pls 120.0.12010000.1 2009/03/12 20:27:20 scherkas noship $ */

/*========================================================================
 | PUBLIC PROCEDURE UPDATE_FLOATING_RATE_LOANS
 |
 | DESCRIPTION
 |      This procedure gets called from CM to mass update index rate for floating loans.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      ERRBUF              OUT     Returns errors to CM
 |      RETCODE             OUT     Returns error code to CM
 |      INDEX_RATE_ID    IN       Inputs index rate type
 |      INTEREST_RATE_LINE_ID IN    Inputs index rate
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 20-Feb-2009            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE UPDATE_FLOATING_RATE_LOANS(
    ERRBUF              OUT NOCOPY     VARCHAR2,
    RETCODE             OUT NOCOPY     VARCHAR2,
    P_INDEX_RATE_ID   	IN             NUMBER);

-- This api updates floating rates for single loan
PROCEDURE UPDATE_LOAN_FLOATING_RATE(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);

END LNS_INDEX_RATES_PUB;

/
