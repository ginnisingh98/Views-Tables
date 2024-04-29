--------------------------------------------------------
--  DDL for Package LNS_SAMPLE_CUSTOM_CONDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_SAMPLE_CUSTOM_CONDS" AUTHID CURRENT_USER as
/* $Header: LNS_SMPL_CUSTOM_CONDS_S.pls 120.0.12010000.1 2010/03/22 15:29:56 scherkas noship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/


 /*========================================================================
 | PUBLIC PROCEDURE VALIDATE_INCREASE_LOAN_AMOUNT1
 |
 | DESCRIPTION
 |      This procedure implements sample validation of increase loan amount - increase of loan amount must not be greater
 |      than 10% of original loan amount.
 |
 | PSEUDO CODE/LOGIC
 |    100%*(increase_amount/original_loan_amount) <= 10%
 |
 | PARAMETERS
 |      P_COND_ASSIGNMENT_ID    IN          Condition Assignment ID
 |      X_CONDITION_MET         OUT NOCOPY  Returned value that indicates if condition is met or not. Valid values Y, N
 |      X_ERROR                 OUT NOCOPY  If condition is not met this returned error message explains why.
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
 | 12-07-2009            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE VALIDATE_INCREASE_LOAN_AMOUNT1(
    P_COND_ASSIGNMENT_ID    IN          NUMBER,
    X_CONDITION_MET         OUT NOCOPY  VARCHAR2,
    X_ERROR                 OUT NOCOPY  VARCHAR2);


 /*========================================================================
 | PUBLIC PROCEDURE VALIDATE_LOAN_APPR_COND1
 |
 | DESCRIPTION
 |      This procedure implements sample validation for loan approval.
 |      This procedure always returns success.
 |
 | PSEUDO CODE/LOGIC
 |    100%*(increase_amount/original_loan_amount) <= 10%
 |
 | PARAMETERS
 |      P_COND_ASSIGNMENT_ID    IN          Condition Assignment ID
 |      X_CONDITION_MET         OUT NOCOPY  Returned value that indicates if condition is met or not. Valid values Y, N
 |      X_ERROR                 OUT NOCOPY  If condition is not met this returned error message explains why.
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
 | 12-07-2009            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE VALIDATE_LOAN_APPR_COND1(
    P_COND_ASSIGNMENT_ID    IN          NUMBER,
    X_CONDITION_MET         OUT NOCOPY  VARCHAR2,
    X_ERROR                 OUT NOCOPY  VARCHAR2);


 /*========================================================================
 | PUBLIC PROCEDURE VALIDATE_LOAN_APPR_COND2
 |
 | DESCRIPTION
 |      This procedure implements sample validation for loan approval.
 |      This procedure always returns failure.
 |
 | PSEUDO CODE/LOGIC
 |    100%*(increase_amount/original_loan_amount) <= 10%
 |
 | PARAMETERS
 |      P_COND_ASSIGNMENT_ID    IN          Condition Assignment ID
 |      X_CONDITION_MET         OUT NOCOPY  Returned value that indicates if condition is met or not. Valid values Y, N
 |      X_ERROR                 OUT NOCOPY  If condition is not met this returned error message explains why.
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
 | 12-07-2009            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE VALIDATE_LOAN_APPR_COND2(
    P_COND_ASSIGNMENT_ID    IN          NUMBER,
    X_CONDITION_MET         OUT NOCOPY  VARCHAR2,
    X_ERROR                 OUT NOCOPY  VARCHAR2);


 /*========================================================================
 | PUBLIC PROCEDURE VALIDATE_DISB_AMOUNT
 |
 | DESCRIPTION
 |      This procedure implements sample validation of disbursement amount - disbursement amount must be greater then
 |      or equal to 20% of current loan amount.
 |
 | PSEUDO CODE/LOGIC
 |    100%*(disbursement_amount/loan_amount) >= 20%
 |
 | PARAMETERS
 |      P_COND_ASSIGNMENT_ID    IN          Condition Assignment ID
 |      X_CONDITION_MET         OUT NOCOPY  Returned value that indicates if condition is met or not. Valid values Y, N
 |      X_ERROR                 OUT NOCOPY  If condition is not met this returned error message explains why.
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
 | 12-07-2009            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE VALIDATE_DISB_AMOUNT(
    P_COND_ASSIGNMENT_ID    IN          NUMBER,
    X_CONDITION_MET         OUT NOCOPY  VARCHAR2,
    X_ERROR                 OUT NOCOPY  VARCHAR2);


 /*========================================================================
 | PUBLIC PROCEDURE VALIDATE_DISB1_AMOUNT
 |
 | DESCRIPTION
 |      This procedure implements sample validation of disbursement amount - disbursement amount must be
 |      or equal to 50% of current loan amount.
 |
 | PSEUDO CODE/LOGIC
 |    100%*(disbursement_amount/loan_amount) = 50%
 |
 | PARAMETERS
 |      P_COND_ASSIGNMENT_ID    IN          Condition Assignment ID
 |      X_CONDITION_MET         OUT NOCOPY  Returned value that indicates if condition is met or not. Valid values Y, N
 |      X_ERROR                 OUT NOCOPY  If condition is not met this returned error message explains why.
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
 | 12-07-2009            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE VALIDATE_DISB1_AMOUNT(
    P_COND_ASSIGNMENT_ID    IN          NUMBER,
    X_CONDITION_MET         OUT NOCOPY  VARCHAR2,
    X_ERROR                 OUT NOCOPY  VARCHAR2);


 /*========================================================================
 | PUBLIC PROCEDURE VALIDATE_NUM_DISB_IN_MONTH
 |
 | DESCRIPTION
 |      This procedure implements sample validation of disbursement -
 |      number of disbursements in any given month cannot be greater than 1
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_COND_ASSIGNMENT_ID    IN          Condition Assignment ID
 |      X_CONDITION_MET         OUT NOCOPY  Returned value that indicates if condition is met or not. Valid values Y, N
 |      X_ERROR                 OUT NOCOPY  If condition is not met this returned error message explains why.
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
 | 12-07-2009            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE VALIDATE_NUM_DISB_IN_MONTH(
    P_COND_ASSIGNMENT_ID    IN          NUMBER,
    X_CONDITION_MET         OUT NOCOPY  VARCHAR2,
    X_ERROR                 OUT NOCOPY  VARCHAR2);


 /*========================================================================
 | PUBLIC PROCEDURE VALIDATE_NUM_DISB_IN_YEAR
 |
 | DESCRIPTION
 |      This procedure implements sample validation of disbursement -
 |      number of disbursements in calendar year cannot be greater than 4
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      P_COND_ASSIGNMENT_ID    IN          Condition Assignment ID
 |      X_CONDITION_MET         OUT NOCOPY  Returned value that indicates if condition is met or not. Valid values Y, N
 |      X_ERROR                 OUT NOCOPY  If condition is not met this returned error message explains why.
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
 | 12-07-2009            scherkas          Created
 |
 *=======================================================================*/
PROCEDURE VALIDATE_NUM_DISB_IN_YEAR(
    P_COND_ASSIGNMENT_ID    IN          NUMBER,
    X_CONDITION_MET         OUT NOCOPY  VARCHAR2,
    X_ERROR                 OUT NOCOPY  VARCHAR2);

END ;

/
