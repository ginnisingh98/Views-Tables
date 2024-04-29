--------------------------------------------------------
--  DDL for Package ZX_PTP_MIGRATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_PTP_MIGRATE_PKG" AUTHID CURRENT_USER AS
/* $Header: zxptpmigs.pls 120.5 2006/02/24 02:31:16 dbetanco ship $ */


	----The PL/SQL TABLES AND THE CORRESPONDING DECLARATIONS ARE PART OF BUG FIX 3722296

	TYPE org_reg_num_tab IS TABLE OF  HR_ORGANIZATION_INFORMATION.ORG_INFORMATION2%TYPE
	    INDEX BY BINARY_INTEGER;
	TYPE loc_reg_num_tab IS TABLE OF  HR_LOCATIONS_ALL.GLOBAL_ATTRIBUTE1%TYPE
	    INDEX BY BINARY_INTEGER;
	TYPE ar_sys_reg_num_tab IS TABLE OF  AR_SYSTEM_PARAMETERS_ALL.TAX_REGISTRATION_NUMBER%TYPE
	    INDEX BY BINARY_INTEGER;
	TYPE fin_sys_reg_num_tab IS TABLE OF  FINANCIALS_SYSTEM_PARAMS_ALL.VAT_REGISTRATION_NUM%TYPE
	    INDEX BY BINARY_INTEGER;
	TYPE register_num_tab IS TABLE OF  VARCHAR2(160)
	    INDEX BY BINARY_INTEGER;
	TYPE party_tax_profile_tab IS TABLE OF ZX_PARTY_TAX_PROFILE.PARTY_TAX_PROFILE_ID%TYPE
	    INDEX BY BINARY_INTEGER;
	TYPE hr_org_rep_info_tab IS TABLE OF VARCHAR2(160)
	    INDEX BY BINARY_INTEGER;
	TYPE ar_tax_reg_num_info_tab IS TABLE OF VARCHAR2(70)
	    INDEX BY BINARY_INTEGER;
	TYPE fin_vat_reg_num_tab IS TABLE OF VARCHAR2(30)
	    INDEX BY BINARY_INTEGER;
	TYPE hr_org_reg_num_tab IS TABLE OF VARCHAR2(160)
	    INDEX BY BINARY_INTEGER;

	PROCEDURE FIRST_PARTY_EXTRACT(p_org_id in Number default null);

	PROCEDURE LEGAL_ESTABLISHMENT(p_org_id in Number) ;

	PROCEDURE SUPPLIER_EXTRACT(p_party_id in NUMBER, p_org_id in Number);

	PROCEDURE SUPPLIER_SITE_EXTRACT(p_party_id in NUMBER, p_org_id in Number) ;

	PROCEDURE OU_EXTRACT(p_party_id in NUMBER) ;

	PROCEDURE 	SUPPLIER_TYPE_EXTRACT;

	PROCEDURE 	SUPPLIER_ASSOC_EXTRACT;

	PROCEDURE 	Party_Assoc_Extract
			  (p_party_source IN VARCHAR2,
			   p_party_tax_profile_id  IN NUMBER,
			   p_fiscal_class_type_code IN VARCHAR2,
			   p_fiscal_classification_code IN VARCHAR2 ,
			   p_dml_type     IN VARCHAR2);

	PROCEDURE ZX_PTP_MAIN;

        PROCEDURE SUPPLIER_TYPE_MIGRATION;

PROCEDURE REG_REP_DRIVER_PROC
(p_party_type_code zx_party_tax_profile.party_type_code%type) ;

PROCEDURE REG_REP_DRIVER_PROC_OU
(p_party_type_code zx_party_tax_profile.party_type_code%type) ;


END ZX_PTP_MIGRATE_PKG;

 

/
