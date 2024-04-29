--------------------------------------------------------
--  DDL for Package Body PQH_BUDGET_DATA_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BUDGET_DATA_MIGRATION" as
/* $Header: pqbdgmig.pkb 120.2 2006/02/06 14:27:56 nsanghal noship $ */
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_budget_data_migration.';  -- Global package name
--
g_table_route_id_p_bgt      number;
g_table_route_id_p_bvr      number;
g_table_route_id_p_bdt      number;
g_table_route_id_p_bpr      number;
g_table_route_id_dst        number;
g_table_route_id_del        number;
g_table_route_id_dfs        number;
g_error_exception          exception;


--
/*--------------------------------------------------------------------------------------------------------------

    Main Procedure
--------------------------------------------------------------------------------------------------------------*/

PROCEDURE extract_data
(
 errbuf                    OUT NOCOPY  VARCHAR2,
 retcode                   OUT NOCOPY  VARCHAR2,
 p_budget_name             IN  per_budgets.name%TYPE DEFAULT NULL,
 p_budget_set_name         IN  pqh_dflt_budget_sets.dflt_budget_set_name%TYPE,
 p_business_group_id       IN  per_budgets.business_group_id%TYPE
)
IS
-- local variables and cursors

CURSOR per_budget_cur IS
 SELECT *
 FROM per_budgets
 WHERE name = NVL(p_budget_name, name)
   AND business_group_id  = p_business_group_id
   AND NVL(budget_type_code,'X') <> 'OTA_BUDGET' ;

CURSOR per_budget_ver_cur (p_budget_id  IN per_budgets.budget_id%TYPE) IS
 SELECT *
 FROM  per_budget_versions
 WHERE budget_id = p_budget_id;

CURSOR per_budget_elmnt_cur (p_budget_version_id  IN per_budget_versions.budget_version_id%TYPE) IS
 SELECT *
 FROM  per_budget_elements
 WHERE  budget_version_id = p_budget_version_id;

CURSOR per_budget_val_cur (p_budget_element_id  IN  per_budget_elements.budget_element_id%TYPE) IS
 SELECT *
 FROM  per_budget_values
 WHERE budget_element_id = p_budget_element_id;


l_proc                       varchar2(72) := g_package||'extract_data';
l_per_budget_rec             per_budgets%ROWTYPE;
l_budget_id                  pqh_budgets.budget_id%TYPE;
l_tot_budget_val             per_budget_values.value%TYPE;
l_per_budget_ver_rec         per_budget_versions%ROWTYPE;
l_budget_version_id          pqh_budget_versions.budget_version_id%TYPE;
l_per_budget_elmnt_rec       per_budget_elements%ROWTYPE;
l_budget_detail_id           pqh_budget_details.budget_detail_id%TYPE;
l_budget_unit1_value         pqh_budget_details.budget_unit1_value%TYPE;
l_per_budget_val_rec         per_budget_values%ROWTYPE;
l_budget_period_id           pqh_budget_periods.budget_period_id%TYPE;
l_log_context                pqh_process_log.log_context%TYPE;
l_valid                      varchar2(10);


BEGIN

  hr_utility.set_location('Entering: '||l_proc, 5);

   -- check input params
    check_params
    (
      p_budget_name     =>  p_budget_name,
      p_budget_set_name => p_budget_set_name,
      p_business_group_id => p_business_group_id
    );

   -- populate the globals
     populate_globals;

   -- populate the per_shared_types table with user defined codes
   populate_per_shared_types;


  -- open the per_budget_cursor
  OPEN per_budget_cur;
   LOOP  -- loop 1
    FETCH per_budget_cur INTO l_per_budget_rec;
    EXIT WHEN per_budget_cur%NOTFOUND;

     -- Start the Log Process
       pqh_process_batch_log.start_log
       (
        p_batch_id       => l_per_budget_rec.budget_id,
        p_module_cd      => 'MIGRATE_BUDGETS',
        p_log_context    => l_per_budget_rec.name
       );

       -- get log_context
         set_p_bgt_log_context
         (
         p_budget_id     => l_per_budget_rec.budget_id,
         p_log_context   => l_log_context
         );

       -- set the context
          pqh_process_batch_log.set_context_level
          (
          p_txn_id                =>  l_per_budget_rec.budget_id,
          p_txn_table_route_id    =>  g_table_route_id_p_bgt,
          p_level                 =>  1,
          p_log_context           =>  l_log_context
          );

      -- check if budget is valid
         check_valid_budget
         (
           p_per_budgets_rec   =>  l_per_budget_rec,
           p_valid             =>  l_valid
         );

      --  create records in pqh_budgets
      populate_budgets
      (
       p_per_budgets_rec         =>  l_per_budget_rec,
       p_valid                   =>  l_valid,
       p_budget_id_o             =>  l_budget_id,
       p_tot_budget_val_o        =>  l_tot_budget_val
      );

   -- open the per_budget_ver_cursor
     OPEN per_budget_ver_cur (p_budget_id  => l_per_budget_rec.budget_id );
      LOOP  -- loop 2
       FETCH per_budget_ver_cur INTO l_per_budget_ver_rec;
       EXIT WHEN per_budget_ver_cur%NOTFOUND;

       -- get log_context
         set_p_bvr_log_context
         (
         p_budget_version_id     => l_per_budget_ver_rec.budget_version_id,
         p_log_context           => l_log_context
         );

       -- set the context
          pqh_process_batch_log.set_context_level
          (
          p_txn_id                =>  l_per_budget_ver_rec.budget_version_id,
          p_txn_table_route_id    =>  g_table_route_id_p_bvr,
          p_level                 =>  2,
          p_log_context           =>  l_log_context
          );

          --  create records in pqh_budget_versions
              populate_budget_versions
              (
               p_per_budget_ver_rec    =>  l_per_budget_ver_rec,
               p_budget_id             =>  l_budget_id,
               p_budget_version_id_o   =>  l_budget_version_id
               );


        -- open the per_budget_elmnt_cursor
        OPEN per_budget_elmnt_cur (p_budget_version_id  => l_per_budget_ver_rec.budget_version_id);
         LOOP  -- loop 3
          FETCH per_budget_elmnt_cur INTO l_per_budget_elmnt_rec;
          EXIT WHEN per_budget_elmnt_cur%NOTFOUND;

       -- get log_context
         set_p_bdt_log_context
         (
         p_budget_element_id     => l_per_budget_elmnt_rec.budget_element_id,
         p_log_context           => l_log_context
         );

       -- set the context
          pqh_process_batch_log.set_context_level
          (
          p_txn_id                =>  l_per_budget_elmnt_rec.budget_element_id,
          p_txn_table_route_id    =>  g_table_route_id_p_bdt,
          p_level                 =>  3,
          p_log_context           =>  l_log_context
          );


           -- create records in pqh_budget_details
           populate_budget_details
           (
            p_per_budget_elmnt_rec       => l_per_budget_elmnt_rec,
            p_budget_version_id          => l_budget_version_id,
            p_tot_budget_val             => l_tot_budget_val,
            p_budget_detail_id_o         => l_budget_detail_id,
            p_budget_unit1_value_o       => l_budget_unit1_value
           );

            -- open the per_budget_val_cursor
             OPEN per_budget_val_cur (p_budget_element_id  =>  l_per_budget_elmnt_rec.budget_element_id);
              LOOP   -- loop 4
               FETCH per_budget_val_cur  INTO l_per_budget_val_rec;
               EXIT WHEN per_budget_val_cur%NOTFOUND;

               -- get log_context
                 set_p_bpr_log_context
                 (
                   p_budget_value_id     => l_per_budget_val_rec.budget_value_id,
                   p_log_context         => l_log_context
                 );

                 -- set the context
                    pqh_process_batch_log.set_context_level
                    (
                      p_txn_id                =>  l_per_budget_val_rec.budget_value_id,
                      p_txn_table_route_id    =>  g_table_route_id_p_bpr,
                      p_level                 =>  4,
                      p_log_context           =>  l_log_context
                    );


             -- create records in pqh_budget_periods
             populate_budget_periods
             (
              p_per_budget_val_rec         =>  l_per_budget_val_rec,
              p_budget_detail_id           =>  l_budget_detail_id,
              p_budget_unit1_value         =>  l_budget_unit1_value,
              p_budget_period_id_o         =>  l_budget_period_id
             );


             -- create records into budget sets, elmnts and fund srcs
             -- new rqmt as on 03/20/2000
              populate_period_details
             (
              p_budget_period_id         =>  l_budget_period_id,
              p_budget_set_name          =>  p_budget_set_name
             );


            END LOOP;  -- loop 4
           CLOSE  per_budget_val_cur;


         END LOOP; -- loop 3
        CLOSE per_budget_elmnt_cur;


      END LOOP;  -- loop 2
     CLOSE per_budget_ver_cur;



    -- end the log for thr current budget id
        pqh_process_batch_log.end_log;

   END LOOP;  -- loop 1
  CLOSE per_budget_cur;


  -- populate pqh_budget_versions with default row for those budgets that do not have child rows
  -- in pqh_budget_versions

     populate_empty_budget_versions;

  -- commit the work;
  commit;
  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
  WHEN g_error_exception THEN
    -- call the end log and stop
     pqh_process_batch_log.end_log;
  WHEN others THEN
     raise;
