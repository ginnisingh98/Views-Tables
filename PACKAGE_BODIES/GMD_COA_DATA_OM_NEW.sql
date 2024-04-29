--------------------------------------------------------
--  DDL for Package Body GMD_COA_DATA_OM_NEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_COA_DATA_OM_NEW" AS
/* $Header: GMDGCOAB.pls 120.12.12010000.4 2009/08/25 16:32:10 rnalla ship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDGCOAB.pls                                        |
--| Package Name       : GMD_COA_DATA_OM_NEW                                 |
--| Type               : Group                                               |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains group layer API  for Population Of COA DATA     |
--|                                                                          |
--| HISTORY                                                                  |
--|    Manish Gupta   20-June-2003      Created.                             |
--|    Anoop Baddam   11-MAR-2004       BUG#3482676 Modified the procedure   |
--|                   getLatestSample to check the specified lot no.         |
--|    Vipul Vaish    30-APR-2004       BUG#3588346 Modified the cursor      |
--|                   c_get_test in procedure populate_spec such that tests  |
--|                   which have no Evaluation would not be shown on COA     |
--|                   report.                                                |
--|    Rameshwar      07-MAY-2004       BUG#3615409                          |
--|                   Initilized the lot_no and moved the call_spec_match    |
--|                   within the loop in the procedure get_order_params      |
--|    Sulipta        23-SEP-2004       BUG#3710191                          |
--|                   Added code to populate data into ship_uom1 , ship_uom2 |
--|    Sulipta        18-APR-2005       BUG#4260445                          |
--|		      Added code to get the value of text_code from gmd_spe- |
--|		      -cifications table and inserted that value to gmd_coa_ |
--|		      headers table corresponding to the spec_id.Added the   |
--|                   procedure populate_hdr_text to insert values into gmd_ |
--|		      coa_spec_hdr_text table from qc_text_tbl.              |
--|    Saikiran       27-Sep-2005    Made Inventory Convergence changes      |
--|   Saikiran       03-Nov-2005 Bug# 4662469                                |
--|   RLNAGARA 21-Feb-2006 Bug 4916856 Modified the cursors in the proc      |
--|            get_order_params by replacing the decode statement by OR .    |
--|   RAGSRIVA 02-Aug-2006 Bug 5399406 Modified the procedure                |
--|            populate_coa_data to assign param_rec.ship_to_site_id         |
--|            to hdr_rec.ship_to_site_id.                                   |
--|   RAGSRIVA 06-Nov-2006 Bug 5629675 Modified the cursor get_lot_tran in   |
--|            procedure get_order_params to select the lot number.          |
--|   srakrish 11-Jan-2006 Bug 5747932: Modified populate_results procedure  |
--|			such that non validated tests results are displayed                  |
--|   Uday Phadtare 16-OCT-2007 Bug 6485606. Changed the column from inv_uom |
--|            to uom while inserting test_unit into gmd_coa_details table.  |
--|   Peter Lowe 30-JUNE-2009 Bug 8577332  - changed procedure               |
--|            get_latest_sample - changed cursor c_sampling_event           |
--|            by adding extra join AND changed 5RJ to 6RJ in cursors        |
--|            as 5RJ does not exist                                         |
--|   Peter Lowe 04-AUG-2009 Bug 8733799 - changed procedure                 |
--|            get_order_params  - changed cursor c_order_delivery           |
--|            by adding extra join AND added a check for duplicates         |
--|            in the insert for gmd_coa_headers table                       |
--|   Rajender Nalla 20-Aug-2009 Added the new where condition to the results|
--|                  and composite results to restrict delete marked rows    |
--|                  Bug 8813052                                             |
--|   Rajender Nalla 20-Aug-2009 Added the new where condition in            |
--|                  getlatestsample to restrict the cancelled samples       |
--|                  Bug 8812000                                             |
--+==========================================================================+
-- End of comments

/*  Global variables */
COA_ID         NUMBER:=0;
G_PKG_NAME     CONSTANT VARCHAR2(30):='GMD_COA_DATA_OM_NEW';
G_tmp          BOOLEAN   := FND_MSG_PUB.Check_Msg_Level(0) ;  -- temp call to initialize the
                                                              -- msg level threshhold gobal
                                                              -- variable.
G_debug_level  NUMBER(2) := FND_MSG_PUB.G_Msg_Level_Threshold; -- Use this variable everywhere
                                                               -- to decide to log a debug msg.


PROCEDURE PUT_SPEC_IN_LOG(p_spec_id IN NUMBER,
                          x_return_status    OUT NOCOPY       VARCHAR2);
PROCEDURE log_msg(p_msg_text IN VARCHAR2);

-- Only called when the spec_id is returned by spec match
PROCEDURE insert_hdr_rec (p_hdr_rec t_coa_hdr_rec,
                          x_return_status    OUT NOCOPY       VARCHAR2) is
     X_user_id NUMBER:= FND_GLOBAL.USER_ID;
     X_login_id NUMBER:= FND_GLOBAL.LOGIN_ID;
BEGIN

