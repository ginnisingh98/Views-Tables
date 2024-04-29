--------------------------------------------------------
--  DDL for Package Body GMD_RESULTS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_RESULTS_GRP" AS
--$Header: GMDGRESB.pls 120.20.12010000.4 2010/01/19 21:00:41 plowe ship $

-- Global variables
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'GMD_RESULTS_GRP';
   --Bug 3222090, magupta removed call to FND_PROFILE.VALUE('AFLOG_ENABLED')
   --forward decl.
   function set_debug_flag return varchar2;
   --l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
   l_debug VARCHAR2(1) := set_debug_flag;

   FUNCTION set_debug_flag RETURN VARCHAR2 IS
   l_debug VARCHAR2(1):= 'N';
   BEGIN

    --gmd_debug.put_line('fnd_log.level_procedure '||FND_LOG.LEVEL_PROCEDURE);
    --gmd_debug.put_line('fnd_log.g_current_runtime_level '||FND_LOG.G_CURRENT_RUNTIME_LEVEL);

    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_debug := 'Y';
    END IF;
    RETURN l_debug;
   END set_debug_flag;

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDGRESB.pls                                        |
--| Package Name       : GMD_RESULTS_GRP                                     |
--| Type               : Group                                               |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains group layer APIs for Results Entity             |
--|                                                                          |
--| HISTORY                                                                  |
--|    Chetan Nagar	08-Aug-2002	Created.                             |
--|                                                                          |
--|   Vipul Vaish 23-Jul-2003 Bug#3063671                                    |
--|    Added a call to the Validate_Result procedure in calc_expression      |
--|    which is used to update the gmd_spec_results table with proper values |
--|    for IN_SPEC_IND,ACTION_CODE and EVALUATION_IND columns when the test  |
--|    type is of Expression.
--|   Rameshwar 13-APR-2004 Bug#3545701                                      |
--|    Added test type 'U' in the get_rslt_and_spec_rslt procedure           |
--|    to retrieve the target values for the current specification.          |
--|  B.Stone  9-Sep-2004  Bug 3763419; Added Guaranteed by Manufacturer      |
--|                       evaluation with the same business rules as         |
--|                       Approved with Variance; Result value not allowed   |
--|                       with this evaluation.                              |
--|  rboddu   13-Sep-2004 Bug 376341. Replaced '1X' with '1Z'                |
--|  J. DiIorio Jan-05-2006 Bug#4691545 - Replaced profile retrieval of      |
--|                         GMD_INCLUDE_OPTIONAL_TEST with call to           |
--|                         gmd_quality_config.                              |
--| RLNAGARA 22-MAR-2006 Bug#5097709. Modified the procedure                 |
--| calc_expression so that expression type tests results are calculated     |
--| properly when their refernce tests evaluation is changed but not results.|
--| RLNAGARA 27-MAR-2006 Bug#5106039 Modified the proc change_sample_disposition |
--|  M.Grosser 04-May-2006:  BUG 5167171 - Forward Port of BUG 5097450       |
--|            Modified code to prevent the setting of sample disposition to |
--|            In Progress on the addition of a test if the current          |
--|            disposition is Pending                                        |
--| RAGSRIVA 09-May-2006 Bug# 5195678 Frontport Bug# 5158678                 |
--| RLNAGARA 22-May-2006 Bug 3892837 Modified the proc validate_results	     |
--| P Lowe   07-Jul-2006:  BUG 5353794 - add test_qty and test_qty_uom       |
--|            to cursor for method                                          |
--| RLNAGARA 21-Jul-2006  B5396610 Modified the CURSOR c_test_data in the proc|
--|                      create_composite_rows
--| RLNAGARA 01-Aug-2006 B5416103  Modified the procedure change_disp_for_auto_lot
--|                      and composite_and_change_lot so as to check for
--|                      control_lot_attrib_ind only while changing the lot status
--|                      instead of while changing the disposition of a sample.
--| srakrish 	18-Dec-2006     bug 5652689: Corrected the cursor	    |
--|					 fetch position			    																				 |
--| P Lowe   23-Feb-2007:  BUG 5739844 - Unvalidated Tests are always In-Spec|
--|    																																			 |
--+==========================================================================+
-- End of comments



--Start of comments
--+========================================================================+
--| API Name    : create_rslt_and_spec_rslt_rows                           |
--| TYPE        : Group                                                    |
--| Notes       : This procedure receives as input sample record and       |
--|               creates results and spec results records.                |
--|                                                                        |
--|               If everything is fine then OUT parameter                 |
--|               x_return_status is set to 'S' else appropriate           |
--|               error message is put on the stack and error              |
--|               is returned.                                             |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	08-Aug-2002	Created.                           |
--|                                                                        |
--|    LeAta Jackson    01-Oct-2002    Added p_migration parameter. Mig    |
--|                                    code will send a Y and skip creating|
--|                                    sample_spec_disp record. Migration  |
--|                                    only calls this for samples with no |
--|                                    result records, but there is a spec.|
--|                                                                        |
--|    Chetan Nagar	05-Nov-2002	Change disposition of the          |
--|      Sampling Event and Event Spec Disp back to In Progress. Also      |
--|      set the recomposite flag.                                         |
--|                                                                        |
--|    LeAta Jackson    07-Nov-2002   Per Karen, no tester id if no result |
--|                                                                        |
--|    Susan Feinstein  10-Mar-2003   allow retained samples to save record|
--|                                   in gmd_sample_spec_disp table        |
--|                                                                        |
--|    Chetan Nagar	01-Apr-2002	Added exclude_ind column condition |
--|       in select for table - gmd_spec_tests_b                           |
--|    Brenda Stone     21-Aug-2003   Changed cursor c_vrs_vw; removed the |
--|                                   use of the view and replaced with    |
--|                                   UNION ALL of all the spec vr tables  |
--|                                   to improve performance               |
--|                                                                        |
--|    Chetan Nagar	23-Apr-2004	B3584185                           |
--|                                     Added gmd_stability_spec_vrs to    |
--|                                     the UNION query                    |
--|    nsrivast         25-Jul-05       Updated call to api                |
--|                                 gmd_samples_grp.update_lot_grade_batch |
--+========================================================================+
-- End of comments

PROCEDURE create_rslt_and_spec_rslt_rows
(
  p_sample            IN         GMD_SAMPLES%ROWTYPE
, p_migration         IN         VARCHAR2
, x_event_spec_disp   OUT NOCOPY GMD_EVENT_SPEC_DISP%ROWTYPE
, x_sample_spec_disp  OUT NOCOPY GMD_SAMPLE_SPEC_DISP%ROWTYPE
, x_results_tab       OUT NOCOPY GMD_API_PUB.gmd_results_tab
, x_spec_results_tab  OUT NOCOPY GMD_API_PUB.gmd_spec_results_tab
, x_return_status     OUT NOCOPY VARCHAR2
) IS

  -- Cursors

   -- Bug 3088216: added test_qty, test_uom and test_method_id
  CURSOR c_spec_tests (p_spec_id NUMBER, p_lot_retest_ind VARCHAR2) IS
  SELECT   st.test_id
         , st.seq
         , st.test_replicate
         , tm.test_kit_inv_item_id
         , tm.resources, st.viability_duration
         , st.test_qty
         , st.test_qty_uom
         , tm.test_method_id
  FROM   gmd_spec_tests_b st, gmd_test_methods_b tm
  WHERE  st.spec_id = p_spec_id
  AND    st.exclude_ind IS NULL
  AND    ((p_lot_retest_ind IS NULL) OR
          (st.retest_lot_expiry_ind =  p_lot_retest_ind)
         )
  AND    st.test_method_id =  tm.test_method_id
  ;

 CURSOR c_vrs_vw ( p_spec_vr_id NUMBER) IS
  SELECT spec_id
  FROM   gmd_inventory_spec_vrs
  where  spec_vr_id = p_spec_vr_id
  UNION ALL
  SELECT spec_id
  FROM   gmd_wip_spec_vrs
  where  spec_vr_id = p_spec_vr_id
  UNION ALL
  SELECT spec_id
  FROM   gmd_customer_spec_vrs
  where  spec_vr_id = p_spec_vr_id
  UNION ALL
  SELECT spec_id
  FROM   gmd_supplier_spec_vrs
  where  spec_vr_id = p_spec_vr_id
  UNION ALL
  SELECT spec_id
  FROM   gmd_monitoring_spec_vrs
  where  spec_vr_id = p_spec_vr_id
  -- B3584185 Added following to the union query
  UNION ALL
  SELECT spec_id
  FROM   gmd_stability_spec_vrs
  where  spec_vr_id = p_spec_vr_id
;



  -- Local Variables
  temp_qty                       NUMBER;
  dummy                          PLS_INTEGER;
  l_lab_organization_id          NUMBER;
  l_user_id                      NUMBER;
  l_seq                          PLS_INTEGER;
  l_date                         DATE;
  l_spec_id                      NUMBER(15);
  l_event_spec_disp_id           NUMBER(15);
  l_return_status                VARCHAR2(1);
  l_meaning                      VARCHAR2(80);

  l_sampling_event               gmd_sampling_events%ROWTYPE;
  l_event_spec_disp              gmd_event_spec_disp%ROWTYPE;
  l_sample_spec_disp             gmd_sample_spec_disp%ROWTYPE;
  l_results                      gmd_results%ROWTYPE;
  l_spec_results                 gmd_spec_results%ROWTYPE;

  l_in_sampling_event            gmd_sampling_events%ROWTYPE;
  l_in_event_spec_disp           gmd_event_spec_disp%ROWTYPE;
  l_out_event_spec_disp          gmd_event_spec_disp%ROWTYPE;
  l_out_results                  gmd_results%ROWTYPE;

  -- Exceptions
  e_sampling_event_fetch_error   EXCEPTION;
  e_results_insert_error         EXCEPTION;
  e_spec_results_insert_error    EXCEPTION;
  e_event_spec_disp_insert_error EXCEPTION;
  e_sample_spec_disp_insert_err  EXCEPTION;
  e_event_spec_disp_fetch_error  EXCEPTION;

  -- DESC FLEX Enhancement
  FLEX_EXISTS NUMBER := 0;
  l_count number ;
  appl_short_name         varchar2(30) := 'GMD';
  desc_flex_name          varchar2(30) := 'GMD_QC_RESULTS_FLEX';
  values_or_ids           varchar2(10) := 'V';
  validation_date         DATE         := SYSDATE;
  error_msg               VARCHAR2(5000);
  n   number;
  tf  boolean;
  s number;
  e number;
  concatentated_values   VARCHAR2(250);
  concatentated_ids      VARCHAR2(250);
  errors_received        EXCEPTION;
  error_segment          varchar2(30);
  -- DESC FLEX Enhancement



BEGIN
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- DESC FLEX Enhancement
	--*********************************************************
	--* set the context value                                 *
	--*********************************************************
	FND_FLEX_DESCVAL.set_context_value('Global Data Elements');

	fnd_flex_descval.set_column_value('ATTRIBUTE1', '');
	fnd_flex_descval.set_column_value('ATTRIBUTE2', '');
	fnd_flex_descval.set_column_value('ATTRIBUTE3', '');
	fnd_flex_descval.set_column_value('ATTRIBUTE4', '');
	fnd_flex_descval.set_column_value('ATTRIBUTE5', '');
	fnd_flex_descval.set_column_value('ATTRIBUTE6', '');
	fnd_flex_descval.set_column_value('ATTRIBUTE7', '');
	fnd_flex_descval.set_column_value('ATTRIBUTE8', '');
	fnd_flex_descval.set_column_value('ATTRIBUTE9', '');
	fnd_flex_descval.set_column_value('ATTRIBUTE10', '');
	fnd_flex_descval.set_column_value('ATTRIBUTE11', '');
	fnd_flex_descval.set_column_value('ATTRIBUTE12', '');
	fnd_flex_descval.set_column_value('ATTRIBUTE13', '');
	fnd_flex_descval.set_column_value('ATTRIBUTE14', '');
	fnd_flex_descval.set_column_value('ATTRIBUTE15', '');
	fnd_flex_descval.set_column_value('ATTRIBUTE16', '');
	fnd_flex_descval.set_column_value('ATTRIBUTE17', '');
	fnd_flex_descval.set_column_value('ATTRIBUTE18', '');
	fnd_flex_descval.set_column_value('ATTRIBUTE19', '');
	fnd_flex_descval.set_column_value('ATTRIBUTE20', '');
	fnd_flex_descval.set_column_value('ATTRIBUTE21', '');
	fnd_flex_descval.set_column_value('ATTRIBUTE22', '');
	fnd_flex_descval.set_column_value('ATTRIBUTE23', '');
	fnd_flex_descval.set_column_value('ATTRIBUTE24', '');
	fnd_flex_descval.set_column_value('ATTRIBUTE25', '');
	fnd_flex_descval.set_column_value('ATTRIBUTE26', '');
	fnd_flex_descval.set_column_value('ATTRIBUTE27', '');
	fnd_flex_descval.set_column_value('ATTRIBUTE28', '');
	fnd_flex_descval.set_column_value('ATTRIBUTE29', '');
	fnd_flex_descval.set_column_value('ATTRIBUTE30', '');
  -- DESC FLEX Enhancement

     -- Check that sample is not "Retain"
     -- Bug 2790099: Retained samples still need an entry in
     -- GMD_SAMPLE_SPEC_DISP table.
    -- IF (p_sample.sample_disposition = '0RT') THEN
    -- Well, if you just want to retain the sample then
    -- why should I create the results rows. Abort.

	-- Not anymore dude?


    -- GMD_API_PUB.Log_Message('GMD_RETAIN_SAMPLE');
    -- RAISE FND_API.G_EXC_ERROR;
    -- END IF;

  -- Check that we have the Sampling Event
  -- Now, even in case where there is no Spec for the sample
  -- there still should be a sampling event as per new directions.
  IF (p_sample.sampling_event_id IS NULL) THEN
    -- I need sampling event to know which Spec is used.
    GMD_API_PUB.Log_Message('GMD_SAMPLING_EVENT_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Now that we have sampling_event_id, fetch the sampling event record
  -- l_sampling_event.sampling_event_id := p_sample.sampling_event_id;
  l_in_sampling_event.sampling_event_id := p_sample.sampling_event_id;
  IF NOT (GMD_SAMPLING_EVENTS_PVT.fetch_row(
                   p_sampling_events => l_in_sampling_event,
                   x_sampling_events => l_sampling_event)
         )
  THEN
    -- Fetch Error.
    RAISE e_sampling_event_fetch_error;
  END IF;

  -- If the Sampling Event is set to - Accept, Accept w/Variance
  -- or Reject then you can not add sample anymore.
  IF (l_sampling_event.disposition IN ('4A', '5AV', '6RJ')) THEN
    SELECT meaning
    INTO   l_meaning
    FROM   gem_lookups
    WHERE  lookup_type = 'GMD_QC_SAMPLE_DISP'
    AND    lookup_code = l_sampling_event.disposition;

    GMD_API_PUB.Log_Message('GMD_SAMPLING_EVENT_DISPOSED',
			    'DISPOSITION', l_meaning);
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- All the required validations are over so let's start
  -- doing some REAL work.

  -- Get the Spec ID from the SPEC_VR_ID, if SPEC_VR_ID is specified
  -- in the Sampling Event
  IF (l_sampling_event.original_spec_vr_id IS NOT NULL) THEN
    OPEN c_vrs_vw(l_sampling_event.original_spec_vr_id);
    FETCH c_vrs_vw INTO l_spec_id;
    IF c_vrs_vw%NOTFOUND THEN
      -- Now this can not happen that we have spec_vr_id and there is no Spec
      GMD_API_PUB.Log_Message('GMD_SPEC_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_vrs_vw;
  END IF;

  l_lab_organization_id := p_sample.lab_organization_id;

  -- Get the user ID
  IF p_sample.created_by IS NULL THEN
    l_user_id  := FND_GLOBAL.user_id;
  ELSE
    l_user_id  := p_sample.created_by;
  END IF;

  l_date     := SYSDATE;
  l_seq      := 0;
  dummy      := 0;

  -- Check if we already have a record in GMD_EVENT_SPEC_DISP
  l_event_spec_disp_id := get_current_event_spec_disp_id(
                               l_sampling_event.sampling_event_id);

  IF (l_event_spec_disp_id IS NULL) THEN
    -- This is the first sample so create a record in GMD_EVENT_SPEC_DISP

    -- Construct the record
    l_event_spec_disp.sampling_event_id            := l_sampling_event.sampling_event_id;
    l_event_spec_disp.spec_id                      := l_spec_id;
    l_event_spec_disp.spec_vr_id                   := l_sampling_event.original_spec_vr_id;
    l_event_spec_disp.disposition                  := '1P';

    -- We need to see if we can default something here
    -- As per 12-Sep-2002 meeting it will be Y for new reocrd
    l_event_spec_disp.spec_used_for_lot_attrib_ind := 'Y';

    l_event_spec_disp.delete_mark                  := 0;
    l_event_spec_disp.creation_date                := l_date;
    l_event_spec_disp.created_by                   := l_user_id;
    l_event_spec_disp.last_update_date             := l_date;
    l_event_spec_disp.last_updated_by              := l_user_id;

    -- We are ready for insert in GMD_EVENT_SPEC_DISP, so then lets do it.
    IF NOT(gmd_event_spec_disp_pvt.insert_row(
                    p_event_spec_disp => l_event_spec_disp,
                    x_event_spec_disp => l_out_event_spec_disp)
            )
    THEN
      -- Insert Error
      RAISE e_event_spec_disp_insert_error;
    END IF;
    l_event_spec_disp.event_spec_disp_id := l_out_event_spec_disp.event_spec_disp_id;
  ELSE
    -- Fetch the GMD_EVENT_SPEC_DISP record
    -- l_event_spec_disp.event_spec_disp_id := l_event_spec_disp_id;
    l_in_event_spec_disp.event_spec_disp_id := l_event_spec_disp_id;
    IF NOT(gmd_event_spec_disp_pvt.fetch_row(
                    p_event_spec_disp => l_in_event_spec_disp,
                    x_event_spec_disp => l_event_spec_disp)
            )
    THEN
      -- Insert Error
      RAISE e_event_spec_disp_fetch_error;
    END IF;
  END IF;

  x_event_spec_disp := l_event_spec_disp;

  -- Migration calls this procedure for samples which match specs but do not
  -- already have results.  So sample_spec_disp already has a row from earlier
  -- in the migration script where the sample record was created.
  -- Migration is the ONLY valid instance where we can skip inserting into
  -- sample_spec_disp.

  IF (p_migration IS NULL OR p_migration <> 'Y')THEN
    -- Create a record in GMD_SAMPLE_SPEC_DISP

    -- Construct the record
    l_sample_spec_disp.event_spec_disp_id     := l_event_spec_disp.event_spec_disp_id;
    l_sample_spec_disp.sample_id              := p_sample.sample_id;
    l_sample_spec_disp.delete_mark            := 0;
    l_sample_spec_disp.creation_date          := l_date;
    l_sample_spec_disp.created_by             := l_user_id;
    l_sample_spec_disp.last_update_date       := l_date;
    l_sample_spec_disp.last_updated_by        := l_user_id;

     -- Bug 3079877: added planning samples
    IF   (p_sample.sample_disposition = '0RT')
      OR (p_sample.sample_disposition = '0PL') THEN
       l_sample_spec_disp.disposition         := p_sample.sample_disposition;
    ELSE
       l_sample_spec_disp.disposition         := '1P';
    END IF;    -- check for retained sample

  -- We are ready for insert, so then lets do it.
    IF NOT(gmd_sample_spec_disp_pvt.Insert_Row(
                    p_sample_spec_disp => l_sample_spec_disp)
            )
    THEN
      -- Insert Error
      RAISE e_sample_spec_disp_insert_err;
    END IF;

    x_sample_spec_disp:= l_sample_spec_disp;
  END IF;                  -- end if migration is calling this procedure

  -- By now the Event Spec Disp record is either created or fetched.
  -- Now if the Event Spec Disp record has Spec then create
  -- rows in GMD_RESULTS and GMD_SPEC_RESULTS for all the tests


  -- Bug 2790099: Retained samples still need an entry in
  --              GMD_SAMPLE_SPEC_DISP table.
  -- Bug 3079877: Planned samples should not get an event disp record
  IF (l_event_spec_disp.spec_id IS NOT NULL)
     AND (p_sample.sample_disposition <> '0RT')
     AND (p_sample.sample_disposition <> '0PL') THEN

    l_spec_id := l_event_spec_disp.spec_id;

    -- Go through all the tests that are part of the Spec
    FOR l_spec_test IN c_spec_tests(l_spec_id, p_sample.lot_retest_ind)
    LOOP

	l_count := 0;
	FLEX_EXISTS := 0;

	-- DESC FLEX Enhancement
	IF  FND_FLEX_DESCVAL.validate_desccols(
	      appl_short_name,
	      desc_flex_name,
	      values_or_ids,
	      validation_date)
	THEN
  	      FLEX_EXISTS := 1;
	      l_count := fnd_flex_descval.segment_count;
	      --GMD_API_PUB.Log_Message('Descriptive Flex Field exists.Count ' || l_count);
	ELSE
	      error_segment := FND_FLEX_DESCVAL.error_segment;
	      -- raise errors_received;
		null ;
        END IF;


       if (l_count > 0) then
	   concatentated_values := FND_FLEX_DESCVAL.concatenated_values;
	   concatentated_ids := FND_FLEX_DESCVAL.concatenated_ids;
           --GMD_API_PUB.Log_Message('Descriptive Flex Field. Values ' || concatentated_values);
	   --GMD_API_PUB.Log_Message('Descriptive Flex Field. IDs ' || concatentated_ids);
       end if ;
	-- DESC FLEX Enhancement



      -- Go through as many times the test replicate mentioned in Spec Test.
      FOR i IN 1..l_spec_test.test_replicate
      LOOP
        l_seq := l_seq + 10;
        dummy := dummy + 1;

            -- Bug 3088216: test for uom conversion.  If the test uom is not
            --              convertible to item uom, send error message.
            -- Bug 3159303: code taken out since convertible test is done between sample
            --              and item UOM in form GMDQSMPL.fmb
            --IF (( l_spec_test.test_uom IS NOT NULL) AND ( l_spec_test.test_qty <> 0 )
              --AND (l_spec_test.test_uom <> p_sample.sample_uom)) THEN
              --temp_qty := gmicuom.uom_conversion(p_sample.item_id,
                   --                              0,
                        --                         p_sample.sample_qty,
                             --                    p_sample.sample_uom,
                                  --               l_spec_test.test_uom,
                                       --          0);

               --IF (temp_qty < 0) THEN
                  --OPEN c_item_no(p_sample.item_id);
                  --FETCH c_item_no INTO l_item_no;
                  --CLOSE c_item_no;
                  --GMD_API_PUB.Log_Message('FM_SCALE_BAD_UOM_CONV',
                      --                    'FROM_UOM',p_sample.sample_uom,
                          --                'TO_UOM'  ,l_spec_test.test_uom,
                             --             'ITEM_NO' ,l_item_no);
                  --RAISE FND_API.G_EXC_ERROR;
               --END IF;  -- (temp_qty < 0)
            --END IF;       -- l_spec_test.test_uom <> p_sample.sample_uom
               -- end bug 3088216

        -- Construct GMD_RESULTS record

        l_results.sample_id                     := p_sample.sample_id;
        l_results.test_id                       := l_spec_test.test_id;
        l_results.test_replicate_cnt            := i;
        l_results.lab_organization_id           := l_lab_organization_id;
        l_results.test_kit_inv_item_id          := l_spec_test.test_kit_inv_item_id;
        l_results.seq                           := l_spec_test.seq;
        l_results.delete_mark                   := 0;
        l_results.creation_date                 := l_date;
        l_results.created_by                    := l_user_id;
        l_results.last_updated_by               := l_user_id;
        l_results.last_update_date              := l_date;
        l_results.planned_resource              := l_spec_test.resources;

          -- Bug 3088216: added test_qty, test_uom, test_method_id
        l_results.test_qty                      := l_spec_test.test_qty;
        l_results.test_qty_uom                  := l_spec_test.test_qty_uom;
        l_results.test_method_id                := l_spec_test.test_method_id;

        IF (nvl(l_spec_test.viability_duration,0)  > 0 ) THEN
          l_results.test_by_date                  := p_sample.date_drawn
                                                  + l_spec_test.viability_duration/(60*60*24);
        END IF;


	-- DESC FLEX Enhancement
     FOR i IN 1..l_count LOOP
 	   IF FND_FLEX_DESCVAL.segment_column_name(i) = 'ATTRIBUTE_CATEGORY' THEN
	     l_results.attribute_category :=  FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = 'ATTRIBUTE1' THEN
	     l_results.attribute1 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = 'ATTRIBUTE2' THEN
	     l_results.attribute2 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = 'ATTRIBUTE3' THEN
	     l_results.attribute3 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = 'ATTRIBUTE4' THEN
	     l_results.attribute4 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = 'ATTRIBUTE5' THEN
	     l_results.attribute5 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = 'ATTRIBUTE6' THEN
	     l_results.attribute6 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = 'ATTRIBUTE7' THEN
	     l_results.attribute7 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = 'ATTRIBUTE8' THEN
	     l_results.attribute8 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = 'ATTRIBUTE9' THEN
	     l_results.attribute9 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = 'ATTRIBUTE10' THEN
	     l_results.attribute10 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = 'ATTRIBUTE11' THEN
	     l_results.attribute11 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = 'ATTRIBUTE12' THEN
	     l_results.attribute12 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = 'ATTRIBUTE13' THEN
	     l_results.attribute13 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = 'ATTRIBUTE14' THEN
	     l_results.attribute14 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = 'ATTRIBUTE15' THEN
	     l_results.attribute15 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = 'ATTRIBUTE16' THEN
	     l_results.attribute16 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = 'ATTRIBUTE17' THEN
	     l_results.attribute17 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = 'ATTRIBUTE18' THEN
	     l_results.attribute18 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = 'ATTRIBUTE19' THEN
	     l_results.attribute19 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = 'ATTRIBUTE20' THEN
	     l_results.attribute20 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = 'ATTRIBUTE21' THEN
	     l_results.attribute21 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = 'ATTRIBUTE22' THEN
	     l_results.attribute22 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = 'ATTRIBUTE23' THEN
	     l_results.attribute23 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = 'ATTRIBUTE24' THEN
	     l_results.attribute24 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = 'ATTRIBUTE25' THEN
	     l_results.attribute25 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = 'ATTRIBUTE26' THEN
	     l_results.attribute26 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = 'ATTRIBUTE27' THEN
	     l_results.attribute27 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = 'ATTRIBUTE28' THEN
	     l_results.attribute28 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = 'ATTRIBUTE29' THEN
	     l_results.attribute29 := FND_FLEX_DESCVAL.segment_id(i);
	   ELSIF FND_FLEX_DESCVAL.segment_column_name(i) = 'ATTRIBUTE30' THEN
	     l_results.attribute30 := FND_FLEX_DESCVAL.segment_id(i);
	  END IF;
       END LOOP;
	-- DESC FLEX Enhancement



        -- We are ready for insert in GMD_RESULTS, so then lets do it.
        IF NOT(GMD_RESULTS_PVT.Insert_Row(
                      p_results => l_results,
                      x_results => l_out_results)
              )
        THEN
          -- Insert Error
          RAISE e_results_insert_error;
        END IF;
	l_results.RESULT_ID := l_out_results.RESULT_ID;

        x_results_tab(dummy) := l_results;

        -- Now, Construct GMD_SPEC_RESULTS record

        l_spec_results.event_spec_disp_id       := l_event_spec_disp.event_spec_disp_id;
        l_spec_results.result_id                := l_results.result_id;
        l_spec_results.delete_mark              := 0;
        l_spec_results.creation_date            := l_date;
        l_spec_results.created_by               := l_user_id;
        l_spec_results.last_updated_by          := l_user_id;
        l_spec_results.last_update_date         := l_date;

        -- We are ready for insert in GMD_SPEC_RESULTS, so then lets do it.
        IF NOT(gmd_spec_results_pvt.Insert_Row(p_spec_results => l_spec_results))
        THEN
          -- Insert Error
          RAISE e_spec_results_insert_error;
        END IF;

        x_spec_results_tab(dummy) := l_spec_results;

      END LOOP;  -- Test Replicate Loop

    END LOOP;  -- Spec Tests Loop

  END IF; -- We have the Spec from Sampling Event

  -- Bug 2790099: Retained samples still need an entry in
  --              GMD_SAMPLE_SPEC_DISP table.
  -- Bug 3079877: iPlanning samples do not need to be recomposited
  IF     (p_sample.sample_disposition <> '0RT')
     AND (p_sample.sample_disposition <> '0PL') THEN
     -- Since we altered the Sampling Event set the recomposite_flag to 'Y'
     IF (nvl(l_sampling_event.sample_active_cnt, 0) > 1) THEN
       se_recomposite_required (  p_sampling_event_id  => l_sampling_event.sampling_event_id
                                , p_event_spec_disp_id => l_event_spec_disp.event_spec_disp_id
                                , x_return_status      => l_return_status
                               );
       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;

     IF NOT (l_event_spec_disp.disposition IN ('1P', '2I')) THEN
       -- Set the disposition of the Event spec disp
       -- back to "In Progress"
       UPDATE gmd_event_spec_disp
       SET    disposition = '2I',
              last_updated_by = l_user_id,
              last_update_date = l_date
       WHERE  event_spec_disp_id = l_event_spec_disp.event_spec_disp_id
       ;
     END IF;

     IF NOT (l_sampling_event.disposition IN ('1P', '2I')) THEN
       -- Set the disposition of the Sampling Event
       -- back to "In Progress"
       UPDATE gmd_sampling_events
       SET    disposition = '2I',
              last_updated_by = l_user_id,
              last_update_date = l_date
       WHERE  sampling_event_id = l_sampling_event.sampling_event_id
       ;
     END IF;

  END IF;  -- (p_sample.sample_disposition <> '0RT')

  -- All systems GO...

EXCEPTION
  WHEN    errors_Received then
	error_msg := fnd_flex_Descval.error_message ;
	s := 1;
	e := 200;
	GMD_API_PUB.Log_Message('GMD_API_ERROR',
                            'PACKAGE','CREATE_RSLT_AND_SPEC_RSLT_ROWS',
                            'ERROR', error_msg);
  WHEN    FND_API.G_EXC_ERROR
       OR e_sampling_event_fetch_error
       OR e_results_insert_error
       OR e_spec_results_insert_error
       OR e_event_spec_disp_insert_error
       OR e_sample_spec_disp_insert_err
       OR e_event_spec_disp_fetch_error
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR',
                            'PACKAGE','CREATE_RSLT_AND_SPEC_RSLT_ROWS',
                            'ERROR', SUBSTR(SQLERRM,1,100));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END create_rslt_and_spec_rslt_rows;





--Start of comments
--+========================================================================+
--| API Name    : delete_rslt_and_spec_rslt_rows                           |
--| TYPE        : Group                                                    |
--| Notes       : This routine is called when the sample disposition is    |
--|               changed from "Pending" to "Retain".  In this case the    |
--|               result and spec result rows that were created when the   |
--|               sample was pending is deleted.                           |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	14-May-2003	Created.                           |
--+========================================================================+
-- End of comments

PROCEDURE delete_rslt_and_spec_rslt_rows
(
  p_sample_id     IN         NUMBER
, x_return_status OUT NOCOPY VARCHAR2
) IS
BEGIN

  IF (l_debug = 'Y') THEN
    gmd_debug.put_line('Entering procedure DELETE_RSLT_AND_SPEC_RSLT_ROWS');
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  DELETE gmd_spec_results
  WHERE result_id IN (SELECT result_id
                      FROM   gmd_results
                      WHERE  sample_id = p_sample_id)
  ;

  IF (l_debug = 'Y') THEN
    gmd_debug.put_line('Rows deleted from gmd_spec_results: '|| SQL%ROWCOUNT);
  END IF;

  DELETE gmd_results
  WHERE  sample_id = p_sample_id
  ;

  IF (l_debug = 'Y') THEN
    gmd_debug.put_line('Rows deleted from gmd_results: '|| SQL%ROWCOUNT);
  END IF;

  IF (l_debug = 'Y') THEN
    gmd_debug.put_line('Leaving procedure DELETE_RSLT_AND_SPEC_RSLT_ROWS');
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR',
                            'PACKAGE','DELETE_RSLT_AND_SPEC_RSLT_ROWS',
                            'ERROR', SUBSTR(SQLERRM,1,100));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END delete_rslt_and_spec_rslt_rows;