END extract_data;


--------------------------------------------------------------------------------------------------------------

PROCEDURE populate_budgets
(
 p_per_budgets_rec         IN  per_budgets%ROWTYPE,
 p_valid                   IN  varchar2,
 p_budget_id_o             OUT NOCOPY pqh_budgets.budget_id%TYPE,
 p_tot_budget_val_o        OUT NOCOPY per_budget_values.value%TYPE
)
IS
-- local variables and cursors

l_proc                        varchar2(72) := g_package||'populate_budgets';
l_budgeted_entity_cd          pqh_budgets.budgeted_entity_cd%TYPE := 'OPEN';
l_budget_style_cd             pqh_budgets.budget_style_cd%TYPE := 'BOTTOM';
l_budget_start_date           pqh_budgets.budget_start_date%TYPE;
l_budget_end_date             pqh_budgets.budget_end_date%TYPE;
l_object_version_number       pqh_budgets.object_version_number%TYPE;
l_tot_budget_val              per_budget_values.value%TYPE;
l_shared_type_id              pqh_budgets.budget_unit1_id%TYPE;
l_status                      pqh_budgets.status%TYPE;
l_budget_unit1_aggregate      pqh_budgets.budget_unit1_aggregate%TYPE := 'ACCUMULATE';


-- cursor to compute budget start and end dates

CURSOR budget_date_cur IS
SELECT MIN(start_date),  MAX(end_date)
FROM per_time_periods
WHERE time_period_id IN
                     (
                      SELECT val.time_period_id
                      FROM  per_budget_values val,
                            per_budget_elements ele,
                            per_budget_versions ver
                      WHERE val.budget_element_id = ele.budget_element_id
                        AND ele.budget_version_id = ver.budget_version_id
                        AND ver.budget_id = p_per_budgets_rec.budget_id
                      );


-- cursor to compute budget start and end dates for budget with no child records
-- in per_budget_values

CURSOR budget_cal_cur IS
SELECT start_date, start_date
FROM pay_calendars
WHERE period_set_name = p_per_budgets_rec.period_set_name;

-- cursor for unit1_value for ALL versions of the budget
-- this is used to compute the percentage at detail level

CURSOR tot_unit1_val_cur IS
 SELECT SUM(value)
 FROM per_budget_values
 WHERE budget_element_id IN
                          ( SELECT ele.budget_element_id
                            FROM per_budget_elements ele,
                                 per_budget_versions ver
                           WHERE  ele.budget_version_id = ver.budget_version_id
                             AND  ver.budget_id = p_per_budgets_rec.budget_id
                          );


BEGIN

 hr_utility.set_location('Entering: '||l_proc, 5);

