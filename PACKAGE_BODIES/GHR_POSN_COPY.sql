--------------------------------------------------------
--  DDL for Package Body GHR_POSN_COPY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_POSN_COPY" AS
/* $Header: ghrposcp.pkb 120.0 2005/05/29 03:37:07 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'ghr_posn_copy.';
--
--

FUNCTION get_seq_location (p_business_group_id  IN NUMBER)
  RETURN VARCHAR2 IS
--
l_proc                 varchar2(72) := g_package||'get_seq_location';
--

CURSOR c_ori IS
  SELECT ori.org_information4 seq_location
  FROM   hr_organization_information ori
  WHERE  ori.organization_id = p_business_group_id
  AND    ori.org_information_context = 'GHR_US_ORG_INFORMATION';
--
BEGIN
  hr_utility.set_location('Entering get_seq_loation:'|| l_proc, 5);

  FOR c_ori_rec IN c_ori LOOP
    RETURN (c_ori_rec.seq_location);
  END LOOP;
  RETURN(NULL);
END get_seq_location;
--
--
------------------------------------------------------------------
FUNCTION get_max_seq (p_seq_location IN VARCHAR2
                      ,p_business_group_id  IN NUMBER
                      ,p_segment1     IN VARCHAR2
                      ,p_segment2     IN VARCHAR2
                      ,p_segment3     IN VARCHAR2
                      ,p_segment4     IN VARCHAR2
                      ,p_segment5     IN VARCHAR2
                      ,p_segment6     IN VARCHAR2
                      ,p_segment7     IN VARCHAR2
                      ,p_segment8     IN VARCHAR2
                      ,p_segment9     IN VARCHAR2
                      ,p_segment10    IN VARCHAR2
                      ,p_segment11    IN VARCHAR2
                      ,p_segment12    IN VARCHAR2
                      ,p_segment13    IN VARCHAR2
                      ,p_segment14    IN VARCHAR2
                      ,p_segment15    IN VARCHAR2
                      ,p_segment16    IN VARCHAR2
                      ,p_segment17    IN VARCHAR2
                      ,p_segment18    IN VARCHAR2
                      ,p_segment19    IN VARCHAR2
                      ,p_segment20    IN VARCHAR2
                      ,p_segment21    IN VARCHAR2
                      ,p_segment22    IN VARCHAR2
                      ,p_segment23    IN VARCHAR2
                      ,p_segment24    IN VARCHAR2
                      ,p_segment25    IN VARCHAR2
                      ,p_segment26    IN VARCHAR2
                      ,p_segment27    IN VARCHAR2
                      ,p_segment28    IN VARCHAR2
                      ,p_segment29    IN VARCHAR2
                      ,p_segment30    IN VARCHAR2)
RETURN VARCHAR2 IS
l_cur                  INTEGER;
l_stmt                 VARCHAR2(2000);
l_fetch_rows           INTEGER;
l_seq_loc              INTEGER;
l_max_seq              VARCHAR2(150);
l_id_flex_num          fnd_id_flex_structures.id_flex_num%type;
l_proc                 varchar2(72) := g_package||'get_max_seq';

--
cursor cur_org_id_flex_num is
select position_structure id_flex_num
from per_business_groups
where business_group_id = p_business_group_id;
--

BEGIN

  hr_utility.set_location('Entering Get Max Seq:'|| l_proc, 5);

  FOR cur_org_id_flex_num_rec IN cur_org_id_flex_num LOOP
      l_id_flex_num := cur_org_id_flex_num_rec.id_flex_num;
  END LOOP;


-- Build Dynamic Sql statment which locates all Position KFFs with the same
-- seqment values (excluding sequence) and returns the highest sequence found +1.

  l_cur := dbms_sql.open_cursor;
  l_stmt := 'SELECT MAX(TO_NUMBER('||p_seq_location||'))  max_seq '||
            'FROM   per_position_definitions pde WHERE id_flex_num= '||l_id_flex_num;
  --
  l_seq_loc := SUBSTR(p_seq_location,8);

  --

  FOR i IN 1..30 LOOP
    IF l_seq_loc <>  i THEN
      IF i = 1 and p_segment1 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||replace(p_segment1,'''','''''')||'''';
      ELSIF i = 2 and p_segment2 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||replace(p_segment2,'''','''''')||'''';
      ELSIF i = 3 and p_segment3 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||replace(p_segment3,'''','''''')||'''';
      ELSIF i = 4 and p_segment4 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||replace(p_segment4,'''','''''')||'''';
      ELSIF i = 5 and p_segment5 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||replace(p_segment5,'''','''''')||'''';
      ELSIF i = 6 and p_segment6 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||replace(p_segment6,'''','''''')||'''';
      ELSIF i = 7 and p_segment7 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||replace(p_segment7,'''','''''')||'''';
      ELSIF i = 8 and p_segment8 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||replace(p_segment8,'''','''''')||'''';
      ELSIF i = 9 and p_segment9 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||replace(p_segment9,'''','''''')||'''';
      ELSIF i = 10 and p_segment10 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||replace(p_segment10,'''','''''')||'''';
      ELSIF i = 11 and p_segment11 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||replace(p_segment11,'''','''''')||'''';
      ELSIF i = 12 and p_segment12 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||replace(p_segment12,'''','''''')||'''';
      ELSIF i = 13 and p_segment13 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||replace(p_segment13,'''','''''')||'''';
      ELSIF i = 14 and p_segment14 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||replace(p_segment14,'''','''''')||'''';
      ELSIF i = 15 and p_segment15 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||replace(p_segment15,'''','''''')||'''';
      ELSIF i = 16 and p_segment16 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||replace(p_segment16,'''','''''')||'''';
      ELSIF i = 17 and p_segment17 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||replace(p_segment17,'''','''''')||'''';
      ELSIF i = 18 and p_segment18 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||replace(p_segment18,'''','''''')||'''';
      ELSIF i = 19 and p_segment19 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||replace(p_segment19,'''','''''')||'''';
      ELSIF i = 20 and p_segment20 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||replace(p_segment20,'''','''''')||'''';
      ELSIF i = 21 and p_segment21 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||replace(p_segment21,'''','''''')||'''';
      ELSIF i = 22 and p_segment22 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||replace(p_segment22,'''','''''')||'''';
      ELSIF i = 23 and p_segment23 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||replace(p_segment23,'''','''''')||'''';
      ELSIF i = 24 and p_segment24 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||replace(p_segment24,'''','''''')||'''';
      ELSIF i = 25 and p_segment25 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||replace(p_segment25,'''','''''')||'''';
      ELSIF i = 26 and p_segment26 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||replace(p_segment26,'''','''''')||'''';
      ELSIF i = 27 and p_segment27 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||replace(p_segment27,'''','''''')||'''';
      ELSIF i = 28 and p_segment28 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||replace(p_segment28,'''','''''')||'''';
      ELSIF i = 29 and p_segment29 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||replace(p_segment29,'''','''''')||'''';
      ELSIF i = 30 and p_segment30 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||replace(p_segment30,'''','''''')||'''';
      END IF;
    END IF;
  END LOOP;
  l_stmt := l_stmt||' AND EXISTS (SELECT 1 FROM per_positions pos'
                  ||' WHERE pde.position_definition_id = pos.position_definition_id)';

--
-- dbms_sql.parse format (number, statement , language_flag)
  dbms_sql.parse(l_cur, l_stmt, DBMS_SQL.NATIVE);
  dbms_sql.define_column(l_cur, 1, l_max_seq,150);
  l_fetch_rows := dbms_sql.execute(l_cur);
  l_fetch_rows := dbms_sql.fetch_rows(l_cur);
  dbms_sql.column_value(l_cur, 1, l_max_seq);
  dbms_sql.close_cursor(l_cur);
--

/*
dbms_output.put_line(substr(l_stmt,1,100));
dbms_output.put_line(substr(l_stmt,101,100));
dbms_output.put_line(substr(l_stmt,201,100));
dbms_output.put_line('l_cur: '||l_cur);
dbms_output.put_line('DBMS_SQL: '||DBMS_SQL.NATIVE);
*/

  --
    RETURN(l_max_seq);
  --

