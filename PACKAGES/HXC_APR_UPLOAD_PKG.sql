--------------------------------------------------------
--  DDL for Package HXC_APR_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_APR_UPLOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: hxcaprupl.pkh 115.3 2002/06/10 00:36:14 pkm ship      $ */

PROCEDURE load_approval_period_set_row (
          p_approval_period_set_name IN VARCHAR2
	, p_owner		     IN VARCHAR2
	, p_custom_mode		     IN VARCHAR2 );

END hxc_apr_upload_pkg;

 

/
