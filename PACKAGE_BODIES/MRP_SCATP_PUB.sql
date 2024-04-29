--------------------------------------------------------
--  DDL for Package Body MRP_SCATP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_SCATP_PUB" AS
/* $Header: MRPPATPB.pls 120.4 2007/11/29 12:34:54 rgurugub ship $  */
G_PKG_NAME CONSTANT VARCHAR2(30) := 'MRP_SCATP_PUB';

-- ========================================================================
-- This procedure inserts information from so_lines to mtl_demand_interface
-- for Supply Chain ATP.
-- ========================================================================

PROCEDURE Insert_Line_MDI(
   p_api_version        IN      NUMBER,
   x_return_status      OUT NOCOPY     VARCHAR2,
   x_msg_count          OUT NOCOPY     NUMBER,
   x_msg_data           OUT NOCOPY     VARCHAR2,
   p_line_id            IN      NUMBER,
   p_assignment_set_id  IN      NUMBER,
   p_atp_group_id       IN OUT NOCOPY     NUMBER ,
   x_session_id         OUT NOCOPY     NUMBER)
IS
   l_api_version           CONSTANT NUMBER := 1.0;
   l_api_name              CONSTANT VARCHAR2(30):= 'Insert_Line_MDI';
   l_assignment_set_id     number;
   l_oe_install	           VARCHAR2(3) := 'OE';

   l_p_atp_group_id NUMBER;
BEGIN
--5022204
--stubbing out the procedure
return;
END Insert_Line_MDI;

-- ========================================================================
-- This procedure inserts information source org information for the request
-- items  into mtl_demand_interface for Supply Chain ATP.
-- ========================================================================
PROCEDURE Insert_Supply_Sources_MDI(
   p_api_version        IN      NUMBER,
   x_return_status      OUT NOCOPY     VARCHAR2,
   x_msg_count          OUT NOCOPY     NUMBER,
   x_msg_data           OUT NOCOPY     VARCHAR2,
   p_atp_group_id       IN      NUMBER,
   p_assignment_set_id  IN      NUMBER,
   x_session_id         OUT NOCOPY     NUMBER )

IS
  l_api_version           CONSTANT NUMBER := 1.0;
  l_api_name              CONSTANT VARCHAR2(30):= 'Insert_Supply_Sources_MDI';
  l_source_org_id       number;
  l_atp_group_id        number;
  l_session_id          number;
  l_lead_time           number;
  l_oe_schedule_window  number;
  l_ship_method         VARCHAR2(30);
  l_vendor_id           number;
  l_vendor_site_id      number;
  l_from_location_id    number;
  l_to_location_id      number;
  l_flag                number;
  l_ship_to_site_use_id number;
  l_customer_id         number;
  l_dest_org_id         number;
  l_oe_install          VARCHAR2(3);
BEGIN
  --  Standard call to check for call compatibility
--5022204
--stubbed out
return;
END Insert_Supply_Sources_MDI;

-- ========================================================================
-- This procedure deletes information from mtl_supply_demand_temp for
-- the atp_group_id specified by the user
-- It also null out some columns in mtl_demand_interface
-- ========================================================================

PROCEDURE Uncheck(
   p_api_version        IN      NUMBER,
   x_return_status      OUT NOCOPY     VARCHAR2,
   x_msg_count          OUT NOCOPY     NUMBER,
   x_msg_data           OUT NOCOPY     VARCHAR2,
   p_atp_group_id       IN      NUMBER)
IS
   l_api_version           CONSTANT NUMBER := 1.0;
   l_api_name              CONSTANT VARCHAR2(30):= 'Uncheck';

BEGIN
 --stubbed out
 --5022204
 return;
END Uncheck;

-- ========================================================================
-- This procedure gets resource/line information from mrp_atp_v and then
-- inserts into mtl_demand_interface for
-- the atp_group_id specified by the user
-- ========================================================================

PROCEDURE Insert_Res_MDI(
   x_err_num       OUT NOCOPY     NUMBER,
   x_err_msg       OUT NOCOPY     VARCHAR2,
   p_atp_group_id  IN      NUMBER)
IS

BEGIN
 --stubbed out
 --5022204
 return;
END Insert_Res_MDI;

PROCEDURE Insert_Comp_MDI(
   p_api_version        IN      NUMBER,
   x_return_status      OUT NOCOPY     VARCHAR2,
   x_msg_count          OUT NOCOPY     NUMBER,
   x_msg_data           OUT NOCOPY     VARCHAR2,
   p_atp_group_id       IN      NUMBER)
