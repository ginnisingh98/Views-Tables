--------------------------------------------------------
--  DDL for Package Body FND_SEQ_CATEGORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_SEQ_CATEGORIES_PKG" AS
/* $Header: AFSNCATB.pls 115.0 99/07/16 23:30:56 porting ship  $ */

-- ************************************************************************
  --
  -- PRIVATE FUNCTIONS
  --
-- ************************************************************************
    FUNCTION is_dublicate_cat( x_applicatio_id	NUMBER,
			       x_category_code	VARCHAR2) RETURN NUMBER IS

    Dummy VARCHAR2(10);
    CURSOR c_cat IS
	SELECT  'Duplicate'
	FROM    fnd_doc_sequence_categories fcat
	WHERE   fcat.code = x_category_code
	AND     fcat.application_id = x_applicatio_id;
    BEGIN
	OPEN c_cat;
	FETCH c_cat into Dummy;

	IF c_cat%FOUND THEN
	   CLOSE c_cat;
	   RETURN(1);
	ELSE
           CLOSE c_cat;
	   RETURN(0);
	END IF;
    END is_dublicate_cat;

-- ************************************************************************
  --
  -- PUBLIC FUNCTIONS
  --
-- ************************************************************************
    PROCEDURE check_unique_cat( x_application_id         NUMBER,
			        x_category_code          VARCHAR2) IS

    BEGIN

	IF is_dublicate_cat(x_application_id,x_category_code) = 1 THEN
	   fnd_message.set_name('FND', 'UNIQUE-DUPLICATE CODE');
	   app_exception.raise_exception;
	END IF;


    EXCEPTION
        WHEN app_exceptions.application_exception THEN
        RAISE;
    WHEN OTHERS THEN
        fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
        fnd_message.set_token('ROUTINE',
		'FND_SEQ_CATEGORIES_PKG.check_unique_cat');
	fnd_message.set_token('ERRNO',SQLCODE);
	fnd_message.set_token('REASON',SQLERRM);
        RAISE;


    END check_unique_cat;

-- ************************************************************************
    PROCEDURE insert_cat( x_application_id         NUMBER,
			  x_category_code          VARCHAR2,
                          x_category_name          VARCHAR2,
                          x_description            VARCHAR2,
			  x_table_name	           VARCHAR2,
                          x_last_updated_by        NUMBER,
                          x_created_by             NUMBER,
                          x_last_update_login      NUMBER ) IS

    BEGIN
    IF (is_dublicate_cat(x_application_id,x_category_code)=0) THEN
      INSERT INTO fnd_doc_sequence_categories (
             application_id, last_update_date, last_updated_by,
             code, name, description,
             table_name, created_by, creation_date,
             last_update_login )
      SELECT x_application_id, sysdate, x_last_updated_by,
             x_category_code, x_category_name, x_description,
             x_table_name, x_created_by, sysdate,
             x_last_update_login
      FROM   sys.dual;

    END IF;

    EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE',
		'FND_SEQ_CATEGORIES_PKG.insert_cat');
      fnd_message.set_token('ERRNO',SQLCODE);
      fnd_message.set_token('REASON',SQLERRM);
      RAISE;

    END insert_cat;

-- ************************************************************************
    PROCEDURE update_cat(  x_application_id         NUMBER,
			   x_category_code          VARCHAR2,
			   x_category_name          VARCHAR2,
                           x_description            VARCHAR2,
                           x_last_updated_by        NUMBER )  IS
    cat FND_DOC_SEQUENCE_CATEGORIES.code%TYPE;

    BEGIN
    IF is_dublicate_cat(x_application_id,x_category_code)=1 THEN
      UPDATE  fnd_doc_sequence_categories fcat
      SET     fcat.name = x_category_name,
              fcat.description = x_description,
              fcat.last_update_date = sysdate,
              fcat.last_updated_by = x_last_updated_by
      WHERE   fcat.application_id = x_application_id
      AND     fcat.code = x_category_code;
    END IF;

    EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE',
		'FND_SEQ_CATEGORIES_PKG.update_cat');
      fnd_message.set_token('ERRNO',SQLCODE);
      fnd_message.set_token('REASON',SQLERRM);

    END update_cat;


END FND_SEQ_CATEGORIES_PKG;

/
