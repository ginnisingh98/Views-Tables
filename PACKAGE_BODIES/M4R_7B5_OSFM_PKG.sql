--------------------------------------------------------
--  DDL for Package Body M4R_7B5_OSFM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."M4R_7B5_OSFM_PKG" AS
   /* $Header: M4R7B5OB.pls 120.6 2006/09/19 12:34:27 bsaratna noship $ */

   g_debug_level             NUMBER;
   g_exception_tracking_msg  VARCHAR2(200);

   --  Package
   --      M4R_7B5_OSFM_PKG
   --
   --  Purpose
   --      This package is called from the 7B5 OSFM WF 'M4R 7B5 OSFM Outbound'.
   --

   -- Procedure
   --    SET_WF_ATTRIBUTES

   -- Purpose
   --    This is called from the Workflow 'M4R 7B5 OSFM Outbound'.
   --    It checks whether the approved PO has any Outside Processing Items.If found,
   --    sets the WF Item Attributes.

   -- Arguments

   -- Notes
   --       None

PROCEDURE SET_WF_ATTRIBUTES(p_itemtype               IN              VARCHAR2,
                            p_itemkey                IN              VARCHAR2,
                            p_actid                  IN              NUMBER,
                            p_funcmode               IN              VARCHAR2,
                            x_resultout              IN OUT NOCOPY   VARCHAR2) IS

                            l_po_header_id              NUMBER;
                            l_po_doc_id                 NUMBER;
                            l_po_rev_id                 NUMBER;
                            l_po_rel_id                 NUMBER;
                            l_po_doc_type               VARCHAR2(30);
                            l_po_rev_num                NUMBER;
                            l_po_rel_num                NUMBER;
                            l_po_rel_rev_num            NUMBER;
                            l_osp_item_exists           VARCHAR2(6);
                            l_party_site_id             NUMBER;
                            l_org_id                    NUMBER;
                            l_party_id                  NUMBER;
                            l_party_type                VARCHAR2(30);
                            l_error_code                NUMBER;
                            l_errmsg                    VARCHAR2(2000);
                            l_gen_wf_param              wf_parameter_list_t;

BEGIN

      IF (g_debug_level <= 2) THEN
                cln_debug_pub.Add('ENTERING M4R_7B5_OSFM_PKG.SET_WF_ATTRIBUTES procedure with the following parameters:', 2);
                cln_debug_pub.Add('itemtype:'   || p_itemtype, 2);
                cln_debug_pub.Add('itemkey:'    || p_itemkey, 2);
                cln_debug_pub.Add('actid:'      || p_actid, 2);
                cln_debug_pub.Add('funcmode:'   || p_funcmode, 2);
                cln_debug_pub.Add('resultout:'  || x_resultout, 2);
      END IF;

      l_po_doc_id := wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'DOCUMENT_ID');
      IF (g_debug_level <= 1) THEN
            cln_debug_pub.Add('PO Document ID ' || l_po_doc_id, 1);
      END IF;

      l_po_doc_type  := wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'DOCUMENT_TYPE');
      IF (g_debug_level <= 1) THEN
            cln_debug_pub.Add('PO Document Type ' || l_po_doc_type, 1);
      END IF;

      l_po_rev_num   := wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'PO_REVISION_NUM');
      IF (g_debug_level <= 1) THEN
            cln_debug_pub.Add('PO Document Revision Number ' || l_po_rev_num, 1);
      END IF;

      IF l_po_doc_type = 'RELEASE' THEN         ---- Get the PO Release ID if the PO is a Release

                  l_po_rel_id := l_po_doc_id;
                  l_po_rel_rev_num := l_po_rev_num;

                  g_exception_tracking_msg := 'Query po_releases_all for header_id,release_num';

                  SELECT po_header_id,release_num
                  INTO   l_po_header_id, l_po_rel_num
                      FROM   po_releases_archive_all
                  WHERE  po_release_id = l_po_rel_id
                         AND revision_num = l_po_rel_rev_num;

                  IF (g_debug_level <= 1) THEN
                       cln_debug_pub.Add('PO Header ID '            || l_po_header_id, 1);
                       cln_debug_pub.Add('PO Release ID '           || l_po_rel_id, 1);
                       cln_debug_pub.Add('PO Release Number '       || l_po_rel_num, 1);
                       cln_debug_pub.Add('Release Revision Number ' || l_po_rel_rev_num, 1);
                  END IF;
      ELSE
                  l_po_header_id := l_po_doc_id;

                  IF (g_debug_level <= 1) THEN
                         cln_debug_pub.Add('PO Header ID' || l_po_header_id, 1);
                  END IF;

      END IF;

      --    Check for OSP items depending upon the PO type.

      IF (l_po_doc_type = 'RELEASE' OR l_po_doc_type = 'STANDARD' OR l_po_doc_type = 'PO') THEN

            g_exception_tracking_msg := 'Query po_lines_all into l_osp_item_exists';

            --    Check if there are any OSP items in the PO.
            BEGIN
                   SELECT 'YES'
                   INTO   l_osp_item_exists
                   FROM   po_lines_archive_all
                   WHERE  po_header_id = l_po_header_id
                          AND line_type_id IN
                                             ( SELECT line_type_id
                                               FROM po_line_types
                                               WHERE outside_operation_flag ='Y'
                                             )
                          AND ROWNUM < 2;

            EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                             x_resultout := 'F';

                             IF (g_debug_level <= 5) THEN
                                       cln_debug_pub.Add('x_resultout = ' || x_resultout, 5);
                                       cln_debug_pub.Add('There are NO OSP items in the PO', 5);
                             END IF;
            END;

            IF l_osp_item_exists = 'YES' THEN

                           x_resultout := 'T';
                            -- retrive the other attributes required for workflow

                           g_exception_tracking_msg := 'Query po_headers_all for Vendor ID, Vendor Site ID, Org ID';

                                   IF l_po_doc_type = 'RELEASE' THEN
                                  SELECT  vendor_id,vendor_site_id,org_id,revision_num
                              INTO    l_party_id,l_party_site_id,l_org_id,l_po_rev_num
                              FROM    po_headers_archive_all
                                    WHERE   po_header_id = l_po_header_id
                                   AND latest_external_flag = 'Y';
                           ELSE
                                  SELECT  vendor_id,vendor_site_id,org_id,revision_num
                              INTO    l_party_id,l_party_site_id,l_org_id,l_po_rev_num
                              FROM    po_headers_archive_all
                                    WHERE   po_header_id = l_po_header_id
                                  AND revision_num = l_po_rev_num;
                           END IF;

                           IF (g_debug_level <= 1) THEN
                                 cln_debug_pub.Add('x_resultout = ' || x_resultout, 1);
                                 cln_debug_pub.Add('There are OSP items in the PO, The WF attributes are set as below.', 1);
                                 cln_debug_pub.Add('PARTY ID = ' || l_party_id, 1);
                                 cln_debug_pub.Add('PARTY SITE ID = '|| l_party_site_id , 1);
                                 cln_debug_pub.Add('PO_HEADER_ID = '|| l_po_header_id , 1);
                                 cln_debug_pub.Add('PO_REVISION_NUM = '|| l_po_rev_num , 1);
                                 cln_debug_pub.Add('PO_RELEASE_ID = ' || l_po_rel_id, 1);
                                 cln_debug_pub.Add('PO_RELEASE_NUM = '|| l_po_rel_num , 1);
                                 cln_debug_pub.Add('PO_REL_REV_NUM = '|| l_po_rel_rev_num , 1);
                           END IF;

                          wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'ECX_TRANSACTION_TYPE', 'M4R');
                          wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'ECX_TRANSACTION_SUBTYPE', '7B5_OSFM_WO');
                          wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'ECX_PARTY_ID', l_party_id);
                          wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'ECX_PARTY_SITE_ID', l_party_site_id);
                          wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'ECX_PARTY_TYPE', 'S');
                          wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'ORG_ID', l_org_id);
                          wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PO_RELEASE_ID', l_po_rel_id);
                          wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PO_HEADER_ID', l_po_header_id);
                          wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PO_RELEASE_NUM', l_po_rel_num);
                          wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PO_REVISION_NUM', l_po_rev_num);
                          wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PO_REL_REV_NUM', l_po_rel_rev_num);

                          IF (g_debug_level <= 1) THEN
                                 cln_debug_pub.Add('Workflow Attributes set', 1);
                          END IF;

            END IF; -- l_osp_item_exists = 'YES'

      ELSE
                       x_resultout := 'F';

                       IF (g_debug_level <= 1) THEN
                                  cln_debug_pub.Add('The Document Type is either BLANKET OR PLANNED', 1);
                                  cln_debug_pub.Add('x_resultout = ' || x_resultout, 1);
                       END IF;

      END IF; -- If doc type is Release, PO or Standard

      IF (g_debug_level <= 2) THEN
             cln_debug_pub.Add('Exiting the M4R_7B5_OSFM_PKG.SET_WF_ATTRIBUTES procedure', 2);
      END IF;

