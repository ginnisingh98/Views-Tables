--------------------------------------------------------
--  DDL for Package Body GMD_COA_DATA_OM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_COA_DATA_OM" AS
/* $Header: GMDCOA3B.pls 115.13 2004/02/18 16:52:36 magupta noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'GMD_COA_DATA_OM';
v_stage             NUMBER;         /*  Variable for debugging. */
p_msg               VARCHAR2(4000);
l_debug_enabled     VARCHAR2(1):='Y';
l_utl_file_dir      VARCHAR2(1000);
      /*   next variable is version for Look_for_CoC_Data   */


 PROCEDURE Trace(p_msg IN VARCHAR2)
    IS
    BEGIN
       /*gmd_debug.put_line(p_msg); */
       IF (l_debug_enabled = 'Y') THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG,p_msg);
       END IF;
    END Trace;
FUNCTION IsEmpty(p_str IN VARCHAR2) RETURN BOOLEAN IS
    BEGIN
	IF ( p_str IS NULL OR RTRIM(p_str) IS NULL )
	THEN
	    RETURN(TRUE);
	ELSE
	    RETURN (FALSE);
	END IF;
    END;

    PROCEDURE WriteLog(p_msg_code IN VARCHAR2,
                       p_appl     IN VARCHAR2,
		       p_col1     IN VARCHAR2,
		       p_token1   IN VARCHAR2,
		       p_col2     IN VARCHAR2,
		       p_token2   IN VARCHAR2,
		       p_col3     IN VARCHAR2,
		       p_token3   IN VARCHAR2,
		       p_col4     IN VARCHAR2,
		       p_token4   IN VARCHAR2,
		       p_col5     IN VARCHAR2,
		       p_token5   IN VARCHAR2,
		       p_file_typ IN VARCHAR2 )
    IS
    BEGIN
	    v_stage:=1;
	    FND_MESSAGE.SET_NAME(p_appl,p_msg_code);
	    IF (NOT IsEmpty(p_col1))
	    THEN
	        FND_MESSAGE.SET_TOKEN(p_token1,p_col1);
            END IF;

	    IF (NOT IsEmpty(p_col2))
	    THEN
	        FND_MESSAGE.SET_TOKEN(p_token2,p_col2);
            END IF;

	    IF (NOT IsEmpty(p_col3))
	    THEN
	        FND_MESSAGE.SET_TOKEN(p_token3,p_col3);
            END IF;

	    IF (NOT IsEmpty(p_col4))
	    THEN
	        FND_MESSAGE.SET_TOKEN(p_token4,p_col4);
            END IF;

	    IF (NOT IsEmpty(p_col5))
	    THEN
	        FND_MESSAGE.SET_TOKEN(p_token5,p_col5);
            END IF;

	    IF (p_file_typ='OUTPUT')
	    THEN
	        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET);
            ELSE
	        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
            END IF;
   END  WriteLog;

