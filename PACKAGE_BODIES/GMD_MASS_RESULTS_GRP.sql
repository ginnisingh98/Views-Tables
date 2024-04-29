--------------------------------------------------------
--  DDL for Package Body GMD_MASS_RESULTS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_MASS_RESULTS_GRP" AS
--$Header: GMDGMRSB.pls 120.2 2006/01/19 02:53:29 rlnagara noship $

  l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDGMRSB.pls                                        |
--| Package Name       : GMD_MASS_RESULTS_GRP                                |
--| Type               : Group                                               |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains group layer APIs for Mass Results Entity        |
--|                                                                          |
--| HISTORY                                                                  |
--|    Chetan Nagar	17-Jul-2003	Created.                             |
--|                                                                          |
--+==========================================================================+
-- End of comments

-- Global variables
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'GMD_MASS_RESULTS_GRP';


--Start of comments
--+========================================================================+
--| API Name    : populate_results                                         |
--| TYPE        : Group                                                    |
--| Notes       : This procedure receives as input parameters, a seq_id.   |
--|               It extracts all the results and related data for the     |
--|               sample_ids associated with the SEQ_ID passed and populates
--|               the table - GMD_MASS_RESULTS_GT.                         |
--|                                                                        |
--|               This erything is fine then OUT parameter                 |
--|               x_return_status is set to 'S' else appropriate           |
--|               error message is put on the stack and error              |
--|               is returned.                                             |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	17-Jul-2003	Created.                           |
--|                                                                        |
--|    Chetan Nagar	08-Jan-2004	B3358725 Do not include archive and|
--|                                     reserve sample for mass results.   |
--|    RLNAGARA         22-Sep-2005     Added Parent_lot_number            |
--|      				Modified test_uom to test_qty_uom  |
--|    RLNAGARA         17-Jan-2006     Bug # 4913637 Split the INSERT statement into 2  |
--|					INSERT statements so as to reduce  |
--|					the Shared Memry Size.		   |
--+========================================================================+
-- End of comments


PROCEDURE  populate_results
( p_seq_id        IN         VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
) IS

  -- Cursors
  -- Local Variables
  -- Exceptions

BEGIN

  IF (l_debug = 'Y') THEN
    gmd_debug.put_line('Entering procedure POPULATE_RESULTS');
    gmd_debug.put_line('  Input Parameters:');
    gmd_debug.put_line('  p_seq_id : ' || p_seq_id);
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- First clear the TEMP table.
  DELETE FROM gmd_mass_results_gt;

  -- Now populate fresh

