--------------------------------------------------------
--  DDL for Package Body FV_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_SETUP_PKG" AS
-- $Header: FVFCATTB.pls 120.9.12010000.7 2010/01/29 11:34:43 yanasing ship $
  g_module_name VARCHAR2(100) := 'fv.plsql.FV_SETUP_PKG.';
 -------------------------------------------------------------------
  l_config_file               VARCHAR2(100) := '@FV:patch/115/import/';
  l_data_file                 VARCHAR2(100) := '@FV:patch/115/import/US/';
  l_language                  VARCHAR2(20)  ;
  l_req_id                    NUMBER ;

 --------------------------------------------------------------------
Procedure FACTS_ATTRIBUTES (errbuf OUT NOCOPY varchar2,
		retcode OUT NOCOPY varchar2,
		p_yes_no in varchar2) is
  l_module_name VARCHAR2(200) := g_module_name || 'FACTS_ATTRIBUTES';
--v_count			number;
v_message		Varchar2(500);
--v_errbuf		Varchar2(255);
--v_retcode		Varchar2(255);
--v_attr_inserted		number :=0;
--v_codes_inserted	number :=0;
--v_accts_inserted  	number :=0;

begin

l_req_id := fnd_request.submit_request
                         (program       => 'FNDLOAD',
                          application   => 'FND',
                          description   => NULL,
                          start_time    => NULL,
                          sub_request   => FALSE,
                          argument1     => 'UPLOAD',
                          argument2     => l_config_file||'fvfcattb.lct',
                          argument3     => l_data_file||'fvfcattb.ldt');

      if l_req_id = 0 then

         errbuf  := fnd_message.get ;
         retcode := -1 ;
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.message1',errbuf);
         raise fnd_api.g_exc_error ;
	      rollback;
              return;
        ELSE
         l_req_id := fnd_request.submit_request
                         (program       => 'FNDLOAD',
                          application   => 'FND',
                          description   => NULL,
                          start_time    => NULL,
                          sub_request   => FALSE,
                          argument1     => 'UPLOAD',
                          argument2     => l_config_file||'fvfcrt7.lct',
                          argument3     => l_data_file||'fvfcrt7.ldt');

      if l_req_id = 0 then
         errbuf  := fnd_message.get ;
         retcode := -1 ;
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.message2',errbuf);
         raise fnd_api.g_exc_error ;
         rollback;
         return;
     END IF;

    COMMIT;

 IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   v_message :='FACTS attributes  table setup program successfully Requested';
   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name||'.message3',v_message);
 END IF;

	if p_yes_no = 'N' then
   retcode := 1;
     errbuf := 'FACTS II requires US SGL compliance        if the natural account segment has been expanded to accomodate Agency
     specific requirements, designate a parent account that is 4-digit US SGL Account';
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.message4',errbuf);
 end if;
END IF;

Exception
   When Others Then
   errbuf := substr(SQLERRM,1,225);
   retcode := -1;
   FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
