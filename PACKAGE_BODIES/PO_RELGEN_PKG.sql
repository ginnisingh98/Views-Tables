--------------------------------------------------------
--  DDL for Package Body PO_RELGEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_RELGEN_PKG" AS
/* $Header: porelgeb.pls 120.16.12010000.20 2012/10/30 14:50:47 jemishra ship $ */

--<ENCUMBRANCE FPJ>
g_dest_type_code_SHOP_FLOOR      CONSTANT
   PO_DISTRIBUTIONS_ALL.destination_type_code%TYPE
   := 'SHOP FLOOR'
   ;

-- Bug 2701147 START
-- Constants for constructing error messages:

-- This is used as a delimiter in constructing the error msgs
g_delim CONSTANT VARCHAR2(1) := ' ';
g_bpamsg CONSTANT VARCHAR2(75) := substr(FND_MESSAGE.GET_STRING('PO', 'PO_BLANKET_PO'),1,26) ;--12553671

g_reqmsg CONSTANT VARCHAR2(75) := substr(FND_MESSAGE.GET_STRING('PO', 'PO_REQ_TYPE'),1,25);

--Contains message 'Line#'
g_linemsg CONSTANT VARCHAR2(75) := substr(FND_MESSAGE.GET_STRING('PO', 'PO_ZMVOR_LINE'), 1,25);

--Contains message 'Shipment#'
g_shipmsg CONSTANT VARCHAR2(75) := substr(FND_MESSAGE.GET_STRING('PO', 'PO_ZMVOR_SHIPMENT'), 1,25);

--Contains message 'Distribution#'
g_distmsg CONSTANT VARCHAR2(75) := substr(FND_MESSAGE.GET_STRING('PO', 'PO_ZMVOR_DISTRIBUTION'), 1,25);

g_pkg_name    CONSTANT VARCHAR2(30) := 'PO_RELGEN_PKG';
c_log_head    CONSTANT VARCHAR2(50) := 'po.plsql.'|| G_PKG_NAME || '.';

-- Read the profile option that enables/disables the debug log
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

g_debug_stmt BOOLEAN := PO_DEBUG.is_debug_stmt_on;

-- <INVCONV R12>
g_chktype_TRACKING_QTY_IND CONSTANT
   MTL_SYSTEM_ITEMS_B.TRACKING_QUANTITY_IND%TYPE
   := 'PS';


-- Private procedure:
PROCEDURE preapproval_checks( p_po_header_id IN NUMBER,
                              p_req_num IN VARCHAR2,
                              p_req_line_num IN NUMBER,
                              x_check_status OUT NOCOPY VARCHAR2);
-- Bug 2701147 END

PROCEDURE create_award_distribution; --<GRANTS FPJ>

--<Encumbrance FPJ>
PROCEDURE CREATE_RELEASE_DISTRIBUTION(
   req_line                         IN   requisition_lines_cursor%rowtype
,  p_req_enc_flag                   IN             VARCHAR2
);


PROCEDURE CREATE_RELEASES
IS
    x_old_po_header_id number := 0;
    po_req_lines       requisition_lines_cursor%rowtype;
    old_po_req_line    requisition_lines_cursor%rowtype;
    x_old_doc_generation_method po_autosource_documents.doc_generation_method%type;
    x_kanban_return_status VARCHAR2(10) := '';
    x_return_code          VARCHAR2(25);
    x_tax_status     VARCHAR2(10);
    l_encode varchar2(2000);
    x_error_msg            varchar2(2000);
    x_no_convert_flag      varchar2(1);
    x_uom_convert          varchar2(2) := fnd_profile.value('PO_REQ_BPA_UOM_CONVERT');
    x_req_num              varchar2(20);
    x_req_line_num         number;
    /* Supplier PCard FPH */
    x_old_pcard_id     number;

    l_check_status         VARCHAR2(1); -- Bug 2701147
    l_api_name  CONSTANT   varchar2(40) := 'CREATE_RELEASES';

    --bug2880298 start

    l_req_enc_flag  financials_system_parameters.req_encumbrance_flag%TYPE;
    l_enf_vendor_hold_flag po_system_parameters.enforce_vendor_hold_flag%TYPE;

    -- bug2880298 end

    -- <FPJ Refactor Archiving API>
    l_return_status varchar2(1) ;
    l_msg_count NUMBER := 0;
    l_msg_data VARCHAR2(2000);
    --<R12 eTax Integration Start>
    l_tax_return_status VARCHAR2(1);
    --<R12 eTax Integration End>

    l_progress VARCHAR2(3) := '000'; -- Bug 3570793
BEGIN

    --bug2880298
    -- get necessary information from fsp and posp and pass them to the
    -- cursor requisition_lines_cursor1 rather than getting the values
    -- from the cursor to improve performance and avoid catesian joins
    -- in a large query.

    SELECT FSP.INVENTORY_ORGANIZATION_ID,
           POSP.EXPENSE_ACCRUAL_CODE,
           NVL(FSP.req_encumbrance_flag, 'N'),       --bug2880298
           NVL(POSP.enforce_vendor_hold_flag, 'N')   --bug2880298
      INTO x_inventory_org_id,
           x_expense_accrual_code,
           l_req_enc_flag,                           --bug2880298
           l_enf_vendor_hold_flag                    --bug2880298
      FROM FINANCIALS_SYSTEM_PARAMETERS FSP,
           PO_SYSTEM_PARAMETERS POSP;

    IF SQL%NOTFOUND THEN
        RAISE NO_DATA_FOUND;
    END IF;

    l_progress := '010';

    BEGIN    -- Added for Bug #2206125, the following code was always
       -- returning the period name irrespective of PO encumbered flag
       -- so adding a condition from FSP to check if encumbrance in On.

    SELECT GPS.PERIOD_NAME
      INTO x_period_name
      FROM GL_PERIOD_STATUSES GPS,
           FINANCIALS_SYSTEM_PARAMETERS FSP
     WHERE GPS.APPLICATION_ID = 101
       AND GPS.SET_OF_BOOKS_ID = FSP.SET_OF_BOOKS_ID
       AND GPS.ADJUSTMENT_PERIOD_FLAG = 'N'
       AND TRUNC(SYSDATE) BETWEEN TRUNC(GPS.START_DATE)
                              AND TRUNC(GPS.END_DATE)
       AND NVL(FSP.PURCH_ENCUMBRANCE_FLAG, 'N') = 'Y';  -- Bug #2206125

    IF SQL%NOTFOUND THEN
        RAISE NO_DATA_FOUND;
    END IF;

    EXCEPTION   -- Bug #2206125
    WHEN NO_DATA_FOUND THEN
         x_period_name := '';
    END;          -- Bug #2206125

--    dbms_output.put_line ('Before Open Cursor1');

    -- bug2880298
    -- added two parameters for the following cursor

    l_progress := '020';

    open requisition_lines_cursor1 (l_req_enc_flag,
                                    l_enf_vendor_hold_flag);

