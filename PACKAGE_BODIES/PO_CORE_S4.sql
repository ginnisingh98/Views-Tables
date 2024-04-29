--------------------------------------------------------
--  DDL for Package Body PO_CORE_S4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CORE_S4" AS
/* $Header: POXCOC4B.pls 120.0.12010000.3 2011/03/03 06:56:23 sbontala ship $*/

--<Bug 11071489 : REQ_AUTOCREATE start>---
g_log_head    CONSTANT VARCHAR2(30) := 'po.plsql.PO_CORE_S4.';
g_debug_stmt  CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
--<REQ_AUTOCREATE end>---
/*===========================================================================

  PROCEDURE NAME:	cleanup_po_tables()

===========================================================================*/
PROCEDURE cleanup_po_tables is

  x_progress   varchar2(3)  := NULL;

BEGIN


    x_progress := '001';


    /* Delete the old notifications from the table. */

    /*  obsolete in R11
    DELETE FROM po_notifications pon
	WHERE pon.end_date_active < sysdate; */

    x_progress := '002';

    /* Delete the lot rows that were not processed */
    DELETE FROM rcv_lots_interface rli
        WHERE NOT EXISTS
            (SELECT rti.interface_transaction_id
             FROM   rcv_transactions_interface rti
             WHERE  rti.interface_transaction_id =
                    rli.interface_transaction_id);



    x_progress := '003';
    /* Delete the lot rows that were not processed */
    DELETE FROM rcv_serials_interface rsi
        WHERE NOT EXISTS
            (SELECT rti.interface_transaction_id
             FROM   rcv_transactions_interface rti
             WHERE  rti.interface_transaction_id =
                    rsi.interface_transaction_id);


    EXCEPTION
      WHEN OTHERS THEN
      po_message_s.sql_error('CLEANUP_PO_TABLES',x_progress,sqlcode);
      raise;

  END cleanup_po_tables;

/*===========================================================================

  PROCEDURE NAME:	get_mtl_parameters()

===========================================================================*/
PROCEDURE get_mtl_parameters (x_org_id			   IN     NUMBER,
			      x_org_code	  	   IN     VARCHAR2,
			      x_project_reference_enabled  IN OUT NOCOPY NUMBER,
		              x_project_control_level      IN OUT NOCOPY NUMBER) IS

  progress   varchar2(3)  := NULL;

BEGIN

    progress := '010';

    -- Support for Project Manufacturing
    -- Get the parameters from the Material_Parameters table

  IF x_org_id is NULL AND
     x_org_code is NULL THEN

    -- both org_id and org_code are not passed.
    -- return NULL to the caller

    x_project_reference_enabled := NULL;
    x_project_control_level     := NULL;

  ELSE

    SELECT mp.PROJECT_REFERENCE_ENABLED,
           mp.PROJECT_CONTROL_LEVEL
    INTO   x_project_reference_enabled,
	   x_project_control_level
    FROM   mtl_parameters mp
    WHERE  mp.organization_id    = NVL(x_org_id, mp.organization_id)
    AND   mp.organization_code  = NVL(x_org_code, mp.organization_code);

  END IF;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

    x_project_reference_enabled := NULL;
    x_project_control_level     := NULL;

  WHEN TOO_MANY_ROWS THEN

    x_project_reference_enabled := NULL;
    x_project_control_level     := NULL;

  WHEN OTHERS THEN
    po_message_s.sql_error('get_mtl_parameters', progress, sqlcode);
    raise;

END get_mtl_parameters;

--<Bug 11071489 : REQ_AUTOCREATE start>---
/*===========================================================================
  PROCEDURE NAME:	raise_business_event()

  DESCRIPTION:		The procedure raises business event in autocreate process
                        for the requisitions processed.
===========================================================================*/

PROCEDURE raise_business_event(x_event_name VARCHAR2 , x_parameter_list IN p_parameter_list)
IS
l_api_name VARCHAR2(30) := 'raise_business_event';
l_progress VARCHAR2(3) := '000';
l_parameter_list  wf_parameter_list_t := wf_parameter_list_t();
p_event_key number;

BEGIN

  IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(p_log_head => g_log_head||l_api_name);
  END IF;

  --Adding all the paramters passed from autocreate process into wf parameter list
  l_progress := '001';

    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(p_log_head => g_log_head||l_api_name);
  END IF;

    IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(p_log_head => g_log_head||l_api_name,
          p_token    => l_progress,
         p_message  => 'Count of Parameter List ' || x_parameter_list.COUNT);
     END IF;

   IF x_parameter_list.COUNT > 0 then
	   FOR i IN x_parameter_list.FIRST .. x_parameter_list.LAST LOOP


	    wf_event.AddParameterToList(p_name=>x_parameter_list(i).name,
				       p_value=>x_parameter_list(i).value,
				       p_parameterlist=>l_parameter_list);
	   END LOOP;

	 SELECT po_wf_itemkey_s.NEXTVAL INTO p_event_key FROM dual;

	  --Raising the autocreate.requisition business event
	  wf_event.raise( p_event_name =>x_event_name,
			  p_event_key => TO_CHAR(p_event_key),
			  p_parameters => l_parameter_list);

	  l_parameter_list.delete;
   END if;

  IF g_debug_stmt THEN
   PO_DEBUG.debug_end(p_log_head => g_log_head||l_api_name);
  END IF;

EXCEPTION

 WHEN OTHERS THEN
    po_message_s.sql_error('raise_business_event', l_progress, sqlcode);
    raise;

END raise_business_event;
---<REQ_AUTOCREATE- End>--

END po_core_s4;

/
