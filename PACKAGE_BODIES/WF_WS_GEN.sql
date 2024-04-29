--------------------------------------------------------
--  DDL for Package Body WF_WS_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_WS_GEN" as
/* $Header: WFWSGENB.pls 120.12.12010000.2 2009/07/14 11:19:02 smunnalu ship $ */


procedure create_derived_class_entry
	(
	p_base_class_id in number,
	p_class_name in varchar2,
	p_irep_name  in varchar2,
	p_created_by in pls_integer,
	p_creation_date in date,
	p_security_group_id in number,
	p_class_type in varchar2,
	p_product_code in varchar,
	p_implementation_name in varchar2,
	p_deployed_flag in varchar2,
	p_generated_flag in varchar2,
	p_compatibility_flag in varchar,
	p_assoc_class_id in pls_integer,
	p_scope_type in varchar,
	p_lifecycle_mode in varchar,
	p_source_file_product in varchar,
	p_source_file_path in varchar,
	p_source_file_name in varchar,
	p_source_file_version in varchar,
	p_description in varchar,
	p_xml_description in clob,
	p_standard_type in varchar,
	p_standard_version in varchar,
	p_standard_spec in varchar2,
	p_load_err in varchar2,
	p_load_err_msgs in varchar2,
	p_open_interface_flag in varchar2,
	p_map_code in varchar2,
	p_class_id_out OUT NOCOPY pls_integer,
	p_err_code OUT NOCOPY pls_integer,
	p_err_message OUT NOCOPY varchar2
	) ;

procedure create_class_lang_entries
	(
	p_base_class_id in number,
	p_class_id in number,
	p_err_code OUT NOCOPY pls_integer,
	p_err_message OUT NOCOPY varchar2
	);


procedure create_class_language
	(
	p_class_id  in number,
	p_language in varchar2,
	p_source_lang in varchar2,
	p_display_name in varchar2,
	p_short_description in varchar2,
	p_security_group_id in number,
	p_err_code OUT NOCOPY pls_integer,
	p_err_message OUT NOCOPY varchar2
	) ;


procedure create_derived_method_entry
	(
	p_function_name in varchar,
	p_application_id in number,
	p_form_id in number,
	p_parameters in varchar2,
	p_creation_date in date,
	p_created_by in pls_integer,
	p_type in varchar2,
	p_web_host_name in varchar2,
	p_web_agent_name in varchar2,
	p_web_html_call in varchar2,
	p_web_encrypt_parameters in varchar2,
	p_web_secured in varchar2,
	p_web_icon in varchar2,
	p_object_id in pls_integer,
	p_region_application_id in pls_integer,
	p_region_code in varchar2,
	p_maintenance_mode_support in varchar2,
	p_context_dependence in varchar2,
	p_jrad_ref_path in varchar2,
	p_irep_method_name  in varchar2,
	p_irep_overload_sequence in pls_integer,
	p_irep_scope in varchar2,
	p_irep_lifecycle in varchar2,
	p_irep_description in clob,
	p_irep_compatibility in varchar2,
	p_irep_inbound_xml_desc in clob,
	p_irep_outbound_xml_desc in clob,
	p_irep_synchro in varchar2,
	p_irep_direction in varchar2,
	p_irep_assoc_function_name in varchar2,
	p_irep_class_id in pls_integer,
	p_base_function_id in number,
	p_err_code OUT NOCOPY pls_integer,
	p_err_message OUT NOCOPY varchar2
	) ;

procedure create_function_lang_entries
	(
	p_base_function_id in number,
	p_function_id in number,
	p_err_code OUT NOCOPY pls_integer,
	p_err_message OUT NOCOPY varchar2
	);


procedure create_function_language
	(
	p_function_id  in number,
	p_language in varchar2,
	p_user_function_name in varchar2,
	p_description in varchar2,
	p_source_lang in varchar2,
	p_err_code OUT NOCOPY pls_integer,
	p_err_message OUT NOCOPY varchar2
	) ;

procedure create_xmlg_schema
	(
	p_clob OUT NOCOPY clob,
	p_root_element in varchar,
	p_product_code in varchar2,
	p_direction in varchar,
	p_port_type in varchar,
	p_operation in varchar,
	p_err_code OUT NOCOPY pls_integer,
	p_err_message OUT NOCOPY varchar2
	) ;

procedure to_upper
	(
	p_name in varchar2,
	p_new_name OUT NOCOPY varchar2,
	p_err_code OUT NOCOPY pls_integer,
	p_err_message OUT NOCOPY varchar2
	) ;

procedure assign_business_entities
	(
	p_base_class_id in number,
	p_derived_class_id in number,
	p_err_code OUT NOCOPY pls_integer,
	p_err_message OUT NOCOPY varchar2
	) ;
procedure ws_base_method_overload
	(
	p_function_id in number,
	p_description in varchar2,
	p_scope_type in varchar2,
	p_irep_lifecycle in varchar2,
	p_irep_compatibility_flag in varchar2,
	p_err_code OUT NOCOPY pls_integer,
	p_err_message OUT NOCOPY varchar2
	);

procedure wf_ws_create
	(
	p_module_name in varchar,
	p_err_code OUT NOCOPY pls_integer,
	p_err_message OUT NOCOPY varchar2
	)
  is

	cursor 	c_classes(c_module_name in varchar) is
	select class_id,class_type
	from fnd_irep_classes
	where class_type = c_module_name ;

	l_count pls_integer := 0;

begin
	for c1 in c_classes(p_module_name)
	loop
		l_count := l_count + 1;
		begin
			if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'oracle.apps.fnd.wf.ws.create_derived_entry', 'Processing Base Class='||c1.class_id);
			end if;

			create_derived_entry(c1.class_id,p_err_code,p_err_message);

			if ( p_err_code = -1 ) then
				if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
					FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'oracle.apps.fnd.wf.ws.create_derived_entry', '	Error Code='||p_err_code||', Error Message='||p_err_message);
				end if;
			end if;
		exception
		when  program_exit then
			if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'oracle.apps.fnd.wf.ws.create_derived_entry', 'Error Code='||p_err_code||', Error Message='||p_err_message);
			end if;
		end;
	end loop;

	if  l_count = 0  then

		p_err_code := -1;
		wf_core.token('Module',p_module_name);
		p_err_message := wf_core.translate('WF_WS_MODULE_NO_ENTRIES');
	else
		p_err_code := 0;
		wf_core.token('Module',p_module_name);
		p_err_message := wf_core.translate('WF_WS_MODULE_SUCCESS');

	end if;

exception
when program_exit then
	null;
when others then
	p_err_code := -1;
	wf_core.token('Module',p_module_name);
	wf_core.token('SqlErr',SQLERRM);
	p_err_message := wf_core.translate('WF_WS_MODULE_FAILED');
end wf_ws_create;

procedure create_derived_entry
	(
	p_interface_irep_name IN varchar2,
	p_err_code OUT NOCOPY pls_integer,
	p_err_message OUT NOCOPY varchar2
	)
  is
	cursor 	c_class_id(c_irep_class_name in varchar2) is
	select  class_id
	from fnd_irep_classes
	where irep_name = c_irep_class_name;

	l_derived_interface_name varchar2(2000) := null;
	l_count pls_integer := 0;

