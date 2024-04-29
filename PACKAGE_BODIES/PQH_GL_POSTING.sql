--------------------------------------------------------
--  DDL for Package Body PQH_GL_POSTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_GL_POSTING" AS
/* $Header: pqglpost.pkb 120.7.12010000.2 2008/08/05 13:34:56 ubhat ship $ */

-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_gl_posting';  -- Global package name
--
g_application_id            NUMBER(15)  := 101;
g_set_of_books_id           gl_interface.set_of_books_id%TYPE;
g_budgetary_control_flag    gl_sets_of_books.enable_budgetary_control_flag%TYPE;
g_budget_name               pqh_budgets.budget_name%TYPE;
g_budgeted_entity_cd        pqh_budgets.budgeted_entity_cd%TYPE;
g_budget_id                 pqh_budgets.budget_id%TYPE;
g_user_je_source_name       gl_interface.user_je_source_name%TYPE;
g_user_je_category_name     gl_interface.user_je_category_name%TYPE;
g_budget_version_id         gl_interface.budget_version_id%TYPE;
g_gl_budget_version_id      gl_interface.budget_version_id%TYPE;
g_version_number            pqh_budget_versions.version_number%TYPE;
g_chart_of_accounts_id      gl_interface.chart_of_accounts_id%TYPE;
g_currency_code             gl_interface.currency_code%TYPE;
g_detail_error              VARCHAR2(10);
g_currency_code1            gl_interface.currency_code%TYPE;
g_currency_code2            gl_interface.currency_code%TYPE;
g_currency_code3            gl_interface.currency_code%TYPE;
g_error_exception           exception;
g_table_route_id_bvr        number;
g_table_route_id_bdt        number;
g_table_route_id_bpr        number;
g_table_route_id_bfs        number;
g_table_route_id_glf        number;
g_status                    varchar2(10);
g_validate                  boolean;
g_last_posted_ver           gl_interface.budget_version_id%TYPE;
g_psb_budget_flag           pqh_budgets.psb_budget_flag%TYPE;
g_transfer_to_grants_flag   pqh_budgets.transfer_to_grants_flag%TYPE;
g_bgt_currency_code         pqh_budgets.currency_code%TYPE;



-- ----------------------------------------------------------------------------
--
-- Private procedures
--
PROCEDURE populate_globals_error
( p_message_text     IN    pqh_process_log.message_text%TYPE) ;

--
PROCEDURE reverse_commitment_post(p_last_posted_ver          IN  NUMBER,
                                  p_curr_bdgt_version        IN  NUMBER);
-- Procedures added for Transfer to Grants

PROCEDURE adjust_ptaeo_gms_amount
(
p_inx                IN binary_integer,
p_unit_of_measure    IN number,
p_period_encumbrance IN number,
p_period_tot_amount  IN number
) ;

PROCEDURE populate_pqh_gms_interface
(
 p_budget_detail_id     IN pqh_budget_details.budget_detail_id%TYPE
);

PROCEDURE insert_pqh_gms_interface
(
 p_budget_detail_id  IN pqh_gl_interface.budget_detail_id%TYPE,
 p_period_name       IN varchar2,
 p_project_id        IN pqh_gl_interface.project_id%TYPE,
 p_task_id	     IN pqh_gl_interface.task_id%TYPE,
 p_award_id	     IN pqh_gl_interface.award_id%TYPE,
 p_expenditure_type  IN pqh_gl_interface.expenditure_type%TYPE,
 p_organization_id   IN pqh_gl_interface.organization_id%TYPE,
 p_amount            IN pqh_gl_interface.amount_dr%TYPE
);

PROCEDURE update_pqh_gms_interface
(
 p_budget_detail_id  IN pqh_gl_interface.budget_detail_id%TYPE,
 p_period_name       IN varchar2,
 p_project_id        IN pqh_gl_interface.project_id%TYPE,
 p_task_id	     IN pqh_gl_interface.task_id%TYPE,
 p_award_id	     IN pqh_gl_interface.award_id%TYPE,
 p_expenditure_type  IN pqh_gl_interface.expenditure_type%TYPE,
 p_organization_id   IN pqh_gl_interface.organization_id%TYPE,
 p_amount            IN pqh_gl_interface.amount_dr%TYPE
) ;

PROCEDURE populate_gms_tables;

PROCEDURE ins_gl_bc_run_fund_check
( p_packet_id            IN   gl_bc_packets.packet_id%TYPE
 ,p_code_combination_id  IN   pqh_gl_interface.code_combination_id%TYPE
 ,p_period_name          IN   pqh_gl_interface.period_name%TYPE
 ,p_period_year          IN   gl_period_statuses.period_year%TYPE
 ,p_period_num           IN   gl_period_statuses.period_num%TYPE
 ,p_quarter_num          IN   gl_period_statuses.quarter_num%TYPE
 ,p_currency_code        IN   pqh_gl_interface.currency_code%TYPE
 ,p_entered_dr           IN   pqh_gl_interface.amount_dr%TYPE
 ,p_entered_cr           IN   pqh_gl_interface.amount_cr%TYPE
 ,p_accounted_dr         IN   pqh_gl_interface.amount_dr%TYPE
 ,p_accounted_cr         IN   pqh_gl_interface.amount_cr%TYPE
 ,p_cost_allocation_keyflex_id           IN   pqh_gl_interface.cost_allocation_keyflex_id%TYPE
 ,p_fc_mode              IN   varchar2
 ,p_fc_success           OUT NOCOPY boolean
 ,p_fc_return            OUT NOCOPY varchar2
 );
-- Procedure added to run funds checker in autonomous transaction

------------------------------------------------------------------------------
PROCEDURE conc_post_budget
(
 errbuf                           OUT  NOCOPY VARCHAR2,
 retcode                          OUT  NOCOPY VARCHAR2,
 p_budget_version_id              IN  pqh_budget_versions.budget_version_id%TYPE,
 p_validate                       IN  varchar2    default 'N'
) IS
/*
 This procedure will call the post_budget procedure . This procedure is written as this
 would be called from the concurrent program Budget GL Posting ( PQHGLPOST )
*/
--
-- local variables
--
 l_proc                         varchar2(72) := g_package||'.conc_post_budget';
 l_status                       varchar2(50);
 l_validate                     boolean;

BEGIN

  hr_utility.set_location('Entering: '||l_proc, 5);

  IF NVL(p_validate,'N') = 'Y' THEN
    l_validate := true;
  ELSE
    l_validate := false;
  END IF;

  post_budget
  ( p_budget_version_id      =>  p_budget_version_id,
    p_validate               =>  l_validate,
    p_status                 =>  l_status
  );


  hr_utility.set_location('Leaving:'||l_proc, 1000);

END;




-- ----------------------------------------------------------------------------

PROCEDURE post_budget
(
 p_budget_version_id              IN  pqh_budget_versions.budget_version_id%TYPE,
 p_validate                       IN  boolean    default false,
 p_status                         OUT NOCOPY varchar2
) IS
/*
   This is the MAIN procedure which would be called.
   This would pick-up all the budget_detail_ids under the budget_version_id and
   try to post them to gl interface tables and pa interface table
   If the program is run in validate mode i.e p_validate is TRUE then we would just check for
   errors in pqh budget tables i.e period and gl account errors ,LD Encumbrance and log the errors
*/
--
-- local variables
--
 l_proc                         varchar2(72) := g_package||'.post_budget';
 l_budget_details_rec           pqh_budget_details%ROWTYPE;
 l_log_context                  pqh_process_log.log_context%TYPE;
 l_budget_detail_result		varchar2(1);
 l_message_text                 fnd_new_messages.message_text%TYPE;
 l_dummy                        varchar2(10);


 CURSOR csr_budget_detail_recs IS
 SELECT *
 FROM pqh_budget_details
 WHERE budget_version_id  = p_budget_version_id
   AND NVL(gl_status,'X') <> 'POST';


BEGIN

  hr_utility.set_location('Entering: '||l_proc, 5);

  -- establish a savepoint at the begining
  -- added as part of fixing bug#3265978 by kgowripe
     savepoint post_budget;
  --
  -- populate the out variable to ERROR and start processing
  -- at the end we will populate the out variable depending on
  -- the program status
     p_status := 'ERROR';
     g_validate := p_validate;

  -- populate the globals and start the process log
    populate_globals
    (
     p_budget_version_id   => p_budget_version_id
    );

  -- If this Budget is marked as 'Transfer Commitments Only' then we  cannot Transfer this budget
  -- In that case we will end log and terminate the program
  IF (nvl(g_psb_budget_flag,'N') ='Y') THEN
   FND_MESSAGE.SET_NAME('PQH','PQH_CMMT_XFER_BUDGET');
   l_message_text := FND_MESSAGE.GET;
   populate_globals_error
          (
            p_message_text  =>  l_message_text
          );
   -- abort the program
           RAISE g_error_exception;
  END IF;


  -- process all the budget details
  OPEN csr_budget_detail_recs;
    LOOP
      FETCH csr_budget_detail_recs INTO l_budget_details_rec;
      EXIT WHEN csr_budget_detail_recs%NOTFOUND;

         -- get log_context
         set_bdt_log_context
         (
          p_budget_detail_id        => l_budget_details_rec.budget_detail_id,
          p_log_context             => l_log_context
         );

        -- set the context
         pqh_process_batch_log.set_context_level
         (
          p_txn_id                =>  l_budget_details_rec.budget_detail_id,
          p_txn_table_route_id    =>  g_table_route_id_bdt,
          p_level                 =>  1,
          p_log_context           =>  l_log_context
         );

        -- for each budget detail
          populate_period_amt_tab
          (
           p_budget_detail_id => l_budget_details_rec.budget_detail_id
          );

          -- get the period name ,gl account and LD Encumbrance adjustments
            update_period_amt_tab
            (
             p_budget_detail_id => l_budget_details_rec.budget_detail_id
            );

          --  populate pqh_gl_interface table if there was no error and validate is false
            IF NOT p_validate THEN
             -- build the old_bdgt_dtls_tab
              build_old_bdgt_dtls_tab
              (
               p_budget_detail_id  => l_budget_details_rec.budget_detail_id
              );

             -- build the new bdgt_dtls tab and populate_pqh_gl_interface
             -- we use same table pqh_gl_interface for Gl as well as GMS transfer
              populate_pqh_gl_interface
              (
                p_budget_detail_id => l_budget_details_rec.budget_detail_id
              );

              populate_pqh_gms_interface
	      (
	        p_budget_detail_id => l_budget_details_rec.budget_detail_id
              );

            -- compare the old and new tables
              compare_old_bdgt_dtls_tab;

            -- reverse the old bdgt_dtls recs not in new
               reverse_old_bdgt_dtls_tab
              (
                p_budget_detail_id => l_budget_details_rec.budget_detail_id
              );

            END IF;  -- if not in validate mode

    END LOOP;
  CLOSE csr_budget_detail_recs;


/*
  At any point of time , only ONE budget version can be posted.  So if this version is different
  from the previously posted version, we would reverse the previously posted version.
*/

       IF NOT p_validate THEN
           reverse_prev_posted_version;
       END IF;

  -- if not in validate mode
  -- insert into gl_interface or gl_bc_packets table all Records that need to be transfered to GL
  -- For all Records that need to be transfered to Grants
  -- insert into pa_interface_all table and call gms_pub api

       IF NOT p_validate THEN
         populate_gl_tables;
         if g_transfer_to_grants_flag = 'Y' then
            populate_gms_tables;
         end if;
       END IF;

/*
   update gl_status of pqh_budget_versions and pqh_budget_details
   update posting_date and status of pqh_gl_interface
   update the global g_status with the program status
*/

     IF NOT p_validate THEN
       update_gl_status;
     END IF;


  -- end the error log process and update the global g_status with the program status
    end_log;

  -- commit work if run in actual mode only i.e p_validate is false
    IF NOT p_validate THEN
      commit;
    END IF;

  -- update the OUT param
     p_status := g_status;


  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
  WHEN g_error_exception THEN
     hr_utility.set_location('Aborting : '||l_proc, 1000);
     -- ROLLBACK ;
      rollback to post_budget;
     end_log;
  WHEN OTHERS THEN
--      ROLLBACK ;
--   rollback to the save point established at the start of the procedure
--   added as part fix for bug#3265978 by kgowripe
      rollback to post_budget;
--
      hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
      hr_utility.set_message_token('ROUTINE', l_proc);
      hr_utility.set_message_token('REASON', SQLERRM);
      hr_utility.raise_error;
END post_budget;

-- ----------------------------------------------------------------------------
PROCEDURE populate_globals
(
  p_budget_version_id             IN  pqh_budget_versions.budget_version_id%TYPE
) IS
/*
  This procedure will populate all the global variables and start the log context
  If there is any error in populate globals we will end log and terminate the program
*/
--
-- local variables
--
 l_proc                         varchar2(72) := g_package||'.populate_globals';
 l_budgets_rec                  pqh_budgets%ROWTYPE;
 l_budget_versions_rec          pqh_budget_versions%ROWTYPE;
 l_gl_sets_of_books_rec         gl_sets_of_books%ROWTYPE;
 l_shared_types_rec             per_shared_types%ROWTYPE;
 l_gl_budget_versions_rec       gl_budget_versions%ROWTYPE;
 l_gl_je_sources_rec            gl_je_sources%ROWTYPE;
 l_gl_je_categories_rec         gl_je_categories%ROWTYPE;
 l_transfer_to_gl_flag          varchar2(10);
 l_message_text                 pqh_process_log.message_text%TYPE;
 l_message_text_out             fnd_new_messages.message_text%TYPE;
 l_error_flag                   varchar2(10) := 'N';
 l_level                        number;
 l_batch_id                     number;
 l_batch_context                varchar2(2000);
 l_count                        number;
 l_map_count_null               number;
 l_budget_detail_result		varchar2(1);
 l_gl_budget_name               pqh_budgets.GL_BUDGET_NAME%TYPE;

 CURSOR csr_budget_versions_rec IS
 SELECT *
 FROM pqh_budget_versions
 WHERE budget_version_id = p_budget_version_id;

 CURSOR csr_budgets_rec (c_budget_id IN NUMBER) IS
 SELECT *
 FROM pqh_budgets
 WHERE budget_id = c_budget_id;
/* ns budget_id is already available, no need to fetch again
 ( SELECT budget_id
                     FROM pqh_budget_versions
                     WHERE budget_version_id = p_budget_version_id ) ;
*/

 CURSOR csr_bus_grp (p_business_group_id IN NUMBER) IS
 SELECT bg.ORG_INFORMATION10
 FROM  HR_ORGANIZATION_INFORMATION bg
 WHERE  bg.organization_id = p_business_group_id
  AND  bg.ORG_INFORMATION_CONTEXT = 'Business Group Information';

 CURSOR csr_chart_of_acc_id(p_set_of_books_id  IN NUMBER) IS
 SELECT *
 FROM gl_sets_of_books
 WHERE set_of_books_id = p_set_of_books_id;

 CURSOR csr_shared_types (p_shared_type_id IN number) IS
 SELECT *
 FROM per_shared_types
 WHERE shared_type_id = p_shared_type_id;
                                   -- Change by kmullapu. Changed p_budget_name to p_gl_budget_name as we can
                                   --now select GL Budget Name from Budget Charectaristics form

 CURSOR csr_gl_budget_version (p_gl_budget_name IN varchar2) IS
 SELECT *
 FROM gl_budget_versions
 WHERE budget_name = p_gl_budget_name AND
       status in ('O','C');

 CURSOR  csr_gl_je_sources IS
 SELECT *
 FROM gl_je_sources
 WHERE je_source_name = 'Public Sector Budget';

 CURSOR csr_gl_je_categories IS
 SELECT *
 FROM gl_je_categories
 WHERE je_category_name = 'Public Sector Budget';

 CURSOR csr_flex_maps_counts (p_budget_id IN number)IS
 SELECT COUNT(*)
 FROM pqh_budget_gl_flex_maps
 WHERE budget_id = p_budget_id;

 CURSOR csr_table_route IS
-- ns (p_table_alias  IN varchar2 )IS
 SELECT table_alias,table_route_id
 FROM pqh_table_route
 WHERE table_alias IN ('BVR','BDT','BPR','BFS','GLF');
-- =  p_table_alias;

 CURSOR csr_cost_map_null (p_budget_id  IN number) IS
 SELECT COUNT(*)
 FROM pqh_budget_gl_flex_maps
 WHERE budget_id = p_budget_id
   AND payroll_cost_segment IS NULL;


BEGIN

  hr_utility.set_location('Entering: '||l_proc, 5);

  g_budget_version_id  :=  p_budget_version_id;

  hr_utility.set_location('p_budget_version_id  '||p_budget_version_id,6);

  -- check if the input budget version Id is valid and the budget_versions is
  -- not already posted
   OPEN csr_budget_versions_rec;
     FETCH csr_budget_versions_rec INTO l_budget_versions_rec;
   CLOSE csr_budget_versions_rec;

  hr_utility.set_location('Step 1 Budget version id  '||l_budget_versions_rec.budget_version_id,6);

   IF l_budget_versions_rec.budget_version_id IS NULL THEN
     -- no record fetched i.e invalid budget_version id
     -- halt the program here
        FND_MESSAGE.SET_NAME('PQH','PQH_INV_BDG_VERSION_ID');
        APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;

  hr_utility.set_location('Step 2 ',6);

   -- check if  budget version already posted
   IF NVL(l_budget_versions_rec.gl_status,'X') = 'POST' THEN
     -- this budget version is already posted
     -- halt the program here
        FND_MESSAGE.SET_NAME('PQH','PQH_BUDGET_ALREADY_POSTED');
        APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;

   -- set the version number
      g_version_number  := l_budget_versions_rec.version_number;

  OPEN csr_budgets_rec(l_budget_versions_rec.budget_id);
    FETCH csr_budgets_rec INTO l_budgets_rec;
  CLOSE csr_budgets_rec;

   g_budget_name             := l_budgets_rec.budget_name;
   g_budgeted_entity_cd      := l_budgets_rec.budgeted_entity_cd;
   g_budget_id               := l_budgets_rec.budget_id;
   g_set_of_books_id         := l_budgets_rec.gl_set_of_books_id;
   l_transfer_to_gl_flag     := l_budgets_rec.transfer_to_gl_flag;
   l_gl_budget_name          := l_budgets_rec.gl_budget_name;
   g_psb_budget_flag         := l_budgets_rec.psb_budget_flag;
   g_transfer_to_grants_flag := l_budgets_rec.transfer_to_grants_flag;
   g_bgt_currency_code       := l_budgets_rec.currency_code;

 /*
    Start the Process Log here
    Batch ID = Budget Version Id
    Batch Context = Budget Name + Version Number
 */
      l_batch_id := g_budget_version_id;

      l_batch_context := g_budget_name||' - '||g_version_number;

  hr_utility.set_location('Batch Context  : '||l_batch_context,7);

   -- Start the Log Process
     pqh_process_batch_log.start_log
     (
      p_batch_id       => l_batch_id,
      p_module_cd      => 'GL_POSTING',
      p_log_context    => l_batch_context
     );

  hr_utility.set_location('Step 3 ',7);

  -- CHECK : if g_set_of_books_id IS NOT NULL
    IF g_set_of_books_id IS NULL THEN
       -- get message text for PQH_INVALID_GL_SET_BOOKS
       -- message : Set of Books is not defined for the budget
          FND_MESSAGE.SET_NAME('PQH','PQH_INVALID_GL_SET_BOOKS');
          l_message_text_out := FND_MESSAGE.GET;

           IF l_error_flag = 'Y' THEN
             -- there is already an error so append the message

                  l_message_text := l_message_text||' **** '||l_message_text_out;
           ELSE
              -- new message
                  l_message_text := l_message_text_out;
           END IF;

           -- set l_error_flag to Y
             l_error_flag := 'Y';

     END IF; -- g_set_of_books_id IS NOT NULL

-- CHECK : if g_bgt_currency_code  IS NOT NULL
    IF g_bgt_currency_code IS NULL THEN
       open csr_bus_grp(l_budgets_rec.business_group_id);
       fetch csr_bus_grp into g_bgt_currency_code;
       close csr_bus_grp;
       /*
       commenting the code which used to give error, if currency on budget was null
       -- get message text for PQH_INVALID_BGT_CURR_CODE
       -- message : Currency Code is not defined for the budget
          FND_MESSAGE.SET_NAME('PQH','PQH_INVALID_BGT_CURR_CODE');
          l_message_text_out := FND_MESSAGE.GET;

           IF l_error_flag = 'Y' THEN
             -- there is already an error so append the message

                  l_message_text := l_message_text||' **** '||l_message_text_out;
           ELSE
              -- new message
                  l_message_text := l_message_text_out;
           END IF;

           -- set l_error_flag to Y
             l_error_flag := 'Y';
        */
     END IF; -- g_bgt_currency_code IS NOT NULL


  -- CHECK : if transfer_to_gl_flag IS Y
    IF NVL(l_transfer_to_gl_flag,'N') <> 'Y'  THEN
       -- get message text for PQH_BUDGET_TRANSFER_FLAG
       -- message : This Budget cannot be transfered to GL. Please check the budget characteristics
         IF  NVL(g_transfer_to_grants_flag,'N') <> 'Y' THEN
          FND_MESSAGE.SET_NAME('PQH','PQH_BUDGET_TRANSFER_FLAG');
          l_message_text_out := FND_MESSAGE.GET;
          IF l_error_flag = 'Y' THEN
             -- there is already an error so append the message

                  l_message_text := l_message_text||' **** '||l_message_text_out;
           ELSE
              -- new message
                  l_message_text := l_message_text_out;
           END IF;

           -- set l_error_flag to Y
             l_error_flag := 'Y';
         END IF;
     ELSE
       -- check if rows in pqh_budget_gl_flex_maps with NULL cost segments
         OPEN csr_cost_map_null(p_budget_id => g_budget_id);
           FETCH csr_cost_map_null INTO l_map_count_null;
         CLOSE csr_cost_map_null;

         IF NVL(l_map_count_null,0) <> 0 THEN

             -- get message text for PQH_BUDGET_GL_MAP
             -- message : Some of the GL segments  are not mapped with cost segments.
             --           You must map all the GL segments with cost segments
             FND_MESSAGE.SET_NAME('PQH','PQH_BUDGET_COST_SEGMENT_NULL');
             l_message_text_out := FND_MESSAGE.GET;

              IF l_error_flag = 'Y' THEN
                -- there is already an error so append the message

                    l_message_text := l_message_text||' **** '||l_message_text_out;
              ELSE
                 -- new message
                    l_message_text := l_message_text_out;
              END IF;

               -- set l_error_flag to Y
                  l_error_flag := 'Y';
          END IF; -- l_map_count_null <> 0

     END IF; -- if transfer_to_gl_flag IS Y

  -- CHECK if the budget is mapped
     OPEN csr_flex_maps_counts(p_budget_id => g_budget_id);
       FETCH csr_flex_maps_counts INTO l_count;
     CLOSE csr_flex_maps_counts;

  -- CHECK : count <> 0 i.e mapping is defined
    IF NVL(l_count,0) = 0 THEN
       -- get message text for PQH_BUDGET_GL_MAP
       -- message : Mapping with GL segments not defined for the budget
          FND_MESSAGE.SET_NAME('PQH','PQH_BUDGET_GL_MAP');
          l_message_text_out := FND_MESSAGE.GET;

           IF l_error_flag = 'Y' THEN
             -- there is already an error so append the message

                  l_message_text := l_message_text||' **** '||l_message_text_out;
           ELSE
              -- new message
                  l_message_text := l_message_text_out;
           END IF;

           -- set l_error_flag to Y
             l_error_flag := 'Y';

     END IF; -- count <> 0 i.e mapping is defined

  -- get gl_budget_version_id
    OPEN csr_gl_budget_version(p_gl_budget_name => l_gl_budget_name);
      FETCH csr_gl_budget_version INTO l_gl_budget_versions_rec;
    CLOSE csr_gl_budget_version;

    g_gl_budget_version_id := l_gl_budget_versions_rec.budget_version_id;

    -- CHECK : if gl_budget_version_id exists else error
    IF g_gl_budget_version_id IS NULL THEN
       -- get message text for PQH_GL_BUDGET_INVALID
       -- message : Budget is not defined in GL
          FND_MESSAGE.SET_NAME('PQH','PQH_GL_BUDGET_INVALID');
          l_message_text_out := FND_MESSAGE.GET;

           IF l_error_flag = 'Y' THEN
             -- there is already an error so append the message

                  l_message_text := l_message_text||' **** '||l_message_text_out;
           ELSE
              -- new message
                  l_message_text := l_message_text_out;
           END IF;

           -- set l_error_flag to Y
             l_error_flag := 'Y';

     END IF; -- gl_budget_version_id  is null


   -- get the set of books , budgetary control flag and currency for money
   OPEN csr_chart_of_acc_id(p_set_of_books_id  => g_set_of_books_id );
     FETCH csr_chart_of_acc_id INTO l_gl_sets_of_books_rec;
   CLOSE csr_chart_of_acc_id;

   g_chart_of_accounts_id     := l_gl_sets_of_books_rec.chart_of_accounts_id;
   g_budgetary_control_flag   := l_gl_sets_of_books_rec.enable_budgetary_control_flag;
   g_currency_code            := l_gl_sets_of_books_rec.currency_code;

   /*
      call the get_default_currency to get business group currency code
      this procedure will check if there is a default currency associated with the business_group
      if yes it will override the gl_sets_of_books currency code
   */
       get_default_currency;

   -- get the je_source
    OPEN csr_gl_je_sources;
      FETCH csr_gl_je_sources INTO l_gl_je_sources_rec;
    CLOSE csr_gl_je_sources;

    g_user_je_source_name := l_gl_je_sources_rec.user_je_source_name;

  -- CHECK : if g_user_je_source_name IS NOT NULL
    IF g_user_je_source_name IS NULL THEN
       -- get message text for PQH_INVALID_JE_SOURCE_NAME
       -- message : Journal Source Name not defined
          FND_MESSAGE.SET_NAME('PQH','PQH_INVALID_JE_SOURCE_NAME');
          l_message_text_out := FND_MESSAGE.GET;

           IF l_error_flag = 'Y' THEN
             -- there is already an error so append the message

                  l_message_text := l_message_text||' **** '||l_message_text_out;
           ELSE
              -- new message
                  l_message_text := l_message_text_out;
           END IF;

           -- set l_error_flag to Y
             l_error_flag := 'Y';

     END IF; -- g_user_je_source_name IS NOT NULL

    -- get the je category
      OPEN csr_gl_je_categories;
        FETCH csr_gl_je_categories INTO l_gl_je_categories_rec;
      CLOSE csr_gl_je_categories;

    g_user_je_category_name := l_gl_je_categories_rec.user_je_category_name;

   -- CHECK : if g_user_je_category_name IS NOT NULL
    IF g_user_je_category_name IS NULL THEN
       -- get message text for PQH_INVALID_JE_CATEGORY_NAME
       -- message : Journal Category Name not defined
          FND_MESSAGE.SET_NAME('PQH','PQH_INVALID_JE_CATEGORY_NAME');
          l_message_text_out := FND_MESSAGE.GET;

           IF l_error_flag = 'Y' THEN
             -- there is already an error so append the message

                  l_message_text := l_message_text||' **** '||l_message_text_out;
           ELSE
              -- new message
                  l_message_text := l_message_text_out;
           END IF;

           -- set l_error_flag to Y
             l_error_flag := 'Y';

     END IF; -- g_user_je_category_name IS NOT NULL

   -- populate the currency codes
   OPEN csr_shared_types(p_shared_type_id => l_budgets_rec.budget_unit1_id );
     FETCH csr_shared_types  INTO l_shared_types_rec;
   CLOSE csr_shared_types;

   IF l_shared_types_rec.system_type_cd = 'MONEY' THEN
       g_currency_code1 := g_currency_code;
   ELSE
       g_currency_code1 := 'STAT';
   END IF;

   IF l_budgets_rec.budget_unit2_id  IS NOT NULL THEN

      OPEN csr_shared_types(p_shared_type_id => l_budgets_rec.budget_unit2_id );
        FETCH csr_shared_types  INTO l_shared_types_rec;
      CLOSE csr_shared_types;

      IF l_shared_types_rec.system_type_cd = 'MONEY' THEN
          g_currency_code2 := g_currency_code;
      ELSE
          g_currency_code2 := 'STAT';
      END IF;

   END IF;  -- budget_unit2_id  IS NOT NULL

   IF l_budgets_rec.budget_unit3_id  IS NOT NULL THEN

      OPEN csr_shared_types(p_shared_type_id => l_budgets_rec.budget_unit3_id );
        FETCH csr_shared_types  INTO l_shared_types_rec;
      CLOSE csr_shared_types;

       IF l_shared_types_rec.system_type_cd = 'MONEY' THEN
          g_currency_code3 := g_currency_code;
       ELSE
          g_currency_code3 := 'STAT';
       END IF;

   END IF;   --   budget_unit3_id  IS NOT NULL

      --  mvankada

      -- This function will determine whether the budget has details or not
      -- If the budget has details return 'Y' else 'N'

       l_budget_detail_result := pqh_gl_posting.chk_budget_details(p_budget_version_id => p_budget_version_id );
       if l_budget_detail_result = 'N' then
            FND_MESSAGE.SET_NAME('PQH','PQH_EMPTY_BUDGET');
            l_message_text := FND_MESSAGE.GET;
            populate_globals_error( p_message_text  =>  l_message_text);
       end if;


      For csr_tab in csr_table_route Loop
       if csr_tab.table_alias = 'BVR' then
          g_table_route_id_bvr := csr_tab.table_route_id;
       elsif csr_tab.table_alias = 'BDT' then
          g_table_route_id_bdt := csr_tab.table_route_id;
       elsif csr_tab.table_alias = 'BPR' then
          g_table_route_id_bpr := csr_tab.table_route_id;
       elsif csr_tab.table_alias = 'BFS' then
          g_table_route_id_bfs := csr_tab.table_route_id;
       elsif csr_tab.table_alias = 'GLF' then
          g_table_route_id_glf := csr_tab.table_route_id;
       end if;
      End Loop;

