--------------------------------------------------------
--  DDL for Package FND_LOG_ADMIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_LOG_ADMIN" AUTHID CURRENT_USER as
/* $Header: AFUTLGAS.pls 115.12 2004/03/09 02:00:59 kkapur ship $ */


/* This routine is used as a concurrent program.  */
/* Nobody besides the concurrent manager should call it. */
procedure delete_by_date_i(     errbuf out NOCOPY varchar2,
                               retcode out NOCOPY varchar2,
                             last_date in  varchar2 );

/* Delete all log messages for a particular user */
function delete_by_user(
         X_USER_ID IN VARCHAR2 ) return NUMBER ;

/* Delete all log messages for a particular session */
function delete_by_session(
          X_SESSION_ID IN VARCHAR2 ) return NUMBER ;

/* Delete all log messages for that match both user and session */
function delete_by_user_session(
          X_USER_ID        IN VARCHAR2,
          X_SESSION_ID     IN VARCHAR2 ) return NUMBER;

/* Delete all log messages that are "like" module */
function delete_by_module(
          X_MODULE IN VARCHAR2 ) return NUMBER;

/* Delete all messages between the specified dates */
/* passing null means unlimited; null for both deletes all rows */
function delete_by_date_range(
          X_START_DATE  IN DATE ,
          X_END_DATE    IN DATE ) return NUMBER;

/* Deletes messages at level and all levels below.*/
function delete_by_max_level(
          X_LEVEL          IN NUMBER) return NUMBER;

/* Delete all messages */
function delete_all return NUMBER;

/* For AOL INTERNAL use only */
function self_test return varchar2;

/* Delete all log messages based on sequenceid */
function delete_by_sequence(
        pLogSeqList IN VARCHAR2 ) return NUMBER ;

/*
function delete_by_Search(
         pFromDate IN DATE,
         pToDate IN DATE,
         PUser  IN VARCHAR2,
         pNode IN VARCHAR2,
         pModule IN VARCHAR2,
         pMessage IN VARCHAR2,
         pSession IN VARCHAR2,
         pProcessid IN  VARCHAR2,
         pJvmid IN VARCHAR2,
         pThreadid IN VARCHAR2,
	 pAudsid IN NUMBER,
 	 pDbinstance IN NUMBER,
 	 pMinseq IN NUMBER,
 	 pMaxseq IN NUMBER) return NUMBER;
*/

function delete_by_seqarray(numArrayList IN FND_ARRAY_OF_NUMBER_25) return NUMBER;

/* Check and Submit the Purge CP */
procedure start_purge_cp;

end FND_LOG_ADMIN;

 

/
