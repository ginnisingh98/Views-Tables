--------------------------------------------------------
--  DDL for Package ASG_MOBTRAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASG_MOBTRAN" AUTHID CURRENT_USER AS
/* $Header: asgmots.pls 120.1 2005/08/12 02:48:07 saradhak noship $*/

-- DESCRIPTION
--  This package allows MDG machines to send mobile changes
--  to the enteprise for processiong.
--  In order to mantain data integrity this package works under the
--  boundaries of mobile transactions.
--
--  A mobile transaction, contains all changes made by a mobile
--  device during a replication session.  The transaction is logicaly
--  devided in objects, Rows, and Columns.  Objects map to publications,
--  rows map to the mobile changed record, and columns map to the
--  columns of the record.
--
--
--
-- HISTORY
--   09-nov-01  vekrishn        Fix for Queue data loss
--   04-jun-01  vekrishn        Support for begin/end transaction.
--   15-dec-99  dcassine        Created.
--
--


NO_TRANSACTION          EXCEPTION;
OPEN_TRANSACTION        EXCEPTION;
NO_OBJECT               EXCEPTION;
NOT_IN_ROW              EXCEPTION;
IN_ROW                  EXCEPTION;
ASG_ERROR               EXCEPTION;

OK                      CONSTANT NUMBER := 0;
ERROR                   CONSTANT NUMBER := 1;

ASG_TRUE                CONSTANT NUMBER := 1;
ASG_FALSE               CONSTANT NUMBER := 0;


INVALID_TYPE            CONSTANT NUMBER :=  0;
CHAR_TYPE               CONSTANT NUMBER :=  1;
DATE_TYPE               CONSTANT NUMBER :=  2;
NUMBER_TYPE             CONSTANT NUMBER :=  3;
BLOB_TYPE               CONSTANT NUMBER :=  4;
CLOB_TYPE               CONSTANT NUMBER :=  5;

M_DEBUG                 varchar2(1) := 'Y';

QUEUE_TO_MDG            CONSTANT NUMBER :=  0;
QUEUE_TO_ENT            CONSTANT NUMBER :=  1;

-- Before calling any member of this package, BeginTransaction must be called
-- Transactions are not process utill EndTransaction is called.
procedure BeginTransaction (trans_id IN number, transaction_owner in varchar2);
procedure CommitTransaction ;
procedure RollBackTransaction ;

-- Transaction writing API
-- Before adding DML transactions to a transaction, setObject must be called
-- with the information of the object whos transactions are about to be process.
Procedure SetObject (object_name in varchar2, metadata in varchar2);
procedure UnsetObject;

Procedure AddRow (row_id number,dml in varchar2);
Procedure PushRow;
Procedure PopRow;

Procedure putString (data in varchar2);
Procedure putNumber (data in NUMBER);
Procedure putDate   (data in DATE);


-- transaction reading API
procedure process_queue_transaction;
procedure process_queue_transaction(debug_flag IN CHAR);
Function parse                  (dequeue_session IN number) return number;
Function getTransactionId       (dequeue_session IN number) return number;
Function getSourceGlobalName    (dequeue_session IN number) return VARCHAR2;
Function getTimeStamp           (dequeue_session IN number) return date;
Function getNextObject          (dequeue_session IN number) return VARCHAR2;
Function getObjectName          (dequeue_session IN number) return VARCHAR2;
Function getObjectMetadata      (dequeue_session IN number) return VARCHAR2;
Function getNextDML             (dequeue_session IN number) return VARCHAR2;
Function getDML                 (dequeue_session IN number) return VARCHAR2;
Function getRecID               (dequeue_session IN number) return number;
Function getColumns             (dequeue_session IN number) return number;
Function NextColumn             (dequeue_session IN number) return number;
Function getString              (dequeue_session IN number) return VARCHAR2;
Function getCHAR                (dequeue_session IN number) return VARCHAR2;
Function getNUMBER              (dequeue_session IN number) return number;
Function getDATE                (dequeue_session IN number) return DATE;
Function getConnectedUserId     (mobile_user_id  IN number) return number;
Function getTransHandler        (mobile_user_id  IN number) return VARCHAR2;
Function dequeue_transaction    return number;
Function rmqueue_transaction    return NUMBER;
Procedure purge_queue_transactions           (p_que_cnt IN NUMBER);

/*
   The following function its used to check if a mobile update can be applied
   to the database.  In order for a mobile update to be applied, the record
   which is beeing updated MUST have a lower value for its last_update column
   that the user last_sync_date.
*/
Function check_TimeStamp        (ObjectName in varchar2, user in number,
                                pk_col1    in varchar2, pk_val1 in number,
                                pk_col2    in varchar2, pk_val2 in number,
                                pk_col3    in varchar2, pk_val3 in number,
                                pk_col4    in varchar2, pk_val4 in number,
                                pk_col5    in varchar2, pk_val5 in number,
                                pk_col6    in varchar2, pk_val6 in number
                                ) return number;

-- procedures used by the wrappers to set the error message
Procedure Set_Short_Error_message  (dequeue_session IN number, message in varchar2);
Procedure Set_Longer_Error_message (dequeue_session IN number, message in varchar2);

-- Reply processing API
procedure REPLY_PROCESSOR;

-- RPC request interface
-- returns transaction Id
Function DoRpc (destination_global_name in varchar2,    /* global name where to execute */
                Remote_procedure in varchar2,           /* procedure to call */
                Call_back_procedure in varchar2,        /* procedure to call with the result */
                who in varchar2 ) return number;        /* who requested the rpc */


-- UTIL functions / procedures
Procedure Purge_Queue (queue in number);

-- internal API No NOT use!!!
Function putLob (data in BLOB) return number;
Function GetBLOB return BLOB;
Function GetBLOBl return number;
-- Debug enable / disable code
procedure Enable_Debug;
procedure Disable_Debug;
END ASG_MOBTRAN;

 

/