begin
	l_derived_interface_name := 'WEBSERVICEDOC:'||p_interface_irep_name;

	if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'oracle.apps.fnd.wf.ws.create_derived_entry', 'Derived Interface Name='||l_derived_interface_name);
	end if;

	for c1 in c_class_id(p_interface_irep_name)
	loop
		l_count := l_count + 1;
		create_derived_entry(c1.class_id,p_err_code,p_err_message);
	end loop;

	if  l_count = 0  then

		p_err_code := -1;
		wf_core.token('BaseInterface',p_interface_irep_name);
		p_err_message := wf_core.translate('WF_WS_BASE_INTF_NOT_EXIST');

	elsif ( p_err_code = -1 ) then
		null;
	else

		p_err_code := 0;
		p_err_message := wf_core.translate('WF_WS_SUCCESS');

	end if;


exception
when program_exit then
	raise program_exit;
when others then
	p_err_code := -1;
	p_err_message := SQLERRM;
	raise;
end create_derived_entry;




/**
Procedure for creating a Web Service Entry for a given Base Entry Interface
**/
procedure create_derived_entry
	(
	p_base_class_id in pls_integer,
	x_derived_class_id OUT NOCOPY pls_integer,
	x_irep_name OUT NOCOPY varchar2,
	p_err_code OUT NOCOPY pls_integer,
	p_err_message OUT NOCOPY varchar2
	)

is
	cursor c_class(c_class_id in number) is
 	select count(*) l_count
 	from fnd_irep_classes
 	where class_id = c_class_id;

        cursor c_class_name(c_class_id in number) is
        select class_name ,irep_name
        from fnd_irep_classes
        where class_id = c_class_id;

 	c_class_rec c_class%ROWTYPE;

	cursor 	c_methods(c_class_id in number) is
	select function_id
	from fnd_form_functions
	where irep_class_id = c_class_id ;

	method_count pls_integer := 0;
	p_base_class_name varchar2(430) := null;
begin
	if (p_base_class_id is null ) then
		p_err_code := -1;
		p_err_message := wf_core.translate('WF_WS_MISSING_CLASS_ID');
		raise program_exit;
	end if;

	if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'oracle.apps.fnd.wf.ws.create_derived_entry', 'Process Class ID='||p_base_class_id);
	end if;

	open c_class(p_base_class_id);
	fetch c_class into c_class_rec;
	close c_class;

        open c_class_name(p_base_class_id);
        fetch c_class_name into p_base_class_name,x_irep_name;
        close c_class_name;

	if c_class_rec.l_count = 0 then
		p_err_code := -1;
		wf_core.token('BaseClassId',p_base_class_id);
		p_err_message := wf_core.translate('WF_WS_BASE_CLASS_NOT_EXIST');
		raise program_exit;
	end if;

	for c1 in c_methods(p_base_class_id)
	loop
		method_count := method_count + 1;

		if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'oracle.apps.fnd.wf.ws.create_derived_entry', 'Processing FunctionID='||c1.function_id);
		end if;


		begin
	                create_derived_entry(p_base_class_id,c1.function_id,x_derived_class_id,p_err_code,p_err_message);
		exception
		when ignore_rec  then
			null;
		when program_exit then
			raise program_exit;
		when others then
			p_err_code := -1;
			wf_core.token('BaseClassId',p_base_class_id);
                        wf_core.token('BaseClassName', p_base_class_name);
			wf_core.token('FunctionId',c1.function_id);
			wf_core.token('SqlErr',SQLERRM);
			p_err_message := wf_core.translate('WF_WS_CLASS_FUNC_ITER');
			raise program_exit;
		end;

	end loop;

	wf_core.token('BaseClassId',p_base_class_id);
        wf_core.token('BaseClassName', p_base_class_name);
	if (method_count = 0 ) then
		p_err_code := -1;
		p_err_message := wf_core.translate('WF_WS_NO_BASE_METHODS');
	elsif ( method_count > 0 ) then
		p_err_code := 0;
		p_err_message := wf_core.translate('WF_WS_SUCCESS');
	end if;

exception
when program_exit then
	null;
when others then
	p_err_code := -1;
	wf_core.token('BaseClassId',p_base_class_id);
        wf_core.token('BaseClassName', p_base_class_name);
	wf_core.token('SqlErr',SQLERRM);
	p_err_message := wf_core.translate('WF_WS_CLASS_DERIVED');
end create_derived_entry;


/**
Procedure for creating a Web Service Entry for a given Base Entry
This will create the derived entries by grouping for XMLGateway
**/
procedure create_derived_entry
	(
	p_base_class_id in pls_integer,
	p_base_function_id in pls_integer,
	l_derived_class_id OUT NOCOPY pls_integer,
	p_err_code OUT NOCOPY pls_integer,
	p_err_message OUT NOCOPY varchar2
	)

is

	cursor c_base_class_entry(c_base_class_id in number) is
	select 	*
	from fnd_irep_classes_vl
	where class_id = c_base_class_id;

	c_base_class_entry_rec c_base_class_entry%ROWTYPE;

	cursor c_base_function_entry(c_base_function_id in number) is
	select  *
	from fnd_form_functions_vl
	where function_id = c_base_function_id;

	c_base_function_entry_rec c_base_function_entry%ROWTYPE;

	i_function_name varchar2(2000) :=null;
	i_port_type varchar2(2000) := null;
	i_operation varchar2(2000) := null;
	i_delimitor pls_integer;
	i_delimitor2 pls_integer;
	i_derived_class_name varchar2(2000) := null;
	i_xmlg_prefix varchar2(2000) := null;
        i_root_element varchar2(255) := null;

--	l_derived_class_id pls_integer;
	in_xml clob := null;
	out_xml clob := null;

