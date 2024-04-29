--------------------------------------------------------
--  DDL for Package Body WIP_DEFAULT_RES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_DEFAULT_RES" AS
/* $Header: WIPDRESB.pls 120.2.12010000.3 2009/12/29 21:56:32 hliew ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'WIP_Default_Res';

--  Package global used within the package.

--  The get_***_attr procedures populate the global variables listed
--  below.  When the get_<attr_name> procedure get called, they will
--  default from the global variables if they have been populated

g_Res_rec                     WIP_Transaction_PUB.Res_Rec_Type;
g_RCV_txn                     WIP_Transaction_PUB.Rcv_Txn_Type;
g_WIP_op_res                  WIP_Transaction_PUB.WIP_Op_Res_Type;
g_PO_Dstr                     WIP_Transaction_PUB.PO_Dist_Type;
g_Wip_Entities_rec            WIP_Work_Order_PUB.Wip_Entities_Rec_Type :=
                                WIP_Work_Order_PUB.G_MISS_WIP_ENTITIES_REC;
g_BOM_res                     WIP_Transaction_PUB.BOM_Resource_Type;

--  Get functions.

/* Private Procedure that will populate all the attributes from RCV_TRANSACTIONS_INTERFACE. Populating each attribute individually will be a performance hit, so call this procedure once */
PROCEDURE get_rti_attr
IS

   l_wip_entity_id              NUMBER := FND_API.G_MISS_NUM;
   l_wip_line_id                NUMBER := FND_API.G_MISS_NUM;
   l_wip_repetitive_schedule_id NUMBER := FND_API.G_MISS_NUM;
   l_wip_operation_seq_num      NUMBER := FND_API.G_MISS_NUM;
   l_wip_resource_seq_num       NUMBER := FND_API.G_MISS_NUM;
   l_transaction_date           DATE := FND_API.G_MISS_DATE;
   l_creation_date              DATE := FND_API.G_MISS_DATE;
   l_created_by                 NUMBER := FND_API.G_MISS_NUM;
   l_item_id                    NUMBER := FND_API.G_MISS_NUM;
   l_last_update_date           DATE := FND_API.G_MISS_DATE;
   l_last_updated_by            NUMBER := FND_API.G_MISS_NUM;
   l_last_update_login          NUMBER := FND_API.G_MISS_NUM;
   l_organization_id            NUMBER := FND_API.G_MISS_NUM;
   l_primary_unit_of_measure    VARCHAR2(25) := FND_API.G_MISS_CHAR;
   l_reason_id                  NUMBER := FND_API.G_MISS_NUM;
   l_source_doc_quantity        NUMBER := FND_API.G_MISS_NUM;
   l_source_doc_unit_of_measure VARCHAR2(25) := FND_API.G_MISS_CHAR;
   l_comments                   VARCHAR2(240) := FND_API.G_MISS_CHAR;
   l_quantity                   NUMBER :=  FND_API.G_MISS_NUM;
   l_unit_of_measure            VARCHAR2(25) := FND_API.G_MISS_CHAR;
   l_po_header_id               NUMBER := FND_API.G_MISS_NUM;
   l_po_line_id                 NUMBER := FND_API.G_MISS_NUM;
   l_po_unit_price              NUMBER := FND_API.G_MISS_NUM;
   l_currency_code              VARCHAR2(15) := FND_API.G_MISS_CHAR;
   l_currency_conversion_type   VARCHAR2(10) := FND_API.G_MISS_CHAR;
   l_currency_conversion_rate   NUMBER := FND_API.G_MISS_NUM;
   l_currency_conversion_date   DATE := FND_API.G_MISS_DATE;
BEGIN

   IF g_Res_rec.source_code = 'RCV'
     AND g_Res_rec.source_line_id IS NOT NULL THEN

      --dbms_output.put_line('osp.rcv_transaction_id = ' || g_Res_rec.rcv_transaction_id);

      SELECT wip_entity_id
        , wip_line_id
        , wip_repetitive_schedule_id
        , wip_operation_seq_num
        , wip_resource_seq_num
        , transaction_date
        , creation_date
        , created_by
        , item_id
        , last_update_date
        , last_updated_by
        , last_update_login
        , to_organization_id
        , reason_id
        , source_doc_unit_of_measure
        , comments
        , po_header_id
        , po_line_id
        , po_unit_price
        , quantity
        , unit_of_measure
        , primary_unit_of_measure
        , currency_code
        , currency_conversion_type
        , currency_conversion_rate
        , currency_conversion_date
        INTO l_wip_entity_id
        , l_wip_line_id
        , l_wip_repetitive_schedule_id
        , l_wip_operation_seq_num
        , l_wip_resource_seq_num
        , l_transaction_date
        , l_creation_date
        , l_created_by
        , l_item_id
        , l_last_update_date
        , l_last_updated_by
        , l_last_update_login
        , l_organization_id
        , l_reason_id
        , l_source_doc_unit_of_measure
        , l_comments
        , l_po_header_id
        , l_po_line_id
        , l_po_unit_price
        , l_quantity
        , l_unit_of_measure
        , l_primary_unit_of_measure
        , l_currency_code
        , l_currency_conversion_type
        , l_currency_conversion_rate
        , l_currency_conversion_date
        FROM RCV_TRANSACTIONS_INTERFACE
        WHERE interface_transaction_id = g_Res_rec.source_line_id;


      IF g_RCV_txn.quantity IS NULL THEN
         g_RCV_txn.quantity := l_quantity;
      END IF;
      IF g_RCV_txn.unit_of_measure IS NULL THEN
         g_RCV_txn.unit_of_measure := l_unit_of_measure;
      END IF;
      IF g_RCV_txn.wip_entity_id IS NULL THEN
         g_RCV_txn.Wip_Entity_Id := l_wip_entity_id;
      END IF;
      IF g_RCV_txn.wip_line_id IS NULL THEN
         g_RCV_txn.wip_line_Id   := l_wip_line_id;
      END IF;
      IF g_RCV_txn.wip_repetitive_schedule_id IS NULL THEN
         g_RCV_txn.wip_repetitive_schedule_id := l_wip_repetitive_schedule_id;
      END IF;
      IF g_RCV_txn.wip_operation_seq_num IS NULL THEN
         g_RCV_txn.wip_operation_seq_num := l_wip_operation_seq_num;
      END IF;
      IF g_RCV_txn.wip_resource_seq_num IS NULL THEN
         g_RCV_txn.wip_resource_seq_Num := l_wip_resource_seq_num;
      END IF;
      IF g_RCV_txn.transaction_date IS NULL THEN
         g_RCV_txn.Transaction_Date := l_transaction_date;
      END IF;
      IF g_RCV_txn.creation_date IS NULL THEN
         g_RCV_txn.Creation_Date := l_creation_date;
      END IF;
      IF g_RCV_txn.created_by IS NULL THEN
         g_RCV_txn.Created_By := l_created_by;
      END IF;
      IF g_RCV_txn.item_id IS NULL THEN
         g_RCV_txn.item_id := l_item_id;
      END IF;
      IF g_RCV_txn.last_update_date IS NULL THEN
         g_RCV_txn.Last_Update_Date := l_last_update_date;
      END IF;
      IF g_RCV_txn.last_updated_by IS NULL THEN
         g_RCV_txn.Last_Updated_By := l_last_updated_by;
      END IF;
      IF g_RCV_txn.last_update_login IS NULL THEN
         g_RCV_txn.Last_Update_Login := l_last_update_login;
      END IF;
      IF g_RCV_txn.organization_id IS NULL THEN
         g_RCV_txn.Organization_Id := l_organization_id;
      END IF;
      IF g_RCV_txn.reason_id IS NULL THEN
         g_RCV_txn.Reason_Id := l_reason_id;
      END IF;
      IF g_RCV_txn.source_doc_unit_of_measure IS NULL THEN
         g_RCV_txn.source_doc_unit_of_measure := l_source_doc_unit_of_measure;
      END IF;
      IF g_RCV_txn.comments IS NULL THEN
         g_RCV_txn.comments := l_comments;
      END IF;
      IF g_RCV_txn.po_header_id IS NULL THEN
         g_RCV_txn.Po_Header_Id := l_po_header_id;
      END IF;
      IF g_RCV_txn.po_line_id IS NULL THEN
         g_RCV_txn.Po_Line_Id := l_po_line_id;
      END IF;
      IF g_RCV_txn.po_unit_price IS NULL THEN
         g_RCV_txn.Po_unit_price := l_po_unit_price;
      END IF;
      IF g_RCV_txn.primary_unit_of_measure IS NULL THEN
         g_RCV_txn.primary_unit_of_measure := l_primary_unit_of_measure;
      END IF;
      IF g_RCV_txn.currency_code IS NULL THEN
         g_RCV_txn.Currency_Code := l_currency_code;
      END IF;
      IF g_RCV_txn.currency_conversion_type IS NULL THEN
         g_RCV_txn.currency_conversion_type := l_currency_conversion_type;
      END IF;
      IF g_RCV_txn.currency_conversion_rate IS NULL THEN
         g_RCV_txn.currency_conversion_rate := l_currency_conversion_rate;
      END IF;
      IF g_RCV_txn.currency_conversion_date IS NULL THEN
         g_RCV_txn.currency_conversion_date := l_currency_conversion_date;
      END IF;

   END IF;