EXCEPTION
       WHEN OTHERS THEN
                  l_error_code := SQLCODE;
                  l_errmsg     := SQLERRM;
                  x_resultout := 'ERROR:'||l_error_code||'-'||l_errmsg;

                  IF (g_debug_level <= 5) THEN
                           cln_debug_pub.Add('g_exception_tracking_msg : '|| g_exception_tracking_msg,5);
                           cln_debug_pub.Add('Exception - In SET_WF_ATTRIBUTES API', 5);
                           cln_debug_pub.Add('Error is ' || l_error_code || ':' || l_errmsg, 5);
                  END IF;

END SET_WF_ATTRIBUTES;


   -- Procedure
   --    PROCESS_WO

   -- Purpose
   --    This procedure is called from the Workflow. It checks whether the OSP Work Order
   --    request is New/Cancel/Change and raises the Generic Outbound Workflow.


PROCEDURE PROCESS_WO(p_itemtype               IN              VARCHAR2,
                     p_itemkey                IN              VARCHAR2,
                     p_actid                  IN              NUMBER,
                     p_funcmode               IN              VARCHAR2,
                     x_resultout              IN OUT NOCOPY   VARCHAR2)  IS

                     l_po_header_id                      NUMBER;
                     l_po_rel_id                         NUMBER;
                     l_po_doc_type                       VARCHAR2(30);
                     l_po_rev_num                        NUMBER;
                     l_po_rel_rev_num                    NUMBER;
                     l_po_rev_num_x                      NUMBER;
                     l_po_rel_num                        NUMBER;
                     l_error_code                        NUMBER;
                     l_action_code                       VARCHAR2(4);
                     l_cancel_flag                       VARCHAR2(2);
                     l_doc_id                            NUMBER;
                     l_rout_seq_num                      NUMBER;
                     l_job_num                           VARCHAR2(100);
                     l_doc_num                           VARCHAR2(100);
                     l_wip_entity_id                     NUMBER;
                     l_party_id                          NUMBER;
                     l_party_site_id                     NUMBER;
                     l_org_id                            NUMBER;
                     l_osfm_org_id                       NUMBER;
                     l_line_loc_id                       NUMBER;
                     l_line_loc_rev_num                  NUMBER;
                     l_line_rev_num                      NUMBER;
                     l_dist_quant_ord                    NUMBER;

                     l_creation_date                     VARCHAR2(40);
                     l_rev_date                          VARCHAR2(40);
                     l_party_type                        VARCHAR2(3);
                     l_event_key                         VARCHAR2(100);
                     l_assembly_name                     VARCHAR2(200);
                     l_op_desc                           VARCHAR2(2000);
                     l_errmsg                            VARCHAR2(2000);
                     l_raise_flag                        VARCHAR2(2);
                     l_header_change                     VARCHAR2(2);
                     l_lines_chk                         NUMBER;
                     l_lines_loc_chk                     VARCHAR2(2);
                     l_dist_chk                          VARCHAR2(2);
                     l_all_new_flag                      VARCHAR2(2);
                     l_seq_num                           NUMBER;
                     l_cn_create_date                    VARCHAR2(50);
                     l_cn_rev_date                       VARCHAR2(50);
                     x_rn_datetime                       VARCHAR2(50);
                     l_item                              VARCHAR2(500);
                     l_item_rv                           VARCHAR2(500);
                     l_uom                               VARCHAR2(50);

                     l_all_cancel_flag                   VARCHAR2(2);
                     l_line_cancel                       NUMBER;
                     l_this_line_cancel                  VARCHAR2(2);
                     l_this_line_loc_cancel              VARCHAR2(2);
                     l_this_line_changed                 VARCHAR2(2);
                     l_this_line_loc_changed             VARCHAR2(2);
                     l_this_line_dist_changed            VARCHAR2(2);
                     x_header_change_flag                VARCHAR2(2);
                     l_this_line_exists_flag             VARCHAR2(2);
                     l_this_line_exists_chk              VARCHAR2(2);
                     l_gen_wf_param                      wf_parameter_list_t;

                     CURSOR M4R_7B5_OSFM_C1(l_po_header_id NUMBER, l_po_rel_id NUMBER)
                     IS
                     SELECT l.po_header_id,ll.po_line_id,ll.line_location_id,d.PO_DISTRIBUTION_ID
                     FROM   po_lines_all l, po_line_locations_all ll, po_distributions_all d
                     WHERE  l.po_header_id =  l_po_header_id
                            AND l.line_type_id  IN (
                                                     SELECT line_type_id
                                                     FROM po_line_types
                                                     WHERE outside_operation_flag ='Y'
                                                    )
                            AND ll.po_line_id = l.po_line_id
                            AND (ll.po_release_id = l_po_rel_id OR ll.po_release_id IS NULL)
                            AND d.line_location_id = ll.line_location_id;


