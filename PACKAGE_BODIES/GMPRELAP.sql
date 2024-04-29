--------------------------------------------------------
--  DDL for Package Body GMPRELAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMPRELAP" AS
/* $Header: GMPRELAB.pls 120.11.12010000.12 2009/07/13 11:08:47 vpedarla ship $ */

PROCEDURE create_new_batch(
                   p_process_id          IN NUMBER,
                   p_inventory_item_id   IN NUMBER,   -- For R12.0
                   p_item_no             IN VARCHAR2, -- For R12.0
                   p_primary_uom_code    IN VARCHAR2, -- For R12.0
                   p_organization_id     IN NUMBER,   -- For R12.0
                   p_batch_id            IN NUMBER,
                   p_effectivity_id      IN NUMBER,
                   p_plan_quantity       IN NUMBER,
                   p_start_date          IN DATE,
                   p_end_date            IN DATE,
                   p_required_completion IN DATE,     -- For R12.0
                   p_order_priority      IN NUMBER,   -- For R12.0
                   p_firmed_ind          IN NUMBER,   -- For R12.0
                   p_header_id           IN NUMBER,
                   p_scheduling_method   IN NUMBER,
                   p_batch_no            IN VARCHAR2,
                   p_batch_type          IN NUMBER,
                   p_rowid               IN ROWID
                   ) ;

PROCEDURE validate_effectivities(
                   p_organization_id   IN NUMBER,
                   p_inventory_item_id IN NUMBER,
                   p_effectivity_id    IN NUMBER,
                   p_plan_quantity     IN NUMBER,
                   p_batch_type        IN NUMBER, /* B5259453 */
                   p_start_date        IN DATE,
                   p_end_date          IN DATE,
                   p_recipe_id         OUT NOCOPY NUMBER, -- For R12.0
                   p_return            OUT NOCOPY NUMBER); -- For R12.0

PROCEDURE  scheduling_details_create(
                   p_batch_id             IN  NUMBER,
                   p_process_id           IN  NUMBER,
                   p_header_id            IN  NUMBER,
                   p_plan_start_date      IN  DATE,
                   p_plan_end_date        IN  DATE,
                   p_required_completion  IN  DATE,     -- For R12.0
                   p_order_priority       IN  NUMBER,   -- For R12.0
                   p_organization_id      IN  NUMBER,   -- For R12.0
                   p_eff_id               IN  NUMBER);

PROCEDURE reschedule_batch(
                   p_process_id          IN NUMBER,
                   p_organization_id     IN NUMBER,  -- For R12.0
                   p_plan_quantity       IN NUMBER,
                   p_start_date          IN DATE,
                   p_end_date            IN DATE,
                   p_required_completion IN DATE,   -- For R12.0
                   p_order_priority      IN NUMBER, -- For R12.0
                   p_scheduling_method   IN NUMBER,
                   p_batch_id            IN NUMBER,
                   p_header_id           IN NUMBER,
                   p_processed_ind       IN NUMBER,
                   p_rowid               IN ROWID
                   ) ;

PROCEDURE  scheduling_details_resc(
                   p_batch_id             IN  NUMBER,
                   p_process_id           IN  NUMBER,
                   p_header_id            IN  NUMBER,
                   p_plan_start_date      IN  DATE,
                   p_plan_end_date        IN  DATE,
                   p_required_completion  IN  DATE,     -- For R12.0
                   p_order_priority       IN  NUMBER,   -- For R12.0
                   p_organization_id      IN  NUMBER,   -- For R12.0
                   p_eff_id               IN  NUMBER,
                   return_status          OUT NOCOPY NUMBER) ;

PROCEDURE cancel_batch(
                   p_process_id         IN NUMBER,
                   p_organization_id    IN NUMBER,   -- For R12.0
                   p_start_date         IN DATE,
                   p_end_date           IN DATE,
                   p_batch_id           IN NUMBER,
                   p_header_id          IN NUMBER,
                   p_processed_ind      IN NUMBER,
                   p_rowid              IN ROWID
                   ) ;
/*
REM+========================================================================+
REM| Procedure:                                                             |
REM|   implement_aps_plng_sugg                                              |
REM|                                                                        |
REM| DESCRIPTION:                                                           |
REM|                                                                        |
REM| Calls the appropriate procedure depending on the Action Type           |
REM|                                                                        |
REM| History :                                                              |
REM| Sridhar 30-SEP-2003  Initial implementation                            |
REM| Rajesh Patangya 	22-AUG-2005   Changes for Release 12.0              |
REM| Vpedarla Bug: 7258717 Added new parameter p_process_id                 |
REM+=======================================================================*/
PROCEDURE Implement_Aps_Plng_Sugg(
                   errbuf             OUT NOCOPY VARCHAR2,
                   retcode            OUT NOCOPY VARCHAR2,
                   p_organization_id  IN  NUMBER  ,
                   p_process_id       IN  NUMBER,
                   p_fitem_no         IN  VARCHAR2,
                   p_titem_no         IN  VARCHAR2,
                   p_fdate            IN  VARCHAR2,
                   p_tdate            IN  VARCHAR2,
                   p_order_type       IN  NUMBER) IS

  CURSOR Cur_gmp_output_tbl(
                   c_process_id   NUMBER,
                   c_organization_id NUMBER,
                   c_fitem_no        VARCHAR2,
                   c_titem_no        VARCHAR2,
                   c_fdate           DATE,
                   c_tdate           DATE
                           ) IS
  SELECT gmp.process_id,
         gmp.inventory_item_id,
         mtl.segment1,
         mtl.primary_uom_code,
         gmp.organization_id,
         gmp.batch_id,
         gmp.effectivity_id,
         gmp.plan_quantity,
         gmp.plan_start_date,
         gmp.plan_end_date,
         nvl( gmp.required_completion_date,gmp.plan_end_date) ,  -- Vpedarla Bug: 8348883
   --      gmp.required_completion_date,  /* APS K */
         gmp.order_priority,
         gmp.firm_flag,
         gmp.action_type,
         gmp.processed_ind,
         gmp.header_id,
         gmp.scheduling_method,
         gmp.rowid
  FROM   gmp_aps_output_tbl gmp,
         mtl_system_items mtl
  WHERE  gmp.processed_ind > 0
  AND   gmp.process_id = nvl(c_process_id,gmp.process_id)  /* vpedarla bug: 7258717 */
  AND   gmp.inventory_item_id = mtl.inventory_item_id
  AND   gmp.organization_id  = mtl.organization_id
  AND   gmp.organization_id  = nvl(c_organization_id,gmp.organization_id)
  AND   mtl.segment1 >= nvl(c_fitem_no,mtl.segment1)
  AND   mtl.segment1 <= nvl(c_titem_no,mtl.segment1)
  AND   gmp.plan_start_date >= nvl(c_fdate,gmp.plan_start_date)
  AND   gmp.plan_start_date <= nvl(c_tdate,gmp.plan_start_date)
  AND   gmp.action_type = 1
  UNION ALL
  SELECT gmp.process_id,
         gmp.inventory_item_id,
         to_char(NULL),
         to_char(NULL),
         gmp.organization_id,
         gmp.batch_id,
         gmp.effectivity_id,
         gmp.plan_quantity,
         gmp.plan_start_date,
         gmp.plan_end_date,
         nvl( gmp.required_completion_date,gmp.plan_end_date) ,  -- Vpedarla Bug: 8348883
   --    gmp.required_completion_date,  /* APS K */
         gmp.order_priority,
         gmp.firm_flag,
         gmp.action_type,
         gmp.processed_ind,
         gmp.header_id,
         gmp.scheduling_method,
         gmp.rowid
  FROM   gmp_aps_output_tbl gmp
  WHERE  gmp.processed_ind > 0
  AND   gmp.process_id = nvl(c_process_id,gmp.process_id)  /* vpedarla bug: 7258717 */
  AND   gmp.organization_id  = nvl(c_organization_id,gmp.organization_id)
  AND   gmp.plan_start_date >= nvl(c_fdate,gmp.plan_start_date)
  AND   gmp.plan_start_date <= nvl(c_tdate,gmp.plan_start_date)
  AND   gmp.action_type <> 1 ;

  TYPE get_data_typ is RECORD
  (
    process_id               NUMBER,
    inventory_item_id        NUMBER,
    item_no                  VARCHAR2(240),
    primary_uom_code         VARCHAR2(3),
    organization_id          NUMBER,
    batch_id                 NUMBER,
    effectivity_id           NUMBER,
    plan_quantity            NUMBER,
    plan_start_date          DATE,
    plan_end_date            DATE,
    required_completion_date DATE,
    order_priority           NUMBER,
    firmed_ind               NUMBER,
    action_type              NUMBER,
    processed_ind            NUMBER,
    header_id                NUMBER,
    scheduling_method        NUMBER,
    rowid                    VARCHAR2(25)
  );

  get_data_rec       get_data_typ;
  v_batch_no         VARCHAR2(32);
  v_batch_type       NUMBER(5);
  v_errbuf           VARCHAR2(2000);
  v_retcode          VARCHAR2(15);
  X_assignment_type  NUMBER;
  X_count            NUMBER ;
  NO_ROWS            EXCEPTION;
  MANUAL_DOC_TYPE    EXCEPTION;
  CHECK_DATE         EXCEPTION;
  l_from_date        DATE;
  l_to_date          DATE;
  l_updt_offsets     NUMBER;  /*B5148802 - sowsubra - Activity offset updation*/

