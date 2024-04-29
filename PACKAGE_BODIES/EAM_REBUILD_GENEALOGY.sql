--------------------------------------------------------
--  DDL for Package Body EAM_REBUILD_GENEALOGY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_REBUILD_GENEALOGY" AS
/* $Header: EAMRBGNB.pls 115.4 2002/11/20 19:28:48 aan noship $*/

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'EAM_REBUILD_GENEALOGY';

PROCEDURE create_rebuild_genealogy(
     p_api_version                   IN  NUMBER
 ,   p_init_msg_list	             IN  VARCHAR2 := FND_API.G_FALSE
 ,   p_commit		                 IN  VARCHAR2 := FND_API.G_FALSE
 ,   p_validation_level	             IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
 ,   p_subinventory                  IN  VARCHAR2 := NULL
 ,   p_locator_id                  IN  NUMBER := NULL
 ,   p_object_id                     IN  number := null
 ,   p_serial_number                 IN  VARCHAR2 := NULL
 ,   p_organization_id                        IN  NUMBER := NULL
 ,   p_inventory_item_id               IN NUMBER := NULL
 ,   p_parent_object_id	             IN  NUMBER   := NULL
 ,   p_parent_serial_number          IN  VARCHAR2 := NULL
 ,   p_parent_inventory_item_id	     IN  NUMBER   := NULL
 ,   p_parent_organization_id		         IN  NUMBER   := NULL
 ,   p_start_date_active             IN  DATE     := sysdate
 ,   p_end_date_active               IN  DATE     := NULL
 ,   x_msg_count                     OUT NOCOPY NUMBER
 ,   x_msg_data                      OUT NOCOPY VARCHAR2
 ,   x_return_status                 OUT NOCOPY VARCHAR2) is

 l_api_name           CONSTANT VARCHAR(30) := 'CREATE_REBUILD_GENEALOGY';
 l_errCode number;
 l_msg_count number;
 l_msg_data varchar2(100);
 l_return_status varchar2(5);
 l_statement number;
 l_txn_id number;
 l_current_status number;
 l_dist_acct_id number;
 l_serial_number varchar2(30);
 l_inventory_item_id number;
 l_subinventory varchar2(30);
 l_locator_id number;
 l_organization_id number;
 l_api_version number := 1.0;
 l_parent_object_id number;
 l_charge_object_id number;

begin

	savepoint eam_rebuild_genealogy;

	IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                   p_api_version,
                                   l_api_name,
                                   g_pkg_name)
	THEN
       		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	IF FND_API.TO_BOOLEAN(p_init_msg_list)
	THEN
       		FND_MSG_PUB.initialize;
	END IF;

--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

-- obtain rebuildable information
	if p_object_id is null then
    		if p_serial_number is null
    		or p_inventory_item_id is null
    		or p_organization_id is null then
            		FND_MESSAGE.SET_NAME('INV', 'INV_FIELD_INVALID');
            		FND_MESSAGE.SET_TOKEN('ENTITY1', 'p_serial_number');
            		FND_MSG_PUB.ADD;
	    		l_return_status := 'E';
            		RAISE FND_API.G_EXC_ERROR;
    		else
        		l_serial_number := p_serial_number;
        		l_inventory_item_id := p_inventory_item_id;
        		l_organization_id := p_organization_id;
    		end if;
	else
	    	if (p_serial_number is null)
    		or (p_inventory_item_id is null)
    		or (p_organization_id is null) then

        		select serial_number, inventory_item_id, current_organization_id
        		into l_serial_number, l_inventory_item_id, l_organization_id
        		from mtl_serial_numbers where
        		gen_object_id = p_object_id;
    		else

		        l_serial_number := p_serial_number;
        		l_inventory_item_id := p_inventory_item_id;
        		l_organization_id := p_organization_id;
    		end if;
	end if;

