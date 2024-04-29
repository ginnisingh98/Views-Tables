--------------------------------------------------------
--  DDL for Package Body PSB_HR_EXTRACT_DATA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_HR_EXTRACT_DATA_PVT" AS
/* $Header: PSBVHRXB.pls 120.34.12010000.4 2009/04/30 04:07:24 rkotha ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_HR_EXTRACT_DATA_PVT';
  g_dbug      VARCHAR2(2000);

  TYPE TokNameArray IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

  -- TokValArray contains values for all tokens

  TYPE TokValArray IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;
  -- Number of Message Tokens

  no_msg_tokens       NUMBER := 0;

  -- Message Token Name

  msg_tok_names       TokNameArray;

  -- Message Token Value

  msg_tok_val         TokValArray;

  PROCEDURE message_token
  ( tokname  IN  VARCHAR2,
    tokval   IN  VARCHAR2
  );

  PROCEDURE add_message
  (appname  IN  VARCHAR2,
   msgname  IN  VARCHAR2);
  TYPE g_glcostmap_rec_type IS RECORD
       (gl_account_segment      VARCHAR2(30),
        payroll_cost_segment    VARCHAR2(30));

  TYPE g_glcostmap_tbl_type is TABLE OF g_glcostmap_rec_type
       INDEX BY BINARY_INTEGER;

  PROCEDURE insert_cost_distribution_row
  ( p_assignment_id        IN   NUMBER,
    p_cost_keyflex_id      IN   NUMBER,
    p_business_group_id    IN   NUMBER,
    p_costing_level        IN   VARCHAR2,
    p_index                IN   BINARY_INTEGER,
    p_proportion           IN   NUMBER,
    p_start_date           IN   DATE,
    p_end_date             IN   DATE,
    p_data_extract_id      IN   NUMBER,
    p_cost_segments        IN   g_glcostmap_tbl_type,
    p_chart_of_accounts_id IN   NUMBER
  );

  TYPE StatusTypArray IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  assign_stat_types       StatusTypArray;

  PROCEDURE Init
  ( p_date IN OUT NOCOPY DATE
  )

  -- Private API for Initialization
  AS
  lsession number;
  l_cnt number;
  BEGIN
    if (p_date is null) then
       p_date := trunc(sysdate);
    end if;

    SELECT USERENV('sessionid') into
           lsession
      FROM dual;

   -- Set up effective Date
    Select count(*) into l_cnt
      from fnd_sessions
     where session_id = lsession
       and effective_date = p_date;

    if  (l_cnt = 0 ) then
        INSERT INTO fnd_sessions
        (session_id,effective_date)
        values (lsession,p_date);
    end if;

  END;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                      PROCEDURE Get_Position_Information                   |
 +===========================================================================*/
PROCEDURE Get_Position_Information
( p_api_version         IN    NUMBER,
  p_init_msg_list       IN    VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN    VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT   NOCOPY VARCHAR2,
  p_msg_count           OUT   NOCOPY NUMBER,
  p_msg_data            OUT   NOCOPY VARCHAR2,
  p_data_extract_id     IN    NUMBER,
  -- de by org
  p_extract_by_org      IN    VARCHAR2,
  p_extract_method      IN    VARCHAR2,
  p_id_flex_num         IN    NUMBER,
  p_date                IN    DATE,
  p_business_group_id   IN    NUMBER,
  p_set_of_books_id     IN    NUMBER
)
IS
  --
  l_position_name       varchar2(240);
  --UTF8 changes for Bug No : 2615261
  l_employee_name       varchar2(310);
  l_person_id           number;
  l_position_ctr        number := 0;
  l_fin_position_id     number := -1;
  l_restart_position_id number := 0;
  prev_person_id        number := -1;
  prev_position_id      number := -1;
  l_process_flag        varchar2(1);
  l_last_update_date    date;
  l_last_updated_by     number;
  l_last_update_login   number;
  l_creation_date       date;
  l_created_by          number;
  d_date_end            date;
  --

  --
  -- Variables for retrieving salary details of a position
  --
  l_grade_rule_id       number;
  l_step_id             number;
  l_salary_type         varchar2(15);
  l_rate_type           varchar2(10);
  l_rate_or_payscale_id number;
  l_grade_step          number;
  l_grade_spine_id      number;
  l_pay_basis_id        number;
  l_pay_basis           varchar2(30);
  l_sequence            number;
  l_value               number;
  l_rate_cnt_flag       varchar2(1);
  l_session_date        date;
  l_grade_or_spinal_point_id  number;
  l_assignment_status_type_id number;

  l_pos_id_flex_num     number;
   l_per_index           BINARY_INTEGER;
   tf                    BOOLEAN;
   nsegs                 NUMBER;
   segs                  FND_FLEX_EXT.SegmentArray;
   possegs               FND_FLEX_EXT.SegmentArray;

   --
   l_status              varchar2(1);
   l_return_status       varchar2(1);
   l_msg_count           number;
   l_msg_data            varchar2(1000);
   l_msg                 varchar2(2000);
   l_status_count        number := 0;
   l_assign_stat_cnt     number := 0;
   -- Start bug no 3902996
   l_parent_spine_id     NUMBER := 0;
   -- End bug no 3902996

   --
   --
   -- Cursor to select filled as well as vacant positions. The First sub-query
   -- pickes up filled positions while the other one picks up vacant ones.
   --

  CURSOR l_positions_csr
  IS
  SELECT pp.position_id,
         pp.position_definition_id,
         pp.organization_id,
         paf.person_id,
         paf.primary_flag,
         paf.assignment_status_type_id,
         pp.name,
         pp.business_group_id,
         pp.date_effective,
         pp.date_end,
         pp.entry_grade_id,
         pp.entry_grade_rule_id,
         pp.entry_step_id,
         pp.pay_basis_id,
         pst.system_type_cd
  FROM   fnd_sessions             fs,
         hr_all_positions_f       pp  ,
         per_shared_types         pst ,
         per_all_assignments_f    paf ,
         pay_all_payrolls_f       ppay,
         per_pay_bases            ppb,
         per_assignment_status_types past --bug 4020452
  WHERE  fs.session_id = userenv('sessionid')
  AND    fs.effective_date between pp.effective_start_date
                           and pp.effective_end_date
  AND    pp.business_group_id       = p_business_group_id
  AND    pp.position_id             > l_restart_position_id
  AND    ( (l_status_count > 0 and pst.business_group_id = p_business_group_id)
           or
           (l_status_count = 0 and pst.business_group_id is null) )
  AND    pp.availability_status_id  = pst.shared_type_id
  AND    pst.system_type_cd         in ('PROPOSED','ACTIVE', 'FROZEN')
  AND    fs.effective_date between paf.effective_start_date
                           and paf.effective_end_date
  AND    paf.position_id            = pp.position_id
  AND    paf.business_group_id      = p_business_group_id
  AND    paf.assignment_type        = 'E'
  /*Bug: 2109120 Start*/
  -- AND        paf.primary_flag           = 'Y'
  /*Bug: 2109120 End*/
  AND    fs.effective_date between ppay.effective_start_date
                           and ppay.effective_end_date
  AND    ppay.payroll_id            = paf.payroll_id
  AND    ppay.gl_set_of_books_id    = p_set_of_books_id
  AND    paf.pay_basis_id           = ppb.pay_basis_id

  /* bug 4020452 start */
  AND    paf.assignment_status_type_id = past.assignment_status_type_id
  AND    past.per_system_status <> 'TERM_ASSIGN'
  /* bug 4020452 end */

  /*
  The following logic is used to restrict the positions for all the selected
  organizations, if extract by org is enabled.  Otherwise, we will ignore
  the organizations avaiable in the business group
  */
  AND    ( p_extract_by_org = 'N'
           OR
	   (p_extract_by_org = 'Y' and pp.organization_id in
	                           (select organization_id
	                            from   psb_data_extract_orgs
	                            where  data_extract_id = p_data_extract_id
	                            and    select_flag = 'Y' )
           )
         )
  UNION ALL
  SELECT pp.position_id,
         pp.position_definition_id,
         pp.organization_id,
         0,
         'Y',
         to_number(NULL),
         pp.name,
         pp.business_group_id,
         pp.date_effective,
         pp.date_end,
         pp.entry_grade_id,
         pp.entry_grade_rule_id,
         pp.entry_step_id,
         pp.pay_basis_id,
         pst.system_type_cd
  FROM   fnd_sessions             fs,
         hr_all_positions_f       pp ,
         per_shared_types         pst
  WHERE  fs.session_id = userenv('sessionid')
  AND    fs.effective_date between pp.effective_start_date
                           and pp.effective_end_date
  AND    pp.business_group_id       = p_business_group_id
  AND    pp.position_id             > l_restart_position_id
  AND    pp.availability_status_id  = pst.shared_type_id
  AND    ( (l_status_count > 0 and pst.business_group_id = p_business_group_id)
           OR
           (l_status_count = 0 and pst.business_group_id is null)
         )
  -- for bug 4533884 .removed frozen from the IN clause so that
  -- vacant frozen positions will not be picked up
  -- AND    pst.system_type_cd         in ('PROPOSED','ACTIVE','FROZEN')
  AND    pst.system_type_cd         in ('PROPOSED','ACTIVE')
  AND    ( (NOT EXISTS
               ( SELECT 1
                 FROM   per_all_assignments_f pafx,
                 -- bug 3777146 added the join with per_assignment_status_types
                        per_assignment_status_types past
                 WHERE  fs.session_id = userenv('sessionid')
                 AND    fs.effective_date between pafx.effective_start_date
                                          and pafx.effective_end_date
                 AND pafx.assignment_status_type_id
                                          = past.assignment_status_type_id
                 AND    pafx.position_id       = pp.position_id
                 -- Bug#3265678: This clause picks all occupied positions.
      		 -- AND pafx.assignment_type <> 'A'
      		 AND    pafx.assignment_type   = 'E'
                 AND    past.per_system_status <> 'TERM_ASSIGN'
               )
           )
           OR
           ( ( pp.position_type <> 'SINGLE')
             AND
             ( nvl(pp.fte,1) >
               ( SELECT sum(nvl(value,1))
      	         FROM   per_assignment_budget_values_f pab,
           	        per_all_assignments_f paf,
                        per_assignment_status_types past
                 -- bug 4020452 added the join with per_assignment_status_types
     		 WHERE  fs.session_id = userenv('sessionid')
                 AND    fs.effective_date between paf.effective_start_date
                                          and paf.effective_end_date
                 AND    paf.assignment_status_type_id
                                          = past.assignment_status_type_id
                 AND    paf.position_id = pp.position_id
		 AND    paf.assignment_type = 'E'
                 AND    past.per_system_status <> 'TERM_ASSIGN' --bug 4020452
                 /* For Bug 2891574 start*/
                 --AND  fs.effective_date between pab.effective_start_date
                 --     and pab.effective_end_date
                 AND    pab.effective_start_date(+) <= fs.effective_date
                 AND    pab.effective_end_date(+) >= fs.effective_date
                 /* For Bug 2891574 end*/
       		 AND    pab.assignment_id(+)  = paf.assignment_id
       		 AND    pab.unit(+) = 'FTE'
               )
       	     )
           )
         )
      /*
      Logic to restrict the positions for all the selected organizations, if
      extract by org is enabled.  Otherwise, we will ignore organizations
      avaiable in the business group
      */
  AND    ( p_extract_by_org = 'N'
           OR
	   (p_extract_by_org = 'Y' and pp.organization_id in
	                           ( select organization_id
	                             from psb_data_extract_orgs
	                             where data_extract_id = p_data_extract_id
                                     and select_flag = 'Y'
                                   )
           )
         )
  ORDER BY 1,3,4 desc;

  Cursor C_flex_num is
        select position_structure
          from per_business_groups
         where business_group_id = p_business_group_id;

  Cursor C_pos_segs is
    select application_column_name
      from fnd_id_flex_segments_vl
     where id_flex_code = 'POS'
       and id_flex_num = l_pos_id_flex_num
       and enabled_flag = 'Y'
    order by segment_num;

  Cursor C_rate_check is
  Select count(*), parent_spine_id
    from pay_rates
   where business_group_id = p_business_group_id
   -- Start bug no 3902996
     and parent_spine_id = l_parent_spine_id
   -- End bug no 3902996
     and rate_type = 'SP'
   group by parent_spine_id
   having count(*) > 1;

  Cursor C_session is
     SELECT effective_date
       FROM FND_SESSIONS
      WHERE session_id = USERENV('sessionid');

  Cursor C_grade_spine is
        SELECT grade_spine_id
          FROM per_spinal_point_steps
         WHERE step_id = l_step_id;

  Cursor C_Pay_Grade is
    SELECT effective_start_date,effective_end_date,
           rate_id, grade_or_spinal_point_id, rate_type,
           maximum,mid_value,minimum,sequence,value
      FROM PAY_GRADE_RULES
     WHERE business_group_id = p_business_group_id
       AND grade_rule_id     = l_grade_rule_id;

  Cursor  C_payscale is
     SELECT parent_spine_id
       FROM PER_SPINAL_POINTS
      WHERE spinal_point_id = l_grade_or_spinal_point_id
       AND business_group_id = p_business_group_id;

  Cursor C_pay_basis is
    SELECT pay_basis
      FROM PER_PAY_BASES
     WHERE pay_basis_id = l_pay_basis_id;

 --
 -- Cursor to find the list of assignment_status types
 -- that correspond to Terminated Assignment Status
 --
 /* Bug 4929586 commenting out the below cursor
 Cursor l_assign_stat_csr is
   Select assignment_status_type_id
     from per_assignment_status_types
    where (business_group_id = p_business_group_id
       or business_group_id  is null)
      and PER_SYSTEM_STATUS = 'TERM_ASSIGN'; */
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Get_Position_Information';
  l_api_version         CONSTANT NUMBER         := 1.0;
  --
BEGIN

  -- Standard Start of API savepoint

  Savepoint Get_Position;

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
     FND_MSG_PUB.initialize;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body

  l_last_update_date  := sysdate;
  l_last_updated_by   := FND_GLOBAL.USER_ID;
  l_last_update_login := FND_GLOBAL.LOGIN_ID;
  l_creation_date     := sysdate;
  l_created_by        := FND_GLOBAL.USER_ID;


  Check_Reentry
  (p_api_version              => 1.0  ,
   p_return_status            => l_return_status,
   p_msg_count                => l_msg_count,
   p_msg_data                 => l_msg_data,
   p_data_extract_id          => p_data_extract_id,
   p_process                  => 'Positions Interface',
   p_status                   => l_status,
   p_restart_id               => l_restart_position_id
   );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     raise FND_API.G_EXC_ERROR;
  end if;


  if (l_status <> 'C') then

  For C_flex_rec in C_flex_num
  Loop
    l_pos_id_flex_num := C_flex_rec.position_structure;
  End Loop;

  -- Start bug no 3902996
  /*l_rate_cnt_flag := 'N';

  For C_rate_check_rec in C_rate_check
  Loop
    l_rate_cnt_flag := 'Y' ;
    exit;
  End Loop;*/
  -- End bug no 3902996

  -- Process all the positions (filled and vacant both).
  SELECT count(*) into l_status_count
    from per_shared_types
   where business_group_id = p_business_group_id
     and system_type_cd   in ('PROPOSED','ACTIVE', 'FROZEN');

  /* Bug 4929586
  assign_stat_types.delete;
  FOR l_assign_stat_rec in l_assign_stat_csr
  Loop
   l_assign_stat_cnt := l_assign_stat_cnt + 1;
   assign_stat_types(l_assign_stat_cnt) := l_assign_stat_rec.assignment_status_type_id;
  End Loop;  */

  FOR position_rec IN l_positions_csr
  LOOP
    l_position_name              := null;
    l_person_id                  := null;
    l_assignment_status_type_id  := null;

    l_position_name              := position_rec.name;
    l_person_id                  := position_rec.person_id;

    l_process_flag := 'Y';

    /* Bug 4929586
    if (l_person_id is not null) then
       l_assignment_status_type_id  := position_rec.assignment_status_type_id;
       For k in 1..l_assign_stat_cnt
       Loop
         if (assign_stat_types(k) = l_assignment_status_type_id) then
          l_process_flag := 'N';
         end if;
       End Loop;
    end if; */


    if ((prev_position_id = position_rec.position_id) and
         (prev_position_id <> -1) and
        (prev_person_id = position_rec.person_id) and
        (prev_person_id <> -1) and
        (prev_person_id <> 0)) then

          l_process_flag := 'N';
    end if;

    prev_position_id := position_rec.position_id;
    prev_person_id := position_rec.person_id;

   if (l_process_flag = 'Y') then

    if ((position_rec.position_id <> l_fin_position_id) and (l_fin_position_id <> -1)) then
       l_position_ctr := l_position_ctr + 1;
    end if;

    if (l_person_id <> 0) then
       For Emp_Name_Rec in G_Employee_Details(p_person_id => l_person_id)
       Loop
         l_employee_name := Emp_Name_Rec.first_name||' '||Emp_Name_Rec.last_name;
       End Loop;
    end if;

   if (position_rec.date_end = to_date('31124712','DDMMYYYY')) then
       d_date_end := to_date(null);
   else
       d_date_end := position_rec.date_end;
   end if;

  l_salary_type   := null;
  l_grade_rule_id := position_rec.entry_grade_rule_id;
  l_step_id       := position_rec.entry_step_id;
  l_pay_basis_id  := position_rec.pay_basis_id;

  For C_Pay_Grade_Rec in C_Pay_Grade
  Loop
    l_rate_type                := C_Pay_Grade_Rec.rate_type;
    if (l_rate_type = 'G') then
       l_rate_or_payscale_id := C_Pay_Grade_Rec.rate_id;
       l_value   := fnd_number.canonical_to_number(C_Pay_Grade_Rec.value);
       l_salary_type   := 'RATE';
    else
       l_grade_or_spinal_point_id := C_Pay_Grade_Rec.grade_or_spinal_point_id;
       l_sequence                 := C_Pay_Grade_Rec.sequence;
       l_value   := fnd_number.canonical_to_number(C_Pay_Grade_Rec.value);
       l_salary_type              := 'STEP';

       -- Start bug no 3902996
       For C_Payscale_rec in C_Payscale
       Loop
         l_parent_spine_id := C_Payscale_rec.parent_spine_id;
       end loop;

       l_rate_cnt_flag := 'N';
       For C_rate_check_rec in C_rate_check
       Loop
         l_rate_cnt_flag := 'Y' ;
         exit;
       End Loop;
       -- End bug no 3902996

       For C_grade_spine_rec in C_grade_spine
       loop
          l_grade_spine_id := C_grade_spine_rec.grade_spine_id;
       end loop;

       For C_session_rec in C_session
       Loop
         l_session_date := C_session_rec.effective_date;
       End Loop;

       per_spinal_point_steps_pkg.pop_flds(l_grade_step,
                                           l_session_date,
                                           l_grade_or_spinal_point_id,
                                           l_grade_spine_id);

      if (l_rate_cnt_flag = 'Y') then
         l_rate_or_payscale_id := C_Pay_Grade_Rec.rate_id;
      else
       -- Start bug no 3902996
       /*For C_Payscale_rec in C_Payscale
       Loop
         l_rate_or_payscale_id := C_Payscale_rec.parent_spine_id;
       end loop;*/
       l_rate_or_payscale_id := l_parent_spine_id;
       -- End bug no 3902996

      end if;
    end if;

  end loop;


  For C_pay_basis_rec in C_pay_basis
  loop
    l_pay_basis := C_pay_basis_rec.pay_basis;
  end loop;

  tf := FND_FLEX_EXT.GET_SEGMENTS('PER', 'POS', l_pos_id_flex_num, position_rec.position_definition_id, nsegs, segs);
  if (tf = FALSE) then

        l_msg := FND_MESSAGE.Get;
        FND_FILE.put_line(FND_FILE.LOG,'Invalid Segments  HRMS Position: '||
                                                    position_rec.position_id);
        FND_FILE.put_line(FND_FILE.LOG,l_msg);
        FND_MESSAGE.SET_NAME('PSB','PSB_POS_DEFN_VALUE_ERROR');
        FND_MESSAGE.SET_TOKEN('POSITION_NAME',l_position_name );
        FND_MESSAGE.SET_TOKEN('ERR_MESG',l_msg);
        FND_MSG_PUB.Add;
  end if;

  l_per_index := 1;

  For k in 1..30
  Loop
   possegs(k) := null;
  End Loop;

  For C_pos_seg_rec in C_pos_segs
  Loop
      If (C_pos_seg_rec.application_column_name = 'SEGMENT1') then
         possegs(1) := segs(l_per_index);
         l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT2') then
         possegs(2) := segs(l_per_index);
         l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT3') then
         possegs(3) := segs(l_per_index);
         l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT4') then
         possegs(4) := segs(l_per_index);
         l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT5') then
         possegs(5) := segs(l_per_index);
         l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT6') then
         possegs(6) := segs(l_per_index);
         l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT7') then
         possegs(7) := segs(l_per_index);
         l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT8') then
         possegs(8) := segs(l_per_index);
         l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT9') then
         possegs(9) := segs(l_per_index);
         l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT10') then
         possegs(10) := segs(l_per_index);
         l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT11') then
         possegs(11) := segs(l_per_index);
         l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT12') then
         possegs(12) := segs(l_per_index);
         l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT13') then
         possegs(13) := segs(l_per_index);
         l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT14') then
         possegs(14) := segs(l_per_index);
         l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT15') then
         possegs(15) := segs(l_per_index);
         l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT16') then
         possegs(16) := segs(l_per_index);
         l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT17') then
         possegs(17) := segs(l_per_index);
         l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT18') then
         possegs(18) := segs(l_per_index);
         l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT19') then
         possegs(19) := segs(l_per_index);
         l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT20') then
         possegs(20) := segs(l_per_index);
         l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT21') then
         possegs(21) := segs(l_per_index);
         l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT22') then
         possegs(22) := segs(l_per_index);
         l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT23') then
         possegs(23) := segs(l_per_index);
         l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT24') then
         possegs(24) := segs(l_per_index);
         l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT25') then
         possegs(25) := segs(l_per_index);
         l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT26') then
         possegs(26) := segs(l_per_index);
         l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT27') then
         possegs(27) := segs(l_per_index);
         l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT28') then
         possegs(28) := segs(l_per_index);
         l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT29') then
         possegs(29) := segs(l_per_index);
         l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT30') then
         possegs(30) := segs(l_per_index);
         l_per_index := l_per_index + 1;
      end if;

  End Loop;

   INSERT INTO PSB_POSITIONS_I
   (
    DATA_EXTRACT_ID         ,
    BUSINESS_GROUP_ID       ,
    HR_POSITION_ID          ,
    HR_EMPLOYEE_ID          ,
    HR_POSITION_NAME        ,
    -- de by org
    ORGANIZATION_ID         ,
    EFFECTIVE_START_DATE    ,
    EFFECTIVE_END_DATE      ,
    HR_POSITION_DEFINITION_ID,
    SUMMARY_FLAG            ,
    ENABLED_FLAG            ,
    ID_FLEX_NUM             ,
    AVAILABILITY_STATUS     ,
    SALARY_TYPE             ,
    RATE_OR_PAYSCALE_ID     ,
    GRADE_ID                ,
    GRADE_STEP              ,
    SEQUENCE_NUMBER         ,
    VALUE                   ,
    PAY_BASIS               ,
    SEGMENT1                ,
    SEGMENT2                ,
    SEGMENT3                ,
    SEGMENT4                ,
    SEGMENT5                ,
    SEGMENT6                ,
    SEGMENT7                ,
    SEGMENT8                ,
    SEGMENT9                ,
    SEGMENT10               ,
    SEGMENT11               ,
    SEGMENT12               ,
    SEGMENT13               ,
    SEGMENT14               ,
    SEGMENT15               ,
    SEGMENT16               ,
    SEGMENT17               ,
    SEGMENT18               ,
    SEGMENT19               ,
    SEGMENT20               ,
    SEGMENT21               ,
    SEGMENT22               ,
    SEGMENT23               ,
    SEGMENT24               ,
    SEGMENT25               ,
    SEGMENT26               ,
    SEGMENT27               ,
    SEGMENT28               ,
    SEGMENT29               ,
    SEGMENT30               ,
    LAST_UPDATE_DATE        ,
    LAST_UPDATED_BY         ,
    LAST_UPDATE_LOGIN       ,
    CREATED_BY              ,
    CREATION_DATE
   )
   VALUES
   (
     p_data_extract_id,
     position_rec.business_group_id,
     position_rec.position_id,
     decode(position_rec.person_id,0,null,position_rec.person_id),
     position_rec.name,
     -- de by org
     position_rec.organization_id,
     position_rec.date_effective,
     d_date_end,
     position_rec.position_definition_id,
     'Y',
     'Y',
     p_id_flex_num,
     position_rec.system_type_cd,
     l_salary_type,
     l_rate_or_payscale_id,
     position_rec.entry_grade_id,
     l_grade_step,
     l_sequence,
     l_value,
     l_pay_basis,
     possegs(1),
     possegs(2),
     possegs(3),
     possegs(4),
     possegs(5),
     possegs(6),
     possegs(7),
     possegs(8),
     possegs(9),
     possegs(10),
     possegs(11),
     possegs(12),
     possegs(13),
     possegs(14),
     possegs(15),
     possegs(16),
     possegs(17),
     possegs(18),
     possegs(19),
     possegs(20),
     possegs(21),
     possegs(22),
     possegs(23),
     possegs(24),
     possegs(25),
     possegs(26),
     possegs(27),
     possegs(28),
     possegs(29),
     possegs(30),
     l_last_update_date,
     l_last_updated_by ,
     l_last_update_login ,
     l_created_by,
     l_creation_date
   );

  if l_position_ctr = PSB_WS_ACCT1.g_checkpoint_save then
        Update_Reentry
        ( p_api_version              => 1.0  ,
          p_return_status            => l_return_status,
          p_msg_count                => l_msg_count,
          p_msg_data                 => l_msg_data,
          p_data_extract_id          => p_data_extract_id,
          p_extract_method           => p_extract_method,
          p_process                  => 'Positions Interface',
          p_restart_id               => position_rec.position_id
        );

       if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          raise FND_API.G_EXC_ERROR;
       end if;
      commit work;
      l_position_ctr := 0;
      Savepoint Get_Position;
    end if;

    l_fin_position_id := position_rec.position_id;

   end if;

  END LOOP; -- End processing positions.

  Update_Reentry
  ( p_api_version              => 1.0  ,
    p_return_status            => l_return_status,
    p_msg_count                => l_msg_count,
    p_msg_data                 => l_msg_data,
    p_data_extract_id          => p_data_extract_id,
    p_extract_method           => p_extract_method,
    p_process                  => 'Positions Interface',
    p_restart_id               => l_fin_position_id
  );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  end if;

  Reentrant_Process
  ( p_api_version              => 1.0  ,
    p_return_status            => l_return_status,
    p_msg_count                => l_msg_count,
    p_msg_data                 => l_msg_data,
    p_data_extract_id          => p_data_extract_id,
    p_extract_method           => p_extract_method,
    p_process                  => 'Positions Interface'
  );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     raise FND_API.G_EXC_ERROR;
  end if;

  commit work;

  end if ; -- Checking IF (l_status <> 'C ).

  -- End of API body.

EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Get_Position;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                 p_data  => p_msg_data);
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                 p_data  => p_msg_data);
     message_token('POSITION_NAME',l_position_name );
     message_token('EMPLOYEE_NAME',l_employee_name );
     add_message('PSB', 'PSB_POSITION_DETAILS');

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Get_Position;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                 p_data  => p_msg_data);
     message_token('POSITION_NAME',l_position_name );
     message_token('EMPLOYEE_NAME',l_employee_name );
     add_message('PSB', 'PSB_POSITION_DETAILS');

  WHEN OTHERS THEN
    --
    ROLLBACK TO Get_Position ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;
    --

    --
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );
    --
    message_token('POSITION_NAME',l_position_name );
    message_token('EMPLOYEE_NAME',l_employee_name );
    add_message('PSB', 'PSB_POSITION_DETAILS');

END Get_Position_Information;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                      PROCEDURE Get_Salary_Information                     |
 +===========================================================================*/
PROCEDURE Get_Salary_Information
( p_api_version         IN    NUMBER,
  p_init_msg_list	IN    VARCHAR2 := FND_API.G_FALSE,
  p_commit	    	IN    VARCHAR2 := FND_API.G_FALSE,
  p_validation_level	IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT   NOCOPY VARCHAR2,
  p_msg_count           OUT   NOCOPY NUMBER,
  p_msg_data            OUT   NOCOPY VARCHAR2,
  p_data_extract_id     IN    NUMBER,
  p_extract_method      IN    VARCHAR2,
  p_business_group_id   IN    NUMBER
)
IS
  --
  l_api_name		CONSTANT VARCHAR2(30)	:= 'Get_Salary_Information';
  l_api_version         CONSTANT NUMBER 	:= 1.0;
  --
  l_last_update_date             date;
  l_last_updated_by              number;
  l_last_update_login            number;
  l_creation_date                date;
  l_created_by                   number;
  l_restart_grade_rule_id        number := 0;
  l_fin_graderule_id             number := 0;
  l_session_date                 date;
  l_salary_ctr                   number := 0;
  l_salary_type                  varchar2(15);
  l_rate_or_payscale_id          number;
  l_parent_spine_id              number;
  l_rate_or_payscale_name        varchar2(80);
  l_grade_step                   number;
  l_grade_step_id                number;
  l_grade_id                     number;
  ld_grade_id                    number;
  lh_grade_id                    number;
  l_grade_id_flex_num            number;
  l_grade_spine_id               number;
  l_grade_name                   varchar2(80);
  l_element_value                number;
  l_element_type_id              number;
  l_minimum_value                number;
  l_maximum_value                number;
  l_mid_value                    number;
  l_sequence                     number;
  l_rate_id                      number;
  l_rate_cnt_flag                varchar2(1);
  l_pay_basis                    varchar2(30);
  l_grade_or_spinal_point_id     number;
  l_grade_stmt                   varchar2(1000);
  l_status                       varchar2(1);
  l_return_status                varchar2(1);
  l_msg_count                    number;
  l_msg_data                     varchar2(1000);
  d_effective_end_date           date;
/*v_gcursorid                    INTEGER;
  v_gdummy                       INTEGER; */
  --
  Cursor C3 is
       SELECT
             GRADE_RULE_ID ,
             EFFECTIVE_START_DATE ,
             EFFECTIVE_END_DATE,
             BUSINESS_GROUP_ID,
             RATE_ID ,
             GRADE_OR_SPINAL_POINT_ID,
             RATE_TYPE,
             MAXIMUM,
             MID_VALUE,
             MINIMUM,
             SEQUENCE,
             VALUE
       FROM  PAY_GRADE_RULES
      WHERE  BUSINESS_GROUP_ID = p_business_group_id
        AND  grade_rule_id > l_restart_grade_rule_id
      ORDER  BY grade_rule_id;
  --
  Cursor Cpay is
     SELECT pgs.grade_id,pgs.grade_spine_id,psp.step_id,psp.sequence
       FROM PER_GRADE_SPINES pgs,PER_SPINAL_POINT_STEPS psp
      WHERE pgs.parent_spine_id = l_parent_spine_id
        AND pgs.business_group_id = p_business_group_id
        AND psp.business_group_id = p_business_group_id
        AND pgs.grade_spine_id    = psp.grade_spine_id
        AND psp.spinal_point_id   = l_grade_or_spinal_point_id;
  --
  Cursor  C_payscale is
     SELECT parent_spine_id
       FROM PER_SPINAL_POINTS
      WHERE spinal_point_id = l_grade_or_spinal_point_id
       AND business_group_id = p_business_group_id;
  --
  Cursor  C_payname is
     SELECT name
       FROM PER_PARENT_SPINES
      WHERE parent_spine_id = l_rate_or_payscale_id
        AND business_group_id = p_business_group_id;
  --
  Cursor  C_paybasis is
     SELECT pay_basis, piv.element_type_id
       FROM PAY_RATES pr, PER_PAY_BASES ppb, PAY_INPUT_VALUES piv
      WHERE pr.parent_spine_id = l_rate_or_payscale_id
        AND pr.rate_id = ppb.rate_id
        AND pr.business_group_id = p_business_group_id
        AND ppb.business_group_id = p_business_group_id
        AND ppb.input_value_id = piv.input_value_id;
  --
  /*Cursor C_flex_num is
        select grade_structure
          from per_business_groups
         where business_group_id = p_business_group_id; */
  --
  Cursor C_session is
     SELECT effective_date
       FROM FND_SESSIONS
      WHERE session_id = USERENV('sessionid');
  --
  Cursor C_rate is
      SELECT name
        FROM PAY_RATES
       WHERE rate_id = l_rate_id;

  -- To fetch grade name from PER_GRADES
  -- (Bug Number 3159157)
  Cursor C_grade is
     SELECT name
       FROM PER_GRADES
      WHERE grade_id = l_grade_id;

  --
  Cursor C_rate_paybasis is
     SELECT ppb.pay_basis, piv.element_type_id
       FROM PER_PAY_BASES ppb, PAY_INPUT_VALUES piv
      WHERe ppb.rate_id = l_rate_id
        AND ppb.business_group_id = p_business_group_id
        AND ppb.input_value_id = piv.input_value_id;
  --
  Cursor C_rate_check is
  Select count(*), parent_spine_id
    from pay_rates
   where business_group_id = p_business_group_id
  -- Start bug no 3902996
     and parent_spine_id = l_parent_spine_id
  -- End bug no 3902996
     and rate_type = 'SP'
   group by parent_spine_id
   having count(*) > 1;
  --
