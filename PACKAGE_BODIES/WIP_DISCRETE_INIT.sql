--------------------------------------------------------
--  DDL for Package Body WIP_DISCRETE_INIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_DISCRETE_INIT" as
/* $Header: wipdjinb.pls 115.10 2003/09/05 21:31:26 kboonyap ship $ */

PROCEDURE get_parameters(p_organization_id              NUMBER,
                        p_default_class                 IN OUT NOCOPY VARCHAR2,
                        p_lot_number_default_type       OUT NOCOPY NUMBER,
                        p_wip_param_count               OUT NOCOPY NUMBER,
                        p_acct_class_flag               IN OUT NOCOPY NUMBER,
                        p_disable_date                  OUT NOCOPY DATE,
                        p_default_ma                    OUT NOCOPY NUMBER,
                        p_default_mva                   OUT NOCOPY NUMBER,
                        p_default_moa                   OUT NOCOPY NUMBER,
                        p_default_ra                    OUT NOCOPY NUMBER,
                        p_default_rva                   OUT NOCOPY NUMBER,
                        p_default_opa                   OUT NOCOPY NUMBER,
                        p_default_opva                  OUT NOCOPY NUMBER,
                        p_default_oa                    OUT NOCOPY NUMBER,
                        p_default_ova                   OUT NOCOPY NUMBER,
                        p_default_scaa                  OUT NOCOPY NUMBER,
                        p_org_locator_control           OUT NOCOPY NUMBER,
                        p_demand_class_mp               OUT NOCOPY VARCHAR2,
                        p_mp_calendar_code              OUT NOCOPY VARCHAR2,
                        p_mp_exception_set_id           OUT NOCOPY NUMBER,
                        p_project_ref                   OUT NOCOPY NUMBER,
                        p_project_control               OUT NOCOPY NUMBER,
                        p_pm_cost_collection            OUT NOCOPY NUMBER,
                        p_primary_cost_method           OUT NOCOPY NUMBER,
                        p_po_creation_time              OUT NOCOPY NUMBER) IS
  l_defSerOp NUMBER; --throw away value
  l_jobChangeToPO NUMBER; --throw away value
begin
  get_parameters(p_organization_id                 => p_organization_id,
                 p_default_class                   => p_default_class,
                 p_lot_number_default_type         => p_lot_number_default_type,
                 p_wip_param_count                 => p_wip_param_count,
                 p_acct_class_flag                 => p_acct_class_flag,
                 p_disable_date                    => p_disable_date,
                 p_default_ma                      => p_default_ma,
                 p_default_mva                     => p_default_mva,
                 p_default_moa                     => p_default_moa,
                 p_default_ra                      => p_default_ra,
                 p_default_rva                     => p_default_rva,
                 p_default_opa                     => p_default_opa,
                 p_default_opva                    => p_default_opva,
                 p_default_oa                      => p_default_oa,
                 p_default_ova                     => p_default_ova,
                 p_default_scaa                    => p_default_scaa,
                 p_org_locator_control             => p_org_locator_control,
                 p_demand_class_mp                 => p_demand_class_mp,
                 p_mp_calendar_code                => p_mp_calendar_code,
                 p_mp_exception_set_id             => p_mp_exception_set_id,
                 p_project_ref                     => p_project_ref,
                 p_project_control                 => p_project_control,
                 p_pm_cost_collection              => p_pm_cost_collection,
                 p_primary_cost_method             => p_primary_cost_method,
                 p_po_creation_time                => p_po_creation_time,
                 p_def_serialization_start_op      => l_defSerOp,
                 p_propagate_job_change_to_po      => l_jobChangeToPO);
end get_parameters;

