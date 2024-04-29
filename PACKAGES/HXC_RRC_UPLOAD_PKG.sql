--------------------------------------------------------
--  DDL for Package HXC_RRC_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_RRC_UPLOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: hxcrrcupl.pkh 115.3 2002/06/10 13:30:41 pkm ship      $ */

FUNCTION get_retrieval_rule_group_id ( p_retrieval_rule_group_name IN VARCHAR2 ) RETURN NUMBER;

PROCEDURE load_rtr_group_comp_row (
          p_retrieval_rule_name      IN VARCHAR2
	, p_retrieval_rule_group_name IN VARCHAR2
	, p_owner	       	     IN VARCHAR2
	, p_custom_mode		     IN VARCHAR2 );

END hxc_rrc_upload_pkg;

 

/