/* ns fetched it in one cursor instead.
   -- get the table route id for pqh_budget versions
      OPEN csr_table_route(p_table_alias => 'BVR');
        FETCH csr_table_route INTO g_table_route_id_bvr;
      CLOSE csr_table_route;

    -- get the table route id for pqh_budget details
      OPEN csr_table_route(p_table_alias => 'BDT');
        FETCH csr_table_route INTO g_table_route_id_bdt;
      CLOSE csr_table_route;

    -- get the table route id for pqh_budget details
      OPEN csr_table_route(p_table_alias => 'BPR');
        FETCH csr_table_route INTO g_table_route_id_bpr;
      CLOSE csr_table_route;

    -- get the table route id for pqh_budget fund srcs
      OPEN csr_table_route(p_table_alias => 'BFS');
        FETCH csr_table_route INTO g_table_route_id_bfs;
      CLOSE csr_table_route;

    -- get the table route id for gl_bc_packets
      OPEN csr_table_route(p_table_alias => 'GLF');
        FETCH csr_table_route INTO g_table_route_id_glf;
      CLOSE csr_table_route;

*/

  hr_utility.set_location('Budget Name : '||g_budget_name,100);
  hr_utility.set_location('Set Of Books Id : '||g_set_of_books_id,110);
  hr_utility.set_location('g_gl_budget_version_id : '||g_gl_budget_version_id,111);
  hr_utility.set_location('g_budget_version_id : '||g_budget_version_id,112);
  hr_utility.set_location('g_budgetary_control_flag : '||g_budgetary_control_flag,120);
  hr_utility.set_location('g_currency_code1 : '||g_currency_code1,150);
  hr_utility.set_location('g_currency_code2 : '||g_currency_code2,160);
  hr_utility.set_location('g_currency_code3 : '||g_currency_code3,170);
  hr_utility.set_location('g_user_je_source_name : '||g_user_je_source_name,180);
  hr_utility.set_location('g_user_je_category_name : '||g_user_je_category_name,190);



  -- if any errors the end the process log and abort the program
      IF l_error_flag = 'Y' THEN

       -- end the process log as the  batch itself has error
          populate_globals_error
          (
            p_message_text  =>  l_message_text
          );

/*
       -- we would rollback any inserts before we update
       -- this is done to undo apply_budget if called from apply_transaction
        rollback;

          UPDATE pqh_process_log
           SET message_type_cd =  'ERROR',
               message_text   = l_message_text,
               txn_table_route_id    =  g_table_route_id_bvr
              -- batch_status    = 'ERROR',
              -- batch_end_date  = sysdate
           WHERE process_log_id = pqh_process_batch_log.g_master_process_log_id;

           -- commit the update work
             commit;
*/

           -- abort the program
           RAISE g_error_exception;

      END IF; -- insert error message if l_error_flag is Y



  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN g_error_exception THEN
        RAISE;
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END populate_globals;



-- ----------------------------------------------------------------------------
PROCEDURE populate_period_amt_tab
(
 p_budget_detail_id IN pqh_budget_details.budget_detail_id%TYPE
) IS
/*
  this procedure will populate the global table g_period_amt_tab
  Cursor csr_dflt_period_amts calculates the Funding Source wise distribution
  from the Default Budget Set Distribution
*/
--
-- local variables
--
 l_proc                           varchar2(72) := g_package||'.populate_period_amt_tab';
 l_budget_period_id               pqh_budget_periods.budget_period_id%TYPE;
 l_cost_allocation_keyflex_id     pqh_budget_fund_srcs.cost_allocation_keyflex_id%TYPE;
 l_project_id                     pqh_budget_fund_srcs.project_id%TYPE;
 l_award_id              	  pqh_budget_fund_srcs.award_id%TYPE;
 l_task_id                	  pqh_budget_fund_srcs.task_id%TYPE;
 l_expenditure_type      	  pqh_budget_fund_srcs.expenditure_type%TYPE;
 l_organization_id		  pqh_budget_fund_srcs.organization_id%TYPE;
 l_amount1                        NUMBER;
 l_amount2                        NUMBER;
 l_amount3                        NUMBER;
 i                                BINARY_INTEGER :=1;


CURSOR csr_period_amts IS
SELECT bpr.budget_period_id ,
       bfs.cost_allocation_keyflex_id,
       bfs.project_id,
       bfs.award_id,
       bfs.task_id,
       bfs.expenditure_type,
       bfs.organization_id,
       SUM(pqh_gl_posting.get_amt1(bfs.budget_fund_src_id)) Amount1,
       SUM(pqh_gl_posting.get_amt2(bfs.budget_fund_src_id)) Amount2,
       SUM(pqh_gl_posting.get_amt3(bfs.budget_fund_src_id)) Amount3
FROM pqh_budget_fund_srcs bfs, pqh_budget_elements bel,
     pqh_budget_sets bst, pqh_budget_periods bpr
WHERE bpr.budget_period_id = bst.budget_period_id
  AND bst.budget_set_id = bel.budget_set_id
  AND bel.budget_element_id = bfs.budget_element_id
  AND bpr.budget_detail_id = p_budget_detail_id
GROUP BY bpr.budget_period_id ,bfs.cost_allocation_keyflex_id,
         bfs.project_id, bfs.award_id,bfs.task_id,
	 bfs.expenditure_type,bfs.organization_id
ORDER BY bpr.budget_period_id , bfs.cost_allocation_keyflex_id,
         bfs.project_id, bfs.award_id,bfs.task_id,
	 bfs.expenditure_type,bfs.organization_id;

CURSOR csr_dflt_period_amts IS
SELECT bpr.budget_period_id ,
       bfs.cost_allocation_keyflex_id,
       bfs.project_id,
       bfs.award_id,
       bfs.task_id,
       bfs.expenditure_type,
       bfs.organization_id,
       SUM((NVL(bfs.dflt_dist_percentage,0)*0.01)*(NVL(bel.dflt_dist_percentage,0)*0.01)*NVL(bst.budget_unit1_value,0)) Amount1,
       SUM((NVL(bfs.dflt_dist_percentage,0)*0.01)*(NVL(bel.dflt_dist_percentage,0)*0.01)*NVL(bst.budget_unit2_value,0)) Amount2,
       SUM((NVL(bfs.dflt_dist_percentage,0)*0.01)*(NVL(bel.dflt_dist_percentage,0)*0.01)*NVL(bst.budget_unit3_value,0)) Amount3
FROM   pqh_dflt_fund_srcs bfs,
       pqh_dflt_budget_elements bel,
       pqh_budget_sets bst,
       pqh_budget_periods bpr
WHERE  bpr.budget_period_id = bst.budget_period_id
  AND  bst.dflt_budget_set_id = bel.dflt_budget_set_id
  AND  bel.dflt_budget_element_id = bfs.dflt_budget_element_id
  AND  bpr.budget_detail_id = p_budget_detail_id
GROUP BY bpr.budget_period_id ,bfs.cost_allocation_keyflex_id,
         bfs.project_id, bfs.award_id,bfs.task_id,
	 bfs.expenditure_type,bfs.organization_id
ORDER BY bpr.budget_period_id , bfs.cost_allocation_keyflex_id,
         bfs.project_id, bfs.award_id,bfs.task_id,
	 bfs.expenditure_type,bfs.organization_id;

BEGIN

  hr_utility.set_location('Entering: '||l_proc, 5);

  -- delete the g_period_amt_tab;
     g_period_amt_tab.DELETE;

  OPEN csr_period_amts;
    LOOP
      FETCH csr_period_amts INTO l_budget_period_id, l_cost_allocation_keyflex_id,
                                 l_project_id,l_award_id,l_task_id,
				 l_expenditure_type,l_organization_id,
                                 l_amount1, l_amount2, l_amount3;
      EXIT WHEN csr_period_amts%NOTFOUND;

       g_period_amt_tab(i).period_id                   := l_budget_period_id;
       g_period_amt_tab(i).cost_allocation_keyflex_id  := l_cost_allocation_keyflex_id;
       g_period_amt_tab(i).project_id                  := l_project_id;
       g_period_amt_tab(i).award_id                    := l_award_id;
       g_period_amt_tab(i).task_id                     := l_task_id;
       g_period_amt_tab(i).expenditure_type            := l_expenditure_type;
       g_period_amt_tab(i).organization_id             := l_organization_id;
       g_period_amt_tab(i).amount1                     := l_amount1;
       g_period_amt_tab(i).amount2                     := l_amount2;
       g_period_amt_tab(i).amount3                     := l_amount3;

       i := i + 1;

    END LOOP;
  CLOSE csr_period_amts;
-- Added By kgowripe. Populate Default Budget Set Distribution
-- Should be using the Default Budget Set Distribution in case there is no
-- elements and Funding sources defined for the Budget set in the Budget Period
  IF i = 1 THEN
    hr_utility.set_location('Populating Default Budget Set Distribution '||l_proc,10);
    OPEN csr_dflt_period_amts;
    LOOP
      FETCH csr_dflt_period_amts INTO l_budget_period_id, l_cost_allocation_keyflex_id,
                                      l_project_id,l_award_id,l_task_id,
                                      l_expenditure_type,l_organization_id,
                                      l_amount1, l_amount2, l_amount3;
      EXIT WHEN csr_dflt_period_amts%NOTFOUND;
      g_period_amt_tab(i).period_id                   := l_budget_period_id;
      g_period_amt_tab(i).cost_allocation_keyflex_id  := l_cost_allocation_keyflex_id;
      g_period_amt_tab(i).project_id                  := l_project_id;
      g_period_amt_tab(i).award_id                    := l_award_id;
      g_period_amt_tab(i).task_id                     := l_task_id;
      g_period_amt_tab(i).expenditure_type            := l_expenditure_type;
      g_period_amt_tab(i).organization_id             := l_organization_id;
      g_period_amt_tab(i).amount1                     := l_amount1;
      g_period_amt_tab(i).amount2                     := l_amount2;
      g_period_amt_tab(i).amount3                     := l_amount3;

     i := i+1;
   END LOOP;
   CLOSE csr_dflt_period_amts;
  END IF;
-- End  code changes by kgowripe
  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END populate_period_amt_tab;

-- ----------------------------------------------------------------------------
PROCEDURE update_period_amt_tab
(
 p_budget_detail_id IN pqh_budget_details.budget_detail_id%TYPE
)
IS
/*
  This procedure will read the above populated global table g_period_amt_tab and

   1.Get the period_name and code_combination_id corresponding to the period_id and
     cost_allocation_keyflex_id. If it does not find a period_name or a code_combination_id then
     it will populate the global variable   g_detail_error to Y.

   2.Get LD Encumbrance/Liquidation amount for each Budget Period and make adjustments to
     all PTAEO's invlved in that Budget period.

  If g_detail_error is Y then we will not populate the pqh_gl_interface table for the current
  budget_detail_id
*/

--
-- local variables
--
 l_proc                           varchar2(72) := g_package||'.update_period_amt_tab';
 l_period_name                    gl_period_statuses.period_name%TYPE;
 l_accounting_date                gl_period_statuses.start_date%TYPE;
 l_code_combination_id            gl_code_combinations.code_combination_id%TYPE;
 l_gl_period_statuses_rec         gl_period_statuses%ROWTYPE;
 l_message_text                   pqh_process_log.message_text%TYPE;
 l_message_text_out               fnd_new_messages.message_text%TYPE;
 l_count                          NUMBER;
 l_error_flag                     varchar2(10) := 'N';
 l_log_context                  pqh_process_log.log_context%TYPE;



BEGIN

  hr_utility.set_location('Entering: '||l_proc, 5);

  -- initialize g_detail_error
     g_detail_error := 'N';

  IF NVL(g_period_amt_tab.COUNT,0) <> 0 THEN
    --
    --IF Budget is Transfered to GMS then we need to Get LD encumbrance amount and make PTAEO adjustments
    --
    IF (NVL(g_transfer_to_grants_flag,'N') ='Y' AND fnd_profile.value('PSP_ENC_ENABLE_PQH')='Y')
    THEN
    populate_period_enc_tab(p_budget_detail_id);
    END IF;
    -- loop thru the array and get the segment value
     FOR i IN NVL(g_period_amt_tab.FIRST,0)..NVL(g_period_amt_tab.LAST,-1)
     LOOP
     --GMS Changes by kmullapu
     --Check if records is Gl records (cost_allocation_flexfield is not null)
     --get the  period_name and code_combination_id only for Gl reocrds
     --
     IF (g_period_amt_tab(i).cost_allocation_keyflex_id is not null) THEN
       -- period name
       get_gl_period
       (
        p_budget_period_id        => g_period_amt_tab(i).period_id,
        p_gl_period_statuses_rec  => l_gl_period_statuses_rec
       );

         l_period_name     := l_gl_period_statuses_rec.period_name;
         l_accounting_date := l_gl_period_statuses_rec.start_date;

         IF l_period_name IS NULL THEN
           -- no period name found mark detail as error and proceed
             g_detail_error := 'Y';
              -- get log_context
               set_bpr_log_context
               (
                p_budget_period_id        => g_period_amt_tab(i).period_id,
                p_log_context             => l_log_context
               );

              -- set the context
              pqh_process_batch_log.set_context_level
              (
               p_txn_id                =>  g_period_amt_tab(i).period_id,
               p_txn_table_route_id    =>  g_table_route_id_bpr,
               p_level                 =>  2,
               p_log_context           =>  l_log_context
               );

             -- get message text for PQH_INVALID_GL_BUDGET_PERIOD
             -- message : There is no corresponding period in GL for the current Budget Period
                FND_MESSAGE.SET_NAME('PQH','PQH_INVALID_GL_BUDGET_PERIOD');
                l_message_text := FND_MESSAGE.GET;

               -- insert error
              pqh_process_batch_log.insert_log
              (
               p_message_type_cd    =>  'ERROR',
               p_message_text       =>  l_message_text
              );


         ELSE
            -- update the pl sql table with period name and accounting date
             g_period_amt_tab(i).period_name     := l_period_name;
             g_period_amt_tab(i).accounting_date := l_accounting_date;
         END IF;

        -- gl account
          get_gl_ccid
          (
           p_budget_detail_id            => p_budget_detail_id,
           p_budget_period_id            => g_period_amt_tab(i).period_id,
           p_cost_allocation_keyflex_id  => g_period_amt_tab(i).cost_allocation_keyflex_id,
           p_code_combination_id         => l_code_combination_id
          );

          IF l_code_combination_id IS NULL THEN
            -- no gl account found, mark as error
             g_detail_error := 'Y';

              -- get log_context
               set_bfs_log_context
               (
                p_cost_allocation_keyflex_id   => g_period_amt_tab(i).cost_allocation_keyflex_id,
                p_log_context                  => l_log_context
                );

              -- set the context
              pqh_process_batch_log.set_context_level
              (
               p_txn_id                =>  g_period_amt_tab(i).cost_allocation_keyflex_id,
               p_txn_table_route_id    =>  g_table_route_id_bfs,
               p_level                 =>  2,
               p_log_context           =>  l_log_context
               );

             -- get message text for PQH_INVALID_GL_BUDGET_ACCOUNT
             -- message : There is no corresponding account in GL for the current funding source
                FND_MESSAGE.SET_NAME('PQH','PQH_INVALID_GL_BUDGET_ACCOUNT');
                l_message_text := FND_MESSAGE.GET;

               -- insert error
              pqh_process_batch_log.insert_log
              (
               p_message_type_cd    =>  'ERROR',
               p_message_text       =>  l_message_text
              );


          ELSE
             -- update the pl sql table with gl account
              g_period_amt_tab(i).code_combination_id  := l_code_combination_id;
          END IF;
     ELSE
      --
      -- For Records that are being Xfered to Grants Peiod_name is nothing but Period_id
      --
      g_period_amt_tab(i).period_name  :=to_char(g_period_amt_tab(i).period_id);
     END IF; /** g_period_amt_tab(i).cost_allocation_keyflex_id is not null **/
     END LOOP; -- end of pl sql table
  END IF;



  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END update_period_amt_tab;


-- ----------------------------------------------------------------------------

PROCEDURE populate_pqh_gl_interface
(
 p_budget_detail_id     IN pqh_budget_details.budget_detail_id%TYPE
)
IS
/*
  This procedure will update or insert into pqh_gl_interface if there was no error for
  the current budget detail record i.e g_detail_error = N
  if g_detail_error = Y then update the pqh_budget_details record with gl_status = ERROR
*/
--
-- local variables
--
 l_proc                           varchar2(72) := g_package||'.populate_pqh_gl_interface';
 l_pqh_gl_interface_rec           pqh_gl_interface%ROWTYPE;
 l_uom1_count                     number;
 l_uom2_count                     number;
 l_uom3_count                     number;

 CURSOR csr_pqh_interface (p_period_name IN varchar2,
                           p_code_combination_id IN number,
                           p_currency_code  IN varchar2) IS
 SELECT COUNT(*)
 FROM pqh_gl_interface
 WHERE budget_version_id    = g_budget_version_id
   AND budget_detail_id     = p_budget_detail_id
   AND posting_type_cd      = 'BUDGET'
   AND period_name          = p_period_name
   AND code_combination_id  = p_code_combination_id
   AND currency_code        = p_currency_code
   AND NVL(adjustment_flag,'N') = 'N'
   AND status IS NOT NULL
   AND posting_date IS NOT NULL;


BEGIN

  hr_utility.set_location('Entering: '||l_proc, 5);

  IF  g_detail_error = 'N' THEN

    -- loop thru the array and get populate the pqh_gl_interface table

     FOR i IN NVL(g_period_amt_tab.FIRST,0)..NVL(g_period_amt_tab.LAST,-1)
     LOOP

     -- Populate only GL records
     IF (g_period_amt_tab(i).cost_allocation_keyflex_id is not null)
     THEN
       -- for UOM1 i.e g_currency_code1
       OPEN csr_pqh_interface(p_period_name => g_period_amt_tab(i).period_name,
                              p_code_combination_id => g_period_amt_tab(i).code_combination_id,
                              p_currency_code   => g_currency_code1 );
             FETCH csr_pqh_interface INTO l_uom1_count;
       CLOSE  csr_pqh_interface;

         IF l_uom1_count <> 0 THEN
           -- update pqh_gl_interface and create a adjustment txn
              update_pqh_gl_interface
              (
               p_budget_detail_id            => p_budget_detail_id,
               p_period_name                 => g_period_amt_tab(i).period_name,
               p_accounting_date             => g_period_amt_tab(i).accounting_date,
               p_code_combination_id         => g_period_amt_tab(i).code_combination_id,
               p_cost_allocation_keyflex_id  => g_period_amt_tab(i).cost_allocation_keyflex_id,
               p_amount                      => g_period_amt_tab(i).amount1,
               p_currency_code               => g_currency_code1
               );
         ELSE
           -- insert into pqh_gl_interface
              insert_pqh_gl_interface
              (
               p_budget_detail_id            => p_budget_detail_id,
               p_period_name                 => g_period_amt_tab(i).period_name,
               p_accounting_date             => g_period_amt_tab(i).accounting_date,
               p_code_combination_id         => g_period_amt_tab(i).code_combination_id,
               p_cost_allocation_keyflex_id  => g_period_amt_tab(i).cost_allocation_keyflex_id,
               p_amount                      => g_period_amt_tab(i).amount1,
               p_currency_code               => g_currency_code1
               );
         END IF;  -- l_uom1_count <> 0


       -- for UOM2 i.e g_currency_code2

          IF (g_currency_code2 IS NOT NULL) AND (g_period_amt_tab(i).amount2 <> 0) THEN
             OPEN csr_pqh_interface(p_period_name => g_period_amt_tab(i).period_name,
                                    p_code_combination_id => g_period_amt_tab(i).code_combination_id,
                                    p_currency_code   => g_currency_code2 );
                  FETCH csr_pqh_interface INTO l_uom2_count;
             CLOSE  csr_pqh_interface;

               IF l_uom2_count <> 0 THEN
                -- update pqh_gl_interface and create a adjustment txn
                  update_pqh_gl_interface
                  (
                   p_budget_detail_id            => p_budget_detail_id,
                   p_period_name                 => g_period_amt_tab(i).period_name,
                   p_accounting_date             => g_period_amt_tab(i).accounting_date,
                   p_code_combination_id         => g_period_amt_tab(i).code_combination_id,
                   p_cost_allocation_keyflex_id  => g_period_amt_tab(i).cost_allocation_keyflex_id,
                   p_amount                      => g_period_amt_tab(i).amount2,
                   p_currency_code               => g_currency_code2
                  );
               ELSE
                 -- insert into pqh_gl_interface
                  insert_pqh_gl_interface
                  (
                   p_budget_detail_id            => p_budget_detail_id,
                   p_period_name                 => g_period_amt_tab(i).period_name,
                   p_accounting_date             => g_period_amt_tab(i).accounting_date,
                   p_code_combination_id         => g_period_amt_tab(i).code_combination_id,
                   p_cost_allocation_keyflex_id  => g_period_amt_tab(i).cost_allocation_keyflex_id,
                   p_amount                      => g_period_amt_tab(i).amount2,
                   p_currency_code               => g_currency_code2
                  );
               END IF;  -- l_uom2_count <> 0

          END IF; -- g_currency_code2 IS NOT NULL  and amt2 <> 0


       -- for UOM3 i.e g_currency_code3

          IF (g_currency_code3 IS NOT NULL) AND (g_period_amt_tab(i).amount3 <> 0) THEN
             OPEN csr_pqh_interface(p_period_name => g_period_amt_tab(i).period_name,
                                    p_code_combination_id => g_period_amt_tab(i).code_combination_id,
                                    p_currency_code   => g_currency_code3 );
                  FETCH csr_pqh_interface INTO l_uom3_count;
             CLOSE  csr_pqh_interface;

               IF l_uom3_count <> 0 THEN
                -- update pqh_gl_interface and create a adjustment txn
                  update_pqh_gl_interface
                  (
                   p_budget_detail_id            => p_budget_detail_id,
                   p_period_name                 => g_period_amt_tab(i).period_name,
                   p_accounting_date             => g_period_amt_tab(i).accounting_date,
                   p_code_combination_id         => g_period_amt_tab(i).code_combination_id,
                   p_cost_allocation_keyflex_id  => g_period_amt_tab(i).cost_allocation_keyflex_id,
                   p_amount                      => g_period_amt_tab(i).amount3,
                   p_currency_code               => g_currency_code3
                  );
               ELSE
                 -- insert into pqh_gl_interface
                  insert_pqh_gl_interface
                  (
                   p_budget_detail_id            => p_budget_detail_id,
                   p_period_name                 => g_period_amt_tab(i).period_name,
                   p_accounting_date             => g_period_amt_tab(i).accounting_date,
                   p_code_combination_id         => g_period_amt_tab(i).code_combination_id,
                   p_cost_allocation_keyflex_id  => g_period_amt_tab(i).cost_allocation_keyflex_id,
                   p_amount                      => g_period_amt_tab(i).amount3,
                   p_currency_code               => g_currency_code3
                  );
               END IF;  -- l_uom3_count <> 0

          END IF; -- g_currency_code3 IS NOT NULL  and amt3 <> 0





      END IF; -- Insert only GL records
     END LOOP; -- end of pl sql table

      -- update pqh_budget_details reset status if previous run was ERROR
      UPDATE pqh_budget_details
         SET gl_status = ''
       WHERE budget_detail_id = p_budget_detail_id;



  ELSE  -- g_detail_error = Y i.e errors in budget details children

      -- update pqh_budget_details
      UPDATE pqh_budget_details
         SET gl_status = 'ERROR'
       WHERE budget_detail_id = p_budget_detail_id;

  END IF; -- g_detail_error = 'N'

  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END populate_pqh_gl_interface;



-- ----------------------------------------------------------------------------
PROCEDURE insert_pqh_gl_interface
(
 p_budget_detail_id            IN  pqh_gl_interface.budget_detail_id%TYPE,
 p_period_name                 IN  pqh_gl_interface.period_name%TYPE,
 p_accounting_date             IN  pqh_gl_interface.accounting_date%TYPE,
 p_code_combination_id         IN  pqh_gl_interface.code_combination_id%TYPE,
 p_cost_allocation_keyflex_id  IN  pqh_gl_interface.cost_allocation_keyflex_id%TYPE,
 p_amount                      IN  pqh_gl_interface.amount_dr%TYPE,
 p_currency_code               IN  pqh_gl_interface.currency_code%TYPE
 ) IS
 /*
  This procedure will insert record into pqh_gl_interface
  If the same UOM is repeated more then once then we would update the unposted txn.
 */
 --
-- local variables
--
 l_proc                         varchar2(72) := g_package||'.insert_pqh_gl_interface';
 l_count                        number(9) := 0 ;

 CURSOR csr_pqh_gl_interface IS
 SELECT COUNT(*)
  FROM pqh_gl_interface
 WHERE budget_version_id    = g_budget_version_id
   AND budget_detail_id     = p_budget_detail_id
   AND posting_type_cd      = 'BUDGET'
   AND period_name          = p_period_name
   AND code_combination_id  = p_code_combination_id
   AND currency_code        = p_currency_code
   AND NVL(adjustment_flag,'N') = 'N'
   AND status IS NULL
   AND posting_date IS NULL;

BEGIN

  hr_utility.set_location('Entering: '||l_proc, 5);
    -- check if its a repeat of that same UOM
       OPEN csr_pqh_gl_interface;
         FETCH csr_pqh_gl_interface INTO l_count;
       CLOSE csr_pqh_gl_interface;

  hr_utility.set_location('l_count in Insert pqh_gl_interface : '||l_count,10);

 IF l_count <> 0 THEN

  -- this is a repeat of UOM , so update the first one adding the new amount
    UPDATE pqh_gl_interface
 -- ns since the record is new, the current amount is actual amount
 -- no need to add to previous amount
 --      SET AMOUNT_DR = NVL(AMOUNT_DR,0) + NVL(p_amount,0)
       SET AMOUNT_DR = NVL(p_amount,0)
     WHERE budget_version_id    = g_budget_version_id
       AND budget_detail_id     = p_budget_detail_id
       AND posting_type_cd      = 'BUDGET'
       AND period_name          = p_period_name
       AND code_combination_id  = p_code_combination_id
       AND currency_code        = p_currency_code
       AND NVL(adjustment_flag,'N') = 'N'
       AND status IS NULL
       AND posting_date IS NULL;

 ELSE

   -- insert this record
     INSERT INTO pqh_gl_interface
     (
       gl_interface_id,
       budget_version_id,
       budget_detail_id,
       period_name,
       accounting_date,
       code_combination_id,
       cost_allocation_keyflex_id,
       amount_dr,
       amount_cr,
       currency_code,
       status,
       adjustment_flag,
       posting_date,
       posting_type_cd
     )
     VALUES
     (
       pqh_gl_interface_s.nextval,
       g_budget_version_id,
       p_budget_detail_id,
       p_period_name,
       p_accounting_date,
       p_code_combination_id,
       p_cost_allocation_keyflex_id,
       NVL(p_amount,0),
       0,
       p_currency_code,
       null,
       null,
       null,
       'BUDGET'
     );

 END IF;  -- l_count <> 0 UOM repeated


  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END insert_pqh_gl_interface;

-- ----------------------------------------------------------------------------
PROCEDURE update_pqh_gl_interface
(
 p_budget_detail_id            IN  pqh_gl_interface.budget_detail_id%TYPE,
 p_period_name                 IN  pqh_gl_interface.period_name%TYPE,
 p_accounting_date             IN  pqh_gl_interface.accounting_date%TYPE,
 p_code_combination_id         IN  pqh_gl_interface.code_combination_id%TYPE,
 p_cost_allocation_keyflex_id  IN  pqh_gl_interface.cost_allocation_keyflex_id%TYPE,
 p_amount                      IN  pqh_gl_interface.amount_dr%TYPE,
 p_currency_code               IN  pqh_gl_interface.currency_code%TYPE
 ) IS
 /*
  This procedure will update pqh_gl_interface and create a adjustment record
 */
 --
