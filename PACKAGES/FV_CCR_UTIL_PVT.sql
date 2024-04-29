--------------------------------------------------------
--  DDL for Package FV_CCR_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_CCR_UTIL_PVT" AUTHID CURRENT_USER as
/* $Header: FVCCRCRS.pls 120.6.12010000.6 2010/03/26 21:25:15 snama ship $*/

FUNCTION existing_org_context RETURN VARCHAR2;

PROCEDURE get_bank_branch_information
(
p_routing_num			IN VARCHAR2,
p_bank_branch_id		IN NUMBER,
x_bank_name			OUT NOCOPY VARCHAR2,
x_bank_branch_name		OUT NOCOPY VARCHAR2,
x_bank_branch_id		OUT NOCOPY NUMBER
);

PROCEDURE get_bank_account_information
(
p_bank_branch_id 		IN NUMBER,
p_bank_account_number	IN VARCHAR2,
p_bank_account_id		IN NUMBER,
p_account_type		IN VARCHAR2,
p_base_currency		IN VARCHAR2,
p_country_code          IN VARCHAR2,
x_bank_account_id		OUT NOCOPY NUMBER,
x_update_account		OUT NOCOPY VARCHAR2
);

procedure get_federal_indicator
(
p_vendor_id		IN NUMBER,
p_taxpayer_number	IN VARCHAR2,
p_legal_bus_name	IN VARCHAR2,
x_federal		OUT NOCOPY VARCHAR2
);

PROCEDURE fv_process_vendor
(
p_ccr_id	   	IN	NUMBER				,
p_prev_ccr_id		IN	VARCHAR2 	,
p_update_type	    IN 	VARCHAR2 ,
x_return_status		OUT	NOCOPY VARCHAR2		  	,
x_msg_count		OUT	NOCOPY NUMBER				,
x_msg_data		OUT	NOCOPY VARCHAR2			,
p_bank_branch_id	IN 	NUMBER		,
p_vendor_id		IN NUMBER,
p_pay_site_id		IN NUMBER,
p_main_add_site_id	IN NUMBER,
p_enabled_flag		IN VARCHAR2,
p_main_address_flag	IN VARCHAR2,
p_taxpayer_number	IN VARCHAR2,
p_legal_bus_name	IN VARCHAR2,
p_duns			IN VARCHAR2,
p_plus4			IN VARCHAR2,
p_main_address_line1	IN VARCHAR2,
p_main_address_line2	IN VARCHAR2,
p_main_address_city		IN VARCHAR2,
p_main_address_state	IN VARCHAR2,
p_main_address_zip		IN VARCHAR2,
p_main_address_country	IN VARCHAR2,
p_pay_address_line1		IN VARCHAR2,
p_pay_address_line2		IN VARCHAR2,
p_pay_address_line3		IN VARCHAR2,
p_pay_address_city		IN VARCHAR2,
p_pay_address_state		IN VARCHAR2,
p_pay_address_zip		IN VARCHAR2,
p_pay_address_country	IN VARCHAR2,
p_old_bank_account_id	IN NUMBER,
p_new_bank_account_id	IN NUMBER,
p_bank_name			IN VARCHAR2,
p_bank_branch_name		IN VARCHAR2,
p_bank_num			IN VARCHAR2,
p_bank_account_num		IN VARCHAR2,
p_org_id			IN NUMBER,
p_update_vendor_flag	IN VARCHAR2,
p_org_name 			IN varchar2,
p_ccr_status			IN varchar2,
p_insert_vendor_flag	IN VARCHAR2,
p_prev_vendor_id		IN NUMBER,
p_file_date			IN DATE,
p_bank_conc_req_status	IN VARCHAR2,
p_header_conc_req_status IN VARCHAR2,
p_assgn_conc_req_status	IN VARCHAR2,
p_base_currency			IN VARCHAR2,
p_valid_bank_info		IN VARCHAR2,
p_federal_vendor		IN VARCHAR2,
p_created_bank_branch_id IN NUMBER,
p_created_bank_account_id IN NUMBER,
x_vendor_id			OUT NOCOPY NUMBER,
x_output			OUT NOCOPY VARCHAR2,
x_react_pay_site_code	OUT NOCOPY VARCHAR2,
x_react_main_site_code	OUT NOCOPY VARCHAR2,
x_tp_changed			OUT NOCOPY VARCHAR2,
x_vendor_name			OUT NOCOPY VARCHAR2,
p_org_type_lookup       IN VARCHAR2,
p_remit_poc        IN VARCHAR2,
p_mail_poc IN VARCHAR2,
p_ar_us_phone IN VARCHAR2,
p_ar_fax IN VARCHAR2,
p_ar_email IN VARCHAR2,
p_ar_non_us_phone IN VARCHAR2
);

FUNCTION get_profile_option(
p_name VARCHAR2
) RETURN VARCHAR2;

PROCEDURE delete_plusfour_assignments(
p_ccrid NUMBER
);

FUNCTION get_org_paysite_id(
p_ccrid NUMBER,
p_org_id NUMBER
) RETURN NUMBER;

FUNCTION get_org_mainaddrsite_id(
p_ccrid NUMBER,
p_org_id NUMBER
) RETURN NUMBER;

FUNCTION get_lookup_desc (p_lookup_type  IN VARCHAR2,
                          p_lookup_code  IN VARCHAR2
) RETURN VARCHAR2;


FUNCTION check_non_user_org_asgnmt(p_ccr_id IN NUMBER
) RETURN VARCHAR2;

FUNCTION check_suppl_tobe_merged (p_vendor_id  IN NUMBER
) RETURN VARCHAR2;

