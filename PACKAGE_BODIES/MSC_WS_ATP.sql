--------------------------------------------------------
--  DDL for Package Body MSC_WS_ATP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_WS_ATP" AS
/* $Header: MSCWATPB.pls 120.6 2008/03/13 15:05:47 bnaghi noship $  */



-- =============================================================
-- Desc: Please see package spec file for description
-- =============================================================
PROCEDURE GetPromiseDate(
	  status                        OUT nocopy VARCHAR2,

          InstanceId                    IN MscNumberArr ,
          InventoryItemId               IN MscNumberArr,
          InventoryItemName             IN MscChar40Arr,
          SourceOrganizationId          IN MscNumberArr ,
          SourceOrganizationCode        IN MscChar7Arr ,
          OrganizationId                IN MscNumberArr ,
          Identifier                    IN MscNumberArr ,
          DemandSourceHeaderId          IN MscNumberArr ,
          DemandSourceDelivery          IN MscChar30Arr ,
          DemandSourceType              IN MscNumberArr ,
          CallingModule                 IN MscNumberArr ,
          CustomerId                    IN MscNumberArr ,
          CustomerSiteId                IN MscNumberArr ,
          QuantityOrdered               IN MscNumberArr ,
          QuantityUOM                   IN MscChar3Arr ,
          RequestedShipDate             IN MscDateArr,
          RequestedArrivalDate          IN MscDateArr ,
          LatestAcceptableDate          IN MscDateArr ,
          DeliveryLeadTime              IN MscNumberArr ,
          ShipMethod                    IN MscChar30Arr ,
          DemandClass                   IN MscChar30Arr ,
          ShipSetName                   IN MscChar30Arr ,
          ArrivalSetName                IN MscChar30Arr ,
          OverrideFlag                  IN MscChar1Arr ,
          Action                        IN MscNumberArr ,
          InsertFlag                    IN MscNumberArr ,
          OEFlag                        IN MscChar1Arr ,
          OrderNumber                   IN MscNumberArr ,
          OldSourceOrganizationId       IN MscNumberArr ,
          OldDemandClass                IN MscChar30Arr ,
          Attribute01                   IN MscNumberArr ,
          Attribute02                   IN MscNumberArr ,
          CustomerCountry               IN MscChar60Arr ,
          CustomerState                 IN MscChar60Arr ,
          CustomerCity                  IN MscChar60Arr ,
          CustomerPostalCode            IN MscChar60Arr ,
          SubstitutionTypeCode          IN MscNumberArr ,
          ReqItemDetailFlag             IN MscNumberArr ,
          SalesRep                      IN MscChar255Arr ,
          CustomerContact               IN MscChar255Arr ,
          TopModelLineId                IN MscNumberArr ,
          ATOParentModelLineId          IN MscNumberArr ,
          ATOModelLineId                IN MscNumberArr ,
          ParentLineId                  IN MscNumberArr ,
          MatchItemId                   IN MscNumberArr ,
          ConfigItemLineId              IN MscNumberArr ,
          ValidationOrg                 IN MscNumberArr ,
          ComponentSequenceID           IN MscNumberArr ,
          ComponentCode                 IN MscChar255Arr ,
          LineNumber                    IN MscChar80Arr ,
          IncludedItemFlag              IN MscNumberArr ,
          PickComponentsFlag            IN MscChar1Arr ,
          CascadeModelInfoToComp        IN MscNumberArr ,
          SequenceNumber                IN MscNumberArr ,
          InternalOrgId                 IN MscNumberArr ,
          PartySiteId                   IN MscNumberArr ,
          PartOfSet                     IN MscChar1Arr ,

          InstanceIdOut                 OUT nocopy MscNumberArr,
          InventoryItemIdOut            OUT nocopy MscNumberArr,
          InventoryItemNameOut          OUT nocopy MscChar40Arr,
          SourceOrganizationIdOut       OUT nocopy MscNumberArr,
          SourceOrganizationCodeOut     OUT nocopy MscChar7Arr,
          OrganizationIdOut             OUT nocopy MscNumberArr,
          IdentifierOut                 OUT nocopy MscNumberArr,
          DemandSourceHeaderIdOut       OUT nocopy MscNumberArr,
          DemandSourceDeliveryOut       OUT nocopy MscChar30Arr,
          DemandSourceTypeOut           OUT nocopy MscNumberArr,
          CustomerIdOut                 OUT nocopy MscNumberArr,
          CustomerSiteIdOut             OUT nocopy MscNumberArr,
          QuanitytOrderedOut            OUT nocopy MscNumberArr,
          QuantityUOMOut                OUT nocopy MscChar3Arr,
          RequestedShipDateOut          OUT nocopy MscDateArr,
          RequestedArrivalDateOut       OUT nocopy MscDateArr,
          LatestAcceptableDateOut       OUT nocopy MscDateArr,
          DeliveryLeadTimeOut           OUT nocopy MscNumberArr,
          ShipMethodOut                 OUT nocopy MscChar30Arr,
          DemandClassOut                OUT nocopy MscChar30Arr,
          ShipSetNameOut                OUT nocopy MscChar30Arr,
          ArrivalSetNameOut             OUT nocopy MscChar30Arr,
          OverrideFlagOut               OUT nocopy MscChar1Arr,
          ShipDateOut                   OUT nocopy MscDateArr,
          ArrivalDateOut                OUT nocopy MscDateArr,
          AvailableQuantityOut          OUT nocopy MscNumberArr,
          RequestedDateQuantityOut      OUT nocopy MscNumberArr,
          GroupShipDateOut              OUT nocopy MscDateArr,
          GroupArrivalDateOut           OUT nocopy MscDateArr,
          AtpLeadTimeOut                OUT nocopy MscNumberArr,
          ErrorCodeOut                  OUT nocopy MscNumberArr,
          EndPeggingIdOut               OUT nocopy MscNumberArr,
          OldSourceOrganizationIdOut    OUT nocopy MscNumberArr,
          OldDemandClassOut             OUT nocopy MscChar30Arr,
          RequestItemIdOut              OUT nocopy MscNumberArr,
          ReqItemReqDateQtyOut          OUT nocopy MscNumberArr,
          ReqItemAvailableDateOut       OUT nocopy MscDateArr,
          ReqItemAvailableDateQtyOut    OUT nocopy MscNumberArr,
          RequestItemNameOut            OUT nocopy MscChar40Arr,
          OldInventoryItemIdOut         OUT nocopy MscNumberArr,
          SubstFlagOut                  OUT nocopy MscNumberArr,
          BaseModelIdOut                OUT nocopy MscNumberArr,
          OssErrorCodeOut               OUT nocopy MscNumberArr,
          MatchedItemNameOut            OUT nocopy MscChar255Arr,
          CascadeModelInfoToCompOut     OUT nocopy MscNumberArr,
          PlanIdOut                     OUT nocopy MscNumberArr
          ) is

          sessionId              NUMBER :=0;
          p_atp_table             MRP_ATP_PUB.ATP_Rec_Typ;
          ln                      NUMBER;
          i                       NUMBER :=0;
          x_atp_table             MRP_ATP_PUB.ATP_Rec_Typ;
          x_atp_supply_demand     MRP_ATP_PUB.ATP_Supply_Demand_Typ;
          x_atp_period            MRP_ATP_PUB.ATP_Period_Typ;
          x_atp_details           MRP_ATP_PUB.ATP_Details_Typ;
          x_return_status         VARCHAR2(1);
          x_msg_data              VARCHAR2(200);
          x_msg_count             NUMBER;

          temp_status           Varchar2(40);
          atpUnknownError       EXCEPTION;
          atpError              EXCEPTION;
          atpParameterSizeError EXCEPTION;
          atpProfilesError      EXCEPTION;
          parameterName         VARCHAR2(40);

          userId NUMBER :=0;
          respId NUMBER :=0;
          appId  NUMBER :=0;
          error_tracking_number NUMBER :=0;


                   BEGIN

          error_tracking_number         := 100;
          InstanceIdOut                 := MscNumberArr();
          InventoryItemIdOut		:= MscNumberArr();
          InventoryItemNameOut		:= MscChar40Arr();
          SourceOrganizationIdOut	:= MscNumberArr();
          SourceOrganizationCodeOut     := MscChar7Arr();
          OrganizationIdOut		:= MscNumberArr();
          IdentifierOut			:= MscNumberArr();
          DemandSourceHeaderIdOut	:= MscNumberArr();
          DemandSourceDeliveryOut	:= MscChar30Arr();
          DemandSourceTypeOut		:= MscNumberArr();
          CustomerIdOut			:= MscNumberArr();
          CustomerSiteIdOut		:= MscNumberArr();
          QuanitytOrderedOut            := MscNumberArr();
          QuantityUOMOut                := MscChar3Arr();
          RequestedShipDateOut          := MscDateArr();
          RequestedArrivalDateOut       := MscDateArr();
          LatestAcceptableDateOut       := MscDateArr();
          DeliveryLeadTimeOut           := MscNumberArr();
          ShipMethodOut                 := MscChar30Arr();
          DemandClassOut                := MscChar30Arr();
          ShipSetNameOut                := MscChar30Arr();
          ArrivalSetNameOut             := MscChar30Arr();
          OverrideFlagOut               := MscChar1Arr();
          ShipDateOut                   := MscDateArr();
          ArrivalDateOut                := MscDateArr();
          AvailableQuantityOut          := MscNumberArr();
          RequestedDateQuantityOut      := MscNumberArr();
          GroupShipDateOut              := MscDateArr();
          GroupArrivalDateOut           := MscDateArr();
          AtpLeadTimeOut                := MscNumberArr();
          ErrorCodeOut                  := MscNumberArr();
          EndPeggingIdOut               := MscNumberArr();
          OldSourceOrganizationIdOut    := MscNumberArr();
          OldDemandClassOut             := MscChar30Arr();
          RequestItemIdOut              := MscNumberArr();
          ReqItemReqDateQtyOut          := MscNumberArr();
          ReqItemAvailableDateOut       := MscDateArr();
          ReqItemAvailableDateQtyOut    := MscNumberArr();
          RequestItemNameOut            := MscChar40Arr();
          OldInventoryItemIdOut         := MscNumberArr();
          SubstFlagOut                  := MscNumberArr();
          BaseModelIdOut                := MscNumberArr();
          OssErrorCodeOut               := MscNumberArr();
          MatchedItemNameOut            := MscChar255Arr();
          CascadeModelInfoToCompOut     := MscNumberArr();
          PlanIdOut                     := MscNumberArr();


          --dbms_output.put_line('ln= ' || ln );

  ------------ STEP 1  verify first that all mandatory params are set!
          IF ( InstanceId is NULL or InstanceId.COUNT =0) THEN
                 parameterName := 'InstanceId';
                 RAISE atpParameterSizeError;
          END IF;
          IF ( InventoryItemId is NULL or InventoryItemId.COUNT =0) THEN
                 parameterName := 'InventoryItemId';
                 RAISE atpParameterSizeError;
          END IF;

          IF ( Identifier is NULL or Identifier.COUNT =0) THEN
                 parameterName := 'Identifier';
                 RAISE atpParameterSizeError;
          END IF;

          IF ( CallingModule is NULL or CallingModule.COUNT =0) THEN
                 parameterName := 'Calling Module';
                 RAISE atpParameterSizeError;
          END IF;

           IF ( QuantityOrdered is NULL or QuantityOrdered.COUNT =0) THEN
                 parameterName := 'QuantityOrdered';
                 RAISE atpParameterSizeError;
          END IF;


          IF ( QuantityUOM is NULL or QuantityUOM.COUNT =0) THEN
                 parameterName := 'QuantityUOM';
                 RAISE atpParameterSizeError;
          END IF;

           IF (RequestedShipDate.COUNT=0  AND  RequestedArrivalDate.COUNT =0 ) THEN
                 parameterName := 'Required Ship Date';
                 RAISE atpParameterSizeError;
          END IF;

           IF ( Action is NULL or Action.COUNT =0) THEN
                 parameterName := 'Action';
                 RAISE atpParameterSizeError;
          END IF;

  ----------- STEP 2 verify that the length of all arrays is the SAME !!.
          ln := InventoryItemId.COUNT ;


        error_tracking_number         := 182;

          IF  ( InventoryItemName is not NULL  and InventoryItemName.Count <>0 AND InventoryItemName.COUNT <> ln) THEN
                 parameterName := 'InventoryItemName';
                 RAISE atpParameterSizeError;
          END IF;

	  IF ( SourceOrganizationId is not NULL  and SourceOrganizationId.Count <>0 AND SourceOrganizationId.COUNT <> ln) THEN
                parameterName := 'SourceOrganizationId';
		 RAISE atpParameterSizeError;
	  END IF;

         IF ( SourceOrganizationCode is not NULL  and SourceOrganizationCode.Count <>0 AND SourceOrganizationCode.Count <> ln) THEN
                 parameterName := 'SourceOrganizationCode';
                 RAISE atpParameterSizeError;
         END IF;

         error_tracking_number         := 200;

         IF (OrganizationId is not NULL  and OrganizationId.Count <>0 AND OrganizationId.Count <> ln) THEN
                 parameterName := 'OrganizationId';
                 RAISE atpParameterSizeError;
         END IF;

         IF (Identifier is not NULL  and Identifier.Count <>0 AND Identifier.Count <> ln) THEN
                 parameterName := 'Identifier';
                 RAISE atpParameterSizeError;
         END IF;

         IF (DemandSourceHeaderId is not NULL  and DemandSourceHeaderId.Count <>0 AND DemandSourceHeaderId.Count <> ln) THEN
                 parameterName := 'DemandSourceHeaderId';
                 RAISE atpParameterSizeError;
         END IF;

         IF (DemandSourceDelivery is not NULL  and DemandSourceDelivery.Count <>0 AND DemandSourceDelivery.Count <> ln) THEN
                 parameterName := 'DemandSourceDelivery';
                 RAISE atpParameterSizeError;
         END IF;


         IF (DemandSourceType is not NULL  and DemandSourceType.Count <>0 AND DemandSourceType.Count <> ln) THEN
                 parameterName := 'DemandSourceType';
                 RAISE atpParameterSizeError;
         END IF;

         IF ( CallingModule.Count <>0 AND CallingModule.Count <> ln) THEN
                 parameterName := 'CallingModule';
                 RAISE atpParameterSizeError;
         END IF;

         IF (CustomerId is not NULL  and CustomerId.Count <>0 AND CustomerId.Count <> ln) THEN
                 parameterName := 'CustomerId';
                 RAISE atpParameterSizeError;
         END IF;

         IF (CustomerSiteId is not NULL  and CustomerSiteId.Count <>0 AND CustomerSiteId.Count <> ln) THEN
                 parameterName := 'CustomerSiteId';
                 RAISE atpParameterSizeError;
         END IF;

         error_tracking_number         := 220;

         IF (QuantityOrdered.Count <>0 AND QuantityOrdered.Count <> ln) THEN
                 parameterName := 'QuantityOrdered';
                 RAISE atpParameterSizeError;
         END IF;

         IF ( QuantityUOM.Count <>0 AND QuantityUOM.Count <> ln) THEN
                 parameterName := 'QuantityUOM';
                 RAISE atpParameterSizeError;
         END IF;

         IF ( RequestedShipDate is not NULL and RequestedShipDate.Count <>0  AND RequestedShipDate.Count <> ln) THEN
                parameterName := 'RequestedShipDate';
                 RAISE atpParameterSizeError;
         END IF;

         IF (RequestedArrivalDate is not NULL  and RequestedArrivalDate.Count <>0 AND RequestedArrivalDate.Count <> ln) THEN
                 parameterName := 'RequestedArrivalDate';
                 RAISE atpParameterSizeError;
         END IF;

        IF (LatestAcceptableDate is not NULL  and LatestAcceptableDate.Count <>0 AND LatestAcceptableDate.Count <> ln) THEN
                 parameterName := 'LatestAcceptableDate';
                 RAISE atpParameterSizeError;
         END IF;

        IF (DeliveryLeadTime is not NULL  and DeliveryLeadTime.Count <>0 AND DeliveryLeadTime.Count <> ln) THEN
                 parameterName := 'DeliveryLeadTime';
                 RAISE atpParameterSizeError;
         END IF;

        IF (ShipMethod is not NULL  and ShipMethod.Count <>0 AND ShipMethod.Count <> ln) THEN
                 parameterName := 'ShipMethod';
                 RAISE atpParameterSizeError;
         END IF;


        error_tracking_number         := 250;

        IF (DemandClass is not NULL  and DemandClass.Count <>0 AND DemandClass.Count <> ln) THEN
                 parameterName := 'DemandClass';
                 RAISE atpParameterSizeError;
         END IF;

        IF (ShipSetName is not NULL  and ShipSetName.Count <>0 AND ShipSetName.Count <> ln) THEN
                 parameterName := 'ShipSetName';
                 RAISE atpParameterSizeError;
         END IF;

         IF (ArrivalSetName is not NULL  and ArrivalSetName.Count <>0 AND ArrivalSetName.Count <> ln) THEN
                 parameterName := 'ArrivalSetName';
                 RAISE atpParameterSizeError;
         END IF;

         IF (OverrideFlag is not NULL  and OverrideFlag.Count <>0 AND OverrideFlag.Count <> ln) THEN
                 parameterName := 'OverrideFlag';
                 RAISE atpParameterSizeError;
         END IF;

         IF( Action.Count <>0 AND Action.Count <> ln) THEN
                 parameterName := 'Action';
                 RAISE atpParameterSizeError;
         END IF;

         IF (InsertFlag is not NULL  and InsertFlag.Count <>0 AND InsertFlag.Count <> ln) THEN
                 parameterName := 'InsertFlag';
                 RAISE atpParameterSizeError;
         END IF;

         IF (OEFlag is not NULL  and OEFlag.Count <>0 AND OEFlag.Count <> ln) THEN
                 parameterName := 'OEFlag';
                 RAISE atpParameterSizeError;
         END IF;

          IF (OrderNumber is not NULL  and OrderNumber.Count <>0 AND OrderNumber.Count <> ln) THEN
                 parameterName := 'OrderNumber';
                 RAISE atpParameterSizeError;
         END IF;

         IF (OldSourceOrganizationId is not NULL  and OldSourceOrganizationId.Count <>0 AND OldSourceOrganizationId.Count <> ln) THEN
                parameterName := 'OldSourceOrganizationId';
                RAISE atpParameterSizeError;
         END IF;

          IF (OldDemandClass is not NULL  and OldDemandClass.Count <>0 AND OldDemandClass.Count <> ln) THEN
                 parameterName := 'OldDemandClass';
                 RAISE atpParameterSizeError;
         END IF;

         IF (Attribute01 is not NULL  and Attribute01.Count <>0 AND Attribute01.Count <> ln) THEN
                 parameterName := 'Attribute01';
                 RAISE atpParameterSizeError;
         END IF;

         IF (Attribute02 is not NULL  and Attribute02.Count <>0 AND Attribute02.Count <> ln) THEN
                 parameterName := 'Attribute02';
                 RAISE atpParameterSizeError;
         END IF;

        IF (CustomerCountry is not NULL  and CustomerCountry.Count <>0 AND CustomerCountry.Count <> ln) THEN
                 parameterName := 'CustomerCountry';
                 RAISE atpParameterSizeError;
         END IF;

        IF (CustomerState is not NULL  and CustomerState.Count <>0 AND CustomerState.Count <> ln) THEN
                 parameterName := 'CustomerState';
                 RAISE atpParameterSizeError;
         END IF;

        IF (CustomerCity is not NULL  and CustomerCity.Count <>0 AND CustomerCity.Count <> ln) THEN
                 parameterName := 'CustomerCity';
                 RAISE atpParameterSizeError;
         END IF;

        IF (CustomerPostalCode is not NULL  and CustomerPostalCode.Count <>0 AND CustomerPostalCode.Count <> ln) THEN
                 parameterName := 'CustomerPostalCode';
                 RAISE atpParameterSizeError;
         END IF;

        IF (SubstitutionTypeCode is not NULL  and SubstitutionTypeCode.Count <>0 AND SubstitutionTypeCode.Count <> ln) THEN
                 parameterName := 'SubstitutionTypeCode';
                 RAISE atpParameterSizeError;
         END IF;

        IF (ReqItemDetailFlag is not NULL  and ReqItemDetailFlag.Count <>0 AND ReqItemDetailFlag.Count <> ln) THEN
                 parameterName := 'ReqItemDetailFlag';
                 RAISE atpParameterSizeError;
         END IF;

        IF (SalesRep is not NULL  and SalesRep.Count <>0 AND SalesRep.Count <> ln) THEN
                 parameterName := 'SalesRep';
                 RAISE atpParameterSizeError;
         END IF;

         IF (CustomerContact is not NULL  and CustomerContact.Count <>0 AND CustomerContact.Count <> ln) THEN
                 parameterName := 'CustomerContact';
                 RAISE atpParameterSizeError;
         END IF;

         error_tracking_number         := 300;

        IF (TopModelLineId is not NULL  and TopModelLineId.Count <>0 AND TopModelLineId.Count <> ln) THEN
                 parameterName := 'TopModelLineId';
                 RAISE atpParameterSizeError;
         END IF;

        IF (ATOParentModelLineId is not NULL  and ATOParentModelLineId.Count <>0 AND ATOParentModelLineId.Count <> ln) THEN
                 parameterName := 'ATOParentModelLineId';
                 RAISE atpParameterSizeError;
         END IF;

        IF (ATOModelLineId is not NULL  and ATOModelLineId.Count <>0 AND ATOModelLineId.Count <> ln) THEN
                 parameterName := 'ATOModelLineId';
                 RAISE atpParameterSizeError;
         END IF;

        IF (ParentLineId is not NULL  and ParentLineId.Count <>0 AND ParentLineId.Count <> ln) THEN
                 parameterName := 'ParentLineId';
                 RAISE atpParameterSizeError;
         END IF;

        IF (MatchItemId is not NULL  and MatchItemId.Count <>0 AND MatchItemId.Count <> ln) THEN
                 parameterName := 'MatchItemId';
                 RAISE atpParameterSizeError;
         END IF;

        IF (ConfigItemLineId is not NULL  and ConfigItemLineId.Count <>0 AND ConfigItemLineId.Count <> ln) THEN
                 parameterName := 'ConfigItemLineId';
                 RAISE atpParameterSizeError;
         END IF;

        IF (ValidationOrg is not NULL  and ValidationOrg.Count <>0 AND ValidationOrg.Count <> ln) THEN
                 parameterName := 'ValidationOrg';
                 RAISE atpParameterSizeError;
         END IF;

        IF (ComponentSequenceID is not NULL  and ComponentSequenceID.Count <>0 AND ComponentSequenceID.Count <> ln) THEN
                 parameterName := 'ComponentSequenceID';
                 RAISE atpParameterSizeError;
         END IF;

        IF (ComponentCode is not NULL  and ComponentCode.Count <>0 AND ComponentCode.Count <> ln) THEN
                 parameterName := 'ComponentCode';
                 RAISE atpParameterSizeError;
         END IF;

          IF (LineNumber is not NULL  and LineNumber.Count <>0 AND LineNumber.Count <> ln) THEN
                 parameterName := 'LineNumber';
                 RAISE atpParameterSizeError;
         END IF;

          IF (IncludedItemFlag is not NULL  and IncludedItemFlag.Count <>0 AND IncludedItemFlag.Count <> ln) THEN
                 parameterName := 'IncludedItemFlag';
                 RAISE atpParameterSizeError;
         END IF;

          IF (PickComponentsFlag is not NULL  and PickComponentsFlag.Count <>0 AND PickComponentsFlag.Count <> ln ) THEN
                 parameterName := 'PickComponentsFlag';
                 RAISE atpParameterSizeError;
         END IF;

          IF (CascadeModelInfoToComp is not NULL  and CascadeModelInfoToComp.Count <>0 AND CascadeModelInfoToComp.Count <> ln) THEN
                 parameterName := 'CascadeModelInfoToComp';
                 RAISE atpParameterSizeError;
         END IF;

          IF (SequenceNumber is not NULL  and SequenceNumber.Count <>0 AND SequenceNumber.Count <> ln) THEN
                 parameterName := 'SequenceNumber';
                 RAISE atpParameterSizeError;
         END IF;

        IF (InternalOrgId is not NULL  and InternalOrgId.Count <>0 AND InternalOrgId.Count <> ln) THEN
                 parameterName := 'InternalOrgId';
                 RAISE atpParameterSizeError;
         END IF;

        IF (PartySiteId is not NULL  and PartySiteId.Count <>0 AND PartySiteId.Count <> ln) THEN
                 parameterName := 'PartySiteId';
                 RAISE atpParameterSizeError;
         END IF;

        IF (PartOfSet is not NULL  and PartOfSet.Count <>0 AND PartOfSet.Count <> ln) THEN
                 parameterName := 'PartOfSet';
                 RAISE atpParameterSizeError;
         END IF;




 ----------STEP 3 -- apps initialize for system_administrator , just so we can get profiles values
          SELECT responsibility_id,  application_id INTO respId, appId FROM fnd_responsibility WHERE responsibility_key = 'SYSTEM_ADMINISTRATOR';
          error_tracking_number:= 110;

          SELECT user_id            INTO userId FROM fnd_user WHERE user_name = 'SYSADMIN';

          error_tracking_number:= 120;
          fnd_global.apps_initialize(userId, respId, appId);

          -- now we get profile values, and properly init apps_initialize();
          error_tracking_number:= 130;
          userId := fnd_profile.value('MSC_WS_ATP_FNDUSER');
          error_tracking_number:= 140;
          respId := fnd_profile.value('MSC_WS_ATP_FNDRESP');

          error_tracking_number:= 150;
          begin
              SELECT application_id INTO appId FROM fnd_responsibility WHERE responsibility_id = respId;
              EXCEPTION
              WHEN others THEN
                RAISE atpProfilesError;
          end;


          error_tracking_number:= 160;
          fnd_global.apps_initialize(userId, respId, appId);

          error_tracking_number:= 170;