BEGIN

  -- Standard Start of API savepoint
  Savepoint Get_Salary;

  -- Standard call to check for call compatibility.
  if not FND_API.Compatible_API_Call (l_api_version,
            	    	    	      p_api_version,
   	       	    	 	      l_api_name,
		    	    	      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  if FND_API.to_Boolean (p_init_msg_list) then
     FND_MSG_PUB.initialize;
  end if;
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  l_last_update_date  := sysdate;
  l_last_updated_by   := FND_GLOBAL.USER_ID;
  l_last_update_login := FND_GLOBAL.LOGIN_ID;
  l_creation_date     := sysdate;
  l_created_by        := FND_GLOBAL.USER_ID;

  Check_Reentry
  (p_api_version              => 1.0  ,
   p_return_status            => l_return_status,
   p_msg_count                => l_msg_count,
   p_msg_data                 => l_msg_data,
   p_data_extract_id          => p_data_extract_id,
   p_process                  => 'Salary Interface',
   p_status                   => l_status,
   p_restart_id               => l_restart_grade_rule_id
   );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     raise FND_API.G_EXC_ERROR;
  end if;

  -- Start bug no 3902996
  /*l_rate_cnt_flag := 'N';

  For C_rate_check_rec in C_rate_check
  Loop
    l_rate_cnt_flag := 'Y' ;
    exit;
  End Loop;*/
  -- End bug no 3902996

/*Bug No:1954662 Start*/
/*For C_flex_rec in C_flex_num
  Loop
    l_grade_id_flex_num := C_flex_rec.grade_structure;
  End Loop;
*/
  if (l_status <> 'C') then

  -- Commented out for bug number 3159157
  /*For C_flex_rec in C_flex_num
  Loop
    l_grade_id_flex_num := C_flex_rec.grade_structure;
  End Loop;

  if (l_grade_id_flex_num is not null) then
     v_gcursorid := DBMS_SQL.OPEN_CURSOR;
     l_grade_stmt := 'SELECT pg.grade_id,pgv.concatenated_segments
                        FROM PER_GRADES pg,PER_GRADE_DEFINITIONS_KFV pgv
                       WHERE pg.grade_id = '||':ld_grade_id'||
                       ' AND pg.business_group_id = '||p_business_group_id||
                       ' AND pg.grade_definition_id = pgv.grade_definition_id'||
                       ' AND pgv.id_flex_num        = '||l_grade_id_flex_num;

     DBMS_SQL.PARSE(v_gcursorid,l_grade_stmt,DBMS_SQL.V7);
     DBMS_SQL.DEFINE_COLUMN(v_gcursorid,1,lh_grade_id);
     DBMS_SQL.DEFINE_COLUMN(v_gcursorid,2,l_grade_name,80);
  end if; */
/*Bug No:1954662 End*/

  For salary_rec IN C3 LOOP
     l_salary_ctr    := l_salary_ctr + 1;
     l_fin_graderule_id := salary_rec.grade_rule_id;
     l_minimum_value := 0;
     l_maximum_value := 0;
     l_mid_value     := 0;
     l_element_value := 0;
     l_grade_step    := null;
     l_sequence      := null;
     l_salary_type   := null;

     if (salary_rec.effective_end_date = to_date('31124712','DDMMYYYY')) then
         d_effective_end_date := to_date(null);
     else
         d_effective_end_date := salary_rec.effective_end_date;
     end if;

     l_grade_or_spinal_point_id := salary_rec.grade_or_spinal_point_id;
     l_rate_id := salary_rec.rate_id;

  -- If pay_grade_rules.rate_type = 'SP' then
  -- the salary type  is 'Grade Scale'

   if (salary_rec.rate_type = 'SP') then

      l_salary_type := 'STEP';

  -- The grade_or_spinal_point_id refers to
  -- the grade_id or spinal_point_id depending
  -- on the rate_type being 'Grade Rate' or 'Grade Scale' respectively.
  -- To get the payscale_id ..


    For C_payscale_rec in C_payscale
    Loop
       l_parent_spine_id := C_payscale_rec.parent_spine_id;
    End Loop;

    -- Start bug no 3902996
    l_rate_cnt_flag := 'N';
    For C_rate_check_rec in C_rate_check
    Loop
      l_rate_cnt_flag := 'Y' ;
      exit;
    End Loop;
    -- End bug no 3902996

    if (l_rate_cnt_flag = 'Y') then

      l_rate_or_payscale_id := salary_rec.rate_id;

      -- To get Grade Rate Name from pay_rates
      For C_rate_rec in C_rate
      Loop
         l_rate_or_payscale_name := C_rate_rec.name;

         -- Bug#3275104: Temporary fix.
         IF LENGTH(l_rate_or_payscale_name) > 30 THEN
           l_rate_or_payscale_name := SUBSTR(l_rate_or_payscale_name,1,30) ;
         END IF;

      End Loop;

      -- To get Pay Basis from per_pay_bases
      For C_paybasis_rec in C_rate_paybasis
      Loop
         l_pay_basis := C_paybasis_rec.pay_basis;
         l_element_type_id := C_paybasis_rec.element_type_id;
      End Loop;

    else
     l_rate_or_payscale_id := l_parent_spine_id;


    -- To get payscale_name from Per_Parent_Spines.
    For C_payname_rec in C_payname
    Loop
       l_rate_or_payscale_name := C_payname_rec.name;
    End Loop;

  -- To get Pay basis for this paysacle

    For C_paybasis_rec in C_paybasis
    Loop
       l_pay_basis := C_paybasis_rec.pay_basis;
       l_element_type_id := C_paybasis_rec.element_type_id;
    End Loop;
   end if;

    For Grade_rec in Cpay Loop

     l_grade_id := Grade_rec.grade_id;
     l_grade_step_id := Grade_rec.step_id;
     l_sequence      := Grade_rec.sequence;

  -- Commented out for bug number 3159157
     /*DBMS_SQL.BIND_VARIABLE(v_gcursorid,':ld_grade_id',l_grade_id);

     v_gdummy := DBMS_SQL.EXECUTE(v_gcursorid);

     Loop
        if (DBMS_SQL.FETCH_ROWS(v_gcursorid) = 0) then
           exit;
        end if;

        DBMS_SQL.COLUMN_VALUE(v_gcursorid,1,lh_grade_id);
        DBMS_SQL.COLUMN_VALUE(v_gcursorid,2,l_grade_name);

     End Loop; */

  -- To get grade name from Per_Grades
     For C_grade_rec in C_grade
     Loop
       l_grade_name    := C_grade_rec.name;
     End Loop;

     For C_session_rec in C_session
     Loop
       l_session_date := C_session_rec.effective_date;
     End Loop;

     per_spinal_point_steps_pkg.pop_flds(l_grade_step,
                                         l_session_date,
                                         salary_rec.grade_or_spinal_point_id,
                                         Grade_rec.grade_spine_id);

    l_element_value := fnd_number.canonical_to_number(salary_rec.value);

   INSERT INTO PSB_SALARY_I
   ( BUSINESS_GROUP_ID,
     DATA_EXTRACT_ID,
     SALARY_TYPE      ,
     RATE_OR_PAYSCALE_ID,
     RATE_OR_PAYSCALE_NAME,
     GRADE_ID         ,
     GRADE_NAME       ,
     GRADE_STEP       ,
     SEQUENCE_NUMBER  ,
     MINIMUM_VALUE    ,
     MAXIMUM_VALUE    ,
     MID_VALUE        ,
     ELEMENT_VALUE    ,
     ELEMENT_TYPE_ID  ,
     PAY_BASIS        ,
     EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE,
     LAST_UPDATE_DATE ,
     LAST_UPDATED_BY  ,
     LAST_UPDATE_LOGIN,
     CREATED_BY       ,
     CREATION_DATE    )
   VALUES
   (
     salary_rec.business_group_id,
     p_data_extract_id,
     l_salary_type,
     l_rate_or_payscale_id,
     l_rate_or_payscale_name,
     Grade_rec.grade_id,
     l_grade_name,
     l_grade_step,
     l_sequence,
     l_minimum_value,
     l_maximum_value,
     l_mid_value,
     l_element_value,
     l_element_type_id,
     l_pay_basis,
     salary_rec.effective_start_date,
     d_effective_end_date,
     l_last_update_date,
     l_last_updated_by ,
     l_last_update_login ,
     l_created_by,
     l_creation_date
     );
    end loop;

   elsif salary_rec.rate_type = 'G' then
      l_salary_type := 'RATE';

      l_grade_id := salary_rec.grade_or_spinal_point_id;
      l_rate_or_payscale_id := salary_rec.rate_id;

      -- To get Grade Rate Name from pay_rates
      For C_rate_rec in C_rate
      Loop
         l_rate_or_payscale_name := C_rate_rec.name;

         -- Bug#3275104: Temporary fix.
         IF LENGTH(l_rate_or_payscale_name) > 30 THEN
           l_rate_or_payscale_name := SUBSTR(l_rate_or_payscale_name,1,30) ;
         END IF;
      End Loop;

      -- To get Pay Basis from per_pay_bases
      For C_paybasis_rec in C_rate_paybasis
      Loop
         l_pay_basis := C_paybasis_rec.pay_basis;
         l_element_type_id := C_paybasis_rec.element_type_id;
      End Loop;

     -- To get grade name from Per_Grades
     /*DBMS_SQL.BIND_VARIABLE(v_gcursorid,':ld_grade_id',l_grade_id);

     v_gdummy := DBMS_SQL.EXECUTE(v_gcursorid);

     Loop
        if (DBMS_SQL.FETCH_ROWS(v_gcursorid) = 0) then
           exit;
        end if;
        DBMS_SQL.COLUMN_VALUE(v_gcursorid,1,lh_grade_id);
        DBMS_SQL.COLUMN_VALUE(v_gcursorid,2,l_grade_name);
     End Loop; */

     For C_grade_rec in C_grade
     Loop
       l_grade_name := C_grade_rec.name;
     End Loop;

     l_minimum_value := fnd_number.canonical_to_number(salary_rec.minimum);
     l_maximum_value := fnd_number.canonical_to_number(salary_rec.maximum);
     l_mid_value     := fnd_number.canonical_to_number(salary_rec.mid_value);
     l_element_value := fnd_number.canonical_to_number(salary_rec.value);
     l_sequence      := salary_rec.sequence;

   INSERT INTO PSB_SALARY_I
   ( BUSINESS_GROUP_ID,
     DATA_EXTRACT_ID,
     SALARY_TYPE      ,
     RATE_OR_PAYSCALE_ID,
     RATE_OR_PAYSCALE_NAME,
     GRADE_ID         ,
     GRADE_NAME       ,
     GRADE_STEP       ,
     SEQUENCE_NUMBER  ,
     MINIMUM_VALUE    ,
     MAXIMUM_VALUE    ,
     MID_VALUE        ,
     ELEMENT_VALUE    ,
     ELEMENT_TYPE_ID  ,
     PAY_BASIS        ,
     EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE,
     LAST_UPDATE_DATE ,
     LAST_UPDATED_BY  ,
     LAST_UPDATE_LOGIN,
     CREATED_BY       ,
     CREATION_DATE    )
   VALUES
   (
     p_business_group_id,
     p_data_extract_id,
     l_salary_type,
     l_rate_or_payscale_id,
     l_rate_or_payscale_name,
     l_grade_id,
     l_grade_name,
     l_grade_step,
     l_sequence,
     l_minimum_value,
     l_maximum_value,
     l_mid_value,
     l_element_value,
     l_element_type_id,
     l_pay_basis ,
     salary_rec.effective_start_date,
     d_effective_end_date,
     l_last_update_date,
     l_last_updated_by ,
     l_last_update_login ,
     l_created_by,
     l_creation_date
     );
   end if;

   if (l_salary_ctr = PSB_WS_ACCT1.g_checkpoint_save) then
      Update_Reentry
      ( p_api_version              => 1.0  ,
        p_return_status            => l_return_status,
        p_msg_count                => l_msg_count,
        p_msg_data                 => l_msg_data,
        p_data_extract_id          => p_data_extract_id,
        p_extract_method           => p_extract_method,
        p_process                  => 'Salary Interface',
        p_restart_id               => salary_rec.grade_rule_id
       );

       if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          raise FND_API.G_EXC_ERROR;
       end if;
      commit work;
      l_salary_ctr := 0;
      Savepoint Get_Salary;
   end if;
  END LOOP;


  Update_Reentry
  ( p_api_version              => 1.0  ,
    p_return_status            => l_return_status,
    p_msg_count                => l_msg_count,
    p_msg_data                 => l_msg_data,
    p_data_extract_id          => p_data_extract_id,
    p_extract_method           => p_extract_method,
    p_process                  => 'Salary Interface',
    p_restart_id               => l_fin_graderule_id
   );

   if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      raise FND_API.G_EXC_ERROR;
   end if;

  Reentrant_Process
  ( p_api_version              => 1.0  ,
    p_return_status            => l_return_status,
    p_msg_count                => l_msg_count,
    p_msg_data                 => l_msg_data,
    p_data_extract_id          => p_data_extract_id,
    p_extract_method           => p_extract_method,
    p_process                  => 'Salary Interface'
  );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     raise FND_API.G_EXC_ERROR;
  end if;

  commit work;
  end if;

  -- End of API body.

EXCEPTION

   when FND_API.G_EXC_ERROR then

     rollback to Get_Salary;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                 p_data  => p_msg_data);
     message_token('SALARY_TYPE',l_salary_type );
     message_token('RATE_OR_PAYSCALE_NAME',l_rate_or_payscale_name );
     message_token('GRADE_NAME',l_grade_name );
     message_token('GRADE_STEP',l_grade_step );
     message_token('GRADE_SEQUENCE',l_sequence);
     add_message('PSB', 'PSB_SALARY_DETAILS');

   when FND_API.G_EXC_UNEXPECTED_ERROR then

     rollback to Get_Salary;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                 p_data  => p_msg_data);
     message_token('SALARY_TYPE',l_salary_type );
     message_token('RATE_OR_PAYSCALE_NAME',l_rate_or_payscale_name );
     message_token('GRADE_NAME',l_grade_name );
     message_token('GRADE_STEP',l_grade_step );
     message_token('GRADE_SEQUENCE',l_sequence);
     add_message('PSB', 'PSB_SALARY_DETAILS');

   when OTHERS then

     rollback to Get_Salary;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                 p_data  => p_msg_data);

     message_token('SALARY_TYPE',l_salary_type );
     message_token('RATE_OR_PAYSCALE_NAME',l_rate_or_payscale_name );
     message_token('GRADE_NAME',l_grade_name );
     message_token('GRADE_STEP',l_grade_step );
     message_token('GRADE_SEQUENCE',l_sequence);
     add_message('PSB', 'PSB_SALARY_DETAILS');

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
          (p_pkg_name => G_PKG_NAME,
           p_procedure_name => l_api_name);
     end if;

END Get_Salary_Information;

PROCEDURE Get_Employee_Information
( p_api_version         IN    NUMBER,
  p_init_msg_list	IN    VARCHAR2 := FND_API.G_FALSE,
  p_commit	    	IN    VARCHAR2 := FND_API.G_FALSE,
  p_validation_level	IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT   NOCOPY VARCHAR2,
  p_msg_count           OUT   NOCOPY NUMBER,
  p_msg_data            OUT   NOCOPY VARCHAR2,
  p_data_extract_id     IN    NUMBER,
  -- de by org
  p_extract_by_org      IN    VARCHAR2,
  p_extract_method      IN    VARCHAR2,
  p_date                IN    DATE,
  p_business_group_id   IN    NUMBER,
  p_set_of_books_id     IN    NUMBER,
  p_copy_defaults_flag  IN    VARCHAR2,
  p_copy_salary_flag    IN    VARCHAR2
) AS

    l_last_update_date    date;
    l_last_updated_by     number;
    l_last_update_login   number;
    l_creation_date       date;
    l_created_by          number;
    l_session_date        date;
    l_restart_assignment_id number := 0;
    l_process_flag        varchar2(1);
    l_hr_position_id      number;
    l_hr_employee_id      number;
    l_assign_ctr          number := 0;
    l_rate_cnt_flag       varchar2(1);
    l_dummy               number;
    l_salary_type          varchar2(15);
    l_rate_or_payscale_id number;
    l_grade_step          number;
    l_grade_spine_id      number;
    l_grade_id            number;
    l_sequence            number;
    l_parent_spine_id     number;
    l_spinal_point_id     number;
    l_step_id             number;
    l_rate_id             number;
    l_rate_type           varchar2(10);
    l_element_value       number;
    l_parent_spine_name   varchar2(80);
    l_proposed_salary     number;
    l_change_date         date;
    l_assignment_id       number;
    l_position_name       varchar2(240);
    --UTF8 changes for Bug No : 2615261
    l_employee_name       varchar2(310);
    l_rate_flag           varchar2(1) := 'N';
    l_status              varchar2(1);
    l_return_status       varchar2(1);
    l_msg_count           number;
    l_msg_data            varchar2(1000);
    l_assignment_status_type_id   number;
    l_assign_stat_cnt             number := 0;

    Cursor C_rate_check is
    Select count(*), parent_spine_id
      from pay_rates
     where business_group_id = p_business_group_id
     -- Start bug no 3902996
       and parent_spine_id = l_parent_spine_id
     -- End bug no 3902996
       and rate_type = 'SP'
     group by parent_spine_id
     having count(*) > 1;

    Cursor C2 is
         Select pp.business_group_id,
                /* Start bug #4128475 */
                --pp.name,
                pp.hr_position_name,
                /* End bug #4128475 */
                pp.hr_position_id,
                paf.assignment_id,
                paf.primary_flag,
                paf.assignment_status_type_id,
                paf.person_id,
                paf.organization_id,
                paf.grade_id,
                paf.job_id,
                paf.payroll_id,
                paf.people_group_id,
                paf.normal_hours,
                paf.frequency,
                paf.set_of_books_id,
                ppf.employee_number,
                ppf.first_name,
                ppf.full_name,
                ppf.known_as,
                ppf.last_name,
                ppf.middle_names,
                ppf.title,
                /*For Bug No : 2594575 Start*/
                --Stop extracting secured data of employee
                --Removed the columns in psb_employees table
                /*For Bug No : 2594575 End*/
                ppf.effective_start_date,
                ppb.pay_basis,
                ppb.rate_basis,
                ppb.rate_id
          FROM  fnd_sessions fs,
                /* Start bug #4128475 */
                -- psb_positions,
                psb_positions_i pp,
                /* End bug #4128475 */
                per_all_assignments_f paf,
                per_all_people_f ppf,
                pay_all_payrolls_f ppay,
                per_pay_bases ppb
          WHERE fs.session_id = userenv('sessionid')
            AND fs.effective_date between paf.effective_start_date and paf.effective_end_date
            AND pp.data_extract_id = p_data_extract_id
            AND pp.hr_position_id     = paf.position_id
            AND pp.hr_employee_id     = paf.person_id
            AND paf.assignment_id    > l_restart_assignment_id
            AND pp.business_group_id = p_business_group_id
                and FS.EFFECTIve_date between ppf.effective_start_date
            AND ppf.effective_end_date
            AND paf.person_id     = ppf.person_id
            AND fs.effective_date between ppay.effective_start_date
            AND ppay.effective_end_date
            AND paf.payroll_id    = ppay.payroll_id
            AND ppay.gl_set_of_books_id = p_set_of_books_id
            AND paf.pay_basis_id  = ppb.pay_basis_id
            AND paf.assignment_type = 'E'
            /*For Bug No : 2109120 Start*/
            --AND paf.primary_flag = 'Y'
            /*For Bug No : 2109120 End*/

        -- de by org

        -- The following logic is used to restrict the positions for all the
	-- selected organizations, if extract by org is enabled.
        -- Otherwise, we will ignore the organizations available
        -- in the business group.

            AND (p_extract_by_org = 'N' OR
                (p_extract_by_org = 'Y' and pp.organization_id in
	           (select organization_id
	             from psb_data_extract_orgs
	            where data_extract_id = p_data_extract_id
	              and select_flag = 'Y')))
            ORDER BY paf.assignment_id;

   Cursor C_prop_sal is
    Select nvl(proposed_salary_n,0) proposed_salary,
           change_date
      from per_pay_proposals
     where assignment_id = l_assignment_id
       and change_date =
           (select max(change_date) from
            per_pay_proposals where
            assignment_id = l_assignment_id
            and approved = 'Y');

  Cursor C_step is
         Select step_id
           from Per_spinal_pt_placements_v
          where assignment_id = l_assignment_id;

  Cursor C_grade_spine is
        SELECT pss.grade_spine_id,pss.spinal_point_id,
               pss.sequence
          FROM per_spinal_pt_placements_v psp, per_spinal_point_steps pss
         WHERE psp.step_id = pss.step_id
           AND psp.assignment_id = l_assignment_id;

  Cursor C_session is
       SELECT effective_date
         FROM FND_SESSIONS
        WHERE session_id = USERENV('sessionid');

  Cursor C_grade is
        SELECT pgs.grade_id,pgs.parent_spine_id,
               pps.name
          FROM per_grade_spines pgs, per_parent_spines pps
         WHERE grade_spine_id = l_grade_spine_id
           and pgs.parent_spine_id = pps.parent_spine_id;

  /* Commented out and changed to enhance performance 23-NOV-2002*/
  /*Cursor C_grade_rate is
	 SELECT rate_id
	   FROM PAY_GRADE_RULES
	  WHERE GRADE_OR_SPINAL_POINT_ID = l_grade_id
	    and rate_type = l_rate_type; */

  Cursor C_grade_rate is
	 SELECT rate_or_payscale_id
	   FROM PSB_SALARY_I
	  WHERE GRADE_ID = l_grade_id
	    and SALARY_TYPE = l_salary_type;

  /* Start bug No 3902996 */
  CURSOR C_grade_rate_step
  IS
  SELECT rate_or_payscale_id
  FROM PSB_SALARY_I
  WHERE GRADE_ID = l_grade_id
  AND SALARY_TYPE = l_salary_type
  AND grade_step = l_grade_step;
  /* End bug no 3902996 */


  Cursor C_rate is
         SELECT rate_or_payscale_id,element_value,
                grade_step,sequence_number
          FROM PSB_SALARY_I
          WHERE RATE_OR_PAYSCALE_ID = l_rate_id
            AND GRADE_ID            = l_grade_id
            AND SALARY_TYPE         = l_salary_type
            AND DATA_EXTRACT_ID     = p_data_extract_id;

  Cursor C_Value is
         SELECT element_value
           FROM PSB_SALARY_I
          WHERE RATE_OR_PAYSCALE_ID = l_rate_or_payscale_id
            AND GRADE_ID            = l_grade_id
            AND SALARY_TYPE         = l_salary_type
            AND GRADE_STEP          = l_grade_step
            AND SEQUENCE_NUMBER     = l_sequence
            AND DATA_EXTRACT_ID     = p_data_extract_id;


  Cursor l_dup_asg_cur is
   Select assignment_id
     from psb_employees_i
   where  hr_position_id = l_hr_position_id
     and  hr_employee_id = l_hr_employee_id
     and  data_extract_id = p_data_extract_id;

  --
  -- Cursor to find the list of assignment_status types
  -- that correspond to Terminated Assignment Status
  --

  /* Bug 4929586 commenting out the below cursor
  Cursor l_assign_stat_csr is
   Select assignment_status_type_id
     from per_assignment_status_types
    where (business_group_id = p_business_group_id
       or business_group_id  is null)
      and PER_SYSTEM_STATUS = 'TERM_ASSIGN'; */
  --
  l_api_name		CONSTANT VARCHAR2(30)	:= 'Get_Employee_Information';
  l_api_version         CONSTANT NUMBER 	:= 1.0;

BEGIN

  -- Standard Start of API savepoint

  Savepoint Get_Employee;

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
        	  	    	      p_api_version,
   	       	    	 	      l_api_name,
		    	    	      G_PKG_NAME)
  then
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
       FND_MSG_PUB.initialize;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body

  l_last_update_date := sysdate;
  l_last_updated_by := FND_GLOBAL.USER_ID;
  l_last_update_login :=FND_GLOBAL.LOGIN_ID;
  l_creation_date     := sysdate;
  l_created_by        := FND_GLOBAL.USER_ID;

  Check_Reentry
  (p_api_version              => 1.0  ,
   p_return_status            => l_return_status,
   p_msg_count                => l_msg_count,
   p_msg_data                 => l_msg_data,
   p_data_extract_id          => p_data_extract_id,
   p_process                  => 'Employees Interface',
   p_status                   => l_status,
   p_restart_id               => l_restart_assignment_id
   );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     raise FND_API.G_EXC_ERROR;
  end if;

  if (l_status <> 'C') then


  -- Start Bug No 3902996
 /*l_rate_cnt_flag := 'N';

  For C_rate_check_rec in C_rate_check
  Loop
    l_rate_cnt_flag := 'Y' ;
    exit;
  End Loop; */
  -- End Bug No 3902996

  /* Bug 4929586 commenting out the below code
  assign_stat_types.delete;
  FOR l_assign_stat_rec in l_assign_stat_csr
   Loop
     l_assign_stat_cnt := l_assign_stat_cnt + 1;
     assign_stat_types(l_assign_stat_cnt) := l_assign_stat_rec.assignment_status_type_id;
  End Loop; */
l_assignment_id := 0;

  For employee_rec IN C2 LOOP
    l_assign_ctr          := l_assign_ctr + 1;
    l_assignment_id       := employee_rec.assignment_id;
    l_grade_spine_id      := null;
    l_spinal_point_id     := null;
    l_grade_step          := null;
    l_sequence            := null;
    l_grade_id            := null;
    l_rate_or_payscale_id := null;
    l_parent_spine_id     := null;
    l_element_value       := 0;
    l_proposed_salary     := 0;
    l_salary_type         := null;
    l_rate_type           := null;
    l_rate_id             := null;
    l_step_id             := null;
    l_position_name       := null;
    l_employee_name       := null;
    l_hr_position_id      := null;
    l_hr_employee_id      := null;
    l_hr_position_id      :=  employee_rec.hr_position_id;
    l_hr_employee_id      :=  employee_rec.person_id;
    l_assignment_status_type_id  := null;
    l_assignment_status_type_id := employee_rec.assignment_status_type_id;

    l_process_flag := 'Y';

    /* Bug 4929586
    For k in 1..l_assign_stat_cnt
    Loop
      if (assign_stat_types(k) = l_assignment_status_type_id) then
       l_process_flag := 'N';
      end if;
    End Loop; */

    For l_dup_asg_rec in l_dup_asg_cur
    Loop
       if (employee_rec.primary_flag = 'Y') then
          delete psb_employees_i
           where hr_position_id = l_hr_position_id
            and  hr_employee_id = l_hr_employee_id
            and  data_extract_id = p_data_extract_id;
       else
          l_process_flag := 'N';
       end if;
    End Loop;

   if (l_process_flag = 'Y') then

    l_employee_name := employee_rec.first_name||' '||employee_rec.last_name;

    if (employee_rec.hr_position_id is not null) then
      /* Start bug #4128475 */
      --l_position_name := employee_rec.name;
      l_position_name := employee_rec.hr_position_name;
      /* End bug #4128475 */
    end if;

    l_step_id := null;

    For C_step_rec in C_step
    Loop
        l_step_id := C_step_rec.step_id;
    end loop;

    if l_step_id is not null then
       -- 'Grade Scale' Method is Used
       l_rate_flag := 'N';
       l_salary_type := 'STEP';
       l_rate_type := 'SP';

       For C_grade_spine_rec in C_grade_spine
       Loop
           l_grade_spine_id  := C_grade_spine_rec.grade_spine_id;
           l_spinal_point_id := C_grade_spine_rec.spinal_point_id;
           l_sequence        := C_grade_spine_rec.sequence;
       end loop;

       For C_session_rec in C_session
       Loop
         l_session_date := C_session_rec.effective_date;
       End Loop;

       per_spinal_point_steps_pkg.pop_flds(l_grade_step,
                                           l_session_date,
                                           l_spinal_point_id,
                                           l_grade_spine_id);

      -- Getting Grade_id from per_grade_spines
       For C_grade_rec in C_grade
       Loop
          l_grade_id := C_grade_rec.grade_id;
          l_parent_spine_id := C_grade_rec.parent_spine_id;
          l_parent_spine_name := C_grade_rec.name;
       End Loop;

       -- Start bug no 3902996
       l_rate_cnt_flag := 'N';
       For C_rate_check_rec in C_rate_check
       Loop
         l_rate_cnt_flag := 'Y' ;
         exit;
       End Loop;
       -- End bug no 3902996

       -- Start bug no 3902996
       --l_rate_or_payscale_id := l_parent_spine_id;
       -- End  bug no 3902996

       if (l_rate_cnt_flag = 'Y') then
         -- Start bug no 3902996
         For C_grade_rate_rec in C_grade_rate_step
         Loop
           l_rate_or_payscale_id := C_grade_rate_rec.rate_or_payscale_id;
         end Loop;
         -- End bug no 3902996

         l_element_value := 0;
       else
         -- Start bug no 3902996
         l_rate_or_payscale_id := l_parent_spine_id;
         -- End  bug no 3902996

       For C_Value_Rec in C_value
       Loop
         l_element_value := C_value_rec.element_value;
       End Loop;
      end if; -- Multiple Rates for single payscale condition

    end if;

    if (l_step_id is null) then
       l_salary_type := 'RATE';
       l_grade_id    :=  employee_rec.grade_id;
       l_rate_type   := 'G';

       For C_grade_rate_rec in C_grade_rate
       Loop
           l_rate_id := C_grade_rate_rec.rate_or_payscale_id;
       End Loop;

       For C_rate_rec in C_rate
       Loop
       -- Getting rate_id from Psb_salary_i for employee_rec.grade_id
         l_rate_or_payscale_id := C_rate_rec.rate_or_payscale_id;
         l_element_value       := C_rate_rec.element_value;
         l_grade_step          := C_rate_rec.grade_step;
         l_sequence            := C_rate_rec.sequence_number;
       End Loop;

     end if;

   -- Getting proposed salary for the employee
   For C_prop_sal_rec in C_prop_sal
   Loop
      l_proposed_salary := C_prop_sal_rec.proposed_salary;
      l_change_date     := C_prop_sal_rec.change_date;
   End Loop;

   if (l_proposed_salary = 0) then
        l_proposed_salary := l_element_value;
        l_change_date     := employee_rec.effective_start_date;
   end if;

   /*For Bug No : 2594575 Start*/
   --Stop extracting secured data of employee
   --Removed the columns in psb_employees table
   /*For Bug No : 2594575 End*/

   INSERT INTO PSB_EMPLOYEES_I
   (HR_EMPLOYEE_ID         ,
    HR_POSITION_ID         ,
    ASSIGNMENT_ID     ,
    GRADE_ID          ,
    GRADE_STEP        ,
    SEQUENCE_NUMBER   ,
    PAY_BASIS         ,
    RATE_ID           ,
    FIRST_NAME        ,
    FULL_NAME         ,
    KNOWN_AS          ,
    LAST_NAME         ,
    MIDDLE_NAMES      ,
    TITLE             ,
    BUSINESS_GROUP_ID ,
    EFFECTIVE_START_DATE,
    SET_OF_BOOKS_ID,
    SALARY_TYPE ,
    RATE_OR_PAYSCALE_ID,
    ELEMENT_VALUE      ,
    PROPOSED_SALARY    ,
    CHANGE_DATE        ,
    EMPLOYEE_NUMBER    ,
    LAST_UPDATE_DATE   ,
    LAST_UPDATED_BY    ,
    LAST_UPDATE_LOGIN  ,
    CREATED_BY         ,
    CREATION_DATE      ,
    DATA_EXTRACT_ID    )
    VALUES
    (
     employee_rec.person_id,
     employee_rec.hr_position_id,
     employee_rec.assignment_id,
     employee_rec.grade_id,
     l_grade_step,
     l_sequence,
     employee_rec.pay_basis,
     employee_rec.rate_id,
     employee_rec.first_name,
     employee_rec.full_name,
     employee_rec.known_as,
     employee_rec.last_name,
     employee_rec.middle_names,
     employee_rec.title,
     employee_rec.business_group_id,
     employee_rec.effective_start_date,
     employee_rec.set_of_books_id,
     l_salary_type,
     l_rate_or_payscale_id,
     l_element_value,
     l_proposed_salary,
     l_change_date,
     employee_rec.employee_number,
     l_last_update_date,
     l_last_updated_by ,
     l_last_update_login ,
     l_created_by,
     l_creation_date,
     p_data_extract_id
     );

    if (l_assign_ctr =  PSB_WS_ACCT1.g_checkpoint_save) then
        Update_Reentry
        ( p_api_version              => 1.0  ,
          p_return_status            => l_return_status,
          p_msg_count                => l_msg_count,
          p_msg_data                 => l_msg_data,
          p_data_extract_id          => p_data_extract_id,
          p_extract_method           => p_extract_method,
          p_process                  => 'Employees Interface',
          p_restart_id               => employee_rec.assignment_id
        );

       if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          raise FND_API.G_EXC_ERROR;
       end if;

       commit work;
       l_assign_ctr := 0;
       Savepoint Get_Employee;
     end if;
    end if;


  END LOOP;

  Update_Reentry
  ( p_api_version              => 1.0  ,
    p_return_status            => l_return_status,
    p_msg_count                => l_msg_count,
    p_msg_data                 => l_msg_data,
    p_data_extract_id          => p_data_extract_id,
    p_extract_method           => p_extract_method,
    p_process                  => 'Employees Interface',
    p_restart_id               => l_assignment_id
   );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     raise FND_API.G_EXC_ERROR;
  end if;

  Reentrant_Process
  ( p_api_version              => 1.0  ,
    p_return_status            => l_return_status,
    p_msg_count                => l_msg_count,
    p_msg_data                 => l_msg_data,
    p_data_extract_id          => p_data_extract_id,
    p_extract_method           => p_extract_method,
    p_process                  => 'Employees Interface'
  );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     raise FND_API.G_EXC_ERROR;
  end if;

  commit work;
  end if;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Get_Employee;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                 p_data  => p_msg_data);
     message_token('POSITION_NAME',l_position_name );
     message_token('EMPLOYEE_NAME',l_employee_name );
     add_message('PSB', 'PSB_POSITION_DETAILS');

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Get_Employee;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     message_token('POSITION_NAME',l_position_name );
     message_token('EMPLOYEE_NAME',l_employee_name );
     add_message('PSB', 'PSB_POSITION_DETAILS');
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                 p_data  => p_msg_data);


   when OTHERS then
     rollback to Get_Employee;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                 p_data  => p_msg_data);
     message_token('POSITION_NAME',l_position_name );
     message_token('EMPLOYEE_NAME',l_employee_name );
     add_message('PSB', 'PSB_POSITION_DETAILS');

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
          (p_pkg_name => G_PKG_NAME,
           p_procedure_name => l_api_name);
     end if;

