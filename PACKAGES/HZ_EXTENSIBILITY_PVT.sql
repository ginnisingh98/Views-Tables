--------------------------------------------------------
--  DDL for Package HZ_EXTENSIBILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_EXTENSIBILITY_PVT" AUTHID CURRENT_USER AS
/* $Header: ARHEXTCS.pls 120.2 2005/08/30 19:07:52 geliu noship $ */

G_FILE_NAME         CONSTANT  VARCHAR2(12)  :=  'ARHEXTCS.pls';

G_RET_STS_SUCCESS   CONSTANT    VARCHAR2(1)  :=  FND_API.g_RET_STS_SUCCESS;     --'S'
G_RET_STS_ERROR     CONSTANT    VARCHAR2(1)  :=  FND_API.g_RET_STS_ERROR;       --'E'
G_RET_STS_UNEXP_ERROR   CONSTANT    VARCHAR2(1)  :=  FND_API.g_RET_STS_UNEXP_ERROR; --'U'

--  Define the package global constants to substitute FND_API global variables for missing values
G_MISS_NUM      CONSTANT    NUMBER       :=  9.99E125;
G_MISS_CHAR     CONSTANT    VARCHAR2(1)  :=  CHR(0);
G_MISS_DATE     CONSTANT    DATE         :=  TO_DATE('1','j');



-- -----------------------------------------------------------------------------
--  API Name:       Process_User_Attrs_For_Item
--
--  Description:
--    Process passed-in User-Defined Attrs data for
--    the Item whose Primary Keys are passed in
-- -----------------------------------------------------------------------------
PROCEDURE Process_User_Attrs_For_Item (
        p_api_version                   IN   NUMBER
       ,p_owner_table_id                IN   NUMBER
       ,p_owner_table_name              IN   VARCHAR2
       ,p_attributes_row_table          IN   EGO_USER_ATTR_ROW_TABLE
       ,p_attributes_data_table         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT 0
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_write_to_concurrent_log       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_log_errors                    IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_failed_row_id_list            OUT NOCOPY VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);

-- -----------------------------------------------------------------------------
--  API Name:       Get_User_Attrs_For_Item
--
--  Description:
--    Fetch passed-in User-Defined Attrs data for
--    the Item whose Primary Keys are passed in
-- -----------------------------------------------------------------------------
PROCEDURE Get_User_Attrs_For_Item (
        p_api_version                   IN   NUMBER
       ,p_org_profile_id                IN   NUMBER
       ,p_attr_group_request_table      IN   EGO_ATTR_GROUP_REQUEST_TABLE
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT 0
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_attributes_row_table          OUT NOCOPY EGO_USER_ATTR_ROW_TABLE
       ,x_attributes_data_table         OUT NOCOPY EGO_USER_ATTR_DATA_TABLE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
);


/**
 * PROCEDURE copy_person_extent_data
 *
 * DESCRIPTION
 *     Copy person extent data. This procedure will be called whenever
 *     a new person profile is created for maintain history reason.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_old_profile_id                Old profile Id.
 *     p_new_profile_id                New profile Id.
 *   IN/OUT:
 *   OUT:
 *     x_return_status                 Return status after the call. The status can
 *                                     be FND_API.G_RET_STS_SUCCESS (success),
 *                                     FND_API.G_RET_STS_ERROR (error),
 *                                     FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   12-01-2004    Jianying Huang      o Created.
 *
 */

PROCEDURE copy_person_extent_data (
    p_old_profile_id              IN     NUMBER,
    p_new_profile_id              IN     NUMBER,
    x_return_status               IN OUT NOCOPY VARCHAR2
);


/**
 * PROCEDURE copy_org_extent_data
 *
 * DESCRIPTION
 *     Copy organization extent data. This procedure will be called whenever
 *     a new organization profile is created for maintain history reason.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_old_profile_id                Old profile Id.
 *     p_new_profile_id                New profile Id.
 *   IN/OUT:
 *   OUT:
 *     x_return_status                 Return status after the call. The status can
 *                                     be FND_API.G_RET_STS_SUCCESS (success),
 *                                     FND_API.G_RET_STS_ERROR (error),
 *                                     FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   12-01-2004    Jianying Huang      o Created.
 *
 */

PROCEDURE copy_org_extent_data (
    p_old_profile_id              IN     NUMBER,
    p_new_profile_id              IN     NUMBER,
    x_return_status               IN OUT NOCOPY VARCHAR2
);


/**
 * PUBLIC PROCEDURE copy_org_conc_main
 *
 * DESCRIPTION
 *   Main concurrent program to copy organization extension data
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * IN:
 *   p_batch_size                 Batch Size
 *   p_number_of_worker           Number of Worker
 *
 * MODIFICATION HISTORY
 *
 *   03-15-2005  Jianying Huang   o Created.
 */

PROCEDURE copy_org_conc_main (
    errbuf                        OUT    NOCOPY VARCHAR2,
    retcode                       OUT    NOCOPY VARCHAR2,
    p_batch_size                  IN     NUMBER,
    p_number_of_worker            IN     NUMBER
);


/**
 * PUBLIC PROCEDURE copy_per_conc_main
 *
 * DESCRIPTION
 *   Main concurrent program to copy person extension data
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * IN:
 *   p_batch_size                 Batch Size
 *   p_number_of_worker           Number of Worker
 *
 * MODIFICATION HISTORY
 *
 *   03-15-2005  Jianying Huang   o Created.
 */

PROCEDURE copy_per_conc_main (
    errbuf                        OUT    NOCOPY VARCHAR2,
    retcode                       OUT    NOCOPY VARCHAR2,
    p_batch_size                  IN     NUMBER,
    p_number_of_worker            IN     NUMBER
);


/**
 * PUBLIC PROCEDURE copy_org_conc_sub
 *
 * DESCRIPTION
 *   Sub concurrent program to copy organization extension data
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * IN:
 *   p_parent_request_id          Parent Request ID
 *
 * MODIFICATION HISTORY
 *
 *   03-15-2005  Jianying Huang   o Created.
 */

PROCEDURE copy_org_conc_sub (
    errbuf                        OUT    NOCOPY VARCHAR2,
    retcode                       OUT    NOCOPY VARCHAR2,
    p_parent_request_id           IN     NUMBER
);


/**
 * PUBLIC PROCEDURE copy_per_conc_sub
 *
 * DESCRIPTION
 *   Sub concurrent program to copy person extension data
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * IN:
 *   p_parent_request_id          Parent Request ID
 *
 * MODIFICATION HISTORY
 *
 *   03-15-2005  Jianying Huang   o Created.
 */

PROCEDURE copy_per_conc_sub (
    errbuf                        OUT    NOCOPY VARCHAR2,
    retcode                       OUT    NOCOPY VARCHAR2,
    p_parent_request_id           IN     NUMBER
);

END HZ_EXTENSIBILITY_PVT;

 

/
