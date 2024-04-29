--------------------------------------------------------
--  DDL for Package Body PQH_APPLY_BUDGET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_APPLY_BUDGET" AS
/* $Header: pqappbdg.pkb 115.38 2004/02/05 12:40:56 rthiagar ship $ */
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_apply_budget.';  -- Global package name
g_budget_version_id       pqh_budget_versions.budget_version_id%TYPE;
g_worksheet_mode_cd       pqh_worksheets.worksheet_mode_cd%TYPE;
g_budget_id               pqh_worksheets.budget_id%TYPE;

g_budgeted_entity_cd       pqh_budgets.budgeted_entity_cd%TYPE;
g_table_route_id_wks       NUMBER;
g_table_route_id_wdt       NUMBER;
g_table_route_id_wpr       NUMBER;
g_table_route_id_wst       NUMBER;
g_table_route_id_wel       NUMBER;
g_table_route_id_wfs       NUMBER;
g_transaction_category_id  pqh_transaction_categories.transaction_category_id%TYPE;
g_worksheet_name           pqh_worksheets.worksheet_name%TYPE;
g_worksheet_id             pqh_worksheets.worksheet_id%TYPE;
g_error_exception          exception;
g_curr_wks_dtl_level       NUMBER;
g_root_wks_dtl_id          NUMBER;

--
--
/*--------------------------------------------------------------------------------------------------------------

    Main Procedure
--------------------------------------------------------------------------------------------------------------*/
PROCEDURE updt_wkd_status
(
 p_worksheet_id         IN    pqh_worksheets.worksheet_id%TYPE,
 p_status               IN    pqh_worksheets.transaction_status%TYPE
)  IS
/*

*/

 l_proc                            varchar2(72) := g_package||'updt_wkd_status';


CURSOR csr_wkd IS
SELECT *
FROM pqh_worksheet_details
WHERE worksheet_id = p_worksheet_id
and parent_worksheet_detail_id is null;

l_wkd_rec                           pqh_worksheet_details%ROWTYPE;
l_wkd_ovn                           pqh_worksheet_details.object_version_number%TYPE;
BEGIN
   hr_utility.set_location('Entering:'||l_proc, 5);
   open csr_wkd;
   fetch csr_wkd into l_wkd_rec;
   CLOSE csr_wkd;
      l_wkd_ovn   :=  l_wkd_rec.object_version_number;
      pqh_worksheet_details_api.update_worksheet_detail(
      p_validate                       =>  false
      ,p_worksheet_detail_id            =>  l_wkd_rec.worksheet_detail_id
      ,p_object_version_number          =>  l_wkd_ovn
      ,p_status                         =>  p_status
      ,p_effective_date                 =>  sysdate
      );
   hr_utility.set_location('Leaving:'||l_proc, 1000);
EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_location('error:'||substr(sqlerrm,1,55), 1000);
        hr_utility.set_location('error:'||substr(sqlerrm,56,55), 1000);
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END updt_wkd_status;

--------------------------------------------------------------------------------------------------------------
PROCEDURE apply_budget
(
 p_worksheet_id                  IN   pqh_worksheets.worksheet_id%TYPE,
 p_budget_version_id             OUT NOCOPY  pqh_budget_versions.budget_version_id%TYPE
)
IS
-- local variables and cursors

CURSOR pqh_worksheets_cur(p_worksheet_id  IN pqh_worksheets.worksheet_id%TYPE) IS
 SELECT *
 FROM pqh_worksheets
 WHERE worksheet_id = p_worksheet_id;

l_proc                       varchar2(72) := g_package||'apply_budget';
l_pqh_worksheets_rec         pqh_worksheets%ROWTYPE;
l_log_context                    pqh_process_log.log_context%TYPE;

BEGIN

  hr_utility.set_location('Entering: '||l_proc, 5);

  -- check the mode for the current worksheet is valid
  -- and populate the global mode_cd variable
  -- check that the worksheet has  not been already applied
   check_valid_mode ( p_worksheet_id => p_worksheet_id);

  -- open pqh_worksheets_cur
  OPEN pqh_worksheets_cur (p_worksheet_id  => p_worksheet_id);
    FETCH pqh_worksheets_cur INTO l_pqh_worksheets_rec;
  CLOSE pqh_worksheets_cur;

  -- populate the global variable
   g_budget_id  := l_pqh_worksheets_rec.budget_id;

  -- populate other global variables
   populate_globals
   (
    p_worksheet_id => p_worksheet_id
   );


   hr_utility.set_location('Worksheet Mode : '||g_worksheet_mode_cd, 6);
   hr_utility.set_location('Budget ID  : '||g_budget_id, 7);

     -- Start the Log Process
     pqh_process_batch_log.start_log
     (
      p_batch_id       => g_worksheet_id,
      p_module_cd      => 'APPLY_BUDGET',
      p_log_context    => g_worksheet_name
     );

    -- set wks id as the top most context level
    -- set the context before inserting error
        pqh_process_batch_log.set_context_level
        (
          p_txn_id                =>  g_worksheet_id,
          p_txn_table_route_id    =>  g_table_route_id_wks,
          p_level                 =>  1,
          p_log_context           =>  g_worksheet_name
        );


  /*
    Depending on the worksheet_mode_cd call the corresponding procedure
  */
  IF   l_pqh_worksheets_rec.worksheet_mode_cd = 'S' THEN
    -- first version no carry forwardi.e NEW
    -- OR new version with no carry forward i.e NEW_OVERRIDE
    apply_new_budget
    (
     p_worksheet_id => p_worksheet_id,
     p_mode         => 'I'
    );
  ELSIF l_pqh_worksheets_rec.worksheet_mode_cd = 'W' THEN
    -- new version with no carry forward i.e NEW_OVERRIDE
    -- as of 02/16/2000 this mode is discontinued
    apply_new_budget
    (
     p_worksheet_id => p_worksheet_id,
     p_mode         => 'I'
    );
  ELSIF l_pqh_worksheets_rec.worksheet_mode_cd = 'N' THEN
    -- edit existing version and create a new version
    -- with carry forward i.e EDIT_NEW no carry forward as of 06/09/2000
     edit_create_new_budget
    (
     p_worksheet_id => p_worksheet_id
    );
  ELSIF l_pqh_worksheets_rec.worksheet_mode_cd = 'O' THEN
    -- edit existing version and update the same version
    -- with carry forward i.e EDIT_UPDATE
    edit_update_budget
    (
     p_worksheet_id => p_worksheet_id
    );

    -- update the pqh_budget_version record with correct unit1, 2, 3 values
      comp_bgt_ver_unit_val
      (
       p_budget_version_id     =>  g_budget_version_id
      );

  ELSE
    -- invalid mode code
    hr_utility.set_location('Invalid Worksheet Mode : '||g_worksheet_mode_cd, 7);
    hr_utility.set_message(8302,'PQH_INVALID_WORKSHEET_MODE_CD');
    hr_utility.raise_error;
  END IF;

   -- update the worksheet status flag to 'APPLIED
   -- and updt budget_version_id

   updt_wks_status
   (
     p_worksheet_id      =>   p_worksheet_id ,
     p_status            =>   'APPLIED'
   );
    hr_utility.set_location('worksheet updated with Applied'||l_proc, 8);

   updt_wkd_status
   (
     p_worksheet_id      =>   p_worksheet_id ,
     p_status            =>   'APPLIED'
   );
    hr_utility.set_location('wkd updated with Applied'||l_proc, 9);

   -- update the status in pqh_budgets to FROZEN


   updt_budget_status
   (
     p_budget_id           =>    g_budget_id
   );


   -- Populate the OUT variable p_budget_version_id
     p_budget_version_id := g_budget_version_id;

   -- call the end log and stop
     pqh_process_batch_log.end_log;

   -- commit the work;
   --  commit;

  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
  WHEN g_error_exception THEN
    -- call the end log and stop
     pqh_process_batch_log.end_log;
    -- call the wf error
     hr_utility.set_location('txn_cat :'||g_transaction_category_id||l_proc, 10);
     hr_utility.set_location('txn_id :'||g_root_wks_dtl_id||l_proc, 10);
     pqh_wf.set_apply_error(p_transaction_category_id => g_transaction_category_id,
                            p_transaction_id          => g_root_wks_dtl_id,
                            p_apply_error_mesg        => SQLERRM,
                            p_apply_error_num         => SQLCODE);
  WHEN others THEN
  p_budget_version_id := null;
    raise;
END apply_budget;


--------------------------------------------------------------------------------------------------------------
PROCEDURE apply_new_budget
(
 p_worksheet_id IN pqh_worksheets.worksheet_id%TYPE,
 p_mode         IN varchar2
)
IS
-- local variables and cursors

CURSOR pqh_worksheets_cur(p_worksheet_id  IN pqh_worksheets.worksheet_id%TYPE) IS
 SELECT *
 FROM pqh_worksheets
 WHERE worksheet_id = p_worksheet_id;

CURSOR pqh_worksheet_details_cur (p_worksheet_id  IN pqh_worksheets.worksheet_id%TYPE) IS
 SELECT *
 FROM  pqh_worksheet_details
 WHERE worksheet_id = p_worksheet_id
   AND NVL(action_cd,'X') = 'B' ;

CURSOR pqh_worksheet_periods_cur (p_worksheet_detail_id  IN pqh_worksheet_details.worksheet_detail_id%TYPE) IS
 SELECT *
 FROM  pqh_worksheet_periods
 WHERE  worksheet_detail_id = p_worksheet_detail_id;

CURSOR pqh_worksheet_budget_sets_cur (p_worksheet_period_id  IN  pqh_worksheet_periods.worksheet_period_id%TYPE) IS
 SELECT *
 FROM  pqh_worksheet_budget_sets
 WHERE worksheet_period_id = p_worksheet_period_id;

CURSOR pqh_worksheet_bdgt_elmnts_cur (p_worksheet_budget_set_id  IN  pqh_worksheet_budget_sets.worksheet_budget_set_id%TYPE) IS
 SELECT *
 FROM  pqh_worksheet_bdgt_elmnts
 WHERE worksheet_budget_set_id = p_worksheet_budget_set_id;

CURSOR pqh_worksheet_fund_srcs_cur (p_worksheet_bdgt_elmnt_id  IN  pqh_worksheet_bdgt_elmnts.worksheet_bdgt_elmnt_id%TYPE) IS
 SELECT *
 FROM  pqh_worksheet_fund_srcs
 WHERE worksheet_bdgt_elmnt_id = p_worksheet_bdgt_elmnt_id;

CURSOR current_version_cur (p_worksheet_id  IN pqh_worksheets.worksheet_id%TYPE ) IS
 SELECT bvr.budget_version_id
 FROM pqh_budget_versions bvr, pqh_worksheets wks
 WHERE bvr.budget_id = wks.budget_id
   AND bvr.version_number = wks.version_number
   AND wks.worksheet_id = p_worksheet_id;

l_proc                           varchar2(72) := g_package||'apply_new_budget';
l_pqh_worksheets_rec             pqh_worksheets%ROWTYPE;
l_budget_version_id              pqh_budget_versions.budget_version_id%TYPE;
l_pqh_worksheet_details_rec      pqh_worksheet_details%ROWTYPE;
l_budget_detail_id               pqh_budget_details.budget_detail_id%TYPE;
l_pqh_worksheet_periods_rec      pqh_worksheet_periods%ROWTYPE;
l_budget_period_id               pqh_budget_periods.budget_period_id%TYPE;
l_pqh_worksheet_budget_set_rec   pqh_worksheet_budget_sets%ROWTYPE;
l_budget_set_id                  pqh_budget_sets.budget_set_id%TYPE;
l_pqh_worksheet_bdgt_elmnt_rec   pqh_worksheet_bdgt_elmnts%ROWTYPE;
l_budget_element_id              pqh_budget_elements.budget_element_id%TYPE;
l_pqh_worksheet_fund_srcs_rec     pqh_worksheet_fund_srcs%ROWTYPE;
l_budget_fund_src_id             pqh_budget_fund_srcs.budget_fund_src_id%TYPE;
l_curr_budget_version_id         pqh_budget_versions.budget_version_id%TYPE;
l_log_context                    pqh_process_log.log_context%TYPE;

BEGIN

  hr_utility.set_location('Entering: '||l_proc, 5);
   -- open the pqh_worksheets_cur
  OPEN pqh_worksheets_cur(p_worksheet_id  => p_worksheet_id);
   LOOP  -- loop 1
    FETCH pqh_worksheets_cur INTO l_pqh_worksheets_rec;
    EXIT WHEN pqh_worksheets_cur%NOTFOUND;
      IF p_mode = 'I' THEN
        --  create records in pqh_budget_versions
         populate_budget_versions
         (
           p_worksheets_rec      => l_pqh_worksheets_rec,
           p_budget_id           => l_pqh_worksheets_rec.budget_id,
           p_worksheet_mode_cd   => g_worksheet_mode_cd,
           p_budget_version_id_o => l_budget_version_id
          );

          -- populate the global variable with the version_id
           g_budget_version_id  := l_budget_version_id;

       ELSE
         -- no new record in the pqh_budget_versions as this is update mode
         -- get the current version_id
           hr_utility.set_location('Called Apply Budget in Update Mode: '||p_mode, 6);
           OPEN current_version_cur(p_worksheet_id  => p_worksheet_id);
             FETCH current_version_cur INTO l_curr_budget_version_id;
           CLOSE current_version_cur;

           -- populate the global variable with the version_id
           g_budget_version_id  := l_curr_budget_version_id;

       END IF;

       hr_utility.set_location('Budget Version: '||g_budget_version_id, 6);


    -- open pqh_worksheet_details_cur
    OPEN pqh_worksheet_details_cur(p_worksheet_id  => l_pqh_worksheets_rec.worksheet_id );
     LOOP  -- loop 2
      FETCH pqh_worksheet_details_cur INTO l_pqh_worksheet_details_rec;
      EXIT WHEN pqh_worksheet_details_cur%NOTFOUND;

        -- get log_context
        set_wks_log_context
        (
         p_worksheet_detail_id     => l_pqh_worksheet_details_rec.worksheet_detail_id,
         p_log_context             => l_log_context
        );

        -- set the context
         pqh_process_batch_log.set_context_level
         (
          p_txn_id                =>  l_pqh_worksheet_details_rec.worksheet_detail_id,
          p_txn_table_route_id    =>  g_table_route_id_wdt,
          p_level                 =>  2,
          p_log_context           =>  l_log_context
         );

      -- create records in pqh_budget_details
      populate_budget_details
      (
       p_worksheet_details_rec      => l_pqh_worksheet_details_rec,
       p_budget_version_id          => g_budget_version_id,
       p_worksheet_id               => l_pqh_worksheets_rec.worksheet_id,
       p_worksheet_mode_cd          => g_worksheet_mode_cd,
       p_budget_detail_id_o         => l_budget_detail_id
      );

      -- open pqh_worksheet_periods_cur
      OPEN pqh_worksheet_periods_cur(p_worksheet_detail_id  => l_pqh_worksheet_details_rec.worksheet_detail_id);
       LOOP -- loop 3
        FETCH pqh_worksheet_periods_cur INTO l_pqh_worksheet_periods_rec;
        EXIT WHEN pqh_worksheet_periods_cur%NOTFOUND;

          -- get log_context
             set_wpr_log_context
             (
              p_worksheet_period_id     => l_pqh_worksheet_periods_rec.worksheet_period_id,
              p_log_context             => l_log_context
             );

             -- set the context
              pqh_process_batch_log.set_context_level
              (
               p_txn_id                =>  l_pqh_worksheet_periods_rec.worksheet_period_id,
               p_txn_table_route_id    =>  g_table_route_id_wpr,
               p_level                 =>  3,
               p_log_context           =>  l_log_context
              );


        -- create records in pqh_budget_periods
        populate_budget_periods
        (
         p_worksheet_periods_rec      => l_pqh_worksheet_periods_rec,
         p_budget_detail_id           => l_budget_detail_id,
         p_budget_period_id_o         => l_budget_period_id
        );

       -- open pqh_worksheet_budget_sets_cur
        OPEN pqh_worksheet_budget_sets_cur(p_worksheet_period_id  => l_pqh_worksheet_periods_rec.worksheet_period_id);
         LOOP  -- loop 4
          FETCH pqh_worksheet_budget_sets_cur INTO l_pqh_worksheet_budget_set_rec;
          EXIT WHEN pqh_worksheet_budget_sets_cur%NOTFOUND;

            -- get log_context
              set_wst_log_context
              (
               p_worksheet_budget_set_id     => l_pqh_worksheet_budget_set_rec.worksheet_budget_set_id,
               p_log_context                 => l_log_context
              );

              -- set the context
               pqh_process_batch_log.set_context_level
               (
                p_txn_id                =>  l_pqh_worksheet_budget_set_rec.worksheet_budget_set_id,
                p_txn_table_route_id    =>  g_table_route_id_wst,
                p_level                 =>  4,
                p_log_context           =>  l_log_context
               );


          -- create records in pqh_budget_sets
          populate_budget_sets
         (
          p_worksheet_budget_sets_rec  => l_pqh_worksheet_budget_set_rec,
          p_budget_period_id           => l_budget_period_id,
          p_budget_set_id_o            => l_budget_set_id
         );

          -- open pqh_worksheet_bdgt_elmnts_cur
          OPEN pqh_worksheet_bdgt_elmnts_cur(p_worksheet_budget_set_id  => l_pqh_worksheet_budget_set_rec.worksheet_budget_set_id);
           LOOP  -- loop 5
            FETCH pqh_worksheet_bdgt_elmnts_cur INTO l_pqh_worksheet_bdgt_elmnt_rec;
            EXIT WHEN pqh_worksheet_bdgt_elmnts_cur%NOTFOUND;

              -- get log_context
               set_wel_log_context
               (
                p_worksheet_bdgt_elmnt_id     => l_pqh_worksheet_bdgt_elmnt_rec.worksheet_bdgt_elmnt_id,
                p_log_context                 => l_log_context
               );

              -- set the context
               pqh_process_batch_log.set_context_level
               (
                p_txn_id                =>  l_pqh_worksheet_bdgt_elmnt_rec.worksheet_bdgt_elmnt_id,
                p_txn_table_route_id    =>  g_table_route_id_wel,
                p_level                 =>  5,
                p_log_context           =>  l_log_context
               );

            -- create records in pqh_budget_elements
            populate_budget_elements
            (
             p_worksheet_bdgt_elmnts_rec  => l_pqh_worksheet_bdgt_elmnt_rec,
             p_budget_set_id              => l_budget_set_id,
             p_budget_element_id_o        => l_budget_element_id
            );

            -- open pqh_worksheet_fund_srcs_cur
             OPEN pqh_worksheet_fund_srcs_cur(p_worksheet_bdgt_elmnt_id  => l_pqh_worksheet_bdgt_elmnt_rec.worksheet_bdgt_elmnt_id);
              LOOP -- loop 6
               FETCH pqh_worksheet_fund_srcs_cur INTO l_pqh_worksheet_fund_srcs_rec;
               EXIT WHEN pqh_worksheet_fund_srcs_cur%NOTFOUND;

                 -- get log_context
                  set_wfs_log_context
                  (
                   p_worksheet_fund_src_id       => l_pqh_worksheet_fund_srcs_rec.worksheet_fund_src_id,
                   p_log_context                 => l_log_context
                  );

                  -- set the context
                   pqh_process_batch_log.set_context_level
                   (
                    p_txn_id                =>  l_pqh_worksheet_fund_srcs_rec.worksheet_fund_src_id,
                    p_txn_table_route_id    =>  g_table_route_id_wfs,
                    p_level                 =>  6,
                    p_log_context           =>  l_log_context
                   );

               -- create records in pah_budget_fund_srcs
               populate_budget_fund_srcs
               (
                p_worksheet_fund_srcs_rec    => l_pqh_worksheet_fund_srcs_rec,
                p_budget_element_id          => l_budget_element_id,
                p_budget_fund_src_id_o       => l_budget_fund_src_id
               );


              END LOOP; -- loop 6
             CLOSE pqh_worksheet_fund_srcs_cur;

           END LOOP; -- loop 5
          CLOSE pqh_worksheet_bdgt_elmnts_cur;

         END LOOP;  -- loop 4
        CLOSE pqh_worksheet_budget_sets_cur;

       END LOOP; -- loop 3
      CLOSE pqh_worksheet_periods_cur;

     END LOOP; -- loop 2
    CLOSE pqh_worksheet_details_cur;

   END LOOP; -- loop 1
  CLOSE pqh_worksheets_cur;


  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
  WHEN others THEN
    raise;