END get_max_seq;
--
/*
     This procedure will accept all data needed to create a position.
     Incoming Parameters will match the core H.R. date tracked API (PQH).
     The sequence number segment of the KFF will be determined and populated
     per requirement doc.  Then the position will be created using GHR wrappers
     to create the position with history.
     Do we need to use GHR wrappers?
     This procedure will also create all child data required per design doc.
*/

Procedure create_position_copy
  (p_position_id                    in out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_position_definition_id         out nocopy number
  ,p_name                           out nocopy varchar2
  ,p_object_version_number          out nocopy number
  ,p_job_id                         in  number
  ,p_organization_id                in  number
  ,p_effective_date                 in  date
  ,p_date_effective                 in  date
  ,p_validate                       in  boolean   default false
  ,p_availability_status_id         in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_entry_step_id                  in  number    default null
  ,p_entry_grade_rule_id            in  number    default null
  ,p_location_id                    in  number    default null
  ,p_pay_freq_payroll_id            in  number    default null
  ,p_position_transaction_id        in  number    default null
  ,p_prior_position_id              in  number    default null
  ,p_relief_position_id             in  number    default null
  ,p_entry_grade_id                 in  number    default null
  ,p_successor_position_id          in  number    default null
  ,p_supervisor_position_id         in  number    default null
  ,p_amendment_date                 in  date      default null
  ,p_amendment_recommendation       in  varchar2  default null
  ,p_amendment_ref_number           in  varchar2  default null
  ,p_bargaining_unit_cd             in  varchar2  default null
  ,p_comments                       in  long      default null
  ,p_current_job_prop_end_date      in  date      default null
  ,p_current_org_prop_end_date      in  date      default null
  ,p_avail_status_prop_end_date     in  date      default null
  ,p_date_end                       in  date      default null
  ,p_earliest_hire_date             in  date      default null
  ,p_fill_by_date                   in  date      default null
  ,p_frequency                      in  varchar2  default null
  ,p_fte                            in  number    default null
  ,p_max_persons                    in  number    default null
  ,p_overlap_period                 in  number    default null
  ,p_overlap_unit_cd                in  varchar2  default null
  ,p_pay_term_end_day_cd            in  varchar2  default null
  ,p_pay_term_end_month_cd          in  varchar2  default null
  ,p_permanent_temporary_flag       in  varchar2  default null
  ,p_permit_recruitment_flag        in  varchar2  default null
  ,p_position_type                  in  varchar2  default 'NONE'
  ,p_posting_description            in  varchar2  default null
  ,p_probation_period               in  number    default null
  ,p_probation_period_unit_cd       in  varchar2  default null
  ,p_replacement_required_flag      in  varchar2  default null
  ,p_review_flag                    in  varchar2  default null
  ,p_seasonal_flag                  in  varchar2  default null
  ,p_security_requirements          in  varchar2  default null
  ,p_status                         in  varchar2  default null
  ,p_term_start_day_cd              in  varchar2  default null
  ,p_term_start_month_cd            in  varchar2  default null
  ,p_time_normal_finish             in  varchar2  default null
  ,p_time_normal_start              in  varchar2  default null
  ,p_update_source_cd               in  varchar2  default null
  ,p_working_hours                  in  number    default null
  ,p_works_council_approval_flag    in  varchar2  default null
  ,p_work_period_type_cd            in  varchar2  default null
  ,p_work_term_end_day_cd           in  varchar2  default null
  ,p_work_term_end_month_cd         in  varchar2  default null
  ,p_proposed_fte_for_layoff        in  number    default null
  ,p_proposed_date_for_layoff       in  date      default null
  ,p_pay_basis_id                   in  number    default null
  ,p_supervisor_id                  in  number    default null
  ,p_information1                   in  varchar2  default null
  ,p_information2                   in  varchar2  default null
  ,p_information3                   in  varchar2  default null
  ,p_information4                   in  varchar2  default null
  ,p_information5                   in  varchar2  default null
  ,p_information6                   in  varchar2  default null
  ,p_information7                   in  varchar2  default null
  ,p_information8                   in  varchar2  default null
  ,p_information9                   in  varchar2  default null
  ,p_information10                  in  varchar2  default null
  ,p_information11                  in  varchar2  default null
  ,p_information12                  in  varchar2  default null
  ,p_information13                  in  varchar2  default null
  ,p_information14                  in  varchar2  default null
  ,p_information15                  in  varchar2  default null
  ,p_information16                  in  varchar2  default null
  ,p_information17                  in  varchar2  default null
  ,p_information18                  in  varchar2  default null
  ,p_information19                  in  varchar2  default null
  ,p_information20                  in  varchar2  default null
  ,p_information21                  in  varchar2  default null
  ,p_information22                  in  varchar2  default null
  ,p_information23                  in  varchar2  default null
  ,p_information24                  in  varchar2  default null
  ,p_information25                  in  varchar2  default null
  ,p_information26                  in  varchar2  default null
  ,p_information27                  in  varchar2  default null
  ,p_information28                  in  varchar2  default null
  ,p_information29                  in  varchar2  default null
  ,p_information30                  in  varchar2  default null
  ,p_information_category           in  varchar2  default null
  ,p_attribute1                     in  varchar2  default null
  ,p_attribute2                     in  varchar2  default null
  ,p_attribute3                     in  varchar2  default null
  ,p_attribute4                     in  varchar2  default null
  ,p_attribute5                     in  varchar2  default null
  ,p_attribute6                     in  varchar2  default null
  ,p_attribute7                     in  varchar2  default null
  ,p_attribute8                     in  varchar2  default null
  ,p_attribute9                     in  varchar2  default null
  ,p_attribute10                    in  varchar2  default null
  ,p_attribute11                    in  varchar2  default null
  ,p_attribute12                    in  varchar2  default null
  ,p_attribute13                    in  varchar2  default null
  ,p_attribute14                    in  varchar2  default null
  ,p_attribute15                    in  varchar2  default null
  ,p_attribute16                    in  varchar2  default null
  ,p_attribute17                    in  varchar2  default null
  ,p_attribute18                    in  varchar2  default null
  ,p_attribute19                    in  varchar2  default null
  ,p_attribute20                    in  varchar2  default null
  ,p_attribute21                    in  varchar2  default null
  ,p_attribute22                    in  varchar2  default null
  ,p_attribute23                    in  varchar2  default null
  ,p_attribute24                    in  varchar2  default null
  ,p_attribute25                    in  varchar2  default null
  ,p_attribute26                    in  varchar2  default null
  ,p_attribute27                    in  varchar2  default null
  ,p_attribute28                    in  varchar2  default null
  ,p_attribute29                    in  varchar2  default null
  ,p_attribute30                    in  varchar2  default null
  ,p_attribute_category             in  varchar2  default null
  ,p_segment1                       in  varchar2  default null
  ,p_segment2                       in  varchar2  default null
  ,p_segment3                       in  varchar2  default null
  ,p_segment4                       in  varchar2  default null
  ,p_segment5                       in  varchar2  default null
  ,p_segment6                       in  varchar2  default null
  ,p_segment7                       in  varchar2  default null
  ,p_segment8                       in  varchar2  default null
  ,p_segment9                       in  varchar2  default null
  ,p_segment10                      in  varchar2  default null
  ,p_segment11                      in  varchar2  default null
  ,p_segment12                      in  varchar2  default null
  ,p_segment13                      in  varchar2  default null
  ,p_segment14                      in  varchar2  default null
  ,p_segment15                      in  varchar2  default null
  ,p_segment16                      in  varchar2  default null
  ,p_segment17                      in  varchar2  default null
  ,p_segment18                      in  varchar2  default null
  ,p_segment19                      in  varchar2  default null
  ,p_segment20                      in  varchar2  default null
  ,p_segment21                      in  varchar2  default null
  ,p_segment22                      in  varchar2  default null
  ,p_segment23                      in  varchar2  default null
  ,p_segment24                      in  varchar2  default null
  ,p_segment25                      in  varchar2  default null
  ,p_segment26                      in  varchar2  default null
  ,p_segment27                      in  varchar2  default null
  ,p_segment28                      in  varchar2  default null
  ,p_segment29                      in  varchar2  default null
  ,p_segment30                      in  varchar2  default null
  ,p_concat_segments                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ) is

  --
  -- Declare cursors and local variables
  --
  l_position_id                    number;
  l_effective_start_date           date;
  l_effective_end_date             date;
  l_position_definition_id         number;
  l_name                           varchar2(2000);
  l_object_version_number          number;
  l_pos_data         per_positions%rowtype;
  l_result_code      VARCHAR2(30);
  l_pde_data         per_position_definitions%rowtype;
  l_dummy_number     NUMBER;
  l_new_pos_id       per_positions.position_id%TYPE;
  l_new_pos_name     per_positions.name%TYPE;
  l_seq_segment_name VARCHAR2(30);
  l_new_seq          VARCHAR2(150);
  l_agency_seq       VARCHAR2(150);
  l_ovn              NUMBER;
  l_seq_len          number(25);
  l_seq_val          VARCHAR2(250);
  l_proc             varchar2(72) := g_package||'create_position_copy';
  l_concat_segments  varchar2(250);
  l_del              varchar2(1) default '.';
  l_source_posn_id   number(25) default p_position_id;
  l_session_date     date;

  l_segment1         varchar2(250);
  l_segment2         varchar2(250);
  l_segment3         varchar2(250);
  l_segment4         varchar2(250);
  l_segment5         varchar2(250);
  l_segment6         varchar2(250);
  l_segment7         varchar2(250);
  l_segment8         varchar2(250);
  l_segment9         varchar2(250);
  l_segment10        varchar2(250);
  l_segment11        varchar2(250);
  l_segment12        varchar2(250);
  l_segment13        varchar2(250);
  l_segment14        varchar2(250);
  l_segment15        varchar2(250);
  l_segment16        varchar2(250);
  l_segment17        varchar2(250);
  l_segment18        varchar2(250);
  l_segment19        varchar2(250);
  l_segment20        varchar2(250);
  l_segment21        varchar2(250);
  l_segment22        varchar2(250);
  l_segment23        varchar2(250);
  l_segment24        varchar2(250);
  l_segment25        varchar2(250);
  l_segment26        varchar2(250);
  l_segment27        varchar2(250);
  l_segment28        varchar2(250);
  l_segment29        varchar2(250);
  l_segment30        varchar2(250);
