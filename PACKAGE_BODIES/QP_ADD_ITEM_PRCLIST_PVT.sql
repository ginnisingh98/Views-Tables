--------------------------------------------------------
--  DDL for Package Body QP_ADD_ITEM_PRCLIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_ADD_ITEM_PRCLIST_PVT" AS
/* $Header: QPXPRAIB.pls 120.2.12010000.5 2009/06/04 07:12:08 jputta ship $*/

Procedure Get_Conc_Reqvalues
	(x_conc_request_id		OUT NOCOPY /* file.sql.39 change */	NUMBER,
	 x_conc_program_application_id	OUT NOCOPY /* file.sql.39 change */	NUMBER,
	 x_conc_program_id		OUT NOCOPY /* file.sql.39 change */	NUMBER,
	 x_conc_login_id		OUT NOCOPY /* file.sql.39 change */	NUMBER,
	 x_user_id			OUT NOCOPY /* file.sql.39 change */	NUMBER	)
IS
BEGIN

  x_conc_request_id := fnd_global.conc_request_id;
  x_conc_program_id := fnd_global.conc_program_id;
  x_user_id       := fnd_global.user_id;
  x_conc_login_id := fnd_global.conc_login_id;

END GET_CONC_REQVALUES;

PROCEDURE Add_Items_To_Price_List
(
 ERRBUF               OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
 RETCODE              OUT NOCOPY /* file.sql.39 change */ NUMBER,
 p_price_list_id	  IN	NUMBER,
 p_start_date_active  IN DATE,
 p_end_date_active    IN DATE,
 p_set_price_flag     IN VARCHAR2,
 p_organization_id	  IN	NUMBER,
 p_seg1			  IN	VARCHAR2,
 p_seg2			  IN	VARCHAR2,
 p_seg3			  IN	VARCHAR2,
 p_seg4			  IN	VARCHAR2,
 p_seg5			  IN	VARCHAR2,
 p_seg6			  IN	VARCHAR2,
 p_seg7			  IN	VARCHAR2,
 p_seg8			  IN	VARCHAR2,
 p_seg9			  IN	VARCHAR2,
 p_seg10		       IN	VARCHAR2,
 p_seg11		       IN	VARCHAR2,
 p_seg12		       IN	VARCHAR2,
 p_seg13		       IN	VARCHAR2,
 p_seg14		       IN	VARCHAR2,
 p_seg15		       IN	VARCHAR2,
 p_seg16		       IN	VARCHAR2,
 p_seg17		       IN	VARCHAR2,
 p_seg18		       IN	VARCHAR2,
 p_seg19		       IN	VARCHAR2,
 p_seg20		       IN	VARCHAR2,
 p_category_id		  IN	NUMBER,
 p_status_code		  IN	VARCHAR2,
 p_category_set_id    IN NUMBER,
 p_costorg_id         IN NUMBER)
IS
  l_conc_request_id	  NUMBER := -1;
  l_conc_program_application_id  NUMBER := -1;
  l_conc_program_id  NUMBER := -1;
  l_conc_login_id	NUMBER := -1;
  l_user_id	     NUMBER := -1;
  l_rounding_factor	NUMBER;
  l_min_acct_unit	NUMBER;
  l_additems_sql	VARCHAR2(4000);
  l_already_exists  NUMBER;
