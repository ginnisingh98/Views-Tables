--------------------------------------------------------
--  DDL for Package Body QA_AUDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_AUDIT_PKG" AS
/* $Header: qaauditb.pls 120.1 2005/07/14 03:41 srhariha noship $ */

 -- Globals
 g_qb_result_columns DBMS_SQL.VARCHAR2_TABLE;
 g_que_result_columns DBMS_SQL.VARCHAR2_TABLE;
 g_master_result_columns DBMS_SQL.VARCHAR2_TABLE;
 g_pkg_name      CONSTANT VARCHAR2(30)   := 'QA_AUDIT_PKG';


  PROCEDURE init_globals(p_audit_bank_plan_id NUMBER,
                         p_audit_master_plan_id NUMBER,
                         p_audit_que_plan_id NUMBER) IS


  CURSOR c(x_plan_id NUMBER) IS
      SELECT char_id,result_column_name
      FROM qa_plan_chars
      WHERE plan_id = x_plan_id;

  BEGIN

    -- Bug 4345779. Audits Copy UI project.
    -- Code Review feedback incorporation. CR Ref 4.9.2
    -- Initialize global plsql tables.
    -- srhariha. Tue Jul 12 02:12:17 PDT 2005.
    g_qb_result_columns.DELETE;
    g_que_result_columns.DELETE;
    g_master_result_columns.DELETE;

    -- fill question bank
    FOR qb_rec IN c(p_audit_bank_plan_id) LOOP
        g_qb_result_columns(qb_rec.char_id) := qb_rec.result_column_name;
    END LOOP;

    -- fill audit master
    FOR qb_rec IN c(p_audit_master_plan_id) LOOP
        g_master_result_columns(qb_rec.char_id) := qb_rec.result_column_name;
    END LOOP;

    -- fill questions
    FOR qb_rec IN c(p_audit_que_plan_id) LOOP
        g_que_result_columns(qb_rec.char_id) := qb_rec.result_column_name;
    END LOOP;

  END init_globals;


 FUNCTION get_collection_id RETURN NUMBER IS

    CURSOR c1 IS SELECT QA_COLLECTION_ID_S.NEXTVAL FROM DUAL;
    l_collection_id NUMBER;

 BEGIN

     OPEN C1;
     FETCH C1 INTO l_collection_id;
     CLOSE C1;

     return l_collection_id;

 END get_collection_id;

 FUNCTION get_txn_header_id RETURN NUMBER IS

    l_txn_header_id NUMBER;
    CURSOR c2 IS SELECT MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL FROM DUAL;

 BEGIN

     OPEN C2;
     FETCH C2 INTO l_txn_header_id;
     CLOSE C2;

     return l_txn_header_id;

 END get_txn_header_id;

 FUNCTION common_insert_sql
            RETURN VARCHAR2 IS


 l_sql_string VARCHAR2(1000);

 BEGIN
   l_sql_string := 'INSERT INTO qa_results (     collection_id, ' ||
                                                '  occurrence,  ' ||
                                                '  last_update_date, ' ||
                                                '  qa_last_update_date, '||
                                                '  last_updated_by, ' ||
                                                '  qa_last_updated_by, ' ||
                                                '  creation_date,  ' ||
                                                '  qa_creation_date, ' ||
                                                '  created_by, ' ||
                                                '  last_update_login, ' ||
                                                '  qa_created_by, ' ||
                                                '  status, ' ||
                                                '  transaction_number, ' ||
                                                '  organization_id, ' ||
                                                '  plan_id, ' ||
                                                '  txn_header_id, ' ||
                                           g_que_result_columns(qa_ss_const.standard_violated) || ', ' ||
                                           g_que_result_columns(qa_ss_const.section_violated)  || ', ' ||
                                           g_que_result_columns(qa_ss_const.audit_area)        || ', ' ||
                                           g_que_result_columns(qa_ss_const.question_category) || ', ' ||
                                           g_que_result_columns(qa_ss_const.question_code)     || ', ' ||
                                           g_que_result_columns(qa_ss_const.audit_question)    || ') ' ||
                                        ' SELECT   :1,  ' ||
                                             '     QA_OCCURRENCE_S.NEXTVAL, ' ||
                                             '     sysdate, ' ||
                                             '     sysdate, ' ||
                                             '     fnd_global.user_id, ' ||
                                             '     fnd_global.user_id, ' ||
                                             '     sysdate, ' ||
                                             '     sysdate, ' ||
                                             '     fnd_global.user_id, ' ||
                                             '     fnd_global.user_id, ' ||
                                             '     fnd_global.user_id, ' ||
                                             '     2, ' ||
                                             '     -1, ' ||
                                             '     :2, ' || -- question and response org_id
                                             '     :3, ' || -- questions and resp plan_id
                                             '     :4,  ' || -- x_txn_header_id,
                                           g_qb_result_columns(qa_ss_const.standard_violated) || ', ' ||
                                           g_qb_result_columns(qa_ss_const.section_violated)  || ', ' ||
                                           g_qb_result_columns(qa_ss_const.audit_area)        || ', ' ||
                                           g_qb_result_columns(qa_ss_const.question_category) || ', ' ||
                                           g_qb_result_columns(qa_ss_const.question_code)     || ', ' ||
                                           g_qb_result_columns(qa_ss_const.audit_question)    || '  ' ||
                                       ' FROM  QA_RESULTS QR ' ||
                                       ' WHERE QR.PLAN_ID = :5 ' ||-- qb_plan_id
                                       ' AND QR.ORGANIZATION_ID = :6 '; -- qb_org_id




   RETURN l_sql_string;

 END common_insert_sql;


 PROCEDURE copy_question_rows(
             p_audit_bank_plan_id NUMBER,
             p_audit_bank_org_id NUMBER,
             p_summary_params qa_audit_pkg.SummaryParamArray ,
             p_audit_question_plan_id NUMBER,
             p_audit_question_org_id NUMBER,
             p_collection_id NUMBER,
             p_txn_header_id NUMBER) IS

   l_summ_params DBMS_SQL.VARCHAR2_TABLE;
   l_sql_string VARCHAR2(1000);
   l_perf_key VARCHAR2(20);

   -- Bug 4345779. Audits Copy UI project.
   -- Code Review feedback incorporation. CR Ref 4.9.1
   -- l_api_name must be declared as constant.
   -- srhariha. Tue Jul 12 02:12:17 PDT 2005.

   l_api_name CONSTANT VARCHAR2(40) := 'COPY_QUESTIONS(..summParam..)';
 BEGIN
    if(p_summary_params IS NULL OR
                          p_summary_params.FIRST IS NULL) THEN
       return;
    end if;


    FOR i IN p_summary_params.FIRST .. p_summary_params.LAST LOOP
       l_summ_params(i) := p_summary_params(i).standard;
    END LOOP;
    l_perf_key := 'AUDIT_STANDARD';
    qa_performance_temp_pkg.purge_and_add_names(l_perf_key,l_summ_params);


    l_sql_string := common_insert_sql ||
                    ' AND ' ||  g_qb_result_columns(qa_ss_const.standard_violated) ||
                    ' IN (SELECT NAME ' ||
                        ' FROM QA_PERFORMANCE_TEMP ' ||
                        ' WHERE KEY = :7) ';

   EXECUTE IMMEDIATE l_sql_string USING p_collection_id,
                                        p_audit_question_org_id,
                                        p_audit_question_plan_id,
                                        p_txn_header_id,
                                        p_audit_bank_plan_id,
                                        p_audit_bank_org_id,
                                        l_perf_key;

   EXCEPTION

      WHEN OTHERS THEN
       IF ( FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) ) THEN
          FND_MSG_PUB.Add_Exc_Msg
          (
            p_pkg_name       => g_pkg_name,
            p_procedure_name => l_api_name,
            p_error_text     => SUBSTR(SQLERRM,1,240)
          );
        END IF;

        IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_procedure,
            g_pkg_name || '.' || l_api_name,
            'EXITING PROCEDURE: ERROR'
          );
        END IF;

        RAISE;
 END copy_question_rows;


 PROCEDURE copy_question_rows(
             p_audit_bank_plan_id NUMBER,
             p_audit_bank_org_id NUMBER,
             p_cat_summary_params qa_audit_pkg.CatSummaryParamArray ,
             p_audit_question_plan_id NUMBER,
             p_audit_question_org_id NUMBER,
             p_collection_id NUMBER,
             p_txn_header_id NUMBER) IS

   l_summ_param DBMS_SQL.VARCHAR2_TABLE;
   l_sql_string VARCHAR2(1000);

   -- Bug 4345779. Audits Copy UI project.
   -- Code Review feedback incorporation. CR Ref 4.9.1
   -- l_api_name must be declared as constant.
   -- srhariha. Tue Jul 12 02:12:17 PDT 2005.

   l_api_name CONSTANT VARCHAR2(40) := 'COPY_QUESTIONS(..CatsummParam..)';
 BEGIN
    if(p_cat_summary_params IS NULL OR
                   p_cat_summary_params.FIRST IS NULL) THEN
       return;
    end if;


    FOR i IN p_cat_summary_params.FIRST .. p_cat_summary_params.LAST LOOP

    l_sql_string := common_insert_sql ||
                  ' AND ' || g_qb_result_columns(qa_ss_const.standard_violated) || ' = :7 '||
                  ' AND ' || g_qb_result_columns(qa_ss_const.section_violated)  || ' = :8 '||
                  ' AND ' || g_qb_result_columns(qa_ss_const.audit_area)        || ' = :9 '||
                  ' AND ' || g_qb_result_columns(qa_ss_const.question_category) || ' = :10 ';

    EXECUTE IMMEDIATE l_sql_string USING p_collection_id,
                                        p_audit_question_org_id,
                                        p_audit_question_plan_id,
                                        p_txn_header_id,
                                        p_audit_bank_plan_id,
                                        p_audit_bank_org_id,
                                        p_cat_summary_params(i).standard,
                                        p_cat_summary_params(i).section,
                                        p_cat_summary_params(i).area,
                                        p_cat_summary_params(i).category;

  END LOOP;

   EXCEPTION

      WHEN OTHERS THEN
       IF ( FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) ) THEN
          FND_MSG_PUB.Add_Exc_Msg
          (
            p_pkg_name       => g_pkg_name,
            p_procedure_name => l_api_name,
            p_error_text     => SUBSTR(SQLERRM,1,240)
          );
        END IF;

        IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_procedure,
            g_pkg_name || '.' || l_api_name,
            'EXITING PROCEDURE: ERROR'
          );
        END IF;

        RAISE;

 END copy_question_rows;

 PROCEDURE get_audit_master_keys (p_audit_question_plan_id NUMBER,
                                  p_audit_question_org_id NUMBER,
                                  p_audit_num VARCHAR2,
                                  x_plan_id OUT NOCOPY NUMBER,
                                  x_collection_id OUT NOCOPY NUMBER,
                                  x_occurrence OUT NOCOPY NUMBER) IS

 CURSOR C(x_id NUMBER, x_org_id NUMBER, x_audit_num VARCHAR2) IS
  SELECT qr.plan_id,
         qr.collection_id,
         qr.occurrence
  FROM  qa_results qr, qa_pc_plan_relationship qppr
  WHERE qr.plan_id = qppr.parent_plan_id
  AND qppr.child_plan_id = x_id
  AND qr.organization_id = x_org_id
  AND (qr.status = 2 OR qr.status IS NULL)
  AND qr.sequence6 = x_audit_num;

 BEGIN

 OPEN C(p_audit_question_plan_id,p_audit_question_org_id,p_audit_num);
 FETCH C into x_plan_id,x_collection_id,x_occurrence;
 CLOSE C;

 END get_audit_master_keys;


