--------------------------------------------------------
--  DDL for Package Body PO_ASL_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ASL_SV" as
/* $Header: POXA1LSB.pls 120.1.12010000.2 2010/12/29 19:15:44 yawang ship $ */

-- <ASL ERECORD FPJ START>
G_ERES_ENABLED  CONSTANT    VARCHAR2(1) :=
                            NVL(FND_PROFILE.value('EDR_ERES_ENABLED'), 'N');

G_PKG_NAME      CONSTANT    VARCHAR2(50) := 'PO_ASL_SV';

G_MODULE_PREFIX CONSTANT    VARCHAR2(40) := 'po.plsql.' || g_pkg_name || '.';

g_debug_stmt    CONSTANT    BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp   CONSTANT    BOOLEAN := PO_DEBUG.is_debug_unexp_on;


TYPE asl_activity_rec IS RECORD
( asl_id   NUMBER,
  action   VARCHAR2(10)
);

TYPE asl_activity_tbl IS TABLE OF asl_activity_rec INDEX BY BINARY_INTEGER;

-- Global variables that maintain ASLs that need to be processed

g_asl_activities asl_activity_tbl;

-- bug3539651
-- g_asl_activities_index should never be null
g_asl_activities_index NUMBER := 0;


PROCEDURE get_identifier
( p_asl_id           IN NUMBER,
  x_identifier       OUT NOCOPY VARCHAR2,
  x_identifier_value OUT NOCOPY VARCHAR2
);

-- <ASL ERECORD FPJ END>

/*=============================================================================

  FUNCTION NAME:	check_asl_action()

=============================================================================*/

function check_asl_action(x_action	     varchar2,
			  x_vendor_id	     number,
			  x_vendor_site_id   number,
			  x_item_id	     number,
			  x_category_id      number,
-- DEBUG for now, we just pass in one org;
-- DEBUG in the future, we need to implement passing a org_list
-- DEBUG  	  	  x_ship_to_org_list orgTab
                          x_ship_to_org      number) return number is

  x_progress            VARCHAR2(3) := NULL;
  x_asl_status          NUMBER      := NULL;


  -- Bug 2072963
  cursor c_category_ids (p_item_id Number,  p_org_id Number) IS
    select category_id
    from   mtl_item_categories
    where  inventory_item_id = p_item_id
    and    organization_id = p_org_id;

  x_asl_s   NUMBER := 0;

begin

  --dbms_output.put_line('Entering check_asl_action');

  -- Query from po_approved_supplier_list to get the status (asl_status_id)
  -- of the supplier, site, item, organization, category.
  x_progress := '010';

  -- Based on the status_id query from po_asl_status_rules to see
  -- if the allow_action_flag is set to Y for the buisness rule
  -- that is the same as the action that is passed in.
  -- The action that is passed in should be equal to one of the
  -- following based on where we are calling this from:
  --	1_PO_APPROVAL
  --	2_SOURCING
  --	3_SCHEDULE_CONFIRMATION
  -- 	4_DISTRIBUTOR_MFR_LINK
/*
  commented the following as part of the performance fix for 1517028
  SELECT sum(decode(ASR.allow_action_flag, 'Y', 1, -100)) INTO x_asl_status
      FROM PO_APPROVED_SUPPLIER_LIS_VAL_V ASL, PO_ASL_STATUS_RULES ASR
      WHERE  ASL.using_organization_id IN (nvl(x_ship_to_org,-1), -1)
      AND    ASL.vendor_id = x_vendor_id
      AND    nvl(ASL.vendor_site_id, nvl(x_vendor_site_id,-1)) = nvl(x_vendor_site_id,-1)
      AND ( (ASL.item_id = x_item_id) OR
            (ASL.category_id = x_category_id) OR
      (ASL.category_id in (SELECT MIC.category_id
                           FROM   MTL_ITEM_CATEGORIES MIC
                           WHERE MIC.inventory_item_id = x_item_id
                           AND MIC.organization_id = x_ship_to_org)))
      AND    ASL.asl_status_id = ASR.status_id
      AND    ASR.business_rule = x_action;
*/

/*1517028 Breaking sql statement into three diffrent sql statements to
  remove OR between checks for item_id and category id...never combine them...*/

/* Bug: 1968168 Replace  PO_APPROVED_SUPPLIER_LIST with
        PO_APPROVED_SUPPLIER_LIS_VAL_V and PO_ASL_STATUS_RULES ASR with
        PO_ASL_STATUS_RULES_V
*/

  SELECT sum(decode(ASR.allow_action_flag, 'Y', 1, -100)) INTO x_asl_status
      FROM PO_APPROVED_SUPPLIER_LIS_VAL_V ASL, PO_ASL_STATUS_RULES_V ASR
      WHERE  ASL.using_organization_id IN (nvl(x_ship_to_org,-1), -1)
      AND    ASL.vendor_id = x_vendor_id
      AND    nvl(ASL.vendor_site_id, nvl(x_vendor_site_id,-1)) = nvl(x_vendor_site_id,-1)
      AND    ASL.item_id = x_item_id
      AND    ASL.asl_status_id = ASR.status_id
      AND    ASR.business_rule = x_action;