-- local variables
--
 l_proc                         varchar2(72) := g_package||'.update_pqh_gl_interface';
 l_amount_diff                  pqh_gl_interface.amount_dr%TYPE :=0;
 l_amount_dr                    pqh_gl_interface.amount_dr%TYPE :=0;
 l_amount_cr                    pqh_gl_interface.amount_cr%TYPE :=0;
 l_pqh_gl_interface_rec         pqh_gl_interface%ROWTYPE;


 CURSOR csr_pqh_gl_interface IS
 SELECT *
  FROM pqh_gl_interface
 WHERE budget_version_id    = g_budget_version_id
   AND budget_detail_id     = p_budget_detail_id
   AND posting_type_cd      = 'BUDGET'
   AND period_name          = p_period_name
   AND code_combination_id  = p_code_combination_id
   AND currency_code        = p_currency_code
   AND NVL(adjustment_flag,'N') = 'N'
   AND status IS NOT NULL
   AND posting_date IS NOT NULL
  FOR UPDATE of amount_dr;

BEGIN

  hr_utility.set_location('Entering: '||l_proc, 5);

    OPEN csr_pqh_gl_interface;
      FETCH csr_pqh_gl_interface INTO l_pqh_gl_interface_rec;

       l_amount_diff := NVL(p_amount,0) - NVL(l_pqh_gl_interface_rec.amount_dr,0);

        IF l_amount_diff > 0 THEN
          -- debit as new is more then old
           l_amount_dr := l_amount_diff;
        ELSE
          -- credit as new is less then old
          l_amount_cr := (-1)*l_amount_diff;
        END IF;


         -- update the pqh_gl_interface table
           UPDATE pqh_gl_interface
              SET amount_dr = NVL(p_amount,0)
            WHERE CURRENT OF csr_pqh_gl_interface;


     CLOSE csr_pqh_gl_interface;

      -- create i.e insert a adjustment record ONLY if l_amount_diff <> 0
     IF NVL(l_amount_diff,0) <> 0 THEN

       INSERT INTO pqh_gl_interface
       (
         gl_interface_id,
         budget_version_id,
         budget_detail_id,
         period_name,
         accounting_date,
         code_combination_id,
         cost_allocation_keyflex_id,
         amount_dr,
         amount_cr,
         currency_code,
         status,
         adjustment_flag,
         posting_date,
         posting_type_cd
       )
       VALUES
       (
         pqh_gl_interface_s.nextval,
         g_budget_version_id,
         p_budget_detail_id,
         p_period_name,
         p_accounting_date,
         p_code_combination_id,
         p_cost_allocation_keyflex_id,
         NVL(l_amount_dr,0),
         NVL(l_amount_cr,0),
         p_currency_code,
         null,
         'Y',
         null,
         'BUDGET'
       );

     END IF; -- create i.e insert a adjustment record ONLY if l_amount_diff <> 0


  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END update_pqh_gl_interface;

-- ----------------------------------------------------------------------------
PROCEDURE populate_gl_tables
IS
/*
  This procedure will pick records from pqh_gl_interface table and insert them into
  gl tables depending on the g_budgetary_control_flag
  If we insert into gl_bc_packets do funds checking for each packet
*/
--
-- local variables
--
 l_proc                         varchar2(72) := g_package||'.populate_gl_tables';
 l_pqh_gl_interface_rec         pqh_gl_interface%ROWTYPE;
 l_period_name                  pqh_gl_interface.period_name%TYPE;
 l_accounting_date              pqh_gl_interface.accounting_date%TYPE;
 l_code_combination_id          pqh_gl_interface.code_combination_id%TYPE;
 l_cost_allocation_keyflex_id   pqh_gl_interface.cost_allocation_keyflex_id%TYPE;
 l_currency_code                pqh_gl_interface.currency_code%TYPE;
 l_amount_dr                    pqh_gl_interface.amount_dr%TYPE;
 l_amount_cr                    pqh_gl_interface.amount_cr%TYPE;
 l_packet_id                    gl_bc_packets.packet_id%TYPE;
 l_gl_period_statuses_rec       gl_period_statuses%ROWTYPE;
 l_fc_success                   boolean;
 l_fc_return                    varchar2(100);
 l_fc_mode                      varchar2(100);
 l_fc_message                   varchar2(8000);
 l_log_context                  varchar2(255);
 l_packet_result_code           varchar2(255);
 l_packet_status_code           varchar2(255);

 CURSOR csr_pqh_gl_interface IS
 SELECT period_name, accounting_date,
        code_combination_id, cost_allocation_keyflex_id, currency_code,
        SUM(NVL(amount_dr,0))  amount_dr,
        SUM(NVL(amount_cr,0))  amount_cr
 FROM pqh_gl_interface
 WHERE budget_version_id IN (g_budget_version_id, NVL(g_last_posted_ver,0) )
   AND status IS NULL
   AND posting_date IS NULL
   AND posting_type_cd = 'BUDGET'
   AND cost_allocation_keyflex_id is NOT NULL
 GROUP BY period_name, accounting_date,code_combination_id,
          cost_allocation_keyflex_id,currency_code;

 CURSOR csr_packet_id IS
 SELECT gl_bc_packets_s.nextval
 FROM dual;

 CURSOR csr_period_name( p_period_name  IN varchar2 ) IS
 SELECT *
 FROM  gl_period_statuses
 WHERE application_id = g_application_id
   AND set_of_books_id = g_set_of_books_id
   AND period_name  = p_period_name;

 CURSOR csr_gl_lookups(p_lookup_code IN varchar2 ) IS
 SELECT description
 FROM gl_lookups
 WHERE lookup_type = 'FUNDS_CHECK_RESULT_CODE'
   AND lookup_code = p_lookup_code
   AND NVL(enabled_flag,'N') = 'Y';

 CURSOR csr_gl_packet_code(p_packet_id IN number ) IS
 SELECT result_code
 FROM gl_bc_packets
 WHERE packet_id = p_packet_id;

 CURSOR csr_gl_status(p_lookup_code IN varchar2 ) IS
 SELECT description
 FROM gl_lookups
 WHERE lookup_type = 'FUNDS_CHECK_STATUS_CODE'
   AND lookup_code = p_lookup_code
   AND NVL(enabled_flag,'N') = 'Y';

BEGIN

  hr_utility.set_location('Entering: '||l_proc, 5);

  IF g_budgetary_control_flag = 'Y' THEN
    -- insert into gl_bc_packets and do funds checking for each packet

      hr_utility.set_location('Inserting into GL_BC_PACKETS',10);

    OPEN csr_pqh_gl_interface;
      LOOP
        FETCH csr_pqh_gl_interface INTO l_period_name, l_accounting_date,
              l_code_combination_id, l_cost_allocation_keyflex_id, l_currency_code,
              l_amount_dr, l_amount_cr;
        EXIT WHEN csr_pqh_gl_interface%NOTFOUND;

          -- Get Packet ID
          OPEN csr_packet_id;
            FETCH csr_packet_id INTO l_packet_id;
          CLOSE csr_packet_id;

          -- get period details
          OPEN csr_period_name(p_period_name => l_period_name);
            FETCH csr_period_name INTO l_gl_period_statuses_rec;
          CLOSE csr_period_name;

              -- compute the GL funds checker Mode
              IF g_validate THEN
                -- this is validate ONLY mode
                 l_fc_mode := 'C';
              ELSIF NVL(l_amount_dr,0) > 0 THEN
                -- this is debit so run fund checker in reserved mode
                 l_fc_mode := 'P';    -- Changed from 'R' to 'P' for 4554281
              ELSE
                 -- this is credit so run fund checker in unreserved mode
                 l_fc_mode := 'U';
              END IF;
/*
     ------------------------------------------------------------------------------------------------
              Insert in gl_bc_packets and Call the GL funds checker
              The  GL funds checker program has COMMIT inside the program so we cannot rollback
              The  GL funds checker is only called when the validate flag is false i.e no validation
             -- do funds checking for each packet
             -- Mode = R (reserved) if amount is dr
             -- Mode = U (unreserved) if amount is cr
             -- Mode = C (Checking) if program is run in validate mode i.e g_validate = TRUE
             -- Mode C is never called as there as explicit commits in GL funds checker program , so
             -- we call the GL funds checker program only when p_validate is FALSE in R or U mode
     ------------------------------------------------------------------------------------------------
*/
              -- Insert in gl_bc_packets and run funds checker
              hr_utility.set_location('Calling ins_gl_bc_run_fund_check with fund checker Mode : '||l_fc_mode,100);

              ins_gl_bc_run_fund_check
                 ( p_packet_id            =>   l_packet_id
                  ,p_code_combination_id  =>   l_code_combination_id
                  ,p_period_name          =>   l_period_name
                  ,p_period_year          =>   l_gl_period_statuses_rec.period_year
                  ,p_period_num           =>   l_gl_period_statuses_rec.period_num
                  ,p_quarter_num          =>   l_gl_period_statuses_rec.quarter_num
                  ,p_currency_code        =>   l_currency_code
                  ,p_entered_dr           =>   NVL(l_amount_dr,0)
                  ,p_entered_cr           =>   NVL(l_amount_cr,0)
                  ,p_accounted_dr         =>   NVL(l_amount_dr,0)
                  ,p_accounted_cr         =>   NVL(l_amount_cr,0)
                  ,p_cost_allocation_keyflex_id  =>   l_cost_allocation_keyflex_id
                  ,p_fc_mode              =>   l_fc_mode
                  ,p_fc_success           =>   l_fc_success
                  ,p_fc_return            =>   l_fc_return
                  );

              hr_utility.set_location('GL Fund Checker return Code : '||l_fc_return,110);

              -- get the return code desc from GL lookups
               OPEN csr_gl_status(p_lookup_code => l_fc_return);
                 FETCH csr_gl_status INTO l_packet_status_code;
               CLOSE csr_gl_status;

              hr_utility.set_location('GL Fund Checker return Code Desc : '||l_packet_status_code,111);

/*

-----------------------------------------------------------------------------------------------------
  If the fund checker program failed i.e l_fc_success = FALSE or l_fc_return in ('T', 'F','R') then we
  would do the following :

1. Put the error message in pqh_process_log ( context : Period Name + CCID + currency code )

2. update all the budget_detail records which have this Period Name + CCID + currency code to ERROR ( gl_status)

3. Reverse unposted adjustment txns in pqh_gl_interface

4. Delete all unposted non-adjustment txns from pqh_gl_interface
-----------------------------------------------------------------------------------------------------

*/

           IF NOT ( l_fc_success )  OR
              ( NVL(l_fc_return,'T') in ('T', 'F','R') ) THEN
              -- fund checker failed

               hr_utility.set_location('Fund Checker Failed ',120);

              -----------------------------------------------------------------
              -- STEP 1: Log the Error Message
              -----------------------------------------------------------------
              -- get the error message which is populated in case of fatal error i.e l_fc_return = T
                 l_fc_message := fnd_message.get;

               -- if the above error message is null then get from result code
                 IF l_fc_message IS NULL THEN
                    OPEN csr_gl_packet_code(p_packet_id => l_packet_id);
                      FETCH csr_gl_packet_code INTO l_packet_result_code;
                    CLOSE csr_gl_packet_code;

                    OPEN csr_gl_lookups(p_lookup_code => l_packet_result_code);
                      FETCH csr_gl_lookups INTO l_fc_message;
                    CLOSE csr_gl_lookups;
                 END IF;

               hr_utility.set_location('Fund Chk Error : '||substr(l_fc_message,1,50),120);

              -- set the log context and insert into log
                 l_log_context := l_period_name||' - '||l_code_combination_id||' - '||l_currency_code;

               hr_utility.set_location('Log Context : '||l_log_context,130);

              -- set the context
                 pqh_process_batch_log.set_context_level
                 (
                  p_txn_id                =>  l_packet_id,
                  p_txn_table_route_id    =>  g_table_route_id_glf,
                  p_level                 =>  1,
                  p_log_context           =>  l_log_context
                  );

               -- insert error
                 pqh_process_batch_log.insert_log
                 (
                  p_message_type_cd    =>  'ERROR',
                  p_message_text       =>  l_packet_status_code||' : '||l_fc_message
                 );


               hr_utility.set_location('Inserted Error and calling reverse txn ',140);

              -----------------------------------------------------------------
              -- STEP 2 ,3 , 4
              -----------------------------------------------------------------
               reverse_budget_details
               (
                p_period_name             => l_period_name ,
                p_currency_code           => l_currency_code ,
                p_code_combination_id     => l_code_combination_id
               );
              -----------------------------------------------------------------



           END IF; -- Fund checker Error









      END LOOP;
    CLOSE csr_pqh_gl_interface;

  ELSE
    -- insert into gl_interface
      hr_utility.set_location('Inserting into GL_INTERFACE',200);

    OPEN csr_pqh_gl_interface;
      LOOP
        FETCH csr_pqh_gl_interface INTO l_period_name, l_accounting_date,
              l_code_combination_id, l_cost_allocation_keyflex_id, l_currency_code,
              l_amount_dr, l_amount_cr;
        EXIT WHEN csr_pqh_gl_interface%NOTFOUND;

          INSERT INTO gl_interface
               (status,
                set_of_books_id,
                user_je_source_name,
                user_je_category_name,
                currency_code,
                date_created,
                created_by,
                actual_flag,
                budget_version_id,
                accounting_date,
                period_name,
                code_combination_id,
                chart_of_accounts_id,
                entered_dr,
                entered_cr,
                reference1,
                reference2)
           VALUES
               ('NEW',
                g_set_of_books_id,
                g_user_je_source_name,
                g_user_je_category_name,
                l_currency_code,
                sysdate,
                8302,
                'B',
                g_gl_budget_version_id,
                l_accounting_date,
                l_period_name,
                l_code_combination_id,
                g_chart_of_accounts_id,
                NVL(l_amount_dr,0),
                NVL(l_amount_cr,0),
                g_budget_version_id,
                l_cost_allocation_keyflex_id);

      END LOOP;
    CLOSE csr_pqh_gl_interface;

  END IF;




  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END populate_gl_tables;

-- ----------------------------------------------------------------------------
PROCEDURE update_gl_status
IS
/*
  This procedure will update the gl_status of pqh_budget_versions, pqh_budget_details
  and update the pqh_gl_interface table

  We always update the TRANSFERED_TO_GL_FLAG = Y to indicate this is the latest budget_version that is posted to GL
  gl_status = POST or ERROR
*/

--
-- local variables
--
 l_proc                         varchar2(72) := g_package||'.update_gl_status';
 l_budget_details_rec           pqh_budget_details%ROWTYPE;
 l_count                        NUMBER;

 CURSOR csr_budget_details IS
 SELECT *
 FROM pqh_budget_details
 WHERE budget_version_id = g_budget_version_id
   AND NVL(gl_status,'X') <> 'ERROR'
  FOR UPDATE OF gl_status;

 CURSOR csr_budget_details_cnt IS
 SELECT COUNT(*)
 FROM pqh_budget_details
  WHERE budget_version_id = g_budget_version_id
   AND NVL(gl_status,'ERROR') = 'ERROR';

BEGIN

  hr_utility.set_location('Entering: '||l_proc, 5);

  -- update pqh_budget_details
  OPEN csr_budget_details;
    LOOP
      FETCH csr_budget_details INTO l_budget_details_rec;
      EXIT WHEN csr_budget_details%NOTFOUND;
        UPDATE pqh_budget_details
        SET gl_status = 'POST'
        WHERE CURRENT OF csr_budget_details;
    END LOOP;
  CLOSE csr_budget_details;

  -- update pqh_budget_versions and the program out variable
   OPEN csr_budget_details_cnt;
     FETCH csr_budget_details_cnt INTO l_count;
   CLOSE csr_budget_details_cnt;

   IF NVL(l_count,0) = 0 THEN
     -- no errors
     -- mvankada
     IF pqh_gl_posting.chk_budget_details(p_budget_version_id => g_budget_version_id ) = 'Y'    THEN
      UPDATE pqh_budget_versions
      SET gl_status = 'POST',
          transfered_to_gl_flag = 'Y'
      WHERE budget_version_id = g_budget_version_id;

      -- set the OUT variable to SUCCESS
        g_status := 'SUCCESS';
      END IF;
   ELSE
     -- there were errors in details
      UPDATE pqh_budget_versions
      SET gl_status = 'ERROR',
          transfered_to_gl_flag = 'Y'
      WHERE budget_version_id = g_budget_version_id;

      -- set the OUT variable to ERROR
        g_status := 'ERROR';
   END IF;

  hr_utility.set_location('Budget Details Error Count : '||l_count, 100);

  -- mvankada
 IF pqh_gl_posting.chk_budget_details(p_budget_version_id => g_budget_version_id ) = 'Y'    THEN
   -- update the pqh_gl_interface table
   UPDATE pqh_gl_interface
   SET posting_date = sysdate,
       status       = 'POST'
   WHERE budget_version_id = g_budget_version_id
     AND posting_type_cd = 'BUDGET'
     AND posting_date IS NULL
     AND status       IS NULL;

   -- update the pqh_gl_interface table for last posted version
   UPDATE pqh_gl_interface
   SET posting_date = sysdate,
       status       = 'POST'
   WHERE budget_version_id = NVL(g_last_posted_ver,0)
     AND posting_type_cd = 'BUDGET'
     AND posting_date IS NULL
     AND status       IS NULL;
 END IF;

  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END update_gl_status;

-- ----------------------------------------------------------------------------

PROCEDURE get_gl_ccid
(
  p_budget_detail_id             IN    pqh_budget_details.budget_detail_id%TYPE,
  p_budget_period_id             IN   pqh_budget_periods.budget_period_id%TYPE,
  p_cost_allocation_keyflex_id   IN    pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE,
  p_code_combination_id          OUT   NOCOPY gl_code_combinations.code_combination_id%TYPE
) IS
/*
  This procedure will return the code_combination_id  from gl_code_combinations corresponding to the
  cost_allocation_keyflex_id. The mapping between the gl segments and cost_allocation_keyflex segments is
  stored in pqh_gl_flex_maps table corresponding to the current budget.

  First we will check to see if there are any defaults set for cost segments and if so populate the
  g_seg_val_tab with the defaults. Defaults are checks at the following level :
  payroll  1st level , we will first initialize the g_seg_val_tab and then get the defaults if any.
  element_link 2nd level, if for the position and element_type_id there are any defaults in the
  pay_element_links table , we only assign values for segments which are not null .
  organization 3rd level which will override the 1st level . At this level we only assign values
  which are not null

  The budget funding src level will override the above default values.
  AT the budget funding src level we only assign values which are not null

*/
--
-- local variables
--
 l_proc                         varchar2(72) := g_package||'.get_gl_ccid';
 l_pay_cost_allocation_rec      pay_cost_allocation_keyflex%ROWTYPE;
 l_pqh_budget_gl_flex_maps_rec  pqh_budget_gl_flex_maps%ROWTYPE;
 i                              BINARY_INTEGER :=1;
 l_where_str                    varchar2(8000) ;
 sql_stmt                       varchar2(8000) := '';

 TYPE SegCurTyp   IS REF CURSOR;
 seg_cv           SegCurTyp;
 l_gl_cc_rec      gl_code_combinations%ROWTYPE;
 l_gl_cc_count    number ;


 CURSOR csr_cost_segments IS
 SELECT *
 FROM pay_cost_allocation_keyflex
 WHERE cost_allocation_keyflex_id = p_cost_allocation_keyflex_id;


 CURSOR csr_map_segments IS
 SELECT *
 FROM pqh_budget_gl_flex_maps
 WHERE budget_id = g_budget_id ;

BEGIN

  hr_utility.set_location('Entering: '||l_proc, 5);

  -- get defaults at Payroll level
     get_payroll_defaults
     (
      p_budget_detail_id        =>  p_budget_detail_id
     );

  -- get defaults at element_link level
     get_element_link_defaults
     (
      p_budget_detail_id         =>  p_budget_detail_id,
      p_budget_period_id         =>  p_budget_period_id
     );

  -- get defaults at Organization level
    get_organization_defaults
    (
     p_budget_detail_id         =>   p_budget_detail_id
    );


  --
    OPEN csr_cost_segments;
      FETCH csr_cost_segments INTO l_pay_cost_allocation_rec;
    CLOSE csr_cost_segments;

  -- populate the g_seg_val_tab with the segment values
  -- assign only the NOT NULL segments so that defaults at Payroll and Organization are not erased
  --
  -- g_seg_val_tab will have all the 30 segment names and their values
  --
     g_seg_val_tab(1).cost_segment_name  := 'SEGMENT1';
     g_seg_val_tab(1).segment_value      := NVL(l_pay_cost_allocation_rec.segment1,g_seg_val_tab(1).segment_value);
     g_seg_val_tab(2).cost_segment_name  := 'SEGMENT2';
     g_seg_val_tab(2).segment_value      := NVL(l_pay_cost_allocation_rec.segment2,g_seg_val_tab(2).segment_value);
     g_seg_val_tab(3).cost_segment_name  := 'SEGMENT3';
     g_seg_val_tab(3).segment_value      := NVL(l_pay_cost_allocation_rec.segment3,g_seg_val_tab(3).segment_value);
     g_seg_val_tab(4).cost_segment_name  := 'SEGMENT4';
     g_seg_val_tab(4).segment_value      := NVL(l_pay_cost_allocation_rec.segment4,g_seg_val_tab(4).segment_value);
     g_seg_val_tab(5).cost_segment_name  := 'SEGMENT5';
     g_seg_val_tab(5).segment_value      := NVL(l_pay_cost_allocation_rec.segment5,g_seg_val_tab(5).segment_value);
     g_seg_val_tab(6).cost_segment_name  := 'SEGMENT6';
     g_seg_val_tab(6).segment_value      := NVL(l_pay_cost_allocation_rec.segment6,g_seg_val_tab(6).segment_value);
     g_seg_val_tab(7).cost_segment_name  := 'SEGMENT7';
     g_seg_val_tab(7).segment_value      := NVL(l_pay_cost_allocation_rec.segment7,g_seg_val_tab(7).segment_value);
     g_seg_val_tab(8).cost_segment_name  := 'SEGMENT8';
     g_seg_val_tab(8).segment_value      := NVL(l_pay_cost_allocation_rec.segment8,g_seg_val_tab(8).segment_value);
     g_seg_val_tab(9).cost_segment_name  := 'SEGMENT9';
     g_seg_val_tab(9).segment_value      := NVL(l_pay_cost_allocation_rec.segment9,g_seg_val_tab(9).segment_value);
     g_seg_val_tab(10).cost_segment_name  := 'SEGMENT10';
     g_seg_val_tab(10).segment_value      := NVL(l_pay_cost_allocation_rec.segment10,g_seg_val_tab(10).segment_value);
     g_seg_val_tab(11).cost_segment_name  := 'SEGMENT11';
     g_seg_val_tab(11).segment_value      := NVL(l_pay_cost_allocation_rec.segment11,g_seg_val_tab(11).segment_value);
     g_seg_val_tab(12).cost_segment_name  := 'SEGMENT12';
     g_seg_val_tab(12).segment_value      := NVL(l_pay_cost_allocation_rec.segment12,g_seg_val_tab(12).segment_value);
     g_seg_val_tab(13).cost_segment_name  := 'SEGMENT13';
     g_seg_val_tab(13).segment_value      := NVL(l_pay_cost_allocation_rec.segment13,g_seg_val_tab(13).segment_value);
     g_seg_val_tab(14).cost_segment_name  := 'SEGMENT14';
     g_seg_val_tab(14).segment_value      := NVL(l_pay_cost_allocation_rec.segment14,g_seg_val_tab(14).segment_value);
     g_seg_val_tab(15).cost_segment_name  := 'SEGMENT15';
     g_seg_val_tab(15).segment_value      := NVL(l_pay_cost_allocation_rec.segment15,g_seg_val_tab(15).segment_value);
     g_seg_val_tab(16).cost_segment_name  := 'SEGMENT16';
     g_seg_val_tab(16).segment_value      := NVL(l_pay_cost_allocation_rec.segment16,g_seg_val_tab(16).segment_value);
     g_seg_val_tab(17).cost_segment_name  := 'SEGMENT17';
     g_seg_val_tab(17).segment_value      := NVL(l_pay_cost_allocation_rec.segment17,g_seg_val_tab(17).segment_value);
     g_seg_val_tab(18).cost_segment_name  := 'SEGMENT18';
     g_seg_val_tab(18).segment_value      := NVL(l_pay_cost_allocation_rec.segment18,g_seg_val_tab(18).segment_value);
     g_seg_val_tab(19).cost_segment_name  := 'SEGMENT19';
     g_seg_val_tab(19).segment_value      := NVL(l_pay_cost_allocation_rec.segment19,g_seg_val_tab(19).segment_value);
     g_seg_val_tab(20).cost_segment_name  := 'SEGMENT20';
     g_seg_val_tab(20).segment_value      := NVL(l_pay_cost_allocation_rec.segment20,g_seg_val_tab(20).segment_value);
     g_seg_val_tab(21).cost_segment_name  := 'SEGMENT21';
     g_seg_val_tab(21).segment_value      := NVL(l_pay_cost_allocation_rec.segment21,g_seg_val_tab(21).segment_value);
     g_seg_val_tab(22).cost_segment_name  := 'SEGMENT22';
     g_seg_val_tab(22).segment_value      := NVL(l_pay_cost_allocation_rec.segment22,g_seg_val_tab(22).segment_value);
     g_seg_val_tab(23).cost_segment_name  := 'SEGMENT23';
     g_seg_val_tab(23).segment_value      := NVL(l_pay_cost_allocation_rec.segment23,g_seg_val_tab(23).segment_value);
     g_seg_val_tab(24).cost_segment_name  := 'SEGMENT24';
     g_seg_val_tab(24).segment_value      := NVL(l_pay_cost_allocation_rec.segment24,g_seg_val_tab(24).segment_value);
     g_seg_val_tab(25).cost_segment_name  := 'SEGMENT25';
     g_seg_val_tab(25).segment_value      := NVL(l_pay_cost_allocation_rec.segment25,g_seg_val_tab(25).segment_value);
     g_seg_val_tab(26).cost_segment_name  := 'SEGMENT26';
     g_seg_val_tab(26).segment_value      := NVL(l_pay_cost_allocation_rec.segment26,g_seg_val_tab(26).segment_value);
     g_seg_val_tab(27).cost_segment_name  := 'SEGMENT27';
     g_seg_val_tab(27).segment_value      := NVL(l_pay_cost_allocation_rec.segment27,g_seg_val_tab(27).segment_value);
     g_seg_val_tab(28).cost_segment_name  := 'SEGMENT28';
     g_seg_val_tab(28).segment_value      := NVL(l_pay_cost_allocation_rec.segment28,g_seg_val_tab(28).segment_value);
     g_seg_val_tab(29).cost_segment_name  := 'SEGMENT29';
     g_seg_val_tab(29).segment_value      := NVL(l_pay_cost_allocation_rec.segment29,g_seg_val_tab(29).segment_value);
     g_seg_val_tab(30).cost_segment_name  := 'SEGMENT30';
     g_seg_val_tab(30).segment_value      := NVL(l_pay_cost_allocation_rec.segment30,g_seg_val_tab(30).segment_value);


  hr_utility.set_location('Populated g_seg_val_tab ', 10);


  --   populate the g_map_tab for the current budget id

     OPEN csr_map_segments;
       LOOP
          FETCH csr_map_segments INTO l_pqh_budget_gl_flex_maps_rec;
          EXIT WHEN csr_map_segments%NOTFOUND;
            g_map_tab(i).gl_segment_name   := l_pqh_budget_gl_flex_maps_rec.GL_ACCOUNT_SEGMENT;
            g_map_tab(i).cost_segment_name := l_pqh_budget_gl_flex_maps_rec.PAYROLL_COST_SEGMENT;
            g_map_tab(i).segment_value     := get_value_from_array ( p_segment_name  => l_pqh_budget_gl_flex_maps_rec.PAYROLL_COST_SEGMENT);

            hr_utility.set_location('i : '||i,11);
            hr_utility.set_location('gl_segment_name: '||g_map_tab(i).gl_segment_name, 15);
            hr_utility.set_location('cost_segment_name: '||g_map_tab(i).cost_segment_name , 20);
            hr_utility.set_location('segment_value: '||g_map_tab(i).segment_value, 25);


           i := i + 1;


       END LOOP;
     CLOSE csr_map_segments;

  --

  -- build the dynamic select for fetching the gl cc id

    IF NVL(g_map_tab.COUNT,0) <> 0 THEN
    -- loop thru the array and get the value in column 3 corresponding to col name
      FOR i IN NVL(g_map_tab.FIRST,0)..NVL(g_map_tab.LAST,-1)
      LOOP
           IF NVL(l_where_str,'X') = 'X'  THEN
             l_where_str := l_where_str ||g_map_tab(i).gl_segment_name||' = '||''''||g_map_tab(i).segment_value||''''||' ';
           ELSE
             l_where_str := l_where_str||' and '||g_map_tab(i).gl_segment_name||' = '||''''||g_map_tab(i).segment_value||''''||' ';
           END IF;
      END LOOP;
    END IF;

    hr_utility.set_location('Built dynamic select ',26);
    --
      sql_stmt := 'SELECT * FROM  gl_code_combinations WHERE  chart_of_accounts_id = :g_chart_of_accounts_id and '||l_where_str ;

    hr_utility.set_location('sql stmt : '||substr(sql_stmt,1,50),27);
    hr_utility.set_location('sql stmt : '||substr(sql_stmt,51,50),27);
    hr_utility.set_location('sql stmt : '||substr(sql_stmt,101,50),27);
    hr_utility.set_location('sql stmt : '||substr(sql_stmt,151,50),27);
    hr_utility.set_location('sql stmt : '||substr(sql_stmt,200,50),27);


      OPEN seg_cv FOR sql_stmt using g_chart_of_accounts_id ;
        FETCH seg_cv INTO l_gl_cc_rec;
        l_gl_cc_count := seg_cv%rowcount ;
      CLOSE seg_cv;

    hr_utility.set_location('Rows returned from gl_code_combination:'||l_gl_cc_count||':',31);
    hr_utility.set_location('Cursor closed ',31);
    --

    -- populate the out variable
       p_code_combination_id := l_gl_cc_rec.code_combination_id;

  hr_utility.set_location('CC ID :'||p_code_combination_id, 100);


  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END get_gl_ccid;


