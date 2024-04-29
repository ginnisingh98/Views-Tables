--------------------------------------------------------
--  DDL for Package JTF_IH_MEDIA_LC_TY_SEED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_IH_MEDIA_LC_TY_SEED_PKG" AUTHID CURRENT_USER AS
/* $Header: JTFIHMTS.pls 120.2 2005/07/08 07:55:02 nchouras ship $ */
     PROCEDURE insert_row(
          x_rowid                          IN OUT NOCOPY VARCHAR2
        , x_milcs_type_id                    NUMBER
        , x_object_version_number            NUMBER
        , x_created_by                       NUMBER
        , x_creation_date                    DATE
        , x_last_updated_by                  NUMBER
        , x_last_update_date                 DATE
        , x_last_update_login                NUMBER
        , x_milcs_code                       VARCHAR2
        , x_short_description                VARCHAR2
     );

     PROCEDURE delete_row(
        x_milcs_type_id                    NUMBER
     );

     PROCEDURE update_row(
          x_milcs_type_id                  NUMBER
        , x_object_version_number          NUMBER
        , x_last_updated_by                NUMBER
        , x_last_update_date               DATE
        , x_last_update_login              NUMBER
        , x_milcs_code                     VARCHAR2
        , x_short_description              VARCHAR2
     );

     PROCEDURE lock_row(
          x_rowid                          VARCHAR2
        , x_milcs_type_id                  NUMBER
        , x_object_version_number          NUMBER
        , x_created_by                     NUMBER
        , x_creation_date                  DATE
        , x_last_updated_by                NUMBER
        , x_last_update_date               DATE
        , x_last_update_login              NUMBER
        , x_milcs_code                     VARCHAR2
        , x_short_description              VARCHAR2
     );

     procedure LOAD_ROW (
  	X_MILCS_TYPE_ID in NUMBER,
  	X_MILCS_CODE in VARCHAR2,
  	X_OBJECT_VERSION_NUMBER in NUMBER,
  	X_SHORT_DESCRIPTION in VARCHAR2,
  	X_OWNER IN VARCHAR2
);

	procedure LOAD_SEED_ROW (
	  X_MILCS_TYPE_ID in NUMBER,
	  X_MILCS_CODE in VARCHAR2,
	  X_OBJECT_VERSION_NUMBER in NUMBER,
	  X_SHORT_DESCRIPTION in VARCHAR2,
	  X_OWNER IN VARCHAR2,
	  X_UPLOAD_MODE in VARCHAR2
	);

END jtf_ih_media_lc_ty_seed_pkg;

 

/