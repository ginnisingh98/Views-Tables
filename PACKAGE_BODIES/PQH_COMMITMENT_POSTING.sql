--------------------------------------------------------
--  DDL for Package Body PQH_COMMITMENT_POSTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_COMMITMENT_POSTING" AS
/* $Header: pqglcmmt.pkb 120.10 2006/12/28 10:37:28 krajarat noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(100) := 'pqh_commitment_posting.';  -- Global package name
--
g_application_id            NUMBER(15)  := 101;
--
g_budget_id                 pqh_budgets.budget_id%TYPE;
g_set_of_books_id           gl_interface.set_of_books_id%TYPE;
g_budgetary_control_flag    gl_sets_of_books.enable_budgetary_control_flag%TYPE;
g_budget_name               pqh_budgets.budget_name%TYPE;
g_budgeted_entity_cd        pqh_budgets.budgeted_entity_cd%TYPE;
g_transfer_to_grants_flag   pqh_budgets.transfer_to_grants_flag%TYPE;
g_bgt_currency_code         pqh_budgets.currency_code%TYPE;
--
g_user_je_source_name       gl_interface.user_je_source_name%TYPE;
g_user_je_category_name     gl_interface.user_je_category_name%TYPE;
--
g_budget_version_id         gl_interface.budget_version_id%TYPE;
g_gl_budget_version_id      gl_interface.budget_version_id%TYPE;
g_version_number            pqh_budget_versions.version_number%TYPE;
g_last_posted_ver           gl_interface.budget_version_id%TYPE;
--
g_chart_of_accounts_id      gl_interface.chart_of_accounts_id%TYPE;
g_default_currency_code     gl_interface.currency_code%TYPE;
g_currency_code1            gl_interface.currency_code%TYPE;
g_currency_code2            gl_interface.currency_code%TYPE;
g_currency_code3            gl_interface.currency_code%TYPE;
g_budget_uom1               pqh_budgets.budget_unit1_id%TYPE;
g_budget_uom2               pqh_budgets.budget_unit2_id%TYPE;
g_budget_uom3               pqh_budgets.budget_unit3_id%TYPE;
--
g_table_route_id_bvr        number;
g_table_route_id_bdt        number;
g_table_route_id_bpr        number;
g_table_route_id_bfs        number;
g_table_route_id_glf        number;
--
g_detail_error              VARCHAR2(10);
g_error_exception           exception;
g_status                    varchar2(10);
g_validate                  boolean;
--
g_distribution_table         t_distribution_table;
g_period_amt_tab             t_period_amt_tab;
g_old_bdgt_dtls_tab          pqh_gl_posting.t_old_bdgt_dtls_tab;
g_gms_import_tab             pqh_gl_posting.t_gms_import_tab;
--
---------------------------------------------------------------------------------------
--                    Private Procedures added for Transfer to Grants
---------------------------------------------------------------------------------------
PROCEDURE populate_pqh_gms_interface
(
 p_budget_version_id    IN pqh_budget_versions.budget_version_id%TYPE,
 p_budget_detail_id     IN pqh_budget_details.budget_detail_id%TYPE,
 p_posting_type_cd      IN pqh_gl_interface.posting_type_cd%TYPE
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
 p_amount            IN pqh_gl_interface.amount_dr%TYPE,
 p_posting_type_cd   IN pqh_gl_interface.posting_type_cd%TYPE
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
 p_amount            IN pqh_gl_interface.amount_dr%TYPE,
 p_posting_type_cd   IN pqh_gl_interface.posting_type_cd%TYPE
) ;

-- Procedure added to run funds checker in autonomous transaction
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

PROCEDURE populate_gms_tables;

---------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- Private procedure added for Consolidating the commitments -- Bug :5645538 --krajarat
------------------------------------------------------------------------------------------
Procedure consolidate_commitment
IS
BEGIN
  --loop thro the g_period_amt_tab and consolidate all teh commitments into a one record.

  For cnt in g_period_amt_tab.FIRST .. g_period_amt_tab.LAST loop
       --
      IF cnt > g_period_amt_tab.FIRST THEN --Skip the first time and process next time onwards
             g_period_amt_tab(1).commitment1 := g_period_amt_tab(1).commitment1 + g_period_amt_tab(cnt).commitment1 ;
             g_period_amt_tab(1).commitment2 := g_period_amt_tab(1).commitment2 + g_period_amt_tab(cnt).commitment2 ;
             g_period_amt_tab(1).commitment3 := g_period_amt_tab(1).commitment3 + g_period_amt_tab(cnt).commitment3 ;
             g_period_amt_tab.delete(cnt);
      END IF;

  END LOOP; --end of for loop.
  hr_utility.set_location('Consolidation-> The size is :'||g_period_amt_tab.LAST , 5);
       --
         --
END;

Procedure get_period_dates
                   (p_budget_period_id  IN  pqh_budget_periods.budget_period_id%TYPE,
                    p_period_start_date OUT NOCOPY date,
                    p_period_end_date   OUT NOCOPY date) IS
--
 Cursor csr_period is
  Select start_time_period_id,end_time_period_id
    From pqh_budget_periods
   Where budget_period_id = p_budget_period_id;
--
 Cursor csr_period_date(p_time_period_id  in  number) is
   Select start_date,end_date
     From per_time_periods
    Where time_period_id = p_time_period_id;
--
l_start_time_period_id    pqh_budget_periods.start_time_period_id%TYPE;
l_end_time_period_id    pqh_budget_periods.end_time_period_id%TYPE;
--
l_start_date       date;
l_end_date       date;
--
l_proc                    varchar2(72) := g_package||'get_period_dates';
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Open csr_period;
  Fetch csr_period into l_start_time_period_id,l_end_time_period_id;
  Close csr_period;
  --
  Open csr_period_date(l_start_time_period_id);
  Fetch csr_period_date into l_start_date,l_end_date;
  Close csr_period_date;
  --
  p_period_start_date := l_start_date;
  --
  Open csr_period_date(l_end_time_period_id);
  Fetch csr_period_date into l_start_date,l_end_date;
  Close csr_period_date;
  --
  p_period_end_date := l_end_date;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
exception when others then
p_period_start_date := null;
p_period_end_date := null;
raise;
End;
--
----------------------------------------------------------------------------------------
--
--  This procedure will check if the business_group has a default currency,if yes it will
--  override the gl_sets_of_book currency code.
--  If there is a currency associated with the budget,it will override all other currencies
--
--
PROCEDURE get_default_currency
  (p_budget_version_id      IN pqh_budget_versions.budget_version_id%TYPE,
   p_default_currency_code OUT NOCOPY gl_interface.currency_code%TYPE) IS
--
-- local variables
--
l_bg_curr_code            varchar2(150) := '';
l_budget_curr             varchar2(150) := '';
--
CURSOR csr_curr_code IS
SELECT bg.currency_code
FROM  per_business_groups bg,
      pqh_budgets bgt,
      pqh_budget_versions bvr
WHERE bgt.budget_id = bvr.budget_id
  AND bvr.budget_version_id = p_budget_version_id
  AND bgt.business_group_id = bg.business_group_id ;
--
CURSOR csr_bgt_curr IS
SELECT bgt.currency_code
FROM  pqh_budgets  bgt,
      pqh_budget_versions bvr
WHERE bgt.budget_id = bvr.budget_id
  AND bvr.budget_version_id = g_budget_version_id;
--
l_proc                    varchar2(72) := g_package||'get_default_currency';
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  OPEN csr_bgt_curr;
  FETCH csr_bgt_curr INTO l_budget_curr;
  CLOSE csr_bgt_curr;
  --
  hr_utility.set_location('Budget Currency Code : '||l_budget_curr,7);
  --
  IF l_budget_curr IS NOT NULL THEN
     --
     -- assign this to g_currency_code
     --
     p_default_currency_code := l_budget_curr;
     --
  else
     OPEN csr_curr_code;
     FETCH csr_curr_code INTO l_bg_curr_code;
     CLOSE csr_curr_code;
     --
     hr_utility.set_location('Business Group Curr Code : '||l_bg_curr_code,6);
     --
     IF l_bg_curr_code IS NOT NULL THEN
        --
        -- assign this to g_currency_code
        --
        p_default_currency_code := l_bg_curr_code;
        --
     END IF;
  END IF;
  --
  hr_utility.set_location('Leaving:'||l_proc, 1000);
  --
EXCEPTION
      WHEN OTHERS THEN
      p_default_currency_code := null;
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END get_default_currency;
--
------------------------------------------------------------------------------------
--
--  If there are errors in fetch globals procedure we will call this procedure which will
--  end the process log as the  batch itself has error
--
PROCEDURE populate_globals_error
(
 p_message_text     IN    pqh_process_log.message_text%TYPE
) IS
--
-- local variables
--
l_proc                    varchar2(72) := g_package||'populate_globals_error';
PRAGMA                    AUTONOMOUS_TRANSACTION;
--
BEGIN
  --
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
  UPDATE pqh_process_log
     SET message_type_cd =  'ERROR',
         message_text   = p_message_text,
         txn_table_route_id    =  g_table_route_id_bvr
   WHERE process_log_id = pqh_process_batch_log.g_master_process_log_id;
   --
   -- commit the autonomous transaction
   --
   commit;
   --
   hr_utility.set_location('Leaving:'||l_proc, 1000);
   --
EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END populate_globals_error;

----------------------------------------------------------------------------------------------------
--
PROCEDURE fetch_global_values
          (p_budget_version_id  IN pqh_budget_versions.budget_version_id%TYPE) IS
--
 l_proc                         varchar2(72) := g_package||'fetch_global_values';
--
 l_budgets_rec                  pqh_budgets%ROWTYPE;
 l_budget_versions_rec          pqh_budget_versions%ROWTYPE;
--
 l_gl_sets_of_books_rec         gl_sets_of_books%ROWTYPE;
 l_shared_types_rec             per_shared_types%ROWTYPE;
 l_gl_budget_versions_rec       gl_budget_versions%ROWTYPE;
 l_gl_je_sources_rec            gl_je_sources%ROWTYPE;
 l_gl_je_categories_rec         gl_je_categories%ROWTYPE;
--
--
 l_version_gl_status            pqh_budget_versions.gl_status%TYPE;
--
 l_gl_encumbrance_type_id       gl_encumbrance_types.encumbrance_type_id%TYPE;
--
 l_transfer_to_gl_flag          pqh_budgets.transfer_to_gl_flag%TYPE;
 l_psb_budget_flag              pqh_budgets.psb_budget_flag%TYPE;
 l_default_currency_code        gl_interface.currency_code%TYPE;
--
 l_message_text                 pqh_process_log.message_text%TYPE;
 l_message_text_out             fnd_new_messages.message_text%TYPE;
 l_error_flag                   varchar2(10) := 'N';
 l_level                        number;
 l_batch_id                     number;
 l_batch_context                varchar2(2000);
 l_count                        number;
 l_map_count_null               number;
 l_gl_budget_name               pqh_budgets.gl_budget_name%TYPE;
--
--
 CURSOR csr_budget_versions_rec IS
 SELECT *
 FROM pqh_budget_versions
 WHERE budget_version_id = p_budget_version_id;

 CURSOR csr_budgets_rec IS
 SELECT *
 FROM pqh_budgets
 WHERE budget_id = ( SELECT budget_id
                     FROM pqh_budget_versions
                     WHERE budget_version_id = p_budget_version_id ) ;
--
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
 WHERE budget_name =p_gl_budget_name  AND
       status in ('O','C');

 CURSOR  csr_gl_je_sources IS
 SELECT *
 FROM gl_je_sources
 WHERE je_source_name = 'Public Sector Budget';

 CURSOR csr_gl_je_categories IS
 SELECT *
 FROM gl_je_categories
 WHERE je_category_name = 'Public Sector Budget';

 CURSOR csr_table_route (p_table_alias  IN varchar2 )IS
 SELECT table_route_id
 FROM pqh_table_route
 WHERE table_alias =  p_table_alias;

 CURSOR csr_flex_maps_counts (p_budget_id IN number)IS
 SELECT COUNT(*)
 FROM pqh_budget_gl_flex_maps
 WHERE budget_id = p_budget_id;

 CURSOR csr_cost_map_null (p_budget_id  IN number) IS
 SELECT COUNT(*)
 FROM pqh_budget_gl_flex_maps
 WHERE budget_id = p_budget_id
   AND payroll_cost_segment IS NULL;

 cursor csr_gl_encumbrance_types is
 select encumbrance_type_id
 from gl_encumbrance_types
 where encumbrance_type_id = 1000;
--
BEGIN
  --
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
  -- check if the input budget version Id is valid
  --
  OPEN csr_budget_versions_rec;
  FETCH csr_budget_versions_rec INTO l_budget_versions_rec;
  CLOSE csr_budget_versions_rec;
  --
   g_version_number       := l_budget_versions_rec.version_number;
  --
  OPEN csr_budgets_rec;
  FETCH csr_budgets_rec INTO l_budgets_rec;
  CLOSE csr_budgets_rec;
  --
   g_budget_id               := l_budgets_rec.budget_id;
   g_budget_name             := l_budgets_rec.budget_name;
   g_budgeted_entity_cd      := l_budgets_rec.budgeted_entity_cd;
   g_set_of_books_id         := l_budgets_rec.gl_set_of_books_id;
   l_transfer_to_gl_flag     := l_budgets_rec.transfer_to_gl_flag;
   g_transfer_to_grants_flag := l_budgets_rec.transfer_to_grants_flag;
   l_psb_budget_flag         := l_budgets_rec.psb_budget_flag;
   g_budget_uom1             := l_budgets_rec.budget_unit1_id;
   g_budget_uom2             := l_budgets_rec.budget_unit2_id;
   g_budget_uom3             := l_budgets_rec.budget_unit3_id;
   l_gl_budget_name          := l_budgets_rec.gl_budget_name;
   get_default_currency(p_budget_version_id     => p_budget_version_id,
                       p_default_currency_code => g_bgt_currency_code);
   g_default_currency_code := g_bgt_currency_code;
  --
  l_batch_id := g_budget_version_id;
  l_batch_context := g_budget_name||' - '||g_version_number;
  --
  hr_utility.set_location('Batch Context  : '||l_batch_context,7);
  --
  -- Start the Log Process
  --
  pqh_process_batch_log.start_log
     (
      p_batch_id       => l_batch_id,
      p_module_cd      => 'COMMITMENT_GL_POSTING',
      p_log_context    => l_batch_context
     );
  --
  --
  --
  l_version_gl_status := l_budget_versions_rec.gl_status;
  IF l_budget_versions_rec.budget_version_id IS NULL THEN
     --
     -- invalid budget_version id
     --
     FND_MESSAGE.SET_NAME('PQH','PQH_INV_BDG_VERSION_ID');
     -- APP_EXCEPTION.RAISE_EXCEPTION; /* Fix for bug 2714555 */
     l_message_text_out := FND_MESSAGE.GET;
     --
     IF l_error_flag = 'Y' THEN
        --
        -- there is already an error so append the message
        --
        l_message_text := l_message_text||' **** '||l_message_text_out;

        --
     ELSE
        --
        -- new message
        --
        l_error_flag := 'Y';
        l_message_text := l_message_text_out;
        --
     END IF;
      --
 END IF;
   --
   -- Raise error if budget version is not posted
   -- Note : If the budget version was posted , then it means that
   -- flexfield has been mapped for the budget version . So we
   -- dont have to validate for that .
   --
   /**
   IF NVL(l_budget_versions_rec.gl_status,'X') <>'POST' THEN
      --
      FND_MESSAGE.SET_NAME('PQH','PQH_BUDGET_VERSION_NOT_POSTED');
      APP_EXCEPTION.RAISE_EXCEPTION;
      --
   END IF;
   **/
   --
   -- Raise error if the commitment for this budget version is already
   -- posted.
   --
   IF NVL(l_budget_versions_rec.commitment_gl_status,'X') = 'POST' THEN
      --
      FND_MESSAGE.SET_NAME('PQH','PQH_BUDGET_VER_CMMTMNT_POSTED');
      -- APP_EXCEPTION.RAISE_EXCEPTION;  /* Fix for bug 2714555 */
      l_message_text_out := FND_MESSAGE.GET;
      --
      IF l_error_flag = 'Y' THEN
        --
        -- there is already an error so append the message
        --
        l_message_text := l_message_text||' **** '||l_message_text_out;

        --
      ELSE
        --
        -- new message
        --
        l_error_flag := 'Y';
        l_message_text := l_message_text_out;
        --
      END IF;
      --
   ELSIF NVL(l_budget_versions_rec.commitment_gl_status,'X') = 'CALCULATION_ERROR' THEN
      --
      -- Raise error if the commitment for this budget version is already
      -- posted.
      --
      FND_MESSAGE.SET_NAME('PQH','PQH_BDGT_VER_CMMTMNT_CALC_ERR');
      -- APP_EXCEPTION.RAISE_EXCEPTION; /* Fix for bug 2714555 */
      l_message_text_out := FND_MESSAGE.GET;
      --
      IF l_error_flag = 'Y' THEN
        --
        -- there is already an error so append the message
        --
        l_message_text := l_message_text||' **** '||l_message_text_out;

        --
      ELSE
        --
        -- new message
        --
        l_error_flag := 'Y';
        l_message_text := l_message_text_out;
        --
      END IF;
      --
