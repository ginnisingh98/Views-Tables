--------------------------------------------------------
--  DDL for Package BEN_BENHIPAA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BENHIPAA_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: BENHIPAAS.pls 120.1.12010000.2 2009/02/04 15:01:31 sagnanas ship $ */
	P_BUSINESS_GROUP_ID	number;
	P_PERSON_ID	number;
	P_EFFECTIVE_DATE	date;
	P_LOCATION_ID	varchar2(40);
	P_ORGANIZATION_ID	varchar2(40);
	P_PGM_ID	varchar2(40);
	P_BNFTS_GRP_ID	varchar2(40);
	P_CONC_REQUEST_ID	number;
	function CF_STANDARD_HEADERFormula return Number  ;
	function cf_wait_start_dtformula(coverage_end_date in date, orgnl_enrt_dt in date, wait_perd_strt_dt in date, per_cm_prvdd_id number) return char  ;
	function cf_wait_perd_cmpltn_dtformula(coverage_end_date in date, orgnl_enrt_dt in date, wait_ped_cmpln_dt in date) return char  ;
	PROCEDURE update_pcd_sent_dt(p_per_cm_prvdd_id in number
                             ,p_effective_Date in date )  ;
	function AfterReport return boolean  ;
	function BeforeReport return boolean  ;
END BEN_BENHIPAA_XMLP_PKG;

/