BEGIN
    X_count          := 0;
    retcode          := '0';

  /* B7609461 Rajesh Patangya 11-DEC-2008  */
     gmd_p_fs_context.set_additional_attr;

    l_updt_offsets   := nvl(FND_PROFILE.VALUE('GMP_UPDATE_ACTIVITY_OFFSETS'),0);/*B5148802*/
    /*  B7530107 Reset everything for GME so that
            for every record it will go and set the org, calendar information */
    gme_common_pvt.g_setup_done := FALSE ;

      FND_FILE.PUT_LINE ( FND_FILE.LOG,'===== Input Parameters ===== ');
      FND_FILE.PUT_LINE ( FND_FILE.LOG,'p_process_id = ' || p_process_id);
      FND_FILE.PUT_LINE ( FND_FILE.LOG,'p_organization_id = ' || p_organization_id);
      FND_FILE.PUT_LINE ( FND_FILE.LOG,'p_fitem_no = ' || p_fitem_no);
      FND_FILE.PUT_LINE ( FND_FILE.LOG,'p_titem_no = ' || p_titem_no);
      FND_FILE.PUT_LINE ( FND_FILE.LOG,'p_fdate = ' || p_fdate);
      FND_FILE.PUT_LINE ( FND_FILE.LOG,'p_tdate = ' || p_tdate);

    /* { */
    IF p_tdate IS NOT NULL AND p_fdate IS NOT NULL THEN

     /* B5857203, Rajesh Patangya ONDEMAND:ASCP/OPM BATCH RELEASE FAILURE * ORA-06550  */

      l_from_date      := fnd_date.canonical_to_date(p_fdate);
      l_to_date        := fnd_date.canonical_to_date(p_tdate);

   --   l_from_date      := fnd_date.charDT_to_date(p_fdate);
   --   l_to_date        := fnd_date.charDT_to_date(p_tdate);

      FND_FILE.PUT_LINE ( FND_FILE.LOG,'l_from_date = ' || l_from_date);
      FND_FILE.PUT_LINE ( FND_FILE.LOG,'l_to_date = ' || l_to_date);

      IF l_updt_offsets = 1 THEN
        FND_FILE.PUT_LINE ( FND_FILE.LOG,'Profile Update activity offset is set');
      ELSE
        FND_FILE.PUT_LINE ( FND_FILE.LOG,'Profile Update activity offset is not set');
      END IF;

      IF (l_to_date < l_from_date) THEN
         RAISE CHECK_DATE;
      END IF;

   ELSE
      l_from_date := NULL;
      l_to_date   := NULL;
    END IF;

    OPEN Cur_gmp_output_tbl(p_process_id , p_organization_id,p_fitem_no,p_titem_no,
                            l_from_date,l_to_date);
    LOOP
       FETCH Cur_gmp_output_tbl  INTO get_data_rec;
       EXIT WHEN Cur_gmp_output_tbl%NOTFOUND;
       IF get_data_rec.action_type = 1 THEN   /* New Batch */

          IF ( p_order_type = 1) THEN
           -- FPO
           SELECT FPO_DOC_NUMBERING
            INTO X_assignment_type
           FROM  gme_parameters
           WHERE organization_id = get_data_rec.organization_id ;

           v_batch_type := 10 ;
           FND_FILE.PUT_LINE ( FND_FILE.LOG,'Implementing FPOs ');
          ELSE
           -- Batch
           SELECT BATCH_DOC_NUMBERING
            INTO X_assignment_type
           FROM  gme_parameters
           WHERE organization_id = get_data_rec.organization_id ;

           v_batch_type := 0 ;
           FND_FILE.PUT_LINE ( FND_FILE.LOG,'Implementing Batches ');
          END IF;

          IF (X_assignment_type = 1)  THEN  -- Manual Numbering
              RAISE MANUAL_DOC_TYPE;
          END IF;

          FND_MESSAGE.SET_NAME('GMA','SY_$NEW');
          v_batch_no := FND_MESSAGE.GET;  -- Manual Batch Number
          /* Start Processing */
           create_new_batch(
                          get_data_rec.process_id,
                          get_data_rec.inventory_item_id,
                          get_data_rec.item_no,
                          get_data_rec.primary_uom_code,
                          get_data_rec.organization_id,
                          get_data_rec.batch_id,
                          get_data_rec.effectivity_id,
                          get_data_rec.plan_quantity,
                          get_data_rec.plan_start_date,
                          get_data_rec.plan_end_date,
                          get_data_rec.required_completion_date,
                          get_data_rec.order_priority,
                          get_data_rec.firmed_ind,
                          get_data_rec.header_id,
                          get_data_rec.scheduling_method,
                          v_batch_no,
                          v_batch_type,
                          get_data_rec.rowid
                         );
           /*B5148802 - sowsubra - Activity offset updation*/
           IF l_updt_offsets = 1 THEN
        	gmp_aps_writer.update_activity_offsets (get_data_rec.batch_id);
           END IF;

        ELSIF get_data_rec.action_type = 3 THEN /* Reschedule */
             FND_FILE.PUT_LINE ( FND_FILE.LOG,'Implementing Reschedule Batches ');

             reschedule_batch(
                               get_data_rec.process_id,
                               get_data_rec.organization_id,
                               get_data_rec.plan_quantity,
                               get_data_rec.plan_start_date,
                               get_data_rec.plan_end_date,
                               get_data_rec.required_completion_date,
                               get_data_rec.order_priority,
                               get_data_rec.scheduling_method,
                               get_data_rec.batch_id,
                               get_data_rec.header_id,
                               get_data_rec.processed_ind,
                               get_data_rec.rowid
                             );

           FND_FILE.PUT_LINE ( FND_FILE.LOG,'Batch Id - '|| get_data_rec.batch_id);

          /* B5897392 Rajesh Patangya firm Flag */
           IF get_data_rec.firmed_ind = 1 THEN
             UPDATE GME_BATCH_HEADER
             SET firmed_ind = get_data_rec.firmed_ind
             WHERE batch_id = get_data_rec.batch_id ;
             --batch id value passed directly
           END IF;

           /*B5148802 - sowsubra - Activity offset updation*/
           IF l_updt_offsets = 1 THEN
        	gmp_aps_writer.update_activity_offsets (get_data_rec.batch_id);
           END IF;

        ELSIF get_data_rec.action_type = -1 THEN /* Cancel */

             FND_FILE.PUT_LINE ( FND_FILE.LOG,'Implementing Cancel Batches ');

                cancel_batch(
                               get_data_rec.process_id,
                               get_data_rec.organization_id,
                               get_data_rec.plan_start_date,
                               get_data_rec.plan_end_date,
                               get_data_rec.batch_id,
                               get_data_rec.header_id,
                               get_data_rec.processed_ind,
                               get_data_rec.rowid
                             );
        END IF;

        X_count := X_count + 1;
    END LOOP;
    /* } */
    CLOSE Cur_gmp_output_tbl;

    COMMIT;

    /* The following IF condition is to check if the Cursor gave any rows
       for the Imput data passed */
    IF X_count = 0
    THEN
        RAISE NO_ROWS;
    END IF;

    EXCEPTION
    WHEN MANUAL_DOC_TYPE THEN
       errbuf := sqlerrm;
       FND_MESSAGE.SET_NAME('GMP','SY_INVALID_MANUAL_DOC');
       FND_FILE.PUT_LINE(FND_FILE.LOG,'-'||FND_MESSAGE.GET);
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Cannot convert to Batch/FPO, Manual Doc Type '||sqlerrm);
       IF (FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',NULL)) THEN
          NULL;
       END IF;
       retcode := '3';

    WHEN CHECK_DATE THEN
       errbuf := sqlerrm;
       FND_MESSAGE.SET_NAME('GMP','MR_INV_CALENDAR_RANGE');
       FND_FILE.PUT_LINE(FND_FILE.LOG,'-'||FND_MESSAGE.GET);
       IF (FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',NULL)) THEN
         NULL;
       END IF;
       retcode := '3';

    WHEN NO_ROWS  THEN
         errbuf := sqlerrm;
         FND_MESSAGE.SET_NAME('GMA','SY_NO_ROWS_SELECTED');
         FND_FILE.PUT_LINE(FND_FILE.LOG,'-'||FND_MESSAGE.GET);
         --IF (FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',NULL)) THEN
	 /*Bug:6408133 GMPRELAP COMPLETES WITH WARNING WHEN THERE ARE NO ORDERS TO BE CONVERTED */

	 IF (FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL',NULL)) THEN

            NULL;
         END IF;
         retcode := '3';
    WHEN OTHERS THEN
         errbuf := sqlerrm;
         FND_FILE.PUT_LINE(FND_FILE.LOG,' Error in Implementing APS Plng Suggestions '||sqlerrm);
         retcode := '2';

END Implement_Aps_Plng_Sugg;

/*
REM+==========================================================================+
REM|                                                                          |
REM|PROCEDURE NAME      create_new_batch                                      |
REM|                                                                          |
REM|DESCRIPTION         Each record is processed to create batch or Reschedule|
REM|                    or Cancel a Batch                                     |
REM|                    The following Return Status can occur  while creating |
REM|                    a Batch                                               |
REM|                    S - Success                                           |
REM|                    E - Error                                             |
REM|                    U - Unexpected Error                                  |
REM|                    V - Inventory shortage exists                         |
REM|                                                                          |
REM| MODIFICATION HISTORY                                                     |
REM|   09/30/03     Sridhar Gidugu  -----  created                            |
REM| Rajesh Patangya 	22-AUG-2005   Changes for Release 12.0                |
REM+=========================================================================*/
PROCEDURE create_new_batch(
                   p_process_id          IN NUMBER,
                   p_inventory_item_id   IN NUMBER,   -- For R12.0
                   p_item_no             IN VARCHAR2, -- For R12.0
                   p_primary_uom_code    IN VARCHAR2, -- For R12.0
                   p_organization_id     IN NUMBER,   -- For R12.0
                   p_batch_id            IN NUMBER,
                   p_effectivity_id      IN NUMBER,
                   p_plan_quantity       IN NUMBER,
                   p_start_date          IN DATE,
                   p_end_date            IN DATE,
                   p_required_completion IN DATE,     -- For R12.0
                   p_order_priority      IN NUMBER,   -- For R12.0
                   p_firmed_ind          IN NUMBER,   -- For R12.0
                   p_header_id           IN NUMBER,
                   p_scheduling_method   IN NUMBER,
                   p_batch_no            IN VARCHAR2,
                   p_batch_type          IN NUMBER,
                   p_rowid               IN ROWID
                   ) IS

    --  Contiguity Override changes
    Cursor calendar_associated(l_organization_id NUMBER) IS
      SELECT calendar_code,organization_code FROM mtl_parameters
      WHERE organization_id = l_organization_id ;

    l_gme_batch_header     GME_BATCH_HEADER%ROWTYPE;
    x_gme_batch_header2    GME_BATCH_HEADER%ROWTYPE;
    x_message_count        NUMBER;
    x_message_list         VARCHAR2(2000);
    x_return_status        VARCHAR2(1);
    CREATE_BATCH_FAILED    EXCEPTION;
    ERROR_MESSAGE          EXCEPTION;
    GMP_CHECK_EFFECTIVITY  EXCEPTION;
    GMP_SHOP_NON_WKG_START EXCEPTION;
    GMP_SHOP_NON_WKG_END   EXCEPTION;
    l_action_code          VARCHAR2(50);
    x_use_workday_cal      VARCHAR2(1) ;
    l_contiguity_override  NUMBER ;
    x_contiguity_override  VARCHAR2(1) ;
    l_org_code             VARCHAR2(10) ;
    l_return_status        VARCHAR2(1) ;
    x_exception_tbl        gme_common_pvt.exceptions_tab;
    l_inv_shortage         BOOLEAN;
    l_item_no              VARCHAR2(240);
    l_cal_code             VARCHAR2(10);
    l_is_associated        NUMBER ;
    v_batch_no             VARCHAR2(32);
    v_start_date           DATE;
    v_end_date             DATE;
    v_due_date             DATE;
    v_batch_id             NUMBER(10);
    l_recipe_id            NUMBER;
    l_return               NUMBER;
    v_orig_plan_cmplt_date DATE ;
    x_data                 VARCHAR2(250) ;
    l_dummy_cnt            NUMBER ;
    l_profile              VARCHAR2(1) ;
    l_end_date             DATE; -- Bug:6265867 Kbanddyo
    u_user_id              NUMBER;
    l_sum_all_prod_lines   VARCHAR2(1) ;
    l_fixed_process_loss_ind   VARCHAR2(1) ;  /* B8290677 */

  -- Bug: 8625112 Vpedarla
   CURSOR Cur_get_item_uoms IS
    SELECT msi.PRIMARY_UOM_CODE , gmd.detail_uom from
   (select PRIMARY_UOM_CODE, inventory_item_id , organization_id from mtl_system_items) msi,
   (select inventory_item_id , recipe_validity_rule_id , DETAIL_UOM from gmd_recipe_validity_rules ) gmd
   where msi.organization_id = p_organization_id
   AND msi.inventory_item_id = p_inventory_item_id
   AND  msi.inventory_item_id = gmd.inventory_item_id
   AND gmd.recipe_validity_rule_id = p_effectivity_id  ;

  -- Bug: 8625112 Vpedarla
   l_rec_uom        VARCHAR2(10);
   l_prim_uom       VARCHAR2(10);
   l_new_plan_qty   NUMBER;

BEGIN
    x_use_workday_cal     := 'T';
    x_contiguity_override := 'F';
    l_is_associated       := 0;
    l_contiguity_override := 1;
    l_item_no             := p_item_no ;
    l_profile             := 'N';
   /* B6994378, Rajesh Patangya GME does need intialization parameters */
    gme_common_pvt.g_setup_done := FALSE ;


  -- Bug: 8625112 Vpedarla
   l_rec_uom    := NULL;
   l_prim_uom   := NULL;
   l_new_plan_qty  := 0;


   /* B6994378, Rajesh Patangya GME does need intialization parameters */
    u_user_id             := FND_PROFILE.VALUE('user_id') ;
    fnd_profile.initialize (u_user_id);
-- Line below required if formula security is used. It sets the security context.
    fnd_global.apps_initialize (user_id           => u_user_id,
                               resp_id           => NULL,
                               resp_appl_id      => NULL
                              );
     fnd_profile.put ('AFLOG_LEVEL', '1');
     /* B7577478 Rajesh Patangya 18-NOV-2008
       'S' -- if multiple product lines for the same items are present in formula details, APS
              suggest the suggestion based on the product line quantity  and hence  GME should
              be using the quantity passed as total quantity for the product (which is the
              minimum line number of the product in formula details) and not
              adding quantities for all the coproducts.
       'A' -- if only one line for the product is present, altough formula have multiple co-products
              then GME should be using the quantity passed as total quantity to create the batch
     */
     l_sum_all_prod_lines := 'S' ;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'New btach Processing for Group ID = ' || p_process_id || ' Header ID = ' || p_header_id);

       OPEN calendar_associated(p_organization_id);
       FETCH calendar_associated INTO l_cal_code,l_org_code;
       CLOSE calendar_associated;

       IF l_cal_code IS NOT NULL THEN
          l_is_associated := 1;
       END IF;

       IF l_is_associated = 1 THEN
          l_profile := NVL(FND_PROFILE.VALUE('GMP_USE_MANUFACTURING_CAL'),'N');
       ELSE
          l_profile := 'N';
       END IF;

    -- For R12.0
    IF p_required_completion IS NOT NULL THEN
      l_gme_batch_header.due_date := p_required_completion;
    ELSE
      l_gme_batch_header.due_date := p_end_date;
    END IF;

      l_gme_batch_header.organization_id := p_organization_id ;
      l_gme_batch_header.plan_cmplt_date := p_end_date;
      l_gme_batch_header.batch_type := p_batch_type;
      l_gme_batch_header.laboratory_ind := 0 ;
      l_gme_batch_header.update_inventory_ind := 0 ;
      l_gme_batch_header.gl_posted_ind := 0;
      l_action_code := 'PRODUCT';
      l_gme_batch_header.text_code := NULL;
      l_gme_batch_header.order_priority := p_order_priority ;
      v_orig_plan_cmplt_date := p_end_date ;
      l_gme_batch_header.firmed_ind := p_firmed_ind ;


      /* B8290677 consider Fixed Process_loss */
      -- Autorelease consider it only when user will set the parameter to 'all batches'
           SELECT fixed_process_loss_ind
            INTO l_fixed_process_loss_ind
           FROM  gme_parameters
           WHERE organization_id = p_organization_id ;

      IF l_fixed_process_loss_ind = 1 THEN
        l_gme_batch_header.fixed_process_loss_applied := 'N' ;
      ELSIF l_fixed_process_loss_ind = 2 THEN
        l_gme_batch_header.fixed_process_loss_applied := 'Y' ;
      ELSE
        l_gme_batch_header.fixed_process_loss_applied := NULL ;
      END IF;

      /* Assuming the fmeff_id is coming from APS Engine */
      l_recipe_id := 0 ;
      l_return    := -1;

     FND_FILE.PUT_LINE(FND_FILE.LOG,'Before validate  Effectivity ');
     FND_FILE.PUT_LINE(FND_FILE.LOG,'p_organization_id  '||p_organization_id);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'p_inventory_item_id  '||p_inventory_item_id);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'p_effectivity_id  '||p_effectivity_id);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'p_plan_quantity  '||p_plan_quantity);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Batch type '||p_batch_type);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'p_start_date  '||p_start_date);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'p_end_date  '||p_end_date);

  -- Bug: 8625112 Vpedarla
    IF p_effectivity_id is not null then
     OPEN Cur_get_item_uoms;
     FETCH Cur_get_item_uoms INTO l_prim_uom,l_rec_uom ;
     CLOSE Cur_get_item_uoms;


     IF (l_prim_uom <> l_rec_uom ) THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG,' Item UOM '||l_prim_uom||' different from validity rule uom '||l_rec_uom);
       l_new_plan_qty  := inv_convert.inv_um_convert(
                                        p_inventory_item_id ,
                                        NULL,
                                        p_organization_id,
                                        5,
                                        p_plan_quantity,
                                        l_prim_uom,
                                        l_rec_uom,
                                        NULL,
                                        NULL);
        FND_FILE.PUT_LINE(FND_FILE.LOG,'New plan quantity in validity rule uom -'||l_new_plan_qty );
     ELSE
       FND_FILE.PUT_LINE(FND_FILE.LOG,' No effectivity id ');
       l_new_plan_qty := p_plan_quantity ;
     END IF;
    END IF;

        validate_effectivities(p_organization_id,
                               p_inventory_item_id,
                               p_effectivity_id, l_new_plan_qty, -- bug: 8625112
                               p_batch_type, /* B5259453 */
                               p_start_date,p_end_date,
                               l_recipe_id,l_return
                               );

     FND_FILE.PUT_LINE(FND_FILE.LOG,'After validate  Effectivity ');
     FND_FILE.PUT_LINE(FND_FILE.LOG,'l_recipe_id  '||l_recipe_id);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'l_return  '||l_return);

      IF l_return <> 0 THEN
          l_gme_batch_header.RECIPE_VALIDITY_RULE_ID :=  p_effectivity_id;
      ELSE
          RAISE GMP_CHECK_EFFECTIVITY;
      END IF;

    -- Contiguity Override changes, always there for batch
            GMD_RECIPE_FETCH_PUB.FETCH_CONTIGUOUS_IND(
               p_recipe_id      => l_recipe_id
              ,p_orgn_id        => p_organization_id
              ,p_recipe_validity_rule_id =>p_effectivity_id
              ,x_contiguous_ind => l_contiguity_override
              ,x_return_status  => l_return_status);

     IF l_contiguity_override = 0 THEN
       x_contiguity_override := 'T' ;
     ELSE
       x_contiguity_override := 'F' ;
     END IF;

      FND_FILE.PUT_LINE(FND_FILE.LOG,'Calendar Code '||l_cal_code);
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Start Date '||to_char(p_start_date,'MM/DD/YYYY HH24:MI:SS'));
/*
      IF p_start_date IS NOT NULL THEN
        IF l_profile = 'Y' THEN
           IF NOT gmp_calendar_api.is_working_daytime (
                         1,
                         TRUE,
                         l_cal_code,
                         p_start_date,
                         0,
                         x_return_status ) THEN
                  RAISE GMP_SHOP_NON_WKG_START ;
           END IF;
        END IF;

      END IF;
*/

      FND_FILE.PUT_LINE(FND_FILE.LOG,'End Date '||to_char(p_end_date,'MM/DD/YYYY HH24:MI:SS'));
      IF p_end_date IS NOT NULL THEN
        IF l_profile = 'Y' THEN
           IF NOT gmp_calendar_api.is_working_daytime (
                         1,
                         TRUE,
                         l_cal_code,
                         p_end_date,
                         1,  /* B3615325 , this should be 1 instead of 0 */
                         x_return_status ) THEN

 --Bug:6265867(kbanddyo)START B5378109 of Teva, For Unconstrained plan suggestions, if Suggested due date
            --  is not a working Daytime, find the nearest working time
                IF (nvl(p_scheduling_method,0) <> 1) THEN
                 l_end_date := NULL ;
                x_return_status := 'E' ;
                gmp_calendar_api.get_nearest_workdaytime(
                               1,
                               TRUE ,
                               l_cal_code,
                               p_end_date,
                               0,
                               l_end_date,
                               x_return_status
                               ) ;

                   IF x_return_status = 'S' THEN
                  l_gme_batch_header.plan_cmplt_date := l_end_date;
                   FND_FILE.PUT_LINE ( FND_FILE.LOG,'Nearest End Date = '||to_char(l_end_date,'MM/DD/YYYY HH24:MI:SS'));
                 ELSE
                    RAISE GMP_SHOP_NON_WKG_END ;
                 END IF;
              END IF;
           --   ELSE
               --   RAISE GMP_SHOP_NON_WKG_END ;  bug:6788788 removed the exception in the else clause
		  -- Bug:6265867 END Teva changes Ends
           END IF;
        END IF;
      END IF;
    -- End of Contiguity Override changes

    select DECODE(l_profile,'N','F','Y','T') into x_use_workday_cal from dual;

   --  Call the GME API to create a Batch
     gme_api_pub.create_batch(
        p_api_version          =>  2.0
       ,p_validation_level     =>  100
       ,p_init_msg_list        =>  'T'
       ,p_commit               =>  'T'
       ,x_message_count        => x_message_count
       ,x_message_list         => x_message_list
       ,x_return_status        => x_return_status
       ,p_org_code             => l_org_code
       ,p_batch_header_rec     => l_gme_batch_header
       ,x_batch_header_rec     => x_gme_batch_header2
       ,p_batch_size           => p_plan_quantity
       ,p_batch_size_uom       => p_primary_uom_code -- 3 character UOM_code
       ,p_creation_mode        => l_action_code
       ,p_ignore_qty_below_cap => 'T'
       ,p_use_workday_cal      => x_use_workday_cal
       ,p_contiguity_override  => x_contiguity_override
       ,p_use_least_cost_validity_rule => 'F'
       ,p_sum_all_prod_lines   => l_sum_all_prod_lines  /*  B7530107 */
       ,x_exception_material_tbl =>  x_exception_tbl) ;


     IF (x_return_status = 'C') THEN
        x_contiguity_override := 'T' ;
        x_message_list        := NULL;
        x_return_status       := NULL ;

        FND_MESSAGE.SET_NAME('GME','GME_SHOP_NOT_ONE_CONT');
        FND_FILE.PUT_LINE(FND_FILE.LOG,'-'||FND_MESSAGE.GET);

     gme_api_pub.create_batch(
        p_api_version          =>  2.0
       ,p_validation_level     =>  100
       ,p_init_msg_list        =>  'T'
       ,p_commit               =>  'T'
       ,x_message_count        => x_message_count
       ,x_message_list         => x_message_list
       ,x_return_status        => x_return_status
       ,p_org_code             => l_org_code
       ,p_batch_header_rec     => l_gme_batch_header
       ,x_batch_header_rec     => x_gme_batch_header2
       ,p_batch_size           =>  p_plan_quantity
       ,p_batch_size_uom       => p_primary_uom_code -- 3 char UOM
       ,p_creation_mode        => l_action_code
       ,p_ignore_qty_below_cap =>  'T'
       ,p_use_workday_cal      => x_use_workday_cal
       ,p_contiguity_override  => x_contiguity_override
       ,p_use_least_cost_validity_rule => 'F'
       ,p_sum_all_prod_lines   => l_sum_all_prod_lines  /*  B7530107 */
       ,x_exception_material_tbl =>  x_exception_tbl) ;

     END IF;

     IF (x_return_Status NOT IN ('E','U')) THEN

      IF p_batch_type = 10 THEN
       FND_MESSAGE.SET_NAME('GME','GME_FPO_CREATED');
       FND_MESSAGE.SET_TOKEN('FPO_NO',x_gme_batch_header2.batch_no);
      ELSE
       FND_MESSAGE.SET_NAME('GME','GME_BATCH_CREATED');
       FND_MESSAGE.SET_TOKEN('BATCH_NO',x_gme_batch_header2.batch_no);
      END IF;
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Item Number '||l_item_no||' - '||FND_MESSAGE.GET);
       v_batch_no   := x_gme_batch_header2.batch_no;
       v_start_date := x_GME_BATCH_HEADER2.plan_start_date;
       v_end_date   := x_GME_BATCH_HEADER2.PLAN_CMPLT_DATE;
       v_due_date   := x_GME_BATCH_HEADER2.due_date;
       v_batch_id   := x_gme_batch_header2.batch_id;
     END IF;
     IF (x_return_status in ('E','U')) THEN
     -- Errors
           RAISE ERROR_MESSAGE;
     ELSIF (x_return_status = 'S') THEN
        -- Production Batch was sucessfully inserted.
       v_batch_no   := x_gme_batch_header2.batch_no;
       v_start_date := x_GME_BATCH_HEADER2.plan_start_date;
       v_end_date   := x_GME_BATCH_HEADER2.PLAN_CMPLT_DATE;
       v_due_date   := x_GME_BATCH_HEADER2.due_date;
         IF p_batch_type = 10 THEN
          FND_MESSAGE.SET_NAME('GME','GME_FPO_CREATED');

          FND_MESSAGE.SET_TOKEN('FPO_NO',x_gme_batch_header2.batch_no);
         ELSE

          FND_MESSAGE.SET_NAME('GME','GME_BATCH_CREATED');
          FND_MESSAGE.SET_TOKEN('BATCH_NO',x_gme_batch_header2.batch_no);
         END IF;
       FND_FILE.PUT_LINE(FND_FILE.LOG,'-'||FND_MESSAGE.GET);

     ELSIF (x_return_status = 'V') THEN
      -- Inventory shortage, Production Batch was sucessfully inserte.

        v_batch_no := x_gme_batch_header2.batch_no;
        FND_MESSAGE.SET_NAME('GME','GME_INV_SHORTAGES');
        FND_FILE.PUT_LINE(FND_FILE.LOG,'-'||FND_MESSAGE.GET||'-'||v_batch_no);
     END IF;

       UPDATE gmp_aps_output_tbl
          SET processed_ind = 0 ,
              batch_id = v_batch_id
        WHERE rowid = p_rowid
          AND processed_ind > 0
          AND header_id = p_header_id;

        IF (nvl(p_scheduling_method,0) = 1) THEN

           UPDATE gmp_aps_output_dtl
              SET wip_entity_id = v_batch_id
            WHERE parent_header_id = p_header_id
              AND group_id  = p_process_id ;

           scheduling_details_create(v_batch_id    , /* B3590089 */
                                     p_process_id  ,
                                     p_header_id   ,
                                     p_start_date  ,
                                     v_orig_plan_cmplt_date ,
                                     p_required_completion ,   -- For R12.0
                                     p_order_priority      ,   -- For R12.0
                                     p_organization_id     ,   -- For R12.0
                                     p_effectivity_id
                                    );
        END IF ;

