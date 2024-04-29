--------------------------------------------------------
--  DDL for Package BSC_DB_MEASURE_COLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_DB_MEASURE_COLS_PKG" AUTHID CURRENT_USER as
/* $Header: BSCMSCOS.pls 120.0 2005/06/01 17:00:43 appldev noship $ */
procedure INSERT_ROW (
  X_MEASURE_COL in VARCHAR2,
  X_MEASURE_GROUP_ID in NUMBER,
  X_PROJECTION_ID in NUMBER,
  X_MEASURE_TYPE in NUMBER,
  X_HELP in VARCHAR2);
procedure LOCK_ROW (
  X_MEASURE_COL in VARCHAR2,
  X_MEASURE_GROUP_ID in NUMBER,
  X_PROJECTION_ID in NUMBER,
  X_MEASURE_TYPE in NUMBER,
  X_HELP in VARCHAR2
);
procedure TRANSLATE_ROW (
  X_MEASURE_COL in VARCHAR2,
  X_HELP in VARCHAR2
);
procedure UPDATE_ROW (
  X_MEASURE_COL in VARCHAR2,
  X_MEASURE_GROUP_ID in NUMBER,
  X_PROJECTION_ID in NUMBER,
  X_MEASURE_TYPE in NUMBER,
  X_HELP in VARCHAR2
);
procedure DELETE_ROW (
  X_MEASURE_COL in VARCHAR2
);
procedure ADD_LANGUAGE;


-- added for Bug#3817894 (POSCO)
PROCEDURE Update_Measure_Column_Help (
    p_Measure_Col    IN VARCHAR2
  , p_Help           IN VARCHAR2
  , x_Return_Status  OUT NOCOPY VARCHAR2
  , x_Msg_Count      OUT NOCOPY NUMBER
  , x_Msg_Data       OUT NOCOPY VARCHAR2
);

end BSC_DB_MEASURE_COLS_PKG;


 

/
