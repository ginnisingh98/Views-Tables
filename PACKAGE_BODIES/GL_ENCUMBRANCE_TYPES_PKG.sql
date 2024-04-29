--------------------------------------------------------
--  DDL for Package Body GL_ENCUMBRANCE_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_ENCUMBRANCE_TYPES_PKG" AS
/* $Header: glietdfb.pls 120.8 2006/02/06 18:29:21 kvora ship $ */

  ---
  --- PRIVATE FUNCTIONS
  ---

  --
  -- Procedure
  --   select_row
  -- Purpose
  --   Gets the row from gl_encumbrance_types associated with
  --   the given encumbrance.
  -- History
  --   01-NOV-94  D J Ogg  Created.
  -- Arguments
  --   recinfo 		A row from gl_encumbrance_types
  -- Example
  --   gl_encumbrance_types_pkg.select_row(recinfo);
  -- Notes
  --
  PROCEDURE select_row( recinfo IN OUT NOCOPY gl_encumbrance_types%ROWTYPE )  IS
  BEGIN
    SELECT  *
    INTO    recinfo
    FROM    gl_encumbrance_types
    WHERE   encumbrance_type_id = recinfo.encumbrance_type_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_encumbrance_types.select_row');
      RAISE;
  END select_row;


  --
  -- PUBLIC FUNCTIONS
  --

  PROCEDURE check_unique_name(x_name   VARCHAR2,
                              x_row_id VARCHAR2) IS
    CURSOR chk_duplicates IS
      SELECT 'Duplicate'
      FROM   GL_ENCUMBRANCE_TYPES et
      WHERE  et.encumbrance_type = x_name
      AND    (   (x_row_id is null)
              OR (et.rowid <> x_row_id));
    dummy VARCHAR2(100);
  BEGIN
    OPEN chk_duplicates;
    FETCH chk_duplicates INTO dummy;

    IF chk_duplicates%FOUND THEN
      CLOSE chk_duplicates;
      fnd_message.set_name('SQLGL', 'GL_DUPLICATE_ENC_TYPE');
      app_exception.raise_exception;
    END IF;

    CLOSE chk_duplicates;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_encumbrance_types_pkg.check_unique_name');
      RAISE;
  END check_unique_name;

  PROCEDURE check_unique_id(x_etid   NUMBER,
                            x_row_id VARCHAR2) IS
    CURSOR chk_duplicate_ids IS
      SELECT 'Duplicate'
      FROM   GL_ENCUMBRANCE_TYPES et
      WHERE  et.encumbrance_type_id = x_etid
      AND    (   (x_row_id is null)
              OR (et.rowid <> x_row_id));
    dummy VARCHAR2(100);
  BEGIN
    OPEN chk_duplicate_ids;
    FETCH chk_duplicate_ids INTO dummy;

    IF chk_duplicate_ids%FOUND THEN
      CLOSE chk_duplicate_ids;
      fnd_message.set_name('SQLGL', 'GL_DUPLICATE_ENC_TYPE');
      app_exception.raise_exception;
    END IF;

    CLOSE chk_duplicate_ids;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_encumbrance_types_pkg.check_unique_id');
      RAISE;
  END check_unique_id;


  PROCEDURE get_unique_id (x_encumbrance_type_id  IN OUT NOCOPY NUMBER) IS
    CURSOR get_new_id IS
      SELECT gl_encumbrance_types_s.NEXTVAL
      FROM dual;
    new_id number;
  BEGIN
    OPEN get_new_id;
    FETCH get_new_id INTO x_encumbrance_type_id;

    IF get_new_id%FOUND THEN
      CLOSE get_new_id;
    ELSE
      CLOSE get_new_id;
      fnd_message.set_name('SQLGL', 'GL_ERROR_GETTING_UNIQUE_ID');
      fnd_message.set_token('SEQUENCE', 'GL_ENCUMBRANCE_TYPES_S');
      app_exception.raise_exception;
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_encumbrance_types_pkg.get_unique_id');
      RAISE;
  END get_unique_id;


  PROCEDURE select_columns(
              x_encumbrance_type_id			NUMBER,
	      x_encumbrance_type		IN OUT NOCOPY  VARCHAR2 ) IS

    recinfo gl_encumbrance_types%ROWTYPE;

  BEGIN
    recinfo.encumbrance_type_id := x_encumbrance_type_id;
    select_row( recinfo );
    x_encumbrance_type := recinfo.encumbrance_type;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_encumbrance_types.select_columns');
      RAISE;
  END select_columns;


  FUNCTION get_enc_type_all(enc_type IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS
    CURSOR get_enc_type IS
      SELECT meaning
        FROM gl_lookups
       WHERE lookup_type = 'LITERAL' AND lookup_code = 'ALL';

  BEGIN
    OPEN get_enc_type;
    FETCH get_enc_type INTO enc_type;

    IF get_enc_type%FOUND THEN
      CLOSE get_enc_type;
      return ( TRUE );
    ELSE
      CLOSE get_enc_type;
      return ( FALSE );
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN ( FALSE );
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('FUNCTION',
                            'gl_encumbrance_types.get_enc_type_all');
      RAISE;
  END get_enc_type_all;

  PROCEDURE insert_row(
              x_rowid                           IN OUT NOCOPY  VARCHAR2,
              x_encumbrance_type_id             IN OUT NOCOPY  NUMBER,
              x_encumbrance_type_key            IN OUT NOCOPY  VARCHAR2,
              x_encumbrance_type                IN  VARCHAR2,
              x_enabled_flag                    IN  VARCHAR2,
              x_last_update_date                IN  DATE,
              x_last_updated_by                 IN  NUMBER,
              x_creation_date                   IN  DATE,
              x_created_by                      IN  NUMBER,
              x_last_update_login               IN  NUMBER,
              x_description                     IN  VARCHAR2) IS

    CURSOR C IS SELECT rowid FROM gl_encumbrance_types
                WHERE  encumbrance_type = x_encumbrance_type;

    current_sequence        NUMBER := 0;
  BEGIN
    IF (x_encumbrance_type_id IS NULL) THEN
      SELECT gl_encumbrance_types_s.nextval
      INTO   x_encumbrance_type_id
      FROM   dual;
    END IF;

    IF (x_encumbrance_type_key IS NULL) THEN
      x_encumbrance_type_key := to_char(x_encumbrance_type_id);
    END IF;

    INSERT INTO gl_encumbrance_types(
            encumbrance_type_id,
            encumbrance_type_key,
            encumbrance_type,
            enabled_flag,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            description
           )
    VALUES(x_encumbrance_type_id,
           x_encumbrance_type_key,
           x_encumbrance_type,
           x_enabled_flag,
           x_last_update_date,
           x_last_updated_by,
           x_creation_date,
           x_created_by,
           x_last_update_login,
           x_description);

    OPEN C;
    FETCH C INTO x_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;

  END insert_row;


  PROCEDURE update_row(
              x_encumbrance_type_id             IN  NUMBER,
              x_encumbrance_type                IN  VARCHAR2,
              x_enabled_flag                    IN  VARCHAR2,
              x_last_update_date                IN  DATE,
              x_last_updated_by                 IN  NUMBER,
              x_last_update_login               IN  NUMBER,
              x_description                     IN  VARCHAR2) IS

  BEGIN
    UPDATE gl_encumbrance_types
    SET    encumbrance_type     =  x_encumbrance_type,
           enabled_flag         =  x_enabled_flag,
           last_update_date     =  x_last_update_date,
           last_updated_by      =  x_last_updated_by,
           last_update_login    =  x_last_update_login,
           description          =  x_description
    WHERE  encumbrance_type_id  =  x_encumbrance_type_id;

    if (SQL%NOTFOUND) then
       Raise NO_DATA_FOUND;
    end if;
  END update_row;

  PROCEDURE load_row(
            y_encumbrance_type_key            IN  VARCHAR2,
            y_owner                           IN  VARCHAR2,
            y_encumbrance_type		      IN  VARCHAR2,
            y_description                     IN  VARCHAR2,
            y_enabled_flag                    IN  VARCHAR2,
            y_force_edits                     IN  VARCHAR2 default 'N') IS

    l_user_id              NUMBER := 0;
    l_encumbrance_type_id  NUMBER;
    l_rowid                ROWID := NULL;
    l_encumbrance_type_key VARCHAR2(30);
  BEGIN

    l_encumbrance_type_key := y_encumbrance_type_key;

    IF y_owner = 'SEED' THEN
       l_user_id := 1;
    END IF;

    -- validate input parameters
    IF (l_encumbrance_type_key IS NULL OR
        y_encumbrance_type    IS NULL OR
        y_enabled_flag        IS NULL) THEN

       FND_MESSAGE.set_name('SQLGL', 'GL_LOAD_ROW_NO_DATA');
       APP_EXCEPTION.raise_exception;
    END IF;

    BEGIN

      /* Update only if force_edits is 'Y' or it is seed data */
      IF ((y_force_edits = 'Y') OR (y_owner = 'SEED')) THEN

         SELECT encumbrance_type_id
         INTO l_encumbrance_type_id
         FROM gl_encumbrance_types
         WHERE encumbrance_type_key = l_encumbrance_type_key;

         -- update row if present
         GL_ENCUMBRANCE_TYPES_PKG.update_row(
           x_encumbrance_type_id =>  l_encumbrance_type_id,
           x_encumbrance_type    =>  y_encumbrance_type,
           x_enabled_flag        =>  y_enabled_flag,
           x_last_update_date    =>  sysdate,
           x_last_updated_by     =>  l_user_id,
           x_last_update_login   =>  0,
           x_description         =>  y_description);
      END IF;

    EXCEPTION WHEN NO_DATA_FOUND THEN
      GL_ENCUMBRANCE_TYPES_PKG.insert_row(
           x_rowid               =>  l_rowid,
           x_encumbrance_type_id => l_encumbrance_type_id,
           x_encumbrance_type_key => l_encumbrance_type_key,
           x_encumbrance_type    =>  y_encumbrance_type,
           x_enabled_flag        =>  y_enabled_flag,
           x_last_update_date    =>  sysdate,
           x_last_updated_by     =>  l_user_id,
           x_creation_date       =>  sysdate,
           x_created_by          =>  l_user_id,
           x_last_update_login   =>  0,
           x_description         =>  y_description);
    END;
  END load_row;

  PROCEDURE Translate_Row(
            x_encumbrance_type_key            IN  VARCHAR2,
            x_owner                           IN  VARCHAR2,
            x_encumbrance_type		      IN  VARCHAR2,
            x_description                     IN  VARCHAR2,
            x_enabled_flag                    IN  VARCHAR2,
            x_force_edits                     IN  VARCHAR2 default 'N') IS

    l_user_id  NUMBER := 0;

  BEGIN

    IF x_owner = 'SEED' THEN
       l_user_id := 1;
    END IF;

    /* Update only if force_edits is 'Y' or it is seed data */
    IF ((x_force_edits = 'Y') OR (x_owner = 'SEED')) THEN

       UPDATE GL_ENCUMBRANCE_TYPES
       SET    encumbrance_type     =  x_encumbrance_type,
              description          =  x_description,
              last_update_date     =  sysdate,
              last_updated_by      =  l_user_id,
              last_update_login    =  0
       WHERE  encumbrance_type_key =  x_encumbrance_type_key
       AND    userenv('LANG') =
              ( SELECT language_code
                FROM  FND_LANGUAGES
                WHERE  installed_flag = 'B' );
    END IF;
 /*If base language is not set to the language being uploaded, then do nothing.*/
    IF SQL%NOTFOUND THEN
       NULL;
    END IF;

  END translate_row;

END gl_encumbrance_types_pkg;

/
