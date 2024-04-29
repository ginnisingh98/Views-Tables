--------------------------------------------------------
--  DDL for Package RLM_CUST_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RLM_CUST_MERGE" AUTHID CURRENT_USER AS
/* $Header: RLMCMRGS.pls 120.1 2005/07/17 18:11:56 rlanka noship $ */



/*===========================================================================
  PACKAGE NAME:         RLM_CUST_MERGE

  DESCRIPTION:          Contains the server side code for customer merge API
			of Release Management Customer Merge.

  CLIENT/SERVER:        Server

  LIBRARY NAME:         None

  OWNER:                rvishnuv

  PROCEDURE/FUNCTIONS:

  GLOBALS:

=========================================================================== */
--
TYPE g_number_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
--
TYPE g_varchar_tbl_type IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
--
TYPE t_CuatomerNameTbl IS TABLE OF ra_customer_merges.customer_name%TYPE
                                                    INDEX BY BINARY_INTEGER;

/*===========================================================================

  PROCEDURE NAME:       Merge

  DESCRIPTION:          Cover function for Customer Merge API

  PARAMETERS:

  DESIGN REFERENCES:    RLMHLMRG.rtf
                        RLMDLMRG.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created rvishnuv 01/31/01
===========================================================================*/
PROCEDURE Merge(REQ_ID NUMBER,
		SET_NUM NUMBER,
		PROCESS_MODE VARCHAR2);
/*============================================================================

  PROCEDURE NAME:       Cust_Item_Cum_Keys

  DESCRIPTION:          This procedure will update the ship-to,
			bill-to and intermediate-ship-to data in
			the Cum Keys table

  PARAMETERS:

  DESIGN REFERENCES:    RLMHLMRG.rtf
                        RLMDLMRG.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created rvishnuv 01/31/01

 ============================================================================*/
PROCEDURE Cust_Item_Cum_Keys(REQ_ID NUMBER,
			     SET_NUM NUMBER,
			     PROCESS_MODE VARCHAR2);
/*============================================================================

  PROCEDURE NAME:       Interface_Headers

  DESCRIPTION:          This procedure will update the customer_id
			in the interface headers table
  PARAMETERS:

  DESIGN REFERENCES:    RLMHLMRG.rtf
                        RLMDLMRG.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created rvishnuv 01/31/01


 ============================================================================*/
PROCEDURE Interface_Headers(REQ_ID NUMBER,
			    SET_NUM NUMBER,
			    PROCESS_MODE VARCHAR2);
/*============================================================================

  PROCEDURE NAME:       Interface_Lines

  DESCRIPTION:          This procedure will update the bill-to-site-id,
			bill-to-address-id, intermediate-ship-to-id,
			intermd-st-site-use-id,ship-to-address-id,
			ship-to-site-use-id in the interface lines table
  PARAMETERS:

  DESIGN REFERENCES:    RLMHLMRG.rtf
                        RLMDLMRG.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created rvishnuv 01/31/01



 ============================================================================*/
PROCEDURE Interface_Lines(REQ_ID NUMBER,
			  SET_NUM NUMBER,
			  PROCESS_MODE VARCHAR2);
/*============================================================================

  PROCEDURE NAME:       Schedule_Headers

  DESCRIPTION:          This procedure will update the customer_id
                        in the schedule headers table
  PARAMETERS:

  DESIGN REFERENCES:    RLMHLMRG.rtf
                        RLMDLMRG.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created rvishnuv 01/31/01


 ============================================================================*/
PROCEDURE Schedule_Headers(REQ_ID NUMBER,
			   SET_NUM NUMBER,
			   PROCESS_MODE VARCHAR2);
/*============================================================================

  PROCEDURE NAME:       Schedule_Lines

  DESCRIPTION:          This procedure will update the bill-to-site-id,
                        bill-to-address-id, intermediate-ship-to-id,
                        intermd-st-site-use-id,ship-to-address-id,
                        ship-to-site-use-id in the interface lines table
  PARAMETERS:

  DESIGN REFERENCES:    RLMHLMRG.rtf
                        RLMDLMRG.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created rvishnuv 01/31/01

 ============================================================================*/
PROCEDURE Schedule_Lines(REQ_ID NUMBER,
                         SET_NUM NUMBER,
                         PROCESS_MODE VARCHAR2);
/*============================================================================

  PROCEDURE NAME:       Cust_Shipto_Terms

  DESCRIPTION:          This procedure will update the address-id,
                        customer-id in the Customer Rules table
  PARAMETERS:

  DESIGN REFERENCES:    RLMHLMRG.rtf
                        RLMDLMRG.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created rvishnuv 01/31/01

 ============================================================================*/
