--------------------------------------------------------
--  DDL for Package Body PQH_WKS_ERROR_CHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_WKS_ERROR_CHK" AS
/* $Header: pqwkserr.pkb 115.27 2004/06/15 13:58:59 rthiagar ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_wks_error_chk.';  -- Global package name
--
g_budget_unit1_id          pqh_budgets.budget_unit1_id%TYPE;
g_budget_unit2_id          pqh_budgets.budget_unit2_id%TYPE;
g_budget_unit3_id          pqh_budgets.budget_unit3_id%TYPE;
g_budgeted_entity_cd       pqh_budgets.budgeted_entity_cd%TYPE;
g_budget_name              pqh_budgets.budget_name%TYPE;
g_worksheet_mode_cd        pqh_worksheets.worksheet_mode_cd%TYPE;
g_table_route_id_wdt       NUMBER;
g_table_route_id_wpr       NUMBER;
g_table_route_id_wst       NUMBER;
g_table_route_id_wel       NUMBER;
g_table_route_id_wfs       NUMBER;
g_worksheet_name           pqh_worksheets.worksheet_name%TYPE;
g_worksheet_id             pqh_worksheets.worksheet_id%TYPE;
g_error_exception          exception;
g_curr_wks_dtl_level       NUMBER;
g_batch_status             VARCHAR2(30);
g_position_control         pqh_budgets.position_control_flag%TYPE;
g_budget_id                pqh_budgets.budget_id%TYPE;
g_budget_start_dt          pqh_budgets.budget_start_date%TYPE;
g_budget_end_dt            pqh_budgets.budget_end_date%TYPE;
g_budget_unit1_aggregate   pqh_budgets.budget_unit1_aggregate%TYPE;
g_budget_unit2_aggregate   pqh_budgets.budget_unit2_aggregate%TYPE;
g_budget_unit3_aggregate   pqh_budgets.budget_unit3_aggregate%TYPE;
g_budget_style_cd          pqh_budgets.budget_style_cd%TYPE;
g_context_organization_id  number;

function get_organization_id (p_worksheet_detail_id in number) return number is
   l_position_id number;
   l_job_id number;
   l_grade_id number;
   l_organization_id number;
   l_position_transaction_id number;
   l_res_organization_id number;
   cursor c1 is select position_id,organization_id,job_id,grade_id,position_transaction_id
                from pqh_worksheet_details
                where worksheet_detail_id = p_worksheet_detail_id;
   cursor c2 is select business_group_id from hr_positions
                where position_id = l_position_id;
   cursor c3 is select business_group_id from per_jobs
                where job_id = l_job_id;
   cursor c4 is select business_group_id from per_grades
                where grade_id = l_grade_id;
   cursor c5 is select business_group_id from pqh_position_transactions
                where position_transaction_id = l_position_transaction_id;
begin
   open c1;
   fetch c1 into l_position_id,l_organization_id,l_job_id,l_grade_id,l_position_transaction_id;
   close c1;
   if l_organization_id is null then
      if l_position_id is not null then
         open c2;
         fetch c2 into l_res_organization_id;
         close c2;
      elsif l_job_id is not null then
         open c3;
         fetch c3 into l_res_organization_id;
         close c3;
      elsif l_grade_id is not null then
         open c4;
         fetch c4 into l_res_organization_id;
         close c4;
      elsif l_position_transaction_id is not null then
         open c5;
         fetch c5 into l_res_organization_id;
         close c5;
      end if;
   else
      l_res_organization_id := l_organization_id;
   end if;
   return l_res_organization_id;
end get_organization_id;





--
    /*----------------------------------------------------------------
    || PROCEDURE : check_wks_errors  -- This is the MAIN procedure
    ||
    ------------------------------------------------------------------*/

PROCEDURE check_wks_errors
(
  p_worksheet_detail_id     IN pqh_worksheet_details.worksheet_detail_id%TYPE,
  p_status                  OUT NOCOPY varchar2
) IS
/*

  p_status = SUCCESS if no errors for the batch else it is ERROR or WARNING

*/
-- local variables and cursors

CURSOR pqh_worksheet_details_cur  IS
 SELECT  level, wdt.*
 FROM pqh_worksheet_details wdt
 START WITH worksheet_detail_id = p_worksheet_detail_id
 CONNECT BY prior worksheet_detail_id = parent_worksheet_detail_id ;

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

CURSOR wks_detail_id_input_cur  IS
 SELECT  *
 FROM pqh_worksheet_details
 WHERE worksheet_detail_id = p_worksheet_detail_id;


l_proc                           varchar2(72) := g_package||'check_wks_errors';
l_pqh_worksheets_rec             pqh_worksheets%ROWTYPE;
l_pqh_worksheet_details_rec      pqh_worksheet_details%ROWTYPE;
l_pqh_worksheet_periods_rec      pqh_worksheet_periods%ROWTYPE;
l_pqh_worksheet_budget_set_rec   pqh_worksheet_budget_sets%ROWTYPE;
l_pqh_worksheet_bdgt_elmnt_rec   pqh_worksheet_bdgt_elmnts%ROWTYPE;
l_pqh_worksheet_fund_srcs_rec    pqh_worksheet_fund_srcs%ROWTYPE;
l_message_text                   pqh_process_log.message_text%TYPE;
l_message_text_out               fnd_new_messages.message_text%TYPE;
l_message_number_out             fnd_new_messages.message_number%TYPE;
l_log_context                    pqh_process_log.log_context%TYPE;
l_pqh_worksheet_details_c_rec    pqh_worksheet_details_cur%ROWTYPE;
l_level                          number;
l_batch_id                       number;
l_batch_context                  varchar2(2000);
l_date_status                    varchar2(10);


BEGIN

  hr_utility.set_location('Entering: '||l_proc, 5);

   -- populate the globals
     populate_globals
     (
      p_worksheet_detail_id     =>  p_worksheet_detail_id
      );

   -- compute batch id and batch context
   -- Batch Id will be the WKS Detail ID passed to the pgm
   -- Batch Context is worksheet dtl id context 03/28/2000

      l_batch_id := p_worksheet_detail_id;

     -- get log_context for the batch
      set_wks_log_context
      (
       p_worksheet_detail_id     => p_worksheet_detail_id,
       p_log_context             => l_log_context
      );

      l_batch_context := l_log_context;

   -- Start the Log Process
     pqh_process_batch_log.start_log
     (
      p_batch_id       => l_batch_id,
      p_module_cd      => 'APPROVE_WORKSHEET',
      p_log_context    => l_batch_context
     );

  -- check that the worksheet_detail_id is root or delegated record else error and exit
    OPEN wks_detail_id_input_cur;
      FETCH wks_detail_id_input_cur INTO l_pqh_worksheet_details_rec;
    CLOSE wks_detail_id_input_cur;

/*
     -- get log_context
      set_wks_log_context
      (
       p_worksheet_detail_id     => p_worksheet_detail_id,
       p_log_context             => l_log_context
      );

      -- set the context before inserting error
        pqh_process_batch_log.set_context_level
        (
          p_txn_id                =>  p_worksheet_detail_id,
          p_txn_table_route_id    =>  g_table_route_id_wdt,
          p_level                 =>  1,
          p_log_context           =>  l_log_context
        );

*/
       -- main check for input action cd in D or R
       IF NVL(l_pqh_worksheet_details_rec.action_cd,'R')  NOT IN ('D', 'R') THEN

          -- get message text for PQH_WKS_INVALID_ID
           FND_MESSAGE.SET_NAME('PQH','PQH_WKS_INVALID_ID');
           l_message_text_out := FND_MESSAGE.GET;

           l_message_text := l_message_text_out;

/*
          -- insert error message
            pqh_process_batch_log.insert_log
            (
              p_message_type_cd    =>  'ERROR',
              p_message_text       =>  l_message_text
            );
*/

          -- end log and HALT the program here
           raise g_error_exception;

       END IF; -- main check for input action cd in D or R

       -- check the worksheet dates
       check_wks_dates
       (
         p_worksheet_detail_id     => p_worksheet_detail_id,
         p_status                  => l_date_status,
         p_message                 => l_message_text
       );

       IF NVL(l_date_status,'ERROR') = 'ERROR' THEN
           -- end log and HALT the program here
           raise g_error_exception;
       END IF; -- valid wks dates

    -- open pqh_worksheet_details_cur
    OPEN pqh_worksheet_details_cur ;
      LOOP  -- loop 1
        FETCH pqh_worksheet_details_cur INTO  l_pqh_worksheet_details_c_rec;
        EXIT WHEN pqh_worksheet_details_cur%NOTFOUND;

           -- current level
             l_level := l_pqh_worksheet_details_c_rec.level ;

           -- populate the global for current level
           -- as wks detail is now the batch , actual level will be one less
            g_curr_wks_dtl_level := l_pqh_worksheet_details_c_rec.level - 1;

           IF g_curr_wks_dtl_level  <> 0 THEN
           -- this is NOT THE ROOT NODE

             -- get log_context
              set_wks_log_context
              (
                p_worksheet_detail_id     => l_pqh_worksheet_details_c_rec.worksheet_detail_id,
                p_log_context             => l_log_context
               );

             -- set the context
               pqh_process_batch_log.set_context_level
               (
                p_txn_id                =>  l_pqh_worksheet_details_c_rec.worksheet_detail_id,
                p_txn_table_route_id    =>  g_table_route_id_wdt,
                p_level                 =>  g_curr_wks_dtl_level,
                p_log_context           =>  l_log_context
                );

              -- check level1 rows of the worksheet_detail_id for Delegated OR Root record ONLY
                 IF NVL(l_pqh_worksheet_details_c_rec.action_cd,'R') IN ('D','R') THEN
                     check_level1_rows
                     (
                      p_worksheet_detail_id     =>  l_pqh_worksheet_details_c_rec.worksheet_detail_id
                      );
                  END IF;

             check_wks_details
             (
              p_worksheet_detail_id     =>  l_pqh_worksheet_details_c_rec.worksheet_detail_id
             );

          ELSE
            -- this is the ROOT INPUT NODE

              -- check level1 rows of the worksheet_detail_id for Delegated OR Root record ONLY
                 IF NVL(l_pqh_worksheet_details_c_rec.action_cd,'R') IN ('D','R') THEN
                     check_level1_rows
                     (
                      p_worksheet_detail_id     =>  l_pqh_worksheet_details_c_rec.worksheet_detail_id
                      );
                  END IF;

                check_input_wks_details
                (
                 p_worksheet_detail_id     =>  l_pqh_worksheet_details_c_rec.worksheet_detail_id
                );

          END IF;  -- for root node

          g_context_organization_id := get_organization_id(p_worksheet_detail_id => l_pqh_worksheet_details_c_rec.worksheet_detail_id);
         -- For app periods level = g_curr_wks_dtl_level + 1


        -- open pqh_worksheet_periods_cur
        OPEN pqh_worksheet_periods_cur(p_worksheet_detail_id  => l_pqh_worksheet_details_c_rec.worksheet_detail_id);
           LOOP -- loop 2
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
                 p_level                 =>  g_curr_wks_dtl_level + 1,
                 p_log_context           =>  l_log_context
                 );

                check_wks_periods
                (
                  p_worksheet_detail_id     =>  l_pqh_worksheet_periods_rec.worksheet_detail_id,
                  p_worksheet_period_id     =>  l_pqh_worksheet_periods_rec.worksheet_period_id
                 );

         -- For all budget sets , current level = g_curr_wks_dtl_level + 2

         -- open pqh_worksheet_budget_sets_cur
          OPEN pqh_worksheet_budget_sets_cur(p_worksheet_period_id  => l_pqh_worksheet_periods_rec.worksheet_period_id);
             LOOP  -- loop 3
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
                   p_level                 =>  g_curr_wks_dtl_level + 2,
                   p_log_context           =>  l_log_context
                   );

                 check_wks_budget_sets
                 (
                  p_worksheet_period_id     =>  l_pqh_worksheet_budget_set_rec.worksheet_period_id,
                  p_worksheet_budget_set_id =>  l_pqh_worksheet_budget_set_rec.worksheet_budget_set_id
                 );

            -- For all elements current level = g_curr_wks_dtl_level + 3

            -- open pqh_worksheet_bdgt_elmnts_cur
              OPEN pqh_worksheet_bdgt_elmnts_cur(p_worksheet_budget_set_id  => l_pqh_worksheet_budget_set_rec.worksheet_budget_set_id);
                 LOOP  -- loop 4
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
                      p_level                 =>  g_curr_wks_dtl_level + 3,
                      p_log_context           =>  l_log_context
                     );

                     check_wks_budget_elements
                     (
                       p_worksheet_budget_set_id   =>  l_pqh_worksheet_bdgt_elmnt_rec.worksheet_budget_set_id,
                       p_worksheet_bdgt_elmnt_id   =>  l_pqh_worksheet_bdgt_elmnt_rec.worksheet_bdgt_elmnt_id
                      );

                -- For all funding srcs current level = g_curr_wks_dtl_level + 4

                -- open pqh_worksheet_fund_srcs_cur
                  OPEN pqh_worksheet_fund_srcs_cur(p_worksheet_bdgt_elmnt_id  => l_pqh_worksheet_bdgt_elmnt_rec.worksheet_bdgt_elmnt_id);
                     LOOP -- loop 5
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
                          p_level                 =>  g_curr_wks_dtl_level + 4,
                          p_log_context           =>  l_log_context
                          );

                          check_wks_fund_srcs
                           (
                            p_worksheet_bdgt_elmnt_id   =>  l_pqh_worksheet_fund_srcs_rec.worksheet_bdgt_elmnt_id,
                            p_worksheet_fund_src_id     =>  l_pqh_worksheet_fund_srcs_rec.worksheet_fund_src_id
                            );


                      END LOOP; -- loop 5
                  CLOSE pqh_worksheet_fund_srcs_cur;

                END LOOP; -- loop 4
             CLOSE pqh_worksheet_bdgt_elmnts_cur;

           END LOOP;  -- loop 3
         CLOSE pqh_worksheet_budget_sets_cur;

       END LOOP; -- loop 2
      CLOSE pqh_worksheet_periods_cur;

     END LOOP; -- loop 1
    CLOSE pqh_worksheet_details_cur;


  -- commit propogation
  --  commit;

  -- end the error log process
    end_log;

  -- populate the out param
   p_status := g_batch_status;


  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
  WHEN g_error_exception THEN
    -- update the out varchar
       p_status := 'ERROR';
    -- call the end log and stop
    -- pqh_process_batch_log.end_log;
    -- now we don't call the end log as there is no batch here
       updt_batch
       (
         p_message_text => l_message_text
       );
    --   UPDATE pqh_process_log
    --   SET message_type_cd =  'ERROR',
    --       message_text   = l_message_text,
    --       txn_table_route_id    =  g_table_route_id_wdt,
    --       batch_status    = 'ERROR',
    --       batch_end_date  = sysdate
    --   WHERE process_log_id = pqh_process_batch_log.g_master_process_log_id;
    --   commit;
  WHEN others THEN
  p_status := 'ERROR';
     raise;