--
  CURSOR c_session_date IS
    select EFFECTIVE_DATE
    from fnd_sessions where session_id = userenv('sessionid');
--

BEGIN

FOR c_session_date_rec IN c_session_date LOOP
  l_session_date := (c_session_date_rec.effective_date);
END LOOP;

 hr_utility.set_location('Entering Copy:'|| l_proc, 5);
 hr_utility.set_location('Effective Date:'|| p_effective_date, 6);
 hr_utility.set_location('Date Effective:'|| p_date_effective, 7);
 hr_utility.set_location('Session Date:'|| l_session_date, 8);
 hr_utility.set_location('BG ID:'|| p_business_group_id, 9);
 hr_utility.set_location('Position id '||to_char(p_position_id),10);

 --
 l_seq_segment_name := ghr_posn_copy.get_seq_location(p_business_group_id);

 -- Set Locals to parameter values before overriding sequence segment for copy
 l_segment1  := p_segment1;
 l_segment2  := p_segment2;
 l_segment3  := p_segment3;
 l_segment4  := p_segment4;
 l_segment5  := p_segment5;
 l_segment6  := p_segment6;
 l_segment7  := p_segment7;
 l_segment8  := p_segment8;
 l_segment9  := p_segment9;
 l_segment10 := p_segment10;
 l_segment11 := p_segment11;
 l_segment12 := p_segment12;
 l_segment13 := p_segment13;
 l_segment14 := p_segment14;
 l_segment15 := p_segment15;
 l_segment16 := p_segment16;
 l_segment17 := p_segment17;
 l_segment18 := p_segment18;
 l_segment19 := p_segment19;
 l_segment20 := p_segment20;
 l_segment21 := p_segment21;
 l_segment22 := p_segment22;
 l_segment23 := p_segment23;
 l_segment24 := p_segment24;
 l_segment25 := p_segment25;
 l_segment26 := p_segment26;
 l_segment27 := p_segment27;
 l_segment28 := p_segment28;
 l_segment29 := p_segment29;
 l_segment30 := p_segment30;