/* Bug: 1968168 Replace  PO_APPROVED_SUPPLIER_LIST with
        PO_APPROVED_SUPPLIER_LIS_VAL_V and PO_ASL_STATUS_RULES ASR with
        PO_ASL_STATUS_RULES_V
*/
  IF x_asl_status IS NULL THEN
    SELECT sum(decode(ASR.allow_action_flag, 'Y', 1, -100)) INTO x_asl_status
      FROM PO_APPROVED_SUPPLIER_LIS_VAL_V ASL, PO_ASL_STATUS_RULES_V ASR
      WHERE  ASL.using_organization_id IN (nvl(x_ship_to_org,-1), -1)
      AND    ASL.vendor_id = x_vendor_id
      AND    nvl(ASL.vendor_site_id, nvl(x_vendor_site_id,-1)) = nvl(x_vendor_site_id,-1)
      AND    ASL.category_id = x_category_id
      AND    ASL.asl_status_id = ASR.status_id
      AND    ASR.business_rule = x_action;
   END IF;

/* Bug: 1968168 Replace  PO_APPROVED_SUPPLIER_LIST with
        PO_APPROVED_SUPPLIER_LIS_VAL_V and PO_ASL_STATUS_RULES ASR with
        PO_ASL_STATUS_RULES_V
*/

  IF x_asl_status IS NULL THEN

    -- Bug 2072963
    -- Take out of IN statement to force using index,
    -- avoiding full-table scan
/*
    SELECT sum(decode(ASR.allow_action_flag, 'Y', 1, -100)) INTO x_asl_status
      FROM PO_APPROVED_SUPPLIER_LIS_VAL_V ASL, PO_ASL_STATUS_RULES_V ASR
      WHERE  ASL.using_organization_id IN (nvl(x_ship_to_org,-1), -1)
      AND    ASL.vendor_id = x_vendor_id
      AND    nvl(ASL.vendor_site_id, nvl(x_vendor_site_id,-1)) = nvl(x_vendor_site_id,-1)
      AND    ASL.category_id in (SELECT MIC.category_id
                           FROM   MTL_ITEM_CATEGORIES MIC
                           WHERE MIC.inventory_item_id = x_item_id
                           AND MIC.organization_id = x_ship_to_org)
      AND    ASL.asl_status_id = ASR.status_id
      AND    ASR.business_rule = x_action;

*/
    for v_category in c_category_ids(x_item_id, x_ship_to_org) loop

      SELECT sum(decode(ASR.allow_action_flag, 'Y', 1, -100)) INTO x_asl_s
        FROM PO_APPROVED_SUPPLIER_LIS_VAL_V ASL, PO_ASL_STATUS_RULES_V ASR
        WHERE  ASL.using_organization_id IN (nvl(x_ship_to_org,-1), -1)
        AND    ASL.vendor_id = x_vendor_id
        AND    nvl(ASL.vendor_site_id, nvl(x_vendor_site_id,-1)) = nvl(x_vendor_site_id,-1)
        AND    ASL.category_id = v_category.category_id
        AND    ASL.asl_status_id = ASR.status_id
        AND    ASR.business_rule = x_action;

      if (x_asl_s is not null) then
        if (x_asl_status is null) then
          x_asl_status := x_asl_s;
        else
          x_asl_status := x_asl_status + x_asl_s;
        end if;
      end if;

    end loop;

  END IF;

  -- If there is a debarred asl then return 0 else return 1. If no asl then
  -- x_asl_status will be null, return -1
  IF x_asl_status < 0 THEN
    RETURN 0;
  ELSIF x_asl_status IS NOT NULL THEN
    RETURN 1;
  ELSE
    RETURN -1;
  END IF;

  --dbms_output.put_line('Exiting check_asl_action');

EXCEPTION
  WHEN OTHERS THEN
    -- po_message_s.sql_error('check_asl_action', x_progress, sqlcode);
    RAISE;
end check_asl_action;


procedure update_vendor_status(x_organization_id        in     number,
                               x_vendor_id              in     number,
                               x_status                 in     varchar2,
                               x_vendor_site_id         in     number default null,
                               x_item_id                in     number default null,
                               x_global_asl_update      in     varchar2 ,
                               x_org_id                 in     number default null,
                               x_return_code            in out NOCOPY varchar2) is
x_status_id  number;

-- <ASL ERECORD FPJ START>
l_api_name          CONSTANT VARCHAR2(30) := 'update_vendor_status';
l_module            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                            G_MODULE_PREFIX || l_api_name || '.';

l_asl_id_tbl    PO_TBL_NUMBER;
l_return_status VARCHAR2(1);
l_progress      VARCHAR2(3);
l_msg_buf       VARCHAR2(2000);
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);
-- <ASL ERECORD FPJ END>

