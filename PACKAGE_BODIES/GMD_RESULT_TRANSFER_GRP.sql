--------------------------------------------------------
--  DDL for Package Body GMD_RESULT_TRANSFER_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_RESULT_TRANSFER_GRP" AS
--$Header: GMDGRSTB.pls 120.2 2006/05/02 23:14:43 rlnagara noship $

 l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

 --+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDGRSTB.pls                                        |
--| Package Name       : gmd_result_transfer_grp                             |
--| Type               : Group                                               |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains group layer APIs for Results  Assoc.            |
--|                                                                          |
--| HISTORY                                                                  |
--|    Manish Gupta     19-Aug-2003     Created.                             |
--|                                                                          |
--+==========================================================================+
-- End of comments


   FUNCTION get_test_code(p_test_id IN NUMBER) RETURN VARCHAR2 IS
    cursor get_test IS
	 SELECT TEST_CODE
	 FROM   gmd_qc_tests_b
	 WHERE  test_id = p_test_id;

	 l_test_code   gmd_qc_tests_b.test_code%TYPE;
    BEGIN
	  OPEN get_test;
	  FETCH get_test INTO l_test_code;
	  CLOSE get_test;
	  RETURN l_test_code;
	END get_test_code;

   PROCEDURE log_msg(p_msg_text IN VARCHAR2);

   PROCEDURE populate_transfer(p_child_id      IN         NUMBER,
                               p_parent_id     IN         NUMBER,
							   p_transfer_type IN         VARCHAR2,
							   x_message_count OUT NOCOPY NUMBER,
							   x_message_data  OUT NOCOPY VARCHAR2,
							   x_return_status OUT NOCOPY VARCHAR2) IS

    CURSOR c_get_common_test(p_child_sample_id IN  NUMBER,
	                         p_parent_sample_id IN NUMBER) IS
      SELECT distinct r1.seq,
		      r1.test_id,
	              r1.test_method_id
	  FROM   gmd_results r1
	  WHERE  r1.sample_id = p_child_sample_id
	  AND    r1.result_value_char IS NULL
	  AND    r1.result_value_num IS NULL
	  AND    r1.reserve_sample_id IS NULL
	  and    r1.delete_mark = 0
	  AND    r1.test_id IN (SELECT distinct r2.test_id
	                        FROM   gmd_results r2,
							       gmd_spec_results sr
							WHERE  r2.sample_id = p_parent_sample_id
							AND    r2.result_id = sr.result_id
							AND    r2.test_method_id = r1.test_method_id
							AND    r2.delete_mark = 0
                            AND    sr.evaluation_ind IN ('0A','1V','2R','3E'))
     ORDER BY r1.seq; --RLNAGARA bug5197746 added the ORDER BY clause


     CURSOR c_get_child_test(p_child_sample_id IN NUMBER,
	                         p_test_id         IN NUMBER,
							 p_test_method_id  IN NUMBER) IS
     SELECT r.result_id,
	        r.TEST_REPLICATE_CNT
	 FROM   gmd_results r
	 WHERE  r.sample_id = p_child_sample_id
	 AND    r.test_id   = p_test_id
	 AND    r.test_method_id = p_test_method_id
	 AND    r.result_value_char IS NULL
	 AND    r.result_value_num IS NULL
     AND    r.reserve_sample_id IS NULL
	 AND    r.delete_mark = 0;

    CURSOR c_get_parent_test(p_parent_sample_id IN NUMBER,
	                         p_test_id          IN NUMBER,
							 p_test_method_id   IN NUMBER) IS
    SELECT r.result_id,
	       r.test_replicate_cnt,
	       r.result_value_char,
		   r.result_value_num,
		   r.result_date,
		   r.test_method_id
	FROM   gmd_results r,
	       gmd_spec_results sr,
               gmd_sample_spec_disp ssd,
               gmd_event_spec_disp  esd
	WHERE  r.sample_id = p_parent_sample_id
	AND    r.test_id = p_test_id
	AND    r.test_method_id = p_test_method_id
	AND    r.result_id = sr.result_id
	AND    sr.evaluation_ind  IN ('0A','1V','2R','3E')
        AND    sr.event_spec_disp_id = ssd.event_spec_disp_id
        AND    r.sample_id          = ssd.sample_id
        AND    ssd.event_spec_disp_id = esd.event_spec_disp_id
        AND    esd.SPEC_USED_FOR_LOT_ATTRIB_IND = 'Y'
	AND    r.delete_mark = 0
	ORDER by r.result_date desc;

CURSOR c_get_composite_test(p_child_id IN NUMBER,
                            p_parent_id IN NUMBER) IS
select r.composite_result_id,
       r.test_id test_id,
       nvl(to_char(r.mean),r.mode_char) result,
       r.mean,
       r.mode_num,
       r.mode_char,
       r.low_num,
       r.high_num,
       r.range,
       r.non_validated_result,
       r.standard_deviation , ges.spec_id,
	   r.creation_date
from   gmd_composite_results r,
       gmd_composite_spec_disp sd,
       gmd_event_spec_disp ges
where  r.composite_spec_disp_id =sd.composite_spec_disp_id
--and    sd.event_spec_disp_id = 1
and    sd.event_spec_disp_id = ges.event_spec_disp_id
and    nvl(ges.spec_used_for_lot_attrib_ind,'N') = 'Y'
and    nvl(sd.latest_ind,'N') = 'Y'
and    ges.sampling_event_id = p_parent_id
and    r.test_id in (select r1.test_id
                     from gmd_composite_results r1,
					      gmd_composite_spec_disp gcs,
						  gmd_event_spec_disp    ges
					 where ges.event_spec_disp_id = gcs.event_spec_disp_id
					 and   gcs.latest_ind = 'Y'
					 and   gcs.composite_spec_disp_id = r1.composite_spec_disp_id
					 and   ges.sampling_event_id = p_child_id
					 and   r1.mean IS NULL AND r1.mode_char IS NULL);

Cursor c_get_child_composite(p_sampling_event_id IN NUMBER,
                             p_test_id           IN NUMBER) IS
	select r1.composite_result_id
                     from gmd_composite_results r1,
					      gmd_composite_spec_disp gcs,
						  gmd_event_spec_disp    ges
					 where ges.event_spec_disp_id = gcs.event_spec_disp_id
					 and   gcs.latest_ind = 'Y'
					 and   gcs.composite_spec_disp_id = r1.composite_spec_disp_id
					 and   ges.sampling_event_id = p_sampling_event_id
					 and   r1.test_id             = p_test_id
					 and   r1.mean IS NULL AND r1.mode_char IS NULL;

	l_seq                    NUMBER; --RLNAGARA Bug5197746
	l_test_id                NUMBER;
	l_test_method_id         NUMBER;
	l_prev_used              VARCHAR2(1);
	c_get_child_sample_row   c_get_child_test%ROWTYPE;
	c_get_parent_sample_row  c_get_parent_test%ROWTYPE;
	c_get_composite_test_row c_get_composite_test%ROWTYPE;
	l_common_test_count      NUMBER:=0;
	l_child_composite_result_id NUMBER;
	l_place                    NUMBER;
    l_test_code   gmd_qc_tests_b.test_code%TYPE;



