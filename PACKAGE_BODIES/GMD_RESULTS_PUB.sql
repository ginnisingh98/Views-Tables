--------------------------------------------------------
--  DDL for Package Body GMD_RESULTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_RESULTS_PUB" AS
/*  $Header: GMDPRESB.pls 120.4.12010000.3 2008/11/17 17:27:31 plowe ship $
 *****************************************************************
 *                                                               *
 * Package  GMD_RESULTS_PUB                                      *
 *                                                               *
 * Contents RECORD_RESULTS                                       *
 *          ADD_TESTS_TO_SAMPLE                                  *
 *          DELETE_RESULTS                                       *
 *                                                               *
 * Use      This is the public layer for the QC RESULTS          *
 *                                                               *
 * History                                                       *
 *         Written by H Verdding, OPM Development (EMEA)         *
 *                                                               *
 * magupta B2752102: Added the parameters for validation of      *
 *                   resource for passing it to results group API*
 * HVerddin B2711643: Added call to set user_context             *
 * odaboval  2709353: Added call to create composite results     *
 * P.Raghu   3467531: Commented the check for Disposition in     *
 *                    Record_Results procedure.                  *
 * magupta   3492836: Reserve Sample Id Validation               *
 *                                                               *
 * Sulipta Tripathy Bug # 3848483 Added new fields in update     *
 *                  statement. TESTER_ID in GMD_RESULTS          *
 * 			  VALUE_IN_REPORT_PRECISION in GMD_SPEC_RESULTS*
 * 			  Modified cond. to update GMD_SPEC_RESULTS    *
 *                  even if eval_ind is NULL.                    *
 *  B.Stone  9-Sep-2004  Bug 3763419; Added Guaranteed by        *
 *                       Manufacturer evaluation with the same   *
 *                       business rules asApproved with Variance;*
 *                       Result value not allowed with this      *
 *                       evaluation.                             *
 * RLNAGARA 16-Mar-2006 Bug 5076736
 *  Modified the procedure Record_results so that it calculates  *
 *  the results of tests which are of expression type.           *
 *  M. Grosser 20-Apr-2006:  Bug 5141976 :  FP of bug 5123379    *
 *             If  the result value is NULL for an expression,   *
 *             set the result date and tester id to NULL.        *
 *  M. Grosser 20-Apr-2006:  Bug 5141976 :  FP of bug 5123379    *
 *  P Lowe     03-OCT-2008   Bug 7420373 allow update of numeric *
 *             test if one has already been recorded just as in  *
 *             form.                                             *
 *             Because API needs to reflect what is in the form, *
 *             results cannot be updated if the disposition is   *
 *             changed to one of these below                     *
 *            ('0RT', '4A', '5AV', '6RJ', '7CN')                 *
 *  P Lowe     12-NOV-2008   Bug 7524393                         *
 *																															 *
 *																															 *
 *****************************************************************
*/

--   Global variables

G_PKG_NAME           CONSTANT  VARCHAR2(30):='GMD_RESULTS_PUB';

PROCEDURE RECORD_RESULTS
( p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2
, p_commit               IN  VARCHAR2
, p_validation_level     IN  NUMBER
, p_results_rec          IN  GMD_RESULTS_PUB.RESULTS_REC
, p_user_name            IN  VARCHAR2
, x_results_rec          OUT NOCOPY GMD_RESULTS%ROWTYPE
, x_spec_results_rec     OUT NOCOPY GMD_SPEC_RESULTS%ROWTYPE
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
, p_user_responsibility_id IN NUMBER DEFAULT NULL /*NSRIVAST, INVCONV*/
)
IS
  l_api_name              CONSTANT VARCHAR2 (30) := 'RECORD_RESULTS';
  l_api_version           CONSTANT NUMBER        := 3.0;
  l_msg_count             NUMBER  :=0;
  l_msg_data              VARCHAR2(2000);
  l_return_status         VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
  l_results_rec           GMD_RESULTS_PUB.RESULTS_REC;
  l_tests_rec             GMD_QC_TESTS%ROWTYPE;
  l_samples_rec           GMD_SAMPLES%ROWTYPE;
  l_spec_results_row_in   GMD_SPEC_RESULTS%ROWTYPE;
  l_spec_results_row      GMD_SPEC_RESULTS%ROWTYPE;
  l_spec_tests_in         GMD_SPEC_TESTS%ROWTYPE;
  l_spec_tests            GMD_SPEC_TESTS%ROWTYPE;
  l_results_row_in        GMD_RESULTS%ROWTYPE;
  l_results_row           GMD_RESULTS%ROWTYPE;
  l_user_id               NUMBER(15);
  l_assign_type           NUMBER;
  l_date                  DATE := SYSDATE;
  l_result_id             NUMBER;
  l_test_type             VARCHAR2(1);
  l_result_value_char     VARCHAR2(80) := NULL;
  l_result_value_num      NUMBER       := NULL;
  l_in_spec               VARCHAR2(1)  := NULL;
  l_event_spec_disp_id    NUMBER;
  l_samples_req           NUMBER;
  l_samples_act           NUMBER;
  l_spec_id               NUMBER;
  l_sample_disp           VARCHAR2(3);
  l_sample_event_disp     VARCHAR2(3);
  l_validate_res          GMD_RESULTS_GRP.result_data;
  --Bug 3492836
  l_reserve_sampling_event_id  NUMBER;
  --Bug 3492836

  l_rslt_tbl 		  gmd_results_grp.rslt_tbl; --RLNAGARA BUG#5076736

