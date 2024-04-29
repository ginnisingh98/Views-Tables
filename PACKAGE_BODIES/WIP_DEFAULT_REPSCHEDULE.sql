--------------------------------------------------------
--  DDL for Package Body WIP_DEFAULT_REPSCHEDULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_DEFAULT_REPSCHEDULE" AS
/* $Header: WIPDWRSB.pls 115.9 2003/01/07 22:32:02 seli ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'WIP_Default_Repschedule';

--  Package global used within the package.

g_RepSchedule_rec             WIP_Work_Order_PUB.Repschedule_Rec_Type;

--  Get functions.

FUNCTION Get_Alternate_Bom_Designator
RETURN VARCHAR2
IS
BEGIN

   IF(g_RepSchedule_rec.Alternate_Bom_Designator IS NOT NULL) THEN
      RETURN g_RepSchedule_rec.Alternate_Bom_Designator;
   END IF;

   RETURN NULL;

END Get_Alternate_Bom_Designator;

FUNCTION Get_Alternate_Rout_Designator
RETURN VARCHAR2
IS
BEGIN

   IF(g_RepSchedule_rec.Alternate_Rout_Designator IS NOT NULL) THEN
      RETURN g_RepSchedule_rec.Alternate_Rout_Designator;
   END IF;
    RETURN NULL;

END Get_Alternate_Rout_Designator;

FUNCTION Get_Bom_Revision
RETURN VARCHAR2
IS
BEGIN

   IF(g_RepSchedule_rec.Bom_Revision IS NOT NULL) THEN
      RETURN g_RepSchedule_rec.Bom_Revision;
   END IF;

   RETURN NULL;

END Get_Bom_Revision;

FUNCTION Get_Bom_Revision_Date
RETURN DATE
IS
BEGIN

   IF(g_RepSchedule_rec.Bom_Revision_Date IS NOT NULL) THEN
      RETURN g_RepSchedule_rec.Bom_Revision_Date;
   END IF;

   RETURN NULL;

END Get_Bom_Revision_Date;

FUNCTION Get_Common_Bom_Sequence
RETURN NUMBER
IS
BEGIN

   IF(g_RepSchedule_rec.Common_Bom_Sequence_Id IS NOT NULL) THEN
      RETURN g_RepSchedule_rec.Common_Bom_Sequence_Id;
   END IF;

   RETURN NULL;

END Get_Common_Bom_Sequence;

FUNCTION Get_Common_Rout_Sequence
RETURN NUMBER
IS
BEGIN

   IF(g_RepSchedule_rec.Common_Rout_Sequence_Id IS NOT NULL) THEN
      RETURN g_RepSchedule_rec.Common_Rout_Sequence_Id;
   END IF;

   RETURN NULL;

END Get_Common_Rout_Sequence;

FUNCTION Get_Daily_Production_Rate
RETURN NUMBER
IS
     l_min_rate NUMBER;
     l_max_rate NUMBER;
     l_fixed_thruput NUMBER;
BEGIN

   IF(g_RepSchedule_rec.Daily_Production_Rate IS NOT NULL)
     THEN
      RETURN g_RepSchedule_rec.Daily_Production_Rate;
   END IF;

   IF g_RepSchedule_rec.kanban_card_id IS NOT NULL
      AND g_RepSchedule_rec.line_id IS NOT NULL
      AND g_RepSchedule_rec.organization_id IS NOT NULL
     THEN
      SELECT minimum_rate, maximum_rate, fixed_throughput
        INTO l_min_rate, l_max_rate, l_fixed_thruput
        FROM wip_lines
        WHERE line_id = g_RepSchedule_rec.line_id
        AND organization_id = g_RepSchedule_rec.organization_id;

      RETURN l_max_rate;
    END IF;

    RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Daily_Production_Rate;

FUNCTION Get_Date_Closed
RETURN DATE
IS
BEGIN

   IF(g_RepSchedule_rec.Date_Closed IS NOT NULL) THEN
      RETURN g_RepSchedule_rec.Date_Closed;
   END IF;

   RETURN NULL;

END Get_Date_Closed;

FUNCTION Get_Date_Released
RETURN DATE
IS
BEGIN

   IF(g_RepSchedule_rec.Date_Released IS NOT NULL) THEN
      RETURN g_RepSchedule_rec.Date_Released;
   END IF;

   RETURN NULL;

END Get_Date_Released;

FUNCTION Get_Demand_Class
RETURN VARCHAR2
IS
BEGIN

   IF(g_RepSchedule_rec.Demand_Class IS NOT NULL) THEN
      RETURN g_RepSchedule_rec.Demand_Class;
   END IF;

   RETURN NULL;

END Get_Demand_Class;

FUNCTION Get_Description
RETURN VARCHAR2
IS
BEGIN

   IF(g_RepSchedule_rec.Description IS NOT NULL) THEN
      RETURN g_RepSchedule_rec.Description;
   END IF;

   RETURN NULL;

END Get_Description;

FUNCTION Get_Firm_Planned
RETURN NUMBER
IS
BEGIN

   IF(g_RepSchedule_rec.Firm_Planned_Flag IS NOT NULL) THEN
      RETURN g_RepSchedule_rec.Firm_Planned_Flag;
   END IF;

   RETURN NULL;

END Get_Firm_Planned;

FUNCTION Get_First_Unit_Cpl_Date
RETURN DATE
IS
   l_line_sch_type NUMBER;
   l_rout_exists NUMBER := 0;
BEGIN

   IF(g_RepSchedule_rec.First_Unit_Cpl_Date IS NOT NULL) THEN
      RETURN g_RepSchedule_rec.First_Unit_Cpl_Date;
   END IF;

   -- If the line is routing based and the assembly does not have a routing, default the first unit completion date to be the same as the first unit start DATE.

   IF g_RepSchedule_rec.line_id IS NOT NULL THEN
      SELECT line_schedule_type INTO l_line_sch_type
	FROM wip_lines
	WHERE line_id = g_RepSchedule_rec.line_id;


      IF l_line_sch_type = 1 THEN --DO not default for Fixed LT lines
	RETURN NULL;
      END IF;

      IF g_RepSchedule_rec.primary_item_id IS NULL
      OR g_RepSchedule_rec.organization_id IS NULL THEN
	 RETURN NULL;
      END IF;

      SELECT 1 INTO l_rout_exists
	FROM dual
	WHERE exists(
		     SELECT routing_sequence_id
		     FROM bom_operational_routings
		     WHERE assembly_item_id = g_RepSchedule_rec.primary_item_id
		     AND organization_id = g_RepSchedule_rec.organization_id);

      IF (l_rout_exists = 0) THEN
	 RETURN g_RepSchedule_rec.First_Unit_Start_Date;
      END IF;
   END IF;

   RETURN NULL;

END Get_First_Unit_Cpl_Date;

FUNCTION Get_First_Unit_Start_Date
RETURN DATE
IS
   l_line_sch_type NUMBER;
   l_rout_exists NUMBER := 0;
BEGIN

   IF(g_RepSchedule_rec.last_unit_start_date IS NOT NULL) THEN
      RETURN g_RepSchedule_rec.last_unit_start_date;
   END IF;

   -- IF the kanban_card_id IS provided THEN we are defaulting FOR kanbans, IN which CASE DEFAULT the first unit START DATE TO be Sysdate.

   IF(g_RepSchedule_rec.kanban_card_id IS NOT NULL) THEN
      RETURN Sysdate;
   END IF;

   -- If the line is routing based and the assembly does not have a routing, default the first unit start date to be the same as the first unit cpl date

   IF g_RepSchedule_rec.line_id IS NOT NULL THEN
      SELECT line_schedule_type INTO l_line_sch_type
	FROM wip_lines
	WHERE line_id = g_RepSchedule_rec.line_id;

      IF l_line_sch_type = 1 THEN --DO not default for Fixed LT lines
	RETURN NULL;
      END IF;

      IF g_RepSchedule_rec.primary_item_id IS NULL
	 OR g_RepSchedule_rec.organization_id IS NULL THEN
	 RETURN NULL;
      END IF;

      SELECT 1 INTO l_rout_exists
	FROM dual
	WHERE exists(
		     SELECT routing_sequence_id
		     FROM bom_operational_routings
		     WHERE assembly_item_id = g_RepSchedule_rec.primary_item_id
		     AND organization_id = g_RepSchedule_rec.organization_id);

	IF (l_rout_exists = 0) THEN
	   RETURN g_RepSchedule_rec.First_Unit_Cpl_Date;
	END IF;
      END IF;

   RETURN NULL;

END Get_First_Unit_Start_Date;

FUNCTION Get_Last_Unit_Cpl_Date
RETURN DATE
IS
   l_line_sch_type NUMBER;
   l_rout_exists NUMBER := 0;

BEGIN

   IF(g_RepSchedule_rec.last_unit_cpl_date IS NOT NULL) THEN
      RETURN g_RepSchedule_rec.last_unit_cpl_date;
   END IF;

   -- If the line is routing based and the assembly does not have a routing, default the last unit completion date to be the same as the last unit start DATE.

   IF g_RepSchedule_rec.line_id IS NOT NULL THEN
      SELECT line_schedule_type INTO l_line_sch_type
	FROM wip_lines
	WHERE line_id = g_RepSchedule_rec.line_id;


      IF l_line_sch_type = 1 THEN --DO not default for Fixed LT lines
	RETURN NULL;
      END IF;

      IF g_RepSchedule_rec.primary_item_id IS NULL
	 OR g_RepSchedule_rec.organization_id IS NULL THEN
	 RETURN NULL;
      END IF;

      SELECT 1 INTO l_rout_exists
	FROM dual
	WHERE exists(
		     SELECT routing_sequence_id
		     FROM bom_operational_routings
		     WHERE assembly_item_id = g_RepSchedule_rec.primary_item_id
		     AND organization_id = g_RepSchedule_rec.organization_id);

      IF (l_rout_exists = 0) THEN
	 RETURN g_RepSchedule_rec.Last_Unit_Start_Date;
      END IF;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
    RETURN FND_API.G_MISS_DATE;

END Get_Last_Unit_Cpl_Date;

FUNCTION Get_Last_Unit_Start_Date
RETURN DATE
IS
   l_line_sch_type NUMBER;
   l_rout_exists NUMBER := 0;
BEGIN

   IF(g_RepSchedule_rec.Last_Unit_Start_Date IS NOT NULL) THEN
      RETURN g_RepSchedule_rec.Last_Unit_Start_Date;
   END IF;

   -- If the line is routing based and the assembly does not have a routing, default the last unit start date to be the same as the last unit cpl DATE.

   IF g_RepSchedule_rec.line_id IS NOT NULL THEN
      SELECT line_schedule_type INTO l_line_sch_type
	FROM wip_lines
	WHERE line_id = g_RepSchedule_rec.line_id;


      IF l_line_sch_type = 1 THEN --DO not default for Fixed LT lines
	RETURN NULL;
      END IF;

      IF g_RepSchedule_rec.primary_item_id IS NULL
	 OR g_RepSchedule_rec.organization_id IS NULL THEN
	 RETURN NULL;
      END IF;

      SELECT 1 INTO l_rout_exists
	FROM dual
	WHERE exists(
		     SELECT routing_sequence_id
		     FROM bom_operational_routings
		     WHERE assembly_item_id = g_RepSchedule_rec.primary_item_id
		     AND organization_id = g_RepSchedule_rec.organization_id);

      IF (l_rout_exists = 0) THEN
	 RETURN g_RepSchedule_rec.Last_Unit_Cpl_Date;
      END IF;
   END IF;

   RETURN NULL;

END Get_Last_Unit_Start_Date;

FUNCTION Get_Line
RETURN NUMBER
IS
   l_kanban_rec INV_Kanban_PVT.Kanban_Card_Rec_Type;
BEGIN

   IF(g_RepSchedule_rec.line_id IS NOT NULL) THEN
      RETURN g_RepSchedule_rec.line_id;
   END IF;

   IF(g_RepSchedule_rec.kanban_card_id IS NOT NULL) THEN
      l_kanban_rec := INV_KanbanCard_PKG.Query_Row(p_kanban_card_id  => g_RepSchedule_rec.kanban_card_id);
      RETURN(l_kanban_rec.wip_line_id);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
    RETURN FND_API.G_MISS_NUM;

END Get_Line;

FUNCTION Get_Material_Account
RETURN NUMBER
IS
BEGIN

   IF(g_RepSchedule_rec.Material_Account IS NOT NULL) THEN
      RETURN g_RepSchedule_rec.Material_Account;
   END IF;

   RETURN NULL;

END Get_Material_Account;

FUNCTION Get_Material_Overhead_Account
RETURN NUMBER
IS
BEGIN

   IF(g_RepSchedule_rec.Material_Overhead_Account IS NOT NULL) THEN
      RETURN g_RepSchedule_rec.Material_Overhead_Account;
   END IF;

   RETURN NULL;

END Get_Material_Overhead_Account;

FUNCTION Get_Material_Variance_Account
RETURN NUMBER
IS
BEGIN

   IF(g_RepSchedule_rec.Material_Variance_Account IS NOT NULL) THEN
      RETURN g_RepSchedule_rec.Material_Variance_Account;
   END IF;

   RETURN NULL;

END Get_Material_Variance_Account;

FUNCTION Get_Organization
RETURN NUMBER
IS
BEGIN

   IF(g_RepSchedule_rec.Organization_Id IS NOT NULL) THEN
      RETURN g_RepSchedule_rec.Organization_Id;
   END IF;

   RETURN NULL;

END Get_Organization;

FUNCTION Get_Osp_Account
RETURN NUMBER
IS
BEGIN

   IF(g_RepSchedule_rec.Osp_Account IS NOT NULL) THEN
      RETURN g_RepSchedule_rec.Osp_Account;
   END IF;

   RETURN NULL;

END Get_Osp_Account;

FUNCTION Get_Osp_Variance_Account
RETURN NUMBER
IS
BEGIN

   IF(g_RepSchedule_rec.Osp_Variance_Account IS NOT NULL) THEN
      RETURN g_RepSchedule_rec.Osp_Variance_Account;
   END IF;

   RETURN NULL;

END Get_Osp_Variance_Account;

FUNCTION Get_Overhead_Account
RETURN NUMBER
IS
BEGIN

   IF(g_RepSchedule_rec.Overhead_Account IS NOT NULL) THEN
      RETURN g_RepSchedule_rec.Overhead_Account;
   END IF;

   RETURN NULL;

END Get_Overhead_Account;

FUNCTION Get_Overhead_Variance_Account
RETURN NUMBER
IS
BEGIN

   IF(g_RepSchedule_rec.Overhead_Variance_Account IS NOT NULL) THEN
      RETURN g_RepSchedule_rec.Overhead_Variance_Account;
   END IF;

   RETURN NULL;

END Get_Overhead_Variance_Account;

FUNCTION Get_Processing_Work_Days
RETURN NUMBER
IS
  l_kanban_rec INV_Kanban_PVT.Kanban_Card_Rec_Type;
BEGIN

   IF(g_RepSchedule_rec.processing_work_days IS NOT NULL) THEN
      RETURN g_RepSchedule_rec.processing_work_days;
   END IF;

   IF g_RepSchedule_rec.kanban_card_id IS NOT NULL
      AND g_RepSchedule_rec.daily_production_rate IS NOT NULL
     THEN
      l_kanban_rec := INV_KanbanCard_PKG.Query_Row(p_kanban_card_id  => g_RepSchedule_rec.kanban_card_id);
      RETURN(l_kanban_rec.kanban_size / g_RepSchedule_rec.daily_production_rate);
    ELSE
      RETURN FND_API.G_MISS_NUM;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Processing_Work_Days;

FUNCTION Get_Quantity_Completed
RETURN NUMBER
IS
BEGIN

   IF(g_RepSchedule_rec.Quantity_Completed IS NOT NULL) THEN
      RETURN g_RepSchedule_rec.Quantity_Completed;
   END IF;

   RETURN NULL;

END Get_Quantity_Completed;

FUNCTION Get_Repetitive_Schedule
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Repetitive_Schedule;

FUNCTION Get_Resource_Account
RETURN NUMBER
IS
BEGIN

   IF(g_RepSchedule_rec.Resource_Account IS NOT NULL) THEN
      RETURN g_RepSchedule_rec.Resource_Account;
   END IF;

   RETURN NULL;

END Get_Resource_Account;

FUNCTION Get_Resource_Variance_Account
RETURN NUMBER
IS
BEGIN

   IF(g_RepSchedule_rec.Resource_Variance_Account IS NOT NULL) THEN
      RETURN g_RepSchedule_rec.Resource_Variance_Account;
   END IF;

   RETURN NULL;

END Get_Resource_Variance_Account;

FUNCTION Get_Routing_Revision
RETURN VARCHAR2
IS
BEGIN

   IF(g_RepSchedule_rec.Routing_Revision IS NOT NULL) THEN
      RETURN g_RepSchedule_rec.Routing_Revision;
   END IF;

   RETURN NULL;

END Get_Routing_Revision;

FUNCTION Get_Routing_Revision_Date
RETURN DATE
IS
BEGIN

   IF(g_RepSchedule_rec.Routing_Revision_Date IS NOT NULL) THEN
      RETURN g_RepSchedule_rec.Routing_Revision_Date;
   END IF;

   RETURN NULL;

END Get_Routing_Revision_Date;

FUNCTION Get_Status_Type
RETURN NUMBER
IS
BEGIN

   IF(g_RepSchedule_rec.Status_Type IS NOT NULL) THEN
      RETURN g_RepSchedule_rec.Status_Type;
   END IF;

   RETURN NULL;

END Get_Status_Type;

FUNCTION Get_Wip_Entity
RETURN NUMBER
  IS
     l_wip_entity_id NUMBER;
BEGIN

   IF(g_RepSchedule_rec.Wip_Entity_Id IS NOT NULL) THEN
      RETURN g_RepSchedule_rec.Wip_Entity_Id;
   END IF;

   RETURN NULL;
   /* Use the following section if you need a new wip entity id */
   /*
   Select wip_entities_s.nextval into l_wip_entity_id FROM dual;
    RETURN l_wip_entity_id;
     */

