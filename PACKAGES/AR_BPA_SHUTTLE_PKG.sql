--------------------------------------------------------
--  DDL for Package AR_BPA_SHUTTLE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_BPA_SHUTTLE_PKG" AUTHID CURRENT_USER as
/* $Header: ARBPSHLS.pls 120.1 2004/12/03 01:45:22 orashid noship $ */

procedure UPDATE_ITEM_MAP (
  P_TEMPLATE_ID in NUMBER,
  P_AREA_CODE in VARCHAR2,
  P_NEW_PARENT_AREA_CODE in VARCHAR2,
  P_SECONDARY_APP_ID in NUMBER default null,
  P_DISPLAY_LEVEL in VARCHAR2 default null,
  P_ITEM_ID in NUMBER default null,
  P_DISPLAY_SEQUENCE in NUMBER default null,
  P_DML_OPERATION IN VARCHAR2,
  X_STATUS out nocopy varchar2
);

procedure UPDATE_ITEM_MAP_ARRAY (
  P_TEMPLATE_ID in NUMBER,
  P_AREA_CODE in VARCHAR2,
  P_NEW_PARENT_AREA_CODE in VARCHAR2,
  P_SECONDARY_APP_ID in NUMBER default null,
  P_DISPLAY_LEVEL in VARCHAR2 default null,
  P_ITEM_ID_LIST in item_varray,
  P_DISPLAY_SEQUENCE in NUMBER default null,
  P_DML_OPERATION IN VARCHAR2,
  X_STATUS out nocopy varchar2
) ;

end AR_BPA_SHUTTLE_PKG;

 

/
