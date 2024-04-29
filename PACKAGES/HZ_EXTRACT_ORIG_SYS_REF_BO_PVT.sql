--------------------------------------------------------
--  DDL for Package HZ_EXTRACT_ORIG_SYS_REF_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_EXTRACT_ORIG_SYS_REF_BO_PVT" AUTHID CURRENT_USER AS
/*$Header: ARHEOSVS.pls 120.1 2005/07/13 21:25:21 awu noship $ */
/*
 * This package contains the private APIs for ssm information.
 * @rep:scope private
 * @rep:product HZ
 * @rep:displayname customer account site
 * @rep:category BUSINESS_ENTITY HZ_PARTIES
 * @rep:lifecycle active
 * @rep:doccd 115hztig.pdf cGet APIs
 */

  --------------------------------------
  --
  -- PROCEDURE get_orig_sys_ref_bo
  --
  -- DESCRIPTION
  --     Get ssm information.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
--       p_owner_table_id          tca owner table ID.
  --     p_owner_table_name        tca owner table name.
  --
  --   OUT:
  --     x_orig_sys_ref_objs  Table of ssm objects.
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
  --
  --   15-May-2005   AWU                Created.
  --



 PROCEDURE get_orig_sys_ref_bos(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_owner_table_id           IN            NUMBER,
    p_owner_table_name           IN            VARCHAR2,
    p_action_type	  IN VARCHAR2 := NULL,
    x_orig_sys_ref_objs          OUT NOCOPY    HZ_ORIG_SYS_REF_OBJ_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );


END HZ_EXTRACT_ORIG_SYS_REF_BO_PVT;

 

/
