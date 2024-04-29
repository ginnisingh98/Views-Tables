--------------------------------------------------------
--  DDL for Package OKE_KCOPY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_KCOPY_PKG" AUTHID CURRENT_USER AS
/*$Header: OKEKCPYS.pls 120.2.12000000.1 2007/01/17 06:50:09 appldev ship $ */


  -- GLOBAL VARIABLES

  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKE_KCOPY_PKG';
  G_APP_NAME             CONSTANT VARCHAR2(200) := OKE_API.G_APP_NAME;
  g_proj_copy_allowed             VARCHAR2(1) := 'Y';

   SUBTYPE cimv_rec_type IS 		OKC_CONTRACT_ITEM_PUB.cimv_rec_type;

/* copies contracts and details.

	p_copy_lines  		'Y' if lines are to be copied
	p_copy_parties		'Y' if party roles are to be copied
	p_copy_tncs		'Y' if terms and conditions to be copied
	p_copy_articles		'Y' if articles to be copied
	p_copy_standard_notes 	'Y' if standard_notes to be copied
	p_copy_admin_yn		'Y' if admin info to be copied
				'N' if otherwise for all above
	p_dest_doc_type		the new contract type
	p_dest_doc_number	new contract number
	p_dest_buy_or_sell	new buy or sell contract?
	p_dest_currency_code	new currency_code for contract
	p_dest_start_date	new start date
	p_dest_end_date		new end date
	p_dest_template_yn	new contract is template?
	p_dest_authoring_org_id	new authoring org_id,
	p_dest_inv_organization_id	new item master org_id,
	p_dest_boa_id		k_header_id of boa related to delivery order,

	p_source_k_header_id	source k_header_id
	p_copy_user_attributes  'Y' if user attributes are to be copied
	x_dest_k_header_id	new id for new contract returned
*/


  PROCEDURE copy_contract(
    		p_api_version 		IN NUMBER,
    		p_init_msg_list 	IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    		x_return_status         OUT NOCOPY VARCHAR2,
    		x_msg_count            	OUT NOCOPY NUMBER,
    		x_msg_data             	OUT NOCOPY VARCHAR2,

		p_copy_lines		IN VARCHAR2,
		p_copy_parties		IN VARCHAR2,
		p_copy_tncs		IN VARCHAR2,
		p_copy_articles		IN VARCHAR2,
		p_copy_standard_notes	IN VARCHAR2,
		p_copy_user_attributes                  IN VARCHAR2,
		p_copy_admin_yn		IN VARCHAR2 DEFAULT 'Y',
                p_copy_projecttask_yn	IN VARCHAR2 DEFAULT 'N',
		p_dest_doc_type 			IN VARCHAR2,
  		p_dest_doc_number 			IN VARCHAR2,
		p_dest_buy_or_sell			IN VARCHAR2,
		p_dest_currency_code			IN VARCHAR2,
		p_dest_start_date			IN DATE,
		p_dest_end_date				IN DATE,
		p_dest_template_yn			IN VARCHAR2,
		p_dest_authoring_org_id			IN NUMBER,
		p_dest_inv_organization_id		IN NUMBER,
		p_dest_boa_id				IN NUMBER,
		p_source_k_header_id			IN NUMBER,
		x_dest_k_header_id 			OUT NOCOPY NUMBER
		);

END OKE_KCOPY_PKG;


 

/
