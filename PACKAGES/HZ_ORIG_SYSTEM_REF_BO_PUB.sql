--------------------------------------------------------
--  DDL for Package HZ_ORIG_SYSTEM_REF_BO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_ORIG_SYSTEM_REF_BO_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHBOSBS.pls 120.7 2006/09/22 00:42:08 acng noship $ */
/*#
 * Business Object Source System Management API
 * Public API that allows users to manage source system references for business objects in the
 * Trading Community Architecture. Several operations are supported, including the creation, update,
 * and remap of source system information for a business object.
 *
 * @rep:scope public
 * @rep:product HZ
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY HZ_EXTERNAL_REFERENCE
 * @rep:displayname Business Object Source System Management API
 * @rep:doccd 120hztig.pdf Business Object APIs Overview, Oracle Trading Community Architecture Technical Implementation Guide
 */

  TYPE object_type_tbl IS TABLE OF VARCHAR2(30);
  TYPE object_id_tbl   IS TABLE OF NUMBER;
  TYPE object_os_tbl   IS TABLE OF VARCHAR2(30);
  TYPE object_osr_tbl  IS TABLE OF VARCHAR2(255);
  TYPE reason_code_tbl IS TABLE OF VARCHAR2(30);

  TYPE REMAP_ORIG_SYS_REC IS RECORD (
    object_type           object_type_tbl,
    old_object_id         object_id_tbl,
    new_object_id         object_id_tbl,
    object_os             object_os_tbl,
    object_osr            object_osr_tbl,
    reason_code           reason_code_tbl
  );

  -- PROCEDURE create_orig_sys_refs_bo
  --
  -- DESCRIPTION
  --     Create original system references
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_orig_sys_refs      List of original system reference objects.
  --     p_created_by_module  Created by module.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --
  PROCEDURE create_orig_sys_refs_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_orig_sys_refs       IN            HZ_ORIG_SYS_REF_OBJ_TBL,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

/*#
 * Create Object Source System References (create_orig_sys_refs_bo)
 * Creates source system references to TCA for business objects. You pass the Source System information,
 * including Original System Name and Original System Reference, and the procedure creates the source system
 * reference in TCA. Multiple source system references for multiple objects can be created in one API call.
 *
 * @param p_orig_sys_refs The business object source system references to be created
 * @param p_created_by_module The module creating this business object. Must be a valid created_by_module value
 * @param x_return_status Return status after the call
 * @param x_msg_count Number of messages in message stack.
 * @param x_msg_data Messages returned from the operation
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Object Source System References
 * @rep:doccd 120hztig.pdf Business Object APIs Overview, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE create_orig_sys_refs_bo(
    p_orig_sys_refs       IN            HZ_ORIG_SYS_REF_OBJ_TBL,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  );

  -- PROCEDURE update_orig_sys_refs_bo
  --
  -- DESCRIPTION
  --     Update original system references
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_orig_sys_refs      List of original system reference objects.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE update_orig_sys_refs_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_orig_sys_refs       IN            HZ_ORIG_SYS_REF_OBJ_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

/*#
 * Update Object Source System References (update_orig_sys_refs_bo)
 * Updates source system references to TCA for business objects. You pass the Source System information including
 * Original System Name, the old Original System Reference value, and the new Original System Reference value,
 * and the procedure updates the source system reference in TCA. Multiple source system references for multiple
 * objects can be updated in one API call.
 *
 * @param p_orig_sys_refs The business object source system references to be updated.
 * @param x_return_status Return status after the call
 * @param x_msg_count Number of messages in message stack.
 * @param x_msg_data Messages returned from the operation
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Object Source System References
 * @rep:doccd 120hztig.pdf Business Object APIs Overview, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE update_orig_sys_refs_bo(
    p_orig_sys_refs       IN            HZ_ORIG_SYS_REF_OBJ_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  );

  -- PROCEDURE remap_internal_identifiers_bo
  --
  -- DESCRIPTION
  --     Remap original system references
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --     p_orig_sys_refs      List of original system reference objects.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE remap_internal_identifiers_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_orig_sys_refs       IN            REMAP_ORIG_SYS_REC,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

/*#
 * Remap Internal Object Identifiers (remap_orig_sys_refs_bo)
 * Remaps TCA internal object identifiers to an Original System and Original System Reference combination.
 * You pass the OS and OSR combination, the TCA object identifier for the internal updates source system
 * references to TCA for business objects. You pass the Source System information, including Original System
 * Name, the old Original System Reference value, the new Original System Reference value, and the procedure
 * updates the source system reference in TCA. Multiple source system references, for multiple objects, can
 * be updated in one API call.
 *
 * @param p_orig_sys_refs The business object source system references to be update.
 * @param x_return_status Return status after the call
 * @param x_msg_count Number of messages in message stack.
 * @param x_msg_data Messages returned from the operation
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Object Source System References
 * @rep:doccd 120hztig.pdf Business Object APIs Overview, Oracle Trading Community Architecture Technical Implementation Guide
 */
  PROCEDURE remap_internal_identifiers_bo(
    p_orig_sys_refs       IN            REMAP_ORIG_SYS_REC,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  );

END HZ_ORIG_SYSTEM_REF_BO_PUB;

 

/