begin

    -- <ASL ERECORD FPJ START>
    IF (g_debug_stmt) THEN
        PO_DEBUG.debug_begin
        ( p_log_head   => l_module
        );
    END IF;
    -- <ASL ERECORD FPJ END>

    l_progress := '000';

    select status_id
           into x_status_id
    from   po_asl_statuses
    where  status = x_status;

    if NVL(x_global_asl_update,'N') = 'N' then
        l_progress := '010';

        update po_approved_supplier_list pasl
               set pasl.asl_status_id = x_status_id
        where  pasl.using_organization_id = x_organization_id
        and    pasl.vendor_id = x_vendor_id
        and    pasl.vendor_site_id = NVL(x_vendor_site_id,pasl.vendor_site_id)
        and    pasl.item_id = NVL(x_item_id,pasl.item_id)
        and    exists (select null from po_vendor_sites_all pvsa
                       where NVL(pvsa.org_id, -99) =
                             NVL(x_org_id, NVL(pvsa.org_id, -99))
                       and   pvsa.vendor_site_id = pasl.vendor_site_id)
        RETURNING PASL.asl_id           -- <ASL ERECORD FPJ>
        BULK COLLECT INTO l_asl_id_tbl; -- <ASL ERECORD FPJ>
    else
        l_progress := '020';

        update po_approved_supplier_list pasl
               set pasl.asl_status_id = x_status_id
        where  pasl.using_organization_id in (x_organization_id,-1)
        and    pasl.vendor_id = x_vendor_id
        and    pasl.vendor_site_id = NVL(x_vendor_site_id,pasl.vendor_site_id)
        and    pasl.item_id = NVL(x_item_id,pasl.item_id)
        and    exists (select null from po_vendor_sites_all pvsa
                       where NVL(pvsa.org_id, -99) =
                             NVL(x_org_id, NVL(pvsa.org_id, -99))
                       and   pvsa.vendor_site_id = pasl.vendor_site_id)
        RETURNING PASL.asl_id           -- <ASL ERECORD FPJ>
        BULK COLLECT INTO l_asl_id_tbl; -- <ASL ERECORD FPJ>

    end if;
    if SQL%rowcount = 0 then
        x_return_code := 'F';
    else
        x_return_code := 'S';
    end if;

    -- <ASL ERECORD FPJ START>
    FOR i IN 1..l_asl_id_tbl.COUNT LOOP

      l_progress := '030';

      l_return_status  := FND_API.G_RET_STS_SUCCESS;

      IF (g_debug_stmt) THEN
        PO_DEBUG.debug_stmt
        ( p_log_head    => l_module,
          p_token       => l_progress,
          p_message     => 'Call PO_BUSINESSEVENT_PVT.raise_event'
        );
      END IF;

      -- Raise ASL Business Event
      PO_BUSINESSEVENT_PVT.raise_event
      (
          p_api_version      =>    1.0,
          x_return_status    =>    l_return_status,
          x_msg_count        =>    l_msg_count,
          x_msg_data         =>    l_msg_data,
          p_event_name       =>    'oracle.apps.po.event.create_asl',
          p_entity_name      =>    'ASL',
          p_entity_id        =>    l_asl_id_tbl(i)
      );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          l_progress := '040';

          IF (g_debug_stmt) THEN

              l_msg_buf := FND_MSG_PUB.Get( p_msg_index => 1,
                                            p_encoded   => 'F');

              l_msg_buf := SUBSTRB('ASL' || l_asl_id_tbl(i) || 'errors out at'
                                   || l_progress || l_msg_buf, 1, 2000);

              PO_DEBUG.debug_stmt
              ( p_log_head      => l_module,
                p_token         => l_progress,
                p_message       => l_msg_buf
              );

          END IF;
      ELSE
          IF (g_debug_stmt) THEN

              l_msg_buf := SUBSTRB('ASL' || l_asl_id_tbl(i) ||
                                   'raised business event successfully',
                                   1, 2000);

              PO_DEBUG.debug_stmt
              ( p_log_head      => l_module,
                p_token         => l_progress,
                p_message       => l_msg_buf
              );
          END IF;
      END IF;  -- IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)

      PO_ASL_SV.raise_asl_eres_event
      ( x_return_status => l_return_status,
        p_asl_id        => l_asl_id_tbl(i),
        p_action        => PO_ASL_SV.G_EVENT_UPDATE,
        p_calling_from  => 'PO_ASL_SV.udpate_vendor_status',
        p_ackn_note     => NULL,
        p_autonomous_commit => FND_API.G_FALSE
      );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END LOOP;

    IF (g_debug_stmt) THEN
        PO_DEBUG.debug_end
        ( p_log_head   => l_module
        );
    END IF;

    -- <ASL ERECORD FPJ END>

exception
when no_data_found then
    x_return_code := 'F';
when others then
    x_return_code := 'F';
    raise;
end update_vendor_status;