CURSOR c_get_event_spec (p_sampling_event_id NUMBER, p_sample_id NUMBER)
IS
SELECT e.event_spec_disp_id, s.disposition , e.spec_id,
       se.sample_req_cnt, se.sample_active_cnt
FROM   gmd_event_spec_disp e , gmd_sample_spec_disp s , gmd_sampling_events se
WHERE  s.event_spec_disp_id = e.event_spec_disp_id
AND    se.sampling_event_id = e.sampling_event_id
AND    se.sampling_event_id = p_sampling_event_id
AND    s.sample_id = p_sample_id
AND    e.spec_used_for_lot_attrib_ind = 'Y'
AND    e.delete_mark = 0
AND    s.delete_mark = 0;

CURSOR c_get_result_num ( p_result_char VARCHAR, p_test_id NUMBER)
IS
SELECT text_range_seq
FROM   GMD_QC_TEST_VALUES_B
WHERE  test_id = p_test_id
AND    value_char = p_result_char;


-- bug 2709353, odaboval added the cursor in order to get the S.E. disposition
CURSOR c_sample_event ( p_event_spec_disp NUMBER)
IS
SELECT disposition
FROM   GMD_EVENT_SPEC_DISP
WHERE  event_spec_disp_id = p_event_spec_disp
AND    delete_mark = 0;

/*NSRIVAST, INVCONV*/

CURSOR cur_get_appl_id IS
SELECT application_id
FROM   fnd_application
WHERE  application_short_name = 'GMD';

CURSOR check_resp_lab_access(cp_lab_organization_id NUMBER,cp_application_id NUMBER) IS
SELECT 1
FROM gmd_parameters_hdr gmd, org_access_view org
WHERE org.organization_id   = gmd.organization_id
AND org.organization_id     = cp_lab_organization_id
AND org.responsibility_id   = p_user_responsibility_id
AND org.resp_application_id = cp_application_id
AND gmd.lab_ind             = 1
AND  org.inventory_enabled_flag = 'Y'  ;

l_application_id NUMBER;
/*NSRIVAST, INVCONV*/

