--------------------------------------------------------
--  DDL for Package GML_AUDIT_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_AUDIT_REPORTS" AUTHID CURRENT_USER AS
/* $Header: GMLOGMCS.pls 115.3 99/07/16 06:15:42 porting ship  $ */

  FUNCTION get_ofi_line_count(p_hid NUMBER) RETURN NUMBER;
  FUNCTION get_ofi_bline_count(p_hid NUMBER) RETURN NUMBER;

  FUNCTION get_ofi_total_cost(p_hid NUMBER) RETURN NUMBER;
  FUNCTION get_ofi_btotal_cost(p_hid NUMBER) RETURN NUMBER;

  FUNCTION get_gemms_line_count(p_id NUMBER) RETURN NUMBER;
  FUNCTION get_gemms_bline_count(p_hid NUMBER) RETURN NUMBER;

  FUNCTION get_gemms_total_cost(p_id NUMBER) RETURN NUMBER;
  FUNCTION get_gemms_btotal_cost(p_hid NUMBER) RETURN NUMBER;


  PRAGMA RESTRICT_REFERENCES(get_ofi_line_count,WNDS,WNPS);
  PRAGMA RESTRICT_REFERENCES(get_ofi_bline_count,WNDS,WNPS);

  PRAGMA RESTRICT_REFERENCES(get_ofi_total_cost,WNDS,WNPS);
  PRAGMA RESTRICT_REFERENCES(get_ofi_btotal_cost,WNDS,WNPS);

  PRAGMA RESTRICT_REFERENCES(get_gemms_line_count,WNDS,WNPS);
  PRAGMA RESTRICT_REFERENCES(get_gemms_bline_count,WNDS,WNPS);

  PRAGMA RESTRICT_REFERENCES(get_gemms_total_cost,WNDS,WNPS);
  PRAGMA RESTRICT_REFERENCES(get_gemms_btotal_cost,WNDS,WNPS);


  FUNCTION match_ofi_gms_po_line(p_ohid  NUMBER,
				   p_olid  NUMBER,
				   p_ollid NUMBER,
				   p_gid   NUMBER,
				   p_glid  NUMBER) RETURN VARCHAR2;
  FUNCTION chk_ofi_gms_poln_itm (p_olid  NUMBER,
				   p_glid  NUMBER) RETURN VARCHAR2;
  FUNCTION chk_ofi_gms_poln_sts (p_ollid NUMBER,
				   p_glid  NUMBER) RETURN VARCHAR2;

  PRAGMA RESTRICT_REFERENCES(match_ofi_gms_po_line,WNDS,WNPS);
  PRAGMA RESTRICT_REFERENCES(chk_ofi_gms_poln_itm,WNDS,WNPS);
  PRAGMA RESTRICT_REFERENCES(chk_ofi_gms_poln_sts,WNDS,WNPS);


  FUNCTION get_po_num( p_ponum VARCHAR2) RETURN VARCHAR2;
  FUNCTION get_rel_num( p_ponum VARCHAR2) RETURN NUMBER;

  PRAGMA RESTRICT_REFERENCES(get_po_num,WNDS,WNPS);
  PRAGMA RESTRICT_REFERENCES(get_rel_num,WNDS,WNPS);

END GML_AUDIT_REPORTS;

 

/