END;
 ----------------------------------------------------------------------------

 Procedure FUNDS_AVAILABLE (errbuf OUT NOCOPY varchar2,
		           retcode OUT NOCOPY varchar2) is
  l_module_name VARCHAR2(200) := g_module_name || 'FUNDS_AVAILABLE';
 begin
       l_req_id := fnd_request.submit_request
                         (program       => 'FNDLOAD',
                          application   => 'FND',
                          description   => NULL,
                          start_time    => NULL,
                          sub_request   => FALSE,
                          argument1     => 'UPLOAD',
                          argument2     => l_config_file||'fvfundav.lct',
                          argument3     => l_data_file||'fvfundav.ldt');

      if l_req_id = 0 then
         errbuf  := fnd_message.get ;
         retcode := -1 ;
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.message1',errbuf);
         raise fnd_api.g_exc_error ;
         rollback;
         return;
     END IF;
    commit;
     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name||'.message2',
         'Fund Available table seed data process sucessfully requested');
     END IF;
 EXCEPTION
   WHEN OTHERS THEN
   errbuf := SQLERRM;
   FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
   RAISE;
 End;
 ------------------------------------------------------------------------------
 Procedure USSGL_LOAD (errbuf OUT NOCOPY varchar2,
		           retcode OUT NOCOPY varchar2) is
  l_module_name VARCHAR2(200) := g_module_name || 'USSGL_LOAD';
 begin
       l_req_id := fnd_request.submit_request
                         (program       => 'FNDLOAD',
                          application   => 'FND',
                          description   => NULL,
                          start_time    => NULL,
                          sub_request   => FALSE,
                          argument1     => 'UPLOAD',
                          argument2     => l_config_file||'fvfcusgl.lct',
                          argument3     => l_data_file||'fvfcusgl.ldt');

      if l_req_id = 0 then
         errbuf  := fnd_message.get ;
         retcode := -1 ;
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.message1',errbuf);
         raise fnd_api.g_exc_error ;
         rollback;
         return;
     END IF;
    commit;
     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name||'.message2',
         'USSGL table setup seed data process sucessfully requested');
     END IF;

     l_req_id := fnd_request.submit_request
                         (program       => 'FNDLOAD',
                          application   => 'FND',
                          description   => NULL,
                          start_time    => NULL,
                          sub_request   => FALSE,
                          argument1     => 'UPLOAD',
                          argument2     => l_config_file||'fvfc2closvald.lct',
                          argument3     => l_data_file||'fvfc2closvald.ldt');

      if l_req_id = 0 then
         errbuf  := fnd_message.get ;
         retcode := -1 ;
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.message3',errbuf);
         raise fnd_api.g_exc_error ;
         rollback;
         return;
     END IF;
    commit;
     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name||'.message4',
         'Closing Validation table setup seed data process sucessfully requested');
     END IF;
 EXCEPTION
   WHEN OTHERS THEN
   errbuf := SQLERRM;
   FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
   RAISE;

 End;
 ------------------------------------------------------------------------------

 Procedure LOAD_FUND_TRANSMISSION_FORMATS (errbuf OUT NOCOPY varchar2,
		           retcode OUT NOCOPY varchar2) is
  l_module_name VARCHAR2(200) := g_module_name || 'LOAD_FUND_TRANSMISSION_FORMATS';
 begin
       l_req_id := fnd_request.submit_request
                         (program       => 'FNDLOAD',
                          application   => 'FND',
                          description   => NULL,
                          start_time    => NULL,
                          sub_request   => FALSE,
                          argument1     => 'UPLOAD',
                          argument2     => l_config_file||'fvxftran.lct',
                          argument3     => l_data_file||'fvxftran.ldt');

      if l_req_id = 0 then
         errbuf  := fnd_message.get ;
         retcode := -1 ;
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.message1',errbuf);
         raise fnd_api.g_exc_error ;
         rollback;
         return;
     END IF;
    commit;
     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name||'.message4',
         'Treasury transmission format seed data process successfully requested');
     END IF;

 EXCEPTION
   WHEN OTHERS THEN
   errbuf := SQLERRM;
   FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
   RAISE;
 End;
 ------------------------------------------------------------------------------
 Procedure CFS_TABLE_SETUP (errbuf OUT NOCOPY varchar2,
		           retcode OUT NOCOPY varchar2) is
  l_module_name VARCHAR2(200) := g_module_name || 'CFS_TABLE_SETUP';