begin
	/**Get the base entry**
	**If its XML Gateway then care about grouping otherwise don't**
	**/


	if ( (p_base_class_id is null) or (p_base_function_id is null)) then
		p_err_code := -1;
		p_err_message := wf_core.translate('WF_WS_MISSING_CLASS_FUNC_ID');
		raise program_exit;
	end if;


	/*Get the Base Entry class**/
	open c_base_class_entry(p_base_class_id);
	fetch c_base_class_entry into c_base_class_entry_rec;

	if c_base_class_entry%NOTFOUND then

		if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'oracle.apps.fnd.wf.ws.create_derived_entry', 'Base Class ID='||p_base_class_id||' does not exist');
		end if;

		p_err_code := -1;
		p_err_message := wf_core.translate('WF_WS_BASE_CLASS_NOT_EXIST');
		raise program_exit;

	elsif c_base_class_entry%FOUND then


		if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
			FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'oracle.apps.fnd.wf.ws.create_derived_entry', 'Base Class ID='||p_base_class_id||' exists');
		end if;

		open c_base_function_entry(p_base_function_id);
		fetch c_base_function_entry into c_base_function_entry_rec;

		if c_base_function_entry%FOUND then

			if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'oracle.apps.fnd.wf.ws.create_derived_entry', 'Base Function='||p_base_function_id||' exist');
			end if;

			if ( c_base_function_entry_rec.irep_class_id <> p_base_class_id ) then
				p_err_code :=-1;
				p_err_message := wf_core.translate('WF_WS_CLASS_FUNC_MISMATCH');
				raise program_exit;
			end if;

			if ( c_base_class_entry_rec.scope_type = 'PUBLIC' AND c_base_function_entry_rec.irep_scope = 'PUBLIC' ) then

				if ( c_base_class_entry_rec.class_type = 'XMLGATEWAY' ) then

					if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
						FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'oracle.apps.fnd.wf.ws.create_derived_entry', 'Class Type:XMLGATEWAY ');
					end if;

					if ( upper(c_base_function_entry_rec.irep_direction) = 'O' ) then

						if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
							FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'oracle.apps.fnd.wf.ws.create_derived_entry', 'Ignoring Outbound Entry ');
						end if;


						p_err_code :=-1;
						p_err_message := wf_core.translate('WF_WS_XMLG_OUTBOUND');
						raise ignore_rec;
					end if;

					/**
					Base
					class Name							irep_name
					XMLGATEWAY:AR:PROCESS_INVOICE					AR:PROCESS_INVOICE

					Function Name
					XMLGATEWAY:AR:PROCESS_INVOICE:PROCESS_INVOICE			PROCESS_INVOICE

					Derived
					WEBSERVICEDOC:oracle.apps.ar.Ar.ProcessInvoice			oracle.apps.ar.Ar

					Function Name
					WEBSERVICEDOC:oracle.apps.ar.Ar.ProcessInvoice.ProcessInvoice	oracle.apps.ar.Ar.ProcessInvoice
					**/

					i_function_name := c_base_class_entry_rec.irep_name;

					if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
						FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'oracle.apps.fnd.wf.ws.create_derived_entry', 'Function Name='||c_base_function_entry_rec.function_name||', Irep Name='||i_function_name );
					end if;

					i_delimitor := instr(i_function_name,':',1);
					--i_delimitor2 := instr(c_base_function_entry_rec.function_name,':',1,2);


					if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
						FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'oracle.apps.fnd.wf.ws.create_derived_entry', 'Delimitor1 ='||i_delimitor||', Delimitor2='||i_delimitor2 );
					end if;


					if ( i_delimitor <> 0 ) then

						i_port_type := substr(i_function_name,1,i_delimitor-1);
						i_port_type := replace(initcap(i_port_type),'_','');
						i_operation := substr(i_function_name,i_delimitor+1,length(i_function_name)-i_delimitor);
						i_operation := replace(initcap(i_operation),'_','');

						i_xmlg_prefix := 'oracle.apps.'||lower(c_base_class_entry_rec.product_code);
						i_derived_class_name :=i_xmlg_prefix||'.'||i_port_type||'.'||i_operation;

						if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
							FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'oracle.apps.fnd.wf.ws.create_derived_entry','Port Type='||i_port_type||',Operation='||i_operation);
						end if;

						if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
							FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'oracle.apps.fnd.wf.ws.create_derived_entry','Description='||c_base_class_entry_rec.description);
						end if;

						if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
							FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'oracle.apps.fnd.wf.ws.create_derived_entry','Method Description='||c_base_function_entry_rec.irep_description);
						end if;

						if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
							FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'oracle.apps.fnd.wf.ws.create_derived_entry','Derived Class Name='||i_derived_class_name);
						end if;

						create_derived_class_entry
						(
						c_base_class_entry_rec.class_id,
						'WEBSERVICEDOC:'||i_derived_class_name,
						i_derived_class_name,
						c_base_class_entry_rec.created_by,
						c_base_class_entry_rec.creation_date,
						c_base_class_entry_rec.security_group_id,
						'WEBSERVICEDOC',
						c_base_class_entry_rec.product_code,
						c_base_class_entry_rec.implementation_name,
						c_base_class_entry_rec.deployed_flag,
						c_base_class_entry_rec.generated_flag,
						c_base_class_entry_rec.compatibility_flag,
						c_base_class_entry_rec.class_id,
						c_base_class_entry_rec.scope_type,
						c_base_class_entry_rec.lifecycle_mode,
						c_base_class_entry_rec.source_file_product,
						c_base_class_entry_rec.source_file_path,
						c_base_class_entry_rec.source_file_name,
						c_base_class_entry_rec.source_file_version,
						c_base_class_entry_rec.description,
						c_base_class_entry_rec.xml_description,
						c_base_class_entry_rec.standard_type,
						c_base_class_entry_rec.standard_version,
						c_base_class_entry_rec.standard_spec,
						null,
						null,
						null,
                                                c_base_class_entry_rec.map_code,
						l_derived_class_id,
						p_err_code,
						p_err_message
						);

					        /**
						assign_business_entities
							(
							c_base_class_entry_rec.class_id,
							l_derived_class_id,
							p_err_code,
							p_err_message);
						**/

						/**
						1.Description for the Class/description and
						user function is an issue for XMLG entries
						2.Get the new field for root element
						**/
				                get_root_element
                                                (
                                                c_base_class_entry_rec.map_code,
                                                i_root_element,
                                                p_err_code,
                                                p_err_message
                                                );

						if c_base_function_entry_rec.irep_inbound_xml_description is null then
							create_xmlg_schema
							(
							in_xml,
                                                        i_root_element,
							c_base_class_entry_rec.product_code,
							'IN',
							i_port_type,
                                                        i_operation,
							p_err_code,
							p_err_message
							);
						else
							in_xml :=c_base_function_entry_rec.irep_inbound_xml_description;
						end if;

						if c_base_function_entry_rec.irep_outbound_xml_description is null then
							create_xmlg_schema
							(
							out_xml,
                                                        i_root_element,
							c_base_class_entry_rec.product_code,
							'OUT',
							i_port_type,
                                                        i_operation,
							p_err_code,
							p_err_message
							);
						else
							out_xml :=c_base_function_entry_rec.irep_outbound_xml_description;
						end if;

						create_derived_method_entry
						(
						'WEBSERVICEDOC:'||i_derived_class_name||':'||i_operation,
						c_base_function_entry_rec.application_id,
						c_base_function_entry_rec.form_id,
						c_base_function_entry_rec.parameters,
						c_base_function_entry_rec.creation_date,
						c_base_function_entry_rec.created_by,
						c_base_function_entry_rec.type,
						c_base_function_entry_rec.web_host_name,
						c_base_function_entry_rec.web_agent_name,
						c_base_function_entry_rec.web_html_call,
						c_base_function_entry_rec.web_encrypt_parameters,
						c_base_function_entry_rec.web_secured,
						c_base_function_entry_rec.web_icon,
						c_base_function_entry_rec.object_id,
						c_base_function_entry_rec.region_application_id,
						c_base_function_entry_rec.region_code,
						c_base_function_entry_rec.maintenance_mode_support,
						c_base_function_entry_rec.context_dependence,
						c_base_function_entry_rec.jrad_ref_path,
						i_derived_class_name||'.'||i_operation,
						c_base_function_entry_rec.irep_overload_sequence,
						c_base_function_entry_rec.irep_scope,
						c_base_function_entry_rec.irep_lifecycle,
						c_base_function_entry_rec.irep_description,
						c_base_function_entry_rec.irep_compatibility,
						in_xml,
						out_xml,
						c_base_function_entry_rec.irep_synchro,
						c_base_function_entry_rec.irep_direction,
						c_base_function_entry_rec.function_name,
						l_derived_class_id,
						p_base_function_id,
						p_err_code,
						p_err_message
						);

					else
						if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
							FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'oracle.apps.fnd.wf.ws.create_derived_entry', 'Invalid Function Name does not have : ');
						end if;

						p_err_code := -1;
						p_err_message :=wf_core.translate('WF_WS_XMLG_INVALID_ENTRY');
					end if;

				elsif ( c_base_class_entry_rec.class_type = 'SERVICEBEAN') then

					if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
						FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'oracle.apps.fnd.wf.ws.create_derived_entry', 'Class Type:SERVICEBEAN ');
					end if;

					i_function_name := c_base_class_entry_rec.irep_name;



					i_port_type := i_function_name;
					i_derived_class_name := i_port_type;

					i_operation := c_base_function_entry_rec.irep_method_name;
					dbms_output.put_line('I_Operation='||i_operation||'x');
					dbms_output.put_line('I_Operation length='||length(i_operation)||'x');
					if ( (i_operation is null ) or (length(i_operation) is NULL ) ) then
						p_err_code := -1;
						p_err_message :=wf_core.translate('WF_WS_MISSING_IREP_METHOD_NAME');
						raise program_exit;
					end if;

					create_derived_class_entry
					(
					c_base_class_entry_rec.class_id,
					'WEBSERVICEDOC:'||i_derived_class_name,
					i_derived_class_name,
					c_base_class_entry_rec.created_by,
					c_base_class_entry_rec.creation_date,
					c_base_class_entry_rec.security_group_id,
					'WEBSERVICEDOC',
					c_base_class_entry_rec.product_code,
					c_base_class_entry_rec.implementation_name,
					c_base_class_entry_rec.deployed_flag,
					c_base_class_entry_rec.generated_flag,
					c_base_class_entry_rec.compatibility_flag,
					c_base_class_entry_rec.class_id,
					c_base_class_entry_rec.scope_type,
					c_base_class_entry_rec.lifecycle_mode,
					c_base_class_entry_rec.source_file_product,
					c_base_class_entry_rec.source_file_path,
					c_base_class_entry_rec.source_file_name,
					c_base_class_entry_rec.source_file_version,
					c_base_class_entry_rec.description,
					c_base_class_entry_rec.xml_description,
					c_base_class_entry_rec.standard_type,
					c_base_class_entry_rec.standard_version,
					c_base_class_entry_rec.standard_spec,
					null,
					null,
					null,
                                        c_base_class_entry_rec.map_code,
					l_derived_class_id,
					p_err_code,
					p_err_message
					);
					/**
					assign_business_entities
					(
					c_base_class_entry_rec.class_id,
					l_derived_class_id,
					p_err_code,
					p_err_message
					);
					**/


					/**What should be the value for description and user_function in method tl table**/
					i_operation := upper(substr(i_operation,0,1))||substr(i_operation,2,length(i_operation));
					create_derived_method_entry
					(
					'WEBSERVICEDOC:'||i_derived_class_name||':'||i_operation,
					c_base_function_entry_rec.application_id,
					c_base_function_entry_rec.form_id,
					c_base_function_entry_rec.parameters,
					c_base_function_entry_rec.creation_date,
					c_base_function_entry_rec.created_by,
					c_base_function_entry_rec.type,
					c_base_function_entry_rec.web_host_name,
					c_base_function_entry_rec.web_agent_name,
					c_base_function_entry_rec.web_html_call,
					c_base_function_entry_rec.web_encrypt_parameters,
					c_base_function_entry_rec.web_secured,
					c_base_function_entry_rec.web_icon,
					c_base_function_entry_rec.object_id,
					c_base_function_entry_rec.region_application_id,
					c_base_function_entry_rec.region_code,
					c_base_function_entry_rec.maintenance_mode_support,
					c_base_function_entry_rec.context_dependence,
					c_base_function_entry_rec.jrad_ref_path,
					i_operation,
					c_base_function_entry_rec.irep_overload_sequence,
					c_base_function_entry_rec.irep_scope,
					c_base_function_entry_rec.irep_lifecycle,
					c_base_function_entry_rec.irep_description,
					c_base_function_entry_rec.irep_compatibility,
					c_base_function_entry_rec.irep_inbound_xml_description,
					c_base_function_entry_rec.irep_outbound_xml_description,
					c_base_function_entry_rec.irep_synchro,
					c_base_function_entry_rec.irep_direction,
					c_base_function_entry_rec.function_name,
					l_derived_class_id,
					p_base_function_id,
					p_err_code,
					p_err_message
					);

				end if;
			else
				if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
					FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'oracle.apps.fnd.wf.ws.create_derived_entry', 'ClassID,FunctionID:'||c_base_class_entry_rec.class_id||','||c_base_function_entry_rec.function_id||' Not a public interface/method to be exposed');
				end if;

				p_err_code := -1;
				p_err_message := wf_core.translate('WF_WS_NOT_PUBLIC');
				raise program_exit;
			end if;
		else
			if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'oracle.apps.fnd.wf.ws.create_derived_entry', ' No records found for FunctionID='||c_base_function_entry_rec.function_id);
			end if;

			p_err_code := -1;
			p_err_message := wf_core.translate('WF_WS_BASE_FUNC_NOT_EXIST');
			raise program_exit;
		end if;

		close c_base_function_entry;
	end if;

	close c_base_class_entry;

	p_err_code := 0;
	wf_core.token('ClassId',p_base_class_id);
	p_err_message :=wf_core.translate('WF_WS_SUCCESS');

