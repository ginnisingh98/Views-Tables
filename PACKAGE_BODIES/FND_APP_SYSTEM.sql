--------------------------------------------------------
--  DDL for Package Body FND_APP_SYSTEM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_APP_SYSTEM" as
/* $Header: AFCPSYSB.pls 120.3 2005/12/20 09:59:35 ssuraj noship $ */

/*==========================================================================*/

procedure register_system ( Name                 varchar2,
                            owner                varchar2,
                            CSI_NUMBER           varchar2,
                            System_Guid          raw            default null
                         )
as
l_rec           fnd_apps_system%rowtype;
l_insert        boolean := false;

begin

  l_rec.System_Guid     := System_Guid;
  l_rec.Name            := Name;
  l_rec.owner           := owner;
  l_rec.CSI_NUMBER      := CSI_NUMBER;

  if ( l_rec.System_Guid is null )
  then
     begin

        select a.System_Guid
          into l_rec.System_Guid
          from fnd_apps_system a
         where a.name = l_rec.Name;

     exception
         when no_data_found then
              l_insert := true;
     end;
  end if;

  if ( l_insert )
  then
     insert into fnd_apps_system
                 (name,Version,Owner,CSI_Number,System_GUID,Source_System_Guid,
                  last_updated_by,last_update_date,last_update_login,
                  creation_date,created_by
                 )
       values ( l_rec.Name,'1',l_rec.owner,l_rec.CSI_NUMBER,sys_guid(),
                sys_guid(),
                1,sysdate,0,sysdate,1 );
  else

     update fnd_apps_system a
        set a.name = nvl(l_rec.Name,a.name),
            a.owner= nvl(l_rec.Owner,a.owner),
            a.csi_number=nvl(l_rec.CSI_NUMBER,a.csi_number),
            a.last_update_date = SYSDATE,
            a.last_updated_by = 1
      where a.System_Guid = l_rec.System_Guid;

  end if;

end;

/*==========================================================================*/

procedure register_oraclehome ( name                  varchar2,
                                Node_Id               varchar2,
                                Path                  varchar2,
                                Version               varchar2,
                                Description           varchar2,
                                File_System_GUID      raw,
                                Oracle_Home_Id        raw        default null )
as
l_rec           fnd_oracle_homes%rowtype;
l_insert        boolean := false;

begin

  l_rec.Oracle_Home_Id := Oracle_Home_Id;
  l_rec.name        := name;
  l_rec.Node_Id     := Node_Id;
  l_rec.Path        := Path;
  l_rec.Version     := Version;
  l_rec.Description := Description;
  l_rec.File_System_GUID := File_System_GUID;

  if ( l_rec.Oracle_Home_Id is null )
  then
     begin

        select a.Oracle_Home_Id
          into l_rec.Oracle_Home_Id
          from fnd_oracle_homes a
         where a.node_id = l_rec.Node_Id
           and a.path    = l_rec.Path;
     exception
         when no_data_found then
             l_insert := true;
     end;
  end if;

  if ( l_insert )
  then

     insert into fnd_oracle_homes
                 (Oracle_Home_Id,name,Node_Id,Path,Version,
                  Description,File_System_GUID,
                  last_updated_by,last_update_date,last_update_login,
                  creation_date,created_by,created
                 )
       values ( sys_guid(),l_rec.name,l_rec.Node_Id,l_rec.Path,
                l_rec.Version,
                l_rec.Description,nvl(l_rec.File_System_GUID,sys_guid()),
                1,sysdate,0,sysdate,1,sysdate );
  else

     update fnd_oracle_homes a
        set a.name = nvl(l_rec.Name,a.name),
            a.node_id = nvl(l_rec.Node_Id,a.Node_Id),
            a.path = nvl(l_rec.Path,a.path),
            a.version = nvl(l_rec.Version,a.version),
            a.Description = nvl(l_rec.Description,a.Description),
            a.File_System_GUID = nvl(l_rec.File_System_GUID,a.File_System_GUID),
            a.last_update_date = SYSDATE,
            a.last_updated_by = 1
      where a.Oracle_Home_Id = l_rec.Oracle_Home_Id;

  end if;

end;

/*==========================================================================*/

procedure register_appltop    ( name                  varchar2,
                                Node_Id               varchar2,
                                Path                  varchar2,
                                Shared                varchar2,
                                File_System_GUID      raw,
                                Appl_Top_Guid         raw        default null )
as
l_rec           fnd_appl_tops%rowtype;
l_insert        boolean := false;

begin

  l_rec.Appl_Top_Guid   := Appl_Top_Guid;
  l_rec.name            := name;
  l_rec.Node_Id         := Node_Id;
  l_rec.Path            := Path;
  l_rec.Shared          := Shared;
  l_rec.File_System_GUID:= File_System_GUID;

  if ( l_rec.Appl_Top_Guid is null )
  then
     begin

        select a.appl_top_guid
          into l_rec.Appl_Top_Guid
          from fnd_appl_tops a
         where a.node_id = l_rec.Node_Id
           and a.path    = l_rec.Path;

     exception
         when no_data_found then
              l_insert := true;
     end;
  end if;

  if ( l_insert )
  then

     insert into fnd_appl_tops
                 (appl_top_guid,name,Node_Id,Path,Shared,File_System_GUID,
                  last_updated_by,last_update_date,last_update_login,
                  creation_date,created_by
                 )
       values ( sys_guid(),l_rec.name,l_rec.Node_Id,l_rec.Path,
                l_rec.Shared,nvl(l_rec.File_System_GUID,sys_guid()),
                1,sysdate,0,sysdate,1 );
  else

     update fnd_appl_tops a
        set a.name = nvl(l_rec.Name,a.name),
            a.node_id = nvl(l_rec.Node_Id,a.Node_Id),
            a.path = nvl(l_rec.Path,a.path),
            a.shared = nvl(l_rec.shared,a.shared),
            a.File_System_GUID = nvl(l_rec.File_System_GUID,a.File_System_GUID),
            a.last_update_date = SYSDATE,
            a.last_updated_by = 1
      where a.appl_top_guid = l_rec.Appl_Top_Guid;

  end if;

end;

/*==========================================================================*/

procedure register_server     ( Name                   varchar2,
                                Node_Id                varchar2,
                                Internal               varchar2,
                                Appl_Top_Guid          raw,
                                Server_type            varchar2,
                                Pri_Oracle_Home        raw,
                                Aux_Oracle_Home        raw,
                                Server_GUID            raw        default null )
