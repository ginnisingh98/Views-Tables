--------------------------------------------------------
--  DDL for Package ASG_CONFIG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASG_CONFIG_PKG" AUTHID CURRENT_USER as
/* $Header: asgpcons.pls 120.1 2005/08/12 02:49:28 saradhak noship $ */

--
--    Table handler for ASG_CONFIG table.
--
-- HISTORY

-- SEP. 15, 2003   ytian ADDED RELEASE_Version COLUMN.
-- AUG. 30, 2002   ytian Created.
--

procedure insert_row (
  x_NAME in VARCHAR2,
  x_VALUE in VARCHAR2,
  x_DESCRIPTION  in VARCHAR2,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER,
  x_RELEASE_VERSION in NUMBER);


procedure update_row (
 x_NAME in VARCHAR2,
  x_VALUE in VARCHAR2,
  x_DESCRIPTION  in VARCHAR2,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER,
  x_RELEASE_VERSION in NUMBER);


procedure update_row (
 x_NAME in VARCHAR2,
  x_VALUE in VARCHAR2,
  x_DESCRIPTION  in VARCHAR2,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER);

procedure load_row (
 x_NAME in VARCHAR2,
  x_VALUE in VARCHAR2,
  x_DESCRIPTION  in VARCHAR2,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER,
  x_RELEASE_VERSION in NUMBER,
  p_owner in VARCHAR2);


procedure load_row (
 x_NAME in VARCHAR2,
  x_VALUE in VARCHAR2,
  x_DESCRIPTION  in VARCHAR2,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER,
  p_owner in VARCHAR2);

END ASG_CONFIG_PKG;

 

/
