--------------------------------------------------------
--  DDL for Package Body PER_DRT_METADATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_DRT_METADATA" AS
	/* $Header: pedrtmet.pkb 120.0.12010000.3 2019/12/24 09:40:16 ktithy noship $ */
		--
	-- Package Variables
	--
	g_package  varchar2(33) := '  PER_DRT_METADATA.';
	g_debug boolean 		:= 	hr_utility.debug_enabled;

  PROCEDURE update_seeded_metadata
    (p_table_id          IN number
    ,p_table_phase       IN number  	DEFAULT NULL
    ,p_record_identifier IN varchar2	DEFAULT NULL
    ,p_column_id         IN number		DEFAULT NULL
    ,p_ff_column_id      IN number		DEFAULT NULL
    ,p_column_phase      IN number   	DEFAULT NULL
    ,p_attribute         IN varchar2	DEFAULT NULL
    ,p_ff_type           IN varchar2 	DEFAULT NULL
    ,p_rule_type         IN varchar2 	DEFAULT NULL
    ,p_parameter_1       IN varchar2 	DEFAULT NULL
    ,p_parameter_2       IN varchar2 	DEFAULT NULL
    ,p_comments          IN varchar2 	DEFAULT NULL)
	is
	  --
	  -- Declare cursors and local variables
	  --
	  	l_proc								varchar2(72);
		l_record_identifier						per_drt_tables.record_identifier%type;
		l_table_phase							per_drt_tables.table_phase%type;
		l_ff_type							per_drt_columns.ff_type%type;
		l_ff_type_old							per_drt_columns.ff_type%type;
		l_validate							varchar2(1);
		l_column_phase							per_drt_columns.column_phase%type;
		l_attribute							per_drt_columns.attribute%type;
		l_rule_type							per_drt_columns.rule_type%type;
		l_parameter_1							per_drt_columns.parameter_1%type;
		l_parameter_2							per_drt_columns.parameter_2%type;
		l_comments							per_drt_columns.comments%type;
		l_rec_c								per_drc_shd.g_rec_type;		--bug#30447381
		l_rec_x								per_drx_shd.g_rec_type;		--bug#30447381

		cursor get_table_details(l_table_id number) is (select * from per_drt_tables where table_id = l_table_id);

		cursor get_column_details(l_column_id number) is (select * from per_drt_columns where column_id = l_column_id);

		cursor get_col_contexts_details(l_ff_column_id number) is (select * from per_drt_col_contexts where ff_column_id = l_ff_column_id);

