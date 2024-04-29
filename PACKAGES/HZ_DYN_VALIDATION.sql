--------------------------------------------------------
--  DDL for Package HZ_DYN_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_DYN_VALIDATION" AUTHID CURRENT_USER AS
/*$Header: ARHDVSS.pls 115.2 2002/05/21 16:19:23 pkm ship        $ */
  invalid_profile_option       EXCEPTION;
  invalid_validation_procedure EXCEPTION;
  null_profile_value           EXCEPTION;
  execution_error              EXCEPTION;

  PROCEDURE validate_organization (
    x_organization       IN hz_party_v2pub.organization_rec_type,
    x_validation_profile IN VARCHAR2,
    x_temp_id            IN NUMBER DEFAULT NULL
  );

  PROCEDURE validate_group (
    x_group              IN hz_party_v2pub.group_rec_type,
    x_validation_profile IN VARCHAR2,
    x_temp_id            IN NUMBER DEFAULT NULL
  );

  PROCEDURE validate_relationship (
    x_relationship       IN hz_relationship_v2pub.relationship_rec_type,
    x_validation_profile IN VARCHAR2,
    x_temp_id            IN NUMBER DEFAULT NULL
  );

  PROCEDURE validate_org_contact (
    x_org_contact        IN hz_party_contact_v2pub.org_contact_rec_type,
    x_validation_profile IN VARCHAR2,
    x_temp_id            IN NUMBER DEFAULT NULL
  );

  PROCEDURE validate_party_site (
    x_party_site         IN hz_party_site_v2pub.party_site_rec_type,
    x_validation_profile IN VARCHAR2,
    x_temp_id            IN NUMBER DEFAULT NULL
  );

  PROCEDURE validate_location (
    x_location           IN hz_location_v2pub.location_rec_type,
    x_validation_profile IN VARCHAR2,
    x_temp_id            IN NUMBER DEFAULT NULL
  );

  PROCEDURE validate_contact_point (
    x_contact_point      IN hz_contact_point_v2pub.contact_point_rec_type,
    x_edi_contact        IN hz_contact_point_v2pub.edi_rec_type,
    x_eft_contact        IN hz_contact_point_v2pub.eft_rec_type,
    x_email_contact      IN hz_contact_point_v2pub.email_rec_type,
    x_phone_contact      IN hz_contact_point_v2pub.phone_rec_type,
    x_telex_contact      IN hz_contact_point_v2pub.telex_rec_type,
    x_web_contact        IN hz_contact_point_v2pub.web_rec_type,
    x_validation_profile IN VARCHAR2,
    x_temp_id            IN NUMBER DEFAULT NULL
  );

END hz_dyn_validation;

 

/
