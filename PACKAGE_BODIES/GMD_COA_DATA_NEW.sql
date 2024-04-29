--------------------------------------------------------
--  DDL for Package Body GMD_COA_DATA_NEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_COA_DATA_NEW" AS
/* $Header: GMDCOA2B.pls 115.2 2002/12/05 18:02:52 magupta noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'GMD_COA_DATA_NEW';
      /*   next variable is version for Look_for_CoC_Data   */


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
                     hdr_tbl_ndx     OUT NOCOPY  BINARY_INTEGER,
                     tbl_hdr      IN OUT  NOCOPY t_coa_header_tbl,
                     tbl_dtl      IN OUT  NOCOPY t_coa_detail_tbl)
     IS
         /*   get cust spec else get global cust spec       */
         /*   else get item spec else get global item spec  */
     /* BEGIN BUG#1810652 James Bernard                     */
     /* Added 'c_item_id is NULL or' in the where clause    */
     CURSOR get_qc_cust_spec (c_cust_id NUMBER,   c_item_id NUMBER,
                              c_orgn_code VARCHAR2)
      IS
         select gcs.orgn_code,
          gcs.cust_id,
          gsb.item_id,
          null whse_code,
          null lot_id,
          gsb.spec_id qc_spec_id,
          gt.test_code assay_code,
          decode (gst.target_value_char, null, to_char(gst.target_value_num), gst.target_value_char)
                                                                 specification,
          gst.test_uom uom,
          gcs.text_code  spec_text_code
        from
          gmd_specifications_b gsb, -- qc_spec_mst qsm
          gmd_customer_spec_vrs gcs,
          gmd_spec_tests_b gst,
          gmd_qc_tests_b gt
       where
           gcs.cust_id  = (select of_cust_id from op_cust_mst where cust_id= c_cust_id)
       and (c_item_id is NULL or gsb.item_id       = c_item_id)
       and gcs.orgn_code     = c_orgn_code
       and gsb.spec_id  =  gcs.spec_id
       and gsb.spec_id  =  gst.spec_id
       and gst.test_id  =  gt.test_id
       and gsb.delete_mark   = 0
       ;

     /* END BUG#1810652                                    */
     /* BEGIN BUG#1810652 James Bernard                    */
     /* Added 'c_item_id is NULL or ' in the where clause  */
     CURSOR get_qc_global_cust_spec (c_cust_id  NUMBER,  c_item_id NUMBER)
      IS
      select gcs.orgn_code,
          gcs.cust_id,
          gsb.item_id,
          null whse_code,
          null lot_id,
          gsb.spec_id qc_spec_id,
          gt.test_code assay_code,
          decode (gst.target_value_char, null, to_char(gst.target_value_num), gst.target_value_char)
                                                                 specification,
          gst.test_uom uom,
          gcs.text_code  spec_text_code
        from
          gmd_specifications_b gsb, -- qc_spec_mst qsm
          gmd_customer_spec_vrs gcs,
          gmd_spec_tests_b gst,
          gmd_qc_tests_b gt
       where
           gcs.cust_id  = (select of_cust_id from op_cust_mst where cust_id =  c_cust_id)
       and (c_item_id is NULL or gsb.item_id       = c_item_id)
       and gcs.orgn_code     is null
       and gsb.spec_id  =  gcs.spec_id
       and gsb.spec_id  =  gst.spec_id
       and gst.test_id  =  gt.test_id
       and gsb.delete_mark   = 0
       ;
       /* END BUG#1810652                                     */
       /* instead of 8 cursors with the hierarchy for searching specs       */
       /* 1 cursor has parameters to look for NULLs or not                  */
       /* Cursor should be called in this order:                            */
       /*  FALSE = 0 (off)  TRUE = 1 (on)                                   */
       /*  (1) whse/lot/orgn params FALSE, look for specific whse/lot/orgn  */
       /*  (2) orgn param=TRUE, look for global + specific whse/lot         */
       /*  (3) orgn param=FALSE, lot param=TRUE; local + specific whse + null lot  */
       /*  (4) orgn param=TRUE, lot param=TRUE; global + specific whse + null lot  */
       /*  (5) orgn param=FALSE, whse param=TRUE, lot param=FALSE;          */
       /*                local + null whse + specific lot                   */
       /*  (6) orgn param=TRUE, whse param=TRUE, lot param=FALSE;           */
       /*                global + null whse + specific lot                  */
       /*  (7) orgn param=FALSE, whse param=TRUE, lot param=TRUE;           */
       /*                local + null whse + null lot                       */
       /*  (8) orgn param=TRUE, whse param=TRUE, lot param=TRUE;            */
       /*                global + null whse + null lot                      */

     /* BEGIN BUG#1810652 James Bernard                                     */
     /* Added the 'c_item_id is NULL or' in the where clause                */
     CURSOR get_qc_item_spec (c_item_id NUMBER,     c_lot_id NUMBER,
                              c_whse_code VARCHAR2, c_orgn_code VARCHAR2,
                              l_chk_whse_null NUMBER,
                              l_chk_lot_null  NUMBER,
                              l_chk_orgn_null NUMBER
                              )
      IS
      select gcs.orgn_code,
          null cust_id,
          gsb.item_id,
          gcs.whse_code whse_code,
          gcs.lot_id lot_id,
          gsb.spec_id qc_spec_id,
          gt.test_code assay_code,
          decode (gst.target_value_char, null, to_char(gst.target_value_num), gst.target_value_char)
                                                                 specification,
          gst.test_uom uom,
          gcs.text_code  spec_text_code
        from
          gmd_specifications_b gsb, -- qc_spec_mst qsm
          gmd_inventory_spec_vrs gcs,
          gmd_spec_tests_b gst,
          gmd_qc_tests_b gt
        where
        ((l_chk_whse_null =1 and gcs.whse_code is NULL)
             OR (l_chk_whse_null=0 and
                   (c_whse_code is NULL or gcs.whse_code = c_whse_code)
                )  )
       and ((l_chk_lot_null=1 and gcs.lot_id is NULL)
             OR (l_chk_lot_null=0 and
                   (c_lot_id is NULL or gcs.lot_id = c_lot_id)
                )  )
       and (c_item_id is NULL or gsb.item_id     = c_item_id)
       and ((l_chk_orgn_null=1 and gcs.orgn_code is NULL)
            OR (l_chk_orgn_null=0 and
                   (c_orgn_code is NULL or gcs.orgn_code = c_orgn_code)
                )  )
       and gsb.spec_id  =  gcs.spec_id
       and gsb.spec_id  =  gst.spec_id
       and gst.test_id  =  gt.test_id
       and gsb.delete_mark   = 0
       ;

       /* END BUG#1810652  */

     dtl_tbl_ndx        BINARY_INTEGER := 0;
     v_gmd_coa_id       BINARY_INTEGER := 1;
     v_previous_header  VARCHAR2(75);    /* orgn_code+cust+item+whse+lot */
     v_current_header   VARCHAR2(75);
     l_chk_whse_null    NUMBER;
     l_chk_lot_null     NUMBER;
     l_chk_orgn_null    NUMBER;

     /* ***********************************************************************
      -    Procedure assign_cursor_values_to_table
      -      If there is a way to send a cursor or a row from a cursor as a
      -      variable, change this code!
      - ***********************************************************************/
     PROCEDURE Assign_Cursor_Values_To_Table
                (p_orgn_code      IN op_ordr_hdr.orgn_code%TYPE,
                 p_cust_id        IN op_cust_mst.cust_id%TYPE,
                 p_item_id        IN ic_item_mst.item_id%TYPE,
                 p_whse_code      IN ic_whse_mst.whse_code%TYPE,
                 p_lot_id         IN ic_lots_mst.lot_id%TYPE,
                 p_qc_spec_id     IN gmd_specifications_b.spec_id%TYPE,
                 p_assay_code     IN gmd_qc_tests_b.test_code%TYPE,
                 p_specification  IN gmd_spec_tests.target_value_char%TYPE,
                 p_UOM            IN gmd_qc_tests_b.test_unit%TYPE,
                 p_spec_text_code IN gmd_specifications_b.text_code%TYPE)
       IS
     BEGIN
       dtl_tbl_ndx  := dtl_tbl_ndx + 1;

       IF hdr_tbl_ndx = 0 THEN
          tbl_dtl(dtl_tbl_ndx).gmd_coa_id     :=1 ;
       ELSE
          tbl_dtl(dtl_tbl_ndx).gmd_coa_id     := hdr_tbl_ndx;
       END IF;             /* --  end if hdr tbl ndx is 0 or greater than 0 */
       tbl_dtl(dtl_tbl_ndx).qc_spec_id     := p_qc_spec_id;
       tbl_dtl(dtl_tbl_ndx).assay_code     := p_assay_code;
       tbl_dtl(dtl_tbl_ndx).specification  := p_specification;

       tbl_dtl(dtl_tbl_ndx).uom            := p_uom;
       tbl_dtl(dtl_tbl_ndx).spec_text_code := p_spec_text_code;

       v_current_header := p_orgn_code || p_cust_id ||
                           p_item_id || p_whse_code ||
                           p_lot_id;

       IF v_previous_header is not NULL THEN
           IF v_previous_header <> v_current_header THEN
             hdr_tbl_ndx  := hdr_tbl_ndx + 1;
             tbl_hdr(hdr_tbl_ndx).gmd_coa_id   := hdr_tbl_ndx;
             tbl_hdr(hdr_tbl_ndx).orgn_code    := p_orgn_code;
             tbl_hdr(hdr_tbl_ndx).cust_id      := p_cust_id;
             tbl_hdr(hdr_tbl_ndx).item_id      := p_item_id;
             tbl_hdr(hdr_tbl_ndx).whse_code    := p_whse_code;
             tbl_hdr(hdr_tbl_ndx).lot_id       := p_lot_id;
             tbl_hdr(hdr_tbl_ndx).report_title := v_report_title;
           END IF;
           v_previous_header := v_current_header;
       ELSE              /* -- else this is the very first record  */
           v_previous_header := p_orgn_code || p_cust_id ||
                                p_item_id || p_whse_code ||
                                p_lot_id;
           hdr_tbl_ndx  := hdr_tbl_ndx + 1;
           tbl_hdr(hdr_tbl_ndx).gmd_coa_id   := hdr_tbl_ndx;
           tbl_hdr(hdr_tbl_ndx).orgn_code    := p_orgn_code;
           tbl_hdr(hdr_tbl_ndx).cust_id      := p_cust_id;
           tbl_hdr(hdr_tbl_ndx).item_id      := p_item_id;
           tbl_hdr(hdr_tbl_ndx).whse_code    := p_whse_code;
           tbl_hdr(hdr_tbl_ndx).lot_id       := p_lot_id;
           tbl_hdr(hdr_tbl_ndx).report_title := v_report_title;
       END IF;           /* --  end if this is 1st record or not */
     END  Assign_Cursor_Values_To_Table;

     BEGIN
       /*  if customer parameter was given, look for customer-specific spec,
        *     then global spec
        *  if no customer results found, look for item/loc/lot-specific result
        *  Fill in whse, customer name, lot no at end of main code

        *  Parameters given would lead to either a cust spec or a global cust
        *    spec or an item spec (or no spec).
        *  Cursors have been designed to bring back all info needed for header
        *    and for detail.  So that header table will not have duplicates,
        *    code will check header info against previous and only add to header
        *    table when header info changes.                                  */

       hdr_tbl_ndx := 0;
       dtl_tbl_ndx := 0;
       l_chk_whse_null := 0;    /* --  1st time thru, look for match */
       l_chk_orgn_null := 0;
       l_chk_lot_null  := 0;

       IF tbl_hdr.FIRST is NULL THEN
           /* if no sales/ship data was given (item/lot only)  and (therefore) */
           /* there is no data in header table, use this code which puts data  */
           /* in both header and detail tables.                                */
         IF rec_param.cust_id is not NULL THEN

           FOR qc_cur_rec IN get_qc_cust_spec (rec_param.cust_id,
                                               rec_param.item_id,
                                               rec_param.orgn_code) LOOP
             Assign_Cursor_Values_To_Table (qc_cur_rec.orgn_code,
                                            qc_cur_rec.cust_id,
                                            qc_cur_rec.item_id,
                                            qc_cur_rec.whse_code,
                                            qc_cur_rec.lot_id,
                                            qc_cur_rec.qc_spec_id,
                                            qc_cur_rec.assay_code,
                                            qc_cur_rec.specification,
                                            qc_cur_rec.uom,
                                            qc_cur_rec.spec_text_code );
           END LOOP;     /*  --  end get CoC cust spec  */
           IF hdr_tbl_ndx = 0 THEN
                        /*  -- try for global customer spec  */
             FOR qc_cur_rec IN get_qc_global_cust_spec
                                                 (rec_param.cust_id,
                                                  rec_param.item_id )  LOOP
               Assign_Cursor_Values_To_Table (qc_cur_rec.orgn_code,
                                              qc_cur_rec.cust_id,
                                              qc_cur_rec.item_id,
                                              qc_cur_rec.whse_code,
                                              qc_cur_rec.lot_id,
                                              qc_cur_rec.qc_spec_id,
                                              qc_cur_rec.assay_code,
                                              qc_cur_rec.specification,
                                              qc_cur_rec.uom,
                                              qc_cur_rec.spec_text_code );
             END LOOP;
                      /* --  end get global cust spec  */
           END IF;
                      /* -- end if no orgn/cust spec found, look for global spec  */

         END IF;
                      /* -- end if cust parameter has value,   */
                      /* -- then look for cust-specific result  */

         IF hdr_tbl_ndx = 0  THEN
           /* no customer specific spec found, or no customer id given as  */
           /*   parameter, look for local item/lot/whse specs  */
           /* (1)  */
           FOR qc_cur_rec IN get_qc_item_spec (rec_param.item_id,
                                               rec_param.lot_id,
                                               rec_param.whse_code,
                                               rec_param.orgn_code,
                                               l_chk_whse_null,
                                               l_chk_lot_null,
                                               l_chk_orgn_null ) LOOP
               Assign_Cursor_Values_To_Table (qc_cur_rec.orgn_code,
                                              qc_cur_rec.cust_id,
                                              qc_cur_rec.item_id,
                                              qc_cur_rec.whse_code,
                                              qc_cur_rec.lot_id,
                                              qc_cur_rec.qc_spec_id,
                                              qc_cur_rec.assay_code,
                                              qc_cur_rec.specification,
                                              qc_cur_rec.uom,
                                              qc_cur_rec.spec_text_code );
           END LOOP;
                     /*  -- end get item from item/lot/loc spec  */
         END IF;
                     /*  -- end if no cust-specific spec, then look for   */
                     /*  --   local item/loc/lot spec  */

         IF hdr_tbl_ndx = 0  THEN
           /* no local item/lot/whse specs, look for global  */
           /* (2)  */
           l_chk_orgn_null := 1;

           FOR qc_cur_rec IN get_qc_item_spec (rec_param.item_id,
                                               rec_param.lot_id,
                                               rec_param.whse_code,
                                               rec_param.orgn_code,
                                               l_chk_whse_null,
                                               l_chk_lot_null,
                                               l_chk_orgn_null ) LOOP
               Assign_Cursor_Values_To_Table (qc_cur_rec.orgn_code,
                                              qc_cur_rec.cust_id,
                                              qc_cur_rec.item_id,
                                              qc_cur_rec.whse_code,
                                              qc_cur_rec.lot_id,
                                              qc_cur_rec.qc_spec_id,
                                              qc_cur_rec.assay_code,
                                              qc_cur_rec.specification,
                                              qc_cur_rec.uom,
                                              qc_cur_rec.spec_text_code );
           END LOOP;
                   /* -- end get item from item/lot/loc spec  */
         END IF;
                   /* -- end if no local item/lot/whse spec, then look for   */
                   /* --  global item/loc/lot spec  */

         IF hdr_tbl_ndx = 0  THEN
           /* no global item/lot/whse specs, look for local item/whse  */
           /* (3)  */
           l_chk_orgn_null := 0;
           l_chk_lot_null  := 1;

           FOR qc_cur_rec IN get_qc_item_spec (rec_param.item_id,
                                               rec_param.lot_id,
                                               rec_param.whse_code,
                                               rec_param.orgn_code,
                                               l_chk_whse_null,
                                               l_chk_lot_null,
                                               l_chk_orgn_null ) LOOP
               Assign_Cursor_Values_To_Table (qc_cur_rec.orgn_code,
                                              qc_cur_rec.cust_id,
                                              qc_cur_rec.item_id,
                                              qc_cur_rec.whse_code,
                                              qc_cur_rec.lot_id,
                                              qc_cur_rec.qc_spec_id,
                                              qc_cur_rec.assay_code,
                                              qc_cur_rec.specification,
                                              qc_cur_rec.uom,
                                              qc_cur_rec.spec_text_code );
           END LOOP;
                     /* end get item from item/lot/loc spec  */
         END IF;
                     /* end if no global item/lot/whse spec, then look for   */
                     /*   local item/whse spec  */

         IF hdr_tbl_ndx = 0  THEN
           /* no local item/whse specs, look for global item/whse  */
           /* (4)  */
           l_chk_orgn_null := 1;
           l_chk_lot_null  := 1;

           FOR qc_cur_rec IN get_qc_item_spec (rec_param.item_id,
                                               rec_param.lot_id,
                                               rec_param.whse_code,
                                               rec_param.orgn_code,
                                               l_chk_whse_null,
                                               l_chk_lot_null,
                                               l_chk_orgn_null ) LOOP
               Assign_Cursor_Values_To_Table (qc_cur_rec.orgn_code,
                                              qc_cur_rec.cust_id,
                                              qc_cur_rec.item_id,
                                              qc_cur_rec.whse_code,
                                              qc_cur_rec.lot_id,
                                              qc_cur_rec.qc_spec_id,
                                              qc_cur_rec.assay_code,
                                              qc_cur_rec.specification,
                                              qc_cur_rec.uom,
                                              qc_cur_rec.spec_text_code );
           END LOOP;
                     /* end get item from item/lot/loc spec  */
         END IF;
                     /* end if no local item/whse spec, look for global  */

         IF hdr_tbl_ndx = 0  THEN
           /* no global item/whse specs, look for local item/lot   */
           /* (5)  */
           l_chk_orgn_null := 0;
           l_chk_lot_null  := 0;
           l_chk_whse_null := 1;

           FOR qc_cur_rec IN get_qc_item_spec (rec_param.item_id,
                                               rec_param.lot_id,
                                               rec_param.whse_code,
                                               rec_param.orgn_code,
                                               l_chk_whse_null,
                                               l_chk_lot_null,
                                               l_chk_orgn_null ) LOOP
               Assign_Cursor_Values_To_Table (qc_cur_rec.orgn_code,
                                              qc_cur_rec.cust_id,
                                              qc_cur_rec.item_id,
                                              qc_cur_rec.whse_code,
                                              qc_cur_rec.lot_id,
                                              qc_cur_rec.qc_spec_id,
                                              qc_cur_rec.assay_code,
                                              qc_cur_rec.specification,
                                              qc_cur_rec.uom,
                                              qc_cur_rec.spec_text_code );
           END LOOP;
                     /* end get item from item/lot/loc spec  */
         END IF;
                     /* end if no global item/lot/whse spec, then look for   */
                     /*   local item/lot  spec  */

         IF hdr_tbl_ndx = 0  THEN
           /* no local item/lot  specs, look for global  item/lot  */
           /* (6)  */
           l_chk_orgn_null := 1;
           l_chk_lot_null  := 0;
           l_chk_whse_null := 1;

           FOR qc_cur_rec IN get_qc_item_spec (rec_param.item_id,
                                               rec_param.lot_id,
                                               rec_param.whse_code,
                                               rec_param.orgn_code,
                                               l_chk_whse_null,
                                               l_chk_lot_null,
                                               l_chk_orgn_null ) LOOP
               Assign_Cursor_Values_To_Table (qc_cur_rec.orgn_code,
                                              qc_cur_rec.cust_id,
                                              qc_cur_rec.item_id,
                                              qc_cur_rec.whse_code,
                                              qc_cur_rec.lot_id,
                                              qc_cur_rec.qc_spec_id,
                                              qc_cur_rec.assay_code,
                                              qc_cur_rec.specification,
                                              qc_cur_rec.uom,
                                              qc_cur_rec.spec_text_code );
           END LOOP;
                     /* end get item from item/lot/loc spec  */
         END IF;
                     /* end if no local item/lot  spec, look for global  */

         IF hdr_tbl_ndx = 0  THEN
           /* no global item/lot  specs, look for local item only  */
           /* (7)  */
           l_chk_orgn_null := 0;
           l_chk_lot_null  := 1;
           l_chk_whse_null := 1;

           FOR qc_cur_rec IN get_qc_item_spec (rec_param.item_id,
                                               rec_param.lot_id,
                                               rec_param.whse_code,
                                               rec_param.orgn_code,
                                               l_chk_whse_null,
                                               l_chk_lot_null,
                                               l_chk_orgn_null ) LOOP
               Assign_Cursor_Values_To_Table (qc_cur_rec.orgn_code,
                                              qc_cur_rec.cust_id,
                                              qc_cur_rec.item_id,
                                              qc_cur_rec.whse_code,
                                              qc_cur_rec.lot_id,
                                              qc_cur_rec.qc_spec_id,
                                              qc_cur_rec.assay_code,
                                              qc_cur_rec.specification,
                                              qc_cur_rec.uom,
                                              qc_cur_rec.spec_text_code );
           END LOOP;
                     /* end get item from item/lot/loc spec  */
         END IF;
                     /* end if no global item/lotspec, then look for   */
                     /*   local item-only spec  */

         IF hdr_tbl_ndx = 0  THEN
           /* no local item-only specs, look for global  item-only  */
           /* (8)  */
           l_chk_orgn_null := 1;
           l_chk_lot_null  := 1;
           l_chk_whse_null := 1;

           FOR qc_cur_rec IN get_qc_item_spec (rec_param.item_id,
                                               rec_param.lot_id,
                                               rec_param.whse_code,
                                               rec_param.orgn_code,
                                               l_chk_whse_null,
                                               l_chk_lot_null,
                                               l_chk_orgn_null ) LOOP
               Assign_Cursor_Values_To_Table (qc_cur_rec.orgn_code,
                                              qc_cur_rec.cust_id,
                                              qc_cur_rec.item_id,
                                              qc_cur_rec.whse_code,
                                              qc_cur_rec.lot_id,
                                              qc_cur_rec.qc_spec_id,
                                              qc_cur_rec.assay_code,
                                              qc_cur_rec.specification,
                                              qc_cur_rec.uom,
                                              qc_cur_rec.spec_text_code );
           END LOOP;
                     /* end get item from item/lot/loc spec  */
         END IF;
                     /* end if no local item-only spec, look for global  */

       ELSE
           /* sales/ship data was given, header records are already created.  */
           /*  just look for specs and insert data into details table  */

         /*BEGIN BUG#1810652 James Bernard */
         /*Changed tbl_hdr.FIRST to NVL(tbl_hdr.FIRST,0) and           */
         /*tbl_hdr.LAST to NVL(tbl_hdr.LAST,0)                         */
         FOR loop_counter IN NVL(tbl_hdr.FIRST,0) .. NVL(tbl_hdr.LAST,0) LOOP
         /*END BUG#1810652  */
           dtl_tbl_ndx := 0;

           IF tbl_hdr(loop_counter).cust_id is not NULL THEN
             FOR qc_cur_rec IN get_qc_cust_spec
                                         (tbl_hdr(loop_counter).cust_id,
                                          tbl_hdr(loop_counter).item_id,
                                          tbl_hdr(loop_counter).orgn_code) LOOP
               dtl_tbl_ndx  := dtl_tbl_ndx + 1;
               tbl_dtl(dtl_tbl_ndx).gmd_coa_id
                                            := tbl_hdr(loop_counter).gmd_coa_id;
               tbl_dtl(dtl_tbl_ndx).qc_spec_id     := qc_cur_rec.qc_spec_id;
               tbl_dtl(dtl_tbl_ndx).assay_code     := qc_cur_rec.assay_code;
               tbl_dtl(dtl_tbl_ndx).specification  := qc_cur_rec.specification;
               tbl_dtl(dtl_tbl_ndx).uom            := qc_cur_rec.uom;
               tbl_dtl(dtl_tbl_ndx).spec_text_code := qc_cur_rec.spec_text_code;
             END LOOP;
                       /* end get CoC cust spec  */

             IF dtl_tbl_ndx = 0 THEN
                       /* try for global customer specification  */
               FOR qc_cur_rec IN get_qc_global_cust_spec
                                         (tbl_hdr(loop_counter).cust_id,
                                          tbl_hdr(loop_counter).item_id )  LOOP
                 dtl_tbl_ndx  := dtl_tbl_ndx + 1;
                 tbl_dtl(dtl_tbl_ndx).gmd_coa_id
                                            := tbl_hdr(loop_counter).gmd_coa_id;
                 tbl_dtl(dtl_tbl_ndx).qc_spec_id     := qc_cur_rec.qc_spec_id;
                 tbl_dtl(dtl_tbl_ndx).assay_code     := qc_cur_rec.assay_code;
                 tbl_dtl(dtl_tbl_ndx).specification  := qc_cur_rec.specification;
                 tbl_dtl(dtl_tbl_ndx).uom            := qc_cur_rec.uom;
                 tbl_dtl(dtl_tbl_ndx).spec_text_code := qc_cur_rec.spec_text_code;
               END LOOP;
                         /* end get global cust spec  */
             END IF;
                         /* end if no orgn/cust spec found, look for global spec  */
           END IF;
                         /* end if cust parameter has value,   */
                         /* then look for cust-specific result  */

           IF dtl_tbl_ndx = 0  THEN
             /* no customer specific spec found, or no customer id given as  */
             /*   parameter, look for local item/lot/loc spec  */
             /* (1)  */
             FOR qc_cur_rec IN get_qc_item_spec
                                        (tbl_hdr(loop_counter).item_id,
                                         tbl_hdr(loop_counter).lot_id,
                                         tbl_hdr(loop_counter).whse_code,
                                         tbl_hdr(loop_counter).orgn_code,
                                         l_chk_whse_null,
                                         l_chk_lot_null,
                                         l_chk_orgn_null
                                        ) LOOP
               dtl_tbl_ndx  := dtl_tbl_ndx + 1;
               tbl_dtl(dtl_tbl_ndx).gmd_coa_id
                                            := tbl_hdr(loop_counter).gmd_coa_id;
               tbl_dtl(dtl_tbl_ndx).qc_spec_id     := qc_cur_rec.qc_spec_id;
               tbl_dtl(dtl_tbl_ndx).assay_code     := qc_cur_rec.assay_code;
               tbl_dtl(dtl_tbl_ndx).specification  := qc_cur_rec.specification;
               tbl_dtl(dtl_tbl_ndx).uom            := qc_cur_rec.uom;
               tbl_dtl(dtl_tbl_ndx).spec_text_code := qc_cur_rec.spec_text_code;
             END LOOP;
                       /* end get item from local item/lot/loc spec  */
           END IF;
                       /* end if no cust-specific spec, then look for   */
                       /*   local item/loc/lot spec  */

           IF dtl_tbl_ndx = 0  THEN
             /* no local item/lot/whse spec,look for global item specs  */
             /* (2)   */
             l_chk_orgn_null := 1;

             FOR qc_cur_rec IN get_qc_item_spec
                                        (tbl_hdr(loop_counter).item_id,
                                         tbl_hdr(loop_counter).lot_id,
                                         tbl_hdr(loop_counter).whse_code,
                                         tbl_hdr(loop_counter).orgn_code,
                                         l_chk_whse_null,
                                         l_chk_lot_null,
                                         l_chk_orgn_null
                                        ) LOOP
               dtl_tbl_ndx  := dtl_tbl_ndx + 1;
               tbl_dtl(dtl_tbl_ndx).gmd_coa_id
                                            := tbl_hdr(loop_counter).gmd_coa_id;
               tbl_dtl(dtl_tbl_ndx).qc_spec_id     := qc_cur_rec.qc_spec_id;
               tbl_dtl(dtl_tbl_ndx).assay_code     := qc_cur_rec.assay_code;
               tbl_dtl(dtl_tbl_ndx).specification  := qc_cur_rec.specification;
               tbl_dtl(dtl_tbl_ndx).uom            := qc_cur_rec.uom;
               tbl_dtl(dtl_tbl_ndx).spec_text_code := qc_cur_rec.spec_text_code;
             END LOOP;
                       /* end get item from item/lot/whse spec  */
           END IF;
                       /* end if no local item spec, look for global item spec  */

           IF dtl_tbl_ndx = 0  THEN
             /* no global item/lot/whse specs, look for local item/whse  */
             /* (3)  */
             l_chk_orgn_null := 0;
             l_chk_lot_null  := 1;

             FOR qc_cur_rec IN get_qc_item_spec
                                        (tbl_hdr(loop_counter).item_id,
                                         tbl_hdr(loop_counter).lot_id,
                                         tbl_hdr(loop_counter).whse_code,
                                         tbl_hdr(loop_counter).orgn_code,
                                         l_chk_whse_null,
                                         l_chk_lot_null,
                                         l_chk_orgn_null
                                        ) LOOP
               dtl_tbl_ndx  := dtl_tbl_ndx + 1;
               tbl_dtl(dtl_tbl_ndx).gmd_coa_id
                                            := tbl_hdr(loop_counter).gmd_coa_id;
               tbl_dtl(dtl_tbl_ndx).qc_spec_id     := qc_cur_rec.qc_spec_id;
               tbl_dtl(dtl_tbl_ndx).assay_code     := qc_cur_rec.assay_code;
               tbl_dtl(dtl_tbl_ndx).specification  := qc_cur_rec.specification;
               tbl_dtl(dtl_tbl_ndx).uom            := qc_cur_rec.uom;
               tbl_dtl(dtl_tbl_ndx).spec_text_code := qc_cur_rec.spec_text_code;
             END LOOP;
                       /* end get item from item/lot/whse spec  */
           END IF;
                       /* end if no global item/whse/lot spec  */

           IF dtl_tbl_ndx = 0  THEN
             /* no local item/whse spec,look for global item specs  */
             /* (4)   */
             l_chk_orgn_null := 1;
             l_chk_lot_null  := 1;

             FOR qc_cur_rec IN get_qc_item_spec
                                        (tbl_hdr(loop_counter).item_id,
                                         tbl_hdr(loop_counter).lot_id,
                                         tbl_hdr(loop_counter).whse_code,
                                         tbl_hdr(loop_counter).orgn_code,
                                         l_chk_whse_null,
                                         l_chk_lot_null,
                                         l_chk_orgn_null
                                        ) LOOP
               dtl_tbl_ndx  := dtl_tbl_ndx + 1;
               tbl_dtl(dtl_tbl_ndx).gmd_coa_id
                                            := tbl_hdr(loop_counter).gmd_coa_id;
               tbl_dtl(dtl_tbl_ndx).qc_spec_id     := qc_cur_rec.qc_spec_id;
               tbl_dtl(dtl_tbl_ndx).assay_code     := qc_cur_rec.assay_code;
               tbl_dtl(dtl_tbl_ndx).specification  := qc_cur_rec.specification;
               tbl_dtl(dtl_tbl_ndx).uom            := qc_cur_rec.uom;
               tbl_dtl(dtl_tbl_ndx).spec_text_code := qc_cur_rec.spec_text_code;
             END LOOP;
                       /* end get item from local item/lot/whse spec  */
           END IF;
                       /* end if no global/item/whse  */

           IF dtl_tbl_ndx = 0  THEN
             /* no global item/whse specs, look for local item/lot   */
             /* (5)  */
             l_chk_orgn_null := 0;
             l_chk_lot_null  := 0;
             l_chk_whse_null := 1;

             FOR qc_cur_rec IN get_qc_item_spec
                                        (tbl_hdr(loop_counter).item_id,
                                         tbl_hdr(loop_counter).lot_id,
                                         tbl_hdr(loop_counter).whse_code,
                                         tbl_hdr(loop_counter).orgn_code,
                                         l_chk_whse_null,
                                         l_chk_lot_null,
                                         l_chk_orgn_null
                                        ) LOOP
               dtl_tbl_ndx  := dtl_tbl_ndx + 1;
               tbl_dtl(dtl_tbl_ndx).gmd_coa_id
                                            := tbl_hdr(loop_counter).gmd_coa_id;
               tbl_dtl(dtl_tbl_ndx).qc_spec_id     := qc_cur_rec.qc_spec_id;
               tbl_dtl(dtl_tbl_ndx).assay_code     := qc_cur_rec.assay_code;
               tbl_dtl(dtl_tbl_ndx).specification  := qc_cur_rec.specification;
               tbl_dtl(dtl_tbl_ndx).uom            := qc_cur_rec.uom;
               tbl_dtl(dtl_tbl_ndx).spec_text_code := qc_cur_rec.spec_text_code;
             END LOOP;
                       /* end get item from item/lot/whse spec  */
           END IF;
                       /* end if local item/lot spec  */

           IF dtl_tbl_ndx = 0  THEN
             /* no local item/lot  spec,look for global item specs  */
             /* (6)   */
             l_chk_orgn_null := 1;
             l_chk_lot_null  := 0;
             l_chk_whse_null := 1;

             FOR qc_cur_rec IN get_qc_item_spec
                                        (tbl_hdr(loop_counter).item_id,
                                         tbl_hdr(loop_counter).lot_id,
                                         tbl_hdr(loop_counter).whse_code,
                                         tbl_hdr(loop_counter).orgn_code,
                                         l_chk_whse_null,
                                         l_chk_lot_null,
                                         l_chk_orgn_null
                                        ) LOOP
               dtl_tbl_ndx  := dtl_tbl_ndx + 1;
               tbl_dtl(dtl_tbl_ndx).gmd_coa_id
                                            := tbl_hdr(loop_counter).gmd_coa_id;
               tbl_dtl(dtl_tbl_ndx).qc_spec_id     := qc_cur_rec.qc_spec_id;
               tbl_dtl(dtl_tbl_ndx).assay_code     := qc_cur_rec.assay_code;
               tbl_dtl(dtl_tbl_ndx).specification  := qc_cur_rec.specification;
               tbl_dtl(dtl_tbl_ndx).uom            := qc_cur_rec.uom;
               tbl_dtl(dtl_tbl_ndx).spec_text_code := qc_cur_rec.spec_text_code;
             END LOOP;
                       /* end get item from local item/lot/whse spec  */
           END IF;
                       /* end global item/lot spec  */

           IF dtl_tbl_ndx = 0  THEN
             /* no global item/lot specs, look for local item-only  */
             /* (7)  */
             l_chk_orgn_null := 0;
             l_chk_lot_null  := 1;
             l_chk_whse_null := 1;

             FOR qc_cur_rec IN get_qc_item_spec
                                        (tbl_hdr(loop_counter).item_id,
                                         tbl_hdr(loop_counter).lot_id,
                                         tbl_hdr(loop_counter).whse_code,
                                         tbl_hdr(loop_counter).orgn_code,
                                         l_chk_whse_null,
                                         l_chk_lot_null,
                                         l_chk_orgn_null
                                        ) LOOP
               dtl_tbl_ndx  := dtl_tbl_ndx + 1;
               tbl_dtl(dtl_tbl_ndx).gmd_coa_id
                                            := tbl_hdr(loop_counter).gmd_coa_id;
               tbl_dtl(dtl_tbl_ndx).qc_spec_id     := qc_cur_rec.qc_spec_id;
               tbl_dtl(dtl_tbl_ndx).assay_code     := qc_cur_rec.assay_code;
               tbl_dtl(dtl_tbl_ndx).specification  := qc_cur_rec.specification;
               tbl_dtl(dtl_tbl_ndx).uom            := qc_cur_rec.uom;
               tbl_dtl(dtl_tbl_ndx).spec_text_code := qc_cur_rec.spec_text_code;
             END LOOP;
                       /* end get item from item/lot/whse spec  */
           END IF;
                       /* end if local item-only spec  */

           IF dtl_tbl_ndx = 0  THEN
             /* no local item-only spec,look for global item-only  specs  */
             /* (8)   */
             l_chk_orgn_null := 1;
             l_chk_lot_null  := 1;
             l_chk_whse_null := 1;

             FOR qc_cur_rec IN get_qc_item_spec
                                        (tbl_hdr(loop_counter).item_id,
                                         tbl_hdr(loop_counter).lot_id,
                                         tbl_hdr(loop_counter).whse_code,
                                         tbl_hdr(loop_counter).orgn_code,
                                         l_chk_whse_null,
                                         l_chk_lot_null,
                                         l_chk_orgn_null
                                        ) LOOP
               dtl_tbl_ndx  := dtl_tbl_ndx + 1;
               tbl_dtl(dtl_tbl_ndx).gmd_coa_id
                                            := tbl_hdr(loop_counter).gmd_coa_id;
               tbl_dtl(dtl_tbl_ndx).qc_spec_id     := qc_cur_rec.qc_spec_id;
               tbl_dtl(dtl_tbl_ndx).assay_code     := qc_cur_rec.assay_code;
               tbl_dtl(dtl_tbl_ndx).specification  := qc_cur_rec.specification;
               tbl_dtl(dtl_tbl_ndx).uom            := qc_cur_rec.uom;
               tbl_dtl(dtl_tbl_ndx).spec_text_code := qc_cur_rec.spec_text_code;
             END LOOP;
                       /* end get item from local item/lot/whse spec  */
           END IF;
                       /* end global item-only spec  */

        END LOOP;
                       /* end going through header records  */
        hdr_tbl_ndx := tbl_hdr.LAST;

      END IF;
                       /* end if header records already exist  */

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
  ################################################################*/
  PROCEDURE Populate_Details (tbl_hdr IN t_coa_header_tbl,
                              tbl_dtl IN OUT NOCOPY t_coa_detail_tbl) IS

  /* BEGIN BUG#1810652 James Bernard                     */
  /* Added 'c_item_id is NULL or' in the where clause    */
  CURSOR get_cust_rslt_info (c_orgn_code gmd_samples.orgn_code%TYPE,
                             c_item_id   ic_item_mst.item_id%TYPE,
                             c_lot_id    ic_lots_mst.lot_id%TYPE,
                             c_cust_id   op_cust_mst.cust_id%TYPE)   IS
