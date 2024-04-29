--------------------------------------------------------
--  DDL for Package AMS_DCF_LEADS_TITLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DCF_LEADS_TITLE" AUTHID CURRENT_USER AS
/*$Header: amsvldss.pls 115.2 2002/04/30 18:08:17 pkm ship        $ */
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below

   FUNCTION print_kpi_bin_title (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
   FUNCTION print_kpi_report_title (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
   FUNCTION print_reg_report_title (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
   FUNCTION print_reg_bin_title (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
   FUNCTION print_reg_bin_title_ls (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
   FUNCTION print_reg_bin_title_lq (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
   FUNCTION print_reg_bin_title_ws (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
   FUNCTION print_reg_bin_title_is (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
   FUNCTION print_reg_bin_title_wr (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;


END; -- Package spec

 

/
