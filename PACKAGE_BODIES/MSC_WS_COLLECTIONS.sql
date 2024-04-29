--------------------------------------------------------
--  DDL for Package Body MSC_WS_COLLECTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_WS_COLLECTIONS" AS
/* $Header: MSCWCOLLB.pls 120.18 2008/03/25 19:33:22 bnaghi noship $  */


    FUNCTION GetCollectionMethodAsNumber( CollectionMethod IN VARCHAR2) RETURN NUMBER;
    FUNCTION GetRH_CollectionMethodAsNumber( CollectionMethod IN VARCHAR2) RETURN NUMBER;
    FUNCTION GetRH_DateRangeTypeAsNumber(DateRangeType IN Varchar2) RETURN NUMBER;
    FUNCTION GetLookupCodeForAppSuppList(ApprovedSupplierList IN VARCHAR2) RETURN NUMBER;
    FUNCTION GetUserCompAssoc(UserCompanyAssoc IN VARCHAR2) RETURN NUMBER;
    FUNCTION GetResAvail(ResourceAvailability IN VARCHAR2) RETURN NUMBER;
    FUNCTION Dem_ULC_GetDestTableName RETURN VARCHAR2;
    FUNCTION isValid_COLLECTION_GROUP( orgGroup IN VARCHAR2, InstanceId IN Number) RETURN BOOLEAN;
    FUNCTION isValid_DEM_COLLECTION_GROUP( orgGroup IN VARCHAR2, InstanceId IN Number ) RETURN BOOLEAN;
    FUNCTION isValid_INSTANCE_ID( INST_ID  IN NUMBER) RETURN BOOLEAN;
    FUNCTION isValid_DEM_COLLECTION_METHOD( methodCode IN NUMBER) RETURN BOOLEAN ;
    FUNCTION isValid_DATE_RANGE_TYPE(CollectionMethod IN NUMBER, dateRangeType IN NUMBER) RETURN BOOLEAN;
    FUNCTION isValid_Dates( DateRangeType in NUMBER, DateFrom in DATE,  DateTo IN DATE) RETURN BOOLEAN;
    FUNCTION isValid_Sel_Of_OrderTypes( CollectAllOrderTypes in Varchar2, IncludeOrderTypes in VARCHAR2, ExcludeOrderTypes in VARCHAR2) RETURN BOOLEAN;
    FUNCTION isValid_RMA_Types( types IN MscChar255Arr, InstanceId IN Number) RETURN BOOLEAN;
    FUNCTION SaveRMATypesIntoTable(RMATypes IN MscChar255Arr) RETURN BOOLEAN;



 -- =============================================================
 -- Desc: Please see package spec file for description
 -- =============================================================
    PROCEDURE RunASCPCollections(
               status				 OUT NOCOPY VARCHAR2,
               processId	       	         OUT NOCOPY VARCHAR2,
               UserID                             IN NUMBER,
               ResponsibilityID                   IN NUMBER,
               InstanceID                         IN NUMBER,
               CollectionGroup                    IN VARCHAR2,
               TotalWorkerNum                     IN NUMBER,
               Timeout                            IN NUMBER,
               OdsPURGEoption                     IN VARCHAR2,
               CollectionMethod                   IN VARCHAR2,
               AnalyzeTablesEnabled               IN VARCHAR2,
               ApprovedSupplierList               IN VARCHAR2,   -- changed from varchar2(popList) to Number
               AtpRulesEnabled                    IN VARCHAR2,
               BomEnabled                         IN VARCHAR2,
               BorEnabled                         IN VARCHAR2,
               CalendarEnabled                    IN VARCHAR2,
               DemandClassEnabled                 IN VARCHAR2,
               ItemSubstEnabled                   IN VARCHAR2,
               ForecastEnabled                    IN VARCHAR2,
               ItemEnabled                        IN VARCHAR2,
               KpiBisEnabled                      IN VARCHAR2,
               MdsEnabled                         IN VARCHAR2,
               MpsEnabled                         IN VARCHAR2,
               OnHandEnabled                      IN VARCHAR2,
               ParameterEnabled                   IN VARCHAR2,
               PlannerEnabled                     IN VARCHAR2,
               PoReceiptsEnabled                  IN VARCHAR2,
               ProjectEnabled                     IN VARCHAR2,
               PurReqPoEnabled                    IN VARCHAR2,
               ReservesHardEnabled                IN VARCHAR2,
               ResourceAvailability               IN VARCHAR2,
               SafestockEnabled                   IN VARCHAR2,
               SalesorderRtype                    IN VARCHAR2,
               SourcingHistoryEnabled             IN VARCHAR2,
               SourcingEnabled                    IN VARCHAR2,
               SubInvEnabled                      IN VARCHAR2,

               SupplierResponseEnabled            IN VARCHAR2,
               TpCustomerEnabled                  IN VARCHAR2,
               TripEnabled                        IN VARCHAR2,
               UnitNoEnabled                      IN VARCHAR2,
               UomEnabled                         IN VARCHAR2,
               UserCompanyAssoc                   IN VARCHAR2,
               UserSupplyDemand                   IN VARCHAR2,
               WipEnabled                         IN VARCHAR2,
               SalesChannelEnabled                IN VARCHAR2,
               FiscalCalendarEnabled              IN VARCHAR2,
               InternalRepairEnabled               IN VARCHAR2,
               ExternalRepairEnabled               IN VARCHAR2,
	       PaybackDemandSupplyEnabled         IN VARCHAR2,
               CurrencyConversionEnabled          IN VARCHAR2,
               DeliveryDetailsEnabled             IN VARCHAR2,

               Odstotalworkernum                  IN NUMBER,
               RecalcResAvailability              IN VARCHAR2,
               PurgeSourcingHistory               IN VARCHAR2
              ) AS
    result              BOOLEAN := false;
    L_VAL_RESULT        VARCHAR2(30);
    code                NUMBER;
    req_id              NUMBER;
    submit_failed       EXCEPTION;
    error_tracking_num  NUMBER;
    passedCollectionGroup varchar2(100);
  BEGIN


--dbms_output.put_line('ApprovedSupplierList: ' || ApprovedSupplierList);

    /* Language and Trading Partners are hidden*/
    /* validate InstanceId, CollectionGroup, WorkOrderNum, Timeout, Odstotalworkernum, all others are yes/no flags*/

        error_tracking_num  := 100;
        MSC_WS_COMMON.VALIDATE_USER_RESP(L_VAL_RESULT, UserId, ResponsibilityID);
        IF (L_VAL_RESULT <> 'OK') THEN
           PROCESSID := -1;
           STATUS := L_VAL_RESULT;
           RETURN;
        END IF;

        error_tracking_num  := 110;
        result := isValid_INSTANCE_ID(InstanceId);
        IF (result = false) THEN
           PROCESSID := -1;
           STATUS := 'INVALID_INSTANCE_ID';
           RETURN;
        END IF;

        error_tracking_num  := 120;
        result := isValid_COLLECTION_GROUP( CollectionGroup, InstanceId) ;
        IF (result = false) THEN
           PROCESSID := -1;
           STATUS := 'INVALID_COLLECTION_GROUP';
           RETURN;
        END IF;

        error_tracking_num  := 130;
        IF (TotalWorkerNum < 1)THEN
           PROCESSID := -1;
           STATUS := 'INVALID_WORKER_NUMBER';
           RETURN;
        END IF;

        IF (Odstotalworkernum < 1)THEN
           PROCESSID := -1;
           STATUS := 'INVALID_ODS_WORKER_NUMBER';
           RETURN;
        END IF;

        IF (Timeout < 0)THEN
           PROCESSID := -1;
           STATUS := 'INVALID_TIMEOUT';
           RETURN;
        END IF;

        IF (OdsPURGEoption = 'N' and CollectionMethod ='COMPLETE_REFRESH') THEN
           PROCESSID := -1;
           STATUS := 'INVALID_COLLECTION_METHOD_FOR_NO_PURGE';
           RETURN;
        END IF;
--bnaghi bug 6861953



        IF (GetLookupCodeForAppSuppList(ApprovedSupplierList) =-1) then
	 PROCESSID := -1;
           STATUS := 'INVALID_APPROVE_SUPPLIER_LIST';
           RETURN;
        END IF;
	IF (GetResAvail(ResourceAvailability) =-1) then
	 PROCESSID := -1;
           STATUS := 'INVALID_RESOURCE_AVAILABILITY';
           RETURN;
        END IF;
        IF (GetUserCompAssoc(UserCompanyAssoc) =-1) then
	 PROCESSID := -1;
           STATUS := 'INVALID_USER_COMPANY_ASSOC';
           RETURN;
        END IF;


        -- initiating request set
        error_tracking_num  := 140;
        result := fnd_submit.set_request_set('MSC','MSCPDX');
        IF(result = false) THEN
               RAISE submit_failed ;
        END IF ;

