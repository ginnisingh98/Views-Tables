--------------------------------------------------------
--  DDL for Package HXC_ALIAS_DEFN_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ALIAS_DEFN_UPLOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: hxcloddef.pkh 115.0 2002/09/03 09:57:13 ksethi noship $ */

PROCEDURE load_alias_definition_row (
          p_alias_definition_name    IN VARCHAR2
	, p_owner                    IN VARCHAR2
	, p_legislation_code         IN VARCHAR2
	, p_alias_context_code       IN VARCHAR2
	, p_description              IN VARCHAR2
	, p_timecard_field           IN VARCHAR2
	, p_prompt		     IN VARCHAR2
	, p_alias_type               IN VARCHAR2
	, p_reference_object	     IN VARCHAR2
	, p_custom_mode	     	     IN VARCHAR2 );


END hxc_alias_defn_upload_pkg;

 

/
