--------------------------------------------------------
--  DDL for Package Body XTR_RM_MD_SET_CURVES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_RM_MD_SET_CURVES_PKG" as
/* $Header: xtrmdscb.pls 120.1 2005/06/29 10:47:52 csutaria ship $ */

    PROCEDURE insert_row(p_rowid	    IN OUT NOCOPY VARCHAR2,
			 p_curve_code       IN VARCHAR2,
			 p_data_side        IN VARCHAR2,
			 p_interpolation    IN VARCHAR2,
			 p_set_code 	    IN VARCHAR2,
			 p_created_by 	    IN NUMBER,
			 p_creation_date    IN DATE,
			 p_last_updated_by  IN NUMBER,
			 p_last_update_date IN DATE,
			 p_last_update_login IN NUMBER) IS

    CURSOR C IS select rowid from xtr_rm_md_set_curves
		where set_code = p_set_code and curve_code = p_curve_code;

 BEGIN

	INSERT INTO xtr_rm_md_set_curves(curve_code,
				 	 data_side,
				   	 interpolation,
					 set_code,
				  	 created_by,
					 creation_date,
					 last_updated_by,
					 last_update_date,
					 last_update_login)
				 VALUES (p_curve_code,
					 p_data_side,
					 p_interpolation,
					 p_set_code,
					 p_created_by,
					 p_creation_date,
					 p_last_updated_by,
					 p_last_update_date,
				  	 p_last_update_login);

	OPEN C;
	FETCH C INTO p_rowid;
	IF (C%NOTFOUND) THEN
	   CLOSE C;
	   raise NO_DATA_FOUND;
	END IF;
	CLOSE C;
END insert_row;


    PROCEDURE update_row(p_rowid	    IN VARCHAR2,
			 p_curve_code       IN VARCHAR2,
			 p_data_side        IN VARCHAR2,
			 p_interpolation    IN VARCHAR2,
			 p_set_code 	    IN VARCHAR2,
			 p_last_updated_by  IN NUMBER,
			 p_last_update_date IN DATE,
			 p_last_update_login IN NUMBER) IS


    BEGIN

	UPDATE xtr_rm_md_set_curves SET set_code 	 = p_set_code,
					curve_code	 = p_curve_code,
					data_side	 = p_data_side,
					interpolation	 = p_interpolation,
				  	last_updated_by  = p_last_updated_by,
				  	last_update_date = p_last_update_date,
					last_update_login = p_last_update_login
	WHERE rowid = p_rowid;

	IF (SQL%NOTFOUND) THEN
	   Raise NO_DATA_FOUND;
	END IF;

    END update_row;



    PROCEDURE lock_row	(p_rowid	    IN VARCHAR2,
			 p_curve_code       IN VARCHAR2,
			 p_data_side        IN VARCHAR2,
			 p_interpolation    IN VARCHAR2,
			 p_set_code 	    IN VARCHAR2) IS

	CURSOR C IS
	   select * from xtr_rm_md_set_curves
	   where rowid = p_rowid
	   for  update of curve_code NOWAIT;
	recinfo C%ROWTYPE;

    BEGIN

	OPEN C;
	FETCH C INTO recinfo;

	IF (C%NOTFOUND) THEN
	   CLOSE C;
	   fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
	   app_exception.raise_exception;
	END IF;
	CLOSE C;

	IF ((recinfo.set_code = p_set_code) AND
	    (recinfo.curve_code = p_curve_code) AND
	    (recinfo.interpolation = p_interpolation) AND
	    (recinfo.data_side = p_data_side)) THEN

	    return;
	ELSE
	   fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
	   app_exception.raise_exception;
	END IF;


    END lock_row;



    PROCEDURE delete_row(p_rowid IN VARCHAR2) IS

    BEGIN

	DELETE FROM xtr_rm_md_set_curves WHERE rowid = p_rowid;

	IF (SQL%NOTFOUND) THEN
	   Raise NO_DATA_FOUND;
	END IF;

    END delete_row;

END XTR_RM_MD_SET_CURVES_PKG;


/
