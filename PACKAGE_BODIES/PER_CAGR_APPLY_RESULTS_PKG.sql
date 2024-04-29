--------------------------------------------------------
--  DDL for Package Body PER_CAGR_APPLY_RESULTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CAGR_APPLY_RESULTS_PKG" AS
/* $Header: pecgrapl.pkb 120.5.12010000.2 2008/08/06 09:06:23 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Package Types and Variables (globals)
-- ----------------------------------------------------------------------------
--

TYPE mapping_rec IS RECORD (parameter_name     per_cagr_api_parameters.parameter_name%TYPE
                           ,value              VARCHAR2(30));

TYPE asg_rec is record (cagr_entitlement_result_id   NUMBER(15)
                       ,assignment_id                NUMBER(11)
                       ,cagr_entitlement_item_id     NUMBER(11)
                       ,cagr_api_id                  NUMBER(15)
                       ,cagr_api_param_id            NUMBER(15)
                       ,value                        VARCHAR2(240)
                       ,units_of_measure             VARCHAR2(60));

TYPE pys_rec is record (cagr_entitlement_result_id   NUMBER(15)
                       ,assignment_id                NUMBER(11)
                       ,cagr_entitlement_item_id     NUMBER(11)
                       ,cagr_api_id                  NUMBER(15)
                       ,cagr_api_param_id            NUMBER(15)
                       ,category_name                VARCHAR2(30)
                       ,grade_spine_id               NUMBER(15)
                       ,parent_spine_id              NUMBER(15)
                       ,step_id                      NUMBER(15)
                       ,from_step_id                 NUMBER(15)
                       ,to_step_id                   NUMBER(15)
                       ,value                        VARCHAR2(240)
                       ,units_of_measure             VARCHAR2(60));

TYPE pay_rec is record (cagr_entitlement_result_id    NUMBER(15)
                       ,assignment_id                 NUMBER(11)
                       ,cagr_entitlement_item_id      NUMBER(11)
                       ,category_namec                VARCHAR2(30)
                       ,element_type_id               NUMBER(10)
                       ,input_value_id                NUMBER(10)
                       ,value                         VARCHAR2(240)
                       ,multiple_entries_allowed_flag VARCHAR2(30));

TYPE t_ASG_results IS TABLE OF asg_rec
                 INDEX BY BINARY_INTEGER;

TYPE t_PYS_results IS TABLE OF pys_rec
                 INDEX BY BINARY_INTEGER;

TYPE t_PAY_results IS TABLE OF pay_rec
                 INDEX BY BINARY_INTEGER;

TYPE t_mapping_table IS TABLE OF mapping_rec INDEX BY BINARY_INTEGER;

g_pkg                 constant varchar2(33) := 'PER_CAGR_APPLY_ENTITLEMENTS_PKG.';
g_done_header         boolean := FALSE;

 --
 -- ------------------------------------------------------------------------------
 -- |------------------------------< initialise >--------------------------------|
 -- ------------------------------------------------------------------------------

 PROCEDURE initialise (p_params    IN OUT NOCOPY per_cagr_evaluation_pkg.control_structure
                      ,p_select_flag IN varchar2 default 'B') IS

  -- (record interface)
  -- Coordinates denormalisation of per_cagr_entitlement_result records to HRMS tables.
  -- Called by: PER_CAGR_APPLY_RESULTS_PKG.initialise (individual parameter interface) and
  -- optionally by PER_CAGR_EVALUATION_PKG.initialise (dependent upon mode).
  --
  -- P_SELECT_FLAG now redundant - apply chosen, or beneficial if no chosen.
  -- Defaults to processing all categories of result records existing in cache
  -- for asg - cagr - effective_date params supplied, unless a specific category is
  -- supplied to restrict processing.
  --
  -- P_SELECT_FLAG NOW REDUNDANT - apply chosen, or beneficial if no chosen.
  -- (old processing: Selects the results according to select_flag
  -- param, either 'B' (benefical_flag = Y) or 'C' (chosen_flag = 'Y').
  --

  TYPE assignment_rec IS RECORD  (assignment_id      number(15));

  TYPE assignment_list IS TABLE OF assignment_rec
                      INDEX BY BINARY_INTEGER;

  -- get the assignments for the SC mode process
  CURSOR csr_assignments_to_process IS
     SELECT assignment_id
        FROM per_all_assignments_f asg
        WHERE asg.collective_agreement_id = p_params.collective_agreement_id
        AND p_params.effective_date BETWEEN asg.effective_start_date
                                        AND asg.effective_end_date
        AND asg.PRIMARY_FLAG = 'Y';

  l_proc constant               VARCHAR2(80)    := g_pkg || 'initialise (rec)';
  t_assignment_list             assignment_list;
  l_counter                     number(15) := 0;
  l_parent_request_id           number(15) := NULL;


 -- ================================================================================================
 -- ==     ****************               GET_REQUEST_ID                *****************         ==
 -- ================================================================================================
 FUNCTION get_request_id (p_assignment_id  in number
                         ,p_effective_date in date) return number IS

 --
 -- Returns the request_id for the first result that is found in the cache for the assignment
 -- on the effective_date or null. (The request_id must be for an 'SA' request only, as only these
 -- logs are visible from PERWSCAR).
 --
 -- Called by initialise during SC mode, to update the correct requests logs .

 CURSOR csr_request IS
   SELECT cagr_request_id
    FROM per_cagr_entitlement_results res
    WHERE res.assignment_id = p_assignment_id
    AND p_effective_date BETWEEN res.start_date and nvl(res.end_date,hr_general.end_of_time)
    AND exists (select 'x'
                from per_cagr_requests req
                where req.cagr_request_id = cagr_request_id
                and req.OPERATION_MODE = 'SA')
    and rownum = 1;

 l_proc constant               VARCHAR2(80)    := g_pkg || 'get_request_id';
 l_request                     per_cagr_requests.cagr_request_id%type;

 BEGIN
  hr_utility.set_location('Entering: '||l_proc,10);

  open  csr_request;
  fetch csr_request into l_request;
  close csr_request;

  hr_utility.set_location('Leaving: '||l_proc,40);
  RETURN l_request;

 END get_request_id;

 -- ================================================================================================
 -- ==     ****************                  GET_NUM_VAL                *****************         ==
 -- ================================================================================================

  FUNCTION get_num_val(p_column_name   IN            VARCHAR2,
                       p_mapping_table IN OUT NOCOPY t_mapping_table) RETURN NUMBER IS

    -- returns the numeric value from the array for the column_name
    -- supplied, and deletes the rec.
    l_proc            constant               VARCHAR2(80)    := g_pkg || 'get_num_val';
    l_return          NUMBER := NULL;

  BEGIN
    hr_utility.set_location('Entering: '||l_proc,10);
    FOR i in p_mapping_table.first..p_mapping_table.last LOOP
      IF p_mapping_table(i).parameter_name = p_column_name THEN
        -- found the correct column, so return the value
        l_return := to_number(p_mapping_table(i).value);
        exit;
      END If;
    END LOOP;
    IF l_return IS NULL THEN
       l_return := hr_api.g_number;
    END IF;
    hr_utility.set_location('Leaving:'||l_proc, 30);
    RETURN l_return;

  END get_num_val;

 -- ================================================================================================
 -- ==     ****************                 GET_CHAR_VAL                *****************         ==
 -- ================================================================================================

  FUNCTION get_char_val(p_column_name   IN            VARCHAR2,
                        p_mapping_table IN OUT NOCOPY t_mapping_table) RETURN VARCHAR2 IS
    -- returns the varchar value from the array for the
    -- column_name supplied, and deletes the rec.
   l_proc            constant               VARCHAR2(80)    := g_pkg || 'get_char_val';
   l_return          VARCHAR2(240) := NULL;

  BEGIN
    hr_utility.set_location('Entering: '||l_proc,10);
    FOR i in p_mapping_table.first..p_mapping_table.last LOOP
      IF p_mapping_table(i).parameter_name = p_column_name THEN
        -- found the correct column, so return the value
        l_return := p_mapping_table(i).value;
        exit;
      END If;
    END LOOP;
    IF l_return IS NULL THEN
       l_return := hr_api.g_varchar2;
    END IF;
    hr_utility.set_location('Leaving: '||l_proc,30);
    RETURN l_return;

  END get_char_val;

 -- ================================================================================================
 -- ==     ****************                 GET_DATE_VAL                *****************         ==
 -- ================================================================================================

  FUNCTION get_date_val(p_column_name   IN            VARCHAR2
                       ,p_mapping_table IN OUT NOCOPY t_mapping_table) RETURN DATE IS
    -- returns the date value from the array for the
    -- column_name supplied, and deletes the rec.
   l_proc            constant               VARCHAR2(80)    := g_pkg || 'get_date_val';
   l_return          DATE := NULL;
  BEGIN
    hr_utility.set_location('Entering: '||l_proc,10);
    FOR i in p_mapping_table.first..p_mapping_table.last LOOP
      IF p_mapping_table(i).parameter_name = p_column_name THEN
        -- found the correct column, so return the value
        l_return := fnd_date.canonical_to_date(p_mapping_table(i).value);
        exit;
      END If;
    END LOOP;
    IF l_return IS NULL THEN
       l_return := hr_api.g_date;
    END IF;
    hr_utility.set_location('Leaving: '||l_proc,30);
    RETURN l_return;

  END get_date_val;

 -- ================================================================================================
 -- ==     ****************              GET_OVN_AND_MODE               *****************         ==
 -- ================================================================================================

   PROCEDURE get_ovn_and_mode (p_table_name      in     varchar2
                              ,p_dt_flag         in     varchar2
                              ,p_pk              in     varchar2
                              ,p_pk_id           in     number
                              ,p_effective_date  in     date
                              ,p_mode               out nocopy varchar2
                              ,p_ovn                out nocopy number) IS
   --
   -- Determines ovn and dt mode (if applicable) for a record
   --
   -- DT UPD modes:
   --  if record started today and no future changes then 'CORRECTION'
   --  if record started before and no future changes then 'UPDATE'
   --  if record started today and there are future changes then 'CORRECTION'
   --  if record started before today and future changes then 'UPDATE_CHANGE_INSERT'.
   --  note: update override is never used, i.e. we never replace all future changes
   --

  TYPE dyn_csr IS REF CURSOR;

  l_dyn_csr                     dyn_csr;
  l_sql                         VARCHAR2(240);
  l_start_date                  date;
  l_dummy                       VARCHAR2(1);
  l_proc constant               VARCHAR2(80)    := g_pkg || 'get_ovn_and_mode';

  BEGIN
    hr_utility.set_location('Entering:'||l_proc, 5);

    if p_dt_flag = 'Y' then
      l_sql :=  'SELECT object_version_number, effective_start_date FROM '||p_table_name||' WHERE '||p_pk||' = :1 ';
      l_sql :=  l_sql ||'AND :2 BETWEEN effective_start_date AND nvl(effective_end_date,hr_general.end_of_time)';
      hr_utility.set_location(l_proc, 10);
      open l_dyn_csr for l_sql using p_pk_id, p_effective_date;
      fetch l_dyn_csr into p_ovn, l_start_date;
      close l_dyn_csr;
      if l_start_date is null or p_ovn is null then
        per_cagr_utility_pkg.put_log('ERROR: dynamic sql failed to return a value for OVN or START_DATE',1);
      else
        hr_utility.set_location(l_proc, 20);
        p_mode := 'UPDATE';                           -- default to this mode
        if p_effective_date = l_start_date then
          -- switch to correction if record started today
          -- irrespective of any future changes
          p_mode := 'CORRECTION';
        else
          hr_utility.set_location(l_proc, 30);
          -- check for future updates
          l_sql := 'SELECT null FROM '||p_table_name||' WHERE '||p_pk||' = :1 and :2 < effective_start_date';
          open l_dyn_csr for l_sql using p_pk_id, p_effective_date;
          fetch l_dyn_csr into l_dummy;
          if l_dyn_csr%found then
            p_mode := 'UPDATE_CHANGE_INSERT';
          end if;
          close l_dyn_csr;
        end if;
      end if;
    else  -- not date tracked
      hr_utility.set_location(l_proc, 40);
      l_sql :=  'SELECT object_version_number FROM '||p_table_name||' WHERE '||p_pk||' = :1 ';
      l_sql :=  l_sql || 'AND :2 BETWEEN start_date and nvl(end_date,hr_general.end_of_time)';
      open l_dyn_csr for l_sql using p_pk_id, p_effective_date;
      fetch l_dyn_csr into p_ovn;
      close l_dyn_csr;
      hr_utility.set_location(l_proc, 50);
      if p_ovn is null then
        per_cagr_utility_pkg.put_log('ERROR: dynamic sql failed to return a value for OVN',1);
      end if;
    end if;

    hr_utility.set_location('Leaving:'||l_proc, 50);

  END get_ovn_and_mode;


 -- ================================================================================================
 -- ==     ****************              CALL_ASG_API                *****************            ==
 -- ================================================================================================

  PROCEDURE call_ASG_api (p_params      IN  per_cagr_evaluation_pkg.control_structure
                         ,p_ASG_results IN  t_ASG_results) IS


  -- get API data (for seeded denormalised columns only)
  -- i.e. not expecting to be seeding UOM columns separately
   CURSOR csr_api (v_cagr_api_id in NUMBER) IS
    SELECT apip.parameter_name
          ,apip.cagr_api_param_id
          ,apip.column_type
          ,apip.uom_parameter
          ,api.api_name
    FROM  per_cagr_api_parameters apip, per_cagr_apis api
    WHERE api.cagr_api_id = v_cagr_api_id
    AND   api.cagr_api_id = apip.cagr_api_id;

   TYPE t_api_details   IS TABLE OF csr_api%ROWTYPE INDEX BY BINARY_INTEGER;

   l_mapping_table                   t_mapping_table;
   l_api_details                     t_api_details;
   l_proc constant                   VARCHAR2(80)    := g_pkg || 'call_ASG_api';
   l_map_count                       NUMBER(10)      := 0;
   l_count                           NUMBER(10)      := 0;

   l_dt_mode                         VARCHAR2(30)    := 'UPDATE';

   -- local vars to catch out params
   l_ovn                             NUMBER(10);
   l_comment_id                      NUMBER;
   l_soft_coding_keyflex_id          NUMBER;
   l_effective_start_date            DATE;
   l_effective_end_date              DATE;
   l_concatenated_segments           hr_soft_coding_keyflex.concatenated_segments%TYPE;
   l_no_managers_warning             BOOLEAN;
   l_other_manager_warning           BOOLEAN;
   l_CAGR_GRADE_DEF_ID               VARCHAR2(30);
   l_CAGR_CONCATENATED_SEGMENTS      VARCHAR2(30);

   l_group_name                      VARCHAR2(30);
   l_people_group_id                 NUMBER;
   l_org_now_no_manager_warning      BOOLEAN;
   l_spp_delete_warning              BOOLEAN;
   l_entries_changed_warning         VARCHAR2(30);
   l_tax_district_changed_warning    BOOLEAN;
   l_special_ceiling_step_id         NUMBER;
   l_warn_message                    VARCHAR2(2000);

   BEGIN
     hr_utility.set_location('Entering:'||l_proc, 5);

     -- build pl/sql table of all seeded api column names for the API id
     for v_api_details in csr_api(p_ASG_results(1).cagr_api_id) loop
       l_count := l_count+1;
       l_api_details(l_count) :=  v_api_details;
     end loop;
     per_cagr_utility_pkg.put_log('   built api_details array of size: '||l_count);

     --  loop thru each ent result and create mapping record(s)
     for i in p_ASG_results.first..p_ASG_results.last loop
       l_map_count := l_map_count+1;
       l_mapping_table(l_map_count).value := p_ASG_results(i).value;
       --  get the PARAMETER_NAME and UOM column from the API details structure
       for j in l_api_details.first..l_api_details.last loop
         if l_api_details(j).cagr_api_param_id = p_ASG_results(i).cagr_api_param_id then
           l_mapping_table(l_map_count).parameter_name := l_api_details(j).parameter_name;
           per_cagr_utility_pkg.put_log('   created mapping record: '||
               l_mapping_table(l_map_count).parameter_name||'='||l_mapping_table(l_map_count).value);
           -- also create a mapping table record, if there is a uom col
           if l_api_details(j).uom_parameter is not null then
             l_map_count := l_map_count+1;
             l_mapping_table(l_map_count).parameter_name := l_api_details(j).uom_parameter;
             l_mapping_table(l_map_count).value          := p_ASG_results(i).units_of_measure;
             per_cagr_utility_pkg.put_log('   created mapping record: '||
                 l_mapping_table(l_map_count).parameter_name||'='||l_mapping_table(l_map_count).value);
           end if;
           exit;
         end if;
       end loop;
     end loop;

     per_cagr_utility_pkg.put_log('   built mapping array of size: '||l_map_count);
     if l_mapping_table.count > 0 then
       if l_api_details(1).api_name = 'HR_ASSIGNMENT_API.UPDATE_EMP_ASG' then

         get_ovn_and_mode (p_table_name      =>  'PER_ALL_ASSIGNMENTS_F'
                          ,p_dt_flag         =>  'Y'
                          ,p_pk              =>  'assignment_id'
                          ,p_pk_id           =>  p_params.assignment_id
                          ,p_effective_date  =>  p_params.effective_date
                          ,p_mode            =>  l_dt_mode
                          ,p_ovn             =>  l_ovn);

         per_cagr_utility_pkg.put_log('    calling HR_ASSIGNMENT_API.UPDATE_EMP_ASG in mode: '||l_dt_mode||' , OVN: '||l_ovn,1);
         BEGIN

           hr_assignment_api.update_emp_asg
            (p_effective_date               =>     p_params.effective_date
            ,p_datetrack_update_mode        =>     l_dt_mode
            ,p_assignment_id                =>     p_params.assignment_id
            ,p_object_version_number        =>     l_ovn
            ,p_normal_hours                 =>     get_num_val('NORMAL_HOURS',l_mapping_table)
            ,p_frequency                    =>     get_char_val('FREQUENCY',l_mapping_table)
            ,p_date_probation_end           =>     null /*Bug 5125705: End date does not get updated, if not passed */
            ,p_probation_period             =>     get_num_val('PROBATION_PERIOD',l_mapping_table)
            ,p_probation_unit               =>     get_char_val('PROBATION_UNIT',l_mapping_table)
            ,p_time_normal_start            =>     get_char_val('TIME_NORMAL_START',l_mapping_table)
            ,p_time_normal_finish           =>     get_char_val('TIME_NORMAL_FINISH',l_mapping_table)
            ,p_notice_period                =>     get_num_val('NOTICE_PERIOD',l_mapping_table)
            ,p_notice_period_uom            =>     get_char_val('NOTICE_PERIOD_UOM',l_mapping_table)
            ,p_bargaining_unit_code         =>     get_char_val('BARGAINING_UNIT_CODE',l_mapping_table)
            ,p_labour_union_member_flag     =>     get_char_val('LABOUR_UNION_MEMBER_FLAG',l_mapping_table)
            ,p_employee_category            =>     get_char_val('EMPLOYEE_CATEGORY',l_mapping_table)
            ,p_ASS_ATTRIBUTE_CATEGORY       =>     get_char_val('ASS_ATTRIBUTE_CATEGORY',l_mapping_table)
            ,p_ASS_ATTRIBUTE1               =>     get_char_val('ASS_ATTRIBUTE1',l_mapping_table)
            ,p_ASS_ATTRIBUTE2               =>     get_char_val('ASS_ATTRIBUTE2',l_mapping_table)
            ,p_ASS_ATTRIBUTE3               =>     get_char_val('ASS_ATTRIBUTE3',l_mapping_table)
            ,p_ASS_ATTRIBUTE4               =>     get_char_val('ASS_ATTRIBUTE4',l_mapping_table)
            ,p_ASS_ATTRIBUTE5               =>     get_char_val('ASS_ATTRIBUTE5',l_mapping_table)
            ,p_ASS_ATTRIBUTE6               =>     get_char_val('ASS_ATTRIBUTE6',l_mapping_table)
            ,p_ASS_ATTRIBUTE7               =>     get_char_val('ASS_ATTRIBUTE7',l_mapping_table)
            ,p_ASS_ATTRIBUTE8               =>     get_char_val('ASS_ATTRIBUTE8',l_mapping_table)
            ,p_ASS_ATTRIBUTE9               =>     get_char_val('ASS_ATTRIBUTE9',l_mapping_table)
            ,p_ASS_ATTRIBUTE10              =>     get_char_val('ASS_ATTRIBUTE10',l_mapping_table)
            ,p_ASS_ATTRIBUTE11              =>     get_char_val('ASS_ATTRIBUTE11',l_mapping_table)
            ,p_ASS_ATTRIBUTE12              =>     get_char_val('ASS_ATTRIBUTE12',l_mapping_table)
            ,p_ASS_ATTRIBUTE13              =>     get_char_val('ASS_ATTRIBUTE13',l_mapping_table)
            ,p_ASS_ATTRIBUTE14              =>     get_char_val('ASS_ATTRIBUTE14',l_mapping_table)
            ,p_ASS_ATTRIBUTE15              =>     get_char_val('ASS_ATTRIBUTE15',l_mapping_table)
            ,p_ASS_ATTRIBUTE16              =>     get_char_val('ASS_ATTRIBUTE16',l_mapping_table)
            ,p_ASS_ATTRIBUTE17              =>     get_char_val('ASS_ATTRIBUTE17',l_mapping_table)
            ,p_ASS_ATTRIBUTE18              =>     get_char_val('ASS_ATTRIBUTE18',l_mapping_table)
            ,p_ASS_ATTRIBUTE19              =>     get_char_val('ASS_ATTRIBUTE19',l_mapping_table)
            ,p_ASS_ATTRIBUTE20              =>     get_char_val('ASS_ATTRIBUTE20',l_mapping_table)
            ,p_ASS_ATTRIBUTE21              =>     get_char_val('ASS_ATTRIBUTE21',l_mapping_table)
            ,p_ASS_ATTRIBUTE22              =>     get_char_val('ASS_ATTRIBUTE22',l_mapping_table)
            ,p_ASS_ATTRIBUTE23              =>     get_char_val('ASS_ATTRIBUTE23',l_mapping_table)
            ,p_ASS_ATTRIBUTE24              =>     get_char_val('ASS_ATTRIBUTE24',l_mapping_table)
            ,p_ASS_ATTRIBUTE25              =>     get_char_val('ASS_ATTRIBUTE25',l_mapping_table)
            ,p_ASS_ATTRIBUTE26              =>     get_char_val('ASS_ATTRIBUTE26',l_mapping_table)
            ,p_ASS_ATTRIBUTE27              =>     get_char_val('ASS_ATTRIBUTE27',l_mapping_table)
            ,p_ASS_ATTRIBUTE28              =>     get_char_val('ASS_ATTRIBUTE28',l_mapping_table)
            ,p_ASS_ATTRIBUTE29              =>     get_char_val('ASS_ATTRIBUTE29',l_mapping_table)
            ,p_ASS_ATTRIBUTE30              =>     get_char_val('ASS_ATTRIBUTE30',l_mapping_table)
            ,p_SEGMENT1                     =>     get_char_val('SEGMENT1',l_mapping_table)
            ,p_SEGMENT2                     =>     get_char_val('SEGMENT2',l_mapping_table)
            ,p_SEGMENT3                     =>     get_char_val('SEGMENT3',l_mapping_table)
            ,p_SEGMENT4                     =>     get_char_val('SEGMENT4',l_mapping_table)
            ,p_SEGMENT5                     =>     get_char_val('SEGMENT5',l_mapping_table)
            ,p_SEGMENT6                     =>     get_char_val('SEGMENT6',l_mapping_table)
            ,p_SEGMENT7                     =>     get_char_val('SEGMENT7',l_mapping_table)
            ,p_SEGMENT8                     =>     get_char_val('SEGMENT8',l_mapping_table)
            ,p_SEGMENT9                     =>     get_char_val('SEGMENT9',l_mapping_table)
            ,p_SEGMENT10                    =>     get_char_val('SEGMENT10',l_mapping_table)
            ,p_SEGMENT11                    =>     get_char_val('SEGMENT11',l_mapping_table)
            ,p_SEGMENT12                    =>     get_char_val('SEGMENT12',l_mapping_table)
            ,p_SEGMENT13                    =>     get_char_val('SEGMENT13',l_mapping_table)
            ,p_SEGMENT14                    =>     get_char_val('SEGMENT14',l_mapping_table)
            ,p_SEGMENT15                    =>     get_char_val('SEGMENT15',l_mapping_table)
            ,p_SEGMENT16                    =>     get_char_val('SEGMENT16',l_mapping_table)
            ,p_SEGMENT17                    =>     get_char_val('SEGMENT17',l_mapping_table)
            ,p_SEGMENT18                    =>     get_char_val('SEGMENT18',l_mapping_table)
            ,p_SEGMENT19                    =>     get_char_val('SEGMENT19',l_mapping_table)
            ,p_SEGMENT20                    =>     get_char_val('SEGMENT20',l_mapping_table)
            ,p_SEGMENT21                    =>     get_char_val('SEGMENT21',l_mapping_table)
            ,p_SEGMENT22                    =>     get_char_val('SEGMENT22',l_mapping_table)
            ,p_SEGMENT23                    =>     get_char_val('SEGMENT23',l_mapping_table)
            ,p_SEGMENT24                    =>     get_char_val('SEGMENT24',l_mapping_table)
            ,p_SEGMENT25                    =>     get_char_val('SEGMENT25',l_mapping_table)
            ,p_SEGMENT26                    =>     get_char_val('SEGMENT26',l_mapping_table)
            ,p_SEGMENT27                    =>     get_char_val('SEGMENT27',l_mapping_table)
            ,p_SEGMENT28                    =>     get_char_val('SEGMENT28',l_mapping_table)
            ,p_SEGMENT29                    =>     get_char_val('SEGMENT29',l_mapping_table)
            ,p_SEGMENT30                    =>     get_char_val('SEGMENT30',l_mapping_table)
            ,P_CAGR_GRADE_DEF_ID            =>     l_CAGR_GRADE_DEF_ID
            ,P_CAGR_CONCATENATED_SEGMENTS   =>     l_CAGR_CONCATENATED_SEGMENTS
            ,p_comment_id                   =>     l_comment_id
            ,p_soft_coding_keyflex_id       =>     l_soft_coding_keyflex_id
            ,p_effective_start_date         =>     l_effective_start_date
            ,p_effective_end_date           =>     l_effective_end_date
            ,p_concatenated_segments        =>     l_concatenated_segments
            ,p_no_managers_warning          =>     l_no_managers_warning
            ,p_other_manager_warning        =>     l_other_manager_warning);

            -- log any warnings
            if l_no_managers_warning then
              per_cagr_utility_pkg.put_log('    WARNING: p_no_managers_warning',1);
            elsif l_other_manager_warning then
              per_cagr_utility_pkg.put_log('    WARNING: p_other_manager_warning',1);
            end if;
            per_cagr_utility_pkg.put_log('    done HR_ASSIGNMENT_API.UPDATE_EMP_ASG, OVN: '||l_ovn,1);
          EXCEPTION
            when others then   -- log unexpected API error, and continue
              per_cagr_utility_pkg.put_log('    ERROR: '||sqlerrm,1);
              --
              -- To show the Dictionary message in the log file
              --
              per_cagr_utility_pkg.put_log('    Dictionary Message: '||fnd_message.get,1);
              --
              per_cagr_utility_pkg.write_log_file(p_params.cagr_request_id);
         END;

       elsif l_api_details(1).api_name = 'HR_ASSIGNMENT_API.UPDATE_EMP_ASG_CRITERIA' then

         get_ovn_and_mode (p_table_name      =>  'PER_ALL_ASSIGNMENTS_F'
                          ,p_dt_flag         =>  'Y'
                          ,p_pk              =>  'assignment_id'
                          ,p_pk_id           =>  p_params.assignment_id
                          ,p_effective_date  =>  p_params.effective_date
                          ,p_mode            =>  l_dt_mode
                          ,p_ovn             =>  l_ovn);

         per_cagr_utility_pkg.put_log('    calling HR_ASSIGNMENT_API.UPDATE_EMP_ASG_CRITERIA in mode: '||l_dt_mode||', OVN: '||l_ovn,1);
         BEGIN
           hr_assignment_api.update_emp_asg_criteria
           (p_effective_date               =>     p_params.effective_date
           ,p_datetrack_update_mode        =>     l_dt_mode
           ,p_assignment_id                =>     p_params.assignment_id
           ,p_object_version_number        =>     l_ovn
           ,p_grade_id                     =>     get_num_val('GRADE_ID',l_mapping_table)
           ,p_job_id                       =>     get_num_val('JOB_ID',l_mapping_table)
           ,p_payroll_id                   =>     get_num_val('PAYROLL_ID',l_mapping_table)
           ,p_organization_id              =>     get_num_val('ORGANIZATION_ID',l_mapping_table)
           ,p_employment_category          =>     get_char_val('EMPLOYMENT_CATEGORY',l_mapping_table)
           ,p_pay_basis_id                 =>     get_num_val('PAY_BASIS_ID',l_mapping_table)
           ,p_special_ceiling_step_id      =>     l_special_ceiling_step_id
           ,p_group_name                   =>     l_group_name
           ,p_effective_start_date         =>     l_effective_start_date
           ,p_effective_end_date           =>     l_effective_end_date
           ,p_people_group_id              =>     l_people_group_id
           ,p_org_now_no_manager_warning   =>     l_org_now_no_manager_warning
           ,p_other_manager_warning        =>     l_other_manager_warning
           ,p_spp_delete_warning           =>     l_spp_delete_warning
           ,p_entries_changed_warning      =>     l_entries_changed_warning
           ,p_tax_district_changed_warning =>     l_tax_district_changed_warning);

           -- log any warnings
           if l_no_managers_warning then
             per_cagr_utility_pkg.put_log('    WARNING: p_no_managers_warning',1);
           elsif l_other_manager_warning then
             per_cagr_utility_pkg.put_log('    WARNING: p_other_manager_warning',1);
           elsif l_spp_delete_warning then
             l_warn_message := fnd_message.get_string(
  				APPIN  => 'PER'
			      , NAMEIN => 'HR_289826_SPP_DELETE_WARN_API');
             per_cagr_utility_pkg.put_log('    WARNING: '||l_warn_message,1);
           end if;
           per_cagr_utility_pkg.put_log('    done HR_ASSIGNMENT_API.UPDATE_EMP_ASG_CRITERIA, OVN: '||l_ovn,1);
          EXCEPTION
            when others then   -- log unexpected API error, and continue
              per_cagr_utility_pkg.put_log('    ERROR: '||sqlerrm,1);
              --
              -- To show the Dictionary message in the log file
              --
              per_cagr_utility_pkg.put_log('    Dictionary Message: '||fnd_message.get,1);
              --
              per_cagr_utility_pkg.write_log_file(p_params.cagr_request_id);
         END;

       end if;
     end if;

     -- delete pl/sql tables
     l_api_details.delete;
     l_mapping_table.delete;

   hr_utility.set_location('Leaving:'||l_proc, 5);
  END call_ASG_api;

