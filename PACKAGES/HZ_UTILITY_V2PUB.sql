--------------------------------------------------------
--  DDL for Package HZ_UTILITY_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_UTILITY_V2PUB" AUTHID CURRENT_USER AS
/*$Header: ARH2UTSS.pls 120.26.12010000.2 2009/02/10 13:00:50 ajaising ship $ */

--------------------------------------
-- public procedures and functions
--------------------------------------

/**
 * PROCEDURE validate_mandatory
 *
 * DESCRIPTION
 *     Validate mandatory field.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_create_update_flag           'C' ( create mode ), 'U' ( update mode )
 *     p_column                       Column name you want to validate.
 *     p_column_value                 Column value
 *     p_restriced                    If set to 'Y', p_column_value should be passed
 *                                    in with some value in both create and update
 *                                    mode. If set to 'N', p_column_value can be
 *                                    NULL in update mode. Default is 'N'.
 *   IN/OUT:
 *     x_return_status                Return status.
 *
 * NOTES
 *     The procedure is overloaded for different column type, i.e. VARCHAR2,
 *     NUMBER, and DATE.
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

G_CREATED_BY_MODULE          VARCHAR2(30);
G_CALLING_API                VARCHAR2(10);
G_EXECUTE_API_CALLOUTS       CONSTANT VARCHAR2(255) := FND_PROFILE.VALUE('HZ_EXECUTE_API_CALLOUTS');
--  Bug 4693719
G_UPDATE_ACS                 VARCHAR2(1);

PROCEDURE validate_mandatory (
    p_create_update_flag                    IN     VARCHAR2,
    p_column                                IN     VARCHAR2,
    p_column_value                          IN     VARCHAR2,
    p_restricted                            IN     VARCHAR2 DEFAULT 'N',
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

PROCEDURE validate_mandatory (
    p_create_update_flag                    IN     VARCHAR2,
    p_column                                IN     VARCHAR2,
    p_column_value                          IN     NUMBER,
    p_restricted                            IN     VARCHAR2 DEFAULT 'N',
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

PROCEDURE validate_mandatory (
    p_create_update_flag                    IN     VARCHAR2,
    p_column                                IN     VARCHAR2,
    p_column_value                          IN     DATE,
    p_restricted                            IN     VARCHAR2 DEFAULT 'N',
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

/**
 * PROCEDURE validate_nonupdateable
 *
 * DESCRIPTION
 *     Validate nonupdateable field.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_column                       Column name you want to validate.
 *     p_column_value                 Column value
 *     p_old_column_value             Current database column value
 *     p_restriced                    If set to 'Y', column can not be updated
 *                                    even the database value is null. This is
 *                                    default value and as long as p_column_value
 *                                    is not equal to p_old_column_error, return
 *                                    status will be set to error.
 *                                    If set to 'N', if database value is null,
 *                                    we can update it to a value. If database value
 *                                    is not null and if p_column_value is not equal
 *                                    to p_old_column_value, return status will be
 *                                    set to error.
 *   IN/OUT:
 *     x_return_status                Return status.
 *
 * NOTES
 *     The procedure is overloaded for different column type, i.e. VARCHAR2,
 *     NUMBER, and DATE. The procedure should be called in update mode.
 *
 *     For example:
 *         IF p_create_update_flag = 'U' THEN
 *             validate_nonupdateable( ... );
 *         END IF;
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE validate_nonupdateable (
    p_column                                IN     VARCHAR2,
    p_column_value                          IN     VARCHAR2,
    p_old_column_value                      IN     VARCHAR2,
    p_restricted                            IN     VARCHAR2 DEFAULT 'Y',
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

PROCEDURE validate_nonupdateable (
    p_column                                IN     VARCHAR2,
    p_column_value                          IN     NUMBER,
    p_old_column_value                      IN     NUMBER,
    p_restricted                            IN     VARCHAR2 DEFAULT 'Y',
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

PROCEDURE validate_nonupdateable (
    p_column                                IN     VARCHAR2,
    p_column_value                          IN     DATE,
    p_old_column_value                      IN     DATE,
    p_restricted                            IN     VARCHAR2 DEFAULT 'Y',
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

/**
 * PROCEDURE validate_start_end_date
 *
 * DESCRIPTION
 *     Validate start data can not be earlier than end date.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_create_update_flag           'C' ( create mode ), 'U' ( update mode )
 *     p_start_date_column_name       Column name of start date
 *     p_start_date                   New start date
 *     p_old_start_date               Database start date in update mode
 *     p_end_date_column_name         Column name of end date
 *     p_end_date                     New end date
 *     p_old_end_date                 Database end date in update mode
 *   IN/OUT:
 *     x_return_status                Return status.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE validate_start_end_date (
    p_create_update_flag                    IN     VARCHAR2,
    p_start_date_column_name                IN     VARCHAR2,
    p_start_date                            IN     DATE,
    p_old_start_date                        IN     DATE,
    p_end_date_column_name                  IN     VARCHAR2,
    p_end_date                              IN     DATE,
    p_old_end_date                          IN     DATE,
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

/**
 * PROCEDURE validate_cannot_update_to_null
 *
 * DESCRIPTION
 *     Validate column cannot be updated to null.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_column                       Column name you want to validate.
 *     p_column_value                 Column value
 *   IN/OUT:
 *     x_return_status                Return status.
 *
 * NOTES
 *     The procedure is overloaded for different column type, i.e. VARCHAR2,
 *     NUMBER, and DATE. The procedure should be called in update mode.
 *
 *     For example:
 *         IF p_create_update_flag = 'U' THEN
 *             validate_cannot_update_to_null( ... );
 *         END IF;
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE validate_cannot_update_to_null (
    p_column                                IN     VARCHAR2,
    p_column_value                          IN     VARCHAR2,
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

PROCEDURE validate_cannot_update_to_null (
    p_column                                IN     VARCHAR2,
    p_column_value                          IN     NUMBER,
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

PROCEDURE validate_cannot_update_to_null (
    p_column                                IN     VARCHAR2,
    p_column_value                          IN     DATE,
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

/**
 * PROCEDURE validate_cannot_update_to_null
 *
 * DESCRIPTION
 *     Validate column cannot be updated to null.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_column                       Column name you want to validate.
 *     p_lookup_table                 Table/view name you want to validate against to.
 *                                    For now, we are supporting
 *                                       AR_LOOKUPS
 *                                       SO_LOOKUPS
 *                                       OE_SHIP_METHODS_V
 *                                       FND_LOOKUP_VALUES
 *                                    Default value is AR_LOOKUPS
 *     p_lookup_type                  Fnd lookup type
 *     p_column_value                 Column value
 *   IN/OUT:
 *     x_return_status                Return status.
 *
 * NOTES
 *     The procedure is using cache strategy for performance improvement.
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE validate_lookup (
    p_column                                IN     VARCHAR2,
    p_lookup_table                          IN     VARCHAR2 DEFAULT 'AR_LOOKUPS',
    p_lookup_type                           IN     VARCHAR2,
    p_column_value                          IN     VARCHAR2,
    x_return_status                         IN OUT NOCOPY VARCHAR2
);

/**
 * PROCEDURE enable_debug
 *
 * DESCRIPTION
 *     Enable file or dbms debug based on profile options.
 *     HZ_API_FILE_DEBUG_ON : Turn on/off file debug, i.e. debug message
 *                            will be written to a user specified file.
 *                            The file name and file path is stored in
 *                            profiles HZ_API_DEBUG_FILE_PATH and
 *                            HZ_API_DEBUG_FILE_NAME. File path must be
 *                            database writable.
 *     HZ_API_DBMS_DEBUG_ON : Turn on/off dbms debug.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE enable_debug;

/**
 * PROCEDURE disable_debug
 *
 * DESCRIPTION
 *     Disable file or dbms debug.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

PROCEDURE disable_debug;

/**
 * PROCEDURE debug
 *
 * DESCRIPTION
 *     Put debug message.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_message                      Message you want to put in log.
 *     p_prefix                       Prefix of the message. Default value is
 *                                    DEBUG.
 *     p_msg_level                    Message Level.Default value is 1 and the value should be between
 *                                    1 and 6 corresponding to FND_LOG's
 *                                    LEVEL_UNEXPECTED CONSTANT NUMBER  := 6;
 *                                    LEVEL_ERROR      CONSTANT NUMBER  := 5;
 *                                    LEVEL_EXCEPTION  CONSTANT NUMBER  := 4;
 *                                    LEVEL_EVENT      CONSTANT NUMBER  := 3;
 *                                    LEVEL_PROCEDURE  CONSTANT NUMBER  := 2;
 *                                    LEVEL_STATEMENT  CONSTANT NUMBER  := 1;
 *     p_module_prefix                Module prefix to store package name,form name.Default value is
 *                                    HZ_Package.
 *     p_module                       Module to store Procedure Name. Default value is HZ_Module.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *   01-Dec-2003   Ramesh Ch           Added p_msg_level,p_module_prefix,p_module parameters
 *                                     with default values as part of Common Logging Infrastrycture Uptake.
 */

