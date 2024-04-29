--------------------------------------------------------
--  DDL for Package Body EAM_ASSET_NUM_IMPORT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ASSET_NUM_IMPORT_PUB" as
/* $Header: EAMPANIB.pls 120.10.12010000.3 2010/01/05 03:28:46 jgootyag ship $ */
 -- Start of comments
 -- API name : import_genealogy
 -- Type     : Public
 -- Function :
 -- Pre-reqs : None.
 -- FILENAME : EAMPANIB.pls
 -- DESCRIPTION
 --   PL/SQL body for package EAM_ASSET_NUM_IMPORT_PUB. This public API imports
 --   assets and their extensible attributes into MTL_SERIAL_NUMBERS and
 --   MTL_EAM_ASSET_ATTR_VALUES. The import process is controlled by two
 --   fields: SCOPE and MODE. These fields exist at the row level.
 --   SCOPE implies what you want to import:
 --     0: Import both ASSETS and their EXTENSIBLE ATTRIBUTES
 --     1: Import only ASSETS
 --     2: Import only EXTENSIBLE ATTRIBUTES
 --   MODE implies whether to create new records or update existing ones:
 --     0: CREATE new records
 --     1: UPDATE existing records
 --   Further since this is the worker API for importing assets, the parameter
 --   p_interface_group_id controls which records the worker will process. The
 --   parameter p_purge_option specifies whether to delete successfully imported
 --   records from the interface table after the worker completes.
 -- HISTORY
 --   02-Aug-01  Created, Deepak Gupta, Anju Gupta
 --   07-Aug-01  Deepak Gupta:  Dropped the dependent asset flag
 --   02-Jan-02  Chris Ng: Fixed bug 2167988
 --   08-Jan-02  Chris Ng: Fixed bug 2175340
 --   11-Jan-02  Chris Ng: Fixed bug 2180770.
 --   15-Jan-02  Chris Ng: Fixed bug 2184016.
 --   15-Jan-02  Chris Ng: Fixed bugs 2184517, 2184498, 2184448, 2184533,
 --                                   2184906.
 --   16-Jan-02  Chris Ng: Fixed bug 2185999.
 --   13-Mar-03  Himal Karmacharya Fixed bug 2850128
 -- End of comments


  g_pkg_name    CONSTANT VARCHAR2(30):= 'EAM_ASSET_NUM_IMPORT_PUB';



 --Converts boolean to varchar2

  function bool2char(
    p_bool            BOOLEAN
  ) return varchar2 is
  begin
    if p_bool then
      return 'TRUE';
    elsif (not p_bool) then
      return 'FALSE';
    else
      return 'NULL';
    end if;
  end bool2char;

  -- checks whether this id (a number only field) is to be skipped (in either mode)
  function skip(
    p_id              NUMBER,
    p_import_mode     NUMBER
  ) return boolean is
  begin
    if (p_import_mode = 0) then
      return (p_id  is null);
    else --it must be update mode (1)
      return (p_id = FND_API.G_MISS_NUM);
    end if;
  end skip;

  -- checks whether this code (a char only field) is to be skipped (in either mode)
  function skip(
    p_code            VARCHAR2,
    p_import_mode     NUMBER
  ) return boolean is
  begin
    if (p_import_mode = 0) then
      return (p_code  is null);
    else --it must be update mode (1)
      return (p_code = FND_API.G_MISS_CHAR);
    end if;
  end skip;

  -- checks whether this id/code combination field is to be skipped (in update mode)
  function skip (
    p_id               IN OUT NOCOPY NUMBER,
    p_code                    VARCHAR2,
    p_import_mode             NUMBER
  ) return boolean is
    l_skip_update             BOOLEAN := false;
  begin
    if (p_import_mode = 0) then
      l_skip_update := ((p_id is null) and (p_code is null));
    else --it must be update mode (1)
      l_skip_update := (((p_id is not null) and (p_id = FND_API.G_MISS_NUM)) OR
                        ((p_id is null) and (p_code is not null) and (p_code = FND_API.G_MISS_CHAR)));
      --if id null, set to g_miss_num so that update (looks only at ids) works
      if (l_skip_update) then
        p_id := FND_API.G_MISS_NUM;
      end if;
    end if;
    return l_skip_update;
  end skip;

  -- Updates the current table row with the error message and error code
  procedure update_row_error (
    p_error_code      NUMBER,
    p_error_message   VARCHAR2,
    p_asset_rec       MTL_EAM_ASSET_NUM_INTERFACE%ROWTYPE
  ) is
  begin
    UPDATE MTL_EAM_ASSET_NUM_INTERFACE SET
      process_flag = 'E',
      error_code = p_error_code,
      error_message = p_error_message
    WHERE interface_header_id = p_asset_rec.interface_header_id;

    -- 2002-01-02: chrng: To fix bug 2167988, also flag the corresponding
    -- rows in Asset Attribute interface table as error
    UPDATE    MTL_EAM_ATTR_VAL_INTERFACE      meavi
    SET       meavi.error_number = 9999,
              meavi.process_status = 'E',
              meavi.error_message = 'Import of corresponding row in MTL_EAM_ASSET_NUM_INTERFACE failed'
    WHERE     meavi.interface_header_id = p_asset_rec.interface_header_id
    AND       meavi.process_status = 'P';

  end update_row_error;

  -- Bug # 3601150
  -- Updates the remaining row in the batch with status as pending
  procedure update_remaining_row_status (p_batch_id NUMBER) is
  begin
    UPDATE MTL_EAM_ASSET_NUM_INTERFACE
    SET    process_flag = 'P',
           interface_group_id = NULL
    WHERE  batch_id = p_batch_id
     AND   process_flag = 'R';
  end update_remaining_row_status;

  -- Updates the current table row with the calculated values for derived
  -- fields such as code from value, value from code, etc.
  procedure update_row_calculated_values (
    p_asset_rec MTL_EAM_ASSET_NUM_INTERFACE%ROWTYPE
  ) is

  l_api_name	      constant varchar2(30)  := 'update_row_calculated_values';

  l_module             varchar2(200);
  l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
  l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level;
  l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
  l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

  begin

    if (l_ulog) then
             l_module  := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
    end if;

    if (l_slog) then
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
               'Updating interface table with calculated values');
     end if;

    update mtl_eam_asset_num_interface set
      owning_department_code = p_asset_rec.owning_department_code,
      owning_department_id = p_asset_rec.owning_department_id,
      asset_criticality_code = p_asset_rec.asset_criticality_code,
      asset_criticality_id = p_asset_rec.asset_criticality_id,
      fa_asset_number = p_asset_rec.fa_asset_number,
      fa_asset_id = p_asset_rec.fa_asset_id,
      location_codes = p_asset_rec.location_codes,
      eam_location_id = p_asset_rec.eam_location_id,
      current_status = p_asset_rec.current_status,
      prod_organization_id = p_asset_rec.prod_organization_id,
      prod_organization_code = p_asset_rec.prod_organization_code
    where interface_header_id = p_asset_rec.interface_header_id;

    --Start 8579859
    update mtl_eam_asset_num_interface set
    instance_number = (select instance_number from csi_item_instances
                       where serial_number = p_asset_rec.serial_number and
                       last_vld_organization_id =p_asset_rec.CURRENT_ORGANIZATION_ID  and
                       inventory_item_id =p_asset_rec.inventory_item_id)
    where interface_header_id = p_asset_rec.interface_header_id;

    -- End 8579859

  end update_row_calculated_values;