BEGIN
   x_return_status :=FND_API.G_RET_STS_SUCCESS;
   FND_MSG_PUB.initialize;
   --GMD_API_PUB.Log_Message('Deleting gmd_result_transfer_gt');
   l_place := 0;
   DELETE gmd_result_transfer_gt;
   l_place := 10;
   IF (p_transfer_type = 'S') THEN
     l_place := 20;

	 IF (l_debug = 'Y') THEN
	  GMD_debug.put_line('Entering populate transfer for samples');
	 END IF;
     OPEN c_get_common_test(p_child_id,
	                        p_parent_id);

	   l_place := 30;
	   LOOP
         FETCH c_get_common_test INTO l_seq,l_test_id,l_test_method_id; --RLNAGARA Bug5197746 Added l_seq

		 IF (l_debug = 'Y') THEN
	       GMD_debug.put_line('Common Test Id, test_method_id Is '||l_test_id||' '||l_test_method_id);
	     END IF;

		 l_place := 40;
	     IF (c_get_common_test%NOTFOUND) THEN
		   CLOSE c_get_common_test;
		   IF (l_common_test_count = 0) THEN
		     x_return_status := 'N';  --No common test
		   END IF;
		   EXIT;
 		 END IF;
		 l_place := 50;

		 OPEN c_get_child_test (p_child_id,
		                        l_test_id,
					l_test_method_id);
         OPEN c_get_parent_test(p_parent_id,
		                        l_test_id,
								l_test_method_id);
         l_place := 60;
         LOOP
           FETCH c_get_child_test INTO c_get_child_sample_row;
		   --lock the child row
		  IF (l_debug = 'Y') THEN
	        GMD_debug.put_line('Child result id, replicate_cnt is '||c_get_child_sample_row.result_id||' '||c_get_child_sample_row.test_replicate_cnt);
	      END IF;


           l_place := 70;
           FETCH c_get_parent_test  INTO c_get_parent_sample_row;
		   IF (c_get_child_test%NOTFOUND OR c_get_parent_test%NOTFOUND) THEN
	 	     CLOSE c_get_child_test;
		     CLOSE c_get_parent_test;
		     EXIT;
            END IF;
			l_place := 80;
			--This parent_result_id should not be used previously for the same sample
			BEGIN
			  SELECT 'Y'
			  INTO   l_prev_used
			  FROM   gmd_results
			  WHERE  sample_id = p_child_id
			  and    parent_result_id = c_get_parent_sample_row.result_id
			  AND    rownum =1;
			EXCEPTION
			  WHEN no_data_found THEN
			    l_prev_used := 'N';
			END;

			IF (l_debug = 'Y') THEN
			 gmd_debug.put_line('The value of the prev used parameter is '||l_prev_used);
			END IF;

			l_place := 85;
           	--insert statement for temp table
			IF (l_prev_used = 'N') THEN

  	  		 l_common_test_count := l_common_test_count +1;

			  IF NOT GMD_RESULTS_PVT.LOCK_ROW ( p_result_id => c_get_child_sample_row.result_id ) THEN
                 RAISE FND_API.G_EXC_ERROR;
              END IF;
		      l_test_code := get_test_code(l_test_id);

			  INSERT INTO gmd_result_transfer_gt
			   (parent_result_id,
			   child_result_id,
			   test_code,
			   result,
			   result_date,
			   parent_replicate,
			   child_replicate)
			  VALUES(c_get_parent_sample_row.result_id,
			         c_get_child_sample_row.result_id,
			         l_test_code,
                     nvl(c_get_parent_sample_row.result_value_char,c_get_parent_sample_row.result_value_num),
		             c_get_parent_sample_row.result_date,
			         c_get_parent_sample_row.test_replicate_cnt,
			         c_get_child_sample_row.test_replicate_cnt);
		    END IF;
		 END LOOP;
      END LOOP;
	  l_place := 90;
  ELSE
    OPEN c_get_composite_test(p_child_id,
	                          p_parent_id);
    l_place := 100;
    LOOP
      FETCH c_get_composite_test INTO c_get_composite_test_row;
	  l_place := 110;
	  IF (c_get_composite_test%NOTFOUND) THEN
	    CLOSE c_get_composite_test;
	    IF (l_common_test_count = 0) THEN
		  x_return_status := 'N';  --No common test
		END IF;
	    EXIT;
      END IF;
	  l_place := 120;
	  l_common_test_count := l_common_test_count +1;
	  OPEN c_get_child_composite(p_child_id,
	                             c_get_composite_test_row.test_id);
      FETCH c_get_child_composite INTO l_child_composite_result_id;
	  CLOSE c_get_child_composite;
	  l_place := 130;
	  --INSERT Statement
		    l_test_code := get_test_code(c_get_composite_test_row.test_id);
	  		INSERT INTO gmd_result_transfer_gt
			(parent_result_id,
			child_result_id,
			test_code,
			result,
			result_date,
			parent_replicate,
			child_replicate)
			VALUES(c_get_composite_test_row.composite_result_id,
			l_child_composite_result_id,
			l_test_code,
            c_get_composite_test_row.result,
		    c_get_composite_test_row.creation_date,
			NULL,
			NULL);

    END LOOP;
	  l_place := 140;
  END IF;
        l_place := 150;
        FND_MSG_PUB.Count_AND_GET
        (p_count => x_message_count, p_data  => x_message_data);

EXCEPTION

   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    log_msg('GMD_QC_RESULT_TRANSFER_GRP.POPULATE_TRANSFER AT '||l_place||' '|| SUBSTR(SQLERRM,1,100));
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_message_count, p_data  => x_message_data);

END populate_transfer;

PROCEDURE do_transfer(p_transfer_type   IN         VARCHAR2,
                      p_copy_edit_text  IN         VARCHAR2,
         			  p_copy_flex_field IN         VARCHAR2,
                      p_copy_attachment IN         VARCHAR2,
					  p_sampling_event_id IN       NUMBER,
					  p_sample_id       IN         NUMBER,
                      x_sample_disp     OUT NOCOPY VARCHAR2,
                      x_message_count   OUT NOCOPY NUMBER,
                      x_message_data    OUT NOCOPY VARCHAR2,
                      x_return_status   OUT NOCOPY VARCHAR2) IS