--Start of comments
--+========================================================================+
--| API Name    : get_current_event_spec_disp_id                           |
--| TYPE        : Group                                                    |
--| Notes       : This procedure finds out current event_spec_disp_id      |
--|               for a given sampling_event_id.                           |
--|                                                                        |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	12-Sep-2002	Created.                           |
--|                                                                        |
--+========================================================================+
-- End of comments

FUNCTION get_current_event_spec_disp_id
(
  p_sampling_event_id     IN  NUMBER
) RETURN NUMBER IS

  -- Cursors
  CURSOR c_event_disp(p_sampling_event_id NUMBER) IS
  SELECT event_spec_disp_id
  FROM   gmd_event_spec_disp
  WHERE  sampling_event_id            = p_sampling_event_id
  AND    spec_used_for_lot_attrib_ind = 'Y'
  AND    delete_mark                  = 0
  ;

  -- Local Variables
  l_dummy                         NUMBER(15);

BEGIN

  OPEN c_event_disp(p_sampling_event_id);
  FETCH c_event_disp INTO l_dummy;
  CLOSE c_event_disp;

  RETURN l_dummy;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;

END get_current_event_spec_disp_id;



--Start of comments
--+========================================================================+
--| API Name    : compare_rslt_and_spec                                    |
--| TYPE        : Group                                                    |
--| Notes       : This procedure finds out Tests that are not in the given |
--|               result set and are in the Spec given.                    |
--|                                                                        |
--|               Example,                                                 |
--|                                                                        |
--|               Sample ID - 000001                                       |
--|                                                                        |
--|                 Tests                                                  |
--|                 -----                                                  |
--|                 T1                                                     |
--|                 T2                                                     |
--|                 T4                                                     |
--|                 T5                                                     |
--|                                                                        |
--|               User wants to compare this sample to Spec - S2           |
--|                                                                        |
--|               S2 has following tests                                   |
--|                                                                        |
--|                 Tests                                                  |
--|                 -----                                                  |
--|                 T1                                                     |
--|                 T3                                                     |
--|                 T6                                                     |
--|                                                                        |
--|               So when this proceudre is called, it will return a       |
--|               table of tests as follows:                               |
--|                                                                        |
--|               Tests in S2 and not in result set for Sample ID - 000001 |
--|                                                                        |
--|               Tests Missing                                            |
--|               -------------                                            |
--|               T3                                                       |
--|               T6                                                       |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	08-Aug-2002	Created.                           |
--|                                                                        |
--|    Chetan Nagar	01-Apr-2002	Added exclude_ind column condition |
--|       in select for table - gmd_spec_tests_b                           |
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE compare_rslt_and_spec
(
  p_sample_id     IN         NUMBER
, p_spec_id       IN         NUMBER
, x_test_ids      OUT NOCOPY GMD_API_PUB.number_tab
, x_return_status OUT NOCOPY VARCHAR2
) IS

  -- Cursors
  CURSOR c_new_spec_tests (p_spec_id NUMBER) IS
  SELECT st.test_id
  FROM   gmd_spec_tests_b st
  WHERE  st.spec_id = p_spec_id
  AND    st.exclude_ind IS NULL
  AND    st.test_id NOT IN
    (SELECT r.test_id
     FROM   gmd_results r
     WHERE  r.sample_id = p_sample_id)
  ORDER BY st.seq
  ;

  -- Local Variables
  i                              PLS_INTEGER;

BEGIN
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  i := 0;

  -- Go throug all the tests that are part of the Spec
  FOR l_spec_test IN c_new_spec_tests(p_spec_id)
  LOOP
    -- Found the test, add it to the table.
    i := i + 1;
    x_test_ids(i) := l_spec_test.test_id;

  END LOOP;

  -- All systems GO...

EXCEPTION
  WHEN    FND_API.G_EXC_ERROR
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR',
                            'PACKAGE','COMPARE_RSLT_AND_SPEC',
                            'ERROR', SUBSTR(SQLERRM,1,100));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END compare_rslt_and_spec;



--Start of comments
--+========================================================================+
--| API Name    : compare_cmpst_rslt_and_spec                              |
--| TYPE        : Group                                                    |
--| Notes       : This procedure finds out Tests that are not in the given |
--|               composite result set and are in the Spec given.          |
--|                                                                        |
--|               Example,                                                 |
--|                                                                        |
--|               Composite Results                                        |
--|                                                                        |
--|                 Tests                                                  |
--|                 -----                                                  |
--|                 T1                                                     |
--|                 T2                                                     |
--|                 T4                                                     |
--|                 T5                                                     |
--|                                                                        |
--|               User wants to compare this sample to Spec - S2           |
--|                                                                        |
--|               S2 has following tests                                   |
--|                                                                        |
--|                 Tests                                                  |
--|                 -----                                                  |
--|                 T1                                                     |
--|                 T3                                                     |
--|                 T6                                                     |
--|                                                                        |
--|               So when this proceudre is called, it will return a       |
--|               table of tests as follows:                               |
--|                                                                        |
--|               Tests in S2 and not in composite result set              |
--|                                                                        |
--|               Tests Missing                                            |
--|               -------------                                            |
--|               T3                                                       |
--|               T6                                                       |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	16-Sep-2002	Created.                           |
--|                                                                        |
--|    Chetan Nagar	01-Apr-2002	Added exclude_ind column condition |
--|       in select for table - gmd_spec_tests_b                           |
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE compare_cmpst_rslt_and_spec
(
  p_composite_spec_disp_id IN         NUMBER
, p_spec_id                IN         NUMBER
, x_test_ids               OUT NOCOPY GMD_API_PUB.number_tab
, x_return_status          OUT NOCOPY VARCHAR2
) IS

  -- Cursors
  CURSOR c_new_spec_tests (p_composite_spec_disp_id NUMBER) IS
  SELECT st.test_id
  FROM   gmd_spec_tests_b st
  WHERE  st.spec_id = p_spec_id
  AND    st.exclude_ind IS NULL
  AND    st.test_id NOT IN
    (SELECT cr.test_id
     FROM   gmd_composite_results cr
     WHERE  cr.composite_spec_disp_id = p_composite_spec_disp_id)
  ORDER BY st.seq
  ;

  -- Local Variables
  i                              PLS_INTEGER;

BEGIN
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  i := 0;

  -- Go throug all the tests that are part of the Spec
  FOR l_spec_test IN c_new_spec_tests(p_composite_spec_disp_id)
  LOOP
    -- Found the test, add it to the table.
    i := i + 1;
    x_test_ids(i) := l_spec_test.test_id;

  END LOOP;

  -- All systems GO...

EXCEPTION
  WHEN    FND_API.G_EXC_ERROR
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR',
                            'PACKAGE','compare_cmpst_rslt_and_spec',
                            'ERROR', SUBSTR(SQLERRM,1,100));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END compare_cmpst_rslt_and_spec;




--Start of comments
--+========================================================================+
--| API Name    : rslt_is_in_spec                                          |
--| TYPE        : Group                                                    |
--| Notes       : This function finds out if the result supplied is        |
--|               IN-SPEC as per the limits set in the specification.      |
--|                                                                        |
--|               Example,                                                 |
--|                                                                        |
--|               Test - pH Test                                           |
--|                                                                        |
--|               Result Value - 7.3                                       |
--|                                                                        |
--|               Spec Test Limits                                         |
--|               ----------------                                         |
--|                     Min - 4                                            |
--|                  Target - 7                                            |
--|                     Max - 9                                            |
--|                                                                        |
--|               So in this case the function will return TRUE since the  |
--|               result value for pH Test is 7.3 and it is withing the    |
--|               limits set in Specification.                             |
--|                                                                        |
--| PARAMETERS  : 1. p_spec_id         - Spec against which result is      |
--|                                      compared.                         |
--|               2. p_test_id         - Test for which the result         |
--|                                      is supplied.                      |
--|               3. p_rslt_value_num  - Value of the test result, passed  |
--|                                      when the test type is             |
--|                                      one of N, E, T                    |
--|               4. p_rslt_value_char - Passed when the test type is L    |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	09-Aug-2002	Created.                           |
--|    LeAta Jackson    08-Nov-2002     Karen said unvalidated tests       |
--|                            should not automatically be in spec.        |
--|                                                                        |
--|    Chetan Nagar	01-Apr-2002	Added exclude_ind column condition |
--|       in select for table - gmd_spec_tests_b                           |
--|    srakrish 	18-Dec-2006     bug 5652689: Corrected the cursor  |
--|					 fetch position			   |
--+========================================================================+
-- End of comments

FUNCTION rslt_is_in_spec
(
  p_spec_id         IN  NUMBER
, p_test_id         IN  NUMBER
, p_rslt_value_num  IN  NUMBER
, p_rslt_value_char IN  VARCHAR2
)
RETURN VARCHAR2 IS

  -- Cursors
  CURSOR c_spec_test_val (p_spec_id NUMBER, p_test_id NUMBER) IS
  SELECT t.test_type, st.min_value_num, st.max_value_num, st.target_value_char
  FROM   gmd_qc_tests_b t, gmd_spec_tests_b st
  WHERE  t.test_id= st.test_id
  AND    st.exclude_ind IS NULL
  AND    st.spec_id = p_spec_id
  AND    st.test_id = p_test_id
  ;

  -- When test type is T, get the NUM seq if only Char value is passed
  CURSOR c_text_to_num(p_test_id NUMBER, p_value_char VARCHAR2) IS
  SELECT text_range_seq
  FROM   gmd_qc_test_values_b
  WHERE  test_id        = p_test_id
  AND    value_char     = p_value_char
  ;

  -- When test type is L, check that there exits a subranges that covers the result num
  CURSOR c_subranges(p_test_id NUMBER, p_num NUMBER) IS
  SELECT 1
  FROM   gmd_qc_test_values_b
  WHERE  test_id = p_test_id
  AND    nvl(min_num, p_num) <= p_num
  AND    nvl(max_num, p_num) >= p_num
  ;



  -- Local Variables
  x_in_spec                     VARCHAR2(1);
  l_test_min                    NUMBER;
  l_test_max                    NUMBER;
  l_rslt_value_num              NUMBER;
  dummy                         PLS_INTEGER;

  l_values                      c_spec_test_val%ROWTYPE;

BEGIN

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('Entering procedure RSLT_IS_IN_SPEC');
  END IF;

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('Spec ID: ' || p_spec_id || ' Test ID: ' || p_test_id ||
            ' Num Result: ' || p_rslt_value_num || ' Char Result: ' || p_rslt_value_char);
  END IF;

  -- Initialize return status as Out-Of-Spec
  x_in_spec := NULL;

  -- Check that the required parameters are passed.
  IF (p_rslt_value_num IS NULL AND p_rslt_value_char IS NULL) OR
     (p_test_id IS NULL) OR
     (p_spec_id IS NULL)
  THEN
    RETURN NULL;
  END IF;
    --srakrish bug 5652689:
    OPEN c_spec_test_val(p_spec_id, p_test_id);
    FETCH c_spec_test_val INTO l_values;
    IF c_spec_test_val%NOTFOUND THEN
      CLOSE c_spec_test_val;
      RETURN NULL;
    END IF;
    CLOSE c_spec_test_val;

  IF (l_values.test_type = 'U') THEN
  -- Find out min, max, and target from the Spec test
    -- Unvalidated Tests are always In-Spec
   RETURN 'Y';   -- Bug 5739844

  ELSE
    --srakrish bug 5652689: Moved the cursor fetch to before the If condition
    /*OPEN c_spec_test_val(p_spec_id, p_test_id);
    FETCH c_spec_test_val INTO l_values;
    IF c_spec_test_val%NOTFOUND THEN
      CLOSE c_spec_test_val;
      RETURN NULL;
    END IF;
    CLOSE c_spec_test_val; */

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Test Type: ' || l_values.test_type ||
                     ' Min: ' || l_values.min_value_num ||
                     ' Max: ' || l_values.max_value_num ||
                     ' Target: ' || l_values.target_value_char);
    END IF;


    IF (l_values.test_type = 'N' OR
         l_values.test_type = 'E' OR
         l_values.test_type = 'T'
        ) THEN

      -- Numeric, Expression or Text Range

      l_rslt_value_num := p_rslt_value_num;
      -- If Text Range and if the seq is not supplied then find one using Char value
      IF (l_values.test_type = 'T' AND l_rslt_value_num IS NULL) THEN
        IF (l_debug = 'Y') THEN
          gmd_debug.put_line('For test type T, the NUM value is missing.');
        END IF;
        OPEN c_text_to_num(p_test_id, p_rslt_value_char);
        FETCH c_text_to_num INTO l_rslt_value_num;
        IF (c_text_to_num%NOTFOUND) THEN
          CLOSE c_text_to_num;
          RETURN NULL;
        END IF;
        IF (l_debug = 'Y') THEN
          gmd_debug.put_line('For test type T, retrieved the NUM value: ' || l_rslt_value_num);
        END IF;
        CLOSE c_text_to_num;
      END IF;       -- end if test type is T and no seq number is given

      IF (l_values.min_value_num <= l_rslt_value_num AND
          l_rslt_value_num <= l_values.max_value_num) THEN

        -- The result is In-Spec
        x_in_spec := 'Y';

        IF (l_debug = 'Y') THEN
          gmd_debug.put_line('For N, E, and T it is IN-SPEC');
        END IF;
      END IF;

    ELSIF (l_values.test_type = 'L') THEN

      -- Numeric Range with Display Label
      IF (nvl(l_values.min_value_num, p_rslt_value_num) <= p_rslt_value_num AND
        p_rslt_value_num <= nvl(l_values.max_value_num, p_rslt_value_num)) THEN

        IF (l_debug = 'Y') THEN
          gmd_debug.put_line('For L it is IN-SPEC AT FIRST. Lets check individual ranges.');
        END IF;
        -- num range with display can have holes in the subranges
        -- check that the result does not fall into one of those holes
        OPEN c_subranges(p_test_id, p_rslt_value_num) ;
        FETCH c_subranges INTO dummy;
        IF c_subranges%FOUND THEN
          IF (l_debug = 'Y') THEN
   	    gmd_debug.put_line('For L it is also in one of the subranges so it is IN-SPEC.');
          END IF;
          x_in_spec := 'Y';
        END IF;
        CLOSE c_subranges;
      END IF;

    ELSIF (l_values.test_type = 'V') THEN

      -- List of Values
      IF (p_rslt_value_char = l_values.target_value_char) THEN
        IF (l_debug = 'Y') THEN
          gmd_debug.put_line('For V it is equal to Target and so it is IN-SPEC');
        END IF;
        x_in_spec := 'Y';
      END IF;

    END IF;         -- end test type CASEs

END IF;             -- end if test is nonvalidate or not

RETURN x_in_spec;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;

END rslt_is_in_spec;


--Start of comments
--+========================================================================+
--| API Name    : add_tests_to_sample                                      |
--| TYPE        : Group                                                    |
--| Notes       : This function received as input table of test IDs that   |
--|               are to be added to a given sample.                       |
--|                                                                        |
--|               The function will insert rows into GMD_RESULTS and       |
--|               GMD_SPEC_RESULTS.                                        |
--|                                                                        |
--| PARAMETERS  :                                                          |
--|                                                                        |
--| 1. p_sample - Sample record for which tests are added to results       |
--| 2. p_test_ids - Table of test ids to be added to the result            |
--| 3. p_event_spec_disp_id  - Event Spec                                  |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	21-Aug-2002   Created.                             |
--|                                                                        |
--|    LeAta Jackson    07-Nov-2002   Per Karen, no tester id if no result |
--|                                                                        |
--|    Chetan Nagar	05-Dec-2002   Assign the OUT variables at proper   |
--|                                   index position.                      |
--|                                                                        |
--|    Chetan Nagar	01-Apr-2002	Added exclude_ind column condition |
--|       in select for table - gmd_spec_tests_b                           |
--|  M.Grosser 04-May-2006:  BUG 5167171 - Forward Port of BUG 5097450     |
--|            Modified code to prevent the setting of sample disposition  |
--|            to In Progress on the addition of a test if the current     |
--|            disposition is Pending                                      |
--|  P Lowe    07-Jul-2006:  BUG 5353794 - add test_qty and test_qty_uom   |
--|            to cursor for method                                        |
--+========================================================================+
-- End of comments

PROCEDURE add_tests_to_sample
(
  p_sample             IN         GMD_SAMPLES%ROWTYPE
, p_test_ids           IN         GMD_API_PUB.number_tab
, p_event_spec_disp_id IN         NUMBER
, x_results_tab        OUT NOCOPY GMD_API_PUB.gmd_results_tab
, x_spec_results_tab   OUT NOCOPY GMD_API_PUB.gmd_spec_results_tab
, x_return_status      OUT NOCOPY VARCHAR2
, p_test_qty           IN         NUMBER   default NULL
, p_test_qty_uom       IN         VARCHAR2 default NULL
)
IS

  -- Cursors
	  CURSOR c_test_method (p_test_id NUMBER) IS
	  SELECT tm.test_kit_inv_item_id,
                 tm.test_replicate,
                 tm.test_method_id, -- 5353794
                 tm.test_qty,
                 tm.test_qty_uom
	  FROM   gmd_qc_tests_b t, gmd_test_methods_b tm
	  WHERE  t.test_id =  p_test_id
	  AND    t.test_method_id = tm.test_method_id
	  ;

         -- Begin 3903309
	 CURSOR c_get_sample_spec_disp (p_sample_id number) is
	 SELECT disposition
         FROM gmd_sample_spec_disp
         WHERE sample_id = p_sample_id
         AND event_spec_disp_id = p_event_spec_disp_id ;

         l_sample_spec_disp varchar2(3) ;
	 -- End 3903309

	  -- Local Variables
	  l_test_method_id               NUMBER;
	  l_user_id                      NUMBER;
	  l_seq                          PLS_INTEGER;
	  l_date                         DATE;
	  l_lab_organization             NUMBER;
	  l_test_kit_inv_item_id             NUMBER;
	  l_next_test_replicate_cnt      PLS_INTEGER;
	  l_test_added_flag              BOOLEAN := FALSE;
	  l_test_type                    VARCHAR2(2);
	  l_additional_test_ind          VARCHAR2(1);
	  l_replicate                    NUMBER(5);
	  dummy                          PLS_INTEGER;
	  out_var_idx                    PLS_INTEGER := 0;
	  l_meaning                      VARCHAR2(80);
	  l_viability_duration           NUMBER;
	  l_resources                    GMD_TEST_METHODS_B.RESOURCES%TYPE;

	  l_sample                       GMD_SAMPLES%ROWTYPE;
	  l_sampling_event               GMD_SAMPLING_EVENTS%ROWTYPE;
	  l_results                      GMD_RESULTS%ROWTYPE;
	  l_spec_results                 GMD_SPEC_RESULTS%ROWTYPE;
	  l_event_spec_disp              GMD_EVENT_SPEC_DISP%ROWTYPE;

	  l_in_sampling_event            GMD_SAMPLING_EVENTS%ROWTYPE;
	  l_in_event_spec_disp           GMD_EVENT_SPEC_DISP%ROWTYPE;
	  l_out_results                  GMD_RESULTS%ROWTYPE;

	  -- Exceptions
	  e_results_insert_error         EXCEPTION;
	  e_spec_results_insert_error    EXCEPTION;
	  e_samples_fetch_error          EXCEPTION;
	  e_sampling_event_fetch_error   EXCEPTION;
	  e_event_spec_fetch_error       EXCEPTION;
    l_lab_organization_id          NUMBER;

    l_test_qty                     NUMBER;   -- 5353794
    l_test_qty_uom                 VARCHAR2(3); -- 5353794

    BEGIN

	  IF (l_debug = 'Y') THEN
	     gmd_debug.put_line('Entering Procedure: ADD_TESTS_TO_SAMPLE');
	  END IF;

	  --  Initialize API return status to success
	  x_return_status := FND_API.G_RET_STS_SUCCESS;

	  l_user_id  := FND_GLOBAL.user_id;
	  l_date     := SYSDATE;

	  -- Fetch the Sample Record
	  IF NOT (gmd_samples_pvt.fetch_row(
			 p_samples => p_sample,
			 x_samples => l_sample)
		 )
	  THEN
	    -- Fetch Error.
	    RAISE e_samples_fetch_error;
	  END IF;


	  -- Fetch the Sampling Event Record
	  l_in_sampling_event.sampling_event_id := l_sample.sampling_event_id;
	  IF NOT (gmd_sampling_events_pvt.fetch_row(
			 p_sampling_events => l_in_sampling_event,
			 x_sampling_events => l_sampling_event)
		 )
	  THEN
	    -- Fetch Error.
	    RAISE e_sampling_event_fetch_error;
	  END IF;

         -- Begin 3903309
	    OPEN c_get_sample_spec_disp (l_sample.sample_id) ;
	    FETCH c_get_sample_spec_disp INTO l_sample_spec_disp ;
	    CLOSE c_get_sample_spec_disp ;
         -- End 3903309

	  -- If the Event Spec is set to - Accept, Accept w/Variance
	  -- or Reject then you can not add sample anymore.
	  -- IF (l_sampling_event.disposition IN ('4A', '5AV', '6RJ')) THEN
	   IF (l_sample_spec_disp IN ('4A', '5AV', '6RJ')) THEN   -- 3903309
	    SELECT meaning
	    INTO   l_meaning
	    FROM   gem_lookups
	    WHERE  lookup_type = 'GMD_QC_SAMPLE_DISP'
	    AND    lookup_code = l_sample_spec_disp;  -- 3903309

	    GMD_API_PUB.Log_Message('GMD_CANT_ADD_TEST');
	    RAISE FND_API.G_EXC_ERROR;
	   END IF;

	  -- Fetch the Event Spec Record
	  IF p_event_spec_disp_id IS NOT NULL THEN
	    -- l_event_spec_disp.event_spec_disp_id := p_event_spec_disp_id;
	    l_in_event_spec_disp.event_spec_disp_id := p_event_spec_disp_id;
	    IF NOT (GMD_EVENT_SPEC_DISP_PVT.fetch_row(
			 p_event_spec_disp => l_in_event_spec_disp,
			 x_event_spec_disp => l_event_spec_disp)
		 )
	    THEN
	      -- Fetch Error.
	      RAISE e_event_spec_fetch_error;
	    END IF;
	  END IF;

    l_lab_organization_id := l_sample.organization_id;

	  l_seq      := 0;

	  IF (l_debug = 'Y') THEN
	     gmd_debug.put_line('Total Number of tests to be added: '|| p_test_ids.COUNT);
	  END IF;

	  -- Go through all the tests
	  FOR i in 1..p_test_ids.COUNT
	  LOOP
	    -- Set the varibles for new test
	    l_additional_test_ind := NULL;
	    l_replicate           := 0;
	    l_viability_duration  := 0;
	    l_resources           := NULL;

	    SELECT test_type
	    INTO   l_test_type
	    FROM   gmd_qc_tests_b
	    WHERE  test_id = p_test_ids(i)
	    ;

	    IF (l_debug = 'Y') THEN
	       gmd_debug.put_line('Working on Test ID: ' || p_test_ids(i) || ' Type: ' || l_test_type);
	    END IF;
	    IF (l_test_type = 'E') THEN

	 /*     -- If the test we are adding is Expression then make sure that it is not
	      -- there alrady
	      OPEN c_res_test(l_sample.sample_id, p_test_ids(i));
	      FETCH c_res_test INTO dummy;
	      IF c_res_test%FOUND THEN
		IF (l_debug = 'Y') THEN
		  gmd_debug.put_line('Expression Test is already in the result set. Abort.');
		END IF;
		CLOSE c_res_test;
		GMD_API_PUB.Log_Message('GMD_EXP_TEST_IS_THERE');
		RAISE FND_API.G_EXC_ERROR;
	      END IF;
	      CLOSE c_res_test; */

	      -- If the test we are adding is Expression then make sure that all the
	      -- reference tests are added before
	      IF NOT all_ref_tests_exist_in_sample(p_sample_id => l_sample.sample_id,
						   p_test_id   => p_test_ids(i))
	      THEN
		IF (l_debug = 'Y') THEN
		  gmd_debug.put_line('Some of the reference tests are missing from the result set. Abort.');
		END IF;
		GMD_API_PUB.Log_Message('GMD_REF_TESTS_MISSING');
		RAISE FND_API.G_EXC_ERROR;
	      END IF;

	    END IF; -- l_test_type = 'E'

	    -- Find out that the test we are adding is an additional_test for the Spec.
	    IF (l_event_spec_disp.spec_id IS NOT NULL) THEN
	      IF NOT gmd_spec_grp.spec_test_exist
		     (  p_spec_id => l_event_spec_disp.spec_id
		      , p_test_id => p_test_ids(i)
		     )
	      THEN
		-- The test is not part of the Spec
		l_additional_test_ind      := 'Y';
	      END IF;
	    ELSE
	      -- Since there is no Spec, all the tests are additional
	      l_additional_test_ind      := 'Y';
	    END IF;
	    IF (l_debug = 'Y') THEN
	       gmd_debug.put_line('The additional test indicator is (Y/NULL): ' || l_additional_test_ind);
	    END IF;


	    -- Now Construct GMD_RESULTS record

	    -- For this, gather required information in local varaibles

	    -- 1. Get the next test_replicate_cnt
	    SELECT NVL(MAX(test_replicate_cnt), 0) + 1
	    INTO   l_next_test_replicate_cnt
	    FROM   gmd_results
	    WHERE  sample_id = l_sample.sample_id
	    AND    test_id   = p_test_ids(i)
	    ;

	    -- 2. Get the test_kit_item_id
	    -- Bug 3088216: added test_method
            OPEN c_test_method(p_test_ids(i));
            FETCH c_test_method INTO l_test_kit_inv_item_id,
                                     l_replicate,
                                     l_test_method_id,
                                     l_test_qty,     -- 5353784
                                     l_test_qty_uom  -- 5353784
                                     ;
            CLOSE c_test_method;
            IF (l_debug = 'Y') THEN
               gmd_debug.put_line('Replicate from Test Method: ' || l_replicate);
            END IF;

    -- 3. If this is not an additional test then get the replicate override
    --    from the Spec
    IF (l_additional_test_ind IS NULL) THEN
      -- Test is part of the Spec so get the replicate from spec.
      SELECT st.test_replicate, st.viability_duration, tm.resources
      INTO   l_replicate,l_viability_duration, l_resources
      FROM   gmd_spec_tests_b st, gmd_test_methods_b tm
      WHERE  st.spec_id = l_event_spec_disp.spec_id
      AND    st.exclude_ind IS NULL
      AND    st.test_id = p_test_ids(i)
      AND    st.test_method_id = tm.test_method_id
      ;
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('Since the test is in Spec the Replicate from Spec: ' || l_replicate);
         gmd_debug.put_line('Viability Duration in seconds: ' || l_viability_duration);
      END IF;
    END IF;

    -- 3.5 If this is an expression, make sure the replicate = 1
    --     The form is supposed to stop an expression from using a
    --     method with >1 replicate.  It is not working, yet, so
    --     here is the double check.  LeAta  07Nov2002
    IF (l_test_type = 'E') THEN
      l_replicate := 1;
    END IF;            -- end if an expression, replicate = 1

    -- 4. Get the next sequence
    l_seq := next_seq_in_result(l_sample.sample_id, p_test_ids(i));

    l_results.sample_id                     := l_sample.sample_id;
    l_results.test_id                       := p_test_ids(i);
    l_results.test_replicate_cnt            := l_next_test_replicate_cnt;
    l_results.lab_organization_id           := l_lab_organization_id;
    l_results.test_kit_inv_item_id          := l_test_kit_inv_item_id;
    l_results.seq                           := l_seq;
    l_results.delete_mark                   := 0;
    l_results.creation_date                 := l_date;
    l_results.created_by                    := l_user_id;
    l_results.last_updated_by               := l_user_id;
    l_results.last_update_date              := l_date;
    l_results.planned_resource              := l_resources;

      -- BUG 3088216: added test qty, test uom and test method id to results table
      -- 5353794 - use from test Method if there
    IF l_test_qty > 0
     then
         l_results.test_qty                      := l_test_qty;
    else
    	 l_results.test_qty                      := p_test_qty;
    END IF;
    IF l_test_qty_uom  IS not null
     then
         l_results.test_qty_uom                  := l_test_qty_uom;
    else
    	 l_results.test_qty_uom                  := p_test_qty_uom;
    END IF;


    l_results.test_method_id                := l_test_method_id;

    IF (nvl(l_viability_duration,0)  > 0 ) THEN
      l_results.test_by_date                  := l_sample.date_drawn
                                                  + l_viability_duration/(60*60*24);
    END IF;

    -- Now, Construct GMD_SPEC_RESULTS record
    l_spec_results.event_spec_disp_id       := p_event_spec_disp_id;
    l_spec_results.additional_test_ind      := l_additional_test_ind;
    l_spec_results.delete_mark              := 0;
    l_spec_results.creation_date            := l_date;
    l_spec_results.created_by               := l_user_id;
    l_spec_results.last_updated_by          := l_user_id;
    l_spec_results.last_update_date         := l_date;

    -- We are ready with Result and Spec Result record, so lets
    -- insert them l_replicate times.
    FOR i IN 1..l_replicate
    LOOP
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('Inserting test for replicate: ' || l_results.TEST_REPLICATE_CNT);
      END IF;
      -- We are ready for insert in GMD_RESULTS, so then lets do it.
      IF NOT(GMD_RESULTS_PVT.Insert_Row(
                    p_results => l_results,
                    x_results => l_out_results)
            )
      THEN
        -- Insert Error
        RAISE e_results_insert_error;
      END IF;
      l_results.RESULT_ID := l_out_results.RESULT_ID;

      -- Increment Serial Counter for OUT variables
      out_var_idx := out_var_idx + 1;

      x_results_tab(out_var_idx) := l_results;
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('Result record inserted, Result ID: ' || l_results.RESULT_ID);
      END IF;

      -- Assign the result_id to Spec Result record
      l_spec_results.RESULT_ID                := l_results.RESULT_ID;

      -- We are ready for insert in GMD_SPEC_RESULTS, so then lets do it.
      IF NOT(GMD_SPEC_RESULTS_PVT.Insert_Row(p_spec_results => l_spec_results))
      THEN
        -- Insert Error
        RAISE e_spec_results_insert_error;
      END IF;

      x_spec_results_tab(out_var_idx) := l_spec_results;

      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('Spec Result record inserted');
      END IF;

      -- Now increment the l_next_test_replicate_cnt
      l_results.TEST_REPLICATE_CNT := l_results.TEST_REPLICATE_CNT + 1;
    END LOOP;

    -- Set the flad to indicate that a new test is added to the result set.
    l_test_added_flag := TRUE;

  END LOOP;  -- All the tests

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('All the tests are added. Setting *In Progress* flags');
  END IF;

  --  M.Grosser 04-May-2006:  BUG 5167171 - Forward Port of BUG 5097450
  --            Modified code to prevent the setting of sample disposition
  --            to In Progress on the addition of a test if the current
  --            disposition is Pending
  --
  IF (l_test_added_flag AND l_sample_spec_disp <> '1P') THEN
    -- Now that we added a new test to the sample, the
    -- disposition of the sample must be set back to "In Progress"

    -- B3005589 The sample disposition is stored in gmd_sample_spec_disp.
    --          So the following update is not required.
    -- UPDATE gmd_samples
    -- SET    sample_disposition = '2I',
    --        last_updated_by = l_user_id,
    --        last_update_date = l_date
    -- WHERE  sample_id = l_sample.sample_id
    -- ;

    -- Set the disposition of the sample spec disp
    -- back to "In Progress"
    UPDATE gmd_sample_spec_disp
    SET    disposition = '2I',
           last_updated_by = l_user_id,
           last_update_date = l_date
    WHERE  event_spec_disp_id = p_event_spec_disp_id
    AND    sample_id = l_sample.sample_id
    ;

    IF (l_event_spec_disp.disposition <> '2I') THEN
      -- Set the disposition of the Event spec disp
      -- back to "In Progress"
      UPDATE gmd_event_spec_disp
      SET    disposition = '2I',
             last_updated_by = l_user_id,
             last_update_date = l_date
      WHERE  event_spec_disp_id = p_event_spec_disp_id
      ;
    END IF;

    -- Set the disposition of the Sampling Event
    -- back to "In Progress"
    -- Also set recomposite_ind to 'Y' since we modified the sampling event
    -- by adding a new test
    UPDATE gmd_sampling_events
    SET    disposition = '2I',
	   recomposite_ind = 'Y',
           last_updated_by = l_user_id,
           last_update_date = l_date
    WHERE  sampling_event_id = l_sample.sampling_event_id
    ;

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Setting *In Progress* flags completed.');
    END IF;
  END IF;

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('Leaving procedure: ADD_TESTS_TO_SAMPLE');
  END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR  OR
       e_results_insert_error OR
       e_spec_results_insert_error OR
       e_samples_fetch_error OR
       e_event_spec_fetch_error OR
       e_sampling_event_fetch_error
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR',
                            'PACKAGE','ADD_TESTS_TO_SAMPLE',
                            'ERROR', SUBSTR(SQLERRM,1,100));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END add_tests_to_sample;



