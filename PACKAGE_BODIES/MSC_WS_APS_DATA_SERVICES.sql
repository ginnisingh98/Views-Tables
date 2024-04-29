--------------------------------------------------------
--  DDL for Package Body MSC_WS_APS_DATA_SERVICES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_WS_APS_DATA_SERVICES" AS
/* $Header: MSCWDATB.pls 120.10 2008/03/27 20:02:22 mtsui noship $ */

g_UserId               NUMBER; -- used by UPLOAD_XXX
g_DemandId             NUMBER; -- Cache the current demand id, used by UPLOAD_FORECAST

g_DummyDemandPlanId    NUMBER;
g_DummyDemandPlanName  VARCHAR2(30);

-- Global variable for un-handled exceptions
g_ErrorCode            VARCHAR2(30);



-- =============================================================
-- Un-handled exceptions generate error tokens in the
-- format of ERROR_UNEXPECTED_#####.
--
-- The possible values are:
--   02001 - UPLOAD_FORECAST/GetScenarioId
--   02002 - UPLOAD_FORECAST/ValidateBucketType/CreateNewScenario
--   02003 - UPLOAD_FORECAST/ValidateBucketType
--   02004 - UPLOAD_FORECAST/PurgeAllFcstData
--   02005 - UPLOAD_FORECAST/InsertOutputLevels
--   02006 - UPLOAD_FORECAST/ValidateOutputLevels
--   02007 - UPLOAD_FORECAST/ProcessForecast/ValidateStartEndDates
--   02008 - UPLOAD_FORECAST/ProcessForecast/ValidateSrData/ sr instance id
--   02009 - UPLOAD_FORECAST/ProcessForecast/ValidateSrData/ local forecast
--   02010 - UPLOAD_FORECAST/ProcessForecast/ValidateItemData
--   02011 - UPLOAD_FORECAST/ProcessForecast/ValidateCustomerData
--   02012 - UPLOAD_FORECAST/ProcessForecast/ValidateUomCode
--   02013 - UPLOAD_FORECAST/ProcessForecast/ValidateDemandClass
--   02014 - UPLOAD_FORECAST/ProcessForecast/InsertForecast/GenerateDemandId
--   02015 - UPLOAD_FORECAST/ProcessForecast/InsertForecast
--   02016 - UPLOAD_FORECAST/Insert dummy record
--   02020 - DOWNLOAD_FORECAST/GetDemandPlanId
--   02021 - DOWNLOAD_FORECAST
--   02031 - UPLOAD_SAFETY_STOCKS/GetPlanId
--   02032 - UPLOAD_SAFETY_STOCKS/ProcessSafetyStock/ organization id
--   02033 - UPLOAD_SAFETY_STOCKS/ProcessSafetyStock/  item id
--   02034 - UPLOAD_SAFETY_STOCKS/ purge all safety stocks
--   02035 - UPLOAD_SAFETY_STOCKS/ProcessSafetyStock/ValidatePeriodStartDate
--   02036 - UPLOAD_SAFETY_STOCKS/ProcessSafetyStock/ValidateProjectDate
--   02037 - UPLOAD_SAFETY_STOCKS/ProcessSafetyStock/InsertSafetyStock
--   02038 - UPLOAD_SAFETY_STOCKS/ProcessSafetyStock/UpdateSafetyStock
--   02040 - DOWNLOAD_SAFETY_STOCKS
--   02050 - UPLOAD_PLANNED_SUPPLY/ValidatePlanType
--   02051 - UPLOAD_PLANNED_SUPPLY/ purge all firmed plan orders
--   02052 - UPLOAD_PLANNED_SUPPLY/ProcessPlannedSupply/ organization id
--   02053 - UPLOAD_PLANNED_SUPPLY/ProcessPlannedSupply/ item id
--   02054 - UPLOAD_PLANNED_SUPPLY/ProcessPlannedSupply/InsertPlannedSupply

--   02098 - UPLOAD_PLANNED_SUPPLY/ check msc_plans.plan_completion_date
--   02099 - UPLOAD_SAFETY_STOCKS/ check msc_plans.plan_completion_date
-- =============================================================



-- =============================================================
--
-- Private helper functions for MSC_WS_APS_DATA_SERVICES.
--
-- =============================================================

-- =============================================================
--
-- Private helper functions for Demand Forecast.
--
-- =============================================================
FUNCTION GetScenarioId(ScenarioId OUT NOCOPY NUMBER, DemandPlanId IN NUMBER, ScenarioName IN VARCHAR2) RETURN VARCHAR2;

-- Private helper functions used by UPLOAD_FORECAST only.
PROCEDURE CreateNewScenario(ScenarioId OUT NOCOPY NUMBER, ScenarioName IN VARCHAR2);
PROCEDURE MakeOutputLevelSet(OutputLevels OUT NOCOPY MscNumberArr, ItemOutputLevel IN VARCHAR2, OrganizationOutputLevel IN VARCHAR2, CustomerOutputLevel IN VARCHAR2, DemandClassOutputLevel IN VARCHAR2);
PROCEDURE PurgeAllFcstData(ScenarioId IN NUMBER);
PROCEDURE InsertOutputLevels(ScenarioId IN NUMBER, ItemOutputLevel IN VARCHAR2, OrganizationOutputLevel IN VARCHAR2, CustomerOutputLevel IN VARCHAR2, DemandClassOutputLevel IN VARCHAR2);
FUNCTION ValidateOutputLevels(ScenarioId IN NUMBER, ItemOutputLevel IN VARCHAR2, OrganizationOutputLevel IN VARCHAR2, CustomerOutputLevel IN VARCHAR2, DemandClassOutputLevel IN VARCHAR2) RETURN VARCHAR2;
FUNCTION ValidateBucketType(BucketType IN NUMBER) RETURN VARCHAR2;
FUNCTION ValidateStartEndDates(BucketType IN NUMBER, StartDate IN DATE, EndDate IN DATE) RETURN VARCHAR2;
FUNCTION ValidateSrData(NewOrgId OUT NOCOPY NUMBER, ValidationOrgId OUT NOCOPY NUMBER, OutputToOrganization IN VARCHAR2, SrInstanceId IN NUMBER, SrOrgId IN NUMBER) RETURN VARCHAR2;
FUNCTION ValidateErrorData(ErrorType IN VARCHAR2, ForecastError IN NUMBER) RETURN VARCHAR2;
FUNCTION ValidateItemData(SrItemId OUT NOCOPY NUMBER, OutputToItem IN VARCHAR2, SrInstanceId IN NUMBER, OrgId IN NUMBER, ItemId IN NUMBER) RETURN VARCHAR2;
FUNCTION ValidateCustomerData(OutputToCustomer IN VARCHAR2, SrInstanceId IN NUMBER, ShipToLocation IN NUMBER, SrCustomerId IN NUMBER, SrZoneId IN NUMBER) RETURN VARCHAR2;
FUNCTION ValidateUomCode(SrInstanceId IN NUMBER, OrgId IN NUMBER, ItemId IN NUMBER, UomCode IN VARCHAR2) RETURN VARCHAR2;
FUNCTION ValidateDemandClass(OutputToDemandClass IN VARCHAR2, SrInstanceId IN NUMBER, DemandClass IN VARCHAR2) RETURN VARCHAR2;
PROCEDURE GenerateDemandId(ScenarioId IN NUMBER);
PROCEDURE InsertForecast(ScenarioId IN NUMBER, ForecastData IN MscForecastRec, OrganizationId IN NUMBER, SrItemId IN NUMBER);
FUNCTION ProcessForecast(ScenarioId IN NUMBER, OutputToItem IN VARCHAR2, OutputToOrganization IN VARCHAR2, OutputToCustomer IN VARCHAR2, OutputToDemandClass IN VARCHAR2, ForecastData IN MscForecastRec) RETURN VARCHAR2;

-- Private helper functions used by DOWNLOAD_FORECAST and DOWNLOAD_SAFETY_STOCK.
FUNCTION GetDemandPlanId(DemandPlanId OUT NOCOPY NUMBER, DemandPlanName IN VARCHAR2) RETURN VARCHAR2;
FUNCTION MakeSubClause(Clause OUT NOCOPY VARCHAR2, ColumnName IN VARCHAR2, IdList IN MscNumberArr) RETURN VARCHAR2;

-- Private helper functions used by DOWNLOAD_FORECAST only.
FUNCTION MakeSubClause(Clause OUT NOCOPY VARCHAR2, ColumnName1 IN VARCHAR2, ColumnName2 IN VARCHAR2, IdPairList IN MscCustZoneTbl) RETURN VARCHAR2;
FUNCTION MakeSubClause(Clause OUT NOCOPY VARCHAR2, ColumnName IN VARCHAR2, IdList IN MscChar255Arr) RETURN VARCHAR2;
FUNCTION GetItemClause(Clause OUT NOCOPY VARCHAR2, ItemIdList IN MscNumberArr, ProductFamilyIdList IN MscNumberArr) RETURN VARCHAR2;
FUNCTION GetCustomerClause(Clause OUT NOCOPY VARCHAR2, ShipToLocIdList IN MscNumberArr, CustomerIdList IN MscNumberArr, CustZonePairList IN MscCustZoneTbl, ZoneIdList IN MscNumberArr) RETURN VARCHAR2;
FUNCTION GetStartEndDateClause(Clause OUT NOCOPY VARCHAR2, StartDate IN DATE, EndDate IN DATE)RETURN VARCHAR2;
PROCEDURE QueryForecasts(ForecastTbl OUT NOCOPY MscForecastTbl, WhereClause IN VARCHAR2);

-- =============================================================
--
-- Private helper functions for Safety Stock.
--
-- =============================================================
-- Private helper functions used by UPLOAD_SAFETY_STOCKS and UPLOAD_PLANNED_SUPPLIES
FUNCTION GetPlanId(PlanId OUT NOCOPY NUMBER, PlanName IN VARCHAR2, OwningOrgId IN NUMBER, SrInstanceId IN NUMBER) RETURN VARCHAR2;
FUNCTION ValidateOrgId(PlanId IN NUMBER, OrgId IN NUMBER, SrInstId IN NUMBER) RETURN VARCHAR2;
FUNCTION ValidateItemId(PlanId IN NUMBER, SrInstId IN NUMBER, OrgId IN NUMBER, ItemId IN NUMBER) RETURN VARCHAR2;

-- Private helper functions used by UPLOAD_SAFETY_STOCKS only.
FUNCTION ValidatePeriodStartDate(PlanId IN NUMBER, OrgId IN NUMBER, SrInstId IN NUMBER, PeriodStartDate IN DATE) RETURN VARCHAR2;
FUNCTION ValidateProjectDate(PlanId IN NUMBER, OrgId IN NUMBER, SrInstId IN NUMBER, ProjectId IN NUMBER, TaskId IN NUMBER, PlanningGroup IN VARCHAR2) RETURN VARCHAR2;
PROCEDURE InsertSafetyStock(PlanId IN NUMBER, SafetyStockData IN MscSafetyStockRec);
PROCEDURE UpdateSafetyStock(PlanId IN NUMBER, SafetyStockData IN MscSafetyStockRec);
FUNCTION ProcessSafetyStock(PlanId IN NUMBER, OwningOrgId IN NUMBER, SrInstId IN NUMBER, SafetyStockData IN MscSafetyStockRec) RETURN VARCHAR2;

-- Private helper functions used by DOWNLOAD_SAFETY_STOCKS only.
PROCEDURE QuerySafetyStocks(SafetyStockTbl OUT NOCOPY MscSafetyStockTbl, WhereClause IN VARCHAR2);

-- Private helper functions used by UPLOAD_PLANNED_SUPPLIES only.
FUNCTION ValidatePlanType(PlanId IN NUMBER) RETURN VARCHAR2;
PROCEDURE InsertPlannedSupply(PlanId IN NUMBER, SrInstId IN NUMBER, PlannedSupplyData IN MscPlannedSupplyRec);
FUNCTION ProcessPlannedSupply(PlanId IN NUMBER, SrInstanceId IN NUMBER, PlannedSupplyData IN MscPlannedSupplyRec) RETURN VARCHAR2;

-- =============================================================
-- Desc: Create a new scenario.
--
-- Input:
--       ScenarioName      Scenario name.
--
-- Output: No output.
-- =============================================================
PROCEDURE CreateNewScenario(
        ScenarioId         OUT NOCOPY NUMBER,
        ScenarioName       IN         VARCHAR2
) AS
BEGIN
    BEGIN
        SELECT MSD_DP_SCENARIOS_S.NEXTVAL INTO ScenarioId FROM DUAL;

        INSERT INTO msd_dp_scenarios
            (
            demand_plan_id, scenario_id, scenario_name, forecast_based_on,
            last_update_date, last_updated_by, creation_date, created_by
            )
        VALUES
            (
            g_DummyDemandPlanId, ScenarioId, ScenarioName, 'APS_DATA_SERVICE',
            sysdate, g_UserId, sysdate, g_UserId
            );
    END;

    EXCEPTION
        WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_02002';
            raise;
END CreateNewScenario;