l_commit_count     NUMBER:=0;

  l_item_tbl_type  DBMS_SQL.VARCHAR2_TABLE;
  l_item_tbl       l_item_tbl_type%type;

  l_attr_grp_s  NUMBER;
  l_index BINARY_INTEGER;

  l_price NUMBER;
  l_uom  VARCHAR2(3);
  l_list_line_id NUMBER;
  l_min_list_line_id NUMBER;
  l_max_list_line_id NUMBER;

  CURSOR qual_cur
  IS
    SELECT qualifier_id
    FROM   qp_qualifiers
    WHERE  list_header_id = p_price_list_id
    AND  NOT (qualifier_context = 'MODLIST' AND
		    qualifier_attribute = 'QUALIFIER_ATTRIBUTE4');
		    --Do not consider those qualifiers which are Primary PLs
		    --that are qualifiers to their secondary PLs.

  CURSOR precedence_cur(a_pte_code VARCHAR2)
  IS SELECT a.user_precedence
     FROM   qp_segments_v a,
            qp_prc_contexts_b b,
            qp_pte_segments c
     WHERE
            b.prc_context_type = 'PRODUCT' and
            b.prc_context_code = 'ITEM' and
            b.prc_context_id = a.prc_context_id and
            a.segment_mapping_column = 'PRICING_ATTRIBUTE1' and
            a.segment_id = c.segment_id and
            c.pte_code = a_pte_code;

  l_pte_code            VARCHAR2(30);

  l_qual_id            NUMBER;
  l_qualification_ind  NUMBER;


  Flexfield FND_DFLEX.dflex_r;
  Flexinfo  FND_DFLEX.dflex_dr;
  Contexts  FND_DFLEX.contexts_dr;
  segments  FND_DFLEX.segments_dr;
  l_sequence_num   NUMBER;
  l_price_rounding        VARCHAR2(50) :='';
  /* 7388596*/
  v_result_code number;
  V_cost_mthd       VARCHAR2(15) DEFAULT NULL ;
  V_cmpntcls_id     NUMBER DEFAULT NULL;
  V_analysis_code   VARCHAR2(15) DEFAULT NULL;
  V_acctg_cost	NUMBER ;
  v_return_status VARCHAR2(15);
  v_msg_count     NUMBER;
  v_msg_data      VARCHAR2(2000);
  v_item_cost  NUMBER;
  v_no_of_rows NUMBER;

BEGIN
  Get_Conc_Reqvalues
    (l_conc_request_id,
     l_conc_program_application_id,
     l_conc_program_id,
	l_conc_login_id,
	l_user_id);

 /* -----------------------------------------------------------------------+
  |     Retrieve the items within the item range                           |
  +----------------------------------------------------------------------- */

    QP_ITEM_RANGE_PVT.ITEMS_IN_RANGE
      (
        p_seg1,
        p_seg2,
	   p_seg3,
	   p_seg4,
	   p_seg5,
	   p_seg6,
	   p_seg7,
	   p_seg8,
	   p_seg9,
	   p_seg10,
	   p_seg11,
	   p_seg12,
	   p_seg13,
	   p_seg14,
	   p_seg15,
	   p_seg16,
	   p_seg17,
	   p_seg18,
	   p_seg19,
	   p_seg20,
	   p_organization_id,
	   p_category_set_id,
	   p_category_id,
	   p_status_code,
	   l_item_tbl);



FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_price_list_id-'||p_price_list_id);
FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_set_price_flag-'||p_set_price_flag);
FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_organization_id-'||p_organization_id);
FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_category_id-'||p_category_id);
FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_status_code-'||p_status_code);
FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_category_set_id-'||p_category_set_id);
FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_costorg_id-'||p_costorg_id);

  IF QP_UTIL.Attrmgr_Installed = 'Y' THEN
     FND_PROFILE.GET('QP_PRICING_TRANSACTION_ENTITY', l_pte_code);

     IF l_pte_code IS NULL THEN
       l_pte_code := 'ORDFUL';
     END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_pte_code'||l_pte_code);
     OPEN  precedence_cur(l_pte_code);
     FETCH precedence_cur INTO l_sequence_num;
     CLOSE precedence_cur;

  ELSE
     -- Added by dhgupta for bug 2113793

     FND_DFLEX.get_flexfield('QP','QP_ATTR_DEFNS_PRICING',Flexfield,Flexinfo);
     FND_DFLEX.get_segments(FND_DFLEX.make_context(Flexfield,'ITEM'),
                         segments,TRUE);
     For i in 1..segments.nsegments LOOP
       IF segments.application_column_name(i) = 'PRICING_ATTRIBUTE1' THEN
         l_sequence_num := segments.sequence(i);
       END IF;
     END LOOP;
  END IF;


  select qp_pricing_attr_group_no_s.nextval
    into l_attr_grp_s
    from dual;

  select (-1*PL.ROUNDING_FACTOR),
                NVL(FC.MINIMUM_ACCOUNTABLE_UNIT,-1)
    into l_rounding_factor, l_min_acct_unit
    from QP_LIST_HEADERS_B PL, FND_CURRENCIES FC
   where PL.LIST_HEADER_ID = p_price_list_id
     and PL.CURRENCY_CODE = FC.CURRENCY_CODE;


  l_price_rounding := fnd_profile.value('QP_PRICE_ROUNDING');  --Added for Enhancement 1732601
FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_price_rounding-'||l_price_rounding);
  OPEN qual_cur;
  FETCH qual_cur INTO l_qual_id;

  IF qual_cur%FOUND THEN -- Qualifiers present in target Price List
      l_qualification_ind := 6;
  ELSE                   -- Qualifiers not present in target Price List
      l_qualification_ind := 4;
  END IF;

  CLOSE qual_cur;

  IF ( p_set_price_flag = 'Y' ) THEN
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Entered p_set_price_flag');
    l_index := l_item_tbl.FIRST;
      WHILE l_index <= l_item_tbl.LAST LOOP
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Entered p_set_price_flag while');
	FND_FILE.PUT_LINE(FND_FILE.LOG, 'inventory item id-'||l_index||'-'||l_item_tbl(l_index));
        begin
/*
	     select count(*)
	     into   l_already_exists
	     from   qp_pricing_attributes qppa
             where  qppa.pricing_phase_id = 1
             and    qppa.qualification_ind in (4,6,20,22)
	     and    qppa.product_attribute_context = 'ITEM'
	     and    qppa.product_attr_value = l_item_tbl(l_index)
             and    qppa.excluder_flag = 'N'
             and    qppa.list_header_id = p_price_list_id;
*/
		l_already_exists := 0;
		Select  1
		Into    l_already_exists
		From    Dual
		Where   Exists
			(Select Null
			  from qp_pricing_attributes qppa
			   where qppa.list_header_id = p_price_list_id
			   and qppa.pricing_phase_id = 1
			   and qppa.product_attribute_context = 'ITEM'
			   and qppa.product_attribute = 'PRICING_ATTRIBUTE1'
			   and qppa.product_attr_value = l_item_tbl(l_index)
			);
        exception
	     WHEN NO_DATA_FOUND THEN
		l_already_exists := 0;
		WHEN OTHERS THEN
		FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR-'||sqlerrm);
		  RAISE;
        end;
        IF l_already_exists > 0 THEN
	     -- write rec log of values that cannot be added
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Item Number '|| l_item_tbl(l_index) || ' already exists');
        ELSE