EXCEPTION
   WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg('WIP_Default_Res', 'get_rti_attr');
END get_rti_attr;



/* Private Procedure that will populate all the attributes from WIP_OPERATION_RESOURCES. Populating each attribute individually will be a performance hit, so call this procedure in all the attributes it populates.  */

PROCEDURE get_wor_attr
  IS
     l_activity_id             NUMBER := FND_API.G_MISS_NUM;
     l_resource_id             NUMBER := FND_API.G_MISS_NUM;
     l_usage_rate_or_amount    NUMBER := FND_API.G_MISS_NUM;
     l_basis_type              NUMBER := FND_API.G_MISS_NUM;
     l_autocharge_type         NUMBER := FND_API.G_MISS_NUM;
     l_uom_code                VARCHAR2(3) := FND_API.G_MISS_CHAR;
     l_std_rate_flag           NUMBER := FND_API.G_MISS_NUM;

BEGIN

   IF g_Res_rec.wip_entity_id IS NOT NULL
     AND g_Res_rec.operation_seq_num IS NOT NULL
     AND g_Res_rec.resource_seq_num IS NOT NULL
     AND g_Res_rec.organization_id IS NOT NULL
     THEN

      SELECT activity_id
        , resource_id
        , usage_rate_or_amount
        , basis_type
        , autocharge_type
        , uom_code
        , standard_rate_flag
        INTO l_activity_id
        , l_resource_id
        , l_usage_rate_or_amount
        , l_basis_type
        , l_autocharge_type
        , l_uom_code
        , l_std_rate_flag
        FROM wip_operation_resources
        WHERE wip_entity_id = g_Res_rec.wip_entity_id
        AND   organization_id = g_Res_rec.organization_id
        AND   operation_seq_num = g_Res_rec.operation_seq_num
        AND   resource_seq_num = g_Res_rec.resource_seq_num
        AND   (repetitive_schedule_id IS NULL
               OR repetitive_schedule_id = g_Res_rec.repetitive_schedule_id);


      IF g_WIP_op_res.activity_id IS NULL THEN
         g_WIP_op_res.activity_id := l_activity_id;
      END IF;
      IF g_WIP_op_res.resource_id IS NULL THEN
         g_WIP_op_res.resource_id := l_resource_id;
      END IF;
      IF g_WIP_op_res.usage_rate_or_amount IS NULL THEN
         g_WIP_op_res.usage_rate_or_amount := l_usage_rate_or_amount;
      END IF;
      IF g_WIP_op_res.basis_type IS NULL THEN
         g_WIP_op_res.basis_type := l_basis_type;
      END IF;
      IF g_WIP_op_res.autocharge_type IS NULL THEN
         g_WIP_op_res.autocharge_type := l_autocharge_type;
      END IF;
      IF g_WIP_op_res.uom_code IS NULL THEN
         g_WIP_op_res.uom_code := l_uom_code;
      END IF;
      IF g_WIP_op_res.uom_code IS NULL THEN
         g_WIP_op_res.uom_code := l_uom_code;
      END IF;
      IF g_WIP_op_res.std_rate_flag IS NULL THEN
         g_WIP_op_res.std_rate_flag := l_std_rate_flag;
      END IF;

   END IF;

EXCEPTION
   WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg('WIP_Default_Res', 'get_wor_attr');
END get_wor_attr;


PROCEDURE get_we_attr
IS
BEGIN

   IF g_Res_rec.wip_entity_id IS NOT NULL THEN

      g_Wip_Entities_rec := WIP_Wip_Entities_Util.Query_Row(g_Res_rec.wip_entity_id);

   END IF;

EXCEPTION
   WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg('WIP_Default_Res', 'get_we_attr');
END get_we_attr;


PROCEDURE get_pd_attr
IS
   l_project_id         NUMBER  := FND_API.G_MISS_NUM;
   l_task_id            NUMBER  := FND_API.G_MISS_NUM;
   l_nonrecoverable_tax NUMBER  := FND_API.G_MISS_NUM;
   l_quantity_ordered   NUMBER  := FND_API.G_MISS_NUM;
   l_po_uom             VARCHAR2(25) := FND_API.G_MISS_CHAR;
BEGIN

   IF g_Res_rec.source_code = 'RCV'
     AND g_Res_rec.source_line_id IS NOT NULL THEN

      SELECT pd.project_id
        , pd.task_id
        , nonrecoverable_tax
        , quantity_ordered
        INTO l_project_id
        , l_task_id
        , l_nonrecoverable_tax
        , l_quantity_ordered
        FROM po_distributions_all pd,
        rcv_transactions_interface rti
        WHERE rti.po_distribution_id = pd.po_distribution_id
        AND   rti.interface_transaction_id = g_Res_rec.source_line_id;

      IF g_PO_Dstr.project_id IS NULL THEN
         g_PO_Dstr.project_id := l_project_id;
      END IF;
      IF g_PO_Dstr.task_id IS NULL THEN
         g_PO_Dstr.task_id := l_task_id;
      END IF;
      IF g_PO_Dstr.nonrecoverable_tax IS NULL THEN
         g_PO_Dstr.nonrecoverable_tax := nvl(l_nonrecoverable_tax, 0 );
      END IF;
      IF g_PO_Dstr.primary_quantity_ordered IS NULL THEN

         IF g_RCV_txn.item_id IS NULL
          OR g_RCV_txn.primary_unit_of_measure IS NULL
          OR g_RCV_txn.po_line_id IS NULL THEN
                get_rti_attr();
         END IF;

         /* get the uom that was used on the Purchase Order */
         select UNIT_MEAS_LOOKUP_CODE
         into l_po_uom
         from po_lines_all
         where po_line_id = g_RCV_txn.po_line_id;

        /*
           Fixed Bug#2139994. Changed g_RCV_txn.quantity to l_quantity_ordered
           in the from_quantity parameter
        */

         g_PO_Dstr.primary_quantity_ordered :=
                inv_convert.inv_um_convert(
                        item_id         => g_RCV_txn.item_id,
                        precision       => NULL,
                        from_quantity   => l_quantity_ordered,
                        from_unit       => NULL,
                        to_unit         => NULL,
                        from_name       => l_po_uom,
                        to_name         => g_RCV_txn.primary_unit_of_measure
                        );
      END IF;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg('WIP_Default_Res', 'get_pd_attr');
END get_pd_attr;

PROCEDURE get_br_attr
IS
   l_resource_code VARCHAR2(10) := FND_API.G_MISS_CHAR;
   l_resource_type NUMBER       := FND_API.G_MISS_NUM;
BEGIN

   IF g_Res_rec.resource_id IS NOT NULL THEN

      SELECT resource_code
        , resource_type
        INTO l_resource_code
        , l_resource_type
        FROM bom_resources br
        WHERE br.resource_id = g_Res_rec.resource_id;

      IF g_BOM_res.resource_code IS NULL THEN
         g_BOM_res.resource_code := l_resource_code;
      END IF;
      IF g_BOM_res.resource_type IS NULL THEN
         g_BOM_res.resource_type := l_resource_type;
      END IF;

   END IF;