-- =============================================================
-- Desc: Get demand plan id.
--
-- Input:
--       DemandPlanName    Demand plan name.
--
-- Output: The possible return statuses are:
--          OK
--          INVALID_DEMAND_PLAN_NAME
--          DUPLICATE_DEMAND_PLAN_NAME
-- =============================================================
FUNCTION GetDemandPlanId(
        DemandPlanId       OUT NOCOPY NUMBER,
        DemandPlanName     IN         VARCHAR2
) RETURN VARCHAR2 AS
BEGIN
    BEGIN
        SELECT distinct demand_plan_id INTO DemandPlanId
        FROM msd_dp_ascp_scenarios_v
        WHERE demand_plan_name = DemandPlanName;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RETURN 'INVALID_DEMAND_PLAN_NAME';
            WHEN TOO_MANY_ROWS THEN
                RETURN 'DUPLICATE_DEMAND_PLAN_NAME';
            WHEN others THEN
                g_ErrorCode := 'ERROR_UNEXPECTED_02020';
                raise;
    END;
    RETURN 'OK';
END GetDemandPlanId;

-- =============================================================
-- Desc: Get scenario id.
--
-- Input:
--       DemandPlanId
--       ScenarioName      Scenario name.
--
-- Output: The possible return statuses are:
--          OK
--          INVALID_SCENARIO_NAME
--          DUPLICATE_SCENARIO_NAME
-- =============================================================
FUNCTION GetScenarioId(
        ScenarioId         OUT NOCOPY NUMBER,
        DemandPlanId       IN         NUMBER,
        ScenarioName       IN         VARCHAR2
) RETURN VARCHAR2 AS
BEGIN
    BEGIN
        SELECT scenario_id
        INTO ScenarioId
        FROM msd_dp_scenarios
        WHERE
            demand_plan_id = DemandPlanId AND
            scenario_name = ScenarioName;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                ScenarioId := -1;
                RETURN 'INVALID_SCENARIO_NAME';
            WHEN TOO_MANY_ROWS THEN
                ScenarioId := -1;
                RETURN 'DUPLICATE_SCENARIO_NAME';
            WHEN others THEN
                ScenarioId := -1;
                g_ErrorCode := 'ERROR_UNEXPECTED_02001';
                raise;
    END;
    RETURN 'OK';
END GetScenarioId;

-- =============================================================
-- Desc: Build the output level sets
--
-- Input:
--       ItemOutputLevel   Item output level, either ITEM or PRODUCT_FAMILY.
--       OrganizationOutputLevel
--                         Organization output level, either Y or N.
--       CustomerOutputLevel
--                         Customer output level, either NONE, CUSTOMER_SHIP_TO_SITE,
--                         CUSTOMER, CUSTOMER_ZONE or ZONE.
--       DemandClassOutputLevel
--                         Demand class output level, either Y or N.
--
-- Output: No output.
-- =============================================================
PROCEDURE MakeOutputLevelSet(
        OutputLevels         OUT NOCOPY MscNumberArr,
        ItemOutputLevel    IN         VARCHAR2,
        OrganizationOutputLevel
                           IN         VARCHAR2,
        CustomerOutputLevel   IN         VARCHAR2,
        DemandClassOutputLevel
                           IN         VARCHAR2
) AS
BEGIN
    -- all the output levels are restricted by xsd
    OutputLevels := MscNumberArr(1);
    IF ItemOutputLevel = 'PRODUCT_FAMILY' THEN
        OutputLevels(1) := 3;
    END IF;
    IF OrganizationOutputLevel = 'Y' THEN
        OutputLevels.extend;
        OutputLevels(OutputLevels.COUNT) := 7;
    END IF;
    IF CustomerOutputLevel <> 'NONE' THEN
        OutputLevels.extend;
        IF CustomerOutputLevel = 'CUSTOMER_SHIP_TO_SITE' THEN
            OutputLevels(OutputLevels.COUNT) := 11;
        ELSIF CustomerOutputLevel = 'CUSTOMER' THEN
            OutputLevels(OutputLevels.COUNT) := 15;
        ELSIF CustomerOutputLevel = 'CUSTOMER_ZONE' THEN
            OutputLevels(OutputLevels.COUNT) := 41;
        ELSIF CustomerOutputLevel = 'ZONE' THEN
            OutputLevels(OutputLevels.COUNT) := 42;
        END IF;
    END IF;
    IF DemandClassOutputLevel = 'Y' THEN
        OutputLevels.extend;
        OutputLevels(OutputLevels.COUNT) := 34;
    END IF;
END MakeOutputLevelSet;

-- =============================================================
-- Desc: Purge forecast data in msd_dp_scn_entries_denorm
--       purge output levels in msd_dp_scenario_output_levels
--       insert new output levels in msd_dp_scenario_output_levels
--
-- Input:
--       ScenarioId        Scenario id.
--
-- Output: No output.
-- =============================================================
PROCEDURE PurgeAllFcstData(ScenarioId IN NUMBER) AS
BEGIN
    BEGIN
        -- purge all forecast
        DELETE FROM msd_dp_scn_entries_denorm
        WHERE scenario_id = ScenarioId;

        -- purge all output levels
        DELETE FROM msd_dp_scenario_output_levels
        WHERE
            demand_plan_id = g_DummyDemandPlanId AND
            scenario_id = ScenarioId;
    END;

    EXCEPTION WHEN others THEN
        g_ErrorCode := 'ERROR_UNEXPECTED_02004';
        raise;

END PurgeAllFcstData;

-- =============================================================
-- Desc: insert output levels in msd_dp_scenario_output_levels
--
-- Input:
--       ScenarioId        Scenario id.
--       ItemOutputLevel   Item output level, either ITEM or PRODUCT_FAMILY.
--       OrganizationOutputLevel
--                         Organization output level, either Y or N.
--       CustomerOutputLevel
--                         Customer output level, either NONE, CUSTOMER_SHIP_TO_SITE,
--                         CUSTOMER, CUSTOMER_ZONE or ZONE.
--       DemandClassOutputLevel
--                         Demand class output level, either Y or N.
--
-- Output: No output.
-- =============================================================
PROCEDURE InsertOutputLevels(
        ScenarioId         IN         NUMBER,
        ItemOutputLevel    IN         VARCHAR2,
        OrganizationOutputLevel
                           IN         VARCHAR2,
        CustomerOutputLevel
                           IN         VARCHAR2,
        DemandClassOutputLevel
                           IN         VARCHAR2
) AS
l_OutputLevels      MscNumberArr;
BEGIN
    l_OutputLevels := MscNumberArr();
    MakeOutputLevelSet(l_OutputLevels, ItemOutputLevel, OrganizationOutputLevel, CustomerOutputLevel, DemandClassOutputLevel);
    FOR I IN l_OutputLevels.first..l_OutputLevels.last
    LOOP
        INSERT INTO msd_dp_scenario_output_levels
        (
            demand_plan_id, scenario_id, level_id,
            last_update_date, last_updated_by, creation_date, created_by
        )
        VALUES
        (
            g_DummyDemandPlanId, ScenarioId, l_OutputLevels(I),
            sysdate, g_UserId, sysdate, g_UserId
        );
    END LOOP;

    EXCEPTION WHEN others THEN
        g_ErrorCode := 'ERROR_UNEXPECTED_02005';
        raise;
END InsertOutputLevels;

-- =============================================================
-- Desc: check consistency of output level parameters against
--       those outpul levels in msd_dp_scenario_output_levels
--
-- Input:
--       ItemOutputLevel   Item output level, either ITEM or PRODUCT_FAMILY.
--       OrganizationOutputLevel
--                         Organization output level, either Y or N.
--       CustomerOutputLevel
--                         Customer output level, either NONE, CUSTOMER_SHIP_TO_SITE,
--                         CUSTOMER, CUSTOMER_ZONE or ZONE.
--       DemandClassOutputLevel
--                         Demand class output level, either Y or N.
--
-- Output: The possible return statuses are:
--          OK
--          INCONSIST_OUTPUT_LEVELS
-- =============================================================
FUNCTION ValidateOutputLevels(
        ScenarioId         IN         NUMBER,
        ItemOutputLevel    IN         VARCHAR2,
        OrganizationOutputLevel
                           IN         VARCHAR2,
        CustomerOutputLevel
                           IN         VARCHAR2,
        DemandClassOutputLevel
                           IN         VARCHAR2
) RETURN VARCHAR2 AS
l_OutputLevels      MscNumberArr;
l_Count             NUMBER;
BEGIN
    l_OutputLevels := MscNumberArr();
    MakeOutputLevelSet(l_OutputLevels, ItemOutputLevel, OrganizationOutputLevel, CustomerOutputLevel, DemandClassOutputLevel);

    BEGIN
        -- check number of output levels
        SELECT count(*) INTO l_Count FROM msd_dp_scenario_output_levels
        WHERE demand_plan_id = g_DummyDemandPlanId AND scenario_id = ScenarioId;
        IF l_Count <> 0 THEN -- Don't need to check if this is a new scenario
            IF l_Count <> l_OutputLevels.COUNT THEN
                RETURN 'INCONSIST_OUTPUT_LEVELS';
            END IF;
            FOR I IN l_OutputLevels.first..l_OutputLevels.last
            LOOP
                BEGIN
                    SELECT 1 INTO l_Count
                    FROM msd_dp_scenario_output_levels
                    WHERE
                        demand_plan_id = g_DummyDemandPlanId AND
                        scenario_id = ScenarioId AND
                        level_id = l_OutputLevels(I);
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            RETURN 'INCONSIST_OUTPUT_LEVELS';
                END;
            END LOOP;
        END IF;
    END;

    RETURN 'OK';
    EXCEPTION WHEN others THEN
        g_ErrorCode := 'ERROR_UNEXPECTED_02006';
        raise;
END ValidateOutputLevels;

-- =============================================================
-- Desc: Validate bucket type.
--
-- Input:
--       BucketType        Bucket Type.
--
-- Output: The possible return statuses are:
--          OK
--          INVALID_BUCKET_TYPE
-- =============================================================
FUNCTION ValidateBucketType( BucketType IN NUMBER ) RETURN VARCHAR2 AS
l_Count             NUMBER;
BEGIN
    -- 'MSC_X_BUCKET_TYPE' is not in fnd_lookups
    IF BucketType IS NULL THEN
        RETURN 'INVALID_BUCKET_TYPE';
    END IF;
    BEGIN
        SELECT count(*) INTO l_Count
        FROM fnd_lookup_values
        WHERE lookup_type = 'MSC_X_BUCKET_TYPE' AND lookup_code = BucketType;
        EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_02003';
            raise;
    END;
    IF l_Count = 0 THEN
        RETURN 'INVALID_BUCKET_TYPE';
    END IF;
    RETURN 'OK';
END ValidateBucketType;

-- =============================================================
-- Desc: Validate start date and end date.
--
-- Input:
--       BucketType        Bucket Type.
--       StartDate         Start date.
--       EndDate           End date.
--
-- Output: The possible return statuses are:
--          OK
--          INVALID_START_END_DATE_FOR_DAILY_BUCKET
--          INVALID_START_END_DATE_FOR_WEEkLY_BUCKET
--          INVALID_START_END_DATE_FOR_MONTHLY_BUCKET
-- =============================================================
FUNCTION ValidateStartEndDates(
        BucketType         IN         NUMBER,
        StartDate          IN         DATE,
        EndDate            IN         DATE
) RETURN VARCHAR2 AS
l_Date              DATE;
BEGIN
    IF BucketType = 1 THEN -- daily bucket
        IF StartDate <> EndDate THEN
            RETURN 'INVALID_START_END_DATE_FOR_DAILY_BUCKET';
        END IF;
    ELSIF BucketType = 2 THEN -- weekly bucket
        -- l_Date := StartDate + 6;
        -- SELECT StartDate + 6 INTO l_Date FROM DUAL;
        IF StartDate + 6 <> EndDate THEN
        -- IF l_Date <> EndDate THEN
            RETURN 'INVALID_START_END_DATE_FOR_WEEKLY_BUCKET';
        END IF;
    ELSE -- monthly bucket can be 5/5 weeks or Gregorian calendar month
        -- start with 4 weeks
        -- SELECT StartDate + 27 INTO l_Date FROM DUAL; -- 4 weeks
        -- IF l_Date <> EndDate THEN
        IF StartDate + 27 <> EndDate THEN
            -- its not 4 weeks period, try 5 weeks
            -- SELECT StartDate + 34 INTO l_Date FROM DUAL; -- 5 weeks
            -- IF l_Date <> EndDate THEN
            IF StartDate + 34 <> EndDate THEN
                -- its not 5 weeks, try Gregorian calendar month
                SELECT TRUNC(StartDate, 'MONTH') INTO l_Date FROM DUAL;
                -- check if StartDate is the first day of the month
                IF StartDate <> l_Date THEN
                    RETURN 'INVALID_START_END_DATE_FOR_MONTHLY_BUCKET';
                ELSE
                    SELECT LAST_DAY(StartDate) INTO l_Date FROM DUAL;
                    -- check if EndDate is the last day of the month
                    IF EndDate <> l_Date THEN
                        RETURN 'INVALID_START_END_DATE_FOR_MONTHLY_BUCKET';
                    END IF;
                END IF;  -- check for Gregorian calendar month
            END IF;      -- check for 5 weeks period
        END IF;          -- check for 4 weeks period
    END IF;

    RETURN 'OK';

    EXCEPTION WHEN others THEN
        g_ErrorCode := 'ERROR_UNEXPECTED_02007';
        raise;

END ValidateStartEndDates;