exception
when ignore_rec then
	raise ignore_rec;
when program_exit then
	raise program_exit;
when others then
	p_err_code := -1;
	p_err_message :=wf_core.translate('WF_WS_GENERIC_CLASS_ERROR')||'Error in Creating Derived Entry for Base FUNCTION_ID='||p_base_function_id||SQLERRM;
	raise program_exit;
end create_derived_entry;

procedure create_derived_class_entry
	(
	p_base_class_id in number,
	p_class_name in varchar2,
	p_irep_name  in varchar2,
	p_created_by in pls_integer,
	p_creation_date in date,
	p_security_group_id in number,
	p_class_type in varchar2,
	p_product_code in varchar,
	p_implementation_name in varchar2,
	p_deployed_flag in varchar2,
	p_generated_flag in varchar2,
	p_compatibility_flag in varchar,
	p_assoc_class_id in pls_integer,
	p_scope_type in varchar,
	p_lifecycle_mode in varchar,
	p_source_file_product in varchar,
	p_source_file_path in varchar,
	p_source_file_name in varchar,
	p_source_file_version in varchar,
	p_description in varchar,
	p_xml_description in clob,
	p_standard_type in varchar,
	p_standard_version in varchar,
	p_standard_spec in varchar2,
	p_load_err in varchar2,
	p_load_err_msgs in varchar2,
	p_open_interface_flag in varchar2,
	p_map_code in varchar2,
	p_class_id_out OUT NOCOPY pls_integer,
	p_err_code OUT NOCOPY pls_integer,
	p_err_message OUT NOCOPY varchar2
	)
is
	cursor c_derived_class(c_class_name in varchar) is
	select *
	from fnd_irep_classes
	where  class_name = c_class_name
	and class_type = 'WEBSERVICEDOC'
	for update ;

	cursor c_irep_class_id is
		select fnd_objects_s.nextval
		from dual;

	l_class_id number;


	c_derived_class_rec c_derived_class%ROWTYPE;