PROCEDURE get_parameters(p_organization_id               NUMBER,
                        p_default_class                  IN OUT NOCOPY VARCHAR2,
                        p_lot_number_default_type        OUT NOCOPY NUMBER,
                        p_wip_param_count                OUT NOCOPY NUMBER,
                        p_acct_class_flag                IN OUT NOCOPY NUMBER,
                        p_disable_date                   OUT NOCOPY DATE,
                        p_default_ma                     OUT NOCOPY NUMBER,
                        p_default_mva                    OUT NOCOPY NUMBER,
                        p_default_moa                    OUT NOCOPY NUMBER,
                        p_default_ra                     OUT NOCOPY NUMBER,
                        p_default_rva                    OUT NOCOPY NUMBER,
                        p_default_opa                    OUT NOCOPY NUMBER,
                        p_default_opva                   OUT NOCOPY NUMBER,
                        p_default_oa                     OUT NOCOPY NUMBER,
                        p_default_ova                    OUT NOCOPY NUMBER,
                        p_default_scaa                   OUT NOCOPY NUMBER,
                        p_org_locator_control            OUT NOCOPY NUMBER,
                        p_demand_class_mp                OUT NOCOPY VARCHAR2,
                        p_mp_calendar_code               OUT NOCOPY VARCHAR2,
                        p_mp_exception_set_id            OUT NOCOPY NUMBER,
                        p_project_ref                    OUT NOCOPY NUMBER,
                        p_project_control                OUT NOCOPY NUMBER,
                        p_pm_cost_collection             OUT NOCOPY NUMBER,
                        p_primary_cost_method            OUT NOCOPY NUMBER,
                        p_po_creation_time               OUT NOCOPY NUMBER,
                        p_def_serialization_start_op     OUT NOCOPY NUMBER) IS
l_jobChangeToPO NUMBER; --throw away value
begin
  get_parameters(p_organization_id                 => p_organization_id,
                 p_default_class                   => p_default_class,
                 p_lot_number_default_type         => p_lot_number_default_type,
                 p_wip_param_count                 => p_wip_param_count,
                 p_acct_class_flag                 => p_acct_class_flag,
                 p_disable_date                    => p_disable_date,
                 p_default_ma                      => p_default_ma,
                 p_default_mva                     => p_default_mva,
                 p_default_moa                     => p_default_moa,
                 p_default_ra                      => p_default_ra,
                 p_default_rva                     => p_default_rva,
                 p_default_opa                     => p_default_opa,
                 p_default_opva                    => p_default_opva,
                 p_default_oa                      => p_default_oa,
                 p_default_ova                     => p_default_ova,
                 p_default_scaa                    => p_default_scaa,
                 p_org_locator_control             => p_org_locator_control,
                 p_demand_class_mp                 => p_demand_class_mp,
                 p_mp_calendar_code                => p_mp_calendar_code,
                 p_mp_exception_set_id             => p_mp_exception_set_id,
                 p_project_ref                     => p_project_ref,
                 p_project_control                 => p_project_control,
                 p_pm_cost_collection              => p_pm_cost_collection,
                 p_primary_cost_method             => p_primary_cost_method,
                 p_po_creation_time                => p_po_creation_time,
                 p_def_serialization_start_op      => p_def_serialization_start_op,
                 p_propagate_job_change_to_po      => l_jobChangeToPO);

end get_parameters;