EXCEPTION
   WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg('WIP_Default_Res', 'get_br_attr');
END get_br_attr;

FUNCTION Get_Acct_Period
RETURN NUMBER
IS
  l_acct_period_id      NUMBER;
  l_open_past_period    BOOLEAN;
BEGIN

   IF g_Res_rec.acct_period_id IS NOT NULL THEN
      RETURN g_Res_rec.acct_period_id;
   END IF;

   IF ( ( ( g_Res_rec.source_code = 'RCV'
            AND g_Res_rec.source_line_id IS NOT NULL )
         OR g_Res_rec.source_code = 'SFCB'
        )
       AND g_Res_rec.transaction_date IS NOT NULL
       AND g_Res_rec.organization_id IS NOT NULL
     )
     THEN

   /* Remove for timezone support in J
      SELECT oap.acct_period_id
        INTO   l_acct_period_id
        FROM   org_acct_periods oap
        WHERE  oap.organization_id = g_Res_rec.organization_id
        AND    oap.period_close_date is null
        AND    trunc(g_Res_rec.transaction_date) between
               trunc(oap.period_start_date) and
               trunc(oap.schedule_close_date);
    */

      invttmtx.tdatechk(org_id => g_Res_rec.organization_id,
                     transaction_date => g_Res_rec.transaction_date,
                     period_id => l_acct_period_id,
                     open_past_period => l_open_past_period );

      RETURN l_acct_period_id;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Acct_Period;

FUNCTION Get_Activity
RETURN NUMBER
IS
   l_activity_id NUMBER := FND_API.G_MISS_NUM;
BEGIN

   IF g_Res_rec.activity_id IS NOT NULL THEN
      RETURN g_Res_rec.activity_id;
   END IF;

   IF g_WIP_op_res.activity_id IS NOT NULL THEN
      RETURN g_WIP_op_res.activity_id;
   ELSE
      get_wor_attr();
      RETURN g_WIP_op_res.activity_id;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Activity;

FUNCTION Get_Activity_Name
RETURN VARCHAR2
IS
BEGIN

   IF g_Res_rec.activity_name IS NOT NULL THEN
      RETURN g_Res_rec.activity_name;
   END IF;

   IF g_Res_rec.activity_id IS NOT NULL then

      SELECT activity
        INTO g_Res_rec.activity_name
        FROM cst_activities
        WHERE activity_id = g_Res_rec.activity_id;

      RETURN g_Res_rec.activity_name;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_Activity_Name;

FUNCTION Get_Actual_Resource_Rate
RETURN NUMBER
IS
  l_actual_resource_rate              NUMBER := FND_API.G_MISS_NUM;
  l_uom_basis  VARCHAR2(25);
  l_uom_code   VARCHAR2(3);
  l_po_uom     VARCHAR2(25) ;
  l_po_unit_price NUMBER;
  l_conversion_factor NUMBER;
  l_currency_conversion_rate NUMBER;
  l_tax_amount        NUMBER;
  l_resource_qty_ordered NUMBER ;
  l_po_qty NUMBER := 1 ;
BEGIN

  IF g_Res_rec.actual_resource_rate IS NOT NULL THEN
    RETURN g_Res_rec.actual_resource_rate;
  END IF;

  IF g_Res_rec.source_code = 'RCV'
    AND g_Res_rec.source_line_id IS NOT NULL THEN
      IF g_RCV_txn.item_id IS NOT NULL
        OR g_RCV_txn.organization_id IS NOT NULL THEN
          get_rti_attr();
      END IF;

      SELECT msi.outside_operation_uom_type
      INTO l_uom_basis
      FROM mtl_system_items msi
      WHERE msi.inventory_item_id = g_RCV_txn.item_id
      AND   msi.organization_id = g_RCV_txn.organization_id;

     /* Fixed for Bug#2031267 */

      IF g_po_dstr.nonrecoverable_tax IS NULL
          OR g_po_dstr.primary_quantity_ordered IS NULL THEN
             get_pd_attr();
      END IF;

    /* Fixed for Bug#2917061  */

      if l_uom_basis = 'ASSEMBLY' AND g_Res_rec.usage_rate_or_amount <> 0 then
             l_resource_qty_ordered := g_po_dstr.primary_quantity_ordered * g_Res_rec.usage_rate_or_amount ;
      else
             l_resource_qty_ordered := g_po_dstr.primary_quantity_ordered  ;
      end if ;

      /* Fix for Bug#2139994 */

      l_tax_amount := nvl((g_po_dstr.nonrecoverable_tax/l_resource_qty_ordered) , 0) ;

       /* Fix for Bug# 2396342 */

       select UNIT_MEAS_LOOKUP_CODE
       into l_po_uom
       from po_lines_all
       where po_line_id = g_RCV_txn.po_line_id;

      if l_po_uom  <> g_RCV_txn.primary_unit_of_measure then
         l_conversion_factor  := inv_convert.inv_um_convert
                                     (g_RCV_txn.item_id,
                                      NULL,
                                      1,
                                      NULL,
                                      NULL,
                                      g_RCV_txn.primary_unit_of_measure,
                                      l_po_uom
                                     );
      else
        l_conversion_factor := 1 ;
      end if ;

      /* return null when inv_um_convert can't convert */

      if l_conversion_factor = -99999 then
                RETURN FND_API.G_MISS_NUM;
      end if ;

      l_po_unit_price := g_RCV_txn.po_unit_price  * l_conversion_factor ;


      IF l_uom_basis = 'ASSEMBLY' THEN

        IF g_Res_rec.transaction_quantity IS NOT NULL
          AND g_Res_rec.usage_rate_or_amount IS NOT NULL
          AND g_RCV_txn.po_unit_price IS NOT NULL
          AND g_RCV_txn.unit_of_measure IS NOT NULL THEN

          /* Fix for bug 4155822: Divide by l_po_unit_price by g_Res_rec.usage_rate_or_amount only if
             g_Res_rec.usage_rate_or_amount is not 0 or NULL. */
          IF (g_Res_rec.usage_rate_or_amount  IS NOT NULL AND g_Res_rec.usage_rate_or_amount  <> 0) THEN
             l_actual_resource_rate := (l_po_unit_price / g_Res_rec.usage_rate_or_amount) + l_tax_amount ;
          ELSE
              /* Usage rate is zero */
              /* Fix for bug 4155822: Need not multiply with PO quantity since we multiply with
                 resource primary quantity to get the cost later
              SELECT rti.primary_quantity
              INTO   l_po_qty
              FROM   mtl_system_items msi, rcv_transactions_interface rti
              WHERE  msi.inventory_item_id = rti.item_id
              AND    msi.organization_id = rti.to_organization_id
              AND    rti.interface_transaction_id = g_Res_rec.source_line_id; */

              l_actual_resource_rate := l_po_unit_price + l_tax_amount ;

             /*Fix for bug 8601418. comment following code to prevent negative l_actual_resource_rate
                IF g_Res_rec.action = WIP_Transaction_PUB.G_ACT_OSP_RET_TO_RCV OR
                g_Res_rec.action = WIP_Transaction_PUB.G_ACT_OSP_RET_TO_VEND OR
                g_Res_rec.action = WIP_Transaction_PUB.G_ACT_OSP_CORRECT_TO_RCV  THEN
                l_actual_resource_rate := -l_actual_resource_rate;
             END IF;*/
          END IF;
        END IF;
      ELSIF g_RCV_txn.po_unit_price IS NOT NULL then
        l_actual_resource_rate := l_po_unit_price + l_tax_amount ;
      END IF;
   -- Fixed bug 5248437. This is a regression from 4232353. That fix override
   -- the fix from bug 3418605. Basically, we should use currency conversion
   -- rate in g_res_rec if available.
      l_currency_conversion_rate := nvl(g_res_rec.currency_conversion_rate,
                                        nvl(g_RCV_txn.currency_conversion_rate,
                                            -1));
      IF l_currency_conversion_rate = -1 THEN
        RETURN l_actual_resource_rate;
      ELSE
        /* Fix for bug 3138121: actual resource rate will be rounded by extended
          precision value instead of minimum accountable unit or precision */
        select round(l_actual_resource_rate,nvl(fc.extended_precision,5))
          into l_actual_resource_rate
          from fnd_currencies fc
          where currency_code = g_RCV_txn.currency_code;

        RETURN l_actual_resource_rate * l_currency_conversion_rate;
      END IF;

   ELSE /* default */
     IF (g_Res_rec.employee_id IS NOT NULL AND
         g_Res_rec.organization_id IS NOT NULL) THEN

        select we.hourly_labor_rate
        into l_actual_resource_rate
        from wip_employee_labor_rates we
        where we.employee_id = g_Res_rec.employee_id
        and we.organization_id = g_Res_rec.organization_id
        and we.effective_date = (select max(we1.effective_date)
                                 from wip_employee_labor_rates we1
                                 where we1.effective_date < sysdate
                                 and we1.employee_id = g_Res_rec.employee_id
                                 and we1.organization_id = g_Res_rec.organization_id);

        return l_actual_resource_rate;
     END IF;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Actual_Resource_Rate;

