--------------------------------------------------------
--  DDL for Package Body GMD_QM_UOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_QM_UOM" AS
/* $Header: GMDQMUMB.pls 120.2 2005/10/07 11:57:48 jdiiorio noship $ */


  l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');


PROCEDURE VERIFY_EVENT(
   /* procedure to verify event and send out notifications*/
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2)

   IS
 l_event_name varchar2(240):=WF_ENGINE.GETITEMATTRTEXT(
                                                itemtype=>p_itemtype,
                                                itemkey=>P_itemkey,
                                                aname=>'EVENT_NAME');
 l_event_key varchar2(240):=WF_ENGINE.GETITEMATTRTEXT(
                                                itemtype=>p_itemtype,
                                                itemkey=>P_itemkey,
                                                aname=>'EVENT_KEY');

 l_current_approver varchar2(240);

 l_application_id number;
 l_transaction_type varchar2(100):='GMDQMUM';
 l_user varchar2(32);
 Approver ame_util.approverRecord;


   l_form varchar2(240);
   l_itemtype varchar2(240);
   l_itemkey varchar2(240);
   l_workflow_process varchar2(240);
   l_log varchar2(4000);
   I NUMBER;
   l_item_no varchar2(240);
   l_item_desc varchar2(240);
    l_lot_no varchar2(240);
    l_item_id number ;
   l_orgn_code varchar2(240);
   l_disposition varchar2(240);
   l_source varchar2(240);
   l_samples_taken number ;
   l_receipt_id number;
   l_receipt_line_id number;
   l_po_id number;
   l_po_line_id number;
   l_supplier_id number;
   l_supplier_lot varchar2(240);
   l_test_id number ;
   l_spec_id number ;
   l_from_uom varchar2(240);
   l_to_uom varchar2(240);
   l_from_uom_base varchar2(240);
   l_to_uom_base varchar2(240);
   l_current_conv number ;
   l_propose_conv number ;
   l_prop_conv_base number ;
   l_prop_conv_base_recip number ;
   l_test_name varchar2(240);
   l_spec_name varchar2(240);
   l_spec_vers varchar2(240);
   l_test_desc varchar2(240);
   l_supplier varchar2(240);
   l_po_num varchar2(240);
   l_po_line_num varchar2(240);
   l_receipt_num varchar2(240);
   l_receipt_line_num varchar2(240);
   l_created_by varchar2(240) := -1;
   l_mode number;
   l_lot_ctl number;
   l_owner number;
   l_uom_type varchar2(240);
   l_item_revision varchar2(240);
   l_subinventory varchar2(240);
   l_locator varchar2(240);
   l_parent_lot_no varchar2(240);
   l_orgn_id number;


 /* These cursors  Will Pick up all the info for a UOM conversion */

 Cursor C1 is

	SELECT  H.INVENTORY_ITEM_ID,
        	K.concatenated_segments, -- Item Number
		H.parent_lot_number,
        	K.description,
        	H.lot_number,
        	I.organization_code,
		H.organization_id,
		H.revision,
        	H.subinventory,
        	MIL.concatenated_segments , -- Locator
        	H.disposition,
        	h.source,
        	h.sample_taken_cnt,
		h.receipt_id,
        	H.RECEIPT_LINE_ID,
        	H.PO_HEADER_ID ,
	        H.PO_LINE_ID ,
        	H.SUPPLIER_ID ,
		H.SUPPLIER_LOT_NO ,
	        E.test_id ,
	        F.spec_id ,
	        E.from_qty_uom,
	        E.to_qty_uom,
		E.CURRENT_CONVERSION ,
	        E.PROPOSED_CONVERSION ,
	        E.from_qty_uom_base ,
	        E.to_qty_uom_base ,
		E.PROPOSED_CONVERSION_BASE,
                E.result_id
        from    GMD_UOM_CONVERSIONS E,
		gmd_event_spec_disp F,
		gmd_sampling_events H,
		mtl_parameters  I,
		mtl_item_locations_kfv MIL,
		mtl_system_items_kfv K
 	where   e.EVENT_SPEC_DISP_ID = l_event_key and
       		e.EVENT_SPEC_DISP_ID = f.event_spec_disp_id and
	   	f.sampling_event_id = h.SAMPLING_EVENT_ID and
       		I.organization_id = H.organization_id and
       		MIL.organization_id(+) = H.organization_id and
       		MIL.inventory_location_id(+) = H.locator_id and
       		K.organization_id = H.organization_id and
       		K.inventory_item_id = H.inventory_item_id and
       		e.recommended_ind = 'Y';

