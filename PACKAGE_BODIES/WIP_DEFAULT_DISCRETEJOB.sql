--------------------------------------------------------
--  DDL for Package Body WIP_DEFAULT_DISCRETEJOB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_DEFAULT_DISCRETEJOB" AS
/* $Header: WIPDWDJB.pls 115.9 2004/02/17 11:10:46 panagara ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'WIP_Default_Discretejob';

--  Package global used within the package.

g_DiscreteJob_rec             WIP_Work_Order_PUB.Discretejob_Rec_Type;

--  Get functions.

FUNCTION Get_Alternate_Bom_Designator
RETURN VARCHAR2
IS
BEGIN

   IF(g_DiscreteJob_rec.Alternate_Bom_Designator IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Alternate_Bom_Designator;
   END IF;

   RETURN NULL;

END Get_Alternate_Bom_Designator;

FUNCTION Get_Alternate_Rout_Designator
RETURN VARCHAR2
IS
BEGIN

   IF(g_DiscreteJob_rec.Alternate_Rout_Designator IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Alternate_Rout_Designator;
   END IF;

   RETURN NULL;

END Get_Alternate_Rout_Designator;

FUNCTION Get_Bom_Reference
RETURN NUMBER
IS
BEGIN

 IF(g_DiscreteJob_rec.Bom_Reference_Id IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Bom_Reference_Id;
   END IF;

   RETURN NULL;

END Get_Bom_Reference;

FUNCTION Get_Bom_Revision
RETURN VARCHAR2
IS
BEGIN

   IF(g_DiscreteJob_rec.Bom_Revision IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Bom_Revision;
   END IF;

   RETURN NULL;

END Get_Bom_Revision;

FUNCTION Get_Bom_Revision_Date
RETURN DATE
IS
BEGIN

   IF(g_DiscreteJob_rec.Bom_Revision_Date IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Bom_Revision_Date;
   END IF;

   RETURN NULL;

END Get_Bom_Revision_Date;

FUNCTION Get_Build_Sequence
RETURN NUMBER
IS
BEGIN

   IF(g_DiscreteJob_rec.Build_Sequence IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Build_Sequence;
   END IF;

   RETURN NULL;

END Get_Build_Sequence;

FUNCTION Get_Class
RETURN VARCHAR2
  IS
     l_acct_class VARCHAR2(10);
BEGIN

  IF(g_DiscreteJob_rec.class_code IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.class_code;
   END IF;

   IF(g_DiscreteJob_rec.organization_id IS NOT NULL) THEN
      SELECT default_discrete_class INTO l_acct_class
	FROM wip_parameters
	WHERE organization_id = g_DiscreteJob_rec.organization_id;

      RETURN l_acct_class;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
    RETURN FND_API.G_MISS_CHAR;

END Get_Class;

FUNCTION Get_Common_Bom_Sequence
RETURN NUMBER
IS
BEGIN

IF(g_DiscreteJob_rec.Common_Bom_Sequence_Id IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Common_Bom_Sequence_Id;
   END IF;

   RETURN NULL;

END Get_Common_Bom_Sequence;

FUNCTION Get_Common_Rout_Sequence
RETURN NUMBER
IS
BEGIN

   IF(g_DiscreteJob_rec.Common_Rout_Sequence_Id IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Common_Rout_Sequence_Id;
   END IF;

   RETURN NULL;

END Get_Common_Rout_Sequence;

FUNCTION Get_Completion_Locator
RETURN NUMBER
IS
   l_kanban_rec      INV_Kanban_PVT.Kanban_Card_Rec_Type;
   l_return_status   VARCHAR2(1);
   l_msg_count       NUMBER;
   l_msg_data        VARCHAR2(1000);
   l_locator_control NUMBER;
BEGIN

   IF(g_DiscreteJob_rec.completion_locator_id IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.completion_locator_id;
   END IF;

   IF g_DiscreteJob_rec.organization_id IS NULL
     OR g_DiscreteJob_rec.completion_subinventory IS NULL
     OR g_DiscreteJob_rec.primary_item_id IS NULL
     THEN
      RETURN FND_API.G_MISS_NUM;
    ELSE
      Wip_Globals.Get_Locator_Control(g_DiscreteJob_rec.organization_id,
				     g_DiscreteJob_rec.completion_subinventory,
				     g_DiscreteJob_rec.primary_item_id,
				     l_return_status,
				     l_msg_count,
				     l_msg_data,
				     l_locator_control
				     );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF l_locator_control = 1 THEN
	 RETURN NULL;
      END IF;
      --  Default the locator only if there is locator control.
      IF(g_DiscreteJob_rec.kanban_card_id IS NOT NULL) THEN
	 l_kanban_rec := INV_KanbanCard_PKG.Query_Row(p_kanban_card_id  => g_DiscreteJob_rec.kanban_card_id);
	 RETURN(l_kanban_rec.locator_id);
      END IF;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
    RETURN FND_API.G_MISS_NUM;

END Get_Completion_Locator;

FUNCTION Get_Completion_Subinventory
RETURN VARCHAR2
IS
     l_kanban_rec INV_Kanban_PVT.Kanban_Card_Rec_Type;
BEGIN

    IF(g_DiscreteJob_rec.completion_subinventory IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.completion_subinventory;
   END IF;

   IF(g_DiscreteJob_rec.kanban_card_id IS NOT NULL) THEN
      l_kanban_rec := INV_KanbanCard_PKG.Query_Row(p_kanban_card_id  => g_DiscreteJob_rec.kanban_card_id);
      RETURN(l_kanban_rec.subinventory_name);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
    RETURN FND_API.G_MISS_CHAR;

END Get_Completion_Subinventory;

FUNCTION Get_Date_Closed
RETURN DATE
IS
BEGIN

   IF(g_DiscreteJob_rec.date_closed IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.date_closed;
   END IF;

   RETURN NULL;

END Get_Date_Closed;

FUNCTION Get_Date_Completed
RETURN DATE
IS
BEGIN

   IF(g_DiscreteJob_rec.date_completed IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.date_completed;
   END IF;

   RETURN NULL;

END Get_Date_Completed;

FUNCTION Get_Date_Released
RETURN DATE
IS
BEGIN

   IF(g_DiscreteJob_rec.date_released IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.date_released;
   END IF;

   RETURN Sysdate;

END Get_Date_Released;

FUNCTION Get_Demand_Class
RETURN VARCHAR2
  IS
BEGIN

   IF(g_DiscreteJob_rec.demand_class IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.demand_class;
   END IF;

   RETURN NULL;

END Get_Demand_Class;

FUNCTION Get_Description
RETURN VARCHAR2
IS
BEGIN

   IF(g_DiscreteJob_rec.Description IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Description;
   END IF;

   RETURN NULL;

END Get_Description;

FUNCTION Get_Firm_Planned
RETURN NUMBER
IS
BEGIN

   IF(g_DiscreteJob_rec.Firm_Planned_Flag IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Firm_Planned_Flag;
   END IF;

   RETURN NULL;

END Get_Firm_Planned;

FUNCTION Get_Job_Type
RETURN NUMBER
IS
BEGIN

   IF(g_DiscreteJob_rec.Job_Type IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Job_Type;
   END IF;

   IF(g_DiscreteJob_rec.kanban_card_id IS NOT NULL) THEN
      -- Create Standard Jobs for Kanban replenishment.
      RETURN 1;
   END IF;

   RETURN NULL;

END Get_Job_Type;

FUNCTION Get_Kanban_Card
RETURN NUMBER
IS
BEGIN

   IF(g_DiscreteJob_rec.Kanban_Card_id IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Kanban_Card_id;
   END IF;

   RETURN NULL;

END Get_Kanban_Card;

FUNCTION Get_Line
RETURN NUMBER
IS
     l_kanban_rec INV_Kanban_PVT.Kanban_Card_Rec_Type;
BEGIN

   IF(g_DiscreteJob_rec.Line_id IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Line_id;
   END IF;

   IF(g_DiscreteJob_rec.kanban_card_id IS NOT NULL) THEN
      l_kanban_rec := INV_KanbanCard_PKG.Query_Row(p_kanban_card_id  => g_DiscreteJob_rec.kanban_card_id);
      RETURN(l_kanban_rec.wip_line_id);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
    RETURN FND_API.G_MISS_NUM;

END Get_Line;

FUNCTION Get_Lot_Number
RETURN VARCHAR2
IS
BEGIN

   IF(g_DiscreteJob_rec.Lot_Number IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Lot_Number;
   END IF;

   RETURN NULL;

END Get_Lot_Number;

FUNCTION Get_Material_Account
RETURN NUMBER
IS
BEGIN

   IF(g_DiscreteJob_rec.Material_Account IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Material_Account;
   END IF;

   RETURN NULL;

END Get_Material_Account;

FUNCTION Get_Material_Overhead_Account
RETURN NUMBER
IS
BEGIN

   IF(g_DiscreteJob_rec.Material_Overhead_Account IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Material_Overhead_Account;
   END IF;

   RETURN NULL;

END Get_Material_Overhead_Account;

FUNCTION Get_Material_Variance_Account
RETURN NUMBER
IS
BEGIN

   IF(g_DiscreteJob_rec.Material_Variance_Account IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Material_Variance_Account;
   END IF;

   RETURN NULL;

END Get_Material_Variance_Account;

FUNCTION Get_Mps_Net_Quantity
RETURN NUMBER
IS
BEGIN

   IF(g_DiscreteJob_rec.Mps_Net_Quantity IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Mps_Net_Quantity;
   END IF;

   RETURN NULL;

END Get_Mps_Net_Quantity;

FUNCTION Get_Mps_Scheduled_Cpl_Date
RETURN DATE
IS
BEGIN

   IF(g_DiscreteJob_rec.Mps_Scheduled_Cpl_Date IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Mps_Scheduled_Cpl_Date;
   END IF;

   RETURN NULL;

END Get_Mps_Scheduled_Cpl_Date;

FUNCTION Get_Net_Quantity
RETURN NUMBER
IS
BEGIN

   IF(g_DiscreteJob_rec.Net_Quantity IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Net_Quantity;
   END IF;

   RETURN NULL;

END Get_Net_Quantity;

FUNCTION Get_Organization
RETURN NUMBER
IS
BEGIN

   IF(g_DiscreteJob_rec.Organization_id IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Organization_id;
   END IF;

   RETURN NULL;

END Get_Organization;

FUNCTION Get_Osp_Account
RETURN NUMBER
IS
BEGIN

   IF(g_DiscreteJob_rec.Osp_Account IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Osp_Account;
   END IF;

   RETURN NULL;

END Get_Osp_Account;

FUNCTION Get_Osp_Variance_Account
RETURN NUMBER
IS
BEGIN

   IF(g_DiscreteJob_rec.Osp_Variance_Account IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Osp_Variance_Account;
   END IF;

   RETURN NULL;

END Get_Osp_Variance_Account;

FUNCTION Get_Overcpl_Tolerance_Type
RETURN NUMBER
IS
BEGIN

   IF(g_DiscreteJob_rec.Overcpl_Tolerance_Type IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Overcpl_Tolerance_Type;
   END IF;

   RETURN NULL;

END Get_Overcpl_Tolerance_Type;

FUNCTION Get_Overcpl_Tolerance_Value
RETURN NUMBER
IS
BEGIN

   IF(g_DiscreteJob_rec.Overcpl_Tolerance_Value IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Overcpl_Tolerance_Value;
   END IF;

   RETURN NULL;

END Get_Overcpl_Tolerance_Value;

FUNCTION Get_Overhead_Account
RETURN NUMBER
IS
BEGIN

   IF(g_DiscreteJob_rec.Overhead_Account IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Overhead_Account;
   END IF;

   RETURN NULL;

END Get_Overhead_Account;

FUNCTION Get_Overhead_Variance_Account
RETURN NUMBER
IS
BEGIN

   IF(g_DiscreteJob_rec.Overhead_Variance_Account IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Overhead_Variance_Account;
   END IF;

   RETURN NULL;

END Get_Overhead_Variance_Account;

FUNCTION Get_Primary_Item
RETURN NUMBER
IS
     l_kanban_rec INV_Kanban_PVT.Kanban_Card_Rec_Type;
BEGIN

   IF(g_DiscreteJob_rec.primary_item_id IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.primary_item_id;
   END IF;

   IF(g_DiscreteJob_rec.kanban_card_id IS NOT NULL) THEN
      l_kanban_rec := INV_KanbanCard_PKG.Query_Row(p_kanban_card_id  => g_DiscreteJob_rec.kanban_card_id);
      RETURN(l_kanban_rec.inventory_item_id);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
    RETURN FND_API.G_MISS_NUM;

END Get_Primary_Item;

FUNCTION Get_Project_Costed
RETURN NUMBER
IS
BEGIN

   IF(g_DiscreteJob_rec.Project_Costed IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Project_Costed;
   END IF;

   RETURN NULL;

END Get_Project_Costed;

FUNCTION Get_Project
RETURN NUMBER
IS
BEGIN

   IF(g_DiscreteJob_rec.Project_Id IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Project_Id;
   END IF;

   RETURN NULL;

END Get_Project;

FUNCTION Get_Quantity_Completed
RETURN NUMBER
IS
BEGIN

   IF(g_DiscreteJob_rec.Quantity_Completed IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Quantity_Completed;
   END IF;

   RETURN NULL;

END Get_Quantity_Completed;

FUNCTION Get_Quantity_Scrapped
RETURN NUMBER
IS
BEGIN

   IF(g_DiscreteJob_rec.Quantity_Scrapped IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Quantity_Scrapped;
   END IF;

   RETURN NULL;

END Get_Quantity_Scrapped;

FUNCTION Get_Resource_Account
RETURN NUMBER
IS
BEGIN

   IF(g_DiscreteJob_rec.Resource_Account IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Resource_Account;
   END IF;

   RETURN NULL;

END Get_Resource_Account;

FUNCTION Get_Resource_Variance_Account
RETURN NUMBER
IS
BEGIN

   IF(g_DiscreteJob_rec.Resource_Variance_Account IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Resource_Variance_Account;
   END IF;

   RETURN NULL;

END Get_Resource_Variance_Account;

FUNCTION Get_Routing_Reference
RETURN NUMBER
IS
BEGIN

   IF(g_DiscreteJob_rec.Routing_Revision IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Routing_Reference_Id;
   END IF;

   RETURN NULL;

END Get_Routing_Reference;

FUNCTION Get_Routing_Revision
RETURN VARCHAR2
IS
BEGIN

   IF(g_DiscreteJob_rec.Routing_Revision IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Routing_Revision;
   END IF;

   RETURN NULL;

END Get_Routing_Revision;

FUNCTION Get_Routing_Revision_Date
RETURN DATE
IS
BEGIN

   IF(g_DiscreteJob_rec.Routing_Revision_Date IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Routing_Revision_Date;
   END IF;

   RETURN NULL;

END Get_Routing_Revision_Date;

FUNCTION Get_Scheduled_Completion_Date
RETURN DATE
IS
   l_rout_exists NUMBER := 0;
BEGIN

   IF(g_DiscreteJob_rec.scheduled_completion_date IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.scheduled_completion_date;
   END IF;

   -- If the assembly doesnot have a routing default the completion sate to be the same as the start date.

   IF g_DiscreteJob_rec.primary_item_id IS NOT NULL
      AND g_DiscreteJob_rec.organization_id IS NOT NULL THEN

      SELECT 1 INTO l_rout_exists
	FROM dual
	WHERE exists(
		     SELECT routing_sequence_id
		     FROM bom_operational_routings
		     WHERE assembly_item_id = g_DiscreteJob_rec.primary_item_id
		     AND organization_id = g_DiscreteJob_rec.organization_id);

      IF (l_rout_exists = 0) THEN
	 RETURN g_DiscreteJob_rec.Scheduled_Start_Date;
      END IF;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_DATE;

END Get_Scheduled_Completion_Date;

FUNCTION Get_Scheduled_Start_Date
RETURN DATE
IS
   l_rout_exists NUMBER := 0;
BEGIN

   IF(g_DiscreteJob_rec.scheduled_start_date IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.scheduled_start_date;
   END IF;

   -- If this defaulting is for kanban default the start date to be sysdate.
   IF(g_DiscreteJob_rec.kanban_card_id IS NOT NULL) THEN
      RETURN Sysdate;
   END IF;

   -- If the assembly doesnot have a routing default the start sate to be the same as the completion date.

   IF g_DiscreteJob_rec.primary_item_id IS NOT NULL
      AND g_DiscreteJob_rec.organization_id IS NOT NULL THEN

      SELECT 1 INTO l_rout_exists
	FROM dual
	WHERE exists(
		     SELECT routing_sequence_id
		     FROM bom_operational_routings
		     WHERE assembly_item_id = g_DiscreteJob_rec.primary_item_id
		     AND organization_id = g_DiscreteJob_rec.organization_id);

      IF (l_rout_exists = 0) THEN
	 RETURN g_DiscreteJob_rec.Scheduled_Completion_Date;
      END IF;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_DATE;

END Get_Scheduled_Start_Date;

FUNCTION Get_Schedule_Group
RETURN NUMBER
IS
BEGIN

   IF(g_DiscreteJob_rec.Schedule_Group_Id IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Schedule_Group_Id;
   END IF;

    RETURN NULL;

END Get_Schedule_Group;

FUNCTION Get_Source
RETURN VARCHAR2
IS
BEGIN

   IF(g_DiscreteJob_rec.Source_Code IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Source_Code;
   END IF;

   RETURN NULL;

END Get_Source;

FUNCTION Get_Source_Line
RETURN NUMBER
IS
BEGIN

   IF(g_DiscreteJob_rec.Source_Line_Id IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Source_Line_Id;
   END IF;

   RETURN NULL;

END Get_Source_Line;

FUNCTION Get_Start_Quantity
RETURN NUMBER
IS
   l_kanban_rec INV_Kanban_PVT.Kanban_Card_Rec_Type;
BEGIN

   IF(g_DiscreteJob_rec.start_quantity IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.start_quantity;
   END IF;

   IF(g_DiscreteJob_rec.kanban_card_id IS NOT NULL) THEN
      l_kanban_rec := INV_KanbanCard_PKG.Query_Row(p_kanban_card_id  => g_DiscreteJob_rec.kanban_card_id);
      RETURN(l_kanban_rec.kanban_size);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
    RETURN FND_API.G_MISS_NUM;

END Get_Start_Quantity;

FUNCTION Get_Status_Type
RETURN NUMBER
IS
BEGIN

  IF(g_DiscreteJob_rec.Status_Type IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Status_Type;
   END IF;

   -- By default Jobs are created as unreleased
   RETURN 1;

END Get_Status_Type;

FUNCTION Get_Std_Cost_Adj_Account
RETURN NUMBER
IS
BEGIN

   IF(g_DiscreteJob_rec.Std_Cost_Adj_Account IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Std_Cost_Adj_Account;
   END IF;

   RETURN NULL;

END Get_Std_Cost_Adj_Account;

FUNCTION Get_Task
RETURN NUMBER
IS
BEGIN

  IF(g_DiscreteJob_rec.Task_Id IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Task_Id;
   END IF;

   RETURN NULL;

END Get_Task;

FUNCTION Get_Wip_Entity
RETURN NUMBER
  IS
     l_Wip_Entity_Id NUMBER;
BEGIN

   IF(g_DiscreteJob_rec.Wip_Entity_Id IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Wip_Entity_Id;
   END IF;

   RETURN NULL;
   /* Use the following section if you need a new wip entity id */
   /*
   Select wip_entities_s.nextval into l_wip_entity_id FROM dual;
   RETURN l_Wip_Entity_Id;
     */

