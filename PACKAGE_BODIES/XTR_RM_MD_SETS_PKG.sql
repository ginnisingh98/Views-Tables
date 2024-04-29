--------------------------------------------------------
--  DDL for Package Body XTR_RM_MD_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_RM_MD_SETS_PKG" as
/* $Header: xtrmdstb.pls 120.3 2005/06/29 10:44:33 badiredd ship $ */

    PROCEDURE insert_row(p_rowid	    IN OUT NOCOPY VARCHAR2,
			 p_set_code 	    IN VARCHAR2,
			 p_description 	    IN VARCHAR2,
			 p_authorized  	    IN VARCHAR2,
			 p_fx_spot_side     IN VARCHAR2,
			 p_bond_price_side  IN VARCHAR2,
                         p_stock_price_side  IN VARCHAR2,
			p_attribute_category IN VARCHAR2,
			p_attribute1 IN VARCHAR2,
			p_attribute2 IN VARCHAR2,
			p_attribute3 IN VARCHAR2,
			p_attribute4 IN VARCHAR2,
			p_attribute5 IN VARCHAR2,
			p_attribute6 IN VARCHAR2,
			p_attribute7 IN VARCHAR2,
			p_attribute8 IN VARCHAR2,
			p_attribute9 IN VARCHAR2,
			p_attribute10 IN VARCHAR2,
			p_attribute11 IN VARCHAR2,
			p_attribute12 IN VARCHAR2,
			p_attribute13 IN VARCHAR2,
			p_attribute14 IN VARCHAR2,
			p_attribute15 IN VARCHAR2,
			 p_created_by 	    IN NUMBER,
			 p_creation_date    IN DATE,
			 p_last_updated_by  IN NUMBER,
			 p_last_update_date IN DATE,
			 p_last_update_login IN NUMBER) IS

    CURSOR C IS select rowid from xtr_rm_md_sets
		where set_code = p_set_code;

    BEGIN

	INSERT INTO xtr_rm_md_sets(set_code,
				   description,
				   authorized_yn,
				   fx_spot_side,
				   bond_price_side,
				   stock_price_side,
			attribute_category,
			attribute1,
			attribute2,
			attribute3,
			attribute4,
			attribute5,
			attribute6,
			attribute7,
			attribute8,
			attribute9,
			attribute10,
			attribute11,
			attribute12,
			attribute13,
			attribute14,
			attribute15,
				   created_by,
				   creation_date,
				   last_updated_by,
				   last_update_date,
				   last_update_login)
			   VALUES (p_set_code,
				   p_description,
				   p_authorized,
				   p_fx_spot_side,
				   p_bond_price_side,
				   p_stock_price_side,
			p_attribute_category,
			p_attribute1,
			p_attribute2,
			p_attribute3,
			p_attribute4,
			p_attribute5,
			p_attribute6,
			p_attribute7,
			p_attribute8,
			p_attribute9,
			p_attribute10,
			p_attribute11,
			p_attribute12,
			p_attribute13,
			p_attribute14,
			p_attribute15,
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
			 p_set_code 	    IN VARCHAR2,
			 p_description	    IN VARCHAR2,
			 p_authorized       IN VARCHAR2,
			 p_fx_spot_side     IN VARCHAR2,
			 p_bond_price_side  IN VARCHAR2,
                         p_stock_price_side  IN VARCHAR2,
			p_attribute_category IN VARCHAR2,
			p_attribute1 IN VARCHAR2,
			p_attribute2 IN VARCHAR2,
			p_attribute3 IN VARCHAR2,
			p_attribute4 IN VARCHAR2,
			p_attribute5 IN VARCHAR2,
			p_attribute6 IN VARCHAR2,
			p_attribute7 IN VARCHAR2,
			p_attribute8 IN VARCHAR2,
			p_attribute9 IN VARCHAR2,
			p_attribute10 IN VARCHAR2,
			p_attribute11 IN VARCHAR2,
			p_attribute12 IN VARCHAR2,
			p_attribute13 IN VARCHAR2,
			p_attribute14 IN VARCHAR2,
			p_attribute15 IN VARCHAR2,
			 p_last_updated_by  IN NUMBER,
			 p_last_update_date IN DATE,
			 p_last_update_login IN NUMBER) IS

    BEGIN

	UPDATE xtr_rm_md_sets SET set_code 	    = p_set_code,
				  description 	    = p_description,
				  authorized_yn     = p_authorized,
				  fx_spot_side 	    = p_fx_spot_side,
				  bond_price_side   = p_bond_price_side,
                                  stock_price_side   = p_stock_price_side,
				attribute_category = p_attribute_category,
			attribute1 = p_attribute1,
			attribute2 = p_attribute2,
			attribute3 = p_attribute3,
			attribute4 = p_attribute4,
			attribute5 = p_attribute5,
			attribute6 = p_attribute6,
			attribute7 = p_attribute7,
			attribute8 = p_attribute8,
			attribute9 = p_attribute9,
			attribute10 = p_attribute10,
			attribute11 = p_attribute11,
			attribute12 = p_attribute12,
			attribute13 = p_attribute13,
			attribute14 = p_attribute14,
			attribute15 = p_attribute15,
				  last_updated_by   = p_last_updated_by,
				  last_update_date  = p_last_update_date,
				  last_update_login = p_last_update_login
	WHERE rowid = p_rowid;

	IF (SQL%NOTFOUND) THEN
	   Raise NO_DATA_FOUND;
	END IF;

    END update_row;



    PROCEDURE lock_row	(p_rowid 	   IN VARCHAR2,
			 p_set_code 	   IN VARCHAR2,
			 p_description 	   IN VARCHAR2,
			 p_authorized  	   IN VARCHAR2,
			 p_fx_spot_side    IN VARCHAR2,
			 p_bond_price_side IN VARCHAR2) IS

	CURSOR C IS
	   select * from xtr_rm_md_sets
	   where rowid = p_rowid
	   for  update of set_code NOWAIT;
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
	    ((recinfo.description = p_description) or
	     ((recinfo.description IS NULL) and (p_description IS NULL))) AND
	    ((recinfo.authorized_yn = p_authorized) OR
	     ((recinfo.authorized_yn IS NULL) and (p_authorized IS NULL)))) THEN
--	    (recinfo.fx_spot_side = p_fx_spot_side) AND
--	    (recinfo.bond_price_side = p_bond_price_side)) THEN
	    return;
	ELSE
	   fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
	   app_exception.raise_exception;
	END IF;


    END lock_row;




    PROCEDURE delete_row(p_rowid IN VARCHAR2) IS

    BEGIN

	DELETE FROM xtr_rm_md_sets WHERE rowid = p_rowid;

	IF (SQL%NOTFOUND) THEN
	   Raise NO_DATA_FOUND;
	END IF;

    END delete_row;


END XTR_RM_MD_SETS_PKG;


/
