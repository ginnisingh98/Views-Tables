--------------------------------------------------------
--  DDL for Package HXC_HPH_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HPH_UPLOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: hxchphupl.pkh 115.6 2002/06/10 00:37:18 pkm ship      $ */

PROCEDURE load_hph_row (
          p_name		VARCHAR2
	, p_legislation_code    VARCHAR2
	, p_parent_name         varchar2
	, p_type                varchar2
	, p_edit_allowed	varchar2
	, p_displayed		varchar2
	, p_pref_def_name	varchar2
	, p_attribute_category  varchar2
	, p_attribute1		 varchar2
	, p_attribute2		  varchar2
	, p_attribute3		  varchar2
	, p_attribute4		  varchar2
	, p_attribute5		  varchar2
	, p_attribute6		  varchar2
	, p_attribute7		  varchar2
	, p_attribute8		  varchar2
	, p_attribute9		  varchar2
	, p_attribute10	   	  varchar2
	, p_attribute11	   	  varchar2
	, p_attribute12	   	  varchar2
	, p_attribute13	   	  varchar2
	, p_attribute14	   	  varchar2
	, p_attribute15	   	  varchar2
	, p_attribute16	   	  varchar2
	, p_attribute17	   	  varchar2
	, p_attribute18	   	  varchar2
	, p_attribute19	   	  varchar2
	, p_attribute20	   	  varchar2
	, p_attribute21	   	  varchar2
	, p_attribute22	   	  varchar2
	, p_attribute23	   	  varchar2
	, p_attribute24	   	  varchar2
	, p_attribute25	   	  varchar2
	, p_attribute26	   	  varchar2
	, p_attribute27	   	  varchar2
	, p_attribute28	   	  varchar2
	, p_attribute29	   	  varchar2
	, p_attribute30	   	  varchar2
	, p_owner		VARCHAR2
	, p_custom_mode		VARCHAR2 );

FUNCTION get_pref_def_name ( p_pref_definition_id NUMBER ) RETURN VARCHAR2;

FUNCTION get_attribute ( p_attribute_category	VARCHAR2
		,	 p_attribute		VARCHAR2 ) RETURN VARCHAR2;

FUNCTION get_parent ( p_pref_top_node	VARCHAR2
		,   p_pref_node		VARCHAR2
		,   p_pref_level	NUMBER
		,   p_count		NUMBER ) RETURN VARCHAR2;

END hxc_hph_upload_pkg;

 

/