passedCollectionGroup := CollectionGroup;
-- bug 6837675
--if ( CollectionGroup = 'All') then
--    passedCollectionGroup := '-999';
--end if;
        -- register Planning Data Pull
        error_tracking_num  := 150;
        result := fnd_submit.submit_program('MSC','MSCPDP','MSCPDP',InstanceId, passedCollectionGroup,
            TotalWorkerNum,Timeout,'US', -- language
            MSC_WS_COMMON.Bool_to_Number( OdsPURGEoption),
            GetCollectionMethodAsNumber(CollectionMethod ),
            MSC_WS_COMMON.Bool_to_Number(AnalyzeTablesEnabled),
            GetLookupCodeForAppSuppList(ApprovedSupplierList),
            MSC_WS_COMMON.Bool_to_Number(AtpRulesEnabled),
            MSC_WS_COMMON.Bool_to_Number(BomEnabled),
            MSC_WS_COMMON.Bool_to_Number(BorEnabled) ,
            MSC_WS_COMMON.Bool_to_Number(CalendarEnabled),
            MSC_WS_COMMON.Bool_to_Number(DemandClassEnabled),
            MSC_WS_COMMON.Bool_to_Number(ItemSubstEnabled)  ,
            MSC_WS_COMMON.Bool_to_Number(ForecastEnabled),
            MSC_WS_COMMON.Bool_to_Number(ItemEnabled),
            MSC_WS_COMMON.Bool_to_Number(KpiBisEnabled),
            MSC_WS_COMMON.Bool_to_Number(MdsEnabled),
            MSC_WS_COMMON.Bool_to_Number(MpsEnabled),
            MSC_WS_COMMON.Bool_to_Number(OnHandEnabled),
            MSC_WS_COMMON.Bool_to_Number(ParameterEnabled),
            MSC_WS_COMMON.Bool_to_Number(PlannerEnabled),
            MSC_WS_COMMON.Bool_to_Number(PoReceiptsEnabled),
            MSC_WS_COMMON.Bool_to_Number(ProjectEnabled),
            MSC_WS_COMMON.Bool_to_Number(PurReqPoEnabled),
            MSC_WS_COMMON.Bool_to_Number(ReservesHardEnabled),
            GetResAvail(ResourceAvailability) ,
            MSC_WS_COMMON.Bool_to_Number(SafestockEnabled),
            MSC_WS_COMMON.Bool_to_Number(SalesorderRtype),
            MSC_WS_COMMON.Bool_to_Number(SourcingHistoryEnabled),
            MSC_WS_COMMON.Bool_to_Number(SourcingEnabled),
            MSC_WS_COMMON.Bool_to_Number(SubInvEnabled),

            MSC_WS_COMMON.Bool_to_Number(SupplierResponseEnabled),
            MSC_WS_COMMON.Bool_to_Number(TpCustomerEnabled),
            MSC_WS_COMMON.Bool_to_Number('N'),
            MSC_WS_COMMON.Bool_to_Number(TripEnabled),
            MSC_WS_COMMON.Bool_to_Number(UnitNoEnabled),
            MSC_WS_COMMON.Bool_to_Number(UomEnabled),
            GetUserCompAssoc(UserCompanyAssoc),
            MSC_WS_COMMON.Bool_to_Number(UserSupplyDemand),
            MSC_WS_COMMON.Bool_to_Number(WipEnabled),
            MSC_WS_COMMON.Bool_to_Number(SalesChannelEnabled),
            MSC_WS_COMMON.Bool_to_Number(FiscalCalendarEnabled),
            MSC_WS_COMMON.Bool_to_Number(InternalRepairEnabled),
            MSC_WS_COMMON.Bool_to_Number(ExternalRepairEnabled ),
 	    MSC_WS_COMMON.Bool_to_Number(PaybackDemandSupplyEnabled ),
            MSC_WS_COMMON.Bool_to_Number(CurrencyConversionEnabled ),
            MSC_WS_COMMON.Bool_to_Number(DeliveryDetailsEnabled )
         );

        IF(result = false) THEN
             RAISE submit_failed ;
        END IF ;

        -- register Planning ODS Load
        error_tracking_num  := 160;
        result := fnd_submit.submit_program('MSC','MSCPDC','MSCPDC',InstanceId,Timeout,Odstotalworkernum,
            MSC_WS_COMMON.Bool_to_Number(RecalcResAvailability),
            MSC_WS_COMMON.Bool_to_Number(SourcingHistoryEnabled),
            MSC_WS_COMMON.Bool_to_Number(PurgeSourcingHistory));

        IF(result = false) THEN
             RAISE submit_failed ;
        END IF ;

         -- submitting the request set
        error_tracking_num  := 170;
        req_id := fnd_submit.submit_set(NULL,FALSE);
        IF(req_id = 0) THEN
            RAISE submit_failed ;
        END IF ;

        status  := 'SUCCESS';
        processId := req_id;

  EXCEPTION
    WHEN submit_failed THEN
        status := 'ERROR_SUBMIT';
        processId := -1;
        RETURN;
    WHEN others THEN
        status := 'ERROR_UNEXPECTED_'||error_tracking_num;
        processId := -1;
        RETURN;

  END RunASCPCollections;

  PROCEDURE RunASCPCollections_Pub(
                 processId                         OUT NOCOPY NUMBER,
  	       status                             OUT NOCOPY VARCHAR2,
  	       UserName                           IN VARCHAR2,
  	       RespName                           IN VARCHAR2,
  	       RespApplName                       IN VARCHAR2,
  	       SecurityGroupName                  IN VARCHAR2,
  	       Language                           IN VARCHAR2,
                 InstanceID                         IN Number,
                 CollectionGroup                    IN VARCHAR2,
                 TotalWorkerNum                     IN  NUMBER,
                 Timeout                            IN  NUMBER,
                 OdsPURGEoption                     IN  VARCHAR2,
                 CollectionMethod                   IN  VARCHAR2,
                 AnalyzeTablesEnabled               IN  VARCHAR2,
                 ApprovedSupplierList               IN  VARCHAR2,
                 AtpRulesEnabled                    IN  VARCHAR2,
                 BomEnabled                         IN  VARCHAR2,
                 BorEnabled                         IN  VARCHAR2,
                 CalendarEnabled                    IN  VARCHAR2,
                 DemandClassEnabled                 IN  VARCHAR2,
                 ItemSubstEnabled                   IN  VARCHAR2,
                 ForecastEnabled                    IN  VARCHAR2,
                 ItemEnabled                        IN  VARCHAR2,
                 KpiBisEnabled                      IN  VARCHAR2,
                 MdsEnabled                         IN  VARCHAR2,
                 MpsEnabled                         IN  VARCHAR2,
                 OnHandEnabled                      IN  VARCHAR2,
                 ParameterEnabled                   IN  VARCHAR2,
                 PlannerEnabled                     IN  VARCHAR2,
                 PoReceiptsEnabled                  IN  VARCHAR2,
                 ProjectEnabled                     IN  VARCHAR2,
                 PurReqPoEnabled                    IN  VARCHAR2,
                 ReservesHardEnabled                IN  VARCHAR2,
                 ResourceAvailability               IN  VARCHAR2,
                 SafestockEnabled                   IN  VARCHAR2,
                 SalesorderRtype                    IN  VARCHAR2,
                 SourcingHistoryEnabled             IN  VARCHAR2,
                 SourcingEnabled                    IN  VARCHAR2,
                 SubInvEnabled                      IN  VARCHAR2,

                 SupplierResponseEnabled            IN  VARCHAR2,
                 TpCustomerEnabled                  IN  VARCHAR2,
                 TripEnabled                        IN  VARCHAR2,
                 UnitNoEnabled                      IN  VARCHAR2,
                 UomEnabled                         IN  VARCHAR2,
                 UserCompanyAssoc                   IN  VARCHAR2,
                 UserSupplyDemand                   IN  VARCHAR2,
                 WipEnabled                         IN  VARCHAR2,
                 SalesChannelEnabled                IN  VARCHAR2,
                 FiscalCalendarEnabled              IN  VARCHAR2,
                 InternalRepairEnabled               IN  VARCHAR2,
                 ExternalRepairEnabled               IN  VARCHAR2,
      	       PaybackDemandSupplyEnabled         IN VARCHAR2,
                 CurrencyConversionEnabled          IN VARCHAR2,
                 DeliveryDetailsEnabled             IN VARCHAR2,

                 Odstotalworkernum                  IN  NUMBER,
                 RecalcResAvailability              IN  VARCHAR2,
                 PurgeSourcingHistory               IN  VARCHAR2
                ) AS
    userid    number;
    respid    number;
    l_String VARCHAR2(30);
    error_tracking_num number;
    l_SecutirtGroupId  NUMBER;
   BEGIN
     error_tracking_num :=2010;
      MSC_WS_COMMON.GET_PERMISSION_IDS(l_String, userid, respid, l_SecutirtGroupId, UserName, RespName, RespApplName, SecurityGroupName, Language);
      IF (l_String <> 'OK') THEN
          Status := l_String;
          RETURN;
      END IF;
       error_tracking_num :=2020;
      MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, userid, respid,'MSC_FNDRSRUN_COLL', l_SecutirtGroupId);
      IF (l_String <> 'OK') THEN
          Status := l_String;
          RETURN;
      END IF;

      error_tracking_num :=2040;


    RunASCPCollections (  Status,
       processId,
                          userid,
                          respid,
                          InstanceID,
                          CollectionGroup,
                          TotalWorkerNum,
                          Timeout,
                          OdsPURGEoption ,
                 CollectionMethod                   ,
                 AnalyzeTablesEnabled ,
                 ApprovedSupplierList  ,
                 AtpRulesEnabled ,
                 BomEnabled  ,
                 BorEnabled  ,
                 CalendarEnabled  ,
                 DemandClassEnabled  ,
                 ItemSubstEnabled ,
                 ForecastEnabled ,
                 ItemEnabled ,
                 KpiBisEnabled  ,
                 MdsEnabled  ,
                 MpsEnabled ,
                 OnHandEnabled  ,
                 ParameterEnabled ,
                 PlannerEnabled  ,
                 PoReceiptsEnabled ,
                 ProjectEnabled  ,
                 PurReqPoEnabled ,
                 ReservesHardEnabled ,
                 ResourceAvailability ,
                 SafestockEnabled ,
                 SalesorderRtype ,
                 SourcingHistoryEnabled ,
                 SourcingEnabled ,
                 SubInvEnabled  ,

                 SupplierResponseEnabled ,
                 TpCustomerEnabled ,
                 TripEnabled ,
                 UnitNoEnabled  ,
                 UomEnabled ,
                 UserCompanyAssoc  ,
                 UserSupplyDemand  ,
                 WipEnabled  ,
                 SalesChannelEnabled  ,
                 FiscalCalendarEnabled  ,
                 InternalRepairEnabled  ,
                 ExternalRepairEnabled  ,
  	       PaybackDemandSupplyEnabled ,
                 CurrencyConversionEnabled ,
                 DeliveryDetailsEnabled  ,

                 Odstotalworkernum ,
                 RecalcResAvailability ,
                 PurgeSourcingHistory );
     --      dbms_output.put_line('USERID=' || userid);


        EXCEPTION
        WHEN others THEN
           status := 'ERROR_UNEXPECTED_'||error_tracking_num;

           return;


  END RunASCPCollections_Pub;




 -- =============================================================
 -- Desc: Please see package spec file for description
 -- =============================================================
  PROCEDURE RunODSLoad(
			     status                    OUT NOCOPY VARCHAR2,
			     processId		       OUT NOCOPY VARCHAR2,
                             UserID                    IN NUMBER ,
                             ResponsibilityID          IN NUMBER ,
			     InstanceId                IN  NUMBER ,
                             Timeout                   IN  NUMBER ,
			     TotalWorkerNum            IN  NUMBER ,
			     RecalcResAvailability     IN  VARCHAR2 ,
			     RecalcSourcingHistory     IN  VARCHAR2  ,
			     PurgeSourcingHistory      IN  VARCHAR2
                             ) as
  L_VAL_RESULT VARCHAR2(30);
  result BOOLEAN := false;
  req_id NUMBER:=0;
  submit_failed EXCEPTION;
  error_tracking_num  NUMBER;
  BEGIN
        error_tracking_num :=100;
        MSC_WS_COMMON.VALIDATE_USER_RESP (L_VAL_RESULT, UserId, ResponsibilityID);
        IF (L_VAL_RESULT <> 'OK') THEN
           PROCESSID := -1;
           STATUS := L_VAL_RESULT;
           RETURN;
        END IF;

        error_tracking_num :=120;
        result := isValid_INSTANCE_ID( InstanceId);
        IF (result = false) THEN
           PROCESSID := -1;
           STATUS := 'INVALID_INSTANCE_ID';
           RETURN;
        END IF;

        error_tracking_num :=130;
        IF (TotalWorkerNum < 1)THEN
           PROCESSID := -1;
           STATUS := 'INVALID_WORKER_NUMBER';
           RETURN;
        END IF;

        error_tracking_num :=140;
        IF (Timeout < 0)THEN
           PROCESSID := -1;
           STATUS := 'INVALID_TIMEOUT';
           RETURN;
        END IF;

        -- register Planning ODS Load
        error_tracking_num :=150;
        req_id := fnd_request.submit_request('MSC','MSCPDC','Planning ODS Load',NULL, false,
                                              InstanceId, Timeout, TotalWorkerNum,
                                               MSC_WS_COMMON.Bool_to_Number(RecalcResAvailability),
                                               MSC_WS_COMMON.Bool_to_Number(RecalcSourcingHistory),
                                               MSC_WS_COMMON.Bool_to_Number(PurgeSourcingHistory));

        IF(req_id = 0) THEN
               raise submit_failed ;
         END IF ;

        status  := 'SUCCESS';
        processId := req_id;

    EXCEPTION
    WHEN submit_failed THEN
        status := 'ERROR_SUBMIT';
        processId := -1;
        RETURN;
    WHEN others THEN
        status := 'ERROR_UNEXPECTED_'||error_tracking_num;
        processId := -1;
        RETURN;

  END RunODSLoad;

  PROCEDURE RunODSLoad_Pub(
                   processId                         OUT NOCOPY NUMBER,
  			           status                             OUT NOCOPY VARCHAR2,
  			           UserName                           IN VARCHAR2,
  			           RespName                           IN VARCHAR2,
  			           RespApplName                       IN VARCHAR2,
  			           SecurityGroupName                  IN VARCHAR2,
  			           Language                           IN VARCHAR2,
                   InstanceId                IN  NUMBER ,
                   Timeout                   IN  NUMBER ,
                   TotalWorkerNum            IN  NUMBER ,
                   RecalcResAvailability     IN  VARCHAR2 ,
                   RecalcSourcingHistory     IN  VARCHAR2  ,
                   PurgeSourcingHistory      IN  VARCHAR2
                   ) AS
    userid    number;
    respid    number;
    l_String VARCHAR2(30);
    error_tracking_num number;
    l_SecutirtGroupId  NUMBER;
   BEGIN
     error_tracking_num :=2010;
      MSC_WS_COMMON.GET_PERMISSION_IDS(l_String, userid, respid, l_SecutirtGroupId, UserName, RespName, RespApplName, SecurityGroupName, Language);
      IF (l_String <> 'OK') THEN
          Status := l_String;
          RETURN;
      END IF;
       error_tracking_num :=2020;
      MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, userid, respid,'MSC_FNDRSRUN_COLL', l_SecutirtGroupId);
      IF (l_String <> 'OK') THEN
          Status := l_String;
          RETURN;
      END IF;

      error_tracking_num :=2040;


    RunODSLoad (
    		  status,
                  processId,
                  userid,
                  respid,
                  InstanceId,
                  Timeout,
                  TotalWorkerNum,
                  RecalcResAvailability,
                  RecalcSourcingHistory,
                  PurgeSourcingHistory );


     --      dbms_output.put_line('USERID=' || userid);


        EXCEPTION
        WHEN others THEN
           status := 'ERROR_UNEXPECTED_'||error_tracking_num;

           return;