IF p_valid = 'Y' THEN

  -- compute the budget start and end date
  /*
    Start date is the minimum date in per_budget_values for the current budget_id
    End date is the maximum date in per_budget_values for the current budget_id
    If the budget has no records in per_budget_values then we get the start and end date
    for the calender
  */

  OPEN budget_date_cur;
    FETCH budget_date_cur INTO l_budget_start_date, l_budget_end_date;
  CLOSE budget_date_cur;

  IF (l_budget_start_date IS NULL ) OR ( l_budget_end_date IS NULL ) THEN
    OPEN budget_cal_cur;
      FETCH budget_cal_cur INTO l_budget_start_date, l_budget_end_date;
    CLOSE budget_cal_cur;
  END IF;

   hr_utility.set_location('Per Budget Id: '||p_per_budgets_rec.budget_id, 10);
   hr_utility.set_location('Start Date: '||l_budget_start_date, 15);
   hr_utility.set_location('End Date: '||l_budget_end_date, 20);

  -- get the shared_type_id for UOM

   l_shared_type_id := get_shared_type_id (p_unit => p_per_budgets_rec.unit );

  -- compute budget status, if unit is null then status is null else status is FROZEN

    IF  p_per_budgets_rec.unit IS NULL THEN
      l_status := '';
    ELSE
      l_status := 'FROZEN';
    END IF;

   hr_utility.set_location('Shared Id : '||l_shared_type_id, 25);

  -- compute total budget value
  OPEN tot_unit1_val_cur;
    FETCH tot_unit1_val_cur INTO  l_tot_budget_val;
     p_tot_budget_val_o := l_tot_budget_val;
  CLOSE tot_unit1_val_cur;

   hr_utility.set_location('l_budget_unit1_aggregate : '||l_budget_unit1_aggregate,26);

  -- call insert API
  pqh_budgets_api.create_budget
  (
   p_validate                       =>   false
  ,p_budget_id                      =>   p_budget_id_o
  ,p_business_group_id              =>   p_per_budgets_rec.business_group_id
  ,p_start_organization_id          =>   null
  ,p_org_structure_version_id       =>   null
  ,p_budgeted_entity_cd             =>   l_budgeted_entity_cd
  ,p_budget_style_cd                =>   l_budget_style_cd
  ,p_budget_name                    =>   p_per_budgets_rec.name
  ,p_period_set_name                =>   p_per_budgets_rec.period_set_name
  ,p_budget_start_date              =>   l_budget_start_date
  ,p_budget_end_date                =>   l_budget_end_date
  ,p_budget_unit1_id                =>   l_shared_type_id
  ,p_budget_unit2_id                =>   null
  ,p_budget_unit3_id                =>   null
  ,p_transfer_to_gl_flag            =>   null
  ,p_status                         =>   l_status
  ,p_object_version_number          =>   l_object_version_number
  ,p_effective_date                 =>   sysdate
  ,p_gl_set_of_books_id             =>   null
  ,p_budget_unit1_aggregate         =>   l_budget_unit1_aggregate
  ,p_budget_unit2_aggregate         =>   null
  ,p_budget_unit3_aggregate         =>   null
  );


END IF; -- p_valid = Y

 hr_utility.set_location('PQH Budget ID OUT NOCOPY : '||p_budget_id_o, 100);

 hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
  WHEN others THEN

 p_budget_id_o		:= null;
 p_tot_budget_val_o	:= null;
   -- insert error into log table
      pqh_process_batch_log.insert_log
      (
       p_message_type_cd    =>  'ERROR',
       p_message_text       =>  SQLERRM
      );
END populate_budgets;


--------------------------------------------------------------------------------------------------------------

PROCEDURE populate_budget_versions
(
 p_per_budget_ver_rec  IN    per_budget_versions%ROWTYPE,
 p_budget_id           IN    pqh_budgets.budget_id%TYPE,
 p_budget_version_id_o OUT NOCOPY   pqh_budget_versions.budget_version_id%TYPE
)
IS
-- local variables and cursors

l_proc                        varchar2(72) := g_package||'populate_budget_versions';
l_object_version_number       pqh_budget_versions.object_version_number%TYPE;
l_budget_unit1_value          pqh_budget_versions.budget_unit1_value%TYPE;
l_budget_unit1_available      pqh_budget_versions.budget_unit1_available%TYPE := 0;


-- cursor for unit1_value
CURSOR unit1_val_cur IS
 SELECT SUM(val.value)
 FROM per_budget_values val
 WHERE budget_element_id IN
  ( SELECT DISTINCT budget_element_id
    FROM per_budget_elements
    WHERE budget_version_id = p_per_budget_ver_rec.budget_version_id);

BEGIN

 hr_utility.set_location('Entering: '||l_proc, 5);

IF p_budget_id IS NOT NULL THEN

 -- compute unit1
  OPEN unit1_val_cur;
    FETCH unit1_val_cur INTO l_budget_unit1_value;
  CLOSE unit1_val_cur;

 -- call insert API
 pqh_budget_versions_api.create_budget_version
(
   p_validate                       =>   false
  ,p_budget_version_id              =>   p_budget_version_id_o
  ,p_budget_id                      =>   p_budget_id
  ,p_version_number                 =>   p_per_budget_ver_rec.version_number
  ,p_date_from                      =>   p_per_budget_ver_rec.date_from
  ,p_date_to                        =>   p_per_budget_ver_rec.date_to
  ,p_transfered_to_gl_flag          =>   null
  ,p_xfer_to_other_apps_cd          =>   null
  ,p_object_version_number          =>   l_object_version_number
  ,p_budget_unit1_value             =>   l_budget_unit1_value
  ,p_budget_unit1_available         =>   l_budget_unit1_available
  ,p_effective_date                 =>   sysdate
 );


END IF; -- p_budget_id not null

 hr_utility.set_location('PQH Budget Version out '||p_budget_version_id_o, 15);
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
 p_per_budget_elmnt_rec       IN  per_budget_elements%ROWTYPE,
 p_budget_version_id          IN  pqh_budget_versions.budget_version_id%TYPE,
 p_tot_budget_val             IN  per_budget_values.value%TYPE,
 p_budget_detail_id_o         OUT NOCOPY pqh_budget_details.budget_detail_id%TYPE,
 p_budget_unit1_value_o       OUT NOCOPY pqh_budget_details.budget_unit1_value%TYPE
)
IS
-- local variables and cursors

l_proc                        varchar2(72) := g_package||'populate_budget_details';
l_object_version_number       pqh_budget_details.object_version_number%TYPE;
l_budget_unit1_value_type_cd           pqh_budget_details.budget_unit1_value_type_cd%TYPE := 'V';
l_budget_unit1_value          pqh_budget_details.budget_unit1_value%TYPE;
l_budget_unit1_percent        pqh_budget_details.budget_unit1_percent%TYPE;
l_budget_unit1_available       pqh_budget_details.budget_unit1_available%TYPE := 0;

-- cursor for unit1_value
CURSOR unit1_val_cur IS
 SELECT SUM(val.value)
 FROM per_budget_values val
 WHERE budget_element_id = p_per_budget_elmnt_rec.budget_element_id;


BEGIN

 hr_utility.set_location('Entering: '||l_proc, 5);

IF p_budget_version_id IS NOT NULL THEN

  -- compute l_budget_unit1_value
    OPEN unit1_val_cur;
      FETCH unit1_val_cur INTO l_budget_unit1_value;
      p_budget_unit1_value_o := l_budget_unit1_value;
    CLOSE unit1_val_cur;

  -- compute l_budget_unit1_percent
     l_budget_unit1_percent := (l_budget_unit1_value/p_tot_budget_val) * 100 ;

  -- call insert API
  pqh_budget_details_api.create_budget_detail
