--------------------------------------------------------
--  DDL for Package JGRX_WT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JGRX_WT" AUTHID CURRENT_USER AS
/* $Header: jgrxwts.pls 120.6 2005/06/23 22:18:21 rguerrer ship $ */
/**************************************************************************
 *                          Public Procedures                             *
 **************************************************************************/
/**************************************************************************
 *                                                                        *
 * Name       : Get_Withholding_Tax                                       *
 * Purpose    : This is the core generic withholding tax routine, which   *
 *              populates the interface table JG_ZZ_AP_WHT_ITF.           *
 *		This has a call to the following:      			  *
 *              1. Before Report - where it constructs the basic SELECT   *
 *              2. Bind - binds the variables				  *
 *                                                                        *
 **************************************************************************/

  PROCEDURE GET_WITHHOLDING_TAX ( request_id	in number,
				  section_name	in varchar2,
				  retcode	out NOCOPY number,
				  errbuf	out NOCOPY varchar2);


/**************************************************************************
 *                                                                        *
 * Name       : jg_wht_extract   	                                  *
 * Purpose    : This plug-in is specific to suit Korean withholding tax   *
 *		needs. It has the following procedures 			  *
 *		1. Call to the BASIC procedure Get_Withholding_Tax        *
 *              2. Before Report - To add conditions specific to Korea    *
 *              3. Bind - binds the variables				  *
 *              4. After Fetch - does manipulation on fetched record      *
 *                                                                        *
 **************************************************************************/

 PROCEDURE jg_wht_extract (	p_gldate_from		in DATE,
				p_gldate_to		in DATE,
				p_supplier_from		in VARCHAR2,
				p_supplier_to		in VARCHAR2,
				p_supp_tax_reg_num 	in VARCHAR2,
				p_invoice_number	in VARCHAR2,
				p_reporting_level	in VARCHAR2,
				p_reporting_context 	in VARCHAR2,
                p_legal_entity_id       in NUMBER,
				p_acct_flexfield_from 	in VARCHAR2,
				p_acct_flexfield_to   	in VARCHAR2,
				p_org_type		in VARCHAR2,
				p_location		in NUMBER,
				p_res_inc_categ		in VARCHAR2,
				p_for_inc_categ		in VARCHAR2,
				request_id		in NUMBER,
				retcode			out NOCOPY NUMBER,
				errbuf			out NOCOPY VARCHAR2);

  ---------------------
  -- Public Procedures
  ---------------------
  PROCEDURE set_retcode(p_retcode in number);
  PROCEDURE append_errbuf(p_msg in varchar2);

 /**************************************************************************
 *                                                                         *
 * Name       : before_report	                                  	   *
 * Purpose    : This procedure constructs the basic SELECT and INSERT      *
 *		statement to populate the interface table JG_ZZ_AP_WHT_ITF *
 *									   *
  **************************************************************************/

  PROCEDURE before_report;

 /**************************************************************************
 *                                                                         *
 * Name       : wht_before_report	                                   *
 * Purpose    : This procedure has Korean specific WHERE clauses           *
 *		for populating the interface table JG_ZZ_AP_WHT_ITF        *
 *									   *
  **************************************************************************/

  PROCEDURE wht_before_report;

/**************************************************************************
 *                                                                         *
 * Name       : get_lookup_meaning	                                   *
 * Purpose    : This function returns the meaning for the matching         *
 *		lookup_type and lookup_code in po_lookup_codes,            *
 *		fnd_lookups using a memory structure.			   *
 **************************************************************************/

  FUNCTION get_lookup_meaning(  p_product in varchar2,
                         	p_lookup_type in varchar2,
                         	p_lookup_code in varchar2)
  RETURN varchar2;


/**************************************************************************
 *                                                                         *
 * Name       : wht_bind	                                  	   *
 * Purpose    : This procedure accepts an integer parameter :CURSOR_SELECT *
 *		and binds the parameter to variables			   *
 *									   *
  **************************************************************************/
  PROCEDURE wht_bind(c in integer);