/*#############################################################################
 #  Procedure Look_For_CoC_Specs
 #  The cursors used are similar to spec cursors in Details procedure.
 #  Cursors here do not take 'assay_code' as parameter and return info for
 #  header and detail tables.  Also, cursors here will return records with
 #  NULL lots (specs only; results must have lots if item is lot cntrl'd).
 #  This procedure also used if sales/shipping information is given (so
 #  there is data in the header table), but no results were found in
 #  Populate_Details.  Use cursors here to look for specs for CoC.
 #      P_init_msg_list should be false when called from Populate_CoA_Data
 # 11feb2000 LRJ
 # 31mar2000 LRJ Made this procedure public (added to package spec)
 # 07jul2000 LRJ Add section for scenario where header data exists but no
 #                results were found.  Make procedure private.
 #                Added cursors for global item/lot specs and global item
 #                no-lot spec
 # 12jun2001 James Bernard Bug 1810652
 #    Modified the where clause of the select statement in the
 #    get_qc_cust_spec cursor definition to retrieve records when
 #    c_item_id is null.
 #    Modified the where clause of the select statement in the
 #    get_qc_global_cust_spec cursor definition to retrieve records when
 #    c_item_id is null.
 #    Modified the where clause of the select statement in the
 #    get_qc_item_spec cursor definition to retrieve records when
 #    c_item_id is null.
 #    In this procedure in the for cursors tbl.hdr.FIRST and tbl_hdr.LAST
 #    are replaced with NVL(tbl.hdr.FIRST,0) and NVL(tbl_hdr.LAST,0).
 ############################################################################ */
   PROCEDURE Look_For_CoC_Specs(
                     rec_param       IN  t_coa_parameters,
                     hdr_tbl_ndx     OUT NOCOPY BINARY_INTEGER,
                     tbl_hdr      IN OUT NOCOPY t_coa_header_tbl,
                     tbl_dtl      IN OUT NOCOPY t_coa_detail_tbl)
     IS
       CURSOR get_spec_details (c_spec_id NUMBER)
       IS
         select  gsb.item_id,
                 gsb.spec_id qc_spec_id,
                 gt.test_code assay_code,
                 decode (gst.target_value_char, null, to_char(gst.target_value_num), gst.target_value_char)
                                                                 specification,
                  gt.test_unit uom,
                 gst.text_code  spec_text_code
        from
          gmd_specifications_b gsb,
          gmd_spec_tests_b gst,
          gmd_qc_tests_b gt
       where
       gsb.spec_id  =  c_spec_id
       and gsb.spec_id  =  gst.spec_id
       and gst.test_id  =  gt.test_id
       and nvl(gst.print_spec_ind,'N') = 'Y'
       and gsb.delete_mark   = 0
       ;


     dtl_tbl_ndx        BINARY_INTEGER := 0;
     v_gmd_coa_id       BINARY_INTEGER := 1;
     v_previous_header  VARCHAR2(75);    /* orgn_code+cust+item+whse+lot */
     v_current_header   VARCHAR2(75);
     l_chk_whse_null    NUMBER;
     l_chk_lot_null     NUMBER;
     l_chk_orgn_null    NUMBER;
     p_customer_spec_rec   GMD_SPEC_MATCH_GRP.customer_spec_rec_type;
     p_inventory_spec_rec  GMD_SPEC_MATCH_GRP.inventory_spec_rec_type;
     x_return_flag       BOOLEAN;
     x_spec_id           NUMBER;
     x_spec_vr_id        NUMBER;
     x_return_status     VARCHAR2(1000);
     x_message_data      VARCHAR2(1000);



     BEGIN

       hdr_tbl_ndx := 0;
       dtl_tbl_ndx := 0;
       l_chk_whse_null := 0;    /* --  1st time thru, look for match */
       l_chk_orgn_null := 0;
       l_chk_lot_null  := 0;


         /*BEGIN BUG#1810652 James Bernard */
         /*Changed tbl_hdr.FIRST to NVL(tbl_hdr.FIRST,0) and           */
         /*tbl_hdr.LAST to NVL(tbl_hdr.LAST,0)                         */
         FOR loop_counter IN NVL(tbl_hdr.FIRST,0) .. NVL(tbl_hdr.LAST,0) LOOP
         /*END BUG#1810652  */
           dtl_tbl_ndx := 0;


           /*-----------------------------------------------------------------
             Call Customer specific spec matching API,
             If the spec is found then open the cursor get_spec_details
             above to get the details about that spec, else try Inventory
             spec.
           -------------------------------------------------------------------*/
             p_customer_spec_rec.item_id := tbl_hdr(loop_counter).item_id;
             p_customer_spec_rec.cust_id := tbl_hdr(loop_counter).cust_id;
             p_customer_spec_rec.date_effective := SYSDATE;
             p_customer_spec_rec.whse_code := tbl_hdr(loop_counter).whse_code;
             p_customer_spec_rec.org_id := tbl_hdr(loop_counter).org_id;
             p_customer_spec_rec.order_id := tbl_hdr(loop_counter).order_id;

             x_return_flag := FALSE;
             x_return_flag := GMD_SPEC_MATCH_GRP.FIND_CUSTOMER_SPEC(p_customer_spec_rec,
		       	                                          x_spec_id,
			     					  x_spec_vr_id,
			    					  x_return_status,
			    					  x_message_data);
             trace('Look_For_CoC_Specs, GMD_SPEC_MATCH_GRP.FIND_CUSTOMER_SPEC , Spec_id '||x_spec_id);
             IF (x_return_flag = FALSE)  THEN

                p_inventory_spec_rec.item_id := tbl_hdr(loop_counter).item_id;
                p_inventory_spec_rec.lot_id  := tbl_hdr(loop_counter).lot_id;
                p_inventory_spec_rec.date_effective := SYSDATE;
                p_inventory_spec_rec.whse_code := tbl_hdr(loop_counter).whse_code;
               -- p_inventory_spec_rec.org_id := tbl_hdr(loop_counter).org_id;

               	x_return_flag := GMD_SPEC_MATCH_GRP.FIND_INVENTORY_SPEC(p_inventory_spec_rec ,
 							                x_spec_id ,
 			   				                x_spec_vr_id,
 			  				                x_return_status,
 			                                                x_message_data);
                trace('Look_For_CoC_Specs, GMD_SPEC_MATCH_GRP.FIND_INVENTORY_SPEC , Spec_id '||x_spec_id);
             END IF;

             FOR qc_cur_rec  IN  get_spec_details
                                       (x_spec_id)   LOOP
                 dtl_tbl_ndx  := dtl_tbl_ndx + 1;
                 tbl_dtl(dtl_tbl_ndx).gmd_coa_id
                                            := tbl_hdr(loop_counter).gmd_coa_id;
                 tbl_dtl(dtl_tbl_ndx).qc_spec_id     := qc_cur_rec.qc_spec_id;
                 tbl_dtl(dtl_tbl_ndx).assay_code     := qc_cur_rec.assay_code;
                 tbl_dtl(dtl_tbl_ndx).specification  := qc_cur_rec.specification;
                 tbl_dtl(dtl_tbl_ndx).uom            := qc_cur_rec.uom;
                 tbl_dtl(dtl_tbl_ndx).spec_text_code := qc_cur_rec.spec_text_code;
                 trace('Look_For_CoC_Specs , get_spec_details '||tbl_dtl(dtl_tbl_ndx).qc_spec_id||' '||
                                             'assay_code '||tbl_dtl(dtl_tbl_ndx).assay_code||' '||
                                             'specification '||tbl_dtl(dtl_tbl_ndx).specification||' '||
                                             'uom '||tbl_dtl(dtl_tbl_ndx).uom||' '||
                                             'spec_text_code '||tbl_dtl(dtl_tbl_ndx).spec_text_code);

             END LOOP;



        END LOOP;
                       /* end going through header records  */
        hdr_tbl_ndx := tbl_hdr.LAST;


      EXCEPTION
        WHEN NO_DATA_FOUND THEN
           NULL;
             /* no data found is not an error.  Not all items will have specs */
        WHEN OTHERS THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                     /* exception defined in Populate_Coa_Data  */

     END Look_For_CoC_Specs;
                     /* end procedure  */


  /*###############################################################
  # NAME
  #	Populate_Details
  # SYNOPSIS
  #	proc Populate_Details
  #     parms header table   IN
  #           details table  IN OUT details will have data if this
  #                                  is non-sales data CoC
  # DESCRIPTION
  #      get results info
  #
  # HISTORY
  # 12jun2001 James Bernard Bug 1810652
  #    In the for cursors tbl_hdr.FIRST and tbl_hdr.LAST are
  #    replaced with NVL(tbl_hdr.FIRST,0) and NVL(tbl_hdr.LAST,0).
  #    Added 'c_item_id is NULL or' condition in  the where clause
  #    of the select statement in the get_cust_rslt_info cursor
  #    definition.
  #    Added 'c_item_id is NULL or' and 'c_lot_id is NULL or'
  #    conditions in  the where clause of the select statement
  #    in the get_item_rslt_info cursor definition.
  # 26Sep2001 Manish Gupta  New Quality
  #    Changed the cursors for getting data from New Quality tables.
  ################################################################*/
  PROCEDURE Populate_Details (tbl_hdr IN t_coa_header_tbl,
                              tbl_dtl IN OUT NOCOPY t_coa_detail_tbl) IS

  /* BEGIN BUG#1810652 James Bernard                     */
  /* Added 'c_item_id is NULL or' in the where clause    */
  CURSOR get_cust_rslt_info (c_orgn_code gmd_samples.orgn_code%TYPE,
                             c_item_id   ic_item_mst.item_id%TYPE,
                             c_lot_id    ic_lots_mst.lot_id%TYPE,
                             c_lot_no    ic_lots_mst.lot_no%TYPE,
                             c_cust_id   hz_cust_accounts.cust_account_id%TYPE)   IS
  select  gr.result_id qc_result_id,
          gst.spec_id qc_spec_id,
          gt.test_code assay_code,
          gr.result_date result_date,
          decode(gr.result_value_char, null, to_char(gr.result_value_num), gr.result_value_char) result,
           decode (gst.target_value_char, null, to_char(gst.target_value_num), gst.target_value_char)
                                                                                   specification,
           gt.test_unit uom,
           gst.text_code spec_text_code,
           gr.text_code rslt_text_code
   from gmd_samples  gs,
        gmd_results gr,
        gmd_qc_tests_b  gt,
        gmd_spec_results gsr,
        gmd_spec_tests_b gst ,
        gmd_sampling_events   gse,
        gmd_event_spec_disp   ges,
        gmd_specifications_b gsb,
        gmd_sample_spec_disp gss
   where     gs.sample_id          = gr.sample_id
    and    gse.sampling_event_id  = gs.sampling_event_id
    and    gse.sampling_event_id = ges.sampling_event_id
    and    ges.spec_used_for_lot_attrib_ind ='Y'
    and    ges.spec_id(+)      = gst.spec_id
    and    gst.test_id(+)    = gt.test_id
    and    gs.sample_id           = gr.sample_id
    and    gr.result_date is not null
    and    gr.result_id           = gsr.result_id
    and    gr.test_id             = gt.test_id
    and    ges.event_spec_disp_id = gsr.event_spec_disp_id
    and    ges.event_spec_disp_id = gss.event_spec_disp_id
    and    gsb.spec_id = ges.spec_id
   and     gss.disposition  in  ('4A','5AV')  -- ACCEPT
   and     nvl(gsr.evaluation_ind,'N') in ('0A','1V')
   and     decode(nvl(gst.print_result_ind,'N'),'Y', decode( gsr.evaluation_ind,'0A','Y','1V','Y','N'),'N',
                 gr.ad_hoc_print_on_coa_ind, 'Y', decode( gsr.evaluation_ind,'0A','Y','1V','Y','N'),'N') = 'Y'
   and     gs.cust_id        = c_cust_id
  and ( c_lot_id is NULL or decode(nvl(gs.lot_id,0),0,gs.lot_no, gs.lot_id) = decode(nvl(gs.lot_id,0),0, c_lot_no,c_lot_id))
  -- and (c_lot_id is NULL or gs.lot_id = c_lot_id)
   and (c_item_id is NULL or gs.item_id = c_item_id)
   --and gs.orgn_code      = c_orgn_code
   and gs.delete_mark    = 0
   ;
  /*END BUG#1810652                                        */

  /* use the next cursor if no rows returned from get_cust_rslt_info  */
  /* BEGIN BUG#1810652 James Bernard                     */
  /* Added 'c_item_id is NULL or' and 'c_lot_id is NULL or' in the where clause */
  CURSOR get_item_rslt_info (c_orgn_code gmd_samples.orgn_code%TYPE,
                             c_item_id   ic_item_mst.item_id%TYPE,
                             c_lot_no    ic_lots_mst.lot_no%TYPE,
                             c_lot_id    ic_lots_mst.lot_id%TYPE)   IS
  select  gr.result_id qc_result_id,
          gst.spec_id qc_spec_id,
          gt.test_code assay_code,
          gr.result_date result_date,
          decode(gr.result_value_char, null, to_char(gr.result_value_num), gr.result_value_char) result,
           decode (gst.target_value_char, null, to_char(gst.target_value_num), gst.target_value_char)
                                                                                   specification,
           gt.test_unit uom,
           gst.text_code spec_text_code,
           gr.text_code rslt_text_code
   from gmd_samples  gs,
        gmd_results gr,
        gmd_qc_tests_b  gt,
        gmd_spec_results gsr,
        gmd_spec_tests_b gst ,
        gmd_sampling_events   gse,
        gmd_event_spec_disp   ges,
        gmd_specifications_b gsb,
        gmd_sample_spec_disp gss
   where     gs.sample_id          = gr.sample_id
    and    gse.sampling_event_id  = gs.sampling_event_id
    and    gse.sampling_event_id = ges.sampling_event_id
    and    ges.spec_used_for_lot_attrib_ind ='Y'
    and    ges.spec_id(+)      = gst.spec_id
    and    gst.test_id(+)    = gt.test_id
    and    gs.sample_id           = gr.sample_id
    and    gr.result_date is not null
    and    gr.result_id           = gsr.result_id
    and    gr.test_id             = gt.test_id
    and    ges.event_spec_disp_id = gsr.event_spec_disp_id
    and    ges.event_spec_disp_id = gss.event_spec_disp_id
    and    gsb.spec_id = ges.spec_id
   and     gss.disposition  in  ('4A','5AV')  -- ACCEPT
   --and     gss.disposition  = '4A'  -- ACCEPT
   and     nvl(gsr.evaluation_ind,'N') in ( '0A','1V')
   and     decode(nvl(gst.print_result_ind,'N'),'Y', decode( gsr.evaluation_ind,'0A','Y','1V','Y','N'),'N',
                gr.ad_hoc_print_on_coa_ind, 'Y', decode( gsr.evaluation_ind,'0A','Y','1V','Y','N'),'N') = 'Y'
  -- and (c_lot_id is NULL or gs.lot_id = c_lot_id)
   and ( c_lot_id is NULL or decode(nvl(gs.lot_id,0),0,gs.lot_no, gs.lot_id) = decode(nvl(gs.lot_id,0),0, c_lot_no,c_lot_id))
   and (c_item_id is NULL or gs.item_id = c_item_id)
  --and gs.orgn_code      = c_orgn_code
   and gs.delete_mark    = 0
   and gs.cust_id        is NULL
   and gs.batch_id       is NULL
   and gs.formula_id     is NULL
   and gs.routing_id     is NULL
   and gs.oprn_id        is NULL
   and gs.supplier_id      is NULL
