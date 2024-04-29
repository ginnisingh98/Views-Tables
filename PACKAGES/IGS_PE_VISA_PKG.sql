--------------------------------------------------------
--  DDL for Package IGS_PE_VISA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_VISA_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI40S.pls 120.0 2005/06/01 16:18:05 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_visa_id                           IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_visa_type                         IN     VARCHAR2,
    x_visa_number                       IN     VARCHAR2,
    x_visa_issue_date                   IN     DATE,
    x_visa_expiry_date                  IN     DATE,
    x_visa_category                     IN     VARCHAR2,
    x_visa_issuing_post                 IN     VARCHAR2,
    x_passport_id                       IN     NUMBER,
    x_agent_org_unit_cd                 IN     VARCHAR2,
    x_agent_person_id                   IN     NUMBER,
    x_agent_contact_name                IN     VARCHAR2,
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
	x_visa_issuing_country              IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_visa_id                           IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_visa_type                         IN     VARCHAR2,
    x_visa_number                       IN     VARCHAR2,
    x_visa_issue_date                   IN     DATE,
    x_visa_expiry_date                  IN     DATE,
    x_visa_category                     IN     VARCHAR2,
    x_visa_issuing_post                 IN     VARCHAR2,
    x_passport_id                       IN     NUMBER,
    x_agent_org_unit_cd                 IN     VARCHAR2,
    x_agent_person_id                   IN     NUMBER,
    x_agent_contact_name                IN     VARCHAR2,
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
	x_visa_issuing_country              IN     VARCHAR2   DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_visa_id                           IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_visa_type                         IN     VARCHAR2,
    x_visa_number                       IN     VARCHAR2,
    x_visa_issue_date                   IN     DATE,
    x_visa_expiry_date                  IN     DATE,
    x_visa_category                     IN     VARCHAR2,
    x_visa_issuing_post                 IN     VARCHAR2,
    x_passport_id                       IN     NUMBER,
    x_agent_org_unit_cd                 IN     VARCHAR2,
    x_agent_person_id                   IN     NUMBER,
    x_agent_contact_name                IN     VARCHAR2,
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
	x_visa_issuing_country              IN     VARCHAR2  DEFAULT NULL,
    x_mode                              IN     VARCHAR2  DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_visa_id                           IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_visa_type                         IN     VARCHAR2,
    x_visa_number                       IN     VARCHAR2,
    x_visa_issue_date                   IN     DATE,
    x_visa_expiry_date                  IN     DATE,
    x_visa_category                     IN     VARCHAR2,
    x_visa_issuing_post                 IN     VARCHAR2,
    x_passport_id                       IN     NUMBER,
    x_agent_org_unit_cd                 IN     VARCHAR2,
    x_agent_person_id                   IN     NUMBER,
    x_agent_contact_name                IN     VARCHAR2,
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
	x_visa_issuing_country              IN     VARCHAR2 DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_visa_id                           IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_person_id                         IN     NUMBER,
    x_visa_type                         IN     VARCHAR2,
    x_visa_issue_date                   IN     DATE
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_pe_passport (
    x_passport_id                       IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_visa_id                           IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_visa_type                         IN     VARCHAR2    DEFAULT NULL,
    x_visa_number                       IN     VARCHAR2    DEFAULT NULL,
    x_visa_issue_date                   IN     DATE        DEFAULT NULL,
    x_visa_expiry_date                  IN     DATE        DEFAULT NULL,
    x_visa_category                     IN     VARCHAR2    DEFAULT NULL,
    x_visa_issuing_post                 IN     VARCHAR2    DEFAULT NULL,
    x_passport_id                       IN     NUMBER      DEFAULT NULL,
    x_agent_org_unit_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_agent_person_id                   IN     NUMBER      DEFAULT NULL,
    x_agent_contact_name                IN     VARCHAR2    DEFAULT NULL,
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
	x_visa_issuing_country              IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_pe_visa_pkg;

 

/