-----------GET SESSION ID ------------------------------
           msc_atp_global.get_atp_session_id(sessionId, temp_status);


----------- STEP 4   -- form  input parameters
            MSC_SATP_FUNC.Extend_Atp (p_atp_table, x_return_status, ln);
          error_tracking_number:= 1180;

           IF InstanceId is not NULL and InstanceId.Count <>0 THEN
            FOR i IN 1 .. ln LOOP p_atp_table.Instance_Id(i) := InstanceId(i);   END LOOP ;
           END IF;


           IF InventoryItemId is not NULL and InventoryItemId.Count <>0 THEN
                FOR i IN 1 .. ln
                LOOP
                p_atp_table.Inventory_Item_Id (i) := InventoryItemId (i);
                END LOOP ;
           END IF;

           IF InventoryItemName is not NULL and InventoryItemName.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Inventory_Item_Name (i) := InventoryItemName (i);   END LOOP ;
           END IF;
           IF SourceOrganizationId is not NULL and SourceOrganizationId.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Source_Organization_Id (i) := SourceOrganizationId (i);   END LOOP ;
           END IF;
           IF SourceOrganizationCode is not NULL and SourceOrganizationCode.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Source_Organization_Code (i) := SourceOrganizationCode (i);   END LOOP ;
           END IF;
           IF OrganizationId is not NULL and OrganizationId.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Organization_Id (i) := OrganizationId (i);   END LOOP ;
           END IF;
           IF Identifier is not NULL and Identifier.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Identifier (i) := Identifier (i);   END LOOP ;
           END IF;
           IF DemandSourceHeaderId is not NULL and DemandSourceHeaderId.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Demand_Source_Header_Id (i) := DemandSourceHeaderId (i);   END LOOP ;
           END IF;
           IF DemandSourceDelivery is not NULL and DemandSourceDelivery.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Demand_Source_Delivery (i) := DemandSourceDelivery (i);   END LOOP ;
           END IF;
           IF DemandSourceType is not NULL and DemandSourceType.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Demand_Source_Type (i) := DemandSourceType(i);   END LOOP ;
           END IF;
        -----------------------------------------------------------------------------------------------------------------

           IF CallingModule is not NULL and CallingModule.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Calling_Module  (i) := CallingModule(i);   END LOOP ;
           END IF;
           IF CustomerId is not NULL and CustomerId.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Customer_Id (i) := CustomerId(i);   END LOOP ;
           END IF;
           IF CustomerSiteId is not NULL and CustomerSiteId.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Customer_Site_Id (i) := CustomerSiteId(i);   END LOOP ;
           END IF;
           IF QuantityOrdered is not NULL and QuantityOrdered.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Quantity_Ordered (i) := QuantityOrdered(i);   END LOOP ;
           END IF;
           IF QuantityUOM is not NULL and QuantityUOM.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Quantity_UOM (i) := QuantityUOM(i);   END LOOP ;
           END IF;
           IF RequestedShipDate is not NULL and RequestedShipDate.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Requested_Ship_Date (i) := RequestedShipDate(i);   END LOOP ;
           END IF;
           IF RequestedArrivalDate is not NULL and RequestedArrivalDate.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Requested_Arrival_Date (i) := RequestedArrivalDate(i);   END LOOP ;
           END IF;
           IF LatestAcceptableDate is not NULL and LatestAcceptableDate.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Latest_Acceptable_Date (i) := LatestAcceptableDate(i);   END LOOP ;
           END IF;
           IF DeliveryLeadTime is not NULL and DeliveryLeadTime.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Delivery_Lead_Time (i) := DeliveryLeadTime(i);   END LOOP ;
           END IF;
           IF ShipMethod is not NULL and ShipMethod.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Ship_Method (i) := ShipMethod(i);   END LOOP ;
           END IF;
          -----------------------------------------------------------------------------------------------------------------

           IF DemandClass is not NULL and DemandClass.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Demand_Class (i) := DemandClass(i);   END LOOP ;
           END IF;
           IF ShipSetName is not NULL and ShipSetName.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Ship_Set_Name (i) := ShipSetName(i);   END LOOP ;
           END IF;
           IF ArrivalSetName is not NULL and ArrivalSetName.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Arrival_Set_Name (i) := ArrivalSetName(i);   END LOOP ;
           END IF;
           IF OverrideFlag is not NULL and OverrideFlag.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Override_Flag (i) := OverrideFlag(i);   END LOOP ;
           END IF;
           IF Action is not NULL and Action.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Action(i) := Action(i);   END LOOP ;
           END IF;
           IF InsertFlag is not NULL and InsertFlag.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Insert_Flag (i) := InsertFlag(i);   END LOOP ;
           END IF;
           IF OEFlag is not NULL and OEFlag.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.OE_Flag (i) := OEFlag(i);   END LOOP ;
           END IF;
           IF OrderNumber is not NULL and OrderNumber.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Order_Number (i) := OrderNumber(i);   END LOOP ;
           END IF;
           IF OldSourceOrganizationId is not NULL and OldSourceOrganizationId.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Old_Source_Organization_Id (i) := OldSourceOrganizationId(i);   END LOOP ;
           END IF;
           IF OldDemandClass is not NULL and OldDemandClass.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Old_Demand_Class (i) := OldDemandClass(i);   END LOOP ;
           END IF;
           IF Attribute01 is not NULL and Attribute01.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Attribute_01 (i) := Attribute01(i);   END LOOP ;
           END IF;
           -----------------------------------------------------------------------------------------------------------------

           IF Attribute02 is not NULL and Attribute02.Count <>0 THEN
                  FOR i IN 1 .. ln LOOP p_atp_table.Attribute_02 (i) := Attribute02(i);   END LOOP ;
           END IF;
           IF CustomerCountry is not NULL and CustomerCountry.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Customer_Country (i) := CustomerCountry(i);   END LOOP ;
           END IF;
           IF CustomerState is not NULL and CustomerState.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Customer_State (i) := CustomerState(i);   END LOOP ;
           END IF;
           IF CustomerCity is not NULL and CustomerCity.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Customer_City (i) := CustomerCity(i);   END LOOP ;
           END IF;
           IF CustomerPostalCode is not NULL and CustomerPostalCode.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Customer_Postal_Code (i) := CustomerPostalCode(i);   END LOOP ;
           END IF;
           IF SubstitutionTypeCode is not NULL and SubstitutionTypeCode.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Substitution_Typ_Code (i) := SubstitutionTypeCode(i);   END LOOP ;
           END IF;
           IF ReqItemDetailFlag is not NULL and ReqItemDetailFlag.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Req_Item_Detail_Flag (i) := ReqItemDetailFlag(i);   END LOOP ;
           END IF;
           IF SalesRep is not NULL and SalesRep.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Sales_Rep (i) := SalesRep(i);   END LOOP ;
           END IF;
           IF CustomerContact is not NULL and CustomerContact.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Customer_Contact (i) := CustomerContact(i);   END LOOP ;
           END IF;
           IF TopModelLineId is not NULL and TopModelLineId.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Top_Model_Line_Id (i) := TopModelLineId(i);   END LOOP ;
           END IF;
           IF ATOParentModelLineId is not NULL and ATOParentModelLineId.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.ATO_Parent_Model_Line_Id (i) := ATOParentModelLineId(i);   END LOOP ;
           END IF;
           IF ATOModelLineId is not NULL and ATOModelLineId.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.ATO_Model_Line_Id (i) := ATOModelLineId(i);   END LOOP ;
           END IF;
           IF ParentLineId is not NULL and ParentLineId.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Parent_Line_Id (i) := ParentLineId(i);   END LOOP ;
           END IF;
           IF MatchItemId is not NULL and MatchItemId.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Match_Item_Id (i) := MatchItemId(i);   END LOOP ;
           END IF;
           IF ConfigItemLineId is not NULL and ConfigItemLineId.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Config_Item_Line_Id (i) := ConfigItemLineId(i);   END LOOP ;
           END IF;
           IF ValidationOrg is not NULL and ValidationOrg.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Validation_Org (i) := ValidationOrg(i);   END LOOP ;
           END IF;
           IF ComponentSequenceID is not NULL and ComponentSequenceID.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Component_Sequence_ID (i) := ComponentSequenceID(i);   END LOOP ;
           END IF;
           IF ComponentCode is not NULL and ComponentCode.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Component_Code (i) := ComponentCode(i);   END LOOP ;
           END IF;
           IF LineNumber is not NULL and LineNumber.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Line_Number (i) := LineNumber(i);   END LOOP ;
           END IF;
           IF IncludedItemFlag is not NULL and IncludedItemFlag.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Included_Item_Flag (i) := IncludedItemFlag(i);   END LOOP ;
           END IF;
           -----------------------------------------------------------------------------------------------------------------

           IF PickComponentsFlag is not NULL and PickComponentsFlag.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Pick_Components_Flag (i) := PickComponentsFlag(i);   END LOOP ;
           END IF;
           IF CascadeModelInfoToComp is not NULL and CascadeModelInfoToComp.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Cascade_Model_Info_To_Comp (i) := CascadeModelInfoToComp(i);   END LOOP ;
           END IF;
           IF SequenceNumber is not NULL and SequenceNumber.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Sequence_Number (i) := SequenceNumber(i);   END LOOP ;
           END IF;
           IF InternalOrgId is not NULL and InternalOrgId.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Internal_Org_Id (i) := InternalOrgId(i);   END LOOP ;
           END IF;
           IF PartySiteId is not NULL and PartySiteId.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Party_Site_Id (i) := PartySiteId(i);   END LOOP ;
           END IF;
           IF PartOfSet is not NULL and PartOfSet.Count <>0 THEN
                FOR i IN 1 .. ln LOOP p_atp_table.Part_Of_Set (i) := PartOfSet(i);   END LOOP ;
           END IF;

         error_tracking_number:= 1190;

        /* for i in 1..ln loop
         dbms_output.put_line('Inventory_Item_Id = ' || p_atp_table.Inventory_Item_Id(i) );
         dbms_output.put_line('Identifier = ' || p_atp_table.Identifier(i) );
         dbms_output.put_line('Calling Module = ' || p_atp_table.Calling_Module(i) );
         dbms_output.put_line('Q Ordered = ' || p_atp_table.Quantity_Ordered(i) );
         dbms_output.put_line('Q UOM = ' || p_atp_table.Quantity_UOM(i) );
         dbms_output.put_line('Req Ship Date = ' || p_atp_table.Requested_Ship_Date(i) );
         dbms_output.put_line('Req Arrival Date = ' || p_atp_table.Requested_Arrival_Date(i) );
         dbms_output.put_line('Action = ' || p_atp_table.Action(i)) ;
         dbms_output.put_line('InstanceId = ' || p_atp_table.Instance_id(i)) ;
         dbms_output.put_line('ShipMethod = ' || p_atp_table.Ship_Method(i)) ;
         dbms_output.put_line('SrOrgId = ' || p_atp_table.Source_organization_id(i)) ;
         dbms_output.put_line('orderNumber = ' || p_atp_table.Order_Number(i)) ;
         dbms_output.put_line('OverrideFlag = ' || p_atp_table.Override_Flag(i)) ;
         dbms_output.put_line('InsertFlag = ' || p_atp_table.Insert_Flag(i)) ;
         end loop;
         dbms_output.put_line('status = ' || status );
         dbms_output.put_line('sessionId = ' || sessionId );*/