EXCEPTION
   WHEN GMP_CHECK_EFFECTIVITY THEN
     -- B4610275 changed the message to include Group ID
        FND_FILE.PUT_LINE ( FND_FILE.LOG,'GMP Item Effectivity for Group Id = '
|| p_process_id || ' is Invalid for Item_no(id) = '||l_item_no ||
 '(' ||p_inventory_item_id ||')' );
        FND_MESSAGE.SET_NAME('GME','GME_INVALID_VALIDITY_RULE_PROD');
        FND_FILE.PUT_LINE(FND_FILE.LOG,'-'||FND_MESSAGE.GET);


 --Bug#6414610 KBANDDYO  uncommented following code
        IF (FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',NULL)) THEN
            NULL;
        END IF;

   WHEN GMP_SHOP_NON_WKG_START THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Message from GMP ');
        FND_MESSAGE.SET_NAME('GME','GME_SHOP_NON_WKG');
        FND_MESSAGE.SET_TOKEN('PDATE',to_char(p_start_date,'MM/DD/YYYY HH24:MI:SS'));
        FND_FILE.PUT_LINE(FND_FILE.LOG,'-'||FND_MESSAGE.GET);

   WHEN GMP_SHOP_NON_WKG_END THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Message from GMP 2 ');
        FND_MESSAGE.SET_NAME('GME','GME_SHOP_NON_WKG');
        FND_MESSAGE.SET_TOKEN('PDATE',to_char(p_end_date,'MM/DD/YYYY HH24:MI:SS'));
        FND_FILE.PUT_LINE(FND_FILE.LOG,'-'||FND_MESSAGE.GET);

   WHEN ERROR_MESSAGE THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,' Error - Status  is E or U '||sqlerrm);
        FOR i in 1..fnd_msg_pub.count_msg LOOP
           FND_MSG_PUB.Get(
           p_msg_index => i,
           p_data => x_data,
           p_encoded => FND_API.G_FALSE,
           p_msg_index_out => l_dummy_cnt);

           FND_FILE.PUT_LINE(FND_FILE.LOG,':'|| i || ':' || x_data );
        END LOOP ;

        IF (FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',NULL)) THEN
            NULL;
        END IF;
   WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,' Error in Create New Batch '||sqlerrm);

