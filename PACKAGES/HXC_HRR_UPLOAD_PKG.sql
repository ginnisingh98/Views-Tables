--------------------------------------------------------
--  DDL for Package HXC_HRR_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HRR_UPLOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: hxchrrupl.pkh 115.4 2002/06/10 00:37:27 pkm ship      $ */

PROCEDURE load_hrr_row (
          p_name			VARCHAR2
        , p_legislation_code            VARCHAR2
	, p_eligibility_criteria_type 	VARCHAR2
	, p_pref_hierarchy_name		VARCHAR2
	, p_rule_evaluation_order	NUMBER
	, p_resource_type		VARCHAR2
	, p_start_date			VARCHAR
	, p_end_date			VARCHAR
	, p_owner			VARCHAR2
	, p_custom_mode			VARCHAR2 );

END hxc_hrr_upload_pkg;

 

/