INSERT INTO gmd_mass_results_gt
  (
    -- Sampling Event Info
    SAMPLING_EVENT_ID
  , SAMPLE_ACTIVE_CNT

    -- Sample Info
  , SAMPLE_ID
  , SAMPLE_NO
  , SAMPLE_DESC
  , INVENTORY_ITEM_ID
  , LOCATOR_ID
  , LOT_NUMBER
  , PARENT_LOT_NUMBER
  , SOURCE
  , SUBINVENTORY
  , ORGANIZATION_ID
  , SOURCE_SUBINVENTORY
  , SOURCE_LOCATOR_ID
  , RESOURCES
  , SAMPLE_TYPE

  -- Result Info
  , UPDATE_INSTANCE_ID
  , RESULT_ID
  , TEST_ID
  , TEST_METHOD_ID
  , TEST_REPLICATE_CNT
  , TEST_QTY
  , TEST_QTY_UOM
  , LAB_ORGANIZATION_ID
  , RESULT_VALUE_NUM
  , RESULT_DATE
  , TESTER_ID
  , SEQ
  , RESULT_VALUE_CHAR
  , LAST_UPDATE_DATE

  -- Spec Result Info
  , EVALUATION_IND
  , ACTION_CODE
  , IN_SPEC_IND
  , ADDITIONAL_TEST_IND
  , VALUE_IN_REPORT_PRECISION

  -- Event Info
  , EVENT_SPEC_DISP_ID
  , SPEC_ID
  , SPEC_VR_ID

  -- Spec Test Info
  , MIN_VALUE_NUM
  , TARGET_VALUE_NUM
  , MAX_VALUE_NUM
  , MIN_VALUE_CHAR
  , TARGET_VALUE_CHAR
  , MAX_VALUE_CHAR
  , TEST_REPLICATE
  , OUT_OF_SPEC_ACTION
  , EXP_ERROR_TYPE
  , BELOW_SPEC_MIN
  , ABOVE_SPEC_MIN
  , BELOW_SPEC_MAX
  , ABOVE_SPEC_MAX
  , BELOW_MIN_ACTION_CODE
  , ABOVE_MIN_ACTION_CODE
  , BELOW_MAX_ACTION_CODE
  , ABOVE_MAX_ACTION_CODE
  , OPTIONAL_IND
  , DISPLAY_PRECISION
  , REPORT_PRECISION

  -- Test Info
  , TEST_CODE
  , TEST_DESC
  , TEST_CLASS
  , TEST_TYPE
  , TEST_UNIT
  , TEST_MIN_VALUE_NUM
  , TEST_MAX_VALUE_NUM
  , EXPRESSION

  -- Test Method Info
  , TEST_METHOD_CODE
  , TEST_METHOD_DESC

  -- Control Columns
  , TEST_SELECTED
  , UPDATE_ALLOWED
  , RECORD_UPDATED
  )
  SELECT
         -- Sampling Event Info
         se.sampling_event_id,
         se.sample_active_cnt,

         --sampleinfo
         s.sample_id,
         s.sample_no,
         s.sample_desc,
         s.inventory_item_id,
         s.locator_id,
         s.lot_number,
         s.parent_lot_number,
         s.source,
         s.subinventory,
         s.organization_id,
         s.source_subinventory,
         s.source_locator_id,
         s.resources,
         s.sample_type,

         --resultinfo
         r.update_instance_id,
         r.result_id,
         r.test_id,
         r.test_method_id,
         r.test_replicate_cnt,
         r.test_qty,
         r.test_qty_uom,
         r.lab_organization_id,
         r.result_value_num,
         r.result_date,
         nvl(r.tester_id, fnd_global.user_id),
         r.seq,
         r.result_value_char,
         r.last_update_date,

         --spec result tinfo
         sr.evaluation_ind,
         sr.action_code,
         sr.in_spec_ind,
         sr.additional_test_ind,
         sr.value_in_report_precision,

         --event info
         esd.event_spec_disp_id,
         esd.spec_id,
         esd.spec_vr_id,

         --spec test info
         st.min_value_num,
         st.target_value_num,
         st.max_value_num,
         st.min_value_char,
         st.target_value_char,
         st.max_value_char,
         st.test_replicate,
         st.out_of_spec_action,
         st.exp_error_type,
         st.below_spec_min,
         st.above_spec_min,
         st.below_spec_max,
         st.above_spec_max,
         st.below_min_action_code,
         st.above_min_action_code,
         st.below_max_action_code,
         st.above_max_action_code,
         st.optional_ind,
         st.display_precision,
         st.report_precision,

         --testinfo
         t.test_code,
         t.test_desc,
         t.test_class,
         t.test_type,
         t.test_unit,
         t.min_value_num test_min_value_num,
         t.max_value_num test_max_value_num,
         t.expression,

         -- Test Methid Info
         tm.test_method_code,
         tm.test_method_desc,

         -- Control Columns
         0 TEST_SELECTED,
         1 UPDATE_ALLOWED,
         0 RECORD_UPDATED
  FROM   gmd_mass_samples ms,
         gmd_results r,
         gmd_spec_results sr,
         gmd_samples s,
         gmd_sample_spec_disp ssd,
         gmd_sampling_events se,
         gmd_event_spec_disp esd,
         gmd_spec_tests_b st,
         gmd_qc_tests t,
         gmd_test_methods tm
  WHERE  ms.seq_id = p_seq_id
  and    ms.sample_id = s.sample_id

  -- standard joins
  and    se.sampling_event_id = s.sampling_event_id
  and    s.sample_id = r.sample_id
  and    se.sampling_event_id = esd.sampling_event_id
  and    esd.spec_used_for_lot_attrib_ind = 'Y'
  and    esd.event_spec_disp_id = ssd.event_spec_disp_id
  and    ssd.sample_id = s.sample_id
  and    esd.event_spec_disp_id = sr.event_spec_disp_id
  and    sr.result_id = r.result_id
  and    sr.additional_test_ind IS NULL
  and    st.spec_id = esd.spec_id
  and    st.test_id = r.test_id
  and    st.exclude_ind is null
  and    t.test_id = r.test_id
  and    r.test_method_id = tm.test_method_id
  and    r.delete_mark = 0
  and    sr.delete_mark = 0
  and    s.delete_mark = 0
  and    ssd.delete_mark = 0
  and    esd.delete_mark = 0
  -- system built filter criteria
  and    nvl(ssd.disposition, 'xx') in ('1P', '2I', '3C')
  and    nvl(sr.evaluation_ind, 'xx') not in ('4C', '5O')
  and    nvl(s.retain_as, 'X') not in ('A', 'R') ; -- B3358725