/*
	     select decode(l_min_acct_unit,
					 -1,
					 round(nvl(cst.item_cost,0), l_rounding_factor),
					 round(nvl(cst.item_cost,0)/l_min_acct_unit)
					 * l_min_acct_unit)
            into l_price
            from  mtl_system_items mtl, cst_item_costs_for_gl_view cst
           where mtl.inventory_item_id = l_item_tbl(l_index)
		   and cst.inventory_item_id (+)=mtl.inventory_item_id
		   and cst.organization_id (+)= nvl(p_costorg_id,mtl.organization_id)
		   and mtl.organization_id = p_organization_id;
*/
                Begin

             IF l_price_rounding IS NOT NULL THEN          --Added for Enhancement 1732601
                If (p_costorg_id Is Null) Then
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Query-1-1');
			select decode(l_min_acct_unit,
                                -1,
                                round(nvl(cst.item_cost,0), l_rounding_factor),
                                round(nvl(cst.item_cost,0)/l_min_acct_unit)*l_min_acct_unit)
                        Into    l_price
                        from    mtl_system_items mtl, cst_item_costs_for_gl_view cst
                        where   mtl.inventory_item_id = l_item_tbl(l_index)
                        and     cst.inventory_item_id =mtl.inventory_item_id
                        and     cst.organization_id = mtl.organization_id
                        and     mtl.organization_id = p_organization_id;
		        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Query-1');
                ELSE /* 7388596*/
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'Query-API-1');
			IF GMF_validations_PVT.Validate_organization_id(p_costorg_id)  THEN
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inventory Item Id: '|| l_item_tbl(l_index));
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_organization_id: '|| p_costorg_id);
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_transaction_date: '|| sysdate);
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_cost_method: '|| NVL(v_cost_mthd,'NULL'));
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'v_cmpntcls_id: '|| NVL(v_cmpntcls_id,0));
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'v_analysis_code: '|| NVL(v_analysis_code,'NULL'));
				v_result_code := GMF_CMCOMMON.Get_Process_Item_Cost
						      (    p_api_version        => 1
							 , p_init_msg_list      => 'F'
							 , x_return_status      => v_return_status
							 , x_msg_count          => v_msg_count
							 , x_msg_data           => v_msg_data
							 , p_inventory_item_id  => l_item_tbl(l_index)
							 , p_organization_id    => p_costorg_id
							 , p_transaction_date   => sysdate /* Cost as on date */
							 , p_detail_flag        => 1 /*  1 = total cost, 2 = details; 3 = cost for a specific component class/analysis code, etc. */
							 , p_cost_method        => v_cost_mthd    /* OPM Cost Method */
							 , p_cost_component_class_id => v_cmpntcls_id
							 , p_cost_analysis_code => v_analysis_code
							 , x_total_cost         => v_item_cost  /* total cost */
							 , x_no_of_rows         => v_no_of_rows    /* number of detail rows retrieved */
						      );
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_cost_method: '|| NVL(v_cost_mthd,'NULL'));
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'v_cmpntcls_id: '|| NVL(v_cmpntcls_id,0));
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'v_analysis_code: '|| NVL(v_analysis_code,'NULL'));
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'v_result_code: '|| NVL(v_result_code,0));
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'x_total_cost: '|| NVL(v_item_cost,0));
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'x_no_of_rows: '|| NVL(v_no_of_rows,0));
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'x_return_status: '|| NVL(v_return_status,'N'));
				IF v_result_code = 1 THEN
					SELECT decode(l_min_acct_unit,-1,round(nvl(v_item_cost,0), l_rounding_factor),
					round(nvl(v_item_cost,0)/l_min_acct_unit)*l_min_acct_unit)
					INTO l_price
					FROM dual;
				ELSE
					l_price := 0;
				END IF;
			ELSE
				FND_FILE.PUT_LINE(FND_FILE.LOG, 'Query-2-1');
				select decode(l_min_acct_unit,
					-1,
					round(nvl(cst.item_cost,0), l_rounding_factor),
					round(nvl(cst.item_cost,0)/l_min_acct_unit)*l_min_acct_unit)
				Into    l_price
				from    mtl_system_items mtl, cst_item_costs_for_gl_view cst
				where   mtl.inventory_item_id = l_item_tbl(l_index)
				and     cst.inventory_item_id =mtl.inventory_item_id
				and     cst.organization_id = p_costorg_id
				and     mtl.organization_id = p_organization_id;
				FND_FILE.PUT_LINE(FND_FILE.LOG, 'Query-2');
			END IF;
                End If;
            ELSE
                /* Added for Enhancement 1732601 */

                If (p_costorg_id Is Null) Then

                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Query-3-1');
			select decode(l_min_acct_unit,
                                -1,
                                nvl(cst.item_cost,0),
                                round(nvl(cst.item_cost,0)/l_min_acct_unit)*l_min_acct_unit)
                        Into    l_price
                        from    mtl_system_items mtl, cst_item_costs_for_gl_view cst
                        where   mtl.inventory_item_id = l_item_tbl(l_index)
                        and     cst.inventory_item_id =mtl.inventory_item_id
                        and     cst.organization_id = mtl.organization_id
                        and     mtl.organization_id = p_organization_id;
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'Query-3');
                ELSE /* 7388596*/
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'Query-API-2');
			IF GMF_validations_PVT.Validate_organization_id(p_costorg_id)  THEN
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inventory Item Id: '|| l_item_tbl(l_index));
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_organization_id: '|| p_costorg_id);
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_transaction_date: '|| sysdate);
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_cost_method: '|| NVL(v_cost_mthd,'NULL'));
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'v_cmpntcls_id: '|| NVL(v_cmpntcls_id,0));
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'v_analysis_code: '|| NVL(v_analysis_code,'NULL'));
				v_result_code := GMF_CMCOMMON.Get_Process_Item_Cost
						      (    p_api_version        => 1
							 , p_init_msg_list      => 'F'
							 , x_return_status      => v_return_status
							 , x_msg_count          => v_msg_count
							 , x_msg_data           => v_msg_data
							 , p_inventory_item_id  => l_item_tbl(l_index)
							 , p_organization_id    => p_costorg_id
							 , p_transaction_date   => sysdate /* Cost as on date */
							 , p_detail_flag        => 1 /*  1 = total cost, 2 = details; 3 = cost for a specific component class/analysis code, etc. */
							 , p_cost_method        => v_cost_mthd    /* OPM Cost Method */
							 , p_cost_component_class_id => v_cmpntcls_id
							 , p_cost_analysis_code => v_analysis_code
							 , x_total_cost         => v_item_cost  /* total cost */
							 , x_no_of_rows         => v_no_of_rows    /* number of detail rows retrieved */
						      );
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_cost_method: '|| NVL(v_cost_mthd,'NULL'));
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'v_cmpntcls_id: '|| NVL(v_cmpntcls_id,0));
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'v_analysis_code: '|| NVL(v_analysis_code,'NULL'));
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'v_result_code: '|| NVL(v_result_code,0));
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'x_total_cost: '|| NVL(v_item_cost,0));
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'x_no_of_rows: '|| NVL(v_no_of_rows,0));
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'x_return_status: '|| NVL(v_return_status,'N'));
				IF v_result_code = 1 THEN
					SELECT decode(l_min_acct_unit,-1,round(nvl(v_item_cost,0), l_rounding_factor),
					round(nvl(v_item_cost,0)/l_min_acct_unit)*l_min_acct_unit)
					INTO l_price
					FROM dual;
				ELSE
					l_price := 0;
				END IF;
			ELSE

				FND_FILE.PUT_LINE(FND_FILE.LOG, 'Query-4-1');
				select decode(l_min_acct_unit,
					-1,
					nvl(cst.item_cost,0),
					round(nvl(cst.item_cost,0)/l_min_acct_unit)*l_min_acct_unit)
				Into    l_price
				from    mtl_system_items mtl, cst_item_costs_for_gl_view cst
				where   mtl.inventory_item_id = l_item_tbl(l_index)
				and     cst.inventory_item_id =mtl.inventory_item_id
				and     cst.organization_id = p_costorg_id
				and     mtl.organization_id = p_organization_id;
				FND_FILE.PUT_LINE(FND_FILE.LOG, 'Query-4');
			END IF;
                End If;

            END IF;
                Exception
                        When No_Data_Found Then
                                l_price := 0;
				FND_FILE.PUT_LINE(FND_FILE.LOG, '1ERROR-'||sqlerrm);
                End;


          select mtl.primary_uom_code
		  into l_uom
		  from mtl_system_items mtl
           where mtl.inventory_item_id = l_item_tbl(l_index)
		   and mtl.organization_id = p_organization_id;

	     select qp_list_lines_s.nextval
		   into l_list_line_id
		   from dual;

		insert
		  into qp_list_lines
		       (LIST_LINE_ID,
			   LIST_LINE_NO,
		        LAST_UPDATE_DATE,
                  CREATION_DATE,
                  LIST_PRICE_UOM_CODE,
                  LIST_PRICE,
                  LAST_UPDATED_BY,
                  CREATED_BY,
                  LAST_UPDATE_LOGIN,
                  LIST_HEADER_ID,
                  REQUEST_ID,
                  PROGRAM_APPLICATION_ID,
                  PROGRAM_ID,
                  PROGRAM_UPDATE_DATE,
			   LIST_LINE_TYPE_CODE,
			   START_DATE_ACTIVE,
			   AUTOMATIC_FLAG,
			   PRICING_PHASE_ID,
			   OPERAND,
			   ARITHMETIC_OPERATOR,
			   INCOMPATIBILITY_GRP_CODE,
			   PRODUCT_PRECEDENCE,
			   MODIFIER_LEVEL_CODE,
			   QUALIFICATION_IND
			   -- Bug 5202021 RAVI
			   ,ORIG_SYS_LINE_REF)
          values (
                  l_list_line_id,
                  l_list_line_id,
		  -- Begin Bug No: 7281484
                  sysdate,
                  sysdate,
                  -- End Bug No: 7281484
                  l_uom,
			   l_price,
                  l_user_id,
                  l_user_id,
                  l_conc_login_id,
                  p_price_list_id,
                  l_conc_request_id,
                  l_conc_program_application_id,
                  l_conc_program_id,
                  sysdate, --Bug No: 7281484
			   'PLL',
			   trunc(sysdate),
			   'Y',
			   1,
			   l_price,
			   'UNIT_PRICE',
			   'EXCL',
                           l_sequence_num,  --modified by dhgupta for bug 2113793
	                   -- 220,
			   'LINE',
			   l_qualification_ind
			   -- Bug 5202021 RAVI
			   ,l_list_line_id);

		 insert
		   into qp_pricing_attributes
			   (pricing_attribute_id,
			    creation_date,
			    created_by,
			    last_update_date,
			    last_updated_by,
			    last_update_login,
			    program_application_id,
			    program_id,
			    program_update_date,
			    request_id,
			    list_line_id,
			    list_header_id,
			    pricing_phase_id,
			    qualification_ind,
			    product_attribute_context,
			    product_attribute,
			    product_attribute_datatype, --3099578
			    product_attr_value,
			    product_uom_code,
			    excluder_flag,
			    accumulate_flag,
			    comparison_operator_code,   --2814272
			    attribute_grouping_no
			    -- Bug 5202021 RAVI
			    ,ORIG_SYS_PRICING_ATTR_REF)
           values (qp_pricing_attributes_s.nextval,
			    sysdate, -- Bug No: 7281484
			    l_user_id,
			    sysdate, -- Bug No: 7281484
			    l_user_id,
			    l_conc_login_id,
			    l_conc_program_application_id,
			    l_conc_program_id,
			    sysdate, -- Bug No: 7281484
			    l_conc_request_id,
			    l_list_line_id,
			    p_price_list_id,
			    1,
			    l_qualification_ind,
			    'ITEM',
			    'PRICING_ATTRIBUTE1',
                            'C',		--3099578
			    l_item_tbl(l_index),
			    l_uom,
			    'N',
			    'N',
			    'BETWEEN',     --2814272
			    l_attr_grp_s
			    -- Bug 5202021 RAVI
			    ,qp_pricing_attributes_s.currval);

        END IF;

	   l_index := l_item_tbl.NEXT(l_index);

      END LOOP;