begin

	if ( (p_class_name is null) or (p_base_class_id is null) ) then
		p_err_code := -1;
		p_err_message := wf_core.translate('WF_WS_CLASS_NAME_IS_NULL');
		raise program_exit;
	end if;

	open c_derived_class(p_class_name);
	fetch c_derived_class into c_derived_class_rec;

	if c_derived_class%NOTFOUND then

		begin

			open c_irep_class_id;
			fetch c_irep_class_id into l_class_id;
			close c_irep_class_id;

			insert into FND_IREP_CLASSES
			(
			CLASS_ID,
			CLASS_NAME,
			IREP_NAME,
			CREATED_BY,
			CREATION_DATE,
			LAST_UPDATED_BY,
			LAST_UPDATE_DATE,
			LAST_UPDATE_LOGIN,
			SECURITY_GROUP_ID,
			CLASS_TYPE,
			PRODUCT_CODE,
			IMPLEMENTATION_NAME,
			DEPLOYED_FLAG,
			GENERATED_FLAG,
			COMPATIBILITY_FLAG,
			ASSOC_CLASS_ID,
			SCOPE_TYPE,
			LIFECYCLE_MODE,
			SOURCE_FILE_PRODUCT,
			SOURCE_FILE_PATH,
			SOURCE_FILE_NAME,
			SOURCE_FILE_VERSION,
			DESCRIPTION,
			XML_DESCRIPTION,
			STANDARD_TYPE,
			STANDARD_VERSION,
			STANDARD_SPEC,
			LOAD_ERR,
			LOAD_ERR_MSGS,
			OPEN_INTERFACE_FLAG,
                        MAP_CODE
			)
			values
			(
			l_class_id,
			p_class_name,
			p_irep_name,
			0,
			sysdate,
			0,
			sysdate,
			0,
			0,
			'WEBSERVICEDOC',
			p_product_code,
			p_implementation_name,
			'Y', -- p_deployed_flag,
			p_generated_flag,
			p_compatibility_flag,
			p_assoc_class_id,
			p_scope_type,
			p_lifecycle_mode,
			p_source_file_product,
			p_source_file_path,
			p_source_file_name,
			p_source_file_version,
			p_description,
			p_xml_description,
			p_standard_type,
			p_standard_version,
			p_standard_spec,
			p_load_err,
			p_load_err_msgs,
			p_open_interface_flag,
                        p_map_code
			);

			create_class_lang_entries
			(
			p_base_class_id ,
			l_class_id ,
			p_err_code,
			p_err_message
			);

		exception
		when program_exit then
			raise program_exit;
		when others then
			p_err_code := -1;
			p_err_message := wf_core.translate('WF_WS_CLASS_INSERT')||SQLERRM;
		end;

		p_class_id_out := l_class_id;

	elsif c_derived_class%FOUND then
		--Update the existing record

		begin
			update fnd_irep_classes
			set	irep_name = p_irep_name,
				last_updated_by = 0,
				last_update_date = sysdate,
				last_update_login = 0,
				security_group_id = p_security_group_id,
				class_type = p_class_type,
				product_code = p_product_code,
				implementation_name = p_implementation_name,
				deployed_flag = 'Y', -- p_deployed_flag,
				generated_flag = p_generated_flag,
				compatibility_flag = p_compatibility_flag,
				assoc_class_id = p_assoc_class_id,
				scope_type = p_scope_type,
				lifecycle_mode = p_lifecycle_mode,
				source_file_product = p_source_file_product,
				source_file_path = p_source_file_path,
				source_file_name = p_source_file_name,
				source_file_version = p_source_file_version,
				description = p_description,
				xml_description = p_xml_description,
				standard_type = p_standard_type,
				standard_version = p_standard_version,
				standard_spec = p_standard_spec,
				load_err = p_load_err,
				load_err_msgs = p_load_err_msgs,
				open_interface_flag = p_open_interface_flag

			where current of c_derived_class;

			create_class_lang_entries
			(
			p_base_class_id ,
			c_derived_class_rec.class_id ,
			p_err_code,
			p_err_message
			);
		exception
		when program_exit then
			raise program_exit;
		when others then
			p_err_code := -1;
			p_err_message := wf_core.translate('WF_WS_CLASS_UPDATE')||SQLERRM;
		end;

		p_class_id_out := c_derived_class_rec.class_id;
	end if;

	close c_derived_class;

	p_err_code := 0;
	p_err_message := wf_core.translate('WF_WS_SUCCESS');
exception
when program_exit then
	raise program_exit;
when others then
	p_err_code := -1;
	wf_core.token('BaseClassName',p_class_name);
	wf_core.token('SqlErr',SQLERRM);
	p_err_message := wf_core.translate('WF_WS_CLASS_CREATE');
	raise program_exit;
end create_derived_class_entry;


procedure create_derived_method_entry
	(
	p_function_name in varchar,
	p_application_id in number,
	p_form_id in number,
	p_parameters in varchar2,
	p_creation_date in date,
	p_created_by in pls_integer,
	p_type in varchar2,
	p_web_host_name in varchar2,
	p_web_agent_name in varchar2,
	p_web_html_call in varchar2,
	p_web_encrypt_parameters in varchar2,
	p_web_secured in varchar2,
	p_web_icon in varchar2,
	p_object_id in pls_integer,
	p_region_application_id in pls_integer,
	p_region_code in varchar2,
	p_maintenance_mode_support in varchar2,
	p_context_dependence in varchar2,
	p_jrad_ref_path in varchar2,
	p_irep_method_name  in varchar2,
	p_irep_overload_sequence in pls_integer,
	p_irep_scope in varchar2,
	p_irep_lifecycle in varchar2,
	p_irep_description in clob,
	p_irep_compatibility in varchar2,
	p_irep_inbound_xml_desc in clob,
	p_irep_outbound_xml_desc in clob,
	p_irep_synchro in varchar2,
	p_irep_direction in varchar2,
	p_irep_assoc_function_name in varchar2,
	p_irep_class_id in pls_integer,
	p_base_function_id in number,
	p_err_code OUT NOCOPY pls_integer,
	p_err_message OUT NOCOPY varchar2
	)
is
	cursor c_derived_method(c_function_name in varchar, c_type in varchar) is
	select *
	from fnd_form_functions
	where  function_name = c_function_name
	and type =c_type
	for update;

	cursor c_irep_function_id is
	select fnd_form_functions_s.nextval
	from dual;

	l_function_id number := 0;


	c_derived_method_rec c_derived_method%ROWTYPE;