END check_wks_errors;



    /*----------------------------------------------------------------
    || PROCEDURE : populate_globals
    ||
    ------------------------------------------------------------------*/


PROCEDURE populate_globals
(
  p_worksheet_detail_id     IN pqh_worksheet_details.worksheet_detail_id%TYPE
) IS

/*
  This procedure will populate all the global variables.
  If the p_worksheet_detail_id is invalid we abort the program
  New Rqmt : 03/28/2000
  Worksheet detail Id passed to the program will be the TOP MOST NODE and NOT THE
  worksheet Id as done previously

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
   FROM pqh_budgets b, pqh_worksheets wks, pqh_worksheet_details wdt
   WHERE wdt.worksheet_id = wks.worksheet_id
     AND wks.budget_id = b.budget_id
     AND wdt.worksheet_detail_id = p_worksheet_detail_id
  );

  CURSOR csr_worksheet_rec IS
   SELECT *
   FROM pqh_worksheets
   WHERE worksheet_id =
    (
     SELECT wks.worksheet_id
     FROM pqh_worksheets wks, pqh_worksheet_details wdt
     WHERE wdt.worksheet_id = wks.worksheet_id
      AND  wdt.worksheet_detail_id = p_worksheet_detail_id
    );

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

     g_budget_unit1_id        := l_budgets_rec.budget_unit1_id;
     g_budget_unit2_id        := l_budgets_rec.budget_unit2_id;
     g_budget_unit3_id        := l_budgets_rec.budget_unit3_id;
     g_budgeted_entity_cd     := l_budgets_rec.budgeted_entity_cd;
     g_budget_name            := l_budgets_rec.budget_name;
     g_position_control       := l_budgets_rec.position_control_flag;
     g_budget_id              := l_budgets_rec.budget_id;
     g_budget_start_dt        := l_budgets_rec.budget_start_date;
     g_budget_end_dt          := l_budgets_rec.budget_end_date;
     g_budget_unit1_aggregate := l_budgets_rec.budget_unit1_aggregate;
     g_budget_unit2_aggregate := l_budgets_rec.budget_unit2_aggregate;
     g_budget_unit3_aggregate := l_budgets_rec.budget_unit3_aggregate;
     g_budget_style_cd        := l_budgets_rec.budget_style_cd;


  hr_utility.set_location('budget_unit1: '||g_budget_unit1_id, 11);
  hr_utility.set_location('budget_unit2: '||g_budget_unit2_id, 15);
  hr_utility.set_location('budget_unit3: '||g_budget_unit3_id, 20);
  hr_utility.set_location('budgeted_entity_cd: '||g_budgeted_entity_cd, 21);


  -- get worksheet mode
    OPEN csr_worksheet_rec;
      FETCH csr_worksheet_rec INTO l_worksheets_rec;
    CLOSE csr_worksheet_rec;

    g_worksheet_mode_cd := l_worksheets_rec.worksheet_mode_cd;
    g_worksheet_name    := l_worksheets_rec.worksheet_name;
    g_worksheet_id      := l_worksheets_rec.worksheet_id;

   hr_utility.set_location('worksheet_mode_cd: '||g_worksheet_mode_cd, 25);
   hr_utility.set_location('worksheet_name: '||g_worksheet_name, 30);
   hr_utility.set_location('worksheet_id: '||g_worksheet_id, 40);

  -- check if p_worksheet_detail_id is valid. If p_worksheet_detail_id is INVALID then
  -- no worksheet record would be fetched . So abort

    IF g_worksheet_id IS NULL THEN
     -- get the message text PQH_INV_WKS_DTL_ID
        FND_MESSAGE.SET_NAME('PQH','PQH_INV_WKS_DTL_ID');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

  -- get table_route_id for all the six worksheet tables

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
        hr_utility.raise_error;
END populate_globals;




    /*----------------------------------------------------------------
    || PROCEDURE : check_level1_rows
    ||
    ------------------------------------------------------------------*/


PROCEDURE check_level1_rows
(
  p_worksheet_detail_id     IN pqh_worksheet_details.worksheet_detail_id%TYPE
) IS

/*
  This procedure will check if all the level one rows below root or input node
  which are delegated have   null in old values and have available amounts > = 0
  Here context_level = 2 as they are one below main input node
  -- new change as of 03/23/2000
  We will call this check_level1_rows at every node which is Delegated
  If we find  values in old values then we will call Sumit's procedure which will
  propogate the changes and give the available values for the child row.
  We will then update the child row with the new values

*/

 l_proc                           varchar2(72) := g_package||'check_level1_rows';
 l_worksheet_details_rec          pqh_worksheet_details%ROWTYPE;
 l_message_text                   pqh_process_log.message_text%TYPE;
 l_message_text_out               fnd_new_messages.message_text%TYPE;
 l_message_number_out             fnd_new_messages.message_number%TYPE;
 l_log_context                    pqh_process_log.log_context%TYPE;
 l_error_flag                     varchar2(10) := 'N';

 l_unit1_available                pqh_worksheet_details.budget_unit1_available%TYPE;
 l_unit2_available                pqh_worksheet_details.budget_unit2_available%TYPE;
 l_unit3_available                pqh_worksheet_details.budget_unit3_available%TYPE;
 l_unit1_precision                number;
 l_unit2_precision                number;
 l_unit3_precision                number;
 l_object_version_number          pqh_worksheet_details.object_version_number%TYPE;
 l_unit1_value                    pqh_worksheet_details.budget_unit1_value%TYPE;
 l_unit2_value                    pqh_worksheet_details.budget_unit2_value%TYPE;
 l_unit3_value                    pqh_worksheet_details.budget_unit3_value%TYPE;
 l_propogate_status               varchar2(30);


CURSOR csr_level1_rows IS
SELECT *
FROM pqh_worksheet_details
WHERE worksheet_detail_id IN
(
 SELECT  worksheet_detail_id
 FROM pqh_worksheet_details
 WHERE level = 2
   AND action_cd = 'D'
 START WITH worksheet_detail_id = p_worksheet_detail_id
 CONNECT BY prior worksheet_detail_id = parent_worksheet_detail_id
 )
FOR UPDATE OF budget_unit1_available,budget_unit2_available,budget_unit3_available;

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

  OPEN csr_level1_rows;
    LOOP
      FETCH csr_level1_rows INTO l_worksheet_details_rec;
      EXIT WHEN csr_level1_rows%NOTFOUND;
/*
  We don't report this as error but instead call Sumit's procedure
  which would correct the error
*/

/*
           -- get log_context
            set_wks_log_context
            (
              p_worksheet_detail_id     => l_worksheet_details_rec.worksheet_detail_id,
              p_log_context             => l_log_context
             );

           -- set the context before inserting error
           pqh_process_batch_log.set_context_level
           (
             p_txn_id                =>  l_worksheet_details_rec.worksheet_detail_id,
             p_txn_table_route_id    =>  g_table_route_id_wdt,
             p_level                 =>  2,
             p_log_context           =>  l_log_context
           );

*/
      -- CHECK # 1 check if old unit values are null

    IF g_budget_style_cd = 'TOP_DOWN' THEN
      --
       IF ( l_worksheet_details_rec.old_unit1_value IS NOT NULL ) OR
          ( l_worksheet_details_rec.old_unit2_value IS NOT NULL ) OR
          ( l_worksheet_details_rec.old_unit3_value IS NOT NULL ) THEN


          -- call to Sumit's procedure for TOP_DOWN
            -- populate the in out variables
               l_unit1_available := l_worksheet_details_rec.budget_unit1_available;
               l_unit2_available := l_worksheet_details_rec.budget_unit2_available;
               l_unit3_available := l_worksheet_details_rec.budget_unit3_available;
           pqh_wks_budget.get_wkd_unit_precision(p_worksheet_detail_id => l_worksheet_details_rec.worksheet_detail_id,
                                                 p_unit1_precision     => l_unit1_precision,
                                                 p_unit2_precision     => l_unit2_precision,
                                                 p_unit3_precision     => l_unit3_precision);
           pqh_budget.propagate_worksheet_changes
           (p_change_mode          => l_worksheet_details_rec.propagation_method,
            p_worksheet_detail_id  => l_worksheet_details_rec.worksheet_detail_id,
            p_budget_style_cd      => g_budget_style_cd,
            p_new_wks_unit1_value  => l_worksheet_details_rec.budget_unit1_value,
            p_new_wks_unit2_value  => l_worksheet_details_rec.budget_unit2_value,
            p_new_wks_unit3_value  => l_worksheet_details_rec.budget_unit3_value,
            p_unit1_aggregate      => g_budget_unit1_aggregate,
            p_unit2_aggregate      => g_budget_unit2_aggregate,
            p_unit3_aggregate      => g_budget_unit3_aggregate,
            p_unit1_precision      => l_unit1_precision,
            p_unit2_precision      => l_unit2_precision,
            p_unit3_precision      => l_unit3_precision,
            p_wks_unit1_available  => l_unit1_available,
            p_wks_unit2_available  => l_unit2_available,
            p_wks_unit3_available  => l_unit3_available,
            p_object_version_number => l_object_version_number
           );

           -- update the current record with the new available values
           UPDATE pqh_worksheet_details
              SET budget_unit1_available = l_unit1_available,
                  budget_unit2_available = l_unit2_available,
                  budget_unit3_available = l_unit3_available
            WHERE CURRENT OF csr_level1_rows;


