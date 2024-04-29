--------------------------------------------------------
--  DDL for Package HXC_HTS_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HTS_UPLOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: hxchtsupl.pkh 115.4 2004/05/13 02:18:35 dragarwa noship $ */

PROCEDURE load_time_source_row (
          p_name                IN VARCHAR2
	, p_owner		IN VARCHAR2
	, p_custom_mode		IN VARCHAR2 );
PROCEDURE load_time_source_row (
          p_name                IN VARCHAR2
	, p_owner		IN VARCHAR2
	, p_custom_mode		IN VARCHAR2
	,p_last_update_date         IN VARCHAR2);


END hxc_hts_upload_pkg;

 

/