FUNCTION  get_copied_row_count (p_audit_que_plan_id NUMBER,
                            p_collection_id NUMBER) RETURN NUMBER IS

  CURSOR C IS
  SELECT count(OCCURRENCE)
  FROM QA_RESULTS
  WHERE plan_id = p_audit_que_plan_id
  AND collection_id = p_collection_id;

  l_rows NUMBER;

 BEGIN
  OPEN C;
  FETCH C INTO l_rows;
  CLOSE C;

  return l_rows;

 END get_copied_row_count;

 PROCEDURE copy_questions(
             p_audit_bank_plan_id NUMBER,
             p_audit_bank_org_id NUMBER,
             p_summary_params qa_audit_pkg.SummaryParamArray,
             p_cat_summary_params qa_audit_pkg.CatSummaryParamArray,
             p_audit_question_plan_id NUMBER,
             p_audit_question_org_id NUMBER,
             p_audit_num VARCHAR2,
             x_count OUT NOCOPY NUMBER,
             x_msg_count OUT NOCOPY NUMBER,
             x_msg_data OUT NOCOPY VARCHAR2,
             x_return_status OUT NOCOPY VARCHAR2) IS


  l_collection_id NUMBER;
  l_txn_header_id NUMBER;
  l_master_plan_id NUMBER;
  l_master_collection_id NUMBER;
  l_master_occurrence NUMBER;
  l_ret_status VARCHAR2(10);
   -- Bug 4345779. Audits Copy UI project.
   -- Code Review feedback incorporation. CR Ref 4.9.1
   -- l_api_name must be declared as constant.
   -- srhariha. Tue Jul 12 02:12:17 PDT 2005.

  l_api_name CONSTANT VARCHAR2(40) := 'COPY_QUESTIONS()';


  BEGIN


     SAVEPOINT copy_questions_SP;

      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- (1) verify whether user has create privillege on audit questions plan

      l_ret_status := qa_web_txn_api.allowed_for_plan (
                                   p_function_name => 'QA_RESULTS_ENTER',
                                   p_plan_id => p_audit_question_plan_id);

     if(l_ret_status = 'F') then
         x_return_status := FND_API.G_RET_STS_ERROR;
         return;
     end if;


     -- create id's
     l_collection_id := get_collection_id;
     l_txn_header_id := get_txn_header_id;
     -- get master details
     get_audit_master_keys(p_audit_question_plan_id => p_audit_question_plan_id,
                            p_audit_question_org_id => p_audit_question_org_id,
                            p_audit_num => p_audit_num,
                            x_plan_id => l_master_plan_id,
                            x_collection_id => l_master_collection_id,
                            x_occurrence => l_master_occurrence);


     -- init globals
     init_globals(p_audit_bank_plan_id => p_audit_bank_plan_id,
                  p_audit_master_plan_id => l_master_plan_id,
                  p_audit_que_plan_id => p_audit_question_plan_id);


       -- (2) copy questions from qb to questions plan

      if(p_summary_params is not null) then
        copy_question_rows(p_audit_bank_plan_id => p_audit_bank_plan_id,
                           p_audit_bank_org_id => p_audit_bank_org_id,
                           p_summary_params => p_summary_params,
                           p_audit_question_plan_id => p_audit_question_plan_id,
                           p_audit_question_org_id => p_audit_question_org_id,
                           p_collection_id => l_collection_id,
                           p_txn_header_id => l_txn_header_id);
      end if;


       if(p_cat_summary_params is not null) then
         copy_question_rows(p_audit_bank_plan_id => p_audit_bank_plan_id,
                            p_audit_bank_org_id => p_audit_bank_org_id,
                            p_cat_summary_params => p_cat_summary_params,
                            p_audit_question_plan_id => p_audit_question_plan_id,
                            p_audit_question_org_id => p_audit_question_org_id,
                            p_collection_id => l_collection_id,
                            p_txn_header_id => l_txn_header_id);
       end if;

    -- Bug 4345779. Audits Copy UI project.
    -- Code Review feedback incorporation. CR Ref 4.9.5, 4.9.6 and 4.9.7
    -- Modularization. Moved the following procedures to parent child pkg.
    --   . create_relationship
    --   . copy_from_parent
    --   . create_history
    -- srhariha. Tue Jul 12 02:12:17 PDT 2005.

    -- (3) create entry in qa_pc_results_relationship
    qa_parent_child_pkg.create_relationship_for_coll
                       (p_parent_plan_id => l_master_plan_id,
                        p_parent_collection_id => l_master_collection_id,
                        p_parent_occurrence => l_master_occurrence,
                        p_child_plan_id => p_audit_question_plan_id,
                        p_child_collection_id => l_collection_id,
                        p_org_id => p_audit_question_org_id);


   -- (4) copy elements from audit master
   qa_parent_child_pkg.copy_from_parent_for_coll
                   (p_parent_plan_id => l_master_plan_id,
                    p_parent_collection_id => l_master_collection_id,
                    p_parent_occurrence => l_master_occurrence,
                    p_child_plan_id => p_audit_question_plan_id,
                    p_child_collection_id => l_collection_id,
                    p_org_id => p_audit_question_org_id);


  -- (5) create history for audit questions
  qa_parent_child_pkg.create_history_for_coll
                ( p_plan_id => p_audit_question_plan_id,
                  p_collection_id => l_collection_id,
                  p_org_id => p_audit_question_org_id,
                  p_txn_header_id => l_txn_header_id);
  -- (6) return number of rows copied
  x_count := get_copied_row_count(p_audit_question_plan_id,l_collection_id);




      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

      IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_procedure,
          g_pkg_name || '.' || l_api_name,
          'EXITING PROCEDURE: SUCCESS'
        );
      END IF;

    EXCEPTION

      WHEN OTHERS THEN
        ROLLBACK TO copy_questions_SP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF ( FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) ) THEN
          FND_MSG_PUB.Add_Exc_Msg
          (
            p_pkg_name       => g_pkg_name,
            p_procedure_name => l_api_name,
            p_error_text     => SUBSTR(SQLERRM,1,240)
          );
        END IF;

        FND_MSG_PUB.Count_And_Get
        (
          p_count => x_msg_count,
          p_data  => x_msg_data
        );

        IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_procedure,
            g_pkg_name || '.' || l_api_name,
            'EXITING PROCEDURE: ERROR'
          );
        END IF;

  END copy_questions;


END qa_audit_pkg;

/
