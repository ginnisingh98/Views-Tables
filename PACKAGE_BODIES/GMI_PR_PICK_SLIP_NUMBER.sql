--------------------------------------------------------
--  DDL for Package Body GMI_PR_PICK_SLIP_NUMBER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_PR_PICK_SLIP_NUMBER" AS
/*  $Header: GMIUSLPB.pls 120.0 2005/05/25 16:17:49 appldev noship $  */
/*
+===========================================================================+
|               Copyright (c) 1999 Oracle Corporation                       |
|                  Redwood Shores, California, USA                          |
|                       All rights reserved.                                |
+===========================================================================+
+===========================================================================+

NAME

  GMIUSLPB.pls

DESCRIPTION (direct copy from file WSHPRPNB.pls)

  This package has 2 public APIs Get_Pick_Slip_Number and Print_Pick_Slip.

  Get_Pick_Slip_Number is used to get a pick slip number depending on the grouping
  rule and grouping rule attribute values passed from dynamically built PL/SQL
  tables. A new pick slip is generated if the criteria doesn't match any of
  the records in the dynamic table. Otherwise the exisiting one is used.
  Also for efficiency purposes a table of grouping rules (passed to this program)
  and grouping rule attributes is maintained.

  Print_Pick_Slip is used to print a specified pick slip or all the pick slips
  created in the particular session.

HISTORY

+===========================================================================+
*/

-- HW BUG#:Removed reference to G_MISS_XXX
   /*  PACKAGE TYPES */
      TYPE keyRecTyp IS RECORD (
         grouping_rule_id         NUMBER		,
         header_id                NUMBER		,
         customer_id              NUMBER		,
         ship_method_code         VARCHAR2(30)	,
         ship_to_loc_id           NUMBER		,
         shipment_priority        VARCHAR2(30)	,
         subinventory             VARCHAR2(10)	,
         trip_stop_id             NUMBER		,
         delivery_id              NUMBER		,
         inventory_item_id        NUMBER     	,
         locator_id               NUMBER     	,
         lot_number               VARCHAR2(32)   	,
         revision                 VARCHAR2(3)    	,
         organization_id          NUMBER		,
         pick_slip_number         NUMBER		,
         counter                  NUMBER
      );


      TYPE keyTabTyp IS TABLE OF keyRecTyp INDEX BY BINARY_INTEGER;

      TYPE grpRecTyp IS RECORD (
         grouping_rule_id         NUMBER	,
         use_order_ps             VARCHAR2(1)   := 'N',
         use_sub_ps               VARCHAR2(1)   := 'N',
         use_customer_ps          VARCHAR2(1)   := 'N',
         use_ship_to_ps           VARCHAR2(1)   := 'N',
         use_carrier_ps           VARCHAR2(1)   := 'N',
         use_ship_priority_ps     VARCHAR2(1)   := 'N',
         use_trip_stop_ps         VARCHAR2(1)   := 'N',
         use_delivery_ps          VARCHAR2(1)   := 'N',
         use_item_ps              VARCHAR2(1)   := 'N',
         use_locator_ps           VARCHAR2(1)   := 'N',
         use_lot_ps               VARCHAR2(1)   := 'N',
         use_revision_ps          VARCHAR2(1)   := 'N'
      );

      TYPE grpTabTyp IS TABLE OF grpRecTyp INDEX BY BINARY_INTEGER;

   /*  PACKAGE VARIABLES */
      g_rule_table                            grpTabTyp;
      g_pskey_table                           keyTabTyp;

   /*  FORWARD DECLARATIONS */
   PROCEDURE Insert_Key (
      p_rule_index                 IN      NUMBER,
      p_header_id                  IN      NUMBER,
      p_customer_id                IN      NUMBER,
      p_ship_method_code           IN      VARCHAR2,
      p_ship_to_loc_id             IN      NUMBER,
      p_shipment_priority          IN      VARCHAR2,
      p_subinventory               IN      VARCHAR2,
      p_trip_stop_id               IN      NUMBER,
      p_delivery_id                IN      NUMBER,
      p_inventory_item_id          IN      NUMBER,
      p_locator_id                 IN      NUMBER,
      p_lot_number                 IN      VARCHAR2,
      p_revision                   IN      VARCHAR2,
      p_org_id                     IN      NUMBER,
      x_pick_slip_number           OUT NOCOPY     NUMBER
   );

   PROCEDURE Print_Pvt (
      p_report_set_id              IN     NUMBER,
      p_organization_id            IN     NUMBER,
      p_pick_slip_number           IN     NUMBER,
      x_api_status                 OUT NOCOPY    VARCHAR2
   );