select  gr.result_id qc_result_id,
          gst.spec_id qc_spec_id,
          gt.test_code assay_code,
          gr.result_date result_date,
          decode(gr.result_value_char, null, to_char(gr.result_value_num), gr.result_value_char) result,
           decode (gst.target_value_char, null, to_char(gst.target_value_num), gst.target_value_char)
                                                                                   specification,
           gst.test_uom uom,
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
   and     gss.disposition  = '4A'  -- ACCEPT
   and     nvl(gsr.evaluation_ind,'N') in ('0A')
   and     decode(nvl(gst.print_on_coa_ind,'N'),'Y', decode( gsr.evaluation_ind,'0A','Y','1V','Y','2R','Y','N'),'N',
                 gr.ad_hoc_print_on_coa_ind, 'Y', decode( gsr.evaluation_ind,'0A','Y','1V','Y','2R','Y','N'),'N') = 'Y'
   and     gs.cust_id        = (select of_cust_id from op_cust_mst where cust_id =  c_cust_id)
   and (c_lot_id is NULL or gs.lot_id = c_lot_id)
   and (c_item_id is NULL or gs.item_id = c_item_id)
   and gs.orgn_code      = c_orgn_code
   and gs.delete_mark    = 0
   ;
  /*END BUG#1810652                                        */

  /* use the next cursor if no rows returned from get_cust_rslt_info  */
  /* BEGIN BUG#1810652 James Bernard                     */
  /* Added 'c_item_id is NULL or' and 'c_lot_id is NULL or' in the where clause */
  CURSOR get_item_rslt_info (c_orgn_code gmd_samples.orgn_code%TYPE,
                             c_item_id   ic_item_mst.item_id%TYPE,
                             c_lot_id    ic_lots_mst.lot_id%TYPE)   IS
  select  gr.result_id qc_result_id,
          gst.spec_id qc_spec_id,
          gt.test_code assay_code,
          gr.result_date result_date,
          decode(gr.result_value_char, null, to_char(gr.result_value_num), gr.result_value_char) result,
           decode (gst.target_value_char, null, to_char(gst.target_value_num), gst.target_value_char)
                                                                                   specification,
           gst.test_uom uom,
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
   and     gss.disposition  = '4A'  -- ACCEPT
   and     nvl(gsr.evaluation_ind,'N') = '0A'
   and     decode(nvl(gst.print_on_coa_ind,'N'),'Y', decode( gsr.evaluation_ind,'0A','Y','1V','Y','2R','Y','N'),'N',
                gr.ad_hoc_print_on_coa_ind, 'Y', decode( gsr.evaluation_ind,'0A','Y','1V','Y','2R','Y','N'),'N') = 'Y'
   and (c_lot_id is NULL or gs.lot_id = c_lot_id)
   and (c_item_id is NULL or gs.item_id = c_item_id)
   and gs.orgn_code      = c_orgn_code
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
                        c_cust_id op_cust_mst.cust_id%TYPE,
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
     and   gsb.item_id    = c_item_id
     and gt.test_code = c_assay_code
     and gcs.cust_id    = (select of_cust_id from op_cust_mst where cust_id =  c_cust_id)
     and gcs.orgn_code  = c_orgn_code
     and gsb.delete_mark= 0;

  CURSOR get_global_cust_spec (c_item_id ic_item_mst.item_id%TYPE,
                               c_cust_id op_cust_mst.cust_id%TYPE,
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
     and   gsb.item_id    = c_item_id
     and gt.test_code = c_assay_code
     and gcs.cust_id    = (select of_cust_id from op_cust_mst where cust_id =  c_cust_id)
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
         GMD_COA_DATA_NEW.Look_For_CoC_Specs
                    (l_dummy_param_rec,
                     tbl_ndx,
                     l_tmp_hdr_tbl,
                     tbl_dtl);
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
   ;


   CURSOR get_gnrc_info (c_generic_id op_gnrc_itm.generic_id%TYPE) IS
      SELECT generic_item,
             generic_desc
        FROM
             op_gnrc_itm
       WHERE generic_id  = c_generic_id
         and delete_mark = 0
   ;

   CURSOR get_bol_info (c_bol_id op_bill_lad.bol_no%TYPE) IS
      SELECT bol_no
        FROM
             op_bill_lad
       WHERE bol_id      = c_bol_id
         and delete_mark = 0
   ;

   CURSOR get_item_info (c_item_id ic_item_mst.item_id%TYPE) IS
      SELECT item_no,
             item_desc1
        FROM
             ic_item_mst
       WHERE item_id     = c_item_id
         and delete_mark = 0
   ;

   CURSOR get_cust_info (c_cust_id op_cust_mst.cust_id%TYPE) IS
      SELECT
             custsort_no cust_no,
             cust_name cust_name
      from   op_cust_mst
      WHERE cust_id = c_cust_id
      AND   delete_mark= 0;


   CURSOR get_whse_info (c_whse_code ic_whse_mst.WHSE_CODE%TYPE) IS
      SELECT whse_name
        FROM
             ic_whse_mst
       WHERE
             whse_code   = c_whse_code
         and delete_mark = 0
   ;

   CURSOR get_lot_tran (c_line_id ic_tran_pnd.line_id%TYPE) IS
      SELECT itp.lot_id, itp.whse_code, itp.location
        FROM
             ic_tran_pnd itp
       WHERE
             itp.doc_type      = 'OPSO'
         AND itp.completed_ind <> -1
         AND itp.line_id       = c_line_id
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
   /* **************************************************************
    *  Procedure Look_For_Results
    *    Used when there is NO shipping data (order, bol, ship num)
    *    Cursor search for lot because non-lot controlled items only
    *    return CoC (specs only).
    *  HISTORY
    *  12jun2001 James Bernard Bug 1810652
    *    Modified the where clause of the select statement in the
    *    get_qc_cust_rslt cursor definition to retrieve records when
    *    c_lot_id and c_item_id are null.
    *    Modified the where clause of the select statement in the
    *    get_qc_item_rslt cursor definition to retrieve records when
    *    c_lot_id and c_item_id are null.
    * **************************************************************/
   PROCEDURE Look_For_Results (
                               tbl_ndx   OUT NOCOPY BINARY_INTEGER)
     IS
     /* BEGIN BUG#1810652 James Bernard                        */
     /* Added 'c_lot_id is NULL or' and 'c_item_id is NULL or' */
     /* conditions in the where clause                         */
     CURSOR get_qc_cust_rslt (c_cust_id NUMBER,   c_item_id NUMBER,
                              c_lot_id NUMBER,    c_orgn_code VARCHAR2)
      IS
      select distinct gs.orgn_code,
        gs.cust_id,
        gs.item_id,
        gs.whse_code,
        gs.lot_id
      from
        gmd_samples  gs,
        gmd_results gr,
        gmd_spec_results gsr,
        gmd_sampling_events   gse,
        gmd_event_spec_disp   ges,
	gmd_spec_tests_b gst,
	gmd_sample_spec_disp gss
      where gse.sampling_event_id  = gs.sampling_event_id
        and     gse.sampling_event_id = ges.sampling_event_id
	and     ges.spec_used_for_lot_attrib_ind ='Y'
        and      gs.sample_id           = gr.sample_id
        and      gr.result_id           = gsr.result_id
        and      ges.event_spec_disp_id = gsr.event_spec_disp_id
	and 	ges.event_spec_disp_id = gss.event_spec_disp_id(+)
	and    ges.spec_id(+) = gst.spec_id
        and    gst.test_id(+) = gr.test_id
  	and     gss.disposition  = '4A'  -- ACCEPT
        and  nvl(gsr.evaluation_ind,'N') = '0A'
	and  decode(nvl(gst.print_on_coa_ind,'N'),'Y', decode( gsr.evaluation_ind,'0A','Y','1V','Y','2R','Y','N'),'N',
                 gr.ad_hoc_print_on_coa_ind, 'Y', decode( gsr.evaluation_ind,'0A','Y','1V','Y','2R','Y','N'),'N') = 'Y'
        and (c_lot_id is NULL or gs.lot_id        = c_lot_id)
        and (c_item_id is NULL or gs.item_id       = c_item_id)
        and gs.orgn_code     = c_orgn_code
        and gs.delete_mark   = 0;
       /* END BUG#1810652                                  */

     /* BEGIN BUG#1810652 James Bernard                        */
     /* Added 'c_lot_id is NULL or' and 'c_item_id is NULL or' */
     /* conditions in the where clause                         */
     CURSOR get_qc_item_rslt (c_item_id NUMBER,     c_lot_id NUMBER,
                              c_whse_code VARCHAR2, c_orgn_code VARCHAR2)
      IS
      select distinct gs.orgn_code,
        gs.cust_id,
        gs.item_id,
        gs.whse_code,
        gs.lot_id
      from
        gmd_samples  gs,
        gmd_results gr,
        gmd_spec_results gsr,
        gmd_sampling_events   gse,
        gmd_event_spec_disp   ges,
	gmd_spec_tests_b gst,
	gmd_sample_spec_disp gss
      where
          gs.cust_id is NULL
       and gs.batch_id is NULL
       and gs.formula_id is NULL
       and gs.routing_id is NULL
       and gs.oprn_id is NULL
       and gs.supplier_id is NULL
       and gse.sampling_event_id  = gs.sampling_event_id
       and gse.sampling_event_id = ges.sampling_event_id
       and ges.spec_used_for_lot_attrib_ind ='Y'
        and  gs.sample_id  = gr.sample_id
        and  gr.result_id = gsr.result_id
        and  ges.event_spec_disp_id = gsr.event_spec_disp_id
	and  ges.event_spec_disp_id = gss.event_spec_disp_id(+)
	and    ges.spec_id(+) = gst.spec_id
        and    gst.test_id(+) = gr.test_id
	and     gss.disposition  = '4A'  -- ACCEPT
        and     nvl(gsr.evaluation_ind,'N') = '0A'
	and     decode(nvl(gst.print_on_coa_ind,'N'),'Y', decode( gsr.evaluation_ind,'0A','Y','1V','Y','2R','Y','N'),'N',
                 gr.ad_hoc_print_on_coa_ind, 'Y', decode( gsr.evaluation_ind,'0A','Y','1V','Y','2R','Y','N'),'N') = 'Y'
        and (c_lot_id is NULL or gs.lot_id        = c_lot_id)
        and (c_item_id is NULL or gs.item_id       = c_item_id)
        and (c_whse_code is NULL OR gs.whse_code = c_whse_code)
        and gs.orgn_code     = c_orgn_code
        and gs.delete_mark   = 0
        ;

       /* END BUG#1810652                                  */
     BEGIN
       /* if customer parameter was given, look for customer-specific result */
       /* if no customer results found, look for item/loc/lot-specific result */

       tbl_ndx := 0;

       IF rec_param.cust_id is not NULL THEN
         FOR qc_cur_rec IN get_qc_cust_rslt (rec_param.cust_id,
                                             rec_param.item_id,
                                             rec_param.lot_id,
                                             rec_param.orgn_code) LOOP
           tbl_ndx  := tbl_ndx + 1;
           tbl_hdr(tbl_ndx).gmd_coa_id      := tbl_ndx;
           tbl_hdr(tbl_ndx).orgn_code       := qc_cur_rec.orgn_code;
           tbl_hdr(tbl_ndx).cust_id         := qc_cur_rec.cust_id;
           tbl_hdr(tbl_ndx).item_id         := qc_cur_rec.item_id;
           tbl_hdr(tbl_ndx).whse_code       := qc_cur_rec.whse_code;
           tbl_hdr(tbl_ndx).lot_id          := qc_cur_rec.lot_id;
           tbl_hdr(tbl_ndx).report_title    := v_report_title;

           /* fill in whse, customer name, lot no at end of main code */

         END LOOP;
                   /* end get item from cust rslt rather than sales order table */
       END IF;
                   /* end if cust parameter has value, then look for  */
                   /* cust-specific result */
       IF tbl_ndx = 0  THEN
         /* no customer specific rslt found, or no customer id given as  */
         /* parameter, look for item/lot/loc rslt */

         FOR qc_cur_rec IN get_qc_item_rslt (rec_param.item_id,
                                             rec_param.lot_id,
                                             rec_param.whse_code,
                                             rec_param.orgn_code) LOOP
           tbl_ndx  := tbl_ndx + 1;
           tbl_hdr(tbl_ndx).gmd_coa_id      := tbl_ndx;
           tbl_hdr(tbl_ndx).orgn_code       := qc_cur_rec.orgn_code;
           tbl_hdr(tbl_ndx).cust_id:=nvl(qc_cur_rec.cust_id, rec_param.CUST_ID);
           tbl_hdr(tbl_ndx).item_id         := qc_cur_rec.item_id;
           tbl_hdr(tbl_ndx).whse_code       := qc_cur_rec.whse_code;
           tbl_hdr(tbl_ndx).lot_id          := qc_cur_rec.lot_id;
           tbl_hdr(tbl_ndx).report_title    := v_report_title;

           /* fill in whse, customer name, lot no at end of main code */

         END LOOP;
                   /* end get item from item/lot/loc rslt */
       END IF;
                   /* end if no cust-specific result, then look for  */
                   /*   item/loc/lot results */
     END Look_For_Results;
                              /* end sub procedure */

   /* **************************** main code **************************** */
   BEGIN

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

   IF rec_param.order_id is not NULL or rec_param.bol_id is not NULL
      or rec_param.from_shipdate is not NULL    THEN
                          /*-  or rec_param.cust_po is not NULL */
     OPEN get_order_info (rec_param.order_id,
                          rec_param.from_shipdate, rec_param.to_shipdate,
                          rec_param.cust_id, rec_param.bol_id,
                          rec_param.item_id, rec_param.lot_id,
                          rec_param.whse_code);
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
       tbl_hdr(tbl_ndx).order_id        := ord_cur_rec.order_id;
       tbl_hdr(tbl_ndx).line_id         := ord_cur_rec.line_id;
       tbl_hdr(tbl_ndx).orgn_code       := ord_cur_rec.orgn_code;
       tbl_hdr(tbl_ndx).order_no        := ord_cur_rec.order_no;
       tbl_hdr(tbl_ndx).custpo_no       := ord_cur_rec.custpo_no;
       tbl_hdr(tbl_ndx).cust_id         := ord_cur_rec.shipcust_id;
       tbl_hdr(tbl_ndx).bol_id          := ord_cur_rec.bol_id;
       tbl_hdr(tbl_ndx).item_id         := ord_cur_rec.item_id;
       tbl_hdr(tbl_ndx).whse_code       := ord_cur_rec.from_whse;
       tbl_hdr(tbl_ndx).order_qty1      := ord_cur_rec.order_qty1;
       tbl_hdr(tbl_ndx).order_qty2      := ord_cur_rec.order_qty2;
       tbl_hdr(tbl_ndx).order_um1       := ord_cur_rec.order_um1;
       tbl_hdr(tbl_ndx).order_um2       := ord_cur_rec.order_um2;
       tbl_hdr(tbl_ndx).ship_qty1       := ord_cur_rec.ship_qty1;
       tbl_hdr(tbl_ndx).ship_qty2       := ord_cur_rec.ship_qty2;

       /* if there is an actual date, use it; otherwise use scheduled date */
       IF ord_cur_rec.actual_shipdate is NULL THEN
         tbl_hdr(tbl_ndx).shipdate := ord_cur_rec.sched_shipdate;
       ELSE
         tbl_hdr(tbl_ndx).shipdate := ord_cur_rec.actual_shipdate;
       END IF;

       /*  if generic id exists in sales order record, get item no and desc */
       /*  from op_gnrc_itm, else get item no and desc from ic_item_mst */

       IF ord_cur_rec.generic_id is not NULL THEN
         FOR gnrc_cur_rec IN get_gnrc_info (ord_cur_rec.generic_id) LOOP
             tbl_hdr(tbl_ndx).item_no   := gnrc_cur_rec.generic_item;
             tbl_hdr(tbl_ndx).item_desc := gnrc_cur_rec.generic_desc;
         END LOOP;
                            /* end getting generic item info from table  */
       ELSE
         FOR item_cur_rec IN get_item_info (ord_cur_rec.item_id) LOOP
            tbl_hdr(tbl_ndx).item_no   := item_cur_rec.item_no;
            tbl_hdr(tbl_ndx).item_desc := item_cur_rec.item_desc1;
         END LOOP;
                             /* end getting item info from ic_item_mst  */
       END IF;
                             /* end if generic_id has a value  */
       /* fill in whse, customer name, bol no at end of code  */

       /* get lot id from ic_tran_pnd  */
       /* get lot no and name and sublot no from ic_lot_mst at end of code  */
       /*   (2 steps so non-sales-order loop can also use get_lot_info)  */

       IF ord_cur_rec.alloc_qty > 0 THEN
         FOR lot_cur_rec IN get_lot_tran (ord_cur_rec.line_id) LOOP
            tbl_hdr(tbl_ndx).lot_id     := lot_cur_rec.lot_id;
         END LOOP;
                              /* end getting lot id from ic_tran_pnd  */
       END IF;
                              /* end checking if alloc qty > 0  */
       /* report title = COA or COC  */
       tbl_hdr(tbl_ndx).report_title := v_report_title;

       FETCH get_order_info INTO ord_cur_rec;

     END LOOP order_loop;

     CLOSE get_order_info;

   /* **************************************************************************  */
   /* *** else no sales order info given, find item info from qc_rslt (CoA) or   */
   /* *** qc_spec (CoC)    */
   ELSE

     Look_For_Results ( tbl_ndx);

     IF tbl_ndx = 0 then
                                     /*  this is a COC report; check for specs only  */
         v_report_title := 'COC';
         GMD_COA_DATA_NEW.Look_For_CoC_Specs
                    (rec_param,
                     tbl_ndx,
                     tbl_hdr,
                     tbl_dtl);

         IF tbl_ndx = 0 THEN
           v_report_title := 'BLK';
         END IF;
                          /* if neither coa nor coc data found, change this  */
                          /* flag back to default for check in populate_details.  */
     END IF;
                          /* end if results records were found  */
   END IF;
                     /* if no sales order info given, else find item info from qc  */

   IF v_report_title <> 'BLK' THEN

     GMD_COA_DATA_NEW.Populate_Details  (tbl_hdr, tbl_dtl);

   END IF;

   IF tbl_dtl.EXISTS(1) THEN
     GMD_COA_DATA_NEW.Populate_Text (tbl_dtl, tbl_spec_text, tbl_rslt_text);
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

       IF tbl_hdr(loop_counter).bol_id is not NULL THEN
         FOR bol_cur_rec IN get_bol_info (tbl_hdr(loop_counter).bol_id) LOOP
            tbl_hdr(loop_counter).bol_no := bol_cur_rec.bol_no;
         END LOOP;
                             /* end getting bol (shipping) info from op_bill_lad  */
       END IF;
                             /* end checking if bol id has a value  */
       /* get customer no and name from op_cust_mst tables  */

       IF tbl_hdr(loop_counter).cust_id is not NULL THEN
         FOR cust_cur_rec IN get_cust_info (tbl_hdr(loop_counter).cust_id) LOOP
           tbl_hdr(loop_counter).cust_no   := cust_cur_rec.cust_no;
           tbl_hdr(loop_counter).cust_name := cust_cur_rec.cust_name;
         END LOOP;
                              /* end getting cust info from hz tables */
       END IF;
                              /* end checking if cust id has a value */

       /* get item no and description from ic_item_mst if it was not */
       /* selected as part of generic item check. */
       /* It is correct to check item_NO, not item_ID! */

       IF tbl_hdr(loop_counter).item_no is NULL THEN
         FOR item_cur_rec IN get_item_info (tbl_hdr(loop_counter).item_id) LOOP
           tbl_hdr(loop_counter).item_no   := item_cur_rec.item_no;
           tbl_hdr(loop_counter).item_desc := item_cur_rec.item_desc1;
         END LOOP;
                              /* end getting item info from ic_item_mst */
       END IF;
                              /* end checking if item id has a value */

       /* get warehouse no and name from ic_whse_mst */

       IF tbl_hdr(loop_counter).whse_code is not NULL THEN
         FOR whse_cur_rec IN get_whse_info (tbl_hdr(loop_counter).whse_code) LOOP
           tbl_hdr(loop_counter).whse_name   := whse_cur_rec.whse_name;
         END LOOP;
                              /* end getting warehouse info from ic_whse_mst */
       END IF;
                              /* end checking if whse has a value  */

       /* get lot no, sublot no and lot desc from ic_lots_mst  */
       /* if pkg called from report, lot id must have value  */
       /* else if called from opm portal, lot may be null  */
       IF tbl_hdr(loop_counter).lot_id is not NULL THEN
         FOR lot_cur_rec IN get_lot_info (tbl_hdr(loop_counter).lot_id) LOOP
           tbl_hdr(loop_counter).lot_no     := lot_cur_rec.lot_no;
           tbl_hdr(loop_counter).lot_desc   := lot_cur_rec.lot_desc;
           tbl_hdr(loop_counter).sublot_no  := lot_cur_rec.sublot_no;
         END LOOP;
                              /* end getting lot info from ic_lot_mst  */
       END IF;
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
                     x_return_status OUT  NOCOPY VARCHAR2,
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

END GMD_CoA_Data_NEW;

/
