--------------------------------------------------------
--  DDL for Package POS_PROFILE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_PROFILE_PKG" AUTHID CURRENT_USER as
/*$Header: POSPRUTS.pls 120.5 2006/07/06 19:08:10 gdwivedi noship $ */

/* This procedure does buyer user boot strapping request.
 *
 */
PROCEDURE buyer_boot_strap (
  p_user_id	      IN NUMBER
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);

/* This procedure gets the vendor information from the notification id.
 *
 */
PROCEDURE get_vendor_data (
  p_ntf_id IN NUMBER
, x_vendor_id out nocopy NUMBER
, x_party_id out nocopy NUMBER
, x_vendor_name out nocopy VARCHAR2
, x_vendor_number out nocopy VARCHAR2
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);

PROCEDURE buyer_update_address_details
(
    p_party_site_id         IN NUMBER,
    p_rfqFlag          IN VARCHAR2,
    p_purFlag          IN VARCHAR2,
    p_payFlag          IN VARCHAR2,
    p_primaryPayFlag   IN VARCHAR2,
    p_note             IN VARCHAR2,
    p_phone_area_code  IN VARCHAR2 DEFAULT NULL,
    p_phone            IN VARCHAR2 DEFAULT NULL,
    p_phone_contact_id IN NUMBER default null,
    p_phone_obj_ver_num IN NUMBER default null,
    p_fax_area_code  IN VARCHAR2 DEFAULT NULL,
    p_fax            IN VARCHAR2 DEFAULT NULL,
    p_fax_contact_id IN NUMBER default null,
    p_fax_obj_ver_num IN NUMBER default null,
    p_email            IN VARCHAR2 DEFAULT NULL,
    p_email_contact_id IN NUMBER default null,
    p_email_obj_ver_num IN NUMBER default null,
    x_status           out nocopy VARCHAR2,
    x_exception_msg    out nocopy VARCHAR2
);

PROCEDURE remove_address (
  p_party_site_id          IN NUMBER
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);

END POS_PROFILE_PKG;

 

/
