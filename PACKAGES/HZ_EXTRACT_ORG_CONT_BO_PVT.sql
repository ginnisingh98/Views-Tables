--------------------------------------------------------
--  DDL for Package HZ_EXTRACT_ORG_CONT_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_EXTRACT_ORG_CONT_BO_PVT" AUTHID CURRENT_USER AS
/*$Header: ARHEOCVS.pls 120.1 2005/07/13 21:25:15 awu noship $ */
/*
 * This package contains the private APIs for org contact information.
 * @rep:scope private
 * @rep:product HZ
 * @rep:display name org contact
 * @rep:category BUSINESS_ENTITY HZ_ORG_CONTACTS
 * @rep:lifecycle active
 * @rep:doccd 115hztig.pdf Get APIs
 */

  --------------------------------------
  --
  -- PROCEDURE get_org_contact_bos
  --
  -- DESCRIPTION
  --     Get org contact information.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --       p_organization_id       Org Contact Org id.
  --
  --   OUT:
  --     x_org contact_objs  Table of org contact objects.
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
  --   15-June-2005   AWU                Created.
  --



 PROCEDURE get_org_contact_bos(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_organization_id     IN            NUMBER,
    p_org_contact_id	  IN            NUMBER := NULL,
    p_action_type	  IN VARCHAR2 := NULL,
    x_org_contact_objs    OUT NOCOPY    HZ_ORG_CONTACT_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );


END HZ_EXTRACT_ORG_CONT_BO_PVT;

 

/