--   ELSIF l_budget_versions_rec.commitment_gl_status IS NULL THEN
      --
      --
      --
   END IF;
   --
 /*  g_version_number       := l_budget_versions_rec.version_number;
   --
   OPEN csr_budgets_rec;
   FETCH csr_budgets_rec INTO l_budgets_rec;
   CLOSE csr_budgets_rec;
   --
   g_budget_id               := l_budgets_rec.budget_id;
   g_budget_name             := l_budgets_rec.budget_name;
   g_budgeted_entity_cd      := l_budgets_rec.budgeted_entity_cd;
   g_set_of_books_id         := l_budgets_rec.gl_set_of_books_id;
   l_transfer_to_gl_flag     := l_budgets_rec.transfer_to_gl_flag;
   g_transfer_to_grants_flag := l_budgets_rec.transfer_to_grants_flag;
   l_psb_budget_flag         := l_budgets_rec.psb_budget_flag;
   g_budget_uom1             := l_budgets_rec.budget_unit1_id;
   g_budget_uom2             := l_budgets_rec.budget_unit2_id;
   g_budget_uom3             := l_budgets_rec.budget_unit3_id;
   l_gl_budget_name          := l_budgets_rec.gl_budget_name;
   get_default_currency(p_budget_version_id     => p_budget_version_id,
                       p_default_currency_code => g_bgt_currency_code);
  g_default_currency_code := g_bgt_currency_code;
  --
  l_batch_id := g_budget_version_id;
  l_batch_context := g_budget_name||' - '||g_version_number;
  --
  hr_utility.set_location('Batch Context  : '||l_batch_context,7);
  --
  -- Start the Log Process
  --
  pqh_process_batch_log.start_log
     (
      p_batch_id       => l_batch_id,
      p_module_cd      => 'COMMITMENT_GL_POSTING',
      p_log_context    => l_batch_context
     ); */
  --
  -- Raise error if set_of_books_id IS NULL
  --
  IF g_set_of_books_id IS NULL THEN
     --
     FND_MESSAGE.SET_NAME('PQH','PQH_INVALID_GL_SET_BOOKS');
     l_message_text_out := FND_MESSAGE.GET;
     --
     IF l_error_flag = 'Y' THEN
        --
        -- there is already an error so append the message
        --
        l_message_text := l_message_text||' **** '||l_message_text_out;
        --
     ELSE
        --
        -- new message
        --
        l_error_flag := 'Y';
        l_message_text := l_message_text_out;
        --
     END IF;
     --
  END IF; -- set_of_books_id IS NOT NULL

  -- CHECK : if g_bgt_currency_code  IS NOT NULL
   IF g_bgt_currency_code IS NULL THEN
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

     END IF; -- g_bgt_currency_code IS NOT NULL
  --
  --
  --
  --If Budget is Transfered to Grants then Budget should be posted prior to Commitment Xfer
  --
  IF NVL(g_transfer_to_grants_flag,'N') = 'Y' AND
     NVL(l_version_gl_status,'X') <> 'POST' THEN
        hr_utility.set_message(8302, 'PQH_BUDGET_VERSION_NOT_POSTED');
        hr_utility.raise_error;
  END IF;


  --
  -- Raise error if transfer_to_gl_flag <> Y and transfer_to_grants_flag <> Y
  --
  IF NVL(l_transfer_to_gl_flag,'N') <> 'Y'  THEN
     --
     IF NVL(g_transfer_to_grants_flag,'N') <> 'Y' THEN
      --
      FND_MESSAGE.SET_NAME('PQH','PQH_BUDGET_TRANSFER_FLAG');
      l_message_text_out := FND_MESSAGE.GET;
      --
      IF l_error_flag = 'Y' THEN
        --
        -- there is already an error so append the message
        --
        l_message_text := l_message_text||' **** '||l_message_text_out;
        --
      ELSE
        --
        -- new message
        --
        l_error_flag := 'Y';
        l_message_text := l_message_text_out;
        --
      END IF;

     END IF;
  Else
     -- check if rows in pqh_budget_gl_flex_maps with NULL cost segments
     OPEN csr_cost_map_null(p_budget_id => g_budget_id);
     FETCH csr_cost_map_null INTO l_map_count_null;
     CLOSE csr_cost_map_null;

     IF NVL(l_map_count_null,0) <> 0 THEN

         -- get message text for PQH_BUDGET_GL_MAP
         -- message: Some of the GL segments  are not mapped with cost segments.
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
  --
  -- CHECK if the budget is mapped
  --
  OPEN csr_flex_maps_counts(p_budget_id => g_budget_id);
  FETCH csr_flex_maps_counts INTO l_count;
  CLOSE csr_flex_maps_counts;
  --
  -- CHECK : count <> 0 i.e mapping is defined
  --
  IF NVL(l_count,0) = 0 THEN
     -- get message text for PQH_BUDGET_GL_MAP
     -- message : Mapping with GL segments not defined for the budget
     --
     FND_MESSAGE.SET_NAME('PQH','PQH_BUDGET_GL_MAP');
     l_message_text_out := FND_MESSAGE.GET;

     IF l_error_flag = 'Y' THEN
         --
        -- there is already an error so append the message
         --

        l_message_text := l_message_text||' **** '||l_message_text_out;
         --
      ELSE
         --
         -- new message
         --
         l_message_text := l_message_text_out;
         --
      END IF;
      --
      -- set l_error_flag to Y
      --
      l_error_flag := 'Y';
      --
  END IF; -- count <> 0 i.e mapping is defined
  --
  -- get gl_budget_version_id
  --
  OPEN csr_gl_budget_version(p_gl_budget_name => l_gl_budget_name);
  FETCH csr_gl_budget_version INTO l_gl_budget_versions_rec;
  CLOSE csr_gl_budget_version;
  --
  g_gl_budget_version_id := l_gl_budget_versions_rec.budget_version_id;
  --
  -- CHECK : if gl_budget_version_id exists else error
  --
  IF g_gl_budget_version_id IS NULL THEN
     --
     FND_MESSAGE.SET_NAME('PQH','PQH_GL_BUDGET_INVALID');
     l_message_text_out := FND_MESSAGE.GET;
     --
     IF l_error_flag = 'Y' THEN
        --
        -- there is already an error so append the message
        --
        l_message_text := l_message_text||' **** '||l_message_text_out;
        --
     ELSE
        --
        -- new message
        --
        l_error_flag := 'Y';
        l_message_text := l_message_text_out;
        --
     END IF;
     --
  END IF; -- gl_budget_version_id  is null
  --
  -- get encumbrance_type_id
  --
  open csr_gl_encumbrance_types;
  fetch csr_gl_encumbrance_types into l_gl_encumbrance_type_id;
  close csr_gl_encumbrance_types;
  if l_gl_encumbrance_type_id is null then
     --
     FND_MESSAGE.SET_NAME('PQH','PQH_GL_ENC_TYP_INVALID');
     l_message_text_out := FND_MESSAGE.GET;
     --
     IF l_error_flag = 'Y' THEN
        --
        -- there is already an error so append the message
        --
        l_message_text := l_message_text||' **** '||l_message_text_out;
        --
     ELSE
        --
        -- new message
        --
        l_error_flag := 'Y';
        l_message_text := l_message_text_out;
        --
     END IF;
     --
  END IF;
  --
  -- get the set of books , budgetary control flag and currency for money
  --
  OPEN csr_chart_of_acc_id(p_set_of_books_id  => l_budgets_rec.gl_set_of_books_id );
  FETCH csr_chart_of_acc_id INTO l_gl_sets_of_books_rec;
  CLOSE csr_chart_of_acc_id;
  --
  g_chart_of_accounts_id     := l_gl_sets_of_books_rec.chart_of_accounts_id;
  g_budgetary_control_flag   := l_gl_sets_of_books_rec.enable_budgetary_control_flag;
  --
  if g_default_currency_code <> l_gl_sets_of_books_rec.currency_code then
  --
  -- currency used in Budget or Business group is different that in Set of books.
  -- it is an error condition.
  null;
  --
  End if;
  --
  --
  -- get the je_source
  --
  OPEN csr_gl_je_sources;
  FETCH csr_gl_je_sources INTO l_gl_je_sources_rec;
  CLOSE csr_gl_je_sources;
  --
  g_user_je_source_name := l_gl_je_sources_rec.user_je_source_name;
  --
  -- CHECK : if g_user_je_source_name IS NOT NULL
  --
  IF g_user_je_source_name IS NULL THEN
     --
     FND_MESSAGE.SET_NAME('PQH','PQH_INVALID_JE_SOURCE_NAME');
     l_message_text_out := FND_MESSAGE.GET;
     --
     IF l_error_flag = 'Y' THEN
        --
        -- there is already an error so append the message
        --
        l_message_text := l_message_text||' **** '||l_message_text_out;
        --
     ELSE
        --
        -- new message
        --
        l_error_flag := 'Y';
        l_message_text := l_message_text_out;
        --
     END IF;
     --
  END IF; -- gl_user_je_source_name IS NOT NULL
  --
  -- get the je category
  --
  OPEN csr_gl_je_categories;
  FETCH csr_gl_je_categories INTO l_gl_je_categories_rec;
  CLOSE csr_gl_je_categories;

  g_user_je_category_name := l_gl_je_categories_rec.user_je_category_name;
  --
  -- CHECK : if g_user_je_category_name IS NOT NULL
  --
  IF g_user_je_category_name IS NULL THEN
     --
     FND_MESSAGE.SET_NAME('PQH','PQH_INVALID_JE_CATEGORY_NAME');
     l_message_text_out := FND_MESSAGE.GET;
     --
     IF l_error_flag = 'Y' THEN
        --
        -- there is already an error so append the message
        --
        l_message_text := l_message_text||' **** '||l_message_text_out;
        --
     ELSE
        --
        -- new message
        --
        l_error_flag := 'Y';
        l_message_text := l_message_text_out;
        --
     END IF;
     --
   END IF; -- gl_user_je_category_name IS NOT NULL
   --
   -- populate the currency codes
   --
   OPEN csr_shared_types(p_shared_type_id => g_budget_uom1 );
   FETCH csr_shared_types  INTO l_shared_types_rec;
   CLOSE csr_shared_types;

   IF l_shared_types_rec.system_type_cd = 'MONEY' THEN
       g_currency_code1 := g_default_currency_code;
   ELSE
       g_currency_code1 := 'STAT';
   END IF;

   IF g_budget_uom2  IS NOT NULL THEN

      OPEN csr_shared_types(p_shared_type_id => g_budget_uom2 );
      FETCH csr_shared_types  INTO l_shared_types_rec;
      CLOSE csr_shared_types;

      IF l_shared_types_rec.system_type_cd = 'MONEY' THEN
          g_currency_code2 := g_default_currency_code;
      ELSE
          g_currency_code2 := 'STAT';
      END IF;

   END IF;  -- budget_unit2_id  IS NOT NULL

   IF g_budget_uom3  IS NOT NULL THEN

      OPEN csr_shared_types(p_shared_type_id => g_budget_uom3 );
      FETCH csr_shared_types  INTO l_shared_types_rec;
      CLOSE csr_shared_types;

      IF l_shared_types_rec.system_type_cd = 'MONEY' THEN
         g_currency_code3 := g_default_currency_code;
      ELSE
         g_currency_code3 := 'STAT';
      END IF;

   END IF;   --   budget_unit3_id  IS NOT NULL
   --
   -- get the table route id for pqh_budget versions
   --
   OPEN csr_table_route(p_table_alias => 'BVR');
   FETCH csr_table_route INTO g_table_route_id_bvr;
   CLOSE csr_table_route;

   --
   -- get the table route id for pqh_budget details
   --
   OPEN csr_table_route(p_table_alias => 'BDT');
   FETCH csr_table_route INTO g_table_route_id_bdt;
   CLOSE csr_table_route;

   --
   -- get the table route id for pqh_budget details
   --
   OPEN csr_table_route(p_table_alias => 'BPR');
   FETCH csr_table_route INTO g_table_route_id_bpr;
   CLOSE csr_table_route;

   --
   -- get the table route id for pqh_budget fund srcs
   --
   OPEN csr_table_route(p_table_alias => 'BFS');
   FETCH csr_table_route INTO g_table_route_id_bfs;
   CLOSE csr_table_route;

   --
   -- get the table route id for gl_bc_packets
   --
   OPEN csr_table_route(p_table_alias => 'GLF');
   FETCH csr_table_route INTO g_table_route_id_glf;
   CLOSE csr_table_route;

   hr_utility.set_location('Budget Name : '||g_budget_name,100);
   hr_utility.set_location('Set Of Books Id : '||g_set_of_books_id,110);
   hr_utility.set_location('g_gl_budget_version_id : '||g_gl_budget_version_id,111);
   hr_utility.set_location('g_budget_version_id : '||g_budget_version_id,112);
   hr_utility.set_location('g_budgetary_control_flag : '||g_budgetary_control_flag,120);
   hr_utility.set_location('g_budget_uom1 : '||to_char(g_budget_uom1),150);
   hr_utility.set_location('g_budget_uom2 : '||to_char(g_budget_uom2),160);
   hr_utility.set_location('g_budget_uom3 : '||to_char(g_budget_uom3),170);
   hr_utility.set_location('g_currency_code1 : '||g_currency_code1,150);
   hr_utility.set_location('g_currency_code2 : '||g_currency_code2,160);
   hr_utility.set_location('g_currency_code3 : '||g_currency_code3,170);
   hr_utility.set_location('g_user_je_source_name : '||g_user_je_source_name,180);
   hr_utility.set_location('g_user_je_category_name : '||g_user_je_category_name,190);
   --
   -- if any errors the end the process log and abort the program
   --
   IF l_error_flag = 'Y' THEN
      --
      -- end the process log as the batch itself has error
      --
      populate_globals_error
      (
           p_message_text  =>  l_message_text
      );
      --
      -- abort the program
      --
      RAISE g_error_exception;
      --
      --
  END IF; -- insert error message if l_error_flag is Y
  --
  hr_utility.set_location('Leaving:'||l_proc, 1000);
  --
EXCEPTION
      WHEN g_error_exception THEN
        RAISE;
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END fetch_global_values;
--
---------------------------------------------------------------------------------------------------
--
Procedure build_budget_set_ratio_table(
          p_budget_period_id     IN     pqh_budget_periods.budget_period_id%TYPE,
          p_element_type_id      IN     pqh_budget_elements.element_type_id%TYPE,
          p_budget_unit_seq      IN     number,
          p_budget_ratio_table   IN OUT NOCOPY t_ratio_table) IS
--
--
l_budget_ratio_table t_ratio_table := p_budget_ratio_table;
 Cursor csr_budget_sets is
  Select bst.budget_set_id,decode(p_budget_unit_seq,1,bst.budget_unit1_value,
                                                    2,bst.budget_unit2_value,
                                                      bst.budget_unit3_value)
    From pqh_budget_sets bst
   Where bst.budget_period_id = p_budget_period_id;
--
 Cursor csr_dist_money is
  Select distinct bst.budget_set_id,
                       decode(p_budget_unit_seq,1,bst.budget_unit1_value,
                                                2,bst.budget_unit2_value,
                                                  bst.budget_unit3_value)
    from pqh_budget_sets bst,pqh_budget_elements bel
   Where bst.budget_period_id  = p_budget_period_id
     and bst.budget_set_id   = bel.budget_set_id
     and bel.element_type_id = p_element_type_id ;
--
l_budget_set_id    pqh_budget_sets.budget_set_id%type;
l_budgeted_amt     pqh_budget_sets.budget_unit1_value%type;
l_total_budgeted_amt     pqh_budget_sets.budget_unit1_value%type;
cnt                number(10) := 0;
--
--
 l_proc            varchar2(72) := g_package||'build_budget_set_ratio_table';
--
Begin
--
hr_utility.set_location('Entering: '||l_proc, 5);
--
l_total_budgeted_amt := 0;
--
If p_element_type_id IS NULL then
   --
   Open csr_budget_sets;
   --
   loop
      --
      Fetch csr_budget_sets into l_budget_set_id,
                                 l_budgeted_amt;
      --
      exit when csr_budget_sets%notfound;
      --
      cnt := cnt + 1;
      --
      p_budget_ratio_table(cnt).budget_set_id := l_budget_set_id;
      p_budget_ratio_table(cnt).budgeted_amt  := l_budgeted_amt;
      --
      l_total_budgeted_amt := l_total_budgeted_amt + l_budgeted_amt;
      --
    End loop;
    --
    Close csr_budget_sets;
    --
Else
    --
    Open csr_dist_money;
    --
    loop
       --
       Fetch csr_dist_money into l_budget_set_id,
                                  l_budgeted_amt;
       --
       exit when csr_dist_money%notfound;
       --
       cnt := cnt + 1;
       --
       p_budget_ratio_table(cnt).budget_set_id := l_budget_set_id;
       p_budget_ratio_table(cnt).budgeted_amt  := l_budgeted_amt;
       --
       l_total_budgeted_amt := l_total_budgeted_amt + l_budgeted_amt;
       --
     End loop;
     --
     Close csr_dist_money;
     --
End if;
--
--
If p_budget_ratio_table.COUNT > 0 then
     --
     hr_utility.set_location('-----No of budget Sets for Element '||to_char(p_element_type_id)||' = '||to_char(p_budget_ratio_table.COUNT),101);
     --
     --
     For cnt in 1..p_budget_ratio_table.COUNT loop
         --
         p_budget_ratio_table(cnt).budget_set_percent
                 := p_budget_ratio_table(cnt).budgeted_amt / l_total_budgeted_amt;
         --
         -- Print Computed Values
         --
         hr_utility.set_location('-----TOTAL BUDGET :'||to_char(l_total_budgeted_amt),100);
         hr_utility.set_location('-----B SET BUDGET :'||to_char(p_budget_ratio_table(cnt).budgeted_amt),100);
         hr_utility.set_location('-----B SET PERCENT :'||to_char(p_budget_ratio_table(cnt).budget_set_percent),100);
         --
     End loop;
     --
End if;
--
hr_utility.set_location('Leaving: '||l_proc, 10);
--
EXCEPTION
      WHEN OTHERS THEN
      p_budget_ratio_table := l_budget_ratio_table;
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
End;
--
----------------------------------------------------------------------------------------------------
--
Procedure update_money_dist_table(p_budget_ratio_table  IN  t_ratio_table,
                                  p_element_type_id     IN  number,
                                  p_commitment          IN  NUMBER,
                                  p_distribution_table IN OUT NOCOPY  t_distribution_table) IS