END;


--------------------------------------------------------------------------------------------------------------

PROCEDURE edit_create_new_budget
(
 p_worksheet_id IN pqh_worksheets.worksheet_id%TYPE
)
IS
-- local variables and cursors

l_proc                           varchar2(72) := g_package||'edit_create_new_budget';

BEGIN

  hr_utility.set_location('Entering: '||l_proc, 5);

    -- apply the existing records from worksheet tables to budget tables
    apply_new_budget
    (
     p_worksheet_id => p_worksheet_id,
     p_mode         => 'I'
    );

/*
  As of rqmt 06/09/2000 we will not carry forward any budget records for this mode

  -- carry forward the remaining records from budget tables
   carry_forward_budget
    (
     p_worksheet_id        => p_worksheet_id,
     p_budget_version_id   => g_budget_version_id
    );

*/

  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
  WHEN others THEN
    raise;
END;



--------------------------------------------------------------------------------------------------------------


PROCEDURE edit_update_budget
(
 p_worksheet_id IN pqh_worksheets.worksheet_id%TYPE
)
IS
-- local variables and cursors

l_proc                           varchar2(72) := g_package||'edit_update_budget';

BEGIN

  hr_utility.set_location('Entering: '||l_proc, 5);

    -- delete the rows from budget tables
    /*
      delete_child_rows
      we pick budget_detail_id from pqh_worksheet_details table for this worksheet_id
      and delete only those rows from pqh_budget_periods table onwards for the above
      fetched budget_detail_id from pqh_worksheet_details table.
    */
    delete_child_rows
    (
     p_worksheet_id   => p_worksheet_id
    );

    -- now create new rows
    apply_new_budget
    (
     p_worksheet_id => p_worksheet_id,
     p_mode         => 'U'
    );

  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
  WHEN others THEN
    raise;
END;





--------------------------------------------------------------------------------------------------------------

PROCEDURE populate_budget_versions
(
 p_worksheets_rec      IN    pqh_worksheets%ROWTYPE,
 p_budget_id           IN    pqh_budgets.budget_id%TYPE,
 p_worksheet_mode_cd   IN    pqh_worksheets.worksheet_mode_cd%TYPE,
 p_budget_version_id_o OUT NOCOPY   pqh_budget_versions.budget_version_id%TYPE
)
IS
-- local variables and cursors

CURSOR version_number_cur IS
SELECT NVL(max(version_number),0)
FROM pqh_budget_versions
WHERE budget_id = p_budget_id;

CURSOR budget_version_cur(p_curr_version_number IN number) IS
SELECT *
FROM pqh_budget_versions
WHERE budget_id = p_budget_id
  AND version_number = p_curr_version_number;

-- cursor for unit1_value,2,3
CURSOR units_csr IS
SELECT sum(nvl(BUDGET_UNIT1_VALUE,0)) ,
       sum(nvl(BUDGET_UNIT2_VALUE,0)) ,
       sum(nvl(BUDGET_UNIT3_VALUE,0))
FROM pqh_worksheet_details
WHERE worksheet_id = p_worksheets_rec.worksheet_id
  AND nvl(action_cd,'X') = 'B' ;


l_proc                        varchar2(72) := g_package||'populate_budget_versions';
l_object_version_number       pqh_budget_versions.object_version_number%TYPE;
l_version_number              pqh_budget_versions.version_number%TYPE;
l_curr_version_number         pqh_budget_versions.version_number%TYPE;
l_max_version_number          pqh_budget_versions.version_number%TYPE;
l_budget_versions_rec         pqh_budget_versions%ROWTYPE;
l_budget_unit1_value          pqh_budget_versions.budget_unit1_value%TYPE;
l_budget_unit1_available      pqh_budget_versions.budget_unit1_available%TYPE ;
l_budget_unit2_value          pqh_budget_versions.budget_unit2_value%TYPE;
l_budget_unit2_available      pqh_budget_versions.budget_unit2_available%TYPE ;
l_budget_unit3_value          pqh_budget_versions.budget_unit3_value%TYPE;
l_budget_unit3_available      pqh_budget_versions.budget_unit3_available%TYPE ;


BEGIN

 hr_utility.set_location('Entering: '||l_proc, 5);

 -- compute max version number
  OPEN version_number_cur;
   FETCH version_number_cur INTO l_max_version_number;
  CLOSE version_number_cur;

-- current version number of the current budget from the worksheet record
   l_curr_version_number  := p_worksheets_rec.version_number;

-- fetch the current budget_versions record
  OPEN budget_version_cur(p_curr_version_number => l_curr_version_number);
    FETCH budget_version_cur INTO l_budget_versions_rec;
  CLOSE budget_version_cur;

  l_object_version_number  := l_budget_versions_rec.object_version_number;

 -- compute the unit values
   OPEN units_csr;
     FETCH units_csr INTO l_budget_unit1_value, l_budget_unit2_value, l_budget_unit3_value;
   CLOSE units_csr;

  IF p_worksheet_mode_cd = 'O' THEN
     -- update the same version
     -- call update API here
      l_version_number := l_curr_version_number;

        pqh_budget_versions_api.update_budget_version
         (
          p_validate                        => false
         ,p_budget_version_id               => l_budget_versions_rec.budget_version_id
         ,p_budget_id                       => l_budget_versions_rec.budget_id
         ,p_version_number                  => l_budget_versions_rec.version_number
         ,p_date_from                       => p_worksheets_rec.date_from
         ,p_date_to                         => p_worksheets_rec.date_to
         ,p_transfered_to_gl_flag           => l_budget_versions_rec.transfered_to_gl_flag
         ,p_xfer_to_other_apps_cd           => l_budget_versions_rec.xfer_to_other_apps_cd
         ,p_object_version_number           => l_object_version_number
         ,p_budget_unit1_value              => l_budget_unit1_value
         ,p_budget_unit2_value              => l_budget_unit2_value
         ,p_budget_unit3_value              => l_budget_unit3_value
         ,p_budget_unit1_available          => l_budget_unit1_available
         ,p_budget_unit2_available          => l_budget_unit2_available
         ,p_budget_unit3_available          => l_budget_unit3_available
         ,p_effective_date                  => sysdate
         );

      -- populate the out variable
      p_budget_version_id_o  := l_budget_versions_rec.budget_version_id;

  ELSIF p_worksheet_mode_cd = 'S' THEN
     -- this is a first version and a record for this has already been created by the
     -- budget form.
     -- call update API here
      l_version_number := l_curr_version_number;

        pqh_budget_versions_api.update_budget_version
         (
          p_validate                        => false
         ,p_budget_version_id               => l_budget_versions_rec.budget_version_id
         ,p_budget_id                       => l_budget_versions_rec.budget_id
         ,p_version_number                  => l_budget_versions_rec.version_number
         ,p_date_from                       => p_worksheets_rec.date_from
         ,p_date_to                         => p_worksheets_rec.date_to
         ,p_transfered_to_gl_flag           => l_budget_versions_rec.transfered_to_gl_flag
         ,p_xfer_to_other_apps_cd           => l_budget_versions_rec.xfer_to_other_apps_cd
         ,p_object_version_number           => l_object_version_number
         ,p_budget_unit1_value              => l_budget_unit1_value
         ,p_budget_unit2_value              => l_budget_unit2_value
         ,p_budget_unit3_value              => l_budget_unit3_value
         ,p_budget_unit1_available          => l_budget_unit1_available
         ,p_budget_unit2_available          => l_budget_unit2_available
         ,p_budget_unit3_available          => l_budget_unit3_available
         ,p_effective_date                  => sysdate
         );

      -- populate the out variable
      p_budget_version_id_o  := l_budget_versions_rec.budget_version_id;


  ELSE
     -- modes new_override and carry_forward , create new version record
     -- call insert API
      l_version_number := l_max_version_number + 1;

        pqh_budget_versions_api.create_budget_version
       (
          p_validate                       =>   false
         ,p_budget_version_id              =>   p_budget_version_id_o
         ,p_budget_id                      =>   p_budget_id
         ,p_version_number                 =>   l_version_number
         ,p_date_from                      =>   p_worksheets_rec.date_from
         ,p_date_to                        =>   p_worksheets_rec.date_to
         ,p_transfered_to_gl_flag          =>   'N'
         ,p_xfer_to_other_apps_cd          =>   'N'
         ,p_object_version_number          =>   l_object_version_number
         ,p_budget_unit1_value             => l_budget_unit1_value
         ,p_budget_unit2_value             => l_budget_unit2_value
         ,p_budget_unit3_value             => l_budget_unit3_value
         ,p_budget_unit1_available         => l_budget_unit1_available
         ,p_budget_unit2_available         => l_budget_unit2_available
         ,p_budget_unit3_available         => l_budget_unit3_available
         ,p_effective_date                 =>   sysdate
        );


  END IF;

 hr_utility.set_location('Current Version Number : '||l_version_number, 6);
 hr_utility.set_location('Worksheet Id  : '||p_worksheets_rec.worksheet_id, 7);
 hr_utility.set_location('PQH Budget Version out nocopy '||p_budget_version_id_o, 15);


 hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
  WHEN others THEN
  p_budget_version_id_o := null;
   -- insert error into log table
      pqh_process_batch_log.insert_log
      (
       p_message_type_cd    =>  'ERROR',
       p_message_text       =>  SQLERRM
      );
END populate_budget_versions;

--------------------------------------------------------------------------------------------------------------

PROCEDURE populate_budget_details
(
 p_worksheet_details_rec      IN  pqh_worksheet_details%ROWTYPE,
 p_budget_version_id          IN  pqh_budget_versions.budget_version_id%TYPE,
 p_worksheet_id               IN  pqh_worksheets.worksheet_id%type,
 p_worksheet_mode_cd          IN  pqh_worksheets.worksheet_mode_cd%TYPE,
 p_budget_detail_id_o         OUT NOCOPY pqh_budget_details.budget_detail_id%TYPE
)
IS
-- local variables and cursors

l_proc                        varchar2(72) := g_package||'populate_budget_details';
l_version_unit1_value         number;
l_version_unit2_value         number;
l_version_unit3_value         number;
l_budget_unit1_percent        number;
l_budget_unit2_percent        number;
l_budget_unit3_percent        number;
l_object_version_number       pqh_budget_details.object_version_number%TYPE;

CURSOR l_object_version_number_cur IS
SELECT object_version_number
FROM pqh_budget_details
WHERE budget_detail_id = p_worksheet_details_rec.budget_detail_id;

CURSOR units_csr IS
SELECT sum(nvl(BUDGET_UNIT1_VALUE,0)) ,
       sum(nvl(BUDGET_UNIT2_VALUE,0)) ,
       sum(nvl(BUDGET_UNIT3_VALUE,0))
FROM pqh_worksheet_details
WHERE worksheet_id = p_worksheet_id
  AND nvl(action_cd,'X') = 'B' ;

BEGIN

 hr_utility.set_location('Entering: '||l_proc, 5);
 hr_utility.set_location('Global Worksheet Mode : '||g_worksheet_mode_cd, 6);

 -- compute the unit values
   OPEN units_csr;
     FETCH units_csr INTO l_version_unit1_value, l_version_unit2_value, l_version_unit3_value;
   CLOSE units_csr;

 if nvl(l_version_unit1_value,0) >0 then
    l_budget_unit1_percent := (p_worksheet_details_rec.budget_unit1_value*100)/l_version_unit1_value ;
 else
    l_budget_unit1_percent := null;
 end if;
 if nvl(l_version_unit2_value,0) >0 then
    l_budget_unit2_percent := (p_worksheet_details_rec.budget_unit2_value*100)/l_version_unit2_value ;
 else
    l_budget_unit2_percent := null;
 end if;
 if nvl(l_version_unit3_value,0) >0 then
    l_budget_unit3_percent := (p_worksheet_details_rec.budget_unit3_value*100)/l_version_unit3_value ;
 else
    l_budget_unit3_percent := null;
 end if;
IF p_budget_version_id IS NOT NULL THEN
 IF g_worksheet_mode_cd = 'O' THEN
   -- this is update to the same version
   IF p_worksheet_details_rec.budget_detail_id IS NOT NULL THEN
   -- update rows where p_worksheet_details_rec.budget_detail_id IS NOT NULL
      hr_utility.set_location('Budget Detail Id : '||p_worksheet_details_rec.budget_detail_id, 7);

   -- get the object_version_number for this budget_detail_id and pass to update API
     OPEN l_object_version_number_cur;
      FETCH l_object_version_number_cur INTO l_object_version_number;
     CLOSE l_object_version_number_cur;

     hr_utility.set_location('Update API OVN  : '||l_object_version_number, 8);

     pqh_budget_details_api.update_budget_detail
   (
      p_validate                       =>  false
     ,p_budget_detail_id               =>  p_worksheet_details_rec.budget_detail_id
     ,p_organization_id                =>  p_worksheet_details_rec.organization_id
     ,p_job_id                         =>  p_worksheet_details_rec.job_id
     ,p_position_id                    =>  p_worksheet_details_rec.position_id
     ,p_grade_id                       =>  p_worksheet_details_rec.grade_id
     ,p_budget_version_id              =>  p_budget_version_id
     ,p_budget_unit1_percent           =>  l_budget_unit1_percent
     ,p_budget_unit1_value_type_cd     =>  p_worksheet_details_rec.budget_unit1_value_type_cd
     ,p_budget_unit1_value             =>  p_worksheet_details_rec.budget_unit1_value
     ,p_budget_unit1_available         =>  p_worksheet_details_rec.budget_unit1_available
     ,p_budget_unit2_percent           =>  l_budget_unit2_percent
     ,p_budget_unit2_value_type_cd     =>  p_worksheet_details_rec.budget_unit2_value_type_cd
     ,p_budget_unit2_value             =>  p_worksheet_details_rec.budget_unit2_value
     ,p_budget_unit2_available         =>  p_worksheet_details_rec.budget_unit2_available
     ,p_budget_unit3_percent           =>  l_budget_unit3_percent
     ,p_budget_unit3_value_type_cd     =>  p_worksheet_details_rec.budget_unit3_value_type_cd
     ,p_budget_unit3_value             =>  p_worksheet_details_rec.budget_unit3_value
     ,p_budget_unit3_available         =>  p_worksheet_details_rec.budget_unit3_available
     ,p_object_version_number          =>  l_object_version_number
   );

      p_budget_detail_id_o  := p_worksheet_details_rec.budget_detail_id;

   ELSE
   -- for others i.e new rows call the insert API

     hr_utility.set_location('Create API in update mode : ', 9);

     pqh_budget_details_api.create_budget_detail
   (
      p_validate                       =>  false
     ,p_budget_detail_id               =>  p_budget_detail_id_o
     ,p_organization_id                =>  p_worksheet_details_rec.organization_id
     ,p_job_id                         =>  p_worksheet_details_rec.job_id
     ,p_position_id                    =>  p_worksheet_details_rec.position_id
     ,p_grade_id                       =>  p_worksheet_details_rec.grade_id
     ,p_budget_version_id              =>  p_budget_version_id
     ,p_budget_unit1_percent           =>  l_budget_unit1_percent
     ,p_budget_unit1_value_type_cd     =>  p_worksheet_details_rec.budget_unit1_value_type_cd
     ,p_budget_unit1_value             =>  p_worksheet_details_rec.budget_unit1_value
     ,p_budget_unit1_available         =>  p_worksheet_details_rec.budget_unit1_available
     ,p_budget_unit2_percent           =>  l_budget_unit2_percent
     ,p_budget_unit2_value_type_cd     =>  p_worksheet_details_rec.budget_unit2_value_type_cd
     ,p_budget_unit2_value             =>  p_worksheet_details_rec.budget_unit2_value
     ,p_budget_unit2_available         =>  p_worksheet_details_rec.budget_unit2_available
     ,p_budget_unit3_percent           =>  l_budget_unit3_percent
     ,p_budget_unit3_value_type_cd     =>  p_worksheet_details_rec.budget_unit3_value_type_cd
     ,p_budget_unit3_value             =>  p_worksheet_details_rec.budget_unit3_value
     ,p_budget_unit3_available         =>  p_worksheet_details_rec.budget_unit3_available
     ,p_object_version_number          =>  l_object_version_number
 );

   END IF;
 ELSE -- i.e not update mode
  -- call insert API
  hr_utility.set_location('Create API in INSERT Mode : ', 10);

  pqh_budget_details_api.create_budget_detail
