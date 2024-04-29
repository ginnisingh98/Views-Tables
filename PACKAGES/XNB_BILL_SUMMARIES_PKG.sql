--------------------------------------------------------
--  DDL for Package XNB_BILL_SUMMARIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNB_BILL_SUMMARIES_PKG" AUTHID CURRENT_USER as
/* $Header: XNBTBSS.pls 120.2 2006/04/06 01:59:19 ksrikant noship $ */
/*#
 * This is the public interface of TBI that is used for inserting, creating, or populating
 * new Bill Summary records into Oracle Applications from external Billing systems.
 * @rep:scope public
 * @rep:product XNB
 * @rep:displayname Create Bill Summary
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY XNB_ADD_BILLSUMMARY
 */

-- Start of Comments
-- Package name     : XNB_BILL_SUMMARIES_PKG
-- Purpose          : Defines public APIs to insert/update records into XNB BILL SUMMARIES schema
-- History          :
--        DATE          AUTHOR		COMMENTS
--        23-Aug-2004   dbhagat     Create table handler
--        04-Feb-2005   DPUTHIYE    Added p_api_version parameter to APIs. (Fixed bug 4159395).
-- NOTE             :
-- End of Comments

TYPE v_number IS VARRAY(10000) OF NUMBER;
TYPE v_date IS VARRAY(10000) OF DATE;
TYPE v_var30 IS VARRAY(10000) OF VARCHAR2(30);
TYPE v_var240 IS VARRAY(10000) OF VARCHAR2(240);
TYPE v_var150 IS VARRAY(10000) OF VARCHAR2(150);

/*
 * Record structure of XNB_BILL_SUMMARIES table
 */
TYPE bill_summaries_rec IS RECORD (
          ACCOUNT_NUMBER                    VARCHAR2(30),   -- mandatory for insert and update
          TOTAL_AMOUNT_DUE                  VARCHAR2(30),
          ADJUSTMENTS                       VARCHAR2(30),
          UNRESOLVED_DISPUTES               VARCHAR2(30),
          BILL_NUMBER                       VARCHAR2(30),   -- mandatory for insert and update
          BILL_CYCLE_START_DATE             DATE,
          BILL_CYCLE_END_DATE               DATE,
          DUE_DATE                          DATE,
          NEW_CHARGES                       VARCHAR2(30),
          PAYMENT                           VARCHAR2(30),
          BALANCE                           VARCHAR2(30),
          PREVIOUS_BALANCE                  VARCHAR2(30),
          BILLING_VENDOR_NAME               VARCHAR2(240),
          BILL_LOCATION_URL                 VARCHAR2(240),
          DUE_NOW                           VARCHAR2(30),
          CREATED_BY                        NUMBER,
          LAST_UPDATED_BY                   NUMBER,
          LAST_UPDATE_LOGIN                 NUMBER,
          ATTRIBUTE_CATEGORY                VARCHAR2(30),
          ATTRIBUTE1                        VARCHAR2(150),
          ATTRIBUTE2                        VARCHAR2(150),
          ATTRIBUTE3                        VARCHAR2(150),
          ATTRIBUTE4                        VARCHAR2(150),
          ATTRIBUTE5                        VARCHAR2(150),
          ATTRIBUTE6                        VARCHAR2(150),
          ATTRIBUTE7                        VARCHAR2(150),
          ATTRIBUTE8                        VARCHAR2(150),
          ATTRIBUTE9                        VARCHAR2(150),
          ATTRIBUTE10                       VARCHAR2(150),
          ATTRIBUTE11                       VARCHAR2(150),
          ATTRIBUTE12                       VARCHAR2(150),
          ATTRIBUTE13                       VARCHAR2(150),
          ATTRIBUTE14                       VARCHAR2(150),
          ATTRIBUTE15                       VARCHAR2(150)
);

/*
 * Table type for holding multiple records/ rows of XNB_BILL_SUMMARIES table data
 */
TYPE bill_summaries_table IS TABLE OF bill_summaries_rec INDEX BY BINARY_INTEGER;


/*
 * insert bulk rows of data
 * Usage example:
 * api_version NUMBER;
 * bill_summaries   XNB_BILL_SUMMARIES_PKG.bill_summaries_table;
 * api_version = 1.0;
 * bill_summaries(i).ACCOUNT_NUMBER := '1001';
 * XNB_BILL_SUMMARIES_PKG.Insert_Row_Batch(api_version, bill_summaries, x_return_status, x_msg_data);
 */

        --Date:04-Feb-2005  Author:DPUTHIYE   Bug#:4159395
        --Change: Added parameter p_api_version to comply to Business API standards.
        --Other Files Impact: None.

/*#
 * This is the public interface of TBI that is used for inserting
 * new Bill Summary records into Oracle Applications from external Billing systems.
 * @param p_api_version API version used to check call compatibility
 * @param p_bill_summaries Bill Summary Records
 * @param x_return_status Returns the status of transaction
 * @param x_msg_data Returns Error Message
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Insert Bill Summary
 */
PROCEDURE Insert_Row_Batch(
                p_api_version         IN            NUMBER,
                p_bill_summaries      IN	        bill_summaries_table,
                x_return_status       OUT   NOCOPY  VARCHAR2,
                x_msg_data		  	  OUT   NOCOPY  VARCHAR2
          );

/*
 * update bulk rows of data
 * Usage example:
 * api_version NUMBER;
 * bill_summaries   XNB_BILL_SUMMARIES_PKG.bill_summaries_table;
 * api_version = 1.0;
 * bill_summaries(i).ACCOUNT_NUMBER := '1001';
 * XNB_BILL_SUMMARIES_PKG.Update_Row_Batch(api_version, bill_summaries, x_return_status, x_msg_data);
 */

        --Date:04-Feb-2005  Author:DPUTHIYE   Bug#:4159395
        --Change: Added parameter p_api_version to comply to Business API standards.
        --Other Files Impact: None.

/*#
 * This is the public interface of TBI that is used for updating
 * existing Bill Summary records in Oracle Applications from external Billing systems.
 * @param p_api_version API version used to check call compatibility
 * @param p_bill_summaries Bill Summary Records
 * @param x_return_status Returns the status of transaction
 * @param x_msg_data Returns Error Message
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Bill Summary
 */
PROCEDURE Update_Row_Batch(
                p_api_version         IN            NUMBER,
                p_bill_summaries      IN	        bill_summaries_table,
                x_return_status       OUT   NOCOPY  VARCHAR2,
                x_msg_data		  	  OUT   NOCOPY  VARCHAR2
          );

End XNB_BILL_SUMMARIES_PKG;

 

/
