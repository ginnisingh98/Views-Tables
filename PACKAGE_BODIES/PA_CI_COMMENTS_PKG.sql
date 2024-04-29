--------------------------------------------------------
--  DDL for Package Body PA_CI_COMMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CI_COMMENTS_PKG" AS
/* $Header: PACICOTB.pls 120.2 2005/08/22 05:10:59 sukhanna noship $ */



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
) IS
      -- Enter the procedure variables here. As shown below
    CURSOR  c1 IS
     SELECT rowid
     FROM   PA_CI_COMMENTS
     WHERE  ci_comment_id = p_ci_comment_id;

    l_row_id  ROWID;

BEGIN

   Insert into PA_CI_COMMENTS (
    CI_COMMENT_ID,
    CI_ID,
    TYPE_CODE,
    COMMENT_TEXT,
    RECORD_VERSION_NUMBER,
    LAST_UPDATED_BY,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    CI_ACTION_ID
    ) VALUES
  (  PA_CI_COMMENTS_S.NEXTVAL ,
    P_CI_ID,
    P_TYPE_CODE,
    P_COMMENT_TEXT,
    1,
    P_LAST_UPDATED_BY,
    P_CREATED_BY,
    P_CREATION_DATE,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATE_LOGIN,
    P_CI_ACTION_ID
  ) returning ci_comment_id INTO p_ci_comment_id;


  EXCEPTION
    WHEN OTHERS THEN -- catch the exceptions here
        p_ci_comment_id := null; --Added for bug#4565156.
        RAISE;
  END INSERT_ROW;

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
) IS
 BEGIN
   UPDATE PA_CI_COMMENTS
   SET
    CI_ID           = P_CI_ID,
    TYPE_CODE       = P_TYPE_CODE,
    COMMENT_TEXT    = P_COMMENT_TEXT,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    CREATED_BY      = P_CREATED_BY,
    CREATION_DATE   = P_CREATION_DATE,
    LAST_UPDATE_DATE    = P_LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN   = P_LAST_UPDATE_LOGIN,
    RECORD_VERSION_NUMBER = P_RECORD_VERSION_NUMBER+1,
    CI_ACTION_ID    = P_CI_ACTION_ID
   WHERE CI_COMMENT_ID  =  P_CI_COMMENT_ID;
 EXCEPTION
    WHEN OTHERS THEN -- catch the exceptins here
        RAISE;
 END UPDATE_ROW;



procedure DELETE_ROW (
		      P_CI_COMMENT_ID in NUMBER )
 IS
 BEGIN
   DELETE FROM PA_CI_COMMENTS
   WHERE CI_COMMENT_ID = P_CI_COMMENT_ID;

 EXCEPTION
    WHEN OTHERS THEN
        RAISE;
 END DELETE_ROW;

   -- Enter further code below as specified in the Package spec.
END PA_CI_COMMENTS_PKG; -- Package Body PA_CI_COMMENTS_PKG

/
