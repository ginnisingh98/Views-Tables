--------------------------------------------------------
--  DDL for Package JTF_NAV_VIEWBYS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_NAV_VIEWBYS_PKG" AUTHID CURRENT_USER as
-- $Header: jtfnvbys.pls 120.1 2005/07/02 00:52:00 appldev ship $
--
-- Package Name
-- JTF_NAV_VIEWBYS_PKG
-- Purpose
--  Table Handler for JTF_NAV_VIEWBYS

procedure INSERT_ROW
  (X_VIEWBY_VALUE in VARCHAR2,
   X_TAB_id in number,
   X_SEQUENCE_NUMBER in NUMBER,
   X_VIEWBY_LABEL in VARCHAR2,
   X_CREATION_DATE in DATE,
   X_CREATED_BY in NUMBER,
   X_LAST_UPDATE_DATE in DATE,
   X_LAST_UPDATED_BY in NUMBER,
   X_LAST_UPDATE_LOGIN in NUMBER);

procedure UPDATE_ROW
  (x_viewby_id IN number,
   X_VIEWBY_VALUE in VARCHAR2,
   X_TAB_id in number,
   X_SEQUENCE_NUMBER in NUMBER,
   X_VIEWBY_LABEL in VARCHAR2,
   X_LAST_UPDATE_DATE in DATE,
   X_LAST_UPDATED_BY in NUMBER,
   X_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW
  (X_VIEWBY_id in number,
   X_TAB_id in number,
   x_viewby_value IN varchar2,
   X_SEQUENCE_NUMBER in NUMBER,
   X_VIEWBY_LABEL in VARCHAR2);

procedure DELETE_ROW
  (X_VIEWBY_id in number);

procedure ADD_LANGUAGE;

PROCEDURE LOAD_row
  (X_VIEWBY_VALUE in VARCHAR2,
   X_TAB_VALUE in VARCHAR2,
   X_SEQUENCE_NUMBER in NUMBER,
   X_VIEWBY_LABEL in VARCHAR2,
   X_OWNER in VARCHAR2);

PROCEDURE TRANSLATE_ROW(
    X_VIEWBY_VALUE in VARCHAR2,
    X_VIEWBY_LABEL in VARCHAR2,
    X_OWNER in VARCHAR2);

END JTF_NAV_VIEWBYS_PKG;
 

/
