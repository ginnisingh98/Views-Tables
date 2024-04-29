--------------------------------------------------------
--  DDL for Package Body GMD_AUTO_SAMPLE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_AUTO_SAMPLE_PKG" AS
/* $Header: GMDQMASB.pls 120.7 2007/10/24 04:40:21 smalluru ship $ */

PROCEDURE create_samples (x_sampling_event GMD_SAMPLING_EVENTS%ROWTYPE,
		L_spec_id  number,
		L_spec_vr_id number,
		X_return_status OUT NOCOPY varchar2) IS

	p_sample           GMD_SAMPLES%ROWTYPE;
	x_sample           GMD_SAMPLES%ROWTYPE;
	p_event_spec_disp  GMD_EVENT_SPEC_DISP%ROWTYPE;
	x_event_spec_disp  GMD_EVENT_SPEC_DISP%ROWTYPE;
	p_sample_spec_disp  GMD_SAMPLE_SPEC_DISP%ROWTYPE;
	x_sample_spec_disp  GMD_SAMPLE_SPEC_DISP%ROWTYPE;
	smp_cnt binary_integer;
	l_reserve_cnt_req number := 0;
	l_archive_cnt_req number := 0;
	l_sample_cnt_req number := 0;
	l_sample_cnt_req2 number := 0; -- Bug 4896237
	sample_instance number := 0;
	l_sample_qty number := 0;
	l_sample_qty_uom varchar2(10) ;
	l_reserve_qty number := 0 ;
	l_archive_qty number := 0 ;
	l_log varchar2(4000);
	l_inv_trans_ind varchar2(2) := 'N' ;

        -- Bug 4165704: new item table used for inventory convergence
	cursor get_item_desc (x_inventory_item_id number) is
		   --select nvl(item_desc1, '')
		   --from ic_item_mst
		   --where item_id = x_item_id_in ;
                SELECT  nvl(description, '')
                FROM     mtl_system_items_b_kfv
                WHERE    organization_id     = x_sampling_event.organization_id
                  AND    inventory_item_id   = x_inventory_item_id;

	cursor sampling_plan_info (x_sampling_plan_id number) is
		select nvl(sample_cnt_req, 0) sample_cnt_req,
			nvl(RESERVE_CNT_REQ, 0) reserve_cnt_req,
			nvl(ARCHIVE_CNT_REQ,0) archive_cnt_req,
			nvl(sample_qty, 0) sample_qty, sample_qty_uom,
			nvl(RESERVE_QTY, 0) reserve_qty,
			nvl(ARCHIVE_QTY,0) archive_qty
		from gmd_sampling_plans_b sm
		where sm.sampling_plan_id = x_sampling_plan_id ;

-- bug 4924526  SQL Id 14689707  -   fix this  13,582,446  shared memory FTS -
       cursor get_vr_info (x_spec_vr_id number) is
	/*	select nvl (SAMPLE_INV_TRANS_IND, 'N') SAMPLE_INV_TRANS_IND
		from gmd_all_spec_vrs
		where spec_vr_id = x_spec_vr_id ; */
SELECT nvl (v.SAMPLE_INV_TRANS_IND, 'N') SAMPLE_INV_TRANS_IND
FROM GMD_INVENTORY_SPEC_VRS V ,
     GMD_SPECIFICATIONS_B S ,
     MTL_SYSTEM_ITEMS_KFV I ,
     GMD_QC_STATUS_TL T ,
     GMD_QC_STATUS_TL P
WHERE V.SPEC_ID = S.SPEC_ID
  AND S.OWNER_ORGANIZATION_ID = I.ORGANIZATION_ID
  AND S.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
  AND V.SPEC_VR_STATUS = T.STATUS_CODE
  AND T.ENTITY_TYPE = 'S'
  AND T.LANGUAGE = USERENV ( 'LANG' )
  AND S.SPEC_STATUS = P.STATUS_CODE
  AND P.ENTITY_TYPE = 'S'
  AND P.LANGUAGE = USERENV ( 'LANG' )
  and v.spec_vr_id = x_spec_vr_id
