--------------------------------------------------------
--  DDL for Package PJI_MT_ROWSET_DET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_MT_ROWSET_DET_PKG" AUTHID CURRENT_USER AS
/* $Header: PJIMTRDS.pls 120.1 2005/05/31 08:01:40 appldev  $ */

PROCEDURE LOCK_ROW (
  p_measure_set_code        IN pji_mt_rowset_det.measure_set_code%TYPE,
  p_rowset_code             IN pji_mt_rowset_det.rowset_code%TYPE,
  p_object_version_number   IN pji_mt_rowset_det.object_version_number%TYPE
);


PROCEDURE DELETE_ROW (
  p_measure_set_code   IN  pji_mt_rowset_det.measure_set_code%TYPE,
  p_rowset_code        IN  pji_mt_rowset_det.rowset_code%TYPE
);


PROCEDURE Insert_Row (
 X_Rowid                        IN  OUT NOCOPY  ROWID,
 X_measure_set_code             IN      pji_mt_rowset_det.measure_set_code%TYPE,
 X_rowset_code                  IN      pji_mt_rowset_det.rowset_code%TYPE,
 X_Object_Version_Number        IN      pji_mt_rowset_det.Object_Version_Number%TYPE,
 X_display_order                IN      pji_mt_rowset_det.display_order%TYPE,			--Bug 3798976
 X_Last_Update_Date             IN      pji_mt_rowset_det.Last_Update_Date%TYPE,
 X_Last_Updated_by              IN      pji_mt_rowset_det.Last_Updated_by%TYPE,
 X_Creation_Date                IN      pji_mt_rowset_det.Creation_Date%TYPE,
 X_Created_By                   IN      pji_mt_rowset_det.Created_By%TYPE,
 X_Last_Update_Login            IN      pji_mt_rowset_det.Last_Update_Login%TYPE,
 X_Return_Status	            OUT NOCOPY      VARCHAR2,
 X_Msg_Data                     OUT NOCOPY      VARCHAR2,
 X_Msg_Count                    OUT NOCOPY      NUMBER
);


PROCEDURE Update_Row (
    X_measure_set_code                IN      pji_mt_rowset_det.measure_set_code%TYPE,
    X_rowset_code                     IN      pji_mt_rowset_det.rowset_code%TYPE,
    X_Object_Version_Number           IN      pji_mt_rowset_det.Object_Version_Number%TYPE,
	X_display_order					  IN      pji_mt_rowset_det.display_order%TYPE,				--Bug 3798976
    X_Last_Update_Date                IN      pji_mt_rowset_det.Last_Update_Date%TYPE,
    X_Last_Updated_by                 IN      pji_mt_rowset_det.Last_Updated_by%TYPE,
    X_Last_Update_Login               IN      pji_mt_rowset_det.Last_Update_Login%TYPE,
    X_Return_Status	                  OUT NOCOPY      VARCHAR2,
    X_Msg_Data                        OUT NOCOPY      VARCHAR2,
    X_Msg_Count                       OUT NOCOPY      NUMBER
);


PROCEDURE Load_Row (
    X_measure_set_code          IN     pji_mt_rowset_det.measure_set_code%TYPE,
    X_rowset_code               IN     pji_mt_rowset_det.rowset_code%TYPE,
    X_Object_Version_Number     IN     pji_mt_rowset_det.Object_Version_Number%TYPE,
	X_display_order             IN     pji_mt_rowset_det.display_order%TYPE,					--Bug 3798976
    X_Owner                     IN     VARCHAR2
);


END PJI_MT_ROWSET_DET_PKG;

 

/
