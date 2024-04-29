--------------------------------------------------------
--  DDL for Package Body CE_FC_EXT_VIEWS_TABLE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_FC_EXT_VIEWS_TABLE_PKG" AS
/* $Header: cefexvwb.pls 120.1 2002/11/12 21:22:31 bhchung ship $ */
  FUNCTION body_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN '$Revision: 120.1 $';

  END body_revision;

  FUNCTION spec_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN G_spec_revision;

  END spec_revision;

  PROCEDURE Insert_Row(	X_rowid			IN OUT NOCOPY	VARCHAR2,
			X_external_source_type		VARCHAR2,
			X_external_source_view		VARCHAR2,
			X_db_link_name			VARCHAR2,
			X_created_by                    NUMBER,
 			X_creation_date                 DATE,
 			X_last_updated_by               NUMBER,
 			X_last_update_date              DATE,
 			X_last_update_login    		NUMBER) IS
  CURSOR C1 IS SELECT rowid
		FROM CE_FORECAST_EXT_VIEWS
		WHERE external_source_type = X_external_source_type;

  BEGIN
  INSERT INTO CE_FORECAST_EXT_VIEWS (
			external_source_type,
			external_source_view,
			db_link_name,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login)
		VALUES
		(	X_external_source_type,
			X_external_source_view,
			X_db_link_name,
			X_created_by,
 			X_creation_date,
 			X_last_updated_by,
 			X_last_update_date,
 			X_last_update_login);
  OPEN C1;
  FETCH C1 INTO X_rowid;
  IF (C1%NOTFOUND) THEN
    CLOSE C1;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE C1;

  END Insert_Row;


  PROCEDURE Update_Row(	X_Rowid				VARCHAR2,
			X_external_source_type		VARCHAR2,
			X_external_source_view		VARCHAR2,
			X_db_link_name			VARCHAR2,
			X_created_by                    NUMBER,
 			X_creation_date                 DATE,
 			X_last_updated_by               NUMBER,
 			X_last_update_date              DATE,
 			X_last_update_login    		NUMBER) IS
  BEGIN
    UPDATE CE_FORECAST_EXT_VIEWS
    SET
	external_source_type	=	X_external_source_type,
	external_source_view	=	X_external_source_view,
	db_link_name		=	X_db_link_name,
	created_by		=	X_created_by,
 	creation_date		= 	X_creation_date,
 	last_updated_by		= 	X_last_updated_by,
 	last_update_date	=	X_last_update_date,
 	last_update_login	=	X_last_update_login
    WHERE	rowid = X_rowid;
    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  END Update_Row;


  PROCEDURE Delete_Row( X_rowid				VARCHAR2) IS

  BEGIN

    DELETE FROM CE_FORECAST_EXT_VIEWS
    WHERE	rowid = X_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  END Delete_Row;

  PROCEDURE Lock_Row  (	X_Rowid				VARCHAR2,
			X_external_source_type		VARCHAR2,
			X_external_source_view		VARCHAR2,
			X_db_link_name			VARCHAR2,
			X_created_by                    NUMBER,
 			X_creation_date                 DATE,
 			X_last_updated_by               NUMBER,
 			X_last_update_date              DATE,
 			X_last_update_login    		NUMBER) IS
    CURSOR C IS SELECT *
    FROM CE_FORECAST_EXT_VIEWS
    WHERE rowid = X_rowid
    FOR UPDATE OF external_source_type NOWAIT;

    Recinfo C%ROWTYPE;
  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    IF (C%NOTFOUND)THEN
      CLOSE C;
      FND_MESSAGE.set_name('FND','FORM_RECORD_DELETED');
      APP_EXCEPTION.raise_exception;
    END IF;
    CLOSE C;

    IF(
	 (    (   (Recinfo.external_source_type = X_external_source_type )
             OR (    (Recinfo.external_source_type IS NULL)
                 AND (X_external_source_type IS NULL))))
	AND (    (   (Recinfo.external_source_view = X_external_source_view )
             OR (    (Recinfo.external_source_view IS NULL)
                 AND (X_external_source_view IS NULL))))
	AND (    (   (Recinfo.db_link_name = X_db_link_name )
             OR (    (Recinfo.db_link_name IS NULL)
                 AND (X_db_link_name IS NULL))))
	) THEN
	RETURN;
   ELSE
	FND_MESSAGE.Set_Name('FND','FORM_RECORD_CHANGED');
	APP_EXCEPTION.raise_exception;
   END IF;
  END Lock_Row;



  PROCEDURE Check_Unique(
		X_external_source_type VARCHAR2,
                X_rowid                 VARCHAR2) IS
  CURSOR chk_duplicates IS
	SELECT 'founddup'
        FROM ce_forecast_ext_views cesv
	WHERE cesv.external_source_type = X_external_source_type
	AND  (X_rowid IS NULL
                   OR cesv.rowid <> chartorowid(X_rowid));
  dummy VARCHAR2(100);
  BEGIN
        OPEN chk_duplicates;
        FETCH chk_duplicates INTO dummy;

        IF chk_duplicates%FOUND THEN
                FND_MESSAGE.Set_Name('CE', 'CE_DUPLICATE_EXT_SOURCE_TYPE');
                APP_EXCEPTION.Raise_exception;
        END IF;
        CLOSE chk_duplicates;
EXCEPTION
        WHEN APP_EXCEPTIONS.application_exception THEN
                RAISE;
        WHEN OTHERS THEn
                FND_MESSAGE.Set_Name('CE', 'CE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.Set_Token('PROCEDURE', 'CE_FC_EXT_VIEWS_TABLE_PKG.Check_Unique');
        RAISE;
  END Check_Unique;




END CE_FC_EXT_VIEWS_TABLE_PKG;

/