-- ----------------------------------------------------------------------------


    /*----------------------------------------------------------------
    || FUNCTION : get_value_from_array
    ||
    ------------------------------------------------------------------*/



FUNCTION get_value_from_array ( p_segment_name  IN  varchar2 )
  RETURN VARCHAR2 IS
/*
   This function would loop thru the g_seg_val_tab and would return the segment value for the
   segment name given as input
*/
--
-- local variables
--
 l_proc          varchar2(72) := g_package||'.get_value_from_array';
 l_col_val       VARCHAR2(8000);




BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);

  hr_utility.set_location('Seg Name : '||p_segment_name, 6);

  IF NVL(g_seg_val_tab.COUNT,0) <> 0 THEN
    -- loop thru the array and get the segment value
     FOR i IN NVL(g_seg_val_tab.FIRST,0)..NVL(g_seg_val_tab.LAST,-1)
     LOOP
        IF UPPER(g_seg_val_tab(i).cost_segment_name) = UPPER(p_segment_name)  THEN
           l_col_val := g_seg_val_tab(i).segment_value;
           EXIT; -- exit the loop as the column is found
        END IF;
     END LOOP;
  END IF;


  l_col_val := l_col_val;

  hr_utility.set_location('Col Val : '||l_col_val, 10);
  hr_utility.set_location('Leaving:'||l_proc, 1000);

  return l_col_val;

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END get_value_from_array;



-- ----------------------------------------------------------------------------


PROCEDURE get_gl_period
(
  p_budget_period_id              IN   pqh_budget_periods.budget_period_id%TYPE,
  p_gl_period_statuses_rec        OUT  NOCOPY gl_period_statuses%ROWTYPE
) IS
/*
  This procedure will return the period name corresponding to start_date between
  gl_period_statuses.start_date and gl_period_statuses.end_date
*/
--
-- local variables
--
 l_proc                     varchar2(72) := g_package||'.get_gl_period';
 l_start_date               DATE;
 l_period_name              gl_period_statuses.period_name%TYPE;
 l_accounting_date          DATE;
 l_gl_period_statuses_rec   gl_period_statuses%ROWTYPE;


 CURSOR csr_time_period IS
 SELECT start_date
 FROM per_time_periods
 WHERE time_period_id = ( SELECT start_time_period_id
                          FROM pqh_budget_periods
                          WHERE budget_period_id = p_budget_period_id );

 CURSOR csr_period_name( p_start_date  IN DATE ) IS
 SELECT *
 FROM  gl_period_statuses
 WHERE application_id = g_application_id
   AND set_of_books_id = g_set_of_books_id
   AND closing_status  = 'O'
   AND p_start_date BETWEEN start_date AND end_date;

BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- get the budget start date
    OPEN csr_time_period;
      FETCH csr_time_period INTO l_start_date;
    CLOSE csr_time_period;

    hr_utility.set_location('Budget Start Date : '||l_start_date,10);

  -- get the period name and accounting date
    OPEN csr_period_name( p_start_date => l_start_date);
      FETCH csr_period_name INTO l_gl_period_statuses_rec;
    CLOSE csr_period_name;



  p_gl_period_statuses_rec      := l_gl_period_statuses_rec;

  hr_utility.set_location('Period Name : '||l_gl_period_statuses_rec.period_name,20);

  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END get_gl_period;

-- ----------------------------------------------------------------------------
FUNCTION get_amt1 ( p_budget_fund_src_id  IN  pqh_budget_fund_srcs.budget_fund_src_id%TYPE )
  RETURN NUMBER IS
/*
   This function will copmute the amout1 for UOM1
*/


l_proc                             varchar2(72) := g_package||'.get_amt1';
l_budget_fund_srcs_rec             pqh_budget_fund_srcs%ROWTYPE;
l_budget_elements_rec              pqh_budget_elements%ROWTYPE;
l_budget_sets_rec                  pqh_budget_sets%ROWTYPE;
l_amount1                          pqh_budget_sets.budget_unit1_value%TYPE;

CURSOR csr_bdgt_amt IS
SELECT (NVL(srcs.distribution_percentage,0) * .01) *
       (NVL(elem.distribution_percentage,0) * .01) *
        NVL(sets.budget_unit1_value,0)
FROM  pqh_budget_fund_srcs srcs,
      pqh_budget_elements  elem,
      pqh_budget_sets      sets
WHERE srcs.budget_fund_src_id = p_budget_fund_src_id
AND   elem.budget_element_id  = srcs.budget_element_id
AND   sets.budget_set_id      = elem.budget_set_id;

BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);

  OPEN  csr_bdgt_amt;
  FETCH csr_bdgt_amt INTO l_amount1;
    if csr_bdgt_amt%NotFound then
       l_amount1 := 0;
    end if;
  CLOSE csr_bdgt_amt;

  hr_utility.set_location('Amount1 is : '||l_amount1, 10);

  hr_utility.set_location('Leaving:'||l_proc, 1000);

  RETURN l_amount1;

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END get_amt1;

-- ----------------------------------------------------------------------------
FUNCTION get_amt2 ( p_budget_fund_src_id  IN  pqh_budget_fund_srcs.budget_fund_src_id%TYPE )
  RETURN NUMBER IS
/*
   This function will copmute the amout1 for UOM2
*/


l_proc                             varchar2(72) := g_package||'.get_amt2';
l_budget_fund_srcs_rec             pqh_budget_fund_srcs%ROWTYPE;
l_budget_elements_rec              pqh_budget_elements%ROWTYPE;
l_budget_sets_rec                  pqh_budget_sets%ROWTYPE;
l_amount2                          pqh_budget_sets.budget_unit2_value%TYPE;

CURSOR csr_bdgt_amt IS
SELECT (NVL(srcs.distribution_percentage,0) * .01) *
       (NVL(elem.distribution_percentage,0) * .01) *
        NVL(sets.budget_unit2_value,0)
FROM  pqh_budget_fund_srcs srcs,
      pqh_budget_elements  elem,
      pqh_budget_sets      sets
WHERE srcs.budget_fund_src_id = p_budget_fund_src_id
AND   elem.budget_element_id  = srcs.budget_element_id
AND   sets.budget_set_id      = elem.budget_set_id;

BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);

  OPEN  csr_bdgt_amt;
  FETCH csr_bdgt_amt INTO l_amount2;
    if csr_bdgt_amt%NotFound then
       l_amount2 := 0;
    end if;
  CLOSE csr_bdgt_amt;

  hr_utility.set_location('Amount2 is : '||l_amount2, 10);

  hr_utility.set_location('Leaving:'||l_proc, 1000);

  RETURN l_amount2;

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END get_amt2;



-- ----------------------------------------------------------------------------
FUNCTION get_amt3 ( p_budget_fund_src_id  IN  pqh_budget_fund_srcs.budget_fund_src_id%TYPE )
  RETURN NUMBER IS
/*
   This function will copmute the amout1 for UOM3
*/


l_proc                             varchar2(72) := g_package||'.get_amt3';
l_budget_fund_srcs_rec             pqh_budget_fund_srcs%ROWTYPE;
l_budget_elements_rec              pqh_budget_elements%ROWTYPE;
l_budget_sets_rec                  pqh_budget_sets%ROWTYPE;
l_amount3                          pqh_budget_sets.budget_unit3_value%TYPE;

CURSOR csr_bdgt_amt IS
SELECT (NVL(srcs.distribution_percentage,0) * .01) *
       (NVL(elem.distribution_percentage,0) * .01) *
        NVL(sets.budget_unit3_value,0)
FROM  pqh_budget_fund_srcs srcs,
      pqh_budget_elements  elem,
      pqh_budget_sets      sets
WHERE srcs.budget_fund_src_id = p_budget_fund_src_id
AND   elem.budget_element_id  = srcs.budget_element_id
AND   sets.budget_set_id      = elem.budget_set_id;

BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);

  OPEN  csr_bdgt_amt;
  FETCH csr_bdgt_amt INTO l_amount3;
    if csr_bdgt_amt%NotFound then
       l_amount3 := 0;
    end if;
  CLOSE csr_bdgt_amt;


  hr_utility.set_location('Amount3 is : '||l_amount3, 10);

  hr_utility.set_location('Leaving:'||l_proc, 1000);

  RETURN l_amount3;

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END get_amt3;

-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
PROCEDURE set_bdt_log_context
(
  p_budget_detail_id        IN  pqh_budget_details.budget_detail_id%TYPE,
  p_log_context             OUT NOCOPY pqh_process_log.log_context%TYPE
) IS

/*
  This procedure will set the log_context at Budget detail level

  Budgeted Record -> Display name of Primary Budgeted Entity
           OPEN -> Display Order is P J O G ( which ever is not null

*/

 l_proc                           varchar2(72) := g_package||'set_bdt_log_context';
 l_budget_details_rec             pqh_budget_details%ROWTYPE;
 l_position_name                  hr_positions.name%TYPE;
 l_job_name                       per_jobs.name%TYPE;
 l_organization_name              hr_organization_units.name%TYPE;
 l_grade_name                     per_grades.name%TYPE;

 CURSOR csr_bdt_detail_rec IS
 SELECT *
 FROM pqh_budget_details
 WHERE budget_detail_id = p_budget_detail_id ;

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

  OPEN csr_bdt_detail_rec;
    FETCH csr_bdt_detail_rec INTO l_budget_details_rec;
  CLOSE csr_bdt_detail_rec;



    -- this is budgeted record , display Primary Budgeted Entity
      IF     NVL(g_budgeted_entity_cd ,'OPEN') = 'POSITION' THEN
           l_position_name := HR_GENERAL.DECODE_POSITION (
                                p_position_id => l_budget_details_rec.position_id);
           p_log_context := SUBSTR(l_position_name,1,255);
      ELSIF  NVL(g_budgeted_entity_cd ,'OPEN') = 'JOB' THEN
           l_job_name := HR_GENERAL.DECODE_JOB (
                                p_job_id => l_budget_details_rec.job_id);
           p_log_context := SUBSTR(l_job_name,1,255);
      ELSIF  NVL(g_budgeted_entity_cd ,'OPEN') = 'ORGANIZATION' THEN
           l_organization_name := HR_GENERAL.DECODE_ORGANIZATION (
                                p_organization_id => l_budget_details_rec.organization_id);
           p_log_context := SUBSTR(l_organization_name,1,255);
      ELSIF  NVL(g_budgeted_entity_cd ,'OPEN') = 'GRADE' THEN
           l_grade_name  := HR_GENERAL.DECODE_GRADE (
                            p_grade_id => l_budget_details_rec.grade_id);
           p_log_context := SUBSTR(l_grade_name,1,255);
      ELSIF  NVL(g_budgeted_entity_cd ,'OPEN') = 'OPEN' THEN
         l_position_name := HR_GENERAL.DECODE_POSITION (
                            p_position_id => l_budget_details_rec.position_id);
         l_job_name := HR_GENERAL.DECODE_JOB (
                       p_job_id => l_budget_details_rec.job_id);
         l_organization_name := HR_GENERAL.DECODE_ORGANIZATION (
                                p_organization_id => l_budget_details_rec.organization_id);
         l_grade_name  := HR_GENERAL.DECODE_GRADE (
                          p_grade_id => l_budget_details_rec.grade_id);

         IF    l_position_name IS NOT NULL THEN
            p_log_context := SUBSTR(l_position_name,1,255);
         ELSIF l_job_name  IS NOT NULL THEN
            p_log_context := SUBSTR(l_job_name,1,255);
         ELSIF l_organization_name  IS NOT NULL THEN
            p_log_context := SUBSTR(l_organization_name,1,255);
         ELSIF l_grade_name  IS NOT NULL THEN
            p_log_context := SUBSTR(l_grade_name,1,255);
         END IF;

      END IF;






  hr_utility.set_location('Log Context : '||p_log_context, 100);



  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        -- end log and halt the program here
        raise g_error_exception;
END set_bdt_log_context;
--------------------------------------------------------------------------------------------------------------
PROCEDURE set_bpr_log_context
(
  p_budget_period_id        IN  pqh_budget_periods.budget_period_id%TYPE,
  p_log_context             OUT NOCOPY pqh_process_log.log_context%TYPE
) IS
/*
  This procedure will set the log_context at bpr periods level

   Display the period start date for start_time_period_id and
   Display the period end date for end_time_period_id
   Table : per_time_periods

*/

 l_proc                           varchar2(72) := g_package||'set_bpr_log_context';
 l_budget_periods_rec             pqh_budget_periods%ROWTYPE;
 l_per_time_periods               per_time_periods%ROWTYPE;
 l_start_date                     per_time_periods.start_date%TYPE;
 l_end_date                       per_time_periods.end_date%TYPE;

 CURSOR csr_bpr_periods_rec IS
 SELECT *
 FROM pqh_budget_periods
 WHERE budget_period_id = p_budget_period_id ;

 CURSOR csr_per_time_periods ( p_time_period_id IN number ) IS
 SELECT *
 FROM per_time_periods
 WHERE time_period_id = p_time_period_id ;

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

  OPEN csr_bpr_periods_rec;
    FETCH csr_bpr_periods_rec INTO l_budget_periods_rec;
  CLOSE csr_bpr_periods_rec;

   -- get the start date
  OPEN csr_per_time_periods ( p_time_period_id => l_budget_periods_rec.start_time_period_id);
    FETCH csr_per_time_periods INTO l_per_time_periods;
  CLOSE csr_per_time_periods;

    l_start_date := l_per_time_periods.start_date;


   -- get the end date

  OPEN csr_per_time_periods ( p_time_period_id => l_budget_periods_rec.end_time_period_id);
    FETCH csr_per_time_periods INTO l_per_time_periods;
  CLOSE csr_per_time_periods;

    l_end_date := l_per_time_periods.end_date;

  -- set log context

    p_log_context := l_start_date||' - '||l_end_date;



  hr_utility.set_location('Log Context : '||p_log_context, 101);
  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        -- end log and halt the program here
        raise g_error_exception;
END set_bpr_log_context;
--------------------------------------------------------------------------------------------------------------
PROCEDURE set_bfs_log_context
(
  p_cost_allocation_keyflex_id       IN  pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE,
  p_log_context                     OUT NOCOPY pqh_process_log.log_context%TYPE
) IS

/*
  This procedure will set the log_context at wks budget fund srcs level

   Display the CONCATENATED_SEGMENTS
   Table : pay_cost_allocation_keyflex

*/

 l_proc                            varchar2(72) := g_package||'set_bfs_log_context';
 l_pay_cost_allocation_kf_rec      pay_cost_allocation_keyflex%ROWTYPE;


 CURSOR csr_pay_cost_allocation_kf_rec  IS
 SELECT *
 FROM pay_cost_allocation_keyflex
 WHERE cost_allocation_keyflex_id = p_cost_allocation_keyflex_id;

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

    OPEN csr_pay_cost_allocation_kf_rec;
      FETCH csr_pay_cost_allocation_kf_rec INTO l_pay_cost_allocation_kf_rec;
    CLOSE csr_pay_cost_allocation_kf_rec;


   p_log_context := l_pay_cost_allocation_kf_rec.concatenated_segments;


  hr_utility.set_location('Log Context : '||p_log_context, 101);
  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        -- end log and halt the program here
        raise g_error_exception;
END set_bfs_log_context;
--------------------------------------------------------------------------------------------------------------

PROCEDURE end_log
IS
/*
  This will update the g_status global with ERROR or SUCCESS
*/
--
-- local variables
--
l_proc                  varchar2(72) := g_package||'end_log';
l_count_error           NUMBER := 0;
l_count_warning         NUMBER := 0;
l_status                VARCHAR2(30);
l_pqh_process_log_rec   pqh_process_log%ROWTYPE;
PRAGMA                    AUTONOMOUS_TRANSACTION;


CURSOR csr_status (p_message_type_cd  IN VARCHAR2 ) IS
SELECT COUNT(*)
FROM pqh_process_log
WHERE message_type_cd = p_message_type_cd
START WITH process_log_id = pqh_process_batch_log.g_master_process_log_id
CONNECT BY PRIOR process_log_id = master_process_log_id;

CURSOR csr_batch_rec IS
SELECT *
FROM pqh_process_log
WHERE process_log_id = pqh_process_batch_log.g_master_process_log_id;


BEGIN

  hr_utility.set_location('Entering: '||l_proc, 5);

  /*
    Compute the status of the batch. If there exists any record in the batch with
    message_type_cd = 'ERROR' then the batch_status = 'ERROR'
    If there only exists records in the batch with message_type_cd = 'WARNING' then
    the batch_status = 'WARNING'
    If there are NO records in the batch with message_type_cd = 'WARNING' OR 'ERROR' then
    the batch_status = 'SUCCESS'
  */

   OPEN csr_status(p_message_type_cd => 'ERROR');
     FETCH csr_status INTO l_count_error;
   CLOSE csr_status;

   OPEN csr_status(p_message_type_cd => 'WARNING');
     FETCH csr_status INTO l_count_warning;
   CLOSE csr_status;


   IF l_count_error <> 0 THEN
     -- there are one or more errors
      l_status := 'ERROR';
      g_status := 'ERROR';
   ELSE
     -- errors are 0 , check for warnings
      IF l_count_warning <> 0 THEN
        -- there are one or more warnings
        l_status := 'WARNING';
        g_status := 'ERROR';
      ELSE
        -- no errors or warnings
         l_status := 'SUCCESS';
         g_status := 'SUCCESS';
      END IF;

   END IF;

   hr_utility.set_location('Batch Status :  '||l_status,100);

  /*
    update the 'start' record for this batch with message_type_cd = 'COMPLETE' and
    update the batch_end_date with current date time
  */

   OPEN csr_batch_rec;
     FETCH csr_batch_rec INTO l_pqh_process_log_rec;
   CLOSE csr_batch_rec;

   IF l_pqh_process_log_rec.message_type_cd <> 'ERROR'THEN
     -- no errors in the batch
      UPDATE pqh_process_log
      SET message_type_cd = 'COMPLETE',
         message_text   = fnd_message.get_string('PQH','PQH_PROCESS_COMPLETED'),
          txn_table_route_id    =  g_table_route_id_bvr,
          batch_status = l_status,
          batch_end_date  = sysdate
      WHERE process_log_id = pqh_process_batch_log.g_master_process_log_id;
    ELSE
      -- there were errors in the batch header record i.e the root node
      -- so only update the batch status and end date
      UPDATE pqh_process_log
      SET batch_status = l_status,
          batch_end_date  = sysdate,
          txn_table_route_id    =  g_table_route_id_bvr
      WHERE process_log_id = pqh_process_batch_log.g_master_process_log_id;
    END IF;



 /*
   commit the autonomous transaction
 */

  commit;

  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END end_log;

--------------------------------------------------------------------------------------------------------------
PROCEDURE populate_globals_error
(
 p_message_text     IN    pqh_process_log.message_text%TYPE
) IS
/*
  If there are errors in populate globals procedure we will call this procedure which will
  end the process log as the  batch itself has error
*/
--
-- local variables
--
l_proc                    varchar2(72) := g_package||'populate_globals_error';
PRAGMA                    AUTONOMOUS_TRANSACTION;

BEGIN

  hr_utility.set_location('Entering: '||l_proc, 5);

   UPDATE pqh_process_log
   SET message_type_cd =  'ERROR',
       message_text   = p_message_text,
       txn_table_route_id    =  g_table_route_id_bvr
       -- batch_status    = 'ERROR',
       -- batch_end_date  = sysdate
   WHERE process_log_id = pqh_process_batch_log.g_master_process_log_id;

 /*
   commit the autonomous transaction
 */

  commit;

  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END populate_globals_error;

--------------------------------------------------------------------------------------------------------------
PROCEDURE populate_budget_gl_map
(
  p_budget_id             IN  pqh_budgets.budget_id%TYPE
) IS
/*
  Called from Budget Charactaristics FORM
  This procedure will populate the pqh_budget_gl_flex_maps
  This will be called from the Budget Characteristics Form when the user presses the Map Tab
  This will get all the segments for the current GL Chart of Account and populate the map table
  This procedure will only be called if transfer to gl flag is Y and gl_set_of_books_id is not null
*/
--
-- local variables
--
l_proc                    varchar2(72) := g_package||'populate_budget_gl_map';
l_budgets_rec             pqh_budgets%ROWTYPE;
l_sets_of_books_rec       gl_sets_of_books%ROWTYPE;
l_fnd_id_flex_segments    fnd_id_flex_segments%ROWTYPE;
l_budget_gl_flex_map_id   number(15);
l_object_version_number   number(9);

CURSOR csr_budget_rec IS
SELECT *
FROM pqh_budgets
WHERE budget_id = p_budget_id;

CURSOR csr_gl_sets_of_books_rec(p_set_of_books_id IN number)IS
SELECT *
FROM gl_sets_of_books
WHERE set_of_books_id = p_set_of_books_id;

CURSOR csr_flex_segments (p_id_flex_num IN number)IS
SELECT *
FROM fnd_id_flex_segments
WHERE application_id = 101
  AND id_flex_code = 'GL#'
  AND id_flex_num = p_id_flex_num
  AND enabled_flag = 'Y'
  AND display_flag = 'Y'
ORDER BY application_column_name;

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

  -- get the set of books ID
  OPEN csr_budget_rec;
    FETCH csr_budget_rec INTO l_budgets_rec;
  CLOSE csr_budget_rec;

  hr_utility.set_location('Set Of Books ID : '||l_budgets_rec.gl_set_of_books_id,10);

  -- get the structure number of the GL ACCOUNT
   OPEN csr_gl_sets_of_books_rec(p_set_of_books_id => l_budgets_rec.gl_set_of_books_id);
     FETCH csr_gl_sets_of_books_rec INTO l_sets_of_books_rec;
   CLOSE csr_gl_sets_of_books_rec;

  hr_utility.set_location('Chart of Account ID : '||l_sets_of_books_rec.chart_of_accounts_id,100);

  -- populate the pqh_budget_gl_flex_maps with the segments
  OPEN csr_flex_segments (p_id_flex_num => l_sets_of_books_rec.chart_of_accounts_id );
    LOOP
      FETCH csr_flex_segments INTO l_fnd_id_flex_segments;
      EXIT WHEN csr_flex_segments%NOTFOUND;
        -- call the insert API here
        pqh_budget_gl_flex_maps_api.create_budget_gl_flex_map
        (
         p_validate                       =>  false
        ,p_budget_gl_flex_map_id          => l_budget_gl_flex_map_id
        ,p_budget_id                      => p_budget_id
        ,p_gl_account_segment             => l_fnd_id_flex_segments.application_column_name
        ,p_payroll_cost_segment           => null
        ,p_object_version_number          => l_object_version_number
        );

        hr_utility.set_location('Segment : '||l_fnd_id_flex_segments.application_column_name, 200);
        hr_utility.set_location('budget_gl_flex_map_id : '||l_budget_gl_flex_map_id,250);

    END LOOP;
  CLOSE csr_flex_segments;


  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END populate_budget_gl_map;

--------------------------------------------------------------------------------------------------------------
PROCEDURE reverse_budget_details
(
 p_period_name              IN  pqh_gl_interface.period_name%TYPE,
 p_currency_code            IN  pqh_gl_interface.currency_code%TYPE,
 p_code_combination_id      IN  pqh_gl_interface.code_combination_id%TYPE
) IS
/*
  This procedure will be called if the GL fund checker failed. This procedure will do the following :

1. update all the budget_detail records which have this Period Name + CCID + currency code to ERROR ( gl_status)

2. Reverse unposted adjustment txns in pqh_gl_interface

3. Delete all unposted non-adjustment txns from pqh_gl_interface

Note : If a budget detail record has 4 periods and there was a error in 4th period , we have no control on the 1st three
as they have already been Approved by funs checker program and would have already been posted to GL.

*/

--
-- local variables
--
l_proc                    varchar2(72) := g_package||'reverse_budget_details';
l_pqh_gl_interface_rec    pqh_gl_interface%ROWTYPE;


CURSOR csr_adj IS
SELECT *
FROM pqh_gl_interface
WHERE budget_version_id = g_budget_version_id
     AND posting_type_cd = 'BUDGET'
  AND period_name = p_period_name
  AND currency_code = p_currency_code
  AND code_combination_id = p_code_combination_id
  AND NVL(adjustment_flag,'N') = 'Y'
  AND status IS NULL
  AND posting_date IS NULL;


BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

  -- reverse the adjustment transactions
    OPEN csr_adj;
      LOOP
        FETCH csr_adj INTO l_pqh_gl_interface_rec;
        EXIT WHEN csr_adj%NOTFOUND;

         -- update the amount_dr for the original record
         UPDATE pqh_gl_interface
         SET amount_dr = NVL(amount_dr,0) -
                         NVL(l_pqh_gl_interface_rec.amount_dr,0) +
                         NVL(l_pqh_gl_interface_rec.amount_cr,0)
         WHERE budget_version_id = l_pqh_gl_interface_rec.budget_version_id
           AND budget_detail_id = l_pqh_gl_interface_rec.budget_detail_id
     AND posting_type_cd = 'BUDGET'
           AND period_name = l_pqh_gl_interface_rec.period_name
           AND currency_code = l_pqh_gl_interface_rec.currency_code
           AND code_combination_id = l_pqh_gl_interface_rec.code_combination_id
           AND NVL(adjustment_flag,'N') = 'N'
           AND status IS NOT NULL;

      END LOOP;
    CLOSE csr_adj;

   -- update the pqh_budget_details table gl_status to ERROR

      UPDATE pqh_budget_details
      SET gl_status = 'ERROR'
      WHERE budget_detail_id IN
        (
          SELECT distinct budget_detail_id
          FROM pqh_gl_interface
          WHERE budget_version_id = g_budget_version_id
     AND posting_type_cd = 'BUDGET'
            AND period_name = p_period_name
            AND currency_code = p_currency_code
            AND code_combination_id = p_code_combination_id
            AND status IS NULL
            AND posting_date IS NULL
        );

    -- delete the unposted transactions from pqh_gl_interface

       DELETE FROM pqh_gl_interface
       WHERE budget_version_id = g_budget_version_id
         AND period_name = p_period_name
         AND currency_code = p_currency_code
         AND code_combination_id = p_code_combination_id
     AND posting_type_cd = 'BUDGET'
         AND status IS NULL
         AND posting_date IS NULL;


  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END reverse_budget_details;
--------------------------------------------------------------------------------------------------------------
PROCEDURE build_old_bdgt_dtls_tab
(
 p_budget_detail_id         IN pqh_budget_details.budget_detail_id%TYPE
) IS
/*
  This procedure will check if the current budget_detail_id was already posted (exists in pqh_gl_interface)
  If Yes, it would build a pl/sql table with all records which have this current budget_detail_id.
  This is done as the user might have changed the records with current budget_detail_id which were previously
  posted and not present in new records. For those records we need to unpost i.e reverse the transactions.

  Consider the following example :

<-----------  Old ------------------------>               <-------------  New  ------>
Budget_detail_id   Period    CCID   Cur  Amt              Period    CCID     Cur  Amt
                            /PTAEO                                 /PTAEO
1                  1         1      US   100  (reverse)   1         1        UK   100  ( new )
                   2         2      US   100  (reverse)   6         2        US   100  ( new )
                   3         3      US   100  (update)    3         3        US   200  ( update )
                   4         4      US   100  (unchanged) 4         4        US   100  ( unchanged )
                                                          4         7        UK   100  ( new )
                                                          7         9        US   100  ( new )


*/
--
-- local variables
--
l_proc                    varchar2(72) := g_package||'build_old_bdgt_dtls_tab';
l_pqh_gl_interface_rec    pqh_gl_interface%ROWTYPE;
i                                BINARY_INTEGER :=1;



