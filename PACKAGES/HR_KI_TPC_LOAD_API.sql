--------------------------------------------------------
--  DDL for Package HR_KI_TPC_LOAD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_TPC_LOAD_API" AUTHID CURRENT_USER as
/* $Header: hrkitpcl.pkh 115.0 2004/01/11 21:44:30 vkarandi noship $ */
--
-- Package Variables
--
--
procedure UPDATE_ROW (
  X_TOPIC_ID in NUMBER,
  X_NAME  in VARCHAR2,
  X_HANDLER in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER

);



procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_TOPIC_ID in out nocopy NUMBER,
  X_TOPIC_KEY in VARCHAR2,
  X_HANDLER in VARCHAR2,
  X_NAME in varchar2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) ;

procedure LOAD_ROW
  (
   X_TOPIC_KEY  in VARCHAR2,
   X_HANDLER     in VARCHAR2,
   X_NAME      in VARCHAR2,
   X_OWNER   in varchar2,
   X_CUSTOM_MODE in varchar2,
   X_LAST_UPDATE_DATE in varchar2

  );

procedure TRANSLATE_ROW
  (X_TOPIC_KEY in varchar2,
  X_NAME in VARCHAR2,
  X_OWNER in varchar2,
  X_CUSTOM_MODE in varchar2,
  X_LAST_UPDATE_DATE in varchar2
  );
END HR_KI_TPC_LOAD_API;

 

/
