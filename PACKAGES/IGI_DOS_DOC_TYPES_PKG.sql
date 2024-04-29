--------------------------------------------------------
--  DDL for Package IGI_DOS_DOC_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_DOS_DOC_TYPES_PKG" AUTHID CURRENT_USER AS
/* $Header: igidosos.pls 120.4.12000000.2 2007/06/14 04:36:47 pshivara ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_amount_type                       IN     VARCHAR2,
    x_dossier_id                        IN OUT NOCOPY NUMBER,
    x_dossier_name                      IN     VARCHAR2,
    x_dossier_numbering                 IN     VARCHAR2,
    x_coa_id                            IN     NUMBER,
    x_sob_id                            IN     NUMBER,
    x_hierarchy_id                      IN     NUMBER,
    x_balanced                          IN     VARCHAR2,
    x_dossier_description               IN     VARCHAR2,
    x_multi_annual                      IN     VARCHAR2,
    x_related_dossier                   IN     VARCHAR2,
    x_related_dossier_dsp               IN     VARCHAR2,
    x_dossier_relationship              IN     VARCHAR2,
    x_dossier_relationship_dsp          IN     VARCHAR2,
    x_dossier_status                    IN     VARCHAR2,
    x_workflow_name                     IN     VARCHAR2,
    x_retired_flag                      IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_related_dossier_id                IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_amount_type                       IN     VARCHAR2,
    x_dossier_id                        IN     NUMBER,
    x_dossier_name                      IN     VARCHAR2,
    x_dossier_numbering                 IN     VARCHAR2,
    x_coa_id                            IN     NUMBER,
    x_sob_id                            IN     NUMBER,
    x_hierarchy_id                      IN     NUMBER,
    x_balanced                          IN     VARCHAR2,
    x_dossier_description               IN     VARCHAR2,
    x_multi_annual                      IN     VARCHAR2,
    x_related_dossier                   IN     VARCHAR2,
    x_related_dossier_dsp               IN     VARCHAR2,
    x_dossier_relationship              IN     VARCHAR2,
    x_dossier_relationship_dsp          IN     VARCHAR2,
    x_dossier_status                    IN     VARCHAR2,
    x_workflow_name                     IN     VARCHAR2,
    x_retired_flag                      IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_related_dossier_id                IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_amount_type                       IN     VARCHAR2,
    x_dossier_id                        IN     NUMBER,
    x_dossier_name                      IN     VARCHAR2,
    x_dossier_numbering                 IN     VARCHAR2,
    x_coa_id                            IN     NUMBER,
    x_sob_id                            IN     NUMBER,
    x_hierarchy_id                      IN     NUMBER,
    x_balanced                          IN     VARCHAR2,
    x_dossier_description               IN     VARCHAR2,
    x_multi_annual                      IN     VARCHAR2,
    x_related_dossier                   IN     VARCHAR2,
    x_related_dossier_dsp               IN     VARCHAR2,
    x_dossier_relationship              IN     VARCHAR2,
    x_dossier_relationship_dsp          IN     VARCHAR2,
    x_dossier_status                    IN     VARCHAR2,
    x_workflow_name                     IN     VARCHAR2,
    x_retired_flag                      IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_related_dossier_id                IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_amount_type                       IN     VARCHAR2,
    x_dossier_id                        IN OUT NOCOPY NUMBER,
    x_dossier_name                      IN     VARCHAR2,
    x_dossier_numbering                 IN     VARCHAR2,
    x_coa_id                            IN     NUMBER,
    x_sob_id                            IN     NUMBER,
    x_hierarchy_id                      IN     NUMBER,
    x_balanced                          IN     VARCHAR2,
    x_dossier_description               IN     VARCHAR2,
    x_multi_annual                      IN     VARCHAR2,
    x_related_dossier                   IN     VARCHAR2,
    x_related_dossier_dsp               IN     VARCHAR2,
    x_dossier_relationship              IN     VARCHAR2,
    x_dossier_relationship_dsp          IN     VARCHAR2,
    x_dossier_status                    IN     VARCHAR2,
    x_workflow_name                     IN     VARCHAR2,
    x_retired_flag                      IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_related_dossier_id                IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_dossier_id                        IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igi_dossier_numbering (
    x_numbering_scheme                  IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_amount_type                       IN     VARCHAR2    DEFAULT NULL,
    x_dossier_id                        IN     NUMBER      DEFAULT NULL,
    x_dossier_name                      IN     VARCHAR2    DEFAULT NULL,
    x_dossier_numbering                 IN     VARCHAR2    DEFAULT NULL,
    x_coa_id                            IN     NUMBER      DEFAULT NULL,
    x_sob_id                            IN     NUMBER      DEFAULT NULL,
    x_hierarchy_id                      IN     NUMBER      DEFAULT NULL,
    x_balanced                          IN     VARCHAR2    DEFAULT NULL,
    x_dossier_description               IN     VARCHAR2    DEFAULT NULL,
    x_multi_annual                      IN     VARCHAR2    DEFAULT NULL,
    x_related_dossier                   IN     VARCHAR2    DEFAULT NULL,
    x_related_dossier_dsp               IN     VARCHAR2    DEFAULT NULL,
    x_dossier_relationship              IN     VARCHAR2    DEFAULT NULL,
    x_dossier_relationship_dsp          IN     VARCHAR2    DEFAULT NULL,
    x_dossier_status                    IN     VARCHAR2    DEFAULT NULL,
    x_workflow_name                     IN     VARCHAR2    DEFAULT NULL,
    x_retired_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_attribute_category                IN     VARCHAR2    DEFAULT NULL,
    x_attribute1                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute2                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute3                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute4                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute5                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute6                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute7                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute8                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute9                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute10                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute11                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute12                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute13                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute14                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute15                       IN     VARCHAR2    DEFAULT NULL,
    x_related_dossier_id                IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igi_dos_doc_types_pkg;

 

/