PROCEDURE debug (
    p_message                               IN     VARCHAR2,
    p_prefix                                IN     VARCHAR2 DEFAULT 'DEBUG',
    p_msg_level                             IN     NUMBER   DEFAULT FND_LOG.LEVEL_STATEMENT,
    p_module_prefix                         IN     VARCHAR2 DEFAULT 'HZ_Package',
    p_module                                IN     VARCHAR2 DEFAULT 'HZ_Module'
);

/**
 * PROCEDURE debug_return_messages
 *
 * DESCRIPTION
 *     Put debug messages based on message count in message stack.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_msg_count                    Message count in message stack.
 *     p_msg_data                     Message data if message count is 1.
 *     p_msg_type                     Message type used as prefix of the message.
 *
 *     p_msg_level                    Message Level.Default value is 1 and the value should be between
 *                                    1 and 6 corresponding to FND_LOG's
 *                                    LEVEL_UNEXPECTED CONSTANT NUMBER  := 6;
 *                                    LEVEL_ERROR      CONSTANT NUMBER  := 5;
 *                                    LEVEL_EXCEPTION  CONSTANT NUMBER  := 4;
 *                                    LEVEL_EVENT      CONSTANT NUMBER  := 3;
 *                                    LEVEL_PROCEDURE  CONSTANT NUMBER  := 2;
 *                                    LEVEL_STATEMENT  CONSTANT NUMBER  := 1;
 *     p_module_prefix                Module prefix to store package name,form name.Default value is
 *                                    HZ_Package.
 *     p_module                       Module to store Procedure Name. Default value is HZ_Module.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 *   01-Dec-2003   Ramesh Ch           Added p_msg_level,p_module_prefix,p_module parameters
 *                                     with default values as part of Common Logging Infrastrycture Uptake.
 */