-- obtain parent object id information
	if p_parent_object_id is null then
    		if p_parent_serial_number is null
    		or p_parent_inventory_item_id is null
    		or p_parent_organization_id is null then
            		FND_MESSAGE.SET_NAME('INV', 'INV_FIELD_INVALID');
            		FND_MESSAGE.SET_TOKEN('ENTITY1', 'p_serial_number');
            		FND_MSG_PUB.ADD;
	    		l_return_status := 'E';
            		RAISE FND_API.G_EXC_ERROR;
    		else
			select gen_object_id into l_parent_object_id
        		from mtl_serial_numbers where
			serial_number = p_parent_serial_number
			and inventory_item_id = p_parent_inventory_item_id
			and current_organization_id = p_parent_organization_id;
		end if;
	else
		l_parent_object_id := p_parent_object_id;
	end if;

-- check if there is an open work order against the rebuild item.  If the parent does not correspond to the charge asset in the work order, there is an error.  If the charge asset is null, this is not a problem.

	begin
		select msn.gen_object_id into l_charge_object_id
		from wip_discrete_jobs wdj, mtl_serial_numbers msn
		where wdj.rebuild_serial_number = l_serial_number
		and wdj.rebuild_item_id = l_inventory_item_id
		and wdj.organization_id = l_organization_id
		and msn.serial_number = wdj.asset_number
		and msn.inventory_item_id = wdj.asset_group_id
		and msn.current_organization_id = wdj.organization_id
		and wdj.manual_rebuild_flag = 'N'
		and wdj.status_type in (1,3,6);

		if l_charge_object_id <> l_parent_object_id then
        		FND_MESSAGE.SET_NAME('EAM', 'EAM_CURRENT_WO_WITH_CHARGE_ASSET');
            		FND_MSG_PUB.ADD;
	    		l_return_status := 'E';
            		RAISE FND_API.G_EXC_ERROR;
		end if;
	exception
		when others then
			null;
	end;

-- determine the current status of the rebuild component
	begin
		select current_status into l_current_status from mtl_serial_numbers
		where serial_number = l_serial_number
		and inventory_item_id = l_inventory_item_id
		and current_organization_id = l_organization_id;

	exception
		when no_data_found then
        		FND_MESSAGE.SET_NAME('EAM', 'EAM_INVALID_CURRENT_STATUS');
            		FND_MSG_PUB.ADD;
	    		l_return_status := 'E';
            		RAISE FND_API.G_EXC_ERROR;
	end;

-- if current_status = 3 then carry out transaction

	if l_current_status = 3 then

		if p_subinventory is null then
			select current_subinventory_code into l_subinventory
    			from mtl_serial_numbers
    			where serial_number = l_serial_number and
          		inventory_item_id = l_inventory_item_id and
          		current_organization_id = l_organization_id;
		else
    			l_subinventory := p_subinventory;
		end if;

		if p_locator_id is null then
			begin
				select current_locator_id into l_locator_id
    				from mtl_serial_numbers
    				where serial_number = l_serial_number and
          			inventory_item_id = l_inventory_item_id and
          			current_organization_id = l_organization_id;

			exception
				when others then
					null;
			end;
		else
    			l_locator_id := p_locator_id;
		end if;

-- Genealogy entry in the future is not allowed.
-- This restriction has been put in place because eventhough the date
-- of transaction is future, the status of the item is changed immediately

		if p_start_date_active > sysdate OR (p_end_date_active is not null
                                    and p_end_date_active > sysdate) then
   			l_return_status := 'E';
   			FND_MESSAGE.SET_NAME('EAM', 'EAM_REBUILD_FUTURE_TXN');
   			FND_MSG_PUB.ADD;
   			RAISE FND_API.G_EXC_ERROR;
		elsif (p_start_date_active < sysdate and
      		(p_end_date_active is not null and p_end_date_active < sysdate)) then
    			l_txn_id := null;
    			l_return_status := 'S';
		else

-- obtain the offset acct id from user defined EAM parameters
    			begin
        			select maintenance_offset_account into l_dist_acct_id
        			from wip_eam_parameters
        			where organization_id = l_organization_id;

    			exception
    				when others then
				FND_MESSAGE.SET_NAME('EAM', 'EAM_NO_OFFSET_ACCOUNT');
   				FND_MSG_PUB.ADD;
				RAISE FND_API.G_EXC_ERROR;
    			end;