END Get_Employee_Information;


PROCEDURE Get_Costing_Information
( p_api_version         IN    NUMBER,
  p_init_msg_list	IN    VARCHAR2 := FND_API.G_FALSE,
  p_commit	    	IN    VARCHAR2 := FND_API.G_FALSE,
  p_validation_level	IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT   NOCOPY VARCHAR2,
  p_msg_count           OUT   NOCOPY NUMBER,
  p_msg_data            OUT   NOCOPY VARCHAR2,
  p_data_extract_id     IN    NUMBER,
  -- de by org
  p_extract_by_org      IN    VARCHAR2,
  p_extract_method      IN    VARCHAR2,
  p_date                IN    DATE,
  p_business_group_id   IN    NUMBER,
  p_set_of_books_id     IN    NUMBER
) AS

  l_last_update_date    date;
  l_last_updated_by     number;
  l_last_update_login   number;
  l_creation_date       date;
  l_created_by          number;
  l_position_name       varchar2(240);
  --UTF8 changes for Bug No : 2615261
  l_employee_name       varchar2(310);

  l_index        BINARY_INTEGER;
  l_cost_segments g_glcostmap_tbl_type;
  l_restart_payroll_id NUMBER := 0;
  loop_ctr       NUMBER := 0;
  loop1_ctr      NUMBER := 0;

  /* Bug#4958997 Start*/
  l_yes          VARCHAR2(1)  := 'Y';
  l_no           VARCHAR2(1)  := 'N';
  /* Bug#4958997 End*/

  /* Start bug #4924031 */
  l_id_flex_code    fnd_id_flex_structures.id_flex_code%TYPE;
  l_application_id  fnd_id_flex_structures.application_id%TYPE;
  l_yes_flag        VARCHAR2(1);
  /* End bug #4924031 */



  /*  Bug#4958997 Start:
      The following logic is used in both queries in Cursor C4 to restrict the positions
      for all the selected organizations, if extract by org is enabled. Otherwise, we will
      ignore the organizations avaiable in the business group.

      AND  (p_extract_by_org = l_no
            OR
	      (p_extract_by_org = l_yes and paf.organization_id in
                (select organization_id
                 from psb_data_extract_orgs
                 where data_extract_id = p_data_extract_id
                 and select_flag = l_yes)))

  */

  Cursor C4 is
    Select paf.assignment_id,
           paf.position_id,
           paf.person_id,
           paf.business_group_id,
           paf.payroll_id,
           pcaf.proportion,
           paf.organization_id,
           paf.pay_basis_id,
           pcaf.cost_allocation_keyflex_id,
           pcaf.effective_start_date,
           pcaf.effective_end_date
      from fnd_sessions fs, per_all_assignments_f paf,
           pay_cost_allocations_f pcaf,
           pay_cost_allocation_keyflex pcak
   where   fs.session_id = userenv('sessionid')
     and   fs.effective_date between paf.effective_start_date and paf.effective_end_date
     and   fs.effective_date between pcaf.effective_start_date and pcaf.effective_end_date   --bug:8244183:added the condition
     and   paf.business_group_id = p_business_group_id
     and   paf.payroll_id > l_restart_payroll_id
     and   paf.assignment_id = pcaf.assignment_id
     and   pcaf.cost_allocation_keyflex_id
           = pcak.cost_allocation_keyflex_id
     AND  (p_extract_by_org = l_no OR
	      (p_extract_by_org = l_yes and paf.organization_id in
	         (select organization_id
	           from psb_data_extract_orgs
	          where data_extract_id = p_data_extract_id
	           and select_flag = l_yes)))

    union all
    Select paf.assignment_id,
           paf.position_id,
           paf.person_id,
           paf.business_group_id,
           paf.payroll_id,
           to_number(null),
           paf.organization_id,
           paf.pay_basis_id,
           to_number(null),
           to_date(null),
           to_date(null)
      from fnd_sessions fs, per_all_assignments_f paf
   where   fs.session_id = userenv('sessionid')
     and   fs.effective_date between paf.effective_start_date and paf.effective_end_date
     and   paf.business_group_id = p_business_group_id
     and   paf.payroll_id > l_restart_payroll_id
     and   not exists (select 1
           from pay_cost_allocations_f pcax
           where pcax.assignment_id = paf.assignment_id
           and fs.session_id = userenv('sessionid')
     and   fs.effective_date between pcax.effective_start_date and pcax.effective_end_date)
     AND  (p_extract_by_org = l_no OR
	       (p_extract_by_org = l_yes and paf.organization_id in
	          (select organization_id
	            from psb_data_extract_orgs
	           where data_extract_id = p_data_extract_id
	            and select_flag = l_yes)))

    order by  1,2;

    /* Bug#4958997 End */

    l_chart_of_accounts_id       NUMBER;
    l_payroll_id NUMBER;
    le_payroll_id NUMBER;
    le_assignment_id NUMBER;
    le_position_id NUMBER;
    le_organization_id NUMBER;
    le_pay_basis_id NUMBER;
    le_element_type_id NUMBER;
    l_costing_level varchar2(20);
    prev_payroll_id NUMBER := 0;
    prev_assignment_id NUMBER := 0;
    l_status   varchar2(1);
    l_return_status  varchar2(1);
    l_msg_count      number;
    l_msg_data       varchar2(1000);

   Cursor C_Assign_Check is
      Select assignment_id,
             first_name,
             last_name
        from PSB_EMPLOYEES_I
       where hr_position_id = le_position_id
         and assignment_id =  le_assignment_id
         and data_extract_id = p_data_extract_id;

    Cursor C11 is
      SELECT gl_account_segment,payroll_cost_segment
        FROM pay_payroll_gl_flex_maps
       WHERE payroll_id = l_payroll_id
         AND gl_set_of_books_id = p_set_of_books_id
         AND gl_account_segment in
        ( SELECT application_column_name
            FROM fnd_id_flex_segments_vl
           WHERE id_flex_code = l_id_flex_code      -- bug #4924031
             AND application_id = l_application_id  -- bug #4924031
             AND enabled_flag = l_yes_flag          -- bug #4924031
             AND id_flex_num = l_chart_of_accounts_id )
             ORDER BY gl_account_segment;

   Cursor C_chart is
     Select chart_of_accounts_id
       from gl_sets_of_books
      where set_of_books_id = p_set_of_books_id;

   Cursor C_payroll is
     Select pay.cost_allocation_keyflex_id ,
            pay.effective_start_date,
            pay.effective_end_date
       from pay_all_payrolls pay, pay_cost_allocation_keyflex pcak
      where pay.payroll_id = le_payroll_id
        and pay.cost_allocation_keyflex_id = pcak.cost_allocation_keyflex_id;


   Cursor C_Pay_basis is
     Select element_type_id
       from pay_input_values piv,
            per_pay_bases ppb
      where ppb.pay_basis_id = le_pay_basis_id
        and piv.input_value_id = ppb.input_value_id;

   Cursor C_Element is
     Select pel.cost_allocation_keyflex_id ,
            pel.effective_start_date,
            pel.effective_end_date
       from Pay_element_entries pee,Pay_element_links pel,
            pay_cost_allocation_keyflex pcak, Pay_element_types pet
      where pee.assignment_id   = le_assignment_id
        and pee.element_link_id = pel.element_link_id
        and pel.element_type_id = pet.element_type_id
        and pet.element_type_id = le_element_type_id
        and pel.cost_allocation_keyflex_id = pcak.cost_allocation_keyflex_id;

   Cursor C_Org is
     Select hru.cost_allocation_keyflex_id ,
            hru.date_from,
            hru.date_to
       from hr_organization_units hru, pay_cost_allocation_keyflex pcak
      where hru.organization_id =  le_organization_id
        and hru.cost_allocation_keyflex_id = pcak.cost_allocation_keyflex_id;

    Cursor C_Segcount is
     SELECT count(*) seg_count
       FROM fnd_id_flex_segments_vl
      WHERE id_flex_code = l_id_flex_code      -- bug #4924031
        AND application_id = l_application_id  -- bug #4924031
        AND enabled_flag = l_yes_flag          -- bug #4924031
        AND id_flex_num  = l_chart_of_accounts_id;

   Cursor C_ld_payroll is
    select 'exists'
      from psb_ld_payroll_maps
     where data_extract_id = p_data_extract_id;

   Cursor C_psp is
      Select nvl(effective_start_date,p_date) effective_start_date
        from psb_ld_payroll_maps plp
       where plp.payroll_id             = le_payroll_id
         and plp.data_extract_id        = p_data_extract_id;

   l_proportion NUMBER;
   l_exists     VARCHAR2(1);
   l_psp_flag   VARCHAR2(1);
   l_payroll_start_date   DATE;
   l_count      NUMBER;
   cost_ctr number := 0;

   l_api_name		CONSTANT VARCHAR2(30)	:= 'Get_Costing_Information';
   l_api_version        CONSTANT NUMBER 	:= 1.0;

BEGIN

  -- Standard Start of API savepoint

  Savepoint Get_Costing;

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
            	    	    	      p_api_version,
   	       	    	 	      l_api_name,
		    	    	      G_PKG_NAME)
  then
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
     FND_MSG_PUB.initialize;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body

  /* Start bug #4924031 */
  l_id_flex_code    := 'GL#';
  l_application_id  := 101;
  l_yes_flag        := 'Y';
  /* End bug #4924031 */

  l_last_update_date := sysdate;
  l_last_updated_by := FND_GLOBAL.USER_ID;
  l_last_update_login :=FND_GLOBAL.LOGIN_ID;
  l_creation_date     := sysdate;
  l_created_by        := FND_GLOBAL.USER_ID;

  Check_Reentry
  (p_api_version              => 1.0  ,
   p_return_status            => l_return_status,
   p_msg_count                => l_msg_count,
   p_msg_data                 => l_msg_data,
   p_data_extract_id          => p_data_extract_id,
   p_process                  => 'Costing Interface',
   p_status                   => l_status,
   p_restart_id               => l_restart_payroll_id
   );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     raise FND_API.G_EXC_ERROR;
  end if;

  if (l_status <> 'C') then

  For C_chart_rec in C_chart
  Loop
    l_chart_of_accounts_id := C_chart_rec.chart_of_accounts_id;
  End Loop;

  for C_Seg_Count_Rec in C_Segcount
  Loop
    l_count := C_Seg_Count_Rec.seg_count;
  End Loop;

  For cost_rec in C4 LOOP
    loop1_ctr := loop1_ctr + 1;
    le_payroll_id    := cost_rec.payroll_id;
    le_position_id   := cost_rec.position_id;
    le_assignment_id := cost_rec.assignment_id;

    For C_Assign_Rec in C_Assign_Check
    Loop

    le_organization_id := cost_rec.organization_id;
    le_pay_basis_id := cost_rec.pay_basis_id;
    l_position_name := null;
    l_employee_name := null;


    if (cost_rec.person_id is not null) then
        l_employee_name := C_Assign_Rec.first_name||C_Assign_Rec.last_name;
    end if;

    if (cost_rec.position_id is not null) then
       For Pos_Name_Rec in G_Position_Details(p_position_id => cost_rec.position_id)
       Loop
         l_position_name := Pos_Name_Rec.name;
       End Loop;
    end if;

    if (le_payroll_id <> prev_payroll_id)  then

       /* Update Reentry */
        Update_Reentry
        ( p_api_version              => 1.0  ,
          p_return_status            => l_return_status,
          p_msg_count                => l_msg_count,
          p_msg_data                 => l_msg_data,
          p_data_extract_id          => p_data_extract_id,
          p_extract_method           => p_extract_method,
          p_process                  => 'Costing Interface',
          p_restart_id               => prev_payroll_id
        );

        if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           raise FND_API.G_EXC_ERROR;
        end if;
        commit work;
        Savepoint Get_Costing;

      l_psp_flag := FND_API.G_FALSE;
      l_payroll_start_date := '';

      For C_psp_rec in C_psp
      Loop
       l_psp_flag := FND_API.G_TRUE;
       l_payroll_start_date := C_psp_rec.effective_start_date;
      End Loop;
    end if;

    For C_pay_rec in C_Pay_basis
    Loop
      le_element_type_id := C_pay_rec.element_type_id;
    End Loop;

    if not (FND_API.TO_BOOLEAN(l_psp_flag)) then
    If (cost_rec.payroll_id <> prev_payroll_id) then
        loop_ctr := 0;
        l_index := 0;
        l_payroll_id := cost_rec.payroll_id;
    For Cost_seg_rec in C11
    Loop
      l_index := l_index + 1;
      l_cost_segments(l_index).gl_account_segment := Cost_seg_rec.gl_account_segment;
      l_cost_segments(l_index).payroll_cost_segment := Cost_seg_rec.payroll_cost_segment;
      loop_ctr := loop_ctr+1;

     End Loop;
   end if;

   if (loop_ctr = l_count) then
      if (cost_rec.cost_allocation_keyflex_id is not null) then
      insert_cost_distribution_row(p_assignment_id => cost_rec.assignment_id,
                    p_cost_keyflex_id => cost_rec.cost_allocation_keyflex_id,
                    p_business_group_id => p_business_group_id,
                    p_costing_level => 'ASSIGNMENT',
                    p_index         => l_index,
                    p_proportion    => cost_rec.proportion,
                    p_start_date    => cost_rec.effective_start_date,
                    p_end_date      => cost_rec.effective_end_date,
                    p_data_extract_id => p_data_extract_id,
                    p_cost_segments   => l_cost_segments,
                    p_chart_of_accounts_id => l_chart_of_accounts_id);
     end if;

   if (cost_rec.assignment_id <> prev_assignment_id) then
   Begin

   For C_payroll_rec in C_payroll
   Loop
   insert_cost_distribution_row(p_assignment_id => cost_rec.assignment_id,
                p_cost_keyflex_id   => C_payroll_rec.cost_allocation_keyflex_id,
                p_business_group_id => p_business_group_id,
                p_costing_level     => 'PAYROLL',
                p_index             => l_index,
                p_proportion        => 0,
                p_start_date        => C_payroll_rec.effective_start_date,
                p_end_date          => C_payroll_rec.effective_end_date,
                p_data_extract_id   => p_data_extract_id,
                p_cost_segments     => l_cost_segments,
                p_chart_of_accounts_id => l_chart_of_accounts_id);
   End Loop;

 end;

 Begin
   For C_Element_rec in C_Element
   Loop
     insert_cost_distribution_row(p_assignment_id => cost_rec.assignment_id,
              p_cost_keyflex_id    => C_Element_rec.cost_allocation_keyflex_id,
              p_business_group_id  => p_business_group_id,
              p_costing_level      => 'ELEMENT LINK',
              p_index              => l_index,
              p_proportion         => 0,
              p_start_date         => C_Element_rec.effective_start_date,
              p_end_date           => C_Element_rec.effective_end_date,
              p_data_extract_id    => p_data_extract_id,
              p_cost_segments      => l_cost_segments,
              p_chart_of_accounts_id => l_chart_of_accounts_id);
   End Loop;
 end;

 Begin
   For C_org_rec in C_org
   Loop

     insert_cost_distribution_row(p_assignment_id => cost_rec.assignment_id,
             p_cost_keyflex_id    => C_org_rec.cost_allocation_keyflex_id,
             p_business_group_id  => p_business_group_id,
             p_costing_level      => 'ORGANIZATION',
             p_index              => l_index,
             p_proportion         => 0,
             p_start_date         => C_org_rec.date_from,
             p_end_date           => C_org_rec.date_to,
             p_data_extract_id    => p_data_extract_id,
             p_cost_segments      => l_cost_segments,
             p_chart_of_accounts_id => l_chart_of_accounts_id);
  End Loop;

  end;

 end if;
 end if;
 else

   Get_LD_Schedule
  ( p_api_version           => 1.0,
    p_init_msg_list	    => FND_API.G_FALSE,
    p_commit	    	    => FND_API.G_FALSE,
    p_validation_level	    => FND_API.G_VALID_LEVEL_FULL,
    p_return_status  	    => l_return_status,
    p_msg_count             => l_msg_count,
    p_msg_data              => l_msg_data,
    p_assignment_id         => cost_rec.assignment_id,
    p_date                  => l_payroll_start_date,
    p_effective_start_date  => cost_rec.effective_start_date,
    p_effective_end_date    => cost_rec.effective_end_date,
    p_chart_of_accounts_id  => l_chart_of_accounts_id,
    p_data_extract_id       => p_data_extract_id,
    p_business_group_id     => p_business_group_id,
    p_set_of_books_id       => p_set_of_books_id,
    p_mode                  => 'D');

   if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     raise FND_API.G_EXC_ERROR;
   end if;

 end if;

 prev_payroll_id := le_payroll_id;
 prev_assignment_id := cost_rec.assignment_id;
 end loop;
end loop;

 Update_Reentry
 ( p_api_version              => 1.0  ,
   p_return_status            => l_return_status,
   p_msg_count                => l_msg_count,
   p_msg_data                 => l_msg_data,
   p_data_extract_id          => p_data_extract_id,
   p_extract_method           => p_extract_method,
   p_process                  => 'Costing Interface',
   p_restart_id               => prev_payroll_id
 );

 if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
 end if;

 Reentrant_Process
 ( p_api_version              => 1.0  ,
   p_return_status            => l_return_status,
   p_msg_count                => l_msg_count,
   p_msg_data                 => l_msg_data,
   p_data_extract_id          => p_data_extract_id,
   p_extract_method           => p_extract_method,
   p_process                  => 'Costing Interface'
 );

 if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
 end if;

 commit work;
end if;

 -- End of API body.

EXCEPTION
   /* Bug 3677529 commenting out the following exception clauses
   when FND_API.G_EXC_ERROR then
     rollback to Get_Costing;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                 p_data  => p_msg_data);
     message_token('POSITION_NAME',l_position_name );
     message_token('EMPLOYEE_NAME',l_employee_name );
     add_message('PSB', 'PSB_POSITION_DETAILS');

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Get_Costing;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                 p_data  => p_msg_data);
     message_token('POSITION_NAME',l_position_name );
     message_token('EMPLOYEE_NAME',l_employee_name );
     add_message('PSB', 'PSB_POSITION_DETAILS');  */

   when OTHERS then
     rollback to Get_Costing;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                 p_data  => p_msg_data);
     message_token('POSITION_NAME',l_position_name );
     message_token('EMPLOYEE_NAME',l_employee_name );
     add_message('PSB', 'PSB_POSITION_DETAILS');

   if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
          (p_pkg_name => G_PKG_NAME,
           p_procedure_name => l_api_name);
    end if;

END Get_Costing_Information;

PROCEDURE Get_LD_Schedule
  ( p_api_version           IN    NUMBER,
    p_init_msg_list	    IN    VARCHAR2 := FND_API.G_FALSE,
    p_commit	    	    IN    VARCHAR2 := FND_API.G_FALSE,
    p_validation_level	    IN    NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_return_status  	    OUT	  NOCOPY VARCHAR2,
    p_msg_count             OUT   NOCOPY NUMBER,
    p_msg_data              OUT   NOCOPY VARCHAR2,
    p_assignment_id         IN    NUMBER,
    p_date                  IN    DATE,
    p_effective_start_date  IN    DATE,
    p_effective_end_date    IN    DATE,
    p_chart_of_accounts_id  IN    NUMBER,
    p_data_extract_id       IN    NUMBER,
    p_business_group_id     IN    NUMBER,
    p_set_of_books_id       IN    NUMBER,
    p_mode                  IN    VARCHAR2 := 'D')
IS

   l_api_name		    CONSTANT VARCHAR2(30)	:= 'Get_LD_Schedule';
   l_api_version            CONSTANT NUMBER 	        := 1.0;

   l_proc_executed          VARCHAR2(10);
   l_last_update_date       date;
   l_last_updated_by        number;
   l_last_update_login      number;
   l_creation_date          date;
   l_created_by             number;
   l_segment1               varchar2(30);
   l_segment2               varchar2(30);
   l_segment3               varchar2(30);
   l_segment4               varchar2(30);
   l_segment5               varchar2(30);
   l_segment6               varchar2(30);
   l_segment7               varchar2(30);
   l_segment8               varchar2(30);
   l_segment9               varchar2(30);
   l_segment10              varchar2(30);
   l_segment11              varchar2(30);
   l_segment12              varchar2(30);
   l_segment13              varchar2(30);
   l_segment14              varchar2(30);
   l_segment15              varchar2(30);
   l_segment16              varchar2(30);
   l_segment17              varchar2(30);
   l_segment18              varchar2(30);
   l_segment19              varchar2(30);
   l_segment20              varchar2(30);
   l_segment21              varchar2(30);
   l_segment22              varchar2(30);
   l_segment23              varchar2(30);
   l_segment24              varchar2(30);
   l_segment25              varchar2(30);
   l_segment26              varchar2(30);
   l_segment27              varchar2(30);
   l_segment28              varchar2(30);
   l_segment29              varchar2(30);
   l_segment30              varchar2(30);
   l_ld_element_type_id     NUMBER;
   l_return_status          varchar2(1);
   v_gldummy                number;

   Cursor C_Element_Type is
     Select element_type_id
       from fnd_sessions fs, pay_input_values piv,
            per_pay_bases ppb,
            per_all_assignments_f paf
      where fs.session_id = userenv('sessionid')
        and fs.effective_date between paf.effective_start_date and paf.effective_end_date
        and paf.assignment_id = p_assignment_id
        and ppb.pay_basis_id  = paf.pay_basis_id
        and piv.input_value_id = ppb.input_value_id;

   tf    BOOLEAN;
   nsegs NUMBER;
   segs  FND_FLEX_EXT.SegmentArray;
   r     VARCHAR2(500);

BEGIN

  -- Standard Start of API savepoint

  Savepoint Get_LD_Schedule;

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
            	    	    	      p_api_version,
   	       	    	 	      l_api_name,
		    	    	      G_PKG_NAME)
  then
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
     FND_MSG_PUB.initialize;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body
  l_last_update_date := sysdate;
  l_last_updated_by := FND_GLOBAL.USER_ID;
  l_last_update_login :=FND_GLOBAL.LOGIN_ID;
  l_creation_date     := sysdate;
  l_created_by        := FND_GLOBAL.USER_ID;

  -- To obtain the element_type_id associated to the assignment

  For C_Element_Type_Rec in C_Element_Type
  Loop
      l_ld_element_type_id := C_Element_Type_Rec.element_type_id;
  End Loop;

  -- Call LD API to get the set of distributions for the
  -- assignment valid on p_date

  PSP_LABOR_DIST.Get_Distribution_Lines
    (p_proc_executed => l_proc_executed,
     p_person_id => null,
     p_sub_line_id => null,
     p_assignment_id => p_assignment_id,
     p_element_type_id => l_ld_element_type_id,
     p_payroll_start_date => p_date,
     p_daily_rate => 100,
     p_effective_date => p_date,
     p_mode => p_mode,
     p_business_group_id => p_business_group_id,
     p_set_of_books_id => p_set_of_books_id,
     p_return_status => l_return_status);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     raise FND_API.G_EXC_ERROR;
  end if;

   For i in 1..PSP_LABOR_DIST.g_num_dist
   Loop
     l_segment1   := null;
     l_segment2   := null;
     l_segment3   := null;
     l_segment4   := null;
     l_segment5   := null;
     l_segment6   := null;
     l_segment7   := null;
     l_segment8   := null;
     l_segment9   := null;
     l_segment10  := null;
     l_segment11  := null;
     l_segment12  := null;
     l_segment13  := null;
     l_segment14  := null;
     l_segment15  := null;
     l_segment16  := null;
     l_segment17  := null;
     l_segment18  := null;
     l_segment19  := null;
     l_segment20  := null;
     l_segment21  := null;
     l_segment22  := null;
     l_segment23  := null;
     l_segment24  := null;
     l_segment25  := null;
     l_segment26  := null;
     l_segment27  := null;
     l_segment28  := null;
     l_segment29  := null;
     l_segment30  := null;

    if (PSP_LABOR_DIST.g_charging_instructions(i).gl_code_combination_id is not null)  then
    r   := null;
    tf  := FND_FLEX_EXT.GET_SEGMENTS('SQLGL','GL#',p_chart_of_accounts_id,PSP_LABOR_DIST.g_charging_instructions(i).gl_code_combination_id,nsegs,segs);

    if (tf) then
       r := 'VALID:  ';
       for i in 1..nsegs loop
          r := r|| '(' || segs(i)||')';
           if (i = 1) then
              l_segment1 := segs(i);
           end if;
           if (i = 2) then
              l_segment2 := segs(i);
           end if;
           if (i = 3) then
              l_segment3 := segs(i);
           end if;
           if (i = 4) then
              l_segment4 := segs(i);
           end if;
           if (i = 5) then
              l_segment5 := segs(i);
           end if;
           if (i = 6) then
              l_segment6 := segs(i);
           end if;
           if (i = 7) then
              l_segment7 := segs(i);
           end if;
           if (i = 8) then
              l_segment8 := segs(i);
           end if;
           if (i = 9) then
              l_segment9 := segs(i);
           end if;
           if (i = 10) then
              l_segment10 := segs(i);
           end if;
           if (i = 11) then
              l_segment11 := segs(i);
           end if;
           if (i = 12) then
              l_segment12 := segs(i);
           end if;
           if (i = 13) then
              l_segment13 := segs(i);
           end if;
           if (i = 14) then
              l_segment14 := segs(i);
           end if;
           if (i = 15) then
              l_segment15 := segs(i);
           end if;
           if (i = 16) then
              l_segment16 := segs(i);
           end if;
           if (i = 17) then
              l_segment17 := segs(i);
           end if;
           if (i = 18) then
              l_segment18 := segs(i);
           end if;
           if (i = 19) then
              l_segment19 := segs(i);
           end if;
           if (i = 20) then
              l_segment20 := segs(i);
           end if;
           if (i = 21) then
              l_segment21 := segs(i);
           end if;
           if (i = 22) then
              l_segment22 := segs(i);
           end if;
           if (i = 23) then
              l_segment23 := segs(i);
           end if;
           if (i = 24) then
              l_segment24 := segs(i);
           end if;
           if (i = 25) then
              l_segment25 := segs(i);
           end if;
           if (i = 26) then
              l_segment26 := segs(i);
           end if;
           if (i = 27) then
              l_segment27 := segs(i);
           end if;
           if (i = 28) then
              l_segment28 := segs(i);
           end if;
           if (i = 29) then
              l_segment29 := segs(i);
           end if;
           if (i = 30) then
              l_segment30 := segs(i);
           end if;

        end loop;
        end if;
      end if;

        Insert into psb_cost_distributions_i
               (DATA_EXTRACT_ID              ,
                ASSIGNMENT_ID                ,
                BUSINESS_GROUP_ID            ,
                COSTING_LEVEL                ,
                PROPORTION                   ,
                CHART_OF_ACCOUNTS_ID         ,
                EFFECTIVE_START_DATE         ,
                EFFECTIVE_END_DATE           ,
                SEGMENT1                     ,
                SEGMENT2                     ,
                SEGMENT3                     ,
                SEGMENT4                     ,
                SEGMENT5                     ,
                SEGMENT6                     ,
                SEGMENT7                     ,
                SEGMENT8                     ,
                SEGMENT9                     ,
                SEGMENT10                    ,
                SEGMENT11                    ,
                SEGMENT12                    ,
                SEGMENT13                    ,
                SEGMENT14                    ,
                SEGMENT15                    ,
                SEGMENT16                    ,
                SEGMENT17                    ,
                SEGMENT18                    ,
                SEGMENT19                    ,
                SEGMENT20                    ,
                SEGMENT21                    ,
                SEGMENT22                    ,
                SEGMENT23                    ,
                SEGMENT24                    ,
                SEGMENT25                    ,
                SEGMENT26                    ,
                SEGMENT27                    ,
                SEGMENT28                    ,
                SEGMENT29                    ,
                SEGMENT30                    ,
                LAST_UPDATE_DATE             ,
                LAST_UPDATED_BY              ,
                LAST_UPDATE_LOGIN            ,
                CREATED_BY                   ,
                CREATION_DATE                ,
                PROJECT_ID                   ,
                TASK_ID                      ,
                AWARD_ID                     ,
                EXPENDITURE_TYPE             ,
                EXPENDITURE_ORGANIZATION_ID  ,
                DESCRIPTION                  )
                values
                (
                  p_data_extract_id,
                  p_assignment_id,
                  p_business_group_id,
                  'ASSIGNMENT',
                  --bug 3677529 added nvl function in the following line
                  NVL(PSP_LABOR_DIST.g_charging_instructions(i).percent,0),
                  p_chart_of_accounts_id,
                  PSP_LABOR_DIST.g_charging_instructions(i).effective_start_date,
                  PSP_LABOR_DIST.g_charging_instructions(i).effective_end_date,
                  l_segment1,
                  l_segment2,
                  l_segment3,
                  l_segment4,
                  l_segment5,
                  l_segment6,
                  l_segment7,
                  l_segment8,
                  l_segment9,
                  l_segment10,
                  l_segment11,
                  l_segment12,
                  l_segment13,
                  l_segment14,
                  l_segment15,
                  l_segment16,
                  l_segment17,
                  l_segment18,
                  l_segment19,
                  l_segment20,
                  l_segment21,
                  l_segment22,
                  l_segment23,
                  l_segment24,
                  l_segment25,
                  l_segment26,
                  l_segment27,
                  l_segment28,
                  l_segment29,
                  l_segment30,
                  l_last_update_date,
                  l_last_updated_by,
                  l_last_update_login,
                  l_created_by,
                  l_creation_date,
                  PSP_LABOR_DIST.g_charging_instructions(i).project_id,
                  PSP_LABOR_DIST.g_charging_instructions(i).task_id,
                  PSP_LABOR_DIST.g_charging_instructions(i).award_id,
                  PSP_LABOR_DIST.g_charging_instructions(i).expenditure_type,
                  PSP_LABOR_DIST.g_charging_instructions(i).expenditure_organization_id,
                  PSP_LABOR_DIST.g_charging_instructions(i).description
               );
   End Loop;

  -- End of API body.