--    dbms_output.put_line ('After Open Cursor1');

    loop
        l_progress := '030';

        fetch requisition_lines_cursor1 into po_req_lines;
        exit when requisition_lines_cursor1%notfound;

      /*  Enh 1660036 : If the req uom and po uom are different and the
       convert uom profile is not set to yes we set the no convert flag to Y
       so that release creation does not happen for this req.*/

      x_no_convert_flag := 'N';

        select segment1 into x_req_num
        from po_requisition_headers
        where requisition_header_id = po_req_lines.requisition_header_id;

        select line_num into x_req_line_num
        from po_requisition_lines
        where requisition_line_id = po_req_lines.requisition_line_id;

      IF ( po_req_lines.req_uom <> po_req_lines.po_uom )  AND
          nvl(x_uom_convert,'Y') <> 'Y'  THEN

        /* if the profile is unset we take it as yes because we want
           the create releases to behave as earlier */

        fnd_message.set_name ('PO', 'PO_REQ_BPA_CONVERT_UOM');
        fnd_message.set_token('REQ', x_req_num);
        fnd_message.set_token('LINE', x_req_line_num);
        x_error_msg := fnd_message.get;
        fnd_file.put_line(fnd_file.log,x_error_msg);
        x_no_convert_flag := 'Y';

      END IF;

      l_progress := '040';

      /*  Enh 1660036 : proceed with the rest of the release creation only if
          the no convert flag has not been set */
      IF  x_no_convert_flag = 'N' THEN
        IF (x_old_po_header_id          <> po_req_lines.blanket_po_header_id  OR
            x_old_doc_generation_method <> po_req_lines.doc_generation_method OR
            /* Supplier PCard FPH */
            nvl(x_old_pcard_id,0) <> nvl(po_req_lines.pcard_id,0))
        THEN

           IF(x_old_po_header_id <> 0) THEN
               --<R12 eTax Integration Start>
               l_tax_return_status := NULL;
               po_tax_interface_pvt.calculate_tax(x_return_status   => l_tax_return_status,
                                                  p_po_header_id    => NULL,
                                                  p_po_release_id   => x_po_release_id,
                                                  p_calling_program =>'PORELGEB');
               l_progress := '042';

               IF l_tax_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 IF (g_debug_stmt) THEN
                   PO_DEBUG.debug_stmt (
                     p_log_head => c_log_head||l_api_name,
                     p_token    => '',
                     p_message  => 'Error in tax calcualtion'
                                  ||' po_release_id: '||x_po_release_id
                   );
                 END IF;
                 FOR i IN 1..po_tax_interface_pvt.g_tax_errors_tbl.message_text.COUNT LOOP
                   fnd_file.put_line(FND_FILE.LOG, po_tax_interface_pvt.g_tax_errors_tbl.message_text(i) );
                 END LOOP;
               END IF;
               l_progress := '043';

               --<R12 eTax Integration End>

               IF (x_authorization_status = 'APPROVED') THEN

                 --<R12 eTax Integration Start>
                 IF l_tax_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    --
                    -- ECO Bug 4643026
                    -- Update Release with status INCOMPLETE
                    -- as the tax calculation has failed
                    --

		    /*Bug 7609663: Update the approved_flag in po_releses_all and po_line_locations_all */

		    UPDATE po_releases_all por
                    SET  por.authorization_status = 'INCOMPLETE',
                         por.approved_flag = 'N'
                    WHERE  por.po_release_id        = x_po_release_id;

                    UPDATE po_line_locations_all plla
                    SET  plla.approved_flag = 'N'
                    WHERE  plla.po_release_id = x_po_release_id;

		    /* Bug 7609663: end */

                    x_authorization_status := 'INCOMPLETE';
                 ELSE
                 --<R12 eTax Integration End>
                   l_progress := '050';

                   -- Support for Kanban Execution
                   /* Bug# 2485087, Moved kanban execution here where all code and
                   logic related to after creating the releases was there. With the
                   earlier Code we were having problems with treating the Release
                   creation and Kanban updation as one transaction and if the next
                   Releases needed to be Rolled back we also lost the Kanban Card
                   Updation for the previous Release. */

                   PO_KANBAN_SV.Update_Card_Status ('IN_PROCESS',
                                                    'RELEASE',
                                                    x_po_release_id,
                                                    x_kanban_return_status);

                   -- <FPJ Refactor Archiving API START>
                   PO_DOCUMENT_ARCHIVE_GRP.Archive_PO(
                                      p_api_version => 1.0,
                                      p_document_id => x_po_release_id,
                                      p_document_type => 'RELEASE',
                                      p_document_subtype => 'BLANKET', -- Not really needed
                                      p_process => 'APPROVE',
                                      x_return_status => l_return_status,
                                      x_msg_count => l_msg_count,
                                      x_msg_data => l_msg_data);

                   IF (l_return_status <> 'S') THEN
                       APP_EXCEPTION.Raise_Exception;
                   END IF;

                   -- <FPJ Refactor Archiving API END>

                   WRAPUP(old_po_req_line);

                   l_progress := '060';
                   -- Bug 3570793 START
                   -- Moved the call here so that it happens for every approved
                   -- release that is created.
                   PO_RESERVATION_MAINTAIN_SV.maintain_reservation (
                          p_header_id             => x_po_release_id,
                          p_line_id               => 0,
                          p_line_location_id      => 0,
                          p_distribution_id       => 0,
                          p_action                => 'Approve_Blanket_Release_Supply',
                          p_recreate_demand_flag  => 'N',
                          p_called_from_reqimport => 'N',
                          x_return_status         => l_return_status
                        );
                   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;
                   -- Bug 3570793 END

                   l_progress := '070';
                   -- <INBOUND LOGISTICS FPJ START>
                   create_deliveryrecord(p_release_id => x_po_release_id);
                   -- <INBOUND LOGISTICS FPJ END>

                   l_progress := '080';
                   -- Bug 2701147 START
                   -- Retrieve the req number and req line number for the
                   -- previous release created.
                   select segment1 into x_req_num
                   from po_requisition_headers
                   where requisition_header_id = old_po_req_line.requisition_header_id;


                   select line_num into x_req_line_num
                   from po_requisition_lines
                   where requisition_line_id = old_po_req_line.requisition_line_id;



                   -- If the release fails any of the pre-approval checks,
                   -- rollback its creation, but proceed with the creation of
                   -- the next release.

                   preapproval_checks(x_old_po_header_id,
                                     x_req_num,x_req_line_num,
                                     l_check_status);

                   IF (l_check_status = FND_API.G_RET_STS_ERROR) THEN
                     -- Rollback the creation of the release.
                     ROLLBACK TO PORELGEN_1;
                     -- Bug 3570793 START
                     IF (g_debug_stmt) THEN
                           PO_DEBUG.debug_stmt (
                             p_log_head => c_log_head||l_api_name,
                             p_token => '',
                             p_message => 'Preapproval checks failed; rollback'
                                          ||' po_release_id: '||x_po_release_id
                           );
                     END IF;
                     -- Bug 3570793 END
		     --<BUG 7685164 Added as part of LCM ER START>
		   -- Assigning check status as unexpected error to make sure that if the release
		   -- fails in LCM submission checks then we should create the release with incomplete status.
		   ELSIF (l_check_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN

		   	--<BUG 7721295 Need to revert the approved date and LCM flag if the
		        -- LCM submission check fails>
			UPDATE po_releases_all por
		           SET por.authorization_status = 'INCOMPLETE',
			       por.approved_flag = 'N',
		               por.approved_date = NULL
		         WHERE por.po_release_id = x_po_release_id;

			UPDATE po_line_locations_all plla
			   SET plla.approved_flag = 'N',
		               plla.approved_date = NULL,
		               plla.lcm_flag = NULL
		         WHERE plla.po_release_id = x_po_release_id
			   AND plla.lcm_flag = 'Y';

			UPDATE po_distributions_all pda
			   SET pda.lcm_flag = NULL
			 WHERE pda.line_location_id = x_line_location_id
			   AND pda.lcm_flag = 'Y';

			IF (g_debug_stmt) THEN
                        	PO_DEBUG.debug_stmt (p_log_head => c_log_head||l_api_name,
                             			     p_token => '',
			                             p_message => 'Preapproval checks for LCM features failed'
                        	                     ||' po_release_id: '||x_po_release_id);
                        END IF;
		   --<BUG 7685164 END>
                   END IF;
                   -- Bug 2701147 END
                 END IF; -- tax calculation failed for approved release
               ELSE    -- authorization_status <> 'APPROVED'
                 WRAPUP(old_po_req_line);
               END IF; -- authorization_status <> 'APPROVED'
           END IF; -- old_header_id <> 0

           SAVEPOINT PORELGEN_1;
           CREATE_RELEASE_HEADER (po_req_lines);

      END IF; --old_header_id <> rec.header_id

      l_progress := '100';

      CREATE_RELEASE_SHIPMENT (po_req_lines);
      CREATE_RELEASE_DISTRIBUTION (po_req_lines,l_req_enc_flag);

      --<BUG 7721295 Added as part of the LCM ER>
      PO_DOCUMENT_CHECKS_PVT.set_lcm_flag(x_line_location_id,'AFTER',l_return_status);

  /* ecso 11/18/97 R11 OE drop ship call back */
        OE_DROP_SHIP (po_req_lines);

        --Moved Kanban Execution to the Top

        l_progress := '110';

/*
 	         Bug 5973123
 	         When a req is autocreated to PO, the correct supply manipulation order is,
 	         Req Creation
 	         Req Deletion
 	         PO Creation

 	         The CLOSE PO API does not delete the backing requisition supply. It just
 	         creates the PO supply if it does not exist. This causes supply manipulation
 	         order to go out of sync. Hence now moving the supply creation code before
 	         the close PO API. The MAINTAIN_SUPPLY will delete the req supply first and
 	         create the PO Supply. Later the Close PO API, would delete the supply if
 	         required. Thus the supply manipulation order is maintained.
 	         */

 	         MAINTAIN_SUPPLY (po_req_lines);

 	         l_progress := '115';

     /* Bug 724170 GMudgal 12/02/98.
     ** Call the po_actions.close_po plsql routine to set the closed
     ** code at the shipment level and consequently rollup to the lines
     ** and headers. This was done because, in case the matching for the
     ** release is set to 2-way and the receipt close tolerance is 100% then
     ** the release shipment should be closed for receiving when it is
     ** created. This will enable AP to close the shipment (finally close
     ** in case of final match) when an invoice is matched. The rolled up
     ** state for lines and header will be CLOSED only for both match and
     ** final match.
     */
        IF (NOT(PO_ACTIONS.Close_PO(x_po_release_id,
                         'RELEASE',
                         'BLANKET',
                         po_req_lines.blanket_po_line_id,
                         x_line_location_id,
                         'UPDATE_CLOSE_STATE',
                         NULL,                 -- p_reason
                         'PO',                 -- p_calling_mode
                         'N',
                         x_return_code,
                         'Y'))) THEN
         APP_EXCEPTION.Raise_Exception;
        END IF ;

/* 858071 - SVAIDYAN : Call maintain_supply after po_actions.close_po so
                       that supply is created correctly.
*/

        l_progress := '120';
        /* Bug 5973123  MAINTAIN_SUPPLY (po_req_lines);  */

        x_old_po_header_id := po_req_lines.blanket_po_header_id;
        x_old_doc_generation_method := po_req_lines.doc_generation_method;
        /* Supplier PCard FPH */
  x_old_pcard_id := po_req_lines.pcard_id;
        old_po_req_line := po_req_lines;

       END IF;

    end loop;


    -- bug 589727
    -- Bug# 2485087, Moved kanban execution from here and did
    -- it alone with Archive logic below

    IF (x_old_po_header_id <> 0)
    THEN
       -- sjadhav, added tax call
       --<R12 eTax Integration Start>
       l_tax_return_status := NULL;
       po_tax_interface_pvt.calculate_tax(x_return_status   => l_tax_return_status,
                                          p_po_header_id    => NULL,
                                          p_po_release_id   => x_po_release_id,
                                          p_calling_program =>'PORELGEB');
       l_progress := '042';
       IF l_tax_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF (g_debug_stmt) THEN
           PO_DEBUG.debug_stmt (
             p_log_head => c_log_head||l_api_name,
             p_token    => '',
             p_message  => 'Error in tax calcualtion'
                          ||' po_release_id: '||x_po_release_id
           );
         END IF;
         FOR i IN 1..po_tax_interface_pvt.g_tax_errors_tbl.message_text.COUNT LOOP
           fnd_file.put_line(FND_FILE.LOG, po_tax_interface_pvt.g_tax_errors_tbl.message_text(i) );
         END LOOP;
       END IF;
       l_progress := '043';

       --<R12 eTax Integration End>

       IF(x_authorization_status = 'APPROVED') THEN
         l_progress := '200';
         --<R12 eTax Integration Start>
         IF l_tax_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            -- sjadhav,
            -- ECO Bug 4643026
            -- Update Release with status INCOMPLETE
            -- as the tax calculation has failed
            --
             /*Bug 7609663: Update the approved_flag in po_releses_all and po_line_locations_all */

		    UPDATE po_releases_all por
                    SET  por.authorization_status = 'INCOMPLETE',
                         por.approved_flag = 'N'
                    WHERE  por.po_release_id        = x_po_release_id;

                    UPDATE po_line_locations_all plla
                    SET  plla.approved_flag = 'N'
                    WHERE  plla.po_release_id = x_po_release_id;

            /* Bug 7609663: end */
         ELSE
         --<R12 eTax Integration End>

         --Moved Kanban Execution here
         --Bug# 2485087, Updating Kanban for Last Release Created.
           PO_KANBAN_SV.Update_Card_Status ('IN_PROCESS',
                                            'RELEASE',
                                            x_po_release_id,
                                            x_kanban_return_status);
         -- <FPJ Refactor Archiving API START>
           PO_DOCUMENT_ARCHIVE_GRP.Archive_PO(p_api_version => 1.0,
                                        p_document_id => x_po_release_id,
                                        p_document_type => 'RELEASE',
                                        p_document_subtype => 'BLANKET', -- Not really needed
                                        p_process => 'APPROVE',
                                        x_return_status => l_return_status,
                                        x_msg_count => l_msg_count,
                                        x_msg_data => l_msg_data);

           IF (l_return_status <> 'S') THEN
             APP_EXCEPTION.Raise_Exception;
           END IF;

          -- PO_RELGEN_PKG1.ARCHIVE_RELEASE(x_po_release_id);
          -- <FPJ Refactor Archiving API END>

           WRAPUP(old_po_req_line);

           l_progress := '210';
           -- Bug 3570793 START
           -- Moved the call here so that it happens for every approved
           -- release that is created.
           PO_RESERVATION_MAINTAIN_SV.maintain_reservation (
             p_header_id             => x_po_release_id,
             p_line_id               => 0,
             p_line_location_id      => 0,
             p_distribution_id       => 0,
             p_action                => 'Approve_Blanket_Release_Supply',
             p_recreate_demand_flag  => 'N',
             p_called_from_reqimport => 'N',
             x_return_status         => l_return_status
           );
           IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
           -- Bug 3570793 END

           l_progress := '220';
           -- <INBOUND LOGISTICS FPJ START>
           create_deliveryrecord(p_release_id => x_po_release_id);
           -- <INBOUND LOGISTICS FPJ END>

           l_progress := '230';
           -- Bug 2701147 START
           select segment1 into x_req_num
           from po_requisition_headers
           where requisition_header_id = old_po_req_line.requisition_header_id;


           select line_num into x_req_line_num
           from po_requisition_lines
           where requisition_line_id = old_po_req_line.requisition_line_id;


           -- If the release fails any of the pre-approval checks, rollback
           -- its creation.
           preapproval_checks(x_old_po_header_id,x_req_num,x_req_line_num,
                              l_check_status);

           IF (l_check_status = FND_API.G_RET_STS_ERROR) THEN
               -- Rollback the creation of the release.
               ROLLBACK TO PORELGEN_1;
               -- Bug 3570793 START
               IF (g_debug_stmt) THEN
                 PO_DEBUG.debug_stmt (
                   p_log_head => c_log_head||l_api_name,
                   p_token => '',
                   p_message => 'Preapproval checks failed; rollback'
                                ||' po_release_id: '||x_po_release_id
                 );
               END IF;
               -- Bug 3570793 END
	       --<BUG 7685164 Added as part of LCM ER START>
	   -- Assigning check status as unexpected error to make sure that if the release
	   -- fails in LCM submission checks then we should create the release with incomplete status.
	   ELSIF (l_check_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN

	  	--<BUG 7721295 Need to revert the approved date and LCM flag if the
		-- LCM submission check fails>
		UPDATE po_releases_all por
		   SET por.authorization_status = 'INCOMPLETE',
		       por.approved_flag = 'N',
		       por.approved_date = NULL
		 WHERE por.po_release_id = x_po_release_id;

		UPDATE po_line_locations_all plla
		   SET plla.approved_flag = 'N',
		       plla.approved_date = NULL,
		       plla.lcm_flag = NULL
		 WHERE plla.po_release_id = x_po_release_id
		   AND plla.lcm_flag = 'Y';

		UPDATE po_distributions_all pda
		   SET pda.lcm_flag = NULL
		 WHERE pda.line_location_id = x_line_location_id
		   AND pda.lcm_flag = 'Y';

		IF (g_debug_stmt) THEN
                	PO_DEBUG.debug_stmt (p_log_head => c_log_head||l_api_name,
                                     	     p_token => '',
			                     p_message => 'Preapproval checks for LCM features failed'
                        	             ||' po_release_id: '||x_po_release_id);
                END IF;
	   --<BUG 7685164 END>
           END IF;
           -- Bug 2701147 END
         END IF; -- tax calculation failed for approved release
       ELSE -- authorization_status <> 'APPROVED'
         WRAPUP(old_po_req_line);
       END IF; -- authorization_status <> 'APPROVED'
    END IF; -- old_header_id <> 0

    l_progress := '140';
    PO_RELGEN_PKG1.MRP_SUPPLY;
    /*
     Bug # 1995964 KPERIASA
     Description :  Spares Management Project.  Support for reservation
            within purchasing.  Modified porelgeb.pls to add a call to
            PO_RESERVATION_MAINTAIN_SV.maintain_reservation
     */
    -- Bug 3570793 Moved the maintain_reservation call to inside the loop,
    -- so that it is called for each approved release that is created.

    close requisition_lines_cursor1;

    commit;

    return;

EXCEPTION
  -- Bug 3570793 START
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- Write the errors on the message list to the concurrent program log.
    PO_DEBUG.write_msg_list_to_file (
      p_log_head => c_log_head || l_api_name,
      p_progress => l_progress
    );
    raise_application_error(-20001,sqlerrm||'---'||msgbuf);
  -- Bug 3570793 END

 WHEN OTHERS THEN
--       dbms_output.put_line ('In exception');
-- Bug 2701147 START
       FND_FILE.put_line(FND_FILE.LOG,
          c_log_head || l_api_name || '.' || l_progress
          || ' exception; SQL code: ' || sqlcode);
-- Bug 2701147 END
       raise_application_error(-20001,sqlerrm||'---'||msgbuf);
END CREATE_RELEASES;




/* ============================================================================
     NAME: CREATE_RELEASE_HEADER
     DESC: Create a new release header
     ARGS: IN : req_line IN requisition_lines_cursor%rowtype
     ALGR: Determine authorization status of release to be created
           Create release header

   ===========================================================================*/

PROCEDURE CREATE_RELEASE_HEADER(req_line IN requisition_lines_cursor%rowtype)
IS
l_api_name CONSTANT VARCHAR2(30) := 'create_release_header';

x_release_num number := 0;
x_purch_encumbrance_flag varchar2(1) := 'N';
x_pay_on_code varchar2(25) := '';
x_shipping_control varchar2(30) := '';  /* Bug 6454219 */
x_acceptance_required_flag  po_system_parameters.acceptance_required_flag%TYPE;  /*Bug7668178*/


BEGIN

    SELECT NVL(PURCH_ENCUMBRANCE_FLAG,'N')
      INTO x_purch_encumbrance_flag
      FROM FINANCIALS_SYSTEM_PARAMETERS;

   /*Bug7668178: Get the default Acceptance Required Flag value from PO System Parameters */

    SELECT Decode(acceptance_required_flag,'D','Y','Y','Y','S','Y','N')
    INTO x_acceptance_required_flag
    FROM po_system_parameters;

    IF (req_line.doc_generation_method = 'CREATE_AND_APPROVE' AND
        x_purch_encumbrance_flag = 'N')
    THEN
       x_authorization_status := 'APPROVED';
       x_acceptance_required_flag := NULL;     /*Bug7668178: Set Acceptance Required Flag to NULL when generation method is Automatic Release */
    ELSE
       x_authorization_status := 'INCOMPLETE';
    END IF;

    SELECT PO_RELEASES_S.NEXTVAL
      INTO x_po_release_id
      FROM SYS.DUAL;

/* Bug 1834138. pchintal. Code for calculating the shipment number.
This was done as a part of improving the performance of the create
releases process.
*/

     IF (Gpo_release_id_prev <> x_po_release_id) then
              Gpo_release_id_prev := x_po_release_id;
              Gship_num_prev := 0;
     END IF;

    SELECT NVL(MAX(RELEASE_NUM) +1,1)
      INTO x_release_num
      FROM PO_RELEASES
     WHERE PO_HEADER_ID = req_line.blanket_po_header_id;

	/* Bug 6454219 Added code to fetch shipping_control from the BPA.
	Same would be inserted into po_releases_all table */
    SELECT PAY_ON_CODE, SHIPPING_CONTROL
      INTO x_pay_on_code, x_shipping_control
      FROM PO_HEADERS
     WHERE PO_HEADER_ID = req_line.blanket_po_header_id;

    -- Bug 3570793 START
    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_stmt (
        p_log_head => c_log_head||l_api_name,
        p_token => '',
        p_message => 'Create release header;'
                     ||' req_line_id: '||req_line.requisition_line_id
                     ||', po_release_id: '||x_po_release_id
      );
    END IF;
    -- Bug 3570793 END

      INSERT INTO PO_RELEASES
        (PO_RELEASE_ID,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        PO_HEADER_ID,
        RELEASE_NUM,
        PCARD_ID, --Supplier Pcard FPH
        AGENT_ID,
        RELEASE_DATE,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        REVISION_NUM,
        APPROVED_FLAG,
        APPROVED_DATE,
        AUTHORIZATION_STATUS,
        PRINT_COUNT,
        CANCEL_FLAG,
        RELEASE_TYPE,
        PAY_ON_CODE,
        GOVERNMENT_CONTEXT,
        DOCUMENT_CREATION_METHOD,      -- PO DBI FPJ
        ORG_ID,                          -- <R12 MOAC>
        tax_attribute_update_code, --< eTax Integration R12>
		SHIPPING_CONTROL, /* Bug 6454219 */
        ACCEPTANCE_REQUIRED_FLAG    -- Bug 7668178
        )
      VALUES (x_po_release_id,               -- :po_release_id
        sysdate,
        req_line.last_updated_by,      -- :cpo_last_updated_by
        req_line.blanket_po_header_id, -- :po_header_id
        x_release_num,                 -- :release_num
        req_line.pcard_id, -- :pcard_id Supplier Pcard FPH
        req_line.agent_id,             -- :agent_id
        SYSDATE,        -- <Action Date TZ FPJ>
        sysdate,
        req_line.last_updated_by,      -- :cpo_last_updated_by
        req_line.last_update_login,    -- :last_update_login,
        0,
        DECODE(x_authorization_status,
        'APPROVED','Y','N'),    -- 'N'
        DECODE(x_authorization_status,
        'APPROVED', sysdate, NULL), -- approved date
        x_authorization_status,        -- :'INCOMPLETE'
        0,
        'N',
        'BLANKET',
        x_pay_on_code,
        null,                       -- :government_context
        -- Bug 3648268 Use lookup code instead of hardcoded value
        'CREATE_RELEASES',           -- Document Creation Method PO DBI FPJ
        req_line.org_id,             -- <R12 MOAC>
        'CREATE',   --<eTax integration R12>
		x_shipping_control,           /* Bug 6454219 */
        x_acceptance_required_flag   -- Bug7668178
      );

EXCEPTION

   WHEN OTHERS THEN
       raise_application_error(-20001,sqlerrm||'---'||msgbuf);

END CREATE_RELEASE_HEADER;


/* ============================================================================
     NAME: CREATE_RELEASE_SHIPMENT
     DESC: Create a new release shipment
     ARGS: IN : req_line IN requisition_lines_cursor%rowtype
     ALGR: Determine ship-to-location and tax information
           Create new release shipment
           Associate req line to the shipment created

   ===========================================================================*/

PROCEDURE CREATE_RELEASE_SHIPMENT(req_line IN requisition_lines_cursor%rowtype)
IS
l_api_name CONSTANT VARCHAR2(30) := 'create_release_shipment';

x_ship_to_location_id  number := 0;
x_taxable_flag         po_system_parameters.taxable_flag%type;
x_shipment_num         number := 0;
rcv_controls           rcv_control_type;
x_conversion_rate      number := 1;
x_best_price           number :=0;
x_ext_precision        number :=5;

--<INVCONV R12 START>
x_secondary_unit_of_measure     mtl_units_of_measure.unit_of_measure%type;
x_secondary_quantity            number;
x_secondary_uom_code            mtl_units_of_measure.uom_code%type;
--<INVCONV R12 END>

x_invoice_match_option		varchar2(25);  -- bgu, Dec. 11, 98
--frkhan 1/12/99
x_country_of_origin_code	varchar2(2);

/* <TIMEPHASED FPI START> */
l_quantity                      po_requisition_lines_all.quantity%TYPE := null;
l_price_break_type              varchar2(1) := null;
l_po_line_id                    po_lines_all.po_line_id%TYPE := null;
l_cumulative_flag               boolean;
l_dest_org_id                   po_requisition_lines_all.destination_organization_id%TYPE := null;
l_need_by_date                  po_requisition_lines_all.need_by_date%TYPE := null;
/* <TIMEPHASED FPI END> */

--<Bug# 3293109 START>
l_promised_date         DATE            := NULL;
l_po_promised_def_prf   VARCHAR2(1)     := fnd_profile.value('PO_NEED_BY_PROMISE_DEFAULTING');
--<Bug# 3293109 END>

l_outsourced_assembly   PO_LINE_LOCATIONS_ALL.outsourced_assembly%TYPE;
l_value_basis  PO_LINES_ALL.order_type_lookup_code%TYPE; --Bug 4896950
l_matching_basis PO_LINES_ALL.matching_basis%TYPE;  --Bug 4896950
l_unit_meas_lookup_code PO_LINES_ALL.unit_meas_lookup_code%TYPE; --Bug 4896950

--<BUG 7685164 START>
l_return_status  VARCHAR2(1);
l_msg_count      NUMBER;
l_msg_data       VARCHAR2(2000);
l_msg_buf        VARCHAR2(2000);
l_progress       VARCHAR2(3) := '001';
--<BUG 7685164 END>

BEGIN

       --<BUG 7685164 START>
       l_return_status  := FND_API.G_RET_STS_SUCCESS;
       IF (g_fnd_debug = 'Y') THEN
       	IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string (
            LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
            MODULE    => c_log_head || '.'||l_api_name||'.' || l_progress,
            MESSAGE   => 'Start create release shipments'
        );
        END IF;
       END IF;
       --<BUG 7685164 END>

       SELECT PO_LINE_LOCATIONS_S.NEXTVAL
         INTO x_line_location_id
         FROM SYS.DUAL;

/* Bug 1834138. pchintal. Commented the below SQL and added new Code
for calculating the shipment number. This was done as a part of
improving the performance of the create releases process.

       SELECT NVL(MAX(SHIPMENT_NUM) +1,1)
         INTO x_shipment_num
         FROM PO_LINE_LOCATIONS
        WHERE PO_RELEASE_ID = x_po_release_id;
*/

       Gship_num_prev :=Gship_num_prev+1;
       x_shipment_num := Gship_num_prev;

/* pchintal Code changes end for bug 1834138 */

     /* Bug 1942696   */

      begin

       SELECT NVL(SHIP_TO_LOCATION_ID,LOCATION_ID)
         INTO x_ship_to_location_id
         FROM HR_LOCATIONS
        WHERE LOCATION_ID = req_line.deliver_to_location_id;

      exception

        when no_data_found then

         /* Check validity against HZ_LOCATIONS  */

         begin
         select location_id
           into x_ship_to_location_id
         FROM HZ_LOCATIONS
         where location_id = req_line.deliver_to_location_id;

         exception
         when no_data_found then

            null;
         end;

       end;

       --<BUG 7685164 START>
       l_progress := '002';
       IF (g_fnd_debug = 'Y') THEN
       	IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
           FND_LOG.string (
            LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
            MODULE    => c_log_head || '.'||l_api_name||'.' || l_progress,
            MESSAGE   => x_ship_to_location_id
        );
        END IF;
       END IF;
       --<BUG 7685164 END>

       GET_RCV_CONTROLS(req_line,rcv_controls);

       /** bgu, Dec. 11, 98
  *  Default match option form vendor site, vendor, down to
  *  financial system parameters
  */
       GET_INVOICE_MATCH_OPTION(req_line, x_invoice_match_option);


       l_quantity := req_line.quantity;   /* <TIMEPHASED FPI> */

       IF ( req_line.req_uom <> req_line.po_uom ) THEN
/*Bug1635257
 The po_uom_convert function was returning a very high precision
 after converting units while creating PO from requisitions
 in autocreate. Thus the value being returned by the function
 call was rounded off to 5 digits after decimal to prevent
 such high prcision to be generated.
*/
      /* bug 1921133
       If we round the conversion rate as done in the above bugfix there will
       be inaccuracies in the final quantity. so we need to round the quantity
       after muliplying with the rate intead of the rate itself */

          /* <TIMEPHASED FPI START> */

-- bug2763177
-- should not comment out derivation of x_conversion_rate as it is
-- used for quantity conversion

          x_conversion_rate := po_uom_s.po_uom_convert(req_line.req_uom,
                                             req_line.po_uom,
                                             req_line.item_id);

        /* Bug 2758378 - The parameters for uom_convert was in the wrong order
        which resulted in Create Releases program to complete with error
        exiting with status 1. Interchanged the req_line.item_id and the
        req_line.po_uom parameters   */

          po_uom_s.uom_convert(req_line.quantity,
                               req_line.req_uom,
                               req_line.item_id,
                               req_line.po_uom,
                               l_quantity);
          /* <TIMEPHASED FPI END> */

       END IF;

       --<INVCONV R12 START>
       --Ensure secondary qty/UOM populated if appropriate
       x_secondary_unit_of_measure := req_line.secondary_unit_of_measure;
       x_secondary_quantity        := req_line.secondary_quantity;

       IF x_secondary_quantity is NULL and req_line.item_id is NOT NULL THEN
         PO_UOM_S.get_secondary_uom(  req_line.item_id,
                                      req_line.destination_organization_id,
                                      x_secondary_uom_code,
                                      x_secondary_unit_of_measure);

         IF x_secondary_unit_of_measure is NOT NULL THEN
           po_uom_s.uom_convert(req_line.quantity,
                               req_line.req_uom,
                               req_line.item_id,
                               x_secondary_unit_of_measure,
                               x_secondary_quantity);
         ELSE
           x_secondary_quantity := NULL;
           x_secondary_unit_of_measure := NULL;
         END IF;
       END IF;
       --<INVCONV R12 END>

       /* <TIMEPHASED FPI START> */
       l_po_line_id   := req_line.blanket_po_line_id;
       l_dest_org_id  := req_line.destination_organization_id;
       l_need_by_date := req_line.need_by_date;

       BEGIN
          --Bug 4896950: added value/matching basis, uom to select below
          select decode(price_break_lookup_code, 'CUMULATIVE', 'Y', 'N'),
                 order_type_lookup_code,
                 matching_basis,
                 unit_meas_lookup_code
          into l_price_break_type,
               l_value_basis,
               l_matching_basis,
               l_unit_meas_lookup_code
          from po_lines_all
          where po_line_id = l_po_line_id;
       EXCEPTION
          when others then
             null;
       END;

       if (l_price_break_type = 'Y') then
          l_cumulative_flag := TRUE;
       else
          l_cumulative_flag := FALSE;
       end if;

       x_best_price := po_sourcing2_sv.get_break_price(l_quantity,
                                                       l_dest_org_id,
                                                       x_ship_to_location_id,
                                                       l_po_line_id,
                                                       l_cumulative_flag,
                                                       l_need_by_date,
                                                       p_req_line_price => req_line.unit_price);--bug 8845486: Passing parameter
                                                                            --to the argument p_req_line_price
                                                         -- Bug 12844276

       /* Commented off for TIMEPHASED
       x_best_price := GET_BEST_PRICE(req_line,
                                      x_conversion_rate,
                                      x_ship_to_location_id);
       */

       /* <TIMEPHASED FPI END> */

--frkhan 1/12/99 get default country of origin code
       po_coo_s.get_default_country_of_origin(
      req_line.item_id,
      req_line.destination_organization_id,
      req_line.vendor_id,
      req_line.vendor_site_id,
      x_country_of_origin_code);

       SELECT FC.EXTENDED_PRECISION
   INTO x_ext_precision
         FROM PO_HEADERS POH, FND_CURRENCIES FC
   WHERE  POH.PO_HEADER_ID = req_line.blanket_po_header_id
   AND POH.CURRENCY_CODE = FC.CURRENCY_CODE;

       --<Bug# 3293109 START>
       if nvl(l_po_promised_def_prf, 'N') = 'Y' then
           l_promised_date := req_line.need_by_date;
       end if;
       --<Bug# 3293109 END>

  -- bug4865023 START
  l_outsourced_assembly :=
	  PO_CORE_S.get_outsourced_assembly
	  ( p_item_id        => req_line.item_id,
	    p_ship_to_org_id => req_line.destination_organization_id
	  );
  -- bug4865023 END

/* Bug 2654838 : If UOM in Blanket and Purchase requisition are same
                 then we should not convert the quantity. */

    -- Bug 3570793 START
    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_stmt (
        p_log_head => c_log_head||l_api_name,
        p_token => '',
        p_message => 'Create release shipment;'
                     ||' req_line_id: '||req_line.requisition_line_id
                     ||', po_release_id: '||x_po_release_id
                     ||', line_location_id: '||x_line_location_id
      );
    END IF;
    -- Bug 3570793 END

       INSERT INTO PO_LINE_LOCATIONS(
                            LINE_LOCATION_ID,
                            LAST_UPDATE_DATE,
                            LAST_UPDATED_BY,
                            PO_HEADER_ID,
                            CREATION_DATE,
                            CREATED_BY,
                            LAST_UPDATE_LOGIN,
                            PO_LINE_ID,
                            QUANTITY,
                            QUANTITY_RECEIVED,
                            QUANTITY_ACCEPTED,
                            QUANTITY_REJECTED,
                            QUANTITY_BILLED,
                            QUANTITY_CANCELLED,
                            SHIP_TO_LOCATION_ID,
                            NEED_BY_DATE,
                            PROMISED_DATE,
                            --togeorge 09/28/2000
                            --added note to receiver
                            note_to_receiver,
                            APPROVED_FLAG,
                            APPROVED_DATE,
                            PO_RELEASE_ID,
                            CANCEL_FLAG,
                            CLOSED_CODE,
                            PRICE_OVERRIDE,
                            ENCUMBERED_FLAG,
                            SHIPMENT_TYPE,
                            SHIPMENT_NUM,
                            INSPECTION_REQUIRED_FLAG,
                            RECEIPT_REQUIRED_FLAG,
                            GOVERNMENT_CONTEXT,
                            DAYS_EARLY_RECEIPT_ALLOWED,
                            DAYS_LATE_RECEIPT_ALLOWED,
                            ENFORCE_SHIP_TO_LOCATION_CODE,
                            SHIP_TO_ORGANIZATION_ID,
                            INVOICE_CLOSE_TOLERANCE,
                            RECEIVE_CLOSE_TOLERANCE,
                            ACCRUE_ON_RECEIPT_FLAG,
                            RECEIVING_ROUTING_ID,
                            QTY_RCV_TOLERANCE,
                            ALLOW_SUBSTITUTE_RECEIPTS_FLAG,
                            QTY_RCV_EXCEPTION_CODE,
                            RECEIPT_DAYS_EXCEPTION_CODE,
                            MATCH_OPTION,  -- bgu, Dec. 11, 98
                            COUNTRY_OF_ORIGIN_CODE, --frkhan 1/12/99
                            SECONDARY_UNIT_OF_MEASURE,
                            SECONDARY_QUANTITY,
                            PREFERRED_GRADE,
                            SECONDARY_QUANTITY_RECEIVED,
                            SECONDARY_QUANTITY_ACCEPTED,
                            SECONDARY_QUANTITY_REJECTED,
                            SECONDARY_QUANTITY_CANCELLED,
                            VMI_FLAG,   -- VMI FPH
                            DROP_SHIP_FLAG,   -- <DropShip FPJ>
                            ORG_ID,                          -- <R12 MOAC>
                            tax_attribute_update_code, --<eTax Integration R12>
                            outsourced_assembly,  -- bug 4865023
                            value_basis, --bug 4896950
                            matching_basis, --bug 4896950
                            unit_meas_lookup_code --bug 4896950
                            )
                    VALUES  (x_line_location_id,       -- :line_location_id
                             sysdate,
                             req_line.last_updated_by, -- :cpo_last_updated_by
                             req_line.blanket_po_header_id,  -- :po_header_id
                             sysdate,
                             req_line.last_updated_by, -- :cpo_last_updated_by
                             req_line.last_update_login, -- :last_update_login
                             req_line.blanket_po_line_id,   -- :po_line_id
                             decode(x_conversion_rate,1,req_line.quantity,round(req_line.quantity * x_conversion_rate,5)),--:quantity
                             0,
                             0,
                             0,
                             0,
                             0,
                             x_ship_to_location_id,   -- :ship_to_location_id,
                             req_line.need_by_date,   -- :need_by_date
                             l_promised_date,    --<Bug# 3293109>
                             --togeorge 09/28/2000
                             --added note to receiver
                             req_line.note_to_receiver,
                             DECODE(x_authorization_status,
                                      'APPROVED','Y','N'),    -- 'N'
          --Bug #1057095 insert sysdate only
          --if the shipment is approved
                             DECODE(x_authorization_status,
                                    'APPROVED', sysdate, NULL), -- approved date
                             x_po_release_id,         -- :po_release_id,
                             'N',
                             'OPEN',
                             x_best_price, /* 9168321 fix */
                                                  -- :best_price
                             'N',
                             'BLANKET',           -- :shipment_type,
                             x_shipment_num,      -- :shipment_num,
                             rcv_controls.inspection_required_flag,
                                                  -- :inspection_required_flag,
                             rcv_controls.receipt_required_flag,
                                                            --:receipt_rqd_flag,
                             null, -- :government_context,
                             rcv_controls.days_early_receipt_allowed,
                                                         -- :days_early_receipt,
                             rcv_controls.days_late_receipt_allowed,
                                                          -- :days_late_receipt,
                             rcv_controls.enforce_ship_to_location,
                                                   -- :enforce_ship_to_location,
                             req_line.destination_organization_id, -- :dest_org
                             rcv_controls.invoice_close_tolerance,
                                                    -- :invoice_close_tolerance,
                             rcv_controls.receipt_close_tolerance,
                                                    -- :receive_close_tolerance,
                             DECODE(req_line.destination_type_code, --:dst_code
                                    'EXPENSE',
                                    DECODE(rcv_controls.receipt_required_flag,
                                                       -- :receipt_required_flag
                                           'N', 'N',
                                           DECODE(x_expense_accrual_code,
                                                       -- :expense_accrual_code
                                                  'PERIOD END', 'N', 'Y')),
                                    'Y'),
                             rcv_controls.receiving_routing_id,
                             rcv_controls.qty_rcv_tolerance,
                             rcv_controls.allow_substitute_receipts_flag,
                             rcv_controls.qty_rcv_exception_code,
                             rcv_controls.receipt_days_exception_code,
                             x_invoice_match_option,  --bgu, Dec. 11, 98
                             X_COUNTRY_OF_ORIGIN_CODE, --frkhan 1/12/99
                             --<INVCONV R12 START>
                             x_secondary_unit_of_measure,
                             x_secondary_quantity,
                             req_line.preferred_grade,
                             DECODE(x_secondary_unit_of_measure,NULL,NULL,0),
                             DECODE(x_secondary_unit_of_measure,NULL,NULL,0),
                             DECODE(x_secondary_unit_of_measure,NULL,NULL,0),
                             DECODE(x_secondary_unit_of_measure,NULL,NULL,0),
                             --<INVCONV R12 END>
                             req_line.vmi_flag,   -- VMI FPH
                             req_line.drop_ship_flag,      -- <DropShip FPJ>
                             req_line.org_id,            -- <R12 MOAC>
                            'CREATE',    --<eTax integration R12>
                            l_outsourced_assembly, -- bug 4865023
                            l_value_basis, --bug 4896950
                            l_matching_basis, --bug 4896950
                            l_unit_meas_lookup_code --bug 4896950
                            );

     UPDATE PO_REQUISITION_LINES
        SET line_location_id = x_line_location_id,
      reqs_in_pool_flag = NULL, -- <REQINPOOL>
            last_update_date = SYSDATE
      WHERE requisition_line_id = req_line.requisition_line_id;

     /* bug 1921133
       If we round the conversion rate as there will be inaccuracies in the
       final quantity. so we need to round the quantity
       after muliplying with the rate intead of the rate itself */

/* bug 2994264 : need to round off the quantity as indicated in the above fix.
     The above fix indicates the rounding, but due to some reason,
     it was missed, hence doing it as a part of this fix. */
/* Bug# 3104460 - Do not update PO_LINES.QUANTITY with released amount
   UPDATE SQL deleted */

  /* Bug 947709
  ** Adding code to copy attachments from Requisition
  ** to Release.
  */

  -- Calling API to copy attachments from Requisition Lines to
  -- Release Shipments
     fnd_attached_documents2_pkg.copy_attachments('REQ_LINES',
      req_line.requisition_line_id,
      '',
      '',
      '',
      '',
      'PO_SHIPMENTS',
      x_line_location_id,
      '',
      '',
      '',
      '',
      req_line.last_updated_by,
      req_line.last_update_login,
      '',
      '',
      '');

  -- Calling API to copy Requisiton Header Attachments to
  -- Release Shipments.

    fnd_attached_documents2_pkg.copy_attachments('REQ_HEADERS',
      req_line.requisition_header_id,
      '',
      '',
      '',
      '',
      'PO_SHIPMENTS',
      x_line_location_id,
      '',
      '',
      '',
      '',
      req_line.last_updated_by,
      req_line.last_update_login,
      '',
      '',
      '');

  /* Bug #947709 */
  --<BUG 7721295 Moved the call after creation of headers,shipments and distributions>
  /*<BUG 7685164 Added as part of LCM ER>
  l_progress := '003';

  PO_DOCUMENT_CHECKS_PVT.set_lcm_flag(x_line_location_id,'AFTER',l_return_status);*/

EXCEPTION
--<BUG 7685164 Exception part added as part of LCM ER>
WHEN OTHERS THEN
        FND_FILE.put_line(FND_FILE.LOG,
                  c_log_head || l_api_name || ' exception; location: '
                  || l_progress || ' SQL code: ' || sqlcode);
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
          FND_LOG.string(FND_LOG.level_unexpected, c_log_head ||
               l_api_name || '.others_exception', 'EXCEPTION: Location is '
               || l_progress || ' SQL CODE is '||sqlcode);
        END IF;
        raise_application_error(-20001,sqlerrm||'---'||msgbuf);
END CREATE_RELEASE_SHIPMENT;


/* ============================================================================
     NAME: CREATE_RELEASE_DISTRIBUTIONS
     DESC: Create new release dsitributions
     ARGS: IN : req_line IN requisition_lines_cursor%rowtype
     ALGR: Create new release distributions

   ===========================================================================*/

PROCEDURE CREATE_RELEASE_DISTRIBUTION(
   req_line                         IN   requisition_lines_cursor%rowtype
,  p_req_enc_flag                   IN             VARCHAR2
)
IS
l_api_name CONSTANT VARCHAR2(30) := 'create_release_distribution';

x_conversion_rate         number := 1;
x_shipment_quantity       number := 0;
x_dist_quantity           number := 0;
x_qty_difference          number := 0;

x_tax_code_id         ap_tax_codes_all.tax_id%type;


BEGIN

    IF ( req_line.req_uom <> req_line.po_uom ) THEN
/*Bug1635257
 The po_uom_convert function was returning a very high precision
 after converting units while creating PO from requisitions
 in autocreate. Thus the value being returned by the function
 call was rounded off to 5 digits after decimal to prevent
 such high prcision to be generated.
*/
          x_conversion_rate := round(po_uom_s.po_uom_convert(req_line.req_uom,
                                              req_line.po_uom,
                                              req_line.item_id),5);
    END IF;

/* Bug 2654838 : If UOM in Blanket and Purchase requisition are same
                 then we should not convert the quantity. */

  BEGIN --<GRANTS FPJ>
    -- Bug 3570793 START
    IF (g_debug_stmt) THEN
      PO_DEBUG.debug_stmt (
        p_log_head => c_log_head||l_api_name,
        p_token => '',
        p_message => 'Create release distributions;'
                     ||' req_line_id: '||req_line.requisition_line_id
                     ||', po_release_id: '||x_po_release_id
                     ||', line_location_id: '||x_line_location_id
      );
    END IF;
    -- Bug 3570793 END

    INSERT INTO PO_DISTRIBUTIONS
                        (PO_DISTRIBUTION_ID,
                         LAST_UPDATE_DATE,
                         LAST_UPDATED_BY,
                         PO_HEADER_ID,
                         CREATION_DATE,
                         CREATED_BY,
                         LAST_UPDATE_LOGIN,
                         PO_LINE_ID,
                         LINE_LOCATION_ID,
                         PO_RELEASE_ID,
                         REQ_DISTRIBUTION_ID,
                         SET_OF_BOOKS_ID,
                         CODE_COMBINATION_ID,
                         DELIVER_TO_LOCATION_ID,
                         DELIVER_TO_PERSON_ID,
                         QUANTITY_ORDERED,
                         QUANTITY_DELIVERED,
                         QUANTITY_BILLED,
                         QUANTITY_CANCELLED,
                         RATE_DATE,
                         RATE,
                         ACCRUED_FLAG,
                         ENCUMBERED_FLAG,
                         GL_ENCUMBERED_DATE,
                         GL_ENCUMBERED_PERIOD_NAME,
                         DISTRIBUTION_NUM,
                         DESTINATION_TYPE_CODE,
                         DESTINATION_ORGANIZATION_ID,
                         DESTINATION_SUBINVENTORY,
                         BUDGET_ACCOUNT_ID,
                         ACCRUAL_ACCOUNT_ID,
                         VARIANCE_ACCOUNT_ID,
                         WIP_ENTITY_ID,
                         WIP_LINE_ID,
                         WIP_REPETITIVE_SCHEDULE_ID,
                         WIP_OPERATION_SEQ_NUM,
                         WIP_RESOURCE_SEQ_NUM,
                         BOM_RESOURCE_ID,
                         GOVERNMENT_CONTEXT,
                         PREVENT_ENCUMBRANCE_FLAG,
                         PROJECT_ID,
                         TASK_ID,
                         AWARD_ID,    -- OGM_0.0
                         EXPENDITURE_TYPE,
                         PROJECT_ACCOUNTING_CONTEXT,
                         DESTINATION_CONTEXT,
                         EXPENDITURE_ORGANIZATION_ID,
                         EXPENDITURE_ITEM_DATE,
                         ACCRUE_ON_RECEIPT_FLAG,
                         KANBAN_CARD_ID,
                         TAX_RECOVERY_OVERRIDE_FLAG, --<eTax Integration R12>
                         RECOVERY_RATE,
                         --togeorge 10/05/2000
                         --added oke columns
                         oke_contract_line_id,
                         oke_contract_deliverable_id,
                         --spangulu 09/16/2003
                         --added distribution_type for encumb. rewrite
                         distribution_type,
                         Org_Id                    -- <R12 MOAC>
                         )
                SELECT   PO_DISTRIBUTIONS_S.NEXTVAL,
                         sysdate,
                         req_line.last_updated_by, -- :cpo_last_updated_by
                         req_line.blanket_po_header_id, --:po_header_id
                         sysdate,
                         req_line.last_updated_by, -- :cpo_last_updated_by,
                         req_line.last_update_login, -- :last_update_login,
                         req_line.blanket_po_line_id, -- :po_line_id,
                         x_line_location_id, -- :line_location_id
                         x_po_release_id,  -- :po_release_id
                         PRD.DISTRIBUTION_ID,
                         PRD.SET_OF_BOOKS_ID,
                         PRD.CODE_COMBINATION_ID,
                         req_line.deliver_to_location_id, --:deliver_to_loc_id
                         req_line.deliver_to_person_id, --:deliver_to_per_id
                         decode(x_conversion_rate,1,prd.req_line_quantity,round(prd.req_line_quantity * x_conversion_rate,5)),
                                                         -- :div by rate????
                         0,
                         0,
                         0,
                         ph.rate_date,
                         ph.rate,
                         'N',
                         'N'
                         --<Encumbrance FPJ>
                         -- If Req encumbrance is on, copy the Req period.
                         -- Otherwise, if PO enc is on and SYSDATE is open
                         -- (x_period_name tries to tell us this, but is buggy)
                         -- then use SYSDATE.  Otherwise, NULL.

                         -- gl_encumbered_date =
                         ,  DECODE(  p_req_enc_flag
                                   ,  'Y', PRD.gl_encumbered_date
                                   ,  DECODE(  x_period_name
                                              ,  '', TO_DATE(NULL)
                                             ,  TRUNC(SYSDATE)
                                            )
                                  )
                         -- gl_encumbered_period_name =
                         ,  DECODE(  p_req_enc_flag
                                  ,  'Y', PRD.gl_encumbered_period_name
                                  ,  x_period_name
                                  )
                         ,  PRD.DISTRIBUTION_NUM, -- (:distribution_num + ROWNUM),
                         PRL.DESTINATION_TYPE_CODE,
                         PRL.DESTINATION_ORGANIZATION_ID,
                         PRL.DESTINATION_SUBINVENTORY,
                         PRD.BUDGET_ACCOUNT_ID,
                         PRD.ACCRUAL_ACCOUNT_ID,
                         PRD.VARIANCE_ACCOUNT_ID,
                         PRL.WIP_ENTITY_ID,
                         PRL.WIP_LINE_ID,
                         PRL.WIP_REPETITIVE_SCHEDULE_ID,
                         PRL.WIP_OPERATION_SEQ_NUM,
                         PRL.WIP_RESOURCE_SEQ_NUM,
                         PRL.BOM_RESOURCE_ID,
                         PH.GOVERNMENT_CONTEXT
                         --<ENCUMBRANCE FPJ>
                         -- prevent_encumbrance_flag =
                         /* ,  DECODE(  PRL.destination_type_code
                                  ,  g_dest_type_code_SHOP_FLOOR, 'Y'
                                  ,  'N'
                                  )   */
                            , DECODE(  PRL.destination_type_code
                        			,  g_dest_type_code_SHOP_FLOOR
                        					, decode((select entity_type
									  from wip_entities
									  where wip_entity_id= PRL.wip_entity_id),6, 'N', 'Y')
                        ,  'N'
                        )         /* Encumbrance Project - To enable encumbrance for destination type Shop Floor and WIP entity type EAM  */
                         ,  PRD.PROJECT_ID,
                         PRD.TASK_ID,
                         PRD.AWARD_ID,    -- OGM_0.0 Change
                         PRD.EXPENDITURE_TYPE,
                         PRD.PROJECT_ACCOUNTING_CONTEXT,
                         PRL.DESTINATION_CONTEXT,
                         PRD.EXPENDITURE_ORGANIZATION_ID,
                         PRD.EXPENDITURE_ITEM_DATE,
                         PLL.ACCRUE_ON_RECEIPT_FLAG,
                         PRL.KANBAN_CARD_ID,
                         nvl(PRD.TAX_RECOVERY_OVERRIDE_FLAG, 'N'),
                         decode(PRD.TAX_RECOVERY_OVERRIDE_FLAG, 'Y', PRD.RECOVERY_RATE, null),--<R12 eTax Integration>
                         --togeorge 10/05/2000
                         --added oke columns
                         PRD.oke_contract_line_id,
                         PRD.oke_contract_deliverable_id,
                         --spangulu 09/16/2003
                         --added distribution_type for encumb. rewrite
                         PLL.shipment_type,
                         PH.Org_Id                    -- <R12 MOAC>
                  FROM   PO_REQ_DISTRIBUTIONS PRD,
                         PO_REQUISITION_LINES PRL,
                         PO_HEADERS           PH,
                         PO_LINE_LOCATIONS    PLL
                  WHERE  PRD.REQUISITION_LINE_ID = req_line.requisition_line_id
                  AND    PRL.REQUISITION_LINE_ID = req_line.requisition_line_id
                  AND    PH.PO_HEADER_ID = req_line.blanket_po_header_id
                  AND    PLL.LINE_LOCATION_ID  = x_line_location_id;

  --<GRANTS FPJ START>
    create_award_distribution;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO PORELGEN_1;
      RAISE;
  END;
  --<GRANTS FPJ END>

    SELECT POLL.quantity
      INTO x_shipment_quantity
      FROM PO_LINE_LOCATIONS POLL,
           PO_REQUISITION_LINES PORL
     WHERE POLL.LINE_LOCATION_ID = PORL.LINE_LOCATION_ID
       AND PORL.REQUISITION_LINE_ID
                    = req_line.requisition_line_id;

    SELECT SUM(POD.QUANTITY_ORDERED)
      INTO x_dist_quantity
      FROM PO_LINE_LOCATIONS POLL,
           PO_REQUISITION_LINES PORL,
           PO_DISTRIBUTIONS POD
     WHERE POLL.LINE_LOCATION_ID = PORL.LINE_LOCATION_ID
       AND PORL.REQUISITION_LINE_ID
                    = req_line.requisition_line_id
       AND POD.LINE_LOCATION_ID = POLL.LINE_LOCATION_ID;

    x_qty_difference := x_shipment_quantity-x_dist_quantity;

    IF (x_qty_difference <> 0) THEN
      UPDATE PO_DISTRIBUTIONS POD
         SET POD.QUANTITY_ORDERED
                  = POD.QUANTITY_ORDERED + x_qty_difference
       WHERE POD.PO_DISTRIBUTION_ID =
              (SELECT POD2.PO_DISTRIBUTION_ID
                 FROM PO_DISTRIBUTIONS POD2,
                      PO_LINE_LOCATIONS POLL,
                      PO_REQUISITION_LINES PORL
                WHERE POD2.LINE_LOCATION_ID
                                 = POLL.LINE_LOCATION_ID
                  AND POLL.LINE_LOCATION_ID
                                 = PORL.LINE_LOCATION_ID
                  AND PORL.REQUISITION_LINE_ID
                              = req_line.requisition_line_id
                  AND POD2.distribution_num=1);
   END IF;


EXCEPTION
   WHEN OTHERS THEN
       raise_application_error(-20001,sqlerrm||'---'||msgbuf);

END CREATE_RELEASE_DISTRIBUTION;


/* ============================================================================
     NAME: GET_RCV_CONTROLS
     DESC: Get receiving controls
     ARGS: IN : req_line IN requisition_lines_cursor%rowtype
           IN OUT: rcv_controls IN OUT rcv_control_type
     ALGR:  Get all the receiving controls required

   ===========================================================================*/

PROCEDURE GET_RCV_CONTROLS(req_line IN requisition_lines_cursor%rowtype,
                           rcv_controls IN OUT NOCOPY rcv_control_type)
IS
BEGIN
   IF (req_line.item_id is not NULL) THEN
        select nvl(rcv_controls.inspection_required_flag,
                                msi.INSPECTION_REQUIRED_FLAG),
               nvl(rcv_controls.days_early_receipt_allowed,
                                msi.DAYS_EARLY_RECEIPT_ALLOWED),
               nvl(rcv_controls.days_late_receipt_allowed,
                                msi.DAYS_LATE_RECEIPT_ALLOWED),
               nvl(rcv_controls.enforce_ship_to_location,
                                msi.ENFORCE_SHIP_TO_LOCATION_CODE),
               nvl(rcv_controls.invoice_close_tolerance,
                                msi.INVOICE_CLOSE_TOLERANCE),
               nvl(rcv_controls.receipt_close_tolerance,
                                msi.RECEIVE_CLOSE_TOLERANCE),
               nvl(rcv_controls.receiving_routing_id,
                                msi.RECEIVING_ROUTING_ID),
               nvl(rcv_controls.qty_rcv_tolerance,
                                msi.QTY_RCV_TOLERANCE),
         nvl(rcv_controls.allow_substitute_receipts_flag,
        msi.ALLOW_SUBSTITUTE_RECEIPTS_FLAG),
         nvl(rcv_controls.qty_rcv_exception_code,
        msi.QTY_RCV_EXCEPTION_CODE),
         nvl(rcv_controls.receipt_required_flag,
        msi.RECEIPT_REQUIRED_FLAG),
               nvl(rcv_controls.receipt_days_exception_code,
                                msi.RECEIPT_DAYS_EXCEPTION_CODE)
              into rcv_controls.inspection_required_flag,
                   rcv_controls.days_early_receipt_allowed,
                   rcv_controls.days_late_receipt_allowed,
                   rcv_controls.enforce_ship_to_location,
                   rcv_controls.invoice_close_tolerance,
                   rcv_controls.receipt_close_tolerance,
                   rcv_controls.receiving_routing_id,
                   rcv_controls.qty_rcv_tolerance,
       rcv_controls.allow_substitute_receipts_flag,
       rcv_controls.qty_rcv_exception_code,
       rcv_controls.receipt_required_flag,
                   rcv_controls.receipt_days_exception_code
              from mtl_system_items msi
             where msi.inventory_item_id = req_line.item_id
               and msi.organization_id = req_line.destination_organization_id;
   END IF;

   -- Bug: 1322342 Select inspection required flag and receipt required flag
   -- also if destination org returns null

   IF (rcv_controls.receipt_close_tolerance  is null) OR
      (rcv_controls.invoice_close_tolerance  is null) OR
      (rcv_controls.receipt_required_flag    is null) OR
      (rcv_controls.inspection_required_flag is null) THEN

      BEGIN
     select nvl(rcv_controls.receipt_close_tolerance,
                 receive_close_tolerance),
        nvl(rcv_controls.invoice_close_tolerance,
                 invoice_close_tolerance),
            nvl(rcv_controls.receipt_required_flag,
                 receipt_required_flag),
            nvl(rcv_controls.inspection_required_flag,
                 inspection_required_flag)
     into   rcv_controls.receipt_close_tolerance,
        rcv_controls.invoice_close_tolerance,
                rcv_controls.receipt_required_flag,
                rcv_controls.inspection_required_flag
     from   mtl_system_items
     where  organization_id   = x_inventory_org_id
     and    inventory_item_id = req_line.item_id;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
    NULL;
      END;
   END IF;

   IF (req_line.blanket_po_line_id is not NULL) THEN
       select nvl(rcv_controls.receipt_required_flag,plt.receiving_flag)
         into rcv_controls.receipt_required_flag
         from po_lines pol,
              po_line_types plt
        where pol.po_line_id = req_line.blanket_po_line_id
         and  pol.line_type_id = plt.line_type_id;
   END IF;

      --Begin fix4388305(forward fix4379167)
   IF (req_line.blanket_po_line_id is not NULL AND
       rcv_controls.receipt_close_tolerance is null) THEN

       select nvl(rcv_controls.receipt_close_tolerance, plt.receive_close_tolerance)
         into rcv_controls.receipt_close_tolerance
         from po_lines pol,
              po_line_types plt
        where pol.po_line_id = req_line.blanket_po_line_id
          and pol.line_type_id = plt.line_type_id;
   END IF;
   -- End fix4388305(forward fix4379167)

   IF (req_line.vendor_id is not NULL) THEN
       select nvl(rcv_controls.inspection_required_flag,
                               pov.INSPECTION_REQUIRED_FLAG),
              nvl(rcv_controls.days_early_receipt_allowed,
                               pov.DAYS_EARLY_RECEIPT_ALLOWED),
              nvl(rcv_controls.days_late_receipt_allowed,
                               pov.DAYS_LATE_RECEIPT_ALLOWED),
              nvl(rcv_controls.enforce_ship_to_location,
                               pov.ENFORCE_SHIP_TO_LOCATION_CODE),
              nvl(rcv_controls.receiving_routing_id,
                               pov.RECEIVING_ROUTING_ID),
              nvl(rcv_controls.qty_rcv_tolerance,
                               pov.QTY_RCV_TOLERANCE),
              nvl(rcv_controls.allow_substitute_receipts_flag,
                               pov.ALLOW_SUBSTITUTE_RECEIPTS_FLAG),
              nvl(rcv_controls.qty_rcv_exception_code,
                               pov.QTY_RCV_EXCEPTION_CODE),
              nvl(rcv_controls.receipt_required_flag,
                               pov.RECEIPT_REQUIRED_FLAG),
              nvl(rcv_controls.receipt_days_exception_code,
                               pov.RECEIPT_DAYS_EXCEPTION_CODE)
        into  rcv_controls.inspection_required_flag,
              rcv_controls.days_early_receipt_allowed,
              rcv_controls.days_late_receipt_allowed,
              rcv_controls.enforce_ship_to_location,
              rcv_controls.receiving_routing_id,
              rcv_controls.qty_rcv_tolerance,
              rcv_controls.allow_substitute_receipts_flag,
              rcv_controls.qty_rcv_exception_code,
              rcv_controls.receipt_required_flag,
              rcv_controls.receipt_days_exception_code
        from  po_vendors pov
       where  pov.vendor_id = req_line.vendor_id;
   END IF;
   select nvl(rcv_controls.days_early_receipt_allowed,
                           rp.DAYS_EARLY_RECEIPT_ALLOWED),
          nvl(rcv_controls.days_late_receipt_allowed,
                           rp.DAYS_LATE_RECEIPT_ALLOWED),
          nvl(rcv_controls.enforce_ship_to_location,
                           rp.ENFORCE_SHIP_TO_LOCATION_CODE),
          nvl(rcv_controls.receiving_routing_id,
                           rp.RECEIVING_ROUTING_ID),
          nvl(rcv_controls.qty_rcv_tolerance,
                           rp.QTY_RCV_TOLERANCE),
          nvl(rcv_controls.allow_substitute_receipts_flag,
                           rp.ALLOW_SUBSTITUTE_RECEIPTS_FLAG),
          nvl(rcv_controls.qty_rcv_exception_code,
                           rp.QTY_RCV_EXCEPTION_CODE),
          nvl(rcv_controls.receipt_days_exception_code,
                           rp.RECEIPT_DAYS_EXCEPTION_CODE)
     into rcv_controls.days_early_receipt_allowed,
          rcv_controls.days_late_receipt_allowed,
          rcv_controls.enforce_ship_to_location,
          rcv_controls.receiving_routing_id,
          rcv_controls.qty_rcv_tolerance,
          rcv_controls.allow_substitute_receipts_flag,
          rcv_controls.qty_rcv_exception_code,
          rcv_controls.receipt_days_exception_code
     from rcv_parameters rp
    where rp.organization_id = req_line.destination_organization_id;
   select nvl(rcv_controls.inspection_required_flag,
                           posp.INSPECTION_REQUIRED_FLAG),
          nvl(rcv_controls.receipt_required_flag,
                           posp.RECEIVING_FLAG),
          nvl(rcv_controls.invoice_close_tolerance,
                           posp.INVOICE_CLOSE_TOLERANCE),
          nvl(rcv_controls.receipt_close_tolerance,
                           posp.RECEIVE_CLOSE_TOLERANCE)
     into rcv_controls.inspection_required_flag,
          rcv_controls.receipt_required_flag,
          rcv_controls.invoice_close_tolerance,
          rcv_controls.receipt_close_tolerance
     from po_system_parameters posp;

   IF (rcv_controls.inspection_required_flag is NULL) THEN
       rcv_controls.inspection_required_flag := 'N';
   END IF;

   -- begin bug 3330748
   IF (req_line.drop_ship_flag = 'Y') THEN
       rcv_controls.inspection_required_flag := 'N';
   END IF;
   -- begin bug 3330748


   IF (rcv_controls.receipt_required_flag is  NULL) THEN
       rcv_controls.receipt_required_flag := 'N';
   END IF;

   IF (rcv_controls.days_early_receipt_allowed is NULL) THEN
       rcv_controls.days_early_receipt_allowed := 0;
   END IF;

   IF (rcv_controls.days_late_receipt_allowed is NULL) THEN
       rcv_controls.days_late_receipt_allowed := 0;
   END IF;

   /* Bug# 2206626 - Replaced 'N' with 'NONE' */
   IF (rcv_controls.enforce_ship_to_location is NULL) THEN
       rcv_controls.enforce_ship_to_location := 'NONE';
   END IF;

   IF (rcv_controls.invoice_close_tolerance is NULL) THEN
       rcv_controls.invoice_close_tolerance := '0';
   END IF;

   IF (rcv_controls.receipt_close_tolerance is NULL) THEN
       rcv_controls.receipt_close_tolerance := '0';
   END IF;


   --bug3211753
   --For drop shipments, receipt routing is always 3 (direct delivery)
   IF (req_line.drop_ship_flag = 'Y') THEN
       rcv_controls.receiving_routing_id := 3;
   -- <<Start of Bug Fix::14762318>>
   -- For four way matching, receipt routing is always Inspection Required(2)
   ELSIF (rcv_controls.inspection_required_flag = 'Y'
       AND rcv_controls.receipt_required_flag = 'Y')
   THEN
       rcv_controls.receiving_routing_id := 2; --Inspection Required
   ELSE
     NULL;
   -- <<End of Bug Fix::14762318>>
   END IF;

EXCEPTION
   WHEN OTHERS THEN
       raise_application_error(-20001,sqlerrm||'---'||msgbuf);

END GET_RCV_CONTROLS;

/* ==========================================================================
     NAME: GET_INVOICE_MATCH_OPTION
     DESC: Default match option from vendor site, vendor, down to financial
     system defaults
     ARGS: IN : req_line IN requisition_lines_cursor%rowtype
           OUT: invoice_match_option
     AUTHOR: bgu, Dec. 10, 98
   =========================================================================*/

PROCEDURE GET_INVOICE_MATCH_OPTION(req_line IN requisition_lines_cursor%rowtype,
                                 x_invoice_match_option OUT NOCOPY varchar2)
IS
BEGIN

   x_invoice_match_option := NULL;

   if (req_line.vendor_site_id is not null) then
     /* Retrieve Invoice Match Option from Vendor site*/
     SELECT match_option
     INTO   x_invoice_match_option
     FROM   po_vendor_sites
     WHERE  vendor_site_id = req_line.vendor_site_id;
   end if;

   if(x_invoice_match_option is NULL) then
     /* Retrieve Invoice Match Option from Vendor */
     if (req_line.vendor_id is not null) then
       SELECT match_option
       INTO   x_invoice_match_option
       FROM   po_vendors
       WHERE  vendor_id = req_line.vendor_id;
     end if;
   end if;

   if(x_invoice_match_option is NULL) then
     /* Retrieve Invoice Match Option from Financial System Parameters */
     SELECT fsp.match_option
     INTO   x_invoice_match_option
     FROM   financials_system_parameters fsp;
   end if;

EXCEPTION
   WHEN OTHERS THEN
       raise_application_error(-20001,sqlerrm||'---'||msgbuf);

END GET_INVOICE_MATCH_OPTION;


/* ============================================================================
     NAME: MAINTAIN_SUPPLY
     DESC: Maintain the supply view
     ARGS: IN : req_line IN requisition_lines_cursor%rowtype
     ALGR: If the release created is approved, delete req supply and create
           Po supply

   ===========================================================================*/

PROCEDURE MAINTAIN_SUPPLY(req_line IN requisition_lines_cursor%rowtype)
IS
BEGIN

if (x_authorization_status = 'APPROVED') THEN

  DELETE FROM MTL_SUPPLY
        WHERE SUPPLY_TYPE_CODE = 'REQ'
        AND SUPPLY_SOURCE_ID = req_line.requisition_line_id;

  INSERT INTO MTL_SUPPLY
               (supply_type_code,
                supply_source_id,
          last_updated_by,
          last_update_date,
          last_update_login,
          created_by,
    creation_date,
                po_header_id,
                po_release_id,
                po_line_id,
                po_line_location_id,
                po_distribution_id,
                item_id,
                item_revision,
                quantity,
                unit_of_measure,
                receipt_date,
                need_by_date,
                destination_type_code,
                location_id,
                to_organization_id,
                to_subinventory,
                change_flag)
                       select 'PO',
                       pod.po_distribution_id,
                 pod.last_updated_by,
                 pod.last_update_date,
                 pod.last_update_login,
                 pod.created_by,
           pod.creation_date,
                       pod.po_header_id,
                       x_po_release_id,        -- :po_release_id
                       pod.po_line_id,
                       pod.line_location_id,
                       pod.po_distribution_id,
                       pol.item_id,
                       pol.item_revision,
                       pod.quantity_ordered,
                       pol.unit_meas_lookup_code,
                       nvl(poll.promised_date,poll.need_by_date),
                       poll.need_by_date,
                       pod.destination_type_code,
                       pod.deliver_to_location_id,
                       pod.destination_organization_id,
                       pod.destination_subinventory,
                       'Y'
                from   po_distributions pod,
                       po_line_locations poll,
                       po_lines pol
                where  poll.line_location_id = x_line_location_id
                and    nvl(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
                and    nvl(poll.closed_code, 'OPEN') <> 'CLOSED'
    and    nvl(poll.closed_code, 'OPEN') <> 'CLOSED FOR RECEIVING'
    and    nvl(poll.cancel_flag, 'N') = 'N'
                and    pod.line_location_id = poll.line_location_id
                and    pol.po_line_id = pod.po_line_id
                and    nvl(poll.approved_flag, 'Y') = 'Y'
    and    not exists
                       (select 'Supply Exists'
                        from   mtl_supply ms1
                        where  ms1.supply_type_code = 'PO'
      and    ms1.supply_source_id = pod.po_distribution_id);

END IF;

EXCEPTION
   WHEN OTHERS THEN
       raise_application_error(-20001,sqlerrm||'---'||msgbuf);

END MAINTAIN_SUPPLY;

/* ============================================================================
     NAME: WRAPUP
     DESC: insert into the notifications table and the action history table
     ARGS: IN : req_line IN requisition_lines_cursor%rowtype
     ALGR: If the release is not approved, insert appropriate rows into
           PO_NOTIFICATIONS
           else insert appropriate rows into PO_ACTION_HISTORY

   ===========================================================================*/

PROCEDURE WRAPUP(req_line IN requisition_lines_cursor%rowtype)
IS
BEGIN

  IF (x_authorization_status <> 'APPROVED') THEN

   /* obsolete in R11
     INSERT INTO PO_NOTIFICATIONS
                   (EMPLOYEE_ID,
                    OBJECT_TYPE_LOOKUP_CODE,
                    OBJECT_ID,
                    OBJECT_CREATION_DATE,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_LOGIN,
                    CREATION_DATE,
                    CREATED_BY,
                    ACTION_LOOKUP_CODE)
            SELECT  AGENT_ID,
                    'RELEASE',
                    PO_RELEASE_ID,
                    TRUNC(CREATION_DATE),
                    sysdate,
                    req_line.last_updated_by,
                    req_line.last_update_login,
                    sysdate,
                    req_line.last_updated_by,
                    DECODE(HOLD_FLAG,
                           'Y','ON_HOLD',
                           DECODE(APPROVED_FLAG,
                                  'R','REQUIRES_REAPPROVAL',
                                  'F','FAILED_APPROVAL',
                                  'NEVER_APPROVED'))
             FROM   PO_RELEASES
             WHERE  NVL(CANCEL_FLAG,'N') = 'N'
             AND    NVL(APPROVED_FLAG,'N') <> 'Y'
             AND    PO_RELEASE_ID = x_po_release_id; */
    null;
   ELSE

       INSERT into PO_ACTION_HISTORY
             (object_id,
              object_type_code,
              object_sub_type_code,
              sequence_num,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              action_code,
              action_date,
              employee_id,
              note,
              object_revision_num,
              last_update_login,
              request_id,
              program_application_id,
              program_id,
              program_update_date,
              approval_path_id,
              offline_code)
             VALUES
             (x_po_release_id,
              'RELEASE',
              'BLANKET',
              1, --Bug 13370924. Sequence Number starts with 1.
              sysdate,
              req_line.last_updated_by,
              sysdate,
              req_line.last_updated_by,
              'SUBMIT',
              sysdate,
              req_line.agent_id,
              'AUTO RELEASE',
              0,
              req_line.last_update_login,
              0,
              0,
              0,
              '',
              null,
              null);

       INSERT into PO_ACTION_HISTORY
             (object_id,
              object_type_code,
              object_sub_type_code,
              sequence_num,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              action_code,
              action_date,
              employee_id,
              note,
              object_revision_num,
              last_update_login,
              request_id,
              program_application_id,
              program_id,
              program_update_date,
              approval_path_id,
              offline_code)
             VALUES
             (x_po_release_id,
              'RELEASE',
              'BLANKET',
              2,  --Bug 13370924
              sysdate,
              req_line.last_updated_by,
              sysdate,
              req_line.last_updated_by,
              'APPROVE',
              sysdate,
              req_line.agent_id,
              'AUTO RELEASE',
              0,
              req_line.last_update_login,
              0,
              0,
              0,
              '',
              null,
              null);

   END IF;

EXCEPTION
   WHEN OTHERS THEN
       raise_application_error(-20001,sqlerrm||'---'||msgbuf);

END WRAPUP;

/* ============================================================================
     NAME: GET_BEST_PRICE
     DESC: Get the best price for the sourced requisition line
     ARGS: req_line IN requisition_lines_cursor%rowtype
           x_conversion_rate IN number
           x_ship_to_location_id IN number
  RETURNS: best_price number
     ALGR: determine whether the price break is cumulative or not
           get the best price based on the price break type

   ===========================================================================*/

FUNCTION GET_BEST_PRICE(req_line IN requisition_lines_cursor%rowtype,
                                 x_conversion_rate IN number,
                                 x_ship_to_location_id IN number)
return number
IS
x_price_break_type varchar2(20) := '';
x_best_price number := 0;
x_price_break_quantity number :=0;
x_po_line_price number := 0;
BEGIN

     /* Get the price break type CUMULATIVE or NON CUMULATIVE */

     SELECT PRICE_BREAK_LOOKUP_CODE
       INTO x_price_break_type
       FROM PO_LINES
      WHERE PO_LINE_ID = req_line.blanket_po_line_id;

     /* Get the price break quantity based on the price break type  */
     /* This is done by calculating the released amount if required */
     /* and adding the current quantity to it */

     IF (x_price_break_type = 'CUMULATIVE') THEN

          -- Bug 521788, lpo, 03/26/98
          -- Ported SVAIDYAN's fix to r11.
          -- If there are no releases yet, then the sum would give a null value
          -- Hence, added a nvl for it.

          SELECT nvl(SUM(QUANTITY - nvl(QUANTITY_CANCELLED, 0)), 0)
            INTO x_price_break_quantity
            FROM PO_LINE_LOCATIONS
           WHERE PO_LINE_ID = req_line.blanket_po_line_id
             AND SHIPMENT_TYPE <> 'PRICE BREAK';

          -- End of fix. Bug 521788, lpo, 03/26/98

     END IF;

     IF (x_price_break_type = 'NON CUMULATIVE') THEN
         x_price_break_quantity := 0;
     END IF;

      /* bug 1921133
       If we round the conversion rate as there will be inaccuracies in the
       final quantity. so we need to round the quantity
       after muliplying with the rate intead of the rate itself */

/* Bug 2654838 : If UOM in Blanket and Purchase requisition are same
                 then we should not convert the quantity. */

     if(x_conversion_rate=1) then
        x_price_break_quantity := x_price_break_quantity + req_line.quantity;
     else
        x_price_break_quantity := x_price_break_quantity
                                   + round(req_line.quantity * x_conversion_rate,5);
     end if;

    /* Get the blanket line price */

    SELECT UNIT_PRICE
      INTO x_po_line_price
      FROM PO_LINES
     WHERE PO_LINE_ID = req_line.blanket_po_line_id;

     /* Determine the final price for the item shipment */

     SELECT LEAST(NVL(MIN(PRICE_OVERRIDE), x_po_line_price), x_po_line_price)
       INTO x_best_price
       FROM PO_LINE_LOCATIONS
      WHERE SHIPMENT_TYPE = 'PRICE BREAK'
        AND PO_LINE_ID    = req_line.blanket_po_line_id
        AND QUANTITY     <= x_price_break_quantity
        AND (SHIP_TO_LOCATION_ID = NVL(x_ship_to_location_id,
                                        SHIP_TO_LOCATION_ID)
             OR
             SHIP_TO_LOCATION_ID IS NULL)
        AND (SHIP_TO_ORGANIZATION_ID
                          = NVL(req_line.destination_organization_id,
                                            SHIP_TO_ORGANIZATION_ID)
             OR
             SHIP_TO_ORGANIZATION_ID IS NULL);

     RETURN(x_best_price);

EXCEPTION
   WHEN OTHERS THEN
       raise_application_error(-20001,sqlerrm||'---'||msgbuf);

END GET_BEST_PRICE;


/* ============================================================================
     NAME: CHECK_AMOUNT_LIMITS
     DESC: Perform document level amount limit checks
     ARGS: IN : x_old_po_header_id IN NUMBER
     ALGR: Get the amount of the current release
           Determine the total amount released against blanket if this
           release were to be included
           Get blanket maximum amount limit
           Get blanket minimum amount limit
           The total including this release must be >= than the
           minimum and <= the maximum

   ===========================================================================*/

PROCEDURE CHECK_AMOUNT_LIMITS(x_old_po_header_id IN NUMBER,x_req_num IN varchar2,x_req_line_num IN NUMBER,
                              x_check_status OUT NOCOPY VARCHAR2 -- Bug 2701147
)
IS
release_amount number := 0;
total_release_amount number := 0;
min_release_amount number := 0;
max_release_amount number :=0;
x_error_msg            varchar2(2000);
x_po_num   varchar2(20);
BEGIN
   x_check_status := FND_API.G_RET_STS_SUCCESS; -- Bug 2701147

   SELECT nvl(sum(poll.quantity * poll.price_override),0)
     INTO release_amount
     FROM po_line_locations poll
    WHERE poll.po_release_id = x_po_release_id
      AND poll.shipment_type = 'BLANKET';

   SELECT nvl(sum(poll.quantity * poll.price_override),0)
     INTO total_release_amount
     FROM po_line_locations poll,
          po_releases por,
          po_headers poh
    WHERE poh.po_header_id = x_old_po_header_id
      AND poll.po_header_id = poh.po_header_id
      AND poll.shipment_type = 'BLANKET'
      AND poll.po_release_id = por.po_release_id
      AND (nvl(por.approved_flag,'N') = 'Y'
           OR por.po_release_id = x_po_release_id)
      AND nvl(poll.cancel_flag,'N') = 'N';

   SELECT nvl(poh.min_release_amount,0)
     INTO min_release_amount
     FROM po_headers poh
    WHERE po_header_id = x_old_po_header_id;

   SELECT nvl(poh.amount_limit,-1),segment1
     INTO max_release_amount,x_po_num
     FROM po_headers poh
    WHERE po_header_id = x_old_po_header_id;


   IF (release_amount < min_release_amount)
   THEN
     -- Bug 2701147 START
     -- Write an error message to the log file.
     x_error_msg := FND_MESSAGE.GET_STRING('PO',
                                           'PO_SUB_REL_AMT_LESS_MINREL_AMT');
     FND_FILE.put_line(FND_FILE.LOG,
           substr(g_reqmsg||g_delim||x_req_num||g_delim||g_linemsg||g_delim||
               x_req_line_num||g_delim||
               x_error_msg,1,240));
     x_check_status := FND_API.G_RET_STS_ERROR;
     -- Bug 2701147 END
   END IF;

   IF (max_release_amount <> -1 AND total_release_amount > max_release_amount)
   THEN
     /* Bug#2057344 Added the below piece of code to write the message
PO_REQ_REL_AMT_GRT_LIMIT_AMT to the log file when the Total Release amount is
greater than the Amount in BPO */
     fnd_message.set_name ('PO', 'PO_REQ_REL_AMT_GRT_LIMIT_AMT');
     fnd_message.set_token('REQ_NUM', x_req_num);
     fnd_message.set_token('LINE_NUM', x_req_line_num);
     fnd_message.set_token('PO_NUM',x_po_num);
     x_error_msg := fnd_message.get;
     fnd_file.put_line(fnd_file.log,x_error_msg);
     x_check_status := FND_API.G_RET_STS_ERROR; -- Bug 2701147
   END IF;

EXCEPTION
   WHEN OTHERS THEN
       raise_application_error(-20001,sqlerrm||'---'||msgbuf);

END CHECK_AMOUNT_LIMITS;


/* ============================================================================
     NAME: OE_DROP_SHIP
     DESC: OE drop ship call back
           update the so_drop_ship_sources table with PO info
     ARGS: IN : req_line IN requisition_lines_cursor%rowtype
   ===========================================================================*/
PROCEDURE  OE_DROP_SHIP(req_line IN requisition_lines_cursor%rowtype)
IS
 x_p_api_version    number:='';
 x_p_return_status    varchar2(1):='';
 x_p_msg_count      number:='';
 x_p_msg_data     varchar2(2000):='';
 x_p_req_header_id    NUMBER:='';
 x_p_req_line_id    NUMBER:='';
 x_p_po_header_id   number:='';
 x_p_po_line_id     number:='';
 x_p_line_location_id   number:='';
 x_p_po_release_id    number:='';
BEGIN

  x_p_api_version     := 1.0;
  x_p_req_line_id     := req_line.requisition_line_id;
  x_p_po_header_id    := req_line.blanket_po_header_id;
  x_p_po_line_id      := req_line.blanket_po_line_id;
  x_p_line_location_id:= x_line_location_id;  -- global variable
  x_p_po_release_id   := x_po_release_id;  -- global variable

  BEGIN
   SELECT requisition_header_id
   INTO   x_p_req_header_id
   FROM   po_requisition_lines
   WHERE  requisition_line_id = req_line.requisition_line_id;
  EXCEPTION
   WHEN NO_DATA_FOUND THEN raise;
   WHEN OTHERS THEN raise;
  END;

  oe_drop_ship_grp.update_po_info(x_p_api_version,
        x_p_return_status,
        x_p_msg_count,
        x_p_msg_data,
        x_p_req_header_id,
                                x_p_req_line_id,
        x_p_po_header_id,
        x_p_po_line_id,
        x_p_line_location_id,
        x_p_po_release_id
        );
EXCEPTION
  WHEN OTHERS THEN
       raise_application_error(-20001,sqlerrm||'---'||msgbuf);

END  OE_DROP_SHIP;

--- Bug 2701147 START
/**
* Private Procedure: get_req_info_from_po_dist
* Modifies: none
* Effects: Returns the requisition number and requisition line number
*   used to create the given release distribution.
**/
PROCEDURE get_req_info_from_po_dist (p_po_distribution_id IN NUMBER,
                                     x_req_num OUT NOCOPY
                                      PO_REQUISITION_HEADERS.segment1%TYPE,
                                     x_req_line_num OUT NOCOPY NUMBER)
IS
BEGIN
    SELECT prh.segment1, prl.line_num
    INTO x_req_num, x_req_line_num
    FROM po_distributions pod,
      po_req_distributions prd,
      po_requisition_lines prl,
      po_requisition_headers prh
    WHERE pod.po_distribution_id = p_po_distribution_id
    AND   pod.req_distribution_id = prd.distribution_id
    AND   prl.requisition_line_id = prd.requisition_line_id
    AND   prh.requisition_header_id = prl.requisition_header_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        x_req_num := NULL;
        x_req_line_num := NULL;
END get_req_info_from_po_dist;

/**
* Private Procedure: get_req_info_from_po_dist
* Modifies: none
* Effects: Returns the requisition number and requisition line number
*   used to create the given release shipment.
*   Note that Create Releases only creates one distribution per shipment.
**/
PROCEDURE get_req_info_from_po_shipment (p_line_location_id IN NUMBER,
                                         x_req_num OUT NOCOPY
                                          PO_REQUISITION_HEADERS.segment1%TYPE,
                                         x_req_line_num OUT NOCOPY NUMBER)
IS
  l_po_distribution_id NUMBER;
BEGIN
    SELECT min(pod.po_distribution_id)
    INTO l_po_distribution_id
    FROM po_distributions pod
    WHERE pod.line_location_id = p_line_location_id;

    get_req_info_from_po_dist (l_po_distribution_id,
                               x_req_num, x_req_line_num);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        x_req_num := NULL;
        x_req_line_num := NULL;
END get_req_info_from_po_shipment;

/**
* Private Procedure: CHECK_REL_REQPRICE
*   Note: This procedure is adapted from the Document Submission Checks API
*         (PO_DOCUMENT_CHECKS_PVT.check_po_rel_reqprice).
* Modifies: Inserts error msgs in the concurrent program log.
* Effects:  This procedure checks that the release shipment price is
*           within the tolerance of the requisition line.
* Returns:
*  x_check_status: FND_API.G_RET_STS_SUCCESS if release passes all
*                    the tolerance checks
*                  FND_API.G_RET_STS_ERROR if at least one check fails
*/
PROCEDURE check_rel_reqprice(x_check_status OUT NOCOPY VARCHAR2) IS

l_textline  po_online_report_text.text_line%TYPE := NULL;
l_api_name  CONSTANT varchar2(40) := 'CHECK_REL_REQPRICE';
l_progress VARCHAR2(3);

l_enforce_price_tolerance po_system_parameters.enforce_price_change_allowance%TYPE;
l_enforce_price_amount  po_system_parameters.enforce_price_change_amount%TYPE;
l_amount_tolerance po_system_parameters.price_change_amount%TYPE;

TYPE unit_of_measure IS TABLE of PO_LINES.unit_meas_lookup_code%TYPE;
TYPE NumTab IS TABLE of NUMBER;
l_ship_price_in_base_curr NumTab;
l_ship_unit_of_measure unit_of_measure;
l_ship_num NumTab;
l_line_num NumTab;
l_quantity NumTab;
l_item_id NumTab;
l_line_location_id NumTab;

--For Req Cursor
l_req_unit_of_measure unit_of_measure;
l_req_line_unit_price NumTab;
l_po_req_line_num NumTab;
l_po_req_ship_num NumTab;
l_po_req_quantity NumTab;

l_ship_price_ext_precn NUMBER;
l_shipment_to_req_rate NUMBER := 0;
l_price_tolerance_allowed NUMBER := 0;

l_req_num PO_REQUISITION_HEADERS.segment1%TYPE;
L_req_line_num NUMBER;

/*
** Setup the Release select cursor
** Select shipment price and convert it to base currency.
** this is done by taking the distribution rate and applying
** it evenly over all distributions.  Additionally get the
** shipment unit of measure, quantity, and item_id to be
** passed to the UomC function.  Get the shipment_num and
** line_num to be passed to the pooinsingle function.
*/
CURSOR rel_shipment_cursor (p_document_id NUMBER) IS
    SELECT nvl(max(POLL.price_override) *
        sum(decode(plt.order_type_lookup_code,'AMOUNT',1,nvl(POD.rate,1))*
                  (POD.quantity_ordered -
                   nvl(POD.quantity_cancelled, 0))) /
              (max(POLL.quantity) -
               nvl(max(POLL.quantity_cancelled),0)), -1) Price,
        POL.unit_meas_lookup_code uom,
        nvl(POLL.shipment_num,0) ship_num,
        nvl(POL.line_num,0) line_num,
        nvl(POLL.quantity,0) quantity,
        nvl(POL.item_id,0) item_id,
        nvl( POLL.line_location_id,0) line_loc_id
    FROM   PO_LINE_LOCATIONS POLL,
        PO_LINE_TYPES PLT,
        PO_LINES POL,
        PO_DISTRIBUTIONS POD
    WHERE  POLL.po_line_id    = POL.po_line_id
     AND    POLL.line_location_id = POD.line_location_id
     AND    POLL.po_release_id = p_document_id
     AND    POL.line_type_id = PLT.line_type_id
     AND    nvl(POLL.cancel_flag,'N') <> 'Y'
     AND    nvl(POLL.closed_code,'OPEN') <> 'FINALLY CLOSED'
    GROUP BY POL.unit_meas_lookup_code, nvl(POLL.shipment_num,0),
              nvl(POL.line_num,0), nvl(POLL.quantity,0),
              nvl(POL.item_id,0), POLL.price_override,
              nvl(POLL.line_location_id,0);

 CURSOR req_price_tol_cursor(p_line_location_id  NUMBER) IS
         SELECT min(PRL.unit_price),
                PRL.unit_meas_lookup_code,
                min(POL.line_num),
                min(POLL.shipment_num)
         FROM   PO_REQUISITION_LINES PRL,
                PO_LINE_LOCATIONS POLL,
                PO_LINES          POL
         WHERE  PRL.line_location_id  = POLL.line_location_id
         AND    POLL.line_location_id = p_line_location_id
         AND    PRL.unit_price        >= 0
         AND    POLL.po_line_id       = POL.po_line_id
         GROUP BY PRL.unit_meas_LOOKUP_code;

CURSOR req_price_amt_cursor(p_line_location_id  NUMBER) IS
         SELECT min(PRL.unit_price),
                 PRL.unit_meas_lookup_code,
                 sum(PD.quantity_ordered),
                 min(POL.line_num),
                 min(POLL.shipment_num)
         FROM   PO_REQUISITION_LINES PRL,
                 PO_LINE_LOCATIONS POLL,
                 PO_LINES          POL,
                 PO_DISTRIBUTIONS  PD,
                 PO_REQ_DISTRIBUTIONS PRD
         WHERE  POLL.line_location_id = p_line_location_id
          AND    POLL.po_line_id = POL.po_line_id
          AND    PRL.unit_price >= 0
          AND    POLL.line_location_id = PD.line_location_id
          AND    PD.req_distribution_id = PRD.distribution_id
          AND    PRD.requisition_line_id = PRL.requisition_line_id
         GROUP BY PRL.requisition_line_id, PRL.unit_meas_lookup_code;

BEGIN
    x_check_status := FND_API.G_RET_STS_SUCCESS;

l_progress := '000';
IF g_fnd_debug = 'Y' THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'||l_api_name||'.'
          || l_progress,'PO REQ: Price, Amount Toleance check');
   END IF;
END IF;

    --check if this check is enforced
    SELECT nvl(enforce_price_change_allowance, 'N'),
                    nvl(enforce_price_change_amount, 'N'),
                    nvl(price_change_amount, -1)
    INTO   l_enforce_price_tolerance,
           l_enforce_price_amount,
           l_amount_tolerance
    FROM   po_system_parameters;

l_progress := '001';
IF g_fnd_debug = 'Y' THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'||l_api_name||'.'
       || l_progress,'Is price tol check enforced '||l_enforce_price_tolerance
       || ' Is price amount check enforced ' || l_enforce_price_amount);
   END IF;
END IF;

    --if we are not enforcing the price tolerance checks then return success
    IF  l_enforce_price_tolerance = 'N' AND l_enforce_price_amount = 'N' THEN
        RETURN;
    END IF;

l_progress := '002';
    OPEN rel_shipment_cursor(x_po_release_id);

    FETCH rel_shipment_cursor BULK COLLECT INTO
            l_ship_price_in_base_curr,
            l_ship_unit_of_measure,
            l_ship_num,
            l_line_num,
            l_quantity,
            l_item_id,
            l_line_location_id;

    CLOSE rel_shipment_cursor;

l_progress := '004';
    FOR shipment_line IN 1..l_line_location_id.COUNT LOOP

        --Bug 1991546
        --Obtain extended precision which is used for rounding while
        --checking for tolerance
      BEGIN
        SELECT  round(l_ship_price_in_base_curr(shipment_line),nvl(FND.extended_precision,5))
        INTO  l_ship_price_ext_precn
        FROM  FND_CURRENCIES FND, PO_HEADERS POH,
             PO_LINE_LOCATIONS POLL
        WHERE  POH.po_header_id = POLL.po_header_id
         AND  POH.currency_code = FND.currency_code
         AND  POLL.line_location_id = l_line_location_id(shipment_line);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
             l_ship_price_ext_precn := l_ship_price_in_base_curr(shipment_line);
        WHEN OTHERS THEN
            RAISE;
      END;

l_progress := '005';
        --Do price tolerance check
        IF l_enforce_price_tolerance = 'Y' THEN

IF g_fnd_debug = 'Y' THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'||l_api_name||'.'
          || l_progress,'Doing Price Tolerance check');
   END IF;