--Start of comments
--+========================================================================+
--| API Name    : next_seq_in_result                                       |
--| TYPE        : Group                                                    |
--| Notes       : This function returns the next sequence for the test     |
--|               in the result set for a given test of sample.            |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	21-Aug-2002	Created.                           |
--|                                                                        |
--+========================================================================+
-- End of comments

FUNCTION next_seq_in_result
(
  p_sample_id NUMBER
, p_test_id   NUMBER
)
RETURN NUMBER IS

  CURSOR c_seq IS
  SELECT seq
  FROM   gmd_results
  WHERE  sample_id = p_sample_id
  AND    test_id   = p_test_id
  ;

  l_seq   NUMBER := 10;

BEGIN

  OPEN c_seq;
  FETCH c_seq INTO l_seq;
  IF c_seq%NOTFOUND THEN

    -- The test is not part of result set, so get the new seq
    SELECT (floor(nvl(max(seq),0) / 10) * 10) + 10
    INTO   l_seq
    FROM   gmd_results
    WHERE  sample_id = p_sample_id
    ;

  END IF;

  CLOSE c_seq;

  return l_seq;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 10;
END next_seq_in_result;



--Start of comments
--+========================================================================+
--| API Name    : all_ref_tests_exist_in_sample                            |
--| TYPE        : Group                                                    |
--| Notes       : This function returns TRUE if all the reference tests    |
--|               for the given test are already part of sample, FALSE     |
--|               otherwise.                                               |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	11-Oct-2002	Created.                           |
--|                                                                        |
--+========================================================================+
-- End of comments

FUNCTION all_ref_tests_exist_in_sample
(
  p_sample_id IN NUMBER
, p_test_id   IN NUMBER
) RETURN BOOLEAN IS

  -- Cursors
  CURSOR c_ref_tests(p_sample_id NUMBER, p_test_id NUMBER) IS
  SELECT 1
  FROM   gmd_qc_test_values_b tv
  WHERE  tv.test_id = p_test_id
  AND    tv.expression_ref_test_id NOT IN
    (SELECT test_id
     FROM   gmd_results
     WHERE  sample_id = p_sample_id)
  ;

  -- Local Variables
  dummy       PLS_INTEGER;

BEGIN
  -- See if any of the reference test is missing
  OPEN c_ref_tests(p_sample_id, p_test_id);
  FETCH c_ref_tests INTO dummy;
  IF c_ref_tests%FOUND THEN
    CLOSE c_ref_tests;
    RETURN FALSE;
  END IF;
  CLOSE c_ref_tests;

  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END all_ref_tests_exist_in_sample;



--Start of comments
--+========================================================================+
--| API Name    : add_test_to_samples                                      |
--| TYPE        : Group                                                    |
--| Notes       : This function received as input table of sample IDs to   |
--|               which a given test is to be added.                       |
--|                                                                        |
--|               The function will insert rows into GMD_RESULTS and       |
--|               GMD_SPEC_RESULTS with the specified test for each Sample.|
--|                                                                        |
--|               THIS ROUTINE RE-USES THE ROUTINE ADD_TESTS_TO_SAMPLE     |
--|               BY ADDING ONE TEST TO ONE SAMPLE AT A TIME.              |
--|                                                                        |
--| PARAMETERS  :                                                          |
--|                                                                        |
--| 1. p_samples - Table of Sample IDs in which the test is to be added.   |
--| 2. p_test_id - Test ID which is to be added to all the samples.        |
--| 3. p_event_spec_disp_id  - Event Spec                                  |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	21-Aug-2002	Created.                           |
--|                                                                        |
--|    Susan Feinstein  11-AUG-2003     Bug 3088216: Added test_uom,       |
--|                                      test_qty                          |
--+========================================================================+
-- End of comments
PROCEDURE add_test_to_samples
(
  p_sample_ids         IN         GMD_API_PUB.number_tab
, p_test_id            IN         NUMBER
, p_event_spec_disp_id IN         NUMBER
, x_results_tab        OUT NOCOPY GMD_API_PUB.gmd_results_tab
, x_spec_results_tab   OUT NOCOPY GMD_API_PUB.gmd_spec_results_tab
, x_return_status      OUT NOCOPY VARCHAR2
, p_test_qty           IN         NUMBER   DEFAULT NULL
, p_test_qty_uom           IN         VARCHAR2 DEFAULT NULL
)
IS

  -- Local Variables
  l_sample                      GMD_SAMPLES%ROWTYPE;
  l_test_ids                    GMD_API_PUB.number_tab;
  l_results_tab                 GMD_API_PUB.gmd_results_tab;
  l_spec_results_tab            GMD_API_PUB.gmd_spec_results_tab;

  l_return_status               VARCHAR2(1);

BEGIN

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('Entering Procedure ADD_TEST_TO_SAMPLES');
  END IF;
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Since we are going to insert the same test to all
  -- the samples assign the test to table of test IDs
  l_test_ids(1) := p_test_id;

  -- Go thorugh all the Sample IDs
  FOR i in 1..p_sample_ids.COUNT
  LOOP

    l_sample.sample_id := p_sample_ids(i);

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Going to add test ID: ' || l_test_ids(1) || ' in Sample ID: ' || l_sample.sample_id);
    END IF;

    -- Now we have all the parameters ready for routine add_tests_to_sample
    add_tests_to_sample(
      p_sample             => l_sample
    , p_test_ids           => l_test_ids
    , p_event_spec_disp_id => p_event_spec_disp_id
    , p_test_qty           => p_test_qty
    , p_test_qty_uom       => p_test_qty_uom
    , x_results_tab        => l_results_tab
    , x_spec_results_tab   => l_spec_results_tab
    , x_return_status      => l_return_status);

    IF l_return_status <> 'S' THEN
      -- Message must have been logged so just raise an exception.
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Ttest ID: ' || l_test_ids(1) || ' is added to Sample ID: ' || l_sample.sample_id);
    END IF;

    -- If success then assign the OUT variables received
    x_results_tab(i)      := l_results_tab(1);
    x_spec_results_tab(i) := l_spec_results_tab(1);

  END LOOP;

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('Leaving Procedure ADD_TEST_TO_SAMPLES');
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR',
                            'PACKAGE','ADD_TEST_TO_SAMPLES',
                            'ERROR', SUBSTR(SQLERRM,1,100));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


END add_test_to_samples;


--Start of comments
--+========================================================================+
--| API Name    : make_target_spec_the_base_spec                           |
--| TYPE        : Group                                                    |
--| Notes       : This procedure is to make the target spec as the base    |
--|               spec for a given sample.                                 |
--|                                                                        |
--|               This procedure will first create any missing replicate   |
--|               of the tests for the target spec in gmd_results. Then    |
--|               create a row in GMD_EVENT_SPEC_DISP and a row in         |
--|               GMD_SAMPLE_SPEC_DISP and a set of rows in                |
--|               GMD_SPEC_RESULTS                                         |
--|                                                                        |
--|                                                                        |
--| PARAMETERS  :                                                          |
--|                                                                        |
--| 1. p_sample_id - Sample ID for which we are changing the base spec.    |
--| 2. p_target_spec_id - Spec ID which will become base spec.             |
--| 3. p_target_spec_cr_id - Spec VR ID which will become base spec VR.    |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	21-Aug-2002	Created.                           |
--|                                                                        |
--|    Chetan Nagar	01-Apr-2002	Added exclude_ind column condition |
--|       in select for table - gmd_spec_tests_b                           |
--|                                                                        |
--|   RLNAGARA          07-Feb-2006     Modified the cursor c_vrs_vw and get_organization_code. |
--|   RLNAGARA   19-MAY-2006 Bug#5220513 (FP of 5026764)
--|          Added code so as to re-evaluate the results against the target |
--|     spec and change the evaluations of results appropriately.          |
--+========================================================================+
-- End of comments

PROCEDURE make_target_spec_the_base_spec
(
  p_sample_id          IN NUMBER
, p_target_spec_id     IN NUMBER
, p_target_spec_vr_id  IN NUMBER
, x_return_status      OUT NOCOPY VARCHAR2
)
IS

  -- Cursors
  CURSOR c_gmd_results (p_sample_id NUMBER) IS
  SELECT result_id,
         test_id,
         result_value_num,
         result_value_char,
         result_date              --Bug 5220513
  FROM   gmd_results
  WHERE  sample_id = p_sample_id
  ;

  CURSOR c_spec_tests (p_spec_id NUMBER) IS
  SELECT   st.test_id
         , st.test_replicate
         , tm.test_kit_inv_item_id
  FROM   gmd_spec_tests_b st, gmd_test_methods_b tm
  WHERE  st.spec_id = p_spec_id
  AND    st.exclude_ind IS NULL
  AND    st.test_method_id =  tm.test_method_id
  ;

--RLNAGARA Bug # 4918820 Changed the view from gmd_all_spec_vrs to gmd_com_spec_vrs_vl
  CURSOR c_vrs_vw (p_spec_vr_id NUMBER) IS
  SELECT spec_id
  FROM   gmd_com_spec_vrs_vl
  WHERE  spec_vr_id = p_spec_vr_id
  ;

  CURSOR c_event_spec (p_sampling_event_id NUMBER, p_spec_vr_id NUMBER) IS
  SELECT *
  FROM   gmd_event_spec_disp
  WHERE  sampling_event_id = p_sampling_event_id
  AND    spec_vr_id = p_spec_vr_id
  AND    spec_used_for_lot_attrib_ind = 'Y'
  ;

--Begin Bug#5220513
   l_test_id 		GMD_QC_TESTS.test_id%TYPE;
   l_spec_id 		gmd_spec_tests_b.spec_id%TYPE;

  CURSOR c_evaluation_ind (p_result_id NUMBER, p_event_spec_disp_id NUMBER) IS
  SELECT evaluation_ind  from gmd_spec_results gsr, gmd_event_spec_disp  esd --, gmd_sample_spec_disp ssd
  WHERE gsr.result_id=p_result_id
  AND esd.event_spec_disp_id=p_event_spec_disp_id
  AND gsr.event_spec_disp_id=esd.event_spec_disp_id;


  CURSOR c_event_spec_disp_id (p_sample_id NUMBER) IS
  SELECT esd.event_spec_disp_id from gmd_event_spec_disp  esd, gmd_sample_spec_disp ssd
  WHERE ssd.sample_id=p_sample_id
  AND esd.event_spec_disp_id=ssd.event_spec_disp_id
  AND esd.spec_used_for_lot_attrib_ind = 'Y';

  CURSOR c_get_type IS
      SELECT  t.test_type, t.test_code, t.test_method_id, t.expression, t.test_unit,
      	      m.test_method_code
      FROM    gmd_qc_tests_b t , gmd_test_methods_b m
      WHERE   t.test_id = l_test_id
      AND     t.test_method_id = m.test_method_id;

  LocalTypeRec	c_get_type%ROWTYPE;

  CURSOR c_get_display IS
    SELECT  v.display_label_numeric_range
    FROM    gmd_qc_test_values v
    WHERE   v.test_id = l_test_id;

  LocalDisRec   c_get_display%ROWTYPE;

  CURSOR c_get_spec_test_num IS
      SELECT  s.min_value_num, s.max_value_num, s.target_value_num,s.display_precision
      FROM    gmd_spec_tests_b s
      WHERE   s.spec_id = l_spec_id
      AND     s.test_id = l_test_id
      AND     s.exclude_ind IS NULL;

  LocalNumRec   c_get_spec_test_num%ROWTYPE;

  CURSOR c_get_spec_test_char IS
      SELECT  s.min_value_char, s.max_value_char, s.target_value_char
      FROM    gmd_spec_tests_b s
      WHERE   s.spec_id = l_spec_id
      AND     s.test_id = l_test_id
      AND     s.exclude_ind IS NULL;

      LocalCharRec   c_get_spec_test_char%ROWTYPE;

   CURSOR   c_spec_test_all (p_spec_id NUMBER, p_test_id NUMBER) IS
    SELECT  *
    FROM   gmd_spec_tests_b
    WHERE  spec_id = p_spec_id
    AND    test_id = p_test_id
   ;


  -- Local Variables
  x_rec                      result_data;
  old_event_spec_disp_id     NUMBER;
  l_spec_test_all            GMD_SPEC_TESTS_B%ROWTYPE;

  --End Bug#5220513

--RLNAGARA Bug 4918820 Changed from mtl_organizations to mtl_parameters
  CURSOR get_organization_code (l_organization_id NUMBER) IS
  SELECT organization_code
  FROM mtl_parameters
  WHERE organization_id = l_organization_id;

  -- Local Variables
  l_user_id                  NUMBER;
  l_date                     DATE;
  l_curr_replicate_cnt       PLS_INTEGER;
  l_missing_cnt              PLS_INTEGER;
  l_return_status            VARCHAR2(1);

  l_change_disp_to           VARCHAR2(3);
  l_message_data             VARCHAR2(2000);

  l_test_ids                 GMD_API_PUB.number_tab;
  l_results_tab              GMD_API_PUB.gmd_results_tab;
  l_spec_results_tab         GMD_API_PUB.gmd_spec_results_tab;

  l_event_spec_disp          GMD_EVENT_SPEC_DISP%ROWTYPE;
  l_sample_spec_disp         GMD_SAMPLE_SPEC_DISP%ROWTYPE;
  l_spec_result              GMD_SPEC_RESULTS%ROWTYPE;
  l_sample                   GMD_SAMPLES%ROWTYPE;

  l_in_sample                GMD_SAMPLES%ROWTYPE;
  l_out_event_spec_disp      GMD_EVENT_SPEC_DISP%ROWTYPE;

  -- Exceptions
  e_sample_fetch_error           EXCEPTION;
  e_event_spec_disp_insert_error EXCEPTION;
  e_sample_spec_disp_insert_err  EXCEPTION;
  e_spec_results_insert_error    EXCEPTION;
  l_organization_code         mtl_organizations.organization_code%TYPE;



BEGIN

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('Entering Procedure - MAKE_TARGET_SPEC_THE_BASE_SPEC');
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Make sure we have the sample record
  -- l_sample.sample_id := p_sample_id;
  l_in_sample.sample_id := p_sample_id;
  IF NOT (GMD_SAMPLES_PVT.fetch_row(
                   p_samples => l_in_sample,
                   x_samples => l_sample)
         )
  THEN
    -- Fetch Error.
    RAISE e_sample_fetch_error;
  END IF;


  IF (l_debug = 'Y') THEN

    OPEN get_organization_code(l_sample.organization_id);
    FETCH get_organization_code into l_organization_code;
    CLOSE get_organization_code;

     gmd_debug.put_line('  Changing base spec for Sample ID - ' || l_sample.sample_id ||
                      ' Sample No - ' || l_organization_code
                                      || '-' || l_sample.sample_no ||
                      ' to Target Spec - ' || p_target_spec_id ||
                      ' Target Spec VR - ' || p_target_spec_vr_id);
  END IF;

  --Bug#5220513
  OPEN  c_event_spec_disp_id(l_sample.sample_id);
  FETCH c_event_spec_disp_id INTO old_event_spec_disp_id;
  CLOSE c_event_spec_disp_id;
--Bug#5220513

  -- Check that sample is not "Retain"
  --  Bug 3079877: Check that sample is not "Planning"
  IF (l_sample.sample_disposition = '0RT')
   AND (l_sample.sample_disposition = '0PL') THEN
       -- For retain sample no comparison, please!
     GMD_API_PUB.Log_Message('GMD_RETAIN_SAMPLE');
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Check that we have the Sampling Event
  -- Now, even in case where there is no Spec for the sample
  -- there still should be a sampling event as per new directions.
  IF (l_sample.sampling_event_id IS NULL) THEN
    GMD_API_PUB.Log_Message('GMD_SAMPLING_EVENT_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- All the required validations are over so let's start
  -- doing some REAL work.

  -- Get the user ID
  IF l_sample.created_by IS NULL THEN
    l_user_id  := FND_GLOBAL.user_id;
  ELSE
    l_user_id  := l_sample.created_by;
  END IF;

  l_date     := SYSDATE;

  OPEN c_event_spec (l_sample.sampling_event_id, p_target_spec_vr_id);
  FETCH c_event_spec INTO l_event_spec_disp;
  IF c_event_spec%NOTFOUND THEN
    -- Since the new spec is going to be the current one, change
    -- all the previous ones to NOT Current
    UPDATE gmd_event_spec_disp
    set    spec_used_for_lot_attrib_ind = NULL
    where  sampling_event_id = l_sample.sampling_event_id
    and    spec_used_for_lot_attrib_ind = 'Y'
    ;

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('  Updated all previous gmd_event_spec_disp to NOT-Current.');
    END IF;

    -- Create a new record in GMD_EVENT_SPEC_DISP for the Target Spec

    -- Construct the record
    l_event_spec_disp.SAMPLING_EVENT_ID            := l_sample.sampling_event_id;
    l_event_spec_disp.SPEC_ID                      := p_target_spec_id;
    l_event_spec_disp.SPEC_VR_ID                   := p_target_spec_vr_id;
    l_event_spec_disp.DISPOSITION                  := '1P';

    -- We need to see if we can default something here
    -- New record gets - Y
    l_event_spec_disp.SPEC_USED_FOR_LOT_ATTRIB_IND := 'Y';

    l_event_spec_disp.DELETE_MARK                  := 0;
    l_event_spec_disp.CREATION_DATE                := l_date;
    l_event_spec_disp.CREATED_BY                   := l_user_id;
    l_event_spec_disp.LAST_UPDATE_DATE             := l_date;
    l_event_spec_disp.LAST_UPDATED_BY              := l_user_id;

    -- We are ready for insert in GMD_EVENT_SPEC_DISP, so then lets do it.
    IF NOT(GMD_EVENT_SPEC_DISP_PVT.Insert_Row(
                    p_event_spec_disp => l_event_spec_disp,
                    x_event_spec_disp => l_out_event_spec_disp)
            )
    THEN
      -- Insert Error
      RAISE e_event_spec_disp_insert_error;
    END IF;
    l_event_spec_disp.EVENT_SPEC_DISP_ID := l_out_event_spec_disp.EVENT_SPEC_DISP_ID;

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('  A new record is created in GMD_EVENT_SPEC_DISP. ID - ' || l_event_spec_disp.event_spec_disp_id);
    END IF;

  END IF;
  CLOSE c_event_spec;

  -- Create a record in GMD_SAMPLE_SPEC_DISP for the Target Spec

  -- Construct the record
  l_sample_spec_disp.EVENT_SPEC_DISP_ID           := l_event_spec_disp.event_spec_disp_id;
  l_sample_spec_disp.SAMPLE_ID                    := l_sample.sample_id;
  l_sample_spec_disp.DISPOSITION                  := '1P';
  l_sample_spec_disp.DELETE_MARK                  := 0;
  l_sample_spec_disp.CREATION_DATE                := l_date;
  l_sample_spec_disp.CREATED_BY                   := l_user_id;
  l_sample_spec_disp.LAST_UPDATE_DATE             := l_date;
  l_sample_spec_disp.LAST_UPDATED_BY              := l_user_id;

  -- We are ready for insert, so then lets do it.
  IF NOT(GMD_SAMPLE_SPEC_DISP_PVT.Insert_Row(
                  p_sample_spec_disp => l_sample_spec_disp)
          )
  THEN
    -- Insert Error
    RAISE e_sample_spec_disp_insert_err;
  END IF;

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('  A new record is created in GMD_SAMPLE_SPEC_DISP.');
     gmd_debug.put_line('  Now duplicate all current GMD_SPEC_RESULTS under new Spec.');
  END IF;

  -- Create a set of records in GMD_SPEC_RESULTS for the target Spec
  -- In this run we are just creating records for all the results
  -- that are there in GMD_RESULTS
  FOR l_res IN c_gmd_results(l_sample.sample_id)
  LOOP

    -- Construct GMD_SPEC_RESULTS Record
    l_spec_result.EVENT_SPEC_DISP_ID       := l_event_spec_disp.event_spec_disp_id;
    l_spec_result.RESULT_ID                := l_res.result_id;

    --Bug#5220513
    OPEN c_evaluation_ind(l_res.result_id,old_event_spec_disp_id);
    FETCH  c_evaluation_ind INTO l_spec_result.evaluation_ind;
    CLOSE c_evaluation_ind;
    --Bug#5220513

    -- B2993072 Initialize the indicators
    l_spec_result.ADDITIONAL_TEST_IND      := NULL;
    l_spec_result.IN_SPEC_IND              := NULL;

    -- When we create Spec Result rows for the new Spec we need to check if
    -- the test is additional for the Target Spec or Not.
    IF (p_target_spec_id IS NOT NULL) THEN
      IF NOT gmd_spec_grp.spec_test_exist
             (  p_spec_id => p_target_spec_id
              , p_test_id => l_res.test_id
             )
      THEN
        -- The test is not in the Target Spec so it becomes Additional
        l_spec_result.ADDITIONAL_TEST_IND      := 'Y';
      ELSE
       -- Begin Bug#5220513
      x_rec.result := NULL;
      IF l_res.result_value_num IS NOT NULL THEN
        x_rec.result_num := l_res.result_value_num;
        x_rec.result := l_res.result_value_num;
        x_rec.result_date := l_res.result_date;
      END IF;

      IF l_res.result_value_char IS NOT NULL THEN
         x_rec.result_char := l_res.result_value_char;
         x_rec.result := l_res.result_value_char;
         x_rec.result_date := l_res.result_date;
      END IF;
      l_test_id := l_res.test_id;
      x_rec.test_id := l_test_id;

      -- For each test type get the test and method info
      OPEN c_get_type;
      FETCH c_get_type INTO LocalTypeRec;
      x_rec.test_type := LocalTypeRec.test_type;
      x_rec.test_code := LocalTypeRec.test_code;
      x_rec.expression := LocalTypeRec.expression;
      x_rec.unit := LocalTypeRec.test_unit;
      x_rec.method := LocalTypeRec.test_method_code;
      CLOSE c_get_type;

      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('Retrieved Test and Method info:');
         gmd_debug.put_line('  Test: ' || LocalTypeRec.test_code || ' Method: ' ||  LocalTypeRec.test_method_code);
      END IF;

      l_spec_id := p_target_spec_id;
      x_rec.spec_id       := l_spec_id;
      OPEN c_get_spec_test_num;
      FETCH c_get_spec_test_num INTO LocalNumRec;
      IF c_get_spec_test_num%FOUND THEN
        x_rec.spec_target_num := LocalNumRec.target_value_num;
  	    x_rec.spec_min_num := LocalNumRec.min_value_num;
    	x_rec.spec_max_num := LocalNumRec.max_value_num;
    	  --Fetching the display precision into table type.
   	    x_rec.spec_display_precision:=LocalNumRec.display_precision;
    	x_rec.display_precision := x_rec.spec_display_precision;
    	x_rec.report_precision := x_rec.spec_display_precision;
      END IF;
      CLOSE c_get_spec_test_num;
      IF LocalTypeRec.test_type IN ('V', 'T', 'L', 'E','U') THEN
        OPEN c_get_spec_test_char;
        FETCH c_get_spec_test_char INTO LocalCharRec;
        IF c_get_spec_test_char%FOUND THEN
          x_rec.spec_target_char := LocalCharRec.target_value_char;
 	      x_rec.spec_min_char := LocalCharRec.min_value_char;
          x_rec.spec_max_char := LocalCharRec.max_value_char;
        END IF;
        CLOSE c_get_spec_test_char;
      END IF;

      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('Got the Test and Spec info');
      END IF;

      OPEN c_spec_test_all(l_spec_id, l_test_id);
      FETCH c_spec_test_all INTO l_spec_test_all;
      CLOSE c_spec_test_all;

    x_rec.spec_min_num := l_spec_test_all.min_value_num;
    x_rec.spec_max_num := l_spec_test_all.max_value_num;
    x_rec.out_action_code := l_spec_test_all.out_of_spec_action;
    x_rec.exp_error_type  := l_spec_test_all.exp_error_type;
    x_rec.below_spec_min := l_spec_test_all.below_spec_min;
    x_rec.above_spec_min := l_spec_test_all.above_spec_min;
    x_rec.below_spec_max := l_spec_test_all.below_spec_max;
    x_rec.above_spec_max := l_spec_test_all.above_spec_max;
    x_rec.below_min_action_code := l_spec_test_all.below_min_action_code;
    x_rec.above_min_action_code := l_spec_test_all.above_min_action_code;
    x_rec.below_max_action_code := l_spec_test_all.below_max_action_code;
    x_rec.above_max_action_code := l_spec_test_all.above_max_action_code;

        -- Since the test is part of the Spec we can derive if it is IN-SPEC
        l_spec_result.IN_SPEC_IND          := rslt_is_in_spec
                                              (p_spec_id         => p_target_spec_id,
                                               p_test_id         => l_res.test_id,
                                               p_rslt_value_num  => l_res.result_value_num,
                                               p_rslt_value_char => l_res.result_value_char
                                              );

         x_rec.in_spec := l_spec_result.IN_SPEC_IND;

       -- 9282975 (12.1.1 ct bug - using triple checkin )  Added this condition to round it only if result is in number not for char result.
  	   IF l_res.result_value_num IS NOT NULL THEN
		 	     x_rec.value_in_report_prec := ROUND(to_number(x_rec.result),x_rec.report_precision);
    	     x_rec.result_num := ROUND(to_number(x_rec.result) ,x_rec.display_precision);
           x_rec.result := ROUND(to_number(x_rec.result) ,x_rec.display_precision);
       END IF;


        IF x_rec.test_type in ('N', 'L', 'E') THEN
           GMD_RESULTS_GRP.check_experimental_error  ( x_rec
                                                , l_return_status );
    	    IF (l_return_status <> 'S') THEN
        	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	        END IF;
        END IF;

    	IF  x_rec.additional_test_ind IS NULL AND
      		x_rec.exp_error_type IS NULL AND
	       (x_rec.in_spec <> 'Y' OR x_rec.in_spec IS NULL )  THEN
      		x_rec.out_of_spec := 'TRUE';
	        x_rec.result_action_code := x_rec.out_action_code;
    	END IF;          -- end if result falls in either of the fuzzy zones


	    IF x_rec.in_fuzzy_zone = 'TRUE' THEN
    	  x_rec.evaluation_ind := '3E';
	    ELSIF (x_rec.in_spec ='Y') THEN
	      x_rec.evaluation_ind := '0A';
        ELSE
      		IF x_rec.out_of_spec = 'FALSE' THEN
	        	x_rec.result_action_code := NULL;
    		END IF;
            x_rec.evaluation_ind := NULL;
    END IF;    --  end setting evaluation ind.
    	  l_spec_result.evaluation_ind := x_rec.evaluation_ind ;

    	  -- End Bug#5220513

	 -- B2993072
         -- Since the result is in spec, it is also 'ACCEPT' for the evaluation
--         l_spec_result.evaluation_ind      := '0A';    Bug5220513 Commented this line

      END IF;
    ELSE
      l_spec_result.ADDITIONAL_TEST_IND      := 'Y';
    END IF;


    l_spec_result.DELETE_MARK              := 0;
    l_spec_result.CREATION_DATE            := l_date;
    l_spec_result.CREATED_BY               := l_user_id;
    l_spec_result.LAST_UPDATED_BY          := l_user_id;
    l_spec_result.LAST_UPDATE_DATE         := l_date;

    -- We are ready for insert in GMD_SPEC_RESULTS, so then lets do it.
    IF NOT(GMD_SPEC_RESULTS_PVT.Insert_Row(p_spec_results => l_spec_result))
    THEN
      -- Insert Error
      RAISE e_spec_results_insert_error;
    END IF;

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('    A duplicate record is created in GMD_SPEC_RESULTS for Result ID - ' || l_res.result_id);
    END IF;

  END LOOP; -- For all the existing results

  -- Now create rows in GMD_RESULTS and GMD_SPEC_RESULTS for
  -- the tests that are missing and are part of the Target Spec

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('  Now create rows in GMD_RESULTS and GMD_SPEC_RESULTS for the tests that are missing and are part of the Target Spec');
  END IF;

  -- Go throug all the tests that are part of the Spec
  FOR l_spec_test IN c_spec_tests(p_target_spec_id)
  LOOP

    l_curr_replicate_cnt := 0;

    -- Find out how many times the test from the target spec is carried
    -- out in the exisitng result set.
    SELECT nvl(max(test_replicate_cnt), 0)
    INTO   l_curr_replicate_cnt
    FROM   GMD_RESULTS
    WHERE  sample_id = l_sample.sample_id
    AND    test_id   = l_spec_test.test_id
    ;

    -- Find out how many times still we need to do the test
    -- in order for Target Spec to be used.
    l_missing_cnt := l_spec_test.test_replicate - l_curr_replicate_cnt;

    IF (l_debug = 'Y') THEN
      gmd_debug.put_line('    Test ID - ' || l_spec_test.test_id ||
                         ' Replicate in Spec - ' || l_spec_test.test_replicate ||
                         ' Already times performed - ' || l_curr_replicate_cnt ||
                         ' To be performed for times - ' || l_missing_cnt);
    END IF;

    IF ( l_missing_cnt > 0 ) THEN

      -- This means we need to carry this same test some more times.
      -- So go through l_missing_cnt times
      l_test_ids.DELETE;
      FOR i IN 1..l_missing_cnt
      LOOP
        -- Here we can re-use the procedure add_tests_to_sample
        -- so construct the input parameters and then just call that
        -- procedure.
        l_test_ids(i) := l_spec_test.test_id;

      END LOOP;  -- Test Replicate Loop

      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('      Since it needs to be performed, Test IDs table created and calling add_tests_to_sample.');
      END IF;

      -- We have all the parameter for inserting tests to a sample
      add_tests_to_sample
      (  p_sample             => l_sample
       , p_test_ids           => l_test_ids
       , p_event_spec_disp_id => l_event_spec_disp.event_spec_disp_id
       , x_results_tab        => l_results_tab
       , x_spec_results_tab   => l_spec_results_tab
       , x_return_status      => l_return_status
      );

      IF l_return_status <> 'S' THEN
        -- Message must have been logged so just raise an exception.
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('      Test template record added to both GMD_RESULTD and GMD_SPEC_RESULTS.');
      END IF;

      -- We ignore other out parameters

    END IF; -- Either test is missing or needs more replicate

  END LOOP;  -- Spec Tests Loop

  -- Now all the test adding business is over. So let's see it the sample disposition
  -- can be changed to Complete
  gmd_results_grp.change_sample_disposition
              ( p_sample_id        => l_sample.sample_id
              , x_change_disp_to   => l_change_disp_to
              , x_return_status    => l_return_status
              , x_message_data     => l_message_data
              );
  IF l_return_status <> 'S' THEN
    FND_MESSAGE.SET_NAME('GMD', l_message_data);
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('Leaving Procedure - MAKE_TARGET_SPEC_THE_BASE_SPEC');
  END IF;

  RETURN;

  -- All systems GO...

EXCEPTION
  WHEN    FND_API.G_EXC_ERROR
       OR e_spec_results_insert_error
       OR e_event_spec_disp_insert_error
       OR e_sample_spec_disp_insert_err
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR',
                            'PACKAGE','MAKE_TARGET_SPEC_THE_BASE_SPEC',
                            'ERROR', SUBSTR(SQLERRM,1,100));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


