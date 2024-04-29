--------------------------------------------------------
--  DDL for Package Body GHR_POSITION_COPY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_POSITION_COPY" AS
/* $Header: ghrwspoc.pkb 120.0.12010000.2 2009/05/26 10:59:16 vmididho noship $ */
--
FUNCTION get_seq_location (p_org_id  IN NUMBER)
  RETURN VARCHAR2 IS
--
CURSOR c_ori IS
  SELECT ori.org_information4 seq_location
  FROM   hr_organization_information ori
  WHERE  ori.organization_id = p_org_id
  AND    ori.org_information_context = 'GHR_US_ORG_INFORMATION';
--
BEGIN
  FOR c_ori_rec IN c_ori LOOP
    RETURN (c_ori_rec.seq_location);
  END LOOP;
  RETURN(NULL);
END get_seq_location;
--
--
------------------------------------------------------------------
FUNCTION get_max_seq (p_seq_location IN VARCHAR2
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
l_cur        INTEGER;
l_stmt       VARCHAR2(2000);
l_fetch_rows INTEGER;
l_seq_loc    INTEGER;
l_max_seq    VARCHAR2(150);

BEGIN

  l_cur := dbms_sql.open_cursor;
  l_stmt := 'SELECT MAX(TO_NUMBER('||p_seq_location||'))  max_seq '||
            'FROM   per_position_definitions pde WHERE 1=1';
  --
  l_seq_loc := SUBSTR(p_seq_location,8);
  --
  FOR i IN 1..30 LOOP
    IF l_seq_loc <>  i THEN
      IF i = 1 and p_segment1 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||p_segment1||'''';
      ELSIF i = 2 and p_segment2 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||p_segment2||'''';
      ELSIF i = 3 and p_segment3 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||p_segment3||'''';
      ELSIF i = 4 and p_segment4 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||p_segment4||'''';
      ELSIF i = 5 and p_segment5 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||p_segment5||'''';
      ELSIF i = 6 and p_segment6 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||p_segment6||'''';
      ELSIF i = 7 and p_segment7 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||p_segment7||'''';
      ELSIF i = 8 and p_segment8 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||p_segment8||'''';
      ELSIF i = 9 and p_segment9 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||p_segment9||'''';
      ELSIF i = 10 and p_segment10 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||p_segment10||'''';
      ELSIF i = 11 and p_segment11 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||p_segment11||'''';
      ELSIF i = 12 and p_segment12 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||p_segment12||'''';
      ELSIF i = 13 and p_segment13 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||p_segment13||'''';
      ELSIF i = 14 and p_segment14 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||p_segment14||'''';
      ELSIF i = 15 and p_segment15 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||p_segment15||'''';
      ELSIF i = 16 and p_segment16 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||p_segment16||'''';
      ELSIF i = 17 and p_segment17 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||p_segment17||'''';
      ELSIF i = 18 and p_segment18 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||p_segment18||'''';
      ELSIF i = 19 and p_segment19 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||p_segment19||'''';
      ELSIF i = 20 and p_segment20 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||p_segment20||'''';
      ELSIF i = 21 and p_segment21 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||p_segment21||'''';
      ELSIF i = 22 and p_segment22 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||p_segment22||'''';
      ELSIF i = 23 and p_segment23 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||p_segment23||'''';
      ELSIF i = 24 and p_segment24 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||p_segment24||'''';
      ELSIF i = 25 and p_segment25 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||p_segment25||'''';
      ELSIF i = 26 and p_segment26 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||p_segment26||'''';
      ELSIF i = 27 and p_segment27 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||p_segment27||'''';
      ELSIF i = 28 and p_segment28 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||p_segment28||'''';
      ELSIF i = 29 and p_segment29 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||p_segment29||'''';
      ELSIF i = 30 and p_segment30 IS NOT NULL THEN
        l_stmt := l_stmt||' AND SEGMENT'||i||' = '''||p_segment30||'''';
      END IF;
    END IF;
  END LOOP;
  l_stmt := l_stmt||' AND EXISTS (SELECT 1 FROM per_positions pos'
                  ||' WHERE pde.position_definition_id = pos.position_definition_id)';
  ---
  --dbms_output.put_line(substr(l_stmt,1,100));
  --dbms_output.put_line(substr(l_stmt,101,100));
  dbms_sql.parse(l_cur, l_stmt, dbms_sql.v7);
  dbms_sql.define_column(l_cur, 1, l_max_seq,150);
  l_fetch_rows := dbms_sql.execute(l_cur);
  l_fetch_rows := dbms_sql.fetch_rows(l_cur);
  dbms_sql.column_value(l_cur, 1, l_max_seq);
  dbms_sql.close_cursor(l_cur);
  --
    RETURN(l_max_seq);
  --
END get_max_seq;
--

PROCEDURE create_posn (p_pos_id              IN  NUMBER
                      ,p_effective_date_from IN  DATE
                      ,p_effective_date_to   IN  DATE
                      ,p_template_flag       IN  VARCHAR2
                      ,p_new_pos_id          OUT NOCOPY NUMBER
                      ,p_new_pos_name        OUT NOCOPY VARCHAR2
                      ,p_ovn                 OUT NOCOPY NUMBER) IS
--
l_pos_data         hr_all_positions_f%rowtype;
l_result_code      VARCHAR2(30);
l_pde_data         per_position_definitions%rowtype;
l_dummy_number     NUMBER;
l_new_pos_id       hr_all_positions_f.position_id%TYPE;
l_new_pos_name     hr_all_positions_f.name%TYPE;
l_seq_segment_name VARCHAR2(30);
l_new_seq          VARCHAR2(150);
l_ovn              NUMBER;
l_seq_len          NUMBER;
--
CURSOR cur_pde (p_position_definition_id IN NUMBER) IS
  SELECT *
  FROM   per_position_definitions pde
  WHERE  pde.position_definition_id = p_position_definition_id;

BEGIN

  ghr_history_fetch.fetch_position (p_position_id    => p_pos_id
                                   ,p_date_effective => p_effective_date_from
                                   ,p_position_data  => l_pos_data
                                   ,p_result_code    => l_result_code) ;

  FOR cur_pde_rec IN cur_pde(l_pos_data.position_definition_id) LOOP
    l_pde_data := cur_pde_rec;
  END LOOP;
  --
  l_seq_segment_name := ghr_position_copy.get_seq_location(l_pos_data.business_group_id);
  --
  -- Get Agency Specified Max Seq
  --
  l_new_seq  := ghr_agency_position_copy.agency_get_max_seq(
                       l_seq_segment_name,
                       l_pde_data.segment1,
                       l_pde_data.segment2,
                       l_pde_data.segment3,
                       l_pde_data.segment4,
                       l_pde_data.segment5,
                       l_pde_data.segment6,
                       l_pde_data.segment7,
                       l_pde_data.segment8,
                       l_pde_data.segment9,
                       l_pde_data.segment10,
                       l_pde_data.segment11,
                       l_pde_data.segment12,
                       l_pde_data.segment13,
                       l_pde_data.segment14,
                       l_pde_data.segment15,
                       l_pde_data.segment16,
                       l_pde_data.segment17,
                       l_pde_data.segment18,
                       l_pde_data.segment19,
                       l_pde_data.segment20,
                       l_pde_data.segment21,
                       l_pde_data.segment22,
                       l_pde_data.segment23,
                       l_pde_data.segment24,
                       l_pde_data.segment25,
                       l_pde_data.segment26,
                       l_pde_data.segment27,
                       l_pde_data.segment28,
                       l_pde_data.segment29,
                       l_pde_data.segment30);


  -- If Agency_get_max returns null then call GHR function
  If l_new_seq is null then
     l_new_seq  := ghr_position_copy.get_max_seq(
                       l_seq_segment_name,
                       l_pde_data.segment1,
                       l_pde_data.segment2,
                       l_pde_data.segment3,
                       l_pde_data.segment4,
                       l_pde_data.segment5,
                       l_pde_data.segment6,
                       l_pde_data.segment7,
                       l_pde_data.segment8,
                       l_pde_data.segment9,
                       l_pde_data.segment10,
                       l_pde_data.segment11,
                       l_pde_data.segment12,
                       l_pde_data.segment13,
                       l_pde_data.segment14,
                       l_pde_data.segment15,
                       l_pde_data.segment16,
                       l_pde_data.segment17,
                       l_pde_data.segment18,
                       l_pde_data.segment19,
                       l_pde_data.segment20,
                       l_pde_data.segment21,
                       l_pde_data.segment22,
                       l_pde_data.segment23,
                       l_pde_data.segment24,
                       l_pde_data.segment25,
                       l_pde_data.segment26,
                       l_pde_data.segment27,
                       l_pde_data.segment28,
                       l_pde_data.segment29,
                       l_pde_data.segment30);
  End If;

  -- Concatenating a negative symbol infront of sequence for template
  -- means that a new combination's max number may be the negative number
  -- of the template combination.  This must be reset.

  If l_new_seq is null or to_number(l_new_seq) < 0 then
     l_new_seq := '0';
  End If;

  l_new_seq := to_char(((to_number(l_new_seq)) + 1));

  -- Need the length of the original seq. to lpad new seq.
  -- If seq. is template record then 1 character must be subtracted.
  IF l_seq_segment_name = 'SEGMENT1' THEN
      If substr(l_pde_data.segment1,1,1) = '-' then
         l_seq_len := length(l_pde_data.segment1)-1;
      Else
         l_seq_len := length(l_pde_data.segment1);
      End If;
    ELSIF l_seq_segment_name = 'SEGMENT2' THEN
      If substr(l_pde_data.segment2,1,1) = '-' then
         l_seq_len := length(l_pde_data.segment2)-1;
      Else
         l_seq_len := length(l_pde_data.segment2);
      End If;
    ELSIF l_seq_segment_name = 'SEGMENT3' THEN
      If substr(l_pde_data.segment3,1,1) = '-' then
         l_seq_len := length(l_pde_data.segment3)-1;
      Else
         l_seq_len := length(l_pde_data.segment3);
      End If;
    ELSIF l_seq_segment_name = 'SEGMENT4' THEN
      If substr(l_pde_data.segment4,1,1) = '-' then
         l_seq_len := length(l_pde_data.segment4)-1;
      Else
         l_seq_len := length(l_pde_data.segment4);
      End If;
    ELSIF l_seq_segment_name = 'SEGMENT5' THEN
      If substr(l_pde_data.segment5,1,1) = '-' then
         l_seq_len := length(l_pde_data.segment5)-1;
      Else
         l_seq_len := length(l_pde_data.segment5);
      End If;
    ELSIF l_seq_segment_name = 'SEGMENT6' THEN
      If substr(l_pde_data.segment6,1,1) = '-' then
         l_seq_len := length(l_pde_data.segment6)-1;
      Else
         l_seq_len := length(l_pde_data.segment6);
      End If;
    ELSIF l_seq_segment_name = 'SEGMENT7' THEN
      If substr(l_pde_data.segment7,1,1) = '-' then
         l_seq_len := length(l_pde_data.segment7)-1;
      Else
         l_seq_len := length(l_pde_data.segment7);
      End If;
    ELSIF l_seq_segment_name = 'SEGMENT8' THEN
      If substr(l_pde_data.segment8,1,1) = '-' then
         l_seq_len := length(l_pde_data.segment8)-1;
      Else
         l_seq_len := length(l_pde_data.segment8);
      End If;
    ELSIF l_seq_segment_name = 'SEGMENT9' THEN
      If substr(l_pde_data.segment9,1,1) = '-' then
         l_seq_len := length(l_pde_data.segment9)-1;
      Else
         l_seq_len := length(l_pde_data.segment9);
      End If;
    ELSIF l_seq_segment_name = 'SEGMENT10' THEN
      If substr(l_pde_data.segment10,1,1) = '-' then
         l_seq_len := length(l_pde_data.segment10)-1;
      Else
         l_seq_len := length(l_pde_data.segment10);
      End If;
    ELSIF l_seq_segment_name = 'SEGMENT11' THEN
      If substr(l_pde_data.segment11,1,1) = '-' then
         l_seq_len := length(l_pde_data.segment11)-1;
      Else
         l_seq_len := length(l_pde_data.segment11);
      End If;
    ELSIF l_seq_segment_name = 'SEGMENT12' THEN
      If substr(l_pde_data.segment12,1,1) = '-' then
         l_seq_len := length(l_pde_data.segment12)-1;
      Else
         l_seq_len := length(l_pde_data.segment12);
      End If;
    ELSIF l_seq_segment_name = 'SEGMENT13' THEN
      If substr(l_pde_data.segment13,1,1) = '-' then
         l_seq_len := length(l_pde_data.segment13)-1;
      Else
         l_seq_len := length(l_pde_data.segment13);
      End If;
    ELSIF l_seq_segment_name = 'SEGMENT14' THEN
      If substr(l_pde_data.segment14,1,1) = '-' then
         l_seq_len := length(l_pde_data.segment14)-1;
      Else
         l_seq_len := length(l_pde_data.segment14);
      End If;
    ELSIF l_seq_segment_name = 'SEGMENT15' THEN
      If substr(l_pde_data.segment15,1,1) = '-' then
         l_seq_len := length(l_pde_data.segment15)-1;
      Else
         l_seq_len := length(l_pde_data.segment15);
      End If;
    ELSIF l_seq_segment_name = 'SEGMENT16' THEN
      If substr(l_pde_data.segment16,1,1) = '-' then
         l_seq_len := length(l_pde_data.segment16)-1;
      Else
         l_seq_len := length(l_pde_data.segment16);
      End If;
    ELSIF l_seq_segment_name = 'SEGMENT17' THEN
      If substr(l_pde_data.segment17,1,1) = '-' then
         l_seq_len := length(l_pde_data.segment17)-1;
      Else
         l_seq_len := length(l_pde_data.segment17);
      End If;
    ELSIF l_seq_segment_name = 'SEGMENT18' THEN
      If substr(l_pde_data.segment18,1,1) = '-' then
         l_seq_len := length(l_pde_data.segment18)-1;
      Else
         l_seq_len := length(l_pde_data.segment18);
      End If;
    ELSIF l_seq_segment_name = 'SEGMENT19' THEN
      If substr(l_pde_data.segment19,1,1) = '-' then
         l_seq_len := length(l_pde_data.segment19)-1;
      Else
         l_seq_len := length(l_pde_data.segment19);
      End If;
    ELSIF l_seq_segment_name = 'SEGMENT20' THEN
      If substr(l_pde_data.segment20,1,1) = '-' then
         l_seq_len := length(l_pde_data.segment20)-1;
      Else
         l_seq_len := length(l_pde_data.segment20);
      End If;
    ELSIF l_seq_segment_name = 'SEGMENT21' THEN
      If substr(l_pde_data.segment21,1,1) = '-' then
         l_seq_len := length(l_pde_data.segment21)-1;
      Else
         l_seq_len := length(l_pde_data.segment21);
      End If;
    ELSIF l_seq_segment_name = 'SEGMENT22' THEN
      If substr(l_pde_data.segment22,1,1) = '-' then
         l_seq_len := length(l_pde_data.segment22)-1;
      Else
         l_seq_len := length(l_pde_data.segment22);
      End If;
    ELSIF l_seq_segment_name = 'SEGMENT23' THEN
      If substr(l_pde_data.segment23,1,1) = '-' then
         l_seq_len := length(l_pde_data.segment23)-1;
      Else
         l_seq_len := length(l_pde_data.segment23);
      End If;
    ELSIF l_seq_segment_name = 'SEGMENT24' THEN
      If substr(l_pde_data.segment24,1,1) = '-' then
         l_seq_len := length(l_pde_data.segment24)-1;
      Else
         l_seq_len := length(l_pde_data.segment24);
      End If;
    ELSIF l_seq_segment_name = 'SEGMENT25' THEN
      If substr(l_pde_data.segment25,1,1) = '-' then
         l_seq_len := length(l_pde_data.segment25)-1;
      Else
         l_seq_len := length(l_pde_data.segment25);
      End If;
    ELSIF l_seq_segment_name = 'SEGMENT26' THEN
      If substr(l_pde_data.segment26,1,1) = '-' then
         l_seq_len := length(l_pde_data.segment26)-1;
      Else
         l_seq_len := length(l_pde_data.segment26);
      End If;
    ELSIF l_seq_segment_name = 'SEGMENT27' THEN
      If substr(l_pde_data.segment27,1,1) = '-' then
         l_seq_len := length(l_pde_data.segment27)-1;
      Else
         l_seq_len := length(l_pde_data.segment27);
      End If;
    ELSIF l_seq_segment_name = 'SEGMENT28' THEN
      If substr(l_pde_data.segment28,1,1) = '-' then
         l_seq_len := length(l_pde_data.segment28)-1;
      Else
         l_seq_len := length(l_pde_data.segment28);
      End If;
    ELSIF l_seq_segment_name = 'SEGMENT29' THEN
      If substr(l_pde_data.segment29,1,1) = '-' then
         l_seq_len := length(l_pde_data.segment29)-1;
      Else
         l_seq_len := length(l_pde_data.segment29);
      End If;
    ELSIF l_seq_segment_name = 'SEGMENT30' THEN
      If substr(l_pde_data.segment30,1,1) = '-' then
         l_seq_len := length(l_pde_data.segment30)-1;
      Else
         l_seq_len := length(l_pde_data.segment30);
      End If;
   END IF;
  --

  If l_seq_len > length(l_new_seq) then
    l_new_seq := lpad(l_new_seq,l_seq_len,'0');
  End If;

 --
  IF p_template_flag = 'N' THEN
    IF l_seq_segment_name = 'SEGMENT1' THEN
      l_pde_data.segment1 := l_new_seq;
    ELSIF l_seq_segment_name = 'SEGMENT2' THEN
      l_pde_data.segment2 := l_new_seq;
    ELSIF l_seq_segment_name = 'SEGMENT3' THEN
      l_pde_data.segment3 := l_new_seq;
    ELSIF l_seq_segment_name = 'SEGMENT4' THEN
      l_pde_data.segment4 := l_new_seq;
    ELSIF l_seq_segment_name = 'SEGMENT5' THEN
      l_pde_data.segment5 := l_new_seq;
    ELSIF l_seq_segment_name = 'SEGMENT6' THEN
      l_pde_data.segment6 := l_new_seq;
    ELSIF l_seq_segment_name = 'SEGMENT7' THEN
      l_pde_data.segment7 := l_new_seq;
    ELSIF l_seq_segment_name = 'SEGMENT8' THEN
      l_pde_data.segment8 := l_new_seq;
    ELSIF l_seq_segment_name = 'SEGMENT9' THEN
      l_pde_data.segment9 := l_new_seq;
    ELSIF l_seq_segment_name = 'SEGMENT10' THEN
      l_pde_data.segment10 := l_new_seq;
    ELSIF l_seq_segment_name = 'SEGMENT11' THEN
      l_pde_data.segment11 := l_new_seq;
    ELSIF l_seq_segment_name = 'SEGMENT12' THEN
      l_pde_data.segment12 := l_new_seq;
    ELSIF l_seq_segment_name = 'SEGMENT13' THEN
      l_pde_data.segment13 := l_new_seq;
    ELSIF l_seq_segment_name = 'SEGMENT14' THEN
      l_pde_data.segment14 := l_new_seq;
    ELSIF l_seq_segment_name = 'SEGMENT15' THEN
      l_pde_data.segment15 := l_new_seq;
    ELSIF l_seq_segment_name = 'SEGMENT16' THEN
      l_pde_data.segment16 := l_new_seq;
    ELSIF l_seq_segment_name = 'SEGMENT17' THEN
      l_pde_data.segment17 := l_new_seq;
    ELSIF l_seq_segment_name = 'SEGMENT18' THEN
      l_pde_data.segment18 := l_new_seq;
    ELSIF l_seq_segment_name = 'SEGMENT19' THEN
      l_pde_data.segment19 := l_new_seq;
    ELSIF l_seq_segment_name = 'SEGMENT20' THEN
      l_pde_data.segment20 := l_new_seq;
    ELSIF l_seq_segment_name = 'SEGMENT21' THEN
      l_pde_data.segment21 := l_new_seq;
    ELSIF l_seq_segment_name = 'SEGMENT22' THEN
      l_pde_data.segment22 := l_new_seq;
    ELSIF l_seq_segment_name = 'SEGMENT23' THEN
      l_pde_data.segment23 := l_new_seq;
    ELSIF l_seq_segment_name = 'SEGMENT24' THEN
      l_pde_data.segment24 := l_new_seq;
    ELSIF l_seq_segment_name = 'SEGMENT25' THEN
      l_pde_data.segment25 := l_new_seq;
    ELSIF l_seq_segment_name = 'SEGMENT26' THEN
      l_pde_data.segment26 := l_new_seq;
    ELSIF l_seq_segment_name = 'SEGMENT27' THEN
      l_pde_data.segment27 := l_new_seq;
    ELSIF l_seq_segment_name = 'SEGMENT28' THEN
      l_pde_data.segment28 := l_new_seq;
    ELSIF l_seq_segment_name = 'SEGMENT29' THEN
      l_pde_data.segment29 := l_new_seq;
    ELSIF l_seq_segment_name = 'SEGMENT30' THEN
      l_pde_data.segment30 := l_new_seq;
    END IF;
  ELSE -- Hard Code Sequence Number for Template Record
       -- This ensures there is no gap generated in seq for copies.
    IF l_seq_segment_name = 'SEGMENT1' THEN
      l_pde_data.segment1 := '-'||l_pde_data.segment1;
    ELSIF l_seq_segment_name = 'SEGMENT2' THEN
      l_pde_data.segment2 := '-'||l_pde_data.segment2;
    ELSIF l_seq_segment_name = 'SEGMENT3' THEN
      l_pde_data.segment3 := '-'||l_pde_data.segment3;
    ELSIF l_seq_segment_name = 'SEGMENT4' THEN
      l_pde_data.segment4 := '-'||l_pde_data.segment4;
    ELSIF l_seq_segment_name = 'SEGMENT5' THEN
      l_pde_data.segment5 := '-'||l_pde_data.segment5;
    ELSIF l_seq_segment_name = 'SEGMENT6' THEN
      l_pde_data.segment6 := '-'||l_pde_data.segment6;
    ELSIF l_seq_segment_name = 'SEGMENT7' THEN
      l_pde_data.segment7 := '-'||l_pde_data.segment7;
    ELSIF l_seq_segment_name = 'SEGMENT8' THEN
      l_pde_data.segment8 := '-'||l_pde_data.segment8;
    ELSIF l_seq_segment_name = 'SEGMENT9' THEN
      l_pde_data.segment9 := '-'||l_pde_data.segment9;
    ELSIF l_seq_segment_name = 'SEGMENT10' THEN
      l_pde_data.segment10 := '-'||l_pde_data.segment10;
    ELSIF l_seq_segment_name = 'SEGMENT11' THEN
      l_pde_data.segment11 := '-'||l_pde_data.segment11;
    ELSIF l_seq_segment_name = 'SEGMENT12' THEN
      l_pde_data.segment12 := '-'||l_pde_data.segment12;
    ELSIF l_seq_segment_name = 'SEGMENT13' THEN
      l_pde_data.segment13 := '-'||l_pde_data.segment13;
    ELSIF l_seq_segment_name = 'SEGMENT14' THEN
      l_pde_data.segment14 := '-'||l_pde_data.segment14;
    ELSIF l_seq_segment_name = 'SEGMENT15' THEN
      l_pde_data.segment15 := '-'||l_pde_data.segment15;
    ELSIF l_seq_segment_name = 'SEGMENT16' THEN
      l_pde_data.segment16 := '-'||l_pde_data.segment16;
    ELSIF l_seq_segment_name = 'SEGMENT17' THEN
      l_pde_data.segment17 := '-'||l_pde_data.segment17;
    ELSIF l_seq_segment_name = 'SEGMENT18' THEN
      l_pde_data.segment18 := '-'||l_pde_data.segment18;
    ELSIF l_seq_segment_name = 'SEGMENT19' THEN
      l_pde_data.segment19 := '-'||l_pde_data.segment19;
    ELSIF l_seq_segment_name = 'SEGMENT20' THEN
      l_pde_data.segment20 := '-'||l_pde_data.segment20;
    ELSIF l_seq_segment_name = 'SEGMENT21' THEN
      l_pde_data.segment21 := '-'||l_pde_data.segment21;
    ELSIF l_seq_segment_name = 'SEGMENT22' THEN
      l_pde_data.segment22 := '-'||l_pde_data.segment22;
    ELSIF l_seq_segment_name = 'SEGMENT23' THEN
      l_pde_data.segment23 := '-'||l_pde_data.segment23;
    ELSIF l_seq_segment_name = 'SEGMENT24' THEN
      l_pde_data.segment24 := '-'||l_pde_data.segment24;
    ELSIF l_seq_segment_name = 'SEGMENT25' THEN
      l_pde_data.segment25 := '-'||l_pde_data.segment25;
    ELSIF l_seq_segment_name = 'SEGMENT26' THEN
      l_pde_data.segment26 := '-'||l_pde_data.segment26;
    ELSIF l_seq_segment_name = 'SEGMENT27' THEN
      l_pde_data.segment27 := '-'||l_pde_data.segment27;
    ELSIF l_seq_segment_name = 'SEGMENT28' THEN
      l_pde_data.segment28 := '-'||l_pde_data.segment28;
    ELSIF l_seq_segment_name = 'SEGMENT29' THEN
      l_pde_data.segment29 := '-'||l_pde_data.segment29;
    ELSIF l_seq_segment_name = 'SEGMENT30' THEN
      l_pde_data.segment30 := '-'||l_pde_data.segment30;
    END IF;
  END IF;

  -- Set Status to Invalid for all copies
  l_pos_data.status := 'INVALID';
  --

  ghr_position_api.create_position(
   p_validate                  =>  FALSE
  ,p_job_id                    =>  l_pos_data.job_id
  ,p_organization_id           =>  l_pos_data.organization_id
  ,p_date_effective            =>  p_effective_date_to
  ,p_successor_position_id     =>  l_pos_data.successor_position_id
  ,p_relief_position_id        =>  l_pos_data.relief_position_id
  ,p_location_id               =>  l_pos_data.location_id
  ,p_comments                  =>  l_pos_data.comments
  ,p_date_end                  =>  null
  ,p_frequency                 =>  l_pos_data.frequency
  ,p_probation_period          =>  l_pos_data.probation_period
  ,p_probation_period_units    =>  l_pos_data.probation_period_unit_cd
  ,p_replacement_required_flag =>  l_pos_data.replacement_required_flag
  ,p_time_normal_finish        =>  l_pos_data.time_normal_finish
  ,p_time_normal_start         =>  l_pos_data.time_normal_start
  ,p_status                    =>  l_pos_data.status
  ,p_working_hours             =>  l_pos_data.working_hours
  ,p_attribute_category        =>  l_pos_data.attribute_category
  ,p_attribute1                =>  l_pos_data.attribute1
  ,p_attribute2                =>  l_pos_data.attribute2
  ,p_attribute3                =>  l_pos_data.attribute3
  ,p_attribute4                =>  l_pos_data.attribute4
  ,p_attribute5                =>  l_pos_data.attribute5
  ,p_attribute6                =>  l_pos_data.attribute6
  ,p_attribute7                =>  l_pos_data.attribute7
  ,p_attribute8                =>  l_pos_data.attribute8
  ,p_attribute9                =>  l_pos_data.attribute9
  ,p_attribute10               =>  l_pos_data.attribute10
  ,p_attribute11               =>  l_pos_data.attribute11
  ,p_attribute12               =>  l_pos_data.attribute12
  ,p_attribute13               =>  l_pos_data.attribute13
  ,p_attribute14               =>  l_pos_data.attribute14
  ,p_attribute15               =>  l_pos_data.attribute15
  ,p_attribute16               =>  l_pos_data.attribute16
  ,p_attribute17               =>  l_pos_data.attribute17
  ,p_attribute18               =>  l_pos_data.attribute18
  ,p_attribute19               =>  l_pos_data.attribute19
  ,p_attribute20               =>  l_pos_data.attribute20
  ,p_segment1                  =>  l_pde_data.segment1
  ,p_segment2                  =>  l_pde_data.segment2
  ,p_segment3                  =>  l_pde_data.segment3
  ,p_segment4                  =>  l_pde_data.segment4
  ,p_segment5                  =>  l_pde_data.segment5
  ,p_segment6                  =>  l_pde_data.segment6
  ,p_segment7                  =>  l_pde_data.segment7
  ,p_segment8                  =>  l_pde_data.segment8
  ,p_segment9                  =>  l_pde_data.segment9
  ,p_segment10                 =>  l_pde_data.segment10
  ,p_segment11                 =>  l_pde_data.segment11
  ,p_segment12                 =>  l_pde_data.segment12
  ,p_segment13                 =>  l_pde_data.segment13
  ,p_segment14                 =>  l_pde_data.segment14
  ,p_segment15                 =>  l_pde_data.segment15
  ,p_segment16                 =>  l_pde_data.segment16
  ,p_segment17                 =>  l_pde_data.segment17
  ,p_segment18                 =>  l_pde_data.segment18
  ,p_segment19                 =>  l_pde_data.segment19
  ,p_segment20                 =>  l_pde_data.segment20
  ,p_segment21                 =>  l_pde_data.segment21
  ,p_segment22                 =>  l_pde_data.segment22
  ,p_segment23                 =>  l_pde_data.segment23
  ,p_segment24                 =>  l_pde_data.segment24
  ,p_segment25                 =>  l_pde_data.segment25
  ,p_segment26                 =>  l_pde_data.segment26
  ,p_segment27                 =>  l_pde_data.segment27
  ,p_segment28                 =>  l_pde_data.segment28
  ,p_segment29                 =>  l_pde_data.segment29
  ,p_segment30                 =>  l_pde_data.segment30
  ,p_position_id               =>  l_new_pos_id
  ,p_object_version_number     =>  l_ovn
  ,p_position_definition_id    =>  l_dummy_number
  ,p_name                      =>  l_new_pos_name
  );

  p_new_pos_id   := l_new_pos_id;
  p_new_pos_name := l_new_pos_name;
  p_ovn          := l_ovn;

END create_posn;

--
-- Given a from position id this procedure will create ALL the extra info
-- details associated with the from position id onto the to position id
-- For position copy we will explicity exclude types:
--  GHR_US_POS_MASS_ACTIONS
--  GHR_US_POS_OBLIG
PROCEDURE create_all_posn_ei (p_pos_id_from         IN NUMBER
                             ,p_effective_date_from IN DATE
                             ,p_pos_id_to           IN NUMBER
                             ,p_effective_date_to   IN DATE) IS
CURSOR cur_pit IS
  SELECT pit.information_type
  FROM   per_position_info_types pit
  WHERE  pit.information_type NOT IN ('GHR_US_POS_MASS_ACTIONS'
                                     ,'GHR_US_POS_OBLIG');
BEGIN
  FOR cur_pit_rec IN cur_pit LOOP
    ghr_position_copy.create_posn_ei(p_pos_id_from
                                    ,p_effective_date_from
                                    ,p_pos_id_to
                                    ,p_effective_date_to
                                    ,cur_pit_rec.information_type);
  END LOOP;
END create_all_posn_ei;
--
-- Given a from position id and information type this procedure will create the extra info
-- details associated with the from position id onto the to position id
PROCEDURE create_posn_ei (p_pos_id_from         IN NUMBER
                         ,p_effective_date_from IN DATE
                         ,p_pos_id_to           IN NUMBER
                         ,p_effective_date_to   IN DATE
                         ,p_info_type           IN VARCHAR2) IS
--
l_pos_ei_data   per_position_extra_info%rowtype;
l_dummy_number  NUMBER;
l_result_code   VARCHAR2(30);
--
CURSOR cur_poi IS
  SELECT poi.position_extra_info_id
  FROM   per_position_extra_info poi
  WHERE  poi.information_type = p_info_type
  AND    poi.position_id      = p_pos_id_from;
--
BEGIN
  -- loops to handle multi_occurrences
  FOR cur_poi_rec IN cur_poi LOOP
    -- Fetch from history
    ghr_history_fetch.fetch_positionei (
                p_position_extra_info_id => cur_poi_rec.position_extra_info_id
               ,p_date_effective         => p_effective_date_from
               ,p_posei_data             => l_pos_ei_data
               ,p_result_code            => l_result_code);
    --
    -- Now create it against the to position
    --
    ghr_position_extra_info_api.create_position_extra_info
      (p_validate                       => FALSE
      ,p_position_id                    => p_pos_id_to
      ,p_information_type               => p_info_type
      ,p_effective_date                 => p_effective_date_to
      ,p_poei_attribute_category        => l_pos_ei_data.poei_attribute_category
      ,p_poei_attribute1                => l_pos_ei_data.poei_attribute1
      ,p_poei_attribute2                => l_pos_ei_data.poei_attribute2
      ,p_poei_attribute3                => l_pos_ei_data.poei_attribute3
      ,p_poei_attribute4                => l_pos_ei_data.poei_attribute4
      ,p_poei_attribute5                => l_pos_ei_data.poei_attribute5
      ,p_poei_attribute6                => l_pos_ei_data.poei_attribute6
      ,p_poei_attribute7                => l_pos_ei_data.poei_attribute7
      ,p_poei_attribute8                => l_pos_ei_data.poei_attribute8
      ,p_poei_attribute9                => l_pos_ei_data.poei_attribute9
      ,p_poei_attribute10               => l_pos_ei_data.poei_attribute10
      ,p_poei_attribute11               => l_pos_ei_data.poei_attribute11
      ,p_poei_attribute12               => l_pos_ei_data.poei_attribute12
      ,p_poei_attribute13               => l_pos_ei_data.poei_attribute13
      ,p_poei_attribute14               => l_pos_ei_data.poei_attribute14
      ,p_poei_attribute15               => l_pos_ei_data.poei_attribute15
      ,p_poei_attribute16               => l_pos_ei_data.poei_attribute16
      ,p_poei_attribute17               => l_pos_ei_data.poei_attribute17
      ,p_poei_attribute18               => l_pos_ei_data.poei_attribute18
      ,p_poei_attribute19               => l_pos_ei_data.poei_attribute19
      ,p_poei_attribute20               => l_pos_ei_data.poei_attribute20
      ,p_poei_information_category      => l_pos_ei_data.poei_information_category
      ,p_poei_information1              => l_pos_ei_data.poei_information1
      ,p_poei_information2              => l_pos_ei_data.poei_information2
      ,p_poei_information3              => l_pos_ei_data.poei_information3
      ,p_poei_information4              => l_pos_ei_data.poei_information4
      ,p_poei_information5              => l_pos_ei_data.poei_information5
      ,p_poei_information6              => l_pos_ei_data.poei_information6
      ,p_poei_information7              => l_pos_ei_data.poei_information7
      ,p_poei_information8              => l_pos_ei_data.poei_information8
      ,p_poei_information9              => l_pos_ei_data.poei_information9
      ,p_poei_information10             => l_pos_ei_data.poei_information10
      ,p_poei_information11             => l_pos_ei_data.poei_information11
      ,p_poei_information12             => l_pos_ei_data.poei_information12
      ,p_poei_information13             => l_pos_ei_data.poei_information13
      ,p_poei_information14             => l_pos_ei_data.poei_information14
      ,p_poei_information15             => l_pos_ei_data.poei_information15
      ,p_poei_information16             => l_pos_ei_data.poei_information16
      ,p_poei_information17             => l_pos_ei_data.poei_information17
      ,p_poei_information18             => l_pos_ei_data.poei_information18
      ,p_poei_information19             => l_pos_ei_data.poei_information19
      ,p_poei_information20             => l_pos_ei_data.poei_information20
      ,p_poei_information21             => l_pos_ei_data.poei_information21
      ,p_poei_information22             => l_pos_ei_data.poei_information22
      ,p_poei_information23             => l_pos_ei_data.poei_information23
      ,p_poei_information24             => l_pos_ei_data.poei_information24
      ,p_poei_information25             => l_pos_ei_data.poei_information25
      ,p_poei_information26             => l_pos_ei_data.poei_information26
      ,p_poei_information27             => l_pos_ei_data.poei_information27
      ,p_poei_information28             => l_pos_ei_data.poei_information28
      ,p_poei_information29             => l_pos_ei_data.poei_information29
      ,p_poei_information30             => l_pos_ei_data.poei_information30
      ,p_position_extra_info_id         => l_dummy_number
      ,p_object_version_number          => l_dummy_number);

  END LOOP;
  --
END create_posn_ei;

--
-- Given a position id this function will create a position record
-- and its associated details (currently just EI) and pass back the new position id
PROCEDURE create_full_posn (p_pos_id              IN  NUMBER
                           ,p_effective_date_from IN  DATE
                           ,p_effective_date_to   IN  DATE
                           ,p_template_flag       IN  VARCHAR2
                           ,p_new_pos_id          OUT NOCOPY NUMBER
                           ,p_new_pos_name        OUT NOCOPY VARCHAR2
                           ,p_ovn                 OUT NOCOPY NUMBER) IS
--
l_new_pos_id   per_positions.position_id%TYPE;
l_new_pos_name per_positions.name%TYPE;

BEGIN

  create_posn(p_pos_id
             ,p_effective_date_from
             ,p_effective_date_to
             ,p_template_flag
             ,l_new_pos_id
             ,l_new_pos_name
             ,p_ovn);
  --
  create_all_posn_ei(p_pos_id
                    ,p_effective_date_from
                    ,l_new_pos_id
                    ,p_effective_date_to);
  --
  p_new_pos_id   := l_new_pos_id;
  p_new_pos_name := l_new_pos_name;

END create_full_posn;

--
-- Update the Template Position's Org and Job
--
FUNCTION update_position (p_pos_id              IN  NUMBER
                          ,p_new_org_id         IN NUMBER
                          ,p_new_job_id         IN NUMBER)
                          RETURN NUMBER IS

l_ovn number;

 cursor c_get_ovn is
 select  object_version_number
 from    per_positions
 where   position_id = p_pos_id;

BEGIN

Update per_positions
       set
       organization_id = p_new_org_id,
       job_id = p_new_job_id
       where position_id = p_pos_id;

For ovn in c_get_ovn loop
       l_ovn := ovn.object_version_number;
       RETURN(l_ovn);
End loop;

End update_position;


END ghr_position_copy;

/