CURSOR csr_old_bdgt_dtls_rec IS
SELECT *
FROM pqh_gl_interface
WHERE budget_version_id        =  g_budget_version_id
  AND budget_detail_id         =  p_budget_detail_id
     AND posting_type_cd = 'BUDGET'
  AND NVL(adjustment_flag,'N') = 'N'
  AND status IS NOT NULL
  AND posting_date IS NOT NULL
  AND (NVL(amount_dr,0) > 0 OR NVL(amount_cr,0) > 0 ) ;


BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

  OPEN csr_old_bdgt_dtls_rec;
    LOOP
      FETCH csr_old_bdgt_dtls_rec INTO l_pqh_gl_interface_rec;
      EXIT WHEN csr_old_bdgt_dtls_rec%NOTFOUND;

       g_old_bdgt_dtls_tab(i).budget_version_id            := g_budget_version_id;
       g_old_bdgt_dtls_tab(i).budget_detail_id             := p_budget_detail_id;
       g_old_bdgt_dtls_tab(i).period_name                  := l_pqh_gl_interface_rec.period_name;
       g_old_bdgt_dtls_tab(i).accounting_date              := l_pqh_gl_interface_rec.accounting_date;
       g_old_bdgt_dtls_tab(i).cost_allocation_keyflex_id   := l_pqh_gl_interface_rec.cost_allocation_keyflex_id;
       g_old_bdgt_dtls_tab(i).code_combination_id          := l_pqh_gl_interface_rec.code_combination_id;
       g_old_bdgt_dtls_tab(i).project_id                   := l_pqh_gl_interface_rec.project_id;
       g_old_bdgt_dtls_tab(i).task_id                      := l_pqh_gl_interface_rec.task_id;
       g_old_bdgt_dtls_tab(i).award_id                     := l_pqh_gl_interface_rec.award_id;
       g_old_bdgt_dtls_tab(i).expenditure_type             := l_pqh_gl_interface_rec.expenditure_type;
       g_old_bdgt_dtls_tab(i).organization_id              := l_pqh_gl_interface_rec.organization_id;
       g_old_bdgt_dtls_tab(i).currency_code                := l_pqh_gl_interface_rec.currency_code;
       g_old_bdgt_dtls_tab(i).amount_dr                    := l_pqh_gl_interface_rec.amount_dr;
       g_old_bdgt_dtls_tab(i).amount_cr                    := l_pqh_gl_interface_rec.amount_cr;
       g_old_bdgt_dtls_tab(i).reverse_flag                 := 'Y';

       i := i + 1;


    END LOOP;
  CLOSE csr_old_bdgt_dtls_rec;


  hr_utility.set_location('Done building - records in old are :'||NVL(g_old_bdgt_dtls_tab.COUNT,0), 100);


  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END build_old_bdgt_dtls_tab;
--------------------------------------------------------------------------------------------------------------
PROCEDURE compare_old_bdgt_dtls_tab IS
/*
  This procedure will compare the g_old_bdgt_dtls_tab with g_period_amt_tab . It will check if there are records in
  g_old_bdgt_dtls_tab which are not in g_period_amt_tab and update the reverse flag for those records to 'Y' so that
  we can reverse those records
*/

--
-- local variables
--
l_proc                    varchar2(72) := g_package||'compare_old_bdgt_dtls_tab';

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

  -- for each record in g_old_bdgt_dtls_tab, loop thru the g_period_amt_tab to check if the record exists in g_period_amt_tab
  -- if yes then reverse_flag is N else update the reverse_flag in g_old_bdgt_dtls_tab to 'Y'

   IF  NVL(g_old_bdgt_dtls_tab.COUNT,0) <> 0 AND
       NVL(g_period_amt_tab.COUNT,0)    <> 0 AND
       g_detail_error = 'N'                  THEN

     -- for each record in old
        FOR i IN NVL(g_old_bdgt_dtls_tab.FIRST,0)..NVL(g_old_bdgt_dtls_tab.LAST,-1)
        LOOP
           -- loop thru the new g_period_amt_tab to check if the record exists
           FOR j IN NVL(g_period_amt_tab.FIRST,0)..NVL(g_period_amt_tab.LAST,-1)
           LOOP
               IF    g_period_amt_tab(j).cost_allocation_keyflex_id is NOT NULL AND
                  g_old_bdgt_dtls_tab(i).code_combination_id        is NOT NULL AND
                  g_old_bdgt_dtls_tab(i).period_name = g_period_amt_tab(j).period_name AND
                  g_old_bdgt_dtls_tab(i).code_combination_id = g_period_amt_tab(j).code_combination_id AND
                  g_old_bdgt_dtls_tab(i).currency_code   IN (g_currency_code1 , g_currency_code2, g_currency_code3 )THEN
                  -- record found, go to next record
                  g_old_bdgt_dtls_tab(i).reverse_flag := 'N';
                  exit ; -- inner loop
               ELSIF
                     g_period_amt_tab(j).cost_allocation_keyflex_id is NULL AND
                  g_old_bdgt_dtls_tab(i).code_combination_id        is NULL AND
                  g_old_bdgt_dtls_tab(i).period_name = to_char(g_period_amt_tab(j).period_id) AND
                  g_old_bdgt_dtls_tab(i).project_id         = g_period_amt_tab(j).project_id AND
		  g_old_bdgt_dtls_tab(i).task_id            = g_period_amt_tab(j).task_id AND
		  g_old_bdgt_dtls_tab(i).award_id           = g_period_amt_tab(j).award_id AND
		  g_old_bdgt_dtls_tab(i).expenditure_type   = g_period_amt_tab(j).expenditure_type AND
                  g_old_bdgt_dtls_tab(i).organization_id    = g_period_amt_tab(j).organization_id  THEN
                 -- record found, go to next record
                  g_old_bdgt_dtls_tab(i).reverse_flag := 'N';
                  exit ; -- inner loop

               END IF;
           END LOOP; -- for the g_period_amt_tab table

        END LOOP; -- for the old g_old_bdgt_dtls_tab table



   END IF; -- if both old and new tables have records and there was no error in new table


  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END compare_old_bdgt_dtls_tab;


--------------------------------------------------------------------------------------------------------------
PROCEDURE reverse_old_bdgt_dtls_tab
(
 p_budget_detail_id         IN pqh_budget_details.budget_detail_id%TYPE
) IS
/*
  This procedure will loop thru the g_old_bdgt_dtls_tab and generate reverse transaction for all records
  where reverse_flag is Y and update the posted record amount to 0
*/
--
-- local variables
--
l_proc                    varchar2(72) := g_package||'reverse_old_bdgt_dtls_tab';
l_pqh_gl_interface_rec    pqh_gl_interface%ROWTYPE;

 CURSOR csr_pqh_gl_interface(p_period_name IN  varchar2,
                             p_code_combination_id  IN number,
                             p_currency_code IN varchar2) IS
 SELECT *
  FROM pqh_gl_interface
 WHERE budget_version_id    = g_budget_version_id
   AND budget_detail_id     = p_budget_detail_id
   AND period_name          = p_period_name
   AND code_combination_id  = p_code_combination_id
   AND currency_code        = p_currency_code
     AND posting_type_cd = 'BUDGET'
   AND NVL(adjustment_flag,'N') = 'N'
   AND status IS NOT NULL
   AND posting_date IS NOT NULL
  FOR UPDATE of amount_dr;


 Cursor csr_pqh_gms_interface ( p_period_name      IN  varchar2,
                                p_project_id	   IN  NUMBER,
                                p_task_id	   IN  NUMBER,
                                p_award_id	   IN  NUMBER,
                                p_expenditure_type IN  varchar2,
                                p_organization_id  IN  NUMBER) IS
   SELECT *
    FROM pqh_gl_interface
   WHERE budget_version_id        = g_budget_version_id
     AND budget_detail_id         = p_budget_detail_id
     AND period_name              = p_period_name
     AND project_id               = p_project_id
     AND task_id	   	  = p_task_id
     AND award_id	   	  = p_award_id
     AND expenditure_type	  = p_expenditure_type
     AND organization_id 	  = p_organization_id
     AND posting_type_cd          = 'BUDGET'
     AND NVL(adjustment_flag,'N') = 'N'
     AND status IS NOT NULL
     AND posting_date IS NOT NULL
  FOR UPDATE of amount_dr;


BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

  hr_utility.set_location('Budget Detail Id : '||p_budget_detail_id,6);

   IF  NVL(g_old_bdgt_dtls_tab.COUNT,0) <> 0 AND
       NVL(g_period_amt_tab.COUNT,0)    <> 0 AND
       g_detail_error = 'N'                  THEN

       hr_utility.set_location('Inside the if ',7);

     -- for each record in old
        FOR i IN NVL(g_old_bdgt_dtls_tab.FIRST,0)..NVL(g_old_bdgt_dtls_tab.LAST,-1)
        LOOP
          IF g_old_bdgt_dtls_tab(i).reverse_flag = 'Y' THEN

            hr_utility.set_location('Reverse flag is Y ',8);
            hr_utility.set_location('code_combination_id '||g_old_bdgt_dtls_tab(i).code_combination_id,8);

            -- update the record and reverse the txn
            IF (g_old_bdgt_dtls_tab(i).code_combination_id is not null) THEN
               OPEN csr_pqh_gl_interface(p_period_name => g_old_bdgt_dtls_tab(i).period_name,
                                         p_code_combination_id => g_old_bdgt_dtls_tab(i).code_combination_id,
                                         p_currency_code => g_old_bdgt_dtls_tab(i).currency_code) ;
                FETCH csr_pqh_gl_interface INTO l_pqh_gl_interface_rec;

                hr_utility.set_location('Fetched record ',10);

                 -- update the pqh_gl_interface table
                 UPDATE pqh_gl_interface
                     SET amount_dr = 0
                 WHERE CURRENT OF csr_pqh_gl_interface;

                 hr_utility.set_location('Updated pqh_gl_interface ',15);
                 hr_utility.set_location('Creating reverse txn in pqh_gl_interface ',16);

                 -- create a reverse transaction for this amount_dr

                 INSERT INTO pqh_gl_interface
                 (
                   gl_interface_id,
                   budget_version_id,
                   budget_detail_id,
                   period_name,
                   accounting_date,
                   code_combination_id,
                   cost_allocation_keyflex_id,
                   amount_dr,
                   amount_cr,
                   currency_code,
                   status,
                   adjustment_flag,
                   posting_date,
                   posting_type_cd
                 )
                 VALUES
                 (
                   pqh_gl_interface_s.nextval,
                   g_budget_version_id,
                   p_budget_detail_id,
                   g_old_bdgt_dtls_tab(i).period_name,
                   g_old_bdgt_dtls_tab(i).accounting_date,
                   g_old_bdgt_dtls_tab(i).code_combination_id,
                   g_old_bdgt_dtls_tab(i).cost_allocation_keyflex_id,
                   0,
                   NVL(l_pqh_gl_interface_rec.amount_dr,0),
                   g_old_bdgt_dtls_tab(i).currency_code,
                   null,
                   'Y',
                   null,
                   'BUDGET'
                 );

                   hr_utility.set_location('Created a reverse txn ',20);

               CLOSE  csr_pqh_gl_interface;

            Else
	         OPEN csr_pqh_gms_interface ( p_period_name      => g_old_bdgt_dtls_tab(i).period_name,
	                                      p_project_id       => g_old_bdgt_dtls_tab(i).project_id,
                                              p_task_id	         => g_old_bdgt_dtls_tab(i).task_id,
                                              p_award_id	 => g_old_bdgt_dtls_tab(i).award_id,
                                              p_expenditure_type => g_old_bdgt_dtls_tab(i).expenditure_type,
                                              p_organization_id  => g_old_bdgt_dtls_tab(i).organization_id);
	         FETCH csr_pqh_gms_interface INTO l_pqh_gl_interface_rec;

	         hr_utility.set_location('Fetched record ',10);

	          -- update the pqh_gl_interface table
	          UPDATE pqh_gl_interface
	              SET amount_dr = 0
	          WHERE CURRENT OF csr_pqh_gms_interface;

	          hr_utility.set_location('Updated pqh_gl_interface ',15);
	          hr_utility.set_location('Creating reverse txn in pqh_gl_interface ',16);

	          -- create a reverse transaction for this amount_dr

	          INSERT INTO pqh_gl_interface
	          (
	            gl_interface_id,
	            budget_version_id,
	            budget_detail_id,
                    period_name,
	            project_id,
		    task_id,
		    award_id,
		    expenditure_type,
                    organization_id,
	            amount_dr,
	            amount_cr,
	            status,
	            adjustment_flag,
	            posting_date,
                    currency_code,
	            posting_type_cd
	          )
	          VALUES
	          (
	            pqh_gl_interface_s.nextval,
	            g_budget_version_id,
	            p_budget_detail_id,
                    g_old_bdgt_dtls_tab(i).period_name,
	            g_old_bdgt_dtls_tab(i).project_id,
	            g_old_bdgt_dtls_tab(i).task_id,
	            g_old_bdgt_dtls_tab(i).award_id,
	            g_old_bdgt_dtls_tab(i).expenditure_type,
	            g_old_bdgt_dtls_tab(i).organization_id,
	            0,
	            NVL(l_pqh_gl_interface_rec.amount_dr,0),
	            null,
	            'Y',
	            null,
                    g_old_bdgt_dtls_tab(i).currency_code,
	            'BUDGET'
	            );

	        hr_utility.set_location('Created a reverse txn ',20);

               CLOSE  csr_pqh_gms_interface;

            END IF; -- ccid is null


            END IF;  -- if the transaction reverse_flag is Y
        END LOOP;

  END IF;  -- if both old and new tables have records and there was no error in new table

  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END reverse_old_bdgt_dtls_tab;
--------------------------------------------------------------------------------------------------------------
PROCEDURE get_default_currency
IS
/*
  This procedure will check if the business_group has a default currency, if yes it will override the
  gl_sets_of_book currency code
  If there is a currency associated with the budget , it will override all other currencies
*/

--
-- local variables
--
l_proc                    varchar2(72) := g_package||'get_default_currency';

l_bg_curr_code            varchar2(150) := '';
l_budget_curr             varchar2(150) := '';

CURSOR csr_curr_code IS
SELECT bg.ORG_INFORMATION10
FROM  HR_ORGANIZATION_INFORMATION bg,
      pqh_budgets bgt,
      pqh_budget_versions bvr
WHERE bgt.budget_id = bvr.budget_id
  AND bvr.budget_version_id = g_budget_version_id
  AND bgt.business_group_id = bg.organization_id
  AND bg.ORG_INFORMATION_CONTEXT = 'Business Group Information';

CURSOR csr_bgt_curr IS
SELECT bgt.currency_code
FROM  pqh_budgets  bgt,
      pqh_budget_versions bvr
WHERE bgt.budget_id = bvr.budget_id
  AND bvr.budget_version_id = g_budget_version_id;


BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

  OPEN csr_curr_code;
    FETCH csr_curr_code INTO l_bg_curr_code;
  CLOSE csr_curr_code;

  hr_utility.set_location('Business Group Curr Code : '||l_bg_curr_code,6);

  IF l_bg_curr_code IS NOT NULL THEN
    -- assign this to g_currency_code
     g_currency_code := l_bg_curr_code;
  END IF;

  OPEN csr_bgt_curr;
    FETCH csr_bgt_curr INTO l_budget_curr;
  CLOSE csr_bgt_curr;

  hr_utility.set_location('Budget Currency Code : '||l_budget_curr,7);

  IF l_budget_curr IS NOT NULL THEN
    -- assign this to g_currency_code
     g_currency_code := l_budget_curr;
  END IF;



  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END get_default_currency;

--------------------------------------------------------------------------------------------------------------

PROCEDURE get_payroll_defaults
(
 p_budget_detail_id         IN  pqh_budget_details.budget_detail_id%TYPE
) IS
/*
  This procedure will initialize the g_seg_val_tab table.
  For the about budget_detail_id ,it will check if the Position ID is not null.
  If the Position_id is not null, we would check if there is pay_freq_payroll_id attached to this position_id
  If yes , we would get the defaults for this pay_freq_payroll_id from pay_all_payrolls table and assign to
  g_seg_val_tab table

*/
--
-- local variables
--
l_proc                    varchar2(72) := g_package||' .get_payroll_defaults';

 l_cost_allocation_keyflex_id   pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE;
 l_pay_cost_allocation_rec      pay_cost_allocation_keyflex%ROWTYPE;

CURSOR csr_cost_allocation_keyflex_id IS
SELECT  cost_allocation_keyflex_id
  FROM  PAY_ALL_PAYROLLS_F pay,
        FND_SESSIONS SS
WHERE   SS.SESSION_ID = USERENV( 'sessionid')
  AND   PAY.EFFECTIVE_START_DATE <= ss.effective_date
  AND   PAY.EFFECTIVE_END_DATE >= ss.effective_date
  AND   pay.payroll_id =
(SELECT  pos.pay_freq_payroll_id
  FROM  pqh_budget_details bdt,
        hr_all_positions_f pos,
        FND_SESSIONS SS
WHERE   bdt.budget_detail_id = p_budget_detail_id
  AND   bdt.position_id = pos.position_id
  AND   SS.SESSION_ID = USERENV( 'sessionid')
  AND   POS.EFFECTIVE_START_DATE <= ss.effective_date
  AND   POS.EFFECTIVE_END_DATE >= ss.effective_date
);

 CURSOR csr_cost_segments (p_cost_allocation_keyflex_id IN number) IS
 SELECT *
 FROM pay_cost_allocation_keyflex
 WHERE cost_allocation_keyflex_id = p_cost_allocation_keyflex_id;




BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

  -- initialize the global table g_seg_val_tab
     g_seg_val_tab.DELETE;
  -- g_seg_val_tab will have all the 30 segment names and their values
     g_seg_val_tab(1).cost_segment_name  := 'SEGMENT1';
     g_seg_val_tab(1).segment_value      := '';
     g_seg_val_tab(2).cost_segment_name  := 'SEGMENT2';
     g_seg_val_tab(2).segment_value      := '';
     g_seg_val_tab(3).cost_segment_name  := 'SEGMENT3';
     g_seg_val_tab(3).segment_value      := '';
     g_seg_val_tab(4).cost_segment_name  := 'SEGMENT4';
     g_seg_val_tab(4).segment_value      := '';
     g_seg_val_tab(5).cost_segment_name  := 'SEGMENT5';
     g_seg_val_tab(5).segment_value      := '';
     g_seg_val_tab(6).cost_segment_name  := 'SEGMENT6';
     g_seg_val_tab(6).segment_value      := '';
     g_seg_val_tab(7).cost_segment_name  := 'SEGMENT7';
     g_seg_val_tab(7).segment_value      := '';
     g_seg_val_tab(8).cost_segment_name  := 'SEGMENT8';
     g_seg_val_tab(8).segment_value      := '';
     g_seg_val_tab(9).cost_segment_name  := 'SEGMENT9';
     g_seg_val_tab(9).segment_value      := '';
     g_seg_val_tab(10).cost_segment_name  := 'SEGMENT10';
     g_seg_val_tab(10).segment_value      := '';
     g_seg_val_tab(11).cost_segment_name  := 'SEGMENT11';
     g_seg_val_tab(11).segment_value      := '';
     g_seg_val_tab(12).cost_segment_name  := 'SEGMENT12';
     g_seg_val_tab(12).segment_value      := '';
     g_seg_val_tab(13).cost_segment_name  := 'SEGMENT13';
     g_seg_val_tab(13).segment_value      := '';
     g_seg_val_tab(14).cost_segment_name  := 'SEGMENT14';
     g_seg_val_tab(14).segment_value      := '';
     g_seg_val_tab(15).cost_segment_name  := 'SEGMENT15';
     g_seg_val_tab(15).segment_value      := '';
     g_seg_val_tab(16).cost_segment_name  := 'SEGMENT16';
     g_seg_val_tab(16).segment_value      := '';
     g_seg_val_tab(17).cost_segment_name  := 'SEGMENT17';
     g_seg_val_tab(17).segment_value      := '';
     g_seg_val_tab(18).cost_segment_name  := 'SEGMENT18';
     g_seg_val_tab(18).segment_value      := '';
     g_seg_val_tab(19).cost_segment_name  := 'SEGMENT19';
     g_seg_val_tab(19).segment_value      := '';
     g_seg_val_tab(20).cost_segment_name  := 'SEGMENT20';
     g_seg_val_tab(20).segment_value      := '';
     g_seg_val_tab(21).cost_segment_name  := 'SEGMENT21';
     g_seg_val_tab(21).segment_value      := '';
     g_seg_val_tab(22).cost_segment_name  := 'SEGMENT22';
     g_seg_val_tab(22).segment_value      := '';
     g_seg_val_tab(23).cost_segment_name  := 'SEGMENT23';
     g_seg_val_tab(23).segment_value      := '';
     g_seg_val_tab(24).cost_segment_name  := 'SEGMENT24';
     g_seg_val_tab(24).segment_value      := '';
     g_seg_val_tab(25).cost_segment_name  := 'SEGMENT25';
     g_seg_val_tab(25).segment_value      := '';
     g_seg_val_tab(26).cost_segment_name  := 'SEGMENT26';
     g_seg_val_tab(26).segment_value      := '';
     g_seg_val_tab(27).cost_segment_name  := 'SEGMENT27';
     g_seg_val_tab(27).segment_value      := '';
     g_seg_val_tab(28).cost_segment_name  := 'SEGMENT28';
     g_seg_val_tab(28).segment_value      := '';
     g_seg_val_tab(29).cost_segment_name  := 'SEGMENT29';
     g_seg_val_tab(29).segment_value      := '';
     g_seg_val_tab(30).cost_segment_name  := 'SEGMENT30';
     g_seg_val_tab(30).segment_value      := '';

  -- check if position at budget detail level has payroll which has default cost allocation
     OPEN csr_cost_allocation_keyflex_id;
       FETCH csr_cost_allocation_keyflex_id  INTO  l_cost_allocation_keyflex_id;
     CLOSE csr_cost_allocation_keyflex_id;

  hr_utility.set_location('cost_allocation_keyflex_id : '||l_cost_allocation_keyflex_id,10);

  --
    IF NVL(l_cost_allocation_keyflex_id,0) <> 0 THEN
      --
       OPEN csr_cost_segments (p_cost_allocation_keyflex_id => l_cost_allocation_keyflex_id);
         FETCH csr_cost_segments  INTO  l_pay_cost_allocation_rec;
       CLOSE csr_cost_segments;

              -- assign the defaults at payroll level
              -- populate the g_seg_val_tab with the segment values
              -- g_seg_val_tab will have all the 30 segment names and their values
                 g_seg_val_tab(1).cost_segment_name  := 'SEGMENT1';
                 g_seg_val_tab(1).segment_value      := l_pay_cost_allocation_rec.segment1;
                 g_seg_val_tab(2).cost_segment_name  := 'SEGMENT2';
                 g_seg_val_tab(2).segment_value      := l_pay_cost_allocation_rec.segment2;
                 g_seg_val_tab(3).cost_segment_name  := 'SEGMENT3';
                 g_seg_val_tab(3).segment_value      := l_pay_cost_allocation_rec.segment3;
                 g_seg_val_tab(4).cost_segment_name  := 'SEGMENT4';
                 g_seg_val_tab(4).segment_value      := l_pay_cost_allocation_rec.segment4;
                 g_seg_val_tab(5).cost_segment_name  := 'SEGMENT5';
                 g_seg_val_tab(5).segment_value      := l_pay_cost_allocation_rec.segment5;
                 g_seg_val_tab(6).cost_segment_name  := 'SEGMENT6';
                 g_seg_val_tab(6).segment_value      := l_pay_cost_allocation_rec.segment6;
                 g_seg_val_tab(7).cost_segment_name  := 'SEGMENT7';
                 g_seg_val_tab(7).segment_value      := l_pay_cost_allocation_rec.segment7;
                 g_seg_val_tab(8).cost_segment_name  := 'SEGMENT8';
                 g_seg_val_tab(8).segment_value      := l_pay_cost_allocation_rec.segment8;
                 g_seg_val_tab(9).cost_segment_name  := 'SEGMENT9';
                 g_seg_val_tab(9).segment_value      := l_pay_cost_allocation_rec.segment9;
                 g_seg_val_tab(10).cost_segment_name  := 'SEGMENT10';
                 g_seg_val_tab(10).segment_value      := l_pay_cost_allocation_rec.segment10;
                 g_seg_val_tab(11).cost_segment_name  := 'SEGMENT11';
                 g_seg_val_tab(11).segment_value      := l_pay_cost_allocation_rec.segment11;
                 g_seg_val_tab(12).cost_segment_name  := 'SEGMENT12';
                 g_seg_val_tab(12).segment_value      := l_pay_cost_allocation_rec.segment12;
                 g_seg_val_tab(13).cost_segment_name  := 'SEGMENT13';
                 g_seg_val_tab(13).segment_value      := l_pay_cost_allocation_rec.segment13;
                 g_seg_val_tab(14).cost_segment_name  := 'SEGMENT14';
                 g_seg_val_tab(14).segment_value      := l_pay_cost_allocation_rec.segment14;
                 g_seg_val_tab(15).cost_segment_name  := 'SEGMENT15';
                 g_seg_val_tab(15).segment_value      := l_pay_cost_allocation_rec.segment15;
                 g_seg_val_tab(16).cost_segment_name  := 'SEGMENT16';
                 g_seg_val_tab(16).segment_value      := l_pay_cost_allocation_rec.segment16;
                 g_seg_val_tab(17).cost_segment_name  := 'SEGMENT17';
                 g_seg_val_tab(17).segment_value      := l_pay_cost_allocation_rec.segment17;
                 g_seg_val_tab(18).cost_segment_name  := 'SEGMENT18';
                 g_seg_val_tab(18).segment_value      := l_pay_cost_allocation_rec.segment18;
                 g_seg_val_tab(19).cost_segment_name  := 'SEGMENT19';
                 g_seg_val_tab(19).segment_value      := l_pay_cost_allocation_rec.segment19;
                 g_seg_val_tab(20).cost_segment_name  := 'SEGMENT20';
                 g_seg_val_tab(20).segment_value      := l_pay_cost_allocation_rec.segment20;
                 g_seg_val_tab(21).cost_segment_name  := 'SEGMENT21';
                 g_seg_val_tab(21).segment_value      := l_pay_cost_allocation_rec.segment21;
                 g_seg_val_tab(22).cost_segment_name  := 'SEGMENT22';
                 g_seg_val_tab(22).segment_value      := l_pay_cost_allocation_rec.segment22;
                 g_seg_val_tab(23).cost_segment_name  := 'SEGMENT23';
                 g_seg_val_tab(23).segment_value      := l_pay_cost_allocation_rec.segment23;
                 g_seg_val_tab(24).cost_segment_name  := 'SEGMENT24';
                 g_seg_val_tab(24).segment_value      := l_pay_cost_allocation_rec.segment24;
                 g_seg_val_tab(25).cost_segment_name  := 'SEGMENT25';
                 g_seg_val_tab(25).segment_value      := l_pay_cost_allocation_rec.segment25;
                 g_seg_val_tab(26).cost_segment_name  := 'SEGMENT26';
                 g_seg_val_tab(26).segment_value      := l_pay_cost_allocation_rec.segment26;
                 g_seg_val_tab(27).cost_segment_name  := 'SEGMENT27';
                 g_seg_val_tab(27).segment_value      := l_pay_cost_allocation_rec.segment27;
                 g_seg_val_tab(28).cost_segment_name  := 'SEGMENT28';
                 g_seg_val_tab(28).segment_value      := l_pay_cost_allocation_rec.segment28;
                 g_seg_val_tab(29).cost_segment_name  := 'SEGMENT29';
                 g_seg_val_tab(29).segment_value      := l_pay_cost_allocation_rec.segment29;
                 g_seg_val_tab(30).cost_segment_name  := 'SEGMENT30';
                 g_seg_val_tab(30).segment_value      := l_pay_cost_allocation_rec.segment30;


    END IF; -- get defaults for the payroll



  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END get_payroll_defaults;

--------------------------------------------------------------------------------------------------------------
PROCEDURE get_element_link_defaults
(
 p_budget_detail_id         IN pqh_budget_details.budget_detail_id%TYPE,
 p_budget_period_id         IN   pqh_budget_periods.budget_period_id%TYPE
) IS
/*
  This procedure wil check if there are any defaults for the position and element in
  pay_element_links if the position id is not null at budget detail level. We would get the
  defaults from pay_element_links table and assign to g_seg_val_tab table
  We would only assign those segments which are not null. That way we would only override the segments
  which were set by payroll if the segment value at this level is not null.
*/

--
-- local variables
--
l_proc                    varchar2(72) := g_package||' .get_element_link_defaults';

 l_cost_allocation_keyflex_id   pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE;
 l_pay_cost_allocation_rec      pay_cost_allocation_keyflex%ROWTYPE;

CURSOR  csr_cost_allocation_keyflex_id IS
SELECT  cost_allocation_keyflex_id
  FROM  pqh_budget_details bdt, pqh_budget_periods bpr,
        pqh_budget_sets bst, pqh_budget_elements bel,
        pay_element_links pel
