--------------------------------------------------------
--  DDL for Package Body ASG_MOBTRAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASG_MOBTRAN" AS
/* $Header: asgmotb.pls 120.1 2005/08/12 02:47:42 saradhak noship $*/

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
--   09-nov-01  vekrishn        Set MAX_TRANSACTIONS to 150
--   09-nov-01  vekrishn        Fix for Queue data loss
--   10-sep-01  vekrishn        Pass session_id/device_userid in Begin/End txn
--   01-jun-01  vekrishn        Support for Begin/End Transactions
--   01-may-01  vekrishn        Set MAX_TRANSACTIONS to 50
--   22-apr-01  vekrishn        Support for Deferred transactions
--   25-jul-00  W Chin          Modified Get_Handler_for_Object function.
--   10-mar-00  D Cassinera     Started adding support for full duplex
--                              mode and RPC payload type
--   15-dec-99  D Cassinera     Created.
--


-- Java Stored Procedures Used by this package.
Function Call_Object_Processor(wrapper IN varchar2,func in varchar2,session_id in number, mobile_user_id in number ) RETURN number is
begin
 return null;
end;

Function beginTransactionJ (trans_id IN number, user IN number, source in varchar2) return number is
begin
   return null;
end;

Function commitTransactionJ (trans_id IN number) return number is
begin
   return null;
end;

Function rollbackTransactionJ (trans_id IN number) return number is
begin
  return null;
end;

Function setObjectJ (trans_id IN number,name in varchar2, metadata in varchar2) return number is
begin
  return null;
end;

Function unsetObjectJ (trans_id IN number) return number is
begin
  return null;
end;

Function addRowJ (trans_id IN number,row_id in number,dml in varchar2) return number is
begin
  return null;
end;

Function pushRowJ (trans_id IN number) return number is
begin
  return null;
end;

Function popRowJ (trans_id IN number) return number is
begin
  return null;
end;


Function putStringJ (trans_id IN number,data in varchar2) return number is
begin
  return null;
end;

Function putNumberJ (trans_id IN number,data in number) return number is
begin
  return null;
end;

Function putDateJ (trans_id IN number,data in DATE) return number is
begin
  return null;
end;

Function getEnterpriseGlobalName return varchar2 is
begin
  return null;
end;

Function openReader (data in BLOB) return number is
begin
  return null;
end;

Function closeReader (dequeue_session IN number) return number is
begin
  return null;
end;

Function parse (dequeue_session IN number) return number is
begin
  return null;
end;

Function getTransactionId (dequeue_session IN number) return number is
begin
  return null;
end;

Function getSourceGlobalName (dequeue_session IN number) return VARCHAR2 is
begin
  return null;
end;

Function getTimeStamp (dequeue_session IN number) return date is
begin
  return null;
end;

Function getNextObject (dequeue_session IN number) return VARCHAR2 is
begin
  return null;
end;

Function getObjectName (dequeue_session IN number) return VARCHAR2 is
begin
  return null;
end;

Function getObjectMetadata (dequeue_session IN number) return VARCHAR2 is
begin
  return null;
end;

Function getNextDML (dequeue_session IN number) return VARCHAR2 is
begin
  return null;
end;

Function getDML (dequeue_session IN number) return VARCHAR2 is
begin
  return null;
end;

Function getRecID (dequeue_session IN number) return number is
begin
  return null;
end;

Function getColumns (dequeue_session IN number) return number is
begin
  return null;
end;

Function NextColumn (dequeue_session IN number) return number is
begin
  return null;
end;

Function getString (dequeue_session IN number) return VARCHAR2 is
begin
  return null;
end;

Function getCHAR (dequeue_session IN number) return VARCHAR2 is
begin
  return null;
end;

Function getNUMBER (dequeue_session IN number) return number is
begin
  return null;
end;

Function getDATE (dequeue_session IN number) return DATE is
begin
  return null;
end;

Function getConnectedUserId (mobile_user_id IN number) return number is
begin
  return null;
end;

Function getMobileUserId (mobile_user_id IN varchar2) return number is
begin
  return null;
end;

Function setFndProfile (user_id IN number) return number is
begin
  return null;
end;

Function enableWrapperDebug (PlsqlPackage IN varchar2) return number is
begin
  return null;
end;

Function disableWrapperDebug (PlsqlPackage IN varchar2) return number is
begin
  return null;
end;


Function getExecLocation (holer in number) return number is
begin
  return null;
end;

Function getQueueHomeSchema return varchar2 is
begin
  return null;
end;

PROCEDURE set_last_sync_date (mobile_user_id in number) is
begin
  null;
end;

PROCEDURE enableDebug is
begin
  null;
end;

Function getTransHandler (mobile_user_id in number) return varchar2 is
begin
  return null;
end;

PROCEDURE disableDebug is
begin
  null;
end;


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
                    ) return number is
begin
  return null;
end;




Function Get_Handler_for_Object (name in varchar2) return varchar2 is
begin
  return null;
end;

Function run_command( p_command in varchar2 ) return number Is
begin
   return null;
END run_command;

/*--------------------------------------------------------------------------------------
  FUNCTIONS TO CHECK AND SUBMIT REPLY HANDLER JOB
  -------------------------------------------------------------------------------------- */
PROCEDURE SUBMIT_REPLY_PROCESSOR is
begin
null;
END Submit_REPLY_PROCESSOR;


PROCEDURE ENABLE_REPLY_PROCESSING is
BEGIN
   null;
END ENABLE_REPLY_PROCESSING;

