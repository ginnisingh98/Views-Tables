--------------------------------------------------------
--  DDL for Package Body PO_VENDORMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_VENDORMERGE_GRP" AS
/* $Header: PO_VendorMerge_GRP.plb 120.2.12010000.2 2011/11/16 12:47:47 swagajul ship $ */

g_pkg_name 	CONSTANT VARCHAR2(30):='PO_VendorMerge_GRP';

-- Start of comments
--    API name 	   : Merge_Vendor
--    Type	   : Group.
--    Function	   :
--    Pre-reqs	   : None.
--    Parameters   :
--	IN	   : p_api_version       IN   NUMBER	       Required
--		     p_init_msg_list	 IN   VARCHAR2         Optional
--				    Default = FND_API.G_FALSE
--		     p_commit	    	 IN   VARCHAR2	       Optional
--				    Default = FND_API.G_FALSE
--		     p_validation_level	 IN   NUMBER	       Optional
--				    Default = FND_API.G_VALID_LEVEL_FULL
--		     parameter1
--		     parameter2
--				.
--				.
--	OUT	   : x_return_status	 OUT    VARCHAR2(1)
--		     x_msg_count	 OUT	NUMBER
--		     x_msg_data		 OUT	VARCHAR2(2000)
--	             parameter1
--		     parameter2
-- End of comments

Procedure Merge_Vendor(
            p_api_version        IN   NUMBER,
	    p_init_msg_list      IN   VARCHAR2 default FND_API.G_FALSE,
	    p_commit             IN   VARCHAR2 default FND_API.G_FALSE,
	    p_validation_level   IN   NUMBER   default FND_API.G_VALID_LEVEL_FULL,
	    x_return_status      OUT  NOCOPY VARCHAR2,
	    x_msg_count          OUT  NOCOPY NUMBER,
	    x_msg_data           OUT  NOCOPY VARCHAR2,
	    p_vendor_id          IN   NUMBER,
	    p_vendor_site_id     IN   NUMBER,
	    p_dup_vendor_id      IN   NUMBER,
	    p_dup_vendor_site_id IN   NUMBER,
	    p_party_id           IN   NUMBER default NULL,
            p_dup_party_id       IN   NUMBER default NULL,
            p_party_site_id      IN   NUMBER default NULL,
            p_dup_party_site_id  IN   NUMBER default NULL
	    )

IS

         cursor merge_autosrc_docs is
         select distinct pad.autosource_rule_id,
                pad.sequence_num,
                pad.document_line_id
         from   po_autosource_documents pad
         where  pad.vendor_id = p_dup_vendor_id;

         l_api_name	      CONSTANT VARCHAR2(30)	:= 'Merge_Vendor';
         l_api_version        CONSTANT NUMBER 	        := 1.0;
         l_row_count	      NUMBER;
         l_max_seq_num        number;
         l_new_seq_num        number;
         l_seq_num            number;
         l_rule_id            number;
         l_doc_line_id        number;
	 l_last_updated_by    number;

	 d_progress NUMBER;
	 d_module   VARCHAR2(60) := 'po.plsql.PO_VendorMerge_GRP.Merge_Vendor';

