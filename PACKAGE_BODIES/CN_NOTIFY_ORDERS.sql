--------------------------------------------------------
--  DDL for Package Body CN_NOTIFY_ORDERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_NOTIFY_ORDERS" AS
-- $Header: cnnooeb.pls 120.10 2005/12/19 22:27:01 apink ship $


G_PKG_NAME          CONSTANT VARCHAR2(30) := 'CN_NOTIFY_ORDERS';
G_SOURCE_DOC_TYPE   CONSTANT VARCHAR2(2) := 'OC';

--*********************************************
-- Private Procedures
--*********************************************

------------------------------------------------------------------+

-- Function Name
--   check_header_exists
-- Purpose
--   This function will check whether a particular header exsits in
--   cn_not_trx.  It returns true if yes, otherwise return false.
-- History

	FUNCTION check_header_exists(hid	NUMBER,
								 p_org_id NUMBER)
	RETURN 	varchar2
	IS

	exist       varchar2(1) := 'N';

	BEGIN

		SELECT	'Y'
		INTO 	exist
		FROM 	sys.dual
		WHERE 	EXISTS
			(SELECT 1
			 FROM 	cn_not_trx
			 WHERE 	source_trx_id = hid
			 AND 	org_id = p_org_id);

		RETURN exist;

	EXCEPTION

		WHEN NO_DATA_FOUND
		THEN
		RETURN exist;

	END check_header_exists;
---------------------------------------------------------------------------+
-- Procedure Name
--   unequal
-- Purpose
--   Overlayed procedures to check for inequality, allowing for the
--   possibility of NULL values
---------------------------------------------------------------------------+
FUNCTION unequal(
         p_lhs VARCHAR2,
	    p_rhs VARCHAR2) RETURN BOOLEAN IS
BEGIN
    IF p_lhs <> p_rhs
       OR (p_lhs IS NULL AND p_rhs IS NOT NULL)
       OR (p_lhs IS NOT NULL AND p_rhs IS NULL) THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END unequal;

FUNCTION unequal(
         p_lhs NUMBER,
	    p_rhs NUMBER) RETURN BOOLEAN IS
BEGIN
    IF p_lhs <> p_rhs
       OR (p_lhs IS NULL AND p_rhs IS NOT NULL)
       OR (p_lhs IS NOT NULL AND p_rhs IS NULL) THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END unequal;


-----------------------------------------------------------------------+
-- Function Name
--   check_last_entry
-- Purpose
--   This function will check the last entry of a particular line in
--   cn_not_trx.  It returns the status of its collected_flag.
-- History

	FUNCTION check_last_entry(hid NUMBER,
				      		  lid NUMBER,
							  x_org_id IN NUMBER)
	RETURN VARCHAR2
	IS
 		col_flag       VARCHAR2(1) := 'Y';
	BEGIN

-- We need to use CN_NOT_TRX_ALL instead of CN_NOT_TRX because this
-- procedure is being called by Adjust_Order, which processes orders
-- from all orgs. This should be OK because we are selecting based on
-- header_id, which for Orders are unique identifiers across all orgs.

    SELECT collected_flag
      INTO col_flag
      FROM cn_not_trx_all a
     WHERE a.source_trx_id = hid
       AND a.source_trx_line_id = lid
       AND a.org_id = x_org_id
       AND a.not_trx_id = (	SELECT max(b.not_trx_id)
				  FROM cn_not_trx_all b
				 WHERE b.source_trx_id = hid
				   AND b.source_trx_line_id = lid
				   AND b.org_id = a.org_id );

    RETURN col_flag;

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      RETURN col_flag;

  END check_last_entry;


---------------------------------------------------------------------------+
-- Procedure Name
--   notify_line
-- Purpose
--   This procedure collects order line identifiers into cn_not_trx
--   as part of order update notification.
--
--   Note. Whereas Regular_Col_Notify is run for each Org, Notify_Line
--   is part of the Update Notification process, of which there is only
--   one instance for the installation - because we only have one
--   Notification  Queue which passes us updates to orders from any Org.
--   This means that new rows inserted into CN_NOT_TRX_ALL must get the
--   Org_Id of the updated order rather than just defaulting to the
--   client Org-Id. (The defaulting is OK in regular_col_notify because
--   that procedure only selects orders for the Client Org anyway). For
--   this reason, we use CN_NOT_TRX_ALL here, rather than just CN_NOT_TRX
--   and we explicitly set the Org_Id during our insert.

-- History
--
  PROCEDURE notify_line (
	p_header_id	NUMBER,
	p_line_id		NUMBER,
	p_adj_flag	VARCHAR2 := 'Y',
	x_org_id NUMBER ) IS

    l_trx_count 	NUMBER;
    l_proc_audit_id	NUMBER;
    l_rowid		ROWID;
     l_sys_batch_size NUMBER;
     CURSOR batch_size IS SELECT system_batch_size FROM cn_repositories WHERE org_id = x_org_id;

  BEGIN

    cn_message_pkg.debug('notify: adjust: entering notify_line (lid = '||p_line_id||') ');
    fnd_file.put_line(fnd_file.Log, 'notify: adjust: entering notify_line (lid = '||p_line_id||') ');

    cn_process_audits_pkg.insert_row
	( l_rowid, l_proc_audit_id, NULL, 'NOT', 'Notification run',
	  NULL, NULL, NULL, NULL, NULL, SYSDATE, NULL, x_org_id);

	  --Added as per MOAC OE Mandate
	  MO_GLOBAL.SET_POLICY_CONTEXT ('S', x_org_id);
    OPEN batch_size;
    FETCH batch_size INTO l_sys_batch_size;
    CLOSE batch_size;

    -- Call to Check_Last_Entry makes sure that there is not
    -- already a 'to-be-collected' record for the line in CN_NOT_TRX_ALL.
    IF Check_Last_Entry
                     (p_header_id,
                      p_line_id,
                      x_org_id) = 'Y' THEN
      INSERT INTO cn_not_trx_all (
        org_id,
        not_trx_id,
        batch_id,
        notified_date,
        processed_date,
        notification_run_id,
        collected_flag,
        row_id,
        source_trx_id,
        source_trx_line_id,
	   source_doc_type,
        adjusted_flag,
        event_id)
      SELECT
        asoh.org_id,
        cn_not_trx_s.NEXTVAL,
        FLOOR(cn_not_trx_s.CURRVAL/NVL(l_sys_batch_size,200)),
        SYSDATE,
        asoh.booked_date,
        l_proc_audit_id,
        'N',
        asoh.rowid,
        asoh.header_id,
        asol.line_id,
	   g_source_doc_type,
        p_adj_flag,
        cn_global.ord_event_id
      FROM
        aso_i_oe_order_headers_v asoh,
        aso_i_oe_order_lines_v asol
      WHERE
        asoh.header_id = p_header_id
        AND asoh.booked_flag = 'Y'              -- only interested in status of booked
	   -- NOTE: asoh.header_id is a primary key, so no need to
	   -- have an org filter for the join to asol
        AND asol.header_id = asoh.header_id
        AND asol.line_id = p_line_id
        AND asol.org_id = x_org_id -- R12 MOAC Changes
        AND asoh.org_id = asol.org_id -- R12 MOAC Changes
-- also collect 'RETURN's        AND asol.line_category_code = 'ORDER'   -- only collect 'Order' lines
        AND EXISTS
		  (SELECT 1
		  FROM mtl_system_items mtl
		  WHERE
                --+
                -- Because this procedure is looking at orders for any
                -- org_id, we have to get the inventory organization for
                -- the org_id of the order, by passing that org_id into
                -- our call to OE_PROFILE.VALUE.
                --+
			 NVL(mtl.organization_id,NVL(oe_profile.value('OE_ORGANIZATION_ID',asoh.org_id),-99)) =
                    NVL(oe_profile.value('OE_ORGANIZATION_ID',asoh.org_id),-99)
                AND mtl.inventory_item_id = asol.inventory_item_id
                AND mtl.invoiceable_item_flag = 'Y');     -- only want invoiceable items
      cn_message_pkg.debug('notify: adjust: .  notified');
      fnd_file.put_line(fnd_file.Log, 'notify: adjust: .  notified');
    END IF;

    cn_message_pkg.debug('notify: adjust: exit from notify_line (lid = '||p_line_id||')');
    fnd_file.put_line(fnd_file.Log, 'notify: adjust: exit from notify_line (lid = '||p_line_id||')');
  END notify_line;



