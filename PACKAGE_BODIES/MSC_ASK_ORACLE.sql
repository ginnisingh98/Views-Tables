--------------------------------------------------------
--  DDL for Package Body MSC_ASK_ORACLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_ASK_ORACLE" AS
/*$Header: MSCASKOB.pls 120.1 2005/06/17 13:13:39 appldev  $ */

-- This procedure is called from the concurrent program to register the
-- questions for Ask Oracle via SRS
PROCEDURE register_question(
   errbuf             OUT NoCopy VARCHAR2,
   retcode            OUT NoCopy VARCHAR2,
   x_mode             IN  NUMBER,
   x_question_code    IN  VARCHAR2,
   x_question_type    IN  VARCHAR2 DEFAULT NULL,
   x_lang_code        IN  VARCHAR2 DEFAULT NULL,
   x_question         IN  VARCHAR2 DEFAULT NULL,
   x_package_name     IN  VARCHAR2 DEFAULT NULL,
   x_copy_question    IN  VARCHAR2 DEFAULT NULL)
IS
 x_question_id number := null;
BEGIN
   msc_util.msc_debug('******** Start of Program ********');
   msc_util.msc_debug('Mode:'|| to_char(x_mode));
   msc_util.msc_debug('QuestionType:'|| x_question_type);
   msc_util.msc_debug('QuestionCode:'|| x_question_code);
   msc_util.msc_debug('Question:'|| x_question);
   msc_util.msc_debug('Language:'|| x_lang_code);
   msc_util.msc_debug('PackageName:'|| x_package_name);
   msc_util.msc_debug('Copy Question:'|| x_copy_question);
   msc_util.msc_debug('**********************************');
   -- There are multiple modes
   -- (1) new question, so insert data
   -- (2) copy question from a existing question, so insert data
   -- (3) update question, so update data
   -- (4) delete question, so delete data
 IF (x_mode = 1) THEN
   -- First insert into msc_questions_b and then into msc_questions_tl
   -- Note that the sequence will ensure that all question_ids are
   -- greater than 5001
   SELECT msc_questions_s.nextval
   INTO   x_question_id
   FROM   dual;
   msc_util.msc_debug('QuestionId:'|| to_char(x_question_id));

   INSERT INTO MSC_QUESTIONS_B(
    QUESTION_ID
    ,ANSWER_ID
    ,QUESTION_CODE
    ,QUESTION_TYPE
    ,PACKAGE_NAME
    ,LAST_UPDATE_DATE
    ,LAST_UPDATED_BY
    ,CREATION_DATE
    ,CREATED_BY
    ,LAST_UPDATE_LOGIN		)
   SELECT
    x_question_id
    ,null
    ,x_question_code
    ,x_question_type
    ,x_package_name
    ,sysdate
    ,fnd_global.user_id
    ,sysdate
    ,fnd_global.user_id
    ,fnd_global.conc_login_id
   FROM dual
   WHERE  not exists (select 'already exists'
                    from msc_questions_b
                    where question_code = x_question_code);
   msc_util.msc_debug('Inserted into msc_questions_b:'|| sql%rowcount);

   INSERT INTO MSC_QUESTIONS_TL(
    QUESTION_ID
    ,LANGUAGE
    ,USER_QUESTION_NAME
    ,DESCRIPTION
    ,SOURCE_LANG
    ,TRANSLATED
    ,LAST_UPDATE_DATE
    ,LAST_UPDATED_BY
    ,CREATION_DATE
    ,CREATED_BY
    ,LAST_UPDATE_LOGIN		)
   SELECT
    x_question_id
    ,x_lang_code
    ,x_question
    ,NULL
    ,x_lang_code
    ,NULL
    ,sysdate
    ,fnd_global.user_id
    ,sysdate
    ,fnd_global.user_id
    ,fnd_global.conc_login_id
   FROM dual
   WHERE not exists
              (select 'already exists'
               from msc_questions_tl
               where  question_id = (select question_id
                                     from msc_questions_b
                                     where question_code = x_question_code)
               and    language = x_lang_code);

   msc_util.msc_debug('Inserted msc_questions_tl:' || to_char(sql%rowcount));
 ELSIF (x_mode = 2) THEN -- copy mode
   SELECT msc_questions_s.nextval
   INTO   x_question_id
   FROM   dual;
   msc_util.msc_debug('QuestionId:'|| to_char(x_question_id));

   INSERT INTO MSC_QUESTIONS_B(
    QUESTION_ID
    ,ANSWER_ID
    ,QUESTION_CODE
    ,QUESTION_TYPE
    ,PACKAGE_NAME
    ,LAST_UPDATE_DATE
    ,LAST_UPDATED_BY
    ,CREATION_DATE
    ,CREATED_BY
    ,LAST_UPDATE_LOGIN		)
   SELECT
    x_question_id
    ,null
    ,x_question_code
    ,q.question_type
    ,q.package_name
    ,sysdate
    ,fnd_global.user_id
    ,sysdate
    ,fnd_global.user_id
    ,fnd_global.conc_login_id
   FROM msc_questions_b q
   WHERE  q.question_code = x_copy_question
   AND  not exists (select 'already exists'
                    from msc_questions_b
                    where question_code = x_question_code);
   msc_util.msc_debug('Inserted into msc_questions_b:'|| sql%rowcount);

   INSERT INTO MSC_QUESTIONS_TL(
    QUESTION_ID
    ,LANGUAGE
    ,USER_QUESTION_NAME
    ,DESCRIPTION
    ,SOURCE_LANG
    ,TRANSLATED
    ,LAST_UPDATE_DATE
    ,LAST_UPDATED_BY
    ,CREATION_DATE
    ,CREATED_BY
    ,LAST_UPDATE_LOGIN		)
   SELECT
    x_question_id
    ,q.language
    ,x_question
    ,NULL
    ,x_lang_code
    ,NULL
    ,sysdate
    ,fnd_global.user_id
    ,sysdate
    ,fnd_global.user_id
    ,fnd_global.conc_login_id
   FROM msc_questions_tl q
   WHERE q.language = x_lang_code
   AND q.question_id = (select question_id
                        from msc_questions_b
                       x where question_code = x_copy_question)
   AND    not exists
              (select 'already exists'
               from msc_questions_tl
               where  question_id = (select question_id
                                     from msc_questions_b
                                     where question_code = x_question_code)
               and    language = x_lang_code);

   msc_util.msc_debug('Inserted msc_questions_tl:' || to_char(sql%rowcount));
 ELSIF (x_mode = 3) THEN -- update mode
   update msc_questions_b
   set    package_name = x_package_name
   where  question_code = x_question_code;
   msc_util.msc_debug('Updated msc_questions_b:' || to_char(sql%rowcount) ||
                      ':'|| x_question_code ||'with package name value:'  ||
                         x_package_name);

   update msc_questions_tl
   set    user_question_name = x_question
   where  question_id = (select question_id
                         from   msc_questions_b
                         where  question_code = x_question_code)
   and    language = x_lang_code;
   msc_util.msc_debug('Updated msc_questions_tl:' || to_char(sql%rowcount) ||
                      ':' || x_question_code || 'with user question:' ||
                      x_question);
 ELSIF (x_mode = 4) THEN -- delete mode
   delete msc_questions_tl
   where  question_id = (select question_id
                         from msc_questions_b
                         where question_code = x_question_code);
   msc_util.msc_debug('Deleted msc_questions_tl:'|| to_char(sql%rowcount) ||
                      ':' || x_question_code);

   delete msc_questions_b
   where  question_code = x_question_code;
   msc_util.msc_debug('Deleted msc_questions_b:'|| to_char(sql%rowcount) ||
                      ':' || x_question_code);
 END IF;
 COMMIT WORK;
 retcode := 0;
 return;

