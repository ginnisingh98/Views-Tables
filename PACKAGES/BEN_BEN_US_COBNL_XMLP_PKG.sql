--------------------------------------------------------
--  DDL for Package BEN_BEN_US_COBNL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BEN_US_COBNL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: BEN_US_COBNLS.pls 120.1 2007/12/10 08:39:40 vjaganat noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_PERSON_ID	number;
	P_BNFTS_GRP_ID	number;
	P_LOCATION_ID	number;
	P_ORGANIZATION_ID	number;
	P_PGM_ID	number;
	P_EFFECTIVE_DATE	date;
	P_conc_request_id	number;
	cp_effective_date	date;
	CP_ler_text	varchar2(500);
	function cf_1formula(admin_name in varchar2, loc_addr1 in varchar2, loc_Addr2 in varchar2,loc_Addr3 in varchar2, loc_city in varchar2, loc_state in varchar2, loc_zip in varchar2, loc_phone in varchar2,per_cm_prvdd_id in number) return varchar2;
	procedure update_pcd_sent_dt(p_per_cm_prvdd_id in number
                             ,p_effective_date in date )  ;
	function AfterReport return boolean  ;
	function BeforeReport return boolean  ;
	function CF_STANDARD_HEADERFormula return Number  ;
	function cf_cmcd_acty_rep_prdformula(cmcd_acty_ref_perd_cd in varchar2) return char  ;
	Function cp_effective_date_p return date;
	Function CP_ler_text_p(ler_type in varchar2,ler_name in varchar2,pcm_ocrd_dt in date) return varchar2;
END BEN_BEN_US_COBNL_XMLP_PKG;

/