CURSOR c_temp_table_rslt IS
SELECT a.parent_result_id,
       a.child_result_id,
       b.result_value_char,
	   b.result_value_num,
	   nvl(b.result_value_char,b.result_value_num) result,
	   b.result_date,
	   a.child_replicate,
	   b.lab_organization_id,
	   b.tester,
	   b.tester_id,
	   b.test_id,
	   b.text_code,
	   b.ATTRIBUTE_CATEGORY,
       b.ATTRIBUTE1,
       b.ATTRIBUTE2,
       b.ATTRIBUTE3,
       b.ATTRIBUTE4,
       b.ATTRIBUTE5,
       b.ATTRIBUTE6,
       b.ATTRIBUTE7,
       b.ATTRIBUTE8,
       b.ATTRIBUTE9,
       b.ATTRIBUTE10,
       b.ATTRIBUTE11,
       b.ATTRIBUTE12,
       b.ATTRIBUTE13,
       b.ATTRIBUTE14,
       b.ATTRIBUTE15,
       b.ATTRIBUTE16,
       b.ATTRIBUTE17,
       b.ATTRIBUTE18,
       b.ATTRIBUTE19,
       b.ATTRIBUTE20,
       b.ATTRIBUTE21,
       b.ATTRIBUTE22,
       b.ATTRIBUTE23,
       b.ATTRIBUTE24,
       b.ATTRIBUTE25,
       b.ATTRIBUTE26,
       b.ATTRIBUTE27,
       b.ATTRIBUTE28,
       b.ATTRIBUTE29,
       b.ATTRIBUTE30
FROM   GMD_RESULT_TRANSFER_GT A,
       gmd_results b
WHERE  b.result_id = a.parent_result_id
;

  CURSOR Cur_get_test(p_test_id IN NUMBER) IS
   SELECT  test_code, test_unit,b.qcunit_desc,
           test_class, test_type,
           min_value_num, max_value_num, test_desc,
           exp_error_type, below_spec_min, above_spec_min,
           below_spec_max, above_spec_max,
           below_min_action_code, above_min_action_code,
           below_max_action_code, above_max_action_code,
            priority,
           t.display_precision, t.report_precision,
           t.expression, tm.resources
   FROM   gmd_qc_tests t,gmd_units b, gmd_test_methods_b tm
   WHERE   t.test_id        = p_test_id
           AND t.test_method_id     =  tm.test_method_id
           AND t.test_unit = b.qcunit_code (+) ;

  l_get_test_row         Cur_get_test%ROWTYPE;

--rboddu modified the following cursor to select median_num, median_char bug 3571258
CURSOR c_temp_table_cmpt IS
select a.parent_result_id,
       a.child_result_id,
       r.test_id,
       nvl(to_char(r.mean),r.mode_char) result,
       r.mean,
       r.mode_num,
       r.mode_char,
       r.median_num,
       r.median_char,
       r.low_num,
       r.high_num,
       r.range,
       r.non_validated_result,
       r.standard_deviation,
	   r.text_code,
	   r.ATTRIBUTE_CATEGORY,
       r.ATTRIBUTE1,
       r.ATTRIBUTE2,
       r.ATTRIBUTE3,
       r.ATTRIBUTE4,
       r.ATTRIBUTE5,
       r.ATTRIBUTE6,
       r.ATTRIBUTE7,
       r.ATTRIBUTE8,
       r.ATTRIBUTE9,
       r.ATTRIBUTE10,
       r.ATTRIBUTE11,
       r.ATTRIBUTE12,
       r.ATTRIBUTE13,
       r.ATTRIBUTE14,
       r.ATTRIBUTE15,
       r.ATTRIBUTE16,
       r.ATTRIBUTE17,
       r.ATTRIBUTE18,
       r.ATTRIBUTE19,
       r.ATTRIBUTE20,
       r.ATTRIBUTE21,
       r.ATTRIBUTE22,
       r.ATTRIBUTE23,
       r.ATTRIBUTE24,
       r.ATTRIBUTE25,
       r.ATTRIBUTE26,
       r.ATTRIBUTE27,
       r.ATTRIBUTE28,
       r.ATTRIBUTE29,
       r.ATTRIBUTE30
FROM   gmd_composite_results r,
       GMD_RESULT_TRANSFER_GT A
WHERE  r.composite_result_id = a.parent_result_id;


cursor c_action_code (p_sample_id IN NUMBER) IS
select  retest_action_code
      , resample_action_code
  from  gmd_quality_config
 where  organization_id = (select organization_id
                     from gmd_samples
                     where sample_id =p_sample_id)
 order by orgn_code;
     l_action_code        c_action_code%ROWTYPE;
	 l_sample           gmd_samples%rowtype;
     test_ids           gmd_api_pub.number_tab;
     add_rslt_tab_out   gmd_api_pub.gmd_results_tab;
     add_spec_tab_out   gmd_api_pub.gmd_spec_results_tab;
	 l_inventory_item_id          mtl_system_items_b.inventory_item_id%TYPE;
	 l_lot_number           mtl_lot_numbers.lot_number%TYPE;
	 l_update_instance_id NUMBER;

     l_validate_res       gmd_results_grp.result_data;
	 l_message_data       VARCHAR2(100);

	 l_return_status      VARCHAR2(100);
   --  l_sample_disp            VARCHAR2(3);
	 l_spec_id            NUMBER;
	 l_event_spec_disp_id NUMBER;
	 l_spec_tests_in      GMD_SPEC_TESTS%ROWTYPE;
     l_spec_tests         GMD_SPEC_TESTS%ROWTYPE;
	 l_tests_rec_in       GMD_QC_TESTS%ROWTYPE;
	 l_tests_rec          GMD_QC_TESTS%ROWTYPE;
	 l_test_qty           GMD_RESULTS.TEST_QTY%TYPE;
	 l_test_qty_uom           GMD_RESULTS.TEST_QTY_UOM%TYPE;

	 l_in_spec            VARCHAR2(1);
	 l_place              NUMBER:=0;
	 l_msg                VARCHAR2(150);
	 p_copy_flex          VARCHAR2(1);
	 l_rslt_tbl gmd_results_grp.rslt_tbl;
         l_composite_flag     VARCHAR2(1) := 'N';
         l_sample_active_cnt  NUMBER;


         l_rslt_tbl_expression gmd_results_grp.rslt_tbl;
	 l_return_status_expression VARCHAR2(10);