as
l_rec           fnd_app_servers%rowtype;
l_insert        boolean := false;

begin

  l_rec.Server_GUID     := Server_GUID;
  l_rec.Name            := Name;
  l_rec.Node_Id         := Node_Id;
  l_rec.Internal        := Internal;
  l_rec.Appl_Top_Guid   := Appl_Top_Guid;
  l_rec.Server_type     := Server_type;
  l_rec.Pri_Oracle_Home := Pri_Oracle_Home;
  l_rec.Aux_Oracle_Home := Aux_Oracle_Home;

  if ( l_rec.Server_GUID is null )
  then
     begin

        select a.Server_GUID
          into l_rec.Server_GUID
          from fnd_app_servers a
         where a.name = l_rec.name;

     exception
         when no_data_found then
              l_insert := true;
     end;
  end if;

  if ( l_insert )
  then

     insert into fnd_app_servers
                 (Server_GUID,name,Node_Id,Internal,Appl_Top_Guid,
                  Server_type,Pri_Oracle_Home,Aux_Oracle_Home,
                  last_updated_by,last_update_date,last_update_login,
                  creation_date,created_by
                 )
       values ( sys_guid(),l_rec.name,l_rec.Node_Id,l_rec.internal,
                l_rec.Appl_Top_Guid,l_rec.Server_type,
                nvl(l_rec.Pri_Oracle_Home,sys_guid()),
                l_rec.Aux_Oracle_Home,
                1,sysdate,0,sysdate,1 );
  else

     update fnd_app_servers a
        set a.name = nvl(l_rec.Name,a.name),
            a.node_id = nvl(l_rec.Node_Id,a.Node_Id),
            a.internal = nvl(l_rec.internal,a.internal),
            a.Appl_Top_Guid = nvl(l_rec.Appl_Top_Guid,a.Appl_Top_Guid),
            a.Server_type = nvl(l_rec.Server_type,a.Server_type),
            a.Pri_Oracle_Home = nvl(l_rec.Pri_Oracle_Home,a.Pri_Oracle_Home),
            a.Aux_Oracle_Home = nvl(l_rec.Aux_Oracle_Home,a.Aux_Oracle_Home),
            a.last_update_date = SYSDATE,
            a.last_updated_by = 1
      where a.Server_GUID = l_rec.Server_GUID;

  end if;

end;

/*==========================================================================*/

procedure register_servermap  ( Server_GUID            raw,
                                System_Guid            raw )
as
l_rec                   fnd_system_server_map%rowtype;
l_insert                boolean := false;

begin

  l_rec.Server_GUID     := Server_GUID;
  l_rec.System_Guid     := System_Guid;

  begin

     select a.Server_GUID,a.System_Guid
       into l_rec.Server_GUID,l_rec.System_Guid
       from fnd_system_server_map a
      where a.Server_GUID = l_rec.Server_GUID
        and a.System_Guid = l_rec.System_Guid;

  exception
      when no_data_found then
           l_insert := true;
  end;

  if ( l_insert )
  then

     insert into fnd_system_server_map
                 (Server_GUID,System_Guid,
                  last_updated_by,last_update_date,last_update_login,
                  creation_date,created_by
                 )
       values ( l_rec.Server_GUID,l_rec.System_Guid,1,sysdate,0,sysdate,1 );

  else

     update fnd_system_server_map a
        set a.Server_GUID = nvl(l_rec.Server_GUID,a.Server_GUID),
            a.System_Guid = nvl(l_rec.System_Guid,a.System_Guid),
            a.last_update_date = SYSDATE,
            a.last_updated_by = 1
      where a.Server_GUID = l_rec.Server_GUID
        and a.System_Guid = l_rec.System_Guid;

  end if;

end;

/*==========================================================================*/

procedure register_database   ( db_name               varchar2,
                                db_domain             varchar2,
                                Default_TNS_Alias_Guid raw,
                                Is_Rac_db	      varchar2,
                                Version               varchar2,
                                db_guid               raw        default null
                             )
as
l_rec                   fnd_databases%rowtype;
l_insert                boolean := false;
begin

  l_rec.db_guid         := db_guid;
  l_rec.db_name         := db_name;
  l_rec.db_domain       := db_domain;
  l_rec.Default_TNS_Alias_Guid := Default_TNS_Alias_Guid;
  l_rec.Is_Rac_db	:= Is_Rac_db;
  l_rec.Version         := Version;

  if ( l_rec.db_guid is null )
  then
     begin

        select a.db_guid
          into l_rec.db_guid
          from fnd_databases a
         where a.db_name  = l_rec.db_name
           and a.db_domain= l_rec.db_domain;

     exception
         when no_data_found then
             l_insert := true;
     end;
  end if;

  if ( l_insert )
  then

     insert into fnd_databases
                 (db_guid,DB_Name,DB_Domain,Default_TNS_Alias_Guid,Is_Rac_db,
                  Version,
                  last_updated_by,last_update_date,last_update_login,
                  creation_date,created_by
                 )
       values ( sys_guid(),l_rec.db_name,l_rec.db_domain,
                nvl(l_rec.Default_TNS_Alias_Guid,sys_guid()),
                l_rec.Is_Rac_db,l_rec.Version,
                1,sysdate,0,sysdate,1 );
  else

     update fnd_databases a
        set a.db_name = nvl(l_rec.db_Name,a.db_name),
            a.db_domain =nvl(l_rec.db_domain,a.db_domain),
            a.Default_TNS_Alias_Guid =
                   nvl(l_rec.Default_TNS_Alias_Guid,a.Default_TNS_Alias_Guid),
            a.Is_Rac_db = nvl(l_rec.Is_Rac_db,a.Is_Rac_db),
            a.version = nvl(l_rec.Version,a.version),
            a.last_update_date = SYSDATE,
            a.last_updated_by = 1
      where a.db_guid = l_rec.db_guid;

  end if;

end;

/*==========================================================================*/

procedure register_database_asg( db_name             varchar2,
                                 assignment          varchar2,
                                 db_domain           varchar2
                             )
as
l_rec                   fnd_database_assignments%rowtype;
l_insert                boolean := false;
l_db_domain             fnd_databases.db_domain%TYPE;
l_db_name               fnd_databases.db_name%TYPE;
l_count                 number;