/*
           --  get message text for PQH_WKS_DEL_CHANGES
           -- Changes in the delegated organization ORG_NAME have not been applied

          -- get message text for PQH_WKS_DEL_CHANGES
             FND_MESSAGE.SET_NAME('PQH','PQH_WKS_DEL_CHANGES');
             FND_MESSAGE.SET_TOKEN('ORG_NAME',l_log_context);
             l_message_text_out := FND_MESSAGE.GET;

             l_message_text := l_message_text_out;

           -- set l_error_flag to Y
             l_error_flag := 'Y';
*/

       END IF; -- check if old unit values are null for TOP_DOWN

   ELSE
     -- budget_style_cd is BOTTOM_UP
       IF ( NVL(l_worksheet_details_rec.old_unit1_value,0) <> NVL(l_worksheet_details_rec.budget_unit1_value,0) ) OR
          ( NVL(l_worksheet_details_rec.old_unit2_value,0) <> NVL(l_worksheet_details_rec.budget_unit2_value,0) ) OR
          ( NVL(l_worksheet_details_rec.old_unit3_value,0) <> NVL(l_worksheet_details_rec.budget_unit3_value,0) ) THEN
         -- call sumit's pkg for BOTTOM_UP
               l_unit1_value := l_worksheet_details_rec.budget_unit1_value;
               l_unit2_value := l_worksheet_details_rec.budget_unit2_value;
               l_unit3_value := l_worksheet_details_rec.budget_unit3_value;

                pqh_wks_budget.propagate_bottom_up
                (p_worksheet_detail_id  =>  l_worksheet_details_rec.worksheet_detail_id,
                 p_budget_unit1_value   =>  l_unit1_value,
                 p_budget_unit2_value   =>  l_unit2_value,
                 p_budget_unit3_value   =>  l_unit3_value,
                 p_status               =>  l_propogate_status
                 ) ;

           -- update the current record with the new available values
           UPDATE pqh_worksheet_details
              SET budget_unit1_value = l_unit1_value,
                  budget_unit2_value = l_unit2_value,
                  budget_unit3_value = l_unit3_value
            WHERE CURRENT OF csr_level1_rows;

       END IF; -- for BOTTOM_UP




   END IF; -- budget_style_cd



         hr_utility.set_location('Error in Txn : '||l_worksheet_details_rec.worksheet_detail_id, 10);


/*
          -- insert error message if l_error_flag is Y
           IF l_error_flag = 'Y' THEN
              pqh_process_batch_log.insert_log
              (
                p_message_type_cd    =>  'ERROR',
                p_message_text       =>  l_message_text
              );
            END IF; -- insert error message if l_error_flag is Y
*/





    END LOOP;
   CLOSE csr_level1_rows;


  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        -- end log and halt the program here
        raise g_error_exception;
END check_level1_rows;



    /*----------------------------------------------------------------
    || PROCEDURE : check_wks_details
    ||
    ------------------------------------------------------------------*/



PROCEDURE check_wks_details
(
  p_worksheet_detail_id     IN pqh_worksheet_details.worksheet_detail_id%TYPE
) IS

/*
  This procedure will check if all the wks detail records under the main node  EXCLUDING
  level 1 as they are already checked in check_level1_rows procedure and report all the errors
  For budgeted records we check if there are rows in periods
*/

 l_proc                           varchar2(72) := g_package||'check_wks_details';
 l_worksheet_details_rec          pqh_worksheet_details%ROWTYPE;
 l_message_text                   pqh_process_log.message_text%TYPE;
 l_message_text_out               fnd_new_messages.message_text%TYPE;
 l_count                          number;
 l_error_flag                     varchar2(10) := 'N';
 l_pc_posn_status                 varchar2(30);
 l_availability_status_id         hr_positions.availability_status_id%type;


CURSOR csr_wks_details IS
SELECT *
FROM pqh_worksheet_details
WHERE worksheet_detail_id = p_worksheet_detail_id;

CURSOR csr_wks_periods_count IS
SELECT COUNT(*)
FROM pqh_worksheet_periods
WHERE worksheet_detail_id = p_worksheet_detail_id;

CURSOR csr_pos_availability(p_position_id  l_worksheet_details_rec.position_id%type,
                            p_worksheet_id l_worksheet_details_rec.worksheet_id%type) IS
SELECT pos.availability_status_id
  FROM hr_all_positions_f pos, pqh_worksheets wks, pqh_budgets bud
 WHERE pos.position_id  = p_position_id
   AND wks.worksheet_id = p_worksheet_id
   AND wks.budget_id    = bud.budget_id
   AND pos.effective_start_date < bud.budget_end_date
   AND pos.effective_end_date   > bud.budget_start_date;


BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

  OPEN csr_wks_details;
     FETCH csr_wks_details INTO l_worksheet_details_rec;
  CLOSE csr_wks_details;

  --  CHECK # 1,2, 3 ARE MUTUALLY EXCLUSIVE

/*
       THIS IS DONE IN WORKSHEET DETAILS API
       removed on 03/23/2000

       -- CHECK # 1 check valid action code which is null for Root , B for budgeted and D for delegated

        IF  NVL(l_worksheet_details_rec.action_cd , 'R') NOT IN ( 'R','D','B' ) THEN

             -- get message text for PQH_WKS_INVALID_ACTION_CD
             -- message : Worksheet has invalid Action Code ACTION_CD
                FND_MESSAGE.SET_NAME('PQH','PQH_WKS_INVALID_ACTION_CD');
                FND_MESSAGE.SET_TOKEN('ACTION_CD',l_worksheet_details_rec.action_cd);
                l_message_text_out := FND_MESSAGE.GET;


             l_message_text := l_message_text_out;

               -- set l_error_flag to Y
                     l_error_flag := 'Y';


             hr_utility.set_location('Error in Txn : '||l_worksheet_details_rec.worksheet_detail_id, 10);


        END IF; -- CHECK # 1

*/

/*
       THIS IS DONE IN WORKSHEET DETAILS API
       removed on 03/23/2000

        -- CHECK #  2 for delegated or Root record the unit values must be greater then zero

        IF  NVL(l_worksheet_details_rec.action_cd , 'R') IN ( 'R','D' ) THEN
           -- this is a root or delegated record

            IF    ( g_budget_unit1_id IS NOT NULL ) AND
                  ( NVL(l_worksheet_details_rec.budget_unit1_value,0) < 0 ) THEN

                 IF l_error_flag = 'Y' THEN
                   -- there is already an error so append the message

                   -- get message text for PQH_WKS_INVALID_BDG_AMT
                   -- message : Worksheet Budgeted Amount Must be more then zero
                      FND_MESSAGE.SET_NAME('PQH','PQH_WKS_INVALID_BDG_AMT');
                      l_message_text_out := FND_MESSAGE.GET;

                      l_message_text := l_message_text||' **** '||l_message_text_out;
                 ELSE
                    -- new message
                      l_message_text := l_message_text_out;
                 END IF;

                 -- set l_error_flag to Y
                    l_error_flag := 'Y';

                      hr_utility.set_location('Error in Txn : '||l_worksheet_details_rec.worksheet_detail_id, 10);



            ELSIF ( g_budget_unit2_id IS NOT NULL ) AND
                  ( NVL(l_worksheet_details_rec.budget_unit2_value,0) < 0 ) THEN

                 IF l_error_flag = 'Y' THEN
                   -- there is already an error so append the message

                   -- get message text for PQH_WKS_INVALID_BDG_AMT
                   -- message : Worksheet Budgeted Amount Must be more then zero
                      FND_MESSAGE.SET_NAME('PQH','PQH_WKS_INVALID_BDG_AMT');
                      l_message_text_out := FND_MESSAGE.GET;

                      l_message_text := l_message_text||' **** '||l_message_text_out;
                 ELSE
                    -- new message
                      l_message_text := l_message_text_out;
                 END IF;

                 -- set l_error_flag to Y
                    l_error_flag := 'Y';

                      hr_utility.set_location('Error in Txn : '||l_worksheet_details_rec.worksheet_detail_id, 10);


            ELSIF ( g_budget_unit3_id IS NOT NULL ) AND
                  ( NVL(l_worksheet_details_rec.budget_unit3_value,0) < 0 ) THEN

                 IF l_error_flag = 'Y' THEN
                   -- there is already an error so append the message

                   -- get message text for PQH_WKS_INVALID_BDG_AMT
                   -- message : Worksheet Budgeted Amount Must be more then zero
                      FND_MESSAGE.SET_NAME('PQH','PQH_WKS_INVALID_BDG_AMT');
                      l_message_text_out := FND_MESSAGE.GET;

                      l_message_text := l_message_text||' **** '||l_message_text_out;
                 ELSE
                    -- new message
                      l_message_text := l_message_text_out;
                 END IF;

                  -- set l_error_flag to Y
                     l_error_flag := 'Y';

                      hr_utility.set_location('Error in Txn : '||l_worksheet_details_rec.worksheet_detail_id, 10);



            END IF;

        END IF;  -- CHECK # 2 for delegated or Root record the unit values must be greater then zero

*/


       -- CHECK # 3 for budgeted records check rows in periods
       --  if position control then check if position is not budgeted in any other budget
        IF  NVL(l_worksheet_details_rec.action_cd , 'R') ='B'  THEN
          -- this is budgeted record
            OPEN csr_wks_periods_count;
              FETCH csr_wks_periods_count INTO l_count;
            CLOSE csr_wks_periods_count;

            IF NVL(l_count,0) = 0 THEN

               hr_utility.set_location('WKS Detail Error 3 PQH_WKS_NO_PERIODS '||l_worksheet_details_rec.worksheet_detail_id,10);

                  -- get message text for PQH_WKS_NO_PERIODS
                  -- message : No Periods Defined for the budgeted entity
                     FND_MESSAGE.SET_NAME('PQH','PQH_WKS_NO_PERIODS');
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


            END IF; -- l_count = 0

            OPEN csr_pos_availability(l_worksheet_details_rec.position_id,
                                      l_worksheet_details_rec.worksheet_id);
            FETCH csr_pos_availability into l_availability_status_id;
            CLOSE csr_pos_availability;

            IF pqh_wks_budget.get_position_budget_flag(l_availability_status_id) = 'N' THEN
               FND_MESSAGE.SET_NAME('PQH','PQH_WKS_WRONG_POSITION');
               FND_MESSAGE.SET_TOKEN('STATUS',HR_GENERAL.DECODE_AVAILABILITY_STATUS(l_availability_status_id));

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

