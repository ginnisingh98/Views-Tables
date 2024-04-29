--------------------------------------------------------
--  DDL for Package AHL_RM_ROUTE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_RM_ROUTE_UTIL" AUTHID CURRENT_USER AS
/* $Header: AHLVRUTS.pls 120.0.12010000.3 2009/11/25 13:00:39 bachandr ship $ */

-- Procedure to validate Operation
PROCEDURE validate_operation
(
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_data              OUT NOCOPY           VARCHAR2,
  p_concatenated_segments IN            AHL_OPERATIONS_B_KFV.concatenated_segments%TYPE,
  p_x_operation_id        IN OUT NOCOPY AHL_OPERATIONS_B.operation_id%TYPE
);

-- Procedure to validate lookups
PROCEDURE validate_lookup
(
  x_return_status        OUT NOCOPY    VARCHAR2,
  x_msg_data             OUT NOCOPY    VARCHAR2,
  p_lookup_type          IN            FND_LOOKUPS.lookup_type%TYPE,
  p_lookup_meaning       IN            FND_LOOKUPS.meaning%TYPE,
  p_x_lookup_code        IN OUT NOCOPY FND_LOOKUPS.lookup_code%TYPE
);

-- Procedure to validate Operator
PROCEDURE validate_operator
(
  x_return_status        OUT NOCOPY    VARCHAR2,
  x_msg_data             OUT NOCOPY    VARCHAR2,
  p_operator_name        IN            HZ_PARTIES.party_name%TYPE,
  p_x_operator_party_id  IN OUT NOCOPY NUMBER
);

-- Procedure to validate Additional Disposition List Item
PROCEDURE validate_adt_item
(
  x_return_status        OUT NOCOPY    VARCHAR2,
  x_msg_data             OUT NOCOPY    VARCHAR2,
  p_item_number          IN            MTL_SYSTEM_ITEMS_KFV.concatenated_segments%TYPE,
  p_x_inventory_item_id  IN OUT NOCOPY MTL_SYSTEM_ITEMS.inventory_item_id%TYPE,
  p_x_inventory_org_id   IN OUT NOCOPY MTL_SYSTEM_ITEMS.organization_id%TYPE
);

-- Procedure to validate Component Item
PROCEDURE validate_item
(
  x_return_status        OUT NOCOPY    VARCHAR2,
  x_msg_data             OUT NOCOPY    VARCHAR2,
  p_item_number          IN            MTL_SYSTEM_ITEMS_KFV.concatenated_segments%TYPE,
  p_x_inventory_item_id  IN OUT NOCOPY MTL_SYSTEM_ITEMS.inventory_item_id%TYPE,
  p_x_inventory_org_id   IN OUT NOCOPY MTL_SYSTEM_ITEMS.organization_id%TYPE
);

-- Procedure to validate Service Item
PROCEDURE validate_service_item
(
  x_return_status        OUT NOCOPY    VARCHAR2,
  x_msg_data             OUT NOCOPY    VARCHAR2,
  p_item_number          IN            MTL_SYSTEM_ITEMS_KFV.concatenated_segments%TYPE,
  p_x_inventory_item_id  IN OUT NOCOPY MTL_SYSTEM_ITEMS.inventory_item_id%TYPE,
  p_x_inventory_org_id   IN OUT NOCOPY MTL_SYSTEM_ITEMS.organization_id%TYPE
);

-- Procedure to validate effectivity Item
PROCEDURE validate_effectivity_item
(
  x_return_status        OUT NOCOPY    VARCHAR2,
  x_msg_data             OUT NOCOPY    VARCHAR2,
  p_item_number          IN            MTL_SYSTEM_ITEMS_KFV.concatenated_segments%TYPE,
  p_org_code             IN            MTL_PARAMETERS.ORGANIZATION_CODE%TYPE,
  p_x_inventory_item_id  IN OUT NOCOPY MTL_SYSTEM_ITEMS.inventory_item_id%TYPE,
  p_x_inventory_org_id   IN OUT NOCOPY MTL_SYSTEM_ITEMS.organization_id%TYPE
)
;

-- Procedure to validate Accounting class
PROCEDURE validate_accounting_class
(
  x_return_status             OUT NOCOPY    VARCHAR2,
  x_msg_data                  OUT NOCOPY    VARCHAR2,
  p_accounting_class          IN            WIP_ACCOUNTING_CLASSES.description%TYPE,
  p_x_accounting_class_code   IN OUT NOCOPY WIP_ACCOUNTING_CLASSES.class_code%TYPE,
  p_x_accounting_class_org_id IN OUT NOCOPY WIP_ACCOUNTING_CLASSES.organization_id%TYPE
);

