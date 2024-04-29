--------------------------------------------------------
--  DDL for Package CZ_ORAAPPS_INTEGRATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_ORAAPPS_INTEGRATE" AUTHID CURRENT_USER AS
/*	$Header: czcaints.pls 120.1 2005/06/29 13:29:02 asiaston ship $		*/

mERRBUF         VARCHAR2(4000);
mRETCODE        NUMBER;

LINK_WORKS      CONSTANT CHAR(1):='0';
LINK_IS_DOWN    CONSTANT CHAR(1):='1';

FUNCTION ITEM_SURROGATE_KEY(nITEM_ID IN VARCHAR2,nORG_ID IN VARCHAR2)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(ITEM_SURROGATE_KEY,WNDS);

FUNCTION isLinkAlive(sDb_Link IN VARCHAR2) RETURN VARCHAR2;

FUNCTION COMPONENT_SURROGATE_KEY(sCOMPONENT_SEQUENCE_ID IN VARCHAR2,
                                 sEXPLOSION_TYPE        IN VARCHAR2,
                                 sORG_ID                IN VARCHAR2,
                                 sTOP_ITEM_ID           IN VARCHAR2)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(COMPONENT_SURROGATE_KEY,WNDS);

FUNCTION PROJECT_SURROGATE_KEY(sEXPLOSION_TYPE IN VARCHAR2,
                               sORG_ID IN VARCHAR2,
                               sTOP_ITEM_ID IN VARCHAR2)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(PROJECT_SURROGATE_KEY,WNDS);

FUNCTION ENDUSER_SURROGATE_KEY(sORG_ID IN VARCHAR2,sSalesrep_ID IN VARCHAR2)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(ENDUSER_SURROGATE_KEY,WNDS);

--------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
---------- create extraction views

FUNCTION create_exv_views(slocal_name   IN  VARCHAR2)
RETURN VARCHAR2;

--------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
---------- recreate extraction views

PROCEDURE recreate_exv_views
(p_link_status OUT NOCOPY VARCHAR2,
 p_db_link     OUT NOCOPY VARCHAR2,
 p_do_compile  IN  VARCHAR2);

--------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
---------- recreate extraction views concurrent program

PROCEDURE recreate_exv_views_cp(errbuf  IN OUT NOCOPY VARCHAR2,
		                    retcode IN OUT NOCOPY INTEGER);

--------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
---------- drop extraction  views

FUNCTION drop_exv_views
RETURN VARCHAR2;

--------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-------populate cz_servers

PROCEDURE populate_cz_server_cp( Errbuf IN OUT NOCOPY VARCHAR2,
		                  Retcode IN OUT NOCOPY PLS_INTEGER,
					LOCAL_NAME           IN  VARCHAR2
					  ,HOSTNAME          IN  VARCHAR2
					  ,DB_LISTENER_PORT  IN  NUMBER
					  ,INSTANCE_NAME     IN  VARCHAR2
					  ,FNDNAM            IN  VARCHAR2
					  ,GLOBAL_IDENTITY   IN  VARCHAR2
					  ,NOTES             IN  VARCHAR2
					  ,FNDNAM_LINK_NAME  IN  VARCHAR2
					  ,IMPORT_ENABLED    IN  VARCHAR2
					);

-------alter cz_servers
PROCEDURE alter_cz_server_cp( Errbuf IN OUT NOCOPY VARCHAR2,
		                  Retcode IN OUT NOCOPY PLS_INTEGER,
					LOCAL_NAME           IN  VARCHAR2
					  ,HOSTNAME          IN  VARCHAR2
					  ,DB_LISTENER_PORT  IN  NUMBER
					  ,INSTANCE_NAME     IN  VARCHAR2
					  ,FNDNAM            IN  VARCHAR2
					  ,GLOBAL_IDENTITY   IN  VARCHAR2
					  ,NOTES             IN  VARCHAR2
					  ,FNDNAM_LINK_NAME  IN  VARCHAR2
					  ,IMPORT_ENABLED    IN  VARCHAR2
					);

------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
FUNCTION create_remote_hgrid_view(p_server_id IN NUMBER, p_fndnam_link_name IN VARCHAR2)
  RETURN VARCHAR2;
-------create database link
PROCEDURE create_link_cp( 	Errbuf 	IN OUT NOCOPY VARCHAR2,
		          	Retcode 	IN OUT NOCOPY PLS_INTEGER,
				LOCAL_NAME	IN  VARCHAR2,
				PASSWORD	IN  VARCHAR2);

------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

------- proc called by concurrent manager to show cz_servers
PROCEDURE show_cz_servers_cp(errbuf OUT NOCOPY VARCHAR2,
                     	  retcode OUT NOCOPY NUMBER);

------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

PROCEDURE ITEM_EXTERNAL_PK(nSURR_KEY IN VARCHAR2,xITEM_ID OUT NOCOPY VARCHAR2,
				xORG_ID OUT NOCOPY VARCHAR2);

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE register_spx_process
(p_name          IN VARCHAR2,
p_short_name     IN VARCHAR2,
p_application    IN VARCHAR2,
p_description    IN VARCHAR2,
p_procedure_name IN VARCHAR2,
p_request_group  IN VARCHAR2,
cz_schema        IN VARCHAR2 default NULL);

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
PROCEDURE delete_spx_process
(p_short_name     IN VARCHAR2,
p_application    IN VARCHAR2);

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
PROCEDURE register_export_process
(application_name  IN VARCHAR2,
 Request_Group     IN VARCHAR2,
 cz_schema         IN VARCHAR2 default NULL);

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE register_import_process
(application_name  IN VARCHAR2,
 Request_Group     IN VARCHAR2 default NULL,
 cz_schema         IN VARCHAR2 default NULL);

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE register_maint_server_process
(application_name  IN VARCHAR2,
 Request_Group     IN VARCHAR2 default NULL,
 cz_schema         IN VARCHAR2 default NULL);

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE delete_export_process(application_name IN VARCHAR2);

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE delete_import_process(application_name IN VARCHAR2);

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE set_request_schedule
(repeat_time      IN VARCHAR2 default NULL,
 repeat_interval  IN NUMBER,
 repeat_unit      IN VARCHAR2,
 repeat_type      IN VARCHAR2,
 repeat_end_time  IN VARCHAR2 default NULL);

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE submit_export_request
(v_user_id       IN NUMBER,
 v_resp_id       IN NUMBER,
 vision_org_id   IN NUMBER,
 v_appl_id       IN NUMBER
 );