BEGIN

            IF (g_debug_level <= 2) THEN
                      cln_debug_pub.Add('ENTERING M4R_7B5_OSFM_PKG.PROCESS_WO procedure with the following parameters:', 2);
                      cln_debug_pub.Add('itemtype:'   || p_itemtype, 2);
                      cln_debug_pub.Add('itemkey:'    || p_itemkey, 2);
                      cln_debug_pub.Add('actid:'      || p_actid, 2);
                      cln_debug_pub.Add('funcmode:'   || p_funcmode, 2);
                      cln_debug_pub.Add('resultout:'  || x_resultout, 2);
            END IF;


            -- read wf item attributes into local variable, begins
            l_po_header_id := wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'PO_HEADER_ID');
            IF (g_debug_level <= 1) THEN
                 cln_debug_pub.Add('PO Header ID ' || l_po_header_id, 1);
            END IF;

            l_po_rel_id := wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'PO_RELEASE_ID');
            IF (g_debug_level <= 1) THEN
                 cln_debug_pub.Add('PO Release ID ' || l_po_rel_id, 1);
            END IF;

            l_po_doc_type  := wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'DOCUMENT_TYPE');
            IF (g_debug_level <= 1) THEN
                 cln_debug_pub.Add('PO Document Type ' || l_po_doc_type, 1);
            END IF;

            l_po_rev_num   := wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'PO_REVISION_NUM');
            IF (g_debug_level <= 1) THEN
                 cln_debug_pub.Add('PO Revision Number ' || l_po_rev_num, 1);
            END IF;

            l_po_rel_num   := wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'PO_RELEASE_NUM');
            IF (g_debug_level <= 1) THEN
                 cln_debug_pub.Add('PO Release Number ' || l_po_rel_num, 1);
            END IF;

            l_po_rel_rev_num   := wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'PO_REL_REV_NUM');
            IF (g_debug_level <= 1) THEN
                 cln_debug_pub.Add('PO Release Revision Number ' || l_po_rel_rev_num, 1);
            END IF;

            l_org_id   := wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'ORG_ID');
            IF (g_debug_level <= 1) THEN
                 cln_debug_pub.Add('Org ID ' || l_org_id, 1);
            END IF;

            l_party_id   := wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'ECX_PARTY_ID');
            IF (g_debug_level <= 1) THEN
                  cln_debug_pub.Add('Party ID ' || l_party_id, 1);
            END IF;

            l_party_site_id   := wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'ECX_PARTY_SITE_ID');
            IF (g_debug_level <= 1) THEN
                 cln_debug_pub.Add('Party Site ID ' || l_party_site_id, 1);
            END IF;
            -- read wf item attributes into local variable, ends

            -- query date attributes and cancel flags for the po/release
            -- Check if this is
            --   A. New PO
            --   B. New Release
            --   C. Cancelled PO
            --   D. Cancelled Release

            --   Defaulting
            l_all_cancel_flag := 'N';
            l_all_new_flag    := 'N';

            IF l_po_doc_type ='RELEASE' THEN

                            g_exception_tracking_msg := 'Query po_releases_all for dates';

                            SELECT revised_date,creation_date
                            INTO   l_rev_date,l_creation_date
                            FROM   po_releases_archive_all
                            WHERE  po_release_id = l_po_rel_id
                                   AND revision_num = l_po_rel_rev_num;

                            IF (g_debug_level <= 1) THEN
                                  cln_debug_pub.Add('From po_releases_all Table',1);
                                  cln_debug_pub.Add('creation_date - ' ||l_creation_date,1);
                                  cln_debug_pub.Add('revised_date  - ' ||l_rev_date,1);
                                  cln_debug_pub.Add('cancel_flag   - ' ||l_cancel_flag,1);
                            END IF;

                            g_exception_tracking_msg := 'Query po_releases_all for cance_flag';

                            --   Query for Cancel flag
                            SELECT cancel_flag
                            INTO   l_cancel_flag
                            FROM   po_releases_all
                            WHERE  po_release_id = l_po_rel_id;

                            IF (g_debug_level <= 1) THEN
                                   cln_debug_pub.Add('cancel_flag - '||l_cancel_flag,1);
                            END IF;

              ELSE

                            g_exception_tracking_msg := 'Query po_headers_all for dates, cancel flag';

                            SELECT creation_date,revised_date,cancel_flag
                            INTO   l_creation_date,l_rev_date,l_cancel_flag
                            FROM   po_headers_archive_all
                            WHERE  po_header_id = l_po_header_id
                                   AND ((revision_num = l_po_rev_num) OR (revision_num IS NULL));

                            IF (g_debug_level <= 1) THEN
                                     cln_debug_pub.Add('From po_headers_all Table',1);
                                     cln_debug_pub.Add('creation_date - ' ||l_creation_date,1);
                                     cln_debug_pub.Add('revised_date  - ' ||l_rev_date,1);
                                     cln_debug_pub.Add('cancel_flag   - ' ||l_cancel_flag,1);
                            END IF;

            END IF;
            -- query date attributes and cancel flags for the po/release ends here


            -- set flags corresponding to new/cancel po release
            IF (l_po_doc_type ='RELEASE' and l_po_rel_rev_num = 0) OR
               ((l_po_doc_type ='STANDARD' OR l_po_doc_type = 'PO') AND l_po_rev_num = 0) THEN


                        l_all_new_flag  := 'Y';
                        l_raise_flag    := 'Y';
                        l_action_code   := 'WOR';
           -- Check if it is cancelled PO or release
            ELSE
                   IF l_cancel_flag = 'Y' THEN

                               l_all_cancel_flag := 'Y';
                               l_action_code     := 'WON';
                               l_raise_flag      := 'Y';

                               IF (g_debug_level <= 1) THEN
                                   cln_debug_pub.Add('Cancel Flag is Y. Document Type is Standard or PO and Action Code is WON', 1);
                               END IF;
                   END IF;
            END IF;
            -- Finished checking if it is new PO/Release or Cancelled PO/release

            IF (g_debug_level <= 1) THEN
                     cln_debug_pub.Add('Raise Flag: '        ||  l_raise_flag, 1);
                     cln_debug_pub.Add('l_all_cancel_flag: ' ||  l_all_cancel_flag, 1);
                     cln_debug_pub.Add('l_all_new_flag: '    ||  l_all_new_flag, 1);
                     cln_debug_pub.Add('l_action_code: '     ||  l_action_code, 1);
            END IF;

            -- Check for header change
            -- IF it is not a new or cancelled release
            -- then compare headers, this is to determine if the new PO revision is due to change
            -- in the header or change in the line.
            -- if it is due to a change in the header, then we need to 7B5 for everyline
            -- else, we can send only the modified lines
            IF l_all_new_flag <> 'Y'  and l_all_cancel_flag <> 'Y'  THEN   --  not a new or cancelled order

                        IF l_po_doc_type = 'RELEASE' THEN
                           l_po_rev_num_x := l_po_rel_rev_num;
                        ELSE
                           l_po_rev_num_x := l_po_rev_num;
                        END IF;

                        IF (g_debug_level <= 1) THEN
                                   cln_debug_pub.Add('l_po_rev_num_x - ' ||l_po_rev_num_x,1);
                        END IF;

                        compare_headers(l_po_header_id,l_po_rel_id,l_po_rev_num_x,x_header_change_flag);

                        IF (g_debug_level <= 1) THEN
                                   cln_debug_pub.Add('x_header_change_flag - ' ||x_header_change_flag,1);
                        END IF;

          END IF;
          -- Check for header change
          -- If it is not a new or cancelled order


        -- Loop through every distribution for the PO
        -- If it is not a new/cancel/header level change
        -- check it is a cancel change
        FOR lines_rec IN M4R_7B5_OSFM_C1(l_po_header_id,l_po_rel_id) LOOP

                    l_this_line_loc_cancel  := 'N';
                    l_this_line_changed     := 'N';
                    l_lines_loc_chk         := NULL;
                    l_lines_chk             := NULL;

                    IF (g_debug_level <= 1) THEN
                          cln_debug_pub.Add('Inside Cursor for',1);
                          cln_debug_pub.Add('Line ID  - '        || lines_rec.po_line_id,1);
                          cln_debug_pub.Add('Line Location ID - '|| lines_rec.line_location_id,1);
                          cln_debug_pub.Add('Distribution ID - ' || lines_rec.po_distribution_id,1);
                    END IF;

                    IF l_all_new_flag = 'Y' THEN
                        l_raise_flag    := 'Y';
                        l_action_code   := 'WOR';
                    ELSIF l_all_cancel_flag = 'Y' THEN
                        l_raise_flag    := 'Y';
                        l_action_code   := 'WON';
                    ELSE

                        g_exception_tracking_msg := 'Query po_line_locations_archive_all into l_lines_loc_chk';

                        BEGIN   -- Checks if the Shipments got cancelled

                                SELECT 'x'
                                INTO   l_lines_loc_chk
                                FROM   po_line_locations_archive_all
                                WHERE  po_header_id = l_po_header_id
                                        AND revision_num     = l_po_rev_num_x
                                        AND po_line_id       = lines_rec.po_line_id
                                        AND line_location_id = lines_rec.line_location_id
                                        AND cancel_flag      = 'Y';

                                IF l_lines_loc_chk ='x' THEN
                                        l_this_line_loc_cancel := 'Y';
                                END IF;

                                         IF (g_debug_level <= 1) THEN
                                                cln_debug_pub.Add('l_this_line_loc_cancel - '||l_this_line_loc_cancel,1);
                                         END IF;
                        EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                        l_this_line_loc_cancel := 'N';

                                        IF (g_debug_level <= 5) THEN
                                                cln_debug_pub.Add('No Rows Found',5);
                                                cln_debug_pub.Add('l_this_line_loc_cancel - '||l_this_line_loc_cancel,5);
                                        END IF;
                        END;

                        IF (l_this_line_loc_cancel <> 'Y') THEN

                                g_exception_tracking_msg := 'Query PO archive tables to check whether line have changes';

                                BEGIN  -- Checks if the line have changes

                                        SELECT COUNT(*)
                                        INTO   l_lines_chk
                                        FROM   dual
                                        WHERE  EXISTS ( (
                                                        SELECT po_header_id
                                                        FROM   po_lines_archive_all
                                                        WHERE  po_header_id      = l_po_header_id
                                                                AND po_line_id    = lines_rec.po_line_id
                                                                AND revision_num  = l_po_rev_num_x
                                                        )
                                                        UNION
                                                        (
                                                        SELECT po_header_id
                                                        FROM   po_line_locations_archive_all
                                                        WHERE  po_header_id       = l_po_header_id
                                                        AND revision_num   = l_po_rev_num_x
                                                        AND po_line_id     = lines_rec.po_line_id
                                                        AND line_location_id = lines_rec.line_location_id
                                                        )
                                                        UNION
                                                        (
                                                        SELECT po_header_id
                                                        FROM   po_distributions_archive_all
                                                        WHERE  po_header_id      = l_po_header_id
                                                        AND revision_num  = l_po_rev_num_x
                                                        AND po_line_id    = lines_rec.po_line_id
                                                        AND po_distribution_id = lines_rec.po_distribution_id
                                                        )
                                                      );

                                        IF l_lines_chk > 0 THEN
                                                l_this_line_changed := 'Y';
                                        END IF;

                                        IF (g_debug_level <= 1) THEN
                                                cln_debug_pub.Add('l_lines_chk - '         ||l_lines_chk,1);
                                                cln_debug_pub.Add('l_this_line_changed - ' ||l_this_line_changed,1);
                                        END IF;

                                EXCEPTION
                                        WHEN NO_DATA_FOUND THEN
                                                l_this_line_changed := 'N';
                                                IF (g_debug_level <= 5) THEN
                                                        cln_debug_pub.Add('No Rows Found',5);
                                                        cln_debug_pub.Add('l_this_line_changed - '||l_this_line_changed,5);
                                                END IF;
                                END;
                        END IF;

                        IF ((l_this_line_changed ='Y') OR (x_header_change_flag = 'Y')) THEN

                                l_raise_flag  := 'Y';
                                l_action_code := 'WOC';

                        ELSIF   l_this_line_loc_cancel = 'Y' THEN  -- if shipments cancelled

                                l_raise_flag  := 'Y';
                                l_action_code := 'WON';

                        ELSE    -- No header Change and No Cancel/Change in the line
                                l_raise_flag := 'N';
                        END IF;

                 END IF;

                 IF (g_debug_level <= 1) THEN
                              cln_debug_pub.Add('Before Setting the WF attributes', 1);
                              cln_debug_pub.Add('l_action_code : ' || l_action_code, 1);
                              cln_debug_pub.Add('l_raise_flag : '  || l_raise_flag, 1);
                 END IF;

                 IF l_raise_flag = 'Y' THEN  --- Set the event parameters for Generic Outbound WF

                               g_exception_tracking_msg := 'Query po_lines_archive_all for revision_num';

                               -- gets the Line Revision Number
                               SELECT revision_num,vendor_product_num,item_revision,unit_meas_lookup_code
                               INTO   l_line_rev_num,l_item,l_item_rv,l_uom
                               FROM   po_lines_archive_all
                               WHERE  po_header_id   = l_po_header_id
                                      AND po_line_id = lines_rec.po_line_id
                                      AND latest_external_flag = 'Y';

                               IF (g_debug_level <= 1) THEN
                                    cln_debug_pub.Add('Line Revision Number : ' || l_line_rev_num, 1);
                               END IF;

                               g_exception_tracking_msg := 'Query po_line_locations_archive_all for line_location_id,revision_num';

                               -- gets the Line Location ID, Line Location Revision Number
                               SELECT line_location_id,revision_num
                               INTO   l_line_loc_id,l_line_loc_rev_num
                               FROM   po_line_locations_archive_all
                               WHERE  po_header_id        = l_po_header_id
                                      AND po_line_id      = lines_rec.po_line_id
                                      AND line_location_id = lines_rec.line_location_id
                                      AND ((po_release_id = l_po_rel_id) OR (po_release_id IS NULL))
                                      AND latest_external_flag = 'Y'
                                      AND revision_num = (
                                                          SELECT MAX(revision_num)
                                                          FROM   po_line_locations_archive_all
                                                          WHERE  po_header_id        = l_po_header_id
                                                                 AND po_line_id      = lines_rec.po_line_id
                                                                 AND line_location_id = lines_rec.line_location_id
                                                                 AND ((po_release_id = l_po_rel_id) OR (po_release_id IS NULL))
                                                         );

                               IF (g_debug_level <= 1) THEN
                                    cln_debug_pub.Add('Line Location ID : '              || l_line_loc_id, 1);
                                    cln_debug_pub.Add('Line Location Revision Number : ' || l_line_loc_rev_num, 1);
                               END IF;

                               g_exception_tracking_msg := 'Query PO_DISTRIBUTIONS_ALL for WIP parameters';

                              -- gets the WIP attributs
                               SELECT WIP_ENTITY_ID,WIP_OPERATION_SEQ_NUM,DESTINATION_ORGANIZATION_ID,(QUANTITY_ORDERED-QUANTITY_CANCELLED)
                               INTO   l_wip_entity_id,l_rout_seq_num,l_osfm_org_id,l_dist_quant_ord
                               FROM   PO_DISTRIBUTIONS_ALL
                               WHERE  po_header_id           = l_po_header_id
                                      AND po_line_id         = lines_rec.po_line_id
                                      AND ((po_release_id    = l_po_rel_id) OR (po_release_id IS NULL))
                                      AND line_location_id   = l_line_loc_id
                                      AND po_distribution_id = lines_rec.po_distribution_id;

                               IF (g_debug_level <= 1) THEN
                                     cln_debug_pub.Add('WIP Entity ID : '          || l_wip_entity_id, 1);
                                     cln_debug_pub.Add('WIP Routing Seq Number : ' || l_rout_seq_num, 1);
                                     cln_debug_pub.Add('OSFM Org ID : '            || l_osfm_org_id, 1);
                               END IF;

                               g_exception_tracking_msg := 'Query WSM_WIP_GENEALOGY_V for Assembly parameters';

                               -- gets the Job Name, Assembly Name
                               SELECT  wip_entity_name,item_number
                               INTO    l_job_num,l_assembly_name
                               FROM    WSM_WIP_GENEALOGY_V
                               WHERE   WIP_ENTITY_ID       = l_wip_entity_id
                                       AND organization_id = l_osfm_org_id;

                               IF (g_debug_level <= 1) THEN
                                    cln_debug_pub.Add('WIP Job Number/ Entity Name' || l_job_num, 1);
                                    cln_debug_pub.Add('Assembly Name'               || l_assembly_name, 1);
                               END IF;

                               l_doc_num := l_job_num ||':' || l_rout_seq_num;

                               IF (g_debug_level <= 1) THEN
                                   cln_debug_pub.Add('Document Number' || l_doc_num, 1);
                               END IF;

                               g_exception_tracking_msg := 'Query M4R_7B5_OSFM_S1 into l_doc_id';

                               SELECT M4R_7B5_OSFM_S1.NEXTVAL
                               INTO    l_doc_id
                               FROM    dual;

                               l_event_key := '7B5:'|| l_doc_id || to_char(cast(sysdate as timestamp),'DD/MM/YY:HHMMSS');

                               IF (g_debug_level <= 1) THEN
                                     cln_debug_pub.Add('l_event_key' || l_event_key, 1);
                               END IF;

                               g_exception_tracking_msg := 'Query wip_operations for Assembly Description';

                               SELECT description
                               INTO   l_op_desc
                               FROM   wip_operations
                               WHERE  wip_entity_id         = l_wip_entity_id
                                      AND operation_seq_num = l_rout_seq_num;

                               IF (g_debug_level <= 1) THEN
                                   cln_debug_pub.Add('Operation Desc' || l_op_desc, 1);
                               END IF;

                               IF (g_debug_level <= 2) THEN
                                      cln_debug_pub.Add('Raising Generic WF with the following parameters', 2);
                                      cln_debug_pub.Add('Party Type      : ' || l_party_type,2);
                                      cln_debug_pub.Add('Party ID        : ' || l_party_id,2);
                                      cln_debug_pub.Add('Party Site ID   : ' || l_party_site_id,2);
                                      cln_debug_pub.Add('Org ID          : ' || l_org_id,2);
                                      cln_debug_pub.Add('Document Number : ' || l_doc_num,2);
                                      cln_debug_pub.Add('Document ID     : ' || l_doc_id,2);
                                      cln_debug_pub.Add('PO Header ID    : ' || l_po_header_id,2);
                                      cln_debug_pub.Add('PO Release ID   : ' || l_po_rel_id,2);

                                      cln_debug_pub.Add('PO Line ID                     : ' || lines_rec.po_line_id,2);
                                      cln_debug_pub.Add('PO Line Location ID            : ' || l_line_loc_id,2);
                                      cln_debug_pub.Add('PO Revision Number             : ' || l_po_rev_num,2);
                                      cln_debug_pub.Add('PO Release Number              : ' || l_po_rel_num,2);
                                      cln_debug_pub.Add('PO Release Revision Number     : ' || l_po_rel_rev_num,2);
                                      cln_debug_pub.Add('PO Lines Revision Number       : ' || l_line_rev_num,2);
                                      cln_debug_pub.Add('Line Locations Revision Number : ' || l_line_loc_rev_num,2);
                                      cln_debug_pub.Add('Document Creation Date         : ' || l_cn_create_date,2);

                                      cln_debug_pub.Add('Document Revision Date    : ' || l_cn_rev_date,2);
                                      cln_debug_pub.Add('Action Code               : ' || l_action_code,2);
                                      cln_debug_pub.Add('WIP Entity ID             : ' || l_wip_entity_id,2);
                                      cln_debug_pub.Add('Assembly Name             : ' || l_assembly_name,2);
                                      cln_debug_pub.Add('Operation Desc            : ' || l_op_desc,2);
                                      cln_debug_pub.Add('Operation Sequence Number : ' || l_rout_seq_num,2);
                                      cln_debug_pub.Add('Reference ID              : ' || l_event_key,2);
                                      cln_debug_pub.Add('UOM                       : ' || l_uom,2);
                               END IF;

                               WF_EVENT.AddParameterToList('ECX_TRANSACTION_TYPE', 'M4R', l_gen_wf_param);
                               WF_EVENT.AddParameterToList('ECX_TRANSACTION_SUBTYPE', '7B5_OSFM_WO', l_gen_wf_param);
                               WF_EVENT.AddParameterToList('ECX_PARTY_TYPE', 'S', l_gen_wf_param);
                               WF_EVENT.AddParameterToList('ECX_PARTY_ID', l_party_id, l_gen_wf_param);
                               WF_EVENT.AddParameterToList('ECX_PARTY_SITE_ID', l_party_site_id, l_gen_wf_param);
                               WF_EVENT.AddParameterToList('ECX_DOCUMENT_ID', l_event_key, l_gen_wf_param);
                               WF_EVENT.AddParameterToList('ORG_ID', l_org_id, l_gen_wf_param);
                               WF_EVENT.AddParameterToList('DOCUMENT_NO', l_doc_num, l_gen_wf_param);
                               WF_EVENT.AddParameterToList('VALIDATION_REQUIRED_YN', 'N', l_gen_wf_param);
                               WF_EVENT.AddParameterToList('CH_MESSAGE_BEFORE_GENERATE_XML', 'M4R_7B5_OSFM_CH_CREATED', l_gen_wf_param);
                               WF_EVENT.AddParameterToList('CH_MESSAGE_AFTER_XML_SENT', 'M4R_7B5_OSFM_CH_XML_GENERATED', l_gen_wf_param);
                               WF_EVENT.AddParameterToList('ECX_DELIVERY_CHECK_REQUIRED', 'N', l_gen_wf_param);
                               WF_EVENT.AddParameterToList('ECX_PARAMETER1', l_po_header_id, l_gen_wf_param);
                               WF_EVENT.AddParameterToList('ECX_PARAMETER2', l_po_rev_num, l_gen_wf_param);
                               WF_EVENT.AddParameterToList('ECX_PARAMETER3', lines_rec.po_line_id, l_gen_wf_param);
                               WF_EVENT.AddParameterToList('ECX_PARAMETER4', l_action_code, l_gen_wf_param);
                               WF_EVENT.AddParameterToList('ECX_PARAMETER5', l_wip_entity_id, l_gen_wf_param);

                               g_exception_tracking_msg := 'FND_DATE.DATE_TO_CANONICAL(l_rev_date)';

                               l_cn_rev_date := FND_DATE.DATE_TO_CANONICAL(l_rev_date);
                               WF_EVENT.AddParameterToList('DOCUMENT_REVISION_DATE', l_cn_rev_date, l_gen_wf_param);

                               g_exception_tracking_msg := 'FND_DATE.DATE_TO_CANONICAL(l_creation_date)';

                               l_cn_create_date := FND_DATE.DATE_TO_CANONICAL(l_creation_date);
                               WF_EVENT.AddParameterToList('DOCUMENT_CREATION_DATE', l_cn_create_date, l_gen_wf_param);

                               WF_EVENT.AddParameterToList('COLLABORATION_STATUS_SET', 'Y', l_gen_wf_param);
                               WF_EVENT.AddParameterToList('ATTRIBUTE1', l_po_rel_id, l_gen_wf_param);
                               WF_EVENT.AddParameterToList('ATTRIBUTE2', l_rout_seq_num, l_gen_wf_param);
                               WF_EVENT.AddParameterToList('ATTRIBUTE3', l_line_loc_id, l_gen_wf_param);
                               WF_EVENT.AddParameterToList('ATTRIBUTE5', l_po_rel_num, l_gen_wf_param);
                               WF_EVENT.AddParameterToList('ATTRIBUTE6', l_assembly_name, l_gen_wf_param);
                               WF_EVENT.AddParameterToList('ATTRIBUTE7', l_op_desc, l_gen_wf_param);
                               WF_EVENT.AddParameterToList('ATTRIBUTE8', l_line_loc_rev_num, l_gen_wf_param);
                               WF_EVENT.AddParameterToList('ATTRIBUTE9', l_line_rev_num, l_gen_wf_param);
                               WF_EVENT.AddParameterToList('ATTRIBUTE10', l_dist_quant_ord, l_gen_wf_param);
                               WF_EVENT.AddParameterToList('ATTRIBUTE11', l_item, l_gen_wf_param);
                               WF_EVENT.AddParameterToList('ATTRIBUTE12', l_item_rv, l_gen_wf_param);
                               WF_EVENT.AddParameterToList('ATTRIBUTE13', l_uom, l_gen_wf_param);

                               g_exception_tracking_msg := 'CONVERT_TO_RN_DATETIME(l_rev_date,x_rn_datetime)';

                               cln_rn_utils.CONVERT_TO_RN_DATETIME(l_rev_date,x_rn_datetime);
                               WF_EVENT.AddParameterToList('DATTRIBUTE1', x_rn_datetime, l_gen_wf_param);

                               g_exception_tracking_msg := 'CONVERT_TO_RN_DATETIME(l_creation_date,x_rn_datetime)';

                               cln_rn_utils.CONVERT_TO_RN_DATETIME(l_creation_date,x_rn_datetime);
                               WF_EVENT.AddParameterToList('DATTRIBUTE2', x_rn_datetime, l_gen_wf_param);

                               IF l_po_doc_type = 'RELEASE' THEN
                                    WF_EVENT.AddParameterToList('ATTRIBUTE4', l_po_rel_rev_num, l_gen_wf_param); -- Release Revision Number
                               ELSE
                                    WF_EVENT.AddParameterToList('ATTRIBUTE4', l_po_rev_num, l_gen_wf_param); ---- PO Revision Number
                               END IF;

                               IF (g_debug_level <= 2) THEN
                                       cln_debug_pub.Add('ATTRIBUTE4  : ' || l_po_rev_num || ' Header Revision Number' ,2);
                               END IF;

                               WF_EVENT.AddParameterToList('REFERENCE_ID', l_event_key, l_gen_wf_param);

                               WF_EVENT.Raise('oracle.apps.cln.common.xml.out',l_event_key, NULL, l_gen_wf_param, NULL);

                               IF (g_debug_Level <= 1) THEN
                                    cln_debug_pub.Add('---------Generic Workflow Triggered ---------', 1);
                               END IF;
                  END IF;  -- For Raise Flag = Y
                  -- reset l_raise_flag before next iteration
                  l_raise_flag := 'N';

        END LOOP;

        x_resultout := wf_engine.eng_completed;

      IF (g_debug_level <= 2) THEN
            cln_debug_pub.Add('Exiting the M4R_7B5_OSFM_PKG.PROCESS_WO procedure', 2);
      END IF;

      EXCEPTION
             WHEN OTHERS THEN
                      l_error_code := SQLCODE;
                      l_errmsg     := SQLERRM;

                      IF (g_debug_level <= 5) THEN
                          cln_debug_pub.Add('g_exception_tracking_msg : ' || g_exception_tracking_msg,5);
                          cln_debug_pub.Add('Exception in PROCESS_WO proc', 5);
                          cln_debug_pub.Add('Error is ' || l_error_code || ':' || l_errmsg, 5);
                      END IF;