-- procedure to insert or update genealogy for PN locations
-- should only be called if pn_location_id is not null

  procedure pn_genealogy_change (
      p_pn_location_id in number,
      p_serial_number in varchar2,
      p_inventory_item_id in number,
      p_current_organization_id in number,
      p_start_date_active in date,
      p_end_date_active in date,
      p_parent_location_id in number,
      p_parent_in_eam in varchar2,
      p_parent_serial_number in varchar2,
      p_parent_inventory_item_id in number,
      p_import_mode in number,
      x_return_status out NOCOPY varchar2,
      x_msg_count out NOCOPY number,
      x_msg_data out NOCOPY varchar2
) is

        l_pn_installed varchar2(1) ;
        l_gen_object_id number;
        l_pn_gen_mode number;
        l_msn_status number;
	l_end_date_active date;
        l_hr_exists varchar2(1);
        l_parent_object_id number;
        l_return_status varchar2(1);
        l_msg_data varchar2(2000);
        l_msg_count number;

	l_api_name	    CONSTANT VARCHAR2(30)  := 'pn_genealogy_change';

	l_module            varchar2(200);
	l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
	l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level;
	l_eLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_error >= l_log_level;
	l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
	l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

  begin
    if (l_ulog) then
             l_module  := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
    end if;

    l_pn_installed  := 'N';
    l_return_status := 'S';

    SAVEPOINT pn_eam_genealogy;

	begin
		select status into l_pn_installed
		from fnd_product_installations
		where application_id = 240;
	exception
		when no_data_found then
		l_pn_installed := 'N';
	end;

	if l_pn_installed = 'I' then

		if p_end_date_active >= fnd_date.canonical_to_date('4712/12/31') then
			l_end_date_active := null;
		else
			l_end_date_active := p_end_date_active;
		end if;

		if p_parent_location_id is not null then

			if p_parent_in_eam = 'Y' then

				SELECT current_status, gen_object_id
				INTO l_msn_status, l_gen_object_id
				FROM mtl_serial_numbers
				WHERE serial_number = p_serial_number
        			and current_organization_id = p_current_organization_id
				and inventory_item_id = p_inventory_item_id;

				SELECT gen_object_id INTO l_parent_object_id
				FROM mtl_serial_numbers
				WHERE serial_number = p_parent_serial_number
				and inventory_item_id = p_parent_inventory_item_id;


                		if p_import_mode = 0 then
                    			l_pn_gen_mode := 0;
                		else
                    			l_hr_exists := 'N';

                    			begin
    	       					select 'Y' into l_hr_exists from dual
	       	       				where exists
		      	       			(select * from mtl_object_genealogy
						where object_id = l_gen_object_id);
                    			exception when no_data_found then
                        			l_hr_exists := 'N';
                    			end;

				     	if l_hr_exists <> 'Y' then
					    	l_pn_gen_mode := 0;
    					else
                    				l_pn_gen_mode := 0;

    						declare
        						CURSOR genealogy_entry_cur IS
            						SELECT  mog.start_date_active start_date_active,
								mog.end_date_active
								end_date_active, msn.serial_number
								parent_serial_number
            						FROM mtl_object_genealogy mog, mtl_serial_numbers msn
            						WHERE mog.object_id = l_gen_object_id
							and msn.gen_object_id = mog.parent_object_id
							and mog.genealogy_type = 5;

	        				begin


						        FOR i IN genealogy_entry_cur LOOP
						          IF i.end_date_active IS NOT NULL THEN
				        		    IF l_end_date_active IS NOT NULL THEN

    							      	if ((p_start_date_active = i.start_date_active)
	       							  and (l_end_date_active = i.end_date_active)) then
		      							l_pn_gen_mode := 2;
			                  			elsif ((p_start_date_active <= i.start_date_active)
				                  				AND (l_end_date_active >= i.start_date_active))
                 							OR ((p_start_date_active >= i.start_date_active)
	                     							AND (l_end_date_active <= i.end_date_active))
		        						OR ((p_start_date_active <= i.start_date_active)
						      		                AND (l_end_date_active >= i.end_date_active))

							                OR ((p_start_date_active <= i.end_date_active)
                     								AND (l_end_date_active >= i.end_date_active)) THEN

            								inv_genealogy_pub.delete_eam_row(
                                                            			p_api_version=>1.0,
                                                            			p_object_id => l_gen_object_id,
                                                            			p_start_date_active=>i.start_date_active,
                                                            			p_end_date_active=>i.end_date_active,
                                                            			x_return_status => l_return_status,
                                                            			x_msg_count => l_msg_count,
                                                            			x_msg_data => l_msg_data);
			             						l_pn_gen_mode := 0;
           				      			END IF;
        				    		    ELSE
				              			IF (p_start_date_active <= i.end_date_active) THEN
       									inv_genealogy_pub.delete_eam_row(
                                                    				p_api_version=>1.0,
                                                    				p_object_id => l_gen_object_id,
                                                    				p_start_date_active=>i.start_date_active,
                                                    				p_end_date_active=>i.end_date_active,
                                                    				x_return_status => l_return_status,
                                                    				x_msg_count => l_msg_count,
                                                    				x_msg_data => l_msg_data);

        									l_pn_gen_mode := 0;
        				      			END IF;
            						    END IF;
          				  		ELSE
            						    IF l_end_date_active IS NULL THEN
        							if p_start_date_active = i.start_date_active then
		          						l_pn_gen_mode := 2;
				        			else
               								inv_genealogy_pub.delete_eam_row(
                                                            			p_api_version=>1.0,
                                                            			p_object_id => l_gen_object_id,
                                                            			p_start_date_active=>i.start_date_active,
                                                            			p_end_date_active=>i.end_date_active,
                                                            			x_return_status => l_return_status,
                                                            			x_msg_count => l_msg_count,
                                                            			x_msg_data => l_msg_data);

									l_pn_gen_mode := 0;
		      					     	END IF;

            						     ELSE
        							IF (p_start_date_active = i.start_date_active) THEN
		          						l_pn_gen_mode := 1;
				        			ELSIF (p_start_date_active >= i.start_date_active)
	                  		   				OR (l_end_date_active >= i.start_date_active) THEN
									inv_genealogy_pub.delete_eam_row(
										p_api_version=>1.0,
										p_object_id => l_gen_object_id,
										p_start_date_active=>i.start_date_active,
										p_end_date_active=>i.end_date_active,
										x_return_status => l_return_status,
										x_msg_count => l_msg_count,
										x_msg_data => l_msg_data);

							     	        l_pn_gen_mode := 0;
            				        		END IF;
              						     END IF;
                          				END IF;
         					END LOOP;
                    			end;
                		END IF;
                	END IF;

			if (l_pn_gen_mode = 0) then
    	            		inv_genealogy_pub.insert_genealogy(
                        	p_api_version              => 1.0,
                 		p_object_type              => 2,
                 		p_parent_object_type       => 2,
                 		p_object_number            => p_serial_number,
                 		p_inventory_item_id        => p_inventory_item_id,
                 		p_org_id                   => p_current_organization_id,
                 		p_parent_object_id         => l_parent_object_id,
                 		p_genealogy_origin         => 3,
                 		p_genealogy_type           => 5,
                 		p_start_date_active        => p_start_date_active,
                 		p_end_date_active          => l_end_date_active,
                 		x_return_status            => l_return_status,
                 		x_msg_count                => l_msg_count,
                 		x_msg_data                 => l_msg_data);

                    		IF NOT  l_return_status = fnd_api.g_ret_sts_success THEN
                        		RAISE fnd_api.g_exc_error;
                    		end if;

			elsif (l_pn_gen_mode = 1) then
		                inv_genealogy_pub.update_genealogy(
                		p_api_version              => 1.0,
                 		p_object_type              => 2,
                 		p_object_number            => p_serial_number,
                 		p_inventory_item_id        => p_inventory_item_id,
                 		p_org_id                   => p_current_organization_id,
                 		p_genealogy_origin         => 3,
                 		p_genealogy_type           => 5,
                 		p_end_date_active          => l_end_date_active,
                 		x_return_status            => l_return_status,
                 		x_msg_count                => l_msg_count,
                 		x_msg_data                 => l_msg_data);

                		IF NOT  l_return_status = fnd_api.g_ret_sts_success THEN
                    			RAISE fnd_api.g_exc_error;
                		end if;
            		END IF;

		end if;
    	end if;
