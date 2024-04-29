--------------------------------------------------------
--  DDL for Package Body FND_NET_SERVICES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_NET_SERVICES" as
/* $Header: AFCPNETB.pls 120.8.12010000.2 2010/02/15 09:43:06 dhakumar ship $ */

-- This package uses dynamic SQL to query fnd_nodes, due to various
-- backward compatibility issues.

type alt_instance_type       is table of varchar2(255) index by binary_integer;

function fmtline(p_text        varchar2,
		 p_length      number,
                 p_pad         varchar2 default ' ') return varchar2
as
begin

  return (rpad(substr(nvl(p_text,' '),1,p_length),p_length,p_pad) || ' ' );

end;

function fmtuline(p_length	number) return varchar2
as
begin

  return fmtline('-',p_length,'-');

end;

function platformNameToNo(platform_name varchar2) return varchar2
as
platform_code	varchar2(20);
begin

  if    ( platform_name = 'Solaris' ) then
       platform_code := '23';
  elsif ( platform_name = 'HP-UX' ) then
       platform_code := '59';
  elsif ( platform_name = 'HPUX_IA64' ) then
       platform_code := '197';
  elsif ( platform_name = 'UNIX Alpha' ) then
       platform_code := '87';
  elsif ( platform_name = 'IBM AIX' )  then
       platform_code := '212';
  elsif ( platform_name = 'Intel_Solaris' ) then
       platform_code := '173';
  elsif ( platform_name = 'Linux' ) then
       platform_code := '46';
  elsif ( platform_name = 'LINUX_X86-64' ) then
       platform_code := '226';
  elsif ( platform_name = 'Windows NT' ) then
       platform_code := '912';
  elsif ( platform_name = 'LINUX_ZSER' ) then
       platform_code := '209';
  else
       platform_code := '453';
  end if;

  return platform_code;
end;

/*==========================================================================*/

function buildNodeName(p_host_name varchar2,
                       p_domain    varchar2,
                       p_platform  varchar2)  return varchar2
as

-- This function doesn't use %type as we have to allow for
-- the node_id column not even being available!

l_platform_code   varchar2(20) := platformNameToNo(p_platform);
l_node_name       varchar2(255):= p_host_name;
l_node_id         number;

begin

  if ( l_platform_code = '87' )
  then

--   Special case for Alpha. afcpnode.sql still appends domain, although
--   no longer required.

     l_node_name := p_host_name || '.' || p_domain;

     l_node_id := null;

--   Do backwards compatibility checks. Use dynamic SQL as node_id
--   may not exist.

     begin

       execute immediate 'select a.node_id ' ||
                         '  from fnd_nodes a ' ||
                         ' where upper(a.node_name) = upper(:v1) '
                     into l_node_id
                    using l_node_name;

     exception
         when no_data_found then
              l_node_id := null;
         when others then
              raise;
     end;

--   When afcpnode.sql is fixed to remove Alpha check, we can then
--   make the default the host name. Uncomment next four lines.

--     if ( l_node_id is null )
--     then
--        l_node_name := p_host_name;
--     end if;

  end if;

  return l_node_name;

end;

/*==========================================================================*/

procedure do_descriptor_resolve ( p_descRec fnd_tns_alias_descriptions%rowtype,
                                  p_alias_name   varchar2,
                                  p_alias_set_name varchar2,
                                  p_Service_Name varchar2,
                                  p_Instance_Name varchar2
                                )
as
l_root_desc   fnd_tns_alias_descriptions%rowtype;
l_descRec     fnd_tns_alias_descriptions%rowtype := p_descRec;
l_sourceDesc  fnd_tns_alias_descriptions%rowtype;

l_valid_service number;
l_valid_instance number;
l_db_guid     raw(16);
l_address_list_guid raw(16);

cursor c1(p_tns_description_guid raw) is
         select a.Tns_Alias_Address_List_Guid,a.sequence_number,
                a.failover,a.load_balance
           from fnd_tns_alias_address_lists a
          where a.Tns_Alias_Description_Guid = p_tns_description_guid
            and a.sequence_number >= 0
          order by a.sequence_number;

cursor c2(p_tns_address_list_guid raw) is
         select a.Listener_Port_Guid
           from fnd_tns_alias_addresses a
          where a.Tns_Alias_Address_List_Guid = p_tns_address_list_guid
          order by a.Listener_Port_Guid;

begin

--  We always do descriptor resolve, as there's no guarantee that an
--  resolved entry doesn't have new service/instance values.

-- Get the root descriptor for Service/Instance_Guid.

  select a.*
    into l_root_desc
    from fnd_tns_alias_descriptions a
   where a.tns_alias_guid = l_descRec.tns_alias_guid
     and a.sequence_number = 0;

-- Get db_guid

  select a.Db_Guid
    into l_db_guid
    from fnd_database_services a
   where a.Db_Service_Guid = l_root_desc.Db_Service_Guid;

-- Is it a valid service ?

  select count(*)
    into l_valid_service
    from fnd_database_services a
   where a.Db_Guid = l_db_guid
     and a.Service_Name = p_Service_Name;

-- Is it a valid Instance ?

  if ( p_instance_name is not null )
  then

    select count(*)
      into l_valid_instance
      from fnd_database_instances a, fnd_database_services b,
           fnd_db_service_members c
     where a.db_guid = l_db_guid
       and a.Instance_Name = p_Instance_name
       and a.db_guid = b.db_guid
       and b.Service_Name = p_Service_Name
       and b.Db_Service_Guid = c.Db_Service_Guid
       and c.Instance_Guid = a.Instance_Guid
       and c.db_guid = b.db_guid;

  end if;

  if ( l_valid_service = 0 or
           ( l_valid_instance = 0 and p_instance_name is not null ) )
  then

--  Can't resolve - remove any addresses/address_lists and mark unresolved.

    l_descRec.sequence_number := abs(l_descRec.sequence_number) * -1 ;
    l_descRec.Db_Service_Guid := null;
    l_descRec.Db_Instance_Guid:= null;
    l_descRec.Service_Name    := p_Service_Name;
    l_descRec.Instance_Name   := p_Instance_name;

    delete from fnd_tns_alias_addresses a
     where a.Tns_Alias_Address_List_Guid
           in ( select b.Tns_Alias_Address_List_Guid
                  from fnd_tns_alias_address_lists b
                 where b.Tns_Alias_Description_Guid
                               = l_descRec.Tns_Alias_Description_Guid );

    delete from fnd_tns_alias_address_lists a
     where a.Tns_Alias_Description_Guid
                 = l_descRec.Tns_Alias_Description_Guid ;

    fnd_app_system.register_tns_description
                      (  Alias_Name     => p_alias_name,
                         Sequence_number=> l_descRec.sequence_number,
                         Failover      => l_descRec.failover,
                         Load_Balance  => l_descRec.load_balance,
                         Service_GUID  => l_descRec.Db_Service_Guid,
                         Instance_Guid => l_descRec.Db_Instance_Guid,
                         Service_Name  => l_descRec.Service_Name,
                         Instance_Name => l_descRec.Instance_Name,
                         Tns_Alias_Description_Guid =>
                                       l_descRec.Tns_Alias_Description_Guid,
                         alias_set_name=> p_alias_set_name
                      );

    return;

  end if;

-- We can now resolve this service/instance.

-- Get the source descriptor

  if ( p_instance_name is null )
  then

     select a.*
       into l_sourceDesc
       from fnd_tns_alias_descriptions a, fnd_databases b,
            fnd_tns_aliases c
      where b.db_guid = l_db_guid
        and b.Default_Tns_Alias_Guid = c.tns_alias_guid
        and c.tns_alias_guid = a.tns_alias_guid
        and a.sequence_number = 0;

  else

     select a.*
       into l_sourceDesc
       from fnd_tns_alias_descriptions a, fnd_database_instances b,
            fnd_tns_aliases c
      where b.db_guid = l_db_guid
        and b.Instance_Name = p_instance_name
        and b.Default_Tns_Alias_Guid = c.tns_alias_guid
        and c.tns_alias_guid = a.tns_alias_guid
        and a.sequence_number = 0;

  end if;

-- Update descriptor

  l_descRec.sequence_number := abs(l_descRec.sequence_number) ;
  l_descRec.Db_Service_Guid := l_sourceDesc.Db_Service_Guid;
  l_descRec.Db_Instance_Guid:= l_sourceDesc.Db_Instance_Guid;
  l_descRec.failover        := l_sourceDesc.failover;
  l_descRec.Load_Balance    := l_sourceDesc.Load_Balance;

-- We need to keep the service/name as originally set by the alt list, to
-- enable us to resolve all non-zero descriptors.  This is because even
-- a resolved descriptor needs to be re-built on each call to
-- register_dbnode.

--  l_descRec.Service_Name    := l_sourceDesc.Service_name;
--  l_descRec.Instance_Name   := l_sourceDesc.Instance_name;

  fnd_app_system.register_tns_description
                      (  Alias_Name     => p_alias_name,
                         Sequence_number=> l_descRec.sequence_number,
                         Failover      => l_descRec.failover,
                         Load_Balance  => l_descRec.load_balance,
                         Service_GUID  => l_descRec.Db_Service_Guid,
                         Instance_Guid => l_descRec.Db_Instance_Guid,
                         Service_Name  => l_descRec.Service_Name,
                         Instance_Name => l_descRec.Instance_Name,
                         Tns_Alias_Description_Guid =>
                                       l_descRec.Tns_Alias_Description_Guid,
                         alias_set_name=> p_alias_set_name
                      );

-- Delete current addresses/list and clone from source.

  delete from fnd_tns_alias_addresses a
   where a.Tns_Alias_Address_List_Guid
         in ( select b.Tns_Alias_Address_List_Guid
                from fnd_tns_alias_address_lists b
               where b.Tns_Alias_Description_Guid
                             = l_descRec.Tns_Alias_Description_Guid );

  delete from fnd_tns_alias_address_lists a
   where a.Tns_Alias_Description_Guid
               = l_descRec.Tns_Alias_Description_Guid ;

  for f_addrlist in c1(l_sourceDesc.Tns_Alias_Description_Guid) loop

     l_address_list_guid := sys_guid();

     fnd_app_system.register_tns_address_list
                   ( TNS_ALIAS_DESCRIPTION_GUID =>
                                     l_descRec.Tns_Alias_Description_Guid,
                     Sequence_Number => f_addrlist.sequence_number,
                     Failover      => f_addrlist.failover,
                     Load_Balance  => f_addrlist.load_balance,
                     Tns_Alias_Address_List_Guid
                                   => l_address_list_guid
                   );


     for f_addr in c2(f_addrlist.Tns_Alias_Address_List_Guid) loop

        fnd_app_system.register_tnsalias_address
                         ( TNS_ALIAS_ADDRESS_LIST_GUID => l_address_list_guid,
                           Listener_port_GUID=> f_addr.Listener_Port_GUID
                         );

     end loop;

  end loop;

end;

/*==========================================================================*/

procedure register_alias( p_alias_name     varchar2,
                          p_alias_type     varchar2,
                          p_Failover       varchar2,
                          p_Load_Balance   varchar2,
                          p_Service_Guid   raw,
                          p_Instance_Guid  raw,
                          p_alias_set_name varchar2,
                          p_alias_set_guid raw,
                          p_tns_alias_guid raw,
                          p_Listener_Port_Guid
				           raw,
                          p_alt_instance_table
		       	                   alt_instance_type
                        )
as

alt_instance_table alt_instance_type := p_alt_instance_table;

l_descRec	fnd_tns_alias_descriptions%rowtype;

l_tns_alias_guid raw(16) := p_tns_alias_guid;

cursor c1 (p_desc_guid raw)
          is select a.Tns_Alias_Address_List_Guid,a.sequence_number
               from fnd_tns_alias_address_lists a
              where a.Tns_Alias_Description_Guid = p_desc_guid
                and a.sequence_number >= 0
              order by a.sequence_number;

l_address_list_seqno	number;
l_address_list_guid	raw(16);

l_alt_table_entries     number;
l_actual_alt_count	number;

l_service_name          fnd_tns_alias_descriptions.service_name%type;
l_instance_name         fnd_tns_alias_descriptions.instance_name%type;

type l_alt_inst_record is record
        ( service_name          fnd_tns_alias_descriptions.service_name%type,
          instance_name         fnd_tns_alias_descriptions.instance_name%type
        );

type l_alt_inst_array   is table of l_alt_inst_record index by binary_integer;
l_alt_inst_data         l_alt_inst_array;

l_alt_inst_data_match   boolean := true;

