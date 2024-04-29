--------------------------------------------------------
--  DDL for Package JTF_CAL_SHIFT_CONSTRUCTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_CAL_SHIFT_CONSTRUCTS_PKG" AUTHID CURRENT_USER as
/* $Header: jtfclscs.pls 120.2 2006/05/26 11:42:07 abraina ship $ */
procedure INSERT_ROW (
  X_ERROR out NOCOPY VARCHAR2,
  X_ROWID in out NOCOPY VARCHAR2,
  X_SHIFT_CONSTRUCT_ID in out NOCOPY NUMBER,
  X_SHIFT_ID in NUMBER,
  X_UNIT_OF_TIME_VALUE in VARCHAR2,
  X_BEGIN_TIME in DATE,
  X_END_TIME in DATE,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_AVAILABILITY_TYPE_CODE in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_ERROR out NOCOPY VARCHAR2,
  X_SHIFT_CONSTRUCT_ID in NUMBER,
  X_SHIFT_ID in NUMBER,
  X_UNIT_OF_TIME_VALUE in VARCHAR2,
  X_BEGIN_TIME in DATE,
  X_END_TIME in DATE,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_AVAILABILITY_TYPE_CODE in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2
);
procedure UPDATE_ROW (
  X_ERROR out NOCOPY VARCHAR2,
  X_SHIFT_CONSTRUCT_ID in NUMBER,
  X_SHIFT_ID in NUMBER,
  X_UNIT_OF_TIME_VALUE in VARCHAR2,
  X_BEGIN_TIME in DATE,
  X_END_TIME in DATE,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_AVAILABILITY_TYPE_CODE in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_ERROR out NOCOPY VARCHAR2,
  X_SHIFT_CONSTRUCT_ID in NUMBER
);
FUNCTION not_null(column_to_check IN DATE) RETURN boolean;
FUNCTION not_null_char(column_to_check IN CHAR) RETURN boolean;
FUNCTION end_greater_than_begin(start_date IN DATE, end_date IN DATE) RETURN boolean;
FUNCTION duplication_shift(X_SHIFT_ID IN NUMBER, X_UNIT_OF_TIME_VALUE IN CHAR,
					X_BEGIN_TIME IN DATE, X_END_TIME IN DATE,
					X_START_DATE_ACTIVE IN DATE, X_END_DATE_ACTIVE IN DATE) RETURN boolean;
FUNCTION overlap_shift(X_SHIFT_ID IN NUMBER, X_UNIT_OF_TIME_VALUE IN CHAR,
					X_START_DATE_TIME IN DATE, X_END_DATE_TIME IN DATE,
					X_START_DATE_ACTIVE IN DATE, X_END_DATE_ACTIVE IN DATE,
                                        X_SHIFT_CONSTRUCT_ID IN NUMBER) RETURN boolean;

end JTF_CAL_SHIFT_CONSTRUCTS_PKG;

 

/