EXCEPTION
   /* Bug 3677529 commented out the following exception clauses
   when FND_API.G_EXC_ERROR then
     rollback to Get_LD_Schedule;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                 p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Get_LD_Schedule;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                 p_data  => p_msg_data);
   */

   when OTHERS then
     rollback to Get_LD_Schedule;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                 p_data  => p_msg_data);
    /* Bug 3677529 Start */
    IF FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       FND_MSG_PUB.Add_Exc_Msg
          (p_pkg_name => G_PKG_NAME,
           p_procedure_name => l_api_name);
    END IF;
    /* Bug 3677529 End */
END Get_LD_Schedule;

PROCEDURE insert_cost_distribution_row(
    P_ASSIGNMENT_ID  IN number,
    P_COST_KEYFLEX_ID IN number,
    P_BUSINESS_GROUP_ID  in number,
    P_COSTING_LEVEL  in varchar2,
    P_INDEX          in binary_integer,
    P_PROPORTION     in number,
    P_START_DATE     in date,
    P_END_DATE       in date,
    P_DATA_EXTRACT_ID    in number,
    P_COST_SEGMENTS in g_glcostmap_tbl_type,
    P_CHART_OF_ACCOUNTS_ID in number) AS

    l_last_update_date    date;
    l_last_updated_by     number;
    l_last_update_login   number;
    l_creation_date       date;
    l_created_by          number;
    l_start_date          date;
    l_end_date            date;
    l_percent             number;

    l_segment1            varchar2(30);
    l_segment2            varchar2(30);
    l_segment3            varchar2(30);
    l_segment4            varchar2(30);
    l_segment5            varchar2(30);
    l_segment6            varchar2(30);
    l_segment7            varchar2(30);
    l_segment8            varchar2(30);
    l_segment9            varchar2(30);
    l_segment10           varchar2(30);
    l_segment11           varchar2(30);
    l_segment12           varchar2(30);
    l_segment13           varchar2(30);
    l_segment14           varchar2(30);
    l_segment15           varchar2(30);
    l_segment16           varchar2(30);
    l_segment17           varchar2(30);
    l_segment18           varchar2(30);
    l_segment19           varchar2(30);
    l_segment20           varchar2(30);
    l_segment21           varchar2(30);
    l_segment22           varchar2(30);
    l_segment23           varchar2(30);
    l_segment24           varchar2(30);
    l_segment25           varchar2(30);
    l_segment26           varchar2(30);
    l_segment27           varchar2(30);
    l_segment28           varchar2(30);
    l_segment29           varchar2(30);
    l_segment30           varchar2(30);


 begin

  l_last_update_date := sysdate;
  l_last_updated_by := FND_GLOBAL.USER_ID;
  l_last_update_login :=FND_GLOBAL.LOGIN_ID;
  l_creation_date     := sysdate;
  l_created_by        := FND_GLOBAL.USER_ID;

  l_percent   :=  p_proportion*100;
  l_segment1   := null;
  l_segment2   := null;
  l_segment3   := null;
  l_segment4   := null;
  l_segment5   := null;
  l_segment6   := null;
  l_segment7   := null;
  l_segment8   := null;
  l_segment9   := null;
  l_segment10  := null;
  l_segment11  := null;
  l_segment12  := null;
  l_segment13  := null;
  l_segment14  := null;
  l_segment15  := null;
  l_segment16  := null;
  l_segment17  := null;
  l_segment18  := null;
  l_segment19  := null;
  l_segment20  := null;
  l_segment21  := null;
  l_segment22  := null;
  l_segment23  := null;
  l_segment24  := null;
  l_segment25  := null;
  l_segment26  := null;
  l_segment27  := null;
  l_segment28  := null;
  l_segment29  := null;
  l_segment30  := null;

  For K in 1..p_index loop
    if (p_cost_segments(K).gl_account_segment = 'SEGMENT1') then
       l_segment1 := get_segment_val(p_cost_segments(K).payroll_cost_segment,p_cost_keyflex_id);
    elsif (p_cost_segments(K).gl_account_segment = 'SEGMENT2') then
       l_segment2 := get_segment_val(p_cost_segments(K).payroll_cost_segment,p_cost_keyflex_id);
    elsif (p_cost_segments(K).gl_account_segment = 'SEGMENT3') then
       l_segment3 := get_segment_val(p_cost_segments(K).payroll_cost_segment,p_cost_keyflex_id);
    elsif (p_cost_segments(K).gl_account_segment = 'SEGMENT4') then
       l_segment4 := get_segment_val(p_cost_segments(K).payroll_cost_segment,p_cost_keyflex_id);
    elsif (p_cost_segments(K).gl_account_segment = 'SEGMENT5') then
       l_segment5 := get_segment_val(p_cost_segments(K).payroll_cost_segment,p_cost_keyflex_id);
    elsif (p_cost_segments(K).gl_account_segment = 'SEGMENT6') then
       l_segment6 := get_segment_val(p_cost_segments(K).payroll_cost_segment,p_cost_keyflex_id);
    elsif (p_cost_segments(K).gl_account_segment = 'SEGMENT7') then
       l_segment7 := get_segment_val(p_cost_segments(K).payroll_cost_segment,p_cost_keyflex_id);
    elsif (p_cost_segments(K).gl_account_segment = 'SEGMENT8') then
       l_segment8 := get_segment_val(p_cost_segments(K).payroll_cost_segment,p_cost_keyflex_id);
    elsif (p_cost_segments(K).gl_account_segment = 'SEGMENT9') then
       l_segment9 := get_segment_val(p_cost_segments(K).payroll_cost_segment,p_cost_keyflex_id);
    elsif (p_cost_segments(K).gl_account_segment = 'SEGMENT10') then
       l_segment10 := get_segment_val(p_cost_segments(K).payroll_cost_segment,p_cost_keyflex_id);
    elsif (p_cost_segments(K).gl_account_segment = 'SEGMENT11') then
       l_segment11 := get_segment_val(p_cost_segments(K).payroll_cost_segment,p_cost_keyflex_id);
    elsif (p_cost_segments(K).gl_account_segment = 'SEGMENT12') then
       l_segment12 := get_segment_val(p_cost_segments(K).payroll_cost_segment,p_cost_keyflex_id);
    elsif (p_cost_segments(K).gl_account_segment = 'SEGMENT13') then
       l_segment13 := get_segment_val(p_cost_segments(K).payroll_cost_segment,p_cost_keyflex_id);
    elsif (p_cost_segments(K).gl_account_segment = 'SEGMENT14') then
       l_segment14 := get_segment_val(p_cost_segments(K).payroll_cost_segment,p_cost_keyflex_id);
    elsif (p_cost_segments(K).gl_account_segment = 'SEGMENT15') then
       l_segment15 := get_segment_val(p_cost_segments(K).payroll_cost_segment,p_cost_keyflex_id);
    elsif (p_cost_segments(K).gl_account_segment = 'SEGMENT16') then
       l_segment16 := get_segment_val(p_cost_segments(K).payroll_cost_segment,p_cost_keyflex_id);
    elsif (p_cost_segments(K).gl_account_segment = 'SEGMENT17') then
       l_segment17 := get_segment_val(p_cost_segments(K).payroll_cost_segment,p_cost_keyflex_id);
    elsif (p_cost_segments(K).gl_account_segment = 'SEGMENT18') then
       l_segment18 := get_segment_val(p_cost_segments(K).payroll_cost_segment,p_cost_keyflex_id);
    elsif (p_cost_segments(K).gl_account_segment = 'SEGMENT19') then
       l_segment19 := get_segment_val(p_cost_segments(K).payroll_cost_segment,p_cost_keyflex_id);
    elsif (p_cost_segments(K).gl_account_segment = 'SEGMENT20') then
       l_segment20 := get_segment_val(p_cost_segments(K).payroll_cost_segment,p_cost_keyflex_id);
    elsif (p_cost_segments(K).gl_account_segment = 'SEGMENT21') then
       l_segment21 := get_segment_val(p_cost_segments(K).payroll_cost_segment,p_cost_keyflex_id);
    elsif (p_cost_segments(K).gl_account_segment = 'SEGMENT22') then
       l_segment22 := get_segment_val(p_cost_segments(K).payroll_cost_segment,p_cost_keyflex_id);
    elsif (p_cost_segments(K).gl_account_segment = 'SEGMENT23') then
       l_segment23 := get_segment_val(p_cost_segments(K).payroll_cost_segment,p_cost_keyflex_id);
    elsif (p_cost_segments(K).gl_account_segment = 'SEGMENT24') then
       l_segment24 := get_segment_val(p_cost_segments(K).payroll_cost_segment,p_cost_keyflex_id);
    elsif (p_cost_segments(K).gl_account_segment = 'SEGMENT25') then
       l_segment25 := get_segment_val(p_cost_segments(K).payroll_cost_segment,p_cost_keyflex_id);
    elsif (p_cost_segments(K).gl_account_segment = 'SEGMENT26') then
       l_segment26 := get_segment_val(p_cost_segments(K).payroll_cost_segment,p_cost_keyflex_id);
    elsif (p_cost_segments(K).gl_account_segment = 'SEGMENT27') then
       l_segment27 := get_segment_val(p_cost_segments(K).payroll_cost_segment,p_cost_keyflex_id);
    elsif (p_cost_segments(K).gl_account_segment = 'SEGMENT28') then
       l_segment28 := get_segment_val(p_cost_segments(K).payroll_cost_segment,p_cost_keyflex_id);
    elsif (p_cost_segments(K).gl_account_segment = 'SEGMENT29') then
       l_segment29 := get_segment_val(p_cost_segments(K).payroll_cost_segment,p_cost_keyflex_id);
    elsif (p_cost_segments(K).gl_account_segment = 'SEGMENT30') then
       l_segment30 := get_segment_val(p_cost_segments(K).payroll_cost_segment,p_cost_keyflex_id);
    end if;
  end loop;

  /* Change to Static Sql */
        Insert into psb_cost_distributions_i
               (DATA_EXTRACT_ID              ,
                ASSIGNMENT_ID                ,
                BUSINESS_GROUP_ID            ,
                COSTING_LEVEL                ,
                PROPORTION                   ,
                CHART_OF_ACCOUNTS_ID         ,
                EFFECTIVE_START_DATE         ,
                EFFECTIVE_END_DATE           ,
                COST_ALLOCATION_KEYFLEX_ID   ,
                SEGMENT1                     ,
                SEGMENT2                     ,
                SEGMENT3                     ,
                SEGMENT4                     ,
                SEGMENT5                     ,
                SEGMENT6                     ,
                SEGMENT7                     ,
                SEGMENT8                     ,
                SEGMENT9                     ,
                SEGMENT10                    ,
                SEGMENT11                    ,
                SEGMENT12                    ,
                SEGMENT13                    ,
                SEGMENT14                    ,
                SEGMENT15                    ,
                SEGMENT16                    ,
                SEGMENT17                    ,
                SEGMENT18                    ,
                SEGMENT19                    ,
                SEGMENT20                    ,
                SEGMENT21                    ,
                SEGMENT22                    ,
                SEGMENT23                    ,
                SEGMENT24                    ,
                SEGMENT25                    ,
                SEGMENT26                    ,
                SEGMENT27                    ,
                SEGMENT28                    ,
                SEGMENT29                    ,
                SEGMENT30                    ,
                LAST_UPDATE_DATE             ,
                LAST_UPDATED_BY              ,
                LAST_UPDATE_LOGIN            ,
                CREATED_BY                   ,
                CREATION_DATE                )
                values
                (
                  p_data_extract_id,
                  p_assignment_id,
                  p_business_group_id,
                  p_costing_level,
                  l_percent,
                  p_chart_of_accounts_id,
                  p_start_date,
                  p_end_date,
                  p_cost_keyflex_id,
                  l_segment1,
                  l_segment2,
                  l_segment3,
                  l_segment4,
                  l_segment5,
                  l_segment6,
                  l_segment7,
                  l_segment8,
                  l_segment9,
                  l_segment10,
                  l_segment11,
                  l_segment12,
                  l_segment13,
                  l_segment14,
                  l_segment15,
                  l_segment16,
                  l_segment17,
                  l_segment18,
                  l_segment19,
                  l_segment20,
                  l_segment21,
                  l_segment22,
                  l_segment23,
                  l_segment24,
                  l_segment25,
                  l_segment26,
                  l_segment27,
                  l_segment28,
                  l_segment29,
                  l_segment30,
                  l_last_update_date,
                  l_last_updated_by,
                  l_last_update_login,
                  l_created_by,
                  l_creation_date
               );
 end;

PROCEDURE Get_Attributes
( p_api_version         IN    NUMBER,
  p_init_msg_list	IN    VARCHAR2 := FND_API.G_FALSE,
  p_commit	    	IN    VARCHAR2 := FND_API.G_FALSE,
  p_validation_level	IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT   NOCOPY VARCHAR2,
  p_msg_count           OUT   NOCOPY NUMBER,
  p_msg_data            OUT   NOCOPY VARCHAR2,
  p_data_extract_id     IN    NUMBER,
  p_extract_method      IN    VARCHAR2,
  p_business_group_id   IN    NUMBER
) AS

    l_last_update_date    date;
    l_last_updated_by     number;
    l_last_update_login   number;
    l_creation_date       date;
    l_created_by          number;
    l_job_id_flex_num     number;
    l_restart_attribute_id  number := 0;
    l_fin_attribute_id      number := 0;
    l_job_stmt            varchar2(1000);

    Cursor C5 is
          SELECT attribute_id,business_group_id,
                 name,definition_type,
                 definition_structure,
                 definition_table,
                 definition_column,
                 data_type,
                 system_attribute_type,
                 attribute_type_id,
                 value_table_flag
           FROM  PSB_ATTRIBUTES_VL
           WHERE business_group_id = p_business_group_id
             AND attribute_id > l_restart_attribute_id
           ORDER BY attribute_id;

    Cursor C_flex_num is
        Select job_structure
          from per_business_groups
         where business_group_id = p_business_group_id;

    Cursor C_Organizations is
       Select organization_id, name
         from hr_organization_units
        where business_group_id = p_business_group_id;

    l_lookup_type     varchar2(30);
    l_lookup_code     varchar2(30);
    l_lookup_meaning  varchar2(80);

    /* Increased the size of the following variable
       from 80 to 240 as part of bug fix 3544573 */
    l_description     varchar2(240);

   /* For Bug No. 2549515 : Start
      Size of following variables increased from 30 to 50 */
    l_select_table    varchar2(50);
    l_select_column   varchar2(50);
   /* For Bug No. 2549515 : End */

    v_jcursorid             INTEGER;
    v_jdummy                INTEGER;

    Cursor C6 is
         Select lookup_code,meaning,description
           from fnd_common_lookups
          where lookup_type = l_lookup_type;

    lsql_stmt                 varchar2(500);
    v_cursorid                integer;
    v_dummy                   integer;
    l_attribute_name          varchar2(30);
    l_definition_type         varchar2(10);
    l_definition_structure    varchar2(30);
    l_definition_table        varchar2(30);
    l_definition_column       varchar2(30);
    l_attribute_id            number;
    l_attribute_value_id      number;
    l_attribute_type_id       number;
    l_application_id          number;
    l_id_flex_code            varchar2(4);
    l_application_table_name  varchar2(30);
    l_set_defining_column     varchar2(30);
    l_id_flex_num             number;
    l_application_column_name varchar2(30);
    l_kflex_value_set_id      number;
    l_dflex_value_set_id      number;
    l_context_column_name     varchar2(30);
    l_desc_flex_context_code  varchar2(30);
    kvset                     fnd_vset.valueset_r;
    kfmt                      fnd_vset.valueset_dr;
    kfound                    BOOLEAN;
    krow                      NUMBER;
    kvalue                    fnd_vset.value_dr;
    dvset                     fnd_vset.valueset_r;
    dfmt                      fnd_vset.valueset_dr;
    dfound                    BOOLEAN;
    drow                      NUMBER;
    dvalue                    fnd_vset.value_dr;
    vdef_col1                 varchar2(100);
    vdef_col2                 number;
    vdef_col3                 date;
    vdef_col                  varchar2(100);
    l_status                  varchar2(1);
    l_return_status           varchar2(1);
    prev_attribute_id         number := -1;
    --UTF8 changes for Bug No : 2615261
    lr_attribute_value        psb_attribute_values_i.attribute_value%TYPE;
    lr_value_id               number := '';
    lr_attribute_id           number;
    l_attr_dummy              number := 0;
    l_msg_count               number;
    l_msg_data                varchar2(1000);

    /* Bug 4075170 Start */
    -- Local Variable that will hold the datatype of the attribute.
    l_data_type               psb_attributes_vl.data_type%TYPE;
    l_param_info              VARCHAR2(4000);
    l_debug_info              VARCHAR2(4000);
    /* Bug 4075170 End */

    Cursor C_table is
       Select name,select_column,
              substr(select_table,1,instr(select_table,' ',1)) select_table
         from psb_attribute_types
        where attribute_type_id = l_attribute_type_id;

   Cursor C_Attribute is
      Select attribute_value_id
        from psb_attribute_values
       where attribute_id = lr_attribute_id
         and attribute_value = lr_attribute_value
         and data_extract_id = p_data_extract_id;

   Cursor C_key_11 is
       Select application_id,id_flex_code,
              application_table_name,
              set_defining_column_name
        from  fnd_id_flexs
       where id_flex_name = l_definition_structure;

   Cursor C_key_22 is
     SELECT fstr.id_flex_num, fseg.application_column_name,
            fseg.flex_value_set_id
       FROM fnd_id_flex_structures_vl fstr,fnd_id_flex_segments_vl fseg
      WHERE fstr.application_id = l_application_id
        AND fstr.id_flex_code   = l_id_flex_code
        AND fstr.id_flex_structure_name = l_definition_table
        AND fstr.id_flex_code   = fseg.id_flex_code
        AND fstr.id_flex_num    = fseg.id_flex_num
        AND fseg.segment_name   = l_definition_column
        AND fstr.application_id = fseg.application_id;  -- bug #4924031;

   Cursor C_dff_11 is
     Select application_id,application_table_name,
            context_column_name
       from fnd_descriptive_flexs_vl
      where descriptive_flexfield_name = l_definition_structure;

   Cursor C_dff_22 is
    Select fcon.descriptive_flex_context_code,
           fcol.application_column_name,
           fcol.flex_value_set_id
     from  fnd_descr_flex_contexts_vl fcon,fnd_descr_flex_column_usages fcol
     where fcon.application_id = fcol.application_id
       and fcon.descriptive_flexfield_name = l_definition_structure
       and fcon.descriptive_flex_context_code = l_definition_table
       and fcon.descriptive_flexfield_name = fcol.descriptive_flexfield_name
    and fcon.descriptive_flex_context_code = fcol.descriptive_flex_context_code
    and fcol.end_user_column_name = l_definition_column;

   Cursor C_Qc_66 is
     Select lookup_type
       from per_common_lookup_types_v
      where lookup_type_meaning = l_definition_table;

   Cursor C_Jobs is
     Select job_id, name
       from per_jobs
     where  business_group_id = p_business_group_id;

  l_api_name		CONSTANT VARCHAR2(30)	:= 'Get_Attributes';
  l_api_version         CONSTANT NUMBER 	:= 1.0;

  l_message_text        VARCHAR2(2000);