(
   p_validate                       =>  false
  ,p_budget_detail_id               =>  p_budget_detail_id_o
  ,p_organization_id                =>  p_worksheet_details_rec.organization_id
  ,p_job_id                         =>  p_worksheet_details_rec.job_id
  ,p_position_id                    =>  p_worksheet_details_rec.position_id
  ,p_grade_id                       =>  p_worksheet_details_rec.grade_id
  ,p_budget_version_id              =>  p_budget_version_id
  ,p_budget_unit1_percent           =>  l_budget_unit1_percent
  ,p_budget_unit1_value_type_cd     =>  p_worksheet_details_rec.budget_unit1_value_type_cd
  ,p_budget_unit1_value             =>  p_worksheet_details_rec.budget_unit1_value
  ,p_budget_unit1_available         =>  p_worksheet_details_rec.budget_unit1_available
  ,p_budget_unit2_percent           =>  l_budget_unit2_percent
  ,p_budget_unit2_value_type_cd     =>  p_worksheet_details_rec.budget_unit2_value_type_cd
  ,p_budget_unit2_value             =>  p_worksheet_details_rec.budget_unit2_value
  ,p_budget_unit2_available         =>  p_worksheet_details_rec.budget_unit2_available
  ,p_budget_unit3_percent           =>  l_budget_unit3_percent
  ,p_budget_unit3_value_type_cd     =>  p_worksheet_details_rec.budget_unit3_value_type_cd
  ,p_budget_unit3_value             =>  p_worksheet_details_rec.budget_unit3_value
  ,p_budget_unit3_available         =>  p_worksheet_details_rec.budget_unit3_available
  ,p_object_version_number          =>  l_object_version_number
 );

 END IF;

END IF; --  p_budget_version_id is not null

 hr_utility.set_location('PQH Budget Detail ID out nocopy '||p_budget_detail_id_o, 100);
 hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
  WHEN others THEN

  p_budget_detail_id_o := null;

   -- insert error into log table
      pqh_process_batch_log.insert_log
      (
       p_message_type_cd    =>  'ERROR',
       p_message_text       =>  SQLERRM
      );
END populate_budget_details;

--------------------------------------------------------------------------------------------------------------
PROCEDURE populate_budget_periods
(
 p_worksheet_periods_rec      IN  pqh_worksheet_periods%ROWTYPE,
 p_budget_detail_id           IN  pqh_budget_details.budget_detail_id%TYPE,
 p_budget_period_id_o         OUT NOCOPY pqh_budget_periods.budget_period_id%TYPE
)
IS
-- local variables and cursors

l_proc                        varchar2(72) := g_package||'populate_budget_periods';
l_object_version_number       pqh_budget_periods.object_version_number%TYPE;

BEGIN

 hr_utility.set_location('Entering: '||l_proc, 5);

IF p_budget_detail_id IS NOT NULL THEN

  -- call insert API
  pqh_budget_periods_api.create_budget_period
(
   p_validate                       =>  false
  ,p_budget_period_id               =>  p_budget_period_id_o
  ,p_budget_detail_id               =>  p_budget_detail_id
  ,p_start_time_period_id           =>  p_worksheet_periods_rec.start_time_period_id
  ,p_end_time_period_id             =>  p_worksheet_periods_rec.end_time_period_id
  ,p_budget_unit1_percent           =>  p_worksheet_periods_rec.budget_unit1_percent
  ,p_budget_unit2_percent           =>  p_worksheet_periods_rec.budget_unit2_percent
  ,p_budget_unit3_percent           =>  p_worksheet_periods_rec.budget_unit3_percent
  ,p_budget_unit1_value             =>  p_worksheet_periods_rec.budget_unit1_value
  ,p_budget_unit2_value             =>  p_worksheet_periods_rec.budget_unit2_value
  ,p_budget_unit3_value             =>  p_worksheet_periods_rec.budget_unit3_value
  ,p_budget_unit1_value_type_cd     =>  p_worksheet_periods_rec.budget_unit1_value_type_cd
  ,p_budget_unit2_value_type_cd     =>  p_worksheet_periods_rec.budget_unit2_value_type_cd
  ,p_budget_unit3_value_type_cd     =>  p_worksheet_periods_rec.budget_unit3_value_type_cd
  ,p_budget_unit1_available          =>  p_worksheet_periods_rec.budget_unit1_available
  ,p_budget_unit2_available          =>  p_worksheet_periods_rec.budget_unit2_available
  ,p_budget_unit3_available          =>  p_worksheet_periods_rec.budget_unit3_available
  ,p_object_version_number          =>  l_object_version_number
 );


END IF; -- p_budget_detail_id is not null

 hr_utility.set_location('PQH Budget Period ID out nocopy '||p_budget_period_id_o, 100);
 hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
  WHEN others THEN

  p_budget_period_id_o := null;

   -- insert error into log table
      pqh_process_batch_log.insert_log
      (
       p_message_type_cd    =>  'ERROR',
       p_message_text       =>  SQLERRM
      );
END populate_budget_periods;

--------------------------------------------------------------------------------------------------------------

PROCEDURE populate_budget_sets
(
 p_worksheet_budget_sets_rec  IN  pqh_worksheet_budget_sets%ROWTYPE,
 p_budget_period_id           IN  pqh_budget_periods.budget_period_id%TYPE,
 p_budget_set_id_o            OUT NOCOPY pqh_budget_sets.budget_set_id%TYPE
)
IS
-- local variables and cursors

l_proc                        varchar2(72) := g_package||'populate_budget_sets';
l_object_version_number       pqh_budget_periods.object_version_number%TYPE;

BEGIN

 hr_utility.set_location('Entering: '||l_proc, 5);

IF p_budget_period_id IS NOT NULL THEN

  -- call insert API
 pqh_budget_sets_api.create_budget_set
 (
   p_validate                       =>  false
  ,p_budget_set_id                  =>  p_budget_set_id_o
  ,p_dflt_budget_set_id             =>  p_worksheet_budget_sets_rec.dflt_budget_set_id
  ,p_budget_period_id               =>  p_budget_period_id
  ,p_budget_unit1_percent           =>  p_worksheet_budget_sets_rec.budget_unit1_percent
  ,p_budget_unit2_percent           =>  p_worksheet_budget_sets_rec.budget_unit2_percent
  ,p_budget_unit3_percent           =>  p_worksheet_budget_sets_rec.budget_unit3_percent
  ,p_budget_unit1_value             =>  p_worksheet_budget_sets_rec.budget_unit1_value
  ,p_budget_unit2_value             =>  p_worksheet_budget_sets_rec.budget_unit2_value
  ,p_budget_unit3_value             =>  p_worksheet_budget_sets_rec.budget_unit3_value
  ,p_budget_unit1_available          =>  p_worksheet_budget_sets_rec.budget_unit1_available
  ,p_budget_unit2_available          =>  p_worksheet_budget_sets_rec.budget_unit2_available
  ,p_budget_unit3_available          =>  p_worksheet_budget_sets_rec.budget_unit3_available
  ,p_object_version_number          =>  l_object_version_number
  ,p_budget_unit1_value_type_cd     =>  p_worksheet_budget_sets_rec.budget_unit1_value_type_cd
  ,p_budget_unit2_value_type_cd     =>  p_worksheet_budget_sets_rec.budget_unit2_value_type_cd
  ,p_budget_unit3_value_type_cd     =>  p_worksheet_budget_sets_rec.budget_unit3_value_type_cd
  ,p_effective_date                 =>  sysdate
 );


END IF; -- p_budget_period_id is not null

 hr_utility.set_location('PQH Budget Set ID out nocopy '||p_budget_set_id_o, 100);
 hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
  WHEN others THEN

  p_budget_set_id_o := null;

   -- insert error into log table
      pqh_process_batch_log.insert_log
      (
       p_message_type_cd    =>  'ERROR',
       p_message_text       =>  SQLERRM
      );
END populate_budget_sets;

--------------------------------------------------------------------------------------------------------------
PROCEDURE populate_budget_elements
(
 p_worksheet_bdgt_elmnts_rec  IN  pqh_worksheet_bdgt_elmnts%ROWTYPE,
 p_budget_set_id              IN  pqh_budget_sets.budget_set_id%TYPE,
 p_budget_element_id_o        OUT NOCOPY pqh_budget_elements.budget_element_id%TYPE
)
IS

-- local variables and cursors

l_proc                        varchar2(72) := g_package||'populate_budget_elements';
l_object_version_number       pqh_budget_periods.object_version_number%TYPE;

BEGIN

 hr_utility.set_location('Entering: '||l_proc, 5);

IF p_budget_set_id IS NOT NULL THEN

  -- call insert API
 pqh_budget_elements_api.create_budget_element
 (
   p_validate                       =>  false
  ,p_budget_element_id              =>  p_budget_element_id_o
  ,p_budget_set_id                  =>  p_budget_set_id
  ,p_element_type_id                =>  p_worksheet_bdgt_elmnts_rec.element_type_id
  ,p_distribution_percentage        =>  p_worksheet_bdgt_elmnts_rec.distribution_percentage
  ,p_object_version_number          =>  l_object_version_number
 );

END IF; -- p_budget_set_id is not null

 hr_utility.set_location('PQH Budget Element ID out nocopy '||p_budget_element_id_o, 100);
 hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
  WHEN others THEN

  p_budget_element_id_o := null;
   -- insert error into log table
      pqh_process_batch_log.insert_log
      (
       p_message_type_cd    =>  'ERROR',
       p_message_text       =>  SQLERRM
      );
END populate_budget_elements;

--------------------------------------------------------------------------------------------------------------
PROCEDURE populate_budget_fund_srcs
(
 p_worksheet_fund_srcs_rec    IN  pqh_worksheet_fund_srcs%ROWTYPE,
 p_budget_element_id          IN  pqh_budget_elements.budget_element_id%TYPE,
 p_budget_fund_src_id_o       OUT NOCOPY pqh_budget_fund_srcs.budget_fund_src_id%TYPE
)
IS
-- local variables and cursors

l_proc                        varchar2(72) := g_package||'populate_budget_fund_srcs';
l_object_version_number       pqh_budget_periods.object_version_number%TYPE;

BEGIN

 hr_utility.set_location('Entering: '||l_proc, 5);

IF p_budget_element_id IS NOT NULL THEN

  -- call insert API
  pqh_budget_fund_srcs_api.create_budget_fund_src
  (
   p_validate                       =>  false
  ,p_budget_fund_src_id             =>  p_budget_fund_src_id_o
  ,p_budget_element_id              =>  p_budget_element_id
  ,p_cost_allocation_keyflex_id     =>  p_worksheet_fund_srcs_rec.cost_allocation_keyflex_id
  ,p_project_id                     =>  p_worksheet_fund_srcs_rec.project_id
  ,p_award_id                       =>  p_worksheet_fund_srcs_rec.award_id
  ,p_task_id                        =>  p_worksheet_fund_srcs_rec.task_id
  ,p_expenditure_type               =>  p_worksheet_fund_srcs_rec.expenditure_type
  ,p_organization_id                =>  p_worksheet_fund_srcs_rec.organization_id
  ,p_distribution_percentage        =>  p_worksheet_fund_srcs_rec.distribution_percentage
  ,p_object_version_number          =>  l_object_version_number
 );

END IF; -- p_budget_element_id is not null

 hr_utility.set_location('PQH Budget Fund Src ID out nocopy '||p_budget_fund_src_id_o, 100);
 hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
  WHEN others THEN

  p_budget_fund_src_id_o := null;
   -- insert error into log table
      pqh_process_batch_log.insert_log
      (
       p_message_type_cd    =>  'ERROR',
       p_message_text       =>  SQLERRM
      );
END populate_budget_fund_srcs;

--------------------------------------------------------------------------------------------------------------
PROCEDURE carry_forward_budget
(
 p_worksheet_id        IN pqh_worksheets.worksheet_id%TYPE,
 p_budget_version_id   IN pqh_budget_versions.budget_version_id%TYPE
)
IS
-- local variables and cursors

CURSOR pqh_worksheets_cur(p_worksheet_id  IN pqh_worksheets.worksheet_id%TYPE) IS
 SELECT *
 FROM pqh_worksheets
 WHERE worksheet_id = p_worksheet_id;

CURSOR pqh_budget_details_cur (p_curr_budget_version_id  IN pqh_budget_details.budget_version_id%TYPE ,
                               p_worksheet_id            IN pqh_worksheets.worksheet_id%TYPE ) IS
 SELECT *
 FROM  pqh_budget_details
 WHERE budget_version_id = p_curr_budget_version_id
   AND budget_detail_id NOT IN ( SELECT budget_detail_id
                                 FROM  pqh_worksheet_details
                                 WHERE worksheet_id = p_worksheet_id
                                   AND NVL(action_cd,'X') = 'B' ) ;

CURSOR pqh_budget_periods_cur (p_budget_detail_id  IN pqh_budget_details.budget_detail_id%TYPE) IS
 SELECT *
 FROM  pqh_budget_periods
 WHERE  budget_detail_id = p_budget_detail_id;

CURSOR pqh_budget_sets_cur (p_budget_period_id  IN  pqh_budget_periods.budget_period_id%TYPE) IS
 SELECT *
 FROM  pqh_budget_sets
 WHERE budget_period_id = p_budget_period_id;

CURSOR pqh_budget_elements_cur (p_budget_set_id  IN  pqh_budget_sets.budget_set_id%TYPE) IS
 SELECT *
 FROM  pqh_budget_elements
 WHERE budget_set_id = p_budget_set_id;

CURSOR pqh_budget_fund_srcs_cur (p_budget_element_id  IN  pqh_budget_elements.budget_element_id%TYPE) IS
 SELECT *
 FROM  pqh_budget_fund_srcs
 WHERE budget_element_id = p_budget_element_id;

CURSOR current_version_cur (p_worksheet_id  IN pqh_worksheets.worksheet_id%TYPE ) IS
 SELECT bvr.budget_version_id
 FROM pqh_budget_versions bvr, pqh_worksheets wks
 WHERE bvr.budget_id = wks.budget_id
   AND bvr.version_number = wks.version_number
   AND wks.worksheet_id = p_worksheet_id;


l_proc                           varchar2(72) := g_package||'carry_forward_budget';
l_pqh_worksheets_rec             pqh_worksheets%ROWTYPE;
l_budget_version_id              pqh_budget_versions.budget_version_id%TYPE;
l_pqh_budget_details_rec         pqh_budget_details%ROWTYPE;
l_budget_detail_id               pqh_budget_details.budget_detail_id%TYPE;
l_pqh_budget_periods_rec         pqh_budget_periods%ROWTYPE;
l_budget_period_id               pqh_budget_periods.budget_period_id%TYPE;
l_pqh_budget_sets_rec            pqh_budget_sets%ROWTYPE;
l_budget_set_id                  pqh_budget_sets.budget_set_id%TYPE;
l_pqh_budget_elements_rec        pqh_budget_elements%ROWTYPE;
l_budget_element_id              pqh_budget_elements.budget_element_id%TYPE;
l_pqh_budget_fund_srcs_rec       pqh_budget_fund_srcs%ROWTYPE;
l_budget_fund_src_id             pqh_budget_fund_srcs.budget_fund_src_id%TYPE;
l_curr_budget_version_id         pqh_budget_versions.budget_version_id%TYPE;

BEGIN

  hr_utility.set_location('Entering: '||l_proc, 5);

  -- get the current version number
   OPEN current_version_cur(p_worksheet_id  => p_worksheet_id );
    FETCH current_version_cur INTO l_curr_budget_version_id;
   CLOSE current_version_cur;

   hr_utility.set_location('Current Version : '||l_curr_budget_version_id, 6);

   -- open the pqh_worksheets_cur
  OPEN pqh_worksheets_cur(p_worksheet_id  => p_worksheet_id);
   LOOP  -- loop 1
    FETCH pqh_worksheets_cur INTO l_pqh_worksheets_rec;
    EXIT WHEN pqh_worksheets_cur%NOTFOUND;

    -- open pqh_budget_details_cur
    OPEN pqh_budget_details_cur(p_curr_budget_version_id  =>  l_curr_budget_version_id,
                                p_worksheet_id            =>  l_pqh_worksheets_rec.worksheet_id );
     LOOP  -- loop 2
      FETCH pqh_budget_details_cur INTO l_pqh_budget_details_rec;
      EXIT WHEN pqh_budget_details_cur%NOTFOUND;
      -- create records in pqh_budget_details
      carry_forward_budget_details
      (
       p_pqh_budget_details_rec     => l_pqh_budget_details_rec,
       p_budget_version_id          => p_budget_version_id,
       p_budget_detail_id_o         => l_budget_detail_id
      );

      -- open pqh_budget_periods_cur
      OPEN pqh_budget_periods_cur(p_budget_detail_id  => l_pqh_budget_details_rec.budget_detail_id);
       LOOP -- loop 3
        FETCH pqh_budget_periods_cur INTO l_pqh_budget_periods_rec;
        EXIT WHEN pqh_budget_periods_cur%NOTFOUND;
        -- create records in pqh_budget_periods
        carry_forward_budget_periods
        (
         p_pqh_budget_periods_rec      => l_pqh_budget_periods_rec,
         p_budget_detail_id            => l_budget_detail_id,
         p_budget_period_id_o          => l_budget_period_id
        );

       -- open pqh_budget_sets_cur
        OPEN pqh_budget_sets_cur(p_budget_period_id  => l_pqh_budget_periods_rec.budget_period_id);
         LOOP  -- loop 4
          FETCH pqh_budget_sets_cur INTO l_pqh_budget_sets_rec;
          EXIT WHEN pqh_budget_sets_cur%NOTFOUND;
          -- create records in pqh_budget_sets
          carry_forward_budget_sets
         (
          p_pqh_budget_sets_rec        => l_pqh_budget_sets_rec,
          p_budget_period_id           => l_budget_period_id,
          p_budget_set_id_o            => l_budget_set_id
         );

          -- open pqh_budget_elements_cur
          OPEN pqh_budget_elements_cur(p_budget_set_id  => l_pqh_budget_sets_rec.budget_set_id);
           LOOP  -- loop 5
            FETCH pqh_budget_elements_cur INTO l_pqh_budget_elements_rec;
            EXIT WHEN pqh_budget_elements_cur%NOTFOUND;
            -- create records in pqh_budget_elements
            carry_forward_budget_elements
            (
             p_pqh_budget_elements_rec    => l_pqh_budget_elements_rec,
             p_budget_set_id              => l_budget_set_id,
             p_budget_element_id_o        => l_budget_element_id
            );

            -- open pqh_budget_fund_srcs_cur
             OPEN pqh_budget_fund_srcs_cur(p_budget_element_id  => l_pqh_budget_elements_rec.budget_element_id);
              LOOP -- loop 6
               FETCH pqh_budget_fund_srcs_cur INTO l_pqh_budget_fund_srcs_rec;
               EXIT WHEN pqh_budget_fund_srcs_cur%NOTFOUND;
               -- create records in pqh_budget_fund_srcs
               carry_forward_budget_fund_srcs
               (
                p_pqh_budget_fund_srcs_rec    => l_pqh_budget_fund_srcs_rec,
                p_budget_element_id           => l_budget_element_id,
                p_budget_fund_src_id_o        => l_budget_fund_src_id
               );


              END LOOP; -- loop 6
             CLOSE pqh_budget_fund_srcs_cur;

           END LOOP; -- loop 5
          CLOSE pqh_budget_elements_cur;

         END LOOP;  -- loop 4
        CLOSE pqh_budget_sets_cur;

       END LOOP; -- loop 3
      CLOSE pqh_budget_periods_cur;

     END LOOP; -- loop 2
    CLOSE pqh_budget_details_cur;

   END LOOP; -- loop 1
  CLOSE pqh_worksheets_cur;


  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
  WHEN others THEN
    raise;
