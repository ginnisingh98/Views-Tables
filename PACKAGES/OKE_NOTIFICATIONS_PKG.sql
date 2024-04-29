--------------------------------------------------------
--  DDL for Package OKE_NOTIFICATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_NOTIFICATIONS_PKG" AUTHID CURRENT_USER as
/* $Header: OKEONXXS.pls 115.0 2003/10/22 22:24:54 ybchen noship $ */
procedure INSERT_ROW (
  X_ROWID 			in out NOCOPY VARCHAR2
, X_ID                          in      NUMBER
, X_SOURCE_CODE 	        in      VARCHAR2
, X_USAGE_CODE 	                in      VARCHAR2
, X_CREATION_DATE 		in 	DATE
, X_CREATED_BY 			in 	NUMBER
, X_LAST_UPDATE_DATE 		in 	DATE
, X_LAST_UPDATED_BY 		in 	NUMBER
, X_LAST_UPDATE_LOGIN 		in 	NUMBER
, X_TARGET_DATE         	in 	VARCHAR2
, X_BEFORE_AFTER                in      VARCHAR2
, X_DURATION_DAYS		in 	NUMBER
, X_RECIPIENT    		in 	VARCHAR2
, X_ROLE_ID		        in 	NUMBER
);

procedure LOCK_ROW (
  X_ID    			in      NUMBER
, X_SOURCE_CODE 	        in      VARCHAR2
, X_USAGE_CODE 	                in 	VARCHAR2
, X_TARGET_DATE         	in 	VARCHAR2
, X_BEFORE_AFTER                in      VARCHAR2
, X_DURATION_DAYS		in 	NUMBER
, X_RECIPIENT    		in 	VARCHAR2
, X_ROLE_ID		        in 	NUMBER
);

procedure UPDATE_ROW (
  X_ID 	        		in      NUMBER
, X_SOURCE_CODE 	        in      VARCHAR2
, X_USAGE_CODE 	                in 	VARCHAR2
, X_LAST_UPDATE_DATE 		in 	DATE
, X_LAST_UPDATED_BY 		in 	NUMBER
, X_LAST_UPDATE_LOGIN 		in 	NUMBER
, X_TARGET_DATE         	in 	VARCHAR2
, X_BEFORE_AFTER                in      VARCHAR2
, X_DURATION_DAYS		in 	NUMBER
, X_RECIPIENT    		in 	VARCHAR2
, X_ROLE_ID		        in 	NUMBER
);

procedure DELETE_ROW (
  X_ID 		        	in      NUMBER
);

end OKE_NOTIFICATIONS_PKG;

 

/
