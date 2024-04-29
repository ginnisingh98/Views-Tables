--------------------------------------------------------
--  DDL for Package JL_ZZ_GL_AXI_MODEL_RANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_GL_AXI_MODEL_RANGES_PKG" AUTHID CURRENT_USER AS
/* $Header: jlzzgmrs.pls 115.2 2002/11/21 02:02:32 vsidhart ship $ */
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
                      , p_calling_sequence          VARCHAR2);


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
                      , p_calling_sequence   VARCHAR2);


  ------------------------------------------------------------
  -- Delete row procedure                                   --
  ------------------------------------------------------------
  PROCEDURE delete_row (p_rowid VARCHAR2
                      , p_calling_sequence IN VARCHAR2);


END JL_ZZ_GL_AXI_MODEL_RANGES_PKG;

 

/