--
cnt                  number(10);
rec_no               number(10);
--
l_distribution_table   t_distribution_table := p_distribution_table;

--
--
l_proc            varchar2(72) := g_package||'update_money_dist_table';
--
Begin
   --
   hr_utility.set_location('Entering: '||l_proc, 5);
   --
   -- Copy the appropriate budget set ratios.
   --
   If p_budget_ratio_table.COUNT > 0  AND p_distribution_table.COUNT > 0 then
      --
      For cnt in p_budget_ratio_table.FIRST .. p_budget_ratio_table.LAST loop
      --
          For rec_no in p_distribution_table.FIRST .. p_distribution_table.LAST loop
          --
              If p_distribution_table(rec_no).element_type_id = p_element_type_id
             AND p_budget_ratio_table(cnt).budget_set_id = p_distribution_table(rec_no).budget_set_id then
                 --
                 p_distribution_table(rec_no).budget_set_dist_percent :=
                                              p_budget_ratio_table(cnt).budget_set_percent;
                 --
              End if;
           --
           End loop;
       --
       End loop;
   --
   End if;
   --
   -- Distribute the budget set among its elements and funding sources
   -- using their distribution percentages.
   --
   hr_utility.set_location('-------Recs in Dist table when breaking commitment :'||to_char(p_distribution_table.COUNT),100);
   --
   If p_distribution_table.COUNT > 0 then
   --
      For rec_no in p_distribution_table.FIRST .. p_distribution_table.LAST loop
          --
          -- Process only those budget sets that contain the current element type
          --
          If p_distribution_table(rec_no).element_type_id = p_element_type_id then
             --
             p_distribution_table(rec_no).budget_set_commitment := nvl(p_distribution_table(rec_no).budget_set_dist_percent,0) * p_commitment;
             --
             p_distribution_table(rec_no).element_commitment := nvl(p_distribution_table(rec_no).budget_set_commitment,0) ;
             --
             p_distribution_table(rec_no).fs_commitment := nvl(p_distribution_table(rec_no).element_commitment,0) * p_distribution_table(rec_no).fs_distribution_percentage * .01;
             --
             -- Print computed Values
             --
             hr_utility.set_location('-------B SETID : '||to_char(p_distribution_table(rec_no).budget_set_id),6);
             hr_utility.set_location('-------B SET COMMITMENT : '||to_char(p_distribution_table(rec_no).budget_set_commitment),6);
             hr_utility.set_location('-------ELMNT COMMITMENT : '||to_char(p_distribution_table(rec_no).element_commitment),7);
             hr_utility.set_location('-------FS PERCENT:'||to_char(p_distribution_table(rec_no).fs_distribution_percentage),8);
             hr_utility.set_location('-------FS COMMITMENT:'||to_char(p_distribution_table(rec_no).fs_commitment),9);
             --
           End if;
           --
       End loop;
       --
   End if;
   --
   hr_utility.set_location('Leaving: '||l_proc, 10);
   --
EXCEPTION
      WHEN OTHERS THEN
      p_distribution_table   := l_distribution_table;
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
End update_money_dist_table;
--
-------------------------------------------------------------------------------------------------------
--
Procedure update_distribution_table(p_budget_ratio_table  IN  t_ratio_table,
                                    p_commitment          IN  NUMBER,
                                    p_distribution_table IN OUT NOCOPY  t_distribution_table) IS
--
cnt                  number(10);
rec_no               number(10);
l_distribution_table   t_distribution_table := p_distribution_table;
--
--
l_proc            varchar2(72) := g_package||'update_distribution_table';
--
Begin
   --
   hr_utility.set_location('Entering: '||l_proc, 5);
   --
   -- Copy the appropriate budget set ratios.
   --
   hr_utility.set_location('DISTRIBUTING NON MONEY COMMITMENTS !', 6);
   --
   If p_budget_ratio_table.COUNT > 0 then
      --
      For cnt in p_budget_ratio_table.FIRST .. p_budget_ratio_table.LAST loop
       --
         If p_distribution_table.COUNT > 0 then
            --
            For rec_no in p_distribution_table.FIRST .. p_distribution_table.LAST loop
            --
               If p_budget_ratio_table(cnt).budget_set_id = p_distribution_table(rec_no).budget_set_id then
               --
                  --
                  p_distribution_table(rec_no).budget_set_dist_percent := nvl(p_budget_ratio_table(cnt).budget_set_percent,0);
                  --
               End if;
            --
            End loop;
            --
         End if;
         --
      End loop;
      --
   End if;
   --
   -- Distribute the budget set among its elements and funding sources using their
   -- distribution percentages.
   --
   If p_distribution_table.COUNT > 0 then
   --
       For rec_no in p_distribution_table.FIRST .. p_distribution_table.LAST loop
           --
           p_distribution_table(rec_no).budget_set_commitment := nvl(p_distribution_table(rec_no).budget_set_dist_percent,0) * p_commitment;
           --
           p_distribution_table(rec_no).element_commitment := nvl(p_distribution_table(rec_no).budget_set_commitment,0) * p_distribution_table(rec_no).el_distribution_percentage * .01;
           --
           p_distribution_table(rec_no).fs_commitment := nvl(p_distribution_table(rec_no).element_commitment,0) * p_distribution_table(rec_no).fs_distribution_percentage * .01;
           --
           --  Print Computed Values
           --
           hr_utility.set_location('----B SET commitment :'||to_char(p_distribution_table(rec_no).budget_set_commitment),7);
           hr_utility.set_location('----EL commitment :'||to_char(p_distribution_table(rec_no).element_commitment),8);
           hr_utility.set_location('----FS commitment :'||to_char(p_distribution_table(rec_no).fs_commitment),9);
           --
           --
       End loop;
   --
   End if;
   --
   hr_utility.set_location('Leaving: '||l_proc, 10);
   --
EXCEPTION
      WHEN OTHERS THEN
      p_distribution_table   := l_distribution_table;
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
End update_distribution_table;
--
--------------------------------------------------------------------------------------------------------------
--
PROCEDURE build_period_commitment (p_budget_period_id    IN   pqh_budget_periods.budget_period_id%TYPE,
                                   p_distribution_table  IN   t_distribution_table,
                                   p_budget_unit_seq     IN   number) IS
--
cnt           NUMBER(10);
rec_no        NUMBER(10);
--
--
l_proc            varchar2(72) := g_package||'build_period_commitment';
--
Begin
 --
 hr_utility.set_location('Entering: '||l_proc, 5);
 --
 --
 If g_period_amt_tab.COUNT > 0  AND p_distribution_table.COUNT > 0 then
    --
    For cnt in g_period_amt_tab.FIRST .. g_period_amt_tab.LAST loop
      --
      For rec_no in p_distribution_table.FIRST .. p_distribution_table.LAST loop
       --
       --
       if(g_period_amt_tab(cnt).cost_allocation_keyflex_id is not null AND
          p_distribution_table(rec_no).cost_allocation_keyflex_id is not null) THEN
         --
         --
         if p_distribution_table(rec_no).budget_period_id = g_period_amt_tab(cnt).period_id AND
            p_distribution_table(rec_no).cost_allocation_keyflex_id = g_period_amt_tab(cnt).cost_allocation_keyflex_id then
            --
            hr_utility.set_location('Period is :'||to_char(g_period_amt_tab(cnt).period_id),100);

            If p_budget_unit_seq  = 1 then
               --
               hr_utility.set_location('CF Commitment1 :'||to_char(g_period_amt_tab(cnt).commitment1),100);
               g_period_amt_tab(cnt).commitment1 :=
                           nvl(g_period_amt_tab(cnt).commitment1,0)+
                           nvl(p_distribution_table(rec_no).fs_commitment,0);
               --
            Elsif p_budget_unit_seq  = 2 then
               --
               hr_utility.set_location('CF Commitment2 : '||to_char(g_period_amt_tab(cnt).commitment2),100);
               g_period_amt_tab(cnt).commitment2 :=
                           nvl(g_period_amt_tab(cnt).commitment2 ,0)+
                           nvl(p_distribution_table(rec_no).fs_commitment,0);
               --
            Elsif p_budget_unit_seq  = 3 then
               --
               hr_utility.set_location('CF Commitment3 : '||to_char(g_period_amt_tab(cnt).commitment3),100);
               g_period_amt_tab(cnt).commitment3 :=
                           nvl(g_period_amt_tab(cnt).commitment3,0)+
                           nvl(p_distribution_table(rec_no).fs_commitment,0);
               --
            End if;
            --
         End if;
         --
         --
       elsif (g_period_amt_tab(cnt).cost_allocation_keyflex_id is null AND
              p_distribution_table(rec_no).cost_allocation_keyflex_id is null) THEN
         --
         --
         if p_distribution_table(rec_no).budget_period_id = g_period_amt_tab(cnt).period_id AND
            p_distribution_table(rec_no).project_id       = g_period_amt_tab(cnt).project_id AND
            p_distribution_table(rec_no).task_id          = g_period_amt_tab(cnt).task_id AND
            p_distribution_table(rec_no).award_id         = g_period_amt_tab(cnt).award_id AND
            p_distribution_table(rec_no).expenditure_type = g_period_amt_tab(cnt).expenditure_type AND
            p_distribution_table(rec_no).organization_id  = g_period_amt_tab(cnt).organization_id
         then
            --
            hr_utility.set_location('Period is :'||to_char(g_period_amt_tab(cnt).period_id),100);

            If p_budget_unit_seq  = 1 then
               --
               hr_utility.set_location('CF Commitment1 :'||to_char(g_period_amt_tab(cnt).commitment1),100);
               g_period_amt_tab(cnt).commitment1 :=
                           nvl(g_period_amt_tab(cnt).commitment1,0)+
                           nvl(p_distribution_table(rec_no).fs_commitment,0);
               --
            Elsif p_budget_unit_seq  = 2 then
               --
               hr_utility.set_location('CF Commitment2 : '||to_char(g_period_amt_tab(cnt).commitment2),100);
               g_period_amt_tab(cnt).commitment2 :=
                           nvl(g_period_amt_tab(cnt).commitment2 ,0)+
                           nvl(p_distribution_table(rec_no).fs_commitment,0);
               --
            Elsif p_budget_unit_seq  = 3 then
               --
               hr_utility.set_location('CF Commitment3 : '||to_char(g_period_amt_tab(cnt).commitment3),100);
               g_period_amt_tab(cnt).commitment3 :=
                           nvl(g_period_amt_tab(cnt).commitment3,0)+
                           nvl(p_distribution_table(rec_no).fs_commitment,0);
               --
            End if;
            --
         End if;
         --
         --
       End IF;
       --
       --
     End loop;
     --
   End loop;
 End if;
 --
 hr_utility.set_location('Leaving: '||l_proc, 10);
 --
EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
 --
End;
--
-------------------------------------------------------------------------------------
--
Procedure distribute_other_commitments
          (p_budget_version_id     IN   pqh_budget_versions.budget_version_id%type,
           p_position_id           IN   pqh_budget_details.position_id%type,
           p_organization_id	   IN   pqh_budget_details.organization_id%type,
           p_job_id		   IN   pqh_budget_details.job_id%type,
           p_grade_id		   IN   pqh_budget_details.grade_id%type,
           p_budget_period_id      IN   pqh_budget_periods.budget_period_id%type,
           p_budget_unit_seq       IN   number,
           p_unit_of_measure_id    IN   pqh_budgets.budget_unit1_id%type,
           p_effective_date	   IN   varchar2) IS
--
l_period_start_date       per_time_periods.start_date%type := NULL;
l_period_end_date         per_time_periods.end_date%type := NULL;
l_commitment              number := NULL;
l_distribution_table      t_distribution_table;
l_budget_ratio_table      t_ratio_table;
l_budget_entity 	  pqh_budgets.budgeted_entity_cd%type := NULL;
l_business_group_id       pqh_budgets.business_group_id%type   :=NULL;
l_commt_value		  number;
l_effective_dt		date;
--
Cursor csr_get_budget_entity_cd is
 Select BGT.BUDGETED_ENTITY_CD , BGT.BUSINESS_GROUP_ID
      From   PQH_BUDGETS BGT,
             PQH_BUDGET_VERSIONS BVR
      Where  BGT.BUDGET_ID = BVR.BUDGET_ID
      And    BGT.POSITION_CONTROL_FLAG ='Y'
      And    l_effective_dt BETWEEN BGT.BUDGET_START_DATE AND BGT.BUDGET_END_DATE
      And    BVR.BUDGET_VERSION_ID = P_BUDGET_VERSION_ID;
l_proc            varchar2(72) := g_package||'distribute_other_commitments';
--
Begin
   --
   hr_utility.set_location('Entering: '||l_proc, 5);
   --
     l_effective_dt := fnd_date.canonical_to_date(p_effective_date);
   --
   -- Obtain the start and end date of the period from per_time_periods
   --
   get_period_dates(p_budget_period_id      => p_budget_period_id,
                    p_period_start_date     => l_period_start_date,
                    p_period_end_date       => l_period_end_date);
   --
   -- For the period and for the specified position , find the commitment
   --
   hr_utility.set_location('UOM : '||to_char(p_unit_of_measure_id),7);
   --
   Open csr_get_budget_entity_cd;

   	Fetch csr_get_budget_entity_cd into l_budget_entity,l_business_group_id;

   close csr_get_budget_entity_cd;
   --
   pqh_bdgt_actual_cmmtmnt_pkg.get_actual_and_cmmtmnt
                   (p_budget_entity          => l_budget_entity,
                    p_position_id            => p_position_id,
                    p_organization_id	     => p_organization_id,
                    p_job_id		     => p_job_id,
                    p_grade_id		     => p_grade_id,
                    p_element_type_id        => NULL,
                    p_start_date             => l_period_start_date,
                    p_end_date               => l_period_end_date,
                    p_unit_of_measure        => hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(p_unit_of_measure_id),
                    p_commt_value	     => l_commt_value,
                    p_actual_value	     => l_commitment,
                    p_business_group_id	     => l_business_group_id,
                    p_effective_date         => l_effective_dt );

                    --p_value_type             => 'C', REMOVED FROM PARAMETER LIST
   --
   -- We now have to start distributing the commitment .
   -- Step 1: Determine the distribution_percent for the budget sets.
   --
   build_budget_set_ratio_table(p_budget_period_id   => p_budget_period_id,
                                p_element_type_id    => NULL,
                                p_budget_unit_seq    => p_budget_unit_seq,
                                p_budget_ratio_table => l_budget_ratio_table);

   --
   -- Step 2: Distribute the commitment among the budget set,elements and
   -- funding sources.
   --
   -- copy values from global table to distribution table.
   --
   l_distribution_table := g_distribution_table;
   --
   update_distribution_table(p_budget_ratio_table   => l_budget_ratio_table,
                             p_commitment           => l_commitment,
                             p_distribution_table   => l_distribution_table);
   --
   -- Step 3: Obtain commitment for each cost alloc flexfield under the period
   --
   build_period_commitment(p_budget_period_id     =>  p_budget_period_id,
                           p_budget_unit_seq      =>  p_budget_unit_seq,
                           p_distribution_table   =>  l_distribution_table);
   --
   hr_utility.set_location('Leaving: '||l_proc, 10);
   --
EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
End;
--
-------------------------------------------------------------------------------------
--
Procedure distribute_money_commitments
          (p_budget_version_id     IN   pqh_budget_versions.budget_version_id%type,
           p_position_id           IN   pqh_budget_details.position_id%type,
           p_organization_id	   IN   pqh_budget_details.organization_id%type,
           p_job_id		   IN   pqh_budget_details.job_id%type,
           p_grade_id		   IN   pqh_budget_details.grade_id%type,
           p_budget_period_id      IN   pqh_budget_periods.budget_period_id%type,
           p_budget_unit_seq       IN   number,
           p_unit_of_measure_id    IN   pqh_budgets.budget_unit1_id%type,
           p_effective_date	   IN   varchar2) IS
--
l_period_start_date       per_time_periods.start_date%type := NULL;
l_period_end_date         per_time_periods.end_date%type := NULL;
--
l_element_type_id         pay_element_types_f.element_type_id%TYPE := NULL;
l_budget_entity 	  pqh_budgets.budgeted_entity_cd%type := NULL;
l_business_group_id	  pqh_budgets.business_group_id%type  := NULL;
l_effective_dt		date;
--
Cursor csr_get_budget_entity_cd is
 Select BGT.BUDGETED_ENTITY_CD, BGT.BUSINESS_GROUP_ID
      From   PQH_BUDGETS BGT,
             PQH_BUDGET_VERSIONS BVR
      Where  BGT.BUDGET_ID = BVR.BUDGET_ID
      And    BGT.POSITION_CONTROL_FLAG ='Y'
      And    l_effective_dt BETWEEN BGT.BUDGET_START_DATE AND BGT.BUDGET_END_DATE
      And    BVR.BUDGET_VERSION_ID = P_BUDGET_VERSION_ID;


--
Cursor csr_bdgt_elmnts is
Select distinct bel.element_type_id
       from pqh_budget_sets bst,pqh_budget_elements bel
 Where bst.budget_period_id = p_budget_period_id
   and bst.budget_set_id = bel.budget_set_id;
--
l_commitment              number := NULL;
l_distribution_table      t_distribution_table;
l_commt_value		  number;
--
l_budget_ratio_table      t_ratio_table;