UNION
SELECT nvl (v.SAMPLE_INV_TRANS_IND, 'N') SAMPLE_INV_TRANS_IND
FROM GMD_WIP_SPEC_VRS V ,
     GMD_SPECIFICATIONS_B S ,
     MTL_SYSTEM_ITEMS_KFV I ,
     GMD_QC_STATUS_TL T ,
     GMD_QC_STATUS_TL P
WHERE V.SPEC_ID = S.SPEC_ID
  AND I.ORGANIZATION_ID = S.OWNER_ORGANIZATION_ID
  AND I.INVENTORY_ITEM_ID = S.INVENTORY_ITEM_ID
  AND V.SPEC_VR_STATUS = T.STATUS_CODE
  AND T.ENTITY_TYPE = 'S'
  AND T.LANGUAGE = USERENV ( 'LANG' )
  AND S.SPEC_STATUS = P.STATUS_CODE
  AND P.ENTITY_TYPE = 'S'
  AND P.LANGUAGE = USERENV ( 'LANG' )
  and v.spec_vr_id = x_spec_vr_id
UNION
SELECT nvl (v.SAMPLE_INV_TRANS_IND, 'N') SAMPLE_INV_TRANS_IND
FROM GMD_CUSTOMER_SPEC_VRS V ,
     GMD_SPECIFICATIONS_B S ,
     MTL_SYSTEM_ITEMS_KFV I ,
     GMD_QC_STATUS_TL T ,
     GMD_QC_STATUS_TL P
WHERE V.SPEC_ID = S.SPEC_ID
  AND S.OWNER_ORGANIZATION_ID = I.ORGANIZATION_ID
  AND S.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
  AND V.SPEC_VR_STATUS = T.STATUS_CODE
  AND T.ENTITY_TYPE = 'S'
  AND T.LANGUAGE = USERENV ( 'LANG' )
  AND S.SPEC_STATUS = P.STATUS_CODE --  NEW
 AND P.ENTITY_TYPE = 'S' --  NEW
AND P.LANGUAGE = USERENV ( 'LANG' ) --  NEW
and v.spec_vr_id = x_spec_vr_id
UNION
SELECT nvl (v.SAMPLE_INV_TRANS_IND, 'N') SAMPLE_INV_TRANS_IND
FROM GMD_SUPPLIER_SPEC_VRS V ,
     GMD_SPECIFICATIONS_B S ,
     MTL_SYSTEM_ITEMS_KFV I ,
     GMD_QC_STATUS_TL T ,
     GMD_QC_STATUS_TL P
WHERE V.SPEC_ID = S.SPEC_ID
  AND S.OWNER_ORGANIZATION_ID = I.ORGANIZATION_ID
  AND S.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
  AND V.SPEC_VR_STATUS = T.STATUS_CODE
  AND T.ENTITY_TYPE = 'S'
  AND T.LANGUAGE = USERENV ( 'LANG' )
  AND S.SPEC_STATUS = P.STATUS_CODE
  AND P.ENTITY_TYPE = 'S'
  AND P.LANGUAGE = USERENV ( 'LANG' )
  and v.spec_vr_id = x_spec_vr_id
UNION
SELECT 'N' SAMPLE_INV_TRANS_IND
FROM GMD_MONITORING_SPEC_VRS V ,
     GMD_SPECIFICATIONS_B S ,
     GMD_QC_STATUS_TL P ,
     GMD_QC_STATUS_TL T
WHERE V.SPEC_ID = S.SPEC_ID
  AND V.SPEC_VR_STATUS = T.STATUS_CODE
  AND T.ENTITY_TYPE = 'S'
  AND T.LANGUAGE = USERENV ( 'LANG' )
  AND S.SPEC_STATUS = P.STATUS_CODE
  AND P.ENTITY_TYPE = 'S'
  AND P.LANGUAGE = USERENV ( 'LANG' )
  and v.spec_vr_id = x_spec_vr_id
