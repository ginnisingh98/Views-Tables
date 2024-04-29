--------------------------------------------------------
--  DDL for Package HZ_MIXNM_API_DYNAMIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_MIXNM_API_DYNAMIC_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHXAPIS.pls 120.2 2005/10/30 04:23:23 appldev noship $ */

--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

/**
 * PROCEDURE initAttributeList
 *
 * DESCRIPTION
 *     Initialize attribute list
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_create_update_flag         Create update flag.
 *     p_new_rec                    New person record.
 *     p_old_rec                    Old person record.
 *   OUT:
 *     x_name_list                  A list of attribute name. The attribute should
 *                                  be a restricted attribute (i.e. defined in setup
 *                                  tables) and it should not be null in creation and
 *                                  it should be updated in update.
 *     x_new_value_is_null_list     Is 'Y' if the restricted column in the new record
 *                                  has null value.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 */

PROCEDURE initAttributeList (
  p_create_update_flag              IN     VARCHAR2,
  p_new_rec                         IN     HZ_PARTY_V2PUB.PERSON_REC_TYPE,
  p_old_rec                         IN     HZ_PARTY_V2PUB.PERSON_REC_TYPE,
  x_name_list                       OUT    NOCOPY HZ_MIXNM_UTILITY.INDEXVARCHAR30List,
  x_new_value_is_null_list          OUT    NOCOPY HZ_MIXNM_UTILITY.INDEXVARCHAR1List
);

/**
 * PROCEDURE getColumnNullProperty
 *
 * DESCRIPTION
 *     Return null property of attributes in person record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_sst_rec                    SST person record.
 *   OUT:
 *     x_value_is_null_list         Is 'Y' if the restricted column in the SST record
 *                                  has null value.
 *     x_value_is_not_null_list     Is 'Y' if the restricted column in the new record
 *                                  has not-null value.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 */

PROCEDURE getColumnNullProperty (
  p_sst_rec                         IN     HZ_PARTY_V2PUB.PERSON_REC_TYPE,
  x_value_is_null_list              OUT    NOCOPY HZ_MIXNM_UTILITY.INDEXVARCHAR1List,
  x_value_is_not_null_list          OUT    NOCOPY HZ_MIXNM_UTILITY.INDEXVARCHAR1List
);

/**
 * PROCEDURE createSSTRecord
 *
 * DESCRIPTION
 *     Create SST record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_new_data_source            New data source type.
 *     p_new_rec                    New person record.
 *   IN/OUT:
 *     p_sst_rec                    SST person record.
 *     p_updateable_flag_list       A list of updateable property.
 *     p_exception_type_list        A list of exception type.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 */

PROCEDURE createSSTRecord (
  p_new_data_source                 IN     VARCHAR2,
  p_new_rec                         IN     HZ_PARTY_V2PUB.PERSON_REC_TYPE,
  p_sst_rec                         IN OUT NOCOPY HZ_PARTY_V2PUB.PERSON_REC_TYPE,
  p_updateable_flag_list            IN OUT NOCOPY HZ_MIXNM_UTILITY.INDEXVARCHAR1List,
  p_exception_type_list             IN OUT NOCOPY HZ_MIXNM_UTILITY.INDEXVARCHAR30List
);

/**
 * PROCEDURE updateSSTRecord
 *
 * DESCRIPTION
 *     Update SST record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_new_data_source            New data source type.
 *     p_new_rec                    New person record.
 *     p_new_value_is_null_list     Is 'Y' if the restricted column in the new record
 *                                  has null value.
 *   IN/OUT:
 *     p_sst_rec                    SST person record.
 *     p_updateable_flag_list       A list of updateable property.
 *     p_exception_type_list        A list of exception type.
 *     x_data_source_list           Data source list.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 */

PROCEDURE updateSSTRecord (
-- Bug 4201309 : add parameter p_create_update_flag
  p_create_update_flag              IN     VARCHAR2,
  p_new_data_source                 IN     VARCHAR2,
  p_new_rec                         IN     HZ_PARTY_V2PUB.PERSON_REC_TYPE,
  p_sst_rec                         IN OUT NOCOPY HZ_PARTY_V2PUB.PERSON_REC_TYPE,
  p_updateable_flag_list            IN OUT NOCOPY HZ_MIXNM_UTILITY.INDEXVARCHAR1List,
  p_exception_type_list             IN OUT NOCOPY HZ_MIXNM_UTILITY.INDEXVARCHAR30List,
  p_new_value_is_null_list          IN     HZ_MIXNM_UTILITY.INDEXVARCHAR1List,
  x_data_source_list                OUT    NOCOPY HZ_MIXNM_UTILITY.INDEXVARCHAR30List
);