/* =======================================================================
 |     Name
 |       PROCEDURE Print_Pick_Slip
 |
 |     Purpose
 |       This function initializesthe g_use_ variables to be used
 |       in determining the how to group pick slips.
 |
 |     Input Parameters
 |       p_pick_slip_number => pick slip number
 |       p_report_set_id    => report set
 |
 |     Output Parameters
 |       x_api_status    => FND_API.G_RET_STS_SUCESSS or
 |                          FND_API.G_RET_STS_ERROR or
 |                          FND_API.G_RET_STS_UNEXP_ERROR
 |       x_error_message => Error message
 =========================================================================*/

-- HW BUG#:2643440 - Replaced FND_API.G_MISS_NUM for p_pick_slip_number
-- with DEFAULT NULL
   PROCEDURE Print_Pick_Slip (
      p_pick_slip_number         IN  NUMBER DEFAULT NULL,
      p_report_set_id            IN  NUMBER,
      p_organization_id          IN  NUMBER,
      x_api_status               OUT NOCOPY VARCHAR2,
      x_error_message            OUT NOCOPY VARCHAR2 )
   IS
      l_index         NUMBER;
      l_ps_num        NUMBER;
      l_document_info WSH_DOCUMENT_SETS.document_set_tab_type;
   BEGIN
      l_index := g_pskey_table.first;

      /*  If report set id is NULL, there is no report to print */
      IF (p_report_set_id IS NULL) THEN
         x_api_status := FND_API.G_RET_STS_SUCCESS;
         RETURN;
      END IF;

      /*  If key table is empty, there is nothing to print */
      IF (l_index IS NULL) THEN
         x_api_status := FND_API.G_RET_STS_SUCCESS;
         RETURN;
      END IF;

-- HW BUG#:2643440 - Replaced comparison with FND_API.G_MISS_NUM for p_pick_slip_number
-- with NULL

      IF p_pick_slip_number = NULL THEN
         /*  Loop through key table and print all remaining pick slips */
         WHILE l_index IS NOT NULL LOOP
            /*  Print pick slip */
            l_ps_num := g_pskey_table(l_index).pick_slip_number;
            WSH_UTIL_CORE.Println('calling Print_Pvt, num =' || l_ps_num);
            Print_Pvt(p_report_set_id, p_organization_id, l_ps_num, x_api_status);
            WSH_UTIL_CORE.Println('x_api_status Print_Pvt:'|| x_api_status);

            /*  Remove from table */
            g_pskey_table.delete(l_index);

            l_index := g_pskey_table.next(l_index);
         END LOOP;
      ELSE
         /*  Loop through table to find specified pick slip */
         WHILE l_index IS NOT NULL LOOP
            IF g_pskey_table(l_index).pick_slip_number = p_pick_slip_number THEN
               /*  Print pick slip */
               Print_Pvt(p_report_set_id, p_organization_id, p_pick_slip_number, x_api_status);

               /*  Remove from table */
               g_pskey_table.delete(l_index);
               EXIT;
            END IF;

            l_index := g_pskey_table.next(l_index);
         END LOOP;
      END IF;

      IF x_api_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_error_message := 'Error occurred in call to ' ||
                            'WSH_UTIL_CORE.Print_Document_Sets in ' ||
                            'WSH_PR_PICK_SLIP_NUMBER.Print_Pick_Slip';
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         x_error_message := 'Exception occurred in WSH_PR_PICK_SLIP_NUMBER.Print_Pick_Slip';
         x_api_status := FND_API.G_RET_STS_UNEXP_ERROR;
         WSH_UTIL_CORE.Println('SQL error: ' ||  SQLERRM(SQLCODE));
   END Print_Pick_Slip;

