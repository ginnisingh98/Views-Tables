--------------------------------------------------------
--  DDL for Package Body CZ_ORAAPPS_INTEGRATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_ORAAPPS_INTEGRATE" AS
/*	$Header: czcaintb.pls 120.16.12010000.2 2010/04/28 20:23:43 lamrute ship $		  */

PROCEDURE get_App_Info(p_app_short_name IN VARCHAR2,
                       p_link_name      IN VARCHAR2,
                       x_oracle_schema  OUT NOCOPY VARCHAR2) IS

  v_status            VARCHAR2(255);
  v_industry          VARCHAR2(255);
BEGIN

  EXECUTE IMMEDIATE
   'DECLARE v_ret BOOLEAN; BEGIN v_ret := FND_INSTALLATION.GET_APP_INFO' || p_link_name ||
   '(:1, :2, :3, :4); END;'
  USING IN p_app_short_name, OUT v_status, OUT v_industry, OUT x_oracle_schema;
END;

FUNCTION ITEM_SURROGATE_KEY(nITEM_ID IN VARCHAR2, nORG_ID IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
    DECLARE
     X         CHAR :=':';
     nSURR_KEY	VARCHAR2(255);
    BEGIN
     nSURR_KEY :=nITEM_ID||X||nORG_ID;
     RETURN nSURR_KEY;
    END;
END ITEM_SURROGATE_KEY;
----------------------------------------------------------------------
FUNCTION COMPONENT_SURROGATE_KEY(sCOMPONENT_SEQUENCE_ID IN VARCHAR2,
                                 sEXPLOSION_TYPE        IN VARCHAR2,
                                 sORG_ID                IN VARCHAR2,
                                 sTOP_ITEM_ID           IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
 RETURN CONCAT(sCOMPONENT_SEQUENCE_ID,CONCAT(':',CONCAT(CONCAT(sEXPLOSION_TYPE,CONCAT(':',sORG_ID)),CONCAT(':',sTOP_ITEM_ID))));
END COMPONENT_SURROGATE_KEY;
----------------------------------------------------------------------
FUNCTION PROJECT_SURROGATE_KEY(sEXPLOSION_TYPE IN VARCHAR2,
                               sORG_ID IN VARCHAR2,
                               sTOP_ITEM_ID IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
 RETURN CONCAT(sEXPLOSION_TYPE, CONCAT(':', CONCAT(sORG_ID,CONCAT(':',sTOP_ITEM_ID))));
END PROJECT_SURROGATE_KEY;
----------------------------------------------------------------------
FUNCTION ENDUSER_SURROGATE_KEY(sORG_ID IN VARCHAR2, sSalesrep_ID IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
 RETURN CONCAT(sORG_ID,CONCAT(':',sSalesrep_ID));
END ENDUSER_SURROGATE_KEY;
----------------------------------------------------------------------
PROCEDURE ITEM_EXTERNAL_PK(nSURR_KEY IN VARCHAR2,xITEM_ID OUT NOCOPY VARCHAR2,
				xORG_ID OUT NOCOPY VARCHAR2)
IS
	BEGIN
		DECLARE
			nITEM_ID VARCHAR2(255);
			nORG_ID VARCHAR2(255);
	BEGIN
		SELECT SUBSTR(nSURR_KEY,((INSTR(nSURR_KEY,':')+1)))
			INTO nORG_ID
			FROM DUAL;
		SELECT RTRIM(nSURR_KEY,nORG_ID)
			INTO nITEM_ID
			FROM DUAL;
		SELECT RTRIM(nITEM_ID,':')
			INTO nITEM_ID
			FROM DUAL;
		xORG_ID:=nORG_ID;
		xITEM_ID:=nITEM_ID;
	END;
END ITEM_EXTERNAL_PK;
------------------------------------------------------------------------------
------------------------------------------------------------------------------
/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE register_spx_process
(p_name          IN VARCHAR2,
p_short_name     IN VARCHAR2,
p_application    IN VARCHAR2,
p_description    IN VARCHAR2,
p_procedure_name IN VARCHAR2,
p_request_group  IN VARCHAR2,
cz_schema        IN VARCHAR2 default NULL) AS

var_schema       VARCHAR2(40);
creation_failure EXCEPTION;
exec_exists      EXCEPTION;
no_req_group     EXCEPTION;

BEGIN
IF NOT(fnd_program.executable_exists(executable_short_name=>p_short_name,
                                        application => p_application))  THEN
   fnd_program.executable(executable => p_name,
                          short_name => p_short_name,
                          application => p_application,
                          description => p_description,
                          execution_method => 'PL/SQL Stored Procedure',
                          execution_file_name => p_procedure_name);
ELSE
   raise exec_exists;
END IF;
BEGIN
fnd_program.register(program => p_name,
                     application => p_application,
                     enabled => 'Y',
                     short_name => p_short_name,
                     description => p_description,
                     executable_short_name => p_short_name,
                     executable_application => p_application,
                     use_in_srs => 'Y');
EXCEPTION
WHEN OTHERS THEN
     LOG_REPORT('Failure creating program: ' || SQLERRM);
     raise creation_failure;
END;

-- Add concurrent program to OE Concurrent Program request group,
-- so it can be seen in Apps UI.

IF p_request_group IS NOT NULL THEN
   BEGIN
   IF fnd_program.request_group_exists(p_request_group, p_application)
   THEN
      fnd_program.add_to_group(p_short_name, p_application,    p_request_group, p_application);
   ELSE
      raise no_req_group;
   END IF;
   END;
END IF;

commit;

EXCEPTION
WHEN exec_exists THEN
     LOG_REPORT('This executable already exists.  Script  terminated.');
WHEN creation_failure THEN
     LOG_REPORT('Creation failure');
WHEN no_req_group THEN
     LOG_REPORT('<'||p_request_group || '> request group does not exist.');
WHEN OTHERS THEN
     LOG_REPORT(SQLERRM);
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE delete_spx_process
(p_short_name  IN VARCHAR2,
 p_application IN VARCHAR2) AS
BEGIN
fnd_program.delete_program(p_short_name,p_application);
fnd_program.delete_executable(p_short_name,p_application);
commit;
END;



/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

--Register SellingPoint Export concurrent process

PROCEDURE register_export_process
(application_name  IN VARCHAR2 , -- default 'Oracle Order Entry',
 Request_Group     IN VARCHAR2 , -- default 'OE Concurrent Programs',
 cz_schema         IN VARCHAR2 default NULL) AS

var_schema           VARCHAR2(40);
ar_application_name  VARCHAR2(50):='Oracle Receivables';
ar_request_group     VARCHAR2(50):=NULL;
creation_failure     EXCEPTION;
exec_exists          EXCEPTION;
no_req_group         EXCEPTION;
BEGIN
BEGIN
register_spx_process(
                    'SellingPoint : Export',
                    'SPOEEXP',
                    application_name,
                    'Export Orders from SellingPoint to OE',
                    'CZ_EXPORT.SUBMIT_ALL_CP',
                    request_group,
                    cz_schema);
EXCEPTION
WHEN OTHERS THEN
     LOG_REPORT('Error : < SellingPoint Order Export > REGISTRATION');
END;

BEGIN
register_spx_process(
                    'SellingPoint : Export for Single Order',
                    'SPOEEXPSO',
                    application_name,
                    'Export of Single Order from SellingPoint to OE',
                    'CZ_EXPORT.SUBMIT_FOR_QUOTE_CP',
                    request_group,
                    cz_schema);

fnd_program.parameter(program_short_name=>'SPOEEXPSO',
                      application=>application_name,
                      sequence=>1,
                      parameter=>'QUOTE_HDR_ID',
                      description=>'QUOTE ID',
                      value_set=>'CZ_QUOTE_ID',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'QUOTE ID');


EXCEPTION
WHEN OTHERS THEN
     LOG_REPORT('Error : < SellingPoint : Export for Single Order > REGISTRATION');
END;

BEGIN
register_spx_process(
                    'SellingPoint : Order Export Update Status Process',
                    'SPOEEXPUS',
                    application_name,
                    'Update Status of Exported Orders from SellingPoint to OE',
                    'CZ_EXPORT.ORDER_STATUS_UPDATE_CP',
                    request_group,
                    cz_schema);
EXCEPTION
WHEN OTHERS THEN
     LOG_REPORT('Error : < SellingPoint Order Export Update Status Process > REGISTRATION');
END;
/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
BEGIN
register_spx_process(
                    'SellingPoint : Customer Export',
                    'SPAREXP',
                    ar_application_name,
                    'Export Customers from SellingPoint to OE',
                    'CZ_EXPORT.ALL_CUSTOMERS_EXPORT_CP',
                    ar_request_group,
                    cz_schema);
EXCEPTION
WHEN OTHERS THEN
     LOG_REPORT('Error : < SellingPoint Customer Export > REGISTRATION');
END;

BEGIN
register_spx_process(
                    'SellingPoint : Customer Export Update Status',
                    'SPAREXPUS',
                    ar_application_name,
                    'Update Status of Exported Customers from SellingPoint to OE',
                    'CZ_EXPORT.CUSTOMER_STATUS_UPDATE_CP',
                    ar_request_group,
                    cz_schema);
EXCEPTION
WHEN OTHERS THEN
     LOG_REPORT('Error : < SellingPoint Customer Export Update Status Process > REGISTRATION');
END;

BEGIN
register_spx_process(
                    'SellingPoint : Customer Export for Single Customer',
                    'SPAREXPSC',
                    ar_application_name,
                    'Export of Single Customer from SellingPoint to OE',
                    'CZ_EXPORT.CUSTOMER_EXPORT_CP',
                    ar_request_group,
                    cz_schema);
fnd_program.parameter(program_short_name=>'SPAREXPSC',
                      application=>ar_application_name,
                      sequence=>1,
                      parameter=>'CUSTOMER_ID',
                      description=>'CUSTOMER_ID',
                      value_set=>'7/Number',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'CUSTOMER ID');

EXCEPTION
WHEN OTHERS THEN
     LOG_REPORT('Error : < SellingPoint Customer Export for Single Customer > REGISTRATION');
END;
*/

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

--Register Configurator Import concurrent process

PROCEDURE register_import_process
(application_name IN VARCHAR2 , -- default 'Oracle Configurator',
 request_group    IN VARCHAR2 default NULL,
 cz_schema        IN VARCHAR2 default NULL) AS
BEGIN
BEGIN
register_spx_process('Refresh All Imported Configuration Models',
                     'CZAPPIMP',
                     application_name,
                     'Import Apps Data into Configurator',
                     'CZ_ORAAPPS_INTEGRATE.GO_CP',
                     request_group,
                     cz_schema);
EXCEPTION
WHEN OTHERS THEN
     LOG_REPORT('Error : < Refresh Configuration Models from BOM > REGISTRATION');
END;
BEGIN
register_spx_process('Import Model Bills',
                     'CZAPPIMPPCM',
                     application_name,
                     'Populate Configuration Models',
                     'CZ_ORAAPPS_INTEGRATE.POPULATEMODELS_CP',
                     request_group,
                     cz_schema);
fnd_program.parameter(program_short_name=>'CZAPPIMPPCM',
                      application=>application_name,
                      sequence=>1,
                      parameter=>'sORG_ID',
                      description=>'Organization Code',
                      value_set=>'CZ_ORG_ID',
                      display_size=>10,
                      description_size=>10,
                      concatenated_description_size=>50,
                      prompt=>'Organization Code');

fnd_program.parameter(program_short_name=>'CZAPPIMPPCM',
                      application=>application_name,
                      sequence=>2,
                      parameter=>'dsORG_ID',
                      description=>'dummy value',
                      value_set=>'CZ_ORG_DUMMY',
                      default_type=>'SQL Statement',
                      default_value=>'select :$FLEX$.CZ_ORG_ID from dual',
                      display=>'N',
                      display_size=>10,
                      description_size=>10,
                      concatenated_description_size=>50,
                      prompt=>'dsORG_ID');

fnd_program.parameter(program_short_name=>'CZAPPIMPPCM',
                      application=>application_name,
                      sequence=>3,
                      parameter=>'sFrom',
                      description=>'Model Inventory Item From',
                      value_set=>'CZ_MODEL_ITM',
                      display_size=>10,
                      description_size=>10,
                      concatenated_description_size=>50,
                      prompt=>'Model Inventory Item From');
fnd_program.parameter(program_short_name=>'CZAPPIMPPCM',
                      application=>application_name,
                      sequence=>4,
                      parameter=>'sTo',
                      description=>'Model Inventory Item To',
                      value_set=>'CZ_MODEL_ITM',
                      display_size=>10,
                      description_size=>10,
                      concatenated_description_size=>50,
                      prompt=>'Model Inventory Item To');
fnd_program.parameter(program_short_name=>'CZAPPIMPPCM',
                      application=>application_name,
                      sequence=>5,
                      parameter=>'sChild',
                      description=>'Reference existing child models when available?',
                      value_set=>'CZ_ENABLE_FLAG',
                      display_size=>1,
                      description_size=>10,
                      concatenated_description_size=>50,
                      prompt=>'Reference existing child models when available?');

EXCEPTION
WHEN OTHERS THEN
     LOG_REPORT('Error : < Import New Configuration Models from BOM > REGISTRATION');
END;

BEGIN
register_spx_process('Refresh a Single Configuration Model',
                     'CZAPPIMPRFCM',
                     application_name,
                     'Refresh a Configuration Model',
                     'CZ_ORAAPPS_INTEGRATE.REFRESHSINGLEMODEL_CP',
                     request_group,
                     cz_schema);

fnd_program.parameter(program_short_name=>'CZAPPIMPRFCM',
                      application=>application_name,
                      sequence=>1,
                      parameter=>'sFolder_Id',
                      description=>'Folder',
                      value_set=>'CZ_FLD',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'Folder'
                      );

fnd_program.parameter(program_short_name=>'CZAPPIMPRFCM',
                      application=>application_name,
                      sequence=>2,
                      parameter=>'sModel_Id',
                      description=>'Configuration Model',
                      value_set=>'CZ_FOLDER_MODEL',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'Configuration Model Id'
                      );

fnd_program.parameter(program_short_name=>'CZAPPIMPRFCM',
                      application=>application_name,
                      sequence=>3,
                      parameter=>'sChild',
                      description=>'Reference existing child models when available?',
                      value_set=>'CZ_ENABLE_FLAG',
                      display_size=>1,
                      description_size=>10,
                      concatenated_description_size=>50,
                      prompt=>'Reference existing child models when available?');

EXCEPTION
WHEN OTHERS THEN
     LOG_REPORT('Error : < Refresh Single Configuration Model from BOM > REGISTRATION');
END;


BEGIN
register_spx_process('Disable/Enable Refresh of a Configuration Model',
                     'CZAPPIMPRMCM',
                     application_name,
                     'Change Import Parameters for a Configuration Model',
                     'CZ_ORAAPPS_INTEGRATE.REMOVEMODEL_CP',
                     request_group,
                     cz_schema);

fnd_program.parameter(program_short_name=>'CZAPPIMPRMCM',
                      application=>application_name,
                      sequence=>1,
                      parameter=>'sFolder_Id',
                      description=>'Folder',
                      value_set=>'CZ_FLD',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'Folder'
                      );

fnd_program.parameter(program_short_name=>'CZAPPIMPRMCM',
                      application=>application_name,
                      sequence=>2,
                      parameter=>'sModel_Id',
                      description=>'Configuration Model',
                      value_set=>'CZ_FOLDER_MODEL',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'Configuration Model Id'
                      );

fnd_program.parameter(program_short_name=>'CZAPPIMPRMCM',
                      application=>application_name,
                      sequence=>3,
                      parameter=>'sImportEnabled',
                      description=>'Import Enabled (Y/N)?',
                      value_set=>'CZ_ENABLE_FLAG',
                      display_size=>1,
                      description_size=>10,
                      concatenated_description_size=>50,
                      prompt=>'Import Enabled (Y/N)?');
EXCEPTION
WHEN OTHERS THEN
     LOG_REPORT('Error : < Change Import Parameters for a Configuration Model > REGISTRATION');
END;

BEGIN
register_spx_process('Purge Configurator Tables',
                     'CZPURGE',
                     application_name,
                     'Purge Configurator Tables',
                     'CZ_MANAGER.PURGE_CP',
                     request_group,
                     cz_schema);
EXCEPTION
WHEN OTHERS THEN
     LOG_REPORT('Error : < Purge Configurator Tables > REGISTRATION');
END;


commit;
END;


-- Register Configurator BOM syncronization concurrent process --

PROCEDURE register_bom_sync_process
(application_name IN VARCHAR2 , -- default 'Oracle Configurator',
 request_group    IN VARCHAR2 default NULL,
 cz_schema        IN VARCHAR2 default NULL) AS
BEGIN

BEGIN
register_spx_process('Check model(s)/bill(s) similarity',
                     'CZBOMSIM',
                     application_name,
                     'Check model(s)/bill(s) similarity',
                     'CZ_ORAAPPS_INTEGRATE.check_model_similarity_cp',
                     request_group,
                     cz_schema);

fnd_program.parameter(program_short_name=>'CZBOMSIM',
                      application=>application_name,
                      sequence=>1,
                      parameter=>'P_TARGET_INSTANCE',
                      description=>'Target Instance',
                      value_set=>'CZ_REMOTE_SERVER',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'Target Instance');


fnd_program.parameter(program_short_name=>'CZBOMSIM',
                      application=>application_name,
                      sequence=>2,
                      parameter=>'P_FOLDER_ID',
                      description=>'Folder',
                      value_set=>'CZ_FLD',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'Folder'
                      );

fnd_program.parameter(program_short_name=>'CZBOMSIM',
                      application=>application_name,
                      sequence=>3,
                      parameter=>'P_MODEL_ID',
                      description=>'List Of Models',
                      value_set=>'CZ_FOLDER_MODEL',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'List Of Models');


EXCEPTION
WHEN OTHERS THEN
     LOG_REPORT('Error : < Check model(s)/bills(s) similarity > REGISTRATION');
END;

BEGIN
register_spx_process('Check all models/bills similarity',
                     'CZALLBOMSIM',
                     application_name,
                     'Check all models/bills similarity',
                     'CZ_ORAAPPS_INTEGRATE.check_all_models_similarity_cp',
                     request_group,
                     cz_schema);

fnd_program.parameter(program_short_name=>'CZALLBOMSIM',
                      application=>application_name,
                      sequence=>1,
                      parameter=>'P_TARGET_INSTANCE',
                      description=>'Target Instance',
                      value_set=>'CZ_REMOTE_SERVER',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'Target Instance');

EXCEPTION
WHEN OTHERS THEN
     LOG_REPORT('Error : < Check all models/bills similarity > REGISTRATION');
END;

BEGIN
register_spx_process('Synchronize all models',
                     'CZALLBOMSYNC',
                     application_name,
                     'Synchronize all models',
                     'CZ_ORAAPPS_INTEGRATE.sync_all_models_cp',
                     request_group,
                     cz_schema);

EXCEPTION
WHEN OTHERS THEN
     LOG_REPORT('Error : < Synchronize all models > REGISTRATION');
END;

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE delete_bom_sync_process
(application_name IN VARCHAR2 -- default 'Oracle Configurator'
) AS
BEGIN
    BEGIN
        fnd_program.delete_program('CZBOMSIM',application_name);
        fnd_program.delete_executable('CZBOMSIM',application_name);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             LOG_REPORT('Error : < CZBOMSIM > does not exist.');
        WHEN OTHERS THEN
             LOG_REPORT('Error : < CZBOMSIM > :'||SQLERRM);
   END;

    BEGIN
        fnd_program.delete_program('CZALLBOMSIM',application_name);
        fnd_program.delete_executable('CZALLBOMSIM',application_name);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             LOG_REPORT('Error : < CZALLBOMSIM > does not exist.');
        WHEN OTHERS THEN
             LOG_REPORT('Error : < CZALLBOMSIM > :'||SQLERRM);
   END;

    BEGIN
        fnd_program.delete_program('CZALLBOMSYNC',application_name);
        fnd_program.delete_executable('CZALLBOMSYNC',application_name);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             LOG_REPORT('Error : < CZALLBOMSYNC > does not exist.');
        WHEN OTHERS THEN
             LOG_REPORT('Error : < CZALLBOMSYNC > :'||SQLERRM);
   END;

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE register_service_process(application_name IN VARCHAR2 , -- default 'Oracle Configurator',
                                   request_group    IN VARCHAR2 default NULL,
                                   cz_schema        IN VARCHAR2 default NULL) AS

BEGIN

    BEGIN
        register_spx_process('Repopulate',
                             'CZREPOP',
                             application_name,
                             'Repopulate',
                             'CZ_ORAAPPS_INTEGRATE.Repopulate_cp',
                             request_group,
                             cz_schema);

        fnd_program.parameter(program_short_name=>'CZREPOP',
                              application=>application_name,
                              sequence=>1,
                              parameter=>'sFolder_Id',
                              description=>'Folder',
                              value_set=>'CZ_FLD',
                              display_size=>20,
                              description_size=>20,
                              concatenated_description_size=>50,
                              prompt=>'Folder');

        fnd_program.parameter(program_short_name=>'CZREPOP',
                              application=>application_name,
                              sequence=>2,
                              parameter=>'sModel_Id',
                              description=>'Configuration Model',
                              value_set=>'CZ_FOLDER_MODEL',
                              display_size=>20,
                              description_size=>20,
                              concatenated_description_size=>50,
                              prompt=>'Configuration Model Id');

       EXCEPTION
           WHEN OTHERS THEN
                LOG_REPORT('Error : < Show Configurator Application Settings > REGISTRATION');
       END;


BEGIN
register_spx_process('Show Configurator Application Settings',
                     'CZREPGS',
                     application_name,
                     'Show Configurator Application Settings',
                     'CZ_ORAAPPS_INTEGRATE.GETSETTING',
                     request_group,
                     cz_schema);

fnd_program.parameter(program_short_name=>'CZREPGS',
                      application=>application_name,
                      sequence=>1,
                      parameter=>'LIKE_SECTION_NAME',
                      description=>'SECTION NAME',
                      value_set=>'30 Characters',
                      default_type=>'Constant',
                      default_value=>'%',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'SECTION NAME');
fnd_program.parameter(program_short_name=>'CZREPGS',
                      application=>application_name,
                      sequence=>2,
                      parameter=>'LIKE_SETTING_ID',
                      description=>'SETTING_ID',
                      value_set=>'30 Characters',
                      default_type=>'Constant',
                      default_value=>'%',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'SETTING_ID');
EXCEPTION
WHEN OTHERS THEN
     LOG_REPORT('Error : < Show Configurator Application Settings > REGISTRATION');
END;

BEGIN
register_spx_process('Change Configurator Application Settings',
                     'CZREPIN',
                     application_name,
                     'Change Configurator Application Settings',
                     'CZ_ORAAPPS_INTEGRATE.ASSIGNSETTING',
                     request_group,
                     cz_schema);

fnd_program.parameter(program_short_name=>'CZREPIN',
                      application=>application_name,
                      sequence=>1,
                      parameter=>'SECTION_NAME',
                      description=>'SECTION NAME',
                      value_set=>'CZ_DB_SETTINGS_SECTION_NAME',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'SECTION_NAME');
fnd_program.parameter(program_short_name=>'CZREPIN',
                      application=>application_name,
                      sequence=>2,
                      parameter=>'SETTING_ID',
                      description=>'SETTING_ID',
                      value_set=>'CZ_DB_SETTINGS_SETTING_ID',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'SETTING_ID');
fnd_program.parameter(program_short_name=>'CZREPIN',
                      application=>application_name,
                      sequence=>3,
                      parameter=>'VALUE',
                      description=>'VALUE',
                      value_set=>'30 Characters',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'VALUE');
fnd_program.parameter(program_short_name=>'CZREPIN',
                      application=>application_name,
                      sequence=>4,
                      parameter=>'TYPE',
                      description=>'TYPE',
                      value_set=>'CZ_DB_SETTINGS_TYPE',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'TYPE');
fnd_program.parameter(program_short_name=>'CZREPIN',
                      application=>application_name,
                      sequence=>5,
                      parameter=>'DESCRIPTION',
                      description=>'DESCRIPTION',
                      value_set=>'30 Characters',
                      display_size=>50,
                      description_size=>50,
                      concatenated_description_size=>50,
                      prompt=>'DESCRIPTION');

EXCEPTION
WHEN OTHERS THEN
     LOG_REPORT('< Change Configurator Application Settings >');
END;

BEGIN
register_spx_process('Show tables to be Imported',
                     'CZREPGIMP',
                     application_name,
                     'Show tables to be Imported',
                     'CZ_ORAAPPS_INTEGRATE.GETTABLEIMPORT',
                     request_group,
                     cz_schema);

fnd_program.parameter(program_short_name=>'CZREPGIMP',
                      application=>application_name,
                      sequence=>1,
                      parameter=>'LIKE_DST_TABLE_NAME',
                      description=>'TABLE_NAME',
                      value_set=>'30 Characters',
                      default_type=>'Constant',
                      default_value=>'%',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>20,
                      prompt=>'TABLE NAME');
fnd_program.parameter(program_short_name=>'CZREPGIMP',
                      application=>application_name,
                      sequence=>2,
                      parameter=>'IMPORT_GROUP',
                      description=>'Import Group',
                      value_set=>'30 Characters',
                      default_type=>'Constant',
                      default_value=>'%',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'IMPORT GROUP');
EXCEPTION
WHEN OTHERS THEN
     LOG_REPORT('Error : < Show tables to be Imported > REGISTRATION');
END;

BEGIN
register_spx_process('Select Tables to Be Imported',
                     'CZREPSIMP',
                     application_name,
                     'Select Tables to Be Imported',
                     'CZ_ORAAPPS_INTEGRATE.SETTABLEIMPORT',
                     request_group,
                     cz_schema);

fnd_program.parameter(program_short_name=>'CZREPSIMP',
                      application=>application_name,
                      sequence=>1,
                      parameter=>'DST_TABLE_NAME',
                      description=>'DST_TABLE_NAME',
                      value_set=>'CZ_IMPORT_DESTINATION_TABLE',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'Destination Table Name');
fnd_program.parameter(program_short_name=>'CZREPSIMP',
                      application=>application_name,
                      sequence=>2,
                      parameter=>'IMPORT_GROUP',
                      description=>'Import Group',
                      value_set=>'CZ_IMPORT_PHASES',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'Import Group');
fnd_program.parameter(program_short_name=>'CZREPSIMP',
                      application=>application_name,
                      sequence=>3,
                      parameter=>'ENABLEIMPORT',
                      description=>'Enable Import',
                      value_set=>'CZ_ENABLE_FLAG',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'Enable(Y/N)');
EXCEPTION
WHEN OTHERS THEN
     LOG_REPORT('Error : < Select Tables to Be Imported > REGISTRATION');
END;


BEGIN
register_spx_process('Process Pending Publications',
                     'CZPUBLISHMODEL',
                     application_name,
                     'Export All Published Models',
                     'CZ_PB_MGR.publish_models_cp',
                     request_group,
                     cz_schema);

EXCEPTION
WHEN OTHERS THEN
     LOG_REPORT('Error : < Export All Published Models > REGISTRATION');
END;

BEGIN
register_spx_process('Process a Single Publication',
                     'CZPUBLISHSINGLE',
                     application_name,
                     'Export a Single Publication',
                     'CZ_PB_MGR.publish_single_model_cp',
                     request_group,
                     cz_schema);
fnd_program.parameter(program_short_name=>'CZPUBLISHSINGLE',
                      application=>application_name,
                      sequence=>1,
                      parameter=>'PublicationId',
                      description=>'Publication',
                      value_set=>'CZ_PUBLICATION',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'Publication');

EXCEPTION
WHEN OTHERS THEN
     LOG_REPORT('Error : < Export a Single Publication > REGISTRATION');
END;

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE delete_service_process
(application_name IN VARCHAR2 -- default 'System Administration'
) AS
BEGIN
BEGIN
    fnd_program.delete_program('SPREPGS',application_name);
    fnd_program.delete_executable('SPREPGS',application_name);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         LOG_REPORT('Error : < SPREPGS > does not exist.');
    WHEN OTHERS THEN
         LOG_REPORT('Error : < SPREPGS > :'||SQLERRM);
END;

BEGIN
    fnd_program.delete_program('SPREPIN',application_name);
    fnd_program.delete_executable('SPREPIN',application_name);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         LOG_REPORT('Error : < SPREPIN > does not exist.');
    WHEN OTHERS THEN
         LOG_REPORT('Error : < SPREPIN > :'||SQLERRM);
END;

BEGIN
    fnd_program.delete_program('SPREPGIMP',application_name);
    fnd_program.delete_executable('SPREPGIMP',application_name);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         LOG_REPORT('Error : < SPREPGIMP > does not exist.');
    WHEN OTHERS THEN
         LOG_REPORT('Error : < SPREPGIMP > :'||SQLERRM);
END;

BEGIN
    fnd_program.delete_program('SPREPSIMP',application_name);
    fnd_program.delete_executable('SPREPSIMP',application_name);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         LOG_REPORT('Error : < SPREPSIMP > does not exist.');
    WHEN OTHERS THEN
         LOG_REPORT('Error : < SPREPSIMP > :'||SQLERRM);
END;

BEGIN
    fnd_program.delete_program('SPCREATELNK',application_name);
    fnd_program.delete_executable('SPCREATELNK',application_name);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         LOG_REPORT('Error : < SPCREATELNK > does not exist.');
    WHEN OTHERS THEN
         LOG_REPORT('Error : < SPCREATELNK > :'||SQLERRM);
END;

BEGIN
    fnd_program.delete_program('SPPUBLISHMODEL',application_name);
    fnd_program.delete_executable('SPPUBLISHMODEL',application_name);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         LOG_REPORT('Error : < SPPUBLISHMODEL > does not exist.');
    WHEN OTHERS THEN
         LOG_REPORT('Error : < SPPUBLISHMODEL > :'||SQLERRM);
END;

BEGIN
    fnd_program.delete_program('SPPOPULATESRV',application_name);
    fnd_program.delete_executable('SPPOPULATESRV',application_name);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         LOG_REPORT('Error : < SPPOPULATESRV > does not exist.');
    WHEN OTHERS THEN
         LOG_REPORT('Error : < SPPOPULATESRV > :'||SQLERRM);
END;


commit;
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

--Delete SellingPoint Export concurrent process

PROCEDURE delete_export_process
(application_name IN VARCHAR2 -- default 'Oracle Order Entry'
) AS
ar_application_name VARCHAR2(50):='Oracle Receivables';
BEGIN
BEGIN
    fnd_program.delete_program('SPOEEXP',application_name);
    fnd_program.delete_executable('SPOEEXP',application_name);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         LOG_REPORT('Error : < SPOEEXP > does not exist.');
    WHEN OTHERS THEN
         LOG_REPORT('Error : < SPOEEXP > :'||SQLERRM);
END;

BEGIN
    fnd_program.delete_program('SPOEEXPUS',application_name);
    fnd_program.delete_executable('SPOEEXPUS',application_name);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         LOG_REPORT('Error : < SPOEEXPUS > does not exist.');
    WHEN OTHERS THEN
         LOG_REPORT('Error : < SPOEEXPUS > :'||SQLERRM);
END;


/*
BEGIN
fnd_program.delete_program('SPAREXP',ar_application_name);
fnd_program.delete_executable('SPAREXP',ar_application_name);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         LOG_REPORT('Error : < SPAREXP > does not exist.');
    WHEN OTHERS THEN
         LOG_REPORT('Error : < SPAREXP > :'||SQLERRM);
END;

BEGIN
fnd_program.delete_program('SPAREXPUS',ar_application_name);
fnd_program.delete_executable('SPAREXPUS',ar_application_name);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         LOG_REPORT('Error : < SPAREXPUS > does not exist.');
    WHEN OTHERS THEN
         LOG_REPORT('Error : < SPAREXPUS > :'||SQLERRM);
END;

BEGIN
fnd_program.delete_program('SPAREXPSC',ar_application_name);
fnd_program.delete_executable('SPAREXPSC',ar_application_name);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         LOG_REPORT('Error : < SPAREXPSC > does not exist.');
    WHEN OTHERS THEN
         LOG_REPORT('Error : < SPAREXPSC > :'||SQLERRM);
END;

BEGIN
fnd_program.delete_program('SPOEEXPSO',application_name);
fnd_program.delete_executable('SPOEEXPSO',application_name);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         LOG_REPORT('Error : < SPOEEXPSO > does not exist.');
    WHEN OTHERS THEN
         LOG_REPORT('Error : < SPOEEXPSO > :'||SQLERRM);
END;

*/
commit;
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

--Delete SellingPoint Import concurrent process

PROCEDURE delete_import_process
(application_name IN VARCHAR2 -- default 'Oracle Bills of Material'
) AS
BEGIN
BEGIN
    fnd_program.delete_program('SPAPPIMP','System Administration');
    fnd_program.delete_executable('SPAPPIMP','System Administrationdel');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         LOG_REPORT('Error : < SPAPPIMP > does not exist.');
    WHEN OTHERS THEN
         LOG_REPORT('Error : < SPAPPIMP > :'||SQLERRM);
END;
BEGIN
    fnd_program.delete_program('SPAPPIMPPCM',application_name);
    fnd_program.delete_executable('SPAPPIMPPCM',application_name);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         LOG_REPORT('Error : < SPAPPIMPPCM > does not exist.');
    WHEN OTHERS THEN
         LOG_REPORT('Error : < SPAPPIMPPCM > :'||SQLERRM);
END;

BEGIN
    fnd_program.delete_program('SPAPPIMPRFCM',application_name);
    fnd_program.delete_executable('SPAPPIMPRFCM',application_name);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         LOG_REPORT('Error : < SPAPPIMPRFCM > does not exist.');
    WHEN OTHERS THEN
         LOG_REPORT('Error : < SPAPPIMPRFCM > :'||SQLERRM);
END;

BEGIN
    fnd_program.delete_program('SPAPPIMPRMCM',application_name);
    fnd_program.delete_executable('SPAPPIMPRMCM',application_name);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         LOG_REPORT('Error : < SPAPPIMPRMCM > does not exist.');
    WHEN OTHERS THEN
         LOG_REPORT('Error : < SPAPPIMPRMCM > :'||SQLERRM);
END;

commit;
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE submit_export_request
(v_user_id       IN NUMBER,
 v_resp_id       IN NUMBER,
 vision_org_id   IN NUMBER  , -- default 204,
 v_appl_id       IN NUMBER    -- default 708   --CZ
) AS

--v_user_id       NUMBER := 1068;

p_interval		NUMBER:=10;
p_max_wait		NUMBER:=1000;
oe_phase	      VARCHAR2(20);
oe_status	      VARCHAR2(20);
oe_dev_phase	VARCHAR2(20);
oe_dev_status	VARCHAR2(20);
oe_message		VARCHAR2(50);
oe_request_id	NUMBER;
oe_request_result BOOLEAN;
cur               NUMBER;
var_row           NUMBER;
stmt              VARCHAR2(1000);
var_schema        VARCHAR2(40);
oe_submit_failure EXCEPTION;

BEGIN

oe_request_id := fnd_request.submit_request(
'OE',        -- APPlication Name  from FND_APPLICATION
'SPOEEXP',    -- Application Concurrent Prgm from FND_CONCURRENT_PROGRAMS
 'Export Orders from SellingPoint to OE',      -- Description  from FND_CONCURRENT_PROGRAMS
 NULL,              -- Start Date
 FALSE             -- Is called from another concurrent request?
 );
COMMIT;
LOG_REPORT('Request ID : ' || to_char(oe_request_id));
IF oe_request_id <> 0 THEN
   oe_request_result :=fnd_concurrent.wait_for_request(oe_request_id,
                                                          p_interval,
  	       			                            p_max_wait,
  		 			                            oe_phase,
  					                            oe_status,
  					                            oe_dev_phase,
  					                            oe_dev_status,
  		      		                            oe_message);
ELSE
    raise oe_submit_failure;
END IF;
COMMIT;
EXCEPTION
WHEN oe_submit_failure THEN
     LOG_REPORT('Error : SellingPoint Export process could not be submitted.');
WHEN OTHERS THEN
     LOG_REPORT(SQLERRM);

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE set_request_schedule
(repeat_time      IN VARCHAR2 default NULL,
 repeat_interval  IN NUMBER   , -- default 60,
 repeat_unit      IN VARCHAR2 , -- default 'MINUTES',
 repeat_type      IN VARCHAR2 , -- default 'START',
 repeat_end_time  IN VARCHAR2 default NULL) AS
ret BOOLEAN;
BEGIN
ret:=fnd_request.set_repeat_options(repeat_time,repeat_interval,repeat_unit,repeat_type,repeat_end_time);
IF ret=FALSE THEN
   LOG_REPORT('Error in repeating request.');
END IF;
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE SettingReport
(section_name IN VARCHAR2 , -- default '%',
 setting_id   IN VARCHAR2 , -- default '%',
 cz_schema        IN VARCHAR2 default NULL ) AS
cur            INTEGER;
stmt           VARCHAR2(1000);
var_setting_id VARCHAR2(40);
var_value      VARCHAR2(255);
var_schema     VARCHAR2(40);
var_row        INTEGER;
BEGIN
IF cz_schema is NULL THEN
   var_schema:=NULL;
ELSE
   var_schema:=cz_schema||'.';
END IF;
cur:=dbms_sql.open_cursor;
stmt:='SELECT setting_id,value from '||var_schema||'CZ_DB_SETTINGS WHERE section_name like '''||section_name||
''' and setting_id like '''||setting_id||''' ';

dbms_sql.parse(cur,stmt,dbms_sql.native);
dbms_sql.define_column(cur,1,var_setting_id,40);
dbms_sql.define_column(cur,2,var_value,300);
var_row:=dbms_sql.execute(cur);
WHILE (dbms_sql.fetch_rows(cur)>0) LOOP
       dbms_sql.column_value(cur,1,var_setting_id);
       dbms_sql.column_value(cur,2,var_value);
       LOG_REPORT(rpad(var_setting_id,40)||var_value);
END LOOP;
dbms_sql.close_cursor(cur);
EXCEPTION
WHEN OTHERS THEN
     LOG_REPORT(SQLERRM);
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
PROCEDURE LOG_REPORT
(inStr IN VARCHAR2) AS

BEGIN
  cz_utils.log_report('CZ_ORAAPPS_INTEGRATE', null, null,
                       instr, fnd_log.LEVEL_ERROR);
EXCEPTION
  WHEN OTHERS THEN
     ROLLBACK;
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
------------------------------------------------------------------------------
PROCEDURE GetSetting(errbuf OUT NOCOPY VARCHAR2,
                     retcode OUT NOCOPY NUMBER,
                     LIKE_SectionName IN VARCHAR2 , -- DEFAULT '%',
                     LIKE_SettingID   IN VARCHAR2   -- DEFAULT '%'
                    ) IS
 CURSOR C_GETSET IS
  SELECT SECTION_NAME,SETTING_ID,VALUE,DESC_TEXT FROM CZ_DB_SETTINGS
  WHERE SECTION_NAME LIKE LIKE_SectionName AND SETTING_ID LIKE LIKE_SettingID;
 slSectionName  CZ_DB_SETTINGS.SECTION_NAME%TYPE;
 slSettingID    CZ_DB_SETTINGS.SETTING_ID%TYPE;
 slValue        CZ_DB_SETTINGS.VALUE%TYPE;
 slDescription  CZ_DB_SETTINGS.DESC_TEXT%TYPE;
BEGIN
errbuf:='';
retcode:=0;
 OPEN C_GETSET;
 LOOP
  FETCH C_GETSET INTO slSectionName,slSettingID,slValue,slDescription;
  EXIT WHEN C_GETSET%NOTFOUND;

  FND_FILE.PUT_LINE(FND_FILE.LOG,'SECTION_NAME = '||slSectionName);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'SETTING_ID = '||slSettingID);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'VALUE = '||slValue);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'DESCRIPTION = '||slDescription);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'----------------------------');

 END LOOP;
 CLOSE C_GETSET;
EXCEPTION
  WHEN OTHERS THEN
    errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_GETSETTING_FAILED','ERRORTEXT',SQLERRM);
    --Now done from GET_TEXT
    --FND_FILE.PUT_LINE(FND_FILE.LOG,'GetSetting failed: '||SQLERRM);
END;
------------------------------------------------------------------------------
PROCEDURE AssignSetting(errbuf OUT NOCOPY VARCHAR2,
                        retcode OUT NOCOPY NUMBER,
                        sSECTION_NAME IN VARCHAR2,
                        sSETTING_ID   IN VARCHAR2,
                        sVALUE        IN VARCHAR2,
                        sTYPE         IN VARCHAR2 , -- DEFAULT '4',
                        sDESCRIPTION  IN VARCHAR2 DEFAULT NULL) IS
CURSOR c1 IS
SELECT 'X' FROM cz_db_settings
WHERE section_name=section_Name AND
setting_id=sSetting_Id;
var1  varchar2(1);
BEGIN
errbuf:='';
retcode:=0;
OPEN c1;
FETCH c1 INTO var1;
IF c1%found THEN
   UPDATE cz_db_settings SET value=sValue WHERE section_name=sSection_Name AND setting_id=sSetting_Id;
ELSE
   INSERT INTO cz_db_settings(setting_id,section_name,data_type,value,desc_text)
   VALUES(sSetting_Id,sSection_Name,sType,sValue,sDESCRIPTION);
END IF;
CLOSE c1;
COMMIT;
EXCEPTION
WHEN OTHERS THEN
    errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_SETSETTING_FAILED','ERRORTEXT',SQLERRM);
    --Now done from GET_TEXT
    --FND_FILE.PUT_LINE(FND_FILE.LOG,'Setting not assigned: '||SQLERRM);
END;
------------------------------------------------------------------------------
PROCEDURE GetTableImport(errbuf OUT NOCOPY VARCHAR2,
                         retcode OUT NOCOPY NUMBER,
                         LIKE_DstTableName IN VARCHAR2 , -- DEFAULT '%',
                         LIKE_PhaseName    IN VARCHAR2   -- DEFAULT '%'
                        ) IS
 CURSOR C_GETSET IS
  SELECT DST_TABLE,XFR_GROUP,DISABLED FROM CZ_XFR_TABLES
  WHERE DST_TABLE LIKE LIKE_DstTableName AND XFR_GROUP LIKE LIKE_PhaseName;
 slDstTable     CZ_XFR_TABLES.DST_TABLE%TYPE;
 slXfrGroup     CZ_XFR_TABLES.XFR_GROUP%TYPE;
 slDisabled     CZ_XFR_TABLES.DISABLED%TYPE;
BEGIN
errbuf:='';
retcode:=0;
 OPEN C_GETSET;
 LOOP
  FETCH C_GETSET INTO slDstTable,slXfrGroup,slDisabled;
  EXIT WHEN C_GETSET%NOTFOUND;

  FND_FILE.PUT_LINE(FND_FILE.LOG,'DST_TABLE = '||slDstTable);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'XFR_GROUP = '||slXfrGroup);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'DISABLED_FLAG = '||slDisabled);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'----------------------------');

 END LOOP;
 CLOSE C_GETSET;
EXCEPTION
WHEN OTHERS THEN
     errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_READXFRTABLE_FAILED','ERRORTEXT',SQLERRM);
END;
------------------------------------------------------------------------------
PROCEDURE SetTableImport(errbuf OUT NOCOPY VARCHAR2,
                         retcode OUT NOCOPY NUMBER,
                         DstTableName   IN VARCHAR2,
                         LIKE_PhaseName IN VARCHAR2 , -- DEFAULT '%',
                         EnableImport   IN VARCHAR2   -- DEFAULT '1'
                        ) IS
BEGIN
errbuf:='';
retcode:=0;
 UPDATE CZ_XFR_TABLES SET
   DISABLED=DECODE(UPPER(EnableImport),'0','1','OFF','1','N','1','DISABLE','1',
   '1','0','ON','0','Y','0','ENABLE','0',DISABLED)
 WHERE DST_TABLE=DstTableName AND XFR_GROUP LIKE LIKE_PhaseName;
 IF(SQL%NOTFOUND)THEN
   LOG_REPORT(CZ_UTILS.GET_TEXT('CZ_IMP_NOXFRTABLEDATA'));
 END IF;
 COMMIT;
 EXCEPTION
  WHEN OTHERS THEN
    errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_SETXFRTABLE_FAILED','ERRORTEXT',SQLERRM);
    LOG_REPORT(errbuf);
END;

------------------------------------------------------------------------------
--The function returns 1 if the link exists, 0 otherwise. This is done for
--compatibility with the previously used SELECT COUNT(*) FROM USER_DB_LINKS
--method which didn't work well because of GLOBAL_NAMES.

FUNCTION doesLinkExist(p_link_name IN VARCHAR2) RETURN PLS_INTEGER IS
  v_null  PLS_INTEGER;
BEGIN
  EXECUTE IMMEDIATE 'SELECT NULL FROM DUAL@' || p_link_name;
  SELECT NULL INTO v_null FROM user_db_links WHERE UPPER(db_link) = UPPER(p_link_name)
      OR UPPER(db_link) LIKE UPPER(p_link_name) || '.%';
  RETURN 1;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
  WHEN OTHERS THEN

    --ORA-02019: connection description for remote database not found

    IF SQLCODE = -2019 THEN RETURN 0; ELSE RETURN 1; END IF;
END;
------------------------------------------------------------------------------
FUNCTION isLinkAlive(sDb_Link IN VARCHAR2) RETURN VARCHAR2 IS
    v_temp         DATE;
    v_db_Link      VARCHAR2(255):='';
BEGIN
--    IF sDb_Link IS NULL OR sDb_Link='' OR sDb_Link=' ' THEN
	IF (replace(sDb_Link,' ',NULL) IS NULL) THEN
       v_db_link:='';
    ELSE
       v_db_link:='@'||sDB_Link;
    END IF;
    --
    -- to check DB link           --
    -- use probe select statement --
    --
    EXECUTE IMMEDIATE 'SELECT sysdate FROM dual'||v_db_link
    INTO v_temp;
    RETURN LINK_WORKS;
EXCEPTION
    WHEN OTHERS THEN
         RETURN LINK_IS_DOWN;
END isLinkAlive;
------------------------------------------------------------------------------

PROCEDURE compile_Dependents(p_filter IN VARCHAR2 -- DEFAULT 'CZ_IMP%'
) IS

BEGIN
    FOR i IN (SELECT object_name FROM user_objects WHERE object_name like p_filter AND
              object_type='PACKAGE BODY' AND status='INVALID')
    LOOP
       BEGIN
           EXECUTE IMMEDIATE 'ALTER PACKAGE '||i.object_name||' COMPILE BODY';
       EXCEPTION
           WHEN OTHERS THEN
             log_report('compile_Dependents: Package ' || i.object_name || ' can not be compiled : ' || SQLERRM);
       END;
    END LOOP;
END;

--------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
---------- create views

FUNCTION create_exv_views(slocal_name   IN  VARCHAR2) RETURN VARCHAR2 AS
v_fndnam_link_name			cz_servers.local_name%type;

v_bom_string				varchar2(4000);
v_item_master_string			varchar2(4000);
v_items_string				varchar2(4000);
v_addresses_string			varchar2(4000);
v_address_uses_string			varchar2(4000);
v_customers_string			varchar2(4000);
v_contacts_string			varchar2(4000);
v_price_list_string			varchar2(4000);
v_price_list_line_string		varchar2(4000);
v_end_user_string			varchar2(4000);
v_item_properties_string		varchar2(4000);
v_item_property_values_string		varchar2(4000);
v_item_types_string			varchar2(4000);
v_mtl_system_items_string		varchar2(4000);
v_organization_string			varchar2(4000);
v_apc_props_string                  varchar2(4000);
v_apc_prop_values_string            varchar2(4000);
v_string				varchar2(4000);
v_versioned_string			varchar2(100);
v_column_name				varchar2(35);
v_trackable_flag			varchar2(35) := ' COMMS_NL_TRACKABLE_FLAG';
v_config_model_type                     varchar2(35) := ' CONFIG_MODEL_TYPE';
x_mtl_system_items_tl_exists            BOOLEAN;
v_table_name        varchar2(355);
v_intl_text_string_1 varchar2(4000);
v_intl_text_string_2 varchar2(4000);

v_success		char(1) := '0';
v_warning		char(1) := '1';
v_error			char(1) := '2';
v_rownum                VARCHAR2(20):='';
v_where                 VARCHAR2(40):='';
v_errorString		VARCHAR2(1024) := 'CREATE_EXV_VIEWS : ';
v_version_10_flag	BOOLEAN := FALSE;
v_count			int;
v_cur    		INTEGER;
v_res    		INTEGER;
v_inv_oracle_schema     VARCHAR2(255);

localTable              VARCHAR2(20) := '';
settingVal              PLS_INTEGER;
v_mtl_system_items_tl   VARCHAR2(240);
v_where_tl              VARCHAR2(240) := ' AND M.ORGANIZATION_ID = T.ORGANIZATION_ID AND M.INVENTORY_ITEM_ID = T.INVENTORY_ITEM_ID ';
v_where_tl_2            VARCHAR2(240) := ' WHERE M.ORGANIZATION_ID = T.ORGANIZATION_ID AND M.INVENTORY_ITEM_ID = T.INVENTORY_ITEM_ID ';
v_desc_tl               VARCHAR2(240) :=  ' T.DESCRIPTION AS ITEM_DESC, ';
v_description_tl        VARCHAR2(240) :=  ' T.DESCRIPTION, ';
v_where_lang_tl         VARCHAR2(240) :=  ' AND T.LANGUAGE = userenv(''LANG'') ';
v_language              VARCHAR2(35)  := ' T.LANGUAGE,';

BEGIN

      IF (upper(slocal_name) NOT IN ('LOCAL','ERROR')) THEN
	   SELECT fndnam_link_name INTO v_fndnam_link_name
         FROM cz_servers
         WHERE local_name = slocal_name;
         v_fndnam_link_name := '@'|| v_fndnam_link_name;
      ELSE
	   v_fndnam_link_name := '';
      END IF;

      v_mtl_system_items_tl :=  ', MTL_SYSTEM_ITEMS_TL'||v_fndnam_link_name||' T ';

      IF (upper(slocal_name)='ERROR') THEN
         v_where:=' WHERE rownum<1';
         v_rownum:=' AND rownum<1';
      END IF;

      --Reading the db settings for the bug #2713743 to see whether we need to include a local
      --table in the join for the definition of CZ_EXV_ITEM_PROPERTY_VALUES and CZ_EXV_ITEMS.

      BEGIN

        SELECT DECODE(UPPER(value), '1', 1, 'ON', 1, 'Y', 1, 'YES', 1,'TRUE', 1, 'ENABLE', 1,
                                    '0', 0, 'OFF', 0, 'N', 0, 'NO',  0,'FALSE', 0, 'DISABLE', 0,
                                     0) --default value
          INTO settingVal FROM cz_db_settings
         WHERE UPPER(section_name) = 'IMPORT'
           AND UPPER(setting_id) = 'USELOCALTABLEINEXTRACTIONVIEWS';

      EXCEPTION
        WHEN OTHERS THEN
          settingVal := 0; --default value
      END;

      --Even if the db setting exists it makes no sense to use it if the import source server
      --is local.

      IF(settingVal = 1 AND v_fndnam_link_name IS NOT NULL)THEN localTable := ', DUAL'; END IF;

	v_bom_string := 'CREATE OR REPLACE VIEW CZ_EXV_BILL_OF_MATERIALS AS ' ||
			'	SELECT ORGANIZATION_ID,ASSEMBLY_ITEM_ID,ASSEMBLY_TYPE,ALTERNATE_BOM_DESIGNATOR,COMMON_BILL_SEQUENCE_ID,BILL_SEQUENCE_ID  ' ||
			'	FROM BOM_BILL_OF_MATERIALS' || v_fndnam_link_name ||' WHERE ALTERNATE_BOM_DESIGNATOR IS NULL'||v_rownum;
	EXECUTE IMMEDIATE v_bom_string;


/*	v_organization_string := 'CREATE OR REPLACE VIEW CZ_EXV_ORGANIZATIONS AS
					SELECT ORGANIZATION_ID, ORGANIZATION_CODE, ORGANIZATION_NAME
					FROM ORG_ORGANIZATION_DEFINITIONS'|| v_fndnam_link_name;*/

	v_organization_string := 'CREATE OR REPLACE VIEW cz_exv_organizations AS ' ||
    					'SELECT A.organization_id ORGANIZATION_ID, b.organization_code ORGANIZATION_CODE, A.name ORGANIZATION_NAME  ' ||
  					'FROM hr_all_organization_units'|| v_fndnam_link_name || ' A,  ' ||
					'	mtl_parameters'|| v_fndnam_link_name || ' b,  ' ||
  					'	hr_organization_information'|| v_fndnam_link_name || ' c, ' ||
  					'	hr_organization_information'|| v_fndnam_link_name || ' c1,  ' ||
					'	gl_sets_of_books'|| v_fndnam_link_name || ' gsob ' ||
  					'WHERE A.organization_id = b.organization_id ' ||
  					'AND A.organization_id = c.organization_id ' ||
    					'AND A.organization_id = c1.organization_id ' ||
  					'AND c.org_information1 = ''INV'' ' ||
  					'AND  c.ORG_INFORMATION2 = ''Y''  ' ||
  					'AND ( c.ORG_INFORMATION_CONTEXT || '''') = ''CLASS'' ' ||
 					'AND ( c1.ORG_INFORMATION_CONTEXT || '''') =''Accounting Information''  ' ||
 					'AND c1.ORG_INFORMATION1 = TO_CHAR(GSOB.SET_OF_BOOKS_ID)'||v_rownum;
  	EXECUTE IMMEDIATE v_organization_string;


--    Check version of apps for existence of indivisible_flag
-- 	mtl_system_items.indivisible_flag and mtl_system_items.concatenated_segments do not exist in ver 10.

	v_versioned_string := ' INDIVISIBLE_FLAG';
	v_count := 0;

	BEGIN
      get_App_Info('INV', v_fndnam_link_name, v_inv_oracle_schema);
	v_string := 'select count(*) from all_tab_columns'||v_fndnam_link_name||
			' where owner='''||v_inv_oracle_schema||''' AND table_name like ''MTL_SYSTEM_ITEMS%''
				and column_name = ''INDIVISIBLE_FLAG''';
     		v_cur := dbms_sql.open_cursor;
     		dbms_sql.parse(v_cur, v_string, dbms_sql.native);
     		dbms_sql.define_column(v_cur,1,v_count);
     		v_res := dbms_sql.execute(v_cur);
		if (dbms_sql.fetch_rows(v_cur) > 0) then
			dbms_sql.column_value(v_cur,1,v_count);
		end if;
     		dbms_sql.close_cursor(v_cur);

		IF (v_count = 0) THEN
			-- version 10
			v_versioned_string := ' ''Y'' INDIVISIBLE_FLAG';
                        v_mtl_system_items_tl :='';
                        v_where_tl := '';
                        v_where_tl_2 :='';
                        v_where_lang_tl :='';
                        v_desc_tl := ' M.DESCRIPTION AS ITEM_DESC, ';
                        v_description_tl := ' M.DESCRIPTION, ';
                        v_language := ' ''' || userenv('LANG') || ''' AS LANGUAGE,';
		END IF;

	EXCEPTION
	 WHEN OTHERS THEN
		if (dbms_sql.is_open(v_cur)) then
			dbms_sql.close_cursor(v_cur);
		end if;
	 END;

--    Check version of apps for existence of comms_nl_trackable_flag in mtl_system_items

	v_trackable_flag := ' COMMS_NL_TRACKABLE_FLAG';
	BEGIN
      get_App_Info('INV', v_fndnam_link_name, v_inv_oracle_schema);
	v_string := 'select distinct column_name from all_tab_columns'||v_fndnam_link_name||
			' where owner='''||v_inv_oracle_schema||''' AND table_name like ''MTL_SYSTEM_ITEMS%'' and column_name = ''COMMS_NL_TRACKABLE_FLAG''';
	EXECUTE IMMEDIATE v_string INTO v_column_name;

	EXCEPTION
	 WHEN NO_DATA_FOUND THEN
		v_trackable_flag := ' ''N'' COMMS_NL_TRACKABLE_FLAG';
	 END;

--    Check version of apps for existence of ml_system_items_tl
    x_mtl_system_items_tl_exists := TRUE;
	BEGIN
      get_App_Info('INV', v_fndnam_link_name, v_inv_oracle_schema);
	v_string := 'select distinct table_name from all_tables'||v_fndnam_link_name||
			' where owner='''||v_inv_oracle_schema||''' AND table_name = ''MTL_SYSTEM_ITEMS_TL'' ';
	EXECUTE IMMEDIATE v_string INTO v_table_name;

	EXCEPTION
	 WHEN NO_DATA_FOUND THEN
		x_mtl_system_items_tl_exists := FALSE;
    END;

    -- Changed view definition by dropping local table for performance improvement. Ref:9446997

         IF  x_mtl_system_items_tl_exists THEN
             v_intl_text_string_1:= 'CREATE OR REPLACE VIEW CZ_EXV_INTL_TEXT  AS ' ||
                'SELECT distinct T.DESCRIPTION, T.LANGUAGE, T.SOURCE_LANG,  ' ||
                'B.COMPONENT_SEQUENCE_ID,B.COMMON_COMPONENT_SEQUENCE_ID, ' ||
                'B.TOP_ITEM_ID, B.EXPLOSION_TYPE, BBM.ORGANIZATION_ID,  ' ||
                'B.COMPONENT_ITEM_ID, B.BILL_SEQUENCE_ID, B.COMPONENT_CODE ' ||
            	'FROM BOM_EXPLOSIONS' || v_fndnam_link_name || ' B, ' ||
            	'BOM_BILL_OF_MATERIALS' || v_fndnam_link_name || ' BBM,  ' ||
                'MTL_SYSTEM_ITEMS_TL' || v_fndnam_link_name || ' T ' ||
            	'WHERE T.INVENTORY_ITEM_ID = B.COMPONENT_ITEM_ID ' ||
                'AND T.ORGANIZATION_ID = B.ORGANIZATION_ID ' ||
                'AND BBM.ORGANIZATION_ID = B.ORGANIZATION_ID ' ||
                'AND BBM.ASSEMBLY_ITEM_ID = B.TOP_ITEM_ID ' ||
                'AND BBM.BILL_SEQUENCE_ID = B.TOP_BILL_SEQUENCE_ID ' ||
            	'AND BBM.ALTERNATE_BOM_DESIGNATOR IS NULL ' ||
                'AND B.EXPLOSION_TYPE = ''OPTIONAL'' ' ||
                'AND T.LANGUAGE IN (SELECT language_code  ' ||
                                 '  FROM fnd_languages' || v_fndnam_link_name ||
                                 ' WHERE installed_flag IN (''B'', ''I''))';

            	EXECUTE IMMEDIATE v_intl_text_string_1;
         ELSE

             -- Usually this block is not executed as MTL_SYSTEM_ITEMS_TL always exist
             -- but otherwise need to fix this view as not able to make any join with fnd_languages table
             -- due to absence of language column in other tables
             v_intl_text_string_2:= 'CREATE OR REPLACE VIEW CZ_EXV_INTL_TEXT  AS ' ||
                'SELECT distinct T.DESCRIPTION, F.LANGUAGE_CODE, F.LANGUAGE_CODE AS SOURCE_LANG, ' ||
                'B.COMPONENT_SEQUENCE_ID,B.COMMON_COMPONENT_SEQUENCE_ID,  ' ||
                'B.TOP_ITEM_ID, B.EXPLOSION_TYPE, BBM.ORGANIZATION_ID,  ' ||
                'B.COMPONENT_ITEM_ID, B.BILL_SEQUENCE_ID, B.COMPONENT_CODE ' ||
            	'FROM BOM_EXPLOSIONS'|| v_fndnam_link_name || ' B, ' ||
            	'BOM_BILL_OF_MATERIALS'|| v_fndnam_link_name || ' BBM,  ' ||
                'MTL_SYSTEM_ITEMS'|| v_fndnam_link_name || ' T, ' ||
                'FND_LANGUAGES'|| v_fndnam_link_name || ' F ' ||
            	'WHERE T.INVENTORY_ITEM_ID = B.COMPONENT_ITEM_ID ' ||
                'AND T.ORGANIZATION_ID = B.ORGANIZATION_ID ' ||
                'AND BBM.ORGANIZATION_ID = B.ORGANIZATION_ID ' ||
                'AND BBM.ASSEMBLY_ITEM_ID = B.TOP_ITEM_ID ' ||
                'AND BBM.BILL_SEQUENCE_ID = B.TOP_BILL_SEQUENCE_ID ' ||
            	'AND BBM.ALTERNATE_BOM_DESIGNATOR IS NULL ' ||
                'AND B.EXPLOSION_TYPE = ''OPTIONAL'' ' ||
                'AND F.INSTALLED_FLAG in (''B'', ''I''))';

               	EXECUTE IMMEDIATE v_intl_text_string_2;
         END IF;

--    Check version of apps for existence of config_model_type in mtl_system_items

	v_config_model_type := ' CONFIG_MODEL_TYPE';
	BEGIN
      get_App_Info('INV', v_fndnam_link_name, v_inv_oracle_schema);
	v_string := 'select distinct column_name from all_tab_columns' || v_fndnam_link_name ||
			' where owner='''||v_inv_oracle_schema||''' AND table_name like ''MTL_SYSTEM_ITEMS%''  ' ||
			' and column_name = ''CONFIG_MODEL_TYPE''';
	EXECUTE IMMEDIATE v_string INTO v_column_name;

	EXCEPTION
	 WHEN NO_DATA_FOUND THEN
		v_config_model_type := ' '''' CONFIG_MODEL_TYPE';
	 END;

	v_mtl_system_items_string := 'CREATE OR REPLACE VIEW CZ_EXV_MTL_SYSTEM_ITEMS AS ' ||
				    ' SELECT M.INVENTORY_ITEM_ID,M.ORGANIZATION_ID,SEGMENT1,BOM_ITEM_TYPE, ' ||
 				    ' FIXED_LEAD_TIME,START_DATE_ACTIVE,END_DATE_ACTIVE, ' ||
	 			    ' CUSTOMER_ORDER_ENABLED_FLAG, '||v_desc_tl||
 				    ' INVENTORY_ITEM_STATUS_CODE,ITEM_CATALOG_GROUP_ID,CONCATENATED_SEGMENTS,' || v_versioned_string ||
				    ' FROM MTL_SYSTEM_ITEMS_KFV' || v_fndnam_link_name|| ' M ' ||v_mtl_system_items_tl||
                                      v_where_tl_2||v_where_lang_tl||v_rownum;
	EXECUTE IMMEDIATE v_mtl_system_items_string;

	v_item_master_string := 'CREATE OR REPLACE VIEW CZ_EXV_ITEM_MASTER AS ' ||
					'SELECT ' ||
 						'M.INVENTORY_ITEM_ID,B.ORGANIZATION_ID,M.SEGMENT1, ' ||
 						'M.FIXED_LEAD_TIME,M.START_DATE_ACTIVE,M.END_DATE_ACTIVE, ' ||
	 					'M.CUSTOMER_ORDER_ENABLED_FLAG, '||v_desc_tl||
 					      ' M.INVENTORY_ITEM_STATUS_CODE,M.ITEM_CATALOG_GROUP_ID,' || v_versioned_string ||
                                    ',M.CONCATENATED_SEGMENTS, ' ||
 				'		BBM.ASSEMBLY_ITEM_ID AS TOP_ITEM_ID,B.EXPLOSION_TYPE, ' ||
                                '                B.COMPONENT_SEQUENCE_ID,B.COMMON_COMPONENT_SEQUENCE_ID,B.COMPONENT_ITEM_ID, ' ||
 				'		B.PLAN_LEVEL,B.SORT_ORDER,B.CREATION_DATE,B.CREATED_BY,B.LAST_UPDATE_DATE, ' ||
	 			'		B.LAST_UPDATED_BY,B.OPTIONAL,B.MUTUALLY_EXCLUSIVE_OPTIONS,B.LOW_QUANTITY, ' ||
				'		B.HIGH_QUANTITY,B.COMPONENT_QUANTITY,B.PRIMARY_UOM_CODE,B.BOM_ITEM_TYPE, ' ||
				'		B.PICK_COMPONENTS_FLAG,B.DESCRIPTION,B.ASSEMBLY_ITEM_ID,B.COMPONENT_CODE, ' ||
				'		B.EFFECTIVITY_DATE,B.DISABLE_DATE,' || v_language || ' ' ||
				'		DECODE (M.BOM_ITEM_TYPE || M.PICK_COMPONENTS_FLAG, ''1Y'',''P'',''1N'',''A'','''')  ' ||
                                '    AS MODEL_TYPE, ' ||
						v_trackable_flag || ', ' || v_config_model_type ||
                                    ', 702 AS BOM_APPLICATION_ID, 401 AS INV_APPLICATION_ID, ' ||
                                '    DECODE (M.IB_ITEM_INSTANCE_CLASS,''LINK'',''1'',''0'') AS IB_LINK_ITEM_FLAG, ' ||
                                '    B.shippable_item_flag,  ' ||
                                '    M.mtl_transactions_enabled_flag,  ' ||
                                '    B.replenish_to_order_flag,  ' ||
                                '    M.serial_number_control_code  ' ||
				'	FROM BOM_EXPLOSIONS'|| v_fndnam_link_name || ' B,  ' ||
                              '     MTL_SYSTEM_ITEMS_KFV'|| v_fndnam_link_name || ' M, ' ||
                              '     BOM_BILL_OF_MATERIALS'|| v_fndnam_link_name || ' BBM '||v_mtl_system_items_tl||
                              ' WHERE M.INVENTORY_ITEM_ID(+) = B.COMPONENT_ITEM_ID ' ||
                              '    AND M.ORGANIZATION_ID(+) = B.ORGANIZATION_ID ' ||
                              '    AND BBM.ORGANIZATION_ID = B.ORGANIZATION_ID       ' ||
                              '    AND BBM.BILL_SEQUENCE_ID = B.TOP_BILL_SEQUENCE_ID ' ||
                              '    AND BBM.ALTERNATE_BOM_DESIGNATOR IS NULL '||v_where_tl||v_rownum;
	EXECUTE IMMEDIATE v_item_master_string;
        -- kdande; 10-Jan-2008; Bug 5934249; Added BOM_BILL_OF_MATERIALS to the FROM to improve the performance via join
	v_items_string := 'CREATE OR REPLACE VIEW CZ_EXV_ITEMS AS ' ||
				'SELECT M.INVENTORY_ITEM_ID, M.ORGANIZATION_ID, M.SEGMENT1, ' ||
 					'M.FIXED_LEAD_TIME, M.START_DATE_ACTIVE, M.END_DATE_ACTIVE, ' ||
 					'M.CUSTOMER_ORDER_ENABLED_FLAG,' || v_versioned_string ||', M.CONCATENATED_SEGMENTS, ' ||
 					'M.INVENTORY_ITEM_STATUS_CODE, M.ITEM_CATALOG_GROUP_ID, ' ||
 					'M.PRIMARY_UOM_CODE, M.BOM_ITEM_TYPE, ' ||v_description_tl || v_desc_tl ||
                                        ' B.TOP_ITEM_ID, B.EXPLOSION_TYPE, 401 AS INV_APPLICATION_ID  ' ||
				'FROM BOM_EXPLOSIONS'|| v_fndnam_link_name || ' B, ' ||
                                        'MTL_SYSTEM_ITEMS_KFV'|| v_fndnam_link_name || ' M ' ||
                                        ',BOM_BILL_OF_MATERIALS'|| v_fndnam_link_name || ' BBM ' ||
                                        localTable || v_mtl_system_items_tl ||
                                ' WHERE M.INVENTORY_ITEM_ID = B.COMPONENT_ITEM_ID ' ||
                                'AND B.top_item_id = BBM.assembly_item_id AND b.organization_id = BBM.organization_id ' ||
                                'AND bbm.alternate_bom_designator IS NULL AND b.top_bill_sequence_id = bbm.bill_sequence_id ' ||
                                'AND M.ORGANIZATION_ID = B.ORGANIZATION_ID' || v_where_tl || v_where_lang_tl || v_rownum;

	EXECUTE IMMEDIATE v_items_string;

/*
	v_addresses_string :=  'CREATE OR REPLACE VIEW CZ_EXV_ADDRESSES AS
					SELECT ADDRESS_ID,CUSTOMER_ID,ADDRESS1,ADDRESS2,ADDRESS3,ADDRESS4,COUNTRY,
					CITY,POSTAL_CODE,STATE,PROVINCE,COUNTY,BILL_TO_FLAG,SHIP_TO_FLAG
					FROM RA_ADDRESSES_ALL'|| v_fndnam_link_name || ' WHERE STATUS=''A'''||v_rownum;
	EXECUTE IMMEDIATE v_addresses_string;

	v_address_uses_string :='CREATE OR REPLACE VIEW CZ_EXV_ADDRESS_USES AS
					SELECT ADDRESS_ID,SITE_USE_CODE,WAREHOUSE_ID,SITE_USE_ID
					FROM RA_SITE_USES_ALL'|| v_fndnam_link_name || ' WHERE STATUS=''A'''||v_rownum;
	EXECUTE IMMEDIATE v_address_uses_string ;

	v_customers_string := 'CREATE OR REPLACE VIEW CZ_EXV_CUSTOMERS AS
					SELECT CUSTOMER_NAME,CUSTOMER_ID,PRICE_LIST_ID,CUSTOMER_CATEGORY_CODE,
					WAREHOUSE_ID,PRIMARY_SALESREP_ID
					FROM RA_CUSTOMERS'|| v_fndnam_link_name || ' WHERE STATUS=''A'''||v_rownum;
	EXECUTE IMMEDIATE v_customers_string;

	v_contacts_string := 'CREATE OR REPLACE VIEW CZ_EXV_CONTACTS AS
					SELECT C.CUSTOMER_ID,C.ADDRESS_ID,C.SALUTATION,C.LAST_NAME,C.FIRST_NAME,C.SUFFIX,
 					C.TITLE,C.PRIMARY_ROLE,C.EMAIL_ADDRESS,C.CONTACT_ID,P.PHONE_NUMBER PHONE,
 					R.PHONE_NUMBER FAX
					FROM RA_CONTACTS'|| v_fndnam_link_name || ' C,RA_PHONES'|| v_fndnam_link_name || ' P,
						RA_PHONES'|| v_fndnam_link_name || ' R
					WHERE C.CUSTOMER_ID=P.CUSTOMER_ID (+)
  						AND C.ADDRESS_ID=P.ADDRESS_ID   (+)
  						AND C.CONTACT_ID=P.CONTACT_ID   (+)
  						AND R.CUSTOMER_ID (+) =P.CUSTOMER_ID
  						AND R.ADDRESS_ID  (+) =P.ADDRESS_ID
  						AND R.CONTACT_ID  (+) =P.CONTACT_ID
  						AND R.PHONE_TYPE(+)=''FAX'' AND P.PHONE_TYPE (+)=''GEN''
  						AND C.STATUS=''A'''||v_rownum;
	EXECUTE IMMEDIATE v_contacts_string;

	v_price_list_string := 'CREATE OR REPLACE VIEW CZ_EXV_PRICE_LISTS AS
					SELECT  L.NAME,L.DESCRIPTION,L.CURRENCY_CODE,L.PRICE_LIST_ID
					FROM CZ_XFR_PRICE_LISTS P,SO_PRICE_LISTS'|| v_fndnam_link_name || ' L
					WHERE P.PRICE_LIST_ID=L.PRICE_LIST_ID
  						AND P.DELETED_FLAG=''0'''||v_rownum;
	EXECUTE IMMEDIATE v_price_list_string;

	v_price_list_line_string := 'CREATE OR REPLACE VIEW CZ_EXV_PRICE_LIST_LINES AS
						SELECT M.INVENTORY_ITEM_ID,M.ORGANIZATION_ID,
       					L.LIST_PRICE,L.PRICE_LIST_ID,L.PRICE_LIST_LINE_ID
						FROM CZ_ITEM_MASTERS I,MTL_SYSTEM_ITEMS'|| v_fndnam_link_name || ' M,
							SO_PRICE_LIST_LINES'|| v_fndnam_link_name || ' L
						WHERE M.INVENTORY_ITEM_ID=L.INVENTORY_ITEM_ID
							AND to_char(M.ORGANIZATION_ID)=substr(I.ORIG_SYS_REF,instr(I.ORIG_SYS_REF,'':'',-1,1)+1)
							AND to_char(M.INVENTORY_ITEM_ID)=substr(I.ORIG_SYS_REF,1,instr(I.ORIG_SYS_REF,'':'',1,1)-1)
							AND I.DELETED_FLAG=''0'''||v_rownum;
	EXECUTE IMMEDIATE v_price_list_line_string;

	v_end_user_string := 'CREATE OR REPLACE VIEW CZ_EXV_END_USER AS
					SELECT SALESREP_ID,ORG_ID,EMAIL_ADDRESS,NAME
					FROM RA_SALESREPS_ALL'|| v_fndnam_link_name || '
					WHERE STATUS=''A'''||v_rownum;
	EXECUTE IMMEDIATE v_end_user_string;

      --Bug #2323864 - this view is being replaced with the one below.

	v_item_property_values_string := 'CREATE OR REPLACE VIEW CZ_EXV_ITEM_PROPERTY_VALUES AS
							SELECT M.ELEMENT_NAME,M.ELEMENT_VALUE,M.INVENTORY_ITEM_ID,
							I.ORGANIZATION_ID,I.TOP_ITEM_ID,I.EXPLOSION_TYPE
							FROM CZ_EXV_ITEM_MASTER I,MTL_DESCR_ELEMENT_VALUES'|| v_fndnam_link_name || ' M
							WHERE M.INVENTORY_ITEM_ID=I.INVENTORY_ITEM_ID'||v_rownum;
*/

        v_item_property_values_string := 'CREATE OR REPLACE VIEW CZ_EXV_ITEM_PROPERTY_VALUES ' ||
                                         '    (ELEMENT_NAME, ELEMENT_VALUE, INVENTORY_ITEM_ID,  ORGANIZATION_ID) AS ' ||
                                         ' SELECT M.ELEMENT_NAME, M.ELEMENT_VALUE, M.INVENTORY_ITEM_ID, MTL.ORGANIZATION_ID ' ||
                                         '   FROM MTL_SYSTEM_ITEMS_KFV' || v_fndnam_link_name || ' MTL, ' ||
                                         '        MTL_DESCR_ELEMENT_VALUES' || v_fndnam_link_name || ' M ' ||
                                         '  WHERE M.INVENTORY_ITEM_ID = MTL.INVENTORY_ITEM_ID' || v_rownum;
	EXECUTE IMMEDIATE v_item_property_values_string;

	v_item_properties_string := 'CREATE OR REPLACE VIEW CZ_EXV_ITEM_PROPERTIES AS ' ||
						'SELECT ITEM_CATALOG_GROUP_ID,ELEMENT_NAME,DESCRIPTION ' ||
						'FROM MTL_DESCRIPTIVE_ELEMENTS'|| v_fndnam_link_name||v_where;
	EXECUTE IMMEDIATE v_item_properties_string;

	v_item_types_string := 'CREATE OR REPLACE VIEW CZ_EXV_ITEM_TYPES AS ' ||
					'SELECT ITEM_CATALOG_GROUP_ID,PARENT_CATALOG_GROUP_ID,DESCRIPTION,CATALOG_CONCAT_SEGS  ' ||
					'FROM MTL_ITEM_CATALOG_GROUPS_V'|| v_fndnam_link_name||v_where;
	EXECUTE IMMEDIATE v_item_types_string;

        v_bom_string := 'CREATE OR REPLACE VIEW cz_exv_descr_element_values AS ' ||
                        ' SELECT element_name, element_value ' ||
                        '   FROM mtl_descr_element_values' || v_fndnam_link_name ||' WHERE element_value IS NOT NULL' || v_rownum;
        EXECUTE IMMEDIATE v_bom_string;

	v_bom_string := 'CREATE OR REPLACE VIEW cz_exv_bom_explosions AS
			 SELECT organization_id, top_item_id, explosion_type, rexplode_flag
			   FROM bom_explosions' || v_fndnam_link_name || v_where;
	EXECUTE IMMEDIATE v_bom_string;

      BEGIN

      v_apc_props_string := 'CREATE OR REPLACE VIEW CZ_EXV_APC_PROPERTIES AS '||
        'SELECT attrgrps.attr_group_id,assocs.classification_code AS item_catalog_group_id,attrs.* '||
        'FROM EGO_ATTR_GROUPS_V'||v_fndnam_link_name||' attrgrps '||
        ',EGO_ATTRS_V'||v_fndnam_link_name||'  attrs '||
        ',EGO_OBJ_AG_ASSOCS_B'||v_fndnam_link_name||'  assocs '||
        ',EGO_ITMATTR_APPL_USGS_B'||v_fndnam_link_name||'  usgs '||
        ',FND_OBJECTS'||v_fndnam_link_name||' objs '||
        'WHERE objs.OBJ_NAME = ''EGO_ITEM'' '||
        'AND objs.OBJECT_ID = assocs.OBJECT_ID '||
        'AND assocs.ATTR_GROUP_ID = attrgrps.ATTR_GROUP_ID '||
        'AND attrgrps.ATTR_GROUP_TYPE = attrs.ATTR_GROUP_TYPE '||
        'AND attrgrps.ATTR_GROUP_NAME = attrs.ATTR_GROUP_NAME '||
        'AND attrs.APPLICATION_ID = 431 AND attrgrps.APPLICATION_ID = 431 '||
        'AND usgs.ATTR_ID = attrs.ATTR_ID '||
        'AND usgs.ENABLED_FLAG = ''Y'' '||
        'AND usgs.APPLICATION_ID = 708 AND attrgrps.attr_group_type=''EGO_ITEMMGMT_GROUP'' AND '||
        ' assocs.DATA_LEVEL=''ITEM_LEVEL'' AND attrs.ENABLED_FLAG=''Y'' '|| v_rownum;

      EXECUTE IMMEDIATE v_apc_props_string;

      v_apc_prop_values_string := 'CREATE OR REPLACE VIEW CZ_EXV_ITEM_APC_PROP_VALUES AS '||
         ' SELECT * FROM EGO_MTL_SY_ITEMS_EXT_VL'|| v_fndnam_link_name||' c '||
         ' WHERE EXISTS(SELECT NULL FROM CZ_EXV_APC_PROPERTIES a WHERE a.attr_group_id=c.attr_group_id) AND '||
         ' EXISTS(SELECT NULL FROM CZ_EXV_APC_PROPERTIES b WHERE b.item_catalog_group_id=c.item_catalog_group_id)' || v_rownum;

      v_apc_prop_values_string := 'CREATE OR REPLACE VIEW CZ_EXV_ITEM_APC_PROP_VALUES AS '||
        'SELECT * FROM EGO_MTL_SY_ITEMS_EXT_VL '|| v_fndnam_link_name||' c '||
        ' WHERE EXISTS '||
        '(SELECT NULL FROM '||
        'EGO_ATTR_GROUPS_V '||v_fndnam_link_name||' attrgrps '||
        ',EGO_ATTRS_V '||v_fndnam_link_name||' attrs '||
        ',EGO_ITMATTR_APPL_USGS_B '||v_fndnam_link_name||' usgs '||
        ',FND_OBJECTS '||v_fndnam_link_name||' objs '||
        'WHERE attrgrps.attr_group_id=c.attr_group_id  AND objs.OBJ_NAME = ''EGO_ITEM'' '||
        'AND attrgrps.ATTR_GROUP_TYPE = attrs.ATTR_GROUP_TYPE '||
        'AND attrgrps.ATTR_GROUP_NAME = attrs.ATTR_GROUP_NAME '||
        'AND attrs.APPLICATION_ID = 431 AND attrgrps.APPLICATION_ID = 431 '||
        'AND usgs.ATTR_ID = attrs.ATTR_ID '||
        'AND usgs.ENABLED_FLAG = ''Y'' '||
        'AND usgs.APPLICATION_ID = 708 AND attrgrps.attr_group_type=''EGO_ITEMMGMT_GROUP'' AND '||
        ' attrs.ENABLED_FLAG=''Y'') '||v_rownum;

      EXECUTE IMMEDIATE v_apc_prop_values_string;

      EXCEPTION
        WHEN OTHERS THEN

       	log_report('APC is not installed, stub views will be created.'||
                cz_utils.get_text('CZ_EXT_VIEW_CREATION_ERR_DTL','SQLERRM',Sqlerrm));

            v_apc_props_string :=
              'CREATE OR REPLACE VIEW CZ_EXV_APC_PROPERTIES AS  ' ||
             ' SELECT  ' ||
             ' -1   AS ATTR_GROUP_ID ' ||
             ' ,-1  AS ITEM_CATALOG_GROUP_ID ' ||
             ' ,-1  AS ATTR_ID               ' ||
             ' ,-1  AS APPLICATION_ID        ' ||
             ' ,-1  AS ATTR_GROUP_TYPE       ' ||
             ' ,''*'' AS ATTR_GROUP_NAME     ' ||
             ' ,''*'' AS ATTR_NAME           ' ||
             ' ,''*'' AS ATTR_DISPLAY_NAME   ' ||
             ' ,''*'' AS DESCRIPTION         ' ||
             ' ,''*'' AS DATABASE_COLUMN     ' ||
             ' ,''*'' AS DATA_TYPE_CODE      ' ||
             ' ,-1  AS SEQUENCE              ' ||
             ' ,''*'' AS UNIQUE_KEY_FLAG     ' ||
             ' ,''*'' AS DEFAULT_VALUE       ' ||
             ' ,''*'' AS INFO_1              ' ||
             ' ,''*'' AS UOM_CLASS           ' ||
             ' ,-1  AS CONTROL_LEVEL         ' ||
             ' ,-1  AS VALUE_SET_ID          ' ||
             ' ,''*'' AS VALUE_SET_NAME      ' ||
             ' ,''*'' AS FORMAT_CODE         ' ||
             ' ,-1  AS MAXIMUM_SIZE          ' ||
             ' ,''*'' AS VALIDATION_CODE     ' ||
             ' ,''*'' AS LONGLIST_FLAG       ' ||
             ' ,''*'' AS ENABLED_FLAG        ' ||
             ' ,''*'' AS ENABLED_MEANING     ' ||
             ' ,''*'' AS REQUIRED_FLAG       ' ||
             ' ,''*'' AS REQUIRED_MEANING    ' ||
             ' ,''*'' AS SEARCH_FLAG         ' ||
             ' ,''*'' AS SEARCH_MEANING      ' ||
             ' ,''*'' AS DISPLAY_CODE        ' ||
             ' ,''*'' AS DISPLAY_MEANING     ' ||
             ' ,''*'' AS ATTRIBUTE_CODE      ' ||
             ' ,''*'' AS VIEW_IN_HIERARCHY_CODE ' ||
             ' ,''*'' AS EDIT_IN_HIERARCHY_CODE ' ||
             ' ,''*'' AS CUSTOMIZATION_LEVEL  ' ||
             ' FROM dual';
        EXECUTE IMMEDIATE v_apc_props_string;

        v_apc_prop_values_string :=
             'CREATE OR REPLACE VIEW CZ_EXV_ITEM_APC_PROP_VALUES AS ' ||
             'SELECT  ' ||
             '-1   AS EXTENSION_ID                 ' ||
             ',-1  AS ORGANIZATION_ID              ' ||
             ',-1  AS INVENTORY_ITEM_ID            ' ||
             ',-1  AS REVISION_ID                  ' ||
             ',-1  AS ITEM_CATALOG_GROUP_ID        ' ||
             ',-1  AS ATTR_GROUP_ID                ' ||
             ',''*'' AS SOURCE_LANG                ' ||
             ',''*'' AS LANGUAGE                   ' ||
             'FROM dual';
        EXECUTE IMMEDIATE v_apc_prop_values_string;

      END;


	return v_success;

EXCEPTION
WHEN OTHERS THEN
	log_report(v_errorString || cz_utils.get_text('CZ_EXT_VIEW_CREATION_ERR_DTL','SQLERRM',Sqlerrm));
	return v_error;
END create_exv_views;

------------------------------------------------------------------------------

PROCEDURE recreate_exv_views
(p_link_status OUT NOCOPY VARCHAR2,
 p_db_link     OUT NOCOPY VARCHAR2,
 p_do_compile  IN  VARCHAR2 -- DEFAULT '1'
) IS
    v_code           VARCHAR2(1);
    v_import_enabled cz_servers.import_enabled%TYPE;
    v_local_name     cz_servers.local_name%TYPE;
BEGIN
    BEGIN
        SELECT local_name,fndnam_link_name,import_enabled
        INTO v_local_name,p_db_link,v_import_enabled FROM CZ_SERVERS
        WHERE import_enabled='1';

        ---- check DB Link ----
        p_link_status:=isLinkAlive(p_db_link);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             p_link_status:=LINK_IS_DOWN;
    END;

    IF  p_link_status=LINK_IS_DOWN  THEN

        ---- recreate views based on local tables ----
        v_code:=create_exv_views('ERROR');

        IF v_code='0' THEN
           p_link_status:=LINK_IS_DOWN;
        ELSE
           p_link_status:=v_code;
        END IF;

    END IF;

    IF p_link_status=LINK_WORKS THEN

        ---- recreate views based on remote tables ----
        v_code:=create_exv_views(v_local_name);

        IF v_code='0' THEN
           p_link_status:=LINK_WORKS;
        ELSE
           p_link_status:=v_code;
        END IF;
    END IF;

    IF  UPPER(p_do_compile) IN ('1','Y','YES') THEN
        compile_Dependents('CZ_IMP%');
    END IF;
    COMMIT;
EXCEPTION
  WHEN TOO_MANY_ROWS THEN
    log_report('recreate_exv_views: ' || CZ_UTILS.GET_TEXT('CZ_IMP_TOO_MANY_SERVERS'));
  WHEN OTHERS THEN
    log_report(SQLERRM);
END;

------------------------------------------------------------------------------

--------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
---------- recreate extraction views concurrent program

PROCEDURE recreate_exv_views_cp(errbuf  IN OUT NOCOPY VARCHAR2,
		                    retcode IN OUT NOCOPY INTEGER) IS
    v_views_status  VARCHAR2(1);
    v_db_link       CZ_SERVERS.fndnam_link_name%TYPE;
BEGIN
    retcode:=0;
    recreate_exv_views(v_views_status,v_db_link, 1);
    IF v_views_status=LINK_WORKS THEN
       errbuf:='';
    END IF;
    IF v_views_status=LINK_IS_DOWN THEN
       retcode:=2;
       errbuf:=CZ_UTILS.GET_TEXT('CZ_DB_LINK_IS_DOWN','DBLINK',v_db_link);
    END IF;
END;

------------------------------------------------------------------------------

--------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
---------- drop exv views

FUNCTION drop_exv_views

RETURN VARCHAR2
AS

v_bom_string				varchar2(4000);
v_item_master_string			varchar2(4000);
v_mtl_system_items_string 		varchar2(4000);
v_items_string				varchar2(4000);
v_addresses_string			varchar2(4000);
v_address_uses_string			varchar2(4000);
v_customers_string			varchar2(4000);
v_contacts_string				varchar2(4000);
v_price_list_string			varchar2(4000);
v_price_list_line_string		varchar2(4000);
v_end_user_string				varchar2(4000);
v_item_properties_string		varchar2(4000);
v_item_property_values_string		varchar2(4000);
v_item_types_string			varchar2(4000);
v_organization_string			varchar2(4000);
v_string					varchar2(4000);

v_success			char(1) := '0';
v_warning			char(1) := '1';
v_error			char(1) := '2';
v_errorString		VARCHAR2(1024) := 'DROP_EXV_VIEWS : ';

BEGIN

	v_bom_string := 'DROP VIEW CZ_EXV_BILL_OF_MATERIALS';
	EXECUTE IMMEDIATE v_bom_string;

	v_item_master_string := 'DROP VIEW CZ_EXV_ITEM_MASTER';
	EXECUTE IMMEDIATE v_item_master_string;

	v_organization_string := 'DROP VIEW CZ_EXV_ORGANIZATIONS';
	EXECUTE IMMEDIATE v_organization_string;

	v_mtl_system_items_string := 'DROP VIEW CZ_EXV_MTL_SYSTEM_ITEMS';
	EXECUTE IMMEDIATE v_mtl_system_items_string;

	v_items_string := 'DROP VIEW CZ_EXV_ITEMS';
	EXECUTE IMMEDIATE v_items_string;

	v_addresses_string :=  'DROP VIEW CZ_EXV_ADDRESSES';
	EXECUTE IMMEDIATE v_addresses_string;

	v_address_uses_string :='DROP VIEW CZ_EXV_ADDRESS_USES';
	EXECUTE IMMEDIATE v_address_uses_string ;

	v_customers_string := 'DROP VIEW CZ_EXV_CUSTOMERS';
	EXECUTE IMMEDIATE v_customers_string;

	v_contacts_string := 'DROP VIEW CZ_EXV_CONTACTS';
	EXECUTE IMMEDIATE v_contacts_string;

	v_price_list_string := 'DROP VIEW CZ_EXV_PRICE_LISTS';
	EXECUTE IMMEDIATE v_price_list_string;

	v_price_list_line_string := 'DROP VIEW CZ_EXV_PRICE_LIST_LINES';
	EXECUTE IMMEDIATE v_price_list_line_string;

	v_end_user_string := 'DROP VIEW CZ_EXV_END_USER';
	EXECUTE IMMEDIATE v_end_user_string;

	v_item_property_values_string := 'DROP VIEW CZ_EXV_ITEM_PROPERTY_VALUES';
	EXECUTE IMMEDIATE v_item_property_values_string;

	v_item_properties_string := 'DROP VIEW CZ_EXV_ITEM_PROPERTIES';
	EXECUTE IMMEDIATE v_item_properties_string;

	v_item_types_string := 'DROP VIEW CZ_EXV_ITEM_TYPES';
	EXECUTE IMMEDIATE v_item_types_string;

	v_bom_string := 'DROP VIEW CZ_EXV_BOM_EXPLOSIONS';
	EXECUTE IMMEDIATE v_bom_string;

	return v_success;

EXCEPTION
   WHEN OTHERS THEN
      log_report(v_errorString || cz_utils.get_text('CZ_DROP_EXT_VIEWS_ERR','SQLERRM',Sqlerrm));
      return v_error;
END drop_exv_views;


--------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
---------- to insert records into cz_servers

PROCEDURE populate_cz_server_cp( Errbuf  IN OUT NOCOPY  VARCHAR2,
 				    	Retcode IN OUT NOCOPY  PLS_INTEGER,
					LOCAL_NAME         IN  VARCHAR2
					,HOSTNAME          IN  VARCHAR2
					,DB_LISTENER_PORT  IN  NUMBER
					,INSTANCE_NAME     IN  VARCHAR2
					,FNDNAM            IN  VARCHAR2
					,GLOBAL_IDENTITY   IN  VARCHAR2
					,NOTES             IN  VARCHAR2
					,FNDNAM_LINK_NAME  IN  VARCHAR2
					,IMPORT_ENABLED    IN  VARCHAR2
					)
AS

v_hostname			cz_servers.hostname%TYPE;
v_db_listener_port 	cz_servers.db_listener_port%TYPE;
v_instance_name		cz_servers.instance_name%TYPE;
v_local_name		cz_servers.local_name%TYPE;
v_fndnam			cz_servers.fndnam%TYPE;
v_global_identity   	cz_servers.global_identity%TYPE;
v_notes		      cz_servers.notes%TYPE;
v_fndnam_link_name      cz_servers.fndnam_link_name%TYPE;
v_import_enabled        cz_servers.import_enabled%TYPE;

v_error_status 		VARCHAR2(4000) := '0';
v_success			char(1) := '0';
v_warning			char(1) := '1';
v_error			char(1) := '2';
x_error			BOOLEAN:=FALSE;
xerror			char(1);
v_errorString		VARCHAR2(1024) :='POPULATE_SERVER_CP : ';

v_server_count		NUMBER := 0;
v_server_id			NUMBER;
v_import_count		NUMBER := 0;
v_fnd_link_count		NUMBER := 0;
v_cursor			NUMBER;
v_NumRows			NUMBER;
v_dummy			NUMBER;
v_name			VARCHAR2(10);

v_createstring		varchar2(4000);
v_bom				varchar2(4000);
v_item_master		varchar2(4000);

BEGIN

	v_hostname 		  := LTRIM(RTRIM(HOSTNAME))	;
	v_instance_name	  := LTRIM(RTRIM(INSTANCE_NAME));
	v_db_listener_port  := DB_LISTENER_PORT  ;
	v_local_name	  := LTRIM(RTRIM(LOCAL_NAME));
      v_fndnam		  := LTRIM(RTRIM(FNDNAM));
	v_global_identity   := LTRIM(RTRIM(GLOBAL_IDENTITY));
	v_notes		  := LTRIM(RTRIM(NOTES));
      v_fndnam_link_name  := LTRIM(RTRIM(FNDNAM_LINK_NAME));
	v_import_enabled    := LTRIM(RTRIM(IMPORT_ENABLED));

	Errbuf := '';
	Retcode := 0;

	BEGIN
		SELECT count(*)
		INTO   v_server_count
		FROM   cz_servers
		WHERE   cz_servers.local_name = v_local_name
		OR (    cz_servers.hostname = v_hostname
		AND	 cz_servers.instance_name = v_instance_name
		AND	 cz_servers.db_listener_port = v_db_listener_port) ;
	EXCEPTION
	WHEN OTHERS THEN
		v_server_count := 0;
	END;

	IF (v_server_count = 0) THEN
		BEGIN

		SELECT decode(import_enabled,'Y','1','N','0','0')
		INTO v_import_enabled
		FROM dual;

		IF (v_import_enabled = '1') THEN
			SELECT count(*) INTO v_import_count FROM cz_servers
			WHERE import_enabled = '1';
			IF (V_IMPORT_count > 0) THEN
			   Errbuf := cz_utils.get_text('CZ_IMP_SERVER_EXISTS_DEF');
			   log_report(Errbuf);
			   Retcode := '2';
			   return;
			END IF;
		END IF;
		EXCEPTION
		WHEN OTHERS THEN
			v_import_count := 0;
		END;

		IF v_fndnam_link_name IS NOT NULL THEN
		BEGIN

                  v_dummy := doesLinkExist(v_fndnam_link_name);

			if (v_dummy > 0) THEN
			   errbuf := cz_utils.get_text('CZ_DB_LINK_EXISTS','LINKNAME',v_fndnam_link_name);
			   log_report(v_errorString ||  errbuf);
			   Retcode := '2';
			   return;
			END IF;
		EXCEPTION
		   WHEN OTHERS THEN
		      errbuf := cz_utils.get_text('CZ_DB_LINK_ERROR', 'SQLERRM', Sqlerrm);
		      log_report(v_errorString || errbuf);
		      Retcode := '2';
		      return;
		END;
		END IF;

		BEGIN
			SELECT cz_servers_s.NEXTVAL
			INTO	 v_server_id
			FROM   dual;
			FND_FILE.PUT_LINE(FND_FILE.LOG,'Inserting ' || v_server_id);
			INSERT INTO CZ_SERVERS (SERVER_LOCAL_ID,LOCAL_NAME, HOSTNAME, DB_LISTENER_PORT,
					  		INSTANCE_NAME, FNDNAM, GLOBAL_IDENTITY, NOTES,
					  		FNDNAM_LINK_NAME, IMPORT_ENABLED)
					VALUES (v_server_id,LOCAL_NAME, HOSTNAME, DB_LISTENER_PORT,
					  		INSTANCE_NAME, FNDNAM, V_GLOBAL_IDENTITY, NOTES,
					  		FNDNAM_LINK_NAME, v_IMPORT_ENABLED );
			COMMIT;
		EXCEPTION
		   WHEN OTHERS THEN
		      errbuf := cz_utils.get_text('CZ_CANNOT_INSERT_SERVER','SQLERRM',Sqlerrm);
		      v_error_status := SQLERRM;
		      log_report(v_errorString  || errbuf);
		      Retcode := '2';
		      return;
		END;
	 ELSE
		-- this message should have name of existing server with same configuration
		-- should change code to get the name of this server and add it to the message
		errbuf := cz_utils.get_text('CZ_SERVER_EXISTS_DEF');
		log_report(v_errorString || errbuf);
		Retcode := '0';
		return;
	END IF;

END populate_cz_server_cp;

---------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
----------proc for altering records into cz_servers

PROCEDURE alter_cz_server_cp( Errbuf IN OUT NOCOPY VARCHAR2,
		                  Retcode IN OUT NOCOPY PLS_INTEGER,
					LOCAL_NAME           IN  VARCHAR2,
					HOSTNAME          IN  VARCHAR2,
					DB_LISTENER_PORT  IN  NUMBER,
					INSTANCE_NAME     IN  VARCHAR2,
					FNDNAM            IN  VARCHAR2,
					GLOBAL_IDENTITY   IN  VARCHAR2,
					NOTES             IN  VARCHAR2,
					FNDNAM_LINK_NAME  IN  VARCHAR2,
					IMPORT_ENABLED    IN  VARCHAR2
					)
AS
v_error_status 		VARCHAR2(4000) := '0';
v_hostname			cz_servers.hostname%TYPE;
v_db_listener_port 	cz_servers.db_listener_port%TYPE;
v_instance_name		cz_servers.instance_name%TYPE;
v_local_name		cz_servers.local_name%TYPE;
v_fndnam			cz_servers.fndnam%TYPE;
v_global_identity   	cz_servers.global_identity%TYPE;
v_notes		      cz_servers.notes%TYPE;
v_fndnam_link_name      cz_servers.fndnam_link_name%TYPE;
v_import_enabled        cz_servers.import_enabled%TYPE;

v_server_count		NUMBER := 0;
v_server_id			NUMBER ;
v_import_count		NUMBER := 0;
v_dummy			NUMBER := 0;
v_name			VARCHAR2(10);
x_error			BOOLEAN:=FALSE;
xerror			char(1);
v_errorString		VARCHAR2(1024) :='ALTER_SERVER_CP: ';
v_createstring		varchar2(4000);

v_views_status          VARCHAR2(1);
v_db_link               CZ_SERVERS.fndnam_link_name%TYPE;

l_hostname			cz_servers.hostname%TYPE;
l_db_listener_port 	cz_servers.db_listener_port%TYPE;
l_instance_name		cz_servers.instance_name%TYPE;
l_fndnam			cz_servers.fndnam%TYPE;
l_global_identity   	cz_servers.global_identity%TYPE;
l_notes		      cz_servers.notes%TYPE;
l_fndnam_link_name	cz_servers.fndnam_link_name%TYPE;
l_import_enabled		cz_servers.import_enabled%TYPE;
matching_local_name	cz_servers.local_name%TYPE;

BEGIN

	v_hostname 		  := LTRIM(RTRIM(HOSTNAME))	;
	v_instance_name	  := LTRIM(RTRIM(INSTANCE_NAME));
	v_db_listener_port  := DB_LISTENER_PORT  ;
	v_local_name	  := LTRIM(RTRIM(LOCAL_NAME));
      v_fndnam		  := LTRIM(RTRIM(FNDNAM));
	v_global_identity   := LTRIM(RTRIM(GLOBAL_IDENTITY));
	v_notes		  := LTRIM(RTRIM(NOTES));
      v_fndnam_link_name  := upper(LTRIM(RTRIM(FNDNAM_LINK_NAME)));
	v_import_enabled    := LTRIM(RTRIM(IMPORT_ENABLED));
	Errbuf := NULL;
	Retcode := 0;

	BEGIN
		SELECT SERVER_LOCAL_ID,hostname,db_listener_port,instance_name,
			fndnam,global_identity,notes,upper(fndnam_link_name),import_enabled
		INTO  v_server_id,l_hostname,l_db_listener_port,l_instance_name,
			l_fndnam,l_global_identity,l_notes,l_fndnam_link_name,l_import_enabled
		FROM   cz_servers
		WHERE  cz_servers.local_name = v_local_name;

		BEGIN
			BEGIN
				SELECT decode(import_enabled,'Y','1','N','0','0')
				INTO v_import_enabled
				FROM dual;

				SELECT local_name into matching_local_name
				FROM cz_servers
				WHERE hostname = v_hostname
				AND	instance_name = v_instance_name
				AND	db_listener_port = v_db_listener_port
				AND	fndnam = v_fndnam
				AND	local_name <> v_local_name;
				IF (sql%FOUND) THEN
				   errbuf := cz_utils.get_text('CZ_SERVER_EXISTS_MOD','SVRNAME',matching_local_name);
				   log_report(v_errorString || errbuf);
				   Retcode := '2';
				   return;
				END IF;
			EXCEPTION
			WHEN OTHERS THEN
				null;
     			END;

			IF ( (upper(v_local_name) = 'LOCAL')
				and ((v_hostname <> l_hostname) or (v_db_listener_port <> l_db_listener_port)
					or (v_instance_name <> l_instance_name) or  (v_fndnam <> l_fndnam)
					or (v_global_identity <> l_global_identity) or  (v_notes <> l_notes)
					or (v_fndnam_link_name <> l_fndnam_link_name)) ) THEN
				   -- cannot alter anything other than import_enabled for Local entry
				   errbuf := cz_utils.get_text('CZ_IMP_ALTER_LOCAL_SERVER_ERR');
				   log_report(v_errorString || errbuf);
				   Retcode := '2';
				   return;
			END IF;

			IF (v_import_enabled = '1') THEN
			BEGIN
				SELECT count(*) INTO v_import_count FROM cz_servers
				WHERE import_enabled = '1'
				AND	local_name <> v_local_name;
				IF (V_IMPORT_count > 0) THEN
				   -- another server has import enabled, only one is allowed
				   errbuf := cz_utils.get_text('CZ_IMP_SERVER_EXISTS_MOD');
				   log_report(v_errorString || errbuf);
				   Retcode := '2';
				   return;
				END IF;
			EXCEPTION
			WHEN OTHERS THEN
			v_import_count := 0;
			END;
			END IF;

			BEGIN
			IF (  ((v_hostname <> l_hostname) or (v_db_listener_port <> l_db_listener_port)
					or (v_instance_name <> l_instance_name)
					or  (v_fndnam <> l_fndnam) or (v_fndnam_link_name <> l_fndnam_link_name)
					or ((v_import_enabled = '0') and (l_import_enabled = '1')) )
				and ((l_fndnam_link_name is NOT NULL)
					or (upper(v_local_name) = 'LOCAL'))  ) THEN

--				IF (l_fndnam_link_name is NOT NULL) THEN
				IF (v_fndnam_link_name <> l_fndnam_link_name) THEN
				BEGIN

                              v_dummy := doesLinkExist(l_fndnam_link_name);

					if (v_dummy > 0) then
						v_CreateString := 'drop database link ' || l_fndnam_link_name;
						EXECUTE IMMEDIATE v_CreateString;
						log_report(v_errorstring ||
							   cz_utils.get_text('CZ_DB_LINK_DROPPED','LINKNAME',
									     l_fndnam_link_name));
					END IF;
				EXCEPTION
				WHEN OTHERS THEN
					log_report(v_errorString ||
					cz_utils.get_text('CZ_DB_LINK_ERROR','SQLERRM',Sqlerrm));
					Retcode := '1';
				END;
				END IF;

				-- if import_enabled changes from 1 to 0, drop views
				IF ((v_import_enabled = '0') and (l_import_enabled = '1')
					and ((l_fndnam_link_name is NOT NULL)
						or (upper(v_local_name) = 'LOCAL')) ) THEN
				BEGIN
                              --
                              -- don't drop views       --
                              -- ( this is an old code )--
                              --
					--v_dummy := drop_exv_views;--

                              --
                              -- just recreate them instead --
                              --
                              xerror:= create_exv_views('ERROR');
					IF (xerror<> '0') THEN
				  		-- error has already been logged
						Retcode := '1';
					END IF;

				EXCEPTION
				WHEN OTHERS THEN
			 		Retcode := '2';
				 	errbuf := cz_utils.get_text('CZ_MOD_SERVER_ERR','SQLERRM',Sqlerrm);
				 	log_report(v_errorString|| errbuf);
					return;
     				END;
				END IF;
			END IF;
     			EXCEPTION
			WHEN OTHERS THEN
			   Retcode := '2';
			   errbuf := cz_utils.get_text('CZ_MOD_SERVER_ERR','SQLERRM',Sqlerrm);
			   log_report(v_errorString|| errbuf);
			   return;
     			END;

			BEGIN
			UPDATE CZ_SERVERS	SET
				LOCAL_NAME	= v_local_name,
				HOSTNAME = v_hostname,
				DB_LISTENER_PORT = v_db_listener_port,
				INSTANCE_NAME = v_instance_name,
      			FNDNAM 	       = v_fndnam		      ,
				GLOBAL_IDENTITY   = v_global_identity    ,
				NOTES		 = v_notes		      ,
	      		FNDNAM_LINK_NAME  = v_fndnam_link_name   ,
				IMPORT_ENABLED    = v_import_enabled
			WHERE  cz_servers.server_local_id = v_server_id ;
			EXCEPTION
			WHEN OTHERS THEN
			   Retcode := '2';
			   errbuf := cz_utils.get_text('CZ_MOD_SERVER_ERR','SQLERRM',Sqlerrm);
			   log_report(v_errorString|| errbuf);
			   return;
			END;

			-- if import_enabled changes from 0 to 1, for LOCAL entry, create views
			IF ((v_import_enabled = '1') and (l_import_enabled = '0')
				/*and (upper(v_local_name) = 'LOCAL')*/ ) THEN
			BEGIN
				xerror := create_exv_views(v_local_name);
				IF (xerror <> '0') THEN
				  	-- detailed error has already been logged
				   	errbuf := cz_utils.get_text('CZ_EXT_VIEW_CREATION_ERR');
				   	Retcode := '2';
				   	return;
				END IF;
			EXCEPTION
			WHEN OTHERS THEN
			 	Retcode := '2';
		      	errbuf := cz_utils.get_text('CZ_LINK_CREATION_ERR','SQLERRM',Sqlerrm);
			 	log_report(v_errorString|| errbuf);
				return;
     			END;
			END IF;

		EXCEPTION
		WHEN OTHERS THEN
			v_server_count := 0;
		END;
		COMMIT;

	EXCEPTION
	WHEN NO_DATA_FOUND THEN
	     errbuf := cz_utils.get_text('CZ_SERVER_NOT_EXIST','SVRNAME',v_local_name);
	     log_report(v_errorString || errbuf);
	     RetCode := '1';
	WHEN OTHERS THEN
	     Retcode := '2';
	     errbuf := cz_utils.get_text('CZ_LINK_CREATION_ERR','SQLERRM',Sqlerrm);
	     log_report(v_errorString|| errbuf);
	END;
END alter_cz_server_cp;


/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
------------------------------------------------------------------------------
PROCEDURE show_cz_servers_cp(Errbuf OUT NOCOPY VARCHAR2,
                     	  Retcode OUT NOCOPY NUMBER)
AS

CURSOR C_GETSERVERS IS
SELECT LOCAL_NAME, HOSTNAME, DB_LISTENER_PORT, INSTANCE_NAME,
SERVER_DB_VERSION, FNDNAM, GLOBAL_IDENTITY, NOTES,FNDNAM_LINK_NAME, Decode(IMPORT_ENABLED, '1', 'Y', '0','N',IMPORT_ENABLED)
FROM CZ_SERVERS
WHERE SERVER_LOCAL_ID >= 0;

lLocalName		CZ_SERVERS.LOCAL_NAME%TYPE;
lHostName		CZ_SERVERS.HOSTNAME%TYPE;
lDbListenerPort	CZ_SERVERS.DB_LISTENER_PORT%TYPE;
lInstanceName	CZ_SERVERS.INSTANCE_NAME%TYPE;
lServerDbVersion	CZ_SERVERS.SERVER_DB_VERSION%TYPE;
lFndNam		CZ_SERVERS.FNDNAM%TYPE;
lGlobalIdentity	CZ_SERVERS.GLOBAL_IDENTITY%TYPE;
lNotes		CZ_SERVERS.NOTES%TYPE;
lFndNamLinkName	CZ_SERVERS.FNDNAM_LINK_NAME%TYPE;
lImportEnabled	CZ_SERVERS.IMPORT_ENABLED%TYPE;

v_errorString	VARCHAR2(1024) :='SHOW_SERVERS_CP: ';

BEGIN
Errbuf:=NULL;
Retcode:=0;

OPEN C_GETSERVERS;
LOOP
	FETCH C_GETSERVERS INTO lLocalName,lHostName,lDbListenerPort,
		lInstanceName,lServerDbVersion,lFndNam,lGlobalIdentity,
		lNotes,lFndNamLinkName,lImportEnabled;
	EXIT WHEN C_GETSERVERS%NOTFOUND;

  	FND_FILE.PUT_LINE(FND_FILE.LOG,'Server Name='||lLocalName);
	FND_FILE.PUT_LINE(FND_FILE.LOG,'Host Name='||lHostName);
	FND_FILE.PUT_LINE(FND_FILE.LOG,'Port='||lDbListenerPort);
	FND_FILE.PUT_LINE(FND_FILE.LOG,'Instance Name='||lInstanceName);
	FND_FILE.PUT_LINE(FND_FILE.LOG,'Server Db Version='||lServerDbVersion);
	FND_FILE.PUT_LINE(FND_FILE.LOG,'FND Name='||lFndNam);
	FND_FILE.PUT_LINE(FND_FILE.LOG,'Global Name='||lGlobalIdentity);
	FND_FILE.PUT_LINE(FND_FILE.LOG,'Notes='||lNotes);
	FND_FILE.PUT_LINE(FND_FILE.LOG,'FND Link Name='||lFndNamLinkName);
--	FND_FILE.PUT_LINE(FND_FILE.LOG,'Import Enabled='||Decode(lImportEnabled, '1', 'Y', '0','N',lImportEnabled));
	FND_FILE.PUT_LINE(FND_FILE.LOG,'Import Enabled=' || lImportEnabled);
	FND_FILE.PUT_LINE(FND_FILE.LOG,'-------------------------------------');

END LOOP;
CLOSE C_GETSERVERS;
EXCEPTION
	WHEN OTHERS THEN
			  Errbuf:= cz_utils.get_text('CZ_SHOW_SERVERS_ERR','SQLERRM',Sqlerrm);
			  log_report(v_errorString || errbuf);
			  retcode := 2;
END show_cz_servers_cp;

------------------------------------------------------------------------------
FUNCTION create_remote_hgrid_view(p_server_id IN NUMBER, p_fndnam_link_name IN VARCHAR2)
  RETURN VARCHAR2 IS
  v_success		varchar2(1) := '0';
  v_error		varchar2(1) := '2';
  v_link_name     VARCHAR2(2000) := p_fndnam_link_name;
BEGIN

  IF(SUBSTR(v_link_name, 1, 1) = '@')THEN v_link_name := SUBSTR(v_link_name, 2); END IF;

  EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW cz_repos_folders_on_' || TO_CHAR(p_server_id) || '_v AS ' ||
                    'SELECT * FROM cz_repository_main_hgrid_v@' || v_link_name ||
                    ' WHERE object_type = ''FLD''';
  RETURN v_success;
EXCEPTION
  WHEN OTHERS THEN
    log_report(cz_utils.get_text('CZ_HGRID_VIEW_ERROR_DTL', 'ERRORTEXT', SQLERRM));
    RETURN v_error;
END;
---------- Create db link ----------------------------------------------------
PROCEDURE create_link_cp(Errbuf 	IN OUT NOCOPY VARCHAR2,
		          	Retcode 	IN OUT NOCOPY PLS_INTEGER,
				LOCAL_NAME	IN  VARCHAR2,
				PASSWORD	IN  VARCHAR2)
AS

v_hostname		 	cz_servers.hostname%TYPE;
v_instance_name	 	cz_servers.instance_name%TYPE;
v_db_listener_port	cz_servers.db_listener_port%TYPE;
v_fndnam			cz_servers.fndnam%TYPE;
v_fndnam_link_name	cz_servers.fndnam_link_name%TYPE;
v_local_name	 	cz_servers.local_name%TYPE;
v_server_db_version	cz_servers.server_db_version%TYPE;
v_import_enabled	 	cz_servers.import_enabled%TYPE;
v_server_id    	      cz_servers.server_local_id%TYPE;
v_cursor		 	NUMBER;
v_NumRows		 	NUMBER;
v_dummy		 	NUMBER;
xerror			char(1);
v_cur				integer;
v_res				integer;
v_link_status           VARCHAR2(1);
v_CreateString    	VARCHAR2(8000):=''  ;
v_dropString		VARCHAR2(8000) := '';
v_newString    		VARCHAR2(8000):=''  ;
v_errorString		VARCHAR2(1024) :='CREATE_LINK_CP: ';

BEGIN

     v_local_name	:= local_name;

     BEGIN
		SELECT hostname,
			 instance_name,
			 db_listener_port,
			 fndnam,
		 	 fndnam_link_name,
			 import_enabled,
                   server_local_id
		  INTO v_hostname,
			 v_instance_name,
			 v_db_listener_port,
			 v_fndnam,
			 v_fndnam_link_name,
			 v_import_enabled,
                   v_server_id
		 FROM  cz_servers
		 WHERE cz_servers.local_name = v_local_name;

		IF v_fndnam_link_name IS NOT NULL THEN
  		BEGIN

                  v_dummy := doesLinkExist(v_fndnam_link_name);

                  --
                  -- DB link already exists --
                  --
			IF (v_dummy > 0) THEN

                     --
                     -- check DB Link --
                     --
                     v_link_status:=isLinkAlive(v_fndnam_link_name);

            	   IF  v_link_status = LINK_IS_DOWN  THEN
                       errbuf := CZ_UTILS.GET_TEXT('CZ_DB_LINK_IS_DOWN','DBLINK',v_fndnam_link_name);
                       Retcode := 1;
                       RETURN;
                     END IF;

                     xerror := create_remote_hgrid_view(v_server_id, v_fndnam_link_name);

		         IF (xerror <> '0') THEN
			     -- detailed error has already been logged
			     Retcode := 2;
                     END IF;

  			   IF (v_import_enabled = '1') THEN

            	     xerror := create_exv_views(v_local_name);

			     IF (xerror <> '0') THEN
			       -- detailed error has already been logged
			       errbuf := cz_utils.get_text('CZ_EXT_VIEW_CREATION_ERR');
			       Retcode := 2;
			       return;
                       END IF;
                     END IF;

--			   errbuf := cz_utils.get_text('CZ_LINK_FOR_CREATION_EXISTS','LINKNAME',v_fndnam_link_name);
--			   log_report(v_errorString  || errbuf);
--			   retCode := 2;
--			   retCode := 1;
--			   return;
			ELSE
       			BEGIN
	  			v_CreateString     := 'create database link '||v_fndnam_link_name||' connect to '||v_fndnam||' identified by '||password||
                                                      ' using ''(DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = '||v_hostname||')(PORT = '||v_db_listener_port||'))(CONNECT_DATA = (SID = '||v_instance_name||')))''';
				EXECUTE IMMEDIATE v_CreateString;
 	      		EXCEPTION
		      	   WHEN OTHERS THEN
	                        errbuf := cz_utils.get_text('CZ_LINK_CREATION_ERR','SQLERRM',Sqlerrm);
                           	log_report(v_errorString || errbuf);
       				retCode := 2;
				return;
		      	END;

			BEGIN
		  		v_newString     := 'SELECT version INTO  :v_server_db_version  FROM V$INSTANCE@' || v_fndnam_link_name ;
--							|| ' WHERE database_status in (''ACTIVE'', ''OPEN'') ';
				v_cur := dbms_sql.open_cursor;
				dbms_sql.parse(v_cur,v_newString,dbms_sql.native);
				dbms_sql.define_column(v_cur,1,v_server_db_version,40);
				v_res:=dbms_sql.execute(v_cur);

				if (dbms_sql.fetch_rows(v_cur) > 0) then
					dbms_sql.column_value(v_cur,1,v_server_db_version);
				end if;
				dbms_sql.close_cursor(v_cur);
			EXCEPTION
			   WHEN OTHERS THEN
			        errbuf := cz_utils.get_text('CZ_DB_VERSION_NOT_FOUND', 'SQLERRM', Sqlerrm);
		 		Retcode := 1;
				log_report(v_errorString || errbuf);
			END;


			BEGIN
				UPDATE CZ_SERVERS	SET
					SERVER_DB_VERSION = v_server_db_version
				WHERE  cz_servers.local_name = v_local_name ;
				COMMIT;
			EXCEPTION
			   WHEN OTHERS THEN
			      errbuf := cz_utils.get_text('CZ_DB_VERSION_UPDATE_FAILURE', 'SQLERRM', Sqlerrm);
			      Retcode := 2;
			      log_report(v_errorString || errbuf);
			      return;
			END;
			END IF;

                  v_link_status:=isLinkAlive(v_fndnam_link_name);

                  IF v_link_status = LINK_IS_DOWN  THEN
                    errbuf :=CZ_UTILS.GET_TEXT('CZ_DB_LINK_IS_DOWN','DBLINK',v_fndnam_link_name);
                    Retcode := 2;
                    RETURN;
                  END IF;

                  xerror := create_remote_hgrid_view(v_server_id, v_fndnam_link_name);

		      IF (xerror <> '0') THEN
			  -- detailed error has already been logged
			  Retcode := 2;
                  END IF;

			IF(v_import_enabled = '1') THEN

			  IF (xerror <> '0') THEN
			    -- detailed error has already been logged
			    errbuf := cz_utils.get_text('CZ_EXT_VIEW_CREATION_ERR');
			    Retcode := 2;
			    RETURN;
			  END IF;
			END IF;

		EXCEPTION
		   WHEN OTHERS THEN
		      errbuf := cz_utils.get_text('CZ_LINK_CREATION_ERR','SQLERRM',Sqlerrm);
		      log_report(v_errorString || errbuf);
		      Retcode := 2;
		      return;
		END;
		END IF;
     EXCEPTION
	WHEN OTHERS THEN
	   errbuf := cz_utils.get_text('CZ_LINK_CREATION_ERR','SQLERRM',Sqlerrm);
	   log_report(v_errorString || errbuf);
	   Retcode := 2;
	   return;
     END;
END create_link_cp;
------------------------------------------------------------------------------

--Register Maintain server concurrent process


PROCEDURE register_maint_server_process
(application_name  IN VARCHAR2 , -- default 'Oracle Configurator',
 Request_Group     IN VARCHAR2 default NULL,
 cz_schema         IN VARCHAR2 default NULL)
AS

var_schema           VARCHAR2(40);
ar_application_name  VARCHAR2(50):='Oracle Configurator';
ar_request_group     VARCHAR2(50):=NULL;
creation_failure     EXCEPTION;
exec_exists          EXCEPTION;
no_req_group         EXCEPTION;

BEGIN


BEGIN
register_spx_process('Enable Remote Server',
                    'CZCREATELNK',
                    application_name,
                    'Enable Remote Server for Configurator',
                    'CZ_ORAAPPS_INTEGRATE.CREATE_LINK_CP',
                    request_group,
                    cz_schema);
fnd_program.parameter(program_short_name=>'CZCREATELNK',
                      application=>application_name,
                      sequence=>1,
                      parameter=>'LOCAL_NAME',
                      description=>'Local Name',
                      value_set=>'40 Chars',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'Server Local name');
fnd_program.parameter(program_short_name=>'CZCREATELNK',
                      application=>application_name,
                      sequence=>1,
                      parameter=>'PASSWORD',
                      description=>'Password',
                      value_set=>'40 Chars',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'Password');

EXCEPTION
WHEN OTHERS THEN
     LOG_REPORT('Error : < Enable Remote Server for Configurator > REGISTRATION');
END;


BEGIN
register_spx_process('Define Remote Server',
                    'CZPOPULATESRV',
                    application_name,
                    'Define Remote Server',
                    'CZ_ORAAPPS_INTEGRATE.POPULATE_CZ_SERVER_CP',
                    request_group,
                    cz_schema);
fnd_program.parameter(program_short_name=>'CZPOPULATESRV',
                      application=>application_name,
                      sequence=>1,
                      parameter=>'LOCAL_NAME',
                      description=>'Local Name',
                      value_set=>'40 Chars',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'Local name');
fnd_program.parameter(program_short_name=>'CZPOPULATESRV',
                      application=>application_name,
                      sequence=>2,
                      parameter=>'HOSTNAME',
                      description=>'Host Name',
                      value_set=>'90 Characters',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'Host name');
fnd_program.parameter(program_short_name=>'CZPOPULATESRV',
                      application=>application_name,
                      sequence=>3,
                      parameter=>'DB_LISTENER_PORT',
                      description=>'DB Listener Port',
                      value_set=>'9 Number',
                      display_size=>10,
                      description_size=>10,
                      concatenated_description_size=>10,
                      prompt=>'DB Listener Port');
fnd_program.parameter(program_short_name=>'CZPOPULATESRV',
                      application=>application_name,
                      sequence=>4,
                      parameter=>'INSTANCE_NAME',
                      description=>'Instance Name',
                      value_set=>'40 Chars',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'Instance name');
fnd_program.parameter(program_short_name=>'CZPOPULATESRV',
                      application=>application_name,
                      sequence=>5,
                      parameter=>'FNDNAM',
                      description=>'FND Name',
                      value_set=>'40 Chars',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'Oracle Applications Schema Name (FNDNAM)');
fnd_program.parameter(program_short_name=>'CZPOPULATESRV',
                      application=>application_name,
                      sequence=>6,
                      parameter=>'GLOBAL_IDENTITY',
                      description=>'Global Identity',
                      value_set=>'90 Characters',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'Global Identity');
fnd_program.parameter(program_short_name=>'CZPOPULATESRV',
                      application=>application_name,
                      sequence=>7,
                      parameter=>'NOTES',
                      description=>'Notes',
                      value_set=>'90 Characters',
                      display_size=>50,
                      description_size=>50,
                      concatenated_description_size=>50,
                      prompt=>'Description');
fnd_program.parameter(program_short_name=>'CZPOPULATESRV',
                      application=>application_name,
                      sequence=>8,
                      parameter=>'FND_LINK_NAME',
                      description=>'FND Link Name',
                      value_set=>'40 Chars',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'FND Link Name');
fnd_program.parameter(program_short_name=>'CZPOPULATESRV',
                      application=>application_name,
                      sequence=>9,
                      parameter=>'IMPORT_ENABLED',
                      description=>'Import Enabled',
                      value_set=>'CZ_ENABLE_FLAG',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'Import Enabled');

EXCEPTION
WHEN OTHERS THEN
     LOG_REPORT('Error : < Define Remote Server > REGISTRATION');
END;

BEGIN
register_spx_process('Modify Server Definition',
                    'CZALTERSERVER',
                    application_name,
                    'Modify Remote Server',
                    'CZ_ORAAPPS_INTEGRATE.ALTER_CZ_SERVER_CP',
                    request_group,
                    cz_schema);

fnd_program.parameter(program_short_name=>'CZALTERSERVER',
                      application=>application_name,
                      sequence=>1,
                      parameter=>'LOCAL_NAME',
                      description=>'Local Name',
                      value_set=>'40 Chars',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'Local name');
fnd_program.parameter(program_short_name=>'CZALTERSERVER',
                      application=>application_name,
                      sequence=>2,
                      parameter=>'HOSTNAME',
                      description=>'Host Name',
                      value_set=>'90 Characters',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'Host name');
fnd_program.parameter(program_short_name=>'CZALTERSERVER',
                      application=>application_name,
                      sequence=>3,
                      parameter=>'DB_LISTENER_PORT',
                      description=>'DB Listener Port',
                      value_set=>'9 Number',
                      display_size=>10,
                      description_size=>10,
                      concatenated_description_size=>10,
                      prompt=>'DB Listener Port');
fnd_program.parameter(program_short_name=>'CZALTERSERVER',
                      application=>application_name,
                      sequence=>4,
                      parameter=>'INSTANCE_NAME',
                      description=>'Instance Name',
                      value_set=>'40 Chars',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'Instance name');
fnd_program.parameter(program_short_name=>'CZALTERSERVER',
                      application=>application_name,
                      sequence=>5,
                      parameter=>'FNDNAM',
                      description=>'FND Name',
                      value_set=>'40 Chars',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'Oracle Applications Schema Name (FNDNAM)');
fnd_program.parameter(program_short_name=>'CZALTERSERVER',
                      application=>application_name,
                      sequence=>6,
                      parameter=>'GLOBAL_IDENTITY',
                      description=>'Global Identity',
                      value_set=>'90 Characters',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'Global Identity');
fnd_program.parameter(program_short_name=>'CZALTERSERVER',
                      application=>application_name,
                      sequence=>7,
                      parameter=>'NOTES',
                      description=>'Notes',
                      value_set=>'90 Characters',
                      display_size=>50,
                      description_size=>50,
                      concatenated_description_size=>50,
                      prompt=>'Description');
fnd_program.parameter(program_short_name=>'CZALTERSERVER',
                      application=>application_name,
                      sequence=>8,
                      parameter=>'FND_LINK_NAME',
                      description=>'FND Link Name',
                      value_set=>'40 Chars',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'FND Link Name');
fnd_program.parameter(program_short_name=>'CZALTERSERVER',
                      application=>application_name,
                      sequence=>9,
                      parameter=>'IMPORT_ENABLED',
                      description=>'Import Enabled',
                      value_set=>'CZ_ENABLE_FLAG',
                      display_size=>20,
                      description_size=>20,
                      concatenated_description_size=>50,
                      prompt=>'Import Enabled');
EXCEPTION
WHEN OTHERS THEN
     LOG_REPORT('Error : < Modify Remote Server > REGISTRATION');
END;

BEGIN
register_spx_process('View Servers',
                    'CZSHOWSERVERS',
                    application_name,
                    'Show Remote Servers',
                    'CZ_ORAAPPS_INTEGRATE.SHOW_CZ_SERVERS_CP',
                    request_group,
                    cz_schema);
EXCEPTION
WHEN OTHERS THEN
     LOG_REPORT('Error : < Show Remote Servers > REGISTRATION');
END;

END;


------------------------------------------------------------------------------------------

PROCEDURE RefreshSingleModel_cp
(errbuf           OUT NOCOPY VARCHAR2,
 retcode          OUT NOCOPY NUMBER,
 iFolder_ID       IN NUMBER,
 iModel_Id        IN VARCHAR2,
 COPY_CHILD_MODELS IN VARCHAR2 DEFAULT '0')

AS

lOrg_Id	       CZ_XFR_PROJECT_BILLS.ORGANIZATION_ID%TYPE;
lTop_Id            CZ_XFR_PROJECT_BILLS.TOP_ITEM_ID%TYPE;
lCopy_Child_Models PLS_INTEGER;

v_link_status      VARCHAR2(1);
v_code             VARCHAR2(1);
v_db_link          cz_servers.fndnam_link_name%TYPE;
v_local_name       cz_servers.local_name%TYPE;
v_import_enabled   cz_servers.import_enabled%TYPE;
v_ret  BOOLEAN := false;

BEGIN
 retcode:=0;
 errbuf:='';

     BEGIN
	SELECT rtrim(substr(orig_sys_ref,instr(orig_sys_ref,':',1,1)+1,length(substr(orig_sys_ref,instr(orig_sys_ref,':',1,1)+1)) -
							length(substr(orig_sys_ref,instr(orig_sys_ref,':',1,2)))  )) ,
		rtrim(substr(orig_sys_ref,instr(orig_sys_ref,':',1,2)+1))
	INTO lOrg_Id, lTop_Id
	FROM cz_devl_projects
	WHERE devl_project_id = iModel_Id
	AND	deleted_flag = '0';

	select decode(copy_child_models,'Y',0,'N',1,0) into lCopy_Child_Models from dual;

     EXCEPTION
	WHEN NO_DATA_FOUND THEN
           RAISE CZ_ADMIN.IMP_MODEL_NOT_FOUND;
     END;

     BEGIN
        SELECT local_name,fndnam_link_name,import_enabled
        INTO v_local_name,v_db_link,v_import_enabled FROM CZ_SERVERS
        WHERE import_enabled='1';
     EXCEPTION
       WHEN TOO_MANY_ROWS THEN
         RAISE CZ_ADMIN.IMP_TOO_MANY_SERVERS;
       WHEN NO_DATA_FOUND THEN
         RAISE CZ_ADMIN.IMP_NO_IMP_SERVER;
     END;

      ---- check DB Link ----
      v_link_status:=isLinkAlive(v_db_link);

      IF v_link_status=LINK_IS_DOWN THEN
         RAISE CZ_ADMIN.IMP_LINK_IS_DOWN;
      ELSE
         ---- recreate views based on remote tables ----
         v_code:=create_exv_views(v_local_name);
         compile_Dependents('CZ_IMP%');

         EXECUTE IMMEDIATE
	   'BEGIN cz_imp_all.goSingleBill_cp(CZ_ORAAPPS_INTEGRATE.mERRBUF,CZ_ORAAPPS_INTEGRATE.mRETCODE'||
         ',:lORG_ID,:lTOP_ID,:lCOPY_CHILD_MODELS,:iMODEL_ID); END;'
         USING lORG_ID,lTOP_ID,lCOPY_CHILD_MODELS,iMODEL_ID;

         errbuf:=CZ_ORAAPPS_INTEGRATE.mERRBUF;
         retcode:=CZ_ORAAPPS_INTEGRATE.mRETCODE;
      END IF;

EXCEPTION
  WHEN CZ_ADMIN.IMP_ACTIVE_SESSION_EXISTS THEN
     retcode:=2;
     errbuf := cz_utils.get_text('CZ_IMP_ACTIVE_SESSION_EXISTS');
     v_ret:=CZ_UTILS.log_report(errbuf,1,'CZ_ORAAPPS_INTEGRATE.RefreshSingleModel_cp',11276,NULL);
  WHEN CZ_ADMIN.IMP_TOO_MANY_SERVERS THEN
     retcode:=2;
     errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_TOO_MANY_SERVERS');
     v_ret:=CZ_UTILS.log_report(errbuf,1,'CZ_ORAAPPS_INTEGRATE.RefreshSingleModel_cp',11276,NULL);
  WHEN CZ_ADMIN.IMP_NO_IMP_SERVER THEN
     retcode:=2;
     errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_NO_SERVERS');
     v_ret:=CZ_UTILS.log_report(errbuf,1,'CZ_ORAAPPS_INTEGRATE.RefreshSingleModel_cp',11276,NULL);
  WHEN CZ_ADMIN.IMP_LINK_IS_DOWN THEN
     retcode:=2;
     errbuf :=CZ_UTILS.GET_TEXT('CZ_DB_LINK_IS_DOWN','DBLINK',v_db_link);
     v_ret:=CZ_UTILS.log_report(errbuf,1,'CZ_ORAAPPS_INTEGRATE.RefreshSingleModel_cp',11276,NULL);
   WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
     retcode:=2;
     errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_MAXERR_REACHED');
     v_ret:=CZ_UTILS.log_report(errbuf,1,'CZ_ORAAPPS_INTEGRATE.RefreshSingleModel_cp',11276,NULL);
  WHEN CZ_ADMIN.IMP_MODEL_NOT_FOUND THEN
     retcode:=2;
     errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_MODEL_NOT_FOUND', 'MODELID', iModel_Id);
     v_ret:=CZ_UTILS.log_report(errbuf,1,'CZ_ORAAPPS_INTEGRATE.RefreshSingleModel_cp',11276,NULL);
  WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
     retcode:=2;
     errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED','ERRORTEXT',SQLERRM);
     v_ret:=CZ_UTILS.log_report(errbuf,1,'CZ_ORAAPPS_INTEGRATE.RefreshSingleModel_cp',11276,NULL);
  WHEN OTHERS THEN
     retcode:=2;
     errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED','ERRORTEXT',SQLERRM);
     v_ret:=CZ_UTILS.log_report(errbuf,1,'CZ_ORAAPPS_INTEGRATE.RefreshSingleModel_cp',11276,NULL);
END RefreshSingleModel_cp;

------------------------------------------------------------------------------------------
PROCEDURE RemoveModel_cp
(errbuf         OUT NOCOPY VARCHAR2,
 retcode        OUT NOCOPY NUMBER,
 iFolder_ID     IN  NUMBER,
 iModel_Id      IN  VARCHAR2,
 iImportEnabled IN  VARCHAR2) IS

BEGIN
 retcode:=0;
 errbuf:='';

 UPDATE cz_xfr_project_bills
	SET  deleted_flag=Decode(iImportEnabled, 'Y', '0', 'N', '1', iImportEnabled)
	WHERE model_ps_node_id = iModel_Id;

 COMMIT;

EXCEPTION
  WHEN CZ_ADMIN.IMP_ACTIVE_SESSION_EXISTS THEN
     retcode:=2;
     errbuf := cz_utils.get_text('CZ_IMP_ACTIVE_SESSION_EXISTS');
     log_report('REMOVEMODEL_CP: ' || errbuf);
  WHEN OTHERS THEN
     retcode:=2;
     errbuf:=cz_utils.get_text('CZ_IMP_CHANGE_PARAMS_ERR','SQLERRM',sqlerrm);
     log_report('REMOVEMODEL_CP: ' || errbuf);
END;

------------------------------------------------------------------------------------------

PROCEDURE go_cp
(errbuf         OUT NOCOPY VARCHAR2,
 retcode        OUT NOCOPY NUMBER ) IS
    v_link_status    VARCHAR2(1);
    v_code           VARCHAR2(1);
    v_ret            BOOLEAN:=FALSE;
    v_db_link        cz_servers.fndnam_link_name%TYPE;
    v_local_name     cz_servers.local_name%TYPE;
    v_import_enabled cz_servers.import_enabled%TYPE;
BEGIN
    BEGIN
      SELECT local_name,fndnam_link_name,import_enabled
      INTO v_local_name,v_db_link,v_import_enabled FROM CZ_SERVERS
      WHERE import_enabled='1';
    EXCEPTION
      WHEN TOO_MANY_ROWS THEN
        RAISE CZ_ADMIN.IMP_TOO_MANY_SERVERS;
      WHEN NO_DATA_FOUND THEN
        RAISE CZ_ADMIN.IMP_NO_IMP_SERVER;
    END;

    ---- check DB Link ----
    v_link_status:=isLinkAlive(v_db_link);

    IF v_link_status=LINK_IS_DOWN THEN
       RAISE CZ_ADMIN.IMP_LINK_IS_DOWN;
    ELSE
       v_code:=create_exv_views(v_local_name);
       compile_Dependents('CZ_IMP%');
       EXECUTE IMMEDIATE
       'BEGIN CZ_IMP_ALL.GO_CP(CZ_ORAAPPS_INTEGRATE.mERRBUF,CZ_ORAAPPS_INTEGRATE.mRETCODE); END;';
       errbuf :=CZ_ORAAPPS_INTEGRATE.mERRBUF;
       retcode:=CZ_ORAAPPS_INTEGRATE.mRETCODE;
    END IF;
EXCEPTION
  WHEN CZ_ADMIN.IMP_ACTIVE_SESSION_EXISTS THEN
    retcode:=2;
    errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_ACTIVE_SESSION_EXISTS');
    v_ret:=CZ_UTILS.log_report(errbuf,1,'CZ_ORAAPPS_INTEGRATE.go_cp',11276,NULL);
  WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
    retcode:=2;
    errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_MAXERR_REACHED');
    v_ret:=CZ_UTILS.log_report(errbuf,1,'CZ_ORAAPPS_INTEGRATE.go_cp',11276,NULL);
  WHEN CZ_ADMIN.IMP_TOO_MANY_SERVERS THEN
     retcode:=2;
     errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_TOO_MANY_SERVERS');
     v_ret:=CZ_UTILS.log_report(errbuf,1,'CZ_ORAAPPS_INTEGRATE.go_cp',11276,NULL);
  WHEN CZ_ADMIN.IMP_NO_IMP_SERVER THEN
     retcode:=2;
     errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_NO_SERVERS');
     v_ret:=CZ_UTILS.log_report(errbuf,1,'CZ_ORAAPPS_INTEGRATE.go_cp',11276,NULL);
  WHEN CZ_ADMIN.IMP_LINK_IS_DOWN THEN
     retcode:=2;
     errbuf :=CZ_UTILS.GET_TEXT('CZ_DB_LINK_IS_DOWN','DBLINK',v_db_link);
     v_ret:=CZ_UTILS.log_report(errbuf,1,'CZ_ORAAPPS_INTEGRATE.go_cp',11276,NULL);
  WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
     retcode:=2;
     errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED','ERRORTEXT',SQLERRM);
     v_ret:=CZ_UTILS.log_report(errbuf,1,'CZ_ORAAPPS_INTEGRATE.go_cp',11276,NULL);
  WHEN OTHERS THEN
     retcode:=2;
     errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED','ERRORTEXT',SQLERRM);
     v_ret:=CZ_UTILS.log_report(errbuf,1,'CZ_ORAAPPS_INTEGRATE.go_cp',11276,NULL);
END;

------------------------------------------------------------------------------------------

PROCEDURE PopulateModels_cp
(errbuf             OUT NOCOPY VARCHAR2,
 retcode            OUT NOCOPY NUMBER,
 sOrg_ID            IN  VARCHAR2,
 dsOrg_ID           IN  VARCHAR2,
 sFrom              IN  VARCHAR2,
 sTo                IN  VARCHAR2,
 COPY_CHILD_MODELS  IN  VARCHAR2 DEFAULT '0') IS
    v_link_status    VARCHAR2(1);
    v_code           VARCHAR2(1);
    v_ret            BOOLEAN:=FALSE;
    v_db_link        cz_servers.fndnam_link_name%TYPE;
    v_local_name     cz_servers.local_name%TYPE;
    v_import_enabled cz_servers.import_enabled%TYPE;
BEGIN
   BEGIN
      SELECT local_name,fndnam_link_name,import_enabled
      INTO v_local_name,v_db_link,v_import_enabled FROM CZ_SERVERS
      WHERE import_enabled='1';
   EXCEPTION
     WHEN TOO_MANY_ROWS THEN
       RAISE CZ_ADMIN.IMP_TOO_MANY_SERVERS;
     WHEN NO_DATA_FOUND THEN
       RAISE CZ_ADMIN.IMP_NO_IMP_SERVER;
   END;

    ---- check DB Link ----
    v_link_status:=isLinkAlive(v_db_link);

    IF v_link_status=LINK_IS_DOWN THEN
       RAISE CZ_ADMIN.IMP_LINK_IS_DOWN;
    ELSE
       v_code:=create_exv_views(v_local_name);
       compile_Dependents('CZ_IMP%');

       EXECUTE IMMEDIATE
       'BEGIN CZ_IMP_ALL.PopulateModels_cp(CZ_ORAAPPS_INTEGRATE.mERRBUF,CZ_ORAAPPS_INTEGRATE.mRETCODE,'||
       ':sOrg_ID,:dsOrg_ID,:sFrom,:sTo,:COPY_CHILD_MODELS); END;'
       USING sOrg_ID,dsOrg_ID,sFrom,sTo,COPY_CHILD_MODELS;
       errbuf :=CZ_ORAAPPS_INTEGRATE.mERRBUF;
       retcode:=CZ_ORAAPPS_INTEGRATE.mRETCODE;
    END IF;
EXCEPTION
  WHEN CZ_ADMIN.IMP_ACTIVE_SESSION_EXISTS THEN
     retcode:=2;
     errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_ACTIVE_SESSION_EXISTS');
     v_ret:=CZ_UTILS.log_report(errbuf,1,'CZ_ORAAPPS_INTEGRATE.PopulateModels_cp',11276,NULL);
  WHEN CZ_ADMIN.IMP_MAXERR_REACHED THEN
     retcode:=2;
     errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_MAXERR_REACHED');
     v_ret:=CZ_UTILS.log_report(errbuf,1,'CZ_ORAAPPS_INTEGRATE.PopulateModels_cp',11276,NULL);
  WHEN CZ_ADMIN.IMP_TOO_MANY_SERVERS THEN
     retcode:=2;
     errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_TOO_MANY_SERVERS');
     v_ret:=CZ_UTILS.log_report(errbuf,1,'CZ_ORAAPPS_INTEGRATE.PopulateModels_cp',11276,NULL);
  WHEN CZ_ADMIN.IMP_NO_IMP_SERVER THEN
     retcode:=2;
     errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_NO_SERVERS');
     v_ret:=CZ_UTILS.log_report(errbuf,1,'CZ_ORAAPPS_INTEGRATE.PopulateModels_cp',11276,NULL);
  WHEN CZ_ADMIN.IMP_LINK_IS_DOWN THEN
     retcode:=2;
     errbuf :=CZ_UTILS.GET_TEXT('CZ_DB_LINK_IS_DOWN','DBLINK',v_db_link);
     v_ret:=CZ_UTILS.log_report(errbuf,1,'CZ_ORAAPPS_INTEGRATE.PopulateModels_cp',11276,NULL);
  WHEN CZ_ADMIN.IMP_UNEXP_SQL_ERROR THEN
     retcode:=2;
     errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED','ERRORTEXT',SQLERRM);
     v_ret:=CZ_UTILS.log_report(errbuf,1,'CZ_ORAAPPS_INTEGRATE.PopulateModels_cp',11276,NULL);
WHEN OTHERS THEN
     retcode:=2;
     errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_OPERATION_FAILED','ERRORTEXT',SQLERRM);
     v_ret:=CZ_UTILS.log_report(errbuf,1,'CZ_ORAAPPS_INTEGRATE.PopulateModels_cp',11276,NULL);
END;

------------------------------------------------------------------------------------------

PROCEDURE check_model_similarity_cp
(errbuf             OUT NOCOPY VARCHAR2,
 retcode            OUT NOCOPY NUMBER,
 p_TARGET_INSTANCE  IN  VARCHAR2,
 p_FOLDER_ID        IN  NUMBER,
 p_MODEL_ID         IN  NUMBER) IS

BEGIN
    EXECUTE IMMEDIATE
    'BEGIN CZ_BOM_SYNCH.report_model_cp(CZ_ORAAPPS_INTEGRATE.mERRBUF,CZ_ORAAPPS_INTEGRATE.mRETCODE,'||
    ':p_TARGET_INSTANCE,:p_MODEL_ID); END;'
    USING p_TARGET_INSTANCE,p_MODEL_ID;
    errbuf :=CZ_ORAAPPS_INTEGRATE.mERRBUF;
    retcode:=CZ_ORAAPPS_INTEGRATE.mRETCODE;
EXCEPTION
    WHEN OTHERS THEN
         retcode:=2;
         errbuf:=SQLERRM;
         log_report('check_model_similarity_cp: ' || errbuf);
END;

------------------------------------------------------------------------------------------

PROCEDURE check_all_models_similarity_cp
(errbuf             OUT NOCOPY VARCHAR2,
 retcode            OUT NOCOPY NUMBER,
 p_TARGET_INSTANCE  IN  VARCHAR2) IS

BEGIN
    EXECUTE IMMEDIATE
    'BEGIN CZ_BOM_SYNCH.report_all_models_cp(CZ_ORAAPPS_INTEGRATE.mERRBUF,CZ_ORAAPPS_INTEGRATE.mRETCODE,'||
    ':p_TARGET_INSTANCE); END;'
    USING p_TARGET_INSTANCE;
    errbuf :=CZ_ORAAPPS_INTEGRATE.mERRBUF;
    retcode:=CZ_ORAAPPS_INTEGRATE.mRETCODE;
EXCEPTION
    WHEN OTHERS THEN
         retcode:=2;
         errbuf:=SQLERRM;
         log_report('check_all_models_similarity_cp: ' || errbuf);
END;

------------------------------------------------------------------------------------------

PROCEDURE sync_all_models_cp
(errbuf             OUT NOCOPY VARCHAR2,
 retcode            OUT NOCOPY NUMBER) IS
    v_ret              BOOLEAN;
    v_TARGET_INSTANCE  CZ_SERVERS.INSTANCE_NAME%TYPE;
BEGIN
    SELECT LOCAL_NAME
    INTO v_TARGET_INSTANCE
    FROM CZ_SERVERS
    WHERE import_enabled='1';

    EXECUTE IMMEDIATE
    'BEGIN CZ_BOM_SYNCH.synchronize_all_models_cp(CZ_ORAAPPS_INTEGRATE.mERRBUF,CZ_ORAAPPS_INTEGRATE.mRETCODE,'||
    ':v_TARGET_INSTANCE); END;'
    USING v_TARGET_INSTANCE;
    errbuf :=CZ_ORAAPPS_INTEGRATE.mERRBUF;
    retcode:=CZ_ORAAPPS_INTEGRATE.mRETCODE;
EXCEPTION
    WHEN TOO_MANY_ROWS THEN
         retcode:=2;
         errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_TOO_MANY_SERVERS');
         log_report('sync_all_models_cp: ' || errbuf);
    WHEN NO_DATA_FOUND THEN
         retcode:=2;
         errbuf:=CZ_UTILS.GET_TEXT('CZ_IMP_NO_SERVERS');
         log_report('sync_all_models_cp: ' || errbuf);
    WHEN OTHERS THEN
         retcode:=2;
         errbuf:=SQLERRM;
         log_report('sync_all_models_cp: ' || errbuf);
END;

------------------------------------------------------------------------------------------

PROCEDURE Repopulate_cp
(errbuf             OUT NOCOPY VARCHAR2,
 retcode            OUT NOCOPY NUMBER,
 p_FOLDER_ID        IN  NUMBER,
 p_MODEL_ID         IN  NUMBER) IS
    v_err INTEGER;
    v_ret BOOLEAN;
BEGIN
    CZ_POPULATORS_PKG.Repopulate(p_MODEL_ID,'1','1','1',v_err);

    --
    -- return last error message if error
    --
    IF v_err<>0 THEN
       FOR i IN(SELECT message FROM CZ_DB_LOGS
                WHERE run_id=v_err ORDER BY logtime)
       LOOP
          errbuf:=i.message;
       END LOOP;
       retcode:=1;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
         retcode:=2;
         errbuf:=SQLERRM;
         log_report('Repopulate_cp: ' || errbuf);
END;

END;

/
