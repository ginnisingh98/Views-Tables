--------------------------------------------------------
--  DDL for Package HZ_MIXNM_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_MIXNM_UTILITY" AUTHID CURRENT_USER AS
/*$Header: ARHXUTLS.pls 120.6.12010000.2 2009/08/14 07:18:55 rgokavar ship $ */

--------------------------------------------------------------------------
-- declaration of user defined type
--------------------------------------------------------------------------

TYPE INDEXVARCHAR30List IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE INDEXVARCHAR1List IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;

--------------------------------------------------------------------------
-- declaration of public procedures and functions
--------------------------------------------------------------------------

/**
 * FUNCTION FindDataSource
 *
 * DESCRIPTION
 *    Finds real data source based on content_source_type
 *    and actual_content_source. This is for backward
 *    compatibility because even the content_source_type is
 *    obsolete, we can not assume user will not pass the
 *    value into this column anymore.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_content_source_type        Value of obsolete column content_source_type
 *     p_actual_content_source      Value of new column actual_content_source
 *     p_def_actual_content_source  Default value of new column actual_content_source
 *   OUT:
 *     x_data_source_from           Column name of where real data source is from.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang   o Created.
 */

FUNCTION FindDataSource (
    p_content_source_type           IN     VARCHAR2,
    p_actual_content_source         IN     VARCHAR2,
    p_def_actual_content_source     IN     VARCHAR2,
    x_data_source_from              OUT    NOCOPY VARCHAR2
) RETURN VARCHAR2;

/**
 * FUNCTION CheckUserCreationPrivilege
 *
 * DESCRIPTION
 *   Check if user has privilege to create user entered data when
 *   after mix-n-match is enabled.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_entity_name                Entity name. Can not be party profiles.
 *     p_entity_attr_id             Entity id. Entity id is used only for
 *                                  performance consideration. It can speed
 *                                  the query if it is passed.
 *     p_mixnmatch_enabled          'Y'/'N' flag to indicate if mix-n-match
 *                                  if enabled for this entity. You can get
 *                                  the info. via HZ_MIXNM_UTILITY.
 *     p_actual_content_source      Actual content source.
 *   OUT:
 *     x_return_status              Return FND_API.G_RET_STS_ERROR if the
 *                                  user under this site/application/
 *                                  responsibility is not allowed to create
 *                                  user-entered data for this entity.
 *
 * NOTES
 *   The procedure can only be called for other entities like HZ_CONTACT_POINTS,
 *   HZ_LOCATIONS etc. It can not be called on party profiles HZ_ORGANIZATION_PROFILES,
 *   HZ_PERSON_PROFILES.
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang   o Created.
 */
/**
 * FUNCTION CheckUserCreationPrivilege
 *
 * DESCRIPTION
 *   Check if user has privilege to create user entered data when
 *   after mix-n-match is enabled.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_entity_name                Entity name. Can not be party profiles.
 *     p_entity_attr_id             Entity id. Entity id is used only for
 *                                  performance consideration. It can speed
 *                                  the query if it is passed.
 *     p_mixnmatch_enabled          'Y'/'N' flag to indicate if mix-n-match
 *                                  if enabled for this entity. You can get
 *                                  the info. via HZ_MIXNM_UTILITY.
 *     p_actual_content_source      Actual content source.
 *   OUT:
 *     x_return_status              Return FND_API.G_RET_STS_ERROR if the
 *                                  user under this site/application/
 *                                  responsibility is not allowed to create
 *                                  user-entered data for this entity.
 *
 * NOTES
 *   The procedure can only be called for other entities like HZ_CONTACT_POINTS,
 *   HZ_LOCATIONS etc. It can not be called on party profiles HZ_ORGANIZATION_PROFILES,
 *   HZ_PERSON_PROFILES.
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang      o Created.
 */

PROCEDURE CheckUserCreationPrivilege (
    p_entity_name                   IN     VARCHAR2,
    p_entity_attr_id                IN OUT NOCOPY NUMBER,
    p_mixnmatch_enabled             IN     VARCHAR2,
    p_actual_content_source         IN     VARCHAR2,
    x_return_status                 IN OUT NOCOPY VARCHAR2
);

