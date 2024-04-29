--------------------------------------------------------
--  DDL for Package JL_ZZ_GL_AXI_MODELS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_GL_AXI_MODELS_PKG" AUTHID CURRENT_USER AS
/* $Header: jlzzgams.pls 115.0 99/07/16 03:14:10 porting ship $ */

  ------------------------------------------------------------
  -- Insert row procedure                                   --
  ------------------------------------------------------------
  PROCEDURE insert_row (p_rowid           IN OUT VARCHAR2
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
                      , p_calling_sequence   IN  VARCHAR2);


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
                      , p_calling_sequence    IN VARCHAR2);

  ------------------------------------------------------------
  -- Delete row procedure                                   --
  ------------------------------------------------------------
  PROCEDURE delete_row (p_rowid VARCHAR2, p_model_id NUMBER, p_calling_sequence IN VARCHAR2);

END JL_ZZ_GL_AXI_MODELS_PKG;

 

/
