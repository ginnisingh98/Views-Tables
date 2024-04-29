--------------------------------------------------------
--  DDL for Package Body HZ_CONTACT_POINT_BO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CONTACT_POINT_BO_PUB" AS
/*$Header: ARHBCPBB.pls 120.14 2006/05/18 22:23:28 acng noship $ */

  -- PRIVATE PROCEDURE assign_phone_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from phone business object to plsql record.
  --
  -- ARGUMENTS
  --   IN:
  --     p_phone_obj          Phone business object.
  --     p_owner_table_id     Owner table Id.
  --     p_owner_table_name   Owner table name.
  --     p_cp_id              Contact point Id.
  --     p_cp_os              Contact point original system.
  --     p_cp_osr             Contact point original system reference.
  --     p_cp_type            Contact point type.
  --     p_created_by_module  Created by module.
  --   IN/OUT:
  --     px_phone_rec         Phone plsql record.
  --     px_contact_point_rec Contact point plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_phone_rec(
    p_phone_obj                  IN            HZ_PHONE_CP_BO,
    p_owner_table_id             IN            NUMBER,
    p_owner_table_name           IN            VARCHAR2,
    p_cp_id                      IN            NUMBER,
    p_cp_os                      IN            VARCHAR2,
    p_cp_osr                     IN            VARCHAR2,
    p_cp_type                    IN            VARCHAR2,
    p_create_or_update           IN            VARCHAR2 := 'C',
    px_phone_rec                 IN OUT NOCOPY HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE,
    px_contact_point_rec         IN OUT NOCOPY HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE
  );

  -- PRIVATE PROCEDURE assign_telex_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from telex business object to plsql record.
  --
  -- ARGUMENTS
  --   IN:
  --     p_telex_obj          Telex business object.
  --     p_owner_table_id     Owner table Id.
  --     p_owner_table_name   Owner table name.
  --     p_cp_id              Contact point Id.
  --     p_cp_os              Contact point original system.
  --     p_cp_osr             Contact point original system reference.
  --     p_cp_type            Contact point type.
  --     p_created_by_module  Created by module.
  --   IN/OUT:
  --     px_telex_rec         Telex plsql record.
  --     px_contact_point_rec Contact point plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_telex_rec(
    p_telex_obj                  IN            HZ_TELEX_CP_BO,
    p_owner_table_id             IN            NUMBER,
    p_owner_table_name           IN            VARCHAR2,
    p_cp_id                      IN            NUMBER,
    p_cp_os                      IN            VARCHAR2,
    p_cp_osr                     IN            VARCHAR2,
    p_cp_type                    IN            VARCHAR2,
    p_create_or_update           IN            VARCHAR2 := 'C',
    px_telex_rec                 IN OUT NOCOPY HZ_CONTACT_POINT_V2PUB.TELEX_REC_TYPE,
    px_contact_point_rec         IN OUT NOCOPY HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE
  );

  -- PRIVATE PROCEDURE assign_email_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from email business object to plsql record.
  --
  -- ARGUMENTS
  --   IN:
  --     p_email_obj          Email business object.
  --     p_owner_table_id     Owner table Id.
  --     p_owner_table_name   Owner table name.
  --     p_cp_id              Contact point Id.
  --     p_cp_os              Contact point original system.
  --     p_cp_osr             Contact point original system reference.
  --     p_cp_type            Contact point type.
  --     p_created_by_module  Created by module.
  --   IN/OUT:
  --     px_email_rec         Email plsql record.
  --     px_contact_point_rec Contact point plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_email_rec(
    p_email_obj                  IN            HZ_EMAIL_CP_BO,
    p_owner_table_id             IN            NUMBER,
    p_owner_table_name           IN            VARCHAR2,
    p_cp_id                      IN            NUMBER,
    p_cp_os                      IN            VARCHAR2,
    p_cp_osr                     IN            VARCHAR2,
    p_cp_type                    IN            VARCHAR2,
    p_create_or_update           IN            VARCHAR2 := 'C',
    px_email_rec                 IN OUT NOCOPY HZ_CONTACT_POINT_V2PUB.EMAIL_REC_TYPE,
    px_contact_point_rec         IN OUT NOCOPY HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE
  );

  -- PRIVATE PROCEDURE assign_web_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from web business object to plsql record.
  --
  -- ARGUMENTS
  --   IN:
  --     p_web_obj            Web business object.
  --     p_owner_table_id     Owner table Id.
  --     p_owner_table_name   Owner table name.
  --     p_cp_id              Contact point Id.
  --     p_cp_os              Contact point original system.
  --     p_cp_osr             Contact point original system reference.
  --     p_cp_type            Contact point type.
  --     p_created_by_module  Created by module.
  --   IN/OUT:
  --     px_web_rec           Web plsql record.
  --     px_contact_point_rec Contact point plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_web_rec(
    p_web_obj                    IN            HZ_WEB_CP_BO,
    p_owner_table_id             IN            NUMBER,
    p_owner_table_name           IN            VARCHAR2,
    p_cp_id                      IN            NUMBER,
    p_cp_os                      IN            VARCHAR2,
    p_cp_osr                     IN            VARCHAR2,
    p_cp_type                    IN            VARCHAR2,
    p_create_or_update           IN            VARCHAR2 := 'C',
    px_web_rec                   IN OUT NOCOPY HZ_CONTACT_POINT_V2PUB.WEB_REC_TYPE,
    px_contact_point_rec         IN OUT NOCOPY HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE
  );

  -- PRIVATE PROCEDURE assign_edi_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from edi business object to plsql record.
  --
  -- ARGUMENTS
  --   IN:
  --     p_edi_obj            EDI business object.
  --     p_owner_table_id     Owner table Id.
  --     p_owner_table_name   Owner table name.
  --     p_cp_id              Contact point Id.
  --     p_cp_os              Contact point original system.
  --     p_cp_osr             Contact point original system reference.
  --     p_cp_type            Contact point type.
  --     p_created_by_module  Created by module.
  --   IN/OUT:
  --     px_edi_rec           EDI plsql record.
  --     px_contact_point_rec Contact point plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_edi_rec(
    p_edi_obj                    IN            HZ_EDI_CP_BO,
    p_owner_table_id             IN            NUMBER,
    p_owner_table_name           IN            VARCHAR2,
    p_cp_id                      IN            NUMBER,
    p_cp_os                      IN            VARCHAR2,
    p_cp_osr                     IN            VARCHAR2,
    p_cp_type                    IN            VARCHAR2,
    p_create_or_update           IN            VARCHAR2 := 'C',
    px_edi_rec                   IN OUT NOCOPY HZ_CONTACT_POINT_V2PUB.EDI_REC_TYPE,
    px_contact_point_rec         IN OUT NOCOPY HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE
  );

  -- PRIVATE PROCEDURE assign_eft_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from eft business object to plsql record.
  --
  -- ARGUMENTS
  --   IN:
  --     p_eft_obj            EFT business object.
  --     p_owner_table_id     Owner table Id.
  --     p_owner_table_name   Owner table name.
  --     p_cp_id              Contact point Id.
  --     p_cp_os              Contact point original system.
  --     p_cp_osr             Contact point original system reference.
  --     p_cp_type            Contact point type.
  --     p_created_by_module  Created by module.
  --   IN/OUT:
  --     px_eft_rec           EFT plsql record.
  --     px_contact_point_rec Contact point plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_eft_rec(
    p_eft_obj                    IN            HZ_EFT_CP_BO,
    p_owner_table_id             IN            NUMBER,
    p_owner_table_name           IN            VARCHAR2,
    p_cp_id                      IN            NUMBER,
    p_cp_os                      IN            VARCHAR2,
    p_cp_osr                     IN            VARCHAR2,
    p_cp_type                    IN            VARCHAR2,
    p_create_or_update           IN            VARCHAR2 := 'C',
    px_eft_rec                   IN OUT NOCOPY HZ_CONTACT_POINT_V2PUB.EFT_REC_TYPE,
    px_contact_point_rec         IN OUT NOCOPY HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE
  );

  -- PRIVATE PROCEDURE assign_sms_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from sms business object to plsql record.
  --
  -- ARGUMENTS
  --   IN:
  --     p_sms_obj            SMS business object.
  --     p_owner_table_id     Owner table Id.
  --     p_owner_table_name   Owner table name.
  --     p_cp_id              Contact point Id.
  --     p_cp_os              Contact point original system.
  --     p_cp_osr             Contact point original system reference.
  --     p_cp_type            Contact point type.
  --     p_created_by_module  Created by module.
  --   IN/OUT:
  --     px_sms_rec           SMS plsql record.
  --     px_contact_point_rec Contact point plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_sms_rec(
    p_sms_obj                    IN            HZ_SMS_CP_BO,
    p_owner_table_id             IN            NUMBER,
    p_owner_table_name           IN            VARCHAR2,
    p_cp_id                      IN            NUMBER,
    p_cp_os                      IN            VARCHAR2,
    p_cp_osr                     IN            VARCHAR2,
    p_cp_type                    IN            VARCHAR2,
    p_create_or_update           IN            VARCHAR2 := 'C',
    px_sms_rec                   IN OUT NOCOPY HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE,
    px_contact_point_rec         IN OUT NOCOPY HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE
  );

  -- PROCEDURE create_phone_bo
  --
  -- DESCRIPTION
  --     Create a logical phone contact point.
  PROCEDURE create_phone_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_phone_obj           IN            HZ_PHONE_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_phone_id            OUT NOCOPY    NUMBER,
    x_phone_os            OUT NOCOPY    VARCHAR2,
    x_phone_osr           OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  ) IS
    l_phone_obj           HZ_PHONE_CP_BO;
  BEGIN
    l_phone_obj := p_phone_obj;
    do_create_contact_point (
      p_init_msg_list      => p_init_msg_list,
      p_validate_bo_flag   => p_validate_bo_flag,
      p_cp_id              => l_phone_obj.phone_id,
      p_cp_os              => l_phone_obj.orig_system,
      p_cp_osr             => l_phone_obj.orig_system_reference,
      p_phone_obj          => l_phone_obj,
      p_email_obj          => NULL,
      p_telex_obj          => NULL,
      p_web_obj            => NULL,
      p_edi_obj            => NULL,
      p_eft_obj            => NULL,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_phone_obj.contact_pref_objs,
      p_cp_type            => 'PHONE',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => null,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      x_cp_id              => x_phone_id,
      x_cp_os              => x_phone_os,
      x_cp_osr             => x_phone_osr,
      px_parent_id         => px_parent_id,
      px_parent_os         => px_parent_os,
      px_parent_osr        => px_parent_osr,
      px_parent_obj_type   => px_parent_obj_type
    );
  END create_phone_bo;

  PROCEDURE create_phone_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_phone_obj           IN            HZ_PHONE_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_PHONE_CP_BO,
    x_phone_id            OUT NOCOPY    NUMBER,
    x_phone_os            OUT NOCOPY    VARCHAR2,
    x_phone_osr           OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  ) IS
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);
    l_phone_obj           HZ_PHONE_CP_BO;
  BEGIN
    l_phone_obj := p_phone_obj;
    do_create_contact_point (
      p_init_msg_list      => fnd_api.g_true,
      p_validate_bo_flag   => p_validate_bo_flag,
      p_cp_id              => l_phone_obj.phone_id,
      p_cp_os              => l_phone_obj.orig_system,
      p_cp_osr             => l_phone_obj.orig_system_reference,
      p_phone_obj          => l_phone_obj,
      p_email_obj          => NULL,
      p_telex_obj          => NULL,
      p_web_obj            => NULL,
      p_edi_obj            => NULL,
      p_eft_obj            => NULL,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_phone_obj.contact_pref_objs,
      p_cp_type            => 'PHONE',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => p_obj_source,
      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,
      x_cp_id              => x_phone_id,
      x_cp_os              => x_phone_os,
      x_cp_osr             => x_phone_osr,
      px_parent_id         => px_parent_id,
      px_parent_os         => px_parent_os,
      px_parent_osr        => px_parent_osr,
      px_parent_obj_type   => px_parent_obj_type
    );
    l_phone_obj.phone_id := x_phone_id;
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_phone_obj;
    END IF;
  END create_phone_bo;

  -- PROCEDURE create_telex_bo
  --
  -- DESCRIPTION
  --     Create a logical telex contact point.
  PROCEDURE create_telex_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_telex_obj           IN            HZ_TELEX_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_telex_id            OUT NOCOPY    NUMBER,
    x_telex_os            OUT NOCOPY    VARCHAR2,
    x_telex_osr           OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  ) IS
    l_telex_obj           HZ_TELEX_CP_BO;
  BEGIN
    l_telex_obj := p_telex_obj;
    do_create_contact_point (
      p_init_msg_list      => p_init_msg_list,
      p_validate_bo_flag   => p_validate_bo_flag,
      p_cp_id              => l_telex_obj.telex_id,
      p_cp_os              => l_telex_obj.orig_system,
      p_cp_osr             => l_telex_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => NULL,
      p_telex_obj          => l_telex_obj,
      p_web_obj            => NULL,
      p_edi_obj            => NULL,
      p_eft_obj            => NULL,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_telex_obj.contact_pref_objs,
      p_cp_type            => 'TLX',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => null,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      x_cp_id              => x_telex_id,
      x_cp_os              => x_telex_os,
      x_cp_osr             => x_telex_osr,
      px_parent_id         => px_parent_id,
      px_parent_os         => px_parent_os,
      px_parent_osr        => px_parent_osr,
      px_parent_obj_type   => px_parent_obj_type
    );
  END create_telex_bo;

  PROCEDURE create_telex_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_telex_obj           IN            HZ_TELEX_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_TELEX_CP_BO,
    x_telex_id            OUT NOCOPY    NUMBER,
    x_telex_os            OUT NOCOPY    VARCHAR2,
    x_telex_osr           OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  ) IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
    l_telex_obj           HZ_TELEX_CP_BO;
  BEGIN
    l_telex_obj := p_telex_obj;
    do_create_contact_point (
      p_init_msg_list      => fnd_api.g_true,
      p_validate_bo_flag   => p_validate_bo_flag,
      p_cp_id              => l_telex_obj.telex_id,
      p_cp_os              => l_telex_obj.orig_system,
      p_cp_osr             => l_telex_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => NULL,
      p_telex_obj          => l_telex_obj,
      p_web_obj            => NULL,
      p_edi_obj            => NULL,
      p_eft_obj            => NULL,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_telex_obj.contact_pref_objs,
      p_cp_type            => 'TLX',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => p_obj_source,
      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,
      x_cp_id              => x_telex_id,
      x_cp_os              => x_telex_os,
      x_cp_osr             => x_telex_osr,
      px_parent_id         => px_parent_id,
      px_parent_os         => px_parent_os,
      px_parent_osr        => px_parent_osr,
      px_parent_obj_type   => px_parent_obj_type
    );
    l_telex_obj.telex_id := x_telex_id;
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_telex_obj;
    END IF;
  END create_telex_bo;

  -- PROCEDURE create_email_bo
  --
  -- DESCRIPTION
  --     Create a logical email contact point.
  PROCEDURE create_email_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_email_obj           IN            HZ_EMAIL_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_email_id            OUT NOCOPY    NUMBER,
    x_email_os            OUT NOCOPY    VARCHAR2,
    x_email_osr           OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  ) IS
    l_email_obj           HZ_EMAIL_CP_BO;
  BEGIN
    l_email_obj := p_email_obj;
    do_create_contact_point (
      p_init_msg_list      => p_init_msg_list,
      p_validate_bo_flag   => p_validate_bo_flag,
      p_cp_id              => l_email_obj.email_id,
      p_cp_os              => l_email_obj.orig_system,
      p_cp_osr             => l_email_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => l_email_obj,
      p_telex_obj          => NULL,
      p_web_obj            => NULL,
      p_edi_obj            => NULL,
      p_eft_obj            => NULL,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_email_obj.contact_pref_objs,
      p_cp_type            => 'EMAIL',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => null,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      x_cp_id              => x_email_id,
      x_cp_os              => x_email_os,
      x_cp_osr             => x_email_osr,
      px_parent_id         => px_parent_id,
      px_parent_os         => px_parent_os,
      px_parent_osr        => px_parent_osr,
      px_parent_obj_type   => px_parent_obj_type);
  END create_email_bo;

  PROCEDURE create_email_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_email_obj           IN            HZ_EMAIL_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_EMAIL_CP_BO,
    x_email_id            OUT NOCOPY    NUMBER,
    x_email_os            OUT NOCOPY    VARCHAR2,
    x_email_osr           OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  ) IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
    l_email_obj           HZ_EMAIL_CP_BO;
  BEGIN
    l_email_obj := p_email_obj;
    do_create_contact_point (
      p_init_msg_list      => fnd_api.g_true,
      p_validate_bo_flag   => p_validate_bo_flag,
      p_cp_id              => l_email_obj.email_id,
      p_cp_os              => l_email_obj.orig_system,
      p_cp_osr             => l_email_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => l_email_obj,
      p_telex_obj          => NULL,
      p_web_obj            => NULL,
      p_edi_obj            => NULL,
      p_eft_obj            => NULL,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_email_obj.contact_pref_objs,
      p_cp_type            => 'EMAIL',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => p_obj_source,
      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,
      x_cp_id              => x_email_id,
      x_cp_os              => x_email_os,
      x_cp_osr             => x_email_osr,
      px_parent_id         => px_parent_id,
      px_parent_os         => px_parent_os,
      px_parent_osr        => px_parent_osr,
      px_parent_obj_type   => px_parent_obj_type);
    l_email_obj.email_id := x_email_id;
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_email_obj;
    END IF;
  END create_email_bo;

  -- PROCEDURE create_web_bo
  --
  -- DESCRIPTION
  --     Create a logical web contact point.
  PROCEDURE create_web_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_web_obj             IN            HZ_WEB_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_web_id              OUT NOCOPY    NUMBER,
    x_web_os              OUT NOCOPY    VARCHAR2,
    x_web_osr             OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  ) IS
    l_web_obj             HZ_WEB_CP_BO;
  BEGIN
    l_web_obj := p_web_obj;
    do_create_contact_point (
      p_init_msg_list      => p_init_msg_list,
      p_validate_bo_flag   => p_validate_bo_flag,
      p_cp_id              => l_web_obj.web_id,
      p_cp_os              => l_web_obj.orig_system,
      p_cp_osr             => l_web_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => NULL,
      p_telex_obj          => NULL,
      p_web_obj            => l_web_obj,
      p_edi_obj            => NULL,
      p_eft_obj            => NULL,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_web_obj.contact_pref_objs,
      p_cp_type            => 'WEB',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => null,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      x_cp_id              => x_web_id,
      x_cp_os              => x_web_os,
      x_cp_osr             => x_web_osr,
      px_parent_id         => px_parent_id,
      px_parent_os         => px_parent_os,
      px_parent_osr        => px_parent_osr,
      px_parent_obj_type   => px_parent_obj_type);
  END create_web_bo;

  PROCEDURE create_web_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_web_obj             IN            HZ_WEB_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_WEB_CP_BO,
    x_web_id              OUT NOCOPY    NUMBER,
    x_web_os              OUT NOCOPY    VARCHAR2,
    x_web_osr             OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  ) IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
    l_web_obj             HZ_WEB_CP_BO;
  BEGIN
    l_web_obj := p_web_obj;
    do_create_contact_point (
      p_init_msg_list      => fnd_api.g_true,
      p_validate_bo_flag   => p_validate_bo_flag,
      p_cp_id              => l_web_obj.web_id,
      p_cp_os              => l_web_obj.orig_system,
      p_cp_osr             => l_web_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => NULL,
      p_telex_obj          => NULL,
      p_web_obj            => l_web_obj,
      p_edi_obj            => NULL,
      p_eft_obj            => NULL,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_web_obj.contact_pref_objs,
      p_cp_type            => 'WEB',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => p_obj_source,
      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,
      x_cp_id              => x_web_id,
      x_cp_os              => x_web_os,
      x_cp_osr             => x_web_osr,
      px_parent_id         => px_parent_id,
      px_parent_os         => px_parent_os,
      px_parent_osr        => px_parent_osr,
      px_parent_obj_type   => px_parent_obj_type);
    l_web_obj.web_id := x_web_id;
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_web_obj;
    END IF;
  END create_web_bo;

  -- PROCEDURE create_edi_bo
  --
  -- DESCRIPTION
  --     Create a logical edi contact point.
  PROCEDURE create_edi_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_edi_obj             IN            HZ_EDI_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_edi_id              OUT NOCOPY    NUMBER,
    x_edi_os              OUT NOCOPY    VARCHAR2,
    x_edi_osr             OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  ) IS
    l_edi_obj             HZ_EDI_CP_BO;
  BEGIN
    l_edi_obj := p_edi_obj;
    do_create_contact_point (
      p_init_msg_list      => p_init_msg_list,
      p_validate_bo_flag   => p_validate_bo_flag,
      p_cp_id              => l_edi_obj.edi_id,
      p_cp_os              => l_edi_obj.orig_system,
      p_cp_osr             => l_edi_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => NULL,
      p_telex_obj          => NULL,
      p_web_obj            => NULL,
      p_edi_obj            => l_edi_obj,
      p_eft_obj            => NULL,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_edi_obj.contact_pref_objs,
      p_cp_type            => 'EDI',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => null,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      x_cp_id              => x_edi_id,
      x_cp_os              => x_edi_os,
      x_cp_osr             => x_edi_osr,
      px_parent_id         => px_parent_id,
      px_parent_os         => px_parent_os,
      px_parent_osr        => px_parent_osr,
      px_parent_obj_type   => px_parent_obj_type);
  END create_edi_bo;

  PROCEDURE create_edi_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_edi_obj             IN            HZ_EDI_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_EDI_CP_BO,
    x_edi_id              OUT NOCOPY    NUMBER,
    x_edi_os              OUT NOCOPY    VARCHAR2,
    x_edi_osr             OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  ) IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
    l_edi_obj             HZ_EDI_CP_BO;
  BEGIN
    l_edi_obj := p_edi_obj;
    do_create_contact_point (
      p_init_msg_list      => fnd_api.g_true,
      p_validate_bo_flag   => p_validate_bo_flag,
      p_cp_id              => l_edi_obj.edi_id,
      p_cp_os              => l_edi_obj.orig_system,
      p_cp_osr             => l_edi_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => NULL,
      p_telex_obj          => NULL,
      p_web_obj            => NULL,
      p_edi_obj            => l_edi_obj,
      p_eft_obj            => NULL,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_edi_obj.contact_pref_objs,
      p_cp_type            => 'EDI',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => p_obj_source,
      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,
      x_cp_id              => x_edi_id,
      x_cp_os              => x_edi_os,
      x_cp_osr             => x_edi_osr,
      px_parent_id         => px_parent_id,
      px_parent_os         => px_parent_os,
      px_parent_osr        => px_parent_osr,
      px_parent_obj_type   => px_parent_obj_type);
    l_edi_obj.edi_id := x_edi_id;
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_edi_obj;
    END IF;
  END create_edi_bo;

  -- PROCEDURE create_eft_bo
  --
  -- DESCRIPTION
  --     Create a logical eft contact point.
  PROCEDURE create_eft_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_eft_obj             IN            HZ_EFT_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_eft_id              OUT NOCOPY    NUMBER,
    x_eft_os              OUT NOCOPY    VARCHAR2,
    x_eft_osr             OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  ) IS
    l_eft_obj             HZ_EFT_CP_BO;
  BEGIN
    l_eft_obj := p_eft_obj;
    do_create_contact_point (
      p_init_msg_list      => p_init_msg_list,
      p_validate_bo_flag   => p_validate_bo_flag,
      p_cp_id              => l_eft_obj.eft_id,
      p_cp_os              => l_eft_obj.orig_system,
      p_cp_osr             => l_eft_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => NULL,
      p_telex_obj          => NULL,
      p_web_obj            => NULL,
      p_edi_obj            => NULL,
      p_eft_obj            => l_eft_obj,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_eft_obj.contact_pref_objs,
      p_cp_type            => 'EFT',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => null,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      x_cp_id              => x_eft_id,
      x_cp_os              => x_eft_os,
      x_cp_osr             => x_eft_osr,
      px_parent_id         => px_parent_id,
      px_parent_os         => px_parent_os,
      px_parent_osr        => px_parent_osr,
      px_parent_obj_type   => px_parent_obj_type);
  END create_eft_bo;

  PROCEDURE create_eft_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_eft_obj             IN            HZ_EFT_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_EFT_CP_BO,
    x_eft_id              OUT NOCOPY    NUMBER,
    x_eft_os              OUT NOCOPY    VARCHAR2,
    x_eft_osr             OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  ) IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
    l_eft_obj             HZ_EFT_CP_BO;
  BEGIN
    l_eft_obj := p_eft_obj;
    do_create_contact_point (
      p_init_msg_list      => fnd_api.g_true,
      p_validate_bo_flag   => p_validate_bo_flag,
      p_cp_id              => l_eft_obj.eft_id,
      p_cp_os              => l_eft_obj.orig_system,
      p_cp_osr             => l_eft_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => NULL,
      p_telex_obj          => NULL,
      p_web_obj            => NULL,
      p_edi_obj            => NULL,
      p_eft_obj            => l_eft_obj,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_eft_obj.contact_pref_objs,
      p_cp_type            => 'EFT',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => p_obj_source,
      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,
      x_cp_id              => x_eft_id,
      x_cp_os              => x_eft_os,
      x_cp_osr             => x_eft_osr,
      px_parent_id         => px_parent_id,
      px_parent_os         => px_parent_os,
      px_parent_osr        => px_parent_osr,
      px_parent_obj_type   => px_parent_obj_type);
    l_eft_obj.eft_id := x_eft_id;
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_eft_obj;
    END IF;
  END create_eft_bo;

  -- PROCEDURE create_sms_bo
  --
  -- DESCRIPTION
  --     Create a logical sms contact point.
  PROCEDURE create_sms_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_sms_obj             IN            HZ_SMS_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_sms_id              OUT NOCOPY    NUMBER,
    x_sms_os              OUT NOCOPY    VARCHAR2,
    x_sms_osr             OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  ) IS
    l_sms_obj             HZ_SMS_CP_BO;
  BEGIN
    l_sms_obj := p_sms_obj;
    do_create_contact_point (
      p_init_msg_list      => p_init_msg_list,
      p_validate_bo_flag   => p_validate_bo_flag,
      p_cp_id              => l_sms_obj.sms_id,
      p_cp_os              => l_sms_obj.orig_system,
      p_cp_osr             => l_sms_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => NULL,
      p_telex_obj          => NULL,
      p_web_obj            => NULL,
      p_edi_obj            => NULL,
      p_eft_obj            => NULL,
      p_sms_obj            => l_sms_obj,
      p_cp_pref_objs       => l_sms_obj.contact_pref_objs,
      p_cp_type            => 'SMS',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => null,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      x_cp_id              => x_sms_id,
      x_cp_os              => x_sms_os,
      x_cp_osr             => x_sms_osr,
      px_parent_id         => px_parent_id,
      px_parent_os         => px_parent_os,
      px_parent_osr        => px_parent_osr,
      px_parent_obj_type   => px_parent_obj_type);
  END create_sms_bo;

  PROCEDURE create_sms_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_sms_obj             IN            HZ_SMS_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAr2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_SMS_CP_BO,
    x_sms_id              OUT NOCOPY    NUMBER,
    x_sms_os              OUT NOCOPY    VARCHAR2,
    x_sms_osr             OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  ) IS
    l_msg_data             VARCHAR2(2000);
    l_msg_count            NUMBER;
    l_sms_obj              HZ_SMS_CP_BO;
  BEGIN
    l_sms_obj := p_sms_obj;
    do_create_contact_point (
      p_init_msg_list      => fnd_api.g_true,
      p_validate_bo_flag   => p_validate_bo_flag,
      p_cp_id              => l_sms_obj.sms_id,
      p_cp_os              => l_sms_obj.orig_system,
      p_cp_osr             => l_sms_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => NULL,
      p_telex_obj          => NULL,
      p_web_obj            => NULL,
      p_edi_obj            => NULL,
      p_eft_obj            => NULL,
      p_sms_obj            => l_sms_obj,
      p_cp_pref_objs       => l_sms_obj.contact_pref_objs,
      p_cp_type            => 'SMS',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => p_obj_source,
      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,
      x_cp_id              => x_sms_id,
      x_cp_os              => x_sms_os,
      x_cp_osr             => x_sms_osr,
      px_parent_id         => px_parent_id,
      px_parent_os         => px_parent_os,
      px_parent_osr        => px_parent_osr,
      px_parent_obj_type   => px_parent_obj_type);
    l_sms_obj.sms_id := x_sms_id;
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_sms_obj;
    END IF;
  END create_sms_bo;

  -- PRIVATE PROCEDURE assign_phone_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from phone business object to plsql record.
  --
  -- ARGUMENTS
  --   IN:
  --     p_phone_obj          Phone business object.
  --     p_owner_table_id     Owner table Id.
  --     p_owner_table_name   Owner table name.
  --     p_cp_id              Contact point Id.
  --     p_cp_os              Contact point original system.
  --     p_cp_osr             Contact point original system reference.
  --     p_cp_type            Contact point type.
  --     p_created_by_module  Created by module.
  --   IN/OUT:
  --     px_phone_rec         Phone plsql record.
  --     px_contact_point_rec Contact point plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_phone_rec(
    p_phone_obj                  IN            HZ_PHONE_CP_BO,
    p_owner_table_id             IN            NUMBER,
    p_owner_table_name           IN            VARCHAR2,
    p_cp_id                      IN            NUMBER,
    p_cp_os                      IN            VARCHAR2,
    p_cp_osr                     IN            VARCHAR2,
    p_cp_type                    IN            VARCHAR2,
    p_create_or_update           IN            VARCHAR2 := 'C',
    px_phone_rec                 IN OUT NOCOPY HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE,
    px_contact_point_rec         IN OUT NOCOPY HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE
  ) IS
  BEGIN
    px_contact_point_rec.contact_point_id       := p_cp_id;
    px_contact_point_rec.contact_point_type     := p_cp_type;
    IF(p_phone_obj.status IN ('A','I')) THEN
      px_contact_point_rec.status               := p_phone_obj.status;
    ELSE
      px_contact_point_rec.status               := NULL;
    END IF;
    px_contact_point_rec.owner_table_name       := p_owner_table_name;
    px_contact_point_rec.owner_table_id         := p_owner_table_id;
    IF(p_phone_obj.primary_flag in ('Y','N')) THEN
      px_contact_point_rec.primary_flag         := p_phone_obj.primary_flag;
    ELSE
      px_contact_point_rec.primary_flag         := NULL;
    END IF;
    px_contact_point_rec.attribute_category     := p_phone_obj.attribute_category;
    px_contact_point_rec.attribute1             := p_phone_obj.attribute1;
    px_contact_point_rec.attribute2             := p_phone_obj.attribute2;
    px_contact_point_rec.attribute3             := p_phone_obj.attribute3;
    px_contact_point_rec.attribute4             := p_phone_obj.attribute4;
    px_contact_point_rec.attribute5             := p_phone_obj.attribute5;
    px_contact_point_rec.attribute6             := p_phone_obj.attribute6;
    px_contact_point_rec.attribute7             := p_phone_obj.attribute7;
    px_contact_point_rec.attribute8             := p_phone_obj.attribute8;
    px_contact_point_rec.attribute9             := p_phone_obj.attribute9;
    px_contact_point_rec.attribute10            := p_phone_obj.attribute10;
    px_contact_point_rec.attribute11            := p_phone_obj.attribute11;
    px_contact_point_rec.attribute12            := p_phone_obj.attribute12;
    px_contact_point_rec.attribute13            := p_phone_obj.attribute13;
    px_contact_point_rec.attribute14            := p_phone_obj.attribute14;
    px_contact_point_rec.attribute15            := p_phone_obj.attribute15;
    px_contact_point_rec.attribute16            := p_phone_obj.attribute16;
    px_contact_point_rec.attribute17            := p_phone_obj.attribute17;
    px_contact_point_rec.attribute18            := p_phone_obj.attribute18;
    px_contact_point_rec.attribute19            := p_phone_obj.attribute19;
    px_contact_point_rec.attribute20            := p_phone_obj.attribute20;
    px_contact_point_rec.contact_point_purpose  := p_phone_obj.contact_point_purpose;
    px_contact_point_rec.primary_by_purpose     := p_phone_obj.primary_by_purpose;
    IF(p_create_or_update = 'C') THEN
      px_contact_point_rec.orig_system            := p_cp_os;
      px_contact_point_rec.orig_system_reference  := p_cp_osr;
      px_contact_point_rec.created_by_module      := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
    END IF;
    px_contact_point_rec.actual_content_source  := p_phone_obj.actual_content_source;
    px_phone_rec.phone_calling_calendar := p_phone_obj.phone_calling_calendar;
    px_phone_rec.last_contact_dt_time   := p_phone_obj.last_contact_dt_time;
    px_phone_rec.timezone_id            := p_phone_obj.timezone_id;
    px_phone_rec.phone_area_code        := p_phone_obj.phone_area_code;
    px_phone_rec.phone_country_code     := p_phone_obj.phone_country_code;
    px_phone_rec.phone_number           := p_phone_obj.phone_number;
    px_phone_rec.phone_extension        := p_phone_obj.phone_extension;
    px_phone_rec.phone_line_type        := p_phone_obj.phone_line_type;
    px_phone_rec.raw_phone_number       := p_phone_obj.raw_phone_number;
  END assign_phone_rec;

  -- PRIVATE PROCEDURE assign_telex_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from telex business object to plsql record.
  --
  -- ARGUMENTS
  --   IN:
  --     p_telex_obj          Telex business object.
  --     p_owner_table_id     Owner table Id.
  --     p_owner_table_name   Owner table name.
  --     p_cp_id              Contact point Id.
  --     p_cp_os              Contact point original system.
  --     p_cp_osr             Contact point original system reference.
  --     p_cp_type            Contact point type.
  --     p_created_by_module  Created by module.
  --   IN/OUT:
  --     px_telex_rec         Telex plsql record.
  --     px_contact_point_rec Contact point plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_telex_rec(
    p_telex_obj                  IN            HZ_TELEX_CP_BO,
    p_owner_table_id             IN            NUMBER,
    p_owner_table_name           IN            VARCHAR2,
    p_cp_id                      IN            NUMBER,
    p_cp_os                      IN            VARCHAR2,
    p_cp_osr                     IN            VARCHAR2,
    p_cp_type                    IN            VARCHAR2,
    p_create_or_update           IN            VARCHAR2 := 'C',
    px_telex_rec                 IN OUT NOCOPY HZ_CONTACT_POINT_V2PUB.TELEX_REC_TYPE,
    px_contact_point_rec         IN OUT NOCOPY HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE
  ) IS
  BEGIN
    px_contact_point_rec.contact_point_id       := p_cp_id;
    px_contact_point_rec.contact_point_type     := p_cp_type;
    IF(p_telex_obj.status in ('A','I')) THEN
      px_contact_point_rec.status               := p_telex_obj.status;
    ELSE
      px_contact_point_rec.status               := NULL;
    END IF;
    px_contact_point_rec.owner_table_name       := p_owner_table_name;
    px_contact_point_rec.owner_table_id         := p_owner_table_id;
    IF(p_telex_obj.primary_flag in ('Y','N')) THEN
      px_contact_point_rec.primary_flag           := p_telex_obj.primary_flag;
    ELSE
      px_contact_point_rec.primary_flag           := NULL;
    END IF;
    px_contact_point_rec.attribute_category     := p_telex_obj.attribute_category;
    px_contact_point_rec.attribute1             := p_telex_obj.attribute1;
    px_contact_point_rec.attribute2             := p_telex_obj.attribute2;
    px_contact_point_rec.attribute3             := p_telex_obj.attribute3;
    px_contact_point_rec.attribute4             := p_telex_obj.attribute4;
    px_contact_point_rec.attribute5             := p_telex_obj.attribute5;
    px_contact_point_rec.attribute6             := p_telex_obj.attribute6;
    px_contact_point_rec.attribute7             := p_telex_obj.attribute7;
    px_contact_point_rec.attribute8             := p_telex_obj.attribute8;
    px_contact_point_rec.attribute9             := p_telex_obj.attribute9;
    px_contact_point_rec.attribute10            := p_telex_obj.attribute10;
    px_contact_point_rec.attribute11            := p_telex_obj.attribute11;
    px_contact_point_rec.attribute12            := p_telex_obj.attribute12;
    px_contact_point_rec.attribute13            := p_telex_obj.attribute13;
    px_contact_point_rec.attribute14            := p_telex_obj.attribute14;
    px_contact_point_rec.attribute15            := p_telex_obj.attribute15;
    px_contact_point_rec.attribute16            := p_telex_obj.attribute16;
    px_contact_point_rec.attribute17            := p_telex_obj.attribute17;
    px_contact_point_rec.attribute18            := p_telex_obj.attribute18;
    px_contact_point_rec.attribute19            := p_telex_obj.attribute19;
    px_contact_point_rec.attribute20            := p_telex_obj.attribute20;
    px_contact_point_rec.contact_point_purpose  := p_telex_obj.contact_point_purpose;
    px_contact_point_rec.primary_by_purpose     := p_telex_obj.primary_by_purpose;
    IF(p_create_or_update = 'C') THEN
      px_contact_point_rec.orig_system            := p_cp_os;
      px_contact_point_rec.orig_system_reference  := p_cp_osr;
      px_contact_point_rec.created_by_module      := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
    END IF;
    px_contact_point_rec.actual_content_source  := p_telex_obj.actual_content_source;
    px_telex_rec.telex_number                   := p_telex_obj.telex_number;
  END assign_telex_rec;

  -- PRIVATE PROCEDURE assign_email_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from email business object to plsql record.
  --
  -- ARGUMENTS
  --   IN:
  --     p_email_obj          Email business object.
  --     p_owner_table_id     Owner table Id.
  --     p_owner_table_name   Owner table name.
  --     p_cp_id              Contact point Id.
  --     p_cp_os              Contact point original system.
  --     p_cp_osr             Contact point original system reference.
  --     p_cp_type            Contact point type.
  --     p_created_by_module  Created by module.
  --   IN/OUT:
  --     px_email_rec         Email plsql record.
  --     px_contact_point_rec Contact point plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_email_rec(
    p_email_obj                  IN            HZ_EMAIL_CP_BO,
    p_owner_table_id             IN            NUMBER,
    p_owner_table_name           IN            VARCHAR2,
    p_cp_id                      IN            NUMBER,
    p_cp_os                      IN            VARCHAR2,
    p_cp_osr                     IN            VARCHAR2,
    p_cp_type                    IN            VARCHAR2,
    p_create_or_update           IN            VARCHAR2 := 'C',
    px_email_rec                 IN OUT NOCOPY HZ_CONTACT_POINT_V2PUB.EMAIL_REC_TYPE,
    px_contact_point_rec         IN OUT NOCOPY HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE
  ) IS
  BEGIN
    px_contact_point_rec.contact_point_id       := p_cp_id;
    px_contact_point_rec.contact_point_type     := p_cp_type;
    IF(p_email_obj.status in ('A','I')) THEN
      px_contact_point_rec.status               := p_email_obj.status;
    ELSE
      px_contact_point_rec.status               := NULL;
    END IF;
    px_contact_point_rec.owner_table_name       := p_owner_table_name;
    px_contact_point_rec.owner_table_id         := p_owner_table_id;
    IF(p_email_obj.primary_flag in ('Y','N')) THEN
      px_contact_point_rec.primary_flag           := p_email_obj.primary_flag;
    ELSE
      px_contact_point_rec.primary_flag           := NULL;
    END IF;
    px_contact_point_rec.attribute_category     := p_email_obj.attribute_category;
    px_contact_point_rec.attribute1             := p_email_obj.attribute1;
    px_contact_point_rec.attribute2             := p_email_obj.attribute2;
    px_contact_point_rec.attribute3             := p_email_obj.attribute3;
    px_contact_point_rec.attribute4             := p_email_obj.attribute4;
    px_contact_point_rec.attribute5             := p_email_obj.attribute5;
    px_contact_point_rec.attribute6             := p_email_obj.attribute6;
    px_contact_point_rec.attribute7             := p_email_obj.attribute7;
    px_contact_point_rec.attribute8             := p_email_obj.attribute8;
    px_contact_point_rec.attribute9             := p_email_obj.attribute9;
    px_contact_point_rec.attribute10            := p_email_obj.attribute10;
    px_contact_point_rec.attribute11            := p_email_obj.attribute11;
    px_contact_point_rec.attribute12            := p_email_obj.attribute12;
    px_contact_point_rec.attribute13            := p_email_obj.attribute13;
    px_contact_point_rec.attribute14            := p_email_obj.attribute14;
    px_contact_point_rec.attribute15            := p_email_obj.attribute15;
    px_contact_point_rec.attribute16            := p_email_obj.attribute16;
    px_contact_point_rec.attribute17            := p_email_obj.attribute17;
    px_contact_point_rec.attribute18            := p_email_obj.attribute18;
    px_contact_point_rec.attribute19            := p_email_obj.attribute19;
    px_contact_point_rec.attribute20            := p_email_obj.attribute20;
    px_contact_point_rec.contact_point_purpose  := p_email_obj.contact_point_purpose;
    px_contact_point_rec.primary_by_purpose     := p_email_obj.primary_by_purpose;
    IF(p_create_or_update = 'C') THEN
      px_contact_point_rec.orig_system            := p_cp_os;
      px_contact_point_rec.orig_system_reference  := p_cp_osr;
      px_contact_point_rec.created_by_module      := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
    END IF;
    px_contact_point_rec.actual_content_source  := p_email_obj.actual_content_source;
    px_email_rec.email_format  := p_email_obj.email_format;
    px_email_rec.email_address := p_email_obj.email_address;
  END assign_email_rec;

  -- PRIVATE PROCEDURE assign_web_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from web business object to plsql record.
  --
  -- ARGUMENTS
  --   IN:
  --     p_web_obj            Web business object.
  --     p_owner_table_id     Owner table Id.
  --     p_owner_table_name   Owner table name.
  --     p_cp_id              Contact point Id.
  --     p_cp_os              Contact point original system.
  --     p_cp_osr             Contact point original system reference.
  --     p_cp_type            Contact point type.
  --     p_created_by_module  Created by module.
  --   IN/OUT:
  --     px_web_rec           Web plsql record.
  --     px_contact_point_rec Contact point plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_web_rec(
    p_web_obj                    IN            HZ_WEB_CP_BO,
    p_owner_table_id             IN            NUMBER,
    p_owner_table_name           IN            VARCHAR2,
    p_cp_id                      IN            NUMBER,
    p_cp_os                      IN            VARCHAR2,
    p_cp_osr                     IN            VARCHAR2,
    p_cp_type                    IN            VARCHAR2,
    p_create_or_update           IN            VARCHAR2 := 'C',
    px_web_rec                   IN OUT NOCOPY HZ_CONTACT_POINT_V2PUB.WEB_REC_TYPE,
    px_contact_point_rec         IN OUT NOCOPY HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE
  ) IS
  BEGIN
    px_contact_point_rec.contact_point_id       := p_cp_id;
    px_contact_point_rec.contact_point_type     := p_cp_type;
    IF(p_web_obj.status in ('A','I')) THEN
      px_contact_point_rec.status               := p_web_obj.status;
    ELSE
      px_contact_point_rec.status               := NULL;
    END IF;
    px_contact_point_rec.owner_table_name       := p_owner_table_name;
    px_contact_point_rec.owner_table_id         := p_owner_table_id;
    IF(p_web_obj.primary_flag in ('Y','N')) THEN
      px_contact_point_rec.primary_flag           := p_web_obj.primary_flag;
    ELSE
      px_contact_point_rec.primary_flag           := NULL;
    END IF;
    px_contact_point_rec.attribute_category     := p_web_obj.attribute_category;
    px_contact_point_rec.attribute1             := p_web_obj.attribute1;
    px_contact_point_rec.attribute2             := p_web_obj.attribute2;
    px_contact_point_rec.attribute3             := p_web_obj.attribute3;
    px_contact_point_rec.attribute4             := p_web_obj.attribute4;
    px_contact_point_rec.attribute5             := p_web_obj.attribute5;
    px_contact_point_rec.attribute6             := p_web_obj.attribute6;
    px_contact_point_rec.attribute7             := p_web_obj.attribute7;
    px_contact_point_rec.attribute8             := p_web_obj.attribute8;
    px_contact_point_rec.attribute9             := p_web_obj.attribute9;
    px_contact_point_rec.attribute10            := p_web_obj.attribute10;
    px_contact_point_rec.attribute11            := p_web_obj.attribute11;
    px_contact_point_rec.attribute12            := p_web_obj.attribute12;
    px_contact_point_rec.attribute13            := p_web_obj.attribute13;
    px_contact_point_rec.attribute14            := p_web_obj.attribute14;
    px_contact_point_rec.attribute15            := p_web_obj.attribute15;
    px_contact_point_rec.attribute16            := p_web_obj.attribute16;
    px_contact_point_rec.attribute17            := p_web_obj.attribute17;
    px_contact_point_rec.attribute18            := p_web_obj.attribute18;
    px_contact_point_rec.attribute19            := p_web_obj.attribute19;
    px_contact_point_rec.attribute20            := p_web_obj.attribute20;
    px_contact_point_rec.contact_point_purpose  := p_web_obj.contact_point_purpose;
    px_contact_point_rec.primary_by_purpose     := p_web_obj.primary_by_purpose;
    IF(p_create_or_update = 'C') THEN
      px_contact_point_rec.orig_system            := p_cp_os;
      px_contact_point_rec.orig_system_reference  := p_cp_osr;
      px_contact_point_rec.created_by_module      := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
    END IF;
    px_contact_point_rec.actual_content_source  := p_web_obj.actual_content_source;
    px_web_rec.web_type        := p_web_obj.web_type;
    px_web_rec.url             := p_web_obj.url;
  END assign_web_rec;

  -- PRIVATE PROCEDURE assign_edi_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from edi business object to plsql record.
  --
  -- ARGUMENTS
  --   IN:
  --     p_edi_obj            EDI business object.
  --     p_owner_table_id     Owner table Id.
  --     p_owner_table_name   Owner table name.
  --     p_cp_id              Contact point Id.
  --     p_cp_os              Contact point original system.
  --     p_cp_osr             Contact point original system reference.
  --     p_cp_type            Contact point type.
  --     p_created_by_module  Created by module.
  --   IN/OUT:
  --     px_edi_rec           EDI plsql record.
  --     px_contact_point_rec Contact point plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_edi_rec(
    p_edi_obj                    IN            HZ_EDI_CP_BO,
    p_owner_table_id             IN            NUMBER,
    p_owner_table_name           IN            VARCHAR2,
    p_cp_id                      IN            NUMBER,
    p_cp_os                      IN            VARCHAR2,
    p_cp_osr                     IN            VARCHAR2,
    p_cp_type                    IN            VARCHAR2,
    p_create_or_update           IN            VARCHAR2 := 'C',
    px_edi_rec                   IN OUT NOCOPY HZ_CONTACT_POINT_V2PUB.EDI_REC_TYPE,
    px_contact_point_rec         IN OUT NOCOPY HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE
  ) IS
  BEGIN
    px_contact_point_rec.contact_point_id       := p_cp_id;
    px_contact_point_rec.contact_point_type     := p_cp_type;
    IF(p_edi_obj.status in ('A','I')) THEN
      px_contact_point_rec.status               := p_edi_obj.status;
    ELSE
      px_contact_point_rec.status               := NULL;
    END IF;
    px_contact_point_rec.owner_table_name       := p_owner_table_name;
    px_contact_point_rec.owner_table_id         := p_owner_table_id;
    IF(p_edi_obj.primary_flag in ('Y','N')) THEN
      px_contact_point_rec.primary_flag           := p_edi_obj.primary_flag;
    ELSE
      px_contact_point_rec.primary_flag           := NULL;
    END IF;
    px_contact_point_rec.attribute_category     := p_edi_obj.attribute_category;
    px_contact_point_rec.attribute1             := p_edi_obj.attribute1;
    px_contact_point_rec.attribute2             := p_edi_obj.attribute2;
    px_contact_point_rec.attribute3             := p_edi_obj.attribute3;
    px_contact_point_rec.attribute4             := p_edi_obj.attribute4;
    px_contact_point_rec.attribute5             := p_edi_obj.attribute5;
    px_contact_point_rec.attribute6             := p_edi_obj.attribute6;
    px_contact_point_rec.attribute7             := p_edi_obj.attribute7;
    px_contact_point_rec.attribute8             := p_edi_obj.attribute8;
    px_contact_point_rec.attribute9             := p_edi_obj.attribute9;
    px_contact_point_rec.attribute10            := p_edi_obj.attribute10;
    px_contact_point_rec.attribute11            := p_edi_obj.attribute11;
    px_contact_point_rec.attribute12            := p_edi_obj.attribute12;
    px_contact_point_rec.attribute13            := p_edi_obj.attribute13;
    px_contact_point_rec.attribute14            := p_edi_obj.attribute14;
    px_contact_point_rec.attribute15            := p_edi_obj.attribute15;
    px_contact_point_rec.attribute16            := p_edi_obj.attribute16;
    px_contact_point_rec.attribute17            := p_edi_obj.attribute17;
    px_contact_point_rec.attribute18            := p_edi_obj.attribute18;
    px_contact_point_rec.attribute19            := p_edi_obj.attribute19;
    px_contact_point_rec.attribute20            := p_edi_obj.attribute20;
    px_contact_point_rec.contact_point_purpose  := p_edi_obj.contact_point_purpose;
    px_contact_point_rec.primary_by_purpose     := p_edi_obj.primary_by_purpose;
    IF(p_create_or_update = 'C') THEN
      px_contact_point_rec.orig_system            := p_cp_os;
      px_contact_point_rec.orig_system_reference  := p_cp_osr;
      px_contact_point_rec.created_by_module      := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
    END IF;
    px_contact_point_rec.actual_content_source  := p_edi_obj.actual_content_source;
    px_edi_rec.edi_transaction_handling   := p_edi_obj.edi_transaction_handling;
    px_edi_rec.edi_id_number              := p_edi_obj.edi_id_number;
    px_edi_rec.edi_payment_method         := p_edi_obj.edi_payment_method;
    px_edi_rec.edi_payment_format         := p_edi_obj.edi_payment_format;
    px_edi_rec.edi_remittance_method      := p_edi_obj.edi_remittance_method;
    px_edi_rec.edi_remittance_instruction := p_edi_obj.edi_remittance_instruction;
    px_edi_rec.edi_tp_header_id           := p_edi_obj.edi_tp_header_id;
    px_edi_rec.edi_ece_tp_location_code   := p_edi_obj.edi_ece_tp_location_code;
  END assign_edi_rec;

  -- PRIVATE PROCEDURE assign_eft_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from eft business object to plsql record.
  --
  -- ARGUMENTS
  --   IN:
  --     p_eft_obj            EFT business object.
  --     p_owner_table_id     Owner table Id.
  --     p_owner_table_name   Owner table name.
  --     p_cp_id              Contact point Id.
  --     p_cp_os              Contact point original system.
  --     p_cp_osr             Contact point original system reference.
  --     p_cp_type            Contact point type.
  --     p_created_by_module  Created by module.
  --   IN/OUT:
  --     px_eft_rec           EFT plsql record.
  --     px_contact_point_rec Contact point plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_eft_rec(
    p_eft_obj                    IN            HZ_EFT_CP_BO,
    p_owner_table_id             IN            NUMBER,
    p_owner_table_name           IN            VARCHAR2,
    p_cp_id                      IN            NUMBER,
    p_cp_os                      IN            VARCHAR2,
    p_cp_osr                     IN            VARCHAR2,
    p_cp_type                    IN            VARCHAR2,
    p_create_or_update           IN            VARCHAR2 := 'C',
    px_eft_rec                   IN OUT NOCOPY HZ_CONTACT_POINT_V2PUB.EFT_REC_TYPE,
    px_contact_point_rec         IN OUT NOCOPY HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE
  ) IS
  BEGIN
    px_contact_point_rec.contact_point_id       := p_cp_id;
    px_contact_point_rec.contact_point_type     := p_cp_type;
    IF(p_eft_obj.status in ('A','I')) THEN
      px_contact_point_rec.status               := p_eft_obj.status;
    ELSE
      px_contact_point_rec.status               := NULL;
    END IF;
    px_contact_point_rec.owner_table_name       := p_owner_table_name;
    px_contact_point_rec.owner_table_id         := p_owner_table_id;
    IF(p_eft_obj.primary_flag in ('Y','N')) THEN
      px_contact_point_rec.primary_flag           := p_eft_obj.primary_flag;
    ELSE
      px_contact_point_rec.primary_flag           := NULL;
    END IF;
    px_contact_point_rec.attribute_category     := p_eft_obj.attribute_category;
    px_contact_point_rec.attribute1             := p_eft_obj.attribute1;
    px_contact_point_rec.attribute2             := p_eft_obj.attribute2;
    px_contact_point_rec.attribute3             := p_eft_obj.attribute3;
    px_contact_point_rec.attribute4             := p_eft_obj.attribute4;
    px_contact_point_rec.attribute5             := p_eft_obj.attribute5;
    px_contact_point_rec.attribute6             := p_eft_obj.attribute6;
    px_contact_point_rec.attribute7             := p_eft_obj.attribute7;
    px_contact_point_rec.attribute8             := p_eft_obj.attribute8;
    px_contact_point_rec.attribute9             := p_eft_obj.attribute9;
    px_contact_point_rec.attribute10            := p_eft_obj.attribute10;
    px_contact_point_rec.attribute11            := p_eft_obj.attribute11;
    px_contact_point_rec.attribute12            := p_eft_obj.attribute12;
    px_contact_point_rec.attribute13            := p_eft_obj.attribute13;
    px_contact_point_rec.attribute14            := p_eft_obj.attribute14;
    px_contact_point_rec.attribute15            := p_eft_obj.attribute15;
    px_contact_point_rec.attribute16            := p_eft_obj.attribute16;
    px_contact_point_rec.attribute17            := p_eft_obj.attribute17;
    px_contact_point_rec.attribute18            := p_eft_obj.attribute18;
    px_contact_point_rec.attribute19            := p_eft_obj.attribute19;
    px_contact_point_rec.attribute20            := p_eft_obj.attribute20;
    px_contact_point_rec.contact_point_purpose  := p_eft_obj.contact_point_purpose;
    px_contact_point_rec.primary_by_purpose     := p_eft_obj.primary_by_purpose;
    IF(p_create_or_update = 'C') THEN
      px_contact_point_rec.orig_system            := p_cp_os;
      px_contact_point_rec.orig_system_reference  := p_cp_osr;
      px_contact_point_rec.created_by_module      := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
    END IF;
    px_contact_point_rec.actual_content_source  := p_eft_obj.actual_content_source;
    px_eft_rec.eft_transmission_program_id := p_eft_obj.eft_transmission_program_id;
    px_eft_rec.eft_printing_program_id     := p_eft_obj.eft_printing_program_id;
    px_eft_rec.eft_user_number             := p_eft_obj.eft_user_number;
    px_eft_rec.eft_swift_code              := p_eft_obj.eft_swift_code;
  END assign_eft_rec;

  -- PRIVATE PROCEDURE assign_sms_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from sms business object to plsql record.
  --
  -- ARGUMENTS
  --   IN:
  --     p_sms_obj            SMS business object.
  --     p_owner_table_id     Owner table Id.
  --     p_owner_table_name   Owner table name.
  --     p_cp_id              Contact point Id.
  --     p_cp_os              Contact point original system.
  --     p_cp_osr             Contact point original system reference.
  --     p_cp_type            Contact point type.
  --     p_created_by_module  Created by module.
  --   IN/OUT:
  --     px_sms_rec           SMS plsql record.
  --     px_contact_point_rec Contact point plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_sms_rec(
    p_sms_obj                    IN            HZ_SMS_CP_BO,
    p_owner_table_id             IN            NUMBER,
    p_owner_table_name           IN            VARCHAR2,
    p_cp_id                      IN            NUMBER,
    p_cp_os                      IN            VARCHAR2,
    p_cp_osr                     IN            VARCHAR2,
    p_cp_type                    IN            VARCHAR2,
    p_create_or_update           IN            VARCHAR2 := 'C',
    px_sms_rec                   IN OUT NOCOPY HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE,
    px_contact_point_rec         IN OUT NOCOPY HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE
  ) IS
  BEGIN
    px_contact_point_rec.contact_point_id       := p_cp_id;
    px_contact_point_rec.contact_point_type     := p_cp_type;
    IF(p_sms_obj.status in ('A','I')) THEN
      px_contact_point_rec.status               := p_sms_obj.status;
    ELSE
      px_contact_point_rec.status               := NULL;
    END IF;
    px_contact_point_rec.owner_table_name       := p_owner_table_name;
    px_contact_point_rec.owner_table_id         := p_owner_table_id;
    IF(p_sms_obj.primary_flag in ('Y','N')) THEN
      px_contact_point_rec.primary_flag           := p_sms_obj.primary_flag;
    ELSE
      px_contact_point_rec.primary_flag           := NULL;
    END IF;
    px_contact_point_rec.attribute_category     := p_sms_obj.attribute_category;
    px_contact_point_rec.attribute1             := p_sms_obj.attribute1;
    px_contact_point_rec.attribute2             := p_sms_obj.attribute2;
    px_contact_point_rec.attribute3             := p_sms_obj.attribute3;
    px_contact_point_rec.attribute4             := p_sms_obj.attribute4;
    px_contact_point_rec.attribute5             := p_sms_obj.attribute5;
    px_contact_point_rec.attribute6             := p_sms_obj.attribute6;
    px_contact_point_rec.attribute7             := p_sms_obj.attribute7;
    px_contact_point_rec.attribute8             := p_sms_obj.attribute8;
    px_contact_point_rec.attribute9             := p_sms_obj.attribute9;
    px_contact_point_rec.attribute10            := p_sms_obj.attribute10;
    px_contact_point_rec.attribute11            := p_sms_obj.attribute11;
    px_contact_point_rec.attribute12            := p_sms_obj.attribute12;
    px_contact_point_rec.attribute13            := p_sms_obj.attribute13;
    px_contact_point_rec.attribute14            := p_sms_obj.attribute14;
    px_contact_point_rec.attribute15            := p_sms_obj.attribute15;
    px_contact_point_rec.attribute16            := p_sms_obj.attribute16;
    px_contact_point_rec.attribute17            := p_sms_obj.attribute17;
    px_contact_point_rec.attribute18            := p_sms_obj.attribute18;
    px_contact_point_rec.attribute19            := p_sms_obj.attribute19;
    px_contact_point_rec.attribute20            := p_sms_obj.attribute20;
    px_contact_point_rec.contact_point_purpose  := p_sms_obj.contact_point_purpose;
    px_contact_point_rec.primary_by_purpose     := p_sms_obj.primary_by_purpose;
    IF(p_create_or_update = 'C') THEN
      px_contact_point_rec.orig_system            := p_cp_os;
      px_contact_point_rec.orig_system_reference  := p_cp_osr;
      px_contact_point_rec.created_by_module      := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
    END IF;
    px_contact_point_rec.actual_content_source  := p_sms_obj.actual_content_source;
    px_sms_rec.phone_calling_calendar := p_sms_obj.phone_calling_calendar;
    px_sms_rec.last_contact_dt_time   := p_sms_obj.last_contact_dt_time;
    px_sms_rec.timezone_id            := p_sms_obj.timezone_id;
    px_sms_rec.phone_area_code        := p_sms_obj.phone_area_code;
    px_sms_rec.phone_country_code     := p_sms_obj.phone_country_code;
    px_sms_rec.phone_number           := p_sms_obj.phone_number;
    px_sms_rec.phone_extension        := p_sms_obj.phone_extension;
    px_sms_rec.phone_line_type        := p_sms_obj.phone_line_type;
    px_sms_rec.raw_phone_number       := p_sms_obj.raw_phone_number;
  END assign_sms_rec;

  -- PRIVATE PROCEDURE do_create_contact_point
  --
  -- DESCRIPTION
  --     Create contact point.
  PROCEDURE do_create_contact_point(
    p_init_msg_list                   IN     VARCHAR2 := FND_API.G_FALSE,
    p_validate_bo_flag                IN     VARCHAR2 := FND_API.G_TRUE,
    p_cp_id                           IN     NUMBER,
    p_cp_os                           IN     VARCHAR2,
    p_cp_osr                          IN     VARCHAR2,
    p_phone_obj                       IN HZ_PHONE_CP_BO,
    p_email_obj                       IN HZ_EMAIL_CP_BO,
    p_telex_obj                       IN HZ_TELEX_CP_BO,
    p_web_obj                         IN HZ_WEB_CP_BO,
    p_edi_obj                         IN HZ_EDI_CP_BO,
    p_eft_obj                         IN HZ_EFT_CP_BO,
    p_sms_obj                         IN HZ_SMS_CP_BO,
    p_cp_pref_objs                    IN OUT NOCOPY    HZ_CONTACT_PREF_OBJ_TBL,
    p_cp_type                         IN     VARCHAR2,
    p_created_by_module               IN     VARCHAR2,
    p_obj_source                      IN     VARCHAR2 := null,
    x_return_status                   OUT    NOCOPY VARCHAR2,
    x_msg_count                       OUT    NOCOPY NUMBER,
    x_msg_data                        OUT    NOCOPY VARCHAR2,
    x_cp_id                           OUT    NOCOPY NUMBER,
    x_cp_os                           OUT    NOCOPY VARCHAR2,
    x_cp_osr                          OUT    NOCOPY VARCHAR2,
    px_parent_id                      IN OUT NOCOPY NUMBER,
    px_parent_os                      IN OUT NOCOPY VARCHAR2,
    px_parent_osr                     IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type                IN OUT NOCOPY VARCHAR2
  ) IS
    l_debug_prefix             VARCHAR2(30);
    l_contact_point_rec        HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE;
    l_phone_rec                HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE;
    l_email_rec                HZ_CONTACT_POINT_V2PUB.EMAIL_REC_TYPE;
    l_telex_rec                HZ_CONTACT_POINT_V2PUB.TELEX_REC_TYPE;
    l_web_rec                  HZ_CONTACT_POINT_V2PUB.WEB_REC_TYPE;
    l_edi_rec                  HZ_CONTACT_POINT_V2PUB.EDI_REC_TYPE;
    l_eft_rec                  HZ_CONTACT_POINT_V2PUB.EFT_REC_TYPE;
    l_sms_rec                  HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE;
    l_contact_pref_rec         HZ_CONTACT_PREFERENCE_V2PUB.CONTACT_PREFERENCE_REC_TYPE;
    l_contact_pref_id          NUMBER;
    l_owner_table_name         VARCHAR2(30);
    l_valid_obj                BOOLEAN;
    l_bus_object               HZ_REGISTRY_VALIDATE_BO_PVT.COMPLETENESS_REC_TYPE;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT do_create_contact_point_pub;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- initialize Global variable to indicate the caller of V2API is from BO API
    HZ_UTILITY_V2PUB.G_CALLING_API := 'BO_API';
    IF(p_created_by_module IS NULL) THEN
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := 'BO_API';
    ELSE
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := p_created_by_module;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_contact_point(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Base on p_validate_bo_flag, check completeness of business object
    IF(p_validate_bo_flag = FND_API.G_TRUE) THEN
      HZ_REGISTRY_VALIDATE_BO_PVT.get_bus_obj_struct(
        p_bus_object_code         => p_cp_type,
        x_bus_object              => l_bus_object
      );

      l_valid_obj := HZ_REGISTRY_VALIDATE_BO_PVT.is_cp_bo_comp(
        p_phone_objs        => HZ_PHONE_CP_BO_TBL(p_phone_obj),
        p_email_objs        => HZ_EMAIL_CP_BO_TBL(p_email_obj),
        p_telex_objs        => HZ_TELEX_CP_BO_TBL(p_telex_obj),
        p_web_objs          => HZ_WEB_CP_BO_TBL(p_web_obj),
        p_edi_objs          => HZ_EDI_CP_BO_TBL(p_edi_obj),
        p_eft_objs          => HZ_EFT_CP_BO_TBL(p_eft_obj),
        p_sms_objs          => HZ_SMS_CP_BO_TBL(p_sms_obj),
        p_bus_object        => l_bus_object
      );

      IF NOT(l_valid_obj) THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- check pass in parent_id and parent_os/parent_osr
    hz_registry_validate_bo_pvt.validate_parent_id(
      px_parent_id      => px_parent_id,
      px_parent_os      => px_parent_os,
      px_parent_osr     => px_parent_osr,
      p_parent_obj_type => px_parent_obj_type,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- get owner table name of contact point, contact point id and os+osr
    l_owner_table_name := HZ_REGISTRY_VALIDATE_BO_PVT.get_owner_table_name(p_obj_type => px_parent_obj_type);
    x_cp_id := p_cp_id;
    x_cp_os := p_cp_os;
    x_cp_osr := p_cp_osr;

    -- check if pass in contact_point_id and/or os+osr
    hz_registry_validate_bo_pvt.validate_ssm_id(
      px_id              => x_cp_id,
      px_os              => x_cp_os,
      px_osr             => x_cp_osr,
      p_obj_type         => p_cp_type,
      p_create_or_update => 'C',
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Base on contact point type, assign record and then call v2pub api
    IF(p_cp_type = 'PHONE') THEN
      assign_phone_rec(
        p_phone_obj => p_phone_obj,
        p_owner_table_id => px_parent_id,
        p_owner_table_name => l_owner_table_name,
        p_cp_id => x_cp_id,
        p_cp_os => x_cp_os,
        p_cp_osr => x_cp_osr,
        p_cp_type => p_cp_type,
        px_phone_rec => l_phone_rec,
        px_contact_point_rec => l_contact_point_rec
      );

      HZ_CONTACT_POINT_V2PUB.create_phone_contact_point(
        p_contact_point_rec         => l_contact_point_rec,
        p_phone_rec                 => l_phone_rec,
        x_contact_point_id          => x_cp_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    ELSIF(p_cp_type = 'EMAIL') THEN
      assign_email_rec(
        p_email_obj => p_email_obj,
        p_owner_table_id => px_parent_id,
        p_owner_table_name => l_owner_table_name,
        p_cp_id => x_cp_id,
        p_cp_os => x_cp_os,
        p_cp_osr => x_cp_osr,
        p_cp_type => p_cp_type,
        px_email_rec => l_email_rec,
        px_contact_point_rec => l_contact_point_rec
      );

      HZ_CONTACT_POINT_V2PUB.create_email_contact_point(
        p_contact_point_rec         => l_contact_point_rec,
        p_email_rec                 => l_email_rec,
        x_contact_point_id          => x_cp_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    ELSIF(p_cp_type = 'TLX') THEN
      assign_telex_rec(
        p_telex_obj => p_telex_obj,
        p_owner_table_id => px_parent_id,
        p_owner_table_name => l_owner_table_name,
        p_cp_id => x_cp_id,
        p_cp_os => x_cp_os,
        p_cp_osr => x_cp_osr,
        p_cp_type => p_cp_type,
        px_telex_rec => l_telex_rec,
        px_contact_point_rec => l_contact_point_rec
      );

      HZ_CONTACT_POINT_V2PUB.create_telex_contact_point(
        p_contact_point_rec         => l_contact_point_rec,
        p_telex_rec                 => l_telex_rec,
        x_contact_point_id          => x_cp_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    ELSIF(p_cp_type = 'WEB') THEN
      assign_web_rec(
        p_web_obj => p_web_obj,
        p_owner_table_id => px_parent_id,
        p_owner_table_name => l_owner_table_name,
        p_cp_id => x_cp_id,
        p_cp_os => x_cp_os,
        p_cp_osr => x_cp_osr,
        p_cp_type => p_cp_type,
        px_web_rec => l_web_rec,
        px_contact_point_rec => l_contact_point_rec
      );

      HZ_CONTACT_POINT_V2PUB.create_web_contact_point(
        p_contact_point_rec         => l_contact_point_rec,
        p_web_rec                   => l_web_rec,
        x_contact_point_id          => x_cp_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    ELSIF(p_cp_type = 'EDI') THEN
      assign_edi_rec(
        p_edi_obj => p_edi_obj,
        p_owner_table_id => px_parent_id,
        p_owner_table_name => l_owner_table_name,
        p_cp_id => x_cp_id,
        p_cp_os => x_cp_os,
        p_cp_osr => x_cp_osr,
        p_cp_type => p_cp_type,
        px_edi_rec => l_edi_rec,
        px_contact_point_rec => l_contact_point_rec
      );

      HZ_CONTACT_POINT_V2PUB.create_edi_contact_point(
        p_contact_point_rec         => l_contact_point_rec,
        p_edi_rec                   => l_edi_rec,
        x_contact_point_id          => x_cp_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    ELSIF(p_cp_type = 'EFT') THEN
      assign_eft_rec(
        p_eft_obj => p_eft_obj,
        p_owner_table_id => px_parent_id,
        p_owner_table_name => l_owner_table_name,
        p_cp_id => x_cp_id,
        p_cp_os => x_cp_os,
        p_cp_osr => x_cp_osr,
        p_cp_type => p_cp_type,
        px_eft_rec => l_eft_rec,
        px_contact_point_rec => l_contact_point_rec
      );

      HZ_CONTACT_POINT_V2PUB.create_eft_contact_point(
        p_contact_point_rec         => l_contact_point_rec,
        p_eft_rec                   => l_eft_rec,
        x_contact_point_id          => x_cp_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    ELSIF(p_cp_type = 'SMS') THEN
      assign_sms_rec(
        p_sms_obj => p_sms_obj,
        p_owner_table_id => px_parent_id,
        p_owner_table_name => l_owner_table_name,
        p_cp_id => x_cp_id,
        p_cp_os => x_cp_os,
        p_cp_osr => x_cp_osr,
        p_cp_type => p_cp_type,
        px_sms_rec => l_sms_rec,
        px_contact_point_rec => l_contact_point_rec
      );

      HZ_CONTACT_POINT_V2PUB.create_phone_contact_point(
        p_contact_point_rec         => l_contact_point_rec,
        p_phone_rec                 => l_sms_rec,
        x_contact_point_id          => x_cp_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    IF((p_cp_pref_objs IS NOT NULL) AND (p_cp_pref_objs.COUNT > 0)) THEN
      -- create contact preferences
      HZ_CONTACT_PREFERENCE_BO_PVT.create_contact_preferences(
        p_cp_pref_objs           => p_cp_pref_objs,
        p_contact_level_table_id => x_cp_id,
        p_contact_level_table    => 'HZ_CONTACT_POINTS',
        x_return_status          => x_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data
      );
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- reset Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_contact_point(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO do_create_contact_point_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', p_cp_type);
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO do_create_contact_point_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', p_cp_type);
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO do_create_contact_point_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', p_cp_type);
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_create_contact_point;

  -- PROCEDURE update_phone_bo
  --
  -- DESCRIPTION
  --     Update a logical phone contact point.
  PROCEDURE update_phone_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_phone_obj           IN            HZ_PHONE_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_phone_id            OUT NOCOPY    NUMBER,
    x_phone_os            OUT NOCOPY    VARCHAR2,
    x_phone_osr           OUT NOCOPY    VARCHAR2
  )IS
    l_phone_obj           HZ_PHONE_CP_BO;
  BEGIN
    l_phone_obj := p_phone_obj;
    do_update_contact_point (
      p_init_msg_list      => p_init_msg_list,
      p_cp_id              => p_phone_obj.phone_id,
      p_cp_os              => l_phone_obj.orig_system,
      p_cp_osr             => l_phone_obj.orig_system_reference,
      p_phone_obj          => l_phone_obj,
      p_email_obj          => NULL,
      p_telex_obj          => NULL,
      p_web_obj            => NULL,
      p_edi_obj            => NULL,
      p_eft_obj            => NULL,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_phone_obj.contact_pref_objs,
      p_cp_type            => 'PHONE',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => NULL,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      x_cp_id              => x_phone_id,
      x_cp_os              => x_phone_os,
      x_cp_osr             => x_phone_osr,
      p_parent_os          => NULL );
  END update_phone_bo;

  PROCEDURE update_phone_bo(
    p_phone_obj           IN            HZ_PHONE_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_PHONE_CP_BO,
    x_phone_id            OUT NOCOPY    NUMBER,
    x_phone_os            OUT NOCOPY    VARCHAR2,
    x_phone_osr           OUT NOCOPY    VARCHAR2
  )IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
    l_phone_obj           HZ_PHONE_CP_BO;
  BEGIN
    l_phone_obj := p_phone_obj;
    do_update_contact_point (
      p_init_msg_list      => fnd_api.g_true,
      p_cp_id              => l_phone_obj.phone_id,
      p_cp_os              => l_phone_obj.orig_system,
      p_cp_osr             => l_phone_obj.orig_system_reference,
      p_phone_obj          => l_phone_obj,
      p_email_obj          => NULL,
      p_telex_obj          => NULL,
      p_web_obj            => NULL,
      p_edi_obj            => NULL,
      p_eft_obj            => NULL,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_phone_obj.contact_pref_objs,
      p_cp_type            => 'PHONE',
      p_created_by_module  => p_created_by_module,
      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,
      x_cp_id              => x_phone_id,
      x_cp_os              => x_phone_os,
      x_cp_osr             => x_phone_osr,
      p_parent_os          => NULL );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_phone_obj;
    END IF;
  END update_phone_bo;

  -- PROCEDURE update_telex_bo
  --
  -- DESCRIPTION
  --     Update a logical telex contact point.
  PROCEDURE update_telex_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_telex_obj           IN            HZ_TELEX_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_telex_id            OUT NOCOPY    NUMBER,
    x_telex_os            OUT NOCOPY    VARCHAR2,
    x_telex_osr           OUT NOCOPY    VARCHAR2
  )IS
    l_telex_obj           HZ_TELEX_CP_BO;
  BEGIN
    l_telex_obj := p_telex_obj;
    do_update_contact_point (
      p_init_msg_list      => p_init_msg_list,
      p_cp_id              => l_telex_obj.telex_id,
      p_cp_os              => l_telex_obj.orig_system,
      p_cp_osr             => l_telex_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => NULL,
      p_telex_obj          => l_telex_obj,
      p_web_obj            => NULL,
      p_edi_obj            => NULL,
      p_eft_obj            => NULL,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_telex_obj.contact_pref_objs,
      p_cp_type            => 'TLX',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => NULL,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      x_cp_id              => x_telex_id,
      x_cp_os              => x_telex_os,
      x_cp_osr             => x_telex_osr,
      p_parent_os          => NULL );
  END update_telex_bo;

  PROCEDURE update_telex_bo(
    p_telex_obj           IN            HZ_TELEX_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_TELEX_CP_BO,
    x_telex_id            OUT NOCOPY    NUMBER,
    x_telex_os            OUT NOCOPY    VARCHAR2,
    x_telex_osr           OUT NOCOPY    VARCHAR2
  )IS
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);
    l_telex_obj           HZ_TELEX_CP_BO;
  BEGIN
    l_telex_obj := p_telex_obj;
    do_update_contact_point (
      p_init_msg_list      => fnd_api.g_true,
      p_cp_id              => l_telex_obj.telex_id,
      p_cp_os              => l_telex_obj.orig_system,
      p_cp_osr             => l_telex_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => NULL,
      p_telex_obj          => l_telex_obj,
      p_web_obj            => NULL,
      p_edi_obj            => NULL,
      p_eft_obj            => NULL,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_telex_obj.contact_pref_objs,
      p_cp_type            => 'TLX',
      p_created_by_module  => p_created_by_module,
      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,
      x_cp_id              => x_telex_id,
      x_cp_os              => x_telex_os,
      x_cp_osr             => x_telex_osr,
      p_parent_os          => NULL );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_telex_obj;
    END IF;
  END update_telex_bo;

  -- PROCEDURE update_email_bo
  --
  -- DESCRIPTION
  --     Update a logical email contact point.
  PROCEDURE update_email_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_email_obj           IN            HZ_EMAIL_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_email_id            OUT NOCOPY    NUMBER,
    x_email_os            OUT NOCOPY    VARCHAR2,
    x_email_osr           OUT NOCOPY    VARCHAR2
  )IS
    l_email_obj           HZ_EMAIL_CP_BO;
  BEGIN
    l_email_obj := p_email_obj;
    do_update_contact_point (
      p_init_msg_list      => p_init_msg_list,
      p_cp_id              => l_email_obj.email_id,
      p_cp_os              => l_email_obj.orig_system,
      p_cp_osr             => l_email_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => l_email_obj,
      p_telex_obj          => NULL,
      p_web_obj            => NULL,
      p_edi_obj            => NULL,
      p_eft_obj            => NULL,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_email_obj.contact_pref_objs,
      p_cp_type            => 'EMAIL',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => NULL,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      x_cp_id              => x_email_id,
      x_cp_os              => x_email_os,
      x_cp_osr             => x_email_osr,
      p_parent_os          => NULL );
  END update_email_bo;

  PROCEDURE update_email_bo(
    p_email_obj           IN            HZ_EMAIL_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_EMAIL_CP_BO,
    x_email_id            OUT NOCOPY    NUMBER,
    x_email_os            OUT NOCOPY    VARCHAR2,
    x_email_osr           OUT NOCOPY    VARCHAR2
  )IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
    l_email_obj           HZ_EMAIL_CP_BO;
  BEGIN
    l_email_obj := p_email_obj;
    do_update_contact_point (
      p_init_msg_list      => fnd_api.g_true,
      p_cp_id              => l_email_obj.email_id,
      p_cp_os              => l_email_obj.orig_system,
      p_cp_osr             => l_email_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => l_email_obj,
      p_telex_obj          => NULL,
      p_web_obj            => NULL,
      p_edi_obj            => NULL,
      p_eft_obj            => NULL,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_email_obj.contact_pref_objs,
      p_cp_type            => 'EMAIL',
      p_created_by_module  => p_created_by_module,
      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,
      x_cp_id              => x_email_id,
      x_cp_os              => x_email_os,
      x_cp_osr             => x_email_osr,
      p_parent_os          => NULL );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_email_obj;
    END IF;
  END update_email_bo;

  -- PROCEDURE update_web_bo
  --
  -- DESCRIPTION
  --     Update a logical web contact point.
  PROCEDURE update_web_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_web_obj             IN            HZ_WEB_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_web_id              OUT NOCOPY    NUMBER,
    x_web_os              OUT NOCOPY    VARCHAR2,
    x_web_osr             OUT NOCOPY    VARCHAR2
  )IS
    l_web_obj             HZ_WEB_CP_BO;
  BEGIN
    l_web_obj := p_web_obj;
    do_update_contact_point (
      p_init_msg_list      => p_init_msg_list,
      p_cp_id              => l_web_obj.web_id,
      p_cp_os              => l_web_obj.orig_system,
      p_cp_osr             => l_web_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => NULL,
      p_telex_obj          => NULL,
      p_web_obj            => l_web_obj,
      p_edi_obj            => NULL,
      p_eft_obj            => NULL,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_web_obj.contact_pref_objs,
      p_cp_type            => 'WEB',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => NULL,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      x_cp_id              => x_web_id,
      x_cp_os              => x_web_os,
      x_cp_osr             => x_web_osr,
      p_parent_os          => NULL );
  END update_web_bo;

  PROCEDURE update_web_bo(
    p_web_obj             IN            HZ_WEB_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_WEB_CP_BO,
    x_web_id              OUT NOCOPY    NUMBER,
    x_web_os              OUT NOCOPY    VARCHAR2,
    x_web_osr             OUT NOCOPY    VARCHAR2
  )IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
    l_web_obj             HZ_WEB_CP_BO;
  BEGIN
    l_web_obj := p_web_obj;
    do_update_contact_point (
      p_init_msg_list      => fnd_api.g_true,
      p_cp_id              => l_web_obj.web_id,
      p_cp_os              => l_web_obj.orig_system,
      p_cp_osr             => l_web_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => NULL,
      p_telex_obj          => NULL,
      p_web_obj            => l_web_obj,
      p_edi_obj            => NULL,
      p_eft_obj            => NULL,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_web_obj.contact_pref_objs,
      p_cp_type            => 'WEB',
      p_created_by_module  => p_created_by_module,
      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,
      x_cp_id              => x_web_id,
      x_cp_os              => x_web_os,
      x_cp_osr             => x_web_osr,
      p_parent_os          => NULL );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_web_obj;
    END IF;
  END update_web_bo;

  -- PROCEDURE update_edi_bo
  --
  -- DESCRIPTION
  --     Update a logical edi contact point.
  PROCEDURE update_edi_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_edi_obj             IN            HZ_EDI_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_edi_id              OUT NOCOPY    NUMBER,
    x_edi_os              OUT NOCOPY    VARCHAR2,
    x_edi_osr             OUT NOCOPY    VARCHAR2
  )IS
    l_edi_obj             HZ_EDI_CP_BO;
  BEGIN
    l_edi_obj := p_edi_obj;
    do_update_contact_point (
      p_init_msg_list      => p_init_msg_list,
      p_cp_id              => l_edi_obj.edi_id,
      p_cp_os              => l_edi_obj.orig_system,
      p_cp_osr             => l_edi_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => NULL,
      p_telex_obj          => NULL,
      p_web_obj            => NULL,
      p_edi_obj            => l_edi_obj,
      p_eft_obj            => NULL,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_edi_obj.contact_pref_objs,
      p_cp_type            => 'EDI',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => NULL,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      x_cp_id              => x_edi_id,
      x_cp_os              => x_edi_os,
      x_cp_osr             => x_edi_osr,
      p_parent_os          => NULL );
  END update_edi_bo;

  PROCEDURE update_edi_bo(
    p_edi_obj             IN            HZ_EDI_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_EDI_CP_BO,
    x_edi_id              OUT NOCOPY    NUMBER,
    x_edi_os              OUT NOCOPY    VARCHAR2,
    x_edi_osr             OUT NOCOPY    VARCHAR2
  )IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
    l_edi_obj             HZ_EDI_CP_BO;
  BEGIN
    l_edi_obj := p_edi_obj;
    do_update_contact_point (
      p_init_msg_list      => fnd_api.g_true,
      p_cp_id              => l_edi_obj.edi_id,
      p_cp_os              => l_edi_obj.orig_system,
      p_cp_osr             => l_edi_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => NULL,
      p_telex_obj          => NULL,
      p_web_obj            => NULL,
      p_edi_obj            => l_edi_obj,
      p_eft_obj            => NULL,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_edi_obj.contact_pref_objs,
      p_cp_type            => 'EDI',
      p_created_by_module  => p_created_by_module,
      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,
      x_cp_id              => x_edi_id,
      x_cp_os              => x_edi_os,
      x_cp_osr             => x_edi_osr,
      p_parent_os          => NULL );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_edi_obj;
    END IF;
  END update_edi_bo;

  -- PROCEDURE update_eft_bo
  --
  -- DESCRIPTION
  --     Update a logical eft contact point.
  PROCEDURE update_eft_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_eft_obj             IN            HZ_EFT_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_eft_id              OUT NOCOPY    NUMBER,
    x_eft_os              OUT NOCOPY    VARCHAR2,
    x_eft_osr             OUT NOCOPY    VARCHAR2
  )IS
    l_eft_obj             HZ_EFT_CP_BO;
  BEGIN
    l_eft_obj := p_eft_obj;
    do_update_contact_point (
      p_init_msg_list      => p_init_msg_list,
      p_cp_id              => l_eft_obj.eft_id,
      p_cp_os              => l_eft_obj.orig_system,
      p_cp_osr             => l_eft_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => NULL,
      p_telex_obj          => NULL,
      p_web_obj            => NULL,
      p_edi_obj            => NULL,
      p_eft_obj            => l_eft_obj,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_eft_obj.contact_pref_objs,
      p_cp_type            => 'EFT',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => NULL,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      x_cp_id              => x_eft_id,
      x_cp_os              => x_eft_os,
      x_cp_osr             => x_eft_osr,
      p_parent_os          => NULL );
  END update_eft_bo;

  PROCEDURE update_eft_bo(
    p_eft_obj             IN            HZ_EFT_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_EFT_CP_BO,
    x_eft_id              OUT NOCOPY    NUMBER,
    x_eft_os              OUT NOCOPY    VARCHAR2,
    x_eft_osr             OUT NOCOPY    VARCHAR2
  )IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
    l_eft_obj             HZ_EFT_CP_BO;
  BEGIN
    l_eft_obj := p_eft_obj;
    do_update_contact_point (
      p_init_msg_list      => fnd_api.g_true,
      p_cp_id              => l_eft_obj.eft_id,
      p_cp_os              => l_eft_obj.orig_system,
      p_cp_osr             => l_eft_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => NULL,
      p_telex_obj          => NULL,
      p_web_obj            => NULL,
      p_edi_obj            => NULL,
      p_eft_obj            => l_eft_obj,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_eft_obj.contact_pref_objs,
      p_cp_type            => 'EFT',
      p_created_by_module  => p_created_by_module,
      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,
      x_cp_id              => x_eft_id,
      x_cp_os              => x_eft_os,
      x_cp_osr             => x_eft_osr,
      p_parent_os          => NULL );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_eft_obj;
    END IF;
  END update_eft_bo;

  -- PROCEDURE update_sms_bo
  --
  -- DESCRIPTION
  --     Update a logical sms contact point.
  PROCEDURE update_sms_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_sms_obj             IN            HZ_SMS_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_sms_id              OUT NOCOPY    NUMBER,
    x_sms_os              OUT NOCOPY    VARCHAR2,
    x_sms_osr             OUT NOCOPY    VARCHAR2
  )IS
    l_sms_obj             HZ_SMS_CP_BO;
  BEGIN
    l_sms_obj := p_sms_obj;
    do_update_contact_point (
      p_init_msg_list      => p_init_msg_list,
      p_cp_id              => l_sms_obj.sms_id,
      p_cp_os              => l_sms_obj.orig_system,
      p_cp_osr             => l_sms_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => NULL,
      p_telex_obj          => NULL,
      p_web_obj            => NULL,
      p_edi_obj            => NULL,
      p_eft_obj            => NULL,
      p_sms_obj            => l_sms_obj,
      p_cp_pref_objs       => l_sms_obj.contact_pref_objs,
      p_cp_type            => 'SMS',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => NULL,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      x_cp_id              => x_sms_id,
      x_cp_os              => x_sms_os,
      x_cp_osr             => x_sms_osr,
      p_parent_os          => NULL );
  END update_sms_bo;

  PROCEDURE update_sms_bo(
    p_sms_obj             IN            HZ_SMS_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_SMS_CP_BO,
    x_sms_id              OUT NOCOPY    NUMBER,
    x_sms_os              OUT NOCOPY    VARCHAR2,
    x_sms_osr             OUT NOCOPY    VARCHAR2
  )IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
    l_sms_obj             HZ_SMS_CP_BO;
  BEGIN
    l_sms_obj := p_sms_obj;
    do_update_contact_point (
      p_init_msg_list      => fnd_api.g_true,
      p_cp_id              => l_sms_obj.sms_id,
      p_cp_os              => l_sms_obj.orig_system,
      p_cp_osr             => l_sms_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => NULL,
      p_telex_obj          => NULL,
      p_web_obj            => NULL,
      p_edi_obj            => NULL,
      p_eft_obj            => NULL,
      p_sms_obj            => l_sms_obj,
      p_cp_pref_objs       => l_sms_obj.contact_pref_objs,
      p_cp_type            => 'SMS',
      p_created_by_module  => p_created_by_module,
      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,
      x_cp_id              => x_sms_id,
      x_cp_os              => x_sms_os,
      x_cp_osr             => x_sms_osr,
      p_parent_os          => NULL );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_sms_obj;
    END IF;
  END update_sms_bo;

  -- PRIVATE PROCEDURE do_update_contact_point
  --
  -- DESCRIPTION
  --     Update contact point.
  PROCEDURE do_update_contact_point (
    p_init_msg_list                   IN     VARCHAR2:= FND_API.G_FALSE,
    p_cp_id                           IN     NUMBER,
    p_cp_os                           IN     VARCHAR2,
    p_cp_osr                          IN     VARCHAR2,
    p_phone_obj                       IN HZ_PHONE_CP_BO,
    p_email_obj                       IN HZ_EMAIL_CP_BO,
    p_telex_obj                       IN HZ_TELEX_CP_BO,
    p_web_obj                         IN HZ_WEB_CP_BO,
    p_edi_obj                         IN HZ_EDI_CP_BO,
    p_eft_obj                         IN HZ_EFT_CP_BO,
    p_sms_obj                         IN HZ_SMS_CP_BO,
    p_cp_pref_objs                    IN OUT NOCOPY    HZ_CONTACT_PREF_OBJ_TBL,
    p_cp_type                         IN     VARCHAR2,
    p_created_by_module               IN     VARCHAR2,
    p_obj_source                      IN     VARCHAR2 := null,
    x_return_status                   OUT    NOCOPY VARCHAR2,
    x_msg_count                       OUT    NOCOPY NUMBER,
    x_msg_data                        OUT    NOCOPY VARCHAR2,
    x_cp_id                           OUT    NOCOPY NUMBER,
    x_cp_os                           OUT    NOCOPY VARCHAR2,
    x_cp_osr                          OUT    NOCOPY VARCHAR2,
    p_parent_os                       IN     VARCHAR2
  ) IS
    l_debug_prefix             VARCHAR2(30);
    l_contact_point_rec        HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE;
    l_phone_rec                HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE;
    l_email_rec                HZ_CONTACT_POINT_V2PUB.EMAIL_REC_TYPE;
    l_telex_rec                HZ_CONTACT_POINT_V2PUB.TELEX_REC_TYPE;
    l_web_rec                  HZ_CONTACT_POINT_V2PUB.WEB_REC_TYPE;
    l_edi_rec                  HZ_CONTACT_POINT_V2PUB.EDI_REC_TYPE;
    l_eft_rec                  HZ_CONTACT_POINT_V2PUB.EFT_REC_TYPE;
    l_sms_rec                  HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE;
    l_contact_pref_rec         HZ_CONTACT_PREFERENCE_V2PUB.CONTACT_PREFERENCE_REC_TYPE;
    l_contact_pref_id          NUMBER;
    l_ovn                      NUMBER;
    l_owner_table_id           NUMBER;
    l_owner_table_name         VARCHAR2(30);
    l_create_update_flag       VARCHAR2(1);
    l_os                       VARCHAR2(30);
    l_osr                      VARCHAR2(255);
    l_orig_sys_reference_rec   HZ_ORIG_SYSTEM_REF_PUB.ORIG_SYS_REFERENCE_REC_TYPE;

    CURSOR get_ovn(l_contact_point_id  NUMBER) IS
    SELECT object_version_number, owner_table_id, owner_table_name
    FROM HZ_CONTACT_POINTS
    WHERE contact_point_id = l_contact_point_id;

  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT do_update_contact_point_pub;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- initialize Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := 'BO_API';
    IF(p_created_by_module IS NULL) THEN
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := 'BO_API';
    ELSE
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := p_created_by_module;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_contact_point (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- get contact point id and os+osr
    x_cp_id := p_cp_id;
    x_cp_os := p_cp_os;
    x_cp_osr := p_cp_osr;

    -- check if pass in contact_point_id and ssm is valid for update
    hz_registry_validate_bo_pvt.validate_ssm_id(
      px_id              => x_cp_id,
      px_os              => x_cp_os,
      px_osr             => x_cp_osr,
      p_obj_type         => p_cp_type,
      p_create_or_update => 'U',
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    OPEN get_ovn(x_cp_id);
    FETCH get_ovn INTO l_ovn, l_owner_table_id, l_owner_table_name;
    CLOSE get_ovn;

    -- step 2) call update contact point
    -- Assign contact point type record, call contact point v2pub update api
    IF(p_cp_type = 'PHONE') THEN
      assign_phone_rec(
        p_phone_obj          => p_phone_obj,
        p_owner_table_id     => l_owner_table_id,
        p_owner_table_name   => l_owner_table_name,
        p_cp_id              => x_cp_id,
        p_cp_os              => x_cp_os,
        p_cp_osr             => x_cp_osr,
        p_cp_type            => p_cp_type,
        p_create_or_update   => 'U',
        px_phone_rec         => l_phone_rec,
        px_contact_point_rec => l_contact_point_rec
      );

      HZ_CONTACT_POINT_V2PUB.update_phone_contact_point(
        p_contact_point_rec         => l_contact_point_rec,
        p_phone_rec                 => l_phone_rec,
        p_object_version_number     => l_ovn,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSIF(p_cp_type = 'EMAIL') THEN
      assign_email_rec(
        p_email_obj          => p_email_obj,
        p_owner_table_id     => l_owner_table_id,
        p_owner_table_name   => l_owner_table_name,
        p_cp_id              => x_cp_id,
        p_cp_os              => x_cp_os,
        p_cp_osr             => x_cp_osr,
        p_cp_type            => p_cp_type,
        p_create_or_update   => 'U',
        px_email_rec         => l_email_rec,
        px_contact_point_rec => l_contact_point_rec
      );

      HZ_CONTACT_POINT_V2PUB.update_email_contact_point(
        p_contact_point_rec         => l_contact_point_rec,
        p_email_rec                 => l_email_rec,
        p_object_version_number     => l_ovn,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSIF(p_cp_type = 'TLX') THEN
      assign_telex_rec(
        p_telex_obj          => p_telex_obj,
        p_owner_table_id     => l_owner_table_id,
        p_owner_table_name   => l_owner_table_name,
        p_cp_id              => x_cp_id,
        p_cp_os              => x_cp_os,
        p_cp_osr             => x_cp_osr,
        p_cp_type            => p_cp_type,
        p_create_or_update   => 'U',
        px_telex_rec         => l_telex_rec,
        px_contact_point_rec => l_contact_point_rec
      );

      HZ_CONTACT_POINT_V2PUB.update_telex_contact_point(
        p_contact_point_rec         => l_contact_point_rec,
        p_telex_rec                 => l_telex_rec,
        p_object_version_number     => l_ovn,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSIF(p_cp_type = 'WEB') THEN
      assign_web_rec(
        p_web_obj            => p_web_obj,
        p_owner_table_id     => l_owner_table_id,
        p_owner_table_name   => l_owner_table_name,
        p_cp_id              => x_cp_id,
        p_cp_os              => x_cp_os,
        p_cp_osr             => x_cp_osr,
        p_cp_type            => p_cp_type,
        p_create_or_update   => 'U',
        px_web_rec           => l_web_rec,
        px_contact_point_rec => l_contact_point_rec
      );

      HZ_CONTACT_POINT_V2PUB.update_web_contact_point(
        p_contact_point_rec         => l_contact_point_rec,
        p_web_rec                   => l_web_rec,
        p_object_version_number     => l_ovn,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSIF(p_cp_type = 'EDI') THEN
      assign_edi_rec(
        p_edi_obj            => p_edi_obj,
        p_owner_table_id     => l_owner_table_id,
        p_owner_table_name   => l_owner_table_name,
        p_cp_id              => x_cp_id,
        p_cp_os              => x_cp_os,
        p_cp_osr             => x_cp_osr,
        p_cp_type            => p_cp_type,
        p_create_or_update   => 'U',
        px_edi_rec           => l_edi_rec,
        px_contact_point_rec => l_contact_point_rec
      );

      HZ_CONTACT_POINT_V2PUB.update_edi_contact_point(
        p_contact_point_rec         => l_contact_point_rec,
        p_edi_rec                   => l_edi_rec,
        p_object_version_number     => l_ovn,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSIF(p_cp_type = 'EFT') THEN
      assign_eft_rec(
        p_eft_obj            => p_eft_obj,
        p_owner_table_id     => l_owner_table_id,
        p_owner_table_name   => l_owner_table_name,
        p_cp_id              => x_cp_id,
        p_cp_os              => x_cp_os,
        p_cp_osr             => x_cp_osr,
        p_cp_type            => p_cp_type,
        p_create_or_update   => 'U',
        px_eft_rec           => l_eft_rec,
        px_contact_point_rec => l_contact_point_rec
      );

      HZ_CONTACT_POINT_V2PUB.update_eft_contact_point(
        p_contact_point_rec         => l_contact_point_rec,
        p_eft_rec                   => l_eft_rec,
        p_object_version_number     => l_ovn,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSIF(p_cp_type = 'SMS') THEN
      assign_sms_rec(
        p_sms_obj            => p_sms_obj,
        p_owner_table_id     => l_owner_table_id,
        p_owner_table_name   => l_owner_table_name,
        p_cp_id              => x_cp_id,
        p_cp_os              => x_cp_os,
        p_cp_osr             => x_cp_osr,
        p_cp_type            => p_cp_type,
        p_create_or_update   => 'U',
        px_sms_rec           => l_sms_rec,
        px_contact_point_rec => l_contact_point_rec
      );

      HZ_CONTACT_POINT_V2PUB.update_phone_contact_point(
        p_contact_point_rec         => l_contact_point_rec,
        p_phone_rec                 => l_sms_rec,
        p_object_version_number     => l_ovn,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    IF((p_cp_pref_objs IS NOT NULL) AND (p_cp_pref_objs.COUNT > 0)) THEN
      -- create or update contact preferences
      HZ_CONTACT_PREFERENCE_BO_PVT.save_contact_preferences(
        p_cp_pref_objs           => p_cp_pref_objs,
        p_contact_level_table_id => x_cp_id,
        p_contact_level_table    => 'HZ_CONTACT_POINTS',
        x_return_status          => x_return_status,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data
      );
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- reset Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_logical_cp(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO do_update_contact_point_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', p_cp_type);
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO do_update_contact_point_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', p_cp_type);
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO do_update_contact_point_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', p_cp_type);
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_update_contact_point;

  -- PROCEDURE save_phone_bo
  --
  -- DESCRIPTION
  --     Create or update a logical phone contact point.
  PROCEDURE save_phone_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_phone_obj           IN            HZ_PHONE_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_phone_id            OUT NOCOPY    NUMBER,
    x_phone_os            OUT NOCOPY    VARCHAR2,
    x_phone_osr           OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  ) IS
    l_phone_obj           HZ_PHONE_CP_BO;
  BEGIN
    l_phone_obj := p_phone_obj;
    do_save_contact_point (
      p_init_msg_list      => p_init_msg_list,
      p_validate_bo_flag   => p_validate_bo_flag,
      p_cp_id              => l_phone_obj.phone_id,
      p_cp_os              => l_phone_obj.orig_system,
      p_cp_osr             => l_phone_obj.orig_system_reference,
      p_phone_obj          => l_phone_obj,
      p_email_obj          => NULL,
      p_telex_obj          => NULL,
      p_web_obj            => NULL,
      p_edi_obj            => NULL,
      p_eft_obj            => NULL,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_phone_obj.contact_pref_objs,
      p_cp_type            => 'PHONE',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => NULL,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      x_cp_id              => x_phone_id,
      x_cp_os              => x_phone_os,
      x_cp_osr             => x_phone_osr,
      px_parent_id         => px_parent_id,
      px_parent_os         => px_parent_os,
      px_parent_osr        => px_parent_osr,
      px_parent_obj_type   => px_parent_obj_type
    );
  END save_phone_bo;

  PROCEDURE save_phone_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_phone_obj           IN            HZ_PHONE_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_PHONE_CP_BO,
    x_phone_id            OUT NOCOPY    NUMBER,
    x_phone_os            OUT NOCOPY    VARCHAR2,
    x_phone_osr           OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  ) IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
    l_phone_obj           HZ_PHONE_CP_BO;
  BEGIN
    l_phone_obj := p_phone_obj;
    do_save_contact_point (
      p_init_msg_list      => fnd_api.g_true,
      p_validate_bo_flag   => p_validate_bo_flag,
      p_cp_id              => l_phone_obj.phone_id,
      p_cp_os              => l_phone_obj.orig_system,
      p_cp_osr             => l_phone_obj.orig_system_reference,
      p_phone_obj          => l_phone_obj,
      p_email_obj          => NULL,
      p_telex_obj          => NULL,
      p_web_obj            => NULL,
      p_edi_obj            => NULL,
      p_eft_obj            => NULL,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_phone_obj.contact_pref_objs,
      p_cp_type            => 'PHONE',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => p_obj_source,
      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,
      x_cp_id              => x_phone_id,
      x_cp_os              => x_phone_os,
      x_cp_osr             => x_phone_osr,
      px_parent_id         => px_parent_id,
      px_parent_os         => px_parent_os,
      px_parent_osr        => px_parent_osr,
      px_parent_obj_type   => px_parent_obj_type
    );
    l_phone_obj.phone_id := x_phone_id;
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_phone_obj;
    END IF;
  END save_phone_bo;

  -- PROCEDURE save_email_bo
  --
  -- DESCRIPTION
  --     Create or update a logical email contact point.
  PROCEDURE save_email_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_email_obj           IN            HZ_EMAIL_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_email_id            OUT NOCOPY    NUMBER,
    x_email_os            OUT NOCOPY    VARCHAR2,
    x_email_osr           OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  ) IS
    l_email_obj           HZ_EMAIL_CP_BO;
  BEGIN
    l_email_obj := p_email_obj;
    do_save_contact_point (
      p_init_msg_list      => p_init_msg_list,
      p_validate_bo_flag   => p_validate_bo_flag,
      p_cp_id              => l_email_obj.email_id,
      p_cp_os              => l_email_obj.orig_system,
      p_cp_osr             => l_email_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => l_email_obj,
      p_telex_obj          => NULL,
      p_web_obj            => NULL,
      p_edi_obj            => NULL,
      p_eft_obj            => NULL,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_email_obj.contact_pref_objs,
      p_cp_type            => 'EMAIL',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => NULL,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      x_cp_id              => x_email_id,
      x_cp_os              => x_email_os,
      x_cp_osr             => x_email_osr,
      px_parent_id         => px_parent_id,
      px_parent_os         => px_parent_os,
      px_parent_osr        => px_parent_osr,
      px_parent_obj_type   => px_parent_obj_type
    );
  END save_email_bo;

  PROCEDURE save_email_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_email_obj           IN            HZ_EMAIL_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_EMAIL_CP_BO,
    x_email_id            OUT NOCOPY    NUMBER,
    x_email_os            OUT NOCOPY    VARCHAR2,
    x_email_osr           OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  ) IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
    l_email_obj           HZ_EMAIL_CP_BO;
  BEGIN
    l_email_obj := p_email_obj;
    do_save_contact_point (
      p_init_msg_list      => fnd_api.g_true,
      p_validate_bo_flag   => p_validate_bo_flag,
      p_cp_id              => l_email_obj.email_id,
      p_cp_os              => l_email_obj.orig_system,
      p_cp_osr             => l_email_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => l_email_obj,
      p_telex_obj          => NULL,
      p_web_obj            => NULL,
      p_edi_obj            => NULL,
      p_eft_obj            => NULL,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_email_obj.contact_pref_objs,
      p_cp_type            => 'EMAIL',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => p_obj_source,
      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,
      x_cp_id              => x_email_id,
      x_cp_os              => x_email_os,
      x_cp_osr             => x_email_osr,
      px_parent_id         => px_parent_id,
      px_parent_os         => px_parent_os,
      px_parent_osr        => px_parent_osr,
      px_parent_obj_type   => px_parent_obj_type
    );
    l_email_obj.email_id := x_email_id;
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_email_obj;
    END IF;
  END save_email_bo;

  -- PROCEDURE save_telex_bo
  --
  -- DESCRIPTION
  --     Create or update a logical telex contact point.
  PROCEDURE save_telex_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_telex_obj           IN            HZ_TELEX_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_telex_id            OUT NOCOPY    NUMBER,
    x_telex_os            OUT NOCOPY    VARCHAR2,
    x_telex_osr           OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  ) IS
    l_telex_obj           HZ_TELEX_CP_BO;
  BEGIN
    l_telex_obj := p_telex_obj;
    do_save_contact_point (
      p_init_msg_list      => p_init_msg_list,
      p_validate_bo_flag   => p_validate_bo_flag,
      p_cp_id              => l_telex_obj.telex_id,
      p_cp_os              => l_telex_obj.orig_system,
      p_cp_osr             => l_telex_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => NULL,
      p_telex_obj          => l_telex_obj,
      p_web_obj            => NULL,
      p_edi_obj            => NULL,
      p_eft_obj            => NULL,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_telex_obj.contact_pref_objs,
      p_cp_type            => 'TLX',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => NULL,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      x_cp_id              => x_telex_id,
      x_cp_os              => x_telex_os,
      x_cp_osr             => x_telex_osr,
      px_parent_id         => px_parent_id,
      px_parent_os         => px_parent_os,
      px_parent_osr        => px_parent_osr,
      px_parent_obj_type   => px_parent_obj_type
    );
  END save_telex_bo;

  PROCEDURE save_telex_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_telex_obj           IN            HZ_TELEX_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_TELEX_CP_BO,
    x_telex_id            OUT NOCOPY    NUMBER,
    x_telex_os            OUT NOCOPY    VARCHAR2,
    x_telex_osr           OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  ) IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
    l_telex_obj           HZ_TELEX_CP_BO;
  BEGIN
    l_telex_obj := p_telex_obj;
    do_save_contact_point (
      p_init_msg_list      => fnd_api.g_true,
      p_validate_bo_flag   => p_validate_bo_flag,
      p_cp_id              => l_telex_obj.telex_id,
      p_cp_os              => l_telex_obj.orig_system,
      p_cp_osr             => l_telex_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => NULL,
      p_telex_obj          => l_telex_obj,
      p_web_obj            => NULL,
      p_edi_obj            => NULL,
      p_eft_obj            => NULL,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_telex_obj.contact_pref_objs,
      p_cp_type            => 'TLX',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => p_obj_source,
      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,
      x_cp_id              => x_telex_id,
      x_cp_os              => x_telex_os,
      x_cp_osr             => x_telex_osr,
      px_parent_id         => px_parent_id,
      px_parent_os         => px_parent_os,
      px_parent_osr        => px_parent_osr,
      px_parent_obj_type   => px_parent_obj_type
    );
    l_telex_obj.telex_id := x_telex_id;
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_telex_obj;
    END IF;
  END save_telex_bo;

  -- PROCEDURE save_web_bo
  --
  -- DESCRIPTION
  --     Create or update a logical web contact point.
  PROCEDURE save_web_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_web_obj             IN            HZ_WEB_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_web_id              OUT NOCOPY    NUMBER,
    x_web_os              OUT NOCOPY    VARCHAR2,
    x_web_osr             OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  ) IS
    l_web_obj             HZ_WEB_CP_BO;
  BEGIN
    l_web_obj := p_web_obj;
    do_save_contact_point (
      p_init_msg_list      => p_init_msg_list,
      p_validate_bo_flag   => p_validate_bo_flag,
      p_cp_id              => l_web_obj.web_id,
      p_cp_os              => l_web_obj.orig_system,
      p_cp_osr             => l_web_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => NULL,
      p_telex_obj          => NULL,
      p_web_obj            => l_web_obj,
      p_edi_obj            => NULL,
      p_eft_obj            => NULL,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_web_obj.contact_pref_objs,
      p_cp_type            => 'WEB',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => NULL,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      x_cp_id              => x_web_id,
      x_cp_os              => x_web_os,
      x_cp_osr             => x_web_osr,
      px_parent_id         => px_parent_id,
      px_parent_os         => px_parent_os,
      px_parent_osr        => px_parent_osr,
      px_parent_obj_type   => px_parent_obj_type
    );
  END save_web_bo;

  PROCEDURE save_web_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_web_obj             IN            HZ_WEB_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_WEB_CP_BO,
    x_web_id              OUT NOCOPY    NUMBER,
    x_web_os              OUT NOCOPY    VARCHAR2,
    x_web_osr             OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  ) IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
    l_web_obj             HZ_WEB_CP_BO;
  BEGIN
    l_web_obj := p_web_obj;
    do_save_contact_point (
      p_init_msg_list      => fnd_api.g_true,
      p_validate_bo_flag   => p_validate_bo_flag,
      p_cp_id              => l_web_obj.web_id,
      p_cp_os              => l_web_obj.orig_system,
      p_cp_osr             => l_web_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => NULL,
      p_telex_obj          => NULL,
      p_web_obj            => l_web_obj,
      p_edi_obj            => NULL,
      p_eft_obj            => NULL,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_web_obj.contact_pref_objs,
      p_cp_type            => 'WEB',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => p_obj_source,
      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,
      x_cp_id              => x_web_id,
      x_cp_os              => x_web_os,
      x_cp_osr             => x_web_osr,
      px_parent_id         => px_parent_id,
      px_parent_os         => px_parent_os,
      px_parent_osr        => px_parent_osr,
      px_parent_obj_type   => px_parent_obj_type
    );
    l_web_obj.web_id := x_web_id;
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_web_obj;
    END IF;
  END save_web_bo;

  -- PROCEDURE save_edi_bo
  --
  -- DESCRIPTION
  --     Create or update a logical edi contact point.
  PROCEDURE save_edi_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_edi_obj             IN            HZ_EDI_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_edi_id              OUT NOCOPY    NUMBER,
    x_edi_os              OUT NOCOPY    VARCHAR2,
    x_edi_osr             OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  ) IS
    l_edi_obj             HZ_EDI_CP_BO;
  BEGIN
    l_edi_obj := p_edi_obj;
    do_save_contact_point (
      p_init_msg_list      => p_init_msg_list,
      p_validate_bo_flag   => p_validate_bo_flag,
      p_cp_id              => l_edi_obj.edi_id,
      p_cp_os              => l_edi_obj.orig_system,
      p_cp_osr             => l_edi_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => NULL,
      p_telex_obj          => NULL,
      p_web_obj            => NULL,
      p_edi_obj            => l_edi_obj,
      p_eft_obj            => NULL,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_edi_obj.contact_pref_objs,
      p_cp_type            => 'EDI',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => NULL,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      x_cp_id              => x_edi_id,
      x_cp_os              => x_edi_os,
      x_cp_osr             => x_edi_osr,
      px_parent_id         => px_parent_id,
      px_parent_os         => px_parent_os,
      px_parent_osr        => px_parent_osr,
      px_parent_obj_type   => px_parent_obj_type
    );
  END save_edi_bo;

  PROCEDURE save_edi_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_edi_obj             IN            HZ_EDI_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_EDI_CP_BO,
    x_edi_id              OUT NOCOPY    NUMBER,
    x_edi_os              OUT NOCOPY    VARCHAR2,
    x_edi_osr             OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  ) IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
    l_edi_obj             HZ_EDI_CP_BO;
  BEGIN
    l_edi_obj := p_edi_obj;
    do_save_contact_point (
      p_init_msg_list      => fnd_api.g_true,
      p_validate_bo_flag   => p_validate_bo_flag,
      p_cp_id              => l_edi_obj.edi_id,
      p_cp_os              => l_edi_obj.orig_system,
      p_cp_osr             => l_edi_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => NULL,
      p_telex_obj          => NULL,
      p_web_obj            => NULL,
      p_edi_obj            => l_edi_obj,
      p_eft_obj            => NULL,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_edi_obj.contact_pref_objs,
      p_cp_type            => 'EDI',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => p_obj_source,
      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,
      x_cp_id              => x_edi_id,
      x_cp_os              => x_edi_os,
      x_cp_osr             => x_edi_osr,
      px_parent_id         => px_parent_id,
      px_parent_os         => px_parent_os,
      px_parent_osr        => px_parent_osr,
      px_parent_obj_type   => px_parent_obj_type
    );
    l_edi_obj.edi_id := x_edi_id;
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_edi_obj;
    END IF;
  END save_edi_bo;

  -- PROCEDURE save_eft_bo
  --
  -- DESCRIPTION
  --     Create or update a logical eft contact point.
  PROCEDURE save_eft_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_eft_obj             IN            HZ_EFT_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_eft_id              OUT NOCOPY    NUMBER,
    x_eft_os              OUT NOCOPY    VARCHAR2,
    x_eft_osr             OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  ) IS
    l_eft_obj             HZ_EFT_CP_BO;
  BEGIN
    l_eft_obj := p_eft_obj;
    do_save_contact_point (
      p_init_msg_list      => p_init_msg_list,
      p_validate_bo_flag   => p_validate_bo_flag,
      p_cp_id              => l_eft_obj.eft_id,
      p_cp_os              => l_eft_obj.orig_system,
      p_cp_osr             => l_eft_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => NULL,
      p_telex_obj          => NULL,
      p_web_obj            => NULL,
      p_edi_obj            => NULL,
      p_eft_obj            => l_eft_obj,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_eft_obj.contact_pref_objs,
      p_cp_type            => 'EFT',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => NULL,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      x_cp_id              => x_eft_id,
      x_cp_os              => x_eft_os,
      x_cp_osr             => x_eft_osr,
      px_parent_id         => px_parent_id,
      px_parent_os         => px_parent_os,
      px_parent_osr        => px_parent_osr,
      px_parent_obj_type   => px_parent_obj_type
    );
  END save_eft_bo;

  PROCEDURE save_eft_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_eft_obj             IN            HZ_EFT_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_EFT_CP_BO,
    x_eft_id              OUT NOCOPY    NUMBER,
    x_eft_os              OUT NOCOPY    VARCHAR2,
    x_eft_osr             OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  ) IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
    l_eft_obj             HZ_EFT_CP_BO;
  BEGIN
    l_eft_obj := p_eft_obj;
    do_save_contact_point (
      p_init_msg_list      => fnd_api.g_true,
      p_validate_bo_flag   => p_validate_bo_flag,
      p_cp_id              => l_eft_obj.eft_id,
      p_cp_os              => l_eft_obj.orig_system,
      p_cp_osr             => l_eft_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => NULL,
      p_telex_obj          => NULL,
      p_web_obj            => NULL,
      p_edi_obj            => NULL,
      p_eft_obj            => l_eft_obj,
      p_sms_obj            => NULL,
      p_cp_pref_objs       => l_eft_obj.contact_pref_objs,
      p_cp_type            => 'EFT',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => p_obj_source,
      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,
      x_cp_id              => x_eft_id,
      x_cp_os              => x_eft_os,
      x_cp_osr             => x_eft_osr,
      px_parent_id         => px_parent_id,
      px_parent_os         => px_parent_os,
      px_parent_osr        => px_parent_osr,
      px_parent_obj_type   => px_parent_obj_type
    );
    l_eft_obj.eft_id := x_eft_id;
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_eft_obj;
    END IF;
  END save_eft_bo;

  -- PROCEDURE save_sms_bo
  --
  -- DESCRIPTION
  --     Create or update a logical sms contact point.
  PROCEDURE save_sms_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_sms_obj             IN            HZ_SMS_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    x_sms_id              OUT NOCOPY    NUMBER,
    x_sms_os              OUT NOCOPY    VARCHAR2,
    x_sms_osr             OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  ) IS
    l_sms_obj             HZ_SMS_CP_BO;
  BEGIN
    l_sms_obj := p_sms_obj;
    do_save_contact_point (
      p_init_msg_list      => p_init_msg_list,
      p_validate_bo_flag   => p_validate_bo_flag,
      p_cp_id              => l_sms_obj.sms_id,
      p_cp_os              => l_sms_obj.orig_system,
      p_cp_osr             => l_sms_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => NULL,
      p_telex_obj          => NULL,
      p_web_obj            => NULL,
      p_edi_obj            => NULL,
      p_eft_obj            => NULL,
      p_sms_obj            => l_sms_obj,
      p_cp_pref_objs       => l_sms_obj.contact_pref_objs,
      p_cp_type            => 'SMS',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => NULL,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      x_cp_id              => x_sms_id,
      x_cp_os              => x_sms_os,
      x_cp_osr             => x_sms_osr,
      px_parent_id         => px_parent_id,
      px_parent_os         => px_parent_os,
      px_parent_osr        => px_parent_osr,
      px_parent_obj_type   => px_parent_obj_type
    );
  END save_sms_bo;

  PROCEDURE save_sms_bo(
    p_validate_bo_flag    IN            VARCHAR2 := fnd_api.g_true,
    p_sms_obj             IN            HZ_SMS_CP_BO,
    p_created_by_module   IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj          OUT NOCOPY    HZ_SMS_CP_BO,
    x_sms_id              OUT NOCOPY    NUMBER,
    x_sms_os              OUT NOCOPY    VARCHAR2,
    x_sms_osr             OUT NOCOPY    VARCHAR2,
    px_parent_id          IN OUT NOCOPY NUMBER,
    px_parent_os          IN OUT NOCOPY VARCHAR2,
    px_parent_osr         IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type    IN OUT NOCOPY VARCHAR2
  ) IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
    l_sms_obj             HZ_SMS_CP_BO;
  BEGIN
    l_sms_obj := p_sms_obj;
    do_save_contact_point (
      p_init_msg_list      => fnd_api.g_true,
      p_validate_bo_flag   => p_validate_bo_flag,
      p_cp_id              => l_sms_obj.sms_id,
      p_cp_os              => l_sms_obj.orig_system,
      p_cp_osr             => l_sms_obj.orig_system_reference,
      p_phone_obj          => NULL,
      p_email_obj          => NULL,
      p_telex_obj          => NULL,
      p_web_obj            => NULL,
      p_edi_obj            => NULL,
      p_eft_obj            => NULL,
      p_sms_obj            => l_sms_obj,
      p_cp_pref_objs       => l_sms_obj.contact_pref_objs,
      p_cp_type            => 'SMS',
      p_created_by_module  => p_created_by_module,
      p_obj_source         => p_obj_source,
      x_return_status      => x_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,
      x_cp_id              => x_sms_id,
      x_cp_os              => x_sms_os,
      x_cp_osr             => x_sms_osr,
      px_parent_id         => px_parent_id,
      px_parent_os         => px_parent_os,
      px_parent_osr        => px_parent_osr,
      px_parent_obj_type   => px_parent_obj_type
    );
    l_sms_obj.sms_id := x_sms_id;
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_sms_obj;
    END IF;
  END save_sms_bo;

  -- PRIVATE PROCEDURE do_save_contact_point
  --
  -- DESCRIPTION
  --     Save contact point.
  PROCEDURE do_save_contact_point (
    p_init_msg_list              IN     VARCHAR2:= FND_API.G_FALSE,
    p_validate_bo_flag           IN     VARCHAR2 := fnd_api.g_true,
    p_cp_id                      IN     NUMBER,
    p_cp_os                      IN     VARCHAR2,
    p_cp_osr                     IN     VARCHAR2,
    p_phone_obj                  IN HZ_PHONE_CP_BO,
    p_email_obj                  IN HZ_EMAIL_CP_BO,
    p_telex_obj                  IN HZ_TELEX_CP_BO,
    p_web_obj                    IN HZ_WEB_CP_BO,
    p_edi_obj                    IN HZ_EDI_CP_BO,
    p_eft_obj                    IN HZ_EFT_CP_BO,
    p_sms_obj                    IN HZ_SMS_CP_BO,
    p_cp_pref_objs               IN OUT NOCOPY    HZ_CONTACT_PREF_OBJ_TBL,
    p_cp_type                    IN     VARCHAR2,
    p_created_by_module          IN     VARCHAR2,
    p_obj_source                 IN     VARCHAR2 := null,
    x_return_status              OUT    NOCOPY VARCHAR2,
    x_msg_count                  OUT    NOCOPY NUMBER,
    x_msg_data                   OUT    NOCOPY VARCHAR2,
    x_cp_id                      OUT    NOCOPY NUMBER,
    x_cp_os                      OUT    NOCOPY VARCHAR2,
    x_cp_osr                     OUT    NOCOPY VARCHAR2,
    px_parent_id                 IN OUT NOCOPY NUMBER,
    px_parent_os                 IN OUT NOCOPY VARCHAR2,
    px_parent_osr                IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type           IN OUT NOCOPY VARCHAR2
  ) IS
    l_return_status            VARCHAR2(30);
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(2000);
    l_create_update_flag       VARCHAR2(1);
    l_debug_prefix             VARCHAR2(30);
    l_parent_table             VARCHAR2(30);
  BEGIN
    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_save_contact_point(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := 'BO_API';
    IF(p_created_by_module IS NULL) THEN
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := 'BO_API';
    ELSE
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := p_created_by_module;
    END IF;

    -- get contact point id and os+osr
    x_cp_id := p_cp_id;
    x_cp_os := p_cp_os;
    x_cp_osr := p_cp_osr;

    -- check root business object to determine that it should be
    -- create or update, call HZ_REGISTRY_VALIDATE_BO_PVT
    l_create_update_flag := HZ_REGISTRY_VALIDATE_BO_PVT.check_bo_op(
                              p_entity_id      => x_cp_id,
                              p_entity_os      => x_cp_os,
                              p_entity_osr     => x_cp_osr,
                              p_entity_type    => 'HZ_CONTACT_POINTS',
                              p_cp_type        => p_cp_type,
                              p_parent_id      => px_parent_id,
                              p_parent_obj_type => px_parent_obj_type);

    IF(l_create_update_flag = 'E') THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', p_cp_type);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- base on different contact point type to pass in different object
    -- and call create or update
    CASE
      WHEN p_cp_type = 'PHONE' THEN
        IF(l_create_update_flag = 'C') THEN
          do_create_contact_point (
            p_validate_bo_flag   => p_validate_bo_flag,
            p_cp_id              => p_cp_id,
            p_cp_os              => p_cp_os,
            p_cp_osr             => p_cp_osr,
            p_phone_obj          => p_phone_obj,
            p_email_obj          => NULL,
            p_telex_obj          => NULL,
            p_web_obj            => NULL,
            p_edi_obj            => NULL,
            p_eft_obj            => NULL,
            p_sms_obj            => NULL,
            p_cp_pref_objs       => p_cp_pref_objs,
            p_cp_type            => p_cp_type,
            p_created_by_module  => p_created_by_module,
            p_obj_source         => p_obj_source,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            x_cp_id              => x_cp_id,
            x_cp_os              => x_cp_os,
            x_cp_osr             => x_cp_osr,
            px_parent_id         => px_parent_id,
            px_parent_os         => px_parent_os,
            px_parent_osr        => px_parent_osr,
            px_parent_obj_type   => px_parent_obj_type
          );
        ELSIF(l_create_update_flag = 'U') THEN
          do_update_contact_point (
            p_cp_id              => p_cp_id,
            p_cp_os              => p_cp_os,
            p_cp_osr             => p_cp_osr,
            p_phone_obj          => p_phone_obj,
            p_email_obj          => NULL,
            p_telex_obj          => NULL,
            p_web_obj            => NULL,
            p_edi_obj            => NULL,
            p_eft_obj            => NULL,
            p_sms_obj            => NULL,
            p_cp_pref_objs       => p_cp_pref_objs,
            p_cp_type            => p_cp_type,
            p_created_by_module  => p_created_by_module,
            p_obj_source         => p_obj_source,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            x_cp_id              => x_cp_id,
            x_cp_os              => x_cp_os,
            x_cp_osr             => x_cp_osr,
            p_parent_os          => px_parent_os);
        ELSE
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      WHEN p_cp_type = 'EMAIL' THEN
        IF(l_create_update_flag = 'C') THEN
          do_create_contact_point (
            p_validate_bo_flag   => p_validate_bo_flag,
            p_cp_id              => p_cp_id,
            p_cp_os              => p_cp_os,
            p_cp_osr             => p_cp_osr,
            p_phone_obj          => NULL,
            p_email_obj          => p_email_obj,
            p_telex_obj          => NULL,
            p_web_obj            => NULL,
            p_edi_obj            => NULL,
            p_eft_obj            => NULL,
            p_sms_obj            => NULL,
            p_cp_pref_objs       => p_cp_pref_objs,
            p_cp_type            => p_cp_type,
            p_created_by_module  => p_created_by_module,
            p_obj_source         => p_obj_source,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            x_cp_id              => x_cp_id,
            x_cp_os              => x_cp_os,
            x_cp_osr             => x_cp_osr,
            px_parent_id         => px_parent_id,
            px_parent_os         => px_parent_os,
            px_parent_osr        => px_parent_osr,
            px_parent_obj_type   => px_parent_obj_type
          );
        ELSIF(l_create_update_flag = 'U') THEN
          do_update_contact_point (
            p_cp_id              => p_cp_id,
            p_cp_os              => p_cp_os,
            p_cp_osr             => p_cp_osr,
            p_phone_obj          => NULL,
            p_email_obj          => p_email_obj,
            p_telex_obj          => NULL,
            p_web_obj            => NULL,
            p_edi_obj            => NULL,
            p_eft_obj            => NULL,
            p_sms_obj            => NULL,
            p_cp_pref_objs       => p_cp_pref_objs,
            p_cp_type            => p_cp_type,
            p_created_by_module  => p_created_by_module,
            p_obj_source         => p_obj_source,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            x_cp_id              => x_cp_id,
            x_cp_os              => x_cp_os,
            x_cp_osr             => x_cp_osr,
            p_parent_os          => px_parent_os);
        ELSE
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      WHEN p_cp_type = 'TLX' THEN
        IF(l_create_update_flag = 'C') THEN
          do_create_contact_point (
            p_validate_bo_flag   => p_validate_bo_flag,
            p_cp_id              => p_cp_id,
            p_cp_os              => p_cp_os,
            p_cp_osr             => p_cp_osr,
            p_phone_obj          => NULL,
            p_email_obj          => NULL,
            p_telex_obj          => p_telex_obj,
            p_web_obj            => NULL,
            p_edi_obj            => NULL,
            p_eft_obj            => NULL,
            p_sms_obj            => NULL,
            p_cp_pref_objs       => p_cp_pref_objs,
            p_cp_type            => p_cp_type,
            p_created_by_module  => p_created_by_module,
            p_obj_source         => p_obj_source,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            x_cp_id              => x_cp_id,
            x_cp_os              => x_cp_os,
            x_cp_osr             => x_cp_osr,
            px_parent_id         => px_parent_id,
            px_parent_os         => px_parent_os,
            px_parent_osr        => px_parent_osr,
            px_parent_obj_type   => px_parent_obj_type
          );
        ELSIF(l_create_update_flag = 'U') THEN
          do_update_contact_point (
            p_cp_id              => p_cp_id,
            p_cp_os              => p_cp_os,
            p_cp_osr             => p_cp_osr,
            p_phone_obj          => NULL,
            p_email_obj          => NULL,
            p_telex_obj          => p_telex_obj,
            p_web_obj            => NULL,
            p_edi_obj            => NULL,
            p_eft_obj            => NULL,
            p_sms_obj            => NULL,
            p_cp_pref_objs       => p_cp_pref_objs,
            p_cp_type            => p_cp_type,
            p_created_by_module  => p_created_by_module,
            p_obj_source         => p_obj_source,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            x_cp_id              => x_cp_id,
            x_cp_os              => x_cp_os,
            x_cp_osr             => x_cp_osr,
            p_parent_os          => px_parent_os);
        ELSE
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      WHEN p_cp_type = 'WEB' THEN
        IF(l_create_update_flag = 'C') THEN
          do_create_contact_point (
            p_validate_bo_flag   => p_validate_bo_flag,
            p_cp_id              => p_cp_id,
            p_cp_os              => p_cp_os,
            p_cp_osr             => p_cp_osr,
            p_phone_obj          => NULL,
            p_email_obj          => NULL,
            p_telex_obj          => NULL,
            p_web_obj            => p_web_obj,
            p_edi_obj            => NULL,
            p_eft_obj            => NULL,
            p_sms_obj            => NULL,
            p_cp_pref_objs       => p_cp_pref_objs,
            p_cp_type            => p_cp_type,
            p_created_by_module  => p_created_by_module,
            p_obj_source         => p_obj_source,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            x_cp_id              => x_cp_id,
            x_cp_os              => x_cp_os,
            x_cp_osr             => x_cp_osr,
            px_parent_id         => px_parent_id,
            px_parent_os         => px_parent_os,
            px_parent_osr        => px_parent_osr,
            px_parent_obj_type   => px_parent_obj_type
          );
        ELSIF(l_create_update_flag = 'U') THEN
          do_update_contact_point (
            p_cp_id              => p_cp_id,
            p_cp_os              => p_cp_os,
            p_cp_osr             => p_cp_osr,
            p_phone_obj          => NULL,
            p_email_obj          => NULL,
            p_telex_obj          => NULL,
            p_web_obj            => p_web_obj,
            p_edi_obj            => NULL,
            p_eft_obj            => NULL,
            p_sms_obj            => NULL,
            p_cp_pref_objs       => p_cp_pref_objs,
            p_cp_type            => p_cp_type,
            p_created_by_module  => p_created_by_module,
            p_obj_source         => p_obj_source,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            x_cp_id              => x_cp_id,
            x_cp_os              => x_cp_os,
            x_cp_osr             => x_cp_osr,
            p_parent_os          => px_parent_os);
        ELSE
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      WHEN p_cp_type = 'EDI' THEN
        IF(l_create_update_flag = 'C') THEN
          do_create_contact_point (
            p_validate_bo_flag   => p_validate_bo_flag,
            p_cp_id              => p_cp_id,
            p_cp_os              => p_cp_os,
            p_cp_osr             => p_cp_osr,
            p_phone_obj          => NULL,
            p_email_obj          => NULL,
            p_telex_obj          => NULL,
            p_web_obj            => NULL,
            p_edi_obj            => p_edi_obj,
            p_eft_obj            => NULL,
            p_sms_obj            => NULL,
            p_cp_pref_objs       => p_cp_pref_objs,
            p_cp_type            => p_cp_type,
            p_created_by_module  => p_created_by_module,
            p_obj_source         => p_obj_source,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            x_cp_id              => x_cp_id,
            x_cp_os              => x_cp_os,
            x_cp_osr             => x_cp_osr,
            px_parent_id         => px_parent_id,
            px_parent_os         => px_parent_os,
            px_parent_osr        => px_parent_osr,
            px_parent_obj_type   => px_parent_obj_type
          );
        ELSIF(l_create_update_flag = 'U') THEN
          do_update_contact_point (
            p_cp_id              => p_cp_id,
            p_cp_os              => p_cp_os,
            p_cp_osr             => p_cp_osr,
            p_phone_obj          => NULL,
            p_email_obj          => NULL,
            p_telex_obj          => NULL,
            p_web_obj            => NULL,
            p_edi_obj            => p_edi_obj,
            p_eft_obj            => NULL,
            p_sms_obj            => NULL,
            p_cp_pref_objs       => p_cp_pref_objs,
            p_cp_type            => p_cp_type,
            p_created_by_module  => p_created_by_module,
            p_obj_source         => p_obj_source,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            x_cp_id              => x_cp_id,
            x_cp_os              => x_cp_os,
            x_cp_osr             => x_cp_osr,
            p_parent_os          => px_parent_os);
        ELSE
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      WHEN p_cp_type = 'EFT' THEN
        IF(l_create_update_flag = 'C') THEN
          do_create_contact_point (
            p_validate_bo_flag   => p_validate_bo_flag,
            p_cp_id              => p_cp_id,
            p_cp_os              => p_cp_os,
            p_cp_osr             => p_cp_osr,
            p_phone_obj          => NULL,
            p_email_obj          => NULL,
            p_telex_obj          => NULL,
            p_web_obj            => NULL,
            p_edi_obj            => NULL,
            p_eft_obj            => p_eft_obj,
            p_sms_obj            => NULL,
            p_cp_pref_objs       => p_cp_pref_objs,
            p_cp_type            => p_cp_type,
            p_created_by_module  => p_created_by_module,
            p_obj_source         => p_obj_source,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            x_cp_id              => x_cp_id,
            x_cp_os              => x_cp_os,
            x_cp_osr             => x_cp_osr,
            px_parent_id         => px_parent_id,
            px_parent_os         => px_parent_os,
            px_parent_osr        => px_parent_osr,
            px_parent_obj_type   => px_parent_obj_type
          );
        ELSIF(l_create_update_flag = 'U') THEN
          do_update_contact_point (
            p_cp_id              => p_cp_id,
            p_cp_os              => p_cp_os,
            p_cp_osr             => p_cp_osr,
            p_phone_obj          => NULL,
            p_email_obj          => NULL,
            p_telex_obj          => NULL,
            p_web_obj            => NULL,
            p_edi_obj            => NULL,
            p_eft_obj            => p_eft_obj,
            p_sms_obj            => NULL,
            p_cp_pref_objs       => p_cp_pref_objs,
            p_cp_type            => p_cp_type,
            p_created_by_module  => p_created_by_module,
            p_obj_source         => p_obj_source,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            x_cp_id              => x_cp_id,
            x_cp_os              => x_cp_os,
            x_cp_osr             => x_cp_osr,
            p_parent_os          => px_parent_os);
        ELSE
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      WHEN p_cp_type = 'SMS' THEN
        IF(l_create_update_flag = 'C') THEN
          do_create_contact_point (
            p_validate_bo_flag   => p_validate_bo_flag,
            p_cp_id              => p_cp_id,
            p_cp_os              => p_cp_os,
            p_cp_osr             => p_cp_osr,
            p_phone_obj          => NULL,
            p_email_obj          => NULL,
            p_telex_obj          => NULL,
            p_web_obj            => NULL,
            p_edi_obj            => NULL,
            p_eft_obj            => NULL,
            p_sms_obj            => p_sms_obj,
            p_cp_pref_objs       => p_cp_pref_objs,
            p_cp_type            => p_cp_type,
            p_created_by_module  => p_created_by_module,
            p_obj_source         => p_obj_source,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            x_cp_id              => x_cp_id,
            x_cp_os              => x_cp_os,
            x_cp_osr             => x_cp_osr,
            px_parent_id         => px_parent_id,
            px_parent_os         => px_parent_os,
            px_parent_osr        => px_parent_osr,
            px_parent_obj_type   => px_parent_obj_type
          );
        ELSIF(l_create_update_flag = 'U') THEN
          do_update_contact_point (
            p_cp_id              => p_cp_id,
            p_cp_os              => p_cp_os,
            p_cp_osr             => p_cp_osr,
            p_phone_obj          => NULL,
            p_email_obj          => NULL,
            p_telex_obj          => NULL,
            p_web_obj            => NULL,
            p_edi_obj            => NULL,
            p_eft_obj            => NULL,
            p_sms_obj            => p_sms_obj,
            p_cp_pref_objs       => p_cp_pref_objs,
            p_cp_type            => p_cp_type,
            p_created_by_module  => p_created_by_module,
            p_obj_source         => p_obj_source,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            x_cp_id              => x_cp_id,
            x_cp_os              => x_cp_os,
            x_cp_osr             => x_cp_osr,
            p_parent_os          => px_parent_os);
        ELSE
          RAISE FND_API.G_EXC_ERROR;
        END IF;
    END CASE;

    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- reset Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_save_contact_point(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_save_contact_point(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_save_contact_point(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_save_contact_point(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_save_contact_point;

/*
The Get Contact Point API Procedures are retrieval services that return a full Contact Point business object of the type specified.
The user identifies a particular Contact Point business object using the TCA identifier and/or the objects Source System information.
Upon proper validation of the object, the full Contact Point business object is returned. The object consists of all data included
within the Contact Point business object, at all embedded levels. This includes the set of all data stored in the TCA tables for
each embedded entity.

To retrieve the appropriate embedded entities within the Contact Point business objects, the Get procedure returns all records for the
particular object from these TCA entity tables.

Embedded BO	    Mandatory	Multiple Logical API Procedure		Comments

Contact Point		Y	N	HZ_CONTACT_POINTS
Contact Preference	N	Y	HZ_CONTACT_PREFERENCES

*/


  PROCEDURE get_phone_bo (
	p_phone_id			IN	NUMBER,
	p_phone_os			IN	VARCHAR2,
	p_phone_osr			IN	VARCHAR2,
	x_phone_obj			OUT NOCOPY	HZ_PHONE_CP_BO,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_messages			OUT NOCOPY	HZ_MESSAGE_OBJ_TBL
  ) IS
    l_msg_data               VARCHAR2(2000);
    l_msg_count              NUMBER;
  BEGIN
    get_phone_bo (
	p_init_msg_list	=> FND_API.G_TRUE,
	p_phone_id	=> p_phone_id,
	p_phone_os	=> p_phone_os,
	p_phone_osr	=> p_phone_osr,
	x_phone_obj	=> x_phone_obj,
	x_return_status	=> x_return_status,
	x_msg_count	=> l_msg_count,
	x_msg_data	=> l_msg_data
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
  END get_phone_bo;

  --------------------------------------
  --
  -- PROCEDURE get_phone_bo
  --
  -- DESCRIPTION
  --     Get a logical phone.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_phone_id         phone ID.If this id passed in, return only one phone obj.
  --     p_phone_os           phone orig system.
  --     p_phone_osr          phone orig system reference.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_phone_obj         Logical phone record.
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


PROCEDURE get_phone_bo (
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_phone_id			IN	NUMBER,
	p_phone_os			IN	VARCHAR2,
	p_phone_osr			IN	VARCHAR2,
	x_phone_obj			OUT NOCOPY	HZ_PHONE_CP_BO,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2
  ) is
 l_debug_prefix              VARCHAR2(30) := '';

  l_phone_id  number;
  l_phone_os  varchar2(30);
  l_phone_osr varchar2(255);
  l_phone_objs HZ_PHONE_CP_BO_TBL;
BEGIN

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_phone_bo_pub.get_phone_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

    	-- check if pass in contact_point_id and/or os+osr
    	-- extraction validation logic is same as update

    	l_phone_id := p_phone_id;
    	l_phone_os := p_phone_os;
    	l_phone_osr := p_phone_osr;

    	HZ_EXTRACT_BO_UTIL_PVT.validate_ssm_id(
      		px_id              => l_phone_id,
      		px_os              => l_phone_os,
      		px_osr             => l_phone_osr,
      		p_obj_type         => 'PHONE',
      		x_return_status    => x_return_status,
      		x_msg_count        => x_msg_count,
      		x_msg_data         => x_msg_data);

    	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE fnd_api.g_exc_error;
   	 END IF;

	HZ_EXTRACT_CONT_POINT_BO_PVT.get_phone_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_phone_id => l_phone_id,
		 p_parent_id => NULL,
 		 p_parent_table_name  => NULL,
		 p_action_type => NULL,
		 x_phone_objs => l_phone_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	x_phone_obj := l_phone_objs(1);
	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;


	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_phone_bo_pub.get_phone_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_phone_bo_pub.get_phone_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_phone_bo_pub.get_phone_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_phone_bo_pub.get_phone_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

  PROCEDURE get_telex_bo (
	p_telex_id			IN	NUMBER,
	p_telex_os			IN	VARCHAR2,
	p_telex_osr			IN	VARCHAR2,
	x_telex_obj			OUT NOCOPY	HZ_TELEX_CP_BO,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_messages			OUT NOCOPY	HZ_MESSAGE_OBJ_TBL
  ) is
    l_msg_data           VARCHAR2(2000);
    l_msg_count          NUMBER;
  BEGIN
    get_telex_bo (
	p_init_msg_list	=> FND_API.G_TRUE,
	p_telex_id	=> p_telex_id,
	p_telex_os	=> p_telex_os,
	p_telex_osr	=> p_telex_osr,
	x_telex_obj	=> x_telex_obj,
	x_return_status	=> x_return_status,
	x_msg_count	=> l_msg_count,
	x_msg_data	=> l_msg_data);
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
  END get_telex_bo;

 --------------------------------------
  --
  -- PROCEDURE get_telex_bo
  --
  -- DESCRIPTION
  --     Get a logical telex.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_telex_id         telex ID.If this id passed in, return only one telex obj.
  --     p_telex_os           telex orig system.
  --     p_telex_osr          telex orig system reference.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_telex_obj         Logical telex record.
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


PROCEDURE get_telex_bo (
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_telex_id			IN	NUMBER,
	p_telex_os			IN	VARCHAR2,
	p_telex_osr			IN	VARCHAR2,
	x_telex_obj			OUT NOCOPY	HZ_TELEX_CP_BO,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2
  ) is
 l_debug_prefix              VARCHAR2(30) := '';

  l_telex_id  number;
  l_telex_os  varchar2(30);
  l_telex_osr varchar2(255);
  l_telex_objs HZ_TELEX_CP_BO_TBL;
BEGIN

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_telex_bo_pub.get_telex_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

    	-- check if pass in contact_point_id and/or os+osr
    	-- extraction validation logic is same as update

    	l_telex_id := p_telex_id;
    	l_telex_os := p_telex_os;
    	l_telex_osr := p_telex_osr;

    	HZ_EXTRACT_BO_UTIL_PVT.validate_ssm_id(
      		px_id              => l_telex_id,
      		px_os              => l_telex_os,
      		px_osr             => l_telex_osr,
      		p_obj_type         => 'TLX',
      		x_return_status    => x_return_status,
      		x_msg_count        => x_msg_count,
      		x_msg_data         => x_msg_data);

    	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE fnd_api.g_exc_error;
   	 END IF;

	HZ_EXTRACT_CONT_POINT_BO_PVT.get_telex_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_telex_id => l_telex_id,
		 p_parent_id => NULL,
 		 p_parent_table_name  => NULL,
		 p_action_type => NULL,
		 x_telex_objs => l_telex_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	x_telex_obj := l_telex_objs(1);
	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;


	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_telex_bo_pub.get_telex_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_telex_bo_pub.get_telex_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_telex_bo_pub.get_telex_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_telex_bo_pub.get_telex_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

  PROCEDURE get_email_bo (
	p_email_id			IN	NUMBER,
	p_email_os			IN	VARCHAR2,
	p_email_osr			IN	VARCHAR2,
	x_email_obj			OUT NOCOPY	HZ_EMAIL_CP_BO,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_messages			OUT NOCOPY	HZ_MESSAGE_OBJ_TBL
  ) IS
    l_msg_data          VARCHAR2(2000);
    l_msg_count         NUMBER;
  BEGIN
    get_email_bo (
	p_init_msg_list	=> FND_API.G_TRUE,
	p_email_id	=> p_email_id,
	p_email_os	=> p_email_os,
	p_email_osr	=> p_email_osr,
	x_email_obj	=> x_email_obj,
	x_return_status	=> x_return_status,
	x_msg_count	=> l_msg_count,
	x_msg_data	=> l_msg_data);
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
  END get_email_bo;

 --------------------------------------
  --
  -- PROCEDURE get_email_bo
  --
  -- DESCRIPTION
  --     Get a logical email.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_email_id         email ID.If this id passed in, return only one email obj.
  --     p_email_os           email orig system.
  --     p_email_osr          email orig system reference.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_email_obj         Logical email record.
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


PROCEDURE get_email_bo (
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_email_id			IN	NUMBER,
	p_email_os			IN	VARCHAR2,
	p_email_osr			IN	VARCHAR2,
	x_email_obj			OUT NOCOPY	HZ_EMAIL_CP_BO,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2
  ) is
 l_debug_prefix              VARCHAR2(30) := '';

  l_email_id  number;
  l_email_os  varchar2(30);
  l_email_osr varchar2(255);
  l_email_objs HZ_EMAIL_CP_BO_TBL;
BEGIN

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_email_bo_pub.get_email_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

    	-- check if pass in contact_point_id and/or os+osr
    	-- extraction validation logic is same as update

    	l_email_id := p_email_id;
    	l_email_os := p_email_os;
    	l_email_osr := p_email_osr;

    	HZ_EXTRACT_BO_UTIL_PVT.validate_ssm_id(
      		px_id              => l_email_id,
      		px_os              => l_email_os,
      		px_osr             => l_email_osr,
      		p_obj_type         => 'EMAIL',
      		x_return_status    => x_return_status,
      		x_msg_count        => x_msg_count,
      		x_msg_data         => x_msg_data);

    	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE fnd_api.g_exc_error;
   	 END IF;

	HZ_EXTRACT_CONT_POINT_BO_PVT.get_email_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_email_id => l_email_id,
		 p_parent_id => NULL,
 		 p_parent_table_name  => NULL,
		 p_action_type => NULL,
		 x_email_objs => l_email_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	x_email_obj := l_email_objs(1);
	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;


	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_email_bo_pub.get_email_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_email_bo_pub.get_email_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_email_bo_pub.get_email_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_email_bo_pub.get_email_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

  PROCEDURE get_web_bo (
	p_web_id			IN	NUMBER,
	p_web_os			IN	VARCHAR2,
	p_web_osr			IN	VARCHAR2,
	x_web_obj			OUT NOCOPY	HZ_WEB_CP_BO,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_messages			OUT NOCOPY	HZ_MESSAGE_OBJ_TBL
  ) IS
    l_msg_data          VARCHAR2(2000);
    l_msg_count         NUMBER;
  BEGIN
    get_web_bo (
	p_init_msg_list	=> FND_API.G_TRUE,
	p_web_id	=> p_web_id,
	p_web_os	=> p_web_os,
	p_web_osr	=> p_web_osr,
	x_web_obj	=> x_web_obj,
	x_return_status	=> x_return_status,
	x_msg_count	=> l_msg_count,
	x_msg_data	=> l_msg_data);
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
  END get_web_bo;

 --------------------------------------
  --
  -- PROCEDURE get_web_bo
  --
  -- DESCRIPTION
  --     Get a logical web.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_web_id         web ID.If this id passed in, return only one web obj.
  --     p_web_os           web orig system.
  --     p_web_osr          web orig system reference.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_web_obj         Logical web record.
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


PROCEDURE get_web_bo (
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_web_id			IN	NUMBER,
	p_web_os			IN	VARCHAR2,
	p_web_osr			IN	VARCHAR2,
	x_web_obj			OUT NOCOPY	HZ_WEB_CP_BO,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2
  ) is
 l_debug_prefix              VARCHAR2(30) := '';

  l_web_id  number;
  l_web_os  varchar2(30);
  l_web_osr varchar2(255);
  l_web_objs HZ_WEB_CP_BO_TBL;
BEGIN

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_web_bo_pub.get_web_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

    	-- check if pass in contact_point_id and/or os+osr
    	-- extraction validation logic is same as update

    	l_web_id := p_web_id;
    	l_web_os := p_web_os;
    	l_web_osr := p_web_osr;

    	HZ_EXTRACT_BO_UTIL_PVT.validate_ssm_id(
      		px_id              => l_web_id,
      		px_os              => l_web_os,
      		px_osr             => l_web_osr,
      		p_obj_type         => 'WEB',
      		x_return_status    => x_return_status,
      		x_msg_count        => x_msg_count,
      		x_msg_data         => x_msg_data);

    	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE fnd_api.g_exc_error;
   	 END IF;

	HZ_EXTRACT_CONT_POINT_BO_PVT.get_web_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_web_id => l_web_id,
		 p_parent_id => NULL,
 		 p_parent_table_name  => NULL,
		 p_action_type => NULL,
		 x_web_objs => l_web_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	x_web_obj := l_web_objs(1);
	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;


	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_web_bo_pub.get_web_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_web_bo_pub.get_web_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_web_bo_pub.get_web_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_web_bo_pub.get_web_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

  PROCEDURE get_edi_bo (
	p_edi_id			IN	NUMBER,
	p_edi_os			IN	VARCHAR2,
	p_edi_osr			IN	VARCHAR2,
	x_edi_obj			OUT NOCOPY	HZ_EDI_CP_BO,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_messages			OUT NOCOPY	HZ_MESSAGE_OBJ_TBL
  ) IS
    l_msg_data          VARCHAR2(2000);
    l_msg_count         NUMBER;
  BEGIN
    get_edi_bo (
	p_init_msg_list	=> FND_API.G_TRUE,
	p_edi_id	=> p_edi_id,
	p_edi_os	=> p_edi_os,
	p_edi_osr	=> p_edi_osr,
	x_edi_obj	=> x_edi_obj,
	x_return_status	=> x_return_status,
	x_msg_count	=> l_msg_count,
	x_msg_data	=> l_msg_data);
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
  END get_edi_bo;
 --------------------------------------
  --
  -- PROCEDURE get_edi_bo
  --
  -- DESCRIPTION
  --     Get a logical edi.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_edi_id         edi ID.If this id passed in, return only one edi obj.
  --     p_edi_os           edi orig system.
  --     p_edi_osr          edi orig system reference.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_edi_obj         Logical edi record.
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


PROCEDURE get_edi_bo (
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_edi_id			IN	NUMBER,
	p_edi_os			IN	VARCHAR2,
	p_edi_osr			IN	VARCHAR2,
	x_edi_obj			OUT NOCOPY	HZ_EDI_CP_BO,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2
  ) is
 l_debug_prefix              VARCHAR2(30) := '';

  l_edi_id  number;
  l_edi_os  varchar2(30);
  l_edi_osr varchar2(255);
  l_edi_objs HZ_EDI_CP_BO_TBL;
BEGIN

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_edi_bo_pub.get_edi_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

    	-- check if pass in contact_point_id and/or os+osr
    	-- extraction validation logic is same as update

    	l_edi_id := p_edi_id;
    	l_edi_os := p_edi_os;
    	l_edi_osr := p_edi_osr;

    	HZ_EXTRACT_BO_UTIL_PVT.validate_ssm_id(
      		px_id              => l_edi_id,
      		px_os              => l_edi_os,
      		px_osr             => l_edi_osr,
      		p_obj_type         => 'EDI',
      		x_return_status    => x_return_status,
      		x_msg_count        => x_msg_count,
      		x_msg_data         => x_msg_data);

    	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE fnd_api.g_exc_error;
   	 END IF;

	HZ_EXTRACT_CONT_POINT_BO_PVT.get_edi_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_edi_id => l_edi_id,
		 p_parent_id => NULL,
 		 p_parent_table_name  => NULL,
		 p_action_type => NULL,
		 x_edi_objs => l_edi_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	x_edi_obj := l_edi_objs(1);
	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;


	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_edi_bo_pub.get_edi_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_edi_bo_pub.get_edi_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_edi_bo_pub.get_edi_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_edi_bo_pub.get_edi_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

  PROCEDURE get_eft_bo (
	p_eft_id			IN	NUMBER,
	p_eft_os			IN	VARCHAR2,
	p_eft_osr			IN	VARCHAR2,
	x_eft_obj			OUT NOCOPY	HZ_EFT_CP_BO,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_messages			OUT NOCOPY	HZ_MESSAGE_OBJ_TBL
  ) IS
    l_msg_data         VARCHAR2(2000);
    l_msg_count        NUMBER;
  BEGIN
    get_eft_bo (
	p_init_msg_list	=> FND_API.G_TRUE,
	p_eft_id	=> p_eft_id,
	p_eft_os	=> p_eft_os,
	p_eft_osr	=> p_eft_osr,
	x_eft_obj	=> x_eft_obj,
	x_return_status	=> x_return_status,
	x_msg_count	=> l_msg_count,
	x_msg_data	=> l_msg_data);
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
  END get_eft_bo;

 --------------------------------------
  --
  -- PROCEDURE get_eft_bo
  --
  -- DESCRIPTION
  --     Get a logical eft.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_eft_id         eft ID.If this id passed in, return only one eft obj.
  --     p_eft_os           eft orig system.
  --     p_eft_osr          eft orig system reference.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_eft_obj         Logical eft record.
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


PROCEDURE get_eft_bo (
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_eft_id			IN	NUMBER,
	p_eft_os			IN	VARCHAR2,
	p_eft_osr			IN	VARCHAR2,
	x_eft_obj			OUT NOCOPY	HZ_EFT_CP_BO,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2
  ) is
 l_debug_prefix              VARCHAR2(30) := '';

  l_eft_id  number;
  l_eft_os  varchar2(30);
  l_eft_osr varchar2(255);
  l_eft_objs HZ_EFT_CP_BO_TBL;
BEGIN

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_eft_bo_pub.get_eft_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

    	-- check if pass in contact_point_id and/or os+osr
    	-- extraction validation logic is same as update

    	l_eft_id := p_eft_id;
    	l_eft_os := p_eft_os;
    	l_eft_osr := p_eft_osr;

    	HZ_EXTRACT_BO_UTIL_PVT.validate_ssm_id(
      		px_id              => l_eft_id,
      		px_os              => l_eft_os,
      		px_osr             => l_eft_osr,
      		p_obj_type         => 'EFT',
      		x_return_status    => x_return_status,
      		x_msg_count        => x_msg_count,
      		x_msg_data         => x_msg_data);

    	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE fnd_api.g_exc_error;
   	 END IF;

	HZ_EXTRACT_CONT_POINT_BO_PVT.get_eft_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_eft_id => l_eft_id,
		 p_parent_id => NULL,
 		 p_parent_table_name  => NULL,
		 p_action_type => NULL,
		 x_eft_objs => l_eft_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	x_eft_obj := l_eft_objs(1);
	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;


	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_eft_bo_pub.get_eft_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_eft_bo_pub.get_eft_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_eft_bo_pub.get_eft_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_eft_bo_pub.get_eft_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

  PROCEDURE get_sms_bo (
	p_sms_id			IN	NUMBER,
	p_sms_os			IN	VARCHAR2,
	p_sms_osr			IN	VARCHAR2,
	x_sms_obj			OUT NOCOPY	HZ_SMS_CP_BO,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_messages			OUT NOCOPY	HZ_MESSAGE_OBJ_TBL
  ) IS
    l_msg_data         VARCHAR2(2000);
    l_msg_count        NUMBER;
  BEGIN
    get_sms_bo (
	p_init_msg_list	=> FND_API.G_TRUE,
	p_sms_id	=> p_sms_id,
	p_sms_os	=> p_sms_os,
	p_sms_osr	=> p_sms_osr,
	x_sms_obj	=> x_sms_obj,
	x_return_status	=> x_return_status,
	x_msg_count	=> l_msg_count,
	x_msg_data	=> l_msg_data);
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
  END get_sms_bo;

 --------------------------------------
  --
  -- PROCEDURE get_sms_bo
  --
  -- DESCRIPTION
  --     Get a logical sms.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
  --     p_sms_id         sms ID.If this id passed in, return only one sms obj.
  --     p_sms_os           sms orig system.
  --     p_sms_osr          sms orig system reference.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_sms_obj         Logical sms record.
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


PROCEDURE get_sms_bo (
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_sms_id			IN	NUMBER,
	p_sms_os			IN	VARCHAR2,
	p_sms_osr			IN	VARCHAR2,
	x_sms_obj			OUT NOCOPY	HZ_SMS_CP_BO,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2
  ) is
 l_debug_prefix              VARCHAR2(30) := '';

  l_sms_id  number;
  l_sms_os  varchar2(30);
  l_sms_osr varchar2(255);
  l_sms_objs HZ_SMS_CP_BO_TBL;
BEGIN

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_sms_bo_pub.get_sms_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

    	-- check if pass in contact_point_id and/or os+osr
    	-- extraction validation logic is same as update

    	l_sms_id := p_sms_id;
    	l_sms_os := p_sms_os;
    	l_sms_osr := p_sms_osr;

    	HZ_EXTRACT_BO_UTIL_PVT.validate_ssm_id(
      		px_id              => l_sms_id,
      		px_os              => l_sms_os,
      		px_osr             => l_sms_osr,
      		p_obj_type         => 'SMS',
      		x_return_status    => x_return_status,
      		x_msg_count        => x_msg_count,
      		x_msg_data         => x_msg_data);

    	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE fnd_api.g_exc_error;
   	 END IF;

	HZ_EXTRACT_CONT_POINT_BO_PVT.get_sms_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_sms_id => l_sms_id,
		 p_parent_id => NULL,
 		 p_parent_table_name  => NULL,
		 p_action_type => NULL,
		 x_sms_objs => l_sms_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	x_sms_obj := l_sms_objs(1);
	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;


	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_sms_bo_pub.get_sms_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;


 EXCEPTION

  WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_sms_bo_pub.get_sms_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_sms_bo_pub.get_sms_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'hz_sms_bo_pub.get_sms_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;


END hz_contact_point_bo_pub;

/
