--------------------------------------------------------
--  DDL for Package POS_PROFILE_CHANGE_REQUEST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_PROFILE_CHANGE_REQUEST_PKG" AUTHID CURRENT_USER AS
/* $Header: POSPCRS.pls 120.15.12010000.4 2011/05/16 15:23:01 ramkandu ship $ */

PROCEDURE approve_address_req
  (p_request_id    IN  NUMBER,
   x_return_status OUT nocopy VARCHAR2,
   x_msg_count     OUT nocopy NUMBER,
   x_msg_data      OUT nocopy VARCHAR2
   );

-- If the request is a new contact request with user account,
-- x_password will have the generated password; otherwise it is null
PROCEDURE approve_contact_req
  (p_request_id    IN  NUMBER,
   x_return_status OUT nocopy VARCHAR2,
   x_msg_count     OUT nocopy NUMBER,
   x_msg_data      OUT nocopy VARCHAR2,
   x_password      OUT nocopy VARCHAR2
   );

PROCEDURE approve_bus_class_req
  (p_request_id    IN  NUMBER,
   x_return_status OUT nocopy VARCHAR2,
   x_msg_count     OUT nocopy NUMBER,
   x_msg_data      OUT nocopy VARCHAR2
   );

PROCEDURE approve_ps_req
  (p_request_id    IN  NUMBER,
   x_return_status OUT nocopy VARCHAR2,
   x_msg_count     OUT nocopy NUMBER,
   x_msg_data      OUT nocopy VARCHAR2
   );

PROCEDURE reject_address_req
  (p_request_id    IN  NUMBER,
   x_return_status OUT nocopy VARCHAR2,
   x_msg_count     OUT nocopy NUMBER,
   x_msg_data      OUT nocopy VARCHAR2
   );

PROCEDURE reject_contact_req
  (p_request_id    IN  NUMBER,
   x_return_status OUT nocopy VARCHAR2,
   x_msg_count     OUT nocopy NUMBER,
   x_msg_data      OUT nocopy VARCHAR2
   );

PROCEDURE reject_bus_class_req
  (p_request_id    IN  NUMBER,
   x_return_status OUT nocopy VARCHAR2,
   x_msg_count     OUT nocopy NUMBER,
   x_msg_data      OUT nocopy VARCHAR2
   );

PROCEDURE reject_ps_req
  (p_request_id    IN  NUMBER,
   x_return_status OUT nocopy VARCHAR2,
   x_msg_count     OUT nocopy NUMBER,
   x_msg_data      OUT nocopy VARCHAR2
   );

PROCEDURE reject_mult_address_reqs
(
  p_req_id_tbl        IN  po_tbl_number,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2
);

PROCEDURE reject_mult_contact_reqs
(
  p_req_id_tbl        IN  po_tbl_number,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2
);

PROCEDURE reject_mult_bus_class_reqs
(
  p_req_id_tbl        IN po_tbl_number,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count          OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2
);

PROCEDURE reject_mult_ps_reqs
(
  p_req_id_tbl        IN  po_tbl_number,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2
);

PROCEDURE approve_mult_address_reqs
(
  p_req_id_tbl        IN  po_tbl_number,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2
);

PROCEDURE approve_mult_contact_reqs
(
  p_req_id_tbl        IN  po_tbl_number,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2
);

PROCEDURE approve_mult_bus_class_reqs
(
  p_req_id_tbl        IN  po_tbl_number,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2
);

PROCEDURE approve_mult_ps_reqs
(
  p_req_id_tbl        IN  po_tbl_number,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2
);



PROCEDURE approve_update_mult_bc_reqs
(
  p_pos_bus_rec_tbl   IN  pos_bus_rec_tbl,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2
);


PROCEDURE chg_address_req_approval
  (p_request_id    	IN NUMBER,
   p_party_site_name 	IN VARCHAR2,
   p_country 		IN VARCHAR2,
   p_address_line1	IN VARCHAR2,
   p_address_line2	IN VARCHAR2,
   p_address_line3	IN VARCHAR2,
   p_address_line4	IN VARCHAR2,
   p_city		IN VARCHAR2,
   p_county		IN VARCHAR2,
   p_state		IN VARCHAR2,
   p_province		IN VARCHAR2,
   p_postal_code	IN VARCHAR2,
   p_phone_area_code 	IN VARCHAR2,
   p_phone_number 	IN VARCHAR2,
   p_fax_area_code 	IN VARCHAR2,
   p_fax_number 	IN VARCHAR2,
   p_email_address	IN VARCHAR2,
   p_rfq_flag  		IN VARCHAR2,
   p_pay_flag  		IN VARCHAR2,
   p_pur_flag  		IN VARCHAR2,
   p_status             IN VARCHAR2,
   x_return_status OUT nocopy VARCHAR2,
   x_msg_count     OUT nocopy NUMBER,
   x_msg_data      OUT nocopy VARCHAR2
   );


   FUNCTION format_address(
    p_address_line1		IN VARCHAR2 DEFAULT NULL,
    p_address_line2		IN VARCHAR2 DEFAULT NULL,
    p_address_line3		IN VARCHAR2 DEFAULT NULL,
    p_address_line4		IN VARCHAR2 DEFAULT NULL,
    p_addr_city			IN VARCHAR2 DEFAULT NULL,
    p_addr_postal_code		IN VARCHAR2 DEFAULT NULL,
    p_addr_state			IN VARCHAR2 DEFAULT NULL,
    p_addr_province		IN VARCHAR2 DEFAULT NULL,
    p_addr_county			IN VARCHAR2 DEFAULT NULL,
    p_addr_country			IN VARCHAR2 DEFAULT NULL
 ) RETURN VARCHAR2;


 PROCEDURE chg_contact_req_approval
 (  p_request_id    	IN NUMBER,
    p_CONTACT_TITLE  	IN VARCHAR2,
    p_FIRST_NAME	IN VARCHAR2,
    p_MIDDLE_NAME 	IN VARCHAR2,
    p_LAST_NAME		IN VARCHAR2,
    p_alt_contact_name  IN VARCHAR2,
    p_JOB_TITLE		IN VARCHAR2,
    p_department        IN VARCHAR2,
    p_email_address	IN VARCHAR2,
    p_url 		IN VARCHAR2,
    p_phone_area_code 	IN VARCHAR2,
    p_phone_number 	IN VARCHAR2,
    p_phone_extension  	IN VARCHAR2,
    p_alt_area_code     IN VARCHAR2,
    p_alt_phone_number  IN VARCHAR2,
    p_fax_area_code 	IN VARCHAR2,
    p_fax_number 	IN VARCHAR2,
    x_return_status OUT nocopy VARCHAR2,
    x_msg_count     OUT nocopy NUMBER,
    x_msg_data      OUT nocopy VARCHAR2
 );