PROCEDURE debug_return_messages (
    p_msg_count                             IN     NUMBER,
    p_msg_data                              IN     VARCHAR2,
    p_msg_type                              IN     VARCHAR2 DEFAULT 'ERROR',
    p_msg_level                             IN     NUMBER   DEFAULT FND_LOG.LEVEL_STATEMENT,
    p_module_prefix                         IN     VARCHAR2 DEFAULT 'HZ_Package',
    p_module                                IN     VARCHAR2 DEFAULT 'HZ_Module'
);


/**
 * FUNCTION get_session_process_id
 *
 * DESCRIPTION
 *     Return OS process id of current session.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

FUNCTION get_session_process_id RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES ( get_session_process_id, WNDS, WNPS, RNPS );

/**
 * FUNCTION
 *     created_by
 *     creation_date
 *     last_updated_by
 *     last_update_date
 *     last_update_login
 *     request_id
 *     program_id
 *     program_application_id
 *     program_update_date
 *     user_id
 *
 * DESCRIPTION
 *     Return standard who value.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Jianying Huang      o Created.
 *
 */

FUNCTION created_by RETURN NUMBER;

FUNCTION creation_date RETURN DATE;

FUNCTION last_updated_by RETURN NUMBER;

FUNCTION last_update_date RETURN DATE;

FUNCTION last_update_login RETURN NUMBER;

FUNCTION request_id RETURN NUMBER;

FUNCTION program_id RETURN NUMBER;

FUNCTION program_application_id RETURN NUMBER;

FUNCTION application_id RETURN NUMBER;

FUNCTION program_update_date RETURN DATE;

FUNCTION user_id RETURN NUMBER;