PROCEDURE QUEUE_MESSAGE (transaction in NUMBER, local_copy in number )is
BEGIN
  null;
END QUEUE_MESSAGE;

PROCEDURE QUEUE_REPLY (destination in sys.aq$_agent, reply in NUMBER) is
BEGIN
null;
END QUEUE_REPLY;

  FUNCTION dequeue_transaction RETURN NUMBER is
  BEGIN
        return null;
  END dequeue_transaction;

  FUNCTION rmqueue_transaction RETURN NUMBER IS
  BEGIN
        return null;
  END rmqueue_transaction;


  PROCEDURE purge_queue_transactions (p_que_cnt IN NUMBER) IS
  BEGIN
        null;
  END purge_queue_transactions;


Function DEQUEUE_REPLY return NUMBER is
BEGIN
        return null;
end;

PROCEDURE setServerAgent is
begin
  null;
end;


PROCEDURE setExecMode is
begin
  null;
end;

Function Generate_Reply_Address (SourceAddress in varchar2) return varchar2 is
begin
    return null;
end Generate_Reply_Address;


PROCEDURE CREATE_TRANSACTION_BUFFER is
BEGIN
   null;
END CREATE_TRANSACTION_BUFFER;

PROCEDURE CHECK_TRANSACTION IS
BEGIN
   null;
END CHECK_TRANSACTION;


PROCEDURE FREE_TRANSACTION IS
BEGIN
  null;
END FREE_TRANSACTION;


PROCEDURE CHECK_OBJECT IS
BEGIN
  null;
END CHECK_OBJECT;

PROCEDURE CHECK_ROW IS
BEGIN
  null;
END CHECK_ROW;

PROCEDURE CHECK_NO_ROW IS
BEGIN
  null;
END CHECK_NO_ROW;

Procedure Set_Short_Error_message (dequeue_session IN number, message in varchar2) is
begin
  null;
end;

Procedure Set_Longer_Error_message (dequeue_session IN number, message in varchar2) is
begin
   null;
end;

PROCEDURE BeginTransaction (trans_id IN number, transaction_owner in varchar2) IS
BEGIN
  null;
end BeginTransaction;

PROCEDURE CommitTransaction is
BEGIN
  null;
END CommitTransaction;

PROCEDURE RollBackTransaction  IS
BEGIN
  null;
END RollBackTransaction;

Procedure SetObject (object_name in varchar2, metadata in varchar2) is
begin
  null;
end SetObject;

PROCEDURE UnsetObject is
begin
  null;
end UnsetObject;

Procedure AddRow (row_id number,dml in varchar2) is
begin
  null;
end AddRow;

Procedure PushRow is
begin
   null;
end PushRow;

Procedure PopRow is
begin
   null;
end PopRow;

Procedure putString (data in varchar2) is
begin
   null;
end putString;

Procedure putNumber (data in NUMBER) is
begin
  null;
end putNumber;

Procedure putDate (data in DATE) is
begin
  null;
end putDate;

Function putLob (data in BLOB) return number is
begin
  return null;
end;


Function Get_Incoming_BLOB return BLOB is
begin
    return null;
end Get_Incoming_BLOB;

Function Get_Incoming_BLOB_LENGTH return number is
begin
    return null;
end Get_Incoming_BLOB_LENGTH;

Function GetBLOB return BLOB is
begin
    return null;
end GetBLOB;

Function GetBLOBl return number is
begin
    return null;
end;



  FUNCTION Exec_handler (MObject IN VARCHAR2, Session_id IN NUMBER,
                         mobile_user_id IN NUMBER) RETURN NUMBER
  IS
  BEGIN
     return null;
  END Exec_handler;



  PROCEDURE DML_MESSAGE_PROCESSOR (incomming_message in NUMBER )
  IS
  BEGIN
     null;
  END DML_MESSAGE_PROCESSOR;


PROCEDURE RPC_PROCESSOR_REQUEST (rpc in NUMBER) is
BEGIN
  null;
end RPC_PROCESSOR_REQUEST;

PROCEDURE RPC_PROCESSOR_REPLY (reply in NUMBER) is
BEGIN
   null;
end RPC_PROCESSOR_REPLY;

PROCEDURE RPC_PROCESSOR (rpc in NUMBER) is
begin
  null;
end RPC_PROCESSOR;


PROCEDURE DML_REPLY_PROCESSOR (incoming_reply in NUMBER) is
begin
   null;
end DML_REPLY_PROCESSOR;

  PROCEDURE PROCESS_QUEUE_TRANSACTION IS
  BEGIN
    null;
  end PROCESS_QUEUE_TRANSACTION;

  PROCEDURE process_queue_transaction (debug_flag IN CHAR) IS
  BEGIN
     null;
  END process_queue_transaction;

PROCEDURE REPLY_PROCESSOR
is
begin
   null;
end REPLY_PROCESSOR;


Function DoRpc (destination_global_name in varchar2,            /* global name where to execute */
                Remote_PROCEDURE in varchar2,       /* PROCEDURE to call */
                Call_back_PROCEDURE in varchar2,    /* PROCEDURE to call with the result */
                who in varchar2             /* who requested the rpc */
        ) return number
is
begin
    return null;
end DoRpc;

PROCEDURE Enable_Debug is
begin
  null;
end Enable_Debug;

PROCEDURE Disable_Debug is
begin
   null;
end  Disable_Debug;

Procedure Purge_Queue (queue in number) is
begin
  null;
end Purge_Queue;

begin
  null;
END ASG_MOBTRAN;

/
