--------------------------------------------------------
--  DDL for Package ASG_PROD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASG_PROD_PKG" AUTHID CURRENT_USER as
/* $Header: asgprods.pls 120.1 2005/08/12 02:53:59 saradhak noship $ */

--
--    Table handler for ASG_CONFIG table.
--
-- HISTORY

-- SEP. 15, 2003   ytian ADDED RELEASE_Version COLUMN.
-- AUG. 30, 2002   ytian Created.
--

procedure insert_row (
  x_PROD_TOP in VARCHAR2,
  x_RUN_ORDER in NUMBER,
  x_INI_FILE in VARCHAR2,
  x_ZIP_FILE in VARCHAR2,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER,
  x_RELEASE_VERSION in NUMBER);


procedure update_row (
  x_PROD_TOP in VARCHAR2,
  x_RUN_ORDER in NUMBER,
  x_INI_FILE in VARCHAR2,
  x_ZIP_FILE in VARCHAR2,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER,
  x_RELEASE_VERSION in NUMBER);


procedure load_row (
  x_PROD_TOP in VARCHAR2,
  x_RUN_ORDER in NUMBER,
  x_INI_FILE in VARCHAR2,
  x_ZIP_FILE in VARCHAR2,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER,
  x_RELEASE_VERSION in NUMBER,
  p_owner in VARCHAR2);

END ASG_PROD_PKG;

 

/
