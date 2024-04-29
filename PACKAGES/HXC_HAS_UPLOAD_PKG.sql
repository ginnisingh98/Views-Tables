--------------------------------------------------------
--  DDL for Package HXC_HAS_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HAS_UPLOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: hxchasupl.pkh 115.4 2002/06/10 00:37:04 pkm ship      $ */

PROCEDURE load_has_row (
          p_name		VARCHAR2
        , p_legislation_code    VARCHAR2
	, p_description		VARCHAR2
	, p_owner		VARCHAR2
	, p_custom_mode		VARCHAR2 );

END hxc_has_upload_pkg;

 

/