EXCEPTION
   WHEN OTHERS THEN
     errbuf := 'MSC_ASK_ORACLE.register_question:' || to_char(sqlcode) || ':'
                   || substr(sqlerrm,1,60);
     retcode := 2;
END register_question;

FUNCTION ask(
   x_question_id      IN  NUMBER,
   x_question_type    IN  VARCHAR2,
   x_question         IN  VARCHAR2,
   x_plan_id          IN  NUMBER,
   x_key1             IN  NUMBER DEFAULT NULL,
   x_key2             IN  NUMBER DEFAULT NULL,
   x_key3             IN  NUMBER DEFAULT NULL,
   x_key4             IN  NUMBER DEFAULT NULL,
   x_answer_id        OUT NoCopy NUMBER,
   x_err_msg          OUT NoCopy VARCHAR2,
   x_msg_count        OUT NoCopy NUMBER)
RETURN BOOLEAN
IS
  p_answer_id NUMBER;
  p_err_msg   VARCHAR2(2000);
  p_msg_count NUMBER;
  x_stmt_num  NUMBER := 0;
  v_sql_stmt  VARCHAR2(400);
  x_question_code VARCHAR2(25);
  x_pkg_name VARCHAR2(25);
BEGIN
  -- First do the fuzzy match
  IF (x_question_id IS NULL and x_question is NOT NULL) THEN
    x_stmt_num := 10;
  ELSE
    -- Setup the package variables
    x_stmt_num := 20;
    v_question_id := x_question_id;
    v_question_type := x_question_type;
    v_question_code := x_question_code;
    v_question := x_question;
    v_plan_id := x_plan_id;
    v_seq_num := 0;
    v_key1 := x_key1;
    v_key2 := x_key2;

    -- Call the appropriate procedure to process this questions
    x_stmt_num := 30;
    SELECT NVL(package_name,'MSC_ASK_ORACLE'), question_code
    INTO   x_pkg_name, x_question_code
    FROM   msc_questions_b
    WHERE  question_id = x_question_id;

    x_stmt_num := 40;
    v_sql_stmt := 'BEGIN' || ' ' ||
                     x_pkg_name || '.' || x_question_code ||
                        '(:p_answer_id, :p_err_msg, :p_msg_count);' ||
                  'END;';
    x_stmt_num := 50;
  --  dbms_output.put_line(x_stmt_num || ':' || v_sql_stmt);
    EXECUTE IMMEDIATE v_sql_stmt USING IN OUT
                p_answer_id,IN OUT p_err_msg, IN OUT p_msg_count;

    x_stmt_num := 60;
    x_answer_id := p_answer_id;
    x_err_msg   := p_err_msg;
    x_msg_count := p_msg_count;

    return(TRUE);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_err_msg := 'MSC_ASK_ORACLE.ASK:' || to_char(x_stmt_num) || ':' ||
                       to_char(sqlcode) || ':' || substr(sqlerrm,1,60);
    return(FALSE);