BEGIN
  x_return_status :=FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.initialize;
  BEGIN
  SELECT spec_id,
         event_spec_disp_id
  INTO   l_spec_id,
         l_event_spec_disp_id
  FROM   gmd_event_spec_disp
  WHERE  sampling_event_id = p_sampling_event_id
  AND    spec_used_for_lot_attrib_ind = 'Y';
  l_place := 1;

  IF (l_debug = 'Y') THEN
   gmd_debug.put_line('The value of spec_id and event_spec_disp_id is '||l_spec_id||' '||l_event_spec_disp_id);
  END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	  FND_MESSAGE.SET_NAME('GMD','GMD_NO_SAMPLING_EVENT');
	  FND_MSG_PUB.ADD;
   END;



  l_place := 5;
  IF (p_transfer_type = 'S') THEN
    l_place := 7;
    --Take update instance id for updating all the result rows.
     select GMD_QC_UPDATE_INST_ID_S.NEXTVAL
     into l_update_instance_id
     from dual;

    l_place := 10;
	-- Make sure flex field can be copied or not
	IF (fnd_flex_apis.IS_DESCR_SETUP(552,'GMD_QC_RESULTS_FLEX')
									 and p_copy_flex_field = 'Y') THEN
       p_copy_flex := 'Y';
    END IF;

	IF (l_debug = 'Y') THEN
      gmd_debug.put_line('Copy flex field flag is '||p_copy_flex);
    END IF;
    FOR temp_table_rslt_row in c_temp_table_rslt LOOP
	   -- Get Test record for results
       l_tests_rec_in.test_id   := temp_table_rslt_row.test_id;
	   l_place := 15;
       IF NOT GMD_QC_TESTS_PVT.fetch_row
                                 ( p_gmd_qc_tests => l_tests_rec_in,
                                   x_gmd_qc_tests => l_tests_rec) THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

	     IF (l_debug = 'Y') THEN
            gmd_debug.put_line('Test_id, Test_code, test_type  To be copied is '||l_tests_rec.test_id||' '||l_tests_rec.test_code||' '||l_tests_rec.test_type);
         END IF;
	  --set up param_list
	  l_place := 20;
      IF (l_spec_id IS NOT NULL) THEN
	     l_spec_tests_in.test_id := temp_table_rslt_row.test_id;
         l_spec_tests_in.spec_id := l_spec_id;

		 l_place := 25;

         IF NOT GMD_SPEC_TESTS_PVT.fetch_row
             ( p_spec_tests => l_spec_tests_in,
               x_spec_tests => l_spec_tests) THEN
         -- Assume that this is an additional test
         -- For this sample.
            l_validate_res.additional_test_ind  := 'Y';
		 END IF;
      END IF;
	  l_place := 30;
	  IF (l_debug = 'Y') THEN
	    gmd_debug.put_line('The value of additional_test_ind, result is '||l_validate_res.additional_test_ind||' '||temp_table_rslt_row.result);
	  END IF;

	  IF (l_validate_res.additional_test_ind IS NULL) THEN

	    l_validate_res.spec_id   := l_spec_tests.spec_id;
            l_validate_res.test_id   := l_tests_rec.test_id;
            l_validate_res.result    := temp_table_rslt_row.result;
            l_validate_res.test_type := l_tests_rec.test_type;
            --l_validate_res.min_num   := l_spec_tests.min_value_num;
            --l_validate_res.max_num   := l_spec_tests.max_value_num;

	    l_validate_res.spec_min_num         := l_spec_tests.min_value_num;
        l_validate_res.spec_max_num         := l_spec_tests.max_value_num;
        l_validate_res.min_num       := l_tests_rec.min_value_num;
        l_validate_res.max_num        := l_tests_rec.max_value_num;
        l_validate_res.spec_target_char     := l_spec_tests.target_value_char;
	    l_validate_res.report_precision  := NVL(NVL(l_spec_tests.report_precision,
                                                l_tests_rec.report_precision),0);
        l_validate_res.display_precision := NVL(NVL(l_spec_tests.display_precision,
	                                              l_tests_rec.display_precision),0);

         l_validate_res.exp_error_type        :=  l_spec_tests.exp_error_type;
         l_validate_res.below_spec_min        :=  l_spec_tests.below_spec_min;
         l_validate_res.above_spec_min        :=  l_spec_tests.above_spec_min;
         l_validate_res.below_spec_max        :=  l_spec_tests.below_spec_max;
         l_validate_res.above_spec_max        :=  l_spec_tests.above_spec_max;
         l_validate_res.below_min_action_code :=  l_spec_tests.below_min_action_code;
         l_validate_res.above_min_action_code :=  l_spec_tests.above_min_action_code;
         l_validate_res.below_max_action_code :=  l_spec_tests.below_max_action_code;
         l_validate_res.above_max_action_code :=  l_spec_tests.above_max_action_code;
         l_validate_res.out_action_code       :=  l_spec_tests.out_of_spec_action;
		 IF (l_debug = 'Y') THEN
		   gmd_debug.put_line('The value of Exp Error Typ, action code is '||l_validate_res.exp_error_type||' '||l_validate_res.out_action_code);
		 END IF;
	   ELSE
	     OPEN cur_get_test(temp_table_rslt_row.test_id);
		 FETCH cur_get_test INTO l_get_test_row;
		 CLOSE cur_get_test;
		l_validate_res.spec_id   := l_spec_tests.spec_id;
        l_validate_res.test_id   := l_tests_rec.test_id;
        l_validate_res.result    := temp_table_rslt_row.result;
        l_validate_res.test_type := l_tests_rec.test_type;
        l_validate_res.min_num   := l_get_test_row.min_value_num;
        l_validate_res.max_num   := l_get_test_row.max_value_num;

	    l_validate_res.report_precision  := NVL(NVL(l_spec_tests.report_precision,
                                                l_tests_rec.report_precision),0);
        l_validate_res.display_precision := NVL(NVL(l_spec_tests.display_precision,
	                                              l_tests_rec.display_precision),0);

         l_validate_res.exp_error_type        :=  l_get_test_row.exp_error_type;
         l_validate_res.below_spec_min        :=  l_get_test_row.below_spec_min;
         l_validate_res.above_spec_min        :=  l_get_test_row.above_spec_min;
         l_validate_res.below_spec_max        :=  l_get_test_row.below_spec_max;
         l_validate_res.above_spec_max        :=  l_get_test_row.above_spec_max;
         l_validate_res.below_min_action_code :=  l_get_test_row.below_min_action_code;
         l_validate_res.above_min_action_code :=  l_get_test_row.above_min_action_code;
         l_validate_res.below_max_action_code :=  l_get_test_row.below_max_action_code;
         l_validate_res.above_max_action_code :=  l_get_test_row.above_max_action_code;
        -- l_validate_res.out_action_code       :=  l_get_test_row.out_of_spec_action;

	   END IF;




	 -- gmd_results_grp.validate_result(l_validate_res,
	 --                                 l_return_status);
      GMD_RESULTS_GRP.validate_result
       ( p_result_rec     => l_validate_res,
         x_return_status  => l_return_status
       );
	   l_place := 35;
	  IF  l_return_status<>'S' THEN
		RAISE FND_API.G_EXC_ERROR;
       END IF;

	   IF (l_debug = 'Y') THEN
	     gmd_debug.put_line('Evaluation Ind           In Spec');
		 gmd_debug.put_line(l_validate_res.evaluation_ind||'                     '||l_validate_res.in_spec);
		 gmd_debug.put_line('p_copy_edit_text, p_copy_flex, p_copy_attachment '||p_copy_edit_text||' '||p_copy_flex||' '||p_copy_attachment);
 		 gmd_debug.put_line('Edit Text Code '||temp_table_rslt_row.text_code);
       END IF;




      UPDATE gmd_results
	  SET    result_value_char = temp_table_rslt_row.result_value_char,
	         result_value_num  = temp_table_rslt_row.result_value_num,
			 update_instance_id = l_update_instance_id,
		 result_date       = temp_table_rslt_row.result_date,
		 lab_organization_id  = temp_table_rslt_row.lab_organization_id,
		 tester_id         = temp_table_rslt_row.tester_id,
		 tester            = temp_table_rslt_row.tester,
		 parent_result_id  = temp_table_rslt_row.parent_result_id,
		 last_update_date  = sysdate,
		 last_updated_by   = fnd_global.USER_ID,
		 text_code         = decode(p_copy_edit_text,'Y',
			                            temp_table_rslt_row.text_code,text_code),
              attribute_category = decode(p_copy_flex,'Y',temp_table_rslt_row.attribute_category, attribute_category),
              attribute1 = decode(p_copy_flex,'Y',temp_table_rslt_row.attribute1, attribute1),
              attribute2 = decode(p_copy_flex,'Y',temp_table_rslt_row.attribute2, attribute2),
              attribute3 = decode(p_copy_flex,'Y',temp_table_rslt_row.attribute3, attribute3),
              attribute4 = decode(p_copy_flex,'Y',temp_table_rslt_row.attribute4, attribute4),
              attribute5 = decode(p_copy_flex,'Y',temp_table_rslt_row.attribute5, attribute5),
              attribute6 = decode(p_copy_flex,'Y',temp_table_rslt_row.attribute6, attribute6),
              attribute7 = decode(p_copy_flex,'Y',temp_table_rslt_row.attribute7, attribute7),
              attribute8 = decode(p_copy_flex,'Y',temp_table_rslt_row.attribute8, attribute8),
              attribute9 = decode(p_copy_flex,'Y',temp_table_rslt_row.attribute9, attribute9),
              attribute10 = decode(p_copy_flex,'Y',temp_table_rslt_row.attribute10, attribute10),
              attribute11 = decode(p_copy_flex,'Y',temp_table_rslt_row.attribute11, attribute11),
              attribute12 = decode(p_copy_flex,'Y',temp_table_rslt_row.attribute12, attribute12),
              attribute13 = decode(p_copy_flex,'Y',temp_table_rslt_row.attribute13, attribute13),
              attribute14 = decode(p_copy_flex,'Y',temp_table_rslt_row.attribute14, attribute14),
              attribute15 = decode(p_copy_flex,'Y',temp_table_rslt_row.attribute15, attribute15),
			  attribute16 = decode(p_copy_flex,'Y',temp_table_rslt_row.attribute16, attribute16),
			  attribute17 = decode(p_copy_flex,'Y',temp_table_rslt_row.attribute17, attribute17),
			  attribute18 = decode(p_copy_flex,'Y',temp_table_rslt_row.attribute18, attribute18),
			  attribute19 = decode(p_copy_flex,'Y',temp_table_rslt_row.attribute19, attribute19),
			  attribute20 = decode(p_copy_flex,'Y',temp_table_rslt_row.attribute20, attribute20),
			  attribute21 = decode(p_copy_flex,'Y',temp_table_rslt_row.attribute21, attribute21),
			  attribute22 = decode(p_copy_flex,'Y',temp_table_rslt_row.attribute22, attribute22),
			  attribute23 = decode(p_copy_flex,'Y',temp_table_rslt_row.attribute23, attribute23),
			  attribute24 = decode(p_copy_flex,'Y',temp_table_rslt_row.attribute24, attribute24),
			  attribute25 = decode(p_copy_flex,'Y',temp_table_rslt_row.attribute25, attribute25),
			  attribute26 = decode(p_copy_flex,'Y',temp_table_rslt_row.attribute26, attribute26),
			  attribute27 = decode(p_copy_flex,'Y',temp_table_rslt_row.attribute27, attribute27),
			  attribute28 = decode(p_copy_flex,'Y',temp_table_rslt_row.attribute28, attribute28),
			  attribute29 = decode(p_copy_flex,'Y',temp_table_rslt_row.attribute29, attribute29),
			  attribute30 = decode(p_copy_flex,'Y',temp_table_rslt_row.attribute30, attribute30)
       WHERE result_id         = temp_table_rslt_row.child_result_id;


        --B3356274 Now atleast one result is updated, so need to mark the composite result as invalid...
        l_composite_flag := 'Y';

        IF (l_validate_res.test_type = 'E') THEN
          gmd_results_grp.calc_expression
	  ( p_sample_id           => p_sample_id
	  , p_event_spec_disp_id  => l_event_spec_disp_id
	  , p_spec_id             => l_spec_tests.spec_id
	  , x_rslt_tbl            => l_rslt_tbl
	  , x_return_status       => l_return_status);

	   IF  l_return_status<>'S' THEN
		 RAISE FND_API.G_EXC_ERROR;
       END IF;
	 END IF;


       IF (p_copy_attachment = 'Y') THEN
	     fnd_attached_documents2_pkg.copy_attachments(X_from_entity_name => 'GMD_RESULTS',
                                                          X_from_pk1_value   => temp_table_rslt_row.parent_result_id,
							  X_to_entity_name   => 'GMD_RESULTS',
							  x_to_pk1_value =>     temp_table_rslt_row.child_result_id);
       END IF;



      IF NOT GMD_SPEC_RESULTS_PVT.lock_row
         ( p_event_spec_disp_id => l_event_spec_disp_id,
           p_result_id          => temp_table_rslt_row.child_result_id
         ) THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

        UPDATE GMD_SPEC_RESULTS
        SET  IN_SPEC_IND  = l_validate_res.in_spec,
        evaluation_ind    = l_validate_res.evaluation_ind,
		action_code       = l_validate_res.result_action_code,
        last_update_date  = SYSDATE,
        last_updated_by   = fnd_global.user_id
       WHERE event_spec_disp_id = l_event_spec_disp_id
       AND   result_id          = temp_table_rslt_row.child_result_id;

	   --Now if the evaluation is reject make sure that you add a test
	   -- or resample depending on action code.
	   IF (l_validate_res.result_action_code IS NOT NULL) THEN
	      IF (l_debug = 'Y') THEN
            gmd_debug.put_line('Result Action code for the child result row is '||l_validate_res.result_action_code);
          END IF;
	     OPEN c_action_code(p_sample_id);
		 FETCH c_action_code into l_action_code.retest_action_code,
		                          l_action_code.resample_action_code;
		 CLOSE c_action_code;
		 IF (l_validate_res.result_action_code = l_action_code.retest_action_code) THEN
		   -- Write code for inserting the test row.
		   NULL;
		   l_sample.sample_id :=  p_sample_id;
           test_ids(1)        :=  temp_table_rslt_row.test_id;
           select test_qty,test_qty_uom
		   into   l_test_qty, l_test_qty_uom
		   from   gmd_results
		   where  result_id = temp_table_rslt_row.child_result_id;

            gmd_results_grp.add_tests_to_sample
                 (p_sample             => l_sample
                 ,p_test_ids           => test_ids
                 ,p_event_spec_disp_id => l_event_spec_disp_id
                 ,x_results_tab        => add_rslt_tab_out
                 ,x_spec_results_tab   => add_spec_tab_out
                 ,x_return_status      => l_return_status
                 ,p_test_qty           => l_test_qty
                 ,p_test_qty_uom           => l_test_qty_uom
              ) ;




            IF  l_return_status <> 'S' THEN
              RAISE FND_API.G_EXC_ERROR;
            ELSE
               gmd_api_pub.RAISE2(
               P_event_name      =>'oracle.apps.gmd.qm.performtest',
               P_event_key       =>p_sample_id,
               P_Parameter_name1 =>'TEST_ID',
               P_Parameter_value1=> temp_table_rslt_row.test_id
              );
            END IF;
		 ELSIF (l_validate_res.result_action_code = l_action_code.resample_action_code) THEN
			-- notification for taking the sample.
		   SELECT inventory_item_id, lot_number
		   INTO   l_inventory_item_id, l_lot_number
		   FROM   gmd_samples
		   WHERE  sample_id = p_sample_id;
		   gmd_api_pub.raise (P_EVENT_NAME => 'oracle.apps.gmi.lotretestdate.update',
                              P_EVENT_KEY  => to_char(l_inventory_item_id)
                               ||'-'|| l_lot_number);
	     END IF;

	    END IF; -- End if the result action code is not null;
	 END LOOP;

	-- Bug 3892771
	-- Need to calculate expressions
	      gmd_results_grp.calc_expression
		   ( p_sample_id           => p_sample_id
		   , p_event_spec_disp_id  => l_event_spec_disp_id
		   , p_spec_id             => l_spec_tests.spec_id
		   , x_rslt_tbl            => l_rslt_tbl_expression
		   , x_return_status       => l_return_status_expression);

	      IF (l_return_status_expression <>'S') THEN
        	         RAISE FND_API.G_EXC_ERROR;
	      END IF ;
        -- Bug 3892771


      --B3356274, start invalidate composite result on result association
      IF (l_composite_flag = 'Y') THEN
        BEGIN
           SELECT sample_active_cnt
           INTO   l_sample_active_cnt
           FROM   gmd_sampling_events gse
           WHERE  gse.sampling_event_id=p_sampling_event_id;
        EXCEPTION
        WHEN OTHERS THEN
         --This should never happen
          NULL;
       END;
     END IF;

    IF (nvl(l_sample_active_cnt, 0) > 1) THEN
       GMD_RESULTS_GRP.se_recomposite_required (  p_sampling_event_id  => p_sampling_event_id
                                , p_event_spec_disp_id => l_event_spec_disp_id
                                , x_return_status      => l_return_status
                               );
       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;


      --B3356274, end invalidate composite result on result association
     GMD_RESULTS_GRP.change_sample_disposition
       ( p_sample_id      => p_sample_id,
         x_change_disp_to => x_sample_disp,
         x_return_status  => l_return_status,
	 x_message_data   => l_message_data
      );
  ELSE
    -- Make sure flex field can be copied or not
	IF (fnd_flex_apis.IS_DESCR_SETUP(552,'GMD_QC_COMPOSITE_RESULTS_FLEX')
									 and p_copy_flex_field = 'Y') THEN
       p_copy_flex := 'Y';
    END IF;
	FOR   c_temp_table_cmpt_row  IN    c_temp_table_cmpt LOOP
	  l_place := 50;
	  l_in_spec := gmd_results_grp.rslt_is_in_spec(l_spec_id,
	                                               c_temp_table_cmpt_row.test_id,
						       to_char(c_temp_table_cmpt_row.mean),
						       c_temp_table_cmpt_row.mode_char);
      l_place := 55;

      --rboddu Modified the following update statement to update gmd_composite_results with  median_num, median_char selected from c_temp_table_cmpt. bug 3571258
       UPDATE gmd_composite_results
	   SET    in_spec_ind = l_in_spec,
	          mean= c_temp_table_cmpt_row.mean ,
                  mode_num= c_temp_table_cmpt_row.mode_num,
                  mode_char = c_temp_table_cmpt_row.mode_char,
                  median_char = c_temp_table_cmpt_row.median_char,
                  median_num = c_temp_table_cmpt_row.median_num,
                  low_num= c_temp_table_cmpt_row.low_num,
                  high_num= c_temp_table_cmpt_row.high_num,
                  range= c_temp_table_cmpt_row.range,
                  non_validated_result = c_temp_table_cmpt_row.non_validated_result,
                  standard_deviation = c_temp_table_cmpt_row.standard_deviation,
                  last_update_date   = SYSDATE,
		  last_updated_by    = fnd_global.USER_ID,
		  text_code          = decode(p_copy_edit_text,'Y',
		                             c_temp_table_cmpt_row.text_code,text_code),
                  parent_composite_result_id   = c_temp_table_cmpt_row.parent_result_id,
                  attribute_category = decode(p_copy_flex,'Y',c_temp_table_cmpt_row.attribute_category, attribute_category),
                  attribute1 = decode(p_copy_flex,'Y',c_temp_table_cmpt_row.attribute1, attribute1),
                  attribute2 = decode(p_copy_flex,'Y',c_temp_table_cmpt_row.attribute2, attribute2),
                  attribute3 = decode(p_copy_flex,'Y',c_temp_table_cmpt_row.attribute3, attribute3),
                  attribute4 = decode(p_copy_flex,'Y',c_temp_table_cmpt_row.attribute4, attribute4),
                  attribute5 = decode(p_copy_flex,'Y',c_temp_table_cmpt_row.attribute5, attribute5),
                  attribute6 = decode(p_copy_flex,'Y',c_temp_table_cmpt_row.attribute6, attribute6),
                  attribute7 = decode(p_copy_flex,'Y',c_temp_table_cmpt_row.attribute7, attribute7),
                  attribute8 = decode(p_copy_flex,'Y',c_temp_table_cmpt_row.attribute8, attribute8),
                  attribute9 = decode(p_copy_flex,'Y',c_temp_table_cmpt_row.attribute9, attribute9),
                  attribute10 = decode(p_copy_flex,'Y',c_temp_table_cmpt_row.attribute10, attribute10),
                  attribute11 = decode(p_copy_flex,'Y',c_temp_table_cmpt_row.attribute11, attribute11),
                  attribute12 = decode(p_copy_flex,'Y',c_temp_table_cmpt_row.attribute12, attribute12),
                  attribute13 = decode(p_copy_flex,'Y',c_temp_table_cmpt_row.attribute13, attribute13),
                  attribute14 = decode(p_copy_flex,'Y',c_temp_table_cmpt_row.attribute14, attribute14),
                  attribute15 = decode(p_copy_flex,'Y',c_temp_table_cmpt_row.attribute15, attribute15),
	      attribute16 = decode(p_copy_flex,'Y',c_temp_table_cmpt_row.attribute16, attribute16),
	      attribute17 = decode(p_copy_flex,'Y',c_temp_table_cmpt_row.attribute17, attribute17),
              attribute18 = decode(p_copy_flex,'Y',c_temp_table_cmpt_row.attribute18, attribute18),
			  attribute19 = decode(p_copy_flex,'Y',c_temp_table_cmpt_row.attribute19, attribute19),
			  attribute20 = decode(p_copy_flex,'Y',c_temp_table_cmpt_row.attribute20, attribute20),
			  attribute21 = decode(p_copy_flex,'Y',c_temp_table_cmpt_row.attribute21, attribute21),
			  attribute22 = decode(p_copy_flex,'Y',c_temp_table_cmpt_row.attribute22, attribute22),
			  attribute23 = decode(p_copy_flex,'Y',c_temp_table_cmpt_row.attribute23, attribute23),
			  attribute24 = decode(p_copy_flex,'Y',c_temp_table_cmpt_row.attribute24, attribute24),
			  attribute25 = decode(p_copy_flex,'Y',c_temp_table_cmpt_row.attribute25, attribute25),
			  attribute26 = decode(p_copy_flex,'Y',c_temp_table_cmpt_row.attribute26, attribute26),
			  attribute27 = decode(p_copy_flex,'Y',c_temp_table_cmpt_row.attribute27, attribute27),
			  attribute28 = decode(p_copy_flex,'Y',c_temp_table_cmpt_row.attribute28, attribute28),
			  attribute29 = decode(p_copy_flex,'Y',c_temp_table_cmpt_row.attribute29, attribute29),
			  attribute30 = decode(p_copy_flex,'Y',c_temp_table_cmpt_row.attribute30, attribute30)
        WHERE  composite_result_id = c_temp_table_cmpt_row.child_result_id;

	  IF (p_copy_attachment = 'Y') THEN
	     fnd_attached_documents2_pkg.copy_attachments(X_from_entity_name => 'GMD_COMPOSITE_RESULTS',
                                                          X_from_pk1_value   => c_temp_table_cmpt_row.parent_result_id,
							  X_to_entity_name   => 'GMD_COMPOSITE_RESULTS',
	        					  x_to_pk1_value =>     c_temp_table_cmpt_row.child_result_id);
          END IF;

	END LOOP;
  END IF;
  FND_MSG_PUB.Count_AND_GET
        (p_count => x_message_count, p_data  => x_message_data);


  COMMIT;
  EXCEPTION

   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    log_msg('GMD_QC_RESULT_TRANSFER_GRP.DO_TRANSFER AT '||l_place||' '|| SUBSTR(SQLERRM,1,100));
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_message_count, p_data  => x_message_data);
END do_transfer;