WHERE  bdt.budget_detail_id  =  bpr.budget_detail_id
  AND  bpr.budget_period_id  =  bst.budget_period_id
  AND  bst.budget_set_id     =  bel.budget_set_id
  AND  bdt.position_id       =  pel.position_id
  AND  bel.element_type_id   =  pel.element_type_id
  AND  bdt.budget_detail_id  =  p_budget_detail_id
  AND  bpr.budget_period_id  =  p_budget_period_id ;


 CURSOR csr_cost_segments (p_cost_allocation_keyflex_id IN number) IS
 SELECT *
 FROM pay_cost_allocation_keyflex
 WHERE cost_allocation_keyflex_id = p_cost_allocation_keyflex_id;




BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

  -- check if position at budget detail level has default cost allocation
     OPEN csr_cost_allocation_keyflex_id;
       FETCH csr_cost_allocation_keyflex_id  INTO  l_cost_allocation_keyflex_id;
     CLOSE csr_cost_allocation_keyflex_id;

  hr_utility.set_location('Element Link cost_allocation_keyflex_id : '||l_cost_allocation_keyflex_id,10);

  --
  --
    IF NVL(l_cost_allocation_keyflex_id,0) <> 0 THEN
      --
       OPEN csr_cost_segments (p_cost_allocation_keyflex_id => l_cost_allocation_keyflex_id);
         FETCH csr_cost_segments  INTO  l_pay_cost_allocation_rec;
       CLOSE csr_cost_segments;

              -- assign the defaults at position and element level for only not null values so that we don't erase information
              -- entered at payroll level
                 g_seg_val_tab(1).segment_value       := NVL(l_pay_cost_allocation_rec.segment1,g_seg_val_tab(1).segment_value);
                 g_seg_val_tab(2).segment_value       := NVL(l_pay_cost_allocation_rec.segment2,g_seg_val_tab(2).segment_value);
                 g_seg_val_tab(3).segment_value       := NVL(l_pay_cost_allocation_rec.segment3,g_seg_val_tab(3).segment_value);
                 g_seg_val_tab(4).segment_value       := NVL(l_pay_cost_allocation_rec.segment4,g_seg_val_tab(4).segment_value);
                 g_seg_val_tab(5).segment_value       := NVL(l_pay_cost_allocation_rec.segment5,g_seg_val_tab(5).segment_value);
                 g_seg_val_tab(6).segment_value       := NVL(l_pay_cost_allocation_rec.segment6,g_seg_val_tab(6).segment_value);
                 g_seg_val_tab(7).segment_value       := NVL(l_pay_cost_allocation_rec.segment7,g_seg_val_tab(7).segment_value);
                 g_seg_val_tab(8).segment_value       := NVL(l_pay_cost_allocation_rec.segment8,g_seg_val_tab(8).segment_value);
                 g_seg_val_tab(9).segment_value       := NVL(l_pay_cost_allocation_rec.segment9,g_seg_val_tab(9).segment_value);
                 g_seg_val_tab(10).segment_value      := NVL(l_pay_cost_allocation_rec.segment10,g_seg_val_tab(10).segment_value);
                 g_seg_val_tab(11).segment_value      := NVL(l_pay_cost_allocation_rec.segment11,g_seg_val_tab(11).segment_value);
                 g_seg_val_tab(12).segment_value      := NVL(l_pay_cost_allocation_rec.segment12,g_seg_val_tab(12).segment_value);
                 g_seg_val_tab(13).segment_value      := NVL(l_pay_cost_allocation_rec.segment13,g_seg_val_tab(13).segment_value);
                 g_seg_val_tab(14).segment_value      := NVL(l_pay_cost_allocation_rec.segment14,g_seg_val_tab(14).segment_value);
                 g_seg_val_tab(15).segment_value      := NVL(l_pay_cost_allocation_rec.segment15,g_seg_val_tab(15).segment_value);
                 g_seg_val_tab(16).segment_value      := NVL(l_pay_cost_allocation_rec.segment16,g_seg_val_tab(16).segment_value);
                 g_seg_val_tab(17).segment_value      := NVL(l_pay_cost_allocation_rec.segment17,g_seg_val_tab(17).segment_value);
                 g_seg_val_tab(18).segment_value      := NVL(l_pay_cost_allocation_rec.segment18,g_seg_val_tab(18).segment_value);
                 g_seg_val_tab(19).segment_value      := NVL(l_pay_cost_allocation_rec.segment19,g_seg_val_tab(19).segment_value);
                 g_seg_val_tab(20).segment_value      := NVL(l_pay_cost_allocation_rec.segment20,g_seg_val_tab(20).segment_value);
                 g_seg_val_tab(21).segment_value      := NVL(l_pay_cost_allocation_rec.segment21,g_seg_val_tab(21).segment_value);
                 g_seg_val_tab(22).segment_value      := NVL(l_pay_cost_allocation_rec.segment22,g_seg_val_tab(22).segment_value);
                 g_seg_val_tab(23).segment_value      := NVL(l_pay_cost_allocation_rec.segment23,g_seg_val_tab(23).segment_value);
                 g_seg_val_tab(24).segment_value      := NVL(l_pay_cost_allocation_rec.segment24,g_seg_val_tab(24).segment_value);
                 g_seg_val_tab(25).segment_value      := NVL(l_pay_cost_allocation_rec.segment25,g_seg_val_tab(25).segment_value);
                 g_seg_val_tab(26).segment_value      := NVL(l_pay_cost_allocation_rec.segment26,g_seg_val_tab(26).segment_value);
                 g_seg_val_tab(27).segment_value      := NVL(l_pay_cost_allocation_rec.segment27,g_seg_val_tab(27).segment_value);
                 g_seg_val_tab(28).segment_value      := NVL(l_pay_cost_allocation_rec.segment28,g_seg_val_tab(28).segment_value);
                 g_seg_val_tab(29).segment_value      := NVL(l_pay_cost_allocation_rec.segment29,g_seg_val_tab(29).segment_value);
                 g_seg_val_tab(30).segment_value      := NVL(l_pay_cost_allocation_rec.segment30,g_seg_val_tab(30).segment_value);

    END IF; -- defaults at position and element level




  hr_utility.set_location('Leaving:'||l_proc, 1000);


EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END get_element_link_defaults;

--------------------------------------------------------------------------------------------------------------
PROCEDURE get_organization_defaults
(
 p_budget_detail_id         IN pqh_budget_details.budget_detail_id%TYPE
) IS
/*
  For the about budget_detail_id ,it will check if the Organization ID is not null.
  If the Organization is not null, we would get the defaults for this Organization ID
  from hr_organization_units table and assign to g_seg_val_tab table
  We would only assign those segments which are not null. That way we would only override the segments
  which were set by payroll if the segment value at this level is not null.

*/
--
-- local variables
--
l_proc                    varchar2(72) := g_package||' .get_organization_defaults';

 l_cost_allocation_keyflex_id   pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE;
 l_pay_cost_allocation_rec      pay_cost_allocation_keyflex%ROWTYPE;

CURSOR csr_cost_allocation_keyflex_id IS
SELECT  cost_allocation_keyflex_id
  FROM  pqh_budget_details bdt,
        hr_all_organization_units org
WHERE   bdt.budget_detail_id = p_budget_detail_id
  AND   bdt.organization_id = org.organization_id;


 CURSOR csr_cost_segments (p_cost_allocation_keyflex_id IN number) IS
 SELECT *
 FROM pay_cost_allocation_keyflex
 WHERE cost_allocation_keyflex_id = p_cost_allocation_keyflex_id;




BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

  -- check if organization at budget detail level has default cost allocation
     OPEN csr_cost_allocation_keyflex_id;
       FETCH csr_cost_allocation_keyflex_id  INTO  l_cost_allocation_keyflex_id;
     CLOSE csr_cost_allocation_keyflex_id;

  hr_utility.set_location('cost_allocation_keyflex_id : '||l_cost_allocation_keyflex_id,10);

  --
    IF NVL(l_cost_allocation_keyflex_id,0) <> 0 THEN
      --
       OPEN csr_cost_segments (p_cost_allocation_keyflex_id => l_cost_allocation_keyflex_id);
         FETCH csr_cost_segments  INTO  l_pay_cost_allocation_rec;
       CLOSE csr_cost_segments;

              -- assign the defaults at organization level for only not null values so that we don't erase information
              -- entered at payroll level
                 g_seg_val_tab(1).segment_value       := NVL(l_pay_cost_allocation_rec.segment1,g_seg_val_tab(1).segment_value);
                 g_seg_val_tab(2).segment_value       := NVL(l_pay_cost_allocation_rec.segment2,g_seg_val_tab(2).segment_value);
                 g_seg_val_tab(3).segment_value       := NVL(l_pay_cost_allocation_rec.segment3,g_seg_val_tab(3).segment_value);
                 g_seg_val_tab(4).segment_value       := NVL(l_pay_cost_allocation_rec.segment4,g_seg_val_tab(4).segment_value);
                 g_seg_val_tab(5).segment_value       := NVL(l_pay_cost_allocation_rec.segment5,g_seg_val_tab(5).segment_value);
                 g_seg_val_tab(6).segment_value       := NVL(l_pay_cost_allocation_rec.segment6,g_seg_val_tab(6).segment_value);
                 g_seg_val_tab(7).segment_value       := NVL(l_pay_cost_allocation_rec.segment7,g_seg_val_tab(7).segment_value);
                 g_seg_val_tab(8).segment_value       := NVL(l_pay_cost_allocation_rec.segment8,g_seg_val_tab(8).segment_value);
                 g_seg_val_tab(9).segment_value       := NVL(l_pay_cost_allocation_rec.segment9,g_seg_val_tab(9).segment_value);
                 g_seg_val_tab(10).segment_value      := NVL(l_pay_cost_allocation_rec.segment10,g_seg_val_tab(10).segment_value);
                 g_seg_val_tab(11).segment_value      := NVL(l_pay_cost_allocation_rec.segment11,g_seg_val_tab(11).segment_value);
                 g_seg_val_tab(12).segment_value      := NVL(l_pay_cost_allocation_rec.segment12,g_seg_val_tab(12).segment_value);
                 g_seg_val_tab(13).segment_value      := NVL(l_pay_cost_allocation_rec.segment13,g_seg_val_tab(13).segment_value);
                 g_seg_val_tab(14).segment_value      := NVL(l_pay_cost_allocation_rec.segment14,g_seg_val_tab(14).segment_value);
                 g_seg_val_tab(15).segment_value      := NVL(l_pay_cost_allocation_rec.segment15,g_seg_val_tab(15).segment_value);
                 g_seg_val_tab(16).segment_value      := NVL(l_pay_cost_allocation_rec.segment16,g_seg_val_tab(16).segment_value);
                 g_seg_val_tab(17).segment_value      := NVL(l_pay_cost_allocation_rec.segment17,g_seg_val_tab(17).segment_value);
                 g_seg_val_tab(18).segment_value      := NVL(l_pay_cost_allocation_rec.segment18,g_seg_val_tab(18).segment_value);
                 g_seg_val_tab(19).segment_value      := NVL(l_pay_cost_allocation_rec.segment19,g_seg_val_tab(19).segment_value);
                 g_seg_val_tab(20).segment_value      := NVL(l_pay_cost_allocation_rec.segment20,g_seg_val_tab(20).segment_value);
                 g_seg_val_tab(21).segment_value      := NVL(l_pay_cost_allocation_rec.segment21,g_seg_val_tab(21).segment_value);
                 g_seg_val_tab(22).segment_value      := NVL(l_pay_cost_allocation_rec.segment22,g_seg_val_tab(22).segment_value);
                 g_seg_val_tab(23).segment_value      := NVL(l_pay_cost_allocation_rec.segment23,g_seg_val_tab(23).segment_value);
                 g_seg_val_tab(24).segment_value      := NVL(l_pay_cost_allocation_rec.segment24,g_seg_val_tab(24).segment_value);
                 g_seg_val_tab(25).segment_value      := NVL(l_pay_cost_allocation_rec.segment25,g_seg_val_tab(25).segment_value);
                 g_seg_val_tab(26).segment_value      := NVL(l_pay_cost_allocation_rec.segment26,g_seg_val_tab(26).segment_value);
                 g_seg_val_tab(27).segment_value      := NVL(l_pay_cost_allocation_rec.segment27,g_seg_val_tab(27).segment_value);
                 g_seg_val_tab(28).segment_value      := NVL(l_pay_cost_allocation_rec.segment28,g_seg_val_tab(28).segment_value);
                 g_seg_val_tab(29).segment_value      := NVL(l_pay_cost_allocation_rec.segment29,g_seg_val_tab(29).segment_value);
                 g_seg_val_tab(30).segment_value      := NVL(l_pay_cost_allocation_rec.segment30,g_seg_val_tab(30).segment_value);

    END IF; -- defaults at organization level




  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END get_organization_defaults;
--------------------------------------------------------------------------------------------------------------
PROCEDURE reverse_prev_posted_version
IS
/*
  Added on 10/10/2000 -- At any point of time , only ONE budget version can be posted to GL.
  The column TRANSFERED_TO_GL_FLAG in pqh_budget_versions will indicate the last posted version.
  For a given budget, only one budget_version will have TRANSFERED_TO_GL_FLAG = 'Y' , which is the last
  posted version.
  We check if the current budget_version_id has TRANSFERED_TO_GL_FLAG = 'Y' ,
  If Yes => this is the last posted version and the user is doing adjustments on the version.
   We don't do anything in this case as our current code takes care of adjustments
  If No => the last posted version is different then the current version. So we get the last posted
  budget_version_id and create reverse txns for this from the pqh_gl_interface table.
  We will also update the following :
  Budget Version table :
     For last Posted Version :
       TRANSFERED_TO_GL_FLAG for the last posted version to 'N '
       gl_status = 'UNPOST'
     For the current budget_version :
        After posting the current version we will update the TRANSFERED_TO_GL_FLAG to Y for the current version.
        gl_status = POST or ERROR

  Budget Detail table :
     For last Posted Version :
        gl_status = NULL ( for all records )
     For the current budget_version :
        handled by the current posting logic, will be set to POST or ERROR



*/
--
-- local variables
--
l_proc                    varchar2(72) := g_package||' .reverse_prev_posted_version';

l_pqh_gl_interface_rec    pqh_gl_interface%ROWTYPE;

CURSOR csr_last_posted_ver IS
SELECT budget_version_id
  FROM pqh_budget_versions
 WHERE budget_id = g_budget_id
   AND NVL(transfered_to_gl_flag,'N') = 'Y';

CURSOR csr_unpost_version (p_budget_version_id IN number )IS
SELECT *
FROM pqh_gl_interface
WHERE budget_version_id    = p_budget_version_id
   AND NVL(adjustment_flag,'N') = 'N'
   AND posting_type_cd = 'BUDGET'
   AND status IS NOT NULL
   AND posting_date IS NOT NULL
   AND (NVL(amount_dr,0) > 0 OR NVL(amount_cr,0) > 0 )
  FOR UPDATE of amount_dr;

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

  -- get the last posted budget_version
     OPEN csr_last_posted_ver;
       FETCH csr_last_posted_ver INTO g_last_posted_ver;
     CLOSE csr_last_posted_ver;

  hr_utility.set_location('Last Posted Version is : '||g_last_posted_ver,6);
  hr_utility.set_location('Current Budget Version is : '||g_budget_version_id,6);

     IF NVL(g_last_posted_ver,0) <> g_budget_version_id THEN

        OPEN csr_unpost_version(p_budget_version_id => g_last_posted_ver);
          LOOP
            FETCH csr_unpost_version INTO  l_pqh_gl_interface_rec;
            EXIT WHEN csr_unpost_version%NOTFOUND;

               -- update the current record
                     UPDATE pqh_gl_interface
                        SET amount_dr = 0
                      WHERE CURRENT OF csr_unpost_version;

               -- create the reverse txn
                        INSERT INTO pqh_gl_interface
                        (
                          gl_interface_id,
                          budget_version_id,
                          budget_detail_id,
                          period_name,
                          accounting_date,
                          code_combination_id,
                          cost_allocation_keyflex_id,
                          project_id,
			  task_id,
			  award_id,
			  expenditure_type,
                          organization_id,
                          amount_dr,
                          amount_cr,
                          currency_code,
                          status,
                          adjustment_flag,
                          posting_date,
                          posting_type_cd
                        )
                        VALUES
                        (
                          pqh_gl_interface_s.nextval,
                          g_last_posted_ver,
                          l_pqh_gl_interface_rec.budget_detail_id,
                          l_pqh_gl_interface_rec.period_name,
                          l_pqh_gl_interface_rec.accounting_date,
                          l_pqh_gl_interface_rec.code_combination_id,
                          l_pqh_gl_interface_rec.cost_allocation_keyflex_id,
                          l_pqh_gl_interface_rec.project_id,
			  l_pqh_gl_interface_rec.task_id,
			  l_pqh_gl_interface_rec.award_id,
			  l_pqh_gl_interface_rec.expenditure_type,
                          l_pqh_gl_interface_rec.organization_id,
                          0,
                          NVL(l_pqh_gl_interface_rec.amount_dr,0),
                          l_pqh_gl_interface_rec.currency_code,
                          null,
                          'Y',
                          null,
                          'BUDGET'
                        );



          END LOOP;
        CLOSE csr_unpost_version;

        -- update the last posted version, gl_status to UNPOST and TRANSFERED_TO_GL_FLAG to N
           UPDATE pqh_budget_versions
              SET transfered_to_gl_flag = 'N' ,
                              gl_status = 'UNPOST'
           WHERE budget_version_id = g_last_posted_ver;

        -- update the budget_detail records corresponding to this version , set gl_status to null
           UPDATE pqh_budget_details
              SET gl_status = ''
            WHERE  budget_version_id = g_last_posted_ver;

       --
       -- Reverse commitment posting .
       --
       reverse_commitment_post(p_last_posted_ver    => g_last_posted_ver,
                               p_curr_bdgt_version  => g_budget_version_id);
       --


     END IF; -- if the current version is not the last posted version



  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END reverse_prev_posted_version;

--------------------------------------------------------------------------------------------------------------
--
-- Added the following wrapper to get_gl_ccid function so that the code
-- can be re-used in commitment gl posting
--
PROCEDURE get_ccid_for_commitment(
p_budget_id                  IN pqh_budgets.budget_id%type,
p_chart_of_accounts_id       IN gl_interface.chart_of_accounts_id%TYPE,
p_budget_detail_id           IN pqh_budget_details.budget_detail_id%TYPE,
p_budget_period_id           IN pqh_budget_periods.budget_period_id%TYPE,
p_cost_allocation_keyflex_id IN pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE,
p_code_combination_id        OUT NOCOPY gl_code_combinations.code_combination_id%TYPE) IS
--
l_code_combination_id        gl_code_combinations.code_combination_id%TYPE;
--
l_proc                    varchar2(72) := g_package||'.get_ccid_for_commitment';
--
BEGIN
--
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  g_budget_id := p_budget_id;
  g_chart_of_accounts_id := p_chart_of_accounts_id;
--
  --
  get_gl_ccid
  (
  p_budget_detail_id            => p_budget_detail_id,
  p_budget_period_id            => p_budget_period_id,
  p_cost_allocation_keyflex_id  => p_cost_allocation_keyflex_id,
  p_code_combination_id         => l_code_combination_id
  );
--
  p_code_combination_id := l_code_combination_id;
--
  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
      p_code_combination_id := null;
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END;

--
-- Added the following wrapper to end_commitment_log function so that the code
-- can be re-used in commitment gl posting
--

PROCEDURE end_commitment_log(p_status          OUT NOCOPY varchar2) IS
--
l_proc                    varchar2(72) := g_package||'.end_commitment_log';
--
BEGIN
--
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  end_log;
--
  p_status := g_status;
--
  hr_utility.set_location('Leaving:'||l_proc, 1000);
--
EXCEPTION
      WHEN OTHERS THEN
      p_status := null;
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END;



PROCEDURE reverse_commitment_post(p_last_posted_ver          IN  NUMBER,
                                  p_curr_bdgt_version        IN  NUMBER) IS
--
l_pqh_gl_interface_rec pqh_gl_interface%ROWTYPE;
l_proc                 varchar2(72) := g_package||'.reverse_commitment_post';
--
CURSOR csr_unpost_version (p_budget_version_id IN number )IS
SELECT *
FROM pqh_gl_interface
WHERE budget_version_id    = p_budget_version_id
   AND NVL(adjustment_flag,'N') = 'N'
   AND posting_type_cd = 'COMMITMENT'
   AND status IS NOT NULL
   AND posting_date IS NOT NULL
   AND (NVL(amount_dr,0) > 0 OR NVL(amount_cr,0) > 0 )
  FOR UPDATE of amount_dr;
--
BEGIN
--
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  hr_utility.set_location('Current Budget Version is:'||p_curr_bdgt_version,6);

  IF NVL(p_last_posted_ver,0) <> p_curr_bdgt_version THEN
     --
     OPEN csr_unpost_version(p_budget_version_id => p_last_posted_ver);
     --
     LOOP
          FETCH csr_unpost_version INTO  l_pqh_gl_interface_rec;
          EXIT WHEN csr_unpost_version%NOTFOUND;

          -- update the current record
          UPDATE pqh_gl_interface
             SET amount_dr = 0
           WHERE CURRENT OF csr_unpost_version;

          -- create the reverse txn
          INSERT INTO pqh_gl_interface
          (
                          gl_interface_id,
                          budget_version_id,
                          budget_detail_id,
                          period_name,
                          accounting_date,
                          code_combination_id,
                          cost_allocation_keyflex_id,
                          project_id,
			  task_id,
			  award_id,
			  expenditure_type,
                          organization_id,
                          amount_dr,
                          amount_cr,
                          currency_code,
                          status,
                          adjustment_flag,
                          posting_date,
                          posting_type_cd
           )
           VALUES
           (
                          pqh_gl_interface_s.nextval,
                          g_last_posted_ver,
                          l_pqh_gl_interface_rec.budget_detail_id,
                          l_pqh_gl_interface_rec.period_name,
                          l_pqh_gl_interface_rec.accounting_date,
                          l_pqh_gl_interface_rec.code_combination_id,
                          l_pqh_gl_interface_rec.cost_allocation_keyflex_id,
                          l_pqh_gl_interface_rec.project_id,
			  l_pqh_gl_interface_rec.task_id,
			  l_pqh_gl_interface_rec.award_id,
			  l_pqh_gl_interface_rec.expenditure_type,
                          l_pqh_gl_interface_rec.organization_id,
                          0,
                          NVL(l_pqh_gl_interface_rec.amount_dr,0),
                          l_pqh_gl_interface_rec.currency_code,
                          null,
                          'Y',
                          null,
                          'BUDGET'
           );
           --
      END LOOP;
      --
      CLOSE csr_unpost_version;
      --
      -- update the last posted version, commitment_gl_status to UNPOST
      --
      UPDATE pqh_budget_versions
         SET commitment_gl_status = 'UNPOST'
      WHERE budget_version_id = g_last_posted_ver;
      --
      -- update the budget_detail records corresponding to this version
      --
      UPDATE pqh_budget_details
         SET commitment_gl_status = 'UNPOST'
       WHERE budget_version_id = g_last_posted_ver;
      --
  END IF; -- if the current version is not the last posted version
  --
  hr_utility.set_location('Leaving:'||l_proc, 1000);
  --
EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END reverse_commitment_post;

FUNCTION chk_budget_details(p_budget_version_id  IN  pqh_budget_details.budget_version_id%TYPE )
  RETURN varchar2 IS
/*
   This function will determine whether the budget has details or not
   If the budget has details return 'Y' else 'N'

*/
l_budget_fund_src_id  pqh_budget_fund_srcs.budget_fund_src_id%TYPE;
l_result              varchar2(30);

 CURSOR csr_budget_details (p_budget_version_id  IN number )IS
 SELECT bfs.budget_fund_src_id
 FROM pqh_budget_details bdt, pqh_budget_periods bpr, pqh_budget_sets bst, pqh_budget_elements bel, pqh_budget_fund_srcs bfs
 WHERE bdt.budget_version_id  =  p_budget_version_id
   and bdt.budget_detail_id  = bpr.budget_detail_id
   and bpr.budget_period_id = bst.budget_period_id
   and bst.budget_set_id = bel.budget_set_id
   and bel.budget_element_id = bfs.budget_element_id;

BEGIN

  OPEN csr_budget_details(p_budget_version_id);
    FETCH csr_budget_details INTO  l_budget_fund_src_id;
  CLOSE csr_budget_details;
  If l_budget_fund_src_id is NOT NULL then
     l_result := 'Y';
  else
     l_result := 'N';
    end if;
  return l_result;
END chk_budget_details;

-------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
PROCEDURE populate_period_enc_tab
(
p_budget_detail_id IN pqh_budget_details.budget_detail_id%TYPE
) IS

/*
  This procedure will read the above populated global table g_period_amt_tab and get the
  LD encumbrance amount for the period_id .
  For each period of Budget Detail, all Assignments of the Budget Detail Position are found .
  For each such Assignment a call for LD function will be made to get LD Encumbrance amount.
  Sum of this encumbrance amount over all Assignments will give Period Encumbrance amount.
  This function will then call adjust_ptaeo_gms_amount to prorate across all PTAEO's for that period.

  Any exception encountered in this procedure will terminate the program.
*/

--
--------------------  Local Variables ----------------------------
--

i                         binary_integer :=0;
p_enc                     binary_integer :=0;
inx                       binary_integer :=0;
l_start_pid               number;
l_end_pid                 number;
l_entity_id               number;
l_period_encumbrance      number;
l_assign_encumbrance      number;
l_assignment_id           number;
/*l_ptaeo_amt               number;
l_ptaeo_adjustment        number;*/
l_period_tot_amt          number;
l_budget_period_id        number :=-1;
l_unit_of_measure         number :=-1;
l_period_start_date       date;
l_period_end_date         date;
l_assg_start_date         date;
l_assg_end_date           date;
l_encumbrance_start_date  date;
l_encumbrance_end_date    date;
l_dummy                   date;
l_asg_psp_encumbered      boolean;
l_return_status           varchar2(10);
l_uom1                    varchar2(80);
l_uom2                    varchar2(80);
l_uom3                    varchar2(80);
l_proc                    varchar2(72) := g_package||'.populate_period_enc_tab';
l_encumbrance_table       psp_pqh_integration.encumbrance_table_rec_col;

------Local Types------
TYPE t_period_enc_type IS RECORD
(
 budget_period_id number,
 enc_amount       number
);

-- PL / SQL table based on the above structure
TYPE t_period_enc_tab IS TABLE OF t_period_enc_type
  INDEX BY BINARY_INTEGER;

TYPE t_bin_array IS TABLE OF BINARY_INTEGER
  INDEX BY BINARY_INTEGER;

l_period_encumbrance_tab   t_period_enc_tab;
l_num                      t_bin_array;

----------------------------------Cursors-----------------------------------------

-- Cursors to get Budget Detail Entity

Cursor budget_detail_position IS
Select position_id
From
pqh_budget_details
where budget_detail_id = p_budget_detail_id;

Cursor budget_detail_org IS
Select organization_id
From
pqh_budget_details
where budget_detail_id = p_budget_detail_id;

Cursor budget_detail_grd IS
Select grade_id
From
pqh_budget_details
where budget_detail_id = p_budget_detail_id;

Cursor budget_detail_job IS
Select job_id
From
pqh_budget_details
where budget_detail_id = p_budget_detail_id;
--
-- Cursors to get Budget Detail Entity Assignments

Cursor budget_period_pos_assignments(start_date date,end_date date) IS
Select
assignment_id,
effective_start_date,
effective_end_date
From per_all_assignments_f
Where position_id=l_entity_id and
(
(effective_start_date <=start_date AND effective_end_date >start_date)
 OR
(effective_start_date <=end_date AND effective_end_date >end_date)
);


Cursor budget_period_org_assignments(start_date date,end_date date) IS
Select
assignment_id,
effective_start_date,
effective_end_date
From per_all_assignments_f
Where organization_id=l_entity_id and
(
(effective_start_date <=start_date AND effective_end_date >start_date)
 OR
(effective_start_date <=end_date AND effective_end_date >end_date)
);


Cursor budget_period_grd_assignments(start_date date,end_date date) IS
Select
assignment_id,
effective_start_date,
effective_end_date
From per_all_assignments_f
Where grade_id=l_entity_id and
(
(effective_start_date <=start_date AND effective_end_date >start_date)
 OR
(effective_start_date <=end_date AND effective_end_date >end_date)
);


Cursor budget_period_job_assignments(start_date date,end_date date) IS
Select
assignment_id,
effective_start_date,
effective_end_date
From per_all_assignments_f
Where job_id=l_entity_id and
(
(effective_start_date <=start_date AND effective_end_date >start_date)
 OR
(effective_start_date <=end_date AND effective_end_date >end_date)
);
--

Cursor csr_budget_time_periods(p_budget_period_id NUMBER) IS
Select
start_time_period_id,
end_time_period_id
From
pqh_budget_periods
Where
budget_period_id = p_budget_period_id;

Cursor csr_time_periods(p_time_period_id NUMBER)IS
Select
start_date,
end_date
From
per_time_periods
Where
time_period_id = p_time_period_id;