begin

  l_db_name             := db_name;
  l_db_domain           := db_domain;
  l_rec.assignment      := assignment;

  select a.db_guid
    into l_rec.db_guid
    from fnd_databases a
   where a.db_name  = l_db_name
     and a.db_domain = l_db_domain;

  begin

    select a.db_guid
      into l_rec.db_guid
      from fnd_database_assignments  a
     where a.db_guid = l_rec.db_guid
       and a.assignment = l_rec.assignment;

  exception
     when no_data_found then
         l_insert := true;
  end;

  if ( l_insert )
  then

     insert into fnd_database_assignments
                 (db_guid,assignment,
                  last_updated_by,last_update_date,last_update_login,
                  creation_date,created_by
                 )
       values ( l_rec.db_guid,l_rec.assignment,
                1,sysdate,0,sysdate,1 );
  else

     update fnd_database_assignments a
        set a.assignment = nvl(l_rec.assignment,a.assignment),
            a.last_update_date = SYSDATE,
            a.last_updated_by = 1
      where a.db_guid = l_rec.db_guid
        and a.assignment = l_rec.assignment;

  end if;

end;

/*==========================================================================*/

procedure register_instance   ( db_name                  varchar2,
                                Instance_Name            varchar2,
                                Instance_Number          Number,
                                Sid_GUID                 raw,
			        Sid			 varchar2,
                                Default_TNS_Alias_GUID   raw,
                                Server_GUID              raw,
                                Local_Listener_Alias     raw,
                                Remote_Listener_Alias    raw,
                                Configuration            varchar2,
                                Description              varchar2,
                                Interconnect_name        varchar2,
                                Instance_Guid            raw    default null,
                                db_domain                varchar2
                              )
as
l_rec                   fnd_database_instances%rowtype;
l_insert                boolean := false;
l_db_name               fnd_databases.db_name%type;
l_db_domain             fnd_databases.db_domain%type;
begin

  l_db_name                     := db_name;
  l_db_domain                   := db_domain;
  l_rec.Instance_Guid           := Instance_Guid;
  l_rec.Instance_Name           := Instance_Name;
  l_rec.Instance_Number         := Instance_Number;
  l_rec.Sid_GUID                := Sid_GUID;
  l_rec.Sid                     := Sid;
  l_rec.Default_TNS_Alias_GUID  := Default_TNS_Alias_GUID;
  l_rec.Server_GUID             := Server_GUID;
  l_rec.Local_Listener_Alias    := Local_Listener_Alias;
  l_rec.Remote_Listener_Alias   := Remote_Listener_Alias;
  l_rec.Configuration           := Configuration;
  l_rec.Description             := Description;
  l_rec.Interconnect_name       := Interconnect_name;

   select a.db_guid
     into l_rec.db_guid
     from fnd_databases a
    where a.db_name  = l_db_name
     and  a.db_domain = l_db_domain;

  if ( l_rec.Instance_Guid is null )
  then
     begin

        select a.db_guid,a.Instance_Guid
          into l_rec.db_guid,l_rec.Instance_Guid
          from fnd_database_Instances a
         where a.db_guid  = l_rec.db_guid
           and a.Instance_Name = l_rec.Instance_Name;

     exception
         when no_data_found then
             l_insert := true;
     end;
  end if;

  if ( l_insert )
  then

     insert into fnd_database_instances
                 (db_guid,Instance_Guid,Instance_Name,Instance_Number,Sid_GUID,
		  Sid,
                  Default_TNS_Alias_GUID,Server_GUID,Local_Listener_Alias,
                  Remote_Listener_Alias,Configuration,Description,
                  Interconnect_name,
                  last_updated_by,last_update_date,last_update_login,
                  creation_date,created_by
                 )
       values (
                l_rec.db_guid,sys_guid(),l_rec.Instance_Name,
                l_rec.Instance_Number,nvl(l_rec.Sid_GUID,sys_guid()),l_rec.sid,
                nvl(l_rec.Default_TNS_Alias_GUID,sys_guid()),
                l_rec.Server_GUID,
                nvl(l_rec.Local_Listener_Alias,sys_guid()),
                l_rec.Remote_Listener_Alias,
                l_rec.Configuration,l_rec.Description,l_rec.Interconnect_name,
                1,sysdate,0,sysdate,1 );
  else

     update fnd_database_instances a
        set a.Instance_Name = nvl(l_rec.Instance_Name,a.Instance_Name),
            a.Instance_Number = nvl(l_rec.Instance_Number,a.Instance_Number),
            a.Sid_GUID = nvl(l_rec.Sid_GUID,a.Sid_GUID),
            a.Sid      = nvl(l_rec.Sid,a.Sid),
            a.Default_TNS_Alias_GUID = nvl(l_rec.Default_TNS_Alias_GUID,
                                                    a.Default_TNS_Alias_GUID),
            a.Server_GUID = nvl(l_rec.Server_GUID,a.Server_GUID),
            a.Local_Listener_Alias = nvl(l_rec.Local_Listener_Alias,
                                                a.Local_Listener_Alias),
            a.Remote_Listener_Alias = nvl(l_rec.Remote_Listener_Alias,
                                                a.Remote_Listener_Alias),
            a.Configuration = nvl(l_rec.Configuration,a.Configuration),
            a.Description = nvl(l_rec.Description,a.Description),
            a.Interconnect_name = nvl(l_rec.Interconnect_name,
                                                a.Interconnect_name),
            a.last_update_date = SYSDATE,
            a.last_updated_by = 1
      where a.db_guid           = l_rec.db_guid
        and a.Instance_Guid     = l_rec.Instance_Guid;

  end if;

end;

/*==========================================================================*/

procedure  register_sid ( Sid                     varchar2,
                          sid_guid                raw
                        )
as
l_rec                   fnd_sids%rowtype;
l_insert                boolean := false;
begin

  l_rec.sid                     := Sid;
  l_rec.sid_guid                := sid_guid;

  if ( l_rec.sid_Guid is null )
  then
       l_insert := true;
       l_rec.sid_guid := sys_guid();
  else

    begin

      select a.sid_guid
        into l_rec.sid_guid
        from fnd_sids a
       where a.sid_guid = l_rec.sid_guid;

    exception
         when no_data_found then
              l_insert := true;
    end;

  end if;

  if ( l_insert )
  then

     insert into fnd_sids
                 (sid_guid,Sid,
                  last_updated_by,last_update_date,last_update_login,
                  creation_date,created_by
                 )
       values ( l_rec.sid_guid,l_rec.sid,
                1,sysdate,0,sysdate,1 );
  else

     update fnd_sids a
        set a.sid = nvl(l_rec.sid,a.sid),
            a.last_update_date = SYSDATE,
            a.last_updated_by = 1
      where a.sid_guid = l_rec.sid_guid;

  end if;

