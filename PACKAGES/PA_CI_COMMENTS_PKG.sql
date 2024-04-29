--------------------------------------------------------
--  DDL for Package PA_CI_COMMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CI_COMMENTS_PKG" AUTHID CURRENT_USER as
/* $Header: PACICOTS.pls 120.1 2005/08/19 16:17:57 mwasowic noship $ */

procedure INSERT_ROW (
    P_CI_COMMENT_ID             out NOCOPY NUMBER, --File.Sql.39 bug 4440895
    P_CI_ID                     in NUMBER,
    P_TYPE_CODE                 in VARCHAR2,
    P_COMMENT_TEXT              in VARCHAR2,
    P_LAST_UPDATED_BY		    in NUMBER,
    P_CREATED_BY			    in NUMBER,
    P_CREATION_DATE			    in DATE,
    P_LAST_UPDATE_DATE		    in DATE,
    P_LAST_UPDATE_LOGIN		    in NUMBER,
    P_CI_ACTION_ID              in NUMBER
);

procedure UPDATE_ROW (
    P_CI_COMMENT_ID             in NUMBER,
    P_CI_ID                     in NUMBER,
    P_TYPE_CODE                 in VARCHAR2,
    P_COMMENT_TEXT              in VARCHAR2,
    P_LAST_UPDATED_BY		    in NUMBER,
    P_CREATED_BY			    in NUMBER,
    P_CREATION_DATE			    in DATE,
    P_LAST_UPDATE_DATE		    in DATE,
    P_LAST_UPDATE_LOGIN		    in NUMBER,
    P_RECORD_VERSION_NUMBER     in NUMBER,
    P_CI_ACTION_ID              in NUMBER
);

procedure DELETE_ROW (
		      P_CI_COMMENT_ID in NUMBER );


END PA_CI_COMMENTS_PKG; -- Package Specification PA_CI_COMMENTS_PKG

 

/