FUNCTION Get_Autocharge_Type
RETURN NUMBER
IS
BEGIN

   IF g_Res_rec.autocharge_type IS NOT NULL THEN
      RETURN g_Res_rec.autocharge_type;
   END IF;

   IF g_Res_rec.source_code = 'SFCB' THEN
      RETURN (WIP_CONSTANTS.MANUAL) ;
   END IF;

   IF g_WIP_op_res.autocharge_type IS NOT NULL THEN
      RETURN g_WIP_op_res.autocharge_type;
   ELSE
      get_wor_attr();
      RETURN g_WIP_op_res.autocharge_type;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Autocharge_Type;

FUNCTION Get_Basis_Type
RETURN NUMBER
IS
BEGIN

   IF g_Res_rec.basis_type IS NOT NULL THEN
      RETURN g_Res_rec.basis_type;
   END IF;

   IF g_WIP_op_res.basis_type IS NOT NULL THEN
      RETURN g_WIP_op_res.basis_type;
   ELSE
      get_wor_attr();
      RETURN g_WIP_op_res.basis_type;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Basis_Type;

FUNCTION Get_Completion_Transaction
RETURN NUMBER
IS
BEGIN

   IF g_Res_rec.completion_transaction_id IS NOT NULL THEN
      RETURN g_Res_rec.completion_transaction_id;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Completion_Transaction;

FUNCTION Get_Created_By
RETURN VARCHAR2
IS
BEGIN

   IF g_Res_rec.created_by IS NOT NULL THEN
      RETURN g_Res_rec.created_by;
   END IF;

   IF g_Res_rec.source_code = 'RCV'
     AND g_Res_rec.source_line_id IS NOT NULL THEN

      IF g_RCV_txn.created_by IS NOT NULL THEN
         RETURN g_RCV_txn.created_by;
      ELSE
         get_rti_attr();
         RETURN g_RCV_txn.created_by;
      END IF;

   END IF;

   RETURN fnd_global.user_id ;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_Created_By;


FUNCTION Get_Created_By_Name
RETURN VARCHAR2
IS
BEGIN

   IF g_Res_rec.created_by_name IS NOT NULL THEN
      RETURN g_Res_rec.created_by_name;
   END IF;

   IF g_Res_rec.created_by IS NOT NULL THEN
      SELECT user_name
        INTO g_Res_rec.created_by_name
        FROM fnd_user
        WHERE user_id = g_Res_rec.created_by;

      RETURN g_Res_rec.created_by_name;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_Created_By_Name;

FUNCTION Get_Creation_Date
RETURN DATE /*Fix bug 8971751(FP 8933207)*/
IS
BEGIN

   IF g_Res_rec.creation_date IS NOT NULL THEN
      RETURN g_Res_rec.creation_date;
   END IF;

   IF g_Res_rec.source_code = 'RCV'
     AND g_Res_rec.source_line_id IS NOT NULL THEN

      IF g_RCV_txn.creation_date IS NOT NULL THEN
         RETURN g_RCV_txn.creation_date;
      ELSE
         get_rti_attr();
         RETURN g_RCV_txn.creation_date;
      END IF;

   END IF;

   RETURN sysdate ;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_DATE;

END Get_Creation_Date;


FUNCTION Get_Currency_Actual_Rsc_Rate
RETURN NUMBER
IS
BEGIN

   IF g_Res_rec.currency_actual_rsc_rate IS NOT NULL THEN
      RETURN g_Res_rec.currency_actual_rsc_rate;
   END IF;
   -- Fixed bug 5248437. This is a regression from 4232353. That fix override
   -- the fix from bug 3418605. Basically, we should use currency conversion
   -- rate in g_res_rec if available.
   IF (g_Res_rec.source_code = 'RCV' AND
       nvl(g_res_rec.currency_conversion_rate,
           g_RCV_txn.currency_conversion_rate) is not NULL) then
     IF ( g_Res_rec.actual_resource_rate IS NOT NULL ) THEN
       return (g_Res_rec.actual_resource_rate /
               nvl(g_res_rec.currency_conversion_rate,
                   g_RCV_txn.currency_conversion_rate));
     END IF;
   ELSE
     return NULL;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Currency_Actual_Rsc_Rate;

FUNCTION Get_Currency
RETURN VARCHAR2
IS
BEGIN

   IF g_Res_rec.currency_code IS NOT NULL THEN
      RETURN g_Res_rec.currency_code;
   END IF;


   IF g_Res_rec.source_code = 'RCV'
     AND g_Res_rec.source_line_id IS NOT NULL THEN

      IF g_RCV_txn.currency_code IS NOT NULL THEN
         RETURN g_RCV_txn.currency_code;
      ELSE
         get_rti_attr();
         RETURN g_RCV_txn.currency_code;
      END IF;

   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Currency;

FUNCTION Get_Currency_Conversion_Date
RETURN DATE
IS
BEGIN

   IF g_Res_rec.currency_conversion_date IS NOT NULL THEN
      RETURN g_Res_rec.currency_conversion_date;
   END IF;

   IF g_Res_rec.source_code = 'RCV'
     AND g_Res_rec.source_line_id IS NOT NULL THEN

      IF g_RCV_txn.currency_conversion_date IS NOT NULL THEN
         RETURN g_RCV_txn.currency_conversion_date;
      ELSE
         get_rti_attr();
         RETURN g_RCV_txn.currency_conversion_date;
      END IF;

   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_DATE;
END Get_Currency_Conversion_Date;

FUNCTION Get_Currency_Conversion_Rate
RETURN NUMBER
IS
BEGIN

   IF g_Res_rec.currency_conversion_rate IS NOT NULL THEN
      RETURN g_Res_rec.currency_conversion_rate;
   END IF;

   IF g_Res_rec.source_code = 'RCV'
     AND g_Res_rec.source_line_id IS NOT NULL THEN

      IF g_RCV_txn.currency_conversion_rate IS NOT NULL THEN
         RETURN g_RCV_txn.currency_conversion_rate;
      ELSE
         get_rti_attr();
         RETURN g_RCV_txn.currency_conversion_rate;
      END IF;

   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Currency_Conversion_Rate;

FUNCTION Get_Currency_Conversion_Type
RETURN VARCHAR2
IS
BEGIN

   IF g_Res_rec.currency_conversion_type IS NOT NULL THEN
      RETURN g_Res_rec.currency_conversion_type;
   END IF;

   IF g_Res_rec.source_code = 'RCV'
     AND g_Res_rec.source_line_id IS NOT NULL THEN

      IF g_RCV_txn.currency_conversion_type IS NOT NULL THEN
         RETURN g_RCV_txn.currency_conversion_type;
      ELSE
         get_rti_attr();
         RETURN g_RCV_txn.currency_conversion_type;
      END IF;

   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Currency_Conversion_Type;

FUNCTION Get_Department_Code
RETURN VARCHAR2
IS
   l_dept_code  VARCHAR2(10);