end;

/*==========================================================================*/

procedure register_service    ( Service_name         varchar2,
                                db_name              varchar2,
                                db_domain            varchar2,
                                Description          varchar2,
                                db_service_guid      raw        default null
                             )
as
l_rec                   fnd_database_services%rowtype;
l_insert                boolean := false;
l_db_name               fnd_databases.db_name%type;
l_db_domain             fnd_databases.db_domain%type;

begin

  l_rec.DB_Service_GUID := DB_Service_GUID;
  l_db_name             := db_name;
  l_db_domain           := db_domain;
  l_rec.Service_Name    := Service_Name;
  l_rec.Description     := Description;

  begin

    select a.db_guid
      into l_rec.db_guid
      from fnd_databases a
     where a.db_name  = l_db_name
       and a.db_domain= l_db_domain;

  end;

  if ( l_rec.db_service_guid is null )
  then
     begin

        select a.db_service_guid
          into l_rec.db_service_guid
          from fnd_database_services a
         where a.db_guid  = l_rec.db_guid
           and a.Service_Name = l_rec.Service_Name;

     exception
         when no_data_found then
             l_insert := true;
     end;
  end if;

  if ( l_insert )
  then

     insert into fnd_database_services
                 (DB_Service_GUID,db_guid,Service_Name,Description,
                  last_updated_by,last_update_date,last_update_login,
                  creation_date,created_by
                 )
       values ( sys_guid(),l_rec.db_guid,l_rec.Service_Name,
                l_rec.Description,
                1,sysdate,0,sysdate,1 );
  else

     update fnd_database_services a
        set a.Service_Name = nvl(l_rec.Service_Name,a.Service_Name),
            a.Description  = nvl(l_rec.Description,a.Description),
            a.last_update_date = SYSDATE,
            a.last_updated_by = 1
      where a.DB_Service_GUID = l_rec.DB_Service_GUID;

  end if;

end;

/*==========================================================================*/

procedure register_service_members ( db_name             varchar2,
                                     instance_name       varchar2,
				     instance_type	 varchar2,
                                     db_service_guid     raw default null,
                                     db_domain           varchar2
                                 )
as
l_rec                  fnd_db_service_members%rowtype;
l_insert               boolean := false;
l_db_name              fnd_databases.db_name%type;
l_instance_name        fnd_database_instances.instance_name%type;
l_db_domain            fnd_databases.db_domain%type;

begin

  l_rec.db_service_guid         := db_service_guid;
  l_rec.instance_type		:= instance_type;
  l_db_name                     := db_name;
  l_db_domain                   := db_domain;
  l_instance_name               := instance_name;

  select a.db_guid
    into l_rec.db_guid
    from fnd_databases a
   where a.db_name  = l_db_name
     and a.db_domain = l_db_domain;

  begin

    select instance_guid
      into l_rec.instance_guid
      from fnd_database_instances a
     where a.db_guid = l_rec.db_guid
       and a.instance_name = l_instance_name;

  end;

  if ( l_rec.db_service_guid is null )
  then
    begin

      select a.db_service_guid
        into l_rec.db_service_guid
        from fnd_db_service_members a
       where a.DB_GUID = l_rec.DB_GUID
         and a.Instance_Guid = l_rec.Instance_Guid;

    exception
        when no_data_found then
             l_insert := true;
    end;

    if ( l_insert )
    then
       l_rec.db_service_guid := sys_guid();
    end if;

  else

    begin

      select a.db_service_guid
        into l_rec.db_service_guid
        from fnd_db_service_members a
       where a.db_service_guid = l_rec.db_service_guid
         and a.Instance_Guid = l_rec.Instance_Guid;

    exception
        when no_data_found then
             l_insert := true;

    end;

  end if;

  if ( l_insert )
  then

     insert into fnd_db_service_members
                 (db_service_guid,DB_GUID,Instance_Guid,instance_type,
                  last_updated_by,last_update_date,last_update_login,
                  creation_date,created_by
                 )
       values ( l_rec.db_service_guid,l_rec.DB_GUID,l_rec.Instance_Guid,
                l_rec.instance_type,
                1,sysdate,0,sysdate,1 );
  else

     update fnd_db_service_members a
        set a.DB_GUID = nvl(l_rec.DB_GUID,a.DB_GUID),
            a.Instance_Guid = nvl(l_rec.Instance_Guid,a.Instance_Guid),
            a.instance_type = nvl(l_rec.instance_type,a.instance_type),
            a.last_update_date = SYSDATE,
            a.last_updated_by = 1
      where a.db_service_guid = l_rec.db_service_guid
        and a.Instance_Guid   = l_rec.Instance_Guid;

  end if;

end;

/*==========================================================================*/

procedure register_listener   (  Listener_Name              varchar2,
                                 Server_name                varchar2,
                                 tns_alias_name             varchar2,
                                 Listener_GUID              raw  default null,
                                 alias_set_name             varchar2
                              )
as
l_rec                   fnd_tns_listeners%rowtype;
l_insert                boolean := false;
l_server_name           fnd_app_servers.name%type;
l_tns_alias_name        fnd_tns_aliases.alias_name%type;
l_alias_set_guid        fnd_tns_alias_sets.tns_alias_set_guid%type;
l_alias_set_name        fnd_tns_alias_sets.tns_alias_set_name%type;