/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE SettingReport
(section_name IN VARCHAR2,
 setting_id   IN VARCHAR2,
 cz_schema    IN VARCHAR2 default NULL);

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE LOG_REPORT
(inStr IN VARCHAR2);

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

------------------------------------------------------------------------------
PROCEDURE GetSetting(errbuf OUT NOCOPY VARCHAR2,
                     retcode OUT NOCOPY NUMBER,
                     LIKE_SectionName IN VARCHAR2,
                     LIKE_SettingID   IN VARCHAR2);
------------------------------------------------------------------------------
PROCEDURE AssignSetting(errbuf OUT NOCOPY VARCHAR2,
                        retcode OUT NOCOPY NUMBER,
                        sSECTION_NAME IN VARCHAR2,
                        sSETTING_ID   IN VARCHAR2,
                        sVALUE        IN VARCHAR2,
                        sTYPE         IN VARCHAR2,
                        sDESCRIPTION  IN VARCHAR2 DEFAULT NULL);
------------------------------------------------------------------------------
PROCEDURE GetTableImport(errbuf OUT NOCOPY VARCHAR2,
                         retcode OUT NOCOPY NUMBER,
                         LIKE_DstTableName IN VARCHAR2,
                         LIKE_PhaseName    IN VARCHAR2);
------------------------------------------------------------------------------
PROCEDURE SetTableImport(errbuf OUT NOCOPY VARCHAR2,
                         retcode OUT NOCOPY NUMBER,
                         DstTableName   IN VARCHAR2,
                         LIKE_PhaseName IN VARCHAR2,
                         EnableImport   IN VARCHAR2);
------------------------------------------------------------------------------
PROCEDURE register_service_process(application_name IN VARCHAR2,
                                   request_group    IN VARCHAR2 default NULL,
                                   cz_schema        IN VARCHAR2 default NULL);
------------------------------------------------------------------------------
PROCEDURE delete_service_process
(application_name IN VARCHAR2);
------------------------------------------------------------------------------

PROCEDURE RefreshSingleModel_cp(errbuf OUT NOCOPY VARCHAR2,
					retcode OUT NOCOPY NUMBER,
                        	iFolder_ID IN NUMBER,
					iModel_Id IN VARCHAR2,
					COPY_CHILD_MODELS IN VARCHAR2 DEFAULT '0');

------------------------------------------------------------------------------------------
PROCEDURE RemoveModel_cp(errbuf OUT NOCOPY VARCHAR2,
			 retcode OUT NOCOPY NUMBER,
			 iFolder_ID IN NUMBER,
			 iModel_Id IN VARCHAR2,
			 iImportEnabled IN VARCHAR2);

------------------------------------------------------------------------------

PROCEDURE go_cp(errbuf OUT NOCOPY VARCHAR2,retcode OUT NOCOPY NUMBER);

------------------------------------------------------------------------------

PROCEDURE PopulateModels_cp
(errbuf             OUT NOCOPY VARCHAR2,
 retcode            OUT NOCOPY NUMBER,
 sOrg_ID            IN  VARCHAR2,
 dsOrg_ID           IN  VARCHAR2,
 sFrom              IN  VARCHAR2,
 sTo                IN  VARCHAR2,
 COPY_CHILD_MODELS  IN  VARCHAR2 DEFAULT '0');

------------------------------------------------------------------------------

-- Register Configurator BOM syncronization concurrent process --

PROCEDURE register_bom_sync_process
(application_name IN VARCHAR2,
 request_group    IN VARCHAR2 default NULL,
 cz_schema        IN VARCHAR2 default NULL) ;

-- remove Configurator BOM syncronization concurrent process --
PROCEDURE delete_bom_sync_process
(application_name IN VARCHAR2);

-- Check model(s)/bill(s) similarity --
PROCEDURE check_model_similarity_cp
(errbuf             OUT NOCOPY VARCHAR2,
 retcode            OUT NOCOPY NUMBER,
 p_TARGET_INSTANCE  IN  VARCHAR2,
 p_FOLDER_ID        IN  NUMBER,
 p_MODEL_ID         IN  NUMBER);

-- Check all models/bills similarity --
PROCEDURE check_all_models_similarity_cp
(errbuf             OUT NOCOPY VARCHAR2,
 retcode            OUT NOCOPY NUMBER,
 p_TARGET_INSTANCE  IN  VARCHAR2);

-- Synchronize all models --
PROCEDURE sync_all_models_cp
(errbuf             OUT NOCOPY VARCHAR2,
 retcode            OUT NOCOPY NUMBER);

-- perform Repopulate operation
-- for all Populators of particular model
PROCEDURE Repopulate_cp
(errbuf             OUT NOCOPY VARCHAR2,
 retcode            OUT NOCOPY NUMBER,
 p_FOLDER_ID        IN  NUMBER,
 p_MODEL_ID         IN  NUMBER);

END;

 

/