END make_target_spec_the_base_spec;




--Start of comments
--+========================================================================+
--| API Name    : use_target_spec_for_cmpst_rslt                           |
--| TYPE        : Group                                                    |
--| Notes       : This procedure is to make the target spec as the base    |
--|               spec for a given composite result set.                   |
--|                                                                        |
--|               NOTE: THIS PROCEDURE RE-USES THE PROCEDURE               |
--|                     make_target_spec_the_base_spec                     |
--|                                                                        |
--|                                                                        |
--|                                                                        |
--| PARAMETERS  :                                                          |
--|                                                                        |
--| 1. p_composite_spec_disp_id - Table of Sample IDs in which the test is |
--|                               to be added.                             |
--| 2. p_target_spec_id - Spec ID which will become base spec.             |
--| 3. p_target_spec_cr_id - Spec VR ID which will become base spec VR.    |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	16-Sep-2002	Created.                           |
--|                                                                        |
--+========================================================================+
-- End of comments


PROCEDURE use_target_spec_for_cmpst_rslt
(
  p_composite_spec_disp_id IN NUMBER
, p_target_spec_id         IN NUMBER
, p_target_spec_vr_id      IN NUMBER
, x_return_status          OUT NOCOPY VARCHAR2
) IS

  -- Cursors
  CURSOR c_get_se_id (p_composite_spec_disp_id NUMBER) IS
  SELECT sampling_event_id
  FROM   gmd_composite_spec_disp csd, gmd_event_spec_disp esd
  WHERE  csd.composite_spec_disp_id = p_composite_spec_disp_id
  AND    csd.event_spec_disp_id = esd.event_spec_disp_id
  AND    csd.latest_ind = 'Y'
  AND    csd.delete_mark = 0
  AND    esd.spec_used_for_lot_attrib_ind = 'Y'
  AND    esd.delete_mark = 0
  ;

  -- Local Variables
  l_sampling_event_id              NUMBER;
  l_sample_ids                     GMD_API_PUB.number_tab;
  l_return_status                  VARCHAR2(1);

BEGIN

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('Entered Procedure - USE_TARGET_SPEC_FOR_CMPST_RSLT');
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Get the Sampling Event ID
  OPEN c_get_se_id (p_composite_spec_disp_id);
  FETCH c_get_se_id INTO l_sampling_event_id;
  IF c_get_se_id%NOTFOUND THEN
    CLOSE c_get_se_id;
    GMD_API_PUB.Log_Message('GMD_SAMPLING_EVENT_NOT_FOUND');
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c_get_se_id;

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('  Working on SE ID - ' || l_sampling_event_id);
  END IF;

  -- Now get all the samples that are part of this Sampling Event
  get_sample_ids_for_se (p_sampling_event_id => l_sampling_event_id,
                         x_sample_ids        => l_sample_ids,
                         x_return_status     => l_return_status);
  IF l_return_status <> 'S' THEN
    -- Message must have been logged so just raise an exception.
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('  There are ' || l_sample_ids.COUNT || ' samples in this SE ID.' );
  END IF;

  -- If the no of samples count is zero then error out
  IF (l_sample_ids.COUNT = 0) THEN
    GMD_API_PUB.Log_Message('GMD_NO_SAMPLE_TO_COMPOSITE');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Now call "make_target_spec_the_base_spec" for each sample ID
  FOR i in 1..l_sample_ids.COUNT
  LOOP
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('    Calling make_target_spec_the_base_spec for Sample ID - ' || l_sample_ids(i));
    END IF;
    -- For each sample make the target spec as base spec.
    make_target_spec_the_base_spec(p_sample_id          => l_sample_ids(i),
                                   p_target_spec_id     => p_target_spec_id,
                                   p_target_spec_vr_id  => p_target_spec_vr_id,
                                   x_return_status      => l_return_status);
    IF l_return_status <> 'S' THEN
      -- Message must have been logged so just raise an exception.
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('    Target Spec Changed for Sample ID - ' || l_sample_ids(i));
    END IF;
  END LOOP;

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('Leaving Procedure - USE_TARGET_SPEC_FOR_CMPST_RSLT');
  END IF;

  RETURN;
  -- All systems go...


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR',
                            'PACKAGE','USE_TARGET_SPEC_FOR_CMPST_RSLT',
                            'ERROR', SUBSTR(SQLERRM,1,100));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END use_target_spec_for_cmpst_rslt;












--+========================================================================+
--| API Name    : get_rslt_and_spec_rslt                                   |
--| TYPE        : Group                                                    |
--| Notes       : This procedure receives as input sample record and       |
--|               retrieves results and spec results records.              |
--|                                                                        |
--|               If everything is fine then OUT parameter                 |
--|               x_return_status is set to 'S' else appropriate           |
--|               error message is put on the stack and error              |
--|               is returned.                                             |
--|                                                                        |
--| HISTORY                                                                |
--|   Ger Kelly  10 Sep 2002	Created.                                   |
--|   GK         11 Sep 2002  Made changes to the results cursor for replicates |
--|   GK         19 Sep 2002 Added event_spec_disp_id as parameter,        |
--|                           changed results_rec to gmd_results_rec_tbl   |
--|   GK	 24 Sep 2002 Changed the cursor c_res to incorporate analytical fns |
--|   GK	 17 Oct 2002 B2621648 - Changed the IF, ELSIF to accomodate for
--|			     chars ,e.g. text_range that have both num and chars
--|  Sukarna Reddy 29 Oct 2002.  B2620851. Added code to fetch test results
--|                            if sample is not associated with specification.
--|   			        indented the procedure code.
--|  Rameshwar     27-FEB-2003   B#2871126
--|                              Added display_precisions column to the select list
--|                              in the cursor c_get_spec_test_num
--|                                                                        |
--|    Chetan Nagar	01-Apr-2002	Added exclude_ind column condition |
--|       in select for table - gmd_spec_tests_b                           |
--|  	Rameshwar   13-APR-2004   B#3545701                                |
--|                              Added non validated test type to retrieve |
--|                              target values for non-validated tests.    |
--========================================================================+
PROCEDURE get_rslt_and_spec_rslt
(
  p_sample_id             IN         NUMBER,
  p_source_spec_id	  IN         NUMBER,
  p_target_spec_id	  IN         NUMBER,
  p_event_spec_disp_id 	  IN         NUMBER,
  x_results_rec_tbl       OUT NOCOPY GMD_RESULTS_GRP.gmd_results_rec_tbl,
  x_return_status         OUT NOCOPY VARCHAR2) IS


/* Local Variables */

  l_spec_id             NUMBER(15);
  i			NUMBER :=0;
  j                     NUMBER :=0;
  k                     NUMBER :=0;

  l_display_label	VARCHAR2(80);
  l_spec_ind		VARCHAR2(1);
  l_test_id	        NUMBER;

  l_results_rec_tbl     GMD_RESULTS_GRP.gmd_results_rec_tbl;

  x_test_ids		GMD_API_PUB.number_tab;
  l_sample_id		GMD_API_PUB.number_tab;
  return_status		VARCHAR2(1);

  /* Cursors */

  CURSOR c_res IS
     SELECT *
     FROM	gmd_result_data_points_gt;

  CURSOR c_get_type IS
      SELECT  t.test_type, t.test_code, t.test_method_id, t.expression, t.test_unit,
      	      m.test_method_code
      FROM    gmd_qc_tests_b t , gmd_test_methods_b m
      WHERE   t.test_id = l_test_id
      AND     t.test_method_id = m.test_method_id;
  LocalTypeRec	c_get_type%ROWTYPE;

  CURSOR c_get_display IS
    SELECT  v.display_label_numeric_range
    FROM    gmd_qc_test_values v
    WHERE   v.test_id = l_test_id;
  LocalDisRec   c_get_display%ROWTYPE;

  --BEGIN BUG#2871126 Rameshwar
  --Added display_precision to the selct list.
  CURSOR c_get_spec_test_num IS
      SELECT  s.min_value_num, s.max_value_num, s.target_value_num,s.display_precision
      FROM    gmd_spec_tests_b s
      WHERE   s.spec_id = l_spec_id
      AND     s.test_id = l_test_id
      AND     s.exclude_ind IS NULL;

  X_additional_test gmd_spec_results.additional_test_ind%TYPE;
  X_display_precision gmd_qc_tests_b.display_precision%TYPE;
  --END BUG#2871126.

  LocalNumRec   c_get_spec_test_num%ROWTYPE;


   CURSOR c_get_spec_test_char IS
      SELECT  s.min_value_char, s.max_value_char, s.target_value_char
      FROM    gmd_spec_tests_b s
      WHERE   s.spec_id = l_spec_id
      AND     s.test_id = l_test_id
      AND     s.exclude_ind IS NULL;

  LocalCharRec   c_get_spec_test_char%ROWTYPE;

  CURSOR c_get_results(p_sample_id NUMBER) IS
    SELECT *
    FROM gmd_results
    WHERE sample_id = p_sample_id;

    l_qc_test         gmd_qc_tests%rowtype;
    l_test_mthd       gmd_test_methods%rowtype;

    l_in_qc_test      gmd_qc_tests%rowtype;
    l_in_test_mthd    gmd_test_methods%rowtype;

    l_ret_sts         BOOLEAN;

BEGIN

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('Entered Procedure - GET_RSLT_AND_SPEC_RSLT');
     gmd_debug.put_line('Input Parameters:');
     gmd_debug.put_line('    Sample ID     : ' || p_sample_id);
     gmd_debug.put_line('    Source Spec ID: ' || p_source_spec_id);
     gmd_debug.put_line('    Target Spec ID: ' || p_target_spec_id);
     gmd_debug.put_line('    Event Spec ID : ' || p_event_spec_disp_id);
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- begin Bug 2620851  29 Oct 2002
  i := 1;

  -- IF there is no specification associated with sample then get the information from GMD_RESULTS directly.
  IF (p_source_spec_id IS NULL) THEN

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Source Spec ID is NULL. So fetch data from GMD_RESULTS.');
    END IF;

    FOR c_result_rec IN C_get_results(p_sample_id) LOOP
      l_results_rec_tbl(i).test_id := c_result_rec.test_id;

      l_in_qc_test.test_id := c_result_rec.test_id;
      l_ret_sts := gmd_qc_tests_pvt.fetch_row(p_gmd_qc_tests => l_in_qc_test,
 	        	                      x_gmd_qc_tests => l_qc_test);
      l_results_rec_tbl(i).test_code := l_qc_test.test_code;
      l_results_rec_tbl(i).test_type := l_qc_test.test_type;
      l_results_rec_tbl(i).unit := l_qc_test.test_unit;

      l_in_test_mthd.test_method_id := l_qc_test.test_method_id;
      l_ret_sts := GMD_TEST_METHODS_PVT.fetch_row(p_test_methods => l_in_test_mthd,
		                                  x_test_methods => l_test_mthd);
      l_results_rec_tbl(i).method     := l_test_mthd.test_method_code;
      l_results_rec_tbl(i).result_num := c_result_rec.result_value_num;
      l_results_rec_tbl(i).result_char:= c_result_rec.result_value_char;
      l_results_rec_tbl(i).expression := l_qc_test.expression;
      l_results_rec_tbl(i).min_num    := l_qc_test.min_value_num;
      l_results_rec_tbl(i).max_num    := l_qc_test.max_value_num;
      i := i + 1;

      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('Fetched Result row with RESULT ID: '|| c_result_rec.result_id );
         gmd_debug.put_line('                        Test Code: '|| l_qc_test.test_code ||
                                         ' Replicate: ' || c_result_rec.test_replicate_cnt );
      END IF;

    END LOOP;
    x_results_rec_tbl := l_results_rec_tbl;
    --  end Bug 2620851

  ELSE

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('We have the source spec, fetch data using POPULATE_RESULT_DATA_POINTS');
    END IF;

    --Since we have a specification
    --retrieve rows in GMD_RESULTS and GMD_SPEC_RESULTS for all the tests
    l_results_rec_tbl.DELETE;
    i := 0;

    -- Added Sep24 for getting tests without results
    l_sample_id(1) := p_sample_id;
    GMD_RESULTS_GRP.populate_result_data_points(p_sample_ids         => l_sample_id,
       					        p_event_spec_disp_id => p_event_spec_disp_id,
					        x_return_status      => x_return_status);

    -- Get the results for each sample and spec
    FOR LocalResRec IN c_res LOOP
      i := i + 1;

      IF (l_debug = 'Y') THEN
         gmd_debug.put_line(' ');
         gmd_debug.put_line('Operating on row: ' || i || ' from POPULATE_RESULT_DATA_POINTS');
      END IF;


      IF LocalResRec.data_num IS NOT NULL THEN
        l_results_rec_tbl(i).result_num := LocalResRec.data_num;
      END IF;
      IF LocalResRec.data_char IS NOT NULL THEN
        l_results_rec_tbl(i).result_char := LocalResRec.data_char;
      END IF;

      l_test_id := LocalResRec.test_id;
      l_results_rec_tbl(i).test_id := l_test_id;

      -- For each test type get the test and method info
      OPEN c_get_type;
      FETCH c_get_type INTO LocalTypeRec;
      l_results_rec_tbl(i).test_type := LocalTypeRec.test_type;
      l_results_rec_tbl(i).test_code := LocalTypeRec.test_code;
      l_results_rec_tbl(i).expression := LocalTypeRec.expression;
      l_results_rec_tbl(i).unit := LocalTypeRec.test_unit;
      l_results_rec_tbl(i).method := LocalTypeRec.test_method_code;
      CLOSE c_get_type;

      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('Retrieved Test and Method info:');
         gmd_debug.put_line('  Test: ' || LocalTypeRec.test_code || ' Method: ' ||  LocalTypeRec.test_method_code);
      END IF;

      -- Get the values for the Current Spec
      l_spec_id := p_source_spec_id;
      OPEN c_get_spec_test_num;
      FETCH c_get_spec_test_num INTO LocalNumRec;
      IF c_get_spec_test_num%FOUND THEN

 	  l_results_rec_tbl(i).target_num := LocalNumRec.target_value_num;
    	  l_results_rec_tbl(i).min_num := LocalNumRec.min_value_num;
    	  l_results_rec_tbl(i).max_num := LocalNumRec.max_value_num;

        --BEGIN BUG#2871126
        --Fetching the display precision into table type.
          l_results_rec_tbl(i).display_precision:=LocalNumRec.display_precision;
        --END BUG#2871126

        IF (l_debug = 'Y') THEN
           gmd_debug.put_line('Retrieved Spec info:');
        END IF;
      END IF;

      CLOSE c_get_spec_test_num;

       --BEGIN BUG#2871126 Rameshwar
      SELECT sr.additional_test_ind
      INTO   X_additional_test
      FROM   gmd_spec_results sr
      WHERE  sr.event_spec_disp_id = p_event_spec_disp_id
      AND    sr.result_id          = LocalResRec.result_id
      ;

      IF X_additional_test = 'Y' THEN

        SELECT display_precision
        INTO X_display_precision
        FROM gmd_qc_tests_b
        WHERE test_id = l_test_id;

        l_results_rec_tbl(i).display_precision := X_display_precision;

        IF (l_debug = 'Y') THEN
           gmd_debug.put_line('The test is additional so get the display precision (' ||
                                                      X_display_precision || ' ) from Test');
        END IF;

      END IF;
      --END BUG#2871126


      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('Now get the values for the Target Spec.');
      END IF;

      --Get the values for the Comparison Spec
      l_spec_id := p_target_spec_id;

      OPEN c_get_spec_test_num;
      FETCH c_get_spec_test_num INTO LocalNumRec;
      IF c_get_spec_test_num%FOUND THEN
        l_results_rec_tbl(i).spec_target_num := LocalNumRec.target_value_num;
	  l_results_rec_tbl(i).spec_min_num := LocalNumRec.min_value_num;
    	  l_results_rec_tbl(i).spec_max_num := LocalNumRec.max_value_num;

          --BEGIN BUG#2871126 Rameshwar
    	  --Fetching the display precision into table type.
    	  l_results_rec_tbl(i).spec_display_precision:=LocalNumRec.display_precision;
    	  --END BUG#2871126

      END IF;
      CLOSE c_get_spec_test_num;
     --BEGIN BUG#3545701
     --Added non-validated test type
      IF LocalTypeRec.test_type IN ('V', 'T', 'L', 'E','U') THEN
     --END BUG#3545701
        -- Get the values for the Current Specfor chars
        l_spec_id := p_source_spec_id;

        OPEN c_get_spec_test_char;
        FETCH c_get_spec_test_char INTO LocalCharRec;
        IF c_get_spec_test_char%FOUND THEN
          l_results_rec_tbl(i).target_char := LocalCharRec.target_value_char;
          l_results_rec_tbl(i).min_char := LocalCharRec.min_value_char;
          l_results_rec_tbl(i).max_char := LocalCharRec.max_value_char;
        END IF;
        CLOSE c_get_spec_test_char;

        --Get the values for the Comparison Spec
        l_spec_id := p_target_spec_id;
        OPEN c_get_spec_test_char;
        FETCH c_get_spec_test_char INTO LocalCharRec;
        IF c_get_spec_test_char%FOUND THEN
          l_results_rec_tbl(i).spec_target_char := LocalCharRec.target_value_char;
 	  l_results_rec_tbl(i).spec_min_char := LocalCharRec.min_value_char;
          l_results_rec_tbl(i).spec_max_char := LocalCharRec.max_value_char;
        END IF;
        CLOSE c_get_spec_test_char;
      END IF;

      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('Got the Test and Spec info');
      END IF;

      l_results_rec_tbl(i).in_spec := GMD_RESULTS_GRP.rslt_is_in_spec(p_source_spec_id,
      								      l_results_rec_tbl(i).test_id,
       								      l_results_rec_tbl(i).result_num,
       								      l_results_rec_tbl(i).result_char);
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('in spec res '||l_results_rec_tbl(i).in_spec);
      END IF;
      l_results_rec_tbl(i).spec_in_spec := GMD_RESULTS_GRP.rslt_is_in_spec( p_target_spec_id,
      									    l_results_rec_tbl(i).test_id,
       									    l_results_rec_tbl(i).result_num,
       									    l_results_rec_tbl(i).result_char);
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('spec in spec res '||l_results_rec_tbl(i).spec_in_spec);
      END IF;
      x_results_rec_tbl(i) := l_results_rec_tbl(i);

    END LOOP;  -- Results test Loop

    j := i;
    l_spec_id := p_target_spec_id;

    GMD_RESULTS_GRP.compare_rslt_and_spec(p_sample_id,
    					  l_spec_id,
    					  x_test_ids,
    					  return_status);

    FOR k in 1..x_test_ids.COUNT LOOP
      i := i + k;
      l_test_id := x_test_ids(k);
      OPEN c_get_type;
      FETCH c_get_type INTO LocalTypeRec;
      CLOSE c_get_type;
      l_results_rec_tbl(i).test_code := LocalTypeRec.test_code;
      l_results_rec_tbl(i).test_type := LocalTypeRec.test_type;
      l_results_rec_tbl(i).spec_test_id := l_test_id;
      l_results_rec_tbl(i).spec_in_spec := GMD_RESULTS_GRP.rslt_is_in_spec( p_target_spec_id,
      									    l_test_id,
      									    l_results_rec_tbl(i).result_num,
      									    l_results_rec_tbl(i).result_char);
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('spec in spec res '||l_results_rec_tbl(i).spec_in_spec);
      END IF;

      IF LocalTypeRec.test_type IN ('N', 'L', 'V', 'T', 'E', 'U')  THEN
         -- Get the values for the Comparison Spec

        OPEN c_get_spec_test_num;
        FETCH c_get_spec_test_num INTO LocalNumRec;
        IF c_get_spec_test_num %FOUND THEN
          l_results_rec_tbl(i).spec_target_num := LocalNumRec.target_value_num;
          l_results_rec_tbl(i).spec_min_num := LocalNumRec.min_value_num;
          l_results_rec_tbl(i).spec_max_num := LocalNumRec.max_value_num;
          --BEGIN BUG#2871126 Rameshwar
          l_results_rec_tbl(i).spec_display_precision:=LocalNumRec.display_precision;
          --END BUG#2871126

        END IF;
        CLOSE c_get_spec_test_num;
      END IF;

      IF LocalTypeRec.test_type IN ('V', 'T', 'L', 'E','U') THEN
        -- Get the values for the Comparison Test for chars

        OPEN c_get_spec_test_char;
        FETCH c_get_spec_test_char INTO LocalCharRec;
        IF c_get_spec_test_char%FOUND THEN
      	  l_results_rec_tbl(i).spec_target_char := LocalCharRec.target_value_char;
	  l_results_rec_tbl(i).spec_min_char := LocalCharRec.min_value_char;
          l_results_rec_tbl(i).spec_max_char := LocalCharRec.max_value_char;
      	END IF;
 	CLOSE c_get_spec_test_char;
      END IF;
        x_results_rec_tbl(i) := l_results_rec_tbl(i);
    END LOOP;
   END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR',
                            'PACKAGE','GET_SAMPLE_IDS_FOR_SE',
                            'ERROR', SUBSTR(SQLERRM,1,100));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END get_rslt_and_spec_rslt;



--Start of comments
--+========================================================================+
--| API Name    : composite_exist                                          |
--| TYPE        : Group                                                    |
--| Notes       : This procedure checks if there does not exist            |
--|               composite results for the given event_spec_disp_id       |
--|               or if the current composite are out of sync.             |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	26-Sep-2002	Created.                           |
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE composite_exist
(
  p_sampling_event_id  IN         NUMBER
, p_event_spec_disp_id IN         NUMBER
, x_composite_exist    OUT NOCOPY VARCHAR2
, x_composite_valid    OUT NOCOPY VARCHAR2
, x_return_status      OUT NOCOPY VARCHAR2
)
IS

  -- Cursors
  CURSOR c_composite (p_event_spec_disp_id NUMBER) IS
  SELECT 1
  FROM   gmd_composite_spec_disp
  WHERE  event_spec_disp_id = p_event_spec_disp_id
  AND    nvl(latest_ind, 'N') = 'Y'
  ;

  CURSOR c_composite_valid (p_sampling_event_id NUMBER) IS
  SELECT nvl(recomposite_ind, 'N')
  FROM   gmd_sampling_events
  WHERE  sampling_event_id = p_sampling_event_id
  ;

  -- Local Variables
  dummy                  PLS_INTEGER;
  l_recomposite_ind      VARCHAR2(1);
  l_event_spec_disp_id   NUMBER;

BEGIN

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('Entered Procedure - COMPOSITE_EXIST');
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  x_composite_exist := 'N';
  x_composite_valid := 'N';

  IF (p_sampling_event_id IS NULL AND p_event_spec_disp_id IS NULL) THEN
    GMD_API_PUB.Log_Message('GMD_INVALID_PARAMETERS');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (p_event_spec_disp_id IS NULL) THEN
    l_event_spec_disp_id := get_current_event_spec_disp_id(p_sampling_event_id);
    IF (l_event_spec_disp_id IS NULL) THEN
      GMD_API_PUB.Log_Message('GMD_EVENT_SPEC_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    l_event_spec_disp_id := p_event_spec_disp_id;
  END IF;

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('SE ID: ' || p_sampling_event_id || ' ESD ID: ' || l_event_spec_disp_id);
  END IF;

  -- See if we have the composite for the event_spec
  OPEN c_composite(l_event_spec_disp_id);
  FETCH c_composite INTO dummy;
  IF c_composite%FOUND THEN
     x_composite_exist := 'Y';
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Composite Exist.');
    END IF;
  ELSE
    NULL;
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Composite DOES NOT Exist.');
    END IF;
  END IF;

  CLOSE c_composite;

  IF (x_composite_exist = 'Y') THEN
    -- See if this composite is Valid
    OPEN c_composite_valid(p_sampling_event_id);
    FETCH c_composite_valid INTO l_recomposite_ind;
    IF c_composite_valid%NOTFOUND THEN
      CLOSE c_composite_valid;
      GMD_API_PUB.Log_Message('GMD_SAMPLING_EVENT_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_composite_valid;

    IF l_recomposite_ind = 'Y' THEN
      x_composite_valid := 'N';
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('Composite IS NOT Valid.');
      END IF;
    ELSE
      x_composite_valid := 'Y';
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('Composite IS Valid.');
      END IF;
    END IF;
  END IF;

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('Leaving Procedure - COMPOSITE_EXIST');
  END IF;
  RETURN;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR',
                            'PACKAGE','GET_SAMPLE_IDS_FOR_SE',
                            'ERROR', SUBSTR(SQLERRM,1,100));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


END composite_exist;




--Start of comments
--+========================================================================+
--| API Name    : se_recomposite_required                                  |
--| TYPE        : Group                                                    |
--| Notes       : This procedure checks if there exist                     |
--|               composite results for the given event_spec_disp_id.      |
--|               If YES then it will mark that composite as NOT-Current   |
--|               in gmd_smapling_events.                                  |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	26-Sep-2002	Created.                           |
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE se_recomposite_required
(
  p_sampling_event_id  IN         NUMBER
, p_event_spec_disp_id IN         NUMBER
, x_return_status      OUT NOCOPY VARCHAR2
)
IS

  -- Cursors
  CURSOR c_composite (p_event_spec_disp_id NUMBER) IS
  SELECT 1
  FROM   gmd_composite_spec_disp
  WHERE  event_spec_disp_id = p_event_spec_disp_id
  AND    nvl(latest_ind, 'N') = 'Y'
  ;

  -- Local Variables
  dummy               PLS_INTEGER;
  l_event_spec_disp_id   NUMBER;

BEGIN
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_sampling_event_id IS NULL AND p_event_spec_disp_id IS NULL) THEN
    GMD_API_PUB.Log_Message('GMD_INVALID_PARAMETERS');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (p_event_spec_disp_id IS NULL) THEN
    l_event_spec_disp_id := get_current_event_spec_disp_id(p_sampling_event_id);
    IF (l_event_spec_disp_id IS NULL) THEN
      GMD_API_PUB.Log_Message('GMD_EVENT_SPEC_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    l_event_spec_disp_id := p_event_spec_disp_id;
  END IF;

  -- See if we have the composite for the event_spec
  OPEN c_composite(l_event_spec_disp_id);
  FETCH c_composite INTO dummy;
  IF c_composite%FOUND THEN
    -- We have found that the Sampling Event is composited before.
    -- So update the sampling event that recomposite is required.
    UPDATE gmd_sampling_events
    SET    recomposite_ind = 'Y'
    WHERE  sampling_event_id = p_sampling_event_id;
  END IF;
  CLOSE c_composite;

  RETURN;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR',
                            'PACKAGE','GET_SAMPLE_IDS_FOR_SE',
                            'ERROR', SUBSTR(SQLERRM,1,100));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


END se_recomposite_required;



--Start of comments
--+========================================================================+
--| API Name    : result_recomposite_required                              |
--| TYPE        : Group                                                    |
--| Notes       : This procedure checks if there exist                     |
--|               composite results for the given result_id.               |
--|               If YES then it will mark that composite as NOT-Current   |
--|               in gmd_smapling_events.                                  |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	26-Sep-2002	Created.                           |
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE result_recomposite_required
(
  p_result_id          IN         NUMBER
, p_event_spec_disp_id IN         NUMBER
, x_return_status      OUT NOCOPY VARCHAR2
)
IS

  -- Cursors
  CURSOR c_composite (p_event_spec_disp_id NUMBER, p_result_id NUMBER) IS
  SELECT 1
  FROM   gmd_composite_spec_disp csd, gmd_composite_results cr, gmd_composite_result_assoc cra
  WHERE  csd.event_spec_disp_id = p_event_spec_disp_id
  AND    csd.composite_spec_disp_id = cr.composite_spec_disp_id
  AND    cr.composite_result_id = cra.composite_result_id
  AND    cra.result_id = p_result_id
  AND    nvl(csd.latest_ind, 'N') = 'Y'
  ;

  -- Local Variables
  dummy               PLS_INTEGER;

BEGIN
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_result_id IS NULL OR p_event_spec_disp_id IS NULL) THEN
    GMD_API_PUB.Log_Message('GMD_INVALID_PARAMETERS');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- See if we have the composite for the result
  OPEN c_composite(p_event_spec_disp_id, p_result_id);
  FETCH c_composite INTO dummy;
  IF c_composite%FOUND THEN
    -- We have found that the Sampling Event is composited before.
    -- So update the sampling event that recomposite is required.
    UPDATE gmd_sampling_events
    SET    recomposite_ind = 'Y'
    WHERE  sampling_event_id =
      (SELECT sampling_event_id
       FROM   gmd_event_spec_disp
       WHERE  event_spec_disp_id = p_event_spec_disp_id);
  END IF;
  CLOSE c_composite;

  RETURN;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR',
                            'PACKAGE','GET_SAMPLE_IDS_FOR_SE',
                            'ERROR', SUBSTR(SQLERRM,1,100));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


END result_recomposite_required;




--Start of comments
--+========================================================================+
--| API Name    : get_sample_ids_for_se                                    |
--| TYPE        : Group                                                    |
--| Notes       : This procedure retrieves all sample_id s that are part   |
--|               of the sampling_event_id supplied.                       |
--|                                                                        |
--|               This procedure should be called when user wants to       |
--|               composite samples.                                       |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	04-Sep-2002	Created.                           |
--|    Chetan Nagar	09-Dec-2002	Changed disposition from gmd_samples|
--|                                     To gmd_sample_spec_disp.           |
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE get_sample_ids_for_se
(
  p_sampling_event_id  IN         NUMBER
, x_sample_ids         OUT NOCOPY GMD_API_PUB.number_tab
, x_return_status      OUT NOCOPY VARCHAR2
)
IS

    -- Bug 3079877: do not composite planning samples
  CURSOR c_sample(p_sampling_event_id NUMBER) IS
  SELECT s.sample_id
  FROM   gmd_event_spec_disp esd,
         gmd_sample_spec_disp ssd,
         gmd_samples s
  WHERE  esd.sampling_event_id = p_sampling_event_id
  AND    esd.spec_used_for_lot_attrib_ind = 'Y'
  AND    esd.event_spec_disp_id = ssd.event_spec_disp_id
  AND    ssd.sample_id = s.sample_id
  AND    nvl(ssd.disposition, 'XX') NOT IN ('0RT', '7CN', '0PL')
  AND    esd.delete_mark     = 0
  AND    ssd.delete_mark     = 0
  AND    s.delete_mark       = 0
  ORDER BY s.sample_id
  ;

  -- Local Variables
  i                    PLS_INTEGER;

BEGIN

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('Entered Procedure - GET_SAMPLE_IDS_FOR_SE');
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Now get all the samples that are part of Sampling Event
  i := 1;
  FOR sample_rec IN c_sample(p_sampling_event_id)
  LOOP
    x_sample_ids(i) := sample_rec.sample_id;
    i := i + 1;
  END LOOP;
  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('  Sampling Event ID - ' || p_sampling_event_id || ' has - ' || x_sample_ids.COUNT || ' samples.');
     gmd_debug.put_line('Leaving Procedure - GET_SAMPLE_IDS_FOR_SE');
  END IF;
  RETURN;

EXCEPTION
  WHEN    FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR',
                            'PACKAGE','GET_SAMPLE_IDS_FOR_SE',
                            'ERROR', SUBSTR(SQLERRM,1,100));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END get_sample_ids_for_se;