BEGIN
  /* Bug 4075170 Start */
  l_param_info := 'data_extract_id::'||p_data_extract_id
                   ||', extract_method::'||p_extract_method
                   ||', business_grp_id::'||p_business_group_id;
  l_debug_info := 'Starting Get_Attributes API';
  /* Bug 4075170 End */

  -- Standard Start of API savepoint

  Savepoint Get_Attributes;

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
          	    	    	      p_api_version,
   	       	    	 	      l_api_name,
		    	    	      G_PKG_NAME)
  then
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
     FND_MSG_PUB.initialize;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body

  l_last_update_date := sysdate;
  l_last_updated_by := FND_GLOBAL.USER_ID;
  l_last_update_login :=FND_GLOBAL.LOGIN_ID;
  l_creation_date     := sysdate;
  l_created_by        := FND_GLOBAL.USER_ID;

  Check_Reentry
  (p_api_version              => 1.0  ,
   p_return_status            => l_return_status,
   p_msg_count                => l_msg_count,
   p_msg_data                 => l_msg_data,
   p_data_extract_id          => p_data_extract_id,
   p_process                  => 'Attribute Values Interface',
   p_status                   => l_status,
   p_restart_id               => l_restart_attribute_id
   );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     raise FND_API.G_EXC_ERROR;
  end if;

 if (l_status <> 'C') then
 For attribute_rec in C5 LOOP
     l_attribute_name       := null;
     l_definition_type      := null;
     l_attribute_name       := attribute_rec.name;
     l_definition_type      := attribute_rec.definition_type;
     l_definition_structure := attribute_rec.definition_structure;
     l_definition_table     := attribute_rec.definition_table;
     l_definition_column    := attribute_rec.definition_column;
     l_fin_attribute_id     := attribute_rec.attribute_id;

     /* Bug 4075170 Start */
     -- Assign the datatype of the current attribute.
     l_data_type  := attribute_rec.data_type;
     l_debug_info := 'Starting for attribute '||l_attribute_name
                     ||', of data type '||l_data_type;
     /* Bug 4075170 End */

     if ((l_fin_attribute_id <> prev_attribute_id) and (prev_attribute_id <> -1)) then
        Update_Reentry
        ( p_api_version              => 1.0  ,
          p_return_status            => l_return_status,
          p_msg_count                => l_msg_count,
          p_msg_data                 => l_msg_data,
          p_data_extract_id          => p_data_extract_id,
          p_extract_method           => p_extract_method,
          p_process                  => 'Attribute Values Interface',
          p_restart_id               =>  prev_attribute_id
        );

       if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          raise FND_API.G_EXC_ERROR;
       end if;
      commit work;
      Savepoint Get_Attributes;
    end if;

    if (attribute_rec.value_table_flag = 'Y') then
    if (attribute_rec.definition_type = 'KFF' ) then
       /* Bug 4075170 Start */
       l_debug_info := 'Starting for attribute '||l_attribute_name
                       ||', of data type '||l_data_type
                       ||' definition type KFF';
       /* Bug 4075170 End */
       For C_key_rec in C_key_11
       Loop
         l_application_id := C_key_rec.application_id;
         l_id_flex_code   := C_key_rec.id_flex_code;
         l_set_defining_column := C_key_rec.set_defining_column_name;
         For C_key_str_rec in C_key_22
         Loop
             l_id_flex_num := C_key_str_rec.id_flex_num;
             l_application_column_name := C_key_str_rec.application_column_name;
             l_kflex_value_set_id      := C_key_str_rec.flex_value_set_id;
         End Loop;

       End Loop;

   if (l_kflex_value_set_id is not null) then
     fnd_vset.get_valueset(l_kflex_value_set_id, kvset, kfmt);

   if (kvset.validation_type = 'N') then
      null;
   else
   fnd_vset.get_value_init(kvset,TRUE);
   fnd_vset.get_value(kvset, krow, kfound, kvalue);
   end if;
   WHILE(kfound) LOOP
      lr_attribute_id := attribute_rec.attribute_id;
      lr_attribute_value := kvalue.value;
      l_attr_dummy := 0;

      For C_Attribute_rec in C_Attribute
      Loop
        l_attribute_value_id := C_Attribute_rec.attribute_value_id;
        l_attr_dummy := 1;
      End Loop;

      if (l_attr_dummy = 0) then
      select psb_attribute_values_s.nextval into
             l_attribute_value_id from dual;
      end if;


      INSERT INTO PSB_ATTRIBUTE_VALUES_I
      (
         ATTRIBUTE_VALUE_ID     ,
         ATTRIBUTE_ID           ,
         ATTRIBUTE_VALUE        ,
         DESCRIPTION            ,
         DATA_EXTRACT_ID        ,
         LAST_UPDATE_DATE       ,
         LAST_UPDATED_BY         ,
         LAST_UPDATE_LOGIN       ,
         CREATED_BY              ,
         CREATION_DATE           )
      VALUES
      (
         l_attribute_value_id,
         attribute_rec.attribute_id,
         kvalue.value,
         kvalue.meaning,
         p_data_extract_id,
         l_last_update_date,
         l_last_updated_by ,
         l_last_update_login ,
         l_created_by,
         l_creation_date);
      fnd_vset.get_value(kvset, krow, kfound, kvalue);
   END LOOP;
   fnd_vset.get_value_end(kvset);
   end if;
   elsif (attribute_rec.definition_type = 'DFF') then
     /* Bug 4075170 Start */
     l_debug_info := 'Starting for attribute '||l_attribute_name
                     ||', of data type '||l_data_type
                     ||' definition type DFF';
     /* Bug 4075170 End */
       For C_dff_rec in C_dff_11
       Loop
         l_application_id            := C_dff_rec.application_id;
         l_application_table_name    := C_dff_rec.application_table_name;
         l_context_column_name       := C_dff_rec.context_column_name;

         For C_dff_str_rec in C_dff_22
         Loop
           l_desc_flex_context_code := C_dff_str_rec.descriptive_flex_context_code;
           l_application_column_name := C_dff_str_rec.application_column_name;
           l_dflex_value_set_id      := C_dff_str_rec.flex_value_set_id;
         End Loop;

       End Loop;

   if (l_dflex_value_set_id is not null) then
   fnd_vset.get_valueset(l_dflex_value_set_id, dvset, dfmt);
   if (dvset.validation_type = 'N') then
      null;
   else
   fnd_vset.get_value_init(dvset, TRUE);
   fnd_vset.get_value(dvset, drow, dfound, dvalue);
   end if;
   WHILE(dfound) LOOP
      lr_attribute_id := attribute_rec.attribute_id;
      lr_attribute_value := dvalue.value;
      l_attr_dummy := 0;

      For C_Attribute_rec in C_Attribute
      Loop
        l_attribute_value_id := C_Attribute_rec.attribute_value_id;
        l_attr_dummy := 1;
      End Loop;

      if (l_attr_dummy = 0) then
      select psb_attribute_values_s.nextval into
             l_attribute_value_id from dual;
      end if;

      /* Bug 4075170 Start */
      l_debug_info := 'Inserting for Atrribute Id '
                      ||attribute_rec.attribute_id
                      ||', Atrribute Data Type '||l_data_type
                      ||', Atrribute Value '||dvalue.value;
      /* Bug 4075170 End */

      INSERT INTO PSB_ATTRIBUTE_VALUES_I
      (
         ATTRIBUTE_VALUE_ID     ,
         ATTRIBUTE_ID           ,
         ATTRIBUTE_VALUE        ,
         VALUE_ID               ,
         DESCRIPTION            ,
         DATA_EXTRACT_ID        ,
         LAST_UPDATE_DATE       ,
         LAST_UPDATED_BY         ,
         LAST_UPDATE_LOGIN       ,
         CREATED_BY              ,
         CREATION_DATE
      )
      VALUES
      (
         l_attribute_value_id,
         attribute_rec.attribute_id,

         -- Fix for bug #4075170 changed the date format to canonical.
         -- But since DFF always stores date in canonical format, this conversion is not
         -- necessary. So removed the conversion as part for Bug #4658351.
         dvalue.value,

         dvalue.id,
         dvalue.meaning,
         p_data_extract_id,
         l_last_update_date,
         l_last_updated_by ,
         l_last_update_login ,
         l_created_by,
         l_creation_date);
      fnd_vset.get_value(dvset, drow, dfound, dvalue);
   END LOOP;
   fnd_vset.get_value_end(dvset);
   end if;

  elsif (attribute_rec.definition_type = 'QC') then
    /* Bug 4075170 Start */
    l_debug_info := 'Starting for attribute '||l_attribute_name
                    ||', of data type '||l_data_type
                    ||' definition type QC';
    /* Bug 4075170 End */
    l_attribute_type_id := attribute_rec.attribute_type_id;

    For C_table_rec in C_table
    Loop
       l_lookup_type := C_table_rec.name;
    End Loop;

     -- Get values for lookup_type from fnd_common_lookups

    Open C6;
    Loop

    Fetch  C6 into l_lookup_code,l_lookup_meaning,l_description;
    exit when C6%NOTFOUND;
      lr_attribute_id := attribute_rec.attribute_id;
      lr_attribute_value := l_lookup_meaning;
      l_attr_dummy := 0;

      For C_Attribute_rec in C_Attribute
      Loop
        l_attribute_value_id := C_Attribute_rec.attribute_value_id;
        l_attr_dummy := 1;
      End Loop;

      if (l_attr_dummy = 0) then
      select psb_attribute_values_s.nextval into
             l_attribute_value_id from dual;
      end if;

      /* Bug 4075170 Start */
      l_debug_info := 'Inserting for Atrribute Id '
                      ||attribute_rec.attribute_id
                      ||', Atrribute Data Type '||l_data_type
                      ||', Atrribute Value '||l_description;
      /* Bug 4075170 End */

      -- Bug #4658351
      -- Moved the date format conversion out of the insert statement.

      if (l_data_type = 'D') then
        begin
          l_description := Fnd_Date.Date_to_Canonical(l_description);
        exception
          when OTHERS then
            FND_MESSAGE.SET_NAME('PSB', 'PSB_ATTRIBUTE_VALUE_DATE_ERR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', l_attribute_name);
            l_message_text := fnd_message.get;
            RAISE_APPLICATION_ERROR(-20001,l_message_text);
         end;
       end if;

      INSERT INTO PSB_ATTRIBUTE_VALUES_I
      (
         ATTRIBUTE_VALUE_ID     ,
         ATTRIBUTE_ID           ,
         ATTRIBUTE_VALUE        ,
         DESCRIPTION            ,
         DATA_EXTRACT_ID        ,
         LAST_UPDATE_DATE       ,
         LAST_UPDATED_BY         ,
         LAST_UPDATE_LOGIN       ,
         CREATED_BY              ,
         CREATION_DATE
      )
      VALUES
      (
         l_attribute_value_id,
         attribute_rec.attribute_id,
         l_lookup_meaning,

         -- Bug #4658351
         -- Moved the date format conversion out of the insert statement.
         l_description,

         p_data_extract_id,
         l_last_update_date,
         l_last_updated_by ,
         l_last_update_login ,
         l_created_by,
         l_creation_date);

    end loop;

    close C6;

  elsif (attribute_rec.definition_type = 'TABLE') then
    /* Bug 4075170 Start */
    l_debug_info := 'Starting for attribute '||l_attribute_name
                    ||', of data type '||l_data_type
                    ||' definition type TABLE ';
    /* Bug 4075170 End */
  if (attribute_rec.value_table_flag = 'Y') then
    l_attribute_type_id := attribute_rec.attribute_type_id;
    v_cursorid := dbms_sql.open_cursor;

    -- Build the statement
    For C_table_rec in C_table

    Loop

    lsql_stmt := 'Select distinct '||C_table_rec.select_column
                ||' From '||C_table_rec.select_table;

    -- Parse the query
    dbms_sql.parse(v_cursorid,lsql_stmt,dbms_sql.v7);
    -- Define the output variables
    if (attribute_rec.data_type = 'C') then
       dbms_sql.define_column(v_cursorid,1,vdef_col1,100);
    elsif (attribute_rec.data_type = 'N') then
      dbms_sql.define_column(v_cursorid,1,vdef_col2);
    elsif (attribute_rec.data_type = 'D') then
       dbms_sql.define_column(v_cursorid,1,vdef_col3);
    end if;

    v_dummy := DBMS_SQL.EXECUTE(v_cursorid);

    loop
      if DBMS_SQL.FETCH_ROWS(v_cursorid) = 0 then
         exit;
      end if;

    if (attribute_rec.data_type = 'C') then
      DBMS_SQL.COLUMN_VALUE(v_cursorid,1,vdef_col1);
      vdef_col := vdef_col1;
    elsif (attribute_rec.data_type = 'N') then
      begin
         DBMS_SQL.COLUMN_VALUE(v_cursorid,1,vdef_col2);
         vdef_col := fnd_number.number_to_canonical(vdef_col2);
      exception
       when INVALID_NUMBER then

         -- Changed the exception part for Bug #4658351
         FND_MESSAGE.SET_NAME('PSB', 'PSB_ATTRIBUTE_VALUE_NUMBER_ERR');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', l_attribute_name);
         l_message_text := fnd_message.get;
         RAISE_APPLICATION_ERROR(-20000,l_message_text);

      end;
    elsif (attribute_rec.data_type = 'D') then
      begin
       DBMS_SQL.COLUMN_VALUE(v_cursorid,1,vdef_col3);
       vdef_col := fnd_date.date_to_canonical(vdef_col3);
      exception
       when OTHERS then -- Bug #4658351: Changed VALUE_ERROR to OTHERS

         -- Changed the exception part for Bug #4658351
         FND_MESSAGE.SET_NAME('PSB', 'PSB_ATTRIBUTE_VALUE_DATE_ERR');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', l_attribute_name);
         l_message_text := fnd_message.get;
         RAISE_APPLICATION_ERROR(-20001,l_message_text);

      end;
    end if;

      lr_attribute_id := attribute_rec.attribute_id;
      lr_attribute_value := vdef_col;
      l_attr_dummy := 0;

      For C_Attribute_rec in C_Attribute
      Loop
        l_attribute_value_id := C_Attribute_rec.attribute_value_id;
        l_attr_dummy := 1;
      End Loop;

      if (l_attr_dummy = 0) then
      select psb_attribute_values_s.nextval into
             l_attribute_value_id from dual;
      end if;

      INSERT INTO PSB_ATTRIBUTE_VALUES_I
      (
         ATTRIBUTE_VALUE_ID     ,
         ATTRIBUTE_ID           ,
         ATTRIBUTE_VALUE        ,
         DATA_EXTRACT_ID        ,
         LAST_UPDATE_DATE       ,
         LAST_UPDATED_BY         ,
         LAST_UPDATE_LOGIN       ,
         CREATED_BY              ,
         CREATION_DATE
      )
      VALUES
      (
         l_attribute_value_id,
         attribute_rec.attribute_id,
         vdef_col,
         p_data_extract_id,
         l_last_update_date,
         l_last_updated_by ,
         l_last_update_login ,
         l_created_by,
         l_creation_date);
     end loop;
    dbms_sql.close_cursor(v_cursorid);
    end loop;
   end if;
     /*bug:7114143:Modified the if condition on definition_type to check if the value is 'NONE'*/
  elsif (attribute_rec.definition_type = 'NONE') then
    /* Bug 4075170 Start */
    l_debug_info := 'Starting for attribute '||l_attribute_name
                    ||', of data type '||l_data_type
                    ||' definition type IS NULL'
                    ||' system_attr_type '
                    ||attribute_rec.system_attribute_type;
    /* Bug 4075170 End */
    if (attribute_rec.system_attribute_type = 'JOB_CLASS') then

     -- Commented out for bug number 3159157
     /*For C_flex_rec in C_flex_num
     Loop
       l_job_id_flex_num := C_flex_rec.job_structure;
     End Loop;

     v_jcursorid := DBMS_SQL.OPEN_CURSOR;

     -- Changed the job stmt for Position Control requirements .
     -- Job name or job_definition_id is unique within a business_group
     -- and so the following cursor helps in storing the job_id value
     -- along with the job name as the corresponding attribute_value.

     l_job_stmt := 'Select job_id, concatenated_segments '||
                   ' from per_jobs pj, per_job_definitions_kfv pjv '||
                   'where  pj.business_group_id = '||p_business_group_id||
                  '  and  pj.job_definition_id =  pjv.job_definition_id and '||
                   'pjv.id_flex_num = '||l_job_id_flex_num;

    dbms_sql.parse(v_jcursorid,l_job_stmt,dbms_sql.v7);
    dbms_sql.define_column(v_jcursorid,1,lr_value_id);
    dbms_sql.define_column(v_jcursorid,2,lr_attribute_value,80);
    v_jdummy := DBMS_SQL.EXECUTE(v_jcursorid);*/

    -- Fetching job name from PER_JOBS (Bug number 3159157)
    For C_job_rec in C_Jobs
    Loop
      lr_attribute_id := attribute_rec.attribute_id;
      lr_attribute_value := C_job_rec.name;
      lr_value_id        := C_job_rec.job_id;
      l_attr_dummy := 0;

      For C_Attribute_rec in C_Attribute
      Loop
        l_attribute_value_id := C_Attribute_rec.attribute_value_id;
        l_attr_dummy := 1;
      End Loop;

      if (l_attr_dummy = 0) then
      select psb_attribute_values_s.nextval into
             l_attribute_value_id from dual;
      end if;

      INSERT INTO PSB_ATTRIBUTE_VALUES_I
      (
         ATTRIBUTE_VALUE_ID     ,
         ATTRIBUTE_ID           ,
         ATTRIBUTE_VALUE        ,
         VALUE_ID               ,
         DATA_EXTRACT_ID        ,
         LAST_UPDATE_DATE       ,
         LAST_UPDATED_BY         ,
         LAST_UPDATE_LOGIN       ,
         CREATED_BY              ,
         CREATION_DATE
      )
      VALUES
      (
         l_attribute_value_id,
         attribute_rec.attribute_id,
         lr_attribute_value,
         lr_value_id,
         p_data_extract_id,
         l_last_update_date,
         l_last_updated_by ,
         l_last_update_login ,
         l_created_by,
         l_creation_date);
     End Loop;

   elsif (attribute_rec.system_attribute_type = 'ORG') then

    For C_Org_Rec in C_Organizations
    Loop
      lr_attribute_id := attribute_rec.attribute_id;
      lr_attribute_value := C_Org_Rec.name;
      lr_value_id        := C_Org_Rec.organization_id;
      l_attr_dummy := 0;

      For C_Attribute_rec in C_Attribute
      Loop
        l_attribute_value_id := C_Attribute_rec.attribute_value_id;
        l_attr_dummy := 1;
      End Loop;

      if (l_attr_dummy = 0) then
      select psb_attribute_values_s.nextval into
             l_attribute_value_id from dual;
      end if;

      INSERT INTO PSB_ATTRIBUTE_VALUES_I
      (
         ATTRIBUTE_VALUE_ID     ,
         ATTRIBUTE_ID           ,
         ATTRIBUTE_VALUE        ,
         VALUE_ID               ,
         DATA_EXTRACT_ID        ,
         LAST_UPDATE_DATE       ,
         LAST_UPDATED_BY         ,
         LAST_UPDATE_LOGIN       ,
         CREATED_BY              ,
         CREATION_DATE
      )
      VALUES
      (
         l_attribute_value_id,
         attribute_rec.attribute_id,
         lr_attribute_value,
         lr_value_id,
         p_data_extract_id,
         l_last_update_date,
         l_last_updated_by ,
         l_last_update_login ,
         l_created_by,
         l_creation_date);
     End Loop;

   end if; /* system attribute type */
  end if; /* definition type */

  end if; /* Value table flag */
  prev_attribute_id := l_fin_attribute_id;
  End loop;

  Update_Reentry
  ( p_api_version              => 1.0  ,
    p_return_status            => l_return_status,
    p_msg_count                => l_msg_count,
    p_msg_data                 => l_msg_data,
    p_data_extract_id          => p_data_extract_id,
    p_extract_method           => p_extract_method,
    p_process                  => 'Attribute Values Interface',
    p_restart_id               =>  l_fin_attribute_id
  );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     raise FND_API.G_EXC_ERROR;
  end if;

  Reentrant_Process
  ( p_api_version              => 1.0  ,
    p_return_status            => l_return_status,
    p_msg_count                => l_msg_count,
    p_msg_data                 => l_msg_data,
    p_data_extract_id          => p_data_extract_id,
    p_extract_method           => p_extract_method,
    p_process                  => 'Attribute Values Interface'
  );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     raise FND_API.G_EXC_ERROR;
  end if;

  commit work;

  end if;

  -- End of API body.

EXCEPTION

   when FND_API.G_EXC_ERROR then
     /* Bug 4075170 Start */
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Last Status::'||l_debug_info);
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Parameter Info::'||l_param_info);
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error Type:: FND_API.G_EXC_EXC_ERROR');
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Get_Attributes API '
                                      ||'failed due to the following error');
     FND_FILE.PUT_LINE(FND_FILE.LOG, sqlerrm);
     /* Bug 4075170 End */

     if C6%isopen then
        close C6;
     end if;

     if (dbms_sql.is_open(v_cursorid)) then
        dbms_sql.close_cursor(v_cursorid);
     end if;

     rollback to Get_Attributes;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                 p_data  => p_msg_data);
     message_token('ATTRIBUTE_NAME',l_attribute_name );
     message_token('DEFINITION_TYPE',l_definition_type );
     message_token('DEFINITION_STRUCTURE',l_definition_structure);
     message_token('DEFINITION_TABLE',l_definition_table);
     message_token('DEFINITION_COLUMN',l_definition_column);
     add_message('PSB', 'PSB_ATTRIBUTE_DETAILS');

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     /* Bug 4075170 Start */
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Last Status::'||l_debug_info);
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Parameter Info::'||l_param_info);
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error Type:: FND_API.G_EXC_UNEXPECTED_ERROR');
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Get_Attributes API '
                                     ||'failed due to the following error');
     FND_FILE.PUT_LINE(FND_FILE.LOG, sqlerrm);
     /* Bug 4075170 End */

     if C6%isopen then
        close C6;
     end if;

     if (dbms_sql.is_open(v_cursorid)) then
        dbms_sql.close_cursor(v_cursorid);
     end if;

     rollback to Get_Attributes;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                 p_data  => p_msg_data);
     message_token('ATTRIBUTE_NAME',l_attribute_name );
     message_token('DEFINITION_TYPE',l_definition_type );
     message_token('DEFINITION_STRUCTURE',l_definition_structure);
     message_token('DEFINITION_TABLE',l_definition_table);
     message_token('DEFINITION_COLUMN',l_definition_column);
     add_message('PSB', 'PSB_ATTRIBUTE_DETAILS');

   when OTHERS then
     /* Bug 4075170 Start */
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Last Status::'||l_debug_info);
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Parameter Info::'||l_param_info);
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error Type:: WHEN OTHERS');
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Get_Attributes API '
                                      ||'failed due to the following error');
     FND_FILE.PUT_LINE(FND_FILE.LOG, sqlerrm);
     /* Bug 4075170 End */

     if C6%isopen then
        close C6;
     end if;

     if (dbms_sql.is_open(v_cursorid)) then
        dbms_sql.close_cursor(v_cursorid);
     end if;

     rollback to Get_Attributes;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                 p_data  => p_msg_data);
     message_token('ATTRIBUTE_NAME',l_attribute_name );
     message_token('DEFINITION_TYPE',l_definition_type );
     message_token('DEFINITION_STRUCTURE',l_definition_structure);
     message_token('DEFINITION_TABLE',l_definition_table);
     message_token('DEFINITION_COLUMN',l_definition_column);
     add_message('PSB', 'PSB_ATTRIBUTE_DETAILS');
     if FND_MSG_PUB.Check_Msg_level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
          (p_pkg_name => G_PKG_NAME,
           p_procedure_name => l_api_name);
    end if;

End Get_Attributes;

/* ----------------------------------------------------------------------- */

PROCEDURE Get_Employee_Attributes
( p_api_version         IN    NUMBER,
  p_init_msg_list	IN    VARCHAR2 := FND_API.G_FALSE,
  p_commit	    	IN    VARCHAR2 := FND_API.G_FALSE,
  p_validation_level	IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT   NOCOPY VARCHAR2,
  p_msg_count           OUT   NOCOPY NUMBER,
  p_msg_data            OUT   NOCOPY VARCHAR2,
  p_data_extract_id     IN    NUMBER,
  -- de by org
  p_extract_by_org      IN    VARCHAR2,
  p_extract_method      IN    VARCHAR2,
  p_date                IN    DATE,
  p_business_group_id   IN    NUMBER,
  p_set_of_books_id     IN    NUMBER
) AS

  l_restart_attribute_id    number := 0;

  Cursor C_Emp_Attributes is
     Select  attribute_id,name,definition_type,definition_structure,
             definition_table, definition_column,system_attribute_type,
             attribute_type_id,data_type
      from   Psb_attributes_VL
     where   business_group_id = p_business_group_id
       and   attribute_id > l_restart_attribute_id;

  /*For Bug No : 2370607 Start*/
  --changed the a.working_hours, a.frequency to
  --		decode statements
  /*For Bug No : 2642012 Start*/
  --replaced per_all_assignments with per_all_assignments_f  and added datetrack logic
  --and also added c.hr_position_name into the cursor select part

  Cursor C_Employees is
     Select b.person_id,b.assignment_id,a.position_id,
            b.grade_id,a.job_id,a.organization_id,
            nvl(a.fte,1) fte, a.earliest_hire_date,
            --a.working_hours,a.frequency,
            decode(b.frequency,'W',b.normal_hours,decode(a.frequency,'W',a.working_hours,null)) working_hours,
            decode(b.frequency,'W','A','P') freq_flag,
            a.position_type,
            c.hr_position_name,
            b.people_group_id ,
            b.soft_coding_keyflex_id,
            b.effective_start_date,
            b.effective_end_date,
            a.effective_start_date date_effective,
            a.effective_end_date date_end
      from  fnd_sessions d, per_all_assignments_f b, hr_all_positions_f a , psb_positions_i c, psb_employees_i e
     where  d.session_id = userenv('sessionid')
       and  d.effective_date between a.effective_start_date and a.effective_end_date
       and  d.effective_date between b.effective_start_date and b.effective_end_date
       and  a.business_group_id = p_business_group_id
       and  a.position_id = c.hr_position_id
       and  c.data_extract_id = p_data_extract_id
       and  b.assignment_id = e.assignment_id
       and  e.data_extract_id = p_data_extract_id
       and  a.position_id = b.position_id
       and  c.hr_employee_id = b.person_id
       and  b.business_group_id = p_business_group_id
       /*For Bug No : 2109120 Start*/
       --and  b.primary_flag(+) = 'Y'
       /*For Bug No : 2109120 End*/
       and  b.assignment_type = 'E'
        -- de by org

        -- The following logic is used to restrict the positions for all the
	-- selected organizations, if extract by org is enabled.
        -- Otherwise, we will ignore the organizations available
        -- in the business group.

       and (p_extract_by_org = 'N' OR
           (p_extract_by_org = 'Y' and a.organization_id in
            (select organization_id
              from psb_data_extract_orgs
              where data_extract_id = p_data_extract_id
              and select_flag = 'Y')))

     UNION ALL
     Select to_number(NULL),to_number(NULL),a.position_id,
            to_number(NULL),a.job_id,a.organization_id,
            nvl(a.fte,1) fte, a.earliest_hire_date,
            --a.working_hours,a.frequency,
            decode(a.frequency,'W',a.working_hours,null) working_hours,
            'P' freq_flag ,
            a.position_type,
            c.hr_position_name,
            to_number(NULL) ,
            to_number(NULL),
            to_date(NULL),
            to_date(NULL),
            a.effective_start_date date_effective,
            a.effective_end_date date_end
      from  fnd_sessions b , hr_all_positions_f a , psb_positions_i c
     where  b.session_id = userenv('sessionid')
       and  b.effective_date between a.effective_start_date and a.effective_end_date
       and  a.business_group_id = p_business_group_id
       and  a.position_id = c.hr_position_id
       and  c.data_extract_id = p_data_extract_id
       and  c.hr_employee_id is null
        -- de by org

        -- The following logic is used to restrict the positions for all the
	-- selected organizations, if extract by org is enabled.
        -- Otherwise, we will ignore the organizations available
        -- in the business group

       and  (p_extract_by_org = 'N' OR
            (p_extract_by_org = 'Y' and a.organization_id in
             (select organization_id
               from psb_data_extract_orgs
              where data_extract_id = p_data_extract_id
              and select_flag = 'Y')));

  /*For Bug No : 2642012 End*/
  /*For Bug No : 2370607 End*/

    l_position_name           varchar2(240);

        /* start bug 4153562 */
        -- local variables to hold the position_id
        -- and the effective end date
	lv_position_id        number;
	lv_effective_end_date date;
       /*  end bug 4153562 */


    --UTF8 changes for Bug No : 2615261
    l_employee_name           varchar2(310);
    l_person_id               number;
    l_definition_structure    varchar2(30);
    l_definition_table        varchar2(30);
    l_definition_column       varchar2(30);
    l_id_flex_code            varchar2(4);
    l_application_id          number;
    l_application_table_name  varchar2(30);
    l_set_defining_column     varchar2(30);
    l_id_flex_num             number;
    l_application_column_name varchar2(30);
    l_assignment_table        varchar2(30);
    l_assignment_column       varchar2(30);
    l_key_column              varchar2(30);
    l_lookup_type             varchar2(30);
    l_link_type               varchar2(10);
    l_attr_link_type          varchar2(30);
    l_last_update_date        date;
    l_last_updated_by         number;
    l_last_update_login       number;
    l_creation_date           date;
    l_created_by              number;
    l_job_name                varchar2(80);
    le_effective_start_date   date;
    le_effective_end_date     date;
    lemp_effective_start_date date;
    lemp_effective_end_date   date;
    lpos_effective_start_date date;
    lpos_effective_end_date   date;
    l_job_id                  number;
    ctr                       number := 0;
    l_sql_stmt                varchar2(500);
    stmt_flag                 varchar2(1);
    v_cursorid                integer;
    v_emp_val                 integer;
    v_dummy                   integer;
    v_segment                 varchar2(80);
    v_dcursorid               integer;
    v_ddummy                  integer;
    v_dsegment                varchar2(80);
  /*For Bug No : 2372434 Start*/
  --increased the size of d_sql_stmt,q_sql_stmt,o_sql_stmt
  --from 500 to 2000
    d_sql_stmt                varchar2(2000);
    v_qcursorid               integer;
    v_qdummy                  integer;
    v_qsegment                varchar2(80);
    q_sql_stmt                varchar2(2000);
    v_ocursorid               integer;
    v_odummy                  integer;
    v_osegment                varchar2(80);
    v_odate                   date;
    v_onumber                 number;
    o_sql_stmt                varchar2(2000);
  /*For Bug No : 2372434 End*/
    d_attribute_type          varchar2(30);
    d_attribute_type_id       number;
    l_emp_col                 varchar2(20);
    l_emp_val                 number;
    l_assignment_id           number;
    l_status                  varchar2(1);
    l_return_status           varchar2(1);
    l_msg_count               number;
    l_msg_data                varchar2(1000);
    l_alias1                  varchar2(10);
    l_job_stmt                varchar2(1000);
    v_jcursorid               integer;
    v_jdummy                  integer;
    prev_attribute_id         number := -1;
    l_attribute_id            number := 0;
    lc_assignment_id          number;
    lc_person_id              number;
    lc_position_id            number;
    lc_people_group_id        number;
    lc_soft_coding_keyflex_id number;
    lc_grade_id               number;
    lc_job_id                 number;
    l_fin_attribute_id        number := 0;
    l_organization_id         number := 0;
    --UTF8 changes for Bug No : 2615261
    l_organization_name       hr_all_organization_units.name%TYPE;


  Cursor C_Attribute_Types is
    Select name, select_table,
           substr(select_table,1,instr(select_table,' ',1)) select_tab,
           select_column,select_key,
           link_key,decode(link_type,'A','PER_ALL_ASSIGNMENTS','E',
           'PER_ALL_PEOPLE','P', 'HR_ALL_POSITIONS','PER_ALL_ASSIGNMENTS') link_type,link_type l_alias2,
           select_where
      From Psb_attribute_types
    Where  attribute_type = d_attribute_type
      and  attribute_type_id = d_attribute_type_id;

  Cursor C_key_33 is
       Select application_id,id_flex_code,
              application_table_name,
              set_defining_column_name
        from  fnd_id_flexs
       where id_flex_name = l_definition_structure;

  Cursor C_key_44 is
    SELECT fseg.application_column_name,
           fstr.id_flex_num
      FROM fnd_id_flex_structures_vl fstr,fnd_id_flex_segments_vl fseg
     WHERE fstr.application_id = l_application_id
       AND fstr.id_flex_code   = l_id_flex_code
       AND fstr.id_flex_structure_name = l_definition_table
       AND fstr.id_flex_code   = fseg.id_flex_code
       AND fstr.id_flex_num    = fseg.id_flex_num
       AND fseg.segment_name   = l_definition_column
	     AND fstr.application_id = fseg.application_id;  -- bug #4924031;

   Cursor C_dff_33 is
     Select application_id,application_table_name,
            context_column_name
       from fnd_descriptive_flexs_vl
      where descriptive_flexfield_name = l_definition_structure;

   Cursor C_dff_44 is
    Select fcol.application_column_name
     from  fnd_descr_flex_contexts_vl fcon,fnd_descr_flex_column_usages fcol
     where fcon.application_id = fcol.application_id
       and fcon.descriptive_flexfield_name = l_definition_structure
       and fcon.descriptive_flex_context_code = l_definition_table
       and fcon.descriptive_flexfield_name = fcol.descriptive_flexfield_name
    and fcon.descriptive_flex_context_code = fcol.descriptive_flex_context_code
    and fcol.end_user_column_name = l_definition_column;

   Cursor C_Qc_55 is
     Select lookup_type
       from per_common_lookup_types_v
      where lookup_type_meaning = l_definition_table;

   Cursor C_job_structure is
     Select job_structure
       from per_business_groups
      where business_group_id = p_business_group_id;

   Cursor C_Pos_Org is
     Select name
       from hr_all_organization_units
      where organization_id = l_organization_id;

   /*For Bug No : 2109120 Start*/
   Cursor C_Fte is
     Select value
       from per_assignment_budget_values
      where assignment_id  = l_assignment_id
      --changed the unit value from 'F' to 'FTE'
        and unit = 'FTE';
   /*For Bug No : 2109120 End*/

   Cursor C_Emp_Name is
    Select first_name,last_name
      from psb_employees_i
     where hr_employee_id = l_person_id
      and  data_extract_id = p_data_extract_id;

   Cursor C_Hiredate is
     Select original_date_of_hire  --bug:7623053:modified
       from per_all_people
      where person_id   = l_person_id ;

   Cursor C_job_name is
     Select name
       from per_jobs
      where  job_id = l_job_id;

   /*For Bug No : 2109120 Start*/
   CURSOR C_check_FTE(l_pos_id NUMBER) IS
     SELECT sum(nvl(value,1)) sum_fte
       FROM fnd_sessions fs,
            per_assignment_budget_values pab,
            per_all_assignments_f paf,
            per_assignment_status_types past
      WHERE fs.session_id = userenv('sessionid')
        AND fs.effective_date between paf.effective_start_date
                          and paf.effective_end_date
        AND paf.position_id = l_pos_id
        AND paf.assignment_type = 'E'
        /* Bug 3796397 Start */
        AND paf.assignment_status_type_id
                          = past.assignment_status_type_id
        AND past.per_system_status <> 'TERM_ASSIGN'
        /* Bug 3796397 End */
        AND pab.assignment_id(+)  = paf.assignment_id
        AND pab.unit(+) = 'FTE';
   /*For Bug No : 2109120 End*/

  --
  l_attribute_name  varchar2(30);
  l_definition_type varchar2(10);
  l_average_fte     NUMBER ;
  l_allocated_fte   NUMBER ;
  l_fte             NUMBER ;
  lp_fte            VARCHAR2(30);
  l_default_weekly_hours  NUMBER;
  lp_default_weekly_hours VARCHAR2(30);
  l_hiredate        DATE;
  lp_hiredate       VARCHAR2(30);
  lk_position_id    NUMBER ;
  lk_effective_end_date DATE;
  l_message_text    VARCHAR2(2000);
  --
  l_api_name	    CONSTANT VARCHAR2(30)	:= 'Get_Employee_Attributes';
  l_api_version     CONSTANT NUMBER 	:= 1.0;

  /* Bug 4075170 Start */
  l_data_type       psb_attributes_vl.data_type%TYPE;
  l_param_info      VARCHAR2(4000);
  l_debug_info      VARCHAR2(4000);
  /* Bug 4075170 End */

Begin

  -- Standard Start of API savepoint
  /* Bug 4075170 Start */
  l_param_info := 'data_extract_id::'||p_data_extract_id
                  ||', extract_method::'||p_extract_method
                  ||', extract_by_org::'||p_extract_by_org
                  ||', business_grp_id::'||p_business_group_id
                  ||' date::'||p_date;
  l_debug_info := 'Starting the Get_Employee_Attributes API';
  /* Bug 4075170 End */

  Savepoint Get_Employee_Attributes;

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
          	    	 	      p_api_version,
   	       	    	              l_api_name,
		    	    	      G_PKG_NAME)
  then
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
     FND_MSG_PUB.initialize;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body

  l_last_update_date := sysdate;
  l_last_updated_by := FND_GLOBAL.USER_ID;
  l_last_update_login :=FND_GLOBAL.LOGIN_ID;
  l_creation_date     := sysdate;
  l_created_by        := FND_GLOBAL.USER_ID;

  Check_Reentry
  (p_api_version              => 1.0  ,
   p_return_status            => l_return_status,
   p_msg_count                => l_msg_count,
   p_msg_data                 => l_msg_data,
   p_data_extract_id          => p_data_extract_id,
   p_process                  => 'Position Assignments Interface',
   p_status                   => l_status,
   p_restart_id               => l_restart_attribute_id
   );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     raise FND_API.G_EXC_ERROR;
  end if;

  if (l_status <> 'C') then
  For Emp_attribute_rec in C_Emp_Attributes Loop
      l_attribute_id         := Emp_attribute_rec.attribute_id;
      l_attribute_name       := Emp_attribute_rec.name;
      l_definition_type      := Emp_attribute_rec.definition_type;
      l_definition_structure := Emp_attribute_rec.definition_structure;
      l_definition_table     := Emp_attribute_rec.definition_table;
      l_definition_column    := Emp_attribute_rec.definition_column;
      /* Bug 4075170 Start */
      -- Assign the datatype of the current attribute.
      l_data_type            := Emp_attribute_rec.data_type;
      /* Bug 4075170 End */

      if ((l_attribute_id <> prev_attribute_id) and (prev_attribute_id <> -1))
