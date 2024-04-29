--------------------------------------------------------
--  DDL for Package MSC_WS_APS_DATA_SERVICES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_WS_APS_DATA_SERVICES" AUTHID CURRENT_USER AS
/* $Header: MSCWDATS.pls 120.7 2008/03/27 20:01:47 mtsui noship $ */

-- =============================================================
--  A note about output levels.
--  Output levels can be grouped into four categories, Item, Organization,
--  Customer and Demand Class. Category Item is mandatory, the rest are optional.
--  When any category is included in the set of output levels, only one member
--  from the category can be specified.
--    Calegory Item has 1(Item) and 3(Product Family).
--    Category Organization has single member, 7(Organization).
--    Category Customer has four members, 11(Customer Ship To Site),
--      15(Customer), 41(Customer Zone) and 42(Zone).
--    Category Demand Class has single member, 34(Demand Class).
-- =============================================================


-- =============================================================
-- Desc: Upload demand forecasts into msd_dp_scn_entries_denorm table.
--
-- Input:
--        UserName           User name.
--        RespName           Responsibility name.
--        RespAppName        Responsibility application name.
--        SecurityGroupName  Security group name.
--        Language           Language.
--        ScenarioName       Scenario Name, it is used to retrieve the scenario_id.
--        ItemOutputLevel    Item output level, either ITEM or PRODUCT_FAMILY.
--        OrganizationOutputLevel
--                           Organization output level, either Y or N.
--        CustomerOutputLevel
--                           Customer output level, either NONE, CUSTOMER_SHIP_TO_SITE,
--                           CUSTOMER, CUSTOMER_ZONE or ZONE.
--        DemandClassOutputLevel
--                           Demand class output level, either Y or N.
--        PurgeAllFlag       Allowed input is Y or N.
--                           If this parameter is set to Y, this operation will delete
--                           msd_dp_scn_entries_denorm for 5555555 + senario_id before
--                           any upload data is inserted/updated.
--        ForecastTbl        List of forecasts to be uploaded to msd_dp_scn_entries_denorm.
--            BucketType         Type of time bucket, allowed value is 1(Day), 2(Week), 3(Month).
--            StartDate          Start date of the bucket, ignore the time part.
--            EndDate            End Start date of the bucket, ignore the time part.
--            Quantity           Quantity.
--            SrOrganizationId   Source organization id. Ignore this if OutputToOrganization is N.
--            SrInstanceId       Source instance id.
--            ErrorType          Error type, allowed value is MAD, MAPE or NULL.
--            ForecastError      NULL, or >= 0 for MAD, 0 - 100 for MAPE.
--            ItemId             Inventory item. This parameter will be used to query the SR_INVENTORY_ITEM_ID.
--                               If OutputToItem is ITEM, this is an item id.
--                               If OutputToItem is PRODUCT_FAMILY, this is a product family id.
--            ShipToLocation     Ship to location. Ignore this if OutputToCustomer is not CUSTOMER_SHIP_TO_SITE.
--            SrCustomerId       Source customer id. Ignore this unless OutputToCustomer is either Customer or Customer Zone.
--            SrZoneId           Source Zone id. Ignore this if OutputToCustomer is not Customer Zone.
--            Priority           Priority.
--            Uom                Primary UOM code, ASCP.
--            DemandClass        Demand class. Ignore this if OutputToDemandClass is N.
--            UnitPrice          Unit price.
--            ErrorStatus        Always ignore this,
--
-- Output:
--        Status             The possible return statuses are:
--                           SUCCESS               if everything is ok
--                           COMPLETED_WITH_ERROR  if any record in ForecastTbl failed the validation, the bad
--                                                 forecast record will be added to BadRecTbl
--                           INVALID_FND_USERID
--                           INVALID_FND_RESPONSIBILITYID
--                           INVALID_SCENARIO_NAME
--                           DUPLICATE_SCENARIO_NAME
--                           INCONSIST_OUTPUT_LEVELS
--                           NO_DATA
--        BadRecTbl          List of forecasts that are failed the validation.
-- =============================================================
PROCEDURE UPLOAD_FORECAST(
        Status             OUT NOCOPY VARCHAR2,
        BadRecTbl          OUT NOCOPY MscForecastTbl,
--        UserId             IN         NUMBER,
--        ResponsibilityId   IN         NUMBER,
        UserName           IN         VARCHAR2,
        RespName           IN         VARCHAR2,
        RespAppName        IN         VARCHAR2,
        SecurityGroupName  IN         VARCHAR2,
        Language           IN         VARCHAR2,
        ScenarioName       IN         VARCHAR2,
        ItemOutputLevel    IN         VARCHAR2,
        OrganizationOutputLevel
                           IN         VARCHAR2,
        CustomerOutputLevel
                           IN         VARCHAR2,
        DemandClassOutputLevel
                           IN         VARCHAR2,
        PurgeAllFlag       IN         VARCHAR2,
        ForecastTbl        IN         MscForecastTbl
        );