/* =======================================================================
 |  Name
 |    PROCEDURE Get_Pick_Slip_Number
 |
 |  Purpose
 |    Returns pick slip number
 |
 |  Input Parameters
 |    p_ps_mode              => pick slip print mode: I=immed, E=deferred
 |    p_pick_grouping_rule_id => pick grouping rule id
 |    p_org_id               => organization_id
 |    p_header_id            => order header id
 |    p_customer_id          => customer id
 |    p_ship_method_code     => ship method
 |    p_ship_to_loc_id       => ship to location
 |    p_shipment_priority    => shipment priority
 |    p_subinventory         => subinventory
 |    p_trip_stop_id         => trip stop
 |    p_delivery_id          => delivery
 |    p_inventory_item_id    => item
 |    p_locator_id           => locator
 |    p_lot_number           => lot number
 |    p_revision             => revision
 |
 |  Output Parameters
 |    x_pick_slip_number     => pick_slip_number
 |    x_ready_to_print       => FND_API.G_TRUE or FND_API.G_FALSE
 |    x_api_status           => FND_API.G_RET_STS_SUCESSS or
 |                              FND_API.G_RET_STS_ERROR or
 |                              FND_API.G_RET_STS_UNEXP_ERROR
 |    x_error_message        => Error message
 ===============================================================*/
PROCEDURE Get_Pick_Slip_Number (
   p_ps_mode                    IN      VARCHAR2,
      p_pick_grouping_rule_id      IN      NUMBER,
      p_org_id                     IN      NUMBER,
      p_header_id                  IN      NUMBER,
      p_customer_id                IN      NUMBER,
      p_ship_method_code           IN      VARCHAR2,
      p_ship_to_loc_id             IN      NUMBER,
      p_shipment_priority          IN      VARCHAR2,
      p_subinventory               IN      VARCHAR2,
      p_trip_stop_id               IN      NUMBER,
      p_delivery_id                IN      NUMBER,
      p_inventory_item_id	     IN      NUMBER   DEFAULT NULL,
      p_locator_id                 IN      NUMBER   DEFAULT NULL,
      p_lot_number                 IN      VARCHAR2 DEFAULT NULL,
      p_revision                   IN      VARCHAR2 DEFAULT NULL,
      x_pick_slip_number           OUT NOCOPY     NUMBER,
      x_ready_to_print             OUT NOCOPY     VARCHAR2,
      x_api_status                 OUT NOCOPY     VARCHAR2,
      x_error_message              OUT NOCOPY     VARCHAR2
   ) IS
      /*  cursor to get the pick slip grouping rule */
      CURSOR ps_rule (v_pgr_id IN NUMBER) IS
      SELECT NVL(ORDER_NUMBER_FLAG, 'N'),
             NVL(SUBINVENTORY_FLAG, 'N'),
             NVL(CUSTOMER_FLAG, 'N'),
             NVL(SHIP_TO_FLAG, 'N'),
             NVL(CARRIER_FLAG, 'N'),
             NVL(SHIPMENT_PRIORITY_FLAG, 'N'),
             NVL(TRIP_STOP_FLAG, 'N'),
             NVL(DELIVERY_FLAG, 'N'),
	        NVL(ITEM_FLAG, 'N'),
	        NVL(LOCATOR_FLAG, 'N'),
	        NVL(LOT_FLAG, 'N'),
	        NVL(REVISION_FLAG, 'N')
      FROM   WSH_PICK_GROUPING_RULES
      WHERE  PICK_GROUPING_RULE_ID = v_pgr_id;

      /*  cursor to get number of times called before printer */
      CURSOR get_limit (v_org_id IN NUMBER) IS
      SELECT NVL(pick_slip_lines,-1)
      FROM   WSH_SHIPPING_PARAMETERS
      WHERE  ORGANIZATION_ID = v_org_id;

      l_limit        NUMBER;
      l_rule_index   NUMBER;
      l_found        BOOLEAN;
      i              NUMBER;

   BEGIN
      /*  get the number of times called for a pick slip before  */
      /*  setting the ready to print flag to TRUE, if print is immediate */
      IF p_ps_mode =  'I' THEN
         OPEN get_limit(p_org_id);
         FETCH get_limit INTO l_limit;
         IF get_limit%NOTFOUND THEN
            x_error_message := 'Organization ' ||
                               to_char(p_org_id) ||
                               ' does not exist. ';
            x_api_status := FND_API.G_RET_STS_ERROR;
            RETURN;
         END IF;
      END IF;


      /*  Set ready to print flag to FALSE initially */
      x_ready_to_print :=  FND_API.G_FALSE;

      /*  find grouping rule in table */
      l_found := FALSE;
      FOR i IN 1..g_rule_table.count LOOP
         IF (g_rule_table(i).grouping_rule_id = p_pick_grouping_rule_id) THEN
            l_found := TRUE;
            l_rule_index := i;
            EXIT;
         END IF;
      END LOOP;

      /*  if not found, fetch information about pick slip grouping rule */
      IF (NOT l_found) THEN
         i := g_rule_table.count + 1;
         OPEN    ps_rule(p_pick_grouping_rule_id);
         FETCH   ps_rule
         INTO    g_rule_table(i).use_order_ps,
                 g_rule_table(i).use_sub_ps,
                 g_rule_table(i).use_customer_ps,
                 g_rule_table(i).use_ship_to_ps,
                 g_rule_table(i).use_carrier_ps,
                 g_rule_table(i).use_ship_priority_ps,
                 g_rule_table(i).use_trip_stop_ps,
                 g_rule_table(i).use_delivery_ps,
                 g_rule_table(i).use_item_ps,
                 g_rule_table(i).use_locator_ps,
                 g_rule_table(i).use_lot_ps,
                 g_rule_table(i).use_revision_ps;
         IF ps_rule%NOTFOUND THEN
            x_error_message := 'Pick grouping rule '
                               || to_char(p_pick_grouping_rule_id) ||
                               ' does not exist';
            x_api_status := FND_API.G_RET_STS_ERROR;
            RETURN;
         END IF;

         g_rule_table(i).grouping_rule_id := p_pick_grouping_rule_id;

         /*  Insert new key to table based on grouping rule */
         Insert_Key(p_rule_index        => i,
                    p_header_id         => p_header_id,
                    p_customer_id       => p_customer_id,
                    p_ship_method_code  => p_ship_method_code,
                    p_ship_to_loc_id    => p_ship_to_loc_id,
                    p_shipment_priority => p_shipment_priority,
                    p_subinventory      => p_subinventory,
                    p_trip_stop_id      => p_trip_stop_id,
                    p_delivery_id       => p_delivery_id,
                    p_inventory_item_id => p_inventory_item_id,
                    p_locator_id        => p_locator_id,
                    p_lot_number        => p_lot_number,
                    p_revision          => p_revision,
                    p_org_id            => p_org_id,
                    x_pick_slip_number  => x_pick_slip_number  );

         x_api_status := FND_API.G_RET_STS_SUCCESS;
         RETURN;

      END IF;

      /*  If grouping rule is stored, find stored pick slip number for rule */
      l_found := FALSE;
      i := g_pskey_table.first;
      LOOP
         /*  If key table is empty, there is no looping through table */
         IF (i IS NULL) THEN
            EXIT;
         END IF;

         IF (g_pskey_table(i).grouping_rule_id = p_pick_grouping_rule_id) THEN
            l_found := TRUE;
            IF (g_rule_table(l_rule_index).use_order_ps = 'Y') THEN
               IF (NVL(g_pskey_table(i).header_id,-1) <> NVL(p_header_id,-1)) THEN
                  l_found := FALSE;
               END IF;
            ELSE
