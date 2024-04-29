--------------------------------------------------------
--  DDL for Package Body AMW_ASSOC_POST_TXN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_ASSOC_POST_TXN" AS
/* $Header: amwpastb.pls 115.1 2004/02/10 03:48:15 abedajna noship $ */

   g_pkg_name    CONSTANT VARCHAR2 (30) := 'AMW_ASSOC_POST_TXN';
   g_file_name   CONSTANT VARCHAR2 (12) := 'amwpastb.pls';
   g_user_id              NUMBER        := fnd_global.user_id;
   g_login_id             NUMBER        := fnd_global.conc_login_id;

-- for RISK_ORG and CONTROL_ORG, pass at least p_process_organization_id.
-- for library contexts, you do not need to pass anything.
   PROCEDURE assoc_post_txn (
      p_process_id                IN              NUMBER := NULL,
      p_risk_id                   IN              NUMBER := NULL,
      p_control_id                IN              NUMBER := NULL,
      p_process_organization_id   IN              NUMBER := NULL,
      p_association_mode          IN              VARCHAR2 := 'ASSOCIATE',
      p_object                    IN              VARCHAR2 := 'RISK',
      p_commit                    IN              VARCHAR2 := fnd_api.g_false,
      p_validation_level          IN              NUMBER   := fnd_api.g_valid_level_full,
      p_init_msg_list             IN              VARCHAR2 := fnd_api.g_false,
      p_api_version_number        IN              NUMBER,
      x_return_status             OUT NOCOPY      VARCHAR2,
      x_msg_count                 OUT NOCOPY      NUMBER,
      x_msg_data                  OUT NOCOPY      VARCHAR2 ) IS

      l_api_name             CONSTANT VARCHAR2 (30) := 'assoc_post_txn';
      l_api_version_number   CONSTANT NUMBER        := 1.0;
      x_process_organization_id       NUMBER        := 0;
      l_process_id                    NUMBER;
      l_org_id			      NUMBER;

-- abb added
      l_process_id2                    NUMBER;
      l_org_id2			      NUMBER;
      l_risk_assoc_id           number;
-- abb added

     cursor cc5 IS
     SELECT control_association_id ,control_id from amw_control_associations
            where object_type='RISK_ORG'
            and pk1 In (
            select risk_association_id
            from amw_risk_associations
            where object_type='PROCESS_ORG' and pk1= p_process_organization_id
            and risk_id = p_risk_id );

     delete_ctrl_org                    cc5 %ROWTYPE;


   BEGIN
      SAVEPOINT get_process_hierarchy_pvt;
      x_return_status            := fnd_api.g_ret_sts_success;
      IF NOT fnd_api.compatible_api_call (l_api_version_number,
                                          p_api_version_number,
                                          l_api_name,
                                          g_pkg_name
                                         ) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;
      -- Debug Message
      amw_utility_pvt.debug_message ('Private API: ' || l_api_name || 'start');
      -- Initialize API return status to SUCCESS
      x_return_status            := fnd_api.g_ret_sts_success;

      IF fnd_global.user_id IS NULL THEN
         amw_utility_pvt.error_message(p_message_name => 'USER_PROFILE_MISSING');
         RAISE fnd_api.g_exc_error;
      END IF;

      IF ( (p_object = 'RISK_ORG') OR (p_object = 'CONTROL_ORG') ) THEN
		select organization_id
		into l_org_id
		from amw_process_organization
		where process_organization_id = p_process_organization_id;
      END IF;