IS
  l_api_version           CONSTANT NUMBER := 1.0;
  l_api_name              CONSTANT VARCHAR2(30):= 'Insert_Comp_MDI';

  l_atp_group_id		NUMBER;
  l_organization_id		NUMBER;
  l_inventory_item_id		NUMBER;
  l_atp_rule_id 		NUMBER;
  l_line_item_quantity 		NUMBER;
  l_primary_uom_quantity	NUMBER;
  l_requirement_date 		DATE;
  l_atp_calendar_organization_id	NUMBER;
  l_atp_check			NUMBER;
  l_line_item_uom		VARCHAR(3);
  l_supply_header_id		NUMBER;

  CURSOR C1(l_atp_group_id NUMBER) IS
  SELECT mdi.atp_group_id,
        mdi.organization_id,
        be.component_item_id,
        NVL(wp.component_atp_rule_id,NVL(msi.atp_rule_id,
		mp.default_atp_rule_id)),
        (mdi.line_item_quantity * be.extended_quantity),
        (mdi.primary_uom_quantity * be.extended_quantity),
        mdi.requirement_date,
        mdi.atp_calendar_organization_id,
        1,
        be.primary_uom_code,
        mdi.supply_header_id
  FROM mtl_system_items msi,
          mtl_parameters mp,
          wip_parameters wp,
          bom_explosions be,
          bom_bill_of_materials bom,
          mtl_demand_interface mdi
  WHERE mdi.atp_group_id = l_atp_group_id
 	AND   bom.assembly_item_id = mdi.inventory_item_id
 	AND   bom.organization_id = mdi.organization_id
 	AND   bom.alternate_bom_designator is NULL
 	AND   be.top_bill_sequence_id = bom.bill_sequence_id
 	AND   be.optional = 2
        AND   be.explosion_type = 'ALL'
        AND   MRP_SCATP_PUB.required_component(be.top_bill_sequence_id,
                            be.plan_level,
                            mdi.requirement_date,
                            be.component_sequence_id,
                            be.component_code) = 1
 	AND   be.component_item_id = msi.inventory_item_id
 	AND   be.organization_id = msi.organization_id
        AND   mp.organization_id = msi.organization_id
        AND   wp.organization_id = msi.organization_id
 	AND   msi.atp_flag in ('Y','C');

BEGIN

  --  Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call
           (   l_api_version
           ,   p_api_version
           ,   l_api_name
           ,   G_PKG_NAME
           )
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- initialize API returm status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN C1(p_atp_group_id);
  LOOP
    FETCH C1 INTO l_atp_group_id,
		l_organization_id,
		l_inventory_item_id,
		l_atp_rule_id,
		l_line_item_quantity,
		l_primary_uom_quantity,
		l_requirement_date,
		l_atp_calendar_organization_id,
		l_atp_check,
		l_line_item_uom,
		l_supply_header_id;

    IF C1%ROWCOUNT = 0 THEN
      CLOSE C1;
      RAISE NO_DATA_FOUND;
    END IF;

    EXIT WHEN C1%NOTFOUND;

    -- insert component records into mtl_demand_interface
    INSERT INTO MTL_DEMAND_INTERFACE(
       atp_group_id,
       organization_id,
       inventory_item_id,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login,
       atp_rule_id,
       line_item_quantity,
       primary_uom_quantity,
       requirement_date,
       atp_calendar_organization_id,
       atp_check,
       line_item_uom,
       supply_header_id
      )
    VALUES (l_atp_group_id,
        l_organization_id,
        l_inventory_item_id,
        sysdate,
        1,
        sysdate,
        1,
        1,
        l_atp_rule_id,
        l_line_item_quantity,
        l_primary_uom_quantity,
        l_requirement_date,
        l_atp_calendar_organization_id,
        l_atp_check,
        l_line_item_uom,
        l_supply_header_id);

  END LOOP;
  CLOSE C1;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       x_return_status := FND_API.G_RET_STS_ERROR;

       FND_MESSAGE.set_name('MRP','MRP_NO_ATP_COMPONENTS');
       FND_MSG_PUB.Add;

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'l_api_name'
            );
        END IF;

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

  END Insert_Comp_MDI;

/*
FUNCTION required_component(p_top_bill_seq_id IN NUMBER,
                            p_plan_level      IN NUMBER,
                            p_request_date    IN DATE,
		            p_comp_seq_id     IN NUMBER,
			    p_component_code  IN VARCHAR2)
return NUMBER
IS
i                       BINARY_INTEGER := 1;
l_required		BINARY_INTEGER := 0;
l_component_code	VARCHAR2(1000);
BEGIN
--5022204
--stubbed out
return -1;
END required_component;
*/