/*=============================================================================

  PROCEDURE NAME:	get_startup_values()

===============================================================================*/
procedure get_startup_values(x_current_form_org		 in     number,
			     x_po_item_master_org_id	 in out NOCOPY number,
			     x_po_category_set_id	 in out NOCOPY number,
			     x_po_structure_id		 in out NOCOPY number,
			     x_default_status_id	 in out NOCOPY number,
			     x_default_status		 in out NOCOPY varchar2,
			     x_default_business_code	 in out NOCOPY varchar2,
			     x_default_business		 in out NOCOPY varchar2,
			     x_chv_install 		 in out NOCOPY varchar2,
			     x_chv_cum_flag		 in out NOCOPY varchar2) is

  x_progress varchar2(3) := '010';
  dummy      number;

begin

  x_chv_cum_flag := 'N';

  po_core_s.get_item_category_structure(x_po_category_set_id,
					x_po_structure_id);

  x_progress := '020';

  x_chv_install := po_core_s.get_product_install_status('CHV');

  /* If Supplier Scheduling is installed, check to see whether we have
  ** an open CUM period for the current form organization.
  */

  if (x_chv_install = 'I') then

    x_progress := '021';

    SELECT count(1)
    INTO   dummy
    FROM   chv_cum_periods
    WHERE  organization_id = x_current_form_org
    AND    sysdate between cum_period_start_date and
	   cum_period_end_date;

    if (dummy >= 1) then
      x_chv_cum_flag := 'Y';
    end if;
  end if;

  x_progress := '030';

  --Bug10229244, when access mode is 'M', the fsp synonym contains
  --multiple rows, caused the sql raise exception
  --Move the logic of getting fsp.inventory_organization_id to the
  --calling procedure
  SELECT past.status_id,
	 past.status,
	 plc.lookup_code,
	 plc.displayed_field
	 --fsp.inventory_organization_id
  INTO   x_default_status_id,
	 x_default_status,
	 x_default_business_code,
	 x_default_business
	 --x_po_item_master_org_id
  FROM   po_asl_statuses  	      past,
	 po_lookup_codes	      plc
	 --financials_system_parameters fsp
  WHERE  past.asl_default_flag = 'Y'
  AND	 plc.lookup_type = 'ASL_VENDOR_BUSINESS_TYPE'
  AND	 plc.lookup_code = 'DIRECT';

exception
  when others then
    --dbms_output.put_line(x_progress);
    po_message_s.sql_error('get_startup_values', x_progress, sqlcode);
    raise;
end get_startup_values;

/*=============================================================================

  FUNCTION NAME:	check_record_unique

=============================================================================*/
function check_record_unique(x_manufacturer_id	   number,
			  x_vendor_id	           number,
			  x_vendor_site_id         number,
			  x_item_id	           number,
			  x_category_id            number,
			  x_using_organization_id  number) return boolean is

    x_record_unique	BOOLEAN;
    x_dummy_count	NUMBER := 0;
    x_dummy_count_local_attr	NUMBER := 0;

begin

    -- Check that the record is unique (i.e., no other
    -- record contains the same supplier, using_org
    -- and item/commodity).

    if (x_manufacturer_id is not null) then

/*Bug 1261392
  A performance issue and to use the index on item id in
  po_approved_supplier_list split one query into two as below
  based on the value of x_item_id.
*/

-- bug3648471
-- item_id and category_id are mutually exclusive fields. Therefore
-- when item_id is not null we can assume that item_id is null, and vice versa.
-- Thus changing the query to skip unnecessary checks for performance
-- reasons.

     	if (x_item_id is not null) then

           SELECT count(1)
           INTO   x_dummy_count
           FROM   po_approved_supplier_list pasl
           WHERE  pasl.manufacturer_id = x_manufacturer_id
           AND    pasl.using_organization_id = x_using_organization_id
           AND    pasl.item_id = x_item_id;
    	else

           SELECT count(1)
           INTO   x_dummy_count
           FROM   po_approved_supplier_list pasl
           WHERE  pasl.manufacturer_id = x_manufacturer_id
           AND    pasl.using_organization_id = x_using_organization_id
           AND    pasl.category_id = x_category_id;

    	end if;
    else