begin
	open c_derived_method(p_function_name, p_type);
	fetch c_derived_method into c_derived_method_rec;

	if c_derived_method%NOTFOUND then

		begin

			open c_irep_function_id;
			fetch c_irep_function_id into l_function_id;
			close c_irep_function_id;

			insert into FND_FORM_FUNCTIONS
			(
			 FUNCTION_ID,
			 FUNCTION_NAME,
			 APPLICATION_ID,
			 FORM_ID,
			 PARAMETERS,
			 CREATION_DATE,
			 CREATED_BY,
			 LAST_UPDATE_DATE,
			 LAST_UPDATED_BY,
			 LAST_UPDATE_LOGIN,
			 TYPE,
			 WEB_HOST_NAME,
			 WEB_AGENT_NAME,
			 WEB_HTML_CALL,
			 WEB_ENCRYPT_PARAMETERS,
			 WEB_SECURED,
			 WEB_ICON,
			 OBJECT_ID,
			 REGION_APPLICATION_ID,
			 REGION_CODE,
			 MAINTENANCE_MODE_SUPPORT,
			 CONTEXT_DEPENDENCE,
			 JRAD_REF_PATH,
			 IREP_METHOD_NAME,
			 IREP_DESCRIPTION,
			 IREP_OVERLOAD_SEQUENCE,
			 IREP_SCOPE,
			 IREP_LIFECYCLE,
			 IREP_COMPATIBILITY,
			 IREP_INBOUND_XML_DESCRIPTION,
			 IREP_OUTBOUND_XML_DESCRIPTION,
			 IREP_SYNCHRO,
			 IREP_DIRECTION,
			 IREP_CLASS_ID,
			 IREP_ASSOC_FUNCTION_NAME
			)
			values
			(
			l_function_id,
			p_function_name,
			p_application_id,
			null,
			null,
			sysdate,
			0,
			sysdate,
			0,
			0,
			p_type,
			null,
			null,
			null,
			null,
			null,
			null,
			p_object_id,
			null,
			null,
			'NONE',
			'NONE',
			null,
			p_irep_method_name,
			p_irep_description,
			p_irep_overload_sequence,
			p_irep_scope,
			p_irep_lifecycle,
			p_irep_compatibility,
			p_irep_inbound_xml_desc,
			p_irep_outbound_xml_desc,
			p_irep_synchro,
			p_irep_direction,
			p_irep_class_id,
			p_irep_assoc_function_name
			);
			/**We don't really need this**/
			/**
			ws_base_method_overload
			(
			l_function_id,
			p_irep_description,
			p_irep_scope,
			p_irep_lifecycle,
			p_irep_compatibility,
			p_err_code,
			p_err_message
			);
			**/

			create_function_lang_entries
			(
			p_base_function_id,
			l_function_id,
			p_err_code,
			p_err_message
			);
		exception
		when program_exit then
			raise program_exit;
		when others then
			p_err_code := -1;
			p_err_message := 'Error in inserting to fnd_form_functions'||SQLERRM;
			raise program_exit;
		end;



	elsif c_derived_method%FOUND then
		--Update the existing entry
		begin
			update fnd_form_functions
			set
				APPLICATION_ID = p_application_id,
				FORM_ID = p_form_id,
				PARAMETERS = p_parameters,
				CREATION_DATE = p_creation_date,
				CREATED_BY = p_created_by,
				LAST_UPDATE_DATE = sysdate,
				LAST_UPDATED_BY = 0,
				LAST_UPDATE_LOGIN = 0,
				TYPE = p_type,
				WEB_HOST_NAME = p_web_host_name,
				WEB_AGENT_NAME = p_web_agent_name,
				WEB_HTML_CALL = p_web_html_call,
				WEB_ENCRYPT_PARAMETERS = p_web_encrypt_parameters,
				WEB_SECURED = p_web_secured,
				WEB_ICON = p_web_icon,
				OBJECT_ID = p_object_id,
				REGION_APPLICATION_ID = p_region_application_id,
				REGION_CODE = p_region_code,
				MAINTENANCE_MODE_SUPPORT = p_maintenance_mode_support,
				CONTEXT_DEPENDENCE = p_context_dependence,
				JRAD_REF_PATH = p_jrad_ref_path,
				IREP_METHOD_NAME = p_irep_method_name,
				IREP_DESCRIPTION = p_irep_description,
				IREP_OVERLOAD_SEQUENCE = p_irep_overload_sequence,
				IREP_SCOPE = p_irep_scope,
				IREP_LIFECYCLE = p_irep_lifecycle,
				IREP_COMPATIBILITY = p_irep_compatibility,
				IREP_INBOUND_XML_DESCRIPTION = p_irep_inbound_xml_desc,
				IREP_OUTBOUND_XML_DESCRIPTION = p_irep_outbound_xml_desc,
				IREP_SYNCHRO = p_irep_synchro,
				IREP_DIRECTION = p_irep_direction,
				IREP_CLASS_ID =p_irep_class_id,
				IREP_ASSOC_FUNCTION_NAME = p_irep_assoc_function_name
			where current of c_derived_method;
			/**
			ws_base_method_overload
			(
			c_derived_method_rec.function_id,
			p_irep_description,
			p_irep_scope,
			p_irep_lifecycle,
			p_irep_compatibility,
			p_err_code,
			p_err_message
			);
			**/

			create_function_lang_entries
			(
			p_base_function_id,
			c_derived_method_rec.function_id,
			p_err_code,
			p_err_message
			);

		exception
		when program_exit then
			raise program_exit;
		when others then
			p_err_code := -1;
			p_err_message := 'Error in Updating fnd_form_functions'||SQLERRM;
			raise program_exit;
		end;

	end if;

	close c_derived_method;

	p_err_code := 0;
	p_err_message := wf_core.translate('WF_WS_SUCCESS');
exception
when program_exit then
	raise program_exit;
when others then
	p_err_code := -1;
        wf_core.token('FunctionName',p_function_name);
	wf_core.token('BaseFunctionId',p_base_function_id);
	wf_core.token('DerivedClassId',p_irep_class_id);
	wf_core.token('SqlErr',SQLERRM);
	p_err_message := wf_core.translate('WF_WS_FUNCTION_CREATE');
	raise program_exit;
end create_derived_method_entry;


procedure create_function_lang_entries
	(
	p_base_function_id in number,
	p_function_id in number,
	p_err_code OUT NOCOPY pls_integer,
	p_err_message OUT NOCOPY varchar2
	)

is
	cursor c_base_function_tl(c_base_function_id in pls_integer) is
	select *
	from fnd_form_functions_tl
	where function_id = c_base_function_id;

        cursor c_function_name(c_function_id in number) is
        select function_name
        from fnd_form_functions
        where function_id = c_function_id;

        p_function_name varchar2(430) := null;
  	c_base_function_tl_rec c_base_function_tl%ROWTYPE;

begin
	if ( (p_base_function_id is null) or (p_function_id is null) ) then
		p_err_code := -1;
		p_err_message := 'Base Function ID or Function ID is null';
		raise program_exit;
	end if;

        open c_function_name(p_function_id);
        fetch c_function_name into p_function_name;
        close c_function_name;

	for c_base_function_tl_rec in c_base_function_tl(p_base_function_id)
	loop
		create_function_language
		(
		p_function_id,
		c_base_function_tl_rec.language,
		c_base_function_tl_rec.user_function_name,
		c_base_function_tl_rec.description,
		c_base_function_tl_rec.source_lang,
		p_err_code,
		p_err_message
		);
	end loop;
	p_err_code := 0;
	p_err_message := wf_core.translate('WF_WS_SUCCESS');

exception
when program_exit then
	raise program_exit;
when others then
	p_err_code := -1;
	wf_core.token('BaseFunctionId',p_base_function_id);
	wf_core.token('DerivedFunctionId',p_function_id);
        wf_core.token('DerivedFunctionName',p_function_name);
	wf_core.token('SqlErr',SQLERRM);
	p_err_message := wf_core.translate('WF_WS_FUNC_LANG_ENTRIES');
	raise program_exit;
end create_function_lang_entries;



procedure create_function_language
	(
	p_function_id  in number,
	p_language in varchar2,
	p_user_function_name in varchar2,
	p_description in varchar2,
	p_source_lang in varchar2,
	p_err_code OUT NOCOPY pls_integer,
	p_err_message OUT NOCOPY varchar2
	)
is
	cursor c_function_language
	(
	c_function_id number,
	c_language in varchar2
	) is
	select *
	from fnd_form_functions_tl
	where  function_id = c_function_id
	and language = c_language
	for update ;

	c_function_language_rec c_function_language%ROWTYPE;

        cursor c_function_name(c_function_id in number) is
        select function_name
        from fnd_form_functions
        where function_id = c_function_id;

        p_function_name varchar2(430) := null;

begin

	if ( (p_function_id is null) or (p_language is null) ) then
		p_err_code := -1;
		p_err_message := 'Function ID or Language is null';
		raise program_exit;
	end if;

        open c_function_name(p_function_id);
        fetch c_function_name into p_function_name;
        close c_function_name;

	open c_function_language(p_function_id,p_language);
	fetch c_function_language into c_function_language_rec;

	if c_function_language%NOTFOUND then

		insert into FND_FORM_FUNCTIONS_TL
		(
		LANGUAGE,
		FUNCTION_ID,
		USER_FUNCTION_NAME,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
		DESCRIPTION,
		SOURCE_LANG
		)
		values
		(
		p_language,
		p_function_id,
		p_user_function_name,
		sysdate,
		0,
		sysdate,
		0,
		0,
		p_description,
		p_source_lang
		);

	elsif c_function_language%FOUND then

		update fnd_form_functions_tl
		set 	user_function_name = p_user_function_name,
			description = p_description,
			source_lang = p_source_lang,
			last_update_date = sysdate,
			last_updated_by = 0,
			last_update_login = 0
		where current of c_function_language;

	end if;

	close c_function_language;

	p_err_message :=wf_core.translate('WF_WS_SUCCESS');
	p_err_code :=0;