END PROCESS_WO;


   -- Procedure
   --    COMPARE_HEADERS

   -- Purpose
   --    This procedure is called from the PROCESS_WO procedure. It checks for chnages in the header of the PO with the
   --    previous revision of the PO.

PROCEDURE compare_headers(  p_header_id            IN          NUMBER,
                            p_release_id           IN          NUMBER,
                            p_revision_num         IN          NUMBER,
                            x_header_change_flag   OUT NOCOPY  VARCHAR2) AS

                            l_from_ship_to_location_id            NUMBER;
                            l_to_ship_to_location_id              NUMBER;
                            l_from_bill_to_location_id            NUMBER;
                            l_to_bill_to_location_id              NUMBER;
                            l_from_terms_id                       NUMBER;
                            l_to_terms_id                         NUMBER;
                            l_from_ship_via_lookup_code           VARCHAR2(25);
                            l_to_ship_via_lookup_code             VARCHAR2(25);
                            l_from_fob_lookup_code                VARCHAR2(25);
                            l_to_fob_lookup_code                  VARCHAR2(25);
                            l_from_vendor_site_id                 NUMBER;
                            l_to_vendor_site_id                   NUMBER;
                            l_from_amount_limit                   NUMBER;
                            l_to_amount_limit                     NUMBER;
                            l_from_rel_num                        NUMBER;
                            l_to_rel_num                          NUMBER;
                            l_from_start_date                     DATE;
                            l_to_start_date                       DATE;
                            l_from_end_date                       DATE;
                            l_to_end_date                         DATE;
                            l_error_code                          NUMBER;
                            l_errmsg                              VARCHAR2(2000);