-- =============================================================
-- Desc: Validate SrOrganizationId, SrInstanceId, get the
--       validation organization id for global forecast as well
--
-- Input:
--       OutputToOrganization
--                         Organization output level, either Y or N.
--       SrOrgId           Source organization id.
--       SrInstanceId        Source instance id.
--
-- Output: The possible return statuses are:
--          OK
--          INVALID_SR_INSTANCE_ID
--          INVALID_SR_ORGANIZATION_ID
--          MISSING_VALIDATION_ORG_ID
-- =============================================================
FUNCTION ValidateSrData(
        NewOrgId             OUT NOCOPY NUMBER,
        ValidationOrgId      OUT NOCOPY NUMBER,
        OutputToOrganization IN         VARCHAR2,
        SrInstanceId         IN         NUMBER,
        SrOrgId              IN         NUMBER
) RETURN VARCHAR2 AS
l_ValidationOrgId   NUMBER;
l_Dummy             NUMBER;
BEGIN
    -- validate sr instance id
    BEGIN
        SELECT validation_org_id INTO l_ValidationOrgId
        FROM msc_apps_instances
        WHERE instance_id = SrInstanceId;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RETURN 'INVALID_SR_INSTANCE_ID';
            WHEN others THEN
                g_ErrorCode := 'ERROR_UNEXPECTED_02008';
                raise;
    END;
    -- validate sr org id, set the validation org id as well
    IF OutputToOrganization = 'Y' THEN
        BEGIN
            SELECT 1 INTO l_Dummy
            FROM msc_trading_partners
            WHERE
                partner_type = 3 AND
                sr_instance_id = SrInstanceId AND
                sr_tp_id = SrOrgId;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RETURN 'INVALID_SR_ORGANIZATION_ID';
                WHEN others THEN
                    g_ErrorCode := 'ERROR_UNEXPECTED_02009';
                    raise;
        END;
        NewOrgId := SrOrgId;
        ValidationOrgId := SrOrgId;
    ELSE
        IF SrOrgId IS NOT NULL THEN
            RETURN 'INVALID_SR_ORGANIZATION_ID';
        ELSE
            NewOrgId := -1;
            IF l_ValidationOrgId IS NULL THEN
                RETURN 'MISSING_VALIDATION_ORG_ID';
            ELSE
                ValidationOrgId := l_ValidationOrgId;
            END IF;
        END IF;
    END IF;

    RETURN 'OK';
END ValidateSrData;

-- =============================================================
-- Desc: Validate ErrorType and ForecastError.
--
-- Input:
--       ErrorType        Error type.
--       ForecastError    Forecast error.
--
-- Output: The possible return statuses are:
--          OK
--          INVALID_ERROR_TYPE
--          INVALID_FORECAST_ERROR
-- =============================================================
FUNCTION ValidateErrorData(
        ErrorType            IN            VARCHAR2,
        ForecastError        IN            NUMBER
) RETURN VARCHAR2 AS
l_Dummy             NUMBER;
BEGIN
    -- ErrorType can be NULL, MAD or MAPE
    IF ErrorType IS NOT NULL AND ErrorType <> 'MAD' AND ErrorType <> 'MAPE' THEN
        RETURN 'INVALID_ERROR_TYPE';
    END IF;

    -- if ErrorType is null, ForecastError has to be null
    -- if ErrorType is MAD, ForecastError can be null, or greater or equal to zero
    -- if ErrorType is MAPE, ForecastError can be null, or between 0 to 100
    IF ErrorType IS NULL THEN
        IF ForecastError IS NOT NULL THEN
            RETURN 'INVALID_FORECAST_ERROR';
        END IF;
    ELSIF ErrorType = 'MAD' THEN
        IF ForecastError IS NOT NULL AND ForecastError < 0 THEN
            RETURN 'INVALID_FORECAST_ERROR';
        END IF;
    ELSE
        IF ForecastError IS NOT NULL AND ForecastError NOT BETWEEN 0 AND 100 THEN
            RETURN 'INVALID_FORECAST_ERROR';
        END IF;
    END IF;

    RETURN 'OK';
END ValidateErrorData;

-- =============================================================
-- Desc: Validate item Id.
--
-- Input:
--       OutputToItem      Item output level, either ITEM or PRODUCT_FAMILY.
--       SrInstanceId      Source instance id.
--       OrgId             Organization id.
--       ItemId            Item id.
--
-- Output: The possible return statuses are:
--          OK
--          INVALID_ITEM_ID
--          INVALID_PRODUCT_FAMILY_ID
--          FAILED_TO_QUERY_SR_ITEM_ID
-- =============================================================
FUNCTION ValidateItemData(
        SrItemId             OUT NOCOPY NUMBER,
        OutputToItem         IN         VARCHAR2,
        SrInstanceId         IN         NUMBER,
        OrgId                IN         NUMBER,
        ItemId               IN         NUMBER
) RETURN VARCHAR2 AS
l_Count             NUMBER;
BEGIN
    IF OutputToItem = 'ITEM' THEN
        BEGIN
            SELECT 1 INTO l_Count
            FROM msc_items
            WHERE
                inventory_item_id = ItemId;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                RETURN 'INVALID_ITEM_ID';
        END;
    ELSE
        SELECT count(*) INTO l_Count
        FROM msc_system_items
        WHERE
            plan_id = -1 and
            inventory_item_id = ItemId and
            sr_instance_id = SrInstanceId and
            organization_id = OrgId and
            bom_item_type = 5;
        IF l_Count = 0 THEN
            RETURN 'INVALID_PRODUCT_FAMILY_ID';
        END IF;
    END IF;
    BEGIN
        SELECT sr_inventory_item_id INTO SrItemId
        FROM msc_system_items
        WHERE
            plan_id = -1 and
            inventory_item_id = ItemId and
            sr_instance_id = SrInstanceId and
            organization_id = OrgId;
       EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RETURN 'FAILED_TO_QUERY_SR_ITEM_ID';
    END;


    RETURN 'OK';
    EXCEPTION WHEN others THEN
        g_ErrorCode := 'ERROR_UNEXPECTED_02010';
        raise;
END ValidateItemData;

-- =============================================================
-- Desc: Validate data related to customer output levels.
--
-- Input:
--       OutputToCustomer  Customer output level, either NONE, CUSTOMER_SHIP_TO_SITE,
--                         CUSTOMER, CUSTOMER_ZONE or ZONE.
--       SrInstanceId      Source instance id.
--       ShipToLocation    Ship to location id.
--       SrCustomerId      Source customer id.
--       SrZoneId          Source Zone primary key.
--
-- Output: The possible return statuses are:
--          OK
--          INVALID_SHIP_TO_LOCATION_ID
--          INVALID_SR_CUSTOMER_ID
--          INVALID_SR_ZONE_ID
-- =============================================================
FUNCTION ValidateCustomerData(
        OutputToCustomer     IN         VARCHAR2,
        SrInstanceId         IN         NUMBER,
        ShipToLocation       IN         NUMBER,
        SrCustomerId         IN         NUMBER,
        SrZoneId             IN         NUMBER
) RETURN VARCHAR2 AS
l_Dummy             NUMBER;
BEGIN
    IF OutputToCustomer = 'CUSTOMER_SHIP_TO_SITE' THEN
        IF ShipToLocation IS NULL THEN
            RETURN 'INVALID_SHIP_TO_LOCATION_ID';
        ELSIF SrCustomerId IS NOT NULL THEN
            RETURN 'INVALID_SR_CUSTOMER_ID';
        ELSIF SrZoneId IS NOT NULL THEN
            RETURN 'INVALID_SR_ZONE_ID';
        END IF;
        BEGIN
            SELECT 1 INTO l_Dummy
            FROM msc_tp_site_id_lid
            WHERE
                sr_tp_site_id = ShipToLocation AND
                partner_type = 2 AND
                sr_instance_id = SrInstanceId;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RETURN 'INVALID_SHIP_TO_LOCATION_ID';
        END;
    ELSIF OutputToCustomer = 'CUSTOMER' THEN
        IF ShipToLocation IS NOT NULL THEN
            RETURN 'INVALID_SHIP_TO_LOCATION_ID';
        ELSIF SrCustomerId IS NULL THEN
            RETURN 'INVALID_SR_CUSTOMER_ID';
        ELSIF SrZoneId IS NOT NULL THEN
            RETURN 'INVALID_SR_ZONE_ID';
        END IF;
        BEGIN
            SELECT 1 INTO l_Dummy
            FROM msc_tp_id_lid
            WHERE
                sr_tp_id = SrCustomerId AND
                partner_type = 2 AND
                sr_instance_id = SrInstanceId;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RETURN 'INVALID_SR_CUSTOMER_ID';
        END;
    ELSIF OutputToCustomer = 'CUSTOMER_ZONE' THEN
        IF ShipToLocation IS NOT NULL THEN
            RETURN 'INVALID_SHIP_TO_LOCATION_ID';
        ELSIF SrCustomerId IS NULL THEN
            RETURN 'INVALID_SR_CUSTOMER_ID';
        ELSIF SrZoneId IS NULL THEN
            RETURN 'INVALID_SR_ZONE_ID';
        END IF;
        BEGIN
            SELECT 1 INTO l_Dummy
            FROM msc_tp_id_lid
            WHERE
                sr_tp_id = SrCustomerId AND
                partner_type = 2 AND
                sr_instance_id = SrInstanceId;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RETURN 'INVALID_SR_CUSTOMER_ID';
        END;
        BEGIN
            SELECT 1 INTO l_Dummy
            FROM msc_regions
            WHERE
                region_id = SrZoneId AND
                sr_instance_id = SrInstanceId;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RETURN 'INVALID_SR_ZONE_ID';
        END;
    ELSIF OutputToCustomer = 'ZONE' THEN
        IF ShipToLocation IS NOT NULL THEN
            RETURN 'INVALID_SHIP_TO_LOCATION_ID';
        ELSIF SrCustomerId IS NOT NULL THEN
            RETURN 'INVALID_SR_CUSTOMER_ID';
        ELSIF SrZoneId IS NULL THEN
            RETURN 'INVALID_SR_ZONE_ID';
        END IF;
        BEGIN
            SELECT 1 INTO l_Dummy
            FROM msc_regions
            WHERE
                region_id = SrZoneId AND
                sr_instance_id = SrInstanceId;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RETURN 'INVALID_SR_ZONE_ID';
        END;
    ELSE -- NONE
        IF ShipToLocation IS NOT NULL THEN
            RETURN 'INVALID_SHIP_TO_LOCATION_ID';
        ELSIF SrCustomerId IS NOT NULL THEN
            RETURN 'INVALID_SR_CUSTOMER_ID';
        ELSIF SrZoneId IS NOT NULL THEN
            RETURN 'INVALID_SR_ZONE_ID';
        END IF;
    END IF;

    RETURN 'OK';

    EXCEPTION WHEN others THEN
        g_ErrorCode := 'ERROR_UNEXPECTED_02011';
        raise;
END ValidateCustomerData;

-- =============================================================
-- Desc: Validate UOM code.
--
-- Input:
--       SrInstanceId      Source instance id.
--       ItemId            Item id.
--       Uom               Unit of meansure code.
--
-- Output: The possible return statuses are:
--          OK
--          UOM_REQUIRED_FOR_ITEM: Uom
-- =============================================================
FUNCTION ValidateUomCode(
        SrInstanceId         IN         NUMBER,
        OrgId                IN         NUMBER,
        ItemId               IN         NUMBER,
        UomCode              IN         VARCHAR2
) RETURN VARCHAR2 AS
l_UomCode             VARCHAR2(10);
BEGIN
    -- validate the dp uom
    BEGIN
        SELECT uom_code INTO l_UomCode
        FROM msc_system_items
        WHERE
            plan_id = -1 and
            sr_instance_id = SrInstanceId and
            organization_id = OrgId and
            inventory_item_id = ItemId;
        EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_02012';
            raise;
    END;
    IF l_UomCode <> UomCode THEN
        RETURN 'UOM_REQUIRED_FOR_ITEM: ' || l_UomCode;
    END IF;

    RETURN 'OK';
END ValidateUomCode;

-- =============================================================
-- Desc: Validate demand class.
--
-- Input:
--       OutputToDemandClass
--                         Demand class output level, either Y or N.
--       SrInstanceId      Source instance id.
--       DemandClass       Demand class.
--
-- Output: The possible return statuses are:
--          OK
--          INVALID_DEMAND_CLASS
-- =============================================================
FUNCTION ValidateDemandClass(
        OutputToDemandClass  IN         VARCHAR2,
        SrInstanceId         IN         NUMBER,
        DemandClass          IN         VARCHAR2
) RETURN VARCHAR2 AS
l_Dummy             NUMBER;
BEGIN
    IF OutputToDemandClass = 'Y' THEN
        IF DemandClass IS NULL THEN
            RETURN 'INVALID_DEMAND_CLASS';
        END IF;
        BEGIN
            SELECT 1 INTO l_Dummy
            FROM msc_demand_classes
            WHERE
                demand_class = DemandClass AND
                sr_instance_id = SrInstanceId;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RETURN 'INVALID_DEMAND_CLASS';
                WHEN others THEN
                    g_ErrorCode := 'ERROR_UNEXPECTED_02013';
                    raise;
        END;
    ELSE
        IF DemandClass IS NOT NULL THEN
            RETURN 'INVALID_DEMAND_CLASS';
        END IF;
    END IF;

    RETURN 'OK';
END ValidateDemandClass;

