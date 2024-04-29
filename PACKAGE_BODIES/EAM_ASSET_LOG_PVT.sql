--------------------------------------------------------
--  DDL for Package Body EAM_ASSET_LOG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ASSET_LOG_PVT" AS
/* $Header: EAMVALGB.pls 120.24 2006/09/12 06:37:40 sshahid noship $ */

             g_pkg_name                          CONSTANT    varchar2(30) := 'EAM_ASSET_LOG_PVT';

PROCEDURE insert_row(
             p_log_id                            IN   number        := NULL,
             p_api_version                       IN   number	    := 1.0,
             p_init_msg_list                     IN   varchar2      := fnd_api.g_false,
             p_commit                            IN   varchar2      := fnd_api.g_false,
             p_validation_level                  IN   number        := fnd_api.g_valid_level_full,
             p_event_date                        IN   date          := sysdate,
             p_event_type                        IN   varchar2      := NULL,
             p_event_id                          IN   number        := NULL,
             p_organization_id                   IN   number        := NULL,
             p_instance_id                       IN   number,
             p_comments                          IN   varchar2      := NULL,
             p_reference                         IN   varchar2      := NULL,
             p_ref_id                            IN   number        := NULL,
             p_operable_flag                     IN   number        := NULL,
             p_reason_code                       IN   number        := NULL,
             p_resource_id                       IN   number        := NULL,
             p_equipment_gen_object_id           IN   number        := NULL,
             p_source_log_id                     IN   number        := NULL,
             p_instance_number                   IN   varchar2      := NULL,
             p_downcode                          IN   number        := NULL,
             p_expected_up_date                  IN   date          := NULL,
             p_employee_id                       IN   number        := NULL,
             p_department_id                     IN   number        := NULL,
             p_attribute_category                IN   varchar2      := NULL,
             p_attribute1                        IN   varchar2      := NULL,
             p_attribute2                        IN   varchar2      := NULL,
             p_attribute3                        IN   varchar2      := NULL,
             p_attribute4                        IN   varchar2      := NULL,
             p_attribute5                        IN   varchar2      := NULL,
             p_attribute6                        IN   varchar2      := NULL,
             p_attribute7                        IN   varchar2      := NULL,
             p_attribute8                        IN   varchar2      := NULL,
             p_attribute9                        IN   varchar2      := NULL,
             p_attribute10                       IN   varchar2      := NULL,
             p_attribute11                       IN   varchar2      := NULL,
             p_attribute12                       IN   varchar2      := NULL,
             p_attribute13                       IN   varchar2      := NULL,
             p_attribute14                       IN   varchar2      := NULL,
             p_attribute15                       IN   varchar2      := NULL,
             x_return_status             OUT NOCOPY   varchar2,
             x_msg_count                 OUT NOCOPY   number,
             x_msg_data                  OUT NOCOPY   varchar2)


   IS
             l_api_name                    CONSTANT   varchar2(30)  := 'insert_row';
             l_api_version                 CONSTANT   number        := 1.0;
             l_full_name                   CONSTANT   varchar2(60)  := g_pkg_name || '.' || l_api_name;
             l_instance_id                            number;
             l_instance_number                        varchar2(30);
             l_log_id                                 number;
             l_organization_id                        number;
             l_status                                 varchar2(1);
             l_var2                                   number;

   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT EAM_ASSET_LOG_PVT_SV;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call(
            l_api_version
           ,p_api_version
           ,l_api_name
           ,g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;

    -- VALIDATION Loggable Asset for System Events
    IF p_event_type='EAM_SYSTEM_EVENTS' THEN
      BEGIN
		SELECT	mp.maint_organization_id, cii.operational_log_flag
		  INTO l_organization_id, l_status
		  FROM	mtl_parameters mp, csi_item_instances cii
		 WHERE	mp.organization_id = cii.last_vld_organization_id
		   AND  cii.instance_id = p_instance_id;

                 IF (l_status = 'N' or l_status is NULL) THEN
             	       RETURN;
	         END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
                fnd_message.set_name
                                (  application  => 'EAM'
                                 , name         => 'EAM_INSTANCE_ID_INVALID'
                                );

                fnd_msg_pub.add;
                x_return_status:= fnd_api.g_ret_sts_error;
                fnd_msg_pub.Count_And_Get
                                (  p_count      =>  x_msg_count,
                                   p_data       =>  x_msg_data
                                );
        RETURN;
      END;

      BEGIN
		SELECT event_id INTO l_var2 FROM eam_control_event
		 WHERE event_type = p_event_type
		   AND event_id= p_event_id
		   AND organization_id=l_organization_id;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
           RETURN;
      END;

    END IF;

          EAM_ASSET_LOG_PVT.validate_event(
                        p_event_date                 =>     p_event_date,
                        p_event_type                 =>     p_event_type,
                        p_event_id                   =>     p_event_id,
                        p_instance_id                =>     p_instance_id,
                        p_instance_number            =>     p_instance_number,
                        p_operable_flag              =>     p_operable_flag,
                        p_reason_code                =>     p_reason_code,
                        p_resource_id                =>     p_resource_id,
                        p_downcode                   =>     p_downcode,
                        p_expected_up_date           =>     p_expected_up_date,
                        p_equipment_gen_object_id    =>     p_equipment_gen_object_id,
                        x_return_status              =>     x_return_status,
                        x_msg_count                  =>     x_msg_count,
                        x_msg_data                   =>     x_msg_data);

        IF x_return_status = fnd_api.g_ret_sts_success THEN

                IF (p_log_id IS NULL) THEN
		  SELECT eam_asset_log_s.nextval INTO l_log_id FROM dual;
                ELSE
                    l_log_id:=p_log_id;
                END IF;

                INSERT
                INTO eam_asset_log
                    (
                        log_id,
                        event_date,
                        event_type,
                        event_id,
                        organization_id,
                        instance_id,
                        reference,
                        ref_id,
                        operable,
                        reason_code,
                        resource_id,
                        comments,
                        down_code,
                        resource_serial_number,
                        expected_up_date,
                        source_log_id,
                        employee_id,
                        department_id,
                        equipment_gen_object_id,
                        attribute_category,
                        attribute1,
                        attribute2,
                        attribute3,
                        attribute4,
                        attribute5,
                        attribute6,
                        attribute7,
                        attribute8,
                        attribute9,
                        attribute10,
                        attribute11,
                        attribute12,
                        attribute13,
                        attribute14,
                        attribute15,
                        created_by,
                        creation_date,
                        last_updated_by,
                        last_update_date,
                        last_update_login
                    )
                    VALUES
                    (
                        l_log_id,
                        p_event_date,
                        p_event_type,
                        p_event_id,
                        p_organization_id,
                        p_instance_id,
                        p_reference,
                        p_ref_id,
                        p_operable_flag,
                        p_reason_code,
                        p_resource_id,
                        p_comments,
                        p_downcode,
                        p_instance_number,
                        p_expected_up_date,
                        p_source_log_id,
                        p_employee_id,
                        p_department_id,
                        p_equipment_gen_object_id,
                        p_attribute_category,
                        p_attribute1,
                        p_attribute2,
                        p_attribute3,
                        p_attribute4,
                        p_attribute5,
                        p_attribute6,
                        p_attribute7,
                        p_attribute8,
                        p_attribute9,
                        p_attribute10,
                        p_attribute11,
                        p_attribute12,
                        p_attribute13,
                        p_attribute14,
                        p_attribute15,
                        fnd_global.user_id,
                        sysdate,
                        fnd_global.user_id,
                        sysdate,
                        fnd_global.login_id
                    )
                    ;

         END IF;

      -- End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;
      fnd_msg_pub.count_and_get(
         p_count => x_msg_count
        ,p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO EAM_ASSET_LOG_PVT_SV;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO EAM_ASSET_LOG_PVT_SV;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO EAM_ASSET_LOG_PVT_SV;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(
               fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data => x_msg_data);

END insert_row;

PROCEDURE validate_event(
             p_api_version                       IN   number    := 1.0,
             p_init_msg_list                     IN   varchar2  := fnd_api.g_false,
             p_commit                            IN   varchar2  := fnd_api.g_false,
             p_validation_level                  IN   number    := fnd_api.g_valid_level_full,
             p_event_date                        IN   date      := sysdate,
             p_event_type                        IN   varchar2  := NULL,
             p_event_id                          IN   number    := NULL,
             p_instance_id                       IN   number    := NULL,
             p_instance_number                   IN   varchar2  := NULL,
             p_operable_flag                     IN   number    := NULL,
             p_reason_code                       IN   number    := NULL,
             p_resource_id                       IN   number    := NULL,
             p_equipment_gen_object_id           IN   number    := NULL,
             p_downcode                          IN   number    := NULL,
             p_expected_up_date                  IN   date      := NULL,
             x_return_status             OUT NOCOPY   varchar2,
             x_msg_count                 OUT NOCOPY   number,
             x_msg_data                  OUT NOCOPY   varchar2)
IS
            l_api_name                    CONSTANT    varchar2(30) := 'validate_event';
            l_api_version                 CONSTANT    number       := 1.0;
            l_full_name                   CONSTANT    varchar2(60) := g_pkg_name || '.' || l_api_name;
            l_status                                  number;
            l_organization_id                         number;
            l_dummy                                   number;

   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT EAM_ASSET_LOG_PVT_SV;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call(
            l_api_version
           ,p_api_version
           ,l_api_name
           ,g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

         x_return_status := fnd_api.g_ret_sts_success;

        -- VALIDATION 1 Event Type

        IF (p_event_type IS NULL OR p_event_type NOT IN ('EAM_USER_EVENTS','EAM_OPERATIONAL_EVENTS'
							 , 'EAM_SYSTEM_EVENTS')) THEN
                fnd_message.set_name
                                (  application  => 'EAM'
                                 , name         => 'EAM_EVENT_TYPE_INVALID'
                                );
                fnd_msg_pub.add;
                x_return_status:= fnd_api.g_ret_sts_error;
                fnd_msg_pub.Count_And_Get
                                (  p_count      =>  x_msg_count,
                                   p_data       =>  x_msg_data
                                );

                RETURN;
        END IF;

        -- VALIDATION 2 Event Date
	IF   (p_event_type <> 'EAM_SYSTEM_EVENTS') THEN
		IF   (p_event_date IS NULL OR p_event_date > sysdate) THEN
			fnd_message.set_name
					(  application  => 'EAM'
					 , name         => 'EAM_EVENT_DATE_INVALID'
					 );

			fnd_msg_pub.add;
			x_return_status:= fnd_api.g_ret_sts_error;
			fnd_msg_pub.Count_And_Get
					(  p_count      =>  x_msg_count,
					   p_data       =>  x_msg_data
					);
			return;
		END IF;
	END IF;

        -- VALIDATION 3 Event Id
	BEGIN

                SELECT  lookup_code INTO l_status FROM  mfg_lookups
                 WHERE  lookup_type  = p_event_type AND
                        lookup_code  = p_event_id AND
                        enabled_flag = 'Y' AND
                        p_event_date >= NVL(start_date_active, p_event_date) AND
                        p_event_date <= NVL(end_date_active,sysdate);

	EXCEPTION
	      WHEN NO_DATA_FOUND THEN
                fnd_message.set_name
                                (  application  => 'EAM'
                                 , name         => 'EAM_EVENT_ID_INVALID'
                                );

                fnd_msg_pub.add;
                x_return_status:= fnd_api.g_ret_sts_error;
                fnd_msg_pub.Count_And_Get
                                (  p_count      =>  x_msg_count,
                                   p_data       =>  x_msg_data
                                );
                RETURN;
        END;

        -- VALIDATION 4 Instance Id

        IF  p_instance_id IS NOT NULL THEN
         BEGIN
		SELECT  instance_id INTO l_status FROM  csi_item_instances
		 WHERE  instance_id  =  p_instance_id;

	 EXCEPTION
	      WHEN NO_DATA_FOUND THEN
                fnd_message.set_name
                                (  application  => 'EAM'
                                 , name         => 'EAM_INSTANCE_ID_INVALID'
                                );

                fnd_msg_pub.add;
                x_return_status:= fnd_api.g_ret_sts_error;
                fnd_msg_pub.Count_And_Get
                                (  p_count      =>  x_msg_count,
                                   p_data       =>  x_msg_data
                                );
                RETURN;
         END;

       END IF;

     -- VALIDATION 5 Operable Flag

    IF  p_operable_flag IS NOT NULL  THEN
 	BEGIN
               SELECT lookup_code INTO l_status FROM  mfg_lookups
                WHERE lookup_type  = 'SYS_YES_NO' AND
                      enabled_flag = 'Y' AND
                      p_event_date >= NVL(start_date_active, p_event_date) AND
                      p_event_date <= NVL(end_date_active,sysdate) AND
                      lookup_code  =  p_operable_flag;

	EXCEPTION
	      WHEN NO_DATA_FOUND THEN
                fnd_message.set_name
                                (  application  => 'EAM'
                                 , name         => 'EAM_OPERABLE_INVALID'
                                );

                fnd_msg_pub.add;
                x_return_status:= fnd_api.g_ret_sts_error;
                fnd_msg_pub.Count_And_Get
                                (  p_count      =>  x_msg_count,
                                   p_data       =>  x_msg_data
                                );
                RETURN;
        END;
     END IF;

         -- VALIDATION 6 Reason Code

     IF p_reason_code IS NOT NULL THEN
	BEGIN
		SELECT  lookup_code INTO l_status FROM mfg_lookups
		 WHERE  lookup_type  = 'EAM_LOG_REASON_CODE' AND
			enabled_flag = 'Y' AND
			p_event_date >= NVL(start_date_active,p_event_date) AND
			p_event_date <= NVL(end_date_active,sysdate) AND
			lookup_code  =  p_reason_code;

	EXCEPTION
	      WHEN NO_DATA_FOUND THEN
                        fnd_message.set_name
                                (  application  => 'EAM'
                                 , name         => 'EAM_RET_MAT_INVALID_REASON'
                                );

                        fnd_msg_pub.add;
                        x_return_status:= fnd_api.g_ret_sts_error;
                fnd_msg_pub.Count_And_Get
                                (  p_count      =>  x_msg_count,
                                   p_data       =>  x_msg_data
                                );
                        RETURN;
        END;
     END IF;

	 -- VALIDATION 7 Operational Event Lookups

     IF p_event_type='EAM_OPERATIONAL_EVENTS' THEN

	 -- VALIDATION for resourceid

	IF p_resource_id is not null THEN

		 BEGIN
			SELECT  resource_id INTO l_status FROM bom_resources_v
			 WHERE  resource_id = p_resource_id;
		 EXCEPTION
		      WHEN NO_DATA_FOUND THEN
			       fnd_message.set_name
					(  application  => 'EAM'
					 , name         => 'EAM_RI_INSTANCE_INVALID'
					);
				fnd_msg_pub.add;
				x_return_status:= fnd_api.g_ret_sts_error;
			fnd_msg_pub.Count_And_Get
					(  p_count      =>  x_msg_count,
					   p_data       =>  x_msg_data
					);
				RETURN;
		 END;

	END IF;
/* Relaxing this validation to avoid patch failure due to dependancy #4522204
	IF p_downcode IS NOT NULL THEN

		BEGIN
		      SELECT  downcode INTO l_status FROM  bom_resource_downcodes
		       WHERE  downcode    =  p_downcode AND
			      resource_id =  p_resource_id ;
		EXCEPTION
		      WHEN NO_DATA_FOUND THEN
			fnd_message.set_name
					(  application  => 'EAM'
					 , name         => 'EAM_DOWNCODE_INVALID'
					);

			fnd_msg_pub.add;
			x_return_status:= fnd_api.g_ret_sts_error;
			fnd_msg_pub.Count_And_Get
					(  p_count      =>  x_msg_count,
					   p_data       =>  x_msg_data
					);
			RETURN;
		END;

	END IF;
*/
    END IF;

   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO EAM_ASSET_LOG_PVT_SV;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO EAM_ASSET_LOG_PVT_SV;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO EAM_ASSET_LOG_PVT_SV;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level(
            fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data => x_msg_data);

END validate_event;

-- Procedure to Purge Log Transactions
PROCEDURE delete_row(
             errbuf                        OUT NOCOPY   varchar2,
             retcode                       OUT NOCOPY   number,
             p_start_date                          IN   varchar2,
             p_end_date                            IN   varchar2,
             p_asset_group                         IN   number,
	     p_instance_id                         IN   number,
             p_event_type                          IN   varchar2,
             p_event_id                            IN   number,
             p_resource_id                         IN   number,
	     p_organization_id                     IN   number,
             p_equipment_gen_object_id             IN   number
	     )
   IS
	     l_statement				varchar2(2000);
	     l_start_date                               date      := fnd_date.canonical_to_date(p_start_date);
	     l_end_date                                 date      := fnd_date.canonical_to_date(p_end_date);
	     l_organization_id                          number;
   BEGIN
        retcode:=0;

      -- Standard Start of API savepoint
      SAVEPOINT EAM_ASSET_LOG_PVT_SV;

	begin
		select nvl(maint_organization_id, p_organization_id)  into l_organization_id
		  from mtl_parameters
		 where organization_id = p_organization_id;
	exception
	      WHEN NO_DATA_FOUND THEN

	      RETURN;
	end;

	l_statement := 'DELETE FROM  eam_asset_log eal WHERE eal.organization_id = :1';

	IF p_start_date is not null then
		l_statement :=  l_statement || ' AND eal.event_date >= '||''''||l_start_date||'''' ;
	END IF;

	IF p_end_date is not null then
		l_statement :=  l_statement || ' AND eal.event_date <= '||''''||l_end_date||'''' ;
	END IF;

	IF p_asset_group is not null then

		if p_instance_id is not null then
			l_statement :=  l_statement || ' AND instance_id = '||p_instance_id;
		else
		        l_statement :=  l_statement || ' AND EXISTS (SELECT cii.instance_id FROM csi_item_instances cii WHERE cii.inventory_item_id = '||p_asset_group||' AND cii.instance_id = eal.instance_id)';
		end if;
	else
		if p_instance_id is not null then
			l_statement :=  l_statement || ' AND instance_id = '||p_instance_id ;
		end if;
	end if;

	IF p_event_type is not null then
		l_statement :=  l_statement || ' AND event_type = '||''''||p_event_type||'''' ;
	END IF;

	IF p_event_id is not null then
		l_statement :=  l_statement || ' AND event_id = '||p_event_id;
	END IF;

	IF p_resource_id is not null then
		l_statement :=  l_statement || ' AND eal.resource_id = '||p_resource_id ;
	end if;

	IF p_equipment_gen_object_id is not null then
		l_statement :=  l_statement ||  ' AND eal.equipment_gen_object_id = '||p_equipment_gen_object_id ;
	end if;

	EXECUTE IMMEDIATE l_statement USING l_organization_id;

	COMMIT;

   EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
		 ROLLBACK TO EAM_ASSET_LOG_PVT_SV;
		 fnd_message.set_name('EAM','EAM_PURGE_EVENT_LOG_FAILURE');
		 errbuf  := fnd_message.get();
		 retcode := 2;
		 fnd_file.put_line(FND_FILE.LOG, fnd_message.get);
         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO EAM_ASSET_LOG_PVT_SV;
		 fnd_message.set_name('EAM','EAM_PURGE_EVENT_LOG_FAILURE');
		 errbuf  := fnd_message.get();
		 retcode := 2;
		 fnd_file.put_line(FND_FILE.LOG, fnd_message.get);
	 WHEN OTHERS THEN
		 ROLLBACK TO EAM_ASSET_LOG_PVT_SV;
		 retcode := 2;
		 fnd_file.put_line(FND_FILE.LOG, SQLERRM);

END delete_row;

-- Procedure to Insert Log for Inventory Transactions
PROCEDURE instance_update_event(
             p_api_version                       IN   number        := 1.0,
             p_init_msg_list                     IN   varchar2      := fnd_api.g_false,
             p_commit                            IN   varchar2      := fnd_api.g_false,
             p_validation_level                  IN   number        := fnd_api.g_valid_level_full,
             p_event_date                        IN   date,
             p_event_type                        IN   varchar2      := 'EAM_SYSTEM_EVENTS',
             p_event_id                          IN   number        := NULL,
             p_instance_id                       IN   number,
             p_ref_id                            IN   number,
             p_organization_id                   IN   number        := NULL,
             x_return_status             OUT NOCOPY   varchar2,
             x_msg_count                 OUT NOCOPY   number,
             x_msg_data                  OUT NOCOPY   varchar2)
IS
             l_api_name                    CONSTANT   varchar2(30)  :='instance_update_event';
             l_api_version                 CONSTANT   number        := 1.0;
             l_association_id                         number;
             l_validated                              boolean;
             l_exists                                 boolean;
             l_instance_number                        varchar2(30);
             l_organization_id                        number;
             l_reference                              varchar2(30);
             l_status                                 number	    := NULL;
             l_status1                                number	    := NULL;
             l_status2                                number	    := NULL;
             l_event_id                               number;
             l_date                                   date;

BEGIN

/* Standard Start of API savepoint */
SAVEPOINT EAM_ASSET_LOG_PVT;

/* Standard call to check for call compatibility. */
        IF NOT FND_API.Compatible_API_Call
                (       l_api_version                ,
                        p_api_version                ,
                        l_api_name                   ,
                        G_PKG_NAME
                        )
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

/* Initialize message list if p_init_msg_list is set to TRUE. */
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                fnd_msg_pub.initialize;
        END IF;

/* Initialize API return status to success */
x_return_status := FND_API.G_RET_STS_SUCCESS;

	BEGIN
	  SELECT mp.maint_organization_id  INTO l_organization_id
	    FROM mtl_parameters mp, csi_item_instances cii
	   WHERE mp.organization_id = cii.last_vld_organization_id
	     AND cii.instance_id = p_instance_id;

        EXCEPTION
	      WHEN NO_DATA_FOUND THEN
		fnd_message.set_name
				(  application  => 'EAM'
				 , name         => 'EAM_INSTANCE_ID_INVALID'
				);

		fnd_msg_pub.add;
		x_return_status:= fnd_api.g_ret_sts_error;
		fnd_msg_pub.Count_And_Get
				(  p_count      =>  x_msg_count,
				   p_data       =>  x_msg_data
				);
	       null;
        END;

        /* VALIDATION 1 Instanceid*/
	l_status := null;
	IF p_event_type='EAM_SYSTEM_EVENTS' THEN
	  BEGIN
		SELECT  instance_history_id INTO l_status
                  FROM  csi_item_instances_H
                 WHERE  instance_history_id = p_ref_id
		 AND    (nvl(old_location_id,1) <> nvl(new_location_id,1));

	  EXCEPTION
	      WHEN NO_DATA_FOUND THEN
	       null;
	  END;

	  BEGIN
                SELECT  instance_history_id INTO l_status1
                  FROM  csi_item_instances_h
                 WHERE  instance_history_id = p_ref_id AND
			old_active_end_date IS NULL and
			new_active_end_date IS NOT NULL;
	  EXCEPTION
	      WHEN NO_DATA_FOUND THEN
	       null;
	  END;

	  BEGIN
                SELECT instance_history_id INTO l_status2
                  FROM csi_item_instances_h
                 WHERE instance_history_id = p_ref_id AND
		       old_active_end_date is not null
		       AND new_active_end_date IS NULL;
	  EXCEPTION
	      WHEN NO_DATA_FOUND THEN
	       null;
	  END;

                IF      l_status  IS NOT NULL        THEN
                        l_event_id := 13 ;

			SELECT  old_location_id||'->'||new_location_id INTO l_reference
			  FROM  csi_item_instances_H
			 WHERE  instance_history_id = p_ref_id;

                ELSIF   l_status1  IS NOT NULL       THEN
                        l_event_id := 2 ;

                        SELECT to_char(last_updated_by) INTO l_reference
                          FROM csi_item_instances_h
                         WHERE instance_history_id = p_ref_id;

                ELSIF   l_status2  IS NOT NULL        THEN
                        l_event_id := 1 ;

                        SELECT to_char(last_updated_by)  INTO l_reference
                          FROM csi_item_instances_H
                         WHERE  instance_history_id = p_ref_id;

                END IF;

        END IF;

    IF  l_event_id IS NOT NULL        THEN

        EAM_ASSET_LOG_PVT.insert_row(
                        p_event_date                =>        p_event_date,
                        p_event_type                =>        p_event_type,
                        p_event_id                  =>        l_event_id,
                        p_organization_id           =>        l_organization_id,
                        p_instance_id               =>        p_instance_id,
                        p_reference                 =>        l_reference,
                        p_ref_id                    =>        p_ref_id,
                        x_return_status             =>        x_return_status,
                        x_msg_count                 =>        x_msg_count,
                        x_msg_data                  =>        x_msg_data
                        );
    END IF;

        /* Standard check of p_commit. */

        IF FND_API.TO_BOOLEAN( P_COMMIT ) THEN
                COMMIT WORK;
        END IF;

-- Standard call to get message count and if count is 1, get message info.

        fnd_msg_pub.get
        (       p_msg_index_out         =>      x_msg_count ,
                p_data                  =>      x_msg_data
        );
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO EAM_ASSET_LOG_PVT;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                fnd_msg_pub.get
                (       p_msg_index_out         =>      x_msg_count ,
                        p_data                  =>      x_msg_data
                );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO EAM_ASSET_LOG_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                fnd_msg_pub.get
                (       p_msg_index_out         =>      x_msg_count ,
                        p_data                  =>      x_msg_data
                );
        WHEN OTHERS THEN
                ROLLBACK TO EAM_ASSET_LOG_PVT;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF fnd_msg_pub.Check_Msg_Level(fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR) THEN
                fnd_msg_pub.add_exc_msg
                (       G_PKG_NAME ,
                        l_api_name
                );
        END IF;

END instance_update_event;

-- Procedure to Log  Meter Transactions
PROCEDURE insert_meter_log(
             p_api_version                        IN   number         := 1.0,
             p_init_msg_list                      IN   varchar2       := fnd_api.g_false,
             p_commit                             IN   varchar2       := fnd_api.g_false,
             p_validation_level                   IN   number         := fnd_api.g_valid_level_full,
             p_event_date                         IN   date           := sysdate,
             p_instance_id                        IN   number	      := NULL,
             p_ref_id                             IN   number,
             p_attribute_category                 IN   varchar2	      := NULL,
             p_attribute1                         IN   varchar2	      := NULL,
             p_attribute2                         IN   varchar2	      := NULL,
             p_attribute3                         IN   varchar2	      := NULL,
             p_attribute4                         IN   varchar2       := NULL,
             p_attribute5                         IN   varchar2       := NULL,
             p_attribute6                         IN   varchar2       := NULL,
             p_attribute7                         IN   varchar2       := NULL,
             p_attribute8                         IN   varchar2       := NULL,
             p_attribute9                         IN   varchar2       := NULL,
             p_attribute10                        IN   varchar2       := NULL,
             p_attribute11                        IN   varchar2       := NULL,
             p_attribute12                        IN   varchar2       := NULL,
             p_attribute13                        IN   varchar2       := NULL,
             p_attribute14                        IN   varchar2       := NULL,
             p_attribute15                        IN   varchar2       := NULL,
             x_return_status              OUT NOCOPY   varchar2,
             x_msg_count                  OUT NOCOPY   number,
             x_msg_data                   OUT NOCOPY   varchar2)
IS
             l_api_name                     CONSTANT   varchar2(30)   := 'insert_meter_log';
             l_api_version                  CONSTANT   number         := 1.0;
             l_full_name                    CONSTANT   varchar2(60)   := g_pkg_name || '.' || l_api_name;
             l_instance_id                             number;
             l_instance_number                         varchar2(30);
             l_log_id                                  number;
             l_event_type                              varchar2(30)   := 'EAM_SYSTEM_EVENTS';
             l_event_id                                number         := 3;
             l_reference                               varchar2(30);
             l_equipment_gen_object_id                 number;
             l_organization_id                         number;
             l_status                                  number;
             l_mfg_org_id                              number;

             CURSOR cmetid IS
                        SELECT cii.instance_id, cii.instance_number, cii.last_vld_organization_id org_id
                          FROM csi_counter_associations caa, csi_item_instances cii
                         WHERE caa.counter_id = p_ref_id AND
			       cii.instance_id = caa.source_object_id;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT EAM_ASSET_LOG_PVT_SV;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call(
            l_api_version
           ,p_api_version
           ,l_api_name
           ,g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;
	BEGIN
        SELECT  counter_id INTO l_status
          FROM  csi_counters_b
         WHERE  counter_id = p_ref_id AND
                p_event_date >= NVL(start_date_active, p_event_date) AND
		p_event_date <= NVL(end_date_active, p_event_date);


	EXCEPTION
	      WHEN NO_DATA_FOUND THEN
                fnd_message.set_name
                                (  application  => 'EAM'
                                , name         => 'EAM_COUNTER_ID_INVALID'
                                );

                fnd_msg_pub.add;
		x_return_status:= fnd_api.g_ret_sts_error;
		fnd_msg_pub.count_and_get(
		    p_count => x_msg_count,
		    p_data => x_msg_data);
        RETURN;
        END ;


		BEGIN
		    SELECT name INTO l_reference
		      FROM csi_counters_tl
		     WHERE language = userenv('Lang')
		     AND counter_id= p_ref_id;
		EXCEPTION
		     WHEN NO_DATA_FOUND THEN
			fnd_message.set_name
					(  application  => 'EAM'
					, name         => 'EAM_COUNTER_ID_INVALID'
					);

			fnd_msg_pub.add;
			x_return_status:= fnd_api.g_ret_sts_error;
			fnd_msg_pub.count_and_get(
			    p_count => x_msg_count,
			    p_data => x_msg_data);
			RETURN;
		END ;


           FOR l_cmetid IN cmetid LOOP
                          l_instance_id     := l_cmetid.instance_id;
                          l_instance_number := l_cmetid.instance_number;

                        SELECT  maint_organization_id  INTO l_organization_id
                        FROM    mtl_parameters
                        WHERE   organization_id = l_cmetid.org_id;

                        EAM_ASSET_LOG_PVT.validate_event(
                                p_event_date           => p_event_date,
                                p_event_type           => l_event_type,
                                p_event_id             => l_event_id,
                                p_instance_id          => l_instance_id,
                                p_instance_number      => l_instance_number,
                                x_return_status        => x_return_status,
                                x_msg_count            => x_msg_count,
                                x_msg_data             => x_msg_data);


                    IF x_return_status = fnd_api.g_ret_sts_success THEN

                        SELECT eam_asset_log_s.nextval INTO l_log_id FROM dual;

                        EAM_ASSET_LOG_PVT.insert_row(
                                p_event_date           =>        p_event_date,
                                p_event_type           =>        l_event_type,
                                p_event_id             =>        l_event_id,
                                p_organization_id      =>        l_organization_id,
                                p_instance_id          =>        l_instance_id,
                                p_reference            =>        l_reference,
                                p_ref_id               =>        p_ref_id,
                                x_return_status        =>        x_return_status,
                                x_msg_count            =>        x_msg_count,
                                x_msg_data             =>        x_msg_data
                                );

                END IF;
           END LOOP;

      -- End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

      fnd_msg_pub.count_and_get(
         p_count => x_msg_count
        ,p_data => x_msg_data);

   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO EAM_ASSET_LOG_PVT_SV;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO EAM_ASSET_LOG_PVT_SV;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO EAM_ASSET_LOG_PVT_SV;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(
               fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data => x_msg_data);

END insert_meter_log;

END EAM_ASSET_LOG_PVT;

/
