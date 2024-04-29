--------------------------------------------------------
--  DDL for Package HXC_RRG_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_RRG_UPLOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: hxcrrgupl.pkh 115.3 2002/06/10 13:30:46 pkm ship      $ */

PROCEDURE load_retrieval_rule_group_row (
          p_retrieval_rule_group_name IN VARCHAR2
	, p_owner		 IN VARCHAR2
	, p_custom_mode		 IN VARCHAR2 );

END hxc_rrg_upload_pkg;

 

/