--Start of comments
--+========================================================================+
--| API Name    : populate_result_data_points                              |
--| TYPE        : Group                                                    |
--| Notes       : This procedure populates global session temporary table  |
--|               with the result value for each test of the sample given. |
--|                                                                        |
--|               Since there can be multiple replicates for the test in   |
--|               a given sample, the last result, defined as having the   |
--|               latest result_date, is considered as test result and is  |
--|               picked up.                                               |
--|                                                                        |
--|               IF THERE ARE MORE THAN ONE RESULTs WITH THE SAME LATEST  |
--|               result_date FOR A GIVEN sample_id AND test_id THEN       |
--|               test_replicate_cnt WILL BE USED TO BREAK THE TIE.        |
--|                                                                        |
--| PARAMETERS  :                                                          |
--|                                                                        |
--| 1. p_sample_ids - Table of Sample IDs                                  |
--| 2. p_event_spec_disp_id - Event Spec ID                                |
--| 3. x_return_status  - Return Status                                    |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	03-Sep-2002	Created.                           |
--|    LeAta Jackson    14-Oct-2002     Added NVL around date in order by. |
--|                                      So results with dates are chosen  |
--|                                      before rows with no results/dates.|
--|    Jeff Baird       12-Nov-2002     Bug #2626977 Removed reference to  |
--|                                      SY$MIN_DATE profile.              |
--|    Manish Gupta     13-Jan-2004     Bug #B3373760, changed 50(Zero) to |
--|                                     5O(Letter O)                       |
--|    Manish Gupta     20-Jan-2004     Bug #B3358298, Included gmd_samples|
--|                                     so that the retain_as samples are  |
--|                                     Excluded.                          |
--+========================================================================+
-- End of comments

PROCEDURE populate_result_data_points
(
  p_sample_ids         IN GMD_API_PUB.number_tab
, p_event_spec_disp_id IN NUMBER
, x_return_status      OUT NOCOPY VARCHAR2
)
IS

  -- Local Variables
  l_sql_stmt           VARCHAR2(2000);
  l_start_date         DATE;

BEGIN

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('Entering Procedure - POPULATE_RESULT_DATA_POINTS');
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_start_date  := GMA_CORE_PKG.get_date_constant_d('SY$MIN_DATE');
-- Bug #2626977 (JKB) Removed reference to date profile above.

  EXECUTE IMMEDIATE 'delete from gmd_result_data_points_gt';
  l_sql_stmt :=
    'INSERT INTO gmd_result_data_points_gt (result_id, test_id, exclude_ind,  data_num, data_char)'
  ||' ('
  ||'  SELECT result_id, test_id, 0, result_value_num, result_value_char FROM'
  ||'  ('
  ||'    SELECT r.result_id, r.test_id, r.result_value_num, r.result_value_char,'
  ||'           r.result_date, r.test_replicate_cnt,'
  ||'           last_value(r.result_id)'
  ||'           over (partition by r.test_id order by NVL(r.result_date, :l_start_date),'
  ||'                                                 r.test_replicate_cnt'
  ||'                 range between unbounded preceding and unbounded following) rmax_id'
  ||'    FROM   gmd_results r, gmd_spec_results sr, gmd_samples s'
  ||'    WHERE  r.result_id = sr.result_id'
  ||'    AND    r.sample_id = :l_sample_id'
  ||'    AND    sr.event_spec_disp_id = :l_event_spec_disp_id'
  ||'    AND    nvl(sr.evaluation_ind, ' || '''' || 'XX' || '''' || ')  not in ('
  ||                         '''' || '5O' || '''' ||','|| '''' || '4C' || '''' ||')'
  ||'    AND    sr.delete_mark = 0'
  ||'    AND    r.delete_mark = 0'
  ||'    AND    r.sample_id = s.sample_id'
  ||'    AND    s.retain_as IS NULL'
  ||'  )'
  ||'  WHERE result_id = rmax_id'
  ||')'
  ;

  -- The code below is now removed/changed from the SQL Above
  --||'    FROM   gmd_results r, gmd_spec_results sr, gmd_qc_tests_b t'
  --||'    AND    r.test_id   = t.test_id'
  --||'    AND    t.test_type <> ' || '''' || 'U' || ''''

  -- GO through all the sample_ids and populate _GTMP table
  FOR i in 1..p_sample_ids.COUNT
  LOOP
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('  Finding results for Sample ID - ' || p_sample_ids(i));
    END IF;
    EXECUTE IMMEDIATE l_sql_stmt USING l_start_date, p_sample_ids(i), p_event_spec_disp_id;
  END LOOP;

  dump_data_points;

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('Leaving Procedure - POPULATE_RESULT_DATA_POINTS');
  END IF;
  -- All systems GO...

EXCEPTION
  WHEN    FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR',
                            'PACKAGE','POPULATE_RESULT_DATA_POINTS',
                            'ERROR', SUBSTR(SQLERRM,1,100));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END populate_result_data_points;


PROCEDURE dump_data_points IS
  CURSOR c1 IS
  SELECT *
  FROM   gmd_result_data_points_gt
  ORDER BY TEST_ID;
BEGIN
  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('Data in session table - gmd_result_data_points_gt');
     gmd_debug.put_line('Result ID    Test ID    Data Num     Data Char    Exclude Ind');
  END IF;

  FOR c_rec IN c1
  LOOP
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line(lpad(c_rec.result_id, 9, ' ')||' '||
                       lpad(c_rec.test_id, 10, ' ')||' '||
                       lpad(nvl(c_rec.data_num, 0), 15, ' ')||' '||
                       lpad(nvl(c_rec.data_char, 'NULL'), 13, ' ')||' '||
                       lpad(c_rec.exclude_ind, 14, ' '));
    END IF;
  END LOOP;
END;



--Start of comments
--+========================================================================+
--| API Name    : create_composite_rows                                    |
--| TYPE        : Group                                                    |
--| Notes       : NEED TO WRITE SOMETHING HERE                             |
--|                                                                        |
--|                                                                        |
--|                                                                        |
--|                                                                        |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	04-Sep-2002	Created.                           |
--|                                                                        |
--|    Chetan Nagar	01-Apr-2002	Added exclude_ind column condition |
--|       in select for table - gmd_spec_tests_b                           |
--|                                                                        |
--|    RLNAGARA 21-Jul-2006 B5396610 Modified the CURSOR c_test_date.      |
--+========================================================================+
-- End of comments

PROCEDURE create_composite_rows
(
  p_event_spec_disp_id  IN         NUMBER
, x_return_status       OUT NOCOPY VARCHAR2
)
IS
 -- Curosrs
 -- RLNAGARA B5396610 Modified below cursor to select tests in order of seq .
  CURSOR c_test_data IS
  SELECT gt.test_id
  FROM   gmd_result_data_points_gt gt, gmd_results r
  WHERE  gt.result_id = r.result_id
  GROUP BY gt.test_id
  ORDER BY min(r.seq)
  ;

  CURSOR c_all_test_data (p_test_id NUMBER) IS
  SELECT result_id, data_num, data_char
  FROM   gmd_result_data_points_gt
  WHERE  test_id = p_test_id
  ;

  CURSOR c_spec_id (p_event_spec_disp_id NUMBER) IS
  SELECT spec_id
  FROM   gmd_event_spec_disp
  WHERE  event_spec_disp_id = p_event_spec_disp_id
  ;

  CURSOR c_test_type (p_test_id NUMBER) IS
  SELECT test_type, display_precision
  FROM   gmd_qc_tests_b
  WHERE  test_id = p_test_id
  ;

  CURSOR c_spec_test (p_spec_id NUMBER, p_test_id NUMBER) IS
  SELECT display_precision
  FROM   gmd_spec_tests_b
  WHERE  spec_id = p_spec_id
  AND    test_id = p_test_id
  AND    exclude_ind IS NULL
  ;

  -- Local Variables
  l_user_id            NUMBER;
  l_date               DATE;

  l_spec_id            NUMBER;
  l_mean               NUMBER;
  l_median_num         NUMBER;
  l_median_char        VARCHAR2(80);
  l_mode_num           NUMBER;
  l_mode_char          VARCHAR2(80);
  l_high_num           NUMBER;
  l_high_char          VARCHAR2(80);
  l_low_num            NUMBER;
  l_low_char           VARCHAR2(80);
  l_range              NUMBER;
  l_standard_deviation NUMBER;

  l_display_precision      NUMBER(2);
  l_t_display_precision    NUMBER(2);
  l_st_display_precision   NUMBER(2);

  l_test_type          VARCHAR2(1);
  l_return_status      VARCHAR2(1);
  sample_cnt           PLS_INTEGER;

  l_composite_spec_disp          GMD_COMPOSITE_SPEC_DISP%ROWTYPE;
  l_composite_result             GMD_COMPOSITE_RESULTS%ROWTYPE;
  l_composite_result_assoc       GMD_COMPOSITE_RESULT_ASSOC%ROWTYPE;

  l_out_composite_spec_disp      GMD_COMPOSITE_SPEC_DISP%ROWTYPE;
  l_out_composite_result         GMD_COMPOSITE_RESULTS%ROWTYPE;

  -- Exceptions
  e_comp_spec_disp_insert_error  EXCEPTION;
  e_comp_result_insert_error     EXCEPTION;
  e_spec_comp_rslt_insert_error  EXCEPTION;
  e_comp_rslt_assoc_insert_error EXCEPTION;


BEGIN

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('Entered Procedure - CREATE_COMPOSITE_ROWS');
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Get the user ID
  l_user_id  := FND_GLOBAL.user_id;
  l_date     := SYSDATE;

  -- Get the SPEC_ID
  OPEN c_spec_id(p_event_spec_disp_id);
  FETCH c_spec_id INTO l_spec_id;
  IF c_spec_id%NOTFOUND THEN
    CLOSE c_spec_id;
    GMD_API_PUB.Log_Message('GMD_SPEC_NOT_FOUND');
  END IF;
  CLOSE c_spec_id;

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('  ESD ID-' || p_event_spec_disp_id || ' Spec ID -' || l_spec_id);
  END IF;

  -- Update all previous composite for this p_event_spec_disp_id as Not-Latest
  UPDATE  gmd_composite_spec_disp
  SET     latest_ind = NULL
  WHERE   event_spec_disp_id = p_event_spec_disp_id
  AND     latest_ind = 'Y'
  ;

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('  Changed latest_ind for old rows in gmd_composite_spec_disp');
  END IF;

  -- Now, create a row in GMD_COMPOSITE_SPEC_DISP with latest_ind = 'Y'

  -- Construct the record
  l_composite_spec_disp.EVENT_SPEC_DISP_ID       := p_event_spec_disp_id;
  l_composite_spec_disp.DISPOSITION              := '3C';
  l_composite_spec_disp.LATEST_IND               := 'Y';
  l_composite_spec_disp.DELETE_MARK              := 0;
  l_composite_spec_disp.CREATION_DATE            := l_date;
  l_composite_spec_disp.CREATED_BY               := l_user_id;
  l_composite_spec_disp.LAST_UPDATE_DATE         := l_date;
  l_composite_spec_disp.LAST_UPDATED_BY          := l_user_id;

  -- We are ready for insert in GME_COMPOSITE_SPEC_DISP, so then lets do it.
  IF NOT(GMD_COMPOSITE_SPEC_DISP_PVT.Insert_Row(
                  p_composite_spec_disp => l_composite_spec_disp,
                  x_composite_spec_disp => l_out_composite_spec_disp)
         )
  THEN
    -- Insert Error
    RAISE e_comp_spec_disp_insert_error;
  END IF;
  l_composite_spec_disp.COMPOSITE_SPEC_DISP_ID := l_out_composite_spec_disp.COMPOSITE_SPEC_DISP_ID;

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('  Record inserted in GMD_COMPOSITE_SPEC_DISP, CSD ID-' || l_composite_spec_disp.composite_spec_disp_id);
  END IF;

  -- Go through all the unique tests for this event spec disp id that
  -- we are compositing.
  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('  Start calcualting composites for each test');
  END IF;
  FOR test_rec IN c_test_data
  LOOP
    l_t_display_precision  := -1;
    l_st_display_precision := -1;

    OPEN c_test_type(test_rec.test_id);
    FETCH c_test_type INTO l_test_type, l_t_display_precision;
    CLOSE c_test_type;

    IF (l_test_type in ('N', 'L', 'E')) THEN
      OPEN c_spec_test(l_spec_id, test_rec.test_id);
      FETCH c_spec_test INTO l_st_display_precision;
      CLOSE c_spec_test;
    END IF;

    IF (l_st_display_precision = -1) THEN
      l_display_precision := l_t_display_precision;
    ELSE
      l_display_precision := l_st_display_precision;
    END IF;

    -- Initialize values
    l_mean               := NULL;
    l_median_num         := NULL;
    l_median_char        := NULL;
    l_mode_num           := NULL;
    l_mode_char          := NULL;
    l_high_num           := NULL;
    l_high_char          := NULL;
    l_low_num            := NULL;
    l_low_char           := NULL;
    l_range              := NULL;
    l_standard_deviation := NULL;

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('    Processing Test ID-' || test_rec.test_id);
    END IF;
    -- Calculate composite values

    -- 1. Mean
    qc_mean( p_test_id       => test_rec.test_id
           , x_mean_num      => l_mean
           , x_return_status => l_return_status);

    IF (l_return_status <> 'S') THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (l_test_type in ('N', 'L', 'E')) THEN
      l_mean := round(l_mean, l_display_precision);
    END IF;
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('    l_mean-'|| l_mean);
    END IF;

    -- 2. Median
    qc_median( p_test_id       => test_rec.test_id
             , x_median_num    => l_median_num
             , x_median_char   => l_median_char
             , x_return_status => l_return_status);

    IF (l_return_status <> 'S') THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('    l_median_num-'|| l_median_num ||' l_median_char-'|| l_median_char);
    END IF;

    -- 3. Mode
    qc_mode( p_test_id       => test_rec.test_id
           , x_mode_num      => l_mode_num
           , x_mode_char     => l_mode_char
           , x_return_status => l_return_status);

    IF (l_return_status <> 'S') THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (l_test_type in ('N', 'L', 'E')) THEN
      l_mode_num := round(l_mode_num, l_display_precision);
    END IF;
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('    l_mode_num-'|| l_mode_num ||' l_mode_char-'|| l_mode_char);
    END IF;

    -- 4. High
    qc_high( p_test_id       => test_rec.test_id
           , x_high_num      => l_high_num
           , x_high_char     => l_high_char
           , x_return_status => l_return_status);

    IF (l_return_status <> 'S') THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('    l_high_num-'|| l_high_num ||' l_high_char-'|| l_high_char);
    END IF;

    -- 5. Low
    qc_low( p_test_id        => test_rec.test_id
           , x_low_num       => l_low_num
           , x_low_char      => l_low_char
           , x_return_status => l_return_status);

    IF (l_return_status <> 'S') THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('   l_low_num - '|| l_low_num ||' l_low_char-'|| l_low_char);
    END IF;

    -- 6. Standard Deviation
    qc_standard_deviation( p_test_id       => test_rec.test_id
                         , x_stddev        => l_standard_deviation
                         , x_return_status => l_return_status);

    IF (l_return_status <> 'S') THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (l_test_type in ('N', 'L', 'E')) THEN
      l_standard_deviation := round(l_standard_deviation, l_display_precision);
    END IF;
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('    l_standard_deviation - '|| l_standard_deviation);
    END IF;

    -- Now, we have all the composite values for the test so create
    -- a new record in GMD_COMPOSITE_RESULTS

    -- Construct the record
    l_composite_result.COMPOSITE_SPEC_DISP_ID   := l_composite_spec_disp.composite_spec_disp_id;
    l_composite_result.TEST_ID                  := test_rec.test_id;
    l_composite_result.MEAN                     := l_mean;
    l_composite_result.MEDIAN_NUM               := l_median_num;
    l_composite_result.MEDIAN_CHAR              := l_median_char;
    l_composite_result.MODE_NUM                 := l_mode_num;
    l_composite_result.MODE_CHAR                := l_mode_char;
    l_composite_result.HIGH_NUM                 := l_high_num;
    l_composite_result.HIGH_CHAR                := l_high_char;
    l_composite_result.LOW_NUM                  := l_low_num;
    l_composite_result.LOW_CHAR                 := l_low_char;
    IF (l_test_type in ('N', 'L', 'E')) THEN
      l_composite_result.RANGE                    := l_high_num - l_low_num;
    ELSE
      l_composite_result.RANGE                    := NULL;
    END IF;
    l_composite_result.STANDARD_DEVIATION       := l_standard_deviation;

    l_composite_result.IN_SPEC_IND              :=
                                    rslt_is_in_spec
                                    (p_spec_id         => l_spec_id,
                                     p_test_id         => test_rec.test_id,
                                     p_rslt_value_num  => l_mean,
                                     p_rslt_value_char => l_mode_char
                                    );

    l_composite_result.DELETE_MARK              := 0;
    l_composite_result.CREATION_DATE            := l_date;
    l_composite_result.CREATED_BY               := l_user_id;
    l_composite_result.LAST_UPDATE_DATE         := l_date;
    l_composite_result.LAST_UPDATED_BY          := l_user_id;
    -- We are ready for insert in GMD_COMPOSITE_RESULTS, so then lets do it.
    IF NOT(GMD_COMPOSITE_RESULTS_PVT.Insert_Row(
                    p_composite_results => l_composite_result,
                    x_composite_results => l_out_composite_result)
            )
    THEN
      -- Insert Error
      RAISE e_comp_result_insert_error;
    END IF;
    l_composite_result.COMPOSITE_RESULT_ID := l_out_composite_result.COMPOSITE_RESULT_ID;

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('    Record created in GMD_COMPOSITE_RESULTS. CR ID - ' || l_composite_result.composite_result_id);
    END IF;

    sample_cnt := 0;

    -- Now record all the result_ids that made up this composite
    FOR result_rec IN c_all_test_data(test_rec.test_id)
    LOOP
      -- Create a new record in GMD_COMPOSITE_RESULT_ASSOC

      -- Construct the record
      l_composite_result_assoc.COMPOSITE_RESULT_ID      := l_composite_result.composite_result_id;
      l_composite_result_assoc.RESULT_ID                := result_rec.result_id;
      l_composite_result_assoc.CREATION_DATE            := l_date;
      l_composite_result_assoc.CREATED_BY               := l_user_id;
      l_composite_result_assoc.LAST_UPDATE_DATE         := l_date;
      l_composite_result_assoc.LAST_UPDATED_BY          := l_user_id;

      -- We are ready for insert in GMD_COMPOSITE_RESULT_ASSOC, so then lets do it.
      IF NOT(GMD_COMPOSITE_RESULT_ASSOC_PVT.Insert_Row(
                      p_composite_result_assoc => l_composite_result_assoc)
              )
      THEN
        -- Insert Error
        RAISE e_comp_rslt_assoc_insert_error;
      END IF;

      IF (l_test_type in ('N', 'L', 'E') AND result_rec.data_num IS NOT NULL) THEN
        sample_cnt := sample_cnt + 1;
      ELSIF (l_test_type in ('T', 'V', 'U') AND result_rec.data_char IS NOT NULL) THEN
        sample_cnt := sample_cnt + 1;
      END IF;

      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('      Created record in GMD_COMPOSITE_RESULT_ASSOC for associated Result ID -' || result_rec.result_id);
      END IF;

    END LOOP;  -- All atomic results for the test

    -- Now update the Sample Total And Sample Count Used fields
    UPDATE gmd_composite_results
    SET    sample_total = sample_cnt,
	   sample_cnt_used = sample_cnt
    WHERE  composite_result_id = l_composite_result.composite_result_id
    AND    test_id = test_rec.test_id
    ;

  END LOOP;  -- All the tests which are composited across multiple samples

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('Leaving Procedure - CREATE_COMPOSITE_ROWS');
  END IF;

  RETURN;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR OR
       e_comp_spec_disp_insert_error OR
       e_comp_result_insert_error OR
       e_comp_rslt_assoc_insert_error
       THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR',
                            'PACKAGE','CREATE_COMPOSITE_ROWS',
                            'ERROR', SUBSTR(SQLERRM,1,100));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END create_composite_rows;



--Start of comments
--+========================================================================+
--| API Name    : qc_mean                                                  |
--| TYPE        : Group                                                    |
--| Notes       : WRITE SOMETHING HERE                                     |
--|                                                                        |
--|                                                                        |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	04-Sep-2002	Created.                           |
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE qc_mean
(
  p_test_id       IN         NUMBER
, x_mean_num      OUT NOCOPY NUMBER
, x_return_status OUT NOCOPY VARCHAR2
)
IS

  -- Curosrs
  CURSOR c_test_type(p_test_id NUMBER) IS
  SELECT test_type
  FROM   gmd_qc_tests_b
  WHERE  test_id = p_test_id
  ;

  CURSOR c_mean(p_test_id NUMBER) IS
  SELECT avg(data_num)
  FROM   gmd_result_data_points_gt
  WHERE  test_id = p_test_id
  AND    exclude_ind = 0
  AND    data_num IS NOT NULL
  ;

  -- Local Variables
  l_test_type        VARCHAR2(1);

BEGIN

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('Entering Procedure - QC_MEAN');
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Get the Test Type
  OPEN c_test_type(p_test_id);
  FETCH c_test_type INTO l_test_type;
  CLOSE c_test_type;

  IF (l_test_type in ('N', 'E', 'L')) THEN
    OPEN c_mean(p_test_id);
    FETCH c_mean INTO x_mean_num;
    CLOSE c_mean;
  END IF;

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('Leaving Procedure - QC_MEAN');
  END IF;
  RETURN;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR',
                            'PACKAGE','QC_MEAN',
                            'ERROR', SUBSTR(SQLERRM,1,100));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END qc_mean;




--Start of comments
--+========================================================================+
--| API Name    : qc_median                                                |
--| TYPE        : Group                                                    |
--| Notes       : This function returns median for the data points in      |
--|               gmd_result_data_points_gt table for a give test_id.      |
--|                                                                        |
--|               If the data points are as below:                         |
--|               5, 11, 14, 16, 20                                        |
--|                                                                        |
--|               Then the median is = 14 (Middle no. after sorting)       |
--|                                                                        |
--|               And if the data points are as below:                     |
--|               5, 11, 14, 16, 20, 30                                    |
--|                                                                        |
--|               Then the median is = 15 (14+16)/2)                       |
--|                                                                        |
--|               THIS PROCEDURE CAN ALSO BE CALLED FOR CHARACTER TEST     |
--|               TYPES.                                                   |
--|                                                                        |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	04-Sep-2002	Created.                           |
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE qc_median
(
  p_test_id       IN         NUMBER
, x_median_num    OUT NOCOPY NUMBER
, x_median_char   OUT NOCOPY VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
)
IS

  -- Curosrs
  CURSOR c_test_type(p_test_id NUMBER) IS
  SELECT test_type
  FROM   gmd_qc_tests_b
  WHERE  test_id = p_test_id
  ;

  CURSOR c_median(p_test_id NUMBER) IS
  SELECT avg(data_num)
  FROM
  (
    SELECT max(data_num) data_num
    FROM
    (
      SELECT data_num
      FROM
      (
        SELECT data_num
        FROM   gmd_result_data_points_gt
        WHERE  test_id = p_test_id
        AND    exclude_ind = 0
	AND    data_num IS NOT NULL
        ORDER BY data_num
      )
      WHERE rownum <= (SELECT ceil(count(*)/2)
                       FROM   gmd_result_data_points_gt
                       WHERE  test_id = p_test_id
                       AND    exclude_ind = 0
		       AND    data_num IS NOT NULL)
    )
    UNION
    SELECT min(data_num) data_num
    FROM
    (
      SELECT data_num
      FROM
      (
        SELECT data_num
        FROM   gmd_result_data_points_gt
        WHERE  test_id = p_test_id
        AND    exclude_ind = 0
	AND    data_num IS NOT NULL
        ORDER BY data_num desc
      )
      WHERE rownum <= (SELECT ceil(count(*)/2)
                       FROM gmd_result_data_points_gt
                       WHERE  test_id = p_test_id
                       AND    exclude_ind = 0
		       AND    data_num IS NOT NULL)
    )
  )
  ;

  CURSOR c_num_to_text (p_test_id NUMBER, p_num NUMBER) IS
  SELECT value_char
  FROM   gmd_qc_test_values_b
  WHERE  test_id        = p_test_id
  AND    text_range_seq = p_num
  ;

  -- Local Variables
  l_test_type        VARCHAR2(1);
  l_count            NUMBER(15);

  -- Exceptions
  e_even_number_data_set      EXCEPTION;

BEGIN

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('Entering Procedure - QC_MEDIAN');
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Get the Test Type
  OPEN c_test_type(p_test_id);
  FETCH c_test_type INTO l_test_type;
  CLOSE c_test_type;

  -- Get the count of data points.
  SELECT nvl(count(*), 0)
  INTO   l_count
  FROM   gmd_result_data_points_gt
  WHERE  test_id = p_test_id
  AND    exclude_ind = 0
  AND    data_num IS NOT NULL
  ;

  -- For character data type we have to have odd number of data points
  -- to determine Median.
  IF (l_test_type = 'T' AND MOD(l_count, 2) = 0 )THEN
    -- Even number of data points, can't find Median, Chief!
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Even data points. Go back.');
    END IF;
    RAISE e_even_number_data_set;
  END IF;

  IF (l_test_type in ('N', 'L', 'E', 'T')) THEN
    OPEN c_median(p_test_id);
    FETCH c_median INTO x_median_num;
    CLOSE c_median;
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Got the median: '|| x_median_num);
    END IF;
  END IF;

  IF (l_test_type = 'T') THEN
    -- Convert Seq for text range back to Character
    OPEN c_num_to_text(p_test_id, x_median_num);
    FETCH c_num_to_text INTO x_median_char;
    CLOSE c_num_to_text;
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('converted the num to char: '|| x_median_char);
    END IF;
  END IF;

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('Leaving Procedure - QC_MEDIAN');
  END IF;

  RETURN;

EXCEPTION
  WHEN e_even_number_data_set THEN
    x_median_num := NULL;
    x_median_char := NULL;
    RETURN;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR',
                            'PACKAGE','qc_median',
                            'ERROR', SUBSTR(SQLERRM,1,100));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END qc_median;




--Start of comments
--+========================================================================+
--| API Name    : qc_mode                                                  |
--| TYPE        : Group                                                    |
--| Notes       : This function returns mode for the data points in        |
--|               gmd_result_data_points_gt table for a give test_id.      |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	04-Sep-2002	Created.                           |
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE qc_mode
(
  p_test_id       IN         NUMBER
, x_mode_num      OUT NOCOPY NUMBER
, x_mode_char     OUT NOCOPY VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
)
IS

  -- Curosrs
  CURSOR c_mode_num(p_test_id NUMBER) IS
  SELECT data_num
  FROM   gmd_result_data_points_gt
  WHERE  test_id = p_test_id
  AND    exclude_ind = 0
  AND    data_num IS NOT NULL
  GROUP BY data_num
  HAVING count(*) = (SELECT max(count(*))
                     FROM   gmd_result_data_points_gt
                     WHERE  test_id = p_test_id
                     AND    exclude_ind = 0
		     AND    data_num IS NOT NULL
                     GROUP BY data_num)
  ;

  CURSOR c_mode_char(p_test_id NUMBER) IS
  SELECT data_char
  FROM   gmd_result_data_points_gt
  WHERE  test_id = p_test_id
  AND    exclude_ind = 0
  AND    data_char IS NOT NULL
  GROUP BY data_char
  HAVING count(*) = (SELECT max(count(*))
                     FROM   gmd_result_data_points_gt
                     WHERE  test_id = p_test_id
                     AND    exclude_ind = 0
		     AND    data_char IS NOT NULL
                     GROUP BY data_char)
  ;


  CURSOR c_test (p_test_id NUMBER) IS
  SELECT test_type
  FROM   gmd_qc_tests_b
  WHERE  test_id = p_test_id
  ;

  CURSOR c_num_to_text (p_test_id NUMBER, p_num NUMBER) IS
  SELECT value_char
  FROM   gmd_qc_test_values_b
  WHERE  test_id        = p_test_id
  AND    text_range_seq = p_num
  ;

  -- Local Variables
  l_test_type          VARCHAR2(1);
  dummy_num            NUMBER;
  dummy_char           VARCHAR2(80);

  -- Exceptions
  e_multi_modal_data_set     EXCEPTION;

BEGIN

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('Entering Procedure - QC_MODE');
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN c_test (p_test_id);
  FETCH c_test INTO l_test_type;
  CLOSE c_test;

  IF (l_test_type IN ('N', 'L', 'E', 'T')) THEN

    OPEN c_mode_num(p_test_id);
    FETCH c_mode_num INTO x_mode_num;

    -- See if we can fetch another Mode, and If we can then the data set
    -- is Multi-Modal.
    FETCH c_mode_num INTO dummy_num;
    IF c_mode_num%FOUND THEN
      RAISE e_multi_modal_data_set;
    END IF;
    CLOSE c_mode_num;

  ELSIF (l_test_type = 'V') THEN

    OPEN c_mode_char(p_test_id);
    FETCH c_mode_char INTO x_mode_char;

    -- See if we can fetch another Mode, and If we can then the data set
    -- is Multi-Modal.
    FETCH c_mode_char INTO dummy_char;
    IF c_mode_char%FOUND THEN
      RAISE e_multi_modal_data_set;
    END IF;

    CLOSE c_mode_char;
  END IF;

  IF (l_test_type = 'T') THEN
    -- Convert Seq for text range back to Character
    OPEN c_num_to_text(p_test_id, x_mode_num);
    FETCH c_num_to_text INTO x_mode_char;
    CLOSE c_num_to_text;

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('converted the num to char: '|| x_mode_char);
    END IF;
  END IF;

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('Leaving Procedure - QC_MODE');
  END IF;

  RETURN;

EXCEPTION
  WHEN e_multi_modal_data_set THEN
    -- We can log a message but since no one is going to use
    -- so just return
    x_mode_num := NULL;
    x_mode_char := NULL;
    RETURN;
  WHEN    FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR',
                            'PACKAGE','QC_MODE',
                            'ERROR', SUBSTR(SQLERRM,1,100));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END qc_mode;



--Start of comments
--+========================================================================+
--| API Name    : qc_high                                                  |
--| TYPE        : Group                                                    |
--| Notes       : WRITE SOMETHING HERE....                                 |
--|                                                                        |
--|                                                                        |
--|                                                                        |
--|                                                                        |
--|                                                                        |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	04-Sep-2002	Created.                           |
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE qc_high
(
  p_test_id       IN         NUMBER
, x_high_num      OUT NOCOPY NUMBER
, x_high_char     OUT NOCOPY VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
)
IS

  -- Curosrs
  CURSOR c_high_num(p_test_id NUMBER) IS
  SELECT max(data_num)
  FROM   gmd_result_data_points_gt
  WHERE  test_id = p_test_id
  AND    exclude_ind = 0
  AND    data_num IS NOT NULL
  ;

  CURSOR c_test (p_test_id NUMBER) IS
  SELECT test_type
  FROM   gmd_qc_tests_b
  WHERE  test_id = p_test_id
  ;

  -- Local Variables
  l_test_type          VARCHAR2(1);

BEGIN

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('Entering Procedure - QC_HIGH');
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN c_test (p_test_id);
  FETCH c_test INTO l_test_type;
  CLOSE c_test;

  IF (l_test_type in ('N', 'L', 'E', 'T')) THEN
    OPEN c_high_num(p_test_id);
    FETCH c_high_num INTO x_high_num;
    CLOSE c_high_num;
  END IF;

  IF (l_test_type = 'T' AND x_high_num IS NOT NULL) THEN
    -- Convert Seq for text range back to Character
    SELECT value_char
    INTO   x_high_char
    FROM   gmd_qc_test_values_b
    WHERE  test_id        = p_test_id
    AND    text_range_seq = x_high_num
    ;
  END IF;

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('Leaving Procedure - QC_HIGH');
  END IF;

  RETURN;

EXCEPTION
  WHEN    FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR',
                            'PACKAGE','QC_HIGH',
                            'ERROR', SUBSTR(SQLERRM,1,100));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END qc_high;




--Start of comments
--+========================================================================+
--| API Name    : qc_low                                                   |
--| TYPE        : Group                                                    |
--| Notes       : WRITE SOMETHING HERE....                                 |
--|                                                                        |
--|                                                                        |
--|                                                                        |
--|                                                                        |
--|                                                                        |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	04-Sep-2002	Created.                           |
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE qc_low
(
  p_test_id       IN         NUMBER
, x_low_num       OUT NOCOPY NUMBER
, x_low_char      OUT NOCOPY VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
)
IS

  -- Curosrs
  CURSOR c_low_num(p_test_id NUMBER) IS
  SELECT min(data_num)
  FROM   gmd_result_data_points_gt
  WHERE  test_id = p_test_id
  AND    exclude_ind = 0
  AND    data_num IS NOT NULL
  ;

  CURSOR c_test (p_test_id NUMBER) IS
  SELECT test_type
  FROM   gmd_qc_tests_b
  WHERE  test_id = p_test_id
  ;

  -- Local Variables
  l_test_type          VARCHAR2(1);