PROCEDURE Cust_Shipto_Terms(p_duplicateAddressIdTab g_number_tbl_type,
                            p_customerAddressIdTab g_number_tbl_type,
                            p_duplicateIdTab g_number_tbl_type,
                            p_customerIdTab g_number_tbl_type,
                            REQ_ID NUMBER,
			    SET_NUM NUMBER,
			    PROCESS_MODE VARCHAR2);
/*============================================================================

  PROCEDURE NAME:       Cust_Item_Terms

  DESCRIPTION:          This procedure will update the address-id,
                        customer-id in the Customer Rules table

  PARAMETERS:

  DESIGN REFERENCES:    RLMHLMRG.rtf
                        RLMDLMRG.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created rvishnuv 01/31/01

 ============================================================================*/
PROCEDURE Cust_Item_Terms(p_duplicateAddressIdTab g_number_tbl_type,
                          p_customerAddressIdTab g_number_tbl_type,
                          p_duplicateIdTab g_number_tbl_type,
                          p_customerIdTab g_number_tbl_type,
                          REQ_ID NUMBER,
			  SET_NUM NUMBER,
			  PROCESS_MODE VARCHAR2);
/*============================================================================

  FUNCTION NAME:        getTimeStamp

  DESCRIPTION:          This function is used to return the
			current date and time

  PARAMETERS:

  DESIGN REFERENCES:    RLMHLMRG.rtf
                        RLMDLMRG.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created rvishnuv 01/31/01

 ============================================================================*/
FUNCTION getTimeStamp RETURN VARCHAR2;
/*============================================================================

  PROCEDURE NAME:       setARMessageUpdateTable

  DESCRIPTION:          This procedure is used to set a message
			on the stack indicating table being updated

  PARAMETERS:

  DESIGN REFERENCES:    RLMHLMRG.rtf
                        RLMDLMRG.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created rvishnuv 01/31/01

 ============================================================================*/

PROCEDURE setARMessageUpdateTable(p_tableName IN VARCHAR2);

/*============================================================================

  PROCEDURE NAME:       setARMessageDeleteTable

  DESCRIPTION:          This procedure is used to set a message
			on the stack indicating table being Deleted

  PARAMETERS:

  DESIGN REFERENCES:    RLMHLMRG.rtf
                        RLMDLMRG.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created rvishnuv 01/31/01

 ============================================================================*/

PROCEDURE setARMessageDeleteTable(p_tableName IN VARCHAR2);
/*============================================================================

  PROCEDURE NAME:	setARMessageLockTable

  DESCRIPTION:		This procedure is used to set a message
			on the stack indicating table record being locked

  PARAMETERS:

  DESIGN REFERENCES:    RLMHLMRG.rtf
                        RLMDLMRG.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created rvishnuv 01/31/01

 ============================================================================*/

PROCEDURE setARMessageLockTable(p_tableName IN VARCHAR2);

/*============================================================================

  PROCEDURE NAME:	setARMessageRowCount

  DESCRIPTION:		This procedure is used to set a message
			on the stack indicating number of rows
			updated in the table

  PARAMETERS:

  DESIGN REFERENCES:    RLMHLMRG.rtf
                        RLMDLMRG.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created rvishnuv 01/31/01

 ============================================================================*/

PROCEDURE setARMessageRowCount(p_rowCount IN NUMBER);

/*============================================================================

  FUNCTION NAME:        getMessage

  DESCRIPTION:          This function is used to return the
			current date and time

  PARAMETERS:

  DESIGN REFERENCES:    RLMHLMRG.rtf
                        RLMDLMRG.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created rvishnuv 01/31/01

 ============================================================================*/
FUNCTION getMessage(p_messageName IN VARCHAR2,
		    p_token1      IN VARCHAR2 DEFAULT NULL,
		    p_value1      IN VARCHAR2 DEFAULT NULL,
		    p_token2	  IN VARCHAR2 DEFAULT NULL,
		    p_value2	  IN VARCHAR2 DEFAULT NULL,
		    p_token3	  IN VARCHAR2 DEFAULT NULL,
		    p_value3	  IN VARCHAR2 DEFAULT NULL
		   )
RETURN VARCHAR2;
/*===========================================================================

  FUNCTION  NAME:       IS_RLM_INSTALLED

  DESCRIPTION:          Checks whether RLM is installed

  PARAMETERS:

  DESIGN REFERENCES:    RLMHLMRG.rtf
                        RLMDLMRG.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       created rvishnuv 01/31/01
===========================================================================*/
FUNCTION IS_RLM_INSTALLED
RETURN BOOLEAN;

/*2447493*/

PROCEDURE RLM_CUST_ITEM_CUM_KEYS_LOG (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);

PROCEDURE RLM_INTERFACE_HEADERS_LOG (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);

PROCEDURE RLM_INTERFACE_LINES_LOG (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);

PROCEDURE RLM_SCHEDULE_HEADERS_LOG (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);

PROCEDURE RLM_SCHEDULE_LINES_LOG (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);

/*2447493*/

END RLM_CUST_MERGE;
 

/
