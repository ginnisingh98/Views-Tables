--------------------------------------------------------
--  DDL for Package POS_SUPP_CLASSIFICATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_SUPP_CLASSIFICATION_PKG" AUTHID CURRENT_USER AS
/*$Header: POSSBCS.pls 120.4 2007/12/28 20:20:18 pbaldota ship $ */

BUSINESS_CLASSIFICATION CONSTANT HZ_CODE_ASSIGNMENTS.CLASS_CATEGORY%TYPE := 'POS_BUSINESS_CLASSIFICATIONS';
WOMEN_OWNED CONSTANT HZ_CODE_ASSIGNMENTS.CLASS_CODE%TYPE := 'WOMEN_OWNED';
MINORITY_OWNED CONSTANT HZ_CODE_ASSIGNMENTS.CLASS_CODE%TYPE := 'MINORITY_OWNED';
SMALL_BUSINESS CONSTANT HZ_CODE_ASSIGNMENTS.CLASS_CODE%TYPE := 'SMALL_BUSINESS';

PROCEDURE SYNCHRONIZE_CLASS_TCA_TO_PO
( pPartyId in Number,
  pVendorId in Number
);

PROCEDURE SYNCHRONIZE_CLASS_PO_TO_TCA
( pPartyId in Number,
  pVendorId in Number
);

PROCEDURE remove_classification( pClassificationId in number);

PROCEDURE add_bus_class_attr
(
p_party_id in number,
p_vendor_id in number,
p_lookup_code in varchar2,
p_exp_date    in date,
p_cert_num  in varchar2,
p_cert_agency in varchar2,
p_ext_attr_1 in varchar2,
p_class_status in varchar2,
p_request_id in number,
x_classification_id out nocopy number,
x_status    out nocopy varchar2,
x_exception_msg out nocopy varchar2
);



PROCEDURE update_bus_class_attr
(
p_party_id in number,
p_vendor_id in number,
p_selected in varchar2,
p_classification_id in number,
p_request_id in number,
p_lookup_code in varchar2,
p_exp_date    in date,
p_cert_num  in varchar2,
p_cert_agency in varchar2,
p_ext_attr_1 in varchar2,
p_class_status in varchar2,
x_classification_id out nocopy number,
x_request_id out nocopy number,
x_status    out nocopy varchar2,
x_exception_msg out nocopy varchar2
);


--Start for Bug 6620664 - Controlling concurrent updates to Business Classification screen

PROCEDURE validate_bus_class_concurrency
(     p_party_id        IN  NUMBER,
      p_class_id_tbl        IN  po_tbl_number,
      p_req_id_tbl        IN  po_tbl_number,
      p_last_upd_date_tbl        IN  po_tbl_date,
      p_lkp_type_tbl        IN  po_tbl_varchar30,
      p_lkp_code_tbl        IN  po_tbl_varchar30,
      x_return_status     OUT nocopy VARCHAR2,
      x_error_msg          OUT nocopy VARCHAR2
);

--End for Bug 6620664 - Controlling concurrent updates to Business Classification screen


END POS_SUPP_CLASSIFICATION_PKG;

/
