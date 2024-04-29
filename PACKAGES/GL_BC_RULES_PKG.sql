--------------------------------------------------------
--  DDL for Package GL_BC_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_BC_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: glibcrls.pls 120.3 2005/05/05 01:00:12 kvora ship $ */
--
-- Package
--   gl_bc_rules_pkg
-- Purpose
--   To contain validation, insertion, and update routines for gl_bc_rules
-- History
--   09-12-94   Sharif Rahman 	Created

PROCEDURE check_unique_bc_rules( X_rowid VARCHAR2,
                        X_bc_option_id NUMBER,
                        X_je_source_name  VARCHAR2,
                        X_je_category_name VARCHAR2 );

PROCEDURE insert_row(X_rowid                         IN OUT NOCOPY VARCHAR2 ,
                     X_bc_option_id                         NUMBER   ,
                     X_last_update_date                     DATE     ,
                     X_last_updated_by                      NUMBER   ,
                     X_last_update_login                    NUMBER   ,
                     X_je_source_name                       VARCHAR2 ,
                     X_je_category_name                     VARCHAR2 ,
                     X_funds_check_level_code               VARCHAR2 ,
                     X_creation_date                        DATE     ,
                     X_created_by                           NUMBER   ,
                     X_override_amount                      NUMBER   ,
                     X_tolerance_percentage                 NUMBER   ,
                     X_tolerance_amount                     NUMBER   ,
                     X_context                              VARCHAR2 ,
                     X_attribute1                           VARCHAR2 ,
                     X_attribute2                           VARCHAR2 ,
                     X_attribute3                           VARCHAR2 ,
                     X_attribute4                           VARCHAR2 ,
                     X_attribute5                           VARCHAR2 ,
                     X_attribute6                           VARCHAR2 ,
                     X_attribute7                           VARCHAR2 ,
                     X_attribute8                           VARCHAR2 ,
                     X_attribute9                           VARCHAR2 ,
                     X_attribute10                          VARCHAR2 ,
                     X_attribute11                          VARCHAR2 ,
                     X_attribute12                          VARCHAR2 ,
                     X_attribute13                          VARCHAR2 ,
                     X_attribute14                          VARCHAR2 ,
                     X_attribute15                          VARCHAR2 );

PROCEDURE update_row(X_rowid                         IN OUT NOCOPY VARCHAR2 ,
                     X_bc_option_id                         NUMBER   ,
                     X_last_update_date                     DATE     ,
                     X_last_updated_by                      NUMBER   ,
                     X_last_update_login                    NUMBER   ,
                     X_je_source_name                       VARCHAR2 ,
                     X_je_category_name                     VARCHAR2 ,
                     X_funds_check_level_code               VARCHAR2 ,
                     X_override_amount                      NUMBER   ,
                     X_tolerance_percentage                 NUMBER   ,
                     X_tolerance_amount                     NUMBER   ,
                     X_context                              VARCHAR2 ,
                     X_attribute1                           VARCHAR2 ,
                     X_attribute2                           VARCHAR2 ,
                     X_attribute3                           VARCHAR2 ,
                     X_attribute4                           VARCHAR2 ,
                     X_attribute5                           VARCHAR2 ,
                     X_attribute6                           VARCHAR2 ,
                     X_attribute7                           VARCHAR2 ,
                     X_attribute8                           VARCHAR2 ,
                     X_attribute9                           VARCHAR2 ,
                     X_attribute10                          VARCHAR2 ,
                     X_attribute11                          VARCHAR2 ,
                     X_attribute12                          VARCHAR2 ,
                     X_attribute13                          VARCHAR2 ,
                     X_attribute14                          VARCHAR2 ,
                     X_attribute15                          VARCHAR2 );

PROCEDURE lock_row ( X_rowid                         IN OUT NOCOPY VARCHAR2 ,
                     X_bc_option_id                         NUMBER   ,
                     X_je_source_name                       VARCHAR2 ,
                     X_je_category_name                     VARCHAR2 ,
                     X_funds_check_level_code               VARCHAR2 ,
                     X_override_amount                      NUMBER   ,
                     X_tolerance_percentage                 NUMBER   ,
                     X_tolerance_amount                     NUMBER   ,
                     X_context                              VARCHAR2 ,
                     X_attribute1                           VARCHAR2 ,
                     X_attribute2                           VARCHAR2 ,
                     X_attribute3                           VARCHAR2 ,
                     X_attribute4                           VARCHAR2 ,
                     X_attribute5                           VARCHAR2 ,
                     X_attribute6                           VARCHAR2 ,
                     X_attribute7                           VARCHAR2 ,
                     X_attribute8                           VARCHAR2 ,
                     X_attribute9                           VARCHAR2 ,
                     X_attribute10                          VARCHAR2 ,
                     X_attribute11                          VARCHAR2 ,
                     X_attribute12                          VARCHAR2 ,
                     X_attribute13                          VARCHAR2 ,
                     X_attribute14                          VARCHAR2 ,
                     X_attribute15                          VARCHAR2 );

PROCEDURE delete_row(X_rowid VARCHAR2);

FUNCTION default_source_name RETURN VARCHAR2;

FUNCTION default_category_name RETURN VARCHAR2;

END GL_BC_RULES_PKG;

 

/
