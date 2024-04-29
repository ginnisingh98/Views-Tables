--------------------------------------------------------
--  DDL for Package OKE_WORKFLOWS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_WORKFLOWS_PKG" AUTHID CURRENT_USER as
/* $Header: OKEOWXXS.pls 115.0 2003/10/22 22:21:42 ybchen noship $ */
procedure INSERT_ROW (
  X_ROWID 			in out NOCOPY VARCHAR2
, X_SOURCE_CODE 	        in 	VARCHAR2
, X_USAGE_CODE 	                in 	VARCHAR2
, X_CREATION_DATE 		in 	DATE
, X_CREATED_BY 			in 	NUMBER
, X_LAST_UPDATE_DATE 		in 	DATE
, X_LAST_UPDATED_BY 		in 	NUMBER
, X_LAST_UPDATE_LOGIN 		in 	NUMBER
, X_WF_ITEM_TYPE		in 	VARCHAR2
, X_WF_PROCESS  		in 	VARCHAR2
);

procedure LOCK_ROW (
  X_SOURCE_CODE 	        in 	VARCHAR2
, X_USAGE_CODE 	                in 	VARCHAR2
, X_WF_ITEM_TYPE		in 	VARCHAR2
, X_WF_PROCESS  		in 	VARCHAR2
);

procedure UPDATE_ROW (
  X_SOURCE_CODE 	        in 	VARCHAR2
, X_USAGE_CODE 	                in 	VARCHAR2
, X_LAST_UPDATE_DATE 		in 	DATE
, X_LAST_UPDATED_BY 		in 	NUMBER
, X_LAST_UPDATE_LOGIN 		in 	NUMBER
, X_WF_ITEM_TYPE		in 	VARCHAR2
, X_WF_PROCESS  		in 	VARCHAR2
);

end OKE_WORKFLOWS_PKG;

 

/
