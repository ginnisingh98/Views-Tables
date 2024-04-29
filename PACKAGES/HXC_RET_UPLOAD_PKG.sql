--------------------------------------------------------
--  DDL for Package HXC_RET_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_RET_UPLOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: hxcretupl.pkh 115.4 2002/06/10 13:30:34 pkm ship      $ */

FUNCTION get_time_recipient_id ( p_time_recipient VARCHAR2 ) RETURN NUMBER;

PROCEDURE load_retrieval_process_row (
          p_name		IN VARCHAR2
	, p_time_recipient	IN VARCHAR2
	, p_mapping_name	IN VARCHAR2
	, p_owner		IN VARCHAR2
	, p_custom_mode		IN VARCHAR2 );

END hxc_ret_upload_pkg;

 

/