END;

--------------------------------------------------------------------------------------------------------------

PROCEDURE carry_forward_budget_details
(
 p_pqh_budget_details_rec     IN  pqh_budget_details%ROWTYPE,
 p_budget_version_id          IN  pqh_budget_versions.budget_version_id%TYPE,
 p_budget_detail_id_o         OUT NOCOPY pqh_budget_details.budget_detail_id%TYPE
)
IS
-- local variables and cursors

l_proc                        varchar2(72) := g_package||'carry_forward_budget_details';
l_object_version_number       pqh_budget_details.object_version_number%TYPE;


BEGIN

 hr_utility.set_location('Entering: '||l_proc, 5);

IF p_budget_version_id IS NOT NULL THEN

  -- call insert API
  pqh_budget_details_api.create_budget_detail
(
   p_validate                       =>  false
  ,p_budget_detail_id               =>  p_budget_detail_id_o
  ,p_organization_id                =>  p_pqh_budget_details_rec.organization_id
  ,p_job_id                         =>  p_pqh_budget_details_rec.job_id
  ,p_position_id                    =>  p_pqh_budget_details_rec.position_id
  ,p_grade_id                       =>  p_pqh_budget_details_rec.grade_id
  ,p_budget_version_id              =>  p_budget_version_id
  ,p_budget_unit1_percent           =>  p_pqh_budget_details_rec.budget_unit1_percent
  ,p_budget_unit1_value_type_cd     =>  p_pqh_budget_details_rec.budget_unit1_value_type_cd
  ,p_budget_unit1_value             =>  p_pqh_budget_details_rec.budget_unit1_value
  ,p_budget_unit1_available          =>  p_pqh_budget_details_rec.budget_unit1_available
  ,p_budget_unit2_percent           =>  p_pqh_budget_details_rec.budget_unit2_percent
  ,p_budget_unit2_value_type_cd     =>  p_pqh_budget_details_rec.budget_unit2_value_type_cd
  ,p_budget_unit2_value             =>  p_pqh_budget_details_rec.budget_unit2_value
  ,p_budget_unit2_available          =>  p_pqh_budget_details_rec.budget_unit2_available
  ,p_budget_unit3_percent           =>  p_pqh_budget_details_rec.budget_unit3_percent
  ,p_budget_unit3_value_type_cd     =>  p_pqh_budget_details_rec.budget_unit3_value_type_cd
  ,p_budget_unit3_value             =>  p_pqh_budget_details_rec.budget_unit3_value
  ,p_budget_unit3_available          =>  p_pqh_budget_details_rec.budget_unit3_available
  ,p_object_version_number          =>  l_object_version_number
 );


END IF; -- p_budget_version_id is not null

 hr_utility.set_location('PQH Budget Detail ID out nocopy '||p_budget_detail_id_o, 100);
 hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
  WHEN others THEN
  p_budget_detail_id_o := null;
    raise;
END carry_forward_budget_details;

--------------------------------------------------------------------------------------------------------------
PROCEDURE carry_forward_budget_periods
(
 p_pqh_budget_periods_rec      IN  pqh_budget_periods%ROWTYPE,
 p_budget_detail_id            IN  pqh_budget_details.budget_detail_id%TYPE,
 p_budget_period_id_o          OUT NOCOPY pqh_budget_periods.budget_period_id%TYPE
)
IS
-- local variables and cursors

l_proc                        varchar2(72) := g_package||'carry_forward_budget_periods';
l_object_version_number       pqh_budget_periods.object_version_number%TYPE;

BEGIN

 hr_utility.set_location('Entering: '||l_proc, 5);

IF p_budget_detail_id IS NOT NULL THEN

  -- call insert API
  pqh_budget_periods_api.create_budget_period
(
   p_validate                       =>  false
  ,p_budget_period_id               =>  p_budget_period_id_o
  ,p_budget_detail_id               =>  p_budget_detail_id
  ,p_start_time_period_id           =>  p_pqh_budget_periods_rec.start_time_period_id
  ,p_end_time_period_id             =>  p_pqh_budget_periods_rec.end_time_period_id
  ,p_budget_unit1_percent           =>  p_pqh_budget_periods_rec.budget_unit1_percent
  ,p_budget_unit2_percent           =>  p_pqh_budget_periods_rec.budget_unit2_percent
  ,p_budget_unit3_percent           =>  p_pqh_budget_periods_rec.budget_unit3_percent
  ,p_budget_unit1_value             =>  p_pqh_budget_periods_rec.budget_unit1_value
  ,p_budget_unit2_value             =>  p_pqh_budget_periods_rec.budget_unit2_value
  ,p_budget_unit3_value             =>  p_pqh_budget_periods_rec.budget_unit3_value
  ,p_budget_unit1_value_type_cd     =>  p_pqh_budget_periods_rec.budget_unit1_value_type_cd
  ,p_budget_unit2_value_type_cd     =>  p_pqh_budget_periods_rec.budget_unit2_value_type_cd
  ,p_budget_unit3_value_type_cd     =>  p_pqh_budget_periods_rec.budget_unit3_value_type_cd
  ,p_budget_unit1_available         =>  p_pqh_budget_periods_rec.budget_unit1_available
  ,p_budget_unit2_available         =>  p_pqh_budget_periods_rec.budget_unit2_available
  ,p_budget_unit3_available         =>  p_pqh_budget_periods_rec.budget_unit3_available
  ,p_object_version_number          =>  l_object_version_number
 );


END IF; -- p_budget_detail_id is not null

 hr_utility.set_location('PQH Budget Period ID out nocopy '||p_budget_period_id_o, 100);
 hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
  WHEN others THEN
p_budget_period_id_o := null;
    raise;
END carry_forward_budget_periods;

--------------------------------------------------------------------------------------------------------------

PROCEDURE carry_forward_budget_sets
(
 p_pqh_budget_sets_rec        IN  pqh_budget_sets%ROWTYPE,
 p_budget_period_id           IN  pqh_budget_periods.budget_period_id%TYPE,
 p_budget_set_id_o            OUT NOCOPY pqh_budget_sets.budget_set_id%TYPE
)
IS
-- local variables and cursors

l_proc                        varchar2(72) := g_package||'carry_forward_budget_sets';
l_object_version_number       pqh_budget_periods.object_version_number%TYPE;

BEGIN

 hr_utility.set_location('Entering: '||l_proc, 5);

IF p_budget_period_id IS NOT NULL THEN

  -- call insert API
 pqh_budget_sets_api.create_budget_set
 (
   p_validate                       =>  false
  ,p_budget_set_id                  =>  p_budget_set_id_o
  ,p_dflt_budget_set_id             =>  p_pqh_budget_sets_rec.dflt_budget_set_id
  ,p_budget_period_id               =>  p_budget_period_id
  ,p_budget_unit1_percent           =>  p_pqh_budget_sets_rec.budget_unit1_percent
  ,p_budget_unit2_percent           =>  p_pqh_budget_sets_rec.budget_unit2_percent
  ,p_budget_unit3_percent           =>  p_pqh_budget_sets_rec.budget_unit3_percent
  ,p_budget_unit1_value             =>  p_pqh_budget_sets_rec.budget_unit1_value
  ,p_budget_unit2_value             =>  p_pqh_budget_sets_rec.budget_unit2_value
  ,p_budget_unit3_value             =>  p_pqh_budget_sets_rec.budget_unit3_value
  ,p_budget_unit1_available         =>  p_pqh_budget_sets_rec.budget_unit1_available
  ,p_budget_unit2_available         =>  p_pqh_budget_sets_rec.budget_unit2_available
  ,p_budget_unit3_available         =>  p_pqh_budget_sets_rec.budget_unit3_available
  ,p_object_version_number          =>  l_object_version_number
  ,p_budget_unit1_value_type_cd     =>  p_pqh_budget_sets_rec.budget_unit1_value_type_cd
  ,p_budget_unit2_value_type_cd     =>  p_pqh_budget_sets_rec.budget_unit2_value_type_cd
  ,p_budget_unit3_value_type_cd     =>  p_pqh_budget_sets_rec.budget_unit3_value_type_cd
  ,p_effective_date                 =>  sysdate
 );

END IF; -- p_budget_period_id is not null

 hr_utility.set_location('PQH Budget Set ID out nocopy '||p_budget_set_id_o, 100);
 hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
  WHEN others THEN
p_budget_set_id_o := null;
    raise;
END carry_forward_budget_sets;

--------------------------------------------------------------------------------------------------------------
PROCEDURE carry_forward_budget_elements
(
 p_pqh_budget_elements_rec    IN  pqh_budget_elements%ROWTYPE,
 p_budget_set_id              IN  pqh_budget_sets.budget_set_id%TYPE,
 p_budget_element_id_o        OUT NOCOPY pqh_budget_elements.budget_element_id%TYPE
)
IS

-- local variables and cursors

l_proc                        varchar2(72) := g_package||'carry_forward_budget_elements';
l_object_version_number       pqh_budget_periods.object_version_number%TYPE;

BEGIN

 hr_utility.set_location('Entering: '||l_proc, 5);

IF p_budget_set_id IS NOT NULL THEN

  -- call insert API
 pqh_budget_elements_api.create_budget_element
 (
   p_validate                       =>  false
  ,p_budget_element_id              =>  p_budget_element_id_o
  ,p_budget_set_id                  =>  p_budget_set_id
  ,p_element_type_id                =>  p_pqh_budget_elements_rec.element_type_id
  ,p_distribution_percentage        =>  p_pqh_budget_elements_rec.distribution_percentage
  ,p_object_version_number          =>  l_object_version_number
 );

END IF; -- p_budget_set_id is not null

 hr_utility.set_location('PQH Budget Element ID out nocopy '||p_budget_element_id_o, 100);
 hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
  WHEN others THEN
  p_budget_element_id_o := null;
    raise;
END carry_forward_budget_elements;

--------------------------------------------------------------------------------------------------------------
PROCEDURE carry_forward_budget_fund_srcs
(
 p_pqh_budget_fund_srcs_rec    IN  pqh_budget_fund_srcs%ROWTYPE,
 p_budget_element_id           IN  pqh_budget_elements.budget_element_id%TYPE,
 p_budget_fund_src_id_o        OUT NOCOPY pqh_budget_fund_srcs.budget_fund_src_id%TYPE
)
IS
-- local variables and cursors

l_proc                        varchar2(72) := g_package||'carry_forward_budget_fund_srcs';
l_object_version_number       pqh_budget_periods.object_version_number%TYPE;

BEGIN

 hr_utility.set_location('Entering: '||l_proc, 5);

IF p_budget_element_id IS NOT NULL THEN

  -- call insert API
  pqh_budget_fund_srcs_api.create_budget_fund_src
  (
   p_validate                       =>  false
  ,p_budget_fund_src_id             =>  p_budget_fund_src_id_o
  ,p_budget_element_id              =>  p_budget_element_id
  ,p_cost_allocation_keyflex_id     =>  p_pqh_budget_fund_srcs_rec.cost_allocation_keyflex_id
  ,p_project_id                     =>  p_pqh_budget_fund_srcs_rec.project_id
  ,p_award_id                       =>  p_pqh_budget_fund_srcs_rec.award_id
  ,p_task_id                        =>  p_pqh_budget_fund_srcs_rec.task_id
  ,p_expenditure_type               =>  p_pqh_budget_fund_srcs_rec.expenditure_type
  ,p_organization_id                =>  p_pqh_budget_fund_srcs_rec.organization_id
  ,p_distribution_percentage        =>  p_pqh_budget_fund_srcs_rec.distribution_percentage
  ,p_object_version_number          =>  l_object_version_number
 );

END IF; -- p_budget_element_id is not null

 hr_utility.set_location('PQH Budget Fund Src ID out nocopy '||p_budget_fund_src_id_o, 100);
 hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
  WHEN others THEN
p_budget_fund_src_id_o := null;
    raise;
END carry_forward_budget_fund_srcs;

--------------------------------------------------------------------------------------------------------------

PROCEDURE delete_child_rows
(
 p_worksheet_id        IN pqh_worksheets.worksheet_id%TYPE
)
IS

-- local variables and cursors

CURSOR budget_period_id_cur IS
SELECT bpr.budget_period_id
FROM  pqh_worksheets wks, pqh_worksheet_details wdt ,pqh_budget_periods bpr
WHERE wks.worksheet_id = wdt.worksheet_id
  AND wdt.action_cd = 'B'
  AND wdt.budget_detail_id = bpr.budget_detail_id
  AND wks.worksheet_id = p_worksheet_id;

 CURSOR budget_set_id_cur IS
 SELECT bst.budget_set_id
 FROM pqh_budget_sets bst, pqh_budget_periods bpr, pqh_budget_details bdt,
      pqh_worksheet_details wdt , pqh_worksheets wks
 WHERE bst.budget_period_id = bpr.budget_period_id
   AND bpr.budget_detail_id = wdt.budget_detail_id
   AND wks.worksheet_id = wdt.worksheet_id
   AND wdt.action_cd = 'B'
   AND wks.worksheet_id = p_worksheet_id;

 CURSOR budget_element_id_cur IS
 SELECT bel.budget_element_id
 FROM pqh_budget_elements bel, pqh_budget_sets bst,
      pqh_budget_periods bpr,
      pqh_worksheet_details wdt , pqh_worksheets wks
 WHERE bel.budget_set_id = bst.budget_set_id
   AND bst.budget_period_id = bpr.budget_period_id
   AND bpr.budget_detail_id = wdt.budget_detail_id
   AND wks.worksheet_id = wdt.worksheet_id
   AND wdt.action_cd = 'B'
   AND wks.worksheet_id = p_worksheet_id;

 CURSOR budget_fund_src_id_cur IS
 SELECT bfs.budget_fund_src_id
 FROM  pqh_budget_fund_srcs bfs,  pqh_budget_elements bel, pqh_budget_sets bst,
       pqh_budget_periods bpr,
       pqh_worksheet_details wdt , pqh_worksheets wks
 WHERE bfs.budget_element_id = bel.budget_element_id
   AND bel.budget_set_id = bst.budget_set_id
   AND bst.budget_period_id = bpr.budget_period_id
   AND bpr.budget_detail_id = wdt.budget_detail_id
   AND wks.worksheet_id = wdt.worksheet_id
   AND wdt.action_cd = 'B'
   AND wks.worksheet_id = p_worksheet_id;

l_proc                        varchar2(72) := g_package||'delete_child_rows';
l_budget_period_id            pqh_budget_periods.budget_period_id%TYPE;
l_budget_set_id               pqh_budget_sets.budget_set_id%TYPE;
l_budget_element_id           pqh_budget_elements.budget_element_id%TYPE;
l_budget_fund_src_id          pqh_budget_fund_srcs.budget_fund_src_id%TYPE;


BEGIN

 hr_utility.set_location('Entering: '||l_proc, 5);

 -- delete from pqh_budget_fund_srcs

   OPEN budget_fund_src_id_cur;
    LOOP
     FETCH budget_fund_src_id_cur INTO l_budget_fund_src_id;
     EXIT WHEN budget_fund_src_id_cur%NOTFOUND;
       DELETE from pqh_budget_fund_srcs
       WHERE budget_fund_src_id = l_budget_fund_src_id;
    END LOOP;
   CLOSE budget_fund_src_id_cur;

 -- delete from pqh_budget_elements

   OPEN budget_element_id_cur;
    LOOP
     FETCH budget_element_id_cur INTO l_budget_element_id;
     EXIT WHEN budget_element_id_cur%NOTFOUND;
       DELETE from pqh_budget_elements
       WHERE budget_element_id = l_budget_element_id;
    END LOOP;
   CLOSE budget_element_id_cur;

 -- delete from pqh_budget_sets

   OPEN budget_set_id_cur;
    LOOP
     FETCH budget_set_id_cur INTO l_budget_set_id;
     EXIT WHEN budget_set_id_cur%NOTFOUND;
       DELETE from pqh_budget_sets
       WHERE budget_set_id = l_budget_set_id;
    END LOOP;
   CLOSE budget_set_id_cur;

 -- delete from pqh_budget_periods
   OPEN budget_period_id_cur;
    LOOP
     FETCH budget_period_id_cur INTO l_budget_period_id;
     EXIT WHEN budget_period_id_cur%NOTFOUND;
       DELETE from pqh_budget_periods
       WHERE budget_period_id = l_budget_period_id;
    END LOOP;
   CLOSE budget_period_id_cur;


/*
  we update pqh_budget_details and so don't delete due to foreign key constraints

   DELETE FROM pqh_budget_details
   WHERE budget_detail_id IN (
                              SELECT wdt.budget_detail_id
                              FROM pqh_worksheet_details wdt , pqh_worksheets wks
                              WHERE wks.worksheet_id = wdt.worksheet_id
                                AND wdt.budget_detail_id IS NOT NULL
                                AND NVL(wdt.action_cd,'X') = 'B'
                                AND wks.worksheet_id = p_worksheet_id
                              );
*/
 hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
  WHEN others THEN
    raise;
