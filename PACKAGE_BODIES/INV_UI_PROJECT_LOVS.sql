--------------------------------------------------------
--  DDL for Package Body INV_UI_PROJECT_LOVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_UI_PROJECT_LOVS" AS
/* $Header: INVUIPRB.pls 120.5.12010000.2 2008/09/30 11:12:30 kkesavar ship $ */
   PROCEDURE print_debug (
      p_err_msg VARCHAR2,
      p_level NUMBER DEFAULT 4
   )
   IS
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      IF ( l_debug = 1 ) THEN
         inv_mobile_helper_functions.tracelog ( p_err_msg           => p_err_msg,
                                                p_module            => 'inv_PROJECT_LOVS',
                                                p_level             => p_level
                                              );
      END IF;
   END print_debug;

   /* Adding new procedure as a part of fix for bug6785303 */
   PROCEDURE GET_RCV_PO_DELIVER_PROJECTS (
      X_PROJECTS  OUT NOCOPY /* file.sql.39 change */ t_genref,
      p_po_header_id IN NUMBER,
      p_po_line_id IN NUMBER,
      p_project_number IN VARCHAR2,
      p_item_id   IN NUMBER DEFAULT NULL,
      p_po_release_id IN NUMBER DEFAULT NULL--BUG 4201013
   )
   IS
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
      l_no_proj_str VARCHAR2(2000);--BUG 4599723
   BEGIN
      l_no_proj_str := FND_MESSAGE.GET_STRING ( 'INV', 'INV_NO_PROJECT' );
      IF (l_debug = 1) THEN
	 print_debug(' l_no_proj_str:' || l_no_proj_str);
	 print_debug(' p_project_number:' || p_project_number);
	 print_debug(' p_po_header_id:'|| p_po_header_id);
	 print_debug(' p_po_line_id:'|| p_po_line_id);
	 print_debug(' p_item_id:'|| p_item_id);
	 print_debug(' p_po_release_id:'|| p_po_release_id);
      END IF;

      IF (l_no_proj_str IS NOT NULL AND l_no_proj_str NOT LIKE p_project_number) THEN
         OPEN x_projects FOR
           SELECT DISTINCT p.project_id,
                           p.project_number,
                           p.project_name
           FROM            po_distributions_all pod,
                           pjm_projects_mtll_v p
           WHERE           pod.project_id = p.project_id
           AND             pod.po_header_id = p_po_header_id
           AND             pod.po_line_id = NVL ( p_po_line_id, pod.po_line_id )
           AND             Nvl(pod.po_release_id,-999) = Nvl(p_po_release_id, Nvl(pod.po_release_id, -999))
           AND             (    p_item_id IS NULL
                                OR pod.po_line_id IN (
                                                      SELECT pol.po_line_id
                                                      FROM   po_lines_all pol
                                                      WHERE  pol.item_id = p_item_id
                                                      AND    pol.po_header_id = p_po_header_id
                                                      )
                                )
             AND            p.project_number LIKE ( p_project_number )
             AND            pod.project_id IS NOT NULL  ;
      ELSE
         OPEN x_projects FOR
           SELECT DISTINCT p.project_id,
                           p.project_number,
                           p.project_name
           FROM            po_distributions_all pod,
                           pjm_projects_mtll_v p
           WHERE           pod.project_id = p.project_id
           AND             pod.po_header_id = p_po_header_id
           AND             pod.po_line_id = NVL ( p_po_line_id, pod.po_line_id )
           AND             Nvl(pod.po_release_id,-999) = Nvl(p_po_release_id, Nvl(pod.po_release_id, -999))
           AND             (    p_item_id IS NULL
                                OR pod.po_line_id IN (
                                                      SELECT pol.po_line_id
                                                      FROM   po_lines_all pol
                                                      WHERE  pol.item_id = p_item_id
                                                      AND    pol.po_header_id = p_po_header_id
                                                      )
                                )
           AND            p.project_number LIKE ( p_project_number )
           AND            pod.project_id IS NOT NULL
         UNION ALL
           SELECT DISTINCT -9999 project_id,
                           l_no_proj_str project_number,
                           l_no_proj_str project_name
             FROM po_distributions_all pod
             WHERE pod.project_id is NULL
               AND pod.po_header_id = p_po_header_id
               AND pod.po_line_id = NVL (p_po_line_id ,POD.PO_LINE_ID )
               AND Nvl(pod.po_release_id,-999) = Nvl(p_po_release_id, Nvl(pod.po_release_id, -999))
               AND (p_item_id IS NULL OR pod.po_line_id IN ( SELECT pol.po_line_id
                                                             FROM po_lines_all pol
                                                             WHERE pol.item_id = p_item_id
                                                             AND pol.po_header_id=p_po_header_id)
                    )
               AND l_no_proj_str LIKE ( p_project_number ) ;
      END IF;

   END;

   PROCEDURE GET_RCV_PO_PROJECTS (
      X_PROJECTS  OUT NOCOPY /* file.sql.39 change */ t_genref,
      p_po_header_id IN NUMBER,
      p_po_line_id IN NUMBER,
      p_project_number IN VARCHAR2,
      p_item_id   IN NUMBER DEFAULT NULL,
      p_po_release_id IN NUMBER DEFAULT NULL--BUG 4201013
   )
   IS
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
      l_no_proj_str VARCHAR2(2000);--BUG 4599723
   BEGIN

      l_no_proj_str := FND_MESSAGE.GET_STRING ( 'INV', 'INV_NO_PROJECT' );
      IF (l_debug = 1) THEN
	 print_debug(' l_no_proj_str:' || l_no_proj_str);
	 print_debug(' p_project_number:' || p_project_number);
	 print_debug(' p_po_header_id:'|| p_po_header_id);
	 print_debug(' p_po_line_id:'|| p_po_line_id);
	 print_debug(' p_item_id:'|| p_item_id);
	 print_debug(' p_po_release_id:'|| p_po_release_id);
      END IF;

      --BUG 4599723
      --For performance reasons, remove the outer join on
      --pjm_projects_mtll_v; instead, use a union to retrieve
      --the no projects row.  Also, if user did not enter a string
      --like the no proj string, don't do the union
      IF (l_no_proj_str IS NOT NULL AND l_no_proj_str NOT LIKE p_project_number) THEN
	 OPEN x_projects FOR
	   SELECT DISTINCT p.project_id,
	                   p.project_number,
	                   p.project_name
	   FROM            po_distributions_all pod,
	                   pjm_projects_mtll_v p,
	                   po_line_locations_all poll
	   WHERE           pod.project_id = p.project_id
	   AND             pod.po_header_id = p_po_header_id
	   AND             pod.po_line_id = NVL ( p_po_line_id, pod.po_line_id )
	   AND             Nvl(pod.po_release_id,-999) = Nvl(p_po_release_id, Nvl(pod.po_release_id, -999))
	   AND             (    p_item_id IS NULL
				OR pod.po_line_id IN (
						      SELECT pol.po_line_id
						      FROM   po_lines pol
						      WHERE  pol.item_id = p_item_id
						      AND    pol.po_header_id = p_po_header_id
						      )
				)
	   AND             pod.line_location_id = poll.line_location_id
	   AND             pod.po_line_id = poll.po_line_id
	   AND             Nvl(pod.po_release_id,-999) = Nvl(poll.po_release_id,-999)
	   AND             pod.po_header_id = poll.po_header_id
	   AND             Nvl(poll.closed_code, 'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING','CLOSED')
	   AND             poll.SHIPMENT_TYPE IN ('STANDARD','BLANKET','SCHEDULED')
	   AND             NVL(poll.APPROVED_FLAG,'N') = 'Y'
	   AND             NVL(poll.CANCEL_FLAG, 'N') = 'N'
	   AND             p.project_number LIKE ( p_project_number )
	   AND             pod.project_id IS NOT NULL  ;
       ELSE
	 OPEN x_projects FOR
	   SELECT DISTINCT p.project_id,
                           p.project_number,
	                   p.project_name
	   FROM            po_distributions_all pod,
	                   pjm_projects_mtll_v p,
	                   po_line_locations_all poll
	   WHERE           pod.project_id = p.project_id
	   AND             pod.po_header_id = p_po_header_id
	   AND             pod.po_line_id = NVL ( p_po_line_id, pod.po_line_id )
	   AND             Nvl(pod.po_release_id,-999) = Nvl(p_po_release_id, Nvl(pod.po_release_id, -999))
	   AND             (    p_item_id IS NULL
				OR pod.po_line_id IN (
						      SELECT pol.po_line_id
						      FROM   po_lines_all pol /* bug 6785303 po_lines -> po_lines_all */
						      WHERE  pol.item_id = p_item_id
						      AND    pol.po_header_id = p_po_header_id
						      )
				)
	   AND             pod.line_location_id = poll.line_location_id
	   AND             pod.po_line_id = poll.po_line_id
	   AND             Nvl(pod.po_release_id,-999) = Nvl(poll.po_release_id,-999)
	   AND             pod.po_header_id = poll.po_header_id
	   AND             Nvl(poll.closed_code, 'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING','CLOSED')
	   AND             poll.SHIPMENT_TYPE IN ('STANDARD','BLANKET','SCHEDULED')
	   AND             NVL(poll.APPROVED_FLAG,'N') = 'Y'
	   AND             NVL(poll.CANCEL_FLAG, 'N') = 'N'
 	   AND             p.project_number LIKE ( p_project_number )
	   AND             pod.project_id IS NOT NULL
	 UNION ALL
	   SELECT DISTINCT -9999 project_id,
	                   l_no_proj_str project_number,
	                   l_no_proj_str project_name
	     FROM po_distributions_all pod,
	          po_line_locations_all poll
	     WHERE pod.project_id is NULL
	       AND pod.po_header_id = p_po_header_id
	       AND pod.po_line_id = NVL (p_po_line_id ,POD.PO_LINE_ID )
	       AND Nvl(pod.po_release_id,-999) = Nvl(p_po_release_id, Nvl(pod.po_release_id, -999))
	       AND (p_item_id IS NULL OR pod.po_line_id IN ( SELECT pol.po_line_id
							     FROM po_lines pol
							     WHERE pol.item_id = p_item_id
							     AND pol.po_header_id=p_po_header_id)
		   )
	       AND pod.line_location_id = poll.line_location_id
	       AND pod.po_line_id = poll.po_line_id
	       AND Nvl(pod.po_release_id,-999) = Nvl(poll.po_release_id,-999)
	       AND pod.po_header_id = poll.po_header_id
	       AND Nvl(poll.closed_code, 'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING','CLOSED')
	       AND poll.SHIPMENT_TYPE IN ('STANDARD','BLANKET','SCHEDULED')
	       AND NVL(poll.APPROVED_FLAG,'N') = 'Y'
	       AND NVL(poll.CANCEL_FLAG, 'N') = 'N'
	       AND l_no_proj_str LIKE ( p_project_number ) ;
      END IF;
   END;

   PROCEDURE GET_RCV_ASN_PROJECTS (
      X_PROJECTS  OUT NOCOPY /* file.sql.39 change */ t_genref,
      p_shipment_header_id IN NUMBER,
      p_project_number IN VARCHAR2,
      p_po_header_id IN NUMBER,
      p_lpn_id    IN NUMBER DEFAULT NULL
   )
   IS
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
      l_no_proj_str VARCHAR2(2000);
   BEGIN
      l_no_proj_str := FND_MESSAGE.GET_STRING ( 'INV', 'INV_NO_PROJECT' );
      IF (l_debug = 1) THEN
	 print_debug(' l_no_proj_str:' || l_no_proj_str);
      END IF;

      --    print_debug('FOR ASN ' || p_shipment_header_id || ' for lpn ' || p_lpn_id || ' Prj: ' || nvl(p_project_number,'@@@@') || ' PoHeader: ' || nvl(p_po_header_id,-9999));

      --BUG 4599723
      --For performance reasons, remove the outer join on
      --pjm_projects_mtll_v; instead, use a union to retrieve
      --the no projects row.  Also, if user did not enter a string
      --like the no proj string, don't do the union
      IF (l_no_proj_str IS NOT NULL AND l_no_proj_str NOT LIKE p_project_number) THEN
	 OPEN x_projects FOR
	   SELECT DISTINCT p.project_id,
                           p.project_number,
                           p.project_name
	   FROM            po_distributions_all pod,
	                   pjm_projects_mtll_v p,
                           rcv_shipment_lines rsl
	   WHERE            pod.project_id IS NOT NULL
	     AND             pod.po_header_id = rsl.po_header_id
	     AND             pod.project_id = p.project_id
	     AND             pod.po_header_id = NVL ( p_po_header_id, pod.po_header_id )
	     AND             p.project_number LIKE ( p_project_number )
	     AND             rsl.shipment_header_id = p_shipment_header_id
	     AND             ( (p_lpn_id IS NULL) OR
			       (p_lpn_id IS NOT NULL AND EXISTS
				( SELECT wlc.inventory_item_id
				  FROM   wms_lpn_contents wlc
				  WHERE  wlc.inventory_item_id = rsl.item_id
				  AND    wlc.parent_lpn_id IN
                                  ( SELECT lpn_id
                                    FROM   wms_license_plate_numbers
                                    START WITH lpn_id = p_lpn_id
                                    CONNECT BY parent_lpn_id = PRIOR lpn_id
				    )
				  )
				)
			       );
       ELSE
	 OPEN x_projects FOR
	   SELECT DISTINCT p.project_id,
                           p.project_number,
                           p.project_name
	   FROM            po_distributions_all pod,
	                   pjm_projects_mtll_v p,
                           rcv_shipment_lines rsl
	   WHERE            pod.project_id IS NOT NULL
	     AND             pod.po_header_id = rsl.po_header_id
	     AND             pod.project_id = p.project_id
	     AND             pod.po_header_id = NVL ( p_po_header_id, pod.po_header_id )
	     AND             p.project_number LIKE ( p_project_number )
	     AND             rsl.shipment_header_id = p_shipment_header_id
	     AND             ( (p_lpn_id IS NULL) OR
			       (p_lpn_id IS NOT NULL AND EXISTS
				( SELECT wlc.inventory_item_id
				  FROM   wms_lpn_contents wlc
				  WHERE  wlc.inventory_item_id = rsl.item_id
				  AND    wlc.parent_lpn_id IN
                                  ( SELECT lpn_id
                                    FROM   wms_license_plate_numbers
                                    START WITH lpn_id = p_lpn_id
                                    CONNECT BY parent_lpn_id = PRIOR lpn_id
				    )
				  )
				)
			       )
        UNION ALL
         SELECT DISTINCT  -9999 project_id,
			 l_no_proj_str project_number,
			 l_no_proj_str project_name
         FROM            po_distributions_all pod,
                         rcv_shipment_lines rsl
	WHERE            pod.project_id IS NULL
         AND             pod.po_header_id = rsl.po_header_id
         AND             pod.po_header_id = NVL ( p_po_header_id, pod.po_header_id )
	 AND             l_no_proj_str LIKE ( p_project_number )
         AND             rsl.shipment_header_id = p_shipment_header_id
         AND             ( (p_lpn_id IS NULL) OR
                           (p_lpn_id IS NOT NULL AND EXISTS
                              ( SELECT wlc.inventory_item_id
                                FROM   wms_lpn_contents wlc
                                WHERE  wlc.inventory_item_id = rsl.item_id
                                AND    wlc.parent_lpn_id IN
                                  ( SELECT lpn_id
                                    FROM   wms_license_plate_numbers
                                    START WITH lpn_id = p_lpn_id
                                    CONNECT BY parent_lpn_id = PRIOR lpn_id
                                  )
                              )
                           )
                         );
      END IF;
   END;

   PROCEDURE GET_RCV_REQ_PROJECTS (
      X_PROJECTS  OUT NOCOPY /* file.sql.39 change */ t_genref,
      p_req_header_id IN NUMBER,
      p_project_number IN VARCHAR2,
      p_item_id   IN NUMBER DEFAULT NULL,
      p_lpn_id    IN NUMBER DEFAULT NULL
   )
   IS
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
      l_no_proj_str VARCHAR2(2000);
   BEGIN
      print_debug ( 'Receiving for req projects : for req ' || p_req_header_id
                  );
      l_no_proj_str := FND_MESSAGE.GET_STRING ( 'INV', 'INV_NO_PROJECT' );
      IF (l_debug = 1) THEN
	 print_debug(' l_no_proj_str:' || l_no_proj_str);
      END IF;

      --BUG 4599723
      --For performance reasons, remove the outer join on
      --pjm_projects_mtll_v; instead, use a union to retrieve
      --the no projects row.  Also, if user did not enter a string
      --like the no proj string, don't do the union
      IF (l_no_proj_str IS NOT NULL AND l_no_proj_str NOT LIKE p_project_number) THEN
      OPEN x_projects FOR
	SELECT DISTINCT p.project_id,
                        p.project_number,
                        p.project_name
	FROM            po_req_distributions_all prd,
                        pjm_projects_mtll_v p,
                        po_requisition_lines_all prl
	WHERE           prd.project_id IS NOT NULL
	  AND             prd.project_id = p.project_id
	  AND             prd.requisition_line_id = prl.requisition_line_id
	  AND             prl.requisition_header_id = p_req_header_id
	  AND             p.project_number LIKE p_project_number
	  AND             (    p_item_id IS NULL
			       OR prl.item_id = p_item_id )
	    AND            ( (p_lpn_id IS NULL) OR
			     (p_lpn_id IS NOT NULL AND EXISTS
			      ( SELECT wlc.inventory_item_id
				FROM   wms_lpn_contents wlc
				WHERE  wlc.inventory_item_id = prl.item_id
				AND    wlc.parent_lpn_id IN
				( SELECT lpn_id
				  FROM   wms_license_plate_numbers
				  START WITH lpn_id = p_lpn_id
                                   CONNECT BY parent_lpn_id = PRIOR lpn_id
				  )
				)
			      )
			     );
       ELSE
	 OPEN x_projects FOR
	   SELECT DISTINCT p.project_id,
	                   p.project_number,
                           p.project_name
	   FROM            po_req_distributions_all prd,
                           pjm_projects_mtll_v p,
                           po_requisition_lines_all prl
	   WHERE           prd.project_id IS NOT NULL
	     AND             prd.project_id = p.project_id
	     AND             prd.requisition_line_id = prl.requisition_line_id
	     AND             prl.requisition_header_id = p_req_header_id
	     AND             p.project_number LIKE p_project_number
	     AND             (    p_item_id IS NULL
				  OR prl.item_id = p_item_id )
	       AND            ( (p_lpn_id IS NULL) OR
				(p_lpn_id IS NOT NULL AND EXISTS
				 ( SELECT wlc.inventory_item_id
				   FROM   wms_lpn_contents wlc
				   WHERE  wlc.inventory_item_id = prl.item_id
				   AND    wlc.parent_lpn_id IN
				   ( SELECT lpn_id
				     FROM   wms_license_plate_numbers
				     START WITH lpn_id = p_lpn_id
				     CONNECT BY parent_lpn_id = PRIOR lpn_id
				     )
				   )
				 )
				)
       UNION ALL
         SELECT DISTINCT  -9999 project_id,
		         l_no_proj_str project_number,
	                 l_no_proj_str project_name
         FROM            po_req_distributions_all prd,
                         po_requisition_lines_all prl
	 WHERE           prd.project_id IS NULL
         AND             prd.requisition_line_id = prl.requisition_line_id
         AND             prl.requisition_header_id = p_req_header_id
	 AND             l_no_proj_str LIKE ( p_project_number )
         AND             (    p_item_id IS NULL
                           OR prl.item_id = p_item_id )
         AND            ( (p_lpn_id IS NULL) OR
                          (p_lpn_id IS NOT NULL AND EXISTS
                             ( SELECT wlc.inventory_item_id
                               FROM   wms_lpn_contents wlc
                               WHERE  wlc.inventory_item_id = prl.item_id
                               AND    wlc.parent_lpn_id IN
                                 ( SELECT lpn_id
                                   FROM   wms_license_plate_numbers
                                   START WITH lpn_id = p_lpn_id
                                   CONNECT BY parent_lpn_id = PRIOR lpn_id
                                 )
                             )
                          )
                        );
      END IF;
   END;

   PROCEDURE GET_RCV_RMA_PROJECTS (
      X_PROJECTS  OUT NOCOPY /* file.sql.39 change */ t_genref,
      p_order_header_id IN NUMBER,
      p_project_number IN VARCHAR2,
      p_item_id   IN NUMBER DEFAULT NULL
   )
   IS
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
      l_no_proj_str VARCHAR2(2000);
   BEGIN
      l_no_proj_str := FND_MESSAGE.GET_STRING ( 'INV', 'INV_NO_PROJECT' );
      IF (l_debug = 1) THEN
	 print_debug(' l_no_proj_str:' || l_no_proj_str);
      END IF;
      --BUG 4599723
      --For performance reasons, remove the outer join on
      --pjm_projects_mtll_v; instead, use a union to retrieve
      --the no projects row.  Also, if user did not enter a string
      --like the no proj string, don't do the union
      IF (l_no_proj_str IS NOT NULL AND l_no_proj_str NOT LIKE p_project_number) THEN
	 OPEN x_projects FOR
	   SELECT DISTINCT p.project_id,
                           p.project_number,
	                   p.project_name
	   FROM            oe_order_lines_all oel,
                           pjm_projects_mtll_v p
	   WHERE           oel.project_id IS NOT NULL
	     AND             oel.project_id = p.project_id
	     AND             oel.header_id = p_order_header_id
	     AND             (    p_item_id IS NULL
				  OR ( oel.inventory_item_id = p_item_id ) )
	       AND             p.project_number LIKE ( p_project_number );
       ELSE
	 OPEN x_projects FOR
	   SELECT DISTINCT p.project_id,
                           p.project_number,
	                   p.project_name
	   FROM            oe_order_lines_all oel,
                           pjm_projects_mtll_v p
	   WHERE           oel.project_id IS NOT NULL
	     AND             oel.project_id = p.project_id
	     AND             oel.header_id = p_order_header_id
	     AND             (    p_item_id IS NULL
				  OR ( oel.inventory_item_id = p_item_id ) )
	       AND             p.project_number LIKE ( p_project_number )
	  UNION ALL
         SELECT DISTINCT  -9999 project_id,
	                 l_no_proj_str project_number,
	                 l_no_proj_str project_name
         FROM            oe_order_lines_all oel
	 WHERE           oel.project_id IS NULL
         AND             oel.header_id = p_order_header_id
         AND             (    p_item_id IS NULL
                           OR ( oel.inventory_item_id = p_item_id ) )
	 AND             l_no_proj_str LIKE ( p_project_number );
      END IF;
   END;

   PROCEDURE GET_PROJECTS (
      x_projects  OUT NOCOPY /* file.sql.39 change */ t_genref,
      p_restrict_projects IN VARCHAR
   )
   IS
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      OPEN x_projects FOR
         SELECT   p.project_id,
                  NVL ( p.project_number, ' ' ),
                  NVL ( p.project_name, ' ' )
         FROM     pjm_projects_mtll_v p
         WHERE    p.project_number LIKE ( p_restrict_projects )
         ORDER BY 2;
   END GET_PROJECTS;

   PROCEDURE GET_RCV_PROJECTS (
      X_PROJECTS  OUT NOCOPY /* file.sql.39 change */ t_genref,
      document_type IN VARCHAR2,
      p_po_header_id IN NUMBER,
      p_po_line_id IN NUMBER,
      p_order_header_id IN NUMBER,
      p_req_header_id IN NUMBER,
      p_shipment_header_id IN NUMBER,
      p_project_number IN VARCHAR2,
      p_item_id   IN NUMBER DEFAULT NULL,
      p_lpn_id    IN NUMBER DEFAULT NULL, --ASN
      p_po_release_id IN NUMBER DEFAULT NULL, --BUG 4201013
      p_is_deliver	IN VARCHAR2 DEFAULT 'F'  --Bug 6785303
    )
   IS
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN
      /* Bug 6785303 if p_is_deliver then call GET_RCV_PO_DELIVER_PROJECTS */
      IF DOCUMENT_TYPE = 'PO' THEN
         IF p_is_deliver = 'T' THEN
            print_debug ( 'PO DELIVER type' );
            GET_RCV_PO_DELIVER_PROJECTS ( X_PROJECTS,
                                          p_po_header_id,
                                          p_po_line_id,
                                          p_project_number,
                                          p_item_id,
                                          p_po_release_id
                                        );
         ELSE
            print_debug ( 'PO type' );
            GET_RCV_PO_PROJECTS ( X_PROJECTS,
                                  p_po_header_id,
                                  p_po_line_id,
                                  p_project_number,
                                  p_item_id,
	                          p_po_release_id
                                );
         END IF;
      ELSIF DOCUMENT_TYPE = 'REQ' THEN
         print_debug ( 'req type' );
         GET_RCV_REQ_PROJECTS ( X_PROJECTS,
                                p_req_header_id,
                                p_project_number,
                                p_item_id,
                                p_lpn_id
                              );
   /*Added as part of bug - 5928199*/
      ELSIF DOCUMENT_TYPE = 'INTSHIP' THEN
         print_debug ( 'INTSHIP type' );
         GET_RCV_REQ_PROJECTS ( X_PROJECTS,
                                p_req_header_id,
                                p_project_number,
                                p_item_id,
                                p_lpn_id
                              );
      /*End of modifications for bug - 5928199*/
      ELSIF DOCUMENT_TYPE = 'RMA' THEN
         GET_RCV_RMA_PROJECTS ( X_PROJECTS,
                                p_order_header_id,
                                p_project_number,
                                p_item_id
                              );
      ELSIF DOCUMENT_TYPE = 'ASN' THEN
         GET_RCV_ASN_PROJECTS ( X_PROJECTS,
                                p_shipment_header_id,
                                p_project_number,
                                p_po_header_id,
                                p_lpn_id
                              );
      END IF;
   END;

   PROCEDURE GET_CC_PROJECTS (
      x_projects  OUT NOCOPY /* file.sql.39 change */ t_genref,
      p_organization_id IN NUMBER,
      p_cycle_count_id IN NUMBER,
      p_unscheduled_flag IN NUMBER,
      p_project_number IN VARCHAR2
   )
   IS
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN

      -- bug 4662395 set the profile mfg_organization_id so
      -- the call to PJM_PROJECTS_MTLL_V will return data.

      FND_PROFILE.put('MFG_ORGANIZATION_ID',p_organization_id);

      IF p_unscheduled_flag = 2 THEN
         IF ( l_debug = 1 ) THEN
            inv_log_util.TRACE (    'Unsceduled flag = 2 '
                                 || p_cycle_count_id
                                 || ' : '
                                 || p_organization_id,
                                 4
                               );
         END IF;

         OPEN x_projects FOR
            SELECT DISTINCT p.project_id,
                            NVL ( p.project_number, ' ' ),
                            NVL ( p.project_name, ' ' )
            FROM            pjm_projects_mtll_v p,
                            mtl_cycle_count_entries mcce,
                            mtl_item_locations mil
            WHERE           mil.segment19 = p.project_id
            AND             mcce.locator_id = mil.inventory_location_id
            AND             mcce.organization_id = mil.organization_id
            AND             mcce.cycle_count_header_id = p_cycle_count_id
            AND             p.project_number LIKE ( p_project_number )
            ORDER BY        2;
      ELSIF p_unscheduled_flag = 1 THEN
         IF ( l_debug = 1 ) THEN
            inv_log_util.TRACE (    'Unsceduled flag = 1 '
                                 || p_cycle_count_id
                                 || ' : '
                                 || p_organization_id,
                                 4
                               );
         END IF;

         OPEN x_projects FOR
            SELECT   p.project_id,
                     NVL ( p.project_number, ' ' ),
                     NVL ( p.project_name, ' ' )
            FROM     pjm_projects_mtll_v p
            WHERE    p.project_number LIKE ( p_project_number )
            ORDER BY 2;
      END IF;
   END;

   PROCEDURE GET_PHY_PROJECTS (
      x_projects  OUT NOCOPY /* file.sql.39 change */ t_genref,
      p_organization_id IN NUMBER,
      p_dynamic_entry_flag IN NUMBER,
      p_physical_inventory_id IN NUMBER,
      p_project_number IN VARCHAR2
   )
   IS
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN

      -- bug 4662395 set the profile mfg_organization_id so
      -- the call to PJM_PROJECTS_MTLL_V will return data.

      FND_PROFILE.put('MFG_ORGANIZATION_ID',p_organization_id);

      IF ( p_dynamic_entry_flag = 2 ) THEN
         OPEN x_projects FOR
            SELECT DISTINCT p.project_id,
                            NVL ( p.project_number, ' ' ),
                            NVL ( p.project_name, ' ' )
            FROM            pjm_projects_mtll_v p,
                            mtl_physical_inventory_tags mpi,
                            mtl_item_locations mil
            WHERE           mil.project_id = p.project_id
            AND             mil.inventory_location_id = mpi.locator_id
            AND             mil.organization_id = p_organization_id
            AND             mpi.physical_inventory_id =
                                                       p_physical_inventory_id
            AND             p.project_number LIKE ( p_project_number )
            ORDER BY        2;
      ELSE -- dynamic tags allowed
         OPEN x_projects FOR
            SELECT   p.project_id,
                     NVL ( p.project_number, ' ' ),
                     NVL ( p.project_name, ' ' )
            FROM     pjm_projects_mtll_v p
            WHERE    p.project_number LIKE ( p_project_number )
            ORDER BY 2;
      END IF;
   END;

   PROCEDURE GET_MO_PROJECTS (
      x_projects  OUT NOCOPY /* file.sql.39 change */ t_genref,
      p_restrict_projects IN VARCHAR2,
      p_organization_id IN NUMBER,
      p_mo_header_id IN NUMBER
   )
   IS
      l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
   BEGIN

      -- bug 4662395 set the profile mfg_organization_id so
      -- the call to PJM_PROJECTS_MTLL_V will return data.

      FND_PROFILE.put('MFG_ORGANIZATION_ID',p_organization_id);

      OPEN x_projects FOR
         SELECT   p.project_id,
                  NVL ( p.project_number, ' ' ),
                  NVL ( p.project_name, ' ' )
         FROM     pjm_projects_mtll_v p
         WHERE    p.project_number LIKE ( p_restrict_projects )
         AND      p.project_id IN (
                     SELECT mtrl.project_id
                     FROM   mtl_txn_request_lines mtrl
                     WHERE  mtrl.organization_id = p_organization_id
                     AND    mtrl.header_id = p_mo_header_id )
         ORDER BY 2;
   END GET_MO_PROJECTS;
END INV_UI_PROJECT_LOVS;

/