BEGIN
	begin
	  if g_debug then
		l_proc := g_package||'update_seeded_metadata';
		hr_utility.set_location('Entering tables:'|| l_proc, 10);
	  end if;
	  --
	  -- Issue a savepoint
	  --
	  savepoint update_table_metadata;
	  hr_utility.set_location(l_proc, 20);

		-- mandatory arguments check
		hr_api.mandatory_arg_error
		            (p_api_name   			=>  l_proc
		            ,p_argument  				=> 'p_table_id'
		            ,p_argument_value		=>	p_table_id);

		l_record_identifier					:= 		p_record_identifier;
		l_table_phase								:= 		p_table_phase;

	  hr_utility.set_location('p_table_id: '||p_table_id, 40);
	  hr_utility.set_location('p_table_phase: '||p_table_phase, 40);
	  hr_utility.set_location('p_record_identifier: '||p_record_identifier, 40);

			-- Check whether the record_identifier is valid
			if instr(p_record_identifier,'<person_id>') = 0 and instr(p_record_identifier,'<:person_id>') = 0 then
					fnd_message.set_name ('PER','PER_500055_DRT_RECID_INVLD');
					fnd_message.raise_error;
			end if;

			for i in get_table_details(p_table_id) loop
				if p_record_identifier is null then
					l_record_identifier := i.record_identifier;
				end if;
				if p_table_phase is null then
					l_table_phase := i.table_phase;
				end if;
			end loop;

  	per_drt_shd.lck(p_table_id);
		BEGIN
		  hr_utility.set_location ('Entering:'|| l_proc,5);
		  UPDATE  per_drt_tables
		  SET     table_phase = l_table_phase
		         ,record_identifier = l_record_identifier
		  WHERE   table_id = p_table_id;
		  hr_utility.set_location (' Leaving:'|| l_proc,10);
		EXCEPTION
		  WHEN hr_api.check_integrity_violated THEN
		    per_drt_shd.constraint_error(p_constraint_name => hr_api.strip_constraint_name (sqlerrm) );
		  WHEN hr_api.parent_integrity_violated THEN
		    per_drt_shd.constraint_error(p_constraint_name => hr_api.strip_constraint_name (sqlerrm) );
		  WHEN hr_api.unique_integrity_violated THEN
		    per_drt_shd.constraint_error(p_constraint_name => hr_api.strip_constraint_name (sqlerrm) );
		  WHEN others THEN
		    RAISE;
		END;
	exception
	  when others then
	    rollback to update_table_metadata;
	    hr_utility.set_location('Leaving: '||l_proc, 100);
	    raise;
	end;

	if (p_column_id is not null) then
		begin

	  if g_debug then
		l_proc := g_package||'update_seeded_metadata';
		hr_utility.set_location('Entering columns:'|| l_proc, 10);
	  end if;
	  --
	  -- Issue a savepoint
	  --
	  savepoint update_columns_metadata;
	  hr_utility.set_location(l_proc, 20);

		-- converting input parameters to upper case
		l_column_phase					:=		p_column_phase;
		l_attribute 						:= 		p_attribute;
		l_ff_type 							:= 		upper(p_ff_type);
		l_rule_type 						:= 		p_rule_type;
		l_parameter_1 					:= 		p_parameter_1;
		l_parameter_2 					:= 		p_parameter_2;
		l_comments							:=		p_comments;

	  hr_utility.set_location('p_column_id: '||p_column_id, 40);
	  hr_utility.set_location('p_table_id: '||p_table_id, 40);
	  hr_utility.set_location('p_column_phase: '||l_column_phase, 40);
	  hr_utility.set_location('p_attribute: '||l_attribute, 40);
	  hr_utility.set_location('p_ff_type: '||l_ff_type, 40);
	  hr_utility.set_location('p_rule_type: '||l_rule_type, 40);
	  hr_utility.set_location('p_parameter_1: '||l_parameter_1, 40);
	  hr_utility.set_location('p_parameter_2: '||l_parameter_2, 40);

			-- Check for not-null column getting null rule_type
			if p_rule_type = 'NULL' then
			select nullable into l_validate from all_tab_columns atc, per_drt_tables pdt, per_drt_columns pdc where atc.table_name=pdt.table_name and pdt.table_id = p_table_id
			and atc.column_name = pdc.column_name and atc.owner = pdt.schema and pdc.column_id = p_column_id;
				if l_validate = 'N' then
					fnd_message.set_name ('PER','PER_500056_DRT_CLMN_NULL');
	    		fnd_message.set_token('COL_NAME','Rule Type');
	    		fnd_message.set_token('TYPE','a non-nullable column');
					fnd_message.raise_error;
				end if;
			end if;

			for i in get_column_details(p_column_id) loop
				if p_column_phase is null then
					l_column_phase := i.column_phase;
				end if;
				if p_attribute is null then
					l_attribute := i.attribute;
				end if;
				if p_ff_type is null then
					l_ff_type := i.ff_type;
				else
					l_ff_type_old := i.ff_type;
				end if;
				if p_rule_type is null then
					l_rule_type := i.rule_type;
				end if;
				if p_parameter_1 is null then
					l_parameter_1 := i.parameter_1;
				end if;
				if p_parameter_2 is null then
					l_parameter_2 := i.parameter_2;
				end if;
				if p_comments is null then
					l_comments := i.comments;
				end if;
			end loop;


		-- Update prt_drt_columns
			if (l_ff_type = 'NONE') then
					l_rec_c := per_drc_shd.convert_args			--bug#30447381
							(p_column_id
							,p_table_id
							,null
							,l_column_phase
							,l_attribute
							,l_ff_type
							,l_rule_type
							,l_parameter_1
							,l_parameter_2
							,l_comments
							);
					per_drc_bus.chk_parameter_values(l_rec_c);		--bug#30447381
					per_drc_shd.lck(p_column_id);
					BEGIN
					  hr_utility.set_location ('Entering:'|| l_proc,5);

					  UPDATE  per_drt_columns
					  SET     column_phase = l_column_phase
					         ,attribute = l_attribute
					         ,ff_type = l_ff_type
					         ,rule_type = l_rule_type
					         ,parameter_1 = l_parameter_1
					         ,parameter_2 = l_parameter_2
					         ,comments = l_comments
					  WHERE   column_id = p_column_id;

					  hr_utility.set_location (' Leaving:'|| l_proc,10);
					EXCEPTION
					  WHEN hr_api.check_integrity_violated THEN
					    per_drc_shd.constraint_error(p_constraint_name => hr_api.strip_constraint_name (sqlerrm) );
					  WHEN hr_api.parent_integrity_violated THEN
					    per_drc_shd.constraint_error(p_constraint_name => hr_api.strip_constraint_name (sqlerrm) );
					  WHEN hr_api.unique_integrity_violated THEN
					    per_drc_shd.constraint_error(p_constraint_name => hr_api.strip_constraint_name (sqlerrm) );
					  WHEN others THEN
					    RAISE;
					END;

				if l_ff_type <> l_ff_type_old then

					for i in (select ff_column_id from per_drt_col_contexts where column_id = p_column_id) loop
							delete_seeded_metadata(p_ff_column_id => i.ff_column_id);
					end loop;

				end if;


			else		-- ff_type in (DDF,DFF,KFF)
					l_rec_c := per_drc_shd.convert_args			--bug#30447381
							(p_column_id
							,p_table_id
							,null
							,l_column_phase
							,l_attribute
							,l_ff_type
							,l_rule_type
							,l_parameter_1
							,l_parameter_2
							,l_comments
							);
					per_drc_bus.chk_parameter_values(l_rec_c);		--bug#30447381
					per_drc_shd.lck(p_column_id);
					BEGIN
					  hr_utility.set_location ('Entering not None:'|| l_proc,5);

					  UPDATE  per_drt_columns
					  SET     column_phase = NULL
					         ,attribute = NULL
					         ,ff_type = l_ff_type
					         ,rule_type = NULL
					         ,parameter_1 = NULL
					         ,parameter_2 = NULL
					         ,comments = p_comments
					  WHERE   column_id = p_column_id;

					  hr_utility.set_location (' Leaving not None:'|| l_proc,10);
					EXCEPTION
					  WHEN hr_api.check_integrity_violated THEN
					    per_drc_shd.constraint_error(p_constraint_name => hr_api.strip_constraint_name (sqlerrm) );
					  WHEN hr_api.parent_integrity_violated THEN
					    per_drc_shd.constraint_error(p_constraint_name => hr_api.strip_constraint_name (sqlerrm) );
					  WHEN hr_api.unique_integrity_violated THEN
					    per_drc_shd.constraint_error(p_constraint_name => hr_api.strip_constraint_name (sqlerrm) );
					  WHEN others THEN
					    RAISE;
					END;

			end if;

			hr_utility.set_location('Leaving: '||l_proc, 80);

	 exception
	  when others then
	    --
	    -- A validation or unexpected error has occured
	    --
	    rollback to update_columns_metadata;
	    hr_utility.set_location('Leaving: '||l_proc, 100);
	    raise;
	end;
	end if;

	if (p_ff_column_id is not null) then
		begin

		l_proc := g_package||'update_col_contexts_metadata';
		hr_utility.set_location('Entering:'|| l_proc, 10);
	  --
	  -- Issue a savepoint
	  --
	  savepoint update_col_contexts_metadata;
	  hr_utility.set_location(l_proc, 20);

		l_column_phase					:=		p_column_phase;
		l_attribute 						:= 		p_attribute;
		l_rule_type 						:= 		p_rule_type;
		l_parameter_1 					:= 		p_parameter_1;
		l_parameter_2 					:= 		p_parameter_2;
		l_comments							:=		p_comments;

	  hr_utility.set_location('p_ff_column_id: '||p_ff_column_id, 20);
	  hr_utility.set_location('p_column_phase: '||p_column_phase,20);
	  hr_utility.set_location('p_attribute: '||p_attribute, 20);
	  hr_utility.set_location('p_rule_type: '||p_rule_type, 20);
	  hr_utility.set_location('p_parameter_1: '||p_parameter_1, 20);
	  hr_utility.set_location('p_parameter_2: '||p_parameter_2, 20);
	  hr_utility.set_location('p_comments: '||p_comments, 20);

			for i in get_col_contexts_details(p_ff_column_id) loop
				if p_column_phase is null then
					l_column_phase := i.column_phase;
				end if;
				if p_attribute is null then
					l_attribute := i.attribute;
				end if;
				if p_rule_type is null then
					l_rule_type := i.rule_type;
				end if;
				if p_parameter_1 is null then
					l_parameter_1 := i.parameter_1;
				end if;
				if p_parameter_2 is null then
					l_parameter_2 := i.parameter_2;
				end if;
				if p_comments is null then
					l_comments := i.comments;
				end if;
			end loop;

		-- Update prt_drt_col_contexts
		  l_rec_x := per_drx_shd.convert_args			--bug#30447381
				(p_ff_column_id
				,p_column_id
				,null
				,null
				,null
				,l_column_phase
				,l_attribute
				,l_rule_type
				,l_parameter_1
				,l_parameter_2
				,l_comments
				);
		per_drx_bus.chk_parameter_values(l_rec_x);		--bug#30447381
  		per_drx_shd.lck(p_ff_column_id);

			BEGIN
			  hr_utility.set_location ('Entering:'|| l_proc,5);

				UPDATE  per_drt_col_contexts
				SET     column_phase = l_column_phase
				       ,attribute = l_attribute
				       ,rule_type = l_rule_type
				       ,parameter_1 = l_parameter_1
				       ,parameter_2 = l_parameter_2
				       ,comments = l_comments
				WHERE   ff_column_id = p_ff_column_id;

			  hr_utility.set_location (' Leaving:'|| l_proc,10);
			EXCEPTION
			  WHEN hr_api.check_integrity_violated THEN
			    per_drx_shd.constraint_error(p_constraint_name => hr_api.strip_constraint_name (sqlerrm) );
			  WHEN hr_api.parent_integrity_violated THEN
			    per_drx_shd.constraint_error(p_constraint_name => hr_api.strip_constraint_name (sqlerrm) );
			  WHEN hr_api.unique_integrity_violated THEN
			    per_drx_shd.constraint_error(p_constraint_name => hr_api.strip_constraint_name (sqlerrm) );
			  WHEN others THEN
			    RAISE;
			END;

				hr_utility.set_location('Leaving: '||l_proc, 80);

	 exception
	  when others then
	    --
	    -- A validation or unexpected error has occured
	    --
	    rollback to update_col_contexts_metadata;
	    hr_utility.set_location('Leaving: '||l_proc, 100);
	    raise;
	end;
	end if;

