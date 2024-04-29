--------------------------------------------------------
--  DDL for Package Body EAM_PN_EXTRACTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_PN_EXTRACTION_PUB" AS
/* $Header: EAMPNXPB.pls 120.1 2006/02/09 20:43:11 hkarmach noship $ */
G_PKG_NAME              CONSTANT VARCHAR2(30) := 'EAM_PN_EXTRACTION_PUB';

Function pn_check_eam_asset(p_location_id in NUMBER) return BOOLEAN
IS
	l_asset_exists varchar2(1) := 'N';
begin

	select 'Y' into l_asset_exists
	from dual
	where exists
	( select * from csi_item_instances
	where pn_location_id = p_location_id
	and nvl(active_start_date, sysdate-1) < sysdate
	and nvl(active_end_date, sysdate+1) > sysdate);

	if (l_asset_exists = 'Y') then
    		return TRUE;
	else
    		return FALSE;
	end if;

end pn_check_eam_asset;

PROCEDURE pn_eam_export_mode(
  P_API_VERSION IN NUMBER,
  P_INIT_MSG_LIST IN VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT IN VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  P_PN_LOCATION_ID IN NUMBER,
  P_PARENT_LOCATION_ID IN NUMBER,
  P_ACTIVE_START_DATE IN DATE,
  P_ACTIVE_END_DATE IN DATE,
  X_INSERT OUT NOCOPY NUMBER,
  X_INSERT_MODE OUT NOCOPY NUMBER,
  X_INSERT_STATUS OUT NOCOPY NUMBER,
  X_RETURN_STATUS OUT NOCOPY VARCHAR2,
  X_MSG_COUNT OUT NOCOPY NUMBER,
  X_MSG_DATA OUT NOCOPY VARCHAR2)
IS

    --  X_INSERT, if equals 1 then the row will be inserted in the interface tables.
    --  X_INSERT_MODE => 0 - create a new row and 1 - Update the existing row
    --  X_INSERT_STATUS, specifies the current status of Asset Number (3 Resides in stores )
    --  X_RETURN_STATUS, X_MSG_COUNT OUT NOCOPY NUMBER,  X_MSG_DATA OUT NOCOPY VARCHAR2
    --    Standard API out parameter (for error handling).

    l_api_version     CONSTANT NUMBER          := 1.0;
    l_api_name        CONSTANT VARCHAR2(30)    := 'PN_EAM_EXPORT_MODE';

l_stmt_num number := 0;
l_instance_id number;
l_gen_object_id number;
l_INVENTORY_ITEM_ID NUMBER;
l_SERIAL_NUMBER NUMBER;
l_ORGANIZATION_ID NUMBER;
l_pn_exists_in_eam varchar2(1) := 'N';
l_parent_exists_in_eam varchar2(1) := 'N';
l_hr_exists varchar2(1) := 'N';
l_pn_start_date date;
l_pn_end_date date;
l_start_date date;
l_end_date date;
l_parent_exists_in_mog number := 0;

BEGIN

      -- Standard Start of API savepoint
      l_stmt_num    := 10;
      SAVEPOINT pn_eam_export_mode_PUB;

      l_stmt_num    := 20;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call(
            l_api_version
           ,p_api_version
           ,l_api_name
           ,g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_stmt_num    := 30;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

        x_insert := 1;

        l_gen_object_id := -1;

        --Does PN exist in MSN?

	begin
	        -- Bug # 3372982
                SELECT cii.active_start_date, cii.active_end_date, msn.gen_object_id, cii.instance_id
		 INTO l_start_date, l_end_date, l_gen_object_id, l_instance_id
		 FROM mtl_serial_numbers msn, csi_item_instances cii
		 WHERE cii.pn_location_id = p_pn_location_id
		       and msn.current_organization_id = cii.last_vld_organization_id
		       and msn.inventory_item_id = cii.inventory_item_id
		       and msn.serial_number = cii.serial_number;

	exception
		when no_data_found  then
		l_gen_object_id := -1;
	end;

        if l_gen_object_id <>  -1 then
	        x_insert := 1;
            	x_insert_mode := 1;
            	x_insert_status := 4;

		begin
            		select 'Y' into l_parent_exists_in_eam from dual
            		where exists
                	(select * from csi_item_instances where
                	pn_location_id = p_parent_location_id);

		exception
			when no_data_found then
			l_parent_exists_in_eam := 'N';
		end;


	        if l_parent_exists_in_eam <> 'Y' then
		      x_insert := 1;
		      x_insert_mode := 1;
		      x_insert_status := 4;
	        else
			begin
	                	select 'Y' into l_hr_exists from dual
				where exists
                		(select * from mtl_object_genealogy
                		where object_id = l_gen_object_id);
			exception
				when no_data_found then
				l_hr_exists := 'N';
			end;

	                if l_hr_exists <> 'Y' then
			         x_insert := 1;
			         x_insert_mode := 1;
			         x_insert_status := 4;
        	        else
			         x_insert := 1;
			         x_insert_mode := 1;
			         x_insert_status := 4;

	        	        select pl.active_start_date, pl.active_end_date
        	        	into l_pn_start_date, l_pn_end_date
                		from pn_locations_all pl
                		where location_id = p_pn_location_id;

                                -- Bug # 3372982
	                	SELECT COUNT(*)
                                 INTO l_parent_exists_in_mog
                                 FROM mtl_object_genealogy mog, mtl_serial_numbers msn
                                 WHERE mog.object_id = l_gen_object_id
                                 AND msn.gen_object_id = mog.parent_object_id
                                 AND mog.genealogy_type = 5
                                 AND mog.start_date_active = l_pn_start_date
                                 AND ( mog.end_date_active = l_pn_end_date OR
                                     (l_pn_end_date IS NULL and mog.end_date_active is NULL))
                                 AND rownum = 1 ;

                                IF l_parent_exists_in_mog = 1 THEN
                                  x_insert := 0;
                                END IF;
               		end if;
	        end if;
        else
	    x_insert := 1;
            x_insert_mode := 0;
            x_insert_status := 4;
        end if;


  EXCEPTION
    WHEN fnd_api.g_exc_error THEN

      ROLLBACK TO pn_eam_export_mode_PUB;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);

    WHEN fnd_api.g_exc_unexpected_error THEN

      ROLLBACK TO pn_eam_export_mode_PUB;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS THEN

      ROLLBACK TO pn_eam_export_mode_PUB;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);

END PN_EAM_EXPORT_MODE;


END  EAM_PN_EXTRACTION_PUB;

/