---------------------------------------------------------------------------+
-- Procedure Name
--   notify_deleted_line
-- Purpose
--   This procedure collects order line identifiers for deleted lines
--   into cn_not_trx as part of order update notification.
--
--   When a collected order is changed, all of the old lines are reversed
--   out and all current lines for the order are added in again. This
--   procedure is used to register the Id of a deleted line so that it
--   will be reversed.We cannot use notify_line for this because that procedure
--   is also used for new lines and therefore runs a query using line information
--   to see if that line is eligible. This infomration is no longer avaliable
--   for a deleted line.
--
-- History
--   11-01-99	D.Maskell  Created

  PROCEDURE notify_deleted_line (
	p_header_id	NUMBER,
	p_line_id	     NUMBER,
	p_org_id NUMBER) IS

	l_proc_audit_id NUMBER;
     l_rowid		ROWID;
     l_org_id NUMBER;
     l_sys_batch_size NUMBER;
     CURSOR batch_size IS SELECT system_batch_size FROM cn_repositories WHERE org_id = p_org_id;

  BEGIN

    cn_message_pkg.debug('notify: adjust: entering notify_deleted_line (lid = '||p_line_id||')');
    fnd_file.put_line(fnd_file.Log, 'notify: adjust: entering notify_deleted_line (lid = '||p_line_id||')');


	  l_org_id := p_org_id;

    cn_process_audits_pkg.insert_row
	( l_rowid, l_proc_audit_id, NULL, 'NOT', 'Notification run',
	  NULL, NULL, NULL, NULL, NULL, SYSDATE, NULL, p_org_id);
    OPEN batch_size;
    FETCH batch_size INTO l_sys_batch_size;
    CLOSE batch_size;

    -- Call to Check_Last_Entry makes sure that there is not
    -- already a 'to-be-collected' record for the line in CN_NOT_TRX_ALL.
    IF Check_Last_Entry
                     (p_header_id,
                      p_line_id,
                      l_org_id) = 'Y' THEN
      INSERT INTO cn_not_trx_all (
		 org_id,
	     not_trx_id,
	     batch_id,
	     notified_date,
	     processed_date,
	     notification_run_id,
	     collected_flag,
	     row_id,
	     source_trx_id,
	     source_trx_line_id,
	     source_doc_type,
	     adjusted_flag,
	     event_id)
      SELECT
		 asoh.org_id,
	     cn_not_trx_s.NEXTVAL,
	     FLOOR(cn_not_trx_s.CURRVAL/NVL(l_sys_batch_size,200)),
	     SYSDATE,
	     asoh.booked_date,
	     l_proc_audit_id,
          'N',
	     asoh.rowid,
	     asoh.header_id,
	     p_line_id,
	     g_source_doc_type,
	     'Y',
	     cn_global.ord_event_id
      FROM
          aso_i_oe_order_headers_v asoh
      WHERE
          asoh.header_id = p_header_id
          AND asoh.booked_flag = 'Y'
		  AND asoh.org_id = l_org_id;              -- only interested in status of booked
      cn_message_pkg.debug('notify: adjust: .  notified');
      fnd_file.put_line(fnd_file.Log, 'notify: adjust: .  notified');
    END IF;

    cn_message_pkg.debug('exit from notify_deleted_line (lid = '||p_line_id||')');
    fnd_file.put_line(fnd_file.Log, 'exit from notify_deleted_line (lid = '||p_line_id||')');
  END notify_deleted_line;

---------------------------------------------------------------------------+
-- Procedure Name
--   notify_affected_lines
-- Purpose
--   This procedure collects order line identifiers into cn_not_trx_all
--   of lines affected by a change to an order sales credit.
--   Design Note: A Top Model Line will have its own line_id in its
--                top_model_line_id column.
--
-- History
--   02-10-00	D.Maskell  Created
-----------------------------------------------------------------------------+
  PROCEDURE notify_affected_lines (
	p_header_id	NUMBER,
	p_line_id		NUMBER,
	p_org_id NUMBER) IS

    l_proc_audit_id	NUMBER;
    l_rowid		ROWID;
    l_org_id NUMBER;
    -- cursor which gets information for a particular line
    CURSOR c_line (cp_lid NUMBER) IS
      SELECT top_model_line_id, service_reference_line_id
      FROM aso_i_oe_order_lines_v
      WHERE line_id = cp_lid
	  AND org_id = l_org_id;
    l_line_rec		c_line%ROWTYPE;

  BEGIN
  l_org_id := p_org_id;

    cn_message_pkg.debug('notify: adjust: entering notify_affected_lines (lid = '||p_line_id||')');
    fnd_file.put_line(fnd_file.Log, 'notify: adjust: entering notify_affected_lines (lid = '||p_line_id||')');

    cn_process_audits_pkg.insert_row
	( l_rowid, l_proc_audit_id, NULL, 'NOT', 'Notification run',
	  NULL, NULL, NULL, NULL, NULL, SYSDATE, NULL, p_org_id);
    --+
    -- Examine the line (if any) to which the sales credit belonged
    -- to determine which other lines need to be re-collected as well.
    --+
    IF p_line_id IS NULL THEN
        --+
        -- This is a Header Sales Credit, so recollect any Top Model Lines
        -- and 'Standard' lines which do not have their own sales credits.
        -- Do this using a recursive self-call, so that any children of
        -- these lines, which do not have their own sales credits, will
        -- also be re-collected.
        --+
        cn_message_pkg.debug('notify: adjust: .  Header SC change');
        fnd_file.put_line(fnd_file.Log, 'notify: adjust: .  Header SC change');
        FOR rec IN
          (SELECT line_id
           FROM   aso_i_oe_order_lines_v asol
           WHERE  asol.header_id = p_header_id
                  AND asol.service_reference_line_id IS NULL
                  AND asol.org_id = l_org_id
                  AND (asol.top_model_line_id IS NULL OR
                      asol.top_model_line_id = asol.line_id)
                  AND NOT EXISTS
                    (SELECT 1
                     FROM aso_i_oe_sales_credits_v assc
                     WHERE assc.line_id = asol.line_id))
        LOOP
            notify_affected_lines(p_header_id, rec.line_id, l_org_id);
        END LOOP;
    ELSE
        -- +
        -- This is a line sales credt, so re-collect the line and
        -- check if any child lines are affected.
        --+
        cn_message_pkg.debug('notify: adjust: .  Line SC change');
        fnd_file.put_line(fnd_file.Log, 'notify: adjust: .  Line SC change');
        notify_line(p_header_id, p_line_id,x_org_id => l_org_id);
        --+
        -- Get some line information
        --+
        OPEN c_line(p_line_id);
        FETCH c_line INTO l_line_rec;
        CLOSE c_line;
        --+
        -- If this is a Service Line or a Configured Line then
        -- no other lines are affected
        --+
        IF l_line_rec.service_reference_line_id IS NOT NULL OR
          (l_line_rec.top_model_line_id IS NOT NULL
           AND p_line_id <> l_line_rec.top_model_line_id) THEN
            cn_message_pkg.debug('notify: adjust: ..  Serv/Conf line');
            fnd_file.put_line(fnd_file.Log, 'notify: adjust: ..  Serv/Conf line');
            NULL;
        --+
        -- If this is a 'Standard' line then also re-collect any Service
        -- Lines belonging to this line, which do not have their own
        -- direct sales credits.
        -- Note: Service Lines can be on a different order
        --+
        ELSIF l_line_rec.service_reference_line_id IS NULL
              AND l_line_rec.top_model_line_id IS NULL THEN
            cn_message_pkg.debug('notify: adjust: ..  Standard line');
            fnd_file.put_line(fnd_file.Log, 'notify: adjust: ..  Standard line');
            FOR rec IN
              (SELECT header_id, line_id
               FROM   aso_i_oe_order_lines_v asol
               WHERE  asol.service_reference_line_id = p_line_id
               AND    asol.org_id = p_org_id
                      AND NOT EXISTS
                        (SELECT 1
                         FROM aso_i_oe_sales_credits_v assc
                         WHERE assc.line_id = asol.line_id))
            LOOP
                notify_line(rec.header_id, rec.line_id,x_org_id => l_org_id);
            END LOOP;
        --+
        -- If this is a Top Model Line then also re-collect any Configured
        -- Lines belonging to this line which do not have their own
        -- direct sales credits.
        -- Note: Configured Lines will be on same order
        --+
        ELSIF p_line_id = l_line_rec.top_model_line_id THEN
            cn_message_pkg.debug('notify: adjust: ..  Top Model line');
            fnd_file.put_line(fnd_file.Log, 'notify: adjust: ..  Top Model line');
            FOR rec IN
              (SELECT line_id
               FROM   aso_i_oe_order_lines_v asol
               WHERE  asol.top_model_line_id = p_line_id
               AND asol.org_id = p_org_id
                      AND asol.header_id = p_header_id   -- makes use of index
                      AND NOT EXISTS
                        (SELECT 1
                         FROM aso_i_oe_sales_credits_v assc
                         WHERE assc.line_id = asol.line_id)
                      AND asol.line_id <> p_line_id)     -- don't re-collect ourself
            LOOP
                notify_line(p_header_id, rec.line_id,x_org_id => l_org_id);
            END LOOP;
        END IF;
    END IF;

    cn_message_pkg.debug('notify: adjust: exit from notify_affected_lines (lid = '||p_line_id||')');
    fnd_file.put_line(fnd_file.Log, 'notify: adjust: exit from notify_affected_lines (lid = '||p_line_id||')');
  END notify_affected_lines;