END create_new_batch;

/*
REM+========================================================================+
REM|                                                                        |
REM| PROCEDURE_NAME         validate_effectivities                          |
REM|                                                                        |
REM| DESCRIPTION            Validates the existence of Effectivity Id       |
REM|                                                                        |
REM| MODIFICATION HISTORY                                                   |
REM|   09/09/03     Sridhar Gidugu  -----  created                          |
REM| Rajesh Patangya 	22-AUG-2005   Changes for Release 12.0              |
REM+=======================================================================*/
PROCEDURE validate_effectivities(
                   p_organization_id   IN NUMBER,
                   p_inventory_item_id IN NUMBER,
                   p_effectivity_id    IN NUMBER,
                   p_plan_quantity     IN NUMBER,
                   p_batch_type        IN NUMBER, /* B5259453 */
                   p_start_date        IN DATE,
                   p_end_date          IN DATE,
                   p_recipe_id         OUT NOCOPY NUMBER, -- For R12.0
                   p_return            OUT NOCOPY NUMBER) IS -- For R12.0

  -- B5259453, FPO can use planning and production validity rules
   CURSOR Cur_get_eff_id IS
   SELECT gr.recipe_id, count(1)
    FROM gmd_recipes_b gr,
         gmd_recipe_validity_rules grv,
         gmd_status_b gs
   WHERE grv.validity_rule_status in ('700','900')
     AND gr.recipe_id = grv.recipe_id
     AND grv.validity_rule_status = gs.status_code
     AND gs.status_type in ('700','900')
     AND grv.delete_mark = 0
     AND (( p_batch_type = 0
         AND grv.recipe_use = 0 )            -- Production Use only
        OR ( p_batch_type = 10
         AND grv.recipe_use IN (0,1) ))      -- Planning/Production Use only
     AND grv.inventory_item_id = p_inventory_item_id
     AND nvl(grv.organization_id,p_organization_id) = p_organization_id
     AND grv.recipe_validity_rule_id = p_effectivity_id
     AND grv.min_qty <= nvl(p_plan_quantity, grv.min_qty )
     AND grv.max_qty >= nvl( p_plan_quantity , grv.max_qty )
     AND trunc(grv.start_date) <= trunc(p_start_date) -- Falls within a data range
 --     AND NVL(grv.end_date,(sysdate+8000)) >= trunc(p_end_date)
 --     Bug: 8467054 Vpedarla commented the above where condition.
   GROUP BY gr.recipe_id;

   l_count      NUMBER ;
   l_recipe_id  NUMBER ;