/**
 * FUNCTION incl_unrelated_entities
 *
 * DESCRIPTION
 *   Function to check the value of incl_unrelated_entities flag
 *   for a relationship type. the procedure has been put here to
 *   cache the values so that program does not hit database if the
 *   same relationship type has already been read.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_relationship_type            Relationship type.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   02-02-2002    Indrajit Sen        o Created.
 *
 */

FUNCTION incl_unrelated_entities (
    p_relationship_type                     IN     VARCHAR2
) RETURN VARCHAR2;

/**
 * FUNCTION Get_SchemaName
 *
 * DESCRIPTION
 *     Return Schema's Name By Given The Application's Short Name
 *     The function will raise fnd_api.g_exc_unexpected_error if
 *     the short name can not be found in installation and put a
 *     message '<p_app_short_name> is not a valid oracle schema name.'
 *     in the message stack.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *           p_app_short_name
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang      o Created.
 *
 */

FUNCTION Get_SchemaName (
    p_app_short_name             IN     VARCHAR2
) RETURN VARCHAR2;

/**
 * FUNCTION Get_AppsSchemaName
 *
 * DESCRIPTION
 *     Return APPS Schema's Name
 *     The function will raise fnd_api.g_exc_unexpected_error if
 *     the 'FND' as a short name can not be found in installation.
 *     and put a message 'FND is not a valid oracle schema name.'
 *     in the message stack.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang      o Created.
 *
 */

FUNCTION Get_AppsSchemaName RETURN VARCHAR2;

/**
 * FUNCTION Get_LookupMeaning
 *
 * DESCRIPTION
 *     Get lookup meaning. Return NULL if lookup code does
 *     not exist.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *       p_lookup_table
 *       p_lookup_type
 *       p_lookup_code
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang      o Created.
 *
 */

FUNCTION Get_LookupMeaning (
    p_lookup_table                          IN     VARCHAR2 DEFAULT 'AR_LOOKUPS',
    p_lookup_type                           IN     VARCHAR2,
    p_lookup_code                           IN     VARCHAR2
) RETURN VARCHAR2;

/**
 * FUNCTION Check_ObsoleteColumn
 *
 * DESCRIPTION
 *    Internal use only!!
 *    Set x_return_status to FND_API.G_RET_STS_ERROR when
 *    user is trying to pass value into an obsolete column
 *    in development site.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_api_version                  'V1' is for V1 API. 'V2' is for V2 API.
 *     p_create_update_flag           'C' is for create. 'U' is for update.
 *     p_column                       Column name.
 *     p_column_value                 Value of the column.
 *     p_default_value                Default value of the column. Please note,
 *                                    for V1 API, most columns are defaulted to
 *                                    FND_API.G_MISS_XXX and for V2 API, we do
 *                                    not have default value for most columns.
 *     p_old_column_value             Database value of the column. Only used
 *                                    in update mode.
 *   OUT:
 *     x_return_status                Return FND_API.G_RET_STS_ERROR if user
 *                                    is trying to pass value into an obsolete
 *                                    column in development site.
 *
 * NOTES
 *   I am not making the function as public for now because it is used only by
 *   obsoleting content_source_type. It is worth to call this function only when
 *   you obsolete one column. If you are obsoleting more than one columns, it
 *   is better to cancat them and then decide if need to raise exception. For
 *   this limitation, it is not worth to provide the function for NUMBER and
 *   DATE type of column.
 *
 * MODIFICATION HISTORY
 *
 *   03-01-2002    Jianying Huang      o Created.
 */

PROCEDURE Check_ObsoleteColumn (
    p_api_version                           IN     VARCHAR2,
    p_create_update_flag                    IN     VARCHAR2,
    p_column                                IN     VARCHAR2,
    p_column_value                          IN     VARCHAR2,
    p_default_value                         IN     VARCHAR2 := NULL,
    p_old_column_value                      IN     VARCHAR2 := NULL,
    x_return_status                         IN OUT NOCOPY VARCHAR2
);


/**
 * FUNCTION get_site_use_purpose
 *
 * DESCRIPTION
 *    used by common party UI .
 *    will return the first three site use type

 * ARGUMENTS
 *   IN:
 *     p_party_site_id               party site id used to retrieve the site use purpose.
 *
 *   RETURNS    : VARCHAR2
 *
**/
function get_site_use_purpose (
    p_party_site_id                         IN     NUMBER)