--
--
l_proc            varchar2(72) := g_package||'distribute_money_commitments';
--
Begin
   --
   hr_utility.set_location('Entering: '||l_proc, 5);
   --
   l_effective_dt := fnd_date.canonical_to_date(p_effective_date);
   --
   hr_utility.set_location('UOM : '||to_char(p_unit_of_measure_id),7);
   -- Obtain the start and end date of the period from per_time_periods
   --
   get_period_dates(p_budget_period_id      => p_budget_period_id,
                    p_period_start_date     => l_period_start_date,
                    p_period_end_date       => l_period_end_date);
   --
   -- copy values from global table to distribution table.
   --
   l_distribution_table := g_distribution_table;
   --
   -- For the period and for the specified position , find the commitment
   --
   Open csr_get_budget_entity_cd;

      	Fetch csr_get_budget_entity_cd into l_budget_entity,l_business_group_id;

   close csr_get_budget_entity_cd;
   --
   hr_utility.set_location('-----Period :'||to_char(l_period_start_date,'DD/MM/RRRR')||' -'||to_char(l_period_end_date,'DD/MM/RRRR'),100);
   Open csr_bdgt_elmnts;
   loop

      Fetch csr_bdgt_elmnts into  l_element_type_id;
      --
      exit when csr_bdgt_elmnts%notfound;
      --
      hr_utility.set_location('-----Processing Element:'||to_char(l_element_type_id),100);
      pqh_bdgt_actual_cmmtmnt_pkg.get_actual_and_cmmtmnt
                   (p_budget_entity          => l_budget_entity,
                    p_position_id            => p_position_id,
                    p_organization_id	     => p_organization_id,
                    p_job_id		     => p_job_id,
                    p_grade_id		     => p_grade_id,
                    p_element_type_id        => l_element_type_id,
                    p_start_date             => l_period_start_date,
                    p_end_date               => l_period_end_date,
                    p_unit_of_measure     => hr_psf_shd.SYSTEM_AVAILABILITY_STATUS(p_unit_of_measure_id),
                    p_commt_value	     => l_commt_value,
                    p_actual_value	     => l_commitment,
                    p_business_group_id	     => l_business_group_id,
                    p_effective_date         => l_effective_dt);

		--p_value_type             => 'C', commented

      hr_utility.set_location('-----ELEMENT COMMITMENT:'||to_char(l_commitment),100);
      --
      -- We now have to start distributing the commitment .
      -- Step 1: Determine the distribution_percent for the budget sets.
      --
      build_budget_set_ratio_table(p_budget_period_id   => p_budget_period_id,
                                   p_element_type_id    => l_element_type_id,
                                   p_budget_unit_seq    => p_budget_unit_seq,
                                   p_budget_ratio_table => l_budget_ratio_table);

      --
      -- Step 2: Distribute the commitment among the budget set,elements and
      -- funding sources.
      --
      update_money_dist_table  (p_budget_ratio_table   => l_budget_ratio_table,
                                p_commitment           => l_commt_value, /* l_commitment,*/
                                p_element_type_id      => l_element_type_id,
                                p_distribution_table   => l_distribution_table);
      --
   End loop;
   --
   Close csr_bdgt_elmnts;
   --
   -- Step 3: Obtain commitment for each cost alloc flexfield under the period
   --
   build_period_commitment(p_budget_period_id     =>  p_budget_period_id,
                           p_budget_unit_seq      =>  p_budget_unit_seq,
                           p_distribution_table   =>  l_distribution_table);
   --
   hr_utility.set_location('Leaving: '||l_proc, 10);
   --
EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
End;
--
--
---------------------------------------------------------------------------------
--
-- This procedure will fetch the commitment for each unit of measure for a
-- budget detail and distribute it to the funding sources.
--
--
PROCEDURE populate_period_commitment_tab (
 p_budget_version_id      IN    pqh_budget_versions.budget_version_id%TYPE,
 p_budget_detail_id       IN    pqh_budget_details.budget_detail_id%TYPE,
 p_position_id            IN    pqh_budget_details.position_id%TYPE,
 p_organization_id	  IN	pqh_budget_details.organization_id%TYPE,
 p_job_id		  IN    pqh_budget_details.job_id%TYPE,
 p_grade_id		  IN 	pqh_budget_details.grade_id%TYPE,
 p_effective_date	  IN    varchar2) IS
--
-- local variables
--
l_budget_period_id              pqh_budget_periods.budget_period_id%TYPE;
l_budget_set_id                 pqh_budget_sets.budget_set_id%TYPE;
l_budget_element_id             pqh_budget_elements.budget_element_id%TYPE;
l_element_type_id               pqh_budget_elements.element_type_id%TYPE;
l_el_distribution_percentage    pqh_budget_fund_srcs.distribution_percentage%TYPE;
l_budget_fund_src_id            pqh_budget_fund_srcs.budget_fund_src_id%TYPE;
l_cost_allocation_keyflex_id    pqh_budget_fund_srcs.cost_allocation_keyflex_id%TYPE;
l_project_id                    pqh_budget_fund_srcs.project_id%TYPE;
l_task_id                       pqh_budget_fund_srcs.task_id%TYPE;
l_award_id                      pqh_budget_fund_srcs.award_id%TYPE;
l_expenditure_type              pqh_budget_fund_srcs.expenditure_type%TYPE;
l_organization_id               pqh_budget_fund_srcs.organization_id%TYPE;
l_fs_distribution_percentage    pqh_budget_fund_srcs.distribution_percentage%TYPE;
--
cnt                             NUMBER(10) := 0;
--
--
CURSOR csr_period_break(p_budget_period_id  IN  NUMBER) IS
SELECT bst.budget_set_id,
       bel.budget_element_id,bel.element_type_id,bel.distribution_percentage,
       bfs.budget_fund_src_id,bfs.cost_allocation_keyflex_id,
       bfs.project_id,bfs.task_id,bfs.award_id,
       bfs.expenditure_type,bfs.organization_id,
       bfs.distribution_percentage
 FROM pqh_budget_fund_srcs bfs, pqh_budget_elements bel,
      pqh_budget_sets bst
WHERE bst.budget_period_id  = p_budget_period_id
  AND bst.budget_set_id     = bel.budget_set_id
  AND bel.budget_element_id = bfs.budget_element_id;
--
Cursor csr_fund_srcs(p_budget_detail_id   IN  NUMBER) is
Select bpr.budget_period_id ,
       bfs.cost_allocation_keyflex_id,
       bfs.project_id,
       bfs.task_id,
       bfs.award_id,
       bfs.expenditure_type,
       bfs.organization_id
FROM pqh_budget_fund_srcs bfs, pqh_budget_elements bel,
     pqh_budget_sets bst, pqh_budget_periods bpr
WHERE bpr.budget_detail_id  = p_budget_detail_id
  AND bpr.budget_period_id  = bst.budget_period_id
  AND bst.budget_set_id     = bel.budget_set_id
  AND bel.budget_element_id = bfs.budget_element_id
GROUP BY bpr.budget_period_id ,bfs.cost_allocation_keyflex_id,bfs.project_id,
       bfs.task_id,bfs.award_id,bfs.expenditure_type, bfs.organization_id;
--
Cursor csr_bdgt_periods is
 Select bpr.budget_period_id
   From pqh_budget_periods bpr
  Where bpr.budget_detail_id  = p_budget_detail_id;
--
l_proc            varchar2(72) := g_package||'populate_period_commitment_tab';
--
Begin
  --
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
  -- Clear the g_distribution_table
  --
  g_period_amt_tab.DELETE;
  --
  -- Build a global table with all period,cost allocation flexfield under the budget_detail
  --
  Open csr_fund_srcs(p_budget_detail_id  =>  p_budget_detail_id);
  --
  loop
     --
     fetch csr_fund_srcs into l_budget_period_id, l_cost_allocation_keyflex_id,l_project_id,
                              l_task_id,l_award_id,l_expenditure_type, l_organization_id;
     --
     exit when csr_fund_srcs%notfound;
     --
     cnt := cnt + 1;
     --
     g_period_amt_tab(cnt).period_id                  := l_budget_period_id;
     g_period_amt_tab(cnt).cost_allocation_keyflex_id := l_cost_allocation_keyflex_id;
     g_period_amt_tab(cnt).project_id                 := l_project_id;
     g_period_amt_tab(cnt).task_id                    := l_task_id;
     g_period_amt_tab(cnt).award_id                   := l_award_id;
     g_period_amt_tab(cnt).expenditure_type           := l_expenditure_type;
     g_period_amt_tab(cnt).organization_id            := l_organization_id;
     --
  End loop;
  Close csr_fund_srcs;
  --
  -- Process each period , one by one
  --
  OPEN csr_bdgt_periods;
  --
  LOOP
  --
    FETCH csr_bdgt_periods into l_budget_period_id;
    --
    EXIT WHEN csr_bdgt_periods%NOTFOUND;
    --
    -- Select all the budget sets , elements and funding sources under that period
    -- and store it in a global table . We will use this table to distribute
    -- commitments.
    --
    hr_utility.set_location('---------------------------------------',101);
    hr_utility.set_location('Processing period :'||to_char(l_budget_period_id),101);
    --
    cnt := 0;
    g_distribution_table.DELETE;
    --
    OPEN csr_period_break(p_budget_period_id  => l_budget_period_id);
    LOOP
      --
      FETCH csr_period_break INTO l_budget_set_id,
                                 l_budget_element_id,l_element_type_id,
                                 l_el_distribution_percentage,
                                 l_budget_fund_src_id,l_cost_allocation_keyflex_id,
                                 l_project_id,l_task_id,l_award_id,l_expenditure_type,
                                 l_organization_id,l_fs_distribution_percentage;
      --
      EXIT WHEN csr_period_break%NOTFOUND;
      --
      cnt := cnt + 1;
      --
      g_distribution_table(cnt).budget_period_id           := l_budget_period_id;
      g_distribution_table(cnt).budget_set_id              := l_budget_set_id;
      g_distribution_table(cnt).budget_element_id          := l_budget_element_id;
      g_distribution_table(cnt).element_type_id            := l_element_type_id;
      g_distribution_table(cnt).el_distribution_percentage := l_el_distribution_percentage;
      g_distribution_table(cnt).budget_fund_src_id         := l_budget_fund_src_id;
      g_distribution_table(cnt).cost_allocation_keyflex_id := l_cost_allocation_keyflex_id;
      g_distribution_table(cnt).project_id                 := l_project_id;
      g_distribution_table(cnt).task_id                    := l_task_id;
      g_distribution_table(cnt).award_id                   := l_award_id;
      g_distribution_table(cnt).expenditure_type           := l_expenditure_type;
      g_distribution_table(cnt).organization_id            := l_organization_id;
      g_distribution_table(cnt).fs_distribution_percentage := l_fs_distribution_percentage;
      --
      hr_utility.set_location('--Period :'||to_char(l_budget_period_id),100);
      hr_utility.set_location('--Budget Set :'||to_char(l_budget_set_id),100);
      hr_utility.set_location('--Element :'||to_char(l_element_type_id),100);
      hr_utility.set_location('--FS :'||to_char(l_cost_allocation_keyflex_id),100);
    END LOOP;
    --
    hr_utility.set_location('Out of loop ',120);
    CLOSE csr_period_break;
    --
    -- For the selected period , we will determine commitments for the 3 units of measure.
    -- For each unit of measure, we will distribute the commitment to its various
    -- funding sources and get the commitment amounts by period, flexfield.
    --
    hr_utility.set_location('Currency Processed :'||g_currency_code1,100);
    If g_currency_code1 = 'STAT' then
        --
        null;
        --
        /* Commented Call to the following procedure as GL does not understand
        'STAT' as an input and gives a EEO3 error in GL import report. The error
        message is EEO3 : Encumbrances can't be in STAT */
        --
        /* distribute_other_commitments
          (p_budget_version_id     => p_budget_version_id,
           p_position_id           => p_position_id,
           p_organization_id	   => p_organization_id,
           p_job_id		   => p_job_id,
           p_grade_id		   => p_grade_id,
           p_budget_period_id      => l_budget_period_id,
           p_budget_unit_seq       => 1,
           p_unit_of_measure_id    => g_budget_uom1,
           p_effective_date	   => p_effective_date); */
        --
    Else
       --
       distribute_money_commitments
          (p_budget_version_id     => p_budget_version_id,
           p_position_id           => p_position_id,
           p_organization_id	   => p_organization_id,
           p_job_id		   => p_job_id,
           p_grade_id		   => p_grade_id,
           p_budget_period_id      => l_budget_period_id,
           p_budget_unit_seq       => 1,
           p_unit_of_measure_id    => g_budget_uom1,
           p_effective_date	   => p_effective_date);
        --
    End if;
    --
    If g_budget_uom2 IS NOT NULL then
       --
       hr_utility.set_location('Currency Processed :'||g_currency_code2,100);
       --
       If g_currency_code2 = 'STAT' then
        --
        null;
        --
        /* Commented Call to the following procedure as GL does not understand
        'STAT' as an input and gives a EEO3 error in GL import report. The error
        message is EEO3 : Encumbrances can't be in STAT */
        --
        /*  distribute_other_commitments
          (p_budget_version_id     => p_budget_version_id,
           p_position_id           => p_position_id,
           p_organization_id	   => p_organization_id,
           p_job_id		   => p_job_id,
           p_grade_id		   => p_grade_id,
           p_budget_period_id      => l_budget_period_id,
           p_budget_unit_seq       => 2,
           p_unit_of_measure_id    => g_budget_uom2,
           p_effective_date	   => p_effective_date); */
        --
       Else
       --
          distribute_money_commitments
          (p_budget_version_id     => p_budget_version_id,
           p_position_id           => p_position_id,
           p_organization_id	   => p_organization_id,
           p_job_id		   => p_job_id,
           p_grade_id		   => p_grade_id,
           p_budget_period_id      => l_budget_period_id,
           p_budget_unit_seq       => 2,
           p_unit_of_measure_id    => g_budget_uom2,
           p_effective_date	   => p_effective_date);
        --
       End if;
       --
    End if;
    --
    If g_budget_uom3 IS NOT NULL then
       --
       hr_utility.set_location('Currency Processed :'||g_currency_code3,100);
       If g_currency_code3 = 'STAT' then
       --
       null;
       --
       /* Commented Call to the following procedure as GL does not understand
        'STAT' as an input and gives a EEO3 error in GL import report. The error
        message is EEO3 : Encumbrances can't be in STAT */
       --
        /*  distribute_other_commitments
          (p_budget_version_id     => p_budget_version_id,
           p_position_id           => p_position_id,
           p_organization_id	   => p_organization_id,
           p_job_id		   => p_job_id,
           p_grade_id		   => p_grade_id,
           p_budget_period_id      => l_budget_period_id,
           p_budget_unit_seq       => 3,
           p_unit_of_measure_id    => g_budget_uom3,
           p_effective_date	   => p_effective_date); */
       --
       Else
       --
          distribute_money_commitments
          (p_budget_version_id     => p_budget_version_id,
           p_position_id           => p_position_id,
           p_organization_id	   => p_organization_id,
           p_job_id		   => p_job_id,
           p_grade_id		   => p_grade_id,
           p_budget_period_id      => l_budget_period_id,
           p_budget_unit_seq       => 3,
           p_unit_of_measure_id    => g_budget_uom3,
           p_effective_date	   => p_effective_date);
       --
       End if;
       --
    End if;
    --
  END LOOP;
  --
  CLOSE csr_bdgt_periods;
  --
  --
  hr_utility.set_location('Leaving:'||l_proc, 1000);
  --
EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302,'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
--
END populate_period_commitment_tab;
--
-------------------------------------------------------------------------------------------
--
PROCEDURE get_gl_period
(
  p_budget_period_id              IN   pqh_budget_periods.budget_period_id%TYPE,
  p_set_of_books_id               IN   pqh_budgets.gl_set_of_books_id%type,
  p_gl_period_statuses_rec        OUT NOCOPY  gl_period_statuses%ROWTYPE
) IS
--
-- This procedure will return the period name corresponding to start_date between
-- gl_period_statuses.start_date and gl_period_statuses.end_date
--
-- local variables
--
  l_start_date               DATE;
  l_gl_period_statuses_rec   gl_period_statuses%ROWTYPE;
--
 CURSOR csr_time_period IS
 SELECT start_date
 FROM per_time_periods
 WHERE time_period_id = ( SELECT start_time_period_id
                          FROM pqh_budget_periods
                          WHERE budget_period_id = p_budget_period_id );
--
 CURSOR csr_period_name( p_start_date  IN DATE ) IS
 SELECT *
 FROM  gl_period_statuses
 WHERE application_id = g_application_id
   AND set_of_books_id = g_set_of_books_id
   AND closing_status  = 'O'
   AND p_start_date BETWEEN start_date AND end_date;

--
 l_proc                     varchar2(72) := g_package||'get_gl_period';
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- get the budget start date
  --
  OPEN csr_time_period;
  FETCH csr_time_period INTO l_start_date;
  CLOSE csr_time_period;
  --
  hr_utility.set_location('Budget Start Date : '||l_start_date,10);
  --
  -- get the period name and accounting date
  --
  OPEN csr_period_name( p_start_date => l_start_date);
  FETCH csr_period_name INTO l_gl_period_statuses_rec;
  CLOSE csr_period_name;
  --
  p_gl_period_statuses_rec      := l_gl_period_statuses_rec;
  --
  hr_utility.set_location('Period Name : '||l_gl_period_statuses_rec.period_name,20);
  --
  hr_utility.set_location('Leaving:'||l_proc, 1000);
  --
EXCEPTION
      WHEN OTHERS THEN
      p_gl_period_statuses_rec := l_gl_period_statuses_rec;
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END get_gl_period;
--
-----------------------------------------------------------------------------------------
--
PROCEDURE update_period_commitment_tab
(
 p_budget_detail_id          IN       pqh_budget_details.budget_detail_id%TYPE,
 p_post_to_period_name		 IN  gl_period_statuses.period_name%TYPE
)
IS
 --
 -- The foll procedure reads the global table g_period_amt_tab and
 -- fetches the period_name and code_combination_id corresponding to the
 -- period_id and cost_allocation_keyflex_id.If it does not find a period_name
 -- or a code_combination_id then it will populate the global variable
 -- g_detail_error to Y and we will not populate the pqh_gl_interface
 -- table for the current budget_detail_id.
 --
 l_gl_period_statuses_rec       gl_period_statuses%ROWTYPE;
 l_period_name                  gl_period_statuses.period_name%TYPE;
 l_accounting_date              gl_period_statuses.start_date%TYPE;
 --
 l_code_combination_id          gl_code_combinations.code_combination_id%TYPE;
 --
 l_message_text                 pqh_process_log.message_text%TYPE;
 l_log_context                  pqh_process_log.log_context%TYPE;