END IF;
            OPEN req_price_tol_cursor(l_line_location_id(shipment_line));

            FETCH req_price_tol_cursor BULK COLLECT INTO
                    l_req_line_unit_price,
                    l_req_unit_of_measure,
                    l_po_req_line_num,
                    l_po_req_ship_num;

            CLOSE req_price_tol_cursor;

l_progress := '006';
            FOR req_line IN 1..l_req_line_unit_price.COUNT LOOP

          /*
           ** If a row was returned then the PO or Release is associated
           ** with a requisition and you should continue with the logic.
           ** If a row was not returned.  It does not mean that an error
           ** occurred, it meas that the submission check does not apply
           ** to this document.
           */

                --Call function that returns the shipment price
                --converted to the correct UOM.
                po_uom_s.po_uom_conversion(
                    l_ship_unit_of_measure(shipment_line),
                    l_req_unit_of_measure(req_line),
                    l_item_id(shipment_line),
                    l_shipment_to_req_rate);

                IF l_shipment_to_req_rate = 0.0 THEN
                    l_shipment_to_req_rate :=1.0;
                END IF;
l_progress := '007';
                --Get the tolerance allowed.  This is the tolerance
                --allowed between the requisition price and
                --shipment price.
                -- bug 432746.
                SELECT NVL(MSI.price_tolerance_percent/100,
                           NVL(POSP.price_change_allowance/100,-1))
                INTO   l_price_tolerance_allowed
                FROM   MTL_SYSTEM_ITEMS MSI,
                       PO_SYSTEM_PARAMETERS POSP,
                       FINANCIALS_SYSTEM_PARAMETERS FSP
                WHERE  msi.inventory_item_id(+) = l_item_id(shipment_line)
                AND  MSI.organization_id(+) = FSP.inventory_organization_id;