RETURN VARCHAR2;

/**
 * FUNCTION get_all_purposes
 *
 * DESCRIPTION
 *    used by common party UI .
 *    will return all site use types

 * ARGUMENTS
 *   IN:
 *     p_party_site_id               party site id used to retrieve the site use purpose.
 *
 *   RETURNS    : VARCHAR2
 *
**/
function get_all_purposes (
    p_party_site_id                         IN     NUMBER)
RETURN VARCHAR2;

/**
 * FUNCTION get_acct_site_purposes
 *
 * DESCRIPTION
 *    used by common party UI .
 *    will return acct site uses

 * ARGUMENTS
 *   IN:
 *     p_acct_site_id               acct site id used to retrieve the acct site use purpose.
 *
 *   RETURNS    : VARCHAR2
 *
**/
function get_acct_site_purposes (
    p_acct_site_id                         IN     NUMBER)
RETURN VARCHAR2;

/**
 * FUNCTION validate_flex_address
 *
 * DESCRIPTION
 *    used by common party UI .
 *    will validate the flex address
 *    and return 'Y'/'N'
 * ARGUMENTS
 *   IN:
 *     p_context_value : context_value
 *     p_address1 :      address1
 *     p_address2 :      address2
 *     p_address3 :      address3
 *     p_address4 :      address4
 *     p_address_lines_phonetic: address_lines_phonetic
 *     p_city :          city
 *     p_county :        county
 *     p_postal_code :   postal_code
 *     p_province :      province
 *     p_state :         state
 *     p_attribute1 :    attribute1
 *     p_attribute2 :    attribute2
 *     p_attribute3 :    attribute3
 *     p_attribute4 :    attribute4
 *     p_attribute5 :    attribute5
 *     p_attribute6 :    attribute6
 *     p_attribute7 :    attribute7
 *     p_attribute8 :    attribute8
 *     p_attribute9 :    attribute9
 *     p_attribute10:    attribute10
 *     p_attribute11:    attribute11
 *     p_attribute12:    attribute12
 *     p_attribute13:    attribute13
 *     p_attribute14:    attribute14
 *     p_attribute15:    attribute15
 *     p_attribute16:    attribute16
 *     p_attribute17:    attribute17
 *     p_attribute18:    attribute18
 *     p_attribute19:    attribute19
 *     p_attribute20:    attribute20
 *     p_postal_plu4_code :   postal_plu4_code --added against bug 7671107
 *
 *   RETURNS    : VARCHAR2
 *
**/
FUNCTION validate_flex_address (
    p_context_value                               IN     VARCHAR2,
    p_address1                                    IN     VARCHAR2,
    p_address2                                    IN     VARCHAR2,
    p_address3                                    IN     VARCHAR2,
    p_address4                                    IN     VARCHAR2,
    p_address_lines_phonetic                      IN     VARCHAR2,
    p_city                                        IN     VARCHAR2,
    p_county                                      IN     VARCHAR2,
    p_postal_code                                 IN     VARCHAR2,
    p_province                                    IN     VARCHAR2,
    p_state                                       IN     VARCHAR2,
    p_attribute1                                  IN     VARCHAR2,
    p_attribute2                                  IN     VARCHAR2,
    p_attribute3                                  IN     VARCHAR2,
    p_attribute4                                  IN     VARCHAR2,
    p_attribute5                                  IN     VARCHAR2,
    p_attribute6                                  IN     VARCHAR2,
    p_attribute7                                  IN     VARCHAR2,
    p_attribute8                                  IN     VARCHAR2,
    p_attribute9                                  IN     VARCHAR2,
    p_attribute10                                 IN     VARCHAR2,
    p_attribute11                                 IN     VARCHAR2,
    p_attribute12                                 IN     VARCHAR2,
    p_attribute13                                 IN     VARCHAR2,
    p_attribute14                                 IN     VARCHAR2,
    p_attribute15                                 IN     VARCHAR2,
    p_attribute16                                 IN     VARCHAR2,
    p_attribute17                                 IN     VARCHAR2,
    p_attribute18                                 IN     VARCHAR2,
    p_attribute19                                 IN     VARCHAR2,
    p_attribute20                                 IN     VARCHAR2,
    p_postal_plu4_code                            IN     VARCHAR2 --added against bug 7671107

) RETURN VARCHAR2;

