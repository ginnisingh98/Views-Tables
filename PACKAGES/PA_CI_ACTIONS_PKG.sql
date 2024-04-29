--------------------------------------------------------
--  DDL for Package PA_CI_ACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CI_ACTIONS_PKG" AUTHID CURRENT_USER as
/* $Header: PACIACTS.pls 120.0 2005/05/29 20:28:14 appldev noship $ */

procedure INSERT_ROW (
   P_CI_ACTION_ID		out NOCOPY NUMBER,
    P_CI_ID                     in NUMBER,
    P_CI_ACTION_NUMBER		in NUMBER,
    P_STATUS_CODE   		in VARCHAR2,
    P_TYPE_CODE			in VARCHAR2,
    P_ASSIGNED_TO		in NUMBER,
    P_DATE_REQUIRED 		in DATE,
    P_SIGN_OFF_REQUIRED_FLAG    in VARCHAR2,
    P_DATE_CLOSED		in DATE,
    P_SIGN_OFF_FLAG		in VARCHAR2,
    P_SOURCE_CI_ACTION_ID	in NUMBER,
    P_LAST_UPDATED_BY		in NUMBER,
    P_CREATED_BY		in NUMBER,
    P_CREATION_DATE		in DATE,
    P_LAST_UPDATE_DATE		in DATE,
    P_LAST_UPDATE_LOGIN		in NUMBER,
    P_RECORD_VERSION_NUMBER     in NUMBER
);

procedure UPDATE_ROW (
    P_CI_ACTION_ID		in NUMBER,
    P_CI_ID                     in NUMBER,
    P_STATUS_CODE   		in VARCHAR2,
    P_TYPE_CODE			in VARCHAR2,
    P_ASSIGNED_TO		in NUMBER,
    P_DATE_REQUIRED 		in DATE,
    P_SIGN_OFF_REQUIRED_FLAG    in VARCHAR2,
    P_DATE_CLOSED		in DATE,
    P_SIGN_OFF_FLAG		in VARCHAR2,
    P_SOURCE_CI_ACTION_ID	in NUMBER,
    P_LAST_UPDATED_BY		in NUMBER,
    P_CREATED_BY		in NUMBER,
    P_CREATION_DATE		in DATE,
    P_LAST_UPDATE_DATE		in DATE,
    P_LAST_UPDATE_LOGIN		in NUMBER,
    P_RECORD_VERSION_NUMBER     in NUMBER
);

procedure DELETE_ROW (
		      P_CI_ACTION_ID in NUMBER );


END; -- Package Specification PA_CI_ACTIONS_PKG
 

/
