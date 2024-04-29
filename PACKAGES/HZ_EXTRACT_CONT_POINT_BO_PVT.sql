--------------------------------------------------------
--  DDL for Package HZ_EXTRACT_CONT_POINT_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_EXTRACT_CONT_POINT_BO_PVT" AUTHID CURRENT_USER AS
/*$Header: ARHECPVS.pls 120.1 2005/07/13 21:25:09 awu noship $ */
/*
 * This package contains the private APIs for logical phone.
 * @rep:scope private
 * @rep:product HZ
 * @rep:displayname phone
 * @rep:category BUSINESS_ENTITY HZ_PARTIES
 * @rep:lifecycle active
 * @rep:doccd 115hztig.pdf phone Get APIs
 */

/*
The Get Contact Point API Procedures are retrieval services that return a full Contact Point business object of the type specified.
The user identifies a particular Contact Point business object using the TCA identifier and/or the objects Source System information.
Upon proper validation of the object, the full Contact Point business object is returned. The object consists of all data included
within the Contact Point business object, at all embedded levels. This includes the set of all data stored in the TCA tables for each
embedded entity.

To retrieve the appropriate embedded entities within the Contact Point business objects, the Get procedure returns all records for
the particular object from these TCA entity tables.

Embedded BO	    Mandatory	Multiple Logical API Procedure		Comments

Contact Point		Y	N	HZ_CONTACT_POINTS
Contact Preference	N	Y	HZ_CONTACT_PREFERENCES

*/


  --------------------------------------
  --
  -- PROCEDURE get_phone_bos
  --
  -- DESCRIPTION
  --     Get a or more logical phone.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --       p_phone_id         phone ID.If this id passed in, return only one phone obj.
  --     p_parent_id 	      parent_id
  --     p_parent_table_name  parent_table name
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_phone_objs         Logical phone records.
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
  --   30-May-2005   AWU                Created.
  --



 PROCEDURE get_phone_bos(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_phone_id           IN            NUMBER,
    p_parent_id 	 IN            NUMBER,
    p_parent_table_name   IN            VARCHAR2,
    p_action_type	  IN VARCHAR2 := NULL,
    x_phone_objs          OUT NOCOPY    HZ_PHONE_CP_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );



  --------------------------------------
  --
  -- PROCEDURE get_telex_bos
  --
  -- DESCRIPTION
  --     Get a or more logical telex.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
--       p_telex_id          telex ID. If this id passed in, return only one obj.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
   --     p_parent_id 	      parent_id
  --     p_parent_table_name  parent_table name
  --   OUT:
  --     x_telex_objs         Logical telex records.
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
  --   30-May-2005   AWU                Created.
  --



 PROCEDURE get_telex_bos(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_telex_id           IN            NUMBER,
    p_parent_id 	 IN            NUMBER,
    p_parent_table_name   IN            VARCHAR2,
    p_action_type	  IN VARCHAR2 := NULL,
    x_telex_objs          OUT NOCOPY    HZ_TELEX_CP_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );


 --------------------------------------
  --
  -- PROCEDURE get_email_bos
  --
  -- DESCRIPTION
  --     Get a or more logical email.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
--       p_email_id          email ID. If this id passed in, return only one obj.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
   --     p_parent_id 	      parent_id
  --     p_parent_table_name  parent_table name
  --   OUT:
  --     x_email_objs         Logical email records.
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
  --   30-May-2005   AWU                Created.
  --



 PROCEDURE get_email_bos(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_email_id           IN            NUMBER,
    p_parent_id 	 IN            NUMBER,
    p_parent_table_name   IN            VARCHAR2,
    p_action_type	  IN VARCHAR2 := NULL,
    x_email_objs          OUT NOCOPY    HZ_EMAIL_CP_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );



  --------------------------------------
  --
  -- PROCEDURE get_web_bos
  --
  -- DESCRIPTION
  --     Get a or more logical web business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
--       p_web_id          	web ID. If this id passed in, return only one obj.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
 --     p_parent_id 	      parent_id
  --     p_parent_table_name  parent_table name
  --   OUT:
  --     x_web_objs         Logical web records.
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
  --   30-May-2005   AWU                Created.
  --



 PROCEDURE get_web_bos(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_web_id           IN            NUMBER,
    p_parent_id 	 IN            NUMBER,
    p_parent_table_name   IN            VARCHAR2,
    p_action_type	  IN VARCHAR2 := NULL,
    x_web_objs          OUT NOCOPY    HZ_WEB_CP_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );


 --------------------------------------
  --
  -- PROCEDURE get_edi_bos
  --
  -- DESCRIPTION
  --     Get a or more logical edi business object.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
--       p_edi_id          edi ID. If this id passed in, return only one obj.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
 --     p_parent_id 	      parent_id
  --     p_parent_table_name  parent_table name
  --   OUT:
  --     x_edi_objs         Logical edi records.
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
  --   30-May-2005   AWU                Created.
  --



 PROCEDURE get_edi_bos(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_edi_id           IN            NUMBER,
    p_parent_id 	 IN            NUMBER,
    p_parent_table_name   IN            VARCHAR2,
    p_action_type	  IN VARCHAR2 := NULL,
    x_edi_objs          OUT NOCOPY    HZ_EDI_CP_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

 --------------------------------------
  --
  -- PROCEDURE get_eft_bos
  --
  -- DESCRIPTION
  --     Get a or more logical eft.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
--       p_eft_id          eft ID. If this id passed in, return only one obj.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
 --     p_parent_id 	      parent_id
  --     p_parent_table_name  parent_table name
  --   OUT:
  --     x_eft_objs         Logical eft records.
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
  --   30-May-2005   AWU                Created.
  --



 PROCEDURE get_eft_bos(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_eft_id           IN            NUMBER,
    p_parent_id 	 IN            NUMBER,
    p_parent_table_name   IN            VARCHAR2,
    p_action_type	  IN VARCHAR2 := NULL,
    x_eft_objs          OUT NOCOPY    HZ_EFT_CP_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

 --------------------------------------
  --
  -- PROCEDURE get_sms_bos
  --
  -- DESCRIPTION
  --     Get a or more logical sms.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
--       p_sms_id          sms ID. If this id passed in, return only one obj.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
 --     p_parent_id 	      parent_id
  --     p_parent_table_name  parent_table name
  --   OUT:
  --     x_sms_objs         Logical sms records.
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
  --   30-May-2005   AWU                Created.
  --



 PROCEDURE get_sms_bos(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_sms_id           IN            NUMBER,
    p_parent_id 	 IN            NUMBER,
    p_parent_table_name   IN            VARCHAR2,
    p_action_type	  IN VARCHAR2 := NULL,
    x_sms_objs          OUT NOCOPY    HZ_SMS_CP_BO_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );

PROCEDURE get_cont_pref_objs(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_cont_level_table_id           IN            NUMBER,
    p_cont_level_table           IN            VARCHAR2,
    p_contact_type          IN            VARCHAR2,
    p_action_type	  IN VARCHAR2 := NULL,
    x_cont_pref_objs          OUT NOCOPY    HZ_CONTACT_PREF_OBJ_TBL,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  );


END HZ_EXTRACT_CONT_POINT_BO_PVT;

 

/
