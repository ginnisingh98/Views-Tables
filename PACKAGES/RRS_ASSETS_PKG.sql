--------------------------------------------------------
--  DDL for Package RRS_ASSETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RRS_ASSETS_PKG" AUTHID CURRENT_USER AS
/* $Header: RRSASSTS.pls 120.5 2008/01/26 00:02:16 sunarang noship $ */

PROCEDURE CREATE_ASSET_INSTANCES
     ( errbuf				OUT NOCOPY VARCHAR2
      ,retcode				OUT NOCOPY VARCHAR2
	 ,p_source_instance_id	IN  NUMBER
      ,p_additional_instances	IN  VARCHAR2
      ,p_session_id			IN  VARCHAR2

     )  ;

PROCEDURE CREATE_ASSET_INSTANCES_WRP
     ( p_source_instance_id	IN  NUMBER
      ,p_additional_instances	IN  VARCHAR2
      ,p_session_id		IN  VARCHAR2
      ,x_request_id		OUT NOCOPY NUMBER
      ,x_return_status		OUT NOCOPY VARCHAR2
      ,x_msg_count		OUT NOCOPY NUMBER
      ,x_msg_data		OUT NOCOPY VARCHAR2
     ) ;

PROCEDURE CREATE_ASSET_INSTANCES_CONC
     ( p_source_instance_id	IN  NUMBER
      ,p_additional_instances	IN  VARCHAR2
      ,p_session_id		IN  VARCHAR2
      ,x_request_id		OUT NOCOPY NUMBER
      ,x_return_status		OUT NOCOPY VARCHAR2
      ,x_msg_count		OUT NOCOPY NUMBER
      ,x_msg_data		OUT NOCOPY VARCHAR2
     ) ;

PROCEDURE POPULATE_RRS_SITES_INTF
      (  p_session_id		IN VARCHAR2
	,p_site_ids		IN RRS_NUMBER_TBL_TYPE DEFAULT NULL
	,p_created_by           IN NUMBER
	,p_creation_date        IN DATE
	,p_last_updated_by      IN NUMBER
	,p_last_update_date     IN DATE
	,p_last_update_login    IN NUMBER
	);

END RRS_ASSETS_PKG;


/