;




  /*END BUG#1810652                                      */


  CURSOR get_cust_spec (c_item_id ic_item_mst.item_id%TYPE,
                        c_cust_id hz_cust_accounts.cust_account_id%TYPE,
                        c_orgn_code  gmd_customer_spec_vrs.ORGN_CODE%TYPE,
                        c_assay_code gmd_qc_tests_b.TEST_CODE%TYPE)
    IS
     select gsb.spec_id qc_spec_id,
	    decode(gst.target_value_char, null, to_char(gst.target_value_num),gst.target_value_char)
										  specification,
            gcs.text_code  spec_text_code
     from  gmd_specifications_b gsb,
	   gmd_customer_spec_vrs gcs,
	   gmd_spec_tests_b   gst,
	   gmd_qc_tests_b gt
     where gsb.spec_id = gcs.spec_id
     and   gsb.spec_id = gst.spec_id
     and   gst.test_id = gt.test_id
     and   nvl(gst.print_result_ind, 'N') = 'Y'
     and   gsb.item_id    = c_item_id
     and gt.test_code = c_assay_code
     and gcs.cust_id    = c_cust_id
     and gcs.orgn_code  = c_orgn_code
     and gsb.delete_mark= 0;

  CURSOR get_global_cust_spec (c_item_id ic_item_mst.item_id%TYPE,
                               c_cust_id hz_cust_accounts.cust_account_id%TYPE,
                               c_assay_code gmd_qc_tests_b.TEST_CODE%TYPE)
    IS
     select gsb.spec_id qc_spec_id,
	    decode(gst.target_value_char, null, to_char(gst.target_value_num),gst.target_value_char)
										  specification,
            gcs.text_code  spec_text_code
     from  gmd_specifications_b gsb,
	   gmd_customer_spec_vrs gcs,
	   gmd_spec_tests_b   gst,
	   gmd_qc_tests_b gt
     where gsb.spec_id = gcs.spec_id
     and   gsb.spec_id = gst.spec_id
     and   gst.test_id = gt.test_id
     and   nvl(gst.print_result_ind, 'N') = 'Y'
     and   gsb.item_id    = c_item_id
     and gt.test_code = c_assay_code
     and gcs.cust_id    = c_cust_id
     and gcs.orgn_code is NULL
     and gsb.delete_mark= 0;


  CURSOR get_assay_info  (c_assay_code gmd_qc_tests_b.TEST_CODE%TYPE)
   IS
     select gt.test_desc assay_desc
     from gmd_qc_tests gt
     where gt.test_code = c_assay_code
     and   gt.delete_mark = 0;

   tbl_ndx           BINARY_INTEGER := 0;
                                     /* index for pl/sql table  */
   v_gmd_coa_id      BINARY_INTEGER;
   dtl_counter       NUMBER := 0;
   l_dummy_param_rec t_coa_parameters;
   l_tmp_hdr_tbl     t_coa_header_tbl;
   found_a_row       BOOLEAN;

   /* *********************************************************************
    * select from result table looking for customer
    * if no results, select from result table for item/loc result
    * if no item/loc result, then end procedure, else
    *    look for a customer spec
    * if spec_id <> cust spec then look for global cust spec
    * get assay description
    * *********************************************************************/

   BEGIN      /* begin Populate_Details  */

   IF v_report_title = 'COA' THEN

      Trace('Populate_Details, in v_report_title = ''COA''');

     /*BEGIN BUG#1810652 James Bernard */
     /*Changed tbl_hdr.FIRST to NVL(tbl_hdr.FIRST,0) and */
     /*tbl_hdr.LAST to NVL(tbl_hdr.LAST,0). */
     FOR loop_counter IN NVL(tbl_hdr.FIRST,0) .. NVL(tbl_hdr.LAST,0) LOOP
     /*END BUG#1810652                 */

       found_a_row := FALSE;

       begin
                        /*  look for customer-specific result  */
       FOR  cust_rslt_cur_rec IN get_cust_rslt_info
                                          (tbl_hdr(loop_counter).orgn_code,
                                           tbl_hdr(loop_counter).item_id,
                                           tbl_hdr(loop_counter).lot_id,
                                           tbl_hdr(loop_counter).lot_no,
                                           tbl_hdr(loop_counter).cust_id)  LOOP
         found_a_row := TRUE;
         tbl_ndx  := tbl_ndx + 1;
         tbl_dtl(tbl_ndx).gmd_coa_id      := tbl_hdr(loop_counter).gmd_coa_id;
         tbl_dtl(tbl_ndx).qc_result_id    := cust_rslt_cur_rec.qc_result_id;
         tbl_dtl(tbl_ndx).result_date     := cust_rslt_cur_rec.result_date;
         tbl_dtl(tbl_ndx).qc_spec_id      := cust_rslt_cur_rec.qc_spec_id;
         tbl_dtl(tbl_ndx).assay_code      := cust_rslt_cur_rec.assay_code;
         tbl_dtl(tbl_ndx).result          := cust_rslt_cur_rec.result;
         tbl_dtl(tbl_ndx).specification   := cust_rslt_cur_rec.specification;
         tbl_dtl(tbl_ndx).uom             := cust_rslt_cur_rec.uom;
         tbl_dtl(tbl_ndx).rslt_text_code  := cust_rslt_cur_rec.rslt_text_code;
         tbl_dtl(tbl_ndx).spec_text_code  := cust_rslt_cur_rec.spec_text_code;

         p_msg := 'Populate_Details get_cust_rslt_info gmd_coa_id '||tbl_hdr(loop_counter).gmd_coa_id||' '||
                            'qc_result_id     '||tbl_dtl(tbl_ndx).qc_result_id||' '||
                            'result_date     '||tbl_dtl(tbl_ndx).result_date||' '||
                            'qc_spec_id     '||tbl_dtl(tbl_ndx).qc_spec_id||' '||
                            'assay_code     '||tbl_dtl(tbl_ndx).assay_code||' '||
                            'result     '||tbl_dtl(tbl_ndx).result||' '||
                            'specification     '||tbl_dtl(tbl_ndx).specification||' '||
                            'uom     '||tbl_dtl(tbl_ndx).uom||' '||
                            'rslt_text_code     '||tbl_dtl(tbl_ndx).rslt_text_code||' '||
                            'spec_text_code     '||tbl_dtl(tbl_ndx).spec_text_code;
         trace(p_msg);


       END LOOP ;
       EXCEPTION
         when NO_DATA_FOUND then
            NULL;
       end;
                         /* end looking for customer-specific result  */

       IF NOT(found_a_row) THEN
         begin
                         /* look for item/loc result  */
         FOR  item_rslt_cur_rec IN get_item_rslt_info
                                            (tbl_hdr(loop_counter).orgn_code,
                                             tbl_hdr(loop_counter).item_id,
                                             tbl_hdr(loop_counter).lot_no,
                                             tbl_hdr(loop_counter).lot_id)  LOOP
           found_a_row := TRUE;
           tbl_ndx  := tbl_ndx + 1;
           tbl_dtl(tbl_ndx).gmd_coa_id      := tbl_hdr(loop_counter).gmd_coa_id;
           tbl_dtl(tbl_ndx).qc_result_id    := item_rslt_cur_rec.qc_result_id;
           tbl_dtl(tbl_ndx).result_date     := item_rslt_cur_rec.result_date;
           tbl_dtl(tbl_ndx).qc_spec_id      := item_rslt_cur_rec.qc_spec_id;
           tbl_dtl(tbl_ndx).assay_code      := item_rslt_cur_rec.assay_code;
           tbl_dtl(tbl_ndx).result          := item_rslt_cur_rec.result;
           tbl_dtl(tbl_ndx).specification   := item_rslt_cur_rec.specification;
           tbl_dtl(tbl_ndx).uom             := item_rslt_cur_rec.uom;
           tbl_dtl(tbl_ndx).rslt_text_code  := item_rslt_cur_rec.rslt_text_code;
           tbl_dtl(tbl_ndx).spec_text_code  := item_rslt_cur_rec.spec_text_code;

            p_msg := 'Populate_Details get_item_rslt_info gmd_coa_id '||tbl_hdr(loop_counter).gmd_coa_id||' '||
                            'qc_result_id     '||tbl_dtl(tbl_ndx).qc_result_id||' '||
                            'result_date     '||tbl_dtl(tbl_ndx).result_date||' '||
                            'qc_spec_id     '||tbl_dtl(tbl_ndx).qc_spec_id||' '||
                            'assay_code     '||tbl_dtl(tbl_ndx).assay_code||' '||
                            'result     '||tbl_dtl(tbl_ndx).result||' '||
                            'specification     '||tbl_dtl(tbl_ndx).specification||' '||
                            'uom     '||tbl_dtl(tbl_ndx).uom||' '||
                            'rslt_text_code     '||tbl_dtl(tbl_ndx).rslt_text_code||' '||
                            'spec_text_code     '||tbl_dtl(tbl_ndx).spec_text_code;
         trace(p_msg);

         END LOOP ;
         EXCEPTION
           when NO_DATA_FOUND then
               NULL;
         end;
                        /* end looking for item/loc-specific result  */
       END IF;
                        /* end if no cust results, look for item results  */
     END LOOP;
                        /* end looping through records in header table  */

     IF tbl_ndx = 0 THEN
             /* Look_For_CoC_Specs needs a header table which is IN/OUT.    */
             /* But tbl_hdr was passed to Populate_Details as IN.  */
             /* Look_For_Coc_Specs should not change hdr table with sales-  */
             /* order-no-results scenario, so send a temporary,writable copy.  */
         l_tmp_hdr_tbl  := tbl_hdr;
         trace('Populate Details Going to GMD_COA_DATA_OM.Look_For_CoC_Specs');
         GMD_COA_DATA_OM.Look_For_CoC_Specs
                    (l_dummy_param_rec,
                     tbl_ndx,
                     l_tmp_hdr_tbl,
                     tbl_dtl);
         trace('Populate Details coming back from  GMD_COA_DATA_OM.Look_For_CoC_Specs');
         IF tbl_dtl.FIRST is not NULL THEN
           v_report_title := 'COC';
         END IF;
                        /* end if there are any rows in tbl_dtl  */
     END IF;
                        /* no results found, look for CoC  */
                        /* this IF and call to Look for CoC Specs should only  */
                        /* happen when sales/shipping info is given and no  */
                        /* results exists.  */
   ELSE
     tbl_ndx := 1;
                        /* if CoC, set flag = 1 so next section executes for CoC  */
   END IF;
                        /* end if this is CoA (not CoC)  */


   /* *********************************************************************** --
    * now look for customer specs
    * if anything about the cust spec cursors or the detail table changes,
    *   also modify CoC code in Look_For_CoC_Specs procedure                 */

   IF tbl_ndx > 0 THEN

     IF tbl_dtl.EXISTS(1) THEN
        /* if sales/shipping item has no specs, there could be rows in tbl_hdr,  */
        /* but nothing to be found for details.  If so, skip this section.  */
        /* This section assumes results have been found.    */
        /* Exception WHEN-NO-DATA-FOUND is not handling th  is case. */

       /*BEGIN BUG#1810652 James Bernard */
       /*Changed tbl_dtl.FIRST to NVL(tbl_dtl.FIRST,0) and      */
       /*tbl_dtl.LAST to NVL(tbl_dtl.LAST,0).                   */
       FOR loop_counter IN NVL(tbl_dtl.FIRST,0) .. NVL(tbl_dtl.LAST,0) LOOP
       /*END BUG#1810652         */

         IF v_report_title = 'COA' THEN
                 /*  if CoC, need to loop thru tbl_dtl for assay desc,  */
                 /* but not look for specs again */
         /* use v_gmd_coa_id rather than tbl_dtl(loop_counter).gmd_coa_id as index */
         /*     to header table.  Hopefully makes codes more readable. */
           v_gmd_coa_id  := tbl_dtl(loop_counter).gmd_coa_id;

           FOR cust_spec_rec IN get_cust_spec (tbl_hdr(v_gmd_coa_id).item_id,
                                               tbl_hdr(v_gmd_coa_id).cust_id,
                                               tbl_hdr(v_gmd_coa_id).orgn_code,
                                               tbl_dtl(loop_counter).assay_code)
           LOOP
             dtl_counter := dtl_counter + 1;
             tbl_dtl(loop_counter).qc_spec_id     := cust_spec_rec.qc_spec_id;
             tbl_dtl(loop_counter).specification  := cust_spec_rec.specification;
             tbl_dtl(loop_counter).spec_text_code := cust_spec_rec.spec_text_code;
           END LOOP;
           IF dtl_counter = 0 THEN
             FOR cust_spec_rec IN get_global_cust_spec
                                               (tbl_hdr(v_gmd_coa_id).item_id,
                                                tbl_hdr(v_gmd_coa_id).cust_id,
                                                tbl_dtl(loop_counter).assay_code)
             LOOP
               dtl_counter := dtl_counter + 1;
               tbl_dtl(loop_counter).qc_spec_id    := cust_spec_rec.qc_spec_id;
               tbl_dtl(loop_counter).specification := cust_spec_rec.specification;
               tbl_dtl(loop_counter).spec_text_code:= cust_spec_rec.spec_text_code;
             END LOOP;
           END IF;
                               /* end if no cust spec found, look for global spec */
             /* if there is only an item specification, it should already have */
             /*  been associated with result in result table (qrm.qc_spec_id). */
             /*  That value, and specification and text code would have been  */
             /*  pulled in cursors get_cust_rslt_info or get_item_rslt_info. */
         END IF;
                           /* end if this is CoA */

        /* ****************************************************************** -- */
        /* now fill in lookup columns (assay_description) */

        /* get assay description from qc_assy_typ */

         IF tbl_dtl(loop_counter).assay_code is not NULL THEN
           FOR assay_cur_rec IN get_assay_info (tbl_dtl(loop_counter).assay_code)
           LOOP
             tbl_dtl(loop_counter).assay_desc := assay_cur_rec.assay_desc;
           END LOOP;
                          /* end getting assay from qc_assy_typ */
         END IF;
                          /* end checking if assay code has a value */
       END LOOP;
                          /* end loop thru detail to get specs and/or fill in  */
                          /* lookup columns */
     END IF;
              /* end if there are rows in detail which need specs matched up */
   ELSE
     tbl_dtl := empty_detail;
   END IF;
                          /* end if any result records found */


  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;

    WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                     /* exception defined in Populate_Coa_Data */

  END Populate_Details;


  /*###############################################################
  # NAME
  #	Populate_Text
  # SYNOPSIS
  #	proc Populate_Text
  #     parms detail table IN text table  OUT
  # DESCRIPTION
  #      get results text info
  # HISTORY
  # 12jun2001 James Bernard Bug 1810652
  #   In the For Cursors tbl_dtl.FIRST and tbl_dtl.LAST is
  #   replaced by NVL(tbl_dtl.FIRST,0) and NVL(tbl_dtl.LAST,0)
  ################################################################*/
  PROCEDURE Populate_Text    (tbl_dtl       IN  t_coa_detail_tbl,
                              tbl_spec_text OUT NOCOPY t_coa_text_tbl,
                              tbl_rslt_text OUT NOCOPY t_coa_text_tbl) IS

  CURSOR get_text_info (c_text_code qc_text_tbl.text_code%TYPE) IS
    select paragraph_code,
           line_no,
           text
      from qc_text_tbl
     where text_code = c_text_code
      and  line_no > 0
     order by paragraph_code, line_no ;

  tbl_ndx         BINARY_INTEGER := 0;
                                        /* index for pl/sql table */

  BEGIN

    /* loop through detail records, get text for results and text for specs */

    tbl_ndx := 0;

    /*BEGIN BUG#1810652 James Bernard                   */
    /*Changed tbl_dtl.FIRST to NVL(tbl_dtl.FIRST,0) and */
    /*tbl_dtl.LAST to NVL(tbl_dtl.LAST,0)               */
    FOR loop_counter IN NVL(tbl_dtl.FIRST,0) .. NVL(tbl_dtl.LAST,0) LOOP
    /*END BUG#1810652                */
      IF (tbl_dtl(loop_counter).spec_text_code) is not NULL THEN
        FOR  text_cur_rec IN get_text_info (tbl_dtl(loop_counter).spec_text_code)
        LOOP
          tbl_ndx  := tbl_ndx + 1;

          tbl_spec_text(tbl_ndx).gmd_coa_id  := tbl_dtl(loop_counter).gmd_coa_id;
          tbl_spec_text(tbl_ndx).text_code:=tbl_dtl(loop_counter).spec_text_code;
          tbl_spec_text(tbl_ndx).paragraph_code := text_cur_rec.paragraph_code;
          tbl_spec_text(tbl_ndx).line_no        := text_cur_rec.line_no;
          tbl_spec_text(tbl_ndx).text           := text_cur_rec.text;
        END LOOP;
                       /* end cursor to get text */
      END IF;
    END LOOP;
                       /* end looping through detail records */

    tbl_ndx := 0;

    /*BEGIN BUG#1810652 James Bernard                   */
    /*Changed tbl_dtl.FIRST to NVL(tbl_dtl.FIRST,0) and */
    /*tbl_dtl.LAST to NVL(tbl_dtl.LAST,0)               */
    FOR loop_counter IN NVL(tbl_dtl.FIRST,0) .. NVL(tbl_dtl.LAST,0) LOOP
    /*END BUG#1810652                */
      IF (tbl_dtl(loop_counter).rslt_text_code) is not NULL THEN
        FOR  text_cur_rec IN get_text_info (tbl_dtl(loop_counter).rslt_text_code)
        LOOP
          tbl_ndx  := tbl_ndx + 1;

          tbl_rslt_text(tbl_ndx).gmd_coa_id  := tbl_dtl(loop_counter).gmd_coa_id;
          tbl_rslt_text(tbl_ndx).text_code:=tbl_dtl(loop_counter).rslt_text_code;
          tbl_rslt_text(tbl_ndx).paragraph_code := text_cur_rec.paragraph_code;
          tbl_rslt_text(tbl_ndx).line_no        := text_cur_rec.line_no;
          tbl_rslt_text(tbl_ndx).text           := text_cur_rec.text;

        END LOOP;
                       /* end cursor to get text */
      END IF;
    END LOOP;
                       /* end looping through detail records */

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
                       /* there may not be text information for this result rec */

      WHEN OTHERS THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

  END  Populate_Text;


  /*###############################################################
  # NAME
  #	Populate_CoA_Data
  # SYNOPSIS
  #	proc Populate_CoA_Data
  #      parms event
  #     There is no Orgn_Code in where clauses for cursors because
  #       parameter is ID which identifies orgn code.
  #       (ie would need orgn_code if we had sales_order_no, not id)
  # DESCRIPTION
  #      populate gmd_coa_coa_hdr with records
  # HISTORY
  # 12jun2001 James Bernard Bug 1810652
  #   Commented a line which was not properly commented in the
  #   while <<order loop>>.
  #   In the For cursors tbl_hdr.FIRST and tbl_hdr.LAST are
  #   replaced with NVL(tbl_hdr.FIRST,0) and NVL(tbl_hdr.LAST,0).
  ################################################################*/
  PROCEDURE Populate_CoA_Data (
                     p_api_version   In NUMBER,
                     p_init_msg_list IN VARCHAR2  := FND_API.G_FALSE,
                     p_commit        IN VARCHAR2  := FND_API.G_FALSE,
                     p_validation_level IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
                     rec_param       IN  t_coa_parameters,
                     x_return_status OUT NOCOPY VARCHAR2,
                     x_msg_count     OUT NOCOPY NUMBER,
                     x_msg_data      OUT NOCOPY VARCHAR2,
                     tbl_hdr         OUT NOCOPY t_coa_header_tbl,
                     tbl_dtl         OUT NOCOPY t_coa_detail_tbl,
                     tbl_spec_text   OUT NOCOPY t_coa_text_tbl,
                     tbl_rslt_text   OUT NOCOPY t_coa_text_tbl)  IS
  CURSOR get_order_info