/* ---------------------------------------------------------------------------+
 |       Create price list line for inventory items not on price list         |
 |         DO NOT Set list_price = cost                                       |
 + --------------------------------------------------------------------------*/
  ELSE
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'DO NOT Set list_price = cost');
    l_index := l_item_tbl.FIRST;
    WHILE l_index <= l_item_tbl.LAST LOOP
      begin
/*
        select count(*)
	     into l_already_exists
	     from qp_pricing_attributes qppa
	    where qppa.list_header_id = p_price_list_id
	      and qppa.pricing_phase_id = 1
		 and qppa.product_attribute_context = 'ITEM'
		 and qppa.product_attr_value = l_item_tbl(l_index);
*/
		l_already_exists := 0;
                Select  1
                Into    l_already_exists
                From    Dual
                Where   Exists
                        (Select Null
                          from qp_pricing_attributes qppa
                           where qppa.list_header_id = p_price_list_id
                           and qppa.pricing_phase_id = 1
                           and qppa.product_attribute_context = 'ITEM'
                           and qppa.product_attribute = 'PRICING_ATTRIBUTE1'
                           and qppa.product_attr_value = l_item_tbl(l_index)
                        );
      exception
	   when no_data_found then
	   l_already_exists := 0;
	   WHEN OTHERS THEN
	   RAISE;
      end;
	 IF l_already_exists > 0 THEN
	     -- write rec log of values that cannot be added
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Item Number '|| l_item_tbl(l_index) || ' already exists');
      ELSE

	   select mtl.primary_uom_code
	     into l_uom
		from mtl_system_items mtl
	    where mtl.inventory_item_id = l_item_tbl(l_index)
		 and mtl.organization_id = p_organization_id;


        insert
		into qp_list_lines
		 	(LIST_LINE_ID,
			 LIST_LINE_NO,
		      LAST_UPDATE_DATE,
                CREATION_DATE,
                LIST_PRICE_UOM_CODE,
                LIST_PRICE,
                LAST_UPDATED_BY,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                LIST_HEADER_ID,
                REQUEST_ID,
                PROGRAM_APPLICATION_ID,
                PROGRAM_ID,
                PROGRAM_UPDATE_DATE,
			 LIST_LINE_TYPE_CODE,
			 START_DATE_ACTIVE,
			 AUTOMATIC_FLAG,
                PRICING_PHASE_ID,
			 OPERAND,
			 ARITHMETIC_OPERATOR,
			 INCOMPATIBILITY_GRP_CODE,
			 PRODUCT_PRECEDENCE,
			 MODIFIER_LEVEL_CODE,
			 QUALIFICATION_IND
			 -- Bug 5202021 RAVI
			 ,ORIG_SYS_LINE_REF)
         values (
                 qp_list_lines_s.nextval,
                 qp_list_lines_s.currval,
		 -- Begin Bug No: 7281484
                 sysdate,
                 sysdate,
		 -- End -- Bug No: 7281484
                 l_uom,
                 0,
                 l_user_id,
                 l_user_id,
                 l_conc_login_id,
                 p_price_list_id,
                 l_conc_request_id,
                 l_conc_program_application_id,
                 l_conc_program_id,
                 sysdate, -- Bug No: 7281484
		       'PLL',
			  trunc(sysdate),
			  'Y',
			  1,
			  0,
			  'UNIT_PRICE',
			  'EXCL',
                          l_sequence_num,
			  --220,     --modified by dhgupta for bug 2113793
			  'LINE',
			  l_qualification_ind
			  -- Bug 5202021 RAVI
			  ,qp_list_lines_s.currval);

