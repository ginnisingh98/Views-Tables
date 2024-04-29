--------------------------------------------------------
--  DDL for Package HXC_APS_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_APS_UPLOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: hxcapsupl.pkh 115.3 2002/06/10 00:36:17 pkm ship      $ */

PROCEDURE load_application_set_row (
          p_application_set_name IN VARCHAR2
	, p_owner		 IN VARCHAR2
	, p_custom_mode		 IN VARCHAR2 );

END hxc_aps_upload_pkg;

 

/
