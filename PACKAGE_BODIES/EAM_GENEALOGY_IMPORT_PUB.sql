--------------------------------------------------------
--  DDL for Package Body EAM_GENEALOGY_IMPORT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_GENEALOGY_IMPORT_PUB" as
/* $Header: EAMPGEIB.pls 120.1 2006/09/27 12:09:16 kmurthy noship $ */
 -- Start of comments
 -- API name : import_genealogy
 -- Type     : Public
 -- Function :
 -- Pre-reqs : None.
 -- Parameters :
 -- IN          p_interface_group_id     IN    NUMBER   Required,
 --             p_purge_option           IN    VARCHAR2 Optional  Default = 'N'
 --
 -- OUT         errbuf                   OUT   VARCHAR2
 --             retcode                  OUT   NUMBER
 --
 -- Version  Initial version    1.0     Himal Karmacharya
 --
 -- Notes    : This public API imports genealogy info into
 --            MTL_OBJECT_GENEALOGY table
 --
 -- End of comments


   g_pkg_name    CONSTANT VARCHAR2(30):= 'EAM_GENEALOGY_IMPORT_PUB';
   g_msg                  VARCHAR2(2000):= null;

   -- global variable to turn on/off debug logging.
   G_DEBUG VARCHAR2(1) := NVL(fnd_profile.value('EAM_DEBUG'), 'N');

