--------------------------------------------------------
--  DDL for Package Body JL_ZZ_GL_AXI_MODEL_RANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_GL_AXI_MODEL_RANGES_PKG" AS
/* $Header: jlzzgmrb.pls 115.1 2002/11/13 23:55:46 vsidhart ship $ */
  ------------------------------------------------------------
  -- Insert row procedure                                   --
  ------------------------------------------------------------
  PROCEDURE Insert_Row (p_rowid              IN OUT NOCOPY VARCHAR2
                      , p_model_id                  NUMBER
                      , p_last_update_date          DATE
                      , p_last_updated_by           NUMBER
                      , p_creation_date             DATE
                      , p_created_by                NUMBER
                      , p_last_update_login         NUMBER
                      , p_set_of_books_id           NUMBER
                      , p_segment1_low              VARCHAR2
                      , p_segment1_high             VARCHAR2
                      , p_segment2_low              VARCHAR2
                      , p_segment2_high             VARCHAR2
                      , p_segment3_low              VARCHAR2
                      , p_segment3_high             VARCHAR2
                      , p_segment4_low              VARCHAR2
                      , p_segment4_high             VARCHAR2
                      , p_segment5_low              VARCHAR2
                      , p_segment5_high             VARCHAR2
                      , p_segment6_low              VARCHAR2
                      , p_segment6_high             VARCHAR2
                      , p_segment7_low              VARCHAR2
                      , p_segment7_high             VARCHAR2
                      , p_segment8_low              VARCHAR2
                      , p_segment8_high             VARCHAR2
                      , p_segment9_low              VARCHAR2
                      , p_segment9_high             VARCHAR2
                      , p_segment10_low             VARCHAR2
                      , p_segment10_high            VARCHAR2
                      , p_segment11_low             VARCHAR2
                      , p_segment11_high            VARCHAR2
                      , p_segment12_low             VARCHAR2
                      , p_segment12_high            VARCHAR2
                      , p_segment13_low             VARCHAR2
                      , p_segment13_high            VARCHAR2
                      , p_segment14_low             VARCHAR2
                      , p_segment14_high            VARCHAR2
                      , p_segment15_low             VARCHAR2
                      , p_segment15_high            VARCHAR2
                      , p_segment16_low             VARCHAR2
                      , p_segment16_high            VARCHAR2
                      , p_segment17_low             VARCHAR2
                      , p_segment17_high            VARCHAR2
                      , p_segment18_low             VARCHAR2
                      , p_segment18_high            VARCHAR2
                      , p_segment19_low             VARCHAR2
                      , p_segment19_high            VARCHAR2
                      , p_segment20_low             VARCHAR2
                      , p_segment20_high            VARCHAR2
                      , p_segment21_low             VARCHAR2
                      , p_segment21_high            VARCHAR2
                      , p_segment22_low             VARCHAR2
                      , p_segment22_high            VARCHAR2
                      , p_segment23_low             VARCHAR2
                      , p_segment23_high            VARCHAR2
                      , p_segment24_low             VARCHAR2
                      , p_segment24_high            VARCHAR2
                      , p_segment25_low             VARCHAR2
                      , p_segment25_high            VARCHAR2
                      , p_segment26_low             VARCHAR2
                      , p_segment26_high            VARCHAR2
                      , p_segment27_low             VARCHAR2
                      , p_segment27_high            VARCHAR2
                      , p_segment28_low             VARCHAR2
                      , p_segment28_high            VARCHAR2
                      , p_segment29_low             VARCHAR2
                      , p_segment29_high            VARCHAR2
                      , p_segment30_low             VARCHAR2
                      , p_segment30_high            VARCHAR2
                      , p_attribute_category        VARCHAR2
                      , p_attribute1                VARCHAR2
                      , p_attribute2                VARCHAR2
                      , p_attribute3                VARCHAR2
                      , p_attribute4                VARCHAR2
                      , p_attribute5                VARCHAR2
                      , p_attribute6                VARCHAR2
                      , p_attribute7                VARCHAR2
                      , p_attribute8                VARCHAR2
                      , p_attribute9                VARCHAR2
                      , p_attribute10               VARCHAR2
                      , p_attribute11               VARCHAR2
                      , p_attribute12               VARCHAR2
                      , p_attribute13               VARCHAR2
                      , p_attribute14               VARCHAR2
                      , p_attribute15               VARCHAR2
                      , p_calling_sequence       IN VARCHAR2) IS

  ------------------------------------------------------------
  -- Main cursor                                            --
  ------------------------------------------------------------
    CURSOR C IS
      SELECT ROWID
        FROM jl_zz_gl_axi_model_ranges
        WHERE model_id = p_model_id;

    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

  BEGIN

    current_calling_sequence := 'JL_ZZ_GL_AXI_MODEL_RANGES_PKG.INSERT_ROW <-' ||
                                p_calling_sequence;

    debug_info := 'INSERT INTO JL_ZZ_GL_AXI_MODEL_RANGES';

    INSERT INTO jl_zz_gl_axi_model_ranges
      ( model_id
      , last_update_date
      , last_updated_by
      , creation_date
      , created_by
      , last_update_login
      , set_of_books_id
      , segment1_low
      , segment1_high
      , segment2_low
      , segment2_high
      , segment3_low
      , segment3_high
      , segment4_low
      , segment4_high
      , segment5_low
      , segment5_high
      , segment6_low
      , segment6_high
      , segment7_low
      , segment7_high
      , segment8_low
      , segment8_high
      , segment9_low
      , segment9_high
      , segment10_low
      , segment10_high
      , segment11_low
      , segment11_high
      , segment12_low
      , segment12_high
      , segment13_low
      , segment13_high
      , segment14_low
      , segment14_high
      , segment15_low
      , segment15_high
      , segment16_low
      , segment16_high
      , segment17_low
      , segment17_high
      , segment18_low
      , segment18_high
      , segment19_low
      , segment19_high
      , segment20_low
      , segment20_high
      , segment21_low
      , segment21_high
      , segment22_low
      , segment22_high
      , segment23_low
      , segment23_high
      , segment24_low
      , segment24_high
      , segment25_low
      , segment25_high
      , segment26_low
      , segment26_high
      , segment27_low
      , segment27_high
      , segment28_low
      , segment28_high
      , segment29_low
      , segment29_high
      , segment30_low
      , segment30_high
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
    VALUES (p_model_id
      , p_last_update_date
      , p_last_updated_by
      , p_creation_date
      , p_created_by
      , p_last_update_login
      , p_set_of_books_id
      , p_segment1_low
      , p_segment1_high
      , p_segment2_low
      , p_segment2_high
      , p_segment3_low
      , p_segment3_high
      , p_segment4_low
      , p_segment4_high
      , p_segment5_low
      , p_segment5_high
      , p_segment6_low
      , p_segment6_high
      , p_segment7_low
      , p_segment7_high
      , p_segment8_low
      , p_segment8_high
      , p_segment9_low
      , p_segment9_high
      , p_segment10_low
      , p_segment10_high
      , p_segment11_low
      , p_segment11_high
      , p_segment12_low
      , p_segment12_high
      , p_segment13_low
      , p_segment13_high
      , p_segment14_low
      , p_segment14_high
      , p_segment15_low
      , p_segment15_high
      , p_segment16_low
      , p_segment16_high
      , p_segment17_low
      , p_segment17_high
      , p_segment18_low
      , p_segment18_high
      , p_segment19_low
      , p_segment19_high
      , p_segment20_low
      , p_segment20_high
      , p_segment21_low
      , p_segment21_high
      , p_segment22_low
      , p_segment22_high
      , p_segment23_low
      , p_segment23_high
      , p_segment24_low
      , p_segment24_high
      , p_segment25_low
      , p_segment25_high
      , p_segment26_low
      , p_segment26_high
      , p_segment27_low
      , p_segment27_high
      , p_segment28_low
      , p_segment28_high
      , p_segment29_low
      , p_segment29_high
      , p_segment30_low
      , p_segment30_high
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

    FETCH c INTO p_rowid;

    IF ( c%NOTFOUND ) THEN

      debug_info := 'CLOSE CURSOR C - DATA NOTFOUND';
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;

    debug_info := 'CLOSE CURSOR C';
    CLOSE C;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        fnd_message.set_name('SQLGL','GL_DEBUG');
        fnd_message.set_token('ERROR',SQLERRM);
        fnd_message.set_token('CALLING_SEQUENCE',current_calling_sequence);
        fnd_message.set_token('PARAMETERS','MODEL_ID = '||p_model_id);
        fnd_message.set_token('DEBUG_INFO',debug_info);
      END IF;

      app_exception.raise_exception;

  END Insert_Row;

  ------------------------------------------------------------
  -- Update row procedure                                   --
  ------------------------------------------------------------
  PROCEDURE Update_Row (p_rowid              VARCHAR2
                      , p_model_id           NUMBER
                      , p_last_update_date   DATE
                      , p_last_updated_by    NUMBER
                      , p_creation_date      DATE
                      , p_created_by         NUMBER
                      , p_last_update_login  NUMBER
                      , p_set_of_books_id    NUMBER
                      , p_segment1_low       VARCHAR2
                      , p_segment1_high      VARCHAR2
                      , p_segment2_low       VARCHAR2
                      , p_segment2_high      VARCHAR2
                      , p_segment3_low       VARCHAR2
                      , p_segment3_high      VARCHAR2
                      , p_segment4_low       VARCHAR2
                      , p_segment4_high      VARCHAR2
                      , p_segment5_low       VARCHAR2
                      , p_segment5_high      VARCHAR2
                      , p_segment6_low       VARCHAR2
                      , p_segment6_high      VARCHAR2
                      , p_segment7_low       VARCHAR2
                      , p_segment7_high      VARCHAR2
                      , p_segment8_low       VARCHAR2
                      , p_segment8_high      VARCHAR2
                      , p_segment9_low       VARCHAR2
                      , p_segment9_high      VARCHAR2
                      , p_segment10_low      VARCHAR2
                      , p_segment10_high     VARCHAR2
                      , p_segment11_low      VARCHAR2
                      , p_segment11_high     VARCHAR2
                      , p_segment12_low      VARCHAR2
                      , p_segment12_high     VARCHAR2
                      , p_segment13_low      VARCHAR2
                      , p_segment13_high     VARCHAR2
                      , p_segment14_low      VARCHAR2
                      , p_segment14_high     VARCHAR2
                      , p_segment15_low      VARCHAR2
                      , p_segment15_high     VARCHAR2
                      , p_segment16_low      VARCHAR2
                      , p_segment16_high     VARCHAR2
                      , p_segment17_low      VARCHAR2
                      , p_segment17_high     VARCHAR2
                      , p_segment18_low      VARCHAR2
                      , p_segment18_high     VARCHAR2
                      , p_segment19_low      VARCHAR2
                      , p_segment19_high     VARCHAR2
                      , p_segment20_low      VARCHAR2
                      , p_segment20_high     VARCHAR2
                      , p_segment21_low      VARCHAR2
                      , p_segment21_high     VARCHAR2
                      , p_segment22_low      VARCHAR2
                      , p_segment22_high     VARCHAR2
                      , p_segment23_low      VARCHAR2
                      , p_segment23_high     VARCHAR2
                      , p_segment24_low      VARCHAR2
                      , p_segment24_high     VARCHAR2
                      , p_segment25_low      VARCHAR2
                      , p_segment25_high     VARCHAR2
                      , p_segment26_low      VARCHAR2
                      , p_segment26_high     VARCHAR2
                      , p_segment27_low      VARCHAR2
                      , p_segment27_high     VARCHAR2
                      , p_segment28_low      VARCHAR2
                      , p_segment28_high     VARCHAR2
                      , p_segment29_low      VARCHAR2
                      , p_segment29_high     VARCHAR2
                      , p_segment30_low      VARCHAR2
                      , p_segment30_high     VARCHAR2
                      , p_attribute_category VARCHAR2
                      , p_attribute1         VARCHAR2
                      , p_attribute2         VARCHAR2
                      , p_attribute3         VARCHAR2
                      , p_attribute4         VARCHAR2
                      , p_attribute5         VARCHAR2
                      , p_attribute6         VARCHAR2
                      , p_attribute7         VARCHAR2
                      , p_attribute8         VARCHAR2
                      , p_attribute9         VARCHAR2
                      , p_attribute10        VARCHAR2
                      , p_attribute11        VARCHAR2
                      , p_attribute12        VARCHAR2
                      , p_attribute13        VARCHAR2
                      , p_attribute14        VARCHAR2
                      , p_attribute15        VARCHAR2
                      , p_calling_sequence in VARCHAR2) IS

    current_calling_sequence VARCHAR2(2000);
    debug_info               VARCHAR2(100);

  BEGIN
    current_calling_sequence := 'JL_ZZ_GL_AXI_MODEL_RANGES_PKG.UPDATE_ROW <-' ||
                                p_calling_sequence;

    debug_info := 'UPDATE JL_ZZ_GL_AXI_MODEL_RANGES';

    UPDATE jl_zz_gl_axi_model_ranges
    SET  model_id  = p_model_id
       , last_update_date = p_last_update_date
       , last_updated_by  = p_last_updated_by
       , creation_date    = p_creation_date
       , created_by       = p_created_by
       , last_update_login = p_last_update_login
       , set_of_books_id   = p_set_of_books_id
       , segment1_low      = p_segment1_low
       , segment1_high     = p_segment1_high
       , segment2_low      = p_segment2_low
       , segment2_high     = p_segment2_high
       , segment3_low      = p_segment3_low
       , segment3_high     = p_segment3_high
       , segment4_low      = p_segment4_low
       , segment4_high     = p_segment4_high
       , segment5_low      = p_segment5_low
       , segment5_high     = p_segment5_high
       , segment6_low      = p_segment6_low
       , segment6_high     = p_segment6_high
       , segment7_low      = p_segment7_low
       , segment7_high     = p_segment7_high
       , segment8_low      = p_segment8_low
       , segment8_high     = p_segment8_high
       , segment9_low      = p_segment9_low
       , segment9_high     = p_segment9_high
       , segment10_low     = p_segment10_low
       , segment10_high    = p_segment10_high
       , segment11_low     = p_segment11_low
       , segment11_high    = p_segment11_high
       , segment12_low     = p_segment12_low
       , segment12_high    = p_segment12_high
       , segment13_low     = p_segment13_low
       , segment13_high    = p_segment13_high
       , segment14_low     = p_segment14_low
       , segment14_high    = p_segment14_high
       , segment15_low     = p_segment15_low
       , segment15_high    = p_segment15_high
       , segment16_low     = p_segment16_low
       , segment16_high    = p_segment16_high
       , segment17_low     = p_segment17_low
       , segment17_high    = p_segment17_high
       , segment18_low     = p_segment18_low
       , segment18_high    = p_segment18_high
       , segment19_low     = p_segment19_low
       , segment19_high    = p_segment19_high
       , segment20_low     = p_segment20_low
       , segment20_high    = p_segment20_high
       , segment21_low     = p_segment21_low
       , segment21_high    = p_segment21_high
       , segment22_low     = p_segment22_low
       , segment22_high    = p_segment22_high
       , segment23_low     = p_segment23_low
       , segment23_high    = p_segment23_high
       , segment24_low     = p_segment24_low
       , segment24_high    = p_segment24_high
       , segment25_low     = p_segment25_low
       , segment25_high    = p_segment25_high
       , segment26_low     = p_segment26_low
       , segment26_high    = p_segment26_high
       , segment27_low     = p_segment27_low
       , segment27_high    = p_segment27_high
       , segment28_low     = p_segment28_low
       , segment28_high    = p_segment28_high
       , segment29_low     = p_segment29_low
       , segment29_high    = p_segment29_high
       , segment30_low     = p_segment30_low
       , segment30_high    = p_segment30_high
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
    WHERE rowid = P_Rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        fnd_message.set_name ('SQLGL','GL_DEBUG');
        fnd_message.set_token ('ERROR',SQLERRM);
        fnd_message.set_token ('CALLING_SEQUENCE',current_calling_sequence);
        fnd_message.set_token ('PARAMETERS','MODEL_ID = '||p_model_id);
        fnd_message.set_token ('DEBUG_INFO',debug_info);
      END IF;

      app_exception.raise_exception;
  END Update_Row;

  ------------------------------------------------------------
  -- Delete row procedure                                   --
  ------------------------------------------------------------
  PROCEDURE delete_row (p_rowid VARCHAR2
                      , p_calling_sequence IN VARCHAR2) IS

    current_calling_sequence VARCHAR2(2000);
    debug_info VARCHAR2(100);

  BEGIN
    current_calling_sequence := 'JL_ZZ_GL_AXI_MODEL_RANGES_PKG.DELETE_ROW <-' ||
                                p_calling_sequence;

    debug_info := 'DELETE FROM JL_ZZ_GL_AXI_MODEL_RANGES';

    DELETE FROM jl_zz_gl_axi_model_ranges
    WHERE rowid = P_Rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        fnd_message.set_name ('SQLGL','GL_DEBUG');
        fnd_message.set_token ('ERROR',SQLERRM);
        fnd_message.set_token ('CALLING_SEQUENCE',CURRENT_CALLING_SEQUENCE);
        fnd_message.set_token ('PARAMETERS','MODEL_ID = '||P_ROWID);
        fnd_message.set_token ('DEBUG_INFO',DEBUG_INFO);
      END IF;

      app_exception.raise_exception;
  END delete_row;

END JL_ZZ_GL_AXI_MODEL_RANGES_PKG;

/