BEGIN

   IF g_Res_rec.department_code IS NOT NULL THEN
      RETURN g_Res_rec.department_code;
   END IF;

   IF g_Res_rec.department_id IS NOT NULL then

         SELECT department_code
           INTO l_dept_code
           FROM bom_departments
           WHERE department_id = g_Res_rec.department_id;

           RETURN l_dept_code;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_Department_Code;

FUNCTION Get_Department_Id
RETURN NUMBER
IS
   l_dept_id    NUMBER;
BEGIN

   IF g_Res_rec.department_id IS NOT NULL THEN
      RETURN g_Res_rec.department_id;
   END IF;

   IF g_Res_rec.wip_entity_id IS NOT NULL
     AND g_Res_rec.operation_seq_num IS NOT NULL
     AND g_Res_rec.operation_seq_num IS NOT NULL THEN
           SELECT department_id
           INTO   l_dept_id
           FROM   wip_operations
           WHERE  wip_entity_id = g_Res_rec.wip_entity_id
           AND    operation_seq_num = g_Res_rec.operation_seq_num
           AND    organization_id = g_Res_rec.organization_id
           AND    (repetitive_schedule_id IS NULL
                  OR repetitive_schedule_id = g_Res_rec.repetitive_schedule_id);

           RETURN l_dept_id;
      END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Department_Id;

FUNCTION Get_Employee
RETURN NUMBER
IS
BEGIN

   IF g_Res_rec.employee_id IS NOT NULL THEN
      RETURN g_Res_rec.employee_id;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Employee;

FUNCTION Get_Employee_Num
RETURN VARCHAR2
IS
BEGIN

   IF g_Res_rec.employee_num IS NOT NULL THEN
      RETURN g_Res_rec.employee_num;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_Employee_Num;

FUNCTION Get_Entity_Type
RETURN NUMBER
IS
BEGIN

   IF g_Res_rec.entity_type IS NOT NULL THEN
      RETURN g_Res_rec.entity_type;
   END IF;

   IF g_wip_entities_rec.Entity_Type IS NOT NULL THEN
      RETURN g_wip_entities_rec.Entity_Type;
   ELSE
      get_we_attr();
      RETURN g_wip_entities_rec.Entity_Type;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Entity_Type;

FUNCTION Get_Group
RETURN NUMBER
IS
BEGIN

   IF g_Res_rec.group_id IS NOT NULL THEN
      RETURN g_Res_rec.group_id;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Group;

FUNCTION Get_Last_Updated_By
RETURN VARCHAR2
IS
BEGIN

   IF g_Res_rec.last_updated_by IS NOT NULL THEN
      RETURN g_Res_rec.last_updated_by;
   END IF;

   IF g_Res_rec.source_code = 'RCV'
     AND g_Res_rec.source_line_id IS NOT NULL THEN

      IF g_RCV_txn.last_updated_by IS NOT NULL THEN
         RETURN g_RCV_txn.last_updated_by;
      ELSE
         get_rti_attr();
         RETURN g_RCV_txn.last_updated_by;
      END IF;

   END IF;

   RETURN fnd_global.user_id ;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_Last_Updated_By;

FUNCTION Get_Last_Updated_By_Name
RETURN VARCHAR2
IS
BEGIN

   IF g_Res_rec.last_updated_by_name IS NOT NULL THEN
      RETURN g_Res_rec.last_updated_by_name;
   END IF;

   IF g_Res_rec.last_updated_by IS NOT NULL THEN
      SELECT user_name
        INTO g_Res_rec.last_updated_by_name
        FROM fnd_user
        WHERE user_id = g_Res_rec.last_updated_by;

      RETURN g_Res_rec.last_updated_by_name;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_Last_Updated_By_Name;

FUNCTION Get_Last_Update_Date
RETURN DATE /*Fix Bug 8971751(FP 8933207)*/
IS
BEGIN

   IF g_Res_rec.last_update_date IS NOT NULL THEN
      RETURN g_Res_rec.last_update_date;
   END IF;

   IF g_Res_rec.source_code = 'RCV'
     AND g_Res_rec.source_line_id IS NOT NULL THEN

     IF g_RCV_txn.last_update_date IS NOT NULL THEN
        RETURN g_RCV_txn.last_update_date;
     ELSE
        get_rti_attr();
        RETURN g_RCV_txn.last_update_date;
     END IF;

   END IF;

   RETURN sysdate ;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_Last_Update_Date;


FUNCTION Get_Line_Code
RETURN VARCHAR2
IS
   l_line_code  VARCHAR2(10);
BEGIN

   IF g_Res_rec.line_code IS NOT NULL THEN
      RETURN g_Res_rec.line_code;
   END IF;

   IF g_Res_rec.line_id IS NOT NULL
    AND g_Res_rec.organization_id IS NOT NULL THEN
      SELECT line_code
        INTO l_line_code
        FROM wip_lines
        WHERE line_id = g_Res_rec.line_id
        AND   organization_id = g_Res_rec.organization_id;

      RETURN l_line_code;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_Line_Code;

FUNCTION Get_Line_Id
RETURN NUMBER
IS
BEGIN

   IF g_Res_rec.line_id IS NOT NULL THEN
      RETURN g_Res_rec.line_id;
   END IF;

   IF g_Res_rec.source_code = 'RCV'
     AND g_Res_rec.source_line_id IS NOT NULL THEN

      IF g_RCV_txn.wip_line_id IS NOT NULL THEN
         RETURN g_RCV_txn.wip_line_id;
      ELSE
         get_rti_attr();
         RETURN g_RCV_txn.wip_line_id;
      END IF;

   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Line_Id;

FUNCTION Get_Move_Transaction
RETURN NUMBER
IS
BEGIN

   IF g_Res_rec.move_transaction_id IS NOT NULL THEN
      RETURN g_Res_rec.move_transaction_id;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Move_Transaction;

FUNCTION Get_Operation_Seq_Num
RETURN NUMBER
IS
BEGIN

   IF g_Res_rec.operation_seq_num IS NOT NULL THEN
      RETURN g_Res_rec.operation_seq_num;
   END IF;

   IF g_Res_rec.source_code = 'RCV'
     AND g_Res_rec.source_line_id IS NOT NULL THEN

      IF g_RCV_txn.wip_operation_seq_num IS NOT NULL THEN
         RETURN g_RCV_txn.wip_operation_seq_num;
      ELSE
         get_rti_attr();
         RETURN g_RCV_txn.wip_operation_seq_num;
      END IF;

   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Operation_Seq_Num;

FUNCTION Get_Organization_Code
RETURN VARCHAR2
IS
BEGIN

   IF g_Res_rec.organization_code IS NOT NULL THEN
      RETURN g_Res_rec.organization_code;
   END IF;

   IF g_Res_rec.organization_id IS NOT NULL THEN
      SELECT organization_code
        INTO g_Res_rec.organization_code
        FROM mtl_parameters
        WHERE organization_id = g_Res_rec.organization_id;

      RETURN g_Res_rec.organization_code;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_Organization_Code;

FUNCTION Get_Organization_Id
RETURN NUMBER
IS
BEGIN

   IF g_Res_rec.organization_id IS NOT NULL THEN
      RETURN g_Res_rec.organization_id;
   END IF;

   IF g_Res_rec.source_code = 'RCV'
     AND g_Res_rec.source_line_id IS NOT NULL THEN

      IF g_RCV_txn.organization_id IS NOT NULL THEN
         RETURN g_RCV_txn.organization_id;
      ELSE
         get_rti_attr();
         RETURN g_RCV_txn.organization_id;
      END IF;

   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Organization_Id;

FUNCTION Get_Po_Header
RETURN NUMBER
IS
BEGIN

   IF g_Res_rec.po_header_id IS NOT NULL THEN
      RETURN g_Res_rec.po_header_id;
   END IF;

   IF g_Res_rec.source_code = 'RCV'
     AND g_Res_rec.source_line_id IS NOT NULL THEN

      IF g_RCV_txn.po_header_id IS NOT NULL THEN
         RETURN g_RCV_txn.po_header_id;
      ELSE
         get_rti_attr();
         RETURN g_RCV_txn.po_header_id;
      END IF;

   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Po_Header;