begin

  l_rec.Listener_GUID           := Listener_GUID;
  l_rec.Listener_Name           := Listener_Name;
  l_server_name                 := Server_name;
  l_tns_alias_name              := tns_alias_name;
  l_alias_set_name              := alias_set_name;

  select a.server_guid
    into l_rec.server_guid
    from fnd_app_servers a
   where a.name = l_server_name;

  select a.tns_alias_set_guid
    into l_alias_set_guid
    from fnd_tns_alias_sets a
   where a.tns_alias_set_name = l_alias_set_name;

  begin

    select a.tns_alias_guid
      into l_rec.tns_alias_guid
      from fnd_tns_aliases  a
     where a.alias_name     = l_tns_alias_name
       and a.alias_set_guid = l_alias_set_guid;

  exception
     when no_data_found then
          l_rec.tns_alias_guid := null;
  end;

  if ( l_rec.Listener_GUID is null )
  then
     begin

        select a.Listener_GUID
          into l_rec.Listener_GUID
          from fnd_tns_listeners a
         where a.Server_GUID   = l_rec.Server_GUID
           and a.Listener_Name = l_rec.Listener_Name;

     exception
         when no_data_found then
             l_insert := true;
     end;
  end if;

  if ( l_insert )
  then

     insert into fnd_tns_listeners
                 (Listener_GUID,Listener_Name,Server_GUID,tns_alias_guid,
                  last_updated_by,last_update_date,last_update_login,
                  creation_date,created_by
                 )
       values (
                sys_guid(),l_rec.Listener_Name,l_rec.Server_GUID,
                nvl(l_rec.tns_alias_guid,sys_guid()),
                1,sysdate,0,sysdate,1 );
  else

     update fnd_tns_listeners a
        set a.Listener_Name = nvl(l_rec.Listener_Name,a.Listener_Name),
            a.tns_alias_guid = nvl(l_rec.tns_alias_guid,a.tns_alias_guid),
            a.last_update_date = SYSDATE,
            a.last_updated_by = 1
      where a.Listener_GUID = l_rec.Listener_GUID;

  end if;

end;

/*==========================================================================*/

procedure register_tnsalias  (  Alias_Name              varchar2,
                                Alias_Type              varchar2,
                                Failover                varchar2,
                                Load_Balance            varchar2,
                                TNS_ALIAS_GUID          raw  default null,
                                alias_set_name          varchar2
                             )
as
l_rec                   fnd_tns_aliases%rowtype;
l_insert                boolean := false;
l_tns_alias_set_name    fnd_tns_alias_sets.tns_alias_set_name%type;

begin

  l_rec.TNS_ALIAS_GUID          := TNS_ALIAS_GUID;
  l_rec.Alias_Name              := Alias_Name;
  l_rec.Alias_Type              := Alias_Type;
  l_rec.Failover                := Failover;
  l_rec.Load_Balance            := Load_Balance;

  l_tns_alias_set_name          := alias_set_name;

  select a.tns_alias_set_GUID
    into l_rec.alias_set_guid
    from fnd_tns_alias_sets  a
   where a.tns_alias_set_name = l_tns_alias_set_name;

  if ( l_rec.TNS_ALIAS_GUID is null )
  then
     begin

       select a.TNS_ALIAS_GUID
         into l_rec.TNS_ALIAS_GUID
         from fnd_tns_aliases a
        where a.alias_set_guid = l_rec.alias_set_guid
        and   a.alias_name     = l_rec.alias_name;

     exception
        when no_data_found then
            l_rec.TNS_ALIAS_GUID := sys_guid();
            l_insert := true;
     end;
  else
     begin

       select a.TNS_ALIAS_GUID
         into l_rec.TNS_ALIAS_GUID
         from fnd_tns_aliases a
        where a.tns_alias_guid = l_rec.TNS_ALIAS_GUID;

     exception
           when no_data_found then
                l_insert := true;
     end;
  end if;

  if ( l_insert )
  then

     insert into fnd_tns_aliases
                 (TNS_ALIAS_GUID,Alias_Name,Alias_set_guid,Alias_Type,
                  Failover,Load_Balance,
                  last_updated_by,last_update_date,last_update_login,
                  creation_date,created_by
                 )
       values (
                l_rec.TNS_ALIAS_GUID,l_rec.Alias_Name,l_rec.alias_set_GUID,
                l_rec.Alias_Type,
                l_rec.Failover,
                l_rec.Load_Balance,
                1,sysdate,0,sysdate,1 );
  else

     update fnd_tns_aliases a
        set a.alias_name = nvl(l_rec.Alias_Name,a.alias_name),
            a.alias_set_guid = nvl(l_rec.alias_set_GUID,a.alias_set_guid),
            a.Alias_Type = nvl(l_rec.Alias_Type,a.Alias_Type),
            a.Failover   = nvl(l_rec.Failover,a.Failover),
            a.Load_Balance=nvl(l_rec.Load_Balance,a.Load_Balance),
            a.last_update_date = SYSDATE,
            a.last_updated_by = 1
      where a.TNS_ALIAS_GUID = l_rec.TNS_ALIAS_GUID;

  end if;

end;

/*==========================================================================*/

procedure register_tns_description
                                (  alias_set_name          varchar2,
                                   Alias_Name              varchar2,
                                   Sequence_Number         number default null,
                                   Failover                varchar2,
                                   Load_Balance            varchar2,
                                   Service_GUID            raw,
                                   Instance_Guid           raw,
                                   Service_Name            varchar2,
                                   Instance_Name           varchar2,
                                   TNS_ALIAS_DESCRIPTION_GUID
                                                           raw  default null
                                )
as
l_rec                   fnd_tns_alias_descriptions%rowtype;
l_insert                boolean := false;
l_tns_alias_set_name    fnd_tns_alias_sets.tns_alias_set_name%type;
l_tns_alias_name        fnd_tns_aliases.alias_name%type;