--
 l_proc                         varchar2(72) := 'update_period_commitment_tab';
--
BEGIN

  hr_utility.set_location('Entering: '||l_proc, 5);

  -- initialize g_detail_error
     g_detail_error := 'N';

  IF NVL(g_period_amt_tab.COUNT,0) <> 0 THEN

     FOR i IN NVL(g_period_amt_tab.FIRST,0)..NVL(g_period_amt_tab.LAST,-1) LOOP
     --
     -- Check if record is GL Record or Grant Record
     --
     IF  g_period_amt_tab(i).cost_allocation_keyflex_id is NOT NULL THEN
        --
        -- For the period , check if there is a corresponding gl period.
        --
        IF  p_post_to_period_name is not null then
        	hr_utility.set_location('Entering: '||l_proc, 10000000);
		      hr_utility.set_location('p_post_to_period_name: '||p_post_to_period_name, 10000000);
      		hr_utility.set_location('g_application_id: '||g_application_id, 10000000);
		      hr_utility.set_location('g_set_of_books_id: '||g_set_of_books_id, 10000000);
		      hr_utility.set_location('g_budget_id: '||g_budget_id, 10000000);
      		l_period_name := p_post_to_period_name;
      		SELECT gl.start_date into l_accounting_date
      		FROM gl_period_statuses gl,  pqh_budgets bdgt
      		WHERE gl.application_id = g_application_id
      		AND gl.closing_status = 'O'
      		AND gl.set_of_books_id = g_set_of_books_id
      		AND gl.period_name = p_post_to_period_name
      		AND bdgt.budget_id = g_budget_id
      		AND gl.start_date <= bdgt.budget_end_date
      		AND gl.end_date >= bdgt.budget_start_date ;
      	ELSE
      		get_gl_period(p_budget_period_id => g_period_amt_tab(i).period_id,
    			p_set_of_books_id => g_set_of_books_id,
    			p_gl_period_statuses_rec  => l_gl_period_statuses_rec );
      		l_period_name := l_gl_period_statuses_rec.period_name;
    	   	l_accounting_date := l_gl_period_statuses_rec.start_date;
    	   END IF;

        --
        IF l_period_name IS NULL THEN
           --
           -- no period name found mark detail as error and proceed
           --
           g_detail_error := 'Y';
           hr_utility.set_location('#######No Period#####',101);
           --
           -- get log_context
           --
           pqh_gl_posting.set_bpr_log_context
           (
                p_budget_period_id        => g_period_amt_tab(i).period_id,
                p_log_context             => l_log_context
           );
           --
           -- set the context
           --
           pqh_process_batch_log.set_context_level
           (
               p_txn_id                =>  g_period_amt_tab(i).period_id,
               p_txn_table_route_id    =>  g_table_route_id_bpr,
               p_level                 =>  2,
               p_log_context           =>  l_log_context
           );
           --
           -- Get the error message.
           --
           FND_MESSAGE.SET_NAME('PQH','PQH_INVALID_GL_BUDGET_PERIOD');
           l_message_text := FND_MESSAGE.GET;
           --
           -- insert error into process log
           --
           pqh_process_batch_log.insert_log
           (
               p_message_type_cd    =>  'ERROR',
               p_message_text       =>  l_message_text
           );
          --
       ELSE
          --
          -- update the pl sql table with period name and accounting date
          --
          g_period_amt_tab(i).period_name     := l_period_name;
          g_period_amt_tab(i).accounting_date := l_accounting_date;
          --
       END IF;
       --
       -- gl account ,
       -- Note : Change gl_posting to take the extra parameter.
       --
       pqh_gl_posting.get_ccid_for_commitment
       (
           p_budget_id                   => g_budget_id,
           p_chart_of_accounts_id        => g_chart_of_accounts_id,
           p_budget_detail_id            => p_budget_detail_id,
           p_budget_period_id            => g_period_amt_tab(i).period_id,
           p_cost_allocation_keyflex_id  => g_period_amt_tab(i).cost_allocation_keyflex_id,
           p_code_combination_id         => l_code_combination_id
       );

       IF l_code_combination_id IS NULL THEN
           --
           -- no gl account found, mark as error
           --
           hr_utility.set_location('#######No l_code_combination_id#####',101);
           g_detail_error := 'Y';
           --
           -- get log_context
           --
           pqh_gl_posting.set_bfs_log_context
           (
                p_cost_allocation_keyflex_id   => g_period_amt_tab(i).cost_allocation_keyflex_id,
                p_log_context                  => l_log_context
           );
           --
           -- set the context
           --
           pqh_process_batch_log.set_context_level
           (
               p_txn_id                =>  g_period_amt_tab(i).cost_allocation_keyflex_id,
               p_txn_table_route_id    =>  g_table_route_id_bfs,
               p_level                 =>  2,
               p_log_context           =>  l_log_context
           );
          --
          FND_MESSAGE.SET_NAME('PQH','PQH_INVALID_GL_BUDGET_ACCOUNT');
          l_message_text := FND_MESSAGE.GET;
          --
          -- insert error
          --
          pqh_process_batch_log.insert_log
          (
               p_message_type_cd    =>  'ERROR',
               p_message_text       =>  l_message_text
          );
          --
          --
      ELSE
          --
          -- update the pl sql table with gl account
          --
          g_period_amt_tab(i).code_combination_id  := l_code_combination_id;
          --
          --
      END IF;
      --
    ELSE
         --
         -- This is a GMS record
         --
         g_period_amt_tab(i).period_name := to_char(g_period_amt_tab(i).period_id);
    END IF;
    --
    --
    END LOOP; -- end of all periods,cost_flexfield under the budget detail
    --
  END IF;
  --
  hr_utility.set_location('Leaving:'||l_proc, 1000);
  --
EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END update_period_commitment_tab;
--
--
/************************************************************************************************************
  This procedure will check if the current budget_detail_id was already posted (exists in pqh_gl_interface)
  If Yes, it would build a pl/sql table with all records which have this current budget_detail_id.
  This is done as the user might have changed the records with current budget_detail_id which were previously
  posted and not present in new records. For those records we need to unpost i.e reverse the transactions.

  Consider the following example :

<-----------  Old ------------------------>               <-------------  New  ------>
Budget_detail_id   Period    CCID   Cur  Amt              Period    CCID     Cur  Amt
1                  1         1      US   100  (reverse)   1         1        UK   100  ( new )
                   2         2      US   100  (reverse)   6         2        US   100  ( new )
                   3         3      US   100  (update)    3         3        US   200  ( update )
                   4         4      US   100  (unchanged) 4         4        US   100  ( unchanged )
                                                          4         7        UK   100  ( new )
                                                          7         9        US   100  ( new )


***************************************************************************************************************/
--
PROCEDURE build_old_bdgt_dtls_tab
(
 p_budget_detail_id         IN pqh_budget_details.budget_detail_id%TYPE,
 p_posting_type_cd          IN varchar2
) IS
--
-- local variables
--
l_pqh_gl_interface_rec    pqh_gl_interface%ROWTYPE;
i                                BINARY_INTEGER :=1;
--
--
CURSOR csr_old_bdgt_dtls_rec IS
SELECT *
FROM pqh_gl_interface
WHERE budget_version_id        =  g_budget_version_id
  AND budget_detail_id         =  p_budget_detail_id
  AND posting_type_cd          =  p_posting_type_cd
  AND NVL(adjustment_flag,'N') = 'N'
  AND status IS NOT NULL
  AND posting_date IS NOT NULL
  AND (NVL(amount_dr,0) > 0 OR NVL(amount_cr,0) > 0 ) ;
--
l_proc                    varchar2(72) := g_package||'build_old_bdgt_dtls_tab';
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Print Passed values
  --
  hr_utility.set_location('Budget Version:'||to_char(g_budget_version_id), 6);
  hr_utility.set_location('Budget Detail:'||to_char(p_budget_detail_id), 7);
  hr_utility.set_location('Posting Type:'||p_posting_type_cd, 8);
  --
  OPEN csr_old_bdgt_dtls_rec;
  --
  LOOP
      --
      FETCH csr_old_bdgt_dtls_rec INTO l_pqh_gl_interface_rec;
      EXIT WHEN csr_old_bdgt_dtls_rec%NOTFOUND;
      --
      g_old_bdgt_dtls_tab(i).budget_version_id            := g_budget_version_id;
      g_old_bdgt_dtls_tab(i).budget_detail_id             := p_budget_detail_id;
      g_old_bdgt_dtls_tab(i).period_name                  := l_pqh_gl_interface_rec.period_name;
      g_old_bdgt_dtls_tab(i).accounting_date              := l_pqh_gl_interface_rec.accounting_date;
      g_old_bdgt_dtls_tab(i).cost_allocation_keyflex_id   := l_pqh_gl_interface_rec.cost_allocation_keyflex_id;
      g_old_bdgt_dtls_tab(i).code_combination_id          := l_pqh_gl_interface_rec.code_combination_id;
      g_old_bdgt_dtls_tab(i).project_id                   := l_pqh_gl_interface_rec.project_id;
      g_old_bdgt_dtls_tab(i).task_id                      := l_pqh_gl_interface_rec.task_id;
      g_old_bdgt_dtls_tab(i).award_id                     := l_pqh_gl_interface_rec.award_id ;
      g_old_bdgt_dtls_tab(i).expenditure_type             := l_pqh_gl_interface_rec.expenditure_type;
      g_old_bdgt_dtls_tab(i).organization_id              := l_pqh_gl_interface_rec.organization_id;
      g_old_bdgt_dtls_tab(i).currency_code                := l_pqh_gl_interface_rec.currency_code;
      g_old_bdgt_dtls_tab(i).amount_dr                    := l_pqh_gl_interface_rec.amount_dr;
      g_old_bdgt_dtls_tab(i).amount_cr                    := l_pqh_gl_interface_rec.amount_cr;
      g_old_bdgt_dtls_tab(i).reverse_flag                 := 'Y';
      --
      i := i + 1;
      --
   END LOOP;
   --
   CLOSE csr_old_bdgt_dtls_rec;
   --
   hr_utility.set_location('No of old records :'||NVL(g_old_bdgt_dtls_tab.COUNT,0), 9);
   --
   hr_utility.set_location('Leaving:'||l_proc, 10);
   --
EXCEPTION
      WHEN OTHERS THEN
        --
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
        --
END build_old_bdgt_dtls_tab;
--
----------------------------------------------------------------------------------
--
--  This procedure will compare the g_old_bdgt_dtls_tab with g_period_amt_tab .
--  It will check if there are records in g_old_bdgt_dtls_tab which are not in
--  g_period_amt_tab and update the reverse flag for those records to 'Y' so
--  that we can reverse those records
--
PROCEDURE compare_old_bdgt_dtls_tab IS
--
-- local variables
--
l_proc                    varchar2(72) := g_package||'compare_old_bdgt_dtls_tab';
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- for each record in g_old_bdgt_dtls_tab,loop thru the g_period_amt_tab
  -- to check if the record exists in g_period_amt_tab,if yes then set
  -- reverse_flag is N,else update the reverse_flag in g_old_bdgt_dtls_tab
  -- to 'Y'
  --
   IF  NVL(g_old_bdgt_dtls_tab.COUNT,0) <> 0 AND
       NVL(g_period_amt_tab.COUNT,0)    <> 0 AND
       g_detail_error = 'N'                  THEN
       --
       -- for each record in old
       --
       FOR i IN NVL(g_old_bdgt_dtls_tab.FIRST,0)..NVL(g_old_bdgt_dtls_tab.LAST,-1)
       --
       LOOP
           --
           -- loop thru the new g_period_amt_tab to check if the record exists
           --
           FOR j IN NVL(g_period_amt_tab.FIRST,0)..NVL(g_period_amt_tab.LAST,-1)
           LOOP
               --
            IF (g_old_bdgt_dtls_tab(i).cost_allocation_keyflex_id is not null and g_period_amt_tab(j).cost_allocation_keyflex_id is not null )
            THEN
               --
               IF g_old_bdgt_dtls_tab(i).period_name = g_period_amt_tab(j).period_name AND
                  g_old_bdgt_dtls_tab(i).code_combination_id = g_period_amt_tab(j).code_combination_id AND
                  g_old_bdgt_dtls_tab(i).currency_code IN(g_currency_code1,g_currency_code2,g_currency_code3)THEN
                  --
                  -- record found, go to next record
                  --
                  hr_utility.set_location('Do NOT Reverse old Record',7);
                  --
                  g_old_bdgt_dtls_tab(i).reverse_flag := 'N';
                  --
                  exit ; -- inner loop
                  --
               END IF;
            ELSIF (g_old_bdgt_dtls_tab(i).cost_allocation_keyflex_id is null and g_period_amt_tab(j).cost_allocation_keyflex_id is null )
            THEN
              --
              IF g_old_bdgt_dtls_tab(i).period_name      = g_period_amt_tab(j).period_name AND
                 g_old_bdgt_dtls_tab(i).project_id       = g_period_amt_tab(j).project_id  AND
		 g_old_bdgt_dtls_tab(i).task_id          = g_period_amt_tab(j).task_id  AND
		 g_old_bdgt_dtls_tab(i).award_id         = g_period_amt_tab(j).award_id   AND
		 g_old_bdgt_dtls_tab(i).expenditure_type = g_period_amt_tab(j).expenditure_type  AND
                 g_old_bdgt_dtls_tab(i).organization_id  = g_period_amt_tab(j).organization_id
	         THEN
	          --
	          -- record found, go to next record
	          --
	          hr_utility.set_location('Do NOT Reverse old Record',7);
	          --
	          g_old_bdgt_dtls_tab(i).reverse_flag := 'N';
	          --
	          exit ; -- inner loop
	          --
               END IF;
               --
            END IF;
               --
           END LOOP; -- for the g_period_amt_tab table
           --
       END LOOP; -- for the old g_old_bdgt_dtls_tab table
       --
   END IF; -- if both old and new tables have records and there was no error in new table
   --
   hr_utility.set_location('Leaving:'||l_proc, 10);
   --
EXCEPTION
      WHEN OTHERS THEN
        --
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
        --
END compare_old_bdgt_dtls_tab;
--
---------------------------------------------------------------------------------
--
-- This procedure will loop thru the g_old_bdgt_dtls_tab and generate reverse
-- transaction for all records where reverse_flag is Y and update the posted
-- record amount to 0
--
PROCEDURE reverse_old_bdgt_dtls_tab
( p_budget_detail_id         IN pqh_budget_details.budget_detail_id%TYPE,
  p_posting_type_cd          IN varchar2) IS
--
-- local variables
--
l_pqh_gl_interface_rec    pqh_gl_interface%ROWTYPE;
--
 CURSOR csr_pqh_gl_interface(p_period_name IN  varchar2,
                             p_code_combination_id  IN number,
                             p_currency_code IN varchar2) IS
 SELECT *
  FROM pqh_gl_interface
 WHERE budget_version_id    = g_budget_version_id
   AND budget_detail_id     = p_budget_detail_id
   AND posting_type_cd      = p_posting_type_cd
   AND period_name          = p_period_name
   AND code_combination_id  = p_code_combination_id
   AND currency_code        = p_currency_code
   AND NVL(adjustment_flag,'N') = 'N'
   AND status IS NOT NULL
   AND posting_date IS NOT NULL
   AND cost_allocation_keyflex_id is not null
  FOR UPDATE of amount_dr;


  CURSOR csr_pqh_gms_interface(p_period_name      IN varchar2,
                               p_project_id       IN number,
                               p_task_id          IN number,
                               p_award_id         IN number,
                               p_expenditure_type IN varchar2,
                               p_organization_id  IN number,
                               p_currency_code    IN varchar2) IS
   SELECT *
    FROM pqh_gl_interface
   WHERE budget_version_id        = g_budget_version_id
     AND budget_detail_id         = p_budget_detail_id
     AND posting_type_cd          = p_posting_type_cd
     AND period_name              = p_period_name
     AND project_id               = p_project_id
     AND task_id                  = p_task_id
     AND award_id                 = p_award_id
     AND expenditure_type         = p_expenditure_type
     AND organization_id          = p_organization_id
     AND currency_code            = p_currency_code
     AND NVL(adjustment_flag,'N') = 'N'
     AND status IS NOT NULL
     AND posting_date IS NOT NULL
     AND cost_allocation_keyflex_id is null
  FOR UPDATE of amount_dr;