-- ================================================================================================
 -- ==     ****************              CALL_PYS_API                *****************            ==
 -- ================================================================================================
  PROCEDURE call_PYS_api (p_params      IN  per_cagr_evaluation_pkg.control_structure
                         ,p_PYS_results IN  t_PYS_results) IS

  -- Identify which SPP api to call (create or update) and build mapping table from
  -- result records and invoke the api to apply the result. (Only step_id in phase 1)
  -- Limitation is that seed data should only allow user to denorm to update data columns
  -- (as these will always be avail when updating or creating) allowing us to dynamically
  -- switch from update to create api call, using update entitlement results.

  -- get API data (for seeded denormalised columns only)
  -- i.e. not expecting to be seeding UOM columns separately

   CURSOR csr_api (v_api_name in varchar2) IS
    SELECT apip.parameter_name
          ,apip.cagr_api_param_id
          ,apip.column_type
          ,apip.uom_parameter
          ,api.api_name
    FROM  per_cagr_api_parameters apip, per_cagr_apis api
    WHERE api.api_name = v_api_name
    AND   api.cagr_api_id = apip.cagr_api_id;

  -- get placement_id rec
   CURSOR csr_placement_id IS
    SELECT placement_id
    FROM   per_spinal_point_placements_f
    WHERE  assignment_id = p_params.assignment_id
    AND    p_params.effective_date BETWEEN effective_start_date and nvl(effective_end_date,hr_general.end_of_time);

   TYPE t_api_details   IS TABLE OF csr_api%ROWTYPE INDEX BY BINARY_INTEGER;

   l_api_name                        per_cagr_apis.api_name%type;
   l_mapping_table                   t_mapping_table;
   l_api_details                     t_api_details;
   l_proc constant                   VARCHAR2(80)    := g_pkg || 'call_PYS_api';
   l_map_count                       NUMBER(10)      := 0;
   l_count                           NUMBER(10)      := 0;
   l_switched_api                    BOOLEAN         := FALSE;

   l_dt_mode                         VARCHAR2(30)    := 'UPDATE';
   l_ovn                             NUMBER(10)      := NULL;
   l_placement_id                    NUMBER(10)      := NULL;
   l_step_id                         NUMBER(10)      := NULL;
   l_effective_start_date            DATE;
   l_effective_end_date              DATE;

   BEGIN
     hr_utility.set_location('Entering:'||l_proc, 5);

     -- first check if we need to call update or create api

     open csr_placement_id;
     fetch csr_placement_id into l_placement_id;
     close csr_placement_id;

     if l_placement_id is not null then
       -- we will be updating spp
       l_api_name := 'HR_SP_PLACEMENT_API.UPDATE_SPP';

       get_ovn_and_mode (p_table_name      =>  'PER_SPINAL_POINT_PLACEMENTS_F'
                        ,p_dt_flag         =>  'Y'
                        ,p_pk              =>  'PLACEMENT_ID'
                        ,p_pk_id           =>  l_placement_id
                        ,p_effective_date  =>  p_params.effective_date
                        ,p_mode            =>  l_dt_mode
                        ,p_ovn             =>  l_ovn);
     else
       -- we will be creating spp
       -- problem as there are no params seeded for it!!!
       l_api_name := 'HR_SP_PLACEMENT_API.CREATE_SPP';
       l_switched_api := TRUE;
     end if;

     -- build pl/sql table of all seeded api column names for the update API name
     -- (as the create params are a subset of update in this case)
     -- BUT this will be a problem should any new create params be added that are NOT updateable
     for v_api_details in csr_api('HR_SP_PLACEMENT_API.UPDATE_SPP') loop
       l_count := l_count+1;
       l_api_details(l_count) :=  v_api_details;
     end loop;
     per_cagr_utility_pkg.put_log('   built api_details array of size: '||l_count);

     --  loop thru each ent result and create mapping record(s)
     for i in p_PYS_results.first..p_PYS_results.last loop
       l_map_count := l_map_count+1;
       l_mapping_table(l_map_count).value := p_PYS_results(i).step_id;

       --  get the PARAMETER_NAME and UOM column from the API details structure
       for j in l_api_details.first..l_api_details.last loop
         -- the cagr_api_param_id does not necessarily match between results reference update api
         -- but we have identified that we actually need to use create, so use parameter name instead...
         if l_api_details(j).cagr_api_param_id = p_PYS_results(i).cagr_api_param_id then
           l_mapping_table(l_map_count).parameter_name := l_api_details(j).parameter_name;
           per_cagr_utility_pkg.put_log('   created mapping record: '||
               l_mapping_table(l_map_count).parameter_name||'='||l_mapping_table(l_map_count).value);
           -- also create a mapping table record, if there is a uom col
           if l_api_details(j).uom_parameter is not null then
             l_map_count := l_map_count+1;
             l_mapping_table(l_map_count).parameter_name := l_api_details(j).uom_parameter;
             l_mapping_table(l_map_count).value          := p_PYS_results(i).units_of_measure;
             per_cagr_utility_pkg.put_log('   created mapping record: '||
                 l_mapping_table(l_map_count).parameter_name||'='||l_mapping_table(l_map_count).value);
           end if;
           exit;
         end if;
       end loop;
     end loop;

     per_cagr_utility_pkg.put_log('   built mapping array of size: '||l_map_count);

     if l_map_count > 0 then
       BEGIN
         if l_api_name = 'HR_SP_PLACEMENT_API.CREATE_SPP' then

           per_cagr_utility_pkg.put_log('    calling HR_SP_PLACEMENT_API.CREATE_SPP',1);
           l_step_id := get_num_val('STEP_ID',l_mapping_table);
           if l_step_id is null then
             -- check other mandatory params are supplied
             per_cagr_utility_pkg.put_log('   ERROR: Cannot call HR_SP_PLACEMENT_API.CREATE_SPP with null STEP_ID',1);
           else
            -- per_cagr_utility_pkg.put_log('   date: '||p_params.effective_date,1);
            -- per_cagr_utility_pkg.put_log('   BG: '||to_char(p_params.business_group_id),1);
            -- per_cagr_utility_pkg.put_log('   asg: '||to_char(p_params.assignment_id),1);
            -- per_cagr_utility_pkg.put_log('   step: '||to_char(l_step_id),1);
             hr_sp_placement_api.create_spp
             (p_effective_date         =>   p_params.effective_date
             ,p_business_group_id      =>   p_params.business_group_id
             ,p_assignment_id          =>   p_params.assignment_id        -- current assignment
             ,p_step_id                =>   l_step_id
             ,p_object_version_number  =>   l_ovn
             ,p_placement_id           =>   l_placement_id
             ,p_effective_start_date   =>   l_effective_start_date
             ,p_effective_end_date     =>   l_effective_end_date);
             per_cagr_utility_pkg.put_log('    done HR_SP_PLACEMENT_API.CREATE_SPP',1);
            -- per_cagr_utility_pkg.put_log('   placement_id: '||to_char(l_placement_id),1);
            -- per_cagr_utility_pkg.put_log('   date: '||l_effective_start_date,1);
            -- per_cagr_utility_pkg.put_log('   date: '||l_effective_end_date,1);
           end if;
         elsif l_api_name = 'HR_SP_PLACEMENT_API.UPDATE_SPP' then

           per_cagr_utility_pkg.put_log('    calling HR_SP_PLACEMENT_API.UPDATE_SPP',1);
           hr_sp_placement_api.update_spp
           (p_effective_date         =>   p_params.effective_date
           ,p_datetrack_mode         =>   l_dt_mode
           ,p_placement_id           =>   l_placement_id
           ,p_step_id                =>   get_num_val('STEP_ID',l_mapping_table)
           ,p_object_version_number  =>   l_ovn
           ,p_effective_start_date   =>   l_effective_start_date
           ,p_effective_end_date     =>   l_effective_end_date);

           per_cagr_utility_pkg.put_log('    done HR_SP_PLACEMENT_API.UPDATE_SPP',1);
         end if;
       EXCEPTION
         when others then   -- log unexpected API error, and continue
           per_cagr_utility_pkg.put_log('    ERROR: '||sqlerrm,1);
           per_cagr_utility_pkg.write_log_file(p_params.cagr_request_id);
       END;

     end if;

     -- delete pl/sql tables
     l_api_details.delete;
     l_mapping_table.delete;


   hr_utility.set_location('Leaving:'||l_proc, 5);
  END call_PYS_api;


 -- ================================================================================================
 -- ==     ****************              CALL_PAY_API                *****************            ==
 -- ================================================================================================

  PROCEDURE call_PAY_api (p_params      IN  per_cagr_evaluation_pkg.control_structure
                         ,p_PAY_results IN  t_PAY_results) IS
   --
   -- Accepts structure holding results for a specific element type, and co-ordinates
   -- denormalisation of those result values to relevant entry_values of any element
   -- that exists for the element type - asg - effective date combination
   -- May update (never insert) recurring or non recurring entries.
   -- May denormalise to more than one element entry record for the element type,
   -- if there are multiple entries in existence for the type, and the item's flag
   -- multiple_element_entries_allowed is 'Y'. If flag is 'N' and there are multiple
   -- entries in existence on the effective date then error is logged.
   -- (Exception is GB legislation where an element entry can be set as substitute override
   -- (entry_type = 'S') which means that only that entry is valid for the element type
   -- on the effective_date, and so only that entry can be updated irrespective of whether multiple
   -- is allowed or not).

   -- get the legislation_code for bg.
   CURSOR csr_bg IS
     SELECT legislation_code
     FROM per_business_groups_perf
     WHERE business_group_id = p_params.business_group_id
     and rownum = 1; -- Added for bug 3387328 to improve performance.

   -- get the details of element entries that exist
   -- for the element_type and asg on the effective_date
   -- p_entry_id is only set if override entry (this is a workaround for GB leg)
   CURSOR csr_entries (p_assignment_id NUMBER
                      ,p_element_type_id NUMBER
                      ,p_entry_id IN NUMBER) IS
    SELECT ee.element_entry_id,  ee.entry_type, el.element_link_id
    FROM pay_element_links el, pay_element_entries ee
    WHERE el.ELEMENT_TYPE_ID = p_element_type_id
    AND ee.ELEMENT_LINK_ID = el.ELEMENT_LINK_ID
    AND ee.ASSIGNMENT_ID = p_assignment_id
    AND (p_entry_id is null or (p_entry_id is not null and ee.element_entry_id = p_entry_id))
    AND p_params.effective_date BETWEEN el.EFFECTIVE_START_DATE
                                AND nvl(el.EFFECTIVE_END_DATE,hr_general.end_of_time)
    AND p_params.effective_date BETWEEN ee.EFFECTIVE_START_DATE
                                AND nvl(ee.EFFECTIVE_END_DATE,hr_general.end_of_time);

    Cursor csr_entries_not_exists(p_assignment_id NUMBER
                      ,p_element_type_id NUMBER) IS
    Select distinct cer.element_type_id
    From   per_cagr_entitlement_results  cer
    Where  cer.ASSIGNMENT_ID = p_assignment_id
    and    cer.end_date is null --fix for bug 5747086
    And    not exists (select 1
                       From pay_element_entries ee
                       Where cer.assignment_id = ee.assignment_id
                       And   cer.element_type_id = ee.element_type_id
                       And   ee.element_type_id  = p_element_type_id
                       And  p_params.effective_date BETWEEN ee.EFFECTIVE_START_DATE
                            AND nvl(ee.EFFECTIVE_END_DATE,hr_general.end_of_time))
    Order by cer.element_type_id;


   Cursor csr_entitlement_items(p_assignment_id NUMBER,
                               p_element_type_id NUMBER) IS
   select cer.cagr_entitlement_item_id
   from   per_cagr_entitlement_results cer,
          per_cagr_entitlement_items   cei
   where  cer.assignment_id   = p_assignment_id
   and    cer.element_type_id = p_element_type_id
   and    cer.cagr_entitlement_item_id = cei.cagr_entitlement_item_id
   and    nvl(cei.auto_create_entries_flag,'N')   = 'Y'
   order  by cer.cagr_entitlement_item_id;


