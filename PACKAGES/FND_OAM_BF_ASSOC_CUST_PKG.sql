--------------------------------------------------------
--  DDL for Package FND_OAM_BF_ASSOC_CUST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_BF_ASSOC_CUST_PKG" AUTHID CURRENT_USER as
/* $Header: AFOAMFACS.pls 120.1 2005/07/02 03:03:19 appldev noship $ */
  ROOT_KEY constant varchar2(40) := '$ROOT$';

  --
  -- Name
  --   load_row
  --
  -- Purpose
  --   Loads the association between a parent flow and a child flow
  --   into the database. This procedure will be called by the
  --   OAM Business Flows Definition Loader program.
  --
  -- Input Arguments
  --	x_biz_flow_parent_key - parent flow key. Pass in ROOT_KEY for
  --      flows that are top level that dont have a parent.
  --    x_biz_flow_child_key - child flow key.
  --    x_monitored_flag - Y/N - whether the child flow is active in
  --      context of its parent.
  --    x_owner - owner e.g. ORACLE
  -- Output Arguments
  --
  -- Notes:
  --
  --
procedure LOAD_ROW (
    X_BIZ_FLOW_PARENT_KEY in VARCHAR2,
    X_BIZ_FLOW_CHILD_KEY in VARCHAR2,
    X_MONITORED_FLAG in VARCHAR2,
    X_DISPLAY_ORDER in NUMBER,
    X_OWNER in VARCHAR2);

procedure LOAD_ROW (
    X_BIZ_FLOW_PARENT_KEY in VARCHAR2,
    X_BIZ_FLOW_CHILD_KEY in VARCHAR2,
    X_MONITORED_FLAG in VARCHAR2,
    X_DISPLAY_ORDER in NUMBER,
    X_OWNER in VARCHAR2,
    x_custom_mode         in      varchar2,
    x_last_update_date    in      varchar2);

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_BIZ_FLOW_PARENT_KEY in VARCHAR2,
  X_BIZ_FLOW_CHILD_KEY in VARCHAR2,
  X_MONITORED_FLAG in VARCHAR2,
  X_DISPLAY_ORDER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure UPDATE_ROW (
  X_BIZ_FLOW_PARENT_KEY in VARCHAR2,
  X_BIZ_FLOW_CHILD_KEY in VARCHAR2,
  X_MONITORED_FLAG in VARCHAR2,
  X_DISPLAY_ORDER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_BIZ_FLOW_PARENT_KEY in VARCHAR2,
  X_BIZ_FLOW_CHILD_KEY in VARCHAR2
);

end FND_OAM_BF_ASSOC_CUST_PKG;

 

/