-- =============================================================
-- Desc: Generate an unique demand id
--
-- Input:
--       ScenarioId        Scenario id.
--
-- Output: No output.
-- =============================================================
PROCEDURE GenerateDemandId(ScenarioId IN NUMBER) AS
l_Count                NUMBER;
BEGIN
    IF g_DemandId = 0 THEN
        BEGIN
            SELECT count(*) INTO l_Count
            FROM msd_dp_scn_entries_denorm
            WHERE scenario_id = ScenarioId;

            IF l_Count = 0 THEN
                g_DemandId := 1000;
            ELSE
                SELECT MAX(demand_id) INTO l_Count
                FROM msd_dp_scn_entries_denorm
                WHERE
                    demand_plan_id = g_DummyDemandPlanId AND
                    scenario_id = ScenarioId;
                g_DemandId := l_Count + 1;
            END IF;

            EXCEPTION WHEN others THEN
                g_ErrorCode := 'ERROR_UNEXPECTED_02014';
                raise;
        END;
    ELSE
        g_DemandId := g_DemandId + 1;
    END IF;

END GenerateDemandId;

-- =============================================================
-- Desc: Insert demand forecast into msd_dp_scn_entries_denorm table.
--
-- Input:
--       ScenarioId        Scenario id.
--       ForecastData      the demand forecast.
--       OrganizationId    Organization id.
--       SrItemId          Source item id.
--       AscpUom           ASCP UOM code.
--
-- Output: No output.
-- =============================================================
PROCEDURE InsertForecast(
        ScenarioId           IN         NUMBER,
        ForecastData         IN         MscForecastRec,
        OrganizationId       IN         NUMBER,
        SrItemId             IN         NUMBER
) AS
BEGIN
    -- generate an unique demand id
    GenerateDemandId(ScenarioId);

    -- insert data
    INSERT INTO msd_dp_scn_entries_denorm
    (
        demand_plan_id, scenario_id, demand_id, bucket_type, start_time, end_time, quantity,
        sr_organization_id, sr_instance_id, sr_inventory_item_id, error_type, forecast_error,
        inventory_item_id, sr_ship_to_loc_id, sr_customer_id, sr_zone_id, priority,
        dp_uom_code, ascp_uom_code, demand_class, unit_price,
        creation_date, created_by, last_update_login
    )
    VALUES
    (
        g_DummyDemandPlanId ,          -- demand_plan_id
        ScenarioId,                    -- scenario_id
        g_DemandId,                    -- demand_id
        ForecastData.BucketType,       -- bucket_type
        ForecastData.StartDate,        -- start_time
        ForecastData.EndDate,          -- end_time
        ForecastData.Quantity,         -- quantity
        ForecastData.SrOrganizationId, -- sr_organization_id
        ForecastData.SrInstanceId,     -- sr_instance_id
        SrItemId,                      -- sr_inventory_item_id
        ForecastData.ErrorType,        -- error_type
        ForecastData.ForecastError,    -- forecast_error
        ForecastData.ItemId,           -- inventory_item_id
        ForecastData.ShipToLocation,   -- sr_ship_to_loc_id
        ForecastData.SrCustomerId,     -- sr_customer_id
        ForecastData.SrZoneId,         -- sr_zone_id
        ForecastData.Priority,         -- priority
        ForecastData.Uom,              -- dp_uom_code
        ForecastData.Uom,              -- ascp_uom_code
        ForecastData.DemandClass,      -- demand_class
        ForecastData.UnitPrice,        -- unit_price
        sysdate,                       -- creation_date
        g_UserId,                      -- created_by
        g_UserId                       -- last_update_login
    ) ;
    EXCEPTION WHEN others THEN
        g_ErrorCode := 'ERROR_UNEXPECTED_02015';
        raise;

END InsertForecast;

-- =============================================================
-- Desc: Process a demand forecast.
--
-- Input:
--       ScenarioId        Scenario Id.
--       OutputToItem      Item output level, either ITEM or PRODUCT_FAMILY.
--       OutputToOrganization
--                         Organization output level, either Y or N.
--       OutputToCustomer  Customer output level, either NONE, CUSTOMER_SHIP_TO_SITE,
--                         CUSTOMER, CUSTOMER_ZONE or ZONE.
--       OutputToDemandClass
--                         Demand class output level, either Y or N.
--       ForecastData      A demand forecast.
--
-- Output: The possible return statuses are:
--          OK
--          INVALID_BUCKET_TYPE
--          INVALID_START_END_DATE_FOR_DAILY_BUCKET
--          INVALID_START_END_DATE_FOR_WEEkLY_BUCKET
--          INVALID_START_END_DATE_FOR_MONTHLY_BUCKET
--          INVALID_QUANTITY
--          INVALID_SR_INSTANCE_ID
--          INVALID_SR_ORGANIZATION_ID
--          MISSING_VALIDATION_ORG_ID
--          INVALID_ERROR_TYPE
--          INVALID_FORECAST_ERROR
--          INVALID_ITEM_ID
--          INVALID_PRODUCT_FAMILY_ID
--          FAILED_TO_QUERY_SR_ITEM_ID
--          INVALID_SHIP_TO_LOCATION_ID
--          INVALID_SR_CUSTOMER_ID
--          INVALID_SR_ZONE_ID
--          INVALID_PRIORITY
--          INVALID_DEMAND_CLASS
--          INVALID_UNIT_PRICE
-- =============================================================
FUNCTION ProcessForecast(
        ScenarioId           IN         NUMBER,
        OutputToItem         IN         VARCHAR2,
        OutputToOrganization IN         VARCHAR2,
        OutputToCustomer     IN         VARCHAR2,
        OutputToDemandClass  IN         VARCHAR2,
        ForecastData         IN         MscForecastRec
) RETURN VARCHAR2 AS
l_String            VARCHAR2(100);
l_OrgId             NUMBER;  -- we need this for global forecast
l_ValidationOrgId   NUMBER;  -- we need this for global forecast
l_SrItemId          NUMBER;
BEGIN
    -- check BucketType
    l_string := ValidateBucketType(ForecastData.BucketType);
    IF (l_String <> 'OK') THEN
        RETURN l_String;
    END IF;

    -- check StartDate and EndDate
    /* Note the validation for start date end date is not completed yet, we need to
       find all the rules */
    l_string := ValidateStartEndDates(ForecastData.BucketType, ForecastData.StartDate, ForecastData.EndDate);
    IF (l_String <> 'OK') THEN
        RETURN l_String;
    END IF;

    -- check Quantity
    IF ForecastData.Quantity < 0 THEN
        RETURN 'INVALID_QUANTITY';
    END IF;

    -- check SrOrganizationId, SrInstanceId, get the validation organization id for global forecast as well
    l_string := ValidateSrData(l_OrgId, l_ValidationOrgId, OutputToOrganization, ForecastData.SrInstanceId, ForecastData.SrOrganizationId);
    IF (l_String <> 'OK') THEN
        RETURN l_String;
    END IF;

    -- check ErrorType and ForecastError
    l_string := ValidateErrorData(ForecastData.ErrorType, ForecastData.ForecastError);
    IF (l_String <> 'OK') THEN
        RETURN l_String;
    END IF;

    -- check ItemId
    l_string := ValidateItemData(l_SrItemId, OutputToItem, ForecastData.SrInstanceId, l_ValidationOrgId, ForecastData.ItemId);
    IF (l_String <> 'OK') THEN
        RETURN l_String;
    END IF;

    -- check data related to customer output levels
    l_string := ValidateCustomerData(OutputToCustomer, ForecastData.SrInstanceId, ForecastData.ShipToLocation, ForecastData.SrCustomerId, ForecastData.SrZoneId);
    IF (l_String <> 'OK') THEN
        RETURN l_String;
    END IF;

    -- check Priority
    IF ForecastData.Priority IS NULL OR ForecastData.Priority < 0 THEN
        RETURN 'INVALID_PRIORITY';
    END IF;

    -- check UOM code
    l_string := ValidateUomCode(ForecastData.SrInstanceId, l_ValidationOrgId, ForecastData.ItemId, ForecastData.Uom);
    IF (l_String <> 'OK') THEN
        RETURN l_String;
    END IF;

    -- check demand class
    l_string := ValidateDemandClass(OutputToDemandClass, ForecastData.SrInstanceId, ForecastData.DemandClass);
    IF (l_String <> 'OK') THEN
        RETURN l_String;
    END IF;

    -- check UnitPrice
    IF ForecastData.UnitPrice IS NULL OR ForecastData.UnitPrice < 0 THEN
        RETURN 'INVALID_UNIT_PRICE';
    END IF;

    -- All parametera pass the validation, insert the new demand
    -- forecast into msd_dp_scn_entries_denorm table.
    InsertForecast(ScenarioId, ForecastData, l_OrgId, l_SrItemId);

    RETURN 'OK';

    EXCEPTION
        WHEN others THEN
            RETURN g_ErrorCode;

END ProcessForecast;

-- =============================================================
-- Desc: Make sub clause.
--
-- Input:
--       ColumnName          Column name.
--       IdList              List ids.
--
-- Output: The possible return statuses are:
--          OK
--          ERROR
-- =============================================================
FUNCTION MakeSubClause(
        Clause               OUT NOCOPY VARCHAR2,
        ColumnName           IN         VARCHAR2,
        IdList               IN         MscNumberArr
) RETURN VARCHAR2 AS
l_AddComma        BOOLEAN;
BEGIN
    IF IdList.COUNT = 1 THEN
        IF IdList(1) IS NULL THEN
            RETURN 'ERROR';
        END IF;
        Clause := ' and ' || ColumnName || ' = ' || IdList(1);
    ELSE
        l_AddComma := FALSE;
        Clause := ' and ' || ColumnName || ' IN (';
        FOR I IN IdList.first..IdList.last
        LOOP
            IF IdList(I) IS NULL THEN
                RETURN 'ERROR';
            END IF;
            IF l_AddComma THEN
                Clause := Clause || ', ';
            ELSE
                l_AddComma := TRUE;
            END IF;
            Clause := Clause || IdList(I);
        END LOOP;
        Clause := Clause || ')';
    END IF;
    RETURN 'OK';
END MakeSubClause;

-- =============================================================
-- Desc: Overload make sub clause.
--
-- Input:
--       ColumnName1         Column name.
--       ColumnName2         Column name.
--       IdPairList          List id pairs.
--
-- Output: The possible return statuses are:
--          OK
--          ERROR1
--          ERROR2
-- =============================================================
FUNCTION MakeSubClause(
        Clause               OUT NOCOPY VARCHAR2,
        ColumnName1          IN         VARCHAR2,
        ColumnName2          IN         VARCHAR2,
        IdPairList           IN         MscCustZoneTbl
) RETURN VARCHAR2 AS
l_AddOr           BOOLEAN;
l_Clause          VARCHAR2(1024);
BEGIN
    IF IdPairList.COUNT = 1 THEN
        IF IdPairList(1).CustomerId IS NULL OR IdPairList(1).ZoneId IS NULL THEN
            RETURN 'ERROR';
        END IF;
        Clause := ' and ' || ColumnName1 || ' = ' || IdPairList(1).CustomerId;
        Clause := Clause || ' and ' || ColumnName2 || ' = ' || IdPairList(1).ZoneId;
    ELSE
        l_AddOr := FALSE;
        Clause := ' and ( ';
        FOR I IN IdPairList.first..IdPairList.last
        LOOP
            IF IdPairList(I).CustomerId IS NULL OR IdPairList(I).ZoneId IS NULL THEN
                RETURN 'ERROR';
            END IF;
            IF l_AddOr THEN
                Clause := Clause || ' or ';
            ELSE
                l_AddOr := TRUE;
            END IF;
            Clause := Clause || '( (' || ColumnName1 || ' = ' || IdPairList(I).CustomerId || ' ) and ( ' ||
                      ColumnName1 || ' = ' || IdPairList(I).ZoneId || ') )';
        END LOOP;
        Clause := Clause || ')';
    END IF;
    RETURN 'OK';
END MakeSubClause;

-- =============================================================
-- Desc: Overload make sub clause.
--
-- Input:
--       ColumnName          Column name.
--       IdList              List ids.
--
-- Output: The possible return statuses are:
--          OK
--          ERROR
-- =============================================================
FUNCTION MakeSubClause(
        Clause               OUT NOCOPY VARCHAR2,
        ColumnName           IN         VARCHAR2,
        IdList               IN         MscChar255Arr
) RETURN VARCHAR2 AS
l_AddComma        BOOLEAN;
BEGIN
    IF IdList.COUNT = 1 THEN
        IF IdList(1) IS NULL THEN
            RETURN 'ERROR';
        END IF;
        Clause := ' and ' || ColumnName || ' = ' || IdList(1);
    ELSE
        l_AddComma := FALSE;
        Clause := ' and ' || ColumnName || ' IN (';
        FOR I IN IdList.first..IdList.last
        LOOP
            IF IdList(I) IS NULL THEN
                RETURN 'ERROR';
            END IF;
            IF l_AddComma THEN
                Clause := Clause || ', ';
            ELSE
                l_AddComma := TRUE;
            END IF;
            Clause := Clause || '''' || IdList(I) || '''';
        END LOOP;
        Clause := Clause || ')';
    END IF;
    RETURN 'OK';
END MakeSubClause;