(c_order_id NUMBER,
 c_bol_id   NUMBER,
 c_shipment_no VARCHAR2,
 c_org_id   NUMBER,
 c_cust_id   NUMBER)
 IS
     select l.header_id order_id,
           l.line_id line_id,
           wdd.delivery_detail_id,
           null orgn_code,
           l.org_id,
           h.order_number order_no,
           h.cust_po_number custpo_no,
           l.schedule_ship_date sched_shipdate,
           l.actual_shipment_date actual_shipdate,
           l.ship_to_org_id ,
           wnd.delivery_id bol_id,
           wnd.name bol_no,
           l.inventory_item_id discrete_item_id,
           ic.item_id item_id,
           ic.item_no,
           ic.item_desc1 item_desc1,
           decode(l.ship_from_org_id, null , h.ship_from_org_id, l.ship_from_org_id) ship_from_org_id,
           ship_from_org.organization_code              from_whse,
           decode(l.line_category_code,'RETURN',(-1)*l.ordered_quantity, l.ordered_quantity )  order_qty1,
           decode(l.line_category_code,'RETURN',(-1)*l.ordered_quantity2,l.ordered_quantity2)  order_qty2,
           l.order_quantity_uom order_um1,
           l.ordered_quantity_UOM2 order_um2,
           wdd.shipped_quantity ship_qty1,
           wdd.shipped_quantity2 ship_qty2,
           C.cust_account_id shipcust_id,
           C.account_number cust_no,
           pr.party_name cust_name ,
           0 alloc_qty
    FROM
         oe_order_headers_all h,
         oe_order_lines_all l,
         wsh_delivery_details wdd,
         wsh_new_deliveries wnd,
         wsh_delivery_assignments wda,
         mtl_parameters ship_from_org,
         mtl_system_items msi,
         ic_item_mst ic,
         hz_cust_accounts              c,
         hz_cust_site_uses_all         s,
         hz_cust_acct_sites_all        a,
         hz_parties    pr
    where h.header_id = l.header_id
    and   l.header_id = wdd.source_header_id
    and   l.line_id   = wdd.source_line_id
    and   wnd.delivery_id= wda.delivery_id
    and   wda.delivery_detail_id  = wdd.delivery_detail_id
    and (c_order_id IS NULL OR h.header_id    = c_order_id)
    and (c_bol_id   IS NULL OR wnd.delivery_id= c_bol_id)
    and (c_shipment_no   IS NULL OR wnd.name= c_shipment_no)
    and (c_org_id   IS NULL OR a.org_id = c_org_id)
    and (c_cust_id   IS NULL OR l.sold_to_org_id = c_cust_id)
    --and   wnd.name = 'passedname'
    and   wdd.source_code ='OE'
    and   l.ship_from_org_id = ship_from_org.organization_id(+)
    and   ship_from_org.process_enabled_flag(+)='Y'
    and   msi.organization_id=decode(l.ship_from_org_id, null , h.ship_from_org_id, l.ship_from_org_id) -- oe_sys_parameters.value('MASTER_ORGANIZATION_ID')
    and   msi.inventory_item_id = l.inventory_item_id
    and   msi.segment1 = ic.item_no
    and   l.ship_to_org_id = s.site_use_id(+)
    and   s.site_use_code(+) ='SHIP_TO'
    and   s.org_id = a.org_id(+)
    and   s.cust_acct_site_id  = a.cust_acct_site_id(+)
    and   a.cust_account_id = c.cust_account_id(+)
    and c.party_id  = pr.party_id(+)
    order by l.header_id
