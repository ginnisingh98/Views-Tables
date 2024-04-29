--------------------------------------------------------
--  DDL for Package HXC_DEP_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_DEP_UPLOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: hxdepupl.pkh 115.1 2002/03/01 18:29:21 pkm ship      $ */

PROCEDURE load_deposit_process_row (
          p_name		IN VARCHAR2
	, p_time_source		IN VARCHAR2
	, p_mapping_name	IN VARCHAR2
	, p_owner		IN VARCHAR2
	, p_custom_mode		IN VARCHAR2 );

END hxc_dep_upload_pkg;

 

/