END RunODSLoad_Pub;


 -- =============================================================
 -- Desc: Please see package spec file for description
 -- =============================================================
  PROCEDURE RunDemantraShipmentBooking(
            status                             OUT nocopy VARCHAR2,
            processid                          OUT nocopy VARCHAR2,
            UserID                             IN NUMBER,
            ResponsibilityID                   IN NUMBER,
            InstanceId 		               IN NUMBER,
            CollectionGroup       	       IN VARCHAR2,
            CollectionMethod     	       IN NUMBER,
            DateRangeType		       IN NUMBER,
            HistoryCollectionWindow            IN NUMBER DEFAULT NULL,
            DateFrom                           IN DATE DEFAULT NULL,
            DateTo                             IN DATE DEFAULT NULL,
            BHBookedItemsBookedDate	       IN VARCHAR2,
            BHBookedItemsRequestedDate	       IN VARCHAR2,
            BHRequestedItemsBookedDate	       IN VARCHAR2,
            BHRequestedItemsRequestedDate      IN VARCHAR2,
            SHShippedItemsShippedDate	       IN VARCHAR2,
            SHShippedItemsRequestedDate	       IN VARCHAR2,
            SHRequestedItemsShippedDate	       IN VARCHAR2,
            SHRequestedItemsRequestedDate      IN VARCHAR2,
            CollectISO			       IN VARCHAR2,
            CollectAllOrderTypes	       IN VARCHAR2,
            IncludeOrderTypes                  IN VARCHAR2 DEFAULT NULL,
            ExcludeOrderTypes                  IN VARCHAR2 DEFAULT NULL,
            LaunchDownload     	               IN VARCHAR2
) IS
  L_VAL_RESULT VARCHAR2(30);
  result BOOLEAN := false;
  req_id NUMBER:=0;
  submit_failed EXCEPTION;
  hiddenParam VARCHAR2(80);
  error_tracking_num NUMBER;
  passedCollectionGroup varchar2(100);
    BEGIN
        /*  VALIDATE: InstanceId, CollectionGroup , CollectionMethod,DateRangeType*/
        /* for CollectAllOrderTypes = no , EITHER IncludeOrderTypes non empty, or ExcludeOrderTypes not empty, but not both*/

        error_tracking_num := 100;
        MSC_WS_COMMON.VALIDATE_USER_RESP (L_VAL_RESULT, UserId, ResponsibilityID);
        IF (L_VAL_RESULT <> 'OK') THEN
           PROCESSID := -1;
           STATUS := L_VAL_RESULT;
           RETURN;
        END IF;

        error_tracking_num := 110;
        result := isValid_INSTANCE_ID( InstanceId);
        IF (result = false) THEN
           PROCESSID := -1;
           STATUS := 'INVALID_INSTANCE_ID';
           RETURN;
        END IF;

        error_tracking_num := 120;
        result := isValid_DEM_COLLECTION_GROUP( CollectionGroup, InstanceId) ;
        IF (result = false) THEN
           PROCESSID := -1;
           STATUS := 'INVALID_COLLECTION_GROUP';
           RETURN;
        END IF;

        error_tracking_num := 130;
        result := isValid_DEM_COLLECTION_METHOD( CollectionMethod) ;
        IF (result = false) THEN
           PROCESSID := -1;
           STATUS := 'INVALID_COLLECTION_METHOD';
           RETURN;
        END IF;


        hiddenParam := '1';

        error_tracking_num := 140;
        result := isValid_DATE_RANGE_TYPE(CollectionMethod, DateRangeType );
        IF (result = false) THEN
           PROCESSID := -1;
           STATUS := 'INVALID_DATE_RANGE_TYPE';
           RETURN;
        END IF;

        error_tracking_num := 145;
        result := isValid_Dates( DateRangeType, DateFrom, DateTo );
        IF (result = false) THEN
           PROCESSID := -1;
           STATUS := 'INVALID_DATES';
           RETURN;
        END IF;

        error_tracking_num := 149;
          -- for 'rolling' dateRange Type, HistoryCollectionWindow cannot be null
        IF ( DateRangeType = 2) THEN
            IF ( HistoryCollectionWindow is NULL ) THEN
                PROCESSID := -1;
                STATUS := 'INVALID_HISTORY_COLLECTION_WINDOW';
               RETURN;
            END IF;
        END IF;

        error_tracking_num := 150;
        result := isValid_Sel_Of_OrderTypes( CollectAllOrderTypes, IncludeOrderTypes, ExcludeOrderTypes );
        IF (result = false) THEN
           PROCESSID := -1;
           STATUS := 'INVALID_ORDER_TYPE_SELECTION';
           RETURN;
        END IF;


       -- initiating request set
        error_tracking_num := 160;
        result := fnd_submit.set_request_set('MSD','MSDDEMRSCH');
        IF(result = false) THEN
               RAISE submit_failed ;
         END IF ;