;
  /*CURSOR get_order_info
      (c_order_id NUMBER,  c_from_shipdate DATE,
       c_to_shipdate DATE, c_cust_id NUMBER,
       c_bol_id   NUMBER,  c_item_id NUMBER,
       c_lot_id NUMBER,    c_whse_code VARCHAR2)
   IS
    select ooh.order_id,
          ood.line_id,
          ooh.orgn_code,
          ooh.order_no,
          ooh.custpo_no,
          ood.sched_shipdate,
          ood.actual_shipdate,
          ood.shipcust_id,
          ood.bol_id,
          ood.item_id,
          ood.from_whse,
          ood.generic_id,
          ood.order_qty1,
          ood.order_qty2,
          ood.order_um1,
          ood.order_um2,
          ood.ship_qty1,
          ood.ship_qty2,
          ood.alloc_qty
     from
          op_ordr_hdr ooh,
          op_ordr_dtl ood
    where
          ooh.order_id = ood.order_id
      and (c_from_shipdate is NULL or
           ( (ood.sched_shipdate between c_from_shipdate and c_to_shipdate)
              OR
             (ood.actual_shipdate between c_from_shipdate and c_to_shipdate)
           ))
      and (c_cust_id  IS NULL OR ood.shipcust_id = c_cust_id)
      and (c_order_id IS NULL OR ood.order_id    = c_order_id)
      and (c_bol_id   IS NULL OR ood.bol_id      = c_bol_id)
      and (c_item_id  IS NULL OR ood.item_id     = c_item_id)
      and ood.ship_status <> -1
      and ood.delete_mark = 0
   ; */



   /*CURSOR get_gnrc_info (c_generic_id op_gnrc_itm.generic_id%TYPE) IS
      SELECT generic_item,
             generic_desc
        FROM
             op_gnrc_itm
       WHERE generic_id  = c_generic_id
         and delete_mark = 0
   ;*/

  /* CURSOR get_bol_info (c_bol_id op_bill_lad.bol_no%TYPE) IS
      SELECT bol_no
        FROM
             op_bill_lad
       WHERE bol_id      = c_bol_id
         and delete_mark = 0
   ;*/

  /* CURSOR get_item_info (c_item_id ic_item_mst.item_id%TYPE) IS
      SELECT item_no,
             item_desc1
        FROM
             ic_item_mst
       WHERE item_id     = c_item_id
         and delete_mark = 0
   ;*/

   /*CURSOR get_cust_info (c_cust_id hz_cust_accounts.cust_account_id%TYPE) IS
      SELECT
             custsort_no cust_no,
             cust_name cust_name
      from   op_cust_mst
      WHERE cust_id = c_cust_id
      AND   delete_mark= 0; */