BEGIN

        d_progress := 0;
        IF (PO_LOG.d_proc) THEN
           PO_LOG.proc_begin(d_module);
           PO_LOG.proc_begin(d_module, 'p_vendor_id', p_vendor_id);
           PO_LOG.proc_begin(d_module, 'p_vendor_site_id', p_vendor_site_id);
           PO_LOG.proc_begin(d_module, 'p_dup_vendor_id', p_dup_vendor_id);
	   PO_LOG.proc_begin(d_module, 'p_dup_vendor_site_id', p_dup_vendor_site_id);
           PO_LOG.proc_begin(d_module, 'p_party_id', p_party_id);
           PO_LOG.proc_begin(d_module, 'p_dup_party_id', p_dup_party_id);
           PO_LOG.proc_begin(d_module, 'p_party_site_id', p_party_site_id);
           PO_LOG.proc_begin(d_module, 'p_dup_party_site_id', p_dup_party_site_id);
        END IF;

         --  Initialize API return status to success
         x_return_status := FND_API.G_RET_STS_SUCCESS;

         l_last_updated_by := FND_GLOBAL.user_id;
         -- Check for call compatibility.
         IF NOT FND_API.Compatible_API_Call ( l_api_version  ,
                                              p_api_version  ,
                                              l_api_name     ,
                                              G_PKG_NAME             )
         THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         -- Initialize API message list if necessary.
         -- Initialize message list if p_init_msg_list is set to TRUE.
         IF FND_API.to_Boolean( p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
         END IF;

         d_progress := 10;

         --Bug 5435716 START
         --Bug 12728157
      UPDATE po_headers ph
      SET    ph.vendor_id = p_vendor_id,
             ph.vendor_site_id = p_vendor_site_id,
             ph.vendor_contact_id = (SELECT vendor_contact_id
                                     FROM   ap_supplier_contacts
                                     WHERE org_party_site_id = (SELECT party_site_id
                                                                FROM   ap_supplier_sites_all
                                                                WHERE vendor_site_id = p_vendor_site_id)
                                     AND per_party_id = (SELECT per_party_id
                                                                FROM   ap_supplier_contacts
                                                               WHERE vendor_contact_id = ph.vendor_contact_id)),
           last_updated_by = l_last_updated_by,
           last_update_date = SYSDATE
      WHERE  ph.vendor_id = p_dup_vendor_id
      AND ph.vendor_site_id = p_dup_vendor_site_id;


          UPDATE po_rfq_vendors
          SET    vendor_id        = p_vendor_id,
                 vendor_site_id   = p_vendor_site_id,
                 last_updated_by  = l_last_updated_by,
                 last_update_date = sysdate
       	 WHERE  vendor_id      = p_dup_vendor_id
         AND    vendor_site_id = p_dup_vendor_site_id ;

          DELETE from po_rfq_vendors prv
          WHERE  vendor_id = p_dup_vendor_id
          AND    vendor_site_id = p_dup_vendor_site_id;


         --Bug 5435716 END

         -- modify PO_HEADERS_ARCHIVE
         UPDATE po_headers_archive
         SET    vendor_id      = p_vendor_id,
          	vendor_site_id = p_vendor_site_id
       	 WHERE  vendor_id      = p_dup_vendor_id
         AND    vendor_site_id = p_dup_vendor_site_id ;

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, 'updated PO_HEADERS_ARCHIVE');
        END IF;


         -- modify PO_VENDOR_LIST_ENTRIES
         -- bug3537645 added vendor_site_id  condition
         UPDATE po_vendor_list_entries pv1
         SET    pv1.vendor_id      = p_vendor_id,
            	pv1.vendor_site_id = p_vendor_site_id
         WHERE  pv1.vendor_id      = p_dup_vendor_id
         AND    pv1.vendor_site_id = p_dup_vendor_site_id
         AND    not exists
  			(select vendor_id
                         from po_vendor_list_entries pv2
                         where pv2.vendor_id      = p_vendor_id
                         and pv2.vendor_site_id   = p_vendor_site_id
                         and pv2.vendor_list_header_id =
                                pv1.vendor_list_header_id);

         -- delete the vendor_list_entry if the new vendor_id would make the
         -- record a duplicate ie. if modify_po6 had failed
         -- Anything not moved to the new vendor would have been a duplicate
         -- and should be deleted
         -- DELETE from po_vendor_list_entries pvl
         --          WHERE  vendor_id      = p_dup_vendor_id
         --          AND    vendor_site_id = p_vendor_site_id;
         -- Fix for 2086548 commented the above do_sql and wrote the below one
         DELETE from po_vendor_list_entries pvl
         WHERE  vendor_id      = p_dup_vendor_id
         AND    vendor_site_id = p_dup_vendor_site_id ;


        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, 'updated PO_VENDOR_LIST_ENTRIES');
        END IF;

         -- modify PO_AUTOSOURCE_VENDORS
         UPDATE po_autosource_vendors pav1
         SET    pav1.vendor_id      = p_vendor_id
         WHERE  pav1.vendor_id      = p_dup_vendor_id
         AND    not exists
 		(select vendor_id
                from po_autosource_vendors pav2
                where pav2.vendor_id      = p_vendor_id
                and pav2.autosource_rule_id =
                pav1.autosource_rule_id) ;


         -- modify split
         UPDATE po_autosource_vendors pav1
         SET pav1.split     = (SELECT sum (pav3.split)
                               FROM   po_autosource_vendors pav3
                               WHERE  pav3.autosource_rule_id =
 				      pav1.autosource_rule_id
                  	       AND    pav3.vendor_id IN
	                              (p_vendor_id, p_dup_vendor_id))
         WHERE  pav1.vendor_id      = p_vendor_id
       	 AND    exists
 		(select pav2.vendor_id
                 from po_autosource_vendors pav2
                 where pav2.vendor_id      = p_dup_vendor_id
                 and pav2.autosource_rule_id =
                                pav1.autosource_rule_id) ;



         -- delete the autosource entry if the new vendor_id would make the
         -- record a duplicate ie. if modify_po6 had failed
         -- Anything not moved to the new vendor would have been a duplicate
         -- and should be deleted


         IF (p_dup_vendor_id <> p_vendor_id) THEN

         DELETE from po_autosource_vendors pavl
         WHERE  vendor_id      = p_dup_vendor_id ;

         END IF;

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, 'updated PO_AUTOSOURCE_VENDORS');
        END IF;

         -- modify po_autosource_documents
         --
         open merge_autosrc_docs;

         loop
              l_max_seq_num := 0;

              fetch merge_autosrc_docs into
              l_rule_id, l_seq_num, l_doc_line_id;
              exit when merge_autosrc_docs%notfound;

              select nvl(max(sequence_num),0)
              into   l_max_seq_num
              from   po_autosource_documents
              where  autosource_rule_id  = l_rule_id
              and    vendor_id           = p_vendor_id;

              l_new_seq_num := l_max_seq_num + 1;

              update po_autosource_documents
              set    vendor_id          = p_vendor_id,
                     sequence_num       = l_new_seq_num
              where  autosource_rule_id = l_rule_id
              and    vendor_id          = p_dup_vendor_id
              and    sequence_num       = l_seq_num
              and    not exists
                    (select 'already have PAD for this rule, vendor, doc line'
                     from   po_autosource_documents
                     where  autosource_rule_id = l_rule_id
                     and    vendor_id = p_vendor_id
                     and    document_line_id = l_doc_line_id);

         end loop;

         close merge_autosrc_docs;

         -- delete the document entry if the new vendor_id would make the
         -- record a duplicate


         IF (p_dup_vendor_id <> p_vendor_id) Then

         delete from po_autosource_documents
         where  vendor_id = p_dup_vendor_id;

         End If;

	IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, 'updated PO_AUTOSOURCE_DOCUMENTS');
        END IF;

    -- Starting from 11i FPJ we no longer update ga org assignments based on
    -- vendor site code. Instead we just need to update org assignment with
    -- vendor site id that matches p_from_vendor_id

        UPDATE  po_ga_org_assignments PGOA
        SET     PGOA.vendor_site_id = p_vendor_site_id,
                PGOA.last_update_date = SYSDATE,
                PGOA.last_updated_by = l_last_updated_by,
                PGOA.last_update_login = FND_GLOBAL.login_id
        WHERE   PGOA.vendor_site_id = p_dup_vendor_site_id;

        UPDATE  po_ga_org_assignments_archive PGOA
        SET     PGOA.vendor_site_id = p_vendor_site_id,
                PGOA.last_update_date = SYSDATE,
                PGOA.last_updated_by = l_last_updated_by,
                PGOA.last_update_login = FND_GLOBAL.login_id
        WHERE   PGOA.vendor_site_id = p_dup_vendor_site_id;

	IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, 'updated PO_GA_ORG_ASSIGNMENTS');
        END IF;

         -- modify  PO_REQUISITION_LINES
         UPDATE PO_REQUISITION_LINES
         SET    suggested_vendor_name =  (select pov1.vendor_name
                                          from   po_vendors pov1
                          		  where  pov1.vendor_id =
         		                         p_vendor_id),
                suggested_vendor_location =  (select pvs1.vendor_site_code
 				              from   po_vendor_sites pvs1
					      where  pvs1.vendor_site_id =
				                     p_vendor_site_id)
         WHERE  suggested_vendor_name in     (select pov2.vendor_name
 					      from   po_vendors pov2
 					      where  pov2.vendor_id =
  					             p_dup_vendor_id)
 	 AND    suggested_vendor_location in (select pvs2.vendor_site_code
 					      from   po_vendor_sites pvs2
 					      where  vendor_site_id =
     						     p_dup_vendor_site_id);


         UPDATE po_requisition_lines
         SET    vendor_id     = p_vendor_id,
	       vendor_site_id = p_vendor_site_id,
             last_update_date = sysdate,
             last_updated_by  = l_last_updated_by
         WHERE  vendor_id = p_dup_vendor_id
         AND    vendor_site_id = p_dup_vendor_site_id ;

         UPDATE po_requisition_lines
       	 SET    vendor_id       = p_vendor_id,
	       last_update_date = sysdate,
               last_updated_by  = l_last_updated_by
       	 WHERE  vendor_id = p_dup_vendor_id
 	 AND    vendor_site_id is null
         AND    exists
        	( select vendor_id
		  from   po_vendors
		  where  vendor_id = p_dup_vendor_id
 		  and    nvl(end_date_active, sysdate+1) <= sysdate);

	IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, 'updated PO_REQUISITION_LINES');
        END IF;


       -- Update Req Template Records
       UPDATE  po_reqexpress_lines_all PRL
       SET     PRL.suggested_vendor_id = p_vendor_id,
               PRL.suggested_vendor_site_id = p_vendor_site_id,
               PRL.last_update_date = SYSDATE,
               PRL.last_updated_by = l_last_updated_by
       WHERE   PRL.suggested_vendor_id = p_dup_vendor_id
       AND     PRL.suggested_vendor_site_id = p_dup_vendor_site_id;


       --SQL What: update requisition template with the new supplier if supplier
       --          site is null in the template, and the supplier is getting
       --          invalidatad because of the merge
       --SQL Why:  If the supplier is not active after vendor merge,the records
       --          associated to that supplier should be moved to point to the
       --          new supplier

       UPDATE  po_reqexpress_lines_all PRL
       SET     PRL.suggested_vendor_id = p_vendor_id,
               last_update_date = SYSDATE,
               last_updated_by = l_last_updated_by
       WHERE   PRL.suggested_vendor_id = p_dup_vendor_id
       AND     PRL.suggested_vendor_site_id IS NULL
       AND     EXISTS (
                   SELECT  NULL
                   FROM    po_vendors PV
                   WHERE   PV.vendor_id = p_dup_vendor_id
                   AND     NVL(PV.end_date_active, SYSDATE + 1) <= SYSDATE);


	IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, 'updated PO_REQEXPRESS_LINES_ALL');
        END IF;

         -- modify po_approved_supplier_list
         UPDATE po_approved_supplier_list poasl1
         SET    poasl1.vendor_id      = p_vendor_id,
            	poasl1.vendor_site_id = p_vendor_site_id
         WHERE  poasl1.vendor_id      = p_dup_vendor_id
 	 AND    poasl1.vendor_site_id = p_dup_vendor_site_id
         	AND    not exists
  		       ( select vendor_id
                         from   po_approved_supplier_list poasl2
                         where  poasl2.vendor_id      = p_vendor_id
                         and    poasl2.vendor_site_id = p_vendor_site_id
                         and    nvl(poasl2.item_id, -99) =
                                            nvl(poasl1.item_id, -99)
  		         and nvl(poasl2.category_id, -99) =
                                            nvl(poasl1.category_id, -99)
    		         and  poasl2.using_organization_id =
                                            poasl1.using_organization_id) ;
         --1755383 Added the nvl condition so that null values does not result
         --in success

         -- delete the approved_list_entry if the new vendor_id would make the
         -- record a duplicate.
         -- Bug: 1494378
         DELETE from po_approved_supplier_list poasl
  	 WHERE  vendor_id      = p_dup_vendor_id
 	 AND    vendor_site_id = p_dup_vendor_site_id ;

         --Bug 1755383 start
         -- modify po_approved_supplier_list

         UPDATE po_approved_supplier_list poasl1
         SET    poasl1.vendor_id      = p_vendor_id
         WHERE  poasl1.vendor_id      = p_dup_vendor_id
     	 AND    poasl1.vendor_site_id is null
         AND    exists
		( select vendor_id
		  from   po_vendors
		  where  vendor_id = p_dup_vendor_id
		  and    nvl(end_date_active, sysdate+1) <= sysdate)
       	 AND    not exists
		( select vendor_id
                  from   po_approved_supplier_list poasl2
                  where  poasl2.vendor_id             = p_vendor_id
                  and    poasl2.vendor_site_id is null
                  and    nvl(poasl2.item_id, -99)     =
                                                nvl(poasl1.item_id, -99)
 		  and    nvl(poasl2.category_id, -99) =
                                                nvl(poasl1.category_id, -99)
		  and    poasl2.using_organization_id =
                                                poasl1.using_organization_id);

         -- delete the approved_list_entry if the new vendor_id would make the
         -- record a duplicate.

         DELETE from po_approved_supplier_list poasl
 	 WHERE  vendor_id      = p_dup_vendor_id
 	 AND    vendor_site_id is null
 	 AND    exists
 		( select vendor_id
 		  from   po_vendors
 		  where  vendor_id = p_dup_vendor_id
 		  and    nvl(end_date_active, sysdate+1) <= sysdate);

	IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, 'updated PO_APPROVED_SUPPLIER_LIST');
        END IF;

         -- modify po_asl_attributes
         UPDATE po_asl_attributes poasl1
         SET    poasl1.vendor_id      = p_vendor_id,
        	poasl1.vendor_site_id = p_vendor_site_id
         WHERE  poasl1.vendor_id      = p_dup_vendor_id
    	 AND    poasl1.vendor_site_id = p_dup_vendor_site_id
       	 AND    not exists
		(select vendor_id
                 from po_asl_attributes poasl2
                 where poasl2.vendor_id           = p_vendor_id
                 and poasl2.vendor_site_id        = p_vendor_site_id
                 and nvl(poasl2.item_id, -99)     = nvl(poasl1.item_id, -99)
    	         and nvl(poasl2.category_id, -99) = nvl(poasl1.category_id, -99)
 	         and poasl2.using_organization_id =
 					poasl1.using_organization_id);
         --1755383 Added the nvl condition so that null values does not result
         --in success
         -- delete the approved_list_entry if the new vendor_id would make the
         -- record a duplicate.
         -- DELETE from po_asl_attributes poasl
         --           WHERE  vendor_id      = p_dup_vendor_id
         --           AND    vendor_site_id = p_vendor_site_id ;
         -- FIX FOR 1931927 commented the above do_sql and wrote the below one
         DELETE from po_asl_attributes poasl
         WHERE  vendor_id      = p_dup_vendor_id
	 AND    vendor_site_id = p_dup_vendor_site_id ;


         --Bug 1755383 start

         UPDATE po_asl_attributes poasl1
         SET    poasl1.vendor_id      = p_vendor_id
         WHERE  poasl1.vendor_id      = p_dup_vendor_id
	 AND    poasl1.vendor_site_id is null
         AND    exists
		( select vendor_id
		  from   po_vendors
		  where  vendor_id = p_dup_vendor_id
		  and    nvl(end_date_active, sysdate+1) <= sysdate)
       	AND    not exists
		(select vendor_id
                 from po_asl_attributes poasl2
                 where poasl2.vendor_id      = p_vendor_id
                 and poasl2.vendor_site_id is null
                 and nvl(poasl2.item_id, -99) = nvl(poasl1.item_id, -99)
   	         and nvl(poasl2.category_id, -99) = nvl(poasl1.category_id, -99)
                 and poasl2.using_organization_id =
 					poasl1.using_organization_id);

         -- delete the approved_list_entry if the new vendor_id would make the
         -- record a duplicate.

         DELETE from po_asl_attributes poasl
         WHERE  vendor_id      = p_dup_vendor_id
 	 AND    vendor_site_id is null
         AND    exists
 		( select vendor_id
     	          from   po_vendors
 		  where  vendor_id = p_dup_vendor_id
 		  and    nvl(end_date_active, sysdate+1) <= sysdate) ;

	IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, 'updated PO_ASL_ATTRIBUTES');
        END IF;


         -- Prepare message name
         FND_MESSAGE.SET_NAME('PO','PO_ASL_ATTRIBUTES');
	 IF SQL%FOUND THEN
		x_return_status := FND_API.G_RET_STS_SUCCESS;
		l_row_count := SQL%ROWCOUNT;
	 ELSE
		x_return_status := FND_API.G_RET_STS_ERROR;
		l_row_count := 0;
	 END IF;
	 FND_MESSAGE.SET_TOKEN('ROWS_DELETED',l_row_count);
	 -- Add message to API message list.
	 FND_MSG_PUB.Add;


         -- Get message count and if 1, return message data.
	 FND_MSG_PUB.Count_And_Get
	 (  	p_count         	=>      x_msg_count,
		p_data          	=>      x_msg_data
	 );



     -- Call the iSP Vendor Merge API
     -- Commenting out POS calll as it would be called from AP directly
