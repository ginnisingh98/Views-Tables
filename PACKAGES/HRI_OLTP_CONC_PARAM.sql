--------------------------------------------------------
--  DDL for Package HRI_OLTP_CONC_PARAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_CONC_PARAM" AUTHID CURRENT_USER AS
/* $Header: hriocprm.pkh 120.0 2005/09/20 01:18:32 jtitmas noship $ */

FUNCTION get_parameter_value(p_parameter_name      IN VARCHAR2,
                             p_process_table_name  IN VARCHAR2)
          RETURN VARCHAR2;

FUNCTION get_date_parameter_value(p_parameter_name      IN VARCHAR2,
                                  p_process_table_name  IN VARCHAR2)
          RETURN DATE;

END hri_oltp_conc_param;

 

/