hr_utility.set_location('l_segment1  :'||l_segment1, 9);
hr_utility.set_location('l_segment2  :'||l_segment2, 9);
hr_utility.set_location('l_segment3  :'||l_segment3, 9);
hr_utility.set_location('l_segment4  :'||l_segment4, 9);

 --
 -- Get Agency Specified Max Seq
 --
 hr_utility.set_location('Calling Agency Get Max:'|| l_proc, 10);
 l_agency_seq := ghr_agency_position_copy.agency_get_max_seq(
                       l_seq_segment_name,
                       p_business_group_id,
                       p_segment1,
                       p_segment2,
                       p_segment3,
                       p_segment4,
                       p_segment5,
                       p_segment6,
                       p_segment7,
                       p_segment8,
                       p_segment9,
                       p_segment10,
                       p_segment11,
                       p_segment12,
                       p_segment13,
                       p_segment14,
                       p_segment15,
                       p_segment16,
                       p_segment17,
                       p_segment18,
                       p_segment19,
                       p_segment20,
                       p_segment21,
                       p_segment22,
                       p_segment23,
                       p_segment24,
                       p_segment25,
                       p_segment26,
                       p_segment27,
                       p_segment28,
                       p_segment29,
                       p_segment30);

hr_utility.set_location('Agency Get Max ='|| l_agency_seq, 11);


  -- Agency get should return sequence value to be used for copy.
  -- This value will not be incremented by 1.  So a nextval will work.

 hr_utility.set_location('Calling GHR get max seq:'|| l_proc, 12);
  -- If Agency_get_max returns null then call GHR function

  If l_agency_seq is null then

    hr_utility.set_location('l_agency_seq is null'|| l_proc, 13);
    hr_utility.set_location('Calling GHR Get Max'|| l_proc, 14);

    l_new_seq  := ghr_posn_copy.get_max_seq(
                       l_seq_segment_name,
                       p_business_group_id,
                       p_segment1,
                       p_segment2,
                       p_segment3,
                       p_segment4,
                       p_segment5,
                       p_segment6,
                       p_segment7,
                       p_segment8,
                       p_segment9,
                       p_segment10,
                       p_segment11,
                       p_segment12,
                       p_segment13,
                       p_segment14,
                       p_segment15,
                       p_segment16,
                       p_segment17,
                       p_segment18,
                       p_segment19,
                       p_segment20,
                       p_segment21,
                       p_segment22,
                       p_segment23,
                       p_segment24,
                       p_segment25,
                       p_segment26,
                       p_segment27,
                       p_segment28,
                       p_segment29,
                       p_segment30);

     hr_utility.set_location('GHR Get Max = '|| l_new_seq, 15);

     -- Add 1 to current max sequence returned if not null.
     IF l_new_seq IS NULL THEN
        l_new_seq := 1;
     ELSE
        l_new_seq := to_char(to_number(l_new_seq) + 1);
     END IF;

     -- Logic for Padding Zeroes to the New Position Sequence Number
     -- Get the Sequence Number of Source position using the
     -- function ghr_api.get_position_sequence_no_pos.
     -- Find the length of source position's sequence Number.
     -- Pad the new sequence to that length.

     l_seq_val :=  ghr_api.get_position_sequence_no_pos
	           ( p_position_id        => p_position_id
	            ,p_business_group_id  => p_business_group_id
                    ,p_effective_date     => l_session_date
                   );
     l_seq_len := length(l_seq_val);
     --
     -- Sequence length passed into copy will be used
     -- to determine length of sequence created.
     --
     -- Added if statments if length(l_new_seq) < l_seq_len for bug#2635850.

     IF l_seq_segment_name = 'SEGMENT1' THEN
       --l_seq_len := length(l_segment1);
       IF length(l_new_seq) < l_seq_len THEN
	 l_segment1 := lpad(l_new_seq,l_seq_len,0);
       ELSE
	 l_segment1 := l_new_seq;
       END IF;
     ELSIF l_seq_segment_name = 'SEGMENT2' THEN
       --l_seq_len := length(l_segment2);
       IF length(l_new_seq) < l_seq_len THEN
	 l_segment2 := lpad(l_new_seq,l_seq_len,0);
       ELSE
	 l_segment2 := l_new_seq;
       END IF;
     ELSIF l_seq_segment_name = 'SEGMENT3' THEN
       --l_seq_len := length(l_segment3);
       IF length(l_new_seq) < l_seq_len THEN
	 l_segment3 := lpad(l_new_seq,l_seq_len,0);
       ELSE
	 l_segment3 := l_new_seq;
       END IF;
     ELSIF l_seq_segment_name = 'SEGMENT4' THEN
       --l_seq_len := length(l_segment4);
       IF length(l_new_seq) < l_seq_len THEN
	 l_segment4 := lpad(l_new_seq,l_seq_len,0);
       ELSE
	 l_segment4 := l_new_seq;
       END IF;
     ELSIF l_seq_segment_name = 'SEGMENT5' THEN
       --l_seq_len := length(l_segment5);
       IF length(l_new_seq) < l_seq_len THEN
	 l_segment5 := lpad(l_new_seq,l_seq_len,0);
       ELSE
	 l_segment5 := l_new_seq;
       END IF;
     ELSIF l_seq_segment_name = 'SEGMENT6' THEN
       --l_seq_len := length(l_segment6);
       IF length(l_new_seq) < l_seq_len THEN
	 l_segment6 := lpad(l_new_seq,l_seq_len,0);
       ELSE
	 l_segment6 := l_new_seq;
       END IF;
     ELSIF l_seq_segment_name = 'SEGMENT7' THEN
       --l_seq_len := length(l_segment7);
       IF length(l_new_seq) < l_seq_len THEN
	 l_segment7 := lpad(l_new_seq,l_seq_len,0);
       ELSE
	 l_segment7 := l_new_seq;
       END IF;
     ELSIF l_seq_segment_name = 'SEGMENT8' THEN
       --l_seq_len := length(l_segment8);
       IF length(l_new_seq) < l_seq_len THEN
	 l_segment8 := lpad(l_new_seq,l_seq_len,0);
       ELSE
	 l_segment8 := l_new_seq;
       END IF;
     ELSIF l_seq_segment_name = 'SEGMENT9' THEN
       --l_seq_len := length(l_segment9);
       IF length(l_new_seq) < l_seq_len THEN
	 l_segment9 := lpad(l_new_seq,l_seq_len,0);
       ELSE
	 l_segment9 := l_new_seq;
       END IF;
     ELSIF l_seq_segment_name = 'SEGMENT10' THEN
       --l_seq_len := length(l_segment10);
       IF length(l_new_seq) < l_seq_len THEN
	 l_segment10 := lpad(l_new_seq,l_seq_len,0);
       ELSE
	 l_segment10 := l_new_seq;
       END IF;
     ELSIF l_seq_segment_name = 'SEGMENT11' THEN
       --l_seq_len := length(l_segment11);
       IF length(l_new_seq) < l_seq_len THEN
	 l_segment11 := lpad(l_new_seq,l_seq_len,0);
       ELSE
	 l_segment11 := l_new_seq;
       END IF;
     ELSIF l_seq_segment_name = 'SEGMENT12' THEN
       --l_seq_len := length(l_segment12);
       IF length(l_new_seq) < l_seq_len THEN
	 l_segment12 := lpad(l_new_seq,l_seq_len,0);
       ELSE
	 l_segment12 := l_new_seq;
       END IF;
     ELSIF l_seq_segment_name = 'SEGMENT13' THEN
       --l_seq_len := length(l_segment13);
       IF length(l_new_seq) < l_seq_len THEN
	 l_segment13 := lpad(l_new_seq,l_seq_len,0);
       ELSE
	 l_segment13 := l_new_seq;
       END IF;
     ELSIF l_seq_segment_name = 'SEGMENT14' THEN
       --l_seq_len := length(l_segment14);
       IF length(l_new_seq) < l_seq_len THEN
	 l_segment14 := lpad(l_new_seq,l_seq_len,0);
       ELSE
	 l_segment14 := l_new_seq;
       END IF;
     ELSIF l_seq_segment_name = 'SEGMENT15' THEN
       --l_seq_len := length(l_segment15);
       IF length(l_new_seq) < l_seq_len THEN
	 l_segment15 := lpad(l_new_seq,l_seq_len,0);
       ELSE
	 l_segment15 := l_new_seq;
       END IF;
     ELSIF l_seq_segment_name = 'SEGMENT16' THEN
       --l_seq_len := length(l_segment16);
       IF length(l_new_seq) < l_seq_len THEN
	 l_segment16 := lpad(l_new_seq,l_seq_len,0);
       ELSE
	 l_segment16 := l_new_seq;
       END IF;
     ELSIF l_seq_segment_name = 'SEGMENT17' THEN
       --l_seq_len := length(l_segment17);
       IF length(l_new_seq) < l_seq_len THEN
	 l_segment17 := lpad(l_new_seq,l_seq_len,0);
       ELSE
	 l_segment17 := l_new_seq;
       END IF;
     ELSIF l_seq_segment_name = 'SEGMENT18' THEN
       --l_seq_len := length(l_segment18);
       IF length(l_new_seq) < l_seq_len THEN
	 l_segment18 := lpad(l_new_seq,l_seq_len,0);
       ELSE
	 l_segment18 := l_new_seq;
       END IF;
     ELSIF l_seq_segment_name = 'SEGMENT19' THEN
       --l_seq_len := length(l_segment19);
       IF length(l_new_seq) < l_seq_len THEN
	 l_segment19 := lpad(l_new_seq,l_seq_len,0);
       ELSE
	 l_segment19 := l_new_seq;
       END IF;
     ELSIF l_seq_segment_name = 'SEGMENT20' THEN
       --l_seq_len := length(l_segment20);
       IF length(l_new_seq) < l_seq_len THEN
	 l_segment20 := lpad(l_new_seq,l_seq_len,0);
       ELSE
	 l_segment20 := l_new_seq;
       END IF;
     ELSIF l_seq_segment_name = 'SEGMENT21' THEN
       --l_seq_len := length(l_segment21);
       IF length(l_new_seq) < l_seq_len THEN
	 l_segment21 := lpad(l_new_seq,l_seq_len,0);
       ELSE
	 l_segment21 := l_new_seq;
       END IF;
     ELSIF l_seq_segment_name = 'SEGMENT22' THEN
       --l_seq_len := length(l_segment22);
       IF length(l_new_seq) < l_seq_len THEN
	 l_segment22 := lpad(l_new_seq,l_seq_len,0);
       ELSE
	 l_segment22 := l_new_seq;
       END IF;
     ELSIF l_seq_segment_name = 'SEGMENT23' THEN
       --l_seq_len := length(l_segment23);
       IF length(l_new_seq) < l_seq_len THEN
	 l_segment23 := lpad(l_new_seq,l_seq_len,0);
       ELSE
	 l_segment23 := l_new_seq;
       END IF;
     ELSIF l_seq_segment_name = 'SEGMENT24' THEN
       --l_seq_len := length(l_segment24);
       IF length(l_new_seq) < l_seq_len THEN
	 l_segment24 := lpad(l_new_seq,l_seq_len,0);
       ELSE
	 l_segment24 := l_new_seq;
       END IF;
     ELSIF l_seq_segment_name = 'SEGMENT25' THEN
       --l_seq_len := length(l_segment25);
       IF length(l_new_seq) < l_seq_len THEN
	 l_segment25 := lpad(l_new_seq,l_seq_len,0);
       ELSE
	 l_segment25 := l_new_seq;
       END IF;
     ELSIF l_seq_segment_name = 'SEGMENT26' THEN
       --l_seq_len := length(l_segment26);
       IF length(l_new_seq) < l_seq_len THEN
	 l_segment26 := lpad(l_new_seq,l_seq_len,0);
       ELSE
	 l_segment26 := l_new_seq;
       END IF;
     ELSIF l_seq_segment_name = 'SEGMENT27' THEN
       --l_seq_len := length(l_segment27);
       IF length(l_new_seq) < l_seq_len THEN
	 l_segment27 := lpad(l_new_seq,l_seq_len,0);
       ELSE
	 l_segment27 := l_new_seq;
       END IF;
     ELSIF l_seq_segment_name = 'SEGMENT28' THEN
       --l_seq_len := length(l_segment28);
       IF length(l_new_seq) < l_seq_len THEN
	 l_segment28 := lpad(l_new_seq,l_seq_len,0);
       ELSE
	 l_segment28 := l_new_seq;
       END IF;
     ELSIF l_seq_segment_name = 'SEGMENT29' THEN
       --l_seq_len := length(l_segment29);
       IF length(l_new_seq) < l_seq_len THEN
	 l_segment29 := lpad(l_new_seq,l_seq_len,0);
       ELSE
	 l_segment29 := l_new_seq;
       END IF;
     ELSIF l_seq_segment_name = 'SEGMENT30' THEN
       --l_seq_len := length(l_segment30);
       IF length(l_new_seq) < l_seq_len THEN
	 l_segment30 := lpad(l_new_seq,l_seq_len,0);
       ELSE
	 l_segment30 := l_new_seq;
       END IF;
     END IF;
     --

  Else -- Use Agency Sequence Returned

     -- Bug 2406584 Do not lpad agency sequence number

     l_new_seq := l_agency_seq;

     IF l_seq_segment_name    =  'SEGMENT1' THEN
       l_segment1  := l_new_seq;
     ELSIF l_seq_segment_name =  'SEGMENT2' THEN
       l_segment2  := l_new_seq;
     ELSIF l_seq_segment_name =  'SEGMENT3' THEN
       l_segment3  := l_new_seq;
     ELSIF l_seq_segment_name =  'SEGMENT4' THEN
       l_segment4  := l_new_seq;
     ELSIF l_seq_segment_name =  'SEGMENT5' THEN
       l_segment5  := l_new_seq;
     ELSIF l_seq_segment_name =  'SEGMENT6' THEN
       l_segment6  := l_new_seq;
     ELSIF l_seq_segment_name =  'SEGMENT7' THEN
       l_segment7  := l_new_seq;
     ELSIF l_seq_segment_name =  'SEGMENT8' THEN
       l_segment8  := l_new_seq;
     ELSIF l_seq_segment_name =  'SEGMENT9' THEN
       l_segment9  := l_new_seq;
     ELSIF l_seq_segment_name = 'SEGMENT10' THEN
       l_segment10 := l_new_seq;
     ELSIF l_seq_segment_name = 'SEGMENT11' THEN
       l_segment11 := l_new_seq;
     ELSIF l_seq_segment_name = 'SEGMENT12' THEN
       l_segment12 := l_new_seq;
     ELSIF l_seq_segment_name = 'SEGMENT13' THEN
       l_segment13 := l_new_seq;
     ELSIF l_seq_segment_name = 'SEGMENT14' THEN
       l_segment14 := l_new_seq;
     ELSIF l_seq_segment_name = 'SEGMENT15' THEN
       l_segment15 := l_new_seq;
     ELSIF l_seq_segment_name = 'SEGMENT16' THEN
       l_segment16 := l_new_seq;
     ELSIF l_seq_segment_name = 'SEGMENT17' THEN
       l_segment17 := l_new_seq;
     ELSIF l_seq_segment_name = 'SEGMENT18' THEN
       l_segment18 := l_new_seq;
     ELSIF l_seq_segment_name = 'SEGMENT19' THEN
       l_segment19 := l_new_seq;
     ELSIF l_seq_segment_name = 'SEGMENT20' THEN
       l_segment20 := l_new_seq;
     ELSIF l_seq_segment_name = 'SEGMENT21' THEN
       l_segment21 := l_new_seq;
     ELSIF l_seq_segment_name = 'SEGMENT22' THEN
       l_segment22 := l_new_seq;
     ELSIF l_seq_segment_name = 'SEGMENT23' THEN
       l_segment23 := l_new_seq;
     ELSIF l_seq_segment_name = 'SEGMENT24' THEN
       l_segment24 := l_new_seq;
     ELSIF l_seq_segment_name = 'SEGMENT25' THEN
       l_segment25 := l_new_seq;
     ELSIF l_seq_segment_name = 'SEGMENT26' THEN
       l_segment26 := l_new_seq;
     ELSIF l_seq_segment_name = 'SEGMENT27' THEN
       l_segment27 := l_new_seq;
     ELSIF l_seq_segment_name = 'SEGMENT28' THEN
       l_segment28 := l_new_seq;
     ELSIF l_seq_segment_name = 'SEGMENT29' THEN
       l_segment29 := l_new_seq;
     ELSIF l_seq_segment_name = 'SEGMENT30' THEN
       l_segment30 := l_new_seq;
     END IF;

  End If;

  -- Set Status to Invalid for all copies
  l_pos_data.status := 'INVALID';
  --

 hr_utility.set_location('Calling ghr_posndt.create_position:'|| l_proc, 20);
 hr_utility.set_location('l_segment1  :'||l_segment1, 21);
 hr_utility.set_location('l_segment2  :'||l_segment2, 21);
 hr_utility.set_location('l_segment3  :'||l_segment3, 21);
 hr_utility.set_location('l_segment4  :'||l_segment4, 21);
 hr_utility.set_location('l_position_id : '||l_position_id , 21);
 hr_utility.set_location('l_effective_start_date: '||l_effective_start_date, 21);
 hr_utility.set_location('l_effective_end_date: '||l_effective_end_date, 21);
 hr_utility.set_location('l_position_definition_id: '||l_position_definition_id, 21);
 hr_utility.set_location('l_name :'||l_name, 21);
 hr_utility.set_location('p_effective_date :'||p_effective_date, 21);
 hr_utility.set_location('p_date_effective :'||p_date_effective, 21);
 hr_utility.set_location('p_business_group_id :'||p_business_group_id, 21);
 hr_utility.set_location('p_concat_segments :'||p_concat_segments, 21);

 ghr_posndt_api.create_position(
     p_position_id                    => l_position_id
    ,p_effective_start_date           => l_effective_start_date
    ,p_effective_end_date             => l_effective_end_date
    ,p_position_definition_id         => l_position_definition_id
    ,p_name                           => l_name
    ,p_object_version_number          => l_object_version_number
    ,p_job_id                         => p_job_id
    ,p_organization_id                => p_organization_id
    ,p_effective_date                 => p_effective_date
    ,p_date_effective                 => p_date_effective
    ,p_validate                       => FALSE
    ,p_availability_status_id         => p_availability_status_id
    ,p_business_group_id              => p_business_group_id
    ,p_entry_step_id                  => p_entry_step_id
    ,p_entry_grade_rule_id            => p_entry_grade_rule_id
    ,p_location_id                    => p_location_id
    ,p_pay_freq_payroll_id            => p_pay_freq_payroll_id
    ,p_position_transaction_id        => p_position_transaction_id
    ,p_prior_position_id              => p_prior_position_id
    ,p_relief_position_id             => p_relief_position_id
    ,p_entry_grade_id                 => p_entry_grade_id
    ,p_successor_position_id          => p_successor_position_id
    ,p_supervisor_position_id         => p_supervisor_position_id
    ,p_amendment_date                 => p_amendment_date
    ,p_amendment_recommendation       => p_amendment_recommendation
    ,p_amendment_ref_number           => p_amendment_ref_number
    ,p_bargaining_unit_cd             => p_bargaining_unit_cd
    ,p_comments                       => p_comments
    ,p_current_job_prop_end_date      => p_current_job_prop_end_date
    ,p_current_org_prop_end_date      => p_current_org_prop_end_date
    ,p_avail_status_prop_end_date     => p_avail_status_prop_end_date
    ,p_date_end                       => p_date_end
    ,p_earliest_hire_date             => p_earliest_hire_date
    ,p_fill_by_date                   => p_fill_by_date
    ,p_frequency                      => p_frequency
    ,p_fte                            => p_fte
    ,p_max_persons                    => p_max_persons
    ,p_overlap_period                 => p_overlap_period
    ,p_overlap_unit_cd                => p_overlap_unit_cd
    ,p_pay_term_end_day_cd            => p_pay_term_end_day_cd
    ,p_pay_term_end_month_cd          => p_pay_term_end_month_cd
    ,p_permanent_temporary_flag       => p_permanent_temporary_flag
    ,p_permit_recruitment_flag        => p_permit_recruitment_flag
    ,p_position_type                  => p_position_type
    ,p_posting_description            => p_posting_description
    ,p_probation_period               => p_probation_period
    ,p_probation_period_unit_cd       => p_probation_period_unit_cd
    ,p_replacement_required_flag      => p_replacement_required_flag
    ,p_review_flag                    => p_review_flag
    ,p_seasonal_flag                  => p_seasonal_flag
    ,p_security_requirements          => p_security_requirements
    ,p_status                         => p_status
    ,p_term_start_day_cd              => p_term_start_day_cd
    ,p_term_start_month_cd            => p_term_start_month_cd
    ,p_time_normal_finish             => p_time_normal_finish
    ,p_time_normal_start              => p_time_normal_start
    ,p_update_source_cd               => p_update_source_cd
    ,p_working_hours                  => p_working_hours
    ,p_works_council_approval_flag    => p_works_council_approval_flag
    ,p_work_period_type_cd            => p_work_period_type_cd
    ,p_work_term_end_day_cd           => p_work_term_end_day_cd
    ,p_work_term_end_month_cd         => p_work_term_end_month_cd
    ,p_proposed_fte_for_layoff        => p_proposed_fte_for_layoff
    ,p_proposed_date_for_layoff       => p_proposed_date_for_layoff
    ,p_pay_basis_id                   => p_pay_basis_id
    ,p_supervisor_id                  => p_supervisor_id
    ,p_information1                   => p_information1
    ,p_information2                   => p_information2
    ,p_information3                   => p_information3
    ,p_information4                   => p_information4
    ,p_information5                   => p_information5
    ,p_information6                   => p_information6
    ,p_information7                   => p_information7
    ,p_information8                   => p_information8
    ,p_information9                   => p_information9
    ,p_information10                  => p_information10
    ,p_information11                  => p_information11
    ,p_information12                  => p_information12
    ,p_information13                  => p_information13
    ,p_information14                  => p_information14
    ,p_information15                  => p_information15
    ,p_information16                  => p_information16
    ,p_information17                  => p_information17
    ,p_information18                  => p_information18
    ,p_information19                  => p_information19
    ,p_information20                  => p_information20
    ,p_information21                  => p_information21
    ,p_information22                  => p_information22
    ,p_information23                  => p_information23
    ,p_information24                  => p_information24
    ,p_information25                  => p_information25
    ,p_information26                  => p_information26
    ,p_information27                  => p_information27
    ,p_information28                  => p_information29
    ,p_information29                  => p_information29
    ,p_information30                  => p_information30
    ,p_information_category           => p_information_category
    ,p_attribute1                     => p_attribute1
    ,p_attribute2                     => p_attribute2
    ,p_attribute3                     => p_attribute3
    ,p_attribute4                     => p_attribute4
    ,p_attribute5                     => p_attribute5
    ,p_attribute6                     => p_attribute6
    ,p_attribute7                     => p_attribute7
    ,p_attribute8                     => p_attribute8
    ,p_attribute9                     => p_attribute9
    ,p_attribute10                    => p_attribute10
    ,p_attribute11                    => p_attribute11
    ,p_attribute12                    => p_attribute12
    ,p_attribute13                    => p_attribute13
    ,p_attribute14                    => p_attribute14
    ,p_attribute15                    => p_attribute15
    ,p_attribute16                    => p_attribute16
    ,p_attribute17                    => p_attribute17
    ,p_attribute18                    => p_attribute18
    ,p_attribute19                    => p_attribute19
    ,p_attribute20                    => p_attribute20
    ,p_attribute21                    => p_attribute21
    ,p_attribute22                    => p_attribute22
    ,p_attribute23                    => p_attribute23
    ,p_attribute24                    => p_attribute24
    ,p_attribute25                    => p_attribute25
    ,p_attribute26                    => p_attribute26
    ,p_attribute27                    => p_attribute27
    ,p_attribute28                    => p_attribute28
    ,p_attribute29                    => p_attribute29
    ,p_attribute30                    => p_attribute30
    ,p_attribute_category             => p_attribute_category
    ,p_segment1                       => l_segment1
    ,p_segment2                       => l_segment2
    ,p_segment3                       => l_segment3
    ,p_segment4                       => l_segment4
    ,p_segment5                       => l_segment5
    ,p_segment6                       => l_segment6
    ,p_segment7                       => l_segment7
    ,p_segment8                       => l_segment8
    ,p_segment9                       => l_segment9
    ,p_segment10                      => l_segment10
    ,p_segment11                      => l_segment11
    ,p_segment12                      => l_segment12
    ,p_segment13                      => l_segment13
    ,p_segment14                      => l_segment14
    ,p_segment15                      => l_segment15
    ,p_segment16                      => l_segment16
    ,p_segment17                      => l_segment17
    ,p_segment18                      => l_segment18
    ,p_segment19                      => l_segment19
    ,p_segment20                      => l_segment20
    ,p_segment21                      => l_segment21
    ,p_segment22                      => l_segment22
    ,p_segment23                      => l_segment23
    ,p_segment24                      => l_segment24
    ,p_segment25                      => l_segment25
    ,p_segment26                      => l_segment26
    ,p_segment27                      => l_segment27
    ,p_segment28                      => l_segment28
    ,p_segment29                      => l_segment29
    ,p_segment30                      => l_segment30
    ,p_concat_segments                => p_concat_segments
    ,p_request_id                     => p_request_id
    ,p_program_application_id         => p_program_application_id
    ,p_program_id                     => p_program_id
    ,p_program_update_date            => p_program_update_date
);