/**
 * FUNCTION CheckUserUpdatePrivilege
 *
 * DESCRIPTION
 *   Check if user has privilege to update a third party record.
 *

 + SSM SST Integration and Extension                                                         +
 + This procedure will also be called for checking update privilege for other source systems'+
 +                                                                                           +

 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_actual_content_source      Actual content source.
 *   OUT:
 *     x_return_status              Return FND_API.G_RET_STS_ERROR if the
 *                                  user under this site/application/
 *                                  responsibility is not allowed to create
 *                                  user-entered data for this entity.
 *
 * NOTES
 *   The procedure can only be called for other entities like HZ_CONTACT_POINTS,
 *   HZ_LOCATIONS etc.
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang       o Created.
 *   12-20-2004    Rajib Ranjan Borah   o SSM SST Integration and Extension.
 *                                        Added parameters p_entity_name,
 *                                        p_new_actual_content_source
 */

PROCEDURE CheckUserUpdatePrivilege (
    p_actual_content_source         IN     VARCHAR2,
    p_new_actual_content_source     IN     VARCHAR2,
    p_entity_name                   IN     VARCHAR2,
    x_return_status                 IN OUT NOCOPY VARCHAR2
);

/**
 * FUNCTION isDataSourceSelected
 *
 * DESCRIPTION
 *   Internal use only!!!
 *   Return 'Y' if the data source has been selected.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_selected_datasources       A list of selected data sources. You can
 *                                  get it via HZ_MIXNM_UTILITY.
 *     p_actual_content_source      Actual content source.
 *
 * NOTES
 *   The procedure can only be called for other entities like HZ_CONTACT_POINTS,
 *   HZ_LOCATIONS etc. It can not be called on party profiles HZ_ORGANIZATION_PROFILES,
 *   HZ_PERSON_PROFILES.
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang   o Created.
 */

FUNCTION isDataSourceSelected(
--  p_selected_datasources          IN     VARCHAR2,
    p_entity_name                   IN     VARCHAR2,
    p_actual_content_source         IN     VARCHAR2
) RETURN VARCHAR2;

/**
 * FUNCTION ValidateContentSource
 *
 * DESCRIPTION
 *   Validate content source type.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_api_version                API version. 'V1' is for V1 API. 'V2' is for V2 API.
 *     p_create_update_flag         Create or update flag. 'C' is for create. 'U' is for
 *                                  update.
 *     p_check_update_privilege     Check if user has privilege to update third party data.
 *     p_content_source_type        Content source type.
 *     p_old_content_source_type    Old content source type.
 *     p_actual_content_source      Actual content source.
 *     p_old_actual_content_source  Old actual content source.
 *   IN/OUT:
 *     x_return_status              Return FND_API.G_RET_STS_ERROR if the
 *                                  user under this site/application/
 *                                  responsibility is not allowed to create
 *                                  user-entered data for this entity.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang       o Created.
 *   01-03-2005    Rajib Ranjan Borah   o SSM SST Integration and Extension.
 *                                        Added parameter p_entity_name.
 */

PROCEDURE ValidateContentSource (
    p_api_version                   IN     VARCHAR2,
    p_create_update_flag            IN     VARCHAR2,
    p_check_update_privilege        IN     VARCHAR2 := 'Y',
    p_content_source_type           IN     VARCHAR2,
    p_old_content_source_type       IN     VARCHAR2 := NULL,
    p_actual_content_source         IN     VARCHAR2,
    p_old_actual_content_source     IN     VARCHAR2 := NULL,
    p_entity_name                   IN     VARCHAR2,
    x_return_status                 IN OUT NOCOPY VARCHAR2
);