passedCollectionGroup := CollectionGroup;
-- fixed done dor bug 6837675
--if ( CollectionGroup = 'All') then
--    passedCollectionGroup := '-999';
--end if;
         -- Stage 1 Collect Shipment and booking History
        error_tracking_num := 170;
         result := fnd_submit.submit_program('MSD','MSDDEMCHD','MSDDEMRSCHD',
            InstanceId,passedCollectionGroup, CollectionMethod,hiddenParam,
            DateRangeType,  HistoryCollectionWindow,
            to_char(DateFrom, 'YYYY/MM/DD HH24:MI:SS'), to_char(DateTo, 'YYYY/MM/DD HH24:MI:SS'),
            MSC_WS_COMMON.Bool_to_Number(BHBookedItemsBookedDate),
            MSC_WS_COMMON.Bool_to_Number(BHBookedItemsRequestedDate),
            MSC_WS_COMMON.Bool_to_Number(BHRequestedItemsBookedDate),
            MSC_WS_COMMON.Bool_to_Number(BHRequestedItemsRequestedDate),
            MSC_WS_COMMON.Bool_to_Number(SHShippedItemsShippedDate),
            MSC_WS_COMMON.Bool_to_Number(SHShippedItemsRequestedDate),
            MSC_WS_COMMON.Bool_to_Number(SHRequestedItemsShippedDate),
            MSC_WS_COMMON.Bool_to_Number(SHRequestedItemsRequestedDate),
            MSC_WS_COMMON.Bool_to_Number(CollectISO),
            MSC_WS_COMMON.Bool_to_Number(CollectAllOrderTypes ),
            IncludeOrderTypes,
            ExcludeOrderTypes,
            MSC_WS_COMMON.Bool_to_Number(LaunchDownload )
         );

           IF(result = false) THEN
                RAISE submit_failed ;
           END IF ;

        -- Stage 2 Push Setup Params
        error_tracking_num := 180;
         result := fnd_submit.submit_program('MSD','MSDDEMPSP','MSDDEMRSPSP',
                    InstanceId,passedCollectionGroup);

           IF(result = false) THEN
                RAISE submit_failed ;
           END IF ;

         -- Stage 3 Populate Staging Tables
         -- Stage 3.1 Collect Level Type
         error_tracking_num := 190;
         result := fnd_submit.submit_program('MSD','MSDDEMCLT','MSDDEMRSPST',
                    InstanceId, 2);

           IF(result = false) THEN
                RAISE submit_failed ;
           END IF ;

          -- Stage 3.2 Collect Level Type
         error_tracking_num := 200;
         result := fnd_submit.submit_program('MSD','MSDDEMCLT','MSDDEMRSPST',
                    InstanceId, 1);

           IF(result = false) THEN
                RAISE submit_failed ;
           END IF ;

           -- Stage 3.3 Update Level Codes
           error_tracking_num := 210;
           result := fnd_submit.submit_program('MSD','MSDDEMULC','MSDDEMRSPST',
                    InstanceId, 'SITE', Dem_ULC_GetDestTableName(), 'DM_SITE_CODE', 'EBS_SITE_SR_PK');

           IF(result = false) THEN
                RAISE submit_failed ;
           END IF ;

              -- Stage 3.4 Collect Time
          error_tracking_num := 220;
          result := fnd_submit.submit_program('MSD','MSDDEMCTD','MSDDEMRSPST',
                    MSC_WS_COMMON.Bool_to_Number(LaunchDownload ));

           IF(result = false) THEN
                RAISE submit_failed ;
           END IF ;

               -- Stage 4 Launch EP Load
          error_tracking_num := 230;
          result := fnd_submit.submit_program('MSD','MSDDEMARD','MSDDEMRSLH',
                    MSC_WS_COMMON.Bool_to_Number(LaunchDownload ));

           IF(result = false) THEN
                RAISE submit_failed ;
           END IF ;

            -- submitting  the  request set
           error_tracking_num := 240;
           req_id := fnd_submit.submit_set(NULL,FALSE);
           IF(req_id = 0) THEN
               RAISE submit_failed ;
           END IF ;

            status  := 'SUCCESS';
            processId := req_id;

    EXCEPTION
    WHEN submit_failed THEN
        status := 'ERROR_SUBMIT';
        processId := -1;
        RETURN;
    WHEN others THEN
        status := 'ERROR_UNEXPECTED_'||error_tracking_num;
        processId := -1;
        RETURN;

    END RunDemantraShipmentBooking;


    PROCEDURE RunDemantraShipmentBooking_Pub(
                processId                         OUT NOCOPY NUMBER,
    	    status                             OUT NOCOPY VARCHAR2,
    	    UserName                           IN VARCHAR2,
    	    RespName                           IN VARCHAR2,
    	    RespApplName                       IN VARCHAR2,
    	    SecurityGroupName                  IN VARCHAR2,
    	    Language                           IN VARCHAR2,
                InstanceId 		               IN NUMBER,
                CollectionGroup       	       IN VARCHAR2,
                CollectionMethod     	       IN NUMBER,
                DateRangeType		       IN NUMBER,
                HistoryCollectionWindow            IN NUMBER DEFAULT NULL,
                DateFrom                           IN DATE DEFAULT NULL,
                DateTo                             IN DATE DEFAULT NULL,
                BHBookedItemsBookedDate	       IN VARCHAR2,
                BHBookedItemsRequestedDate	       IN VARCHAR2,
                BHRequestedItemsBookedDate	       IN VARCHAR2,
                BHRequestedItemsRequestedDate      IN VARCHAR2,
                SHShippedItemsShippedDate	       IN VARCHAR2,
                SHShippedItemsRequestedDate	       IN VARCHAR2,
                SHRequestedItemsShippedDate	       IN VARCHAR2,
                SHRequestedItemsRequestedDate      IN VARCHAR2,
                CollectISO			       IN VARCHAR2,
                CollectAllOrderTypes	       IN VARCHAR2,
                IncludeOrderTypes                  IN VARCHAR2 DEFAULT NULL,
                ExcludeOrderTypes                  IN VARCHAR2 DEFAULT NULL,
                LaunchDownload     	               IN VARCHAR2
                ) AS
      userid    number;
      respid    number;
      l_String VARCHAR2(30);
      error_tracking_num number;
      l_SecutirtGroupId  NUMBER;
     BEGIN
       error_tracking_num :=2010;
        MSC_WS_COMMON.GET_PERMISSION_IDS(l_String, userid, respid, l_SecutirtGroupId, UserName, RespName, RespApplName, SecurityGroupName, Language);
        IF (l_String <> 'OK') THEN
            Status := l_String;
            RETURN;
        END IF;
         error_tracking_num :=2020;
        MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, userid, respid,'MSD_DEM_FNDRSRUN_CHD', l_SecutirtGroupId);
        IF (l_String <> 'OK') THEN
            Status := l_String;
            RETURN;
        END IF;

        error_tracking_num :=2040;


      RunDemantraShipmentBooking(   Status,
                                    processid,
                                    userid,
                                    respid,
                                    InstanceId,
                                    CollectionGroup,
                                    CollectionMethod,
                                    DateRangeType,
                HistoryCollectionWindow,
                DateFrom,
                DateTo ,
                BHBookedItemsBookedDate,
                BHBookedItemsRequestedDate,
                BHRequestedItemsBookedDate,
                BHRequestedItemsRequestedDate,
                SHShippedItemsShippedDate,
                SHShippedItemsRequestedDate,
                SHRequestedItemsShippedDate,
                SHRequestedItemsRequestedDate,
                CollectISO,
                CollectAllOrderTypes,
                IncludeOrderTypes,
                ExcludeOrderTypes,
                LaunchDownload);


          EXCEPTION
          WHEN others THEN
             status := 'ERROR_UNEXPECTED_'||error_tracking_num;

             return;