PROCEDURE import_genealogy(
    errbuf                     OUT NOCOPY     VARCHAR2,
    retcode                    OUT NOCOPY     NUMBER,
    p_interface_group_id        IN      NUMBER,
    p_purge_option              IN      VARCHAR2 := 'N'
    ) IS
      l_api_name       CONSTANT VARCHAR2(30) := 'import_genealogy';
      l_api_version    CONSTANT NUMBER       := 1.0;
      l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
      l_conc_status             BOOLEAN;
      l_error_message           VARCHAR2(2000);
      l_error_code              NUMBER;
      l_return_status           VARCHAR2(10);
      l_msg_count               NUMBER;
      l_msg_data                VARCHAR2(2000);
      l_dummy			NUMBER;
    -- Cursor for all the records in this processing group

    CURSOR  genealogy_cur IS
    SELECT  *
    FROM    MTL_OBJECT_GENEALOGY_INTERFACE mogi
    WHERE   mogi.group_id = p_interface_group_id
    AND     mogi.process_status = 'R';

    BEGIN

    g_msg := 'Entering ' || l_full_name;
    IF G_DEBUG = 'Y' THEN
      fnd_file.put_line(FND_FILE.LOG, g_msg);
    END IF;

      -- Standard Start of API savepoint

      SAVEPOINT import_genealogy_PUB;

      -- Initialize message list
      fnd_msg_pub.initialize;

      -- Initialize API return status to success
      l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL', l_error_message);

    -- API starts
      l_error_code := 9999;
      l_error_message := 'Unknown Exception';
      g_msg := '';
      IF G_DEBUG = 'Y' THEN
        fnd_file.put_line(FND_FILE.LOG, g_msg);
      END IF;

      g_msg := '******** Starting import of Genealogy ********';
      IF G_DEBUG = 'Y' THEN
        fnd_file.put_line(FND_FILE.LOG, g_msg);
      END IF;

      g_msg := 'Processing interface group ' || p_interface_group_id ||
      ' with purge option ' || p_purge_option;

      IF G_DEBUG = 'Y' THEN
        fnd_file.put_line(FND_FILE.LOG, g_msg);
      END IF;

      g_msg := 'Opening cursor for records in interface table';
      IF G_DEBUG = 'Y' THEN
        fnd_file.put_line(FND_FILE.LOG, g_msg);
      END IF;

      -- process each row in the cursor at a time

      FOR genealogy_rec in genealogy_cur LOOP

	fnd_msg_pub.initialize;

        declare

            incorrect_genealogy exception;

        begin

            --  Initialize API return status to success
            l_return_status := fnd_api.g_ret_sts_success;


	    -- check for the item type.

	begin
            select msi.eam_item_type into l_dummy
            from mtl_serial_numbers msn, mtl_system_items msi
            where msn.serial_number = genealogy_rec.serial_number
            and msi.organization_id = genealogy_rec.organization_id
            and msi.inventory_item_id = genealogy_rec.inventory_item_id
            and msn.inventory_item_id = msi.inventory_item_id
	    and msi.organization_id = msn.current_organization_id;

	    if (l_dummy <> 1 and l_dummy <> 3) then
		FND_MESSAGE.SET_NAME('EAM', 'EAM_GEN_INVALID_ITEM_TYPE');
		FND_MSG_PUB.ADD;
		RAISE incorrect_genealogy;
	    end if;

        exception
            when others then
		FND_MESSAGE.SET_NAME('EAM', 'EAM_GEN_INVALID_ITEM_TYPE');
		FND_MSG_PUB.ADD;
		RAISE incorrect_genealogy;
        end;

            -- if the import mode is 0 then insert a row in the MOG table

            IF genealogy_rec.import_mode = 0 THEN

		if genealogy_rec.start_date_active is null then
		   FND_MESSAGE.SET_NAME('EAM', 'EAM_GEN_NULL_START_DATE');
		   FND_MSG_PUB.ADD;
		   RAISE incorrect_genealogy;
		end if;

		if l_dummy = 1 then

	                INV_GENEALOGY_PUB.insert_genealogy(
                                            p_api_version => l_api_version
                                        ,   p_commit => fnd_api.g_true
                                        ,   p_object_type =>  genealogy_rec.object_type
                                        ,   p_parent_object_type => genealogy_rec.parent_object_type
                                        ,   p_object_id => genealogy_rec.object_id
                                        ,   p_object_number => genealogy_rec.serial_number
                                        ,   p_inventory_item_id => genealogy_rec.inventory_item_id
                                        ,   p_org_id => genealogy_rec.organization_id
                                        ,   p_parent_object_id => genealogy_rec.parent_object_id
                                        ,   p_parent_object_number => genealogy_rec.parent_serial_number
                                        ,   p_parent_inventory_item_id => genealogy_rec.parent_inventory_item_id
                                        ,   p_parent_org_id => genealogy_rec.parent_organization_id
                                        ,   p_genealogy_origin => genealogy_rec.genealogy_origin
                                        ,   p_genealogy_type => genealogy_rec.genealogy_type
                                        ,   p_start_date_active => genealogy_rec.start_date_active
                                        ,   p_end_date_active => genealogy_rec.end_date_active
                                        ,   p_origin_txn_id => genealogy_rec.origin_txn_id
                                        ,   p_update_txn_id => genealogy_rec.update_txn_id
                                        ,   x_return_status => l_return_status
                                        ,   x_msg_count => l_msg_count
                                        ,   x_msg_data => l_msg_data);
		else
			wip_eam_genealogy_pvt.create_eam_genealogy(
                                            p_api_version => l_api_version
                                        ,   p_commit => fnd_api.g_true
                                        ,   p_object_id => genealogy_rec.object_id
                                        ,   p_serial_number => genealogy_rec.serial_number
                                        ,   p_inventory_item_id => genealogy_rec.inventory_item_id
                                        ,   p_organization_id => genealogy_rec.organization_id
                                        ,   p_parent_object_id => genealogy_rec.parent_object_id
                                        ,   p_parent_serial_number => genealogy_rec.parent_serial_number
                                        ,   p_parent_inventory_item_id => genealogy_rec.parent_inventory_item_id
                                        ,   p_parent_organization_id => genealogy_rec.parent_organization_id
                                        ,   p_start_date_active => genealogy_rec.start_date_active
                                        ,   p_end_date_active => genealogy_rec.end_date_active
                                        ,   p_origin_txn_id => genealogy_rec.origin_txn_id
                                        ,   p_update_txn_id => genealogy_rec.update_txn_id
					,   p_from_eam => fnd_api.g_true
                                        ,   x_return_status => l_return_status
                                        ,   x_msg_count => l_msg_count
                                        ,   x_msg_data => l_msg_data);
		end if;

             -- if the import mode is 1 then update the row in MOG table

             ELSIF genealogy_rec.import_mode = 1 THEN

		if genealogy_rec.end_date_active is null then
		   FND_MESSAGE.SET_NAME('EAM', 'EAM_GEN_NULL_END_DATE');
		   FND_MSG_PUB.ADD;
		   RAISE incorrect_genealogy;
		end if;

		if l_dummy = 3 then
		   if genealogy_rec.end_date_active > sysdate then
		       FND_MESSAGE.SET_NAME('WIP', 'WIP_EAM_REBUILD_FUTURE_TXN');
		       FND_MSG_PUB.ADD;
		       RAISE FND_API.G_EXC_ERROR;
 		   end if;
		end if;

	        INV_GENEALOGY_PUB.update_genealogy(
                                            p_api_version => l_api_version
                                        ,   p_commit => fnd_api.g_true
                                        ,   p_object_type =>  genealogy_rec.object_type
                                        ,   p_object_id => genealogy_rec.object_id
                                        ,   p_object_number => genealogy_rec.serial_number
                                        ,   p_inventory_item_id => genealogy_rec.inventory_item_id
                                        ,   p_org_id => genealogy_rec.organization_id
                                        ,   p_genealogy_origin => genealogy_rec.genealogy_origin
                                        ,   p_genealogy_type => genealogy_rec.genealogy_type
                                        ,   p_end_date_active => genealogy_rec.end_date_active
                                        ,   p_update_txn_id => genealogy_rec.update_txn_id
                                        ,   x_return_status => l_return_status
                                        ,   x_msg_count => l_msg_count
                                        ,   x_msg_data => l_msg_data);


             END IF;

             IF l_return_status = 'E' or l_return_status = 'U' THEN
                  UPDATE MTL_OBJECT_GENEALOGY_INTERFACE mogi
                  SET mogi.process_status = 'E',
                  mogi.error_message = l_msg_data
                  WHERE mogi.group_id = p_interface_group_id and mogi.interface_header_id = genealogy_rec.interface_header_id;

             ELSIF l_return_status = 'S' THEN
                UPDATE MTL_OBJECT_GENEALOGY_INTERFACE mogi
                SET mogi.process_status = 'S'
                WHERE mogi.group_id = p_interface_group_id and mogi.interface_header_id = genealogy_rec.interface_header_id;
             END IF;

        exception
            when incorrect_genealogy then

                l_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get
                (p_encoded   =>    FND_API.G_FALSE,
                 p_count     =>    l_msg_count,
                 p_data      =>    l_msg_data
                );

                UPDATE MTL_OBJECT_GENEALOGY_INTERFACE mogi
                SET mogi.process_status = 'E',
                mogi.error_message = l_msg_data
                WHERE mogi.group_id = p_interface_group_id and mogi.interface_header_id = genealogy_rec.interface_header_id;

            when others then

                l_return_status := FND_API.G_RET_STS_ERROR ;

                FND_MSG_PUB.Count_And_Get
                (p_encoded     =>     FND_API.G_FALSE,
                 p_count       =>     l_msg_count,
                 p_data        =>     l_msg_data
                );

                UPDATE MTL_OBJECT_GENEALOGY_INTERFACE mogi
                SET mogi.process_status = 'E',
                mogi.error_message = l_msg_data
                WHERE mogi.group_id = p_interface_group_id and mogi.interface_header_id = genealogy_rec.interface_header_id;

         end;

      END LOOP;

    -- delete rows marked as success

    IF p_purge_option = 'Y' THEN
        DELETE FROM MTL_OBJECT_GENEALOGY_INTERFACE mogi
        WHERE mogi.process_status = 'S' and
              mogi.group_id = p_interface_group_id;
    END IF;

    COMMIT;

    g_msg := 'Exiting ' || l_full_name;
    IF G_DEBUG = 'Y' THEN
      fnd_file.put_line(FND_FILE.LOG, g_msg);
    END IF;

    l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL', l_error_message);


EXCEPTION

    WHEN OTHERS THEN

        ROLLBACK TO import_genealogy_PUB;

      	l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', l_error_message);

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
        END IF;

        FND_MSG_PUB.Count_And_Get
        (p_encoded  =>    FND_API.G_FALSE,
         p_count    =>    l_msg_count,
         p_data     =>    l_msg_data
        );

        UPDATE MTL_OBJECT_GENEALOGY_INTERFACE mogi
        SET mogi.process_status = 'E',
        mogi.error_message = l_msg_data,
        mogi.error_code = 9999
        WHERE mogi.group_id = p_interface_group_id;

        IF G_DEBUG = 'Y' THEN
          fnd_file.put_line(FND_FILE.LOG, l_msg_data);
        END IF;

END import_genealogy;


END EAM_GENEALOGY_IMPORT_PUB;

/