BEGIN

IF (g_debug_level <= 2) THEN
            cln_debug_pub.Add('Entering M4R_7B5_OSFM_PKG.compare_headers', 2);
END IF;

IF p_revision_num <= 0
THEN
        RETURN;
END IF;

IF p_release_id IS NULL THEN

       g_exception_tracking_msg := 'Query po_headers_archive_all to find Header change between current and previous revision';

        BEGIN
                SELECT f.ship_to_location_id,t.ship_to_location_id,
                       f.bill_to_location_id,t.bill_to_location_id,
                       f.terms_id,t.terms_id,
                       f.ship_via_lookup_code,t.ship_via_lookup_code,
                       f.fob_lookup_code,t.fob_lookup_code,
                       f.vendor_site_id,t.vendor_site_id,
                       f.amount_limit,t.amount_limit,
                       f.start_date,t.start_date,
                       f.end_date,t.end_date
                INTO   l_from_ship_to_location_id,l_to_ship_to_location_id,
                       l_from_bill_to_location_id,l_to_bill_to_location_id,
                       l_from_terms_id,l_to_terms_id,
                       l_from_ship_via_lookup_code,l_to_ship_via_lookup_code,
                       l_from_fob_lookup_code,l_to_fob_lookup_code,
                       l_from_vendor_site_id,l_to_vendor_site_id,
                       l_from_amount_limit,l_to_amount_limit,
                       l_from_start_date,l_to_start_date,
                       l_from_end_date,l_to_end_date
                FROM   po_headers_archive_all f, po_headers_archive_all t
                WHERE  f.po_header_id = p_header_id
                       AND f.revision_num = p_revision_num
                       AND t.po_header_id = p_header_id
                       AND t.revision_num = p_revision_num-1;

        EXCEPTION
                WHEN no_data_found THEN

                      IF (g_debug_level <= 5) THEN
                          cln_debug_pub.Add('Exception in COMPARE_PO proc - headers query - NO DATA FOUND', 5);
                      END IF;
       END;

        IF ((NVL( l_from_ship_to_location_id, -99 )  <> NVL( l_to_ship_to_location_id, -99 )) OR
            (NVL( l_from_bill_to_location_id, -99 )  <> NVL( l_to_bill_to_location_id, -99 )) OR
            (NVL( l_from_terms_id, -99 )             <> NVL( l_to_terms_id, -99 )) OR
            (NVL( l_from_ship_via_lookup_code, ' ' ) <> NVL( l_to_ship_via_lookup_code, ' ' ))OR
            (NVL( l_from_fob_lookup_code, ' ' )      <> NVL( l_to_fob_lookup_code, ' ' )) OR
            (NVL( l_from_vendor_site_id, -99 )       <> NVL( l_to_vendor_site_id, -99 )) OR
            (NVL( l_from_amount_limit, -99 )         <> NVL( l_to_amount_limit, -99 )) OR
            (NVL( l_from_start_date,TO_DATE( '01/01/1000', 'DD/MM/YYYY' )) <> NVL( l_to_start_date,TO_DATE( '01/01/1000', 'DD/MM/YYYY' ))) OR
            (NVL( l_from_end_date,TO_DATE( '01/01/1000', 'DD/MM/YYYY' ))   <> NVL( l_to_end_date,TO_DATE( '01/01/1000', 'DD/MM/YYYY' )))
          ) THEN

               x_header_change_flag := 'Y';
        ELSE
               x_header_change_flag := 'N';
        END IF;