/**
 * FUNCTION AssignDataSourceDuringCreation
 *
 * DESCRIPTION
 *   Assign data source during entity creation. Check validity of the data
 *   source and check if user has privilege to create user-entered data.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_entity_name                Entity name. Can not be party profiles.
 *     p_entity_attr_id             Entity id. Entity id is used only for
 *                                  performance consideration. It can speed
 *                                  the query if it is passed.
 *     p_mixnmatch_enabled          'Y'/'N' flag to indicate if mix-n-match
 *                                  if enabled for this entity. You can get
 *                                  the info. via HZ_MIXNM_UTILITY.
 *     p_selected_datasources       A list of selected data sources. You can
 *                                  get it via HZ_MIXNM_UTILITY.
 *     p_content_source_type        Content source type.
 *     p_actual_content_source      Actual content source.
 *   OUT:
 *     x_is_datasource_selected     Return 'Y'/'N' to indicate if the data
 *                                  source is visible.
 *     x_return_status              Return FND_API.G_RET_STS_ERROR if any
 *                                  validation fails.
 *
 * NOTES
 *   The procedure can only be called for other entities like HZ_CONTACT_POINTS,
 *   HZ_LOCATIONS etc. It can not be called on party profiles HZ_ORGANIZATION_PROFILES,
 *   HZ_PERSON_PROFILES.
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang   o Created.
 */

PROCEDURE AssignDataSourceDuringCreation (
    p_entity_name                   IN     VARCHAR2,
    p_entity_attr_id                IN OUT NOCOPY NUMBER,
    p_mixnmatch_enabled             IN     VARCHAR2,
    p_selected_datasources          IN     VARCHAR2,
    p_content_source_type           IN OUT NOCOPY VARCHAR2,
    p_actual_content_source         IN OUT NOCOPY VARCHAR2,
    x_is_datasource_selected        OUT    NOCOPY VARCHAR2,
    x_return_status                 IN OUT NOCOPY VARCHAR2,
    p_api_version                   IN     VARCHAR2 := 'V2'
);

/**
 * FUNCTION isMixNMatchEnabled
 *
 * DESCRIPTION
 *    Is mix-n-match is enabled in the given entity.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_entity_name                 Entity name.
 *     p_called_from_policy_function A flag to indicate if the procedure is called
 *                                   from policy function.
 *   IN/OUT:
 *     p_entity_attr_id              Entity Id.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 */

FUNCTION isMixNMatchEnabled (
    p_entity_name                   IN     VARCHAR2,
    p_entity_attr_id                IN OUT NOCOPY NUMBER,
    p_called_from_policy_function   IN     VARCHAR2 := 'N'
) RETURN VARCHAR2;

/**
 * PROCEDURE updateSSTProfile
 *
 * DESCRIPTION
 *    Return new SST record to create / update SST profile.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_create_update_flag         Create update flag.
 *     p_create_update_sst_flag     Create update SST profile flag.
 *     p_raise_error_flag           Raise error flag.
 *     p_party_type                 Party type.
 *     p_party_id                   Party Id.
 *     p_new_person_rec             New person record.
 *     p_old_person_rec             New person record.
 *     p_sst_person_rec             Current SST person record.
 *     p_new_organization_rec       New organization record.
 *     p_old_organization_rec       New organization record.
 *     p_sst_organization_rec       Current SST organization record.
 *     p_data_source_type           Comming data source type.
 *   IN/OUT:
 *     p_new_sst_person_rec         New SST person record.
 *     p_new_sst_organization_rec   New SST organization record.
 *     x_return_status              Return status.
 *
 * NOTES
 *   The procedure should only be called if the mix-n-match is enable for
 *   the entity.
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 */

PROCEDURE updateSSTProfile (
    p_create_update_flag            IN     VARCHAR2,
    p_create_update_sst_flag        IN     VARCHAR2,
    p_raise_error_flag              IN     VARCHAR2,
    p_party_type                    IN     VARCHAR2,
    p_party_id                      IN     NUMBER,
    p_new_person_rec                IN     HZ_PARTY_V2PUB.PERSON_REC_TYPE
                                             DEFAULT HZ_PARTY_V2PUB.G_MISS_PERSON_REC,
    p_old_person_rec                IN     HZ_PARTY_V2PUB.PERSON_REC_TYPE
                                             DEFAULT HZ_PARTY_V2PUB.G_MISS_PERSON_REC,
    p_sst_person_rec                IN     HZ_PARTY_V2PUB.PERSON_REC_TYPE,
    p_new_sst_person_rec            IN OUT NOCOPY HZ_PARTY_V2PUB.PERSON_REC_TYPE,
    p_new_organization_rec          IN     HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE
                                             DEFAULT HZ_PARTY_V2PUB.G_MISS_ORGANIZATION_REC,
    p_old_organization_rec          IN     HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE
                                             DEFAULT HZ_PARTY_V2PUB.G_MISS_ORGANIZATION_REC,
    p_sst_organization_rec          IN     HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
    p_new_sst_organization_rec      IN OUT NOCOPY HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
    p_data_source_type              IN     VARCHAR2,
    x_return_status                 IN OUT NOCOPY VARCHAR2
);