END RunDemantraShipmentBooking_Pub;

 -- =============================================================
 -- Desc: Please see package spec file for description
 -- =============================================================
    PROCEDURE RunDemantraSCIData (
                            status	  	OUT NOCOPY VARCHAR2,
                            processid 		OUT NOCOPY VARCHAR2,
                            UserID              IN NUMBER,
                            ResponsibilityID    IN NUMBER,
                            InstanceId		IN NUMBER,
                            CollectionGroup     IN VARCHAR2,
                            CollectionMethod    IN NUMBER,
                            DateRangeType       IN NUMBER,
                            HistoryCollectionWindow          IN NUMBER DEFAULT NULL,
                            DateFrom                         IN DATE DEFAULT NULL,
                            DateTo                           IN DATE DEFAULT NULL
  ) is
  L_VAL_RESULT VARCHAR2(30);
  result BOOLEAN := false;
  req_id NUMBER:=0;
  submit_failed EXCEPTION;
  hiddenParam VARCHAR2(80);
  error_tracking_number NUMBER;
  passedCollectionGroup varchar2(100);
  BEGIN
        /* validate: Instanceid, CollectionGroup, CollectionMenthod, DateRangeType*/

        error_tracking_number := 100;
        MSC_WS_COMMON.VALIDATE_USER_RESP (L_VAL_RESULT, UserId, ResponsibilityID);
        IF (L_VAL_RESULT <> 'OK') THEN
           PROCESSID := -1;
           STATUS := L_VAL_RESULT;
           RETURN;
        END IF;

        error_tracking_number := 110;
        result := isValid_INSTANCE_ID( InstanceId);
        IF (result = false) THEN
           PROCESSID := -1;
           STATUS := 'INVALID_INSTANCE_ID';
           RETURN;
        END IF;

        error_tracking_number := 120;
        result := isValid_DEM_COLLECTION_GROUP( CollectionGroup, InstanceId) ;
        IF (result = false) THEN
           PROCESSID := -1;
           STATUS := 'INVALID_COLLECTION_GROUP';
           RETURN;
        END IF;

        error_tracking_number := 130;
        result := isValid_DEM_COLLECTION_METHOD( CollectionMethod) ;
        IF (result = false) THEN
           PROCESSID := -1;
           STATUS := 'INVALID_COLLECTION_METHOD';
           RETURN;
        END IF;

        hiddenParam := '1';

        error_tracking_number := 140;
        result := isValid_DATE_RANGE_TYPE(CollectionMethod, DateRangeType );
        IF (result = false) THEN
           PROCESSID := -1;
           STATUS := 'INVALID_DATE_RANGE_TYPE';
           RETURN;
        END IF;

        error_tracking_number := 145;
        result := isValid_Dates( DateRangeType, DateFrom, DateTo );
        IF (result = false) THEN
           PROCESSID := -1;
           STATUS := 'INVALID_DATES';
           RETURN;
        END IF;

        error_tracking_number := 149;
          -- for 'rolling' dateRange Type, HistoryCollectionWindow cannot be null
        IF ( DateRangeType = 2) THEN
            IF ( HistoryCollectionWindow is NULL ) THEN
                PROCESSID := -1;
                STATUS := 'INVALID_HISTORY_COLLECTION_WINDOW';
               RETURN;
            END IF;
        END IF;

passedCollectionGroup := CollectionGroup;
-- bug 6837675
--if ( CollectionGroup = 'All') then
--    passedCollectionGroup := '-999';
--end if;
        -- register Collect SCI Data
        error_tracking_number := 150;
        req_id := fnd_request.submit_request('MSD','MSDDEMCSD','Collect SCI Data',NULL, false,
                                              InstanceId, passedCollectionGroup, CollectionMethod,
                                              hiddenParam, DateRangeType, HistoryCollectionWindow,
                                              to_char(DateFrom, 'YYYY/MM/DD HH24:MI:SS'), to_char(DateTo, 'YYYY/MM/DD HH24:MI:SS'));


        IF(req_id = 0) THEN
               RAISE submit_failed ;
         END IF ;

      status  := 'SUCCESS';
      processId := req_id;

    EXCEPTION
    WHEN submit_failed THEN
        status := 'ERROR_SUBMIT';
        processId := -1;
        RETURN;
    WHEN others THEN
        status := 'ERROR_UNEXPECTED_'||error_tracking_number;
        processId := -1;
        RETURN;

  END RunDemantraSCIData;

  PROCEDURE RunDemantraSCIData_Pub(
                  processId                         OUT NOCOPY NUMBER,
  		status                             OUT NOCOPY VARCHAR2,
  		 UserName                           IN VARCHAR2,
  			         RespName                           IN VARCHAR2,
  			         RespApplName                       IN VARCHAR2,
  			         SecurityGroupName                  IN VARCHAR2,
  			         Language                           IN VARCHAR2,
                  InstanceId		        IN NUMBER,
                  CollectionGroup                 IN VARCHAR2,
                  CollectionMethod                IN NUMBER,
                  DateRangeType                   IN NUMBER,
                  HistoryCollectionWindow         IN NUMBER DEFAULT NULL,
                  DateFrom                        IN DATE DEFAULT NULL,
                  DateTo                          IN DATE DEFAULT NULL
                  )  AS
    userid    number;
    respid    number;
    l_String VARCHAR2(30);
    error_tracking_num number;
    l_SecutirtGroupId  NUMBER;
   BEGIN
     error_tracking_num :=2010;
      MSC_WS_COMMON.GET_PERMISSION_IDS(l_String, userid, respid, l_SecutirtGroupId, UserName, RespName, RespApplName, SecurityGroupName, Language);
      IF (l_String <> 'OK') THEN
          Status := l_String;
          RETURN;
      END IF;
       error_tracking_num :=2020;
      MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, userid,respid,'MSD_DEM_FNDRSRUN_SCI', l_SecutirtGroupId);
      IF (l_String <> 'OK') THEN
          Status := l_String;
          RETURN;
      END IF;

      error_tracking_num :=2040;


    RunDemantraSCIData(   Status,
    processid,
                          userid,
                          respid,
                          InstanceId,
                          CollectionGroup,
                          CollectionMethod,
                          DateRangeType,
                          HistoryCollectionWindow,
                          DateFrom ,
                          DateTo    );



        EXCEPTION
        WHEN others THEN
           status := 'ERROR_UNEXPECTED_'||error_tracking_num;

           return;


  END RunDemantraSCIData_Pub;



 -- =============================================================
 -- Desc: Please see package spec file for description
 -- =============================================================
  PROCEDURE RunDemantraCurrConversion(
                        status	  		OUT NOCOPY VARCHAR2,
      			processid 		OUT NOCOPY VARCHAR2,
                        UserID                  IN NUMBER,
                        ResponsibilityID        IN NUMBER,
                        InstanceId              IN NUMBER,
                        DateFrom                IN DATE DEFAULT NULL,
                        DateTo                  IN DATE DEFAULT NULL,
                        CollectAllCurrencies    IN VARCHAR2,
                        IncludeCurrencyList     IN VARCHAR2 DEFAULT NULL,
                        ExcludeCurrencyList     IN VARCHAR2 DEFAULT NULL
                        ) is
  L_VAL_RESULT VARCHAR2(30);
  result BOOLEAN := false;
  req_id NUMBER:=0;
  submit_failed EXCEPTION;
  hiddenParam VARCHAR2(80);
  error_tracking_number NUMBER;
    BEGIN

       error_tracking_number:= 100;
        MSC_WS_COMMON.VALIDATE_USER_RESP (L_VAL_RESULT, UserId, ResponsibilityID);
        IF (L_VAL_RESULT <> 'OK') THEN
           PROCESSID := -1;
           STATUS := L_VAL_RESULT;
           RETURN;
        END IF;

       error_tracking_number:= 110;
        result := isValid_INSTANCE_ID( InstanceId);
        IF (result = false) THEN
           PROCESSID := -1;
           STATUS := 'INVALID_INSTANCE_ID';
           RETURN;
        END IF;

        error_tracking_number := 111;
        IF (DateFrom > DateTo) THEN
           PROCESSID := -1;
           STATUS := 'INVALID_DATES';
           RETURN;
        END IF;


        error_tracking_number:= 120;
        result:= isValid_Sel_Of_OrderTypes( CollectAllCurrencies , IncludeCurrencyList, ExcludeCurrencyList );
        IF (result = false) THEN
           PROCESSID := -1;
           STATUS := 'INVALID_SELECTION_CURRENCY_LIST';
           RETURN;
        END IF;


        -- register Collect Currency
        error_tracking_number:= 130;
        req_id := fnd_request.submit_request('MSD','MSDDEMCCONV','Collect Currency',NULL, false,
                                              InstanceId,
                                              to_char(DateFrom, 'YYYY/MM/DD HH24:MI:SS'), to_char(DateTo, 'YYYY/MM/DD HH24:MI:SS'),
                                              MSC_WS_COMMON.Bool_to_Number(CollectAllCurrencies),
                                              IncludeCurrencyList,
                                              ExcludeCurrencyList
                                              );


        IF(req_id = 0) THEN
               RAISE submit_failed ;
        END IF ;

      status  := 'SUCCESS';
      processId := req_id;

    EXCEPTION
    WHEN submit_failed THEN
        status := 'ERROR_SUBMIT';
        processId := -1;
        RETURN;
    WHEN others THEN
        status := 'ERROR_UNEXPECTED_'||error_tracking_number;
        processId := -1;
        RETURN;

    END RunDemantraCurrConversion;


