--------------------------------------------------------
--  DDL for Package Body HZ_CONTACT_POINT_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CONTACT_POINT_BO_PVT" AS
/*$Header: ARHBCPVB.pls 120.6 2006/05/18 22:23:48 acng noship $ */

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
  )IS
    l_cp_id                      NUMBER;
    l_cp_os                      VARCHAR2(30);
    l_cp_osr                     VARCHAR2(255);
    l_owner_table_id             NUMBER;
    l_owner_table_os             VARCHAR2(30);
    l_owner_table_osr            VARCHAR2(255);
    l_parent_obj_type            VARCHAR2(30);
    l_debug_prefix               VARCHAR2(30);
    l_current_cp_type            VARCHAR2(30);
    l_cbm                        VARCHAR2(30);
  BEGIN
    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_contact_points(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    l_owner_table_id  := p_owner_table_id;
    l_owner_table_os  := p_owner_table_os;
    l_owner_table_osr := p_owner_table_osr;
    l_parent_obj_type := p_parent_obj_type;

    l_cbm := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;

    IF(p_create_update_flag = 'C') THEN
      -----------------------------
      -- Create phone contact point
      -----------------------------
      IF((p_phone_objs IS NOT NULL) AND (p_phone_objs.COUNT > 0)) THEN
        l_current_cp_type := 'PHONE';

        FOR i IN 1..p_phone_objs.COUNT LOOP
          HZ_CONTACT_POINT_BO_PUB.do_create_contact_point(
            p_init_msg_list                   => FND_API.G_FALSE,
            p_validate_bo_flag                => FND_API.G_FALSE,
            p_cp_id                           => p_phone_objs(i).phone_id,
            p_cp_os                           => p_phone_objs(i).orig_system,
            p_cp_osr                          => p_phone_objs(i).orig_system_reference,
            p_phone_obj                       => p_phone_objs(i),
            p_email_obj                       => NULL,
            p_telex_obj                       => NULL,
            p_web_obj                         => NULL,
            p_edi_obj                         => NULL,
            p_eft_obj                         => NULL,
            p_sms_obj                         => NULL,
            p_cp_pref_objs                    => p_phone_objs(i).contact_pref_objs,
            p_cp_type                         => l_current_cp_type,
            p_created_by_module               => HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE,
            p_obj_source                      => p_obj_source,
            x_return_status                   => x_return_status,
            x_msg_count                       => x_msg_count,
            x_msg_data                        => x_msg_data,
            x_cp_id                           => l_cp_id,
            x_cp_os                           => l_cp_os,
            x_cp_osr                          => l_cp_osr,
            px_parent_id                      => l_owner_table_id,
            px_parent_os                      => l_owner_table_os,
            px_parent_osr                     => l_owner_table_osr,
            px_parent_obj_type                => l_parent_obj_type
          );
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
              hz_utility_v2pub.debug(p_message=>'Create PHONE - Error occurred at hz_contact_point_bo_pvt.save_contact_points: '||l_cp_id||' '||l_cp_os||' '||l_cp_osr||', owner table: '||l_owner_table_id||' '||l_owner_table_os||' '||l_owner_table_osr,
                                     p_prefix=>l_debug_prefix,
                                     p_msg_level=>fnd_log.level_procedure);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;
          p_phone_objs(i).phone_id := l_cp_id;
        END LOOP;
      END IF;

      -----------------------------
      -- Create telex contact point
      -----------------------------
      IF((p_telex_objs IS NOT NULL) AND (p_telex_objs.COUNT > 0)) THEN
        l_current_cp_type := 'TLX';

        FOR i IN 1..p_telex_objs.COUNT LOOP
          HZ_CONTACT_POINT_BO_PUB.do_create_contact_point(
            p_init_msg_list                   => FND_API.G_FALSE,
            p_validate_bo_flag                => FND_API.G_FALSE,
            p_cp_id                           => p_telex_objs(i).telex_id,
            p_cp_os                           => p_telex_objs(i).orig_system,
            p_cp_osr                          => p_telex_objs(i).orig_system_reference,
            p_phone_obj                       => NULL,
            p_email_obj                       => NULL,
            p_telex_obj                       => p_telex_objs(i),
            p_web_obj                         => NULL,
            p_edi_obj                         => NULL,
            p_eft_obj                         => NULL,
            p_sms_obj                         => NULL,
            p_cp_pref_objs                    => p_telex_objs(i).contact_pref_objs,
            p_cp_type                         => l_current_cp_type,
            p_created_by_module               => HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE,
            p_obj_source                      => p_obj_source,
            x_return_status                   => x_return_status,
            x_msg_count                       => x_msg_count,
            x_msg_data                        => x_msg_data,
            x_cp_id                           => l_cp_id,
            x_cp_os                           => l_cp_os,
            x_cp_osr                          => l_cp_osr,
            px_parent_id                      => l_owner_table_id,
            px_parent_os                      => l_owner_table_os,
            px_parent_osr                     => l_owner_table_osr,
            px_parent_obj_type                => l_parent_obj_type
          );
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
              hz_utility_v2pub.debug(p_message=>'Create TLX - Error occurred at hz_contact_point_bo_pvt.save_contact_points: '||l_cp_id||' '||l_cp_os||' '||l_cp_osr||', owner table: '||l_owner_table_id||' '||l_owner_table_os||' '||l_owner_table_osr,
                                     p_prefix=>l_debug_prefix,
                                     p_msg_level=>fnd_log.level_procedure);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;
          p_telex_objs(i).telex_id := l_cp_id;
        END LOOP;
      END IF;

      -----------------------------
      -- Create email contact point
      -----------------------------
      IF((p_email_objs IS NOT NULL) AND (p_email_objs.COUNT > 0)) THEN
        l_current_cp_type := 'EMAIL';

        FOR i IN 1..p_email_objs.COUNT LOOP
          HZ_CONTACT_POINT_BO_PUB.do_create_contact_point(
            p_init_msg_list                   => FND_API.G_FALSE,
            p_validate_bo_flag                => FND_API.G_FALSE,
            p_cp_id                           => p_email_objs(i).email_id,
            p_cp_os                           => p_email_objs(i).orig_system,
            p_cp_osr                          => p_email_objs(i).orig_system_reference,
            p_phone_obj                       => NULL,
            p_email_obj                       => p_email_objs(i),
            p_telex_obj                       => NULL,
            p_web_obj                         => NULL,
            p_edi_obj                         => NULL,
            p_eft_obj                         => NULL,
            p_sms_obj                         => NULL,
            p_cp_pref_objs                    => p_email_objs(i).contact_pref_objs,
            p_cp_type                         => l_current_cp_type,
            p_created_by_module               => HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE,
            p_obj_source                      => p_obj_source,
            x_return_status                   => x_return_status,
            x_msg_count                       => x_msg_count,
            x_msg_data                        => x_msg_data,
            x_cp_id                           => l_cp_id,
            x_cp_os                           => l_cp_os,
            x_cp_osr                          => l_cp_osr,
            px_parent_id                      => l_owner_table_id,
            px_parent_os                      => l_owner_table_os,
            px_parent_osr                     => l_owner_table_osr,
            px_parent_obj_type                => l_parent_obj_type
          );
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
              hz_utility_v2pub.debug(p_message=>'Create EMAIL - Error occurred at hz_contact_point_bo_pvt.save_contact_points: '||l_cp_id||' '||l_cp_os||' '||l_cp_osr||', owner table: '||l_owner_table_id||' '||l_owner_table_os||' '||l_owner_table_osr,
                                     p_prefix=>l_debug_prefix,
                                     p_msg_level=>fnd_log.level_procedure);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;
          p_email_objs(i).email_id := l_cp_id;
        END LOOP;
      END IF;

      -----------------------------
      -- Create web contact point
      -----------------------------
      IF((p_web_objs IS NOT NULL) AND (p_web_objs.COUNT > 0)) THEN
        l_current_cp_type := 'WEB';

        FOR i IN 1..p_web_objs.COUNT LOOP
          HZ_CONTACT_POINT_BO_PUB.do_create_contact_point(
            p_init_msg_list                   => FND_API.G_FALSE,
            p_validate_bo_flag                => FND_API.G_FALSE,
            p_cp_id                           => p_web_objs(i).web_id,
            p_cp_os                           => p_web_objs(i).orig_system,
            p_cp_osr                          => p_web_objs(i).orig_system_reference,
            p_phone_obj                       => NULL,
            p_email_obj                       => NULL,
            p_telex_obj                       => NULL,
            p_web_obj                         => p_web_objs(i),
            p_edi_obj                         => NULL,
            p_eft_obj                         => NULL,
            p_sms_obj                         => NULL,
            p_cp_pref_objs                    => p_web_objs(i).contact_pref_objs,
            p_cp_type                         => l_current_cp_type,
            p_created_by_module               => HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE,
            p_obj_source                      => p_obj_source,
            x_return_status                   => x_return_status,
            x_msg_count                       => x_msg_count,
            x_msg_data                        => x_msg_data,
            x_cp_id                           => l_cp_id,
            x_cp_os                           => l_cp_os,
            x_cp_osr                          => l_cp_osr,
            px_parent_id                      => l_owner_table_id,
            px_parent_os                      => l_owner_table_os,
            px_parent_osr                     => l_owner_table_osr,
            px_parent_obj_type                => l_parent_obj_type
          );
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
              hz_utility_v2pub.debug(p_message=>'Create WEB - Error occurred at hz_contact_point_bo_pvt.save_contact_points: '||l_cp_id||' '||l_cp_os||' '||l_cp_osr||', owner table: '||l_owner_table_id||' '||l_owner_table_os||' '||l_owner_table_osr,
                                     p_prefix=>l_debug_prefix,
                                     p_msg_level=>fnd_log.level_procedure);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;
          p_web_objs(i).web_id := l_cp_id;
        END LOOP;
      END IF;

      -----------------------------
      -- Create edi contact point
      -----------------------------
      IF((p_edi_objs IS NOT NULL) AND (p_edi_objs.COUNT > 0)) THEN
        l_current_cp_type := 'EDI';

        FOR i IN 1..p_edi_objs.COUNT LOOP
          HZ_CONTACT_POINT_BO_PUB.do_create_contact_point(
            p_init_msg_list                   => FND_API.G_FALSE,
            p_validate_bo_flag                => FND_API.G_FALSE,
            p_cp_id                           => p_edi_objs(i).edi_id,
            p_cp_os                           => p_edi_objs(i).orig_system,
            p_cp_osr                          => p_edi_objs(i).orig_system_reference,
            p_phone_obj                       => NULL,
            p_email_obj                       => NULL,
            p_telex_obj                       => NULL,
            p_web_obj                         => NULL,
            p_edi_obj                         => p_edi_objs(i),
            p_eft_obj                         => NULL,
            p_sms_obj                         => NULL,
            p_cp_pref_objs                    => p_edi_objs(i).contact_pref_objs,
            p_cp_type                         => l_current_cp_type,
            p_created_by_module               => HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE,
            p_obj_source                      => p_obj_source,
            x_return_status                   => x_return_status,
            x_msg_count                       => x_msg_count,
            x_msg_data                        => x_msg_data,
            x_cp_id                           => l_cp_id,
            x_cp_os                           => l_cp_os,
            x_cp_osr                          => l_cp_osr,
            px_parent_id                      => l_owner_table_id,
            px_parent_os                      => l_owner_table_os,
            px_parent_osr                     => l_owner_table_osr,
            px_parent_obj_type                => l_parent_obj_type
          );
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
              hz_utility_v2pub.debug(p_message=>'Create EDI - Error occurred at hz_contact_point_bo_pvt.save_contact_points: '||l_cp_id||' '||l_cp_os||' '||l_cp_osr||', owner table: '||l_owner_table_id||' '||l_owner_table_os||' '||l_owner_table_osr,
                                     p_prefix=>l_debug_prefix,
                                     p_msg_level=>fnd_log.level_procedure);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;
          p_edi_objs(i).edi_id := l_cp_id;
        END LOOP;
      END IF;

      -----------------------------
      -- Create eft contact point
      -----------------------------
      IF((p_eft_objs IS NOT NULL) AND (p_eft_objs.COUNT > 0)) THEN
        l_current_cp_type := 'EFT';

        FOR i IN 1..p_eft_objs.COUNT LOOP
          HZ_CONTACT_POINT_BO_PUB.do_create_contact_point(
            p_init_msg_list                   => FND_API.G_FALSE,
            p_validate_bo_flag                => FND_API.G_FALSE,
            p_cp_id                           => p_eft_objs(i).eft_id,
            p_cp_os                           => p_eft_objs(i).orig_system,
            p_cp_osr                          => p_eft_objs(i).orig_system_reference,
            p_phone_obj                       => NULL,
            p_email_obj                       => NULL,
            p_telex_obj                       => NULL,
            p_web_obj                         => NULL,
            p_edi_obj                         => NULL,
            p_eft_obj                         => p_eft_objs(i),
            p_sms_obj                         => NULL,
            p_cp_pref_objs                    => p_eft_objs(i).contact_pref_objs,
            p_cp_type                         => l_current_cp_type,
            p_created_by_module               => HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE,
            p_obj_source                      => p_obj_source,
            x_return_status                   => x_return_status,
            x_msg_count                       => x_msg_count,
            x_msg_data                        => x_msg_data,
            x_cp_id                           => l_cp_id,
            x_cp_os                           => l_cp_os,
            x_cp_osr                          => l_cp_osr,
            px_parent_id                      => l_owner_table_id,
            px_parent_os                      => l_owner_table_os,
            px_parent_osr                     => l_owner_table_osr,
            px_parent_obj_type                => l_parent_obj_type
          );
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
              hz_utility_v2pub.debug(p_message=>'Create EFT - Error occurred at hz_contact_point_bo_pvt.save_contact_points: '||l_cp_id||' '||l_cp_os||' '||l_cp_osr||', owner table: '||l_owner_table_id||' '||l_owner_table_os||' '||l_owner_table_osr,
                                     p_prefix=>l_debug_prefix,
                                     p_msg_level=>fnd_log.level_procedure);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;
          p_eft_objs(i).eft_id := l_cp_id;
        END LOOP;
      END IF;

      -----------------------------
      -- Create sms contact point
      -----------------------------
      IF((p_sms_objs IS NOT NULL) AND (p_sms_objs.COUNT > 0)) THEN
        l_current_cp_type := 'SMS';

        FOR i IN 1..p_sms_objs.COUNT LOOP
          HZ_CONTACT_POINT_BO_PUB.do_create_contact_point(
            p_init_msg_list                   => FND_API.G_FALSE,
            p_validate_bo_flag                => FND_API.G_FALSE,
            p_cp_id                           => p_sms_objs(i).sms_id,
            p_cp_os                           => p_sms_objs(i).orig_system,
            p_cp_osr                          => p_sms_objs(i).orig_system_reference,
            p_phone_obj                       => NULL,
            p_email_obj                       => NULL,
            p_telex_obj                       => NULL,
            p_web_obj                         => NULL,
            p_edi_obj                         => NULL,
            p_eft_obj                         => NULL,
            p_sms_obj                         => p_sms_objs(i),
            p_cp_pref_objs                    => p_sms_objs(i).contact_pref_objs,
            p_cp_type                         => l_current_cp_type,
            p_created_by_module               => HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE,
            p_obj_source                      => p_obj_source,
            x_return_status                   => x_return_status,
            x_msg_count                       => x_msg_count,
            x_msg_data                        => x_msg_data,
            x_cp_id                           => l_cp_id,
            x_cp_os                           => l_cp_os,
            x_cp_osr                          => l_cp_osr,
            px_parent_id                      => l_owner_table_id,
            px_parent_os                      => l_owner_table_os,
            px_parent_osr                     => l_owner_table_osr,
            px_parent_obj_type                => l_parent_obj_type
          );
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
              hz_utility_v2pub.debug(p_message=>'Create SMS - Error occurred at hz_contact_point_bo_pvt.save_contact_points: '||l_cp_id||' '||l_cp_os||' '||l_cp_osr||', owner table: '||l_owner_table_id||' '||l_owner_table_os||' '||l_owner_table_osr,
                                     p_prefix=>l_debug_prefix,
                                     p_msg_level=>fnd_log.level_procedure);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;
          p_sms_objs(i).sms_id := l_cp_id;
        END LOOP;
      END IF;
    ELSE
      -----------------------------
      -- Save phone contact point
      -----------------------------
      IF((p_phone_objs IS NOT NULL) AND (p_phone_objs.COUNT > 0)) THEN
        l_current_cp_type := 'PHONE';

        FOR i IN 1..p_phone_objs.COUNT LOOP
          HZ_CONTACT_POINT_BO_PUB.do_save_contact_point(
            p_init_msg_list                   => FND_API.G_FALSE,
            p_validate_bo_flag                => FND_API.G_FALSE,
            p_cp_id                           => p_phone_objs(i).phone_id,
            p_cp_os                           => p_phone_objs(i).orig_system,
            p_cp_osr                          => p_phone_objs(i).orig_system_reference,
            p_phone_obj                       => p_phone_objs(i),
            p_email_obj                       => NULL,
            p_telex_obj                       => NULL,
            p_web_obj                         => NULL,
            p_edi_obj                         => NULL,
            p_eft_obj                         => NULL,
            p_sms_obj                         => NULL,
            p_cp_pref_objs                    => p_phone_objs(i).contact_pref_objs,
            p_cp_type                         => l_current_cp_type,
            p_created_by_module               => HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE,
            p_obj_source                      => p_obj_source,
            x_return_status                   => x_return_status,
            x_msg_count                       => x_msg_count,
            x_msg_data                        => x_msg_data,
            x_cp_id                           => l_cp_id,
            x_cp_os                           => l_cp_os,
            x_cp_osr                          => l_cp_osr,
            px_parent_id                      => l_owner_table_id,
            px_parent_os                      => l_owner_table_os,
            px_parent_osr                     => l_owner_table_osr,
            px_parent_obj_type                => l_parent_obj_type
          );
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
              hz_utility_v2pub.debug(p_message=>'Save PHONE - Error occurred at hz_contact_point_bo_pvt.save_contact_points: '||l_cp_id||' '||l_cp_os||' '||l_cp_osr||', owner table: '||l_owner_table_id||' '||l_owner_table_os||' '||l_owner_table_osr,
                                     p_prefix=>l_debug_prefix,
                                     p_msg_level=>fnd_log.level_procedure);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;
          p_phone_objs(i).phone_id := l_cp_id;
        END LOOP;
      END IF;

      -----------------------------
      -- Save telex contact point
      -----------------------------
      IF((p_telex_objs IS NOT NULL) AND (p_telex_objs.COUNT > 0)) THEN
        l_current_cp_type := 'TLX';

        FOR i IN 1..p_telex_objs.COUNT LOOP
          HZ_CONTACT_POINT_BO_PUB.do_save_contact_point(
            p_init_msg_list                   => FND_API.G_FALSE,
            p_validate_bo_flag                => FND_API.G_FALSE,
            p_cp_id                           => p_telex_objs(i).telex_id,
            p_cp_os                           => p_telex_objs(i).orig_system,
            p_cp_osr                          => p_telex_objs(i).orig_system_reference,
            p_phone_obj                       => NULL,
            p_email_obj                       => NULL,
            p_telex_obj                       => p_telex_objs(i),
            p_web_obj                         => NULL,
            p_edi_obj                         => NULL,
            p_eft_obj                         => NULL,
            p_sms_obj                         => NULL,
            p_cp_pref_objs                    => p_telex_objs(i).contact_pref_objs,
            p_cp_type                         => l_current_cp_type,
            p_created_by_module               => HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE,
            p_obj_source                      => p_obj_source,
            x_return_status                   => x_return_status,
            x_msg_count                       => x_msg_count,
            x_msg_data                        => x_msg_data,
            x_cp_id                           => l_cp_id,
            x_cp_os                           => l_cp_os,
            x_cp_osr                          => l_cp_osr,
            px_parent_id                      => l_owner_table_id,
            px_parent_os                      => l_owner_table_os,
            px_parent_osr                     => l_owner_table_osr,
            px_parent_obj_type                => l_parent_obj_type
          );
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
              hz_utility_v2pub.debug(p_message=>'Save TLX - Error occurred at hz_contact_point_bo_pvt.save_contact_points: '||l_cp_id||' '||l_cp_os||' '||l_cp_osr||', owner table: '||l_owner_table_id||' '||l_owner_table_os||' '||l_owner_table_osr,
                                     p_prefix=>l_debug_prefix,
                                     p_msg_level=>fnd_log.level_procedure);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;
          p_telex_objs(i).telex_id := l_cp_id;
        END LOOP;
      END IF;

      -----------------------------
      -- Save email contact point
      -----------------------------
      IF((p_email_objs IS NOT NULL) AND (p_email_objs.COUNT > 0)) THEN
        l_current_cp_type := 'EMAIL';

        FOR i IN 1..p_email_objs.COUNT LOOP
          HZ_CONTACT_POINT_BO_PUB.do_save_contact_point(
            p_init_msg_list                   => FND_API.G_FALSE,
            p_validate_bo_flag                => FND_API.G_FALSE,
            p_cp_id                           => p_email_objs(i).email_id,
            p_cp_os                           => p_email_objs(i).orig_system,
            p_cp_osr                          => p_email_objs(i).orig_system_reference,
            p_phone_obj                       => NULL,
            p_email_obj                       => p_email_objs(i),
            p_telex_obj                       => NULL,
            p_web_obj                         => NULL,
            p_edi_obj                         => NULL,
            p_eft_obj                         => NULL,
            p_sms_obj                         => NULL,
            p_cp_pref_objs                    => p_email_objs(i).contact_pref_objs,
            p_cp_type                         => l_current_cp_type,
            p_created_by_module               => HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE,
            p_obj_source                      => p_obj_source,
            x_return_status                   => x_return_status,
            x_msg_count                       => x_msg_count,
            x_msg_data                        => x_msg_data,
            x_cp_id                           => l_cp_id,
            x_cp_os                           => l_cp_os,
            x_cp_osr                          => l_cp_osr,
            px_parent_id                      => l_owner_table_id,
            px_parent_os                      => l_owner_table_os,
            px_parent_osr                     => l_owner_table_osr,
            px_parent_obj_type                => l_parent_obj_type
          );
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
              hz_utility_v2pub.debug(p_message=>'Save EMAIL - Error occurred at hz_contact_point_bo_pvt.save_contact_points: '||l_cp_id||' '||l_cp_os||' '||l_cp_osr||', owner table: '||l_owner_table_id||' '||l_owner_table_os||' '||l_owner_table_osr,
                                     p_prefix=>l_debug_prefix,
                                     p_msg_level=>fnd_log.level_procedure);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;
          p_email_objs(i).email_id := l_cp_id;
        END LOOP;
      END IF;

      -----------------------------
      -- Save web contact point
      -----------------------------
      IF((p_web_objs IS NOT NULL) AND (p_web_objs.COUNT > 0)) THEN
        l_current_cp_type := 'WEB';

        FOR i IN 1..p_web_objs.COUNT LOOP
          HZ_CONTACT_POINT_BO_PUB.do_save_contact_point(
            p_init_msg_list                   => FND_API.G_FALSE,
            p_validate_bo_flag                => FND_API.G_FALSE,
            p_cp_id                           => p_web_objs(i).web_id,
            p_cp_os                           => p_web_objs(i).orig_system,
            p_cp_osr                          => p_web_objs(i).orig_system_reference,
            p_phone_obj                       => NULL,
            p_email_obj                       => NULL,
            p_telex_obj                       => NULL,
            p_web_obj                         => p_web_objs(i),
            p_edi_obj                         => NULL,
            p_eft_obj                         => NULL,
            p_sms_obj                         => NULL,
            p_cp_pref_objs                    => p_web_objs(i).contact_pref_objs,
            p_cp_type                         => l_current_cp_type,
            p_created_by_module               => HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE,
            p_obj_source                      => p_obj_source,
            x_return_status                   => x_return_status,
            x_msg_count                       => x_msg_count,
            x_msg_data                        => x_msg_data,
            x_cp_id                           => l_cp_id,
            x_cp_os                           => l_cp_os,
            x_cp_osr                          => l_cp_osr,
            px_parent_id                      => l_owner_table_id,
            px_parent_os                      => l_owner_table_os,
            px_parent_osr                     => l_owner_table_osr,
            px_parent_obj_type                => l_parent_obj_type
          );
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
              hz_utility_v2pub.debug(p_message=>'Save WEB - Error occurred at hz_contact_point_bo_pvt.save_contact_points: '||l_cp_id||' '||l_cp_os||' '||l_cp_osr||', owner table: '||l_owner_table_id||' '||l_owner_table_os||' '||l_owner_table_osr,
                                     p_prefix=>l_debug_prefix,
                                     p_msg_level=>fnd_log.level_procedure);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;
          p_web_objs(i).web_id := l_cp_id;
        END LOOP;
      END IF;

      -----------------------------
      -- Save edi contact point
      -----------------------------
      IF((p_edi_objs IS NOT NULL) AND (p_edi_objs.COUNT > 0)) THEN
        l_current_cp_type := 'EDI';

        FOR i IN 1..p_edi_objs.COUNT LOOP
          HZ_CONTACT_POINT_BO_PUB.do_save_contact_point(
            p_init_msg_list                   => FND_API.G_FALSE,
            p_validate_bo_flag                => FND_API.G_FALSE,
            p_cp_id                           => p_edi_objs(i).edi_id,
            p_cp_os                           => p_edi_objs(i).orig_system,
            p_cp_osr                          => p_edi_objs(i).orig_system_reference,
            p_phone_obj                       => NULL,
            p_email_obj                       => NULL,
            p_telex_obj                       => NULL,
            p_web_obj                         => NULL,
            p_edi_obj                         => p_edi_objs(i),
            p_eft_obj                         => NULL,
            p_sms_obj                         => NULL,
            p_cp_pref_objs                    => p_edi_objs(i).contact_pref_objs,
            p_cp_type                         => l_current_cp_type,
            p_created_by_module               => HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE,
            p_obj_source                      => p_obj_source,
            x_return_status                   => x_return_status,
            x_msg_count                       => x_msg_count,
            x_msg_data                        => x_msg_data,
            x_cp_id                           => l_cp_id,
            x_cp_os                           => l_cp_os,
            x_cp_osr                          => l_cp_osr,
            px_parent_id                      => l_owner_table_id,
            px_parent_os                      => l_owner_table_os,
            px_parent_osr                     => l_owner_table_osr,
            px_parent_obj_type                => l_parent_obj_type
          );
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
              hz_utility_v2pub.debug(p_message=>'Save EDI - Error occurred at hz_contact_point_bo_pvt.save_contact_points: '||l_cp_id||' '||l_cp_os||' '||l_cp_osr||', owner table: '||l_owner_table_id||' '||l_owner_table_os||' '||l_owner_table_osr,
                                     p_prefix=>l_debug_prefix,
                                     p_msg_level=>fnd_log.level_procedure);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;
          p_edi_objs(i).edi_id := l_cp_id;
        END LOOP;
      END IF;

      -----------------------------
      -- Save eft contact point
      -----------------------------
      IF((p_eft_objs IS NOT NULL) AND (p_eft_objs.COUNT > 0)) THEN
        l_current_cp_type := 'EFT';

        FOR i IN 1..p_eft_objs.COUNT LOOP
          HZ_CONTACT_POINT_BO_PUB.do_save_contact_point(
            p_init_msg_list                   => FND_API.G_FALSE,
            p_validate_bo_flag                => FND_API.G_FALSE,
            p_cp_id                           => p_eft_objs(i).eft_id,
            p_cp_os                           => p_eft_objs(i).orig_system,
            p_cp_osr                          => p_eft_objs(i).orig_system_reference,
            p_phone_obj                       => NULL,
            p_email_obj                       => NULL,
            p_telex_obj                       => NULL,
            p_web_obj                         => NULL,
            p_edi_obj                         => NULL,
            p_eft_obj                         => p_eft_objs(i),
            p_sms_obj                         => NULL,
            p_cp_pref_objs                    => p_eft_objs(i).contact_pref_objs,
            p_cp_type                         => l_current_cp_type,
            p_created_by_module               => HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE,
            p_obj_source                      => p_obj_source,
            x_return_status                   => x_return_status,
            x_msg_count                       => x_msg_count,
            x_msg_data                        => x_msg_data,
            x_cp_id                           => l_cp_id,
            x_cp_os                           => l_cp_os,
            x_cp_osr                          => l_cp_osr,
            px_parent_id                      => l_owner_table_id,
            px_parent_os                      => l_owner_table_os,
            px_parent_osr                     => l_owner_table_osr,
            px_parent_obj_type                => l_parent_obj_type
          );
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
              hz_utility_v2pub.debug(p_message=>'Save EFT - Error occurred at hz_contact_point_bo_pvt.save_contact_points: '||l_cp_id||' '||l_cp_os||' '||l_cp_osr||', owner table: '||l_owner_table_id||' '||l_owner_table_os||' '||l_owner_table_osr,
                                     p_prefix=>l_debug_prefix,
                                     p_msg_level=>fnd_log.level_procedure);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;
          p_eft_objs(i).eft_id := l_cp_id;
        END LOOP;
      END IF;

      -----------------------------
      -- Save sms contact point
      -----------------------------
      IF((p_sms_objs IS NOT NULL) AND (p_sms_objs.COUNT > 0)) THEN
        l_current_cp_type := 'SMS';

        FOR i IN 1..p_sms_objs.COUNT LOOP
          HZ_CONTACT_POINT_BO_PUB.do_save_contact_point(
            p_init_msg_list                   => FND_API.G_FALSE,
            p_validate_bo_flag                => FND_API.G_FALSE,
            p_cp_id                           => p_sms_objs(i).sms_id,
            p_cp_os                           => p_sms_objs(i).orig_system,
            p_cp_osr                          => p_sms_objs(i).orig_system_reference,
            p_phone_obj                       => NULL,
            p_email_obj                       => NULL,
            p_telex_obj                       => NULL,
            p_web_obj                         => NULL,
            p_edi_obj                         => NULL,
            p_eft_obj                         => NULL,
            p_sms_obj                         => p_sms_objs(i),
            p_cp_pref_objs                    => p_sms_objs(i).contact_pref_objs,
            p_cp_type                         => l_current_cp_type,
            p_created_by_module               => HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE,
            p_obj_source                      => p_obj_source,
            x_return_status                   => x_return_status,
            x_msg_count                       => x_msg_count,
            x_msg_data                        => x_msg_data,
            x_cp_id                           => l_cp_id,
            x_cp_os                           => l_cp_os,
            x_cp_osr                          => l_cp_osr,
            px_parent_id                      => l_owner_table_id,
            px_parent_os                      => l_owner_table_os,
            px_parent_osr                     => l_owner_table_osr,
            px_parent_obj_type                => l_parent_obj_type
          );
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
              hz_utility_v2pub.debug(p_message=>'Save SMS - Error occurred at hz_contact_point_bo_pvt.save_contact_points: '||l_cp_id||' '||l_cp_os||' '||l_cp_osr||', owner table: '||l_owner_table_id||' '||l_owner_table_os||' '||l_owner_table_osr,
                                     p_prefix=>l_debug_prefix,
                                     p_msg_level=>fnd_log.level_procedure);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;
          p_sms_objs(i).sms_id := l_cp_id;
        END LOOP;
      END IF;
    END IF;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_contact_points(-)',
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
        hz_utility_v2pub.debug(p_message=>'save_contact_points(-)',
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
        hz_utility_v2pub.debug(p_message=>'save_contact_points(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR', SQLERRM);
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
        hz_utility_v2pub.debug(p_message=>'save_contact_points(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END save_contact_points;

END hz_contact_point_bo_pvt;

/