l_result_id                        NUMBER;

Cursor C2 (spec_id_in number) is
	select spec_name , spec_vers, owner_id
	from gmd_specifications
	where spec_id = spec_id_in ;

	Cursor C3 (test_id_in number) is
	select test_desc
	from gmd_qc_tests
	where test_id = test_id_in;

Cursor C4 (vendor_id_in number) is
	select vendor_name
	from po_vendors
	where vendor_id = vendor_id_in ;

Cursor C5 (po_header_in number) is
	select segment1
	from po_headers_all
	where po_header_id = po_header_in ;

Cursor C6 (po_line_in number) is
	select line_num
	from po_lines_all
	where po_line_id = po_line_in ;

Cursor C7 (receipt_in number) is
	select receipt_num
	from rcv_shipment_headers
	where shipment_header_id = receipt_in ;

Cursor C8 (receipt_line_in number) is
	select line_num
	from rcv_shipment_lines
	where shipment_line_id = receipt_line_in ;
-- SCHANDRU INVCONV  START


Cursor C9 (lot_number_in varchar2, org_id_in number,  item_id_in number,
           from_uom_in varchar2, to_uom_in varchar2) is
	select   conversion_id
	from MTL_LOT_UOM_CLASS_CONVERSIONS
        where inventory_item_id = item_id_in
        and   organization_id = org_id_in
	and   lot_number = lot_number_in
	and   from_uom_code = from_uom_in
	and   to_uom_code = to_uom_in;

l_conversion_id     mtl_lot_uom_class_conversions.conversion_id%TYPE;
-- JD changed query above to get exact conversion.

-- SCHANDRU INVCONV END

Cursor C10 (disp_in varchar2) is
       SELECT meaning
       FROM   fnd_lookup_values
       WHERE  lookup_TYPE = 'GMD_QC_SAMPLE_DISP'
       AND    language = USERENV('LANG')
       AND    lookup_code = disp_in ;


Cursor C11 (item_source_in varchar2) is
       SELECT description
       FROM   fnd_lookup_values
       WHERE  lookup_TYPE like 'GMD_QC_SOURCE'
       AND    language = USERENV('LANG')
       AND    lookup_code = item_source_in ;

Cursor C12 (mon_source_in varchar2) is
       SELECT description
       FROM   fnd_lookup_values
       WHERE  lookup_TYPE like 'GMD_QC_MONITOR_RULE_TYPE'
       AND    language = USERENV('LANG')
       AND    lookup_code = mon_source_in ;
--SCHANDRU INVCONV START
Cursor control (item_no_in number) is
        select LOT_CONTROL_CODE
        from mtl_system_items_kfv
        where inventory_item_id = item_no_in;

--SCHANDRU INVCONV END
cursor  get_child_lots (l_item_id_in number, l_organization_id_in number,l_parent_lot_number_in varchar2) is
	select 	lot_number
	from 	mtl_lot_numbers
	where 	parent_lot_number = l_parent_lot_number_in  and
      		organization_id = l_organization_id_in   and
      		inventory_item_id = l_item_id_in ;


cursor get_owner_name (owner_id_in number) is
       select user_name
	 from fnd_user
     	 where user_id = owner_id_in;