PrintLn('Begin procedure insert_hdr_rec');
PrintLn('Inserting into gmd_coa_headers table');
         INSERT INTO gmd_coa_headers (gmd_coa_id,
                                      order_id,
                                      line_id,
                                      organization_id,    --INVCONV
                                      organization_code,  --INVCONV
                                      order_no,
                                      custpo_no,
                                      shipdate,
                                      cust_id,
                                      cust_no,
                                      cust_name,
                                      bol_id,
                                      bol_no,
                                      inventory_item_id, --INVCONV
                                      item_number,       --INVCONV
                                      item_description,
                                      revision,  --Bug# 4662469
                                      subinventory,      --INVCONV
                                      lot_number,        --INVCONV
                                      lot_description,   --INVCONV
                                      order_qty1,
                                      order_uom1,         --INVCONV
                                      order_qty2,
                                      order_uom2,         --INVCONV
                                      ship_qty1,
                                      ship_qty2,
                                      ship_qty_uom1,  -- Bug # 3710191 Added ship_uom1 and ship_uom2
                                      ship_qty_uom2,  --INVCONV
                                      report_title,
				      spec_hdr_text_code, -- Bug # 4260445
                                      created_by, creation_date, last_update_date,
                                    last_updated_by, last_update_login)
         VALUES (p_hdr_rec.gmd_coa_id,
                 p_hdr_rec.order_id,
                 p_hdr_rec.line_id,
                 p_hdr_rec.organization_id,
                 p_hdr_rec.organization_code,
                 p_hdr_rec.order_no,
                 p_hdr_rec.custpo_no,
                 p_hdr_rec.shipdate,
                 p_hdr_rec.cust_id,
                 p_hdr_rec.cust_no,
                 p_hdr_rec.cust_name,
                 p_hdr_rec.bol_id,
                 p_hdr_rec.bol_no,
                 p_hdr_rec.inventory_item_id,
                 p_hdr_rec.item_number,
                 p_hdr_rec.item_description,
                 p_hdr_rec.revision, --bug# 4662469
                 p_hdr_rec.subinventory,
                 p_hdr_rec.lot_number,
                 p_hdr_rec.lot_description,
                 p_hdr_rec.order_qty1,
                 p_hdr_rec.order_uom1,
                 p_hdr_rec.order_qty2,
                 p_hdr_rec.order_uom2,
                 p_hdr_rec.ship_qty1,
                 p_hdr_rec.ship_qty2,
                 p_hdr_rec.ship_qty_uom1, -- Bug # 3710191 Added these two lines.
                 p_hdr_rec.ship_qty_uom2,
                 p_hdr_rec.report_title,
		 p_hdr_rec.spec_hdr_text_code, -- Bug # 4260445
                 X_user_id, SYSDATE, SYSDATE, X_user_id, X_login_id
                );
              --log_msg('Message level is ...'||FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
              --log_msg('debug level is ...'||G_debug_level);
              IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                 log_msg('procedure insert_hdr_rec, inserted into hdr table...');
              END IF;
PrintLn('End procedure insert_hdr_rec');
PrintLn('Calling procedure Populate_hdr_Text'); -- Bug # 4260445
populate_hdr_text(p_hdr_rec,x_return_status); --Bug # 4260445 Calling populate_hdr_text

EXCEPTION
   WHEN OTHERS THEN
    PrintLn('When Others in GMD_COA_DATA.INSERT_HDR_REC '|| SUBSTR(SQLERRM,1,100));
    log_msg('GMD_COA_DATA.INSERT_HDR_REC '|| SUBSTR(SQLERRM,1,100));
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
END insert_hdr_rec;

-- Bug # 4260445 Added this procedure to populate data into gmd_coa_spec_hdr_text

PROCEDURE populate_hdr_text (tbl_hdr IN t_coa_hdr_rec,
                           x_return_status OUT NOCOPY  VARCHAR2) IS
CURSOR get_text_info (c_text_code qc_text_tbl.text_code%TYPE) IS
   select paragraph_code,
          line_no,
          text
   from qc_text_tbl
   where text_code = c_text_code
   and   line_no > 0
   order by paragraph_code, line_no ;

 BEGIN

 PrintLn('Begin procedure populate_hdr_text');

  FOR  text_cur_rec IN get_text_info (tbl_hdr.spec_hdr_text_code)
    LOOP
          PrintLn('In gmd_coa_spec_hdr_text LOOP');
          PrintLn('Inserting into gmd_coa_spec_hdr_text');
          INSERT into gmd_coa_spec_hdr_text (gmd_coa_id, text_code,
                                         paragraph_code, line_no, text)
          VALUES (tbl_hdr.gmd_coa_id,
                  tbl_hdr.spec_hdr_text_code,
                  text_cur_rec.paragraph_code,
                  text_cur_rec.line_no,
                  text_cur_rec.text);
    END LOOP;
       IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
         log_msg('inserted into populate_hdr_text...');
       END IF;

 PrintLn('End procedure populate_hdr_text');
 EXCEPTION
  WHEN OTHERS THEN
    PrintLn('GMD_COA_DATA.INSERT_HDR_REC '|| SUBSTR(SQLERRM,1,100));
    log_msg('GMD_COA_DATA.INSERT_HDR_REC '|| SUBSTR(SQLERRM,1,100));
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

END populate_hdr_text; -- Bug # 4260445



 PROCEDURE populate_text    (tbl_dtl       IN  t_coa_dtl_rec,
                             x_return_status    OUT NOCOPY       VARCHAR2) IS

 CURSOR get_text_info (c_text_code qc_text_tbl.text_code%TYPE) IS
   select paragraph_code,
          line_no,
          text
   from qc_text_tbl
   where text_code = c_text_code
   and   line_no > 0
   order by paragraph_code, line_no ;


 BEGIN

 PrintLn('Begin procedure populate_text');

     FOR  text_cur_rec IN get_text_info (tbl_dtl.spec_text_code)
       LOOP
         PrintLn('In gmd_coa_spec_text LOOP');
         PrintLn('Inserting into gmd_coa_spec_text');
          INSERT into gmd_coa_spec_text (gmd_coa_id, text_code,
                                         paragraph_code, line_no, text)
          VALUES (tbl_dtl.gmd_coa_id,
                  tbl_dtl.spec_text_code,
                  text_cur_rec.paragraph_code,
                  text_cur_rec.line_no,
                  text_cur_rec.text);
       END LOOP;


     FOR  text_cur_rec IN get_text_info (tbl_dtl.rslt_text_code)
       LOOP
         PrintLn('In gmd_coa_rslt_text LOOP');
         PrintLn('Inserting into gmd_coa_rslt_text');
          INSERT into gmd_coa_rslt_text (gmd_coa_id, text_code,
                                         paragraph_code, line_no, text)
          VALUES (tbl_dtl.gmd_coa_id,
                  tbl_dtl.rslt_text_code,
                  text_cur_rec.paragraph_code,
                  text_cur_rec.line_no,
                  text_cur_rec.text);
       END LOOP;
       IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
         log_msg('inserted into populate_text...');
       END IF;

 PrintLn('End procedure populate_text');

EXCEPTION
  WHEN OTHERS THEN
    PrintLn('GMD_COA_DATA.INSERT_HDR_REC '|| SUBSTR(SQLERRM,1,100));
    log_msg('GMD_COA_DATA.INSERT_HDR_REC '|| SUBSTR(SQLERRM,1,100));
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
END populate_text;



PROCEDURE insert_dtl_rec(p_dtl_rec  t_coa_dtl_rec,
                         x_return_status OUT NOCOPY  VARCHAR2) IS
     X_user_id NUMBER:= FND_GLOBAL.USER_ID;
     X_login_id NUMBER:= FND_GLOBAL.LOGIN_ID;
BEGIN
   PrintLn('Begin procedure insert_dtl_rec');
   PrintLn('Inserting into gmd_coa_details');
        INSERT into gmd_coa_details (gmd_coa_id,
                                     qc_result_id,
                                     result_date,
                                     qc_spec_id,
                                     assay_code,
                                     assay_desc,
                                     result,
                                     specification,
                                     uom,             --Bug 6485606. Changed inv_uom to uom
                                     rslt_text_code,
                                     spec_text_code,
                                     min_spec,max_spec,
                                     test_method,
                                     created_by, creation_date,
                                     last_update_date,
                                     last_updated_by, last_update_login
                                     )
           VALUES (p_dtl_rec.gmd_coa_id,
                   p_dtl_rec.result_id,
                   p_dtl_rec.result_date,
                   p_dtl_rec.spec_id,
                   p_dtl_rec.test_code,
                   p_dtl_rec.test_display,
                   p_dtl_rec.result,
                   p_dtl_rec.specification,
                   p_dtl_rec.test_unit,
                   p_dtl_rec.rslt_text_code,
                   p_dtl_rec.spec_text_code,
                   p_dtl_rec.min_spec,
                   p_dtl_rec.max_spec,
                   p_dtl_rec.test_method,
                   X_user_id, SYSDATE, SYSDATE, X_user_id, X_login_id
                   );

      PrintLn('End procedure insert_dtl_rec');
      PrintLn('Calling procedure Populate_Text');
      Populate_Text(p_dtl_rec,x_return_status);

EXCEPTION
   WHEN OTHERS THEN
    PrintLn('GMD_COA_DATA.INSERT_DTL_REC '|| SUBSTR(SQLERRM,1,100));
    log_msg('GMD_COA_DATA.INSERT_DTL_REC '|| SUBSTR(SQLERRM,1,100));
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

END insert_dtl_rec;

PROCEDURE populate_result(p_detail_rec IN OUT NOCOPY t_coa_dtl_rec,
                          p_sample_id NUMBER,
                          x_return_status    OUT NOCOPY VARCHAR2) IS
--For sample having single result(for printing COA)

CURSOR get_results(p_sample_id NUMBER,
                   p_test_id   NUMBER) IS
select r.result_id,
       r.test_id,
       ges.spec_id,
       nvl(r.result_value_char,result_value_num) result,
       r.result_value_char,
       r.result_value_num,
       r.result_date,
       r.text_code
from   gmd_results r,
       gmd_spec_results sr,
       gmd_event_spec_disp ges
where  r.sample_id = p_sample_id
and    r.result_id = sr.result_id
and    nvl(sr.evaluation_ind,'N') in ('0A','1V','2R','N') -- srakrish bug 5747932: To fetch results for non validated tests.
and    sr.event_spec_disp_id = ges.event_spec_disp_id
and    ges.spec_used_for_lot_attrib_ind ='Y'
and    r.test_id = p_test_id
and    r.delete_mark = 0
order  by r.result_date, r.seq desc;
--Bug 8813052
--Added above and r.delete_mark = 0 condition
CURSOR c_get_range_with_disp(p_test_id NUMBER,
                             p_result NUMBER) IS
SELECT display_label_numeric_range
FROM   gmd_qc_test_values
WHERE  p_result between min_num and max_num
AND    test_id = p_test_id;

BEGIN
 PrintLn('Begin procedure populate_result');
  FOR c_results IN get_results(p_sample_id,p_detail_rec.test_id) LOOP
    PrintLn('In get_results LOOP');
      p_detail_rec.gmd_coa_id := coa_id;
      p_detail_rec.result_id := c_results.result_id;
      p_detail_rec.result_date := c_results.result_date;
      p_detail_rec.result  := c_results.result;
      p_detail_rec.result_value_num := c_results.result_value_num;
      p_detail_rec.result_value_char := c_results.result_value_char;
      p_detail_rec.rslt_text_code := c_results.text_code;

      PrintLn('p_detail_rec.gmd_coa_id = '||p_detail_rec.gmd_coa_id);
      PrintLn('p_detail_rec.result_id = '||p_detail_rec.result_id);
      PrintLn('p_detail_rec.result_date = '||p_detail_rec.result_date);
      PrintLn('p_detail_rec.result  = '||p_detail_rec.result);
      PrintLn('p_detail_rec.result_value_num = '||p_detail_rec.result_value_num);
      PrintLn('p_detail_rec.result_value_char = '||p_detail_rec.result_value_char);
      PrintLn('p_detail_rec.rslt_text_code = '||p_detail_rec.rslt_text_code);
      PrintLn('p_detail_rec.test_type = '||p_detail_rec.test_type);

      IF (p_detail_rec.test_type in ('N','E')) THEN
        p_detail_rec.result := getprecision(c_results.result,p_detail_rec.report_precision);
      END IF;
      IF (p_detail_rec.test_type in ('L')) THEN
        p_detail_rec.result := get_text_for_range(p_detail_rec.test_id,p_detail_rec.result_value_num);
      END IF;

      exit;
  END LOOP;
  PrintLn('End procedure populate_result');
EXCEPTION
   WHEN OTHERS THEN
    PrintLn('GMD_COA_DATA.POPULATE_RESULT '|| SUBSTR(SQLERRM,1,100));
    log_msg('GMD_COA_DATA.POPULATE_RESULT '|| SUBSTR(SQLERRM,1,100));
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
END populate_result;

PROCEDURE populate_composite_results(p_detail_rec IN OUT NOCOPY t_coa_dtl_rec ,
                                     p_event_spec_disp_id IN NUMBER,
                                     x_return_status  OUT NOCOPY VARCHAR2) IS
--there is no result date in composite results??
CURSOR c_composite_results(p_event_spec_disp_id IN NUMBER,
                           p_test_id            IN NUMBER) IS
select r.composite_result_id,
       r.test_id,
       --nvl(r.mean,r.mode_char) result,
       r.mean,
       r.mode_num,
       r.mode_char,
       r.low_num,
       r.high_num,
       r.range,
       r.non_validated_result,
       r.standard_deviation , ges.spec_id
from   gmd_composite_results r,
       gmd_composite_spec_disp sd,
       gmd_event_spec_disp ges
where  r.composite_spec_disp_id =sd.composite_spec_disp_id
and    sd.event_spec_disp_id = p_event_spec_disp_id
and    sd.event_spec_disp_id = ges.event_spec_disp_id
and    nvl(ges.spec_used_for_lot_attrib_ind,'N') = 'Y'
and    nvl(sd.latest_ind,'N') = 'Y'
and    r.delete_mark = 0
and    r.test_id = p_test_id;
--Bug 8813052
--Added above and r.delete_mark = 0 condition
BEGIN
 PrintLn('Begin procedure populate_composite_results');
  FOR l_results IN c_composite_results(p_event_spec_disp_id,
                                       p_detail_rec.test_id) LOOP
    PrintLn('In c_composite_results LOOP');
      p_detail_rec.gmd_coa_id := coa_id;
      p_detail_rec.result_id := l_results.composite_result_id;

      -- In composite result for numeric values is mean
      -- for char results is mode_char
      p_detail_rec.result_value_num := l_results.mean;
      p_detail_rec.result_value_char := l_results.mode_char;

      PrintLn('p_detail_rec.gmd_coa_id = '||p_detail_rec.gmd_coa_id);
      PrintLn('p_detail_rec.result_id = '||p_detail_rec.result_id);
      PrintLn('p_detail_rec.result_value_num = '||p_detail_rec.result_value_num);
      PrintLn('p_detail_rec.result_value_char = '||p_detail_rec.result_value_char);
      PrintLn('p_detail_rec.test_type = '||p_detail_rec.test_type);

      IF (p_detail_rec.test_type in ('N','E')) THEN
        p_detail_rec.result := getprecision(l_results.mean,p_detail_rec.report_precision);
      ELSIF (p_detail_rec.test_type in ('L')) THEN
        p_detail_rec.result := get_text_for_range(p_detail_rec.test_id,p_detail_rec.result_value_num);
      ELSE
        p_detail_rec.result := nvl(l_results.mode_char,l_results.non_validated_result);
      END IF;
      EXIT;
  END LOOP;
 PrintLn('End procedure populate_composite_results');
EXCEPTION
   WHEN OTHERS THEN
    PrintLn('GMD_COA_DATA.POPULATE_COMPOSITE_RESULTS '|| SUBSTR(SQLERRM,1,100));
    log_msg('GMD_COA_DATA.POPULATE_COMPOSITE_RESULTS '|| SUBSTR(SQLERRM,1,100));
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
END populate_composite_results;

PROCEDURE populate_spec(p_spec_id IN NUMBER,
                        p_cust_id IN NUMBER,
                        p_report_type IN VARCHAR2,
                        x_return_status    OUT NOCOPY       VARCHAR2,
                        p_event_spec_disp_id IN NUMBER DEFAULT NULL,
                        p_sample_id          IN NUMBER DEFAULT NULL) IS
 --Input cust_id, spec_id, result
 -- output result with report precision, test_display, result_display(for 'L' Only)
 --Make sure that COA or COC report is determined before this procedure is called.
  CURSOR c_get_cust_test(p_cust_id NUMBER,
                         p_test_id NUMBER) IS
  SELECT cust_test_display,
         report_precision
  FROM   gmd_customer_tests
  WHERE  cust_id = p_cust_id
  AND    test_id = p_test_id;


  CURSOR c_get_test( p_spec_id NUMBER ) IS
  SELECT nvl(s.test_display,t.test_desc) display,
         s.report_precision,t.test_type,
         s.target_value_num, s.min_value_num, s.max_value_num,
         s.target_value_char, s.min_value_char, s.max_value_char,
         s.text_code spec_text_code,t.test_code,t.test_id,t.test_unit,
         decode(m.test_method_code,'DEFAULT',NULL, m.test_method_code) test_method_code
  FROM   gmd_spec_tests s,
         gmd_qc_tests t,
         gmd_test_methods_b m
         --Bug 3785184 backing out fix 3588346
         -- gmd_results r,      --BUG#3588346
         -- gmd_spec_results sr --BUG#3588346
  WHERE  s.test_id= t.test_id
  AND    s.spec_id= p_spec_id
  AND    ((p_report_type = 'COC' and nvl(s.print_spec_ind,'N') ='Y') OR
         (p_report_type = 'COA' and nvl(s.print_result_ind,'N') ='Y'))
  -- Bug# 5223677. Pick all tests. Commented following AND condition.
  -- AND    nvl(s.optional_ind,'N') = 'N'
  AND    s.test_method_id = m.test_method_id
  --Bug 3785184 backing out fix 3588346
  --BEGIN BUG#3588346
  -- AND    r.sample_id = p_sample_id
  -- AND    s.test_id = r.test_id
  -- AND    r.result_id = sr.result_id
  -- AND    sr.evaluation_ind IS NOT NULL
  --END BUG#3588346
  ORDER BY s.seq;

  CURSOR c_get_range_with_disp(p_test_id NUMBER,
                               p_result NUMBER) IS
   SELECT display_label_numeric_range
   FROM   gmd_qc_test_values
   WHERE  p_result between min_num and max_num
   AND    test_id = p_test_id;

  l_get_cust_test c_get_cust_test%ROWTYPE;

  l_target             VARCHAR2(240);
  l_detail_rec         t_coa_dtl_rec;
  l_detail_rec_blank   t_coa_dtl_rec;


BEGIN
 PrintLn('Begin procedure populate_spec');
 PrintLn('p_spec_id = '||p_spec_id);
 PrintLn('p_cust_id = '||p_cust_id);
 PrintLn('p_report_type = '||p_report_type);
 PrintLn('p_event_spec_disp_id = '||p_event_spec_disp_id);
 PrintLn('p_sample_id = '||p_sample_id);

  FOR c_spec_rec IN  c_get_test(p_spec_id) LOOP
   PrintLn('In c_get_test LOOP');
   --Bug 3785184 Start with blank l_detail_rec
    l_detail_rec := l_detail_rec_blank;

    l_detail_rec.gmd_coa_id := coa_id;
    l_detail_rec.test_id    := c_spec_rec.test_id;
    l_detail_rec.test_code  := c_spec_rec.test_code;
    l_detail_rec.test_unit  := c_spec_rec.test_unit;
    l_detail_rec.spec_text_code :=   c_spec_rec.spec_text_code;
    l_detail_rec.test_type :=   c_spec_rec.test_type;
    l_detail_rec.test_method :=   c_spec_rec.test_method_code;


    l_get_cust_test.cust_test_display := NULL;
    l_get_cust_test.report_precision := NULL;

    IF (p_cust_id IS NOT NULL) THEN
      OPEN c_get_cust_test(p_cust_id,c_spec_rec.test_id);
      FETCH c_get_cust_test INTO l_get_cust_test;
      CLOSE c_get_cust_test;
    ELSE
      l_get_cust_test.cust_test_display := NULL;
      l_get_cust_test.report_precision := NULL;
    END IF;

    IF (l_get_cust_test.cust_test_display IS NOT NULL) THEN
      l_detail_rec.test_display := l_get_cust_test.cust_test_display;
    ELSE
      l_detail_rec.test_display := c_spec_rec.display;
    END IF;


    IF (l_get_cust_test.report_precision IS NOT NULL) THEN
      l_detail_rec.report_precision := l_get_cust_test.report_precision;
    ELSE
      l_detail_rec.report_precision := c_spec_rec.report_precision;
    END IF;
    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
     log_msg('populate_spec, report preicion is ...'||l_detail_rec.report_precision);
    END IF;

    PrintLn('c_spec_rec.test_type = '||c_spec_rec.test_type);
    IF (c_spec_rec.test_type in ('L')) THEN
      -- when numeric with display text display only the text
        l_detail_rec.min_spec := get_text_for_range(l_detail_rec.test_id,c_spec_rec.min_value_num);
        l_detail_rec.max_spec := get_text_for_range(l_detail_rec.test_id,c_spec_rec.max_value_num);
    ELSIF (c_spec_rec.test_type in ('N','E')) THEN
        l_detail_rec.min_spec := getprecision(c_spec_rec.min_value_num,l_detail_rec.report_precision);
        l_detail_rec.max_spec := getprecision(c_spec_rec.max_value_num,l_detail_rec.report_precision);
    ELSIF (c_spec_rec.test_type in ('T')) THEN
        l_detail_rec.min_spec := c_spec_rec.min_value_char;
        l_detail_rec.max_spec := c_spec_rec.max_value_char;
    ELSE
        l_detail_rec.specification := c_spec_rec.target_value_char;
        l_detail_rec.min_spec := c_spec_rec.target_value_char;
        l_detail_rec.max_spec := null;
    END IF;

    PrintLn('l_detail_rec.gmd_coa_id = '||l_detail_rec.gmd_coa_id);
    PrintLn('l_detail_rec.test_id    = '||l_detail_rec.test_id);
    PrintLn('l_detail_rec.test_code  = '||l_detail_rec.test_code);
    PrintLn('l_detail_rec.test_unit  = '||l_detail_rec.test_unit);
    PrintLn('l_detail_rec.spec_text_code = '||l_detail_rec.spec_text_code);
    PrintLn('l_detail_rec.test_type = '||l_detail_rec.test_type);
    PrintLn('l_detail_rec.test_method = '||l_detail_rec.test_method);
    PrintLn('l_detail_rec.report_precision = '||l_detail_rec.report_precision);
    PrintLn('l_detail_rec.min_spec = '||l_detail_rec.min_spec);
    PrintLn('l_detail_rec.max_spec = '||l_detail_rec.max_spec);

    --Bug 3785184 Populate result only for COA report
    IF (p_report_type = 'COA') THEN
       IF (p_sample_id IS NOT NULL) THEN
          PrintLn('Calling procedure populate_result ');
          populate_result(l_detail_rec,p_sample_id,x_return_status);
       ELSIF (p_event_spec_disp_id IS NOT NULL) THEN
          PrintLn('Calling procedure populate_composite_results');
          populate_composite_results(l_detail_rec,p_event_spec_disp_id,x_return_status);
       END IF;
    END IF;

    PrintLn('Calling procedure insert_dtl_rec');
    insert_dtl_rec(l_detail_rec,x_return_status);

  END LOOP;
 PrintLn('End procedure populate_spec');
EXCEPTION
   WHEN OTHERS THEN
    PrintLn('GMD_COA_DATA.POPULATE_SPEC '|| SUBSTR(SQLERRM,1,100));
    log_msg('GMD_COA_DATA.POPULATE_SPEC '|| SUBSTR(SQLERRM,1,100));
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
END populate_spec;




FUNCTION get_text_for_range(p_test_id NUMBER,
                            p_value   NUMBER) RETURN VARCHAR2 IS

CURSOR c_get_range_with_disp(p_test_id NUMBER,
                             p_value NUMBER) IS
SELECT display_label_numeric_range
FROM   gmd_qc_test_values
WHERE  p_value between min_num and max_num
AND    test_id = p_test_id;

l_text   VARCHAR2(240);
BEGIN
 PrintLn('Begin procedure get_text_for_range');
 PrintLn('p_test_id = '||p_test_id);
  OPEN c_get_range_with_disp(p_test_id,p_value);
  FETCH c_get_range_with_disp INTO l_text;
  CLOSE c_get_range_with_disp;
  PrintLn('End procedure get_text_for_range');
  RETURN l_text;

END get_text_for_range;




PROCEDURE get_foreign_keys(p_hdr_rec       IN OUT NOCOPY t_coa_hdr_rec,
                           x_return_status    OUT NOCOPY       VARCHAR2) IS

 /*CURSOR c_get_item_no(p_item_id IN NUMBER) IS
   select item_no, item_desc1
   from   ic_item_mst
   where  item_id = p_item_id;*/

 --INVCONV
 CURSOR c_get_item_no (p_inventory_item_id IN NUMBER, p_organization_id IN NUMBER) IS
 SELECT concatenated_segments item_number,
 description item_description
 FROM mtl_system_items_b_kfv
 WHERE inventory_item_id = p_inventory_item_id
 AND organization_id = p_organization_id;


 CURSOR c_get_cust(p_cust_id IN NUMBER) IS
   select a.account_number cust_no,
          b.party_name cust_name
   from   hz_cust_accounts a,
          hz_parties       b
   where  a.party_id = b.party_id
   and    a.cust_account_id = p_cust_id;

  --INVCONV
  /*CURSOR c_get_lot(p_lot_id IN NUMBER,
                   p_lot_no in VARCHAR2) IS
    select a.lot_no,a.lot_desc,
           a.sublot_no
    from   ic_lots_mst a
    where (p_lot_id is NULL OR lot_id = p_lot_id)
    and   (p_lot_no IS NULL or lot_no = p_lot_no);*/

BEGIN
  PrintLn('Begin procedure get_foreign_keys');
  PrintLn('p_hdr_rec.cust_id = '||p_hdr_rec.cust_id);
  PrintLn('p_hdr_rec.lot_no = '||p_hdr_rec.lot_number);
   OPEN c_get_item_no(p_hdr_rec.inventory_item_id, p_hdr_rec.organization_id);
   FETCH c_get_item_no INTO p_hdr_rec.item_number, p_hdr_rec.item_description;
   CLOSE c_get_item_no;

   IF (p_hdr_rec.cust_id IS NOT NULL) THEN
     OPEN  c_get_cust(p_hdr_rec.cust_id);
     FETCH c_get_cust INTO p_hdr_rec.cust_no, p_hdr_rec.cust_name;
     CLOSE c_get_cust;
   END IF;

  PrintLn('End procedure get_foreign_keys');
EXCEPTION
   WHEN OTHERS THEN
    PrintLn('GMD_COA_DATA.GET_FOREIGN_KEYS '|| SUBSTR(SQLERRM,1,100));
    log_msg('GMD_COA_DATA.GET_FOREIGN_KEYS '|| SUBSTR(SQLERRM,1,100));
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

END get_foreign_keys;



FUNCTION getprecision (p_value IN NUMBER,
                       p_report_precision IN NUMBER) return VARCHAR2 IS
 L_local NUMBER;
 l_format VARCHAR2(50);

begin
 PrintLn('Begin Function getprecision');
 PrintLn('p_value = '||p_value);
 PrintLn('p_report_precision = '||p_report_precision);

  -- Bug 3970286
  -- For 9.97,1 as input parameters, the l_local should be 99 and not 9,
  -- to accomodate any rounding UP. Added 1 to the length.
  l_local := POWER(10,LENGTH(TRUNC(p_value))+1) - 1;
PrintLn('l_local is '||l_local);

  IF (p_report_precision > 0) THEN
     l_format := to_char(l_local)||'D'||to_char(power(10,p_report_precision) -1);
  ELSE
     l_format := to_char(l_local);
  END IF;
PrintLn('Format string is '||l_format);

PrintLn('End Function getprecision');
  return rtrim(ltrim(to_char(p_value,l_format)));
EXCEPTION
   WHEN OTHERS THEN
   PrintLn('GMD_COA_DATA.GETPRECISION '|| SUBSTR(SQLERRM,1,100));
   log_msg('GMD_COA_DATA.GETPRECISION '|| SUBSTR(SQLERRM,1,100));
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
END getprecision;


PROCEDURE log_msg(p_msg_text IN VARCHAR2) IS
BEGIN
    FND_MESSAGE.SET_NAME('GMI','GMI_DEBUG_API');
    FND_MESSAGE.SET_TOKEN('MSG',p_msg_text);
    FND_MSG_PUB.Add;
END log_msg ;

PROCEDURE put_spec_in_log(p_spec_id IN NUMBER,
                          x_return_status    OUT NOCOPY       VARCHAR2) IS
CURSOR c_get_spec(p_spec_id NUMBER) IS
SELECT spec_name,spec_vers
FROM   gmd_specifications_b
WHERE  spec_id = p_spec_id;

l_spec_name    gmd_specifications.spec_name%TYPE;
l_spec_vers    gmd_specifications.spec_vers%TYPE;

BEGIN
  PrintLn('Begin Procedure put_spec_in_log');
      OPEN c_get_spec(p_spec_id);
      FETCH c_get_spec INTO  l_spec_name,l_spec_vers;
      CLOSE c_get_spec;
      PrintLn('l_spec_name = '||l_spec_name);
      PrintLn('l_spec_vers = '||l_spec_vers);
      PrintLn('GMD_QC_SPEC_NAME');
      FND_MESSAGE.SET_NAME('GMD','GMD_QC_SPEC_NAME');
      FND_MESSAGE.SET_TOKEN('SPEC_NAME'  ,l_spec_name);
      FND_MESSAGE.SET_TOKEN('SPEC_VERSION',l_spec_vers);
      FND_MSG_PUB.Add;
  PrintLn('End Procedure put_spec_in_log');
EXCEPTION
   WHEN OTHERS THEN
    PrintLn('GMD_COA_DATA.PUT_SPEC_IN_LOG '|| SUBSTR(SQLERRM,1,100));
    log_msg('GMD_COA_DATA.PUT_SPEC_IN_LOG '|| SUBSTR(SQLERRM,1,100));
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
END put_spec_in_log;

PROCEDURE getLatestSample(p_spec_id            IN NUMBER,
                          p_lot_number         IN VARCHAR2,
                          p_event_spec_disp_id OUT NOCOPY NUMBER,
                          p_sample_id          OUT NOCOPY NUMBER) IS

--BUG#3482676 Anoop.
--Added condition in where clause to check the lot no specified.
--BUG# 8577332
--Added extra join in where clause to gmd_samples  and changed 5RJ to 6RJ
CURSOR c_sampling_event(p_spec_id IN NUMBER) IS

select nvl(c.SAMPLE_ACTIVE_CNT,0) sample_active_cnt,
b.event_spec_disp_id,
b.sampling_event_id
from gmd_samples a,gmd_event_spec_disp b, gmd_sampling_events c
where b.spec_id =p_spec_id
and  (a.lot_number = p_lot_number or p_lot_number is null)
and b.disposition in ('4A','5AV','6RJ')
and b.spec_used_for_lot_attrib_ind ='Y'
and a.sampling_event_id= b.sampling_event_id
and a.sampling_event_id= c.sampling_event_id
and nvl (c.sample_active_cnt,0) >= 1
order by a.creation_date desc;

--BUG# 8577332
--Added added sample_no  for debugging
--Bug 8812000
--Added and a.sample_id = b.sample_id and b.disposition <> '7CN';
CURSOR c_simple_result(p_sampling_event_id IN NUMBER) IS
select a.sample_id , a.sample_no
from   gmd_samples a, gmd_sample_spec_disp b
where  a.sampling_event_id = p_sampling_event_id
AND    a.sample_id = b.sample_id
AND    b.disposition <> '7CN';

BEGIN
 PrintLn('Begin Procedure getLatestSample');
 PrintLn('p_spec_id = '||p_spec_id);
 PrintLn('p_lot_number = '||p_lot_number);
  FOR c_sampling_event_rec IN c_sampling_event(p_spec_id) LOOP
    PrintLn('In c_sampling_event LOOP');
     IF (c_sampling_event_rec.SAMPLE_ACTIVE_CNT=1) THEN
       for  c_simple_result_rec in c_simple_result(c_sampling_event_rec.sampling_event_id) loop   -- take out this  loop and try   - compile on vis02
         PrintLn('In c_simple_result LOOP');
           p_sample_id := c_simple_result_rec.sample_id;
           IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
             log_msg('getLatestSample sample for spec_id '|| p_sample_id);
           END IF;
           PrintLn('getLatestSample sample_id for spec_id '|| p_sample_id);
           PrintLn('getLatestSample sample no  for spec_id '|| c_simple_result_rec.sample_no);
           PrintLn('RETURN End Procedure getLatestSample');
           RETURN;
       END LOOP;
     ELSE
         p_event_spec_disp_id := c_sampling_event_rec.event_spec_disp_id;
         IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
           log_msg('getLatestSample p_event_spec_disp_id for spec_id '|| p_event_spec_disp_id);
         END IF;
         PrintLn('getLatestSample p_event_spec_disp_id for spec_id '|| p_event_spec_disp_id);
         PrintLn('RETURN End Procedure getLatestSample');
         RETURN;
     END IF;
  END LOOP;
 PrintLn('End Procedure getLatestSample');
END getLatestSample;

--Start of comments
--+=====================================================================================================+
--| API Name    : get_result_match_for_spec                                                              |
--| TYPE        : Group                                                                                  |
--| Notes       :                                                                                        |
--| Parameters  : item_id      - IN PARAMETER item_id of the order line                                  |
--|               lot_id       - IN PARAMETER lot_id                                                     |
--|               whse_code    - IN PARAMETER warehouse                                                  |
--|               location     - IN PARAMETER location                                                   |
--|               result_type  - OUT parameter ( will be SET BY THE API get_result_match_for_spec)       |
--|                         result_type will have 2 values - 'I' for Individual Result,                  |
--|                         'C' - for Composite Result                                                   |
--|               sample_id      - OUT parameter ( will be SET BY THE API get_result_match_for_spec)     |
--|                      - This will be used to navigate to the Result form.                             |
--|               spec_match_type - OUT parameter ( will be SET BY THE API get_result_match_for_spec)    |
--|                          It can have 3 values.                                                       |
--|                       - NULL If no sample is found, OR no results can be found for this lot,         |
--|                       - 'U' for Unaccepted. If the latest accepted final result is not               |
--|                          within the spec. test range.                                                |
--|                       - 'A' for Accepted.All the test results for the customer spec are              |
--|                       within the spec. test range                                                    |
--|               event_spec_disp_id - OUT parameter ( will be SET BY THE API get_result_match_for_spec) |
--|                          - This will be used to navigate to the composite results form.              |
--|                                                                                                      |
--| Calling Program : -  Order Management(Pick lots form)                                                |
--| HISTORY                                                                                              |
--|    Mahesh Chandak   1-sep-2002      Created.                                                         |
--|    Anoop Baddam     11-MAR-2004     Modified the call to procedure getLatestSample.                  |
--+=====================================================================================================+
-- End of comments



PROCEDURE get_result_match_for_spec
                  (  p_spec_id       IN  NUMBER
                   , p_lots          IN  OUT NOCOPY result_lot_match_tbl
                   , x_return_status OUT NOCOPY VARCHAR2
                   , x_message_data  OUT NOCOPY VARCHAR2 ) IS

l_position              VARCHAR2(3);
--l_lot_no                VARCHAR2(32);     --INVCONV
--l_sublot_no             VARCHAR2(32);     --INVCONV
--l_whse_code             VARCHAR2(4);      --INVCONV
--l_location              VARCHAR2(16);     --INVCONV
--l_item_id               NUMBER;           --INVCONV
l_lot_number            VARCHAR2(80);       --INVCONV
l_subinventory          VARCHAR2(10);       --INVCONV
l_locator_id            NUMBER;             --INVCONV
l_inventory_item_id     NUMBER;             --INVCONV
l_revision              NUMBER;              --BUG# 4662469
l_old_event_spec_disp_id NUMBER;
l_cust_id               NUMBER;

-- pick up only required test
--RLNAGARA Bug # 4916856
--Bug# 5223677. Pick all tests. Commented optional_ind condition.
CURSOR cr_get_req_spec_tests IS
  SELECT gst.test_id
  FROM   GMD_SPEC_TESTS_B gst
  WHERE  gst.spec_id = p_spec_id;
  -- AND    gst.optional_ind is NULL  ;



CURSOR cr_get_sample_for_lot IS
  SELECT gs.lot_number,gs.cust_id,gs.creation_date,/*gs.location,*/gs.subinventory,
         gr.sample_id sample_id,ges.event_spec_disp_id,
         gr.test_id,
         gr.result_value_num,
         gr.result_value_char,'SAMPLE'
  FROM   GMD_SAMPLING_EVENTS gs ,
         GMD_EVENT_SPEC_DISP ges,
         GMD_RESULTS gr,
         GMD_SPEC_RESULTS sp
  WHERE
  gs.inventory_item_id    = l_inventory_item_id
  AND   (gs.revision    =  l_revision OR gs.revision IS NULL )
  AND   (gs.lot_number      = l_lot_number  OR gs.lot_number IS NULL)
  AND   (gs.subinventory   = l_subinventory OR gs.subinventory IS NULL)
  AND   (gs.locator_id    = l_locator_id OR gs.locator_id IS NULL )
  AND   gr.delete_mark = 0
  AND   (gs.cust_id     = l_cust_id OR gs.cust_id IS NULL)
  AND   (gr.result_value_num IS NOT NULL or gr.result_value_char IS NOT NULL)
  AND   gs.sample_active_cnt = 1
  and    ges.disposition  in ('4A','5AV','6RJ') --8577332 changed from 5RJ to 6RJ
  and    ges.spec_used_for_lot_attrib_ind ='Y'
  and    gs.sampling_event_id = ges.sampling_event_id
  and    ges.event_spec_disp_id = sp.event_spec_disp_id
  and    sp.result_id           = gr.result_id
  UNION
  SELECT gs.lot_number,gs.cust_id,gs.creation_date ,/*gs.location,*/gs.subinventory,
         null sample_id,ges.event_spec_disp_id,
         gr.test_id,
         gr.mean result_value_num,
         gr.mode_char result_value_char,'EVENT_SPEC_DISP'
  FROM   GMD_SAMPLING_EVENTS gs ,
         GMD_EVENT_SPEC_DISP sd,
         GMD_COMPOSITE_RESULTS gr,   -- possble change here
         GMD_COMPOSITE_SPEC_DISP ges
  WHERE
  gs.inventory_item_id    = l_inventory_item_id
  AND   (gs.revision    =  l_revision OR gs.revision IS NULL)
  AND   (gs.lot_number    = l_lot_number  OR gs.lot_number IS NULL)
  AND   (gs.subinventory   = l_subinventory OR gs.subinventory IS NULL)
  AND   (gs.locator_id    = l_locator_id OR gs.locator_id IS NULL )
  AND   (gs.cust_id     = l_cust_id OR gs.cust_id IS NULL)
  AND    gr.delete_mark = 0
  AND   (gr.mean IS NOT NULL or gr.mode_char IS NOT NULL)
  AND   gs.sample_active_cnt > 1
  AND   gs.sampling_event_id = sd.sampling_event_id
  and   sd.event_spec_disp_id = ges.event_spec_disp_id
  and    ges.composite_spec_disp_id = gr.composite_spec_disp_id
  and    ges.disposition  in ('4A','5AV','6RJ') ----8577332 changed from 5RJ to 6RJ
  and    nvl(ges.latest_ind,'N') = 'Y'
  ORDER BY 1 ,2,3 desc,4,5,6 ;
-- 2651353  changed the order by clause. sample date takes preference over sub lot no.
-- looks for a sample within a lot_no with latest sample date.

l_lot_counter           BINARY_INTEGER;
l_spec_test_counter     BINARY_INTEGER;
REQ_FIELDS_MISSING      EXCEPTION;
INVALID_LOT             EXCEPTION;
l_sample_rec            cr_get_sample_for_lot%ROWTYPE;

TYPE spec_test_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

spec_test_list  spec_test_tab ;

TYPE result_test_tab IS TABLE OF cr_get_sample_for_lot%ROWTYPE INDEX BY BINARY_INTEGER;

result_test_list                result_test_tab ;
l_spec_tests_exist_in_sample    BOOLEAN := FALSE;
l_result_in_spec                BOOLEAN := TRUE;
l_in_spec                       VARCHAR2(1); -- returned by the results API
BEGIN
 PrintLn('Begin Procedure get_result_match_for_spec');
 PrintLn('p_spec_id = '||p_spec_id);
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --FND_MSG_PUB.initialize;

   l_position := '010';
 PrintLn('l_position = '||l_position);
   IF p_spec_id IS NULL THEN
        PrintLn('RETURN End Procedure get_result_match_for_spec');
        RETURN;
   END IF;

   FOR spec_test_row IN  cr_get_req_spec_tests LOOP
      spec_test_list(spec_test_row.test_id) := spec_test_row.test_id;
   END LOOP;

   l_position := '020';
 PrintLn('l_position = '||l_position);
   l_lot_counter := p_lots.FIRST;
   WHILE l_lot_counter IS NOT NULL
   LOOP
   --BUG#3482676 Anoop.
   --Modified the call to procedure getLatestSample by passing lot no.
   PrintLn('In WHILE l_lot_counter LOOP');
   PrintLn('Calling Procedure getLatestSample');
       getLatestSample(p_spec_id,
                       p_lots(l_lot_counter).lot_number,
                       p_lots(l_lot_counter).event_spec_disp_id,
                       p_lots(l_lot_counter).sample_id);
       PrintLn('The value of event_spec_disp_id after latest sample is '||p_lots(l_lot_counter).event_spec_disp_id);
       PrintLn('The value of sample_id after latest sample is '||p_lots(l_lot_counter).sample_id);
       IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
         log_msg('The value of event_spec_disp_id after latest sample is '||p_lots(l_lot_counter).event_spec_disp_id);
         log_msg('The value of sample_id after latest sample is '||p_lots(l_lot_counter).sample_id);
       END IF;

       IF (p_lots(l_lot_counter).event_spec_disp_id IS NULL AND
          p_lots(l_lot_counter).sample_id           IS NULL) THEN
        /** Mahesh, Can we remove this check for OM too */
        PrintLn('p_lots(l_lot_counter).called_from = '||p_lots(l_lot_counter).called_from);
         IF (p_lots(l_lot_counter).called_from = 'OM') THEN
           IF p_lots(l_lot_counter).inventory_item_id IS NULL OR p_lots(l_lot_counter).lot_number IS NULL OR
             p_lots(l_lot_counter).subinventory IS NULL  THEN
               RAISE REQ_FIELDS_MISSING;
           END IF;
         END IF;
         PrintLn('p_lots(l_lot_counter).lot_number = '||p_lots(l_lot_counter).lot_number);


         l_lot_number := p_lots(l_lot_counter).lot_number;

         l_inventory_item_id   := p_lots(l_lot_counter).inventory_item_id;
         l_revision := p_lots(l_lot_counter).revision; --bug# 4662469
         l_subinventory := p_lots(l_lot_counter).subinventory;
         l_locator_id  := p_lots(l_lot_counter).locator_id;

         l_old_event_spec_disp_id := null;
         l_spec_tests_exist_in_sample := FALSE;
         l_result_in_spec                   := TRUE;
         result_test_list.DELETE;

         l_position := '030';

         PrintLn('l_position  = '||l_position);
         PrintLn('l_inventory_item_id   = '||l_inventory_item_id);
         PrintLn('l_revision   =  '||l_revision);
         PrintLn('l_lot_number    = '||l_lot_number);
         PrintLn('l_subinventory = '||l_subinventory);
         PrintLn('l_locator_id  = '||l_locator_id);
         PrintLn('l_cust_id   = '||l_cust_id);

         OPEN  cr_get_sample_for_lot ;
         LOOP
           PrintLn('In cr_get_sample_for_lot LOOP');
            FETCH cr_get_sample_for_lot INTO l_sample_rec;
            IF cr_get_sample_for_lot%NOTFOUND THEN
              PrintLn('cr_get_sample_for_lot%NOTFOUND EXIT cr_get_sample_for_lot LOOP');
               EXIT ;
            END IF;

            PrintLn('l_sample_rec.event_spec_disp_id = '||l_sample_rec.event_spec_disp_id);
            PrintLn('l_old_event_spec_disp_id        = '||l_old_event_spec_disp_id);
            -- sample changed.check for tests against each sample.
            IF l_old_event_spec_disp_id IS NULL OR l_sample_rec.event_spec_disp_id <> l_old_event_spec_disp_id THEN
               l_old_event_spec_disp_id := l_sample_rec.event_spec_disp_id ;

               PrintLn('1 result_test_list.COUNT = '||result_test_list.COUNT);
               PrintLn('1 spec_test_list.COUNT   = '||spec_test_list.COUNT);
               IF result_test_list.COUNT = spec_test_list.COUNT THEN
                   l_spec_tests_exist_in_sample := TRUE;
                   PrintLn('EXIT cr_get_sample_for_lot LOOP');
                   EXIT; -- once a matching sample with all the reqd spec test is found,then do not continue further.
               END IF;
               result_test_list.DELETE;

            -- If the current test is not in the spec, ignore it.
            -- If the test is already in the result test list, skip this row.
            END IF;

            PrintLn('2 result_test_list.COUNT = '||result_test_list.COUNT);
            PrintLn('2 spec_test_list.COUNT   = '||spec_test_list.COUNT);
            PrintLn('l_sample_rec.test_id     = '||l_sample_rec.test_id);

            IF spec_test_list.EXISTS(l_sample_rec.test_id) AND
              NOT (result_test_list.EXISTS(l_sample_rec.test_id)) THEN
                result_test_list(l_sample_rec.test_id) := l_sample_rec;
            END IF;

         END LOOP;
         CLOSE cr_get_sample_for_lot;
         -- do check again since the last sample won't go through the first test.
         -- Bug 3854427 result_test_list.COUNT and spec_test_list.COUNT need not necessarily be the same.
          --IF result_test_list.COUNT = spec_test_list.COUNT THEN
         IF result_test_list.COUNT <> 0 THEN
             l_spec_tests_exist_in_sample := TRUE;
         END IF;

         l_position := '040';
         PrintLn('l_position = '||l_position);
         IF l_spec_tests_exist_in_sample  THEN
           PrintLn('l_spec_tests_exist_in_sample TRUE');
         -- check test results against the selected sample are in range as per the given specification
            l_spec_test_counter := spec_test_list.FIRST;
            IF (p_lots(l_lot_counter).called_from = 'COA') THEN
              p_lots(l_lot_counter).sample_id        := result_test_list(result_test_list.FIRST).sample_id;
              IF (result_test_list(result_test_list.FIRST).sample_id IS NULL) THEN
                p_lots(l_lot_counter).event_spec_disp_id := result_test_list(result_test_list.FIRST).event_spec_disp_id;
              END IF;
              PrintLn('RETURN End Procedure get_result_match_for_spec');
              RETURN;
            END IF;


            WHILE l_spec_test_counter IS NOT NULL
            LOOP
              PrintLn('In WHILE l_spec_test_counter LOOP');
                l_in_spec := GMD_RESULTS_GRP.rslt_is_in_spec(
                          p_spec_id         => p_spec_id
                  ,     p_test_id         => spec_test_list(l_spec_test_counter)
                  ,     p_rslt_value_num  => result_test_list(l_spec_test_counter).result_value_num
                  ,     p_rslt_value_char => result_test_list(l_spec_test_counter).result_value_char ) ;

                PrintLn('l_in_spec = '||l_in_spec);
                IF l_in_spec IS NULL THEN
                    l_result_in_spec := FALSE;
                    EXIT;
                END IF;
                l_spec_test_counter := spec_test_list.NEXT(l_spec_test_counter);
            END LOOP ;
            l_position := '050';
            PrintLn('l_position = '||l_position);
            IF l_result_in_spec THEN
               PrintLn('l_result_in_spec TRUE');
                p_lots(l_lot_counter).sample_id        := result_test_list(result_test_list.FIRST).sample_id;
                IF (result_test_list(result_test_list.FIRST).sample_id IS NULL) THEN
                  p_lots(l_lot_counter).event_spec_disp_id := result_test_list(result_test_list.FIRST).event_spec_disp_id;
                END IF;
                p_lots(l_lot_counter).spec_match_type  := 'A';
                p_lots(l_lot_counter).result_type      := 'I' ;
            ELSE
               PrintLn('l_result_in_spec FALSE');
                p_lots(l_lot_counter).sample_id        := result_test_list(result_test_list.FIRST).sample_id;
                IF (result_test_list(result_test_list.FIRST).sample_id IS NULL) THEN
                  p_lots(l_lot_counter).event_spec_disp_id := result_test_list(result_test_list.FIRST).event_spec_disp_id;
                END IF;
                p_lots(l_lot_counter).spec_match_type  := 'U';
                p_lots(l_lot_counter).result_type      := 'I' ;
            END IF;
         ELSE
            p_lots(l_lot_counter).spec_match_type := null;
         END IF; -- IF l_spec_tests_exist_in_sample
       END IF;  -- IF (p_lots(l_lot_counter).event_spec_disp_id IS NULL  check for getLatestSample
       l_lot_counter := p_lots.NEXT(l_lot_counter);
   END LOOP; -- WHILE l_lot_counter IS NOT NULL
PrintLn('End Procedure get_result_match_for_spec');

EXCEPTION
WHEN REQ_FIELDS_MISSING THEN
   PrintLn('GMD_REQ_FIELD_MIS , PACKAGE , GMD_SPEC_MATCH_GRP.GET_RESULT_MATCH_FOR_SPEC');
   gmd_api_pub.log_message('GMD_REQ_FIELD_MIS','PACKAGE','GMD_SPEC_MATCH_GRP.GET_RESULT_MATCH_FOR_SPEC');
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
WHEN INVALID_LOT THEN
   PrintLn('GMD_INVALID_LOT , LOT_NUMBER = '||p_lots(l_lot_counter).lot_number);
   gmd_api_pub.log_message('GMD_INVALID_LOT','LOT',to_char(p_lots(l_lot_counter).lot_number));
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
WHEN OTHERS THEN
   PrintLn('GMD_API_ERROR , PACKAGE , GMD_SPEC_MATCH_GRP.GET_RESULT_MATCH_FOR_SPEC , ERROR '||SUBSTR(SQLERRM,1,100)||' l_position = '||l_position);
   gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE','GMD_SPEC_MATCH_GRP.GET_RESULT_MATCH_FOR_SPEC','ERROR', SUBSTR(SQLERRM,1,100),'POSITION',l_position);
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END get_result_match_for_spec ;



PROCEDURE add_sample_to_log(p_sample_id IN NUMBER,
                            p_event_spec_disp_id IN NUMBER) IS

 CURSOR c_sample IS
 select a.organization_id, b.organization_code, a.sample_no
 from   gmd_samples a, mtl_parameters b
 where  sample_id = p_sample_id
 and    a.organization_id = b.organization_id;


CURSOR c_samples  IS
  select a.organization_id, c.organization_code, a.sample_no
  from gmd_samples a,
       gmd_event_spec_disp b,
       mtl_parameters c
  where a.sampling_event_id = b.sampling_event_id
  and   b.event_spec_disp_id = p_event_spec_disp_id
  and   a.organization_id = c.organization_id;

BEGIN
 PrintLn('Begin Procedure add_sample_to_log');
 PrintLn('p_sample_id = '||p_sample_id);
 PrintLn('p_event_spec_disp_id = '||p_event_spec_disp_id);
  IF (p_sample_id IS NOT NULL) THEN
    FOR l_sample_rec in c_sample LOOP
     PrintLn('In c_sample1 LOOP');
     PrintLn('GMD_QC_SAMPLE_NO');
      FND_MESSAGE.SET_NAME('GMD','GMD_QC_SAMPLE_NO');
      FND_MESSAGE.SET_TOKEN('ORGN_CODE'  ,l_sample_rec.organization_code);
      FND_MESSAGE.SET_TOKEN('SAMPLE_NO',l_sample_rec.sample_no);
      FND_MSG_PUB.Add;
    END LOOP;
  ELSE
    FOR l_sample_rec in c_samples LOOP
     PrintLn('In c_samples2 LOOP');
     PrintLn('GMD_QC_SAMPLE_NO');
      FND_MESSAGE.SET_NAME('GMD','GMD_QC_SAMPLE_NO');
      FND_MESSAGE.SET_TOKEN('ORGN_CODE'  ,l_sample_rec.organization_code);
      FND_MESSAGE.SET_TOKEN('SAMPLE_NO',l_sample_rec.sample_no);
      FND_MSG_PUB.Add;
    END LOOP;
  END IF;
 PrintLn('End Procedure add_sample_to_log');
END add_sample_to_log;

PROCEDURE call_spec_match(p_hdr_rec IN OUT NOCOPY t_coa_hdr_rec,
                          x_return_status OUT NOCOPY VARCHAR2) IS

--RLNAGARA Bug # 4916856 Replaced gmd_all_spec_vrs with gmd_com_spec_vrs_vl
  CURSOR c_coa_type(p_spec_vr_id IN NUMBER) IS
  select nvl(coa_type,'A') coa_type
  from   gmd_com_spec_vrs_vl
  where  spec_vr_id = p_spec_vr_id;

  CURSOR cur_spec_hdr_text(l_spec_id IN NUMBER) IS -- Bug # 4260445 Declared Cursor to get the value of text_code
  SELECT text_code
  FROM gmd_specifications
  WHERE spec_id = l_spec_id;

   p_customer_spec_rec   GMD_SPEC_MATCH_GRP.customer_spec_rec_type;
   p_inventory_spec_rec  GMD_SPEC_MATCH_GRP.inventory_spec_rec_type;
   x_return_flag       BOOLEAN;
   x_spec_id           NUMBER;
   x_spec_vr_id        NUMBER;
   l_return_status     VARCHAR2(1000);
   x_message_data      VARCHAR2(1000);
   x_sample_id         NUMBER;
   x_event_spec_disp_id NUMBER;
   l_lot_tbl            result_lot_match_tbl;
   l_coa_type          VARCHAR2(1);
   l_lot_ctl           NUMBER; -- Bug# 5010385

BEGIN
  PrintLn('Begin Procedure call_spec_match');
         /*-----------------------------------------------------------------
             Call customer spec match and inventory spec match
           -------------------------------------------------------------------*/
             p_customer_spec_rec.inventory_item_id := p_hdr_rec.inventory_item_id;  --INVCONV
             p_customer_spec_rec.revision := p_hdr_rec.revision; --Bug# 4662469
             p_customer_spec_rec.cust_id := p_hdr_rec.cust_id;
             p_customer_spec_rec.date_effective := SYSDATE;
             p_customer_spec_rec.subinventory := p_hdr_rec.subinventory;    --INVCONV
             p_customer_spec_rec.org_id := p_hdr_rec.org_id;
             p_customer_spec_rec.order_id := p_hdr_rec.order_id;
             p_customer_spec_rec.organization_id := nvl(p_hdr_rec.organization_id,0);   --INVCONV
             p_customer_spec_rec.look_in_other_orgn := 'Y';
             p_customer_spec_rec.ship_to_site_id := p_hdr_rec.ship_to_site_id;   --Bug 4166529 added.

             PrintLn('p_customer_spec_rec.inventory_item_id = '||p_customer_spec_rec.inventory_item_id);  --INVCONV
             PrintLn('p_customer_spec_rec.revision = '||p_customer_spec_rec.revision);  --Bug# 4662469
             PrintLn('p_customer_spec_rec.cust_id = '||p_customer_spec_rec.cust_id);
             PrintLn('p_customer_spec_rec.date_effective = '||to_char(p_customer_spec_rec.date_effective));
             PrintLn('p_customer_spec_rec.subinventory = '||p_customer_spec_rec.subinventory);       --INVCONV
             PrintLn('p_customer_spec_rec.org_id = '||p_customer_spec_rec.org_id);
             PrintLn('p_customer_spec_rec.order_id = '||p_customer_spec_rec.order_id);
             PrintLn('p_customer_spec_rec.organization_id = '||p_customer_spec_rec.organization_id);  --INVCONV
             PrintLn('p_customer_spec_rec.look_in_other_orgn = '||p_customer_spec_rec.look_in_other_orgn);
             PrintLn('p_customer_spec_rec.ship_to_site_id = '||p_customer_spec_rec.ship_to_site_id);  --Bug 4166529 added.

             PrintLn('Calling GMD_SPEC_MATCH_GRP.FIND_CUSTOMER_SPEC');
             x_return_flag := FALSE;
             x_return_flag := GMD_SPEC_MATCH_GRP.FIND_CUSTOMER_SPEC(p_customer_spec_rec,
                                                                    x_spec_id,
                                                                    x_spec_vr_id,
                                                                    l_return_status,
                                                                    x_message_data);
             IF x_return_flag THEN  -- cust spec found
                PrintLn('CUSTOMER SPEC FOUND');
                PrintLn('call_spec_match, GMD_SPEC_MATCH_GRP.FIND_CUSTOMER_SPEC , Spec_id '||x_spec_id);
                PrintLn('call_spec_match, GMD_SPEC_MATCH_GRP.FIND_CUSTOMER_SPEC , x_spec_vr_id '||x_spec_vr_id);
                PrintLn('call_spec_match, GMD_SPEC_MATCH_GRP.FIND_CUSTOMER_SPEC , l_return_status '||l_return_status);
                PrintLn('call_spec_match, GMD_SPEC_MATCH_GRP.FIND_CUSTOMER_SPEC , x_message_data '||x_message_data);
             END IF;

             IF (x_return_flag = FALSE)  THEN
               PrintLn('CUSTOMER SPEC NOT FOUND');
                p_inventory_spec_rec.inventory_item_id :=  p_hdr_rec.inventory_item_id;  --INVCONV
                p_inventory_spec_rec.revision := p_hdr_rec.revision; --Bug# 4662469
                p_inventory_spec_rec.lot_number  := p_hdr_rec.lot_number;                --INVCONV
                p_inventory_spec_rec.organization_id  := p_hdr_rec.organization_id;      --INVCONV
                p_inventory_spec_rec.date_effective := SYSDATE;
                p_inventory_spec_rec.subinventory := p_hdr_rec.subinventory;              --INVCONV

                PrintLn('p_inventory_spec_rec.inventory_item_id = '||p_inventory_spec_rec.inventory_item_id);  --INVCONV
                PrintLn('p_inventory_spec_rec.revision = '||p_inventory_spec_rec.revision);  --INVCONV
                PrintLn('p_inventory_spec_rec.organization_id  = '||p_inventory_spec_rec.organization_id);  --INVCONV
                PrintLn('p_inventory_spec_rec.parent_lot_number = '||p_inventory_spec_rec.parent_lot_number);    --INVCONV
                PrintLn('p_inventory_spec_rec.lot_number = '||p_inventory_spec_rec.lot_number);    --INVCONV
                PrintLn('p_inventory_spec_rec.date_effective = '||to_char(p_inventory_spec_rec.date_effective));
                PrintLn('p_inventory_spec_rec.subinventory = '||p_inventory_spec_rec.subinventory);  --INVCONV
                PrintLn('p_inventory_spec_rec.locator_id = '||p_inventory_spec_rec.locator_id);   --INVCONV
                PrintLn('p_inventory_spec_rec.grade_code = '||p_inventory_spec_rec.grade_code);   --INVCONV
                PrintLn('p_inventory_spec_rec.exact_match = '||p_inventory_spec_rec.exact_match);   --INVCONV
                PrintLn('Calling GMD_SPEC_MATCH_GRP.FIND_INVENTORY_SPEC');

                x_return_flag := GMD_SPEC_MATCH_GRP.FIND_INVENTORY_SPEC(p_inventory_spec_rec ,
                                                                        x_spec_id ,
                                                                        x_spec_vr_id,
                                                                        l_return_status,
                                                                        x_message_data);
                IF x_return_flag THEN
                   PrintLn('INVENTORY SPEC FOUND');
                   PrintLn('call_spec_match, GMD_SPEC_MATCH_GRP.FIND_INVENTORY_SPEC , Spec_id '||x_spec_id);
                   PrintLn('call_spec_match, GMD_SPEC_MATCH_GRP.FIND_INVENTORY_SPEC , x_spec_vr_id '||x_spec_vr_id);
                   PrintLn('call_spec_match, GMD_SPEC_MATCH_GRP.FIND_INVENTORY_SPEC , l_return_status '||l_return_status);
                   PrintLn('call_spec_match, GMD_SPEC_MATCH_GRP.FIND_INVENTORY_SPEC , x_message_data '||x_message_data);
                END IF;

                IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                  log_msg('call_spec_match, GMD_SPEC_MATCH_GRP.FIND_INVENTORY_SPEC , Spec_id '||x_spec_id);
                  log_msg('call_spec_match, GMD_SPEC_MATCH_GRP.FIND_INVENTORY_SPEC , x_message_data '||x_message_data);
                  log_msg('call_spec_match, GMD_SPEC_MATCH_GRP.FIND_INVENTORY_SPEC , l_return_status '||l_return_status);
                  log_msg('The parameters for inventory=>inventory_item_id, lot_number, subinventory '||
                           p_inventory_spec_rec.inventory_item_id||' '||
                           p_inventory_spec_rec.lot_number||' '||p_inventory_spec_rec.subinventory);
                END IF;

            END IF;
            IF (x_return_flag = FALSE) THEN
             PrintLn('GMD_QC_NO_SPEC_FOUND');
              FND_MESSAGE.SET_NAME('GMD','GMD_QC_NO_SPEC_FOUND');
              FND_MSG_PUB.Add;
              PrintLn('RETURN End Procedure call_spec_match');
              RETURN;
            ELSE
              coa_id := coa_id + 1;
              p_hdr_rec.gmd_coa_id := coa_id;

              PrintLn('p_hdr_rec.gmd_coa_id = '||p_hdr_rec.gmd_coa_id);
              PrintLn('p_hdr_rec.item_number = '||p_hdr_rec.item_number);
              PrintLn('p_hdr_rec.lot_number = '||p_hdr_rec.lot_number);

              IF (p_hdr_rec.item_number IS NULL or p_hdr_rec.lot_number IS NULL) THEN
                  PrintLn('Calling Procedure get_foreign_keys');
                  get_foreign_keys(p_hdr_rec,x_return_status);
              END IF;

              PrintLn('Calling Procedure put_spec_in_log');
              -- to put the information in log.
              put_spec_in_log(x_spec_id,x_return_status);

            END IF;

             -- check if coa can be printed for the spec_vr_id
            OPEN c_coa_type(x_spec_vr_id);
            FETCH c_coa_type INTO l_coa_type;
            CLOSE c_coa_type;

              OPEN cur_spec_hdr_text(x_spec_id); -- Bug # 4260445
              FETCH cur_spec_hdr_text INTO p_hdr_rec.spec_hdr_text_code;
              CLOSE cur_spec_hdr_text;


            PrintLn('p_hdr_rec.lot_number = '||p_hdr_rec.lot_number);
            PrintLn('l_coa_type = '||l_coa_type);

            -- Bug# 5010385
            SELECT lot_control_code INTO l_lot_ctl
              FROM mtl_system_items
             WHERE organization_id = p_hdr_rec.organization_id
               AND inventory_item_id = p_hdr_rec.inventory_item_id;

            PrintLn('Item lot_ctl = '||l_lot_ctl);

            -- Bug 5010385 Added the above select and modified the following IF condition.
            -- IF (p_hdr_rec.lot_number IS NULL OR l_coa_type='C') THEN
            IF (l_coa_type='C') OR (l_lot_ctl = 2 AND p_hdr_rec.lot_number IS NULL) THEN
              PrintLn('GMD_QC_COA_NO_LOT');
              FND_MESSAGE.SET_NAME('GMD','GMD_QC_COA_NO_LOT');
              FND_MSG_PUB.Add;
              p_hdr_rec.report_title := 'COC';

              PrintLn('p_hdr_rec.report_title = '||p_hdr_rec.report_title);
              PrintLn('Calling Procedure insert_hdr_rec');
              insert_hdr_rec(p_hdr_rec,x_return_status);
              PrintLn('Calling Procedure populate_spec');
              populate_spec(x_spec_id,p_hdr_rec.cust_id,'COC',x_return_status);
             ELSE
              --call_mahesh_api for matchih spec
               l_lot_tbl(1).inventory_item_id := p_hdr_rec.inventory_item_id; --INVCONV
               l_lot_tbl(1).revision := p_hdr_rec.revision; --Bug# 4662469
               l_lot_tbl(1).lot_number  := p_hdr_rec.lot_number;    --INVCONV
               l_lot_tbl(1).subinventory := p_hdr_rec.subinventory;    --INVCONV
               l_lot_tbl(1).cust_id := p_hdr_rec.cust_id;
               l_lot_tbl(1).called_from := 'COA';

               PrintLn('Calling Procedure get_result_match_for_spec');
               PrintLn('l_lot_tbl(1).inventory_item_id = '||l_lot_tbl(1).inventory_item_id); --INVCONV
               PrintLn('l_lot_tbl(1).revision = '||l_lot_tbl(1).revision); --Bug# 4662469
               PrintLn('l_lot_tbl(1).lot_number  = '||l_lot_tbl(1).lot_number);   --INVCONV
               PrintLn('l_lot_tbl(1).subinventory = '||l_lot_tbl(1).subinventory);  --INVCONV
               PrintLn('l_lot_tbl(1).cust_id = '||l_lot_tbl(1).cust_id);
               PrintLn('l_lot_tbl(1).called_from = '||l_lot_tbl(1).called_from);

               get_result_match_for_spec( x_spec_id
                                          , l_lot_tbl
                                          , x_return_status
                                          , x_message_data);

               IF (x_return_status <> 'S') THEN
                 PrintLn('Error occurred in execution of gmd_coa_data.get_result_match_for_spec...');
                 log_msg('Error occurred in execution of gmd_coa_data.get_result_match_for_spec...');
               END IF;

              PrintLn('l_lot_tbl(1).sample_id = '||l_lot_tbl(1).sample_id);
              PrintLn('l_lot_tbl(1).event_spec_disp_id = '||l_lot_tbl(1).event_spec_disp_id);
 	      PrintLn('x_spec_id' || x_spec_id);


  PrintLn('p_hdr_rec.spec_hdr_text_code ' || p_hdr_rec.spec_hdr_text_code ); --Bug # 4260445

              IF (l_lot_tbl(1).sample_id IS NOT NULL OR
                  l_lot_tbl(1).event_spec_disp_id IS NOT NULL) THEN
                 PrintLn('Calling Procedure add_sample_to_log');
                 add_sample_to_log(l_lot_tbl(1).sample_id, l_lot_tbl(1).event_spec_disp_id );

                 p_hdr_rec.report_title := 'COA';
                 PrintLn('p_hdr_rec.report_title = '||p_hdr_rec.report_title);
                 PrintLn('Calling Procedure insert_hdr_rec');
                 insert_hdr_rec(p_hdr_rec,x_return_status);
                 PrintLn('Calling Procedure populate_spec');
                 populate_spec(x_spec_id,
                               p_hdr_rec.cust_id,
                              'COA',
                               x_return_status,
                               l_lot_tbl(1).event_spec_disp_id,
                               l_lot_tbl(1).sample_id);
              ELSE
                PrintLn('GMD_QC_COA_NO_ACCEPTED_SAMPLE');
                FND_MESSAGE.SET_NAME('GMD','GMD_QC_COA_NO_ACCEPTED_SAMPLE');
                FND_MSG_PUB.Add;

                p_hdr_rec.report_title := 'COC';

                PrintLn('p_hdr_rec.report_title = '||p_hdr_rec.report_title);
                PrintLn('Calling Procedure insert_hdr_rec');
                insert_hdr_rec(p_hdr_rec,x_return_status);
                PrintLn('Calling Procedure populate_spec');
                populate_spec(x_spec_id,p_hdr_rec.cust_id,'COC',x_return_status);
              END IF;
            END IF;
     PrintLn('End Procedure call_spec_match');
EXCEPTION
   WHEN OTHERS THEN
    PrintLn('GMD_COA_DATA.CALL_SPEC_MATCH '|| SUBSTR(SQLERRM,1,100));
    log_msg('GMD_COA_DATA.CALL_SPEC_MATCH '|| SUBSTR(SQLERRM,1,100));
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
END call_spec_match;

PROCEDURE get_order_params ( p_param_rec     t_coa_parameters,
                             x_return_status OUT NOCOPY VARCHAR2) IS
--get info call spec match if row returned by spec match insert into header
--RLNAGARA Bug 4916856
CURSOR c_order_delivery(p_delivery_id NUMBER,
                        p_order_id    NUMBER,
                        --p_item_id     NUMBER,    --INVCONV
                        p_inventory_item_id NUMBER,       --INVCONV
                        p_org_id      NUMBER,
                        p_cust_id     NUMBER) IS
    select l.header_id order_id,
           l.line_id line_id,
           wdd.delivery_detail_id,
           null organization_code,  --INVCONV
           l.org_id,
           h.order_number order_no,
           h.cust_po_number custpo_no,
           nvl(l.actual_shipment_date,l.schedule_ship_date) actual_shipdate,
           l.ship_to_org_id ,
           wnd.delivery_id bol_id,
           wnd.name bol_no,
           l.inventory_item_id inventory_item_id,   --INVCONV
           msi.concatenated_segments item_number,   --INVCONV
           msi.description item_description,         --INVCONV
           l.item_revision,  --Bug# 4662469
           decode(l.ship_from_org_id, null , h.ship_from_org_id, l.ship_from_org_id) ship_from_org_id,
           l.ship_to_org_id ship_to_site_id, --Bug 4166529 added.
           ship_from_org.organization_code  from_whse,
           h.sold_to_org_id cust_id,
           decode(l.line_category_code,'RETURN',(-1)*l.ordered_quantity, l.ordered_quantity )  order_qty1,
           decode(l.line_category_code,'RETURN',(-1)*l.ordered_quantity2,l.ordered_quantity2)  order_qty2,
           l.order_quantity_uom order_uom1, --INVCONV
           l.ordered_quantity_UOM2 order_uom2, --INVCONV
           wdd.shipped_quantity ship_qty1,
           wdd.shipped_quantity2 ship_qty2,
           l.shipping_quantity_uom ship_qty_uom1, --INVCONV -- Bug # 3710191 Added these two lines.
           l.shipping_quantity_uom2 ship_qty_uom2, --INVCONV
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
         mtl_system_items_b_kfv      msi,  --INVCONV
         hz_cust_accounts              c,
         hz_cust_site_uses_all         s,
         hz_cust_acct_sites_all        a,
         hz_parties    pr
    where h.header_id              = l.header_id
    and   l.header_id              = wdd.source_header_id
    and   l.line_id                = wdd.source_line_id
    and   wnd.delivery_id          = wda.delivery_id
    and   wda.delivery_detail_id   = wdd.delivery_detail_id
    and   (p_order_id      IS NULL OR h.header_id      = p_order_id)
    and   (p_delivery_id   IS NULL OR wnd.delivery_id  = p_delivery_id)
    and   (p_org_id        IS NULL OR a.org_id         = p_org_id)
    and   (p_cust_id       IS NULL OR l.sold_to_org_id = p_cust_id)
    and   (p_inventory_item_id       IS NULL OR msi.inventory_item_id       = p_inventory_item_id)  --INVCONV
    and   wdd.source_code                       ='OE'
    AND wdd.split_from_delivery_detail_ID IS NULL      -- ADDED BY plowe for bug 8733799
    and   l.ship_from_org_id                    = ship_from_org.organization_id(+)
    and   ship_from_org.process_enabled_flag(+) ='Y'
    and ((l.ship_from_org_id IS NOT NULL AND  msi.organization_id = l.ship_from_org_id ) OR (l.ship_from_org_id IS NULL AND  msi.organization_id = h.ship_from_org_id ))
    and   msi.inventory_item_id                 = l.inventory_item_id
    and   l.ship_to_org_id                      = s.site_use_id(+)
    and   s.site_use_code(+)                    = 'SHIP_TO'
    and   s.org_id                              = a.org_id(+)
    and   s.cust_acct_site_id                   = a.cust_acct_site_id(+)
    and   a.cust_account_id                     = c.cust_account_id(+)
    and c.party_id                              = pr.party_id(+)
    order by l.header_id;

--RLNAGARA Bug 4916856
CURSOR c_order ( p_order_id    NUMBER,
                 --p_item_id     NUMBER,  --INVCONV
                 p_inventory_item_id NUMBER,   --INVCONV
                 p_org_id      NUMBER,
                 p_cust_id     NUMBER) IS
    select l.header_id order_id,
           l.line_id line_id,
           l.org_id,
           h.order_number order_no,
           h.cust_po_number custpo_no,
           nvl(l.actual_shipment_date,l.schedule_ship_date) actual_shipdate,
           l.ship_to_org_id ,
           l.inventory_item_id inventory_item_id,  --INVCONV
           msi.concatenated_segments item_number,  --INVCONV
           msi.description item_description,       --INVCONV
           l.item_revision,  --Bug# 4662469
           decode(l.ship_from_org_id, null , h.ship_from_org_id, l.ship_from_org_id) ship_from_org_id,
           l.ship_to_org_id ship_to_site_id, --Bug 4166529 added.
           ship_from_org.organization_code              from_whse,
           decode(l.line_category_code,'RETURN',(-1)*l.ordered_quantity, l.ordered_quantity )  order_qty1,
           decode(l.line_category_code,'RETURN',(-1)*l.ordered_quantity2,l.ordered_quantity2)  order_qty2,
           l.order_quantity_uom order_uom1, --INVCONV
           l.ordered_quantity_UOM2 order_uom2, --INVCONV
           C.cust_account_id shipcust_id,
           C.account_number cust_no,
           pr.party_name cust_name ,
           0 alloc_qty

    FROM
         oe_order_headers_all h,
         oe_order_lines_all l,
         mtl_parameters ship_from_org,
         mtl_system_items_b_kfv msi,  --INVCONV
         hz_cust_accounts              c,
         hz_cust_site_uses_all         s,
         hz_cust_acct_sites_all        a,
         hz_parties    pr
    where h.header_id                              = l.header_id
    and   (p_order_id  IS NULL OR h.header_id      = p_order_id)
    and   (p_org_id    IS NULL OR a.org_id         = p_org_id)
    and   (p_cust_id   IS NULL OR l.sold_to_org_id = p_cust_id)
    and   (p_inventory_item_id   IS NULL OR msi.inventory_item_id       = p_inventory_item_id)
    and   l.ship_from_org_id                       = ship_from_org.organization_id(+)
    and   ship_from_org.process_enabled_flag(+)    = 'Y'
    and ((l.ship_from_org_id IS NOT NULL AND  msi.organization_id = l.ship_from_org_id ) OR (l.ship_from_org_id IS NULL AND  msi.organization_id = h.ship_from_org_id ))
    and   msi.inventory_item_id                    = l.inventory_item_id
    and   l.ship_to_org_id                         = s.site_use_id(+)
    and   s.site_use_code(+)                       = 'SHIP_TO'
    and   s.org_id                                 = a.org_id(+)
    and   s.cust_acct_site_id                      = a.cust_acct_site_id(+)
    and   a.cust_account_id                        = c.cust_account_id(+)
    and   c.party_id                               = pr.party_id(+)
    order by l.header_id;

   --INVCONV
   /*CURSOR get_whse_info (c_ship_from_org_id oe_order_lines.ship_from_org_id%TYPE) IS
   SELECT  s.orgn_code,
           w.whse_code
   FROM   mtl_parameters p,
          ic_whse_mst w,
          sy_orgn_mst s
   WHERE w.mtl_organization_id   = c_ship_from_org_id
   AND   p.ORGANIZATION_ID       = c_ship_from_org_id
   AND   s.orgn_code             = w.orgn_code
   AND   s.orgn_code             = p.process_orgn_code
   AND   p.process_enabled_flag  ='Y'
   AND   s.delete_mark           = 0
   AND   w.delete_mark           = 0
   ;*/

   --INVCONV
   /*CURSOR get_lot_tran (c_line_id ic_tran_pnd.line_id%TYPE) IS
   SELECT itp.lot_id, itp.whse_code, itp.location
   FROM   ic_tran_pnd itp
   WHERE  itp.doc_type        = 'OMSO'
   AND    itp.completed_ind   <> -1
   AND    itp.line_detail_id  = c_line_id
   and    itp.delete_mark     = 0;*/

   --INVCONV
   --RLNAGARA Bug # 4916856
   -- Bug# 5629675 Added distinct in the first select and added union.
   CURSOR Get_Lot_Tran(p_order_line_id oe_order_lines_all.line_id%TYPE) IS
     SELECT distinct MTLT.LOT_NUMBER
     FROM  MTL_TRANSACTION_LOTS_TEMP MTLT,
           MTL_MATERIAL_TRANSACTIONS_TEMP MMTT,
           MTL_TXN_REQUEST_LINES_V MTRL
     WHERE MTLT.TRANSACTION_TEMP_ID = MMTT.TRANSACTION_TEMP_ID
	AND   MMTT.MOVE_ORDER_LINE_ID = MTRL.LINE_ID
	AND   MTRL.TXN_SOURCE_LINE_ID = p_order_line_id
	AND   MTRL.TRANSACTION_TYPE_ID = 52
	AND   MTRL.TRANSACTION_ACTION_ID = 28
	AND   MTRL.TRANSACTION_SOURCE_TYPE_ID = 2
     UNION
	SELECT distinct MTLN.LOT_NUMBER
          FROM MTL_TRANSACTION_LOT_NUMBERS MTLN,
               MTL_MATERIAL_TRANSACTIONS MMT
         WHERE MTLN.TRANSACTION_ID = MMT.TRANSACTION_ID
  	   AND MMT.TRX_SOURCE_LINE_ID = p_order_line_id
	   AND MMT.TRANSACTION_TYPE_ID = 52
	   AND MMT.TRANSACTION_ACTION_ID = 28
	   AND MMT.TRANSACTION_SOURCE_TYPE_ID = 2;

 hdr_rec                       t_coa_hdr_rec;
 l_del_found                   boolean:=FALSE;


 -- 8733799
CURSOR CHECK_DUP_LOT (P_LOT_NUMBER VARCHAR2, P_ORDER_QTY1 NUMBER) IS
SELECT LOT_NUMBER FROM GMD_COA_HEADERS WHERE LOT_NUMBER =  P_LOT_NUMBER AND ORDER_QTY1 = P_ORDER_QTY1;

l_lot_number            VARCHAR2(80);      -- 8733799
l_order_qty1            NUMBER;            -- 8733799


BEGIN
  PrintLn('Begin Procedure get_order_params');

  FOR c_order_rec IN c_order_delivery(p_param_rec.delivery_id,
                           p_param_rec.order_id,
                           --p_param_rec.item_id,
                           p_param_rec.inventory_item_id,
                           p_param_rec.org_id,
                           p_param_rec.cust_id) LOOP

     PrintLn('In c_order_delivery LOOP');
      l_del_found := TRUE;

       hdr_rec.org_id          := c_order_rec.org_id;
       hdr_rec.order_id        := c_order_rec.order_id;
       hdr_rec.line_id         := c_order_rec.line_id;
       hdr_rec.delivery_detail_id  := c_order_rec.delivery_detail_id;
       hdr_rec.order_no        := c_order_rec.order_no;
       hdr_rec.custpo_no       := c_order_rec.custpo_no;
       hdr_rec.cust_id         := c_order_rec.shipcust_id;
       hdr_rec.bol_id          := c_order_rec.bol_id;
       --hdr_rec.item_id         := c_order_rec.item_id;  --INVCONV
       hdr_rec.inventory_item_id         := c_order_rec.inventory_item_id;  --INVCONV
       hdr_rec.revision        := c_order_rec.item_revision; --Bug# 4662469
       hdr_rec.order_qty1      := c_order_rec.order_qty1;
       hdr_rec.order_qty2      := c_order_rec.order_qty2;
       --hdr_rec.order_um1       := c_order_rec.order_um1;  --INVCONV
       --hdr_rec.order_um2       := c_order_rec.order_um2;  --INVCONV
       hdr_rec.order_uom1       := c_order_rec.order_uom1;  --INVCONV
       hdr_rec.order_uom2       := c_order_rec.order_uom2;  --INVCONV
       hdr_rec.ship_qty1       := c_order_rec.ship_qty1;
       hdr_rec.ship_qty2       := c_order_rec.ship_qty2;
       --hdr_rec.ship_uom1       := c_order_rec.ship_uom1; --INVCONV   -- Bug # 3710191 added these two lines.
       --hdr_rec.ship_uom2       := c_order_rec.ship_uom2; --INVCONV
       hdr_rec.ship_qty_uom1   := c_order_rec.ship_qty_uom1; --INVCONV
       hdr_rec.ship_qty_uom2       := c_order_rec.ship_qty_uom2; --INVCONV
       hdr_rec.cust_no         := c_order_rec.cust_no;
       hdr_rec.cust_name       := c_order_rec.cust_name;
       hdr_rec.bol_no          := c_order_rec.bol_no;
       --hdr_rec.item_no         := c_order_rec.item_no;  --INVCONV
       --hdr_rec.item_desc        := c_order_rec.item_desc1;  --INVCONV
       hdr_rec.item_number     := c_order_rec.item_number; --INVCONV
       hdr_rec.item_description    := c_order_rec.item_description; --INVCONV
       hdr_rec.ship_from_org_id := c_order_rec.ship_from_org_id;
       hdr_rec.shipdate         := c_order_rec.actual_shipdate;
       hdr_rec.ship_to_site_id  := c_order_rec.ship_to_site_id;  --Bug 4166529 added.

       PrintLn('hdr_rec.org_id          = '||hdr_rec.org_id);
       PrintLn('hdr_rec.order_id        = '||hdr_rec.order_id);
       PrintLn('hdr_rec.line_id         = '||hdr_rec.line_id);
       PrintLn('hdr_rec.delivery_detail_id  = '||hdr_rec.delivery_detail_id);
       PrintLn('hdr_rec.order_no        = '||hdr_rec.order_no);
       PrintLn('hdr_rec.custpo_no       = '||hdr_rec.custpo_no);
       PrintLn('hdr_rec.cust_id         = '||hdr_rec.cust_id);
       PrintLn('hdr_rec.bol_id          = '||hdr_rec.bol_id);
       --PrintLn('hdr_rec.item_id         = '||hdr_rec.item_id); --INVCONV
       PrintLn('hdr_rec.inventory_item_id         = '||hdr_rec.inventory_item_id); --INVCONV
       PrintLn('hdr_rec.revsion   ='||hdr_rec.revision); --Bug# 4662469
       PrintLn('hdr_rec.order_qty1      = '||hdr_rec.order_qty1);
       PrintLn('hdr_rec.order_qty2      = '||hdr_rec.order_qty2);
       --PrintLn('hdr_rec.order_um1       = '||hdr_rec.order_um1); --INVCONV
       --PrintLn('hdr_rec.order_um2       = '||hdr_rec.order_um2); --INVCONV
       PrintLn('hdr_rec.order_uom1       = '||hdr_rec.order_uom1); --INVCONV
       PrintLn('hdr_rec.order_uom2       = '||hdr_rec.order_uom2); --INVCONV
       PrintLn('hdr_rec.ship_qty1       = '||hdr_rec.ship_qty1);
       PrintLn('hdr_rec.ship_qty2       = '||hdr_rec.ship_qty2);
       --PrintLn('hdr_rec.ship_uom1       = '||hdr_rec.ship_uom1); --INVCONV -- Bug # 3710191 Added these two lines
       --PrintLn('hdr_rec.ship_uom2       = '||hdr_rec.ship_uom2);
       PrintLn('hdr_rec.ship_qty_uom1       = '||hdr_rec.ship_qty_uom1); --INVCONV
       PrintLn('hdr_rec.ship_qty_uom2       = '||hdr_rec.ship_qty_uom2); --INVCONV
       PrintLn('hdr_rec.cust_no   = '||hdr_rec.cust_no);
       PrintLn('hdr_rec.cust_name = '||hdr_rec.cust_name);
       PrintLn('hdr_rec.bol_no = '||hdr_rec.bol_no);
       --PrintLn('hdr_rec.item_no   = '||hdr_rec.item_no); --INVCONV
       --PrintLn('hdr_rec.item_desc = '||hdr_rec.item_desc); --INVCONV
       PrintLn('hdr_rec.item_number   = '||hdr_rec.item_number); --INVCONV
       PrintLn('hdr_rec.item_description = '||hdr_rec.item_description); --INVCONV
       PrintLn('hdr_rec.ship_from_org_id = '||hdr_rec.ship_from_org_id);
       PrintLn('hdr_rec.shipdate = '||hdr_rec.shipdate);
       PrintLn('hdr_rec.ship_to_site_id = '||hdr_rec.ship_to_site_id);   --Bug 4166529 added.

       --INVCONV
       /*OPEN  get_whse_info(c_order_rec.ship_from_org_id);
       FETCH get_whse_info INTO hdr_rec.orgn_code,hdr_rec.whse_code;
       CLOSE get_whse_info;*/

       hdr_rec.organization_id := c_order_rec.ship_from_org_id; --INVCONV
       PrintLn('hdr_rec.organization_id = '||hdr_rec.organization_id); --INVCONV

       --INVCONV
       /*FOR c_lot_tran in  get_lot_tran(c_order_rec.delivery_detail_id) LOOP
         PrintLn('In get_lot_tran LOOP');
          hdr_rec.lot_id := c_lot_tran.lot_id;
          PrintLn('hdr_rec.lot_id(:= c_lot_tran.lot_id) = '||hdr_rec.lot_id);
       --BEGIN BUG#3615409
       --Initialized the lot_no
       --Moved the call_spec_match within the loop to fetch  lot_no correctly.
          hdr_rec.lot_no := NULL;
       IF (hdr_rec.lot_id IS NULL) THEN
          hdr_rec.lot_id := p_param_rec.lot_id;
          hdr_rec.lot_no := p_param_rec.lot_no;
       END IF;
       PrintLn('hdr_rec.lot_id = '||hdr_rec.lot_id);
       PrintLn('hdr_rec.lot_no = '||hdr_rec.lot_no);
       PrintLn('Calling Procedure call_spec_match');
        call_spec_match(hdr_rec,
                        x_return_status);
        --END BUG#3615409
       END LOOP;*/

       --INVCONV


       FOR c_lot_tran in get_lot_tran(c_order_rec.line_id) LOOP





         PrintLn('In get_lot_tran LOOP');
    	   hdr_rec.lot_number := c_lot_tran.lot_number;
         PrintLn('hdr_rec.lot_number(:= c_lot_tran.lot_number) = '||hdr_rec.lot_number);

         --  8733799 need to add this as it was in before but not included in INVCONV


         --BEGIN BUG#3615409
       --Initialized the lot_no
       --Moved the call_spec_match within the loop to fetch  lot_no correctly.
       IF (hdr_rec.lot_number IS NULL) THEN
          hdr_rec.lot_number := p_param_rec.lot_number;
       END IF;
       PrintLn('hdr_rec.lot_number = '||hdr_rec.lot_number);


       --  fix for 8733799 - to check for duplicates in the gmd_coa_headers table

        --  check dup lot
        OPEN  Check_Dup_Lot(hdr_rec.lot_number , hdr_rec.order_qty1);
        FETCH check_dup_lot INTO l_lot_number;
        IF check_dup_lot%NOTFOUND THEN

      	   PrintLn('Calling Procedure call_spec_match');


        	 call_spec_match(hdr_rec,x_return_status);


        END IF;
        CLOSE check_dup_lot;
        --PrintLn('Calling Procedure call_spec_match'); fix for 8733799


         --call_spec_match(hdr_rec,x_return_status); --  fix for 8733799 comment out as writing 2 headers here
       END LOOP;
  END LOOP;

  --If the delivery_id is passed or  the previous cursor returned rows.
  --BEGIN BUG#3615409
  IF (p_param_rec.delivery_id IS NOT NULL  OR  l_del_found) THEN
  --END BUG#3615409
    PrintLn('RETURN End Procedure get_order_params');
     RETURN;
  END IF;

  FOR c_order_rec IN c_order(p_param_rec.order_id,
                             --p_param_rec.item_id, --INVCONV
                             p_param_rec.inventory_item_id, --INVCONV
                             p_param_rec.org_id,
                             p_param_rec.cust_id) LOOP
       PrintLn('In c_order LOOP');

       hdr_rec.org_id          := c_order_rec.org_id;
       hdr_rec.order_id        := c_order_rec.order_id;
       hdr_rec.line_id         := c_order_rec.line_id;
       hdr_rec.order_no        := c_order_rec.order_no;
       hdr_rec.custpo_no       := c_order_rec.custpo_no;
       hdr_rec.cust_id         := c_order_rec.shipcust_id;
       --hdr_rec.item_id         := c_order_rec.item_id;  --INVCONV
       hdr_rec.inventory_item_id  := c_order_rec.inventory_item_id;  --INVCONV
       hdr_rec.revision        := c_order_rec.item_revision; --Bug# 4662469
       hdr_rec.order_qty1      := c_order_rec.order_qty1;
       hdr_rec.order_qty2      := c_order_rec.order_qty2;
       --hdr_rec.order_um1       := c_order_rec.order_um1;  --INVCONV
       --hdr_rec.order_um2       := c_order_rec.order_um2;  --INVCONV
       hdr_rec.order_uom1       := c_order_rec.order_uom1;  --INVCONV
       hdr_rec.order_uom2       := c_order_rec.order_uom2;  --INVCONV
       hdr_rec.cust_no   := c_order_rec.cust_no;
       hdr_rec.cust_name := c_order_rec.cust_name;
       --hdr_rec.item_no   := c_order_rec.item_no;  --INVCONV
       --hdr_rec.item_desc := c_order_rec.item_desc1;  --INVCONV
       hdr_rec.item_number   := c_order_rec.item_number;  --INVCONV
       hdr_rec.item_description := c_order_rec.item_description; --INVCONV
       hdr_rec.ship_from_org_id := c_order_rec.ship_from_org_id;
       hdr_rec.shipdate := c_order_rec.actual_shipdate;
       --hdr_rec.lot_id := p_param_rec.lot_id;  --INVCONV
       --hdr_rec.lot_no := p_param_rec.lot_no;  --INVCONV
       hdr_rec.lot_number := p_param_rec.lot_number;  --INVCONV
       hdr_rec.ship_to_site_id  := c_order_rec.ship_to_site_id;  --Bug 4166529 added.


       PrintLn('hdr_rec.org_id          = '||hdr_rec.org_id);
       PrintLn('hdr_rec.order_id        = '||hdr_rec.order_id);
       PrintLn('hdr_rec.line_id         = '||hdr_rec.line_id);
       PrintLn('hdr_rec.order_no        = '||hdr_rec.order_no);
       PrintLn('hdr_rec.custpo_no       = '||hdr_rec.custpo_no);
       PrintLn('hdr_rec.cust_id         = '||hdr_rec.cust_id);
       --PrintLn('hdr_rec.item_id         = '||hdr_rec.item_id);  --INVCONV
       PrintLn('hdr_rec.inventory_item_id         = '||hdr_rec.inventory_item_id);  --INVCONV
       PrintLn('hdr_rec.revsion   ='||hdr_rec.revision); --Bug# 4662469
       PrintLn('hdr_rec.order_qty1      = '||hdr_rec.order_qty1);
       PrintLn('hdr_rec.order_qty2      = '||hdr_rec.order_qty2);
       --PrintLn('hdr_rec.order_um1       = '||hdr_rec.order_um1);  --INVCONV
       --PrintLn('hdr_rec.order_um2       = '||hdr_rec.order_um2);  --INVCONV
       PrintLn('hdr_rec.order_uom1       = '||hdr_rec.order_uom1);  --INVCONV
       PrintLn('hdr_rec.order_uom2       = '||hdr_rec.order_uom2);  --INVCONV
       PrintLn('hdr_rec.cust_no   = '||hdr_rec.cust_no);
       PrintLn('hdr_rec.cust_name = '||hdr_rec.cust_name);
       --PrintLn('hdr_rec.item_no   = '||hdr_rec.item_no);   --INVCONV
       --PrintLn('hdr_rec.item_desc = '||hdr_rec.item_desc); --INVCONV
       PrintLn('hdr_rec.item_number   = '||hdr_rec.item_number); --INVCONV
       PrintLn('hdr_rec.item_description = '||hdr_rec.item_description); --INVCONV
       PrintLn('hdr_rec.ship_from_org_id = '||hdr_rec.ship_from_org_id);
       PrintLn('hdr_rec.shipdate = '||hdr_rec.shipdate);
       --PrintLn('hdr_rec.lot_id = '||hdr_rec.lot_id);  --INVCONV
       --PrintLn('hdr_rec.lot_no = '||hdr_rec.lot_no);  --INVCONV
       PrintLn('hdr_rec.lot_number = '||hdr_rec.lot_number); --INVCONV
       PrintLn('hdr_rec.ship_to_site_id = '||hdr_rec.ship_to_site_id);   --Bug 4166529 added.

       --INVCONV
       /*OPEN  get_whse_info(c_order_rec.ship_from_org_id);
       FETCH get_whse_info INTO hdr_rec.orgn_code,hdr_rec.whse_code;
       CLOSE get_whse_info;
       PrintLn('hdr_rec.orgn_code = '||hdr_rec.orgn_code);
       PrintLn('hdr_rec.whse_code = '||hdr_rec.whse_code);*/

       hdr_rec.organization_id := c_order_rec.ship_from_org_id; --INVCONV
       PrintLn('hdr_rec.organization_id = '||hdr_rec.organization_id); --INVCONV

       --INVCONV
       /*   hdr_rec.lot_no := NULL;
       IF (hdr_rec.lot_id IS NULL) THEN
          hdr_rec.lot_id := p_param_rec.lot_id;
          hdr_rec.lot_no := p_param_rec.lot_no;
       END IF;
       PrintLn('hdr_rec.lot_id = '||hdr_rec.lot_id);
       PrintLn('hdr_rec.lot_no = '||hdr_rec.lot_no);*/
       PrintLn('Calling Procedure call_spec_match');
        call_spec_match(hdr_rec,
                        x_return_status);




  END LOOP;
 PrintLn('End Procedure get_order_params');
EXCEPTION

   WHEN OTHERS THEN
    PrintLn('GMD_COA_DATA.GET_ORDER_PARAMS '|| SUBSTR(SQLERRM,1,100));
    log_msg('GMD_COA_DATA.GET_ORDER_PARAMS '|| SUBSTR(SQLERRM,1,100));
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

END get_order_params;

PROCEDURE populate_coa_data(
 p_api_version          IN               NUMBER
, p_init_msg_list       IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit              IN               VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level    IN               NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
, x_return_status       OUT NOCOPY       VARCHAR2
, x_msg_count           OUT NOCOPY       NUMBER
, x_msg_data            OUT NOCOPY       VARCHAR2
, param_rec             IN               t_coa_parameters) IS
  hdr_rec     t_coa_hdr_rec;
  l_api_name           CONSTANT VARCHAR2(30)   := 'populate_coa_data' ;
  l_api_version        CONSTANT NUMBER         := 1.0 ;

BEGIN

Log_Initialize;  -- Initialize Debug Log File

  PrintLn('Begin Procedure populate_coa_data');
  PrintLn('param_rec.order_id    = '||param_rec.order_id);
  --PrintLn('param_rec.orgn_code   = '||param_rec.orgn_code);    --INVCONV
  PrintLn('param_rec.organization_id   = '||param_rec.organization_id); --INVCONV
  PrintLn('param_rec.cust_id     = '||param_rec.cust_id);
  PrintLn('param_rec.delivery_id = '||param_rec.delivery_id);
  --PrintLn('param_rec.item_id     = '||param_rec.item_id);  --INVCONV
  PrintLn('param_rec.inventory_item_id     = '||param_rec.inventory_item_id);  --INVCONV
  PrintLn('param_rec.revision  = '||param_rec.revision);  --Bug# 4662469
  --PrintLn('param_rec.whse_code   = '||param_rec.whse_code);  --INVCONV
  PrintLn('param_rec.subinventory   = '||param_rec.subinventory);  --INVCONV
  --PrintLn('param_rec.location    = '||param_rec.location);  --INVCONV
  PrintLn('param_rec.locator_id    = '||param_rec.locator_id);  --INVCONV
  --PrintLn('param_rec.lot_id      = '||param_rec.lot_id);  --INVCONV
  --PrintLn('param_rec.lot_no      = '||param_rec.lot_no);  --INVCONV
  PrintLn('param_rec.lot_number      = '||param_rec.lot_number);  --INVCONV
  PrintLn('param_rec.org_id      = '||param_rec.org_id);
  PrintLn('param_rec.sampling_event_id    = '||param_rec.sampling_event_id);
  PrintLn('param_rec.spec_id              = '||param_rec.spec_id);
  PrintLn('param_rec.ship_to_site_id      = '||param_rec.ship_to_site_id); -- Bug# 5399406

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (   l_api_version          ,
                                         p_api_version          ,
                                         l_api_name             ,
                                         G_PKG_NAME ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status :=FND_API.G_RET_STS_SUCCESS;

  IF (param_rec.delivery_id IS NOT NULL or param_rec.order_id IS NOT NULL) THEN
     PrintLn('Calling Procedure get_order_params');
      get_order_params(param_rec,
                       x_return_status);
  ELSE
    hdr_rec.cust_id := param_rec.cust_id;
    hdr_rec.order_id := param_rec.order_id;
    --hdr_rec.item_id   :=param_rec.item_id;  --INVCONV
    hdr_rec.inventory_item_id   :=param_rec.inventory_item_id;  --INVCONV
    hdr_rec.revision  := param_rec.revision; --Bug# 4662469
    --hdr_rec.whse_code := param_rec.whse_code;  --INVCONV
    hdr_rec.subinventory := param_rec.subinventory;  --INVCONV
    --hdr_rec.lot_id  := param_rec.lot_id;  --INVCONV
    --hdr_rec.lot_no := param_rec.lot_no;   --INVCONV
    hdr_rec.lot_number := param_rec.lot_number;  --INVCONV
    hdr_rec.org_id := param_rec.org_id;
    --hdr_rec.orgn_code := param_rec.orgn_code;  --INVCONV
    hdr_rec.organization_id := param_rec.organization_id;  --INVCONV
    hdr_rec.ship_to_site_id := param_rec.ship_to_site_id; --Bug# 5399406

    -- these two parameters are for short circuiting
    --hdr_rec.sampling_event_id
    --hdr_rec.spec_id

    PrintLn('Calling Procedure call_spec_match');
    call_spec_match(hdr_rec,
                    x_return_status);
  END IF;
      FND_MSG_PUB.Count_AND_GET
        (p_count => x_msg_count, p_data  => x_msg_data);
 PrintLn('End Procedure populate_coa_data');
EXCEPTION

   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    PrintLn('GMD_COA_DATA.POPULATE_COA_DATA '|| SUBSTR(SQLERRM,1,100));
    log_msg('GMD_COA_DATA.POPULATE_COA_DATA '|| SUBSTR(SQLERRM,1,100));
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_msg_count, p_data  => x_msg_data);
END populate_coa_data;
--  /*************************************************************************
--  # PROC
--  #     Log_Initialize
--  #
--  # INPUT PARAMETERS
--  #     filename
--  # DESCRIPTION
--  #   Procedure to initialize the debug log.
--  #
--  #
--  #**************************************************************************/
PROCEDURE Log_Initialize
IS

LOG          UTL_FILE.FILE_TYPE;
l_file_name  VARCHAR2(10) := 'GMDLOG.txt';

CURSOR c_get_1st_location IS
SELECT NVL( SUBSTR( value, 1, INSTR( value, ',')-1), value)
FROM v$parameter
WHERE name = 'utl_file_dir';

BEGIN

       OPEN  c_get_1st_location;
       FETCH c_get_1st_location
       INTO  g_gmdlog_location;
       CLOSE c_get_1st_location;

       LOG := UTL_FILE.fopen(g_gmdlog_location, l_file_name, 'w');
       UTL_FILE.put_line(LOG, 'Log file opened: '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
       UTL_FILE.fflush(LOG);
       UTL_FILE.fclose(LOG);

EXCEPTION
  WHEN OTHERS THEN
    NULL;

END Log_Initialize;

--  /*************************************************************************
--  # PROC
--  #     PrintLine
--  #
--  # INPUT PARAMETERS
--  #     string
--  # DESCRIPTION
--  #   Procedure to write the debug log.
--  #
--  #
--  #**************************************************************************/
PROCEDURE PrintLn( p_msg  IN  VARCHAR2 ) IS

        CURSOR get_log_file_location IS
        SELECT NVL( SUBSTR( value, 1, instr( value, ',')-1), value)
        FROM   v$parameter
        WHERE  name = 'utl_file_dir';


        l_log                UTL_FILE.file_type;
        l_file_name          VARCHAR2(80) := 'GMDLOG.txt';

BEGIN

          IF g_gmdlog_location is NULL THEN
            OPEN   get_log_file_location;
            FETCH  get_log_file_location into gmd_coa_data_om_new.g_gmdlog_location;
            CLOSE  get_log_file_location;
          END IF;

           l_log := UTL_FILE.fopen(g_gmdlog_location, l_file_name, 'a');
           IF UTL_FILE.IS_OPEN(l_log) THEN
              UTL_FILE.put_line(l_log, p_msg);
              UTL_FILE.fflush(l_log);
              UTL_FILE.fclose(l_log);
           END IF;

    EXCEPTION

            WHEN OTHERS THEN
                NULL;

END PrintLn;

END gmd_coa_data_om_new;

/