/**
 * FUNCTION validate_desc_flex
 *
 * DESCRIPTION
 *    used by common party UI .
 *    will validate the descriptive flex
 *    and return 'Y'/'N'
 * ARGUMENTS
 *   IN:
 *     p_appl_short_name:appl_short_name
 *     p_desc_flex_name :desc_flex_name
 *     p_context_value : context_value
 *     p_attribute1 :    attribute1
 *     p_attribute2 :    attribute2
 *     p_attribute3 :    attribute3
 *     p_attribute4 :    attribute4
 *     p_attribute5 :    attribute5
 *     p_attribute6 :    attribute6
 *     p_attribute7 :    attribute7
 *     p_attribute8 :    attribute8
 *     p_attribute9 :    attribute9
 *     p_attribute10:    attribute10
 *     p_attribute11:    attribute11
 *     p_attribute12:    attribute12
 *     p_attribute13:    attribute13
 *     p_attribute14:    attribute14
 *     p_attribute15:    attribute15
 *     p_attribute16:    attribute16
 *     p_attribute17:    attribute17
 *     p_attribute18:    attribute18
 *     p_attribute19:    attribute19
 *     p_attribute20:    attribute20
 *     p_attribute21:    attribute21
 *     p_attribute22:    attribute22
 *     p_attribute23:    attribute23
 *     p_attribute24:    attribute24
 *   RETURNS    : VARCHAR2
 *
**/
FUNCTION validate_desc_flex (
    p_appl_short_name                             IN     VARCHAR2,
    p_desc_flex_name                              IN     VARCHAR2,
    p_context_value                               IN     VARCHAR2,
    p_attribute1                                  IN     VARCHAR2,
    p_attribute2                                  IN     VARCHAR2,
    p_attribute3                                  IN     VARCHAR2,
    p_attribute4                                  IN     VARCHAR2,
    p_attribute5                                  IN     VARCHAR2,
    p_attribute6                                  IN     VARCHAR2,
    p_attribute7                                  IN     VARCHAR2,
    p_attribute8                                  IN     VARCHAR2,
    p_attribute9                                  IN     VARCHAR2,
    p_attribute10                                 IN     VARCHAR2,
    p_attribute11                                 IN     VARCHAR2,
    p_attribute12                                 IN     VARCHAR2,
    p_attribute13                                 IN     VARCHAR2,
    p_attribute14                                 IN     VARCHAR2,
    p_attribute15                                 IN     VARCHAR2,
    p_attribute16                                 IN     VARCHAR2,
    p_attribute17                                 IN     VARCHAR2,
    p_attribute18                                 IN     VARCHAR2,
    p_attribute19                                 IN     VARCHAR2,
    p_attribute20                                 IN     VARCHAR2,
    p_attribute21                                 IN     VARCHAR2 DEFAULT NULL,
    p_attribute22                                 IN     VARCHAR2 DEFAULT NULL,
    p_attribute23                                 IN     VARCHAR2 DEFAULT NULL,
    p_attribute24                                 IN     VARCHAR2 DEFAULT NULL
) RETURN VARCHAR2;


/**
 * FUNCTION get_primary_email
 *
 * DESCRIPTION
 *    used by common party UI .
 *    added by albert (tsli)
 *    will return the primary email
 * ARGUMENTS
 *   IN:
 *     p_party_id               party id used to retrieve the primary email
 *
 *   RETURNS    : VARCHAR2
 *
**/

function get_primary_email (
    p_party_id                         IN     NUMBER)
RETURN VARCHAR2;

/**
 * FUNCTION get_primary_phone
 *
 * DESCRIPTION
 *    used by common party UI .
 *    added by albert (tsli)
 *    will return the primary phone
 * ARGUMENTS
 *   IN:
 *     p_party_id               party id used to retrieve the primary phone
 *
 *   RETURNS    : VARCHAR2
 *
**/

function get_primary_phone (
    p_party_id                         IN     NUMBER,
    p_display_purpose                  IN     VARCHAR2 := fnd_api.g_true)
RETURN VARCHAR2;


/**
 * FUNCTION get_org_contact_role
 *
 * DESCRIPTION
 *    used by common party UI .
 *    added by albert (tsli)
 *    will return the first three org contact roles

 * ARGUMENTS
 *   IN:
 *     p_org_contact_id               org contact id used to retrieve the org contact roles.
 *
 *   RETURNS    : VARCHAR2
 *
**/

