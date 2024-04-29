--------------------------------------------------------
--  DDL for Package PN_VAR_BKPTS_DET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_VAR_BKPTS_DET_PKG" AUTHID CURRENT_USER as
/* $Header: PNVRBKDS.pls 120.1 2006/12/20 09:23:17 pseeram noship $ */

procedure INSERT_ROW (
  X_ROWID                 in out NOCOPY VARCHAR2,
  X_BKPT_DETAIL_ID        in out NOCOPY NUMBER,
  X_BKPT_DETAIL_NUM       in out NOCOPY NUMBER,
  X_BKPT_HEADER_ID        in NUMBER,
  X_BKPT_START_DATE       in DATE,
  X_BKPT_END_DATE         in DATE,
  X_PERIOD_BKPT_VOL_START in NUMBER,
  X_PERIOD_BKPT_VOL_END   in NUMBER,
  X_GROUP_BKPT_VOL_START  in NUMBER,
  X_GROUP_BKPT_VOL_END    in NUMBER,
  X_BKPT_RATE             in NUMBER,
  X_BKDT_DEFAULT_ID       in NUMBER,
  X_VAR_RENT_ID           in NUMBER,
  X_COMMENTS              in VARCHAR2,
  X_ATTRIBUTE_CATEGORY    in VARCHAR2,
  X_ATTRIBUTE1            in VARCHAR2,
  X_ATTRIBUTE2            in VARCHAR2,
  X_ATTRIBUTE3            in VARCHAR2,
  X_ATTRIBUTE4            in VARCHAR2,
  X_ATTRIBUTE5            in VARCHAR2,
  X_ATTRIBUTE6            in VARCHAR2,
  X_ATTRIBUTE7            in VARCHAR2,
  X_ATTRIBUTE8            in VARCHAR2,
  X_ATTRIBUTE9            in VARCHAR2,
  X_ATTRIBUTE10           in VARCHAR2,
  X_ATTRIBUTE11           in VARCHAR2,
  X_ATTRIBUTE12           in VARCHAR2,
  X_ATTRIBUTE13           in VARCHAR2,
  X_ATTRIBUTE14           in VARCHAR2,
  X_ATTRIBUTE15           in VARCHAR2,
  X_ORG_ID                in NUMBER default NULL,
  X_CREATION_DATE         in DATE,
  X_CREATED_BY            in NUMBER,
  X_LAST_UPDATE_DATE      in DATE,
  X_LAST_UPDATED_BY       in NUMBER,
  X_LAST_UPDATE_LOGIN     in NUMBER,
  X_ANNUAL_BASIS_AMOUNT   in NUMBER DEFAULT NULL --03-NOV-2003
  );

procedure LOCK_ROW (
  X_BKPT_DETAIL_ID        in NUMBER,
  X_BKPT_DETAIL_NUM       in NUMBER,
  X_BKPT_HEADER_ID        in NUMBER,
  X_BKPT_START_DATE       in DATE,
  X_BKPT_END_DATE         in DATE,
  X_PERIOD_BKPT_VOL_START in NUMBER,
  X_PERIOD_BKPT_VOL_END   in NUMBER,
  X_GROUP_BKPT_VOL_START  in NUMBER,
  X_GROUP_BKPT_VOL_END    in NUMBER,
  X_BKPT_RATE             in NUMBER,
  X_BKDT_DEFAULT_ID       in NUMBER,
  X_VAR_RENT_ID           in NUMBER,
  X_COMMENTS              in VARCHAR2,
  X_ATTRIBUTE_CATEGORY    in VARCHAR2,
  X_ATTRIBUTE1            in VARCHAR2,
  X_ATTRIBUTE2            in VARCHAR2,
  X_ATTRIBUTE3            in VARCHAR2,
  X_ATTRIBUTE4            in VARCHAR2,
  X_ATTRIBUTE5            in VARCHAR2,
  X_ATTRIBUTE6            in VARCHAR2,
  X_ATTRIBUTE7            in VARCHAR2,
  X_ATTRIBUTE8            in VARCHAR2,
  X_ATTRIBUTE9            in VARCHAR2,
  X_ATTRIBUTE10           in VARCHAR2,
  X_ATTRIBUTE11           in VARCHAR2,
  X_ATTRIBUTE12           in VARCHAR2,
  X_ATTRIBUTE13           in VARCHAR2,
  X_ATTRIBUTE14           in VARCHAR2,
  X_ATTRIBUTE15           in VARCHAR2,
  X_ANNUAL_BASIS_AMOUNT   in NUMBER DEFAULT NULL --03-NOV-2003
  );

procedure UPDATE_ROW (
  X_BKPT_DETAIL_ID        in NUMBER,
  X_BKPT_DETAIL_NUM       in NUMBER,
  X_BKPT_HEADER_ID        in NUMBER,
  X_BKPT_START_DATE       in DATE,
  X_BKPT_END_DATE         in DATE,
  X_PERIOD_BKPT_VOL_START in NUMBER,
  X_PERIOD_BKPT_VOL_END   in NUMBER,
  X_GROUP_BKPT_VOL_START  in NUMBER,
  X_GROUP_BKPT_VOL_END    in NUMBER,
  X_BKPT_RATE             in NUMBER,
  X_BKDT_DEFAULT_ID       in NUMBER,
  X_VAR_RENT_ID           in NUMBER,
  X_COMMENTS              in VARCHAR2,
  X_ATTRIBUTE_CATEGORY    in VARCHAR2,
  X_ATTRIBUTE1            in VARCHAR2,
  X_ATTRIBUTE2            in VARCHAR2,
  X_ATTRIBUTE3            in VARCHAR2,
  X_ATTRIBUTE4            in VARCHAR2,
  X_ATTRIBUTE5            in VARCHAR2,
  X_ATTRIBUTE6            in VARCHAR2,
  X_ATTRIBUTE7            in VARCHAR2,
  X_ATTRIBUTE8            in VARCHAR2,
  X_ATTRIBUTE9            in VARCHAR2,
  X_ATTRIBUTE10           in VARCHAR2,
  X_ATTRIBUTE11           in VARCHAR2,
  X_ATTRIBUTE12           in VARCHAR2,
  X_ATTRIBUTE13           in VARCHAR2,
  X_ATTRIBUTE14           in VARCHAR2,
  X_ATTRIBUTE15           in VARCHAR2,
  X_LAST_UPDATE_DATE      in DATE,
  X_LAST_UPDATED_BY       in NUMBER,
  X_LAST_UPDATE_LOGIN     in NUMBER,
  X_ANNUAL_BASIS_AMOUNT   in NUMBER DEFAULT NULL --03-NOV-2003
  );

procedure DELETE_ROW (
  X_BKPT_DETAIL_ID        in NUMBER
  );

procedure CHECK_VOL_START
    (
        x_return_status     in out NOCOPY  varchar2,
        x_bkpt_header_id    in      number,
        x_bkpt_detail_id    in      number,
        x_period_vol_start  in      number
    );

end PN_VAR_BKPTS_DET_PKG;

/
