--------------------------------------------------------
--  DDL for Package HXC_MCU_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_MCU_UPLOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: hxcmcuupl.pkh 115.3 2002/06/10 13:30:20 pkm ship      $ */

FUNCTION get_mapping_id ( p_mapping_name IN VARCHAR2 ) RETURN NUMBER;

PROCEDURE load_mapping_comp_usage_row (
          p_name                IN VARCHAR2
	, p_mapping_name	IN VARCHAR2
	, p_owner		IN VARCHAR2
	, p_custom_mode		IN VARCHAR2 );

END hxc_mcu_upload_pkg;

 

/