exception
when program_exit then
	raise program_exit;
when others then
	p_err_code := -1;
        wf_core.token('DerivedFunctionName', p_function_name);
	wf_core.token('DerivedFunctionId',p_function_id);
	wf_core.token('Lang',p_language);
	wf_core.token('SqlErr',SQLERRM);
	p_err_message := wf_core.translate('WF_WS_FUNC_LANG');
	raise program_exit;
end create_function_language;

procedure create_class_language
	(
	p_class_id  in number,
	p_language in varchar2,
	p_source_lang in varchar2,
	p_display_name in varchar2,
	p_short_description in varchar2,
	p_security_group_id in number,
	p_err_code OUT NOCOPY pls_integer,
	p_err_message OUT NOCOPY varchar2
	)
is
	cursor c_class_language
	(
	c_class_id number,
	c_language in varchar2
	) is
	select *
	from fnd_irep_classes_tl
	where  class_id = c_class_id
	and language = c_language
	for update ;

	c_class_language_rec c_class_language%ROWTYPE;

        cursor c_class_name(c_class_id in number) is
        select class_name
        from fnd_irep_classes
        where class_id = c_class_id;

        p_derived_class_name varchar2(430) := null;

begin
	if ( (p_class_id is null) or (p_language is null) ) then
		p_err_code := -1;
		p_err_message := 'Class ID or Language is null';
		raise program_exit;
	end if;

        open c_class_name(p_class_id);
        fetch c_class_name into p_derived_class_name;
        close c_class_name;

	open c_class_language(p_class_id,p_language);
	fetch c_class_language into c_class_language_rec;

	if c_class_language%NOTFOUND then

		insert into FND_IREP_CLASSES_TL
		(
		CLASS_ID,
		LANGUAGE,
		SOURCE_LANG,
		DISPLAY_NAME,
		SHORT_DESCRIPTION,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN,
		SECURITY_GROUP_ID
		)
		values
		(
		p_class_id,
		p_language,
		p_source_lang,
		p_display_name,
		p_short_description,
		0,
		sysdate,
		0,
		sysdate,
		0,
		0
		);

	elsif c_class_language%FOUND then

		update fnd_irep_classes_tl
		set 	display_name = p_display_name,
			short_description = p_short_description,
			source_lang = p_source_lang,
			last_update_date = sysdate,
			last_updated_by = 0,
			last_update_login = 0,
			security_group_id = p_security_group_id
		where current of c_class_language;

	end if;

	close c_class_language;

	p_err_message :=wf_core.translate('WF_WS_SUCCESS');
	p_err_code :=0;
exception
when program_exit then
	raise program_exit;
when others then
	p_err_code := -1;
        wf_core.token('DerivedClassName', p_derived_class_name);
	wf_core.token('DerivedClassId',p_class_id);
	wf_core.token('Lang',p_language);
	wf_core.token('SqlErr',SQLERRM);
	p_err_message := wf_core.translate('WF_WS_CLASS_LANG');
	raise program_exit;
end create_class_language;


procedure create_class_lang_entries
	(
	p_base_class_id in number,
	p_class_id in number,
	p_err_code OUT NOCOPY pls_integer,
	p_err_message OUT NOCOPY varchar2
	)

is
	cursor c_base_class_tl(c_base_class_id in pls_integer) is
	select *
	from fnd_irep_classes_tl
	where class_id = c_base_class_id;

  	c_base_class_tl_rec c_base_class_tl%ROWTYPE;

        cursor c_class_name(c_class_id in number) is
        select class_name
        from fnd_irep_classes
        where class_id = c_class_id;

        p_derived_class_name varchar2(430) := null;

begin
	if ( (p_base_class_id is null) or (p_class_id is null) ) then
		p_err_code := -1;
		p_err_message := 'Base Class ID or Class ID is null';
		raise program_exit;
	end if;

        open c_class_name(p_class_id);
        fetch c_class_name into p_derived_class_name;
        close c_class_name;

	for c_base_class_tl_rec in c_base_class_tl(p_base_class_id)
	loop
		create_class_language
		(
		p_class_id,
		c_base_class_tl_rec.language,
		c_base_class_tl_rec.source_lang,
		c_base_class_tl_rec.display_name,
		c_base_class_tl_rec.short_description,
		c_base_class_tl_rec.security_group_id,
		p_err_code,
		p_err_message
		);
	end loop;

	p_err_code := 0;
	p_err_message := wf_core.translate('WF_WS_SUCCESS');

exception
when program_exit then
	raise program_exit;
when others then
	p_err_code := -1;
        wf_core.token('DerivedClassName', p_derived_class_name);
	wf_core.token('DerivedClassId',p_class_id);
	wf_core.token('SqlErr',SQLERRM);
	p_err_message := wf_core.translate('WF_WS_CLASS_LANG_ENTRIES');
	raise program_exit;
end create_class_lang_entries;

procedure create_xmlg_schema
	(
	p_clob OUT NOCOPY clob,
	p_root_element in varchar,
	p_product_code in varchar2,
	p_direction in varchar,
	p_port_type in varchar,
        p_operation in varchar,
	p_err_code OUT NOCOPY pls_integer,
	p_err_message OUT NOCOPY varchar2
	)
is

	i_tmp				clob;
	i_buffer varchar2(32767) 	:= null;
	i_lob_len			pls_integer;
	i_root				varchar2(200);
begin
	dbms_lob.createtemporary(i_tmp,true,dbms_lob.session);

	if ( p_direction = 'IN') then


		i_buffer := '<xsd:schema elementFormDefault="qualified"'||
				 ' targetNamespace="http://xmlns.oracle.com/apps/'||lower(p_product_code)||'/'||p_port_type||'/'||p_operation||'">'||
			    '	<xsd:element name="'||p_root_element||'" type="xsd:anyType"/>'||
		            '</xsd:schema>';
	elsif (p_direction = 'OUT') then
		i_buffer :='<xsd:schema elementFormDefault="qualified"'||
				 ' targetNamespace="http://xmlns.oracle.com/apps/fnd/XMLGateway">'||
			    '	<xsd:element name="ReceiveDocument_Response">'||
			    '		<xsd:complexType>'||
			    '			<xsd:sequence>'||
			    '				<xsd:element name="ResponseCode" type="xsd:string" />'||
			    '				<xsd:element name="ResponseCode" type="xsd:string" />'||
		            '		 		<xsd:element name="ResponseCode" type="xsd:string" />'||
		            '			</xsd:sequence>'||
		            '		</xsd:complexType>'||
		            '	</xsd:element>'||
		            '</xsd:schema>';
	end if;

	i_lob_len := length(i_buffer);
	dbms_lob.write(i_tmp,i_lob_len,1,i_buffer);
	p_clob := i_tmp;
	dbms_lob.freetemporary(i_tmp);

	p_err_code := 0;
	p_err_message := wf_core.translate('WF_WS_SUCCESS');
exception
when program_exit then
	raise program_exit;
when others then
	p_err_code := -1;
	wf_core.token('InterfaceName',p_port_type);
	wf_core.token('SqlErr',SQLERRM);
	p_err_message := wf_core.translate('WF_WS_XMLG_SCHEMA');
	raise program_exit;
end create_xmlg_schema;