-- Procedure to validate Task Template Group
PROCEDURE validate_task_template_group
(
  x_return_status            OUT NOCOPY    VARCHAR2,
  x_msg_data                 OUT NOCOPY    VARCHAR2,
  p_task_template_group      IN            JTF_TASK_TEMP_GROUPS_VL.template_group_name%TYPE,
  p_x_task_template_group_id IN OUT NOCOPY JTF_TASK_TEMP_GROUPS_VL.task_template_group_id%TYPE
);

-- Procedure to validate QA Plan
PROCEDURE validate_qa_plan
(
  x_return_status        OUT NOCOPY    VARCHAR2,
  x_msg_data             OUT NOCOPY    VARCHAR2,
  p_qa_plan              IN            QA_PLANS_VAL_V.name%TYPE,
  p_x_qa_plan_id         IN OUT NOCOPY QA_PLANS_VAL_V.plan_id%TYPE
);

-- Procedure to validate QA Inspection Type
PROCEDURE validate_qa_inspection_type
(
  x_return_status           OUT NOCOPY    VARCHAR2,
  x_msg_data                OUT NOCOPY    VARCHAR2,
  p_qa_inspection_type_desc IN            QA_CHAR_VALUE_LOOKUPS_V.description%TYPE,
  p_x_qa_inspection_type    IN OUT NOCOPY QA_CHAR_VALUE_LOOKUPS_V.short_code%TYPE
);

-- Procedure to valiadate the Item Group
PROCEDURE validate_item_group
(
  x_return_status        OUT NOCOPY    VARCHAR2,
  x_msg_data             OUT NOCOPY    VARCHAR2,
  p_association_type     IN            VARCHAR2,
  p_item_group_name      IN            AHL_ITEM_GROUPS_VL.name%TYPE,
  p_x_item_group_id      IN OUT NOCOPY AHL_ITEM_GROUPS_VL.item_group_id%TYPE
);


-- Procedure to valiadate the Position Path
PROCEDURE validate_item_comp
(
  x_return_status        OUT NOCOPY    VARCHAR2,
  x_msg_data             OUT NOCOPY    VARCHAR2,
  p_x_item_comp_detail_id   IN OUT NOCOPY NUMBER
);


-- Procedure to valiadate the Position Path
PROCEDURE validate_position_path
(
  x_return_status        OUT NOCOPY    VARCHAR2,
  x_msg_data             OUT NOCOPY    VARCHAR2,
  p_position_path        IN            VARCHAR2,
  p_x_position_path_id   IN OUT NOCOPY NUMBER
);

PROCEDURE validate_master_configuration
(
  x_return_status        OUT NOCOPY    VARCHAR2,
  x_msg_data             OUT NOCOPY    VARCHAR2,
  p_mc_name              IN AHL_MC_HEADERS_V.NAME%TYPE,
  p_x_mc_id              IN OUT NOCOPY AHL_MC_HEADERS_V.MC_ID%TYPE,
  p_mc_revision_number   IN AHL_MC_HEADERS_V.REVISION%TYPE ,
  p_x_mc_header_id       IN OUT NOCOPY AHL_MC_HEADERS_V.MC_HEADER_ID%TYPE
)
;

-- Procedure to validate UOM
PROCEDURE validate_uom
(
  x_return_status        OUT NOCOPY    VARCHAR2,
  x_msg_data             OUT NOCOPY    VARCHAR2,
  p_uom                  IN            MTL_UNITS_OF_MEASURE_VL.unit_of_measure%TYPE,
  p_x_uom_code           IN OUT NOCOPY MTL_UNITS_OF_MEASURE_VL.uom_code%TYPE
);

-- Procedure to validate whether a UOM is valid for an Item / Item Group
PROCEDURE validate_item_uom
(
  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_item_group_id        IN  AHL_ITEM_GROUPS_VL.item_group_id%TYPE,
  p_inventory_item_id    IN  MTL_SYSTEM_ITEMS.inventory_item_id%TYPE,
  p_inventory_org_id     IN  MTL_SYSTEM_ITEMS.organization_id%TYPE,
  p_uom_code             IN  MTL_UNITS_OF_MEASURE_VL.uom_code%TYPE
);

-- Procedure to validate Product Type and Zone association
PROCEDURE validate_pt_zone
(
  x_return_status        OUT NOCOPY    VARCHAR2,
  x_msg_data             OUT NOCOPY    VARCHAR2,
  p_product_type_code    IN            AHL_PRODTYPE_ZONES.product_type_code%TYPE,
  p_zone_code            IN            AHL_PRODTYPE_ZONES.zone_code%TYPE
);