END;


--------------------------------------------------------------------------------------------------------------
PROCEDURE check_valid_mode
(
 p_worksheet_id IN pqh_worksheets.worksheet_id%TYPE
)
IS
/*
   This procedure checks if the worksheet_mode is valid else it will give an
   error message. This will populate the global mode variable
   Now we only have 3 modes ( 02/16/2000 )
   So we will have to determine internally the 4th mode which is W
   check that the worksheet has not been already applied i.e worksheet_status <> APPLIED
*/

-- local variables and cursors

CURSOR pqh_worksheets_cur(p_worksheet_id  IN pqh_worksheets.worksheet_id%TYPE) IS
 SELECT *
 FROM pqh_worksheets
 WHERE worksheet_id = p_worksheet_id;

CURSOR pqh_budget_details_cur(p_budget_version_id   IN pqh_worksheets.budget_version_id%TYPE) is
 SELECT count(*)
 FROM pqh_budget_details
 WHERE budget_version_id = p_budget_version_id;


l_pqh_worksheets_rec          pqh_worksheets%ROWTYPE;
l_proc                        varchar2(72) := g_package||'check_valid_mode';
l_budget_details_count        number;
l_worksheet_status            pqh_worksheets.transaction_status%TYPE;


BEGIN
 hr_utility.set_location('Entering: '||l_proc, 5);

 hr_utility.set_location('Worksheet ID: '||p_worksheet_id, 5);

  -- open pqh_worksheets_cur
  OPEN pqh_worksheets_cur (p_worksheet_id  => p_worksheet_id);
    FETCH pqh_worksheets_cur INTO l_pqh_worksheets_rec;
  CLOSE pqh_worksheets_cur;

  -- populate the global mode_cd variable
   g_worksheet_mode_cd  := l_pqh_worksheets_rec.worksheet_mode_cd;

  -- check if wks already applied then abort the program
    l_worksheet_status := l_pqh_worksheets_rec.transaction_status;
    IF nvl(l_worksheet_status,'X') = 'APPLIED' THEN
         hr_utility.set_message(8302,'PQH_WKS_APPLIED');
         hr_utility.raise_error;
    END IF;

   hr_utility.set_location('Worksheet Mode : '||g_worksheet_mode_cd, 6);

  IF   l_pqh_worksheets_rec.worksheet_mode_cd = 'S' THEN
    -- first version no carry forward i.e NEW or
    -- existing version with no carry forward i.e W

  /*
     since this is the first version, there should be no records in pqh_budget_details with the
     current budget_version_id.
  */
     OPEN pqh_budget_details_cur(p_budget_version_id => l_pqh_worksheets_rec.budget_version_id);
       FETCH pqh_budget_details_cur INTO l_budget_details_count;
     CLOSE pqh_budget_details_cur;

       IF l_budget_details_count <> 0 THEN

         /*
           This is the 'W' mode ie new worksheet
         */

           g_worksheet_mode_cd  := 'W';

       ELSE

           g_worksheet_mode_cd  := 'S';

     /*
           incorrect mode passed , give error
           New mode cannot have budget_detail records

         hr_utility.set_message(8302,'PQH_INVALID_NEW_MODE');
         hr_utility.raise_error;
     */

       END IF;

  ELSIF l_pqh_worksheets_rec.worksheet_mode_cd = 'W' THEN
    -- new version with no carry forward i.e NEW_OVERRIDE
    -- this case is not used from 02/16/2000

    /*
      since this is new override , there must exist atleast one record in budget_detail
      for the current version.
    */
    OPEN pqh_budget_details_cur(p_budget_version_id => l_pqh_worksheets_rec.budget_version_id);
       FETCH pqh_budget_details_cur INTO l_budget_details_count;
     CLOSE pqh_budget_details_cur;

       IF l_budget_details_count = 0 THEN

         /*
           incorrect mode passed , give error
           New override mode must have budget_detail records
         */

         hr_utility.set_message(8302,'PQH_INVALID_OVERRIDE_MODE');
         hr_utility.raise_error;

       ELSE

           g_worksheet_mode_cd  := 'W';

       END IF;

  ELSIF l_pqh_worksheets_rec.worksheet_mode_cd = 'N' THEN
    -- edit existing version and create a new version
    -- with carry forward i.e EDIT_NEW

     /*
       for carry forward , there must be an existing version in budgets table
      */
    OPEN pqh_budget_details_cur(p_budget_version_id => l_pqh_worksheets_rec.budget_version_id);
       FETCH pqh_budget_details_cur INTO l_budget_details_count;
     CLOSE pqh_budget_details_cur;

       IF l_budget_details_count = 0 THEN

         /*
           incorrect mode passed , give error
           Carry forward mode must have budget_detail records
         */

         hr_utility.set_message(8302,'PQH_INVALID_CARRY_MODE');
         hr_utility.raise_error;

       ELSE

           g_worksheet_mode_cd  := 'N';

       END IF;


  ELSIF l_pqh_worksheets_rec.worksheet_mode_cd = 'O' THEN
    -- edit existing version and update the same version
    -- with carry forward i.e EDIT_UPDATE
   /*
      Check if record exists in budget_details for this mode
    */

   OPEN pqh_budget_details_cur(p_budget_version_id => l_pqh_worksheets_rec.budget_version_id);
       FETCH pqh_budget_details_cur INTO l_budget_details_count;
     CLOSE pqh_budget_details_cur;

       IF l_budget_details_count = 0 THEN

         /*
           incorrect mode passed , give error
           Carry forward mode must have budget_detail records
         */

         hr_utility.set_message(8302,'PQH_INVALID_UPDATE_MODE');
         hr_utility.raise_error;

       ELSE

           g_worksheet_mode_cd  := 'O';

       END IF;

  ELSE
    -- invalid mode code
    hr_utility.set_location('Invalid Worksheet Mode : '||g_worksheet_mode_cd, 7);
    hr_utility.set_message(8302,'PQH_INVALID_WORKSHEET_MODE_CD');
    hr_utility.raise_error;
  END IF;

 hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
  WHEN others THEN
    raise;
END;
--------------------------------------------------------------------------------------------------------------
PROCEDURE populate_globals
(
 p_worksheet_id IN pqh_worksheets.worksheet_id%TYPE
) IS

/*
  This procedure will populate all the global variables.
*/

 l_proc                           varchar2(72) := g_package||'populate_globals';
 l_budgets_rec                    pqh_budgets%ROWTYPE;
 l_worksheets_rec                 pqh_worksheets%ROWTYPE;

 CURSOR csr_budget_rec IS
 SELECT *
 FROM pqh_budgets
 WHERE budget_id =
  (
   SELECT b.budget_id
   FROM pqh_budgets b, pqh_worksheets wks
   WHERE wks.worksheet_id = p_worksheet_id
     AND wks.budget_id = b.budget_id
  );

  CURSOR csr_worksheet_rec IS
   SELECT *
   FROM pqh_worksheets
   WHERE worksheet_id = p_worksheet_id ;

 CURSOR csr_table_route (p_table_alias  IN varchar2 )IS
  SELECT table_route_id
  FROM pqh_table_route
  WHERE table_alias =  p_table_alias;

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

  -- get budget units
   OPEN  csr_budget_rec;
     FETCH csr_budget_rec INTO l_budgets_rec;
   CLOSE csr_budget_rec;

     g_budgeted_entity_cd := l_budgets_rec.budgeted_entity_cd;

  hr_utility.set_location('budgeted_entity_cd: '||g_budgeted_entity_cd, 21);


  -- get worksheet mode
    OPEN csr_worksheet_rec;
      FETCH csr_worksheet_rec INTO l_worksheets_rec;
    CLOSE csr_worksheet_rec;

    g_worksheet_name          := l_worksheets_rec.worksheet_name;
    g_worksheet_id            := p_worksheet_id;
    g_transaction_category_id := l_worksheets_rec.wf_transaction_category_id;

   hr_utility.set_location('worksheet_name: '||g_worksheet_name, 30);
   hr_utility.set_location('worksheet_id: '||g_worksheet_id, 40);
   hr_utility.set_location('g_transaction_category_id: '||g_transaction_category_id, 45);

  -- get table_route_id for all the 7 worksheet tables

  -- table_route_id for pqh_worksheets
    OPEN csr_table_route (p_table_alias  => 'WKS');
       FETCH csr_table_route INTO g_table_route_id_wks;
    CLOSE csr_table_route;

  -- table_route_id for pqh_worksheet_details
    OPEN csr_table_route (p_table_alias  => 'WDT');
       FETCH csr_table_route INTO g_table_route_id_wdt;
    CLOSE csr_table_route;

  -- table_route_id for pqh_worksheet_periods
    OPEN csr_table_route (p_table_alias  => 'WPR');
       FETCH csr_table_route INTO g_table_route_id_wpr;
    CLOSE csr_table_route;

  -- table_route_id for pqh_worksheet_budget_sets
    OPEN csr_table_route (p_table_alias  => 'WST');
       FETCH csr_table_route INTO g_table_route_id_wst;
    CLOSE csr_table_route;

  -- table_route_id for pqh_worksheet_bdgt_elmnts
    OPEN csr_table_route (p_table_alias  => 'WEL');
       FETCH csr_table_route INTO g_table_route_id_wel;
    CLOSE csr_table_route;

  -- table_route_id for pqh_worksheet_fund_srcs
    OPEN csr_table_route (p_table_alias  => 'WFS');
       FETCH csr_table_route INTO g_table_route_id_wfs;
    CLOSE csr_table_route;

  hr_utility.set_location('g_table_route_id_wdt: '||g_table_route_id_wdt, 50);
  hr_utility.set_location('g_table_route_id_wpr: '||g_table_route_id_wpr, 60);
  hr_utility.set_location('g_table_route_id_wst: '||g_table_route_id_wst, 70);
  hr_utility.set_location('g_table_route_id_wel: '||g_table_route_id_wel, 80);
  hr_utility.set_location('g_table_route_id_wfs: '||g_table_route_id_wfs, 90);

  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        -- end log and halt the program here
        raise g_error_exception;

END populate_globals;
--------------------------------------------------------------------------------------------------------------
PROCEDURE set_wks_log_context
(
  p_worksheet_detail_id     IN  pqh_worksheet_details.worksheet_detail_id%TYPE,
  p_log_context             OUT NOCOPY pqh_process_log.log_context%TYPE
) IS

/*
  This procedure will set the log_context at wks detail level

  Delegated Record ->  Display Organization Name
  Budgeted Record -> Display name of Primary Budgeted Entity
           OPEN -> Display Order is P J O G ( which ever is not null

*/

 l_proc                           varchar2(72) := g_package||'set_wks_log_context';
 l_worksheet_details_rec          pqh_worksheet_details%ROWTYPE;
 l_position_name                  hr_positions.name%TYPE;
 l_job_name                       per_jobs.name%TYPE;
 l_organization_name              hr_all_organization_units_tl.name%TYPE;
 l_grade_name                     per_grades.name%TYPE;

 CURSOR csr_wks_detail_rec IS
 SELECT *
 FROM pqh_worksheet_details
 WHERE worksheet_detail_id = p_worksheet_detail_id ;

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

  OPEN csr_wks_detail_rec;
    FETCH csr_wks_detail_rec INTO l_worksheet_details_rec;
  CLOSE csr_wks_detail_rec;


  l_position_name := HR_GENERAL.DECODE_POSITION (p_position_id => l_worksheet_details_rec.position_id);
  l_job_name := HR_GENERAL.DECODE_JOB (p_job_id => l_worksheet_details_rec.job_id);
  l_organization_name := HR_GENERAL.DECODE_ORGANIZATION (p_organization_id => l_worksheet_details_rec.organization_id);
  l_grade_name := HR_GENERAL.DECODE_GRADE (p_grade_id => l_worksheet_details_rec.grade_id);

  IF NVL(l_worksheet_details_rec.action_cd , 'R') = 'R' THEN
    -- this is the main parent record , display Organization Name
     p_log_context := SUBSTR(l_organization_name,1,255);
  ELSIF NVL(l_worksheet_details_rec.action_cd , 'R') = 'D' THEN
    -- this is delegated record , display Organization Name
    p_log_context := SUBSTR(l_organization_name,1,255);
  ELSIF NVL(l_worksheet_details_rec.action_cd , 'R') = 'B' THEN
    -- this is budgeted record , display Primary Budgeted Entity
      IF     NVL(g_budgeted_entity_cd ,'OPEN') = 'POSITION' THEN
           p_log_context := SUBSTR(l_position_name,1,255);
      ELSIF  NVL(g_budgeted_entity_cd ,'OPEN') = 'JOB' THEN
           p_log_context := SUBSTR(l_job_name,1,255);
      ELSIF  NVL(g_budgeted_entity_cd ,'OPEN') = 'ORGANIZATION' THEN
           p_log_context := SUBSTR(l_organization_name,1,255);
      ELSIF  NVL(g_budgeted_entity_cd ,'OPEN') = 'GRADE' THEN
           p_log_context := SUBSTR(l_grade_name,1,255);
      ELSIF  NVL(g_budgeted_entity_cd ,'OPEN') = 'OPEN' THEN

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
  END IF;

  hr_utility.set_location('Log Context : '||p_log_context, 100);
  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN

p_log_context := null;
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        -- end log and halt the program here
        raise g_error_exception;
END set_wks_log_context;
--------------------------------------------------------------------------------------------------------------
PROCEDURE set_wpr_log_context
(
  p_worksheet_period_id     IN  pqh_worksheet_periods.worksheet_period_id%TYPE,
  p_log_context             OUT NOCOPY pqh_process_log.log_context%TYPE
) IS
/*
  This procedure will set the log_context at wks periods level

   Display the period start date for start_time_period_id and
   Display the period end date for end_time_period_id
   Table : per_time_periods

*/

 l_proc                           varchar2(72) := g_package||'set_wpr_log_context';
 l_worksheet_periods_rec          pqh_worksheet_periods%ROWTYPE;
 l_per_time_periods               per_time_periods%ROWTYPE;
 l_start_date                     per_time_periods.start_date%TYPE;
 l_end_date                       per_time_periods.end_date%TYPE;

 CURSOR csr_wks_periods_rec IS
 SELECT *
 FROM pqh_worksheet_periods
 WHERE worksheet_period_id = p_worksheet_period_id ;

 CURSOR csr_per_time_periods ( p_time_period_id IN number ) IS
 SELECT *
 FROM per_time_periods
 WHERE time_period_id = p_time_period_id ;

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

  OPEN csr_wks_periods_rec;
    FETCH csr_wks_periods_rec INTO l_worksheet_periods_rec;
  CLOSE csr_wks_periods_rec;

   -- get the start date
  OPEN csr_per_time_periods ( p_time_period_id => l_worksheet_periods_rec.start_time_period_id);
    FETCH csr_per_time_periods INTO l_per_time_periods;
  CLOSE csr_per_time_periods;

    l_start_date := l_per_time_periods.start_date;


   -- get the end date

  OPEN csr_per_time_periods ( p_time_period_id => l_worksheet_periods_rec.end_time_period_id);
    FETCH csr_per_time_periods INTO l_per_time_periods;
  CLOSE csr_per_time_periods;

    l_end_date := l_per_time_periods.end_date;

  -- set log context

    p_log_context := l_start_date||' - '||l_end_date;

  hr_utility.set_location('Log Context : '||p_log_context, 101);
  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN

p_log_context := null;
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        -- end log and halt the program here
        raise g_error_exception;
END set_wpr_log_context;

--------------------------------------------------------------------------------------------------------------
PROCEDURE set_wst_log_context
(
  p_worksheet_budget_set_id     IN  pqh_worksheet_budget_sets.worksheet_budget_set_id%TYPE,
  p_log_context                 OUT NOCOPY pqh_process_log.log_context%TYPE
) IS

/*
  This procedure will set the log_context at wks budget sets level

   Display the DFLT_BUDGET_SET_NAME
   Table : pqh_dflt_budget_sets

*/

 l_proc                           varchar2(72) := g_package||'set_wst_log_context';
 l_worksheet_budget_sets_rec      pqh_worksheet_budget_sets%ROWTYPE;
 l_dflt_budget_sets_rec           pqh_dflt_budget_sets%ROWTYPE;


 CURSOR csr_wks_budget_sets_rec IS
 SELECT *
 FROM pqh_worksheet_budget_sets
 WHERE worksheet_budget_set_id = p_worksheet_budget_set_id;

 CURSOR csr_dflt_budget_sets_rec ( p_dflt_budget_set_id IN number) IS
 SELECT *
 FROM pqh_dflt_budget_sets
 WHERE dflt_budget_set_id = p_dflt_budget_set_id;

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

   OPEN csr_wks_budget_sets_rec;
     FETCH csr_wks_budget_sets_rec INTO l_worksheet_budget_sets_rec;
   CLOSE csr_wks_budget_sets_rec;

    OPEN csr_dflt_budget_sets_rec(p_dflt_budget_set_id => l_worksheet_budget_sets_rec.dflt_budget_set_id);
      FETCH csr_dflt_budget_sets_rec INTO l_dflt_budget_sets_rec;
    CLOSE csr_dflt_budget_sets_rec;

   p_log_context := l_dflt_budget_sets_rec.dflt_budget_set_name;

  hr_utility.set_location('Log Context : '||p_log_context, 101);
  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
      p_log_context := null;
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        -- end log and halt the program here
        raise g_error_exception;
END set_wst_log_context;

--------------------------------------------------------------------------------------------------------------
PROCEDURE set_wel_log_context
(
  p_worksheet_bdgt_elmnt_id     IN  pqh_worksheet_bdgt_elmnts.worksheet_bdgt_elmnt_id%TYPE,
  p_log_context                 OUT NOCOPY pqh_process_log.log_context%TYPE
) IS