BEGIN


  -- Standard Start OF API savepoint

  SAVEPOINT RECORD_RESULTS;


  /*  Standard call to get for call compatibility.  */

  IF NOT FND_API.Compatible_API_CALL
    (l_api_version , p_api_version , l_api_name , G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /* Initialize message list if p_int_msg_list is set TRUE.   */
  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  --   Initialize API return Parameters

  x_return_status  := FND_API.G_RET_STS_SUCCESS;

  -- Validate User Name Parameter

  GMA_GLOBAL_GRP.Get_Who ( p_user_name => p_user_name
                          ,x_user_id   => l_user_id);

  IF NVL(l_user_id, -1) < 0
    THEN
    GMD_API_PUB.Log_Message('GMD_INVALID_USER_NAME',
                            'l_user_name', p_user_name);

    RAISE FND_API.G_EXC_ERROR;
  ELSE
    -- Added below for BUG 2711643. Hverddin
    GMD_API_PUB.SET_USER_CONTEXT(p_user_id       => l_user_id,
                                 x_return_status => l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;

/*NSRIVAST, INVCONV*/

  OPEN  cur_get_appl_id;
  FETCH cur_get_appl_id INTO l_application_id;
  CLOSE cur_get_appl_id;

  OPEN check_resp_lab_access(l_results_row.organization_id,l_application_id);
  IF check_resp_lab_access%NOTFOUND THEN
      GMD_API_PUB.Log_Message('GMD_RESP_LAB_NOACCESS');
      CLOSE check_resp_lab_access;
      RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE check_resp_lab_access;
/*NSRIVAST, INVCONV*/

  VALIDATE_INPUT
  ( p_results_rec          => p_results_rec,
    x_return_status        => l_return_status
  );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;


  IF p_results_rec.result_id IS NULL THEN

     GET_RESULT_INFO
     ( p_results_rec          => p_results_rec,
       x_tests_rec            => l_tests_rec,
       x_samples_rec          => l_samples_rec,
       x_return_status        => l_return_status
     );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Fetch the Result Record
     l_results_row_in.test_id             := l_tests_rec.test_id;
     l_results_row_in.sample_id           := l_samples_rec.sample_id;
     l_results_row_in.test_replicate_cnt  := p_results_rec.test_replicate_cnt;

     IF NOT GMD_RESULTS_PVT.fetch_row
        ( p_results  => l_results_row_in,
          x_results  => l_results_row
        ) THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;

  ELSE
     -- Fetch Result Row
     l_results_row_in.result_id            := p_results_rec.result_id;

     IF NOT GMD_RESULTS_PVT.fetch_row
        ( p_results  => l_results_row_in,
          x_results  => l_results_row
        ) THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Get Result Info
     l_results_rec.test_id              := l_results_row.test_id;
     l_results_rec.sample_id            := l_results_row.sample_id;
     l_results_rec.test_replicate_cnt   := l_results_row.test_replicate_cnt;

     GET_RESULT_INFO
     ( p_results_rec          => l_results_rec,
       x_tests_rec            => l_tests_rec,
       x_samples_rec          => l_samples_rec,
       x_return_status        => l_return_status
     );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;

  END IF;


  -- Validate that Result Record is Not deleted
  IF l_results_row.delete_mark = 1 THEN
      GMD_API_PUB.Log_Message('GMD_RESULT_DELETED');
      RAISE FND_API.G_EXC_ERROR;
  END IF;

   -- If values have been  populated for this result then
   -- Return an ERROR.


-- Bug 7420373  --  allow update of numeric
--    test if one has already been recorded just as in  the form
/*   IF l_results_row.result_value_num IS NOT NULL OR
      l_results_row.result_value_char IS NOT NULL THEN
      -- Result values have been recorded for this Result
      GMD_API_PUB.Log_Message('GMD_RESULT_RECORDED',   -- pal
                  'l_ORGN_CODE', l_samples_rec.orgn_code,
                  'l_SAMPLE_NO', l_samples_rec.sample_no,
                  'l_TEST',      l_tests_rec.test_code);
      RAISE FND_API.G_EXC_ERROR;
   END IF;
*/

  -- Validate that the values in the RESULT REC i.e RESULT_CHAR and NUM
   -- Are populated for the correct test_type
   -- Bug 3763419; Added condition to only check for test_type if not
   --              Guaranteed by Manufacturer (1X) evaluation.

  -- RLNAGARA 16-Jan-2006 Added the OR condition
   IF p_results_rec.eval_ind <> '1Z' OR p_results_rec.eval_ind IS NULL THEN

   IF l_tests_rec.test_type = 'E' THEN

    --RLNAGARA Begin BUG#5076736 Calling gmd_results_grp.calc_expression

      OPEN c_get_event_spec(l_samples_rec.sampling_event_id,
                            l_samples_rec.sample_id);
      FETCH c_get_event_spec INTO l_event_spec_disp_id, l_sample_disp, l_spec_id,
                                  l_samples_req, l_samples_act;
      IF c_get_event_spec%NOTFOUND THEN
         GMD_API_PUB.Log_Message('GMD_NO_SPEC_EVENT_FOUND',
                                 'SPEC_ID', l_spec_id,
                                 'SAMP_EVENT', l_samples_rec.sampling_event_id);
         RAISE FND_API.G_EXC_ERROR;
         CLOSE c_get_event_spec;
      END IF;
      CLOSE c_get_event_spec;

      gmd_results_grp.calc_expression
   	  ( p_sample_id           => l_samples_rec.sample_id --:gmdqsmpl.sample_id
   	  , p_event_spec_disp_id  => l_event_spec_disp_id --:gmdqsmpl.event_spec_disp_id
   	  , p_spec_id             => l_spec_id --:gmdqsmpl.spec_id
   	  , x_rslt_tbl            => l_rslt_tbl
   	  , x_return_status       => l_return_status);

      IF (l_return_Status <> 'S') THEN
       GMD_API_PUB.Log_Message('GMD_EXP_RES_DISALLOWED');
       RAISE FND_API.G_EXC_ERROR;
      END IF;
  --RLNAGARA Bug5076736 end


   ELSIF l_tests_rec.test_type in ('N','L') THEN

     -- Check that the result_value is Numeric
     IF NOT GMD_RESULTS_GRP.is_value_numeric
       ( p_char_number => p_results_rec.result_value) THEN
         GMD_API_PUB.Log_Message('GMD_RESULT_VAL_NUM_REQD');
         RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- l_result_value_num  := p_results_rec.result_value;
     l_validate_res.result  := p_results_rec.result_value;

   ELSIF l_tests_rec.test_type in ( 'T','V','U') THEN

     IF p_results_rec.result_value is NULL THEN
       GMD_API_PUB.Log_Message('GMD_RESULT_VAL_CHAR_REQD');
       RAISE FND_API.G_EXC_ERROR;
     END IF;

     l_validate_res.result      := p_results_rec.result_value;
     l_result_value_char        := p_results_rec.result_value;
   END IF;
   END IF;

   --=======================================================
   -- Get event spec disp Value, and the sample dispostion
   --=======================================================

   OPEN c_get_event_spec(l_samples_rec.sampling_event_id,
                         l_samples_rec.sample_id);
   FETCH c_get_event_spec INTO l_event_spec_disp_id, l_sample_disp, l_spec_id,
                               l_samples_req, l_samples_act;
   IF c_get_event_spec%NOTFOUND THEN
      GMD_API_PUB.Log_Message('GMD_NO_SPEC_EVENT_FOUND',
                              'SPEC_ID', l_spec_id,
                              'SAMP_EVENT', l_samples_rec.sampling_event_id);
      RAISE FND_API.G_EXC_ERROR;
      CLOSE c_get_event_spec;
   END IF;
   CLOSE c_get_event_spec;



-- part of bug 7420373  as api needs to reflect what is in the form

-- Results cannot be updated if the disposition is changed to one of these below
      IF l_sample_disp  in ('0RT', '4A', '5AV', '6RJ', '7CN')
      THEN
       GMD_API_PUB.Log_Message('GMD_SAMPLE_DISP_INVALID',
                              'l_SAMPLE_DISP', l_sample_disp);
      RAISE FND_API.G_EXC_ERROR;
   END IF;


   --Begin Bug#3467531, port bug 3494551 P.Raghu
   --Commented the following code. No need to check the sample disposition.
   /*
   --== SHOULD THIS BE THE SAMPLE OR SAMPLE EVENT DISP
   IF l_sample_disp NOT IN ('1P','2I') THEN
      GMD_API_PUB.Log_Message('GMD_SAMPLE_DISP_INVALID',
                              'l_SAMPLE_DISP', l_sample_disp);
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   */
   --End Bug#3467531, port bug 3494551


   -- IF specification record exists for this sample then
   -- Get specification test details

   IF l_spec_id IS NOT NULL THEN

     l_spec_tests_in.test_id := l_tests_rec.test_id;
     l_spec_tests_in.spec_id := l_spec_id;

      IF NOT GMD_SPEC_TESTS_PVT.fetch_row
         ( p_spec_tests => l_spec_tests_in,
           x_spec_tests => l_spec_tests
         ) THEN
           -- Assume that this is an additional test
           -- For this sample.
           l_validate_res.additional_test_ind  := 'Y';
      END IF;
   END IF;



   --=================================
   -- We need to populate Validate_res
   -- record type.
   --=================================

   l_validate_res.spec_id   := l_spec_tests.spec_id;
   l_validate_res.test_id   := l_tests_rec.test_id;
   l_validate_res.test_type := l_tests_rec.test_type;
   l_validate_res.min_num   := l_tests_rec.min_value_num;
   l_validate_res.max_num   := l_tests_rec.max_value_num;
   l_validate_res.report_precision  := NVL(NVL(l_spec_tests.report_precision,
                                           l_tests_rec.report_precision),0);
   l_validate_res.display_precision := NVL(NVL(l_spec_tests.display_precision,
                                           l_tests_rec.display_precision),0);

   l_validate_res.lab_organization_id := l_results_row.lab_organization_id;  /*NSRIVAST, INVCONV*/
   l_validate_res.planned_resource := NVL(p_results_rec.planned_resource,
                                         l_results_row.planned_resource);
   l_validate_res.planned_resource_instance := NVL(p_results_rec.planned_resource_instance,
                                                   l_results_row.planned_resource_instance);
   l_validate_res.actual_resource := NVL(p_results_rec.actual_resource,
                                         l_results_row.actual_resource);
   l_validate_res.actual_resource_instance := NVL(p_results_rec.actual_resource_instance,
                                                 l_results_row.actual_resource_instance);


   --=================================
   -- Now Validate result record values
   --=================================

   GMD_RESULTS_GRP.validate_result
   ( p_result_rec     => l_validate_res,
     x_return_status  => l_return_status
   );

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;


   IF NOT GMD_RESULTS_PVT.LOCK_ROW ( p_result_id => l_results_row.result_id )
     THEN
     RAISE FND_API.G_EXC_ERROR;
   ELSE
      -- IF test_type is T then convert result char to Num
      IF ( l_tests_rec.test_type = 'T') THEN

         OPEN c_get_result_num ( p_results_rec.result_value,
                                 l_tests_rec.test_id);
         FETCH c_get_result_num INTO l_validate_res.result_num;
         IF c_get_result_num%NOTFOUND THEN
            CLOSE c_get_result_num;
            GMD_API_PUB.Log_Message('GMD_RESULT_CHAR_NOTFOUND');
            RAISE FND_API.G_EXC_ERROR;
         END IF;
         CLOSE c_get_result_num;
      END IF;


  --==================================================
  -- Bug 3492836 Start Validate Reserve Sample
  --==================================================
  --dbms_output.put_line('Sampling even id is '||l_samples_rec.sampling_event_id);
  IF (p_results_rec.reserve_sample_id IS NOT NULL) THEN
     BEGIN
       SELECT sampling_event_id
       INTO   l_reserve_sampling_event_id
       FROM   gmd_samples
       WHERE  sample_id = p_results_rec.reserve_sample_id;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         GMD_API_PUB.Log_Message('GMD_INVALID_RESERVE_SMPL');
         RAISE FND_API.G_EXC_ERROR;
     END;

     IF (l_samples_rec.sampling_event_id <> l_reserve_sampling_event_id) THEN
        GMD_API_PUB.Log_Message('GMD_INVALID_RESERVE_SMPL');
        RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;
  --==================================================
  -- End Bug 3492836 Validate Reserve Sample
  --==================================================

      --=================================
      -- Quantity MANAGEMENT
      --=================================
     -- Bug 3468300: if test qty exists on the result record, there must be a consumed qty on the result.
     --              If consumed qty is not input to API, then take the test qty.
     --              and corrected the value taken from the remaining qty
     -- l_results_row.test_qty := p_results_rec.test_qty;
     IF (( p_results_rec.consumed_qty IS NULL )
      AND (l_results_row.test_qty IS NOT NULL ))   THEN
        -- consumed qty becomes test qty if not specified
        l_results_row.consumed_qty := l_results_row.test_qty;
     ELSIF ( p_results_rec.consumed_qty IS NOT NULL ) THEN
        -- if consumed_qty exists it is taken from remaining qty
        l_results_row.consumed_qty := p_results_rec.consumed_qty;
     END IF;

     IF (NVL(l_results_row.consumed_qty, 0) < 0) THEN
        GMD_API_PUB.Log_Message('GMD_QM_NEGATIVE_QTY');
        RAISE FND_API.G_EXC_ERROR;
     --END IF;  Bug 3468300: added else statement
     ELSIF (( NVL(l_results_row.consumed_qty, 0) <> 0 )
         AND (NVL(l_results_row.test_uom, '0') = '0' )) THEN
        -- If test uom does not exist in result and consumed qty is specified, test uom must be in input file
        IF ( NVL(p_results_rec.test_qty_uom, '0') <> '0' ) THEN     /*NSRIVAST, INVCONV*/
           l_results_row.test_uom := p_results_rec.test_qty_uom;   /*NSRIVAST, INVCONV*/
        END IF;

        IF ( NVL(l_results_row.test_uom, '0') = '0' ) THEN
           GMD_API_PUB.Log_Message('GMD_QM_TEST_UOM');
           RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF;

      --=================================
      -- Update Results Record
      --=================================

       IF l_tests_rec.test_type = 'E' THEN --RLNAGARA BUG#5076736
        select result_value_num into l_validate_res.result_num from gmd_results WHERE  result_id = l_results_row.result_id;
        select in_spec_ind into l_result_value_char from gmd_spec_results WHERE  result_id = l_results_row.result_id;
       END IF;

      -- Bug 3468300: added consumed qty, test uom and reserve sample id
      UPDATE  GMD_RESULTS
      SET   result_date         = NVL(p_results_rec.result_date,l_date), -- 3559127 (use of p_results_rec rather than l_results_rec)
      last_update_date          = l_date,
      last_updated_by           = l_user_id,
      result_value_num          = l_validate_res.result_num,
      result_value_char         = l_result_value_char,
      planned_resource          = l_results_rec.planned_resource,
      planned_resource_instance = l_results_rec.planned_resource_instance,
      actual_resource           = l_results_rec.actual_resource,
      actual_resource_instance  = l_results_rec.actual_resource_instance,
      planned_result_date       = l_results_rec.planned_result_date,
          -- test_qty           = l_results_row.test_qty,  -- bug 3468300: test qty does not change in this API
      test_uom                  = l_results_row.test_uom,
      consumed_qty              = l_results_row.consumed_qty,
      test_by_date              = l_results_rec.test_by_date,
      tester_id                 = NVL(p_results_rec.tester_id,l_user_id),   /* Bug # 3848483 Added this line */
      reserve_sample_id         = p_results_rec.reserve_sample_id
      WHERE result_id           = l_results_row.result_id;

      l_results_row_in.result_id := l_results_row.result_id;


      --  M. Grosser 20-Apr-2006:  Bug 5141976 :  FP of bug 5123379
      --             If  the result value is NULL for an expression,
      --             set the result date and tester id to NULL.
      --
      IF l_tests_rec.test_type = 'E' THEN
       	UPDATE gmd_results
           SET result_date = NULL ,
       	       tester_id = NULL
      	 WHERE result_id = l_results_row.result_id
      	   AND result_value_num IS NULL;
      END IF;
      --  M. Grosser 20-Apr-2006:  Bug 5141976 : End of changes


      IF NOT GMD_RESULTS_PVT.FETCH_ROW( p_results => l_results_row_in,
                                        x_results => l_results_row ) THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

  END IF;


      --=================================
      -- Update Remaining Qty on Sample Record
      --=================================
     IF ( NVL(p_results_rec.reserve_sample_id, 0) <> 0 ) THEN
        -- Bug 3468300: added API/FORM field and test uom to update remaining qty call
	-- B3600012 ST: RECORD RESULTS API ISSUES AMBIGUOUS ERROR
        gmd_samples_grp.update_remaining_qty
                            (l_results_row.result_id,  -- B3600012 changed from l_results_rec
                             p_results_rec.reserve_sample_id ,
                             l_results_row.consumed_qty ,
                             l_return_status
                             );
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

     ELSE
        gmd_samples_grp.update_remaining_qty
                            (l_results_row.result_id,  -- B3600012 changed from l_results_rec
                             l_results_row.sample_id ,
                             l_results_row.consumed_qty ,
                             l_return_status
                             );
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF;


  --=================================
  -- Now Validate the Evaluation_ind
  -- If user has specified a value
  --=================================

  IF p_results_rec.eval_ind IS NOT NULL THEN

     GMD_RESULTS_GRP.validate_evaluation_ind
     ( p_evaluation_ind  => p_results_rec.eval_ind,
       p_in_spec_ind     => l_validate_res.in_spec,
       p_result_value    => p_results_rec.result_value,
       x_return_status   => l_return_status
     );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;

  END IF;


  --=================================
  -- Now Update the Spec Results
  -- Only if there is a Valid Evaluation
  --=================================
  /* Bug # 3848483 Update the spec results even if eval_ind is NULL - Commenting the condition */
  -- IF NVL(l_validate_res.evaluation_ind, p_results_rec.eval_ind) is NOT NULL THEN


      IF NOT GMD_SPEC_RESULTS_PVT.lock_row
         ( p_event_spec_disp_id => l_event_spec_disp_id,
           p_result_id          => l_results_row.result_id
         ) THEN
         RAISE FND_API.G_EXC_ERROR;

      END IF;

    IF l_tests_rec.test_type <> 'E' THEN  --RLNAGARA BUG#5076736
      UPDATE GMD_SPEC_RESULTS
      SET  IN_SPEC_IND  = l_validate_res.in_spec,
      evaluation_ind    = NVL(l_validate_res.evaluation_ind,p_results_rec.eval_ind), /* Bug # 3848483 Swapped args. l_validate_res takes precedence */
      action_code       = NVL(p_results_rec.action_code,
                              l_validate_res.result_action_code),
      last_update_date  = l_date,
      last_updated_by   = l_user_id,
      --value_in_report_precision = ROUND(p_results_rec.result_value,l_validate_res.report_precision)/* Bug # 3848483 Added this line */
      	value_in_report_precision =     -- replaced above line with this -- bug 7524393
				   DECODE(l_tests_rec.test_type, 'T', NULL, 'V', NULL, 'U', NULL,
			  	 ROUND(p_results_rec.result_value,l_validate_res.report_precision))
      WHERE event_spec_disp_id = l_event_spec_disp_id
      AND   result_id          = l_results_row.result_id;
    END IF;

      -- Populate OUT parameter.

      l_spec_results_row_in.event_spec_disp_id := l_event_spec_disp_id;
      l_spec_results_row_in.result_id          := l_results_row.result_id;

      IF NOT GMD_SPEC_RESULTS_PVT.fetch_row
         ( p_spec_results => l_spec_results_row_in,
         x_spec_results => l_spec_results_row
         ) THEN

         RAISE FND_API.G_EXC_ERROR;

      END IF;

 -- END IF; /*Bug # 3848483 Commented if eval_ind is NULL */


  --=================================
  -- Now Attempt to Update the
  -- Sample/ Samp Event Dispositions
  --=================================

  GMD_RESULTS_GRP.change_sample_disposition
  ( p_sample_id      => l_samples_rec.sample_id,
    x_change_disp_to => l_sample_disp,
    x_return_status  => l_return_status,
    x_message_data   => x_msg_data
  );

  IF l_return_status <> 'S' THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;


  --=================================
  -- Now determine if we can change
  -- the Dispostion to ''4A','5AV', '6RJ'
  -- And in turn set the Lot Status
  --=================================

  IF l_spec_id IS NOT NULL AND l_sample_disp = '3C' THEN

    -- There was only 1 sample Req for this Sampling Event
    -- SHOULD THIS BE = 1 OR AS LONG AS THEY EQUAL EACH OTHER !!!!!!!
    IF l_samples_req = 1 and l_samples_act = 1 THEN

       GMD_RESULTS_GRP.change_disp_for_auto_lot
       ( p_sample_id      => l_samples_rec.sample_id,
         x_change_disp_to => l_sample_disp,
         x_return_status  => l_return_status
       );

       IF l_return_status <> 'S' THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

    END IF;
  END IF;

  --==================================================
  -- Now determine if we can create a composite result
  -- There is no need to create a composite result if samples_act count <= 1
  --==================================================
  OPEN c_sample_event ( l_event_spec_disp_id);
  FETCH c_sample_event
   INTO l_sample_event_disp;

  IF (c_sample_event%NOTFOUND)
  THEN
     CLOSE c_sample_event;
     GMD_API_PUB.Log_Message('GMD_NO_SPEC_EVENT_FOUND',
                             'EVENT_SPEC_DISP_ID', l_event_spec_disp_id);
     RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c_sample_event;

  -- dbms_output.put_line('spec_id='||l_spec_id||', sample_event_disp='||l_sample_event_disp||', samples_act='||l_samples_act);
  IF (l_spec_id IS NOT NULL
       AND l_sample_event_disp = '3C'
       AND l_samples_act > 1)
  THEN
       -- bug 2709353, 9-Apr-2003, odaboval, Create a composite result :
       -- At this stage, the Sampling Event is completed and
       --  its sample_cnt > = required_cnt
       --  Therefore, the composite result is only created when more than 1 sample.

       GMD_RESULTS_GRP.composite_and_change_lot(
                         p_sampling_event_id  => l_samples_rec.sampling_event_id
                       , p_commit             => p_commit
                       , x_return_status      => l_return_status);

       IF l_return_status <> 'S' THEN
           RAISE FND_API.G_EXC_ERROR;
       END IF;
  END IF;



  -- Standard Check of p_commit.
  IF FND_API.to_boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

  -- Set return Parameters

  x_return_status        := l_return_status;
  x_results_rec          := l_results_row;
  x_spec_results_rec     := l_spec_results_row;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO RECORD_RESULTS;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO RECORD_RESULTS;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );



    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO RECORD_RESULTS;
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

END RECORD_RESULTS;

PROCEDURE ADD_TESTS_TO_SAMPLE
(
  p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2
, p_commit               IN  VARCHAR2
, p_validation_level     IN  NUMBER
, p_user_name            IN  VARCHAR2
, p_sample_rec           IN  GMD_SAMPLES%ROWTYPE
, p_test_id_tab          IN  GMD_API_PUB.number_tab
, p_event_spec_disp_id   IN  NUMBER
, x_results_tab          OUT NOCOPY GMD_API_PUB.gmd_results_tab
, x_spec_results_tab     OUT NOCOPY GMD_API_PUB.gmd_spec_results_tab
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY  NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
)
IS
  l_api_name              CONSTANT VARCHAR2 (30) := 'ADD_TESTS_TO_SAMPLE';
  l_api_version           CONSTANT NUMBER        := 2.0;
  l_msg_count             NUMBER  :=0;
  l_msg_data              VARCHAR2(2000);
  l_return_status         VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
  l_results_tab           GMD_API_PUB.gmd_results_tab;
  l_spec_results_tab      GMD_API_PUB.gmd_spec_results_tab;
  l_spec_results_row      GMD_SPEC_RESULTS%ROWTYPE;
  l_user_id               NUMBER(15);
  l_date                  DATE := SYSDATE;
  l_event_spec_disp_id    NUMBER;
  l_event_spec_exists     NUMBER;

CURSOR c_check_event_spec ( p_event_spec_disp NUMBER)
IS
SELECT 1
FROM   GMD_EVENT_SPEC_DISP
WHERE  EVENT_SPEC_DISP_ID = p_event_spec_disp
AND    DELETE_MARK = 0;


BEGIN


  -- Standard Start OF API savepoint

  SAVEPOINT  ADD_TESTS_TO_SAMPLE;


  /*  Standard call to get for call compatibility.  */

  IF NOT FND_API.Compatible_API_CALL
    (l_api_version , p_api_version , l_api_name , G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /* Initialize message list if p_int_msg_list is set TRUE.   */
  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  --   Initialize API return Parameters

  x_return_status    := FND_API.G_RET_STS_SUCCESS;
  l_results_tab      := x_results_tab;
  l_spec_results_tab := x_spec_results_tab;

  -- Validate User Name Parameter


  GMA_GLOBAL_GRP.Get_Who ( p_user_name => p_user_name
                          ,x_user_id   => l_user_id);

  IF NVL(l_user_id, -1) < 0
    THEN
    GMD_API_PUB.Log_Message('GMD_INVALID_USER_NAME',
                            'l_user_name', p_user_name);

    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Validate  Input Parematers

  -- Validate Sample Record


  IF ( p_sample_rec.sample_id is NULL) THEN
     -- Validate that composite keys are present

     IF ( p_sample_rec.sample_no is NULL) THEN
        GMD_API_PUB.Log_Message('GMD_SAMPLE_NUMBER_REQD');
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF ( p_sample_rec.orgn_code is NULL) THEN
         GMD_API_PUB.Log_Message('GMD_SAMPLE_ORGN_CODE_REQD');
         RAISE FND_API.G_EXC_ERROR;
      END IF;

  END IF; -- Key Sample values Present


  -- Validate that test id's are present

  IF ( p_test_id_tab.COUNT < 1 ) THEN
      GMD_API_PUB.Log_Message('GMD_TEST_ID_TABLE_EMPTY');
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Validate event spec  disp id is present and valid

  IF ( p_event_spec_disp_id is NULL) THEN
      GMD_API_PUB.Log_Message('GMD_EVENT_SPEC_DISP_NULL');
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Validate that the event_spec_disp_id is Valid

  OPEN c_check_event_spec(p_event_spec_disp_id);
    FETCH c_check_event_spec INTO l_event_spec_exists;
    IF c_check_event_spec%NOTFOUND THEN
      GMD_API_PUB.Log_Message('GMD_EVENT_SPEC_NOTFOUND',
                               'event_disp', p_event_spec_disp_id);
      RAISE FND_API.G_EXC_ERROR;
      CLOSE c_check_event_spec;
    END IF;
  CLOSE c_check_event_spec;


  -- Now Start Business Processing

  --  Call Grp Layer API to Process Records

  GMD_RESULTS_GRP.ADD_TESTS_TO_SAMPLE
  (   p_sample             => p_sample_rec
    , p_test_ids           => p_test_id_tab
    , p_event_spec_disp_id => p_event_spec_disp_id
    , x_results_tab        => l_results_tab
    , x_spec_results_tab   => l_spec_results_tab
    , x_return_status      => l_return_status);

  IF l_return_status <> 'S' THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;


  -- Standard Check of p_commit.
  IF FND_API.to_boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

  -- Set return Parameters

  x_return_status        := l_return_status;
  x_results_tab          := l_results_tab;
  x_spec_results_tab     := l_spec_results_tab;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO ADD_TESTS_TO_SAMPLE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO ADD_TESTS_TO_SAMPLE;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );



    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO ADD_TESTS_TO_SAMPLE;
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

END ADD_TESTS_TO_SAMPLE;

PROCEDURE VALIDATE_INPUT
( p_results_rec          IN  GMD_RESULTS_PUB.RESULTS_REC,
  x_return_status        OUT NOCOPY VARCHAR2
)
IS
  l_return_status   VARCHAR2(1):= FND_API.G_RET_STS_SUCCESS;
BEGIN

  -- Set out Variable
  x_return_status := l_return_status;

  -- Validate Results Record For Result Table Key Fields
  --  Bug 3763419 ; add Guaranteed by Manufacturer
  IF p_results_rec.result_value IS NULL AND
     p_results_rec.eval_ind NOT IN ('4C', '5O', '1Z') THEN
     GMD_API_PUB.Log_Message('GMD_RESULT_VALUE_REQ');
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  --============================
  -- In Spec Value Should either
  -- be NULL or 'Y'
  --============================
  IF ( p_results_rec.in_spec IS NOT NULL AND
      UPPER(p_results_rec.in_spec) <> 'Y') THEN
      GMD_API_PUB.Log_Message('GMD_INVALID_INSPEC_VALUE');
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_results_rec.result_id IS NULL THEN

     --============================
     -- Valdate Sample Definition.
     --============================
     IF ( p_results_rec.sample_id is NULL) THEN
        IF ( p_results_rec.sample_no is NULL) THEN
           GMD_API_PUB.Log_Message('GMD_SAMPLE_NUMBER_REQD');
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF ( p_results_rec.organization_id is NULL) THEN   /*NSRIVAST, INVCONV*/
           GMD_API_PUB.Log_Message('GMD_SAMPLE_ORGN_CODE_REQD');
           RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF;

     --============================
     -- Validate test_code
     --============================
     IF ( p_results_rec.test_id is NULL) THEN
       IF ( p_results_rec.test_code is NULL) THEN
           GMD_API_PUB.Log_Message('GMD_TEST_ID_CODE_NULL');
           RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;

     --============================
     -- Test Replicate Cnt
     --============================
     IF ( p_results_rec.test_replicate_cnt is NULL) THEN
         GMD_API_PUB.Log_Message('GMD_TEST_REP_CNT_REQD');
         RAISE FND_API.G_EXC_ERROR;
     END IF;

  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE',
                              'GMD_RESULTS_PUB.VALIDATE_INPUT',
                              'ERROR',SUBSTR(SQLERRM,1,100),
                              'POSITION','010');


