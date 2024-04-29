--------------------------------------------------------
--  DDL for Package IGS_AD_IMP_018
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_IMP_018" AUTHID CURRENT_USER AS
/* $Header: IGSAD96S.pls 115.4 2002/02/11 16:40:42 pkm ship      $ */

FUNCTION validate_desc_flex(
 p_attribute_category	IN VARCHAR2,
 p_attribute1		IN VARCHAR2,
 p_attribute2		IN VARCHAR2,
 p_attribute3		IN VARCHAR2,
 p_attribute4		IN VARCHAR2,
 p_attribute5		IN VARCHAR2,
 p_attribute6		IN VARCHAR2,
 p_attribute7		IN VARCHAR2,
 p_attribute8		IN VARCHAR2,
 p_attribute9		IN VARCHAR2,
 p_attribute10		IN VARCHAR2,
 p_attribute11		IN VARCHAR2,
 p_attribute12		IN VARCHAR2,
 p_attribute13		IN VARCHAR2,
 p_attribute14		IN VARCHAR2,
 p_attribute15		IN VARCHAR2,
 p_attribute16		IN VARCHAR2,
 p_attribute17		IN VARCHAR2,
 p_attribute18		IN VARCHAR2,
 p_attribute19		IN VARCHAR2,
 p_attribute20		IN VARCHAR2,
 p_desc_flex_name	IN VARCHAR2)
 RETURN BOOLEAN;

FUNCTION validate_desc_flex_40_cols(
 p_attribute_category	IN VARCHAR2,
 p_attribute1		IN VARCHAR2,
 p_attribute2		IN VARCHAR2,
 p_attribute3		IN VARCHAR2,
 p_attribute4		IN VARCHAR2,
 p_attribute5		IN VARCHAR2,
 p_attribute6		IN VARCHAR2,
 p_attribute7		IN VARCHAR2,
 p_attribute8		IN VARCHAR2,
 p_attribute9		IN VARCHAR2,
 p_attribute10		IN VARCHAR2,
 p_attribute11		IN VARCHAR2,
 p_attribute12		IN VARCHAR2,
 p_attribute13		IN VARCHAR2,
 p_attribute14		IN VARCHAR2,
 p_attribute15		IN VARCHAR2,
 p_attribute16		IN VARCHAR2,
 p_attribute17		IN VARCHAR2,
 p_attribute18		IN VARCHAR2,
 p_attribute19		IN VARCHAR2,
 p_attribute20		IN VARCHAR2,
 p_attribute21		IN VARCHAR2,
 p_attribute22		IN VARCHAR2,
 p_attribute23		IN VARCHAR2,
 p_attribute24		IN VARCHAR2,
 p_attribute25		IN VARCHAR2,
 p_attribute26		IN VARCHAR2,
 p_attribute27		IN VARCHAR2,
 p_attribute28		IN VARCHAR2,
 p_attribute29		IN VARCHAR2,
 p_attribute30		IN VARCHAR2,
 p_attribute31		IN VARCHAR2,
 p_attribute32		IN VARCHAR2,
 p_attribute33		IN VARCHAR2,
 p_attribute34		IN VARCHAR2,
 p_attribute35		IN VARCHAR2,
 p_attribute36		IN VARCHAR2,
 p_attribute37		IN VARCHAR2,
 p_attribute38		IN VARCHAR2,
 p_attribute39		IN VARCHAR2,
 p_attribute40		IN VARCHAR2,
 p_desc_flex_name	IN VARCHAR2)
 RETURN BOOLEAN;

END Igs_Ad_Imp_018;

 

/