(
   p_validate                       =>  false
  ,p_budget_detail_id               =>  p_budget_detail_id_o
  ,p_organization_id                =>  p_per_budget_elmnt_rec.organization_id
  ,p_job_id                         =>  p_per_budget_elmnt_rec.job_id
  ,p_position_id                    =>  p_per_budget_elmnt_rec.position_id
  ,p_grade_id                       =>  p_per_budget_elmnt_rec.grade_id
  ,p_budget_version_id              =>  p_budget_version_id
  ,p_budget_unit1_percent           =>  l_budget_unit1_percent
  ,p_budget_unit1_value_type_cd              =>  l_budget_unit1_value_type_cd
  ,p_budget_unit1_value             =>  l_budget_unit1_value
  ,p_budget_unit1_available          =>  l_budget_unit1_available
  ,p_budget_unit2_percent           =>  null
  ,p_budget_unit2_value_type_cd              =>  null
  ,p_budget_unit2_value             =>  null
  ,p_budget_unit2_available          =>  null
  ,p_budget_unit3_percent           =>  null
  ,p_budget_unit3_value_type_cd              =>  null
  ,p_budget_unit3_value             =>  null
  ,p_budget_unit3_available          =>  null
  ,p_object_version_number          =>  l_object_version_number
 );

END IF;  -- p_budget_version_id is not null

 hr_utility.set_location('PQH Budget Detail ID out '||p_budget_detail_id_o, 100);
 hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
  WHEN others THEN
p_budget_detail_id_o    := null;
 p_budget_unit1_value_o := null;
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
 p_per_budget_val_rec         IN  per_budget_values%ROWTYPE,
 p_budget_detail_id           IN  pqh_budget_details.budget_detail_id%TYPE,
 p_budget_unit1_value         IN  pqh_budget_details.budget_unit1_value%TYPE,
 p_budget_period_id_o         OUT NOCOPY pqh_budget_periods.budget_period_id%TYPE
)
IS
-- local variables and cursors

l_proc                        varchar2(72) := g_package||'populate_budget_periods';
l_object_version_number       pqh_budget_periods.object_version_number%TYPE;
l_budget_unit1_value_type_cd  pqh_budget_periods.budget_unit1_value_type_cd%TYPE := 'V';
l_budget_unit1_percent        pqh_budget_periods.budget_unit1_percent%TYPE;
l_budget_unit1_available       pqh_budget_details.budget_unit1_available%TYPE := 0;
/*
  changed as per Sumit's reqt that p_budget_unit1_available equals value
  02/16/2000
  changed on 3/20/1999 as now we also have records in budget sets for the budget_period
  so in budget_periods we will have available = 0 as entire value passed to budget_sets
*/


BEGIN

 hr_utility.set_location('Entering: '||l_proc, 5);

IF p_budget_detail_id IS NOT NULL THEN

  --  compute l_budget_unit1_percent
  l_budget_unit1_percent := (p_per_budget_val_rec.value/p_budget_unit1_value)*100 ;

  -- call insert API
  pqh_budget_periods_api.create_budget_period
(
   p_validate                       =>  false
  ,p_budget_period_id               =>  p_budget_period_id_o
  ,p_budget_detail_id               =>  p_budget_detail_id
  ,p_start_time_period_id           =>  p_per_budget_val_rec.time_period_id
  ,p_end_time_period_id             =>  p_per_budget_val_rec.time_period_id
  ,p_budget_unit1_percent           =>  l_budget_unit1_percent
  ,p_budget_unit2_percent           =>  null
  ,p_budget_unit3_percent           =>  null
  ,p_budget_unit1_value             =>  p_per_budget_val_rec.value
  ,p_budget_unit2_value             =>  null
  ,p_budget_unit3_value             =>  null
  ,p_budget_unit1_value_type_cd              =>  l_budget_unit1_value_type_cd
  ,p_budget_unit2_value_type_cd              =>  null
  ,p_budget_unit3_value_type_cd              =>  null
  ,p_budget_unit1_available          =>  l_budget_unit1_available
  ,p_budget_unit2_available          =>  null
  ,p_budget_unit3_available          =>  null
  ,p_object_version_number          =>  l_object_version_number
 );


END IF; -- p_budget_detail_id is not null

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
FUNCTION  get_shared_type_id (p_unit  IN per_budgets.unit%TYPE ) RETURN number
IS

CURSOR uom_csr IS
SELECT pst.shared_type_id
FROM  per_shared_types_vl pst , hr_standard_lookups lk
WHERE lk.lookup_type = pst.lookup_type
  and lk.lookup_code = pst.system_type_cd
  and lk.meaning     = pst.shared_type_name
  and lk.lookup_code = p_unit
  and lk.lookup_type = 'BUDGET_MEASUREMENT_TYPE';

-- local variables and cursors

l_proc                        varchar2(72) := g_package||'get_shared_type_id';
l_shared_type_id              number;

BEGIN

  hr_utility.set_location('Entering: '||l_proc, 5);

  hr_utility.set_location('Unit : '||p_unit,10);

  IF p_unit IS NULL THEN

     hr_utility.set_location('Unit is NULL  ',10);
     hr_utility.set_location('Leaving:'||l_proc, 1000);

     RETURN NULL;

  END IF;

  OPEN uom_csr;
   FETCH uom_csr INTO l_shared_type_id;
  CLOSE uom_csr;

 hr_utility.set_location('Shared Type ID :'||l_shared_type_id, 100);
 hr_utility.set_location('Leaving:'||l_proc, 1000);

 RETURN l_shared_type_id;

EXCEPTION
  WHEN others THEN
      raise;
END;
--------------------------------------------------------------------------------------------------------------
PROCEDURE populate_per_shared_types
IS
/*
  This procedure will populate per_shared_types with lookup_code that the user may have
  defined for lookup_type = BUDGET_MEASUREMENT_TYPE
*/
-- local variables and cursors

l_proc                        varchar2(72) := g_package||'populate_per_shared_types';
l_object_version_number       per_shared_types.object_version_number%TYPE;
l_shared_type_id              per_shared_types.shared_type_id%TYPE;
l_lookup_code                 per_shared_types.system_type_cd%TYPE;
l_meaning                     per_shared_types.shared_type_name%TYPE;


CURSOR pop_uom_csr is
SELECT lookup_code, meaning
FROM hr_lookups
WHERE lookup_type = 'BUDGET_MEASUREMENT_TYPE'
  AND enabled_flag = 'Y'
  AND sysdate BETWEEN NVL(start_date_active,sysdate) AND NVL(end_date_active,sysdate)
  AND lookup_code NOT IN ( SELECT system_type_cd
                           FROM per_shared_types
                           WHERE lookup_type = 'BUDGET_MEASUREMENT_TYPE' );

BEGIN

 hr_utility.set_location('Entering: '||l_proc, 5);