Cursor csr_budget_units IS
Select
hr_general.decode_shared_type(budget_unit1_id) UOM1,
hr_general.decode_shared_type(budget_unit2_id) UOM2,
hr_general.decode_shared_type(budget_unit3_id) UOM3
From
pqh_budgets
Where budget_id=g_budget_id;

Cursor csr_last_posted_ver IS
Select budget_version_id
From pqh_budget_versions
Where     budget_id = g_budget_id
      AND NVL(transfered_to_gl_flag,'N') = 'Y';


Begin

hr_utility.set_location('Entering: '||l_proc, 5);

--
-- Get ID of primary Entity attached with Budget Detail
--
IF   (g_budgeted_entity_cd='POSITION') THEN
      OPEN budget_detail_position;
      FETCH budget_detail_position into l_entity_id;
      CLOSE budget_detail_position;

ELSIF(g_budgeted_entity_cd='ORGANIZATION')  THEN
      OPEN budget_detail_org;
      FETCH budget_detail_org into l_entity_id;
      CLOSE budget_detail_org;

ELSIF(g_budgeted_entity_cd='GRADE')  THEN
      OPEN budget_detail_grd;
      FETCH budget_detail_grd into l_entity_id;
      CLOSE budget_detail_grd;

ELSIF(g_budgeted_entity_cd='JOB')  THEN
      OPEN budget_detail_job;
      FETCH budget_detail_job into l_entity_id;
      CLOSE budget_detail_job;
END IF;



--
--For each Period in Budget Details get LD encumbrance amount across Assignments
--

FOR i in 1..g_period_amt_tab.COUNT
LOOP
 --
 --Calculate Encumbrnace for a Period only if atleast one Funding source for that period is PTAEO
 --
 IF (g_period_amt_tab(i).cost_allocation_keyflex_id is null AND
     g_period_amt_tab(i).period_id<> l_budget_period_id)
 THEN
  --
  hr_utility.set_location('Processing Period:'||g_period_amt_tab(i).period_id, 10);
  --
  l_period_encumbrance :=0;
  l_budget_period_id := g_period_amt_tab(i).period_id;
  --
  --Get Budget Period start and end time period id's
  --
  OPEN csr_budget_time_periods(l_budget_period_id);
  FETCH csr_budget_time_periods into l_start_pid,l_end_pid;
  CLOSE csr_budget_time_periods;
  --
  -- Get Budget Periods start date
  --
  OPEN  csr_time_periods(l_start_pid);
  FETCH csr_time_periods into l_period_start_date,l_dummy;
  CLOSE csr_time_periods;
  --
  --Get Budget Periods end date
  --
  OPEN  csr_time_periods(l_end_pid);
  FETCH csr_time_periods into l_dummy, l_period_end_date;
  CLOSE csr_time_periods;
  --
  -- For each Position Assignment calculate LD encumbrance for that period
  --
  IF   (g_budgeted_entity_cd='POSITION') THEN

       OPEN  budget_period_pos_assignments(l_period_start_date,l_period_end_date);

  ELSIF(g_budgeted_entity_cd='ORGANIZATION')  THEN

       OPEN  budget_period_org_assignments(l_period_start_date,l_period_end_date);

  ELSIF(g_budgeted_entity_cd='GRADE')  THEN

       OPEN  budget_period_grd_assignments(l_period_start_date,l_period_end_date);

  ELSIF(g_budgeted_entity_cd='JOB')  THEN

      OPEN  budget_period_job_assignments(l_period_start_date,l_period_end_date);

  END IF;
     -- For each assignment
    LOOP

  IF   (g_budgeted_entity_cd='POSITION') THEN

         FETCH budget_period_pos_assignments into l_assignment_id,l_assg_start_date ,l_assg_end_date;
         IF budget_period_pos_assignments%NOTFOUND THEN
          CLOSE budget_period_pos_assignments;
          EXIT;
         END IF;

    ELSIF(g_budgeted_entity_cd='ORGANIZATION')  THEN

         FETCH budget_period_org_assignments into  l_assignment_id,l_assg_start_date ,l_assg_end_date;
         IF budget_period_org_assignments%NOTFOUND THEN
          CLOSE budget_period_org_assignments;
          EXIT;
         END IF;

    ELSIF(g_budgeted_entity_cd='GRADE')  THEN

         FETCH budget_period_grd_assignments into l_assignment_id,l_assg_start_date ,l_assg_end_date;
         IF budget_period_grd_assignments%NOTFOUND THEN
          CLOSE budget_period_grd_assignments;
          EXIT;
         END IF;

    ELSIF(g_budgeted_entity_cd='JOB')  THEN

        FETCH budget_period_job_assignments into  l_assignment_id,l_assg_start_date ,l_assg_end_date;
        IF budget_period_job_assignments%NOTFOUND THEN
         CLOSE budget_period_job_assignments;
         EXIT;
        END IF;

  END IF;
   l_assign_encumbrance  :=0;
   --
   --Get Encumbrance dates
   --
   IF (l_assg_start_date > l_period_start_date)
   THEN
    l_encumbrance_start_date := l_assg_start_date;
   ELSE
    l_encumbrance_start_date := l_period_start_date;
   END IF;
   IF (l_assg_end_date < l_period_end_date)
   THEN
    l_encumbrance_end_date := l_assg_end_date;
   ELSE
    l_encumbrance_end_date := l_period_end_date;
   END IF;
   --
   hr_utility.set_location('Calling LD Function with Followin params',20);
   hr_utility.set_location('Processing Assignment:'||l_assignment_id, 22);
   hr_utility.set_location('Encumbrance Start Date:'||l_encumbrance_start_date, 24);
   hr_utility.set_location('Encumbracne End Date :'||l_encumbrance_end_date, 26);
   --
   --Call LD functions to get Encumbered amount
   --
   psp_pqh_integration.get_asg_encumbrances(l_assignment_id,
                        l_encumbrance_start_date ,
                        l_encumbrance_end_date ,
                        l_encumbrance_table,
                        l_asg_psp_encumbered,
                        l_return_status);
   IF(l_asg_psp_encumbered) THEN
     hr_utility.set_location('Assignment Encumbered by LD :'||l_assign_encumbrance, 30);
   FOR psp_inx IN 1..l_encumbrance_table.r_gms_enc_amount.COUNT LOOP
   hr_utility.set_location('GMS Amount :'||l_encumbrance_table.r_gms_enc_amount(psp_inx), 31);
   l_assign_encumbrance  := l_assign_encumbrance   +l_encumbrance_table.r_gms_enc_amount(psp_inx);
   END LOOP;
   l_period_encumbrance := l_period_encumbrance + l_assign_encumbrance;
   END IF;
   --
   hr_utility.set_location('Assignment Encumbrance:'||l_assign_encumbrance, 35);
   --
  END LOOP; -- Assignment Loop
  p_enc := p_enc + 1;
  hr_utility.set_location('Period Encumbrance:'||l_period_encumbrance, 40);
  l_period_encumbrance_tab(p_enc).budget_period_id  :=l_budget_period_id;
  l_period_encumbrance_tab(p_enc).enc_amount :=l_period_encumbrance;
 END IF;
END LOOP;
/*
  Now for each period in l_period_encumbrance_tab find corresponding records in g_period_amt_tab
  Reduce Money units amount for those records based on enc_amount.
*/
--
--Find Which of three budget_units is Money Unit
--
OPEN csr_budget_units;
FETCH csr_budget_units into l_uom1, l_uom2,l_uom3;
CLOSE csr_budget_units;

IF    NVL(l_uom1,'X')='Money' THEN
                           l_unit_of_measure :=1;
   ELSIF NVL(l_uom2,'X')='Money' THEN
                           l_unit_of_measure :=2;
   ELSIF NVL(l_uom3,'X')='Money' THEN
                           l_unit_of_measure :=3;
   END IF;
--
-- If current Budget version id not Last posted Budget Version then entries in
-- pqh_gms_excess would be meaningless. Hence delete them.
--
OPEN  csr_last_posted_ver;
FETCH csr_last_posted_ver INTO g_last_posted_ver;
IF (csr_last_posted_ver%FOUND AND g_last_posted_ver  <> g_budget_version_id)
THEN
  DELETE from pqh_gms_excess
  WHERE  budget_period_id in (Select budget_period_id
                              From
                              pqh_budget_periods bpr
                             ,pqh_budget_details bdt
                              Where bpr.budget_detail_id = bdt.budget_detail_id AND
                              bdt.budget_version_id=g_budget_version_id);
END IF;
CLOSE csr_last_posted_ver;
--
hr_utility.set_location('Corrections for LD Encumbrance', 45);
--
FOR psp_inx IN 1..l_period_encumbrance_tab.COUNT
LOOP
 --
 hr_utility.set_location('Updating Period :'||l_period_encumbrance_tab(psp_inx).budget_period_id, 50);
 --
 l_period_encumbrance :=l_period_encumbrance_tab(psp_inx).enc_amount;
 l_period_tot_amt     :=0;
 inx                  :=0;
 --
 --Find all PTAEO's that need to be adjusted for that Budget Period and get sum total of Money posted
 -- to GMS by Budget for that period. We require this to pro-rate LD encumbrances across available PTAEO's
 --
 FOR i in 1..g_period_amt_tab.COUNT
 LOOP
  IF ( g_period_amt_tab(i).period_id = l_period_encumbrance_tab(psp_inx).budget_period_id
       AND
       g_period_amt_tab(i).cost_allocation_keyflex_id is null
     )
  THEN
   --
   --Set Currency Code
   --
   inx        := inx +1;
   l_num(inx) := i;
   IF    NVL(l_uom1,'X')='Money' THEN
                          l_period_tot_amt :=l_period_tot_amt + g_period_amt_tab(i).amount1;
   ELSIF NVL(l_uom2,'X')='Money' THEN
                          l_period_tot_amt :=l_period_tot_amt + g_period_amt_tab(i).amount2;
   ELSIF NVL(l_uom3,'X')='Money' THEN
                          l_period_tot_amt :=l_period_tot_amt + g_period_amt_tab(i).amount3;
   END IF;
  END IF;
 END LOOP;
--
hr_utility.set_location('Updating relevant PTAEOs', 55);
--
--Adjust PTAEO amount by Prorating Period Encumbrance across PTAEO's
--
IF l_period_tot_amt <> 0 THEN
FOR inx in 1..l_num.COUNT
LOOP
--
--For Each PTAEO in period make adjustments according to LD encumbrance/Liquidation.
--Also store Excess amounts if any in pqh_gms_excess table
--
adjust_ptaeo_gms_amount(l_num(inx),l_unit_of_measure,l_period_encumbrance,l_period_tot_amt);
--
END LOOP;
END IF;
--
END LOOP;
--
hr_utility.set_location('Leaving:'||l_proc, 1000);
--
EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END populate_period_enc_tab;

------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
PROCEDURE adjust_ptaeo_gms_amount
(
p_inx                IN binary_integer,
p_unit_of_measure    IN number,
p_period_encumbrance IN number,
p_period_tot_amount  IN number
)  IS
/*
This procedure makes adjustments to PTAEO gms amount based on LD encumbrance/Liquidation for this period.
prorates period_encumbrance across all PTAEO's for that period.
Excess Encumbrance amount over PTAEO amount if any will be stored in pqh_gms_execess table.
*/

--
--  Cursor to Fetch GMS excess amount for that PTAEO.
-- IF LD encumbered amont 700 for a period but PTAEO in that period is only transfering 200 then excess
-- 500 will be kept in pqh_gms_excess table for that budget_period and PTAEO
--
Cursor csr_ptaeo_excess(inx binary_integer) IS
Select amount
From pqh_gms_excess
Where
     budget_period_id =g_period_amt_tab(inx).period_id
AND  project_id       =g_period_amt_tab(inx).project_id
AND  task_id          =g_period_amt_tab(inx).task_id
AND  award_id         =g_period_amt_tab(inx).award_id
AND  expenditure_type =g_period_amt_tab(inx).expenditure_type
AND  organization_id  =g_period_amt_tab(inx).organization_id;

------------------------------Local Variables-------------------------------
l_ptaeo_amt         number;
l_ptaeo_adjustment  number;
l_ptaeo_excess      number;
l_proc              varchar2(72) := g_package||'.adjust_ptaeo_gms_amount';

Begin
--
hr_utility.set_location('Entering:'||l_proc, 10);
--
IF    (p_unit_of_measure =1) THEN
                                  l_ptaeo_amt :=g_period_amt_tab(p_inx).amount1;
ELSIF (p_unit_of_measure =2) THEN
                                  l_ptaeo_amt :=g_period_amt_tab(p_inx).amount2;
ELSIF (p_unit_of_measure =3) THEN
                                  l_ptaeo_amt :=g_period_amt_tab(p_inx).amount3;
END IF;

hr_utility.set_location('Original PTAEO Amount:'||l_ptaeo_amt, 20);
--
-- Prorate period_encumbrance across all PTAEO's in that budget period
--
l_ptaeo_adjustment :=p_period_encumbrance *(l_ptaeo_amt/p_period_tot_amount)*100;
hr_utility.set_location('Prorated PTAEO Adjustment:'||l_ptaeo_adjustment, 20);
--
-- Check if there is any excess for that PTAEO/Period
--
OPEN  csr_ptaeo_excess(p_inx);
FETCH csr_ptaeo_excess into l_ptaeo_excess;
--
IF csr_ptaeo_excess%FOUND
THEN
 hr_utility.set_location('Existing PTAEO Excess:'||l_ptaeo_excess, 30);
 --
 -- If excess is there and LD is liquidating take excess into consideration
 -- If excess is more than liquidation we  dont need any adjustment for that PTAEO
 -- If excess is less than liquidation adjust for remaining amount
 --
 IF l_ptaeo_adjustment <0
 THEN
  --
  IF (ABS(l_ptaeo_adjustment) <l_ptaeo_excess)
  THEN
   l_ptaeo_excess     := l_ptaeo_excess + l_ptaeo_adjustment;
   l_ptaeo_adjustment :=0;
  ELSE
   l_ptaeo_adjustment :=l_ptaeo_adjustment + l_ptaeo_excess;
   l_ptaeo_excess     :=0;
  END IF;
  --
  l_ptaeo_amt         := l_ptaeo_amt - l_ptaeo_adjustment;
 --
 -- If Ld is encumbering then deduct PTAEO adjustment from budget PTAEO amount
 -- If result is negative then we need not transfer anything for that PTAEO/Period and
 -- we will stor excess in pqh_gl_excess
 --
 ELSE
  l_ptaeo_amt  := l_ptaeo_amt - l_ptaeo_adjustment;
  --
  IF l_ptaeo_amt <0 THEN
     l_ptaeo_excess := l_ptaeo_excess + ABS(l_ptaeo_amt);
     l_ptaeo_amt    :=0;

  END IF;
  --
 END IF;
 hr_utility.set_location('PTAEO Excess after Adjustment:'||l_ptaeo_excess, 40);
 --
 -- If net PTAEO excess after all adjustments is  zero delete record, otherwise update
 --
   IF l_ptaeo_excess = 0 THEN
    --
    DELETE FROM PQH_GMS_EXCESS
    WHERE     budget_period_id =g_period_amt_tab(p_inx).period_id
          AND project_id       =g_period_amt_tab(p_inx).project_id
          AND task_id          =g_period_amt_tab(p_inx).task_id
          AND award_id         =g_period_amt_tab(p_inx).award_id
          AND expenditure_type =g_period_amt_tab(p_inx).expenditure_type
          AND organization_id  =g_period_amt_tab(p_inx).organization_id;
   --
   ELSE
   --
    UPDATE PQH_GMS_EXCESS
    SET amount = l_ptaeo_excess
    WHERE     budget_period_id =g_period_amt_tab(p_inx).period_id
          AND project_id       =g_period_amt_tab(p_inx).project_id
          AND task_id          =g_period_amt_tab(p_inx).task_id
          AND award_id         =g_period_amt_tab(p_inx).award_id
          AND expenditure_type =g_period_amt_tab(p_inx).expenditure_type
          AND organization_id  =g_period_amt_tab(p_inx).organization_id;
   --
   END IF;
--
-- If currently there is no excess for that PTAEO/Period and PTAEO amount after adjustment is negative
-- post that amount to pqh_gms_excess and make PTAEO maount as zero
--
ELSE
 l_ptaeo_amt  := l_ptaeo_amt - l_ptaeo_adjustment;
 hr_utility.set_location('PTAEO Excess after Adjustment:'||-l_ptaeo_amt, 50);
 --
 IF l_ptaeo_amt < 0 THEN
  INSERT into pqh_gms_excess
   ( GMS_EXCESS_ID
    ,BUDGET_PERIOD_ID
    ,PROJECT_ID
    ,TASK_ID
    ,AWARD_ID
    ,EXPENDITURE_TYPE
    ,ORGANIZATION_ID
    ,AMOUNT
   )
  VALUES
   (
    pqh_gms_excess_s.nextval
    ,g_period_amt_tab(p_inx).period_id
    ,g_period_amt_tab(p_inx).project_id
    ,g_period_amt_tab(p_inx).task_id
    ,g_period_amt_tab(p_inx).award_id
    ,g_period_amt_tab(p_inx).expenditure_type
    ,g_period_amt_tab(p_inx).organization_id
    ,-l_ptaeo_amt
   );
  l_ptaeo_amt :=0;
 END IF;
 --
END IF;
--
-- Update global table with PTAEO amounts after adjustment
--
hr_utility.set_location('Adjusted PTAEO GMS amount:'||l_ptaeo_amt, 60);
IF    (p_unit_of_measure =1) THEN
                                 g_period_amt_tab(p_inx).amount1 :=l_ptaeo_amt;
ELSIF (p_unit_of_measure =2) THEN
                                 g_period_amt_tab(p_inx).amount2 :=l_ptaeo_amt;
ELSIF (p_unit_of_measure =3) THEN
                                 g_period_amt_tab(p_inx).amount3 :=l_ptaeo_amt;
END IF;
--
hr_utility.set_location('Leaving:'||l_proc, 100);
--
END adjust_ptaeo_gms_amount;

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

PROCEDURE populate_pqh_gms_interface
(
 p_budget_detail_id     IN pqh_budget_details.budget_detail_id%TYPE
)
IS
/*
  This procedure will update or insert GMS records into pqh_gl_interface if there was no error for
  the current budget detail record i.e g_detail_error = N
  if g_detail_error = Y then update the pqh_budget_details record with gl_status = ERROR
*/
--
-- local variables
--
 l_proc                           varchar2(72) := g_package||'.populate_pqh_gms_interface';
 l_pqh_gl_interface_rec           pqh_gl_interface%ROWTYPE;
 l_uom_count                      number;
 l_amount                         number;
 l_uom1                           varchar2(80);
 l_uom2                           varchar2(80);
 l_uom3                           varchar2(80);


 Cursor csr_pqh_gms_interface ( p_period_name      IN varchar2,
                                p_project_id	   IN  NUMBER,
                                p_task_id	   IN  NUMBER,
                                p_award_id	   IN  NUMBER,
                                p_expenditure_type IN  varchar2,
                                p_organization_id  IN  NUMBER) IS
 Select COUNT(*)
 From pqh_gl_interface
 Where budget_version_id  = g_budget_version_id
   AND budget_detail_id   = p_budget_detail_id
   AND period_name        = p_period_name
   AND posting_type_cd    = 'BUDGET'
   AND project_id	  = p_project_id
   AND task_id		  = p_task_id
   AND award_id		  = p_award_id
   AND expenditure_type	  = p_expenditure_type
   AND organization_id	  = p_organization_id
   AND NVL(adjustment_flag,'N') = 'N'
   AND status IS NOT NULL
   AND posting_date IS NOT NULL;


Cursor csr_budget_units IS
Select
hr_general.decode_shared_type(budget_unit1_id) UOM1,
hr_general.decode_shared_type(budget_unit2_id) UOM2,
hr_general.decode_shared_type(budget_unit3_id) UOM3
From
pqh_budgets
Where budget_id=g_budget_id;


BEGIN

  hr_utility.set_location('Entering: '||l_proc, 5);

  IF  g_detail_error = 'N' THEN
   OPEN csr_budget_units;
   FETCH csr_budget_units into l_uom1, l_uom2,l_uom3;
   CLOSE csr_budget_units;

    -- loop thru the array and get populate the pqh_gl_interface table

     FOR i IN 1..g_period_amt_tab.COUNT
     LOOP

     -- Populate only GMS records
      IF (g_period_amt_tab(i).cost_allocation_keyflex_id is  null)
      THEN
        IF    NVL(l_uom1,'X')='Money' THEN
                                         l_amount :=g_period_amt_tab(i).amount1;
              ELSIF NVL(l_uom2,'X')='Money' THEN
                                         l_amount :=g_period_amt_tab(i).amount2;
              ELSIF NVL(l_uom3,'X')='Money' THEN
                                  l_amount :=g_period_amt_tab(i).amount3;
       END IF;
       OPEN csr_pqh_gms_interface(p_period_name      => g_period_amt_tab(i).period_name,
                                  p_project_id       => g_period_amt_tab(i).project_id,
                                  p_task_id	     => g_period_amt_tab(i).task_id,
                                  p_award_id	     => g_period_amt_tab(i).award_id,
                                  p_expenditure_type => g_period_amt_tab(i).expenditure_type,
                                  p_organization_id  => g_period_amt_tab(i).organization_id );
       FETCH csr_pqh_gms_interface INTO l_uom_count;
       CLOSE csr_pqh_gms_interface;


       IF l_uom_count <> 0 THEN
           -- update pqh_gl_interface and create a adjustment txn
       update_pqh_gms_interface
              (
               p_budget_detail_id  => p_budget_detail_id,
               p_period_name       => g_period_amt_tab(i).period_name,
               p_project_id        => g_period_amt_tab(i).project_id,
	       p_task_id	   => g_period_amt_tab(i).task_id,
	       p_award_id	   => g_period_amt_tab(i).award_id,
	       p_expenditure_type  => g_period_amt_tab(i).expenditure_type,
               p_organization_id   => g_period_amt_tab(i).organization_id,
               p_amount            => l_amount
              );
         ELSE
           -- insert into pqh_gl_interface
       insert_pqh_gms_interface
                     (
                      p_budget_detail_id  => p_budget_detail_id,
                      p_period_name       => g_period_amt_tab(i).period_name,
                      p_project_id        => g_period_amt_tab(i).project_id,
       	              p_task_id	          => g_period_amt_tab(i).task_id,
       	              p_award_id	  => g_period_amt_tab(i).award_id,
       	              p_expenditure_type  => g_period_amt_tab(i).expenditure_type,
                      p_organization_id   => g_period_amt_tab(i).organization_id,
                      p_amount            => l_amount
              );
       END IF;  -- l_uom1_count <> 0

      END IF; -- Insert only GMS records
     END LOOP; -- end of pl sql table

      -- update pqh_budget_details reset status if previous run was ERROR
      UPDATE pqh_budget_details
         SET gl_status = ''
       WHERE budget_detail_id = p_budget_detail_id;



  ELSE  -- g_detail_error = Y i.e errors in budget details children

      -- update pqh_budget_details
      UPDATE pqh_budget_details
         SET gl_status = 'ERROR'
       WHERE budget_detail_id = p_budget_detail_id;

  END IF; -- g_detail_error = 'N'

  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END populate_pqh_gms_interface;

---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
PROCEDURE insert_pqh_gms_interface
(
 p_budget_detail_id  IN pqh_gl_interface.budget_detail_id%TYPE,
 p_period_name       IN varchar2,
 p_project_id        IN pqh_gl_interface.project_id%TYPE,
 p_task_id	     IN pqh_gl_interface.task_id%TYPE,
 p_award_id	     IN pqh_gl_interface.award_id%TYPE,
 p_expenditure_type  IN pqh_gl_interface.expenditure_type%TYPE,
 p_organization_id   IN pqh_gl_interface.organization_id%TYPE,
 p_amount            IN pqh_gl_interface.amount_dr%TYPE
) IS
 /*
  This procedure will insert record into pqh_gl_interface
  If the same UOM is repeated more then once then we would update the unposted txn.
 */
 --
-- local variables
--
 l_proc                         varchar2(72) := g_package||'.insert_pqh_gms_interface';
 l_count                        number(9) := 0 ;

 Cursor csr_pqh_gms_interface IS
 Select COUNT(*)
 From   pqh_gl_interface
 Where budget_version_id        = g_budget_version_id
   AND budget_detail_id         = p_budget_detail_id
   AND p_period_name            = p_period_name
   AND posting_type_cd          = 'BUDGET'
   AND project_id               = p_project_id
   AND task_id	   	        = p_task_id
   AND award_id	   	        = p_award_id
   AND expenditure_type	        = p_expenditure_type
   AND organization_id 	        = p_organization_id
   AND NVL(adjustment_flag,'N') = 'N'
   AND status IS NULL
   AND posting_date IS NULL;

BEGIN

  hr_utility.set_location('Entering: '||l_proc, 5);

  -- check if its a repeat of that same UOM
  OPEN csr_pqh_gms_interface;
  FETCH csr_pqh_gms_interface INTO l_count;
  CLOSE csr_pqh_gms_interface;

  hr_utility.set_location('l_count in Insert pqh_gl_interface : '||l_count,10);

  IF l_count <> 0 THEN

  -- this is a repeat of UOM , so update the first one adding the new amount
    UPDATE pqh_gl_interface
       SET AMOUNT_DR                = NVL(AMOUNT_DR,0) + NVL(p_amount,0)
     WHERE budget_version_id        = g_budget_version_id
       AND budget_detail_id         = p_budget_detail_id
       AND p_period_name            = p_period_name
       AND posting_type_cd          = 'BUDGET'
       AND project_id               = p_project_id
       AND task_id	   	    = p_task_id
       AND award_id	   	    = p_award_id
       AND expenditure_type	    = p_expenditure_type
       AND organization_id 	    = p_organization_id
       AND NVL(adjustment_flag,'N') = 'N'
       AND status IS NULL
       AND posting_date IS NULL;

 ELSE

   -- insert this record
     INSERT INTO pqh_gl_interface
     (
       gl_interface_id,
       budget_version_id,
       budget_detail_id,
       period_name,
       project_id,
       task_id,
       award_id,
       expenditure_type,
       organization_id,
       amount_dr,
       amount_cr,
       currency_code,
       status,
       adjustment_flag,
       posting_date,
       posting_type_cd
     )
     VALUES
     (
       pqh_gl_interface_s.nextval,
       g_budget_version_id,
       p_budget_detail_id,
       p_period_name,
       p_project_id,
       p_task_id,
       p_award_id,
       p_expenditure_type,
       p_organization_id,
       NVL(p_amount,0),
       0,
       g_bgt_currency_code,
       null,
       null,
       null,
       'BUDGET'
     );

 END IF;  -- l_count <> 0 UOM repeated


  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END insert_pqh_gms_interface;
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
PROCEDURE update_pqh_gms_interface
(
 p_budget_detail_id  IN pqh_gl_interface.budget_detail_id%TYPE,
 p_period_name       IN varchar2,
 p_project_id        IN pqh_gl_interface.project_id%TYPE,
 p_task_id	     IN pqh_gl_interface.task_id%TYPE,
 p_award_id	     IN pqh_gl_interface.award_id%TYPE,
 p_expenditure_type  IN pqh_gl_interface.expenditure_type%TYPE,
 p_organization_id   IN pqh_gl_interface.organization_id%TYPE,
 p_amount            IN pqh_gl_interface.amount_dr%TYPE
) IS
 /*
  This procedure will update pqh_gl_interface and create a adjustment record
 */
 --
-- local variables
--
 l_proc                         varchar2(72) := g_package||'.update_pqh_gms_interface';
 l_amount_diff                  pqh_gl_interface.amount_dr%TYPE :=0;
 l_amount_dr                    pqh_gl_interface.amount_dr%TYPE :=0;
 l_amount_cr                    pqh_gl_interface.amount_cr%TYPE :=0;
 l_pqh_gl_interface_rec         pqh_gl_interface%ROWTYPE;


 CURSOR csr_pqh_gms_interface IS
 SELECT *
  FROM pqh_gl_interface
 WHERE budget_version_id        = g_budget_version_id
   AND budget_detail_id         = p_budget_detail_id
   AND period_name              = p_period_name
   AND posting_type_cd          = 'BUDGET'
   AND project_id               = p_project_id
   AND task_id	   	        = p_task_id
   AND award_id	   	        = p_award_id
   AND expenditure_type	        = p_expenditure_type
   AND organization_id 	        = p_organization_id
   AND NVL(adjustment_flag,'N') = 'N'
   AND status IS NOT NULL
   AND posting_date IS NOT NULL
  FOR UPDATE of amount_dr;