cursor get_uom_type (uom_code_in varchar2) is
	select UOM_CLASS from mtl_units_of_measure  -- SCHANDRU INVCONV
	where uom_code = uom_code_in ;


  cursor get_from_role is
     select nvl( text, '')
	from wf_Resources where name = 'WF_ADMIN_ROLE'
        and language = userenv('LANG')   ;

  l_from_role varchar2(240);
  l_conversion varchar2(2000);


 BEGIN


     IF (l_debug = 'Y') THEN
 	      gmd_debug.log_initialize('UomConv');
     END IF;

     IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Event Name ' || l_event_name);
       gmd_debug.put_line('Event Key ' || l_event_key);
     END IF;

	open get_from_role ;
	fetch get_from_role into l_from_role ;
	close get_from_role ;


    IF P_FUNCMODE='RUN' THEN
     /* Get application_id from FND_APPLICATION */
         select application_id into l_application_id
           from fnd_application where application_short_name='GMD';

      /* Check which event has been raised */
      wf_log_pkg.string(6, 'Dummy','Entered UOM Conversion with event_key '||l_event_key);

	  /* Check each UOM conversion which is recommended to send a notification */
          OPEN C1;
            LOOP
             	wf_log_pkg.string(6, 'Dummy','Before Fetching the values. Inside the Loop');


		IF (l_debug = 'Y') THEN
		       gmd_debug.put_line('Getting data from cursors ');
		END IF;


		Fetch C1 into   l_item_id,
              		      --l_lot_id,
               			l_item_no,
				l_parent_lot_no,
               			l_item_desc,
               			l_lot_no,
               		      --l_sublot_no,
               			l_orgn_code,
				l_orgn_id,
               			l_item_revision,
               			l_subinventory,--l_whse_code,
               			l_locator, --l_location,
               			l_disposition,
        	   		l_source,
               			l_samples_taken,
               			l_receipt_id,
              			l_receipt_line_id,
			   	l_po_id ,
               			l_po_line_id ,
               			l_supplier_id,
               			l_supplier_lot,
			   	l_test_id,
               			l_spec_id,
               			l_from_uom,
               			l_to_uom,
               			l_current_conv,
			   	l_propose_conv,
               			l_from_uom_base,
               			l_to_uom_base,
			   	l_prop_conv_base,
                                l_result_id;
             	EXIT when C1%notfound;


		open C2 (l_spec_id);
			fetch C2 into l_spec_name , l_spec_vers, l_owner;
		close C2;

		open C3(l_test_id);
			fetch C3 into l_test_name;
		close C3;

		open C4(l_supplier_id);
			fetch C4 into l_supplier;
		close C4;

		open C5(l_po_id);
			fetch C5 into l_po_num;
		close C5;

		open C6(l_po_line_id);
			fetch C6 into l_po_line_num;
		close C6;

		open C7(l_receipt_id);
			fetch C7 into l_receipt_num;
		close C7;

		open C8(l_receipt_line_id);
			fetch C8 into l_receipt_line_num;
		close C8;

		open C10(l_disposition);
			fetch C10 into l_disposition;
		close C10;

		open control (l_item_id);
			fetch control into l_lot_ctl;
		close control;

		open get_owner_name (l_owner);
			fetch get_owner_name into l_user;
		close get_owner_name;


		IF (l_debug = 'Y') THEN
		       gmd_debug.put_line('l_source ' || l_source);
		END IF;

		if (l_source = 'R') or (l_source = 'L') then
		/* Resource source */
			open C12(l_source);
				fetch C12 into l_source;
			close C12;
		else
		/* Item source */
			open C11 (l_source);
				fetch C11 into l_source;
			close C11 ;
		end if ;



		open get_uom_type (l_to_uom);
			fetch get_uom_type into l_uom_type ;
		close get_uom_type;

		--BUG#3676227
		l_prop_conv_base_recip :=to_number(substr(to_char(1.0 / l_prop_conv_base),1,30));

		IF (l_debug = 'Y') THEN
		       gmd_debug.put_line('checking approvers ');
		END IF;

              	/* Start the Workflow for the Given Combination */
              	ame_api.clearAllApprovals(applicationIdIn =>   l_application_id,
                                        transactionIdIn =>   l_event_key,
                                        transactionTypeIn => l_transaction_type);

              	wf_log_pkg.string(6, 'Dummy','Approvers Cleared');
              	ame_api.getNextApprover(applicationIdIn => l_application_id,
                                      transactionIdIn => l_event_key,
                                      transactionTypeIn => l_transaction_type,
                                      nextApproverOut => Approver);

      		if(Approver.user_id is null and Approver.person_id is null) then
       			/* No Approval Required so default to owner*/
       			 null ;
      		elsif(Approver.person_id is null) then
      			  select user_name into l_user from fnd_user
        			 where user_id=Approver.user_id;
     		 	else
	       		  select user_name into l_user from fnd_user
        	             where user_id=ame_util.PERSONIDTOUSERID(Approver.person_id);
                	end if;

		IF (l_debug = 'Y') THEN
		       gmd_debug.put_line('User Name ' || l_user);
		END IF;

		/* In the case there is a lot_id, we should send a notification. in the
		   case there is a lot_no with not sublot_no but item is not sublot
    		   controlled then also send a notification. In the case there is a lot_no
                   specified but no sublot_no but the item is sublot controlled then need
		   to loop through each of the sublots and send a different notification */
		if (l_lot_no is not null ) then

			IF (l_debug = 'Y') THEN
			       gmd_debug.put_line('Case where lot defined and not sublot ctrl ');
			END IF;

			/* Need to check if UOM conversion already exists */
                        l_conversion_id := NULL;
			open C9 (l_lot_no, l_orgn_id, l_item_id, l_from_uom, l_to_uom);
				fetch C9 into l_conversion_id;
				if (l_conversion_id IS NOT NULL) THEN
					l_mode := 1;
				else
					l_mode := 0;
				end if;
			close C9 ;

	             	/* Set Form Attribute to the sampling event */
	             	-- BUG#3315141 Sastry
	             	-- Passed l_prop_conv_base_recip for type_factor
                        -- JD changed to converged form function





            -- JD changed parm list.

        	     	l_form := 'INVSDLUC_F: CONV_MODE="'||l_mode||'"'||' CONV_ID="'||l_conversion_id||'"'||' RID="'||l_result_id||'"'||' C_RATE="'||l_prop_conv_base_recip||'"'||' EVT_DISPID="'||l_event_key||'"';


	                     l_itemtype:='GMDQMUOM';
        	             l_itemkey:=l_event_key||'-'||to_char(sysdate,'dd/mm/yy hh:mi:ss');

	                     l_workflow_process:='GMDQMUOM_SUB_PROCESS';

	                     WF_ENGINE.CREATEPROCESS (itemtype => l_itemtype,
	                                     itemkey => l_itemkey,
        	                             process =>    l_workflow_process );

		         /* Set the User Attribute */

			  WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,itemkey => p_itemkey,
         					  aname => '#FROM_ROLE',
         					  avalue => l_user );

	        	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype, itemkey => l_itemkey,
         					  aname => 'CURRENT_APPROVER',
         					  avalue => l_user);
        	            WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'APPS_FORM',
         					  avalue =>l_form );
	       		/* Set All other Attributes */
			  -- SCHANDRU INVCONV START

        		  WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,itemkey => p_itemkey,
	                                              aname => 'ITEM_REVISION',
                                                  avalue =>l_item_revision );
        		  WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,itemkey => l_itemkey,
	                                              aname => 'ITEM_REVISION',
                                                  avalue =>l_item_revision );
			   -- SCHANDRU INVCONV END

			    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'EVENT_KEY',
         						  avalue =>l_event_key );
                	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => p_itemkey,
        	 					  aname => 'EVENT_NAME',
         						  avalue =>l_event_name );

	        	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'SOURCE',
         						  avalue =>l_source );
        		    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'SAMPLES_TAKEN',
         						  avalue =>l_samples_taken );
        		    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'SAMPLE_GRP_DISP',
         						  avalue =>l_disposition );
	        	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'ITEM_NO',
         						  avalue =>l_item_no );
        		    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'LOT_NO',
         						  avalue =>l_lot_no );

	        	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'ORGANIZATION',
         						  avalue =>l_orgn_code );
        		    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'SUBINVENTORY',
         						  avalue =>l_subinventory );
        		    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'LOCATOR',
         						  avalue =>l_locator );
	        	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'SUPPLIER',
         						  avalue =>l_supplier );
        		    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'SUPPLIER_LOT',
         						  avalue =>l_supplier_lot );
        		    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'PO_NUMBER',
         						  avalue =>l_po_num );
	        	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'PO_LINE_NO',
         						  avalue =>l_po_line_num );
	        	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'RECEIPT_NO',
         						  avalue =>l_receipt_num );
        		    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'RECEIPT_LINE_NO',
         						  avalue =>l_receipt_line_num );
        		    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'SPEC',
         						  avalue =>l_spec_name );
	        	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'SPEC_VERSION',
         						  avalue =>l_spec_vers );
        		    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'TEST_NAME',
         						  avalue =>l_test_name );
        		    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'FROM_UOM',
         						  avalue =>l_from_uom );
	        	    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'PROPOSED_CONVERSION',
         						  avalue =>l_propose_conv );
        		    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         						  aname => 'TO_UOM',
         						  avalue =>l_TO_UOM );

			    l_conversion := '1 '|| l_from_uom || ' = ' || l_propose_conv || ' ' || l_TO_UOM ;
        		    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
							  itemkey => l_itemkey,
         						  aname => 'CONVERSION',
         						  avalue => l_conversion );


        		    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'AME_TRANS',
         					  avalue =>l_transaction_type);


	                    wf_log_pkg.string(6, 'Dummy','Setting Parent');


        	            WF_ENGINE.SETITEMPARENT(itemtype =>l_itemtype,itemkey =>l_itemkey,
                                         parent_itemtype => p_itemtype,
                                         parent_itemkey=> p_itemkey,
                                         parent_context=> NULL);

	                   /* start the Workflow process */
        	            wf_log_pkg.string(6, 'Dummy','Starting Process');

		       /* As this a pure FYI notification we will set the approver to approve status */
        		  Approver.approval_status := ame_util.approvedStatus;
	        	  ame_api.updateApprovalStatus(applicationIdIn => l_application_id,
                                       transactionIdIn => l_event_key,
                                       approverIn => Approver,
                                       transactionTypeIn => l_transaction_type,
                                       forwardeeIn => ame_util.emptyApproverRecord);


	        	   WF_ENGINE.STARTPROCESS (itemtype => l_itemtype,itemkey => l_itemkey);


			elsif(l_parent_lot_no is not null) then

				IF (l_debug = 'Y') THEN
				       gmd_debug.put_line('Case where lot not defined ');
				END IF;
				open get_child_lots (l_item_id, l_orgn_id,l_parent_lot_no);

				loop
					fetch get_child_lots into l_lot_no;
					EXIT when get_child_lots%notfound;

					/* Need to check if UOM conversion already exists */
                                        l_conversion_id := NULL;
			                open C9 (l_lot_no, l_orgn_id, l_item_id, l_from_uom, l_to_uom);
						fetch C9 into l_conversion_id;
						if (l_conversion_id IS NOT NULL) then
							l_mode := 1;
						else
							l_mode := 0;
						end if;
					close C9 ;

				/* Set Form Attribute to the sampling event */
				-- BUG#3315141 Sastry
	             	        -- Passed l_prop_conv_base_recip for type_factor



        	     	l_form := 'INVSDLUC_F: CONV_MODE="'||l_mode||'"'||' CONV_ID="'||l_conversion_id||'"'||' RID="'||l_result_id||'"'||' C_RATE="'||l_prop_conv_base_recip||'"'||' EVT_DISPID="'||l_event_key||'"';



				     l_itemtype:='GMDQMUOM';
				     l_itemkey:=l_event_key||'-'||to_char(sysdate,'dd/mm/yy hh:mi:ss');

				     l_workflow_process:='GMDQMUOM_SUB_PROCESS';

				     WF_ENGINE.CREATEPROCESS (itemtype => l_itemtype,
						     itemkey => l_itemkey,
						     process =>    l_workflow_process );

				 /* Set the User Attribute */

				    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype, itemkey => l_itemkey,
							  aname => 'CURRENT_APPROVER',
							  avalue => l_user);
				    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
							  aname => 'APPS_FORM',
							  avalue =>l_form );
	 			    WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,itemkey => p_itemkey,
         					  aname => '#FROM_ROLE',
         					  avalue => l_user );


				/* Set All other Attributes */
	                           -- SCHANDRU INVCONV START
				   WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,itemkey => p_itemkey,
	                                              aname => 'ITEM_REVISION',
                                                  avalue =>l_item_revision );
				     -- SCHANDRU INVCONV END
				    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
								  aname => 'EVENT_KEY',
								  avalue =>l_event_key );
				    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => p_itemkey,
								  aname => 'EVENT_NAME',
								  avalue =>l_event_name );

				    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
								  aname => 'SOURCE',
								  avalue =>l_source );
				    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
								  aname => 'SAMPLES_TAKEN',
								  avalue =>l_samples_taken );
				    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
								  aname => 'SAMPLE_GRP_DISP',
								  avalue =>l_disposition );
				    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
								  aname => 'ITEM_NO',
								  avalue =>l_item_no );
				    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
								  aname => 'LOT_NO',
								  avalue =>l_lot_no );

				    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
								  aname => 'ORGANIZATION',
								  avalue =>l_orgn_code );
				    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
								  aname => 'SUBINVENTORY',
								  avalue =>l_subinventory );
				    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
								  aname => 'LOCATOR',
								  avalue =>l_locator );
				    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
								  aname => 'SUPPLIER',
								  avalue =>l_supplier );
				    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
								  aname => 'SUPPLIER_LOT',
								  avalue =>l_supplier_lot );
				    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
								  aname => 'PO_NUMBER',
								  avalue =>l_po_num );
				    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
								  aname => 'PO_LINE_NO',
								  avalue =>l_po_line_num );
				    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
								  aname => 'RECEIPT_NO',
								  avalue =>l_receipt_num );
				    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
								  aname => 'RECEIPT_LINE_NO',
								  avalue =>l_receipt_line_num );
				    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
								  aname => 'SPEC',
								  avalue =>l_spec_name );
				    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
								  aname => 'SPEC_VERSION',
								  avalue =>l_spec_vers );
				    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
								  aname => 'TEST_NAME',
								  avalue =>l_test_name );
				    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
								  aname => 'FROM_UOM',
								  avalue =>l_from_uom );
				    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
								  aname => 'PROPOSED_CONVERSION',
								  avalue =>l_propose_conv );
				    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
								  aname => 'TO_UOM',
								  avalue =>l_TO_UOM );
				    l_conversion := '1 '|| l_from_uom || ' = ' || l_propose_conv
							|| ' ' || l_TO_UOM ;
	        		    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
							  itemkey => l_itemkey,
         						  aname => 'CONVERSION',
         						  avalue => l_conversion );

				    WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
							  aname => 'AME_TRANS',
							  avalue =>l_transaction_type);


				    wf_log_pkg.string(6, 'Dummy','Setting Parent');


				    WF_ENGINE.SETITEMPARENT(itemtype =>l_itemtype,itemkey =>l_itemkey,
						 parent_itemtype => p_itemtype,
						 parent_itemkey=> p_itemkey,
						 parent_context=> NULL);

				   /* start the Workflow process */
				    wf_log_pkg.string(6, 'Dummy','Starting Process');

			       /* As this a pure FYI notification we will set the approver to approve status */
				  Approver.approval_status := ame_util.approvedStatus;
				  ame_api.updateApprovalStatus(applicationIdIn => l_application_id,
					       transactionIdIn => l_event_key,
					       approverIn => Approver,
					       transactionTypeIn => l_transaction_type,
					       forwardeeIn => ame_util.emptyApproverRecord);


				   WF_ENGINE.STARTPROCESS (itemtype => l_itemtype,itemkey => l_itemkey);


				end loop ;
				close get_child_lots;
			end if;


      END LOOP;
      CLOSE C1;

    END IF;