END ask;

PROCEDURE get_question(
   x_question_id      OUT NoCopy NUMBER,
   x_question_type    OUT NoCopy VARCHAR2,
   x_question_code    OUT NoCopy NUMBER)
IS
BEGIN
   x_question_id := v_question_id;
   x_question_code := v_question_code;
   x_question_type := v_question_type;
   return;
END get_question;

PROCEDURE get_key(
   x_question_type    OUT NoCopy VARCHAR2,
   x_plan_id          OUT NoCopy NUMBER,
   x_key1             OUT NoCopy NUMBER,
   x_key2             OUT NoCopy NUMBER)
IS
BEGIN
   x_question_type := v_question_type;
   x_plan_id := v_plan_id;
   x_key1 := v_key1;
   x_key2 := v_key2;
   return;
END get_key;

PROCEDURE get_answer_id(
    answer_id OUT NoCopy NUMBER)
IS
BEGIN
    SELECT msc_answers_s.nextval
    INTO   answer_id
    FROM   sys.dual;

    return;
EXCEPTION
  WHEN OTHERS THEN
    raise;
END get_answer_id;

PROCEDURE get_sequence(
    seq_num OUT NoCopy NUMBER)
IS
BEGIN
    v_seq_num := v_seq_num + 5;
    seq_num := v_seq_num;
    return;