cursor c2(p_tns_alias_guid_parm raw)
         is select a.Tns_Alias_Description_Guid,a.Sequence_Number,
                   abs(a.Sequence_Number) abs_sequence_number
              from fnd_tns_alias_descriptions a
             where a.tns_alias_guid = p_tns_alias_guid_parm
               and a.Sequence_Number <> 0
            order by abs(a.Sequence_Number);

cursor c3(p_tns_alias_guid_parm raw,p_actual_count number)
         is select a.Tns_Alias_Description_Guid,a.Sequence_Number
              from fnd_tns_alias_descriptions a
             where a.tns_alias_guid = p_tns_alias_guid_parm
               and a.Sequence_Number <> 0
               and abs(a.Sequence_Number) > p_actual_count;

begin

  fnd_app_system.register_tnsalias
                   (  Alias_Name     => p_alias_name,
                      Alias_Type     => p_alias_type,
                      Failover       => p_Failover,
                      Load_Balance   => p_Load_Balance,
                      TNS_ALIAS_GUID => l_tns_alias_guid,
                      alias_set_name => p_alias_set_name
                   );

-- If TNS ALIAS GUID is null, fetch actual GUID.

  if ( l_tns_alias_guid is null )
  then
     select a.tns_alias_guid
       into l_tns_alias_guid
       from fnd_tns_aliases a, fnd_tns_alias_sets b
      where b.tns_alias_set_name = p_alias_set_name
        and b.tns_alias_set_guid = a.alias_set_guid
        and a.alias_name     = p_alias_name;
  end if;

--  Register primary descriptor - zero

  fnd_app_system.register_tns_description
                   (  Alias_Name     => p_alias_name,
                      Sequence_Number=> 0,
                      Failover      => p_Failover,
                      Load_Balance  => p_Load_Balance,
                      Service_GUID  => p_Service_Guid,
                      Instance_Guid => p_Instance_Guid,
                      Service_Name  => null,
                      Instance_Name => null,
                      Tns_Alias_Description_Guid => null,
                      alias_set_name=> p_alias_set_name
                   );

  select a.*
    into l_descRec
    from fnd_tns_alias_descriptions a
   where a.Tns_Alias_Guid = l_tns_alias_guid
     and a.Sequence_Number = 0;

-- Currently there is no way for autoconfig to tell the api about
-- multiple address lists - so we just list 0.

  l_address_list_guid := null;
  l_address_list_seqno:= 0;

  for f_addr_list in c1(l_descRec.Tns_Alias_Description_Guid) loop

    if ( f_addr_list.sequence_number = 0 )
    then
       l_address_list_guid := f_addr_list.Tns_Alias_Address_List_Guid;
       l_address_list_seqno:= 0;
       exit;
    end if;

  end loop;

  if ( l_address_list_guid is null )
  then
     l_address_list_guid := sys_guid();
  end if;

  fnd_app_system.register_tns_address_list
                   ( TNS_ALIAS_DESCRIPTION_GUID =>
                                     l_descRec.Tns_Alias_Description_Guid,
                     Sequence_Number => l_address_list_seqno,
                     Failover      => p_Failover,
                     Load_Balance  => p_Load_Balance,
                     Tns_Alias_Address_List_Guid
                                   => l_address_list_guid
                   );

-- Register Address

  fnd_app_system.register_tnsalias_address
                        ( TNS_ALIAS_ADDRESS_LIST_GUID => l_address_list_guid,
                          Listener_port_GUID=> p_Listener_Port_GUID
                        );

-- Nothing more to do if alt_instance_table is empty

  if ( p_alt_instance_table.count = 0 )
  then
     return;
  end if;

  l_alt_table_entries := 0;

-- Build the data array.

  for i in 1..p_alt_instance_table.count loop

    exit when p_alt_instance_table(i) is null or
              p_alt_instance_table(i) = ''  ;

    if ( instr(p_alt_instance_table(i),':') = 0 )
    then
       l_service_name := p_alt_instance_table(i);
       l_instance_name:= null;
    else

       l_service_name := substr(p_alt_instance_table(i),1,
                                 instr(p_alt_instance_table(i),':')-1);
       l_instance_name:= substr(p_alt_instance_table(i),
                                 instr(p_alt_instance_table(i),':')+1);
    end if;

    exit when ( l_service_name is null or l_service_name = '' );

--  OK, we've got something to do.

    l_alt_inst_data(i).service_name := l_service_name;
    l_alt_inst_data(i).instance_name:= l_instance_name;

  end loop;

-- Description records are ordered by sequence, to ensure alt entries
-- are generated correctly. But the order from the context file
-- could have been changed, and be completely different to the
-- current records in fnd_tns_alias_descriptions. Since this can lead to
-- all sorts of f/key issues, we check that the order in the alt_inst_data
-- matches the current records. If there is any mis-match, we delete all
-- the descriptors and start with an empty list.

  select count(*)
    into l_actual_alt_count
    from fnd_tns_alias_descriptions a
   where a.tns_alias_guid = l_tns_alias_guid
     and a.sequence_number <> 0 ;

  if ( l_actual_alt_count <> l_alt_inst_data.count )
  then
     l_alt_inst_data_match := false;
  end if;

  for i in 1..l_alt_inst_data.count loop

    exit when not l_alt_inst_data_match;

    begin
      select a.*
        into l_descRec
        from fnd_tns_alias_descriptions a
       where a.tns_alias_guid = l_tns_alias_guid
         and abs(a.sequence_number) = i;

       if not (   l_descRec.Service_Name = l_alt_inst_data(i).service_name
               and ( (     l_descRec.Instance_Name is null
                       and l_alt_inst_data(i).instance_name is null )
                    or
                     (l_descRec.Instance_Name=l_alt_inst_data(i).instance_name)
                   )
              )
       then
            l_alt_inst_data_match := false;
       end if;

    exception
       when no_data_found then
            l_alt_inst_data_match := false;
    end;

  end loop;

-- If the data array doesn't match, delete all the descriptors.

  if ( not l_alt_inst_data_match )
  then

     for f_unused in c3(l_tns_alias_guid,0) loop

       delete from fnd_tns_alias_descriptions a
        where a.Tns_Alias_Description_Guid =
                      f_unused.Tns_Alias_Description_Guid;

       -- Is this a resolved descriptor ?

       if ( f_unused.sequence_number > 0 )
       then

         -- Need to delete Address_Lists, and addresses.

         delete from fnd_tns_alias_addresses a
          where a.Tns_Alias_Address_List_Guid
                in ( select b.Tns_Alias_Address_List_Guid
                       from fnd_tns_alias_address_lists b
                      where b.Tns_Alias_Description_Guid
                                    = f_unused.Tns_Alias_Description_Guid );

         delete from fnd_tns_alias_address_lists a
          where a.Tns_Alias_Description_Guid
                      = f_unused.Tns_Alias_Description_Guid ;
       end if;

     end loop;

  end if;

-- Now process the data array and update descriptors.

  for i in 1..l_alt_inst_data.count loop

--  Do we have an existing description record?

    begin
      select a.*
        into l_descRec
        from fnd_tns_alias_descriptions a
       where a.tns_alias_guid = l_tns_alias_guid
         and abs(a.sequence_number) = i;

    exception
       when no_data_found then
            l_descRec.Tns_Alias_Description_Guid := null;
    end;

    if ( l_descRec.Tns_Alias_Description_Guid is null )
    then

--	Create an unresolved descriptor.

       fnd_app_system.register_tns_description
                        (  Alias_Name     => p_alias_name,
                           Sequence_Number=> i*-1,
                           Failover      => p_Failover,
                           Load_Balance  => p_Load_Balance,
                           Service_GUID  => null,
                           Instance_Guid => null,
                           Service_Name  => l_alt_inst_data(i).Service_Name,
                           Instance_Name => l_alt_inst_data(i).Instance_Name,
                           Tns_Alias_Description_Guid => null,
                           alias_set_name=> p_alias_set_name
                        );

       select a.*
         into l_descRec
         from fnd_tns_alias_descriptions a
        where a.tns_alias_guid = l_tns_alias_guid
          and abs(a.sequence_number) = i;

    end if;

--	Resolve the descriptor

    do_descriptor_resolve( p_descRec => l_descRec,
                           p_alias_name => p_alias_name,
                           p_alias_set_name => p_alias_set_name,
                           p_Service_Name => l_alt_inst_data(i).Service_Name,
                           p_Instance_Name=> l_alt_inst_data(i).Instance_Name
                         );

  end loop;

end;

/*==========================================================================*/

procedure register_db_alias( p_alias_name     varchar2,
                             p_alias_type     varchar2,
                             p_Failover       varchar2,
                             p_Load_Balance   varchar2,
                             p_Service_Guid   raw,
                             p_Instance_Guid  raw,
                             p_alias_set_name varchar2,
                             p_alias_set_guid raw,
                             p_tns_alias_guid raw,
                             p_Listener_Port_Guid
                                              raw,
                             p_alt_instance_table
		       	                      alt_instance_type
                           )
as
begin

  register_alias( p_alias_name,
                  p_alias_type,
                  p_Failover,
                  p_Load_Balance,
                  p_Service_Guid,
                  p_Instance_Guid,
                  p_alias_set_name,
                  p_alias_set_guid,
                  p_tns_alias_guid,
                  p_Listener_Port_Guid,
                  p_alt_instance_table
                );

end;

/*==========================================================================*/

procedure register_dbnode(SystemName		varchar2,
		          ServerName		varchar2,
                          SystemOwner           varchar2,
                          SystemCSINumber       varchar2,
                          DatabaseName		varchar2,
                          InstanceName		varchar2,
                          InstanceNumber	varchar2,
                          ListenerPort		varchar2,
                          ClusterDatabase	varchar2,
                          ServiceName		varchar2,
                          RemoteListenerName	varchar2,
                          LocalListenerName	varchar2,
                          HostName		varchar2,
		          Domain		varchar2,
		          OracleHomePath	varchar2,
                          OracleHomeVersion     varchar2,
                          OracleHomeName        varchar2,
                          InterconnectName      varchar2,
                          InstanceSid           varchar2,
                          platform              varchar2,
                          alt_service_instance_1  varchar2 default null,
                          alt_service_instance_2  varchar2 default null,
                          alt_service_instance_3  varchar2 default null,
                          alt_service_instance_4  varchar2 default null,
                          alt_service_instance_5  varchar2 default null,
                          alt_service_instance_6  varchar2 default null,
                          alt_service_instance_7  varchar2 default null,
                          alt_service_instance_8  varchar2 default null,
                          VirtualHostName         varchar2 default null
                         )
as
l_node_id		number;
l_node_name             varchar2(255);
l_Oracle_Home_Id	raw(16);
l_Server_Guid		raw(16);
l_System_Guid		raw(16);
l_db_guid		raw(16);
l_db_service_guid	raw(16);
l_db_Default_TNS_Alias_Guid
			raw(16);
l_Listener_GUID		raw(16);
l_remote_tns_alias_guid raw(16);
l_tns_db_alias		raw(16);
l_tns_sid_alias		raw(16);

l_tns_alias_set_guid_pub    raw(16);
l_tns_alias_set_guid_int    raw(16);
l_public_alias_set_name     fnd_tns_alias_sets.TNS_Alias_set_Name%type;
l_internal_alias_set_name   fnd_tns_alias_sets.TNS_Alias_set_Name%type;

l_listener_port_guid        raw(16);

l_instRec		fnd_database_instances%rowtype;

alt_instance_table      alt_instance_type;
alt_check_table		alt_instance_type;
empty_instance_table	alt_instance_type;
alt_index		number;
is_alt_duplicate	boolean;

l_resolveDescRec        fnd_tns_alias_descriptions%rowtype;

l_db_alias_exists	number;

cursor c2(p_db_guid raw)
         is select a.remote_listener_alias
              from fnd_database_instances a
             where a.db_guid = p_db_guid
               and a.remote_listener_alias is not null;

cursor c3(p_listener_guid raw)
         is select a.listener_port_guid,a.port
              from fnd_tns_listener_ports a
             where a.listener_guid = p_listener_guid;

-- Cursor c4 was originally designed just to fetch unresolved descriptors
-- (seq_no < 0 ). But because we clone alt descriptors we need to rebuild
-- every alt descriptor on each call. So we look for all non-zero
-- sequence_numbers. When we add a detail table to sit in between
-- FND_TNS_ALIASES and FND_TNS_ALIAS_DESCRIPTIONS we can remove this
-- restriction.

