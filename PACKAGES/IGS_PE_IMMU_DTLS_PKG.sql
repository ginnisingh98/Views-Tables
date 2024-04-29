--------------------------------------------------------
--  DDL for Package IGS_PE_IMMU_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_IMMU_DTLS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI90S.pls 120.0 2005/06/01 20:22:03 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY  VARCHAR2,
    x_immu_details_id                   IN OUT NOCOPY  NUMBER,
    x_person_id                         IN      NUMBER,
    x_immunization_code                 IN      VARCHAR2,
    x_status_code                       IN      VARCHAR2,
    x_start_date                        IN      DATE,
    x_end_date                          IN      DATE,
    x_ATTRIBUTE_CATEGORY		IN	VARCHAR2,
    x_ATTRIBUTE1			IN	VARCHAR2,
    x_ATTRIBUTE2			IN	VARCHAR2,
    x_ATTRIBUTE3			IN	VARCHAR2,
    x_ATTRIBUTE4			IN	VARCHAR2,
    x_ATTRIBUTE5			IN	VARCHAR2,
    x_ATTRIBUTE6			IN	VARCHAR2,
    x_ATTRIBUTE7			IN	VARCHAR2,
    x_ATTRIBUTE8			IN	VARCHAR2,
    x_ATTRIBUTE9			IN	VARCHAR2,
    x_ATTRIBUTE10			IN	VARCHAR2,
    x_ATTRIBUTE11			IN	VARCHAR2,
    x_ATTRIBUTE12			IN	VARCHAR2,
    x_ATTRIBUTE13			IN	VARCHAR2,
    x_ATTRIBUTE14			IN	VARCHAR2,
    x_ATTRIBUTE15			IN	VARCHAR2,
    x_ATTRIBUTE16			IN	VARCHAR2,
    x_ATTRIBUTE17			IN	VARCHAR2,
    x_ATTRIBUTE18			IN	VARCHAR2,
    x_ATTRIBUTE19			IN	VARCHAR2,
    x_ATTRIBUTE20			IN	VARCHAR2,
    x_mode                              IN      VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN      VARCHAR2,
    x_immu_details_id                   IN      NUMBER,
    x_person_id                         IN      NUMBER,
    x_immunization_code                 IN      VARCHAR2,
    x_status_code                       IN      VARCHAR2,
    x_start_date                        IN      DATE,
    x_end_date                          IN      DATE,
    x_ATTRIBUTE_CATEGORY		IN	VARCHAR2,
    x_ATTRIBUTE1			IN	VARCHAR2,
    x_ATTRIBUTE2			IN	VARCHAR2,
    x_ATTRIBUTE3			IN	VARCHAR2,
    x_ATTRIBUTE4			IN	VARCHAR2,
    x_ATTRIBUTE5			IN	VARCHAR2,
    x_ATTRIBUTE6			IN	VARCHAR2,
    x_ATTRIBUTE7			IN	VARCHAR2,
    x_ATTRIBUTE8			IN	VARCHAR2,
    x_ATTRIBUTE9			IN	VARCHAR2,
    x_ATTRIBUTE10			IN	VARCHAR2,
    x_ATTRIBUTE11			IN	VARCHAR2,
    x_ATTRIBUTE12			IN	VARCHAR2,
    x_ATTRIBUTE13			IN	VARCHAR2,
    x_ATTRIBUTE14			IN	VARCHAR2,
    x_ATTRIBUTE15			IN	VARCHAR2,
    x_ATTRIBUTE16			IN	VARCHAR2,
    x_ATTRIBUTE17			IN	VARCHAR2,
    x_ATTRIBUTE18			IN	VARCHAR2,
    x_ATTRIBUTE19			IN	VARCHAR2,
    x_ATTRIBUTE20			IN	VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN      VARCHAR2,
    x_immu_details_id                   IN      NUMBER,
    x_person_id                         IN      NUMBER,
    x_immunization_code                 IN      VARCHAR2,
    x_status_code                       IN      VARCHAR2,
    x_start_date                        IN      DATE,
    x_end_date                          IN      DATE,
    x_ATTRIBUTE_CATEGORY		IN	VARCHAR2,
    x_ATTRIBUTE1			IN	VARCHAR2,
    x_ATTRIBUTE2			IN	VARCHAR2,
    x_ATTRIBUTE3			IN	VARCHAR2,
    x_ATTRIBUTE4			IN	VARCHAR2,
    x_ATTRIBUTE5			IN	VARCHAR2,
    x_ATTRIBUTE6			IN	VARCHAR2,
    x_ATTRIBUTE7			IN	VARCHAR2,
    x_ATTRIBUTE8			IN	VARCHAR2,
    x_ATTRIBUTE9			IN	VARCHAR2,
    x_ATTRIBUTE10			IN	VARCHAR2,
    x_ATTRIBUTE11			IN	VARCHAR2,
    x_ATTRIBUTE12			IN	VARCHAR2,
    x_ATTRIBUTE13			IN	VARCHAR2,
    x_ATTRIBUTE14			IN	VARCHAR2,
    x_ATTRIBUTE15			IN	VARCHAR2,
    x_ATTRIBUTE16			IN	VARCHAR2,
    x_ATTRIBUTE17			IN	VARCHAR2,
    x_ATTRIBUTE18			IN	VARCHAR2,
    x_ATTRIBUTE19			IN	VARCHAR2,
    x_ATTRIBUTE20			IN	VARCHAR2,
    x_mode                              IN      VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY  VARCHAR2,
    x_immu_details_id                   IN OUT NOCOPY  NUMBER,
    x_person_id                         IN      NUMBER,
    x_immunization_code                 IN      VARCHAR2,
    x_status_code                       IN      VARCHAR2,
    x_start_date                        IN      DATE,
    x_end_date                          IN      DATE,
    x_ATTRIBUTE_CATEGORY		IN	VARCHAR2,
    x_ATTRIBUTE1			IN	VARCHAR2,
    x_ATTRIBUTE2			IN	VARCHAR2,
    x_ATTRIBUTE3			IN	VARCHAR2,
    x_ATTRIBUTE4			IN	VARCHAR2,
    x_ATTRIBUTE5			IN	VARCHAR2,
    x_ATTRIBUTE6			IN	VARCHAR2,
    x_ATTRIBUTE7			IN	VARCHAR2,
    x_ATTRIBUTE8			IN	VARCHAR2,
    x_ATTRIBUTE9			IN	VARCHAR2,
    x_ATTRIBUTE10			IN	VARCHAR2,
    x_ATTRIBUTE11			IN	VARCHAR2,
    x_ATTRIBUTE12			IN	VARCHAR2,
    x_ATTRIBUTE13			IN	VARCHAR2,
    x_ATTRIBUTE14			IN	VARCHAR2,
    x_ATTRIBUTE15			IN	VARCHAR2,
    x_ATTRIBUTE16			IN	VARCHAR2,
    x_ATTRIBUTE17			IN	VARCHAR2,
    x_ATTRIBUTE18			IN	VARCHAR2,
    x_ATTRIBUTE19			IN	VARCHAR2,
    x_ATTRIBUTE20			IN	VARCHAR2,
    x_mode                              IN      VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_immu_details_id                   IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_person_id                         IN     NUMBER,
    x_immunization_code                 IN     VARCHAR2,
    x_start_date                        IN     DATE
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_hz_parties (
    x_party_id                          IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN      VARCHAR2,
    x_rowid                             IN      VARCHAR2        DEFAULT NULL,
    x_immu_details_id                   IN      NUMBER          DEFAULT NULL,
    x_person_id                         IN      NUMBER          DEFAULT NULL,
    x_immunization_code                 IN      VARCHAR2        DEFAULT NULL,
    x_status_code                       IN      VARCHAR2        DEFAULT NULL,
    x_start_date                        IN      DATE            DEFAULT NULL,
    x_end_date                          IN      DATE            DEFAULT NULL,
    x_attribute_category		IN	VARCHAR2	DEFAULT NULL,
    x_attribute1			IN	VARCHAR2	DEFAULT NULL,
    x_attribute2			IN	VARCHAR2	DEFAULT NULL,
    x_attribute3			IN	VARCHAR2	DEFAULT NULL,
    x_attribute4			IN	VARCHAR2	DEFAULT NULL,
    x_attribute5			IN	VARCHAR2	DEFAULT NULL,
    x_attribute6			IN	VARCHAR2	DEFAULT NULL,
    x_attribute7			IN	VARCHAR2	DEFAULT NULL,
    x_attribute8			IN	VARCHAR2	DEFAULT NULL,
    x_attribute9			IN	VARCHAR2	DEFAULT NULL,
    x_attribute10			IN	VARCHAR2	DEFAULT NULL,
    x_attribute11			IN	VARCHAR2	DEFAULT NULL,
    x_attribute12			IN	VARCHAR2	DEFAULT NULL,
    x_attribute13			IN	VARCHAR2	DEFAULT NULL,
    x_attribute14			IN	VARCHAR2	DEFAULT NULL,
    x_attribute15			IN	VARCHAR2	DEFAULT NULL,
    x_attribute16			IN	VARCHAR2	DEFAULT NULL,
    x_attribute17			IN	VARCHAR2	DEFAULT NULL,
    x_attribute18			IN	VARCHAR2	DEFAULT NULL,
    x_attribute19			IN	VARCHAR2	DEFAULT NULL,
    x_attribute20			IN	VARCHAR2	DEFAULT NULL,
    x_creation_date                     IN      DATE		DEFAULT NULL,
    x_created_by                        IN      NUMBER          DEFAULT NULL,
    x_last_update_date                  IN      DATE            DEFAULT NULL,
    x_last_updated_by                   IN      NUMBER          DEFAULT NULL,
    x_last_update_login                 IN      NUMBER          DEFAULT NULL
  );

END igs_pe_immu_dtls_pkg;

 

/
