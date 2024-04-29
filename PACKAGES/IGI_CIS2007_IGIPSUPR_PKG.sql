--------------------------------------------------------
--  DDL for Package IGI_CIS2007_IGIPSUPR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_CIS2007_IGIPSUPR_PKG" AUTHID CURRENT_USER AS
-- $Header: igipsups.pls 120.0.12000000.2 2007/07/18 13:07:11 vensubra noship $

  p_supplier_from VARCHAR2(240);
  p_supplier_to   VARCHAR2(240);
  p_active        VARCHAR2(30);
  p_report        VARCHAR2(30);
  p_sort_by       VARCHAR2(240);

  pwhereclause VARCHAR2(3200);
  porderclause VARCHAR2(1200);

  FUNCTION beforereport RETURN BOOLEAN;
  FUNCTION get_p_supplier_from RETURN VARCHAR2;
  FUNCTION get_p_supplier_to RETURN VARCHAR2;
  FUNCTION get_p_report_title RETURN VARCHAR2;
  FUNCTION get_p_org_name RETURN VARCHAR2;
  FUNCTION get_p_active RETURN VARCHAR2;
  FUNCTION get_p_sortby RETURN VARCHAR2;
  FUNCTION check_active
  (
    p_start_date DATE,
    p_end_date   DATE
  ) RETURN VARCHAR2;

  FUNCTION igi_cis_is_vendor_verified (l_vendor_id NUMBER)
        RETURN VARCHAR2 ;
  FUNCTION igi_cis_is_vendor_paid (l_vendor_id NUMBER,verify_date DATE DEFAULT SYSDATE)
        RETURN VARCHAR2;
  FUNCTION igi_cis_is_verify_required (l_vendor_id NUMBER)
        RETURN VARCHAR2 ;
END igi_cis2007_igipsupr_pkg;

 

/
