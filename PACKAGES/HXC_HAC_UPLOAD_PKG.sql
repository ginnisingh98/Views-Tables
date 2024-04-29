--------------------------------------------------------
--  DDL for Package HXC_HAC_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HAC_UPLOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: hxhacupl.pkh 115.2 2002/03/01 18:29:25 pkm ship      $ */

PROCEDURE load_hac_row (
          p_as_name		VARCHAR2
	, p_time_recipient      VARCHAR2
	, p_approval_order 	NUMBER
	, p_approval_mechanism	VARCHAR2
	, p_approval_mechanism_name VARCHAR2
	, p_wf_item_type	VARCHAR2
	, p_wf_name		VARCHAR2
	, p_start_date		VARCHAR2
	, p_end_date		VARCHAR2
	, p_owner		VARCHAR2
	, p_custom_mode		VARCHAR2 );

END hxc_hac_upload_pkg;

 

/