--
l_proc                    varchar2(72) := g_package||'reverse_old_bdgt_dtls_tab';
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location('Budget Detail Id : '||p_budget_detail_id,6);
  --
   IF  NVL(g_old_bdgt_dtls_tab.COUNT,0) <> 0 AND
       NVL(g_period_amt_tab.COUNT,0)    <> 0 AND
       --
       g_detail_error = 'N'                  THEN
       --
       -- for each record in old
       --
       FOR i IN NVL(g_old_bdgt_dtls_tab.FIRST,0)..NVL(g_old_bdgt_dtls_tab.LAST,-1)
       LOOP
        IF g_old_bdgt_dtls_tab(i).reverse_flag = 'Y' THEN
          hr_utility.set_location('Reversing .... ',8);
          hr_utility.set_location('Period Name is '||g_old_bdgt_dtls_tab(i).period_name,8);
          hr_utility.set_location('code_combination_id '||g_old_bdgt_dtls_tab(i).code_combination_id,8);
          hr_utility.set_location('currency_code '|| g_old_bdgt_dtls_tab(i).currency_code,8);
          --
          -- update the record and reverse the txn
          --
          IF g_old_bdgt_dtls_tab(i).cost_allocation_keyflex_id  is NOT NULL
          THEN
               OPEN csr_pqh_gl_interface(p_period_name => g_old_bdgt_dtls_tab(i).period_name,
                                         p_code_combination_id => g_old_bdgt_dtls_tab(i).code_combination_id,
                                         p_currency_code => g_old_bdgt_dtls_tab(i).currency_code) ;
               FETCH csr_pqh_gl_interface INTO l_pqh_gl_interface_rec;

               hr_utility.set_location('Fetched record ',10);

               --
               -- Reverse the old record.
               --
               UPDATE pqh_gl_interface
                  SET amount_dr = 0
                WHERE CURRENT OF csr_pqh_gl_interface;

               CLOSE  csr_pqh_gl_interface;
          ELSE
               OPEN csr_pqh_gms_interface(p_period_name       => g_old_bdgt_dtls_tab(i).period_name,
	                                  p_project_id        => g_old_bdgt_dtls_tab(i).project_id,
					  p_task_id           => g_old_bdgt_dtls_tab(i).task_id,
					  p_award_id          => g_old_bdgt_dtls_tab(i).award_id,
					  p_expenditure_type  => g_old_bdgt_dtls_tab(i).expenditure_type,
                                          p_organization_id   => g_old_bdgt_dtls_tab(i).organization_id,
	                                  p_currency_code     => g_old_bdgt_dtls_tab(i).currency_code) ;
	       FETCH csr_pqh_gms_interface INTO l_pqh_gl_interface_rec;

	       hr_utility.set_location('Fetched record ',10);

	       --
	       -- Reverse the old record.
	       --
	       UPDATE pqh_gl_interface
	         SET amount_dr = 0
               WHERE CURRENT OF csr_pqh_gms_interface;

               CLOSE  csr_pqh_gms_interface;
          END IF;
               --
               -- create a reverse transaction for this amount_dr
               --
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
                          posting_type_cd,
                          posting_date
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
                          g_old_bdgt_dtls_tab(i).project_id,
                          g_old_bdgt_dtls_tab(i).task_id,
                          g_old_bdgt_dtls_tab(i).award_id,
                          g_old_bdgt_dtls_tab(i).expenditure_type,
                          g_old_bdgt_dtls_tab(i).organization_id,
                          0,
                          NVL(l_pqh_gl_interface_rec.amount_dr,0),
                          g_old_bdgt_dtls_tab(i).currency_code,
                          null,
                          'Y',
                          'COMMITMENT',
                          null
               );
               --

               hr_utility.set_location('Created a reverse txn ',20);


        END IF;  -- if the transaction reverse_flag is Y
            --
       END LOOP;
        --
  END IF;  -- if both old and new tables have records and there was no error in new table
  --
  hr_utility.set_location('Leaving:'||l_proc, 1000);
  --
EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END reverse_old_bdgt_dtls_tab;
--
---------------------------------------------------------------------------------------
--
PROCEDURE reverse_budget_details
(
 p_period_name              IN  pqh_gl_interface.period_name%TYPE,
 p_currency_code            IN  pqh_gl_interface.currency_code%TYPE,
 p_code_combination_id      IN  pqh_gl_interface.code_combination_id%TYPE,
 p_posting_type_cd         IN varchar2
) IS
--
-- This procedure will be called if the GL fund checker failed.
-- This procedure will does the following : 1. update all the budget_detail
-- records which have this Period Name + CCID + currency code to ERROR ( gl_status)
-- 2. Reverse unposted adjustment txns in pqh_gl_interface
-- 3. Delete all unposted non-adjustment txns from pqh_gl_interface
-- Note : If a budget detail record has 4 periods and there was a error in 4th period ,
-- we have no control on the 1st three as they have already been Approved by funds
-- checker program and would have already been posted to GL.
--
-- local variables
--
l_pqh_gl_interface_rec    pqh_gl_interface%ROWTYPE;
--
CURSOR csr_adj IS
SELECT *
FROM pqh_gl_interface
WHERE budget_version_id = g_budget_version_id
  AND period_name = p_period_name
  AND currency_code = p_currency_code
  AND code_combination_id = p_code_combination_id
  AND posting_type_cd = p_posting_type_cd
  AND NVL(adjustment_flag,'N') = 'Y'
  AND status IS NULL
  AND posting_date IS NULL;
--
l_proc                    varchar2(72) := g_package||'reverse_budget_details';
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- reverse the adjustment transactions
  --
  OPEN csr_adj;
  LOOP
     FETCH csr_adj INTO l_pqh_gl_interface_rec;
     EXIT WHEN csr_adj%NOTFOUND;
     --
     -- update the amount_dr for the original record
     --
     UPDATE pqh_gl_interface
        SET amount_dr = NVL(amount_dr,0) -
                        NVL(l_pqh_gl_interface_rec.amount_dr,0) +
                        NVL(l_pqh_gl_interface_rec.amount_cr,0)
         WHERE budget_version_id = l_pqh_gl_interface_rec.budget_version_id
           AND budget_detail_id = l_pqh_gl_interface_rec.budget_detail_id
           AND period_name = l_pqh_gl_interface_rec.period_name
           AND currency_code = l_pqh_gl_interface_rec.currency_code
           AND code_combination_id = l_pqh_gl_interface_rec.code_combination_id
           AND posting_type_cd = p_posting_type_cd
           AND NVL(adjustment_flag,'N') = 'N'
           AND status IS NOT NULL;

  END LOOP;
  CLOSE csr_adj;
  --
  -- update the pqh_budget_details table gl_status to ERROR
  --
  UPDATE pqh_budget_details
     SET commitment_gl_status = 'ERROR'
   WHERE budget_version_id    = g_budget_version_id
     AND budget_detail_id IN
       ( SELECT distinct budget_detail_id
         FROM pqh_gl_interface
         WHERE budget_version_id = g_budget_version_id
           AND period_name = p_period_name
           AND currency_code = p_currency_code
           AND code_combination_id = p_code_combination_id
           AND posting_type_cd = p_posting_type_cd
           AND status IS NULL
           AND posting_date IS NULL
        );
  --
  -- delete the unposted transactions from pqh_gl_interface
  --
  DELETE FROM pqh_gl_interface
   WHERE budget_version_id = g_budget_version_id
     AND period_name = p_period_name
     AND currency_code = p_currency_code
     AND code_combination_id = p_code_combination_id
     AND posting_type_cd = p_posting_type_cd
     AND status IS NULL
     AND posting_date IS NULL;
  --
  hr_utility.set_location('Leaving:'||l_proc, 1000);
  --
EXCEPTION
      WHEN OTHERS THEN
        --
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
        --
END reverse_budget_details;
--
-----------------------------------------------------------------------------------------
--
-- This procedure will pick records from pqh_gl_interface table and insert them into
-- gl tables depending on the g_budgetary_control_flag If we insert into gl_bc_packets
-- do funds checking for each packet
--
PROCEDURE populate_gl_tables
IS
--
-- local variables
--
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
 --
 CURSOR csr_pqh_gl_interface IS
 SELECT period_name, accounting_date,
        code_combination_id, cost_allocation_keyflex_id, currency_code,
        SUM(NVL(amount_dr,0))  amount_dr,
        SUM(NVL(amount_cr,0))  amount_cr
 FROM pqh_gl_interface
 WHERE budget_version_id IN (g_budget_version_id, NVL(g_last_posted_ver,0) )
   AND status IS NULL
   AND posting_date IS NULL
   AND posting_type_cd = 'COMMITMENT'
   AND cost_allocation_keyflex_id is NOT NULL
 GROUP BY period_name, accounting_date,code_combination_id,
          cost_allocation_keyflex_id,currency_code;
 --
 CURSOR csr_packet_id IS
 SELECT gl_bc_packets_s.nextval
 FROM dual;
 --
 CURSOR csr_period_name( p_period_name  IN varchar2 ) IS
 SELECT *
 FROM  gl_period_statuses
 WHERE application_id = g_application_id
   AND set_of_books_id = g_set_of_books_id
   AND period_name  = p_period_name;
 --
 CURSOR csr_gl_lookups(p_lookup_code IN varchar2 ) IS
 SELECT description
 FROM gl_lookups
 WHERE lookup_type = 'FUNDS_CHECK_RESULT_CODE'
   AND lookup_code = p_lookup_code
   AND NVL(enabled_flag,'N') = 'Y';
 --
 CURSOR csr_gl_packet_code(p_packet_id IN number ) IS
 SELECT result_code
 FROM gl_bc_packets
 WHERE packet_id = p_packet_id;
 --
 CURSOR csr_gl_status(p_lookup_code IN varchar2 ) IS
 SELECT description
 FROM gl_lookups
 WHERE lookup_type = 'FUNDS_CHECK_STATUS_CODE'
   AND lookup_code = p_lookup_code
   AND NVL(enabled_flag,'N') = 'Y';
 --
 l_proc                         varchar2(72) := g_package||'populate_gl_tables';
 --
BEGIN
  --
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
  IF g_budgetary_control_flag = 'Y' THEN
     --
     -- insert into gl_bc_packets and do funds checking for each packet
     --
     hr_utility.set_location('Inserting into GL_BC_PACKETS',10);
     --
     OPEN csr_pqh_gl_interface;
     LOOP
        --
        FETCH csr_pqh_gl_interface INTO l_period_name, l_accounting_date,
              l_code_combination_id, l_cost_allocation_keyflex_id, l_currency_code,
              l_amount_dr, l_amount_cr;
        EXIT WHEN csr_pqh_gl_interface%NOTFOUND;
        --
        -- Get Packet ID
        --
        OPEN csr_packet_id;
        FETCH csr_packet_id INTO l_packet_id;
        CLOSE csr_packet_id;
        --
        -- get period details
        --
        OPEN csr_period_name(p_period_name => l_period_name);
        FETCH csr_period_name INTO l_gl_period_statuses_rec;
        CLOSE csr_period_name;
         --
         -- compute the GL funds checker Mode
         --
         IF g_validate THEN
             --
             -- this is validate ONLY mode
             --
             l_fc_mode := 'C';
             --
         ELSIF NVL(l_amount_dr,0) > 0 THEN
             --
             -- this is debit so run fund checker in reserved mode
             --
             l_fc_mode := 'R';
             --
         ELSE
             --
             -- this is credit so run fund checker in unreserved mode
             --
             l_fc_mode := 'U';
             --
         END IF;
         --
         --
         -- Call the GL funds checker. The GL funds checker program has COMMIT inside
         -- the program.so we cannot rollback.  The  GL funds checker is only called
         -- when the validate flag is false i.e no validation
         -- do funds checking for each packet
         -- Mode = R (reserved) if amount is dr
         -- Mode = U (unreserved) if amount is cr
         -- Mode = C (Checking) if program is run in validate mode i.e g_validate = TRUE
         -- Mode C is never called as there as explicit commits in GL funds checker program , so
         -- we call the GL funds checker program only when g_validate is FALSE in R or U mode

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
          --
          -- get the return code desc from GL lookups
          --
          OPEN csr_gl_status(p_lookup_code => l_fc_return);
          FETCH csr_gl_status INTO l_packet_status_code;
          CLOSE csr_gl_status;
          --
          hr_utility.set_location('GL Fund Checker return Code Desc : '||l_packet_status_code,111);
          --
          -- If the fund checker program failed i.e l_fc_success = FALSE or
          -- l_fc_return in ('T', 'F','R') then we would do the following :
          -- 1. Put the error message in pqh_process_log ( context : Period Name + CCID + currency code )
          -- 2.update gl_status of budget_detail records which have this Period Name+CCID+currency code to ERROR
          -- 3. Reverse unposted adjustment txns in pqh_gl_interface
          -- 4. Delete all unposted non-adjustment txns from pqh_gl_interface
          --
          IF NOT ( l_fc_success )  OR ( NVL(l_fc_return,'T') in ('T', 'F','R') ) THEN
             --
             -- fund checker failed
             --
             hr_utility.set_location('Fund Checker Failed ',120);
             --
             -- STEP 1: Log the Error Message
             -- get the error message which is populated in case of fatal error i.e l_fc_return = T
             --
             l_fc_message := fnd_message.get;
             --
             -- if the above error message is null then get from result code
             --
             IF l_fc_message IS NULL THEN
                OPEN csr_gl_packet_code(p_packet_id => l_packet_id);
                FETCH csr_gl_packet_code INTO l_packet_result_code;
                CLOSE csr_gl_packet_code;

                OPEN csr_gl_lookups(p_lookup_code => l_packet_result_code);
                FETCH csr_gl_lookups INTO l_fc_message;
                CLOSE csr_gl_lookups;
             END IF;
             --
             hr_utility.set_location('Fund Chk Error : '||substr(l_fc_message,1,50),120);
             --
             -- set the log context and insert into log
             --
             l_log_context := l_period_name||' - '||l_code_combination_id||' - '||l_currency_code;
             --
             hr_utility.set_location('Log Context : '||l_log_context,130);
             --
             -- set the context
             --
             pqh_process_batch_log.set_context_level
                 (
                  p_txn_id                =>  l_packet_id,
                  p_txn_table_route_id    =>  g_table_route_id_glf,
                  p_level                 =>  1,
                  p_log_context           =>  l_log_context
                  );
             --
             -- insert error
             --
             pqh_process_batch_log.insert_log
                 (
                  p_message_type_cd    =>  'ERROR',
                  p_message_text       =>  l_packet_status_code||' : '||l_fc_message
                 );
             --
             hr_utility.set_location('Inserted Error and calling reverse txn ',140);
             --
             -- Reverse budget details
             --
             reverse_budget_details
               (
                p_period_name             => l_period_name ,
                p_currency_code           => l_currency_code ,
                p_code_combination_id     => l_code_combination_id ,
                p_posting_type_cd         => 'COMMITMENT'
               );
             --
         END IF; -- Fund checker Error
         --
    END LOOP;
    --
    CLOSE csr_pqh_gl_interface;
    --
  ELSE
    --
    -- insert into gl_interface
    --
    hr_utility.set_location('Inserting into GL_INTERFACE',200);
    --
    OPEN csr_pqh_gl_interface;
    LOOP
        --
        FETCH csr_pqh_gl_interface INTO l_period_name, l_accounting_date,
              l_code_combination_id, l_cost_allocation_keyflex_id, l_currency_code,
              l_amount_dr, l_amount_cr;
        EXIT WHEN csr_pqh_gl_interface%NOTFOUND;
        --
        INSERT INTO gl_interface
               (status,
                set_of_books_id,
                user_je_source_name,
                user_je_category_name,
                currency_code,
                date_created,
                created_by,
                actual_flag,
                accounting_date,
                period_name,
                code_combination_id,
                chart_of_accounts_id,
                entered_dr,
                entered_cr,
                encumbrance_type_id,
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
                'E',
                l_accounting_date,
                l_period_name,
                l_code_combination_id,
                g_chart_of_accounts_id,
                NVL(l_amount_dr,0),
                NVL(l_amount_cr,0),
                1000, -- encumbrance_type_id
                g_budget_version_id,
                l_cost_allocation_keyflex_id);
    --
    END LOOP;
    --
    CLOSE csr_pqh_gl_interface;
    --
  END IF;
  --
  hr_utility.set_location('Leaving:'||l_proc, 1000);
  --
EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END populate_gl_tables;
--
----------------------------------------------------------------------------------------------
PROCEDURE update_commitment_gl_status
IS
--
-- This procedure will update the gl_status of pqh_budget_versions,
-- pqh_budget_details and update the pqh_gl_interface table
-- We always update the TRANSFERED_TO_GL_FLAG = Y to indicate this is the
-- latest budget_version that is posted to GL
-- gl_status = POST or ERROR
--
-- local variables
--
 l_budget_details_rec           pqh_budget_details%ROWTYPE;
 l_count                        NUMBER;
--
 CURSOR csr_budget_details IS
 SELECT *
 FROM pqh_budget_details
 WHERE budget_version_id = g_budget_version_id
   AND NVL(commitment_gl_status,'X') <> 'ERROR'
  FOR UPDATE OF commitment_gl_status;
--
 CURSOR csr_budget_details_cnt IS
 SELECT COUNT(*)
 FROM pqh_budget_details
  WHERE budget_version_id = g_budget_version_id
   AND NVL(commitment_gl_status,'ERROR') = 'ERROR';
--
 l_proc                         varchar2(72) := g_package||'update_commitment_gl_status';
--
BEGIN
  --
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
  -- update pqh_budget_details
  --
  OPEN csr_budget_details;
  LOOP
      FETCH csr_budget_details INTO l_budget_details_rec;
      EXIT WHEN csr_budget_details%NOTFOUND;
      --
      UPDATE pqh_budget_details
         SET commitment_gl_status = 'POST'
       WHERE CURRENT OF csr_budget_details;
      --
  END LOOP;
  CLOSE csr_budget_details;
  --
  -- update pqh_budget_versions and the program out variable
  --
  OPEN csr_budget_details_cnt;
  FETCH csr_budget_details_cnt INTO l_count;
  CLOSE csr_budget_details_cnt;
  --
  IF NVL(l_count,0) = 0 THEN
     --
     -- no errors
     --
     UPDATE pqh_budget_versions
        SET commitment_gl_status = 'POST'
      WHERE budget_version_id = g_budget_version_id;
     --
     -- set the OUT variable to SUCCESS
     --
     g_status := 'SUCCESS';
     --
   ELSE
     --
     -- there were errors in details
     --
     UPDATE pqh_budget_versions
        SET commitment_gl_status = 'ERROR'
      WHERE budget_version_id = g_budget_version_id;
     --
     -- set the OUT variable to ERROR
     --
     g_status := 'ERROR';
     --
   END IF;
   --
   hr_utility.set_location('Budget Details Error Count : '||l_count, 100);
   --
   -- update the pqh_gl_interface table
   --
   UPDATE pqh_gl_interface
      SET posting_date = sysdate,
          status       = 'POST'
   WHERE budget_version_id = g_budget_version_id
     AND posting_type_cd = 'COMMITMENT'
     AND posting_date IS NULL
     AND status       IS NULL;
   --
   -- update the pqh_gl_interface table for last posted version
   --
   UPDATE pqh_gl_interface
   SET posting_date = sysdate,
       status       = 'POST'
   WHERE budget_version_id = NVL(g_last_posted_ver,0)
     AND posting_type_cd = 'COMMITMENT'
     AND posting_date IS NULL
     AND status       IS NULL;
   --
   hr_utility.set_location('Leaving:'||l_proc, 1000);
   --
EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END update_commitment_gl_status;
--
--------------------------------------------------------------------------------------------------
--
PROCEDURE set_bdt_log_context
(
  p_budget_detail_id        IN  pqh_budget_details.budget_detail_id%TYPE,
  p_log_context             OUT NOCOPY pqh_process_log.log_context%TYPE
) IS
--
--  This procedure will set the log_context at Budget detail level
--  We are processing only positions . So we need to set store the
--  position_name.
--
 l_budget_details_rec             pqh_budget_details%ROWTYPE;
 l_position_name                  hr_all_positions.name%TYPE;
 l_log_context pqh_process_log.log_context%TYPE;
--
 CURSOR csr_bdt_detail_rec IS
 SELECT *
 FROM pqh_budget_details
 WHERE budget_detail_id = p_budget_detail_id ;
--
 l_proc                           varchar2(72) := g_package||'set_bdt_log_context';
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  OPEN csr_bdt_detail_rec;
  FETCH csr_bdt_detail_rec INTO l_budget_details_rec;
  CLOSE csr_bdt_detail_rec;
  --
  l_position_name := HR_GENERAL.DECODE_POSITION (p_position_id => l_budget_details_rec.position_id);
  --
  hr_utility.set_location('Position :'||l_position_name, 8);
  --
  p_log_context := SUBSTR(l_position_name,1,255);
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
EXCEPTION
      WHEN OTHERS THEN
      p_log_context := l_log_context;
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        -- end log and halt the program here
        raise g_error_exception;
END set_bdt_log_context;
--
------------------------------------------------------------------------------------
PROCEDURE insert_pqh_gl_interface
(
 p_budget_detail_id            IN  pqh_gl_interface.budget_detail_id%TYPE,
 p_period_name                 IN  pqh_gl_interface.period_name%TYPE,
 p_accounting_date             IN  pqh_gl_interface.accounting_date%TYPE,
 p_code_combination_id         IN  pqh_gl_interface.code_combination_id%TYPE,
 p_cost_allocation_keyflex_id  IN  pqh_gl_interface.cost_allocation_keyflex_id%TYPE,
 p_amount                      IN  pqh_gl_interface.amount_dr%TYPE,
 p_currency_code               IN  pqh_gl_interface.currency_code%TYPE,
 p_posting_type_cd             IN pqh_gl_interface.posting_type_cd%TYPE
 ) IS
 --
 -- This procedure will insert record into pqh_gl_interface
 -- If the same UOM is repeated more then once then we would update the unposted txn.
 --
 CURSOR csr_pqh_gl_interface IS
 SELECT COUNT(*)
  FROM pqh_gl_interface
 WHERE budget_version_id    = g_budget_version_id
   AND budget_detail_id     = p_budget_detail_id
   AND period_name          = p_period_name
   AND code_combination_id  = p_code_combination_id
   AND currency_code        = p_currency_code
   AND posting_type_cd    = p_posting_type_cd
   AND NVL(adjustment_flag,'N') = 'N'
   AND status IS NULL
   AND posting_date IS NULL
   AND cost_allocation_keyflex_id is not null;
 --
 -- local variables
 --
 l_proc                         varchar2(72) := g_package||'insert_pqh_gl_interface';
 l_count                        number(9) := 0 ;
 --
BEGIN

 hr_utility.set_location('Entering: '||l_proc, 5);
 --
 -- check if its a repeat of that same UOM
 --
 OPEN csr_pqh_gl_interface;
 FETCH csr_pqh_gl_interface INTO l_count;
 CLOSE csr_pqh_gl_interface;
 --
 hr_utility.set_location('l_count in Insert pqh_gl_interface : '||l_count,10);
 --
 IF l_count <> 0 THEN
    --
    -- this is a repeat of UOM , so update the first one adding the new amount
    --
    UPDATE pqh_gl_interface
       SET AMOUNT_DR = NVL(AMOUNT_DR,0) + NVL(p_amount,0)
     WHERE budget_version_id    = g_budget_version_id
       AND budget_detail_id     = p_budget_detail_id
       AND period_name          = p_period_name
       AND code_combination_id  = p_code_combination_id
       AND currency_code        = p_currency_code
       AND posting_type_cd      = p_posting_type_cd
       AND NVL(adjustment_flag,'N') = 'N'
       AND status IS NULL
       AND posting_date IS NULL;

 ELSE
    --
 hr_utility.set_location('Currency code: '||p_currency_code, 5);
    -- insert this record
    --
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
       p_posting_type_cd
    );
   --
 END IF;  -- l_count <> 0 UOM repeated
 --
 hr_utility.set_location('Leaving:'||l_proc, 1000);
 --
EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END insert_pqh_gl_interface;
--
-- ----------------------------------------------------------------------------
PROCEDURE update_pqh_gl_interface
(
p_budget_detail_id           IN pqh_gl_interface.budget_detail_id%TYPE,
p_period_name                IN pqh_gl_interface.period_name%TYPE,
p_accounting_date            IN pqh_gl_interface.accounting_date%TYPE,
p_code_combination_id        IN pqh_gl_interface.code_combination_id%TYPE,
p_cost_allocation_keyflex_id IN pqh_gl_interface.cost_allocation_keyflex_id%TYPE,
p_amount                     IN pqh_gl_interface.amount_dr%TYPE,
p_currency_code              IN pqh_gl_interface.currency_code%TYPE,
p_posting_type_cd            IN pqh_gl_interface.posting_type_cd%TYPE
) IS
--
-- This procedure will update pqh_gl_interface and create a adjustment record
--
--
-- local variables
--
 l_proc                         varchar2(72) := g_package||'update_pqh_gl_interface';
--
 l_amount_diff                  pqh_gl_interface.amount_dr%TYPE :=0;
 l_amount_dr                    pqh_gl_interface.amount_dr%TYPE :=0;
 l_amount_cr                    pqh_gl_interface.amount_cr%TYPE :=0;
 l_pqh_gl_interface_rec         pqh_gl_interface%ROWTYPE;
--
 CURSOR csr_pqh_gl_interface IS
 SELECT *
  FROM pqh_gl_interface
 WHERE budget_version_id    = g_budget_version_id
   AND budget_detail_id     = p_budget_detail_id
   AND period_name          = p_period_name
   AND code_combination_id  = p_code_combination_id
   AND currency_code        = p_currency_code
   AND posting_type_cd      = p_posting_type_cd
   AND NVL(adjustment_flag,'N') = 'N'
   AND status IS NOT NULL
   AND posting_date IS NOT NULL
   AND cost_allocation_keyflex_id is not null
  FOR UPDATE of amount_dr;
--
BEGIN
  --
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
  OPEN csr_pqh_gl_interface;
  FETCH csr_pqh_gl_interface INTO l_pqh_gl_interface_rec;
  --
  l_amount_diff := NVL(p_amount,0) - NVL(l_pqh_gl_interface_rec.amount_dr,0);
  --
  IF l_amount_diff > 0 THEN
     --
     -- debit as new is more then old
     --
     l_amount_dr := l_amount_diff;
     --
  ELSE
     --
     -- credit as new is less then old
     --
     l_amount_cr := (-1)*l_amount_diff;
     --
  END IF;
  --
  -- update the pqh_gl_interface table
  --
  UPDATE pqh_gl_interface
  SET amount_dr = NVL(p_amount,0)
  WHERE CURRENT OF csr_pqh_gl_interface;
  --
  CLOSE csr_pqh_gl_interface;
  --
  -- create i.e insert a adjustment record ONLY if l_amount_diff <> 0
  --
  IF NVL(l_amount_diff,0) <> 0 THEN
     --
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
         p_posting_type_cd
     );
  --
  END IF; -- create i.e insert a adjustment record ONLY if l_amount_diff <> 0
  --
  hr_utility.set_location('Leaving:'||l_proc, 1000);
  --
EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END update_pqh_gl_interface;

-- ----------------------------------------------------------------------------
--
PROCEDURE populate_pqh_gl_interface
(
 p_budget_version_id    IN pqh_budget_versions.budget_version_id%TYPE,
 p_budget_detail_id     IN pqh_budget_details.budget_detail_id%TYPE,
 p_posting_type_cd      IN pqh_gl_interface.posting_type_cd%TYPE
)
IS
--
--  This procedure will update or insert into pqh_gl_interface if there was
--  no error --  for the current budget detail record i.e g_detail_error = N.
--  If g_detail_error = Y
--  then update the pqh_budget_details record with gl_status = ERROR.
--
 l_pqh_gl_interface_rec           pqh_gl_interface%ROWTYPE;
 l_uom1_count                     number;
 l_uom2_count                     number;
 l_uom3_count                     number;
--
 CURSOR csr_pqh_interface (p_period_name IN varchar2,
                           p_code_combination_id IN number,
                           p_currency_code  IN varchar2) IS
 SELECT COUNT(*)
 FROM pqh_gl_interface
 WHERE budget_version_id    = p_budget_version_id
   AND budget_detail_id     = p_budget_detail_id
   AND period_name          = p_period_name
   AND code_combination_id  = p_code_combination_id
   AND currency_code        = p_currency_code
   AND posting_type_cd      = p_posting_type_cd
   AND NVL(adjustment_flag,'N') = 'N'
   AND status IS NOT NULL
   AND posting_date IS NOT NULL
   AND cost_allocation_keyflex_id is not null;
--
-- local variables
--
 l_proc                     varchar2(72) := g_package||'populate_pqh_gl_interface';
--
BEGIN
  --
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
  If  g_detail_error = 'N' THEN
     --
     -- loop thru the array and get populate the pqh_gl_interface table
     --
     FOR i IN NVL(g_period_amt_tab.FIRST,0)..NVL(g_period_amt_tab.LAST,-1)
     LOOP
       --
       hr_utility.set_location('PERIOD '||g_period_amt_tab(i).period_name,6);
       IF g_period_amt_tab(i).code_combination_id is not NULL THEN
       -- for UOM1 i.e g_currency_code1
       --
       OPEN csr_pqh_interface
           (p_period_name         => g_period_amt_tab(i).period_name,
            p_code_combination_id => g_period_amt_tab(i).code_combination_id,
            p_currency_code       => g_currency_code1 );
       --
       FETCH csr_pqh_interface INTO l_uom1_count;
       --
       CLOSE  csr_pqh_interface;

       IF l_uom1_count <> 0 THEN
          --
       hr_utility.set_location('CURRENCY '||g_currency_code1,7);
          -- update pqh_gl_interface and create a adjustment txn
          --
          update_pqh_gl_interface
          (
          p_budget_detail_id          => p_budget_detail_id,
          p_period_name               => g_period_amt_tab(i).period_name,
          p_accounting_date           => g_period_amt_tab(i).accounting_date,
          p_code_combination_id       => g_period_amt_tab(i).code_combination_id,
          p_cost_allocation_keyflex_id=> g_period_amt_tab(i).cost_allocation_keyflex_id,
          p_amount                    => g_period_amt_tab(i).commitment1,
          p_posting_type_cd           => p_posting_type_cd,
          p_currency_code             => g_currency_code1
          );
       ELSE
          --
       hr_utility.set_location('CURRENCY '||g_currency_code1,7);
          -- insert into pqh_gl_interface
          --
          insert_pqh_gl_interface
          (
          p_budget_detail_id            => p_budget_detail_id,
          p_period_name                 => g_period_amt_tab(i).period_name,
          p_accounting_date             => g_period_amt_tab(i).accounting_date,
          p_code_combination_id         => g_period_amt_tab(i).code_combination_id,
          p_cost_allocation_keyflex_id  => g_period_amt_tab(i).cost_allocation_keyflex_id,
          p_amount                      => g_period_amt_tab(i).commitment1,
          p_posting_type_cd           => p_posting_type_cd,
          p_currency_code               => g_currency_code1
          );
       END IF;  -- l_uom1_count <> 0
       --
     If g_budget_uom2 IS NOT NULL then
       --
       -- for UOM2 i.e g_currency_code2
       --
       OPEN csr_pqh_interface
           (p_period_name => g_period_amt_tab(i).period_name,
            p_code_combination_id => g_period_amt_tab(i).code_combination_id,
            p_currency_code   => g_currency_code2 );
       --
       FETCH csr_pqh_interface INTO l_uom2_count;
       --
       CLOSE  csr_pqh_interface;

       IF l_uom2_count <> 0 THEN
          --
          -- update pqh_gl_interface and create a adjustment txn
          --
          update_pqh_gl_interface
          (
          p_budget_detail_id          => p_budget_detail_id,
          p_period_name               => g_period_amt_tab(i).period_name,
          p_accounting_date           => g_period_amt_tab(i).accounting_date,
          p_code_combination_id       => g_period_amt_tab(i).code_combination_id,
          p_cost_allocation_keyflex_id=> g_period_amt_tab(i).cost_allocation_keyflex_id,
          p_amount                    => g_period_amt_tab(i).commitment2,
          p_posting_type_cd           => p_posting_type_cd,
          p_currency_code             => g_currency_code2
          );
       ELSE
          --
          -- insert into pqh_gl_interface
          --
          insert_pqh_gl_interface
          (
          p_budget_detail_id            => p_budget_detail_id,
          p_period_name                 => g_period_amt_tab(i).period_name,
          p_accounting_date             => g_period_amt_tab(i).accounting_date,
          p_code_combination_id         => g_period_amt_tab(i).code_combination_id,
          p_cost_allocation_keyflex_id  => g_period_amt_tab(i).cost_allocation_keyflex_id,
          p_amount                      => g_period_amt_tab(i).commitment2,
          p_posting_type_cd           => p_posting_type_cd,
          p_currency_code               => g_currency_code2
          );
       END IF;  -- l_uom2_count <> 0
       --
     End if;
     --
     If g_budget_uom3 IS NOT NULL then
       --
       -- for UOM3 i.e g_currency_code3
       --
       OPEN csr_pqh_interface
           (p_period_name => g_period_amt_tab(i).period_name,
            p_code_combination_id => g_period_amt_tab(i).code_combination_id,
            p_currency_code   => g_currency_code3 );
       --
       FETCH csr_pqh_interface INTO l_uom3_count;
       --
       CLOSE  csr_pqh_interface;

       IF l_uom3_count <> 0 THEN
          --
          -- update pqh_gl_interface and create a adjustment txn
          --
          update_pqh_gl_interface
          (
          p_budget_detail_id          => p_budget_detail_id,
          p_period_name               => g_period_amt_tab(i).period_name,
          p_accounting_date           => g_period_amt_tab(i).accounting_date,
          p_code_combination_id       => g_period_amt_tab(i).code_combination_id,
          p_cost_allocation_keyflex_id=> g_period_amt_tab(i).cost_allocation_keyflex_id,
          p_amount                    => g_period_amt_tab(i).commitment3,
          p_posting_type_cd           => p_posting_type_cd,
          p_currency_code             => g_currency_code3
          );
       ELSE
          --
          -- insert into pqh_gl_interface
          --
          insert_pqh_gl_interface
          (
          p_budget_detail_id            => p_budget_detail_id,
          p_period_name                 => g_period_amt_tab(i).period_name,
          p_accounting_date             => g_period_amt_tab(i).accounting_date,
          p_code_combination_id         => g_period_amt_tab(i).code_combination_id,
          p_cost_allocation_keyflex_id  => g_period_amt_tab(i).cost_allocation_keyflex_id,
          p_amount                      => g_period_amt_tab(i).commitment3,
          p_posting_type_cd             => p_posting_type_cd,
          p_currency_code               => g_currency_code3
          );
       END IF;  -- l_uom3_count <> 0

     End if;
     --
     END IF;
     END LOOP; -- end of pl sql table
     --
     -- update pqh_budget_details reset status if previous run was ERROR
     --
     UPDATE pqh_budget_details
        SET commitment_gl_status = ''
      WHERE budget_detail_id = p_budget_detail_id;
     --
  ELSE  -- g_detail_error = Y i.e errors in budget details children
     hr_utility.set_location('******############',101);
     --
     -- update pqh_budget_details
     --
     UPDATE pqh_budget_details
        SET commitment_gl_status = 'ERROR'
      WHERE budget_detail_id = p_budget_detail_id;
     --
  END IF; -- g_detail_error = 'N'
  --
  hr_utility.set_location('Leaving:'||l_proc, 1000);
  --
EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END populate_pqh_gl_interface;



-- ----------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- This is the MAIN procedure which is called to post budget commitment
-- This would pick-up all the budget_detail under the budget_version_id
-- and try to post them to gl interface tables
-- If the program is run in validate mode i.e g_validate is TRUE then we
-- would just check for errors and log the errors
--
-- Additional parameter is added p_effecitve_date for the bug 2288274
--
PROCEDURE post_budget_commitment
(
 errbuf                         OUT NOCOPY  VARCHAR2,
 retcode                        OUT NOCOPY  VARCHAR2,
 p_effective_date		 IN  VARCHAR2  ,
 p_budget_version_id             IN  pqh_budget_versions.budget_version_id%TYPE,
 p_post_to_period_name		 IN  gl_period_statuses.period_name%TYPE DEFAULT NULL,
 p_validate                      IN  VARCHAR2    default 'N'
) IS
--
-- Declaring local variables
--
 l_budget_details_rec           pqh_budget_details%ROWTYPE;
 l_log_context                  pqh_process_log.log_context%TYPE;
 l_effective_dt		date;
