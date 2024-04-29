--------------------------------------------------------
--  DDL for Package HXC_MAP_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_MAP_UPLOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: hxcmapupl.pkh 115.3 2002/06/10 00:37:47 pkm ship      $ */

PROCEDURE load_mapping_row (
          p_name                IN VARCHAR2
	, p_owner		IN VARCHAR2
	, p_custom_mode		IN VARCHAR2 );

END hxc_map_upload_pkg;

 

/