/*
           The Posn Control Check is now done at Budget Version Level as of 03/22/2001

            IF NVL(g_position_control,'N') = 'Y' AND l_worksheet_details_rec.position_id IS NOT NULL THEN

               -- for a pc budget we check if the position budgeted is budgeted in any other budget , if yes we
               -- check if the Fiscal Period for the current budget and the other budget overlap, if yes we report this
               -- as error

                check_pc_posn
                (
                  p_position_id         => l_worksheet_details_rec.position_id,
                  p_status              => l_pc_posn_status
                );

                IF l_pc_posn_status = 'ERROR' THEN
                  hr_utility.set_location('WKS Detail Error 3.1 PQH_PC_POSN_INVALID '||l_worksheet_details_rec.position_id,11);
                   -- get message text for PQH_PC_POSN_INVALID
                   -- message : Position is already budgeted in another budget for the same Fiscal period
                     FND_MESSAGE.SET_NAME('PQH','PQH_PC_POSN_INVALID');
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
                END IF; -- for pc_posn_status = ERROR
            END IF; -- pc budget for posn check

*/

        END IF; -- CHECK # 3 for budgeted records check rows in periods


       -- CHECK # 4 check if available amount is >= 0  for all records

       IF ( NVL(l_worksheet_details_rec.budget_unit1_available,0) < 0  ) OR
          ( NVL(l_worksheet_details_rec.budget_unit2_available,0) < 0  ) OR
          ( NVL(l_worksheet_details_rec.budget_unit3_available,0) < 0  ) THEN

           hr_utility.set_location('WKS Detail Error 4 PQH_WKS_DEL_ALL_AMT '||l_worksheet_details_rec.worksheet_detail_id,10);

               -- get message text for PQH_WKS_DEL_ALL_AMT
               -- message : Budget Amount in the delegated organization exceeds the allocated amount
                  FND_MESSAGE.SET_NAME('PQH','PQH_WKS_DEL_ALL_AMT');
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


        END IF; -- CHECK # 4 check if available amount is >= 0

       -- CHECK # 5 for position records check if position_id exists for the position_transaction_id
        IF  NVL(l_worksheet_details_rec.action_cd , 'R') ='B'  THEN
          -- this is budgeted record

            IF l_worksheet_details_rec.position_transaction_id IS NOT NULL THEN
               -- posn txn id exists, check if position id exists
               IF l_worksheet_details_rec.position_id IS NULL THEN
                  hr_utility.set_location('WKS Detail Error 5 PQH_WKS_NO_POSITION '||l_worksheet_details_rec.worksheet_detail_id,10);

                  -- get message text for PQH_WKS_NO_POSITION
                  -- message : Position is not created for this position transaction
                     FND_MESSAGE.SET_NAME('PQH','PQH_WKS_NO_POSITION');
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

               END IF; -- position id is null

            END IF; -- for position_transaction_id

        END IF; -- CHECK # 5 budgeted record


          hr_utility.set_location('Error Flag : '||l_error_flag,10);

          -- insert error message if l_error_flag is Y
           IF l_error_flag = 'Y' THEN
              pqh_process_batch_log.insert_log
              (
                p_message_type_cd    =>  'ERROR',
                p_message_text       =>  l_message_text
              );
            END IF; -- insert error message if l_error_flag is Y



  hr_utility.set_location('Leaving:'||l_proc, 10);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        -- end log and halt the program here
        raise g_error_exception;
END check_wks_details;


    /*----------------------------------------------------------------
    || PROCEDURE : check_wks_periods
    ||
    ------------------------------------------------------------------*/



PROCEDURE check_wks_periods
(
  p_worksheet_detail_id     IN pqh_worksheet_details.worksheet_detail_id%TYPE,
  p_worksheet_period_id     IN pqh_worksheet_periods.worksheet_period_id%TYPE
) IS

/*
  This procedure will be called ONLY for Budgeted Worksheet records
  This procedure will check if all the wks period records under the wks detail
  and report all the errors
*/

 l_proc                           varchar2(72) := g_package||'check_wks_periods';
 l_worksheet_periods_rec          pqh_worksheet_periods%ROWTYPE;
 l_message_text                   pqh_process_log.message_text%TYPE;
 l_message_text_out               fnd_new_messages.message_text%TYPE;
 l_count                          NUMBER;
 l_error_flag                     varchar2(10) := 'N';
 l_message_type                   varchar2(10) := 'E';
 l_warnings_rec                   pqh_utility.warnings_rec;


CURSOR csr_wks_periods IS
SELECT *
FROM pqh_worksheet_periods
WHERE worksheet_period_id = p_worksheet_period_id;

CURSOR csr_wks_periods_count IS
SELECT COUNT(*)
FROM pqh_worksheet_periods
WHERE worksheet_detail_id = p_worksheet_detail_id;

CURSOR csr_wks_bset_count IS
SELECT COUNT(*)
FROM pqh_worksheet_budget_sets
WHERE worksheet_period_id  = p_worksheet_period_id;


BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);


  OPEN csr_wks_periods;
     FETCH csr_wks_periods INTO l_worksheet_periods_rec;
  CLOSE csr_wks_periods;

   -- CHECK # 1 if budget sets defined for the period else error
   OPEN csr_wks_bset_count;
     FETCH csr_wks_bset_count INTO l_count;
   CLOSE csr_wks_bset_count;

    IF NVL(l_count,0) = 0  THEN
         -- get message text for PQH_WKS_NO_BSETS
         -- message : No budget Sets have been defined for the budgeted period.
          FND_MESSAGE.SET_NAME('PQH','PQH_WKS_NO_BSETS');
          l_message_text_out := FND_MESSAGE.GET;

          l_message_text := l_message_text_out;

          -- set l_error_flag to Y
          l_error_flag := 'Y';

    END IF; -- for budget sets defined

/*
       THIS IS DONE IN WORKSHEET DETAILS API
       removed on 03/23/2000

      -- CHECK # 1 check if  unit values are >= 0

       IF ( NVL(l_worksheet_periods_rec.budget_unit1_value,0) < 0 ) OR
          ( NVL(l_worksheet_periods_rec.budget_unit2_value,0) < 0 ) OR
          ( NVL(l_worksheet_periods_rec.budget_unit3_value,0) < 0 ) THEN

           -- get message text for PQH_WKS_INVALID_PERIOD_VAL
           -- message : Budget Period Values must be more then zero
              FND_MESSAGE.SET_NAME('PQH','PQH_WKS_INVALID_PERIOD_VAL');
              l_message_text_out := FND_MESSAGE.GET;

              l_message_text := l_message_text_out;

            -- set l_error_flag to Y
               l_error_flag := 'Y';

       END IF;  -- CHECK # 1 check if  unit values are >= 0

*/

       -- CHECK # 2 check if available amount is >= 0

       IF ( NVL(l_worksheet_periods_rec.budget_unit1_available,0) < 0  ) OR
          ( NVL(l_worksheet_periods_rec.budget_unit2_available,0) < 0  ) OR
          ( NVL(l_worksheet_periods_rec.budget_unit3_available,0) < 0  ) THEN

           -- get message text for PQH_WKS_INVALID_PERIOD_AMT
            -- message : Budget Period Amount exceeds the allocated amount
               pqh_utility.set_message(8302,'PQH_WKS_INVALID_PERIOD_AMT',g_context_organization_id);
               l_message_text_out := pqh_utility.get_message;
               l_message_type     := pqh_utility.get_message_type_cd;

               IF nvl(l_message_type,'E') = 'E' THEN
                 -- this is a error
                 IF l_error_flag = 'Y' THEN
                    -- there is already an error so append the message

                    l_message_text := l_message_text||' **** '||l_message_text_out;
                 ELSE
                    -- new message
                     l_message_text := l_message_text_out;
                 END IF;
                 -- set l_error_flag to Y
                   l_error_flag := 'Y';

               ELSIF nvl(l_message_type,'E') = 'W' THEN
                -- this is a warning
                 l_warnings_rec.message_text  := l_message_text_out;
                 -- pqh_utility.init_warnings_table;
                 pqh_utility.insert_warning
                 (
                  p_warnings_rec => l_warnings_rec
                 );
                 -- assign warning message
                 l_message_text := l_message_text_out;
                -- insert warning into process log
                    pqh_process_batch_log.insert_log
                    (
                     p_message_type_cd    =>  'WARNING',
                     p_message_text       =>  l_message_text
                    );
               ELSE
                  -- this is ignore
                   hr_utility.set_location('Message Type in wks Periods is : '||l_message_type,6);
               END IF;


/*          -- added configurable rule on 10/13/2000

            -- get message text for PQH_WKS_INVALID_PERIOD_AMT
            -- message : Budget Period Amount exceeds the allocated amount
               FND_MESSAGE.SET_NAME('PQH','PQH_WKS_INVALID_PERIOD_AMT');
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

       END IF;  -- CHECK # 2 check if available amount is >= 0


       -- insert error message if l_error_flag is Y
        IF l_error_flag = 'Y' THEN
           pqh_process_batch_log.insert_log
           (
            p_message_type_cd    =>  'ERROR',
            p_message_text       =>  l_message_text
           );
        END IF; -- insert error message if l_error_flag is Y







  hr_utility.set_location('Leaving:'||l_proc, 10);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        -- end log and halt the program here
        raise g_error_exception;
END check_wks_periods;



    /*----------------------------------------------------------------
    || PROCEDURE : check_wks_budget_sets
    ||
    ------------------------------------------------------------------*/



PROCEDURE check_wks_budget_sets
(
  p_worksheet_period_id       IN pqh_worksheet_periods.worksheet_period_id%TYPE,
  p_worksheet_budget_set_id   IN pqh_worksheet_budget_sets.worksheet_budget_set_id%TYPE
) IS

/*
  This procedure will be called ONLY for Budgeted Worksheet records
  This procedure will check if all the wks budget sets records under the wks detail
  and report all the errors
  we check that if for the period the budget_unit1_value is more then zero, then
  its sum in the budget sets must be more then zero
*/

 l_proc                           varchar2(72) := g_package||'check_wks_budget_sets';
 l_worksheet_budget_sets_rec      pqh_worksheet_budget_sets%ROWTYPE;
 l_message_text                   pqh_process_log.message_text%TYPE;
 l_message_text_out               fnd_new_messages.message_text%TYPE;
 l_unit1_sum                      NUMBER;
 l_unit2_sum                      NUMBER;
 l_unit3_sum                      NUMBER;
 l_worksheet_periods_rec          pqh_worksheet_periods%ROWTYPE;
 l_message_type                   varchar2(10) := 'E';
 l_warnings_rec                   pqh_utility.warnings_rec;





CURSOR csr_wks_budget_sets_value IS
SELECT SUM(budget_unit1_value),
       SUM(budget_unit2_value),
       SUM(budget_unit3_value)
FROM pqh_worksheet_budget_sets
WHERE worksheet_period_id = p_worksheet_period_id;

CURSOR csr_wks_worksheet_periods IS
SELECT *
FROM pqh_worksheet_periods
WHERE worksheet_period_id = p_worksheet_period_id;


BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

  -- get the details for the current period
     OPEN csr_wks_worksheet_periods;
       FETCH csr_wks_worksheet_periods INTO l_worksheet_periods_rec;
     CLOSE csr_wks_worksheet_periods;

  -- CHECK # 1 check if sum of unit values under the current period are > 0

    OPEN csr_wks_budget_sets_value;
      FETCH csr_wks_budget_sets_value INTO l_unit1_sum, l_unit2_sum, l_unit3_sum;
    CLOSE csr_wks_budget_sets_value;


             IF   ( g_budget_unit1_id IS NOT NULL ) AND
                  ( NVL(l_worksheet_periods_rec.budget_unit1_value,0) > 0 ) AND
                  ( NVL(l_unit1_sum,0) <= 0 ) THEN

                     -- get message text for  PQH_WKS_INVALID_BSET_VAL
                     -- message : Sum of Budget Sets value for a period must be more then zero
                        pqh_utility.set_message(8302,'PQH_WKS_INVALID_BSET_VAL',g_context_organization_id);
                        l_message_text_out := pqh_utility.get_message;
                        l_message_type     := pqh_utility.get_message_type_cd;

                        l_message_text := l_message_text_out;

                        IF nvl(l_message_type,'E') = 'E' THEN
                          -- this is a error
                          -- insert error message
                              pqh_process_batch_log.insert_log
                              (
                               p_message_type_cd    =>  'ERROR',
                               p_message_text       =>  l_message_text
                              );
                        ELSIF nvl(l_message_type,'E') = 'W' THEN
                           -- this is a warning
                            l_warnings_rec.message_text  := l_message_text_out;
                            -- pqh_utility.init_warnings_table;
                            pqh_utility.insert_warning
                            (
                             p_warnings_rec => l_warnings_rec
                            );
                           -- insert warning into process log
                               pqh_process_batch_log.insert_log
                               (
                                p_message_type_cd    =>  'WARNING',
                                p_message_text       =>  l_message_text
                               );
                        ELSE
                             -- this is ignore
                              hr_utility.set_location('Message Type in wks Periods is : '||l_message_type,6);
                        END IF;  -- message_type




/*
                     -- get message text for PQH_WKS_INVALID_BSET_VAL
                     -- message : Sum of Budget Sets value for a period must be more then zero
                        FND_MESSAGE.SET_NAME('PQH','PQH_WKS_INVALID_BSET_VAL');
                        l_message_text_out := FND_MESSAGE.GET;

                        l_message_text := l_message_text_out;

                      -- insert error message
                      pqh_process_batch_log.insert_log
                      (
                       p_message_type_cd    =>  'ERROR',
                       p_message_text       =>  l_message_text
                      );
*/


            ELSIF ( g_budget_unit2_id IS NOT NULL ) AND
                  ( NVL(l_worksheet_periods_rec.budget_unit2_value,0) > 0 ) AND
                  ( NVL(l_unit2_sum,0) <= 0 ) THEN


                     -- get message text for  PQH_WKS_INVALID_BSET_VAL
                     -- message : Sum of Budget Sets value for a period must be more then zero
                        pqh_utility.set_message(8302,'PQH_WKS_INVALID_BSET_VAL',g_context_organization_id);
                        l_message_text_out := pqh_utility.get_message;
                        l_message_type     := pqh_utility.get_message_type_cd;

                        l_message_text := l_message_text_out;

                        IF nvl(l_message_type,'E') = 'E' THEN
                          -- this is a error
                          -- insert error message
                              pqh_process_batch_log.insert_log
                              (
                               p_message_type_cd    =>  'ERROR',
                               p_message_text       =>  l_message_text
                              );
                        ELSIF nvl(l_message_type,'E') = 'W' THEN
                           -- this is a warning
                            l_warnings_rec.message_text  := l_message_text_out;
                            -- pqh_utility.init_warnings_table;
                            pqh_utility.insert_warning
                            (
                             p_warnings_rec => l_warnings_rec
                            );
                           -- insert warning into process log
                               pqh_process_batch_log.insert_log
                               (
                                p_message_type_cd    =>  'WARNING',
                                p_message_text       =>  l_message_text
                               );
                        ELSE
                             -- this is ignore
                              hr_utility.set_location('Message Type in wks Periods is : '||l_message_type,6);
                        END IF;  -- message_type





/*
                     -- get message text for PQH_WKS_INVALID_BSET_VAL
                     -- message : Sum of Budget Sets value for a period must be more then zero
                        FND_MESSAGE.SET_NAME('PQH','PQH_WKS_INVALID_BSET_VAL');
                        l_message_text_out := FND_MESSAGE.GET;

                        l_message_text := l_message_text_out;

                       -- insert error message
                      pqh_process_batch_log.insert_log
                      (
                       p_message_type_cd    =>  'ERROR',
                       p_message_text       =>  l_message_text
                      );
*/



            ELSIF ( g_budget_unit3_id IS NOT NULL ) AND
                  ( NVL(l_worksheet_periods_rec.budget_unit3_value,0) > 0 ) AND
                  ( NVL(l_unit3_sum,0) <= 0 ) THEN


                     -- get message text for  PQH_WKS_INVALID_BSET_VAL
                     -- message : Sum of Budget Sets value for a period must be more then zero
                        pqh_utility.set_message(8302,'PQH_WKS_INVALID_BSET_VAL',g_context_organization_id);
                        l_message_text_out := pqh_utility.get_message;
                        l_message_type     := pqh_utility.get_message_type_cd;

                        l_message_text := l_message_text_out;

                        IF nvl(l_message_type,'E') = 'E' THEN
                          -- this is a error
                          -- insert error message
                              pqh_process_batch_log.insert_log
                              (
                               p_message_type_cd    =>  'ERROR',
                               p_message_text       =>  l_message_text
                              );
                        ELSIF nvl(l_message_type,'E') = 'W' THEN
                           -- this is a warning
                            l_warnings_rec.message_text  := l_message_text_out;
                            -- pqh_utility.init_warnings_table;
                            pqh_utility.insert_warning
                            (
                             p_warnings_rec => l_warnings_rec
                            );
                           -- insert warning into process log
                               pqh_process_batch_log.insert_log
                               (
                                p_message_type_cd    =>  'WARNING',
                                p_message_text       =>  l_message_text
                               );
                        ELSE
                             -- this is ignore
                              hr_utility.set_location('Message Type in wks Periods is : '||l_message_type,6);
                        END IF;  -- message_type




/*
                     -- get message text for PQH_WKS_INVALID_BSET_VAL
                     -- message : Sum of Budget Sets value for a period must be more then zero
                        FND_MESSAGE.SET_NAME('PQH','PQH_WKS_INVALID_BSET_VAL');
                        l_message_text_out := FND_MESSAGE.GET;

                        l_message_text := l_message_text_out;

                      -- insert error message
                      pqh_process_batch_log.insert_log
                      (
                       p_message_type_cd    =>  'ERROR',
                       p_message_text       =>  l_message_text
                      );
*/


            END IF;




  hr_utility.set_location('Leaving:'||l_proc, 10);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        -- end log and halt the program here
        raise g_error_exception;
END check_wks_budget_sets;


    /*----------------------------------------------------------------
    || PROCEDURE : check_wks_budget_elements
    ||
    ------------------------------------------------------------------*/



PROCEDURE check_wks_budget_elements
(
  p_worksheet_budget_set_id   IN pqh_worksheet_budget_sets.worksheet_budget_set_id%TYPE,
  p_worksheet_bdgt_elmnt_id   IN pqh_worksheet_fund_srcs.worksheet_bdgt_elmnt_id%TYPE
) IS

/*
  This procedure will be called ONLY for Budgeted Worksheet records
  This procedure will check if all the wks budget element records under the wks budget set
  and report all the errors
*/

 l_proc                           varchar2(72) := g_package||'check_wks_budget_elements';
 l_worksheet_bdgt_elmnts_rec      pqh_worksheet_bdgt_elmnts%ROWTYPE;
 l_message_text                   pqh_process_log.message_text%TYPE;
 l_message_text_out               fnd_new_messages.message_text%TYPE;
 l_percentage_sum                 NUMBER;
 l_error_flag                     varchar2(10) := 'N';
 l_message_type                   varchar2(10) := 'E';
 l_warnings_rec                   pqh_utility.warnings_rec;



 CURSOR csr_wks_budget_elements IS
 SELECT *
 FROM pqh_worksheet_bdgt_elmnts
 WHERE worksheet_bdgt_elmnt_id = p_worksheet_bdgt_elmnt_id;

 CURSOR csr_wks_budget_elements_sum IS
 SELECT SUM(distribution_percentage)
 FROM pqh_worksheet_bdgt_elmnts
 WHERE worksheet_budget_set_id = p_worksheet_budget_set_id;


BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);


  -- CHECK # 1 check if SUM of percentage = 100

  OPEN csr_wks_budget_elements_sum;
    FETCH csr_wks_budget_elements_sum INTO l_percentage_sum;
  CLOSE csr_wks_budget_elements_sum;

    IF    NVL(l_percentage_sum,0) > 100 THEN

       -- get message text for PQH_WKS_INVALID_ELMNT_SUM
       -- message : For Budget elements total of percentage under a budget set cannot exceed 100
          pqh_utility.set_message(8302,'PQH_WKS_INVALID_ELMNT_SUM',g_context_organization_id);

             hr_utility.set_location('Message Set ',6);

          l_message_text_out := pqh_utility.get_message;

             hr_utility.set_location('Get Message Text : '||l_message_text_out,7);

          l_message_type     := pqh_utility.get_message_type_cd;

             hr_utility.set_location('Get Message Type : '||l_message_type,8);

           -- assign warning message
             l_message_text := l_message_text_out;

          IF nvl(l_message_type,'E') = 'E' THEN
             -- set l_error_flag to Y
             l_error_flag := 'Y';
          ELSIF nvl(l_message_type,'E') = 'W' THEN
                -- this is a warning
                 l_warnings_rec.message_text  := l_message_text_out;
                 -- pqh_utility.init_warnings_table;
                 pqh_utility.insert_warning
                 (
                  p_warnings_rec => l_warnings_rec
                 );
                -- insert warning into process log
                    pqh_process_batch_log.insert_log
                    (
                     p_message_type_cd    =>  'WARNING',
                     p_message_text       =>  l_message_text
                    );
          ELSE
                -- this is ignore
                 hr_utility.set_location('Message Type in wks Periods is : '||l_message_type,6);
          END IF;

/*

       -- get message text for PQH_WKS_INVALID_ELMNT_SUM
       -- message : For Budget elements total of percentage under a budget set cannot exceed 100
          FND_MESSAGE.SET_NAME('PQH','PQH_WKS_INVALID_ELMNT_SUM');
          l_message_text_out := FND_MESSAGE.GET;

          l_message_text := l_message_text_out;

         -- set l_error_flag to Y
            l_error_flag := 'Y';
*/

    ELSIF NVL(l_percentage_sum,0) < 100 THEN


       -- get message text for PQH_WKS_LESS_ELMNT_SUM
       -- message : Warning : For Budget elements total of percentage under  budget set is less then 100
          pqh_utility.set_message(8302,'PQH_WKS_LESS_ELMNT_SUM',g_context_organization_id);
          l_message_text_out := pqh_utility.get_message;
          l_message_type     := pqh_utility.get_message_type_cd;

       -- assign warning message
          l_message_text := l_message_text_out;

          IF nvl(l_message_type,'E') = 'E' THEN
             -- set l_error_flag to Y
             l_error_flag := 'Y';
          ELSIF nvl(l_message_type,'E') = 'W' THEN
                -- this is a warning
                 l_warnings_rec.message_text  := l_message_text_out;
                 -- pqh_utility.init_warnings_table;
                 pqh_utility.insert_warning
                 (
                  p_warnings_rec => l_warnings_rec
                 );
                -- insert warning into process log
                    pqh_process_batch_log.insert_log
                    (
                     p_message_type_cd    =>  'WARNING',
                     p_message_text       =>  l_message_text
                    );
          ELSE
                -- this is ignore
                 hr_utility.set_location('Message Type in wks Periods is : '||l_message_type,6);
          END IF;



/*
       -- get message text for PQH_WKS_LESS_ELMNT_SUM
       -- message : Warning : For Budget elements total of percentage under  budget set is less then 100
          FND_MESSAGE.SET_NAME('PQH','PQH_WKS_LESS_ELMNT_SUM');
          l_message_text_out := FND_MESSAGE.GET;

          l_message_text := l_message_text_out;

         -- set l_error_flag to Y
            l_error_flag := 'Y';
*/


    END IF;  -- CHECK # 1 check if SUM of percentage = 100


     hr_utility.set_location('After check 1 ',10);