EXCEPTION
  WHEN OTHERS THEN
    raise;
END get_sequence;

PROCEDURE insert_answer(
    a_id IN NUMBER,
    q_id IN NUMBER,
    seq  IN NUMBER,
    ans  IN VARCHAR2)
IS
BEGIN
 --  dbms_output.put_line('Inserting answer:'|| ans);
   INSERT INTO MSC_ANSWERS(
      ANSWER_ID,
      QUESTION_ID,
      SEQ_NUM,
      SESSION_ID,
      ANSWER_TEXT,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY)
   SELECT
      a_id,
      q_id,
      seq,
      USERENV('SESSIONID'),
      ans,
      sysdate,
      FND_GLOBAL.USER_ID,
      sysdate,
      FND_GLOBAL.USER_ID
   FROM sys.dual;

   return;
EXCEPTION
  WHEN OTHERS THEN
 --   dbms_output.put_line('Error in inserting answer:'|| to_char(sqlcode));
    raise;
END insert_answer;

PROCEDURE late_prj(
   x_answer_id        IN OUT NoCopy NUMBER,
   x_err_msg          IN OUT NoCopy VARCHAR2,
   x_msg_count        IN OUT NoCopy NUMBER)
IS
  l_plan  NUMBER;
  l_qtype VARCHAR2(10);
  l_key1  NUMBER;
  l_key2  NUMBER;
  l_prj   VARCHAR2(100);
  l_task  VARCHAR2(100);
  l_ans   VARCHAR2(100);
  l_es    DATE;
  l_ef    DATE;
  l_ls    DATE;
  l_lf    DATE;
  l_ss    DATE;
  l_sf    DATE;
  l_due_date DATE;
BEGIN
  -- Get the keys
  get_key(l_qtype,l_plan,l_key1,l_key2);
  IF (l_qtype = 'SUPPLY') THEN
     -- First find the end demand that this supply is pegged to, and get
     -- its due date
     SELECT min(peg2.demand_date)
     INTO  l_due_date
     FROM  msc_full_pegging peg2, msc_full_pegging peg1
     WHERE peg1.plan_id = l_plan
     AND   peg1.transaction_id (+) = l_key1
     AND   peg2.pegging_id = peg1.end_pegging_id (+);
     -- Then, get the dates of this task as defined in Oracle Projects
     SELECT p2.project_number||'-'||p1.task_number || '-' ||p2.task_name,
            early_start_date,
            early_finish_date,late_start_date, late_finish_date,
            scheduled_start_date, scheduled_finish_date
     INTO   l_prj, l_es, l_ef, l_ls, l_lf, l_ss, l_sf
     FROM   pjm_tasks_v  p2, pa_tasks_v p1, msc_supplies m
     WHERE  p2.project_id = p1.project_id
     AND    p2.task_id = p1.task_id
     AND    p1.project_id = m.project_id
     AND    p1.task_id = m.task_id
     AND    m.transaction_id = l_key1;

     -- Construct the message that is to be displayed and insert it
     IF (l_es > l_due_date) THEN
       l_ans := 'The project '||l_prj || 'is early. It has a early ' ||
          'completion date of '|| to_char(l_ef) ||' and completion'||
          'date of '|| to_char(l_due_date);
     ELSIF (l_lf < l_due_date) THEN
       l_ans := 'The project '||l_prj || 'is late. It has a late ' ||
          'completion date of '|| to_char(l_lf) ||' and completion'||
          'date of '|| to_char(l_due_date);
     ELSE
       l_ans := 'The project '||l_prj || 'is within guidelines. It has a '||
          'early completion date of '|| to_char(l_ef) ||' , a late completion'
        ||' date of ' || to_char(l_lf) ||' , a early start date of ' ||
          to_char(l_es) || ', a late start date of '|| to_char(l_ls) ||
          ' and completion date of '|| to_char(l_due_date);
     END IF;
  ELSIF (l_qtype = 'DEMAND') THEN
    null;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    raise;