OPEN pop_uom_csr;
 LOOP

   FETCH pop_uom_csr into l_lookup_code, l_meaning;
   EXIT WHEN pop_uom_csr%NOTFOUND;

         per_shared_types_api.create_shared_type
        (
         p_shared_type_id        =>  l_shared_type_id
        ,p_shared_type_name      =>  l_meaning
        ,p_system_type_cd        =>  l_lookup_code
        ,p_language_code         =>  userenv('LANG')
        ,p_object_version_number =>  l_object_version_number
        ,p_lookup_type           =>  'BUDGET_MEASUREMENT_TYPE'
        ,p_effective_date        =>   sysdate
        );

     hr_utility.set_location('Ins Per Shared Types '||l_lookup_code,10);

   END LOOP;

CLOSE pop_uom_csr;

 hr_utility.set_location('Leaving:'||l_proc, 1000);


EXCEPTION
  WHEN others THEN
      raise;
END;


--------------------------------------------------------------------------------------------------------------
PROCEDURE populate_empty_budget_versions
IS
/*
  This procedure will populate one row in pqh_budget_versions table for those budgets that have on row
  here. This is a new rqmt that thete cannot be a row in pqh_budgets table without any child rows in
  pqh_budget_versions
*/
-- local variables and cursors

l_proc                        varchar2(72) := g_package||'populate_empty_budget_versions';
l_budget_rec                  pqh_budgets%ROWTYPE;
l_budget_version_id           pqh_budget_versions.budget_version_id%TYPE;
l_object_version_number       pqh_budget_versions.object_version_number%TYPE;

CURSOR budgets_csr is
 SELECT * FROM pqh_budgets
 WHERE budget_id NOT IN ( SELECT DISTINCT budget_id
                          FROM pqh_budget_versions );

BEGIN

 hr_utility.set_location('Entering: '||l_proc, 5);

   OPEN budgets_csr;
     LOOP

      FETCH budgets_csr INTO l_budget_rec;
      EXIT WHEN budgets_csr%NOTFOUND;

         -- call insert API
         pqh_budget_versions_api.create_budget_version
        (
           p_validate                       =>   false
          ,p_budget_version_id              =>   l_budget_version_id
          ,p_budget_id                      =>   l_budget_rec.budget_id
          ,p_version_number                 =>   1
          ,p_date_from                      =>   l_budget_rec.budget_start_date
          ,p_date_to                        =>   l_budget_rec.budget_end_date
          ,p_transfered_to_gl_flag          =>   'N'
          ,p_xfer_to_other_apps_cd          =>   'N'
          ,p_object_version_number          =>   l_object_version_number
          ,p_effective_date                 =>   sysdate
         );

     END LOOP;

   CLOSE budgets_csr;

 hr_utility.set_location('Leaving:'||l_proc, 1000);


EXCEPTION
  WHEN others THEN
      raise;
END;



--------------------------------------------------------------------------------------------------------------

PROCEDURE populate_period_details
(
 p_budget_period_id         IN  pqh_budget_periods.budget_period_id%TYPE,
 p_budget_set_name          IN  pqh_dflt_budget_sets.dflt_budget_set_name%TYPE
)
IS
/*
  This procedure will populate one rows in pqh_budget_sets, elements and funding srcs with rows from
  pqh_dflt_budget_sets, elements and fund srcs
*/
-- local variables and cursors

l_proc                        varchar2(72) := g_package||'populate_period_details';
l_budget_periods_rec          pqh_budget_periods%ROWTYPE;
l_dflt_budget_sets_rec        pqh_dflt_budget_sets%ROWTYPE;
l_dflt_budget_elements_rec    pqh_dflt_budget_elements%ROWTYPE;
l_dflt_fund_srcs              pqh_dflt_fund_srcs%ROWTYPE;
l_budget_set_id               pqh_budget_sets.budget_set_id%TYPE;
l_budget_element_id           pqh_budget_elements.budget_element_id%TYPE;
l_budget_fund_src_id          pqh_budget_fund_srcs.budget_fund_src_id%TYPE;


CURSOR budget_periods_csr IS
SELECT *
FROM pqh_budget_periods
WHERE budget_period_id = p_budget_period_id;

CURSOR pqh_dflt_budget_sets_cur (p_budget_set_name  IN  pqh_dflt_budget_sets.dflt_budget_set_name%TYPE) IS
 SELECT *
 FROM  pqh_dflt_budget_sets
 WHERE dflt_budget_set_name = p_budget_set_name;

CURSOR pqh_dflt_budget_elements_cur (p_dflt_budget_set_id  IN  pqh_dflt_budget_elements.dflt_budget_set_id%TYPE) IS
 SELECT *
 FROM  pqh_dflt_budget_elements
 WHERE dflt_budget_set_id = p_dflt_budget_set_id;

CURSOR pqh_dflt_fund_srcs_cur (p_dflt_budget_element_id  IN  pqh_dflt_fund_srcs.dflt_budget_element_id%TYPE) IS
 SELECT *
 FROM  pqh_dflt_fund_srcs
 WHERE dflt_budget_element_id = p_dflt_budget_element_id;


BEGIN

 hr_utility.set_location('Entering: '||l_proc, 5);

IF p_budget_period_id IS NOT NULL THEN

 OPEN budget_periods_csr;
   FETCH budget_periods_csr INTO l_budget_periods_rec;
 CLOSE budget_periods_csr;


 OPEN pqh_dflt_budget_sets_cur(p_budget_set_name  => p_budget_set_name);
   LOOP  -- loop 1
     FETCH pqh_dflt_budget_sets_cur INTO l_dflt_budget_sets_rec;
     EXIT WHEN pqh_dflt_budget_sets_cur%NOTFOUND;
       -- create records in pqh_budget_sets
         populate_budget_sets
         (
          p_dflt_budget_sets_rec       => l_dflt_budget_sets_rec,
          p_budget_period_id           => p_budget_period_id,
          p_budget_set_id_o            => l_budget_set_id
          );


       -- open budget elements cursor
       OPEN pqh_dflt_budget_elements_cur(p_dflt_budget_set_id => l_dflt_budget_sets_rec.dflt_budget_set_id);
         LOOP  -- loop 2
           FETCH pqh_dflt_budget_elements_cur INTO l_dflt_budget_elements_rec;
           EXIT WHEN pqh_dflt_budget_elements_cur%NOTFOUND;
             -- create records in pqh_budget_elements
               populate_budget_elements
               (
                p_dflt_budget_elements_rec   => l_dflt_budget_elements_rec,
                p_budget_set_id              => l_budget_set_id,
                p_budget_element_id_o        => l_budget_element_id
               );


             -- open budget fund srcs cursor
             OPEN pqh_dflt_fund_srcs_cur(p_dflt_budget_element_id  => l_dflt_budget_elements_rec.dflt_budget_element_id);
               LOOP  -- loop 3
                 FETCH pqh_dflt_fund_srcs_cur INTO l_dflt_fund_srcs;
                 EXIT WHEN pqh_dflt_fund_srcs_cur%NOTFOUND;
                 -- create records in pqh_budget_fund_srcs
                  populate_budget_fund_srcs
                  (
                   p_dflt_fund_srcs             =>  l_dflt_fund_srcs,
                   p_budget_element_id          =>  l_budget_element_id,
                   p_budget_fund_src_id_o       =>  l_budget_fund_src_id
                  );


               END LOOP; -- loop 3
             CLOSE pqh_dflt_fund_srcs_cur;


          END LOOP; -- loop 2
        CLOSE   pqh_dflt_budget_elements_cur;

   END LOOP; -- loop 1
 CLOSE pqh_dflt_budget_sets_cur;