-- Transaction processing API is called
-- If the transaction is processed successfully then
-- the inventory genealogy API is called

    			eam_transactions_pvt.process_eam_txn(
                       		p_subinventory => l_subinventory,
				p_locator_id => l_locator_id,
                       		p_serial_number => l_serial_number,
                       		p_organization_id => l_organization_id,
                       		p_inventory_item_id => l_inventory_item_id,
      	                 	p_dist_acct_id => l_dist_acct_id,
    	                   	p_transaction_type_id => 32,
   	                    	p_transaction_quantity => 1,
 	                      	p_transaction_action_id => 1,
                       		p_transaction_source_type_id => 13,
                	       	x_errCode => l_errCode,
             	          	x_msg_count => l_msg_count,
                	       	x_msg_data => l_msg_data,
        	               	x_return_status => l_return_status,
	                       	x_statement => l_statement);

    			begin
				select last_transaction_id
				into l_txn_id
    				from mtl_serial_numbers
    				where serial_number = l_serial_number;
    			exception
				when others then
	   				RAISE FND_API.G_EXC_ERROR;
    			end;
		end if;

	elsif l_current_status = 4 then
    		l_txn_id := null;
    		l_return_status := 'S';
	else
            	FND_MESSAGE.SET_NAME('EAM', 'EAM_INVALID_CURRENT_STATUS');
            	FND_MSG_PUB.ADD;
	    	l_return_status := 'E';
            	RAISE FND_API.G_EXC_ERROR;
	end if;

	if l_return_status = 'S' then

    		FND_MSG_PUB.initialize;
    		inv_genealogy_pub.insert_genealogy(
     			p_api_version                   => l_api_version
 			,   p_object_type                   => 2
 			,   p_parent_object_type            => 2
 			,   p_object_number                 => l_serial_number
 			,   p_inventory_item_id	     => l_inventory_item_id
 			,   p_org_id			     => l_organization_id
 			,   p_parent_object_id	             => p_parent_object_id
 			,   p_parent_object_number          => p_parent_serial_number
 			,   p_parent_inventory_item_id	     => p_parent_inventory_item_id
 			,   p_parent_org_id		     => p_parent_organization_id
 			,   p_genealogy_origin              => 3
 			,   p_genealogy_type                => 5
 			,   p_start_date_active             => p_start_date_active
 			,   p_end_date_active               => p_end_date_active
 			,   p_origin_txn_id                 => l_txn_id
 			,   x_return_status                 => l_return_status
 			,   x_msg_count                     => l_msg_count
 			,   x_msg_data                      => l_msg_data);

 		if (l_return_status = 'E') or (l_return_status = 'U') then
    			raise FND_API.G_EXC_ERROR;
 		end if;

	else
    		raise FND_API.G_EXC_ERROR;
 	end if;

	if p_commit = FND_API.G_TRUE then
    		commit;
	end if;

 exception
 	WHEN FND_API.G_EXC_ERROR THEN
 		ROLLBACK TO eam_rebuild_genealogy;
   		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		FND_MSG_PUB.Count_And_Get
    		(  	p_encoded			=> 		FND_API.G_FALSE,
    			p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);

 	WHEN OTHERS THEN
		ROLLBACK TO eam_rebuild_genealogy;
   		x_return_status := FND_API.G_RET_STS_ERROR;
    		FND_MSG_PUB.Count_And_Get
    		(  	p_encoded			=> 		FND_API.G_FALSE,
    			p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);