ELSE

        g_exception_tracking_msg := 'Query po_releases_archive_all to find Header change between current and previous revision';

        BEGIN
                SELECT f.release_num ,t.release_num
                INTO   l_from_rel_num,l_to_rel_num
                FROM   po_releases_archive_all f,po_releases_archive_all t
                WHERE  f.po_release_id     = p_release_id
                       AND f.revision_num  = p_revision_num
                       AND t.po_release_id = p_release_id
                       AND t.revision_num  = p_revision_num-1;

        EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      IF (g_debug_level <= 5) THEN
                          cln_debug_pub.Add('Exception in COMPARE_PO proc - releases query - NO DATA FOUND', 5);
                      END IF;

        END;

        IF (NVL(l_from_rel_num,-99) <> NVL(l_to_rel_num, -99 )) THEN
                      x_header_change_flag := 'Y';
        ELSE
                      x_header_change_flag := 'N';
        END IF;

END IF;

EXCEPTION
WHEN OTHERS THEN
         l_error_code := SQLCODE;
         l_errmsg     := SQLERRM;

         IF (g_debug_level <= 5) THEN
                          cln_debug_pub.Add('g_exception_tracking_msg :' || g_exception_tracking_msg,5);
                          cln_debug_pub.Add('Exception in PROCESS_WO proc', 5);
                          cln_debug_pub.Add('Error is ' || l_error_code || ':' || l_errmsg, 5);
         END IF;

END compare_headers;

BEGIN
      g_debug_level   := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

END M4R_7B5_OSFM_PKG;

/