END IF; -- p_budget_period_id is not null

 hr_utility.set_location('Leaving:'||l_proc, 1000);


EXCEPTION
  WHEN others THEN
      raise;
END;

--------------------------------------------------------------------------------------------------------------

PROCEDURE populate_budget_sets
(
 p_dflt_budget_sets_rec       IN  pqh_dflt_budget_sets%ROWTYPE,
 p_budget_period_id           IN  pqh_budget_periods.budget_period_id%TYPE,
 p_budget_set_id_o            OUT NOCOPY pqh_budget_sets.budget_set_id%TYPE
)
IS
-- local variables and cursors

l_proc                        varchar2(72) := g_package||'populate_budget_sets';
l_object_version_number       pqh_budget_periods.object_version_number%TYPE;
l_budget_periods_rec          pqh_budget_periods%ROWTYPE;
l_percent_sum                 pqh_dflt_budget_elements.dflt_dist_percentage%TYPE;
l_budget_unit1_available      pqh_budget_periods.budget_unit1_available%TYPE;

CURSOR budget_periods_csr IS
SELECT *
FROM pqh_budget_periods
WHERE budget_period_id = p_budget_period_id;

CURSOR budget_set_percent_csr IS
SELECT SUM(dflt_dist_percentage)
FROM pqh_dflt_budget_elements
WHERE dflt_budget_set_id  = p_dflt_budget_sets_rec.dflt_budget_set_id;


BEGIN

 hr_utility.set_location('Entering: '||l_proc, 5);

IF p_budget_period_id IS NOT NULL THEN

 OPEN budget_periods_csr;
   FETCH budget_periods_csr INTO l_budget_periods_rec;
 CLOSE budget_periods_csr;

 -- compute avaliable
 OPEN budget_set_percent_csr;
   FETCH budget_set_percent_csr INTO l_percent_sum;
 CLOSE budget_set_percent_csr;

 l_budget_unit1_available := l_budget_periods_rec.budget_unit1_value - (l_budget_periods_rec.budget_unit1_value*l_percent_sum/100);

 -- unit2 and 3 are null in migrated data

  -- call insert API
 pqh_budget_sets_api.create_budget_set
 (
   p_validate                       =>  false
  ,p_budget_set_id                  =>  p_budget_set_id_o
  ,p_dflt_budget_set_id             =>  p_dflt_budget_sets_rec.dflt_budget_set_id
  ,p_budget_period_id               =>  p_budget_period_id
  ,p_budget_unit1_percent           =>  l_budget_periods_rec.budget_unit1_percent
  ,p_budget_unit2_percent           =>  l_budget_periods_rec.budget_unit2_percent
  ,p_budget_unit3_percent           =>  l_budget_periods_rec.budget_unit3_percent
  ,p_budget_unit1_value             =>  l_budget_periods_rec.budget_unit1_value
  ,p_budget_unit2_value             =>  l_budget_periods_rec.budget_unit2_value
  ,p_budget_unit3_value             =>  l_budget_periods_rec.budget_unit3_value
  ,p_budget_unit1_available         =>  l_budget_unit1_available
  ,p_budget_unit2_available         =>  null
  ,p_budget_unit3_available         =>  null
  ,p_object_version_number          =>  l_object_version_number
  ,p_budget_unit1_value_type_cd     =>  l_budget_periods_rec.budget_unit1_value_type_cd
  ,p_budget_unit2_value_type_cd     =>  l_budget_periods_rec.budget_unit2_value_type_cd
  ,p_budget_unit3_value_type_cd     =>  l_budget_periods_rec.budget_unit3_value_type_cd
  ,p_effective_date                 =>  sysdate
 );


END IF; -- p_budget_period_id is not null

 hr_utility.set_location('PQH Budget Set ID out '||p_budget_set_id_o, 100);
 hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
  WHEN others THEN
  p_budget_set_id_o := null;
    raise;
END populate_budget_sets;

--------------------------------------------------------------------------------------------------------------
PROCEDURE populate_budget_elements
(
 p_dflt_budget_elements_rec   IN  pqh_dflt_budget_elements%ROWTYPE,
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
  ,p_element_type_id                =>  p_dflt_budget_elements_rec.element_type_id
  ,p_distribution_percentage        =>  p_dflt_budget_elements_rec.dflt_dist_percentage
  ,p_object_version_number          =>  l_object_version_number
 );

END IF; -- p_budget_set_id is not null

 hr_utility.set_location('PQH Budget Element ID out '||p_budget_element_id_o, 100);
 hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
  WHEN others THEN
  p_budget_element_id_o := null;
    raise;
END populate_budget_elements;

--------------------------------------------------------------------------------------------------------------
PROCEDURE populate_budget_fund_srcs
(
 p_dflt_fund_srcs             IN  pqh_dflt_fund_srcs%ROWTYPE,
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
  ,p_cost_allocation_keyflex_id     =>  p_dflt_fund_srcs.cost_allocation_keyflex_id
  ,p_distribution_percentage        =>  p_dflt_fund_srcs.dflt_dist_percentage
  ,p_object_version_number          =>  l_object_version_number
 );

END IF; -- p_budget_element_id is not null

 hr_utility.set_location('PQH Budget Fund Src ID out '||p_budget_fund_src_id_o, 100);
 hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
  WHEN others THEN
  p_budget_fund_src_id_o := null;
    raise;
END populate_budget_fund_srcs;
--------------------------------------------------------------------------------------------------------------

PROCEDURE populate_globals
IS