/*Bug 1261392
  A performance issue and to use the index on item id in
  po_approved_supplier_list split one query into two as below
  based on the value of x_item_id.
*/
       if (x_item_id is not null) then

      	   SELECT count(1)
           INTO   x_dummy_count
           FROM   po_approved_supplier_list pasl
           WHERE  pasl.vendor_id = x_vendor_id
           AND    ((pasl.vendor_site_id is null AND x_vendor_site_id is null) OR
	          (pasl.vendor_site_id = x_vendor_site_id))
           AND    pasl.using_organization_id = x_using_organization_id
	   AND    pasl.item_id = x_item_id;
       else

      	   SELECT count(1)
           INTO   x_dummy_count
           FROM   po_approved_supplier_list pasl
           WHERE  pasl.vendor_id = x_vendor_id
           AND    ((pasl.vendor_site_id is null AND x_vendor_site_id is null) OR
	          (pasl.vendor_site_id = x_vendor_site_id))
           AND    pasl.using_organization_id = x_using_organization_id
           AND    pasl.category_id = x_category_id;

       end if;

     -- if this is not a global entry check to see if local
     -- attributes exist for a global entry for that vendor/item/using org

     if (x_using_organization_id <> -1) then
      SELECT count(1)
      INTO   x_dummy_count_local_attr
      FROM   po_approved_supplier_list pasl,po_asl_attributes paa
      WHERE  pasl.vendor_id = x_vendor_id
      AND    ((pasl.vendor_site_id is null AND x_vendor_site_id is null) OR
              (pasl.vendor_site_id = x_vendor_site_id))
      AND    pasl.using_organization_id = -1
      AND    paa.using_organization_id = x_using_organization_id
      AND    pasl.asl_id = paa.asl_id
      AND    ((pasl.item_id is null AND x_item_id is null) OR
              (pasl.item_id = x_item_id))
      AND    ((pasl.category_id is null AND x_category_id is null) OR
              (pasl.category_id = x_category_id));

     end if;
    end if;

    if (x_dummy_count >= 1 or x_dummy_count_local_attr >= 1) then
	return FALSE;
    else
	return TRUE;
    end if;

exception
    when others then
        raise;
end;

-- <ASL ERECORD FPJ START>


-----------------------------------------------------------------------
--Start of Comments
--Name: raise_asl_eres_event
--Pre-reqs:
--Modifies:
--Locks:
--  None
--Function: Call QA API to raise a ERES business event, which creates an
--          eRecord for the ASL. This procedure will also acknowledge
--          the eRecord that is created
--Parameters:
--IN:
--p_asl_id
--  primary key of the ASL
--p_action
--  Type of action done to the ASL
--  PO_ASL_SV.G_EVENT_INSERT: ASL is inserted
--  PO_ASL_SV.G_EVENT_UPDATE: ASL is updated
--p_calling_from
--  Identifier of the caller
--p_ackn_note
--  Note for the acknowledge
--p_autonomous_commit
--  Whehter the acknowledge should be performed as an autonomous transaction
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE raise_asl_eres_event
( x_return_status     OUT NOCOPY VARCHAR2,
  p_asl_id            IN         NUMBER,
  p_action            IN         VARCHAR2,
  p_calling_from      IN         VARCHAR2,
  p_ackn_note         IN         VARCHAR2,
  p_autonomous_commit IN         VARCHAR2
) IS

l_api_name          CONSTANT VARCHAR2(30) := 'raise_asl_eres_event';
l_module            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                            G_MODULE_PREFIX || l_api_name || '.';

l_progress          VARCHAR2(3);

l_child_erecords    QA_EDR_STANDARD.ERECORD_ID_TBL_TYPE;
l_event             QA_EDR_STANDARD.ERES_EVENT_REC_TYPE;
l_erecord_id        NUMBER;
l_event_status      VARCHAR2(20);
l_return_status     VARCHAR2(1);
l_msg_count         NUMBER;
l_msg_data          VARCHAR2(2000);

l_subroutine        VARCHAR2(100);

l_identifier        FND_NEW_MESSAGES.message_text%TYPE;
l_identifier_val    VARCHAR2(2000);

