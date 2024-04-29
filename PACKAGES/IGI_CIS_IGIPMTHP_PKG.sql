--------------------------------------------------------
--  DDL for Package IGI_CIS_IGIPMTHP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_CIS_IGIPMTHP_PKG" AUTHID CURRENT_USER AS
-- $Header: igipmthps.pls 120.0.12010000.3 2011/10/05 01:40:39 yanasing ship $
	p_supplier_from	VARCHAR2(240);
	p_supplier_to	VARCHAR2(240);
	p_period	VARCHAR2(30);
	p_sort_by	VARCHAR2(30);
        p_print_type    VARCHAR2(240);
	p_mode          VARCHAR2(2);
	p_del_preview VARCHAR2(2);
        p_report_lev VARCHAR2(2);
	pwhereclause    VARCHAR2(3200);
	tableclause     VARCHAR2(240);
	orderbyclause   VARCHAR2(240);
        partselect VARCHAR2(240);
        partgroupby VARCHAR2(240);
	p_amt_type      VARCHAR2(10); --ER6137652

	FUNCTION BeforeReport RETURN BOOLEAN ;
	FUNCTION AfterReport RETURN BOOLEAN;
	FUNCTION get_p_supplier_from RETURN VARCHAR2;
	FUNCTION get_p_supplier_to RETURN VARCHAR2;
	FUNCTION get_period_start_date RETURN VARCHAR2;
	FUNCTION get_period_end_date RETURN VARCHAR2;
	FUNCTION get_print_type RETURN VARCHAR2;
	FUNCTION get_org_name RETURN VARCHAR2;
	FUNCTION get_p_report_title RETURN VARCHAR2;
	FUNCTION get_p_sort_by RETURN VARCHAR2;
        FUNCTION get_p_rep_mode RETURN VARCHAR2;
        FUNCTION get_tax_status(p_awt_group_code IN VARCHAR2) RETURN VARCHAR2;
	FUNCTION get_p_amt_type RETURN VARCHAR2; --ER6137652
END igi_cis_igipmthp_pkg;

/