END late_prj;

-- This procedure answers questions about why a supply is late
--    supplier capacity issue
--    resource capacity overloading
PROCEDURE late_supply(
   x_answer_id        IN OUT NoCopy NUMBER,
   x_err_msg          IN OUT NoCopy VARCHAR2,
   x_msg_count        IN OUT NoCopy NUMBER)
IS
  l_plan  NUMBER;
  l_qtype VARCHAR2(10);
  l_qid   NUMBER;
  l_qcode VARCHAR2(25);
  l_key1  NUMBER;
  l_key2  NUMBER;
  l_ansid NUMBER;
  l_ans   VARCHAR2(1000);
  l_seq   NUMBER := 0; -- remember to increment while inserting the answers

  l_so_num VARCHAR2(100);
  l_dmd_schedule VARCHAR2(30);
  l_dmd_date DATE;
  l_op_seq_num   NUMBER;
  l_op_code      VARCHAR2(10);
  l_res_seq_num  NUMBER;
  l_start_date   DATE;
  l_end_date     DATE;

  CURSOR pegging(lkey NUMBER, lplan NUMBER) IS
  SELECT dmd.order_number,NULL, --dmd.demand_schedule_name,
         dmd.using_assembly_demand_date
  FROM   msc_demands dmd, msc_full_pegging peg
  WHERE  peg.transaction_id = lkey
  AND    peg.plan_id = lplan
  AND    peg.demand_id = dmd.demand_id
  AND    peg.plan_id = dmd.plan_id
  AND    dmd.using_assembly_demand_date < peg.supply_date;

  CURSOR overloaded_res(lkey NUMBER, lplan NUMBER) IS
  SELECT res.operation_seq_num, res.std_op_code, res.resource_seq_num,
         res.start_date, res.end_date
  FROM   msc_resource_requirements res, msc_supplies sup
  WHERE  sup.plan_id = lplan
  AND    sup.transaction_id = lkey
  AND    res.plan_id = sup.plan_id
  AND    res.supply_id = sup.transaction_id
  AND    NVL(res.end_date,res.start_date) < sup.new_schedule_date
  ORDER  BY res.operation_seq_num, res.resource_seq_num;
BEGIN
  -- Get all the key information
  get_question(l_qid,l_qtype,l_qcode);
  get_key(l_qtype,l_plan,l_key1,l_key2);
--  dbms_output.put_line('Entering late supply:'|| to_char(l_plan) || ':' ||
--              to_char(l_key1));
  IF (x_answer_id is NULL) THEN
    get_answer_id(l_ansid);
  END IF;
  get_sequence(l_seq);

  -- Check if the supply is late
  OPEN pegging(l_key1,l_plan);
  FETCH pegging INTO l_so_num, l_dmd_schedule, l_dmd_date;
  IF pegging%NOTFOUND THEN
 --   dbms_output.put_line('No data is found here!');
    -- This supply does not cause any late demands, so it is not late
 --   dbms_output.put_line('No demands are late');
    l_ans := 'This supply does not cause any late demand';
    insert_answer(l_ansid,l_qid,l_seq,l_ans);
  ELSE
 --   dbms_output.put_line('l_so_num=' || l_so_num ||':l_dmd_schedule=' ||
  --      l_dmd_schedule|| ':l_dmd_date='|| to_char(l_dmd_date));
    -- Check each of the resources to see which is overloaded
    OPEN overloaded_res(l_key1, l_plan);
    LOOP
      FETCH overloaded_res INTO l_op_seq_num, l_op_code, l_res_seq_num,
           l_start_date, l_end_date;
      EXIT WHEN overloaded_res%NOTFOUND;
      -- For each of the overloaded resources and operations, insert answers
      get_sequence(l_seq);
   --   dbms_output.put_line('Overloaded resources:'|| to_char(l_seq));
    END LOOP;
  END IF;
  x_answer_id := l_ansid;
  return;