/**
 * PROCEDURE updateSSTPerProfile
 *
 * DESCRIPTION
 *    Return new SST record to create / update person SST profile.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_create_update_flag         Create update flag.
 *     p_create_update_sst_flag     Create update SST profile flag.
 *     p_raise_error_flag           Raise error flag.
 *     p_party_type                 Party type.
 *     p_party_id                   Party Id.
 *     p_new_person_rec             New person record.
 *     p_old_person_rec             New person record.
 *     p_sst_person_rec             Current SST person record.
 *     p_data_source_type           Comming data source type.
 *   IN/OUT:
 *     p_new_sst_person_rec         New SST person record.
 *     x_return_status              Return status.
 *
 * NOTES
 *   The procedure should only be called if the mix-n-match is enable for
 *   the entity.
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 */

PROCEDURE updatePerSSTProfile (
    p_create_update_flag            IN     VARCHAR2,
    p_create_update_sst_flag        IN     VARCHAR2,
    p_raise_error_flag              IN     VARCHAR2,
    p_party_id                      IN     NUMBER,
    p_new_person_rec                IN     HZ_PARTY_V2PUB.PERSON_REC_TYPE
                                             DEFAULT HZ_PARTY_V2PUB.G_MISS_PERSON_REC,
    p_old_person_rec                IN     HZ_PARTY_V2PUB.PERSON_REC_TYPE
                                             DEFAULT HZ_PARTY_V2PUB.G_MISS_PERSON_REC,
    p_sst_person_rec                IN     HZ_PARTY_V2PUB.PERSON_REC_TYPE,
    p_new_sst_person_rec            IN OUT NOCOPY HZ_PARTY_V2PUB.PERSON_REC_TYPE,
    p_data_source_type              IN     VARCHAR2,
    x_return_status                 IN OUT NOCOPY VARCHAR2
);

/**
 * PROCEDURE updateSSTOrgProfile
 *
 * DESCRIPTION
 *    Return new SST record to create / update organization SST profile.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_create_update_flag         Create update flag.
 *     p_create_update_sst_flag     Create update SST profile flag.
 *     p_raise_error_flag           Raise error flag.
 *     p_party_type                 Party type.
 *     p_party_id                   Party Id.
 *     p_new_organization_rec       New organization record.
 *     p_old_organization_rec       New organization record.
 *     p_sst_organization_rec       Current SST organization record.
 *     p_data_source_type           Comming data source type.
 *   IN/OUT:
 *     p_new_sst_organization_rec   New SST organization record.
 *     x_return_status              Return status.
 *
 * NOTES
 *   The procedure should only be called if the mix-n-match is enable for
 *   the entity.
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 */

PROCEDURE updateOrgSSTProfile (
    p_create_update_flag            IN     VARCHAR2,
    p_create_update_sst_flag        IN     VARCHAR2,
    p_raise_error_flag              IN     VARCHAR2,
    p_party_id                      IN     NUMBER,
    p_new_organization_rec          IN     HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE
                                             DEFAULT HZ_PARTY_V2PUB.G_MISS_ORGANIZATION_REC,
    p_old_organization_rec          IN     HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE
                                             DEFAULT HZ_PARTY_V2PUB.G_MISS_ORGANIZATION_REC,
    p_sst_organization_rec          IN     HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
    p_new_sst_organization_rec      IN OUT NOCOPY HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE,
    p_data_source_type              IN     VARCHAR2,
    x_return_status                 IN OUT NOCOPY VARCHAR2
);

/**
 * PROCEDURE getDictIndexedNameList
 *
 * DESCRIPTION
 *    Split a new list into non-restricted attributes list and restricted
 *    attributes list.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_entity_name                Entity name.
 *     p_name_list                  Attribute name list.
 *   OUT:
 *     x_restricted_name_list       Restricted attributes' name list.
 *     x_nonrestricted_name_list    Non-Restricted attributes' name list.
 *
 * NOTES
 *   The procedure should only be called if the mix-n-match is enable for
 *   the entity.
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 */