then
        Update_Reentry
        ( p_api_version              => 1.0  ,
          p_return_status            => l_return_status,
          p_msg_count                => l_msg_count,
          p_msg_data                 => l_msg_data,
          p_data_extract_id          => p_data_extract_id,
          p_extract_method           => p_extract_method,
          p_process                  => 'Position Assignments Interface',
          p_restart_id               => prev_attribute_id
        );

       if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          raise FND_API.G_EXC_ERROR;
       end if;
      commit work;
      Savepoint Get_Employee_Attributes;
      end if;


   For Employee_rec in C_Employees Loop
    ctr := 0;
    stmt_flag := '';
    l_sql_stmt := '';
    l_position_name         := null;
    l_employee_name         := null;
    lemp_effective_start_date := to_date(null);
    lemp_effective_end_date   := to_date(null);
    lpos_effective_start_date := to_date(null);
    lpos_effective_end_date   := to_date(null);
    le_effective_start_date := to_date(null);
    le_effective_end_date   := to_date(null);

    if (Employee_rec.person_id is not null) then
       l_person_id               := Employee_Rec.person_id;
       For Emp_Name_Rec in C_Emp_Name
       Loop
         l_employee_name := Emp_Name_Rec.first_name||' '||Emp_Name_Rec.last_name;
       End Loop;
    end if;

    /* Bug 4075170 Start */
    l_debug_info := 'Starting for person_id '||l_person_id;
    /* Bug 4075170 End */


    /*For Bug No : 2642012 Start*/
    --coomented the following code and getting the position name
    --directly from the cursor itself
    l_position_name := Employee_rec.hr_position_name;

    /*
    if (Employee_rec.position_id is not null) then
       For Pos_Name_Rec in G_Position_Details(p_position_id => Employee_rec.position_id)
       Loop
         l_position_name := Pos_Name_Rec.name;
       End Loop;
    end if;
    */
    /*For Bug No : 2642012 End*/

    lpos_effective_start_date := Employee_rec.date_effective;

    if (Employee_rec.date_end = to_date('31124712','DDMMYYYY')) then
      lpos_effective_end_date := to_date(null);
    else
      lpos_effective_end_date   := Employee_rec.date_end;
    end if;

     lemp_effective_start_date := Employee_rec.effective_start_date;
     if (Employee_rec.effective_end_date = to_date('31124712','DDMMYYYY')) then
         lemp_effective_end_date := to_date(null);
     else
        lemp_effective_end_date   := Employee_rec.effective_end_date;
     end if;

    /* Start bug #4302946 */
    l_emp_val := null;
    /* End bug #4302946 */

    if (Emp_attribute_rec.definition_type = 'KFF') then
      /* Bug 4075170 Start */
      l_debug_info := 'Starting for person_id '||l_person_id||' definition type KFF';
      /* Bug 4075170 End */

   if ((l_attribute_id <> prev_attribute_id) or  (prev_attribute_id = -1)) then
      if dbms_sql.is_open(v_cursorid) then
         dbms_sql.close_cursor(v_cursorid);
      end if;

       For C_key_rec in C_key_33
       Loop
         l_application_id := C_key_rec.application_id;
         l_id_flex_code   := C_key_rec.id_flex_code;
         l_set_defining_column := C_key_rec.set_defining_column_name;
         For C_key_str_rec in C_key_44
         Loop
             l_application_column_name := C_key_str_rec.application_column_name;
             l_id_flex_num := C_key_str_rec.id_flex_num;
         End Loop;

       End Loop;

      v_cursorid := dbms_sql.open_cursor;
   end if;

   if (Emp_attribute_rec.definition_structure = 'Job Flexfield' ) then
      if (Employee_Rec.job_id is not null) then
          stmt_flag := 'T';
      end if;
   if ((l_attribute_id <> prev_attribute_id) or  (prev_attribute_id = -1)) then
         l_sql_stmt := 'Select '||l_application_column_name||
                    ' From  Per_jobs,per_job_definitions '||
                    ' Where per_jobs.job_id = '||':lc_job_id'||
                    '   and per_jobs.job_definition_id = '||
                    ' per_job_definitions.job_definition_id';
         dbms_sql.parse(v_cursorid,l_sql_stmt,dbms_sql.v7);
         dbms_sql.define_column(v_cursorid,1,v_segment,80);


         if (stmt_flag = 'T') then
            le_effective_start_date := lpos_effective_start_date;
            le_effective_end_date := lpos_effective_end_date;
            dbms_sql.bind_variable(v_cursorid,':lc_job_id',Employee_Rec.job_id);
         end if;
      else
         if (stmt_flag = 'T') then
            dbms_sql.bind_variable(v_cursorid,':lc_job_id',Employee_Rec.job_id);
            le_effective_start_date := lpos_effective_start_date;
            le_effective_end_date := lpos_effective_end_date;
         end if;
      end if;
  elsif (Emp_attribute_rec.definition_structure = 'Position Flexfield') then
      if (Employee_rec.position_id is not null) then
         stmt_flag := 'T';
      end if;
   if ((l_attribute_id <> prev_attribute_id) or  (prev_attribute_id = -1)) then
         l_sql_stmt := 'Select '||l_application_column_name||
               ' From  hr_positions,per_position_definitions '||
               ' Where hr_positions.position_id = '||':lc_position_id'||
               '   and hr_positions.position_definition_id = '||
                    ' per_position_definitions.position_definition_id';
         dbms_sql.parse(v_cursorid,l_sql_stmt,dbms_sql.v7);
         dbms_sql.define_column(v_cursorid,1,v_segment,80);
        if (stmt_flag = 'T') then
            dbms_sql.bind_variable(v_cursorid,':lc_position_id',Employee_Rec.position_id);
         le_effective_start_date := lpos_effective_start_date;
         le_effective_end_date := lpos_effective_end_date;
        end if;
      else
        if (stmt_flag = 'T') then
           dbms_sql.bind_variable(v_cursorid,':lc_position_id',Employee_Rec.position_id);
         le_effective_start_date := lpos_effective_start_date;
         le_effective_end_date := lpos_effective_end_date;
        end if;
      end if;
   elsif (Emp_attribute_rec.definition_structure = 'Grade Flexfield') then
      if (Employee_rec.grade_id is not null) then
          stmt_flag := 'T';
      end if;
   if ((l_attribute_id <> prev_attribute_id) or  (prev_attribute_id = -1)) then
         l_sql_stmt := 'Select '||l_application_column_name||
               ' From  Per_grades,per_grade_definitions '||
               ' Where per_grades.grade_id = '||':lc_grade_id'||
               '   and per_grades.grade_definition_id = '||
                    ' per_grade_definitions.grade_definition_id';
         dbms_sql.parse(v_cursorid,l_sql_stmt,dbms_sql.v7);
         dbms_sql.define_column(v_cursorid,1,v_segment,80);
        if (stmt_flag = 'T') then
            dbms_sql.bind_variable(v_cursorid,':lc_grade_id',Employee_Rec.grade_id);
         le_effective_start_date := lemp_effective_start_date;
         le_effective_end_date := lemp_effective_end_date;
        end if;
      else
        if (stmt_flag = 'T') then
           dbms_sql.bind_variable(v_cursorid,':lc_grade_id',Employee_Rec.grade_id);
         le_effective_start_date := lemp_effective_start_date;
         le_effective_end_date := lemp_effective_end_date;
        end if;
      end if;
  elsif (Emp_attribute_rec.definition_structure = 'People Group Flexfield') then
      if (Employee_rec.people_group_id is not null) then
        stmt_flag := 'T';
      end if;
   if ((l_attribute_id <> prev_attribute_id) or  (prev_attribute_id = -1)) then
         l_sql_stmt := 'Select '||l_application_column_name||
               ' From  Pay_People_Groups'||
               ' Where pay_people_groups.people_group_id = '||
                 ':lc_people_group_id';
           dbms_sql.parse(v_cursorid,l_sql_stmt,dbms_sql.v7);
           dbms_sql.define_column(v_cursorid,1,v_segment,80);
        if (stmt_flag = 'T') then
           dbms_sql.bind_variable(v_cursorid,':lc_people_group_id',Employee_Rec.people_group_id);
           le_effective_start_date := lemp_effective_start_date;
           le_effective_end_date := lemp_effective_end_date;
        end if;
      else
        if (stmt_flag = 'T') then
           dbms_sql.bind_variable(v_cursorid,':lc_people_group_id',Employee_Rec.people_group_id);
           le_effective_start_date := lemp_effective_start_date;
           le_effective_end_date := lemp_effective_end_date;
        end if;
      end if;
elsif (Emp_attribute_rec.definition_structure = 'Cost Allocation Flexfield') then
      if (Employee_rec.assignment_id is not null) then
         stmt_flag := 'T';
      end if;
   if ((l_attribute_id <> prev_attribute_id) or  (prev_attribute_id = -1)) then
         l_sql_stmt := 'Select '||l_application_column_name||
                   ' From pay_cost_allocations,pay_cost_allocation_keyflex '||
                   ' Where pay_cost_allocations.assignment_id = '||
                     ':lc_assignment_id'||
             ' and pay_cost_allocations.cost_allocation_keyflex_id = '||
             ' pay_cost_allocation_keyflex.cost_allocation_keyflex_id '||
             ' order by pay_cost_allocations.proportion';
           dbms_sql.parse(v_cursorid,l_sql_stmt,dbms_sql.v7);
           dbms_sql.define_column(v_cursorid,1,v_segment,80);
        if (stmt_flag = 'T') then
           dbms_sql.bind_variable(v_cursorid,':lc_assignment_id',Employee_Rec.assignment_id);
           le_effective_start_date := lemp_effective_start_date;
           le_effective_end_date := lemp_effective_end_date;
        end if;
      else
        if (stmt_flag = 'T') then
        dbms_sql.bind_variable(v_cursorid,':lc_assignment_id',Employee_Rec.assignment_id);
           le_effective_start_date := lemp_effective_start_date;
           le_effective_end_date := lemp_effective_end_date;
        end if;
      end if;
elsif (Emp_attribute_rec.definition_structure = 'Soft Coded KeyFlexfield') then
      if (Employee_rec.soft_coding_keyflex_id is not null) then
        stmt_flag := 'T';
      end if;
   if ((l_attribute_id <> prev_attribute_id) or  (prev_attribute_id = -1)) then
         l_sql_stmt := 'Select '||l_application_column_name||
                   ' From hr_soft_coding_keyflex'||
                   ' Where hr_soft_coding_keyflex.soft_coding_keyflex_id = '||
                     ':lc_soft_coding_keyflex_id';
        dbms_sql.parse(v_cursorid,l_sql_stmt,dbms_sql.v7);
        dbms_sql.define_column(v_cursorid,1,v_segment,80);

        if (stmt_flag = 'T') then
           dbms_sql.bind_variable(v_cursorid,':lc_soft_coding_keyflex_id',Employee_Rec.soft_coding_keyflex_id);
           le_effective_start_date := lemp_effective_start_date;
           le_effective_end_date := lemp_effective_end_date;
        end if;
      else
        if (stmt_flag = 'T') then
        dbms_sql.bind_variable(v_cursorid,':lc_soft_coding_keyflex_id',Employee_Rec.soft_coding_keyflex_id);
           le_effective_start_date := lemp_effective_start_date;
           le_effective_end_date := lemp_effective_end_date;
       end if;
      end if;

elsif (Emp_attribute_rec.definition_structure = 'Personal Analysis Flexfield') then

     if (Employee_rec.person_id is not null) then
        stmt_flag := 'T';
     end if;

   if ((l_attribute_id <> prev_attribute_id) or  (prev_attribute_id = -1)) then

     l_sql_stmt := 'Select '||l_application_column_name||
                   ' From Per_Analysis_Criteria, Per_Person_Analyses'||
                   ' Where Per_Person_Analyses.person_id = :lc_person_id '||
                   ' And Per_person_analyses.id_flex_num = :lc_id_flex_num '||
                   ' And Per_person_analyses.analysis_criteria_id =  Per_analysis_criteria.analysis_criteria_id '||
                   ' And Per_person_analyses.id_flex_num = Per_analysis_criteria.id_flex_num';

        dbms_sql.parse(v_cursorid,l_sql_stmt,dbms_sql.v7);
        dbms_sql.define_column(v_cursorid,1,v_segment,80);
        dbms_sql.bind_variable(v_cursorid,':lc_id_flex_num', l_id_flex_num);

        if (stmt_flag = 'T') then

           dbms_sql.bind_variable(v_cursorid,':lc_person_id',Employee_Rec.person_id);

           le_effective_start_date := lemp_effective_start_date;
           le_effective_end_date := lemp_effective_end_date;

        end if;
     else
        if (stmt_flag = 'T') then
           dbms_sql.bind_variable(v_cursorid,':lc_person_id',Employee_Rec.person_id);
           le_effective_start_date := lemp_effective_start_date;
           le_effective_end_date := lemp_effective_end_date;
        end if;
      end if;
   end if;

   if (stmt_flag = 'T') then
    v_dummy := DBMS_SQL.EXECUTE(v_cursorid);

    loop
      ctr := ctr + 1;
      v_segment := '';
      if DBMS_SQL.FETCH_ROWS(v_cursorid) = 0 then
         exit;
      end if;
      dbms_sql.column_value(v_cursorid,1,v_segment);
      if (v_segment is not null) then
      if (ctr = 1) then

      INSERT INTO PSB_EMPLOYEE_ASSIGNMENTS_I
      ( HR_POSITION_ID  ,
        HR_EMPLOYEE_ID  ,
        DATA_EXTRACT_ID ,
        ATTRIBUTE_NAME  ,
        ATTRIBUTE_VALUE ,
        EFFECTIVE_START_DATE,
        EFFECTIVE_END_DATE ,
        LAST_UPDATE_DATE  ,
        LAST_UPDATED_BY  ,
        LAST_UPDATE_LOGIN ,
        CREATED_BY,
        CREATION_DATE
      )
      values
      (Employee_rec.position_id,
       Employee_rec.person_id,
       p_data_extract_id,
       Emp_attribute_rec.name,
       v_segment,
       le_effective_start_date,
       le_effective_end_date,
       l_last_update_date,
       l_last_updated_by,
       l_last_update_login,
       l_created_by,
       l_creation_date);
      end if;
      end if;
     end loop;
    end if;
    elsif (Emp_attribute_rec.definition_type = 'DFF') then
      /* Bug 4075170 Start */
      l_debug_info := 'Starting for person_id '||l_person_id||' definition type DFF';
      /* Bug 4075170 End */
   if ((l_attribute_id <> prev_attribute_id) or  (prev_attribute_id = -1)) then

      if (dbms_sql.IS_OPEN(v_dcursorid)) then
         dbms_sql.close_cursor(v_dcursorid);
      end if;

      l_attr_link_type := null;

      For C_dff_rec in C_dff_33
      Loop
         l_application_id            := C_dff_rec.application_id;
         l_application_table_name    := C_dff_rec.application_table_name;

        For C_dff_str_rec in C_dff_44
        Loop
          l_application_column_name := C_dff_str_rec.application_column_name;
        End Loop;
      End Loop;

    d_attribute_type := Emp_attribute_rec.definition_type;
    d_attribute_type_id := Emp_attribute_rec.attribute_type_id;

    For Attr_type_rec in C_Attribute_Types
    Loop

    Begin
       Select ltrim(rtrim(substr(Attr_type_rec.select_table,
              instr(Attr_type_rec.select_table,' ',1),
              length(Attr_type_rec.select_table) - instr(Attr_type_rec.select_table,' ',1) + 1))) into l_alias1
         from dual;
     end;

     if (Attr_type_rec.link_type = 'PER_ALL_ASSIGNMENTS') then
         l_emp_col := 'assignment_id';
         --l_emp_val := Employee_rec.assignment_id;
     elsif (Attr_type_rec.link_type = 'PER_ALL_PEOPLE') then
         l_emp_col := 'person_id';
         --l_emp_val := Employee_rec.person_id;
     elsif (Attr_type_rec.link_type = 'HR_ALL_POSITIONS') then
         l_emp_col := 'position_id';
         --l_emp_val := Employee_rec.position_id;
     end if;
     l_attr_link_type := Attr_type_rec.link_type;

     v_dcursorid := dbms_sql.open_cursor;

      /* bug no 3944599 */
     IF LTRIM(RTRIM(attr_type_rec.link_type)) = 'HR_ALL_POSITIONS' AND
        LTRIM(RTRIM(attr_type_rec.select_tab)) = 'PER_ALL_POSITIONS' AND
        LTRIM(RTRIM(attr_type_rec.name)) = 'PER_POSITIONS' THEN

         -- commented out l_alais1 as we are selecting from table HR_ALL_POSITIONS
       d_sql_stmt := 'Select '||/*l_alias1*/Attr_type_rec.l_alias2||'.'
                            ||l_application_column_name||
                     '  From '||Attr_type_rec.select_tab||' '||
                            l_alias1||' , '||
                     Attr_type_rec.link_type||' '||Attr_type_rec.l_alias2||
                     ' Where '||l_alias1||'.'||
                     Attr_type_rec.select_key||' = '||
                     Attr_type_rec.l_alias2||'.'||Attr_type_rec.link_key||
                     ' and '||Attr_type_rec.l_alias2||'.'||l_emp_col||
                     ' = '||':v_emp_val';
      ELSE
        d_sql_stmt := 'Select '||l_alias1||'.'
                            ||l_application_column_name||
                   '  From '||Attr_type_rec.select_tab||' '||
                            l_alias1||' , '||
                   Attr_type_rec.link_type||' '||Attr_type_rec.l_alias2||
                   ' Where '||l_alias1||'.'||
                     Attr_type_rec.select_key||' = '||
                     Attr_type_rec.l_alias2||'.'||Attr_type_rec.link_key||
                   ' and '||Attr_type_rec.l_alias2||'.'||l_emp_col||
                   ' = '||':v_emp_val';
     END IF;
     /* bug no 3944599 */

     if (Attr_type_rec.select_where is not null) then
        d_sql_stmt := d_sql_stmt||' and '||Attr_type_rec.select_where;
     end if;

    dbms_sql.parse(v_dcursorid,d_sql_stmt,dbms_sql.v7);
    dbms_sql.define_column(v_dcursorid,1,v_dsegment,80);
    end loop;

    /* Start bug #4302946 */
    IF (l_attr_link_type IS NULL) THEN
      FND_MESSAGE.SET_NAME('PSB','PSB_ATTR_MAPPING_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', l_attribute_name);
      l_message_text := FND_MESSAGE.GET;
      FND_FILE.PUT_LINE(FND_FILE.LOG, l_message_text);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    /* End bug #4302946 */

   end if;

     if (l_attr_link_type = 'PER_ALL_ASSIGNMENTS') then
         l_emp_val := Employee_rec.assignment_id;
         le_effective_start_date := lemp_effective_start_date;
         le_effective_end_date   := lemp_effective_end_date;
     elsif (l_attr_link_type = 'PER_ALL_PEOPLE') then
         l_emp_val := Employee_rec.person_id;
         le_effective_start_date := lemp_effective_start_date;
         le_effective_end_date   := lemp_effective_end_date;
     elsif (l_attr_link_type = 'HR_ALL_POSITIONS') then
         l_emp_val := Employee_rec.position_id;
         le_effective_start_date := lpos_effective_start_date;
         le_effective_end_date   := lpos_effective_end_date;
     end if;

   if (l_emp_val is not null) then
    dbms_sql.bind_variable(v_dcursorid,':v_emp_val',l_emp_val);

    v_ddummy := DBMS_SQL.EXECUTE(v_dcursorid);

   loop
      if DBMS_SQL.FETCH_ROWS(v_dcursorid) = 0 then
         exit;
      end if;

      dbms_sql.column_value(v_dcursorid,1,v_dsegment);

     if (v_dsegment is not null) then

      /* Bug 4075170 Start */
      l_debug_info := 'Inserting for Atrribute Name '
                      ||Emp_attribute_rec.name
                      ||', Atrribute Data Type '||l_data_type
                      ||', Atrribute Value '||v_dsegment;
      /* Bug 4075170 End */

      INSERT INTO PSB_EMPLOYEE_ASSIGNMENTS_I
      ( HR_POSITION_ID  ,
        HR_EMPLOYEE_ID  ,
        DATA_EXTRACT_ID ,
        ATTRIBUTE_NAME  ,
        ATTRIBUTE_VALUE ,
        EFFECTIVE_START_DATE,
        EFFECTIVE_END_DATE ,
        LAST_UPDATE_DATE  ,
        LAST_UPDATED_BY  ,
        LAST_UPDATE_LOGIN ,
        CREATED_BY,
        CREATION_DATE
      )
      values
      (Employee_rec.position_id,
       Employee_rec.person_id,
       p_data_extract_id,
       Emp_attribute_rec.name,

       -- Fix for bug #4075170 changed the date format to canonical.
       -- But since DFF always stores date in canonical format, this conversion is not
       -- necessary. So removed the conversion as part for Bug #4658351.
       v_dsegment,

       le_effective_start_date,
       le_effective_end_date,
       l_last_update_date,
       l_last_updated_by,
       l_last_update_login,
       l_created_by,
       l_creation_date);
      end if;
    end loop;
   end if;
   elsif (Emp_attribute_rec.definition_type = 'QC') then
     /* Bug 4075170 Start */
     l_debug_info := 'Starting for person_id '||l_person_id||' definition type QC';
     /* Bug 4075170 End */

   if ((l_attribute_id <> prev_attribute_id) or (prev_attribute_id = -1)) then
    if dbms_sql.is_open(v_qcursorid) then
       dbms_sql.close_cursor(v_qcursorid);
    end if;

    d_attribute_type := Emp_attribute_rec.definition_type;
    d_attribute_type_id := Emp_attribute_rec.attribute_type_id;

    l_attr_link_type := null;

    For Attr_type_rec in C_Attribute_Types
    Loop
     if (Attr_type_rec.link_type = 'PER_ALL_ASSIGNMENTS') then
         l_emp_col := 'assignment_id';
         --l_emp_val := Employee_rec.assignment_id;
     elsif (Attr_type_rec.link_type = 'PER_ALL_PEOPLE') then
         l_emp_col := 'person_id';
         --l_emp_val := Employee_rec.person_id;
     elsif (Attr_type_rec.link_type = 'HR_ALL_POSITIONS') then
         l_emp_col := 'position_id';
         --l_emp_val := Employee_rec.position_id;
     end if;

     l_lookup_type := Attr_type_rec.name;
     l_attr_link_type := Attr_type_rec.link_type;

     Begin
       Select ltrim(rtrim(substr(Attr_type_rec.select_table,
              instr(Attr_type_rec.select_table,' ',1),
              length(Attr_type_rec.select_table) - instr(Attr_type_rec.select_table,' ',1) + 1))) into l_alias1
         from dual;
     end;

    --if (l_emp_val is not null) then
     v_qcursorid := dbms_sql.open_cursor;
     q_sql_stmt := 'Select a.meaning '||
                   '  From Fnd_Common_lookups a , '||
                    Attr_type_rec.select_tab||' '||l_alias1||' ,'||
                    Attr_type_rec.link_type||' '||Attr_type_rec.l_alias2||
                   ' Where a.lookup_type = '||''''||
                   l_lookup_type||''''||
                   ' and a.lookup_code = '||
                     l_alias1||'.'||Attr_type_rec.select_column||
                   ' and '||l_alias1||'.'||Attr_type_rec.select_key||
                   ' = '||Attr_type_rec.l_alias2||'.'||Attr_type_rec.link_key||
                   ' and '||Attr_type_rec.l_alias2||'.'||l_emp_col||
                   ' = '||':v_emp_val';

     if (Attr_type_rec.select_where is not null) then
        q_sql_stmt := q_sql_stmt||' and '||Attr_type_rec.select_where;
     end if;

    dbms_sql.parse(v_qcursorid,q_sql_stmt,dbms_sql.v7);
    dbms_sql.define_column(v_qcursorid,1,v_qsegment,80);
    end loop;

    /* Start bug #4302946 */
    IF (l_attr_link_type IS NULL) THEN
      FND_MESSAGE.SET_NAME('PSB','PSB_ATTR_MAPPING_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', l_attribute_name);
      l_message_text := FND_MESSAGE.GET;
      FND_FILE.PUT_LINE(FND_FILE.LOG, l_message_text);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    /* End bug #4302946 */

   end if;

    if (l_attr_link_type = 'PER_ALL_ASSIGNMENTS') then
         l_emp_val := Employee_rec.assignment_id;
         le_effective_start_date   := lemp_effective_start_date;
         le_effective_end_date     := lemp_effective_end_date;
    elsif (l_attr_link_type = 'PER_ALL_PEOPLE') then
         l_emp_val := Employee_rec.person_id;
         le_effective_start_date   := lemp_effective_start_date;
         le_effective_end_date     := lemp_effective_end_date;
    elsif (l_attr_link_type = 'HR_ALL_POSITIONS') then
         l_emp_val := Employee_rec.position_id;
         le_effective_start_date   := lpos_effective_start_date;
         le_effective_end_date     := lpos_effective_end_date;
    end if;

    if (l_emp_val is not null) then
    dbms_sql.bind_variable(v_qcursorid,':v_emp_val',l_emp_val);

    v_qdummy := DBMS_SQL.EXECUTE(v_qcursorid);

    loop
      if DBMS_SQL.FETCH_ROWS(v_qcursorid) = 0 then
         exit;
      end if;

      dbms_sql.column_value(v_qcursorid,1,v_qsegment);

     if (v_qsegment is not null) then

      /* Bug 4075170 Start */
      l_debug_info := 'Inserting for Atrribute Id '
                      ||Emp_attribute_rec.name
                      ||', Atrribute Data Type '||l_data_type
                      ||', Atrribute Value '||v_qsegment;
      /* Bug 4075170 End */

      -- Bug #4658351
      -- Moved the date format conversion out of the insert statement.

      if (l_data_type = 'D') then
        begin
          v_qsegment := Fnd_Date.Date_to_Canonical(v_qsegment);
        exception
          when OTHERS then
            FND_MESSAGE.SET_NAME('PSB', 'PSB_ATTRIBUTE_VALUE_DATE_ERR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', l_attribute_name);
            l_message_text := fnd_message.get;
            RAISE_APPLICATION_ERROR(-20001,l_message_text);
         end;
      end if;

      INSERT INTO PSB_EMPLOYEE_ASSIGNMENTS_I
      ( HR_POSITION_ID  ,
        HR_EMPLOYEE_ID  ,
        DATA_EXTRACT_ID ,
        ATTRIBUTE_NAME  ,
        ATTRIBUTE_VALUE ,
        EFFECTIVE_START_DATE,
        EFFECTIVE_END_DATE ,
        LAST_UPDATE_DATE  ,
        LAST_UPDATED_BY  ,
        LAST_UPDATE_LOGIN ,
        CREATED_BY,
        CREATION_DATE
      )
      values
      (Employee_rec.position_id,
       Employee_rec.person_id,
       p_data_extract_id,
       Emp_attribute_rec.name,

       -- Bug #4658351
       -- Moved the date format conversion out of the insert statement.
       v_qsegment,

       le_effective_start_date,
       le_effective_end_date,
       l_last_update_date,
       l_last_updated_by,
       l_last_update_login,
       l_created_by,
       l_creation_date);
      end if;
    end loop;
    end if;
  elsif (Emp_attribute_rec.definition_type = 'TABLE') then
    /* Bug 4075170 Start */
    l_debug_info := 'Starting for person_id '||l_person_id||' definition type TABLE';
    /* Bug 4075170 End */

   if ((l_attribute_id <> prev_attribute_id) or (prev_attribute_id = -1)) then
      if dbms_sql.is_open(v_ocursorid) then
         dbms_sql.close_cursor(v_ocursorid);
      end if;

   d_attribute_type := Emp_attribute_rec.definition_type;
   d_attribute_type_id := Emp_attribute_rec.attribute_type_id;
   l_attr_link_type := null;

   For Attr_type_rec in C_Attribute_Types
   Loop
     if (Attr_type_rec.link_type = 'PER_ALL_ASSIGNMENTS') then
         l_emp_col := 'assignment_id';
         --l_emp_val := Employee_rec.assignment_id;
     elsif (Attr_type_rec.link_type = 'PER_ALL_PEOPLE') then
         l_emp_col := 'person_id';
         --l_emp_val := Employee_rec.person_id;
     elsif (Attr_type_rec.link_type = 'HR_ALL_POSITIONS') then
         l_emp_col := 'position_id';
         --l_emp_val := Employee_rec.position_id;
     end if;

     l_attr_link_type := Attr_type_rec.link_type;
     v_ocursorid := dbms_sql.open_cursor;
     Begin
       Select ltrim(rtrim(substr(Attr_type_rec.select_table,
              instr(Attr_type_rec.select_table,' ',1),
              length(Attr_type_rec.select_table) - instr(Attr_type_rec.select_table,' ',1) + 1))) into l_alias1
         from dual;
     End;

     if (Attr_type_rec.select_table = Attr_type_rec.link_type) then
        o_sql_stmt := 'Select '||
                      Attr_type_rec.select_column||
                   '  From '||Attr_type_rec.select_tab||
                   '  Where '||Attr_type_rec.select_tab||'.'||l_emp_col||
                   ' = '||':v_emp_val';
     else
        o_sql_stmt := 'Select '||l_alias1||'.'||
                      Attr_type_rec.select_column||
                   '  From '||Attr_type_rec.select_tab||' '||l_alias1||' , '||
                      Attr_type_rec.link_type||' '||Attr_type_rec.l_alias2||
                    ' Where '||l_alias1||'.'||
                      Attr_type_rec.select_key||' = '||
                      Attr_type_rec.l_alias2||'.'||Attr_type_rec.link_key||
                    ' and '||Attr_type_rec.l_alias2||'.'||l_emp_col||
                    ' = '||':v_emp_val';
     end if;

     if (Attr_type_rec.select_where is not null) then
        o_sql_stmt := o_sql_stmt||' and '||Attr_type_rec.select_where;
     end if;

    dbms_sql.parse(v_ocursorid,o_sql_stmt,dbms_sql.v7);

    if (Emp_attribute_rec.data_type = 'D') then
       dbms_sql.define_column(v_ocursorid,1,v_odate);
    elsif (Emp_attribute_rec.data_type = 'N') then
       dbms_sql.define_column(v_ocursorid,1,v_onumber);
    elsif (Emp_attribute_rec.data_type = 'C') then
       dbms_sql.define_column(v_ocursorid,1,v_osegment,80);
    end if;

   end loop;

   /* Start bug #4302946 */
   IF (l_attr_link_type IS NULL) THEN
     FND_MESSAGE.SET_NAME('PSB','PSB_ATTR_MAPPING_NOT_FOUND');
     FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', l_attribute_name);
     l_message_text := FND_MESSAGE.GET;
     FND_FILE.PUT_LINE(FND_FILE.LOG, l_message_text);
     RAISE FND_API.G_EXC_ERROR;
   END IF;
   /* End bug #4302946 */

  end if;

    if (l_attr_link_type = 'PER_ALL_ASSIGNMENTS') then
         l_emp_val := Employee_rec.assignment_id;
         le_effective_start_date   := lemp_effective_start_date;
         le_effective_end_date     := lemp_effective_end_date;
    elsif (l_attr_link_type = 'PER_ALL_PEOPLE') then
         l_emp_val := Employee_rec.person_id;
         le_effective_start_date   := lemp_effective_start_date;
         le_effective_end_date     := lemp_effective_end_date;
    elsif (l_attr_link_type = 'HR_ALL_POSITIONS') then
         l_emp_val := Employee_rec.position_id;
         le_effective_start_date   := lpos_effective_start_date;
         le_effective_end_date     := lpos_effective_end_date;
    end if;

   if (l_emp_val is not null) then
    dbms_sql.bind_variable(v_ocursorid,':v_emp_val',l_emp_val);
    v_odummy := DBMS_SQL.EXECUTE(v_ocursorid);

   loop
      if DBMS_SQL.FETCH_ROWS(v_ocursorid) = 0 then
         exit;
      end if;
      if (Emp_attribute_rec.data_type = 'D') then
       begin
         dbms_sql.column_value(v_ocursorid,1,v_odate);
         v_osegment := fnd_date.date_to_canonical(v_odate);
       exception
       when OTHERS then -- Bug #4658351: Changed VALUE_ERROR to OTHERS

         -- Changed the exception part for Bug#4658351
         FND_MESSAGE.SET_NAME('PSB', 'PSB_ATTRIBUTE_VALUE_DATE_ERR');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', l_attribute_name);
         l_message_text := fnd_message.get;
         RAISE_APPLICATION_ERROR(-20001,l_message_text);

      end;
      elsif (Emp_attribute_rec.data_type = 'N') then
      begin
         dbms_sql.column_value(v_ocursorid,1,v_onumber);
         v_osegment := fnd_number.number_to_canonical(v_onumber);
      exception
       when INVALID_NUMBER then

         -- Changed the exception part for Bug#4658351
         FND_MESSAGE.SET_NAME('PSB', 'PSB_ATTRIBUTE_VALUE_NUMBER_ERR');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', l_attribute_name);
         l_message_text := fnd_message.get;
         RAISE_APPLICATION_ERROR(-20000,l_message_text);

      end;

      elsif (Emp_attribute_rec.data_type = 'C') then
        dbms_sql.column_value(v_ocursorid,1,v_osegment);
      end if;

     if (v_osegment is not null) then

      INSERT INTO PSB_EMPLOYEE_ASSIGNMENTS_I
      ( HR_POSITION_ID  ,
        HR_EMPLOYEE_ID  ,
        DATA_EXTRACT_ID ,
        ATTRIBUTE_NAME  ,
        ATTRIBUTE_VALUE ,
        EFFECTIVE_START_DATE,
        EFFECTIVE_END_DATE ,
        LAST_UPDATE_DATE  ,
        LAST_UPDATED_BY  ,
        LAST_UPDATE_LOGIN ,
        CREATED_BY,
        CREATION_DATE
      )
      values
      (Employee_rec.position_id,
       Employee_rec.person_id,
       p_data_extract_id,
       Emp_attribute_rec.name,
       v_osegment,
       le_effective_start_date,
       le_effective_end_date,
       l_last_update_date,
       l_last_updated_by,
       l_last_update_login,
       l_created_by,
       l_creation_date);
      end if;
    end loop;
    end if;
    /*bug:7114143:Modified the if condition on defition_type to check if the value is 'NONE' */
  elsif (Emp_attribute_rec.definition_type = 'NONE') then
    /* Bug 4075170 Start */
    l_debug_info := 'Starting for person_id '||l_person_id
                    ||' definition type NULL'
                    ||' system_attr_type '
                    ||Emp_attribute_rec.system_attribute_type;
    /* Bug 4075170 End */
   if (Emp_attribute_rec.system_attribute_type = 'JOB_CLASS') then

   -- Commented out for bug number 3159157
   /*if ((l_attribute_id <> prev_attribute_id) or (prev_attribute_id = -1)) then
      For C_job_structure_rec in C_job_structure
      Loop
        l_id_flex_num := C_job_structure_rec.job_structure;
      End Loop;

      if dbms_sql.is_open(v_jcursorid) then
         dbms_sql.close_cursor(v_jcursorid);
      end if;

      v_jcursorid := DBMS_SQL.OPEN_CURSOR;
      l_job_stmt := 'Select concatenated_segments '||
                    'from per_jobs pj,per_job_definitions_kfv pjv '||
                    'where  pj.job_id = '||':lc_job_id'||
                    ' and  pj.job_definition_id = pjv.job_definition_id '||
                    ' and  pjv.id_flex_num = '||l_id_flex_num;

     dbms_sql.parse(v_jcursorid,l_job_stmt,dbms_sql.v7);
     dbms_sql.define_column(v_jcursorid,1,l_concatenated_segments,80);
   end if;*/

   l_job_id   := Employee_rec.job_id;
   le_effective_start_date   := lpos_effective_start_date;
   le_effective_end_date     := lpos_effective_end_date;

   -- Commented out for bug number 3159157
   /*dbms_sql.bind_variable(v_jcursorid,':lc_job_id',l_job_id);
   v_jdummy := DBMS_SQL.EXECUTE(v_jcursorid);*/

   For C_job_name_rec in C_job_name
   Loop
      l_job_name := C_job_name_rec.name;
   End Loop;

   INSERT INTO PSB_EMPLOYEE_ASSIGNMENTS_I
   ( HR_POSITION_ID  ,
     HR_EMPLOYEE_ID  ,
     DATA_EXTRACT_ID ,
     ATTRIBUTE_NAME  ,
     ATTRIBUTE_VALUE ,
     EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE ,
     LAST_UPDATE_DATE  ,
     LAST_UPDATED_BY  ,
     LAST_UPDATE_LOGIN ,
     CREATED_BY,
     CREATION_DATE
   )
   values
   (Employee_rec.position_id,
    Employee_rec.person_id,
    p_data_extract_id,
    Emp_attribute_rec.name,
    l_job_name,
    le_effective_start_date,
    le_effective_end_date,
    l_last_update_date,
    l_last_updated_by,
    l_last_update_login,
    l_created_by,
    l_creation_date);
   elsif (Emp_attribute_rec.system_attribute_type = 'ORG') then

     l_organization_id         := Employee_Rec.organization_id;
     le_effective_start_date   := lpos_effective_start_date;
     le_effective_end_date     := lpos_effective_end_date;

     For C_Org_Rec in C_Pos_Org
     Loop
       l_organization_name := C_Org_Rec.name;
     End Loop;

   INSERT INTO PSB_EMPLOYEE_ASSIGNMENTS_I
   ( HR_POSITION_ID  ,
     HR_EMPLOYEE_ID  ,
     DATA_EXTRACT_ID ,
     ATTRIBUTE_NAME  ,
     ATTRIBUTE_VALUE ,
     EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE ,
     LAST_UPDATE_DATE  ,
     LAST_UPDATED_BY  ,
     LAST_UPDATE_LOGIN ,
     CREATED_BY,
     CREATION_DATE
   )
   values
   (Employee_rec.position_id,
    Employee_rec.person_id,
    p_data_extract_id,
    Emp_attribute_rec.name,
    l_organization_name,
    le_effective_start_date,
    le_effective_end_date,
    l_last_update_date,
    l_last_updated_by,
    l_last_update_login,
    l_created_by,
    l_creation_date);
  elsif (Emp_attribute_rec.system_attribute_type = 'FTE') then
    -- Handle Fte Code
    l_fte := null;
    lp_fte := null;
    le_effective_start_date := null;
    le_effective_end_date   := null;

    /*For Bug No : 2109120 Start*/
    /*if (Employee_Rec.fte is not null) then
       l_fte                     := Employee_Rec.fte;
       le_effective_start_date   := lpos_effective_start_date;
       le_effective_end_date     := lpos_effective_end_date;
    else
       l_assignment_id := Employee_Rec.assignment_id;
       For C_Fte_Rec in C_Fte
       Loop
         l_fte                   := C_Fte_Rec.value;
         le_effective_start_date := lemp_effective_start_date;
         le_effective_end_date   := lemp_effective_end_date;
       End Loop;
    end if; */

    IF (Employee_Rec.assignment_id IS NOT NULL) THEN

      /* Bug 5004141 Start */
      -- l_fte := 1;
      IF Employee_Rec.position_type = 'SINGLE' THEN
        l_fte := Employee_Rec.fte;
      ELSE
        l_fte := 1;
      END IF;
      /* Bug 5004141 End */

      l_assignment_id := Employee_Rec.assignment_id;
      For C_Fte_Rec in C_Fte Loop
        l_fte                   := C_Fte_Rec.value;
      End Loop;

      le_effective_start_date := lemp_effective_start_date;
      le_effective_end_date   := lemp_effective_end_date;

    ELSIF (Employee_Rec.position_type <> 'SINGLE') THEN

      FOR C_check_FTE_rec IN C_check_FTE(Employee_Rec.position_id) LOOP
        l_fte := Employee_Rec.fte - C_check_FTE_rec.sum_fte;
      END LOOP;

      IF l_fte IS NULL THEN
        l_fte := Employee_Rec.fte;
      END IF;

      le_effective_start_date   := lpos_effective_start_date;
      le_effective_end_date     := lpos_effective_end_date;

    ELSE

      l_fte                     := Employee_Rec.fte;
    /* start bug 4153562 */
    --  The l_date_rec cursor takes position_id as the input
    --  and returns the start date for that position. This
    --  will run only for the terminated position and when the
    --  data extract mode is refresh. When the start date is passed
    --  as end date, the procedure will end date and create a new
    --  record for the attribute.
    --  le_effective_start_date   := lpos_effective_start_date;
    if p_extract_method = 'REFRESH' then
      FOR l_date_rec IN (
                          SELECT effective_start_date
                          FROM (
                          SELECT a.effective_start_date
                          FROM   per_all_assignments_f a,
                                 fnd_sessions b,
                                 per_assignment_status_types c
                          WHERE  a.position_id = Employee_rec.position_id
                          AND    a.assignment_status_type_id = c.assignment_status_type_id
                          AND    c.per_system_status = 'TERM_ASSIGN'
                          AND    b.effective_date BETWEEN a.effective_start_date
                                 AND to_date('31124712','DDMMYYYY')
                          AND    b.session_id = userenv('sessionid')
                          ORDER BY a.effective_start_date DESC
                          )
                          WHERE ROWNUM <= 1
                        ) LOOP

        lv_effective_end_date := l_date_rec.effective_start_date;

      END LOOP;

      IF lv_effective_end_date is not null THEN
        le_effective_start_date   := lv_effective_end_date;
      ELSE
        le_effective_start_date   := lpos_effective_start_date;
      END IF;

    else
      le_effective_start_date   := lpos_effective_start_date;
    end if;
    /* End bug 4153562 */

      le_effective_end_date     := lpos_effective_end_date;

    END IF;

    /*For Bug No : 2109120 End*/

   if (l_fte is not null) then

   lp_fte := fnd_number.number_to_canonical(l_fte);

   INSERT INTO PSB_EMPLOYEE_ASSIGNMENTS_I
   ( HR_POSITION_ID  ,
     HR_EMPLOYEE_ID  ,
     DATA_EXTRACT_ID ,
     ATTRIBUTE_NAME  ,
     ATTRIBUTE_VALUE ,
     EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE ,
     LAST_UPDATE_DATE  ,
     LAST_UPDATED_BY  ,
     LAST_UPDATE_LOGIN ,
     CREATED_BY,
     CREATION_DATE
   )
   values
   (Employee_rec.position_id,
    Employee_rec.person_id,
    p_data_extract_id,
    Emp_attribute_rec.name,
    lp_fte,
    le_effective_start_date,
    le_effective_end_date,
    l_last_update_date,
    l_last_updated_by,
    l_last_update_login,
    l_created_by,
    l_creation_date);
    end if;
  elsif (Emp_attribute_rec.system_attribute_type = 'DEFAULT_WEEKLY_HOURS') then
   -- Handle Default Weekly hours
    l_default_weekly_hours := null;
    lp_default_weekly_hours := null;
    le_effective_start_date := null;
    le_effective_end_date   := null;

    /*For Bug No : 2370607 Start*/
    --changed the condition from frequency to working_hours
    --and added the inner if condition
    if (Employee_Rec.working_hours is not null) then
       l_default_weekly_hours    := Employee_Rec.working_hours;
       lp_default_weekly_hours   := fnd_number.number_to_canonical(l_default_weekly_hours);

       if(Employee_Rec.freq_flag = 'P') then

         /* start bug 4153562 */

         --  The l_date_rec cursor takes position_id as the input
         --  and returns the start date for that position. This
         --  will run only for the terminated position and when the
         --  data extract mode is refresh. When the start date is passed
         --  as end date, the procedure will end date and create a new
         --  record for the attribute.

         if p_extract_method = 'REFRESH' AND Employee_Rec.assignment_id IS NULL then
           if Employee_Rec.position_type = 'SINGLE' then

             FOR l_date_rec IN ( SELECT effective_start_date
                                 FROM (
                                        SELECT a.effective_start_date
                                        FROM   per_all_assignments_f a,
                                               fnd_sessions b,
                                               per_assignment_status_types c
                                        WHERE  a.position_id = Employee_rec.position_id
                                        AND    a.assignment_status_type_id = c.assignment_status_type_id
                                        AND    c.per_system_status = 'TERM_ASSIGN'
                                        AND    b.effective_date BETWEEN a.effective_start_date
                                                                AND to_date('31124712','DDMMYYYY')
                                        AND    b.session_id = userenv('sessionid')
                                        ORDER BY a.effective_start_date DESC
                                       )
                                 WHERE ROWNUM <= 1
                               ) LOOP

               lv_effective_end_date := l_date_rec.effective_start_date;
             END LOOP;

            IF lv_effective_end_date is not null THEN
              le_effective_start_date   := lv_effective_end_date;
            ELSE
              le_effective_start_date   := lpos_effective_start_date;
            END IF;
          else
            le_effective_start_date   := lpos_effective_start_date;
          end if;
         else
	  le_effective_start_date   := lpos_effective_start_date;
         end if;

         -- le_effective_start_date   := lpos_effective_start_date;
        /* end bug 4153562 */

         le_effective_end_date     := lpos_effective_end_date;
       else
         le_effective_start_date   := lemp_effective_start_date;
         le_effective_end_date     := lemp_effective_end_date;
       end if;

    /*For Bug No : 2370607 End*/

       INSERT INTO PSB_EMPLOYEE_ASSIGNMENTS_I
       ( HR_POSITION_ID  ,
        HR_EMPLOYEE_ID  ,
        DATA_EXTRACT_ID ,
        ATTRIBUTE_NAME  ,
        ATTRIBUTE_VALUE ,
        EFFECTIVE_START_DATE,
        EFFECTIVE_END_DATE ,
        LAST_UPDATE_DATE  ,
        LAST_UPDATED_BY  ,
        LAST_UPDATE_LOGIN ,
        CREATED_BY,
        CREATION_DATE
      )
      values
      (Employee_rec.position_id,
       Employee_rec.person_id,
       p_data_extract_id,
       Emp_attribute_rec.name,
       lp_default_weekly_hours,
       le_effective_start_date,
       le_effective_end_date,
       l_last_update_date,
       l_last_updated_by,
       l_last_update_login,
       l_created_by,
       l_creation_date);
    end if;
  /*For Bug No : 2109120 Start*/
  --added the persion_id condition in the following line
  elsif (Emp_attribute_rec.system_attribute_type = 'HIREDATE'
         AND Employee_Rec.person_id IS NOT NULL) then
  /*For Bug No : 2109120 End*/
     l_hiredate := null;
     lp_hiredate := null;

     /*For Bug No : 2109120 Start*/
     l_person_id               := Employee_Rec.person_id;
     For C_Hiredate_Rec in C_Hiredate
     Loop
       l_hiredate := C_Hiredate_Rec.original_date_of_hire;  --bug:7623053:modified
       le_effective_start_date := lemp_effective_start_date;
       le_effective_end_date   := lemp_effective_end_date;
     End Loop;

     /*For Bug No : 2109120 End*/


      if (l_hiredate is not null) then
       lp_hiredate := fnd_date.date_to_canonical(l_hiredate);
       INSERT INTO PSB_EMPLOYEE_ASSIGNMENTS_I
       ( HR_POSITION_ID  ,
        HR_EMPLOYEE_ID  ,
        DATA_EXTRACT_ID ,
        ATTRIBUTE_NAME  ,
        ATTRIBUTE_VALUE ,
        EFFECTIVE_START_DATE,
        EFFECTIVE_END_DATE ,
        LAST_UPDATE_DATE  ,
        LAST_UPDATED_BY  ,
        LAST_UPDATE_LOGIN ,
        CREATED_BY,
        CREATION_DATE
      )
      values
      (Employee_rec.position_id,
       Employee_rec.person_id,
       p_data_extract_id,
       Emp_attribute_rec.name,
       lp_hiredate,
       le_effective_start_date,
       le_effective_end_date,
       l_last_update_date,
       l_last_updated_by,
       l_last_update_login,
       l_created_by,
       l_creation_date);
    end if;
  end if;
  end if;
  prev_attribute_id := l_attribute_id;

  end loop; --C_Employees


  if (dbms_sql.is_open(v_cursorid)) then
      dbms_sql.close_cursor(v_cursorid);
  end if;

  if (dbms_sql.is_open(v_dcursorid)) then
      dbms_sql.close_cursor(v_dcursorid);
  end if;

  if (dbms_sql.is_open(v_qcursorid)) then
      dbms_sql.close_cursor(v_qcursorid);
  end if;

  if (dbms_sql.is_open(v_ocursorid)) then
      dbms_sql.close_cursor(v_ocursorid);
  end if;

  if (dbms_sql.is_open(v_jcursorid)) then
      dbms_sql.close_cursor(v_jcursorid);
  end if;

  prev_attribute_id := l_attribute_id;