cursor c4(p_system_guid raw)
         is select f.Tns_Alias_Description_Guid,
                   e.alias_name,d.tns_alias_set_name
              from fnd_system_server_map a, fnd_app_servers b,
                   fnd_tns_alias_set_usage c,fnd_tns_alias_sets d,
                   fnd_tns_aliases e, fnd_tns_alias_descriptions f
             where a.System_GUID = p_System_Guid
               and a.Server_GUID = b.Server_GUID
               and b.server_type = fnd_app_system.C_DB_SERVER_TYPE
               and a.Server_GUID = c.Server_GUID
               and c.tns_alias_set_guid = d.tns_alias_set_guid
               and d.tns_alias_set_type = fnd_app_system.C_ALIAS_SET_NAME_PUB
               and d.tns_alias_set_guid = e.alias_set_guid
               and e.tns_alias_guid = f.tns_alias_guid
               and f.sequence_number <> 0;

cursor c5(p_db_guid raw,p_instance_guid raw,p_service_name varchar2)
         is select a.service_name,b.instance_name
              from fnd_database_services a,fnd_database_instances b
             where a.db_guid = p_db_guid
               and b.db_guid = p_db_guid
               and (  b.Instance_Guid <> p_instance_guid
                    or (  b.Instance_Guid = p_instance_guid and
                          a.service_name  <> p_service_name )
                   )
             order by 1,2;

begin

--  Set up the alt instance table.

  alt_instance_table(1) := alt_service_instance_1;
  alt_instance_table(2) := alt_service_instance_2;
  alt_instance_table(3) := alt_service_instance_3;
  alt_instance_table(4) := alt_service_instance_4;
  alt_instance_table(5) := alt_service_instance_5;
  alt_instance_table(6) := alt_service_instance_6;
  alt_instance_table(7) := alt_service_instance_7;
  alt_instance_table(8) := alt_service_instance_8;

-- Remove duplicates.

  if ( alt_instance_table(1) is not null )
  then
     alt_check_table := alt_instance_table;

     alt_index := 2;

     for i in 2..alt_check_table.count loop

       is_alt_duplicate := false;

       for j in 1..(i-1) loop

         if ( alt_check_table(i) = alt_check_table(j) )
         then
            is_alt_duplicate := true;
            exit;
         end if;
       end loop;

       if ( not is_alt_duplicate )
       then
          alt_instance_table(alt_index) := alt_check_table(i);
          alt_index := alt_index + 1;
       end if;
     end loop;

     alt_instance_table(alt_index) := null;
  end if;

  fnd_app_system.register_system(SystemName,SystemOwner,SystemCSINumber,
                                 system_guid => null);

  select a.System_Guid
    into l_System_Guid
    from fnd_apps_system a
   where a.name = SystemName;

  l_node_name := buildNodeName( p_host_name   => HostName,
                                p_domain      => Domain,
                                p_platform    => platform );

  fnd_app_system.register_node( name          => l_node_name,
                                platform_id   => platformNameToNo(platform),
                                forms_tier    => 'N',
                                cp_tier       => 'N',
                                web_tier      => 'N',
                                admin_tier    => 'N',
                                p_server_id   => null,
                                p_address     => null,
                                p_description => '',
                                p_host_name   => HostName,
                                p_domain      => Domain,
                                db_tier       => 'Y',
                                p_virtual_ip  => VirtualHostName  );

  execute immediate 'select a.node_id ' ||
                    '  from fnd_nodes a ' ||
                    ' where upper(a.node_name) = upper(:v1) '
                into l_node_id
               using l_node_name;

--      Need to create Oracle_Home before FND_SERVER.

  fnd_app_system.register_oraclehome
		          ( name                  => OracleHomeName,
                            Node_Id               => l_node_id,
                            Path                  => OracleHomePath,
                            Version               => OracleHomeVersion,
                            Description           => null,
                            File_System_GUID      => null,
                            oracle_home_id        => null
		          );

  select a.Oracle_Home_Id
    into l_Oracle_Home_Id
    from fnd_oracle_homes a
   where a.node_id = l_node_id
     and a.path    = OracleHomePath;

--      Register Server

  fnd_app_system.register_server
                           ( Name            => ServerName,
                             Node_Id         => l_node_id,
                             Internal        => 'Y',
                             Appl_Top_Guid   => null,
                             Server_type     =>
				    	   fnd_app_system.C_DB_SERVER_TYPE,
                             Pri_Oracle_Home => l_Oracle_Home_Id,
                             Aux_Oracle_Home => null,
                             server_guid     => null
                           );

  select a.Server_Guid
    into l_Server_Guid
    from fnd_app_servers a
   where a.name = ServerName;

-- Register the Server Map

  fnd_app_system.register_servermap (  Server_GUID	=> l_Server_GUID,
				       System_Guid      => l_System_Guid
				    );

-- Register database

  fnd_app_system.register_database
			  ( db_name               => DatabaseName,
			    db_domain             => Domain,
                            Default_TNS_Alias_Guid=> null,
                            Is_Rac_db             => ClusterDatabase,
                            Version               => OracleHomeVersion,
                            db_guid               => null
                          );

  select a.db_guid , a.Default_TNS_Alias_Guid
    into l_db_guid, l_db_Default_TNS_Alias_Guid
    from fnd_databases a
   where a.db_name = DatabaseName
     and a.db_domain = Domain;

  fnd_app_system.register_Database_Asg
		          ( db_name    => DatabaseName,
                            assignment => fnd_app_system.C_APP_DB_ASSIGNMENT,
                            db_domain  => Domain
                          );

-- Register Instance

  fnd_app_system.register_Instance
			   (  db_name                 => DatabaseName,
                              Instance_Name           => InstanceName,
                              Instance_Number         => InstanceNumber,
                              Sid_GUID                => null,
			      Sid		      => InstanceSid,
                              Default_TNS_Alias_GUID  => null,
                              Server_GUID             => l_Server_Guid,
                              Local_Listener_Alias    => null,
                              Remote_Listener_Alias   => null,
                              Configuration           => null,
                              Description             => null,
                              Interconnect_name       => InterconnectName,
                              Instance_guid           => null,
                              db_domain               => Domain
                           ) ;

  select a.*
    into l_instRec
    from fnd_database_instances a
   where a.db_guid = l_db_guid
     and a.Instance_Name = InstanceName;

-- Register Sid - use Sid_Guid already allocated in fnd_database_instances.

  fnd_app_system.register_Sid ( Sid		=> InstanceSid,
			        sid_guid	=> l_instRec.sid_guid
			      );
-- Register Service and member

  fnd_app_system.register_service
			    ( Service_name	      => ServiceName,
                              db_name		      => DatabaseName,
                              db_domain               => Domain,
                              Description	      => null,
                              db_service_guid         => null
		            );

-- Get the common remote tns alias

  l_remote_tns_alias_guid := l_instRec.remote_listener_alias;

  for f_remote in c2(l_db_guid) loop

    l_remote_tns_alias_guid := f_remote.remote_listener_alias;
    exit;

  end loop;

  if ( l_remote_tns_alias_guid is null )
  then
     l_remote_tns_alias_guid := sys_guid();
  end if;

  select a.db_service_guid
    into l_db_service_guid
    from fnd_database_services a
   where a.db_guid    = l_db_guid
     and a.Service_name = ServiceName;

  fnd_app_system.register_service_Members
	    ( db_name		      => DatabaseName,
              Instance_Name	      => InstanceName,
              Instance_Type           => fnd_app_system.C_PREFERRED_INSTANCE,
              db_service_guid	      => l_db_service_guid,
              db_domain               => Domain
	    );

-- Register Alias Sets

   l_public_alias_set_name   := Servername ||'_' ||
					 fnd_app_system.C_ALIAS_SET_NAME_PUB;
   l_internal_alias_set_name := Servername ||'_' ||
					 fnd_app_system.C_ALIAS_SET_NAME_INT;

   fnd_app_system.register_tnsalias_sets
                     ( Alias_set_name => l_public_alias_set_name,
                       Alias_set_type => fnd_app_system.C_ALIAS_SET_NAME_PUB );

   select a.tns_alias_set_guid
     into l_tns_alias_set_guid_pub
     from fnd_tns_alias_sets a
    where a.tns_alias_set_name = l_public_alias_set_name;

   fnd_app_system.register_aliasset_usage
		           ( tns_alias_set_guid => l_tns_alias_set_guid_pub,
                             server_guid        => l_server_guid);

   fnd_app_system.register_tnsalias_sets
                     ( Alias_set_name => l_internal_alias_set_name ,
                       Alias_set_type => fnd_app_system.C_ALIAS_SET_NAME_INT );

   select a.tns_alias_set_guid
     into l_tns_alias_set_guid_int
     from fnd_tns_alias_sets a
    where a.tns_alias_set_name = l_internal_alias_set_name;

   fnd_app_system.register_aliasset_usage
			   ( tns_alias_set_guid => l_tns_alias_set_guid_int,
                             server_guid        => l_server_guid);

-- Register Instance Listener

  fnd_app_system.register_Listener
			   ( Listener_Name   => ServerName,
                             Server_Name     => ServerName,
                             tns_alias_name  => InstanceName||'_'||
					    fnd_app_system.C_LOCAL_ALIAS_ID,
                             listener_guid   => null,
                             alias_set_name  => l_internal_alias_set_name
                           );
  select a.Listener_GUID
    into l_Listener_GUID
    from fnd_tns_listeners a
   where a.Server_GUID = l_Server_Guid
     and a.Listener_Name = ServerName;

-- Register Listener Ports

-- Special case for Autoconfig. There should only be one port. Since
-- the caller can't pass in old/new values, we check for any existing
-- port entries. If supplied ListenerPort does not exist, then use first
-- available.

  l_listener_port_guid   := null;

  for f_port in c3(l_Listener_GUID) loop

    l_listener_port_guid := f_port.listener_port_guid;

    exit when f_port.port = ListenerPort;

  end loop;

  fnd_app_system.register_listener_ports (Listener_name=>ServerName,
                                          Port         =>ListenerPort,
                                          server_guid  =>l_server_guid,
                                          Listener_Port_Guid
						       =>l_listener_port_guid
                                         );

  select a.listener_port_guid
    into l_listener_port_guid
    from fnd_tns_listener_ports a
   where a.listener_guid= l_Listener_GUID
     and a.port = ListenerPort;

-- Register local listener TNS alias

  register_db_alias( p_alias_name     => InstanceName||'_'||
                                            fnd_app_system.C_LOCAL_ALIAS_ID,
                     p_alias_type     =>
                                    fnd_app_system.C_LOCAL_INST_TNS_ALIAS_TYPE,
                     p_Failover       => 'N',
                     p_Load_Balance   => 'N',
                     p_Service_GUID   => null,
                     p_Instance_Guid  => null,
                     p_alias_set_name => l_internal_alias_set_name,
                     p_alias_set_guid => l_tns_alias_set_guid_int,
                     p_tns_alias_guid => l_instRec.Local_Listener_Alias,
                     p_Listener_Port_Guid => l_listener_port_guid,
                     p_alt_instance_table => empty_instance_table
                   );

-- Create Remote DB listener alias. We supply the Service Name, to make
-- it easier to get all listeners.

-- Set Remote_Listener_Alias in fnd_database_instances if null.

  if ( l_instRec.Remote_Listener_Alias is null or
       l_instRec.Remote_Listener_Alias <> l_remote_tns_alias_guid )
  then
     l_instRec.Remote_Listener_Alias := l_remote_tns_alias_guid;

     fnd_app_system.register_Instance
         (  db_name                 => DatabaseName,
            Instance_Name           => l_instRec.Instance_Name,
            Instance_Number         => l_instRec.Instance_Number,
            Sid_GUID                => l_instRec.Sid_GUID,
	    Sid			    => l_instRec.Sid,
            Default_TNS_Alias_GUID  => l_instRec.Default_TNS_Alias_GUID,
            Server_GUID             => l_instRec.Server_GUID,
            Local_Listener_Alias    => l_instRec.Local_Listener_Alias,
            Remote_Listener_Alias   => l_instRec.Remote_Listener_Alias,
            Configuration           => l_instRec.Configuration,
            Description             => l_instRec.Description,
            Interconnect_name       => l_instRec.Interconnect_name,
            Instance_Guid	    => l_instRec.Instance_Guid,
            db_domain               => Domain
         ) ;

  end if;

  register_db_alias
                   ( p_Alias_Name     => DatabaseName||'_'||
                                           fnd_app_system.C_REMOTE_ALIAS_ID,
                     p_Alias_Type     =>
                                   fnd_app_system.C_REMOTE_INST_TNS_ALIAS_TYPE,
                     p_Failover       => 'N',
                     p_Load_Balance   => 'N',
                     p_Service_GUID   => l_db_service_guid,
                     p_Instance_Guid  => null,
                     p_alias_set_name => l_internal_alias_set_name,
                     p_alias_set_guid => l_tns_alias_set_guid_int,
                     p_tns_alias_guid => l_remote_tns_alias_guid,
                     p_Listener_Port_Guid => l_listener_port_guid,
                     p_alt_instance_table => empty_instance_table
                   );