/*
       THIS IS DONE IN WORKSHEET DETAILS API
       removed on 03/23/2000

  -- CHECK # 2 check if percent is negative

  OPEN csr_wks_budget_elements;
    FETCH csr_wks_budget_elements INTO l_worksheet_bdgt_elmnts_rec;
  CLOSE csr_wks_budget_elements;


        IF NVL(l_worksheet_bdgt_elmnts_rec.distribution_percentage,0) < 0 THEN

           IF l_error_flag = 'Y' THEN
            -- there is already an error so append the message

             -- get message text for PQH_WKS_INVALID_ELMNT_PERCENT
             -- message : For Budget elements percentage cannot be less then 0
                FND_MESSAGE.SET_NAME('PQH','PQH_WKS_INVALID_ELMNT_PERCENT');
                l_message_text_out := FND_MESSAGE.GET;

                l_message_text := l_message_text||' **** '||l_message_text_out;
           ELSE
              -- new message
                l_message_text := l_message_text_out;
           END IF;

           -- set l_error_flag to Y
             l_error_flag := 'Y';

        END IF;    -- CHECK # 2 check if percent is negative

*/



       -- insert error message if l_error_flag is Y
        IF l_error_flag = 'Y' THEN
           pqh_process_batch_log.insert_log
           (
            p_message_type_cd    =>  'ERROR',
            p_message_text       =>  l_message_text
           );
        END IF; -- insert error message if l_error_flag is Y




  hr_utility.set_location('Leaving:'||l_proc, 10);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        -- end log and halt the program here
        raise g_error_exception;
END check_wks_budget_elements;


    /*----------------------------------------------------------------
    || PROCEDURE : check_wks_fund_srcs
    ||
    ------------------------------------------------------------------*/



PROCEDURE check_wks_fund_srcs
(
  p_worksheet_bdgt_elmnt_id   IN pqh_worksheet_fund_srcs.worksheet_bdgt_elmnt_id%TYPE,
  p_worksheet_fund_src_id     IN pqh_worksheet_fund_srcs.worksheet_fund_src_id%TYPE
) IS

/*
  This procedure will be called ONLY for Budgeted Worksheet records
  This procedure will check if all the wks budget fund srcs records under the wks budget set
  and report all the errors
*/

 l_proc                           varchar2(72) := g_package||'check_wks_fund_srcs';
 l_worksheet_fund_srcs_rec        pqh_worksheet_fund_srcs%ROWTYPE;
 l_message_text                   pqh_process_log.message_text%TYPE;
 l_message_text_out               fnd_new_messages.message_text%TYPE;
 l_percentage_sum                 NUMBER;
 l_error_flag                     varchar2(10) := 'N';
 l_message_type                   varchar2(10) := 'E';
 l_warnings_rec                   pqh_utility.warnings_rec;


 CURSOR csr_wks_fund_srcs IS
 SELECT *
 FROM pqh_worksheet_fund_srcs
 WHERE worksheet_fund_src_id = p_worksheet_fund_src_id;

 CURSOR csr_wks_fund_srcs_sum IS
 SELECT SUM(distribution_percentage)
 FROM pqh_worksheet_fund_srcs
 WHERE worksheet_bdgt_elmnt_id = p_worksheet_bdgt_elmnt_id;


BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);


  -- CHECK # 1 check if SUM of percentage = 100

  OPEN csr_wks_fund_srcs_sum;
    FETCH csr_wks_fund_srcs_sum INTO l_percentage_sum;
  CLOSE csr_wks_fund_srcs_sum;

    IF    NVL(l_percentage_sum,0) > 100 THEN

       -- get message text for PQH_WKS_INVALID_SRCS_SUM
       -- message : For Budget funding source total of percentage under a budget element cannot exceed 100
          pqh_utility.set_message(8302,'PQH_WKS_INVALID_SRCS_SUM',g_context_organization_id);
          l_message_text_out := pqh_utility.get_message;
          l_message_type     := pqh_utility.get_message_type_cd;

       -- assign warning message
          l_message_text := l_message_text_out;

          IF nvl(l_message_type,'E') = 'E' THEN
             -- set l_error_flag to Y
             l_error_flag := 'Y';
          ELSIF nvl(l_message_type,'E') = 'W' THEN
                -- this is a warning
                 l_warnings_rec.message_text  := l_message_text_out;
                 -- pqh_utility.init_warnings_table;
                 pqh_utility.insert_warning
                 (
                  p_warnings_rec => l_warnings_rec
                 );
                -- insert warning into process log
                    pqh_process_batch_log.insert_log
                    (
                     p_message_type_cd    =>  'WARNING',
                     p_message_text       =>  l_message_text
                    );
          ELSE
                -- this is ignore
                 hr_utility.set_location('Message Type in wks Periods is : '||l_message_type,6);
          END IF;

    ELSIF NVL(l_percentage_sum,0) < 100 THEN

       -- get message text for PQH_WKS_LESS_SRC_SUM
       -- message : Warning : For Budget funding source total of percentage under  budget element is less then 100
          pqh_utility.set_message(8302,'PQH_WKS_LESS_SRC_SUM',g_context_organization_id);
          l_message_text_out := pqh_utility.get_message;
          l_message_type     := pqh_utility.get_message_type_cd;

       -- assign warning message
          l_message_text := l_message_text_out;

          IF nvl(l_message_type,'E') = 'E' THEN
             -- set l_error_flag to Y
             l_error_flag := 'Y';
          ELSIF nvl(l_message_type,'E') = 'W' THEN
                -- this is a warning
                 l_warnings_rec.message_text  := l_message_text_out;
                 -- pqh_utility.init_warnings_table;
                 pqh_utility.insert_warning
                 (
                  p_warnings_rec => l_warnings_rec
                 );
                -- insert warning into process log
                    pqh_process_batch_log.insert_log
                    (
                     p_message_type_cd    =>  'WARNING',
                     p_message_text       =>  l_message_text
                    );
          ELSE
                -- this is ignore
                 hr_utility.set_location('Message Type in wks Periods is : '||l_message_type,6);
          END IF;

    END IF; -- CHECK # 1 check if SUM of percentage = 100


  OPEN csr_wks_fund_srcs;
    FETCH csr_wks_fund_srcs INTO l_worksheet_fund_srcs_rec;
  CLOSE csr_wks_fund_srcs;

  if l_worksheet_fund_srcs_rec.cost_allocation_keyflex_id is null then
     -- ALL PATEO columns should be there as cost allocation is null
     if l_worksheet_fund_srcs_rec.project_id is null or
        l_worksheet_fund_srcs_rec.task_id is null or
        l_worksheet_fund_srcs_rec.award_id is null or
        l_worksheet_fund_srcs_rec.expenditure_type is null or
        l_worksheet_fund_srcs_rec.organization_id is null then
        -- one of the PATEO column is missing, raise an error
        l_error_flag := 'Y';
        FND_MESSAGE.SET_NAME('PQH','PQH_BUDGET_SRC_MANDATORY');
        l_message_text_out := FND_MESSAGE.GET;
        l_message_text := l_message_text||' **** '||l_message_text_out;
     end if;
  else
     -- ALL PATEO columns should be null as cost allocation is present
     if l_worksheet_fund_srcs_rec.project_id is not null and
        l_worksheet_fund_srcs_rec.task_id is not null and
        l_worksheet_fund_srcs_rec.award_id is not null and
        l_worksheet_fund_srcs_rec.expenditure_type is not null and
        l_worksheet_fund_srcs_rec.organization_id is not null then
        -- some of the PATEO column is present alongwith cost allocation, raise an error
        l_error_flag := 'Y';
        FND_MESSAGE.SET_NAME('PQH','PQH_BUDGET_SRC_GL_GMS');
        l_message_text_out := FND_MESSAGE.GET;
        l_message_text := l_message_text||' **** '||l_message_text_out;
     end if;
  end if;
/*
       THIS IS DONE IN WORKSHEET DETAILS API
       removed on 03/23/2000
       -- CHECK # 2 check if percent is negative
        IF NVL(l_worksheet_fund_srcs_rec.distribution_percentage,0) < 0 THEN

           IF l_error_flag = 'Y' THEN
            -- there is already an error so append the message

             -- get message text for PQH_WKS_INVALID_SRC_PERCENT
             -- message : For Budget funding source percentage cannot be less then 0
                FND_MESSAGE.SET_NAME('PQH','PQH_WKS_INVALID_SRC_PERCENT');
                l_message_text_out := FND_MESSAGE.GET;

                l_message_text := l_message_text||' **** '||l_message_text_out;
           ELSE
              -- new message
               l_message_text := l_message_text_out;
           END IF;

           -- set l_error_flag to Y
             l_error_flag := 'Y';

        END IF; -- CHECK # 2 check if percent is negative
*/

       -- insert error message if l_error_flag is Y
        IF l_error_flag = 'Y' THEN
           pqh_process_batch_log.insert_log
           (
            p_message_type_cd    =>  'ERROR',
            p_message_text       =>  l_message_text
           );
        END IF; -- insert error message if l_error_flag is Y




  hr_utility.set_location('Leaving:'||l_proc, 10);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        -- end log and halt the program here
        raise g_error_exception;
END check_wks_fund_srcs;




    /*----------------------------------------------------------------
    || PROCEDURE : set_wks_log_context
    ||
    ------------------------------------------------------------------*/



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
  Root Record  ->  Display Worksheet Name

*/

 l_proc                           varchar2(72) := g_package||'set_wks_log_context';
 l_worksheet_details_rec          pqh_worksheet_details%ROWTYPE;
 l_position_name                  hr_positions.name%TYPE;
 l_job_name                       per_jobs.name%TYPE;
 l_organization_name              hr_organization_units.name%TYPE;
 l_grade_name                     per_grades.name%TYPE;

 CURSOR csr_wks_detail_rec IS
 SELECT *
 FROM pqh_worksheet_details
 WHERE worksheet_detail_id = p_worksheet_detail_id ;

CURSOR csr_ptx_name(p_position_transaction_id IN number) IS
SELECT name
FROM pqh_position_transactions
WHERE position_transaction_id = p_position_transaction_id;

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
    -- this is the main parent record , display worksheet Name
     p_log_context := g_worksheet_name;
  ELSIF NVL(l_worksheet_details_rec.action_cd , 'R') = 'D' THEN
    -- this is delegated record , display Organization Name
    p_log_context := SUBSTR(l_organization_name,1,255);
  ELSIF NVL(l_worksheet_details_rec.action_cd , 'R') = 'B' THEN
    -- this is budgeted record , display Primary Budgeted Entity
      IF     NVL(g_budgeted_entity_cd ,'OPEN') = 'POSITION' THEN
           p_log_context := SUBSTR(l_position_name,1,255);
           -- if there is no position then get name from PTX table
           IF (l_worksheet_details_rec.position_transaction_id IS NOT NULL ) AND
              (l_worksheet_details_rec.position_id  IS NULL )  THEN
                OPEN csr_ptx_name(p_position_transaction_id => l_worksheet_details_rec.position_transaction_id);
                  FETCH csr_ptx_name INTO p_log_context;
                CLOSE csr_ptx_name;
           END IF; -- ptx record
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
      p_log_context := 'When others exception in pqwkserr.pkb.set_wks_log_context';
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        -- end log and halt the program here
        raise g_error_exception;
END set_wks_log_context;




    /*----------------------------------------------------------------
    || PROCEDURE : set_wpr_log_context
    ||
    ------------------------------------------------------------------*/




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
      p_log_context := 'pqwkserr.pkb.set_wpr_log_context failed in when others';
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        -- end log and halt the program here
        raise g_error_exception;