END Get_Wip_Entity;

FUNCTION Get_Wip_Supply_Type
RETURN NUMBER
IS
BEGIN

   IF(g_DiscreteJob_rec.Wip_Supply_Type IS NOT NULL) THEN
      RETURN g_DiscreteJob_rec.Wip_Supply_Type;
   END IF;

   RETURN NULL;

END Get_Wip_Supply_Type;

PROCEDURE Get_Flex_Discretejob
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_DiscreteJob_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_DiscreteJob_rec.attribute1   := NULL;
    END IF;

    IF g_DiscreteJob_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_DiscreteJob_rec.attribute10  := NULL;
    END IF;

    IF g_DiscreteJob_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_DiscreteJob_rec.attribute11  := NULL;
    END IF;

    IF g_DiscreteJob_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_DiscreteJob_rec.attribute12  := NULL;
    END IF;

    IF g_DiscreteJob_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_DiscreteJob_rec.attribute13  := NULL;
    END IF;

    IF g_DiscreteJob_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_DiscreteJob_rec.attribute14  := NULL;
    END IF;

    IF g_DiscreteJob_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_DiscreteJob_rec.attribute15  := NULL;
    END IF;

    IF g_DiscreteJob_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_DiscreteJob_rec.attribute2   := NULL;
    END IF;

    IF g_DiscreteJob_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_DiscreteJob_rec.attribute3   := NULL;
    END IF;

    IF g_DiscreteJob_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_DiscreteJob_rec.attribute4   := NULL;
    END IF;

    IF g_DiscreteJob_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_DiscreteJob_rec.attribute5   := NULL;
    END IF;

    IF g_DiscreteJob_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_DiscreteJob_rec.attribute6   := NULL;
    END IF;

    IF g_DiscreteJob_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_DiscreteJob_rec.attribute7   := NULL;
    END IF;

    IF g_DiscreteJob_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_DiscreteJob_rec.attribute8   := NULL;
    END IF;

    IF g_DiscreteJob_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_DiscreteJob_rec.attribute9   := NULL;
    END IF;

    IF g_DiscreteJob_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        g_DiscreteJob_rec.attribute_category := NULL;
    END IF;