commit ;

     p_resultout:='COMPLETE:';

  EXCEPTION

      WHEN OTHERS THEN
      WF_CORE.CONTEXT ('GMD_QMU_OM','VERIFY_EVENT',p_itemtype,p_itemkey,l_log );
      raise;

  END VERIFY_EVENT;



PROCEDURE CHECK_NEXT_APPROVER(
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2)

   IS
 l_event_name varchar2(240):=WF_ENGINE.GETITEMATTRTEXT(
                                                itemtype=>p_itemtype,
                                                itemkey=>P_itemkey,
                                                aname=>'EVENT_NAME');
 l_event_key varchar2(240):=WF_ENGINE.GETITEMATTRTEXT(
                                                itemtype=>p_itemtype,
                                                itemkey=>P_itemkey,
                                                aname=>'EVENT_KEY');

 l_current_approver varchar2(240);

 l_application_id number;
 l_transaction_type varchar2(100):=WF_ENGINE.GETITEMATTRTEXT(
                                                itemtype=>p_itemtype,
                                                itemkey=>P_itemkey,
                                                aname=>'AME_TRANS');
 l_user varchar2(32);
 Approver ame_util.approverRecord;
 l_form varchar2(240);
 BEGIN

    /* Get Next Approver */
        /* Get application_id from FND_APPLICATION */
         select application_id into l_application_id
           from fnd_application where application_short_name='GMD';

       ame_api.getNextApprover(applicationIdIn => l_application_id,
                              transactionIdIn => l_event_key,
                              transactionTypeIn => l_transaction_type,
                              nextApproverOut => Approver);


     if(Approver.user_id is null and Approver.person_id is null) then
       /* No Approval Required */
        P_resultout:='COMPLETE:N';
     else
       if(Approver.person_id is null) then
         select user_name into l_user from fnd_user
           where user_id=Approver.user_id;
       else
         select user_name into l_user from fnd_user
          where user_id=ame_util.PERSONIDTOUSERID(Approver.person_id);
        end if;

         /* Set the User Attribute */

         WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,itemkey => p_itemkey,
         					  aname => 'CURRENT_APPROVER',
         					  avalue => l_user);

         P_resultout:='COMPLETE:Y';
          Approver.approval_status := ame_util.approvedStatus;
          ame_api.updateApprovalStatus(applicationIdIn => l_application_id,
                                       transactionIdIn => l_event_key,
                                       approverIn => Approver,
                                       transactionTypeIn => l_transaction_type,
                                       forwardeeIn => ame_util.emptyApproverRecord);
     end if;
  EXCEPTION
      WHEN OTHERS THEN
      WF_CORE.CONTEXT ('GMD_QMUOM','CHECK_NEXT_APPROVER',p_itemtype,p_itemkey,'Initial' );
      raise;

  END CHECK_NEXT_APPROVER;


END;

/