/*
  This procedure will set the log_context at wks budget elements level

   Display the ELEMENT_NAME
   Table : pay_element_types

*/

 l_proc                           varchar2(72) := g_package||'set_wel_log_context';

 CURSOR csr_wks_bdgt_elmnts_rec IS
 SELECT *
 FROM pqh_worksheet_bdgt_elmnts
 WHERE worksheet_bdgt_elmnt_id = p_worksheet_bdgt_elmnt_id;

 CURSOR csr_pay_element_types_rec ( p_element_type_id IN number) IS
 SELECT element_name
 FROM pay_element_types_f_tl
 WHERE element_type_id = p_element_type_id
 and language = userenv('LANG');

 l_worksheet_bdgt_elmnts_rec      pqh_worksheet_bdgt_elmnts%ROWTYPE;
 l_pay_element_types_rec          csr_pay_element_types_rec%ROWTYPE;

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

   OPEN csr_wks_bdgt_elmnts_rec;
     FETCH csr_wks_bdgt_elmnts_rec INTO l_worksheet_bdgt_elmnts_rec;
   CLOSE csr_wks_bdgt_elmnts_rec;

    OPEN csr_pay_element_types_rec(p_element_type_id => l_worksheet_bdgt_elmnts_rec.element_type_id);
      FETCH csr_pay_element_types_rec INTO l_pay_element_types_rec;
    CLOSE csr_pay_element_types_rec;

   p_log_context := l_pay_element_types_rec.element_name;

  hr_utility.set_location('Log Context : '||p_log_context, 101);
  hr_utility.set_location('Leaving:'||l_proc, 1000);


EXCEPTION
      WHEN OTHERS THEN
      p_log_context := null;
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        -- end log and halt the program here
        raise g_error_exception;
END set_wel_log_context;

--------------------------------------------------------------------------------------------------------------
PROCEDURE set_wfs_log_context
(
  p_worksheet_fund_src_id       IN  pqh_worksheet_fund_srcs.worksheet_fund_src_id%TYPE,
  p_log_context                 OUT NOCOPY pqh_process_log.log_context%TYPE
) IS

/*
  This procedure will set the log_context at wks budget fund srcs level

   Display the CONCATENATED_SEGMENTS
   Table : pay_cost_allocation_keyflex

*/

 l_proc                            varchar2(72) := g_package||'set_wfs_log_context';
 l_worksheet_fund_srcs_rec         pqh_worksheet_fund_srcs%ROWTYPE;
 l_pay_cost_allocation_kf_rec      pay_cost_allocation_keyflex%ROWTYPE;


 CURSOR csr_wks_bdgt_fund_srcs_rec IS
 SELECT *
 FROM pqh_worksheet_fund_srcs
 WHERE worksheet_fund_src_id = p_worksheet_fund_src_id;

 CURSOR csr_pay_cost_allocation_kf_rec ( p_cost_allocation_keyflex_id IN number) IS
 SELECT *
 FROM pay_cost_allocation_keyflex
 WHERE cost_allocation_keyflex_id = p_cost_allocation_keyflex_id;

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

   OPEN csr_wks_bdgt_fund_srcs_rec;
     FETCH csr_wks_bdgt_fund_srcs_rec INTO l_worksheet_fund_srcs_rec;
   CLOSE csr_wks_bdgt_fund_srcs_rec;

    OPEN csr_pay_cost_allocation_kf_rec(p_cost_allocation_keyflex_id => l_worksheet_fund_srcs_rec.cost_allocation_keyflex_id);
      FETCH csr_pay_cost_allocation_kf_rec INTO l_pay_cost_allocation_kf_rec;
    CLOSE csr_pay_cost_allocation_kf_rec;


   p_log_context := l_pay_cost_allocation_kf_rec.concatenated_segments;


  hr_utility.set_location('Log Context : '||p_log_context, 101);
  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
      p_log_context := null;
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        -- end log and halt the program here
        raise g_error_exception;
END set_wfs_log_context;


--------------------------------------------------------------------------------------------------------------
FUNCTION apply_transaction
(
 p_transaction_id          IN number,
 p_validate_only           IN varchar2
) RETURN varchar2 IS

/*
 This procedure is a wrapper which will be called by workflow. This procedure will call the
 check_wks_errors procedure and if there were no errors and if the p_validate_only is NO then
 call the apply_budget procedure
 If the chk_wks_errors has errors then we will update the wks status to 'APPROVED' from the 'SUBMITTED'
 status

 If p_validate_only is YES then we would only call the check_wks_errors procedure

 p_transaction_id  is the WKS Detail ID

 If the Apply transaction is successful and the budget can be transfered to GL , we would call the
 Apply to GL procedure

*/

 l_proc                            varchar2(72) := g_package||'apply_transaction';
 l_status                          varchar2(30);
 l_wks_detail_rec                  pqh_worksheet_details%ROWTYPE;
 l_return                          varchar2(30) := 'SUCCESS' ;
 l_worksheet_id                    pqh_worksheet_details.worksheet_id%TYPE;
 l_budget_id                       pqh_budgets.budget_id%TYPE;
 l_budget_rec                      pqh_budgets%ROWTYPE;
 l_budget_version_id               pqh_budget_versions.budget_version_id%TYPE;
 l_gl_validation                   varchar2(30);
 l_req                             number(9);
 l_transaction_category_id         number;
 l_transaction_categories_rec      pqh_transaction_categories%ROWTYPE;
 l_pqh_worksheets_rec              pqh_worksheets%ROWTYPE;
 l_txn_state                       varchar2(10);


CURSOR csr_wks_dtl_rec IS
SELECT *
FROM pqh_worksheet_details
WHERE worksheet_detail_id = p_transaction_id;

CURSOR csr_txn_cat_id(p_transaction_category_id in number) IS
SELECT *
FROM pqh_transaction_categories
WHERE transaction_category_id = p_transaction_category_id;

CURSOR csr_wks(p_worksheet_id IN NUMBER)  IS
SELECT *
FROM pqh_worksheets
WHERE worksheet_id = p_worksheet_id;

CURSOR csr_budget_rec(p_budget_id IN NUMBER ) IS
SELECT *
FROM pqh_budgets
WHERE budget_id = p_budget_id;

cursor c1(p_transaction_id in number) is
select wf_transaction_category_id
from pqh_worksheets wks, pqh_worksheet_details wkd
where wks.worksheet_id = wkd.worksheet_id
and wkd.worksheet_detail_id = p_transaction_id;

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

  -- populate global variable g_root_wks_dtl_id and g_transaction_category_id
     g_root_wks_dtl_id  := p_transaction_id;

    OPEN c1(p_transaction_id);
      FETCH c1 INTO l_transaction_category_id;
    CLOSE c1;

    OPEN csr_txn_cat_id(l_transaction_category_id);
      FETCH csr_txn_cat_id INTO l_transaction_categories_rec;
    CLOSE csr_txn_cat_id;

    g_transaction_category_id  := l_transaction_categories_rec.transaction_category_id;

  -- call the chk procedure
    pqh_wks_error_chk.check_wks_errors
    (
     p_worksheet_detail_id  =>  p_transaction_id,
     p_status               =>  l_status
    );

  hr_utility.set_location('Chk Wks Status : '||l_status,10);
  hr_utility.set_location('Validate Only flag : '||p_validate_only,15);

  -- if p_validate_only = 'NO' and the above chk was successful i.e
  -- l_status = SUCCESS then call apply budget

  IF l_status <> 'SUCCESS' THEN

       --
       -- if this is not a validate mode and there were errors in wks then
       -- mark the wks status as APPROVED from SUBMITTED
       --
           IF p_validate_only = 'NO' THEN
            -- get the worksheet ID

               OPEN csr_wks_dtl_rec;
                 FETCH csr_wks_dtl_rec INTO l_wks_detail_rec;
               CLOSE csr_wks_dtl_rec;

               hr_utility.set_location('Changing WKS Status with WKS ID  : '||l_wks_detail_rec.worksheet_id,20);

               -- this is done by Sumit in PQHWSWKS form for txn state = 'I'
               -- if txn state = 'D' then update here

               -- get the wks action date
                  OPEN csr_wks(p_worksheet_id => l_wks_detail_rec.worksheet_id);
                    FETCH csr_wks INTO l_pqh_worksheets_rec;
                  CLOSE csr_wks;

                 l_txn_state := get_txn_state
                              (
                                p_transaction_category_id      =>  g_transaction_category_id,
                                p_action_date                  =>  l_pqh_worksheets_rec.action_date
                              );

               IF NVL(l_txn_state,'I') = 'D' THEN

                      -- update the worksheet status flag to 'APPROVED'

                      updt_wks_status
                      (
                        p_worksheet_id      =>   l_wks_detail_rec.worksheet_id,
                        p_status            =>   'APPROVED'
                      );

               hr_utility.set_location('wks changed with approved '||l_proc,23);
                      updt_wkd_status
                      (
                        p_worksheet_id      =>   l_wks_detail_rec.worksheet_id,
                        p_status            =>   'APPROVED'
                      );
               hr_utility.set_location('wkd changed with approved '||l_proc,26);
               END IF; -- for defered txn state


           END IF; -- not in validate mode and errors


     -- set the error message to see the process log
     pqh_wf.set_apply_error(p_transaction_category_id => g_transaction_category_id,
                            p_transaction_id          => g_root_wks_dtl_id,
                            p_apply_error_mesg        => 'PQH_WKS_CHK_ERRORS',
                            p_apply_error_num         => '1');

     hr_utility.set_location('dberror returned ',18);
     RETURN 'FAILURE';

  END IF;


  IF p_validate_only = 'NO' AND l_status = 'SUCCESS'  THEN

    -- get the worksheet ID

       OPEN csr_wks_dtl_rec;
         FETCH csr_wks_dtl_rec INTO l_wks_detail_rec;
       CLOSE csr_wks_dtl_rec;

    hr_utility.set_location('Calling Apply Budget with WKS ID  : '||l_wks_detail_rec.worksheet_id,20);

    -- create savepoint

    savepoint s1;

    pqh_apply_budget.apply_budget
    (
     p_worksheet_id       => l_wks_detail_rec.worksheet_id,
     p_budget_version_id  => l_budget_version_id
    );

   hr_utility.set_location('Called Apply Budget, Budget Version ID is  '||l_budget_version_id,20);

    --
    -- check if the budget can be transfered to GL , if so POST the budget to GL
    --
    --  get the budget Id from pqh_worksheets
        OPEN csr_wks(p_worksheet_id => l_wks_detail_rec.worksheet_id);
          FETCH csr_wks INTO l_pqh_worksheets_rec;
        CLOSE csr_wks;

      l_budget_id := l_pqh_worksheets_rec.budget_id;

      hr_utility.set_location('Budget ID is '||l_budget_id, 21);

    -- get the budget characteristics
       OPEN csr_budget_rec(p_budget_id  => l_budget_id);
         FETCH csr_budget_rec INTO l_budget_rec;
       CLOSE csr_budget_rec;

    -- if the budget can be transfered to GL then validate do the validations before posting
    -- budget should be marked for transfer to GL and it should not be marked as psb_budget
       IF NVL(l_budget_rec.transfer_to_gl_flag,'N') = 'Y' and l_budget_rec.psb_budget_flag<> 'Y' THEN

          hr_utility.set_location('Calling GL Posting Validate Budget Version ID  : '||l_budget_version_id,25);
          pqh_gl_posting.post_budget
          ( p_budget_version_id  =>  l_budget_version_id,
            p_validate           =>  true ,
            p_status             =>  l_gl_validation
          );

          -- if the validations are successful call the gl posting program
          IF NVL(l_gl_validation,'ERROR') = 'SUCCESS' THEN

             hr_utility.set_location('Calling GL Posting Conc Program ',26);
             l_req := fnd_request.submit_request
                      (application => 'PQH',
                       program     => 'PQHGLPOST' ,
                       argument1   => l_budget_version_id
                      );
               -- check if the program was submitted successfully
               IF NVL(l_req,0) = 0 THEN
                 -- conc program could not be submitted
                 -- ROLLBACK HERE up to Savepoint s1 AND THEN PASS CONTROL TO FORM
                  rollback to s1;
                 hr_utility.set_location('Conc Program could not be submittted  '||l_req, 27);
                -- set the error message to see the process log
                   pqh_wf.set_apply_error(p_transaction_category_id => g_transaction_category_id,
                                          p_transaction_id          => g_root_wks_dtl_id,
                                          p_apply_error_mesg        => 'PQH_CONC_GL_PGM',
                                          p_apply_error_num         => '3');

                   hr_utility.set_location('dberror returned ',27);
                 l_return  := 'FAILURE';
               ELSE
                 hr_utility.set_location('Submitted GL Post Conc Pgm Request '||l_req, 27);
               END IF; -- conc program submit failed
          ELSE
            -- there were errors in gl validation, return error for rollback
            -- ROLLBACK HERE up to Savepoint s1 AND THEN PASS CONTROL TO FORM
             rollback to s1;
             hr_utility.set_location('GL Validation Failed ',26);
                -- set the error message to see the process log
                   pqh_wf.set_apply_error(p_transaction_category_id => g_transaction_category_id,
                                          p_transaction_id          => g_root_wks_dtl_id,
                                          p_apply_error_mesg        => 'PQH_GL_VAL_ERR',
                                          p_apply_error_num         => '3');

                   hr_utility.set_location('dberror returned ',27);
             l_return  := 'FAILURE';
          END IF;
       END IF; -- transfer_to_gl_flag is Y or psb_budget

  END IF;  -- p_validate_only = 'NO' AND l_status = 'SUCCESS'
  hr_utility.set_location('Leaving:'||l_proc, 1000);
  return l_return;

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        -- rollback to s1;
        return 'FAILURE';
        hr_utility.raise_error;
END apply_transaction;

--------------------------------------------------------------------------------------------------------------
PROCEDURE comp_bgt_ver_unit_val
(
 p_budget_version_id           IN  pqh_budget_versions.budget_version_id%TYPE
) IS
/*
   This procedure will be called in the case of Correct the same version i.e worksheet_mode_cd = 'O'
   In this case will will compute the total of all unit values from pqh_budget_details instead of
   pqh_worksheet_details as the user may not have clicked the populate all button in the form in
   which case all budget records may not be there in pqh_worksheet_details table
*/

-- cursor for unit1_value,2,3
CURSOR units_csr IS
SELECT SUM(nvl(BUDGET_UNIT1_VALUE,0)) ,
       SUM(nvl(BUDGET_UNIT2_VALUE,0)) ,
       SUM(nvl(BUDGET_UNIT3_VALUE,0))
FROM pqh_budget_details
WHERE budget_version_id = p_budget_version_id;

-- cursor for OVN for the current budget version record
CURSOR csr_budget_version IS
SELECT *
FROM pqh_budget_versions
WHERE budget_version_id = p_budget_version_id;

-- worksheet cursor is
CURSOR pqh_worksheets_cur(p_worksheet_id  IN pqh_worksheets.worksheet_id%TYPE) IS
 SELECT *
 FROM pqh_worksheets
 WHERE worksheet_id = p_worksheet_id;

 l_proc                            varchar2(72) := g_package||'comp_bgt_ver_unit_val';
 l_budget_unit1_value              pqh_budget_details.budget_unit1_value%TYPE;
 l_budget_unit2_value              pqh_budget_details.budget_unit2_value%TYPE;
 l_budget_unit3_value              pqh_budget_details.budget_unit3_value%TYPE;
 l_pqh_budget_version_rec          pqh_budget_versions%ROWTYPE;
 l_object_version_number           pqh_budget_versions.object_version_number%TYPE;
 l_pqh_worksheets_rec             pqh_worksheets%ROWTYPE;


BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);

 -- compute the unit values
   OPEN units_csr;
     FETCH units_csr INTO l_budget_unit1_value, l_budget_unit2_value, l_budget_unit3_value;
   CLOSE units_csr;

-- get the current OVN of the budget_version record
   OPEN csr_budget_version;
     FETCH csr_budget_version  INTO l_pqh_budget_version_rec;
   CLOSE csr_budget_version;

   l_object_version_number  := l_pqh_budget_version_rec.object_version_number;

-- get the worksheet start and end dates
   OPEN pqh_worksheets_cur(p_worksheet_id => g_worksheet_id);
     FETCH pqh_worksheets_cur INTO l_pqh_worksheets_rec;
   CLOSE pqh_worksheets_cur;

-- call the update API

        pqh_budget_versions_api.update_budget_version
         (
          p_validate                        => false
         ,p_budget_version_id               => l_pqh_budget_version_rec.budget_version_id
         ,p_budget_id                       => l_pqh_budget_version_rec.budget_id
         ,p_version_number                  => l_pqh_budget_version_rec.version_number
         ,p_date_from                       => l_pqh_worksheets_rec.date_from
         ,p_date_to                         => l_pqh_worksheets_rec.date_to
         ,p_transfered_to_gl_flag           => l_pqh_budget_version_rec.transfered_to_gl_flag
         ,p_xfer_to_other_apps_cd           => l_pqh_budget_version_rec.xfer_to_other_apps_cd
         ,p_object_version_number           => l_object_version_number
         ,p_budget_unit1_value              => l_budget_unit1_value
         ,p_budget_unit2_value              => l_budget_unit2_value
         ,p_budget_unit3_value              => l_budget_unit3_value
         ,p_budget_unit1_available          => l_pqh_budget_version_rec.budget_unit1_available
         ,p_budget_unit2_available          => l_pqh_budget_version_rec.budget_unit2_available
         ,p_budget_unit3_available          => l_pqh_budget_version_rec.budget_unit3_available
         ,p_effective_date                  => sysdate
         );


  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END comp_bgt_ver_unit_val;
--------------------------------------------------------------------------------------------------------------

PROCEDURE updt_budget_status
(
 p_budget_id         IN   pqh_budgets.budget_id%TYPE
) IS
/*
 This procedure will update the budget status to FROZEN once the budgte is successfully
 applied
*/

 l_proc                            varchar2(72) := g_package||'updt_budget_status';

CURSOR csr_budget IS
SELECT *
FROM pqh_budgets
WHERE budget_id = p_budget_id
  AND NVL(status,'X') <> 'FROZEN';

l_budget_rec                        pqh_budgets%ROWTYPE;
l_object_version_number             pqh_budgets.object_version_number%TYPE;

BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);

  OPEN csr_budget;
    LOOP
      FETCH csr_budget INTO l_budget_rec;
      EXIT WHEN csr_budget%NOTFOUND;

       l_object_version_number  := l_budget_rec.object_version_number;

       -- call the update API here
       pqh_budgets_api.update_budget
       (
        p_validate                       =>  false
       ,p_budget_id                      =>  p_budget_id
       ,p_object_version_number          =>  l_object_version_number
       ,p_status                         =>  'FROZEN'
       ,p_effective_date                 =>  sysdate
       );


    END LOOP;
  CLOSE csr_budget;


  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END updt_budget_status;