/*
  This procedure will populate all the global variables.
*/

 l_proc                           varchar2(72) := g_package||'populate_globals';


 CURSOR csr_table_route (p_table_alias  IN varchar2 )IS
  SELECT table_route_id
  FROM pqh_table_route
  WHERE table_alias =  p_table_alias;

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);


  -- get table_route_id for all the tables

  -- table_route_id for per_budgets
    OPEN csr_table_route (p_table_alias  => 'P_BGT');
       FETCH csr_table_route INTO g_table_route_id_p_bgt;
    CLOSE csr_table_route;

  -- table_route_id for per_budget_versions
    OPEN csr_table_route (p_table_alias  => 'P_BVR');
       FETCH csr_table_route INTO g_table_route_id_p_bvr;
    CLOSE csr_table_route;

  -- table_route_id for per_budget_elements
    OPEN csr_table_route (p_table_alias  => 'P_BDT');
       FETCH csr_table_route INTO g_table_route_id_p_bdt;
    CLOSE csr_table_route;

  -- table_route_id for per_budget_values
    OPEN csr_table_route (p_table_alias  => 'P_BPR');
       FETCH csr_table_route INTO g_table_route_id_p_bpr;
    CLOSE csr_table_route;

  -- table_route_id for pqh_dflt_budget_sets
    OPEN csr_table_route (p_table_alias  => 'DST');
       FETCH csr_table_route INTO g_table_route_id_dst;
    CLOSE csr_table_route;

  -- table_route_id for pqh_dflt_budget_elements
    OPEN csr_table_route (p_table_alias  => 'DEL');
       FETCH csr_table_route INTO g_table_route_id_del;
    CLOSE csr_table_route;

  -- table_route_id for pqh_dflt_budget_fund srcs
    OPEN csr_table_route (p_table_alias  => 'DFS');
       FETCH csr_table_route INTO g_table_route_id_dfs;
    CLOSE csr_table_route;

  hr_utility.set_location('g_table_route_id_p_bgt: '||g_table_route_id_p_bgt, 50);
  hr_utility.set_location('g_table_route_id_p_bvr: '||g_table_route_id_p_bvr, 60);
  hr_utility.set_location('g_table_route_id_p_bdt: '||g_table_route_id_p_bdt, 70);
  hr_utility.set_location('g_table_route_id_p_bpr: '||g_table_route_id_p_bpr, 80);
  hr_utility.set_location('g_table_route_id_dst: '||g_table_route_id_dst, 90);
  hr_utility.set_location('g_table_route_id_del: '||g_table_route_id_del, 95);
  hr_utility.set_location('g_table_route_id_dfs: '||g_table_route_id_dfs, 96);

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
PROCEDURE set_p_bgt_log_context
(
  p_budget_id               IN  per_budgets.budget_id%TYPE,
  p_log_context             OUT NOCOPY pqh_process_log.log_context%TYPE
) IS
/*
  This procedure will set the log_context at per budgets level
*/

 l_proc                           varchar2(72) := g_package||'set_p_bgt_log_context';
 l_bdg_name                       per_budgets.name%TYPE;

CURSOR bdg_name_csr IS
SELECT name
FROM per_budgets
WHERE budget_id = p_budget_id;

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

  OPEN bdg_name_csr;
    FETCH bdg_name_csr INTO l_bdg_name;
  CLOSE bdg_name_csr;

  -- set log context

    p_log_context := l_bdg_name;



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
END set_p_bgt_log_context;







--------------------------------------------------------------------------------------------------------------
PROCEDURE set_p_bvr_log_context
(
  p_budget_version_id       IN  per_budget_versions.budget_version_id%TYPE,
  p_log_context             OUT NOCOPY pqh_process_log.log_context%TYPE
) IS
/*
  This procedure will set the log_context at per budgets level
*/

 l_proc                           varchar2(72) := g_package||'set_p_bvr_log_context';
 l_bdg_ver_number                 per_budget_versions.version_number%TYPE;

CURSOR bdg_ver_csr IS
SELECT version_number
FROM per_budget_versions
WHERE budget_version_id = p_budget_version_id;

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

  OPEN bdg_ver_csr;
    FETCH bdg_ver_csr INTO l_bdg_ver_number;
  CLOSE bdg_ver_csr;

  -- set log context

    p_log_context := l_bdg_ver_number;



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
END set_p_bvr_log_context;



--------------------------------------------------------------------------------------------------------------
PROCEDURE set_p_bdt_log_context
(
  p_budget_element_id       IN  per_budget_elements.budget_element_id%TYPE,
  p_log_context             OUT NOCOPY pqh_process_log.log_context%TYPE
) IS
/*
  This procedure will set the log_context at per budgets level
  Display Order is P J O G ( which ever is not null
*/
 l_proc                           varchar2(72) := g_package||'set_p_bdt_log_context';
 l_budget_elements_rec            per_budget_elements%ROWTYPE;
 l_position_name                  hr_all_positions.name%TYPE;
 l_job_name                       per_jobs.name%TYPE;
 l_organization_name              hr_all_organization_units_tl.name%TYPE;
 l_grade_name                     per_grades.name%TYPE;

 CURSOR csr_bdg_elmnt_rec  IS
 SELECT *
 FROM per_budget_elements
 WHERE budget_element_id = p_budget_element_id ;

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

  OPEN csr_bdg_elmnt_rec;
    FETCH csr_bdg_elmnt_rec INTO l_budget_elements_rec;
  CLOSE csr_bdg_elmnt_rec;


  l_position_name := HR_GENERAL.DECODE_POSITION (p_position_id => l_budget_elements_rec.position_id);
  l_job_name := HR_GENERAL.DECODE_JOB (p_job_id => l_budget_elements_rec.job_id);
  l_organization_name := HR_GENERAL.DECODE_ORGANIZATION (p_organization_id => l_budget_elements_rec.organization_id);
  l_grade_name := HR_GENERAL.DECODE_GRADE (p_grade_id => l_budget_elements_rec.grade_id);


  IF    l_position_name IS NOT NULL THEN
            p_log_context := SUBSTR(l_position_name,1,255);
  ELSIF l_job_name  IS NOT NULL THEN
            p_log_context := SUBSTR(l_job_name,1,255);
  ELSIF l_organization_name  IS NOT NULL THEN
            p_log_context := SUBSTR(l_organization_name,1,255);
  ELSIF l_grade_name  IS NOT NULL THEN
            p_log_context := SUBSTR(l_grade_name,1,255);
  ELSE
            p_log_context := 'Budget Element';
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
END set_p_bdt_log_context;

--------------------------------------------------------------------------------------------------------------
PROCEDURE set_p_bpr_log_context
(
  p_budget_value_id         IN  per_budget_values.budget_value_id%TYPE,
  p_log_context             OUT NOCOPY pqh_process_log.log_context%TYPE
) IS
/*
  This procedure will set the log_context at per budgets level
*/

 l_proc                           varchar2(72) := g_package||'set_p_bpr_log_context';
 l_per_budget_values_rec          per_budget_values%ROWTYPE;
 l_per_time_periods_rec           per_time_periods%ROWTYPE;

 CURSOR csr_bpr_periods_rec IS
 SELECT *
 FROM per_budget_values
 WHERE budget_value_id = p_budget_value_id ;

 CURSOR csr_per_time_periods ( p_time_period_id IN number ) IS
 SELECT *
 FROM per_time_periods
 WHERE time_period_id = p_time_period_id ;


BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

  OPEN csr_bpr_periods_rec;
    FETCH csr_bpr_periods_rec INTO l_per_budget_values_rec;
  CLOSE csr_bpr_periods_rec;

  OPEN csr_per_time_periods(p_time_period_id => l_per_budget_values_rec.time_period_id);
    FETCH csr_per_time_periods INTO l_per_time_periods_rec;
  CLOSE csr_per_time_periods;

  -- set log context

    p_log_context := l_per_time_periods_rec.period_name;



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
END set_p_bpr_log_context;


--------------------------------------------------------------------------------------------------------------
PROCEDURE check_params
(
 p_budget_name            IN per_budgets.name%TYPE,
 p_budget_set_name        IN pqh_dflt_budget_sets.dflt_budget_set_name%TYPE,
 p_business_group_id       IN  per_budgets.business_group_id%TYPE
) IS
/*
 This procedure will check at the input params are valid else it will log error and abort the program
 Valid Params :
 There should atleast be one record in per_budgets with name = p_budget_name and budget_type_code <> OTA_BUDGET
 as we are not migrating OTA_BUDGETS
 The budget_set_name must exist in pqh_dflt_budget_sets ( dflt_budget_set_name )
*/

 l_proc                           varchar2(72) := g_package||'check_params';
 l_bdg_cnt                        number := 0;
 l_set_cnt                        number := 0;
 l_message_number_out             fnd_new_messages.message_number%TYPE;


 CURSOR cnt_budgets_csr IS
 SELECT COUNT(*)
 FROM per_budgets
 WHERE name = NVL(p_budget_name, name)
   AND business_group_id  = p_business_group_id
   AND NVL(budget_type_code,'X') <> 'OTA_BUDGET' ;

 CURSOR bdg_sets_csr IS
 SELECT COUNT(*)
 FROM pqh_dflt_budget_sets
 WHERE dflt_budget_set_name = p_budget_set_name;

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

 -- count budgets
  OPEN cnt_budgets_csr;
   FETCH cnt_budgets_csr INTO l_bdg_cnt;
  CLOSE cnt_budgets_csr;

  -- count sets
  OPEN bdg_sets_csr;
   FETCH bdg_sets_csr INTO l_set_cnt;
  CLOSE bdg_sets_csr;

  -- if cnt is zero then stop here after logging the event
  IF l_bdg_cnt = 0 THEN

     -- get the message text PQH_BDG_MIG_INV_NAME
        FND_MESSAGE.SET_NAME('PQH','PQH_BDG_MIG_INV_NAME');
        APP_EXCEPTION.RAISE_EXCEPTION;
  ELSIF l_set_cnt = 0 THEN

     -- get the message text PQH_BDG_MIG_INV_SET
        FND_MESSAGE.SET_NAME('PQH','PQH_BDG_MIG_INV_SET');
        APP_EXCEPTION.RAISE_EXCEPTION;

  END IF;

  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
       raise;
END;

--------------------------------------------------------------------------------------------------------------
PROCEDURE check_valid_budget
(
 p_per_budgets_rec         IN  per_budgets%ROWTYPE,
 p_valid                   OUT NOCOPY varchar2
) IS
/*
 This procedure validates if the budget is valid. For budget to be valid there must be no
 records in per_budget_elements which do not have child records in per_budget_values
 If it is not valid we set p_valid = N so that we can skip this budget migration and give the
 error message
*/

l_proc                           varchar2(72) := g_package||'check_valid_budget';
l_cnt_elements    number;
l_cnt_values      number;
l_message_text_out               fnd_new_messages.message_text%TYPE;


CURSOR cnt_elements IS
SELECT COUNT(budget_element_id)
FROM per_budget_elements
WHERE budget_version_id IN
  ( SELECT budget_version_id
      FROM per_budget_versions
    WHERE budget_id = p_per_budgets_rec.budget_id
  );

CURSOR cnt_values IS
SELECT COUNT(distinct budget_element_id)
FROM per_budget_values
WHERE budget_element_id IN
 ( SELECT budget_element_id
     FROM per_budget_elements
    WHERE budget_version_id IN
        ( SELECT budget_version_id
            FROM per_budget_versions
           WHERE budget_id = p_per_budgets_rec.budget_id
         )
  );


BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

   OPEN cnt_elements;
     FETCH cnt_elements INTO l_cnt_elements;
   CLOSE cnt_elements;

   OPEN cnt_values;
     FETCH cnt_values INTO l_cnt_values;
   CLOSE cnt_values;

   IF NVL(l_cnt_elements,0) <> NVL(l_cnt_values,0) THEN

    -- there are some elements under this budget without rows in budget values
    -- skip this budget
       p_valid := 'N';

       -- get message text for PQH_WKS_INVALID_ID
           FND_MESSAGE.SET_NAME('PQH','PQH_INVALID_PER_BUDGET');
           l_message_text_out := FND_MESSAGE.GET;

       -- insert error into log table
          pqh_process_batch_log.insert_log
          (
           p_message_type_cd    =>  'ERROR',
           p_message_text       =>  l_message_text_out
          );


   ELSE
       p_valid := 'Y';
   END IF;


  hr_utility.set_location('Leaving:'||l_proc, 1000);
  exception
  when others then
  p_valid := null;
  raise;

END check_valid_budget;


-----------------------------------------------------------------------------------------------
PROCEDURE migrate_bdgt(p_budget_id          in number,
                       p_dflt_budget_set_id in number,
                       p_request_number     out nocopy number) is
Cursor csr_budget is
Select name,business_group_id
  From per_budgets
 Where budget_id = p_budget_id;
--
 CURSOR bdg_sets_csr IS
 SELECT dflt_budget_set_name
 FROM pqh_dflt_budget_sets
 WHERE dflt_budget_set_id = p_dflt_budget_set_id;
--
 l_name              per_budgets.name%type;
 l_business_group_id per_budgets.business_group_id%type;
 l_bset_name         pqh_dflt_budget_sets.dflt_budget_set_name%type;
--
begin
   --
   Open csr_budget;
   Fetch csr_budget into l_name,l_business_group_id;
   Close csr_budget;
   --
   Open bdg_sets_csr;
   Fetch bdg_sets_csr into l_bset_name;
   Close bdg_sets_csr;

   --
   p_request_number := -1;
   --
   p_request_number := fnd_request.submit_request(application => 'PQH',
                                       program     => 'PQHBDGMIG',
                                       argument1   => l_name,
                                       argument2   => l_bset_name,
                                       argument3   => l_business_group_id);
exception
when others then
p_request_number := null;
raise;
end migrate_bdgt;

-----------------------------------------------------------------------------------------



END; -- Package Body PQH_BUDGET_DATA_MIGRATION

/