-- =============================================================
-- Desc: Download demand forecast from msd_dp_scn_entries_denorm table.
--
-- Input:
--        UserName           User name.
--        RespName           Responsibility name.
--        RespAppName        Responsibility application name.
--        SecurityGroupName  Security group name.
--        Language           Language.
--        DemandPlanName     Demand plan name, it is used to retrieve the demand_plan_id
--        ScenarioName       Scenario Name, its is used to retrieve the scenario_id.
--        ItemIdList         List of item ids.
--        ProductFamilyIdList
--                           List of product family ids.
--        OrganizationIdList Organization output level, either Y or N.
--        ShipToLocIdList    List of ship to location ids.
--        CustomerIdList     List of customer ids.
--        CustomerZoneList   List of customer id and zone id pairs.
--        ZoneIdList         List of zone ids.
--        DemandClassList    List of demand classes.
--        StartDate          Start date.
--        EndDate            End date.
--
-- Output:
--        Status             The possible return statuses are:
--                           SUCCESS               if everything is ok
--                           INVALID_FND_USERID
--                           INVALID_FND_RESPONSIBILITYID
--                           INVALID_DEMAND_PLAN_NAME
--                           DUPLICATE_DEMAND_PLAN_NAME
--                           INVALID_SCENARIO_NAME
--                           DUPLICATE_SCENARIO_NAME
--                           BOTH_ITEM_AND_PRODUCT_FAMILY
--                           INVALID_ITEM_ID
--                           INVALID_PRODUCT_FAMILY_ID
--                           INVALID_SR_ORGANIZATION_ID
--                           INVALID_SHIP_TO_LOCATION_ID
--                           MULTIPLE_CUSTOMER_LEVEL_DATA
--                           INVALID_SR_CUSTOMER_ID
--                           INVALID_SR_ZONE_ID
--                           INVALID_DEMAND_CLASS
--                           INVALID_START_END_DATE
--        ForecastTbl        List of forecasts that are downloaded.
-- =============================================================
PROCEDURE DOWNLOAD_FORECAST(
        Status             OUT NOCOPY VARCHAR2,
        ForecastTbl        OUT NOCOPY MscForecastTbl,
--        UserId             IN         NUMBER,
--        ResponsibilityId   IN         NUMBER,
        UserName           IN         VARCHAR2,
        RespName           IN         VARCHAR2,
        RespAppName        IN         VARCHAR2,
        SecurityGroupName  IN         VARCHAR2,
        Language           IN         VARCHAR2,
        DemandPlanName     IN         VARCHAR2,
        ScenarioName       IN         VARCHAR2,
        ItemIdList         IN         MscNumberArr,
        ProductFamilyIdList
                           IN         MscNumberArr,
        OrganizationIdList IN         MscNumberArr,
        ShipToLocIdList    IN         MscNumberArr,
        CustomerIdList     IN         MscNumberArr,
        CustomerZoneList   IN         MscCustZoneTbl,
        ZoneIdList         IN         MscNumberArr,
        DemandClassList    IN         MscChar255Arr,
        StartDate          IN         DATE,
        EndDate            IN         DATE
        );


-- =============================================================
-- Desc: Upload safety stocks into msc_safety_stocks table.
--
-- Input:
--        UserName           User name.
--        RespName           Responsibility name.
--        RespAppName        Responsibility application name.
--        SecurityGroupName  Security group name.
--        Language           Language.
--        PlanName           Plan name, use this + OwningOrgId + SrInstanceId to guery plan_id from msc_plans.
--        OwningOrgId        Owning organization id for the plan.
--        SrInstanceId       Source instance id.
--        PurgeAllFlag       Allowed input is Y or N.
--                           If this parameter is set to Y, this operation will delete
--                           msc_safety_stocks for plan_id + SrInstanceId + OrganizationId + ItemId
--                           before any upload data is inserted/updated.
--        SafetyStockTbl     List of safety stocks to be uploaded to msc_safety_stocks.
--            OrganizationId     Oragnization id.
--            SrInstanceId       Source instance id.
--            ItemId             Item id.
--            PeriodStartDate    Period start date.
--            SafetyStockQty     Safety stock quantity.
--            TargetSafetyStock  Target safety stock.
--            ProjectId          Project Id.
--            TaskId             Task Id.
--            PlanningGroup      Planning group.
--            UserDefinedSafetyStock
--                               User defined safety stock quantity.
--            UserDefinedDOS     User defined days of supply.
--            TargetDOS          Taget days of supply.
--            AchievedDOS        Achieved days of supply.
--            DemandVarSSPct     Percentage of total Safety Stock held for demand variability.
--            MfgLTVarSSPct      Percentage of total Safety Stock held for Mfg. leadtime variability.
--            TransitLTVarSSPct  Percentage of total Safety Stock held for Transit leadtime variability.
--            SupLTVarSSPct      Percentage of total Safety Stock held for Supplier leadtime variability.
--            TotalUnpooledSS    Unpooled Sum of Safety Stocks for all Uncertainity forms.
--            ErrorStatus        Always ignore this,
--
-- Output:
--        Status             The possible return statuses are:
--                           SUCCESS               if everything is ok
--                           COMPLETED_WITH_ERROR  if any record in ForecastTbl failed the validation, the bad
--                                                 forecast record will be added to BadRecTbl
--                           INVALID_FND_USERID
--                           INVALID_FND_RESPONSIBILITYID
--                           FAILED_TO_QUERY_PLAN_ID
--                           PLAN_IS_NOT_READY
--                           NO_DATA
--        BadRecTbl          List of safety stocks that are failed the validation.
-- =============================================================
PROCEDURE UPLOAD_SAFETY_STOCKS(
        Status             OUT NOCOPY VARCHAR2,
        BadRecTbl          OUT NOCOPY MscSafetyStockTbl,
--        UserId             IN         NUMBER,
--        ResponsibilityId   IN         NUMBER,
        UserName           IN         VARCHAR2,
        RespName           IN         VARCHAR2,
        RespAppName        IN         VARCHAR2,
        SecurityGroupName  IN         VARCHAR2,
        Language           IN         VARCHAR2,
        PlanName           IN         VARCHAR2,
        OwningOrgId        IN         NUMBER,
        SrInstanceId       IN         NUMBER,
        PurgeAllFlag       IN         VARCHAR2,
        SafetyStockTbl     IN         MscSafetyStockTbl
        );


