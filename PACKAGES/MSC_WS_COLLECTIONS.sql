--------------------------------------------------------
--  DDL for Package MSC_WS_COLLECTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_WS_COLLECTIONS" AUTHID CURRENT_USER AS
/* $Header: MSCWCOLLS.pls 120.3 2008/03/13 04:00:57 bnaghi noship $ */




    -- =============================================================
    -- Desc: This procedure is invoked from web service to launch
    --       the ASCP Collection request set.  The input parameters
    --       mirror the parameters for the concurrent programs within
    --       the request set.  The procedure returns a status and
    --       concurrent program request id.  The possible return
    --       statuses are:
    --          SUCCESS, ERROR_SUBMITTING,
    --          INVALID_FND_USER, INVALID_FND_RESP
    --          INVALID_INSTANCE_ID, INVALID_COLLECTION_GROUP, INVALID_TIMEOUT,
    --          INVALID_WORKER_NUMBER, INVALID_ODS_WORKER_NUMBER
    -- =============================================================
    PROCEDURE RunASCPCollections(
               status				 OUT NOCOPY VARCHAR2,
               processId	       	         OUT NOCOPY VARCHAR2,
               UserID                             IN NUMBER,
               ResponsibilityID                   IN NUMBER,
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
              ) ;


   -- =============================================================
      -- Desc: This procedure is invoked from web service to launch
      --       the ASCP Collection request set.  The input parameters
      --       mirror the parameters for the concurrent programs within
      --       the request set.  The procedure returns a status and
      --       concurrent program request id.  The possible return
      --       statuses are:
      --          SUCCESS, ERROR_SUBMITTING,
      --          INVALID_USER_NAME, INVALID_RESP_NAME
      --          INVALID_LANGUAGE, INVALID_SECUTITY_GROUP_NAME, INVALID_FUNC_NAME
      --          INVALID_INSTANCE_ID, INVALID_COLLECTION_GROUP, INVALID_TIMEOUT,
      --          INVALID_WORKER_NUMBER, INVALID_ODS_WORKER_NUMBER
    -- =============================================================
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
              ) ;
   -- =============================================================
    -- Desc: This procedure is invoked from web service to launch
    --       the ODS Load conc prog.  The input parameters
    --       mirror the parameters for the concurrent program
    --       The procedure returns a status and
    --       concurrent program request id.  The possible return
    --       statuses are:
    --          SUCCESS, ERROR_SUBMITTING,
    --          INVALID_FND_USER, INVALID_FND_RESP
    --          INVALID_INSTANCE_ID, INVALID_TIMEOUT ,INVALID_ODS_WORKER_NUMBER
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
                 );

   -- =============================================================
    -- Desc: This procedure is invoked from web service to launch
    --       the ODS Load conc prog.  The input parameters
    --       mirror the parameters for the concurrent program
    --       The procedure returns a status and
    --       concurrent program request id.  The possible return
    --       statuses are:
    --          SUCCESS, ERROR_SUBMITTING,
    --          INVALID_USER_NAME, INVALID_RESP_NAME
    --       INVALID_LANGUAGE, INVALID_SECUTITY_GROUP_NAME, INVALID_FUNC_NAME
    --          INVALID_INSTANCE_ID, INVALID_TIMEOUT ,INVALID_ODS_WORKER_NUMBER
    -- =============================================================

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
                 );

    -- =============================================================
    -- Desc: This procedure is invoked from web service to launch
    --       the Demantra Shipment and booking Request Set.  The input parameters
    --       mirror the parameters for the concurrent programs within the request set.
    --       The procedure returns a status and
    --       concurrent program request id.  The possible return
    --       statuses are:
    --          SUCCESS, ERROR_SUBMITTING,
    --          INVALID_FND_USER, INVALID_FND_RESP
    --          INVALID_COLLECTION_METHOD_NOT_2, INVALID_INSTANCE_ID, INVALID_COLLECTION_GROUP,INVALID_COLLECTION_METHOD,
    --          INVALID_DATE_RANGE_TYPE, INVALID_ORDER_TYPE_SELECTION

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
            );

    -- =============================================================
    -- Desc: This procedure is invoked from web service to launch
    --       the Demantra Shipment and booking Request Set.  The input parameters
    --       mirror the parameters for the concurrent programs within the request set.
    --       The procedure returns a status and
    --       concurrent program request id.  The possible return
    --       statuses are:
    --          SUCCESS, ERROR_SUBMITTING,
    --          INVALID_USER_NAME, INVALID_RESP_NAME
    --          INVALID_LANGUAGE, INVALID_SECUTITY_GROUP_NAME, INVALID_FUNC_NAME
    --          INVALID_COLLECTION_METHOD_NOT_2, INVALID_INSTANCE_ID, INVALID_COLLECTION_GROUP,INVALID_COLLECTION_METHOD,
    --          INVALID_DATE_RANGE_TYPE, INVALID_ORDER_TYPE_SELECTION


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
            );

    -- =============================================================
    -- Desc: This procedure is invoked from web service to launch
    --       the Demantra Collect SCI Data conc prog.  The input parameters
    --       mirror the parameters for the concurrent program.
    --       The procedure returns a status and
    --       concurrent program request id.  The possible return
    --       statuses are:
    --          SUCCESS, ERROR_SUBMITTING,
    --          INVALID_FND_USER, INVALID_FND_RESP
    --          INVALID_COLLECTION_METHOD_NOT_2, INVALID_INSTANCE_ID, INVALID_COLLECTION_GROUP,INVALID_COLLECTION_METHOD,
    --          INVALID_DATE_RANGE_TYPE
    -- =============================================================

    PROCEDURE RunDemantraSCIData (
                status	  	                OUT NOCOPY VARCHAR2,
                processid 		        OUT NOCOPY VARCHAR2,
                UserID                          IN NUMBER,
                ResponsibilityID                IN NUMBER,
                InstanceId		        IN NUMBER,
                CollectionGroup                 IN VARCHAR2,
                CollectionMethod                IN NUMBER,
                DateRangeType                   IN NUMBER,
                HistoryCollectionWindow         IN NUMBER DEFAULT NULL,
                DateFrom                        IN DATE DEFAULT NULL,
                DateTo                          IN DATE DEFAULT NULL
                );

    -- =============================================================
    -- Desc: This procedure is invoked from web service to launch
    --       the Demantra Collect SCI Data conc prog.  The input parameters
    --       mirror the parameters for the concurrent program.
    --       The procedure returns a status and
    --       concurrent program request id.  The possible return
    --       statuses are:
    --          SUCCESS, ERROR_SUBMITTING,
    --          IINVALID_USER_NAME, INVALID_RESP_NAME
    --       INVALID_LANGUAGE, INVALID_SECUTITY_GROUP_NAME, INVALID_FUNC_NAME
    --          INVALID_COLLECTION_METHOD_NOT_2, INVALID_INSTANCE_ID, INVALID_COLLECTION_GROUP,INVALID_COLLECTION_METHOD,
    --          INVALID_DATE_RANGE_TYPE
    -- =============================================================

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
                );

    -- =============================================================
    -- Desc: This procedure is invoked from web service to launch
    --       the Demantra Collect Currency conc prog.  The input parameters
    --       mirror the parameters for the concurrent program.
    --       The procedure returns a status and
    --       concurrent program request id.  The possible return
    --       statuses are:
    --          SUCCESS, ERROR_SUBMITTING,
    --          INVALID_FND_USER, INVALID_FND_RESP
    --          INVALID_INSTANCE_ID, INVALID_SELECTION_CURRENCY_LIST
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
                );

     -- =============================================================
    -- Desc: This procedure is invoked from web service to launch
    --       the Demantra Collect Currency conc prog.  The input parameters
    --       mirror the parameters for the concurrent program.
    --       The procedure returns a status and
    --       concurrent program request id.  The possible return
    --       statuses are:
    --          SUCCESS, ERROR_SUBMITTING,
    --          INVALID_USER_NAME, INVALID_RESP_NAME
    --       INVALID_LANGUAGE, INVALID_SECUTITY_GROUP_NAME, INVALID_FUNC_NAME
    --          INVALID_INSTANCE_ID, INVALID_SELECTION_CURRENCY_LIST
    -- =============================================================

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
                );

     -- =============================================================
    -- Desc: This procedure is invoked from web service to launch
    --       the Demantra UOM Conversions conc prog.  The input parameters
    --       mirror the parameters for the concurrent program.
    --       The procedure returns a status and
    --       concurrent program request id.  The possible return
    --       statuses are:
    --          SUCCESS, ERROR_SUBMITTING,
    --          INVALID_FND_USER, INVALID_FND_RESP
    --          INVALID_INSTANCE_ID, INVALID_SELECTION_UOM_LIST
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
                );

       -- =============================================================
    -- Desc: This procedure is invoked from web service to launch
    --       the Demantra UOM Conversions conc prog.  The input parameters
    --       mirror the parameters for the concurrent program.
    --       The procedure returns a status and
    --       concurrent program request id.  The possible return
    --       statuses are:
    --          SUCCESS, ERROR_SUBMITTING,INVALID_USER_NAME, INVALID_RESP_NAME
    --       INVALID_LANGUAGE, INVALID_SECUTITY_GROUP_NAME, INVALID_FUNC_NAME INVALID_FND_USER, INVALID_FND_RESP
    --          INVALID_INSTANCE_ID, INVALID_SELECTION_UOM_LIST
    -- =============================================================

     PROCEDURE RunDemantraUOMConversion_Pub(
                 processId                         OUT NOCOPY NUMBER,
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
                );

    -- =============================================================
    -- Desc: This procedure is invoked from web service to launch
    --       the Demantra Pricing Data conc prog.  The input parameters
    --       mirror the parameters for the concurrent program.
    --       The procedure returns a status and
    --       concurrent program request id.  The possible return
    --       statuses are:
    --          SUCCESS, ERROR_SUBMITTING,
    --          INVALID_FND_USER, INVALID_FND_RESP
    --          INVALID_INSTANCE_ID, INVALID_SELECTION_PRICE_LIST
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
            );

    -- =============================================================
    -- Desc: This procedure is invoked from web service to launch
    --       the Demantra Pricing Data conc prog.  The input parameters
    --       mirror the parameters for the concurrent program.
    --       The procedure returns a status and
    --       concurrent program request id.  The possible return
    --       statuses are:
    --          SUCCESS, ERROR_SUBMITTING,
    --          INVALID_USER_NAME, INVALID_RESP_NAME
    --       INVALID_LANGUAGE, INVALID_SECUTITY_GROUP_NAME, INVALID_FUNC_NAME
    --          INVALID_INSTANCE_ID, INVALID_SELECTION_PRICE_LIST
    -- =============================================================

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
            );


     -- =============================================================
    -- Desc: This procedure is invoked from web service to launch
    --       the Demantra Returns History conc prog.  The input parameters
    --       mirror the parameters for the concurrent program.
    --       The procedure returns a status and
    --       concurrent program request id.  The possible return
    --       statuses are:
    --          SUCCESS, ERROR_SUBMITTING,
    --          INVALID_FND_USER, INVALID_FND_RESP
    --          INVALID_INSTANCE_ID, INVALID_COLLECTION_METHOD, INVALID_COLLECTION_GROUP
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
                );

       -- =============================================================
    -- Desc: This procedure is invoked from web service to launch
    --       the Demantra Returns History conc prog.  The input parameters
    --       mirror the parameters for the concurrent program.
    --       The procedure returns a status and
    --       concurrent program request id.  The possible return
    --       statuses are:
    --          SUCCESS, ERROR_SUBMITTING,
    --         INVALID_USER_NAME, INVALID_RESP_NAME
    --         INVALID_LANGUAGE, INVALID_SECUTITY_GROUP_NAME, INVALID_FUNC_NAME
    --          INVALID_INSTANCE_ID, INVALID_COLLECTION_METHOD, INVALID_COLLECTION_GROUP
    -- =============================================================
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
                );

END MSC_WS_COLLECTIONS;


/