procedure to_upper
	(
	p_name in varchar2,
	p_new_name OUT NOCOPY varchar2,
	p_err_code OUT NOCOPY pls_integer,
	p_err_message OUT NOCOPY varchar2
	) is
	l_var varchar2(100);
begin
	if length(p_name) >0 then
		l_var := substr(p_name,1,1);
		l_var := upper(l_var);
		l_var := l_var||lower(substr(p_name,2,length(p_name)));
		p_new_name := l_var;
	end if;

	p_err_code := 0;
	p_err_message := wf_core.translate('WF_WS_SUCCESS');
exception
when program_exit then
	raise program_exit;
when others then
	p_err_code := -1;
	wf_core.token('Name',p_name);
	wf_core.token('SqlErr',SQLERRM);
	p_err_message := wf_core.translate('WF_WS_XMLG_NS');
	raise program_exit;
end;


/**Procedure to assign the Business Entities
 **Any Base Class Entry can have multiple business entities assigned to it.
 **For same IREP entry multiple assignment records to be created in fnd_lookup_assignments
 **with lookup_code equal to the business entity codes.
 **Relationship between lookup_assignments and the lookup_values is already existing.
**/
procedure assign_business_entities
	(
	p_base_class_id in number,
	p_derived_class_id in number,
	p_err_code OUT NOCOPY pls_integer,
	p_err_message OUT NOCOPY varchar2
	) is

	cursor c1(c_base_class_id in number) is
	select *
	from fnd_lookup_assignments
	where obj_name = 'FND_IREP_CLASSES'
	and lookup_type = 'BUSINESS_ENTITY'
	and instance_pk1_value = c_base_class_id;

	c1_rec c1%ROWTYPE;

	cursor c2
	(
	c_derived_class_id in number,
	c_lookup_code in varchar2
	) is
	select *
	from fnd_lookup_assignments
	where obj_name = 'FND_IREP_CLASSES'
	and lookup_type = 'BUSINESS_ENTITY'
	and instance_pk1_value = c_derived_class_id
	and lookup_code = c_lookup_code
	for update ;

	c2_rec c2%ROWTYPE;

	cursor c3 is
	select fnd_lookup_assignments_s.nextval assign_id
	from dual;

	c3_rec c3%ROWTYPE;

        cursor c_class_name(c_class_id in number) is
        select class_name
        from fnd_irep_classes
        where class_id = c_class_id;

        p_derived_class_name varchar2(430) := null;

begin

        open c_class_name(p_derived_class_id);
        fetch c_class_name into p_derived_class_name;
        close c_class_name;

	for  c1_rec in c1(p_base_class_id)
	loop
		open c2(p_derived_class_id,c1_rec.lookup_code);

		fetch c2 into c2_rec;

		if c2%NOTFOUND then

			if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'oracle.apps.fnd.wf.ws.assign_business_entities', 'Assigning new Business Entity='||c1_rec.lookup_code);
			end if;

			open c3;
			fetch c3 into c3_rec;
			close c3;

			insert into fnd_lookup_assignments
			(
			 LOOKUP_ASSIGNMENT_ID,
			 LOOKUP_TYPE,
			 LOOKUP_CODE,
			 OBJ_NAME,
			 INSTANCE_PK1_VALUE,
			 INSTANCE_PK2_VALUE,
			 INSTANCE_PK3_VALUE,
			 INSTANCE_PK4_VALUE,
			 INSTANCE_PK5_VALUE,
			 DISPLAY_SEQUENCE,
			 CREATED_BY,
			 CREATION_DATE,
			 LAST_UPDATED_BY,
			 LAST_UPDATE_DATE,
			LAST_UPDATE_LOGIN
			)
			values
			(
			c3_rec.assign_id,
			c1_rec.lookup_type,
			c1_rec.lookup_code,
			c1_rec.obj_name,
			p_derived_class_id,
			null,
			null,
			null,
			null,
			null,
			1,
			sysdate,
			1,
			sysdate,
			0
			);
		elsif c2%FOUND then

			if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
				FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'oracle.apps.fnd.wf.ws.assign_business_entities', 'Updating Business Entity='||c1_rec.lookup_code);
			end if;

			update fnd_lookup_assignments
			set  LAST_UPDATED_BY = 1,
			     last_update_date = sysdate,
			     last_update_login = 0
			where current of c2;
		end if;

		close c2;
	end loop;

	p_err_code := 0;
	p_err_message := wf_core.translate('WF_WS_SUCCESS');
exception
when program_exit then
	raise program_exit;
when others then
	p_err_code := -1;
        wf_core.token('DerivedClassName', p_derived_class_name);
	wf_core.token('DerivedClassId',p_derived_class_id);
	wf_core.token('SqlErr',SQLERRM);
	p_err_message := wf_core.translate('WF_WS_CREATE_BUS_ENTITIES');
	raise program_exit;
end assign_business_entities;

procedure ws_base_method_overload
	(
	p_function_id in number,
	p_description in varchar2,
	p_scope_type in varchar2,
	p_irep_lifecycle in varchar2,
	p_irep_compatibility_flag in varchar2,
	p_err_code OUT NOCOPY pls_integer,
	p_err_message OUT NOCOPY varchar2
	)  is

	cursor c1(c_function_id in number) is
	select *
	from fnd_irep_function_flavors
	where function_id = c_function_id
	for update;

        cursor c_function_name(c_function_id in number) is
        select function_name
        from fnd_form_functions
        where function_id = c_function_id;

        p_function_name varchar2(430) := null;

	c1_rec c1%ROWTYPE;
begin
	open c1(p_function_id);
	fetch c1 into c1_rec;

	if c1%NOTFOUND then

		insert into FND_IREP_FUNCTION_FLAVORS
		(
		FUNCTION_ID,OVERLOAD_SEQ,
		SCOPE_TYPE,LIFECYCLE_MODE,DESCRIPTION,COMPATIBILITY_FLAG
		)
		values
		(
		p_function_id,1,
		'PUBLIC','ACTIVE',p_description,'S'
		);


	elsif c1%FOUND then

		update fnd_irep_function_FLAVORS
		set description = p_description,
		scope_type = p_scope_type
		where current of c1;
	end if;

	close c1;

        open c_function_name(p_function_id);
        fetch c_function_name into p_function_name;
        close c_function_name;

	p_err_code := 0;
  	p_err_message := wf_core.translate('WF_WS_SUCCESS');
exception
when others then
	p_err_code := -1;
        wf_core.token('DerivedFunctionName', p_function_name);
	wf_core.token('DerivedFunctionId',p_function_id);
	wf_core.token('SqlErr',SQLERRM);
	p_err_message := wf_core.translate('WF_WS_OVERLOAD_SEQ');
	raise program_exit;
end ws_base_method_overload;


procedure get_root_element
        (
        p_map_code in varchar2,
        p_root_element OUT NOCOPY varchar2,
        p_err_code OUT NOCOPY pls_integer,
        p_err_message OUT NOCOPY varchar2
        ) is

        i_map_id  number;
        invalid_input     exception;
begin

        if (p_map_code = '') or (p_map_code is null)
        then
           raise invalid_input;
        end if;

        select map_id
        into i_map_id
        from ecx_mappings
        where map_code = p_map_code;


        select root_element
        into p_root_element
        from  ecx_objects
        where map_id = i_map_id and
              (object_type = 'XML' or
               object_type = 'DTD');


exception
when others then
        p_err_code := -1;
        wf_core.token('GetRootElement mapCode', p_map_code);
        wf_core.token('SqlErr',SQLERRM);
        p_err_message := wf_core.translate('WF_WS_MODULE_FAILED');
        raise program_exit;
end get_root_element;

end WF_WS_GEN;

/