------- STEP 5 -- Call pl/sqlp ATP
          MRP_ATP_PUB.Call_ATP(
            sessionId,
            p_atp_table,
            x_atp_table,
            x_atp_supply_demand,
            x_atp_period,
            x_atp_details,
            x_return_status,
            x_msg_data,
            x_msg_count);

            error_tracking_number:= 200;

            IF x_return_status = 'E'  THEN
                RAISE atpError;
            END IF;

            IF x_return_status = 'U'  THEN
                RAISE atpUnknownError;
            END IF;


             -- otherwise x_return_status = 'S' for success
            ln := x_atp_table.Ship_Date.Count;
            if ln = 0 then
                ln := x_atp_table.Arrival_Date.Count;
            end if;

            error_tracking_number:= 2100;


            IF ln > 0 THEN
              InstanceIdOut.extend(ln);
              FOR i IN 1 .. ln LOOP InstanceIdOut (i) := x_atp_table.Instance_Id(i);   END LOOP ;
              InventoryItemIdOut.extend(ln);
              FOR i IN 1 .. ln LOOP InventoryItemIdOut (i) := x_atp_table.Inventory_Item_Id(i);   END LOOP ;

              InventoryItemNameOut.extend(ln);
              FOR i IN 1 .. ln LOOP InventoryItemNameOut (i) := x_atp_table.Inventory_Item_Name(i);   END LOOP ;
              SourceOrganizationIdOut.extend(ln);
              FOR i IN 1 .. ln LOOP SourceOrganizationIdOut (i) := x_atp_table.Source_Organization_Id(i);   END LOOP ;
              SourceOrganizationCodeOut.extend(ln);
              FOR i IN 1 .. ln LOOP SourceOrganizationCodeOut (i) := x_atp_table.Source_Organization_Code(i);   END LOOP ;

              error_tracking_number:= 2103;

              OrganizationIdOut.extend(ln);
              FOR i IN 1 .. ln LOOP OrganizationIdOut (i) := x_atp_table.Organization_Id(i);   END LOOP ;
              IdentifierOut.extend(ln);
              FOR i IN 1 .. ln LOOP IdentifierOut (i) := x_atp_table.Identifier(i);   END LOOP ;
              DemandSourceHeaderIdOut.extend(ln);
              FOR i IN 1 .. ln LOOP DemandSourceHeaderIdOut (i) := x_atp_table.Demand_Source_Header_Id(i);   END LOOP ;
              DemandSourceDeliveryOut.extend(ln);
              FOR i IN 1 .. ln LOOP DemandSourceDeliveryOut (i) := x_atp_table.Demand_Source_Delivery(i);   END LOOP ;
              DemandSourceTypeOut.extend(ln);
              FOR i IN 1 .. ln LOOP DemandSourceTypeOut (i) := x_atp_table.Demand_Source_Type(i);   END LOOP ;

              error_tracking_number:= 2104;

              CustomerIdOut.extend(ln);
              FOR i IN 1 .. ln LOOP CustomerIdOut (i) := x_atp_table.Customer_Id(i);   END LOOP ;
              CustomerSiteIdOut.extend(ln);
              FOR i IN 1 .. ln LOOP CustomerSiteIdOut (i) := x_atp_table.Customer_Site_Id(i);   END LOOP ;
              QuanitytOrderedOut.extend(ln);
              FOR i IN 1 .. ln LOOP QuanitytOrderedOut (i) := x_atp_table.Quantity_Ordered(i);   END LOOP ;
              QuantityUOMOut.extend(ln);
              FOR i IN 1 .. ln LOOP QuantityUOMOut (i) := x_atp_table.Quantity_UOM(i);   END LOOP ;
              RequestedShipDateOut.extend(ln);
              FOR i IN 1 .. ln LOOP RequestedShipDateOut (i) := x_atp_table.Requested_Ship_Date(i);   END LOOP ;
              RequestedArrivalDateOut.extend(ln);
              FOR i IN 1 .. ln LOOP RequestedArrivalDateOut (i) := x_atp_table.Requested_Arrival_Date(i);   END LOOP ;
              LatestAcceptableDateOut.extend(ln);
              FOR i IN 1 .. ln LOOP LatestAcceptableDateOut (i) := x_atp_table.Latest_Acceptable_Date(i);   END LOOP ;
              DeliveryLeadTimeOut.extend(ln);
              FOR i IN 1 .. ln LOOP DeliveryLeadTimeOut (i) := x_atp_table.Delivery_Lead_Time(i);   END LOOP ;
              ShipMethodOut.extend(ln);
              FOR i IN 1 .. ln LOOP ShipMethodOut (i) := x_atp_table.Ship_Method(i);   END LOOP ;
              DemandClassOut.extend(ln);
              FOR i IN 1 .. ln LOOP DemandClassOut (i) := x_atp_table.Demand_Class(i);   END LOOP ;

              error_tracking_number:= 2105;

              ShipSetNameOut.extend(ln);
              FOR i IN 1 .. ln LOOP ShipSetNameOut (i) := x_atp_table.Ship_Set_Name(i);   END LOOP ;
              ArrivalSetNameOut.extend(ln);
              FOR i IN 1 .. ln LOOP ArrivalSetNameOut (i) :=x_atp_table. Arrival_Set_Name(i);   END LOOP ;
              OverrideFlagOut.extend(ln);
              FOR i IN 1 .. ln LOOP OverrideFlagOut (i) := x_atp_table.Override_Flag(i);   END LOOP ;
              ShipDateOut.extend(ln);
              FOR i IN 1 .. ln LOOP ShipDateOut (i) := x_atp_table.Ship_Date(i);   END LOOP ;
              ArrivalDateOut.extend(ln);
              FOR i IN 1 .. ln LOOP ArrivalDateOut (i) := x_atp_table.Arrival_Date(i);   END LOOP ;
              AvailableQuantityOut.extend(ln);
              FOR i IN 1 .. ln LOOP AvailableQuantityOut (i) := x_atp_table.Available_Quantity(i);   END LOOP ;

              AvailableQuantityOut.extend(ln);
              FOR i IN 1 .. ln LOOP AvailableQuantityOut (i) := x_atp_table.Available_Quantity(i);   END LOOP ;
              RequestedDateQuantityOut.extend(ln);
              FOR i IN 1 .. ln LOOP RequestedDateQuantityOut (i) := x_atp_table.Requested_Date_Quantity(i);   END LOOP ;
              GroupShipDateOut.extend(ln);
              FOR i IN 1 .. ln LOOP GroupShipDateOut (i) := x_atp_table.Group_Ship_Date(i);   END LOOP ;
              GroupArrivalDateOut.extend(ln);
              FOR i IN 1 .. ln LOOP GroupArrivalDateOut (i) := x_atp_table.Group_Arrival_Date(i);   END LOOP ;

              error_tracking_number:= 2106;

              AtpLeadTimeOut.extend(ln);
              FOR i IN 1 .. ln LOOP AtpLeadTimeOut (i) := x_atp_table.Atp_Lead_Time(i);   END LOOP ;
              ErrorCodeOut.extend(ln);
              FOR i IN 1 .. ln LOOP ErrorCodeOut (i) := x_atp_table.Error_Code(i);   END LOOP ;
              EndPeggingIdOut.extend(ln);
              FOR i IN 1 .. ln LOOP EndPeggingIdOut (i) :=x_atp_table.End_Pegging_Id(i);   END LOOP ;
              OldSourceOrganizationIdOut.extend(ln);
              FOR i IN 1 .. ln LOOP OldSourceOrganizationIdOut (i) := x_atp_table.Old_Source_Organization_Id(i);   END LOOP ;
              OldDemandClassOut.extend(ln);
              FOR i IN 1 .. ln LOOP OldDemandClassOut (i) := x_atp_table.Old_Demand_Class(i);   END LOOP ;
              RequestItemIdOut.extend(ln);
              FOR i IN 1 .. ln LOOP RequestItemIdOut (i) := x_atp_table.Request_Item_Id(i);   END LOOP ;
              ReqItemReqDateQtyOut.extend(ln);
              FOR i IN 1 .. ln LOOP ReqItemReqDateQtyOut (i) := x_atp_table.Req_Item_Req_Date_Qty(i);   END LOOP ;
              ReqItemAvailableDateQtyOut.extend(ln);
              FOR i IN 1 .. ln LOOP ReqItemAvailableDateQtyOut (i) := x_atp_table.Req_Item_Available_Date_Qty(i);   END LOOP ;
              RequestItemNameOut.extend(ln);
              FOR i IN 1 .. ln LOOP RequestItemNameOut (i) := x_atp_table.Request_Item_Name(i);   END LOOP ;
              OldInventoryItemIdOut.extend(ln);
              FOR i IN 1 .. ln LOOP OldInventoryItemIdOut (i) := x_atp_table.Old_Inventory_Item_Id(i);   END LOOP ;

              error_tracking_number:= 2110;

              SubstFlagOut.extend(ln);
              FOR i IN 1 .. ln LOOP SubstFlagOut (i) := x_atp_table.Subst_Flag(i);   END LOOP ;
              BaseModelIdOut.extend(ln);
              FOR i IN 1 .. ln LOOP BaseModelIdOut (i) := x_atp_table.Base_Model_Id(i);   END LOOP ;
              OssErrorCodeOut.extend(ln);
              FOR i IN 1 .. ln LOOP OssErrorCodeOut (i) := x_atp_table.Oss_Error_Code(i);   END LOOP ;
              MatchedItemNameOut.extend(ln);
              FOR i IN 1 .. ln LOOP MatchedItemNameOut (i) := x_atp_table.Matched_Item_Name(i);   END LOOP ;
              CascadeModelInfoToCompOut.extend(ln);
              FOR i IN 1 .. ln LOOP CascadeModelInfoToCompOut (i) := x_atp_table.Cascade_Model_Info_To_Comp(i);   END LOOP ;
              PlanIdOut.extend(ln);
              FOR i IN 1 .. ln LOOP PlanIdOut (i) := x_atp_table.Plan_Id(i);   END LOOP ;

          END IF;

          error_tracking_number:= 2200;
          status := 'SUCCESS';


    EXCEPTION
    WHEN atpParameterSizeError THEN
        status := 'ERROR_WRONG ARRAY_SIZE IN ' || parameterName;
        RETURN;
    WHEN atpError THEN
        status := 'ERROR_ATP';
        RETURN;
    WHEN atpProfilesError THEN
        status := 'ERROR_PROFILES_FOR_USER_OR_RESPID_NOT_SET';
        RETURN;
    WHEN others THEN
        status := 'ERROR_UNEXPECTED_'||error_tracking_number;
        RETURN;