-- =============================================================
-- Desc: make where clause for item output level.
--
-- Input:
--       ItemIdList          List of item ids.
--       ProductFamilyIdList List of product family ids.
--
-- Output: The possible return statuses are:
--          OK
--          BOTH_ITEM_AND_PRODUCT_FAMILY
--          INVALID_ITEM_ID
--          INVALID_PRODUCT_FAMILY_ID
-- =============================================================
FUNCTION GetItemClause(
        Clause               OUT NOCOPY VARCHAR2,
        ItemIdList           IN         MscNumberArr,
        ProductFamilyIdList  IN         MscNumberArr
) RETURN VARCHAR2 AS
l_String            VARCHAR2(100);
BEGIN
    -- If any item or product family id is specified, make sure it is consistantent
    -- with the the rules for output levels.
    IF ItemIdList IS NOT NULL AND ItemIdList.COUNT > 0 AND
       ProductFamilyIdList IS NOT NULL AND ProductFamilyIdList.COUNT > 0 THEN
        RETURN 'BOTH_ITEM_AND_PRODUCT_FAMILY';
    END IF;

    IF ItemIdList IS NOT NULL AND ItemIdList.COUNT > 0 THEN
        l_string := MakeSubClause(Clause, 'inventory_item_id', ItemIdList);
        IF (l_String <> 'OK') THEN
            RETURN 'INVALID_ITEM_ID';
        END IF;
    ELSIF ProductFamilyIdList IS NOT NULL AND ProductFamilyIdList.COUNT > 0 THEN
        l_string := MakeSubClause(Clause, 'inventory_item_id', ProductFamilyIdList);
        IF (l_String <> 'OK') THEN
            RETURN 'INVALID_PRODUCT_FAMILY_ID';
        END IF;
    ELSE
        Clause := ''; -- both lists are null.
    END IF;

    RETURN 'OK';
END GetItemClause;

-- =============================================================
-- Desc: make where clause for customer output level.
--
-- Input:
--       ScenarioId        Scenario id.
--       ForecastData      the demand forecast.
--       OrganizationId    Organization id.
--       SrItemId          Source item id.
--
-- Output: The possible return statuses are:
--          OK
--          INVALID_SHIP_TO_LOCATION_ID
--          MULTIPLE_CUSTOMER_LEVEL_DATA
--          INVALID_SR_CUSTOMER_ID
--          INVALID_SR_ZONE_ID
-- =============================================================
FUNCTION GetCustomerClause(
        Clause              OUT NOCOPY VARCHAR2,
        ShipToLocIdList     IN         MscNumberArr,
        CustomerIdList      IN         MscNumberArr,
        CustZonePairList    IN         MscCustZoneTbl,
        ZoneIdList          IN         MscNumberArr
) RETURN VARCHAR2 AS
l_HasCustomer       BOOLEAN;
l_String            VARCHAR2(100);
BEGIN
    -- If any customer data related is specified,  make sure it is consistantent
    -- with the the rules for Customer output levels.

    l_HasCustomer := FALSE;
    Clause := '';
    IF ShipToLocIdList IS NOT NULL AND ShipToLocIdList.COUNT > 0 THEN
        l_string := MakeSubClause(Clause, 'sr_ship_to_loc_id', ShipToLocIdList);
        IF (l_String <> 'OK') THEN
            RETURN 'INVALID_SHIP_TO_LOCATION_ID';
        END IF;
        l_HasCustomer := TRUE;
    END IF;

    IF CustomerIdList IS NOT NULL AND CustomerIdList.COUNT > 0 THEN
        IF l_HasCustomer THEN
            return 'MULTIPLE_CUSTOMER_LEVEL';
        ELSE
            l_string := MakeSubClause(Clause, 'sr_customer_id', CustomerIdList);
            IF (l_String <> 'OK') THEN
                RETURN 'INVALID_SR_CUSTOMER_ID';
            END IF;
        l_HasCustomer := TRUE;
        END IF;
    END IF;

    IF CustZonePairList IS NOT NULL AND CustZonePairList.COUNT > 0 THEN
        IF l_HasCustomer THEN
            return 'MULTIPLE_CUSTOMER_LEVEL';
        ELSE
            l_string := MakeSubClause(Clause, 'sr_customer_id', 'sr_zone_id', CustZonePairList);
            IF (l_String <> 'OK') THEN
                IF l_String = 'ERROR1' THEN
                    RETURN 'INVALID_SR_CUSTOMER_ID';
                ELSE
                    RETURN 'INVALID_SR_ZONE_ID';
                END IF;
            END IF;
            l_HasCustomer := TRUE;
        END IF;
    END IF;

    IF ZoneIdList IS NOT NULL AND ZoneIdList.COUNT > 0 THEN
        IF l_HasCustomer THEN
            return 'MULTIPLE_CUSTOMER_LEVEL';
        ELSE
            l_string := MakeSubClause(Clause, 'sr_zone_id', ZoneIdList);
            IF (l_String <> 'OK') THEN
                RETURN 'INVALID_SR_ZONE_ID';
            END IF;
            l_HasCustomer := TRUE;
        END IF;
    END IF;

    RETURN 'OK';
END GetCustomerClause;

-- =============================================================
-- Desc: make where clause for start date and end date.
--
-- Input:
--       StartDate         Start date, time is ignored.
--       EndDate           End date, time is ignored.
--
-- Output: The possible return statuses are:
--          OK
--          INVALID_START_END_DATE
-- =============================================================
FUNCTION GetStartEndDateClause(
        Clause              OUT NOCOPY VARCHAR2,
        StartDate           IN         DATE,
        EndDate             IN         DATE
)RETURN VARCHAR2 AS
BEGIN
    IF StartDate IS NOT NULL AND EndDate IS NOT NULL AND EndDate < StartDate THEN
        RETURN 'INVALID_START_END_DATE';
    END IF;

    Clause := '';
    IF StartDate IS NOT NULL THEN
        Clause := ' and start_time >= to_date(''' || to_char(StartDate,'yyyy-mm-dd') || ''',''yyyy-mm-dd'')';
    END IF;

    IF EndDate IS NOT NULL THEN
        Clause := Clause || ' and end_time <= to_date(''' || to_char(EndDate,'yyyy-mm-dd') || ''',''yyyy-mm-dd'')';
    END IF;

    RETURN 'OK';
END GetStartEndDateClause;

-- =============================================================
-- Desc: build the select statement and query the data.
--
-- Input:
--       WhereClause       where clause.
--
-- Output: No output.
-- =============================================================
PROCEDURE QueryForecasts(
        ForecastTbl         OUT NOCOPY MscForecastTbl,
        WhereClause         IN         VARCHAR2
) AS
TYPE FCSTCurType IS REF CURSOR;
fcst_cursor FCSTCurType;

l_Sql                   VARCHAR2(2048);
l_BucketType            NUMBER;
l_StartDate             DATE;
l_EndDate               DATE;
l_Quantity              NUMBER;
l_SrOrganizationId      NUMBER;
l_SrInstanceId          NUMBER;
l_ErrorType             VARCHAR2(30);
l_ForecastError         NUMBER;
l_ItemId                NUMBER;
l_ShipToLocation        NUMBER;
l_SrCustomerId          NUMBER;
l_SrZoneId              NUMBER;
l_Priority              NUMBER;
l_Uom                   VARCHAR2(10);
l_DemandClass           VARCHAR2(240);
l_UnitPrice             NUMBER;
BEGIN
    ForecastTbl := MscForecastTbl();
    l_Sql := 'SELECT '                                                         ||
                  'nvl(bucket_type, -23453), '                                 ||
                  'nvl(start_time, to_date(''1970-01-01'', ''YYYY-MM-DD'')), ' ||
                  'nvl(end_time, to_date(''1970-01-01'', ''YYYY-MM-DD'')), '   ||
                  'nvl(quantity, -23453), '                                    ||
                  'sr_organization_id, '                                       ||
                  'nvl(sr_instance_id, -23453), '                              ||
                  'error_type, '                                               ||
                  'forecast_error, '                                           ||
                  'nvl(inventory_item_id, -23453), '                           ||
                  'sr_ship_to_loc_id, '                                        ||
                  'sr_customer_id, '                                           ||
                  'sr_zone_id, '                                               ||
                  'nvl(priority, -23453), '                                    ||
                  'nvl(ascp_uom_code, ''''), '                                 ||
                  'demand_class, '                                             ||
                  'nvl(unit_price, -23453) '                                   ||
             'FROM msd_dp_scn_entries_denorm '                                 ||
             'WHERE '                                                          ||
                 WhereClause;


    OPEN fcst_cursor FOR l_Sql;
    LOOP
        FETCH fcst_cursor
        INTO
            l_BucketType,
            l_StartDate,
            l_EndDate,
            l_Quantity,
            l_SrOrganizationId,
            l_SrInstanceId,
            l_ErrorType,
            l_ForecastError,
            l_ItemId,
            l_ShipToLocation,
            l_SrCustomerId,
            l_SrZoneId,
            l_Priority,
            l_Uom,
            l_DemandClass,
            l_UnitPrice;
        EXIT WHEN fcst_cursor%NOTFOUND;

        ForecastTbl.extend;
        ForecastTbl(ForecastTbl.count) :=
                MscForecastRec(
                    l_BucketType,
                    l_StartDate,
                    l_EndDate,
                    l_Quantity,
                    l_SrOrganizationId,
                    l_SrInstanceId,
                    l_ErrorType,
                    l_ForecastError,
                    l_ItemId,
                    l_ShipToLocation,
                    l_SrCustomerId,
                    l_SrZoneId,
                    l_Priority,
                    l_Uom,
                    l_DemandClass,
                    l_UnitPrice,
                    '');
    END LOOP;
    CLOSE fcst_cursor;
END QueryForecasts;

-- =============================================================
-- Desc: Get plan id.
--
-- Input:
--       PlanName          Plan name.
--       OwningOrgId       Owning organization id
--       SrInstanceId      Source instance id.
--
-- Output: The possible return statuses are:
--          OK
--          FAILED_TO_QUERY_PLAN_ID
-- =============================================================
FUNCTION GetPlanId(
        PlanId             OUT NOCOPY NUMBER,
        PlanName           IN         VARCHAR2,
        OwningOrgId        IN         NUMBER,
        SrInstanceId       IN         NUMBER
) RETURN VARCHAR2 AS
l_Count             NUMBER;
BEGIN
    BEGIN
        SELECT plan_id
        INTO PlanId
        FROM msc_plans
        WHERE
            organization_id = OwningOrgId AND
            compile_designator = PlanName AND
            sr_instance_id = SrInstanceId;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RETURN 'FAILED_TO_QUERY_PLAN_ID';
            WHEN others THEN
                g_ErrorCode := 'ERROR_UNEXPECTED_02031';
                raise;
    END;
    RETURN 'OK';
END GetPlanId;


-- =============================================================
-- Desc: Check if the plan contains this org organization.
--
-- Input:
--       PlanId            Plan Id.
--       OrgId             Organization Id.
--       SrInstId          Source instance id
--
-- Output: The possible return statuses are:
--         OK
--         INVALID_ORGID
-- =============================================================
FUNCTION ValidateOrgId(
        PlanId             IN         NUMBER,
        OrgId              IN         NUMBER,
        SrInstId           IN         NUMBER
) RETURN VARCHAR2 AS
l_Dummy             NUMBER;
BEGIN
    BEGIN
        SELECT 1 INTO l_Dummy
        FROM
            msc_plan_organizations
        WHERE
            plan_id = PlanId AND
            organization_id = OrgId AND
            sr_instance_id = SrInstId;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            RETURN 'INVALID_ORGID';
        WHEN others THEN
            raise;
    END;

    RETURN 'OK';
END ValidateOrgId;

-- =============================================================
-- Desc: check item id.
--
-- Input:
--       PlanId            Plan id.
--       SrInsId           Source instance id.
--       OrgId             Organization id.
--       ItemId            Item id
--
-- Output: The possible return statuses are:
--          OK
--          INVALID_ITEM_ID
-- =============================================================
FUNCTION ValidateItemId(
        PlanId             IN         NUMBER,
        SrInstId           IN         NUMBER,
        OrgId              IN         NUMBER,
        ItemId             IN         NUMBER
) RETURN VARCHAR2 AS
l_Dummy             NUMBER;
BEGIN
    BEGIN
        SELECT 1 INTO l_Dummy
        FROM msc_system_items
        WHERE
            plan_id = planId AND
            sr_instance_id = SrInstId AND
            organization_id = OrgId AND
            inventory_item_id = ItemId;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RETURN 'INVALID_ITEM_ID';
                WHEN others THEN
                    g_ErrorCode := 'ERROR_UNEXPECTED_02033';
                    raise;
    END;
    RETURN 'OK';
END ValidateItemId;

-- =============================================================
-- Desc: check period start date.
--
-- Input:
--       PlanId            Plan id.
--       OrgId             Organization id.
--       SrInsId           Source instance id.
--       PeriodStartDate   Period start date.
--
-- Output: The possible return statuses are:
--          OK
--          INVALID_PERIOD_START_DATE
-- =============================================================
FUNCTION ValidatePeriodStartDate(
        PlanId             IN         NUMBER,
        OrgId              IN         NUMBER,
        SrInstId           IN         NUMBER,
        PeriodStartDate    IN         DATE
) RETURN VARCHAR2 AS
l_Dummy             NUMBER;
BEGIN
    BEGIN
        SELECT 1 INTO l_Dummy
        FROM msc_plan_buckets
        WHERE
            plan_id = PlanId AND
            organization_id = OrgId AND
            sr_instance_id = SrInstId AND
            curr_flag = 1 AND
            trunc(bkt_start_date) = PeriodStartDate; -- PeriodStartDate is date only in xsd
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RETURN 'INVALID_PERIOD_START_DATE';
                WHEN others THEN
                    g_ErrorCode := 'ERROR_UNEXPECTED_02035';
                    raise;
    END;
    RETURN 'OK';