BEGIN

  hr_utility.set_location('Entering: '||l_proc, 5);

  OPEN csr_pqh_gms_interface;
  FETCH csr_pqh_gms_interface INTO l_pqh_gl_interface_rec;

  l_amount_diff := NVL(p_amount,0) - NVL(l_pqh_gl_interface_rec.amount_dr,0);

  IF l_amount_diff > 0 THEN
    -- debit as new is more then old
    l_amount_dr := l_amount_diff;
  ELSE
    -- credit as new is less then old
    l_amount_cr := (-1)*l_amount_diff;
  END IF;
    -- update the pqh_gl_interface table
     UPDATE pqh_gl_interface
       SET amount_dr = NVL(p_amount,0)
      WHERE CURRENT OF csr_pqh_gms_interface;

  CLOSE csr_pqh_gms_interface;

   -- create i.e insert a adjustment record ONLY if l_amount_diff <> 0
     IF NVL(l_amount_diff,0) <> 0 THEN

       INSERT INTO pqh_gl_interface
       (
         gl_interface_id,
         budget_version_id,
         budget_detail_id,
         period_name,
         project_id,
	 task_id,
	 award_id,
	 expenditure_type,
         organization_id,
         amount_dr,
         amount_cr,
         currency_code,
         status,
         adjustment_flag,
         posting_date,
         posting_type_cd
       )
       VALUES
       (
         pqh_gl_interface_s.nextval,
         g_budget_version_id,
         p_budget_detail_id,
         p_period_name,
         p_project_id,
	 p_task_id,
	 p_award_id,
	 p_expenditure_type,
         p_organization_id,
         NVL(l_amount_dr,0),
         NVL(l_amount_cr,0),
         g_bgt_currency_code,
         null,
         'Y',
         null,
         'BUDGET'
       );

     END IF; -- create i.e insert a adjustment record ONLY if l_amount_diff <> 0


  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END update_pqh_gms_interface;
--------------------------------------------------------------------------------------------------------
function get_gms_rejection_msg (p_rejection_code in varchar2) return varchar2 is
cursor rej_msg is
SELECT substr(l.description, 1, 240 ) meaning
  FROM pa_lookups l
 WHERE l.lookup_type in ('TRANSACTION REJECTION REASON','FC_RESULT_CODE',
                         'COST DIST REJECTION CODE','INVOICE_CURRENCY',
                         'TRANSACTION USER REJ REASON')
   AND l.lookup_code = p_rejection_code
UNION all
SELECT message_text
  FROM fnd_new_messages fnd
 WHERE language_code    = userenv('lang')
   AND fnd.message_name = p_rejection_code
   AND application_id   = 275; -- PA

 l_message  fnd_new_messages.message_text%Type;
begin
  open rej_msg;
  fetch rej_msg into l_message;
  close rej_msg;

  return l_message;
end;

---------------------------------------------------------------------------------------------------------
PROCEDURE gms_pqh_tie_back
(
 p_gms_batch_name	IN  VARCHAR2
)
 IS
/*
This procedure ties back all the transactions posted into Oracle Grants Mgmt with records in pqh_gl_interface
In case of failure the status in pqh_gl_interface is updated to error
*/
--
-- Cursor to get records rejected by import process
--
CURSOR gms_tie_back_reject_cur IS
SELECT
 nvl(transaction_rejection_code,'P') rejection_code,
 orig_transaction_reference,
 transaction_status_code
FROM   pa_transaction_interface_all
WHERE  transaction_source = 'GMSEPQHBC'
  AND  batch_name = p_gms_batch_name
  AND  transaction_status_code in ('R', 'PI', 'PR', 'PO');


l_proc         varchar2(72) := g_package||'.gms_pqh_tie_back';
l_int_id       BINARY_INTEGER;
l_cnt          number;


Begin
 hr_utility.set_location('Entering:'||l_proc, 5);
 --
 -- If transaction_status_code = 'P' then the transaction import process did not kick off
 -- for some reason.
 -- If transaction_status_code = 'I' then the transaction import process did not complete
 -- the Post Processing extension.
 -- In both cases import for all records failed
 --
 SELECT
  count(*)  into l_cnt
 FROM  pa_transaction_interface_all
 WHERE transaction_source = 'GMSEPQHBC'
   And batch_name = p_gms_batch_name
   And transaction_status_code in ('P', 'I');

--
-- IF import for all records failed then update status in pqh_gl_interface to error
--
 IF l_cnt > 0
 THEN

  hr_utility.set_location('GMS Import is not Complete:'||to_char(l_cnt), 10);
  --
  hr_utility.set_message(8302,'PQH_TR_GMS_IMP_FAILED');
  populate_globals_error
      (
       p_message_text => FND_MESSAGE.get
      );
  RAISE g_error_exception;
  --
 ELSE
  hr_utility.set_location('GMS Import is complete', 15);
  --
  FOR reject_rec in  gms_tie_back_reject_cur
  LOOP
   l_int_id := to_number(substr(reject_rec.orig_transaction_reference,
                          instr(reject_rec.orig_transaction_reference,'-')+1));
   hr_utility.set_location('Import failed for:'||l_int_id, 20);
   hr_utility.set_location('Failure Code: '||reject_rec.rejection_code, 22);

  populate_globals_error (
       p_message_text => get_gms_rejection_msg(reject_rec.rejection_code));

   begin

   UPDATE pqh_gl_interface
     SET status='ERROR',posting_date=sysdate
   WHERE period_name      =g_gms_import_tab(l_int_id).period_name And
         project_id       =g_gms_import_tab(l_int_id).project_id And
         task_id          =g_gms_import_tab(l_int_id).task_id And
         award_id         =g_gms_import_tab(l_int_id).award_id And
         expenditure_type =g_gms_import_tab(l_int_id).expenditure_type And
         organization_id  =g_gms_import_tab(l_int_id).organization_id;

 EXCEPTION
   when no_data_found then
        null;
   WHEN g_error_exception THEN
    RAISE;
   WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc||l_int_id);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
  end;
  END LOOP;
  --

 END IF;
--
--For each record that failed in import update budget_detail status
--
 hr_utility.set_location('Set Budget Detail status to Error', 25);
 begin
 UPDATE pqh_budget_details
  SET gl_status = 'ERROR'
 Where budget_detail_id in (select budget_detail_id from pqh_gl_interface where
                            budget_version_id=g_budget_version_id
                            And cost_allocation_keyflex_id is null
                            And status='ERROR'
                           );
 exception
   when no_data_found then
        null;
   WHEN g_error_exception THEN
    RAISE;
   WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc||'2');
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
 end;
 hr_utility.set_location('Leaving:'||l_proc, 100);

 EXCEPTION
   WHEN g_error_exception THEN
    RAISE;
   WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END gms_pqh_tie_back;


-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
PROCEDURE purge_pa_tables(
                 p_gms_batch_name IN varchar2
                )
 IS
 /*
 Procedure to purge records from pa_transaction_interface_all and gms_transaction_interface_all
 once Import process is complete
 */
 l_proc             varchar2(72) := g_package||'.purge_pa_tables';
 PRAGMA             AUTONOMOUS_TRANSACTION;

 BEGIN
 hr_utility.set_location('Entering:'||l_proc, 10);
 DELETE pa_transaction_interface_all
 WHERE  batch_name = p_gms_batch_name
    And transaction_source = 'GMSEPQHBC';

 hr_utility.set_location('Deleted pa_transaction_interface_all:',20);

 DELETE gms_transaction_interface_all
 WHERE  batch_name = p_gms_batch_name
    And transaction_source = 'GMSEPQHBC';

 hr_utility.set_location('Deleted gms_transaction_interface_all:',30);
 COMMIT;
 hr_utility.set_location('Transaction commited:',40);
 hr_utility.set_location('Leaving:'||l_proc, 100);
 EXCEPTION
 WHEN OTHERS THEN
        ROLLBACK;
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
 END purge_pa_tables;
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
PROCEDURE populate_pa_tables(
                    p_gms_batch_name OUT NOCOPY varchar2,
                    p_call_status    OUT NOCOPY BOOLEAN
                   )
 IS
 /*
 This procedure populates pa_transaction_interface_all and gms_transaction_interface_all tables
 and submits conc request to import records in to projects.
 It waits till conc request is complete
 */
 gms_rec	        gms_transaction_interface_all%ROWTYPE;
 l_proc                 varchar2(72) := g_package||'.populate_pa_tables';
 call_status		BOOLEAN;
 rphase			VARCHAR2(30);
 rstatus		VARCHAR2(30);
 dphase			VARCHAR2(30);
 dstatus		VARCHAR2(30);
 message		VARCHAR2(240);
 l_return_status        VARCHAR2(30);
 l_txn_interface_id	number(15);
 req_id			NUMBER(15);
 PRAGMA                 AUTONOMOUS_TRANSACTION;
 begin
 hr_utility.set_location('Entering:'||l_proc, 10);
 --
 -- Select Batch Name for Transaction
 --
 Select
  'PQH'||to_char(pqh_gms_batch_name_s.nextval) INTO p_gms_batch_name
 From  dual;

 hr_utility.set_location('Batch Name: '||p_gms_batch_name, 15);

 FOR cnt in 1..g_gms_import_tab.COUNT LOOP

 hr_utility.set_location('Processing Record:'||g_gms_import_tab(cnt).ORIG_TRANSACTION_REFERENCE, 20);
  --
  --  Get the transaction_interface_id. We need this to populate the gms_interface table.
  --
  Select pa_txn_interface_s.nextval
         INTO l_txn_interface_id
  From dual;
  --
  -- Insert in to PA_TRANSACTIONS_ALL
  --
  INSERT INTO PA_TRANSACTION_INTERFACE_ALL
  (
    TXN_INTERFACE_ID
   ,TRANSACTION_SOURCE
   ,BATCH_NAME
   ,EXPENDITURE_ENDING_DATE
   ,ORGANIZATION_NAME
   ,EXPENDITURE_ITEM_DATE
   ,PROJECT_NUMBER
   ,TASK_NUMBER
   ,EXPENDITURE_TYPE
   ,QUANTITY
   ,TRANSACTION_STATUS_CODE
   ,ORIG_TRANSACTION_REFERENCE
   ,ORG_ID
   ,DENOM_CURRENCY_CODE
   ,DENOM_RAW_COST
  )
  VALUES
  (
    l_txn_interface_id
   ,g_gms_import_tab(cnt).TRANSACTION_SOURCE
   ,p_gms_batch_name
   ,g_gms_import_tab(cnt).EXPENDITURE_ENDING_DATE
   ,g_gms_import_tab(cnt).ORGANIZATION_NAME
   ,g_gms_import_tab(cnt).EXPENDITURE_ITEM_DATE
   ,g_gms_import_tab(cnt).PROJECT_NUMBER
   ,g_gms_import_tab(cnt).TASK_NUMBER
   ,g_gms_import_tab(cnt).EXPENDITURE_TYPE
   ,g_gms_import_tab(cnt).QUANTITY
   ,'P'
   ,g_gms_import_tab(cnt).ORIG_TRANSACTION_REFERENCE
   ,g_gms_import_tab(cnt).ORG_ID
   ,g_gms_import_tab(cnt).DENOM_CURRENCY_CODE
   ,g_gms_import_tab(cnt).amount
  );


 --
 -- insert into gms_interface table
 --

  GMS_REC.TXN_INTERFACE_ID 	     := l_txn_interface_id;
  GMS_REC.BATCH_NAME 	             := p_gms_batch_name;
  GMS_REC.TRANSACTION_SOURCE 	     := g_gms_import_tab(cnt).TRANSACTION_SOURCE;
  GMS_REC.EXPENDITURE_ENDING_DATE    := g_gms_import_tab(cnt).EXPENDITURE_ENDING_DATE;
  GMS_REC.EXPENDITURE_ITEM_DATE	     := g_gms_import_tab(cnt).EXPENDITURE_ITEM_DATE ;
  GMS_REC.PROJECT_NUMBER 	     := g_gms_import_tab(cnt).PROJECT_NUMBER;
  GMS_REC.TASK_NUMBER 	  	     := g_gms_import_tab(cnt).TASK_NUMBER;
  GMS_REC.AWARD_ID 	    	     := g_gms_import_tab(cnt).AWARD_ID ;
  GMS_REC.EXPENDITURE_TYPE 	     := g_gms_import_tab(cnt).EXPENDITURE_TYPE;
  GMS_REC.TRANSACTION_STATUS_CODE    := 'P';
  GMS_REC.ORIG_TRANSACTION_REFERENCE := g_gms_import_tab(cnt).ORIG_TRANSACTION_REFERENCE;
  GMS_REC.ORG_ID 	  	     := g_gms_import_tab(cnt).ORG_ID;
  GMS_REC.SYSTEM_LINKAGE	     := NULL;
  GMS_REC.USER_TRANSACTION_SOURCE    := NULL;
  GMS_REC.TRANSACTION_TYPE 	     := NULL;
  GMS_REC.BURDENABLE_RAW_COST 	     := g_gms_import_tab(cnt).AMOUNT;
  GMS_REC.FUNDING_PATTERN_ID 	     := NULL;

  gms_transactions_pub.LOAD_GMS_XFACE_API(gms_rec, l_return_status);

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     hr_utility.set_location('gms_transactions_pub failed', 25);
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

 END LOOP;	-- g_gms_import_tab



 IF g_gms_import_tab.COUNT > 0
 THEN
   hr_utility.set_location('Submitting Request for batch: '||p_gms_batch_name, 30);
   req_id := 	fnd_request.submit_request(
                                  	   'PA',
                                  	   'PAXTRTRX',
                                 	    NULL,
                                  	    NULL,
                                  	    FALSE,
                                  	    'GMSEPQHBC',
                                  	    p_gms_batch_name
                                  	  );

 IF req_id = 0
 THEN
   hr_utility.set_location('Conc Request not submitted properly', 35);
   ROLLBACK;
   p_call_status :=false;
 ELSE
  hr_utility.set_location('Transaction commited', 40);
  COMMIT;
  call_status := fnd_concurrent.wait_for_request(req_id, 20, 0,
 		                                rphase, rstatus,
 		                                dphase, dstatus,
 		                                message
 		                               );
  p_call_status := call_status;
 END IF;
 END IF;
 EXCEPTION
 WHEN OTHERS THEN
    ROLLBACK;
    hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
    hr_utility.set_message_token('ROUTINE', l_proc);
    hr_utility.set_message_token('REASON', SQLERRM);
    hr_utility.raise_error;
 END populate_pa_tables;
 -----------------------------------------------------------------------------------------------------------
 ----------------------------------------------------------------------------------------------------------

PROCEDURE populate_gms_tables IS
/*
This procedure transfers records  from pqh_gl_interface to pa_transaction_interface_all,
kicks off the TRANSACTION IMPORT program in GMS
*/

---------------Local Variables---------------------------------------------
l_bg_id			  NUMBER(15) ;
l_org_name 		  hr_all_organization_units_tl.name%TYPE;
l_seg1			  VARCHAR2(25);
l_task_number		  pa_tasks.task_number%TYPE;
l_gms_batch_name	  VARCHAR2(10);
l_exp_end_dt		  DATE;
l_call_status		  BOOLEAN;
l_value			  VARCHAR2(200);
l_table			  VARCHAR2(100);
l_org_id	          NUMBER(15);
l_effective_date          DATE := trunc(sysdate);
l_gms_transaction_source  varchar2(30);
l_amount                  NUMBER;
tran_setup_exception      EXCEPTION;
tran_source_exception     EXCEPTION;
l_pqh_interface_rec       pqh_gl_interface%ROWTYPE;
l_log_context             pqh_process_log.log_context%TYPE;
l_proc                    varchar2(72) := g_package||'.populate_gms_interface';
l_log_message             varchar2(8000);
cnt                       BINARY_INTEGER := 1;
ref_cnt                       BINARY_INTEGER := 1;
l_period_name             NUMBER;
-----------------------------------------------------------------------
Cursor csr_budget_bg IS
Select business_group_id
From pqh_budgets
Where budget_id=g_budget_id;

Cursor csr_tran_srcs IS
Select transaction_source
From   pa_transaction_sources
Where  transaction_source = 'GMSEPQHBC';

Cursor csr_pqh_gms_interface IS
Select period_name,project_id,award_id,task_id,
       expenditure_type,organization_id,
       currency_code,
       SUM(NVL(amount_dr,0))  amount_dr,
       SUM(NVL(amount_cr,0))  amount_cr
From   pqh_gl_interface
Where  budget_version_id        = g_budget_version_id
   AND posting_type_cd          = 'BUDGET'
   AND status IS NULL
   AND posting_date IS NULL
   AND cost_allocation_keyflex_id IS NULL
   group by
   period_name,project_id,award_id,task_id,
   expenditure_type,organization_id,currency_code;


Cursor csr_hr_org_name(p_organization_id NUMBER) is
Select name
From   hr_organization_units
Where  organization_id   = p_organization_id
  AND  business_group_id = l_bg_id;

Cursor csr_pa_project_num (p_project_id NUMBER) IS
Select segment1,org_id
From   pa_projects_all
Where  project_id = p_project_id;


Cursor csr_pa_task_num(p_task_id NUMBER) IS
Select task_number
From   pa_tasks
Where  task_id = p_task_id;



 BEGIN
  hr_utility.set_location('Entering: '||l_proc, 5);

  OPEN csr_budget_bg;
  FETCH csr_budget_bg INTO l_bg_id;
  IF (csr_budget_bg%NOTFOUND) THEN
     CLOSE csr_budget_bg;
     l_value	:= 'Business Group Id';
     l_table 	:= 'pqh_budgets';
     RAISE tran_setup_exception;
  else
     CLOSE csr_budget_bg;
  END IF;
  --
  --Check if Transaction source is present .Other wise exit program
  --
  OPEN csr_tran_srcs;
  FETCH csr_tran_srcs INTO l_gms_transaction_source;
  IF (csr_tran_srcs%NOTFOUND) THEN
     CLOSE csr_tran_srcs;
     l_value	:= 'Transaction source ='||'GMSEPQHBC';
     l_table 	:= 'pa_transaction_sources';
     RAISE tran_source_exception;
  else
     CLOSE csr_tran_srcs;
  END IF;

 hr_utility.set_location('Transaction Source: '||l_gms_transaction_source, 10);

 l_exp_end_dt := nvl(pa_utils.getweekending(sysdate),sysdate);
 --
 --Prepare a batch containing all records to be imported
 --
 For C1 in csr_pqh_gms_interface LOOP
   hr_utility.set_location('Processing Period: '||C1.period_name, 20);
  l_period_name := to_number(C1.period_name);
  --
  -- Fetch Hr Org Name
  --
  hr_utility.set_location('organization : '||C1.organization_id, 21);
  OPEN csr_hr_org_name (C1.organization_id);
  FETCH csr_hr_org_name INTO 	l_org_name;
  IF (csr_hr_org_name%NOTFOUND) THEN
     CLOSE csr_hr_org_name;
     l_value	:= 'Org id ='||to_char(C1.organization_id);
     l_table 	:= 'HR_ORGANIZATION_UNITS';
     RAISE tran_setup_exception;
  else
     CLOSE csr_hr_org_name;
     hr_utility.set_location('org name : '||l_org_name, 22);
  END IF;
 --
 -- Fetch Project Number and Project Oraganization Id
 --
  hr_utility.set_location('project : '||C1.project_id, 23);
 OPEN csr_pa_project_num (C1.project_id);
 FETCH csr_pa_project_num INTO l_seg1,l_org_id;
 IF (csr_pa_project_num%NOTFOUND) THEN
    CLOSE csr_pa_project_num;
      l_value	:= 'Project id ='||to_char(C1.project_id);
      l_table 	:= 'PA_PROJECTS_ALL';
      RAISE tran_setup_exception;
 else
    CLOSE csr_pa_project_num;
    hr_utility.set_location('project number : '||l_seg1, 22);
 END IF;
 --
 --Fetch Task Number
 --
  hr_utility.set_location('task : '||C1.task_id, 24);
 OPEN csr_pa_task_num (C1.task_id);
 FETCH csr_pa_task_num INTO l_task_number;
 IF (csr_pa_task_num%NOTFOUND) THEN
    CLOSE csr_pa_task_num;
       l_value	:= 'Task id ='||to_char(C1.task_id);
       l_table 	:= 'PA_TASKS';
       RAISE tran_setup_exception;
 else
    CLOSE csr_pa_task_num;
    hr_utility.set_location('task num: '||l_task_number, 25);
 END IF;
 l_amount := C1.amount_dr + C1.amount_cr;
   hr_utility.set_location('setting tab row '||cnt, 26);

   select pqh_gms_orig_txn_reference_s.nextval
   into   ref_cnt
   from   dual;

   g_gms_import_tab(cnt).EXPENDITURE_ENDING_DATE     :=l_exp_end_dt;
   g_gms_import_tab(cnt).ORGANIZATION_NAME           :=l_org_name;
   g_gms_import_tab(cnt).EXPENDITURE_ITEM_DATE       :=l_effective_date;
   g_gms_import_tab(cnt).PROJECT_NUMBER              :=l_seg1;
   g_gms_import_tab(cnt).TASK_NUMBER                 :=l_task_number;
   g_gms_import_tab(cnt).QUANTITY                    :=1;
   g_gms_import_tab(cnt).ORIG_TRANSACTION_REFERENCE  :='PQH'||ref_cnt||'-'||cnt;
   g_gms_import_tab(cnt).ORG_ID                      :=l_org_id;
   g_gms_import_tab(cnt).TRANSACTION_SOURCE          :='GMSEPQHBC';
   g_gms_import_tab(cnt).Amount                      :=l_amount;
   g_gms_import_tab(cnt).DENOM_CURRENCY_CODE         :=C1.currency_code;
   g_gms_import_tab(cnt).PERIOD_NAME                 :=C1.PERIOD_NAME;
   g_gms_import_tab(cnt).PROJECT_ID                  :=C1.PROJECT_ID;
   g_gms_import_tab(cnt).TASK_ID                     :=C1.TASK_ID;
   g_gms_import_tab(cnt).AWARD_ID                    :=C1.AWARD_ID;
   g_gms_import_tab(cnt).EXPENDITURE_TYPE            :=C1.expenditure_type;
   g_gms_import_tab(cnt).ORGANIZATION_ID             :=C1.ORGANIZATION_ID;

   hr_utility.set_location('end setting tab row '||cnt, 27);
   cnt := cnt + 1;

 END LOOP;

 IF not g_validate THEN
   hr_utility.set_location('not validate mode : ', 30);
   hr_utility.set_location('calling populate_pa_tab : ', 31);

   populate_pa_tables(l_gms_batch_name,l_call_status);

   hr_utility.set_location('done calling populate_pa_tab : ', 32);
   IF l_call_status THEN
      hr_utility.set_location('for call back : ', 33);
      gms_pqh_tie_back(l_gms_batch_name);
      hr_utility.set_location('done call back : ', 34);
   END IF;
   purge_pa_tables(l_gms_batch_name);
   IF not l_call_status THEN
    hr_utility.set_message(8302,'PQH_TR_GMS_IMP_FAILED');
    populate_globals_error
       (
        p_message_text => FND_MESSAGE.get
       );
      RAISE g_error_exception;
   END IF;
 END IF;

 hr_utility.set_location('Leaving: '||l_proc, 1000);

 EXCEPTION
    WHEN tran_source_exception THEN
         hr_utility.set_message(8302,'PQH_TR_VALUE_NOT_FOUND');
         hr_utility.set_message_token('ROUTINE', l_proc);
         hr_utility.set_message_token('VALUE',l_value);
         hr_utility.set_message_token('TABLE',l_table);
         populate_globals_error
    	      (
    	       p_message_text => FND_MESSAGE.get
              );
        RAISE g_error_exception;

    WHEN tran_setup_exception THEN
     	 hr_utility.set_message(8302,'PQH_TR_VALUE_NOT_FOUND');
    	 hr_utility.set_message_token('ROUTINE', l_proc);
    	 hr_utility.set_message_token('VALUE',l_value);
         hr_utility.set_message_token('TABLE',l_table);
         -- set the context
         set_bpr_log_context
	       (
	        p_budget_period_id        =>l_period_name,
	        p_log_context             => l_log_context
               );
         pqh_process_batch_log.set_context_level
           (
            p_txn_id                => l_period_name,
            p_txn_table_route_id    =>  g_table_route_id_bpr,
            p_level                 =>  1,
            p_log_context           =>  l_log_context
          );

           -- insert error
          pqh_process_batch_log.insert_log
            (
            p_message_type_cd    =>  'ERROR',
            p_message_text       =>  fnd_message.get
            );
         RAISE g_error_exception;
    WHEN g_error_exception THEN
     RAISE ;
    WHEN OTHERS THEN
      hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
      hr_utility.set_message_token('ROUTINE', l_proc);
      hr_utility.set_message_token('REASON', SQLERRM);
      hr_utility.raise_error;
   END populate_gms_tables;

/**************************************************************/

PROCEDURE ins_gl_bc_run_fund_check
( p_packet_id            IN   gl_bc_packets.packet_id%TYPE
 ,p_code_combination_id  IN   pqh_gl_interface.code_combination_id%TYPE
 ,p_period_name          IN   pqh_gl_interface.period_name%TYPE
 ,p_period_year          IN   gl_period_statuses.period_year%TYPE
 ,p_period_num           IN   gl_period_statuses.period_num%TYPE
 ,p_quarter_num          IN   gl_period_statuses.quarter_num%TYPE
 ,p_currency_code        IN   pqh_gl_interface.currency_code%TYPE
 ,p_entered_dr           IN   pqh_gl_interface.amount_dr%TYPE
 ,p_entered_cr           IN   pqh_gl_interface.amount_cr%TYPE
 ,p_accounted_dr         IN   pqh_gl_interface.amount_dr%TYPE
 ,p_accounted_cr         IN   pqh_gl_interface.amount_cr%TYPE
 ,p_cost_allocation_keyflex_id           IN   pqh_gl_interface.cost_allocation_keyflex_id%TYPE
 ,p_fc_mode              IN   varchar2
 ,p_fc_success           OUT NOCOPY boolean
 ,p_fc_return            OUT NOCOPY varchar2
 )
IS
/*
  This procedure Inserts in gl_bc_packets , commits so that the data is available
  for the autonomous funds checker and runs funds checker returns as argument funds
  checker return code and success flag
*/
--
-- local variables
--
 l_proc                       varchar2(72) := g_package||'.ins_gl_bc_run_fund_check';
 l_fc_success                 boolean;
 l_fc_return                  varchar2(100);
 l_session_id		      gl_bc_packets.session_id%TYPE DEFAULT -1;
 l_serial_id                  gl_bc_packets.serial_id%TYPE DEFAULT -1;
 l_application_id             gl_bc_packets.application_id%TYPE ;
 PRAGMA                       AUTONOMOUS_TRANSACTION;

BEGIN
   hr_utility.set_location('Entering: '||l_proc, 5);

   -- get the session details and application_id to insert into gl_bc_packets (Bug Fix 6769905)
   -- session id and serial id is fetched from v$session, same as that in psa_funds_checker_pkg.get_session_details
   select s.audsid,  s.serial#
   into l_session_id, l_serial_id
   from v$session s, v$process p
   where s.paddr = p.addr
   and   s.audsid = USERENV('SESSIONID');

   l_application_id := fnd_global.resp_appl_id;


   INSERT INTO  gl_bc_packets
      (packet_id,
       ledger_id,
       je_source_name,
       je_category_name,
       code_combination_id,
       actual_flag,
       period_name,
       period_year,
       period_num,
       quarter_num,
       currency_code,
       status_code,
       last_update_date,
       last_updated_by,
       budget_version_id,
       entered_dr,
       entered_cr,
       accounted_dr,
       accounted_cr,
       reference1,
       reference2,
       -- Added these three columns for Bug 6769905 fix,  only for R12
       SESSION_ID,
       SERIAL_ID,
       APPLICATION_ID
       )
    VALUES
      (p_packet_id,
       g_set_of_books_id,
       g_user_je_source_name,
       g_user_je_category_name,
       p_code_combination_id,
       'B',
       p_period_name,
       p_period_year,
       p_period_num,
       p_quarter_num,
       p_currency_code,
       'P',
       sysdate,
       8302,
       g_gl_budget_version_id,
       p_entered_dr,
       p_entered_cr,
       p_accounted_dr,
       p_accounted_cr,
       g_budget_version_id,
       p_cost_allocation_keyflex_id,
        -- Added these three columns for Bug 6769905 fix,  only for R12
       l_session_id,
       l_serial_id,
       l_application_id);

       -- Funds Checker is run in autonomous mode.
       -- Commit so that the gl_bc_packets records are visible to fundschecker
       commit;

       hr_utility.set_location('Calling GL fund checker in Mode : '||p_fc_mode,100);

   l_fc_success := PSA_FUNDS_CHECKER_PKG.GLXFCK
       (
        p_ledgerid          => g_set_of_books_id,
        p_packetid          => p_packet_id,
        p_mode              => p_fc_mode,
        p_conc_flag         => 'Y',
        p_return_code       => l_fc_return,
        p_calling_prog_flag => 'H'
        );

       hr_utility.set_location('GL Fund Checker return Code : '||l_fc_return,110);

   p_fc_success := l_fc_success;
   p_fc_return  := l_fc_return;

   -- commit the autonomous transaction
   commit;

  hr_utility.set_location('Leaving:'||l_proc, 1000);

end ins_gl_bc_run_fund_check;


END pqh_gl_posting;

/