END VALIDATE_INPUT;

PROCEDURE GET_RESULT_INFO
( p_results_rec          IN  GMD_RESULTS_PUB.RESULTS_REC,
  x_tests_rec            OUT NOCOPY GMD_QC_TESTS%ROWTYPE,
  x_samples_rec          OUT NOCOPY GMD_SAMPLES%ROWTYPE,
  x_return_status        OUT NOCOPY VARCHAR2
)
IS
  l_return_status         VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
  l_tests_rec             GMD_QC_TESTS%ROWTYPE;
  l_samples_rec            GMD_SAMPLES%ROWTYPE;

BEGIN

  -- Set out Variable
  x_return_status := l_return_status;

  -- Get Test record for results
  l_tests_rec.test_id   := p_results_rec.test_id;
  l_tests_rec.test_code := p_results_rec.test_code;

  IF NOT GMD_QC_TESTS_PVT.fetch_row
     ( p_gmd_qc_tests => l_tests_rec,
       x_gmd_qc_tests => x_tests_rec
     ) THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Get Sample Record
  l_samples_rec.sample_id   := p_results_rec.sample_id;
  l_samples_rec.sample_no   := p_results_rec.sample_no;
  l_samples_rec.organization_id   := p_results_rec.organization_id; /*NSRIVAST, INVCONV*/

  IF NOT GMD_SAMPLES_PVT.fetch_row
     (
      p_samples    => l_samples_rec,
      x_samples    => x_samples_rec
     ) THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF x_samples_rec.delete_mark = 1 THEN
      GMD_API_PUB.Log_Message('GMD_RECORD_DELETE_MARKED',
                              'l_table_name', 'GMD_SAMPLES',
                              'l_column_name', 'SAMPLE_ID',
                              'l_key_value', x_samples_rec.sample_id);
      RAISE FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE',
                              'GMD_RESULTS_PUB.GET_RESULT_INFO',
                              'ERROR',SUBSTR(SQLERRM,1,100),
                              'POSITION','010');

END GET_RESULT_INFO;

END GMD_RESULTS_PUB;

/
