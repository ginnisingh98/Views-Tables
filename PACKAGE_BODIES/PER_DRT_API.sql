--------------------------------------------------------
--  DDL for Package Body PER_DRT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_DRT_API" as
	/* $Header: pedrtapi.pkb 120.0.12010000.5 2019/06/13 07:27:36 pkgandi noship $ */
	--
	-- Package Variables
	--
	g_package  varchar2(33) := '  PER_DRT_API.';
	g_debug boolean := hr_utility.debug_enabled;

	--
	-- ----------------------------------------------------------------------------
	-- |--------------------------< INSERT_TABLES_DETAILS >--------------------------|
	-- ----------------------------------------------------------------------------
	--

	procedure insert_tables_details
	  (p_product_code								in varchar2
	  ,p_schema											in varchar2
	  ,p_table_name           			in varchar2
	  ,p_table_phase			    			in number default '100'
	  ,p_record_identifier					in varchar2
	  ,p_entity_type                in varchar2
	  ,p_table_id                   in out nocopy number
	 )
	 is
	  --
	  -- Declare cursors and local variables
	  --
	  l_proc    										varchar2(72);
	  l_table_id                    per_drt_tables.table_id%type default null;
		l_product_code								per_drt_tables.product_code%type;
		l_schema											per_drt_tables.schema%type;
		l_table_name 									per_drt_tables.table_name%type;
		l_entity_type 								per_drt_tables.entity_type%type;
		l_validate										varchar2(5);

	begin

		l_proc := g_package||'insert_tables_details';
		hr_utility.set_location('Entering:'|| l_proc, 10);
	  --
	  -- Issue a savepoint
	  --
	  savepoint insert_tables_details;
	  hr_utility.set_location(l_proc, 20);

		-- mandatory arguments check
		hr_api.mandatory_arg_error
	            	(p_api_name   			=>  l_proc
	            	,p_argument  				=> 'p_product_code'
	            	,p_argument_value		=>	p_product_code);

		hr_api.mandatory_arg_error
		            (p_api_name   			=>  l_proc
		            ,p_argument  				=> 'p_schema'
		            ,p_argument_value		=>	p_schema);

		hr_api.mandatory_arg_error
		            (p_api_name   			=>  l_proc
		            ,p_argument  				=> 'p_table_name'
		            ,p_argument_value		=>	p_table_name);

		hr_api.mandatory_arg_error
		            (p_api_name   			=>  l_proc
		            ,p_argument  				=> 'p_record_identifier'
		            ,p_argument_value		=>	p_record_identifier);

		hr_api.mandatory_arg_error
			            (p_api_name   			=>  l_proc
			            ,p_argument  				=> 'p_entity_type'
			            ,p_argument_value		=>	p_entity_type);

		-- converting input parameters to upper case
		l_product_code					:= 		upper(p_product_code);
		l_schema								:= 		upper(p_schema);
		l_table_name 						:= 		upper(p_table_name);
		l_entity_type 					:= 		upper(p_entity_type);

	  hr_utility.set_location('p_product_code: '||l_product_code, 40);
	  hr_utility.set_location('p_schema: '||l_schema, 40);
	  hr_utility.set_location('p_table_name: '||l_table_name, 40);
	  hr_utility.set_location('p_table_phase: '||p_table_phase, 40);
	  hr_utility.set_location('p_record_identifier: '||p_record_identifier, 40);
	  hr_utility.set_location('p_entity_type: '||l_entity_type, 40);

	  --
	  -- Validation in addition to Row Handlers
	  --

			-- Check for valid product_code and schema
			begin
			--select null into l_validate from dual where exists ( select null from per_drt_product_apps where PRODUCT_SHORT_NAME = p_product_code);
			select null into l_validate from all_users where username = l_schema;
			exception
				WHEN no_data_found THEN
					fnd_message.set_name ('PER','PER_500053_DRT_PR_SCMA_INVD');
					fnd_message.raise_error;
			end;

			-- Check whether table is present and valid for the prodcut, schema combination
			begin
			if l_schema = 'APPS' then
				select null into l_validate from all_views where owner = l_schema and view_name = l_table_name;
			else
				select null into l_validate from all_tables where owner = l_schema and table_name = l_table_name and status = 'VALID';
			end if;
			exception
				WHEN no_data_found THEN
					fnd_message.set_name ('PER','PER_500054_DRT_TBL_INVLD');
	    		fnd_message.set_token('PROD_CODE',l_product_code);
	    		fnd_message.set_token('SCHEMA',l_schema);
					fnd_message.raise_error;
			end;

			-- Check whether the record_identifier is valid
			if instr(p_record_identifier,'<person_id>') = 0 and instr(p_record_identifier,'<:person_id>') = 0 then
					fnd_message.set_name ('PER','PER_500055_DRT_RECID_INVLD');
					fnd_message.raise_error;
			end if;

			-- Check if table_id has already been provided from the java layer, if not then api will generate the same.
			if (p_table_id is not null) then
					l_table_id := p_table_id;
			end if;

	  --
	  -- Process Logic
	  --
				per_drt_bk1.insert_tables_details_b
					(p_product_code => p_product_code
					,p_schema => p_schema
					,p_table_name => p_table_name
					,p_table_phase => p_table_phase
					,p_record_identifier => p_record_identifier
					,p_entity_type => p_entity_type
					,p_table_id => p_table_id
					);

		-- Insert into prt_drt_tables
				per_drt_ins.ins
	  			(p_table_id								=>		l_table_id
	  			,p_product_code						=>		l_product_code
	  			,p_schema									=>		l_schema
	  			,p_table_name       			=>		l_table_name
	  			,p_table_phase			    	=>		p_table_phase
	  			,p_record_identifier			=>		p_record_identifier
	  			,p_entity_type            =>		l_entity_type
		  		);
	  --
	  hr_utility.set_location('table id: '||l_table_id, 60);

		-- Setting the out parameter values
	  p_table_id := l_table_id;
	  hr_utility.set_location('Inserted table_id: '||p_table_id, 60);

				per_drt_bk1.insert_tables_details_a
					(p_product_code => p_product_code
					,p_schema => p_schema
					,p_table_name => p_table_name
					,p_table_phase => p_table_phase
					,p_record_identifier => p_record_identifier
					,p_entity_type => p_entity_type
					,p_table_id => p_table_id
					);

	  hr_utility.set_location('Leaving: '||l_proc, 80);
	exception
	  when others then
	    --
	    -- A validation or unexpected error has occured
	    --
	    rollback to insert_tables_details;
	    hr_utility.set_location('Leaving: '||l_proc, 100);
	    raise;
	end insert_tables_details ;

	--
	-- ----------------------------------------------------------------------------
	-- |--------------------------< INSERT_COLUMNS_DETAILS >--------------------------|
	-- ----------------------------------------------------------------------------
	--

	procedure insert_columns_details
	  (p_table_id                  	in number
		,p_column_name								in varchar2
	  ,p_column_phase            		in number default null
	  ,p_attribute			    				in varchar2 default null
	  ,p_ff_type             				in varchar2 default 'NONE'
	  ,p_rule_type                  in varchar2	default null
	  ,p_parameter_1								in varchar2 default null
	  ,p_parameter_2            		in varchar2 default null
	  ,p_comments			            	in varchar2 default null
	  ,p_column_id                  in out nocopy number
	 )
	 is
	  --
	  -- Declare cursors and local variables
		--
	   l_proc    										varchar2(72);
	   l_column_id                  per_drt_columns.column_id%type default null;
		 l_validate										varchar2(1) default 'Y';
		 l_column_name 								per_drt_columns.column_name%type;
		 l_ff_type 										per_drt_columns.ff_type%type;

	begin

	  if g_debug then
		l_proc := g_package||'insert_columns_details';
		hr_utility.set_location('Entering:'|| l_proc, 10);
	  end if;
	  --
	  -- Issue a savepoint
	  --
	  savepoint insert_columns_details;
	  hr_utility.set_location(l_proc, 20);

		-- mandatory arguments check
		hr_api.mandatory_arg_error
		            (p_api_name   			=>  l_proc
		            ,p_argument  				=> 'p_table_id'
		            ,p_argument_value		=>	p_table_id);

		hr_api.mandatory_arg_error
		            (p_api_name   			=>  l_proc
		            ,p_argument  				=> 'p_column_name'
		            ,p_argument_value		=>	p_column_name);

		hr_api.mandatory_arg_error
		            (p_api_name   			=>  l_proc
		            ,p_argument  				=> 'p_ff_type'
		            ,p_argument_value		=>	p_ff_type);

		-- converting input parameters to upper case
		l_column_name 					:= 		upper(p_column_name);
		l_ff_type 							:= 		upper(p_ff_type);

	  hr_utility.set_location('p_table_id: '||p_table_id, 40);
	  hr_utility.set_location('p_column_name: '||l_column_name, 40);
	  hr_utility.set_location('p_column_phase: '||p_column_phase, 40);
	  hr_utility.set_location('p_attribute: '||p_attribute, 40);
	  hr_utility.set_location('p_ff_type: '||l_ff_type, 40);
	  hr_utility.set_location('p_rule_type: '||p_rule_type, 40);
	  hr_utility.set_location('p_parameter_1: '||p_parameter_1, 40);
	  hr_utility.set_location('p_parameter_2: '||p_parameter_2, 40);

	  --
	  -- Validation in addition to Row Handlers
	  --
			-- Check whether the table_id is present in parent table per_drt_tables
			begin
			select 1 into l_validate from per_drt_tables where table_id = p_table_id;
			exception
				WHEN no_data_found THEN
					fnd_message.set_name ('PER','PER_500068_DRT_FK_NOT_FOUND');
	    		fnd_message.set_token('FK','table_id');
	    		fnd_message.set_token('TABLE','PER_DRT_TABLES');
					fnd_message.raise_error;
			end;

			-- Check whether the column_name is valid as per the table_id
			begin
			select nullable into l_validate from all_tab_columns atc, per_drt_tables pdt where atc.table_name=pdt.table_name and pdt.table_id = p_table_id
			and atc.column_name = l_column_name and atc.owner = pdt.schema;
			exception
				WHEN no_data_found THEN
					fnd_message.set_name ('PER','PER_500061_DRT_CLMN_INVLD');
	    		fnd_message.set_token('COL_NAME',l_column_name);
					fnd_message.raise_error;
			end;

			-- Check if column_id has already been provided from the java layer, if not then api will generate the same.
			if (p_column_id is not null) then
					l_column_id := p_column_id;
			end if;
	  --
			-- Check for not-null column getting null rule_type
			if l_validate = 'N' and p_rule_type = 'NULL' then
					fnd_message.set_name ('PER','PER_500056_DRT_CLMN_NULL');
	    		fnd_message.set_token('COL_NAME','Rule Type');
	    		fnd_message.set_token('TYPE','a non-nullable column');
					fnd_message.raise_error;
			end if;

	  -- Process Logic
	  --
				per_drt_bk2.insert_columns_details_b
					(p_table_id => p_table_id
					,p_column_name => p_column_name
					,p_column_phase => p_column_phase
					,p_attribute => p_attribute
					,p_ff_type => p_ff_type
					,p_rule_type => p_rule_type
					,p_parameter_1 => p_parameter_1
					,p_parameter_2 => p_parameter_2
					,p_comments => p_comments
					,p_column_id => p_column_id
					);

	-- Insert into prt_drt_columns
				per_drc_ins.ins
				(p_column_id				=>		l_column_id
				,p_table_id					=> 		p_table_id
				,p_column_name			=>		l_column_name
				,p_column_phase     =>		p_column_phase
				,p_attribute        =>		p_attribute
				,p_ff_type					=> 		l_ff_type
				,p_rule_type			  =>		p_rule_type
				,p_parameter_1      =>		p_parameter_1
				,p_parameter_2			=>		p_parameter_2
				,p_comments					=> 		p_comments
				);

				hr_utility.set_location('Column Id: '||l_column_id, 60);

	-- Setting the out parameter values
	  p_column_id := l_column_id;
	  hr_utility.set_location('Inserted column_id: '||p_column_id, 80);

					per_drt_bk2.insert_columns_details_a
						(p_table_id => p_table_id
						,p_column_name => p_column_name
						,p_column_phase => p_column_phase
						,p_attribute => p_attribute
						,p_ff_type => p_ff_type
						,p_rule_type => p_rule_type
						,p_parameter_1 => p_parameter_1
						,p_parameter_2 => p_parameter_2
						,p_comments => p_comments
						,p_column_id => p_column_id
						);

		hr_utility.set_location('Leaving: '||l_proc, 80);

	 exception
	  when others then
	    --
	    -- A validation or unexpected error has occured
	    --
	    rollback to insert_columns_details;
	    hr_utility.set_location('Leaving: '||l_proc, 100);
	    raise;
	end insert_columns_details ;

	--
	-- ----------------------------------------------------------------------------
	-- |--------------------------< INSERT_COL_CONTEXTS_DETAILS >--------------------------|
	-- ----------------------------------------------------------------------------
	--

	procedure insert_col_contexts_details
	  (p_column_id                  in number
	  ,p_ff_name             				in varchar2
	  ,p_context_name             	in varchar2
		,p_column_name								in varchar2
	  ,p_column_phase            		in number	default '1'
	  ,p_attribute			    				in varchar2
	  ,p_rule_type                  in varchar2
	  ,p_parameter_1								in varchar2	default null
	  ,p_parameter_2            		in varchar2	default null
	  ,p_comments			            	in varchar2	default null
	  ,p_ff_column_id              	in out nocopy number
	 )
	 is
	  --
	  -- Declare cursors and local variables
	  --
	   l_proc    										varchar2(72);
	   l_ff_column_id               per_drt_col_contexts.ff_column_id%type default null;
		 l_column_name 								per_drt_columns.column_name%type;
		 l_validate										varchar2(1) default 'Y';

	begin

	  if g_debug then
		l_proc := g_package||'insert_col_contexts_details';
		hr_utility.set_location('Entering:'|| l_proc, 10);
	  end if;
	  --
	  -- Issue a savepoint
	  --
	  savepoint insert_col_contexts_details;
	  hr_utility.set_location(l_proc, 20);

		-- mandatory arguments check
		hr_api.mandatory_arg_error
		            (p_api_name   			=>  l_proc
		            ,p_argument  				=> 'p_column_id'
		            ,p_argument_value		=>	p_column_id);

		hr_api.mandatory_arg_error
		            (p_api_name   			=>  l_proc
		            ,p_argument  				=> 'p_column_name'
		            ,p_argument_value		=>	p_column_name);

		hr_api.mandatory_arg_error
		            (p_api_name   			=>  l_proc
		            ,p_argument  				=> 'p_ff_name'
		            ,p_argument_value		=>	p_ff_name);

		hr_api.mandatory_arg_error
		            (p_api_name   			=>  l_proc
		            ,p_argument  				=> 'p_context_name'
		            ,p_argument_value		=>	p_context_name);

		-- converting input parameters to upper case
		l_column_name 					:= 		upper(p_column_name);

	  hr_utility.set_location('p_column_id: '||p_column_id, 40);
	  hr_utility.set_location('p_column_name: '||l_column_name, 40);
	  hr_utility.set_location('p_column_phase: '||p_column_phase, 40);
	  hr_utility.set_location('p_attribute: '||p_attribute, 40);
	  hr_utility.set_location('p_ff_name: '||p_ff_name, 40);
	  hr_utility.set_location('p_context_name: '||p_context_name, 40);
	  hr_utility.set_location('p_rule_type: '||p_rule_type, 40);
	  hr_utility.set_location('p_parameter_1: '||p_parameter_1, 40);
	  hr_utility.set_location('p_parameter_2: '||p_parameter_2, 40);

	  --
	  -- Validation in addition to Row Handlers
		--
			-- Check whether the column_id is present in parent table per_drt_columns
			begin
			select 1 into l_validate from per_drt_columns where column_id = p_column_id;
			exception
				WHEN no_data_found THEN
					fnd_message.set_name ('PER','PER_500068_DRT_FK_NOT_FOUND');
	    		fnd_message.set_token('FK','column_id');
	    		fnd_message.set_token('TABLE','PER_DRT_COLUMNS');
					fnd_message.raise_error;
			end;

			-- Check if ff_column_id has already been provided from the java layer, if not then api will generate the same.
			if (p_ff_column_id is not null) then
					l_ff_column_id := p_ff_column_id;
			end if;

	  --
	  -- Process Logic
	  --
				per_drt_bk3.insert_col_contexts_details_b
					(p_column_id => p_column_id
					,p_ff_name => p_ff_name
					,p_context_name => p_context_name
					,p_column_name => p_column_name
					,p_column_phase => p_column_phase
					,p_attribute => p_attribute
					,p_rule_type => p_rule_type
					,p_parameter_1 => p_parameter_1
					,p_parameter_2 => p_parameter_2
					,p_comments => p_comments
					,p_ff_column_id => p_ff_column_id
					);

		-- Insert into prt_drt_col_contexts
				per_drx_ins.ins
					(p_ff_column_id					=>		l_ff_column_id
					,p_column_id						=> 		p_column_id
					,p_ff_name             	=>		p_ff_name
					,p_context_name         =>		p_context_name
					,p_column_name			    =>		l_column_name
					,p_column_phase		      =>		p_column_phase
					,p_attribute			    	=>		p_attribute
					,p_rule_type			      =>		p_rule_type
					,p_parameter_1          =>		p_parameter_1
					,p_parameter_2          =>		p_parameter_2
					,p_comments							=> 		p_comments
					);

				hr_utility.set_location('ff_column_id :'||l_proc, 60);

		-- Setting the out parameter values
	  p_ff_column_id := l_ff_column_id;
	  hr_utility.set_location('Inserted ff_column_id: '||p_ff_column_id, 80);

				per_drt_bk3.insert_col_contexts_details_a
					(p_column_id => p_column_id
					,p_ff_name => p_ff_name
					,p_context_name => p_context_name
					,p_column_name => p_column_name
					,p_column_phase => p_column_phase
					,p_attribute => p_attribute
					,p_rule_type => p_rule_type
					,p_parameter_1 => p_parameter_1
					,p_parameter_2 => p_parameter_2
					,p_comments => p_comments
					,p_ff_column_id => p_ff_column_id
					);

	  hr_utility.set_location('Leaving: '||l_proc, 80);

	 exception
	  when others then
	    --
	    -- A validation or unexpected error has occured
	    --
	    rollback to insert_col_contexts_details;
	    hr_utility.set_location('Leaving: '||l_proc, 100);
	    raise;
	end insert_col_contexts_details ;

	-- ----------------------------------------------------------------------------
	-- --------------------------< UPDATE_TABLES_DETAILS >------------------------
	-- ----------------------------------------------------------------------------
	--

	procedure update_tables_details
	  (p_table_id										in number
		,p_product_code								in varchar2
	  ,p_schema											in varchar2
	  ,p_table_name            			in varchar2
	  ,p_table_phase			        	in number default '100'
	  ,p_record_identifier					in varchar2
	  ,p_entity_type                in varchar2
	  )
	is
	  --
	  -- Declare cursors and local variables
	  --
	  l_proc												varchar2(72);
		l_product_code								per_drt_tables.product_code%type;
		l_schema											per_drt_tables.schema%type;
		l_table_name 									per_drt_tables.table_name%type;
		l_entity_type 								per_drt_tables.entity_type%type;
		old_entity_type 							per_drt_tables.entity_type%type;

	begin

	  if g_debug then
		l_proc := g_package||'update_tables_details';
		hr_utility.set_location('Entering:'|| l_proc, 10);
	  end if;
	  --
	  -- Issue a savepoint
	  --
	  savepoint update_tables_details;
	  hr_utility.set_location(l_proc, 20);

		-- mandatory arguments check
		hr_api.mandatory_arg_error
		            (p_api_name   			=>  l_proc
		            ,p_argument  				=> 'p_table_id'
		            ,p_argument_value		=>	p_table_id);

		hr_api.mandatory_arg_error
		            (p_api_name   			=>  l_proc
		            ,p_argument  				=> 'p_product_code'
		            ,p_argument_value		=>	p_product_code);

		hr_api.mandatory_arg_error
		            (p_api_name   			=>  l_proc
		            ,p_argument  				=> 'p_schema'
		            ,p_argument_value		=>	p_schema);

		hr_api.mandatory_arg_error
		            (p_api_name   			=>  l_proc
		            ,p_argument  				=> 'p_table_name'
		            ,p_argument_value		=>	p_table_name);

		-- converting input parameters to upper case
		l_product_code					:= 		upper(p_product_code);
		l_schema								:= 		upper(p_schema);
		l_table_name 						:= 		upper(p_table_name);
		l_entity_type 					:= 		upper(p_entity_type);

	  hr_utility.set_location('p_table_id: '||p_table_id, 40);
	  hr_utility.set_location('p_product_code: '||l_product_code, 40);
	  hr_utility.set_location('p_schema: '||l_schema, 40);
	  hr_utility.set_location('p_table_name: '||l_table_name, 40);
	  hr_utility.set_location('p_table_phase: '||p_table_phase, 40);
	  hr_utility.set_location('p_record_identifier: '||p_record_identifier, 40);
	  hr_utility.set_location('p_entity_type: '||l_entity_type, 40);

			-- Check whether the record_identifier is valid
			if instr(p_record_identifier,'<person_id>') = 0 and instr(p_record_identifier,'<:person_id>') = 0 then
					fnd_message.set_name ('PER','PER_500055_DRT_RECID_INVLD');
					fnd_message.raise_error;
			end if;

			-- Get the old_entity_type value before proceeding to update
				SELECT  entity_type
				INTO    old_entity_type
				FROM    per_drt_tables
				WHERE   table_id = p_table_id;

	  --
	  -- Process Logic
	  --
				per_drt_bk4.update_tables_details_b
					(p_table_id => p_table_id
					,p_product_code => p_product_code
					,p_schema => p_schema
					,p_table_name => p_table_name
					,p_table_phase => p_table_phase
					,p_record_identifier => p_record_identifier
					,p_entity_type => p_entity_type
					);

		-- Update per_drt_tables
				per_drt_upd.upd
	  			(p_table_id								=>		p_table_id
	  			,p_product_code						=>		l_product_code
	  			,p_schema									=>		l_schema
	  			,p_table_name       			=>		l_table_name
	  			,p_table_phase			    	=>		p_table_phase
	  			,p_record_identifier			=>		p_record_identifier
	  			,p_entity_type            =>		l_entity_type
		  		);

				per_drt_bk4.update_tables_details_a
					(p_table_id => p_table_id
					,p_product_code => p_product_code
					,p_schema => p_schema
					,p_table_name => p_table_name
					,p_table_phase => p_table_phase
					,p_record_identifier => p_record_identifier
					,p_entity_type => p_entity_type
					);

				hr_utility.set_location('Leaving: '||l_proc, 80);

	 exception
	  when others then
	    --
	    -- A validation or unexpected error has occured
	    --
	    rollback to update_tables_details;
	    hr_utility.set_location('Leaving: '||l_proc, 100);
	    raise;
	end update_tables_details;

	-- ----------------------------------------------------------------------------
	-- --------------------------< UPDATE_COLUMNS_DETAILS >------------------------
	-- ----------------------------------------------------------------------------
	--

	procedure update_columns_details
	  (p_column_id						in number
		,p_table_id							in number
	  ,p_column_name					in varchar2
	  ,p_column_phase					in number	default null
	  ,p_attribute			    	in varchar2 default null
	  ,p_ff_type             	in varchar2 default 'NONE'
	  ,p_rule_type            in varchar2 default null
	  ,p_parameter_1					in varchar2 default null
	  ,p_parameter_2          in varchar2 default null
	  ,p_comments			        in varchar2 default null
	  )
	is
	  --
	  -- Declare cursors and local variables
		--
	  l_proc										varchar2(72);
		l_validate								varchar2(1) default 'Y';
		l_column_name 						per_drt_columns.column_name%type;
		l_ff_type 								per_drt_columns.ff_type%type;

	begin

	  if g_debug then
		l_proc := g_package||'update_columns_details';
		hr_utility.set_location('Entering:'|| l_proc, 10);
	  end if;
	  --
	  -- Issue a savepoint
	  --
	  savepoint update_columns_details;
	  hr_utility.set_location(l_proc, 20);

		-- mandatory arguments check
		hr_api.mandatory_arg_error
		            (p_api_name   			=>  l_proc
		            ,p_argument  				=> 'p_table_id'
		            ,p_argument_value		=>	p_table_id);

		hr_api.mandatory_arg_error
		            (p_api_name   			=>  l_proc
		            ,p_argument  				=> 'p_column_name'
		            ,p_argument_value		=>	p_column_name);

		hr_api.mandatory_arg_error
		            (p_api_name   			=>  l_proc
		            ,p_argument  				=> 'p_column_id'
		            ,p_argument_value		=>	p_column_id);

		-- converting input parameters to upper case
		l_column_name 					:= 		upper(p_column_name);
		l_ff_type 							:= 		upper(p_ff_type);

	  hr_utility.set_location('p_column_id: '||p_column_id, 40);
	  hr_utility.set_location('p_table_id: '||p_table_id, 40);
	  hr_utility.set_location('p_column_name: '||l_column_name, 40);
	  hr_utility.set_location('p_column_phase: '||p_column_phase, 40);
	  hr_utility.set_location('p_attribute: '||p_attribute, 40);
	  hr_utility.set_location('p_ff_type: '||l_ff_type, 40);
	  hr_utility.set_location('p_rule_type: '||p_rule_type, 40);
	  hr_utility.set_location('p_parameter_1: '||p_parameter_1, 40);
	  hr_utility.set_location('p_parameter_2: '||p_parameter_2, 40);

			-- Check for not-null column getting null rule_type
			if p_rule_type = 'NULL' then
			select nullable into l_validate from all_tab_columns atc, per_drt_tables pdt where atc.table_name=pdt.table_name and pdt.table_id = p_table_id
			and atc.column_name = l_column_name and atc.owner = pdt.schema;
				if l_validate = 'N' then
					fnd_message.set_name ('PER','PER_500056_DRT_CLMN_NULL');
	    		fnd_message.set_token('COL_NAME','Rule Type');
	    		fnd_message.set_token('TYPE','a non-nullable column');
					fnd_message.raise_error;
				end if;
			end if;

	  --
	  -- Process Logic
	  --
				per_drt_bk5.update_columns_details_b
					(p_column_id => p_column_id
					,p_table_id => p_table_id
					,p_column_name => p_column_name
					,p_column_phase => p_column_phase
					,p_attribute => p_attribute
					,p_ff_type => p_ff_type
					,p_rule_type => p_rule_type
					,p_parameter_1 => p_parameter_1
					,p_parameter_2 => p_parameter_2
					,p_comments => p_comments
					);

		-- Update prt_drt_columns
			if (p_ff_type = 'NONE') then
					per_drc_upd.upd
						(p_column_id				=>		p_column_id
						,p_table_id					=> 		p_table_id
						,p_column_name			=>		l_column_name
						,p_column_phase     =>		p_column_phase
						,p_attribute        =>		p_attribute
						,p_ff_type					=> 		l_ff_type
						,p_rule_type			  =>		p_rule_type
						,p_parameter_1      =>		p_parameter_1
						,p_parameter_2			=>		p_parameter_2
						,p_comments					=> 		p_comments
						);
			else
					per_drc_upd.upd
						(p_column_id				=>		p_column_id
						,p_table_id					=> 		p_table_id
						,p_column_name			=>		l_column_name
						,p_column_phase			=>		null
						,p_attribute        =>		null
						,p_ff_type					=> 		l_ff_type
						,p_rule_type			  =>		null
						,p_parameter_1      =>		null
						,p_parameter_2      =>		null
						,p_comments					=> 		p_comments
						);
			end if;

				per_drt_bk5.update_columns_details_a
					(p_column_id => p_column_id
					,p_table_id => p_table_id
					,p_column_name => p_column_name
					,p_column_phase => p_column_phase
					,p_attribute => p_attribute
					,p_ff_type => p_ff_type
					,p_rule_type => p_rule_type
					,p_parameter_1 => p_parameter_1
					,p_parameter_2 => p_parameter_2
					,p_comments => p_comments
					);

			hr_utility.set_location('Leaving: '||l_proc, 80);

	 exception
	  when others then
	    --
	    -- A validation or unexpected error has occured
	    --
	    rollback to update_columns_details;
	    hr_utility.set_location('Leaving: '||l_proc, 100);
	    raise;
	end update_columns_details;

	-- ----------------------------------------------------------------------------
	-- --------------------------< UPDATE_COL_CONTEXTS_DETAILS >------------------------
	-- ----------------------------------------------------------------------------
	--

	procedure update_col_contexts_details
	  (p_ff_column_id					in number
		,p_column_id						in number
	  ,p_ff_name             	in varchar2
	  ,p_context_name         in varchar2
	  ,p_column_name					in varchar2
	  ,p_column_phase					in number default '1'
	  ,p_attribute			    	in varchar2
	  ,p_rule_type            in varchar2
	  ,p_parameter_1					in varchar2	default null
	  ,p_parameter_2          in varchar2	default null
	  ,p_comments			        in varchar2	default null
	  )
	is
	  --
	  -- Declare cursors and local variables
		--
	  l_proc										varchar2(72);
		l_column_name 						per_drt_columns.column_name%type;

	begin

		l_proc := g_package||'update_col_contexts_details';
		hr_utility.set_location('Entering:'|| l_proc, 10);
	  --
	  -- Issue a savepoint
	  --
	  savepoint update_col_contexts_details;
	  hr_utility.set_location(l_proc, 20);

		-- mandatory arguments check
		hr_api.mandatory_arg_error
		            (p_api_name   			=>  l_proc
		            ,p_argument  				=> 'p_ff_column_id'
		            ,p_argument_value		=>	p_ff_column_id);

		hr_api.mandatory_arg_error
		            (p_api_name   			=>  l_proc
		            ,p_argument  				=> 'p_column_id'
		            ,p_argument_value		=>	p_column_id);

		-- converting input parameters to upper case
		l_column_name 					:= 		upper(p_column_name);

	  hr_utility.set_location('p_ff_column_id: '||p_ff_column_id, 20);
	  hr_utility.set_location('p_column_id: '||p_column_id, 20);
	  hr_utility.set_location('p_ff_name: '||p_ff_name, 20);
	  hr_utility.set_location('p_context_name: '||p_context_name, 20);
	  hr_utility.set_location('p_column_name: '||l_column_name, 20);
	  hr_utility.set_location('p_column_phase: '||p_column_phase, 20);
	  hr_utility.set_location('p_attribute: '||p_attribute, 20);
	  hr_utility.set_location('p_rule_type: '||p_rule_type, 20);
	  hr_utility.set_location('p_parameter_1: '||p_parameter_1, 20);
	  hr_utility.set_location('p_parameter_2: '||p_parameter_2, 20);

	  --
	  -- Process Logic
	  --
				per_drt_bk6.update_col_contexts_details_b
					(p_ff_column_id => p_ff_column_id
					,p_column_id => p_column_id
					,p_ff_name => p_ff_name
					,p_context_name => p_context_name
					,p_column_name => p_column_name
					,p_column_phase => p_column_phase
					,p_attribute => p_attribute
					,p_rule_type => p_rule_type
					,p_parameter_1 => p_parameter_1
					,p_parameter_2 => p_parameter_2
					,p_comments => p_comments
					);

		-- Update prt_drt_col_contexts
				per_drx_upd.upd
					(p_ff_column_id					=>		p_ff_column_id
					,p_column_id						=> 		p_column_id
					,p_ff_name             	=>		p_ff_name
					,p_context_name         =>		p_context_name
					,p_column_name			    =>		l_column_name
					,p_column_phase		      =>		p_column_phase
					,p_attribute			    	=>		p_attribute
					,p_rule_type			      =>		p_rule_type
					,p_parameter_1          =>		p_parameter_1
					,p_parameter_2          =>		p_parameter_2
					,p_comments							=> 		p_comments
					);

				per_drt_bk6.update_col_contexts_details_a
					(p_ff_column_id => p_ff_column_id
					,p_column_id => p_column_id
					,p_ff_name => p_ff_name
					,p_context_name => p_context_name
					,p_column_name => p_column_name
					,p_column_phase => p_column_phase
					,p_attribute => p_attribute
					,p_rule_type => p_rule_type
					,p_parameter_1 => p_parameter_1
					,p_parameter_2 => p_parameter_2
					,p_comments => p_comments
					);

				hr_utility.set_location('Leaving: '||l_proc, 80);

	 exception
	  when others then
	    --
	    -- A validation or unexpected error has occured
	    --
	    rollback to update_col_contexts_details;
	    hr_utility.set_location('Leaving: '||l_proc, 100);
	    raise;
	end update_col_contexts_details;

	-- ----------------------------------------------------------------------------
	-- |--------------------------< delete_table_details >------------------------
	--|
	-- ----------------------------------------------------------------------------
	--
	procedure delete_drt_details
	  (p_table_id					           in 		number default null
		,p_column_id					           in 		number default null
		,p_ff_column_id					           in 		number default null
	  )
	is
	  --
	  -- Declare cursors and local variables
		--
	  l_proc							varchar2(72);

		cursor get_column_id(l_table_id number) is
		select column_id from per_drt_columns where table_id = l_table_id;

		cursor get_ff_column_id(l_column_id number) is
		select ff_column_id from per_drt_col_contexts where column_id = l_column_id;

	begin

	  if g_debug then
		l_proc := g_package||'delete_table_details';
		hr_utility.set_location('Entering:'|| l_proc, 10);
	  end if;
	  --
	  -- Issue a savepoint
	  --
	  savepoint delete_table_details;
	  hr_utility.set_location(l_proc, 20);

	  hr_utility.set_location('p_table_id: '||p_table_id, 20);
	  hr_utility.set_location('p_column_id: '||p_column_id, 20);
	  hr_utility.set_location('p_ff_column_id: '||p_ff_column_id, 20);

	  --
	  -- Process Logic
	  --
				per_drt_bk7.delete_drt_details_b
					(p_table_id => p_table_id
					,p_column_id => p_column_id
					,p_ff_column_id => p_ff_column_id
					);

		-- Delete from per_drt_col_contexts
		if (p_ff_column_id is not null) then
				hr_utility.set_location('Before deletion for p_ff_column_id: '||p_ff_column_id, 30);
				per_drx_del.del(p_ff_column_id => p_ff_column_id);
				hr_utility.set_location('Deletion processed for p_ff_column_id: '||p_ff_column_id, 30);
		end if;


		-- Delete from per_drt_columns
		if (p_column_id is not null) then
				-- Delete from child per_drt_col_contexts first
				for i in get_ff_column_id(p_column_id)
					loop
						hr_utility.set_location('Before deletion for l_ff_column_id: '||i.ff_column_id, 40);
						per_drx_del.del(p_ff_column_id => i.ff_column_id);
						hr_utility.set_location('Deletion processed for l_ff_column_id: '||i.ff_column_id, 40);
					end loop;
				-- Now delete from per_drt_columns
				hr_utility.set_location('Before deletion for column_id: '||p_column_id, 50);
				per_drc_del.del(p_column_id => p_column_id);
				hr_utility.set_location('Deletion processed for column_id: '||p_column_id, 50);
	  end if;


		-- Delete from per_drt_tables
		if (p_table_id is not null) then
				-- Delete from child per_drt_columns, per_drt_col_contexts first
				for i in get_column_id(p_table_id)
					loop
						for j in get_ff_column_id(i.column_id)
							loop
								hr_utility.set_location('Before deletion for l_ff_column_id: '||j.ff_column_id, 60);
								per_drx_del.del(p_ff_column_id => j.ff_column_id);
								hr_utility.set_location('Deletion processed for l_ff_column_id: '||j.ff_column_id, 60);
							end loop;
						hr_utility.set_location('Before deletion for l_column_id: '||i.column_id, 70);
						per_drc_del.del(p_column_id => i.column_id);
						hr_utility.set_location('Deletion processed for l_column_id: '||i.column_id, 70);
					end loop;
				-- Now delete from per_drt_tables
	    	hr_utility.set_location('Before deletion for p_table_id: '||p_table_id, 80);
				per_drt_del.del(p_table_id => p_table_id);
	    	hr_utility.set_location('Deletion processed for p_table_id: '||p_table_id, 80);
	  end if;

					per_drt_bk7.delete_drt_details_a
						(p_table_id => p_table_id
						,p_column_id => p_column_id
						,p_ff_column_id => p_ff_column_id
						);

		hr_utility.set_location('Leaving: '||l_proc, 90);

	exception
	  when others then
	    --
	    -- A validation or unexpected error has occured
	    --
	    rollback to delete_table_details;
	    hr_utility.set_location('Leaving: '||l_proc, 100);
	    raise;
	end delete_drt_details;

end PER_DRT_API;

/
