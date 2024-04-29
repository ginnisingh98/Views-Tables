--------------------------------------------------------
--  DDL for Package RCV_DEBIT_MEMO_NOTIF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_DEBIT_MEMO_NOTIF" AUTHID CURRENT_USER AS
/* $Header: RCVWFDMS.pls 120.1.12010000.2 2013/11/04 09:24:10 kahe ship $ */

 /*=======================================================================+
 | FILENAME
 |   RCVWPA1S.pls
 |
 | DESCRIPTION
 |   PL/SQL spec for package: RCV_DEBIT_MEMO_NOTIF
 |
 | NOTES        dreddy  Created 3/30/2000
 |
 *=======================================================================*/

--
-- get the receipt_info
-- call the workflow after
--
PROCEDURE dm_workflow_call(x_transaction_id    number);

--  Start_WF_Process
--  Generates the itemkey, sets up the Item Attributes,
--  then starts the workflow process.
--
PROCEDURE Start_WF_Process ( ItemType               VARCHAR2 ,
                             ItemKey                VARCHAR2,
                             WorkflowProcess        VARCHAR2,
                             ReceiptNum             VARCHAR2,
                             EmployeeId             NUMBER,
                             Quantity               NUMBER,
                             PONumber               VARCHAR2,
                             ErrorMessage      VARCHAR2); -- Bug 16925688 added


END RCV_DEBIT_MEMO_NOTIF;

/
