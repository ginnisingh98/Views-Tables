--------------------------------------------------------
--  DDL for Package JTF_NAV_TREE_ROOTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_NAV_TREE_ROOTS_PKG" AUTHID CURRENT_USER as
-- $Header: jtfntrs.pls 120.1 2005/07/02 00:51:11 appldev ship $
--
-- Package Name
-- JTF_NAV_TREE_ROOTS_PKG
-- Purpose
--  Table Handler for JTF_NAV_TREE_ROOTS

procedure INSERT_ROW
  (X_ROOT_VALUE in VARCHAR2,
   X_VIEWBY_id in number,
   X_SEQUENCE_NUMBER in NUMBER,
   X_ROOT_LABEL in VARCHAR2,
   X_CREATION_DATE in DATE,
   X_CREATED_BY in NUMBER,
   X_LAST_UPDATE_DATE in DATE,
   X_LAST_UPDATED_BY in NUMBER,
   X_LAST_UPDATE_LOGIN in NUMBER);

procedure UPDATE_ROW
  (x_tree_root_id IN number,
   X_ROOT_VALUE in VARCHAR2,
   X_VIEWBY_id in number,
   X_SEQUENCE_NUMBER in NUMBER,
   X_ROOT_LABEL in VARCHAR2,
   X_LAST_UPDATE_DATE in DATE,
   X_LAST_UPDATED_BY in NUMBER,
   X_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW
  (X_tree_root_id in number,
   X_VIEWBY_id in number,
   x_root_value IN varchar2,
   X_SEQUENCE_NUMBER in NUMBER,
   X_ROOT_LABEL in VARCHAR2);

procedure DELETE_ROW
  (X_tree_ROOT_id in number);

procedure ADD_LANGUAGE;

PROCEDURE LOAD_row
  (X_ROOT_VALUE in VARCHAR2,
   X_VIEWBY_VALUE in VARCHAR2,
   X_SEQUENCE_NUMBER in NUMBER,
   X_ROOT_LABEL in VARCHAR2,
   X_OWNER in VARCHAR2);

PROCEDURE TRANSLATE_row
  (X_root_VALUE in VARCHAR2,
   X_ROOT_LABEL in VARCHAR2,
   X_OWNER in VARCHAR2);

END JTF_NAV_TREE_ROOTS_PKG;
 

/
