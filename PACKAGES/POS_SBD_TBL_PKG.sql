--------------------------------------------------------
--  DDL for Package POS_SBD_TBL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_SBD_TBL_PKG" AUTHID CURRENT_USER as
/*$Header: POSSBDTS.pls 120.0 2005/08/21 08:48:07 gdwivedi noship $ */

/* This procedure create a row in POS_ACNT_GEN_REQ
 *
 */
PROCEDURE insert_row_pos_acnt_gen_req (
  p_mapping_id	   IN NUMBER
, p_temp_ext_bank_account_id IN NUMBER
, p_ext_bank_account_id IN NUMBER
, x_account_request_id out nocopy number
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);

/* This procedure create a row in POS_ACNT_ADDR_REQ
 *
 */
PROCEDURE insert_row_pos_acnt_addr_req (
  p_mapping_id	   in NUMBER
, p_request_type   in varchar2
, p_party_site_id  in number
, p_address_request_id in number
, x_assignment_request_id out nocopy number
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);

/* This procedure create a row in POS_ACNT_ADDR_SUMM_REQ
 *
 */
PROCEDURE insert_row_pos_acnt_summ_req (
  p_assignment_request_id in number
, p_ext_bank_account_id IN NUMBER
, p_account_request_id in number
, p_start_date in date
, p_end_date in date
, p_priority in number
, p_assignment_status in varchar2
, x_assignment_id out nocopy number
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);

/* This procedure removes a row in POS_ACNT_ADDR_SUMM_REQ
 *
 */

PROCEDURE del_row_pos_acnt_summ_req (
  p_assignment_id	   IN NUMBER
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);

/* This procedure removes a row in POS_ACNT_ADDR_REQ
 *
 */

PROCEDURE del_row_pos_acnt_addr_req (
  p_assignment_request_id	   IN NUMBER
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);

/* This procedure removes a row in POS_ACNT_GEN_REQ
 *
 */
PROCEDURE del_row_pos_acnt_gen_req (
  p_account_request_id	   IN NUMBER
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);

/* This procedure updates a row in POS_ACNT_ADDR_SUMM_REQ
 *
 */

PROCEDURE update_row_pos_acnt_summ_req (
  p_assignment_id	   IN NUMBER
, p_assignment_request_id  IN NUMBER
, p_ext_bank_account_id    IN NUMBER
, p_account_request_id     IN NUMBER
, p_start_date             IN DATE
, p_end_date               IN DATE
, p_priority               IN NUMBER
, p_assignment_status      IN VARCHAR2
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);


/* This procedure updates a row in POS_ACNT_ADDR_REQ
 *
 */

PROCEDURE update_row_pos_acnt_addr_req (
  p_assignment_request_id  IN NUMBER
, p_request_status in varchar2
, p_party_site_id  in number
, p_address_request_id in number
, p_object_version_number in number
, x_status        out nocopy VARCHAR2
, x_exception_msg out nocopy VARCHAR2
);

END POS_SBD_TBL_PKG;

 

/