rphase1               VARCHAR2(30);
rstatus1              VARCHAR2(30);
dphase1               VARCHAR2(30);
dstatus1              VARCHAR2(30);
message1              VARCHAR2(240);
call_status1          BOOLEAN;

 begin

    begin
       l_req_id := fnd_request.submit_request
                         (program       => 'FNDLOAD',
                          application   => 'FND',
                          description   => NULL,
                          start_time    => NULL,
                          sub_request   => FALSE,
                          argument1     => 'UPLOAD',
                          argument2     => l_config_file||'fvcfsrds.lct',
                          argument3     => l_data_file||'fvcfsrd1.ldt');

      if l_req_id = 0 then
         errbuf  := fnd_message.get ;
         retcode := -1 ;
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.message1',errbuf);
         raise fnd_api.g_exc_error ;
         rollback;
         return;
     END IF;
     commit;
   end ;
  LOOP
          call_status1 := FND_CONCURRENT.GET_REQUEST_STATUS(l_req_id,NULL,NULL,rphase1,rstatus1,dphase1,dstatus1,message1);
          EXIT WHEN ((call_status1 and dphase1 = 'COMPLETE') or NOT(call_status1));
          DBMS_LOCK.SLEEP(5);
  END LOOP;
     begin
       l_req_id := fnd_request.submit_request
                         (program       => 'FNDLOAD',
                          application   => 'FND',
                          description   => NULL,
                          start_time    => NULL,
                          sub_request   => FALSE,
                          argument1     => 'UPLOAD',
                          argument2     => l_config_file||'fvcfsrds.lct',
                          argument3     => l_data_file||'fvcfsrd2.ldt');

      if l_req_id = 0 then
         errbuf  := fnd_message.get ;
         retcode := -1 ;
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.message2',errbuf);
         raise fnd_api.g_exc_error ;
         rollback;
         return;
     END IF;
     commit;
     end ;
      begin
       l_req_id := fnd_request.submit_request
                         (program       => 'FNDLOAD',
                          application   => 'FND',
                          description   => NULL,
                          start_time    => NULL,
                          sub_request   => FALSE,
                          argument1     => 'UPLOAD',
                          argument2     => l_config_file||'fvcfsrds.lct',
                          argument3     => l_data_file||'fvcfsrd3.ldt');

      if l_req_id = 0 then
         errbuf  := fnd_message.get ;
         retcode := -1 ;
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.message3',errbuf);
         raise fnd_api.g_exc_error ;
         rollback;
         return;
     END IF;
     commit;
     end ;
     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name||'.message4','Financial statements table seed data process sucessfully requested');
     END IF;

 EXCEPTION
   WHEN OTHERS THEN
   errbuf := SQLERRM;
   FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
   RAISE;
 End;