end if;

EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO pn_eam_genealogy;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO pn_eam_genealogy;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO pn_eam_genealogy;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

end pn_genealogy_change;



  -- The worker procedure to import assets.
  -- Note that in update mode, if id is null, then it does not mean that we update
  -- with null, instead we see the code if code is also null then we update with
  -- null, else if it is g_miss_num or g_miss_char we ignore it, else we update with
  -- new id got from the code. If id is not null, we straightaway update id, get code.
  -- In insert mode, no g_miss_num and g_miss_char values are expected. First see id
  -- If id is null, then see code, if both are null, insert null.
  PROCEDURE import_asset_numbers
  (
    errbuf                      OUT NOCOPY     VARCHAR2,
    retcode                     OUT NOCOPY     NUMBER,
    p_interface_group_id        IN      NUMBER,
    p_purge_option              IN      VARCHAR2
   )  IS

      l_api_name                CONSTANT VARCHAR2(30) := 'import_asset_numbers';
      l_api_version             CONSTANT NUMBER       := 1.0;
      l_full_name               CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
      l_stmt_num                NUMBER;
      l_error_message           VARCHAR2(2000);
      l_error_code              NUMBER;
      no_rows_updated           EXCEPTION;

      -- 2002-01-11: chrng: handle attribute import failure separately
      attr_import_failed	EXCEPTION;

      l_application_id          CONSTANT    NUMBER       := 401;
      l_application_code        CONSTANT    VARCHAR2(3)  := 'INV';
      l_number1                 NUMBER;
      l_varchar2000             VARCHAR2(2000);
      l_return_status           VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_count                   NUMBER;
      l_data                    VARCHAR2(240);
      l_object_id               NUMBER;
        l_msg_data varchar2(2000);
        l_msg_count number;

	l_pn_exists_in_eam varchar2(1) := 'N';
        l_parent_location_id number;
        l_parent_in_eam varchar2(1) := 'N';
	l_parent_serial_number varchar2(30);
	l_parent_inventory_item_id number;

        l_start_date_active date;
        l_end_date_active date;

      l_category_set_id         NUMBER := -1;
      l_is_create_asset         BOOLEAN;
      l_serial_rowid		        ROWID;
      l_created_rowid           VARCHAR2(100);
	l_conc_status             BOOLEAN;
	    l_equipment_type          NUMBER;
	    l_skip_field1           BOOLEAN := false;
	    l_skip_field2           BOOLEAN := false;
	    l_skip_field3           BOOLEAN := false;
	    l_skip_all                BOOLEAN := false;
	    l_prod_organization_id    MTL_EAM_ASSET_NUM_INTERFACE.prod_organization_id%TYPE := NULL;
	    l_equipment_item_id       MTL_EAM_ASSET_NUM_INTERFACE.equipment_item_id%TYPE := NULL;
	    l_eqp_serial_number       MTL_EAM_ASSET_NUM_INTERFACE.eqp_serial_number%TYPE := NULL;

      l_prod_equipment_type      NUMBER;
      l_asset_criticality_code   VARCHAR2(30);

	l_gen_object_id			NUMBER;
	-- Returned parameters from calling the Maintenance Object Instantiation API
	l_x_moi_return_status		VARCHAR2(1);
	l_x_moi_msg_count		NUMBER;
	l_x_moi_msg_data		VARCHAR2(20000);

	l_module           varchar2(200);
	l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
	l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level;
	l_exLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_exception >= l_log_level;
        l_eLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_error >= l_log_level;
	l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
	l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;

      CURSOR asset_num_cur IS
        SELECT  *
        FROM  MTL_EAM_ASSET_NUM_INTERFACE
        WHERE interface_group_id = p_interface_group_id
        AND process_flag = 'R'
        ORDER BY import_mode, import_scope, interface_header_id;

      CURSOR PROPERTY_CUR(child1 in number, parent1 in number) IS
        SELECT  pn_location_id, serial_number, inventory_item_id
        FROM  CSI_ITEM_INSTANCES
        WHERE pn_location_id in (child1, parent1);

      asset_rec MTL_EAM_ASSET_NUM_INTERFACE%ROWTYPE;


  BEGIN
  --dbms_output.enable(100000);
   if (l_ulog) then
             l_module  := 'eam.plsql.'|| l_full_name;
    end if;

  if (l_plog) then
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
        'Entering ' || l_full_name);
  end if;


  -- Standard Start of API savepoint
  l_stmt_num    := 10;
  SAVEPOINT import_asset_num_interface_pub;

  l_stmt_num    := 20;

  -- Initialize message list
  fnd_msg_pub.initialize;

  l_stmt_num    := 40;

  -- Initialize API return status to success