--RLNAGARA Bug # 4913637

INSERT INTO gmd_mass_results_gt
  (
    -- Sampling Event Info
    SAMPLING_EVENT_ID
  , SAMPLE_ACTIVE_CNT

    -- Sample Info
  , SAMPLE_ID
  , SAMPLE_NO
  , SAMPLE_DESC
  , INVENTORY_ITEM_ID
  , LOCATOR_ID
  , LOT_NUMBER
  , PARENT_LOT_NUMBER
  , SOURCE
  , SUBINVENTORY
  , ORGANIZATION_ID
  , SOURCE_SUBINVENTORY
  , SOURCE_LOCATOR_ID
  , RESOURCES
  , SAMPLE_TYPE

  -- Result Info
  , UPDATE_INSTANCE_ID
  , RESULT_ID
  , TEST_ID
  , TEST_METHOD_ID
  , TEST_REPLICATE_CNT
  , TEST_QTY
  , TEST_QTY_UOM
  , LAB_ORGANIZATION_ID
  , RESULT_VALUE_NUM
  , RESULT_DATE
  , TESTER_ID
  , SEQ
  , RESULT_VALUE_CHAR
  , LAST_UPDATE_DATE

  -- Spec Result Info
  , EVALUATION_IND
  , ACTION_CODE
  , IN_SPEC_IND
  , ADDITIONAL_TEST_IND
  , VALUE_IN_REPORT_PRECISION

  -- Event Info
  , EVENT_SPEC_DISP_ID
  , SPEC_ID
  , SPEC_VR_ID

  -- Spec Test Info
  , MIN_VALUE_NUM
  , TARGET_VALUE_NUM
  , MAX_VALUE_NUM
  , MIN_VALUE_CHAR
  , TARGET_VALUE_CHAR
  , MAX_VALUE_CHAR
  , TEST_REPLICATE
  , OUT_OF_SPEC_ACTION
  , EXP_ERROR_TYPE
  , BELOW_SPEC_MIN
  , ABOVE_SPEC_MIN
  , BELOW_SPEC_MAX
  , ABOVE_SPEC_MAX
  , BELOW_MIN_ACTION_CODE
  , ABOVE_MIN_ACTION_CODE
  , BELOW_MAX_ACTION_CODE
  , ABOVE_MAX_ACTION_CODE
  , OPTIONAL_IND
  , DISPLAY_PRECISION
  , REPORT_PRECISION

  -- Test Info
  , TEST_CODE
  , TEST_DESC
  , TEST_CLASS
  , TEST_TYPE
  , TEST_UNIT
  , TEST_MIN_VALUE_NUM
  , TEST_MAX_VALUE_NUM
  , EXPRESSION

  -- Test Method Info
  , TEST_METHOD_CODE
  , TEST_METHOD_DESC

  -- Control Columns
  , TEST_SELECTED
  , UPDATE_ALLOWED
  , RECORD_UPDATED
  )
  SELECT
         -- Sampling Event Info
         se.sampling_event_id,
         se.sample_active_cnt,

         --sampleinfo
         s.sample_id,
         s.sample_no,
         s.sample_desc,
         s.inventory_item_id,
         s.locator_id,
         s.lot_number,
         s.parent_lot_number,
         s.source,
         s.subinventory,
         s.organization_id,
         s.source_subinventory,
         s.source_locator_id,
         s.resources,
         s.sample_type,

         --resultinfo
         r.update_instance_id,
         r.result_id,
         r.test_id,
         r.test_method_id,
         r.test_replicate_cnt,
         r.test_qty,
         r.test_qty_uom,
         r.lab_organization_id,
         r.result_value_num,
         r.result_date,
         nvl(r.tester_id, fnd_global.user_id),
         r.seq,
         r.result_value_char,
         r.last_update_date,

         --spec result tinfo
         sr.evaluation_ind,
         sr.action_code,
         sr.in_spec_ind,
         sr.additional_test_ind,
         sr.value_in_report_precision,

         --event info
         esd.event_spec_disp_id,
         esd.spec_id,
         esd.spec_vr_id,

         --spec test info SINCE THIS IS additional_test READ FROM TEST TABLE
         t.min_value_num,
         to_number(NULL) target_value_num,
         t.max_value_num,
         NULL min_value_char,
         NULL target_value_char,
         NULL max_value_char,
         1, -- Need to read from Test method
         NULL out_of_spec_action,
         t.exp_error_type,
         t.below_spec_min,
         t.above_spec_min,
         t.below_spec_max,
         t.above_spec_max,
         t.below_min_action_code,
         t.above_min_action_code,
         t.below_max_action_code,
         t.above_max_action_code,
         NULL optional_ind,
         t.display_precision,
         t.report_precision,

         --testinfo
         t.test_code,
         t.test_desc,
         t.test_class,
         t.test_type,
         t.test_unit,
         t.min_value_num test_min_value_num,
         t.max_value_num test_max_value_num,
         t.expression,

         -- Test Methid Info
         tm.test_method_code,
         tm.test_method_desc,

         -- Control Columns
         0 TEST_SELECTED,
         1 UPDATE_ALLOWED,
         0 RECORD_UPDATED
  FROM   gmd_mass_samples ms,
         gmd_results r,
         gmd_spec_results sr,
         gmd_samples s,
         gmd_sample_spec_disp ssd,
         gmd_sampling_events se,
         gmd_event_spec_disp esd,
         gmd_qc_tests t,
         gmd_test_methods tm
  WHERE  ms.seq_id = p_seq_id
  and    ms.sample_id = s.sample_id

  -- standard joins
  and    se.sampling_event_id = s.sampling_event_id
  and    s.sample_id = r.sample_id
  and    se.sampling_event_id = esd.sampling_event_id
  and    esd.spec_used_for_lot_attrib_ind = 'Y'
  and    esd.event_spec_disp_id = ssd.event_spec_disp_id
  and    ssd.sample_id = s.sample_id
  and    esd.event_spec_disp_id = sr.event_spec_disp_id
  and    sr.result_id = r.result_id
  and    sr.additional_test_ind = 'Y'
  and    t.test_id = r.test_id
  and    r.test_method_id = tm.test_method_id
  and    r.delete_mark = 0
  and    sr.delete_mark = 0
  and    s.delete_mark = 0
  and    ssd.delete_mark = 0
  and    esd.delete_mark = 0
  -- system built filter criteria
  and    nvl(ssd.disposition, 'xx') in ('1P', '2I', '3C')
  and    nvl(sr.evaluation_ind, 'xx') not in ('4C', '5O')
  and    nvl(s.retain_as, 'X') not in ('A', 'R');  -- B3358725



  IF (l_debug = 'Y') THEN
    gmd_debug.put_line('  No. of rows inserted into GMD_MASS_RESULTS_GT : ' || SQL%ROWCOUNT);
  END IF;

  UPDATE gmd_mass_results_gt
  SET    update_allowed = 0
  WHERE  (result_date IS NOT NULL OR test_type = 'E')
  ;

  IF (l_debug = 'Y') THEN
    gmd_debug.put_line('  No. of rows with Result or Expression Test : ' || SQL%ROWCOUNT);
  END IF;

  IF (l_debug = 'Y') THEN
    GMD_MASS_RESULTS_GRP.dump_data_points;
    gmd_debug.put_line('Leaving procedure POPULATE_RESULTS');
  END IF;


  -- All systems GO...

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR',
                            'PACKAGE','POPULATE_RESULTS',
                            'ERROR', SUBSTR(SQLERRM,1,100));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END populate_results;