--   POS_SUP_PROF_MRG_GRP.handle_merge (
--                            p_new_vendor_id        => p_vendor_id,
--                            p_new_vendor_site_id   => p_vendor_site_id,
--                            p_old_vendor_id        => p_dup_vendor_id,
--                            p_old_vendor_site_id   => p_dup_vendor_site_id ,
--                            x_return_status        => x_return_status
--                            );

      -- Call the iP Vendor Merge API

     ICX_CAT_POPULATE_ITEM_GRP.populateVendorMerge(
                              p_api_version    => 1.0,
                              p_to_vendor_id => p_vendor_id,
                              p_to_site_id   => p_vendor_site_id,
                              p_from_vendor_id   => p_dup_vendor_id,
                              p_from_site_id     => p_dup_vendor_site_id,
                              x_return_status  => x_return_status
                              );



	 -- Standard check of p_commit.
	 IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	 END IF;

	 IF (PO_LOG.d_proc) THEN
              PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
              PO_LOG.proc_end(d_module);
          END IF;


EXCEPTION

                WHEN OTHERS THEN
                ROLLBACK;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	        IF (PO_LOG.d_proc) THEN
                   PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
                   PO_LOG.proc_end(d_module);
                END IF;

  		FND_MSG_PUB.Count_And_Get
    		       ( p_count         	=>      x_msg_count,
        		 p_data          	=>      x_msg_data
    		       );

END Merge_Vendor;

END PO_VendorMerge_GRP ;


/
