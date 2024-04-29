--------------------------------------------------------
--  DDL for Package Body IGS_AD_IMP_018
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_IMP_018" AS
/* $Header: IGSAD96B.pls 120.0 2005/06/01 14:06:06 appldev noship $ */
FUNCTION validate_desc_flex
(
 p_attribute_category IN VARCHAR2,
 p_attribute1  IN VARCHAR2,
 p_attribute2  IN VARCHAR2,
 p_attribute3  IN VARCHAR2,
 p_attribute4  IN VARCHAR2,
 p_attribute5  IN VARCHAR2,
 p_attribute6  IN VARCHAR2,
 p_attribute7  IN VARCHAR2,
 p_attribute8  IN VARCHAR2,
 p_attribute9  IN VARCHAR2,
 p_attribute10  IN VARCHAR2,
 p_attribute11  IN VARCHAR2,
 p_attribute12  IN VARCHAR2,
 p_attribute13  IN VARCHAR2,
 p_attribute14  IN VARCHAR2,
 p_attribute15  IN VARCHAR2,
 p_attribute16  IN VARCHAR2,
 p_attribute17  IN VARCHAR2,
 p_attribute18  IN VARCHAR2,
 p_attribute19  IN VARCHAR2,
 p_attribute20  IN VARCHAR2,
 p_desc_flex_name IN VARCHAR2
) RETURN BOOLEAN AS
	CURSOR app_cur IS
	SELECT
		application_short_name
	FROM
		fnd_application app, fnd_descriptive_flexs des
	WHERE
		app.application_id = des.application_id AND
		des.descriptive_flexfield_name = p_desc_flex_name;
	app_rec app_cur%ROWTYPE;
BEGIN
 fnd_flex_descval.clear_column_values;
 fnd_flex_descval.set_context_value(p_attribute_category);
 fnd_flex_descval.set_column_value('ATTRIBUTE1',p_attribute1);
 fnd_flex_descval.set_column_value('ATTRIBUTE2',p_attribute2);
 fnd_flex_descval.set_column_value('ATTRIBUTE3',p_attribute3);
 fnd_flex_descval.set_column_value('ATTRIBUTE4',p_attribute4);
 fnd_flex_descval.set_column_value('ATTRIBUTE5',p_attribute5);
 fnd_flex_descval.set_column_value('ATTRIBUTE6',p_attribute6);
 fnd_flex_descval.set_column_value('ATTRIBUTE7',p_attribute7);
 fnd_flex_descval.set_column_value('ATTRIBUTE8',p_attribute8);
 fnd_flex_descval.set_column_value('ATTRIBUTE9',p_attribute9);
 fnd_flex_descval.set_column_value('ATTRIBUTE10',p_attribute10);
 fnd_flex_descval.set_column_value('ATTRIBUTE11',p_attribute11);
 fnd_flex_descval.set_column_value('ATTRIBUTE12',p_attribute12);
 fnd_flex_descval.set_column_value('ATTRIBUTE13',p_attribute13);
 fnd_flex_descval.set_column_value('ATTRIBUTE14',p_attribute14);
 fnd_flex_descval.set_column_value('ATTRIBUTE15',p_attribute15);
 fnd_flex_descval.set_column_value('ATTRIBUTE16',p_attribute16);
 fnd_flex_descval.set_column_value('ATTRIBUTE17',p_attribute17);
 fnd_flex_descval.set_column_value('ATTRIBUTE18',p_attribute18);
 fnd_flex_descval.set_column_value('ATTRIBUTE19',p_attribute19);
 fnd_flex_descval.set_column_value('ATTRIBUTE20',p_attribute20);
 OPEN app_cur;
 FETCH app_cur INTO app_rec;
 CLOSE app_cur;
 IF (FND_FLEX_DESCVAL.validate_desccols( app_rec.application_short_name, p_desc_flex_name, 'I',SYSDATE)) THEN
  RETURN TRUE;
 ELSE
  RETURN FALSE;
 END IF;
EXCEPTION
 WHEN OTHERS THEN
  IF app_cur%ISOPEN THEN
  	CLOSE app_cur;
  END IF;
  RETURN FALSE;
END validate_desc_flex;

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
 RETURN BOOLEAN AS

 CURSOR app_cur IS
  SELECT application_short_name
  FROM fnd_application app, fnd_descriptive_flexs des
  WHERE app.application_id = des.application_id AND
	des.descriptive_flexfield_name = p_desc_flex_name;
	app_rec app_cur%ROWTYPE;
