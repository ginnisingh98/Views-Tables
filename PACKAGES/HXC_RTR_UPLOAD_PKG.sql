--------------------------------------------------------
--  DDL for Package HXC_RTR_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_RTR_UPLOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: hxrtrupl.pkh 115.1 2002/03/04 17:55:56 pkm ship      $ */

PROCEDURE load_rtr_row (
          p_name		VARCHAR2
        , p_ret_name		VARCHAR2
	, p_owner		VARCHAR2
	, p_custom_mode		VARCHAR2 );

PROCEDURE load_rtc_row (
          p_rtr_name		VARCHAR2
	, p_time_recipient      VARCHAR2
	, p_status      	VARCHAR2
	, p_owner		VARCHAR2
	, p_custom_mode		VARCHAR2 );

g_fndload_mode VARCHAR2(1) := 'N';

END hxc_rtr_upload_pkg;

 

/