BEGIN
    l_progress := '000';

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (g_debug_stmt) THEN
        PO_DEBUG.debug_begin
        ( p_log_head   => l_module
        );
    END IF;

    IF (g_eres_enabled <> 'Y') THEN
        IF (g_debug_stmt) THEN
            PO_DEBUG.debug_stmt
            ( p_log_head => l_module,
              p_token    => l_progress,
              p_message  => 'g_eres_enabled is ' || g_eres_enabled ||
                            'Quitting procedure raise_asl_eres_event'
            );
        END IF;

        RETURN;
    END IF;

    get_identifier
    ( p_asl_id => p_asl_id,
      x_identifier => l_identifier,
      x_identifier_value => l_identifier_val
    );


    l_event.param_name_1  := 'DEFERRED';
    l_event.param_value_1 := 'Y';

    l_event.param_name_2  := 'POST_OPERATION_API';
    l_event.param_value_2 := 'NONE';

    l_event.param_name_3  := 'PSIG_USER_KEY_LABEL';
    l_event.param_value_3 := l_identifier;

    l_event.param_name_4  := 'PSIG_USER_KEY_VALUE';
    l_event.param_value_4 := l_identifier_val;

    l_event.param_name_5  := 'PSIG_TRANSACTION_AUDIT_ID';
    l_event.param_value_5 := '-1';

    l_event.param_name_6  := '#WF_SOURCE_APPLICATION_TYPE';
    l_event.param_value_6 := 'DB';

    l_event.param_name_7  := '#WF_SIGN_REQUESTER';
    l_event.param_value_7 := FND_GLOBAL.user_name;


    IF (p_action = G_EVENT_INSERT) THEN
        l_progress := '010';
        l_event.event_name := 'oracle.apps.po.asl.create';
    ELSIF (p_action = G_EVENT_UPDATE) THEN
        l_progress := '020';
        l_event.event_name := 'oracle.apps.po.asl.update';
    ELSE
        l_progress := '030';
        RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_event.event_key := p_asl_id;
    l_event.event_status := 'SUCCESS';

    IF (g_debug_stmt) THEN
        PO_DEBUG.debug_var(l_module, l_progress, 'l_event.event_name',
                           l_event.event_name);

        PO_DEBUG.debug_var(l_module, l_progress, 'l_event.event_key',
                           l_event.event_key);
    END IF;

    -- Call QA API to raise ERES event

    l_progress := '040';

    QA_EDR_STANDARD.raise_eres_event
    ( p_api_version         => 1.0,
      p_init_msg_list       => FND_API.G_TRUE,
      p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
      x_return_status       => l_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      p_child_erecords      => l_child_erecords,
      x_event               => l_event
    );

    IF (g_debug_stmt) THEN
        PO_DEBUG.debug_stmt
        ( p_log_head => l_module,
          p_token    => l_progress,
          p_message  => 'Called raise_eres_event. status = ' || l_event.event_status
        );


        PO_DEBUG.debug_var(l_module, l_progress, 'l_event.erecord_id',
                           l_event.erecord_id);
    END IF;

    --Bug 4745270 dont error incase of  'PENDING' status
    -- when raise event is called in DB mode, it runs asynchronously
    -- and returns with pending status
    IF (l_event.event_status NOT IN ('SUCCESS', 'NOACTION','PENDING')) THEN
        l_progress := '050';
        l_subroutine := 'QA_EDR_STANDARD.raise_eres_event';
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (l_event.erecord_id > 0) THEN
        l_progress := '060';

        QA_EDR_STANDARD.send_ackn
        ( p_api_version     => 1.0,
          p_init_msg_list   => FND_API.G_TRUE,
          x_return_status   => l_return_status,
          x_msg_count       => l_msg_count,
          x_msg_data        => l_msg_data,
          p_event_name      => l_event.event_name,
          p_event_key       => l_event.event_key,
          p_erecord_id      => l_event.erecord_id,
          p_trans_status    => 'SUCCESS',
          p_ackn_by         => p_calling_from,
          p_ackn_note       => p_ackn_note,
          p_autonomous_commit   => p_autonomous_commit
        );

        IF (g_debug_stmt) THEN
            PO_DEBUG.debug_stmt
            ( p_log_head => l_module,
              p_token    => l_progress,
              p_message  => 'Called send_ackn. status = ' ||
                            l_event.event_status
            );

        END IF;

       --Bug 4745270 dont error incase of  'PENDING' status
        IF (l_event.event_status NOT IN ('SUCCESS', 'NOACTION','PENDING')) THEN
            l_progress := '070';
            l_subroutine := 'QA_EDR_STANDARD.send_ackn';
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    IF (g_debug_stmt) THEN
        PO_DEBUG.debug_end
        ( p_log_head   => l_module
        );
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF (g_debug_unexp) THEN
            PO_DEBUG.debug_exc
            ( p_log_head    => l_module,
              p_progress    => l_progress
            );


            IF (l_msg_count IS NOT NULL) THEN
                FOR i IN 1..l_msg_count LOOP
                    l_msg_data := FND_MSG_PUB.get
                                  ( p_msg_index => i,
                                    p_encoded  => 'F');
                    PO_DEBUG.debug_stmt
                    ( p_log_head => l_module,
                      p_token    => l_progress,
                      p_message  => l_msg_data);
                END LOOP;
            END IF;
        END IF;

        IF (FND_MSG_PUB.G_FIRST IS NOT NULL) THEN
            l_msg_data := FND_MSG_PUB.get(p_msg_index => FND_MSG_PUB.G_FIRST,
                                          p_encoded   => 'F');
        END IF;

        FND_MESSAGE.set_name  ('PO', 'PO_ALL_TRACE_ERROR_WITH_MSG');
        FND_MESSAGE.set_token ('FILE', l_api_name);
        FND_MESSAGE.set_token ('ERR_NUMBER', l_progress);
        FND_MESSAGE.set_token ('SUBROUTINE', l_subroutine);
        FND_MESSAGE.set_token ('ERROR_MSG', l_msg_data);

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF (g_debug_unexp) THEN
            PO_DEBUG.debug_exc
            ( p_log_head    => l_module,
              p_progress    => l_progress
            );
        END IF;

        FND_MSG_PUB.build_exc_msg
        ( p_pkg_name => g_pkg_name,
          p_procedure_name => l_api_name
        );

END raise_asl_eres_event;