PROCEDURE dump_data_points
( p_sample_id IN NUMBER := NULL
, p_result_id IN NUMBER := NULL
, p_test_id   IN NUMBER := NULL
) IS

  CURSOR c1 IS
  SELECT *
  FROM   gmd_mass_results_gt
  WHERE  sample_id = nvl(p_sample_id, sample_id)
  AND    result_id = nvl(p_result_id, result_id)
  AND    test_id   = nvl(test_id, p_test_id)
  ORDER BY sample_id, result_id;

BEGIN
  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('');
     gmd_debug.put_line('Data in session table - gmd_mass_results_gt');
     gmd_debug.put_line(' Sample ID  Result ID    Test ID        Data Num       Data Char UA RU');
     gmd_debug.put_line('---------- ---------- ---------- --------------- --------------- -- --');
  END IF;

  FOR c_rec IN c1
  LOOP
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line(lpad(c_rec.sample_id, 10, ' ')||' '||
                          lpad(c_rec.result_id, 10, ' ')||' '||
                          lpad(c_rec.test_id, 10, ' ')||' '||
                          lpad(nvl(c_rec.result_value_num, 0), 15, ' ')||' '||
                          lpad(nvl(c_rec.result_value_char, 'NULL'), 15, ' ')|| ' ' ||
                          lpad(c_rec.update_allowed, 2, ' ') || ' ' ||
                          lpad(c_rec.record_updated, 2, ' ')
                         );
    END IF;
  END LOOP;


END dump_data_points;

END gmd_mass_results_grp;

/