hr_utility.set_location(l_proc, 25);

p_position_id := l_position_id;
p_effective_start_date := l_effective_start_date;
p_effective_end_date := l_effective_end_date;
p_position_definition_id := l_position_definition_id;
p_name := l_name;
p_object_version_number := l_object_version_number;

hr_utility.set_location('Created '||p_position_id||' '||p_name, 20);

-- Add Creation of Position Extra Info Here --
--
create_all_posn_ei(l_source_posn_id, p_effective_date, p_position_id, l_session_date);

-- Bug#2944210 Update the Newly Created Position Name into pqh_copy_entity_results Table
UPDATE pqh_copy_entity_results
SET    information1 = p_name
WHERE  copy_entity_result_id = pqh_generic.g_result_id ;
--

END create_position_copy;

--
-- Given a source position id this procedure will create ALL the extra info
-- details associated with the source position id onto the to position id
-- For position copy we will explicity exclude types:
--  GHR_US_POS_MASS_ACTIONS
--  GHR_US_POS_OBLIG
--  GHR_US_POS_POSITION_DESCRIPTION
--

PROCEDURE create_all_posn_ei (p_source_posn_id      IN NUMBER
                             ,p_effective_date      IN DATE
                             ,p_position_id         IN NUMBER
                             ,p_date_effective      IN DATE) IS