------------------------------------------------------------------------------+
-- Procedure Name
--   Adjust_Order
-- Purpose
--   This procedure receives the Header, Line and Sales Credit information
--   for an adjusted order. It searches through these entities to see whether
--   any changes have occured which are relevant to Sales Compensation. If
--   there are relevant changes, a notify_line procedure is called to apply
--   the appropriate adjustments to Sales Compensation.
--
-- History
--   11-15-99  D.Maskell Created
------------------------------------------------------------------------------+
PROCEDURE Adjust_Order
(  p_api_version      IN NUMBER,
   p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
   p_commit           IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status          OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2,
   p_header_id              IN NUMBER,
   p_header_rec             IN OE_Order_PUB.Header_Rec_Type,
   p_old_header_rec         IN OE_Order_PUB.Header_Rec_Type,
   p_Header_Scredit_tbl     IN OE_Order_PUB.Header_Scredit_Tbl_Type,
   p_old_Header_Scredit_tbl IN OE_Order_PUB.Header_Scredit_Tbl_Type,
   p_line_tbl               IN OE_Order_PUB.Line_Tbl_Type,
   p_old_line_tbl           IN OE_Order_PUB.Line_Tbl_Type,
   p_Line_Scredit_tbl       IN OE_Order_PUB.Line_Scredit_Tbl_Type,
   p_old_Line_Scredit_tbl   IN OE_Order_PUB.line_scredit_tbl_type,
   p_parent_proc_audit_id   IN NUMBER,
   x_org_id 				IN NUMBER) -- R12 MOAC Change
IS
    l_api_name      CONSTANT VARCHAR2(30) := 'Adjust_Order';
    l_api_version   CONSTANT NUMBER  := 1.0;
    l_debug_pipe    VARCHAR2(30);
    l_debug_level   NUMBER := 1 ;
    l_process_audit_id   NUMBER;
    l_order_changed BOOLEAN;
    l_found         BOOLEAN;
    i               NUMBER; --loop counter
    k               NUMBER; --loop counter
    l_idx           NUMBER; --remembered loop counter
    l_org_id        NUMBER;
    -- cursor which loops through all the lines under a
    -- particular header
    CURSOR c_affected_lines (cp_hid NUMBER) IS
      SELECT header_id, line_id
      FROM aso_i_oe_order_lines_v
      WHERE header_id = cp_hid
	  AND org_id = x_org_id; -- R12 MOAC Change
    l_affected_line_rec		c_affected_lines%ROWTYPE;
    -- Cursor which gets all Service lines for the
    -- input line, where the Service line resides on
    -- another order
    CURSOR c_affected_service_lines (cp_hid NUMBER, cp_lid NUMBER) IS
      SELECT header_id, line_id
      FROM aso_i_oe_order_lines_v
      WHERE service_reference_line_id = cp_lid
        AND header_id <> cp_hid
		AND org_id = x_org_id;
    l_affected_service_line_rec		c_affected_lines%ROWTYPE;