/*  CURSOR get_cust_info (c_ship_to_org_id OE_ORDER_LINES.SHIP_TO_ORG_ID%TYPE) IS
  SELECT
     A.CUST_ACCT_SITE_ID cust_id,
     C.ACCOUNT_NUMBER cust_no,
     PR.PARTY_NAME cust_name
  from
  HZ_CUST_ACCOUNTS              C,
  HZ_CUST_SITE_USES_ALL         S,
  HZ_CUST_ACCT_SITES_ALL        A,
  HZ_PARTIES    PR
  where C.CUST_ACCOUNT_ID = A.CUST_ACCOUNT_ID
  AND S.CUST_ACCT_SITE_ID  = A.CUST_ACCT_SITE_ID
  AND S.SITE_USE_CODE  IN ('SHIP_TO')
  AND A.ORG_ID = S.ORG_ID
  AND C.PARTY_ID  = PR.PARTY_ID
  AND  S.SITE_USE_ID = c_ship_to_org_id
  ;*/


   /*CURSOR get_whse_info (c_whse_code ic_whse_mst.WHSE_CODE%TYPE) IS
      SELECT whse_name
        FROM
             ic_whse_mst
       WHERE
             whse_code   = c_whse_code
         and delete_mark = 0
   ;*/
   CURSOR get_whse_info (c_ship_from_org_id oe_order_lines.ship_from_org_id%TYPE) IS
   SELECT  s.orgn_code,
           w.whse_code,
           w.whse_name
   FROM   mtl_parameters p,
       ic_whse_mst w,
       sy_orgn_mst s
   WHERE
      w.mtl_organization_id   = c_ship_from_org_id
   AND   p.ORGANIZATION_ID       = c_ship_from_org_id
   AND   s.orgn_code             = w.orgn_code
   AND   s.orgn_code             = p.process_orgn_code
   AND   p.process_enabled_flag  ='Y'
   AND   s.delete_mark           = 0
   AND   w.delete_mark           = 0
   ;


   CURSOR get_lot_tran (c_line_id ic_tran_pnd.line_id%TYPE) IS
      SELECT itp.lot_id, itp.whse_code, itp.location
        FROM
             ic_tran_pnd itp
       WHERE
             itp.doc_type      = 'OMSO'
         AND itp.completed_ind <> -1
         AND itp.line_detail_id       = c_line_id
         and itp.delete_mark   = 0
   ;

   CURSOR get_lot_info (c_lot_id ic_lots_mst.lot_id%TYPE) IS
      SELECT ilm.lot_no,
             ilm.lot_desc,
             ilm.sublot_no
        FROM
             ic_lots_mst  ilm
       WHERE
             ilm.lot_id      = c_lot_id
         and ilm.delete_mark = 0
   ;

   ord_cur_rec     get_order_info % ROWTYPE;

   tbl_ndx         BINARY_INTEGER := 0;
                          /* index for pl/sql table */
   l_api_name      CONSTANT     VARCHAR2(30) := 'Populate_CoA_Data';
   l_api_version   CONSTANT     NUMBER       := 1.6;


   /* **************************** main code **************************** */
   BEGIN
   /* select NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'Y')
   INTO l_debug_enabled FROM sys.DUAL; */
   --Bug 3222090, magupta removed call to FND_PROFILE.VALUE('AFLOG_ENABLED')
   if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     l_debug_enabled := 'Y';
   end if;


   /*   Do API standard code for savepoint, messages, initialize return status */
   SAVEPOINT Populate_CoA_Data_SAVE;
   IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                       l_api_name, G_PKG_NAME)  THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   IF FND_API.to_Boolean (p_init_msg_list)  THEN
     FND_MSG_PUB.initialize;
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   v_report_title := 'COA';
   /*IF (l_debug_enabled = 'Y') THEN
     select value into l_utl_file_dir from v$parameter where name like 'utl_file_dir';
     fnd_file.put_names('coacoc.log','coacoc.out',l_utl_file_dir);
     Trace('Log file is '||l_utl_file_dir||'coacoc.log');
   END IF; */
   /*fnd_file.put_names(test.log,test.out,/home/magupta/work/qc/);  */
   --gmd_debug.Log_Initialize('coacocpackage');
   trace('Populate_CoA_Data :- delivery_id '||rec_param.bol_id);
   trace('The value of master organization id is '||oe_sys_parameters.value('MASTER_ORGANIZATION_ID'));
   IF rec_param.shipment_no is not NULL or rec_param.order_id is not NULL or rec_param.bol_id is not NULL
      or rec_param.from_shipdate is not NULL or rec_param.org_id IS NOT NULL or rec_param.item_id IS NOT NULL    THEN
                          /*-  or rec_param.cust_po is not NULL */
     OPEN get_order_info (rec_param.order_id,
                          rec_param.bol_id,
                          rec_param.shipment_no,
                          rec_param.org_id,
                          rec_param.cust_id
                          );
     FETCH get_order_info INTO ord_cur_rec;

     <<order_loop>>
     WHILE  ( get_order_info % FOUND )  LOOP
       tbl_ndx := tbl_ndx + 1;
       /* BEGIN BUG#1810652 James Bernard */
       /* Properly commented the next line. Prior to the fix there */
       /* was only the opening slash and asterisk */
                              /* replace with next_val.sequence */
       /* END BUG#1810652                */
       tbl_hdr(tbl_ndx).gmd_coa_id      := tbl_ndx;
        tbl_hdr(tbl_ndx).org_id      := ord_cur_rec.org_id;
       tbl_hdr(tbl_ndx).order_id        := ord_cur_rec.order_id;
       tbl_hdr(tbl_ndx).line_id         := ord_cur_rec.line_id;
       tbl_hdr(tbl_ndx).delivery_detail_id         := ord_cur_rec.delivery_detail_id;
      -- tbl_hdr(tbl_ndx).orgn_code       := ord_cur_rec.orgn_code;
       tbl_hdr(tbl_ndx).order_no        := ord_cur_rec.order_no;
       tbl_hdr(tbl_ndx).custpo_no       := ord_cur_rec.custpo_no;
       tbl_hdr(tbl_ndx).cust_id         := ord_cur_rec.shipcust_id;
       tbl_hdr(tbl_ndx).bol_id          := ord_cur_rec.bol_id;
       tbl_hdr(tbl_ndx).item_id         := ord_cur_rec.item_id;
     --  tbl_hdr(tbl_ndx).whse_code       := ord_cur_rec.from_whse;
       tbl_hdr(tbl_ndx).order_qty1      := ord_cur_rec.order_qty1;
       tbl_hdr(tbl_ndx).order_qty2      := ord_cur_rec.order_qty2;
       tbl_hdr(tbl_ndx).order_um1       := ord_cur_rec.order_um1;
       tbl_hdr(tbl_ndx).order_um2       := ord_cur_rec.order_um2;
       tbl_hdr(tbl_ndx).ship_qty1       := ord_cur_rec.ship_qty1;
       tbl_hdr(tbl_ndx).ship_qty2       := ord_cur_rec.ship_qty2;
       tbl_hdr(tbl_ndx).cust_no   := ord_cur_rec.cust_no;
       tbl_hdr(tbl_ndx).cust_name := ord_cur_rec.cust_name;
       tbl_hdr(tbl_ndx).bol_no := ord_cur_rec.bol_no;
       tbl_hdr(tbl_ndx).item_no   := ord_cur_rec.item_no;
       tbl_hdr(tbl_ndx).item_desc := ord_cur_rec.item_desc1;
       tbl_hdr(tbl_ndx).ship_from_org_id := ord_cur_rec.ship_from_org_id;
       /* if there is an actual date, use it; otherwise use scheduled date */



       IF ord_cur_rec.actual_shipdate is NULL THEN
         tbl_hdr(tbl_ndx).shipdate := ord_cur_rec.sched_shipdate;
       ELSE
         tbl_hdr(tbl_ndx).shipdate := ord_cur_rec.actual_shipdate;
       END IF;
       IF tbl_hdr(tbl_ndx).ship_from_org_id is not NULL THEN
         FOR whse_cur_rec IN get_whse_info (tbl_hdr(tbl_ndx).ship_from_org_id) LOOP
           tbl_hdr(tbl_ndx).whse_code       := whse_cur_rec.whse_code;
           tbl_hdr(tbl_ndx).whse_name   := whse_cur_rec.whse_name;
           tbl_hdr(tbl_ndx).orgn_code   := whse_cur_rec.orgn_code;
         END LOOP;
                              /* end getting warehouse info from ic_whse_mst */
       END IF;



       /*  if generic id exists in sales order record, get item no and desc */
       /*  from op_gnrc_itm, else get item no and desc from ic_item_mst */

   --    IF ord_cur_rec.generic_id is not NULL THEN
   --      FOR gnrc_cur_rec IN get_gnrc_info (ord_cur_rec.generic_id) LOOP
   --         tbl_hdr(tbl_ndx).item_no   := gnrc_cur_rec.generic_item;
   --          tbl_hdr(tbl_ndx).item_desc := gnrc_cur_rec.generic_desc;
   --      END LOOP;
   --                         /* end getting generic item info from table  */
   --   ELSE
   --      FOR item_cur_rec IN get_item_info (ord_cur_rec.item_id) LOOP
    --        tbl_hdr(tbl_ndx).item_no   := item_cur_rec.item_no;
    --        tbl_hdr(tbl_ndx).item_desc := item_cur_rec.item_desc1;
    --     END LOOP;
                             /* end getting item info from ic_item_mst  */
    --   END IF;
                             /* end if generic_id has a value  */
       /* fill in whse, customer name, bol no at end of code  */

       /* get lot id from ic_tran_pnd  */
       /* get lot no and name and sublot no from ic_lot_mst at end of code  */
       /*   (2 steps so non-sales-order loop can also use get_lot_info)  */

      -- IF ord_cur_rec.alloc_qty > 0 THEN
         FOR lot_cur_rec IN get_lot_tran (ord_cur_rec.delivery_detail_id) LOOP
          tbl_hdr(tbl_ndx).lot_id     := lot_cur_rec.lot_id;
         END LOOP;
                              /* end getting lot id from ic_tran_pnd  */
          IF tbl_hdr(tbl_ndx).lot_id is not NULL THEN
           FOR lot_cur_rec IN get_lot_info (tbl_hdr(tbl_ndx).lot_id) LOOP
             tbl_hdr(tbl_ndx).lot_no     := lot_cur_rec.lot_no;
             tbl_hdr(tbl_ndx).lot_desc   := lot_cur_rec.lot_desc;
             tbl_hdr(tbl_ndx).sublot_no  := lot_cur_rec.sublot_no;
           END LOOP;
                              /* end getting lot info from ic_lot_mst  */
          END IF;
                              /* end checking if lot id has a value   */

     --  END IF;
                              /* end checking if alloc qty > 0  */
       /* report title = COA or COC  */
       tbl_hdr(tbl_ndx).report_title := v_report_title;
        p_msg := 'Populate_CoA_Data get_order_info gmd_coa_id '||tbl_hdr(tbl_ndx).gmd_coa_id||' '||
                            'org_id     '||tbl_hdr(tbl_ndx).org_id||' '||
                            'order_id     '||tbl_hdr(tbl_ndx).order_id||' '||
                            'line_id     '||tbl_hdr(tbl_ndx).line_id||' '||
                            'order_no     '||tbl_hdr(tbl_ndx).order_no||' '||
                            'custpo_no     '||tbl_hdr(tbl_ndx).custpo_no||' '||
                            'cust_id     '||tbl_hdr(tbl_ndx).cust_id||' '||
                            'bol_id     '||tbl_hdr(tbl_ndx).bol_id||' '||
                            'item_id     '||tbl_hdr(tbl_ndx).item_id||' '||
                            'order_id     '||tbl_hdr(tbl_ndx).order_id||' '||
                            'whse_code     '||tbl_hdr(tbl_ndx).whse_code||' '||
                            'order_qty1     '||tbl_hdr(tbl_ndx).order_qty1||' '||
                            'order_qty2     '||tbl_hdr(tbl_ndx).order_qty2||' '||
                            'order_um1     '||tbl_hdr(tbl_ndx).order_um1||' '||
                            'ship_qty1     '||tbl_hdr(tbl_ndx).ship_qty1||' '||
                            'ship_qty2     '||tbl_hdr(tbl_ndx).ship_qty2||' '||
                            'cust_no     '||tbl_hdr(tbl_ndx).cust_no||' '||
                            'cust_name     '||tbl_hdr(tbl_ndx).cust_name||' '||
                            'bol_no     '||tbl_hdr(tbl_ndx).bol_no||' '||
                            'item_no     '||tbl_hdr(tbl_ndx).item_no||' '||
                            'lot_id     '||tbl_hdr(tbl_ndx).lot_id||' '||
                            'lot_no     '||tbl_hdr(tbl_ndx).lot_no||' '||
                            'whse_code     '||tbl_hdr(tbl_ndx).whse_code||' '||
                            'orgn_code     '||tbl_hdr(tbl_ndx).orgn_code||' '||
                            'item_desc     '||tbl_hdr(tbl_ndx).item_desc;

       trace(p_msg);


       FETCH get_order_info INTO ord_cur_rec;

     END LOOP order_loop;

     CLOSE get_order_info;

   END IF;



   IF v_report_title <> 'BLK' THEN
     trace('Populate_CoA_Data :- Going to GMD_COA_DATA_OM.Populate_Details');
     GMD_COA_DATA_OM.Populate_Details  (tbl_hdr, tbl_dtl);
     trace('Populate_CoA_Data :- Came Back from GMD_COA_DATA_OM.Populate_Details');

   END IF;

   IF tbl_dtl.EXISTS(1) THEN
     GMD_COA_DATA_OM.Populate_Text (tbl_dtl, tbl_spec_text, tbl_rslt_text);
   ELSE
     tbl_hdr := empty_header;
                                /* if there is nothing in details, empty headers  */
                                /* this is not an error.  Report will be empty   */
     tbl_ndx := 0;
   END IF;

   /* *********************************************************************** --  */
   /* now fill in lookup columns (whse name, customer name, bol_no, lot_no)  */
   /* and make sure report_title is accurate  (gets a little messy if   */
   /* sales/ship info given and no results (CoC)  */

   IF tbl_ndx > 0 THEN

     /*BEGIN BUG#1810652 James Bernard                    */
     /*Changed tbl_hdr.FIRST to NVL(tbl_hdr.FIRST,0) and  */
     /*tbl_hdr.LAST to NVL(tbl_hdr.LAST,0)                */
     FOR loop_counter IN NVL(tbl_hdr.FIRST,0) .. NVL(tbl_hdr.LAST,0) LOOP
     /*END BUG#1810652                                    */

         /* if sales/ship data given and no results, only specs exists,  */
         /* reset report_title in tbl_hdr to v_report_title (tbl_hdr is IN  */
         /* var to Populate_Details, so cannot change report_title there.)  */

       tbl_hdr(loop_counter).report_title := v_report_title;

       /* get bol (shipping no) from op_bill_lad  */

     --  IF tbl_hdr(loop_counter).bol_id is not NULL THEN
     --    FOR bol_cur_rec IN get_bol_info (tbl_hdr(loop_counter).bol_id) LOOP
     --       tbl_hdr(loop_counter).bol_no := bol_cur_rec.bol_no;
     --    END LOOP;
                             /* end getting bol (shipping) info from op_bill_lad  */
     --  END IF;
                             /* end checking if bol id has a value  */
       /* get customer no and name from op_cust_mst tables  */

     --  IF tbl_hdr(loop_counter).cust_id is not NULL THEN
     --    FOR cust_cur_rec IN get_cust_info (tbl_hdr(loop_counter).cust_id) LOOP
      --     tbl_hdr(loop_counter).cust_no   := cust_cur_rec.cust_no;
     --      tbl_hdr(loop_counter).cust_name := cust_cur_rec.cust_name;
      --   END LOOP;
                              /* end getting cust info from hz tables */
    --   END IF;
                              /* end checking if cust id has a value */

       /* get item no and description from ic_item_mst if it was not */
       /* selected as part of generic item check. */
       /* It is correct to check item_NO, not item_ID! */

    --   IF tbl_hdr(loop_counter).item_no is NULL THEN
    --     FOR item_cur_rec IN get_item_info (tbl_hdr(loop_counter).item_id) LOOP
    --       tbl_hdr(loop_counter).item_no   := item_cur_rec.item_no;
    --       tbl_hdr(loop_counter).item_desc := item_cur_rec.item_desc1;
     --    END LOOP;
                              /* end getting item info from ic_item_mst */
    --   END IF;
                              /* end checking if item id has a value */


       /* get lot no, sublot no and lot desc from ic_lots_mst  */
       /* if pkg called from report, lot id must have value  */
       /* else if called from opm portal, lot may be null  */
     --  IF tbl_hdr(loop_counter).lot_id is not NULL THEN
     --    FOR lot_cur_rec IN get_lot_info (tbl_hdr(loop_counter).lot_id) LOOP
     --      tbl_hdr(loop_counter).lot_no     := lot_cur_rec.lot_no;
     --      tbl_hdr(loop_counter).lot_desc   := lot_cur_rec.lot_desc;
     --      tbl_hdr(loop_counter).sublot_no  := lot_cur_rec.sublot_no;
     --    END LOOP;
                              /* end getting lot info from ic_lot_mst  */
     --  END IF;
                              /* end checking if lot id has a value   */
     END LOOP;
                              /* end loop to fill in lookup columns  */
   ELSE                       /* no header records found  */
     tbl_hdr := empty_header;
                              /* this is not an error.  Report will be empty   */
   END IF;
                              /* end if there are any records in header table  */

   /*  -- standard check of p_commit  */
   IF FND_API.To_Boolean(p_commit) THEN
     COMMIT WORK;
   END IF;
   /* --  standard call to get message count and if count is 1, get message info  */
   FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
   --fnd_file.close;
   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO Populate_CoA_Data_Save;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO Populate_CoA_Data_Save;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS THEN
       ROLLBACK TO Populate_CoA_Data_Save;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);

  END Populate_CoA_Data;


  /*###############################################################
  # NAME
  #	dump_to_db_tables
  # SYNOPSIS
  #	proc dump_to_db_tables
  #      parms event
  #     This is a debug procedure to put data from plsql tables into
  #       physical database tables.
  #     p_commit should always be TRUE
  # DESCRIPTION
  # HISTORY
  # 12jun2001 James Bernard Bug 1810652
  #   In the For cursors tbl_hdr.FIRST, tbl_hdr.LAST ,tbl_spec_text.FIRST,
  #   tbl_spec_text.LAST,tbl_rslt_text.FIRST and tbl_rslt_text.LAST
  #   are replaced with NVL(tbl_hdr.FIRST,0).
  #   NVL(tbl_hdr.LAST,0),NVL(tbl_spec_text.FIRST,0)
  #   NVL(tbl_spec_text.LAST,0),NVL(tbl_rslt_text.FIRST,0) and
  #   NVL(tbl_rslt_text.LAST,0) respectively.
  ################################################################*/


  PROCEDURE Dump_To_Db_Tables (
                     p_api_version   In NUMBER,
                     p_init_msg_list IN VARCHAR2  := FND_API.G_FALSE,
                     p_commit        IN VARCHAR2  := FND_API.G_FALSE,
                     p_validation_level IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
                     tbl_hdr         IN  t_coa_header_tbl,
                     tbl_dtl         IN  t_coa_detail_tbl,
                     tbl_spec_text   IN  t_coa_text_tbl,
                     tbl_rslt_text   IN  t_coa_text_tbl,
                     x_return_status OUT NOCOPY VARCHAR2,
                     x_msg_count     OUT NOCOPY NUMBER,
                     x_msg_data      OUT NOCOPY VARCHAR2) IS

   X_user_id      NUMBER;
   X_login_id     NUMBER;
   X_date         DATE;
   l_api_name     CONSTANT     VARCHAR2(30) := 'Dump_To_Db_Tables';
   l_api_version  CONSTANT     NUMBER       := 1.6;

  begin

   IF FND_API.to_Boolean (p_init_msg_list)  THEN
     FND_MSG_PUB.initialize;
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   /* *******  if db table is necessary   and for debugging  *****  --  */

   delete from gmd_coa_headers;
   delete from gmd_coa_details;
   delete from gmd_coa_spec_text;
   delete from gmd_coa_rslt_text;

   /*  --   Do API standard code for savepoint, messages, initialize return status  */
   SAVEPOINT Dump_To_Db_Tables_SAVE;
   IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                       l_api_name, G_PKG_NAME)  THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF tbl_hdr.FIRST is not NULL THEN
     X_user_id  := FND_GLOBAL.USER_ID;
     X_login_id := FND_GLOBAL.LOGIN_ID;

     /*BEGIN BUG#1810652 James Bernard                   */
     /*Changed tbl_hdr.FIRST to NVL(tbl_hdr.FIRST,0) and */
     /*tbl_hdr.LAST to NVL(tbl_hdr.LAST,0)               */
     FOR loop_counter IN NVL(tbl_hdr.FIRST,0) .. NVL(tbl_hdr.LAST,0) LOOP
     /*END BUG#1810652         */
       INSERT into gmd_coa_headers (gmd_coa_id, order_id, line_id, orgn_code,
                                    order_no,
                                    custpo_no,
                                    shipdate, cust_id, cust_no, cust_name,
                                    bol_id, bol_no, item_id,
                                    item_no, item_desc1,
                                    whse_code, whse_name,
                                    lot_id, lot_no, lot_desc, sublot_no,
                                    order_qty1, order_um1, order_qty2,
                                    order_um2, ship_qty1, ship_qty2,
                                    report_title,
                                    created_by, creation_date, last_update_date,
                                    last_updated_by, last_update_login)
         VALUES (tbl_hdr(loop_counter).gmd_coa_id,
                 tbl_hdr(loop_counter).order_id,
                 tbl_hdr(loop_counter).line_id,
                 tbl_hdr(loop_counter).orgn_code,
                 tbl_hdr(loop_counter).order_no,
                 tbl_hdr(loop_counter).custpo_no,
                 tbl_hdr(loop_counter).shipdate,
                 tbl_hdr(loop_counter).cust_id,
                 tbl_hdr(loop_counter).cust_no,
                 tbl_hdr(loop_counter).cust_name,
                 tbl_hdr(loop_counter).bol_id,
                 tbl_hdr(loop_counter).bol_no,
                 tbl_hdr(loop_counter).item_id,
                 tbl_hdr(loop_counter).item_no,
                 tbl_hdr(loop_counter).item_desc,
                 tbl_hdr(loop_counter).whse_code,
                 tbl_hdr(loop_counter).whse_name,
                 tbl_hdr(loop_counter).lot_id,
                 tbl_hdr(loop_counter).lot_no,
                 tbl_hdr(loop_counter).lot_desc,
                 tbl_hdr(loop_counter).sublot_no,
                 tbl_hdr(loop_counter).order_qty1,
                 tbl_hdr(loop_counter).order_um1,
                 tbl_hdr(loop_counter).order_qty2,
                 tbl_hdr(loop_counter).order_um2,
                 tbl_hdr(loop_counter).ship_qty1,
                 tbl_hdr(loop_counter).ship_qty2,
                 tbl_hdr(loop_counter).report_title,
                 X_user_id, SYSDATE, SYSDATE, X_user_id, X_login_id
                );
       END LOOP;

     IF tbl_dtl.FIRST is not NULL THEN
       /*  -- *******  if db table is necessary and for debugging  *****  --  */
       /*BEGIN BUG#1810652 James Bernard                          */
       /*Changed tbl_dtl.FIRST to NVL(tbl_dtl.FIRST,0) and        */
       /*tbl_dtl.LAST to NVL(tbl_dtl.LAST,0)                      */
       FOR loop_counter IN NVL(tbl_dtl.FIRST,0) .. NVL(tbl_dtl.LAST,0) LOOP
       /*END BUG#1810652                 */
         INSERT into gmd_coa_details (gmd_coa_id, qc_result_id,  result_date,
                                      qc_spec_id, assay_code,    assay_desc,
                                      result,     specification, uom,
                                      rslt_text_code, spec_text_code,
                                      created_by, creation_date,
                                      last_update_date,
                                      last_updated_by, last_update_login
                                     )
           VALUES (tbl_dtl(loop_counter).gmd_coa_id,
                   tbl_dtl(loop_counter).qc_result_id,
                   tbl_dtl(loop_counter).result_date,
                   tbl_dtl(loop_counter).qc_spec_id,
                   tbl_dtl(loop_counter).assay_code,
                   tbl_dtl(loop_counter).assay_desc,
                   tbl_dtl(loop_counter).result,
                   tbl_dtl(loop_counter).specification,
                   tbl_dtl(loop_counter).uom,
                   tbl_dtl(loop_counter).rslt_text_code,
                   tbl_dtl(loop_counter).spec_text_code,
                   X_user_id, SYSDATE, SYSDATE, X_user_id, X_login_id
                   );
       END LOOP;
       IF tbl_spec_text.FIRST is not NULL THEN
         /*BEGIN BUG#1810652  James Bernard                          */
         /*Changed tbl_spec_text.FIRST to NVL(tbl_spec_text.FIRST,0) */
         /* and tbl_spec_text.LAST to NVL(tbl_spec_text.LAST,0)      */
         FOR loop_counter IN NVL(tbl_spec_text.FIRST,0) .. NVL(tbl_spec_text.LAST,0) LOOP
         /*END BUG#1810652                 */
           INSERT into gmd_coa_spec_text (gmd_coa_id, text_code,
                                          paragraph_code, line_no, text)
           VALUES (tbl_spec_text(loop_counter).gmd_coa_id,
                   tbl_spec_text(loop_counter).text_code,
                   tbl_spec_text(loop_counter).paragraph_code,
                   tbl_spec_text(loop_counter).line_no,
                   tbl_spec_text(loop_counter).text);
         END LOOP;
       END IF;
                                /* if there is any spec text  */
       IF tbl_rslt_text.FIRST is not NULL THEN
         /*BEGIN BUG#1810652 James Bernard                               */
         /*Changed tbl_rslt_text.FIRST to NVL(tbl_rslt_text.FIRST,0) and */
         /*tbl_rslt_text.LAST to NVL(tbl_rslt_text.LAST,0)               */
         FOR loop_counter IN NVL(tbl_rslt_text.FIRST,0) .. NVL(tbl_rslt_text.LAST,0) LOOP
         /*END BUG#1810652  */
           INSERT into gmd_coa_rslt_text (gmd_coa_id, text_code,
                                          paragraph_code, line_no, text)
           VALUES (tbl_rslt_text(loop_counter).gmd_coa_id,
                   tbl_rslt_text(loop_counter).text_code,
                   tbl_rslt_text(loop_counter).paragraph_code,
                   tbl_rslt_text(loop_counter).line_no,
                   tbl_rslt_text(loop_counter).text);
         END LOOP;
       END IF;
                        /* if there is any results text  */
     ELSE
       NULL;
                        /* empty table is not an error  */
     END if;
                        /* if there is something in details table  */
    ELSE
      NULL;
                        /* empty table is not an error  */
    END IF;
                        /* if there is something in header table  */

    /*  -- standard check of p_commit  */
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    /*  -- standard call to get message count and if count is 1, get message info  */
    FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Dump_To_Db_Tables_Save;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Dump_To_Db_Tables_Save;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);

     WHEN OTHERS THEN
        ROLLBACK TO Dump_To_Db_Tables_Save;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
        FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);

  END Dump_To_Db_Tables;








  PROCEDURE run_coa_coc (
    errbuf              OUT NOCOPY VARCHAR2,
    retcode             OUT NOCOPY NUMBER,
    p_delivery_id number) IS
   --errbuf VARCHAR2(200);
   --retcode NUMBER;

   --  If no spec data is found, the gmd_coa_headers table will be empty

   CURSOR get_report_title IS
       select c.report_title, meaning
         from gem_lookups l, gmd_coa_headers c
        where l.lookup_type  = 'GMD_COA_REPORT_TITLE'
          and l.lookup_code =  c.report_title;

   CURSOR get_report_title_blank IS
       select meaning
         from gem_lookups l
        where l.lookup_type  = 'GMD_COA_REPORT_TITLE'
          and l.lookup_code = 'BLK';


      param_rec     gmd_coa_data_om.t_coa_parameters;
      header_table  gmd_coa_data_om.t_coa_header_tbl;
      detail_table  gmd_coa_data_om.t_coa_detail_tbl;
      spec_text_table    gmd_coa_data_om.t_coa_text_tbl;
      rslt_text_table    gmd_coa_data_om.t_coa_text_tbl;

      X_status	  BOOLEAN;
      X_conc_id	  NUMBER;
      X_which_report VARCHAR2(80);
      X_report_title VARCHAR2(30);

      x_return_status  VARCHAR2(1);
      x_msg_count      NUMBER;
      x_msg_data       VARCHAR2(2000);

      p_init_msg_list     VARCHAR2(1);
      p_commit            VARCHAR2(1);
      p_validation_level  NUMBER;
      p_api_version_populate  CONSTANT NUMBER := 1.5;
      p_api_version_dump      CONSTANT NUMBER := 1.5;
      rqid           NUMBER:=0;
      rdata          VARCHAR2(10);
      l_i            NUMBER;

   begin

      param_rec.order_id      := null; --:qcrcoa01.order_id;
      param_rec.orgn_code     := null;--:qcrcoa01.orgn_code;
      param_rec.from_shipdate := null; --:qcrcoa01.from_shipdate;
      param_rec.to_shipdate   :=null; -- :qcrcoa01.to_shipdate;
      param_rec.cust_id       :=null; -- :qcrcoa01.shipcust_id;
      param_rec.bol_id        :=p_delivery_id; -- :qcrcoa01.bol_id;
      param_rec.item_id       :=null; -- :qcrcoa01.item_id;
      param_rec.whse_code     :=null; -- :qcrcoa01.whse_code;
      param_rec.lot_id        :=null; -- :qcrcoa01.lot_id;
      param_rec.shipment_no   := null;

      p_init_msg_list    := 'T';
      p_commit           := 'T';
      p_validation_level := 0;
      Trace('run_coa_coc : Going to gmd_coa_data_om.populate_coa_data, Shipment No '|| param_rec.shipment_no);
      gmd_coa_data_om.populate_coa_data (
                                      p_api_version_populate,
                                      p_init_msg_list,
                                      p_commit,
                                      p_validation_level,
                                      param_rec,
                                      x_return_status, x_msg_count, x_msg_data,
                                      header_table, detail_table,
                                      spec_text_table, rslt_text_table);

       Trace('run_coa_coc : Coming from  gmd_coa_data_om.populate_coa_data, x_return_status'||x_return_status);
      IF x_return_status = 'S' THEN                       -- #1

        -- check if plsql tables have any data.
        -- If so, do dump to db tables and call concurrent manager for report.
        -- else give user 'blank report' message.

        p_init_msg_list    := 'F';
        Trace('run_coa_coc : calling gmd_coa_data_om.dump_to_db_tables ');
        gmd_coa_data_om.dump_to_db_tables (
                                      p_api_version_dump,
                                      p_init_msg_list,
                                      p_commit,
                                      p_validation_level,
                                      header_table, detail_table,
                                      spec_text_table, rslt_text_table,
                                      x_return_status, x_msg_count, x_msg_data);
        Trace('run_coa_coc : returning from  gmd_coa_data_om.dump_to_db_tables, x_return_status'||x_return_status);


        IF x_return_status = 'S' THEN                   -- #2
          OPEN   get_report_title;
          FETCH  get_report_title into x_report_title, x_which_report;
          CLOSE  get_report_title;

          IF x_report_title IS NOT NULL THEN             -- #3

            rqid := FND_GLOBAL.CONC_REQUEST_ID;
            rdata := fnd_conc_global.request_data;
            if (rdata is not null) then
		errbuf := 'Done';
		retcode := 0 ;
		return;
	    else
		l_i := 1;
	    end if;

            X_conc_id := FND_REQUEST.SUBMIT_REQUEST('GMD','QCRCOA02','', '',TRUE,
                                                to_char(0),
    					      '','','','','','','','','',
					      '','','','','','','','','','',
					      '','','','','','','','','','',
					      '','','','','','','','','','',
					      '','','','','','','','','','',
					      '','','','','','','','','','',
					      '','','','','','','','','','',
					      '','','','','','','','','','',
					      '','','','','','','','','','',
					      '','','','','','','','','','');
            IF X_conc_id = 0 THEN                            -- #4
               null;
               errbuf := 'Unable to submit concurrent request for QCRCOA02 ...';
               retcode := -1;
            ELSE
              fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
                                        request_data => l_i);
              errbuf := 'Sub Requests Submitted.';
              retcode := 0;


            END IF;     -- end if #4 concurrent manager returned conc_id or not
          ELSE          -- x_report_title IS NULL    #3
            OPEN   get_report_title_blank;
            FETCH  get_report_title_blank into x_which_report;
            CLOSE  get_report_title_blank;
          END IF;       -- end if #3 plsql table has rows (data found)
        END IF;       -- end if #2 stored procedure dump-to-db ended with success

            -- coa table will have 3-char code for if stored procedure found COA
            -- data or COC data.  Pass lookup value for that code to message to
            -- be displayed so user knows which one is being run.
         /*writelog('GMD_COA_REPORT_SUBMITTED','GMD' , 'COA_REPORT_TITLE', x_which_report); */
      END IF;                    -- end if (#1) 1st api call retured success

      IF x_return_status <> 'S' THEN

         errbuf := 'Error';
         retcode :=-1;

      END IF;                                 -- end if api returned Success or not

  END run_coa_coc;



END GMD_CoA_Data_OM;

/
