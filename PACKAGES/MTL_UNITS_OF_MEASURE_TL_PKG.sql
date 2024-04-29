--------------------------------------------------------
--  DDL for Package MTL_UNITS_OF_MEASURE_TL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_UNITS_OF_MEASURE_TL_PKG" AUTHID CURRENT_USER as
/* $Header: INVUOMSS.pls 120.2 2006/05/17 17:53:34 satkumar noship $ */

procedure INSERT_ROW (
  X_ROW_ID IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_UNIT_OF_MEASURE in VARCHAR2,
  X_UNIT_OF_MEASURE_TL in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_REQUEST_ID in NUMBER,
  X_DISABLE_DATE in DATE,
  X_BASE_UOM_FLAG in VARCHAR2,
  X_UOM_CODE in VARCHAR2,
  X_UOM_CLASS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE);

--

procedure LOCK_ROW (
  X_UNIT_OF_MEASURE in VARCHAR2,
  X_UNIT_OF_MEASURE_TL in VARCHAR2,
  X_UOM_CODE in VARCHAR2,
  X_UOM_CLASS in VARCHAR2,
  X_BASE_UOM_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DISABLE_DATE in DATE,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_REQUEST_ID in NUMBER
);
--

procedure UPDATE_ROW (
  X_UNIT_OF_MEASURE in VARCHAR2,
  X_UNIT_OF_MEASURE_TL in VARCHAR2,
  X_UOM_CODE in VARCHAR2,
  X_UOM_CLASS in VARCHAR2,
  X_BASE_UOM_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DISABLE_DATE in DATE,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_REQUEST_ID in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

--

procedure DELETE_ROW (
  X_UNIT_OF_MEASURE in VARCHAR2
);

procedure LOAD_ROW (
  X_UNIT_OF_MEASURE in VARCHAR2,
  X_UOM_CODE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_UNIT_OF_MEASURE_TL in VARCHAR2,
  X_UOM_CLASS in VARCHAR2,
  X_BASE_UOM_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DISABLE_DATE in DATE,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_REQUEST_ID in NUMBER,
  X_APPL_SHORT_NAME in VARCHAR2
);

procedure TRANSLATE_ROW (
  X_UNIT_OF_MEASURE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_UNIT_OF_MEASURE_TL in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure ADD_LANGUAGE;

--
/* this version takes x_language as the language
 * overloaded by Oracle Exchange
 */
procedure INSERT_ROW (
  X_ROW_ID IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_UNIT_OF_MEASURE in VARCHAR2,
  X_UNIT_OF_MEASURE_TL in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_REQUEST_ID in NUMBER,
  X_DISABLE_DATE in DATE,
  X_BASE_UOM_FLAG in VARCHAR2,
  X_UOM_CODE in VARCHAR2,
  X_UOM_CLASS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE,
  x_language IN VARCHAR2
  );
--

/* this version takes x_language as the language for the user session
 * overloaded by Oracle Exchange
 */
procedure LOCK_ROW (
  X_UNIT_OF_MEASURE in VARCHAR2,
  X_UNIT_OF_MEASURE_TL in VARCHAR2,
  X_UOM_CODE in VARCHAR2,
  X_UOM_CLASS in VARCHAR2,
  X_BASE_UOM_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DISABLE_DATE in DATE,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_REQUEST_ID in NUMBER,
  x_language IN VARCHAR2
);
--
/* this version takes x_language as the language for the user session
 * overloaded by Oracle Exchange
 */
procedure UPDATE_ROW (
  X_UNIT_OF_MEASURE in VARCHAR2,
  X_UNIT_OF_MEASURE_TL in VARCHAR2,
  X_UOM_CODE in VARCHAR2,
  X_UOM_CLASS in VARCHAR2,
  X_BASE_UOM_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DISABLE_DATE in DATE,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_REQUEST_ID in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  x_language IN VARCHAR2
);

 -- Bug 5100785 : This API is called from the Translation Trigger of UOM block of the
 -- INVSDUOM.fmb form. The 4th parameter l_temp is of no use but needed to
 -- follow the way fnd handles edit OF translated records
 PROCEDURE validate_translated_row
   (
   X_UNIT_OF_MEASURE    in VARCHAR2,
   X_language IN VARCHAR2,
   X_UNIT_OF_MEASURE_TL in VARCHAR2,
   l_temp IN VARCHAR2
  );



end MTL_UNITS_OF_MEASURE_TL_PKG;

 

/
