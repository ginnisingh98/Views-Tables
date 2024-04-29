--------------------------------------------------------
--  DDL for Package HXC_APC_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_APC_UPLOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: hxcapcupl.pkh 115.3 2002/06/10 00:36:04 pkm ship      $ */

FUNCTION get_approval_period_set_id ( p_approval_period_set_name IN VARCHAR2 ) RETURN NUMBER;

PROCEDURE load_approval_period_comp_row (
          p_time_recipient_name      IN VARCHAR2
        , p_recurring_period_name    IN VARCHAR2
	, p_approval_period_set_name IN VARCHAR2
	, p_owner	       	     IN VARCHAR2
	, p_custom_mode		     IN VARCHAR2 );

END hxc_apc_upload_pkg;

 

/