-- =============================================================
-- Desc: Download safety stocks from mss_safety_stocks table.
--
-- Input:
--        UserName           User name.
--        RespName           Responsibility name.
--        RespAppName        Responsibility application name.
--        SecurityGroupName  Security group name.
--        Language           Language.
--        PlanName           Plan name, use this + OwningOrgId + SrInstanceId to guery plan_id from msc_plans.
--        OwningOrgId        Owning organization id for the plan.
--        SrInstanceId       Source instance id.
--        ItemIdList         List of item Ids.
--        OrganizationIdList List of organization Ids
--
-- Output:
--        Status             The possible return statuses are:
--                           SUCCESS               if everything is ok
--                           INVALID_FND_USERID
--                           INVALID_FND_RESPONSIBILITYID
--                           FAILED_TO_QUERY_PLAN_ID
--                           INVALID_ITEM_ID
--                           INVALID_ORGANIZATION_ID
--        ForecastTbl        List of safety stocks that are downloaded.
-- =============================================================
PROCEDURE DOWNLOAD_SAFETY_STOCKS(
        Status             OUT NOCOPY VARCHAR2,
        SafetyStockTbl     OUT NOCOPY MscSafetyStockTbl,
--        UserId             IN         NUMBER,
--        ResponsibilityId   IN         NUMBER,
        UserName           IN         VARCHAR2,
        RespName           IN         VARCHAR2,
        RespAppName        IN         VARCHAR2,
        SecurityGroupName  IN         VARCHAR2,
        Language           IN         VARCHAR2,
        PlanName           IN         VARCHAR2,
        OwningOrgId        IN         NUMBER,
        SrInstanceId       IN         NUMBER,
        ItemIdList         IN         MscNumberArr,
        OrganizationIdList IN         MscNumberArr
        );


-- =============================================================
-- Desc: Upload firmed plan orders into msc_supplies table.
--
-- Input:
--        UserName           User name.
--        RespName           Responsibility name.
--        RespAppName        Responsibility application name.
--        SecurityGroupName  Security group name.
--        Language           Language.
--        PlanName           Plan name, use this + OwningOrgId + SrInstanceId to guery plan_id from msc_plans.
--        OwningOrgId        Owning organization id for the plan.
--        SrInstanceId       Source instance id.
--        PlannedSupplyTbl   List of safety stocks to be uploaded to msc_supplies.
--            OrganizationId     Organization id.
--            ItemId             Item id.
--            Quantity           Quantity.
--            FirmDate           Firm date.
--
-- Output:
--        Status             The possible return statuses are:
--                           SUCCESS               if everything is ok
--                           COMPLETED_WITH_ERROR  if any record in ForecastTbl failed the validation, the bad
--                                                 forecast record will be added to BadRecTbl
--                           INVALID_FND_USERID
--                           INVALID_FND_RESPONSIBILITYID
--                           FAILED_TO_QUERY_PLAN_ID
--                           INVALID_PLAN_TYPE
--                           PLAN_IS_NOT_READY
--                           NO_DATA
--        BadRecTbl          List of firmed plann orders that are failed the validation.
-- =============================================================
PROCEDURE UPLOAD_PLANNED_SUPPLY(
        Status             OUT NOCOPY VARCHAR2,
        BadRecTbl          OUT NOCOPY MscPlannedSupplyTbl,
--        UserId             IN         NUMBER,
--        ResponsibilityId   IN         NUMBER,
        UserName           IN         VARCHAR2,
        RespName           IN         VARCHAR2,
        RespAppName        IN         VARCHAR2,
        SecurityGroupName  IN         VARCHAR2,
        Language           IN         VARCHAR2,
        PlanName           IN         VARCHAR2,
        OwningOrgId        IN         NUMBER,
        SrInstanceId       IN         NUMBER,
        PlannedSupplyTbl   IN         MscPlannedSupplyTbl
        );



END MSC_WS_APS_DATA_SERVICES;


/