begin

  l_rec.TNS_ALIAS_DESCRIPTION_GUID := TNS_ALIAS_DESCRIPTION_GUID;
  l_rec.Sequence_Number         := nvl(Sequence_Number,0);
  l_rec.Failover                := Failover;
  l_rec.Load_Balance            := Load_Balance;
  l_rec.DB_Service_GUID         := Service_GUID;
  l_rec.DB_Instance_Guid        := Instance_Guid;
  l_rec.Service_Name		:= Service_Name;
  l_rec.Instance_Name		:= Instance_Name;
  l_rec.tns_alias_guid		:= null;

  l_tns_alias_name		:= Alias_Name;
  l_tns_alias_set_name          := alias_set_name;

  select b.tns_alias_GUID
    into l_rec.tns_alias_guid
    from fnd_tns_alias_sets  a, fnd_tns_aliases b
   where a.tns_alias_set_name = l_tns_alias_set_name
     and b.alias_set_guid     = a.tns_alias_set_guid
     and b.alias_name         = l_tns_alias_name;

  if ( l_rec.TNS_ALIAS_DESCRIPTION_GUID is null )
  then
     begin

       select a.TNS_ALIAS_DESCRIPTION_GUID
         into l_rec.TNS_ALIAS_DESCRIPTION_GUID
         from fnd_tns_alias_descriptions a
        where a.tns_alias_guid = l_rec.tns_alias_guid
          and a.Sequence_Number= l_rec.Sequence_Number;

     exception
        when no_data_found then
            l_rec.TNS_ALIAS_DESCRIPTION_GUID := sys_guid();
            l_insert := true;
     end;
  else

     begin

       select a.TNS_ALIAS_DESCRIPTION_GUID
         into l_rec.TNS_ALIAS_DESCRIPTION_GUID
         from fnd_tns_alias_descriptions a
        where a.TNS_ALIAS_DESCRIPTION_GUID = l_rec.TNS_ALIAS_DESCRIPTION_GUID;

     exception
           when no_data_found then
                l_insert := true;
     end;
  end if;

  if ( l_insert )
  then

     insert into fnd_tns_alias_descriptions
                 (TNS_ALIAS_GUID,TNS_ALIAS_DESCRIPTION_GUID,sequence_number,
                  Failover,Load_Balance,
                  DB_Service_GUID,DB_Instance_Guid,
                  Service_Name,Instance_Name,
                  last_updated_by,last_update_date,last_update_login,
                  creation_date,created_by
                 )
       values (
                l_rec.tns_alias_guid,l_rec.TNS_ALIAS_DESCRIPTION_GUID,
                l_rec.Sequence_Number,
                l_rec.Failover,l_rec.Load_Balance,
                l_rec.DB_Service_GUID,l_rec.DB_Instance_Guid,
                l_rec.Service_Name,l_rec.Instance_Name,
                1,sysdate,0,sysdate,1 );
  else

     update fnd_tns_alias_descriptions a
        set a.Failover   = nvl(l_rec.Failover,a.Failover),
            a.Load_Balance=nvl(l_rec.Load_Balance,a.Load_Balance),
            a.DB_Service_GUID=l_rec.DB_Service_GUID,
            a.DB_Instance_Guid = l_rec.DB_Instance_Guid,
            a.TNS_ALIAS_GUID= nvl(l_rec.tns_alias_guid,a.TNS_ALIAS_GUID),
            a.sequence_number=nvl(l_rec.Sequence_Number,a.sequence_number),
            a.Service_Name=l_rec.Service_Name,
            a.Instance_Name=l_rec.Instance_Name,
            a.last_update_date = SYSDATE,
            a.last_updated_by = 1
      where a.TNS_ALIAS_DESCRIPTION_GUID = l_rec.TNS_ALIAS_DESCRIPTION_GUID;

  end if;

end;

/*==========================================================================*/

procedure register_tns_address_list
                                (  TNS_ALIAS_DESCRIPTION_GUID
                                                           raw,
                                   Sequence_Number         number default null,
                                   Failover                varchar2,
                                   Load_Balance            varchar2,
                                   TNS_ALIAS_ADDRESS_LIST_GUID
                                                           raw  default null
                                )
as
l_rec                   fnd_tns_alias_address_lists%rowtype;
l_insert                boolean := false;

begin

  l_rec.TNS_ALIAS_DESCRIPTION_GUID := TNS_ALIAS_DESCRIPTION_GUID;
  l_rec.Sequence_Number         := nvl(Sequence_Number,0);
  l_rec.Failover                := Failover;
  l_rec.Load_Balance            := Load_Balance;
  l_rec.TNS_ALIAS_ADDRESS_LIST_GUID := TNS_ALIAS_ADDRESS_LIST_GUID;

  if ( l_rec.TNS_ALIAS_ADDRESS_LIST_GUID is null )
  then

    begin

      select a.TNS_ALIAS_ADDRESS_LIST_GUID,a.TNS_ALIAS_DESCRIPTION_GUID
        into l_rec.TNS_ALIAS_ADDRESS_LIST_GUID,l_rec.TNS_ALIAS_DESCRIPTION_GUID
        from fnd_tns_alias_address_lists a
       where a.TNS_ALIAS_DESCRIPTION_GUID  = l_rec.TNS_ALIAS_DESCRIPTION_GUID
         and a.sequence_number             = l_rec.Sequence_Number;

    exception
       when no_data_found then
            l_rec.TNS_ALIAS_ADDRESS_LIST_GUID := sys_guid();
            l_insert := true;
    end;

  else

    begin

      select a.TNS_ALIAS_ADDRESS_LIST_GUID,a.TNS_ALIAS_DESCRIPTION_GUID
        into l_rec.TNS_ALIAS_ADDRESS_LIST_GUID,l_rec.TNS_ALIAS_DESCRIPTION_GUID
        from fnd_tns_alias_address_lists a
       where a.TNS_ALIAS_ADDRESS_LIST_GUID = l_rec.TNS_ALIAS_ADDRESS_LIST_GUID;

     exception
           when no_data_found then
                l_insert := true;
     end;

  end if;

  if ( l_insert )
  then

     insert into fnd_tns_alias_address_lists
                 (TNS_ALIAS_ADDRESS_LIST_GUID,TNS_ALIAS_DESCRIPTION_GUID,
                  Sequence_Number,Failover,Load_Balance,
                  last_updated_by,last_update_date,last_update_login,
                  creation_date,created_by
                 )
       values (
                l_rec.TNS_ALIAS_ADDRESS_LIST_GUID,
                l_rec.TNS_ALIAS_DESCRIPTION_GUID,
                l_rec.Sequence_Number,
                l_rec.Failover,
                l_rec.Load_Balance,
                1,sysdate,0,sysdate,1 );
  else

     update fnd_tns_alias_address_lists a
        set a.Failover   = nvl(l_rec.Failover,a.Failover),
            a.Load_Balance=nvl(l_rec.Load_Balance,a.Load_Balance),
            a.sequence_number=nvl(l_rec.Sequence_Number,a.sequence_number),
            a.last_update_date = SYSDATE,
            a.last_updated_by = 1
      where a.TNS_ALIAS_ADDRESS_LIST_GUID = l_rec.TNS_ALIAS_ADDRESS_LIST_GUID;

  end if;

end;

/*==========================================================================*/

procedure register_tnsalias_address   ( TNS_ALIAS_ADDRESS_LIST_GUID raw,
                                        Listener_port_GUID        raw
                                      )
