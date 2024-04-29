--------------------------------------------------------
--  DDL for Package ALR_DBTRIGGER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ALR_DBTRIGGER" AUTHID CURRENT_USER as
/* $Header: ALREDBTS.pls 120.3.12010000.3 2009/02/04 18:02:19 jwsmith ship $ */


   procedure CREATE_EVENT_DB_TRIGGER(
		APPL_ID in number,
		ALR_ID in number,
		TBL_APPLID in number,
		TBL_NAME in varchar2,
		OID in number,
		INSERT_FLAG in varchar2,
		UPDATE_FLAG in varchar2,
		DELETE_FLAG in varchar2,
		IS_ENABLE in varchar2);

   procedure ALTER_EVENT_DB_TRIGGER(
		APPL_ID in number,
		ALR_ID in number,
		TBL_APPLID in number,
		TBL_NAME in varchar2,
		OID in number,
		INSERT_FLAG in varchar2,
		UPDATE_FLAG in varchar2,
		DELETE_FLAG in varchar2,
		IS_ENABLE in varchar2);

   procedure DELETE_EVENT_DB_TRIGGER(
		APPL_ID in number,
		ALR_ID in number,
		OID in number);

   procedure PRE_UPDATE_EVENT_ALERT(
		APPL_ID in number,
		ALR_ID in number,
		NEW_TABLE_APPLID in number,
		NEW_TABLE_NAME in varchar2,
		NEW_INSERT_FLAG in varchar2,
		NEW_UPDATE_FLAG in varchar2,
		NEW_DELETE_FLAG in varchar2,
		NEW_IS_ENABLE in varchar2);

end ALR_DBTRIGGER;

/
