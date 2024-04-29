--------------------------------------------------------
--  DDL for Package BEN_BEF_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BEF_UPLOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: bexflupd.pkh 120.1 2005/12/13 19:36 tjesumic noship $ */

PROCEDURE load_bef_row (
          p_short_name		VARCHAR2
	, p_decd_flag		VARCHAR2
	, p_name        	VARCHAR2
	, p_frmt_mask_typ_cd	VARCHAR2
	, p_csr_cd              VARCHAR2
	, p_lvl_cd              VARCHAR2
	, p_alwd_in_rcd_cd	VARCHAR2
        , p_Group_lvl_cd        VARCHAR2 default null
	, p_custom_mode  	VARCHAR2 );

END ben_bef_upload_pkg;

 

/