FUNCTION Get_Po_Line
RETURN NUMBER
IS
BEGIN

   IF g_Res_rec.po_line_id IS NOT NULL THEN
      RETURN g_Res_rec.po_line_id;
   END IF;

   IF g_Res_rec.source_code = 'RCV'
     AND g_Res_rec.source_line_id IS NOT NULL THEN

      IF g_RCV_txn.po_line_id IS NOT NULL THEN
         RETURN g_RCV_txn.po_line_id;
      ELSE
         get_rti_attr();
         RETURN g_RCV_txn.po_line_id;
      END IF;

   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Po_Line;

FUNCTION Get_Primary_Item
RETURN NUMBER
IS
BEGIN

   IF g_Res_rec.primary_item_id IS NOT NULL THEN
      RETURN g_Res_rec.primary_item_id;
   END IF;

   IF g_wip_entities_rec.primary_item_id IS NOT NULL THEN
      RETURN g_wip_entities_rec.primary_item_id;
   ELSE
      get_we_attr();
      RETURN g_wip_entities_rec.primary_item_id;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Primary_Item;

FUNCTION Get_Primary_Quantity
RETURN NUMBER
IS
BEGIN

   IF g_Res_rec.primary_quantity IS NOT NULL THEN
      RETURN g_Res_rec.primary_quantity;
   END IF;

   IF g_Res_rec.source_code IN ('RCV', 'SFCB') THEN
      RETURN g_Res_rec.transaction_quantity;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Primary_Quantity;

FUNCTION Get_Primary_Uom
RETURN VARCHAR2
IS
BEGIN

   IF g_Res_rec.primary_uom IS NOT NULL THEN
      RETURN g_Res_rec.primary_uom;
   END IF;

   IF g_WIP_op_res.uom_code IS NOT NULL THEN
      RETURN g_WIP_op_res.uom_code;
   ELSE
      get_wor_attr();
      RETURN g_WIP_op_res.uom_code;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_Primary_Uom;

FUNCTION Get_Primary_Uom_Class
RETURN VARCHAR2
IS
BEGIN

   IF g_Res_rec.primary_uom_class IS NOT NULL THEN
      RETURN g_Res_rec.primary_uom_class;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_Primary_Uom_Class;

FUNCTION Get_Process_Phase
RETURN NUMBER
IS
BEGIN

   IF g_Res_rec.process_phase IS NOT NULL THEN
      RETURN g_Res_rec.process_phase;
   END IF;

   IF  g_Res_rec.source_code = 'RCV'
   AND g_Res_rec.source_line_id IS NOT NULL
   THEN
      RETURN (WIP_CONSTANTS.RES_VAL);
   END IF;

   IF g_Res_rec.source_code = 'SFCB'
   THEN
      RETURN (WIP_CONSTANTS.RES_PROC);
   END IF;


   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Process_Phase;

FUNCTION Get_Process_Status
RETURN NUMBER
IS
BEGIN

   IF g_Res_rec.process_status IS NOT NULL THEN
      RETURN g_Res_rec.process_status;
   END IF;

   IF g_Res_rec.source_code = 'RCV'
     AND g_Res_rec.source_line_id IS NOT NULL
     THEN
      RETURN (WIP_CONSTANTS.PENDING);
   END IF;

   IF g_Res_rec.source_code = 'SFCB'
   THEN
      RETURN (WIP_CONSTANTS.PENDING);
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Process_Status;

FUNCTION Get_Project
RETURN NUMBER
IS
BEGIN

   IF g_Res_rec.project_id IS NOT NULL THEN
      RETURN g_Res_rec.project_id;
   END IF;

   IF g_Res_rec.source_code = 'RCV'
     AND g_Res_rec.source_line_id IS NOT NULL THEN

      IF g_PO_Dstr.project_id IS NOT NULL THEN
         RETURN g_PO_Dstr.project_id;
      ELSE
         get_pd_attr();
         RETURN g_PO_Dstr.project_id;
      END IF;

   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Project;

FUNCTION Get_Rcv_Transaction
RETURN NUMBER
IS
BEGIN

   IF g_Res_rec.rcv_transaction_id IS NOT NULL THEN
      RETURN g_Res_rec.rcv_transaction_id;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Rcv_Transaction;

FUNCTION Get_Reason
RETURN NUMBER
IS
BEGIN

   IF g_Res_rec.reason_id IS NOT NULL THEN
      RETURN g_Res_rec.reason_id;
   END IF;

   IF g_Res_rec.source_code = 'RCV'
     AND g_Res_rec.source_line_id IS NOT NULL THEN

      IF g_RCV_txn.reason_id IS NOT NULL THEN
         RETURN g_RCV_txn.reason_id;
      ELSE
         get_rti_attr();
         RETURN g_RCV_txn.reason_id;
      END IF;

   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Reason;

FUNCTION Get_Reason_Name
RETURN VARCHAR2
IS
l_reason_name   VARCHAR2(30);
BEGIN

   IF g_Res_rec.reason_name IS NOT NULL THEN
      RETURN g_Res_rec.reason_name;
   END IF;

   IF g_Res_rec.reason_id IS NOT NULL then

         SELECT reason_name
           INTO l_reason_name
           FROM mtl_transaction_reasons
           WHERE reason_id = g_Res_rec.reason_id;

           RETURN l_reason_name;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_Reason_Name;

FUNCTION Get_Receiving_Account
RETURN NUMBER
IS
BEGIN

   IF g_Res_rec.receiving_account_id IS NOT NULL THEN
      RETURN g_Res_rec.receiving_account_id;
   END IF;

   IF g_Res_rec.source_code = 'RCV'
     AND g_Res_rec.organization_id IS NOT NULL THEN

      SELECT   rp.receiving_account_id
        INTO   g_Res_rec.receiving_account_id
        FROM   rcv_parameters rp
        WHERE  rp.organization_id = g_Res_rec.organization_id;

      RETURN g_Res_rec.receiving_account_id;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Receiving_Account;

FUNCTION Get_Reference
RETURN VARCHAR2
IS
BEGIN

   IF g_Res_rec.reference IS NOT NULL THEN
      RETURN g_Res_rec.reference;
   END IF;

   IF g_Res_rec.source_code = 'RCV'
     AND g_Res_rec.source_line_id IS NOT NULL THEN

      IF g_RCV_txn.comments IS NOT NULL THEN
         RETURN g_RCV_txn.comments;
      ELSE
         get_rti_attr();
         RETURN g_RCV_txn.comments;
      END IF;

   END IF;

    RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_Reference;

FUNCTION Get_Repetitive_Schedule
RETURN NUMBER
IS
BEGIN

   IF g_Res_rec.repetitive_schedule_id IS NOT NULL THEN
      RETURN g_Res_rec.repetitive_schedule_id;
   END IF;

   IF g_Res_rec.source_code = 'RCV'
     AND g_Res_rec.source_line_id IS NOT NULL THEN

      IF g_RCV_txn.wip_repetitive_schedule_id IS NOT NULL THEN
         RETURN g_RCV_txn.wip_repetitive_schedule_id;
      ELSE
         get_rti_attr();
         RETURN g_RCV_txn.wip_repetitive_schedule_id;
      END IF;

   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Repetitive_Schedule;

FUNCTION Get_Resource_Code
RETURN VARCHAR2
IS
BEGIN

   IF g_Res_rec.resource_code IS NOT NULL THEN
      RETURN g_Res_rec.resource_code;
   END IF;

   IF g_BOM_res.resource_code IS NOT NULL THEN
        return g_BOM_res.resource_code;
   END IF;

   IF g_Res_rec.resource_id IS NOT NULL then
      get_br_attr();
      RETURN g_BOM_res.resource_code;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_Resource_Code;

FUNCTION Get_Resource_Id
RETURN NUMBER
IS
BEGIN

   IF g_Res_rec.resource_id IS NOT NULL THEN
      RETURN g_Res_rec.resource_id;
   END IF;

   IF g_WIP_op_res.resource_id IS NOT NULL THEN
      RETURN g_WIP_op_res.resource_id;
   ELSE
      get_wor_attr();
      RETURN g_WIP_op_res.resource_id;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Resource_Id;

