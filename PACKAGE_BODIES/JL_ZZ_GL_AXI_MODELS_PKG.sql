--------------------------------------------------------
--  DDL for Package Body JL_ZZ_GL_AXI_MODELS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_GL_AXI_MODELS_PKG" AS
/* $Header: jlzzgamb.pls 115.1 2002/11/13 23:56:24 vsidhart ship $ */

  ------------------------------------------------------------
  -- Insert row procedure                                   --
  ------------------------------------------------------------
  PROCEDURE insert_row (p_rowid           IN OUT NOCOPY VARCHAR2
                      , p_model_id               NUMBER
                      , p_name                   VARCHAR2
                      , p_description            VARCHAR2
                      , p_last_update_date       DATE
                      , p_last_updated_by        NUMBER
                      , p_creation_date          DATE
                      , p_created_by             NUMBER
                      , p_last_update_login      NUMBER
                      , p_set_of_books_id        NUMBER
                      , p_attribute_category     VARCHAR2
                      , p_attribute1             VARCHAR2
                      , p_attribute2             VARCHAR2
                      , p_attribute3             VARCHAR2
                      , p_attribute4             VARCHAR2
                      , p_attribute5             VARCHAR2
                      , p_attribute6             VARCHAR2
                      , p_attribute7             VARCHAR2
                      , p_attribute8             VARCHAR2
                      , p_attribute9             VARCHAR2
                      , p_attribute10            VARCHAR2
                      , p_attribute11            VARCHAR2
                      , p_attribute12            VARCHAR2
                      , p_attribute13            VARCHAR2
                      , p_attribute14            VARCHAR2
                      , p_attribute15            VARCHAR2
                      , p_calling_sequence   IN  VARCHAR2) IS

    CURSOR c IS
      SELECT ROWID
        FROM jl_zz_gl_axi_models
        WHERE model_id = p_model_id;

    current_calling_sequence   VARCHAR2(2000);
    debug_info                 VARCHAR2(100);

  BEGIN

    current_calling_sequence := 'JL_ZZ_GL_AXI_MODELS_PKG.INSERT_ROW <-' ||
                                p_CALLING_SEQUENCE;

    debug_info := 'INSERT INTO JL_ZZ_GL_AXI_MODELS';

    INSERT INTO jl_zz_gl_axi_models
       (model_id
      , name
      , description
      , last_update_date
      , last_updated_by
      , creation_date
      , created_by
      , last_update_login
      , set_of_books_id
      , attribute_category
      , attribute1
      , attribute2
      , attribute3
      , attribute4
      , attribute5
      , attribute6
      , attribute7
      , attribute8
      , attribute9
      , attribute10
      , attribute11
      , attribute12
      , attribute13
      , attribute14
      , attribute15)
    VALUES( p_model_id
      , p_name
      , p_description
      , p_last_update_date
      , p_last_updated_by
      , p_creation_date
      , p_created_by
      , p_last_update_login
      , p_set_of_books_id
      , p_attribute_category
      , p_attribute1
      , p_attribute2
      , p_attribute3
      , p_attribute4
      , p_attribute5
      , p_attribute6
      , p_attribute7
      , p_attribute8
      , p_attribute9
      , p_attribute10
      , p_attribute11
      , p_attribute12
      , p_attribute13
      , p_attribute14
      , p_attribute15);

    debug_info := 'OPEN CURSOR C';

    OPEN c;

    debug_info := 'FETCH CURSOR C';

    FETCH c INTO p_Rowid;

    IF (C%NOTFOUND) THEN
      debug_info := 'CLOSE CURSOR C - DATA NOTFOUND';
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;

    debug_info := 'CLOSE CURSOR C';

    CLOSE c;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        fnd_message.set_name ('SQLGL','GL_DEBUG');
        fnd_message.set_token ('ERROR',SQLERRM);
        fnd_message.set_token ('CALLING_SEQUENCE', current_calling_sequence);
        fnd_message.set_token ('PARAMETERS','MODEL_ID = ' || p_model_id);
        fnd_message.set_token ('DEBUG_INFO', debug_info);
      END IF;

      app_exception.raise_exception;
  END Insert_Row;

  ------------------------------------------------------------
  -- Update row procedure                                   --
  ------------------------------------------------------------
  PROCEDURE update_row (p_Rowid                  VARCHAR2,
                        p_model_id               NUMBER
                      , p_name                   VARCHAR2
                      , p_description            VARCHAR2
                      , p_last_update_date       DATE
                      , p_last_updated_by        NUMBER
                      , p_creation_date          DATE
                      , p_created_by             NUMBER
                      , p_last_update_login      NUMBER
                      , p_set_of_books_id        NUMBER
                      , p_attribute_category     VARCHAR2
                      , p_attribute1             VARCHAR2
                      , p_attribute2             VARCHAR2
                      , p_attribute3             VARCHAR2
                      , p_attribute4             VARCHAR2
                      , p_attribute5             VARCHAR2
                      , p_attribute6             VARCHAR2
                      , p_attribute7             VARCHAR2
                      , p_attribute8             VARCHAR2
                      , p_attribute9             VARCHAR2
                      , p_attribute10            VARCHAR2
                      , p_attribute11            VARCHAR2
                      , p_attribute12            VARCHAR2
                      , p_attribute13            VARCHAR2
                      , p_attribute14            VARCHAR2
                      , p_attribute15            VARCHAR2
                      , p_calling_sequence    IN VARCHAR2) IS

    current_calling_sequence   VARCHAR2(2000);
    debug_info                 VARCHAR2(100);

  BEGIN
    current_calling_sequence := 'JL_ZZ_GL_AXI_MODELS_PKG.UPDATE_ROW <-' ||
                                 p_calling_sequence;
    debug_info := 'UPDATE JL_ZZ_GL_AXI_MODELS';

    UPDATE jl_zz_gl_axi_models
      SET model_id          = p_model_id
        , name              = p_name
        , description       = p_description
        , last_update_date  = p_last_update_date
        , last_updated_by   = p_last_updated_by
        , creation_date     = p_creation_date
        , created_by        = p_created_by
        , last_update_login = p_last_update_login
        , set_of_books_id   = p_set_of_books_id
        , attribute_category= p_attribute_category
        , attribute1        = p_attribute1
        , attribute2        = p_attribute2
        , attribute3        = p_attribute3
        , attribute4        = p_attribute4
        , attribute5        = p_attribute5
        , attribute6        = p_attribute6
        , attribute7        = p_attribute7
        , attribute8        = p_attribute8
        , attribute9        = p_attribute9
        , attribute10       = p_attribute10
        , attribute11       = p_attribute11
        , attribute12       = p_attribute12
        , attribute13       = p_attribute13
        , attribute14       = p_attribute14
        , attribute15       = p_attribute15
      WHERE rowid = p_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        fnd_message.set_name ('SQLGL','GL_DEBUG');
        fnd_message.set_token ('ERROR',SQLERRM);
        fnd_message.set_token ('CALLING_SEQUENCE', current_calling_sequence);
        fnd_message.set_token ('PARAMETERS','MODEL_ID = '||p_model_id);
        fnd_message.set_token ('DEBUG_INFO', debug_info);
      END IF;

      app_exception.raise_exception;

  END Update_Row;

  ------------------------------------------------------------
  -- Delete row procedure                                   --
  ------------------------------------------------------------
  PROCEDURE delete_row (p_rowid VARCHAR2,
                        p_model_id NUMBER,
                        p_calling_sequence IN VARCHAR2) IS

    current_calling_sequence VARCHAR2(2000);
    debug_info    VARCHAR2(100);
    CURSOR c1 IS SELECT rowid
                 FROM   jl_zz_gl_axi_model_ranges
                 WHERE  model_id = p_model_id;
  BEGIN
    current_calling_sequence := 'JL_ZZ_GL_AXI_MODELS_PKG.DELETE_ROW<-' ||
                               p_calling_sequence;

    debug_info := 'DELETE FROM JL_ZZ_GL_AXI_MODELS';

    DELETE FROM jl_zz_gl_axi_models
    WHERE rowid = p_rowid;
    FOR c1_rec IN c1 LOOP
      jl_zz_gl_axi_model_ranges_pkg.delete_row(c1_rec.rowid,'JLZZGAAM');
    END LOOP;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        fnd_message.set_name ('SQLGL','GL_DEBUG');
        fnd_message.set_token ('ERROR',SQLERRM);
        fnd_message.set_token ('CALLING_SEQUENCE', current_calling_sequence);
        fnd_message.set_token ('PARAMETERS','MODEL_ID = '||p_rowid);
        fnd_message.set_token ('DEBUG_INFO', debug_info);
      END IF;

      app_exception.raise_exception;
  END Delete_Row;

END JL_ZZ_GL_AXI_MODELS_PKG;

/