BEGIN
   --+
   -- Create a Debug log file to track how the order was processed
   --+
   IF (p_parent_proc_audit_id IS NOT NULL) THEN
      cn_message_pkg.end_batch (p_parent_proc_audit_id);
   END IF;

   l_org_id := x_org_id;

   cn_message_pkg.begin_batch(
        x_parent_proc_audit_id => p_parent_proc_audit_id,
        x_process_audit_id     => l_process_audit_id,
        x_request_id           => fnd_global.conc_request_id,
        x_process_type         => 'ORD',
		p_org_id => l_org_id);

   cn_message_pkg.debug('notify: Got update information from Order Capture Feedback Queue for an adjusted order.');
   fnd_file.put_line(fnd_file.Log, 'notify: Got update information from Order Capture Feedback Queue for an adjusted order.');

   cn_message_pkg.debug('notify: Checking see if any changes have occured which are relevant to Sales Compensation.');
   fnd_file.put_line(fnd_file.Log, 'notify: Checking see if any changes have occured which are relevant to Sales Compensation.');

   cn_message_pkg.debug('notify: Entering adjust_order (hid = '||p_header_id||') ');
   fnd_file.put_line(fnd_file.Log, 'notify: Entering adjust_order (hid = '||p_header_id||') ');

    -- Standard Start of API savepoint
    SAVEPOINT	Update_Headers;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -------------------+
    -- API body
    -------------------+
    --+
    -- Look to see if the Order has changed at all in a relevent way
    -- and then act appropriately.
    -- The general strategy is simply to call Notify_Line for each
    -- existing order line which is affected by a change to an Order
    -- Header, Line or Sales Credit.
    -- Notify_Line then adds a new row in CN_NOT_TRX_ALL for the
    -- order line. That strategy takes care of changes to existing
    -- lines and addition of new lines. However for a line deletetion,
    -- Notify_Line would not add a record for it in CN_NOT_TRX_ALL, because it
    -- requeries the line to get more details,
    -- which would fail. We must have this record because
    -- the collection process will use its presence to Reverse
    -- the existing line in CN_COMM_LINES_API. That is why we call the special
    -- procedure Notify_Deleted_Line for every deleted line.
    --+
    -- DESIGN NOTE: you can't just loop from table.FIRST..table.LAST because this
    -- leads to a 'Numeric or Value Error' if a table is empty. This is why I
    -- wrapped the FIRST/LAST attributes in NVL statements for all table loops
    -- This is less messy than having to wrap each loop in an IF..ENDIF test for
    -- an empty table.
    -- Also note, thorughout the code I have done the DELETE processing separately
    -- from the Insert/Update processing. This is because I was told that the DELETE
    -- operation would be registered in the Old_Tbl structures, (e.g. Old_Line_Tbl)
    -- rather than the current ones (e.g. Line_Tbl). As it turns out they are
    -- recording the DELETEs in the Current structures and not in the 'Olds'
    -- However, you never know when they may change their minds...
    --+
    l_order_changed := FALSE;
    --+
    -- Have any Lines been Deleted?
    --+
    cn_message_pkg.debug('notify: adjust: Deleted Lines? - Line_Tbl');
    fnd_file.put_line(fnd_file.Log, 'notify: adjust: Deleted Lines? - Line_Tbl');
    FOR i IN NVL(p_line_tbl.FIRST,1)..NVL(p_line_tbl.LAST,0) LOOP
        cn_message_pkg.debug('notify: adjust: .  lid = '|| p_line_tbl(i).line_id || ' operation = ' || Nvl(p_line_tbl(i).operation,'NULL'));
        fnd_file.put_line(fnd_file.Log, 'notify: adjust: .  lid = '|| p_line_tbl(i).line_id || ' operation = ' || Nvl(p_line_tbl(i).operation,'NULL'));
        IF p_line_tbl(i).operation = 'DELETE' THEN
            notify_deleted_line
	                         (p_line_tbl(i).header_id,
	                          p_line_tbl(i).line_id,
							  p_org_id => l_org_id);
        END IF;
    END LOOP;
    --+
    -- Has the Order Header been Inserted?
    -- Or has a relevant Header field been Updated?
    -- If so, collect (or re-collect) the entire Order
    --+
    IF NOT l_order_changed THEN
        cn_message_pkg.debug('notify: adjust: Header Insert/Update?');
        fnd_file.put_line(fnd_file.Log, 'notify: adjust: Header Insert/Update?');

        cn_message_pkg.debug('notify: adjust: .  operation = '|| Nvl(p_header_rec.operation,'NULL'));
        fnd_file.put_line(fnd_file.Log, 'notify: adjust: .  operation = '|| Nvl(p_header_rec.operation,'NULL'));

        IF p_header_rec.operation = 'CREATE' THEN
            l_order_changed := TRUE;
        ELSIF p_header_rec.operation = 'UPDATE' THEN
            IF unequal(p_header_rec.invoice_to_org_id , p_old_header_rec.invoice_to_org_id) OR
               unequal(p_header_rec.invoice_to_contact_id , p_old_header_rec.invoice_to_contact_id) OR
               unequal(p_header_rec.ship_to_org_id , p_old_header_rec.ship_to_org_id) OR
               unequal(p_header_rec.order_number , p_old_header_rec.order_number) OR
               unequal(p_header_rec.booked_flag , p_old_header_rec.booked_flag) OR
               unequal(p_header_rec.transactional_curr_code , p_old_header_rec.transactional_curr_code) OR
               unequal(p_header_rec.conversion_rate , p_old_header_rec.conversion_rate)
            THEN
                l_order_changed := TRUE;
                cn_message_pkg.debug('notify: adjust: .  update of interest');
                fnd_file.put_line(fnd_file.Log, 'notify: adjust: .  update of interest');
            END IF;
        END IF;
        IF l_order_changed THEN
            cn_message_pkg.debug('notify: adjust: .  Calling Notify_Line for each line');
            fnd_file.put_line(fnd_file.Log, 'notify: adjust: .  Calling Notify_Line for each line');
            FOR l_affected_line_rec IN c_affected_lines(p_header_id)
            LOOP
                cn_notify_orders.notify_line
                  (l_affected_line_rec.header_id,
                   l_affected_line_rec.line_id,
				   x_org_id => l_org_id);
                -- Find any Service Lines for this line on other orders and
                -- flag them for recollection too.
                FOR l_affected_service_line_rec IN c_affected_service_lines(
                                                   l_affected_line_rec.header_id,
                                                   l_affected_line_rec.line_id)
                LOOP
                    cn_notify_orders.notify_line
                      (l_affected_service_line_rec.header_id,
                       l_affected_service_line_rec.line_id, x_org_id => l_org_id);
                END LOOP;
            END LOOP;
        END IF;
    END IF;
    --+
    -- Have any Order Lines been Inserted?
    -- Or has a relevant Line field been Updated?
    --+
    IF NOT l_order_changed THEN
        cn_message_pkg.debug('notify: adjust: Line Insert/Update? - Line_Tbl');
        fnd_file.put_line(fnd_file.Log, 'notify: adjust: Line Insert/Update? - Line_Tbl');

        -- Loop thru the 'new' table
        <<new_line_tbl_loop>>
        FOR i IN NVL(p_line_tbl.FIRST,1)..NVL(p_line_tbl.LAST,0) LOOP
            cn_message_pkg.debug('notify: adjust: .  lid = '||p_line_tbl(i).line_id||' operation = '|| Nvl(p_line_tbl(i).operation,'NULL'));
            fnd_file.put_line(fnd_file.Log, 'notify: adjust: .  lid = '||p_line_tbl(i).line_id||' operation = '|| Nvl(p_line_tbl(i).operation,'NULL'));
            --+
            -- If operation CREATE, add notification for the line
            --+
            IF p_line_tbl(i).operation = 'CREATE' THEN
                cn_notify_orders.notify_line
                      (p_line_tbl(i).header_id,
                       p_line_tbl(i).line_id, x_org_id => l_org_id);
            --+
            -- If we find an UPDATE, and any significant field has changed,
            -- add notification for the line
            --+
            ELSIF p_line_tbl(i).operation = 'UPDATE' THEN
                --+
                -- Locate the Before Image of the line
                --+
                l_found := FALSE;
                <<old_tbl_loop>>
                FOR k IN NVL(p_old_line_tbl.FIRST,1)..NVL(p_old_line_tbl.LAST,0) LOOP
                    IF p_old_line_tbl(k).line_id = p_line_tbl(i).line_id THEN
                        l_found := TRUE;
                        l_idx := k;  --need to remember the index of the record
                        EXIT old_tbl_loop;
                    END IF;
                END LOOP old_tbl_loop;
                --+
                -- If there is no Before Image it is a fatal error
                --+
                IF NOT l_found THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
                --+
                -- Compare the significant fields, checking for changes
                --+
                IF unequal(p_line_tbl(i).sold_to_org_id , p_old_line_tbl(l_idx).sold_to_org_id) OR
                   unequal(p_line_tbl(i).unit_selling_price , p_old_line_tbl(l_idx).unit_selling_price) OR
                   unequal(p_line_tbl(i).unit_list_price , p_old_line_tbl(l_idx).unit_list_price) OR
                   unequal(p_line_tbl(i).inventory_item_id , p_old_line_tbl(l_idx).inventory_item_id) OR
                   unequal(p_line_tbl(i).header_id , p_old_line_tbl(l_idx).header_id) OR
                   unequal(p_line_tbl(i).top_model_line_id , p_old_line_tbl(l_idx).top_model_line_id) OR
                   unequal(p_line_tbl(i).service_reference_line_id , p_old_line_tbl(l_idx).service_reference_line_id) OR
                   unequal(p_line_tbl(i).ordered_quantity , p_old_line_tbl(l_idx).ordered_quantity) OR
                   unequal(p_line_tbl(i).ship_to_contact_id , p_old_line_tbl(l_idx).ship_to_contact_id) OR
                   unequal(p_line_tbl(i).line_category_code , p_old_line_tbl(l_idx).line_category_code) OR
                   (p_line_tbl(i).operation='UPDATE' AND p_old_line_tbl(l_idx).operation ='CREATE') -- Added for Main Line Placeholder Bug 4665116
                THEN
                    cn_message_pkg.debug('notify: adjust: .  update of interest');
                    fnd_file.put_line(fnd_file.Log, 'notify: adjust: .  update of interest');
                    cn_notify_orders.notify_line
                          (p_header_id,  --p_line_tbl(i).header_id
                           p_line_tbl(i).line_id,x_org_id => l_org_id);
                END IF;
            END IF;
        END LOOP new_line_tbl_loop;
    END IF;
    --+
    -- Have any Header Sales Credits been Deleted?
    --+
    IF NOT l_order_changed THEN
        cn_message_pkg.debug('notify: adjust: Header Sales Credit Deletion? - Header_Scredit_Tbl');
        fnd_file.put_line(fnd_file.Log, 'notify: adjust: Header Sales Credit Deletion? - Header_Scredit_Tbl');
        FOR i IN NVL(p_header_scredit_tbl.FIRST,1)..NVL(p_header_scredit_tbl.LAST,0) LOOP
            cn_message_pkg.debug('notify: adjust: .  scid = '||p_header_scredit_tbl(i).sales_credit_id|| ' operation = '|| Nvl(p_header_scredit_tbl(i).operation,'NULL'));
            fnd_file.put_line(fnd_file.Log, 'notify: adjust: .  scid = '||p_header_scredit_tbl(i).sales_credit_id|| ' operation = '|| Nvl(p_header_scredit_tbl(i).operation,'NULL'));
            IF p_header_scredit_tbl(i).operation = 'DELETE' THEN
                cn_notify_orders.notify_affected_lines
                      (p_old_header_scredit_tbl(i).header_id,
                       p_old_header_scredit_tbl(i).line_id, p_org_id => l_org_id);  -- this should be NULL
            END IF;
        END LOOP;
    END IF;
    --+
    -- Have any Header Sales Credits been Inserted?
    -- Or has a relevant Sales Credit field been Updated?
    --+
    IF NOT l_order_changed THEN
        cn_message_pkg.debug('notify: adjust: Header Sales Credit Insert/Update? - Header_Scredit_Tbl');
        fnd_file.put_line(fnd_file.Log, 'notify: adjust: Header Sales Credit Insert/Update? - Header_Scredit_Tbl');
        -- Loop thru the 'new' table
        <<new_hsc_tbl_loop>>
        FOR i IN NVL(p_header_scredit_tbl.FIRST,1)..NVL(p_header_scredit_tbl.LAST,0) LOOP
            cn_message_pkg.debug('notify: adjust: .  scid = '||p_header_scredit_tbl(i).sales_credit_id|| ' operation = '||Nvl(p_header_scredit_tbl(i).operation,'NULL'));
            fnd_file.put_line(fnd_file.Log, 'notify: adjust: .  scid = '||p_header_scredit_tbl(i).sales_credit_id|| ' operation = '||Nvl(p_header_scredit_tbl(i).operation,'NULL'));
            --+
            -- If we find an INSERT, flag the order changed and quit loop
            --+
            IF p_header_scredit_tbl(i).operation = 'CREATE' THEN
                cn_notify_orders.notify_affected_lines
                      (p_header_scredit_tbl(i).header_id,
                       p_header_scredit_tbl(i).line_id,p_org_id => l_org_id);  -- this should be NULL
            --+
            -- If we find an UPDATE, and any significant field has changed,
            -- flag the order changed and quit loop
            --+
            ELSIF p_header_scredit_tbl(i).operation = 'UPDATE' THEN
                --+
                -- Locate the Before Image of the header_scredit
                --+
                l_found := FALSE;
                <<old_tbl_loop>>
                FOR k IN NVL(p_old_header_scredit_tbl.FIRST,1)..NVL(p_old_header_scredit_tbl.LAST,0) LOOP
                    IF p_old_header_scredit_tbl(k).sales_credit_id = p_header_scredit_tbl(i).sales_credit_id THEN
                        l_found := TRUE;
                        l_idx := k;  --need to remember the index of the record
                        EXIT old_tbl_loop;
                    END IF;
                END LOOP old_tbl_loop;
                --+
                -- If there is no Before Image it is a fatal error
                --+
                IF NOT l_found THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
                --+
                -- Compare the significant fields, checking for changes
                --+
                IF unequal(p_header_scredit_tbl(i).header_id , p_old_header_scredit_tbl(l_idx).header_id) OR
                   unequal(p_header_scredit_tbl(i).line_id , p_old_header_scredit_tbl(l_idx).line_id) OR
                   unequal(p_header_scredit_tbl(i).salesrep_id , p_old_header_scredit_tbl(l_idx).salesrep_id) OR
                   unequal(p_header_scredit_tbl(i).percent , p_old_header_scredit_tbl(l_idx).percent)
                THEN
                    cn_message_pkg.debug('notify: adjust: .  update of interest');
                    fnd_file.put_line(fnd_file.Log, 'notify: adjust: .  update of interest');
                    cn_notify_orders.notify_affected_lines
                          (p_header_scredit_tbl(i).header_id,
                           p_header_scredit_tbl(i).line_id,p_org_id => l_org_id);  -- this should be NULL
                END IF;
            END IF;
        END LOOP new_hsc_tbl_loop;
    END IF;
    --+
    -- Have any Line Sales Credits been Deleted?
    --+
    IF NOT l_order_changed THEN
        cn_message_pkg.debug('notify: adjust: Line Sales Credit Deletion? - Line_Scredit_Tbl');
        fnd_file.put_line(fnd_file.Log, 'notify: adjust: Line Sales Credit Deletion? - Line_Scredit_Tbl');
        FOR i IN NVL(p_line_scredit_tbl.FIRST,1)..NVL(p_line_scredit_tbl.LAST,0) LOOP
            cn_message_pkg.debug('notify: adjust: .  scid = '||p_line_scredit_tbl(i).sales_credit_id||' operation = '||Nvl(p_line_scredit_tbl(i).operation,'NULL'));
            fnd_file.put_line(fnd_file.Log, 'notify: adjust: .  scid = '||p_line_scredit_tbl(i).sales_credit_id||' operation = '||Nvl(p_line_scredit_tbl(i).operation,'NULL'));
            IF p_line_scredit_tbl(i).operation = 'DELETE' THEN
                cn_notify_orders.notify_affected_lines
                      (p_old_line_scredit_tbl(i).header_id,
                       p_old_line_scredit_tbl(i).line_id,p_org_id => l_org_id);
            END IF;
        END LOOP;
    END IF;
    --+
    -- Have any Line Sales Credits been Inserted?
    -- Or has a relevant Sales Credit field been Updated?
    --+
    IF NOT l_order_changed THEN
        cn_message_pkg.debug('notify: adjust: Line Sales Credit Insert/Update? - Line_Scredit_Tbl');
        fnd_file.put_line(fnd_file.Log, 'notify: adjust: Line Sales Credit Insert/Update? - Line_Scredit_Tbl');
        -- Loop thru the 'new' table
        <<new_lsc_tbl_loop>>
        FOR i IN NVL(p_line_scredit_tbl.FIRST,1)..NVL(p_line_scredit_tbl.LAST,0) LOOP
            cn_message_pkg.debug('notify: adjust: .  scid = '||p_line_scredit_tbl(i).sales_credit_id||' operation = '||Nvl(p_line_scredit_tbl(i).operation,'NULL'));
            fnd_file.put_line(fnd_file.Log, 'notify: adjust: .  scid = '||p_line_scredit_tbl(i).sales_credit_id||' operation = '||Nvl(p_line_scredit_tbl(i).operation,'NULL'));
            --+
            -- If we find an INSERT, flag the order changed and quit loop
            --+
            IF p_line_scredit_tbl(i).operation = 'CREATE' THEN
                cn_notify_orders.notify_affected_lines
                      (p_line_scredit_tbl(i).header_id,
                       p_line_scredit_tbl(i).line_id,p_org_id => l_org_id);
            --+
            -- If we find an UPDATE, and any significant field has changed,
            -- flag the order changed and quit loop
            --+
            ELSIF p_line_scredit_tbl(i).operation = 'UPDATE' THEN
                --+
                -- Locate the Before Image of the line_scredit
                --+
                l_found := FALSE;
                <<old_tbl_loop>>
                FOR k IN NVL(p_old_line_scredit_tbl.FIRST,1)..NVL(p_old_line_scredit_tbl.LAST,0) LOOP
                    IF p_old_line_scredit_tbl(k).sales_credit_id = p_line_scredit_tbl(i).sales_credit_id THEN
                        l_found := TRUE;
                        l_idx := k;  --need to remember the index of the record
                        EXIT old_tbl_loop;
                    END IF;
                END LOOP old_tbl_loop;
                --+
                -- If there is no Before Image it is a fatal error
                --+
                IF NOT l_found THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
                --+
                -- Compare the significant fields, checking for changes
                --+
                IF unequal(p_line_scredit_tbl(i).header_id , p_old_line_scredit_tbl(l_idx).header_id) OR
                   unequal(p_line_scredit_tbl(i).line_id , p_old_line_scredit_tbl(l_idx).line_id) OR
                   unequal(p_line_scredit_tbl(i).salesrep_id , p_old_line_scredit_tbl(l_idx).salesrep_id) OR
                   unequal(p_line_scredit_tbl(i).percent , p_old_line_scredit_tbl(l_idx).percent)
                THEN
                    cn_message_pkg.debug('notify: adjust: .  update of interest');
                    fnd_file.put_line(fnd_file.Log, 'notify: adjust: .  update of interest');
                    cn_notify_orders.notify_affected_lines
                          (p_line_scredit_tbl(i).header_id,
                           p_line_scredit_tbl(i).line_id,p_org_id => l_org_id);
                END IF;
            END IF;
        END LOOP new_lsc_tbl_loop;
    END IF;
    cn_message_pkg.debug('notify: Exit from adjust_order (hid = '||p_header_id||') ');
    fnd_file.put_line(fnd_file.Log, 'notify: Exit from adjust_order (hid = '||p_header_id||') ');

    cn_message_pkg.end_batch(l_process_audit_id);
    -------------------+
    -- End of API body.
    -------------------+
    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
                        (p_count   =>  x_msg_count ,
                         p_data    =>  x_msg_data  ,
                         p_encoded => FND_API.G_FALSE);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      cn_message_pkg.end_batch(l_process_audit_id);
      ROLLBACK TO Update_Headers;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(p_count   => x_msg_count,
	 p_data    => x_msg_data,
	 p_encoded => FND_API.G_FALSE);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      cn_message_pkg.end_batch(l_process_audit_id);
      ROLLBACK TO Update_Headers;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(p_count   => x_msg_count,
	 p_data    => x_msg_data,
	 p_encoded => FND_API.G_FALSE);

   WHEN OTHERS THEN
      cn_message_pkg.end_batch(l_process_audit_id);
      ROLLBACK TO Update_Headers;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level
	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 FND_MSG_PUB.Add_Exc_Msg
	   (G_PKG_NAME,
	    l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
	(p_count   => x_msg_count,
	 p_data    => x_msg_data,
	 p_encoded => FND_API.G_FALSE);
END Adjust_Order;


--*********************************************
-- Public Procedures
--*********************************************
------------------------------------------------------------------------------+
-- Procedure Name
--   Get_Notice_Conc
-- Purpose
--   Concurrent Program "Order Update Notification" wrapper
--   on top of Get_Notice
------------------------------------------------------------------------------+
PROCEDURE Get_notice_conc
  (x_errbuf               OUT NOCOPY VARCHAR2,
   x_retcode              OUT NOCOPY NUMBER,
   p_org_id IN  NUMBER )
  IS

BEGIN

   get_notice(p_parent_proc_audit_id => NULL, x_org_id => p_org_id );

END get_notice_conc;
------------------------------------------------------------------------------+
-- Procedure Name
--   Get_Notice
-- Purpose
--   This procedure collects order updates from the Order Capture Notification
--   API.  It is a loop which
--   gets the latest notification off of the queue. If the order is Booked,
--   this procedure initiates processing of the adjustments to the
--   order for OSC.
--
-- History
--   11-15-99  D.Maskell Created
------------------------------------------------------------------------------+
PROCEDURE Get_notice
  (
   p_parent_proc_audit_id IN  NUMBER,
   x_org_id IN NUMBER)
 IS
    l_return_status             VARCHAR2(2000);
    l_process_audit_id          NUMBER;
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
    l_no_more_messages          VARCHAR2(2000);
    l_header_id                 NUMBER;
    l_booked_flag               VARCHAR2(1);
    l_header_rec                OE_Order_PUB.Header_Rec_Type;
    l_old_header_rec            OE_Order_PUB.Header_Rec_Type;
    l_Header_Adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
    l_old_Header_Adj_tbl        OE_Order_PUB.Header_Adj_Tbl_Type;
    l_Header_price_Att_tbl      OE_Order_PUB.Header_Price_Att_Tbl_Type;
    l_old_Header_Price_Att_tbl  OE_Order_PUB.Header_Price_Att_Tbl_Type;
    l_Header_Adj_Att_tbl        OE_Order_PUB.Header_Adj_Att_Tbl_Type;
    l_old_Header_Adj_Att_tbl    OE_Order_PUB.Header_Adj_Att_Tbl_Type;
    l_Header_Adj_Assoc_tbl      OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
    l_old_Header_Adj_Assoc_tbl  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
    l_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
    l_old_Header_Scredit_tbl    OE_Order_PUB.Header_Scredit_Tbl_Type;
    l_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
    l_old_line_tbl              OE_Order_PUB.Line_Tbl_Type;
    l_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
    l_old_Line_Adj_tbl          OE_Order_PUB.Line_Adj_Tbl_Type;
    l_Line_Price_Att_tbl        OE_Order_PUB.Line_Price_Att_Tbl_Type;
    l_old_Line_Price_Att_tbl    OE_Order_PUB.Line_Price_Att_Tbl_Type;
    l_Line_Adj_Att_tbl          OE_Order_PUB.Line_Adj_Att_Tbl_Type;
    l_old_Line_Adj_Att_tbl      OE_Order_PUB.Line_Adj_Att_Tbl_Type;
    l_Line_Adj_Assoc_tbl        OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
    l_old_Line_Adj_Assoc_tbl    OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
    l_Line_Scredit_tbl          OE_Order_PUB.Line_Scredit_Tbl_Type;
    l_old_Line_Scredit_tbl      OE_Order_PUB.Line_Scredit_Tbl_Type;
    l_Lot_Serial_tbl            OE_Order_PUB.Lot_Serial_Tbl_Type;
    l_old_Lot_Serial_tbl        OE_Order_PUB.Lot_Serial_Tbl_Type;
    l_action_request_tbl        OE_Order_PUB.Request_Tbl_Type;

    CURSOR c_booked_flag (cp_hid NUMBER) IS
      SELECT booked_flag
      FROM aso_i_oe_order_lines_v
	WHERE header_id = cp_hid
	AND org_id = x_org_id; -- R12 MOAC Change

	l_org_id NUMBER;

BEGIN
   -- Standard Start of process savepoint
   SAVEPOINT	Update_Headers_Savepoint;

   l_org_id := x_org_id;

    --+
    -- Start looping to check for messages in the queue
    --+
    LOOP
        -- Queue savepoint for standard advanced queue error handling
        SAVEPOINT	Get_Notice_Loop_Savepoint;
        --+
        -- Invoke Get_Notice to dequeue queue payload and return Order data
        --+
        aso_order_feedback_pub.Get_Notice
              (p_api_version               => 1.0,
               x_return_status             => l_return_status,
               x_msg_count                 => l_msg_count,
               x_msg_data                  => l_msg_data,
               p_app_short_name            => 'CN',
               x_no_more_messages          => l_no_more_messages,
               x_header_rec                => l_header_rec,
               x_old_header_rec            => l_old_header_rec,
               x_Header_Adj_tbl            => l_header_adj_tbl,
               x_old_Header_Adj_tbl        => l_old_header_adj_tbl,
               x_Header_price_Att_tbl      => l_header_price_att_tbl,
               x_old_Header_Price_Att_tbl  => l_old_header_price_att_tbl,
               x_Header_Adj_Att_tbl        => l_header_adj_att_tbl,
               x_old_Header_Adj_Att_tbl    => l_old_header_adj_att_tbl,
               x_Header_Adj_Assoc_tbl      => l_header_adj_assoc_tbl,
               x_old_Header_Adj_Assoc_tbl  => l_old_header_adj_assoc_tbl,
               x_Header_Scredit_tbl        => l_header_scredit_tbl,
               x_old_Header_Scredit_tbl    => l_old_header_scredit_tbl,
               x_line_tbl                  => l_line_tbl,
               x_old_line_tbl              => l_old_line_tbl,
               x_Line_Adj_tbl              => l_line_adj_tbl,
               x_old_Line_Adj_tbl          => l_old_line_adj_tbl,
               x_Line_Price_Att_tbl        => l_line_price_att_tbl,
               x_old_Line_Price_Att_tbl    => l_old_line_price_att_tbl,
               x_Line_Adj_Att_tbl          => l_line_adj_att_tbl,
               x_old_Line_Adj_Att_tbl      => l_old_line_adj_att_tbl,
               x_Line_Adj_Assoc_tbl        => l_line_adj_assoc_tbl,
               x_old_Line_Adj_Assoc_tbl    => l_old_line_adj_assoc_tbl,
               x_Line_Scredit_tbl          => l_line_scredit_tbl,
               x_old_Line_Scredit_tbl      => l_old_line_scredit_tbl,
               x_Lot_Serial_tbl            => l_lot_serial_tbl,
               x_old_Lot_Serial_tbl        => l_old_lot_serial_tbl,
               x_action_request_tbl        => l_action_request_tbl
               );
        -- +
        -- Check return status
        --+
        IF NOT (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
	    -- This rollback causes an error message sometimes and is anyway not
	    --  necessary (no changes since COMMIT at end of loop
	    --            ROLLBACK TO Update_Headers_Savepoint;

	    --  hithanki:23-04-03:Changes for Enhancement#2778521:Start
        --  Enqueue the failed message into the Order Feedback Exception Queue
        fnd_file.put_line(fnd_file.Log, 'l_return_status = FND_API.G_RET_STS_SUCCESS.');

           aso_order_feedback_pub.handle_exception(
	               p_api_version 			=> 1.0
	              ,p_init_msg_list 			=> fnd_api.g_false
	              ,p_commit 			=> fnd_api.g_false
	              ,x_return_status 			=> l_return_status
	              ,x_msg_count 			=> l_msg_count
	              ,x_msg_data 			=> l_msg_data
	              ,p_app_short_name 		=> 'CN'
	              ,p_header_rec 			=> l_header_rec
	              ,p_old_header_rec 		=> l_old_header_rec
	              ,p_header_adj_tbl 		=> l_header_adj_tbl
	              ,p_old_header_adj_tbl 		=> l_old_header_adj_tbl
	              ,p_header_price_att_tbl 		=> l_header_price_att_tbl
	              ,p_old_header_price_att_tbl 	=> l_old_header_price_att_tbl
	              ,p_header_adj_att_tbl 		=> l_header_adj_att_tbl
	              ,p_old_header_adj_att_tbl 	=> l_old_header_adj_att_tbl
	              ,p_header_adj_assoc_tbl 		=> l_header_adj_assoc_tbl
	              ,p_old_header_adj_assoc_tbl 	=> l_old_header_adj_assoc_tbl
	              ,p_header_scredit_tbl 		=> l_header_scredit_tbl
	              ,p_old_header_scredit_tbl 	=> l_old_header_scredit_tbl
	              ,p_line_tbl 			=> l_line_tbl
	              ,p_old_line_tbl 			=> l_old_line_tbl
	              ,p_line_adj_tbl 			=> l_line_adj_tbl
	              ,p_old_line_adj_tbl 		=> l_old_line_adj_tbl
	              ,p_line_price_att_tbl 		=> l_line_price_att_tbl
	              ,p_old_line_price_att_tbl 	=> l_old_line_price_att_tbl
	              ,p_line_adj_att_tbl 		=> l_line_adj_att_tbl
	              ,p_old_line_adj_att_tbl 		=> l_old_line_adj_att_tbl
	              ,p_line_adj_assoc_tbl 		=> l_line_adj_assoc_tbl
	              ,p_old_line_adj_assoc_tbl 	=> l_old_line_adj_assoc_tbl
	              ,p_line_scredit_tbl 		=> l_line_scredit_tbl
	              ,p_old_line_scredit_tbl 		=> l_old_line_scredit_tbl
	              ,p_lot_serial_tbl 		=> l_lot_serial_tbl
	              ,p_old_lot_serial_tbl 		=> l_old_lot_serial_tbl
           	      ,p_action_request_tbl 		=> l_action_request_tbl);

           -- Quit the procedure IF the queue is empty

           EXIT WHEN l_no_more_messages = FND_API.G_TRUE;

           IF l_return_status = fnd_api.g_ret_sts_success THEN
              COMMIT;
           END IF;

           --  hithanki:23-04-03:Changes for Enhancement#2778521:Done

	   --+
	   -- Create a debug log file and dump out the error message list
	   --+
	   IF (p_parent_proc_audit_id IS NOT NULL) THEN
	      cn_message_pkg.end_batch (p_parent_proc_audit_id);
	   END IF;
	   cn_message_pkg.begin_batch
	     (x_parent_proc_audit_id => p_parent_proc_audit_id,
	      x_process_audit_id     => l_process_audit_id,
	      x_request_id           => fnd_global.conc_request_id,
	      x_process_type         => 'ORD',
		  p_org_id => x_org_id);

	   cn_message_pkg.debug('<<CN_NOTIFY_ORDERS.Get_Notice exited - error message list>>');
	   fnd_file.put_line(fnd_file.Log, '<<CN_NOTIFY_ORDERS.Get_Notice exited - error message list>>');

	   cn_api.get_fnd_message(NULL,NULL);
	   cn_message_pkg.end_batch (l_process_audit_id);

	   RETURN;

        END IF;
        --+
        -- Get the Booked_Flag for the order. Unfortunately, we have no idea

        -- which entities of the order will have data in them. We therefore
        -- either get the Booked_Flag direct from our Header entity , or if
        -- that's empty, get Header_Id from another entity and then use that to
        -- to call Get_Booked_Status, which will query the current Header in
        -- the database. The proper solution would be for the OM/OC data
        -- structure to include a "curr_header_rec" entity which is
        -- always populated.
        --+

        l_booked_flag := 'N';
        IF  l_header_rec.header_id <> FND_API.G_MISS_NUM THEN
            fnd_file.put_line(fnd_file.Log, 'l_header_rec.header_id <> FND_API.G_MISS_NUM'||l_header_rec.header_id);
            l_booked_flag := l_header_rec.booked_flag;
            l_header_id := l_header_rec.header_id;
        ELSE
            l_header_id := FND_API.G_MISS_NUM;
            fnd_file.put_line(fnd_file.Log, 'l_header_rec.header_id == FND_API.G_MISS_NUM'||l_header_rec.header_id);
            IF l_line_tbl.COUNT >0 THEN
                l_header_id := l_line_tbl(l_line_tbl.FIRST).header_id;
            ELSIF l_old_line_tbl.COUNT >0 THEN
                l_header_id := l_old_line_tbl(l_old_line_tbl.FIRST).header_id;
            ELSIF l_line_scredit_tbl.COUNT >0 THEN
                l_header_id := l_line_scredit_tbl(l_line_scredit_tbl.FIRST).header_id;
            ELSIF l_old_line_scredit_tbl.COUNT >0 THEN
                l_header_id := l_old_line_scredit_tbl(l_old_line_scredit_tbl.FIRST).header_id;
            ELSIF l_header_scredit_tbl.COUNT >0 THEN
                l_header_id := l_header_scredit_tbl(l_header_scredit_tbl.FIRST).header_id;
            ELSIF l_old_header_scredit_tbl.COUNT >0 THEN
                l_header_id := l_old_header_scredit_tbl(l_old_header_scredit_tbl.FIRST).header_id;
            END IF;
            IF l_header_id <> FND_API.G_MISS_NUM THEN
                OPEN c_booked_flag(l_header_id);
                FETCH c_booked_flag INTO l_booked_flag;
                CLOSE c_booked_flag;
            END IF;
        END IF;
 --dbms_output.put_line('Get_Notice - processing header_id '||NVL(TO_CHAR(l_header_id),'null')||' Booked = '||l_booked_flag);
        --+
        -- If the order is booked, call Update_Headers to process my structure
        --+
        fnd_file.put_line(fnd_file.Log, 'Booked Flag value...'||l_booked_flag);
        fnd_file.put_line(fnd_file.Log, 'l_line_tbl.header_id...'||l_line_tbl.COUNT);
        fnd_file.put_line(fnd_file.Log, 'l_old_line_tbl.header_id...'||l_old_line_tbl.COUNT);
        fnd_file.put_line(fnd_file.Log, 'l_line_scredit_tbl.header_id...'||l_line_scredit_tbl.COUNT);
        fnd_file.put_line(fnd_file.Log, 'l_old_line_scredit_tbl.header_id...'||l_old_line_scredit_tbl.COUNT);
        fnd_file.put_line(fnd_file.Log, 'l_header_scredit_tbl.header_id...'||l_header_scredit_tbl.COUNT);
        fnd_file.put_line(fnd_file.Log, 'l_old_header_scredit_tbl.header_id...'||l_old_header_scredit_tbl.COUNT);

        IF l_booked_flag = 'Y' THEN
            Adjust_Order
                (p_api_version		  => 1.0,
                 x_return_status	  => l_return_status,
                 x_msg_count		  => l_msg_count,
                 x_msg_data		  => l_msg_data,
                 p_header_id		  => l_header_id,
                 p_header_rec		  => l_header_rec,
                 p_old_header_rec	  => l_old_header_rec,
                 p_line_tbl		  => l_line_tbl,
                 p_old_line_tbl		  => l_old_line_tbl,
                 p_line_scredit_tbl	  => l_line_scredit_tbl,
                 p_old_line_scredit_tbl	  => l_old_line_scredit_tbl,
                 p_header_scredit_tbl	  => l_header_scredit_tbl,
                 p_old_header_scredit_tbl => l_old_header_scredit_tbl,
		 p_parent_proc_audit_id   => p_parent_proc_audit_id,
		 x_org_id => l_org_id );
            --+
            -- Check return status of functional process, rollback to undo processing
            -- and increment retry_count of queue
            --+
            IF NOT (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                ROLLBACK TO Get_Notice_Loop_Savepoint;
            END IF;
            COMMIT;
        END IF;
        --+
        -- Quit the procedure if the queue is empty
        --+
        IF l_no_more_messages = 'T' THEN
	   RETURN;
        END IF;
    END LOOP;

END Get_Notice;


------------------------------------------------------------------------+
-- Procedure Name
--   regular_col_notify
-- Purpose
--   This procedure collects order line identifiers into cn_not_trx
--   as part of the collection process for new orders.
--
--   It is called from CN_COLLECT_ORDERS and is passed a
--   start-period-id and end-period-id.
--
--   Note. The ASO views contain Org_Ids but ARE NOT ORG-PARTITIONED.
--   The purpose of this procedure is to collect new orders for the
--   current Org only, so we have to add an Org filter to the WHERE
--   clause of the query.
--   This is why there is a line in the WHERE clause to restrict
--   the selection from ASO_I_OE_ORDER_HEADERS_V to only the
--   current Org_Id. We only need to do this on the ...HEADERS_V
--   view, because we then join from ...HEADERS_V to ...LINES_V using
--   ASO_I_OE_ORDER_HEADERS_V.Header_Id, which is Primary Key.


-- History
--   04-16-98	J.Cheng    Created
--   11-01-99	D.Maskell	 Interface to Order Capture instead
--                        of Order Entry tables
--   12-08-99	D.Maskell	 New processing because ASO views are
--                        no longer org-partitioned.
--   12-24-99  D.Maskell  Call Get_Notice to get any pending
--                        order updates off of the queue

PROCEDURE regular_col_notify
  (
   x_start_period	 cn_periods.period_id%TYPE,
   x_end_period	         cn_periods.period_id%TYPE,
   x_adj_flag	         VARCHAR2,
   parent_proc_audit_id  NUMBER,
   debug_pipe	         VARCHAR2 DEFAULT NULL,
   debug_level	         NUMBER	  DEFAULT NULL,
   x_org_id 			 NUMBER ) -- R12 MOAC Changes
     IS
    l_retcode       NUMBER;
    l_errbuf        VARCHAR2(2000);
    l_trx_count 	NUMBER;
    l_proc_audit_id	NUMBER;
    l_start_date	DATE;
    l_end_date		DATE;
    l_rowid		ROWID;
    --+
    -- Because this procedure is only looking at orders for
    -- the client org_id, we can get the right inventory
    -- organization for that org by a simple call to oe_profile.value
    --+
    l_so_org_id 	NUMBER;
    l_sys_batch_size NUMBER;
    l_client_org_id NUMBER;

    CURSOR batch_size IS SELECT system_batch_size FROM cn_repositories WHERE org_id = x_org_id;

  BEGIN
    IF (debug_pipe IS NOT NULL) THEN
		cn_debug.init_pipe(debug_pipe, debug_level);
    END IF;

    cn_debug.print_msg('>>cn_notify_orders.regular_col_notify', 1);

    cn_message_pkg.debug('notify: cn_notify_orders.regular_col_notify>>');
    fnd_file.put_line(fnd_file.Log, 'notify: cn_notify_orders.regular_col_notify>>');

    --Added as per OM MOAC Mandate
    MO_GLOBAL.SET_POLICY_CONTEXT ('S', x_org_id);
    l_so_org_id := NVL(oe_profile.value('OE_ORGANIZATION_ID'),-99);

    --+
    -- Call Get_Notice to get any pending order updates off of the queue
    --+
    cn_message_pkg.debug('notify: Get_Notice>>');
    fnd_file.put_line(fnd_file.Log, 'notify: Get_Notice>>');

    cn_message_pkg.debug('notify: Getting any pending order updates off of the Order Capture Feedback Queue');
    fnd_file.put_line(fnd_file.Log, 'notify: Getting any pending order updates off of the Order Capture Feedback Queue');

	l_client_org_id := x_org_id;

    Get_Notice(p_parent_proc_audit_id => parent_proc_audit_id, x_org_id => l_client_org_id);

    cn_message_pkg.debug('notify: Get_Notice<<');
    fnd_file.put_line(fnd_file.Log, 'notify: Get_Notice<<');

    l_proc_audit_id := NULL;	-- Gets a value in the call below

    cn_process_audits_pkg.insert_row
	( l_rowid, l_proc_audit_id, NULL, 'NOT', 'Notification run',
	  NULL, NULL, NULL, NULL, NULL, SYSDATE, NULL, x_org_id);

    cn_periods_api.set_dates(x_start_period, x_end_period, x_org_id,
			     l_start_date, l_end_date);

    cn_message_pkg.debug
	( 'notify: Inserting records into CN_NOT_TRX from period '
	   || l_start_date ||' to period '|| l_end_date ||'.');

    fnd_file.put_line(fnd_file.Log, 'notify: Inserting records into CN_NOT_TRX from period '
	   || l_start_date ||' to period '|| l_end_date ||'.');

    OPEN batch_size;
    FETCH batch_size INTO l_sys_batch_size;
    CLOSE batch_size;

    INSERT INTO cn_not_trx (
	   not_trx_id,
	   batch_id,
	   notified_date,
	   processed_date,
	   notification_run_id,
	   collected_flag,
	   row_id,
	   source_trx_id,
	   source_trx_line_id,
	   source_doc_type,
	   adjusted_flag,
	   event_id,
	   org_id)
    SELECT
	   cn_not_trx_s.NEXTVAL,
	   FLOOR(cn_not_trx_s.CURRVAL/l_sys_batch_size),
	   SYSDATE,
	   asoh.booked_date,
	   l_proc_audit_id,
	   'N',
	   asoh.rowid,
	   asoh.header_id,
	   asol.line_id,
	   g_source_doc_type,
	   x_adj_flag,
	   cn_global.ord_event_id,
	   l_client_org_id
    FROM
        aso_i_oe_order_headers_v asoh,
	    aso_i_oe_order_lines_v asol
    WHERE
        -- Multi_org filter, see comment in procedure header
	   -- NOTE: asoh.header_id is a primary key, so no need to
	   -- have an org filter for the join to asol
	   --+
        NVL(asoh.org_id,l_client_org_id) = l_client_org_id
        AND asol.org_id = asoh.org_id
        --+
        AND asoh.booked_flag = 'Y'              -- only interested in status of booked
        AND asol.header_id = asoh.header_id
-- also collect 'RETURN's        AND asol.line_category_code = 'ORDER'   -- only collect 'Order' lines
        AND TRUNC(asoh.booked_date)
            BETWEEN TRUNC(nvl(l_start_date,asoh.booked_date))
                AND TRUNC(nvl(l_end_date,asoh.booked_date))
        AND EXISTS
		  (SELECT 1
		  FROM mtl_system_items mtl
		  WHERE NVL(mtl.organization_id,l_so_org_id) = l_so_org_id
                  AND mtl.inventory_item_id = asol.inventory_item_id
                  AND mtl.invoiceable_item_flag = 'Y')     -- only want invoiceable items
        AND NOT EXISTS
                       (SELECT 1
                       FROM cn_not_trx
                       WHERE source_trx_id = asoh.header_id
                             AND source_trx_line_id = asol.line_id
                             AND event_id= cn_global.ord_event_id
							 AND org_id = l_client_org_id) ;

    l_trx_count := SQL%ROWCOUNT;

    --dbms_output.put_line(' In CN_NOTIFY_ORDERS REGULAR_COL_NOTIFY ');
    --dbms_output.put_line(' l_trx_count '||l_trx_count);


    cn_process_audits_pkg.update_row(l_proc_audit_id, NULL, SYSDATE, 0,
      'Finished notification run: Notified ' || l_trx_count || ' orders.');

    --DBMS_OUTPUT.put_line('parent_proc_audit_id '||parent_proc_audit_id);

    IF  ( l_trx_count = 0 ) THEN

      cn_message_pkg.debug('notify: No rows inserted into CN_NOT_TRX. Possible reason: Order transactions may have already been collected.');
      fnd_file.put_line(fnd_file.Log, 'notify: No rows inserted into CN_NOT_TRX. Possible reason: Order transactions may have already been collected.');

    END IF;

--    COMMIT; -- Commit now done by Order Capture notification process or by CN_COLLECT_ORDERS

    cn_message_pkg.debug('notify: Finished notification run: Notified ' || l_trx_count || ' orders.');
    fnd_file.put_line(fnd_file.Log, 'notify: Finished notification run: Notified ' || l_trx_count || ' orders.');

    cn_debug.print_msg('cn_notify_orders.regular_col_notify<<', 1);

    cn_message_pkg.debug('notify: cn_notify_orders.regular_col_notify<<');
    fnd_file.put_line(fnd_file.Log, 'notify: cn_notify_orders.regular_col_notify<<');

    cn_message_pkg.end_batch (l_proc_audit_id);


  EXCEPTION
    WHEN OTHERS THEN ROLLBACK;

    cn_message_pkg.debug('notify_orders: in exception handler');
    fnd_file.put_line(fnd_file.Log, 'notify_orders: in exception handler');

    cn_message_pkg.debug(SQLCODE||' '||SQLERRM);
    fnd_file.put_line(fnd_file.Log, SQLCODE||' '||SQLERRM);

    cn_debug.print_msg('notify_orders: in exception handler', 1);
    cn_process_audits_pkg.update_row(l_proc_audit_id, NULL, SYSDATE, SQLCODE,
      SQLERRM);
    cn_message_pkg.end_batch (l_proc_audit_id);

    app_exception.raise_exception;


  END regular_col_notify;


END CN_NOTIFY_ORDERS;




/