-- Procedure to validate Product Type, Zone and Sub Zone association
PROCEDURE validate_pt_zone_subzone
(
  x_return_status        OUT NOCOPY    VARCHAR2,
  x_msg_data             OUT NOCOPY    VARCHAR2,
  p_product_type_code    IN            AHL_PRODTYPE_ZONES.product_type_code%TYPE,
  p_zone_code            IN            AHL_PRODTYPE_ZONES.zone_code%TYPE,
  p_sub_zone_code        IN            AHL_PRODTYPE_ZONES.sub_zone_code%TYPE
);

-- Procedure to validate MFG lookups
PROCEDURE validate_mfg_lookup
(
  x_return_status        OUT NOCOPY    VARCHAR2,
  x_msg_data             OUT NOCOPY    VARCHAR2,
  p_lookup_type          IN            MFG_LOOKUPS.lookup_type%TYPE,
  p_lookup_meaning       IN            MFG_LOOKUPS.meaning%TYPE,
  p_x_lookup_code        IN OUT NOCOPY MFG_LOOKUPS.lookup_code%TYPE
);

-- Procedure to validate ASO Resource
PROCEDURE validate_aso_resource
(
  x_return_status        OUT NOCOPY    VARCHAR2,
  x_msg_data             OUT NOCOPY    VARCHAR2,
  p_aso_resource_name    IN            AHL_RESOURCES.name%TYPE,
  p_x_aso_resource_id    IN OUT NOCOPY AHL_RESOURCES.resource_id%TYPE
);

-- Procedure to validate ASO Resource
PROCEDURE validate_bom_resource
(
  x_return_status        OUT NOCOPY    VARCHAR2,
  x_msg_data             OUT NOCOPY    VARCHAR2,
  p_bom_resource_code    IN            BOM_RESOURCES.resource_code%TYPE,
  p_x_bom_resource_id    IN OUT NOCOPY BOM_RESOURCES.resource_id%TYPE,
  p_x_bom_org_id         IN OUT NOCOPY BOM_RESOURCES.organization_id%TYPE
);

-- Procedure to validate BOM Resource department
--pdoki ER 7436910 Begin.
PROCEDURE validate_bom_res_dep
(
  x_return_status  OUT NOCOPY    VARCHAR2,
  x_msg_data     OUT NOCOPY    VARCHAR2,
  p_bom_resource_id  IN NUMBER,
  p_bom_org_id   IN  BOM_DEPARTMENTS.organization_id%TYPE,
  p_bom_department_name  IN        BOM_DEPARTMENTS.DESCRIPTION%TYPE,
  p_x_bom_department_id  IN OUT NOCOPY BOM_DEPARTMENTS.department_id%TYPE
);
--pdoki ER 7436910 End.

-- Procedure to validate Resource Costing - Activity
PROCEDURE validate_activity
(
  x_return_status        OUT NOCOPY    VARCHAR2,
  x_msg_data             OUT NOCOPY    VARCHAR2,
  p_activity             IN            CST_ACTIVITIES.activity%TYPE,
  p_x_activity_id        IN OUT NOCOPY CST_ACTIVITIES.activity_id%TYPE
);

-- Procedure to validate Skill Type
PROCEDURE validate_skill_type
(
  x_return_status         OUT NOCOPY   VARCHAR2,
  x_msg_data              OUT NOCOPY   VARCHAR2,
  p_business_group_id     IN           PER_COMPETENCES.business_group_id%TYPE,
  p_skill_name            IN           PER_COMPETENCES.name%TYPE,
  p_x_skill_competence_id IN OUT NOCOPY PER_COMPETENCES.competence_id%TYPE
);

-- Procedure to validate Skill Level
PROCEDURE validate_skill_level
(
  x_return_status       OUT NOCOPY    VARCHAR2,
  x_msg_data            OUT NOCOPY    VARCHAR2,
  p_business_group_id   IN            PER_RATING_LEVELS.business_group_id%TYPE,
  p_skill_competence_id IN            PER_RATING_LEVELS.competence_id%TYPE,
  p_skill_level_desc    IN            VARCHAR2,
  p_x_rating_level_id   IN OUT NOCOPY PER_RATING_LEVELS.rating_level_id%TYPE
);

-- Procedure to validate Qualification Type
PROCEDURE validate_qualification_type
(
  x_return_status           OUT NOCOPY    VARCHAR2,
  x_msg_data                OUT NOCOPY    VARCHAR2,
  p_qualification_type      IN            PER_QUALIFICATION_TYPES.name%TYPE,
  p_x_qualification_type_id IN OUT NOCOPY PER_QUALIFICATION_TYPES.qualification_type_id%TYPE
);

-- Procedure to validate whether the Route is in Updatable status
PROCEDURE validate_route_status
(
  p_route_id             IN  NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  x_return_status        OUT NOCOPY VARCHAR2
);