END set_wpr_log_context;



    /*----------------------------------------------------------------
    || PROCEDURE : set_wst_log_context
    ||
    ------------------------------------------------------------------*/


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
            p_log_context := 'pqwkserr.pkb.set_wst_log_context failed in when others';
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        -- end log and halt the program here
        raise g_error_exception;
END set_wst_log_context;



    /*----------------------------------------------------------------
    || PROCEDURE : set_wel_log_context
    ||
    ------------------------------------------------------------------*/


PROCEDURE set_wel_log_context
(
  p_worksheet_bdgt_elmnt_id     IN  pqh_worksheet_bdgt_elmnts.worksheet_bdgt_elmnt_id%TYPE,
  p_log_context                 OUT NOCOPY pqh_process_log.log_context%TYPE
) IS

/*
  This procedure will set the log_context at wks budget elements level

   Display the ELEMENT_NAME
   Table : pay_element_types

  Added on 11/01/2000
  At worksheet element level, we only check for the sum of percentage . The context in this case
  will be the above budget set .

*/

 l_proc                           varchar2(72) := g_package||'set_wel_log_context';
 l_worksheet_bdgt_elmnts_rec      pqh_worksheet_bdgt_elmnts%ROWTYPE;
 l_pay_element_types_rec          pay_element_types%ROWTYPE;

 l_worksheet_budget_sets_rec      pqh_worksheet_budget_sets%ROWTYPE;
 l_dflt_budget_sets_rec           pqh_dflt_budget_sets%ROWTYPE;



 CURSOR csr_wks_bdgt_elmnts_rec IS
 SELECT *
 FROM pqh_worksheet_bdgt_elmnts
 WHERE worksheet_bdgt_elmnt_id = p_worksheet_bdgt_elmnt_id;

 CURSOR csr_pay_element_types_rec ( p_element_type_id IN number) IS
 SELECT *
 FROM pay_element_types
 WHERE element_type_id = p_element_type_id;

 CURSOR csr_wks_budget_sets_rec(p_worksheet_budget_set_id IN number) IS
 SELECT *
 FROM pqh_worksheet_budget_sets
 WHERE worksheet_budget_set_id = p_worksheet_budget_set_id;

 CURSOR csr_dflt_budget_sets_rec ( p_dflt_budget_set_id IN number) IS
 SELECT *
 FROM pqh_dflt_budget_sets
 WHERE dflt_budget_set_id = p_dflt_budget_set_id;


BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

   OPEN csr_wks_bdgt_elmnts_rec;
     FETCH csr_wks_bdgt_elmnts_rec INTO l_worksheet_bdgt_elmnts_rec;
   CLOSE csr_wks_bdgt_elmnts_rec;

/*
    OPEN csr_pay_element_types_rec(p_element_type_id => l_worksheet_bdgt_elmnts_rec.element_type_id);
      FETCH csr_pay_element_types_rec INTO l_pay_element_types_rec;
    CLOSE csr_pay_element_types_rec;
*/

   OPEN csr_wks_budget_sets_rec(p_worksheet_budget_set_id => l_worksheet_bdgt_elmnts_rec.worksheet_budget_set_id);
     FETCH csr_wks_budget_sets_rec INTO l_worksheet_budget_sets_rec;
   CLOSE csr_wks_budget_sets_rec;

    OPEN csr_dflt_budget_sets_rec(p_dflt_budget_set_id => l_worksheet_budget_sets_rec.dflt_budget_set_id);
      FETCH csr_dflt_budget_sets_rec INTO l_dflt_budget_sets_rec;
    CLOSE csr_dflt_budget_sets_rec;


     p_log_context := l_dflt_budget_sets_rec.dflt_budget_set_name;

--   p_log_context := l_pay_element_types_rec.element_name;

  hr_utility.set_location('Log Context : '||p_log_context, 101);
  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
      p_log_context := 'pqwkserr.pkb.set_wel_log_context failed in when others';
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        -- end log and halt the program here
        raise g_error_exception;
END set_wel_log_context;




    /*----------------------------------------------------------------
    || PROCEDURE : set_wfs_log_context
    ||
    ------------------------------------------------------------------*/


PROCEDURE set_wfs_log_context
(
  p_worksheet_fund_src_id       IN  pqh_worksheet_fund_srcs.worksheet_fund_src_id%TYPE,
  p_log_context                 OUT NOCOPY pqh_process_log.log_context%TYPE
) IS

/*
  This procedure will set the log_context at wks budget fund srcs level

   Display the CONCATENATED_SEGMENTS
   Table : pay_cost_allocation_keyflex

  Added on 11/01/2000. The check done at fund src level is for sum of the above budget element.
  So context will be the element name

*/

 l_proc                            varchar2(72) := g_package||'set_wfs_log_context';
 l_worksheet_fund_srcs_rec         pqh_worksheet_fund_srcs%ROWTYPE;
 l_pay_cost_allocation_kf_rec      pay_cost_allocation_keyflex%ROWTYPE;

 l_worksheet_bdgt_elmnts_rec      pqh_worksheet_bdgt_elmnts%ROWTYPE;
 l_pay_element_types_rec          pay_element_types%ROWTYPE;



 CURSOR csr_wks_bdgt_fund_srcs_rec IS
 SELECT *
 FROM pqh_worksheet_fund_srcs
 WHERE worksheet_fund_src_id = p_worksheet_fund_src_id;

 CURSOR csr_pay_cost_allocation_kf_rec ( p_cost_allocation_keyflex_id IN number) IS
 SELECT *
 FROM pay_cost_allocation_keyflex
 WHERE cost_allocation_keyflex_id = p_cost_allocation_keyflex_id;

 CURSOR csr_wks_bdgt_elmnts_rec(p_worksheet_bdgt_elmnt_id IN number) IS
 SELECT *
 FROM pqh_worksheet_bdgt_elmnts
 WHERE worksheet_bdgt_elmnt_id = p_worksheet_bdgt_elmnt_id;

 CURSOR csr_pay_element_types_rec ( p_element_type_id IN number) IS
 SELECT *
 FROM pay_element_types
 WHERE element_type_id = p_element_type_id;



BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

   OPEN csr_wks_bdgt_fund_srcs_rec;
     FETCH csr_wks_bdgt_fund_srcs_rec INTO l_worksheet_fund_srcs_rec;
   CLOSE csr_wks_bdgt_fund_srcs_rec;

   OPEN csr_wks_bdgt_elmnts_rec(p_worksheet_bdgt_elmnt_id => l_worksheet_fund_srcs_rec.worksheet_bdgt_elmnt_id);
     FETCH csr_wks_bdgt_elmnts_rec INTO l_worksheet_bdgt_elmnts_rec;
   CLOSE csr_wks_bdgt_elmnts_rec;

    OPEN csr_pay_element_types_rec(p_element_type_id => l_worksheet_bdgt_elmnts_rec.element_type_id);
      FETCH csr_pay_element_types_rec INTO l_pay_element_types_rec;
    CLOSE csr_pay_element_types_rec;

  p_log_context := l_pay_element_types_rec.element_name;


/*
    OPEN csr_pay_cost_allocation_kf_rec(p_cost_allocation_keyflex_id => l_worksheet_fund_srcs_rec.cost_allocation_keyflex_id);
      FETCH csr_pay_cost_allocation_kf_rec INTO l_pay_cost_allocation_kf_rec;
    CLOSE csr_pay_cost_allocation_kf_rec;
*/


   -- p_log_context := l_pay_cost_allocation_kf_rec.concatenated_segments;


  hr_utility.set_location('Log Context : '||p_log_context, 101);
  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
      p_log_context := 'pqwkserr.pkb.set_wfs_log_context failed in when others';
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        -- end log and halt the program here
        raise g_error_exception;
END set_wfs_log_context;


-- added on 03/28/2000 for the new rqmt that the batch header is wks detail record
-- and not the wks id as was previously designed

    /*----------------------------------------------------------------
    || PROCEDURE : check_input_wks_details
    ||
    ------------------------------------------------------------------*/



PROCEDURE check_input_wks_details
(
  p_worksheet_detail_id     IN pqh_worksheet_details.worksheet_detail_id%TYPE
) IS

/*
  This procedure will check if all the input wks detail records i.e the main node is valid
  and report all the errors
  For budgeted records we check if there are rows in periods
  For the input wks dtl ID there must be atleast one budgeted record under this node
*/

 l_proc                           varchar2(72) := g_package||'check_input_wks_details';
 l_worksheet_details_rec          pqh_worksheet_details%ROWTYPE;
 l_message_text                   pqh_process_log.message_text%TYPE;
 l_message_text_out               fnd_new_messages.message_text%TYPE;
 l_count                          number;
 l_budget_count                   number;
 l_error_flag                     varchar2(10) := 'N';


CURSOR csr_wks_details IS
SELECT *
FROM pqh_worksheet_details
WHERE worksheet_detail_id = p_worksheet_detail_id;

CURSOR csr_wks_periods_count IS
SELECT COUNT(*)
FROM pqh_worksheet_periods
WHERE worksheet_detail_id = p_worksheet_detail_id;

CURSOR csr_budget_count  IS
 SELECT  COUNT(*)
 FROM pqh_worksheet_details wdt
 WHERE action_cd = 'B'
 START WITH worksheet_detail_id = p_worksheet_detail_id
 CONNECT BY prior worksheet_detail_id = parent_worksheet_detail_id ;


BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

  OPEN csr_wks_details;
     FETCH csr_wks_details INTO l_worksheet_details_rec;
  CLOSE csr_wks_details;


       -- CHECK # 1 for budgeted records check rows in periods
        IF  NVL(l_worksheet_details_rec.action_cd , 'R') ='B'  THEN
          -- this is budgeted record
            OPEN csr_wks_periods_count;
              FETCH csr_wks_periods_count INTO l_count;
            CLOSE csr_wks_periods_count;

            IF NVL(l_count,0) = 0 THEN

               hr_utility.set_location('WKS Detail Error 3 PQH_WKS_NO_PERIODS '||l_worksheet_details_rec.worksheet_detail_id,10);

                  -- get message text for PQH_WKS_NO_PERIODS
                  -- message : No Periods Defined for the budgeted entity
                     FND_MESSAGE.SET_NAME('PQH','PQH_WKS_NO_PERIODS');
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
        END IF; -- CHECK # 1 for budgeted records check rows in periods


       -- CHECK # 2 check if available amount is >= 0  for all records

       IF ( NVL(l_worksheet_details_rec.budget_unit1_available,0) < 0  ) OR
          ( NVL(l_worksheet_details_rec.budget_unit2_available,0) < 0  ) OR
          ( NVL(l_worksheet_details_rec.budget_unit3_available,0) < 0  ) THEN

           hr_utility.set_location('WKS Detail Error 4 PQH_WKS_DEL_ALL_AMT '||l_worksheet_details_rec.worksheet_detail_id,10);

               -- get message text for PQH_WKS_DEL_ALL_AMT
               -- message : Budget Amount in the delegated organization exceeds the allocated amount
                  FND_MESSAGE.SET_NAME('PQH','PQH_WKS_DEL_ALL_AMT');
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


        END IF; -- CHECK # 2 check if available amount is >= 0

        -- CHECK # 3 check if atleast one record under the input node is Budgeted

            OPEN csr_budget_count;
              FETCH csr_budget_count INTO l_budget_count;
            CLOSE csr_budget_count;

            IF NVL(l_budget_count,0) = 0 THEN

               -- get message text for PQH_WKS_NO_BDT_RECS
               -- message : There must be atleast one Budgeted entity
                  FND_MESSAGE.SET_NAME('PQH','PQH_WKS_NO_BDT_RECS');
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

            END IF;  -- End CHECK # 3 check if atleast one record under the input node is Budgeted

          hr_utility.set_location('Error Flag : '||l_error_flag,10);

          -- insert error message if l_error_flag is Y
           IF l_error_flag = 'Y' THEN

             -- end the process log as the  batch itself has error

                updt_batch
                (
                  p_message_text    =>  l_message_text
                );

           --    UPDATE pqh_process_log
           --    SET message_type_cd =  'ERROR',
           --        message_text   = l_message_text,
           --        txn_table_route_id    =  g_table_route_id_wdt,
           --        batch_status    = 'ERROR',
           --        batch_end_date  = sysdate
           --    WHERE process_log_id = pqh_process_batch_log.g_master_process_log_id;

                 -- set the batch status to error
                 g_batch_status := 'ERROR';

            END IF; -- insert error message if l_error_flag is Y


  hr_utility.set_location('Leaving:'||l_proc, 10);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END check_input_wks_details;



    /*----------------------------------------------------------------
    || PROCEDURE : end_log
    ||
    ------------------------------------------------------------------*/