as
l_rec                   fnd_tns_alias_addresses%rowtype;
l_insert                boolean := false;

begin

  l_rec.TNS_ALIAS_ADDRESS_LIST_GUID := TNS_ALIAS_ADDRESS_LIST_GUID;
  l_rec.Listener_port_GUID      := Listener_port_GUID;

  begin

    select a.TNS_ALIAS_ADDRESS_LIST_GUID,a.Listener_port_GUID
      into l_rec.TNS_ALIAS_ADDRESS_LIST_GUID,l_rec.Listener_port_GUID
      from fnd_tns_alias_addresses a
     where a.TNS_ALIAS_ADDRESS_LIST_GUID = l_rec.TNS_ALIAS_ADDRESS_LIST_GUID
       and a.Listener_port_GUID = l_rec.Listener_port_GUID;

  exception
     when no_data_found then
          l_insert := true;
  end;

  if ( l_insert )
  then

     insert into fnd_tns_alias_addresses
                 (TNS_ALIAS_ADDRESS_LIST_GUID,Listener_port_GUID,
                  last_updated_by,last_update_date,last_update_login,
                  creation_date,created_by
                 )
       values (
                l_rec.TNS_ALIAS_ADDRESS_LIST_GUID,l_rec.Listener_port_GUID,
                1,sysdate,0,sysdate,1 );
  else

     update fnd_tns_alias_addresses a
        set a.Listener_port_GUID=nvl(l_rec.Listener_port_GUID,
                                              a.Listener_port_GUID),
            a.last_update_date = SYSDATE,
            a.last_updated_by = 1
      where a.TNS_ALIAS_ADDRESS_LIST_GUID = l_rec.TNS_ALIAS_ADDRESS_LIST_GUID
        and a.Listener_port_GUID = l_rec.Listener_port_GUID;

  end if;

end;

/*==========================================================================*/

procedure register_node( name          varchar2,  /* Max 30 bytes */
                         platform_id   number,    /* Platform ID from BugDB */
                         forms_tier    varchar2,  /* 'Y'/'N' */
                         cp_tier       varchar2,  /* 'Y'/'N' */
                         web_tier      varchar2,  /* 'Y'/'N' */
                         admin_tier    varchar2,  /* 'Y'/'N' */
                         p_server_id   varchar2,  /* ID of server */
                         p_address     varchar2,  /* IP address of server */
                         p_description varchar2,  /* description of server*/
                         p_host_name   varchar2,
                         p_domain      varchar2,
                         db_tier       varchar2,   /* 'Y'/'N' */
                         p_virtual_ip  varchar2 default null
                       )
as

register_node_complete boolean := false;

l_sql_str       varchar2(2000);
l_sql_str_dom   varchar2(2000);
l_sql_str_db_tier
                varchar2(2000);
l_sql_str_db_tier_virtualip
                varchar2(2000);
kount           number;

begin


  l_sql_str := 'begin fnd_concurrent.register_node ' ||
                 '(:v1, :v2, :v3, :v4, :v5, :v6, :v7, :v8, :v9); end;';
  l_sql_str_dom := 'begin fnd_concurrent.register_node' ||
            '(:v1, :v2, :v3, :v4, :v5, :v6, :v7, :v8, :v9, :v10, :v11); end;';
  l_sql_str_db_tier := 'begin fnd_concurrent.register_node' ||
            '(:v1, :v2, :v3, :v4, :v5, :v6, :v7, :v8, :v9, :v10, :v11, :v12); end;';
  l_sql_str_db_tier_virtualip := 'begin fnd_concurrent.register_node' ||
            '(:v1, :v2, :v3, :v4, :v5, :v6, :v7, :v8, :v9, :v10, :v11, :v12, :v13); end;';

-- Try with db_tier_virtualip

  begin

    execute immediate l_sql_str_db_tier_virtualip using
                                          name,
                                          platform_id   ,
                                          forms_tier    ,
                                          cp_tier       ,
                                          web_tier      ,
                                          admin_tier    ,
                                          p_server_id   ,
                                          p_address     ,
                                          p_description ,
                                          p_host_name   ,
                                          p_domain      ,
                                          db_tier       ,
                                          p_virtual_ip  ;

    register_node_complete := true;

  exception
      when others then null;
  end;

  if ( register_node_complete )
  then
     return;
  end if;

-- Try with db_tier

  begin

    execute immediate l_sql_str_db_tier using
                                          name,
                                          platform_id   ,
                                          forms_tier    ,
                                          cp_tier       ,
                                          web_tier      ,
                                          admin_tier    ,
                                          p_server_id   ,
                                          p_address     ,
                                          p_description ,
                                          p_host_name   ,
                                          p_domain      ,
                                          db_tier       ;

    register_node_complete := true;

  exception
      when others then null;
  end;

  if ( register_node_complete )
  then
     return;
  end if;

-- Try with host/domain.

  begin

    execute immediate l_sql_str_dom using name,
                                          platform_id   ,
                                          forms_tier    ,
                                          cp_tier       ,
                                          web_tier      ,
                                          admin_tier    ,
                                          p_server_id   ,
                                          p_address     ,
                                          p_description ,
                                          p_host_name   ,
                                          p_domain      ;

    register_node_complete := true;

  exception
      when others then null;
  end;

  if ( register_node_complete )
  then
     return;
  end if;

-- Try without host/domain

  begin

    execute immediate l_sql_str     using name,
                                          platform_id   ,
                                          forms_tier    ,
                                          cp_tier       ,
                                          web_tier      ,
                                          admin_tier    ,
                                          p_server_id   ,
                                          p_address     ,
                                          p_description ;

    register_node_complete := true;

  exception
      when others then null;
  end;

  if ( register_node_complete )
  then
     return;
  end if;

-- Register node doesn't even exist. Do the DML here.