PROCEDURE RunDemantraCurrConversion_Pub(
                 processId                         OUT NOCOPY NUMBER,
		 status                             OUT NOCOPY VARCHAR2,
		 UserName                           IN VARCHAR2,
		 RespName                           IN VARCHAR2,
		 RespApplName                       IN VARCHAR2,
		 SecurityGroupName                  IN VARCHAR2,
		 Language                           IN VARCHAR2,
                 InstanceId              IN NUMBER,
                 DateFrom                IN DATE DEFAULT NULL,
                 DateTo                  IN DATE DEFAULT NULL,
                 CollectAllCurrencies    IN VARCHAR2,
                 IncludeCurrencyList     IN VARCHAR2 DEFAULT NULL,
                 ExcludeCurrencyList     IN VARCHAR2 DEFAULT NULL
                ) AS
  userid    number;
  respid    number;
  l_String VARCHAR2(30);
  error_tracking_num number;
  l_SecutirtGroupId  NUMBER;
 BEGIN
   error_tracking_num :=2010;
    MSC_WS_COMMON.GET_PERMISSION_IDS(l_String, userid, respid, l_SecutirtGroupId, UserName, RespName, RespApplName, SecurityGroupName, Language);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;
     error_tracking_num :=2020;
    MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, userid, respid, 'MSD_DEM_FNDRSRUN_CURCONV',l_SecutirtGroupId);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;

    error_tracking_num :=2040;


  RunDemantraCurrConversion(   Status,
                               processid,
                        userid,
                        respid,
                        InstanceId,
                        DateFrom ,
                        DateTo ,
                        CollectAllCurrencies,
                        IncludeCurrencyList,
                        ExcludeCurrencyList   );


      EXCEPTION
      WHEN others THEN
         status := 'ERROR_UNEXPECTED_'||error_tracking_num;

         return;


END RunDemantraCurrConversion_Pub;
 -- =============================================================
 -- Desc: Please see package spec file for description
 -- =============================================================
  PROCEDURE RunDemantraUOMConversion(
                        status	  		OUT NOCOPY VARCHAR2,
      			processid 		OUT NOCOPY VARCHAR2,
                        UserID                  IN NUMBER,
                        ResponsibilityID        IN NUMBER,
                        InstanceId              IN NUMBER,
                        IncludeAll              IN VARCHAR2,
                        IncludeUomList          IN VARCHAR2 DEFAULT NULL,
                        ExcludeUomList          IN VARCHAR2 DEFAULT NULL
                        ) is
  L_VAL_RESULT VARCHAR2(30);
  result BOOLEAN := false;
  req_id NUMBER:=0;
  submit_failed EXCEPTION;
  error_tracking_number NUMBER;
    BEGIN

        error_tracking_number  := 100;
        MSC_WS_COMMON.VALIDATE_USER_RESP (L_VAL_RESULT, UserId, ResponsibilityID);
        IF (L_VAL_RESULT <> 'OK') THEN
           PROCESSID := -1;
           STATUS := L_VAL_RESULT;
           RETURN;
        END IF;

        error_tracking_number  := 110;
        result := isValid_INSTANCE_ID( InstanceId);
        IF (result = false) THEN
           PROCESSID := -1;
           STATUS := 'INVALID_INSTANCE_ID';
           RETURN;
        END IF;

        error_tracking_number  := 120;
        result:= isValid_Sel_Of_OrderTypes( IncludeAll , IncludeUomList, ExcludeUomList );
        IF (result = false) THEN
           PROCESSID := -1;
           STATUS := 'INVALID_SELECTION_UOM_LIST';
           RETURN;
        END IF;


        -- register Collect UOM Conversions
        error_tracking_number  := 130;
        req_id := fnd_request.submit_request('MSD','MSDDEMUOM','UOM Conversions',NULL, false,
                                              InstanceId,
                                              MSC_WS_COMMON.Bool_to_Number(IncludeAll),
                                              IncludeUomList,
                                              ExcludeUomList
                                              );


        IF(req_id = 0) THEN
               raise submit_failed ;
        END IF ;

      status  := 'SUCCESS';
      processId := req_id;

    EXCEPTION
    WHEN submit_failed THEN
        status := 'ERROR_SUBMIT';
        processId := -1;
        RETURN;
    WHEN others THEN
        status := 'ERROR_UNEXPECTED_'||error_tracking_number;
        processId := -1;
        RETURN;

   END RunDemantraUOMConversion;

   PROCEDURE RunDemantraUOMConversion_Pub(
                                 processId                          OUT NOCOPY NUMBER,
   			         status                             OUT NOCOPY VARCHAR2,
   			         UserName                           IN VARCHAR2,
   			         RespName                           IN VARCHAR2,
   			         RespApplName                       IN VARCHAR2,
   			         SecurityGroupName                  IN VARCHAR2,
   			         Language                           IN VARCHAR2,
                                 InstanceId              IN NUMBER,
                                 IncludeAll              IN VARCHAR2,
                                 IncludeUomList          IN VARCHAR2 DEFAULT NULL,
                                 ExcludeUomList          IN VARCHAR2 DEFAULT NULL
                   ) AS
     userid    number;
     respid    number;
     l_String VARCHAR2(30);
     error_tracking_num number;
     l_SecutirtGroupId  NUMBER;
    BEGIN
      error_tracking_num :=2010;
       MSC_WS_COMMON.GET_PERMISSION_IDS(l_String, userid, respid, l_SecutirtGroupId, UserName, RespName, RespApplName, SecurityGroupName, Language);
       IF (l_String <> 'OK') THEN
           status := l_String;
           RETURN;
       END IF;
        error_tracking_num :=2020;
       MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, userid, respid,'MSD_DEM_FNDRSRUN_UOM', l_SecutirtGroupId);
       IF (l_String <> 'OK') THEN
           status := l_String;
           RETURN;
       END IF;

       error_tracking_num :=2040;


     RunDemantraUOMConversion(
                           status,
                           processid,
                           userid,
                           respid,
                           InstanceId ,
                           IncludeAll,
                           IncludeUomList ,
                           ExcludeUomList  );



         EXCEPTION
         WHEN others THEN
            status := 'ERROR_UNEXPECTED_'||error_tracking_num||'_'||sqlerrm;

            return;


END RunDemantraUOMConversion_Pub;

 -- =============================================================
 -- Desc: Please see package spec file for description
 -- =============================================================
   PROCEDURE RunDemantraPricingData(
                        status	  		OUT NOCOPY VARCHAR2,
      			processid 		OUT NOCOPY VARCHAR2,
                        UserID                  IN NUMBER,
                        ResponsibilityID        IN NUMBER,
                        InstanceId              IN NUMBER,
                        DateFrom                IN DATE,
                        DateTo                  IN DATE,
                        IncludeAllLists         IN VARCHAR2,
                        IncludePriceList        IN VARCHAR2 DEFAULT NULL,
                        ExcludePriceList        IN VARCHAR2 DEFAULT NULL
                        ) is
  L_VAL_RESULT VARCHAR2(30);
  result BOOLEAN := false;
  req_id NUMBER:=0;
  submit_failed EXCEPTION;
  error_tracking_number NUMBER;
    BEGIN

        error_tracking_number := 100;
        MSC_WS_COMMON.VALIDATE_USER_RESP (L_VAL_RESULT, UserId, ResponsibilityID);
        IF (L_VAL_RESULT <> 'OK') THEN
           PROCESSID := -1;
           STATUS := L_VAL_RESULT;
           RETURN;
        END IF;

        error_tracking_number := 110;
        result := isValid_INSTANCE_ID( InstanceId);
        IF (result = false) THEN
           PROCESSID := -1;
           STATUS := 'INVALID_INSTANCE_ID';
           RETURN;
        END IF;

         IF (DateFrom is NULL) THEN
           PROCESSID := -1;
           STATUS := 'INVALID_DATEFROM_CANNOT_BE_NULL';
           RETURN;
        END IF;

	 IF (DateTo is NULL) THEN
           PROCESSID := -1;
           STATUS := 'INVALID_DATETO_CANNOT_BE_NULL';
           RETURN;
        END IF;

        IF (DateFrom > DateTo) THEN
           PROCESSID := -1;
           STATUS := 'INVALID_DATES';
           RETURN;
        END IF;

        error_tracking_number := 120;
        result:= isValid_Sel_Of_OrderTypes( IncludeAllLists , IncludePriceList, ExcludePriceList );
        IF (result = false) THEN
           PROCESSID := -1;
           STATUS := 'INVALID_SELECTION_PRICE_LIST';
           RETURN;
        END IF;


        -- register Collect Price Lists
        error_tracking_number := 130;
        req_id := fnd_request.submit_request('MSD','MSDDEMPRL','Collect Price Lists',NULL, false,
                                              InstanceId,
                                              to_char(DateFrom, 'YYYY/MM/DD HH24:MI:SS'),
                                              to_char(DateTo, 'YYYY/MM/DD HH24:MI:SS'),
                                              MSC_WS_COMMON.Bool_to_Number(IncludeAllLists),
                                              IncludePriceList,
                                              ExcludePriceList
                                              );


        IF(req_id = 0) THEN
               RAISE submit_failed ;
         END IF ;

      status  := 'SUCCESS';
      processId := req_id;

    EXCEPTION
    WHEN submit_failed THEN
        status := 'ERROR_SUBMIT';
        processId := -1;
        RETURN;
    WHEN others THEN
        status := 'ERROR_UNEXPECTED_'||error_tracking_number;
        processId := -1;
        RETURN;


   END RunDemantraPricingData;