------------------------------------------------------------------------------
Procedure LOAD_SF133_SETUP_DATA (errbuf OUT NOCOPY varchar2,
		           retcode OUT NOCOPY varchar2,
               p_delete_133_setup IN VARCHAR2) is
  l_module_name VARCHAR2(200) := g_module_name || 'LOAD_SF133_SETUP_DATA';
 begin


       IF p_delete_133_setup = 'Y' THEN
        fv_utility.log_mesg('Deleting 133 setup data');
        BEGIN

          delete from FV_SF133_REP_LINE_CALC;
          fv_utility.log_mesg('Deleted from FV_SF133_REP_LINE_CALC');
          delete from FV_SF133_DEFINITIONS_ACCTS;
          fv_utility.log_mesg('Deleted from FV_SF133_DEFINITIONS_ACCTS');
          delete from FV_SF133_DEFINITIONS_LINES;
          fv_utility.log_mesg('Deleted from FV_SF133_DEFINITIONS_LINES');
         EXCEPTION WHEN OTHERS THEN
             fv_utility.log_mesg('When others error when deleting
                                  SF133 data: '||SQLERRM);
         END;

       END IF;
       l_req_id := fnd_request.submit_request
                         (program       => 'FNDLOAD',
                          application   => 'FND',
                          description   => NULL,
                          start_time    => NULL,
                          sub_request   => FALSE,
                          argument1     => 'UPLOAD',
                          argument2     => l_config_file||'fvsf133.lct',
                          argument3     => l_data_file||'fvsf133.ldt');


      if l_req_id = 0 then
         errbuf  := fnd_message.get ;
         retcode := -1 ;
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.message1',errbuf);
         raise fnd_api.g_exc_error ;
         rollback;
         return;
     END IF;
    commit;
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name||'.message1', 'SF133 seed data process successfully requested');
   END IF;

 EXCEPTION
   WHEN OTHERS THEN
   errbuf := SQLERRM;
   FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
   RAISE;
 End;

 ------------------------------------------------------------------------------
 Procedure LOAD_SBR_SETUP_DATA (errbuf OUT NOCOPY varchar2,
		           retcode OUT NOCOPY varchar2,
               p_delete_sbr_setup IN VARCHAR2) is
  l_module_name VARCHAR2(200) := g_module_name || 'LOAD_SBR_SETUP_DATA';
 begin


       IF p_delete_sbr_setup = 'Y' THEN
        fv_utility.log_mesg('Deleting SBR setup data');
        BEGIN

          delete from FV_SBR_REP_LINE_CALC;
          fv_utility.log_mesg('Deleted from FV_SBR_REP_LINE_CALC');
          delete from FV_SBR_DEFINITIONS_ACCTS;
          fv_utility.log_mesg('Deleted from FV_SBR_DEFINITIONS_ACCTS');
          delete from FV_SBR_DEFINITIONS_LINES;
          fv_utility.log_mesg('Deleted from FV_SBR_DEFINITIONS_LINES');
         EXCEPTION WHEN OTHERS THEN
             fv_utility.log_mesg('When others error when deleting
                                  SBR data: '||SQLERRM);
         END;

       END IF;
       l_req_id := fnd_request.submit_request
                         (program       => 'FNDLOAD',
                          application   => 'FND',
                          description   => NULL,
                          start_time    => NULL,
                          sub_request   => FALSE,
                          argument1     => 'UPLOAD',
                          argument2     => l_config_file||'fvsbr.lct',
                          argument3     => l_data_file||'fvsbr.ldt');


      if l_req_id = 0 then
         errbuf  := fnd_message.get ;
         retcode := -1 ;
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.message1',errbuf);
         raise fnd_api.g_exc_error ;
         rollback;
         return;
     END IF;
    commit;
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name||'.message1', 'SBR seed data process successfully requested');
   END IF;

 EXCEPTION
   WHEN OTHERS THEN
   errbuf := SQLERRM;
   FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
   RAISE;
 End;

 ------------------------------------------------------------------------------
 PROCEDURE load_rx_reports (errbuf OUT NOCOPY varchar2,
                             retcode OUT NOCOPY varchar2) IS
  l_module_name VARCHAR2(200) := g_module_name || 'load_rx_reports';

 BEGIN
       l_req_id := fnd_request.submit_request
                         (program       => 'FNDLOAD',
                          application   => 'FND',
                          description   => NULL,
                          start_time    => NULL,
                          sub_request   => FALSE,
                          argument1     => 'UPLOAD',
                          argument2     => l_config_file||'fvrxi.lct',
                          argument3     => l_data_file||'fvrxi.ldt');

      IF l_req_id = 0 THEN
         errbuf  := fnd_message.get ;
         retcode := -1 ;
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.message1',errbuf);
         raise fnd_api.g_exc_error ;
         ROLLBACK;
         RETURN;
     END IF;
    COMMIT;
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name||'.message2', 'RXi reports upload process successfully requested');
   END IF;

   --   Updating the RX report responsiblity_id
   --   This is required because Rxi seed populates responsiblity id
   --   stored in seed115 for Federal Administrator, which is not correct
   UPDATE fa_rx_reports
   SET responsibility_id = (SELECT responsibility_id
                            FROM FND_responsibility_tl
                            WHERE responsibility_name = 'Federal Administrator'
                            AND   language= 'US')
   WHERE report_id IN (395,397,399,415);

 EXCEPTION
   WHEN OTHERS THEN
   errbuf := SQLERRM;
   FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
   RAISE;
 END;

  PROCEDURE load_reimb_act_definitions (errbuf OUT NOCOPY varchar2,
                            retcode OUT NOCOPY varchar2) IS

    l_module_name VARCHAR2(200) := g_module_name || 'load_reimb_act_definitions';

    BEGIN
      l_req_id := fnd_request.submit_request
                                    (program       => 'FNDLOAD',
                                    application   => 'FND',
                                    description   => NULL,
                                    start_time    => NULL,
                                    sub_request   => FALSE,
                                    argument1     => 'UPLOAD',
                                    argument2     => l_config_file||'fvreimrd.lct',
                                    argument3     => l_data_file||'fvreimrd.ldt');

      IF l_req_id = 0 THEN
         errbuf  := fnd_message.get ;
         retcode := -1 ;
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.message1',errbuf);
         ROLLBACK;
         RAISE fnd_api.g_exc_error ;
     END IF;
    commit;
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name||'.message1',
	 'Load Reimbursement Activity Definitions process successfully requested');
   END IF;
  END  load_reimb_act_definitions;

 ----------------------------------------------------------------------------
END fv_setup_pkg;

/