END Get_Flex_Discretejob;

--  Procedure Attributes

PROCEDURE Attributes
(   p_DiscreteJob_rec               IN  WIP_Work_Order_PUB.Discretejob_Rec_Type
,   p_iteration                     IN  NUMBER DEFAULT NULL
,   p_ReDefault                     IN  BOOLEAN DEFAULT NULL
,   x_DiscreteJob_rec           OUT NOCOPY WIP_Work_Order_PUB.Discretejob_Rec_Type
)
IS
l_DiscreteJob_rec  WIP_Work_Order_PUB.Discretejob_Rec_Type:= WIP_Work_Order_PUB.G_MISS_DISCRETEJOB_REC;
l_return_status BOOLEAN;
l_Defaulting_Done BOOLEAN := FALSE;
BEGIN

    --  Check number of iterations.

    IF nvl(p_iteration,1) > WIP_GLOBALS.G_MAX_DEF_ITERATIONS THEN

       Wip_Globals.Add_Error_Message(p_message_name   => 'WIP_DEF_MAX_ITERATION');
       RAISE FND_API.G_EXC_ERROR;

    END IF;

    IF p_DiscreteJob_rec.action = WIP_Globals.G_OPR_DEFAULT_USING_KANBAN
      THEN

      IF p_DiscreteJob_rec.kanban_card_id IS NULL
         THEN
	  Wip_Globals.Add_Error_Message(p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
					p_token1_name    => 'ATTRIBUTE',
					p_token1_value   => 'KANBAN_CARD_ID');
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          l_DiscreteJob_rec.kanban_card_id := p_DiscreteJob_rec.kanban_card_id;

       END IF;

     IF p_DiscreteJob_rec.organization_id IS NULL
         THEN
	  Wip_Globals.Add_Error_Message(p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
					p_token1_name    => 'ATTRIBUTE',
					p_token1_value   => 'ORGANIZATION_ID');
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          l_DiscreteJob_rec.organization_id := p_DiscreteJob_rec.organization_id;

       END IF;
    --  Initialize g_DiscreteJob_rec

       g_DiscreteJob_rec := p_DiscreteJob_rec;

    --  Default missing attributes.

       g_DiscreteJob_rec.completion_subinventory := Get_Completion_Subinventory;
       g_DiscreteJob_rec.primary_item_id := Get_Primary_Item;
       g_DiscreteJob_rec.completion_locator_id := Get_Completion_Locator;
       g_DiscreteJob_rec.date_released := Get_Date_Released;
       g_DiscreteJob_rec.firm_planned_flag := Get_Firm_Planned;
       g_DiscreteJob_rec.job_type := Get_Job_Type;
       g_DiscreteJob_rec.mps_net_quantity := Get_Mps_Net_Quantity;
       g_DiscreteJob_rec.mps_scheduled_cpl_date := Get_Mps_Scheduled_Cpl_Date;
       g_DiscreteJob_rec.net_quantity := Get_Net_Quantity;
       g_DiscreteJob_rec.scheduled_completion_date := Get_Scheduled_Completion_Date;
       g_DiscreteJob_rec.scheduled_start_date := Get_Scheduled_Start_Date;
       g_DiscreteJob_rec.source_code := Get_Source;
       g_DiscreteJob_rec.start_quantity := Get_Start_Quantity;
       g_DiscreteJob_rec.status_type := Get_Status_Type;
       g_DiscreteJob_rec.wip_entity_id := Get_Wip_Entity;
       g_DiscreteJob_rec.wip_supply_type := Get_Wip_Supply_Type;

       l_Defaulting_Done := TRUE;

    END IF;

        --  Done defaulting attributes
    IF l_Defaulting_Done
      THEN
       /* Fix for bug 3392437. Modified the following 'If' condition:
       IF nvl(p_ReDefault,FALSE)
       The code in the THEN part needs to be executed when p_ReDefault is FALSE.
       This If condition fails when p_ReDefault is FALSE and hence the control
       goes to Else.
       */
       IF nvl(p_ReDefault,FALSE)=FALSE
	 THEN
	  x_DiscreteJob_rec := WIP_DiscreteJob_Util.Complete_Record(g_DiscreteJob_rec,p_DiscreteJob_rec,FALSE);
	ELSE
	  -- Force Copy the given record into the defaulted record.
	  x_DiscreteJob_rec := WIP_DiscreteJob_Util.Complete_Record(g_DiscreteJob_rec,p_DiscreteJob_rec,TRUE);
       END IF;
       -- Check against the given flow schedule record
       l_return_status := WIP_DiscreteJob_Util.Compare(x_DiscreteJob_rec, p_DiscreteJob_rec);
       IF (nvl(p_ReDefault,FALSE) = FALSE AND l_return_status = FALSE)
	 THEN
	  x_DiscreteJob_rec.return_status := 'N';
       END IF;
    END IF;


END Attributes;

END WIP_Default_Discretejob;

/
