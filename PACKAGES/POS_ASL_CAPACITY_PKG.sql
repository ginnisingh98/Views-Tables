--------------------------------------------------------
--  DDL for Package POS_ASL_CAPACITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_ASL_CAPACITY_PKG" AUTHID CURRENT_USER AS
/* $Header: POSSICPS.pls 115.1 99/10/15 16:19:38 porting ship $ */

  l_language    VARCHAR2(5);
  l_script_name VARCHAR2(240);
  l_org_id      NUMBER;
  l_user_id     NUMBER;
  l_session_id  NUMBER;
  l_responsibility_id NUMBER;
  l_request_id NUMBER;
  l_date_format varchar2(100);


  TYPE t_text_table is table of varchar2(240) index by binary_integer;
  g_dummy t_text_table;

  PROCEDURE capacity_frame(pos_asl_id       IN VARCHAR2 DEFAULT NULL);

  PROCEDURE submit_capacity(pos_sic_action  IN VARCHAR2 DEFAULT NULL,
                   pos_sic_rows             IN VARCHAR2 DEFAULT NULL,
                   p_asl_id                 IN VARCHAR2 DEFAULT NULL,
                   pos_error_row            IN VARCHAR2 DEFAULT NULL,
                   pos_more_rows            IN VARCHAR2 DEFAULT NULL,
		   pos_sic_capacity_id      IN t_text_table DEFAULT g_dummy,
		   pos_sic_from_date        IN t_text_table DEFAULT g_dummy,
		   pos_sic_to_date          IN t_text_table DEFAULT g_dummy,
	 	   pos_sic_capacity_per_day IN t_text_table DEFAULT g_dummy);


END POS_ASL_CAPACITY_PKG;

 

/