--  l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL', l_error_message);

  l_stmt_num    := 50;
  -- API starts
  l_error_code := 9999;
  l_error_message := 'Unknown Exception';

  if (l_slog) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'');

       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
              'Start Worker for Asset Import. Time now is ' ||
	      to_char(sysdate, 'Month DD, YYYY HH24:MI:SS'));

       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'');
  end if;



   if (l_slog) then FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
     'Processing interface group ' || p_interface_group_id ||
     ' with purge option ' || p_purge_option);
   end if;

  --store the category set id for eAM for use in every loop
  -- 2002-01-08: chrng: Use category_set_id directly, see bug 2175340.
  l_category_set_id := 1000000014;

  if (l_slog) then FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
     'Opening cursor for records in interface table');
  end if;

  open asset_num_cur;
  LOOP
  BEGIN --this begin is needed for checking exception in every loop
    SAVEPOINT LOOP_START;


    if (l_slog) then
	      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
		'___________________________________________________________');
    end if;

    FETCH asset_num_cur INTO asset_rec;
    EXIT WHEN asset_num_cur%NOTFOUND;


    if (l_slog) then
	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
	      'Processing Record with HEADER ID: '|| asset_rec.interface_header_id);

	FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
           '  for ORGANIZATION (Id/Code): ' ||
           asset_rec.current_organization_id || '/' || asset_rec.organization_code ||
           ', ITEM ID: ' || asset_rec.inventory_item_id ||
           ', SERIAL: ' || asset_rec.serial_number);
    end if;


    if (l_slog) then
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
		'Record will be processed with SCOPE: '
	        || asset_rec.import_scope || ', MODE: ' || asset_rec.import_mode);
    end if;


     if asset_rec.pn_location_id is not null then

	l_error_code := 170;
	l_error_message := 'Error while validating Property Manager row. The Property Manager location already exists in EAM';

	begin

		select active_start_date, active_end_date, parent_location_id
		into l_start_date_active, l_end_date_active, l_parent_location_id
		from pn_locations_all
		where location_id = asset_rec.pn_location_id
            	and active_start_date <= sysdate
            	and active_end_date >= sysdate;

		l_pn_exists_in_eam := 'N';
		l_parent_in_eam := 'N';
		l_parent_serial_number := null;
		l_parent_inventory_item_id := null;

		for l_property_rec in  property_cur(asset_rec.pn_location_id, l_parent_location_id) loop

    			EXIT WHEN property_cur%NOTFOUND;

			if l_property_rec.pn_location_id = asset_rec.pn_location_id then
				l_pn_exists_in_eam := 'Y';
			else

				l_parent_in_eam := 'Y';
				l_parent_serial_number := l_property_rec.serial_number;
				l_parent_inventory_item_id := l_property_rec.inventory_item_id;
			end if;
		end loop;

    		if property_cur%isopen then
    		   close property_cur;
    		end if;

	exception
		when no_data_found then
			raise no_data_found;
	end;

    end if;


     --Pass Location Id when location Codes are given
     -- Added for Bug # 6271101
	if ((asset_rec.location_codes is not null) and (asset_rec.eam_location_id is null))  then
		begin
			  select location_id into asset_rec.eam_location_id
			  from mtl_eam_locations
			  where location_codes = asset_rec.location_codes
			  and organization_id = asset_rec.current_organization_id;
		exception
			when no_data_found then
				raise no_data_found;
		end;
	end if;
      --End Validate location

	if ((asset_rec.prod_organization_code is not null) and (asset_rec.prod_organization_id is null))  then
		begin
			  select organization_id into asset_rec.prod_organization_id
			  from mtl_parameters
			  where organization_code = asset_rec.prod_organization_code;
		exception
			when no_data_found then
				raise no_data_found;
		end;
	end if;

    --if mode = 0, create row
    IF asset_rec.import_mode = 0 THEN

      if (l_slog) then
	    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
		 'Now inserting asset...');
      end if;

      if asset_rec.pn_location_id is not null then

	if l_pn_exists_in_eam = 'Y' then
			raise no_data_found;
	end if;
      end if;


      eam_assetnumber_pub.Insert_Asset_Number
	(
          p_api_version  =>  l_api_version,

          x_object_id     => l_object_id,
          x_return_status    => l_return_status,
          x_msg_count   => l_count,
          x_msg_data    => l_data,
          p_inventory_item_id  => asset_rec.inventory_item_id,
          p_serial_number   => asset_rec.serial_number,
          p_instance_number   => asset_rec.instance_number,
          p_current_status    => asset_rec.current_status,
          p_descriptive_text  => asset_rec.descriptive_text,
          p_current_organization_id => asset_rec.current_organization_id,
          p_wip_accounting_class_code  => asset_rec.wip_accounting_class_code,
          p_maintainable_flag    => asset_rec.maintainable_flag,
          p_owning_department_id  => asset_rec.owning_department_id,
          p_network_asset_flag   => nvl(asset_rec. network_asset_flag,'N'),
          p_fa_asset_id   => asset_rec. fa_asset_id,
          p_pn_location_id       => asset_rec.pn_location_id,
          p_eam_location_id      => asset_rec.eam_location_id,
          p_asset_criticality_code  => to_char(asset_rec.asset_criticality_id),
          p_category_id  =>  asset_rec.category_id,
          p_prod_organization_id  => asset_rec.prod_organization_id,
          p_equipment_item_id  => asset_rec.equipment_item_id,
          p_eqp_serial_number  =>   asset_rec.eqp_serial_number,
	  p_active_start_date  =>  asset_rec.active_start_date,
	  p_active_end_date  =>  asset_rec.active_end_date,
	  p_operational_log_flag	=> asset_rec.operational_log_flag,
	  p_checkin_status	=> asset_rec.checkin_status,
	  p_supplier_warranty_exp_date => asset_rec.supplier_warranty_exp_date
      );

      IF NOT  l_return_status = fnd_api.g_ret_sts_success THEN
        l_error_code := 150;

        l_error_message := 'Asset insertion failed with return status: '
            || l_return_status || ' and message: ' || l_data;


	if (l_elog) then
	         FND_LOG.STRING(FND_LOG.LEVEL_ERROR, l_module,l_error_message);
        end if;

        RAISE NO_DATA_FOUND;
      ELSE
	   if (l_slog) then
	       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
			'Asset was inserted.');
           end if;
      END IF;

      -- pn integration changes
      if asset_rec.pn_location_id is not null then
	        l_error_code := 180;
      		l_error_message := 'Failed while trying to insert genealogy for PN';

        	pn_genealogy_change (
            		p_pn_location_id => asset_rec.pn_location_id,
            		p_serial_number => asset_rec.serial_number,
            		p_inventory_item_id => asset_rec.inventory_item_id,
            		p_current_organization_id => asset_rec.current_organization_id,
			p_start_date_active => l_start_date_active,
			p_end_date_active => l_end_date_active,
			p_parent_location_id => l_parent_location_id,
			p_parent_in_eam => l_parent_in_eam,
			p_parent_serial_number => l_parent_serial_number,
			p_parent_inventory_item_id => l_parent_inventory_item_id,
            		p_import_mode => asset_rec.import_mode,
            		x_return_status => l_return_status,
            		x_msg_count => l_msg_count,
            		x_msg_data => l_msg_data);

		if l_return_status <> 'S' then
			raise no_data_found;
    		end if;
      end if;
    END IF;

    -- if mode = 1 update record
    IF asset_rec.import_mode = 1 THEN

      if (l_slog) then
	      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
               'Now updating asset with ROWID: ' || l_serial_rowid || '...');
      end if;

        -- 2002-01-16: chrng: Fixed bug 2185999.
        -- If asset_criticality_id is FND_API.G_MISS_NUM,
        -- then asset_criticality_code should be FND_API.G_MISS_CHAR
      IF asset_rec.asset_criticality_id = FND_API.G_MISS_NUM
        THEN
           l_asset_criticality_code := FND_API.G_MISS_CHAR;
      ELSE
           l_asset_criticality_code := TO_CHAR(asset_rec.asset_criticality_id);
      END IF;


      -- pn integration changes
      if asset_rec.pn_location_id is not null then
	        l_error_code := 180;
      		l_error_message := 'Failed while trying to insert/update genealogy for PN';

        	pn_genealogy_change (
            		p_pn_location_id => asset_rec.pn_location_id,
            		p_serial_number => asset_rec.serial_number,
            		p_inventory_item_id => asset_rec.inventory_item_id,
            		p_current_organization_id => asset_rec.current_organization_id,
			p_start_date_active => l_start_date_active,
			p_end_date_active => l_end_date_active,
			p_parent_location_id => l_parent_location_id,
			p_parent_in_eam => l_parent_in_eam,
			p_parent_serial_number => l_parent_serial_number,
			p_parent_inventory_item_id => l_parent_inventory_item_id,
            		p_import_mode => asset_rec.import_mode,
            		x_return_status => l_return_status,
            		x_msg_count => l_msg_count,
            		x_msg_data => l_msg_data);

		if l_return_status <> 'S' then
			raise no_data_found;
    		end if;
      end if;

      eam_assetnumber_pub.update_asset_number
      (
          p_api_version  =>  l_api_version,
          x_return_status    => l_return_status,
          x_msg_count   => l_count,
          x_msg_data    => l_data,

          p_inventory_item_id  => asset_rec.inventory_item_id,
	  p_serial_number => asset_rec.serial_number,
	  p_instance_number => asset_rec.instance_number,
	  p_current_organization_id => asset_rec.current_organization_id,
          p_descriptive_text  => asset_rec.descriptive_text,
          p_category_id  =>  asset_rec.category_id,
          p_prod_organization_id  => asset_rec. prod_organization_id,
          p_equipment_item_id  => asset_rec.equipment_item_id,
          p_eqp_serial_number  =>   asset_rec.eqp_serial_number,
          p_pn_location_id       => asset_rec.pn_location_id,
          p_eam_location_id      => asset_rec.eam_location_id,
          p_fa_asset_id   => asset_rec. fa_asset_id,
          p_asset_criticality_code  => l_asset_criticality_code,
          p_wip_accounting_class_code  => asset_rec.wip_accounting_class_code,
          p_maintainable_flag    => asset_rec.maintainable_flag,
          p_network_asset_flag   => nvl(asset_rec. network_asset_flag,'N'),
          p_owning_department_id  => asset_rec.owning_department_id,
          p_current_status => asset_rec.current_status,
	  p_active_end_date => asset_rec.active_end_date,
	  p_operational_log_flag => asset_rec.operational_log_flag,
	  p_checkin_status => asset_rec.checkin_status,
	  p_supplier_warranty_exp_date => asset_rec.supplier_warranty_exp_date
      );


      IF NOT  l_return_status = fnd_api.g_ret_sts_success THEN
          l_error_code := 160;
          l_error_message := 'Asset update failed with return status: '
            || l_return_status || ' and message: ' || l_data;

        if (l_elog) then
	     FND_LOG.STRING(FND_LOG.LEVEL_ERROR, l_module,l_error_message);
        end if;

	RAISE NO_DATA_FOUND;
      ELSE
        if (l_slog) then
	      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
                 'Asset was updated');
        end if;

      END IF;
    END IF;

      --update base table with the latest fields in record asset_rec
      if (p_purge_option = 'N' or asset_rec.import_scope <> 1) then
        update_row_calculated_values(asset_rec);
      end if;

    --Import Asset Extensible attributes
    IF (asset_rec.import_scope <> 1) THEN

       if (l_slog) then
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
              'Now importing Attributes...');
      end if;

      EAM_ASSET_ATTR_IMPORT_PVT.import_asset_attr_values(
        p_api_version => 1.0,
            p_interface_header_id => asset_rec.interface_header_id,
            p_import_mode => asset_rec.import_mode,
            p_purge_option=>p_purge_option,
            x_return_status => l_return_status,
            x_msg_count => l_count,
            x_msg_data =>  l_data
      );
      IF NOT  l_return_status = fnd_api.g_ret_sts_success THEN
        l_error_code := 300;

        -- 2002-01-11: chrng: The following message is long and it causes an error.

        l_error_message := 'Failed because Extensible Attributes import failed';

        if (l_elog) then
	  FND_LOG.STRING(FND_LOG.LEVEL_ERROR, l_module,l_error_message);
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR, l_module,'Import attribute return status= ' || l_return_status);
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR, l_module,'Import attribute msg count= ' || l_count);
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR, l_module,'Import attribute msg data = ' || l_data);
        end if;

        RAISE attr_import_failed;

      ELSE

	if (l_slog) then
	     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
                 'Attributes were imported.');
        end if;

      END IF;
    END IF;
    --End of Import Asset Extensible attributes

    --set process_flag to 'S'. If it has come to this point, it succeeded
    UPDATE  MTL_EAM_ASSET_NUM_INTERFACE
    SET   process_flag = 'S'
    WHERE interface_header_id = asset_rec.interface_header_id;
    COMMIT;

     if (l_slog) then
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,
              'Transaction Commited.');
     end if;

    --end validations if scope =0 or 1

    EXCEPTION
      -- 2002-01-11: chrng: Fixed bug 2180770, handle attr import failure separately
      WHEN attr_import_failed THEN

        DECLARE
           CURSOR  meavi_cur IS
           SELECT  interface_line_id,
                   application_id,
                   descriptive_flexfield_name,
                   application_column_name,
                   association_id,
                   process_status,
                   error_number,
                   error_message
           FROM    mtl_eam_attr_val_interface
           WHERE   interface_header_id = asset_rec.interface_header_id;

           TYPE meavi_tabtype IS TABLE OF meavi_cur%ROWTYPE
              INDEX BY BINARY_INTEGER;
           meavi_tab meavi_tabtype;

           i BINARY_INTEGER;

        BEGIN


	   if (l_exlog) then
	       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, l_module,
                     'ERROR: ' || l_error_code || ' - ' || l_error_message);
           end if;

           -- Save the error messages and other calculated columns in the MEAVI table
           FOR meavi_row IN meavi_cur
           LOOP
              meavi_tab(meavi_row.interface_line_id) := meavi_row;
           END LOOP;

           ROLLBACK to LOOP_START;


	   if (l_exlog) then
	       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, l_module,
                   'After attr import failed: Transaction Rolled back to LOOP_START.');
           end if;

           -- Update MEAVI with error messages
           i := meavi_tab.FIRST;
           LOOP
              EXIT WHEN i IS NULL;

              UPDATE  mtl_eam_attr_val_interface
              SET     application_id             = meavi_tab(i).application_id,
                      descriptive_flexfield_name = meavi_tab(i).descriptive_flexfield_name,
                      application_column_name    = meavi_tab(i).application_column_name,
                      association_id             = meavi_tab(i).association_id,
                      process_status             = meavi_tab(i).process_status,
                      error_number               = meavi_tab(i).error_number,
                      error_message              = meavi_tab(i).error_message
              WHERE   interface_line_id = meavi_tab(i).interface_line_id;

              i := meavi_tab.NEXT(i);
           END LOOP;

           -- Update MEANI with error messages
           UPDATE   MTL_EAM_ASSET_NUM_INTERFACE
           SET      process_flag = 'E',
                    error_code = l_error_code,
                    error_message = l_error_message
           WHERE    interface_header_id = asset_rec.interface_header_id;

           if (p_purge_option = 'N') then
              update_row_calculated_values(asset_rec);
           end if;

           COMMIT;


	   if (l_exlog) then
	      FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, l_module,
                   'After attr import failed: Transaction Commited');
           end if;

        END;

      WHEN NO_DATA_FOUND or no_rows_updated THEN

	if (l_exlog) then
	   FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, l_module,
              'ERROR: ' || l_error_code || ' - ' || l_error_message);
        end if;

	ROLLBACK to LOOP_START;

	if (l_exlog) then
           FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, l_module,
              'Transaction Rolled back to LOOP_START.');
        end if;

	update_row_error(l_error_code, l_error_message, asset_rec);
        if (p_purge_option = 'N') then
          update_row_calculated_values(asset_rec);
        end if;
        COMMIT;

	if (l_exlog) then
	     FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, l_module,
              'Transaction Commited.');
        end if;

	-- pn integration changes
	-- Bug # 3601150
	IF asset_rec.pn_location_id is not null then
	  update_remaining_row_status(asset_rec.batch_id);
          EXIT; --from cursor
	END IF;

        --dbms_output.put_line(g_msg);
      WHEN OTHERS THEN

	if (l_exlog) then
	    FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, l_module,
              'UNEXPECTED ERROR: ' || SQLERRM);
        end if;

        ROLLBACK to LOOP_START;

        if (l_exlog) then
	    FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, l_module,
              'Transaction Rolled back to LOOP_START.');
        end if;

        update_row_error(9999, l_varchar2000, asset_rec);
        if (p_purge_option = 'N') then
          update_row_calculated_values(asset_rec);
        end if;
        COMMIT;

        if (l_exlog) then
	     FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, l_module,
              'Transaction Commited.');
        end if;

        RAISE;
  END; --of nested BEGIN for exception. BEGIN was just after loop started