FUNCTION required_component(p_top_bill_seq_id IN NUMBER,
                            p_plan_level      IN NUMBER,
                            p_request_date    IN DATE,
                            p_comp_seq_id     IN NUMBER,
                            p_component_code  IN VARCHAR2)
return NUMBER
IS
i                       BINARY_INTEGER := 1;
l_required              BINARY_INTEGER := 0;
l_component_code        VARCHAR2(1000);
BEGIN

    -- this function is planned to be used to determine if a component
    -- requirement is required when we calculate flow shedule requirements
    -- in atp program.  we need to explose through phantom.
    -- for example, we have a bill like this
    --             A
    --             .B (phantom)
    --             ..C (phantom)
    --             ...D
    --             .E
    --             ..C (phantom)
    --             ...D
    -- So if we have a flow schedule on A, it should have component requirement
    -- on D (from A-B-C-D) and E (from A-E) only.
    -- So we should return 1 for the D and E and return 0 for the rest.

    -- First we need to make sure this item is not a phantom
    -- (phantom will not be included not matter at which plan level)

    BEGIN
        SELECT  '1'
        INTO    l_required
            FROM    BOM_INVENTORY_COMPONENTS
            WHERE       COMPONENT_SEQUENCE_ID = p_comp_seq_id
            AND NVL(WIP_SUPPLY_TYPE,
               MRP_SCATP_PUB.mtl_wip_supply_type(
                         p_top_bill_seq_id,
                         component_item_id)) <> 6; /* Bug 2777745 */
    EXCEPTION WHEN NO_DATA_FOUND THEN
            l_required := 0;
    END;

    IF (l_required = 1) AND (p_plan_level > 1) THEN
      -- now we make sure the item itself is not a phantom. however,
      -- if this item is not a immediate component, we need to make sure
      -- all the parent records are phantoms all the way up and

        l_component_code := p_component_code;

        FOR i IN REVERSE 1..p_plan_level-1 LOOP
          -- we go to the parent level, and i indicates the plan_level of the
          -- parent record.

          l_component_code := substr(l_component_code, 1,
                                   instr(l_component_code,'-',-1,1)-1);

          BEGIN
            -- bug 1305491: look like bom still does the explosion
            -- for the model, option class which belong to config item.
            -- so we end up triple count the component demand for the option.
            -- so we need to make sure all the parents are not model/oc.
            SELECT      '1'
            INTO        l_required
                FROM    BOM_INVENTORY_COMPONENTS BIC,
                                BOM_EXPLOSIONS BE
                WHERE   BE.TOP_BILL_SEQUENCE_ID = p_top_bill_seq_id
            AND         BE.COMPONENT_CODE = l_component_code
            AND         BE.PLAN_LEVEL = i
            AND         BE.explosion_type = 'ALL'
            AND         TRUNC(BE.EFFECTIVITY_DATE) <= TRUNC(p_request_date)
            AND         TRUNC(BE.DISABLE_DATE) >TRUNC(p_request_date)
                AND             BIC.COMPONENT_SEQUENCE_ID =
BE.COMPONENT_SEQUENCE_ID
            AND         nvl(BIC.WIP_SUPPLY_TYPE,
                        MRP_SCATP_PUB.mtl_wip_supply_type(
                             p_top_bill_seq_id,
                             bic.component_item_id)) = 6  /* Bug 2777745 */
            AND         BIC.BOM_ITEM_TYPE NOT IN (1,2); -- not a model or oc
          EXCEPTION WHEN NO_DATA_FOUND THEN
                l_required := 0 ;
          END;

          EXIT WHEN l_required = 0 ;

        END LOOP;
    END IF; -- end if (l_required = 1) AND (p_plan_level > 1)
    return l_required;

END required_component;


/* Bug 2777745 */
FUNCTION mtl_wip_supply_type(
       p_top_bill_seq_id IN NUMBER,
	   p_comp_id     IN NUMBER)
RETURN NUMBER
IS
l_wip_supply_type NUMBER;
BEGIN

  SELECT NVL(msi.wip_supply_type,1)
   INTO l_wip_supply_type
  FROM mtl_system_items msi, bom_bill_of_materials bbm
  WHERE bbm.bill_sequence_id = p_top_bill_seq_id
  AND   msi.organization_id = bbm.organization_id
  AND   msi.inventory_item_id = p_comp_id;

  RETURN(l_wip_supply_type);

END mtl_wip_supply_type;

END MRP_SCATP_PUB;

/