PROCEDURE insert_vendor
(
p_vendor_name     IN varchar2,
p_taxpayer_id     IN varchar2,
p_supplier_number IN varchar2,
p_org_type_lookup_code IN VARCHAR2,
x_vendor_id       OUT NOCOPY NUMBER,
x_status          OUT NOCOPY VARCHAR2,
x_exception_msg   OUT NOCOPY VARCHAR2
);

PROCEDURE update_vendor
(
p_vendor_id     IN NUMBER,
p_taxpayer_id   IN VARCHAR2,
x_status        OUT NOCOPY VARCHAR2,
x_exception_msg OUT NOCOPY VARCHAR2
);

PROCEDURE insert_vendor_site
(
p_vendor_site_code IN VARCHAR2,
p_vendor_id        IN NUMBER,
p_org_id           IN NUMBER,
p_address_line1    IN VARCHAR2,
p_address_line2    IN VARCHAR2,
p_address_line3    IN VARCHAR2,
p_address_line4    IN VARCHAR2,
p_city             IN VARCHAR2,
p_state		 IN VARCHAR2,
p_zip		   IN VARCHAR2,
p_province	   IN VARCHAR2,
p_country	   IN VARCHAR2,
p_duns_number	   IN VARCHAR2,
p_pay_site_flag    IN VARCHAR2,
p_hold_unvalidated_inv_flag IN VARCHAR2,
p_hold_all_payments_flag    IN VARCHAR2,
p_us_phone                  IN VARCHAR2,
p_fax                       IN VARCHAR2,
p_email                     IN VARCHAR2,
p_non_us_phone              IN VARCHAR2,
p_purchasing_site_flag      IN VARCHAR2,
x_vendor_site_id            OUT NOCOPY NUMBER,
x_party_site_id             OUT NOCOPY NUMBER,
x_status                    OUT NOCOPY VARCHAR2,
x_exception_msg             OUT NOCOPY VARCHAR2
);

PROCEDURE update_vendor_site
	(
	p_vendor_site_code IN VARCHAR2,
	p_vendor_site_id   IN NUMBER,
	p_org_id           IN NUMBER,
	p_address_line1    IN VARCHAR2,
	p_address_line2    IN VARCHAR2,
	p_address_line3    IN VARCHAR2,
	p_address_line4    IN VARCHAR2,
	p_city             IN VARCHAR2,
	p_state		   IN VARCHAR2,
	p_zip		   IN VARCHAR2,
	p_province	   IN VARCHAR2,
	p_country	   IN VARCHAR2,
	p_duns_number	   IN VARCHAR2,
	p_pay_site_flag    IN VARCHAR2,
	p_hold_unvalidated_inv_flag IN VARCHAR2,
	p_hold_all_payments_flag    IN VARCHAR2,
  p_us_phone                  IN VARCHAR2,
  p_fax                       IN VARCHAR2,
  p_email                     IN VARCHAR2,
  p_non_us_phone              IN VARCHAR2,
  p_purchasing_site_flag      IN VARCHAR2,
  x_party_site_id             OUT NOCOPY NUMBER,
	x_status                    OUT NOCOPY VARCHAR2,
	x_exception_msg             OUT NOCOPY VARCHAR2
	);

PROCEDURE create_bank_account
	(
	p_created_bank_id IN NUMBER,
	p_created_bank_branch_id IN NUMBER,
	p_bank_name  IN VARCHAR2,
	p_branch_name IN VARCHAR2,
	p_bank_num IN VARCHAR2,
	p_eft_user_num IN VARCHAR2,
	p_inst_type IN VARCHAR2,
	p_bank_branch_type IN VARCHAR2,
	p_bank_acct_name  IN VARCHAR2,
	p_bank_acct_num IN VARCHAR2,
	p_currency_code IN VARCHAR2,
	p_bank_account_type IN VARCHAR2,
	p_country_code IN VARCHAR2,
	p_duns_number IN VARCHAR2,
	x_bank_id      OUT NOCOPY NUMBER,
	x_bank_branch_id OUT NOCOPY NUMBER,
	x_bank_account_id OUT NOCOPY NUMBER,
	x_return_status OUT NOCOPY VARCHAR2
	);

PROCEDURE update_bank_account
(
 p_bank_account_id NUMBER,
 p_bank_account_type VARCHAR2,
 x_return_status OUT NOCOPY VARCHAR2
);

PROCEDURE process_bank_account_uses
(
	p_account_uses_upd_flag IN VARCHAR2,
	p_vendor_id IN NUMBER,
	p_federal_vendor IN VARCHAR2,
	p_valid_bank_info IN VARCHAR2,
	p_old_bank_account_id IN NUMBER,
	p_pay_site_id IN NUMBER,
	p_file_date IN DATE,
	p_new_bank_account_id IN NUMBER,
	p_account_uses_insert_flag IN VARCHAR2,
	p_org_id IN NUMBER
);

FUNCTION check_taxpayerid_diff(p_vendor_id IN number, p_duns varchar2
) RETURN VARCHAR2;

FUNCTION get_ext_cert_val(p_duns varchar2, p_code varchar2) return varchar2;

function get_ccr_flag_code(p_duns varchar2) return varchar2;

function get_ccr_numerics(p_duns varchar2, p_code varchar2) return number;

FUNCTION get_disaster_code(p_duns varchar2, p_code varchar2) return varchar2;

function get_supplier_debarred ( p_supplier_id in number,
                                 p_supplier_site_id in number,
                                 p_reference_date in date default sysdate,
                                 x_return_status out nocopy varchar2,
                                 x_msg_data varchar2) return boolean;

END;

/
