--------------------------------------------------------
--  DDL for Package Body INV_UI_TASK_LOVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_UI_TASK_LOVS" AS
/* $Header: INVUITAB.pls 120.3 2008/02/15 10:41:28 mporecha ship $ */
   PROCEDURE print_debug (
      p_err_msg VARCHAR2,
      p_level NUMBER DEFAULT 4
   )
   IS
      l_debug   NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN
      IF ( l_debug = 1 ) THEN
         inv_mobile_helper_functions.tracelog ( p_err_msg => p_err_msg,
                                                p_module  => 'INV_UI_TASK_LOVS',
                                                p_level   => p_level
                                              );
      END IF;
   END print_debug;

   PROCEDURE GET_TASKS (
      x_tasks     OUT NOCOPY t_genref,
      p_restrict_tasks IN VARCHAR,
      p_project_id IN VARCHAR
   )
   IS
   BEGIN
      OPEN x_tasks FOR
         SELECT   t.task_id,
                  NVL ( t.task_number, '  ' ),
                  NVL ( t.task_name, '  ' )
         FROM     pjm_tasks_mtll_v t
         WHERE    t.task_number LIKE ( p_restrict_tasks )
         AND      t.project_id = p_project_id
         ORDER BY 2;
   END GET_TASKS;

   PROCEDURE GET_MO_TASKS (
      x_tasks     OUT NOCOPY t_genref,
      p_restrict_tasks IN VARCHAR2,
      p_project_id IN NUMBER,
      p_organization_id IN NUMBER,
      p_mo_header_id IN NUMBER
   )
   IS
   BEGIN
      OPEN x_tasks FOR
         SELECT   t.task_id,
                  NVL ( t.task_number, ' ' ),
                  NVL ( t.task_name, ' ' )
         FROM     pjm_tasks_mtll_v t
         WHERE    t.task_number LIKE ( p_restrict_tasks )
         AND      t.project_id = p_project_id
         AND      t.task_id IN (
                     SELECT mtrl.task_id
                     FROM   mtl_txn_request_lines mtrl
                     WHERE  mtrl.organization_id = p_organization_id
                     AND    mtrl.header_id = p_mo_header_id )
         ORDER BY 2;
   END GET_MO_TASKS;

   PROCEDURE GET_CC_TASKS (
      x_tasks     OUT NOCOPY t_genref,
      p_restrict_tasks IN VARCHAR2,
      p_project_id IN NUMBER,
      p_organization_id IN NUMBER,
      p_cycle_count_id IN NUMBER,
      p_unscheduled_flag IN NUMBER
   )
   IS
   BEGIN
      IF p_unscheduled_flag = 2 THEN
         OPEN x_tasks FOR
            SELECT DISTINCT t.task_id,
                            NVL ( t.task_number, ' ' ),
                            NVL ( t.task_name, ' ' )
            FROM            pjm_tasks_mtll_v t,
                            mtl_cycle_count_entries mcce,
                            mtl_item_locations mil
            WHERE           t.project_id = p_project_id
            AND             mcce.organization_id = mil.organization_id
            AND             mcce.subinventory = mil.subinventory_code
            AND             mcce.locator_id = mil.inventory_location_id
            AND             mcce.organization_id = p_organization_id
            AND             mcce.cycle_count_header_id = p_cycle_count_id
            AND             t.task_id = mil.task_id
            AND             t.task_number LIKE ( p_restrict_tasks )
            AND             t.project_id = mil.project_id
            ORDER BY        2;
      ELSE
         OPEN x_tasks FOR
            SELECT   t.task_id,
                     NVL ( t.task_number, '  ' ),
                     NVL ( t.task_name, '  ' )
            FROM     pjm_tasks_mtll_v t
            WHERE    t.task_number LIKE ( p_restrict_tasks )
            AND      t.project_id = p_project_id
            ORDER BY 2;
      END IF;
   END;

   PROCEDURE GET_PHY_TASKS (
      x_tasks     OUT NOCOPY t_genref,
      p_restrict_tasks IN VARCHAR2,
      p_project_id IN NUMBER,
      p_organization_id IN NUMBER,
      p_dynamic_entry_flag IN NUMBER,
      p_physical_inventory_id IN NUMBER
   )
   IS
   BEGIN
      IF ( p_dynamic_entry_flag = 2 ) THEN
         OPEN x_tasks FOR
            SELECT   t.task_id,
                     NVL ( t.task_number, ' ' ),
                     NVL ( t.task_name, ' ' )
            FROM     pjm_tasks_mtll_v t,
                     mtl_physical_inventory_tags mpi,
                     mtl_item_locations mil
            WHERE    t.project_id = p_project_id
            AND      mil.inventory_location_id = mpi.locator_id
            AND      mil.organization_id = p_organization_id
            AND      mpi.physical_inventory_id = p_physical_inventory_id
            AND      t.task_number LIKE ( p_restrict_tasks )
            AND      mil.task_id = t.task_id
            AND      t.project_id = mil.project_id
            ORDER BY 2;
      ELSE
         OPEN x_tasks FOR
            SELECT   t.task_id,
                     NVL ( t.task_number, '  ' ),
                     NVL ( t.task_name, '  ' )
            FROM     pjm_tasks_mtll_v t
            WHERE    t.task_number LIKE ( p_restrict_tasks )
            AND      t.project_id = p_project_id
            ORDER BY 2;
      END IF;
   END;

   PROCEDURE get_rcv_po_tasks (
      X_TASKS     OUT NOCOPY t_genref,
      p_po_header_id IN NUMBER,
      p_po_line_id IN NUMBER,
      p_project_id IN NUMBER,
      p_task_number IN VARCHAR2,
      p_item_id   IN NUMBER,
      p_po_release_id IN NUMBER DEFAULT NULL
   )
   IS
      l_debug   NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN
      IF (l_debug = 1) THEN
        print_debug(' p_task_number:' || p_task_number);
        print_debug(' p_po_header_id:'|| p_po_header_id);
        print_debug(' p_po_line_id:'|| p_po_line_id);
        print_debug(' p_item_id:'|| p_item_id);
        print_debug(' p_po_release_id:'|| p_po_release_id);
      END IF;

      OPEN x_tasks FOR
	SELECT DISTINCT t.task_id,
	NVL ( t.task_number, '  ' ),
	NVL ( t.task_name, '  ' )
	FROM   pjm_tasks_mtll_v t,
	po_distributions_all pod,
	po_line_locations_all poll
	WHERE  pod.task_id = t.task_id
	AND    pod.po_header_id = p_po_header_id
	AND    pod.po_line_id = NVL ( p_po_line_id, pod.po_line_id )
	AND    pod.project_id = p_project_id
	AND    t.project_id = p_project_id
	AND    (    p_item_id IS NULL
		    OR ( pod.po_line_id IN ( SELECT pol.po_line_id
					     FROM   po_lines_all pol
					     WHERE  pol.item_id = p_item_id ) )
		    )
	  AND    (  p_po_release_id IS NULL
		    OR ( pod.po_release_id = p_po_release_id)
		    )
	    AND    pod.line_location_id = poll.line_location_id
	    AND    pod.po_line_id = poll.po_line_id
	    AND    Nvl(pod.po_release_id,-999) = Nvl(poll.po_release_id,-999)
	    AND    pod.po_header_id = poll.po_header_id
	    AND    Nvl(poll.closed_code, 'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING','CLOSED')
	    AND    poll.SHIPMENT_TYPE IN ('STANDARD','BLANKET','SCHEDULED')
	    AND    NVL(poll.APPROVED_FLAG,'N') = 'Y'
	    AND    NVL(poll.CANCEL_FLAG, 'N') = 'N'
	    AND    t.task_number LIKE ( p_task_number );
   END;

   /* Adding a new procedure as a part of fix for bug 6785303
    * For deliver transactions tasks are not limited to open shipments
    */

   PROCEDURE get_rcv_po_deliver_tasks (
      X_TASKS     OUT NOCOPY t_genref,
      p_po_header_id IN NUMBER,
      p_po_line_id IN NUMBER,
      p_project_id IN NUMBER,
      p_task_number IN VARCHAR2,
      p_item_id   IN NUMBER,
      p_po_release_id IN NUMBER DEFAULT NULL
   )
   IS
      l_debug   NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN
      IF (l_debug = 1) THEN
         print_debug(' p_task_number:' || p_task_number);
         print_debug(' p_po_header_id:'|| p_po_header_id);
         print_debug(' p_po_line_id:'|| p_po_line_id);
         print_debug(' p_item_id:'|| p_item_id);
         print_debug(' p_po_release_id:'|| p_po_release_id);
      END IF;

      OPEN x_tasks FOR
         SELECT DISTINCT t.task_id,
                NVL ( t.task_number, '  ' ),
                NVL ( t.task_name, '  ' )
         FROM   pjm_tasks_mtll_v t,
                po_distributions_all pod
         WHERE  pod.task_id = t.task_id
         AND    pod.po_header_id = p_po_header_id
         AND    pod.po_line_id = NVL ( p_po_line_id, pod.po_line_id )
         AND    pod.project_id = p_project_id
         AND    t.project_id = p_project_id
         AND    (  p_item_id IS NULL
                   OR ( pod.po_line_id IN ( SELECT pol.po_line_id
                                            FROM   po_lines_all pol
                                            WHERE  pol.item_id = p_item_id ) )
                )
         AND    (  p_po_release_id IS NULL
                   OR ( pod.po_release_id = p_po_release_id)
                )
         AND    t.task_number LIKE ( p_task_number );
   END;

   PROCEDURE get_rcv_req_tasks (
      X_TASKS     OUT NOCOPY t_genref,
      p_req_header_id IN NUMBER,
      p_project_id IN NUMBER,
      p_task_number IN VARCHAR2,
      p_item_id   IN NUMBER,
      p_lpn_id    IN NUMBER
   )
   IS
   BEGIN
      OPEN x_tasks FOR
         SELECT DISTINCT t.task_id,
                NVL ( t.task_number, '  ' ),
                NVL ( t.task_name, '  ' )
         FROM   pjm_tasks_mtll_v t,
                po_requisition_lines_all prl,
                po_req_distributions_all prd
         WHERE  prd.requisition_line_id = prl.requisition_line_id
         AND    prl.requisition_header_id = p_req_header_id
         AND    prd.project_id = p_project_id
         AND    t.project_id = p_project_id
         AND    prd.task_id = t.task_id
         AND    (    p_item_id IS NULL
                  OR ( prl.item_id = p_item_id ) )
         AND    (p_lpn_id IS NULL
                 OR (p_lpn_id IS NOT NULL
                     AND EXISTS(
                       SELECT wlc.parent_lpn_id
                       FROM   wms_lpn_contents wlc
                       WHERE  wlc.inventory_item_id = prl.item_id
                       AND    wlc.parent_lpn_id IN(
                         SELECT lpn_id
                         FROM   wms_license_plate_numbers
                         START WITH lpn_id = p_lpn_id
                         CONNECT BY parent_lpn_id = PRIOR lpn_id
                       )
                     )
                  )
                )
         AND    t.task_number LIKE ( p_task_number );
   END;

   PROCEDURE get_rcv_rma_tasks (
      X_TASKS     OUT NOCOPY t_genref,
      p_oe_header_id IN NUMBER,
      p_project_id IN NUMBER,
      p_task_number IN VARCHAR2,
      p_item_id   IN NUMBER
   )
   IS
   BEGIN
      OPEN x_tasks FOR
         SELECT DISTINCT t.task_id,
                NVL ( t.task_number, '  ' ),
                NVL ( t.task_name, '  ' )
         FROM   pjm_tasks_mtll_v t,
                oe_order_lines_all oel
         WHERE  oel.project_id = t.project_id
         AND    t.project_id = p_project_id
         AND    oel.task_id = t.task_id
         AND    oel.header_id = p_oe_header_id
         AND    (    p_item_id IS NULL
                  OR ( oel.inventory_item_id = p_item_id ) )
         AND    t.task_number LIKE ( p_task_number );
   END;

   PROCEDURE get_rcv_asn_tasks (
      X_TASKS     OUT NOCOPY t_genref,
      p_po_header_id IN NUMBER,
      p_shipment_id IN NUMBER,
      p_project_id IN NUMBER,
      p_task_number IN VARCHAR2,
      p_lpn_id    IN NUMBER DEFAULT NULL --ASN
   )
   IS
   BEGIN
      OPEN x_tasks FOR
         SELECT DISTINCT t.task_id,
                         NVL ( t.task_number, '  ' ),
                         NVL ( t.task_name, '  ' )
         FROM            pjm_tasks_mtll_v t,
                         po_distributions_all pod,
                         rcv_shipment_lines rsl
         WHERE           rsl.shipment_header_id = p_shipment_id
         AND             rsl.po_header_id =
                                      NVL ( p_po_header_id, rsl.po_header_id )
         AND             rsl.po_header_id = pod.po_header_id
         AND             rsl.po_line_id = pod.po_line_id(+)
         AND             rsl.po_line_location_id = pod.line_location_id(+)
         AND             t.project_id = p_project_id
         AND             pod.project_id = p_project_id
         AND             t.project_id = pod.project_id
         AND             t.task_id = pod.task_id
         AND             task_number LIKE ( p_task_number )
         AND             (p_lpn_id IS NULL
                          OR(p_lpn_id IS NOT NULL
                            AND EXISTS(
                              SELECT wlc.parent_lpn_id
                              FROM   wms_lpn_contents wlc
                              WHERE  wlc.inventory_item_id = rsl.item_id
                              AND    wlc.parent_lpn_id IN(
                                SELECT lpn_id
                                FROM   wms_license_plate_numbers
                                START WITH lpn_id = p_lpn_id
                                CONNECT BY parent_lpn_id = PRIOR lpn_id
                                )
                              )
                            )
                          )

  /*       AND             rsl.item_id IN (
                            SELECT wlc.inventory_item_id
                            FROM   wms_lpn_contents wlc,
                                   po_lines_all pol
                            WHERE  pol.item_id = wlc.inventory_item_id
                            AND    parent_lpn_id =
                                               NVL ( p_lpn_id, parent_lpn_id )
                            AND    pod.po_line_id = pol.po_line_id )*/; --bug 2876336
   END;

   PROCEDURE GET_RCV_TASKS (
      X_TASKS     OUT NOCOPY t_genref,
      p_document_type IN VARCHAR2,
      p_po_header_id IN NUMBER,
      p_po_line_id IN NUMBER,
      p_oe_header_id IN NUMBER,
      p_req_header_id IN NUMBER,
      p_shipment_id IN NUMBER,
      p_project_id IN NUMBER,
      p_task_number IN VARCHAR2,
      p_item_id   IN NUMBER DEFAULT NULL,
      p_lpn_id    IN NUMBER DEFAULT NULL,
      p_po_release_id IN NUMBER DEFAULT NULL,
      p_is_deliver IN VARCHAR2 DEFAULT 'F'    --bug 6785303
   )
   IS
      l_debug NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN
      IF p_document_type = 'PO' THEN
          /* Adding IF-ELSE-END IF as part of fix for bug 6785303 */
          IF p_is_deliver = 'T' THEN
             print_debug('PO deliver type');
             get_rcv_po_deliver_tasks ( X_TASKS,
                                        p_po_header_id,
                                        p_po_line_id,
                                        p_project_id,
                                        p_task_number,
                                        p_item_id,
                                        p_po_release_id
                                      );
          ELSE
             print_debug('PO type');
             get_rcv_po_tasks ( X_TASKS,
                                p_po_header_id,
                                p_po_line_id,
                                p_project_id,
                                p_task_number,
                                p_item_id,
                                p_po_release_id
                              );
          END IF;
      ELSIF p_document_type = 'REQ' THEN
         get_rcv_req_tasks ( X_TASKS,
                             p_req_header_id,
                             p_project_id,
                             p_task_number,
                             p_item_id,
                             p_lpn_id
                           );
      ELSIF p_document_type = 'RMA' THEN
         get_rcv_rma_tasks ( X_TASKS,
                             p_oe_header_id,
                             p_project_id,
                             p_task_number,
                             p_item_id
                           );
      ELSIF p_document_type = 'ASN' THEN
         get_rcv_asn_tasks ( X_TASKS,
                             p_po_header_id,
                             p_shipment_id,
                             p_project_id,
                             p_task_number,
                             p_lpn_id
                           );
      END IF;
   END GET_RCV_TASKS;
END INV_UI_TASK_LOVS;

/