-- HW replaced by NULL
               IF (g_pskey_table(i).header_id <> NULL) THEN
                  l_found := FALSE;
               END IF;
            END IF;

            IF (g_rule_table(l_rule_index).use_sub_ps = 'Y') AND l_found THEN
               IF (NVL(g_pskey_table(i).subinventory,'-1') <> NVL(p_subinventory,'-1')) THEN
                  l_found := FALSE;
               END IF;
            ELSE
-- HW replaced by NULL
               IF (g_pskey_table(i).subinventory <> NULL) THEN
                  l_found := FALSE;
               END IF;
            END IF;

            IF (g_rule_table(l_rule_index).use_customer_ps = 'Y') AND l_found THEN
               IF (NVL(g_pskey_table(i).customer_id,-1) <> NVL(p_customer_id,-1)) THEN
                  l_found := FALSE;
               END IF;
             ELSE
-- HW replaced by NULL
               IF (g_pskey_table(i).customer_id <> NULL) THEN
                  l_found := FALSE;
               END IF;

            END IF;

            IF (g_rule_table(l_rule_index).use_ship_to_ps = 'Y') AND l_found THEN
               IF (NVL(g_pskey_table(i).ship_to_loc_id,-1) <> NVL(p_ship_to_loc_id,-1)) THEN
                  l_found := FALSE;
               END IF;
            ELSE