-- Register Load Balance Alias.

  register_db_alias
                   ( p_Alias_Name     => DatabaseName||'_'||
                                        fnd_app_system.C_BALANCE_ALIAS_ID,
                     p_Alias_Type     =>
                                fnd_app_system.C_DB_BALANCE_TNS_ALIAS_TYPE,
                     p_Failover       => 'Y',
                     p_Load_Balance   => 'Y',
                     p_Service_GUID   => l_db_service_guid,
                     p_Instance_Guid  => null,
                     p_alias_set_name => l_public_alias_set_name,
                     p_alias_set_guid => l_tns_alias_set_guid_pub,
                     p_tns_alias_guid => l_db_Default_TNS_Alias_Guid,
                     p_Listener_Port_Guid => l_listener_port_guid,
                     p_alt_instance_table => empty_instance_table
                   );

-- Register Instance Alias, with and without failover

  register_db_alias
                   ( p_Alias_Name     => InstanceName,
                     p_Alias_Type     =>
                                fnd_app_system.C_DB_INST_TNS_ALIAS_TYPE,
                     p_Failover       => 'N',
                     p_Load_Balance   => 'N',
                     p_Service_GUID   => l_db_service_guid,
                     p_Instance_Guid  => l_instRec.Instance_Guid,
                     p_alias_set_name => l_public_alias_set_name,
                     p_alias_set_guid => l_tns_alias_set_guid_pub,
                     p_tns_alias_guid => l_instRec.Default_TNS_Alias_GUID,
                     p_Listener_Port_Guid => l_listener_port_guid,
                     p_alt_instance_table => empty_instance_table
                   );

  register_db_alias
                   ( p_Alias_Name     => InstanceName||'_'||
                                           fnd_app_system.C_FAILOVER_ALIAS_ID,
                     p_Alias_Type     =>
                                fnd_app_system.C_DB_INST_TNS_ALIAS_TYPE,
                     p_Failover       => 'Y',
                     p_Load_Balance   => 'N',
                     p_Service_GUID   => l_db_service_guid,
                     p_Instance_Guid  => l_instRec.Instance_Guid,
                     p_alias_set_name => l_public_alias_set_name,
                     p_alias_set_guid => l_tns_alias_set_guid_pub,
                     p_tns_alias_guid => NULL,
                     p_Listener_Port_Guid => l_listener_port_guid,
                     p_alt_instance_table => alt_instance_table
                   );

-- Register Database Alias as Instance.

-- Nothing to do if already assigned to another db set.

  select count(*)
    into l_db_alias_exists
    from fnd_system_server_map a, fnd_app_servers b,
         fnd_tns_alias_set_usage c,fnd_tns_alias_sets d,
         fnd_tns_aliases e
   where a.System_GUID = l_System_Guid
     and a.Server_GUID = b.Server_GUID
     and b.server_type = fnd_app_system.C_DB_SERVER_TYPE
     and b.server_guid <> l_Server_Guid
     and a.Server_GUID = c.Server_GUID
     and c.tns_alias_set_guid = d.tns_alias_set_guid
     and d.tns_alias_set_type = fnd_app_system.C_ALIAS_SET_NAME_PUB
     and d.tns_alias_set_guid = e.alias_set_guid
     and e.alias_name = DatabaseName;

  if ( l_db_alias_exists = 0 )
  then

     begin

        select a.TNS_ALIAS_GUID
          into l_tns_db_alias
          from fnd_tns_aliases a
         where a.Alias_Name = DatabaseName
           and a.alias_set_guid = l_tns_alias_set_guid_pub;

     exception
   	when no_data_found then
   	     l_tns_db_alias := sys_guid();
     end;

     register_db_alias
                   ( p_Alias_Name     => DatabaseName,
                     p_Alias_Type     =>
                                fnd_app_system.C_DB_INST_TNS_ALIAS_TYPE,
                     p_Failover       => 'N',
                     p_Load_Balance   => 'N',
                     p_Service_GUID   => l_db_service_guid,
                     p_Instance_Guid  => l_instRec.Instance_Guid,
                     p_alias_set_name => l_public_alias_set_name,
                     p_alias_set_guid => l_tns_alias_set_guid_pub,
                     p_tns_alias_guid => l_tns_db_alias,
                     p_Listener_Port_Guid => l_listener_port_guid,
                     p_alt_instance_table => empty_instance_table
                   );

     register_db_alias
                   ( p_Alias_Name     => DatabaseName||'_'||
                                           fnd_app_system.C_FAILOVER_ALIAS_ID,
                     p_Alias_Type     =>
                                fnd_app_system.C_DB_INST_TNS_ALIAS_TYPE,
                     p_Failover       => 'Y',
                     p_Load_Balance   => 'N',
                     p_Service_GUID   => l_db_service_guid,
                     p_Instance_Guid  => l_instRec.Instance_Guid,
                     p_alias_set_name => l_public_alias_set_name,
                     p_alias_set_guid => l_tns_alias_set_guid_pub,
                     p_tns_alias_guid => NULL,
                     p_Listener_Port_Guid => l_listener_port_guid,
                     p_alt_instance_table => alt_instance_table
                   );
  end if;

-- Register InstanceSid if different to database.

  select count(*)
    into l_db_alias_exists
    from fnd_tns_aliases a
   where a.Alias_Name = InstanceSid
     and a.alias_set_guid = l_tns_alias_set_guid_pub;

  if ( l_db_alias_exists = 0 )
  then
       l_tns_sid_alias := sys_guid();
  end if;

  register_db_alias
                   ( p_Alias_Name     => InstanceSid,
                     p_Alias_Type     =>
                                fnd_app_system.C_DB_INST_TNS_ALIAS_TYPE,
                     p_Failover       => 'N',
                     p_Load_Balance   => 'N',
                     p_Service_GUID   => l_db_service_guid,
                     p_Instance_Guid  => l_instRec.Instance_Guid,
                     p_alias_set_name => l_public_alias_set_name,
                     p_alias_set_guid => l_tns_alias_set_guid_pub,
                     p_tns_alias_guid => l_tns_sid_alias,
                     p_Listener_Port_Guid => l_listener_port_guid,
                     p_alt_instance_table => empty_instance_table
                   );

  register_db_alias
                   ( p_Alias_Name     => InstanceSid||'_'||
                                           fnd_app_system.C_FAILOVER_ALIAS_ID,
                     p_Alias_Type     =>
                                fnd_app_system.C_DB_INST_TNS_ALIAS_TYPE,
                     p_Failover       => 'Y',
                     p_Load_Balance   => 'N',
                     p_Service_GUID   => l_db_service_guid,
                     p_Instance_Guid  => l_instRec.Instance_Guid,
                     p_alias_set_name => l_public_alias_set_name,
                     p_alias_set_guid => l_tns_alias_set_guid_pub,
                     p_tns_alias_guid => NULL,
                     p_Listener_Port_Guid => l_listener_port_guid,
                     p_alt_instance_table => alt_instance_table
                   );



-- Now've registered, see if this instance fixes any unresolved
-- descriptors. Note c4 fetches all alt descriptors not just unresolved
-- descriptors. This is due to the model not having a detail table
-- between FND_TNS_ALIASES and FND_TNS_ALIAS_DESCRIPTIONS.

  for f_resolve in c4(l_system_guid) loop

    select a.*
      into l_resolveDescRec
      from fnd_tns_alias_descriptions a
     where a.Tns_Alias_Description_Guid = f_resolve.Tns_Alias_Description_Guid;

    do_descriptor_resolve( p_descRec => l_resolveDescRec,
                           p_alias_name => f_resolve.alias_name,
                           p_alias_set_name => f_resolve.tns_alias_set_name,
                           p_Service_Name => l_resolveDescRec.Service_Name,
                           p_Instance_Name=> l_resolveDescRec.Instance_Name
                         );

  end loop;

end;

/*==========================================================================*/

procedure register_app_alias( alias	     varchar2,
		              type	     varchar2,
		              system_guid    raw,
                              alias_set_name varchar2,
                              alias_set_guid raw,
                              auto_create    boolean
                            )
as
l_system_guid		raw(16) := system_guid;
l_db_guid		raw(16);
l_instance_guid		raw(16);
l_instance_tns_alias_guid raw(16);
l_db_tns_alias_guid	raw(16);
l_db_service_guid	raw(16);
l_port_list_tns_guid    raw(16);
l_system_name           varchar2(100);

l_tns_aliases_rec	fnd_tns_aliases%rowtype;
l_tns_descriptions_rec  fnd_tns_alias_descriptions%rowtype;

l_db_alias_exists	boolean;
l_app_alias_exists	boolean;

empty_instance_table      alt_instance_type;

cursor c1(p_System_Guid raw) is
    select b.db_guid,b.default_tns_alias_guid instance_tns_alias_guid,
           a.default_tns_alias_guid db_tns_alias_guid,b.instance_guid
     from fnd_databases a,fnd_database_instances b,
          fnd_system_server_map c, fnd_app_servers d
    where c.system_guid = p_System_Guid
      and d.server_guid = c.server_guid
      and d.server_type = fnd_app_system.C_DB_SERVER_TYPE
      and b.server_guid = d.server_guid
      and b.db_guid = a.db_guid;

cursor c2(p_db_guid raw) is
    select a.db_service_guid
      from fnd_database_services a
     where a.db_guid = p_db_guid ;

cursor c3(p_alias_name varchar2,p_alias_set_guid raw,p_alias_type varchar2) is
    select a.tns_alias_guid,a.alias_type
      from fnd_tns_aliases a
     where a.alias_name = p_alias_name
       and a.alias_set_guid = p_alias_set_guid
       and (    a.alias_type = nvl(p_alias_type,a.alias_type)
             or a.alias_type = fnd_app_system.C_DB_INST_TNS_ALIAS_TYPE );

cursor c4(p_tns_alias_guid raw) is
    select c.listener_port_guid
      from fnd_tns_alias_descriptions a, fnd_tns_alias_address_lists b,
           fnd_tns_alias_addresses c
     where a.tns_alias_guid = p_tns_alias_guid
       and a.sequence_number= 0
       and b.Tns_Alias_Description_Guid = a.Tns_Alias_Description_Guid
       and c.Tns_Alias_Address_List_Guid = b.Tns_Alias_Address_List_Guid;

cursor c5(p_System_Guid raw,p_alias_name varchar2,p_alias_type varchar2) is
    select e.Tns_Alias_Guid,e.Alias_Type
      from fnd_system_server_map a,fnd_tns_alias_set_usage b,
           fnd_tns_alias_sets c, fnd_app_servers d,
           fnd_tns_aliases e
     where a.system_guid = p_System_Guid
       and a.server_guid = b.server_guid
       and b.tns_alias_set_guid = c.tns_alias_set_guid
       and c.tns_alias_set_type = fnd_app_system.C_ALIAS_SET_NAME_PUB
       and a.server_guid = d.server_guid
       and d.server_type = fnd_app_system.C_DB_SERVER_TYPE
       and e.alias_set_guid = b.tns_alias_set_guid
       and e.alias_name = p_alias_name
       and (    e.alias_type = nvl(p_alias_type,e.alias_type)
             or e.alias_type = fnd_app_system.C_DB_INST_TNS_ALIAS_TYPE );

cursor c6(p_tns_alias_guid raw) is
    select a.Tns_Alias_Description_Guid
      from fnd_tns_alias_descriptions a
     where a.Tns_Alias_Guid = p_tns_alias_guid
       and a.sequence_number >= 0
     order by a.sequence_number;

-- Always allow instance aliases, regardless of type.

begin

-- If already a valid db alias, nothing more to do.

  for f_valid in c5(l_system_guid,alias,type) loop

    return;

  end loop;

-- If exists but of wrong type, adjust accordingly.

  l_db_alias_exists := false;

  for f_valid in c5(l_system_guid,alias,null) loop

    l_db_alias_exists := true;

    select a.*
      into l_tns_aliases_rec
      from fnd_tns_aliases a
     where a.tns_alias_guid = f_valid.Tns_Alias_Guid;

    for f_desc in c6(f_valid.Tns_Alias_Guid) loop

      select a.*
        into l_tns_descriptions_rec
        from fnd_tns_alias_descriptions a
       where a.Tns_Alias_Description_Guid = f_desc.Tns_Alias_Description_Guid;

      exit;

    end loop;

--  Adjust for type and set.

    l_tns_aliases_rec.alias_type := type;
    l_tns_aliases_rec.Alias_Set_Guid := alias_set_guid;
    l_tns_aliases_rec.Tns_Alias_Guid := null;

    exit;

  end loop;

