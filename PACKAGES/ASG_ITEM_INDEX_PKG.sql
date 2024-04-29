--------------------------------------------------------
--  DDL for Package ASG_ITEM_INDEX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASG_ITEM_INDEX_PKG" AUTHID CURRENT_USER as
/* $Header: asgpinds.pls 120.1 2005/08/12 02:52:04 saradhak noship $ */

--
--    Table handler for ASG_PUB_ITEM_INDEX table.
--
-- HISTORY
-- MAR. 11, 2002   ytian Created.
--

procedure insert_row (
  x_INDEX_ID in VARCHAR2,
  x_ITEM_ID  in VARCHAR2,
  x_INDEX_NAME in VARCHAR2,
  x_ENABLED  in VARCHAR2,
  x_PMOD     in VARCHAR2,
  x_INDEX_COLUMNS  in VARCHAR2,
  x_LAST_RELEASE_VERSION in NUMBER,
  x_CURRENT_RELEASE_VERSION in NUMBER,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER);


procedure update_row (
  x_INDEX_ID in VARCHAR2,
  x_ITEM_ID  in VARCHAR2,
  x_INDEX_NAME in VARCHAR2,
  x_ENABLED  in VARCHAR2,
  x_PMOD     in VARCHAR2,
  x_INDEX_COLUMNS  in VARCHAR2,
  x_LAST_RELEASE_VERSION in NUMBER,
  x_CURRENT_RELEASE_VERSION in NUMBER,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER);


procedure load_row (
  x_INDEX_ID in VARCHAR2,
  x_ITEM_ID  in VARCHAR2,
  x_INDEX_NAME in VARCHAR2,
  x_ENABLED  in VARCHAR2,
  x_PMOD     in VARCHAR2,
  x_INDEX_COLUMNS  in VARCHAR2,
  x_LAST_RELEASE_VERSION in NUMBER,
  x_CURRENT_RELEASE_VERSION in NUMBER,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER,
  p_owner in VARCHAR2);

END ASG_ITEM_INDEX_PKG;

 

/
