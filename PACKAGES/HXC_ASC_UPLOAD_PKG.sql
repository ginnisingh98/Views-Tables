--------------------------------------------------------
--  DDL for Package HXC_ASC_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ASC_UPLOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: hxcascupl.pkh 115.3 2002/06/10 00:36:24 pkm ship      $ */

FUNCTION get_application_set_id ( p_application_set_name IN VARCHAR2 ) RETURN NUMBER;

PROCEDURE load_application_set_comp_row (
          p_time_recipient_name  IN VARCHAR2
	, p_application_set_name IN VARCHAR2
	, p_owner		IN VARCHAR2
	, p_custom_mode		IN VARCHAR2 );

END hxc_asc_upload_pkg;

 

/