END ValidatePeriodStartDate;

-- =============================================================
-- Desc: check project id, task id and planning group.
--
-- Input:
--       PlanId            Scenario Id.
--       OrgId             Organization id.
--       SrInstId          Source instance id.
--       ProjectId         Project id.
--       TaskId            Task id.
--       PlanningGroup     Planning group.
--
-- Output: The possible return statuses are:
--          OK
--          INVALID_PROJECT_ID
--          INVALID_TASK_ID
--          INVALID_PLANNING_GROUP
-- =============================================================
FUNCTION ValidateProjectDate(
        PlanId             IN         NUMBER,
        OrgId              IN         NUMBER,
        SrInstId           IN         NUMBER,
        ProjectId          IN         NUMBER,
        TaskId             IN         NUMBER,
        PlanningGroup      IN         VARCHAR2
) RETURN VARCHAR2 AS
l_Dummy             NUMBER;
BEGIN
    IF ProjectId IS NULL THEN
        IF TaskId IS NOT NULL THEN
            RETURN 'INVALID_TASK_ID';
        END IF;
        IF PlanningGroup IS NOT NULL THEN
            RETURN 'INVALID_PLANNING_GROUP';
        END IF;
    ELSE
        BEGIN -- check project id
            SELECT 1 INTO l_Dummy
            FROM msc_projects
            WHERE
                plan_id = PlanId AND
                sr_instance_id = SrInstId AND
                organization_id = OrgId AND
                project_id = ProjectId;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        RETURN 'INVALID_PROJECT_ID';
        END;
        IF TaskId IS NOT NULL THEN
            BEGIN -- check task id
                SELECT 1 INTO l_Dummy
                FROM msc_project_tasks
                WHERE
                    plan_id = PlanId AND
                    sr_instance_id = SrInstId AND
                    organization_id = OrgId AND
                    project_id = ProjectId AND
                    task_id = TaskId;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            RETURN 'INVALID_TASK_ID';
            END;
        END IF;
        IF PlanningGroup IS NOT NULL THEN
            BEGIN -- check planning group
                SELECT 1 INTO l_Dummy
                FROM pjm_project_parameters
                WHERE
                    organization_id = OrgId AND
                    project_id = ProjectId AND
                    planning_group = PlanningGroup;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                             RETURN 'INVALID_PLANNING_GROUP';
            END;
        END IF;
    END IF;

    RETURN 'OK';

    EXCEPTION
        WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_02036';
            raise;
END ValidateProjectDate;

-- =============================================================
-- Desc: insert a safety stock into msc_safety_stocks.
--
-- Input:
--       PlanId            Scenario Id.
--       SafetyStockData   A safety stock.
--
-- Output: No output.
-- =============================================================
PROCEDURE InsertSafetyStock(
        PlanId             IN         NUMBER,
        SafetyStockData    IN         MscSafetyStockRec
) AS
BEGIN
    BEGIN
        INSERT INTO msc_safety_stocks
            (
            plan_id, organization_id, sr_instance_id, inventory_item_id,
            period_start_date, safety_stock_quantity,
            last_update_date, last_updated_by, creation_date, created_by,
            target_safety_stock,
            project_id, task_id, planning_group,
            user_defined_safety_stocks, user_defined_dos,
            target_days_of_supply, achieved_days_of_supply,
            demand_var_ss_percent, mfg_ltvar_ss_percent,
            transit_ltvar_ss_percent, sup_ltvar_ss_percent,
            total_unpooled_safety_stock
            )
        VALUES
            (
            PlanId, SafetyStockData.OrganizationId, SafetyStockData.SrInstanceId, SafetyStockData.ItemId,
            SafetyStockData.PeriodStartDate, SafetyStockData.SafetyStockQty,
            sysdate, g_UserId, sysdate, g_UserId,
            SafetyStockData.TargetSafetyStock,
            SafetyStockData.ProjectId, SafetyStockData.TaskId, SafetyStockData.PlanningGroup,
            SafetyStockData.UserDefinedSafetyStock, SafetyStockData.UserDefinedDOS,
            SafetyStockData.TargetDOS, SafetyStockData.AchievedDOS,
            SafetyStockData.DemandVarSSPct, SafetyStockData.MfgLTVarSSPct,
            SafetyStockData.TransitLTVarSSPct, SafetyStockData.SupLTVarSSPct,
            SafetyStockData.TotalUnpooledSS
            ) ;
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                UpdateSafetyStock(PlanId, SafetyStockData);
            WHEN others THEN
                g_ErrorCode := 'ERROR_UNEXPECTED_02037';
                raise;
    END;

END InsertSafetyStock;

-- =============================================================
-- Desc: update a safety stock in msc_safety_stocks.
--
-- Input:
--       PlanId            Scenario Id.
--       SafetyStockData   A safety stock.
--
-- Output: No output.
-- =============================================================
PROCEDURE UpdateSafetyStock(
        PlanId             IN         NUMBER,
        SafetyStockData    IN         MscSafetyStockRec
) AS
BEGIN
    UPDATE msc_safety_stocks
    SET
        safety_stock_quantity       = SafetyStockData.SafetyStockQty,
        last_update_date            = sysdate,
        last_updated_by             = g_UserId,
        target_safety_stock         = SafetyStockData.TargetSafetyStock,
        user_defined_safety_stocks  = SafetyStockData.UserDefinedSafetyStock,
        user_defined_dos            = SafetyStockData.UserDefinedDOS,
        target_days_of_supply       = SafetyStockData.TargetDOS,
        achieved_days_of_supply     = SafetyStockData.AchievedDOS,
        demand_var_ss_percent       = SafetyStockData.DemandVarSSPct,
        mfg_ltvar_ss_percent        = SafetyStockData.MfgLTVarSSPct,
        transit_ltvar_ss_percent    = SafetyStockData.TransitLTVarSSPct,
        sup_ltvar_ss_percent        = SafetyStockData.SupLTVarSSPct,
        total_unpooled_safety_stock = SafetyStockData.TotalUnpooledSS
    WHERE
        plan_id                     = PlanId                                 AND
        organization_id             = SafetyStockData.OrganizationId         AND
        sr_instance_id              = SafetyStockData.SrInstanceId           AND
        inventory_item_id           = SafetyStockData.ItemId                 AND
        period_start_date           = SafetyStockData.PeriodStartDate        AND
        nvl(project_id, -1)         = nvl(SafetyStockData.ProjectId, -1)     AND
        nvl(task_id, -1)            = nvl(SafetyStockData.TaskId, -1)        AND
        nvl(planning_group, -1)     = nvl(SafetyStockData.PlanningGroup, -1) AND
        unit_number IS NULL;
    EXCEPTION
        WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_02038';
            raise;
END UpdateSafetyStock;

-- =============================================================
-- Desc: Process a safety stock.
--
-- Input:
--       PlanId            Scenario Id.
--       OwningOrgId       Plan owning org id.
--       SrInstId          Source instance id.
--       SafetyStockData   A safety stock.
--
-- Output: The possible return statuses are:
--          OK
--          INVALID_ORGANIZATION_ID
--          INVALID_PERIOD_START_DATE
--          INVALID_SS_QTY
--          INVALID_TARGET_SS_QTY
--          INVALID_PROJECT_ID
--          INVALID_TASK_ID
--          INVALID_PLANNING_GROUP
--          INVALID_USER_DEFINED_SS
--          INVALID_USER_DEFINED_DOS
--          INVALID_TARGET_DOS
--          INVALID_ACHIEVED_DOS
--          INVALID_DEMAND_VAR_SS_PERCENT
--          INVALID_MFG_LTVAR_SS_PERCENT
--          INVALID_TRANSIT_LTVAR_SS_PERCENT
--          INVALID_SUP_LTVAR_SS_PERCENT
--          INVALID_TOTAL_UNPOOLED_SS
-- =============================================================
FUNCTION ProcessSafetyStock(
        PlanId             IN         NUMBER,
        OwningOrgId        IN         NUMBER,
        SrInstId           IN         NUMBER,
        SafetyStockData    IN         MscSafetyStockRec
) RETURN VARCHAR2 AS
l_String            VARCHAR2(100);
BEGIN
    -- check organization id
    BEGIN
        l_string := ValidateOrgId(PlanId, SafetyStockData.OrganizationId, SafetyStockData.SrInstanceId);
        IF (l_string <> 'OK') THEN
            -- overwrite the error token here.
            RETURN 'INVALID_ORGANIZATION_ID';
        END IF;
        EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_02032';
            raise;
    END;

    -- No need to check SrInstanceId. GetPlanId should catch this.
    -- check item id
    l_string := ValidateItemId(PlanId, SafetyStockData.SrInstanceId, SafetyStockData.OrganizationId, SafetyStockData.ItemId);
    IF (l_String <> 'OK') THEN
        RETURN l_String;
    END IF;

    -- check period start date
    l_string := ValidatePeriodStartDate(PlanId, OwningOrgId, SrInstId, SafetyStockData.PeriodStartDate);
    IF (l_String <> 'OK') THEN
        RETURN l_String;
    END IF;

    -- check safety stock quantity
    IF SafetyStockData.SafetyStockQty < 0 THEN
        RETURN 'INVALID_SS_QTY';
    END IF;

    -- check target safety stock quantity
    IF SafetyStockData.TargetSafetyStock IS NOT NULL AND SafetyStockData.TargetSafetyStock < SafetyStockData.SafetyStockQty THEN
        RETURN 'INVALID_TARGET_SS_QTY';
    END IF;

    -- check project id, task id and planning group
    l_string := ValidateProjectDate(PlanId, OwningOrgId, SrInstId, SafetyStockData.ProjectId, SafetyStockData.TaskId, SafetyStockData.PlanningGroup);
    IF (l_String <> 'OK') THEN
        RETURN l_String;
    END IF;

    -- check user defined safety stock
    IF SafetyStockData.UserDefinedSafetyStock IS NOT NULL AND SafetyStockData.UserDefinedSafetyStock < 0 THEN
        RETURN 'INVALID_USER_DEFINED_SS';
    END IF;

    -- check user defined days of supply
    IF SafetyStockData.UserDefinedDOS IS NOT NULL AND SafetyStockData.UserDefinedDOS < 0 THEN
        RETURN 'INVALID_USER_DEFINED_DOS';
    END IF;

    -- check target days of supply
    IF SafetyStockData.TargetDOS IS NOT NULL AND SafetyStockData.TargetDOS < 0 THEN
        RETURN 'INVALID_TARGET_DOS';
    END IF;

    -- check achieved days of supply
    IF SafetyStockData.AchievedDOS IS NOT NULL AND SafetyStockData.AchievedDOS < 0 THEN
        RETURN 'INVALID_ACHIEVED_DOS';
    END IF;

    -- check percentage of total SS held for demand variability
    IF SafetyStockData.DemandVarSSPct IS NOT NULL AND SafetyStockData.DemandVarSSPct NOT BETWEEN 0 AND 100 THEN
        RETURN 'INVALID_DEMAND_VAR_SS_PERCENT';
    END IF;

    -- check percentage of total SS held for Mfg. Leadtime variability
    IF SafetyStockData.MfgLTVarSSPct IS NOT NULL AND SafetyStockData.MfgLTVarSSPct NOT BETWEEN 0 AND 100 THEN
        RETURN 'INVALID_MFG_LTVAR_SS_PERCENT';
    END IF;

    -- check percentage of total SS held for Transit Leadtime variability
    IF SafetyStockData.MfgLTVarSSPct IS NOT NULL AND SafetyStockData.MfgLTVarSSPct NOT BETWEEN 0 AND 100 THEN
        RETURN 'INVALID_TRANSIT_LTVAR_SS_PERCENT';
    END IF;

    -- check percentage of total SS held for Supplier Leadtime variability
    IF SafetyStockData.SupLTVarSSPct IS NOT NULL AND SafetyStockData.SupLTVarSSPct NOT BETWEEN 0 AND 100 THEN
        RETURN 'INVALID_SUP_LTVAR_SS_PERCENT';
    END IF;

    -- check Unpooled Sum of Safety Stocks for all Uncertainity forms
    IF SafetyStockData.TotalUnpooledSS IS NOT NULL AND SafetyStockData.TotalUnpooledSS < 0 THEN
        RETURN 'INVALID_TOTAL_UNPOOLED_SS';
    END IF;

    -- All parametera pass the validation, insert/update the safety
    -- stock into msc_safety_stocks table.
    InsertSafetyStock(PlanId, SafetyStockData);

    RETURN 'OK';

    EXCEPTION
        WHEN others THEN
            RETURN g_ErrorCode;

END ProcessSafetyStock;

-- =============================================================
-- Desc: build the select statement and query the data.
--
-- Input:
--       WhereClause       where clause.
--
-- Output: No output.
-- =============================================================
PROCEDURE QuerySafetyStocks(
        SafetyStockTbl      OUT NOCOPY MscSafetyStockTbl,
        WhereClause         IN         VARCHAR2
) AS
TYPE SSCurType IS REF CURSOR;
ss_cursor SSCurType;