FUNCTION Get_Resource_Seq_Num
RETURN NUMBER
IS
BEGIN

   IF g_Res_rec.resource_seq_num IS NOT NULL THEN
      RETURN g_Res_rec.resource_seq_num;
   END IF;

   IF g_Res_rec.source_code = 'RCV'
     AND g_Res_rec.source_line_id IS NOT NULL THEN

      IF g_RCV_txn.wip_resource_seq_num IS NOT NULL THEN
         RETURN g_RCV_txn.wip_resource_seq_num;
      ELSE
         get_rti_attr();
         RETURN g_RCV_txn.wip_resource_seq_num;
      END IF;

   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Resource_Seq_Num;

FUNCTION Get_Resource_Type
RETURN NUMBER
IS
BEGIN

   IF g_Res_rec.resource_type IS NOT NULL THEN
      RETURN g_Res_rec.resource_type;
   END IF;

   IF g_BOM_res.resource_type IS NOT NULL THEN
        return g_BOM_res.resource_type;
   END IF;

   IF g_Res_rec.resource_id IS NOT NULL then
      get_br_attr();
      RETURN g_BOM_res.resource_type;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;
END Get_Resource_Type;

FUNCTION Get_Source
RETURN VARCHAR2
IS
BEGIN

   IF g_Res_rec.source_code IS NOT NULL THEN
      RETURN g_Res_rec.source_code;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Source;

FUNCTION Get_Source_Line
RETURN NUMBER
IS
BEGIN

   IF g_Res_rec.source_line_id IS NOT NULL THEN
      RETURN g_Res_rec.source_line_id;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Source_Line;

FUNCTION Get_Standard_Rate
RETURN NUMBER
IS
BEGIN

   IF g_Res_rec.standard_rate_flag IS NOT NULL THEN
      RETURN g_Res_rec.standard_rate_flag;
   END IF;

   IF g_WIP_op_res.std_rate_flag IS NOT NULL THEN
      RETURN g_WIP_op_res.std_rate_flag;
   ELSE
      get_wor_attr();
      RETURN g_WIP_op_res.std_rate_flag;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Standard_Rate;

FUNCTION Get_Task
RETURN NUMBER
IS
BEGIN

   IF g_Res_rec.task_id IS NOT NULL THEN
      RETURN g_Res_rec.task_id;
   END IF;

   IF g_Res_rec.source_code = 'RCV'
     AND g_Res_rec.source_line_id IS NOT NULL
     THEN
      IF g_PO_Dstr.task_id IS NOT NULL THEN
         RETURN g_PO_Dstr.task_id;
      ELSE
         get_pd_attr();
         RETURN g_PO_Dstr.task_id;
      END IF;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Task;

FUNCTION Get_Transaction_Date
RETURN DATE
IS
BEGIN

   IF g_Res_rec.transaction_date IS NOT NULL THEN
      RETURN g_Res_rec.transaction_date;
   END IF;

   IF g_Res_rec.source_code = 'RCV'
     AND g_Res_rec.source_line_id IS NOT NULL THEN

      IF g_RCV_txn.transaction_date IS NOT NULL THEN
         RETURN g_RCV_txn.transaction_date;
      ELSE
         get_rti_attr();
         RETURN g_RCV_txn.transaction_date;
      END IF;

   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_DATE;

END Get_Transaction_Date;

FUNCTION Get_Transaction
RETURN NUMBER
IS
BEGIN

   IF g_Res_rec.transaction_id IS NOT NULL THEN
      RETURN g_Res_rec.transaction_id;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Transaction;

FUNCTION Get_Transaction_Quantity
RETURN NUMBER
IS
   l_uom_basis  VARCHAR2(25);
   l_po_qty     NUMBER;
BEGIN

   IF g_Res_rec.transaction_quantity IS NOT NULL THEN
      RETURN g_Res_rec.transaction_quantity;
   END IF;

   IF g_Res_rec.source_code = 'RCV'
     AND g_Res_rec.source_line_id IS NOT NULL
     THEN

      -- Calculate the transaction quantity.

      SELECT msi.outside_operation_uom_type, rti.primary_quantity
        INTO l_uom_basis, l_po_qty
        FROM mtl_system_items msi, rcv_transactions_interface rti
        WHERE msi.inventory_item_id = rti.item_id
        AND   msi.organization_id = rti.to_organization_id
        AND   rti.interface_transaction_id = g_Res_rec.source_line_id;

      IF l_uom_basis = 'ASSEMBLY' THEN
        /* Fix for bug 4155822: Added condition usage rate or amount <> 0 */
        IF (    g_Res_rec.usage_rate_or_amount IS NOT NULL
            AND g_Res_rec.usage_rate_or_amount <> 0) THEN
          g_Res_rec.transaction_quantity := l_po_qty*g_Res_rec.usage_rate_or_amount;
        ELSE
          g_Res_rec.transaction_quantity := l_po_qty;
        END IF;
       ELSIF l_uom_basis = 'RESOURCE' THEN
         g_Res_rec.transaction_quantity := l_po_qty;
      ELSE
         RETURN NULL;
      END IF;

      IF g_Res_rec.action = WIP_Transaction_PUB.G_ACT_OSP_RET_TO_RCV
        OR g_Res_rec.action = WIP_Transaction_PUB.G_ACT_OSP_RET_TO_VEND
        OR g_Res_rec.action = WIP_Transaction_PUB.G_ACT_OSP_CORRECT_TO_RCV
        THEN
         g_Res_rec.transaction_quantity := -1* g_Res_rec.transaction_quantity;
      END IF;

      RETURN g_Res_rec.transaction_quantity;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Transaction_Quantity;

FUNCTION Get_Transaction_Type
RETURN NUMBER
IS
BEGIN

   IF g_Res_rec.transaction_type IS NOT NULL THEN
      RETURN g_Res_rec.transaction_type;
   END IF;

   IF g_Res_rec.source_code = 'RCV'
     AND g_Res_rec.source_line_id IS NOT NULL
     THEN
      RETURN WIP_CONSTANTS.OSP_TXN;
   END IF;

   IF g_Res_rec.source_code = 'SFCB'
   THEN
      RETURN (WIP_CONSTANTS.RES_TXN);
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Transaction_Type;

FUNCTION Get_Transaction_Uom
RETURN VARCHAR2
IS
BEGIN

   IF g_Res_rec.transaction_uom IS NOT NULL THEN
      RETURN g_Res_rec.transaction_uom;
   END IF;

   IF g_WIP_op_res.uom_code IS NOT NULL THEN
      RETURN g_WIP_op_res.uom_code;
   ELSE
      get_wor_attr();
      RETURN g_WIP_op_res.uom_code;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_Transaction_Uom;

FUNCTION Get_Usage_Rate_Or_Amount
RETURN NUMBER
IS
BEGIN

   IF g_Res_rec.usage_rate_or_amount IS NOT NULL THEN
      RETURN g_Res_rec.usage_rate_or_amount;
   END IF;

   IF g_WIP_op_res.usage_rate_or_amount IS NOT NULL THEN
      RETURN g_WIP_op_res.usage_rate_or_amount;
   ELSE
      get_wor_attr();
      RETURN g_WIP_op_res.usage_rate_or_amount;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Usage_Rate_Or_Amount;

FUNCTION Get_Wip_Entity
RETURN NUMBER
IS
BEGIN

   IF g_Res_rec.wip_entity_id IS NOT NULL THEN
      RETURN g_Res_rec.wip_entity_id;
   END IF;

   IF g_Res_rec.source_code = 'RCV'
     AND g_Res_rec.source_line_id IS NOT NULL THEN

      IF g_RCV_txn.wip_entity_id IS NOT NULL THEN
         RETURN g_RCV_txn.wip_entity_id;
      ELSE
         get_rti_attr();
         RETURN g_RCV_txn.wip_entity_id;
      END IF;

   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_NUM;

END Get_Wip_Entity;

