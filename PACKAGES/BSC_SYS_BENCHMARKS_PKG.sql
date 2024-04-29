--------------------------------------------------------
--  DDL for Package BSC_SYS_BENCHMARKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_SYS_BENCHMARKS_PKG" AUTHID CURRENT_USER as
/* $Header: BSCBMTLS.pls 120.1 2005/08/17 12:34:21 hcamacho noship $ */
procedure INSERT_ROW (
  X_BM_ID in NUMBER,
  X_COLOR in NUMBER,
  X_DATA_TYPE in NUMBER,
  X_SOURCE_TYPE in NUMBER,
  X_PERIODICITY_ID in NUMBER,
  X_NO_DISPLAY_FLAG in NUMBER,
  X_NAME in VARCHAR2);

procedure LOCK_ROW (
  X_BM_ID in NUMBER,
  X_COLOR in NUMBER,
  X_DATA_TYPE in NUMBER,
  X_SOURCE_TYPE in NUMBER,
  X_PERIODICITY_ID in NUMBER,
  X_NO_DISPLAY_FLAG in NUMBER,
  X_NAME in VARCHAR2
);

PROCEDURE TRANSLATE_ROW
(
    p_Bm_id   IN  NUMBER
  , p_Name    IN  VARCHAR2
);

procedure DELETE_ROW (
  X_BM_ID in NUMBER
);
procedure ADD_LANGUAGE;



PROCEDURE INSERT_ROW (
    p_Bm_id              IN     NUMBER
  , p_Color              IN     NUMBER
  , p_Data_type          IN     NUMBER
  , p_Source_type        IN     NUMBER
  , p_Periodicity_id     IN     NUMBER
  , p_No_display_flag    IN     NUMBER
  , p_Name               IN     VARCHAR2
  , p_Created_by         IN     NUMBER
  , p_Creation_date      IN     DATE
  , p_Last_updated_by    IN     NUMBER
  , p_Last_update_date   IN     DATE
  , p_Last_update_login  IN     NUMBER
);

PROCEDURE UPDATE_ROW (
    p_Bm_id              IN     NUMBER
  , p_Color              IN     NUMBER
  , p_Data_type          IN     NUMBER
  , p_Source_type        IN     NUMBER
  , p_Periodicity_id     IN     NUMBER
  , p_No_display_flag    IN     NUMBER
  , p_Name               IN     VARCHAR2
  , p_Last_updated_by    IN     NUMBER
  , p_Last_update_date   IN     DATE
  , p_Last_update_login  IN     NUMBER
  , p_Custom_mode        IN     VARCHAR2
) ;


end BSC_SYS_BENCHMARKS_PKG;

 

/
