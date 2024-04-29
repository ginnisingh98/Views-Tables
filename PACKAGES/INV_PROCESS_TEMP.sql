--------------------------------------------------------
--  DDL for Package INV_PROCESS_TEMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_PROCESS_TEMP" AUTHID CURRENT_USER AS
/* $Header: INVMMTTS.pls 120.0 2005/05/25 05:48:36 appldev noship $ */

-- transaction status codes
/* same as the initial transactions functionality, i.e., no
   saving mode. So, if TRANSACTION_STATUS field is NULL or 1
   then it is treated as the default. */
TS_DEFAULT   CONSTANT NUMBER := 1; -- process immediately

/* this will just save the transaction and will not be picked
   up for processing. The TRANSACTION_STATUS should be changed
   to 3 in order to process it.
    So, the state diagram for this transaction_status is

      S-->2--->3--E
         /|\   |
          |____| in case of error we will set it bace to 2
                 and when the user corrects the mistake and
                 submits it it will be processed.
*/
TS_SAVE_ONLY  CONSTANT NUMBER := 2; -- save only

/* this will do some of the validation that is done for interface
   records and then proceed as normal with the inltpu processing.
   So, some of the validation in inltev is done for this mode. */
TS_PROCESS    CONSTANT NUMBER := 3; -- ready for processing

TS_CANCEL     CONSTANT NUMBER := 0; -- is this really needed?

-- validation level constants
  -- validate only those fields/entities that have time dependency
  -- for example a sub might have a disable date set
TIMEBASED    CONSTANT NUMBER := 1;
  -- validate completely
FULL         CONSTANT NUMBER := 2;

-- error tolerance constants
IGNORE_NONE       CONSTANT NUMBER := 1; -- return as soon as a error is found
IGNORE_GROUP  CONSTANT NUMBER := 2; -- complete group validation
                                   -- but strict for individual validation
IGNORE_ALL    CONSTANT NUMBER := 3; -- ignore individual errors as well


CURSOR  TXNRECS_CURSOR IS
          SELECT MMTT.*,MMTT.rowid
            FROM MTL_MATERIAL_TRANSACTIONS_TEMP MMTT;

TYPE TXNRECS IS REF CURSOR RETURN TXNRECS_CURSOR%ROWTYPE;

SUBTYPE TXNREC IS TXNRECS_CURSOR%ROWTYPE;

--SUBTYPE    TXNREC IS MTL_MATERIAL_TRANSACTIONS_TEMP%ROWTYPE;

FUNCTION processTransaction(headerID IN NUMBER,
                            validationLevel IN NUMBER := TIMEBASED,
                            errorTolerance  IN NUMBER := IGNORE_NONE
                           ) RETURN NUMBER;

-- group validations
FUNCTION validateSupportedTxns(validationLevel IN NUMBER) RETURN NUMBER;
FUNCTION validateFromOrganization RETURN NUMBER;
FUNCTION validateToOrganization RETURN NUMBER;
FUNCTION validateItem RETURN NUMBER;
FUNCTION validateItemRevision RETURN NUMBER;
FUNCTION validateToOrgItem RETURN NUMBER;
FUNCTION validateToOrgItemRevision RETURN NUMBER;
FUNCTION validateFromSubinventory RETURN NUMBER;
FUNCTION validateFromLocator RETURN NUMBER;
FUNCTION validateToSubinventory RETURN NUMBER;
FUNCTION validateToLocator RETURN NUMBER;
FUNCTION validateTransactionSource RETURN NUMBER;
FUNCTION validateSourceProject RETURN NUMBER;
FUNCTION validateSourceTask RETURN NUMBER;
FUNCTION validateCostGroups RETURN NUMBER;
FUNCTION validateExpenditureType RETURN NUMBER;
FUNCTION validateExpenditureOrg RETURN NUMBER;
FUNCTION validateTxnUOM RETURN NUMBER;
FUNCTION validateInterOrgItemControls RETURN NUMBER;
FUNCTION validateTransactionReason RETURN NUMBER;
FUNCTION validateFreightInfo RETURN NUMBER;


-- single record validations
FUNCTION validateLOT(txnrec IN TXNREC,
                     org IN INV_Validate.ORG,
                     item IN INV_Validate.ITEM) RETURN NUMBER;
FUNCTION validateUnitNumber(txnrec IN TXNREC) RETURN NUMBER;

FUNCTION getAccountPeriodId(orgID IN NUMBER,txndate IN DATE) RETURN NUMBER;

-- utility functions
PROCEDURE loadmsg(errorCode IN VARCHAR2,errorExplanation IN VARCHAR2);
PROCEDURE errupdate(err_row_id IN ROWID);

loginid   NUMBER;
userid    NUMBER;
applid    NUMBER;
progid    NUMBER;
reqstid   NUMBER;
validationLevel NUMBER;
-- changed to err_code other wise DB column and parameter can not be distinguished.
err_code  VARCHAR2(240);
error_exp   VARCHAR2(2000); -- Incresed the length to 2000
header_id  NUMBER;

END INV_PROCESS_TEMP;

 

/