-- Procedure to validate whether the Operation is in Updatable status
PROCEDURE validate_operation_status
(
  p_operation_id         IN  NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  x_return_status        OUT NOCOPY VARCHAR2
);

-- Procedure to validate Effectivity of the Route
PROCEDURE validate_efct_status
(
  p_efct_id             IN  NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  x_return_status        OUT NOCOPY VARCHAR2
)
;

-- Procedure to validate whether the Time Span of the Route is Greater than the Longest Resource Duration for the Same Route and all the Associated Operations
-- Bug # 8639648 - added route start date parameter for this bug fix.
PROCEDURE validate_route_time_span
(
  p_route_id             IN  NUMBER,
  p_time_span            IN  NUMBER,
  p_rou_start_date       IN  DATE,
  x_res_max_duration     OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  x_return_status        OUT NOCOPY VARCHAR2
);

-- Procedure to validate whether the Duration specified for the Route / Operation Resource is longer than The Route Time Span.
PROCEDURE validate_resource_duration
(
  p_object_id             IN  NUMBER,
  p_association_type_code IN  VARCHAR2,
  p_duration              IN  NUMBER,
  x_max_rt_time_span      OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  x_return_status         OUT NOCOPY VARCHAR2
);

-- Procedure to validate whether the longest Duration specified for an operation Resource is longer than associated Route Time Span.
PROCEDURE validate_rt_op_res_duration
(
  p_route_id              IN  NUMBER,
  p_operation_id          IN  NUMBER,
  x_rt_time_span          OUT NOCOPY NUMBER,
  x_op_max_res_duration   OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2,
  x_return_status         OUT NOCOPY VARCHAR2
);

-- Procedure to validate whether the route / operation Start date is valid.
PROCEDURE validate_rt_oper_start_date
(
  p_object_id             IN  NUMBER,
  p_association_type      IN  VARCHAR2,
  p_start_date            IN  DATE,
  x_start_date            OUT NOCOPY DATE,
  x_msg_data              OUT NOCOPY VARCHAR2,
  x_return_status         OUT NOCOPY VARCHAR2
);

-- Procedure to validate whether the route has correct application usage code.
PROCEDURE validate_ApplnUsage
(
  p_object_id                IN  NUMBER,
  p_association_type         IN  VARCHAR2,
  x_msg_data                 OUT NOCOPY VARCHAR2,
  x_return_status            OUT NOCOPY VARCHAR2
)
;

FUNCTION get_position_meaning
(
 p_position_path_id IN NUMBER,
 p_item_comp_detail_id IN NUMBER
)
RETURN VARCHAR2
;

FUNCTION get_source_composition
(
 p_position_path_id IN NUMBER,
 p_item_comp_detail_id IN NUMBER
)
RETURN VARCHAR2
;

--Procedure to get Operation id out of Operation Number and Revision

-- Start of Comments
-- Procedure name              : Operation_Number_To_Id
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    :
-- Parameters                  :
--
-- Standard IN  Parameters :
--  None
--
-- Standard OUT Parameters :
--  None
--
-- Operation_Number_To_Id IN parameters:
--  p_operation_number  VARCHAR2  Required
--  p_operation_revision  NUMBER    Required
--
-- Operation_Number_To_Id IN OUT parameters:
--      None
--
-- Operation_Number_To_Id OUT parameters:
--      x_operation_id    NUMBER    Required
--  x_return_status   VARCHAR2  Required
--
-- Version :
--          Current version        1.0
--
-- End of Comments

PROCEDURE Operation_Number_To_Id
(
 p_operation_number IN    VARCHAR2,
 p_operation_revision IN    NUMBER,
 x_operation_id   OUT NOCOPY  NUMBER,
 x_return_status  OUT NOCOPY  VARCHAR2
);

--Procedure to get Route id out of Route Number and Revision

-- Start of Comments
-- Procedure name              : Route_Number_To_Id
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    :
-- Parameters                  :
--
-- Standard IN  Parameters :
--  None
--
-- Standard OUT Parameters :
--  None
--
-- Operation_Number_To_Id IN parameters:
--  p_route_number    VARCHAR2  Required
--  p_route_revision  NUMBER    Required
--
-- Operation_Number_To_Id IN OUT parameters:
--      None
--
-- Operation_Number_To_Id OUT parameters:
--  x_route_id    NUMBER    Required
--  x_return_status   VARCHAR2  Required
--
-- Version :
--          Current version        1.0
--
-- End of Comments

PROCEDURE Route_Number_To_Id
(
 p_route_number   IN    VARCHAR2,
 p_route_revision IN    NUMBER,
 x_route_id   OUT NOCOPY  NUMBER,
 x_return_status  OUT NOCOPY  VARCHAR2
);

END AHL_RM_ROUTE_UTIL;

/