l_progress := '008';
                IF l_price_tolerance_allowed <> -1 AND
                    l_req_line_unit_price(req_line) <> 0 THEN

                   /*
                   **  Check to see if the rate returned from the function
                   **  multiplied by the shipment price in base currency and
                   **  then divided by the requisition price is less then
                   **  the tolerance.  If not, call the function to
                   **  insert into the Online Report Text Table.
                   **
                   ** The following formula will cost precision erro when the
                   ** increase equals to the tolerance.
                   ** Patched as part of bug 432746.
                   **
                   **if ((((ship_price_in_base_curr * rate) /
                   **   req_line_unit_price[i]) -1) <= tolerance)
                   */

                   /* Bug 638073
                      the formula for tolerance check should be
                      ship_price_in_base_curr/ req_line_unit_pric e[i] *rate
                      since rate is the conversion from shipment uom to req uom
                    */

                   /*    svaidyan 09/10/98   726568  Modified the price tolerance
                      to check against tolerance + 1.000001. This is because,
                      the reqs sourced to a blanket store the unit price rounded
                      to 5 decimal places and hence we compare only upto the 5th
                      decimal place.
                    */
                   IF (((l_ship_price_ext_precn) /
                        (l_req_line_unit_price(req_line) *
                            l_shipment_to_req_rate ))
                                  > (l_price_tolerance_allowed + 1.000001))
                   THEN
