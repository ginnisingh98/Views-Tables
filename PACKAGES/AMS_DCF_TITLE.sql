--------------------------------------------------------
--  DDL for Package AMS_DCF_TITLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DCF_TITLE" AUTHID CURRENT_USER AS
/*$Header: amsvdtls.pls 115.10 2002/04/30 18:08:14 pkm ship        $ */
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
   FUNCTION print_reg_bin_title_kpi (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
   FUNCTION print_reg_bin_title_mb (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
   FUNCTION print_reg_bin_title_ce (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
   FUNCTION print_reg_bin_title_ee (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
   FUNCTION print_reg_report_title (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
   FUNCTION print_reg_report_nc_title (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
   FUNCTION print_reg_incremental_title (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
   FUNCTION print_hom_report_title (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
   FUNCTION print_hom_report_nc_title (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
   FUNCTION print_mktg_activities_title (p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
   FUNCTION get_currency (p_parameters IN varchar2 default null) return varchar2;
   FUNCTION print_currency(p_parameters IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;




END; -- Package spec

 

/