--------------------------------------------------------------------------------------------------------------

PROCEDURE updt_wks_status
(
 p_worksheet_id         IN    pqh_worksheets.worksheet_id%TYPE,
 p_status               IN    pqh_worksheets.transaction_status%TYPE
)  IS
/*
  This procedure will update the wks status to APPLIED after budget is applied successfully
  If the chk wks has error then the wks status will be changed to APPROVED from SUBMITTED
  If the wks has errors then the apply budget will not be called. In this case we will not have
  g_budget_version_id computed.

*/

 l_proc                            varchar2(72) := g_package||'updt_wks_status';


CURSOR csr_wks IS
SELECT *
FROM pqh_worksheets
WHERE worksheet_id = p_worksheet_id;

l_wks_rec                           pqh_worksheets%ROWTYPE;
l_wks_ovn                           pqh_worksheets.object_version_number%TYPE;

BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);

    OPEN csr_wks;
      LOOP
        FETCH csr_wks INTO l_wks_rec;
        EXIT WHEN csr_wks%NOTFOUND;

          l_wks_ovn   :=  l_wks_rec.object_version_number;

          -- call the update API for APPLIED

          IF p_status = 'APPLIED' THEN
            pqh_worksheets_api.update_worksheet
            (
             p_validate                       =>  false
            ,p_worksheet_id                   =>  p_worksheet_id
            ,p_object_version_number          =>  l_wks_ovn
            ,p_transaction_status             =>  p_status
            ,p_budget_version_id              =>  g_budget_version_id
            ,p_effective_date                 =>  sysdate
            );
          ELSE
            -- p_status is APPROVED and we don't have g_budget_version_id

            pqh_worksheets_api.update_worksheet
            (
             p_validate                       =>  false
            ,p_worksheet_id                   =>  p_worksheet_id
            ,p_object_version_number          =>  l_wks_ovn
            ,p_transaction_status             =>  p_status
            ,p_effective_date                 =>  sysdate
            );
          END IF;


      END LOOP;
  CLOSE csr_wks;


  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END updt_wks_status;

--------------------------------------------------------------------------------------------------------------
FUNCTION get_txn_state
(
  p_transaction_category_id      IN number,
  p_action_date                  IN date
) RETURN VARCHAR2 IS
/*
  This function will determine whether the apply_transaction is called in Defered Mode or Immediate Mode
  and return D or I. This will be used by apply_transaction to determine whether to update the wks_status
  to APPROVED from SUBMIT if the wks had errors

In the following matrix , we have used the abbreviations as follows :

Immediate          :  I
Deferred           :  D
Future Dt          :  F
Past or Present Dt : P-P

     *---------------------------------------*
     | Future      | Action   | Post  | Net |
     | Action CD   | Date     | Style |     |
     ----------------------------------------
     |   I         |  P-P     |  I    | I   |
     ----------------------------------------
     |   I         |  P-P     |  D    | D   |
     ----------------------------------------
     |   I         |   F      |  I    | I   |
     ----------------------------------------
     |   I         |   F      |  D    | D   |
     ----------------------------------------
     |   D         |  P-P     |  I    | I   |
     ----------------------------------------
     |   D         |  P-P     |  D    | D   |
     ----------------------------------------
     |   D         |   F      |  I    | D   |
     ----------------------------------------
     |   D         |   F      |  D    | D   |
     ----------------------------------------

*/

 l_proc                            varchar2(72) := g_package||'get_txn_state';
 l_return_state                    varchar2(10);

 l_transaction_categories_rec      pqh_transaction_categories%ROWTYPE;

CURSOR csr_txn_cat_id IS
SELECT *
FROM pqh_transaction_categories
WHERE transaction_category_id = p_transaction_category_id;


BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);

   OPEN csr_txn_cat_id;
     FETCH csr_txn_cat_id INTO l_transaction_categories_rec;
   CLOSE csr_txn_cat_id;

  IF l_transaction_categories_rec.future_action_cd = 'I' AND
     l_transaction_categories_rec.post_style_cd    = 'I' THEN

     RETURN   'I';

  END IF;

  IF l_transaction_categories_rec.future_action_cd = 'D' AND
     l_transaction_categories_rec.post_style_cd    = 'I' AND
     p_action_date   <= sysdate                          THEN

     RETURN   'I';

  END IF;



  hr_utility.set_location('Leaving:'||l_proc, 1000);

  RETURN  'D';

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END get_txn_state;
--------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------------
-- added as per Sir Hon' Lord Sumit Goyalji
--------------------------------------------------------------------------------------------------------------
PROCEDURE complete_all_del_workflow
(
 p_worksheet_id            in number,
 p_transaction_category_id in number
 ) IS

cursor c1 is
select worksheet_detail_id
from pqh_worksheet_details
where worksheet_id = p_worksheet_id
  and nvl(action_cd,'B') ='D';

l_itemkey       varchar2(30);
l_workflow_name varchar2(30);

BEGIN
    l_workflow_name := pqh_wf.get_workflow_name(p_transaction_category_id   => p_transaction_category_id);
    for i in c1 loop
        l_itemkey := to_char(p_transaction_category_id)  || '-' || to_char(i.worksheet_detail_id) ;
        pqh_wf.complete_delegate_workflow(p_itemkey         => l_itemkey,
                                          p_workflow_name   => l_workflow_name);
    end loop;

EXCEPTION
  WHEN others THEN
    raise;
END;
--------------------------------------------------------------------------------------------------------------
FUNCTION chk_root_node
(
 p_transaction_id number
 ) RETURN VARCHAR2 IS
cursor c1 is
select parent_worksheet_detail_id
from pqh_worksheet_details
where worksheet_detail_id = p_transaction_id;

l_parent_id number;
l_result varchar2(30);

BEGIN
     open c1;
     fetch c1 into l_parent_id;
     if c1%notfound then
        hr_utility.set_message(8302,'PQH_INVALID_WKS_TXN_ID');
        hr_utility.raise_error;
     end if;
     close c1;
     if l_parent_id  is null then
        l_result := 'ROOT' ;
     else
        l_result := 'DELEGATE';
     end if;
  RETURN l_result;

EXCEPTION
  WHEN others THEN
    raise;
END;
--------------------------------------------------------------------------------------------------------------
PROCEDURE delegate_approve
(
 p_worksheet_detail_id in number
) IS
   cursor c1 is select status,parent_worksheet_detail_id,
                       budget_unit1_available,budget_unit2_available,budget_unit3_available
                from pqh_worksheet_details
                where worksheet_detail_id = p_worksheet_detail_id
                and action_cd = 'D'
                for update of status;
   cursor c2(p_parent_worksheet_detail_id number) is
                select budget_unit1_available,budget_unit2_available, budget_unit3_available
                from pqh_worksheet_details
                where worksheet_detail_id = p_parent_worksheet_detail_id
                for update of budget_unit1_available,budget_unit2_available, budget_unit3_available;
BEGIN
   for i in c1 loop
      if i.parent_worksheet_detail_id is not null then
         for j in c2(i.parent_worksheet_detail_id) loop
            update pqh_worksheet_details
            set budget_unit1_available = nvl(j.budget_unit1_available,0) + nvl(i.budget_unit1_available,0)
            , budget_unit2_available = nvl(j.budget_unit2_available,0) + nvl(i.budget_unit2_available,0)
            , budget_unit3_available = nvl(j.budget_unit3_available,0) + nvl(i.budget_unit3_available,0)
            where current of c2;
         end loop;
         update pqh_worksheet_details
         set status = 'APPROVED'
         where current of c1;
      else
         hr_utility.set_message(8302,'PQH_INVALID_WKS_TXN_ID');
         hr_utility.raise_error;
      end if;
   end loop;
EXCEPTION
   WHEN others THEN
         hr_utility.set_message(8302,'PQH_INVALID_WKS_TXN_ID');
         hr_utility.raise_error;
END delegate_approve;
procedure build_wks_notice(p_transaction_id    in     number,
                           p_worksheet_name       out nocopy varchar2,
                           p_budget_name          out nocopy varchar2,
                           p_tran_cat_name        out nocopy varchar2,
                           p_organization_name    out nocopy varchar2,
                           p_wks_start_date       out nocopy date,
                           p_wks_end_date         out nocopy date,
                           p_bgt_start_date       out nocopy date,
                           p_bgt_end_date         out nocopy date,
                           p_worksheet_mode       out nocopy varchar2,
                           p_budget_style         out nocopy varchar2,
                           p_budget_entity        out nocopy varchar2,
                           p_budget_version       out nocopy number) is
  l_proc              varchar2(61) := g_package||'build_wks_notice' ;
  l_worksheet_id      number;
  l_organization_id   number;
  l_budget_id         number;
  l_worksheet_mode_cd varchar2(30);
  l_budget_entity_cd  varchar2(30);
  l_budget_style_cd   varchar2(30);
  l_tran_cat_id number;
  cursor c0 is select worksheet_id,organization_id
               from pqh_worksheet_details
               where worksheet_detail_id = p_transaction_id;
  cursor c1 is select budget_id,worksheet_name,version_number,worksheet_mode_cd,date_from,date_to,wf_transaction_category_id
               from pqh_worksheets
               where worksheet_id = l_worksheet_id;
  cursor c2 is select budget_name,budgeted_entity_cd,budget_style_cd,budget_start_date,budget_end_date
               from pqh_budgets
               where budget_id = l_budget_id;
  cursor c3 is select name from pqh_transaction_categories
               where transaction_category_id = l_tran_cat_id;
  cursor c4 is select name from hr_all_organization_units_tl
               where organization_id = l_organization_id
                and language = userenv('LANG');
BEGIN
  hr_utility.set_location('inside build_wks_notice '||l_proc,10);
  open c0;
  fetch c0 into l_worksheet_id,l_organization_id;
  close c0;
  hr_utility.set_location('worksheet detail fetched   '||l_proc,20);
  open c1;
  fetch c1 into l_budget_id,p_worksheet_name,p_budget_version,l_worksheet_mode_cd,p_wks_start_date,p_wks_end_date,l_tran_cat_id;
  close c1;
  hr_utility.set_location('worksheet fetched   '||l_proc,30);
  open c2;
  fetch c2 into p_budget_name,l_budget_entity_cd,l_budget_style_cd,p_bgt_start_date,p_bgt_end_date;
  close c2;
  hr_utility.set_location('budget fetched'||l_proc,40);
  open c3;
  fetch c3 into p_tran_cat_name;
  close c3;
  hr_utility.set_location('tran_cat fetched'||l_proc,50);
  if l_organization_id is not null then
     open c4;
     fetch c4 into p_organization_name;
     close c4;
     hr_utility.set_location('organization fetched'||l_proc,60);
  end if;
  p_budget_style := hr_general.decode_lookup(p_lookup_type => 'PQH_BUDGET_STYLE',
                                             p_lookup_code => l_budget_style_cd);
  p_budget_entity := hr_general.decode_lookup(p_lookup_type => 'PQH_BUDGET_ENTITY',
                                             p_lookup_code => l_budget_entity_cd);
  p_worksheet_mode := hr_general.decode_lookup(p_lookup_type =>'PQH_WORKSHEET_MODE' ,
                                             p_lookup_code =>l_worksheet_mode_cd );
exception
when others then
p_worksheet_name       := null;
p_budget_name          := null;
p_tran_cat_name        := null;
p_organization_name    := null;
p_wks_start_date       := null;
p_wks_end_date         := null;
p_bgt_start_date       := null;
p_bgt_end_date         := null;
p_worksheet_mode       := null;
p_budget_style         := null;
p_budget_entity        := null;
p_budget_version       := null;
end build_wks_notice;
FUNCTION fyi_notification (p_transaction_id in number) RETURN varchar2
is
  l_document          varchar2(4000);
  l_proc              varchar2(61) := g_package||'fyi_notification' ;
  l_budget_name       varchar2(30);
  l_worksheet_name    varchar2(30);
  l_budget_version    number;
  l_worksheet_mode    varchar2(60);
  l_budget_entity     varchar2(30);
  l_budget_style      varchar2(30);
  l_organization_name varchar2(60);
  l_tran_cat_name     varchar2(60);
  l_tran_cat_id       number;
  l_bgt_start_date    date;
  l_bgt_end_date      date;
  l_wks_start_date    date;
  l_wks_end_date      date;
BEGIN
  hr_utility.set_location('inside fyi notification'||l_proc,10);
  build_wks_notice(p_transaction_id    => p_transaction_id,
                   p_worksheet_name    => l_worksheet_name,
                   p_budget_name       => l_budget_name,
                   p_tran_cat_name     => l_tran_cat_name,
                   p_organization_name => l_organization_name,
                   p_wks_start_date    => l_wks_start_date,
                   p_wks_end_date      => l_wks_end_date,
                   p_bgt_start_date    => l_bgt_start_date,
                   p_bgt_end_date      => l_bgt_end_date,
                   p_worksheet_mode    => l_worksheet_mode,
                   p_budget_style      => l_budget_style,
                   p_budget_entity     => l_budget_entity,
                   p_budget_version    => l_budget_version);
  hr_utility.set_message(8302,'PQH_WORKFLOW_FYI_NOTICE');
  hr_utility.set_message_token('WORKSHEET_NAME',l_worksheet_name);
  hr_utility.set_message_token('BUDGET_NAME',l_budget_name);
  hr_utility.set_message_token('TRANSACTION_CATEGORY',l_tran_cat_name);
  hr_utility.set_message_token('BUDGET_VERSION',l_budget_version);
  hr_utility.set_message_token('BUDGET_STYLE',l_budget_style);
  hr_utility.set_message_token('BUDGET_ENTITY',l_budget_entity);
  hr_utility.set_message_token('WORKSHEET_MODE',l_worksheet_mode);
  hr_utility.set_message_token('ORGANIZATION_NAME',l_organization_name);
  hr_utility.set_message_token('BUDGET_START_DATE',l_bgt_start_date);
  hr_utility.set_message_token('BUDGET_END_DATE',l_bgt_end_date);
  hr_utility.set_message_token('WORKSHEET_START_DATE',l_wks_start_date);
  hr_utility.set_message_token('WORKSHEET_END_DATE',l_wks_end_date);
  l_document := hr_utility.get_message;
  return l_document;
exception
  when others then
     hr_utility.set_message(8302,'PQH_WF_FYI_NOTICE_FAIL');
     hr_utility.set_message_token('TRANSACTION_ID',p_transaction_id);
     l_document := hr_utility.get_message;
     return l_document;
END fyi_notification;

FUNCTION back_notification (p_transaction_id in number) RETURN varchar2
is
  l_document          varchar2(4000);
  l_proc              varchar2(61) := g_package||'back_notification' ;
  l_budget_name       varchar2(30);
  l_worksheet_name    varchar2(30);
  l_budget_version    number;
  l_worksheet_mode    varchar2(60);
  l_budget_entity     varchar2(30);
  l_budget_style      varchar2(30);
  l_organization_name varchar2(60);
  l_tran_cat_name     varchar2(60);
  l_tran_cat_id       number;
  l_bgt_start_date    date;
  l_bgt_end_date      date;
  l_wks_start_date    date;
  l_wks_end_date      date;
BEGIN
  hr_utility.set_location('inside back notification'||l_proc,10);
  build_wks_notice(p_transaction_id    => p_transaction_id,
                   p_worksheet_name    => l_worksheet_name,
                   p_budget_name       => l_budget_name,
                   p_tran_cat_name     => l_tran_cat_name,
                   p_organization_name => l_organization_name,
                   p_wks_start_date    => l_wks_start_date,
                   p_wks_end_date      => l_wks_end_date,
                   p_bgt_start_date    => l_bgt_start_date,
                   p_bgt_end_date      => l_bgt_end_date,
                   p_worksheet_mode    => l_worksheet_mode,
                   p_budget_style      => l_budget_style,
                   p_budget_entity     => l_budget_entity,
                   p_budget_version    => l_budget_version);
  hr_utility.set_message(8302,'PQH_WORKFLOW_BACK_NOTICE');
  hr_utility.set_message_token('WORKSHEET_NAME',l_worksheet_name);
  hr_utility.set_message_token('BUDGET_NAME',l_budget_name);
  hr_utility.set_message_token('TRANSACTION_CATEGORY',l_tran_cat_name);
  hr_utility.set_message_token('BUDGET_VERSION',l_budget_version);
  hr_utility.set_message_token('BUDGET_STYLE',l_budget_style);
  hr_utility.set_message_token('BUDGET_ENTITY',l_budget_entity);
  hr_utility.set_message_token('WORKSHEET_MODE',l_worksheet_mode);
  hr_utility.set_message_token('ORGANIZATION_NAME',l_organization_name);
  hr_utility.set_message_token('BUDGET_START_DATE',l_bgt_start_date);
  hr_utility.set_message_token('BUDGET_END_DATE',l_bgt_end_date);
  hr_utility.set_message_token('WORKSHEET_START_DATE',l_wks_start_date);
  hr_utility.set_message_token('WORKSHEET_END_DATE',l_wks_end_date);
  l_document := hr_utility.get_message;
  return l_document;
exception
  when others then
     hr_utility.set_message(8302,'PQH_WF_BACK_NOTICE_FAIL');
     hr_utility.set_message_token('TRANSACTION_ID',p_transaction_id);
     l_document := hr_utility.get_message;
     return l_document;
END back_notification;
FUNCTION override_notification (p_transaction_id in number) RETURN varchar2
is
  l_document          varchar2(4000);
  l_proc              varchar2(61) := g_package||'override_notification' ;
  l_budget_name       varchar2(30);
  l_worksheet_name    varchar2(30);
  l_budget_version    number;
  l_worksheet_mode    varchar2(60);
  l_budget_entity     varchar2(30);
  l_budget_style      varchar2(30);
  l_organization_name varchar2(60);
  l_tran_cat_name     varchar2(60);
  l_tran_cat_id       number;
  l_bgt_start_date    date;
  l_bgt_end_date      date;
  l_wks_start_date    date;
  l_wks_end_date      date;