-- Check app alias.

  l_app_alias_exists := false;

  for f_app_alias in c3(alias,alias_set_guid,type) loop

    return;   -- Exact match - nothing to do.

  end loop;

  -- Exists but wrong type.

  for f_app_alias in c3(alias,alias_set_guid,null) loop

    l_app_alias_exists := true;

    select a.*
      into l_tns_aliases_rec
      from fnd_tns_aliases a
     where a.alias_name = alias
       and a.alias_set_guid = alias_set_guid;

    for f_desc in c6(l_tns_aliases_rec.Tns_Alias_Guid) loop

      select a.*
        into l_tns_descriptions_rec
        from fnd_tns_alias_descriptions a
       where a.Tns_Alias_Description_Guid = f_desc.Tns_Alias_Description_Guid;

      exit;

    end loop;

    l_tns_aliases_rec.alias_type := type;

  end loop;

-- Always get the database defaults - needed for switching balance to
-- instance, and setting the port list.

  for f_db in c1(l_system_guid) loop

    l_db_guid := f_db.db_guid;
    l_instance_guid := f_db.instance_guid;
    l_instance_tns_alias_guid := f_db.instance_tns_alias_guid;
    l_db_tns_alias_guid := f_db.db_tns_alias_guid;

    for f_service in c2(l_db_guid) loop

      l_db_service_guid := f_service.db_service_guid;

      exit;

    end loop;

    exit;

  end loop;

  if ( l_db_guid is null )
  then
     return;
  end if;

-- No aliases? - set default guids as required.

  if ( not l_db_alias_exists and not l_app_alias_exists )
  then

    l_tns_aliases_rec.Tns_Alias_Guid := null;
    l_tns_aliases_rec.Alias_Name     := alias;
    l_tns_aliases_rec.Alias_Set_Guid := alias_set_guid;
    l_tns_aliases_rec.Alias_Type     := type;

    l_tns_descriptions_rec.DB_Service_Guid   := l_db_service_guid;
    l_tns_descriptions_rec.DB_Instance_Guid  := l_instance_guid;

  end if;

-- Set guid if null.

  if ( l_tns_aliases_rec.Tns_Alias_Guid is null )
  then
     l_tns_aliases_rec.Tns_Alias_Guid := sys_guid();
  end if;

-- Adjust for load balance, instance.

  if (l_tns_aliases_rec.Alias_Type = fnd_app_system.C_DB_BALANCE_TNS_ALIAS_TYPE)
  then

     l_tns_aliases_rec.Failover     := 'Y';
     l_tns_aliases_rec.Load_Balance := 'Y';

     l_tns_descriptions_rec.DB_Instance_Guid  := null;

  else

     l_tns_aliases_rec.Failover     := 'Y';
     l_tns_aliases_rec.Load_Balance := 'N';

     if ( l_tns_descriptions_rec.DB_Instance_Guid is null )
     then

--  This only occurs when we swap db/instance aliases within a context file.
--  Just choose any instance_guid.

         l_tns_descriptions_rec.DB_Instance_Guid := l_instance_guid;
     end if;

  end if;

-- Build aliases if autocreate specified

  if ( auto_create )
  then

  -- Get the alias guid for the port list.

    if (l_tns_aliases_rec.Alias_Type = fnd_app_system.C_DB_INST_TNS_ALIAS_TYPE )
    then

      l_port_list_tns_guid := l_instance_tns_alias_guid;
    else
      l_port_list_tns_guid := l_db_tns_alias_guid ;

    end if;

    for f_address in c4(l_port_list_tns_guid) loop

        register_alias
                  ( p_Alias_Name     => l_tns_aliases_rec.Alias_Name,
                    p_Alias_Type     => l_tns_aliases_rec.Alias_Type,
                    p_Failover       => l_tns_aliases_rec.Failover,
                    p_Load_Balance   => l_tns_aliases_rec.Load_Balance,
                    p_Service_GUID   => l_tns_descriptions_rec.DB_Service_Guid,
                    p_Instance_Guid  => l_tns_descriptions_rec.DB_Instance_Guid,
                    p_alias_set_name => alias_set_name,
                    p_alias_set_guid => alias_set_guid,
                    p_tns_alias_guid => l_tns_aliases_rec.Tns_Alias_Guid,
                    p_Listener_Port_Guid
                                     => f_address.Listener_port_GUID,
                    p_alt_instance_table
                                     => empty_instance_table
                  );
    end loop;

  end if;

end;

/*==========================================================================*/

procedure register_appnode(SystemName	      in     varchar2,
		           ServerName	      in     varchar2,
                           SystemOwner        in     varchar2,
                           SystemCSINumber    in     varchar2,
                           HostName           in     varchar2,
		           Domain	      in     varchar2,
                           RPCPort            in     varchar2,
                           PriOracleHomePath  in     varchar2,
                           PriOracleHomeVersion in   varchar2,
                           PriOracleHomeName  in     varchar2,
                           AuxOracleHomePath  in     varchar2,
                           AuxOracleHomeVersion in   varchar2,
                           AuxOracleHomeName  in     varchar2,
			   ApplTopPath	      in     varchar2,
			   ApplTopName	      in     varchar2,
			   SharedApplTop      in     varchar2,
                           ToolsInstanceAlias in out nocopy varchar2,
                           WebInstanceAlias   in out nocopy varchar2,
                           SidDefaultAlias    in out nocopy varchar2,
                           JDBCSid            in out nocopy varchar2,
                           isFormsNode        in     varchar2 default 'Y',
                           isCPNode           in     varchar2 default 'Y',
                           isWebNode          in     varchar2 default 'Y',
                           isAdminNode        in     varchar2 default 'Y',
                           platform           in     varchar2,
                           forceMissingAliases
                                              in     varchar2 default 'N'
                          )
as
l_node_id	        number;
l_node_name             varchar2(255);
l_Pri_Oracle_Home_Id	raw(16);
l_Aux_Oracle_Home_Id	raw(16);
l_Appl_Top_Guid		raw(16);
l_Server_Guid		raw(16);
l_System_Guid           raw(16);
l_Listener_GUID		raw(16);
l_listener_port_guid    raw(16);

l_auto_create_aliases	boolean := false;

l_tns_alias_set_guid_pub    raw(16);
l_public_alias_set_name     fnd_tns_alias_sets.TNS_Alias_set_Name%type;

l_fndfs_tns_alias	raw(16);
l_fndsm_tns_alias	raw(16);
l_fndfs_sid_alias	raw(16);
l_fndsm_sid_alias	raw(16);

l_fndsm_alias		varchar2(255);
l_fndfs_alias		varchar2(255);

l_fndsm_sid  		varchar2(255);
l_fndfs_sid  		varchar2(255);

type l_fndsmfs_record is record
	( alias		varchar2(255),
          sid	        varchar2(255)
	);

type l_fndsmfs_table	is table of l_fndsmfs_record index by binary_integer;
l_fndsmfs	        l_fndsmfs_table;

empty_instance_table      alt_instance_type;

cursor c1(p_System_Guid raw) is
    select c.alias_name instance_alias,d.alias_name load_balance_alias,
           a.db_name
     from fnd_databases a, fnd_database_instances b, fnd_tns_aliases c,
          fnd_tns_aliases d
    where b.default_tns_alias_guid  = c.tns_alias_guid
      and b.db_guid = a.db_guid
      and a.Default_TNS_Alias_GUID = d.tns_alias_guid
      and b.server_guid in  ( select x.server_guid
                                from fnd_system_server_map x, fnd_app_servers y
                               where x.system_guid = p_System_Guid
                                 and y.server_guid = x.server_guid
                                 and y.server_type =
                                        fnd_app_system.C_DB_SERVER_TYPE
                            ) ;

cursor c3(p_listener_guid raw)
         is select a.listener_port_guid,a.port
              from fnd_tns_listener_ports a
             where a.listener_guid = p_listener_guid;

begin

  if ( upper(forceMissingAliases) = 'Y' )
  then
     l_auto_create_aliases := true;
  end if;

  fnd_app_system.register_system(SystemName,SystemOwner,SystemCSINumber,
                                 System_guid=>null);

  select a.System_Guid
    into l_System_Guid
    from fnd_apps_system a
   where a.name = SystemName;

  l_node_name := buildNodeName( p_host_name   => HostName,
                                p_domain      => Domain,
                                p_platform    => platform );

  fnd_app_system.register_Node( name          => l_node_name,
                                platform_id   => platformNameToNo(platform),
                                forms_tier    => isFormsNode,
                                cp_tier       => isCPNode,
                                web_tier      => isWebNode,
                                admin_tier    => isAdminNode,
                                p_server_id   => null,
                                p_address     => null,
                                p_description => '' ,
                                p_host_name   => HostName,
                                p_domain      => Domain,
                                db_tier       => 'N' );

  execute immediate 'select a.node_id ' ||
                    '  from fnd_nodes a ' ||
                    ' where upper(a.node_name) = upper(:v1) '
                into l_node_id
               using l_node_name;

--	Need to create Oracle_Homes and APPL_TOP before FND_SERVER.

  fnd_app_system.register_oraclehome
		          ( name                  => PriOracleHomeName,
                            Node_Id               => l_node_id,
                            Path                  => PriOracleHomePath,
                            Version               => PriOracleHomeVersion,
                            Description           => null,
                            File_System_GUID      => null,
                            oracle_home_id        => null
		          );

  fnd_app_system.register_oraclehome
		          ( name                  => AuxOracleHomeName,
                            Node_Id               => l_node_id,
                            Path                  => AuxOracleHomePath,
                            Version               => AuxOracleHomeVersion,
                            Description           => null,
                            File_System_GUID      => null,
                            oracle_home_id        => null
		          );

  fnd_app_system.register_appltop
                          ( name                  => ApplTopName,
                            Node_Id               => l_node_id,
                            Path                  => ApplTopPath,
			    Shared		  => SharedApplTop,
                            File_System_GUID      => null,
                            appl_top_guid         => null
                          );

--	Get Home Ids

  select a.Oracle_Home_Id
    into l_Pri_Oracle_Home_Id
    from fnd_oracle_homes a
   where a.node_id = l_node_id
     and a.path    = PriOracleHomePath;

  select a.Oracle_Home_Id
    into l_Aux_Oracle_Home_Id
    from fnd_oracle_homes a
   where a.node_id = l_node_id
     and a.path    = AuxOracleHomePath;

  select a.appl_top_guid
    into l_Appl_Top_Guid
    from fnd_appl_tops a
   where a.node_id = l_node_id
     and a.path    = ApplTopPath;

--	Register Server

  fnd_app_system.register_server
                           ( Name            => ServerName,
                             Node_Id         => l_node_id,
                             Internal        => 'Y',
                             Appl_Top_Guid   => l_Appl_Top_Guid,
                             Server_type     =>
				    	 fnd_app_system.C_APP_SERVER_TYPE,
                             Pri_Oracle_Home => l_Pri_Oracle_Home_Id,
                             Aux_Oracle_Home => l_Aux_Oracle_Home_Id,
                             server_guid     => null
                           );

  select a.Server_Guid
    into l_Server_Guid
    from fnd_app_servers a
   where a.name = ServerName;

-- Register the Server Map

  fnd_app_system.register_servermap (  Server_GUID   => l_Server_GUID,
                                       System_Guid   => l_System_Guid
                                    );

-- Register Alias Sets PUBLIC

  l_public_alias_set_name   := Servername ||'_' ||
                                         fnd_app_system.C_ALIAS_SET_NAME_PUB;

  fnd_app_system.register_tnsalias_sets
                     ( Alias_set_name => l_public_alias_set_name,
                       Alias_set_type => fnd_app_system.C_ALIAS_SET_NAME_PUB );

  select a.tns_alias_set_guid
    into l_tns_alias_set_guid_pub
    from fnd_tns_alias_sets a
   where a.tns_alias_set_name = l_public_alias_set_name;

   fnd_app_system.register_aliasset_usage
                          ( tns_alias_set_guid => l_tns_alias_set_guid_pub,
                            server_guid        => l_server_guid);

-- Register APPS Listener

  fnd_app_system.register_listener
                           ( Listener_Name   =>
                                     fnd_app_system.C_APPS_LISTENER_ID
						|| '_' || ServerName,
                             Server_name     => ServerName,
                             tns_alias_name  =>
                                     fnd_app_system.C_APPS_LISTENER_ID
                                                || '_' || ServerName,
                             listener_guid  => null,
                             alias_set_name => l_public_alias_set_name
                           );

  select a.Listener_GUID
    into l_Listener_GUID
    from fnd_tns_listeners a
   where a.Server_GUID = l_Server_Guid
     and a.Listener_Name = fnd_app_system.C_APPS_LISTENER_ID ||
					'_' || ServerName;

-- Register Listener Ports

