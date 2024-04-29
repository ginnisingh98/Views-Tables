--------------------------------------------------------
--  DDL for Package Body GMD_QUALITY_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_QUALITY_GRP" AS
/* $Header: GMDGQCMB.pls 120.1 2005/06/21 04:09:04 appldev ship $ */
l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

G_PKG_NAME      CONSTANT VARCHAR2(30):='GMD_QUALITY_GRP';


 /*  ************************************************************************ */
 /*  API name    : get_display_precision                                      */
 /*  Type        : Private                                                    */
 /*  Function    :                                                            */
 /*  Pre-reqs    : None.                                                      */
 /*  Parameters  :                                                            */
 /*  IN          : p_number                IN      NUMBER  (Required)         */
 /*              : p_display_precision     IN      NUMBER  (Required)         */
 /*  Notes       : This function returns the number in character format with  */
 /*                the specified precision                                    */
 /*  HISTORY                                                                  */
 /*  20-Feb-2003   Shyam Sitaraman        Initial Implementation              */
 /*  13-JUN-2005  Saikiran Vankadari     Convergence Changes                  */
 /*  ************************************************************************ */
 FUNCTION get_display_precision(p_number            NUMBER,
                                p_display_precision NUMBER) RETURN VARCHAR2 IS
  l_format_mask VARCHAR2(100);
  l_prefix      VARCHAR2(100);
 BEGIN
   IF (instr(p_number,'.') <> 0) THEN
     l_prefix := POWER(10, (instr(p_number,'.') - 1)) - 1;
   ELSE
     l_prefix := POWER(10, length(p_number)) - 1;
   END IF;
   l_format_mask := POWER(10, p_display_precision) - 1;
   RETURN  TO_CHAR(p_number, l_prefix||'D'||l_format_mask);
 END get_display_precision;


 /*  ************************************************************************ */
 /*  API name    : get_inv_test_value                                         */
 /*  Type        : Private                                                    */
 /*  Function    :                                                            */
 /*  Pre-reqs    : None.                                                      */
 /*  Parameters  :                                                            */
 /*  IN          : P_inv_test_inp_rec    IN      inv_inp_rec_type  (Required) */
 /*                                                                           */
 /*                P_inv_test_inp_rec.organization_id (Required)              */
 /*                P_inv_test_inp_rec.inventory_item_Id   (Required)          */
 /*                P_inv_test_inp_rec.grade_code     (Optional)               */
 /*                P_inv_test_inp_rec.parent_lot_number    (Optional)         */
 /*                P_inv_test_inp_rec.lot_number    (Optional)                */
 /*                P_inv_test_inp_rec.subinventory (Optional)                 */
 /*                P_inv_test_inp_rec.locator_id  (Optional)                  */
 /*                P_inv_test_inp_rec.Test_Id   (Required)                    */
 /*                                                                           */
 /*  OUT         : x_return_status       OUT     VARCHAR2(1)                  */
 /*              : x_inv_test_out_rec    OUT     inv_val_out_rec_type         */
 /*                                                                           */
 /*                x_inv_test_out_rec.Entity_Id  (Result/Spec Id)             */
 /*                x_inv_test_out_rec.Entity_Value (Result/Spec test value)   */
 /*                x_inv_test_out_rec.Entity_min_value                        */
 /*                x_inv_test_out_rec.Entity_max_value                        */
 /*                x_inv_test_out_rec.Level  (Result/Spec test source/type    */
 /*                                                                           */
 /*  Notes       : This is a wrapper on Procedures GET_INV_RESULT_TEST_VALUE  */
 /*                (returns results) or GET_INV_SPEC_TEST_VALUE (returns spec */
 /*                tests). Given the item, organization_id, parent_lot,       */
 /*                 lot, subinventory, locator_id and                         */
 /*                grade information it gets the result value for a test. If  */
 /*                the result is not found it gets the spec details for this  */
 /*                test.                                                      */
 /*  HISTORY                                                                  */
 /*  20-Feb-2003   Shyam Sitaraman   Initial Implementation                   */
 /*  09-FEB-2004   Thomas Daniel     Bug#3412075. Passed a local variable to  */
 /*                                  get_inv_spec_test_value to avoid the     */
 /*                                  overwrite of the global specification    */
 /*  10-JUN-2005  Saikiran Vankadari  Convergence Changes. Replaced all       */
 /*                                  opm-inventory references with that of    */
 /*                                   discrete inventory                      */
 /*  ************************************************************************ */
 PROCEDURE get_inv_test_value
  ( P_inv_test_inp_rec    IN            inv_inp_rec_type
  , x_inv_test_out_rec    OUT  NOCOPY   inv_val_out_rec_type
  , x_return_status       OUT  NOCOPY   VARCHAR2
  )
  IS
    l_api_name           VARCHAR2(100)  := 'GET_INV_TEST_VALUE';
    x_results            GMD_QUALITY_GRP.inv_rslt_out_rec_type;
    x_spec_tests         GMD_QUALITY_GRP.inv_spec_out_rec_type;

    /* Bug#3412075 - Define the local variable */
    l_spec_tests         GMD_QUALITY_GRP.inv_spec_out_rec_type;

    l_inv_test_inp_rec   GMD_QUALITY_GRP.INV_INP_REC_TYPE;

  BEGIN
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Intialize the local variable rec
    l_inv_test_inp_rec := P_inv_test_inp_rec;

    -- Check if Plant_id value is passed.
    -- If it is passed then we obtain the test samples/results/specs
    -- for this plant organization.
    -- Of course if there is no result we would like to derive Results/Specs
    -- for the lab organization_id that is passed in (mandatory field for the record
    -- type p_inv_test_inp_rec.

    -- Call the fetch Results API
    IF p_inv_test_inp_rec.plant_id IS NOT NULL  THEN
       l_inv_test_inp_rec.organization_id := p_inv_test_inp_rec.plant_id;

       GMD_QUALITY_GRP.get_inv_result_test_value
       ( p_inv_rslt_inp_rec => l_inv_test_inp_rec
       , x_inv_rslt_out_rec => x_results
       , x_return_status    => x_return_status);

       IF x_results.result_value IS NULL THEN
          -- check if you get results using lab_id or organization_id
          l_inv_test_inp_rec.organization_id := p_inv_test_inp_rec.organization_id;

          GMD_QUALITY_GRP.get_inv_result_test_value
          ( p_inv_rslt_inp_rec => l_inv_test_inp_rec
          , x_inv_rslt_out_rec => x_results
          , x_return_status    => x_return_status);
       END IF;
    ELSE -- no plant_id provided, so use the lab or organization id
       l_inv_test_inp_rec.organization_id := p_inv_test_inp_rec.organization_id;

       GMD_QUALITY_GRP.get_inv_result_test_value
       ( p_inv_rslt_inp_rec => l_inv_test_inp_rec
       , x_inv_rslt_out_rec => x_results
       , x_return_status    => x_return_status
       );
    END IF; -- When plant_id is not null

    IF x_results.result_value IS NULL THEN
      -- Call the fetch Spec Test API

      IF p_inv_test_inp_rec.plant_id IS NOT NULL  THEN
         l_inv_test_inp_rec.organization_id := p_inv_test_inp_rec.plant_id;

         GMD_QUALITY_GRP.get_inv_spec_test_value
         ( p_inv_spec_inp_rec => l_inv_test_inp_rec
         , x_inv_spec_out_rec => x_spec_tests
         , x_return_status    => x_return_status
         );

         -- Level=41 or 51 would indicate a Global Spec
         -- in this case we would want to retrieve lab_id or organization_id
         -- based specification first
         IF x_spec_tests.level IN (41,51) THEN
            -- check if you get results using lab_id or organization_id
            l_inv_test_inp_rec.organization_id := p_inv_test_inp_rec.organization_id;

            GMD_QUALITY_GRP.get_inv_spec_test_value
            ( p_inv_spec_inp_rec => l_inv_test_inp_rec
            /* Bug#3412075 - Changed the parameter from x_spec_tests to l_spec_tests */
            /* to avoid the overwriting of the data from the global sepc */
            , x_inv_spec_out_rec => l_spec_tests
            , x_return_status    => x_return_status
            );
            /* Bug#3412075 - If a local spec is found then we have to assign its data */
            IF l_spec_tests.spec_id IS NOT NULL THEN
              x_spec_tests := l_spec_tests;
            END IF;
         END IF;
      ELSE -- no plant_id  provided, so use the lab or orgn ocde
         l_inv_test_inp_rec.organization_id := p_inv_test_inp_rec.organization_id;

         GMD_QUALITY_GRP.get_inv_spec_test_value
         ( p_inv_spec_inp_rec => l_inv_test_inp_rec
         , x_inv_spec_out_rec => x_spec_tests
         , x_return_status    => x_return_status
         );
      END IF; -- When plant_id is not null

      x_inv_test_out_rec.entity_id        := x_spec_tests.spec_id;
      x_inv_test_out_rec.spec_id          := x_spec_tests.spec_id;
      x_inv_test_out_rec.entity_value     := x_spec_tests.target_value;
      x_inv_test_out_rec.entity_min_value := x_spec_tests.min_value;
      x_inv_test_out_rec.entity_max_value := x_spec_tests.max_value;
      x_inv_test_out_rec.level            := x_spec_tests.level;
    ELSE -- Assign value from results
      x_inv_test_out_rec.entity_id        := x_results.result_id;
      x_inv_test_out_rec.spec_id          := x_results.spec_id;
      x_inv_test_out_rec.entity_value     := x_results.result_value;
      x_inv_test_out_rec.entity_min_value := x_results.min_value;
      x_inv_test_out_rec.entity_max_value := x_results.max_value;
      x_inv_test_out_rec.level            := x_results.level;
      x_inv_test_out_rec.composite_ind    := x_results.composite_ind;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
  END get_inv_test_value;

 /*  ************************************************************************ */
 /*  API name    : get_inv_result_test_value                                  */
 /*  Type        : Private                                                    */
 /*  Function    :                                                            */
 /*  Pre-reqs    : None.                                                      */
 /*  Parameters  :                                                            */
 /*  IN          : P_inv_rslt_inp_rec    IN      inv_inp_rec_type  (Required) */
 /*                                                                           */
 /*  OUT         : x_return_status       OUT     VARCHAR2(1)                  */
 /*              : x_inv_rslt_out_rec    OUT     inv_rslt_out_rec_type        */
 /*                                                                           */
 /*                x_inv_rslt_out_rec.Result_Id  (Simple/Composite Result Id) */
 /*                x_inv_rslt_out_rec.result_value (Numeric or Char Results)  */
 /*                x_inv_rslt_out_rec.Min_Value (Result value lower limit)    */
 /*                x_inv_rslt_out_rec.Max_Value (Result value upper limit)    */
 /*                x_inv_rslt_out_rec.Level (value representing inventory/lot */
 /*                                          specific test result)            */
 /*                                                                           */
 /*  Notes       : Given the item, organization_id, parent_lot, lot,          */
 /*                subinventory, locator_id and                               */
 /*                grade information this API gets the result value for a test*/
 /*                This API can be called independently to return the test    */
 /*                results for a sample that has an approved disposition.     */
 /*                The results could return either simple or composite based  */
 /*                on the number of approved samples (or sample acive count)  */
 /*                for a given item.                                          */
 /*                                                                           */
 /*  HISTORY                                                                  */
 /*  20-Feb-2003   Shyam Sitaraman        Initial Implementation              */
 /*  10-JUN-2005  Saikiran Vankadari  Convergence Changes. Replaced all       */
 /*                                  opm-inventory references with that of    */
 /*                                   discrete inventory                      */
 /*  ************************************************************************ */
  PROCEDURE get_inv_result_test_value
  ( P_inv_rslt_inp_rec    IN            inv_inp_rec_type
  , x_inv_rslt_out_rec    OUT  NOCOPY   inv_rslt_out_rec_type
  , x_return_status       OUT  NOCOPY   VARCHAR2
  )
  IS
    l_api_name                 VARCHAR2(100)  := 'GET_INV_RESULT_TEST_VALUE';
    x_sampling_events          GMD_QUALITY_GRP.sampling_events_tbl_type;
    x_results                  GMD_RESULTS_GRP.gmd_results_rec_tbl;
    l_level_rec                GMD_QUALITY_GRP.inv_inp_rec_type;
    l_return_status            VARCHAR2(1);
    l_composite_spec_disp_id   NUMBER;
    i                          NUMBER := 0;
    l_row_num                  NUMBER := 0;
    l_test_type                gmd_qc_tests_b.test_type%TYPE;
    l_min_value_num            gmd_spec_tests_b.min_value_num%TYPE;
    l_max_value_num            gmd_spec_tests_b.max_value_num%TYPE;
    l_min_value_char           gmd_spec_tests_b.min_value_char%TYPE;
    l_max_value_char           gmd_spec_tests_b.max_value_char%TYPE;
    l_display_precision        gmd_spec_tests_b.display_precision%TYPE;

    l_result_id                gmd_results.result_id%TYPE;
    l_result_value_num         gmd_results.result_value_num%TYPE;
    l_result_value_char        gmd_results.result_value_char%TYPE;

    -- Cursor defn
    -- Get simple results
    Cursor get_simple_results(vSample_id              NUMBER,
                              vEvent_Spec_disp_id     NUMBER,
                              vTest_id                NUMBER) IS
      SELECT  sr.result_id, sr.result_value_num, sr.result_value_char
      FROM    gmd_results sr,
              gmd_spec_results spr
      WHERE   sr.sample_id           = vSample_id
      AND     sr.test_id             = vTest_id
      AND     spr.result_id          = sr.result_id
      AND     spr.Event_spec_disp_id = vEvent_Spec_disp_id
      AND     (spr.evaluation_ind     <> '4C'
               OR spr.evaluation_ind  <> '5O')
      -- B3698232 The manager must evaluate the result for it to be considered for the simulator
      AND     spr.evaluation_ind IS NOT NULL
      ;

    Cursor get_qc_tests(vTest_id NUMBER)  IS
      SELECT  test_type, min_value_num, max_value_num, display_precision
      FROM    gmd_qc_tests_b
      WHERE   test_id = vTest_id;

    Cursor get_spec_tests(vSpec_id NUMBER,
                          vTest_id NUMBER) IS
      SELECT  min_value_num, max_value_num,
              min_value_char, max_value_char, display_precision
      FROM    gmd_spec_tests_b
      WHERE   spec_id = vSpec_id
      AND     test_id = vTest_id;

    -- Get composite results
    Cursor get_composite_results(vComposite_spec_disp_id NUMBER) IS
      SELECT rst.mean, rst.mode_char, rst.high_num, rst.low_num,
             rst.high_char, rst.low_char, rst.composite_result_id,
             rst.test_id
      FROM   gmd_composite_results rst, gmd_composite_spec_disp csd
      WHERE  rst.test_id                = p_inv_rslt_inp_rec.test_id
      AND    rst.delete_mark            = 0
      AND    rst.composite_spec_disp_id = csd.composite_spec_disp_id
      AND    csd.composite_spec_disp_id = vComposite_spec_disp_id
      AND    csd.latest_ind             ='Y';

    Cursor get_composite_disp(vEvent_spec_disp_id NUMBER)  IS
      SELECT composite_spec_disp_id
      FROM   gmd_composite_spec_disp
      WHERE  event_spec_disp_id = vEvent_spec_disp_id
      -- B3698232 Added disposition 'Complete' for the composite sample
      -- AND    disposition IN ('4A','5AV');
      AND    disposition IN ('3C', '4A','5AV');

    -- get display precision for composite results
    CURSOR get_tst_display_precision(vTest_id NUMBER) IS
      SELECT display_precision
      FROM   gmd_qc_tests_b
      WHERE  test_id  = vTest_id;

    l_test_found BOOLEAN := FALSE;
    l_disp_precision  NUMBER;

    -- Exception Definition
    No_test_results_exp     EXCEPTION;

  BEGIN
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Get the list of approved sampling events
    GMD_QUALITY_GRP.get_appr_sampling_events
    ( p_inv_rslt_inp_rec    => p_inv_rslt_inp_rec
    , x_sampling_events_tbl => x_sampling_events
    , x_return_status       => x_return_status
    );

    -- For each approved sampling event, based on the sample active count
    -- we return either the composite or simple result.
    FOR i IN 1 .. x_sampling_events.count LOOP
      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('Sample active cnt for row # '
                     ||i||' = '||x_sampling_events(i).sample_active_cnt);
      END IF;

      IF (x_sampling_events(i).sample_active_cnt > 1) THEN -- composite results
        IF (l_debug = 'Y') THEN
           gmd_debug.put_line('Sample id, spec id, event_spec_id row # '
                     ||i||' = '||X_sampling_events(i).sample_id
                     ||' - '||X_sampling_events(i).spec_id
                     ||' - '||X_sampling_events(i).event_spec_disp_id);
        END IF;

        OPEN  get_composite_disp(X_sampling_events(i).event_spec_disp_id);
        FETCH get_composite_disp INTO l_composite_spec_disp_id;
          IF get_composite_disp%FOUND THEN
             IF (l_debug = 'Y') THEN
               gmd_debug.put_line('Comp_spec_disp_id row # '
                     ||i||' = '||l_Composite_spec_disp_id);
             END IF;

             FOR get_composite_rec IN get_composite_results(l_Composite_spec_disp_id)
             LOOP
             IF get_composite_rec.test_id = p_inv_rslt_inp_rec.test_id  THEN
                x_inv_rslt_out_rec.Result_Id
                                  := get_composite_rec.Composite_result_Id ;
                IF (get_composite_rec.mean IS NOT NULL) THEN
                  -- Get the display precision
                  OPEN get_tst_display_precision(get_composite_rec.test_id);
                  FETCH get_tst_display_precision INTO l_disp_precision;
                  CLOSE get_tst_display_precision;

                  IF (l_debug = 'Y') THEN
                    gmd_debug.put_line('Display Precision and mean  row # '
                                ||i||' = '||get_composite_rec.mean
                                ||' - '||l_disp_precision);
                  END IF;

                  IF (l_disp_precision IS NOT NULL) THEN
                    x_inv_rslt_out_rec.result_value :=
                                 get_display_precision(get_composite_rec.mean,
                                                             l_disp_precision);
                  ELSE
                    x_inv_rslt_out_rec.result_value := get_composite_rec.mean;
                  END IF;
                  x_inv_rslt_out_rec.Spec_id      := X_sampling_events(i).spec_id;
                  x_inv_rslt_out_rec.Min_Value    := get_composite_rec.low_num;
                  x_inv_rslt_out_rec.Max_Value    := get_composite_rec.high_num;
                  x_inv_rslt_out_rec.composite_ind
                                      := x_sampling_events(i).sample_active_cnt;
                  l_row_num := i;
                  l_test_found := TRUE;
                  Exit;   -- break away from the outer loops
                ELSIF (get_composite_rec.mode_char IS NOT NULL) THEN
                  -- we use mode for result value is char
                  x_inv_rslt_out_rec.result_value := get_composite_rec.mode_char;
                  x_inv_rslt_out_rec.Min_Value    := get_composite_rec.low_char;
                  x_inv_rslt_out_rec.Max_Value    := get_composite_rec.high_char;
                  x_inv_rslt_out_rec.composite_ind
                                      := x_sampling_events(i).sample_active_cnt;
                  x_inv_rslt_out_rec.Spec_id      := X_sampling_events(i).spec_id;
                  l_row_num := i;
                  l_test_found := TRUE;
                  Exit;   -- break away from the outer loops
                END IF;-- If mean or mode composite result exists
             END IF;   -- test ids match
            END LOOP; -- Loop thro all composite results
          ELSE -- No composite results found
            FND_MESSAGE.SET_NAME('GMD','GMD_RESULT_NOT_FOUND');
            FND_MESSAGE.SET_TOKEN('SAMPLE_ID', X_sampling_events(i).sample_id);
            FND_MESSAGE.SET_TOKEN('TEST_ID', p_inv_rslt_inp_rec.test_id);
            FND_MSG_PUB.ADD;
          END IF;      -- if the composite disposition id is found
        CLOSE get_composite_disp;
      ELSE -- for simple results

        IF (l_debug = 'Y') THEN
          gmd_debug.put_line('Sample id, spec id, event_spec_id row # '
                     ||i||' = '||X_sampling_events(i).sample_id
                     ||' - '||X_sampling_events(i).spec_id
                     ||' - '||X_sampling_events(i).event_spec_disp_id);
        END IF;

        -- cursor below should return only onw row
        OPEN get_simple_results(X_sampling_events(i).sample_id,
                                X_sampling_events(i).event_spec_disp_id,
                                p_inv_rslt_inp_rec.test_id);
        FETCH get_simple_results INTO l_result_id,
                                      l_result_value_num,
                                      l_result_value_char;

        IF get_simple_results%FOUND THEN
          -- Get details from gmd_qc_tests
          OPEN  get_qc_tests(p_inv_rslt_inp_rec.test_id);
          FETCH get_qc_tests INTO l_test_type, l_min_value_num, l_max_value_num,
                                  l_display_precision;
            IF get_qc_tests%FOUND THEN
               -- Override certain qc tests values with spec test values
               OPEN  get_spec_tests(X_sampling_events(i).spec_id ,
                                    p_inv_rslt_inp_rec.test_id);
               FETCH get_spec_tests INTO l_min_value_num, l_max_value_num,
                                         l_min_value_char,l_max_value_char,
                                         l_display_precision;
               CLOSE get_spec_tests;
            END IF;

            IF (l_test_type IN ('T','U','V')) THEN -- char test types
                x_inv_rslt_out_rec.result_value := l_result_value_char;
                x_inv_rslt_out_rec.Min_Value    := l_min_value_char;
                x_inv_rslt_out_rec.Max_Value    := l_max_value_char;
            ELSIF (l_test_type IN ('E','L','N')) THEN -- numeric test type
                x_inv_rslt_out_rec.Min_Value     := l_min_value_num;
                x_inv_rslt_out_rec.Max_Value     := l_max_value_num;

                -- Setting the display precision
                IF (l_Display_Precision IS NOT NULL) THEN
                   x_inv_rslt_out_rec.Display_precision := l_Display_Precision;
                   x_inv_rslt_out_rec.result_value :=
                               get_display_precision(l_result_value_num,
                                                     l_Display_Precision);
                ELSE
                   x_inv_rslt_out_rec.result_value := l_result_value_num;
                END IF;
            END IF;

            x_inv_rslt_out_rec.result_id     := l_result_id;
            x_inv_rslt_out_rec.Spec_id       := X_sampling_events(i).spec_id;
            x_inv_rslt_out_rec.composite_ind := 1;
            l_row_num := i;
            l_test_found := TRUE;
          ELSE -- No Results were found
            FND_MESSAGE.SET_NAME('GMD','GMD_RESULT_NOT_FOUND');
            FND_MESSAGE.SET_TOKEN('SAMPLE_ID', X_sampling_events(i).sample_id);
            FND_MESSAGE.SET_TOKEN('TEST_ID', p_inv_rslt_inp_rec.test_id);
            FND_MSG_PUB.ADD;
          END IF; -- geting simple results

        CLOSE get_simple_results;
      END IF; -- condition to check if simple or composite results
      IF l_test_found THEN -- Either a simple or composite result was found
         EXIT ;
      END IF;
    END LOOP; -- goes thro all sampling events

    -- get the level
    IF (l_row_num > 0) THEN
      l_level_rec.organization_id := X_sampling_events(l_row_num).organization_id;
      l_level_rec.inventory_item_id   := X_sampling_events(l_row_num).inventory_item_id ;
      l_level_rec.parent_lot_number   := X_sampling_events(l_row_num).parent_lot_number ;
      l_level_rec.lot_number    := X_sampling_events(l_row_num).lot_number ;
      l_level_rec.subinventory := X_sampling_events(l_row_num).subinventory;
      l_level_rec.locator_id  := X_sampling_events(l_row_num).locator_id ;

      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('Getting the level for inventory item_id '
               ||X_sampling_events(l_row_num).organization_id);
      END IF;

      GMD_QUALITY_GRP.get_level
      ( p_inv_inp_rec         => l_level_rec
      , p_called_from         => 'RESULT'
      , x_level               => x_inv_rslt_out_rec.level
      , x_return_status       => x_return_status
      );

      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('The return status from get_level '||x_return_status);
      END IF;
    END IF; -- when l_row_num > 0

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
  END get_inv_result_test_value;


 /*  ************************************************************************ */
 /*  API name    : get_appr_sampling_events                                   */
 /*  Type        : Private                                                    */
 /*  Function    :                                                            */
 /*  Pre-reqs    : None.                                                      */
 /*  Parameters  :                                                            */
 /*  IN          : p_inv_rslt_inp_rec    IN      inv_inp_rec_type  (Required) */
 /*                                                                           */
 /*  OUT         : x_return_status       OUT     VARCHAR2(1)                  */
 /*              : x_sampling_events_tbl OUT     sampling_events_tbl_type     */
 /*                                                                           */
 /*  Notes       : Given the item, organization_id, parent_lot, lot,          */
 /*                 subinventory, locator_id and                              */
 /*                grade information this API gets the list of the sampling   */
 /*                that have approved disposition.                            */
 /*                                                                           */
 /*  HISTORY                                                                  */
 /*  20-Feb-2003   Shyam Sitaraman        Initial Implementation              */
 /*  10-JUN-2005  Saikiran Vankadari  Convergence Changes. Replaced all       */
 /*                                  opm-inventory references with that of    */
 /*                                   discrete inventory                      */
 /*  ************************************************************************ */
PROCEDURE get_appr_sampling_events
 ( p_inv_rslt_inp_rec    IN            inv_inp_rec_type
 , x_sampling_events_tbl OUT  NOCOPY   sampling_events_tbl_type
 , x_return_status       OUT  NOCOPY   VARCHAR2
 )
  IS
    l_api_name  VARCHAR2(100)  := 'GET_APPR_SAMPLING_EVENTS';
    i           NUMBER         := 0;

    -- Cursor for selecting approved sampling events
    CURSOR  get_sample_events IS
      SELECT  se.sampling_event_id, se.sample_active_cnt, se.inventory_item_id,
              se.parent_lot_number, se.lot_number, se.subinventory, se.locator_id,
              sd.event_spec_disp_id,  sd.spec_id
      FROM    gmd_sampling_events se,
              gmd_event_spec_disp sd
      WHERE   se.sampling_event_id = sd.sampling_event_id
      AND     se.inventory_item_id = p_inv_rslt_inp_rec.inventory_item_id
      AND     ((se.parent_lot_number = p_inv_rslt_inp_rec.parent_lot_number)
              OR (p_inv_rslt_inp_rec.parent_lot_number IS NULL AND se.parent_lot_number IS NULL)
              OR (p_inv_rslt_inp_rec.parent_lot_number IS NOT NULL AND se.parent_lot_number IS NULL))
      AND     ((se.lot_number = p_inv_rslt_inp_rec.lot_number)
              OR (p_inv_rslt_inp_rec.lot_number IS NULL AND se.lot_number IS NULL)
              OR (p_inv_rslt_inp_rec.lot_number IS NOT NULL AND se.lot_number IS NULL))
      AND     ((se.subinventory = p_inv_rslt_inp_rec.subinventory)
              OR (p_inv_rslt_inp_rec.subinventory IS NULL AND se.subinventory IS NULL)
              OR (p_inv_rslt_inp_rec.subinventory IS NOT NULL AND se.subinventory IS NULL))
      AND     ((se.locator_id = p_inv_rslt_inp_rec.locator_id)
              OR (p_inv_rslt_inp_rec.locator_id IS NULL AND se.locator_id IS NULL)
              OR (p_inv_rslt_inp_rec.locator_id IS NOT NULL AND se.locator_id IS NULL))
      AND     sd.spec_used_for_lot_attrib_ind = 'Y'
      -- B3698232 Added dispostion 'In-Progress' and 'Complete' for single sample
      -- AND     sd.disposition IN ('4A','5AV')
      AND     sd.disposition IN ('2I', '3C', '4A','5AV')
      AND     EXISTS (Select 1
                      From gmd_samples s, gmd_results r
                      Where s.sample_id =  r.sample_id
                      AND r.test_id = p_inv_rslt_inp_rec.test_id
                      AND s.organization_id = p_inv_rslt_inp_rec.organization_id
                      AND s.delete_mark = 0
                      AND r.delete_mark = 0
                      AND s.sampling_event_id = se.sampling_event_id)
      ORDER BY se.lot_number, se.parent_lot_number, se.subinventory, se.locator_id,
               se.last_update_date desc;

    CURSOR  get_samples(vSampling_Event_Id  NUMBER,
                        vEvent_spec_disp_id NUMBER)  IS
      SELECT  smp.sample_id
      FROM    gmd_samples smp, gmd_sample_spec_disp sd
      WHERE   smp.sampling_event_id = vSampling_Event_Id
      AND     smp.organization_id   = p_inv_rslt_inp_rec.organization_id
      AND     smp.sample_id         = sd.sample_id
      AND     sd.event_spec_disp_id = vEvent_spec_disp_id
      AND     smp.delete_mark       = 0
      AND     sd.disposition       NOT IN  ('0RT','7CN')
      ORDER BY smp.last_update_date desc;

    -- Exception Definition
    No_Appr_Sample_evt_exp     EXCEPTION;

  BEGIN
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('Begining get_appr_sampling_evnt proc, '
                 ||' inventory_item_id = '||p_inv_rslt_inp_rec.inventory_item_id
                 ||' organization_id = '||p_inv_rslt_inp_rec.organization_id
                 ||' test_id = '||p_inv_rslt_inp_rec.test_id
                 ||' parent_lot_number = '||p_inv_rslt_inp_rec.parent_lot_number
                 ||' lot_number = '||p_inv_rslt_inp_rec.lot_number);
      END IF;
    FOR sampling_rec IN get_sample_events LOOP
      i := i + 1;
      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('Before assigning values , i value = '||i);
      END IF;
      x_sampling_events_tbl(i).sampling_event_id  := sampling_rec.sampling_event_id;
      x_sampling_events_tbl(i).event_spec_disp_id := sampling_rec.event_spec_disp_id;
      x_sampling_events_tbl(i).sample_active_cnt  := sampling_rec.sample_active_cnt;
      x_sampling_events_tbl(i).spec_id            := sampling_rec.spec_id;
      x_sampling_events_tbl(i).organization_id    := p_inv_rslt_inp_rec.organization_id;
      x_sampling_events_tbl(i).inventory_item_id  := sampling_rec.inventory_item_id ;
      x_sampling_events_tbl(i).parent_lot_number  := sampling_rec.parent_lot_number  ;
      x_sampling_events_tbl(i).lot_number         := sampling_rec.lot_number  ;
      x_sampling_events_tbl(i).subinventory       := sampling_rec.subinventory ;
      x_sampling_events_tbl(i).locator_id         := sampling_rec.locator_id ;

      -- Get the sample id
      OPEN get_samples(x_sampling_events_tbl(i).sampling_event_id
                      ,x_sampling_events_tbl(i).event_spec_disp_id);
      FETCH get_samples INTO x_sampling_events_tbl(i).sample_id;
      CLOSE get_samples;
      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('i value = '||i);
        gmd_debug.put_line('The sample id  = '||x_sampling_events_tbl(i).sample_id);
      END IF;
    END LOOP;

    IF (i = 0) THEN
       RAISE No_Appr_Sample_evt_exp;
    END IF;

 EXCEPTION
    WHEN No_Appr_Sample_evt_exp THEN
      FND_MESSAGE.SET_NAME('GMD','GMD_SAMPLING_EVENT_NOT_FOUND');
      FND_MSG_PUB.ADD;
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
  END get_appr_sampling_events;


 /*  ************************************************************************ */
 /*  API name    : get_inv_spec_test_value                                    */
 /*  Type        : Private                                                    */
 /*  Function    :                                                            */
 /*  Pre-reqs    : None.                                                      */
 /*  Parameters  :                                                            */
 /*  IN          : p_inv_spec_inp_rec    IN      inv_inp_rec_type  (Required) */
 /*                                                                           */
 /*  OUT         : x_return_status       OUT     VARCHAR2(1)                  */
 /*              : x_inv_spec_out_rec    OUT     inv_rslt_out_rec_type        */
 /*                                                                           */
 /*                x_inv_spec_out_rec.Spec_Id (Specification id)              */
 /*                x_inv_spec_out_rec.Target_Value (Numeric or char target)   */
 /*                x_inv_spec_out_rec.Min_Value (Spec test lower limit)       */
 /*                x_inv_spec_out_rec.Max_Value (Spec test upper limit)       */
 /*                x_inv_spec_out_rec.level (value representing inventory/lot */
 /*                                          specification tests              */
 /*                                                                           */
 /*  Notes       : Given the item, organization_id, parent_lot, lot,          */
 /*                 subinventory, locator_id and                              */
 /*                grade information this API gets the inventory spec value   */
 /*                for a test.  This API can be called independently to return*/
 /*                the inventory specs                                        */
 /*  HISTORY                                                                  */
 /*  20-Feb-2003   Shyam Sitaraman   Initial Implementation                   */
 /*  10-JUN-2005  Saikiran Vankadari  Convergence Changes. Replaced all       */
 /*                                  opm-inventory references with that of    */
 /*                                   discrete inventory                      */
 /*  ************************************************************************ */
  PROCEDURE get_inv_spec_test_value
  ( p_inv_spec_inp_rec    IN            inv_inp_rec_type
  , x_inv_spec_out_rec    OUT  NOCOPY   inv_spec_out_rec_type
  , x_return_status       OUT  NOCOPY   VARCHAR2
  )
  IS
    l_api_name             VARCHAR2(100)  := 'GET_INV_SPEC_TEST_VALUE';
    l_inventory_spec_rec   GMD_SPEC_MATCH_GRP.inventory_spec_rec_type;
    l_level_rec            GMD_QUALITY_GRP.inv_inp_rec_type;
    x_spec_id              NUMBER;
    x_spec_vr_id           NUMBER;
    x_msg_data             VARCHAR2(2000);

    -- get the test_type from gmd_qc_tests to check if it is numeric/char type
    CURSOR get_spec_test(vSpec_id NUMBER, vTest_id NUMBER) IS
      SELECT st.target_value_char, st.target_value_num ,
             st.min_value_char, st.min_value_num ,
             st.max_value_char, st.max_value_num ,
             qt.test_type, st.spec_id,
             NVL(st.display_precision, qt.display_precision) display_precision
      FROM   gmd_spec_tests_b st, gmd_qc_tests_b qt
      WHERE  st.spec_id = vSpec_id
      AND    st.test_id = vTest_id
      AND    st.test_id = qt.test_id;

    CURSOR get_spec_vr(vSpec_vr_id NUMBER) IS
      SELECT organization_id, parent_lot_number, lot_number,
             subinventory, locator_id
      FROM   gmd_inventory_spec_vrs
      WHERE  spec_vr_id = vSpec_vr_id;

  BEGIN
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_inventory_spec_rec.inventory_item_id    := p_inv_spec_inp_rec.inventory_item_id;
    l_inventory_spec_rec.grade_code           := p_inv_spec_inp_rec.grade_code;
    l_inventory_spec_rec.organization_id      := p_inv_spec_inp_rec.organization_id;
    l_inventory_spec_rec.parent_lot_number    := p_inv_spec_inp_rec.parent_lot_number;
    l_inventory_spec_rec.lot_number           := p_inv_spec_inp_rec.lot_number;
    l_inventory_spec_rec.subinventory         := p_inv_spec_inp_rec.subinventory;
    l_inventory_spec_rec.locator_id           := p_inv_spec_inp_rec.locator_id ;
    l_inventory_spec_rec.date_effective  := SYSDATE;
    l_inventory_spec_rec.exact_match     := 'N' ;

    -- get the inventory spec match
    IF GMD_SPEC_MATCH_GRP.find_inventory_spec
     ( p_inventory_spec_rec  => l_inventory_spec_rec
     , x_spec_id             => x_spec_id
     , x_spec_vr_id          => x_spec_vr_id
     , x_return_status       => x_return_status
     , x_message_data        => x_msg_data) THEN

     IF (l_debug = 'Y') THEN
        gmd_debug.put_line('The spec and spec_vr id = '||x_spec_id||' x '||x_spec_vr_id);
     END IF;

     IF x_spec_id IS NOT NULL THEN
       -- Spec test match is found
       FOR get_spec_rec IN get_spec_test(x_Spec_id, p_inv_spec_inp_rec.test_id)
       LOOP
         x_inv_spec_out_rec.Spec_Id        := get_spec_rec.spec_id;
         IF (l_debug = 'Y') THEN
             gmd_debug.put_line('The test type = '||get_spec_rec.test_type);
         END IF;
         IF get_spec_rec.test_type IN ('E','L','N') THEN -- numeric test types
           IF (l_debug = 'Y') THEN
               gmd_debug.put_line('The target_val_num = '||get_spec_rec.target_value_num);
           END IF;
           IF get_spec_rec.target_value_num IS NOT NULL THEN
              x_inv_spec_out_rec.target_value := get_spec_rec.target_value_num;
           ELSIF (get_spec_rec.max_value_num IS NOT NULL
                 AND get_spec_rec.min_value_num IS NOT NULL) THEN
              x_inv_spec_out_rec.target_value
                 := (get_spec_rec.min_value_num + get_spec_rec.max_value_num)/2;
           ELSIF get_spec_rec.min_value_num IS NOT NULL THEN
              x_inv_spec_out_rec.target_value := get_spec_rec.min_value_num;
           ELSIF get_spec_rec.max_value_num IS NOT NULL THEN
              x_inv_spec_out_rec.target_value := get_spec_rec.max_value_num;
           END IF;

           -- setting the spec target value with the display precision
           IF (get_spec_rec.display_precision IS NOT NULL) THEN
               x_inv_spec_out_rec.display_precision := get_spec_rec.display_precision;
               x_inv_spec_out_rec.target_value
                  := get_display_precision(
                                     to_number(x_inv_spec_out_rec.target_value),
                                     get_spec_rec.display_precision);
           END IF;
           x_inv_spec_out_rec.Min_Value    := get_spec_rec.min_value_num;
           x_inv_spec_out_rec.Max_Value    := get_spec_rec.max_value_num;

         ELSE -- character test types
           IF (l_debug = 'Y') THEN
               gmd_debug.put_line('The target_val_char = '||get_spec_rec.target_value_char);
           END IF;
           x_inv_spec_out_rec.target_value := get_spec_rec.target_value_char;
           x_inv_spec_out_rec.Min_Value    := get_spec_rec.min_value_char;
           x_inv_spec_out_rec.Max_Value    := get_spec_rec.max_value_char;
         END IF;
       END LOOP;

       IF x_spec_vr_id IS NOT NULL THEN
         FOR get_spec_vr_rec IN get_spec_vr(x_Spec_vr_id) LOOP
           l_level_rec.organization_id := get_spec_vr_rec.organization_id;
           l_level_rec.parent_lot_number  := get_spec_vr_rec.parent_lot_number ;
           l_level_rec.lot_number    := get_spec_vr_rec.lot_number ;
           l_level_rec.subinventory := get_spec_vr_rec.subinventory;
           l_level_rec.locator_id  := get_spec_vr_rec.locator_id ;
         END LOOP;
       END IF;

       l_level_rec.inventory_item_Id     := p_inv_spec_inp_rec.inventory_item_Id ;
       l_level_rec.grade_code       := p_inv_spec_inp_rec.grade_code  ;

       -- get the level
       GMD_QUALITY_GRP.get_level
       ( p_inv_inp_rec         => l_level_rec
       , p_called_from         => 'TEST'
       , x_level               => x_inv_spec_out_rec.level
       , x_return_status       => x_return_status
       );

     END IF; -- If spec id is not null
    ELSE
      FND_MESSAGE.SET_NAME('GMD','GMD_SPEC_NOT_FOUND');
      FND_MSG_PUB.ADD;
    END IF; -- If the inventory spec match exists

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
  END get_inv_spec_test_value;

 /*  ************************************************************************ */
 /*  API name    : get_level                                    */
 /*  Type        : Private                                                    */
 /*  Function    :                                                            */
 /*  Pre-reqs    : None.                                                      */
 /*  Parameters  :                                                            */
 /*  IN          : p_inv_spec_inp_rec    IN      inv_inp_rec_type  (Required) */
 /*                p_called_from         IN      VARCHAR2 (Required - either  */
 /*                                                        'TEST' / 'RESULT') */
 /*                                                                           */
 /*  OUT         : x_return_status       OUT     VARCHAR2(1)                  */
 /*              : x_level               OUT     NUMBER                       */
 /*                                                                           */
 /*                                                                           */
 /*  Notes       : Given the item, organization_id, parent lot, lot,          */
 /*                subinventory, locator_id and                               */
 /*                grade information this API gets the level i.e. it based    */
 /*                based on the number returned (x_level) users can identify  */
 /*                if the test value was based on results or specs and if it  */
 /*                was inventory or lot or grade specific.  More details on   */
 /*                implecation of the value returned please refer to the QM   */
 /*                Fetch API Detailed Design doc                              */
 /*                                                                           */
 /*  HISTORY                                                                  */
 /*  20-Feb-2003   Shyam Sitaraman        Initial Implementation              */
 /*  10-JUN-2005  Saikiran Vankadari  Convergence Changes. Replaced all       */
 /*                                  opm-inventory references with that of    */
 /*                                   discrete inventory                      */
 /*  ************************************************************************ */
  PROCEDURE get_level
  ( p_inv_inp_rec         IN             inv_inp_rec_type
  , p_called_from         IN             VARCHAR2
  , x_level               OUT  NOCOPY    NUMBER
  , x_return_status       OUT  NOCOPY    VARCHAR2
  )
  IS
    l_api_name           VARCHAR2(100)  := 'GET_LEVEL';
  BEGIN
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF  (p_called_from = 'RESULT') THEN
       -- When there is an exact match on Organization , inventory_item_id, lot_number, subinventory
       -- and locator_id
       IF(( p_inv_inp_rec.organization_id IS NOT NULL) AND
          ( p_inv_inp_rec.lot_number IS NOT NULL) AND
          ( p_inv_inp_rec.subinventory IS NOT NULL) AND
          ( p_inv_inp_rec.locator_id IS NOT NULL))  THEN

          x_Level := 1;

       ELSIF (( p_inv_inp_rec.organization_id IS NOT NULL) AND
          ( p_inv_inp_rec.parent_lot_number IS NOT NULL) AND
          ( p_inv_inp_rec.subinventory  IS NOT NULL) AND
          ( p_inv_inp_rec.locator_id IS NOT NULL)) THEN

          x_Level := 2;

       ELSIF (( p_inv_inp_rec.organization_id IS NOT NULL) AND
          ( p_inv_inp_rec.lot_number IS NOT NULL) AND
          ( p_inv_inp_rec.subinventory IS NOT NULL)) THEN

          x_Level := 3;

       ELSIF (( p_inv_inp_rec.organization_id IS NOT NULL) AND
          ( p_inv_inp_rec.parent_lot_number IS NOT NULL) AND
          ( p_inv_inp_rec.subinventory IS NOT NULL)) THEN

          x_Level := 4;

       ELSIF (( p_inv_inp_rec.organization_id IS NOT NULL) AND
          ( p_inv_inp_rec.lot_number IS NOT NULL)) THEN

          x_Level := 5;

       ELSIF (( p_inv_inp_rec.organization_id IS NOT NULL) AND
          ( p_inv_inp_rec.parent_lot_number IS NOT NULL)) THEN

          x_Level := 6;

       ELSE
          x_Level := 11;

       END IF;
     ELSIF  (p_called_from = 'TEST') THEN
       IF (p_inv_inp_rec.grade_code IS NOT NULL) THEN

         IF(( p_inv_inp_rec.organization_id IS NOT NULL) AND
            ( p_inv_inp_rec.lot_number IS NOT NULL) AND
            ( p_inv_inp_rec.subinventory IS NOT NULL) AND
            ( p_inv_inp_rec.locator_id IS NOT NULL))  THEN

            x_Level := 21;

         ELSIF (( p_inv_inp_rec.organization_id IS NOT NULL) AND
            ( p_inv_inp_rec.parent_lot_number IS NOT NULL) AND
            ( p_inv_inp_rec.subinventory  IS NOT NULL) AND
            ( p_inv_inp_rec.locator_id IS NOT NULL)) THEN

            x_Level := 22;

         ELSIF (( p_inv_inp_rec.organization_id IS NOT NULL) AND
            ( p_inv_inp_rec.lot_number IS NOT NULL) AND
            ( p_inv_inp_rec.subinventory IS NOT NULL)) THEN

            x_Level := 23;

         ELSIF (( p_inv_inp_rec.organization_id IS NOT NULL) AND
            ( p_inv_inp_rec.parent_lot_number IS NOT NULL) AND
            ( p_inv_inp_rec.subinventory IS NOT NULL)) THEN

            x_Level := 24;

         ELSIF (( p_inv_inp_rec.organization_id IS NOT NULL) AND
            ( p_inv_inp_rec.lot_number IS NOT NULL)) THEN

            x_Level := 25;

         ELSIF (( p_inv_inp_rec.organization_id IS NOT NULL) AND
            ( p_inv_inp_rec.parent_lot_number IS NOT NULL)) THEN

            x_Level := 26;

         ELSE
            x_Level := 41;

         END IF;

       ELSE  -- if p_inv_inp_rec.grade_code is null

         IF(( p_inv_inp_rec.organization_id IS NOT NULL) AND
            ( p_inv_inp_rec.lot_number IS NOT NULL) AND
            ( p_inv_inp_rec.subinventory IS NOT NULL) AND
            ( p_inv_inp_rec.locator_id IS NOT NULL))  THEN

            x_Level := 31;

         ELSIF (( p_inv_inp_rec.organization_id IS NOT NULL) AND
            ( p_inv_inp_rec.parent_lot_number IS NOT NULL) AND
            ( p_inv_inp_rec.subinventory  IS NOT NULL) AND
            ( p_inv_inp_rec.locator_id IS NOT NULL)) THEN

            x_Level := 32;

         ELSIF (( p_inv_inp_rec.organization_id IS NOT NULL) AND
            ( p_inv_inp_rec.lot_number IS NOT NULL) AND
            ( p_inv_inp_rec.subinventory IS NOT NULL)) THEN

            x_Level := 33;

         ELSIF (( p_inv_inp_rec.organization_id IS NOT NULL) AND
            ( p_inv_inp_rec.parent_lot_number IS NOT NULL) AND
            ( p_inv_inp_rec.subinventory IS NOT NULL)) THEN

            x_Level := 34;

         ELSIF (( p_inv_inp_rec.organization_id IS NOT NULL) AND
            ( p_inv_inp_rec.lot_number IS NOT NULL)) THEN

            x_Level := 35;

         ELSIF (( p_inv_inp_rec.organization_id IS NOT NULL) AND
            ( p_inv_inp_rec.parent_lot_number IS NOT NULL)) THEN

            x_Level := 36;

         ELSE
            x_Level := 51;

         END IF;
      END IF; -- check if grade_code is null
    END IF;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
  END get_level;

END GMD_QUALITY_GRP;

/