END GetPromiseDate;



 PROCEDURE GetPromiseDate_Public(
 	  status                        OUT nocopy VARCHAR2,
           UserName               IN VARCHAR2,
 	  RespName     IN VARCHAR2,
 	  RespApplName IN VARCHAR2,
 	  SecurityGroupName      IN VARCHAR2,
 	  Language            IN VARCHAR2,
           InstanceId                    IN MscNumberArr ,
           InventoryItemId               IN MscNumberArr,
           InventoryItemName             IN MscChar40Arr,
           SourceOrganizationId          IN MscNumberArr ,
           SourceOrganizationCode        IN MscChar7Arr ,
           OrganizationId                IN MscNumberArr ,
           Identifier                    IN MscNumberArr ,
           DemandSourceHeaderId          IN MscNumberArr ,
           DemandSourceDelivery          IN MscChar30Arr ,
           DemandSourceType              IN MscNumberArr ,
           CallingModule                 IN MscNumberArr ,
           CustomerId                    IN MscNumberArr ,
           CustomerSiteId                IN MscNumberArr ,
           QuantityOrdered               IN MscNumberArr ,
           QuantityUOM                   IN MscChar3Arr ,
           RequestedShipDate             IN MscDateArr,
           RequestedArrivalDate          IN MscDateArr ,
           LatestAcceptableDate          IN MscDateArr ,
           DeliveryLeadTime              IN MscNumberArr ,
           ShipMethod                    IN MscChar30Arr ,
           DemandClass                   IN MscChar30Arr ,
           ShipSetName                   IN MscChar30Arr ,
           ArrivalSetName                IN MscChar30Arr ,
           OverrideFlag                  IN MscChar1Arr ,
           Action                        IN MscNumberArr ,
           InsertFlag                    IN MscNumberArr ,
           OEFlag                        IN MscChar1Arr ,
           OrderNumber                   IN MscNumberArr ,
           OldSourceOrganizationId       IN MscNumberArr ,
           OldDemandClass                IN MscChar30Arr ,
           Attribute01                   IN MscNumberArr ,
           Attribute02                   IN MscNumberArr ,
           CustomerCountry               IN MscChar60Arr ,
           CustomerState                 IN MscChar60Arr ,
           CustomerCity                  IN MscChar60Arr ,
           CustomerPostalCode            IN MscChar60Arr ,
           SubstitutionTypeCode          IN MscNumberArr ,
           ReqItemDetailFlag             IN MscNumberArr ,
           SalesRep                      IN MscChar255Arr ,
           CustomerContact               IN MscChar255Arr ,
           TopModelLineId                IN MscNumberArr ,
           ATOParentModelLineId          IN MscNumberArr ,
           ATOModelLineId                IN MscNumberArr ,
           ParentLineId                  IN MscNumberArr ,
           MatchItemId                   IN MscNumberArr ,
           ConfigItemLineId              IN MscNumberArr ,
           ValidationOrg                 IN MscNumberArr ,
           ComponentSequenceID           IN MscNumberArr ,
           ComponentCode                 IN MscChar255Arr ,
           LineNumber                    IN MscChar80Arr ,
           IncludedItemFlag              IN MscNumberArr ,
           PickComponentsFlag            IN MscChar1Arr ,
           CascadeModelInfoToComp        IN MscNumberArr ,
           SequenceNumber                IN MscNumberArr ,
           InternalOrgId                 IN MscNumberArr ,
           PartySiteId                   IN MscNumberArr ,
           PartOfSet                     IN MscChar1Arr ,

           InstanceIdOut                 OUT nocopy MscNumberArr,
           InventoryItemIdOut            OUT nocopy MscNumberArr,
           InventoryItemNameOut          OUT nocopy MscChar40Arr,
           SourceOrganizationIdOut       OUT nocopy MscNumberArr,
           SourceOrganizationCodeOut     OUT nocopy MscChar7Arr,
           OrganizationIdOut             OUT nocopy MscNumberArr,
           IdentifierOut                 OUT nocopy MscNumberArr,
           DemandSourceHeaderIdOut       OUT nocopy MscNumberArr,
           DemandSourceDeliveryOut       OUT nocopy MscChar30Arr,
           DemandSourceTypeOut           OUT nocopy MscNumberArr,
           CustomerIdOut                 OUT nocopy MscNumberArr,
           CustomerSiteIdOut             OUT nocopy MscNumberArr,
           QuanitytOrderedOut            OUT nocopy MscNumberArr,
           QuantityUOMOut                OUT nocopy MscChar3Arr,
           RequestedShipDateOut          OUT nocopy MscDateArr,
           RequestedArrivalDateOut       OUT nocopy MscDateArr,
           LatestAcceptableDateOut       OUT nocopy MscDateArr,
           DeliveryLeadTimeOut           OUT nocopy MscNumberArr,
           ShipMethodOut                 OUT nocopy MscChar30Arr,
           DemandClassOut                OUT nocopy MscChar30Arr,
           ShipSetNameOut                OUT nocopy MscChar30Arr,
           ArrivalSetNameOut             OUT nocopy MscChar30Arr,
           OverrideFlagOut               OUT nocopy MscChar1Arr,
           ShipDateOut                   OUT nocopy MscDateArr,
           ArrivalDateOut                OUT nocopy MscDateArr,
           AvailableQuantityOut          OUT nocopy MscNumberArr,
           RequestedDateQuantityOut      OUT nocopy MscNumberArr,
           GroupShipDateOut              OUT nocopy MscDateArr,
           GroupArrivalDateOut           OUT nocopy MscDateArr,
           AtpLeadTimeOut                OUT nocopy MscNumberArr,
           ErrorCodeOut                  OUT nocopy MscNumberArr,
           EndPeggingIdOut               OUT nocopy MscNumberArr,
           OldSourceOrganizationIdOut    OUT nocopy MscNumberArr,
           OldDemandClassOut             OUT nocopy MscChar30Arr,
           RequestItemIdOut              OUT nocopy MscNumberArr,
           ReqItemReqDateQtyOut          OUT nocopy MscNumberArr,
           ReqItemAvailableDateOut       OUT nocopy MscDateArr,
           ReqItemAvailableDateQtyOut    OUT nocopy MscNumberArr,
           RequestItemNameOut            OUT nocopy MscChar40Arr,
           OldInventoryItemIdOut         OUT nocopy MscNumberArr,
           SubstFlagOut                  OUT nocopy MscNumberArr,
           BaseModelIdOut                OUT nocopy MscNumberArr,
           OssErrorCodeOut               OUT nocopy MscNumberArr,
           MatchedItemNameOut            OUT nocopy MscChar255Arr,
           CascadeModelInfoToCompOut     OUT nocopy MscNumberArr,
           PlanIdOut                     OUT nocopy MscNumberArr
           )AS
 		     userid    number;
 		     respid    number;
 		     l_String VARCHAR2(30);
 		     error_tracking_num number;
 		     l_SecutirtGroupId  NUMBER;
 		    BEGIN
                     InstanceIdOut                 := MscNumberArr();
          InventoryItemIdOut		:= MscNumberArr();
          InventoryItemNameOut		:= MscChar40Arr();
          SourceOrganizationIdOut	:= MscNumberArr();
          SourceOrganizationCodeOut     := MscChar7Arr();
          OrganizationIdOut		:= MscNumberArr();
          IdentifierOut			:= MscNumberArr();
          DemandSourceHeaderIdOut	:= MscNumberArr();
          DemandSourceDeliveryOut	:= MscChar30Arr();
          DemandSourceTypeOut		:= MscNumberArr();
          CustomerIdOut			:= MscNumberArr();
          CustomerSiteIdOut		:= MscNumberArr();
          QuanitytOrderedOut            := MscNumberArr();
          QuantityUOMOut                := MscChar3Arr();
          RequestedShipDateOut          := MscDateArr();
          RequestedArrivalDateOut       := MscDateArr();
          LatestAcceptableDateOut       := MscDateArr();
          DeliveryLeadTimeOut           := MscNumberArr();
          ShipMethodOut                 := MscChar30Arr();
          DemandClassOut                := MscChar30Arr();
          ShipSetNameOut                := MscChar30Arr();
          ArrivalSetNameOut             := MscChar30Arr();
          OverrideFlagOut               := MscChar1Arr();
          ShipDateOut                   := MscDateArr();
          ArrivalDateOut                := MscDateArr();
          AvailableQuantityOut          := MscNumberArr();
          RequestedDateQuantityOut      := MscNumberArr();
          GroupShipDateOut              := MscDateArr();
          GroupArrivalDateOut           := MscDateArr();
          AtpLeadTimeOut                := MscNumberArr();
          ErrorCodeOut                  := MscNumberArr();
          EndPeggingIdOut               := MscNumberArr();
          OldSourceOrganizationIdOut    := MscNumberArr();
          OldDemandClassOut             := MscChar30Arr();
          RequestItemIdOut              := MscNumberArr();
          ReqItemReqDateQtyOut          := MscNumberArr();
          ReqItemAvailableDateOut       := MscDateArr();
          ReqItemAvailableDateQtyOut    := MscNumberArr();
          RequestItemNameOut            := MscChar40Arr();
          OldInventoryItemIdOut         := MscNumberArr();
          SubstFlagOut                  := MscNumberArr();
          BaseModelIdOut                := MscNumberArr();
          OssErrorCodeOut               := MscNumberArr();
          MatchedItemNameOut            := MscChar255Arr();
          CascadeModelInfoToCompOut     := MscNumberArr();
          PlanIdOut                     := MscNumberArr();
 		      error_tracking_num :=2010;
 		       MSC_WS_COMMON.GET_PERMISSION_IDS(l_String, userid, respid, l_SecutirtGroupId, UserName, RespName, RespApplName, SecurityGroupName, Language);
 		       IF (l_String <> 'OK') THEN
 		           Status := l_String;
 		           RETURN;
 		       END IF;

 		        error_tracking_num :=2030;
 		       MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, userid, respid, 'MSC_MSCOSCWB',l_SecutirtGroupId);
 		       IF (l_String <> 'OK') THEN
 		           Status := l_String;
 		           RETURN;
 		       END IF;
 		       error_tracking_num :=2040;

 		      GetPromiseDate(  		Status,
                                             	InstanceId  ,
                                             	InventoryItemId,
                                             	InventoryItemName ,
                                             	SourceOrganizationId ,
                                             	SourceOrganizationCode ,
                                             	OrganizationId  ,
                                             	Identifier  ,
                                             	DemandSourceHeaderId  ,
                                              	DemandSourceDelivery  ,
                                             	DemandSourceType ,
                                             	CallingModule ,
                                             	CustomerId ,
           					CustomerSiteId,
           					QuantityOrdered ,
           					QuantityUOM ,
           					RequestedShipDate,
           					RequestedArrivalDate,
           					LatestAcceptableDate ,
           					DeliveryLeadTime,
           					ShipMethod,
           					DemandClass ,
           					ShipSetName  ,
           					ArrivalSetName  ,
           					OverrideFlag ,
           					Action  ,
           					InsertFlag  ,
           					OEFlag  ,
           					OrderNumber ,
           					OldSourceOrganizationId,
           					OldDemandClass ,
           					Attribute01  ,
           					Attribute02,
           					CustomerCountry  ,
           					CustomerState  ,
           					CustomerCity ,
           					CustomerPostalCode ,
           					SubstitutionTypeCode ,
          					ReqItemDetailFlag  ,
           					SalesRep ,
           					CustomerContact  ,
           					TopModelLineId ,
           					ATOParentModelLineId ,
           					ATOModelLineId ,
           					ParentLineId ,
           					MatchItemId  ,
           					ConfigItemLineId ,
           					ValidationOrg ,
           					ComponentSequenceID ,
           					ComponentCode ,
           					LineNumber ,
           					IncludedItemFlag  ,
           					PickComponentsFlag ,
           					CascadeModelInfoToComp  ,
           					SequenceNumber,
          				        InternalOrgId ,
           					PartySiteId ,
           					PartOfSet ,

           					InstanceIdOut,
           					InventoryItemIdOut,
           					InventoryItemNameOut,
           					SourceOrganizationIdOut ,
           					SourceOrganizationCodeOut,
           					OrganizationIdOut ,
           					IdentifierOut,
           					DemandSourceHeaderIdOut ,
           					DemandSourceDeliveryOut,
           					DemandSourceTypeOut,
           					CustomerIdOut ,
           					CustomerSiteIdOut,
           					QuanitytOrderedOut,
           					QuantityUOMOut ,
           					RequestedShipDateOut   ,
           					RequestedArrivalDateOut ,
           					LatestAcceptableDateOut,
           					DeliveryLeadTimeOut ,
           					ShipMethodOut ,
           					DemandClassOut,
           					ShipSetNameOut ,
           					ArrivalSetNameOut,
           					OverrideFlagOut,
           					ShipDateOut ,
           					ArrivalDateOut ,
           					AvailableQuantityOut ,
           					RequestedDateQuantityOut,
           					GroupShipDateOut,
           					GroupArrivalDateOut,
           					AtpLeadTimeOut ,
           					ErrorCodeOut ,
           					EndPeggingIdOut ,
           					OldSourceOrganizationIdOut,
           					OldDemandClassOut,
           					RequestItemIdOut,
           					ReqItemReqDateQtyOut ,
           					ReqItemAvailableDateOut,
           					ReqItemAvailableDateQtyOut,
           					RequestItemNameOut,
           					OldInventoryItemIdOut ,
           					SubstFlagOut ,
           					BaseModelIdOut,
           					OssErrorCodeOut,
           					MatchedItemNameOut ,
           					CascadeModelInfoToCompOut,
           					PlanIdOut  );



 		         EXCEPTION
 		         WHEN others THEN
 		            status := 'ERROR_UNEXPECTED_'||error_tracking_num;

 		            return;
 END   GetPromiseDate_Public;








END MSC_WS_ATP;

/