end create_rebuild_genealogy;


 PROCEDURE update_rebuild_genealogy(
     p_api_version                   IN  NUMBER
 ,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
 ,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
 ,   p_validation_level              IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
 ,   p_object_type                   IN  NUMBER
 ,   p_object_id                     IN  NUMBER   := NULL
 ,   p_serial_number                 IN  VARCHAR2 := NULL
 ,   p_inventory_item_id             IN  NUMBER   := NULL
 ,   p_organization_id               IN  NUMBER   := NULL
 ,   p_subinventory                  IN VARCHAR2  := NULL
 ,   p_locator_id                  IN  NUMBER := NULL
 ,   p_genealogy_origin              IN  NUMBER   := NULL
 ,   p_genealogy_type                IN  NUMBER   := NULL
 ,   p_end_date_active               IN  DATE     := NULL
 ,   x_return_status                 OUT NOCOPY VARCHAR2
 ,   x_msg_count                     OUT NOCOPY NUMBER
 ,   x_msg_data                      OUT NOCOPY VARCHAR2) is

 l_api_name           CONSTANT VARCHAR(30) := 'UPDATE_REBUILD_GENEALOGY';
 l_errCode number;
 l_msg_count number;
 l_msg_data varchar2(100);
 l_return_status varchar2(5);
 l_statement number;
 l_txn_id number;
 l_dist_acct_id number;
 l_api_version number := 1.0;
 l_serial_number varchar2(30);
 l_subinventory varchar2(30);
 l_locator_id number;
 l_inventory_item_id number;
 l_object_id number;
 l_organization_id number;
 l_txn_type number;
 l_txn_action_id number;
 l_txn_source_type number;
 l_wip_entity_id number;
 l_work_status number;
 l_original_txn_id number;

 begin

savepoint eam_rebuild_genealogy;

IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                   p_api_version,
                                   l_api_name,
                                   g_pkg_name)
THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

IF FND_API.TO_BOOLEAN(p_init_msg_list)
THEN
       FND_MSG_PUB.initialize;
END IF;

--  Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;


-- obtain rebuildable information
if p_object_id is null then
    if p_serial_number is null
    or p_inventory_item_id is null
    or p_organization_id is null then
            FND_MESSAGE.SET_NAME('INV', 'INV_FIELD_INVALID');
            FND_MESSAGE.SET_TOKEN('ENTITY1', 'p_serial_number');
            FND_MSG_PUB.ADD;
	    l_return_status := 'E';
            RAISE FND_API.G_EXC_ERROR;
    else
        l_serial_number := p_serial_number;
        l_inventory_item_id := p_inventory_item_id;
        l_organization_id := p_organization_id;

	begin
		select gen_object_id into l_object_id
    		from mtl_serial_numbers
		where serial_number = p_serial_number
		and inventory_item_id = p_inventory_item_id
		and current_organization_id = p_organization_id;
	exception
		when others then
		     FND_MESSAGE.SET_NAME('INV', 'INV_EAM_GEN_INVALID_OBJECT');
            	     FND_MSG_PUB.ADD;
	    	     l_return_status := 'E';
            	     RAISE FND_API.G_EXC_ERROR;
	end;
    end if;
else

    if (p_serial_number is null)
    or (p_inventory_item_id is null)
    or (p_organization_id is null) then

	begin
	        select serial_number, inventory_item_id, current_organization_id
	        into l_serial_number, l_inventory_item_id, l_organization_id
	        from mtl_serial_numbers where
	        gen_object_id = p_object_id;

	exception
		when others then
		     FND_MESSAGE.SET_NAME('INV', 'INV_EAM_GEN_INVALID_OBJECT');
            	     FND_MSG_PUB.ADD;
	    	     l_return_status := 'E';
            	     RAISE FND_API.G_EXC_ERROR;
	end;
    else
        l_serial_number := p_serial_number;
        l_inventory_item_id := p_inventory_item_id;
        l_organization_id := p_organization_id;
    end if;

    l_object_id := p_object_id;
end if;



		if p_subinventory is null then
			begin
				select current_subinventory_code into l_subinventory
    				from mtl_serial_numbers
    				where serial_number = l_serial_number and
          			inventory_item_id = l_inventory_item_id and
          			current_organization_id = l_organization_id;
			exception
				when others then
				   l_return_status := 'E';
				   FND_MESSAGE.SET_NAME('EAM', 'EAM_NO_SUBINV_SPECIFIED');
				   FND_MSG_PUB.ADD;
				   RAISE FND_API.G_EXC_ERROR;
			end;
		else
    			l_subinventory := p_subinventory;
		end if;

		if p_locator_id is null then
			begin
				select current_locator_id into l_locator_id
    				from mtl_serial_numbers
    				where serial_number = l_serial_number and
          			inventory_item_id = l_inventory_item_id and
          			current_organization_id = l_organization_id;

			exception
				when others then
					null;
			end;
		else
    			l_locator_id := p_locator_id;
		end if;