l_Sql                       VARCHAR2(2048);
l_OrganizationId            NUMBER;
l_SrInstanceId              NUMBER;
l_ItemId                    NUMBER;
l_PeriodStartDate           DATE;
l_SafetyStockQty            NUMBER;
l_TargetSafetyStock         NUMBER;
l_ProjectId                 NUMBER;
l_TaskId                    NUMBER;
l_PlanningGroup             VARCHAR2(30);
l_UserDefinedSafetyStock    NUMBER;
l_UserDefinedDOS            NUMBER;
l_TargetDOS                 NUMBER;
l_AchievedDOS               NUMBER;
l_DemandVarSSPct            NUMBER;
l_MfgLTVarSSPct             NUMBER;
l_TransitLTVarSSPct         NUMBER;
l_SupLTVarSSPct             NUMBER;
l_TotalUnpooledSS           NUMBER;
BEGIN
    SafetyStockTbl := MscSafetyStockTbl();
    l_Sql := 'SELECT '                            ||
                  'organization_id, '             ||
                  'sr_instance_id, '              ||
                  'inventory_item_id, '           ||
                  'period_start_date, '           ||
                  'safety_stock_quantity, '       ||
                  'target_safety_stock, '         ||
                  'project_id, '                  ||
                  'task_id, '                     ||
                  'planning_group, '              ||
                  'user_defined_safety_stocks, '  ||
                  'user_defined_dos, '            ||
                  'target_days_of_supply, '       ||
                  'achieved_days_of_supply, '     ||
                  'demand_var_ss_percent, '       ||
                  'mfg_ltvar_ss_percent, '        ||
                  'transit_ltvar_ss_percent, '    ||
                  'sup_ltvar_ss_percent, '        ||
                  'total_unpooled_safety_stock '  ||
             'FROM msc_safety_stocks '            ||
             'WHERE '                             ||
                 WhereClause;

/*
sample where clause
plan_id = 204934 and inventory_item_id IN (10, 11, 12) and organization_id IN (201, 207, 201)
*/
    OPEN ss_cursor FOR l_Sql;
    LOOP
        FETCH ss_cursor
        INTO
            l_OrganizationId,
            l_SrInstanceId,
            l_ItemId,
            l_PeriodStartDate,
            l_SafetyStockQty,
            l_TargetSafetyStock,
            l_ProjectId,
            l_TaskId,
            l_PlanningGroup,
            l_UserDefinedSafetyStock,
            l_UserDefinedDOS,
            l_TargetDOS,
            l_AchievedDOS,
            l_DemandVarSSPct,
            l_MfgLTVarSSPct,
            l_TransitLTVarSSPct,
            l_SupLTVarSSPct,
            l_TotalUnpooledSS;
        EXIT WHEN ss_cursor%NOTFOUND;

        SafetyStockTbl.extend;
        SafetyStockTbl(SafetyStockTbl.count) :=
                MscSafetyStockRec(
                    l_OrganizationId,
                    l_SrInstanceId,
                    l_ItemId,
                    l_PeriodStartDate,
                    l_SafetyStockQty,
                    l_TargetSafetyStock,
                    l_ProjectId,
                    l_TaskId,
                    l_PlanningGroup,
                    l_UserDefinedSafetyStock,
                    l_UserDefinedDOS,
                    l_TargetDOS,
                    l_AchievedDOS,
                    l_DemandVarSSPct,
                    l_MfgLTVarSSPct,
                    l_TransitLTVarSSPct,
                    l_SupLTVarSSPct,
                    l_TotalUnpooledSS,
                    '');
    END LOOP;
    CLOSE ss_cursor;
END QuerySafetyStocks;


-- =============================================================
-- Desc: Check plan type, we only support ASCP for now.
--
-- Input:
--       PlanId            Scenario Id.
--
-- Output: The possible return statuses are:
--          OK
--          INVALID_PLAN_TYPE
-- =============================================================
FUNCTION ValidatePlanType(PlanId IN NUMBER) RETURN VARCHAR2 AS
l_Dummy             NUMBER;
BEGIN
    BEGIN
        SELECT 1 INTO l_Dummy
        FROM msc_plans
        WHERE
            curr_plan_type IN (1, 2, 3) AND
            plan_id = PlanId;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            RETURN 'INVALID_PLAN_TYPE';
        WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_02050';
            raise;
    END;

    RETURN 'OK';
END ValidatePlanType;


-- =============================================================
-- Desc: Insert planned supply into msc_supplies table.
--
-- Input:
--       PlanId            Plan id.
--       SrInstId          Source instance id.
--       PlannedSupplyData The planned supply.
--
-- Output: No output.
-- =============================================================
PROCEDURE InsertPlannedSupply(
        PlanId              IN         NUMBER,
        SrInstId            IN         NUMBER,
        PlannedSupplyData   IN         MscPlannedSupplyRec
) AS
l_TransactionId     NUMBER;
BEGIN
    -- generate an unique demand id
    SELECT msc_supplies_s.nextval INTO l_TransactionId FROM DUAL;

    -- insert data
    INSERT INTO msc_supplies
        (
        plan_id, transaction_id, organization_id,
        sr_instance_id, inventory_item_id, new_schedule_date,
        disposition_status_type, order_type, new_order_quantity,
        quantity_in_process, firm_planned_type, firm_quantity,
        firm_date, implement_firm, new_dock_date,
        status, applied,
        last_update_date, last_updated_by, creation_date, created_by
        )
    VALUES
        (
        PlanId, l_TransactionId, PlannedSupplyData.OrganizationId,
        SrInstId, PlannedSupplyData.ItemId, PlannedSupplyData.FirmDate,
        1, 5, 0,
        0, 1, PlannedSupplyData.Quantity,
        PlannedSupplyData.FirmDate, 2, PlannedSupplyData.FirmDate,
        0, 2,
        sysdate, g_UserId, sysdate, g_UserId
        );
    EXCEPTION WHEN others THEN
        g_ErrorCode := 'ERROR_UNEXPECTED_02054';
        raise;
END InsertPlannedSupply;

-- =============================================================
-- Desc: Process a planned supply.
--
-- Input:
--       PlanId            Scenario Id.
--       SrInstanceId      Source instance id.
--       PlannedSupplyData A planned supply.
--
-- Output: The possible return statuses are:
--          OK
--          INVALID_ORGANIZATION_ID
--          INVALID_ITEM_ID
--          INVALID_QUANTITY
-- =============================================================
FUNCTION ProcessPlannedSupply(
        PlanId             IN         NUMBER,
        SrInstanceId       IN         NUMBER,
        PlannedSupplyData  IN         MscPlannedSupplyRec
) RETURN VARCHAR2 AS
l_String            VARCHAR2(100);
BEGIN
    -- check organization id
    BEGIN
        l_string := ValidateOrgId(PlanId, PlannedSupplyData.OrganizationId, SrInstanceId);
        IF (l_string <> 'OK') THEN
            -- overwrite the error token here.
            RETURN 'INVALID_ORGANIZATION_ID';
        END IF;
        EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_02052';
            raise;
    END;

    -- check item id
    BEGIN
        l_string := ValidateItemId(PlanId, SrInstanceId, PlannedSupplyData.OrganizationId, PlannedSupplyData.ItemId);
        IF (l_String <> 'OK') THEN
            RETURN l_String;
        END IF;
        EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_02053';
            raise;
    END;

    -- check quantity
    IF PlannedSupplyData.Quantity <= 0 THEN
        RETURN 'INVALID_QUANTITY';
    END IF;

    -- All parametera pass the validation, insert/update the planned
    -- supply into msc_supplies table.
    InsertPlannedSupply(PlanId, SrInstanceId, PlannedSupplyData);

    RETURN 'OK';

    EXCEPTION
        WHEN others THEN
            RETURN g_ErrorCode;

END ProcessPlannedSupply;

-- =============================================================
--
-- Public functions for APS Data Services.
--
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
--        ScenarioName       Scenario Name, its is used to retrieve the scenario_id.
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
        ) AS
l_String            VARCHAR2(100);
l_ResponsibilityId  NUMBER;
l_SecurityGroupId   NUMBER;
l_ScenarioId        NUMBER;
l_IsNewScenario     BOOLEAN;
l_GoodRecCount      NUMBER;
l_BadRecCount       NUMBER;
l_BadData           MscForecastRec;
BEGIN
    -- init global variables
    g_DemandId            := 0;
    g_DummyDemandPlanId   := 5555555;
    g_DummyDemandPlanName := 'Default';
    g_ErrorCode           := '';

    -- init bad record table
    BadRecTbl := MscForecastTbl();

    -- query user id, responsibility id and security group id
    MSC_WS_COMMON.GET_PERMISSION_IDS(l_String, g_UserId, l_ResponsibilityId, l_SecurityGroupId, UserName, RespName, RespAppName, SecurityGroupName, Language);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;

    MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, g_UserId, l_ResponsibilityId, 'MSC_FNDRSRUN_LEG_COLL',l_SecurityGroupId);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;

    -- check any demand forecast data is available
    IF ForecastTbl IS NULL OR ForecastTbl.count <= 0 THEN
        Status := 'NO_DATA';
        RETURN;
    END IF;

    -- Don't need to check output levels, they're restricted by xsd
    -- ItemOutputLevel, OrganizationOutputLevel, CustomerOutputLevel and DemandClassOutputLevel

    -- query scenario id from ScenarioName
    l_IsNewScenario := FALSE;
    l_string := GetScenarioId(l_ScenarioId, g_DummyDemandPlanId, ScenarioName);
    IF (l_String <> 'OK') THEN
        IF l_String = 'INVALID_SCENARIO_NAME' THEN
            l_IsNewScenario := TRUE;
        ELSE
            Status := l_String;
            RETURN;
        END IF;
    END IF;

    -- if PurgeAllFlag is set, purge all rows in msd_dp_scn_entries_denorm
    -- and msd_dp_scenario_output_levels for l_ScenarioId, if it is there.
    IF MSC_WS_COMMON.BOOL_TO_NUMBER(PurgeAllFlag) = MSC_UTIL.SYS_YES THEN
        IF l_IsNewScenario THEN
            CreateNewScenario(l_ScenarioId, ScenarioName);
        ELSE
            PurgeAllFcstData(l_ScenarioId);
        END IF;
        InsertOutputLevels(l_ScenarioId, ItemOutputLevel, OrganizationOutputLevel, CustomerOutputLevel, DemandClassOutputLevel);
    ELSE
        IF l_IsNewScenario THEN
            CreateNewScenario(l_ScenarioId, ScenarioName);
            InsertOutputLevels(l_ScenarioId, ItemOutputLevel, OrganizationOutputLevel, CustomerOutputLevel, DemandClassOutputLevel);
        ELSE
            -- check consistency of output level parameters against
            -- those outpul levels in msd_dp_scenario_output_levels
            l_string := ValidateOutputLevels(l_ScenarioId, ItemOutputLevel, OrganizationOutputLevel, CustomerOutputLevel, DemandClassOutputLevel);
            IF (l_String <> 'OK') THEN
                Status := l_String;
                RETURN;
            END IF;
        END IF;
    END IF;

    -- process forecast data
    l_GoodRecCount := 0;
    l_BadRecCount := 0;
    FOR I IN ForecastTbl.first..ForecastTbl.last
    LOOP
        l_string := ProcessForecast(l_ScenarioId,
                                    ItemOutputLevel, OrganizationOutputLevel, CustomerOutputLevel, DemandClassOutputLevel,
                                    ForecastTbl(I)
                                   );
        IF (l_string <> 'OK') THEN
            -- ForecastTbl(I).ErrorStatus := l_string;
            l_BadData := ForecastTbl(I);
            l_BadData.ErrorStatus := l_string;
            -- BadRecTbl(BadRecTbl.COUNT + 1) := l_BadData; crash
            BadRecTbl.extend;
            BadRecTbl(BadRecTbl.COUNT) := l_BadData;
            l_BadRecCount := l_BadRecCount + 1;
        ELSE
            l_GoodRecCount := l_GoodRecCount + 1;
        END IF;
    END LOOP;

    IF l_BadRecCount = 0 THEN
        Status := 'SUCCESS';
    ELSIF l_GoodRecCount > 0 THEN
        Status := 'COMPLETED_WITH_ERROR';
    ELSE
        -- if all forecast data are bad, roll back
        Status := 'FAILED';
        rollback;
        RETURN;
    END IF;

    -- insert the dummy record in msd_demand_plans, we need
    -- this in order to see the scenarios that are created
    -- by us in LOV of Plan Option form.
    BEGIN
        INSERT INTO msd_demand_plans
            (
            demand_plan_id, organization_id, sr_instance_id, demand_plan_name, use_org_specific_bom_flag,
            last_update_date, last_updated_by, creation_date, created_by
            )
        VALUES
            (
            g_DummyDemandPlanId, -23453, -23453, g_DummyDemandPlanName, 'N',
            sysdate, g_UserId, sysdate, g_UserId
            ) ;
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                NULL; -- do nothing
            WHEN others THEN
                g_ErrorCode := 'ERROR_UNEXPECTED_02016';
                raise;
    END;
    COMMIT;

    EXCEPTION
        WHEN others THEN
            rollback;
            Status := g_ErrorCode;