l_progress := '009';
                      --Report the price tolerance error
                      l_textline := FND_MESSAGE.GET_STRING('PO',
                                          'PO_SUB_REQ_PRICE_TOL_EXCEED');
                      get_req_info_from_po_shipment(
                        l_line_location_id(shipment_line),
                        l_req_num, l_req_line_num);
                      FND_FILE.put_line(FND_FILE.LOG,
                            substr(g_reqmsg||g_delim||
                                l_req_num||g_delim||g_linemsg||g_delim||
                                l_req_line_num||g_delim||
                                l_textline,1,240));
                      x_check_status := FND_API.G_RET_STS_ERROR;

                   END IF; --check for tolerance

                 END IF; --check l_price_tolerance_allowed

             END LOOP; --req line

        END IF; --price tolerance check

l_progress := '010';

        --Do price 'not to exceed' amount check
        IF l_enforce_price_amount = 'Y' THEN
IF g_fnd_debug = 'Y' THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'||l_api_name||'.'
          || l_progress,'Doing Not to exceed amt check');
   END IF;
END IF;

            OPEN req_price_amt_cursor(l_line_location_id(shipment_line));

            FETCH req_price_amt_cursor BULK COLLECT INTO
                    l_req_line_unit_price,
                    l_req_unit_of_measure,
                    l_po_req_quantity,
                    l_po_req_line_num,
                    l_po_req_ship_num;

            CLOSE req_price_amt_cursor;