BEGIN
   l_count      := 0 ;
   l_recipe_id  := 0 ;

     OPEN Cur_get_eff_id;
     FETCH Cur_get_eff_id INTO l_recipe_id,l_count ;
     CLOSE Cur_get_eff_id;

     p_recipe_id := l_recipe_id ;
     p_return    := l_count ;


EXCEPTION
   WHEN OTHERS THEN
     FND_FILE.PUT_LINE(FND_FILE.LOG,' Error Validate Effectivities '||sqlerrm);
END validate_effectivities;

/*
REM+========================================================================+
REM| PROCEDURE NAME        SCHEDULING_DETAILS_CREATE                        |
REM|                                                                        |
REM| DESCRIPTION           Process the APS generated scheduling details to  |
REM|                       update GME                                       |
REM|                                                                        |
REM| MODIFICATION HISTORY                                                   |
REM|   10/01/03     Sridhar Gidugu  -----  created                          |
REM| Rajesh Patangya 	22-AUG-2005   Changes for Release 12.0              |
REM+=======================================================================*/
PROCEDURE  scheduling_details_create(
                   p_batch_id             IN  NUMBER,
                   p_process_id           IN  NUMBER,
                   p_header_id            IN  NUMBER,
                   p_plan_start_date      IN  DATE,
                   p_plan_end_date        IN  DATE,
                   p_required_completion  IN  DATE,     -- For R12.0
                   p_order_priority       IN  NUMBER,   -- For R12.0
                   p_organization_id      IN  NUMBER,   -- For R12.0
                   p_eff_id               IN  NUMBER) IS

   err_msg       VARCHAR2(4000) ;
   l_msg_data    VARCHAR2(4000) ;
   ret_code      NUMBER ;