-- Bug 6645756
Cursor csr_ineligible_entitlements(p_assignment_id number) IS
SELECT DISTINCT cagr_entitlement_item_id
FROM   per_cagr_entitlement_results cer
WHERE  ASSIGNMENT_ID = p_assignment_id
AND    NOT EXISTS (SELECT 1 FROM per_cagr_entitlement_results
		WHERE cer.cagr_entitlement_item_id = cagr_entitlement_item_id
		AND start_date = trunc(p_params.effective_date)
		AND ASSIGNMENT_ID = p_assignment_id)
AND    EXISTS   ( SELECT 1 FROM per_cagr_entitlement_results
		WHERE cer.cagr_entitlement_item_id = cagr_entitlement_item_id
		AND end_date = trunc(p_params.effective_date) - 1
		AND ASSIGNMENT_ID = p_assignment_id);

CURSOR csr_entitlement_element_detail(p_entitlement_id number, p_assignment_id number) IS
SELECT cei.element_type_id,cer.start_date,cer.end_date
FROM   per_cagr_entitlement_results  cer,PER_CAGR_ENTITLEMENT_ITEMS cei
WHERE  cer.ASSIGNMENT_ID = p_assignment_id
AND cer.end_date = trunc(p_params.effective_date)-1
AND cer.cagr_entitlement_item_id=cei.cagr_entitlement_item_id
AND cei.cagr_entitlement_item_id = p_entitlement_id;

