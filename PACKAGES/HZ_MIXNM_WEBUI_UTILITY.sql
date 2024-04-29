--------------------------------------------------------
--  DDL for Package HZ_MIXNM_WEBUI_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_MIXNM_WEBUI_UTILITY" AUTHID CURRENT_USER AS
/*$Header: ARHXWUTS.pls 120.2 2005/01/20 16:05:41 dmmehta noship $ */

TYPE IDList IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE VARCHARList IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

/**
 * PROCEDURE Create_Rule
 *
 * DESCRIPTION
 *    Create an user creation / overwrite rule.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_rule_type                  Rule type. 'USER_CREATE_RULE' is for user create rule.
 *                                  'USER_OVERWRITE_RULE is for user overwrite rule.
 *     p_rule_name                  Rule name.
 *     p_entity_attr_id_tab         Entity / attribute id list.
 *     p_attribute_group_name_tab   A list of attribute group name.
 *     p_flag_tab                   A list of creation / overwrite flags for each
 *                                  entity / attribute.
 *   IN/OUT:
 *     p_rule_id                    Rule id.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang   o Created.
 */

PROCEDURE Create_Rule (
    p_rule_type                        IN     VARCHAR2,
    p_rule_id                          IN OUT NOCOPY NUMBER,
    p_rule_name                        IN     VARCHAR2,
    p_entity_attr_id_tab               IN     IDList,
    p_attribute_group_name_tab         IN     VARCHARList,
    p_flag_tab                         IN     VARCHARList,
    p_os_tab                         IN     VARCHARList
);

/**
 * PROCEDURE Update_Rule
 *
 * DESCRIPTION
 *    Update an user creation / overwrite rule.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_rule_type                  Rule type. 'USER_CREATE_RULE' is for user create rule.
 *                                  'USER_OVERWRITE_RULE is for user overwrite rule.
 *     p_rule_id                    Rule id.
 *     p_rule_name                  Rule name.
 *     p_entity_attr_id_tab         Entity / attribute id list.
 *     p_attribute_group_name_tab   A list of attribute group name.
 *     p_flag_tab                   A list of creation / overwrite flags for each
 *                                  entity / attribute.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang   o Created.
 */

PROCEDURE Update_Rule (
    p_rule_type                        IN     VARCHAR2,
    p_rule_id                          IN     NUMBER,
    p_rule_name                        IN     VARCHAR2,
    p_entity_attr_id_tab               IN     IDList,
    p_attribute_group_name_tab         IN     VARCHARList,
    p_flag_tab                         IN     VARCHARList,
    p_os_tab                         IN     VARCHARList
);

/**
 * PROCEDURE Copy_Rule
 *
 * DESCRIPTION
 *    Copy an user creation / overwrite rule.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_rule_type                  Rule type. 'USER_CREATE_RULE' is for user create rule.
 *                                  'USER_OVERWRITE_RULE is for user overwrite rule.
 *     p_rule_id                    Rule id.
 *     p_rule_name                  Rule name.
 *   OUT:
 *     x_new_rule_id                New rule id.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang   o Created.
 */

PROCEDURE Copy_Rule (
    p_rule_type                        IN     VARCHAR2,
    p_rule_id                          IN     NUMBER,
    p_rule_name                        IN     VARCHAR2,
    x_new_rule_id                      OUT    NOCOPY NUMBER
);

/**
 * PROCEDURE Delete_Rule
 *
 * DESCRIPTION
 *    Delete an user creation / overwrite rule.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_rule_type                  Rule type. 'USER_CREATE_RULE' is for user create rule.
 *                                  'USER_OVERWRITE_RULE is for user overwrite rule.
 *     p_rule_id                    Rule id.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang   o Created.
 */

PROCEDURE Delete_Rule (
    p_rule_type                        IN     VARCHAR2,
    p_rule_id                          IN     NUMBER
);


/**
 * PROCEDURE Update_ThirdPartyRule
 *
 * DESCRIPTION
 *    Update the third party rule.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_rule_exists                'Y'/'N' indicator to indicate if the rule
 *     p_entity_attr_id_tab         Entity / attribute id list.
 *     p_attribute_group_name_tab   A list of attribute group name.
 *     p_flag_tab                   A list of overwrite flags for each attribute.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang   o Created.
 */

PROCEDURE Update_ThirdPartyRule (
    p_rule_exists                      IN     VARCHAR2,
    p_entity_attr_id_tab               IN     IDList,
    p_attribute_group_name_tab         IN     VARCHARList,
    p_flag_tab                         IN     VARCHARList,
    p_os_tab                         IN     VARCHARList
);

/**
 * PROCEDURE Set_DataSources
 *
 * DESCRIPTION
 *    Set the data sources for a list of attributes.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_entity_attr_id_tab         Entity / attribute id list.
 *     p_attribute_group_name_tab   A list of attribute group name.
 *     p_range_tab                  The index range of each attribute.
 *     p_data_sources_tab           The list of data sources for each attributes.
 *     p_ranking_tab                The list of data sources ranking for each attributes.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang   o Created.
 */

PROCEDURE Set_DataSources (
    p_entity_attr_id_tab               IN     IDList,
    p_attribute_group_name_tab         IN     VARCHARList,
    p_range_tab                        IN     IDList,
    p_data_sources_tab                 IN     VARCHARList,
    p_ranking_tab                      IN     IDList
);

/**
 * PROCEDURE Get_DataSourcesForAGroup
 *
 * DESCRIPTION
 *    Get the data source setup for a group of attributes.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_entity_type                Entity type.
 *     p_entity_attr_id_tab         Entity / attribute id list.
 *     x_has_same_setup             'Y'/'N' indicator for if the attributes have
 *                                  the same data source setup.
 *     x_data_sources_tab           The list of data sources meaning for all of the attributes.
 *     x_meaning_tab                The list of data sources for all of the attributes.
 *     x_ranking_tab                The list of data sources ranking for all of the attributes.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang   o Created.
 */

PROCEDURE Get_DataSourcesForAGroup (
    p_entity_type                      IN     VARCHAR2,
    p_entity_attr_id_tab               IN     IDList,
    x_has_same_setup                   OUT    NOCOPY VARCHAR2,
    x_data_sources_tab                 OUT    NOCOPY VARCHARList,
    x_meaning_tab                      OUT    NOCOPY VARCHARList,
    x_ranking_tab                      OUT    NOCOPY IDList
);

/**
 * PROCEDURE Set_DataSourcesForAGroup
 *
 * DESCRIPTION
 *    Set the data sources for a list of attributes.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_entity_attr_id_tab         Entity / attribute id list.
 *     p_attribute_group_name_tab   A list of attribute group name.
 *     p_data_sources_tab           The list of data sources for each attributes.
 *     p_ranking_tab                The list of data sources ranking for each attributes.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang   o Created.
 */

PROCEDURE Set_DataSourcesForAGroup (
    p_entity_attr_id_tab               IN     IDList,
    p_attribute_group_name_tab         IN     VARCHARList,
    p_data_sources_tab                 IN     VARCHARList,
    p_ranking_tab                      IN     IDList
);

END HZ_MIXNM_WEBUI_UTILITY;

 

/