PROCEDURE get_parameters(p_organization_id               NUMBER,
                        p_default_class                  IN OUT NOCOPY VARCHAR2,
                        p_lot_number_default_type        OUT NOCOPY NUMBER,
                        p_wip_param_count                OUT NOCOPY NUMBER,
                        p_acct_class_flag                IN OUT NOCOPY NUMBER,
                        p_disable_date                   OUT NOCOPY DATE,
                        p_default_ma                     OUT NOCOPY NUMBER,
                        p_default_mva                    OUT NOCOPY NUMBER,
                        p_default_moa                    OUT NOCOPY NUMBER,
                        p_default_ra                     OUT NOCOPY NUMBER,
                        p_default_rva                    OUT NOCOPY NUMBER,
                        p_default_opa                    OUT NOCOPY NUMBER,
                        p_default_opva                   OUT NOCOPY NUMBER,
                        p_default_oa                     OUT NOCOPY NUMBER,
                        p_default_ova                    OUT NOCOPY NUMBER,
                        p_default_scaa                   OUT NOCOPY NUMBER,
                        p_org_locator_control            OUT NOCOPY NUMBER,
                        p_demand_class_mp                OUT NOCOPY VARCHAR2,
                        p_mp_calendar_code               OUT NOCOPY VARCHAR2,
                        p_mp_exception_set_id            OUT NOCOPY NUMBER,
                        p_project_ref                    OUT NOCOPY NUMBER,
                        p_project_control                OUT NOCOPY NUMBER,
                        p_pm_cost_collection             OUT NOCOPY NUMBER,
                        p_primary_cost_method            OUT NOCOPY NUMBER,
                        p_po_creation_time               OUT NOCOPY NUMBER,
                        p_def_serialization_start_op     OUT NOCOPY NUMBER,
                        p_propagate_job_change_to_po     OUT NOCOPY NUMBER) IS
        std NUMBER;
        nonstd NUMBER;
        CURSOR c1 IS
                SELECT wp.DEFAULT_DISCRETE_CLASS,
                       wp.LOT_NUMBER_DEFAULT_TYPE,
                       wp.PO_CREATION_TIME,
                       wp.default_serialization_start_op,
                       wp.propagate_job_change_to_po
                FROM   WIP_PARAMETERS wp
                WHERE  wp.ORGANIZATION_ID = p_organization_id;
        CURSOR c2 IS
                SELECT DECODE(count(*),0,0,1)
                FROM   WIP_STANDARD_CLASSES_VAL_V wac
                WHERE  wac.ORGANIZATION_ID = p_organization_id;
        CURSOR c3 IS
                SELECT  DECODE(count(*),0,0,2)
                FROM    WIP_NON_STANDARD_CLASSES_VAL_V wac
                WHERE   wac.ORGANIZATION_ID = p_organization_id;
        CURSOR c4 (cc VARCHAR2) IS
                SELECT  NVL(DISABLE_DATE,SYSDATE+1),
                        MATERIAL_ACCOUNT,
                        MATERIAL_VARIANCE_ACCOUNT,
                        MATERIAL_OVERHEAD_ACCOUNT,
                        RESOURCE_ACCOUNT,
                        RESOURCE_VARIANCE_ACCOUNT,
                        OUTSIDE_PROCESSING_ACCOUNT,
                        OUTSIDE_PROC_VARIANCE_ACCOUNT,
                        OVERHEAD_ACCOUNT,
                        OVERHEAD_VARIANCE_ACCOUNT,
                        STD_COST_ADJUSTMENT_ACCOUNT
                FROM    WIP_ACCOUNTING_CLASSES wac
                WHERE   wac.ORGANIZATION_ID = p_organization_id
                AND     wac.CLASS_CODE = cc;
        CURSOR c5 IS
                SELECT  max(STOCK_LOCATOR_CONTROL_CODE),
                        max(DEFAULT_DEMAND_CLASS),
                        max(CALENDAR_CODE),
                        max(CALENDAR_EXCEPTION_SET_ID),
                        nvl(max(PROJECT_REFERENCE_ENABLED),2),
                        nvl(max(PROJECT_CONTROL_LEVEL),1),
                        nvl(max(PM_COST_COLLECTION_ENABLED),2),
                        max(PRIMARY_COST_METHOD)
                FROM    MTL_PARAMETERS
                WHERE   ORGANIZATION_ID = p_organization_id;

BEGIN
        OPEN c1;
        FETCH c1 INTO P_Default_Class, P_Lot_Number_Default_Type, p_po_creation_time, p_def_serialization_start_op, p_propagate_job_change_to_po;
        IF c1%NOTFOUND THEN
                p_wip_param_count := 0;
        ELSE
                p_wip_param_count := 1;
                OPEN c2;
                FETCH c2 INTO std;
                CLOSE c2;
                OPEN c3;
                FETCH c3 INTO nonstd;
                CLOSE c3;
                p_acct_class_flag := std + nonstd;
                IF p_acct_class_flag <> 0 THEN
                        IF P_Default_Class IS NOT NULL THEN
                                OPEN c4(P_Default_Class);
                                FETCH c4 INTO
                                        p_disable_date,
                                        p_default_ma,
                                        p_default_mva,
                                        p_default_moa,
                                        p_default_ra,
                                        p_default_rva,
                                        p_default_opa,
                                        p_default_opva,
                                        p_default_oa,
                                        p_default_ova,
                                        p_default_scaa;
                                CLOSE c4;
                        END IF;
                        OPEN c5;
                        FETCH c5 INTO
                                p_org_locator_control,
                                p_demand_class_mp,
                                p_mp_calendar_code,
                                p_mp_exception_set_id,
                                p_project_ref,
                                p_project_control,
                                p_pm_cost_collection,
                                p_primary_cost_method;
                        CLOSE c5;
                END IF;
        END IF;
        CLOSE c1;
END get_parameters;

END WIP_DISCRETE_INIT;

/