CURSOR csr_ele_entries (p_assignment_id number,p_element_type_id number,p_end_date date) is
SELECT element_entry_id,object_version_number
FROM pay_element_entries_f
WHERE element_type_id=p_element_type_id
AND assignment_id=p_assignment_id
AND effective_start_date<=p_end_date
AND effective_end_date>p_end_date;

   l_element_type_id                  NUMBER(15);
   l_start_date                       DATE;
   l_end_date                         DATE;
   l_entitlement_id                   per_cagr_entitlement_items.cagr_entitlement_item_id%type;
--fix for bug 5557658 ends here.

   l_mapping_table                   t_mapping_table;
   l_proc constant                   VARCHAR2(80)    := g_pkg || 'call_PAY_api';
   l_map_count                       NUMBER(10)      := 0;
   l_dt_mode                         VARCHAR2(30)    := 'UPDATE';
   v_entries                         csr_entries%ROWTYPE;
   v_entries_not_exists              csr_entries_not_exists%ROWTYPE;
   v_entitlement_items               csr_entitlement_items%ROWTYPE;

   -- local vars to catch out params
   l_ovn                             NUMBER(10);
   l_entry_id                        NUMBER(15);
   l_element_link_id                 NUMBER(15);
   l_element_entry_id                NUMBER(15);
   l_effective_start_date            DATE;
   l_effective_end_date              DATE;
   l_warning                         BOOLEAN         := FALSE;
   l_auto_entries                    BOOLEAN         := FALSE;
   l_multi                           VARCHAR2(1)     := 'N';
   l_too_many_entries                VARCHAR2(1)     := NULL;
   l_legislation_code                VARCHAR2(2)     := NULL;

   BEGIN
     hr_utility.set_location('Entering:'||l_proc, 5);


     -- get the leg_code
     open csr_bg;
     fetch csr_bg into l_legislation_code;
     close csr_bg;

     -- build and populate mapping table with iv_ids and entry values
     -- from the table of entitlement result records
     for i in p_PAY_results.first..p_PAY_results.last loop
       if (l_too_many_entries is null and p_PAY_results(i).multiple_entries_allowed_flag = 'N')
          or (l_legislation_code = 'GB') then
         -- here we are doing additional processing if the item uses multiple entries flag,
         -- or the item is for GB and so can be overriden
         -- e.t. allows multiple e.e. and the user has set update multi to N on item
         -- so error log if there are > 1 entries that will be updated
         open csr_entries(p_pay_results(i).assignment_id
                         ,p_PAY_results(i).element_type_id
                         ,NULL);
         if l_legislation_code = 'GB' then
           -- loop through all entries to
           -- check if there is an override set
           loop
             fetch csr_entries into v_entries;
             exit when csr_entries%notfound;
             if v_entries.entry_type = 'S' then
               -- store the override entry id
               per_cagr_utility_pkg.put_log('Override entry exists - only this will be updated: '||v_entries.element_entry_id);
               l_entry_id := v_entries.element_entry_id;
             end if;
           end loop;
         else
           -- just see if there is > 1 entry
           for i in 1..2 loop                     -- dummy loop
             fetch csr_entries into v_entries;
             exit when csr_entries%notfound;
           end loop;
         end if;
         if csr_entries%rowcount > 1 then
           close csr_entries;
           l_too_many_entries := 'Y';
         else
           close csr_entries;
           l_too_many_entries := 'N';
         end if;
       end if;

       if l_too_many_entries = 'Y' and p_PAY_results(i).multiple_entries_allowed_flag = 'N'
       and l_entry_id is null then
           -- not an override GB element entry so show message
           per_cagr_utility_pkg.put_log('  iv: '||p_PAY_results(i).input_value_id);
           per_cagr_utility_pkg.put_log('  ev: '||p_PAY_results(i).value);
           per_cagr_utility_pkg.put_log('    Error: More than 1 entry found for payroll item on the '
                                    ||'effective_date and updating multiple entries is not allowed.',1);
           per_cagr_utility_pkg.put_log('    Item value will not be applied to element_entry records.',1);
       else
         -- build the mapping table for the results
         per_cagr_utility_pkg.put_log('  iv: '||p_PAY_results(i).input_value_id);
         l_map_count := l_map_count+1;
         l_mapping_table(l_map_count).parameter_name := 'INPUT_VALUE_ID'||i;
         l_mapping_table(l_map_count).value := p_PAY_results(i).input_value_id;
         l_map_count := l_map_count+1;
         l_mapping_table(l_map_count).parameter_name := 'ENTRY_VALUE'||i;
         l_mapping_table(l_map_count).value := p_PAY_results(i).value;
         per_cagr_utility_pkg.put_log('  ev: '||p_PAY_results(i).value);
       end if;

     end loop;

     per_cagr_utility_pkg.put_log('   built mapping array of size: '||l_map_count);

     if l_mapping_table.count > 0 then

         -- get all entry recs for the element type on the effective_date
         -- (if GB and we know the id of the override then restrict to that entry only)
         open csr_entries (p_pay_results(1).assignment_id
                          ,p_pay_results(1).element_type_id
                          ,l_entry_id);

         loop
           fetch csr_entries into v_entries;
           exit when csr_entries%notfound;

           -- determine the ovn, dt mode for the ele entry in this iteration
           get_ovn_and_mode (p_table_name      =>  'PAY_ELEMENT_ENTRIES_F'
                            ,p_dt_flag         =>  'Y'
                            ,p_pk              =>  'ELEMENT_ENTRY_ID'
                            ,p_pk_id           =>  v_entries.element_entry_id
                            ,p_effective_date  =>  p_params.effective_date
                            ,p_mode            =>  l_dt_mode
                            ,p_ovn             =>  l_ovn);

           -- if the element entry is non recurring then api should be called in CORRECTION mode only.
           -- check here, or modify get_ovn_and_mode

           per_cagr_utility_pkg.put_log('    calling PY_ELEMENT_ENTRY_API.UPDATE_ELEMENT_ENTRY in mode: '||l_dt_mode,1);
           BEGIN
             py_element_entry_api.update_element_entry(
             p_datetrack_update_mode    => l_dt_mode,
             p_effective_date           => p_params.effective_date,
             p_business_group_id        => p_params.business_group_id,
             p_element_entry_id         => v_entries.element_entry_id,
             p_object_version_number    => l_ovn,
             p_input_value_id1          => get_num_val('INPUT_VALUE_ID1',l_mapping_table),
             p_input_value_id2          => get_num_val('INPUT_VALUE_ID2',l_mapping_table),
             p_input_value_id3          => get_num_val('INPUT_VALUE_ID3',l_mapping_table),
             p_input_value_id4          => get_num_val('INPUT_VALUE_ID4',l_mapping_table),
             p_input_value_id5          => get_num_val('INPUT_VALUE_ID5',l_mapping_table),
             p_input_value_id6          => get_num_val('INPUT_VALUE_ID6',l_mapping_table),
             p_input_value_id7          => get_num_val('INPUT_VALUE_ID7',l_mapping_table),
             p_input_value_id8          => get_num_val('INPUT_VALUE_ID8',l_mapping_table),
             p_input_value_id9          => get_num_val('INPUT_VALUE_ID9',l_mapping_table),
             p_input_value_id10         => get_num_val('INPUT_VALUE_ID10',l_mapping_table),
             p_input_value_id11         => get_num_val('INPUT_VALUE_ID11',l_mapping_table),
             p_input_value_id12         => get_num_val('INPUT_VALUE_ID12',l_mapping_table),
             p_input_value_id13         => get_num_val('INPUT_VALUE_ID13',l_mapping_table),
             p_input_value_id14         => get_num_val('INPUT_VALUE_ID14',l_mapping_table),
             p_input_value_id15         => get_num_val('INPUT_VALUE_ID15',l_mapping_table),
             p_entry_value1             => get_char_val('ENTRY_VALUE1',l_mapping_table),
             p_entry_value2             => get_char_val('ENTRY_VALUE2',l_mapping_table),
             p_entry_value3             => get_char_val('ENTRY_VALUE3',l_mapping_table),
             p_entry_value4             => get_char_val('ENTRY_VALUE4',l_mapping_table),
             p_entry_value5             => get_char_val('ENTRY_VALUE5',l_mapping_table),
             p_entry_value6             => get_char_val('ENTRY_VALUE6',l_mapping_table),
             p_entry_value7             => get_char_val('ENTRY_VALUE7',l_mapping_table),
             p_entry_value8             => get_char_val('ENTRY_VALUE8',l_mapping_table),
             p_entry_value9             => get_char_val('ENTRY_VALUE9',l_mapping_table),
             p_entry_value10            => get_char_val('ENTRY_VALUE10',l_mapping_table),
             p_entry_value11            => get_char_val('ENTRY_VALUE11',l_mapping_table),
             p_entry_value12            => get_char_val('ENTRY_VALUE12',l_mapping_table),
             p_entry_value13            => get_char_val('ENTRY_VALUE13',l_mapping_table),
             p_entry_value14            => get_char_val('ENTRY_VALUE14',l_mapping_table),
             p_entry_value15            => get_char_val('ENTRY_VALUE15',l_mapping_table),
             p_effective_start_date     => l_effective_start_date,
             p_effective_end_date       => l_effective_end_date,
             p_update_warning           => l_warning);

             -- log any warnings
             if l_warning then
               per_cagr_utility_pkg.put_log('    WARNING: p_update_warning',1);
             end if;
             per_cagr_utility_pkg.put_log('    done PY_ELEMENT_ENTRY_API.UPDATE_ELEMENT_ENTRY in mode: '||l_dt_mode,1);
           EXCEPTION
             when others then       -- log unexpected API error, and continue
               per_cagr_utility_pkg.put_log('    ERROR: '||sqlerrm,1);
               per_cagr_utility_pkg.write_log_file(p_params.cagr_request_id);
           END;
         end loop;
         if csr_entries%rowcount = 0 then
         per_cagr_utility_pkg.put_log('    Warning: 0 element entries found for element_type_id '||
                                             p_pay_results(1).element_type_id||' on assignment '||
                                             p_pay_results(1).assignment_id,1);
         end if;
         close csr_entries;

     end if;


     -- delete pl/sql tables
     l_mapping_table.delete;


   /* Enhancements - Create Element Entry if it does not exists and the
      Auto Entry Flag for the CAGR Entitlement Item is checked         */

     l_map_count := 0;
     l_warning   := FALSE;

         per_cagr_utility_pkg.put_log('New EE Entries ',5);
     -- build and populate mapping table with iv_ids and entry values
     -- from the table of entitlement result records
     for i in p_PAY_results.first..p_PAY_results.last loop

         -- build the mapping table for the results
         l_map_count := l_map_count+1;
         per_cagr_utility_pkg.put_log('map count = '||l_map_count,5);
         l_mapping_table(l_map_count).parameter_name := 'INPUT_VALUE_ID'||i;
         per_cagr_utility_pkg.put_log('input_value_id : '||p_PAY_results(i).input_value_id,5);
         l_mapping_table(l_map_count).value := p_PAY_results(i).input_value_id;
         l_map_count := l_map_count+1;
         per_cagr_utility_pkg.put_log('entry_value : '||p_PAY_results(i).value,5);
         l_mapping_table(l_map_count).parameter_name := 'ENTRY_VALUE'||i;
         l_mapping_table(l_map_count).value := p_PAY_results(i).value;
         per_cagr_utility_pkg.put_log('  ev: '||p_PAY_results(i).value,5);

     end loop;

     per_cagr_utility_pkg.put_log('   built mapping array of size: '||l_map_count,5);

     if l_mapping_table.count > 0 then

         -- get all entry recs for the assignment on the effective_date
         --
         open csr_entries_not_exists (p_pay_results(1).assignment_id
                                     ,p_pay_results(1).element_type_id);

         loop
           fetch csr_entries_not_exists into v_entries_not_exists;
           exit when csr_entries_not_exists%notfound;

           open csr_entitlement_items(p_params.assignment_id,
                                       v_entries_not_exists.element_type_id);
           fetch csr_entitlement_items into v_entitlement_items;
           if csr_entitlement_items%FOUND then
              close csr_entitlement_items;

           BEGIN
             l_element_link_id := hr_entry_api.get_link
                                 (p_assignment_id      => p_params.assignment_id,
                                  p_element_type_id    => v_entries_not_exists.element_type_id,
                                  p_session_date       => p_params.effective_date);

             per_cagr_utility_pkg.put_log(' Assignment ID  = '||p_params.assignment_id);
             per_cagr_utility_pkg.put_log(' Element TypeID = '||v_entries_not_exists.element_type_id);
             per_cagr_utility_pkg.put_log(' Element LinkID = '||l_element_link_id);
             pay_element_entry_api.create_element_entry(
             p_validate                 => FALSE,
             p_effective_date           => p_params.effective_date,
             p_business_group_id        => p_params.business_group_id,
             p_assignment_id            => p_params.assignment_id,
             p_element_link_id          => l_element_link_id,
             p_entry_type               => 'E',
             p_input_value_id1          => get_num_val('INPUT_VALUE_ID1',l_mapping_table),
             p_input_value_id2          => get_num_val('INPUT_VALUE_ID2',l_mapping_table),
             p_input_value_id3          => get_num_val('INPUT_VALUE_ID3',l_mapping_table),
             p_input_value_id4          => get_num_val('INPUT_VALUE_ID4',l_mapping_table),
             p_input_value_id5          => get_num_val('INPUT_VALUE_ID5',l_mapping_table),
             p_input_value_id6          => get_num_val('INPUT_VALUE_ID6',l_mapping_table),
             p_input_value_id7          => get_num_val('INPUT_VALUE_ID7',l_mapping_table),
             p_input_value_id8          => get_num_val('INPUT_VALUE_ID8',l_mapping_table),
             p_input_value_id9          => get_num_val('INPUT_VALUE_ID9',l_mapping_table),
             p_input_value_id10         => get_num_val('INPUT_VALUE_ID10',l_mapping_table),
             p_input_value_id11         => get_num_val('INPUT_VALUE_ID11',l_mapping_table),
             p_input_value_id12         => get_num_val('INPUT_VALUE_ID12',l_mapping_table),
             p_input_value_id13         => get_num_val('INPUT_VALUE_ID13',l_mapping_table),
             p_input_value_id14         => get_num_val('INPUT_VALUE_ID14',l_mapping_table),
             p_input_value_id15         => get_num_val('INPUT_VALUE_ID15',l_mapping_table),
             p_entry_value1             => get_char_val('ENTRY_VALUE1',l_mapping_table),
             p_entry_value2             => get_char_val('ENTRY_VALUE2',l_mapping_table),
             p_entry_value3             => get_char_val('ENTRY_VALUE3',l_mapping_table),
             p_entry_value4             => get_char_val('ENTRY_VALUE4',l_mapping_table),
             p_entry_value5             => get_char_val('ENTRY_VALUE5',l_mapping_table),
             p_entry_value6             => get_char_val('ENTRY_VALUE6',l_mapping_table),
             p_entry_value7             => get_char_val('ENTRY_VALUE7',l_mapping_table),
             p_entry_value8             => get_char_val('ENTRY_VALUE8',l_mapping_table),
             p_entry_value9             => get_char_val('ENTRY_VALUE9',l_mapping_table),
             p_entry_value10            => get_char_val('ENTRY_VALUE10',l_mapping_table),
             p_entry_value11            => get_char_val('ENTRY_VALUE11',l_mapping_table),
             p_entry_value12            => get_char_val('ENTRY_VALUE12',l_mapping_table),
             p_entry_value13            => get_char_val('ENTRY_VALUE13',l_mapping_table),
             p_entry_value14            => get_char_val('ENTRY_VALUE14',l_mapping_table),
             p_entry_value15            => get_char_val('ENTRY_VALUE15',l_mapping_table),
             p_effective_start_date     => l_effective_start_date,
             p_effective_end_date       => l_effective_end_date,
             p_element_entry_id         => l_element_entry_id,
             p_object_version_number    => l_ovn,
             p_create_warning           => l_warning);
             per_cagr_utility_pkg.put_log(' End of create element entry.');
             per_cagr_utility_pkg.put_log(' Element EntryID = '||l_element_entry_id);

             -- log any warnings
             if l_warning then
               per_cagr_utility_pkg.put_log('    WARNING: p_create_warning',1);
             end if;
             per_cagr_utility_pkg.put_log('    Done PAY_ELEMENT_ENTRY_API.CREATE_ELEMENT_ENTRY '||l_element_entry_id,1);
           EXCEPTION
             when others then       -- log unexpected API error, and continue
               per_cagr_utility_pkg.put_log('    ERROR: '||sqlerrm,1);
               per_cagr_utility_pkg.write_log_file(p_params.cagr_request_id);
           END;

           else

           close csr_entitlement_items;

           per_cagr_utility_pkg.put_log('    WARNING: Auto Entry flag for Entitlement Item is not checked');

           end if;

         end loop;
         if csr_entries_not_exists%rowcount = 0 then
         per_cagr_utility_pkg.put_log('    Warning: 0 element entries found for element_type_id '||
                                             p_pay_results(1).element_type_id||' on assignment '||
                                             p_pay_results(1).assignment_id,1);
         end if;
         close csr_entries_not_exists;

     end if;

     -- delete pl/sql tables
     l_mapping_table.delete;

