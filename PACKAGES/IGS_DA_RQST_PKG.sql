--------------------------------------------------------
--  DDL for Package IGS_DA_RQST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_DA_RQST_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSKI41S.pls 115.0 2003/04/11 07:57:28 smanglm noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_batch_id                          IN OUT NOCOPY NUMBER,
    x_request_type_id                   IN     NUMBER,
    x_request_mode                      IN     VARCHAR2,
    x_program_comparison_type           IN     VARCHAR2,
    x_request_status                    IN     VARCHAR2,
    x_person_id_group_id                IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_requestor_id                      IN     NUMBER,
    x_student_release_ind               IN     VARCHAR2,
    x_special_program                   IN     VARCHAR2,
    x_special_program_catalog           IN     VARCHAR2,
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
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_request_type_id                   IN     NUMBER,
    x_request_mode                      IN     VARCHAR2,
    x_program_comparison_type           IN     VARCHAR2,
    x_request_status                    IN     VARCHAR2,
    x_person_id_group_id                IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_requestor_id                      IN     NUMBER,
    x_student_release_ind               IN     VARCHAR2,
    x_special_program                   IN     VARCHAR2,
    x_special_program_catalog           IN     VARCHAR2,
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
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_request_type_id                   IN     NUMBER,
    x_request_mode                      IN     VARCHAR2,
    x_program_comparison_type           IN     VARCHAR2,
    x_request_status                    IN     VARCHAR2,
    x_person_id_group_id                IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_requestor_id                      IN     NUMBER,
    x_student_release_ind               IN     VARCHAR2,
    x_special_program                   IN     VARCHAR2,
    x_special_program_catalog           IN     VARCHAR2,
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
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_batch_id                          IN OUT NOCOPY NUMBER,
    x_request_type_id                   IN     NUMBER,
    x_request_mode                      IN     VARCHAR2,
    x_program_comparison_type           IN     VARCHAR2,
    x_request_status                    IN     VARCHAR2,
    x_person_id_group_id                IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_requestor_id                      IN     NUMBER,
    x_student_release_ind               IN     VARCHAR2,
    x_special_program                   IN     VARCHAR2,
    x_special_program_catalog           IN     VARCHAR2,
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
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2 ,
    X_RETURN_STATUS                     OUT NOCOPY    VARCHAR2,
    X_MSG_DATA                          OUT NOCOPY    VARCHAR2,
    X_MSG_COUNT                         OUT NOCOPY    NUMBER
  );

  FUNCTION get_pk_for_validation (
    x_batch_id                          IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_da_cnfg_req_typ (
    x_request_type_id                   IN     NUMBER
  );

  PROCEDURE get_fk_igs_pe_persid_group (
    x_group_id                          IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_batch_id                          IN     NUMBER      DEFAULT NULL,
    x_request_type_id                   IN     NUMBER      DEFAULT NULL,
    x_request_mode                      IN     VARCHAR2    DEFAULT NULL,
    x_program_comparison_type           IN     VARCHAR2    DEFAULT NULL,
    x_request_status                    IN     VARCHAR2    DEFAULT NULL,
    x_person_id_group_id                IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_requestor_id                      IN     NUMBER      DEFAULT NULL,
    x_student_release_ind               IN     VARCHAR2    DEFAULT NULL,
    x_special_program                   IN     VARCHAR2    DEFAULT NULL,
    x_special_program_catalog           IN     VARCHAR2    DEFAULT NULL,
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
    x_attribute16                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute17                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute18                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute19                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute20                       IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_da_rqst_pkg;

 

/