l_progress := '011';
            FOR req_line IN 1..l_req_line_unit_price.COUNT LOOP

          /*
           ** If a row was returned then the PO or Release is associated
           ** with a requisition and you should continue with the logic.
           ** If a row was not returned.  It does not mean that an error
           ** occurred, it meas that the submission check does not apply
           ** to this document.
           */

                --Call function that returns the shipment price
                --converted to the correct UOM.
                po_uom_s.po_uom_conversion(
                    l_ship_unit_of_measure(shipment_line),
                    l_req_unit_of_measure(req_line),
                    l_item_id(shipment_line),
                    l_shipment_to_req_rate);

                IF l_shipment_to_req_rate = 0.0 THEN
                    l_shipment_to_req_rate :=1.0;
                END IF;


                IF l_amount_tolerance >= 0 AND
                    l_req_line_unit_price(req_line) <> 0 THEN

                   --do the amount check
                   --makes sure the requisition amount and
                   --PO amount for each shipment line is within the value
                   --defined in the column PRICE_CHANGE_AMOUNT of table
                   --PO_SYSTEM_PARAMETERS.
                   IF ((l_ship_price_ext_precn -
                      (l_req_line_unit_price(req_line) *
                          l_shipment_to_req_rate))
                             * l_po_req_quantity(req_line)
                                           > l_amount_tolerance)
                   THEN
l_progress := '012';
                      --Report the price amount exceeded error
                      l_textline :=
                   FND_MESSAGE.GET_STRING('PO', 'PO_SUB_REQ_AMT_TOL_EXCEED');
                      get_req_info_from_po_shipment(
                        l_line_location_id(shipment_line),
                        l_req_num, l_req_line_num);
                      FND_FILE.put_line(FND_FILE.LOG,
                            substr(g_reqmsg||g_delim||
                                l_req_num||g_delim||g_linemsg||g_delim||
                                l_req_line_num||g_delim||
                                l_textline,1,240));
                      x_check_status := FND_API.G_RET_STS_ERROR;

                   END IF; --amount check

                 END IF; --check l_amount_tolerance_allowed

             END LOOP; --req line

        END IF; --not to exceed amount check

   END LOOP;  --for shipment_line

EXCEPTION
    WHEN OTHERS THEN
        FND_FILE.put_line(FND_FILE.LOG,
                  c_log_head || l_api_name || ' exception; location: '
                  || l_progress || ' SQL code: ' || sqlcode);
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
          FND_LOG.string(FND_LOG.level_unexpected, c_log_head ||
               l_api_name || '.others_exception', 'EXCEPTION: Location is '
               || l_progress || ' SQL CODE is '||sqlcode);
        END IF;
        raise_application_error(-20001,sqlerrm||'---'||msgbuf);
END CHECK_REL_REQPRICE;

/**
* Private Procedure: preapproval_checks
* Modifies: Writes error messages to the concurrent program log.
* Effects: Performs checks that must be successful for an approved release
*   to be created.
* Returns:
*  x_check_status: FND_API.G_RET_STS_SUCCESS if release passes all
*                    pre-approval checks
*                  FND_API.G_RET_STS_ERROR if at least one check fails
**/
PROCEDURE preapproval_checks( p_po_header_id IN NUMBER,
                              p_req_num IN VARCHAR2,
                              p_req_line_num IN NUMBER,
                              x_check_status OUT NOCOPY VARCHAR2)