PROCEDURE getDictIndexedNameList (
    p_entity_name                   IN     VARCHAR2,
    p_name_list                     IN     INDEXVARCHAR30List,
    x_restricted_name_list          OUT    NOCOPY INDEXVARCHAR30List,
    x_nonrestricted_name_list       OUT    NOCOPY INDEXVARCHAR30List
);

/**
 * PROCEDURE areSSTColumnsUpdeable
 *
 * DESCRIPTION
 *    Return a list to indicate which SST attributes are updatable and which are not.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_party_id                   Party Id.
 *     p_entity_name                Entity name.
 *     p_attribute_name_list        Attribute name list.
 *     p_value_is_null_list         'Y' if the corresponding SST column is null.
 *     p_data_source_type           Comming data source.
 *     p_raise_error_flag           Raise error flag.
 *     p_known_dict_id              'Y' if use knew entity id.
 *   IN/OUT:
 *     x_return_status              Return status.
 *   OUT:
 *     x_updatable_flag_list        Updatable list.
 *
 * NOTES
 *   The procedure should only be called if the mix-n-match is enable for
 *   the entity.
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 */

PROCEDURE areSSTColumnsUpdeable (
    p_party_id                      IN     NUMBER,
    p_entity_name                   IN     VARCHAR2,
    p_attribute_name_list           IN     INDEXVARCHAR30List,
    p_value_is_null_list            IN     INDEXVARCHAR1List,
    p_data_source_type              IN     VARCHAR2 := 'SST',
    x_updatable_flag_list           OUT    NOCOPY INDEXVARCHAR1List,
    x_return_status                 IN OUT NOCOPY VARCHAR2,
    p_raise_error_flag              IN     VARCHAR2 DEFAULT 'N',
    p_known_dict_id                 IN     VARCHAR2 DEFAULT 'N'
);

/**
 * PROCEDURE LoadDataSources
 *
 * DESCRIPTION
 *    Load data sources for a given entity.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_entity_name                 Entity name.
 *     p_called_from_policy_function A flag to indicate if the procedure is called
 *                                   from policy function.
 *   IN/OUT:
 *     p_entity_attr_id              Entity Id.
 *     p_mixnmatch_enabled           If the mix-n-match is enabled for this entity.
 *     p_selected_datasources        Select data sources for this entity.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 */

PROCEDURE LoadDataSources (
    p_entity_name                   IN     VARCHAR2,
    p_entity_attr_id                IN OUT NOCOPY NUMBER,
    p_mixnmatch_enabled             IN OUT NOCOPY VARCHAR2,
    p_selected_datasources          IN OUT NOCOPY VARCHAR2,
    p_called_from_policy_function   IN     VARCHAR2 := 'N'
);

/**
 * FUNCTION getSelectedDataSources
 *
 * DESCRIPTION
 *    Return selected data sources for a given entity. The
 *    function is created for policy function. For anywhere
 *    else, you should call LoadDataSources.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_entity_name                Entity name.
 *   IN/OUT:
 *     p_entity_attr_id             Entity Id.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 */

FUNCTION getSelectedDataSources (
    p_entity_name                   IN     VARCHAR2,
    p_entity_attr_id                IN OUT NOCOPY NUMBER
) RETURN VARCHAR2;

/**
 * FUNCTION isEntityUserCreatable
 *
 * DESCRIPTION
 *    Return if user can create user-entered data.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_entity_name                Entity name.
 *   IN/OUT:
 *     p_entity_attr_id             Entity Id.
 *
 * NOTES
 *   The procedure should only be called if the mix-n-match is enable for
 *   the entity.
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 */

FUNCTION isEntityUserCreatable (
    p_entity_name                   IN     VARCHAR2,
    p_entity_attr_id                IN OUT NOCOPY NUMBER
) RETURN VARCHAR2;

--------------------------------------------------------------------------
-- the following procedures are called by mix-n-match concurrent program.
--------------------------------------------------------------------------