-- HW replaced by NULL
               IF (g_pskey_table(i).ship_to_loc_id <> NULL) THEN
                  l_found := FALSE;
               END IF;
            END IF;

            IF (g_rule_table(l_rule_index).use_carrier_ps = 'Y') AND l_found THEN
               IF (NVL(g_pskey_table(i).ship_method_code,'-1') <> NVL(p_ship_method_code,'-1')) THEN
                  l_found := FALSE;
               END IF;
            ELSE
-- HW replaced by NULL
               IF (g_pskey_table(i).ship_method_code <> NULL) THEN
                  l_found := FALSE;
               END IF;
            END IF;

            IF (g_rule_table(l_rule_index).use_ship_priority_ps = 'Y') AND l_found THEN
               IF (NVL(g_pskey_table(i).shipment_priority,'-1') <> NVL(p_shipment_priority,'-1')) THEN
                  l_found := FALSE;
               END IF;
            ELSE
-- HW replaced by NULL
               IF (g_pskey_table(i).shipment_priority <> NULL) THEN
                  l_found := FALSE;
               END IF;
            END IF;

            IF (g_rule_table(l_rule_index).use_trip_stop_ps = 'Y') AND l_found THEN
               IF (NVL(g_pskey_table(i).trip_stop_id,-1) <> NVL(p_trip_stop_id,-1)) THEN
                  l_found := FALSE;
                END IF;
            ELSE
-- HW replaced by NULL
               IF (g_pskey_table(i).trip_stop_id <> NULL) THEN
                  l_found := FALSE;
               END IF;
            END IF;

            IF (g_rule_table(l_rule_index).use_delivery_ps = 'Y') AND l_found THEN
               IF (NVL(g_pskey_table(i).delivery_id,-1) <> NVL(p_delivery_id,-1)) THEN
                  l_found := FALSE;
               END IF;
            ELSE
-- HW replaced by NULL
               IF (g_pskey_table(i).delivery_id <> NULL) THEN
                  l_found := FALSE;
               END IF;
            END IF;

            IF (g_rule_table(l_rule_index).use_item_ps = 'Y') AND l_found THEN
               IF (NVL(g_pskey_table(i).inventory_item_id,-1) <> NVL(p_inventory_item_id,-1)) THEN
                  l_found := FALSE;
               END IF;
            ELSE
-- HW replaced by NULL
               IF (g_pskey_table(i).inventory_item_id <> NULL) THEN
                  l_found := FALSE;
               END IF;
            END IF;
            IF (g_rule_table(l_rule_index).use_locator_ps = 'Y') AND l_found THEN
               IF (NVL(g_pskey_table(i).locator_id,-1) <> NVL(p_locator_id,-1)) THEN
                  l_found := FALSE;
               END IF;
            ELSE
-- HW replaced by NULL
               IF (g_pskey_table(i).locator_id <> NULL) THEN
                  l_found := FALSE;
               END IF;
            END IF;
            IF (g_rule_table(l_rule_index).use_lot_ps = 'Y') AND l_found THEN
               IF (NVL(g_pskey_table(i).lot_number,'-1') <> NVL(p_lot_number,'-1')) THEN
                  l_found := FALSE;
               END IF;
            ELSE
-- HW replaced by NULL
               IF (g_pskey_table(i).lot_number <> NULL) THEN
                  l_found := FALSE;
               END IF;
            END IF;
            IF (g_rule_table(l_rule_index).use_revision_ps = 'Y') AND l_found THEN
               IF (NVL(g_pskey_table(i).revision,'-1') <> NVL(p_revision,'-1')) THEN
                  l_found := FALSE;
               END IF;
            ELSE