IS
  l_api_name       CONSTANT varchar2(30) := 'PREAPPROVAL_CHECKS';

  TYPE ErrorMessagesTab is TABLE of PO_ONLINE_REPORT_TEXT.text_line%TYPE
    INDEX by BINARY_INTEGER;
  l_error_messages ErrorMessagesTab;
  l_textline       PO_ONLINE_REPORT_TEXT.text_line%TYPE;

  TYPE NumTab is TABLE of NUMBER INDEX by BINARY_INTEGER;
  l_line_location_id NumTab;
  l_dist_id        NumTab;

  l_req_num        PO_REQUISITION_HEADERS.segment1%TYPE;
  L_req_line_num   NUMBER;

  l_check_status   VARCHAR2(1);
  l_progress       VARCHAR2(3) := '001';

  -- <JFMIP Vendor Registration FPJ Start>
  -- If the profile option 'Enable Transaction Code' is set to Yes, then
  -- it is a federal instance, and we need to check vendor site registration
  -- status when necessary
  l_federal_instance   VARCHAR2(1);
  l_vendor_id          PO_HEADERS.vendor_id%TYPE;
  l_vendor_site_id     PO_HEADERS.vendor_site_id%TYPE;
  l_valid_registration BOOLEAN := FALSE;
  -- <JFMIP Vendor Registration FPJ End>
  l_sob_id             FINANCIALS_SYSTEM_PARAMS_ALL.set_of_books_id%TYPE;
  l_purch_enc_flag     FINANCIALS_SYSTEM_PARAMS_ALL.purch_encumbrance_flag%TYPE;
BEGIN

    x_check_status := FND_API.G_RET_STS_SUCCESS;
    --<R12 SLA START>
    l_federal_instance  :=  PO_CORE_S.Check_Federal_Instance(
                         PO_MOAC_UTILS_PVT.Get_Current_Org_Id);
    --<R12 SLA END>
    IF g_fnd_debug = 'Y' THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'||l_api_name||'.'
          || l_progress,'Perform pre-approval checks on the release');
       END IF;
    END IF;

    -- First check the document level amount limits.
    check_amount_limits(p_po_header_id, p_req_num, p_req_line_num,l_check_status);
    IF (l_check_status = FND_API.G_RET_STS_ERROR) THEN
      x_check_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- The following checks were adapted from the Document Submission
    -- Checks API (PO_DOCUMENT_CHECKS_PVT.check_releases):

----------------------------------------------

l_progress := '012';
IF g_fnd_debug = 'Y' THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'||l_api_name||'.'
          || l_progress,'REL 12: Amount released check for min release amt');
   END IF;
END IF;

    -- Check 12: The Amount being released for all shipments for a particular line
    -- must be greater than the min release amount specified in agreement line
    -- PO_SUB_REL_SHIPAMT_LESS_MINREL

    l_textline := FND_MESSAGE.GET_STRING('PO','PO_SUB_REL_SHIPAMT_LESS_MINREL');
    --Bug 12553671 Start
	/*SELECT substr(g_reqmsg||g_delim||p_req_num||g_delim||
                  g_linemsg||g_delim||p_req_line_num||
                  g_delim||l_textline||g_delim||POL.min_release_amount,1,240)*/
    SELECT substr(g_bpamsg||g_delim||POH.segment1||g_delim||
                  g_linemsg||g_delim||POL.line_num||
                  g_delim||l_textline||g_delim||POL.min_release_amount,1,240)
	--Bug 12553671 end
    BULK COLLECT INTO l_error_messages
    FROM  PO_HEADERS POH, PO_LINES POL,PO_RELEASES POR,PO_LINE_LOCATIONS PLL----Bug 12553671, Added table _PO_HEADERS
    WHERE  POH.po_header_id = POL.po_header_id  ----Bug 12553671. Added join condition
	AND    PLL.po_release_id = POR.po_release_id
    AND    PLL.po_release_id = x_po_release_id
    AND    POL.po_line_id  = PLL.po_line_id
    AND    POL.min_release_amount is not null
    AND    POL.min_release_amount >
	       --Bug 10403684 start. Sync the following portion code with the submition check in PO_DOCUMENT_CHECKS_PVT.check_releases()
	( SELECT decode ( sum ( decode ( PLL2.quantity                   /*Bug 5028960 pol.quantity */
                                 , NULL , PLL2.amount - nvl(PLL2.amount_cancelled,0)
                                 , PLL2.quantity - nvl(PLL2.quantity_cancelled,0)
                                )
                        )
                  , 0 , POL.min_release_amount
                  , sum ( decode ( PLL2.quantity     /*Bug 5028960  pol.quantity */
                                 , NULL , PLL2.amount - nvl(PLL2.amount_cancelled,0)
                                 , (  ( PLL2.quantity - nvl(PLL2.quantity_cancelled,0) )
                                     *  PLL2.price_override
									)
                                  )
                        )
                   )
	  FROM PO_LINE_LOCATIONS PLL2
    WHERE PLL2.po_line_id = POL.po_line_id
    AND PLL2.po_release_id = POR.po_release_id
    AND PLL2.shipment_type in ('BLANKET', 'SCHEDULED')
	)
	--Bug 10403684 end
       /*(SELECT
            decode(sum(nvl(PLL2.quantity,0)-nvl(PLL2.quantity_cancelled,0)),
                   0,POL.min_release_amount,
                   sum((nvl(PLL2.quantity,0)-nvl(PLL2.quantity_cancelled,0))
                       *PLL2.price_override))
        FROM PO_LINE_LOCATIONS PLL2
        WHERE PLL2.po_line_id = POL.po_line_id
        AND PLL2.po_release_id = POR.po_release_id
        AND PLL2.shipment_type in ('BLANKET', 'SCHEDULED'))*/
    GROUP BY POH.segment1,POL.line_num,POL.min_release_amount;

    FOR i IN 1..l_error_messages.COUNT LOOP
      FND_FILE.put_line(FND_FILE.LOG, l_error_messages(i));
    END LOOP;
    IF l_error_messages.COUNT > 0 THEN
      x_check_status := FND_API.G_RET_STS_ERROR;
    END IF;

----------------------------------------------

l_progress := '013';
IF g_fnd_debug = 'Y' THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'||l_api_name||'.'
          || l_progress,'REL 13: GL date check ');
   END IF;
END IF;

    -- Check 13: The Release GL date should be within an open purchasing period
    -- PO_SUB_REL_INVALID_GL_DATE

    -- bug 4963886
    -- The query had the check for purchasing encumbrance. Moved it
    -- out into an if block so the query is only conditionally executed
    -- Also removed the need for fsp by introducing the bind variable
    -- for set_of_books_id

    SELECT NVL(purch_encumbrance_flag,'N'), set_of_books_id
      INTO l_purch_enc_flag, l_sob_id
    FROM FINANCIALS_SYSTEM_PARAMETERS;

    IF l_purch_enc_flag = 'Y'  THEN

      -- bug 3296181
      -- Changed the message name.
      l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_PDOI_INVALID_GL_ENC_PER');
      SELECT substr(l_textline,1,240),
             POD.po_distribution_id
      BULK COLLECT INTO l_error_messages, l_dist_id
      FROM PO_DISTRIBUTIONS POD, PO_LINE_LOCATIONS PLL, PO_LINES POL
      WHERE POD.line_location_id = PLL.line_location_id
      AND    PLL.po_release_id = x_po_release_id
      AND    POL.po_line_id = PLL.po_line_id
      AND    nvl(POD.encumbered_flag,'N') = 'N'
      AND nvl(PLL.cancel_flag,'N') = 'N'
      AND nvl(PLL.closed_code,'OPEN') <> 'FINALLY CLOSED'
      AND    not exists
         (SELECT 'find if the GL date is not within Open period'
          from   GL_PERIOD_STATUSES PS1, GL_PERIOD_STATUSES PS2,
                 GL_SETS_OF_BOOKS GSOB
          WHERE  PS1.application_id  = 101
          AND    PS1.set_of_books_id = l_sob_id
          AND    PS1.closing_status IN ('O','F')
          AND    trunc(nvl(POD.GL_ENCUMBERED_DATE,PS1.start_date))
              BETWEEN trunc(PS1.start_date) AND trunc(PS1.end_date)
          AND    PS1.period_year <= GSOB.latest_encumbrance_year
          AND    PS1.period_name     = PS2.period_name
          AND    PS2.application_id  = 201
          AND    PS2.closing_status  = 'O'
          AND    PS2.set_of_books_id = l_sob_id
          AND GSOB.set_of_books_id = l_sob_id);

      FOR i IN 1..l_error_messages.COUNT LOOP
        get_req_info_from_po_dist(l_dist_id(i),
          l_req_num, l_req_line_num);
        FND_FILE.put_line(FND_FILE.LOG,
                          g_reqmsg||g_delim||l_req_num||g_delim||
                          g_linemsg||g_delim||l_req_line_num||g_delim||
                          l_error_messages(i));
      END LOOP;
      IF l_error_messages.COUNT > 0 THEN
        x_check_status := FND_API.G_RET_STS_ERROR;
      END IF;

    END IF; -- l_purch_enc_flag check

----------------------------------------------

l_progress := '014';
IF g_fnd_debug = 'Y' THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'||l_api_name||'.'
          || l_progress,'Rel 14: UOM Interclass conversions check');
   END IF;
END IF;

    -- Check 14: Invalid Interclass conversions between UOMs should not be allowed
    -- PO_SUB_UOM_CLASS_CONVERSION, PO_SUB_REL_INVALID_CLASS_CONV
    -- Message inserted is:
    --'Following Interclass UOM conversion is not defined or
    -- is disabled <UOM1> <UOM2>'
    --   Bug #1630662
    l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_UOM_CLASS_CONVERSION');
    SELECT  substr(l_textline||g_delim||
                   MTL1.uom_class||' , '||MTL2.uom_class,1,240),
            POLL.line_location_id
    BULK COLLECT INTO l_error_messages, l_line_location_id
    FROM MTL_UOM_CLASS_CONVERSIONS MOU, PO_LINE_LOCATIONS POLL,
         PO_LINES POL, MTL_UOM_CLASSES_TL MTL1,
         MTL_UOM_CLASSES_TL MTL2
    WHERE MOU.inventory_item_id = POL.item_id
    AND   (NVL(MOU.disable_date, TRUNC(SYSDATE)) + 1) < TRUNC(SYSDATE)
    AND   POL.po_line_id = POLL.po_line_id
    AND   POLL.po_release_id = x_po_release_id
    AND   MOU.from_uom_class = MTL1.uom_class
    AND   MOU.to_uom_class = MTL2.uom_class
    AND EXISTS
       (SELECT 'uom conversion exists'
        FROM MTL_UNITS_OF_MEASURE MUM
        WHERE POL.unit_meas_lookup_code = MUM.unit_of_measure
        AND   MOU.to_uom_class = MUM.uom_class);

    FOR i IN 1..l_error_messages.COUNT LOOP
      get_req_info_from_po_shipment(l_line_location_id(i),
        l_req_num, l_req_line_num);
      FND_FILE.put_line(FND_FILE.LOG,
                        g_reqmsg||g_delim||l_req_num||g_delim||
                        g_linemsg||g_delim||l_req_line_num||g_delim||
                        l_error_messages(i));
      FND_FILE.put_line(FND_FILE.LOG, l_error_messages(i));
    END LOOP;
    IF l_error_messages.COUNT > 0 THEN
      x_check_status := FND_API.G_RET_STS_ERROR;
    END IF;

--------------------------------------------------

l_progress := '015';
IF g_fnd_debug = 'Y' THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'||l_api_name||'.'
          || l_progress,'REL 15: Item restricted check ');
   END IF;
END IF;

    -- Check 15:  If an item is restricted then the Purchase Order Vendor
    -- must be listed in the Approved Suppliers List table and must be approved.
    -- PO_SUB_ITEM_NOT_APPROVED_REL
    -- Bug# 2461828
    l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_ITEM_NOT_APPROVED_REL');
    SELECT substr(g_reqmsg||g_delim||p_req_num||g_delim||
                  g_linemsg||g_delim||p_req_line_num||
                  g_delim||l_textline,1,240)
    BULK COLLECT INTO l_error_messages
    FROM MTL_SYSTEM_ITEMS MSI, PO_LINE_LOCATIONS PLL,
         PO_RELEASES POR,PO_LINES POL, PO_HEADERS POH,
         FINANCIALS_SYSTEM_PARAMETERS FSP
    WHERE POR.po_release_id = x_po_release_id
    AND POR.po_header_id = POH.po_header_id
    AND POR.po_header_id = POL.po_header_id
    AND POL.po_line_id = PLL.po_line_id
    AND POR.po_release_id = PLL.po_release_id
    AND MSI.organization_id = PLL.SHIP_TO_ORGANIZATION_id
    AND MSI.inventory_item_id = POL.item_id
    AND POL.item_id is not null
    AND nvl(PLL.closed_code,'OPEN') <> 'FINALLY CLOSED'
    AND nvl(POL.cancel_flag,'N') = 'N'
    AND nvl(PLL.cancel_flag,'N') = 'N'
    AND nvl(MSI.must_use_approved_vendor_flag,'N') = 'Y'
    AND not exists
       (SELECT sum(decode(ASR.allow_action_flag, 'Y', 1, -100))
        FROM PO_APPROVED_SUPPLIER_LIS_VAL_V ASL, PO_ASL_STATUS_RULES ASR
        WHERE  ASL.using_organization_id in (PLL.ship_to_organization_id, -1)
        AND    ASL.vendor_id = POH.vendor_id
        AND    nvl(ASL.vendor_site_id, POH.vendor_site_id) = POH.vendor_site_id
        AND   ASL.item_id = POL.item_id
        AND    ASL.asl_status_id = ASR.status_id
        AND    ASR.business_rule = '1_PO_APPROVAL'
        HAVING sum(decode(ASR.allow_action_flag, 'Y', 1, -100)) > 0
        UNION ALL
        SELECT sum(decode(ASR.allow_action_flag, 'Y', 1, -100))
        FROM PO_APPROVED_SUPPLIER_LIS_VAL_V ASL, PO_ASL_STATUS_RULES ASR
        WHERE  ASL.using_organization_id in (PLL.ship_to_organization_id , -1)
        AND    ASL.vendor_id = POH.vendor_id
        AND    nvl(ASL.vendor_site_id, POH.vendor_site_id) = POH.vendor_site_id
        AND    ASL.item_id is NULL
        AND    not exists
           (SELECT ASL1.ASL_ID
            FROM PO_APPROVED_SUPPLIER_LIS_VAL_V ASL1
            WHERE ASL1.ITEM_ID = POL.item_id
            AND ASL1.using_organization_id in (PLL.ship_to_organization_id, -1))
        AND    ASL.category_id in
           (SELECT MIC.category_id
            FROM   MTL_ITEM_CATEGORIES MIC
            WHERE MIC.inventory_item_id = POL.item_id
            AND MIC.organization_id = PLL.ship_to_organization_id)
        AND    ASL.asl_status_id = ASR.status_id
        AND    ASR.business_rule = '1_PO_APPROVAL'
        HAVING sum(decode(ASR.allow_action_flag, 'Y', 1, -100)) > 0);

    FOR i IN 1..l_error_messages.COUNT LOOP
      FND_FILE.put_line(FND_FILE.LOG, l_error_messages(i));
    END LOOP;
    IF l_error_messages.COUNT > 0 THEN
      x_check_status := FND_API.G_RET_STS_ERROR;
    END IF;

---------------------------------------------

l_progress := '016';
IF g_fnd_debug = 'Y' THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
     FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'||l_api_name||'.'
          || l_progress,'REL 16: ASL Debarred check ');
   END IF;
END IF;

    -- Check 16: Determine if an item is restricted.  If it is restricted the
    -- Purchase Order Vendor must be listed in the Approved Suppliers
    -- List table and must be approved for release to get approved.
    -- Bug 839743
    -- PO_SUB_ITEM_ASL_DEBARRED_REL

    l_textline := FND_MESSAGE.GET_STRING('PO', 'PO_SUB_ITEM_ASL_DEBARRED_REL');
    SELECT substr(g_reqmsg||g_delim||p_req_num||g_delim||
                  g_linemsg||g_delim||p_req_line_num||
                  g_delim||l_textline,1,240)
    BULK COLLECT INTO l_error_messages
    FROM MTL_SYSTEM_ITEMS MSI, PO_LINE_LOCATIONS PLL,
         PO_RELEASES POR,PO_LINES POL, PO_HEADERS POH,
         FINANCIALS_SYSTEM_PARAMETERS FSP
    WHERE POR.po_release_id = x_po_release_id
    AND POR.po_header_id = POH.po_header_id
    AND POR.po_header_id = POL.po_header_id
    AND POL.po_line_id = PLL.po_line_id
    AND POR.po_release_id = PLL.po_release_id
    AND MSI.organization_id = PLL.ship_to_organization_id
    AND MSI.inventory_item_id = POL.item_id
    AND POL.item_id is not null
    AND nvl(PLL.closed_code,'OPEN') <> 'FINALLY CLOSED'
    AND nvl(POL.cancel_flag,'N') = 'N'
    AND nvl(PLL.cancel_flag,'N') = 'N'
    AND nvl(MSI.must_use_approved_vendor_flag,'N') = 'Y'
    AND exists
       (SELECT sum(decode(ASR.allow_action_flag, 'Y', 1, -100))
        FROM PO_APPROVED_SUPPLIER_LIS_VAL_V ASL, PO_ASL_STATUS_RULES ASR
        WHERE  ASL.using_organization_id in (PLL.ship_to_organization_id, -1)
        AND    ASL.vendor_id = POH.vendor_id
        AND    nvl(ASL.vendor_site_id, POH.vendor_site_id) = POH.vendor_site_id
        AND   ASL.item_id = POL.item_id
        AND    ASL.asl_status_id = ASR.status_id
        AND    ASR.business_rule = '1_PO_APPROVAL'
        HAVING sum(decode(ASR.allow_action_flag, 'Y', 1, -100)) < 0
        UNION ALL
        SELECT sum(decode(ASR.allow_action_flag, 'Y', 1, -100))
        FROM PO_APPROVED_SUPPLIER_LIS_VAL_V ASL, PO_ASL_STATUS_RULES ASR
        WHERE  ASL.using_organization_id in (PLL.ship_to_organization_id , -1)
        AND    ASL.vendor_id = POH.vendor_id
        AND    nvl(ASL.vendor_site_id, POH.vendor_site_id) = POH.vendor_site_id
        AND    ASL.item_id is NULL
        AND    ASL.category_id in
           (SELECT MIC.category_id
            FROM   MTL_ITEM_CATEGORIES MIC
            WHERE MIC.inventory_item_id = POL.item_id
            AND MIC.organization_id = PLL.ship_to_organization_id)
        AND    ASL.asl_status_id = ASR.status_id
      AND    ASR.business_rule = '1_PO_APPROVAL'
      HAVING sum(decode(ASR.allow_action_flag, 'Y', 1, -100)) < 0);

    FOR i IN 1..l_error_messages.COUNT LOOP
      FND_FILE.put_line(FND_FILE.LOG, l_error_messages(i));
    END LOOP;
    IF l_error_messages.COUNT > 0 THEN
      x_check_status := FND_API.G_RET_STS_ERROR;
    END IF;