PROCEDURE RunDemantraPricingData_Pub(
                 processId                         OUT NOCOPY NUMBER,
			         status                             OUT NOCOPY VARCHAR2,
			         UserName                           IN VARCHAR2,
			         RespName                           IN VARCHAR2,
			         RespApplName                       IN VARCHAR2,
			         SecurityGroupName                  IN VARCHAR2,
			         Language                           IN VARCHAR2,
                InstanceId              IN NUMBER,
                DateFrom                IN DATE,
                DateTo                  IN DATE,
                IncludeAllLists         IN VARCHAR2,
                IncludePriceList        IN VARCHAR2 DEFAULT NULL,
                ExcludePriceList        IN VARCHAR2 DEFAULT NULL
            )AS
  userid    number;
  respid    number;
  l_String VARCHAR2(30);
  error_tracking_num number;
  l_SecutirtGroupId  NUMBER;
 BEGIN
   error_tracking_num :=2010;
    MSC_WS_COMMON.GET_PERMISSION_IDS(l_String, userid, respid, l_SecutirtGroupId, UserName, RespName, RespApplName, SecurityGroupName, Language);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;
     error_tracking_num :=2020;
    MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, userid, respid,'MSD_DEM_FNDRSRUN_PRL', l_SecutirtGroupId);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;

    error_tracking_num :=2040;


  RunDemantraPricingData(   Status,
                            processid ,
                            userid,
                            respid,
                            InstanceId,
                            DateFrom,
                            DateTo,
                            IncludeAllLists ,
                            IncludePriceList,
                            ExcludePriceList );
   --      dbms_output.put_line('USERID=' || userid);


      EXCEPTION
      WHEN others THEN
         status := 'ERROR_UNEXPECTED_'||error_tracking_num;

         return;


END RunDemantraPricingData_Pub;
 -- =============================================================
 -- Desc: Please see package spec file for description
 -- =============================================================
   PROCEDURE RunDemantraReturnsHistory(
                        status	  		OUT NOCOPY VARCHAR2,
      			processid 		OUT NOCOPY VARCHAR2,
                        UserID                  IN NUMBER,
                        ResponsibilityID        IN NUMBER,
                        InstanceId              IN NUMBER,
                        CollectionGroup         IN VARCHAR2,
                        CollectionMethod        IN VARCHAR2,
                        DateRangeType	        IN VARCHAR2 DEFAULT NULL,
                        HistoryCollectionWindow IN NUMBER DEFAULT NULL,
                        DateFrom                IN DATE DEFAULT NULL,
                        DateTo                  IN DATE DEFAULT NULL,
                        RMATypes                IN MscChar255Arr
                        ) is
  L_VAL_RESULT VARCHAR2(30);
  result BOOLEAN := false;
  req_id NUMBER:=0;
  submit_failed EXCEPTION;
  error_tracking_number NUMBER;
  passedCollectionGroup varchar2(100);

    BEGIN
        error_tracking_number:=100;
        MSC_WS_COMMON.VALIDATE_USER_RESP (L_VAL_RESULT, UserId, ResponsibilityID);
        IF (L_VAL_RESULT <> 'OK') THEN
           PROCESSID := -1;
           STATUS := L_VAL_RESULT;
           RETURN;
        END IF;

        error_tracking_number:=120;
        result := isValid_INSTANCE_ID( InstanceId);
        IF (result = false) THEN
           PROCESSID := -1;
           STATUS := 'INVALID_INSTANCE_ID';
           RETURN;
        END IF;

        error_tracking_number:=130;
        result := isValid_DEM_COLLECTION_GROUP( CollectionGroup, InstanceId) ;
        IF (result = false) THEN
           PROCESSID := -1;
           STATUS := 'INVALID_COLLECTION_GROUP';
           RETURN;
        END IF;

         error_tracking_number:=140;

        result := isValid_RMA_Types(RMATypes, InstanceId);
         IF (result = false) THEN
           PROCESSID := -1;
           STATUS := 'INVALID_RMA_TYPES';
           RETURN;
        END IF;

       error_tracking_number:=145;
        --save the RMA types into MSD_DEM_RMA_TYPE. Conc program will read data from here, and wipe out table.

        result := SaveRMATypesIntoTable(RMATypes);
         IF (result = false) THEN
           PROCESSID := -1;
           STATUS := 'ERROR_SAVING_RMA_TYPES';
           RETURN;
        END IF;

        -- register Collect Returns History
        error_tracking_number:=150;

passedCollectionGroup := CollectionGroup;
-- bug 6837675
--if ( CollectionGroup = 'All') then
--    passedCollectionGroup := '-999';
--end if;
        req_id := fnd_request.submit_request('MSD','MSDDEMRH','Returns History',NULL, false,
                                              InstanceId, passedCollectionGroup,
                                              GetRH_CollectionMethodAsNumber( CollectionMethod),
                                              GetRH_DateRangeTypeAsNumber(DateRangeType),
                                              HistoryCollectionWindow,
                                              to_char(DateFrom, 'YYYY/MM/DD HH24:MI:SS'), to_char(DateTo, 'YYYY/MM/DD HH24:MI:SS'),
                                              'MSD_DEM_RETURN_HISTORY'
                                              );


        IF(req_id = 0) THEN
               raise submit_failed ;
         END IF ;

        status  := 'SUCCESS';
        processId := req_id;

    EXCEPTION
    WHEN submit_failed THEN
        status := 'ERROR_SUBMIT';
        processId := -1;
        RETURN;
    WHEN others THEN
        status := 'ERROR_UNEXPECTED_'||error_tracking_number;
        processId := -1;
        RETURN;


   END RunDemantraReturnsHistory;

   PROCEDURE RunDemantraReturnsHistory_Pub(
                    processId                         OUT NOCOPY NUMBER,
   			         status                             OUT NOCOPY VARCHAR2,
   			         UserName                           IN VARCHAR2,
   			         RespName                           IN VARCHAR2,
   			         RespApplName                       IN VARCHAR2,
   			         SecurityGroupName                  IN VARCHAR2,
   			         Language                           IN VARCHAR2,
                   InstanceId              IN NUMBER,
                   CollectionGroup         IN VARCHAR2,
                   CollectionMethod        IN VARCHAR2,
                   DateRangeType	        IN VARCHAR2 DEFAULT NULL,
                   HistoryCollectionWindow IN NUMBER DEFAULT NULL,
                   DateFrom                IN DATE DEFAULT NULL,
                   DateTo                  IN DATE DEFAULT NULL,
                   RMATypes                IN MscChar255Arr
                   ) AS
   		     userid    number;
   		     respid    number;
   		     l_String VARCHAR2(30);
   		     error_tracking_num number;
   		     l_SecutirtGroupId  NUMBER;
   		    BEGIN
   		      error_tracking_num :=2010;
   		       MSC_WS_COMMON.GET_PERMISSION_IDS(l_String, userid, respid, l_SecutirtGroupId, UserName, RespName, RespApplName, SecurityGroupName, Language);
   		       IF (l_String <> 'OK') THEN
   		           Status := l_String;
   		           RETURN;
   		       END IF;
   		        error_tracking_num :=2020;
   		       MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, userid, respid,'MSD_DEM_CRH', l_SecutirtGroupId);
   		       IF (l_String <> 'OK') THEN
   		           Status := l_String;
   		           RETURN;
   		       END IF;

   		       error_tracking_num :=2040;

   		      RunDemantraReturnsHistory (   status,
                                                       processId,
                                                       userId ,
                                                       respid,
                                                       InstanceId,
                                                       CollectionGroup ,
                                                       CollectionMethod,
                                                       DateRangeType,
                                                       HistoryCollectionWindow,
                                                       DateFrom ,
                                                       DateTo,
                                                       RMATypes  );



   		         EXCEPTION
   		         WHEN others THEN
   		            status := 'ERROR_UNEXPECTED_'||error_tracking_num;

   		            return;
END RunDemantraReturnsHistory_Pub;

FUNCTION GetCollectionMethodAsNumber( CollectionMethod IN VARCHAR2) RETURN NUMBER IS
cCode NUMBER;
BEGIN
    --SELECT lookup_code INTO cCode FROM mfg_lookups WHERE lookup_type = 'PARTIAL_YES_NO' AND meaning = CollectionMethod;

     SELECT to_number(decode(CollectionMethod,'COMPLETE_REFRESH',1,'NET_CHANGE_REFRESH',2,'TARGETED_REFRESH',3, -1))
     INTO cCode FROM dual;

     RETURN cCode;


    RETURN 3;
END GetCollectionMethodAsNumber;

FUNCTION GetLookupCodeForAppSuppList(ApprovedSupplierList IN VARCHAR2) RETURN NUMBER IS
cCode NUMBER;
BEGIN
    --SELECT lookup_code INTO cCode FROM mfg_lookupsWHERE lookup_type = 'MSC_X_ASL_SYS_YES_NO' AND meaning = ApprovedSupplierList;
 -- bnaghi bug 6861953
     SELECT to_number(decode(ApprovedSupplierList,'YES_REPLACE',1,'NO',2,'YES_BUT_RETAIN_CP', 3,-1))
     INTO cCode FROM dual;

     RETURN cCode;

END GetLookupCodeForAppSuppList;


FUNCTION GetUserCompAssoc(UserCompanyAssoc IN VARCHAR2) RETURN NUMBER IS
cCode NUMBER;
BEGIN
    --SELECT lookup_code INTO cCode FROM fnd_lookups WHERE lookup_type = 'MSC_X_USER_COMPANY' AND meaning = UserCompanyAssoc;

     SELECT to_number(decode(UserCompanyAssoc,'CREATE_USERS_ENABLE_UCA',3,'NO',1,'ENABLE_UCA', 2,-1))
     INTO cCode FROM dual;

    RETURN cCode;

END GetUserCompAssoc;