function get_org_contact_role (
    p_org_contact_id                   IN     NUMBER)
RETURN VARCHAR2;

PROCEDURE find_index_name(
                        p_index_name OUT NOCOPY VARCHAR2);

/**
 * FUNCTION GET_YAHOO_MAP_URL
 *
 * DESCRIPTION
 *    function that would return a html link tag which
 *    will contain the address formatted for Yahoo Maps.
 * ARGUMENTS
 *   IN:
 *        address1                IN VARCHAR2,
 *        address2                IN VARCHAR2,
 *        address3                IN VARCHAR2,
 *        address4                IN VARCHAR2,
 *        city                    IN VARCHAR2,
 *        country                 IN VARCHAR2,
 *        state                   IN VARCHAR2,
 *        postal_code             IN VARCHAR2
 *
 *   RETURNS    : VARCHAR2
 *
**/
FUNCTION GET_YAHOO_MAP_URL(address1                IN VARCHAR2,
                           address2                IN VARCHAR2,
                           address3                IN VARCHAR2,
                           address4                IN VARCHAR2,
                           city                    IN VARCHAR2,
                           country                 IN VARCHAR2,
                           state                   IN VARCHAR2,
                           postal_code             IN VARCHAR2)
RETURN VARCHAR2;

/**
 * FUNCTION IS_PARTY_ID_IN_REQUEST_LOG
 *
 * DESCRIPTION
 *    function that would return a 'Y' if this party_id exist in hz_dnb_request_log
 *    return 'N' if not.
 * ARGUMENTS
 *     party_id             IN     NUMBER
 *
 *   RETURNS    : VARCHAR2
*/
FUNCTION IS_PARTY_ID_IN_REQUEST_LOG(
              p_party_id             IN     NUMBER)

RETURN VARCHAR2;

/**
 * FUNCTION get_message
 *
 * DESCRIPTION
 *    returns the translated message
 * ARGUMENTS
 *     app_short_name  -- applicatio short name
 *     message_name
 *     token1_name, token1_value
 *     token2_name, token2_value
 *     token3_name, token3_value
 *     token4_name, token4_value
 *     token5_name, token5_value
 *
 *   RETURNS    : VARCHAR2: token sustituted, translated message
*/
FUNCTION get_message(
   app_short_name IN VARCHAR2,
   message_name IN varchar2,
   token1_name  IN VARCHAR2,
   token1_value IN VARCHAR2,
   token2_name  IN VARCHAR2,
   token2_value IN VARCHAR2,
   token3_name  IN VARCHAR2,
   token3_value IN VARCHAR2,
   token4_name  IN VARCHAR2,
   token4_value IN VARCHAR2,
   token5_name  IN VARCHAR2,
   token5_value IN VARCHAR2)
RETURN VARCHAR2;


/**
 * FUNCTION is_restriction_exist
 *
 * DESCRIPTION
 *    used by common party UI .
 *    will return a flag to indicate if contact preference exist
 * ARGUMENTS
 *   IN:
 *     p_contact_level_table     contact level table
 *     p_contact_level_table_id  contact level table id
 *     p_preference_code         preference code
 *
 *   RETURNS    : VARCHAR2
 *
**/

FUNCTION is_restriction_exist (
    p_contact_level_table              IN     VARCHAR2,
    p_contact_level_table_id           IN     NUMBER,
    p_preference_code                  IN     VARCHAR2
) RETURN VARCHAR2;

/**
 * FUNCTION is_purchased_content_source
 *
 * DESCRIPTION
 *    This function will return 'Y' if the source system is a purchased one.
 *    (i.e HZ_ORIG_SYSTEMS_B.orig_system_type = 'PURCHASED')
 *
 * ARGUMENTS
 *   IN:
 *     p_content_source
 *
 *   RETURNS    : VARCHAR2
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *  01-03-2005  Rajib Ranjan Borah   o SSM SST Integration and Extension. Created.
 *
**/
FUNCTION is_purchased_content_source(
p_content_source                       IN     VARCHAR2
) RETURN VARCHAR2;