-----------------------------------------------------------------------
--Start of Comments
--Name: get_identifier
--Pre-reqs:
--Modifies:
--Locks:
--  None
--Function: Get identifier and identifier value for display purpose on
--          an ASL eRecord
--Parameters:
--IN:
--p_asl_id
--  primary key of the ASL
--IN OUT:
--OUT:
--x_identifier
--  identifier for ASL eRecord. It's a description what identifier_value
--  contains
--x_identigier_value
--  a string to identify an ASL
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE get_identifier
( p_asl_id           IN NUMBER,
  x_identifier       OUT NOCOPY VARCHAR2,
  x_identifier_value OUT NOCOPY VARCHAR2
) IS

l_api_name          CONSTANT VARCHAR2(30) := 'get_identifier';
l_module            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                            G_MODULE_PREFIX || l_api_name || '.';
l_progress          VARCHAR2(3);

l_using_org_id      PO_APPROVED_SUPPLIER_LIST.using_organization_id%TYPE;
l_organization      VARCHAR2(30);
l_item_id           PO_APPROVED_SUPPLIER_LIST.item_id%TYPE;
l_vendor_name       PO_VENDORS.vendor_name%TYPE;
l_vendor_site_code  PO_VENDOR_SITES_ALL.vendor_site_code%TYPE;
l_category_name     MTL_CATEGORIES_KFV.concatenated_segments%TYPE;
l_item_name         MTL_SYSTEM_ITEMS_KFV.concatenated_segments%TYPE;

BEGIN
    l_progress := '000';

    IF (g_debug_stmt) THEN
        PO_DEBUG.debug_begin
        ( p_log_head   => l_module
        );
    END IF;

    x_identifier := FND_MESSAGE.get_string('PO', 'PO_ASL_EREC_IDENTIFIER');

    SELECT PASL.using_organization_id,
           MP.organization_code,
           PASL.item_id,
           DECODE (PASL.vendor_business_type,
                   'MANUFACTURER', MM.manufacturer_name,
                   PV.vendor_name),
           PVS.vendor_site_code,
           MC.concatenated_segments,
           MSI.concatenated_segments
    INTO   l_using_org_id,
           l_organization,
           l_item_id,
           l_vendor_name,
           l_vendor_site_code,
           l_category_name,
           l_item_name
    FROM   po_approved_supplier_list PASL,
           mtl_parameters MP,
           mtl_manufacturers MM,
           po_vendors PV,
           po_vendor_sites_all PVS,
           mtl_system_items_kfv MSI,
           mtl_categories_kfv MC
    WHERE  PASL.asl_id = p_asl_id
    AND    PASL.using_organization_id = MP.organization_id (+)
    AND    PASL.manufacturer_id = MM.manufacturer_id (+)
    AND    PASL.vendor_id = PV.vendor_id (+)
    AND    PASL.vendor_site_id = PVS.vendor_site_id (+)
    AND    PASL.item_id = MSI.inventory_item_id (+)
    AND    PASL.owning_organization_id = NVL(MSI.organization_id,
                                             PASL.owning_organization_id)
    AND    PASL.category_id = MC.category_id (+);

    x_identifier_value := ' - ' || l_vendor_name || ' - ' ||
                          l_vendor_site_code || ' - ';

    IF ( l_using_org_id = -1 ) THEN
        l_organization := FND_MESSAGE.get_string('PO', 'PO_ASL_GLOBAL');
    END IF;

    IF ( l_item_id IS NOT NULL) THEN
        x_identifier_value := l_organization || x_identifier_value ||
                              l_item_name;
    ELSE
        x_identifier_value := l_organization || x_identifier_value ||
                              l_category_name;
    END IF;

    IF (g_debug_stmt) THEN
        PO_DEBUG.debug_end
        ( p_log_head   => l_module
        );
    END IF;


EXCEPTION
    WHEN OTHERS THEN
        IF (g_debug_unexp) THEN
            PO_DEBUG.debug_exc
            ( p_log_head    => l_module,
              p_progress    => l_progress
            );
        END IF;

        FND_MSG_PUB.build_exc_msg
        ( p_pkg_name => g_pkg_name,
          p_procedure_name => l_api_name
        );

        RAISE;

END get_identifier;



-----------------------------------------------------------------------
--Start of Comments
--Name: init_asl_activity_tbl
--Pre-reqs:
--Modifies:
--Locks:
--  None
--Function: Initialize g_asl_activities table, which is used to store
--          the ASL changes (Insert or Update) happening in the current
--          commit cycle. We need these data for calling ERES event
--          right before commit happens.
--Parameters:
--IN:
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE init_asl_activity_tbl IS

l_api_name          CONSTANT VARCHAR2(30) := 'init_asl_activity_tbl';
l_module            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                            G_MODULE_PREFIX || l_api_name || '.';
l_progress          VARCHAR2(3);
l_return_status     VARCHAR2(1);