/* Enhancements  End  Create Element Entry */

-- Changes done for bug 6645756

OPEN csr_ineligible_entitlements(p_params.assignment_id);
LOOP
FETCH csr_ineligible_entitlements INTO l_entitlement_id;
EXIT WHEN csr_ineligible_entitlements%NOTFOUND;
  -- Assignment is ineligible in future for current entitlement, get the element details and end date
  -- corresponding assignment element entries.
  OPEN csr_entitlement_element_detail(l_entitlement_id, p_params.assignment_id);
  /* Get all the records in per_cagr_entitlement_results, which are end dated on the effective date */
  loop
  fetch csr_entitlement_element_detail into l_element_type_id,l_start_date,l_end_date;
  exit when csr_entitlement_element_detail%notfound;

  open csr_ele_entries(p_params.assignment_id,l_element_type_id,l_end_date);
  loop
  fetch csr_ele_entries into l_element_entry_id, l_ovn;
  exit when csr_ele_entries%notFOUND ;

  py_element_entry_api.delete_element_entry
  (p_validate                   =>  FALSE
  ,p_datetrack_delete_mode      =>  'DELETE'
  ,p_effective_date             =>  l_end_date
  ,p_element_entry_id           =>  l_element_entry_id
  ,p_object_version_number      =>  l_ovn
  ,p_effective_start_date       =>  l_effective_start_date
  ,p_effective_end_date         =>  l_effective_end_date
  ,p_delete_warning             =>  l_warning
  );

