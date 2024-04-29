--------------------------------------------------------
--  DDL for Package POS_SUPP_CONTACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_SUPP_CONTACT_PKG" AUTHID CURRENT_USER AS
/*$Header: POSCONTS.pls 120.5.12010000.4 2011/05/11 13:07:36 ramkandu ship $ */
/* As Part Of Bug 7938942 Added A New Parameter p_person_party_obversion_num */
PROCEDURE create_supplier_contact
  (p_vendor_party_id  IN  NUMBER,
   p_first_name       IN  VARCHAR2,
   p_last_name        IN  VARCHAR2,
   p_middle_name      IN  VARCHAR2 DEFAULT NULL,
   p_contact_title    IN  VARCHAR2 DEFAULT NULL,
   p_job_title        IN  VARCHAR2 DEFAULT NULL,
   p_phone_area_code  IN  VARCHAR2 DEFAULT NULL,
   p_phone_number     IN  VARCHAR2 DEFAULT NULL,
   p_phone_extension  IN  VARCHAR2 DEFAULT NULL,
   p_fax_area_code    IN  VARCHAR2 DEFAULT NULL,
   p_fax_number       IN  VARCHAR2 DEFAULT NULL,
   p_email_address    IN  VARCHAR2 DEFAULT NULL,
   p_inactive_date    IN  DATE DEFAULT NULL,
   x_return_status    OUT nocopy VARCHAR2,
   x_msg_count        OUT nocopy NUMBER,
   x_msg_data         OUT nocopy VARCHAR2,
   x_person_party_id  OUT nocopy NUMBER,
   p_department IN  VARCHAR2 DEFAULT NULL,
   p_alt_contact_name IN VARCHAR2 DEFAULT NULL,
   p_alt_area_code IN VARCHAR2 DEFAULT NULL,
   p_alt_phone_number IN VARCHAR2 DEFAULT NULL,
   p_url IN VARCHAR2 DEFAULT NULL
   );

/* As Part Of Bug 7027825 Added A New Parameter p_person_party_obversion_num */
/* As Part Of Bug 7938942 Added A New Parameter p_person_party_obversion_num */
PROCEDURE update_supplier_contact
  (p_contact_party_id IN  NUMBER,
   p_vendor_party_id  IN  NUMBER,
   p_first_name       IN  VARCHAR2 DEFAULT NULL,
   p_last_name        IN  VARCHAR2 DEFAULT NULL,
   p_middle_name      IN  VARCHAR2 DEFAULT NULL,
   p_contact_title    IN  VARCHAR2 DEFAULT NULL,
   p_job_title        IN  VARCHAR2 DEFAULT NULL,
   p_phone_area_code  IN  VARCHAR2 DEFAULT NULL,
   p_phone_number     IN  VARCHAR2 DEFAULT NULL,
   p_phone_extension  IN  VARCHAR2 DEFAULT NULL,
   p_fax_area_code    IN  VARCHAR2 DEFAULT NULL,
   p_fax_number       IN  VARCHAR2 DEFAULT NULL,
   p_email_address    IN  VARCHAR2 DEFAULT NULL,
   p_inactive_date    IN  DATE DEFAULT NULL,
--Start Bug 6620664 - Handling Concurrent Updates on ContactDirectory, BusinessClassifications ans Accounting pages
   p_party_object_version_number  IN NUMBER DEFAULT fnd_api.G_NULL_NUM,
   p_email_object_version_number  IN NUMBER DEFAULT fnd_api.G_NULL_NUM,
   p_phone_object_version_number  IN NUMBER DEFAULT fnd_api.G_NULL_NUM,
   p_fax_object_version_number    IN NUMBER DEFAULT fnd_api.G_NULL_NUM,
   p_rel_object_version_number    IN NUMBER DEFAULT fnd_api.G_NULL_NUM,
   p_cont_object_version_number   IN NUMBER DEFAULT fnd_api.G_NULL_NUM,
--End Bug 6620664 - Handling Concurrent Updates on ContactDirectory, BusinessClassifications ans Accounting pages
   p_person_party_obversion_num IN NUMBER DEFAULT fnd_api.G_NULL_NUM,
   x_return_status    OUT nocopy VARCHAR2,
   x_msg_count        OUT nocopy NUMBER,
   x_msg_data         OUT nocopy VARCHAR2,
   p_department IN  VARCHAR2 DEFAULT NULL,
   p_alt_contact_name IN VARCHAR2 DEFAULT NULL,
   p_alt_area_code IN VARCHAR2 DEFAULT NULL,
   p_alt_phone_number IN VARCHAR2 DEFAULT NULL,
   p_url IN VARCHAR2 DEFAULT NULL,
   p_url_object_version_number  IN NUMBER DEFAULT fnd_api.G_NULL_NUM,
   p_altphone_obj_version_num  IN NUMBER DEFAULT fnd_api.G_NULL_NUM
   );

END POS_SUPP_CONTACT_PKG ;

/