END LOOP; -- end of Cursor for loop
IF asset_num_cur%ISOPEN THEN
  CLOSE asset_num_cur;
END IF;
-- delete rows marked as success if purge option is true
IF p_purge_option = 'Y' THEN
  DELETE FROM MTL_EAM_ASSET_NUM_INTERFACE
  WHERE process_flag = 'S'
  and interface_group_id = p_interface_group_id;
END IF;

if (l_plog) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
              'Exiting ' || l_full_name);

     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module,
               'End Worker for Asset Import. Time now is ' ||
                to_char(sysdate, 'Month DD, YYYY HH24:MI:SS'));
end if;
l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL', l_error_message);

EXCEPTION
  WHEN OTHERS THEN
    l_error_message := 'UNEXPECTED ERROR IN OUTER BLOCK: ' || SQLERRM;
  	l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', l_error_message);

    if (l_exlog) then
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, l_module,l_error_message);
    end if;

    ROLLBACK;

    if (l_exlog) then
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, l_module,'Transaction Rolled back.');
    end if;

    IF asset_num_cur%ISOPEN THEN
      CLOSE asset_num_cur;
    END IF;
    -- delete rows marked as success if purge option is true
    IF p_purge_option = 'Y' THEN
      DELETE FROM MTL_EAM_ASSET_NUM_INTERFACE
      WHERE process_flag = 'S'
      and interface_group_id = p_interface_group_id;
    END IF;
    -- update all unprocessed records to errored status
    UPDATE MTL_EAM_ASSET_NUM_INTERFACE
    SET process_flag = 'E',
    error_message = l_error_message
    WHERE interface_group_id = p_interface_group_id
    and process_flag = 'R';
    COMMIT;

    if (l_exlog) then
          FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, l_module,'Transaction Commited.');
    end if;

    if (l_exlog) then
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, l_module,
        'End Worker for Asset Import. Time now is ' ||
        to_char(sysdate, 'Month DD, YYYY HH24:MI:SS'));
    end if;

END import_asset_numbers;

END EAM_ASSET_NUM_IMPORT_PUB;

/