end loop;
close csr_ele_entries;
end loop;
close csr_entitlement_element_detail;
END loop;
CLOSE csr_ineligible_entitlements;
-- fix for bug 6645756 ends here.

   hr_utility.set_location('Leaving:'||l_proc, 5);
  END call_PAY_api;

 -- ================================================================================================
 -- ==     ****************          do_apply_for_assignment            *****************         ==
 -- ================================================================================================
  PROCEDURE do_apply_for_assignment(p_params IN OUT NOCOPY per_cagr_evaluation_pkg.control_structure
                                   ,p_select_flag IN varchar2) IS
 --
 -- This routine controls the apply processing for a particular assignment on the effective_date.
 --

 -- get ASG category results to be applied, for an asg.
 -- either chosen or beneficial if none chosen
  CURSOR csr_ASG_denorm_results IS
   SELECT  cagr_entitlement_result_id
          ,assignment_id
          ,cagr_entitlement_item_id
          ,cagr_api_id
          ,cagr_api_param_id
          ,value
          ,units_of_measure
   FROM  per_cagr_entitlement_results
   WHERE category_name = 'ASG'
     AND (p_params.assignment_id is not null and assignment_id = p_params.assignment_id)
     AND (chosen_flag = 'Y'
          OR (beneficial_flag = 'Y'
               and not exists (select 'X' from per_cagr_entitlement_results res1
                               where  res1.assignment_id = p_params.assignment_id
                               and res1.cagr_entitlement_item_id = cagr_entitlement_item_id
                               AND res1.chosen_flag = 'Y'
                               AND p_params.effective_date between start_date and nvl(end_date,hr_general.end_of_time))))
     AND cagr_api_id is not null
     AND p_params.effective_date between start_date and nvl(end_date,hr_general.end_of_time)
   ORDER BY cagr_api_id;

-- get PYS category results to be applied (step_id, increment_number) for an asg.
  CURSOR csr_PYS_denorm_results IS
   SELECT  cagr_entitlement_result_id
          ,assignment_id
          ,cagr_entitlement_item_id
          ,cagr_api_id
          ,cagr_api_param_id
          ,category_name
          ,grade_spine_id
          ,parent_spine_id
          ,step_id
          ,from_step_id
          ,to_step_id
          ,value
          ,units_of_measure
   FROM  per_cagr_entitlement_results
   WHERE category_name = 'PYS'
     AND (p_params.assignment_id is not null and assignment_id = p_params.assignment_id)
     AND (chosen_flag = 'Y'
          OR (beneficial_flag = 'Y'
               and not exists (select 'X' from per_cagr_entitlement_results res1
                               where  res1.assignment_id = p_params.assignment_id
                               and res1.cagr_entitlement_item_id = cagr_entitlement_item_id
                               AND res1.chosen_flag = 'Y'
                               AND p_params.effective_date between start_date and nvl(end_date,hr_general.end_of_time))))
     AND cagr_api_id is not null
     AND p_params.effective_date between start_date and nvl(end_date,hr_general.end_of_time)
   ORDER BY cagr_api_id;