end loop; --C_Emp_Attributes

  --
  -- Updating 'FTE' information for the position assignments.
  --

  --
  -- Loop to get all the pooled position where 'FTE' is define at the
  -- position level. As the attribute_value will be same for all instances
  -- of the pooled positions, using max to pick up any one.  The HAVING
  -- clause ensures the query picks up pooled positions only.
  --
  l_link_type := null;
  FOR l_fte_link_rec IN
  (
    SELECT link_type
      from PSB_ATTRIBUTES_VL a, PSB_ATTRIBUTE_TYPES B
     WHERE a.business_group_id = p_business_group_id
       AND a.system_attribute_type = 'FTE'
       AND a.attribute_type_id = b.attribute_type_id
  )
  LOOP
    l_link_type := l_fte_link_rec.link_type;
  END LOOP;


  if (l_link_type  = 'P') then
  FOR l_emp_assgn_rec IN
  (
    SELECT hr_position_id                         ,
           MAX(attribute_value)   total_fte       ,
           COUNT(hr_employee_id)  total_employees
    FROM   psb_employee_assignments_i
    WHERE  data_extract_id = p_data_extract_id
    AND    attribute_value IS NOT NULL
    AND    hr_employee_id  IS NOT NULL
    AND    attribute_name IN
           (
             SELECT name
             FROM   psb_attributes_VL
             WHERE  system_attribute_type = 'FTE'
             AND    business_group_id     = p_business_group_id
           )
    GROUP  BY  hr_position_id
    HAVING COUNT(hr_position_id) > 1
  )
  LOOP

    -- Find the average FTE to be divided among the employees.
    l_average_fte := ROUND (l_emp_assgn_rec.total_fte /
                     l_emp_assgn_rec.total_employees, 2 )  ;

    l_allocated_fte := 0 ;

    -- Distribute average FTE to all the employees associated with the
    -- pooled positions.
    FOR l_emp_rec IN
    ( SELECT ROWID,
             ROWNUM
      FROM   psb_employee_assignments_i
      WHERE  hr_position_id = l_emp_assgn_rec.hr_position_id
        AND  data_extract_id = p_data_extract_id
        AND  attribute_value IS NOT NULL
        AND  hr_employee_id  IS NOT NULL
        AND  attribute_name IN
             (
             SELECT name
             FROM   psb_attributes
             WHERE  system_attribute_type = 'FTE'
             AND    business_group_id     = p_business_group_id
           )
    )
    LOOP

      --
      -- The allocate FTE must equal the total_fte. The following will ensure
      -- that the last employee will get the remaining of the FTE.
      --
      IF l_emp_rec.rownum = l_emp_assgn_rec.total_employees THEN
        l_fte := l_emp_assgn_rec.total_fte - l_allocated_fte ;
      ELSE
        l_fte := l_average_fte ;
      END IF ;

      -- Update the FTE information.
      UPDATE psb_employee_assignments_i
      SET    attribute_value = l_fte
      WHERE  rowid           = l_emp_rec.rowid ;

      l_allocated_fte := l_allocated_fte + l_fte ;

    END LOOP ; -- End distributing average FTE.

  END LOOP ; -- End processing all the pooled positions.

  --
  -- End updating 'FTE' information.
  --
  end if;

  Update_Reentry
 ( p_api_version              => 1.0  ,
   p_return_status            => l_return_status,
   p_msg_count                => l_msg_count,
   p_msg_data                 => l_msg_data,
   p_data_extract_id          => p_data_extract_id,
   p_extract_method           => p_extract_method,
   p_process                  => 'Position Assignments Interface',
   p_restart_id               => prev_attribute_id
  );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     raise FND_API.G_EXC_ERROR;
  end if;

  Reentrant_Process
  ( p_api_version              => 1.0  ,
    p_return_status            => l_return_status,
    p_msg_count                => l_msg_count,
    p_msg_data                 => l_msg_data,
    p_data_extract_id          => p_data_extract_id,
    p_extract_method           => p_extract_method,
    p_process                  => 'Position Assignments Interface'
  );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     raise FND_API.G_EXC_ERROR;
  end if;

 end if;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     /* Bug 4075170 Start */
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Last Status::>'||l_debug_info);
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Parameter Info::'||l_param_info);
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error Type:: FND_API.G_EXC_ERROR');
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Get_Employee_Attributes API '
                                      ||'failed due to the following error');
     FND_FILE.PUT_LINE(FND_FILE.LOG, sqlerrm);
     /* Bug 4075170 End */

     if (dbms_sql.is_open(v_cursorid)) then
        dbms_sql.close_cursor(v_cursorid);
     end if;

     if (dbms_sql.is_open(v_dcursorid)) then
        dbms_sql.close_cursor(v_dcursorid);
     end if;

     if (dbms_sql.is_open(v_qcursorid)) then
        dbms_sql.close_cursor(v_qcursorid);
     end if;

     if (dbms_sql.is_open(v_ocursorid)) then
        dbms_sql.close_cursor(v_ocursorid);
     end if;

     if (dbms_sql.is_open(v_jcursorid)) then
        dbms_sql.close_cursor(v_jcursorid);
     end if;

     rollback to Get_Employee_Attributes;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                 p_data  => p_msg_data);
     message_token('POSITION_NAME',l_position_name );
     message_token('EMPLOYEE_NAME',l_employee_name );
     add_message('PSB', 'PSB_POSITION_DETAILS');

     message_token('ATTRIBUTE NAME',l_attribute_name );
     message_token('DEFINITION_TYPE',l_definition_type );
     message_token('DEFINITION_STRUCTURE',l_definition_structure);
     message_token('DEFINITION_TABLE',l_definition_table);
     message_token('DEFINITION_COLUMN',l_definition_column);
     add_message('PSB', 'PSB_ATTRIBUTE_DETAILS');

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     /* Bug 4075170 Start */
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Last Status::>'||l_debug_info);
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Parameter Info::'||l_param_info);
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error Type:: FND_API.G_EXC_UNEXPECTED_ERROR');
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Get_Employee_Attributes API '
                                      ||'failed due to the following error');
     FND_FILE.PUT_LINE(FND_FILE.LOG, sqlerrm);
     /* Bug 4075170 End */

     if (dbms_sql.is_open(v_cursorid)) then
        dbms_sql.close_cursor(v_cursorid);
     end if;

     if (dbms_sql.is_open(v_dcursorid)) then
        dbms_sql.close_cursor(v_dcursorid);
     end if;

     if (dbms_sql.is_open(v_qcursorid)) then
        dbms_sql.close_cursor(v_qcursorid);
     end if;

     if (dbms_sql.is_open(v_ocursorid)) then
        dbms_sql.close_cursor(v_ocursorid);
     end if;

     if (dbms_sql.is_open(v_jcursorid)) then
        dbms_sql.close_cursor(v_jcursorid);
     end if;

     rollback to Get_Employee_Attributes;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                 p_data  => p_msg_data);
     message_token('POSITION_NAME',l_position_name );
     message_token('EMPLOYEE_NAME',l_employee_name );
     add_message('PSB', 'PSB_POSITION_DETAILS');

     message_token('ATTRIBUTE_NAME',l_attribute_name );
     message_token('DEFINITION_TYPE',l_definition_type );
     message_token('DEFINITION_STRUCTURE',l_definition_structure);
     message_token('DEFINITION_TABLE',l_definition_table);
     message_token('DEFINITION_COLUMN',l_definition_column);
     add_message('PSB', 'PSB_ATTRIBUTE_DETAILS');

   when OTHERS then
     /* Bug 4075170 Start */
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Last Status::>'||l_debug_info);
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Parameter Info::'||l_param_info);
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error Type:: WHEN OTHERS');
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Get_Employee_Attributes API '
                                      ||'failed due to the following error');
     FND_FILE.PUT_LINE(FND_FILE.LOG, sqlerrm);
     /* Bug 4075170 End */

     if (dbms_sql.is_open(v_cursorid)) then
        dbms_sql.close_cursor(v_cursorid);
     end if;

     if (dbms_sql.is_open(v_dcursorid)) then
        dbms_sql.close_cursor(v_dcursorid);
     end if;

     if (dbms_sql.is_open(v_qcursorid)) then
        dbms_sql.close_cursor(v_qcursorid);
     end if;

     if (dbms_sql.is_open(v_ocursorid)) then
        dbms_sql.close_cursor(v_ocursorid);
     end if;

     if (dbms_sql.is_open(v_jcursorid)) then
        dbms_sql.close_cursor(v_jcursorid);
     end if;
     rollback to Get_Employee_Attributes;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                 p_data  => p_msg_data);

     message_token('POSITION_NAME',l_position_name );
     message_token('EMPLOYEE_NAME',l_employee_name );
     add_message('PSB', 'PSB_POSITION_DETAILS');

     message_token('ATTRIBUTE_NAME',l_attribute_name );
     message_token('DEFINITION_TYPE',l_definition_type );
     message_token('DEFINITION_STRUCTURE',l_definition_structure);
     message_token('DEFINITION_TABLE',l_definition_table);
     message_token('DEFINITION_COLUMN',l_definition_column);
     add_message('PSB', 'PSB_ATTRIBUTE_DETAILS');
     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
          (p_pkg_name => G_PKG_NAME,
           p_procedure_name => l_api_name);
    end if;

End Get_Employee_Attributes;

PROCEDURE Check_Reentry
( p_api_version         IN    NUMBER,
  p_return_status       OUT   NOCOPY VARCHAR2,
  p_msg_count           OUT   NOCOPY NUMBER,
  p_msg_data            OUT   NOCOPY VARCHAR2,
  p_data_extract_id     IN    NUMBER,
  p_process             IN    VARCHAR2,
  p_status              OUT   NOCOPY VARCHAR2,
  p_restart_id          OUT   NOCOPY NUMBER
) AS

  Cursor C_Reentrant is
         Select nvl(sp1_status,'I'),
                nvl(sp2_status,'I'),
                nvl(sp3_status,'I'),
                nvl(sp4_status,'I'),
                nvl(sp5_status,'I'),
                nvl(sp6_status,'I'),
                nvl(sp7_status,'I'),
                nvl(sp8_status,'I'),
                nvl(sp9_status,'I'),
                nvl(sp10_status,'I'),
                nvl(sp11_status,'I'),
                nvl(sp12_status,'I'),
                nvl(sp13_status,'I'),
                nvl(sp14_status,'I'),
                nvl(sp15_status,'I'),
                nvl(sp16_status,'I'),
                nvl(sp17_status,'I'),
                nvl(sp18_status,'I'),
                nvl(sp19_status,'I'),
                attribute1,
                attribute2,
                nvl(to_number(attribute3),0),
                nvl(to_number(attribute11),0),
                nvl(to_number(attribute12),0),
                nvl(to_number(attribute13),0),
                nvl(to_number(attribute14),0),
                nvl(to_number(attribute15),0),
                nvl(to_number(attribute16),0),
                nvl(to_number(attribute17),0),
                nvl(to_number(attribute18),0),
                nvl(to_number(attribute19),0),
                nvl(to_number(attribute20),0),
                nvl(to_number(attribute21),0),
                nvl(to_number(attribute22),0),
                nvl(to_number(attribute23),0),
                nvl(to_number(attribute24),0),
                nvl(to_number(attribute25),0),
                nvl(to_number(attribute26),0),
                nvl(to_number(attribute27),0),
                nvl(to_number(attribute28),0),
                nvl(to_number(attribute29),0)
           from psb_reentrant_process_status
          where process_type = 'HR DATA EXTRACT'
            and process_uid  = p_data_extract_id;

  l_api_name		CONSTANT VARCHAR2(30)	:= 'Check_Reentry';
  l_api_version         CONSTANT NUMBER 	:= 1.0;

  l_status              varchar2(1);
  l_sp1_status          varchar2(1);
  l_sp2_status          varchar2(1);
  l_sp3_status          varchar2(1);
  l_sp4_status          varchar2(1);
  l_sp5_status          varchar2(1) ;
  l_sp6_status          varchar2(1) ;
  l_sp7_status          varchar2(1) ;
  l_sp8_status          varchar2(1) ;
  l_sp9_status          varchar2(1) ;
  l_sp10_status         varchar2(1) ;
  l_sp11_status         varchar2(1) ;
  l_sp12_status         varchar2(1) ;
  l_sp13_status         varchar2(1) ;
  l_sp14_status         varchar2(1) ;
  l_sp15_status         varchar2(1) ;
  l_sp16_status         varchar2(1) ;
  l_sp17_status         varchar2(1) ;
  l_sp18_status         varchar2(1) ;
  l_sp19_status         varchar2(1) ;
  l_attribute1          varchar2(30) ;
  l_attribute2          varchar2(30) ;
  l_attribute3          number ;
  l_attribute11         number ;
  l_attribute12         number ;
  l_attribute13         number ;
  l_attribute14         number ;
  l_attribute15         number ;
  l_attribute16         number ;
  l_attribute17         number ;
  l_attribute18         number ;
  l_attribute19         number ;
  l_attribute20         number ;
  l_attribute21         number ;
  l_attribute22         number ;
  l_attribute23         number ;
  l_attribute24         number ;
  l_attribute25         number ;
  l_attribute26         number ;
  l_attribute27         number ;
  l_attribute28         number ;
  l_attribute29         number ;
  l_restart_id          number := 0;

  Begin

    -- Standard call to check for call compatibility.

    if not FND_API.Compatible_API_Call (l_api_version,
            	    	    	        p_api_version,
   	       	    	 	        l_api_name,
		    	    	        G_PKG_NAME)
    then
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;

    p_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body

    Open C_Reentrant;

    Fetch C_Reentrant into l_sp1_status,
                           l_sp2_status,
                           l_sp3_status,
                           l_sp4_status,
                           l_sp5_status,
                           l_sp6_status,
                           l_sp7_status,
                           l_sp8_status,
                           l_sp9_status,
                           l_sp10_status,
                           l_sp11_status,
                           l_sp12_status,
                           l_sp13_status,
                           l_sp14_status,
                           l_sp15_status,
                           l_sp16_status,
                           l_sp17_status,
                           l_sp18_status,
                           l_sp19_status,
                           l_attribute1,
                           l_attribute2,
                           l_attribute3,
                           l_attribute11,
                           l_attribute12,
                           l_attribute13,
                           l_attribute14,
                           l_attribute15,
                           l_attribute16,
                           l_attribute17,
                           l_attribute18,
                           l_attribute19,
                           l_attribute20,
                           l_attribute21,
                           l_attribute22,
                           l_attribute23,
                           l_attribute24,
                           l_attribute25,
                           l_attribute26,
                           l_attribute27,
                           l_attribute28,
                           l_attribute29;




    if (C_Reentrant%NOTFOUND) then
       l_status := 'I';
       l_restart_id := 0;
    else
    if (p_process = 'Positions Interface') then
        l_status  := l_sp1_status;
        l_restart_id := l_attribute11;
    elsif (p_process = 'Salary Interface') then
        l_status := l_sp2_status;
        l_restart_id := l_attribute12;
    elsif (p_process = 'Employees Interface') then
        l_status := l_sp3_status;
        l_restart_id := l_attribute13;
    elsif (p_process = 'Costing Interface') then
        l_status := l_sp4_status;
        l_restart_id := l_attribute14;
    elsif (p_process = 'Attribute Values Interface') then
        l_status := l_sp5_status;
        l_restart_id := l_attribute15;
    elsif (p_process = 'Position Assignments Interface') then
        l_status := l_sp6_status;
        l_restart_id := l_attribute16;
    elsif (p_process = 'Data Extract Summary') then
        l_status := l_sp7_status;
        l_restart_id := l_attribute17;
    elsif (p_process = 'Validate Data Extract') then
        l_status := l_sp8_status;
        l_restart_id := l_attribute18;
    elsif (p_process = 'Copy Attributes') then
        l_status := l_sp9_status;
        l_restart_id := l_attribute19;
    elsif (p_process = 'Copy Elements') then
        l_status := l_sp10_status;
        l_restart_id := l_attribute20;
    elsif (p_process = 'Copy Position Sets') then
        l_status := l_sp11_status;
        l_restart_id := l_attribute21;
    elsif (p_process = 'Copy Default Rules') then
        l_status := l_sp12_status;
        l_restart_id := l_attribute22;
    elsif (p_process = 'PSB Positions') then
        if (l_sp1_status <> 'C') then
           l_status := 'D';
        else
           l_status := l_sp13_status;
           l_restart_id := l_attribute23;
        end if;
    elsif (p_process = 'PSB Elements') then
        if (l_sp2_status <> 'C') then
           l_status := 'D';
        else
           l_status := l_sp14_status;
           l_restart_id := l_attribute24;
        end if;
    elsif (p_process = 'PSB Employees') then
       if ((l_sp3_status  <> 'C') or (l_sp13_status <> 'C')) then
           l_status := 'D';
       else
          l_status := l_sp15_status;
          l_restart_id := l_attribute25;
       end if;
    elsif (p_process = 'PSB Costing') then
       if ((l_sp4_status  <> 'C') or (l_sp13_status <> 'C')) then
          l_status := 'D';
       else
          l_status := l_sp16_status;
          l_restart_id := l_attribute26;
       end if;
    elsif (p_process = 'PSB Attribute Values') then
       if (l_sp5_status <> 'C') then
          l_status := 'D';
       else
          l_status := l_sp17_status;
          l_restart_id := l_attribute27;
       end if;
    elsif (p_process = 'PSB Position Assignments') then
       if ((l_sp6_status  <> 'C') or (l_sp13_status <> 'C')) then
          l_status := 'D';
       else
          l_status := l_sp18_status;
          l_restart_id := l_attribute28;
       end if;
    elsif (p_process = 'PSB Apply Defaults') then
          l_status := l_sp19_status;
          l_restart_id := l_attribute29;
    end if;
    end if;

    p_status := l_status;
    p_restart_id := l_restart_id;
    Close C_Reentrant;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
          (p_pkg_name => G_PKG_NAME,
           p_procedure_name => l_api_name);
    end if;
End Check_Reentry;


Procedure Update_Reentry
( p_api_version         IN   NUMBER,
  p_return_status       OUT  NOCOPY VARCHAR2,
  p_msg_count           OUT  NOCOPY NUMBER,
  p_msg_data            OUT  NOCOPY VARCHAR2,
  p_data_extract_id     IN   NUMBER,
  p_extract_method      IN   VARCHAR2,
  p_process             IN   VARCHAR2,
  p_restart_id          IN   NUMBER
)
IS

  Cursor C_Reenter_Upd is
         Select rowid
           from psb_reentrant_process_status
          where process_type = 'HR DATA EXTRACT'
            and process_uid  = p_data_extract_id;

  -- Commenting this condition as part of DE by Org, since
  -- both CREATE and REFRESH methods can be present in a
  -- single run of the DE.