END Get_Wip_Entity;

FUNCTION Get_Kanban_Card
RETURN NUMBER
IS
BEGIN

   IF(g_RepSchedule_rec.Kanban_Card_Id IS NOT NULL) THEN
      RETURN g_RepSchedule_rec.Kanban_Card_Id;
   END IF;

   RETURN NULL;

END Get_Kanban_Card;

PROCEDURE Get_Flex_Repschedule
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_RepSchedule_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_RepSchedule_rec.attribute1   := NULL;
    END IF;

    IF g_RepSchedule_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_RepSchedule_rec.attribute10  := NULL;
    END IF;

    IF g_RepSchedule_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_RepSchedule_rec.attribute11  := NULL;
    END IF;

    IF g_RepSchedule_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_RepSchedule_rec.attribute12  := NULL;
    END IF;

    IF g_RepSchedule_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_RepSchedule_rec.attribute13  := NULL;
    END IF;

    IF g_RepSchedule_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_RepSchedule_rec.attribute14  := NULL;
    END IF;

    IF g_RepSchedule_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_RepSchedule_rec.attribute15  := NULL;
    END IF;

    IF g_RepSchedule_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_RepSchedule_rec.attribute2   := NULL;
    END IF;

    IF g_RepSchedule_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_RepSchedule_rec.attribute3   := NULL;
    END IF;

    IF g_RepSchedule_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_RepSchedule_rec.attribute4   := NULL;
    END IF;

    IF g_RepSchedule_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_RepSchedule_rec.attribute5   := NULL;
    END IF;

    IF g_RepSchedule_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_RepSchedule_rec.attribute6   := NULL;
    END IF;

    IF g_RepSchedule_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_RepSchedule_rec.attribute7   := NULL;
    END IF;

    IF g_RepSchedule_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_RepSchedule_rec.attribute8   := NULL;
    END IF;

    IF g_RepSchedule_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_RepSchedule_rec.attribute9   := NULL;
    END IF;

    IF g_RepSchedule_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        g_RepSchedule_rec.attribute_category := NULL;
    END IF;

