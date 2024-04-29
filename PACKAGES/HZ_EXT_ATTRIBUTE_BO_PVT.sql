--------------------------------------------------------
--  DDL for Package HZ_EXT_ATTRIBUTE_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_EXT_ATTRIBUTE_BO_PVT" AUTHID CURRENT_USER AS
/*$Header: ARHBEXVS.pls 120.1 2005/07/28 21:51:40 acng noship $ */

  -- PROCEDURE save_ext_attributes
  --
  -- DESCRIPTION
  --     Create or update extensibility attributes.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_ext_attr_objs      List of extensibility attribute objects.
  --     p_parent_obj_id      Parent object Id.
  --     p_parent_obj_type    Parent object type.
  --     p_create_or_update   Create or update flag.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --     x_errorcode          Error code.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE save_ext_attributes(
    p_ext_attr_objs           IN         HZ_EXT_ATTRIBUTE_OBJ_TBL,
    p_parent_obj_id           IN         NUMBER,
    p_parent_obj_type         IN         VARCHAR2,
    p_create_or_update        IN         VARCHAR2,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_errorcode               OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2
  );

END HZ_EXT_ATTRIBUTE_BO_PVT;

 

/