l_proc             varchar2(72) := g_package||'create_all_posn_ei';

--
--
--

CURSOR cur_pit IS
  SELECT pit.information_type
  FROM   per_position_info_types pit
  WHERE  pit.information_type NOT IN ('GHR_US_POS_MASS_ACTIONS','GHR_US_POS_OBLIG'
                                     ,'GHR_US_POSITION_DESCRIPTION');

BEGIN

  FOR cur_pit_rec IN cur_pit LOOP
    ghr_posn_copy.create_posn_ei(p_source_posn_id
                                ,p_effective_date
                                ,p_position_id
                                ,p_date_effective
                                ,cur_pit_rec.information_type);
  END LOOP;
hr_utility.set_location(l_proc, 30);

END create_all_posn_ei;
--
--
-- Given a source position id and information type this procedure
-- will create the extra info
-- details associated with the source position id onto the to position id
PROCEDURE create_posn_ei (p_source_posn_id      IN NUMBER
                         ,p_effective_date      IN DATE
                         ,p_position_id         IN NUMBER
                         ,p_date_effective      IN DATE
                         ,p_info_type           IN VARCHAR2) IS
--
l_pos_ei_data   per_position_extra_info%rowtype;
l_dummy_number  NUMBER;
l_result_code   VARCHAR2(30);
l_proc          varchar2(72) := g_package||'create_posn_ei';

