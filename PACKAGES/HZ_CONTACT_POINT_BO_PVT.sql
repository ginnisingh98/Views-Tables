--------------------------------------------------------
--  DDL for Package HZ_CONTACT_POINT_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CONTACT_POINT_BO_PVT" AUTHID CURRENT_USER AS
/*$Header: ARHBCPVS.pls 120.3 2006/05/18 22:23:57 acng noship $ */

  -- PROCEDURE save_contact_points
  --
  -- DESCRIPTION
  --     Create or update contact points.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_phone_objs         List of phone business objects.
  --     p_telex_objs         List of telex business objects.
  --     p_email_objs         List of email business objects.
  --     p_web_objs           List of web business objects.
  --     p_edi_objs           List of edi business objects.
  --     p_eft_objs           List of eft business objects.
  --     p_sms_objs           List of sms business objects.
  --     p_owner_table_id     Owner table Id.
  --     p_owner_table_os     Owner table original system.
  --     p_owner_table_osr    Owner table original system reference.
  --     p_parent_obj_type    Parent object type.
  --     p_create_update_flag Create or update flag.
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

  PROCEDURE save_contact_points(
    p_phone_objs                 IN OUT NOCOPY HZ_PHONE_CP_BO_TBL,
    p_telex_objs                 IN OUT NOCOPY HZ_TELEX_CP_BO_TBL,
    p_email_objs                 IN OUT NOCOPY HZ_EMAIL_CP_BO_TBL,
    p_web_objs                   IN OUT NOCOPY HZ_WEB_CP_BO_TBL,
    p_edi_objs                   IN OUT NOCOPY HZ_EDI_CP_BO_TBL,
    p_eft_objs                   IN OUT NOCOPY HZ_EFT_CP_BO_TBL,
    p_sms_objs                   IN OUT NOCOPY HZ_SMS_CP_BO_TBL,
    p_owner_table_id             IN         NUMBER,
    p_owner_table_os             IN         VARCHAR2,
    p_owner_table_osr            IN         VARCHAR2,
    p_parent_obj_type            IN         VARCHAR2,
    p_create_update_flag         IN         VARCHAR2,
    p_obj_source                 IN         VARCHAR2 := null,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  );

END hz_contact_point_bo_pvt;

 

/