FUNCTION GetResAvail(ResourceAvailability IN VARCHAR2) RETURN NUMBER IS
cCode NUMBER;
BEGIN
    --SELECT lookup_type, meaning, lookup_code FROM mfg_lookups WHERE lookup_type = 'MSC_NRA_ENABLED'
 -- bnaghi bug 6861953
     SELECT to_number(decode(ResourceAvailability,'COLLECT_DATA',1,'DO_NOT_COLLECT_DATA',2,'REGENERATE_DATA', 3,-1))
     INTO cCode FROM dual;

    RETURN cCode;

END GetResAvail;
 -- =============================================================
 -- Desc: Private function to validate instance id.  The logic
 --       mirrors the value set MSC_SRS_INSTANCE_CODE
 -- =============================================================
 FUNCTION isValid_INSTANCE_ID( INST_ID  IN NUMBER) RETURN BOOLEAN IS
   l_val_instance_id NUMBER;
 BEGIN
    BEGIN
        SELECT instance_id INTO l_val_instance_id
        FROM   msc_apps_instances
        WHERE  instance_id = INST_ID
        AND    instance_type IN (1,2,4) and enable_flag=1;
    END;

    RETURN TRUE;

 EXCEPTION WHEN no_data_found THEN
                 RETURN false;
 END isValid_INSTANCE_ID;


 -- =============================================================
 -- Desc: Private function to validate instance id.  The logic
 --       mirrors the value set MSC_ORG_STRINGS
 -- =============================================================
 FUNCTION isValid_COLLECTION_GROUP( orgGroup IN VARCHAR2, InstanceId IN Number) RETURN booleaN IS
   cCode VARCHAR2(80);
 BEGIN
        SELECT org_group into cCode
        from MSC_ORG_GROUPS_V
        WHERE code = orgGroup
        and (instance_id IS NULL OR instance_id = InstanceId);

        RETURN true;

 EXCEPTION
   WHEN no_data_found THEN
        RETURN false;

 END isValid_COLLECTION_GROUP;

 -- =============================================================
 -- Desc: Private function to validate instance id.  The logic
 --       mirrors the value set MSD_DEM_ORG_STRINGS
 -- =============================================================
FUNCTION isValid_DEM_COLLECTION_GROUP( orgGroup IN VARCHAR2, InstanceId IN Number) RETURN booleaN IS
  cCode VARCHAR2(80);
BEGIN
-- changed for bug 6837675 , orgGroup/collection group input value for All is -999
        SELECT org_group into cCode
        from MSD_DEM_ORG_GROUPS_V
        WHERE code = orgGroup
        and (instance_id IS NULL OR instance_id = InstanceId);
        RETURN true;

EXCEPTION
  WHEN no_data_found THEN
        RETURN false;

END isValid_DEM_COLLECTION_GROUP;


 -- =============================================================
 -- Desc: Private function to validate instance id.  The logic
 --       mirrors the value set MSD_DEM_COLL_METHODS
 -- =============================================================
FUNCTION isValid_DEM_COLLECTION_METHOD( methodCode IN NUMBER) RETURN booleaN IS
  cCode NUMBER;
BEGIN

        SELECT lookup_code INTO cCode
        FROM fnd_lookup_values_vl flv
        WHERE flv.lookup_type = 'MSD_DEM_COLL_METHODS'
        AND flv.lookup_code = methodCode;

        RETURN true;

EXCEPTION
  WHEN no_data_found THEN
        RETURN false;

END isValid_DEM_COLLECTION_METHOD;



 -- =============================================================
 -- Desc: Private function to validate instance id.  The logic
 --       mirrors the value set MSD_DEM_DATE_RANGE_TYPES
 -- =============================================================
FUNCTION isValid_DATE_RANGE_TYPE(CollectionMethod IN NUMBER,
                                 dateRangeType IN NUMBER) RETURN booleaN IS
  cCode NUMBER;
BEGIN
  -- If collection method is 2 (Netchange), then the dateRangeType
  -- Is required.  Otherwise, dateRangeType need to be NULL
  IF (CollectionMethod = 2) THEN
       SELECT lookup_code into cCode from fnd_lookup_values_vl flv
       WHERE flv.lookup_type = 'MSD_DEM_DATE_RANGE_TYPES'
       --AND '1' = hiddenParam
       AND lookup_code= dateRangeType;

       RETURN true;
  ELSE
    IF (dateRangeType is NULL) THEN
      RETURN true;
    ELSE
      RETURN false;
    END IF;
  END IF;
EXCEPTION WHEN no_data_found THEN
       RETURN false;

END isValid_DATE_RANGE_TYPE;


 -- =============================================================
 -- Desc: Private function to validate instance id.  The logic
 --       mirrors the value set MSD_DEM_DATE_RANGE_TYPES
 -- =============================================================
FUNCTION isValid_Sel_Of_OrderTypes( CollectAllOrderTypes in Varchar2,
                                    IncludeOrderTypes in VARCHAR2,
                                    ExcludeOrderTypes in VARCHAR2) RETURN BOOLEAN is
BEGIN
    IF (CollectAllOrderTypes = 'Y') THEN
        RETURN true;
    END IF;

     IF ((IncludeOrderTypes is NULL) AND (ExcludeOrderTypes is NULL)) THEN
        RETURN FALSE;
     END IF;

    IF ( (IncludeOrderTypes is NOT NULL) AND (ExcludeOrderTypes is NOT NULL )) THEN
      RETURN false;
    END IF;

    RETURN true;
END isValid_Sel_Of_OrderTypes;

-- =============================================================
 -- Desc: Private function to validate dates based on DateRangeType.
 -- =============================================================
FUNCTION isValid_Dates( DateRangeType in NUMBER,
                        DateFrom in DATE,
                        DateTo IN DATE) RETURN BOOLEAN is
 BEGIN
        -- for 'absolute' dateRange Type, dates cannot be null
        IF ( DateRangeType = 1) THEN
            IF ( DateFrom is NULL or DateTo is NULL ) THEN
               RETURN FALSE;
            END IF;
        END IF;

        -- dateFrom  < dateTo
        IF ( DateFrom is NOT NULL and DateTo is NOT NULL ) THEN
            IF ( DateFrom > DateTo) THEN
                    RETURN FALSE;
            END IF;
        END IF;

	RETURN TRUE;

END isValid_Dates;


 -- =============================================================
 -- Desc: Private function to get destination table name for
 -- "Demantra Update Level Codes" conc program
 -- =============================================================

FUNCTION Dem_ULC_GetDestTableName RETURN VARCHAR2 is
value varchar(80);
BEGIN
    SELECT msd_dem_common_utilities.get_lookup_value ('MSD_DEM_DM_STAGING_TABLES', 'SALES_STAGING_TABLE') into value from dual;
    RETURN value;
END Dem_ULC_GetDestTableName;

FUNCTION GetRH_CollectionMethodAsNumber( CollectionMethod IN VARCHAR2) RETURN NUMBER IS
cCode NUMBER;
BEGIN

     SELECT to_number(decode(CollectionMethod,'COMPLETE',1,'NET_CHANGE',2, -1))
     INTO cCode FROM dual;
    RETURN cCode;
END GetRH_CollectionMethodAsNumber;

FUNCTION GetRH_DateRangeTypeAsNumber(DateRangeType IN Varchar2) RETURN NUMBER IS
cCode NUMBER;
BEGIN

     SELECT to_number(decode(DateRangeType,'ABSOLUTE',1,'ROLLING',2, -1))
     INTO cCode FROM dual;
    RETURN cCode;
END GetRH_DateRangeTypeAsNumber;

FUNCTION isValid_RMA_Types( types IN MscChar255Arr, InstanceId IN Number) RETURN BOOLEAN is
v_number NUMBER :=0;
dbLink varchar2(128);
dbLink2 varchar2(129);
tableName varchar2(180);
tableNameAll varchar2(180);
selectStr varchar2(1555);
i NUMBER :=0;
begin

    if types is NULL or types.COUNT = 0 then
        return TRUE;
    end if;

    select a2m_dblink into dbLink
    from msc_apps_instances
    where instance_id = InstanceId;

    select DECODE(dbLink, NULL,'', '@' || dbLink) into dbLink2 from dual;
    tableName := 'oe_transaction_types_tl' || dbLink2;
    tableNameAll := 'oe_transaction_types_all' || dbLink2;


    for i in 1 .. types.LAST  LOOP
        v_number := 0;
        selectStr :=  'SELECT count(1)
                       FROM ' || tableName || ' a, ' || tableNameAll || ' b
                       WHERE b.transaction_type_code =''LINE''
                       AND b.order_category_code = ''RETURN''
                       AND a.LANGUAGE = userenv(''LANG'')
                       AND a.transaction_type_id = b.transaction_type_id
                       AND a.name = ''' ||types(i) || '''';


        --dbms_output.put_line(selectStr);
        execute immediate selectStr into v_number;

        --dbms_output.put_line('number = ' || v_number);

        if  v_number = 0 then
            return false;
        end if;

    end loop;

    return true;

end isValid_RMA_Types;

FUNCTION SaveRMATypesIntoTable(RMATypes IN MscChar255Arr) RETURN BOOLEAN IS
i NUMBER;
begin
    if ( RMATypes is NULL or RMATypes.COUNT =0) then
        return true;
    end if;

    for i in 1 .. RMATypes.LAST  LOOP
    BEGIN
        INSERT INTO MSD_DEM_RMA_TYPE
            ( RMA_TYPES )
        VALUES
            (
            RMATypes(i)
            );
        EXCEPTION WHEN others THEN
            RETURN FALSE;
    END ;
    end loop;

    return TRUE;

end SaveRMATypesIntoTable;

END MSC_WS_COLLECTIONS;

/