PROCEDURE end_log
IS

--
-- local variables
--
l_proc                  varchar2(72) := g_package||'end_log';
l_count_error           NUMBER := 0;
l_count_warning         NUMBER := 0;
l_status                VARCHAR2(30);
l_pqh_process_log_rec   pqh_process_log%ROWTYPE;


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

PRAGMA                  AUTONOMOUS_TRANSACTION;


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
      g_batch_status := 'ERROR';
   ELSE
     -- errors are 0 , check for warnings
      IF l_count_warning <> 0 THEN
        -- there are one or more warnings
        l_status := 'WARNING';
        g_batch_status := 'WARNING';
      ELSE
        -- no errors or warnings
         l_status := 'SUCCESS';
         g_batch_status := 'SUCCESS';
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
          txn_table_route_id    =  g_table_route_id_wdt,
          batch_status = l_status,
          batch_end_date  = sysdate
      WHERE process_log_id = pqh_process_batch_log.g_master_process_log_id;
    ELSE
      -- there were errors in the batch header record i.w the root node
      -- so only update the batch status and end date
      UPDATE pqh_process_log
      SET batch_status = l_status,
          batch_end_date  = sysdate,
          txn_table_route_id    =  g_table_route_id_wdt
      WHERE process_log_id = pqh_process_batch_log.g_master_process_log_id;
    END IF;


  hr_utility.set_location('Leaving:'||l_proc, 1000);

 /*
   commit the transaction
 */

     commit;


EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END end_log;



    /*----------------------------------------------------------------
    || PROCEDURE : updt_batch
    ||
    ------------------------------------------------------------------*/

PROCEDURE updt_batch
(
 p_message_text   IN pqh_process_log.message_text%TYPE
)
IS
--
-- local variables
--
l_proc                  varchar2(72) := g_package||'updt_batch';
l_message_text          pqh_process_log.message_text%TYPE;

PRAGMA                  AUTONOMOUS_TRANSACTION;

BEGIN

  hr_utility.set_location('Entering: '||l_proc, 5);


    UPDATE pqh_process_log
    SET message_type_cd =  'ERROR',
      message_text   = p_message_text,
      txn_table_route_id    =  g_table_route_id_wdt,
      batch_status    = 'ERROR',
      batch_end_date  = sysdate
    WHERE process_log_id = pqh_process_batch_log.g_master_process_log_id;

/*
   Commit the autonomous txn
*/

         commit;

  hr_utility.set_location('Leaving: '||l_proc, 100);

EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END updt_batch;



    /*----------------------------------------------------------------
    || PROCEDURE : check_wks_dates
    ||
    ------------------------------------------------------------------*/

PROCEDURE check_wks_dates
(
  p_worksheet_detail_id     IN pqh_worksheet_details.worksheet_detail_id%TYPE,
  p_status                  OUT NOCOPY varchar2,
  p_message                 OUT NOCOPY varchar2
) IS
/*
  This procedure will call Sumit's procedure to check if the wks dates are valid
  If not we will populate the log and abort the program
*/
--
-- local variables
--
l_proc                           varchar2(72) := g_package||'check_wks_dates';
l_worksheets_rec                 pqh_worksheets%ROWTYPE;
l_wks_ll_date                    date;
l_wks_ul_date                    date;
l_status                         varchar2(10);
l_message_text_out               fnd_new_messages.message_text%TYPE;
l_pc_start_date                  date;
l_pc_end_date                    date;
l_pc_bdgt_name                   varchar2(80);
l_pc_version_no                  number(9);
l_budgets_rec                    pqh_budgets%ROWTYPE;

CURSOR csr_worksheet_rec IS
SELECT *
FROM pqh_worksheets
WHERE worksheet_id =
(
  SELECT wks.worksheet_id
  FROM pqh_worksheets wks, pqh_worksheet_details wdt
  WHERE wdt.worksheet_id = wks.worksheet_id
  AND  wdt.worksheet_detail_id = p_worksheet_detail_id
);

CURSOR csr_budgets_rec(p_budget_id IN number) IS
SELECT *
FROM pqh_budgets
WHERE budget_id = p_budget_id ;

BEGIN

  hr_utility.set_location('Entering: '||l_proc, 5);

  OPEN csr_worksheet_rec;
    FETCH csr_worksheet_rec INTO l_worksheets_rec;
  CLOSE csr_worksheet_rec;

  pqh_wks_budget.wks_date_validation
  (
   p_worksheet_mode            => l_worksheets_rec.worksheet_mode_cd,
   p_budget_id                 => l_worksheets_rec.budget_id,
   p_budget_version_id         => l_worksheets_rec.budget_version_id,
   p_wks_start_date            => l_worksheets_rec.date_from,
   p_wks_end_date              => l_worksheets_rec.date_to,
   p_wks_ll_date               => l_wks_ll_date,
   p_wks_ul_date               => l_wks_ul_date,
   p_status                    => l_status
  );

  IF NVL(l_status,'ERROR') = 'ERROR' THEN
     -- get message text for PQH_WKS_VALID_DATES
    FND_MESSAGE.SET_NAME('PQH','PQH_WKS_VALID_DATES');
    FND_MESSAGE.SET_TOKEN('LL',l_wks_ll_date);
    FND_MESSAGE.SET_TOKEN('UL',l_wks_ul_date);
    l_message_text_out := FND_MESSAGE.GET;
    p_message := l_message_text_out;

    p_status  := 'ERROR';

  ELSE

   p_message := '';
   p_status  := 'SUCCESS';

  END IF;

  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
      p_status := 'ERROR';
      p_message := 'Erroring out in pqwkserr.pkb.check_wks_dates';
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END check_wks_dates;


    /*----------------------------------------------------------------
    || PROCEDURE : check_pc_posn
    ||
    ------------------------------------------------------------------*/
PROCEDURE check_pc_posn
(
  p_position_id             IN pqh_worksheet_details.position_id%TYPE,
  p_status                  OUT NOCOPY varchar2
) IS
/*
  This procedure will check if the position is already budgeted in any other budget
*/
--
-- local variables
--
l_proc                           varchar2(72) := g_package||'check_pc_posn';

CURSOR csr_budget_id IS
SELECT DISTINCT bgt.budget_id
FROM pqh_budgets bgt, pqh_budget_versions bvr, pqh_budget_details bdt
WHERE bgt.budget_id = bvr.budget_id
  AND bvr.budget_version_id = bdt.budget_version_id
  AND bdt.position_id = p_position_id
  AND NVL(bgt.position_control_flag,'X') = 'Y'
  AND bgt.budget_id <> g_budget_id;

CURSOR csr_budget_rec(p_budget_id IN number) IS
SELECT *
FROM pqh_budgets
WHERE budget_id = p_budget_id;

CURSOR csr_lookup(p_shared_type_id IN number) IS
SELECT system_type_cd
FROM per_shared_types
WHERE shared_type_id = NVL(p_shared_type_id,-1);

l_budget_id     pqh_budgets.budget_id%TYPE;
l_budget_rec    pqh_budgets%ROWTYPE;

l_curr_lookup1  varchar2(50) := 'A';
l_curr_lookup2  varchar2(50) := 'B';
l_curr_lookup3  varchar2(50) := 'C';

l_pc_lookup1  varchar2(50);
l_pc_lookup2  varchar2(50);
l_pc_lookup3  varchar2(50);


BEGIN

  hr_utility.set_location('Entering: '||l_proc, 5);

  --  start with success and mark error if found
      p_status := 'SUCCESS';

  -- get the lookup codes for current budget
     OPEN csr_lookup(p_shared_type_id => g_budget_unit1_id);
       FETCH csr_lookup INTO l_curr_lookup1;
     CLOSE csr_lookup;

     OPEN csr_lookup(p_shared_type_id => g_budget_unit2_id);
       FETCH csr_lookup INTO l_curr_lookup2;
     CLOSE csr_lookup;

     OPEN csr_lookup(p_shared_type_id => g_budget_unit3_id);
       FETCH csr_lookup INTO l_curr_lookup3;
     CLOSE csr_lookup;

  OPEN csr_budget_id;
    LOOP
      FETCH csr_budget_id INTO l_budget_id;
      EXIT WHEN csr_budget_id%NOTFOUND;
       -- get details for this budget
         OPEN csr_budget_rec(p_budget_id => l_budget_id);
           FETCH csr_budget_rec INTO l_budget_rec;
         CLOSE csr_budget_rec;

         -- compare fiscal periods
           IF (l_budget_rec.budget_start_date BETWEEN g_budget_start_dt AND g_budget_end_dt ) OR
              (l_budget_rec.budget_end_date BETWEEN g_budget_start_dt AND g_budget_end_dt )   OR
              (g_budget_start_dt BETWEEN l_budget_rec.budget_start_date AND l_budget_rec.budget_end_date) OR
              (g_budget_end_dt BETWEEN l_budget_rec.budget_start_date AND l_budget_rec.budget_end_date)THEN
               -- there is a FISCAL PERIOD OVERLAP, compare UOM lookup codes
               -- initialize and get the loopup codes for this budget
                 l_pc_lookup1 := 'X';
                 l_pc_lookup1 := 'Y';
                 l_pc_lookup1 := 'Z';
                 OPEN csr_lookup(p_shared_type_id => l_budget_rec.budget_unit1_id);
                   FETCH csr_lookup INTO l_pc_lookup1;
                 CLOSE csr_lookup;

                 OPEN csr_lookup(p_shared_type_id => l_budget_rec.budget_unit2_id);
                   FETCH csr_lookup INTO l_pc_lookup2;
                 CLOSE csr_lookup;

                 OPEN csr_lookup(p_shared_type_id => l_budget_rec.budget_unit3_id);
                   FETCH csr_lookup INTO l_pc_lookup3;
                 CLOSE csr_lookup;

                -- compare if UOM lookup codes overlap
                IF l_pc_lookup1 IN ( l_curr_lookup1, l_curr_lookup2, l_curr_lookup3 ) OR
                   l_pc_lookup2 IN ( l_curr_lookup1, l_curr_lookup2, l_curr_lookup3 ) OR
                   l_pc_lookup3 IN ( l_curr_lookup1, l_curr_lookup2, l_curr_lookup3 ) THEN
                     -- lookup codes match too , sor this is ERROR
                      p_status := 'ERROR';
                      exit; -- exit the loop
                END IF;

           END IF ; -- FISCAL PERIODS OVERLAP
    END LOOP;
  CLOSE csr_budget_id;


  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
      p_status := 'ERROR';
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
END check_pc_posn;






END ;  -- end of body for package pqh_wks_error_chk

/
