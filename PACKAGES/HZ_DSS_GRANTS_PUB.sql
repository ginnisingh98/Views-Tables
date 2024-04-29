--------------------------------------------------------
--  DDL for Package HZ_DSS_GRANTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_DSS_GRANTS_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHPDSXS.pls 120.2 2005/10/30 04:22:03 appldev noship $ */


--------------------------------------
-- declaration of global variables
--------------------------------------

g_dss_admin_create                VARCHAR2(30) := 'CREATE';  -- or "copy"
g_dss_admin_update                VARCHAR2(30) := 'UPDATE';
g_dss_admin_grant                 VARCHAR2(30) := 'GRANT';


--------------------------------------
-- declaration of procedures / functions
--------------------------------------

/**
 * PROCEDURE create_grant
 *
 * DESCRIPTION
 *
 *     Creates a set of Grants to a Data Sharing Group.
 *     This signature matches the UI and corresponds to a "UI Grant Create".
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   09-03-2002    Chris Saulit       o Created.
 *
 */

PROCEDURE create_grant (
    p_init_msg_list               IN     VARCHAR2 DEFAULT NULL,
    p_dss_group_code              IN     VARCHAR2,
    p_dss_grantee_type            IN     VARCHAR2,
    p_dss_grantee_key             IN     VARCHAR2,
    p_view_flag                   IN     VARCHAR2,
    p_insert_flag                 IN     VARCHAR2,
    p_update_flag                 IN     VARCHAR2,
    p_delete_flag                 IN     VARCHAR2,
    p_admin_flag                  IN     VARCHAR2,
    x_return_status               OUT    NOCOPY VARCHAR2,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
);

/**
 * PROCEDURE create_grant
 *
 * DESCRIPTION
 *
 *     Creates a set of Grants to a Data Sharing Group.
 *     The procedure is called when a new secured entity is
 *     added to a dss group.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   06-30-2004    Jianying Huang       o Created.
 *
 */

PROCEDURE create_grant (
    p_init_msg_list               IN     VARCHAR2 DEFAULT NULL,
    p_dss_group_code              IN     VARCHAR2,
    p_dss_instance_set_id         IN     NUMBER,
    p_secured_entity_status       IN     VARCHAR2,
    x_return_status               OUT    NOCOPY VARCHAR2,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
);

/**
 * PROCEDURE update_grant
 *
 * DESCRIPTION
 *
 *     Updates a set of Grants against a Data Sharing Group.
 *     This signature matches the UI and corresponds to a "UI Grant Update".
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   09-03-2002    Chris Saulit       o Created.
 *
 */

PROCEDURE update_grant (
    p_init_msg_list               IN     VARCHAR2 DEFAULT NULL,
    p_dss_group_code              IN     VARCHAR2,
    p_dss_grantee_type            IN     VARCHAR2,
    p_dss_grantee_key             IN     VARCHAR2,
    p_view_flag                   IN     VARCHAR2,
    p_insert_flag                 IN     VARCHAR2,
    p_update_flag                 IN     VARCHAR2,
    p_delete_flag                 IN     VARCHAR2,
    p_admin_flag                  IN     VARCHAR2,
    x_return_status               OUT    NOCOPY VARCHAR2,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
);


/**
 * PROCEDURE update_grant
 *
 * DESCRIPTION
 *
 *     Updates a set of Grants against a Data Sharing Group.
 *     This procedure is called when a whole DSS group is
 *     disabled/enabled.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   06-29-2004    Jianying Huang       o Created.
 *
 */

PROCEDURE update_grant (
    p_init_msg_list               IN     VARCHAR2 DEFAULT NULL,
    p_dss_group_code              IN     VARCHAR2,
    p_dss_group_status            IN     VARCHAR2,
    x_return_status               OUT    NOCOPY VARCHAR2,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
);


/**
 * PROCEDURE update_grant
 *
 * DESCRIPTION
 *
 *     Updates a set of Grants against a Data Sharing Group.
 *     This procedure is called when an entity inside a DSS group
 *     is disabled/enabled.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   06-29-2004    Jianying Huang       o Created.
 *
 */

PROCEDURE update_grant (
    p_init_msg_list               IN     VARCHAR2 DEFAULT NULL,
    p_dss_group_code              IN     VARCHAR2,
    p_dss_instance_set_id         IN     NUMBER,
    p_secured_entity_status       IN     VARCHAR2,
    x_return_status               OUT    NOCOPY VARCHAR2,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
);


/**
 * PROCEDURE check_admin_priv
 *
 * DESCRIPTION
 *
 *     Checks whether the current user has sufficient privilege to maintain
 *     a Data Sharing Group.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   09-18-2002    Chris Saulit       o Created.
 *
 */

PROCEDURE check_admin_priv (
    p_init_msg_list               IN     VARCHAR2 DEFAULT NULL,
    p_dss_group_code              IN     VARCHAR2,
    p_dss_admin_func_code         IN     VARCHAR2,
    x_pass_fail_flag              OUT    NOCOPY VARCHAR2,
    x_return_status               OUT    NOCOPY VARCHAR2,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
);


/**
 * FUNCTION check_admin_priv
 *
 * DESCRIPTION
 *
 *     Checks whether the current user has sufficient privilege to maintain
 *     a Data Sharing Group.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   09-18-2002    Chris Saulit       o Created.
 *
 */

FUNCTION check_admin_priv (
    p_dss_group_code              IN     VARCHAR2,
    p_dss_admin_func_code         IN     VARCHAR2
) RETURN VARCHAR2;


END HZ_DSS_GRANTS_PUB;

 

/
