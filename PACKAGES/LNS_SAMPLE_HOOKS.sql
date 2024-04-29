--------------------------------------------------------
--  DDL for Package LNS_SAMPLE_HOOKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_SAMPLE_HOOKS" AUTHID CURRENT_USER as
/* $Header: LNS_SMPL_HOOKS_S.pls 120.0.12010000.1 2009/07/02 17:42:01 scherkas noship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/


 /*========================================================================
 | PUBLIC PROCEDURE SHIFT_PAY_START_DATES
 |
 | DESCRIPTION
 |      This procedure implements sample algorithm for shifting first interest payment and
 |       first principal payment dates on full disbursement payment in AP. New dates are returned back to caller.
 |
 | PSEUDO CODE/LOGIC
 |    NEW_INT_START_DATE = ORIG_INT_START_DATE + diff in months between ORIG_LOAN_START_DATE and NEW_LOAN_START_DATE
 |    NEW_PRIN_START_DATE = ORIG_PRIN_START_DATE + diff in months between ORIG_LOAN_START_DATE and NEW_LOAN_START_DATE
 |
 | PARAMETERS
 |      P_LOAN_ID               IN          Loan ID
 |      P_DISBURSEMENT_DATE     IN          Disbursement Date
 |      P_ORIG_LOAN_START_DATE  IN          Original loan start date
 |      P_ORIG_INT_START_DATE   IN          Original interest payment start date. Passed for all amortization methods.
 |      P_ORIG_PRIN_START_DATE  IN          Original principal payment start date. Passed only for Seperate Schedule method.
 |      P_ORIG_LOAN_MATUR_DATE  IN          Original loan maturity date
 |      P_NEW_LOAN_START_DATE   IN          New loan start date
 |      P_NEW_LOAN_MATUR_DATE   IN OUT NOCOPY New loan maturity date. If changed - new value will be stored
 |      X_NEW_INT_START_DATE    OUT NOCOPY  New/calculated interest payment start date. Must be returned for all amortization methods.
 |      X_NEW_PRIN_START_DATE   OUT NOCOPY  New/calculated principal payment start date. Must be returned only for Seperate Schedule method.
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
 | 12-23-2004            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE SHIFT_PAY_START_DATES(
        P_LOAN_ID               IN              NUMBER,
        P_DISBURSEMENT_DATE     IN              DATE,
        P_ORIG_LOAN_START_DATE  IN              DATE,
        P_ORIG_INT_START_DATE   IN              DATE,
        P_ORIG_PRIN_START_DATE  IN              DATE,
        P_ORIG_LOAN_MATUR_DATE  IN              DATE,
        P_NEW_LOAN_START_DATE   IN              DATE,
        P_NEW_LOAN_MATUR_DATE   IN OUT NOCOPY   DATE,
        X_NEW_INT_START_DATE    OUT NOCOPY      DATE,
        X_NEW_PRIN_START_DATE   OUT NOCOPY      DATE);


END ;

/