-- HW replaced by NULL
               IF (g_pskey_table(i).revision <> NULL) THEN
                  l_found := FALSE;
               END IF;
            END IF;

            /*  Implicitly use organization */
            IF (NVL(g_pskey_table(i).organization_id,-1) <> NVL(p_org_id,-1)) THEN
               l_found := FALSE;
            END IF;

            /*  If found, get pick slip number and increment counter */
            IF l_found THEN
               x_pick_slip_number := g_pskey_table(i).pick_slip_number;
               g_pskey_table(i).counter := g_pskey_table(i).counter + 1;
               EXIT;
            END IF;
         END IF;

         EXIT WHEN i = g_pskey_table.last;
         i := g_pskey_table.next(i);
      END LOOP;

      IF l_found THEN
         /*  Print is immediate so check if limit has been reached */
         IF (p_ps_mode = 'I' AND l_limit <> -1) THEN
            IF (g_pskey_table(i).counter >= l_limit) THEN
                x_ready_to_print :=  FND_API.G_TRUE;
            END IF;
         END IF;
      ELSE
         /*  Insert new key */
         Insert_Key(p_rule_index        => l_rule_index,
                    p_header_id         => p_header_id,
                    p_customer_id       => p_customer_id,
                    p_ship_method_code  => p_ship_method_code,
                    p_ship_to_loc_id    => p_ship_to_loc_id,
                    p_shipment_priority => p_shipment_priority,
                    p_subinventory      => p_subinventory,
                    p_trip_stop_id      => p_trip_stop_id,
                    p_delivery_id       => p_delivery_id,
                    p_inventory_item_id => p_inventory_item_id,
                    p_locator_id        => p_locator_id,
                    p_lot_number        => p_lot_number,
                    p_revision          => p_revision,
                    p_org_id            => p_org_id,
                    x_pick_slip_number  => x_pick_slip_number  );
      END IF;

      x_api_status := FND_API.G_RET_STS_SUCCESS;
   EXCEPTION
      WHEN OTHERS THEN
         x_error_message := 'Error occurred in WSH_PR_PICK_NUMBER.Get_Pick_Slip_Number';
         x_api_status := FND_API.G_RET_STS_UNEXP_ERROR;

   END Get_Pick_Slip_Number;

/* ==================================================================
 |
 |  Name
 |    PROCEDURE Print_Pvt
 |
 |  Purpose
 |    Print Pick Slip based on Pick Slip Number
 |
 |  Input Parameter
 |    p_report_set_id    => report set
 |    p_pick_slip_number => pick slip number
 |
 |  Output Parameters
 |    x_api_status    => FND_API.G_RET_STS_SUCESSS or
 |                       FND_API.G_RET_STS_ERROR or
 |                       FND_API.G_RET_STS_UNEXP_ERROR
 ==================================================================*/
PROCEDURE Print_Pvt (
   p_report_set_id            IN  NUMBER,
	 p_organization_id          IN  NUMBER,
      p_pick_slip_number         IN  NUMBER,
      x_api_status               OUT NOCOPY VARCHAR2)
   IS
      l_report_set_id NUMBER;
      l_trip_ids      WSH_UTIL_CORE.Id_Tab_Type;
      l_stop_ids      WSH_UTIL_CORE.Id_Tab_Type;
      l_delivery_ids  WSH_UTIL_CORE.Id_Tab_Type;
      l_document_info WSH_DOCUMENT_SETS.document_set_tab_type;
	 l_organization_id NUMBER;
   BEGIN
      l_document_info(1).p_report_set_id := p_report_set_id;
      l_document_info(1).pick_slip_num_l := p_pick_slip_number;
      l_document_info(1).pick_slip_num_h := p_pick_slip_number;
      l_document_info(1).p_item_display := 'D';
      l_document_info(1).p_item_flex_code := 'MSTK';
      l_document_info(1).p_locator_flex_code :='MTLL';
      l_document_info(1).p_pick_status := 'A';

      l_organization_id := p_organization_id;

      WSH_UTIL_CORE.Println('calling WSH_UTIL_CORE.Print_Document_Sets');
      WSH_DOCUMENT_SETS.Print_Document_Sets(
         p_report_set_id       => l_report_set_id,
  	    p_organization_id     => l_organization_id,
         p_trip_ids            => l_trip_ids,
         p_stop_ids            => l_stop_ids,
         p_delivery_ids        => l_delivery_ids,
         p_document_param_info => l_document_info,
         x_return_status       => x_api_status);

   END Print_Pvt;