--
 CURSOR csr_budget_detail_recs IS
 SELECT *
 FROM pqh_budget_details
 WHERE budget_version_id  = p_budget_version_id
 AND NVL(commitment_gl_status,'X') <> 'POST';
--
-- Cursor added to check the passed budget version is control budget.(Bug 2288274)
--

    Cursor csr_check_budget_is_ctrlbgt IS
    Select 1
    From   PQH_BUDGETS BGT,
           PQH_BUDGET_VERSIONS BVR
    Where  BGT.BUDGET_ID = BVR.BUDGET_ID
    And    BGT.POSITION_CONTROL_FLAG ='Y'
    And    l_effective_dt BETWEEN BGT.BUDGET_START_DATE AND BGT.BUDGET_END_DATE
    And    BVR.BUDGET_VERSION_ID = P_BUDGET_VERSION_ID;
--
 l_proc                         varchar2(72) := g_package||'post_budget_commitment';
 l_dummy			varchar2(3) := null;
--

BEGIN
  --
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
  l_effective_dt := fnd_date.canonical_to_date(p_effective_date);
  --
  IF NVL(p_validate,'N') = 'Y' THEN
    g_validate := true;
  ELSE
    g_validate := false;
  END IF;

  /* kmullapu : in procedure fetch_globals we throwing error if both transfer_to_grants ans transfer_to_gl
     are not set. If atlest one of them is set then it implies that Budget is controlled.
     So we dont require a control budget check.
  --
    -- CHECK THE BUDGET VERSION ID IS CONTROL BUDGET OR NOT.
    --
    OPEN csr_check_budget_is_ctrlbgt;
    FETCH csr_check_budget_is_ctrlbgt into l_dummy;

    If csr_check_budget_is_ctrlbgt%notfound then
    --
    -- Raise Error , budget_version is not a CONTROL BUDGET_VERSION.
    --
         Close csr_check_budget_is_ctrlbgt;
         FND_MESSAGE.SET_NAME('PQH','PQH_INVALID_CTRL_BDGT_VERSION');
         APP_EXCEPTION.RAISE_EXCEPTION;
    End if;

    Close csr_check_budget_is_ctrlbgt;

*/
  g_budget_version_id := p_budget_version_id;
  --
  -- populate the globals and start the process log
  --
  fetch_global_values(p_budget_version_id  => p_budget_version_id);
  --
  -- process all the budget details records whose commitment have not been
  -- posted. Also we currently generate commitment only for positions . So
  -- we can post only those budget detail records.
  --
  OPEN csr_budget_detail_recs;
  --
  LOOP
      --
      FETCH csr_budget_detail_recs INTO l_budget_details_rec;
      --
      EXIT WHEN csr_budget_detail_recs%NOTFOUND;
      --
      -- get log_context
      --
      set_bdt_log_context
      (
          p_budget_detail_id        => l_budget_details_rec.budget_detail_id,
          p_log_context             => l_log_context
      );
      --
      -- set the context
      --
      pqh_process_batch_log.set_context_level
      (
          p_txn_id                =>  l_budget_details_rec.budget_detail_id,
          p_txn_table_route_id    =>  g_table_route_id_bdt,
          p_level                 =>  1,
          p_log_context           =>  l_log_context
       );
      --
  hr_utility.set_location('--------------------------------------------', 5);
  hr_utility.set_location('POSITION : '||to_char(l_budget_details_rec.position_id), 5);
  hr_utility.set_location('--------------------------------------------', 5);
      -- for each budget detail
      --
      populate_period_commitment_tab
      (
           p_budget_version_id  => p_budget_version_id,
           p_budget_detail_id   => l_budget_details_rec.budget_detail_id,
           p_position_id        => l_budget_details_rec.position_id,
           p_organization_id    => l_budget_details_rec.organization_id,
           p_job_id		=> l_budget_details_rec.job_id,
           p_grade_id		=> l_budget_details_rec.grade_id,
           p_effective_date	=> p_effective_date
      );
      --
      -- get the period name and gl account
      --
      update_period_commitment_tab
      (
           p_budget_detail_id => l_budget_details_rec.budget_detail_id,
           p_post_to_period_name => p_post_to_period_name
      );
      --
      -- If the parameter is passed, consolidate the commitments into the passed period.
      --
      IF p_post_to_period_name IS NOT NULL THEN
        hr_utility.set_location('Consolidating into one period', 10);
        consolidate_commitment;
      END IF;

      --
      -- populate pqh_gl_interface table if there was no error and
      -- validate is false
      --
      IF NOT g_validate THEN
         --
         -- build the old_bdgt_dtls_tab
         --
         build_old_bdgt_dtls_tab
         (
               p_budget_detail_id  => l_budget_details_rec.budget_detail_id,
               p_posting_type_cd   => 'COMMITMENT'
         );
         --
         -- build the new bdgt_dtls tab and populate_pqh_gl_interface
         --
         populate_pqh_gl_interface
         (
               p_budget_version_id => l_budget_details_rec.budget_version_id,
               p_budget_detail_id => l_budget_details_rec.budget_detail_id,
               p_posting_type_cd   => 'COMMITMENT'
         );

         populate_pqh_gms_interface
         (
               p_budget_version_id => l_budget_details_rec.budget_version_id,
               p_budget_detail_id => l_budget_details_rec.budget_detail_id,
               p_posting_type_cd   => 'COMMITMENT'
         );
         --
         -- compare the old and new tables
         --
         compare_old_bdgt_dtls_tab;
         --
         -- reverse the old bdgt_dtls recs not in new
         --
         reverse_old_bdgt_dtls_tab
         (
                p_budget_detail_id => l_budget_details_rec.budget_detail_id,
                p_posting_type_cd  => 'COMMITMENT'
         );
         --
         --
      END IF;  -- if not in validate mode
      --
  END LOOP;
  --
  CLOSE csr_budget_detail_recs;
  --
  /**  Check this out.
  --
  -- At any point of time , only ONE budget version can be posted to GL.
  -- So if this version is different from the previously posted version,
  -- we would reverse the previously posted version.
  --
  IF NOT p_validate THEN
     --
     reverse_prev_posted_version;
     --
  END IF;
  --
  **/
  --
  -- insert into gl_interface or gl_bc_packets table if not in validate mode
  --
  IF NOT g_validate THEN
     --
     populate_gl_tables;
     if g_transfer_to_grants_flag = 'Y' then
        populate_gms_tables;
     end if;
     --
  END IF;
  --
  -- update gl_status of pqh_budget_versions and pqh_budget_details
  -- update posting_date and status of pqh_gl_interface
  -- update the global g_status with the program status
  --
  IF NOT g_validate THEN
     --
     update_commitment_gl_status;
     --
   END IF;
  --
  -- end the error log process and update the global g_status with the program status
  --
  pqh_gl_posting.end_commitment_log(p_status  =>  g_status);
  --
  -- commit work if run in actual mode only i.e g_validate is false
  --
  IF NOT g_validate THEN
     --
     commit;
     --
  END IF;
  --
  --
  hr_utility.set_location('Leaving:'||l_proc, 1000);
  --
EXCEPTION
  WHEN g_error_exception THEN
     hr_utility.set_location('Aborting : '||l_proc, 1000);
     -- ROLLBACK ;
     pqh_gl_posting.end_commitment_log(p_status  =>  g_status);
     --
  WHEN OTHERS THEN
      ROLLBACK ;
      hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
      hr_utility.set_message_token('ROUTINE', l_proc);
      hr_utility.set_message_token('REASON', SQLERRM);
      hr_utility.raise_error;
END post_budget_commitment;
-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
PROCEDURE insert_pqh_gms_interface
(
 p_budget_detail_id  IN pqh_gl_interface.budget_detail_id%TYPE,
 p_period_name       IN varchar2,
 p_project_id        IN pqh_gl_interface.project_id%TYPE,
 p_task_id	     IN pqh_gl_interface.task_id%TYPE,
 p_award_id	     IN pqh_gl_interface.award_id%TYPE,
 p_expenditure_type  IN pqh_gl_interface.expenditure_type%TYPE,
 p_organization_id   IN pqh_gl_interface.organization_id%TYPE,
 p_amount            IN pqh_gl_interface.amount_dr%TYPE,
 p_posting_type_cd   IN pqh_gl_interface.posting_type_cd%TYPE
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
   AND posting_type_cd          = p_posting_type_cd
   AND project_id               = p_project_id
   AND task_id	   	        = p_task_id
   AND award_id	   	        = p_award_id
   AND expenditure_type	        = p_expenditure_type
   AND organization_id 	        = p_organization_id
   AND NVL(adjustment_flag,'N') = 'N'
   AND status IS NULL
   AND posting_date IS NULL
   AND cost_allocation_keyflex_id is null;

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
       AND posting_type_cd          = p_posting_type_cd
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
       p_posting_type_cd
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
 p_amount            IN pqh_gl_interface.amount_dr%TYPE,
 p_posting_type_cd   IN pqh_gl_interface.posting_type_cd%TYPE
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
   AND posting_type_cd          = p_posting_type_cd
   AND project_id               = p_project_id
   AND task_id	   	        = p_task_id
   AND award_id	   	        = p_award_id
   AND expenditure_type	        = p_expenditure_type
   AND organization_id 	        = p_organization_id
   AND NVL(adjustment_flag,'N') = 'N'
   AND status IS NOT NULL
   AND posting_date IS NOT NULL
   AND cost_allocation_keyflex_id is  null
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
         p_posting_type_cd
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

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

PROCEDURE populate_pqh_gms_interface
(
 p_budget_version_id    IN pqh_budget_versions.budget_version_id%TYPE,
 p_budget_detail_id     IN pqh_budget_details.budget_detail_id%TYPE,
 p_posting_type_cd      IN pqh_gl_interface.posting_type_cd%TYPE
)
IS
/*
  This procedure will update or insert GMS records into pqh_gl_interface if there was no error for
  the current budget detail record i.e g_detail_error = N
  if g_detail_error = Y then update the pqh_budget_details record with gl_status = ERROR

  Also it will Deduct a similar amount from Budget Commitments.
  If a Bduget Commitment for that Detail/Period is not available error is thrown and program is
  aborted
*/
--
-- local variables
--
 l_proc                           varchar2(72) := g_package||'.populate_pqh_gms_interface';
 l_pqh_gl_interface_rec           pqh_gl_interface%ROWTYPE;
 l_uom_count                      number;
 l_amount                         number;
 l_amount_dr                      number;
 l_amount_cr                      number;
 l_uom1                           varchar2(80);
 l_uom2                           varchar2(80);
 l_uom3                           varchar2(80);


 Cursor csr_pqh_gms_interface ( p_period_name      IN varchar2,
                                p_project_id	   IN  NUMBER,
                                p_task_id	   IN  NUMBER,
                                p_award_id	   IN  NUMBER,
                                p_expenditure_type IN  varchar2,
                                p_organization_id  IN  NUMBER,
                                p_posting_type_cd  IN  VARCHAR2) IS
 Select *
 From pqh_gl_interface
 Where budget_version_id  = p_budget_version_id
   AND budget_detail_id   = p_budget_detail_id
   AND period_name        = p_period_name
   AND posting_type_cd    = p_posting_type_cd
   AND project_id	  = p_project_id
   AND task_id		  = p_task_id
   AND award_id		  = p_award_id
   AND expenditure_type	  = p_expenditure_type
   AND organization_id	  = p_organization_id
   AND NVL(adjustment_flag,'N') = 'N'
   AND cost_allocation_keyflex_id is  null
   AND nvl(status,'X')='POST'
   AND posting_date IS NOT NULL
   AND cost_allocation_keyflex_id is null
   FOR UPDATE of amount_dr;


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
                                         l_amount :=g_period_amt_tab(i).commitment1;
              ELSIF NVL(l_uom2,'X')='Money' THEN
                                         l_amount :=g_period_amt_tab(i).commitment2;
              ELSIF NVL(l_uom3,'X')='Money' THEN
                                  l_amount :=g_period_amt_tab(i).commitment3;
       END IF;
       OPEN csr_pqh_gms_interface(p_period_name      => g_period_amt_tab(i).period_name,
                                  p_project_id       => g_period_amt_tab(i).project_id,
                                  p_task_id	     => g_period_amt_tab(i).task_id,
                                  p_award_id	     => g_period_amt_tab(i).award_id,
                                  p_expenditure_type => g_period_amt_tab(i).expenditure_type,
                                  p_organization_id  => g_period_amt_tab(i).organization_id ,
                                  p_posting_type_cd  =>'COMMITMENT');
       FETCH csr_pqh_gms_interface INTO l_pqh_gl_interface_rec;
       IF csr_pqh_gms_interface%FOUND THEN
                l_uom_count :=1;
       ELSE     l_uom_count :=0;
       END IF;
       CLOSE csr_pqh_gms_interface;

       OPEN csr_pqh_gms_interface(p_period_name      => g_period_amt_tab(i).period_name,
                                  p_project_id       => g_period_amt_tab(i).project_id,
                                  p_task_id	     => g_period_amt_tab(i).task_id,
                                  p_award_id	     => g_period_amt_tab(i).award_id,
                                  p_expenditure_type => g_period_amt_tab(i).expenditure_type,
                                  p_organization_id  => g_period_amt_tab(i).organization_id ,
                                  p_posting_type_cd  => 'BUDGET');
      FETCH csr_pqh_gms_interface INTO l_pqh_gl_interface_rec;
      IF csr_pqh_gms_interface%FOUND THEN
         CLOSE csr_pqh_gms_interface;
         hr_utility.set_message(8302, 'PQH_BUDGET_VERSION_NOT_POSTED');
         hr_utility.raise_error;
      END IF;
      --
      --We cannot Xfer a commitment greater than Budget amount posted for that period/Detail
      --
      IF(nvl(l_amount,-1) > 0 and l_amount < l_pqh_gl_interface_rec.amount_dr)
      THEN
         l_amount := l_pqh_gl_interface_rec.amount_dr;
      END IF;

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
               p_amount            => l_amount,
               p_posting_type_cd   => p_posting_type_cd
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
                      p_amount            => l_amount,
                      p_posting_type_cd   => p_posting_type_cd
              );
       END IF;  -- l_uom1_count <> 0

       --
       -- Deduct Commitment Amount posted, from Budget Commitment for that Detail/Period and create
       -- adjustment transaction for BUDGET
       --
       IF NVL(l_amount,0) <>0  THEN
       UPDATE pqh_gl_interface
              SET amount_dr = amount_dr - l_amount
       WHERE CURRENT OF csr_pqh_gms_interface;
       l_amount_dr :=0;
       l_amount_cr :=0;
       IF ( l_amount > 0) THEN
             l_amount_dr := l_amount;
       ELSE  l_amount_cr := -1 * l_amount;
       END IF;


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
                g_period_amt_tab(i).period_name,
                g_period_amt_tab(i).project_id,
       	        g_period_amt_tab(i).task_id,
       	        g_period_amt_tab(i).award_id,
       	        g_period_amt_tab(i).expenditure_type,
                g_period_amt_tab(i).organization_id,
                l_amount_dr,
                l_amount_cr,
                g_bgt_currency_code,
                null,
                'Y',
                null,
                'BUDGET'
              );

     END IF; -- create i.e insert a adjustment record ONLY if l_amount_diff <> 0

      END IF; -- Insert only GMS records
     END LOOP; -- end of pl sql table

      -- update pqh_budget_details reset status if previous run was ERROR
      UPDATE pqh_budget_details
         SET commitment_gl_status  = ''
       WHERE budget_detail_id = p_budget_detail_id;



  ELSE  -- g_detail_error = Y i.e errors in budget details children

      -- update pqh_budget_details
      UPDATE pqh_budget_details
         SET commitment_gl_status = 'ERROR'
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

 PRAGMA                       AUTONOMOUS_TRANSACTION;

BEGIN
   hr_utility.set_location('Entering: '||l_proc, 5);

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
         entered_dr,
         entered_cr,
         accounted_dr,
         accounted_cr,
         encumbrance_type_id,
         reference1,
         reference2 )
    VALUES
      (p_packet_id,
       g_set_of_books_id,
       g_user_je_source_name,
       g_user_je_category_name,
       p_code_combination_id,
       'E',
       p_period_name,
       p_period_year,
       p_period_num,
       p_quarter_num,
       p_currency_code,
       'P',
       sysdate,
       8302,
       p_entered_dr,
       p_entered_cr,
       p_accounted_dr,
       p_accounted_cr,
       1000, -- encumbrance_type_id
       g_budget_version_id,
       p_cost_allocation_keyflex_id );

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

/**************************************************************/

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
                                  	    'GMSEPQHC ',
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

/**************************************************************/

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
WHERE  transaction_source = 'GMSEPQHC '
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
 WHERE transaction_source = 'GMSEPQHC '
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
       p_message_text => pqh_gl_posting.get_gms_rejection_msg(reject_rec.rejection_code));

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

/**************************************************************/

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
    And transaction_source = 'GMSEPQHC ';

 hr_utility.set_location('Deleted pa_transaction_interface_all:',20);

 DELETE gms_transaction_interface_all
 WHERE  batch_name = p_gms_batch_name
    And transaction_source = 'GMSEPQHC ';

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

/**************************************************************/

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
Where  transaction_source = 'GMSEPQHC ';

Cursor csr_pqh_gms_interface IS
Select period_name,project_id,award_id,task_id,
       expenditure_type,organization_id,
       currency_code,
       SUM(NVL(amount_dr,0))  amount_dr,
       SUM(NVL(amount_cr,0))  amount_cr
From   pqh_gl_interface
Where  budget_version_id        = g_budget_version_id
   AND posting_type_cd          = 'COMMITMENT'
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
     l_value	:= 'Transaction source ='||'GMSEPQHC ';
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
   g_gms_import_tab(cnt).TRANSACTION_SOURCE          :='GMSEPQHC ';
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
         pqh_gl_posting.set_bpr_log_context
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

End;

/