-- get PAY category results to be applied (element is set) for an asg.
   -- ordered by element_type
  CURSOR csr_PAY_denorm_results IS
   SELECT  cagr_entitlement_result_id
          ,assignment_id
          ,cagr_entitlement_item_id
          ,category_name
          ,element_type_id
          ,input_value_id
          ,value
          ,multiple_entries_allowed_flag
   FROM  per_cagr_entitlement_results
   WHERE category_name = 'PAY'
     AND (p_params.assignment_id is not null and assignment_id = p_params.assignment_id)
     AND (chosen_flag = 'Y'
          OR (beneficial_flag = 'Y'
               and not exists (select 'X' from per_cagr_entitlement_results res1
                               where  res1.assignment_id = p_params.assignment_id
                               and res1.cagr_entitlement_item_id = cagr_entitlement_item_id
                               AND res1.chosen_flag = 'Y'
                               AND p_params.effective_date between start_date and nvl(end_date,hr_general.end_of_time))))
     AND element_type_id is not null
     AND input_value_id is not null
     AND p_params.effective_date between start_date and nvl(end_date,hr_general.end_of_time)
     ORDER BY element_type_id;


  l_ASG_results t_ASG_results;
  l_PYS_results t_PYS_results;
  l_PAY_results t_PAY_results;

  l_proc constant               VARCHAR2(80)    := g_pkg || 'do_apply_for_assignment';
  l_table_counter               NUMBER(15)      := 0;
  l_old_cagr_api_id             per_cagr_entitlement_items.cagr_api_id%TYPE := 0;
  l_old_element_type_id         per_cagr_entitlement_items.element_type_id%TYPE := 0;


  BEGIN

   hr_utility.set_location('Entering:'||l_proc, 5);

    if  p_params.category is null or p_params.category = 'ASG' then
       per_cagr_utility_pkg.put_log('  Starting ASSIGNMENT category items...',1);

     -- open cursor for ASG results for denormalisation, and collect pl/sql table
       for v_ASG_results in csr_ASG_denorm_results loop
         per_cagr_utility_pkg.put_log('  found result record for item: '||v_ASG_results.cagr_entitlement_item_id);

         if (l_old_cagr_api_id <> 0 and l_old_cagr_api_id <> v_ASG_results.cagr_api_id) then
           -- the cagr_api_id has changed so call_the relevant API to denormalise
           call_ASG_api(p_params,l_ASG_results);
           l_ASG_results.delete;
           l_table_counter := 0;
           l_old_cagr_api_id := v_ASG_results.cagr_api_id;
         end if;
         l_table_counter := l_table_counter+1;
         l_ASG_results(l_table_counter) := v_ASG_results;     -- assign csr_rec to table
         l_old_cagr_api_id := v_ASG_results.cagr_api_id;
       end loop;
       if l_table_counter <> 0 then
         -- pass any remaining records to denormalise pkg
         call_ASG_api(p_params,l_ASG_results);
         l_ASG_results.delete;
         l_table_counter := 0;
       end if;

       -- bug 2289200 reset variable to 0;
       l_old_cagr_api_id := 0;

       per_cagr_utility_pkg.put_log('  Completed ASSIGNMENT category items.',1);
       per_cagr_utility_pkg.put_log(' ');
    end if;

    if p_params.category is null or p_params.category = 'PYS' then
       per_cagr_utility_pkg.put_log('  Starting PAY SCALE category items...',1);

       for v_PYS_results in csr_PYS_denorm_results loop
         per_cagr_utility_pkg.put_log('  found result record for item: '||v_PYS_results.cagr_entitlement_item_id);

         if (l_old_cagr_api_id <> 0 and l_old_cagr_api_id <> v_PYS_results.cagr_api_id) then
           -- the cagr_api_id has changed so call_the relevant API to denormalise
           call_PYS_api(p_params,l_PYS_results);
           l_PYS_results.delete;
           l_table_counter := 0;
           l_old_cagr_api_id := v_PYS_results.cagr_api_id;
         end if;
         l_table_counter := l_table_counter+1;
         l_PYS_results(l_table_counter) := v_PYS_results;     -- assign csr_rec to table
         l_old_cagr_api_id := v_PYS_results.cagr_api_id;
       end loop;
       if l_table_counter <> 0 then
         -- pass any remaining records to denormalise pkg
         call_PYS_api(p_params,l_PYS_results);
         l_PYS_results.delete;
         l_table_counter := 0;
       end if;

       -- bug 2289200 reset variable to 0;
       l_old_cagr_api_id := 0;

       per_cagr_utility_pkg.put_log('  Completed PAY SCALE category items.',1);
       per_cagr_utility_pkg.put_log(' ');
    end if;

    if p_params.category is null or p_params.category = 'PAY' then
       per_cagr_utility_pkg.put_log('  Starting PAYROLL category items...',1);

       -- loop through all element results, populating pl/sql table with values
       -- and calling denormalise routine for each element type in the cursor.
       for v_PAY_results in csr_PAY_denorm_results loop
         per_cagr_utility_pkg.put_log('  found result record for item: '||v_PAY_results.cagr_entitlement_item_id);

         if (l_old_element_type_id <> 0 and l_old_element_type_id <> v_PAY_results.element_type_id) then
           -- the element_type has changed so call element entry API to denormalise
           -- entry values for the element_type
           if l_PAY_results.count > 15 then
             -- error as too many results for the update api call for the element
             per_cagr_utility_pkg.put_log('  ERROR: > 15 results for this element_type means data lost, skipping element');
           else
             call_PAY_api(p_params,l_PAY_results);
             l_PAY_results.delete;
             l_table_counter := 0;
             l_old_element_type_id := v_PAY_results.element_type_id;
           end if;
         end if;
         l_table_counter := l_table_counter+1;
         l_PAY_results(l_table_counter) := v_PAY_results;     -- assign csr_rec to table
         l_old_element_type_id := v_PAY_results.element_type_id;
       end loop;
       if l_table_counter <> 0 then
         -- pass any remaining records to denormalise pkg
         call_PAY_api(p_params,l_PAY_results);
         l_PAY_results.delete;
         l_table_counter := 0;
       end if;

       -- bug 2289200 reset variable to 0;
       l_old_cagr_api_id := 0;

       per_cagr_utility_pkg.put_log('  Completed PAYROLL category items.',1);
       per_cagr_utility_pkg.put_log(' ');
     end if;

    hr_utility.set_location('Leaving:'||l_proc, 100);


  EXCEPTION
   when others then
     -- write the log contents
     per_cagr_utility_pkg.write_log_file(p_params.cagr_request_id);
     raise;

  END do_apply_for_assignment;

 -- ================================================================================================
 -- ==     ****************                MAIN_BLOCK                *****************            ==
 -- ================================================================================================

 BEGIN

   hr_utility.set_location('Entering:'||l_proc, 5);
   --
   if not(g_done_header) then
     per_cagr_utility_pkg.put_log(per_cagr_evaluation_pkg.g_head_separator,1);
     per_cagr_utility_pkg.put_log('--------  Result Population Process Log ('||fnd_date.date_to_canonical(sysdate)||')  --------',1);
     per_cagr_utility_pkg.put_log(per_cagr_evaluation_pkg.g_head_separator,1);
     per_cagr_utility_pkg.put_log('Starting Result Population Process: ('
                                   ||fnd_date.date_to_canonical(sysdate)||')',1);

     If p_params.operation_mode = 'SA' then
       per_cagr_utility_pkg.put_log(' Mode: Single Assignment',1);
     elsif p_params.operation_mode = 'SC' then
       per_cagr_utility_pkg.put_log(' Mode: Single Collective Agreement',1);
     end if;

   /* redundant
     If p_select_flag = 'B' then
       per_cagr_utility_pkg.put_log(' Beneficial values to be applied.',1);
     elsif p_select_flag = 'C' then
       per_cagr_utility_pkg.put_log(' Chosen values to be applied.',1);
     end if;
   */
   end if;
   g_done_header := FALSE;
   --
   --
   if p_params.category is not null then
     if  p_params.category not in ('ASG','PAY','PYS','ABS') then
       per_cagr_utility_pkg.log_and_raise_error('HR_XXXXX_CAGR_INV_CATEGORY',p_params.cagr_request_id);
     end if;
   end if;


   if p_params.operation_mode = 'SA' then
   --
   --  ********* single assignment *********
   --

     per_cagr_utility_pkg.put_log(' ',1);
     per_cagr_utility_pkg.put_log(' Processing Assignment ID '|| p_params.assignment_id ||
                                  ' during Single Assignment Agreement mode.',1);
     do_apply_for_assignment(p_params, p_select_flag);

     --
     -- Commit, if required.
     --
     if p_params.commit_flag = 'Y' then
       per_cagr_utility_pkg.put_log(' Any changes have been saved.',1);
       commit;
     elsif p_params.commit_flag = 'N' then
       per_cagr_utility_pkg.put_log(' Any changes have been discarded.',1);
       rollback;
     end if;

   elsif p_params.operation_mode = 'SC' then
   --
   --  ********* single collective agreement *********
   --

     --  Applies any results found in cache for each asg on the cagr
     --  on the effective_date. Processing notes:
     --   1) Results are located, applied and committed for each asg in succession.
     --   2) if cagr_request_id is a parent_request_id then process was called from
     --      evaluation code directly, so we re-use that request id as the main
     --      request id for this run. Otherwise we use the request id created in
     --      intitilize (parameter) as the main request.
     --   3) for each asg, log entries are written under existing request ids (created
     --      when the results were evaluated, and are visible from PERWSCAR), but a
     --      file of combined parent request and asg denorm log entries is also
     --      created when we are running under CM.
     --
     per_cagr_utility_pkg.put_log(' Identified the following assignments on the collective agreement:',1);
     --
     -- first load all the assignment ids to be processed into pl/sql table.
     --
     open csr_assignments_to_process;
     loop
       l_counter := l_counter+1;
       fetch csr_assignments_to_process into t_assignment_list(l_counter);
       exit when csr_assignments_to_process%notfound;
       per_cagr_utility_pkg.put_log('  '||t_assignment_list(l_counter).assignment_id,1);
     end loop;
     close csr_assignments_to_process;


     -- write the log out and save the request_id
     per_cagr_utility_pkg.write_log_file(p_params.cagr_request_id);
     l_parent_request_id := p_params.cagr_request_id;

     -- could now break pl/sql table into varray subsets, ready for multiple threads

     -- loop through assignment_id table
     FOR k in t_assignment_list.first .. t_assignment_list.last LOOP
       Begin

        -- set asg and request, then call asg processing
        p_params.assignment_id := t_assignment_list(k).assignment_id;
        p_params.cagr_request_id := get_request_id(t_assignment_list(k).assignment_id
                                                  ,p_params.effective_date);

        per_cagr_utility_pkg.put_log(' ',1);
        per_cagr_utility_pkg.put_log(per_cagr_evaluation_pkg.g_head_separator,1);
        per_cagr_utility_pkg.put_log('--------  Result Population Process Log ('||fnd_date.date_to_canonical(sysdate)||')  --------',1);
        per_cagr_utility_pkg.put_log(per_cagr_evaluation_pkg.g_head_separator,1);

        per_cagr_utility_pkg.put_log(' Processing Assignment ID '|| p_params.assignment_id ||
                                     ' during Single Collective Agreement mode.',1);


        if p_params.cagr_request_id is null then
          -- there are no SA mode eval logs to update for this asg, so just use parent request id.
          p_params.cagr_request_id := l_parent_request_id;
        end if;

        do_apply_for_assignment(p_params, p_select_flag);

        --
        -- Commit, if required.
        --
        if p_params.commit_flag = 'Y' then
          per_cagr_utility_pkg.put_log(' Any changes have been saved.',1);
          commit;
        elsif p_params.commit_flag = 'N' then
          per_cagr_utility_pkg.put_log(' Any changes have been discarded.',1);
          rollback;
        end if;

        -- complete the logging for this asg
        per_cagr_utility_pkg.write_log_file(p_params.cagr_request_id);

       Exception
         when others then
           -- complete the logging for this asg
           per_cagr_utility_pkg.put_log('ERROR: '||sqlerrm);
           per_cagr_utility_pkg.write_log_file(p_params.cagr_request_id);
       End;
     END LOOP;

     -- restore the original request id, now all asgs have completed
     p_params.cagr_request_id := l_parent_request_id;

   else
     null;    -- do processing for other modes...
   end if;

   per_cagr_utility_pkg.put_log('Completed Result Population Process ('
                                ||fnd_date.date_to_canonical(sysdate)||')',1);
   per_cagr_utility_pkg.write_log_file(p_params.cagr_request_id);
   hr_utility.set_location('Leaving:'||l_proc, 100);


  EXCEPTION
   when others then
     -- write the log contents
     per_cagr_utility_pkg.write_log_file(p_params.cagr_request_id);
     raise;
  END initialise;

 --
 -- ------------------------------------------------------------------------------
 -- |-----------------------------< initialise >---------------------------------|
 -- ------------------------------------------------------------------------------
 --
 PROCEDURE initialise (p_process_date                 in    date
                      ,p_operation_mode               in    varchar2
                      ,p_business_group_id            in    number
                      ,p_assignment_id                in    number   default null
                      ,p_assignment_set_id            in    number   default null
                      ,p_category                     in    varchar2 default null
                      ,p_collective_agreement_id      in    number   default null
                      ,p_collective_agreement_set_id  in    number   default null
                      ,p_person_id                    in    number   default null
                      ,p_entitlement_item_id          in    number   default null
                      ,p_select_flag                  in    varchar2 default 'B'
                      ,p_commit_flag                  in    varchar2 default 'N'
                      ,p_cagr_request_id              in out nocopy   number) IS

  --   (individual parameter interface)
  --  This procedure is the main interface to the denormalization process, and is called
  --  directly by the concurrent manager and the form PERWSCAR.fmb to apply values to HRMS
  --  according to the control parameters supplied.
  --
  --  It calls PER_CAGR_DENORMALIZE_PKG.initialise (parameter interface) after
  --  validating individual parameters, populating the control record structure structure, creating
  --  a per_cagr_request record (if required) and initializing logging for the denormalisation run.
  --
  --  P_SELECT_FLAG IS NOW REDUNDANT - the beneficial flag result will be applied unless there is
  --  another result for the entitlement that has been chosen, in which case that will be applied.
  --  (old behaviour: process detects if it has been run from concurrent manager or from form and
  --  differs in behaviour as follows: If run from form, the form user has chosen a particular record
  --  (which may differ from the most beneficial) and so this process will trigger the result with
  --  chosen_flag = Y to be applied (ignoring beneficial_flag) for each item. If run from conc manager,
  --  of the set of results for each item in the cache the process will select the record with
  --  beneficial_flag = 'Y' (if any, and ignoring chosen_flag values) for application to HRMS)
  --

  l_proc constant varchar2(61) := g_pkg || 'initialise';
  l_params                        per_cagr_evaluation_pkg.control_structure;