BEGIN
  hr_utility.set_location('inside override notification'||l_proc,10);
  build_wks_notice(p_transaction_id    => p_transaction_id,
                   p_worksheet_name    => l_worksheet_name,
                   p_budget_name       => l_budget_name,
                   p_tran_cat_name     => l_tran_cat_name,
                   p_organization_name => l_organization_name,
                   p_wks_start_date    => l_wks_start_date,
                   p_wks_end_date      => l_wks_end_date,
                   p_bgt_start_date    => l_bgt_start_date,
                   p_bgt_end_date      => l_bgt_end_date,
                   p_worksheet_mode    => l_worksheet_mode,
                   p_budget_style      => l_budget_style,
                   p_budget_entity     => l_budget_entity,
                   p_budget_version    => l_budget_version);
  hr_utility.set_message(8302,'PQH_WORKFLOW_OVERRIDE_NOTICE');
  hr_utility.set_message_token('WORKSHEET_NAME',l_worksheet_name);
  hr_utility.set_message_token('BUDGET_NAME',l_budget_name);
  hr_utility.set_message_token('TRANSACTION_CATEGORY',l_tran_cat_name);
  hr_utility.set_message_token('BUDGET_VERSION',l_budget_version);
  hr_utility.set_message_token('BUDGET_STYLE',l_budget_style);
  hr_utility.set_message_token('BUDGET_ENTITY',l_budget_entity);
  hr_utility.set_message_token('WORKSHEET_MODE',l_worksheet_mode);
  hr_utility.set_message_token('ORGANIZATION_NAME',l_organization_name);
  hr_utility.set_message_token('BUDGET_START_DATE',l_bgt_start_date);
  hr_utility.set_message_token('BUDGET_END_DATE',l_bgt_end_date);
  hr_utility.set_message_token('WORKSHEET_START_DATE',l_wks_start_date);
  hr_utility.set_message_token('WORKSHEET_END_DATE',l_wks_end_date);
  l_document := hr_utility.get_message;
  return l_document;
exception
  when others then
     hr_utility.set_message(8302,'PQH_WF_OVERRIDE_NOTICE_FAIL');
     hr_utility.set_message_token('TRANSACTION_ID',p_transaction_id);
     l_document := hr_utility.get_message;
     return l_document;
END override_notification;
FUNCTION apply_notification (p_transaction_id in number) RETURN varchar2
is
  l_document          varchar2(4000);
  l_proc              varchar2(61) := g_package||'apply_notification' ;
  l_budget_name       varchar2(30);
  l_worksheet_name    varchar2(30);
  l_budget_version    number;
  l_worksheet_mode    varchar2(60);
  l_budget_entity     varchar2(30);
  l_budget_style      varchar2(30);
  l_organization_name varchar2(60);
  l_tran_cat_name     varchar2(60);
  l_tran_cat_id       number;
  l_bgt_start_date    date;
  l_bgt_end_date      date;
  l_wks_start_date    date;
  l_wks_end_date      date;
BEGIN
  hr_utility.set_location('inside apply notification'||l_proc,10);
  build_wks_notice(p_transaction_id    => p_transaction_id,
                   p_worksheet_name    => l_worksheet_name,
                   p_budget_name       => l_budget_name,
                   p_tran_cat_name     => l_tran_cat_name,
                   p_organization_name => l_organization_name,
                   p_wks_start_date    => l_wks_start_date,
                   p_wks_end_date      => l_wks_end_date,
                   p_bgt_start_date    => l_bgt_start_date,
                   p_bgt_end_date      => l_bgt_end_date,
                   p_worksheet_mode    => l_worksheet_mode,
                   p_budget_style      => l_budget_style,
                   p_budget_entity     => l_budget_entity,
                   p_budget_version    => l_budget_version);
  hr_utility.set_message(8302,'PQH_WORKFLOW_APPLY_NOTICE');
  hr_utility.set_message_token('WORKSHEET_NAME',l_worksheet_name);
  hr_utility.set_message_token('BUDGET_NAME',l_budget_name);
  hr_utility.set_message_token('TRANSACTION_CATEGORY',l_tran_cat_name);
  hr_utility.set_message_token('BUDGET_VERSION',l_budget_version);
  hr_utility.set_message_token('BUDGET_STYLE',l_budget_style);
  hr_utility.set_message_token('BUDGET_ENTITY',l_budget_entity);
  hr_utility.set_message_token('WORKSHEET_MODE',l_worksheet_mode);
  hr_utility.set_message_token('ORGANIZATION_NAME',l_organization_name);
  hr_utility.set_message_token('BUDGET_START_DATE',l_bgt_start_date);
  hr_utility.set_message_token('BUDGET_END_DATE',l_bgt_end_date);
  hr_utility.set_message_token('WORKSHEET_START_DATE',l_wks_start_date);
  hr_utility.set_message_token('WORKSHEET_END_DATE',l_wks_end_date);
  l_document := hr_utility.get_message;
  return l_document;
exception
  when others then
     hr_utility.set_message(8302,'PQH_WF_APPLY_NOTICE_FAIL');
     hr_utility.set_message_token('TRANSACTION_ID',p_transaction_id);
     l_document := hr_utility.get_message;
     return l_document;
END apply_notification;
FUNCTION reject_notification (p_transaction_id in number) RETURN varchar2
is
  l_document          varchar2(4000);
  l_proc              varchar2(61) := g_package||'reject_notification' ;
  l_budget_name       varchar2(30);
  l_worksheet_name    varchar2(30);
  l_budget_version    number;
  l_worksheet_mode    varchar2(60);
  l_budget_entity     varchar2(30);
  l_budget_style      varchar2(30);
  l_organization_name varchar2(60);
  l_tran_cat_name     varchar2(60);
  l_tran_cat_id       number;
  l_bgt_start_date    date;
  l_bgt_end_date      date;
  l_wks_start_date    date;
  l_wks_end_date      date;
BEGIN
  hr_utility.set_location('inside reject notification'||l_proc,10);
  build_wks_notice(p_transaction_id    => p_transaction_id,
                   p_worksheet_name    => l_worksheet_name,
                   p_budget_name       => l_budget_name,
                   p_tran_cat_name     => l_tran_cat_name,
                   p_organization_name => l_organization_name,
                   p_wks_start_date    => l_wks_start_date,
                   p_wks_end_date      => l_wks_end_date,
                   p_bgt_start_date    => l_bgt_start_date,
                   p_bgt_end_date      => l_bgt_end_date,
                   p_worksheet_mode    => l_worksheet_mode,
                   p_budget_style      => l_budget_style,
                   p_budget_entity     => l_budget_entity,
                   p_budget_version    => l_budget_version);
  hr_utility.set_message(8302,'PQH_WORKFLOW_REJECT_NOTICE');
  hr_utility.set_message_token('WORKSHEET_NAME',l_worksheet_name);
  hr_utility.set_message_token('BUDGET_NAME',l_budget_name);
  hr_utility.set_message_token('TRANSACTION_CATEGORY',l_tran_cat_name);
  hr_utility.set_message_token('BUDGET_VERSION',l_budget_version);
  hr_utility.set_message_token('BUDGET_STYLE',l_budget_style);
  hr_utility.set_message_token('BUDGET_ENTITY',l_budget_entity);
  hr_utility.set_message_token('WORKSHEET_MODE',l_worksheet_mode);
  hr_utility.set_message_token('ORGANIZATION_NAME',l_organization_name);
  hr_utility.set_message_token('BUDGET_START_DATE',l_bgt_start_date);
  hr_utility.set_message_token('BUDGET_END_DATE',l_bgt_end_date);
  hr_utility.set_message_token('WORKSHEET_START_DATE',l_wks_start_date);
  hr_utility.set_message_token('WORKSHEET_END_DATE',l_wks_end_date);
  l_document := hr_utility.get_message;
  return l_document;
exception
  when others then
     hr_utility.set_message(8302,'PQH_WF_REJECT_NOTICE_FAIL');
     hr_utility.set_message_token('TRANSACTION_ID',p_transaction_id);
     l_document := hr_utility.get_message;
     return l_document;
END reject_notification;
FUNCTION warning_notification (p_transaction_id in number) RETURN varchar2
is
  l_document          varchar2(4000);
  l_proc              varchar2(61) := g_package||'warning_notification' ;
  l_budget_name       varchar2(30);
  l_worksheet_name    varchar2(30);
  l_budget_version    number;
  l_worksheet_mode    varchar2(60);
  l_budget_entity     varchar2(30);
  l_budget_style      varchar2(30);
  l_organization_name varchar2(60);
  l_tran_cat_name     varchar2(60);
  l_tran_cat_id       number;
  l_bgt_start_date    date;
  l_bgt_end_date      date;
  l_wks_start_date    date;
  l_wks_end_date      date;
BEGIN
  hr_utility.set_location('inside warning notification'||l_proc,10);
  build_wks_notice(p_transaction_id    => p_transaction_id,
                   p_worksheet_name    => l_worksheet_name,
                   p_budget_name       => l_budget_name,
                   p_tran_cat_name     => l_tran_cat_name,
                   p_organization_name => l_organization_name,
                   p_wks_start_date    => l_wks_start_date,
                   p_wks_end_date      => l_wks_end_date,
                   p_bgt_start_date    => l_bgt_start_date,
                   p_bgt_end_date      => l_bgt_end_date,
                   p_worksheet_mode    => l_worksheet_mode,
                   p_budget_style      => l_budget_style,
                   p_budget_entity     => l_budget_entity,
                   p_budget_version    => l_budget_version);
  hr_utility.set_message(8302,'PQH_WORKFLOW_WARNING_NOTICE');
  hr_utility.set_message_token('WORKSHEET_NAME',l_worksheet_name);
  hr_utility.set_message_token('BUDGET_NAME',l_budget_name);
  hr_utility.set_message_token('TRANSACTION_CATEGORY',l_tran_cat_name);
  hr_utility.set_message_token('BUDGET_VERSION',l_budget_version);
  hr_utility.set_message_token('BUDGET_STYLE',l_budget_style);
  hr_utility.set_message_token('BUDGET_ENTITY',l_budget_entity);
  hr_utility.set_message_token('WORKSHEET_MODE',l_worksheet_mode);
  hr_utility.set_message_token('ORGANIZATION_NAME',l_organization_name);
  hr_utility.set_message_token('BUDGET_START_DATE',l_bgt_start_date);
  hr_utility.set_message_token('BUDGET_END_DATE',l_bgt_end_date);
  hr_utility.set_message_token('WORKSHEET_START_DATE',l_wks_start_date);
  hr_utility.set_message_token('WORKSHEET_END_DATE',l_wks_end_date);
  l_document := hr_utility.get_message;
  return l_document;
exception
  when others then
     hr_utility.set_message(8302,'PQH_WF_WARNING_NOTICE_FAIL');
     hr_utility.set_message_token('TRANSACTION_ID',p_transaction_id);
     l_document := hr_utility.get_message;
     return l_document;
END warning_notification;
FUNCTION respond_notification (p_transaction_id in number) RETURN varchar2
is
  l_document          varchar2(4000);
  l_proc              varchar2(61) := g_package||'respond_notification' ;
  l_budget_name       varchar2(30);
  l_worksheet_name    varchar2(30);
  l_budget_version    number;
  l_worksheet_mode    varchar2(60);
  l_budget_entity     varchar2(30);
  l_budget_style      varchar2(30);
  l_organization_name varchar2(60);
  l_tran_cat_name     varchar2(60);
  l_tran_cat_id       number;
  l_bgt_start_date    date;
  l_bgt_end_date      date;
  l_wks_start_date    date;
  l_wks_end_date      date;
BEGIN
  hr_utility.set_location('inside respond notification'||l_proc,10);
  build_wks_notice(p_transaction_id    => p_transaction_id,
                   p_worksheet_name    => l_worksheet_name,
                   p_budget_name       => l_budget_name,
                   p_tran_cat_name     => l_tran_cat_name,
                   p_organization_name => l_organization_name,
                   p_wks_start_date    => l_wks_start_date,
                   p_wks_end_date      => l_wks_end_date,
                   p_bgt_start_date    => l_bgt_start_date,
                   p_bgt_end_date      => l_bgt_end_date,
                   p_worksheet_mode    => l_worksheet_mode,
                   p_budget_style      => l_budget_style,
                   p_budget_entity     => l_budget_entity,
                   p_budget_version    => l_budget_version);
  hr_utility.set_message(8302,'PQH_WORKFLOW_RESPOND_NOTICE');
  hr_utility.set_message_token('WORKSHEET_NAME',l_worksheet_name);
  hr_utility.set_message_token('BUDGET_NAME',l_budget_name);
  hr_utility.set_message_token('TRANSACTION_CATEGORY',l_tran_cat_name);
  hr_utility.set_message_token('BUDGET_VERSION',l_budget_version);
  hr_utility.set_message_token('BUDGET_STYLE',l_budget_style);
  hr_utility.set_message_token('BUDGET_ENTITY',l_budget_entity);
  hr_utility.set_message_token('WORKSHEET_MODE',l_worksheet_mode);
  hr_utility.set_message_token('ORGANIZATION_NAME',l_organization_name);
  hr_utility.set_message_token('BUDGET_START_DATE',l_bgt_start_date);
  hr_utility.set_message_token('BUDGET_END_DATE',l_bgt_end_date);
  hr_utility.set_message_token('WORKSHEET_START_DATE',l_wks_start_date);
  hr_utility.set_message_token('WORKSHEET_END_DATE',l_wks_end_date);
  l_document := hr_utility.get_message;
  return l_document;
exception
  when others then
     hr_utility.set_message(8302,'PQH_WF_RESPOND_NOTICE_FAIL');
     hr_utility.set_message_token('TRANSACTION_ID',p_transaction_id);
     l_document := hr_utility.get_message;
     return l_document;
END respond_notification;
--------------------------------------------------------------------------------------------------------------
-- end added by Sumit Goyal
--------------------------------------------------------------------------------------------------------------

-- added as per Dinesh's rqmt
--------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------

FUNCTION set_status
(
 p_transaction_category_id       IN    pqh_transaction_categories.transaction_category_id%TYPE,
 p_transaction_id                IN    pqh_worksheets.worksheet_id%TYPE,
 p_status                        IN    pqh_worksheets.transaction_status%TYPE
) RETURN varchar2 IS
/*
   This procedure will update the wks status and wks detail status
*/

 l_proc                            varchar2(72) := g_package||'set_status';

-- commented to remove dependency on pqh_transactions_v
-- cursor c1 is select transaction_id,parent_transaction_id,transaction_status
-- from pqh_transactions_v
-- where parent_transaction_id = p_transaction_id
-- and parent_transaction_id <> transaction_id
-- and transaction_category_id = p_transaction_category_id
-- and NVL(transaction_status,'X')  <> p_status;
--

cursor c1 is select wkd.worksheet_detail_id transaction_id,
                    wkd.parent_worksheet_detail_id parent_transaction_id,
                    wkd.status transaction_status
from pqh_worksheet_details wkd, pqh_worksheets wks
where parent_worksheet_detail_id = p_transaction_id
and parent_worksheet_detail_id <> worksheet_detail_id
and wkd.worksheet_id = wks.worksheet_id
and wks.wf_transaction_category_id = p_transaction_category_id
and NVL(wkd.status,'X')  <> p_status;

CURSOR csr_wks IS
SELECT wks.*
FROM pqh_worksheets wks
, pqh_worksheet_details wkd
WHERE wkd.worksheet_detail_id = p_transaction_id
and   wks.worksheet_id        = wkd.worksheet_id;

CURSOR csr_wdt IS
SELECT wdt.*
FROM pqh_worksheet_details wdt
WHERE wdt.worksheet_detail_id = p_transaction_id;

l_wks_rec                           pqh_worksheets%ROWTYPE;
l_wdt_rec                           pqh_worksheet_details%ROWTYPE;
l_object_version_number             pqh_worksheets.object_version_number%TYPE;
l_object_version_number_wdt         pqh_worksheet_details.object_version_number%TYPE;
l_do_action boolean := FALSE;
l_return_status                     varchar2(20);

BEGIN
   hr_utility.set_location('Entering:'||p_transaction_id||l_proc, 5);
   for i in c1 loop
      hr_utility.set_location('calling:'||i.transaction_id||l_proc, 10);
      l_return_status := set_status(p_transaction_category_id => p_transaction_category_id,
                                    p_transaction_id          => i.transaction_id,
                                    p_status                  => p_status );
   end loop; -- for loop
   OPEN csr_wdt;
   FETCH csr_wdt INTO l_wdt_rec;
   CLOSE csr_wdt;
   if l_wdt_rec.parent_worksheet_detail_id is null and l_wdt_rec.status in ('PENDING','APPROVED','SUBMITTED') then
      l_do_action := TRUE;
   elsif l_wdt_rec.parent_worksheet_detail_id is not null and l_wdt_rec.status in ('DELEGATED','PENDING') then
      l_do_action := TRUE;
   else
      l_do_action := FALSE;
   end if;
   if l_do_action then
      if l_wdt_rec.parent_worksheet_detail_id is not null and l_wdt_rec.status ='PENDING' then
         hr_utility.set_location('changing just stat'||l_proc, 10);
      else
         BEGIN
            wf_engine.AbortProcess
            (itemtype  => 'PQHGEN',
            itemkey    => p_transaction_category_id || '-' || p_transaction_id,
            process    => 'PQH_ROUTING',
            result     => null
            );
         EXCEPTION
           WHEN OTHERS THEN
              null;
         END ; -- for abort process
      end if;
      l_object_version_number_wdt := l_wdt_rec.object_version_number;
      pqh_worksheet_details_api.update_worksheet_detail
         (
         p_validate                       =>  false
         ,p_worksheet_detail_id            =>  p_transaction_id
         ,p_object_version_number          =>  l_object_version_number_wdt
         ,p_status                         =>  p_status
         ,p_effective_date                 =>  sysdate
         );
      if l_wdt_rec.parent_worksheet_detail_id is null then
         OPEN csr_wks;
         FETCH csr_wks INTO l_wks_rec;
         CLOSE csr_wks;
         l_object_version_number   :=  l_wks_rec.object_version_number;
         pqh_worksheets_api.update_worksheet
            (
            p_validate                       =>  false
            ,p_worksheet_id                   =>  l_wks_rec.worksheet_id
            ,p_object_version_number          =>  l_object_version_number
            ,p_transaction_status             =>  p_status
            ,p_effective_date                 =>  sysdate
            );
      end if;
   end if;
   hr_utility.set_location('Leaving:'||l_proc, 1000);
   RETURN 'SUCCESS';
EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
        hr_utility.set_location('Leaving: EXCEPTION '||l_proc, 1000);
        RETURN 'FAILURE';
END set_status;


--------------------------------------------------------------------------------------------------------------

END; -- Package Body PQH_APPLY_BUDGET

/