UNION
SELECT 'N' SAMPLE_INV_TRANS_IND
FROM GMD_STABILITY_SPEC_VRS V ,
     GMD_SPECIFICATIONS_B S ,
     GMD_QC_STATUS_TL T ,
     GMD_QC_STATUS_TL L
WHERE V.SPEC_ID = S.SPEC_ID
  AND V.SPEC_VR_STATUS = T.STATUS_CODE
  AND S.SPEC_STATUS = L.STATUS_CODE
  AND T.ENTITY_TYPE = 'S'
  AND L.ENTITY_TYPE = 'S'
  AND T.LANGUAGE = USERENV ( 'LANG' )
  AND L.LANGUAGE = USERENV ( 'LANG' )
  and v.spec_vr_id = x_spec_vr_id;

BEGIN

	/* Update created sampling event */
	p_event_spec_disp.sampling_event_id := x_sampling_event.sampling_event_id;
	p_event_spec_disp.SAMPLING_EVENT_ID:= x_sampling_event.sampling_event_id;
	p_event_spec_disp.SPEC_ID     	:= l_spec_id;
	p_event_spec_disp.SPEC_VR_ID  	:= l_spec_vr_id;
	p_event_spec_disp.DISPOSITION   := '0PL';
	p_event_spec_disp.SPEC_USED_FOR_LOT_ATTRIB_IND := 'Y';
	p_event_spec_disp.DELETE_MARK := 0;
	p_event_spec_disp.CREATION_DATE := sysdate;
	p_event_spec_disp.CREATED_BY := FND_GLOBAL.USER_ID;
	p_event_spec_disp.LAST_UPDATE_DATE := sysdate;
	p_event_spec_disp.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;


        IF NOT GMD_EVENT_SPEC_DISP_PVT.insert_row(
      		   p_event_spec_disp =>p_event_spec_disp,
                   x_event_spec_disp =>x_event_spec_disp) THEN
               RAISE FND_API.G_EXC_ERROR;
        END IF;


	open get_vr_info (l_spec_vr_id) ;
	fetch get_vr_info into l_inv_trans_ind ;
	close get_vr_info ;

	open sampling_plan_info (x_Sampling_event.sampling_plan_id );
	fetch sampling_plan_info into l_sample_cnt_req2, l_reserve_cnt_req, l_archive_cnt_req,
	l_sample_qty, l_sample_qty_uom, l_reserve_qty, l_archive_qty;
	close sampling_plan_info ;

	-- Bug 4896237. svankada. Use l_sample_cnt_req from x_sampling_event passed as that has reference to transaction
	-- quantities for quantity based sampling plans.
	l_sample_cnt_req := x_sampling_event.sample_req_cnt;
	IF NVL(l_sample_cnt_req , 0) = 0 THEN
	  l_sample_cnt_req := l_sample_cnt_req2;
	END IF;
	-- End Bug 4896237. svankada

	FOR smp_cnt in 1..l_sample_cnt_req  LOOP
	/* Create a Regular sample */
	sample_instance := sample_instance + 1;
	p_sample.sampling_event_id   :=  x_sampling_event.sampling_event_id;
	p_sample.sample_qty          := l_sample_qty;
	p_sample.sample_qty_uom       := l_sample_qty_uom;
	p_sample.sample_inv_trans_ind :=  l_inv_trans_ind ;
	p_sample.source               := x_sampling_event.source;
	p_sample.sample_type          := 'I';
	p_sample.retain_as            := NULL;
                    -- Bug 4165704: sample no now taken from quality parameters table
		    -- p_sample.sample_no  :=
	            -- 		GMA_GLOBAL_GRP.Get_Doc_No('SMPL', x_sampling_event.ORGN_CODE);
        p_sample.sample_no            := GMD_QUALITY_PARAMETERS_GRP.get_next_sample_no(x_sampling_event.organization_id);
	p_Sample.inventory_item_id := x_sampling_event.inventory_item_id ;
	p_Sample.revision          := x_sampling_event.revision;
        p_sample.delete_mark        := 0;
        p_sample.creation_date      := sysdate;
        p_sample.created_by         := FND_GLOBAL.USER_ID;
        p_sample.last_update_date   := sysdate;
        p_sample.last_updated_by    := FND_GLOBAL.USER_ID;
	p_sample.sampler_id         := FND_GLOBAL.USER_ID;

	p_sample.priority           := '5N' ;
	p_sample.remaining_qty      := p_sample.sample_qty;

        --RLNAGARA B5463399 Commented the below line and added next line so that the correct operating unit get populated.
        --p_sample.org_id             := p_sample.org_id;
	p_sample.org_id             := x_sampling_event.org_id;

     	p_sample.source 	    :=	x_sampling_event.source   ;
        p_sample.supplier_id 	    :=  x_sampling_event.supplier_id   ;
        p_sample.supplier_site_id   :=  x_sampling_event.supplier_site_id   ;
        p_sample.po_header_id 	    :=  x_sampling_event.po_header_id  ;
        p_sample.po_line_id 	    :=  x_sampling_event.po_line_id   ;
     	p_sample.sample_type 	    :=	x_sampling_event.sample_type  ;
        p_sample.organization_id    :=  x_sampling_event.organization_id    ;
        p_sample.receipt_id 	    :=  x_sampling_event.receipt_id   ; /*Bug 3378697*/
        p_sample.receipt_line_id    :=  x_sampling_event.receipt_line_id ; /*Bug 3378697*/
        p_sample.lot_number 	    :=  x_sampling_event.lot_number       ;
        p_sample.parent_lot_number  :=  x_sampling_event.parent_lot_number    ;
        p_sample.supplier_lot_no    :=  x_sampling_event.supplier_lot_no; --Bug#6491872
       	--srakrish bug 5844806: Populating the WIP fields properly.
        --p_sample.subinventory     :=  x_sampling_event.subinventory     ;
     	--p_sample.locator_id  	    :=	x_sampling_event.locator_id     ;
	IF x_sampling_event.source = 'W' THEN
           p_sample.source_locator_id  	    :=	x_sampling_event.locator_id     ;
           p_sample.source_subinventory     :=  x_sampling_event.subinventory     ;
        ELSE
           p_sample.locator_id  	    :=	x_sampling_event.locator_id     ;
           p_sample.subinventory 	    :=  x_sampling_event.subinventory     ;
        END IF;
        p_sample.lot_retest_ind     :=  x_sampling_event.lot_retest_ind    ;
     	p_sample.batch_ID 	    :=	x_sampling_event.batch_ID    ;
     	p_sample.recipe_ID 	    :=	x_sampling_event.recipe_ID    ;
     	p_sample.formula_id 	    :=	x_sampling_event.formula_id    ;
     	p_sample.formulaline_id     :=	x_sampling_event.formulaline_id    ;
     	p_sample.material_detail_id :=	x_sampling_event.material_detail_id    ;
     	p_sample.routing_id 	    :=	x_sampling_event.routing_id   ;
     	p_sample.step_id 	    :=	x_sampling_event.step_id      ;
     	p_sample.step_no 	    :=	x_sampling_event.step_no      ;
     	p_sample.oprn_id 	    :=	x_sampling_event.oprn_id      ;
     	p_sample.sample_disposition :=	'0PL' ;
		/* Get item Desc and default it in sample */
		open get_item_desc (x_sampling_event.inventory_item_id) ;
		fetch get_item_desc into p_sample.sample_desc ;
		close get_item_desc;

		p_sample.sample_instance    := sample_instance;
		IF not GMD_SAMPLES_PVT.insert_row (
                                 p_sample,  x_sample )      THEN
                           raise fnd_api.g_exc_error;
		END IF;

		p_sample_spec_disp.sample_id  := x_sample.sample_id;
		p_sample_spec_disp.event_spec_disp_id := x_event_spec_disp.event_spec_disp_id;
		p_sample_spec_disp.disposition        := '0PL';
                p_sample_spec_disp.delete_mark        := 0;
                p_sample_spec_disp.creation_date      := sysdate;
                p_sample_spec_disp.created_by         := FND_GLOBAL.USER_ID;
                p_sample_spec_disp.last_update_date   := sysdate;
                p_sample_spec_disp.last_updated_by    := FND_GLOBAL.USER_ID;

		IF not GMD_SAMPLE_SPEC_DISP_PVT.insert_row  (
                            p_sample_spec_disp  )    THEN
	                          raise fnd_api.g_exc_error;
		END IF;
    --gml_sf_log('creating sample');
	END LOOP;

	FOR smp_cnt in 1..l_archive_cnt_req  LOOP
	/* Create a Archive sample */
		sample_instance := sample_instance + 1;
		p_sample.sample_qty := l_archive_qty;
		p_sample.sample_qty_uom := l_sample_qty_uom;
		p_sample.sample_inv_trans_ind :=  l_inv_trans_ind ;
		p_sample.sampling_event_id   :=  x_sampling_event.sampling_event_id;
                    -- Bug 4165704: sample no now taken from quality parameters table
		    -- p_sample.sample_no  :=
	            -- 		GMA_GLOBAL_GRP.Get_Doc_No('SMPL', x_sampling_event.ORGN_CODE);
                p_sample.sample_no            := GMD_QUALITY_PARAMETERS_GRP.get_next_sample_no(x_sampling_event.organization_id);
		p_Sample.inventory_item_id := x_sampling_event.inventory_item_id ;
		p_Sample.revision          := x_sampling_event.revision;
                p_sample.delete_mark        := 0;
                p_sample.creation_date      := sysdate;
                p_sample.created_by         := FND_GLOBAL.USER_ID;
                p_sample.last_update_date   := sysdate;
                p_sample.last_updated_by    := FND_GLOBAL.USER_ID;
		p_sample.sampler_id         := FND_GLOBAL.USER_ID;

		p_sample.priority           := '5N' ;
		p_sample.remaining_qty      := p_sample.sample_qty;
                --RLNAGARA B5463399 Commented the below line and added next line so that the correct operating unit get populated.
                --p_sample.org_id             := p_sample.org_id;
                p_sample.org_id             := x_sampling_event.org_id;

     		p_sample.source 	    :=	x_sampling_event.source   ;
                p_sample.supplier_id 	    :=  x_sampling_event.supplier_id   ;
                p_sample.supplier_site_id   :=  x_sampling_event.supplier_site_id   ;
                p_sample.po_header_id 	    :=  x_sampling_event.po_header_id  ;
                p_sample.po_line_id 	    :=  x_sampling_event.po_line_id   ;
     		p_sample.sample_type 	    :=	x_sampling_event.sample_type  ;
                p_sample.organization_id    :=  x_sampling_event.organization_id    ;
                p_sample.receipt_id 	    :=  x_sampling_event.receipt_id   ;
                p_sample.receipt_line_id    :=  x_sampling_event.receipt_line_id   ;
                p_sample.lot_number 	    :=  x_sampling_event.lot_number       ;
                p_sample.parent_lot_number  :=  x_sampling_event.parent_lot_number    ;
                p_sample.supplier_lot_no    :=  x_sampling_event.supplier_lot_no; --Bug#6491872
		--srakrish bug 5844806: Populating the WIP fields properly.
	        --p_sample.subinventory     :=  x_sampling_event.subinventory     ;
	     	--p_sample.locator_id  	    :=	x_sampling_event.locator_id     ;
		IF x_sampling_event.source = 'W' THEN
	           p_sample.source_locator_id  	    :=	x_sampling_event.locator_id     ;
  	           p_sample.source_subinventory     :=  x_sampling_event.subinventory     ;
		ELSE
		   p_sample.locator_id  	    :=	x_sampling_event.locator_id     ;
		   p_sample.subinventory 	    :=  x_sampling_event.subinventory     ;
		END IF;
		p_sample.lot_retest_ind     :=  x_sampling_event.lot_retest_ind    ;
     		p_sample.batch_ID 	    :=	x_sampling_event.batch_ID    ;
     		p_sample.recipe_ID 	    :=	x_sampling_event.recipe_ID    ;
     		p_sample.formula_id 	    :=	x_sampling_event.formula_id    ;
     		p_sample.formulaline_id     :=	x_sampling_event.formulaline_id    ;
     	        p_sample.material_detail_id :=	x_sampling_event.material_detail_id    ;
     		p_sample.routing_id 	    :=	x_sampling_event.routing_id   ;
     		p_sample.step_id 	    :=	x_sampling_event.step_id      ;
     		p_sample.step_no 	    :=	x_sampling_event.step_no      ;
     		p_sample.oprn_id 	    :=	x_sampling_event.oprn_id      ;


		/* Get item Desc and default it in sample */
		open get_item_desc (x_sampling_event.inventory_item_id) ;
		fetch get_item_desc into p_sample.sample_desc ;
		close get_item_desc;

		p_sample.sample_instance := sample_instance;
		p_sample.retain_as := 'A' ;
     		p_sample.sample_disposition :=	'0PL' ;

		IF not GMD_SAMPLES_PVT.insert_row (
                                 p_sample,  x_sample )      THEN
                           raise fnd_api.g_exc_error;
		END IF;

		p_sample_spec_disp.sample_id  := x_sample.sample_id;
		p_sample_spec_disp.event_spec_disp_id := x_event_spec_disp.event_spec_disp_id;
		p_sample_spec_disp.disposition        := '0PL';

		IF not GMD_SAMPLE_SPEC_DISP_PVT.insert_row  (
                            p_sample_spec_disp  )    THEN
	                          raise fnd_api.g_exc_error;
		END IF;
	END LOOP;

	FOR smp_cnt in 1..l_reserve_cnt_req  LOOP
	/* Create a Reserve sample */
		sample_instance := sample_instance + 1;
		p_sample.sample_qty := l_reserve_qty;
		p_sample.sample_qty_uom := l_sample_qty_uom;
		p_sample.sample_inv_trans_ind :=  l_inv_trans_ind ;
		p_sample.sampling_event_id   :=  x_sampling_event.sampling_event_id;
                    -- Bug 4165704: sample no now taken from quality parameters table
		    -- p_sample.sample_no  :=
	            -- 		GMA_GLOBAL_GRP.Get_Doc_No('SMPL', x_sampling_event.ORGN_CODE);
                p_sample.sample_no            := GMD_QUALITY_PARAMETERS_GRP.get_next_sample_no(x_sampling_event.organization_id);
		p_Sample.inventory_item_id := x_sampling_event.inventory_item_id ;
		p_Sample.revision          := x_sampling_event.revision;
                p_sample.delete_mark        := 0;
                p_sample.creation_date      := sysdate;
                p_sample.created_by         := FND_GLOBAL.USER_ID;
                p_sample.last_update_date   := sysdate;
                p_sample.last_updated_by    := FND_GLOBAL.USER_ID;
		p_sample.sampler_id         := FND_GLOBAL.USER_ID;

		p_sample.priority           := '5N' ;
		p_sample.remaining_qty      := p_sample.sample_qty;

                --RLNAGARA B5463399 Commented the below line and added next line so that the correct operating unit get populated.
                --p_sample.org_id             := p_sample.org_id;
                p_sample.org_id             := x_sampling_event.org_id;

     		p_sample.source 	    :=	x_sampling_event.source   ;
                p_sample.supplier_id 	    :=  x_sampling_event.supplier_id   ;
                p_sample.supplier_site_id   :=  x_sampling_event.supplier_site_id   ;
                p_sample.po_header_id 	    :=  x_sampling_event.po_header_id  ;
                p_sample.po_line_id 	    :=  x_sampling_event.po_line_id   ;
     		p_sample.sample_type 	    :=	x_sampling_event.sample_type  ;
                p_sample.organization_id    :=  x_sampling_event.organization_id    ;
                p_sample.receipt_id 	    :=  x_sampling_event.receipt_id   ;
                p_sample.receipt_line_id    :=  x_sampling_event.receipt_line_id   ;
                p_sample.lot_number 	    :=  x_sampling_event.lot_number       ;
                p_sample.parent_lot_number  :=  x_sampling_event.parent_lot_number    ;
                p_sample.supplier_lot_no    :=  x_sampling_event.supplier_lot_no; --Bug#6491872
                --srakrish bug 5844806: Populating the WIP fields properly.
		--p_sample.subinventory     :=  x_sampling_event.subinventory     ;
		--p_sample.locator_id  	    :=	x_sampling_event.locator_id     ;
		IF x_sampling_event.source = 'W' THEN
		    p_sample.source_locator_id  	    :=	x_sampling_event.locator_id     ;
		    p_sample.source_subinventory     :=  x_sampling_event.subinventory     ;
		 ELSE
		    p_sample.locator_id  	    :=	x_sampling_event.locator_id     ;
		    p_sample.subinventory 	    :=  x_sampling_event.subinventory     ;
		 END IF;
                p_sample.lot_retest_ind     :=  x_sampling_event.lot_retest_ind    ;
     		p_sample.batch_ID 	    :=	x_sampling_event.batch_ID    ;
     		p_sample.recipe_ID 	    :=	x_sampling_event.recipe_ID    ;
     		p_sample.formula_id 	    :=	x_sampling_event.formula_id    ;
     		p_sample.formulaline_id     :=	x_sampling_event.formulaline_id    ;
     	        p_sample.material_detail_id :=	x_sampling_event.material_detail_id    ;
     		p_sample.routing_id 	    :=	x_sampling_event.routing_id   ;
     		p_sample.step_id 	    :=	x_sampling_event.step_id      ;
     		p_sample.step_no 	    :=	x_sampling_event.step_no      ;
     		p_sample.oprn_id 	    :=	x_sampling_event.oprn_id      ;

		/* Get item Desc and default it in sample */
		open get_item_desc (x_sampling_event.inventory_item_id) ;
		fetch get_item_desc into p_sample.sample_desc ;
		close get_item_desc;

		p_sample.sample_instance := sample_instance;
		p_sample.retain_as := 'R' ;
     		p_sample.sample_disposition :=	'0PL' ;

		IF not GMD_SAMPLES_PVT.insert_row (
                                 p_sample,  x_sample )      THEN
                           raise fnd_api.g_exc_error;
		END IF;

		p_sample_spec_disp.sample_id  := x_sample.sample_id;
		p_sample_spec_disp.event_spec_disp_id := x_event_spec_disp.event_spec_disp_id;
		p_sample_spec_disp.disposition        := '0PL';

		IF not GMD_SAMPLE_SPEC_DISP_PVT.insert_row  (
                            p_sample_spec_disp  )    THEN
	            raise fnd_api.g_exc_error;
		END IF;
	END LOOP;

	/* Update the sampling event samples taken */
	update gmd_sampling_events
	set  SAMPLE_TAKEN_CNT =  0
	where sampling_event_id = x_sampling_event.sampling_event_id ;

	update gmd_sampling_events
	set  ARCHIVED_TAKEN =  0
	where sampling_event_id = x_sampling_event.sampling_event_id ;

	update gmd_sampling_events
	set  RESERVED_TAKEN =  0
	where sampling_event_id = x_sampling_event.sampling_event_id ;

	update gmd_sampling_events
	set  SAMPLE_REQ_CNT =  l_sample_cnt_req
	where sampling_event_id = x_sampling_event.sampling_event_id ;

	/* Update the sampling event disposition to Planned */
	update gmd_sampling_events
	set  disposition = '0PL'
	where sampling_event_id = x_sampling_event.sampling_event_id ;
    --gml_sf_log('return success - created samples');

	x_return_status := 'SUCCESS';

  EXCEPTION
      WHEN OTHERS THEN
      WF_CORE.CONTEXT ('GMD_AUTO_SAMPLE_PKG','CREATING AUTO SAMPLES',0,0,l_log );
      raise;
END create_samples;


END GMD_AUTO_SAMPLE_PKG;

/
