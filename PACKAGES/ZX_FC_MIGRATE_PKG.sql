--------------------------------------------------------
--  DDL for Package ZX_FC_MIGRATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_FC_MIGRATE_PKG" AUTHID CURRENT_USER as
/* $Header: zxfcmigrates.pls 120.15.12010000.1 2008/07/28 13:32:03 appldev ship $ */

PROCEDURE       MTL_SYSTEM_ITEMS;
PROCEDURE       FC_ENTITIES;
PROCEDURE       COUNTRY_DEFAULT;
PROCEDURE       ZX_FC_MIGRATE;
PROCEDURE       ZX_MIGRATE_AP;
PROCEDURE       ZX_MIGRATE_AR;

PROCEDURE FC_TYPE_INSERT(
 	p_classification_type_code 	IN  ZX_FC_TYPES_B.CLASSIFICATION_TYPE_CODE%TYPE,
 	p_classification_type_name 	IN  ZX_FC_TYPES_TL.CLASSIFICATION_TYPE_NAME%TYPE,
 	p_owner_id_num			IN  ZX_FC_TYPES_B.OWNER_ID_NUM%TYPE);

PROCEDURE FC_PARTY_TYPE_INSERT(
 	p_classification_type_code 	IN  ZX_FC_TYPES_B.CLASSIFICATION_TYPE_CODE%TYPE,
 	p_classification_type_name 	IN  ZX_FC_TYPES_TL.CLASSIFICATION_TYPE_NAME%TYPE,
 	p_tca_class 		        IN  VARCHAR2);

PROCEDURE FIRST_LEVEL_FC_CODE_INSERT(
	p_classification_type_code 	IN  ZX_FC_CODES_B.CLASSIFICATION_TYPE_CODE%TYPE,
 	p_classification_code 		IN  ZX_FC_CODES_B.CLASSIFICATION_CODE%TYPE,
 	p_classification_name 		IN  ZX_FC_CODES_TL.CLASSIFICATION_NAME%TYPE,
 	p_country_code  		IN  ZX_FC_CODES_B.COUNTRY_CODE%TYPE,
 	x_fc_id 			OUT NOCOPY ZX_FC_CODES_B.CLASSIFICATION_ID%TYPE);


PROCEDURE CREATE_MTL_CATEGORIES (l_lookup_type      IN VARCHAR2,
  l_category_name    IN VARCHAR2,
  l_category_status  OUT NOCOPY VARCHAR2,
  l_category_set     OUT NOCOPY mtl_category_sets_b.Category_set_ID%TYPE,
  l_structure_id     OUT NOCOPY mtl_category_sets_b.structure_id%TYPE);

FUNCTION Is_Country_Installed(
    p_application_id IN fnd_module_installations.APPLICATION_ID%TYPE,
    p_module_short_name IN fnd_module_installations.MODULE_SHORT_NAME%TYPE
    ) RETURN BOOLEAN;

PROCEDURE Create_Category_Sets;

PROCEDURE OKL_MIGRATION;

PROCEDURE Create_Category_Set(p_structure_code    IN VARCHAR2,
                              p_structure_desc    IN VARCHAR2,
                              p_category_set_name IN VARCHAR2,
                              p_category_set_desc IN VARCHAR2 );

-- Bug # 5106298. Called from country defaults UI.
-- Used to create the FC Types for fresh install.
PROCEDURE CREATE_SEEDED_FC_TYPES(p_country_code       IN VARCHAR2,
                                 x_category_set       OUT NOCOPY NUMBER,
				 x_category_set_name  OUT NOCOPY VARCHAR2,
                                 x_return_status      OUT NOCOPY VARCHAR2
                                );

-- Bug# 5106298. This procedure is called from zxcfctbc.lct file
PROCEDURE FC_CODE_GDF_INSERT(
 	p_classification_code 		IN  ZX_FC_CODES_B.CLASSIFICATION_CODE%TYPE,
	p_classification_name 		IN  ZX_FC_CODES_TL.CLASSIFICATION_NAME%TYPE,
	p_country_code  		IN  ZX_FC_CODES_B.COUNTRY_CODE%TYPE,
	p_lookup_type			IN  FND_LOOKUP_VALUES.LOOKUP_TYPE%TYPE,
	p_tax_event_class_code		IN  ZX_EVENT_CLASSES_VL.TAX_EVENT_CLASS_CODE%TYPE,
	p_record_type_code              IN  ZX_FC_CODES_B.RECORD_TYPE_CODE%TYPE
	);


/*THIS PROECEDURE IS USED TO INSERT VALUES BASED UPON THE LOOKUP TYPE */
PROCEDURE FC_CODE_FROM_FND_LOOKUP(
	p_classification_type_code 	IN  ZX_FC_CODES_B.CLASSIFICATION_TYPE_CODE%TYPE,
 	p_lookup_type			IN  FND_LOOKUP_VALUES.LOOKUP_TYPE%TYPE,
	p_country_code			IN  ZX_FC_CODES_B.COUNTRY_CODE%TYPE,
        p_parent_fc_id			IN  ZX_FC_CODES_B.CLASSIFICATION_ID%TYPE,
	p_ancestor_code			IN  ZX_FC_CODES_DENORM_B.ANCESTOR_CODE%TYPE,
	p_ancestor_name			IN  ZX_FC_CODES_DENORM_B.ANCESTOR_NAME%TYPE,
	p_classification_code_level	IN  ZX_FC_CODES_DENORM_B.CLASSIFICATION_CODE_LEVEL%TYPE
	);

END ZX_FC_MIGRATE_PKG;

/