BEGIN

    l_progress := '000';

    IF (g_debug_stmt) THEN
        PO_DEBUG.debug_begin
        ( p_log_head   => l_module
        );
    END IF;

    g_asl_activities.delete;
    g_asl_activities_index := 0;


    IF (g_debug_stmt) THEN
        PO_DEBUG.debug_end
        ( p_log_head   => l_module
        );
    END IF;


EXCEPTION
    WHEN OTHERS THEN
        IF (g_debug_unexp) THEN
            PO_DEBUG.debug_exc
            ( p_log_head    => l_module,
              p_progress    => l_progress
            );
        END IF;

        FND_MSG_PUB.build_exc_msg
        ( p_pkg_name => g_pkg_name,
          p_procedure_name => l_api_name
        );

        APP_EXCEPTION.raise_exception;

END init_asl_activity_tbl;

-----------------------------------------------------------------------
--Start of Comments
--Name: add_asl_activity
--Pre-reqs:
--Modifies:
--Locks:
--  None
--Function: Populate a row to g_asl_activities table to record a ASL
--          change (insert or update)
--Parameters:
--IN:
--p_asl_id
--  Unique identifier for the ASL
--p_action
--  Type of action for this ASL ('INSERT' or 'UPDATE')
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE add_asl_activity
( p_asl_id IN NUMBER,
  p_action IN VARCHAR2
) IS


l_api_name          CONSTANT VARCHAR2(30) := 'add_asl_activity';
l_module            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                            G_MODULE_PREFIX || l_api_name || '.';
l_progress          VARCHAR2(3);
l_return_status     VARCHAR2(1);

l_asl_activity asl_activity_rec;

BEGIN

    IF (g_debug_stmt) THEN
        PO_DEBUG.debug_begin
        ( p_log_head   => l_module
        );
    END IF;

    g_asl_activities_index := g_asl_activities_index + 1;
    g_asl_activities(g_asl_activities_index).asl_id := p_asl_id;
    g_asl_activities(g_asl_activities_index).action := p_action;


    IF (g_debug_stmt) THEN
        PO_DEBUG.debug_end
        ( p_log_head   => l_module
        );
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF (g_debug_unexp) THEN
            PO_DEBUG.debug_exc
            ( p_log_head    => l_module,
              p_progress    => l_progress
            );
        END IF;

        FND_MSG_PUB.build_exc_msg
        ( p_pkg_name => g_pkg_name,
          p_procedure_name => l_api_name
        );

        APP_EXCEPTION.raise_exception;

END add_asl_activity;

-----------------------------------------------------------------------
--Start of Comments
--Name: process_asl_activity_tbl
--Pre-reqs:
--Modifies:
--Locks:
--  None
--Function: Loop through each of the record in g_asl_activity and
--          raise an ERES event. The event type will be based on
--          the action column in the record.
--Parameters:
--IN:
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE process_asl_activity_tbl IS

l_api_name          CONSTANT VARCHAR2(30) := 'process_asl_activity_tbl';
l_module            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                            G_MODULE_PREFIX || l_api_name || '.';
l_progress          VARCHAR2(3);
l_return_status     VARCHAR2(1);

BEGIN

    IF (g_debug_stmt) THEN
        PO_DEBUG.debug_begin
        ( p_log_head   => l_module
        );
    END IF;

    l_progress := '010';

    FOR i IN 1..g_asl_activities_index LOOP
        l_progress := '020';


        IF (g_debug_stmt) THEN
            PO_DEBUG.debug_stmt
            ( p_log_head => l_module,
              p_token    => l_progress,
              p_message  => 'Processing asl_id= ' || g_asl_activities(i).asl_id
                            || ', action= ' || g_asl_activities(i).action
            );
        END IF;

        PO_ASL_SV.raise_asl_eres_event
        ( x_return_status => l_return_status,
          p_asl_id        => g_asl_activities(i).asl_id,
          p_action        => g_asl_activities(i).action,
          p_calling_from  => 'PO_ASL_SV.process_asl_activity_tbl',
          p_ackn_note     => NULL,
          p_autonomous_commit => FND_API.G_FALSE
        );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            l_progress := '030';


            IF (g_debug_stmt) THEN
                PO_DEBUG.debug_stmt
                ( p_log_head => l_module,
                  p_token    => l_progress,
                  p_message  => 'PO_ASL_SV.raise_asl_eres_event failed ' ||
                                'with status ' || l_return_status
                );
            END IF;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END LOOP;

    -- bug3539651
    -- clean up pl/sql table once all the rows are processed
    init_asl_activity_tbl;

    IF (g_debug_stmt) THEN
        PO_DEBUG.debug_end
        ( p_log_head   => l_module
        );
    END IF;


EXCEPTION
    WHEN OTHERS THEN

        IF (g_debug_unexp) THEN
            PO_DEBUG.debug_exc
            ( p_log_head    => l_module,
              p_progress    => l_progress
            );
        END IF;

        APP_EXCEPTION.raise_exception;

END process_asl_activity_tbl;


-- <ASL ERECORD FPJ END>

END PO_ASL_SV;

/