/**************************************************************************
 *                                                                         *
 * Name       : wht_after_fetch                                  	   *
 * Purpose    : This procedure does any manipulation required on the       *
 *		fetched record before populating the interface table       *
 *		JG_ZZ_AP_WHT_ITF 					   *
 *									   *
  **************************************************************************/
  PROCEDURE wht_after_fetch;

 /**************************************************************************
 *  Structure to hold placeholder values				   *
  **************************************************************************/

  type var_t is record (
	CORPORATE_ID_NUMBER		VARCHAR2(150),
	LOCATION_NAME			VARCHAR2(60),
	LOCATION_ADDRESS1		VARCHAR2(240),
	LOCATION_ADDRESS2		VARCHAR2(240),
	LOCATION_ADDRESS3		VARCHAR2(240),
	LOCATION_COUNTRY		VARCHAR2(60),
	LOCATION_ZIPCODE		VARCHAR2(30),
	LOCATION_PHONE			VARCHAR2(30),
	LOCATION_FAX			VARCHAR2(60),
	LEGAL_ENTITY_NAME		VARCHAR2(60),
	LEGAL_ENTITY_CITY		VARCHAR2(30),
	LEGAL_ENTITY_ADDRESS1		VARCHAR2(240),
	LEGAL_ENTITY_ADDRESS2		VARCHAR2(240),
	LEGAL_ENTITY_ADDRESS3		VARCHAR2(240),
	LEGAL_ENTITY_COUNTRY		VARCHAR2(60),
	LEGAL_ENTITY_ZIPCODE		VARCHAR2(30),
	LEGAL_ENTITY_PHONE		VARCHAR2(30),
	TAX_REGISTRATION_NUM		VARCHAR2(150),
	LOC_TAXABLE_PERSON		VARCHAR2(150),
	SUPPLIER_ID			NUMBER,
	SUPPLIER_NAME			VARCHAR2(240),
	SUPPLIER_SITE_ID		NUMBER,
	SUPPLIER_SITE_NAME		VARCHAR2(15),
	PV_ATTRIBUTE1			VARCHAR2(150),
	PV_ATTRIBUTE2			VARCHAR2(150),
	PV_ATTRIBUTE3			VARCHAR2(150),
	PV_ATTRIBUTE4			VARCHAR2(150),
	PV_ATTRIBUTE5			VARCHAR2(150),
	PV_ATTRIBUTE6			VARCHAR2(150),
	PV_ATTRIBUTE7			VARCHAR2(150),
	PV_ATTRIBUTE8			VARCHAR2(150),
	PV_ATTRIBUTE9			VARCHAR2(150),
	PV_ATTRIBUTE10			VARCHAR2(150),
	PV_ATTRIBUTE11			VARCHAR2(150),
	PV_ATTRIBUTE12			VARCHAR2(150),
	PV_ATTRIBUTE13			VARCHAR2(150),
	PV_ATTRIBUTE14			VARCHAR2(150),
	PV_ATTRIBUTE15			VARCHAR2(150),
	PVS_ATTRIBUTE1			VARCHAR2(150),
	PVS_ATTRIBUTE2			VARCHAR2(150),
	PVS_ATTRIBUTE3			VARCHAR2(150),
	PVS_ATTRIBUTE4			VARCHAR2(150),
	PVS_ATTRIBUTE5			VARCHAR2(150),
	PVS_ATTRIBUTE6			VARCHAR2(150),
	PVS_ATTRIBUTE7			VARCHAR2(150),
	PVS_ATTRIBUTE8			VARCHAR2(150),
	PVS_ATTRIBUTE9			VARCHAR2(150),
	PVS_ATTRIBUTE10			VARCHAR2(150),
	PVS_ATTRIBUTE11			VARCHAR2(150),
	PVS_ATTRIBUTE12			VARCHAR2(150),
	PVS_ATTRIBUTE13			VARCHAR2(150),
	PVS_ATTRIBUTE14			VARCHAR2(150),
	PVS_ATTRIBUTE15			VARCHAR2(150),
	INV_ATTRIBUTE1			VARCHAR2(150),
	INV_ATTRIBUTE2			VARCHAR2(150),
	INV_ATTRIBUTE3			VARCHAR2(150),
	INV_ATTRIBUTE4			VARCHAR2(150),
	INV_ATTRIBUTE5			VARCHAR2(150),
	INV_ATTRIBUTE6			VARCHAR2(150),
	INV_ATTRIBUTE7			VARCHAR2(150),
	INV_ATTRIBUTE8			VARCHAR2(150),
	INV_ATTRIBUTE9			VARCHAR2(150),
	INV_ATTRIBUTE10			VARCHAR2(150),
	INV_ATTRIBUTE11			VARCHAR2(150),
	INV_ATTRIBUTE12			VARCHAR2(150),
	INV_ATTRIBUTE13			VARCHAR2(150),
	INV_ATTRIBUTE14			VARCHAR2(150),
	INV_ATTRIBUTE15			VARCHAR2(150),
	SUPPLIER_COUNTRY		VARCHAR2(25),
	SUPPLIER_ADDRESS_LINE1		VARCHAR2(240),
	SUPPLIER_ADDRESS_LINE2		VARCHAR2(240),
	SUPPLIER_ADDRESS_LINE3		VARCHAR2(240),
	SUPPLIER_CITY			VARCHAR2(25),
	SUPPLIER_POSTAL_CODE		VARCHAR2(20),
	SUPPLIER_PROVINCE		VARCHAR2(150),
	SUPPLIER_COUNTY			VARCHAR2(150),
        SUPP_CONCATENATED_ADDRESS       VARCHAR2(800),
	SUPPLIER_TAXABLE_PERSON		VARCHAR2(150),
	SUPPLIER_TAX_REGISTRATION_NUM	VARCHAR2(20),
	SUPPLIER_TAXPAYER_ID		VARCHAR2(30),
	BUSINESS_INC_SUB_CATEGORY	VARCHAR2(150),
	BIZ_INC_SUB_CATEG_MEANING	VARCHAR2(80),
	DIST_CODE_COMBINATION_ID	NUMBER(15),
	ACCOUNTING_FLEXFIELD		VARCHAR2(1000), /*Bug 3017170*/
	TRANSACTION_NUMBER		VARCHAR2(50),
	ACCOUNTING_DATE			DATE,
	DOCUMENT_NUMBER			VARCHAR2(50),
	ORGANIZATION_TYPE		VARCHAR2(25),
	ORG_TYPE_MEANING		VARCHAR2(80),
	TAX_ID				NUMBER(15),
	TAX_CODE			VARCHAR2(15),
	AWT_DESCRIPTION			VARCHAR2(240),
	TAX_TYPE			VARCHAR2(25),
	TAX_RATE_ID			NUMBER(15),
	TAX_RATE			NUMBER,
	RECOGNIZED_EXPENSE_PERCENT	VARCHAR2(150),
	NOMINAL_TAX_RATE		VARCHAR2(150),
	NOMINAL_OR_REG_TAX_RATE		NUMBER,
	TAX_LOCATION			VARCHAR2(150),
	WITHHOLDING_TAX_TYPE		VARCHAR2(150),
	WH_TAX_TYPE_MEANING		VARCHAR2(80),
	RESIDENT_INC_CATEG_CODE		VARCHAR2(150),
	RES_INC_CATEG_MEANING		VARCHAR2(80),
	FOREIGN_INC_CATEG_CODE		VARCHAR2(150),
	FOR_INC_CATEG_MEANING		VARCHAR2(80),
	TAX_AUTHORITY_NAME		VARCHAR2(240),
	STATUS				VARCHAR2(1),
	INCOME_TAX			NUMBER,
	RESIDENT_TAX			NUMBER,
	TOTAL_WHT_AMOUNT		NUMBER,
	PAYMENT_CURRENCY		VARCHAR2(15),
	INVOICE_PAYMENT_ID		NUMBER(15),
	PAYMENT_AMOUNT			NUMBER,
	PAYMENT_DATE			DATE,
	PAYMENT_NUMBER			NUMBER(15),
	CHECK_ID			NUMBER(15),
	CHECK_NUMBER			NUMBER(15),
	CHECK_AMOUNT			NUMBER,
	INVOICE_ID			NUMBER(15),
      INVOICE_LINE_NUMBER             NUMBER(15),
	INVOICE_DISTRIBUTION_ID		NUMBER(15),
	INVOICE_AMOUNT			NUMBER,
	INVOICE_DATE			DATE,
	CURRENCY_CODE			VARCHAR2(15),
	FUNC_CURRENCY_CODE		VARCHAR2(15),
	AMT_SUBJECT_TO_WH		NUMBER,
	RECOGNIZED_EXPENSE_AMT		NUMBER,
	INC_WH_TAX_BASE_AMT		NUMBER,
	RES_WH_TAX_BASE_AMT		NUMBER,
	TOTAL_TAX_BASE_AMT		NUMBER,
	NET_AMOUNT			NUMBER,
	LINE_NUMBER			NUMBER(15),
	TYPE_1099			VARCHAR2(10),
	ITEM_DESCRIPTION		VARCHAR2(240),
	ORGANIZATION_NAME		VARCHAR2(60),
	REPORTING_ENTITY_NAME		VARCHAR2(50),
	REPORTING_SOB_NAME		VARCHAR2(30),
	SOB_ID				NUMBER(15),
	CREATE_DIST  ap_system_parameters_all.create_awt_dists_type%TYPE,
	ORG_ID				NUMBER(15)
	);

	var var_t;

END JGRX_WT;

 

/