BEGIN

  hr_utility.set_location('Entering:'||l_proc, 5);

  if p_cagr_request_id is null then
    --
    -- generate a new request for use in this run, if called from SRS or pl/sql module directly
    -- (if called from PERWSCAR.fmb or evaluation process we use the request_id
    -- that gave rise to the results which we are about to denormalise, so evaluation log records
    -- are appended with entitlement population process entries)
    --
    per_cagr_utility_pkg.create_cagr_request(p_process_date => p_process_date
                                            ,p_operation_mode => p_operation_mode
                                            ,p_business_group_id => p_business_group_id
                                            ,p_assignment_id => p_assignment_id
                                            ,p_assignment_set_id => p_assignment_set_id
                                            ,p_collective_agreement_id => p_collective_agreement_id
                                            ,p_collective_agreement_set_id => p_collective_agreement_set_id
                                            ,p_payroll_id  => NULL
                                            ,p_person_id => p_person_id
                                            ,p_entitlement_item_id => p_entitlement_item_id
                                            ,p_parent_request_id => NULL
                                            ,p_commit_flag => p_commit_flag
                                            ,p_denormalise_flag => 'Y'
                                            ,p_cagr_request_id => p_cagr_request_id);
  end if;


  --
  -- Ensure that all the mandatory arguments are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'process_date'
                            ,p_argument_value => p_process_date);
  hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'operation_mode'
                            ,p_argument_value => p_operation_mode);

  --
  -- Output denormalization log header
  --
  per_cagr_utility_pkg.put_log(per_cagr_evaluation_pkg.g_head_separator,1);
  per_cagr_utility_pkg.put_log('--------  Result Population Process Log ('||fnd_date.date_to_canonical(sysdate)||')  --------',1);
  per_cagr_utility_pkg.put_log(per_cagr_evaluation_pkg.g_head_separator,1);
  g_done_header := TRUE;

  --
  -- validate parameters
  --
  if not (p_commit_flag in ('N','Y')) then
    per_cagr_utility_pkg.log_and_raise_error('HR_289419_CAGR_INV_CFLAG'
                                            ,p_cagr_request_id);
  end if;

/* select_flag is redundant
  if not (p_select_flag in ('B','C')) then
    per_cagr_utility_pkg.log_and_raise_error('HR_XXXXX_CAGR_INV_SFLAG'
                                            ,p_cagr_request_id);
  end if;
*/

  if not(p_operation_mode in ('SA','SC')) then      -- just phase 1 denorm modes
    -- if not(p_operation_mode in ('SA','SE','SC','SP','BC','BA','BR')) then
    per_cagr_utility_pkg.log_and_raise_error('HR_289420_CAGR_INV_MODE'
                                            ,p_cagr_request_id);
  end if;

  if p_operation_mode = 'SA' and p_assignment_id is null then   -- SINGLE ASSIGNMENT
    per_cagr_utility_pkg.log_and_raise_error('HR_289421_CAGR_INV_SA_PARAM'
                                            ,p_cagr_request_id);
  end if;

  if p_operation_mode = 'SC'
     and (p_collective_agreement_id is null
         or p_assignment_id is not null
         or p_collective_agreement_set_id is not null) then   -- SINGLE CAGR
    per_cagr_utility_pkg.log_and_raise_error('HR_289597_INV_SC_PARAM'
                                            ,p_cagr_request_id);
  end if;

  --
  -- populate the record structure
  --
  l_params.effective_date := trunc(p_process_date);
  l_params.operation_mode := p_operation_mode;
  l_params.business_group_id := p_business_group_id;
  l_params.assignment_id := p_assignment_id;
  l_params.assignment_set_id := p_assignment_set_id;
  l_params.collective_agreement_id := p_collective_agreement_id;
  l_params.cagr_set_id := p_collective_agreement_set_id;
  l_params.cagr_request_id := p_cagr_request_id;
  l_params.person_id := p_person_id;
  l_params.category := p_category;
  l_params.entitlement_item_id := p_entitlement_item_id;
  l_params.commit_flag := p_commit_flag;
  l_params.denormalise_flag := 'Y';

  per_cagr_utility_pkg.put_log(' ',1);
  per_cagr_utility_pkg.put_log(' * Execution Parameter List * ',1);
  per_cagr_utility_pkg.put_log(' ',1);
  per_cagr_utility_pkg.put_log(' Mode: '||l_params.operation_mode,1);
  per_cagr_utility_pkg.put_log(' CAGR Request ID: '||l_params.cagr_request_id,1);
  per_cagr_utility_pkg.put_log(' Effective Date: '||l_params.effective_date,1);
  per_cagr_utility_pkg.put_log(' Business Group ID: '||l_params.business_group_id,1);
  per_cagr_utility_pkg.put_log(' Assignment ID: '||l_params.assignment_id,1);
  per_cagr_utility_pkg.put_log(' Assignment Set ID: '||l_params.assignment_set_id,1);
  per_cagr_utility_pkg.put_log(' Collective Agreement ID: '||l_params.collective_agreement_id,1);
  per_cagr_utility_pkg.put_log(' Collective Agreement Set ID: '||l_params.cagr_set_id,1);
  per_cagr_utility_pkg.put_log(' Person ID: '||l_params.person_id,1);
  per_cagr_utility_pkg.put_log(' Entitlement Item ID: '||l_params.entitlement_item_id,1);
  per_cagr_utility_pkg.put_log(' Category: '||l_params.category,1);

  /* redundant now chosen values are stored after refresh
  If p_select_flag = 'B' then
    per_cagr_utility_pkg.put_log(' Beneficial values to be applied.',1);
  elsif p_select_flag = 'C' then
    per_cagr_utility_pkg.put_log(' Chosen values to be applied.',1);
  end if;
  */

  per_cagr_utility_pkg.put_log(' Commit values flag: '||l_params.commit_flag,1);
  per_cagr_utility_pkg.put_log(' ',1);

  --
  -- ****** This needs to be converted to a parameter passed to create_request,
  -- rather than relying on a public package variable *******
  --
  if fnd_global.conc_request_id <> -1 then
    per_cagr_utility_pkg.put_log(' Executed from concurrent manager');
  else
    per_cagr_utility_pkg.put_log(' Executed from SQLPLUS session');
  end if;
  per_cagr_utility_pkg.put_log(' ',1);
  per_cagr_utility_pkg.write_log_file(l_params.cagr_request_id);

  --
  -- invoke denormalization processing;
  --
  initialise (p_params => l_params
             ,p_select_flag => p_select_flag);

  -- complete logging
  per_cagr_utility_pkg.put_log(per_cagr_evaluation_pkg.g_separator,1);
  per_cagr_utility_pkg.write_log_file(l_params.cagr_request_id);

  hr_utility.set_location('Leaving:'||l_proc, 50);

END;

END per_cagr_apply_results_pkg;

/