EXCEPTION
  WHEN OTHERS THEN
    raise;
END late_supply;

-- This procedure answers questions about why a demand is late
--    looks at the late supplies the demand is pegged to, and picks the
--    one that is lowest in the chain
--    for this supply, it figures out why the supply is late
PROCEDURE late_demand(
   x_answer_id        IN OUT NoCopy NUMBER,
   x_err_msg          IN OUT NoCopy VARCHAR2,
   x_msg_count        IN OUT NoCopy NUMBER)
IS
  l_plan  NUMBER;
  l_qtype VARCHAR2(10);
  l_qid   NUMBER;
  l_qcode VARCHAR2(25);
  l_key1  NUMBER;
  l_key2  NUMBER;
  l_ansid NUMBER;
  l_ans   VARCHAR2(1000);
  l_seq   NUMBER := 0; -- remember to increment while inserting the answers

  l_so_num VARCHAR2(100);
  l_dmd_schedule VARCHAR2(30);
  l_dmd_date DATE;
  l_op_seq_num   NUMBER;
  l_op_code      VARCHAR2(10);
  l_res_seq_num  NUMBER;
  l_start_date   DATE;
  l_end_date     DATE;
  l_supply_id    NUMBER;
  l_err_msg      VARCHAR2(2000);
  l_msg_count    NUMBER;

  CURSOR pegging(lkey NUMBER, lplan NUMBER) IS
  SELECT peg.transaction_id
  FROM   msc_full_pegging peg
  WHERE  peg.demand_date > peg.supply_date
  START WITH peg.demand_id = lkey
     AND     peg.plan_id = lplan
  CONNECT BY PRIOR peg.pegging_id = peg.prev_pegging_id
  ORDER BY peg.demand_date;
BEGIN
  -- Get all the key information
  get_question(l_qid,l_qtype,l_qcode);
  get_key(l_qtype,l_plan,l_key1,l_key2);
--  dbms_output.put_line('Entering late demand:'|| to_char(l_plan) || ':' ||
 --             to_char(l_key1));
  IF (x_answer_id is NULL) THEN
    get_answer_id(l_ansid);
  END IF;
  get_sequence(l_seq);
  -- Check if the supply is late
  OPEN pegging(l_key1,l_plan);
  FETCH pegging INTO l_supply_id;
  IF pegging%NOTFOUND THEN
   -- dbms_output.put_line('No data is found here!');
    -- This supply does not cause any late demands, so it is not late
   -- dbms_output.put_line('No demands are late');
    l_ans := 'This demand or its dependent demands are satisfied on time';
    insert_answer(l_ansid,l_qid,l_seq,l_ans);
    return;
  END IF ;
  -- Now that we have the late supply, find out why that is late
  -- Set the package variable key appropriately
  v_key1 := l_supply_id;
  MSC_ASK_ORACLE.LATE_SUPPLY(
                   x_answer_id => l_ansid,
                   x_err_msg   => l_err_msg,
                   x_msg_count => l_msg_count);
  x_answer_id := l_ansid;
  x_err_msg   := l_err_msg;
  x_msg_count := l_msg_count;
  -- Reset the package variable key for future use
  v_key1 := l_key1;
  return;
EXCEPTION
  WHEN OTHERS THEN
    raise;
END late_demand;

END msc_ask_oracle;

/
