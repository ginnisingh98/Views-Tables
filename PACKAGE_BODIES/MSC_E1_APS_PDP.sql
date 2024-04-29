--------------------------------------------------------
--  DDL for Package Body MSC_E1_APS_PDP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_E1_APS_PDP" AS
--# $Header: MSCE1PDB.pls 120.0.12010000.21 2009/09/10 13:47:11 nyellank noship $
	/* Array declaration */

	TYPE scenarios_array IS VARRAY(100) OF VARCHAR2(200);  -- declaring array for holding scenarios
	arrScr scenarios_array := scenarios_array();

	/* Global variables */

	ReturnStr varchar2(2000);
	SessionNum varchar2(10);
	ErrMessage varchar2(1900);
	ErrLength integer;
	StartIndex integer;
	EndIndex integer;
        WSURL varchar2(1000);

	/* Local Procedure */

	/* Function to Launch Mail after scnerios are done */
	FUNCTION MSC_E1_Mail_ODIExecute(scrName IN VARCHAR2, WSURL IN VARCHAR2)
		RETURN BOOLEAN
	AS
		-- NO local variables
	BEGIN
		IF WSURL IS NOT NULL THEN
				begin
					select MSC_E1APS_UTIL.MSC_E1APS_ODIScenarioExecute(scrName,'001','',WSURL) into ReturnStr from dual;

				EXCEPTION
					WHEN OTHERS THEN
						select instr(ReturnStr,'#') into StartIndex from dual;
						select substr(ReturnStr,StartIndex+1,1800) into ErrMessage from dual;
						MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'ODI Scenario' || scrName|| ' execution failed.' || ErrMessage);
					return FALSE;
				end;

				select instr(ReturnStr,'#') into StartIndex from dual;
				select substr(ReturnStr,0,StartIndex-1) into SessionNum from dual;
				select substr(ReturnStr,StartIndex+1,1800) into ErrMessage from dual;

				if (SessionNum = '-1') then
					MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'ODI Scenario ' || scrName|| ' executed with errors. Session #: ' || SessionNum || ' , Error Message: ' || ErrMessage);
					RETURN FALSE;
				end if;

				if (SessionNum <> '-1' and length(ErrMessage) > 0) then
					MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'ODI Scenario ' || scrName|| ' executed with errors. Session #: ' || SessionNum || ' , Error Message: ' || ErrMessage);
					RETURN FALSE;
				end if;
				MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'  Mail Execution SUCCESS');
			  RETURN TRUE;
		ELSE
					RETURN TRUE;
		END IF;
	END;     --MSC_E1_Mail_ODIExecute

		/*execute ODI scenario*/
	FUNCTION MSC_E1_APS_ODIEXECUTE(arrScr IN scenarios_array, WSURL IN VARCHAR2)
		RETURN BOOLEAN
	AS
		scrStatus varchar2(10);

	begin
		FOR i IN arrScr.FIRST .. arrScr.LAST LOOP
			IF WSURL IS NOT NULL THEN
				begin
					select MSC_E1APS_UTIL.MSC_E1APS_ODIScenarioExecute(arrScr(i),'001','',WSURL) into ReturnStr from dual;

				EXCEPTION
					WHEN OTHERS THEN
						select instr(ReturnStr,'#') into StartIndex from dual;
						select substr(ReturnStr,StartIndex+1,1800) into ErrMessage from dual;
						MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'ODI Scenario' || arrScr(i)|| ' execution failed.' || ErrMessage);
					return FALSE;
				end;

				select instr(ReturnStr,'#') into StartIndex from dual;
				select substr(ReturnStr,0,StartIndex-1) into SessionNum from dual;
				select substr(ReturnStr,StartIndex+1,1800) into ErrMessage from dual;
				MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, '  ODI Scenario  '||'  RESULT');

				if (SessionNum = '-1') then
						MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'ODI Scenario ' || arrScr(i)|| ' executed with errors. Session #: ' || SessionNum || ' , Error Message: ' || ErrMessage);
  					RETURN FALSE;
				end if;

				if (SessionNum <> '-1' and length(ErrMessage) > 0) then
						MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'ODI Scenario ' || arrScr(i)|| ' executed with errors. Session #: ' || SessionNum || ' , Error Message: ' || ErrMessage);
						RETURN FALSE;
				end if;
				MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'  ' || arrScr(i)||'  SUCCESS');
			ELSE
				RETURN TRUE;
			END IF;
		END LOOP;

		RETURN TRUE;

	END ;  --  MSC_E1_APS_ODIEXECUTE local procedure

	/* Main procedure begins here */

	/* Check parameters and add scenarios to above defined array */

	PROCEDURE MSC_E1APS_SCR_LIST(ERRBUF OUT NOCOPY VARCHAR2,
								RETCODE OUT NOCOPY VARCHAR2,
								parInstanceID IN VARCHAR2,
								parBaseDate IN INTEGER,
								parCalendars IN NUMBER ,
								parTradingPtnrs IN NUMBER ,
								parPlanners IN NUMBER ,
								parUOMs IN NUMBER ,
								parItems IN NUMBER ,
								parResrcs IN NUMBER ,
								parRtng IN NUMBER ,
								parOprns IN NUMBER ,
								parBOMs IN NUMBER ,
								parDmdClasses IN NUMBER ,
								parSalesChannels IN NUMBER ,
								parPriceLists IN NUMBER ,
								parShippingMethods IN NUMBER ,
								parItemSupp IN NUMBER ,
								parItemSrcing IN NUMBER ,
								parOnhandSupp IN NUMBER ,
								parSS IN NUMBER ,
								parPOSupp IN NUMBER ,
								parReqSupp IN NUMBER,
								parInstrSupp IN NUMBER ,
								parExtFcst IN NUMBER ,
								parSO IN NUMBER,
								parWO IN NUMBER)
	is
		scrCnt number(2) := 0;
		setreq_success BOOLEAN;
		req_submit_failed exception;
		FlagODILaunch boolean;
		set_req_id NUMBER;
		disp_val varchar2(10);
		fc_url varchar2(1000);
		fc_ret_value BOOLEAN;
		source_file varchar2(200);
		destination_file varchar2(200);
		mailstat BOOLEAN;
		l_instance_code VARCHAR2(3);
		scenario_name    VARCHAR2(200);
    scenario_version VARCHAR2(100);
    scenario_param   VARCHAR2(200);
    pre_process_odi BOOLEAN;
    post_process_odi BOOLEAN;


		/* Array definition for file copy list */
		TYPE FileList IS TABLE OF VARCHAR2(100);
		arrFiles FileList;

		/* Local Variables for pre-processor submit request */

		varCtg NUMBER DEFAULT MSC_UTIL.SYS_NO;
		varItemCtg NUMBER DEFAULT MSC_UTIL.SYS_NO;
		varUomClass NUMBER DEFAULT MSC_UTIL.SYS_NO;
		varDesig NUMBER DEFAULT MSC_UTIL.SYS_NO;
		varProj NUMBER DEFAULT MSC_UTIL.SYS_NO;
		varSuppCap NUMBER DEFAULT MSC_UTIL.SYS_NO;
		varMatSup NUMBER DEFAULT MSC_UTIL.SYS_NO;
		varMatDmd NUMBER DEFAULT MSC_UTIL.SYS_NO;
		varResrv NUMBER DEFAULT MSC_UTIL.SYS_NO;
		varResDmd NUMBER DEFAULT MSC_UTIL.SYS_NO;
		varItemCst NUMBER DEFAULT MSC_UTIL.SYS_NO;
		varParentReqId NUMBER DEFAULT -1;
		varFisCal NUMBER DEFAULT MSC_UTIL.SYS_NO;
		varSetup NUMBER DEFAULT MSC_UTIL.SYS_NO;
		varLinkDummy VARCHAR2(1000) DEFAULT NULL;
		varItemRollup NUMBER DEFAULT MSC_UTIL.SYS_NO;
		varLvlvalue NUMBER DEFAULT MSC_UTIL.SYS_NO;
		varLvlAssoc NUMBER DEFAULT MSC_UTIL.SYS_NO;
		varBooking NUMBER DEFAULT MSC_UTIL.SYS_NO;
		varShipment NUMBER DEFAULT MSC_UTIL.SYS_NO;
		varMfgFct  NUMBER DEFAULT MSC_UTIL.SYS_NO;
		varCSData  NUMBER DEFAULT MSC_UTIL.SYS_NO;
		varCSDummy VARCHAR2(1000) DEFAULT NULL;
		varCSRefresh NUMBER DEFAULT MSC_UTIL.SYS_NO;
		varCurrConv NUMBER DEFAULT MSC_UTIL.SYS_NO;
		varUomConv NUMBER DEFAULT MSC_UTIL.SYS_NO;
		varCallingModule CONSTANT NUMBER := 1;
		varCompUsers  NUMBER DEFAULT MSC_UTIL.SYS_NO;
		varItemSubs NUMBER DEFAULT MSC_UTIL.SYS_NO;
		varCompCal NUMBER DEFAULT MSC_UTIL.SYS_NO;
		varProfile NUMBER DEFAULT MSC_UTIL.SYS_NO;
		varCalAssign NUMBER DEFAULT MSC_UTIL.SYS_NO;
		varIRO  NUMBER DEFAULT MSC_UTIL.SYS_NO;
		varERO  NUMBER DEFAULT MSC_UTIL.SYS_NO;
		varSalesChannel NUMBER DEFAULT MSC_UTIL.SYS_NO;
		varFiscalCalendar NUMBER DEFAULT MSC_UTIL.SYS_NO;

		/* Local variables for ODS LOAD */
		varRecalcResAvailability NUMBER DEFAULT MSC_UTIL.SYS_NO;
		varSourcingHistoryEnabled NUMBER DEFAULT MSC_UTIL.SYS_YES;
		varPurgeSourcingHistory NUMBER DEFAULT MSC_UTIL.SYS_NO;

	/*Additional Variables to Purge ODS Data */

	varATPRules NUMBER DEFAULT MSC_UTIL.SYS_NO;
	varBOR NUMBER DEFAULT MSC_UTIL.SYS_NO;
	varKPIBIS NUMBER DEFAULT MSC_UTIL.SYS_NO;
  varMDS   NUMBER DEFAULT MSC_UTIL.SYS_NO;
  varMPS    NUMBER  DEFAULT MSC_UTIL.SYS_NO;
  varParameter NUMBER DEFAULT MSC_UTIL.SYS_NO;
  varPOReceipts   NUMBER DEFAULT MSC_UTIL.SYS_NO;
  varProject     NUMBER DEFAULT MSC_UTIL.SYS_NO;
  varPURREQPO    NUMBER DEFAULT MSC_UTIL.SYS_NO;
  varReservesHard NUMBER  DEFAULT MSC_UTIL.SYS_NO;
  varResourceNRA  NUMBER  DEFAULT MSC_UTIL.SYS_NO;
  varSH      NUMBER  DEFAULT MSC_UTIL.SYS_NO;
  varSUBINV       NUMBER  DEFAULT MSC_UTIL.SYS_NO;
  varSupplierResponse NUMBER  DEFAULT MSC_UTIL.SYS_NO;
  varTrip NUMBER    DEFAULT MSC_UTIL.SYS_NO;
  varUnitNO NUMBER  DEFAULT MSC_UTIL.SYS_NO;
  varUserCompany  NUMBER  DEFAULT MSC_UTIL.SYS_NO;
  varUserSupplyDemand NUMBER  DEFAULT MSC_UTIL.SYS_NO;
  varPaybackDemandSupply  NUMBER  DEFAULT MSC_UTIL.SYS_NO;
  varCurrencyConversion NUMBER DEFAULT MSC_UTIL.SYS_NO;
  varDeliveryDetails NUMBER DEFAULT MSC_UTIL.SYS_NO;

  /* Purge ODS Global Entities and Lid */
  varPurgeGlobalODS   NUMBER DEFAULT MSC_UTIL.SYS_NO;
  varPurgeGlobalFlag  NUMBER DEFAULT MSC_UTIL.SYS_NO;
  varPurgeLocalId   NUMBER DEFAULT MSC_UTIL.SYS_NO;

	/*Loacal Parametes for Dependency Entites*/
	locParCalendars  NUMBER DEFAULT MSC_UTIL.SYS_NO;
	locParResrcs  NUMBER DEFAULT MSC_UTIL.SYS_NO;
	locParOprns NUMBER  DEFAULT MSC_UTIL.SYS_NO;
	locParRtng NUMBER   DEFAULT MSC_UTIL.SYS_NO;

	parInstanceCode VARCHAR2(3);



	BEGIN

	 locParCalendars := parCalendars;
	 locParResrcs := parResrcs;
	 locParOprns  := parOprns ;
	 locParRtng   := parRtng;


    /* Purge ODS Dependancy for parPOSupp and parReqSupp*/
   IF parPOSupp = MSC_UTIL.SYS_YES AND  parReqSupp = MSC_UTIL.SYS_YES  AND parInstrSupp =MSC_UTIL.SYS_YES THEN
        varPURREQPO := MSC_UTIL.SYS_YES;
    END IF;

     /* Launching  Collections Pre-Process Custom Hook*/
     MSC_E1APS_HOOK.COL_PLAN_DATA_PRE_PROCESS(ERRBUF,RETCODE);

     IF RETCODE = MSC_UTIL.G_ERROR THEN
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Error Message:' || ERRBUF);
         RETCODE := MSC_UTIL.G_ERROR;
         RETURN;
     END IF;

    WSURL := fnd_profile.value('MSC_E1APS_ODIURL');
		IF WSURL IS NOT NULL THEN
		  /* Launching Pre-Process Custom Hook ODI Scenario */
      select instance_code into l_instance_code from msc_apps_instances
      where instance_id = parInstanceID;

                 scenario_name    := 'PREPROCESSHOOKPKG';
                 scenario_version := '001';
                 scenario_param   := 'E1TOAPSPROJECT.PVV_PRE_PROCESS_VAR=';
                 scenario_param   := scenario_param
                                     ||l_instance_code
                                     || ':'
                                     || MSC_E1APS_UTIL.COL_PLAN_DATA;
                pre_process_odi   :=MSC_E1APS_DEMCL.CALL_ODIEXE(scenario_name, scenario_version, scenario_param, WSURL);

                IF pre_process_odi = FALSE THEN
                      mailstat := MSC_E1_Mail_ODIExecute('MAIL',WSURL);
                      RETCODE := MSC_UTIL.G_ERROR;
                      RETURN;
                END IF;
     END IF;

     MSC_UTIL.MSC_DEBUG('STARTING E1 APS Planning Data Pull');

     /*Dependency Check for Trading Partner and Calendars*/
       IF parTradingPtnrs = MSC_UTIL.SYS_YES  AND locParCalendars = MSC_UTIL.SYS_NO THEN
              scrCnt := scrCnt + 1;
        			arrScr.EXTEND;
        			arrScr(scrCnt) := 'LOADE1CALENDARDATATOAPSPKG';
        END IF;
         /*Dependency Check for BOM and Resource*/
       IF parBOMs = MSC_UTIL.SYS_YES   THEN
               locParOprns  := MSC_UTIL.SYS_YES;
               locParRtng   := MSC_UTIL.SYS_YES;
               locParResrcs := MSC_UTIL.SYS_YES;
        END IF;
      /*Dependency Check for Resource Requirments and WO */
      	IF parWO = MSC_UTIL.SYS_YES  THEN
      		     locParResrcs := MSC_UTIL.SYS_YES;
      	END IF;

      	/*Dependency Check for Routing Operations and WO */
      	IF parWO = MSC_UTIL.SYS_YES  THEN
      		     locParOprns := MSC_UTIL.SYS_YES;
      	END IF;

      /*Dependency Check for Operations and Routing */
        IF locParOprns = MSC_UTIL.SYS_YES THEN
			   locParRtng := MSC_UTIL.SYS_YES;
			END IF;

		/* Creating array to hold the scenarios to be launched for the input parameters */

		MSC_UTIL.MSC_DEBUG('CHECKING INPUT PARAMETERS TO RUN SCENARIOS');

		IF locParCalendars = MSC_UTIL.SYS_YES THEN
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1CALENDARDATATOAPSPKG';
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1WORKDAYPATTERNDATATOAPSPKG';
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1SHIFTTIMEDATATOAPSPKG';
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1CALENDAREXCEPTIONDATATOAPSPKG';
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1SHIFTEXCEPTIONDATATOAPSPKG';
		END IF;

		IF parTradingPtnrs = MSC_UTIL.SYS_YES THEN
		  scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1TRADINGPARTNERSDATATOAPSPKG';
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1TRADPARTNERSITEDATATOAPSPKG';
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1LOCASSOCIATIONDATATOAPSPKG';
		END IF;

		IF parPlanners = MSC_UTIL.SYS_YES THEN
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1PLANNERDATATOAPSPKG';
		END IF;

		IF parUOMs = MSC_UTIL.SYS_YES THEN
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1UNITSOFMEASUREDATATOAPSPKG';
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1UOMCONVERSIONDATATOAPSPKG';
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1UOMCLASSCONVDATATOAPSPKG';
		END IF;

		IF parItems = MSC_UTIL.SYS_YES THEN
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1ITEMDATATOAPSPKG';
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1CATEGORYSETDATATOAPSPKG';
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1ITEMCATEGORIESDATATOAPSPKG';
		END IF;

		IF locParResrcs = MSC_UTIL.SYS_YES THEN
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1RESOURCEGROUPSDATATOAPSPKG';
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1RESOURCESDATATOAPSPKG';
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1RESOURCESHIFTDATATOAPSPKG';
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1RESOURCESETUPSDATATOAPSPKG';
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1STDOPERRESOURCESDATATOAPSPKG';
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1SETUPTRANSITIONSDATATOAPSPKG';

		END IF;

		IF locParRtng = MSC_UTIL.SYS_YES THEN
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1ROUTINGDATATOAPSPKG';
		END IF;

		IF locParOprns = MSC_UTIL.SYS_YES THEN
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1ROUTINOPERATIONDATATOAPSPKG';
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1ROUTINGOPRESOURCEDATATOAPSPKG';
		END IF;

		IF parBOMs = MSC_UTIL.SYS_YES THEN
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1BOMHEADERDATATOAPSPKG';
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1BOMCOMPONENTDATATOAPSPKG';
		END IF;

		IF parDmdClasses = MSC_UTIL.SYS_YES THEN
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1DEMANDCLASSESDATATOAPSPKG';
		END IF;

		IF parSalesChannels = MSC_UTIL.SYS_YES THEN
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1SALESCHANNELDATATOAPSPKG';
		END IF;

		IF parPriceLists = MSC_UTIL.SYS_YES THEN
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1PRICELISTDATATOAPSPKG';
		END IF;

		IF parShippingMethods = MSC_UTIL.SYS_YES THEN
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1SHIPPINGMETHODSDATATOAPSPKG';
		END IF;

		IF parItemSupp = MSC_UTIL.SYS_YES THEN
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1ITEMSUPPLIERDATATOAPSPKG';
		END IF;

		IF parItemSrcing = MSC_UTIL.SYS_YES THEN
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1ITEMSOURCINGDATATOAPSPKG';
		END IF;

		IF parOnhandSupp = MSC_UTIL.SYS_YES THEN
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1ONHANDSUPPLIESDATATOAPSPKG';
		END IF;

		IF parSS = MSC_UTIL.SYS_YES THEN
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1SAFETYSTOCKDATATOAPSPKG';
		END IF;

		IF parPOSupp = MSC_UTIL.SYS_YES THEN
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1PURCHASEORDSUPPLYDATATOAPSPKG';
		END IF;

		IF parReqSupp = MSC_UTIL.SYS_YES THEN
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1REQUISITIONSUPPLDATATOAPSPKG';
		END IF;

		IF parInstrSupp = MSC_UTIL.SYS_YES THEN
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1INTRANSITSUPPLIESDATATOAPSPKG';
		END IF;

		IF parExtFcst = MSC_UTIL.SYS_YES THEN
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1FORECASTDESDATATOAPSPKG';
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1FORECASTDEMANDSDATATOAPSPKG';
		END IF;

		IF parSO = MSC_UTIL.SYS_YES THEN
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1SALESORDERDATATOAPSPKG';
		END IF;

		IF parWO = MSC_UTIL.SYS_YES THEN
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1WORKORDERSUPPLIESDATATOAPSPKG';
      scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1WORKORDERCOMPDMNDDATATOAPSPKG';
			scrCnt := scrCnt + 1;
			arrScr.EXTEND;
			arrScr(scrCnt) := 'LOADE1RESOURCEREQDATATOAPSPKG';
		END IF;


		/*Initialize ODI */

		MSC_UTIL.MSC_DEBUG('INITIALIZING ODI ....');

		WSURL := fnd_profile.value('MSC_E1APS_ODIURL');

		IF WSURL IS NOT NULL THEN
			BEGIN
				select MSC_E1APS_UTIL.MSC_E1APS_ODIInitialize(WSURL,parBaseDate) into ReturnStr from dual;

			EXCEPTION
			WHEN OTHERS THEN
				select instr(ReturnStr,'#') into StartIndex from dual;
				select substr(ReturnStr,StartIndex+1,1800) into ErrMessage from dual;
				MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'ODI Intialization failed. Error Message' || ErrMessage );
         RETCODE := MSC_UTIL.G_ERROR;
				RETURN;
			END;

			  select instr(ReturnStr,'#') into StartIndex from dual;
				select substr(ReturnStr,StartIndex+1,1800) into ErrMessage from dual;

		  IF (length(ErrMessage) > 0) THEN
			MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'ODI Failed to Initialize. Error Message' || ErrMessage );
			RETCODE := MSC_UTIL.G_ERROR;
			return;
		    end if;

			MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'ODI Initializion is successful');

		END IF;

    /* Deleting all rows from MSC_ST_PRICE_LIST Before Loading the Data */
	IF parPriceLists = MSC_UTIL.SYS_YES THEN
  	BEGIN
            DELETE
            FROM   MSC_ST_PRICE_LIST;
            COMMIT;

            EXCEPTION
            WHEN OTHERS THEN
                    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'No Rows Deleted from MSC_ST_PRICE_LIST');
                    RETCODE := MSC_UTIL.G_ERROR;
                    RETURN;
    END;
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'Rows Deleted from MSC_ST_PRICE_LIST');
  END IF;
		FlagODILaunch := MSC_E1_APS_ODIEXECUTE (arrScr, WSURL);

  		/* Launch Mail Scenario after all scenarions excution */
		mailstat := MSC_E1_Mail_ODIExecute('MAIL',WSURL);

		 IF parTradingPtnrs = MSC_UTIL.SYS_YES  AND locParCalendars = MSC_UTIL.SYS_NO THEN
       BEGIN

          SELECT INSTANCE_CODE into parInstanceCode
          FROM MSC_APPS_INSTANCES
          WHERE  INSTANCE_ID = parInstanceId;

          EXCEPTION
            WHEN OTHERS THEN
                    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'No Rows fetched from MSC_APPS_INSTANCES');
                    RETCODE := MSC_UTIL.G_ERROR;
                    RETURN;
        END;

        BEGIN
          DELETE FROM MSC_ST_CALENDARS
          WHERE SR_INSTANCE_CODE like parInstanceCode AND  PROCESS_FLAG =1;

           EXCEPTION
            WHEN OTHERS THEN
                    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,'No Rows deleted from MSC_ST_CALENDARS');
                    RETCODE := MSC_UTIL.G_ERROR;
                    RETURN;
       END;
     END IF;

		IF FlagODILaunch = FALSE THEN
      RETCODE := MSC_UTIL.G_ERROR;
      RETURN;
    END IF;


		IF FlagODILaunch THEN

			/* Variables initialization for Legacy Collections Pre-processor paramerters */

			IF parItems = MSC_UTIL.SYS_YES THEN
				varCtg := MSC_UTIL.SYS_YES;
				varItemCtg := MSC_UTIL.SYS_YES;
				varItemCst:= MSC_UTIL.SYS_YES;
				varItemSubs:= MSC_UTIL.SYS_YES;
			END IF;

			IF parUOMs = MSC_UTIL.SYS_YES THEN
				varUomClass := MSC_UTIL.SYS_YES;
				varUomConv := MSC_UTIL.SYS_YES;
			END IF;

			IF parItemSupp = MSC_UTIL.SYS_YES THEN
			 varSuppCap :=MSC_UTIL.SYS_YES;
			END IF;

			If parExtFcst = MSC_UTIL.SYS_YES THEN
			 varDesig :=MSC_UTIL.SYS_YES;
			 varMatDmd :=MSC_UTIL.SYS_YES;
			End IF;

      IF parWO = MSC_UTIL.SYS_YES THEN
        varMatSup :=MSC_UTIL.SYS_YES;
        varMatDmd :=MSC_UTIL.SYS_YES;
        varResDmd :=MSC_UTIL.SYS_YES;
      END IF;

      IF parOnhandSupp = MSC_UTIL.SYS_YES THEN
        varMatSup :=MSC_UTIL.SYS_YES;
      END IF;

      IF parPOSupp = MSC_UTIL.SYS_YES THEN
        varMatSup :=MSC_UTIL.SYS_YES;
      END IF;

       IF parInstrSupp = MSC_UTIL.SYS_YES THEN
        varMatSup :=MSC_UTIL.SYS_YES;
      END IF;

       IF parReqSupp = MSC_UTIL.SYS_YES THEN
        varMatSup :=MSC_UTIL.SYS_YES;
      END IF;

      IF parSO = MSC_UTIL.SYS_YES THEN
        varMatDmd :=MSC_UTIL.SYS_YES;
			End IF;

			MSC_UTIL.MSC_DEBUG('LAUNCHING PRE-PROCESSOR');

			MSC_UTIL.MSC_DEBUG('Setting Request Set');

			setreq_success := fnd_submit.set_request_set('MSC','FNDRSSUB3385');

			IF setreq_success THEN
				disp_val := 'TRUE';
			ELSE
				disp_val := 'FALSE';
			END IF;

			IF NOT setreq_success THEN
				MSC_UTIL.MSC_DEBUG('After Setting Request set'||disp_val);
				raise req_submit_failed;
			END IF;

			BEGIN

	   		MSC_UTIL.MSC_DEBUG('Before Lauching Pre-processor');

				setreq_success:=fnd_submit.submit_program('MSC','MSCPPM','Stage10',parInstanceID,60,1000,3, locParCalendars, parDmdClasses
					, parTradingPtnrs, varCtg, varItemCtg, parUOMs, varUomClass, varDesig, varProj
					, parItems, varSuppCap, parSS, parShippingMethods, parItemSrcing, parBOMs, locParRtng
					, locParResrcs, varMatSup, varMatDmd, varResrv, varResDmd, varItemCst, varParentReqId
					, varFisCal, varSetup, varLinkDummy, varItemRollup, varLvlvalue, varLvlAssoc, varBooking
					, varShipment, varMfgFct , parPriceLists, varCSData , varCSDummy,varCSRefresh, varCurrConv
					, varUomConv, varCallingModule, varCompUsers , varItemSubs, parPlanners, varCompCal, varProfile
					, varCalAssign, varIRO, varERO,parSalesChannels, varFiscalCalendar);

				IF setreq_success THEN
					disp_val := 'TRUE';
				ELSE
					disp_val := 'FALSE';
				END IF;

				IF NOT setreq_success THEN
					MSC_UTIL.MSC_DEBUG('After Launching Pre-proccessor '||disp_val);
					raise req_submit_failed;
				END IF;

         MSC_UTIL.MSC_DEBUG('Before Lauching Purge ODS Data');


				/* Purge ODS Data for Collected Entities (Stage15) */
         setreq_success :=fnd_submit.submit_program('MSC','MSCPURLEGODSENT','Stage15',parInstanceID,varPurgeLocalId,varPurgeLocalId
               ,varSuppCap, varATPRules, parBOMs,locParResrcs,locParRtng,locParOprns,varBOR, varPurgeGlobalODS,varPurgeGlobalODS, parDmdClasses,
                varItemSubs,varPurgeGlobalODS, parExtFcst,parItems,varItemCtg,varPurgeGlobalODS,varKPIBIS, varMDS, varMPS, parOnhandSupp,
                varParameter, parPlanners, varPOReceipts ,varProject, varPURREQPO, varReservesHard, varResourceNRA, parSS, parSO, varSH,
                parShippingMethods,parItemSrcing ,varSUBINV, varSupplierResponse, varPurgeGlobalODS, varTrip, varUnitNO, varPurgeGlobalODS,varUomConv, varUserCompany
               ,varUserSupplyDemand,varUserSupplyDemand, parWO, parSalesChannels, varFiscalCalendar, varIRO, varERO, varPaybackDemandSupply
               ,varCurrencyConversion, varDeliveryDetails);

        IF setreq_success THEN
					disp_val := 'TRUE';
				ELSE
					disp_val := 'FALSE';
				END IF;

				IF NOT setreq_success THEN
					MSC_UTIL.MSC_DEBUG('After Launching Purge ODS Data '||disp_val);
					raise req_submit_failed;
				END IF;


				MSC_UTIL.MSC_DEBUG('Before Launching ODS LOAD');
				setreq_success:=fnd_submit.submit_program('MSC','MSCPDC','Stage20',parInstanceID,180,3
						, varRecalcResAvailability, varSourcingHistoryEnabled,varPurgeSourcingHistory);

				IF setreq_success THEN
					disp_val := 'TRUE';
				ELSE
					disp_val := 'FALSE';
				END IF;

				IF NOT setreq_success THEN
					MSC_UTIL.MSC_DEBUG('After Launching ODS Load'||disp_val);
					raise req_submit_failed;
				END IF;

				set_req_id := fnd_submit.submit_set(NULL,FALSE);

				IF set_req_id = 0 THEN
					FND_MESSAGE.SET_NAME('MSC','Request Set Submission Failed');
					MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);
						RETCODE := MSC_UTIL.G_ERROR;
						RETURN;
				END IF;


      		 WSURL := fnd_profile.value('MSC_E1APS_ODIURL');
      		IF WSURL IS NOT NULL THEN
           /* Launching Post-Process Custom Hook ODI Scenario */
                       scenario_name    := 'POSTPROCESSHOOKPKG';
                       scenario_version := '001';
                       scenario_param   := 'E1TOAPSPROJECT.PVV_POST_PROCESS_VAR=';
                       scenario_param   := scenario_param
                                           ||l_instance_code
                                           || ':'
                                           || MSC_E1APS_UTIL.COL_PLAN_DATA;
                       post_process_odi :=MSC_E1APS_DEMCL.CALL_ODIEXE(scenario_name, scenario_version, scenario_param, WSURL);

                      IF post_process_odi = FALSE THEN
                            mailstat := MSC_E1_Mail_ODIExecute('MAIL',WSURL);
                            RETCODE := MSC_UTIL.G_ERROR;
                            RETURN;
                      END IF;
           END IF;
      	   /* Launching  Collections Post-Proces Custom Hook*/
             MSC_E1APS_HOOK.COL_PLAN_DATA_POST_PROCESS(ERRBUF,RETCODE);
             IF RETCODE = MSC_UTIL.G_ERROR THEN
                   MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Error Message:' || ERRBUF);
                   RETCODE := MSC_UTIL.G_ERROR;
                   RETURN;
             END IF;
      	RETURN;

			exception
				when req_submit_failed then
					FND_MESSAGE.SET_NAME('MSC','Request Set Failed');
					MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);
					RETCODE := MSC_UTIL.G_ERROR;
					RETURN;
				when others then
					FND_MESSAGE.SET_NAME('MSC','Request Set Submission Failed');
					MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, FND_MESSAGE.GET);
					RETCODE := MSC_UTIL.G_ERROR;
					RETURN;
			END;
		END IF;

  END; -- Procedure MSC_E1APS_SCR_LIST

END MSC_E1_APS_PDP;


/