BEGIN
   err_msg       := '' ;
   ret_code      := -1;

     FND_FILE.PUT_LINE(FND_FILE.LOG,'Calling GMP APS Writer program ');
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Batch Id '||p_batch_id);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'process Id '||p_process_id);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Header Id '||p_header_id);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Start Date '||p_plan_start_date);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'End Date '||p_plan_end_date);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Req completion = '||p_required_completion);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Priority = '||p_order_priority);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Orgn Id = '||p_organization_id);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Eff Id = '||p_eff_id);

     GMP_APS_WRITER.main_process(p_batch_id,
                                 p_process_id,
                                 p_header_id,
                                 p_plan_start_date,
                                 p_plan_end_date,
                                 p_required_completion,
                                 p_order_priority,
                                 p_organization_id,
	  		         p_eff_id,
                                 1,            -- Action_type
                                 sysdate,      -- Creation_date
                                 FND_PROFILE.VALUE('user_id'),
                                 FND_PROFILE.VALUE('user_id'),
				 err_msg,
				 ret_code) ;

     -- We shall add a check for return code also if negative means an error
     -- Then show a message

     IF ret_code <> 0 THEN
         l_msg_data := FND_MSG_PUB.GET(
                         p_msg_index =>FND_MSG_PUB.Count_msg,
                         p_encoded   =>  'F') ;

       IF  l_msg_data is NOT NULL THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG,'Return from the main process is '||l_msg_data);
       END IF ;
     END IF ;

EXCEPTION
  WHEN OTHERS THEN
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in process scheduling details create '||p_batch_id||'-'||sqlerrm);
END scheduling_details_create ;

/*
REM+=========================================================================+
REM|                                                                         |
REM| PROCEDURE NAME        reschedule_batch                                  |
REM|                                                                         |
REM| DESCRIPTION           Each record is processed to Reschedule a Batch    |
REM|                                                                         |
REM| MODIFICATION HISTORY                                                    |
REM|   10/01/03     Sridhar Gidugu  -----  created                           |
REM| Rajesh Patangya 	22-AUG-2005   Changes for Release 12.0               |
REM+========================================================================*/
PROCEDURE reschedule_batch(
                   p_process_id          IN NUMBER,
                   p_organization_id     IN NUMBER,  -- For R12.0
                   p_plan_quantity       IN NUMBER,
                   p_start_date          IN DATE,
                   p_end_date            IN DATE,
                   p_required_completion IN DATE,   -- For R12.0
                   p_order_priority      IN NUMBER, -- For R12.0
                   p_scheduling_method   IN NUMBER,
                   p_batch_id            IN NUMBER,
                   p_header_id           IN NUMBER,
                   p_processed_ind       IN NUMBER,
                   p_rowid               IN ROWID
                   ) IS

    CURSOR Cur_get_batch_data IS
    SELECT a.batch_no, a.batch_type, a.batch_status,
           a.plan_start_date, a.plan_cmplt_date,
           a.recipe_validity_rule_id, b.recipe_id
     FROM  gme_batch_header a,
           gmd_recipe_validity_rules b
    WHERE a.batch_id = p_batch_id
      AND a.organization_id  = p_organization_id
      AND a.recipe_validity_rule_id = b.recipe_validity_rule_id
      AND b.delete_mark = 0
      AND b.recipe_use IN (0,1) ;

    -- Contiguity Override changes
    Cursor calendar_associated(l_organization_id NUMBER) IS
      SELECT calendar_code, organization_code FROM mtl_parameters
      WHERE organization_id = l_organization_id ;

    x_message_count             NUMBER;
    x_message_list              VARCHAR2(2000);
    x_return_status             VARCHAR2(2000);
    x_batch_header              gme_batch_header%ROWTYPE;
    x_use_workday_cal           VARCHAR2(1) ;
    l_contiguity_override       NUMBER ;
    x_contiguity_override       VARCHAR2(1) ;
    l_return_status             VARCHAR2(2000);
    l_gme_batch_header          GME_BATCH_HEADER%ROWTYPE;
    l_gme_batch_header2         GME_BATCH_HEADER%ROWTYPE;
    t_ret_code                  NUMBER ;
    x_decision                  NUMBER ;
    c_batch_id                  NUMBER(10);
    l_cal_code                  VARCHAR2(10);
    l_is_associated             NUMBER ;
    v_scheduling_method         NUMBER ;
    l_org_code                  VARCHAR2(10);
    l_batch_no                  VARCHAR2(32);
    l_batch_type                NUMBER(5);
    l_batch_status              NUMBER(5);
    l_old_pst                   DATE;
    l_plan_start_date           DATE;
    l_plan_end_date             DATE;
    l_recipe_validity_rule_id   NUMBER;
    l_recipe_id                 NUMBER;
    expct_cmplt_date            DATE;
    x_data                      VARCHAR2(250) ;
    l_dummy_cnt                 NUMBER ;
    ERROR_MESSAGE               EXCEPTION;
    l_profile              VARCHAR2(1) ;
    GMP_SHOP_NON_WKG_END   EXCEPTION;  -- Bug:6265867 Kbanddyo
    l_end_date             DATE; -- Bug:6265867 Kbanddyo

    l_update_due_date         NUMBER;  -- Vpedarla Bug: 8348883


  -- Bug: 8663941 Vpedarla
   CURSOR Cur_get_item_uoms(eff_id NUMBER) IS
    SELECT msi.CONCATENATED_SEGMENTS , msi.inventory_item_id from
   (select PRIMARY_UOM_CODE, inventory_item_id , organization_id , CONCATENATED_SEGMENTS from mtl_system_items_kfv) msi,
   (select inventory_item_id , recipe_validity_rule_id , DETAIL_UOM from gmd_recipe_validity_rules ) gmd
   where msi.organization_id = p_organization_id
   AND  msi.inventory_item_id = gmd.inventory_item_id
   AND gmd.recipe_validity_rule_id = eff_id  ;

  -- Bug: 8663941 Vpedarla
   l_new_plan_qty   NUMBER;
   l_val_recipe_id      NUMBER;
   l_val_return         NUMBER;
   GMP_CHECK_EFFECTIVITY  EXCEPTION;
   l_item_no        VARCHAR2(250);
   l_item_id        NUMBER;

BEGIN
    x_use_workday_cal     := 'T';
    x_contiguity_override := 'F';
    l_contiguity_override := 1;
    l_is_associated       := 0;
    x_decision            := NULL;
    t_ret_code            := -1 ;
    l_profile             := 'N';
    l_item_no             := ' ';
    l_item_id             := 0;

-- Bug: 8262503 Vpedarla
    v_scheduling_method   := p_scheduling_method;

    -- Vpedarla Bug: 8348883
    l_update_due_date        := nvl(FND_PROFILE.VALUE('GMP:UPDATE_DUE_DATE_FOR_BATCHES_RESCHEDULE_BY_ASCP'),0) ;

     /* { */
       OPEN Cur_get_batch_data;
       FETCH Cur_get_batch_data INTO
                  l_batch_no, l_batch_type, l_batch_status,
                  l_old_pst, expct_cmplt_date,
                  l_recipe_validity_rule_id, l_recipe_id ;
       CLOSE Cur_get_batch_data;

       FND_FILE.PUT_LINE(FND_FILE.LOG,'Now Rescheduling Batch = ' || l_batch_no);

      /* Calculate plan_start_date, as APS is not sending in
         wip_job_schedule_interface  */
       l_plan_start_Date := p_start_date ;
       l_plan_end_date   := p_end_date ;

      IF l_plan_start_date is NULL then
         l_plan_start_Date := l_old_pst + (l_plan_end_date - expct_cmplt_date) ;
      END IF;

       OPEN calendar_associated(p_organization_id);
       FETCH calendar_associated INTO l_cal_code,l_org_code;
       CLOSE calendar_associated;

       IF l_cal_code IS NOT NULL THEN
          l_is_associated := 1;
       END IF;

       IF l_is_associated = 1 THEN
          l_profile := NVL(FND_PROFILE.VALUE('GMP_USE_MANUFACTURING_CAL'),'N');
       ELSE
          l_profile := 'N';
       END IF;

     IF l_batch_status in (1,2) THEN
        IF ((l_batch_status = 2) AND (l_old_pst > l_plan_start_date))
        THEN
          -- Do not reschedule via APS or GME way
            FND_MESSAGE.SET_NAME('GMP','GMP_WIP_RESCHEDULE_IN_NA');
            FND_FILE.PUT_LINE(FND_FILE.LOG,'-'||FND_MESSAGE.GET);
            v_scheduling_method := -1 ;
        END IF;

          -- Bug: 8663941 Vpedarla
            IF l_recipe_validity_rule_id is not null then
             OPEN Cur_get_item_uoms(l_recipe_validity_rule_id);
             FETCH Cur_get_item_uoms INTO l_item_no, l_item_id ;
             CLOSE Cur_get_item_uoms;

             FND_FILE.PUT_LINE(FND_FILE.LOG,'Before validate  Effectivity ');
             FND_FILE.PUT_LINE(FND_FILE.LOG,'p_organization_id  '||p_organization_id);
             FND_FILE.PUT_LINE(FND_FILE.LOG,'p_effectivity_id  '||l_recipe_validity_rule_id);
             FND_FILE.PUT_LINE(FND_FILE.LOG,'p_inventory_item_id  '||l_item_id);
             FND_FILE.PUT_LINE(FND_FILE.LOG,'p_start_date  '||p_start_date);
             FND_FILE.PUT_LINE(FND_FILE.LOG,'p_end_date  '||p_end_date);

                validate_effectivities(p_organization_id,
                                       l_item_id,
                                       l_recipe_validity_rule_id, to_number(NULL) , -- bug: 8625112
                                       l_batch_type, /* B5259453 */
                                       p_start_date,p_end_date,
                                       l_val_recipe_id,l_val_return
                                       );

             FND_FILE.PUT_LINE(FND_FILE.LOG,'After validate  Effectivity ');
             FND_FILE.PUT_LINE(FND_FILE.LOG,'l_val_recipe_id  '||l_val_recipe_id);
             FND_FILE.PUT_LINE(FND_FILE.LOG,'l_val_return  '||l_val_return);

              IF l_val_return <> 0 THEN
                  l_gme_batch_header.RECIPE_VALIDITY_RULE_ID :=  l_recipe_validity_rule_id;
              ELSE
                  RAISE GMP_CHECK_EFFECTIVITY;
              END IF;
            END IF;

        IF nvl(p_scheduling_method,2) = 1 THEN
          IF l_update_due_date = 0 THEN  -- Vpedarla bug: 8348883
                  scheduling_details_resc(
                                     p_batch_id,
                                     p_process_id,
                                     p_header_id,
                                     p_start_date,
                                     p_end_date,
                                     NULL ,   -- For R12.0
                                     p_order_priority      ,   -- For R12.0
                                     p_organization_id     ,   -- For R12.0
                                     l_recipe_validity_rule_id,
                                     t_ret_code
                                     );
          ELSE
                  scheduling_details_resc(
                                     p_batch_id,
                                     p_process_id,
                                     p_header_id,
                                     p_start_date,
                                     p_end_date,
                                     p_required_completion ,   -- For R12.0
                                     p_order_priority      ,   -- For R12.0
                                     p_organization_id     ,   -- For R12.0
                                     l_recipe_validity_rule_id,
                                     t_ret_code
                                     );
          END IF;

            IF t_ret_code < 0 THEN
                FND_MESSAGE.SET_NAME('GMP','GMP_RESCHEDULE_CONTINUE');