---------------------------------------------------------

    -- Check that the release shipment price is within the tolerance
    -- of the requisition line.
    check_rel_reqprice(l_check_status);
    IF (l_check_status = FND_API.G_RET_STS_ERROR) THEN
      x_check_status := FND_API.G_RET_STS_ERROR;
    END IF;

----------------------------------------------------------
    --<JFMIP Vendor Registration FPJ Start>
    -- Check if vendor site has a valid Central Contractor Registration(CCR)
    l_progress := '017';

    IF g_fnd_debug = 'Y' THEN
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'||l_api_name
               ||'.'|| l_progress,'Vendor site registration check ');
       END IF;
    END IF;

    -- No need to check vendor site registration if it's not a federal instance
    IF l_federal_instance = 'Y' THEN

       -- SQL What: retrieves vendor and vendor site id from blanket header
       -- SQL Why:  need to check vendor site registration status below
       BEGIN
         SELECT vendor_id, vendor_site_id
         INTO   l_vendor_id, l_vendor_site_id
         FROM   po_headers_all
         WHERE  po_header_id = p_po_header_id;
       EXCEPTION
         WHEN OTHERS THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END;

       -- Call PO_FV_INTEGRATION_PVT.val_vendor_site_ccr_regis to check the
       -- Central Contractor Registration (CCR) status of the vendor site
       IF (l_vendor_id IS NOT NULL) AND (l_vendor_site_id IS NOT NULL) THEN
          l_valid_registration := PO_FV_INTEGRATION_PVT.val_vendor_site_ccr_regis(
                        p_vendor_id      => l_vendor_id,
                        p_vendor_site_id => l_vendor_site_id);

          IF NOT l_valid_registration THEN
             l_textline := FND_MESSAGE.get_string('PO', 'PO_VENDOR_SITE_CCR_INVALID');
             FND_FILE.put_line(FND_FILE.LOG, substr(g_reqmsg||g_delim
                            ||p_req_num||g_delim||g_linemsg||g_delim
                            ||p_req_line_num||g_delim||l_textline,1,240));
             x_check_status := FND_API.G_RET_STS_ERROR;
          END IF; -- l_valid_registration check
       END IF; -- l_vendor_id and l_vendor_site_id check
    END IF; -- l_federal_instance check
    --<JFMIP Vendor Registration FPJ End>

    --<BUG 7685164 Added following submission checks as part of LCM ER>
    l_progress := '018';
    IF g_fnd_debug = 'Y' THEN
    	IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'||l_api_name||'.'
          	|| l_progress,'LCM enabled release shipment should have invoice match option as receipt');
	END IF;
    END IF;
    l_textline := FND_MESSAGE.GET_STRING('PO','PO_SUB_REL_SHIP_INV_MATCH_NE_R');

    SELECT substr (g_shipmsg||g_delim||PLL.shipment_num||g_delim||l_textline,1,240)
    BULK COLLECT INTO l_error_messages
    FROM PO_RELEASES_ALL POR,
         PO_LINE_LOCATIONS_ALL PLL
   WHERE POR.po_release_id = PLL.po_release_id
     AND POR.po_release_id = x_po_release_id
     AND Nvl(PLL.LCM_FLAG,'N') = 'Y'
     AND Nvl(PLL.match_option,'P') <> 'R';

    FOR i IN 1..l_error_messages.COUNT LOOP
    	FND_FILE.put_line(FND_FILE.LOG, l_error_messages(i));
    END LOOP;
    IF l_error_messages.COUNT > 0 THEN
	x_check_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END IF;

    l_progress := '019';
    IF g_fnd_debug = 'Y' THEN
    	IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        	FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || '.'||l_api_name||'.'
          	|| l_progress,'LCM enabled release distribution should have destination type as Inventory');
  	END IF;
    END IF;

    l_textline := FND_MESSAGE.GET_STRING('PO','PO_SUB_REL_DIST_DEST_TYPE_NE_I');

    SELECT substr (g_shipmsg||g_delim||PLL.shipment_num||g_delim||g_distmsg||g_delim||
                   POD.distribution_num||g_delim||l_textline, 1,240)
      BULK COLLECT INTO l_error_messages
      FROM PO_RELEASES_GT POR,
           PO_LINE_LOCATIONS_GT PLL,
           PO_DISTRIBUTIONS_GT POD
     WHERE POR.po_release_id = POD.po_release_id
       AND POD.line_location_id = PLL.line_location_id
       AND POR.po_release_id = x_po_release_id
       AND Nvl(POD.LCM_FLAG,'N') = 'Y'
       AND POD.DESTINATION_TYPE_CODE <> 'INVENTORY';

    FOR i IN 1..l_error_messages.COUNT LOOP
    	FND_FILE.put_line(FND_FILE.LOG, l_error_messages(i));
    END LOOP;
    IF l_error_messages.COUNT > 0 THEN
    	x_check_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        FND_FILE.put_line(FND_FILE.LOG,
                  c_log_head || l_api_name || ' exception; location: '
                  || l_progress || ' SQL code: ' || sqlcode);
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
          FND_LOG.string(FND_LOG.level_unexpected, c_log_head ||
               l_api_name || '.others_exception', 'EXCEPTION: Location is '
               || l_progress || ' SQL CODE is '||sqlcode);
        END IF;
        raise_application_error(-20001,sqlerrm||'---'||msgbuf);

END PREAPPROVAL_CHECKS;
--- Bug 2701147 END

-- <INBOUND LOGISITCS PFJ START>
-------------------------------------------------------------------------------
--Start of Comments
--Name: create_deliveryrecord
--Pre-reqs:
--  None.
--Modifies:
--  l_fte_rec
--Locks:
--  None.
--Function:
--  Call FTE's API to create delivery record for Approved Blanket Release
--Parameters:
--IN:
--p_release_id
--  Corresponding to po_release_id
--Testing:
--  Pass in po_release_id for an approved release.
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE create_deliveryrecord(p_release_id IN NUMBER)
IS
    l_api_name       CONSTANT varchar2(30) := 'CREATE_DELIVERYRECORD';

    l_return_status  VARCHAR2(1);
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(2000);
    l_msg_buf        VARCHAR2(2000);

    l_progress       VARCHAR2(3) := '001';

BEGIN
    l_return_status  := FND_API.G_RET_STS_SUCCESS;

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string (
            LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
            MODULE    => c_log_head || '.'||l_api_name||'.' || l_progress,
            MESSAGE   => 'Start create delivery record for approved Blanket Release'
        );
        END IF;
    END IF;

    PO_DELREC_PVT.create_update_delrec
    (
        p_api_version        =>    1.0,
        x_return_status      =>    l_return_status,
        x_msg_count          =>    l_msg_count,
        x_msg_data           =>    l_msg_data,
        p_action             =>    'APPROVE',
        p_doc_type           =>    'RELEASE',
        p_doc_subtype        =>    'BLANKET',
        p_doc_id             =>    p_release_id,
        p_line_id            =>    NULL,
        p_line_location_id   =>    NULL
    );

    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
        NULL;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO PORELGEN_1;
        -- Bug 3570793 Write the message list to the concurrent program log.
        PO_DEBUG.write_msg_list_to_file (
          p_log_head => c_log_head || l_api_name,
          p_progress => l_progress
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO PORELGEN_1;
        -- Bug 3570793 Write the message list to the concurrent program log.
        PO_DEBUG.write_msg_list_to_file (
          p_log_head => c_log_head || l_api_name,
          p_progress => l_progress
        );

    WHEN OTHERS THEN
        ROLLBACK TO PORELGEN_1;

        IF FND_MSG_PUB.check_msg_level(
            p_message_level => FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(
                p_pkg_name       => G_PKG_NAME,
                p_procedure_name => l_api_name
                );
        END IF;

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(
                LOG_LEVEL => FND_LOG.level_unexpected,
                MODULE    => c_log_head ||'.'||l_api_name||'.others_exception',
                MESSAGE   => FND_MSG_PUB.get(p_msg_index => FND_MSG_PUB.G_LAST, p_encoded => 'F')
            );
            END IF;
        END IF;

END create_deliveryrecord;
-- <INBOUND LOGISITCS PFJ END>

--<GRANTS FPJ START>

----------------------------------------------------------------------------
--Start of Comments
--Name: create_award_distribution
--Pre-reqs:
--  None
--Modifies:
--  PO_DISTRIBUTIONS
--  GMS_AWARD_DISTRIBUTIONS
--Locks:
--  None
--Function:
--  Calls Grants Accounting API to create new award distributions lines
--  when a requisition with distributions that reference awards is
--  processed into a release through the Create Releases concurent request.
--Parameters:
--  None
--Returns:
--  None
--Testing:
--  None
--End of Comments
----------------------------------------------------------------------------

PROCEDURE create_award_distribution IS

  l_api_name     CONSTANT VARCHAR(30) := 'CREATE_AWARD_DISTRIBUTION';
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(2000);
  l_return_status  VARCHAR2(1);
  l_gms_po_interface_obj gms_po_interface_type;
  l_progress             VARCHAR2(3);
  l_msg_buf              VARCHAR2(2000);

BEGIN

    l_progress := '001';

    --SQL WHAT: Select the columns that Grants needs from the
    --          po_distributions table for this release where
    --          award_id is referenced.
    --SQL WHY : Need to call GMS API to update award distribution
    --          lines table.

    SELECT
      po_distribution_id,
      distribution_num,
      project_id,
      task_id,
      award_id,
      NULL
    BULK COLLECT INTO
      l_gms_po_interface_obj.distribution_id,
      l_gms_po_interface_obj.distribution_num,
      l_gms_po_interface_obj.project_id,
      l_gms_po_interface_obj.task_id,
      l_gms_po_interface_obj.award_set_id_in,
      l_gms_po_interface_obj.award_set_id_out
    FROM PO_DISTRIBUTIONS
    WHERE line_location_id = x_line_location_id AND
          award_id IS NOT NULL;

    IF SQL%NOTFOUND THEN
      RETURN;
    END IF;

    l_progress := '002';

    --Call GMS API to update award distribution lines table

    PO_GMS_INTEGRATION_PVT.maintain_adl (
          p_api_version           => 1.0,
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data,
          p_caller                => 'CREATE_RELEASE',
          x_po_gms_interface_obj  => l_gms_po_interface_obj);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_progress := '003';

    --Update po_distributions table with the new award_id's

    FORALL i IN 1..l_gms_po_interface_obj.distribution_id.COUNT
        UPDATE po_distributions
        SET award_id = l_gms_po_interface_obj.award_set_id_out(i)
        WHERE po_distribution_id = l_gms_po_interface_obj.distribution_id(i);

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    -- Bug 3570793 Write the message list to the concurrent program log.
    PO_DEBUG.write_msg_list_to_file (
      p_log_head => c_log_head || l_api_name,
      p_progress => l_progress
    );

    RAISE;

  WHEN OTHERS THEN

    FND_FILE.put_line(FND_FILE.LOG,
                      c_log_head || l_api_name || ' exception; location: '
                       || l_progress || ' SQL code: ' || sqlcode);

    IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(
        LOG_LEVEL => FND_LOG.level_unexpected,
        MODULE    => c_log_head||l_api_name||'.error_exception',
        MESSAGE   => 'EXCEPTION ' || l_progress || ': SQL CODE is '||sqlcode
      );
      END IF;
    END IF;

    RAISE;

END create_award_distribution;

--<GRANTS FPJ END>

/*bug12602301 starts:  Performance issue.
 	 in order to determine the one particular entry from
 	 the asl table the earlier cursor had many queries within itself
 	 i.e subqueries. As a part of the fix all the conditions of the subqueries have been
 	 incorporated in a single sql.This sql is in the function get_asl_id which retruns the asl_id
 	 The precedence for picking up an asl entry is
 	 1. Item level asl.
 	 2. Category ASl
 	 For each of the above
 	 Local ASL will be preferred over global asl
 	 Valid Vendor site will be preferred than vendor_site being null
 	   */
 	 FUNCTION get_asl_id( p_item_id IN po_requisition_lines_all.item_id%TYPE,
 	                      p_category_id IN po_requisition_lines_all.category_id%TYPE,
 	                      p_destination_organization_id      IN po_requisition_lines_all.destination_organization_id%TYPE,
 	                      p_vendor_id IN po_headers_all.vendor_id%TYPE,
 	                                                                                  p_vendor_site_id IN po_headers_all.vendor_site_id%TYPE )
 	 return number
 	 as

 	 l_progress VARCHAR2(3) := '000';
 	 l_api_name CONSTANT VARCHAR2(30) := 'get_asl_id';

 	 l_aslid NUMBER;
 	 begin

 	   IF g_debug_stmt THEN    --< Bug 3210331: use proper debugging >
 	         PO_DEBUG.debug_begin(p_log_head => c_log_head||l_api_name);
 	     END IF;

 	      l_progress := '010';
 	      IF g_debug_stmt THEN    --< Bug 3210331: use proper debugging >
 	         PO_DEBUG.debug_stmt(p_log_head => c_log_head||l_api_name,
 	                             p_token    => l_progress,
 	                             p_message  => 'Get_asl_id : item_id : '||p_item_id||
 	                                           'category_id : '||p_category_id||
 	                                           'destination_organization_id : '||p_destination_organization_id||
 	                                           'vendor_id : '||p_vendor_id||
 	                                           'vendor_site_id : '||p_vendor_site_id);
 	     END IF;

 	      l_progress := '020';

 	  SELECT asl_id
 	  INTO   l_aslid
 	  FROM   (SELECT asl_id
 	          FROM   (SELECT paa2.asl_id,Nvl(paa2.item_id, -1)        item_id,
 	                         Nvl(paa2.category_id, -1)    category_id,
 	                         Decode(item_id, NULL, '2-CATEGORY',
 	                                                       '1-ITEM')    item_cat,
 	                         paa2.using_organization_id,
 	                         paa2.vendor_id,
 	                         Nvl(paa2.vendor_site_id, -1) vendor_site_id
 	                  FROM   po_asl_attributes_val_v paa2
 	                  WHERE  p_item_id IS NOT NULL
 	                         AND paa2.item_id = p_item_id
 	                         AND paa2.vendor_id = p_vendor_id
 	                         AND paa2.using_organization_id IN
 	                             ( -1, p_destination_organization_id
 	                             )
 	                         AND Nvl(paa2.vendor_site_id, -1) =
 	                             Nvl(p_vendor_site_id, -1)
 	                         and paa2.release_generation_method in ('CREATE','CREATE_AND_APPROVE')
 	                  UNION
 	                  SELECT paa3.asl_id,Nvl(paa3.item_id, -1)        item_id,
 	                         Nvl(paa3.category_id, -1)    category_id,
 	                                   Decode(item_id, NULL, '2-CATEGORY',
 	                                             '1-ITEM')    item_cat,
 	                         paa3.using_organization_id,
 	                         paa3.vendor_id               vendor_id,
 	                         Nvl(paa3.vendor_site_id, -1) vendor_site_id
 	                  FROM   po_asl_attributes_val_v paa3
 	                  WHERE  p_item_id IS NULL
 	                         AND paa3.category_id = p_category_id
 	                         AND paa3.vendor_id = p_vendor_id
 	                         AND paa3.using_organization_id IN
 	                             ( -1, p_destination_organization_id
 	                             )
 	                         AND Nvl(paa3.vendor_site_id, -1) =
 	                             Nvl(p_vendor_site_id, -1)
 	                         and paa3.release_generation_method in ('CREATE','CREATE_AND_APPROVE')    )
 	          ORDER  BY ITEM_CAT ASC,Nvl(item_id, -1),
 	                                     Nvl(category_id, -1),
 	                                     using_organization_id DESC,
 	                                     Nvl(vendor_site_id, -1))
 	  WHERE  rownum < 2   ;

 	  l_progress := '030';
 	  IF g_debug_stmt THEN    --< Bug 3210331: use proper debugging >
 	         PO_DEBUG.debug_stmt(p_log_head => c_log_head||l_api_name,
 	                             p_token    => l_progress,
 	                             p_message  => 'Get_asl_id : l_aslid : '||l_aslid);
 	     END IF;


 	  return l_aslid;


 	  EXCEPTION WHEN NO_DATA_FOUND THEN
 	   l_aslid := -1;
 	   l_progress := '040';
 	   IF g_debug_stmt THEN    --< Bug 3210331: use proper debugging >
 	         PO_DEBUG.debug_stmt(p_log_head => c_log_head||l_api_name,
 	                             p_token    => l_progress,
 	                             p_message  => 'Get_asl_id in exception block : l_aslid : '||l_aslid);
 	    END IF;
 	   RETURN l_aslid;

 	 end;
 	 /*bug 12602301 ends*/

END PO_RELGEN_PKG;

/
