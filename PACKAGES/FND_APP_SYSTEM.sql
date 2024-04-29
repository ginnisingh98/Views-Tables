--------------------------------------------------------
--  DDL for Package FND_APP_SYSTEM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_APP_SYSTEM" AUTHID CURRENT_USER as
/* $Header: AFCPSYSS.pls 120.2 2005/12/19 09:49:31 ssuraj noship $ */

C_DB_SERVER_TYPE        constant        varchar2(20) := 'DB';
C_APP_SERVER_TYPE       constant        varchar2(20) := 'APPS';
C_APP_DB_ASSIGNMENT     constant        varchar2(20) := 'APPS';

C_FNDFS_TNS_ALIAS_TYPE  constant        varchar2(20) := 'FNDFS';
C_FNDSM_TNS_ALIAS_TYPE  constant        varchar2(20) := 'FNDSM';
C_DB_BALANCE_TNS_ALIAS_TYPE
                        constant        varchar2(20) := 'DB-LOAD-BAL';
C_DB_INST_TNS_ALIAS_TYPE
                        constant        varchar2(20) := 'DB-INST';
C_LOCAL_INST_TNS_ALIAS_TYPE
                        constant        varchar2(20) := 'LOCAL';
C_REMOTE_INST_TNS_ALIAS_TYPE
                        constant        varchar2(20) := 'REMOTE';

C_APPS_LISTENER_ID      constant        varchar2(20) := 'APPS';

C_LOCAL_ALIAS_ID        constant        varchar2(20) := 'LOCAL';
C_REMOTE_ALIAS_ID       constant        varchar2(20) := 'REMOTE';
C_BALANCE_ALIAS_ID      constant        varchar2(20) := 'BALANCE';
C_806_BALANCE_ALIAS_ID  constant        varchar2(20) := '806_BALANCE';
C_FAILOVER_ALIAS_ID     constant        varchar2(20) := 'FO';
C_PROTOCOL_TCP          constant        varchar2(20) := 'TCP';
C_ALIAS_SET_NAME_PUB    constant        varchar2(20) := 'PUBLIC';
C_ALIAS_SET_NAME_INT    constant        varchar2(20) := 'INTERNAL';

C_PREFERRED_INSTANCE    constant        varchar2(20) := 'P';
C_AVAILABLE_INSTANCE    constant        varchar2(20) := 'A';

   procedure register_system (          name            varchar2,
                                        owner           varchar2,
                                        CSI_NUMBER      varchar2,
                                        System_Guid     raw        default null
                          );

   procedure register_node( name          varchar2,
                            platform_id   number,
                            forms_tier    varchar2,
                            cp_tier       varchar2,
                            web_tier      varchar2,
                            admin_tier    varchar2,
                            p_server_id   varchar2,
                            p_address     varchar2,
                            p_description varchar2,
                            p_host_name   varchar2,
                            p_domain      varchar2,
                            db_tier       varchar2,
                            p_virtual_ip  varchar2 default null);

   procedure register_oraclehome ( name                  varchar2,
                                   Node_Id               varchar2,
                                   Path                  varchar2,
                                   Version               varchar2,
                                   Description           varchar2,
                                   File_System_GUID      raw,
                                   Oracle_Home_Id        raw default null );

   procedure register_appltop    ( name                  varchar2,
                                   Node_Id               varchar2,
                                   Path                  varchar2,
                                   Shared                varchar2,
                                   File_System_GUID      raw,
                                   Appl_Top_Guid         raw default null );

  procedure register_server     ( Name                   varchar2,
                                  Node_Id                varchar2,
                                  Internal               varchar2,
                                  Appl_Top_Guid          raw,
                                  Server_type            varchar2,
                                  Pri_Oracle_Home        raw,
                                  Aux_Oracle_Home        raw,
                                  Server_GUID            raw default null );

  procedure register_servermap  ( Server_GUID            raw,
                                  System_Guid            raw );

  procedure register_database   ( db_name               varchar2,
                                  db_domain             varchar2,
                                  Default_TNS_Alias_Guid raw,
                                  Is_Rac_db		varchar2,
                                  Version               varchar2,
                                  db_guid               raw default null
                                );

  procedure register_database_asg( db_name               varchar2,
                                   assignment            varchar2,
                                   db_domain             varchar2
                                 );

  procedure register_instance   ( db_name                 varchar2,
                                  Instance_Name           varchar2,
                                  Instance_Number         Number,
                                  Sid_GUID                raw,
			          Sid			  varchar2,
                                  Default_TNS_Alias_GUID  raw,
                                  Server_GUID             raw,
                                  Local_Listener_Alias    raw,
                                  Remote_Listener_Alias   raw,
                                  Configuration           varchar2,
                                  Description             varchar2,
                                  Interconnect_name       varchar2,
                                  Instance_Guid           raw    default null,
                                  db_domain               varchar2
                                ) ;

  procedure register_sid         ( Sid                       varchar2 ,
                                   sid_guid                  raw
                                 ) ;

  procedure register_service     ( Service_name          varchar2,
                                   db_name               varchar2,
                                   db_domain             varchar2,
                                   Description           varchar2,
                                   db_service_guid       raw        default null
                                 );

  procedure register_service_members ( db_name           varchar2,
                                       Instance_name     varchar2,
                                       Instance_type     varchar2,
                                       db_service_guid   raw default null,
                                       db_domain         varchar2
                                     );

  procedure register_listener   (  Listener_Name           varchar2,
                                   Server_name             varchar2,
                                   tns_alias_name          varchar2,
                                   Listener_GUID           raw  default null,
                                   alias_set_name          varchar2
                                );

  procedure register_tnsalias   (  Alias_Name              varchar2,
                                   Alias_Type              varchar2,
                                   Failover                varchar2,
                                   Load_Balance            varchar2,
                                   TNS_ALIAS_GUID          raw  default null,
                                   alias_set_name          varchar2
                                );

  procedure register_tns_description
                                (  alias_set_name          varchar2,
                                   Alias_Name              varchar2,
                                   Sequence_Number	   number default null,
                                   Failover                varchar2,
                                   Load_Balance            varchar2,
                                   Service_GUID            raw,
                                   Instance_Guid           raw,
                                   Service_Name            varchar2,
                                   Instance_Name           varchar2,
                                   TNS_ALIAS_DESCRIPTION_GUID
                                                           raw  default null
                                );

  procedure register_tns_address_list
			        (  TNS_ALIAS_DESCRIPTION_GUID
                                                           raw,
                                   Sequence_Number         number default null,
                                   Failover                varchar2,
                                   Load_Balance            varchar2,
                                   TNS_ALIAS_ADDRESS_LIST_GUID
                                                           raw  default null
                                );

  procedure register_tnsalias_address ( TNS_ALIAS_ADDRESS_LIST_GUID raw,
                                        Listener_port_GUID     raw
                                      );

  procedure register_listener_ports  (Listener_Name             varchar2,
                                      Port                      number,
                                      server_guid               raw,
				      Listener_Port_Guid        raw default null
                                     );

  procedure register_tnsalias_sets  (  Alias_set_Name           varchar2,
				       Alias_set_type		varchar2 );

  procedure register_aliasset_usage   ( TNS_ALIAS_set_GUID    raw,
                                        server_guid           raw
                                      ) ;


end FND_APP_SYSTEM ;

 

/