FUNCTION Get_Wip_Entity_Name
RETURN VARCHAR2
IS
BEGIN

   IF g_Res_rec.wip_entity_name IS NOT NULL THEN
      RETURN g_Res_rec.wip_entity_name;
   END IF;

   IF g_wip_entities_rec.wip_entity_name IS NOT NULL THEN
      RETURN g_wip_entities_rec.wip_entity_name;
   ELSE
      get_we_attr();
      RETURN g_wip_entities_rec.wip_entity_name;
   END IF;

   RETURN NULL;

EXCEPTION
   WHEN OTHERS THEN
      RETURN FND_API.G_MISS_CHAR;

END Get_Wip_Entity_Name;

PROCEDURE Get_Flex_Res
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_Res_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_Res_rec.attribute1           := NULL;
    END IF;

    IF g_Res_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_Res_rec.attribute10          := NULL;
    END IF;

    IF g_Res_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_Res_rec.attribute11          := NULL;
    END IF;

    IF g_Res_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_Res_rec.attribute12          := NULL;
    END IF;

    IF g_Res_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_Res_rec.attribute13          := NULL;
    END IF;

    IF g_Res_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_Res_rec.attribute14          := NULL;
    END IF;

    IF g_Res_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_Res_rec.attribute15          := NULL;
    END IF;

    IF g_Res_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_Res_rec.attribute2           := NULL;
    END IF;

    IF g_Res_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_Res_rec.attribute3           := NULL;
    END IF;

    IF g_Res_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_Res_rec.attribute4           := NULL;
    END IF;

    IF g_Res_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_Res_rec.attribute5           := NULL;
    END IF;

    IF g_Res_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_Res_rec.attribute6           := NULL;
    END IF;

    IF g_Res_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_Res_rec.attribute7           := NULL;
    END IF;

    IF g_Res_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_Res_rec.attribute8           := NULL;
    END IF;

    IF g_Res_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_Res_rec.attribute9           := NULL;
    END IF;

    IF g_Res_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        g_Res_rec.attribute_category   := NULL;
    END IF;

END Get_Flex_Res;

--  Procedure Attributes
PROCEDURE Attributes
(   p_Res_rec                       IN  WIP_Transaction_PUB.Res_Rec_Type
,   p_iteration                     IN  NUMBER := NULL
,   x_Res_rec                       IN OUT NOCOPY WIP_Transaction_PUB.Res_Rec_Type
)
IS
BEGIN

    --  Check number of iterations.

    IF nvl(p_iteration,1) > WIP_GLOBALS.G_MAX_DEF_ITERATIONS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_DEF_MAX_ITERATION');
            FND_MSG_PUB.Add;

        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --  Initialize global variables

    g_Res_rec := WIP_Transaction_PUB.G_MISS_RES_REC;
    g_RCV_txn := WIP_Transaction_PUB.G_MISS_RCV_TXN_REC;
    g_WIP_op_res := WIP_Transaction_PUB.G_MISS_WIP_OP_RES_REC;
    g_PO_Dstr := WIP_Transaction_PUB.G_MISS_PO_DIST_REC;
    g_Wip_Entities_rec := WIP_Work_Order_PUB.G_MISS_WIP_ENTITIES_REC;
    g_BOM_res := WIP_Transaction_PUB.G_MISS_BOM_RES_REC;

    g_Res_rec := p_Res_rec;

    --  Default missing attributes.

    g_Res_rec.wip_entity_id := Get_Wip_Entity;
    g_Res_rec.wip_entity_name := Get_Wip_Entity_Name;
    g_Res_rec.primary_item_id := Get_Primary_Item;
    g_Res_rec.line_id := Get_Line_Id;
    g_Res_rec.operation_seq_num := Get_Operation_Seq_Num;
    g_Res_rec.organization_id := Get_Organization_Id;
    g_Res_rec.po_header_id := Get_Po_Header;
    g_Res_rec.po_line_id := Get_Po_Line;
    g_Res_rec.reason_id := Get_Reason;
    g_Res_rec.reference := Get_Reference;
    g_Res_rec.repetitive_schedule_id := Get_Repetitive_Schedule;
    g_Res_rec.resource_seq_num := Get_Resource_Seq_Num;
    g_Res_rec.transaction_date := Get_Transaction_Date;
    g_Res_rec.acct_period_id := Get_Acct_Period;
    g_Res_rec.activity_id := Get_Activity;
    g_Res_rec.resource_id := Get_Resource_Id;
    g_Res_rec.usage_rate_or_amount := Get_Usage_Rate_Or_Amount;
    g_Res_rec.basis_type := Get_Basis_Type;
    g_Res_rec.autocharge_type := Get_Autocharge_Type;
    g_Res_rec.primary_uom := Get_Primary_Uom;
    g_Res_rec.transaction_uom := Get_Transaction_Uom;
    g_Res_rec.standard_rate_flag := Get_Standard_Rate;
    g_Res_rec.project_id := Get_Project;
    g_Res_rec.task_id := Get_Task;
    g_Res_rec.activity_name := Get_Activity_Name;
    g_Res_rec.transaction_quantity := Get_Transaction_Quantity;
    g_Res_rec.primary_quantity := Get_Primary_Quantity;
    g_Res_rec.currency_code := Get_Currency;
    g_Res_rec.currency_conversion_date := Get_Currency_Conversion_Date;
    g_Res_rec.currency_conversion_rate := Get_Currency_Conversion_Rate;
    g_Res_rec.actual_resource_rate := Get_Actual_Resource_Rate;
    g_Res_rec.currency_conversion_type := Get_Currency_Conversion_Type;
    g_Res_rec.currency_actual_rsc_rate := Get_Currency_Actual_Rsc_Rate;
    g_Res_rec.department_id := Get_Department_Id;
    g_Res_rec.department_code := Get_Department_Code;
    g_Res_rec.entity_type := Get_Entity_Type;
    g_Res_rec.created_by := Get_Created_By;
    g_Res_rec.created_by_name := Get_Created_By_Name;
    g_Res_rec.last_updated_by := Get_Last_Updated_By;
    g_Res_rec.last_updated_by_name := Get_Last_Updated_By_Name;
    g_Res_rec.line_code := Get_Line_Code;
    g_Res_rec.organization_code := Get_Organization_Code;
    g_Res_rec.process_phase := Get_Process_Phase;
    g_Res_rec.process_status := Get_Process_Status;
    g_Res_rec.reason_name := Get_Reason_Name;
    g_Res_rec.resource_code := Get_Resource_Code;
    g_Res_rec.resource_type := Get_Resource_Type;
    g_Res_rec.transaction_type := Get_Transaction_Type;
    g_Res_rec.last_update_date := Get_Last_Update_Date;
    g_Res_rec.creation_date := Get_Creation_Date;

    IF g_Res_rec.created_by IS NULL THEN
        g_Res_rec.created_by := NULL;
    END IF;

    IF g_Res_rec.creation_date IS NULL THEN
        g_Res_rec.creation_date := Sysdate;
    END IF;

    IF g_Res_rec.last_updated_by IS NULL THEN
        g_Res_rec.last_updated_by := NULL;
    END IF;

    IF g_Res_rec.last_update_date IS NULL THEN
        g_Res_rec.last_update_date := Sysdate;
    END IF;

    IF g_Res_rec.last_update_login IS NULL THEN
        g_Res_rec.last_update_login := NULL;
    END IF;

    IF g_Res_rec.program_application_id IS NULL THEN
       --FND_PROFILE.Get('CONC_PROGRAM_APPLICATION_ID',g_Res_rec.program_application_id);
       g_Res_rec.program_application_id := NULL;
    END IF;

    IF g_Res_rec.program_id IS NULL THEN
       --FND_PROFILE.Get('CONC_PROGRAM_ID', g_Res_rec.program_id);
       g_Res_rec.program_id := NULL;
    END IF;

    IF g_Res_rec.program_update_date IS NULL THEN
        g_Res_rec.program_update_date := Sysdate;
    END IF;

    IF g_Res_rec.request_id IS NULL THEN
       --FND_PROFILE.Get('CONC_REQUEST_ID', g_Res_rec.request_id);
       g_Res_rec.request_id:= NULL;
    END IF;

    x_Res_rec := g_Res_rec;
END Attributes;

END WIP_Default_Res;

/
