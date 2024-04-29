--------------------------------------------------------
--  DDL for Package CSM_CUSTOMIZATION_VIEWS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_CUSTOMIZATION_VIEWS_PKG" AUTHID CURRENT_USER AS
/* $Header: csmlcvs.pls 120.2 2005/11/23 05:28:05 saradhak noship $ */

PROCEDURE LOAD_ROW(
                   X_PAGE_NAME              VARCHAR2,
                   X_REGION_NAME            VARCHAR2,
                   X_CUST_VIEW_KEY          VARCHAR2,
                   X_LEVEL_ID               NUMBER,
                   X_LEVEL_VALUE            NUMBER,
                   X_MESSAGE_NAME           VARCHAR2,
                   X_SELECT_STATEMENT       VARCHAR2,
                   X_WHERE_CONDITION        VARCHAR2,
                   X_WHERE_CLAUSE           VARCHAR2,
                   X_ORDERBY_CLAUSE         VARCHAR2,
                   X_IS_DEFAULT             VARCHAR2,
                   X_DISPLAY_ROWS           NUMBER,
                   X_DISPLAY_VIEW           VARCHAR2,
                   X_BASE_VO_NAME           VARCHAR2,
                   X_UPDATABLE              VARCHAR2,
                   X_OWNER                  VARCHAR2
                  );


PROCEDURE INSERT_ROW
                   (
                   X_PAGE_NAME              VARCHAR2,
                   X_REGION_NAME            VARCHAR2,
                   X_CUST_VIEW_KEY          VARCHAR2,
                   X_LEVEL_ID               NUMBER,
                   X_LEVEL_VALUE            NUMBER,
                   X_MESSAGE_NAME           VARCHAR2,
                   X_SELECT_STATEMENT       VARCHAR2,
                   X_WHERE_CONDITION        VARCHAR2,
                   X_WHERE_CLAUSE           VARCHAR2,
                   X_ORDERBY_CLAUSE         VARCHAR2,
                   X_IS_DEFAULT             VARCHAR2,
                   X_DISPLAY_ROWS           NUMBER,
                   X_DISPLAY_VIEW           VARCHAR2,
                   X_BASE_VO_NAME           VARCHAR2,
                   X_UPDATABLE              VARCHAR2,
                   X_OWNER                  VARCHAR2
                   );

PROCEDURE UPDATE_ROW(
                    X_PAGE_NAME              VARCHAR2,
                    X_REGION_NAME            VARCHAR2,
                    X_CUST_VIEW_KEY          VARCHAR2,
                    X_LEVEL_ID               NUMBER,
                    X_LEVEL_VALUE            NUMBER,
                    X_MESSAGE_NAME           VARCHAR2,
                    X_SELECT_STATEMENT       VARCHAR2,
                    X_WHERE_CONDITION        VARCHAR2,
                    X_WHERE_CLAUSE           VARCHAR2,
                    X_ORDERBY_CLAUSE         VARCHAR2,
                    X_IS_DEFAULT             VARCHAR2,
                    X_DISPLAY_ROWS           NUMBER,
                    X_DISPLAY_VIEW           VARCHAR2,
                    X_BASE_VO_NAME           VARCHAR2,
                    X_UPDATABLE              VARCHAR2,
                    X_OWNER                  VARCHAR2
                    );

END;

 

/
