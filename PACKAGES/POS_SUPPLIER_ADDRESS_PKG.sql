--------------------------------------------------------
--  DDL for Package POS_SUPPLIER_ADDRESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_SUPPLIER_ADDRESS_PKG" AUTHID CURRENT_USER AS
/* $Header: POSSAS.pls 120.4.12010000.3 2009/11/06 12:46:57 suyjoshi ship $ */

PROCEDURE create_supplier_address
  (p_vendor_id        IN  NUMBER,
   p_vendor_party_id  IN  NUMBER,
   p_party_site_name  IN  VARCHAR2,
   p_address_line1    IN  VARCHAR2,
   p_address_line2    IN  VARCHAR2,
   p_address_line3    IN  VARCHAR2,
   p_address_line4    IN  VARCHAR2,
   p_country          IN  VARCHAR2,
   p_city             IN  VARCHAR2,
   p_state            IN  VARCHAR2,
   p_province         IN  VARCHAR2,
   p_postal_code      IN  VARCHAR2,
   p_county           IN  VARCHAR2,
   p_rfq_flag         IN  VARCHAR2,
   p_pur_flag         IN  VARCHAR2,
   p_pay_flag         IN  VARCHAR2,
   p_primary_pay_flag IN  VARCHAR2,
   p_phone_area_code  IN  VARCHAR2,
   p_phone_number     IN  VARCHAR2,
   p_phone_extension  IN  VARCHAR2,
   p_fax_area_code    IN  VARCHAR2,
   p_fax_number       IN  VARCHAR2,
   p_email_address    IN  VARCHAR2,
   x_return_status    OUT nocopy VARCHAR2,
   x_msg_count        OUT nocopy NUMBER,
   x_msg_data         OUT nocopy VARCHAR2,
   x_party_site_id    OUT nocopy NUMBER
   );

PROCEDURE update_supplier_address
  (p_vendor_id        IN  NUMBER,
   p_vendor_party_id  IN  NUMBER,
   p_party_site_id    IN  NUMBER,
   p_party_site_name  IN  VARCHAR2,
   p_address_line1    IN  VARCHAR2,
   p_address_line2    IN  VARCHAR2,
   p_address_line3    IN  VARCHAR2,
   p_address_line4    IN  VARCHAR2,
   p_country          IN  VARCHAR2,
   p_city             IN  VARCHAR2,
   p_state            IN  VARCHAR2,
   p_province         IN  VARCHAR2,
   p_postal_code      IN  VARCHAR2,
   p_county           IN  VARCHAR2,
   p_rfq_flag         IN  VARCHAR2,
   p_pur_flag         IN  VARCHAR2,
   p_pay_flag         IN  VARCHAR2,
   p_primary_pay_flag IN  VARCHAR2,
   p_phone_area_code  IN  VARCHAR2,
   p_phone_number     IN  VARCHAR2,
   p_phone_extension  IN  VARCHAR2,
   p_fax_area_code    IN  VARCHAR2,
   p_fax_number       IN  VARCHAR2,
   p_email_address    IN  VARCHAR2,
   x_return_status    OUT nocopy VARCHAR2,
   x_msg_count        OUT nocopy NUMBER,
   x_msg_data         OUT nocopy VARCHAR2
   );

PROCEDURE unassign_address_to_contact
  (p_contact_party_id   IN  NUMBER,
   p_org_party_site_id  IN  NUMBER,
   p_vendor_id          IN  NUMBER,
   x_return_status      OUT nocopy VARCHAR2,
   x_msg_count          OUT nocopy NUMBER,
   x_msg_data           OUT nocopy VARCHAR2
   );

-- code added for bug 8237063
/* updating address details to ap_supplier_contacts
when only the contact related data is changed and the
address assignments are not added or deleted */
PROCEDURE update_address_to_contact
  (p_contact_party_id   IN  NUMBER,
   p_org_party_site_id  IN  NUMBER,
   p_vendor_id          IN  NUMBER,
   x_return_status      OUT nocopy VARCHAR2,
   x_msg_count          OUT nocopy NUMBER,
   x_msg_data           OUT nocopy VARCHAR2
   );
-- code added for bug 8237063