-- genealogy update in future is not allowed
-- This restriction has been put in place because eventhough the date
-- of transaction is future, the status of the item is changed immediately

if p_end_date_active is not null and p_end_date_active > sysdate then
   l_return_status := 'E';
   FND_MESSAGE.SET_NAME('EAM', 'EAM_REBUILD_FUTURE_TXN');
   FND_MSG_PUB.ADD;
   RAISE FND_API.G_EXC_ERROR;
else

-- obtain the offset account id from user-defined EAM parameters
    begin
        select maintenance_offset_account into l_dist_acct_id
        from wip_eam_parameters
        where organization_id = l_organization_id;

    exception
    when others then
	FND_MESSAGE.SET_NAME('EAM', 'EAM_NO_OFFSET_ACCOUNT');
   	FND_MSG_PUB.ADD;
	RAISE FND_API.G_EXC_ERROR;
    end;

-- call the Transaction processing API
-- if API returns success, call the inventory genealogy API
    eam_transactions_pvt.process_eam_txn(
                       p_subinventory => l_subinventory,
                       p_serial_number => l_serial_number,
		       p_locator_id => l_locator_id,
                       p_organization_id => l_organization_id,
                       p_inventory_item_id => l_inventory_item_id,
                       p_dist_acct_id => l_dist_acct_id,
                       p_transaction_type_id => 42,
                       p_transaction_quantity => 1,
                       p_transaction_action_id => 27,
                       p_transaction_source_type_id => 13,
                       x_errCode => l_errCode,
                       x_msg_count => l_msg_count,
                       x_msg_data => l_msg_data,
                       x_return_status => l_return_status,
                       x_statement => l_statement);
    begin
	select last_transaction_id
    	into l_txn_id
    	from mtl_serial_numbers
    	where serial_number = l_serial_number;
--    dbms_output.put_line('got here 3');
    exception
	when others then
	   RAISE FND_API.G_EXC_ERROR;
    end;
end if;

if l_return_status = 'S' then
--dbms_output.put_line('got here 4');
    FND_MSG_PUB.initialize;
    inv_genealogy_pub.update_genealogy(
     p_api_version                   => l_api_version
 ,   p_object_type                   => 2
 ,   p_object_number                 => l_serial_number
 ,   p_inventory_item_id	         => l_inventory_item_id
 ,   p_org_id			             => l_organization_id
 ,   p_genealogy_origin              => 3
 ,   p_genealogy_type                => 5
 ,   p_end_date_active               => p_end_date_active
 ,   p_update_txn_id                 => l_txn_id
 ,   x_return_status                 => l_return_status
 ,   x_msg_count                     => l_msg_count
 ,   x_msg_data                      => l_msg_data);

 if (l_return_status = 'E') or (l_return_status = 'U') then
    raise FND_API.G_EXC_ERROR;
 end if;

 else
    raise FND_API.G_EXC_ERROR;
 end if;

if p_commit = FND_API.G_TRUE then
    commit;
end if;

 exception
 WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO eam_rebuild_genealogy;
   	x_return_status := l_RETURN_STATUS;
    FND_MSG_PUB.Count_And_Get
    (  	p_encoded			=> 		FND_API.G_FALSE,
    	p_count         	=>      x_msg_count     	,
        p_data          	=>      x_msg_data
    );
 WHEN OTHERS THEN
	ROLLBACK TO eam_rebuild_genealogy;
   	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
    (  	p_encoded			=> 		FND_API.G_FALSE,
    	p_count         	=>      x_msg_count     	,
        p_data          	=>      x_msg_data
    );

end update_rebuild_genealogy;

end eam_rebuild_genealogy;

/