-- Special case for Autoconfig. There should only be one port. Since
-- the caller can't pass in old/new values, we check for any existing
-- port entries. If supplied rpcPort does not exist, then use first
-- available.

  l_listener_port_guid := null;

  for f_port in c3(l_Listener_GUID) loop

    l_listener_port_guid := f_port.listener_port_guid;

    exit when f_port.port = to_number(RPCPort);

  end loop;

  fnd_app_system.register_listener_ports
                        ( Listener_name  => fnd_app_system.C_APPS_LISTENER_ID
                                                   ||'_'|| ServerName,
                          Port           => to_number(RPCPort),
                          server_guid    => l_server_guid,
                          Listener_Port_Guid
				         => l_listener_port_guid
                        );

  select a.listener_port_guid
    into l_listener_port_guid
    from fnd_tns_listener_ports a
   where a.listener_guid= l_Listener_GUID
     and a.port = to_number(RPCPort);

-- Create FNDFS/SM aliases

  l_fndsmfs(1).alias := '_' || Hostname;
  l_fndsmfs(1).sid   := '_' || SidDefaultAlias;

  for i in 1..l_fndsmfs.count loop

    l_fndfs_alias := 'FNDFS' || l_fndsmfs(i).alias;
    l_fndsm_alias := 'FNDSM' || l_fndsmfs(i).alias;

    l_fndfs_sid   := 'FNDFS' || l_fndsmfs(i).sid;
    l_fndsm_sid   := 'FNDSM' || l_fndsmfs(i).sid;

-- For now we only want certain types. Let's keep the loop in case
-- things change.

    l_fndfs_sid := 'FNDFS';

    begin

       select a.TNS_ALIAS_GUID
         into l_fndfs_tns_alias
         from fnd_tns_aliases a
        where a.Alias_Name = l_fndfs_alias
          and a.Alias_set_guid = l_tns_alias_set_guid_pub;

    exception
          when no_data_found then
               l_fndfs_tns_alias := sys_guid();
    end;

    begin

       select a.TNS_ALIAS_GUID
         into l_fndsm_tns_alias
         from fnd_tns_aliases a
        where a.Alias_Name = l_fndsm_alias
          and a.Alias_set_guid = l_tns_alias_set_guid_pub;

    exception
          when no_data_found then
               l_fndsm_tns_alias := sys_guid();
    end;

    register_alias
                  ( p_Alias_Name     => l_fndfs_alias,
                    p_Alias_Type     => fnd_app_system.C_FNDFS_TNS_ALIAS_TYPE,
                    p_Failover       => 'N',
                    p_Load_Balance   => 'N',
                    p_Service_GUID   => null,
                    p_Instance_Guid  => null,
                    p_alias_set_name => l_public_alias_set_name,
                    p_alias_set_guid => l_tns_alias_set_guid_pub,
                    p_tns_alias_guid => l_fndfs_tns_alias,
                    p_Listener_Port_Guid
                                     => l_Listener_port_GUID,
                    p_alt_instance_table
                                     => empty_instance_table
                  );

    register_alias
                  ( p_Alias_Name     => l_fndsm_alias,
                    p_Alias_Type     => fnd_app_system.C_FNDSM_TNS_ALIAS_TYPE,
                    p_Failover       => 'N',
                    p_Load_Balance   => 'N',
                    p_Service_GUID   => null,
                    p_Instance_Guid  => null,
                    p_alias_set_name => l_public_alias_set_name,
                    p_alias_set_guid => l_tns_alias_set_guid_pub,
                    p_tns_alias_guid => l_fndsm_tns_alias,
                    p_Listener_Port_Guid
                                     => l_Listener_port_GUID,
                    p_alt_instance_table
                                     => empty_instance_table
                  );

  end loop;

-- Now set up the aliases correctly. Process DB aliases before Instance
-- aliases, to ensure Instance aliases have priority over db aliases.


  register_app_alias( alias => SidDefaultAlias,
                      type => fnd_app_system.C_DB_BALANCE_TNS_ALIAS_TYPE ,
                      system_guid => l_System_Guid,
                      alias_set_name => l_public_alias_set_name,
                      alias_set_guid => l_tns_alias_set_guid_pub,
                      auto_create    => l_auto_create_aliases );

  register_app_alias( alias => ToolsInstanceAlias,
                      type => fnd_app_system.C_DB_INST_TNS_ALIAS_TYPE,
                      system_guid => l_System_Guid,
                      alias_set_name => l_public_alias_set_name,
                      alias_set_guid => l_tns_alias_set_guid_pub,
                      auto_create    => l_auto_create_aliases );

  register_app_alias( alias => WebInstanceAlias,
                      type => fnd_app_system.C_DB_INST_TNS_ALIAS_TYPE ,
                      system_guid => l_System_Guid,
                      alias_set_name => l_public_alias_set_name,
                      alias_set_guid => l_tns_alias_set_guid_pub,
                      auto_create    => l_auto_create_aliases );

  register_app_alias( alias => JDBCSid,
                      type => fnd_app_system.C_DB_INST_TNS_ALIAS_TYPE ,
                      system_guid => l_System_Guid,
                      alias_set_name => l_public_alias_set_name,
                      alias_set_guid => l_tns_alias_set_guid_pub,
                      auto_create    => l_auto_create_aliases );

end;

/*==========================================================================*/

procedure show_tns_addresses(p_Tns_Alias_Description_Guid raw)
as
cursor c1 is select d.listener_name,c.port,
                    a.sequence_number,a.failover,a.load_balance
               from fnd_tns_alias_address_lists a, fnd_tns_alias_addresses b,
                    fnd_tns_listener_ports c, fnd_tns_listeners d
              where a.Tns_Alias_Description_Guid = p_Tns_Alias_Description_Guid
                and a.Tns_Alias_Address_List_Guid =
                                            b.Tns_Alias_Address_List_Guid
                and b.listener_port_guid = c.listener_port_guid
                and c.Listener_GUID  = d.Listener_GUID
              order by a.sequence_number,b.listener_port_guid;
begin

  for f_listener1 in c1 loop

      dbms_output.put_line ( fmtline('SeqNo',8)       ||
                             fmtline('Lsrn Name',30)  ||
			     fmtline('Lsrn Port',20)  ||
                             fmtline('Fov',4)         ||
                             fmtline('Bal',4)
		           );

      dbms_output.put_line ( fmtuline(8) || fmtuline(30) ||  fmtuline(20) ||
                             fmtuline(4) || fmtuline(4) );

      dbms_output.put_line ( fmtline(f_listener1.sequence_number,8)    ||
                             fmtline(f_listener1.listener_name,30)||
			     fmtline(f_listener1.port,20)         ||
                             fmtline(f_listener1.Failover,4)           ||
                             fmtline(f_listener1.Load_Balance,4)
			   );
  end loop;

end;

/*==========================================================================*/

procedure show_servicename(p_DB_Service_GUID raw)
as
cursor c1 is select a.service_name
               from fnd_database_services a
              where a.DB_Service_GUID = p_DB_Service_GUID;
begin

  for f_service in c1 loop

      dbms_output.put_line ( fmtline('Service Name',30)    );

      dbms_output.put_line ( fmtuline(30));

      dbms_output.put_line ( fmtline(f_service.service_name,30) );

  end loop;

end;

/*==========================================================================*/

procedure show_service_instance(p_DB_Service_GUID raw,p_instance_guid raw)
as
cursor c1 is select a.service_name,b.Instance_Name,b.Instance_Number,
                    c.instance_type
               from fnd_database_services a, fnd_database_instances b,
                    fnd_db_service_members c
              where a.DB_Service_GUID = p_DB_Service_GUID
                and b.Instance_Guid   = p_instance_guid
                and a.Db_Service_Guid = c.Db_Service_Guid
                and c.Instance_Guid = p_instance_guid ;
begin

  for f_service in c1 loop

      dbms_output.put_line ( fmtline('Service Name',20) ||
		             fmtline('Instance Name',20) ||
                             fmtline('Instance Number',15)||
                             fmtline('10g-Pref/Ava',15)    );

      dbms_output.put_line ( fmtuline(20) || fmtuline(20) || fmtuline(15) ||
                             fmtuline(15) );

      dbms_output.put_line ( fmtline(f_service.service_name,20) ||
                             fmtline(f_service.Instance_Name,20) ||
                             fmtline(f_service.Instance_Number,15) ||
                             fmtline(f_service.instance_type,15) );

  end loop;

end;

/*==========================================================================*/

procedure show_tnsalias(p_info varchar2, p_tns_alias_guid raw )
as
cursor c1 is select a.alias_name,a.Alias_Type,
                    a.Failover,a.Load_Balance,
                    b.tns_alias_set_name,
		    b.tns_alias_set_type
               from fnd_tns_aliases a,fnd_tns_alias_sets b
              where a.tns_alias_guid = p_tns_alias_guid
                and a.alias_set_guid = b.tns_alias_set_guid;

cursor c2 is select c.tns_alias_description_guid,
                    c.DB_Service_GUID,c.DB_Instance_Guid,
                    c.Service_Name,c.Instance_Name,
                    c.Failover,c.Load_Balance,
                    c.sequence_number
               from fnd_tns_alias_descriptions c
              where c.tns_alias_guid = p_tns_alias_guid
               order by c.sequence_number;

begin

  dbms_output.put_line('>>>>');

  dbms_output.put_line ( fmtline('TNS Info for ' || p_info ,50) );

  dbms_output.put_line ( fmtuline(50) );

  for f_tns_alias in c1 loop

     dbms_output.put_line ( fmtline('Alias Name',20) 	||
                            fmtline('Type',20)		||
			    fmtline('Fov',4)	        ||
			    fmtline('Bal',4)            ||
                            fmtline('Alias Set Name',26) ||
                            fmtline('Set Type',10)
                          );

     dbms_output.put_line ( fmtuline(20) ||
                            fmtuline(20) ||
                            fmtuline(4)  ||
                            fmtuline(4)  ||
                            fmtuline(26) ||
                            fmtuline(10)
                          );

     dbms_output.put_line
              ( fmtline(f_tns_alias.alias_name,20)		||
		fmtline(f_tns_alias.Alias_Type,20)		||
		fmtline(f_tns_alias.Failover,4) 		||
		fmtline(f_tns_alias.Load_Balance,4)             ||
                fmtline(f_tns_alias.tns_alias_set_name,26)      ||
                fmtline(f_tns_alias.tns_alias_set_type,10)
	      );

     for f_desc in c2 loop

        dbms_output.put_line ( fmtline('SeqNo',8) 	||
	   		       fmtline('Fov',4)	        ||
	   		       fmtline('Bal',4)         ||
                               fmtline('SrvName',16)    ||
                               fmtline('InstName',16)
                             );

        dbms_output.put_line ( fmtuline(8 ) ||
                               fmtuline(4)  ||
                               fmtuline(4)  ||
                               fmtuline(16) ||
                               fmtuline(16)
                             );

        dbms_output.put_line
                 ( fmtline(f_desc.sequence_number,8)    ||
		   fmtline(f_desc.Failover,4) 		||
		   fmtline(f_desc.Load_Balance,4)       ||
                   fmtline(f_desc.service_name,16)      ||
                   fmtline(f_desc.instance_name,16)
	         );

        if ( f_tns_alias.Alias_Type
                      = fnd_app_system.C_LOCAL_INST_TNS_ALIAS_TYPE )
        then

           show_tns_addresses(f_desc.tns_alias_description_guid);

        end if;

        if ( f_tns_alias.Alias_Type
                      = fnd_app_system.C_REMOTE_INST_TNS_ALIAS_TYPE )
        then

           show_ServiceName(f_desc.DB_Service_GUID);
           show_tns_addresses(f_desc.tns_alias_description_guid);

        end if;

        if ( f_tns_alias.Alias_Type
                      = fnd_app_system.C_DB_BALANCE_TNS_ALIAS_TYPE )
        then

           show_ServiceName(f_desc.DB_Service_GUID);
           show_tns_addresses(f_desc.tns_alias_description_guid);

        end if;

        if ( f_tns_alias.Alias_Type
                      = fnd_app_system.C_DB_INST_TNS_ALIAS_TYPE )
        then

           show_Service_Instance(f_desc.DB_Service_GUID,
                                 f_desc.DB_instance_guid);
           show_tns_addresses(f_desc.tns_alias_description_guid);

        end if;

        if ( f_tns_alias.Alias_Type
                      = fnd_app_system.C_FNDFS_TNS_ALIAS_TYPE or
             f_tns_alias.Alias_Type
                      = fnd_app_system.C_FNDSM_TNS_ALIAS_TYPE )
        then

           show_tns_addresses(f_desc.tns_alias_description_guid);

        end if;

     end loop;

  end loop;