--                x_decision := FND_MESSAGE.QUESTION('YES','NO',NULL);
                /* Purposely making the Reschedule to Contine   */
                x_decision := 1;
                IF x_decision = 1 THEN
                   v_scheduling_method := 2;
                END IF;
            END IF;    /* End if for ret_code */

         END IF;
        -- The start and end dates will not have correct date stamps
        -- We also have to check with APS team to see if we get correct end date

         IF v_scheduling_method = 2 THEN

         IF (l_batch_type = 0) AND (l_profile = 'Y') THEN
            GMD_RECIPE_FETCH_PUB.FETCH_CONTIGUOUS_IND(
               p_recipe_id      => l_recipe_id
              ,p_orgn_id        => p_organization_id
              ,p_recipe_validity_rule_id => l_recipe_validity_rule_id
              ,x_contiguous_ind => l_contiguity_override
              ,x_return_status  => l_return_status);

            IF l_contiguity_override = 0 THEN
              x_contiguity_override := 'T' ;
            ELSE
              x_contiguity_override := 'F' ;
            END IF;
         END IF;

         -- Bug: 8262503 Vpedarla commented below code.
        /*    IF p_start_date IS NOT NULL THEN
               IF l_profile = 'Y' THEN
                  IF NOT gmp_calendar_api.is_working_daytime (
                         1,
                         TRUE,
                         l_cal_code,
                         p_start_date,
                         0,
                         x_return_status ) THEN
                     FND_MESSAGE.SET_NAME('GME','GME_SHOP_NON_WKG');
                     FND_MESSAGE.SET_TOKEN('PDATE',to_char(p_start_date,'MM/DD/YYYY HH24:MI:SS'));
                     FND_FILE.PUT_LINE(FND_FILE.LOG,'-'||FND_MESSAGE.GET);
                  END IF;
               END IF;
            END IF;  */

            IF p_end_date IS NOT NULL THEN
               IF l_profile = 'Y' THEN
                  IF NOT gmp_calendar_api.is_working_daytime (
                         1,
                         TRUE,
                         l_cal_code,
                         p_end_date,
                         0,
                         x_return_status ) THEN

 -- Bug: 6265867 (kbanddyo)START - B5378109 Teva, For Unconstrained plan suggestions, if Suggested due date
            --  is not a working Daytime, find the nearest working time
              l_end_date := NULL ;
              x_return_status := 'E' ;
              gmp_calendar_api.get_nearest_workdaytime(
                               1,
                               TRUE ,
                               l_cal_code,
                               p_end_date,
                               0,
                               l_end_date,
                               x_return_status
                               ) ;

                     FND_MESSAGE.SET_NAME('GME','GME_SHOP_NON_WKG');
                     FND_MESSAGE.SET_TOKEN('PDATE',to_char(p_end_date,'MM/DD/YYYY HH24:MI:SS'));
                     FND_FILE.PUT_LINE(FND_FILE.LOG,'-'||FND_MESSAGE.GET);

                  IF x_return_status = 'S' THEN
                     l_gme_batch_header.plan_cmplt_date := l_end_date;
                     FND_FILE.PUT_LINE ( FND_FILE.LOG,'Nearest End Date = '||to_char(l_end_date,'MM/DD/YYYY HH24:MI:SS'));
                  ELSE
                     RAISE GMP_SHOP_NON_WKG_END ;
                  END IF;
		  ----Bug: 6265867 Teva changes Ends

                     FND_MESSAGE.SET_NAME('GME','GME_SHOP_NON_WKG');
                     FND_MESSAGE.SET_TOKEN('PDATE',to_char(p_end_date,'MM/DD/YYYY HH24:MI:SS'));
                     FND_FILE.PUT_LINE(FND_FILE.LOG,'-'||FND_MESSAGE.GET);
                  END IF;
               END IF;
           END IF;

      SELECT DECODE(l_profile,'N','F','Y','T') INTO x_use_workday_cal FROM dual;
      -- End of Contiguity Override changes

      -- Batch will be rescheduled via GME mechanism
      l_gme_batch_header.batch_id := p_batch_id ;
      l_gme_batch_header.organization_id := p_organization_id ;
      l_gme_batch_header.RECIPE_VALIDITY_RULE_ID := l_recipe_validity_rule_id;
      -- Bug: 8262503 Vpedarla commented below line.
     -- l_gme_batch_header.plan_start_date := p_start_date;
      l_gme_batch_header.plan_cmplt_date := p_end_date;

      gme_api_pub.reschedule_batch(
       p_api_version          => 2
      ,p_validation_level     => 100
      ,p_init_msg_list        => 'T'
      ,p_commit               => 'T'
      ,p_org_code             => l_org_code
      ,p_use_workday_cal      => x_use_workday_cal
      ,p_contiguity_override  => x_contiguity_override
      ,x_message_count        => x_message_count
      ,x_message_list         => x_message_list
      ,x_return_status        => x_return_status
      ,p_batch_header_rec     => l_gme_batch_header
      ,x_batch_header_rec     => l_gme_batch_header2 );

           IF x_return_status = 'C' THEN

             FND_MESSAGE.SET_NAME('GME','GME_SHOP_NOT_ONE_CONT');
             FND_FILE.PUT_LINE(FND_FILE.LOG,'-'||FND_MESSAGE.GET);

             gme_api_pub.reschedule_batch(
               p_api_version          => 2
              ,p_validation_level     => 100
              ,p_init_msg_list        => 'T'
              ,p_commit               => 'T'
              ,p_org_code             => l_org_code
              ,p_use_workday_cal      => x_use_workday_cal
              ,p_contiguity_override  => 'T'
              ,x_message_count        => x_message_count
              ,x_message_list         => x_message_list
              ,x_return_status        => x_return_status
              ,p_batch_header_rec     => l_gme_batch_header
              ,x_batch_header_rec     => x_batch_header );

          END IF;   /* for return status C */

          IF X_return_status <> 'S' THEN
             RAISE ERROR_MESSAGE;
          ELSE
              FND_MESSAGE.SET_NAME('GME','GME_RESCHEDULE');
              FND_FILE.PUT_LINE(FND_FILE.LOG,'-'||FND_MESSAGE.GET||' Return Success');

            -- Vpedarla Bug: 8348883 start
              IF l_update_due_date = 1 THEN
                 FND_FILE.PUT_LINE ( FND_FILE.LOG,'due date update');
                UPDATE gme_batch_header
                SET due_date = p_required_completion
                WHERE BATCH_ID =  l_gme_batch_header.batch_id;
              END IF;
            -- Vpedarla Bug: 8348883 end

             UPDATE gmp_aps_output_tbl
             SET processed_ind = 0
             WHERE rowid = p_rowid
               AND header_id = p_header_id
               AND processed_ind > 0
               AND batch_id = p_batch_id ;

          END IF; /* End if for GME Return Status */

        END IF ;  /* End of second scheduling method */

     ELSE
          FND_MESSAGE.SET_NAME('GMP','MR_USE_PM_RESP_TO_RESCHEDULE');
          FND_MESSAGE.SET_TOKEN('BATCH_NO',l_batch_no);
          FND_FILE.PUT_LINE(FND_FILE.LOG,'-'||FND_MESSAGE.GET);
     END IF;  /* } */