/**
 * PROCEDURE conc_main
 *
 * DESCRIPTION
 *   Main concurrent program for mix-n-match.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * IN:
 *   p_commit_size                  Commit size.
 *   p_num_of_worker                Number of workers.
 * OUT:
 *   errbuf                         Buffer for error message.
 *   retcode                        Return code.
 *
 * MODIFICATION HISTORY
 *
 *   04-30-2002    Jianying Huang   o Created.
 *   12-08-2009    Sudhir Gokavarapu  o Bug8651628
 *                                      Added p_run_mode parameter to conc_main procedure.
 */

PROCEDURE conc_main (
    errbuf                          OUT NOCOPY    VARCHAR2,
    retcode                         OUT NOCOPY    VARCHAR2,
    p_commit_size                   IN     VARCHAR2,
    p_num_of_worker                 IN     VARCHAR2,
 	p_run_mode                      IN     VARCHAR2 DEFAULT 'REGENERATE_SST'
);

/**
 * PROCEDURE conc_sub
 *
 * DESCRIPTION
 *   Sub concurrent program for mix-n-match.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * IN:
 *   p_entity_type                  Entity type.
 *   p_from_id                      From id.
 *   p_to_id                        To id.
 *   p_commit_size                  Commit size.
 * OUT:
 *   errbuf                         Buffer for error message.
 *   retcode                        Return code.
 *
 * MODIFICATION HISTORY
 *
 *   04-30-2002    Jianying Huang   o Created.
 */

PROCEDURE conc_sub (
    errbuf                          OUT NOCOPY   VARCHAR2,
    retcode                         OUT NOCOPY   VARCHAR2,
    p_entity_type                   IN     VARCHAR2,
    p_from_id                       IN     VARCHAR2,
    p_to_id                         IN     VARCHAR2,
    p_commit_size                   IN     VARCHAR2
);

/**
 * PROCEDURE
 *     create_exceptions
 *
 * DESCRIPTION
 *     Creates records in HZ_WIN_SOURCE_EXCEPTIONS when a party (organization/ person)
 *     is created from non-user_entered source systems and no prior user-entered profile
 *     exist for that party.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     HZ_MIXNM_API_DYNAMIC_PKG.initAttributeList
 *     HZ_MIXNM_UTILITY.cacheSetupForPartyProfiles
 *     HZ_MIXNM_UTILITY.getEntityAttrId
 *     HZ_MIXNM_UTILITY.getDataSourceRanking
 *
 * ARGUMENTS
 *   IN:
 *     p_party_type                Either 'ORGANIZATION' or 'PERSON'
 *     p_organization_rec
 *     p_person_rec
 *     p_third_party_content_source
 *     p_party_id
 *   OUT:
 *
 * NOTES
 *     This will be called only from HZ_PARTY_V2PUB.do_create_party.
 *     And only when a new party is created by a non-user_entered source system.
 *
 * MODIFICATION HISTORY
 *
 *   12-30-2004    Rajib Ranjan Borah  o SSM SST Integration and Extension. Created.
 *
 */

PROCEDURE create_exceptions (
  p_party_type                   IN      VARCHAR2,
  p_organization_rec             IN      HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE
                           DEFAULT       HZ_PARTY_V2PUB.G_MISS_ORGANIZATION_REC,
  p_person_rec                   IN      HZ_PARTY_V2PUB.PERSON_REC_TYPE
                           DEFAULT       HZ_PARTY_V2PUB.G_MISS_PERSON_REC,
  p_third_party_content_source   IN      VARCHAR2,
  p_party_id                     IN      NUMBER
);

Procedure populateMRRExc(
	p_entity_name                   IN     VARCHAR2,
	p_data_source_type              IN     VARCHAR2,
	p_party_id			IN	NUMBER
);

Function getUserRestriction(
	p_entity_attr_id IN NUMBER
) Return VARCHAR2;

Function getUserOverwrite(
        p_entity_attr_id IN NUMBER,
        p_rule_id        IN NUMBER
) Return VARCHAR2;


Function getGroupMeaningList(
	p_entity IN VARCHAR2,
        p_group IN VARCHAR2
) Return VARCHAR2;

END HZ_MIXNM_UTILITY;

/