END Get_Flex_Repschedule;

--  Procedure Attributes

PROCEDURE Attributes
(   p_RepSchedule_rec               IN  WIP_Work_Order_PUB.Repschedule_Rec_Type
,   p_iteration                     IN  NUMBER DEFAULT NULL
,   p_ReDefault                     IN BOOLEAN DEFAULT NULL
,   x_RepSchedule_rec               OUT NOCOPY WIP_Work_Order_PUB.Repschedule_Rec_Type
)
IS
l_RepSchedule_rec  WIP_Work_Order_PUB.RepSchedule_Rec_Type:= WIP_Work_Order_PUB.G_MISS_REPSCHEDULE_REC;
l_return_status BOOLEAN;
l_Defaulting_Done BOOLEAN := FALSE;
BEGIN

    --  Check number of iterations.

    IF nvl(p_iteration,1) > WIP_GLOBALS.G_MAX_DEF_ITERATIONS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','OE_DEF_MAX_ITERATION');
            FND_MSG_PUB.Add;

        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    IF p_RepSchedule_rec.action = WIP_Globals.G_OPR_DEFAULT_USING_KANBAN
      THEN

       IF p_RepSchedule_rec.kanban_card_id IS NULL
         THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
             FND_MESSAGE.SET_NAME('WIP','WIP_REQUIRED');
             FND_MSG_PUB.Add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          l_RepSchedule_rec.kanban_card_id := p_RepSchedule_rec.kanban_card_id;

       END IF;

       IF p_RepSchedule_rec.organization_id IS NULL
         THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
             FND_MESSAGE.SET_NAME('WIP','WIP_REQUIRED');
             FND_MSG_PUB.Add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          l_RepSchedule_rec.organization_id := p_RepSchedule_rec.organization_id;

       END IF;
       --  Initialize g_RepSchedule_rec

       g_RepSchedule_rec := p_RepSchedule_rec;

       --  Default missing attributes.

       g_RepSchedule_rec.daily_production_rate := Get_Daily_Production_Rate;
       g_RepSchedule_rec.date_released := Get_Date_Released;
       g_RepSchedule_rec.firm_planned_flag := Get_Firm_Planned;
       g_RepSchedule_rec.first_unit_start_date := Get_First_Unit_Start_Date;
       g_RepSchedule_rec.first_unit_cpl_date := Get_First_Unit_Cpl_Date;
       g_RepSchedule_rec.line_id := Get_Line;
       g_RepSchedule_rec.processing_work_days := Get_Processing_Work_Days;
       g_RepSchedule_rec.repetitive_schedule_id := Get_Repetitive_Schedule;
       g_RepSchedule_rec.status_type := Get_Status_Type;
       g_RepSchedule_rec.wip_entity_id := Get_Wip_Entity;

        --  Done defaulting attributes
       l_Defaulting_Done := TRUE;
    END IF;
    --  Done defaulting attributes
    IF l_Defaulting_Done
      THEN
       IF nvl(p_ReDefault,TRUE)
	 THEN
	  x_RepSchedule_rec := WIP_RepSchedule_Util.Complete_Record(g_RepSchedule_rec,p_RepSchedule_rec,FALSE);
	ELSE
	  -- Force Copy the given record into the defaulted record.
	  x_RepSchedule_rec := WIP_RepSchedule_Util.Complete_Record(g_RepSchedule_rec,p_RepSchedule_rec,TRUE);
       END IF;
       -- Check against the given flow schedule record
       l_return_status := WIP_RepSchedule_Util.Compare(x_RepSchedule_rec, p_RepSchedule_rec);
       IF (nvl(p_ReDefault,TRUE) = FALSE AND l_return_status = FALSE)
	 THEN
	  x_RepSchedule_rec.return_status := 'N';
       END IF;
    END IF;

END Attributes;

END WIP_Default_Repschedule;

/