PROCEDURE reject_mult_cont_addr_reqs
(     p_cont_req_id       IN  NUMBER,
      p_req_id_tbl        IN  po_tbl_number,
      x_return_status     OUT nocopy VARCHAR2,
      x_msg_count         OUT nocopy NUMBER,
      x_msg_data          OUT nocopy VARCHAR2
);

PROCEDURE new_contact_req_approval
(  p_request_id    	IN NUMBER,
   p_contact_title  	IN VARCHAR2,
   p_first_name		IN VARCHAR2,
   p_middle_name 	IN VARCHAR2,
   p_last_name		IN VARCHAR2,
   p_job_title		IN VARCHAR2,
   p_email_address	IN VARCHAR2,
   p_phone_area_code 	IN VARCHAR2,
   p_phone_number 	IN VARCHAR2,
   p_phone_extension  	IN VARCHAR2,
   p_fax_area_code 	IN VARCHAR2,
   p_fax_number 	IN VARCHAR2,
   p_create_user_acc 	IN VARCHAR2,
   p_user_name		IN VARCHAR2,
   x_user_id 	   OUT nocopy NUMBER,
   x_cont_party_id OUT nocopy NUMBER,
   x_return_status OUT nocopy VARCHAR2,
   x_msg_count     OUT nocopy NUMBER,
   x_msg_data      OUT nocopy VARCHAR2,
   p_inactive_date IN DATE DEFAULT NULL,
   p_department  IN VARCHAR2 DEFAULT NULL,
   p_alt_contact_name IN VARCHAR2 DEFAULT NULL,
   p_alt_area_code IN VARCHAR2 DEFAULT NULL,
   p_alt_phone_number IN VARCHAR2 DEFAULT NULL,
   p_url IN VARCHAR2 DEFAULT NULL
);

PROCEDURE assign_mult_address_to_contact
(    p_site_id_tbl        IN  po_tbl_number,
     p_cont_party_id 	 IN  NUMBER,
     p_vendor_id	 IN  NUMBER,
     x_return_status     OUT nocopy VARCHAR2,
     x_msg_count         OUT nocopy NUMBER,
     x_msg_data          OUT nocopy VARCHAR2
);

PROCEDURE assign_user_sec_attr
(    p_req_id_tbl        IN  po_tbl_number,
     p_usr_id 		 IN  NUMBER,
     p_code_name	 IN  VARCHAR2,
     x_return_status     OUT nocopy VARCHAR2,
     x_msg_count         OUT nocopy NUMBER,
     x_msg_data          OUT nocopy VARCHAR2
);

PROCEDURE approve_contact_req
(	p_request_id    IN  NUMBER,
 	p_user_name	IN  VARCHAR2,
   	x_return_status OUT nocopy VARCHAR2,
   	x_msg_count     OUT nocopy NUMBER,
   	x_msg_data      OUT nocopy VARCHAR2,
   	x_password      OUT nocopy VARCHAR2,
	p_inactive_date IN DATE DEFAULT NULL
);

PROCEDURE update_addr_req_status
(
	p_request_id    IN  NUMBER,
        p_party_site_id IN  NUMBER,
	p_req_status    IN  VARCHAR2,
	x_return_status OUT nocopy VARCHAR2,
	x_msg_count     OUT nocopy NUMBER,
	x_msg_data      OUT nocopy VARCHAR2
);

PROCEDURE get_ou_count
(
	x_ou_count      OUT nocopy NUMBER,
	x_return_status OUT nocopy VARCHAR2,
	x_msg_count     OUT nocopy NUMBER,
	x_msg_data      OUT nocopy VARCHAR2
);

PROCEDURE upd_address_to_contact_rel
(    p_mapping_id        IN  NUMBER,
     p_cont_party_id     IN  NUMBER,
     p_cont_req_id       IN  NUMBER,
     p_addr_req_id       IN  NUMBER,
     p_party_site_id     IN  NUMBER,
     p_request_type      IN  VARCHAR2,
     x_return_status     OUT nocopy VARCHAR2,
     x_msg_data          OUT nocopy VARCHAR2
);

FUNCTION get_cont_req_id(
    p_contact_party_id                    IN NUMBER
 ) RETURN NUMBER;

END pos_profile_change_request_pkg;

/