BEGIN
 fnd_flex_descval.clear_column_values;
 fnd_flex_descval.set_context_value(p_attribute_category);
 fnd_flex_descval.set_column_value('ATTRIBUTE1',p_attribute1);
 fnd_flex_descval.set_column_value('ATTRIBUTE2',p_attribute2);
 fnd_flex_descval.set_column_value('ATTRIBUTE3',p_attribute3);
 fnd_flex_descval.set_column_value('ATTRIBUTE4',p_attribute4);
 fnd_flex_descval.set_column_value('ATTRIBUTE5',p_attribute5);
 fnd_flex_descval.set_column_value('ATTRIBUTE6',p_attribute6);
 fnd_flex_descval.set_column_value('ATTRIBUTE7',p_attribute7);
 fnd_flex_descval.set_column_value('ATTRIBUTE8',p_attribute8);
 fnd_flex_descval.set_column_value('ATTRIBUTE9',p_attribute9);
 fnd_flex_descval.set_column_value('ATTRIBUTE10',p_attribute10);
 fnd_flex_descval.set_column_value('ATTRIBUTE11',p_attribute11);
 fnd_flex_descval.set_column_value('ATTRIBUTE12',p_attribute12);
 fnd_flex_descval.set_column_value('ATTRIBUTE13',p_attribute13);
 fnd_flex_descval.set_column_value('ATTRIBUTE14',p_attribute14);
 fnd_flex_descval.set_column_value('ATTRIBUTE15',p_attribute15);
 fnd_flex_descval.set_column_value('ATTRIBUTE16',p_attribute16);
 fnd_flex_descval.set_column_value('ATTRIBUTE17',p_attribute17);
 fnd_flex_descval.set_column_value('ATTRIBUTE18',p_attribute18);
 fnd_flex_descval.set_column_value('ATTRIBUTE19',p_attribute19);
 fnd_flex_descval.set_column_value('ATTRIBUTE20',p_attribute20);
 fnd_flex_descval.set_column_value('ATTRIBUTE21',p_attribute21);
 fnd_flex_descval.set_column_value('ATTRIBUTE22',p_attribute22);
 fnd_flex_descval.set_column_value('ATTRIBUTE23',p_attribute23);
 fnd_flex_descval.set_column_value('ATTRIBUTE24',p_attribute24);
 fnd_flex_descval.set_column_value('ATTRIBUTE25',p_attribute25);
 fnd_flex_descval.set_column_value('ATTRIBUTE26',p_attribute26);
 fnd_flex_descval.set_column_value('ATTRIBUTE27',p_attribute27);
 fnd_flex_descval.set_column_value('ATTRIBUTE28',p_attribute28);
 fnd_flex_descval.set_column_value('ATTRIBUTE29',p_attribute29);
 fnd_flex_descval.set_column_value('ATTRIBUTE30',p_attribute30);
 fnd_flex_descval.set_column_value('ATTRIBUTE31',p_attribute31);
 fnd_flex_descval.set_column_value('ATTRIBUTE32',p_attribute32);
 fnd_flex_descval.set_column_value('ATTRIBUTE33',p_attribute33);
 fnd_flex_descval.set_column_value('ATTRIBUTE34',p_attribute34);
 fnd_flex_descval.set_column_value('ATTRIBUTE35',p_attribute35);
 fnd_flex_descval.set_column_value('ATTRIBUTE36',p_attribute36);
 fnd_flex_descval.set_column_value('ATTRIBUTE37',p_attribute37);
 fnd_flex_descval.set_column_value('ATTRIBUTE38',p_attribute38);
 fnd_flex_descval.set_column_value('ATTRIBUTE39',p_attribute39);
 fnd_flex_descval.set_column_value('ATTRIBUTE40',p_attribute40);
 OPEN app_cur;
 FETCH app_cur INTO app_rec;
 CLOSE app_cur;
 IF (FND_FLEX_DESCVAL.validate_desccols( app_rec.application_short_name, p_desc_flex_name, 'I',SYSDATE)) THEN
  RETURN TRUE;
 ELSE
  RETURN FALSE;
 END IF;
EXCEPTION
 WHEN OTHERS THEN
  IF app_cur%ISOPEN THEN
  	CLOSE app_cur;
  END IF;
  RETURN FALSE;
END validate_desc_flex_40_cols;

END IGS_AD_IMP_018;

/
