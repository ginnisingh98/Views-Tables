--------------------------------------------------------
--  DDL for Package JTF_CAL_SHIFT_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_CAL_SHIFT_CUHK" AUTHID CURRENT_USER as
/* $Header: jtfcluhs.pls 115.2 2002/04/09 10:52:04 pkm ship    $ */

PROCEDURE  update_shift_pre
  (X_ERROR out VARCHAR2,
  X_SHIFT_ID in NUMBER  DEFAULT fnd_api.g_miss_num,
  X_OBJECT_VERSION_NUMBER in OUT NUMBER,
  X_START_DATE_ACTIVE in DATE DEFAULT fnd_api.g_miss_date,
  X_END_DATE_ACTIVE in DATE DEFAULT fnd_api.g_miss_date,
  X_ATTRIBUTE1 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE2 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE3 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE4 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE5 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE6 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE7 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE8 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE9 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE10 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE11 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE12 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE13 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE14 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE15 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_SHIFT_NAME in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_DESCRIPTION in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_LAST_UPDATE_DATE in DATE DEFAULT fnd_api.g_miss_date,
  X_LAST_UPDATED_BY in NUMBER DEFAULT fnd_api.g_miss_num,
  X_LAST_UPDATE_LOGIN in NUMBER DEFAULT fnd_api.g_miss_num
);

PROCEDURE insert_shift_pre (
  X_ERROR out VARCHAR2,
  X_ROWID in out VARCHAR2,
  X_SHIFT_ID in  out NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER DEFAULT fnd_api.g_miss_num,
  X_START_DATE_ACTIVE in DATE DEFAULT fnd_api.g_miss_date,
  X_END_DATE_ACTIVE in DATE DEFAULT fnd_api.g_miss_date,
  X_ATTRIBUTE1 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE2 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE3 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE4 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE5 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE6 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE7 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE8 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE9 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE10 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE11 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE12 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE13 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE14 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE15 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_SHIFT_NAME in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_DESCRIPTION in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_CREATION_DATE in DATE DEFAULT fnd_api.g_miss_date,
  X_CREATED_BY in NUMBER DEFAULT fnd_api.g_miss_num,
  X_LAST_UPDATE_DATE in DATE DEFAULT fnd_api.g_miss_date,
  X_LAST_UPDATED_BY in NUMBER DEFAULT fnd_api.g_miss_num,
  X_LAST_UPDATE_LOGIN in NUMBER DEFAULT fnd_api.g_miss_num
);

PROCEDURE delete_shift_pre (
  X_SHIFT_ID in NUMBER DEFAULT fnd_api.g_miss_num
);

PROCEDURE insert_shift_constructs_pre
(
  X_ERROR out VARCHAR2,
  X_ROWID in out VARCHAR2,
  X_SHIFT_CONSTRUCT_ID in out NUMBER,
  X_SHIFT_ID in NUMBER DEFAULT fnd_api.g_miss_num,
  X_UNIT_OF_TIME_VALUE in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_BEGIN_TIME in DATE DEFAULT fnd_api.g_miss_date,
  X_END_TIME in DATE DEFAULT fnd_api.g_miss_date,
  X_START_DATE_ACTIVE in DATE DEFAULT fnd_api.g_miss_date,
  X_END_DATE_ACTIVE in DATE DEFAULT fnd_api.g_miss_date,
  X_AVAILABILITY_TYPE_CODE in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE1 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE2 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE3 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE4 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE5 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE6 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE7 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE8 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE9 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE10 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE11 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE12 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE13 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE14 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE15 in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT fnd_api.g_miss_char,
  X_CREATION_DATE in DATE DEFAULT fnd_api.g_miss_date,
  X_CREATED_BY in NUMBER DEFAULT fnd_api.g_miss_num,
  X_LAST_UPDATE_DATE in DATE DEFAULT fnd_api.g_miss_date,
  X_LAST_UPDATED_BY in NUMBER DEFAULT fnd_api.g_miss_num,
  X_LAST_UPDATE_LOGIN in NUMBER DEFAULT fnd_api.g_miss_num
  );

PROCEDURE delete_shift_constructs_pre (
  X_SHIFT_CONSTRUCT_ID in NUMBER DEFAULT fnd_api.g_miss_num
);

END JTF_CAL_SHIFT_CUHK;

 

/
