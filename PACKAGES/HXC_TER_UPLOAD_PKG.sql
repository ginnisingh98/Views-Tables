--------------------------------------------------------
--  DDL for Package HXC_TER_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TER_UPLOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: hxcterupl.pkh 115.5 2003/03/24 23:22:43 gpaytonm noship $ */

PROCEDURE load_ter_row (
          p_name		IN VARCHAR2
        , p_legislation_code    IN VARCHAR2
	, p_rule_usage		IN VARCHAR2
	, p_mapping_name	IN VARCHAR2
	, p_formula_name	IN VARCHAR2
        , p_attribute_category  IN VARCHAR2
        , p_attribute1          IN VARCHAR2
        , p_attribute2          IN VARCHAR2
        , p_attribute3          IN VARCHAR2
        , p_attribute4          IN VARCHAR2
        , p_attribute5          IN VARCHAR2
        , p_attribute6          IN VARCHAR2
        , p_attribute7          IN VARCHAR2
        , p_attribute8          IN VARCHAR2
        , p_attribute9          IN VARCHAR2
        , p_attribute10         IN VARCHAR2
        , p_attribute11         IN VARCHAR2
        , p_attribute12         IN VARCHAR2
        , p_attribute13         IN VARCHAR2
        , p_attribute14         IN VARCHAR2
        , p_attribute15         IN VARCHAR2
        , p_attribute16         IN VARCHAR2
        , p_attribute17         IN VARCHAR2
        , p_attribute18         IN VARCHAR2
        , p_attribute19         IN VARCHAR2
        , p_attribute20         IN VARCHAR2
        , p_attribute21         IN VARCHAR2
        , p_attribute22         IN VARCHAR2
        , p_attribute23         IN VARCHAR2
        , p_attribute24         IN VARCHAR2
        , p_attribute25         IN VARCHAR2
        , p_attribute26         IN VARCHAR2
        , p_attribute27         IN VARCHAR2
        , p_attribute28         IN VARCHAR2
        , p_attribute29         IN VARCHAR2
        , p_attribute30         IN VARCHAR2
	, p_description		IN VARCHAR2
	, p_start_date		IN VARCHAR2
	, p_end_date		IN VARCHAR2
	, p_owner		IN VARCHAR2
	, p_custom_mode		IN VARCHAR2 );

PROCEDURE load_daru_row (
          p_time_entry_rule_name IN VARCHAR2
	, p_approval_style_name	IN VARCHAR2
	, p_time_recipient	IN VARCHAR2
	, p_owner		IN VARCHAR2
	, p_custom_mode		IN VARCHAR2 );

END hxc_ter_upload_pkg;

 

/