end update_seeded_metadata;

  PROCEDURE delete_seeded_metadata
    (p_table_id     IN number DEFAULT NULL
    ,p_column_id    IN number DEFAULT NULL
    ,p_ff_column_id IN number DEFAULT NULL) is
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
		l_proc := g_package||'delete_seeded_metadata';
		hr_utility.set_location('Entering:'|| l_proc, 10);
	  end if;
	  --
	  -- Issue a savepoint
	  --
	  savepoint delete_seeded_metadata;
	  hr_utility.set_location(l_proc, 20);

	  hr_utility.set_location('p_table_id: '||p_table_id, 20);
	  hr_utility.set_location('p_column_id: '||p_column_id, 20);
	  hr_utility.set_location('p_ff_column_id: '||p_ff_column_id, 20);


-- Bug # 30577806
		if((p_table_id is not null and p_column_id is not null)
				or (p_column_id is not null and p_ff_column_id is not null)
				or (p_ff_column_id is not null and p_table_id is not null)) then

			  hr_utility.set_location('Error: Only one parameter amoing table_id, column_id and ff_column_id need to be passed',25);
				RAISE_APPLICATION_ERROR (-20001, 'Error: Only one parameter amoing table_id, column_id and ff_column_id need to be passed.');
		end if;

		if (p_ff_column_id is not null) then
				hr_utility.set_location('Before deletion for p_ff_column_id: '||p_ff_column_id, 30);
				per_drx_shd.lck(p_ff_column_id);
				BEGIN
				  hr_utility.set_location ('Entering:'|| l_proc,30);
				  DELETE FROM per_drt_col_contexts WHERE ff_column_id = p_ff_column_id;
				  hr_utility.set_location (' Leaving:'|| l_proc,30);
				EXCEPTION
				  WHEN hr_api.child_integrity_violated THEN
				    per_drx_shd.constraint_error(p_constraint_name => hr_api.strip_constraint_name (sqlerrm) );
				  WHEN others THEN
				    RAISE;
				END;
				hr_utility.set_location('Deletion processed for p_ff_column_id: '||p_ff_column_id, 30);
			end if;


		-- Delete from per_drt_columns
		if (p_column_id is not null) then
				-- Delete from child per_drt_col_contexts first
				for i in get_ff_column_id(p_column_id)
					loop
						hr_utility.set_location('Before deletion for l_ff_column_id: '||i.ff_column_id, 40);
						per_drx_shd.lck(i.ff_column_id);
						BEGIN
						  hr_utility.set_location ('Entering:'|| l_proc,40);
						  DELETE FROM per_drt_col_contexts WHERE ff_column_id = i.ff_column_id;
						  hr_utility.set_location (' Leaving:'|| l_proc,40);
						EXCEPTION
						  WHEN hr_api.child_integrity_violated THEN
						    per_drx_shd.constraint_error(p_constraint_name => hr_api.strip_constraint_name (sqlerrm) );
						  WHEN others THEN
						    RAISE;
						END;
						hr_utility.set_location('Deletion processed for l_ff_column_id: '||i.ff_column_id, 40);
					end loop;
				-- Now delete from per_drt_columns
				hr_utility.set_location('Before deletion for column_id: '||p_column_id, 50);
						per_drc_shd.lck(p_column_id);
						BEGIN
  						hr_utility.set_location ('Entering:'|| l_proc,50);
  						DELETE FROM per_drt_columns WHERE column_id = p_column_id;
  						hr_utility.set_location (' Leaving:'|| l_proc,50);
						EXCEPTION
  						WHEN hr_api.child_integrity_violated THEN
    						per_drc_shd.constraint_error(p_constraint_name => hr_api.strip_constraint_name (sqlerrm) );
 						  WHEN others THEN
    						RAISE;
						END;
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
								per_drx_shd.lck(j.ff_column_id);
								BEGIN
								  hr_utility.set_location ('Entering:'|| l_proc,60);
								  DELETE FROM per_drt_col_contexts WHERE ff_column_id = j.ff_column_id;
								  hr_utility.set_location (' Leaving:'|| l_proc,60);
								EXCEPTION
								  WHEN hr_api.child_integrity_violated THEN
								    per_drx_shd.constraint_error(p_constraint_name => hr_api.strip_constraint_name (sqlerrm) );
								  WHEN others THEN
								    RAISE;
								END;
								hr_utility.set_location('Deletion processed for l_ff_column_id: '||j.ff_column_id, 60);
							end loop;
						hr_utility.set_location('Before deletion for l_column_id: '||i.column_id, 70);
						per_drc_shd.lck(i.column_id);
						BEGIN
  						hr_utility.set_location ('Entering:'|| l_proc,70);
  						DELETE FROM per_drt_columns WHERE column_id = i.column_id;
  						hr_utility.set_location (' Leaving:'|| l_proc,70);
						EXCEPTION
  						WHEN hr_api.child_integrity_violated THEN
    						per_drc_shd.constraint_error(p_constraint_name => hr_api.strip_constraint_name (sqlerrm) );
 						  WHEN others THEN
    						RAISE;
						END;
						hr_utility.set_location('Deletion processed for l_column_id: '||i.column_id, 70);
					end loop;
				-- Now delete from per_drt_tables
	    	hr_utility.set_location('Before deletion for p_table_id: '||p_table_id, 80);
				  per_drt_shd.lck(p_table_id);
					BEGIN
					  hr_utility.set_location ('Entering:'|| l_proc,80);
						DELETE FROM per_drt_tables WHERE table_id = p_table_id;
					  hr_utility.set_location (' Leaving:'|| l_proc,80);
					EXCEPTION
					  WHEN hr_api.child_integrity_violated THEN
					    per_drt_shd.constraint_error(p_constraint_name => hr_api.strip_constraint_name (sqlerrm) );
					  WHEN others THEN
					    RAISE;
					END;
	    	hr_utility.set_location('Deletion processed for p_table_id: '||p_table_id, 80);
	  end if;

	exception
	  when others then
	    --
	    -- A validation or unexpected error has occured
	    --
	    rollback to delete_seeded_metadata;
	    hr_utility.set_location('Leaving: '||l_proc, 100);
	    raise;
	end delete_seeded_metadata;

END PER_DRT_METADATA;

/