/**
 * PROCEDURE initAttributeList
 *
 * DESCRIPTION
 *     Initialize attribute list
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_create_update_flag         Create update flag.
 *     p_new_rec                    New organization record.
 *     p_old_rec                    Old organization record.
 *   OUT:
 *     x_name_list                  A list of attribute name. The attribute should
 *                                  be a restricted attribute (i.e. defined in setup
 *                                  tables) and it should not be null in creation and
 *                                  it should be updated in update.
 *     x_new_value_is_null_list     Is 'Y' if the restricted column in the new record
 *                                  has null value.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 */

PROCEDURE initAttributeList (
  p_create_update_flag              IN     VARCHAR2,
  p_new_rec                         IN     HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
  p_old_rec                         IN     HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
  x_name_list                       OUT    NOCOPY HZ_MIXNM_UTILITY.INDEXVARCHAR30List,
  x_new_value_is_null_list          OUT    NOCOPY HZ_MIXNM_UTILITY.INDEXVARCHAR1List
);

/**
 * PROCEDURE getColumnNullProperty
 *
 * DESCRIPTION
 *     Return null property of attributes in organization record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_sst_rec                    SST organization record.
 *   OUT:
 *     x_value_is_null_list         Is 'Y' if the restricted column in the SST record
 *                                  has null value.
 *     x_value_is_not_null_list     Is 'Y' if the restricted column in the new record
 *                                  has not-null value.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang    o Created
 */

PROCEDURE getColumnNullProperty (
  p_sst_rec                         IN     HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
  x_value_is_null_list              OUT    NOCOPY HZ_MIXNM_UTILITY.INDEXVARCHAR1List,
  x_value_is_not_null_list          OUT    NOCOPY HZ_MIXNM_UTILITY.INDEXVARCHAR1List
);

/**
 * PROCEDURE createSSTRecord
 *
 * DESCRIPTION
 *     Create SST record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_new_data_source            New data source type.
 *     p_new_rec                    New organization record.
 *   IN/OUT:
 *     p_sst_rec                    SST organization record.
 *     p_updateable_flag_list       A list of updateable property.
 *     p_exception_type_list        A list of exception type.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 */

PROCEDURE createSSTRecord (
  p_new_data_source                 IN     VARCHAR2,
  p_new_rec                         IN     HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
  p_sst_rec                         IN OUT NOCOPY HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
  p_updateable_flag_list            IN OUT NOCOPY HZ_MIXNM_UTILITY.INDEXVARCHAR1List,
  p_exception_type_list             IN OUT NOCOPY HZ_MIXNM_UTILITY.INDEXVARCHAR30List
);

/**
 * PROCEDURE updateSSTRecord
 *
 * DESCRIPTION
 *     Update SST record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_new_data_source            New data source type.
 *     p_new_rec                    New organization record.
 *     p_new_value_is_null_list     Is 'Y' if the restricted column in the new record
 *                                  has null value.
 *   IN/OUT:
 *     p_sst_rec                    SST organization record.
 *     p_updateable_flag_list       A list of updateable property.
 *     p_exception_type_list        A list of exception type.
 *     x_data_source_list           Data source list.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 */

PROCEDURE updateSSTRecord (
-- Bug 4201309 : add parameter p_create_update_flag
  p_create_update_flag              IN     VARCHAR2,
  p_new_data_source                 IN     VARCHAR2,
  p_new_rec                         IN     HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
  p_sst_rec                         IN OUT NOCOPY HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
  p_updateable_flag_list            IN OUT NOCOPY HZ_MIXNM_UTILITY.INDEXVARCHAR1List,
  p_exception_type_list             IN OUT NOCOPY HZ_MIXNM_UTILITY.INDEXVARCHAR30List,
  p_new_value_is_null_list          IN     HZ_MIXNM_UTILITY.INDEXVARCHAR1List,
  x_data_source_list                OUT    NOCOPY HZ_MIXNM_UTILITY.INDEXVARCHAR30List
);

END HZ_MIXNM_API_DYNAMIC_PKG;

 

/