/*------------------------------------------------------------------------+
 |    Insert pricing attributes                                           |
 +-----------------------------------------------------------------------*/


         insert
	      into qp_pricing_attributes
     	      (PRICING_ATTRIBUTE_ID,
     	       CREATION_DATE,
	            CREATED_BY,
	            LAST_UPDATE_DATE,
	            LAST_UPDATED_BY,
	            LAST_UPDATE_LOGIN,
	            PROGRAM_APPLICATION_ID,
	            PROGRAM_ID,
	            PROGRAM_UPDATE_DATE,
	            REQUEST_ID,
	            LIST_LINE_ID,
			  LIST_HEADER_ID,
			  PRICING_PHASE_ID,
			  QUALIFICATION_IND,
	            PRODUCT_ATTRIBUTE_CONTEXT,
	            PRODUCT_ATTRIBUTE,
                    product_attribute_datatype, --3099578
	            PRODUCT_ATTR_VALUE,
	            PRODUCT_UOM_CODE,
		       EXCLUDER_FLAG,
		       ACCUMULATE_FLAG,
		       comparison_operator_code,   --2814272
	            ATTRIBUTE_GROUPING_NO
		    -- Bug 5202021 RAVI
		    ,ORIG_SYS_PRICING_ATTR_REF)
         values (qp_pricing_attributes_s.nextval,
		       sysdate, -- Bug No: 7281484
		       l_user_id,
		       sysdate, -- Bug No: 7281484
		       l_user_id,
		       l_conc_login_id,
		       l_conc_program_application_id,
		       l_conc_program_id,
		       sysdate, -- Bug No: 7281484
		       l_conc_request_id,
		       qp_list_lines_s.currval,
			  p_price_list_id,
			  1,
			  l_qualification_ind,
		       'ITEM',
		       'PRICING_ATTRIBUTE1',
                       'C',                       --3099578
		       l_item_tbl(l_index),
		       l_uom,
		       'N',
		       'N',
			'BETWEEN',    --2814272
		       l_attr_grp_s
		       -- Bug 5202021 RAVI
		       ,qp_pricing_attributes_s.currval);

    	  END IF;

	  l_index := l_item_tbl.NEXT(l_index);
          l_commit_count:=l_commit_count+1;    --Commiting after every 100 records for bug2363369
          IF l_commit_count=100 THEN
            l_commit_count:=0;
            COMMIT;
          END IF;


     END LOOP;

   END IF;
   IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'Y' THEN
	select min(list_line_id), max(list_line_id)
	into   l_min_list_line_id, l_max_list_line_id
	from qp_list_lines
	where list_header_id = p_price_list_id;

	QP_ATTR_GRP_PVT.Update_Prod_Pric_Segment_id(p_price_list_id, l_min_list_line_id, l_max_list_line_id);
	QP_ATTR_GRP_PVT.update_pp_lines(p_price_list_id, l_min_list_line_id, l_max_list_line_id);
   END IF;
    --- jagan PL/SQL pattern engine
            IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
               IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'P' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B' THEN
	        select min(list_line_id), max(list_line_id)
		into   l_min_list_line_id, l_max_list_line_id
		from qp_list_lines
		where list_header_id = p_price_list_id;

		QP_PS_ATTR_GRP_PVT.Update_Prod_Pric_Segment_id(p_price_list_id, l_min_list_line_id, l_max_list_line_id);
		QP_PS_ATTR_GRP_PVT.update_pp_lines(p_price_list_id, l_min_list_line_id, l_max_list_line_id);
	       END IF;
	    END IF;
   COMMIT;
retcode:=0;
errbuf:='';
EXCEPTION
 WHEN others THEN
  ROLLBACK;
  FND_FILE.PUT_LINE(FND_FILE.LOG, SQLCODE||' -DK- '||SQLERRM);
retcode:=2;
END Add_Items_To_Price_List;

END QP_ADD_ITEM_PRCLIST_PVT;

/