PROCEDURE assign_address_to_contact
  (p_contact_party_id   IN  NUMBER,
   p_org_party_site_id  IN  NUMBER,
   p_vendor_id          IN  NUMBER,
   x_attribute_category   IN VARCHAR2 default null,
   x_attribute1 IN VARCHAR2 default null,
   x_attribute2 IN VARCHAR2 default null,
   x_attribute3 IN VARCHAR2 default null,
   x_attribute4 IN VARCHAR2 default null,
   x_attribute5 IN VARCHAR2 default null,
   x_attribute6 IN VARCHAR2 default null,
   x_attribute7 IN VARCHAR2 default null,
   x_attribute8 IN VARCHAR2 default null,
   x_attribute9 IN VARCHAR2 default null,
   x_attribute10 IN VARCHAR2 default null,
   x_attribute11 IN VARCHAR2 default null,
   x_attribute12 IN VARCHAR2 default null,
   x_attribute13 IN VARCHAR2 default null,
   x_attribute14 IN VARCHAR2 default null,
   x_attribute15 IN VARCHAR2 default null,
   x_return_status      OUT nocopy VARCHAR2,
   x_msg_count          OUT nocopy NUMBER,
   x_msg_data           OUT nocopy VARCHAR2
   );

/* Bug 6599374 Start */

PROCEDURE update_address_assignment_dff
  (x_contact_party_id   IN  NUMBER,
   x_org_party_site_id  IN  NUMBER,
   x_vendor_id          IN  NUMBER,
   x_attribute_category   IN VARCHAR2 default null,
   x_attribute1 IN VARCHAR2 default null,
   x_attribute2 IN VARCHAR2 default null,
   x_attribute3 IN VARCHAR2 default null,
   x_attribute4 IN VARCHAR2 default null,
   x_attribute5 IN VARCHAR2 default null,
   x_attribute6 IN VARCHAR2 default null,
   x_attribute7 IN VARCHAR2 default null,
   x_attribute8 IN VARCHAR2 default null,
   x_attribute9 IN VARCHAR2 default null,
   x_attribute10 IN VARCHAR2 default null,
   x_attribute11 IN VARCHAR2 default null,
   x_attribute12 IN VARCHAR2 default null,
   x_attribute13 IN VARCHAR2 default null,
   x_attribute14 IN VARCHAR2 default null,
   x_attribute15 IN VARCHAR2 default null,
   x_return_status OUT nocopy VARCHAR2,
   x_msg_count          OUT nocopy NUMBER,
   x_msg_data           OUT nocopy VARCHAR2
   );

/* Bug 6599374 End   */
-- This procedure is used by the new supplier UI in r12
-- to update details such as site use flags, phone,
-- fax, email, notes for a supplier address
PROCEDURE buyer_update_address_details
(p_party_site_id     IN  NUMBER,
 p_rfqFlag           IN  VARCHAR2,
 p_purFlag           IN  VARCHAR2,
 p_payFlag           IN  VARCHAR2,
 p_primaryPayFlag    IN  VARCHAR2,
 p_note              IN  VARCHAR2,
 p_phone_area_code   IN  VARCHAR2 DEFAULT NULL,
 p_phone             IN  VARCHAR2 DEFAULT NULL,
 p_phone_contact_id  IN  NUMBER DEFAULT NULL,
 p_phone_obj_ver_num IN  NUMBER DEFAULT NULL,
 p_fax_area_code     IN  VARCHAR2 DEFAULT NULL,
 p_fax               IN  VARCHAR2 DEFAULT NULL,
 p_fax_contact_id    IN  NUMBER DEFAULT NULL,
 p_fax_obj_ver_num   IN  NUMBER DEFAULT NULL,
 p_email             IN  VARCHAR2 DEFAULT NULL,
 p_email_contact_id  IN  NUMBER DEFAULT NULL,
 p_email_obj_ver_num IN  NUMBER DEFAULT NULL,
 x_return_status     OUT NOCOPY VARCHAR2,
 x_msg_count         OUT NOCOPY NUMBER,
 x_msg_data          OUT NOCOPY VARCHAR2
 );

END pos_supplier_address_pkg;

/