end;

/*==========================================================================*/

procedure show_FNDFSSM(p_Server_Guid raw)
as
l_fndfs_tns_alias       raw(16);
l_fndsm_tns_alias       raw(16);
l_fndfs_sid		varchar2(50);
l_fndsm_sid		varchar2(50);

cursor c1 is
  select a.TNS_ALIAS_GUID
    from fnd_tns_aliases a, fnd_tns_alias_set_usage b
   where a.Alias_Name like 'FNDFS%'
     and a.Alias_Type = fnd_app_system.C_FNDFS_TNS_ALIAS_TYPE
     and b.server_guid = p_Server_Guid
     and a.alias_set_guid = b.tns_alias_set_guid;

cursor c2 is
  select a.TNS_ALIAS_GUID
    from fnd_tns_aliases a, fnd_tns_alias_set_usage b
   where a.Alias_Name like 'FNDSM%'
     and a.Alias_Type = fnd_app_system.C_FNDSM_TNS_ALIAS_TYPE
     and b.server_guid = p_Server_Guid
     and a.alias_set_guid = b.tns_alias_set_guid;

begin

  for f_fndfs in c1 loop

    show_tnsalias('FNDFS-Alias', f_fndfs.tns_alias_guid);

  end loop;

  for f_fndsm in c2 loop

    show_tnsalias('FNDSM-Alias', f_fndsm.tns_alias_guid);

  end loop;

end;

/*==========================================================================*/

procedure show_instance ( p_Server_Guid	   raw )
as
cursor c1 is select db_guid,Instance_Guid,Instance_Name,Instance_Number,
                    Sid_GUID,Default_TNS_Alias_GUID,sid,
                    Local_Listener_Alias,Remote_Listener_Alias,
                    Configuration,Description,Interconnect_name
               from fnd_database_instances
              where Server_Guid = p_Server_Guid;

cursor c2(p_db_guid raw)
          is select db_name,db_domain,default_tns_alias_guid,is_rac_db,version
               from fnd_databases
              where db_guid = p_db_guid;

cursor c3(p_db_guid raw)
          is select assignment
               from fnd_database_assignments
              where db_guid = p_db_guid;

l_db_assignment	varchar2(50);

cursor c4(p_sid_guid raw)
          is select sid
               from fnd_sids
              where sid_guid = p_sid_guid;

l_sid		varchar2(50);
l_sid2		varchar2(50);

cursor c5(p_db_guid raw)
          is select DB_Service_GUID,db_guid,Service_Name,Description
               from fnd_database_services
              where db_guid = p_db_guid;

cursor c6(p_db_name varchar2,p_server_guid raw) is
      select a.TNS_ALIAS_GUID
        from fnd_tns_aliases a, fnd_tns_alias_set_usage b
       where a.Alias_Name   = p_db_name
         and a.Alias_Type   = fnd_app_system.C_DB_INST_TNS_ALIAS_TYPE
         and b.Server_Guid  = p_server_guid
         and b.Tns_Alias_Set_Guid = a.Alias_Set_Guid;

l_service_member	number;
l_db_name		varchar2(50);
l_tns_db_alias		raw(16);

begin

  dbms_output.put_line('>>>');
  dbms_output.put_line('>>> Show Instance');
  dbms_output.put_line('>>>');

  for f_instance in c1 loop

    for f_sid in c4(f_instance.sid_guid) loop

        l_sid2 := f_sid.sid;

    end loop;

    dbms_output.put_line
        (
          fmtline('Inst Name',10) ||
          fmtline('Inst No', 8)   ||
          fmtline('Config',10)    ||
          fmtline('Desc',15)      ||
          fmtline('InterCnt',15)  ||
          fmtline('SID',10)
        );

    dbms_output.put_line
        (
          fmtuline(10) ||
          fmtuline( 8) ||
          fmtuline(10) ||
          fmtuline(15) ||
          fmtuline(15) ||
          fmtuline(10)
        );

    dbms_output.put_line
        (
          fmtline(f_instance.Instance_Name,10)		||
 	  fmtline(f_instance.Instance_Number, 8)	||
          fmtline(f_instance.Configuration,10)		||
          fmtline(f_instance.Description,15)		||
          fmtline(f_instance.Interconnect_name,15)	||
          fmtline(f_instance.sid,10)
        );

    show_tnsalias('Default Inst TNS', f_instance.Default_TNS_Alias_GUID);
    show_tnsalias('Local TNS', f_instance.Local_Listener_Alias);
    show_tnsalias('Remote TNS', f_instance.Remote_Listener_Alias);

    for f_database in c2(f_instance.db_guid) loop

      for f_db_assignment in c3(f_instance.db_guid) loop

        l_db_assignment := f_db_assignment.assignment;

      end loop;

      l_db_name := f_database.db_name;

      dbms_output.put_line ( fmtline('DB Name',10)      ||
                             fmtline('Domain',20)       ||
                             fmtline('Cluster',8)       ||
                             fmtline('Version',10)  	||
			     fmtline('Assgn',10)
                           );

      dbms_output.put_line ( fmtuline(10) ||
                             fmtuline(20) ||
                             fmtuline(8)  ||
                             fmtuline(10) ||
			     fmtuline(10)
                           );

      dbms_output.put_line
              (	fmtline(f_database.db_name,10)		||
		fmtline(f_database.db_domain,20)	||
		fmtline(f_database.Is_rac_db, 8)	||
		fmtline(f_database.Version,10)	        ||
		fmtline(l_db_assignment,10)
	      );

      show_tnsalias('Default DB TNS', f_database.Default_TNS_Alias_GUID);

    end loop;

    for f_service in c5(f_instance.db_guid) loop

      select count(*)
        into l_service_member
        from fnd_db_service_members a
       where a.db_service_guid = f_service.db_service_guid
         and a.Instance_Guid   = f_instance.Instance_Guid ;

      dbms_output.put_line ( fmtline('Service Name',20)      ||
                             fmtline('Description',30)       ||
                             fmtline('Member',10)
                           );

      dbms_output.put_line ( fmtuline(20) ||
                             fmtuline(30) ||
                             fmtuline(10)
                           );

      dbms_output.put_line
              ( fmtline(f_service.Service_Name,20)	||
                fmtline(f_service.Description,30)	||
                fmtline(l_service_member,10)
              );

     for f_alias in c6(l_db_name,p_server_guid) loop

        show_tnsalias('DB Inst Alias', f_alias.tns_alias_guid );

     end loop;

    end loop;

  end loop;

end;

/*==========================================================================*/

procedure show ( SystemName         in     varchar2)
as
cursor c1 is select name,Version,Owner,CSI_Number,System_GUID
               from fnd_apps_system
              where name = SystemName;

cursor c2(p_System_Guid raw)
          is select a.Server_GUID,a.name,a.Node_Id,a.Internal,a.Appl_Top_Guid,
                    a.Server_type,a.Pri_Oracle_Home,a.Aux_Oracle_Home
               from fnd_app_servers a, fnd_system_server_map b
              where b.System_Guid = p_System_Guid
                and a.Server_GUID = b.Server_GUID
              order by a.node_id,a.Internal,a.Server_type,a.name;

cursor c3(p_appl_top_guid raw)
          is select name,Path,Shared
               from fnd_appl_tops
              where appl_top_guid = p_appl_top_guid;

cursor c4(p_oracle_home_id raw)
          is select name,Path,Version,Description
               from fnd_oracle_homes
              where oracle_home_id = p_oracle_home_id;

l_nodeRec       fnd_nodes%rowtype;

begin

  dbms_output.enable(1000000);

  for f_app_rec in c1 loop

    dbms_output.put_line
        (
          fmtline('System Name',15) ||
          fmtline('Version',15)     ||
          fmtline('Owner',20)       ||
          fmtline('CSI Number',15)
        );

    dbms_output.put_line
        (
          fmtuline(15) ||
          fmtuline(15) ||
          fmtuline(20) ||
          fmtuline(15)
        );

    dbms_output.put_line
        (
          fmtline(f_app_rec.name,15)    ||
          fmtline(f_app_rec.version,15)  ||
          fmtline(f_app_rec.owner,20)    ||
          fmtline(f_app_rec.CSI_Number,15)
        );

    for f_server in c2(f_app_rec.System_GUID) loop

       execute immediate 'select a.* ' ||
                         '  from fnd_nodes a ' ||
                         ' where a.node_id = :v1 '
                     into l_nodeRec
                    using f_server.node_id;

       dbms_output.put_line('>');

       dbms_output.put_line
           (
             fmtline('Server Name',20) ||
             fmtline('Internal',10)    ||
             fmtline('Type',10)        ||
             fmtline('Node',10)        ||
             fmtline('Host',10)        ||
             fmtline('Domain',15)
           );

       dbms_output.put_line( fmtuline(20) ||
                             fmtuline(10) ||
                             fmtuline(10) ||
                             fmtuline(10) ||
                             fmtuline(10) ||
                             fmtuline(15) );

       dbms_output.put_line
           (
             fmtline(f_server.name,20)	    ||
             fmtline(f_server.internal,10)  ||
             fmtline(f_server.server_type,10) ||
             fmtline(l_nodeRec.node_name,10)

-- Only certain versions of fnd_nodes has host/domain. So to be safe,
-- we just comment out the following lines.

--           fmtline(l_nodeRec.host,10)  ||
--           fmtline(l_nodeRec.domain,15)
           );

       if ( f_server.appl_top_guid is not null )
       then

          for f_appl_top in c3(f_server.appl_top_guid) loop

            dbms_output.put_line('>>');

            dbms_output.put_line ( fmtline('App Name|Path',20) ||
                                   fmtline('Shared',10)    );

            dbms_output.put_line ( fmtuline(20) || fmtuline(10) );

            dbms_output.put_line ( fmtline(f_appl_top.name,20) ||
                                   fmtline(f_appl_top.shared,10) );
            dbms_output.put_line( f_appl_top.path );

          end loop;
       end if;

       for f_o_home in c4(f_server.pri_oracle_home) loop

            dbms_output.put_line('>>');

            dbms_output.put_line ( fmtline('Home Name|Path',20) ||
                                   fmtline('Version',15) ||
                                   fmtline('Description',30)   );

            dbms_output.put_line (fmtuline(20) || fmtuline(15) || fmtuline(30));

            dbms_output.put_line ( fmtline(f_o_home.name,20) ||
                                   fmtline(f_o_home.version,15) ||
                                   fmtline(f_o_home.Description,30) );
            dbms_output.put_line( f_o_home.path );

       end loop;

       if ( f_server.aux_oracle_home is not null )
       then

          for f_o_home in c4(f_server.aux_oracle_home) loop

            dbms_output.put_line('>>');

            dbms_output.put_line ( fmtline('Home Name|Path',20) ||
                                   fmtline('Version',15) ||
                                   fmtline('Description',30)   );

            dbms_output.put_line (fmtuline(20) || fmtuline(15) || fmtuline(30));

            dbms_output.put_line ( fmtline(f_o_home.name,20) ||
                                   fmtline(f_o_home.version,15) ||
                                   fmtline(f_o_home.Description,30) );
            dbms_output.put_line( f_o_home.path );

          end loop;
       end if;

       if ( f_server.server_type = fnd_app_system.C_DB_SERVER_TYPE )
       then
          show_instance(f_server.Server_Guid);
       end if;

       if ( f_server.server_type = fnd_app_system.C_APP_SERVER_TYPE )
       then
          show_FNDFSSM(f_server.Server_Guid);
       end if;

    end loop;

  end loop;

end;

/*==========================================================================*/

procedure remove_dbnode  ( SystemName         in      varchar2,
                           ServerName         in      varchar2,
                           DatabaseName       in      varchar2,
                           InstanceName       in      varchar2,
			   Domain	      in      varchar2
                         )
as
l_System_GUID		raw(16);

-- Always lock the system when doing major structural changes.

cursor c1(p_SystemName varchar2) is
          select a.System_Guid
            from fnd_apps_system a
           where a.name = p_SystemName
             for update of a.System_Guid;

cursor c2(p_System_GUID raw, p_ServerName varchar2) is
          select a.Server_GUID,b.PRI_ORACLE_HOME,c.listener_guid
            from fnd_system_server_map a, fnd_app_servers b,
                 fnd_tns_listeners c
           where a.System_GUID = p_System_GUID
             and a.Server_GUID = b.Server_GUID
             and b.name = p_ServerName
             and b.server_type = fnd_app_system.C_DB_SERVER_TYPE
             and b.Server_GUID = c.Server_GUID(+);