BEGIN

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('Entering Procedure - QC_LOW');
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN c_test (p_test_id);
  FETCH c_test INTO l_test_type;
  CLOSE c_test;

  IF (l_test_type in ('N', 'L', 'E', 'T')) THEN
    OPEN c_low_num(p_test_id);
    FETCH c_low_num INTO x_low_num;
    CLOSE c_low_num;
  END IF;

  IF (l_test_type = 'T' AND x_low_num IS NOT NULL) THEN
    -- Convert Seq for text range back to Character
    SELECT value_char
    INTO   x_low_char
    FROM   gmd_qc_test_values_b
    WHERE  test_id        = p_test_id
    AND    text_range_seq = x_low_num
    ;
  END IF;

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('Leaving Procedure - QC_LOW');
  END IF;

  RETURN;

EXCEPTION
  WHEN    FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR',
                            'PACKAGE','QC_LOW',
                            'ERROR', SUBSTR(SQLERRM,1,100));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END qc_low;



--Start of comments
--+========================================================================+
--| API Name    : qc_standard_deviation                                    |
--| TYPE        : Group                                                    |
--| Notes       : WRITE SOMETHING HERE                                     |
--|                                                                        |
--|                                                                        |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	04-Sep-2002	Created.                           |
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE qc_standard_deviation
(
  p_test_id       IN         NUMBER
, x_stddev        OUT NOCOPY NUMBER
, x_return_status OUT NOCOPY VARCHAR2
)
IS

  -- Curosrs
  CURSOR c_test_type(p_test_id NUMBER) IS
  SELECT test_type
  FROM   gmd_qc_tests_b
  WHERE  test_id = p_test_id
  ;

  CURSOR c_stddev(p_test_id NUMBER) IS
  SELECT stddev(data_num)
  FROM   gmd_result_data_points_gt
  WHERE  test_id = p_test_id
  AND    exclude_ind = 0
  AND    data_num IS NOT NULL
  ;

  -- Local Variables
  l_test_type        VARCHAR2(1);

BEGIN

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('Entering Procedure - QC_STANDARD_DEVIATION');
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Get the Test Type
  OPEN c_test_type(p_test_id);
  FETCH c_test_type INTO l_test_type;
  CLOSE c_test_type;

  IF (l_test_type in ('N', 'E', 'L')) THEN
    OPEN c_stddev(p_test_id);
    FETCH c_stddev INTO x_stddev;
    CLOSE c_stddev;
  END IF;

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('Leaving Procedure - QC_STANDARD_DEVIATION');
  END IF;

  RETURN;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR',
                            'PACKAGE','qc_standard_deviation',
                            'ERROR', SUBSTR(SQLERRM,1,100));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END qc_standard_deviation;

--+========================================================================+
--| API Name    : get_composite_rslt                              |
--| TYPE        : Group                                                    |
--| Notes       : This procedure receives as input composite spec disp id  and       |
--|               retrieves composite results               |
--|                                                                        |
--|               If everything is fine then OUT parameter                 |
--|               x_return_status is set to 'S' else appropriate           |
--|               error message is put on the stack and error              |
--|               is returned.                                             |
--|                                                                        |
--| HISTORY                                                                |
--|   Ger Kelly  17 Sep 2002	Created.                           |
--|   GK 	 17 Oct 2002    B 2621648 Changed the IF, ELSIF to IF END IF for the text chars
--|                                                                        |
--|    Chetan Nagar	01-Apr-2002	Added exclude_ind column condition |
--|       in select for table - gmd_spec_tests_b                           |
--+========================================================================+
PROCEDURE get_composite_rslt
(
  p_composite_spec_disp_id  IN  NUMBER,
  p_source_spec_id		  IN NUMBER,
  p_target_spec_id		  IN NUMBER,
  x_comresults_tab        OUT NOCOPY GMD_RESULTS_GRP.gmd_comres_tab,
  x_return_status         OUT NOCOPY VARCHAR2) IS

  -- Local Variables

  l_spec_id             NUMBER(15);
  i				        NUMBER :=0;
  j			            NUMBER :=0;
  k			            NUMBER :=0;

  l_spec_ind			VARCHAR2(1);
  l_test_id		        NUMBER;
  l_result_id           NUMBER(15);
  l_mode_num            NUMBER;
  l_mode_char           VARCHAR2(80);
  l_median_num          NUMBER;
  l_median_char         VARCHAR2(80);

  l_comres_tab          GMD_RESULTS_GRP.gmd_comres_tab;
  return_status			VARCHAR2(1);
  x_test_ids			GMD_API_PUB.number_tab;


  -- Cursors

CURSOR c_get_composite_results IS
  SELECT cr.composite_spec_disp_id,
         cr.composite_result_id,
         cr.in_spec_ind,
         cr.test_id,
         cr.median_num,
         cr.median_char,
         cr.mode_num,
         cr.mode_char
   FROM  gmd_composite_results cr
   WHERE cr.composite_spec_disp_id = p_composite_spec_disp_id;
   LocalComResRec   c_get_composite_results%ROWTYPE;

 CURSOR c_get_type IS
      SELECT  t.test_type, t.test_code, t.test_method_id, m.test_method_code
      FROM    gmd_qc_tests_b t , gmd_test_methods_b m
      WHERE   t.test_id = l_test_id
      AND     t.test_method_id = m.test_method_id;
  LocalTypeRec	c_get_type%ROWTYPE;

  CURSOR c_get_spec_test_num IS
      SELECT  s.min_value_num, s.max_value_num, s.target_value_num
      FROM    gmd_spec_tests_b s
      WHERE   s.spec_id = l_spec_id
      AND     s.test_id = l_test_id
      AND     s.exclude_ind IS NULL;
  LocalNumRec   c_get_spec_test_num%ROWTYPE;

   CURSOR c_get_spec_test_char IS
      SELECT  s.min_value_char, s.max_value_char, s.target_value_char
      FROM    gmd_spec_tests_b s
      WHERE   s.spec_id = l_spec_id
      AND     s.test_id = l_test_id
      AND     s.exclude_ind IS NULL;
  LocalCharRec   c_get_spec_test_char%ROWTYPE;


  BEGIN
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Since we have a specification
   --retrieve rows in GMD_COM_RESULTS for all the tests
    l_comres_tab.DELETE;
    i := 0;

    -- Get the results for each sample and spec

      FOR LocalComResRec IN c_get_composite_results LOOP
      i := i + 1;

      l_test_id := LocalComResRec.test_id;
      l_comres_tab(i).test_id := l_test_id;
      l_comres_tab(i).in_spec := LocalComResRec.in_spec_ind;
      l_mode_num :=  LocalComResRec.mode_num;
      l_mode_char :=  LocalComResRec.mode_char;
      l_median_num := LocalComResRec.median_num;
      l_median_char := LocalComResRec.median_char;

      -- For each test type get the test and method info
      OPEN c_get_type;
      FETCH c_get_type INTO LocalTypeRec;
       l_comres_tab(i).test_code := LocalTypeRec.test_code;
      CLOSE c_get_type;

      IF LocalTypeRec.test_type IN ('T', 'L', 'V')  THEN
        IF l_mode_num IS NOT NULL THEN
         l_comres_tab(i).result_num := l_mode_num;
        ELSE
      	 l_comres_tab(i).result_char := l_mode_char;
        END IF;
      ELSIF LocalTypeRec.test_type IN ('N', 'U', 'E') THEN
        IF l_median_num IS NOT NULL THEN
       	 l_comres_tab(i).result_num := l_median_num;
        ELSE
      	 l_comres_tab(i).result_char := l_median_char;
        END IF;
      END IF;
      IF LocalTypeRec.test_type IN ('N', 'L', 'V', 'T', 'E', 'U')  THEN
         -- Get the values for the Current Spec
         l_spec_id := p_source_spec_id;

         OPEN c_get_spec_test_num;
         FETCH c_get_spec_test_num INTO LocalNumRec;
           IF c_get_spec_test_num %FOUND THEN
      	    l_comres_tab(i).target_num := LocalNumRec.target_value_num;
      	    l_comres_tab(i).min_num := LocalNumRec.min_value_num;
      	    l_comres_tab(i).max_num := LocalNumRec.max_value_num;
      	   END IF;
         CLOSE c_get_spec_test_num;

       --Get the values for the Comparison Spec
          l_spec_id := p_target_spec_id;

          OPEN c_get_spec_test_num;
          FETCH c_get_spec_test_num INTO LocalNumRec;
          IF c_get_spec_test_num %FOUND THEN
             l_comres_tab(i).spec_target_num := LocalNumRec.target_value_num;
      	     l_comres_tab(i).spec_min_num := LocalNumRec.min_value_num;
      	     l_comres_tab(i).spec_max_num := LocalNumRec.max_value_num;
          END IF;
          CLOSE c_get_spec_test_num;

      END IF;
      IF LocalTypeRec.test_type IN ('V', 'T', 'L', 'E') THEN
       -- Get the values for the Current Specfor chars
        l_spec_id := p_source_spec_id;

        OPEN c_get_spec_test_char;
        FETCH c_get_spec_test_char INTO LocalCharRec;
        IF c_get_spec_test_char%FOUND THEN
           l_comres_tab(i).target_char := LocalCharRec.target_value_char;
           l_comres_tab(i).min_char := LocalCharRec.min_value_char;
           l_comres_tab(i).max_char := LocalCharRec.max_value_char;
        END IF;
        CLOSE c_get_spec_test_char;

      --Get the values for the Comparison Spec
          l_spec_id := p_target_spec_id;

        OPEN c_get_spec_test_char;
        FETCH c_get_spec_test_char INTO LocalCharRec;
        IF c_get_spec_test_char%FOUND THEN
      	  l_comres_tab(i).spec_target_char := LocalCharRec.target_value_char;
	      l_comres_tab(i).spec_min_char := LocalCharRec.min_value_char;
          l_comres_tab(i).spec_max_char := LocalCharRec.max_value_char;
      	END IF;
 	    CLOSE c_get_spec_test_char;

      END IF;
    l_comres_tab(i).in_spec := GMD_RESULTS_GRP.rslt_is_in_spec
	( p_source_spec_id, l_test_id, l_comres_tab(i).result_num, l_comres_tab(i).result_char);
IF (l_debug = 'Y') THEN
   gmd_debug.put_line('in speca '||l_comres_tab(i).in_spec);
END IF;
    l_comres_tab(i).spec_in_spec := GMD_RESULTS_GRP.rslt_is_in_spec
	( p_target_spec_id, l_test_id, l_comres_tab(i).result_num, l_comres_tab(i).result_char);
IF (l_debug = 'Y') THEN
   gmd_debug.put_line('in spec '||l_comres_tab(i).spec_in_spec);
END IF;
    x_comresults_tab(i) := l_comres_tab(i);


    END LOOP;  -- Composite Results test Loop
    j := i;
    l_spec_id := p_target_spec_id;

    GMD_RESULTS_GRP.compare_cmpst_rslt_and_spec
        (p_composite_spec_disp_id, l_spec_id, x_test_ids, return_status);

         FOR k in 1..x_test_ids.COUNT LOOP
	    i := i + k;
            l_test_id := x_test_ids(k);

          OPEN c_get_type;
          FETCH c_get_type INTO LocalTypeRec;
	  CLOSE c_get_type;
      	  l_comres_tab(i).test_code := LocalTypeRec.test_code;

        IF LocalTypeRec.test_type IN ('N', 'L', 'V', 'T', 'E', 'U')  THEN
      	  -- Get the values for the Comparison Spec

           OPEN c_get_spec_test_num;
           FETCH c_get_spec_test_num INTO LocalNumRec;
           IF c_get_spec_test_num %FOUND THEN
             l_comres_tab(i).spec_target_num := LocalNumRec.target_value_num;
      	     l_comres_tab(i).spec_min_num := LocalNumRec.min_value_num;
      	     l_comres_tab(i).spec_max_num := LocalNumRec.max_value_num;
           END IF;
           CLOSE c_get_spec_test_num;
        END IF;

        IF LocalTypeRec.test_type IN ('V', 'T', 'L', 'E') THEN
        -- Get the values for the Comparison Test for chars

        OPEN c_get_spec_test_char;
        FETCH c_get_spec_test_char INTO LocalCharRec;
        IF c_get_spec_test_char%FOUND THEN
      	    l_comres_tab(i).spec_target_char := LocalCharRec.target_value_char;
	    l_comres_tab(i).spec_min_char := LocalCharRec.min_value_char;
            l_comres_tab(i).spec_max_char := LocalCharRec.max_value_char;
      	END IF;
 	CLOSE c_get_spec_test_char;
 	END IF;

 	l_comres_tab(i).spec_in_spec := GMD_RESULTS_GRP.rslt_is_in_spec
		( p_target_spec_id, l_test_id, l_comres_tab(i).result_num, l_comres_tab(i).result_char);
IF (l_debug = 'Y') THEN
   gmd_debug.put_line('in spec1 '||l_comres_tab(i).spec_in_spec);
END IF;
	 x_comresults_tab(i) := l_comres_tab(i);

    END LOOP;


EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END get_composite_rslt;





--+========================================================================+
--| change_lot_status
--| DESCRIPTION
--|    Called from check_disp procedure.
--| This procedure gets the reason code from the quality config table and
--| calls the update_lot procedure.
--| This procedure assumes the proper disposition and status have already
--| been determined.
--+========================================================================+
PROCEDURE change_lot_status
( p_sample_id        IN         NUMBER
, p_organization_id  IN         NUMBER
, p_lot_status       IN         VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
) IS

  -- Local Variables
  l_reason_id    gmd_quality_config.transaction_reason_id%TYPE;
  l_message_data   VARCHAR2(2000);

  -- this is almost the same cursor as cur_global_configurator
  -- in the samples form.
  CURSOR Cur_quality_config (p_organization_id NUMBER) IS
  SELECT transaction_reason_id
  FROM   gmd_quality_config
  WHERE  organization_id = p_organization_id
  AND    transaction_reason_id IS NOT NULL
  ;

BEGIN
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (l_debug = 'Y') THEN
    gmd_debug.put_line('Entering procedure: CHANGE_LOT_STATUS');
  END IF;

  -- Get the reason code from quality configuration/parameters
  OPEN  Cur_quality_config(p_organization_id);
  FETCH Cur_quality_config INTO l_reason_id ;
  IF Cur_quality_config%NOTFOUND THEN                 -- #1
    CLOSE Cur_quality_config;
    GMD_API_PUB.Log_Message('GMD_QM_INV_REASON_CODE');
    RAISE FND_API.G_EXC_ERROR;
  END IF;                                             -- #1
  CLOSE Cur_quality_config;

  IF (l_debug = 'Y') THEN
    gmd_debug.put_line('  Lot status ' || p_lot_status || ' Reason ID ' || TO_CHAR(l_reason_id));
  END IF;


  IF  p_lot_status IS NOT NULL  THEN                 -- #3
    -- no grade, no composite id,
--rconv
    gmd_samples_grp.update_lot_grade_batch(         -- nsrivast
	  	  p_sample_id		=> p_sample_id
		, p_composite_spec_disp_id  => NULL
		, p_to_lot_status_id	=> p_lot_status
        , p_from_lot_status_id	=> NULL --p_from_lot_status
		, p_to_grade_code		=> NULL
        , p_from_grade_code		=> NULL
		, p_to_qc_status	=> NULL
 	    , p_hold_date       => NULL
		, p_reason_id		=> l_reason_id
 --   , p_update_child => NULL -- Added for Results Convergence. rboddu.
		, x_return_status 	=> x_return_status
		, x_message_data	=> l_message_data );

    IF x_return_status <> 'S' THEN          -- #4
      GMD_API_PUB.Log_Message(l_message_data);
      RAISE FND_API.G_EXC_ERROR;
    END IF;                                 -- #4
  END IF;                                            -- #3

  IF (l_debug = 'Y') THEN
    gmd_debug.put_line('  Leaving Procedure: CHANGE_LOT_STATUS');
  END IF;


EXCEPTION
  WHEN    FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR',
                            'PACKAGE','CHANGE_LOT_STATUS','ERROR', SUBSTR(SQLERRM,1,100));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END change_lot_status;





--  /*#####################################################
--  # NAME
--  #    is_value_numeric
--  # SYNOPSIS
--  #    Proc  is_value_numeric
--  #    Parms X_temp
--  # DESCRIPTION
--  #    This function returns TRUE if result is numeric else
--  #    returns FALSE.
--  #####################################################*/

FUNCTION is_value_numeric (p_char_number VARCHAR2)
RETURN BOOLEAN IS
  l_dummy NUMBER;
BEGIN
  l_dummy := TO_NUMBER(p_char_number);
  RETURN TRUE;
EXCEPTION
  WHEN VALUE_ERROR THEN
    RETURN FALSE;
  WHEN OTHERS THEN
    RETURN FALSE;
END is_value_numeric;




--  /*#####################################################
--  # NAME
--  #    check_experimental_error
--  # SYNOPSIS
--  #    Proc  check_experimental_error
--  #    See QC4H DLD for write-up on fuzzy zones.
--  #    1) If error type is PCT, calculate the raw numbers using spec min /spec max
--  #    2) Calculate the upper and lower bounds of the fuzzy zones
--  #    3) Check if the result falls within these bounds.
--  #    4) If so, show the warning with the corresponding action code / desc.
--  #       Pass back flags.
--  # DESCRIPTION
--  #   The following columns from RESULT_DATA record are used:
--  #      result(already rounded, already validated against test limits),
--  #      exp_error_type, min_num, max_num,
--  #      spec_min_num, spec_max_num, out-action-code,
--  #      below_spec_min, above_spec_min, below_spec_max, above_spec_max
--  #      action code fields corresponding to above exp error regions.
--  #   The following fields are updated by this procedure:
--  #      in_fuzzy_zone, result_action_code
--  # HISTORY
--  # L.R.Jackson  Sept/Oct 2002
--  #####################################################*/


PROCEDURE check_experimental_error
( p_result_rec     IN OUT NOCOPY  RESULT_DATA
, x_return_status     OUT NOCOPY  VARCHAR2
)   IS

  L_below_min  NUMBER;
  L_above_min  NUMBER;
  L_below_max  NUMBER;
  L_above_max  NUMBER;

  L_test_range       NUMBER;     --  percentages are calculated
                                 --  against the test range.
  L_lower_bound_min  NUMBER;        -- fuzzy zone is from the lower bound
  L_upper_bound_min  NUMBER;        -- of the min to the upper bound of the spec min
  L_lower_bound_max  NUMBER;        -- and from the lower bound of the spec max
  L_upper_bound_max  NUMBER;        -- to the upper bound of the spec max.
                                    -- "outside" and "inside" fields CAN be null or 0

  -- assign the block.field to variables so that forms does not have to look up
  -- the value each time it is referenced in the procedure.
  L_result           NUMBER  := to_number(p_result_rec.result);

BEGIN

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('Entering procedure CHECK_EXPERIMENTAL_ERROR');
  END IF;

  p_result_rec.in_fuzzy_zone := 'FALSE';

  L_below_min  := p_result_rec.below_spec_min ;
  L_above_min  := p_result_rec.above_spec_min  ;
  L_below_max  := p_result_rec.below_spec_max  ;
  L_above_max  := p_result_rec.above_spec_max ;

  IF p_result_rec.exp_error_type IS NOT NULL THEN
    -- convert percentages to raw numbers
    IF p_result_rec.exp_error_type = 'P' THEN
      L_test_range := p_result_rec.max_num - p_result_rec.min_num;
      L_below_min  := (L_below_min * .01) * L_test_range;
      L_above_min  := (L_above_min * .01) * L_test_range;
      L_below_max  := (L_below_max * .01) * L_test_range;
      L_above_max  := (L_above_max * .01) * L_test_range;
    END IF;      -- end if error type is pct or num

    L_lower_bound_min := p_result_rec.spec_min_num - L_below_min;
    L_upper_bound_min := p_result_rec.spec_min_num + L_above_min;
    L_lower_bound_max := p_result_rec.spec_max_num - L_below_max;
    L_upper_bound_max := p_result_rec.spec_max_num + L_above_max;

    IF (l_debug = 'Y') THEN
      gmd_debug.put_line('Exp Error Type ' || p_result_rec.exp_error_type ||
            ' Result ' || L_result ||' Test Range ' || L_test_range);
      gmd_debug.put_line
           (' Lower Bound Min ' || L_lower_bound_min ||
            ' Upper Bound Min ' || L_upper_bound_min ||
            ' Lower Bound Max ' || L_lower_bound_max ||
            ' Upper Bound Max ' || L_upper_bound_max );
    END IF;

    IF (L_result >= L_lower_bound_min and L_result < p_result_rec.spec_min_num)  THEN --Bug5220513 made < instead of <=
        p_result_rec.result_action_code := p_result_rec.below_min_action_code ;
        p_result_rec.in_fuzzy_zone      := 'TRUE';
    ELSIF (L_result >= p_result_rec.spec_min_num and L_result < L_upper_bound_min)  THEN  --Bug5220513 made < instead of <=
        p_result_rec.result_action_code := p_result_rec.above_min_action_code;
        p_result_rec.in_fuzzy_zone      := 'TRUE';
    ELSIF (L_result >= L_lower_bound_max and L_result <= p_result_rec.spec_max_num) THEN
        p_result_rec.result_action_code := p_result_rec.below_max_action_code;
        p_result_rec.in_fuzzy_zone      := 'TRUE';
    ELSIF (L_result >= p_result_rec.spec_max_num and L_result <= L_upper_bound_max)  THEN
        p_result_rec.result_action_code := p_result_rec.above_max_action_code;
        p_result_rec.in_fuzzy_zone      := 'TRUE';
    ELSIF (L_result < p_result_rec.spec_min_num
        OR L_result > p_result_rec.spec_max_num)  THEN
        -- if out of bounds, copy out of bounds action code
        p_result_rec.result_action_code := p_result_rec.out_action_code ;
    END IF;          -- end if result falls in any of the fuzzy zones

    IF p_result_rec.in_fuzzy_zone = 'TRUE' THEN
      FND_MESSAGE.SET_NAME ('GMD', 'GMD_QC_IN_EXPERIMENTAL_ERROR');
    END IF;
    IF p_result_rec.result_action_code is not NULL THEN
      FND_MESSAGE.SET_NAME ('GMD', 'GMD_QM_RSLT_OUT_OF_SPEC_ACT');
    END IF;
  END IF;            -- end if there is a value in error type,
                     -- experimental error is optional.

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('In Fuzzy Zone ' || p_result_rec.in_fuzzy_zone ||
            ' Action Code ' || p_result_rec.result_action_code);
  END IF;

EXCEPTION
  WHEN    FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR',
                            'PACKAGE','CHECK_EXPERIMENTAL_ERROR','ERROR', SUBSTR(SQLERRM,1,100));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END check_experimental_error;


--Start of comments
--+========================================================================+
--| API Name    : validate_resource                                        |
--| TYPE        : Group                                                    |
--| Notes       : Validates the resource and resource instance passed to   |
--|               public API.                                              |
--|                                                                        |
--|                                                                        |
--|                                                                        |
--|                                                                        |
--| HISTORY                                                                |
--|    Manish Gupta     17-Jan-2003     Created.                           |
--|                                                                        |
--+========================================================================+
FUNCTION isvalid_resource(p_lab_organization_id  NUMBER,
                          p_resource          VARCHAR2,
                          p_resource_instance NUMBER) RETURN BOOLEAN IS

CURSOR c_validate_resource (p_resource VARCHAR)
IS
 SELECT 1
 FROM cr_rsrc_mst
 WHERE resources = p_resource
 AND   delete_mark = 0;

CURSOR c_validate_resource_instance (p_resource VARCHAR,
                                     p_resource_instance VARCHAR)
IS
 SELECT 1
 FROM   gmp_resource_instances ri,
       cr_rsrc_dtl rd
 WHERE rd.resources  = p_resource
 AND   rd.organization_id =  p_lab_organization_id
 AND   rd.resource_id = ri.resource_id
 AND   ri.instance_id = p_resource_instance
 AND   ri.inactive_ind = 0;

l_dummy     PLS_INTEGER;

BEGIN
  --=========================================
   -- Validate Resource and Resource Instance.
   --==========================================

    IF (p_resource IS NULL AND p_resource_instance IS NOT NULL) THEN
      RETURN FALSE;
    END IF;

    IF (p_resource IS NOT NULL) THEN

      OPEN c_validate_resource(p_resource);
      FETCH c_validate_resource INTO l_dummy;
      IF (c_validate_resource%NOTFOUND) THEN
        CLOSE c_validate_resource;
        RETURN FALSE;
      END IF;
      CLOSE c_validate_resource;

      IF (p_resource_instance IS NOT NULL) THEN

        OPEN c_validate_resource_instance(p_resource,
                                          p_resource_instance);
        FETCH  c_validate_resource_instance INTO l_dummy;
        IF (c_validate_resource_instance%NOTFOUND) THEN
          CLOSE c_validate_resource_instance;
          RETURN FALSE;
        END IF;
        CLOSE c_validate_resource_instance;

      END IF;

    END IF;  -- p_results_rec.planned_resource IS NOT NULL
    RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
     NULL;
END isvalid_resource;



--/*#####################################################
--  # NAME
--  #    validate_result
--  # SYNOPSIS
--  #    Proc
--  # DESCRIPTION
--  #   1. If no result, clear other fields.
--  #   2. Determine result_num and/or result_char
--  #   3. Round, if numeric test type
--  #   4. Check result against Test limits.
--  #      If not called from the form and test type is V,
--  #      validate that the result is IN the list in test_values table.
--  #   5. Call API to determine in or out of spec
--  #   6. Check experimental error, if numeric test type
--  #   7. Set evaluation field and, possibly, action field.
--  #      and out_of_spec flag.
--  #
--  #  The following fields from the RESULTS_DATA record are used:
--  #   test_id and test type are required.
--  #    test_id, test_type,result, min_num, max_num,
--  #    spec_min_num, spec_max_num, spec_id, display_precision,
--  #    report_precision, additional_test_ind, exp_error_type,
--  #    4 experimental error number fields, 4 experimental error
--  #    action code fields, out_action_code, called_from_form.
--  #  The following fields are updated by this procedure:
--  #    result, result_num, result_char, result_date, in_spec,
--  #    evaluation_ind, result_action_code, display_label,
--  #    value_in_report_precision, out_of_spec, in_fuzzy_zone,
--  #    x_return_status
--  #  Assumptions:  For numeric tests, if no spec-level exp
--  #    error data is given, calling programs have provided
--  #    any test-level experimental error data.
--  #
--  #  Srastogi : added test_id and test_type to the call
--  #             GMD_SPEC_GRP.spec_test_min_target_max_valid
--  #####################################################*/


PROCEDURE validate_result
( p_result_rec     IN OUT NOCOPY result_data
, x_return_status  OUT    NOCOPY VARCHAR2
) IS

  L_num_result    NUMBER;

BEGIN

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('Entering procedure VALIDATE_RESULT');
  END IF;

  IF p_result_rec.result IS NULL THEN
        --#. ===========================
        --#. They didn't enter a result!
        --#. ===========================

    p_result_rec.result_date          := NULL;
    p_result_rec.in_spec              := NULL;
    p_result_rec.evaluation_ind       := NULL;
    p_result_rec.result_num           := NULL;
    p_result_rec.result_char          := NULL;
    p_result_rec.display_label        := NULL;
    p_result_rec.result_action_code   := NULL;
    p_result_rec.value_in_report_prec := NULL;

  ELSE
    --#. =========================================================
    --#. start fresh in case new result is ok
    --#. and no action code should be displayed.
    --#. =========================================================
    p_result_rec.result_action_code := NULL;

    IF p_result_rec.test_type in ('N', 'L', 'E') THEN

      --#. =========================================================
      --#. Ensure the value is numeric. If not, return user to field
      --#. Apply decimal precision.
      --#. =========================================================
      IF NOT (is_value_numeric (p_result_rec.result)) THEN
        GMD_API_PUB.Log_Message('GMD', 'QC_NOTNUMERIC');
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      L_num_result := ROUND(to_number(p_result_rec.result) ,
                             p_result_rec.display_precision);
      p_result_rec.value_in_report_prec := ROUND(to_number(p_result_rec.result),
                             p_result_rec.report_precision);
      p_result_rec.result_num := l_num_result;
      p_result_rec.result     := l_num_result;    -- used in check-exp-error

      --#. =========================================================
      --#. Send test min, result, test max to function.
      --#. Is result within Test-level min and max?
      --#. =========================================================

      IF NOT GMD_SPEC_GRP.spec_test_min_target_max_valid
                           (  p_test_id   => p_result_rec.test_id
                            , p_test_type => p_result_rec.test_type
                            , p_validation_level => 'ST_TARGET'
                            , p_st_min    => NULL
                            , p_st_target => L_num_result
                            , p_st_max    => NULL
                            , p_t_min     => p_result_rec.min_num
                            , p_t_max     => p_result_rec.max_num
                           )     THEN
        GMD_API_PUB.Log_Message('GMD', 'NOT_IN_RANGE');
        IF  p_result_rec.test_type = 'E' THEN
          -- if expression give warning, not error
          x_return_status := 'E';           -- expected error
        ELSE
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;     -- end if within test min/max

      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('Result is within test range.  Rounded value = ' || L_num_result);
      END IF;

      IF p_result_rec.test_type = 'L' THEN
         p_result_rec.display_label := GMD_QC_TEST_VALUES_GRP.get_test_value_desc
                                        (p_test_id        => p_result_rec.test_id,
                                         p_test_value_num => L_num_result
                                        );
      END IF;  -- end if test is num range w/ display, get label

    ELSE
      -- else test type is V, T, U
      IF p_result_rec.called_from_form = 'N'
            OR p_result_rec.called_from_form is NULL THEN
      null;
      END IF;
      -- move result to result_char
      p_result_rec.result_char := p_result_rec.result;
      --RLNAGARA Bug 3892837 Added below line because the result_num value will be assigned in the IF condition when there is
      -- a Numeric result but this does not get cleared and hence it has to be cleared when it is not Numeric.
      p_result_rec.result_num := NULL;

    END IF;           -- move result to result...num or result...char

    IF  p_result_rec.additional_test_ind IS NULL THEN
        --#. ====================================================
        --#. If this is not an additional test, then there should
        --#. be a spec.  So we can use the canned in_spec function.
        --#. With additional tests, there is not a spec.
        --#. ===================================================

      p_result_rec.in_spec := GMD_RESULTS_GRP.rslt_is_in_spec
                     (p_spec_id => p_result_rec.spec_id,
                      p_test_id => p_result_rec.test_id,
                      p_rslt_value_num  => p_result_rec.result_num,
                      p_rslt_value_char => p_result_rec.result_char);
      IF p_result_rec.in_spec IS NOT NULL THEN
        p_result_rec.out_of_spec := 'FALSE';
      END IF;
    END IF;    -- end if not an additional test/spec or no spec

    IF (l_debug = 'Y') THEN
      gmd_debug.put_line('After call to rslt_is_is_spec, before call to check_exp_error');
    END IF;

    IF p_result_rec.test_type in ('N', 'L', 'E') THEN

      GMD_RESULTS_GRP.check_experimental_error  ( p_result_rec
                                                , x_return_status );
      IF (x_return_status <> 'S') THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;             -- only send numeric types for exp error checking


    --#. =========================================================
    --#. Only check tests from spec (num or alpha).  There is no
    --#. concept of out-of-spec with additional tests.
    --#. Check if error type is null because tests with error
    --#. types have already been evaluated in fuzzy zone code.
    --#. =========================================================
    IF  p_result_rec.additional_test_ind IS NULL AND
        p_result_rec.exp_error_type IS NULL AND
        p_result_rec.in_spec IS NULL  THEN
      p_result_rec.out_of_spec := 'TRUE';
      p_result_rec.result_action_code := p_result_rec.out_action_code;
    END IF;          -- end if result falls in either of the fuzzy zones


    IF p_result_rec.in_fuzzy_zone = 'TRUE' THEN
      p_result_rec.evaluation_ind := '3E';
    ELSIF (p_result_rec.in_spec IS NOT NULL) THEN
      p_result_rec.evaluation_ind := '0A';
    ELSE
      --#. ===================================================
      --#. Clear the eval indicator and the action code field.
      --#. They are the only ones which could be NULL because
      --#. of a result value.
      --#. ===================================================
      IF p_result_rec.out_of_spec = 'FALSE' THEN
        p_result_rec.result_action_code := NULL;
      END IF;
      p_result_rec.evaluation_ind := NULL;
    END IF;    --  end setting evaluation ind.

  END IF;      -- Result is null then clear, else validate


  --===========================================
  -- Validate Resource
  --===========================================

  IF (NOT isvalid_resource(p_result_rec.lab_organization_id,
                          p_result_rec.planned_resource,
                          p_result_rec.planned_resource_instance)) THEN
    GMD_API_PUB.Log_Message('GMD_INVALID_PARAMETERS');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (NOT isvalid_resource(p_result_rec.lab_organization_id,
                          p_result_rec.actual_resource,
                          p_result_rec.actual_resource_instance)) THEN
    GMD_API_PUB.Log_Message('GMD_INVALID_PARAMETERS');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (l_debug = 'Y') THEN
    gmd_debug.put_line('End of validate_result.  In-Spec ' || p_result_rec.in_spec
                        ||' Evaluation ' || p_result_rec.evaluation_ind
                        ||' Fuzzy ' || p_result_rec.in_fuzzy_zone
                        ||' Out of Spec ' || p_result_rec.out_of_spec);
  END IF;

