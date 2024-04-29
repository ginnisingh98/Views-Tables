--------------------------------------------------------
--  DDL for Package CS_BILLING_TYPE_CATEGORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_BILLING_TYPE_CATEGORIES_PKG" AUTHID CURRENT_USER as
/* $Header: csxchbcs.pls 115.4 2003/02/11 19:21:03 cnemalik noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_BILLING_TYPE in VARCHAR2,
  X_BILLING_CATEGORY in VARCHAR2,
  X_ROLLUP_ITEM_ID in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_SEEDED_FLAG in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW (
  X_BILLING_TYPE in VARCHAR2,
  X_BILLING_CATEGORY in VARCHAR2,
  X_ROLLUP_ITEM_ID in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE
);

procedure UPDATE_ROW (
  X_BILLING_TYPE in VARCHAR2,
  X_BILLING_CATEGORY in VARCHAR2,
  X_ROLLUP_ITEM_ID in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_SEEDED_FLAG in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  X_BILLING_TYPE in VARCHAR2
);

procedure LOAD_ROW (
  x_billing_type        in VARCHAR2,
  x_billing_category    in VARCHAR2,
  x_start_date_active   in VARCHAR2,
  x_end_date_active     in VARCHAR2,
  x_rollup_item_id      in NUMBER,
  x_owner               in VARCHAR2,
  x_custom_mode         in VARCHAR2,
  x_seeded_flag         in VARCHAR2,
  x_last_update_date    in VARCHAR2
);

end CS_BILLING_TYPE_CATEGORIES_PKG;

 

/