cursor c3(p_Server_GUID raw,p_InstanceName varchar2,
          p_DatabaseName varchar2,p_Domain varchar2) is
          select a.instance_guid,a.sid_guid,
                 a.default_tns_alias_guid instance_tns_alias_guid,
                 a.local_listener_alias,
                 a.remote_listener_alias,
                 b.db_guid,
                 b.default_tns_alias_guid db_tns_alias_guid
            from fnd_database_instances a,fnd_databases b
           where a.Server_GUID = p_Server_GUID
             and a.Instance_Name = p_InstanceName
             and a.db_guid = b.db_guid
             and b.DB_Name = p_DatabaseName
             and b.DB_Domain = p_Domain;
begin

  for f_system in c1(SystemName) loop

    for f_server in c2(f_system.System_Guid,ServerName) loop

      delete from fnd_oracle_homes a
       where a.oracle_home_id = f_server.pri_oracle_home
         and not exists ( select b.name
                            from fnd_app_servers b
                           where (   b.pri_oracle_home
                                          = f_server.pri_oracle_home
                                  or b.aux_oracle_home
                                          = f_server.pri_oracle_home
                                 )
                             and b.server_guid <> f_server.server_guid
                        );

      if ( f_server.Listener_GUID is not null )
      then

         delete from fnd_tns_alias_address_lists a
          where a.Tns_Alias_Address_List_Guid
                 in ( select b.Tns_Alias_Address_List_Guid
                        from fnd_tns_alias_addresses b,fnd_tns_listener_ports c
                       where b.listener_port_guid = c.listener_port_guid
                         and c.Listener_GUID = f_server.Listener_GUID )
            and 1 = ( select count(*)
                        from fnd_tns_alias_addresses c
                       where c.Tns_Alias_Address_List_Guid
                                           = a.Tns_Alias_Address_List_Guid );

--	Note on delete of : fnd_tns_aliases and fnd_tns_alias_descriptions
--         The deletes remove all dangling references, not just the
--         current db node. Since the only dangling references should be
--         this node this seems ok.

--      A descriptor can be unresolved. If it is, it will not have
--      an address list, in which case we can't just delete dangling
--      references. So unresolved descriptors can only be deleted at the
--      server level.

         delete from fnd_tns_alias_descriptions a
          where not exists ( select 1
                                from fnd_tns_alias_address_lists b
                               where b.Tns_Alias_Description_Guid
                                             = a.Tns_Alias_Description_Guid )
            and a.sequence_number >= 0;

--      An alias will always have a descriptor, so ok.

         delete from fnd_tns_aliases a
          where not exists ( select 1
                               from fnd_tns_alias_descriptions b
                              where b.Tns_Alias_Guid = a.Tns_Alias_Guid );

         delete from fnd_tns_alias_addresses b
          where b.Listener_port_GUID
                  in ( select c.listener_port_guid
                         from fnd_tns_listener_ports c
                        where c.Listener_GUID = f_server.Listener_GUID );

         delete from fnd_tns_listener_ports a
          where a.Listener_GUID = f_server.Listener_GUID;

         delete from fnd_tns_listeners a
          where a.Listener_GUID = f_server.Listener_GUID;

      end if;

      for f_instance in c3(f_server.Server_GUID,InstanceName,DatabaseName,
                           Domain) loop

        delete from fnd_database_instances a
         where a.instance_guid = f_instance.instance_guid;

        delete from fnd_db_service_members a
         where a.db_guid = f_instance.db_guid
           and a.instance_guid = f_instance.instance_guid;

        delete from fnd_sids a
         where a.sid_guid = f_instance.sid_guid;

        delete from fnd_database_services a
         where a.db_guid = f_instance.db_guid
           and not exists ( select b.instance_guid
                              from fnd_db_service_members b
                             where b.db_service_guid = a.db_service_guid );

        delete from fnd_databases a
         where a.db_guid = f_instance.db_guid
           and not exists ( select b.instance_guid
                              from fnd_database_instances b
                             where b.db_guid = a.db_guid );

        delete from fnd_database_assignments a
         where a.db_guid = f_instance.db_guid
           and a.assignment = fnd_app_system.C_APP_DB_ASSIGNMENT
           and not exists ( select 1
                              from fnd_databases b
                             where b.db_guid = a.db_guid ) ;

      end loop;

    end loop;

  end loop;

end;

/*==========================================================================*/

procedure remove_appnode ( SystemName         in     varchar2,
                           ServerName         in     varchar2
                         )
as

-- Always lock the system when doing major structural changes.

cursor c1(p_SystemName varchar2) is
          select a.System_Guid
            from fnd_apps_system a
           where a.name = p_SystemName
             for update of a.System_Guid;

cursor c2(p_System_GUID raw, p_ServerName varchar2) is
          select a.Server_GUID,b.PRI_ORACLE_HOME,c.listener_guid,
                 b.APPL_TOP_GUID,b.AUX_ORACLE_HOME
            from fnd_system_server_map a, fnd_app_servers b,
                 fnd_tns_listeners c
           where a.System_GUID = p_System_GUID
             and a.Server_GUID = b.Server_GUID
             and b.name = p_ServerName
             and b.server_type = fnd_app_system.C_APP_SERVER_TYPE
             and b.Server_GUID = c.Server_GUID(+);

begin

  for f_system in c1(SystemName) loop

    for f_server in c2(f_system.System_Guid,ServerName) loop

      delete from fnd_oracle_homes a
       where a.oracle_home_id = f_server.pri_oracle_home
         and not exists ( select b.name
                            from fnd_app_servers b
                           where (   b.pri_oracle_home
                                          = f_server.pri_oracle_home
                                  or b.aux_oracle_home
                                          = f_server.pri_oracle_home
                                 )
                             and b.server_guid <> f_server.server_guid
                        );

      if ( f_server.aux_oracle_home is not null )
      then
         delete from fnd_oracle_homes a
          where a.oracle_home_id = f_server.aux_oracle_home
            and not exists ( select b.name
                               from fnd_app_servers b
                              where (   b.pri_oracle_home
                                             = f_server.aux_oracle_home
                                     or b.aux_oracle_home
                                             = f_server.aux_oracle_home
                                    )
                                and b.server_guid <> f_server.server_guid
                           );

      end if;

      if ( f_server.appl_top_guid is not null )
      then
         delete from fnd_appl_tops a
          where a.appl_top_guid = f_server.appl_top_guid
            and not exists ( select b.name
                               from fnd_app_servers b
                              where b.appl_top_guid = f_server.appl_top_guid
                                and b.server_guid <> f_server.server_guid
                           );
      end if;

      if ( f_server.Listener_GUID is not null )
      then

        delete from fnd_tns_alias_address_lists a
         where a.Tns_Alias_Address_List_Guid
                 in ( select b.Tns_Alias_Address_List_Guid
                        from fnd_tns_alias_addresses b,fnd_tns_listener_ports c
                       where b.listener_port_guid = c.listener_port_guid
                         and c.Listener_GUID = f_server.Listener_GUID )
           and 1 = ( select count(*)
                       from fnd_tns_alias_addresses c
                      where c.Tns_Alias_Address_List_Guid
                                           = a.Tns_Alias_Address_List_Guid );

--      Note on delete of : fnd_tns_aliases and fnd_tns_alias_descriptions
--         The deletes remove all dangling references, not just the
--         current db node. Since the only dangling references should be
--         this node this seems ok.

--	A descriptor can be unresolved. If it is, it will not have
--      an address list, in which case we can't just delete dangling
--      references. So unresolved descriptors can only be deleted at the
--      server level.

         delete from fnd_tns_alias_descriptions a
          where not exists ( select 1
                                from fnd_tns_alias_address_lists b
                               where b.Tns_Alias_Description_Guid
                                             = a.Tns_Alias_Description_Guid )
            and a.sequence_number >= 0;

--	An alias will always have a descriptor, so ok.

         delete from fnd_tns_aliases a
          where not exists ( select 1
                               from fnd_tns_alias_descriptions b
                              where b.Tns_Alias_Guid = a.Tns_Alias_Guid );

         delete from fnd_tns_alias_addresses b
          where b.Listener_port_GUID
                  in ( select c.listener_port_guid
                         from fnd_tns_listener_ports c
                        where c.Listener_GUID = f_server.Listener_GUID );

         delete from fnd_tns_listener_ports a
          where a.Listener_GUID = f_server.Listener_GUID;

         delete from fnd_tns_listeners a
          where a.Listener_GUID = f_server.Listener_GUID;

      end if;

    end loop;

  end loop;

end;

/*==========================================================================*/

procedure remove_server  ( SystemName         in      varchar2,
                           ServerName         in      varchar2
                         )
as

-- Always lock the system when doing major structural changes.

cursor c1(p_SystemName varchar2) is
          select a.System_Guid
            from fnd_apps_system a
           where a.name = p_SystemName
             for update of a.System_Guid;

cursor c2(p_System_GUID raw, p_ServerName varchar2) is
          select a.Server_GUID,b.Server_type
            from fnd_system_server_map a, fnd_app_servers b
           where a.System_GUID = p_System_GUID
             and a.Server_GUID = b.Server_GUID
             and b.name = p_ServerName;

cursor c3(p_Server_GUID raw) is
          select a.instance_name,b.DB_Name,b.DB_Domain
            from fnd_database_instances a,fnd_databases b
           where a.Server_GUID = p_Server_GUID
             and a.db_guid = b.db_guid;

cursor c4(p_Server_GUID raw) is
          select a.tns_alias_guid,b.Tns_Alias_Description_Guid,
                 c.Tns_Alias_Address_List_Guid
            from fnd_tns_aliases a,fnd_tns_alias_descriptions b,
                 fnd_tns_alias_address_lists c,fnd_tns_alias_set_usage d
           where d.server_guid = p_server_guid
             and d.tns_alias_set_guid = a.alias_set_guid
             and a.tns_alias_guid = b.tns_alias_guid
             and b.Tns_Alias_Description_Guid = c.Tns_Alias_Description_Guid(+);

begin

  for f_system in c1(SystemName) loop

    for f_server in c2(f_system.System_Guid,ServerName) loop

      if ( f_server.Server_type = fnd_app_system.C_DB_SERVER_TYPE )
      then

         for f_instance in c3(f_server.Server_GUID) loop

           remove_dbnode(SystemName,ServerName,f_instance.db_name,
                         f_instance.instance_name,f_instance.db_domain);

         end loop;

      end if;

      if ( f_server.Server_type = fnd_app_system.C_APP_SERVER_TYPE )
      then

         remove_AppNode(SystemName,ServerName);

--	 Remove any remaining aliases assigned to set.

         for f_alias in c4(f_server.Server_GUID) loop

           delete from fnd_tns_alias_descriptions a
            where a.Tns_Alias_Description_Guid =
                       f_alias.Tns_Alias_Description_Guid;

           if ( f_alias.Tns_Alias_Address_List_Guid is not null )
           then

              delete from fnd_tns_alias_address_lists a
               where a.Tns_Alias_Address_List_Guid =
                          f_alias.Tns_Alias_Address_List_Guid;

              delete from fnd_tns_alias_addresses a
               where a.Tns_Alias_Address_List_Guid =
                          f_alias.Tns_Alias_Address_List_Guid;

           end if;

           delete from fnd_tns_aliases a
            where a.tns_alias_guid = f_alias.tns_alias_guid;

         end loop;

      end if;

      delete from fnd_tns_alias_sets a
       where a.tns_alias_set_guid
                 in ( select b.tns_alias_set_guid
                        from fnd_tns_alias_set_usage b
                       where b.server_guid = f_server.server_guid );

      delete from fnd_tns_alias_set_usage a
       where a.server_guid = f_server.server_guid;

      delete from fnd_system_server_map a
       where a.System_GUID = f_system.System_Guid
         and a.Server_GUID = f_server.Server_GUID;

      delete from fnd_app_servers a
       where a.Server_GUID = f_server.Server_GUID;

    end loop;

  end loop;

end;

/*==========================================================================*/

procedure remove_system  (  SystemName         in      varchar2 )
as

-- Always lock the system when doing major structural changes.

cursor c1(p_SystemName varchar2) is
          select a.System_Guid
            from fnd_apps_system a
           where a.name = p_SystemName
             for update of a.System_Guid;

cursor c2(p_System_GUID raw) is
          select a.Server_GUID,b.name
            from fnd_system_server_map a, fnd_app_servers b
           where a.System_GUID = p_System_GUID
             and a.Server_GUID = b.Server_GUID;
begin

  for f_system in c1(SystemName) loop

    for f_server in c2(f_system.System_Guid) loop

      remove_Server(SystemName,f_server.Name);

    end loop;

    delete from fnd_apps_system a
     where a.System_GUID = f_system.System_Guid ;

  end loop;

end;

/*==========================================================================*/

begin
  null;
end FND_NET_SERVICES;

/
