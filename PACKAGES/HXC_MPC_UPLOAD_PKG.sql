--------------------------------------------------------
--  DDL for Package HXC_MPC_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_MPC_UPLOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: hxcmpcupl.pkh 115.3 2002/06/10 13:30:26 pkm ship      $ */

PROCEDURE load_mapping_component_row (
          p_name                IN VARCHAR2
	, p_field_name		IN VARCHAR2
	, p_bld_blk_info_type	IN VARCHAR2
	, p_segment		IN VARCHAR2
	, p_owner		IN VARCHAR2
	, p_custom_mode		IN VARCHAR2 );

END hxc_mpc_upload_pkg;

 

/