-- abb added
      IF (p_association_mode = 'ASSOCIATE') THEN
          IF (p_object = 'RISK_ORG') THEN

			select risk_association_id into l_risk_assoc_id from amw_risk_associations where risk_id = p_risk_id and pk1 = p_process_organization_id and object_type = 'PROCESS_ORG';

			insert into amw_control_associations
			(CONTROL_ASSOCIATION_ID,
			 LAST_UPDATE_DATE,
			 LAST_UPDATED_BY,
			 CREATION_DATE,
			 CREATED_BY,
			 LAST_UPDATE_LOGIN,
			 CONTROL_ID,
			 PK1,
			 OBJECT_TYPE,
			 ATTRIBUTE_CATEGORY,
			 ATTRIBUTE1,
			 ATTRIBUTE2,
			 ATTRIBUTE3,
			 ATTRIBUTE4,
			 ATTRIBUTE5,
			 ATTRIBUTE6,
			 ATTRIBUTE7,
			 ATTRIBUTE8,
			 ATTRIBUTE9,
			 ATTRIBUTE10,
			 ATTRIBUTE11,
			 ATTRIBUTE12,
			 ATTRIBUTE13,
			 ATTRIBUTE14,
			 ATTRIBUTE15,
			 OBJECT_VERSION_NUMBER,
			 EFFECTIVE_DATE_FROM,
			 EFFECTIVE_DATE_TO )
			( select
			amw_control_associations_s.nextval,
			sysdate,
			FND_GLOBAL.USER_ID,
			sysdate,
			FND_GLOBAL.USER_ID,
			FND_GLOBAL.CONC_LOGIN_ID,
			control_id,
			l_risk_assoc_id,
			'RISK_ORG',
			ATTRIBUTE_CATEGORY,
			ATTRIBUTE1,
			ATTRIBUTE2,
			ATTRIBUTE3,
			ATTRIBUTE4,
			ATTRIBUTE5,
			ATTRIBUTE6,
			ATTRIBUTE7,
			ATTRIBUTE8,
			ATTRIBUTE9,
			ATTRIBUTE10,
			ATTRIBUTE11,
			ATTRIBUTE12,
			ATTRIBUTE13,
			ATTRIBUTE14,
			ATTRIBUTE15,
			1,
        		 EFFECTIVE_DATE_FROM,
			 EFFECTIVE_DATE_TO
			from amw_control_associations
			where object_type = 'RISK'
			and pk1 = p_risk_id);

			SELECT  organization_id into l_org_id2 from amw_process_organization where process_organization_id = p_process_organization_id;
			SELECT  process_id into l_process_id2 from amw_process_organization where process_organization_id = p_process_organization_id;

			insert into amw_ap_associations
			(AP_ASSOCIATION_ID,
			 LAST_UPDATE_DATE,
			 LAST_UPDATED_BY,
			 CREATION_DATE,
			 CREATED_BY,
			 LAST_UPDATE_LOGIN,
			 PK1,
			 PK2,
			 PK3,
			 OBJECT_TYPE,
			 AUDIT_PROCEDURE_ID,
			 ATTRIBUTE_CATEGORY,
			 ATTRIBUTE1,
			 ATTRIBUTE2,
			 ATTRIBUTE3,
			 ATTRIBUTE4,
			 ATTRIBUTE5,
			 ATTRIBUTE6,
			 ATTRIBUTE7,
			 ATTRIBUTE8,
			 ATTRIBUTE9,
			 ATTRIBUTE10,
			 ATTRIBUTE11,
			 ATTRIBUTE12,
			 ATTRIBUTE13,
			 ATTRIBUTE14,
			 ATTRIBUTE15,
			 OBJECT_VERSION_NUMBER,
			 DESIGN_EFFECTIVENESS,
			 OP_EFFECTIVENESS )
			( select
			amw_ap_associations_s.nextval,
			sysdate,
			FND_GLOBAL.USER_ID,
			sysdate,
			FND_GLOBAL.USER_ID,
			FND_GLOBAL.CONC_LOGIN_ID,
			l_org_id,
			l_process_id2,
			pk1,
			'CTRL_ORG',
			AUDIT_PROCEDURE_ID,
			ATTRIBUTE_CATEGORY,
			ATTRIBUTE1,
			ATTRIBUTE2,
			ATTRIBUTE3,
			ATTRIBUTE4,
			ATTRIBUTE5,
			ATTRIBUTE6,
			ATTRIBUTE7,
			ATTRIBUTE8,
			ATTRIBUTE9,
			ATTRIBUTE10,
			ATTRIBUTE11,
			ATTRIBUTE12,
			ATTRIBUTE13,
			ATTRIBUTE14,
			ATTRIBUTE15,
			1,
			DESIGN_EFFECTIVENESS,
			OP_EFFECTIVENESS
			from amw_ap_associations
			where object_type = 'CTRL'
			and pk1 in (select control_id from amw_control_associations
					where object_type = 'RISK'
					and pk1 = p_risk_id));

          ELSIF (p_object = 'CONTROL_ORG') THEN

			SELECT  organization_id into l_org_id2 from amw_process_organization where process_organization_id = p_process_organization_id;
			SELECT  process_id into l_process_id2 from amw_process_organization where process_organization_id = p_process_organization_id;

			insert into amw_ap_associations
			(AP_ASSOCIATION_ID,
			 LAST_UPDATE_DATE,
			 LAST_UPDATED_BY,
			 CREATION_DATE,
			 CREATED_BY,
			 LAST_UPDATE_LOGIN,
			 PK1,
			 PK2,
			 PK3,
			 OBJECT_TYPE,
			 AUDIT_PROCEDURE_ID,
			 ATTRIBUTE_CATEGORY,
			 ATTRIBUTE1,
			 ATTRIBUTE2,
			 ATTRIBUTE3,
			 ATTRIBUTE4,
			 ATTRIBUTE5,
			 ATTRIBUTE6,
			 ATTRIBUTE7,
			 ATTRIBUTE8,
			 ATTRIBUTE9,
			 ATTRIBUTE10,
			 ATTRIBUTE11,
			 ATTRIBUTE12,
			 ATTRIBUTE13,
			 ATTRIBUTE14,
			 ATTRIBUTE15,
			 OBJECT_VERSION_NUMBER,
			 DESIGN_EFFECTIVENESS,
			 OP_EFFECTIVENESS )
			( select
			amw_ap_associations_s.nextval,
			sysdate,
			FND_GLOBAL.USER_ID,
			sysdate,
			FND_GLOBAL.USER_ID,
			FND_GLOBAL.CONC_LOGIN_ID,
			l_org_id,
			l_process_id2,
			p_control_id,
			'CTRL_ORG',
			AUDIT_PROCEDURE_ID,
			ATTRIBUTE_CATEGORY,
			ATTRIBUTE1,
			ATTRIBUTE2,
			ATTRIBUTE3,
			ATTRIBUTE4,
			ATTRIBUTE5,
			ATTRIBUTE6,
			ATTRIBUTE7,
			ATTRIBUTE8,
			ATTRIBUTE9,
			ATTRIBUTE10,
			ATTRIBUTE11,
			ATTRIBUTE12,
			ATTRIBUTE13,
			ATTRIBUTE14,
			ATTRIBUTE15,
			1,
			DESIGN_EFFECTIVENESS,
			OP_EFFECTIVENESS
			from amw_ap_associations
			where object_type = 'CTRL'
			and pk1 = p_control_id);

          END IF;
      END IF;