--            and attribute1   = p_extract_method;

  l_last_update_date    date;
  l_last_updated_by     number;
  l_last_update_login   number;
  l_creation_date       date;
  l_created_by          number;
  l_rowid               VARCHAR2(100);

  l_attribute11         number ;
  l_attribute12         number ;
  l_attribute13         number ;
  l_attribute14         number ;
  l_attribute15         number ;
  l_attribute16         number ;
  l_attribute17         number ;
  l_attribute18         number ;
  l_attribute19         number ;
  l_attribute20         number ;
  l_attribute21         number ;
  l_attribute22         number ;
  l_attribute23         number ;
  l_attribute24         number ;
  l_attribute25         number ;
  l_attribute26         number ;
  l_attribute27         number ;
  l_attribute28         number ;
  l_attribute29         number ;

  l_api_name		CONSTANT VARCHAR2(30)	:= 'Update_Reentry';
  l_api_version         CONSTANT NUMBER 	:= 1.0;

BEGIN

    -- Standard call to check for call compatibility.

    if not FND_API.Compatible_API_Call (l_api_version,
            	    	    	        p_api_version,
   	       	    	 	        l_api_name,
		    	    	        G_PKG_NAME)
    then
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;

    p_return_status := FND_API.G_RET_STS_SUCCESS;

    l_last_update_date  := sysdate;
    l_last_updated_by   := FND_GLOBAL.USER_ID;
    l_last_update_login := FND_GLOBAL.LOGIN_ID;
    l_creation_date     := sysdate;
    l_created_by        := FND_GLOBAL.USER_ID;

    if (p_process = 'Positions Interface') then
        l_attribute11 := p_restart_id;
    elsif (p_process = 'Salary Interface') then
        l_attribute12 := p_restart_id;
    elsif (p_process = 'Employees Interface') then
        l_attribute13 := p_restart_id;
    elsif (p_process = 'Costing Interface') then
        l_attribute14 := p_restart_id;
    elsif (p_process = 'Attribute Values Interface') then
        l_attribute15 := p_restart_id;
    elsif (p_process = 'Position Assignments Interface') then
        l_attribute16 := p_restart_id;
    elsif (p_process = 'Data Extract Summary') then
        l_attribute17 := p_restart_id;
    elsif (p_process = 'Validate Data Extract') then
        l_attribute18 := p_restart_id;
    elsif (p_process = 'Copy Attributes') then
        l_attribute19 := p_restart_id;
    elsif (p_process = 'Copy Elements') then
        l_attribute20 := p_restart_id;
    elsif (p_process = 'Copy Position Sets') then
        l_attribute21 := p_restart_id;
    elsif (p_process = 'Copy Default Rules') then
        l_attribute22 := p_restart_id;
    elsif (p_process = 'PSB Positions') then
        l_attribute23 := p_restart_id;
    elsif (p_process = 'PSB Elements') then
        l_attribute24 := p_restart_id;
    elsif (p_process = 'PSB Employees') then
        l_attribute25 := p_restart_id;
    elsif (p_process = 'PSB Costing') then
        l_attribute26 := p_restart_id;
    elsif (p_process = 'PSB Attribute Values') then
        l_attribute27 := p_restart_id;
    elsif (p_process = 'PSB Position Assignments') then
        l_attribute28 := p_restart_id;
    elsif (p_process = 'PSB Apply Defaults') then
        l_attribute29 := p_restart_id;
    end if;

    Open C_Reenter_Upd;

    Fetch C_Reenter_Upd into l_rowid;

    if C_Reenter_Upd%NOTFOUND then
    Insert Into Psb_Reentrant_Process_Status
    (process_type,
     process_uid,
     attribute1,
     attribute11,
     attribute12,
     attribute13,
     attribute14,
     attribute15,
     attribute16,
     attribute17,
     attribute18,
     attribute19,
     attribute20,
     attribute21,
     attribute22,
     attribute23,
     attribute24,
     attribute25,
     attribute26,
     attribute27,
     attribute28,
     attribute29)
    values
    ('HR DATA EXTRACT',
     p_data_extract_id,
     p_extract_method,
     l_attribute11,
     l_attribute12,
     l_attribute13,
     l_attribute14,
     l_attribute15,
     l_attribute16,
     l_attribute17,
     l_attribute18,
     l_attribute19,
     l_attribute20,
     l_attribute21,
     l_attribute22,
     l_attribute23,
     l_attribute24,
     l_attribute25,
     l_attribute26,
     l_attribute27,
     l_attribute28,
     l_attribute29);
   else
    Update Psb_Reentrant_Process_Status
       set attribute11  = decode(p_process,'Positions Interface',l_attribute11,attribute11),
           attribute12  = decode(p_process,'Salary Interface',l_attribute12,attribute12),
           attribute13  = decode(p_process,'Employees Interface',l_attribute13,attribute13),
           attribute14  = decode(p_process,'Costing Interface',l_attribute14,attribute14),
           attribute15  = decode(p_process,'Attribute Values Interface',l_attribute15,attribute15),
           attribute16  = decode(p_process,'Position Assignments Interface',l_attribute16,attribute16),
           attribute17  = decode(p_process,'Data Extract Summary',l_attribute17,attribute17),
           attribute18  = decode(p_process,'Validate Data Extract',l_attribute18,attribute18),
           attribute19  = decode(p_process,'Copy Attributes',l_attribute19,attribute19),
           attribute20  = decode(p_process,'Copy Elements',l_attribute20,attribute20),
           attribute21  = decode(p_process,'Copy Position Sets',l_attribute21,attribute21),
           attribute22  = decode(p_process,'Copy Default Rules',l_attribute22,attribute22),
           attribute23 = decode(p_process,'PSB Positions',l_attribute23,attribute23),
           attribute24 = decode(p_process,'PSB Elements',l_attribute24,attribute24),
           attribute25 = decode(p_process,'PSB Employees',l_attribute25,attribute25),
           attribute26 = decode(p_process,'PSB Costing',l_attribute26,attribute26),
           attribute27 = decode(p_process,'PSB Attribute Values',l_attribute27,attribute27),
           attribute28 = decode(p_process,'PSB Position Assignments',l_attribute28,attribute28),
           attribute29 = decode(p_process,'PSB Apply Defaults',l_attribute29,attribute29)
    where  rowid  = l_rowid;

   end if;
   Close C_Reenter_Upd;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     if C_Reenter_Upd%isopen then
        Close C_Reenter_Upd;
     end if;
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     if C_Reenter_Upd%isopen then
        Close C_Reenter_Upd;
     end if;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     if C_Reenter_Upd%isopen then
        Close C_Reenter_Upd;
     end if;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
          (p_pkg_name => G_PKG_NAME,
           p_procedure_name => l_api_name);
     end if;


END Update_Reentry;

PROCEDURE Reentrant_Process
( p_api_version         IN   NUMBER,
  p_return_status       OUT  NOCOPY VARCHAR2,
  p_msg_count           OUT  NOCOPY NUMBER,
  p_msg_data            OUT  NOCOPY VARCHAR2,
  p_data_extract_id     IN   NUMBER,
  p_extract_method      IN   VARCHAR2,
  p_process             IN   VARCHAR2
) AS

  Cursor C_Reentrant is
         Select nvl(sp1_status,'I'),
                nvl(sp2_status,'I'),
                nvl(sp3_status,'I'),
                nvl(sp4_status,'I'),
                nvl(sp5_status,'I'),
                nvl(sp6_status,'I'),
                nvl(sp7_status,'I'),
                nvl(sp8_status,'I'),
                nvl(sp9_status,'I'),
                nvl(sp10_status,'I'),
                nvl(sp11_status,'I'),
                nvl(sp12_status,'I'),
                nvl(sp13_status,'I'),
                nvl(sp14_status,'I'),
                nvl(sp15_status,'I'),
                nvl(sp16_status,'I'),
                nvl(sp17_status,'I'),
                nvl(sp18_status,'I'),
                nvl(sp19_status,'I'),
                attribute1,
                attribute2,
                nvl(to_number(attribute3),0)
           from psb_reentrant_process_status
          where process_type = 'HR DATA EXTRACT'
            and process_uid  = p_data_extract_id;

   -- Commenting this condition as part of DE by Org, since
   -- both CREATE and REFRESH methods can be present in a
   -- single run of the DE
--            and attribute1   = p_extract_method;


  l_api_name		CONSTANT VARCHAR2(30)	:= 'Reentrant_Process';
  l_api_version         CONSTANT NUMBER 	:= 1.0;
  l_sp1_status          varchar2(1) := 'I';
  l_sp2_status          varchar2(1) := 'I';
  l_sp3_status          varchar2(1) := 'I';
  l_sp4_status          varchar2(1) := 'I';
  l_sp5_status          varchar2(1) := 'I';
  l_sp6_status          varchar2(1) := 'I';
  l_sp7_status          varchar2(1) := 'I';
  l_sp8_status          varchar2(1) := 'I';
  l_sp9_status          varchar2(1) := 'I';
  l_sp10_status         varchar2(1) := 'I';
  l_sp11_status         varchar2(1) := 'I';
  l_sp12_status         varchar2(1) := 'I';
  l_sp13_status         varchar2(1) := 'I';
  l_sp14_status         varchar2(1) := 'I';
  l_sp15_status         varchar2(1) := 'I';
  l_sp16_status         varchar2(1) := 'I';
  l_sp17_status         varchar2(1) := 'I';
  l_sp18_status         varchar2(1) := 'I';
  l_sp19_status         varchar2(1) := 'I';
  l_attribute1          varchar2(30) ;
  l_attribute2          varchar2(30) ;
  l_attribute3          number := 0;
  l_last_update_date    date;
  l_last_updated_by     number;
  l_last_update_login   number;
  l_creation_date       date;
  l_created_by          number;
  l_refresh_num         number := 0;

  Begin

    -- Standard call to check for call compatibility.

    if not FND_API.Compatible_API_Call (l_api_version,
            	    	    	        p_api_version,
   	       	    	 	        l_api_name,
		    	    	        G_PKG_NAME)
    then
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;


    p_return_status := FND_API.G_RET_STS_SUCCESS;

    l_last_update_date  := sysdate;
    l_last_updated_by   := FND_GLOBAL.USER_ID;
    l_last_update_login := FND_GLOBAL.LOGIN_ID;
    l_creation_date     := sysdate;
    l_created_by        := FND_GLOBAL.USER_ID;

    -- API body
    if (p_process = 'Positions Interface') then
        l_sp1_status := 'C';
    elsif (p_process = 'Salary Interface') then
        l_sp2_status := 'C';
    elsif (p_process = 'Employees Interface') then
        l_sp3_status := 'C';
    elsif (p_process = 'Costing Interface') then
        l_sp4_status := 'C';
    elsif (p_process = 'Attribute Values Interface') then
        l_sp5_status := 'C';
    elsif (p_process = 'Position Assignments Interface') then
        l_sp6_status := 'C';
    elsif (p_process = 'Data Extract Summary') then
        l_sp7_status := 'C';
    elsif (p_process = 'Validate Data Extract') then
        l_sp8_status := 'C';
    elsif (p_process = 'Copy Attributes') then
        l_sp9_status  := 'C';
    elsif (p_process = 'Copy Elements') then
        l_sp9_status   := 'C';
        l_sp10_status  := 'C';
    elsif (p_process = 'Copy Position Sets') then
        l_sp11_status  := 'C';
    elsif (p_process = 'Copy Default Rules') then
        l_sp12_status  := 'C';
    elsif (p_process = 'PSB Positions') then
        l_sp13_status := 'C';
    elsif (p_process = 'PSB Elements') then
        l_sp14_status := 'C';
    elsif (p_process = 'PSB Employees') then
        l_sp15_status := 'C';
    elsif (p_process = 'PSB Costing') then
        l_sp16_status := 'C';
    elsif (p_process = 'PSB Attribute Values') then
        l_sp17_status := 'C';
    elsif (p_process = 'PSB Position Assignments') then
        l_sp18_status := 'C';
    elsif (p_process = 'PSB Apply Defaults') then
        l_sp19_status := 'C';
    end if;

    Open C_Reentrant;

    Fetch C_Reentrant into l_sp1_status,
                           l_sp2_status,
                           l_sp3_status,
                           l_sp4_status,
                           l_sp5_status,
                           l_sp6_status,
                           l_sp7_status,
                           l_sp8_status,
                           l_sp9_status,
                           l_sp10_status,
                           l_sp11_status,
                           l_sp12_status,
                           l_sp13_status,
                           l_sp14_status,
                           l_sp15_status,
                           l_sp16_status,
                           l_sp17_status,
                           l_sp18_status,
                           l_sp19_status,
                           l_attribute1,
                           l_attribute2,
                           l_attribute3;

    if (p_extract_method <> 'CREATE') then
       l_refresh_num := l_attribute3 + 1;
    end if;

    if C_Reentrant%NOTFOUND then
    Insert Into Psb_Reentrant_Process_Status
    (process_type,
     process_uid,
     sp1_status,
     sp2_status,
     sp3_status,
     sp4_status,
     sp5_status,
     sp6_status,
     sp7_status,
     sp8_status,
     sp9_status,
     sp10_status,
     sp11_status,
     sp12_status,
     sp13_status,
     sp14_status,
     sp15_status,
     sp16_status,
     sp17_status,
     sp18_status,
     sp19_status,
     attribute1 ,
     attribute2 ,
     attribute3
     )
     values
     ('HR DATA EXTRACT',
       p_data_extract_id,
       l_sp1_status,
       l_sp2_status,
       l_sp3_status,
       l_sp4_status,
       l_sp5_status,
       l_sp6_status,
       l_sp7_status,
       l_sp8_status,
       l_sp9_status,
       l_sp10_status,
       l_sp11_status,
       l_sp12_status,
       l_sp13_status,
       l_sp14_status,
       l_sp15_status,
       l_sp16_status,
       l_sp17_status,
       l_sp18_status,
       l_sp19_status,
       p_extract_method,
       l_last_update_date,
       to_char(l_refresh_num)
     );
   else
    Update Psb_Reentrant_Process_Status
       set sp1_status  = decode(p_process,'Positions Interface','C',sp1_status),
           sp2_status  = decode(p_process,'Salary Interface','C',sp2_status),
           sp3_status  = decode(p_process,'Employees Interface','C',sp3_status),
           sp4_status  = decode(p_process,'Costing Interface','C',sp4_status),
           sp5_status  = decode(p_process,'Attribute Values Interface','C',sp5_status),
           sp6_status  = decode(p_process,'Position Assignments Interface','C',sp6_status),
           sp7_status  = decode(p_process,'Data Extract Summary','C',sp7_status),
           sp8_status  = decode(p_process,'Validate Data Extract','C',sp8_status),
           sp9_status  = decode(p_process,'Copy Elements','C',sp9_status), -- Fix for Bug #4726455.
           sp10_status = decode(p_process,'Copy Elements','C',sp10_status),
           sp11_status = decode(p_process,'Copy Position Sets','C',sp11_status),
           sp12_status = decode(p_process,'Copy Default Rules','C',sp12_status),
           sp13_status = decode(p_process,'PSB Positions','C',sp13_status),
           sp14_status = decode(p_process,'PSB Elements','C',sp14_status),
           sp15_status = decode(p_process,'PSB Employees','C',sp15_status),
           sp16_status = decode(p_process,'PSB Costing','C',sp16_status),
           sp17_status = decode(p_process,'PSB Attribute Values','C',sp17_status),
           sp18_status = decode(p_process,'PSB Position Assignments','C',sp18_status),
           sp19_status = decode(p_process,'PSB Apply Defaults','C',sp19_status),
           attribute2  = l_last_update_date
    where  process_type  = 'HR DATA EXTRACT'
      and  process_uid   = p_data_extract_id;
   -- de by org
--      and  attribute1    = p_extract_method;
  end if;

  Close C_Reentrant;

    -- End of API body.

EXCEPTION

   when FND_API.G_EXC_ERROR then
     if C_Reentrant%isopen then
        Close C_Reentrant;
     end if;

     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     if C_Reentrant%isopen then
        Close C_Reentrant;
     end if;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     if C_Reentrant%isopen then
        Close C_Reentrant;
     end if;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
          (p_pkg_name => G_PKG_NAME,
           p_procedure_name => l_api_name);
    end if;

End Reentrant_Process;


PROCEDURE Validate_Attribute_Mapping
  ( p_api_version           IN    NUMBER,
    p_init_msg_list         IN    VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN    VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_return_status         OUT   NOCOPY VARCHAR2,
    p_msg_count             OUT   NOCOPY NUMBER,
    p_msg_data              OUT   NOCOPY VARCHAR2,
    p_business_group_id     IN    NUMBER,
    p_attribute_type_id     IN    NUMBER,
    p_definition_structure  IN    VARCHAR2 ,
    p_definition_table      IN    VARCHAR2 ,
    p_definition_column     IN    VARCHAR2
  )
  AS
  --
  l_api_name          CONSTANT VARCHAR2(30)   := 'Validate_Attribute_Mapping';
  l_api_version       CONSTANT NUMBER         := 1.0;
  --
  /*For Bug No : 2372434 Start*/
  --increased the size of d_sql_stmt,q_sql_stmt,o_sql_stmt
  --from 500 to 2000
  v_dcursorid    integer;
  d_sql_stmt     varchar2(2000);
  v_qcursorid    integer;

  q_sql_stmt     varchar2(2000);
  v_ocursorid    integer;
  o_sql_stmt     varchar2(2000);
  /*For Bug No : 2372434 End*/
  l_emp_col      varchar2(20);
  v_emp_val      number;

  l_application_id          number;
  l_application_table_name  varchar2(30);
  l_application_column_name varchar2(30);
  l_lookup_type             varchar2(30);
  l_attr_link_type          varchar2(30);
  l_status                  varchar2(1);
  l_return_status           varchar2(1);
  l_msg_count               number;

  l_msg_data     varchar2(1000);
  l_alias1       varchar2(10);


  Cursor C_Attribute_Types is
    Select name, select_table,attribute_type,
           substr(select_table,1,instr(select_table,' ',1)) select_tab,
           select_column,select_key,
           link_key,decode(link_type,'A','PER_ALL_ASSIGNMENTS','E',
           'PER_ALL_PEOPLE','P', 'HR_ALL_POSITIONS','PER_ALL_ASSIGNMENTS')
           link_type,link_type l_alias2,
           select_where
      From Psb_attribute_types
     where attribute_type_id = p_attribute_type_id;

  Cursor C_dff_tab is
     Select application_id,application_table_name,
            context_column_name
       from fnd_descriptive_flexs_vl
      where descriptive_flexfield_name = p_definition_structure;

  Cursor C_dff_col is
    Select fcol.application_column_name
      from fnd_descr_flex_contexts_vl fcon,fnd_descr_flex_column_usages fcol
     where fcon.application_id = fcol.application_id
       and fcon.descriptive_flexfield_name = p_definition_structure
       and fcon.descriptive_flex_context_code = p_definition_table
       and fcon.descriptive_flexfield_name = fcol.descriptive_flexfield_name
    and fcon.descriptive_flex_context_code = fcol.descriptive_flex_context_code
    and fcol.end_user_column_name = p_definition_column;

BEGIN

  -- Standard Start of API savepoint

  Savepoint Validate_Attribute_Mapping;

  -- Standard call to check for call compatibility.


  if not FND_API.Compatible_API_Call (l_api_version,
     p_api_version,
     l_api_name,
     G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
     FND_MSG_PUB.initialize;
  end if;


  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body

  For C_Attribute_Types_Rec in C_Attribute_Types
  Loop
    Begin
    Select ltrim(rtrim(substr(C_Attribute_Types_Rec.select_table,
           instr(C_Attribute_Types_Rec.select_table,' ',1),
           length(C_Attribute_Types_Rec.select_table)
                  - instr(C_Attribute_Types_Rec.select_table,' ',1) + 1)))
      into l_alias1
      from dual;
     end;

   if (C_Attribute_Types_Rec.link_type = 'PER_ALL_ASSIGNMENTS') then
       l_emp_col := 'assignment_id';
   elsif (C_Attribute_Types_Rec.link_type = 'PER_ALL_PEOPLE') then
       l_emp_col := 'person_id';
   elsif (C_Attribute_Types_Rec.link_type = 'HR_ALL_POSITIONS') then
       l_emp_col := 'position_id';
   end if;

   l_attr_link_type := C_Attribute_Types_Rec.link_type;

   if (C_Attribute_Types_Rec.attribute_type = 'DFF') then

      For C_dff_rec in C_dff_tab
      Loop
         l_application_id := C_dff_rec.application_id;
         l_application_table_name    := C_dff_rec.application_table_name;

        For C_dff_str_rec in C_dff_col
        Loop
          l_application_column_name := C_dff_str_rec.application_column_name;
        End Loop;
      End Loop;

     v_dcursorid := dbms_sql.open_cursor;

     d_sql_stmt := 'Select '||l_alias1||'.' ||l_application_column_name||
                   '  From '||C_Attribute_Types_Rec.select_tab||' '||
                   l_alias1||' , '||
                   C_Attribute_Types_Rec.link_type||' '||
                   C_Attribute_Types_Rec.l_alias2||
                   ' Where '||l_alias1||'.'||
                   C_Attribute_Types_Rec.select_key||' = '||
                   C_Attribute_Types_Rec.l_alias2||'.'||
                   C_Attribute_Types_Rec.link_key||
                   ' and '||C_Attribute_Types_Rec.l_alias2||'.'||l_emp_col||
                   ' = '||':v_emp_val';

     if (C_Attribute_Types_Rec.select_where is not null) then
        d_sql_stmt := d_sql_stmt||' and '||C_Attribute_Types_Rec.select_where;
     end if;

    dbms_sql.parse(v_dcursorid,d_sql_stmt,dbms_sql.v7);

    -- dff code
    elsif (C_Attribute_Types_Rec.attribute_type = 'TABLE') then
     v_ocursorid := dbms_sql.open_cursor;
     if (C_Attribute_Types_Rec.select_table = C_Attribute_Types_Rec.link_type) then
        o_sql_stmt := 'Select '||
              C_Attribute_Types_Rec.select_column||
              '  From '||C_Attribute_Types_Rec.select_tab||
              '  Where '||C_Attribute_Types_Rec.select_tab||'.'||
              l_emp_col|| ' = '||':v_emp_val';
     else
        o_sql_stmt := 'Select '||l_alias1||'.'||
           C_Attribute_Types_Rec.select_column||
           '  From '||C_Attribute_Types_Rec.select_tab||' '||l_alias1||
           ' , '||
           C_Attribute_Types_Rec.link_type||' '||
           C_Attribute_Types_Rec.l_alias2||
           ' Where '||l_alias1||'.'||
           C_Attribute_Types_Rec.select_key||' = '||
           C_Attribute_Types_Rec.l_alias2||'.'||
           C_Attribute_Types_Rec.link_key||
         ' and '||C_Attribute_Types_Rec.l_alias2||'.'||l_emp_col||
         ' = '||':v_emp_val';
     end if;


     if (C_Attribute_Types_Rec.select_where is not null) then
        o_sql_stmt := o_sql_stmt||' and '||C_Attribute_Types_Rec.select_where;
     end if;

    dbms_sql.parse(v_ocursorid,o_sql_stmt,dbms_sql.v7);
       -- table code
    elsif (C_Attribute_Types_Rec.attribute_type = 'QC') then
     v_qcursorid := dbms_sql.open_cursor;
     q_sql_stmt := 'Select a.meaning '||
        '  From Fnd_Common_lookups a , '||
         C_Attribute_Types_Rec.select_tab||' '||l_alias1||' ,'||
         C_Attribute_Types_Rec.link_type||' '||
         C_Attribute_Types_Rec.l_alias2||
         ' Where a.lookup_type = '||''''||
         l_lookup_type||''''||
         ' and a.lookup_code = '||
         l_alias1||'.'||C_Attribute_Types_Rec.select_column||
         ' and '||l_alias1||'.'||C_Attribute_Types_Rec.select_key||
         ' = '||C_Attribute_Types_Rec.l_alias2||'.'||
         C_Attribute_Types_Rec.link_key||
         ' and '||C_Attribute_Types_Rec.l_alias2||'.'||l_emp_col||
         ' = '||':v_emp_val';


     if (C_Attribute_Types_Rec.select_where is not null) then
        q_sql_stmt := q_sql_stmt||' and '||C_Attribute_Types_Rec.select_where;
     end if;

    dbms_sql.parse(v_qcursorid,q_sql_stmt,dbms_sql.v7);
       -- qc code
    end if;
  End Loop;
  -- End of API body.

EXCEPTION

   when FND_API.G_EXC_ERROR then

     rollback to Validate_Attribute_Mapping;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Validate_Attribute_Mapping;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                p_data  => p_msg_data);

  WHEN OTHERS THEN
    --
    ROLLBACK TO Validate_Attribute_Mapping ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                               l_api_name);
    END if;
    --

    --
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                p_data  => p_msg_data );
    --

END Validate_Attribute_Mapping;

PROCEDURE Final_Process is
Begin

  Delete fnd_sessions
  where session_id = (select USERENV('sessionid') from dual);

End Final_Process;

/* ----------------------------------------------------------------------- */

FUNCTION get_segment_val(pseg_num in varchar2,
                pcost_allocation_keyflex_id in number)
                RETURN VARCHAR2  is
s_col varchar2(30);

Cursor C_segment_val is
  Select segment1,  segment2,  segment3,
         segment4,  segment5,  segment6,
         segment7,  segment8,  segment9,
         segment10, segment11, segment12,
         segment13, segment14, segment15,
         segment16, segment17, segment18,
         segment19, segment20, segment21,
         segment22, segment23, segment24,
         segment25, segment26, segment27,
         segment28, segment29, segment30
    from pay_cost_allocation_keyflex
   where cost_allocation_keyflex_id = pcost_allocation_keyflex_id;

begin

  for C_segment_rec in C_segment_val
  Loop
       if (pseg_num = 'SEGMENT1') then
           s_col := C_segment_rec.segment1;
       elsif (pseg_num = 'SEGMENT2') then
           s_col := C_Segment_rec.segment2;
       elsif (pseg_num = 'SEGMENT3') then
           s_col := C_Segment_rec.segment3;
       elsif (pseg_num = 'SEGMENT4') then
           s_col := C_Segment_rec.segment4;
       elsif (pseg_num = 'SEGMENT5') then
           s_col := C_Segment_rec.segment5;
       elsif (pseg_num = 'SEGMENT6') then
           s_col := C_Segment_rec.segment6;
       elsif (pseg_num = 'SEGMENT7') then
           s_col := C_Segment_rec.segment7;
       elsif (pseg_num = 'SEGMENT8') then
           s_col := C_Segment_rec.segment8;
       elsif (pseg_num = 'SEGMENT9') then
           s_col := C_Segment_rec.segment9;
       elsif (pseg_num = 'SEGMENT10') then
           s_col := C_Segment_rec.segment10;
       elsif (pseg_num = 'SEGMENT11') then
           s_col := C_Segment_rec.segment11;
       elsif (pseg_num = 'SEGMENT12') then
           s_col := C_Segment_rec.segment12;
       elsif (pseg_num = 'SEGMENT13') then
           s_col := C_Segment_rec.segment13;
       elsif (pseg_num = 'SEGMENT14') then
           s_col := C_Segment_rec.segment14;
       elsif (pseg_num = 'SEGMENT15') then
           s_col := C_Segment_rec.segment15;
       elsif (pseg_num = 'SEGMENT16') then
           s_col := C_Segment_rec.segment16;
       elsif (pseg_num = 'SEGMENT17') then
           s_col := C_Segment_rec.segment17;
       elsif (pseg_num = 'SEGMENT18') then
           s_col := C_Segment_rec.segment18;
       elsif (pseg_num = 'SEGMENT19') then
           s_col := C_Segment_rec.segment19;
       elsif (pseg_num = 'SEGMENT20') then
           s_col := C_Segment_rec.segment20;
       elsif (pseg_num = 'SEGMENT21') then
           s_col := C_Segment_rec.segment21;
       elsif (pseg_num = 'SEGMENT22') then
           s_col := C_Segment_rec.segment22;
       elsif (pseg_num = 'SEGMENT23') then
           s_col := C_Segment_rec.segment23;
       elsif (pseg_num = 'SEGMENT24') then
           s_col := C_Segment_rec.segment24;
       elsif (pseg_num = 'SEGMENT25') then
           s_col := C_Segment_rec.segment25;
       elsif (pseg_num = 'SEGMENT26') then
           s_col := C_Segment_rec.segment26;
       elsif (pseg_num = 'SEGMENT27') then
           s_col := C_Segment_rec.segment27;
       elsif (pseg_num = 'SEGMENT28') then
           s_col := C_Segment_rec.segment28;
       elsif (pseg_num = 'SEGMENT29') then
           s_col := C_Segment_rec.segment29;
       elsif (pseg_num = 'SEGMENT30') then
           s_col := C_Segment_rec.segment30;
       end if;
  End Loop;

  RETURN s_col;

End get_segment_val;

/* ----------------------------------------------------------------------- */

FUNCTION Is_LD_Enabled
( p_business_group_id IN NUMBER
) RETURN BOOLEAN
IS
  l_plsql_block        VARCHAR2(100);
  l_ld_enabled         VARCHAR2(1);

BEGIN

  --Dynamic sql statement to find whether CBC is enabled

  l_plsql_block := 'BEGIN :ld_enabled := PSP_GENERAL.IS_LD_Enabled(:business_group_id); END;';

  EXECUTE IMMEDIATE l_plsql_block USING OUT l_ld_enabled, IN p_business_group_id;

  if FND_API.to_Boolean(l_ld_enabled) then
    return TRUE;
  else
    return FALSE;
  end if;

  EXCEPTION
  WHEN OTHERS THEN
    Add_Message('PSB', 'PSB_LD_ENABLED_STATUS');
    RETURN FALSE;

END Is_LD_Enabled;

/* ----------------------------------------------------------------------- */
  -- Get Debug Information

  -- This Module is used to retrieve Debug Information for this routine. It
  -- prints Debug Information when run as a Batch Process from SQL*Plus. For
  -- the Debug Information to be printed on the Screen, the SQL*Plus parameter
  -- 'Serveroutput' should be set to 'ON'

  FUNCTION get_debug RETURN VARCHAR2 AS

  BEGIN

    return(g_dbug);

  END get_debug;

/* ----------------------------------------------------------------------- */
-- Add Token and Value to the Message Token array

PROCEDURE message_token(tokname IN VARCHAR2,
                        tokval  IN VARCHAR2) AS

BEGIN

  if no_msg_tokens is null then
    no_msg_tokens := 1;
  else
    no_msg_tokens := no_msg_tokens + 1;
  end if;

  msg_tok_names(no_msg_tokens) := tokname;
  msg_tok_val(no_msg_tokens) := tokval;

END message_token;

/* ----------------------------------------------------------------------- */

-- Define a Message Token with a Value and set the Message Name

-- Calls FND_MESSAGE server package to set the Message Stack. This message is
-- retrieved by the calling program.

PROCEDURE add_message(appname IN VARCHAR2,
                      msgname IN VARCHAR2) AS

  i  BINARY_INTEGER;

BEGIN

  if ((appname is not null) and
      (msgname is not null)) then

    FND_MESSAGE.SET_NAME(appname, msgname);

    if no_msg_tokens is not null then

      for i in 1..no_msg_tokens loop
        FND_MESSAGE.SET_TOKEN(msg_tok_names(i), msg_tok_val(i));
      end loop;

    end if;

    FND_MSG_PUB.Add;

  end if;

  -- Clear Message Token stack

  no_msg_tokens := 0;

END add_message;

/* ----------------------------------------------------------------------- */

END PSB_HR_EXTRACT_DATA_PVT;

/