/* ========================================================================
 |
 |  Name
 |    PROCEDURE Insert_Key
 |
 |  Purpose
 |    Insert new key to table and returns newly generated pick slip number
 |
 |  Input Parameter
 |    p_rule_index         => index to the grouping rule table
 |    p_header_id          => order header id
 |    p_customer_id        => customer id
 |    p_ship_method_code   => ship method
 |    p_ship_to_loc_id     => ship to location
 |    p_shipment_priority  => shipment priority
 |    p_subinventory       => subinventory
 |    p_trip_stop_id       => trip stop
 |    p_delivery_id        => delivery
 |    p_inventory_item_id  => item
 |    p_locator_id         => locator
 |    p_lot_number         => lot number
 |    p_revision           => revision
 |    p_org_id             => organization
 |
 |  Output Parameter
 |    x_pick_slip_number   => pick_slip_number
 =============================================================== */

   PROCEDURE Insert_Key (
      p_rule_index                 IN      NUMBER,
      p_header_id                  IN      NUMBER,
      p_customer_id                IN      NUMBER,
      p_ship_method_code           IN      VARCHAR2,
      p_ship_to_loc_id             IN      NUMBER,
      p_shipment_priority          IN      VARCHAR2,
      p_subinventory               IN      VARCHAR2,
      p_trip_stop_id               IN      NUMBER,
      p_delivery_id                IN      NUMBER,
      p_inventory_item_id          IN      NUMBER,
      p_locator_id                 IN      NUMBER,
      p_lot_number                 IN      VARCHAR2,
      p_revision                   IN      VARCHAR2,
      p_org_id                     IN      NUMBER,
      x_pick_slip_number           OUT NOCOPY     NUMBER )
   IS
      l_tab_size     NUMBER;
   BEGIN
      SELECT WSH_PICK_SLIP_NUMBERS_S.NEXTVAL
      INTO x_pick_slip_number
      FROM DUAL;

      l_tab_size := NVL(g_pskey_table.last,0);
      g_pskey_table(l_tab_size+1).grouping_rule_id := g_rule_table(p_rule_index).grouping_rule_id;
      IF (g_rule_table(p_rule_index).use_order_ps = 'Y') THEN
         g_pskey_table(l_tab_size+1).header_id := p_header_id;
      END IF;
      IF (g_rule_table(p_rule_index).use_sub_ps = 'Y') THEN
         g_pskey_table(l_tab_size+1).subinventory := p_subinventory;
      END IF;
      IF (g_rule_table(p_rule_index).use_customer_ps = 'Y') THEN
         g_pskey_table(l_tab_size+1).customer_id := p_customer_id;
      END IF;
      IF (g_rule_table(p_rule_index).use_carrier_ps = 'Y') THEN
         g_pskey_table(l_tab_size+1).ship_method_code := p_ship_method_code;
      END IF;
      IF (g_rule_table(p_rule_index).use_ship_to_ps = 'Y') THEN
          g_pskey_table(l_tab_size+1).ship_to_loc_id := p_ship_to_loc_id;
      END IF;
      IF (g_rule_table(p_rule_index).use_ship_priority_ps = 'Y') THEN
         g_pskey_table(l_tab_size+1).shipment_priority := p_shipment_priority;
      END IF;
      IF (g_rule_table(p_rule_index).use_trip_stop_ps = 'Y') THEN
         g_pskey_table(l_tab_size+1).trip_stop_id := p_trip_stop_id;
      END IF;
      IF (g_rule_table(p_rule_index).use_delivery_ps = 'Y') THEN
         g_pskey_table(l_tab_size+1).delivery_id := p_delivery_id;
      END IF;

      IF (g_rule_table(p_rule_index).use_item_ps = 'Y') THEN
         g_pskey_table(l_tab_size+1).inventory_item_id := p_inventory_item_id;
      END IF;
      IF (g_rule_table(p_rule_index).use_locator_ps = 'Y') THEN
         g_pskey_table(l_tab_size+1).locator_id := p_locator_id;
      END IF;
      IF (g_rule_table(p_rule_index).use_lot_ps = 'Y') THEN
         g_pskey_table(l_tab_size+1).lot_number := p_lot_number;
      END IF;
      IF (g_rule_table(p_rule_index).use_revision_ps = 'Y') THEN
         g_pskey_table(l_tab_size+1).revision := p_revision;
      END IF;

      g_pskey_table(l_tab_size+1).organization_id := p_org_id;
      g_pskey_table(l_tab_size+1).pick_slip_number := x_pick_slip_number;
      g_pskey_table(l_tab_size+1).counter := 1;
   END Insert_Key;

END GMI_PR_PICK_SLIP_NUMBER;

/
