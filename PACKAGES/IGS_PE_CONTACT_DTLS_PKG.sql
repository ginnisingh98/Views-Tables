--------------------------------------------------------
--  DDL for Package IGS_PE_CONTACT_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_CONTACT_DTLS_PKG" AUTHID CURRENT_USER AS
  /* $Header: IGSNI73S.pls 120.0 2005/06/02 04:15:40 appldev noship $ */
  PROCEDURE insert_row (
    x_rowid IN OUT NOCOPY VARCHAR2,
    x_phone_line_type IN VARCHAR2,
    x_contact_point_id IN OUT NOCOPY NUMBER,
    x_location_venue_addr_id IN NUMBER,
    x_contact_point_type IN VARCHAR2,
    x_status IN VARCHAR2,
    x_primary_flag IN VARCHAR2,
    x_email_format IN VARCHAR2,
    x_email_address IN VARCHAR2,
    x_telephone_type IN VARCHAR2,
    x_phone_area_code IN VARCHAR2,
    x_phone_country_code IN VARCHAR2,
    x_phone_number IN VARCHAR2,
    x_phone_extension IN VARCHAR2,
    x_attribute_category IN VARCHAR2,
    x_attribute1 IN VARCHAR2,
    x_attribute2 IN VARCHAR2,
    x_attribute3 IN VARCHAR2,
    x_attribute4 IN VARCHAR2,
    x_attribute5 IN VARCHAR2,
    x_attribute6 IN VARCHAR2,
    x_attribute7 IN VARCHAR2,
    x_attribute8 IN VARCHAR2,
    x_attribute9 IN VARCHAR2,
    x_attribute10 IN VARCHAR2,
    x_attribute11 IN VARCHAR2,
    x_attribute12 IN VARCHAR2,
    x_attribute13 IN VARCHAR2,
    x_attribute14 IN VARCHAR2,
    x_attribute15 IN VARCHAR2,
    x_attribute16 IN VARCHAR2,
    x_attribute17 IN VARCHAR2,
    x_attribute18 IN VARCHAR2,
    x_attribute19 IN VARCHAR2,
    x_attribute20 IN VARCHAR2,
    x_mode IN VARCHAR2 DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid IN VARCHAR2,
    x_phone_line_type IN VARCHAR2,
    x_contact_point_id IN NUMBER,
    x_location_venue_addr_id IN NUMBER,
    x_contact_point_type IN VARCHAR2,
    x_status IN VARCHAR2,
    x_primary_flag IN VARCHAR2,
    x_email_format IN VARCHAR2,
    x_email_address IN VARCHAR2,
    x_telephone_type IN VARCHAR2,
    x_phone_area_code IN VARCHAR2,
    x_phone_country_code IN VARCHAR2,
    x_phone_number IN VARCHAR2,
    x_phone_extension IN VARCHAR2,
    x_attribute_category IN VARCHAR2,
    x_attribute1 IN VARCHAR2,
    x_attribute2 IN VARCHAR2,
    x_attribute3 IN VARCHAR2,
    x_attribute4 IN VARCHAR2,
    x_attribute5 IN VARCHAR2,
    x_attribute6 IN VARCHAR2,
    x_attribute7 IN VARCHAR2,
    x_attribute8 IN VARCHAR2,
    x_attribute9 IN VARCHAR2,
    x_attribute10 IN VARCHAR2,
    x_attribute11 IN VARCHAR2,
    x_attribute12 IN VARCHAR2,
    x_attribute13 IN VARCHAR2,
    x_attribute14 IN VARCHAR2,
    x_attribute15 IN VARCHAR2,
    x_attribute16 IN VARCHAR2,
    x_attribute17 IN VARCHAR2,
    x_attribute18 IN VARCHAR2,
    x_attribute19 IN VARCHAR2,
    x_attribute20 IN VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid IN VARCHAR2,
    x_phone_line_type IN VARCHAR2,
    x_contact_point_id IN NUMBER,
    x_location_venue_addr_id IN NUMBER,
    x_contact_point_type IN VARCHAR2,
    x_status IN VARCHAR2,
    x_primary_flag IN VARCHAR2,
    x_email_format IN VARCHAR2,
    x_email_address IN VARCHAR2,
    x_telephone_type IN VARCHAR2,
    x_phone_area_code IN VARCHAR2,
    x_phone_country_code IN VARCHAR2,
    x_phone_number IN VARCHAR2,
    x_phone_extension IN VARCHAR2,
    x_attribute_category IN VARCHAR2,
    x_attribute1 IN VARCHAR2,
    x_attribute2 IN VARCHAR2,
    x_attribute3 IN VARCHAR2,
    x_attribute4 IN VARCHAR2,
    x_attribute5 IN VARCHAR2,
    x_attribute6 IN VARCHAR2,
    x_attribute7 IN VARCHAR2,
    x_attribute8 IN VARCHAR2,
    x_attribute9 IN VARCHAR2,
    x_attribute10 IN VARCHAR2,
    x_attribute11 IN VARCHAR2,
    x_attribute12 IN VARCHAR2,
    x_attribute13 IN VARCHAR2,
    x_attribute14 IN VARCHAR2,
    x_attribute15 IN VARCHAR2,
    x_attribute16 IN VARCHAR2,
    x_attribute17 IN VARCHAR2,
    x_attribute18 IN VARCHAR2,
    x_attribute19 IN VARCHAR2,
    x_attribute20 IN VARCHAR2,
    x_mode IN VARCHAR2 DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid IN OUT NOCOPY VARCHAR2,
    x_phone_line_type IN VARCHAR2,
    x_contact_point_id IN OUT NOCOPY NUMBER,
    x_location_venue_addr_id IN NUMBER,
    x_contact_point_type IN VARCHAR2,
    x_status IN VARCHAR2,
    x_primary_flag IN VARCHAR2,
    x_email_format IN VARCHAR2,
    x_email_address IN VARCHAR2,
    x_telephone_type IN VARCHAR2,
    x_phone_area_code IN VARCHAR2,
    x_phone_country_code IN VARCHAR2,
    x_phone_number IN VARCHAR2,
    x_phone_extension IN VARCHAR2,
    x_attribute_category IN VARCHAR2,
    x_attribute1 IN VARCHAR2,
    x_attribute2 IN VARCHAR2,
    x_attribute3 IN VARCHAR2,
    x_attribute4 IN VARCHAR2,
    x_attribute5 IN VARCHAR2,
    x_attribute6 IN VARCHAR2,
    x_attribute7 IN VARCHAR2,
    x_attribute8 IN VARCHAR2,
    x_attribute9 IN VARCHAR2,
    x_attribute10 IN VARCHAR2,
    x_attribute11 IN VARCHAR2,
    x_attribute12 IN VARCHAR2,
    x_attribute13 IN VARCHAR2,
    x_attribute14 IN VARCHAR2,
    x_attribute15 IN VARCHAR2,
    x_attribute16 IN VARCHAR2,
    x_attribute17 IN VARCHAR2,
    x_attribute18 IN VARCHAR2,
    x_attribute19 IN VARCHAR2,
    x_attribute20 IN VARCHAR2,
    x_mode IN VARCHAR2 DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_contact_point_id IN NUMBER
  ) RETURN BOOLEAN;

 PROCEDURE get_fk_igs_ad_locvenue_addr (
   x_location_venue_addr_id IN NUMBER
    );

  PROCEDURE check_constraints (
    column_name IN VARCHAR2 DEFAULT NULL,
    column_value IN VARCHAR2 DEFAULT NULL
  );

  PROCEDURE before_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_phone_line_type IN VARCHAR2 DEFAULT NULL,
    x_contact_point_id IN NUMBER DEFAULT NULL,
    x_location_venue_addr_id IN NUMBER DEFAULT NULL,
    x_contact_point_type IN VARCHAR2 DEFAULT NULL,
    x_status IN VARCHAR2 DEFAULT NULL,
    x_primary_flag IN VARCHAR2 DEFAULT NULL,
    x_email_format IN VARCHAR2 DEFAULT NULL,
    x_email_address IN VARCHAR2 DEFAULT NULL,
    x_telephone_type IN VARCHAR2 DEFAULT NULL,
    x_phone_area_code IN VARCHAR2 DEFAULT NULL,
    x_phone_country_code IN VARCHAR2 DEFAULT NULL,
    x_phone_number IN VARCHAR2 DEFAULT NULL,
    x_phone_extension IN VARCHAR2 DEFAULT NULL,
    x_attribute_category IN VARCHAR2 DEFAULT NULL,
    x_attribute1 IN VARCHAR2 DEFAULT NULL,
    x_attribute2 IN VARCHAR2 DEFAULT NULL,
    x_attribute3 IN VARCHAR2 DEFAULT NULL,
    x_attribute4 IN VARCHAR2 DEFAULT NULL,
    x_attribute5 IN VARCHAR2 DEFAULT NULL,
    x_attribute6 IN VARCHAR2 DEFAULT NULL,
    x_attribute7 IN VARCHAR2 DEFAULT NULL,
    x_attribute8 IN VARCHAR2 DEFAULT NULL,
    x_attribute9 IN VARCHAR2 DEFAULT NULL,
    x_attribute10 IN VARCHAR2 DEFAULT NULL,
    x_attribute11 IN VARCHAR2 DEFAULT NULL,
    x_attribute12 IN VARCHAR2 DEFAULT NULL,
    x_attribute13 IN VARCHAR2 DEFAULT NULL,
    x_attribute14 IN VARCHAR2 DEFAULT NULL,
    x_attribute15 IN VARCHAR2 DEFAULT NULL,
    x_attribute16 IN VARCHAR2 DEFAULT NULL,
    x_attribute17 IN VARCHAR2 DEFAULT NULL,
    x_attribute18 IN VARCHAR2 DEFAULT NULL,
    x_attribute19 IN VARCHAR2 DEFAULT NULL,
    x_attribute20 IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

END igs_pe_contact_dtls_pkg;

 

/
