--------------------------------------------------------
--  DDL for Package PO_CHANGE_ORDER_TOLERANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CHANGE_ORDER_TOLERANCES_PKG" AUTHID CURRENT_USER as
/* $Header: PO_CHANGE_ORDER_TOLERANCES_PKG.pls 120.1 2005/12/02 16:26:16 dreddy noship $ */

------------------------------------------------------------------------------
--Start of Comments
--Name: INSERT_ROW
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--   1. inserts a record into PO_CHANGE_ORDER_TOLERANCES_ALL table
--Parameters:
--IN:
--   X_CHANGE_ORDER_TYPE Change Order Type
--   X_TOLERANCE_NAME    Tolerance name
--   X_ORG_ID            Operating Unit Id
--   X_SEQUENCE_NUMBER   Tolerance sequence number
--   X_MAXIMUM_INCREMENT maximum increment value
--   X_MAXIMUM_DECREMENT minimum increment value
--   X_ROUTING_FLAG      approval routing flag
--   X_CREATION_DATE     creation date (Standard Who Column)
--   X_CREATED_BY        created date (Standard Who Column)
--   X_LAST_UPDATE_DATE  last update date (Standard Who Column)
--   X_LAST_UPDATED_BY   last updated by (Standard Who Column)
--   X_LAST_UPDATE_LOGIN last update login (Standard Who Column)
--OUT:
--  None
--End of Comment
-------------------------------------------------------------------------------
procedure INSERT_ROW (
  X_CHANGE_ORDER_TYPE in VARCHAR2,
  X_TOLERANCE_NAME in VARCHAR2,
  X_ORG_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_MAXIMUM_INCREMENT in NUMBER,
  X_MAXIMUM_DECREMENT in NUMBER,
  X_ROUTING_FLAG in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

------------------------------------------------------------------------------
--Start of Comments
--Name: LOAD_ROW
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--   1. Load the row into PO_CHANGE_ORDER_TOLERANCES_ALL table
--Parameters:
--IN:
--   X_CHANGE_ORDER_TYPE Change Order Type
--   X_TOLERANCE_NAME    Tolerance name
--   X_ORG_ID            Operating Unit Id
--   X_SEQUENCE_NUMBER   Tolerance sequence number
--   X_MAXIMUM_INCREMENT maximum increment value
--   X_MAXIMUM_DECREMENT minimum increment value
--   X_ROUTING_FLAG      approval routing flag
--OUT:
--  None
--End of Comment
-------------------------------------------------------------------------------
procedure LOAD_ROW (
  X_CHANGE_ORDER_TYPE in VARCHAR2,
  X_TOLERANCE_NAME in VARCHAR2,
  X_ORG_ID in NUMBER,
  X_OWNER in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_MAXIMUM_INCREMENT in NUMBER,
  X_MAXIMUM_DECREMENT in NUMBER,
  X_ROUTING_FLAG in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2);

end PO_CHANGE_ORDER_TOLERANCES_PKG;

 

/
