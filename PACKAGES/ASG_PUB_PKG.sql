--------------------------------------------------------
--  DDL for Package ASG_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASG_PUB_PKG" AUTHID CURRENT_USER as
/* $Header: asgppubs.pls 120.1 2005/08/12 02:53:24 saradhak noship $ */

--
--    Table handler for ASG_PUB table.
--
-- HISTORY
-- JUL 16, 2003    ytian   Added ADDITIONAL_DEVICE_TYPE column.
-- MAR 11, 2003    yazhang add shared_by
-- AUG  30, 2002   ytian   Added ENABLE_SYNCH.
-- JUN  06  2002   ytian   Modified device_type to varchar2.
-- MAR. 11, 2002   ytian   Created.
--

procedure insert_row (
  x_PUB_ID in VARCHAR2,
  x_NAME in VARCHAR2,
  x_ENABLED in VARCHAR2,
  x_STATUS  in VARCHAR2,
  x_LAST_RELEASE_VERSION in NUMBER,
  x_CURRENT_RELEASE_VERSION in NUMBER,
  x_WRAPPER_NAME    in VARCHAR2,
  x_DEVICE_TYPE in VARCHAR2,
  x_ENABLE_SYNCH in VARCHAR2,
  x_NEED_RESOURCEID in VARCHAR2,
  x_CUSTOM in VARCHAR2,
  x_SHARED_BY in VARCHAR2,
  x_ADDITIONAL_DEVICE_TYPE in VARCHAR2,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER);


procedure update_row (
   x_PUB_ID in VARCHAR2,
  x_NAME in VARCHAR2,
  x_ENABLED in VARCHAR2,
  x_STATUS  in VARCHAR2,
  x_LAST_RELEASE_VERSION in NUMBER,
  x_CURRENT_RELEASE_VERSION in NUMBER,
  x_WRAPPER_NAME    in VARCHAR2,
  x_DEVICE_TYPE in VARCHAR2,
  x_ENABLE_SYNCH in VARCHAR2,
  x_NEED_RESOURCEID in VARCHAR2,
  x_CUSTOM in VARCHAR2,
  x_SHARED_BY in VARCHAR2,
  x_ADDITIONAL_DEVICE_TYPE in VARCHAR2,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER);


procedure load_row (
  x_PUB_ID in VARCHAR2,
  x_NAME in VARCHAR2,
  x_ENABLED in VARCHAR2,
  x_STATUS  in VARCHAR2,
  x_LAST_RELEASE_VERSION in NUMBER,
  x_CURRENT_RELEASE_VERSION in NUMBER,
  x_WRAPPER_NAME    in VARCHAR2,
  x_DEVICE_TYPE in VARCHAR2,
  x_ENABLE_SYNCH in VARCHAR2,
  x_NEED_RESOURCEID in VARCHAR2,
  x_CUSTOM in VARCHAR2,
  x_SHARED_BY in VARCHAR2,
  x_ADDITIONAL_DEVICE_TYPE in VARCHAR2,
  x_CREATION_DATE in DATE,
  x_CREATED_BY in NUMBER,
  x_LAST_UPDATE_DATE in DATE,
  x_LAST_UPDATED_BY in NUMBER,
  p_owner in VARCHAR2);

END ASG_PUB_PKG;

 

/