-- abb added


      IF (p_association_mode = 'ASSOCIATE') THEN
          IF ( (p_object = 'RISK') OR (p_object = 'CONTROL') ) THEN
		AMW_WF_HIERARCHY_PKG.reset_process_risk_ctrl_count;
          ELSIF ( (p_object = 'RISK_ORG') OR (p_object = 'CONTROL_ORG') ) THEN
		AMW_WF_HIERARCHY_PKG.reset_proc_org_risk_ctrl_count(l_org_id);
          END IF;

       ELSIF (p_association_mode = 'DISASSOCIATE') THEN
          IF ( (p_object = 'RISK') OR (p_object = 'CONTROL') )THEN
		AMW_WF_HIERARCHY_PKG.reset_process_risk_ctrl_count;
          ELSIF (p_object = 'RISK_ORG') THEN
                OPEN cc5;
                LOOP
                  FETCH cc5            INTO delete_ctrl_org;
                   EXIT WHEN cc5%NOTFOUND;

                   -- added  mpande 11/14/2003
                   delete   from amw_ap_associations
                   where object_type='CTRL_ORG'
                   and pk1  = ( SELECT  organization_id from amw_process_organization
                   where process_organization_id = p_process_organization_id )
                   and pk2  = ( SELECT  process_id from amw_process_organization
                   where process_organization_id = p_process_organization_id )
                   AND pk3 = delete_ctrl_org.control_id
                   and
                   not exists ( select control_id from amw_control_associations aca, amw_risk_associations ara
                                where aca.pk1= ara.risk_association_id
                                and ara.object_type = 'PROCESS_ORG'
                                and aca.object_type = 'RISK_ORG'
                                and control_id = delete_ctrl_org.control_id  ) ;

                   delete   from amw_control_associations
                   where control_association_id = delete_ctrl_org.control_association_id ;
                 END LOOP ;
                 CLOSE cc5 ;
		AMW_WF_HIERARCHY_PKG.reset_proc_org_risk_ctrl_count(l_org_id);
         ELSIF (p_object = 'CONTROL_ORG') THEN
                -- added  mpande 11/14/2003
                delete   from amw_ap_associations
                where object_type='CTRL_ORG'
                and pk1  = ( SELECT  organization_id from amw_process_organization
                where process_organization_id = p_process_organization_id )
                and pk2  = ( SELECT  process_id from amw_process_organization
                where process_organization_id = p_process_organization_id )
                AND pk3 = p_control_id
                and
                not exists ( select control_id from amw_control_associations aca, amw_risk_associations ara
                             where aca.pk1= ara.risk_association_id
                             and ara.object_type = 'PROCESS_ORG'
                             and aca.object_type = 'RISK_ORG'
                             and control_id = p_control_id  );
		AMW_WF_HIERARCHY_PKG.reset_proc_org_risk_ctrl_count(l_org_id);

         END IF;
      END IF;


      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;
      -- Standard check for p_commit
      IF fnd_api.to_boolean (p_commit) THEN
         COMMIT WORK;
      END IF;
      --Debug Message
      amw_utility_pvt.debug_message ('Private API: ' || l_api_name || 'end');
      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO get_process_hierarchy_pvt;
         x_return_status            := fnd_api.g_ret_sts_error;
         -- Standard call to get message count and if count=1, get the message
         fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO get_process_hierarchy_pvt;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         -- Standard call to get message count and if count=1, get the message
         fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
      WHEN OTHERS THEN
         ROLLBACK TO get_process_hierarchy_pvt;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
         -- Standard call to get message count and if count=1, get the message
         fnd_msg_pub.count_and_get (p_encoded      => fnd_api.g_false,
                                    p_count        => x_msg_count,
                                    p_data         => x_msg_data
                                   );
   END assoc_post_txn;
END AMW_ASSOC_POST_TXN;

/
