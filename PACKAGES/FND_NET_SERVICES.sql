--------------------------------------------------------
--  DDL for Package FND_NET_SERVICES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_NET_SERVICES" AUTHID CURRENT_USER as
/* $Header: AFCPNETS.pls 120.4 2006/05/31 09:46:38 subhroy noship $ */

   procedure register_dbnode(SystemName			varchar2,
                             ServerName                 varchar2,
		             SystemOwner		varchar2,
			     SystemCSINumber		varchar2,
                             DatabaseName		varchar2,
                             InstanceName		varchar2,
                             InstanceNumber		varchar2,
                             ListenerPort		varchar2,
                             ClusterDatabase		varchar2,
                             ServiceName		varchar2,
                             RemoteListenerName		varchar2,
                             LocalListenerName		varchar2,
                             HostName			varchar2,
                             Domain                     varchar2,
			     OracleHomePath             varchar2,
			     OracleHomeVersion		varchar2,
			     OracleHomeName		varchar2,
			     InterconnectName		varchar2,
			     InstanceSid		varchar2,
                             platform	                varchar2,
                             alt_service_instance_1	varchar2 default null,
                             alt_service_instance_2	varchar2 default null,
                             alt_service_instance_3	varchar2 default null,
                             alt_service_instance_4	varchar2 default null,
                             alt_service_instance_5	varchar2 default null,
                             alt_service_instance_6	varchar2 default null,
                             alt_service_instance_7	varchar2 default null,
                             alt_service_instance_8	varchar2 default null,
                             VirtualHostName            varchar2 default null
		           );

   procedure register_appnode(SystemName	 in     varchar2,
                              ServerName         in     varchar2,
                              SystemOwner        in     varchar2,
                              SystemCSINumber    in     varchar2,
                              HostName           in     varchar2,
                              Domain             in     varchar2,
                              RPCPort            in     varchar2,
			      PriOracleHomePath  in     varchar2,
			      PriOracleHomeVersion in   varchar2,
			      PriOracleHomeName	 in     varchar2,
			      AuxOracleHomePath  in     varchar2,
			      AuxOracleHomeVersion in   varchar2,
			      AuxOracleHomeName	 in     varchar2,
                              ApplTopPath        in     varchar2,
			      ApplTopName	 in	varchar2,
                              SharedApplTop      in     varchar2,
                              ToolsInstanceAlias in out nocopy varchar2,
                              WebInstanceAlias   in out nocopy varchar2,
                              SidDefaultAlias    in out nocopy varchar2,
                              JDBCSid            in out nocopy varchar2,
			      isFormsNode	 in     varchar2 default 'Y',
                              isCPNode		 in     varchar2 default 'Y',
                              isWebNode		 in	varchar2 default 'Y',
                              isAdminNode	 in	varchar2 default 'Y',
                              platform	         in     varchar2,
                              forceMissingAliases
					         in     varchar2 default 'N'
                             );

  procedure remove_dbNode  ( SystemName         in      varchar2,
                             ServerName         in      varchar2,
                             DatabaseName       in      varchar2,
                             InstanceName       in      varchar2,
			     Domain		in      varchar2
			   );

  procedure remove_AppNode ( SystemName         in     varchar2,
                             ServerName         in     varchar2
			   );

  procedure remove_Server  ( SystemName         in     varchar2,
			     ServerName         in     varchar2
			   );

  procedure remove_System  ( SystemName         in     varchar2 );

  procedure show	   ( SystemName         in     varchar2);

  procedure show_tnsalias  ( p_info             in     varchar2,
                             p_tns_alias_guid   in     raw );

end FND_NET_SERVICES;

 

/