/**
 * FUNCTION get_lookupMeaning_lang
 *
 * DESCRIPTION
 *     This function will return the meaning in FND_LOOKUP_VALUES for the given combination
 *     of lookup_type, lookup_code and language.
 *
 * ARGUMENTS
 *   IN:
 *     p_lookup_type
 *     p_lookup_code
 *     p_language
 *
 *   RETURNS    : VARCHAR2 (FND_LOOKUP_VALUES.Meaning)
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *  09-Jan-2005  Rajib Ranjan Borah   o SSM SST Integration and Extension. Created.
 *
**/
FUNCTION get_lookupMeaning_lang (
p_lookup_type                        IN    VARCHAR2,
p_lookup_code                        IN    VARCHAR2,
p_language                           IN    VARCHAR2
) RETURN VARCHAR2;

/**
 * FUNCTION get_lookupDesc_lang
 *
 * DESCRIPTION
 *     This function will return the description in FND_LOOKUP_VALUES for the given combination
 *     of lookup_type, lookup_code and language.
 *
 * ARGUMENTS
 *   IN:
 *     p_lookup_type
 *     p_lookup_code
 *     p_language
 *
 *   RETURNS    : VARCHAR2 (FND_LOOKUP_VALUES.Description)
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *  09-Jan-2005  Rajib Ranjan Borah   o SSM SST Integration and Extension. Created.
 *
**/
FUNCTION get_lookupDesc_lang (
p_lookup_type                        IN    VARCHAR2,
p_lookup_code                        IN    VARCHAR2,
p_language                           IN    VARCHAR2
) RETURN VARCHAR2;


/**
 * FUNCTION check_prim_bill_to_site
 *
 * DESCRIPTION
 *    used by common party UI .
 *    will return Y if the party site is the primary Bill_To site.
 *    will return N in other cases

 * ARGUMENTS
 *   IN:
 *     p_party_site_id               party site id used to retrieve the site use purpose.
 *
 *   RETURNS    : VARCHAR2
 *
**/
function check_prim_bill_to_site (
    p_party_site_id                         IN     NUMBER)
RETURN VARCHAR2;


/**
 * FUNCTION check_prim_ship_to_site
 *
 * DESCRIPTION
 *    used by common party UI .
 *    will return Y if the party site is the primary Ship_To site.
 *    will return N in other cases

 * ARGUMENTS
 *   IN:
 *     p_party_site_id               party site id used to retrieve the site use purpose.
 *
 *   RETURNS    : VARCHAR2
 *
**/
function check_prim_ship_to_site (
    p_party_site_id                         IN     NUMBER)
RETURN VARCHAR2;


/**
 * PROCEDURE validate_created_by_module
 *
 * DESCRIPTION
 *    validate created by module
 * ARGUMENTS
 *   IN:
 *     p_create_update_flag      create update flag
 *     p_created_by_module       created by module
 *     p_old_created_by_module   old value of created by module
 *     x_return_status           return status
 */

PROCEDURE validate_created_by_module (
    p_create_update_flag          IN     VARCHAR2,
    p_created_by_module           IN     VARCHAR2,
    p_old_created_by_module       IN     VARCHAR2,
    x_return_status               IN OUT NOCOPY VARCHAR2
);


/**
 * PROCEDURE validate_application_id
 *
 * DESCRIPTION
 *    validate application id
 * ARGUMENTS
 *   IN:
 *     p_create_update_flag      create update flag
 *     p_application_id          application id
 *     p_old_application_id      old value of application id
 *     x_return_status           return status
 */

PROCEDURE validate_application_id (
    p_create_update_flag          IN     VARCHAR2,
    p_application_id              IN     NUMBER,
    p_old_application_id          IN     NUMBER,
    x_return_status               IN OUT NOCOPY VARCHAR2
);


/**
 * FUNCTION is_role_in_relationship_group
 *
 * DESCRIPTION
 *    return if a role exists in a relationship group
 * ARGUMENTS
 *   IN:
 *     p_relationship_type_id    relationship type id
 *     p_relationship_group_code relationship group code
 */

FUNCTION is_role_in_relationship_group (
    p_relationship_type_id        IN     NUMBER,
    p_relationship_group_code     IN     VARCHAR2
) RETURN VARCHAR2;

END HZ_UTILITY_V2PUB;

/
