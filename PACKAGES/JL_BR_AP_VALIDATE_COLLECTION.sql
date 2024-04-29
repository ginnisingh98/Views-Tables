--------------------------------------------------------
--  DDL for Package JL_BR_AP_VALIDATE_COLLECTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_BR_AP_VALIDATE_COLLECTION" AUTHID CURRENT_USER as
/* $Header: jlbrpvcs.pls 120.2.12010000.2 2009/11/19 16:06:30 gmeni ship $ */

PROCEDURE jl_br_ap_validate_coll_doc (
   e_cnab_currency_code			IN	VARCHAR2,
   e_arrears_code 			     IN	VARCHAR2,
   e_accounting_balancing_segment	IN	VARCHAR2,
   e_set_of_books_id			IN	NUMBER,
   e_drawee_name			    IN	VARCHAR2,
   e_drawee_inscription_type  		IN	NUMBER,
   e_drawee_inscription_number		IN	VARCHAR2,
   e_drawee_bank_code			  IN	VARCHAR2,
   e_drawee_branch_code			IN	VARCHAR2,
   e_drawee_account			 IN	VARCHAR2,
   e_transferor_name			IN	VARCHAR2,
   e_transf_inscription_type  		IN	NUMBER,
   e_transf_inscription_number		IN	VARCHAR2,
   e_transferor_bank_code		 IN	VARCHAR2,
   e_transferor_branch_code	IN	VARCHAR2,
   e_arrears_date   			     IN      DATE,
   e_arrears_interest   		  IN      NUMBER,
   e_barcode                IN	VARCHAR2,
   e_electronic_format_flag IN	VARCHAR2,
   s_currency_code			      OUT NOCOPY	VARCHAR2,
   s_vendor_site_id			     OUT NOCOPY	NUMBER,
   s_error_code				     IN OUT NOCOPY	VARCHAR2);

END JL_BR_AP_VALIDATE_COLLECTION;

/