PROCEDURE log_msg(p_msg_text IN VARCHAR2) IS
BEGIN
    FND_MESSAGE.SET_NAME('GMI','GMI_DEBUG_API');
    FND_MESSAGE.SET_TOKEN('MSG',p_msg_text);
    FND_MSG_PUB.Add;
END log_msg ;

  PROCEDURE  copy_previous_composite_result(p_composite_spec_disp_id IN NUMBER,
                                             x_message_count   OUT NOCOPY NUMBER,
                                             x_message_data    OUT NOCOPY VARCHAR2,
                                             x_return_status   OUT NOCOPY VARCHAR2) IS
  cursor c_previous_row IS
  SELECT  a.event_spec_disp_id,r.in_spec_ind,r.parent_composite_result_id,
       r.composite_result_id,
       r.composite_spec_disp_id,
       r.test_id,
       nvl(to_char(r.mean),r.mode_char) result,
       r.mean,
       r.mode_num,
       r.mode_char,
       r.low_num,
       r.high_num,
       r.range,
       r.non_validated_result,
       r.standard_deviation,
	   r.text_code,
	   r.ATTRIBUTE_CATEGORY,
       r.ATTRIBUTE1,
       r.ATTRIBUTE2,
       r.ATTRIBUTE3,
       r.ATTRIBUTE4,
       r.ATTRIBUTE5,
       r.ATTRIBUTE6,
       r.ATTRIBUTE7,
       r.ATTRIBUTE8,
       r.ATTRIBUTE9,
       r.ATTRIBUTE10,
       r.ATTRIBUTE11,
       r.ATTRIBUTE12,
       r.ATTRIBUTE13,
       r.ATTRIBUTE14,
       r.ATTRIBUTE15,
       r.ATTRIBUTE16,
       r.ATTRIBUTE17,
       r.ATTRIBUTE18,
       r.ATTRIBUTE19,
       r.ATTRIBUTE20,
       r.ATTRIBUTE21,
       r.ATTRIBUTE22,
       r.ATTRIBUTE23,
       r.ATTRIBUTE24,
       r.ATTRIBUTE25,
       r.ATTRIBUTE26,
       r.ATTRIBUTE27,
       r.ATTRIBUTE28,
       r.ATTRIBUTE29,
       r.ATTRIBUTE30