END UPLOAD_FORECAST;


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
        ) AS
l_String            VARCHAR2(100);
l_ResponsibilityId  NUMBER;
l_SecurityGroupId   NUMBER;
l_DemandPlanId      NUMBER;
l_WhereClause       VARCHAR2(2048);
l_SubClause         VARCHAR2(1024);
l_ScenarioId        NUMBER;
BEGIN
    -- init global variables
    g_ErrorCode           := '';

    -- init output table
    ForecastTbl := MscForecastTbl();

    -- UnitTest('all MakeSubClause');
    -- /*

    -- query user id, responsibility id and security group id
    MSC_WS_COMMON.GET_PERMISSION_IDS(l_String, g_UserId, l_ResponsibilityId, l_SecurityGroupId, UserName, RespName, RespAppName, SecurityGroupName, Language);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;

    MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, g_UserId, l_ResponsibilityId, 'MSC_FNDRSRUN_LEG_COLL',l_SecurityGroupId);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;

    -- get demand plan id from DemandPlanName
    l_string := GetDemandPlanId(l_DemandPlanId, DemandPlanName);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;

    -- get scenario id from ScenarioName
    l_string := GetScenarioId(l_ScenarioId, l_DemandPlanId, ScenarioName);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;
    l_WhereClause := ' demand_plan_id = ' || l_DemandPlanId || ' and scenario_id = ' || l_ScenarioId;

    -- make where clause for item output level
    l_string := GetItemClause(l_SubClause, ItemIdList, ProductFamilyIdList);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;
    l_WhereClause := l_WhereClause || l_SubClause;

    -- make where clause for organization output level
    IF OrganizationIdList IS NOT NULL AND OrganizationIdList.COUNT > 0 THEN
        l_string := MakeSubClause(l_SubClause, 'sr_organization_id', OrganizationIdList);
        IF (l_String <> 'OK') THEN
            Status := 'INVALID_SR_ORGANIZATION_ID';
            RETURN;
        END IF;
        l_WhereClause := l_WhereClause || l_SubClause;
    END IF;

    -- make where clause for customer output level
    l_string := GetCustomerClause(l_SubClause, ShipToLocIdList, CustomerIdList, CustomerZoneList, ZoneIdList);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;
    l_WhereClause := l_WhereClause || l_SubClause;

    -- make where clause for demand class output level
    IF DemandClassList IS NOT NULL AND DemandClassList.COUNT > 0 THEN
        l_string := MakeSubClause(l_SubClause, 'demand_class', DemandClassList);
        IF (l_String <> 'OK') THEN
            Status := 'INVALID_DEMAND_CLASS';
            RETURN;
        END IF;
        IF l_SubClause <> '' THEN
            l_WhereClause := l_WhereClause || l_SubClause;
        END IF;
    END IF;

    -- make where clause for start date and end date
    l_string := GetStartEndDateClause(l_SubClause, StartDate, EndDate);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;
    l_WhereClause := l_WhereClause || l_SubClause;


    -- query the data
    QueryForecasts(ForecastTbl, l_WhereClause);
    -- */

    Status := 'SUCCESS';

    EXCEPTION
        WHEN others THEN
        -- Status := 'Failed '|| fnd_message.get;
            Status := 'ERROR_UNEXPECTED_02021';

END DOWNLOAD_FORECAST;


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
--        SafetyStockTbl     List of safety stocks to be uploaded to ms_safety_stocks.
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
--        BadRecTbl          List of forecasts that are failed the validation.
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
) AS
l_String            VARCHAR2(100);
l_ResponsibilityId  NUMBER;
l_SecurityGroupId   NUMBER;
l_PlanId            NUMBER;
l_Date              DATE;
l_GoodRecCount      NUMBER;
l_BadRecCount       NUMBER;
l_BadData           MscSafetyStockRec;
BEGIN
    -- init global variables
    g_ErrorCode    := '';

    -- init bad record table
    BadRecTbl := MscSafetyStockTbl();

    -- query user id, responsibility id and security group id
    MSC_WS_COMMON.GET_PERMISSION_IDS(l_String, g_UserId, l_ResponsibilityId, l_SecurityGroupId, UserName, RespName, RespAppName, SecurityGroupName, Language);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;

    MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, g_UserId, l_ResponsibilityId, 'MSC_FNDRSRUN_LEG_COLL',l_SecurityGroupId);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;

    -- get plan id from PlanName + OwningOrgId + SrInstanceId
    l_string := GetPlanId(l_PlanId, PlanName, OwningOrgId, SrInstanceId);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;

    /*
    Richard, I don't think we should check the msc_plans.plan_completion_date.
    The plan_completion_date is always null for new plans until they are ran.
    We cannot detect any ASCP plan is running and using SS from this IO plan.
    BEGIN
        SELECT plan_completion_date INTO l_Date
        FROM msc_plans
        WHERE plan_id = l_PlanId;
        EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_02099';
            raise;
        IF l_Date IS NULL THEN
            Status := 'PLAN_IS_NOT_READY';
        END IF;
    END;
    */

    -- check any safety stock data is available
    IF SafetyStockTbl IS NULL OR SafetyStockTbl.count <= 0 THEN
        Status := 'NO_DATA';
        RETURN;
    END IF;

    -- if PurgeAllFlag is set, purge all rows in msc_safety_stocks table for l_PlanId.
    IF MSC_WS_COMMON.BOOL_TO_NUMBER(PurgeAllFlag) = MSC_UTIL.SYS_YES THEN
        BEGIN
            DELETE FROM msc_safety_stocks
            WHERE
                plan_id = l_PlanId;
            EXCEPTION WHEN others THEN
                g_ErrorCode := 'ERROR_UNEXPECTED_02034';
                raise;
        END;
    END IF;

    -- process safety stock data
    l_GoodRecCount := 0;
    l_BadRecCount := 0;
    FOR I IN SafetyStockTbl.first..SafetyStockTbl.last
    LOOP
        l_string := ProcessSafetyStock(l_PlanId, OwningOrgId, SrInstanceId, SafetyStockTbl(I));
        IF (l_string <> 'OK') THEN
            -- SafetyStockTbl(I).ErrorStatus := l_string;
            l_BadData := SafetyStockTbl(I);
            l_BadData.ErrorStatus := l_string;
            -- BadRecTbl(BadRecTbl.COUNT + 1) := l_BadData; crash
            BadRecTbl.extend;
            BadRecTbl(BadRecTbl.COUNT) := l_BadData;
            l_BadRecCount := l_BadRecCount + 1;
        ELSE
            l_GoodRecCount := l_GoodRecCount + 1;
        END IF;
    END LOOP;

    IF l_BadRecCount = 0 THEN
        Status := 'SUCCESS';
    ELSIF l_GoodRecCount > 0 THEN
        Status := 'COMPLETED_WITH_ERROR';
    ELSE
        -- if all safety stock data are bad, roll back
        Status := 'FAILED';
        rollback;
        RETURN;
    END IF;
    COMMIT;

    EXCEPTION
        WHEN others THEN
            rollback;
            Status := g_ErrorCode;

END UPLOAD_SAFETY_STOCKS;


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
) AS
l_String            VARCHAR2(100);
l_ResponsibilityId  NUMBER;
l_SecurityGroupId   NUMBER;
l_WhereClause       VARCHAR2(2048);
l_SubClause         VARCHAR2(1024);
l_PlanId            NUMBER;
BEGIN
    -- init output table
    SafetyStockTbl := MscSafetyStockTbl();

    -- query user id, responsibility id and security group id
    MSC_WS_COMMON.GET_PERMISSION_IDS(l_String, g_UserId, l_ResponsibilityId, l_SecurityGroupId, UserName, RespName, RespAppName, SecurityGroupName, Language);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;

    MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, g_UserId, l_ResponsibilityId, 'MSC_FNDRSRUN_LEG_COLL',l_SecurityGroupId);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;

    -- get plan id from PlanName + OwningOrgId + SrInstanceId
    l_string := GetPlanId(l_PlanId, PlanName, OwningOrgId, SrInstanceId);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;
    l_WhereClause := ' plan_id = ' || l_PlanId;

    -- make where clause for item ids
    IF ItemIdList IS NOT NULL AND ItemIdList.COUNT > 0 THEN
        l_string := MakeSubClause(l_SubClause, 'inventory_item_id', ItemIdList);
        IF (l_String <> 'OK') THEN
            Status := 'INVALID_ITEM_ID';
            RETURN;
        END IF;
        l_WhereClause := l_WhereClause || l_SubClause;
    END IF;

    -- make where clause for organization ids
    IF OrganizationIdList IS NOT NULL AND OrganizationIdList.COUNT > 0 THEN
        l_string := MakeSubClause(l_SubClause, 'organization_id', OrganizationIdList);
        IF (l_String <> 'OK') THEN
            Status := 'INVALID_SR_ORGANIZATION_ID';
            RETURN;
        END IF;
        l_WhereClause := l_WhereClause || l_SubClause;
    END IF;

    -- query the data
    QuerySafetyStocks(SafetyStockTbl, l_WhereClause);

    Status := 'SUCCESS';

    EXCEPTION
        WHEN others THEN
        -- Status := 'Failed '|| fnd_message.get;
            Status := 'ERROR_UNEXPECTED_02040';

END DOWNLOAD_SAFETY_STOCKS;


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
) AS
l_String            VARCHAR2(100);
l_ResponsibilityId  NUMBER;
l_SecurityGroupId   NUMBER;
l_PlanId            NUMBER;
l_CompletionDate    DATE;
l_GoodRecCount      NUMBER;
l_BadRecCount       NUMBER;
l_BadData           MscPlannedSupplyRec;
BEGIN
    -- init global variables
    g_ErrorCode    := '';

    -- init bad record table
    BadRecTbl := MscPlannedSupplyTbl();

    -- query user id, responsibility id and security group id
    MSC_WS_COMMON.GET_PERMISSION_IDS(l_String, g_UserId, l_ResponsibilityId, l_SecurityGroupId, UserName, RespName, RespAppName, SecurityGroupName, Language);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;

    MSC_WS_COMMON.VALIDATE_USER_RESP_FUNC(l_String, g_UserId, l_ResponsibilityId, 'MSC_FNDRSRUN_LEG_COLL',l_SecurityGroupId);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;

    -- get plan id from PlanName + OwningOrgId + SrInstanceId
    l_String := GetPlanId(l_PlanId, PlanName, OwningOrgId, SrInstanceId);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;

    -- we only support ASCP for now
    l_String := ValidatePlanType(l_PlanId);
    IF (l_String <> 'OK') THEN
        Status := l_String;
        RETURN;
    END IF;

    -- No need to check SrInstanceId. GetPlanId should catch this.

    /*
    Richard, I don't think we should check the msc_plans.plan_completion_date.
      1) The plan_completion_date is always null for new plans until they are ran.
      2) Consultant will run the ASCP plan after the upload.
    BEGIN
        SELECT plan_completion_date INTO l_CompletionDate
        FROM msc_plans
        WHERE plan_id = l_PlanId;
        EXCEPTION WHEN others THEN
            g_ErrorCode := 'ERROR_UNEXPECTED_02098';
            raise;
    END;
    -- Richard, can callers re-set the msc_plans.plan_completion_date?
    IF l_CompletionDate IS NULL THEN
        Status := 'PLAN_IS_NOT_READY';
        RETURN;
    END IF;
    */

    -- check any planned supply data is available
    IF PlannedSupplyTbl IS NULL OR PlannedSupplyTbl.count <= 0 THEN
        Status := 'NO_DATA';
        RETURN;
    END IF;

    -- purge all firmed plan orders in msc_supplies table
    -- for l_PlanId + order_type (5) + firm_planned_type .
    BEGIN
        DELETE FROM msc_supplies
        WHERE
            plan_id = l_PlanId AND
            order_type = 5 AND
            firm_planned_type = 1;
            EXCEPTION WHEN others THEN
                g_ErrorCode := 'ERROR_UNEXPECTED_02051';
                raise;
    END;

    -- process safety stock data
    l_GoodRecCount := 0;
    l_BadRecCount := 0;
    FOR I IN PlannedSupplyTbl.first..PlannedSupplyTbl.last
    LOOP
        l_string := ProcessPlannedSupply(l_PlanId, SrInstanceId, PlannedSupplyTbl(I));
        IF (l_string <> 'OK') THEN
            l_BadData := PlannedSupplyTbl(I);
            l_BadData.ErrorStatus := l_string;
            -- BadRecTbl(BadRecTbl.COUNT + 1) := l_BadData; crash
            BadRecTbl.extend;
            BadRecTbl(BadRecTbl.COUNT) := l_BadData;
            l_BadRecCount := l_BadRecCount + 1;
        ELSE
            l_GoodRecCount := l_GoodRecCount + 1;
        END IF;
    END LOOP;

    IF l_BadRecCount = 0 THEN
        Status := 'SUCCESS';
    ELSIF l_GoodRecCount > 0 THEN
        Status := 'COMPLETED_WITH_ERROR';
    ELSE
        -- if all planned supply data are bad, roll back
        Status := 'FAILED';
        rollback;
        RETURN;
    END IF;
    COMMIT;

    EXCEPTION
        WHEN others THEN
            rollback;
            Status := g_ErrorCode;

END UPLOAD_PLANNED_SUPPLY;


END MSC_WS_APS_DATA_SERVICES;


/