EXCEPTION
   WHEN GMP_CHECK_EFFECTIVITY THEN
     -- B4610275 changed the message to include Group ID
        FND_FILE.PUT_LINE ( FND_FILE.LOG,'GMP Item Effectivity for Group Id = '
|| p_process_id || ' is Invalid for Item_no(id) = '||l_item_no ||
 '(' ||l_item_id ||')' );
        FND_MESSAGE.SET_NAME('GME','GME_INVALID_VALIDITY_RULE_PROD');
        FND_FILE.PUT_LINE(FND_FILE.LOG,'-'||FND_MESSAGE.GET);


 --Bug#6414610 KBANDDYO  uncommented following code
        IF (FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',NULL)) THEN
            NULL;
        END IF;
   WHEN ERROR_MESSAGE THEN
     FND_FILE.PUT_LINE(FND_FILE.LOG,' Error in Reschedule Batch - Status Not in S  '||p_batch_id||'-'||sqlerrm);

     FOR i in 1..fnd_msg_pub.count_msg LOOP
        FND_MSG_PUB.Get(
          p_msg_index => i,
          p_data => x_data,
          p_encoded => FND_API.G_FALSE,
          p_msg_index_out => l_dummy_cnt);

          FND_FILE.PUT_LINE(FND_FILE.LOG,':'|| i || ':' || x_data );
     END LOOP ;

     IF (FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',NULL)) THEN
       NULL;
     END IF;
   WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,' Error in Reschedule Batch '||sqlerrm);
END reschedule_batch;

/*
REM+=======================================================================+
REM|                                                                       |
REM| PROCEDURE NAME                SCHEDULING_DETAILS_RESC                 |
REM|                                                                       |
REM| DESCRIPTION           Process the APS generated scheduling details to |
REM|                       update GME                                      |
REM|                                                                       |
REM| MODIFICATION HISTORY                                                  |
REM|   10/01/03     Sridhar Gidugu  -----  created                         |
REM| Rajesh Patangya 	22-AUG-2005   Changes for Release 12.0             |
REM+======================================================================*/
PROCEDURE  scheduling_details_resc(
                   p_batch_id             IN  NUMBER,
                   p_process_id           IN  NUMBER,
                   p_header_id            IN  NUMBER,
                   p_plan_start_date      IN  DATE,
                   p_plan_end_date        IN  DATE,
                   p_required_completion  IN  DATE,     -- For R12.0
                   p_order_priority       IN  NUMBER,   -- For R12.0
                   p_organization_id      IN  NUMBER,   -- For R12.0
                   p_eff_id               IN  NUMBER,
                   return_status          OUT NOCOPY NUMBER) IS

   err_msg       VARCHAR2(3000) ;
   l_msg_data    VARCHAR2(3000) ;
   ret_code      NUMBER ;

BEGIN
    ret_code := -1 ;
    err_msg := '';
     gmp_aps_writer.main_process(p_batch_id,
                                 p_process_id,
                                 p_header_id,
                                 p_plan_start_date,
                                 p_plan_end_date,
                                 p_required_completion,   -- Vpedarla Bug: 8348883
                                 p_order_priority,
                                 p_organization_id,
                                 p_eff_id,
                                 3,
                                 sysdate,
                                 FND_PROFILE.VALUE('USER_ID'),
                                 FND_PROFILE.VALUE('USER_ID'),
                                 err_msg,
                                 ret_code) ;
      -- We shall add a check for return code also if negative means an error
      -- Then show a message

      IF ret_code <> 0 THEN

       l_msg_data := FND_MSG_PUB.GET(
                           p_msg_index =>FND_MSG_PUB.Count_msg,
                           p_encoded   =>  'F') ;
       IF  l_msg_data is NOT NULL THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG,'::'||to_char(ret_code) ||'::'||l_msg_data);
       END IF ;

      END IF ;
    return_status := ret_code ;

 EXCEPTION
 WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in process scheduling details Reschedule '||p_batch_id||'-'||sqlerrm);
 END scheduling_details_resc;

/*
REM+========================================================================+
REM|                                                                        |
REM| PROCEDURE NAME        cancel_batch                                     |
REM|                                                                        |
REM| DESCRIPTION           Each record is processed to Cancel the batch     |
REM|                                                                        |
REM| MODIFICATION HISTORY                                                   |
REM|   10/01/03     Sridhar Gidugu  -----  created                          |
REM| Rajesh Patangya 	22-AUG-2005   Changes for Release 12.0              |
REM+=======================================================================*/
PROCEDURE cancel_batch(
                   p_process_id         IN NUMBER,
                   p_organization_id    IN NUMBER,   -- For R12.0
                   p_start_date         IN DATE,
                   p_end_date           IN DATE,
                   p_batch_id           IN NUMBER,
                   p_header_id          IN NUMBER,
                   p_processed_ind      IN NUMBER,
                   p_rowid              IN ROWID
                   ) IS

    CURSOR get_batch_status IS
    SELECT gbh.batch_no, gbh.batch_status,
           gbh.recipe_validity_rule_id,
           mp.organization_code
    FROM   gme_batch_header gbh, mtl_parameters mp
    WHERE  gbh.batch_id = p_batch_id
      AND  gbh.organization_id = mp.organization_id
      AND  mp.organization_id = p_organization_id;

    x_message_count         NUMBER;
    x_message_list          VARCHAR2(2000);
    x_return_status         VARCHAR2(2000);
    X_msg_count             NUMBER;
    l_gme_batch_header      GME_BATCH_HEADER%ROWTYPE;
    l_gme_batch_header2     GME_BATCH_HEADER%ROWTYPE;
    l_batch_status          NUMBER(5);
    l_batch_no              VARCHAR2(32);
    l_effectivity_id        NUMBER(10) ;
    l_org_code              VARCHAR2(10);
    x_data                  VARCHAR2(250) ;
    l_dummy_cnt             NUMBER ;
    ERROR_MESSAGE           EXCEPTION;
BEGIN
     /* { */
     OPEN  get_batch_status;
     FETCH get_batch_status INTO l_batch_no,l_batch_status,
           l_effectivity_id, l_org_code;
     CLOSE get_batch_status;

     IF l_batch_status <> 1 THEN
          FND_MESSAGE.SET_NAME('GMP','MR_INVALID_BATCH_STATUS_USE_GM');
          FND_MESSAGE.SET_TOKEN('BATCH_NO',l_batch_no);
          FND_FILE.PUT_LINE(FND_FILE.LOG,'-'||FND_MESSAGE.GET);
     ELSE
          -- Batch will be rescheduled via GME mechanism
          l_gme_batch_header.batch_id := p_batch_id ;
          l_gme_batch_header.organization_id := p_organization_id;
          l_gme_batch_header.RECIPE_VALIDITY_RULE_ID := l_effectivity_id ;

          GME_API_PUB.cancel_batch
                      ( p_api_version          => 2.0,
                        p_validation_level     => 100,
                        p_init_msg_list        => 'T',
                        p_commit               => 'T',
                        x_message_count        => x_message_count,
                        x_message_list         => x_message_list,
                        x_return_status        => X_return_status,
                        p_org_code             => l_org_code,
                        p_batch_header_rec     => l_gme_batch_header,
                        x_batch_header_rec     => l_gme_batch_header2);

          IF X_return_status <> 'S' THEN
             RAISE ERROR_MESSAGE;
          ELSE
             FND_MESSAGE.SET_NAME('GME','GME_API_BATCH_CANCELLED');
             FND_FILE.PUT_LINE(FND_FILE.LOG,'-  '||FND_MESSAGE.GET||l_batch_no);

             UPDATE gmp_aps_output_tbl
             SET processed_ind = 0
             WHERE rowid = p_rowid
               AND processed_ind > 0 ;

          END IF; /* End if for GME Return Status */

     END IF;  /* } */

EXCEPTION
   WHEN ERROR_MESSAGE THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,' Error in Cancel Batch - Status Not in S  '||p_batch_id||'-'||sqlerrm);

          FOR i in 1..fnd_msg_pub.count_msg LOOP
                FND_MSG_PUB.Get(
                  p_msg_index => i,
                  p_data => x_data,
                  p_encoded => FND_API.G_FALSE,
                  p_msg_index_out => l_dummy_cnt);

                  FND_FILE.PUT_LINE(FND_FILE.LOG,':'|| i || ':' || x_data );
          END LOOP ;

        IF (FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',NULL)) THEN
            NULL;
        END IF;
   WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,' Error in Cancel Batch '||sqlerrm);
END cancel_batch;

END GMPRELAP;


/