FROM   gmd_composite_results r,
       gmd_composite_spec_disp a   --Bug 3017743, added to get event spec disp id.
WHERE  r.composite_spec_disp_id = p_composite_spec_disp_id
AND    r.composite_spec_disp_id = a.composite_spec_disp_id
AND    r.parent_composite_result_id IS NOT NULL
;




CURSOR c_curr_compo_rec(p_event_spec_disp_id IN NUMBER,
                        p_test_id            IN NUMBER) IS
SELECT composite_result_id
FROM   gmd_composite_results a, gmd_composite_spec_disp b
WHERE  a.composite_spec_disp_id = b.composite_spec_disp_id
AND    b.latest_ind = 'Y'
AND    b.event_spec_disp_id = p_event_spec_disp_id
AND    a.test_id            = p_test_id
AND   (( a.mode_char IS NULL) OR (a.mean IS NULL));
--AND   a.parent_composite_result_id IS NOT NULL; --Bug 3349433, for current composite result, this value will be null

l_place  NUMBER;

BEGIN
  x_return_status :=FND_API.G_RET_STS_SUCCESS;
 FOR l_previous_row IN c_previous_row LOOP
    l_place := 20;
    gmd_debug.put_line('The value of event_spec_disp_id is '||l_previous_row.event_spec_disp_id);
    gmd_debug.put_line('The value of test_id is '||l_previous_row.test_id);
    FOR l_curr_compo_rec IN c_curr_compo_rec(l_previous_row.event_spec_disp_id,
                                             l_previous_row.test_id) LOOP
          gmd_debug.put_line('The value of composite_result_id is '||l_curr_compo_rec.composite_result_id);
           UPDATE gmd_composite_results
	   SET    in_spec_ind = l_previous_row.in_spec_ind,
	          mean= l_previous_row.mean ,
              mode_num= l_previous_row.mode_num,
              mode_char = l_previous_row.mode_char,
              low_num= l_previous_row.low_num,
              high_num= l_previous_row.high_num,
              range= l_previous_row.range,
              non_validated_result = l_previous_row.non_validated_result,
              standard_deviation = l_previous_row.standard_deviation,
			  last_update_date   = SYSDATE,
			  last_updated_by    = fnd_global.USER_ID,
			  text_code          =l_previous_row.text_code,
              parent_composite_result_id   = l_previous_row.parent_composite_result_id,
              attribute_category = l_previous_row.attribute_category,
              attribute1 = l_previous_row.attribute1,
              attribute2 = l_previous_row.attribute2,
              attribute3 = l_previous_row.attribute3,
              attribute4 = l_previous_row.attribute4,
              attribute5 = l_previous_row.attribute5,
              attribute6 = l_previous_row.attribute6,
              attribute7 = l_previous_row.attribute7,
              attribute8 = l_previous_row.attribute8,
              attribute9 = l_previous_row.attribute9,
              attribute10 = l_previous_row.attribute10,
              attribute11 = l_previous_row.attribute11,
              attribute12 = l_previous_row.attribute12,
              attribute13 = l_previous_row.attribute13,
              attribute14 = l_previous_row.attribute14,
              attribute15 = l_previous_row.attribute15,
              attribute16 = l_previous_row.attribute16,
              attribute17 = l_previous_row.attribute17,
              attribute18 = l_previous_row.attribute18,
       	      attribute19 = l_previous_row.attribute19,
	      attribute20 = l_previous_row.attribute20,
	      attribute21 = l_previous_row.attribute21,
	      attribute22 = l_previous_row.attribute22,
			  attribute23 = l_previous_row.attribute23,
			  attribute24 = l_previous_row.attribute24,
			  attribute25 = l_previous_row.attribute25,
			  attribute26 = l_previous_row.attribute26,
			  attribute27 = l_previous_row.attribute27,
			  attribute28 = l_previous_row.attribute28,
			  attribute29 = l_previous_row.attribute29,
			  attribute30 = l_previous_row.attribute30
        WHERE  composite_result_id = l_curr_compo_rec.composite_result_id;


	END LOOP;
 END LOOP;
  EXCEPTION

   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    log_msg('GMD_QC_RESULT_TRANSFER_GRP.DO_TRANSFER AT '||l_place||' '|| SUBSTR(SQLERRM,1,100));
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_message_count, p_data  => x_message_data);