-- Copied from AFCPUTLB.pls - 115.56

  select count(*)
    into kount
    from fnd_nodes
   where upper(node_name) = upper(name);

  if (kount = 0) then
      execute immediate
              'insert into fnd_nodes ' ||
              '      (node_id, node_name,' ||
              '       support_forms, support_cp, support_web, support_admin,' ||              '       platform_code, created_by, creation_date,' ||
              '       last_updated_by, last_update_date, last_update_login,' ||
              '       node_mode, server_id, server_address, description)' ||
              ' select ' ||
              '       fnd_nodes_s.nextval, :v1,' ||
              '       :v2, :v3, :v4, :v5, :v6, 1, SYSDATE, 1, SYSDATE, 0,' ||
              '       ''O'', :v7, :v8, :v9  ' ||
              ' from dual '
              using name, forms_tier, cp_tier, web_tier, admin_tier,
                    platform_id, p_server_id, p_address, p_description;
  else
      update fnd_nodes
         set description   = p_description,
             support_forms = decode(forms_tier, 'Y', 'Y', support_forms),
             support_cp    = decode(cp_tier,    'Y', 'Y', support_cp),
             support_web   = decode(web_tier,   'Y', 'Y', support_web),
             support_admin = decode(admin_tier, 'Y', 'Y', support_admin),
             platform_code = platform_id,
             last_update_date = SYSDATE, last_updated_by = 1
       where upper(node_name) = upper(name);

       if (p_server_id is not null) then
           execute immediate 'update fnd_nodes ' ||
                             '   set server_id = :v1' ||
                             ' where upper(node_name) = upper(:v2) '
                       using p_server_id, name;
       end if;

       if (p_address is not null) then
           execute immediate 'update fnd_nodes ' ||
                             '   set server_address = :v1' ||
                             ' where upper(node_name) = upper(:v2)'
                       using p_address,name;
       end if;
  end if;

  register_node_complete := true;

end;

/*==========================================================================*/

procedure register_listener_ports  (Listener_Name              varchar2,
                                    Port                       number,
                                    server_guid                raw,
                                    Listener_Port_Guid         raw default null)
as
l_rec                   fnd_tns_listener_ports%rowtype;
l_insert                boolean := false;
l_listener_name         fnd_tns_listeners.listener_name%type;
l_server_guid           fnd_tns_listeners.server_guid%type;
begin

  l_Listener_Name               := Listener_Name;
  l_rec.Listener_Port_Guid      := Listener_Port_Guid;
  l_rec.Port                    := Port;
  l_server_guid                 := server_guid;

  select a.Listener_GUID
    into l_rec.Listener_GUID
    from fnd_tns_listeners a
   where a.Server_GUID = l_server_guid
     and a.Listener_Name = l_Listener_Name;

  if ( l_rec.Listener_Port_Guid is null )
  then

    begin

      select a.listener_port_guid
        into l_rec.listener_port_guid
        from fnd_tns_listener_ports a
       where a.listener_guid = l_rec.listener_GUID
         and a.port          = l_rec.Port;

    exception
         when no_data_found then
              l_insert := true;
    end;

  end if;

  if ( l_insert )
  then
    insert into fnd_tns_listener_ports
                    (Listener_Port_GUID,Listener_GUID,Protocol,Port,
                     Created_By,Creation_Date,
                     Last_Updated_By,Last_Update_Date,Last_Update_Login)
       values (sys_guid(),l_rec.Listener_guid,fnd_app_system.c_protocol_tcp,
               l_rec.Port,1,sysdate,1,sysdate,0 );
  else

     update fnd_tns_listener_ports  a
        set a.port = nvl(l_rec.Port,a.port),
            a.last_update_date = SYSDATE,
            a.last_updated_by = 1
      where a.Listener_port_GUID = l_rec.Listener_port_GUID;

  end if;

end;

/*=========================================================================*/

procedure register_tnsalias_sets  (  Alias_set_Name     varchar2,
				     Alias_set_type     varchar2 )
as
l_rec                   fnd_tns_alias_sets%rowtype;
l_insert                boolean := false;

begin

  l_rec.tns_Alias_set_Name          := Alias_set_Name;
  l_rec.tns_alias_set_type	    := alias_set_type;

  begin

    select tns_alias_set_guid
      into l_rec.tns_alias_set_guid
      from fnd_tns_alias_sets  a
     where a.tns_alias_set_name = l_rec.tns_alias_set_name;

  exception
      when no_data_found then
           l_insert := true;
  end;

  if ( l_insert )
  then

     insert into fnd_tns_alias_sets
               (TNS_ALIAS_SET_GUID,tns_Alias_set_name,tns_Alias_set_type,
                  last_updated_by,last_update_date,last_update_login,
                  creation_date,created_by
                 )
       values (
                sys_guid(),l_rec.tns_Alias_set_Name,l_rec.tns_alias_set_type,
                1,sysdate,0,sysdate,1 );
  else

     update fnd_tns_alias_sets a
        set a.tns_alias_set_name = nvl(l_rec.tns_Alias_set_Name,
                                               a.tns_alias_set_name),
            a.tns_alias_set_type = nvl(l_rec.tns_alias_set_type,
                                               a.tns_alias_set_type),
            a.last_update_date = SYSDATE,
            a.last_updated_by = 1
      where a.TNS_ALIAS_set_GUID = l_rec.TNS_ALIAS_set_GUID;

  end if;

end;

/*===========================================================================*/

procedure register_aliasset_usage   ( TNS_ALIAS_set_GUID raw,
                                      server_guid        raw
                                    )
as
l_rec                   fnd_tns_alias_set_usage%rowtype;
l_insert                boolean := false;

begin

  l_rec.TNS_ALIAS_set_GUID      := TNS_ALIAS_set_GUID;
  l_rec.server_guid             := server_guid;

  begin

    select a.TNS_ALIAS_set_GUID,a.server_guid
      into l_rec.TNS_ALIAS_set_GUID,l_rec.server_guid
      from fnd_tns_alias_set_usage a
     where a.TNS_ALIAS_set_GUID = l_rec.TNS_ALIAS_set_GUID
       and a.server_guid = l_rec.server_guid;

  exception
     when no_data_found then
          l_insert := true;
  end;

  if ( l_insert )
  then

     insert into fnd_tns_alias_set_usage
                 (TNS_ALIAS_set_guid,server_guid,
                  last_updated_by,last_update_date,last_update_login,
                  creation_date,created_by
                 )
       values (
                l_rec.TNS_ALIAS_set_GUID,l_rec.server_guid,
                1,sysdate,0,sysdate,1 );
  else

     update fnd_tns_alias_set_usage a
        set a.server_guid=nvl(l_rec.server_guid,a.server_guid),
            a.last_update_date = SYSDATE,
            a.last_updated_by = 1
      where a.TNS_ALIAS_set_GUID = l_rec.TNS_ALIAS_set_GUID
        and a.server_guid = l_rec.server_guid;

  end if;

end;

end FND_APP_SYSTEM;

/