--
CURSOR cur_poi IS
  SELECT poi.position_extra_info_id
  FROM   per_position_extra_info poi
  WHERE  poi.information_type = p_info_type
  AND    poi.position_id      = p_source_posn_id;
--
BEGIN
  -- loops to handle multi_occurrences
  FOR cur_poi_rec IN cur_poi LOOP
    -- Fetch from history
    ghr_history_fetch.fetch_positionei (
                p_position_extra_info_id        => cur_poi_rec.position_extra_info_id
               ,p_date_effective                => p_date_effective
               ,p_posei_data                    => l_pos_ei_data
               ,p_result_code                   => l_result_code);
    --
    hr_utility.set_location(l_proc, 35);
    --
    -- Now create it against the to position
    --
/*
dbms_output.put_line('Creating EI');
dbms_output.put_line('Info Type '||p_info_type);
dbms_output.put_line('Source Posn Id '||p_source_posn_id);
dbms_output.put_line('Posn Id '||p_position_id);
dbms_output.put_line('Effective Date '||p_effective_date);
dbms_output.put_line('Date Effective '||p_date_effective);
dbms_output.put_line('info cat '||l_pos_ei_data.poei_information_category);
dbms_output.put_line('info1 '||l_pos_ei_data.poei_information1);
dbms_output.put_line('info2 '||l_pos_ei_data.poei_information2);
dbms_output.put_line('info3 '||l_pos_ei_data.poei_information3);
dbms_output.put_line('info4 '||l_pos_ei_data.poei_information4);
dbms_output.put_line('info5 '||l_pos_ei_data.poei_information5);
dbms_output.put_line('info6 '||l_pos_ei_data.poei_information6);
dbms_output.put_line('info7 '||l_pos_ei_data.poei_information7);
dbms_output.put_line('info8 '||l_pos_ei_data.poei_information8);
dbms_output.put_line('info9 '||l_pos_ei_data.poei_information9);
dbms_output.put_line('info10 '||l_pos_ei_data.poei_information10);
*/

 ghr_position_extra_info_api.create_position_extra_info
 (p_validate                    => FALSE
 ,p_position_id                 => p_position_id
 ,p_information_type            => p_info_type
 ,p_effective_date              => p_effective_date
 ,p_poei_attribute_category     => l_pos_ei_data.poei_attribute_category
 ,p_poei_attribute1             => l_pos_ei_data.poei_attribute1
 ,p_poei_attribute2             => l_pos_ei_data.poei_attribute2
 ,p_poei_attribute3             => l_pos_ei_data.poei_attribute3
 ,p_poei_attribute4             => l_pos_ei_data.poei_attribute4
 ,p_poei_attribute5             => l_pos_ei_data.poei_attribute5
 ,p_poei_attribute6             => l_pos_ei_data.poei_attribute6
 ,p_poei_attribute7             => l_pos_ei_data.poei_attribute7
 ,p_poei_attribute8             => l_pos_ei_data.poei_attribute8
 ,p_poei_attribute9             => l_pos_ei_data.poei_attribute9
 ,p_poei_attribute10            => l_pos_ei_data.poei_attribute10
 ,p_poei_attribute11            => l_pos_ei_data.poei_attribute11
 ,p_poei_attribute12            => l_pos_ei_data.poei_attribute12
 ,p_poei_attribute13            => l_pos_ei_data.poei_attribute13
 ,p_poei_attribute14            => l_pos_ei_data.poei_attribute14
 ,p_poei_attribute15            => l_pos_ei_data.poei_attribute15
 ,p_poei_attribute16            => l_pos_ei_data.poei_attribute16
 ,p_poei_attribute17            => l_pos_ei_data.poei_attribute17
 ,p_poei_attribute18            => l_pos_ei_data.poei_attribute18
 ,p_poei_attribute19            => l_pos_ei_data.poei_attribute19
 ,p_poei_attribute20            => l_pos_ei_data.poei_attribute20
 ,p_poei_information_category   => l_pos_ei_data.poei_information_category
 ,p_poei_information1           => l_pos_ei_data.poei_information1
 ,p_poei_information2           => l_pos_ei_data.poei_information2
 ,p_poei_information3           => l_pos_ei_data.poei_information3
 ,p_poei_information4           => l_pos_ei_data.poei_information4
 ,p_poei_information5           => l_pos_ei_data.poei_information5
 ,p_poei_information6           => l_pos_ei_data.poei_information6
 ,p_poei_information7           => l_pos_ei_data.poei_information7
 ,p_poei_information8           => l_pos_ei_data.poei_information8
 ,p_poei_information9           => l_pos_ei_data.poei_information9
 ,p_poei_information10          => l_pos_ei_data.poei_information10
 ,p_poei_information11          => l_pos_ei_data.poei_information11
 ,p_poei_information12          => l_pos_ei_data.poei_information12
 ,p_poei_information13          => l_pos_ei_data.poei_information13
 ,p_poei_information14          => l_pos_ei_data.poei_information14
 ,p_poei_information15          => l_pos_ei_data.poei_information15
 ,p_poei_information16          => l_pos_ei_data.poei_information16
 ,p_poei_information17          => l_pos_ei_data.poei_information17
 ,p_poei_information18          => l_pos_ei_data.poei_information18
 ,p_poei_information19          => l_pos_ei_data.poei_information19
 ,p_poei_information20          => l_pos_ei_data.poei_information20
 ,p_poei_information21          => l_pos_ei_data.poei_information21
 ,p_poei_information22          => l_pos_ei_data.poei_information22
 ,p_poei_information23          => l_pos_ei_data.poei_information23
 ,p_poei_information24          => l_pos_ei_data.poei_information24
 ,p_poei_information25          => l_pos_ei_data.poei_information25
 ,p_poei_information26          => l_pos_ei_data.poei_information26
 ,p_poei_information27          => l_pos_ei_data.poei_information27
 ,p_poei_information28          => l_pos_ei_data.poei_information28
 ,p_poei_information29          => l_pos_ei_data.poei_information29
 ,p_poei_information30          => l_pos_ei_data.poei_information30
 ,p_position_extra_info_id      => l_dummy_number
 ,p_object_version_number       => l_dummy_number);

hr_utility.set_location(l_proc, 40);
--dbms_output.put_line('EI Created ');

END LOOP;

hr_utility.set_location(l_proc, 50);
  --
END create_posn_ei;

END ghr_posn_copy;

/