EXCEPTION
  WHEN    FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR',
                              'PACKAGE','VALIDATE_RESULT','ERROR', SUBSTR(SQLERRM,1,100));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END validate_result;





--/*###########################################################
--# NAME
--#    validate_evaluation_ind
--# DESCRIPTION
--#    Called from when_validate_item procedure.
--#    Validate the Evaluation field based on in or out
--#      of spec, experimental error, current evaluation.
--#    The LOV is used for validation, so must include current value
--#      in the list.  (User cannot CHANGE disp to Exp Error, but it
--#      must be in the list if the system changes to Exp Error.)
--#    Only the manager responsibility has Edit access to this field.
--# HISTORY
--############################################################*/

PROCEDURE validate_evaluation_ind
( p_evaluation_ind      IN         VARCHAR2
, p_in_spec_ind         IN         VARCHAR2
, p_result_value        IN         VARCHAR2
, x_return_status       OUT NOCOPY VARCHAR2
)
IS

BEGIN
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (l_debug = 'Y') THEN
    gmd_debug.put_line('Entering procedure VALIDATE_EVALUATION_IND');
    gmd_debug.put_line ('   Evaluation Ind = ' || p_evaluation_ind);
  END IF;

  --== If no result, eval can be set only to NULL, CANCEL, VOID or
  --    Bug 3763419 - added                  GUARANTEED BY MANUFACTURER


  IF (p_result_value IS NULL       AND
      p_evaluation_ind IS NOT NULL AND
      p_evaluation_ind NOT IN ('4C', '5O', '1Z'))
  THEN
    GMD_API_PUB.Log_message ('GMD', 'GMD_QM_EVAL_BLANK_RESULT');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF nvl(p_in_spec_ind, 'N') = 'Y'  THEN
    -- Result is IN-SPEC
    IF (p_evaluation_ind = '3E') THEN
      GMD_API_PUB.Log_Message('GMD', 'GMD_QM_EVAL_NO_EXP_ERROR');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    -- else not in spec
    --    Bug 3763419 - added         GUARANTEED BY MANUFACTURER
    IF (p_evaluation_ind NOT IN ('1V', '2R', '4C', '5O', '1Z')) THEN
      GMD_API_PUB.Log_Message('GMD', 'GMD_QM_EVAL_OUT_OF_SPEC');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

EXCEPTION
  WHEN    FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR',
                            'PACKAGE','VALIDATE_EVALUATION_IND','ERROR', SUBSTR(SQLERRM,1,100));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END  validate_evaluation_ind;






-- /*###############################################################
-- # NAME
-- #	calc_expression
-- # SYNOPSIS
-- #	proc calc_expression
-- # DESCRIPTION
-- # This assumes records have been posted (if called from forms).
-- # 1. Start at the 1st record.
-- # 2. For each record after the 1st, loop through records, checking
-- #     if they are of type Expression.
-- # 3. If the current test is of type Expression, call the API
-- #     GMD_UTILITY_PKG.parse, which breaks the expression into its
-- #     components.
-- #
-- #
-- #
-- #
-- #
-- #
-- # HISTORY
--|                                                                        |
--|    Chetan Nagar	01-Apr-2002	Added exclude_ind column condition |
--|       in select for table - gmd_spec_tests_b                           |
--|                                                                        |
--|    Vipul Vaish 23-Jul-2003 Bug#3063671                                 |
--|       Added a call to the Validate_Result procedure which is used      |
--|       to update the gmd_spec_results table with proper values when the |
--|       test type is of Expression.                                      |
--|    RajaSekhar 12-Nov-2003 BUG#3243631 Frontport for 3199585            |
--|	Removed checking for the NULL results since expression can be	         |
--|	calculated without Test Result if the expression is written with       |
--|	nvl SQL function.                                                      |
--|                                                                        |
--|    Ravi Boddu 29-APR-2004 Bug 3447472 Test Groups Enhancement          |
--|  Modifed cursors c_exp_test and c_all_ref_test to the data from base   |
--| tables, rather than the Global Temp table gmd_result_data_points_gt    |
--| which fetches only the most recent Test Replicates. Also not calling   |
--| populate_result_data_points anymore
--| RLNAGARA 16-MAR-2006 Bug#5076736. Updating the result date of   |
--| results properly depending on the result value. |
--| RLNAGARA 22-MAR-2006 Bug#5097709. Not evaluating the results           |
--| of expression tests when the refernce tests result vlaues are not      |
--| modified  and their evaluations are modified to void or cancel.        |
--| RAGSRIVA 09-May-2006 Bug# 5195678 Frontport Bug# 5158678               |
--| Modified the cursor c_exp_test to fetch the expression type tests      |
--| details though the result value is not NULL.                           |
-- #######################################################################*/
PROCEDURE calc_expression
( p_sample_id           IN         NUMBER
, p_event_spec_disp_id  IN         NUMBER
, p_spec_id             IN         NUMBER
, x_rslt_tbl            OUT NOCOPY rslt_tbl
, x_return_status       OUT NOCOPY VARCHAR2
) IS

  CURSOR get_referenced_tests (p_exp_test_id NUMBER) IS
      SELECT  expression_ref_test_id
        FROM  gmd_qc_test_values_b
       where test_id = p_exp_test_id;

  -- Modified the following cursor to fetch all the test replicates
  -- whichever is not calculated the Result yet.
  -- Earlier the data was being fetched from Global Temp Table gmd_result_data_points_gt
  -- Test Groups Enh Bug# 3447472
  CURSOR c_exp_test IS
  SELECT t.test_id, t.test_code, t.expression, t.display_precision,
         t.report_precision, r.result_id, r.result_value_num
  FROM   gmd_samples s,
         gmd_results r,
         gmd_spec_results sr,
         gmd_qc_tests_b t
  WHERE  s.sample_id = r.sample_id
  AND    s.sample_id = p_sample_id
  AND    s.retain_as IS NULL
  AND    r.result_id = sr.result_id
  AND    sr.event_spec_disp_id = p_event_spec_disp_id
  AND    NVL(sr.evaluation_ind, 'XX') NOT IN ('5O','4C')
  AND    r.test_id = t.test_id
  AND    t.test_type= 'E'
  AND    sr.delete_mark = 0
  AND    r.delete_mark = 0;
  --AND    r.result_value_num IS NULL; -- Bug# 5195678


  --BEGIN BUG#3063671 Vipul Vaish
  --Declared a Cursor to fetch the test type
   CURSOR   c_spec_test_all (p_spec_id NUMBER, p_test_id NUMBER) IS
    SELECT  *
    FROM   gmd_spec_tests_b
    WHERE  spec_id = p_spec_id
    AND    test_id = p_test_id
   ;

   CURSOR   c_add_test_id (p_event_spec_id NUMBER, p_result_id NUMBER) IS
    SELECT ADDITIONAL_TEST_IND
    FROM   gmd_spec_results
    WHERE  event_spec_disp_id = p_event_spec_id
    AND    result_id          = p_result_id
    ;

   CURSOR c_qc_test_value(p_test_id NUMBER) IS
    SELECT min_value_num,max_value_num
    FROM   gmd_qc_tests_b
    WHERE  test_id = p_test_id
    ;

   l_additional_test_ind VARCHAR2(1);
   l_min_value_num number;
   l_max_value_num number;
   l_spec_test_all  GMD_SPEC_TESTS_B%ROWTYPE;
   --Declared the X_rec of result_data type.
   X_rec                result_data;
  --END BUG#3063671

CURSOR c_all_ref_test (p_exp_test_id NUMBER) IS
  SELECT gtmp.data_num,
         t.test_code
  FROM   gmd_result_data_points_gt gtmp,
         gmd_results r,
         gmd_qc_tests_b t,
         gmd_qc_test_values_b tv
  WHERE  gtmp.result_id = r.result_id
  AND    r.test_id = t.test_id
  AND    t.test_id = tv.expression_ref_test_id
  AND    tv.test_id = p_exp_test_id
  ;

  CURSOR c_spec_test (p_spec_id NUMBER, p_test_id NUMBER) IS
  SELECT display_precision, report_precision
  FROM   gmd_spec_tests_b
  WHERE  spec_id = p_spec_id
  AND    test_id = p_test_id
  AND    exclude_ind IS NULL
  ;

  l_value             NUMBER;
  l_exptab            GMD_UTILITY_PKG.exptab;
  l_boolean           BOOLEAN  := FALSE;
  l_exp_is_null       BOOLEAN;

  i                       PLS_INTEGER;
  l_display_precision     PLS_INTEGER;
  l_report_precision      PLS_INTEGER;
  l_return_status         VARCHAR2(1);
  l_display_value         NUMBER;
  l_report_value          NUMBER;
  l_ref_tests             NUMBER := 0;  --Bug#5097709
  l_ref_count             NUMBER := 0;
  l_samples               GMD_API_PUB.number_tab;

BEGIN

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (l_debug = 'Y') THEN
    gmd_debug.put_line('Entering procedure CALC_EXPRESSION');
    gmd_debug.put_line('   Sample ID = ' || p_sample_id );
  END IF;


  l_samples(1) := p_sample_id;

  -- Load the result data points for the sample
  populate_result_data_points (
      p_sample_ids         => l_samples
    , p_event_spec_disp_id => p_event_spec_disp_id
    , x_return_status      => l_return_status);

  IF (l_return_status <> 'S') THEN
    -- Error message is already logged
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Index variable
  i := 0;

  -- Go through All the Expressions that are in the Sample
  FOR l_exp_test IN c_exp_test
  LOOP
    -- Initialize IN Variable
    l_exp_is_null := FALSE;
    l_display_value := NULL;
    l_report_value  := NULL;

    l_exptab.DELETE;

    -- Parse the expression
    GMD_UTILITY_PKG.parse (
		x_exp           => l_exp_test.expression,
		x_exptab        => l_exptab,
		x_return_status => l_return_status)
         ;

    IF l_return_status <> 'S' THEN
      -- Error message must be already logged
       RAISE FND_API.G_EXC_ERROR;
    END IF;
     select count(*) INTO l_ref_count from gmd_qc_test_values_b where test_id=l_exp_test.test_id; --Bug#5097709
    -- Now we have all the ref. tests for the current expression in l_exptab so
    -- fill-in result_values in l_exptab from _GT table
    FOR l_all_ref_test IN c_all_ref_test(l_exp_test.test_id)
    LOOP
      -- BEGIN BUG#3243631
      -- Commented the below code.
      -- IF (l_all_ref_test.data_num IS NULL) THEN
      -- -- Expression can not be evaluated as one of the reference test
      -- -- does not have result
      --   l_exp_is_null := TRUE;
      --   EXIT;
      -- END IF;
      -- END BUG#3243631
      l_ref_tests := l_ref_tests+1; --Bug#5097709
      GMD_UTILITY_PKG.variable_value (
           pvar_name       => l_all_ref_test.test_code,
           pvar_value      => l_all_ref_test.data_num ,
           p_exptab        => l_exptab,
           x_return_status => l_return_status);
      -- Above procedure does  unconditional FND_MSG_PUB.INITIALIZE;
      -- No need to look at return status
      -- Do the following for the last iteration
      FND_MSG_PUB.INITIALIZE;
    END LOOP;

    -- Expression can only be calculated if all the reference
    -- tests have results entered.
    IF (NOT l_exp_is_null AND l_ref_tests = l_ref_count) THEN  --Bug#5097709
      -- l_exptab is filled-in with values now so evaluate the exp.
      GMD_UTILITY_PKG.evaluate_exp (
  		  pexptab         => l_exptab,
                  pexp_test       => l_boolean,
                  x_value         => l_value,
  		  x_return_status => x_return_status);
      IF x_return_status <> 'S' THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- We have got the expression calculated so format this to
      -- the display and report precision values

      -- Step 1. Get the Display and report precision from Spec else Test
      l_display_precision := 0;
      l_report_precision  := 0;

      IF (p_spec_id IS NULL) THEN
        -- Get it from the Test
        l_display_precision := l_exp_test.display_precision;
        l_report_precision  := l_exp_test.report_precision;
      ELSE
        -- Get it from the Spec Test
        OPEN c_spec_test(p_spec_id, l_exp_test.test_id);
        FETCH c_spec_test INTO l_display_precision, l_report_precision;
        -- Bug# 5087404 Added condition for Tests not in specification but directly included
        IF c_spec_test%ROWCOUNT = 0 THEN
            l_display_precision := l_exp_test.display_precision;
            l_report_precision  := l_exp_test.report_precision;
        END IF;
        CLOSE c_spec_test;
      END IF;

      l_display_value := ROUND(l_value, l_display_precision);
      l_report_value  := ROUND(l_value, l_report_precision);

    END IF;  -- Evalulate Expression

    l_ref_tests := 0;  --Bug#5097709
    l_ref_count := 0;


    -- No need to update the WHO columns as they are either set in the
    -- FORM or the API
    UPDATE gmd_results
    SET    result_value_num = l_display_value,
           result_date = SYSDATE
    WHERE  result_id = l_exp_test.result_id
    ;

--RLNAGARA Bug5076736 Updating the result date of results properly depending on the result value.
     UPDATE gmd_results
     SET    result_date = NULL
     WHERE  result_id = l_exp_test.result_id
     AND  result_value_num IS NULL;

    --BEGIN BUG#3063671 Vipul Vaish
    OPEN c_add_test_id(p_event_spec_disp_id, l_exp_test.result_id);
    FETCH c_add_test_id INTO l_additional_test_ind;
    CLOSE c_add_test_id;

    OPEN c_qc_test_value(l_exp_test.test_id);
    FETCH c_qc_test_value INTO l_min_value_num,l_max_value_num;
    CLOSE c_qc_test_value;

    --Fetching the values depending upon the test id and spec_id.
    OPEN c_spec_test_all(p_spec_id, l_exp_test.test_id);
    FETCH c_spec_test_all INTO l_spec_test_all;
    CLOSE c_spec_test_all;
    --Passing the necessary parameters which are useful while calling the
    --validate_result procedure.
    x_rec.test_id := l_exp_test.test_id;
    x_rec.test_type := 'E';
    x_rec.result := l_display_value;
    x_rec.spec_id := p_spec_id;
    x_rec.spec_min_num := l_spec_test_all.min_value_num;
    x_rec.spec_max_num := l_spec_test_all.max_value_num;
    x_rec.out_action_code := l_spec_test_all.out_of_spec_action;
    x_rec.display_precision :=l_display_precision;
    x_rec.report_precision := l_report_precision;
    x_rec.exp_error_type  := l_spec_test_all.exp_error_type;
    x_rec.below_spec_min := l_spec_test_all.below_spec_min;
    x_rec.above_spec_min := l_spec_test_all.above_spec_min;
    x_rec.below_spec_max := l_spec_test_all.below_spec_max;
    x_rec.above_spec_max := l_spec_test_all.above_spec_max;
    x_rec.below_min_action_code := l_spec_test_all.below_min_action_code;
    x_rec.above_min_action_code := l_spec_test_all.above_min_action_code;
    x_rec.below_max_action_code := l_spec_test_all.below_max_action_code;
    x_rec.above_max_action_code := l_spec_test_all.above_max_action_code;
    x_rec.additional_test_ind   :=l_additional_test_ind;
    x_rec.min_num := l_min_value_num;
    x_rec.max_num := l_max_value_num;

    GMD_RESULTS_GRP.validate_result(x_rec,l_return_status);
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    --Updating the gmd_spec_results table, with proper values
    --which returned during the above call.
    UPDATE gmd_spec_results
    SET    value_in_report_precision = l_report_value,
           in_spec_ind = x_rec.in_spec,
           action_code = x_rec.result_action_code,
           evaluation_ind = x_rec.evaluation_ind
    WHERE  event_spec_disp_id = p_event_spec_disp_id
    AND    result_id          = l_exp_test.result_id
    ;
    --END BUG#3063671.

    -- Increament the index and store the result in OUT variable
    i := i + 1;
    x_rslt_tbl(i).test_id := l_exp_test.test_id;
    x_rslt_tbl(i).value   := l_display_value;

  END LOOP;

EXCEPTION
  WHEN    FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR',
                              'PACKAGE','CALC_EXPRESSION','ERROR', SUBSTR(SQLERRM,1,100));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END calc_expression;







--+========================================================================+
--|NAME
--|   change_sample_disposition
--|SYNOPSIS
--|   Proc check
--|DESCRIPTION
--|   Called from the post_forms_commit procedure.
--|
--|   After posting, before committing, figure out any disposition changes.
--|   If      all tests are canceled, change disposition to Pending.
--|   Else If all tests have a results, change disposition to complete.
--|   Else    Disposition Change not required.
--|
--|                                                                        |
--|    Chetan Nagar	01-Apr-2002	Added exclude_ind column condition |
--|       in select for table - gmd_spec_tests_b  |
--|  RLNAGARA 27-Mar-2006  B5106039 Modified the procedure so that it considers the Flag |
--|                        Consider Optional Tests Result which is there in Process Quality Parameters Form |
--+========================================================================+

PROCEDURE  change_sample_disposition
( p_sample_id        IN         NUMBER
, x_change_disp_to   OUT NOCOPY VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
, x_message_data     OUT NOCOPY VARCHAR2
) IS

  -- Local Variables
  l_count                         NUMBER;
  l_incomplete_count_from_spec    NUMBER := 0;
  l_incomplete_count_additional   NUMBER := 0;
  l_change_disp_to                VARCHAR2(4);
  l_qlty_config_present           NUMBER;    --RLNAGARA B5106039


  l_sample_in                     GMD_SAMPLES%ROWTYPE;
  l_sample                        GMD_SAMPLES%ROWTYPE;
  l_sampling_event_in             GMD_SAMPLING_EVENTS%ROWTYPE;
  l_sampling_event                GMD_SAMPLING_EVENTS%ROWTYPE;
  l_event_spec_disp_in            GMD_EVENT_SPEC_DISP%ROWTYPE;
  l_event_spec_disp               GMD_EVENT_SPEC_DISP%ROWTYPE;
  l_sample_spec_disp_in           GMD_SAMPLE_SPEC_DISP%ROWTYPE;
  l_sample_spec_disp              GMD_SAMPLE_SPEC_DISP%ROWTYPE;
  l_update_disp_rec               GMD_SAMPLES_GRP.update_disp_rec;

  -- Exceptions
  e_sample_fetch_error            EXCEPTION;
  e_sampling_event_fetch_error    EXCEPTION;
  e_sample_spec_disp_fetch_error  EXCEPTION;
  e_event_spec_disp_fetch_error   EXCEPTION;

BEGIN

  IF (l_debug = 'Y') THEN
    gmd_debug.put_line('Entering procedure CHANGE_SAMPLE_DISPOSITION');
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Get the sample record
  l_sample_in.sample_id := p_sample_id;
  IF NOT (GMD_SAMPLES_PVT.fetch_row(
                   p_samples => l_sample_in,
                   x_samples => l_sample)
         )
  THEN
    -- Fetch Error.
    RAISE e_sample_fetch_error;
  END IF;

  -- Get the sampling event record
  l_sampling_event_in.sampling_event_id := l_sample.sampling_event_id;
  IF NOT (GMD_SAMPLING_EVENTS_PVT.fetch_row(
                   p_sampling_events => l_sampling_event_in,
                   x_sampling_events => l_sampling_event)
         )
  THEN
    -- Fetch Error.
    RAISE e_sampling_event_fetch_error;
  END IF;

  -- Check if we already have a record in GMD_EVENT_SPEC_DISP
  l_event_spec_disp_in.event_spec_disp_id := get_current_event_spec_disp_id(
                               l_sampling_event.sampling_event_id);
  -- Get the event spec disp record
  IF NOT (GMD_EVENT_SPEC_DISP_PVT.fetch_row(
                   p_event_spec_disp => l_event_spec_disp_in,
                   x_event_spec_disp => l_event_spec_disp)
         )
  THEN
    -- Fetch Error.
    RAISE e_event_spec_disp_fetch_error;
  END IF;

  -- Get the sample spec record
  l_sample_spec_disp_in.event_spec_disp_id := l_event_spec_disp.event_spec_disp_id;
  l_sample_spec_disp_in.sample_id          := l_sample.sample_id;
  IF NOT (GMD_SAMPLE_SPEC_DISP_PVT.fetch_row(
                   p_sample_spec_disp => l_sample_spec_disp_in,
                   x_sample_spec_disp => l_sample_spec_disp)
         )
  THEN
    -- Fetch Error.
    RAISE e_sample_spec_disp_fetch_error;
  END IF;

  -- =============================================================
  -- If all tests are cancelled (or marked for purge), change
  --   to PENDING.  (Change sample_spec_disp only, not event_spec.)
  -- This rule is applied regardless of if there is a spec for the event.
  -- =============================================================

  -- Select COUNT of tests that have result with valid evaluation
  SELECT count(1)
  INTO   l_count
  FROM   gmd_spec_results sr, gmd_results r
  WHERE  sr.event_spec_disp_id = l_event_spec_disp.event_spec_disp_id
  AND    sr.result_id          = r.result_id
  AND    r.sample_id           = l_sample.sample_id
  AND    (((r.result_value_num IS NOT NULL OR r.result_value_char IS NOT NULL) AND
          nvl(sr.evaluation_ind, 'XX') not in ( '4C')) OR
          (r.result_value_num IS NULL AND r.result_value_char IS NULL AND
          sr.evaluation_ind = '1Z'))

  AND    r.delete_mark         = 0
  ;

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line ('  COUNT of tests that have result with valid evaluation: '  || l_count);
  END IF;


  IF l_count = 0  THEN
    -- There is no valid result on Sample, Set the disposition to 'Pending'
    l_change_disp_to := '1P';
  ELSE
    -- We have got some result so sample is 'In Progress'
    l_change_disp_to := '2I';

    -- =============================================================
    -- Check if this sample is COMPLETE.
    -- If all required tests and additional tests not marked as cancel
    --  or void have a value AND there is a spec, and all have an
    --  evaluation (other than 3E), then change sample_spec_Disp to COMPLETE.
    --
    -- If all samples are now complete or higher, then change event too.
    --
    -- If control_lot_attrib is ON, then check if all evaluations are
    --  "Accept".  If so, change disposition to Accept. Otherwise REJECT
    --  Change lot status.
    --
    -- =============================================================

    -- 1st select tests from spec (where sr.additional_test_ind  is null)

    IF l_event_spec_disp.spec_id is NOT NULL THEN
      -- Sample has a Spec
--RLNAGARA B5106039 start
--RLNAGARA B5106039 Added the below select stmt. Here I am checking whether the quality parameters has been defined for the sample organization
      SELECT count(1) INTO l_qlty_config_present
      FROM gmd_quality_config
      WHERE organization_id = l_sample.organization_id;

      IF l_qlty_config_present = 0 THEN --IF the process parameters for the sample org is not defined then consider only the non-optional test

	      -- Select COUNT of Incomplete Tests in Sample WITH Spec
	      SELECT count(1)
	      INTO   l_incomplete_count_from_spec
	      FROM   gmd_results r, gmd_spec_tests st, gmd_spec_results sr
	      WHERE  sr.event_spec_disp_id = l_event_spec_disp.event_spec_disp_id
	      AND    sr.result_id          = r.result_id
	      AND    r.sample_id           = l_sample.sample_id
	      AND    st.spec_id            = l_event_spec_disp.spec_id
	      AND    st.test_id            = r.test_id
	      AND    st.exclude_ind IS NULL
	      AND    st.optional_ind IS NULL             -- Check only REQUIRED tests
	      AND    (sr.evaluation_ind is NULL          -- No Evaluation --> Incomplete
	               OR sr.evaluation_ind = '3E'       -- Evaluation is 'Exp Error' --> Incomplete
	               OR ( r.result_value_num    IS NULL
	                    AND r.result_value_char   IS NULL
	                    AND sr.evaluation_ind not in ('4C', '5O', '1Z')  -- Result not entered
	                  )
	             )
	      AND  r.delete_mark         = 0              -- Check only active ones
	      ;
       ELSE --IF the process parameters for the sample org is defined then consider the tests based on the vlaue of include_optional_test_rslt_ind checkbox
	      SELECT count(1)
	      INTO   l_incomplete_count_from_spec
	      FROM   gmd_results r, gmd_spec_tests st, gmd_spec_results sr,gmd_quality_config gc
	      WHERE  sr.event_spec_disp_id = l_event_spec_disp.event_spec_disp_id
	      AND    sr.result_id          = r.result_id
	      AND    r.sample_id           = l_sample.sample_id
	      AND    st.spec_id            = l_event_spec_disp.spec_id
	      AND    st.test_id            = r.test_id
	      AND    st.exclude_ind IS NULL
	      AND    gc.organization_id = l_sample.organization_id
	      AND   (
	             ( (gc.include_optional_test_rslt_ind IS NULL OR gc.include_optional_test_rslt_ind='N') and st.optional_ind IS NULL)  OR
	              (gc.include_optional_test_rslt_ind ='Y')
	            )
	      AND    (sr.evaluation_ind is NULL          -- No Evaluation --> Incomplete
	               OR sr.evaluation_ind = '3E'       -- Evaluation is 'Exp Error' --> Incomplete
	               OR ( r.result_value_num    IS NULL
	                    AND r.result_value_char   IS NULL
	                    AND sr.evaluation_ind not in ('4C', '5O', '1Z')  -- Result not entered
	                  )
	             )
	      AND  r.delete_mark         = 0              -- Check only active ones
	      ;

       END IF;  -- l_qlty_config_present = 0
--RLNAGARA B5106039 end
    END IF;

    IF l_incomplete_count_from_spec = 0 THEN
      -- Try to select COUNT of Incomplete Tests in Sample WITHOUT Spec
      SELECT count(1)
      INTO   l_incomplete_count_additional
      FROM   gmd_results r, gmd_spec_results sr
      WHERE  sr.result_id          = r.result_id
      AND    sr.event_spec_disp_id = l_event_spec_disp.event_spec_disp_id
      AND    r.sample_id           = l_sample.sample_id
      AND    sr.additional_test_ind = 'Y'
      AND    (sr.evaluation_ind  is NULL
               OR sr.evaluation_ind = '3E'
               OR ( r.result_value_num    IS NULL
                    AND r.result_value_char   IS NULL
                    AND sr.evaluation_ind not in ('4C', '5O')
                  )
             )
      AND    r.delete_mark         = 0
      ;
    END IF;     -- end if all tests from spec are complete, then check ad hoc

    IF (l_debug = 'Y') THEN
      gmd_debug.put_line ('    COUNT of Incomplete Tests in Sample WITH Spec: '
                       || l_incomplete_count_from_spec);
      gmd_debug.put_line ('    COUNT of Incomplete Tests in Sample WITHOUT Spec: '
                       || l_incomplete_count_additional);

    END IF;

    IF  l_incomplete_count_from_spec + l_incomplete_count_additional = 0  THEN

      -- This means all the results have been entered so set the
      -- disposition to 'Complete'
      l_change_disp_to := '3C';

    END IF; -- Sample is Complete

    x_change_disp_to := l_change_disp_to;

  END IF;  -- Sample Disposition is Determined

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line ('  Old disposition: ' || l_sample_spec_disp.disposition);
     gmd_debug.put_line ('  New disposition: ' || l_change_disp_to);
  END IF;

  -- See if the sample disposition is changing from what it was.
  IF (l_sample_spec_disp.disposition <> l_change_disp_to) THEN

    -- This means that we are changing the disposition of the sample

    -- =======================================================
    -- So change the disposition of
    -- 1. sample_spec_disp
    -- 2. sampling_events (only if one sample required, OR atleast sample_req_cnt are Complete)
    -- 3. event_spec_disp (only if one sample required, OR atleast sample_req_cnt are Complete)
    -- by calling GMD_SAMPLES_GRP.update_sample_comp_disp
    -- =======================================================

    -- Prepare IN parameter
    l_update_disp_rec.sample_id               := l_sample.sample_id;
    l_update_disp_rec.event_spec_disp_id      := l_event_spec_disp.event_spec_disp_id;
    -- l_update_disp_rec.called_from_results     := p_disp_out_rec.called_from_results;
    l_update_disp_rec.no_of_samples_for_event := l_sampling_event.sample_req_cnt;
    -- MAHESH
    l_update_disp_rec.curr_disposition 	      := l_sample_spec_disp.disposition;



    IF (l_debug = 'Y') THEN
       gmd_debug.put_line ('  Call GMD_SAMPLES_GRP.update_sample_comp_disp '|| l_sample_spec_disp.disposition);
    END IF;

    GMD_SAMPLES_GRP.update_sample_comp_disp(
                 p_update_disp_rec => l_update_disp_rec
               , p_to_disposition  => l_change_disp_to
               , x_return_status   => x_return_status
               , x_message_data    => x_message_data);
  END IF;

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line ('Leaving Procedure: CHANGE_SAMPLE_DISPOSITION ' );
  END IF;

EXCEPTION
  WHEN    FND_API.G_EXC_ERROR
       OR e_sample_fetch_error
       OR e_sampling_event_fetch_error
       OR e_sample_spec_disp_fetch_error
       OR e_event_spec_disp_fetch_error
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR',
                            'PACKAGE','change_sample_disposition','ERROR', SUBSTR(SQLERRM,1,100));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END change_sample_disposition;






--+========================================================================+
--|NAME change_disp_for_auto_lot
--|
--|DESCRIPTION
--|  Called from a subscrition to the Event - Complete Sample
--|
--|  NOTE: Only called if:
--|        1. Sample has Spec
--|        2. Sample is 'COMPLETE'
--|
--|    If all tests have eval of Accept, and there is a spec, and control_lot_attrib
--|          is on, change disposition to Accept.
--|    If all tests are Accept or Accept w/Variance, change disp to Accept w/var.
--|
--|HISTORY
--|  RLNAGARA 07-Feb-2006 Bug4918820 Modified the cursor c_sample_dtl
--|  RLNAGARA 01-Aug-2006 Bug5416103 Modified the procedure so as to
--|                       check for control_lot_attrib_ind only while
--|                       changing the lot status instead of while changing
--|                       the disposition of a sample.
--|  Supriya Malluru 04-Oct-2007 Bug6439776. Included NVL() for l_config_opt.
--+========================================================================+

PROCEDURE change_disp_for_auto_lot
( p_sample_id           IN         NUMBER
, x_change_disp_to      OUT NOCOPY VARCHAR2
, x_return_status       OUT NOCOPY VARCHAR2
) IS

