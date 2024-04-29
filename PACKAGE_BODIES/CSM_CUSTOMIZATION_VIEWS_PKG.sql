--------------------------------------------------------
--  DDL for Package Body CSM_CUSTOMIZATION_VIEWS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_CUSTOMIZATION_VIEWS_PKG" AS
/* $Header: csmlcvb.pls 120.2 2005/11/23 05:28:32 saradhak noship $ */

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
                   )
IS

BEGIN
 --Insert
	INSERT INTO CSM_CUSTOMIZATION_VIEWS
                (CUST_VIEW_ID,
				 PAGE_NAME,
                 REGION_NAME,
                 CUST_VIEW_KEY,
                 LEVEL_ID,
                 LEVEL_VALUE,
                 MESSAGE_NAME,
                 SELECT_STATEMENT,
                 WHERE_CONDITION,
                 WHERE_CLAUSE,
                 ORDERBY_CLAUSE,
                 IS_DEFAULT,
                 DISPLAY_ROWS,
                 DISPLAY_VIEW,
                 BASE_VO_NAME,
                 UPDATABLE,
                 LAST_UPDATED_BY,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_DATE)
          VALUES(CSM_CUSTOMIZATION_VIEWS_S.NEXTVAL,
                 X_PAGE_NAME,
                 X_REGION_NAME,
                 X_CUST_VIEW_KEY,
                 X_LEVEL_ID,
                 X_LEVEL_VALUE,
                 X_MESSAGE_NAME,
                 X_SELECT_STATEMENT,
                 X_WHERE_CONDITION,
                 X_WHERE_CLAUSE,
                 X_ORDERBY_CLAUSE,
                 X_IS_DEFAULT,
                 X_DISPLAY_ROWS,
                 X_DISPLAY_VIEW,
                 X_BASE_VO_NAME,
                 X_UPDATABLE,
                 DECODE(X_OWNER,'SEED',1,0),
                 SYSDATE,
                 DECODE(X_OWNER,'SEED',1,0),
                 SYSDATE);

END Insert_Row;

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
                    )

IS

BEGIN
   --Update
	UPDATE CSM_CUSTOMIZATION_VIEWS
   	SET    MESSAGE_NAME     = X_MESSAGE_NAME,
           SELECT_STATEMENT = X_SELECT_STATEMENT,
           WHERE_CONDITION  = X_WHERE_CONDITION,
           WHERE_CLAUSE     = X_WHERE_CLAUSE,
           ORDERBY_CLAUSE   = X_ORDERBY_CLAUSE,
           IS_DEFAULT       = X_IS_DEFAULT,
           DISPLAY_ROWS     = X_DISPLAY_ROWS,
           DISPLAY_VIEW     = X_DISPLAY_VIEW,
           BASE_VO_NAME     = X_BASE_VO_NAME,
           UPDATABLE        = X_UPDATABLE,
           LAST_UPDATED_BY  = DECODE(X_OWNER,'SEED',1,0),
           LAST_UPDATE_DATE = SYSDATE
	WHERE  PAGE_NAME        = X_PAGE_NAME
    AND    REGION_NAME      = X_REGION_NAME
	AND    CUST_VIEW_KEY    = X_CUST_VIEW_KEY
	AND    LEVEL_ID         = X_LEVEL_ID
	AND    LEVEL_VALUE      = X_LEVEL_VALUE;

END Update_Row;

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
                  )
IS


CURSOR c_view_exists(b_page_name VARCHAR2,b_region_name VARCHAR2,b_cust_view_key VARCHAR2,b_level_id NUMBER,b_level_value NUMBER) IS
 SELECT 1
 FROM  CSM_CUSTOMIZATION_VIEWS CCV
 WHERE CCV.PAGE_NAME      = b_page_name
 AND   CCV.REGION_NAME    = b_region_name
 AND   CCV.CUST_VIEW_KEY  = b_cust_view_key
 AND   CCV.LEVEL_ID       = b_level_id
 AND   CCV.LEVEL_VALUE    = b_level_value;

 l_exists NUMBER;

BEGIN

  OPEN c_view_exists(X_PAGE_NAME,X_REGION_NAME,X_CUST_VIEW_KEY,X_LEVEL_ID,X_LEVEL_VALUE);
  FETCH c_view_exists INTO l_exists;
  CLOSE c_view_exists;

  IF l_exists IS NULL THEN

          Insert_Row(
 	                X_PAGE_NAME,
                    X_REGION_NAME,
                    X_CUST_VIEW_KEY,
                    X_LEVEL_ID,
                    X_LEVEL_VALUE,
                    X_MESSAGE_NAME,
                    X_SELECT_STATEMENT,
                    X_WHERE_CONDITION,
                    X_WHERE_CLAUSE,
                    X_ORDERBY_CLAUSE,
                    X_IS_DEFAULT,
                    X_DISPLAY_ROWS,
                    X_DISPLAY_VIEW,
                    X_BASE_VO_NAME,
                    X_UPDATABLE,
                    X_OWNER );


  ELSE
          Update_Row(
 	                X_PAGE_NAME,
                    X_REGION_NAME,
                    X_CUST_VIEW_KEY,
                    X_LEVEL_ID,
                    X_LEVEL_VALUE,
                    X_MESSAGE_NAME,
                    X_SELECT_STATEMENT,
                    X_WHERE_CONDITION,
                    X_WHERE_CLAUSE,
                    X_ORDERBY_CLAUSE,
                    X_IS_DEFAULT,
                    X_DISPLAY_ROWS,
                    X_DISPLAY_VIEW,
                    X_BASE_VO_NAME,
                    X_UPDATABLE,
                    X_OWNER);

	END IF;


END load_row;

END ;

/