END  copy_previous_composite_result;

 PROCEDURE  delete_single_composite(p_composite_spec_disp_id NUMBER,
                                    x_message_count   OUT NOCOPY NUMBER,
	                            x_message_data    OUT NOCOPY VARCHAR2,
                                    x_return_status          OUT NOCOPY VARCHAR2) IS
  l_place  NUMBER;
 BEGIN
     x_return_status :=FND_API.G_RET_STS_SUCCESS;
   -- There can never be any issue with locking as exiting the form should always delete single
   -- composites.
    l_place := 10;
    delete gmd_composite_result_assoc
    where  composite_result_id IN
	                             (select composite_result_id
				      from   gmd_composite_results
				      where  composite_spec_disp_id = p_composite_spec_disp_id);
    IF (l_debug = 'Y') THEN
      gmd_debug.put_line('Deleting<'||SQL%ROWCOUNT||'>gmd_composite_result_assoc for single sample sample group for composite_spec_disp_id <'||p_composite_spec_disp_id||'>');
    END IF;
    l_place := 20;
    delete gmd_composite_results
    where  composite_spec_disp_id = p_composite_spec_disp_id;

    IF (l_debug = 'Y') THEN
      gmd_debug.put_line('Deleting<'||SQL%ROWCOUNT||'>gmd_composite_results for single sample sample group for composite_spec_disp_id <'||p_composite_spec_disp_id||'>');
    END IF;

	l_place := 30;
	delete gmd_composite_spec_disp
	where composite_spec_disp_id = p_composite_spec_disp_id;
    IF (l_debug = 'Y') THEN
      gmd_debug.put_line('Deleting<'||SQL%ROWCOUNT||'>gmd_composite_spec_disp for single sample sample group for composite_spec_disp_id <'||p_composite_spec_disp_id||'>');
    END IF;
   --Bug 3334382, single sample group transaction not gettting deleted
   COMMIT;
   --end bug 3334382
  EXCEPTION

   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    log_msg('GMD_RESULT_TRANSFER_GRP.delete_single_composite AT '||l_place||' '|| SUBSTR(SQLERRM,1,100));
    FND_MSG_PUB.Count_AND_GET
      (p_count => x_message_count, p_data  => x_message_data);
 END delete_single_composite;


END gmd_result_transfer_grp;

/