--RLNAGARA Bug # 4918820 Changed the view from gmd_all_spec_vrs to gmd_com_spec_vrs_vl
-- Cursor
  CURSOR c_sample_dtl (p_sample_id NUMBER) IS
  SELECT se.sampling_event_id,
         se.sample_active_cnt,
         se.sample_req_cnt,
         esd.event_spec_disp_id,
         esd.spec_id,
         esd.spec_vr_id,
         ssd.disposition,
         svr.control_lot_attrib_ind,
         svr.in_spec_lot_status_id,
         svr.out_of_spec_lot_status_id,
         s.organization_id
  FROM   gmd_sampling_events se,
         gmd_event_spec_disp esd,
         gmd_sample_spec_disp ssd,
         gmd_samples s,
         gmd_com_spec_vrs_vl svr
  WHERE  s.sample_id = p_sample_id
  AND    s.sampling_event_id = se.sampling_event_id
  AND    se.sampling_event_id = esd.sampling_event_id
  AND    esd.spec_used_for_lot_attrib_ind = 'Y'
  AND    esd.event_spec_disp_id = ssd.event_spec_disp_id
  AND    ssd.sample_id = s.sample_id
  AND    svr.spec_vr_id = esd.spec_vr_id
  AND    s.delete_mark = 0
  AND    esd.delete_mark = 0
  AND    ssd.delete_mark = 0
  ;

  l_sample_rec           c_sample_dtl%ROWTYPE;
  l_update_disp_rec      GMD_SAMPLES_GRP.update_disp_rec;

  l_change_disp_to       VARCHAR2(4);
  l_disposition          VARCHAR2(4);

  l_req_cnt              NUMBER;
  l_lot_disp             VARCHAR2(30);
  l_count                NUMBER;
  l_lot_status_id        GMD_QUALITY_CONFIG.in_spec_lot_status_id%TYPE;
  l_message_data         VARCHAR2(2000);

  l_include_optional     VARCHAR2(3);
  l_count_with_spec      NUMBER;
  l_count_wo_spec        NUMBER;

  /*====================
      BUG#4691545
    ====================*/

  CURSOR get_config_opt (p_org_id NUMBER) IS
  SELECT include_optional_test_rslt_ind
  FROM   gmd_quality_config
  WHERE  organization_id = p_org_id;

  l_config_opt           VARCHAR2(1);

BEGIN
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (l_debug = 'Y') THEN
    gmd_debug.put_line('Entering procedure: CHANGE_DISP_FOR_AUTO_LOT.');
  END IF;

  OPEN c_sample_dtl(p_sample_id);
  FETCH c_sample_dtl INTO l_sample_rec;
  IF c_sample_dtl%NOTFOUND THEN
    CLOSE c_sample_dtl;
    GMD_API_PUB.Log_Message('GMD_INVALID_PARAMETERS');
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c_sample_dtl;

  -- ========================================================
  -- Check_event is only called if there is a spec.
  --  Is control_lot_attrib_ind on?
  --  Check this sample.  (Check all samples in events further down.)
  -- ========================================================

  -- Is control_lot_attrib_ind on?
  --IF  l_sample_rec.control_lot_attrib_ind = 'Y' THEN                -- #1  RLNAGARA Bug5416103

    -- This means that user wants to change lot status automatically
    -- to either Accept or Reject.

    /*====================
        BUG#4691545
      ====================*/

    OPEN get_config_opt (l_sample_rec.organization_id);
    FETCH get_config_opt INTO l_config_opt;
    IF (get_config_opt%NOTFOUND) THEN
       l_config_opt := 'N';
    END IF;
    CLOSE get_config_opt;
    l_include_optional := NVL(l_config_opt,'N'); --Bug#6490789, Bug#6439776

    IF (l_debug = 'Y') THEN
      gmd_debug.put_line('Profile GMD: Include Optional Tests in Sample Disposition :' || l_include_optional);
    END IF;

    -- If all tests are accept, cancel or void --> Set to Accept.
    -- If all tests are accept, accept w/var,
    --                        cancel or void   --> Set to Accept w/Variance.
    --
    -- Note: Accept w/var uses the same lot status as Accept.

    -- Select COUNT of tests that either don't have a
    -- result OR are not (Accept, Cancel, or Void)

    -- B2820787 CHANGED FOLLOWING SELECT
    -- SELECT count(1)
    -- INTO   l_count
    -- FROM   gmd_results r, gmd_spec_results sr
    -- WHERE  sr.result_id          = r.result_id
    -- AND    sr.event_spec_disp_id = l_sample_rec.event_spec_disp_id
    -- AND    r.sample_id           = p_sample_id
    -- AND    (sr.evaluation_ind IS NULL OR
    --         sr.evaluation_ind    NOT IN ('0A', '4C', '5O')
    --        )
    -- AND    r.delete_mark         = 0
    -- ;
    -- WITH THE FOLLOWING

    -- B2820787 BEGIN
    l_count           := 0;
    l_count_with_spec := 0;
    l_count_wo_spec   := 0;

    IF l_sample_rec.spec_id IS NOT NULL THEN
      -- Sample has a Spec

      -- Select COUNT of Tests with Evaluation other then ACCEPT
      SELECT count(1)
      INTO   l_count_with_spec
      FROM   gmd_event_spec_disp esd, gmd_results r, gmd_spec_results sr,
             gmd_spec_tests_b st
      WHERE  esd.event_spec_disp_id = l_sample_rec.event_spec_disp_id
      AND    esd.event_spec_disp_id = sr.event_spec_disp_id
      AND    sr.result_id           = r.result_id
      AND    r.sample_id            = p_sample_id
      AND    (sr.evaluation_ind IS NULL OR
              sr.evaluation_ind    NOT IN ('0A', '4C', '5O', '1Z')
             )
      AND    r.delete_mark          = 0
      AND    sr.delete_mark         = 0
      AND    esd.spec_id = st.spec_id
      AND    st.test_id = r.test_id
      AND    ((l_include_optional = 'N' and st.optional_ind IS NULL) OR
              (l_include_optional = 'Y' and (r.result_value_num IS NOT NULL OR
	                                     r.result_value_char IS NOT NULL)
              )
             )
      ;

    END IF;

    IF (l_count_with_spec = 0) THEN

      -- Select COUNT of Tests with Evaluation other then ACCEPT or ACCEPT W/ VAR
      SELECT count(1)
      INTO   l_count_wo_spec
      FROM   gmd_results r, gmd_spec_results sr
      WHERE  sr.event_spec_disp_id = l_sample_rec.event_spec_disp_id
      AND    sr.result_id           = r.result_id
      AND    r.sample_id            = p_sample_id
      AND    sr.additional_test_ind = 'Y'
      AND    (sr.evaluation_ind IS NULL OR
              sr.evaluation_ind    NOT IN ('0A', '4C', '5O')
             )
      AND    r.delete_mark          = 0
      AND    sr.delete_mark         = 0
      ;

    END IF;

    l_count := l_count_with_spec + l_count_wo_spec;

    -- B2820787 END

    IF (l_debug = 'Y') THEN
      gmd_debug.put_line('   Count of tests which do NOT have accept evaluation w/  SPEC :' || l_count);
      gmd_debug.put_line('   Count of tests which do NOT have accept evaluation wo/ SPEC :' || l_count);
      gmd_debug.put_line('   Count of tests which do NOT have accept evaluation Total    :' || l_count);
    END IF;

    IF  l_count = 0  THEN                                -- #2
      -- This means that all results are 'Accept' so change
      -- the disposition for 'ACCEPT'
      l_change_disp_to := '4A';

      -- Set the lot status to In-Spec Lot Status
      IF l_sample_rec.control_lot_attrib_ind = 'Y' THEN       --RLNAGARA Bug5416103
	l_lot_status_id := l_sample_rec.in_spec_lot_status_id;
      END IF;

    ELSE
      -- check Accept AND accept w/ var, cancel and void

      -- B2820787 REPLACED QUERY WITH
      -- SELECT COUNT(1)
      -- INTO   l_count
      -- FROM   gmd_results r, gmd_spec_results sr
      -- WHERE  sr.result_id          = r.result_id
      -- AND    sr.event_spec_disp_id = l_sample_rec.event_spec_disp_id
      -- AND    r.sample_id           = p_sample_id
      -- AND    (sr.evaluation_ind IS NULL OR
      --         sr.evaluation_ind    NOT IN ('0A', '1V', '4C', '5O')
      --        )
      -- AND    r.delete_mark         = 0
      -- ;
      -- THE FOLLOWING

      -- B2820787 BEGIN
      l_count           := 0;
      l_count_with_spec := 0;
      l_count_wo_spec   := 0;

      IF l_sample_rec.spec_id IS NOT NULL THEN
        -- Sample has a Spec

        -- Select COUNT of Tests with Evaluation other then ACCEPT
        SELECT count(1)
        INTO   l_count_with_spec
        FROM   gmd_event_spec_disp esd, gmd_results r, gmd_spec_results sr,
               gmd_spec_tests_b st
        WHERE  esd.event_spec_disp_id = l_sample_rec.event_spec_disp_id
        AND    esd.event_spec_disp_id = sr.event_spec_disp_id
        AND    sr.result_id           = r.result_id
        AND    r.sample_id            = p_sample_id
        AND    (sr.evaluation_ind IS NULL OR
                sr.evaluation_ind    NOT IN ('0A', '1V', '4C', '5O', '1Z')
               )
        AND    r.delete_mark          = 0
        AND    sr.delete_mark         = 0
        AND    esd.spec_id = st.spec_id
        AND    st.test_id = r.test_id
        AND    ((l_include_optional = 'N' and st.optional_ind IS NULL) OR
                (l_include_optional = 'Y' and (r.result_value_num IS NOT NULL OR
	                                       r.result_value_char IS NOT NULL)
                )
               )
        ;

      END IF;

      IF (l_count_with_spec = 0) THEN

        -- Select COUNT of Tests with Evaluation other then ACCEPT or ACCEPT W/ VAR
        -- Bug 3763419 -  Added Guaranteed by Manufacturer - 1Z
        SELECT count(1)
        INTO   l_count_wo_spec
        FROM   gmd_results r, gmd_spec_results sr
        WHERE  sr.event_spec_disp_id = l_sample_rec.event_spec_disp_id
        AND    sr.result_id           = r.result_id
        AND    r.sample_id            = p_sample_id
        AND    sr.additional_test_ind = 'Y'
        AND    (sr.evaluation_ind IS NULL OR
                sr.evaluation_ind    NOT IN ('0A', '1V', '4C', '5O', '1Z')
               )
        AND    r.delete_mark          = 0
        AND    sr.delete_mark         = 0
        ;

      END IF;

      l_count := l_count_with_spec + l_count_wo_spec;

      -- B2820787 END

      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('   Count of tests which do NOT have accept or accept w/ var evaluation w/  SPEC :' || l_count_with_spec);
        gmd_debug.put_line('   Count of tests which do NOT have accept or accept w/ var evaluation wo/ SPEC :' || l_count_wo_spec);
        gmd_debug.put_line('   Count of tests which do NOT have accept or accept w/ var evaluation Total    :' || l_count);
      END IF;

      IF  l_count = 0  THEN                                -- #2.1
        -- This means that all results are either 'Accept' or
        -- 'Accept with Variance' so set the Disposition to 'ACCEPT WITH VARIANCE'
        l_change_disp_to := '5AV';

        -- Set the lot status to In-Spec Lot Status
	IF l_sample_rec.control_lot_attrib_ind = 'Y' THEN     --RLNAGARA Bug5416103
	  l_lot_status_id := l_sample_rec.in_spec_lot_status_id;
	END IF;
      ELSE
        -- This means that some result have 'Reject' evaluation so
        -- set the Disposition to 'REJECT'
        l_change_disp_to := '6RJ';

        -- Set the lot status to Out-of-Spec Lot Status
	IF l_sample_rec.control_lot_attrib_ind = 'Y' THEN     --RLNAGARA Bug5416103
	  l_lot_status_id := l_sample_rec.out_of_spec_lot_status_id;
	END IF;
      END IF;           -- end if all are accept or accept w/var, cancel, void #2.1

    END IF;      -- end if all tests are accept, cancel, void or MFP    #2

    IF (l_debug = 'Y') THEN
      gmd_debug.put_line('   Lot status will be changed to: ' || to_char(l_lot_status_id));
    END IF;

    x_change_disp_to := l_change_disp_to;



    -- By now, we are setting the Sample Disposition to
    -- either of three - 4A, 5AV, 6RJ

    -- =======================================================
    -- So change the disposition of
    -- 1. sample_spec_disp
    -- 2. sampling_events (only if one sample required)
    -- 3. event_spec_disp (only if one sample required)
    -- by calling GMD_SAMPLES_GRP.update_sample_comp_disp
    --
    -- If there are more than one sample required then user
    -- has to go through composite results path to set the
    -- Event Disposition.
    -- =======================================================

    -- Prepare IN parameter
    l_update_disp_rec.sample_id               := p_sample_id;
    l_update_disp_rec.event_spec_disp_id      := l_sample_rec.event_spec_disp_id;
    -- l_update_disp_rec.called_from_results     := p_disp_out_rec.called_from_results;
    l_update_disp_rec.no_of_samples_for_event := l_sample_rec.sample_req_cnt;
     -- MAHESH
    l_update_disp_rec.curr_disposition        := l_sample_rec.disposition;


    IF (l_debug = 'Y') THEN
       gmd_debug.put_line ('  Call GMD_SAMPLES_GRP.update_sample_comp_disp '|| l_change_disp_to);
    END IF;

    GMD_SAMPLES_GRP.update_sample_comp_disp(
                 p_update_disp_rec => l_update_disp_rec
               , p_to_disposition  => l_change_disp_to
               , x_return_status   => x_return_status
               , x_message_data    => l_message_data);
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      GMD_API_PUB.Log_Message(l_message_data);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- The above procedure has changed the Sample Spec Disposition.
    -- It might also change the Sampling Event Disposition if this is the
    -- ONLY required sample.

    -- So if the Event is changed, then change the lot status to
    -- In-Spec or Out-of-Spec Lot status.

    SELECT disposition
    INTO   l_disposition
    FROM   gmd_sampling_events
    WHERE  sampling_event_id = l_sample_rec.sampling_event_id
    ;

    IF l_sample_rec.control_lot_attrib_ind = 'Y' THEN  --RLNAGARA Bug5416103
     IF (l_disposition IN ('4A', '5AV', '6RJ')) THEN
      change_lot_status(  p_sample_id        => p_sample_id
                        , p_organization_id  => l_sample_rec.organization_id
                        , p_lot_status       => l_lot_status_id
                        , x_return_status    => x_return_status
                        );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
     END IF; --l_disposition IN...
    END IF; -- control_lot_attrib_ind = Y ...

  --END IF;         -- end  if #1  if control_lot_attrib is on

  IF (l_debug = 'Y') THEN
    gmd_debug.put_line('Leaving Procedure: CHANGE_DISP_FOR_AUTO_LOT.');
  END IF;

EXCEPTION
  WHEN    FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR',
                            'PACKAGE','CHANGE_DISP_FOR_AUTO_LOT','ERROR', SUBSTR(SQLERRM,1,100));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END  change_disp_for_auto_lot;



--Start of comments
--+========================================================================+
--| API Name    : composite_and_change_lot                                 |
--| TYPE        : Group                                                    |
--| Notes       : This procedure creates a composite results for the given |
--|               sampling event id. It then checks if the Auto Lot Status |
--|               change is required from the Spec. If so, then it will    |
--|               find out the disposition of the composite result and     |
--|               change the lot status based on the disposition           |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar     06-Dec-2002     Created.                           |
--|                                                                        |
--|  RLNAGARA 07-Feb-2006 B4918820 Modified the cursor c_spec_dtl
--|  RLNAGARA 01-Aug-2006 Bug5416103 Modified the procedure so as to
--|                       check for control_lot_attrib_ind only while
--|                       changing the lot status instead of while changing
--|                       the disposition of a sample.
--|  Supriya Malluru 04-Oct-2007 Bug6439776. Included NVL() for l_config_opt.
--|  Supriya Malluru 12-Nov-2007 Bug6490789. Assigning Y if l_config_opt is
--|                       Null.
--|  Supriya Malluru 26-Nov-2007 Bug6609341.Reverted the fix of bug 6490789.
--+========================================================================+
-- End of comments
PROCEDURE  composite_and_change_lot
( p_sampling_event_id IN         NUMBER
, p_commit            IN         VARCHAR2
, x_return_status     OUT NOCOPY VARCHAR2
) IS

  /*=================================================
     BUG#4691545 - Added organization_id to cursor.
    =================================================*/
--RLNAGARA Bug 4918820 Changed the view from gmd_all_spec_vrs to gmd_com_spec_vrs_vl
  CURSOR c_spec_dtl (p_event_spec_disp_id NUMBER) IS
  SELECT esd.disposition,
         svr.control_lot_attrib_ind,
         svr.in_spec_lot_status_id,
         svr.out_of_spec_lot_status_id,
         svr.organization_id
  FROM   gmd_event_spec_disp esd,
         gmd_com_spec_vrs_vl svr,
         gmd_composite_spec_disp csd
  WHERE  esd.event_spec_disp_id = p_event_spec_disp_id
  AND    esd.spec_used_for_lot_attrib_ind = 'Y'
  AND    svr.spec_vr_id = esd.spec_vr_id
  AND    esd.delete_mark = 0
  ;

  CURSOR Cur_quality_config (p_organization_id VARCHAR2) IS
  SELECT transaction_reason_id
  FROM   gmd_quality_config
  WHERE  organization_id = p_organization_id
  AND    transaction_reason_id IS NOT NULL;


  l_sampling_event               GMD_SAMPLING_EVENTS%ROWTYPE;
  l_in_sampling_event            GMD_SAMPLING_EVENTS%ROWTYPE;

  l_spec_dtl                     c_spec_dtl%ROWTYPE;
  l_sample_ids                   GMD_API_PUB.number_tab;
  l_update_disp_rec              GMD_SAMPLES_GRP.update_disp_rec;

  l_event_spec_disp_id           NUMBER;
  l_composite_spec_disp_id       NUMBER;
  l_composite_exist              VARCHAR2(1);
  l_composite_valid              VARCHAR2(1);
  l_return_status                VARCHAR2(1);
  l_count                        PLS_INTEGER;
  l_count_with_spec              PLS_INTEGER;
  l_count_wo_spec                PLS_INTEGER;
  l_lot_status_id                VARCHAR2(4);
  l_change_disp_to               VARCHAR2(4);
  l_message_data                 VARCHAR2(2000);
  l_organization_id              NUMBER;

  l_include_optional             VARCHAR2(3);
  l_reason_id                    gmd_quality_config.transaction_reason_id%TYPE;


/*
  l_event_spec_disp              GMD_EVENT_SPEC_DISP%ROWTYPE;
  l_sample_spec_disp             GMD_SAMPLE_SPEC_DISP%ROWTYPE;
  l_results                      GMD_RESULTS%ROWTYPE;
  l_spec_results                 GMD_SPEC_RESULTS%ROWTYPE;

  l_in_event_spec_disp           GMD_EVENT_SPEC_DISP%ROWTYPE;
  l_out_event_spec_disp          GMD_EVENT_SPEC_DISP%ROWTYPE;
  l_out_results                  GMD_RESULTS%ROWTYPE;
*/

  -- Exception
  e_sampling_event_fetch_error   EXCEPTION;

  /*====================
      BUG#4691545
    ====================*/

  CURSOR get_config_opt (p_org_id NUMBER) IS
  SELECT include_optional_test_rslt_ind
  FROM   gmd_quality_config
  WHERE  organization_id = p_org_id;

  l_config_opt           VARCHAR2(1);

BEGIN

  IF (l_debug = 'Y') THEN
    gmd_debug.put_line('Entering procedure CHANGE_SAMPLE_DISPOSITION');
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Now that we have sampling_event_id, fetch the sampling event record
  l_in_sampling_event.sampling_event_id := p_sampling_event_id;
  IF NOT (GMD_SAMPLING_EVENTS_PVT.fetch_row(
                   p_sampling_events => l_in_sampling_event,
                   x_sampling_events => l_sampling_event)
         )
  THEN
    -- Fetch Error.
    RAISE e_sampling_event_fetch_error;
  END IF;

  -- Composite is done only if there are nore than one active samples.
  IF (l_sampling_event.sample_active_cnt > 1) THEN

    l_event_spec_disp_id := get_current_event_spec_disp_id
                               (l_sampling_event.sampling_event_id);
    IF (l_event_spec_disp_id IS NULL) THEN
      GMD_API_PUB.Log_Message('GMD_EVENT_SPEC_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_composite_exist := 'N';
    l_composite_valid := 'N';

    gmd_results_grp.composite_exist(
       p_sampling_event_id  => l_sampling_event.sampling_event_id
     , p_event_spec_disp_id => NULL
     , x_composite_exist    => l_composite_exist
     , x_composite_valid    => l_composite_valid
     , x_return_status      => l_return_status);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF ((l_composite_exist = 'N') OR
        (l_composite_exist = 'Y' AND l_composite_valid = 'N')) THEN
      -- Get all the sample IDs for this Sampling Event
      GMD_RESULTS_GRP.get_sample_ids_for_se(l_sampling_event.sampling_event_id,
					    l_sample_ids,
					    l_return_status);
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Populate Session Temp Table with Data Points
      GMD_RESULTS_GRP.populate_result_data_points
            (p_sample_ids         => l_sample_ids,
             p_event_spec_disp_id => l_event_spec_disp_id,
             x_return_status      => l_return_status);
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Create new Composite Rows
      GMD_RESULTS_GRP.create_composite_rows
          (p_event_spec_disp_id => l_event_spec_disp_id,
           x_return_Status      => l_return_status);
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- At this time the composite results are created with IN/OUT-OF-SPEC flag set.

      OPEN c_spec_dtl(l_event_spec_disp_id);
      FETCH c_spec_dtl INTO l_spec_dtl;
      CLOSE c_spec_dtl;

      --IF (l_spec_dtl.control_lot_attrib_ind = 'Y') THEN   --RLNAGARA Bug 5416103

        -- The Auto Lot Status is ON so we need to change the
        -- disposition of the Composite Result to 'Accept' OR 'Reject'

        -- How do we do that, you might ask?
        -- Simple. If even a single result is OUT-OF-SPEC then the composite result
        -- is OUT-OF-SPEC else it is IN-SPEC.

    /*====================
        BUG#4691545
      ====================*/

    OPEN get_config_opt (l_spec_dtl.organization_id);
    FETCH get_config_opt INTO l_config_opt;
    IF (get_config_opt%NOTFOUND) THEN
       l_config_opt := 'N';
    END IF;
    CLOSE get_config_opt;
    l_include_optional := NVL(l_config_opt,'N'); --Bug#6490789,Bug#6439776

        IF (l_debug = 'Y') THEN
          gmd_debug.put_line('Profile GMD: Include Optional Tests in Sample Disposition :' || l_include_optional);
        END IF;

        -- B2820787 START
        -- REPLACED FOLLOWING WITH
        -- SELECT count(1)
        -- INTO   l_count
        -- FROM   gmd_composite_spec_disp csd,
        --        gmd_composite_results cr
        -- WHERE  csd.event_spec_disp_id = l_event_spec_disp_id
        -- AND    csd.latest_ind = 'Y'
        -- AND    csd.composite_spec_disp_id = cr.composite_spec_disp_id
        -- AND    cr.in_spec_ind IS NULL                  -- Result is out-of-spec
        -- ;
        -- THE FOLLOWING

        SELECT count(1)
        INTO   l_count_with_spec
        FROM   gmd_composite_spec_disp csd, gmd_event_spec_disp esd,
               gmd_composite_results cr, gmd_spec_tests_b st
        WHERE  csd.event_spec_disp_id = l_event_spec_disp_id
        AND    csd.latest_ind = 'Y'
        AND    csd.event_spec_disp_id = esd.event_spec_disp_id
        AND    csd.composite_spec_disp_id = cr.composite_spec_disp_id
        AND    cr.in_spec_ind IS NULL   -- Result is out-of-spec
        AND    st.spec_id = esd.spec_id
        AND    st.test_id = cr.test_id
        AND    ((l_include_optional = 'N' and st.optional_ind IS NULL) OR
                (l_include_optional = 'Y' and (cr.mean IS NOT NULL or cr.mode_char IS NOT NULL))
               )
        ;

        SELECT count(1)
        INTO   l_count_wo_spec
        FROM   gmd_composite_spec_disp csd, gmd_event_spec_disp esd,
               gmd_composite_results cr
        WHERE  csd.event_spec_disp_id = l_event_spec_disp_id
        AND    csd.latest_ind = 'Y'
        AND    csd.event_spec_disp_id = esd.event_spec_disp_id
        AND    csd.composite_spec_disp_id = cr.composite_spec_disp_id
        AND    cr.in_spec_ind IS NULL                  -- Result is out-of-spec
        AND    cr.test_id NOT IN
               (SELECT st.test_id
                FROM   gmd_spec_tests_b st
                WHERE  st.spec_id = esd.spec_id)
        ;

        l_count := l_count_with_spec + l_count_wo_spec;

        -- B2820787 END

        IF (l_count = 0) THEN
          -- Everything is IN-SPEC so the lot is changed to In-Spec Lot Status
	  IF (l_spec_dtl.control_lot_attrib_ind = 'Y') THEN   --RLNAGARA Bug5416103
	      l_lot_status_id := l_spec_dtl.in_spec_lot_status_id;
	  END IF;

          -- And the Disposition is changed to 'Accept
          l_change_disp_to := '4A';
        ELSE
          -- Something is OUT-OF-SPEC so the lot is changed to Out-of-Spec Lot Status
	  IF (l_spec_dtl.control_lot_attrib_ind = 'Y') THEN   --RLNAGARA Bug5416103
	     l_lot_status_id := l_spec_dtl.out_of_spec_lot_status_id;
	  END IF;

          -- And the Disposition is changed to 'Reject'
          l_change_disp_to := '6RJ';
        END IF;

        SELECT composite_spec_disp_id
        INTO   l_composite_spec_disp_id
        FROM   gmd_composite_spec_disp csd
        WHERE  csd.event_spec_disp_id = l_event_spec_disp_id
        AND    csd.latest_ind = 'Y'
        ;

        -- Change the dispostion of the Event
        -- Prepare IN parameter
        l_update_disp_rec.composite_spec_disp_id  := l_composite_spec_disp_id;
        l_update_disp_rec.event_spec_disp_id      := l_event_spec_disp_id;
        l_update_disp_rec.no_of_samples_for_event := l_sampling_event.sample_req_cnt;
        l_update_disp_rec.sampling_event_id       := l_sampling_event.sampling_event_id;
        l_update_disp_rec.curr_disposition        := l_spec_dtl.disposition;

        IF (l_debug = 'Y') THEN
           gmd_debug.put_line ('  Call GMD_SAMPLES_GRP.update_sample_comp_disp '|| l_change_disp_to);
        END IF;

        GMD_SAMPLES_GRP.update_sample_comp_disp(
                     p_update_disp_rec => l_update_disp_rec
                   , p_to_disposition  => l_change_disp_to
                   , x_return_status   => l_return_status
                   , x_message_data    => l_message_data);
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          GMD_API_PUB.Log_Message(l_message_data);
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Disposition has been changed so now change the Lot Status in Inventory
	IF (l_spec_dtl.control_lot_attrib_ind = 'Y') THEN   --RLNAGARA Bug5416103
         IF  l_lot_status_id IS NOT NULL  THEN

          -- Get the orgn_code for the sampling event
          SELECT organization_id
          INTO   l_organization_id
          FROM   gmd_samples
          WHERE  sampling_event_id = l_sampling_event.sampling_event_id
          AND    rownum = 1 ;

          -- Get the reason code from quality configuration/parameters
          OPEN  Cur_quality_config(l_organization_id);
          FETCH Cur_quality_config INTO l_reason_id ;
          IF Cur_quality_config%NOTFOUND THEN
            CLOSE Cur_quality_config;
            GMD_API_PUB.Log_Message('GMD_QM_INV_REASON_CODE');
            RAISE FND_API.G_EXC_ERROR;
          END IF;
          CLOSE Cur_quality_config;

--rconv

          gmd_samples_grp.update_lot_grade_batch(       --nsrivast
                  p_sample_id           => NULL
                , p_composite_spec_disp_id  => l_composite_spec_disp_id
                , p_to_lot_status_id       => l_lot_status_id
                , p_from_lot_status_id       => NULL --l_lot_status_id
                , p_to_grade_code            => NULL
                , p_from_grade_code          => NULL
                , p_to_qc_status        => NULL
                , p_reason_id           => l_reason_id
                , p_hold_date           => NULL
                , x_return_status       => x_return_status
                , x_message_data        => l_message_data );


          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            GMD_API_PUB.Log_Message(l_message_data);
            RAISE FND_API.G_EXC_ERROR;
          END IF;

        END IF; -- l_lot_status IS NOT NULL

      END IF; -- l_spec_dtl.control_lot_attrib_ind = 'Y'

    END IF;  -- Need to create composite

    -- Check of p_commit.
    IF FND_API.to_boolean(p_commit)
    THEN
      COMMIT WORK;
    END IF;

  END IF;  -- l_sampling_event.active_sample_cnt > 1



EXCEPTION
  WHEN FND_API.G_EXC_ERROR OR
       e_sampling_event_fetch_error
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR',
                            'PACKAGE','change_sample_disposition','ERROR', SUBSTR(SQLERRM,1,100));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END composite_and_change_lot;

PROCEDURE update_exptest_value_null
(p_exp_ref_test_id  IN gmd_qc_tests_b.test_id%TYPE
, p_sample_id IN gmd_samples.sample_id%TYPE
, p_event_spec_disp_id IN gmd_sample_spec_disp.event_spec_disp_id%TYPE
, x_return_status     OUT NOCOPY VARCHAR2
)
--Start of comments
--+========================================================================+
--| API Name    : update_exptest_value_null                                |
--| TYPE        : Group                                                    |
--| Notes       : This procedure takes the sample information and          |
--|               test_id, and updates the result of latest replicates     |
--|               of all the Expression tests of the current sample,       |
--|               which use the given test as dependent test, to NULL.     |              |
--|                                                                        |
--| HISTORY                                                                |
--|    Ravi Boddu     31-Dec-2004       Created.                           |
--|                                                                        |
--+========================================================================+
-- End of comments
IS
    l_rslt_tbl gmd_results_grp.rslt_tbl;
    l_return_status VARCHAR2(10);
    l_sts BOOLEAN;
    l_start_date  DATE := GMA_CORE_PKG.get_date_constant_d('SY$MIN_DATE');

   CURSOR get_exp_tests (l_exp_ref_test_id gmd_qc_tests_b.test_id%TYPE) IS
   SELECT DISTINCT test_id
   FROM gmd_qc_test_values_b val
   WHERE  expression_ref_test_id = l_exp_ref_test_id ;

   CURSOR exp_tests_need_calc ( l_sample_id gmd_samples.sample_id%TYPE,
                             l_test_id gmd_qc_tests_b.test_id%TYPE,
                             l_event_spec_disp_id gmd_sample_spec_disp.event_spec_disp_id%TYPE)
   IS
    SELECT r.result_id
    FROM   gmd_results r, gmd_spec_results sr
    WHERE  r.result_id = sr.result_id
    AND    r.sample_id = l_sample_id
    AND    sr.event_spec_disp_id = l_event_spec_disp_id
    AND    NVL(sr.evaluation_ind, 'XX')  NOT IN ('50' ,'4C')
    AND    sr.delete_mark = 0
    AND    r.delete_mark = 0
    AND    r.test_id = l_test_id
    ORDER BY NVL(r.result_date,l_start_date) DESC , r.test_replicate_cnt DESC;
   l_result_id           NUMBER(15);

  BEGIN

    gmd_debug.put_line('Entering procedure update_exptest_value_null');

    --Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    FOR test in get_exp_tests(p_exp_ref_test_id)
    LOOP
      OPEN exp_tests_need_calc(p_sample_id, test.test_id,p_event_spec_disp_id);
      FETCH exp_tests_need_calc INTO l_result_id;
      CLOSE exp_tests_need_calc;
      IF l_result_id IS NOT NULL THEN
        UPDATE gmd_results SET result_value_num = NULL WHERE result_id = l_result_id;
      END IF;
    END LOOP;

  EXCEPTION
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR','PACKAGE','update_exptest_value_null','ERROR', SUBSTR(SQLERRM,1,100));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  END update_exptest_value_null;

END gmd_results_grp;

/
