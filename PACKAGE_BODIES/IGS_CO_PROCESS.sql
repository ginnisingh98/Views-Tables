--------------------------------------------------------
--  DDL for Package Body IGS_CO_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CO_PROCESS" AS
/* $Header: IGSCO22B.pls 120.12 2006/05/31 10:25:46 vskumar ship $ */
  /*************************************************************
  Created By :Nalin Kumar
  Date Created on : 05-Feb-2002
  Purpose : This package will consist of procedures that will perform validation
            and processing of correspondence related information and data.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  svadde		28-Apr-2006		Bug 5126451 removed the dubuging of sql statement
  pkpatel      6-Feb-2006      Bug 4937960 (MOdified the Person ID group logic to use get_dynamic_sql function to solve literal issue. Uncommented all the FND loggings)
   pacross     11-APR-2005     Implemented code for Correspondance preview and edit fucntionality
   mnade          6/1/2005        FA 157 Added p_award_prd_cd parameter to corp_post_process
  ssaleem         09-SEP-2004   3630073. Added p_org_unit_id as a new parameter
   ssawhney   3-may-04        IBC.C patchset changes bug 3565861 + 3442719 + signature of corp_get_letter_type changed + interaction history signature changes
                              citemverid changes.
   gmaheswa   15-Nov-2003     Bug : 3006800 Added New parameter p_fax_number in corp_submit_fulfil_request and
                                   fax number is passed to jtf_fm_request_grp.get_content_xml as p_fax.
   ssaleem    28-OCT-2003     Bug : 3198795
                                   Part of the Dynamic/Static Person Groups modifications,
           Procedure corp_get_parameter_value is modified.
   npalanis   23-OCT-2002     Bug : 2547368
                              Defaulting arguments in funtion and procedure definitions removed
   kpadiyar   04-MAR-2003     Bug # 2520895 - Condition added with outcome status <> CANCELLED
   kpadiyar   07-MAR-2003     Bug # 2836391 - parameter 8 and 9 commented wherever checks being done
                                              reason being these 2 parameters are not being used and kept probably for backup.
   KUMMA      07-jun-2003     2853531, Inside corp_submit_fulfil_request, Changed the cursor cur_get_sub to use the lookup type also
   kumma      24-JUN-2003     2853531, Before making a CRM API call checked the return status of the earlier call
   kumma      21-AUG-2003     3104787, Modified the corp_submit_fulfil_request , Added the code to check if the query is attached with a template and accordingly pass the content type 'QUERY' or 'DATA'
                                      Modified the else condition to not to consider the Adhoc letters while binding the bind variables.
   asbala     11-SEP-2003     3071111  GSCC FILE.DATE.5 Compliance
   hreddych   13-oct-2003     Build UK Correspondence Letters
   pkpatel    11-DEC-2003     Bug 2863933 (Added the where clause 1=1 in corp_get_system_letter_view for ADRESID. Removed the variable g_parameter_value.)
   vskumar    30-May-2006     Xbuild3 performance fix. break cursor's select queries in procedure corp_check_interaction_history. e.g cur_c1 to cur_c1_part1 and cur_c1_part2.
   ***************************************************************/
  -- package variable declarations

 l_prog_label CONSTANT VARCHAR2(500) :='igs.plsql.igs_co_process';
 l_request_id  NUMBER;
 l_label VARCHAR2(32000);
 l_debug_str VARCHAR2(32000);


  PROCEDURE corp_get_letter_type(
    p_map_id            IN       NUMBER,
    p_document_id       OUT NOCOPY      NUMBER,
    p_sys_ltr_code      OUT NOCOPY      VARCHAR2,
    p_letter_type       OUT NOCOPY      VARCHAR2 ,
    p_version_id        OUT NOCOPY      NUMBER
  ) AS
  /*************************************************************
  Created By :Nalin Kumar
  Date Created on : 05-Feb-2002
  Purpose : This procedure will accept map id as a parameter and
            returns document id, system letter code and letter
      type for the map id.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR cur_c1 (cp_map_id NUMBER)IS
    SELECT document_id, sys_ltr_code, doc_code , version_id
    FROM igs_co_mapping_v
    WHERE map_id = cp_map_id;
    l_cur_c1 cur_c1%ROWTYPE;
  BEGIN
    OPEN cur_c1(p_map_id);
    FETCH cur_c1 INTO l_cur_c1;
      IF cur_c1%FOUND THEN
        p_document_id  := l_cur_c1.document_id;
        p_sys_ltr_code := l_cur_c1.sys_ltr_code;
        p_letter_type  := l_cur_c1.doc_code;
  p_version_id   := l_cur_c1.version_id;
      ELSE
        p_document_id  := NULL;
        p_sys_ltr_code := NULL;
        p_letter_type  := NULL;
  p_version_id   := NULL;
      END IF;
    CLOSE cur_c1;
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGS_CO_PROCESS.corp_get_letter_type');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END corp_get_letter_type;


  PROCEDURE corp_build_sql_stmt(
    p_document_id       IN       NUMBER,
    p_sys_ltr_code      IN       VARCHAR2,
    p_select_type       IN       VARCHAR2,
    p_list_id           IN       NUMBER,
    p_person_id         IN       NUMBER,
    p_letter_type       IN       VARCHAR2,
    p_parameter_1       IN       VARCHAR2,
    p_parameter_2       IN       VARCHAR2,
    p_parameter_3       IN       VARCHAR2,
    p_parameter_4       IN       VARCHAR2,
    p_parameter_5       IN       VARCHAR2,
    p_parameter_6       IN       VARCHAR2,
    p_parameter_7       IN       VARCHAR2,
    p_parameter_8       IN       VARCHAR2,
    p_parameter_9       IN       VARCHAR2,
    p_sql_stmt          OUT NOCOPY      VARCHAR2,
    p_exception         OUT NOCOPY      VARCHAR2
  ) AS
  /*************************************************************
  Created By :Nalin Kumar
  Date Created on : 05-Feb-2002
  Purpose : Based on the selection type this procedure will build and return a select statement.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  Bayadav         24-MAY-2002     Included two system letter codes 'ENADHOC', 'SFADHOC' for adhoc letters as a part of bug 2376434
  cheslyn         10-JUN-2002     Chnged the applictaion name from IGS to IGF for message IGF_AW_NO_LIST as  a part of bug 2410165
  pkpatel         7-MAy-2003      Bug 2940810
                                  Modified for Bind Variable
  asbala          19-AUG-2003     3098262:Added check to retrieve only active members of a group
  pkpatel         26-AUG-2003     Bug 3110793 (Removed the string WHERE while forming the dynamic clause for LIST for adhoc letters)
  ssaleem         29-OCT-2003     Bug 3198795 For select type 'P' 'G', 'SYSTEM' check is removed, since
                                  ADHoc letters were failing due to it
  ***************************************************************/
    l_view_name       VARCHAR2(30);
    l_where_clause    VARCHAR2(350);
    l_parameter_value VARCHAR2(2000);
    l_str VARCHAR2(32767);
    l_group_type VARCHAR2(10);
    l_static_group VARCHAR2(1);
    lv_status VARCHAR2(1);

     CURSOR c_att_id(cp_itm_id ibc_citems_v.citem_id%TYPE) IS
    SELECT attach_fid
    FROM ibc_citems_v
    WHERE CITEM_ID = cp_itm_id
    AND language = USERENV('LANG');
/*
     CURSOR c_group_member(cp_group_id VARCHAR2) IS
     SELECT person_id
     FROM igs_pe_prsid_grp_mem_all
     WHERE group_id = cp_group_id AND SYSDATE BETWEEN start_date AND NVL(end_date, SYSDATE);
*/
    CURSOR cur_c1 (cp_map_id NUMBER)IS
    SELECT document_id
    FROM igs_co_mapping
    WHERE map_id = cp_map_id;
    l_cur_c1 cur_c1%ROWTYPE;
    l_list_id igs_co_mapping.map_id%TYPE;
/*
    CURSOR c_file_name IS
     SELECT file_name
     FROM igs_pe_persid_group_all
     WHERE group_id = p_parameter_1;


      TYPE cur_query IS REF CURSOR;
      l_query_desc      cur_query;*/
      l_query_str       VARCHAR2(32767);
      l_person_id       NUMBER;
      l_and_con         VARCHAR2(32767);
      l_attach_fid      ibc_citems_v.attach_fid%TYPE;
      l_query_text      VARCHAR2(32767);

  BEGIN
    l_static_group := 'Y';
    IF p_select_type = 'L' THEN
      OPEN cur_c1(p_list_id);
      FETCH cur_c1 INTO l_cur_c1;
        l_list_id := l_cur_c1.document_id;
      CLOSE cur_c1;
    END IF;

   fnd_dsql.init;

    IF p_sys_ltr_code = 'ADRESID' THEN
      fnd_dsql.add_text('SELECT DISTINCT email_address, person_id FROM ');
    ELSIF p_sys_ltr_code IN ('ADADHOC','FAADHOC','GENERIC','ENADHOC','SFADHOC') THEN
      fnd_dsql.add_text('SELECT DISTINCT email_address, party_id FROM ');
    ELSIF p_sys_ltr_code = 'ADACKMT' THEN
      fnd_dsql.add_text('SELECT DISTINCT email_address, person_id, adm_appl_number,nominated_course_cd, appl_sequence_number FROM ');
    ELSIF p_sys_ltr_code = 'ADINTRW' THEN
      fnd_dsql.add_text('SELECT DISTINCT email_address, person_id, adm_appl_number,nominated_course_cd, appl_sequence_number, panel_code FROM ');
    ELSE
      fnd_dsql.add_text('SELECT DISTINCT email_address, person_id, adm_appl_number,nominated_course_cd, appl_sequence_number FROM ');
    END IF;
    corp_get_system_letter_view (p_sys_ltr_code,
                     l_view_name,
             l_where_clause);

     --**  proc level logging.
         IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;
            l_label := 'igs.plsql.igs_co_process.corp_build_sql_stmt.whereclause';
            l_debug_str :=  'View :'||l_view_name || 'Where Clause :'|| l_where_clause;
            fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
         END IF;
     --**


    IF p_select_type = 'S' THEN
      --
      -- If the System Type is of type 'Student' then
      --
      IF p_letter_type = 'SYSTEM' THEN
        IF l_where_clause IS NOT NULL THEN
    IF p_sys_ltr_code = 'ADINTRW' THEN
            fnd_dsql.add_text(l_view_name || ' WHERE person_id = ' );
            fnd_dsql.add_bind(p_person_id);
            fnd_dsql.add_text(' AND panel_code = ' );
            fnd_dsql.add_bind(p_parameter_5);
    ELSE
            fnd_dsql.add_text(l_view_name || ' WHERE person_id = ');
            fnd_dsql.add_bind(p_person_id);
    END IF;
          fnd_dsql.add_text(' AND '|| l_where_clause);
      ELSE
          fnd_dsql.add_text(l_view_name || ' WHERE person_id = ');
          fnd_dsql.add_bind(p_person_id);
      END IF;
      ELSE
          fnd_dsql.add_text(' hz_parties WHERE party_id = ');
          fnd_dsql.add_bind(p_person_id);
      END IF;

    ELSIF p_select_type = 'L' THEN
      --
      -- If the System Type is of type 'List' then get the query string.
      --

     OPEN c_att_id(l_list_id);
     FETCH c_att_id INTO l_attach_fid;


     IF c_att_id%NOTFOUND OR l_attach_fid IS NULL THEN
        FND_MESSAGE.SET_NAME('IGF','IGF_AW_NO_LIST');
      FND_MESSAGE.SET_TOKEN('LIST', l_list_id);
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
        p_exception := 'Y';
          CLOSE c_att_id;
      RETURN;
     END IF;

     CLOSE c_att_id;
     IGS_CO_GEN_004.get_list_query(l_attach_fid,l_query_text);

     --**  proc level logging.
         IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;
            l_label := 'igs.plsql.igs_co_process.corp_build_sql_stmt.listquery';
            l_debug_str :=  'List Query Text :'||l_query_text;
            fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
         END IF;
     --**

     IF l_query_text IS NULL THEN
        p_exception := 'Y';
        fnd_message.set_name('IGF','IGF_AW_NO_LIST');
        fnd_message.set_token('LIST',p_list_id);
        fnd_file.put_line(fnd_file.log,fnd_message.get());
        fnd_file.put_line(FND_FILE.LOG,' ');
        RETURN;
     ELSE
        l_query_str := 'SELECT distinct person_id FROM '|| '(' || l_query_text || ')';

        IF l_where_clause IS NOT NULL THEN
           IF p_sys_ltr_code = 'ADINTRW' THEN
              fnd_dsql.add_text(l_view_name || ' WHERE '|| l_where_clause );
              fnd_dsql.add_text(' AND panel_code = ' );
              fnd_dsql.add_bind(p_parameter_5);
            ELSE
              fnd_dsql.add_text(l_view_name || ' WHERE '|| l_where_clause );
        END IF;

            --IF l_and_con IS NOT NULL THEN
        IF l_query_str IS NOT NULL THEN
         IF p_sys_ltr_code = 'ADINTRW' THEN
                fnd_dsql.add_text(' AND person_id IN ('||l_query_str||' )');
                fnd_dsql.add_text(' AND panel_code = ' );
                fnd_dsql.add_bind(p_parameter_5);
               ELSE
                fnd_dsql.add_text('AND person_id IN ('||l_query_str||' )');
         END IF;
            END IF;
        ELSE

       fnd_dsql.add_text(l_view_name );

            IF l_query_str IS NOT NULL THEN
                        IF p_sys_ltr_code IN ('ADADHOC','FAADHOC','GENERIC','ENADHOC','SFADHOC') THEN
                             fnd_dsql.add_text(' WHERE party_id IN(' || l_query_str ||' )');
                        ELSE
                 IF p_sys_ltr_code = 'ADINTRW' THEN
                             fnd_dsql.add_text(' WHERE person_id IN(' || l_query_str ||' )');
                             fnd_dsql.add_text(' AND panel_code = ' );
                             fnd_dsql.add_bind(p_parameter_5);
                           ELSE
                             fnd_dsql.add_text(' WHERE person_id IN(' || l_query_str ||' )');
                 END IF;
                        END IF;
                 END IF;
      END IF;
     END IF;

    ELSIF p_select_type IN ('P','G') THEN
      --
      -- If the System Type is of type 'Parameter' then get the parameter values.
      --
      IF p_parameter_1 IS NOT NULL THEN

      -- check whether the group is dynamic or not.
      -- if file_name is NOT NULL means, the group is dynamic.
      l_str := igs_pe_dynamic_persid_group.get_dynamic_sql(p_parameter_1 ,lv_status, l_group_type);
      IF lv_status <> 'S' THEN
        FND_MESSAGE.SET_NAME('IGF','IGF_AW_NO_QUERY');
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
        p_exception := 'Y';
        RETURN;
      END IF;

      IF l_group_type = 'STATIC' THEN
        l_str := SUBSTR(l_str,1,INSTR(l_str,':p_GroupID')-1);
      END IF;

     END IF;

      -- the l_str will hold the the select statement. If static bind parameter would be there.

      IF l_where_clause IS NOT NULL THEN
        IF p_sys_ltr_code = 'ADINTRW' THEN
             IF l_str IS NOT NULL THEN
                     fnd_dsql.add_text(l_view_name || ' WHERE person_id IN ('||l_str);
		     IF l_group_type = 'STATIC' THEN
  		       fnd_dsql.add_bind(p_parameter_1);
		     END IF;
                     fnd_dsql.add_text(') AND '||l_where_clause||' AND panel_code = ' );
                     fnd_dsql.add_bind(p_parameter_5);
             ELSE
                     fnd_dsql.add_text(l_view_name || ' WHERE '||l_where_clause);
                     fnd_dsql.add_text(' AND panel_code = ' );
                     fnd_dsql.add_bind(p_parameter_5);
             END IF;
        ELSE
             IF l_str IS NOT NULL THEN
                     fnd_dsql.add_text(l_view_name || ' WHERE person_id IN ('||l_str);
		     IF l_group_type = 'STATIC' THEN
  		       fnd_dsql.add_bind(p_parameter_1);
		     END IF;
                     fnd_dsql.add_text(') AND '||l_where_clause);
               ELSE
                     fnd_dsql.add_text(l_view_name || ' WHERE '||l_where_clause);
             END IF;
        END IF;
      ELSE

      -- adhoc letters will not have where clause

           IF p_sys_ltr_code = 'ADINTRW' THEN
             IF l_str IS NOT NULL THEN
                     fnd_dsql.add_text(l_view_name|| ' WHERE person_id IN ('||l_str);
		     IF l_group_type = 'STATIC' THEN
  		       fnd_dsql.add_bind(p_parameter_1);
		     END IF;
                     fnd_dsql.add_text(') AND panel_code = ' );
                     fnd_dsql.add_bind(p_parameter_5);
             ELSE
                     fnd_dsql.add_text(l_view_name|| ' WHERE ');
                     fnd_dsql.add_text(' panel_code = ' );
                     fnd_dsql.add_bind(p_parameter_5);
             END IF;
           ELSE
             IF l_str IS NOT NULL THEN
                 IF p_sys_ltr_code IN ('ADADHOC','FAADHOC','GENERIC','ENADHOC','SFADHOC') THEN
                    fnd_dsql.add_text(l_view_name|| ' WHERE party_id IN ('||l_str);
		    IF l_group_type = 'STATIC' THEN
  		       fnd_dsql.add_bind(p_parameter_1);
		    END IF;
                    fnd_dsql.add_text(')');
                 ELSE
                    fnd_dsql.add_text(l_view_name|| ' WHERE person_id IN ('||l_str);
		    IF l_group_type = 'STATIC' THEN
  		       fnd_dsql.add_bind(p_parameter_1);
		    END IF;
                    fnd_dsql.add_text(')');
                 END IF;
             ELSE
                 fnd_dsql.add_text(l_view_name);
             END IF;
           END IF;
      END IF;

      IF p_letter_type = 'SYSTEM' THEN
         corp_get_parameter_value(
              p_sys_ltr_code    => p_sys_ltr_code,
              p_parameter_1     => p_parameter_1,
            p_parameter_2     => p_parameter_2,
            p_parameter_3     => p_parameter_3,
            p_parameter_4     => p_parameter_4,
            p_parameter_5     => p_parameter_5,
            p_parameter_6     => p_parameter_6,
            p_parameter_7     => p_parameter_7,
            p_parameter_8     => p_parameter_8,
            p_parameter_9     => p_parameter_9,
            p_parameter_value => l_parameter_value);
        END IF;

    END IF;

    p_sql_stmt := fnd_dsql.get_text(FALSE);

    --** proc level logging.
        IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

            l_label := 'igs.plsql.igs_co_process.corp_build_sql_stmt';
            l_debug_str := 'p_sql_stmt: '||p_sql_stmt;

            fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
        END IF;
        --**
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGS_CO_PROCESS.corp_build_sql_stmt'||'-'||SQLERRM);
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END corp_build_sql_stmt;

  PROCEDURE corp_check_document_attributes(
    p_map_id            IN       NUMBER,
    p_elapsed_days      OUT NOCOPY      NUMBER,
    p_no_of_repeats     OUT NOCOPY      NUMBER
  ) AS
  /*************************************************************
  Created By :Nalin Kumar
  Date Created on : 05-Feb-2002
  Purpose : This procedure will check and return attributes assigned to a document.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR cur_c1 (cp_map_id  NUMBER)IS
    SELECT elapsed_days, repeat_times
    FROM igs_co_mapping
    WHERE map_id  = TO_NUMBER(cp_map_id);
    l_cur_c1 cur_c1%ROWTYPE;
  BEGIN
    OPEN cur_c1(p_map_id);
    FETCH cur_c1 INTO l_cur_c1;
      IF cur_c1%FOUND THEN
        p_elapsed_days  := l_cur_c1.elapsed_days;
        p_no_of_repeats := l_cur_c1.repeat_times;
      ELSE
        p_elapsed_days  := NULL;
        p_no_of_repeats := NULL;
      END IF;
    CLOSE cur_c1;
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGS_CO_PROCESS.corp_check_document_attributes');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END corp_check_document_attributes;

  PROCEDURE corp_check_interaction_history(
    p_person_id         IN       NUMBER,
    p_sys_ltr_code      IN       VARCHAR2,
    p_document_id       IN       NUMBER,
    p_application_id    IN       NUMBER ,
    p_course_cd         IN       VARCHAR2,
    p_adm_seq_no        IN       NUMBER ,
    p_awd_cal_type      IN       VARCHAR2,
    p_awd_seq_no        IN       NUMBER ,
    p_elapsed_days      IN       NUMBER,
    p_no_of_repeats     IN       NUMBER,
    p_send_letter       OUT NOCOPY      VARCHAR2
  ) AS
  /*************************************************************
  Created By :Nalin Kumar
  Date Created on : 05-Feb-2002
  Purpose : This procedure will check interaction history and return a value to
            inform whether a document can be sent or not.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
      Pacross         12-Sep-2005     Included references into the IGS_CO_COV_LTR_RELS table, to ensure all
				      letters that were created as an edit of the current one are included in the
				      count
      Bayadav         24-MAY-2002     Included two system letter codes 'ENADHOC', 'SFADHOC' for adhoc letters as
				      a part of bug 2376434
      vskumar	      30-May-2006     Xbuild3 performance fixes. Changed curosr queries for cur_c1, cur_adhoc1,
				      cur_adackmt1.
  ***************************************************************/
   CURSOR cur_c1_part1 (cp_document_id    NUMBER,
                   cp_person_id      NUMBER,
       cp_application_id NUMBER,
       cp_course_cd      VARCHAR2,
       cp_adm_seq_no     NUMBER)IS
  SELECT count(*) cnt, max(requested_date) max_requested_date
        FROM igs_co_interaction_history_v
        WHERE document_id = cp_document_id
        and student_id = cp_person_id
        and adm_application_number = cp_application_id
        and nominated_course_cd = cp_course_cd
        and sequence_number = cp_adm_seq_no
        and ( comp_status = 'SUCCESS' OR
              request_id IN (SELECT request_id FROM jtf_fm_status));

 l_cur_c1_part1 cur_c1_part1%ROWTYPE;

    CURSOR cur_c1_part2 (cp_document_id    NUMBER,
                   cp_person_id      NUMBER,
	   cp_application_id NUMBER,
	   cp_course_cd      VARCHAR2,
           cp_adm_seq_no     NUMBER)IS
    SELECT count(1) cnt, max(requested_date) max_requested_date
           FROM igs_co_interaction_history_v
	   WHERE document_id in (SELECT CHILD_ITEM_ID
			        FROM IGS_CO_COV_LTR_RELS
				WHERE BASE_ITEM_ID = cp_document_id)
	      and student_id = cp_person_id
	      and adm_application_number = cp_application_id
	      and nominated_course_cd = cp_course_cd
	      and sequence_number = cp_adm_seq_no
	      and ( comp_status = 'SUCCESS' OR
		    request_id IN (SELECT request_id FROM jtf_fm_status));

   l_cur_c1_part2 cur_c1_part2%ROWTYPE;

    CURSOR cur_adhoc1_part1 (cp_document_id    NUMBER,
                       cp_person_id      NUMBER)IS
    SELECT count(1) cnt, max(requested_date) max_requested_date
        FROM igs_co_interaction_history_v
        WHERE document_id = cp_document_id
        and student_id = cp_person_id
        and ( comp_status = 'SUCCESS' OR
              request_id IN (SELECT request_id FROM jtf_fm_status));


    CURSOR cur_adhoc1_part2 (cp_document_id    NUMBER,
                       cp_person_id      NUMBER)IS
    SELECT count(1) cnt, max(requested_date) max_requested_date
        FROM igs_co_interaction_history_v
        WHERE document_id in (SELECT CHILD_ITEM_ID
                              FROM IGS_CO_COV_LTR_RELS
                              WHERE BASE_ITEM_ID = cp_document_id)
        and student_id = cp_person_id
        and ( comp_status = 'SUCCESS' OR
              request_id IN (SELECT request_id FROM jtf_fm_status));

    l_cur_adhoc1_part1 cur_adhoc1_part1%ROWTYPE;
    l_cur_adhoc1_part2 cur_adhoc1_part2%ROWTYPE;

   CURSOR cur_adackmt1_part1 (cp_document_id    NUMBER,
                         cp_person_id      NUMBER,
                     cp_application_id NUMBER)IS
    SELECT count(1) cnt, max(requested_date) max_requested_date
      FROM igs_co_interaction_history_v
      WHERE document_id = cp_document_id
      and student_id = cp_person_id
      and adm_application_number = cp_application_id
      and ( comp_status = 'SUCCESS' OR
            request_id IN (SELECT request_id FROM jtf_fm_status));

   CURSOR cur_adackmt1_part2 (cp_document_id    NUMBER,
                         cp_person_id      NUMBER,
                     cp_application_id NUMBER)IS
   SELECT count(1) cnt, max(requested_date) max_requested_date
      FROM igs_co_interaction_history_v
      WHERE document_id in (SELECT CHILD_ITEM_ID
                            FROM IGS_CO_COV_LTR_RELS
                            WHERE BASE_ITEM_ID = cp_document_id)
      and student_id = cp_person_id
      and adm_application_number = cp_application_id
      and ( comp_status = 'SUCCESS' OR
           request_id IN (SELECT request_id FROM jtf_fm_status));


    l_cur_adackmt1_part1 cur_adackmt1_part1%ROWTYPE;
    l_cur_adackmt1_part2 cur_adackmt1_part2%ROWTYPE;

--**
    CURSOR cur_get_per_num(cp_person_id NUMBER) IS
    SELECT person_number
    FROM igs_pe_person_base_v
    WHERE person_id = TO_NUMBER(cp_person_id);
    l_cur_get_per_num cur_get_per_num%ROWTYPE;

    l_count NUMBER(16);
    l_requested_date DATE;
    l_retcode NUMBER(1);
    l_errbuf VARCHAR2(1000);
  BEGIN

    corp_check_request_status(
        errbuf            => l_errbuf,
        retcode           => l_retcode,
  p_person_id       => p_person_id ,
        p_document_id     => p_document_id    ,
        p_application_id  => p_application_id ,
        p_course_cd       => p_course_cd      ,
        p_adm_seq_no      => p_adm_seq_no     ,
        p_awd_cal_type    => p_awd_cal_type   ,
        p_awd_seq_no      => p_awd_seq_no     ,
        p_elapsed_days    => p_elapsed_days   ,
        p_no_of_repeats   => p_no_of_repeats  ,
      p_sys_ltr_code    => p_sys_ltr_code);

    IF  p_sys_ltr_code NOT IN ('FAAWARD','FAMISTM','FADISBT','ADRESID','ADADHOC','FAADHOC','GENERIC','ADACKMT','ENADHOC','SFADHOC')  THEN
      OPEN cur_c1_part1(p_document_id,
                  p_person_id,
                  p_application_id,
                  p_course_cd,
                  p_adm_seq_no);
      FETCH cur_c1_part1 INTO l_cur_c1_part1;
      CLOSE cur_c1_part1;

     OPEN cur_c1_part2(p_document_id,
	          p_person_id,
                  p_application_id,
                  p_course_cd,
                  p_adm_seq_no);
      FETCH cur_c1_part2 INTO l_cur_c1_part2;
      CLOSE cur_c1_part2;

      l_count := l_cur_c1_part1.cnt + l_cur_c1_part2.cnt;


      IF l_cur_c1_part1.max_requested_date > l_cur_c1_part2.max_requested_date THEN
             l_requested_date := l_cur_c1_part1.max_requested_date;
      ELSE
	     l_requested_date := l_cur_c1_part2.max_requested_date;
      END IF;

    ELSIF p_sys_ltr_code IN ('ADADHOC','FAADHOC','GENERIC','ADRESID','ENADHOC','SFADHOC') THEN

     OPEN cur_adhoc1_part1(p_document_id,
                      p_person_id);
      FETCH cur_adhoc1_part1 INTO l_cur_adhoc1_part1;
      CLOSE cur_adhoc1_part1;

      OPEN cur_adhoc1_part2(p_document_id,
                      p_person_id);
      FETCH cur_adhoc1_part2 INTO l_cur_adhoc1_part2;
      CLOSE cur_adhoc1_part2;

      l_count := l_cur_adhoc1_part1.cnt + l_cur_adhoc1_part2.cnt;

      IF l_cur_adhoc1_part1.max_requested_date > l_cur_adhoc1_part2.max_requested_date THEN
        l_requested_date := l_cur_adhoc1_part1.max_requested_date;
      ELSE
        l_requested_date := l_cur_adhoc1_part2.max_requested_date;
      END IF;

    ELSIF p_sys_ltr_code = 'ADACKMT' THEN
      OPEN cur_adackmt1_part1(p_document_id,
                        p_person_id,
                        p_application_id);
      FETCH cur_adackmt1_part1 INTO l_cur_adackmt1_part1;
      CLOSE cur_adackmt1_part1;

      OPEN cur_adackmt1_part2(p_document_id,
                        p_person_id,
                        p_application_id);
      FETCH cur_adackmt1_part2 INTO l_cur_adackmt1_part2;
      CLOSE cur_adackmt1_part2;

      l_count := l_cur_adackmt1_part1.cnt + l_cur_adackmt1_part2.cnt;

      IF l_cur_adackmt1_part1.max_requested_date > l_cur_adackmt1_part2.max_requested_date THEN
        l_requested_date := l_cur_adackmt1_part1.max_requested_date;
      ELSE
        l_requested_date := l_cur_adackmt1_part2.max_requested_date;
      END IF;

    END IF;
    p_send_letter := 'FALSE';
    IF p_elapsed_days IS NULL AND p_no_of_repeats IS NULL THEN
      p_send_letter := 'TRUE';
      RETURN;
    END IF;
    --GSCC FILE.DATE.5 Compliance  3071111 asbala
    IF (TRUNC(SYSDATE) - TRUNC(l_requested_date)) < NVL(p_elapsed_days,0) THEN
      p_send_letter := 'FALSE';
      OPEN cur_get_per_num(p_person_id);
      FETCH cur_get_per_num into l_cur_get_per_num;
        fnd_message.set_name('IGS','IGS_CO_ELAPSED_DAYS');
        fnd_message.set_token('PERSON',l_cur_get_per_num.person_number);
        fnd_file.put_line(fnd_file.log,fnd_message.get());
        fnd_file.put_line(FND_FILE.LOG,' ');
      CLOSE cur_get_per_num;
    ELSIF NVL(p_no_of_repeats,10000) <= l_count THEN
      p_send_letter := 'FALSE';
      OPEN cur_get_per_num(p_person_id);
      FETCH cur_get_per_num into l_cur_get_per_num;
        fnd_message.set_name('IGS','IGS_CO_NO_REPEATS');
        fnd_message.set_token('PERSON',l_cur_get_per_num.person_number);
        fnd_file.put_line(fnd_file.log,fnd_message.get());
        fnd_file.put_line(FND_FILE.LOG,' ');
      CLOSE cur_get_per_num;
    ELSE
      p_send_letter := 'TRUE';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGS_CO_PROCESS.corp_check_interaction_history');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END corp_check_interaction_history;

  PROCEDURE corp_submit_fulfil_request(
    p_letter_type       IN       VARCHAR2,
    p_person_id         IN       NUMBER,
    p_email_address     IN       VARCHAR2,
    p_content_id        IN       NUMBER,
    p_award_year        IN       VARCHAR2,  --New
    p_sys_ltr_code      IN       VARCHAR2,  --New
    p_adm_appl_number   IN       NUMBER,    --New
    p_nominated_course_cd IN     VARCHAR2,  --New
    p_appl_sequence_number IN    NUMBER,    --New
    p_fulfillment_req   IN       VARCHAR2,
    p_crm_user_id       IN       NUMBER,
    p_media_type        IN       VARCHAR2,
    p_destination       IN       VARCHAR2,
    p_fax_number        IN       VARCHAR2, --New
    p_reply_days        IN       VARCHAR2,
    p_panel_code        IN       VARCHAR2,
    p_request_id        OUT NOCOPY      NUMBER,
    p_request_status    OUT NOCOPY      VARCHAR2,
    p_reply_email       IN  VARCHAR2  ,
    p_sender_email      IN  VARCHAR2  ,
    p_cc_email          IN  VARCHAR2 ,
    p_org_unit_id       IN  NUMBER,
    p_preview           IN  VARCHAR2,
    p_awd_cal_type      IN  VARCHAR2,
    p_awd_ci_seq_number IN  NUMBER,
    p_awd_prd_cd        IN  VARCHAR2,
    p_preview_version_id  IN       NUMBER,
    p_preview_version     IN       NUMBER
  ) AS
  /*************************************************************
  Created By :Nalin Kumar
  Date Created on : 05-Feb-2002
  Purpose : This procedure will accept parameters and submit fulfilment requests.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
   pradhakr        13-Aug-2002    Added the parameter p_destination, which takes the
          destination name (i.e) printer name if the media type
          selected is printer. Changes as part of bug# 2472250
   kpadiyar        19-NOV-2002   Added check if hold exists - Correspondence Enhancement - SWS102
                                 Added check for relation between document and query and pass
         the content type as relevant.
   kumma           07-JUN-2003   2853531, Changed the cursor cur_get_sub to use the lookup type also
                                 Replace the three CRM API calls jtf_fm_request_grp.start_request, jtf_fm_request_grp.get_content_xml and
         jtf_fm_request_grp.submit_request into a single API Call of IGS_CO_API.SEND_REQUEST, which inturn calls
         the create_fulfillment CRM API.
   kumma           21-AUG-2003   3104787, Added the code to check if the query is attached with a template and accordingly pass the content type 'QUERY' or 'DATA'
                                 Modified the else condition to not to consider the Adhoc letters while binding the bind variables.
   ssaleem         09-SEP-2004   3630073. Added p_org_unit_id as a new parameter
   pacross         11-APR-2005   Implemented code for Correspondance preview and edit fucntionality
  ***************************************************************/
    CURSOR cur_c1 (cp_content_id igs_co_mapping.document_id%TYPE,
             cp_map_code igs_co_mapping.map_code%TYPE,
       cp_sys_ltr_code igs_co_mapping.sys_ltr_code%TYPE) IS
    SELECT map_description, version_id, citem_ver_id
    FROM igs_co_mapping_v
    WHERE document_id = cp_content_id
    AND map_code = cp_map_code
    AND sys_ltr_code = cp_sys_ltr_code
    AND enable_flag ='Y';

    l_cur_c1 cur_c1%ROWTYPE;

    l_doc_desc igs_co_mapping_v.name%TYPE;
    l_msg_count   NUMBER;
    l_msg_data    VARCHAR2(2000);
    l_content_xml VARCHAR2(5000);
    l_varchar_tbl_bind_var jtf_fm_request_grp.g_varchar_tbl_type;
    l_varchar_tbl_bind_var_type jtf_fm_request_grp.g_varchar_tbl_type;
    l_varchar_tbl_bind_val jtf_fm_request_grp.g_varchar_tbl_type;
    l_return_status  VARCHAR2(30);
    l_awd_cal_type   igs_co_itm.cal_type%TYPE;
    l_awd_seq_number igs_co_itm.ci_sequence_number%TYPE;
    l_reply_date DATE;

    CURSOR cur_get_sub(cp_sys_ltr_code VARCHAR2) IS
    SELECT description
    FROM igs_lookups_view
    WHERE lookup_code = cp_sys_ltr_code AND
          Lookup_type = 'IGS_CO_SYS_LTR_CODE';

    l_cur_get_sub cur_get_sub%ROWTYPE;

    CURSOR check_hold_exists IS
    SELECT COUNT ('x')
    FROM  igs_pe_pers_encumb ppe, igs_pe_persenc_effct ppef
    WHERE ppe.person_id = p_person_id
    AND   ppe.person_id = ppef.person_id
    AND   ppe.encumbrance_type = ppef.encumbrance_type
    AND   ppe.start_dt = ppef.pen_start_dt
    AND   ppef.s_encmb_effect_type = 'S_COR_BLK'
    AND   trunc(ppef.pee_start_dt) <= trunc(sysdate)
    AND   (ppef.expiry_dt IS NULL OR trunc(ppef.expiry_dt) > trunc(sysdate))
    AND   trunc(ppe.start_dt) <= trunc(sysdate)
    AND   (ppe.expiry_dt IS NULL OR trunc(ppe.expiry_dt) > trunc(sysdate));


    l_hold_count NUMBER;

    CURSOR log_details IS
    SELECT ppbv.full_name,ppbv.person_number,fet.description
    FROM  igs_pe_pers_encumb ppe, igs_pe_persenc_effct ppef,igs_pe_person_base_v ppbv,igs_fi_encmb_type fet
    WHERE ppe.person_id = p_person_id
    AND   ppe.person_id = ppef.person_id
    AND   ppe.person_id = ppbv.person_id
    AND   ppe.encumbrance_type = ppef.encumbrance_type
    AND   ppe.encumbrance_type = fet.encumbrance_type
    AND   ppe.start_dt = ppef.pen_start_dt
    AND   ppef.s_encmb_effect_type = 'S_COR_BLK'
    AND   trunc(ppef.pee_start_dt) <= trunc(sysdate)
    AND   (ppef.expiry_dt IS NULL OR trunc(ppef.expiry_dt) > trunc(sysdate))
    AND   trunc(ppe.start_dt) <= trunc(sysdate)
    AND   (ppe.expiry_dt IS NULL OR trunc(ppe.expiry_dt) > trunc(sysdate));

    l_full_name         igs_pe_person_base_v.full_name%TYPE;
    l_person_number     igs_pe_person_base_v.person_number%TYPE;
    l_encumbrance_desc  igs_fi_encmb_type.description%TYPE;

    l_query_id     jtf_fm_query_mes.query_id%TYPE;
    l_content_type VARCHAR2(10);
    l_tmp_var                 VARCHAR2(4000);
    l_tmp_var1                 VARCHAR2(4000);
    l_version_id   NUMBER;
    -- Empty Arrays to reset the value
    le_varchar_tbl_bind_var jtf_fm_request_grp.g_varchar_tbl_type;
    le_varchar_tbl_bind_var_type jtf_fm_request_grp.g_varchar_tbl_type;
    le_varchar_tbl_bind_val jtf_fm_request_grp.g_varchar_tbl_type;
    l_query_exists VARCHAR2(1);
    l_citem_ver_id NUMBER;
    l_extended_header VARCHAR2(32000);
    l_id  VARCHAR2(500);

    l_reply_days VARCHAR2(10);

    -- Cursor to log the person's processed
    CURSOR c_per_processed (p_person_id NUMBER) IS
        SELECT person_number,full_name
  FROM   igs_pe_person_base_v
  WHERe  person_id = p_person_id;

     --Cursor to get the citem_version_id
     CURSOR c_check_relation (cp_item_id ibc_citem_versions_b.content_item_id%TYPE,
                              cp_version_id ibc_citem_versions_b.version_number%TYPE)  IS
          SELECT 'Y'
    FROM ibc_compound_relations
    WHERE CITEM_VERSION_ID = (SELECT CITEM_VERSION_ID FROM ibc_citem_versions_b
                              WHERE CONTENT_ITEM_ID = cp_item_id AND
                  VERSION_NUMBER  = cp_version_id)
    AND ATTRIBUTE_TYPE_CODE = 'QUERY';  -- ssawhney modified after OCM migration.

     --Cursor to get the reply date
     CURSOR c_reply_date(p_reply_days NUMBER)  IS
        SELECT SYSDATE + NVL(TO_NUMBER(p_reply_days),0)
  FROM   DUAL;

     --Cursor to get the reply date
      CURSOR c_intr_reply_date (
               p_person_id igs_ad_panel_dtls.person_id%TYPE,
         p_adm_appl_number igs_ad_panel_dtls.admission_appl_number%TYPE,
               p_nominated_course_cd igs_ad_panel_dtls.nominated_course_cd%TYPE,
         p_appl_sequence_number igs_ad_panel_dtls.sequence_number%TYPE,
         p_panel_code igs_ad_panel_dtls.panel_code%TYPE)IS
        SELECT NVL(MAX(ipl.INTERVIEW_DATE),MAX(ipm.INTERVIEW_DATE)) - NVL(TO_NUMBER(p_reply_days),0)
  FROM   igs_ad_panel_dtls ipl ,
         igs_ad_pnmembr_dtls ipm
  WHERE  ipl.panel_dtls_id = ipm.panel_dtls_id AND
         ipl.person_id = p_person_id AND
         ipl.admission_appl_number =p_adm_appl_number AND
         ipl.nominated_course_cd = p_nominated_course_cd AND
         ipl.sequence_number = p_appl_sequence_number AND
         ipl.panel_code = p_panel_code ;

      -- Cursor to get address info of an Orgn Unit
      CURSOR  c_org_unit_addr(cp_party_id hz_parties.party_id%TYPE) IS
        SELECT P.ADDRESS1, P.ADDRESS2, P.ADDRESS3, P.ADDRESS4, P.POSTAL_CODE,
               P.PARTY_NAME, TERR.TERRITORY_SHORT_NAME COUNTRY, P.CITY,
               P.STATE, P.PROVINCE, P.COUNTY
        FROM
               HZ_PARTIES P, FND_TERRITORIES_VL TERR
        WHERE
               P.PARTY_ID = cp_party_id AND
               TERR.TERRITORY_CODE = P.COUNTRY ;

      l_org_unit_addr c_org_unit_addr%ROWTYPE;

      -- Cursor to obtain the primary email address of the primary address of an Orgn Unit
      CURSOR c_org_unit_email(cp_id_flag hz_party_sites.IDENTIFYING_ADDRESS_FLAG%TYPE,
                              cp_owner_tbl  hz_contact_points.OWNER_TABLE_NAME%TYPE,
            cp_cnt_type  hz_contact_points.CONTACT_POINT_TYPE%TYPE,
            cp_prim_flag hz_contact_points.PRIMARY_FLAG%TYPE,
            cp_party_id HZ_PARTY_SITES.PARTY_ID%TYPE) IS
        SELECT
           CPE.EMAIL_ADDRESS
  FROM
    HZ_PARTY_SITES PS,
    HZ_CONTACT_POINTS CPE
  WHERE
    PS.PARTY_ID = cp_party_id AND
    PS.IDENTIFYING_ADDRESS_FLAG = cp_id_flag AND
    CPE.OWNER_TABLE_NAME = cp_owner_tbl AND
    CPE.CONTACT_POINT_TYPE  = cp_cnt_type AND
    CPE.OWNER_TABLE_ID = PS.PARTY_SITE_ID AND
    CPE.PRIMARY_FLAG  = cp_prim_flag;

     l_org_unit_email c_org_unit_email%ROWTYPE;

     -- Cursor to obtain the Phone/Fax of an Organization Unit
     CURSOR c_org_unit_phone (cp_id_flag hz_party_sites.IDENTIFYING_ADDRESS_FLAG%TYPE,
                              cp_owner_tbl  hz_contact_points.OWNER_TABLE_NAME%TYPE,
            cp_cnt_type  hz_contact_points.CONTACT_POINT_TYPE%TYPE,
            cp_status hz_contact_points.STATUS%TYPE,
            cp_party_id hz_party_sites.PARTY_ID%TYPE,
            cp_line_type1 hz_contact_points.PHONE_LINE_TYPE%TYPE,
            cp_line_type2 hz_contact_points.PHONE_LINE_TYPE%TYPE) IS
         SELECT
          NVL (CPP.PHONE_AREA_CODE,'*') PHONE_AREA_CODE,
    NVL (CPP.PHONE_COUNTRY_CODE,'*') PHONE_COUNTRY_CODE,
    NVL (CPP.PHONE_NUMBER,'*') PHONE_NUMBER,
    NVL (CPP.PHONE_EXTENSION,'*') PHONE_EXTENSION,
    CPP.PHONE_LINE_TYPE
  FROM
          HZ_PARTY_SITES PS,
    HZ_CONTACT_POINTS CPP
  WHERE
    PS.PARTY_ID = cp_party_id AND
    PS.IDENTIFYING_ADDRESS_FLAG = cp_id_flag AND
    CPP.OWNER_TABLE_NAME  = cp_owner_tbl AND
    CPP.CONTACT_POINT_TYPE = cp_cnt_type AND
    CPP.PHONE_LINE_TYPE IN(cp_line_type1,cp_line_type2) AND
    CPP.OWNER_TABLE_ID = PS.PARTY_SITE_ID AND
    CPP.STATUS = cp_status
  ORDER BY
          CPP.PRIMARY_FLAG DESC  ;

     l_org_unit_phone c_org_unit_phone%ROWTYPE;
     l_fax_count NUMBER;
     l_phone_count NUMBER;

     l_fax_val VARCHAR2(300);
     l_phone_val VARCHAR2(300);

  BEGIN
    l_query_exists := 'N';
    l_fax_count :=0;
    l_phone_count := 0;
    l_fax_val := NULL;
    l_phone_val := NULL;

         --MMKUMAR, bug 4681183
	 IF p_sys_ltr_code IN ('ADNORSP','ADINTRW') THEN
	       l_reply_days := p_reply_days;
	 ELSE
	       l_reply_days := null;
	 END IF;

     --**  proc level logging.
         IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;
            l_label := 'igs.plsql.igs_co_process.corp_submit_fulfil_request.JUST_ENTERED_INSIDE_corp_submit_fulfil_request';
            l_debug_str :=  'values';
            l_debug_str := l_debug_str || 'p_letter_type=' ||   p_letter_type;
            l_debug_str := l_debug_str || ',p_person_id=' ||  p_person_id     ;
            l_debug_str := l_debug_str || ',p_email_address=' ||  p_email_address  ;
            l_debug_str := l_debug_str || ',p_content_id=' ||  p_content_id        ;
            l_debug_str := l_debug_str || ',p_award_year=' ||  p_award_year        ;
            l_debug_str := l_debug_str || ',p_sys_ltr_code=' ||  p_sys_ltr_code     ;
            l_debug_str := l_debug_str || ',p_adm_appl_number=' ||  p_adm_appl_number;
            l_debug_str := l_debug_str || ',p_nominated_course_cd=' ||  p_nominated_course_cd ;
            l_debug_str := l_debug_str || ',p_appl_sequence_number=' ||  p_appl_sequence_number;
            l_debug_str := l_debug_str || ',p_fulfillment_req=' ||  p_fulfillment_req   ;
            l_debug_str := l_debug_str || ',p_crm_user_id=' ||  p_crm_user_id      ;
            l_debug_str := l_debug_str || ',p_media_type=' ||  p_media_type        ;
            l_debug_str := l_debug_str || ',p_destination=' ||  p_destination      ;
            l_debug_str := l_debug_str || ',p_fax_number=' ||  p_fax_number        ;
            l_debug_str := l_debug_str || ',p_reply_days=' ||  p_reply_days        ;
	    l_debug_str := l_debug_str || ',l_reply_days=' ||  l_reply_days        ;
            l_debug_str := l_debug_str || ',p_panel_code=' ||  p_panel_code        ;
            l_debug_str := l_debug_str || ',p_reply_email=' ||  p_reply_email   ;
            l_debug_str := l_debug_str || ',p_sender_email=' ||  p_sender_email ;
            l_debug_str := l_debug_str || ',p_cc_email=' ||  p_cc_email         ;
            l_debug_str := l_debug_str || ',p_org_unit_id=' ||  p_org_unit_id   ;
            l_debug_str := l_debug_str || ',p_preview=' ||  p_preview           ;
            l_debug_str := l_debug_str || ',p_awd_cal_type=' ||  p_awd_cal_type  ;
            l_debug_str := l_debug_str || ',p_awd_ci_seq_number=' ||  p_awd_ci_seq_number ;
            l_debug_str := l_debug_str || ',p_awd_prd_cd=' ||  p_awd_prd_cd  ;

            fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
         END IF;
     --**

    l_doc_desc := NULL;
    OPEN cur_c1(p_content_id,'DOCUMENT',p_sys_ltr_code);
    FETCH cur_c1 INTO l_cur_c1;
      l_doc_desc := l_cur_c1.map_description;
      l_version_id := l_cur_c1.version_id;   --ssawhney IBC.C version concept changes
      l_citem_ver_id := l_cur_c1.citem_ver_id; --ssawhney IBC.C version concept changes
    CLOSE cur_c1;

    -- If there was no mapping since this is an updated document, then use the passed in version id's.
    -- PACROSS - 11-SEP-2005
    IF p_preview = 'Y' AND l_version_id IS NULL AND l_citem_ver_id IS NULL
      AND p_preview_version IS NOT NULL AND p_preview_version_id IS NOT NULL THEN
      l_version_id := p_preview_version;
      l_citem_ver_id := p_preview_version_id;
    END IF;

    --**  proc level logging.
         IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;
            l_label := 'igs.plsql.igs_co_process.corp_submit_fulfil_request.gotthevalues';
            l_debug_str :=  'hurrreeeeeeee got the values';
            fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
         END IF;
     --**

    IF l_doc_desc IS NULL THEN
      OPEN cur_get_sub(p_sys_ltr_code);
      FETCH cur_get_sub INTO l_cur_get_sub;
        l_doc_desc := l_cur_get_sub.description;
      CLOSE cur_get_sub;
    END IF;
  IF p_letter_type = 'SYSTEM' THEN
   OPEN check_hold_exists;
    FETCH check_hold_exists INTO l_hold_count;
   CLOSE check_hold_exists;
  END IF;

   IF NVL(l_hold_count,0) = 0 THEN
    --
    --  To start the submit fulfilment request by invoking CRM API
    --


    jtf_fm_request_grp.start_request (
      p_api_version     => 1,
      p_init_msg_list   => 'T',
      x_return_status   => l_return_status,
      x_msg_count       => l_msg_count,
      x_msg_data        => l_msg_data,
      x_request_id      => p_request_id);

    --
    --  To populate the bind parameters.
    --

     --**  proc level logging.
         IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;
            l_label := 'igs.plsql.igs_co_process.corp_submit_fulfil_request.startrequest';
            l_debug_str :=  'Person ID :' ||p_person_id ||
                      'FA Calendar :'||l_awd_cal_type||'-'||l_awd_seq_number||
          'Appl Details :' ||p_adm_appl_number||'-'||p_appl_sequence_number||
                         '-' ||p_nominated_course_cd||'-'||l_reply_date ||
          'Content ID :' ||p_content_id ||
                      --'Content Type :'||l_content_type ||
          'Version :' ||l_version_id ||
          'Citem Ver Id :'||l_citem_ver_id ||
          'Return Status :' || l_return_status || '-' || l_msg_data;
            fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
         END IF;
     --**


     IF l_return_status IN ('E','U') THEN
          -- FND_MSG_PUB.Count_And_Get( p_count => l_msg_count, p_data  => l_msg_data );
    -- FND_FILE.PUT_LINE(FND_FILE.LOG,l_msg_data);

    IF l_msg_count > 1 THEN
               FOR i IN 1..l_msg_count
               LOOP
                    l_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        l_tmp_var1 := l_tmp_var1 || l_tmp_var;
               END LOOP;
         FND_FILE.PUT_LINE(FND_FILE.LOG,l_tmp_var1);
    ELSE
              FND_FILE.PUT_LINE(FND_FILE.LOG,l_msg_data ||'-' ||l_msg_count);
          END IF;
    RETURN;
     END IF;


    l_varchar_tbl_bind_var(1)      := 'p_person_id';
    l_varchar_tbl_bind_var_type(1) := 'NUMBER';
    l_varchar_tbl_bind_val(1)      := p_person_id;


    IF p_org_unit_id IS NOT NULL THEN
       OPEN c_org_unit_addr (p_org_unit_id);
       FETCH c_org_unit_addr INTO l_org_unit_addr;
       CLOSE c_org_unit_addr;

       IF l_org_unit_addr.ADDRESS1 IS NOT NULL THEN
         OPEN c_org_unit_email ( 'Y','HZ_PARTY_SITES', 'EMAIL', 'Y',p_org_unit_id);
         FETCH c_org_unit_email INTO l_org_unit_email;
         CLOSE c_org_unit_email;

   OPEN c_org_unit_phone ( 'Y','HZ_PARTY_SITES', 'PHONE', 'A',p_org_unit_id,'GEN','FAX');
   LOOP
           FETCH c_org_unit_phone INTO l_org_unit_phone;
           EXIT WHEN (c_org_unit_phone%NOTFOUND OR (l_fax_count = 3 AND l_phone_count = 3));

           IF l_org_unit_phone.PHONE_LINE_TYPE = 'FAX'  AND l_fax_count < 3 THEN
             l_fax_count := l_fax_count + 1;
             l_fax_val := l_fax_val || l_org_unit_phone.PHONE_COUNTRY_CODE || '-' ||
                                 l_org_unit_phone.PHONE_AREA_CODE || '-' ||
               l_org_unit_phone.PHONE_NUMBER || '-' ||
               l_org_unit_phone.PHONE_EXTENSION || ',';
           END IF;

           IF l_org_unit_phone.PHONE_LINE_TYPE = 'GEN' AND l_phone_count < 3 THEN
             l_phone_count := l_phone_count + 1;
             l_phone_val := l_phone_val || l_org_unit_phone.PHONE_COUNTRY_CODE || '-' ||
                                     l_org_unit_phone.PHONE_AREA_CODE || '-' ||
                   l_org_unit_phone.PHONE_NUMBER || '-' ||
                   l_org_unit_phone.PHONE_EXTENSION || ',';

     END IF;

   END LOOP;
         CLOSE c_org_unit_phone;

         IF l_phone_val IS NOT NULL THEN
     l_phone_val := SUBSTR(l_phone_val,0,LENGTH(l_phone_val)-1);
   END IF;

         IF l_fax_val IS NOT NULL THEN
     l_fax_val := SUBSTR(l_fax_val,0,LENGTH(l_fax_val)-1);
   END IF;
       END IF;
    END IF;

   IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
    IF (l_request_id IS NULL) THEN
      l_request_id := fnd_global.conc_request_id;
    END IF;
    l_label := 'igs.plsql.igs_co_process.corp_submit_fulfil_request.beforecontentxml';
    l_debug_str :=  'p_org_phone :' ||l_phone_val ||
          ' p_org_fax :'||l_fax_val ||' p_org_address1 :'||l_org_unit_addr.ADDRESS1||' p_org_address2 :'||l_org_unit_addr.ADDRESS2||
          ' p_org_address3 :'||l_org_unit_addr.ADDRESS3||' p_org_address4 :'||l_org_unit_addr.ADDRESS4||
          ' p_org_party_name :'||l_org_unit_addr.PARTY_NAME||' p_org_postal_code :'||l_org_unit_addr.POSTAL_CODE||
          ' p_org_country :'||l_org_unit_addr.COUNTRY||' p_org_county :'||l_org_unit_addr.COUNTY||
          ' p_org_city :'||l_org_unit_addr.CITY||' p_org_province :'||l_org_unit_addr.PROVINCE||
          ' p_org_state :'||l_org_unit_addr.STATE||' p_org_email_address :'||l_org_unit_email.EMAIL_ADDRESS;
    fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));

   END IF;

    l_varchar_tbl_bind_var(2)      := 'p_org_phone';
    l_varchar_tbl_bind_var_type(2) := 'VARCHAR2';
    l_varchar_tbl_bind_val(2)      := l_phone_val;

    l_varchar_tbl_bind_var(3)      := 'p_org_fax';
    l_varchar_tbl_bind_var_type(3) := 'VARCHAR2';
    l_varchar_tbl_bind_val(3)      := l_fax_val;

    l_varchar_tbl_bind_var(4)      := 'p_org_address1';
    l_varchar_tbl_bind_var_type(4) := 'VARCHAR2';
    l_varchar_tbl_bind_val(4)      := l_org_unit_addr.ADDRESS1;

    l_varchar_tbl_bind_var(5)      := 'p_org_address2';
    l_varchar_tbl_bind_var_type(5) := 'VARCHAR2';
    l_varchar_tbl_bind_val(5)      := l_org_unit_addr.ADDRESS2;

    l_varchar_tbl_bind_var(6)      := 'p_org_address3';
    l_varchar_tbl_bind_var_type(6) := 'VARCHAR2';
    l_varchar_tbl_bind_val(6)      := l_org_unit_addr.ADDRESS3;

    l_varchar_tbl_bind_var(7)      := 'p_org_address4';
    l_varchar_tbl_bind_var_type(7) := 'VARCHAR2';
    l_varchar_tbl_bind_val(7)      := l_org_unit_addr.ADDRESS4;

    l_varchar_tbl_bind_var(8)      := 'p_org_party_name';
    l_varchar_tbl_bind_var_type(8) := 'VARCHAR2';
    l_varchar_tbl_bind_val(8)      := l_org_unit_addr.PARTY_NAME;

    l_varchar_tbl_bind_var(9)      := 'p_org_postal_code';
    l_varchar_tbl_bind_var_type(9) := 'VARCHAR2';
    l_varchar_tbl_bind_val(9)      := l_org_unit_addr.POSTAL_CODE;

    l_varchar_tbl_bind_var(10)      := 'p_org_country';
    l_varchar_tbl_bind_var_type(10) := 'VARCHAR2';
    l_varchar_tbl_bind_val(10)      := l_org_unit_addr.COUNTRY;

    l_varchar_tbl_bind_var(11)      := 'p_org_county';
    l_varchar_tbl_bind_var_type(11) := 'VARCHAR2';
    l_varchar_tbl_bind_val(11)      := l_org_unit_addr.COUNTY;

    l_varchar_tbl_bind_var(12)      := 'p_org_city';
    l_varchar_tbl_bind_var_type(12) := 'VARCHAR2';
    l_varchar_tbl_bind_val(12)      := l_org_unit_addr.CITY;

    l_varchar_tbl_bind_var(13)      := 'p_org_province';
    l_varchar_tbl_bind_var_type(13) := 'VARCHAR2';
    l_varchar_tbl_bind_val(13)      := l_org_unit_addr.PROVINCE;

    l_varchar_tbl_bind_var(14)      := 'p_org_state';
    l_varchar_tbl_bind_var_type(14) := 'VARCHAR2';
    l_varchar_tbl_bind_val(14)      := l_org_unit_addr.STATE;

    l_varchar_tbl_bind_var(15)      := 'p_org_email_address';
    l_varchar_tbl_bind_var_type(15) := 'VARCHAR2';
    l_varchar_tbl_bind_val(15)      := l_org_unit_email.EMAIL_ADDRESS;


    IF p_sys_ltr_code IN ('FAAWARD','FAMISTM','FADISBT') THEN
      IF p_award_year IS NOT NULL THEN
        l_awd_cal_type := SUBSTR (p_award_year,1, 10);
        l_awd_seq_number := TO_NUMBER(SUBSTR (p_award_year,11));
      END IF;

      l_varchar_tbl_bind_var(16)      := 'p_awd_cal_type';
      l_varchar_tbl_bind_var_type(16) := 'VARCHAR2';
      l_varchar_tbl_bind_val(16)      := l_awd_cal_type;
      l_varchar_tbl_bind_var(17)      := 'p_awd_seq_number';
      l_varchar_tbl_bind_var_type(17) := 'NUMBER';
      l_varchar_tbl_bind_val(17)      := l_awd_seq_number;

    ELSIF p_sys_ltr_code = 'ADACKMT' THEN
      l_varchar_tbl_bind_var(16)      := 'p_adm_appl_number';
      l_varchar_tbl_bind_var_type(16) := 'NUMBER';
      l_varchar_tbl_bind_val(16)      := p_adm_appl_number;

    --kumma, 3104787, Added the following code to not to take adhoc letters
    ELSIF p_sys_ltr_code NOT IN ('ADRESID','ADADHOC','FAADHOC','GENERIC','ADRESID','ENADHOC','SFADHOC') THEN
      l_varchar_tbl_bind_var(16)      := 'p_appl_sequence_number';
      l_varchar_tbl_bind_var_type(16) := 'NUMBER';
      l_varchar_tbl_bind_val(16)      := p_appl_sequence_number;

      l_varchar_tbl_bind_var(17)      := 'p_adm_appl_number';
      l_varchar_tbl_bind_var_type(17) := 'NUMBER';
      l_varchar_tbl_bind_val(17)      := p_adm_appl_number;

      l_varchar_tbl_bind_var(18)      := 'p_nominated_course_cd';
      l_varchar_tbl_bind_var_type(18) := 'VARCHAR2';
      l_varchar_tbl_bind_val(18)      := p_nominated_course_cd;

      IF p_sys_ltr_code = 'ADNORSP' THEN
        OPEN c_reply_date(l_reply_days) ;
  FETCH c_reply_date INTO l_reply_date ;
  CLOSE c_reply_date;

        l_varchar_tbl_bind_var(19)      := 'REPLY_DATE';
        l_varchar_tbl_bind_var_type(19) := 'DATE';
        l_varchar_tbl_bind_val(19)      := l_reply_date;
      ELSIF p_sys_ltr_code = 'ADINTRW' THEN

        OPEN c_intr_reply_date(p_person_id,
                         p_adm_appl_number,
                               p_nominated_course_cd,
                         p_appl_sequence_number,
                         p_panel_code) ;
  FETCH c_intr_reply_date INTO l_reply_date ;
  CLOSE c_intr_reply_date;

        IF NVL(l_reply_date,SYSDATE) <= SYSDATE THEN
    l_reply_date := SYSDATE;
  END IF;
        l_varchar_tbl_bind_var(19)      := 'p_panel_code';
        l_varchar_tbl_bind_var_type(19) := 'VARCHAR2';
        l_varchar_tbl_bind_val(19)      := p_panel_code;

        l_varchar_tbl_bind_var(20)      := 'REPLY_DATE';
        l_varchar_tbl_bind_var_type(20) := 'DATE';
        l_varchar_tbl_bind_val(20)      := l_reply_date;

      END IF;
    END IF;


     --kumma, 3104787, Added the following code to check that if the content type should be query and data
     -- need to pass the version id because the table doesnt hold citem_ver_id

     OPEN c_check_relation (p_content_id, l_version_id);
     FETCH c_check_relation INTO l_query_exists;
     CLOSE c_check_relation;

     IF l_query_exists = 'Y' THEN
          l_content_type := 'QUERY';
     ELSE
          l_content_type := 'DATA';

          l_varchar_tbl_bind_var := le_varchar_tbl_bind_var;
    l_varchar_tbl_bind_var_type := le_varchar_tbl_bind_var_type;
    l_varchar_tbl_bind_val  := le_varchar_tbl_bind_val;

     END IF;



    --
    --  To Submit fulfilment request by invoking CRM API
    --

     --**  proc level logging.
         IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;
            l_label := 'igs.plsql.igs_co_process.corp_submit_fulfil_request.CALLING_GET_CONTENT_XML WITH PARAMS';
            l_debug_str :=  'values ;';
            l_debug_str :=  l_debug_str || 'p_content_id=' || p_content_id;
            l_debug_str :=  l_debug_str || 'p_media_type,=' || p_media_type;
            l_debug_str :=  l_debug_str || 'p_email_address,=' || p_email_address;
            l_debug_str :=  l_debug_str || 'p_destination,=' || p_destination;
            l_debug_str :=  l_debug_str || 'l_content_type,=' || l_content_type;
            l_debug_str :=  l_debug_str || 'p_request_id,=' || p_request_id;
            --l_debug_str :=  l_debug_str || 'l_content_xml,=' || l_content_xml;
            l_debug_str :=  l_debug_str || 'l_citem_ver_id,=' || l_citem_ver_id;
            l_debug_str :=  l_debug_str || 'p_fax_number,=' || p_fax_number;
            fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
         END IF;
     --**

    jtf_fm_request_grp.get_content_xml (
      p_api_version     => 1,
      p_init_msg_list   => 'T',
      x_return_status   => l_return_status,
      x_msg_count       => l_msg_count,
      x_msg_data        => l_msg_data,
      p_bind_var        => l_varchar_tbl_bind_var,
      p_bind_val        => l_varchar_tbl_bind_val,
      p_bind_var_type   => l_varchar_tbl_bind_var_type,
      p_content_id      => p_content_id,
      p_media_type      => p_media_type,
      p_email           => p_email_address,
      p_printer         => p_destination,
      p_content_type    => l_content_type,
      p_request_id      => p_request_id,
      x_content_xml     => l_content_xml,
      P_CONTENT_SOURCE  => 'OCM',
      P_VERSION         => l_citem_ver_id ,   -- CITEM version information IBC.C changes. THIS SHOULD NOT BE l_version_id
      p_fax             => p_fax_number
      );

     --FND_FILE.PUT_LINE(FND_FILE.LOG,l_version_id ||' /'||l_content_xml);
     --**  proc level logging.
         IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;
            l_label := 'igs.plsql.igs_co_process.corp_submit_fulfil_request.aftercontentxml';
            l_debug_str :=  'Content Type :' ||l_content_type ||
	                    'Return Status :'||l_return_status ||'-' ||l_msg_data;
             l_debug_str := l_debug_str || l_content_xml;
            fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
         END IF;
     --**


     IF l_return_status IN ('E','U') THEN
          --FND_MSG_PUB.Count_And_Get( p_count => l_msg_count, p_data  => l_msg_data );
    --FND_FILE.PUT_LINE(FND_FILE.LOG,l_msg_data);

    IF l_msg_count > 1 THEN
               FOR i IN 1..l_msg_count
               LOOP
                    l_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        l_tmp_var1 := l_tmp_var1 || l_tmp_var;
               END LOOP;
         FND_FILE.PUT_LINE(FND_FILE.LOG,l_tmp_var1);
    ELSE
              FND_FILE.PUT_LINE(FND_FILE.LOG,l_msg_data ||'-' ||l_msg_count);
          END IF;
    RETURN;
     END IF;

     /*
     l_id := 'ssawhney@oracle.com';
     l_extended_header:= '<extended_header><header_name>email_from_address</header_name><header_value>' || l_id || '</header_value>' ;
     l_extended_header:= l_extended_header||'<header_name>email_reply_to_address</header_name><header_value>' || l_id || '</header_value></extended_header>';
     */

    IF l_org_unit_email.EMAIL_ADDRESS IS NOT NULL OR p_reply_email IS NOT NULL OR
       p_sender_email IS NOT NULL OR
       p_cc_email IS NOT NULL THEN

       l_extended_header:= '<extended_header>';

       IF p_reply_email IS NOT NULL THEN
          l_extended_header := l_extended_header || '<header_name>email_reply_to_address</header_name><header_value>' || p_reply_email || '</header_value>' ;
       ELSIF l_org_unit_email.EMAIL_ADDRESS IS NOT NULL  THEN
          l_extended_header := l_extended_header || '<header_name>email_reply_to_address</header_name><header_value>' || l_org_unit_email.EMAIL_ADDRESS  || '</header_value>' ;
       END IF;

       IF p_sender_email IS NOT NULL THEN
          l_extended_header := l_extended_header || '<header_name>email_from_address</header_name><header_value>' || p_sender_email || '</header_value>' ;
       ELSIF l_org_unit_email.EMAIL_ADDRESS IS NOT NULL  THEN
          l_extended_header := l_extended_header || '<header_name>email_from_address</header_name><header_value>' || l_org_unit_email.EMAIL_ADDRESS || '</header_value>' ;
       END IF;

       IF p_cc_email IS NOT NULL THEN
          l_extended_header := l_extended_header || '<header_name>email_cc_address</header_name><header_value>' || p_cc_email  || '</header_value>' ;
       END IF;

       l_extended_header := l_extended_header || '</extended_header>';

    END IF;

    IF p_preview = 'Y' THEN
      -- Store away all of the parameters required for a preview so they can be used later to fulfill the request.
      -- PACROSS - 11-SEP-2005

           --**  proc level logging.
         IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;
            l_label := 'igs.plsql.igs_co_process.corp_submit_fulfil_request.before_inserting_into_IGS_CO_PREV_REQS';
            l_debug_str :=  'just going to insert into IGS_CO_PREV_REQS';
            l_debug_str := l_debug_str || 'conc_request_id='||fnd_global.conc_request_id;
            l_debug_str := l_debug_str || ',p_letter_type='||p_letter_type;
            l_debug_str := l_debug_str || ',p_person_id=' || p_person_id;
            l_debug_str := l_debug_str || ',p_email_address=' || p_email_address;
            l_debug_str := l_debug_str || ',p_content_id=' || p_content_id;
            l_debug_str := l_debug_str || ',p_content_id=' || p_content_id;
            l_debug_str := l_debug_str || ',p_award_year=' || p_award_year;
            l_debug_str := l_debug_str || ',p_sys_ltr_code=' || p_sys_ltr_code;
            l_debug_str := l_debug_str || ',p_adm_appl_number=' || p_adm_appl_number;
            l_debug_str := l_debug_str || ',p_nominated_course_cd=' || p_nominated_course_cd;
            l_debug_str := l_debug_str || ',p_appl_sequence_number=' || p_appl_sequence_number;
            l_debug_str := l_debug_str || ',p_fulfillment_req=' || p_fulfillment_req;
            l_debug_str := l_debug_str || ',p_crm_user_id=' || p_crm_user_id;
            l_debug_str := l_debug_str || ',p_media_type=' || p_media_type;
            l_debug_str := l_debug_str || ',p_destination=' || p_destination;
            l_debug_str := l_debug_str || ',p_fax_number=' || p_fax_number;
            l_debug_str := l_debug_str || ',p_reply_days=' || p_reply_days;
	    l_debug_str := l_debug_str || ',l_reply_days=' || l_reply_days;
            l_debug_str := l_debug_str || ',p_panel_code=' || p_panel_code;
            l_debug_str := l_debug_str || ',p_reply_email=' || p_reply_email;
            l_debug_str := l_debug_str || ',p_sender_email=' || p_sender_email;
            l_debug_str := l_debug_str || ',p_cc_email=' || p_cc_email;
            l_debug_str := l_debug_str || ',p_org_unit_id=' || p_org_unit_id;
            l_debug_str := l_debug_str || ',p_awd_cal_type=' || p_awd_cal_type;
            l_debug_str := l_debug_str || ',p_awd_ci_seq_number=' || p_awd_ci_seq_number;
            l_debug_str := l_debug_str || ',l_citem_ver_id=' || l_citem_ver_id;
            l_debug_str := l_debug_str || ',l_citem_ver_id=' || l_citem_ver_id;
            l_debug_str := l_debug_str || ',l_doc_desc=' || l_doc_desc;
            --l_debug_str := l_debug_str || ',l_content_xml=' || l_content_xml;
            --l_debug_str := l_debug_str || ',l_content_xml=' || l_content_xml;
            l_debug_str := l_debug_str || ',p_request_id=' || p_request_id;
            --l_debug_str := l_debug_str || ',l_extended_header=' || l_extended_header;
            l_debug_str := l_debug_str || ',p_awd_prd_cd=' || p_awd_prd_cd;


            fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
         END IF;
           --**

     BEGIN

	      INSERT INTO IGS_CO_PREV_REQS
		 (CONCURRENT_REQUEST_ID, LETTER_TYPE_CODE, PERSON_ID,
		  EMAIL_ADDRESS, ORIGINAL_CONTENT_ID, CURRENT_CONTENT_ID, AWARD_YEAR,
		  SYS_LTR_CODE, ADM_APPL_NUMBER, NOMINATED_COURSE_CD, APPL_SEQUENCE_NUMBER,
		  FULFILLMENT_REQ, CRM_USER_ID, MEDIA_TYPE_CODE, DESTINATION, FAX_NUMBER, REPLY_DAYS,
		  PANEL_CODE, REPLY_EMAIL, SENDER_EMAIL, CC_EMAIL, ORG_UNIT_ID, AWD_CAL_TYPE,
		  AWD_CI_SEQ_NUMBER, ORIGINAL_VERSION_ID, CURRENT_VERSION_ID, EMAIL_SUBJECT, ORIGINAL_CONTENT_XML,
		  CURRENT_CONTENT_XML, FF_REQUEST_HIST_ID, EXTENDED_HEADER, DISTRIBUTION_ID, REQUEST_STATUS_CODE,
		  OBJECT_VERSION_NUMBER, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
		  LAST_UPDATE_DATE, AWARD_PRD_CD)
	      VALUES
		 (fnd_global.conc_request_id, p_letter_type, p_person_id,
		  p_email_address, p_content_id, p_content_id, p_award_year,
		  p_sys_ltr_code, p_adm_appl_number, p_nominated_course_cd, p_appl_sequence_number,
		  p_fulfillment_req, p_crm_user_id, p_media_type, p_destination, p_fax_number, l_reply_days,
		  p_panel_code, p_reply_email, p_sender_email, p_cc_email, p_org_unit_id, p_awd_cal_type,
		  p_awd_ci_seq_number, l_citem_ver_id, l_citem_ver_id, l_doc_desc, l_content_xml,
		  l_content_xml, p_request_id, l_extended_header, NULL, 'CREATED', 1,
		  FND_GLOBAL.USER_ID, SYSDATE, FND_GLOBAL.USER_ID, NULL, SYSDATE, p_awd_prd_cd);

     EXCEPTION
          WHEN OTHERS THEN

          --**  proc level logging.
          IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
               IF (l_request_id IS NULL) THEN
                   l_request_id := fnd_global.conc_request_id;
               END IF;
               l_label := 'igs.plsql.igs_co_process.corp_submit_fulfil_request.excep_when_insert';
               l_debug_str :=  'inside exception section when inserting record in IGS_CO_PREV_REQS and exception is  ' || sqlerrm;
               fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
          END IF;
          --**
      Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGS_CO_PROCESS.corp_submit_fulfil_request');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;

     END;
	  --**  proc level logging.
	 IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
	    IF (l_request_id IS NULL) THEN
	      l_request_id := fnd_global.conc_request_id;
	    END IF;
	    l_label := 'igs.plsql.igs_co_process.corp_submit_fulfil_request.after_inserting_into_IGS_CO_PREV_REQS';
	    l_debug_str :=  'just after insert into IGS_CO_PREV_REQS';
	    fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
	 END IF;
	 --**


           --**  proc level logging.
         IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;
            l_label := 'igs.plsql.igs_co_process.corp_submit_fulfil_request.going_to_call_send_request';
            l_debug_str :=  'calling send_request with parameters l_doc_desc='||l_doc_desc;
            l_debug_str :=  l_debug_str || ',p_crm_user_id=' || p_crm_user_id;
            l_debug_str :=  l_debug_str || ',l_content_xml=' || l_content_xml;
            l_debug_str :=  l_debug_str || ',p_request_id=' || p_request_id;
            l_debug_str :=  l_debug_str || ',p_person_id=' || p_person_id;
            l_debug_str :=  l_debug_str || ',l_extended_header=' || l_extended_header;
            l_debug_str :=  l_debug_str || ',p_content_id=' || p_content_id;
            fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
         END IF;
           --**

      jtf_fm_request_grp.send_request (
        p_api_version     => 1,
        p_init_msg_list   => 'T',
        x_return_status   => l_return_status,
        x_msg_count       => l_msg_count,
        x_msg_data        => l_msg_data,
        p_subject         => l_doc_desc,
        p_user_id         => p_crm_user_id,
        p_content_xml     => l_content_xml,
        p_request_id      => p_request_id,
        p_party_id        => p_person_id,
        p_doc_id          => p_request_id,
        p_extended_header => l_extended_header,
        p_doc_ref         => to_char(p_content_id),
        p_preview          => FND_API.G_TRUE
      );

      --**  proc level logging.
	 IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
	    IF (l_request_id IS NULL) THEN
	      l_request_id := fnd_global.conc_request_id;
	    END IF;
	    l_label := 'igs.plsql.igs_co_process.corp_submit_fulfil_request.after_call_to_send_request';
	    l_debug_str :=  'just after call to send_request with status ' || l_return_status || ' and l_msg_data ' || l_msg_data;
	    fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
	 END IF;
     --**

    ELSE
      -- Submit the request as per pre-preview and edit

      jtf_fm_request_grp.submit_request (
        p_api_version     => 1,
        p_init_msg_list   => 'T',
        x_return_status   => l_return_status,
        x_msg_count       => l_msg_count,
        x_msg_data        => l_msg_data,
        p_subject         => l_doc_desc,
        p_user_id         => p_crm_user_id,
        --p_server_id       => p_fulfillment_req,
        p_content_xml     => l_content_xml,
        p_request_id      => p_request_id,
        p_party_id        => p_person_id,
        p_doc_id          => p_request_id,
        p_extended_header => l_extended_header,   --ssawhney testing.
        p_doc_ref         => to_char(p_content_id)
      );
    END IF;

    IF l_return_status = 'S' THEN

          p_request_status := 'SUBMITTED';
          OPEN c_per_processed(p_person_id);
          FETCH c_per_processed INTO l_person_number,l_full_name;
        Fnd_Message.Set_name('IGF','IGF_AW_PROC_STUD');
        FND_MESSAGE.SET_TOKEN('STDNT',l_person_number||' - '||l_full_name);
                    fnd_file.put_line(fnd_file.log,fnd_message.get);
        Fnd_Message.Set_name('IGS','IGS_CO_REQ_INFO');
        FND_MESSAGE.SET_TOKEN('REQUEST_ID',p_request_id);
                    fnd_file.put_line(fnd_file.log,fnd_message.get);

         IF igs_co_process.l_message_logged THEN
      igs_co_process.l_message_logged := FALSE;
         END IF;
          CLOSE c_per_processed;
    ELSE
          p_request_status := 'FAILURE';
    -- FND_MSG_PUB.Count_And_Get( p_count => l_msg_count, p_data  => l_msg_data );
    -- FND_FILE.PUT_LINE(FND_FILE.LOG,l_msg_data);

    IF l_msg_count > 1 THEN
               FOR i IN 1..l_msg_count
               LOOP
                    l_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        l_tmp_var1 := l_tmp_var1 || l_tmp_var;
               END LOOP;
         FND_FILE.PUT_LINE(FND_FILE.LOG,l_tmp_var1);
    ELSE
               FND_FILE.PUT_LINE(FND_FILE.LOG,l_msg_data ||'-' ||l_msg_count);
          END IF;

    END IF;

   --**  proc level logging.
	 IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
	    IF (l_request_id IS NULL) THEN
	      l_request_id := fnd_global.conc_request_id;
	    END IF;
	    l_label := 'igs.plsql.igs_co_process.corp_submit_fulfil_request.aftersubmitrequest';
	    l_debug_str :=  'Request ID :' ||p_request_id ||
			    'Return Status :' ||l_return_status  ||'-' ||l_msg_data;
	    fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
	 END IF;
  --**

   l_corp_submit_fulfil_request := FALSE;
    COMMIT;
  ELSE
   l_corp_submit_fulfil_request := TRUE;
      IF NOT igs_co_process.l_message_logged THEN
   fnd_message.set_name('IGS','IGS_CO_HOLD_EXISTS');
   fnd_file.put_line(fnd_file.log,fnd_message.get);
   igs_co_process.l_message_logged := TRUE;
      END IF;
     OPEN log_details; LOOP
       FETCH log_details INTO l_full_name,l_person_number,l_encumbrance_desc;
         EXIT WHEN log_details%NOTFOUND;
   fnd_file.put_line(fnd_file.log,rpad(l_person_number,20,' ')||'             '||rpad(l_full_name,50,' ')||'    '||l_encumbrance_desc);
      END LOOP;
   CLOSE log_details;
  END IF;
  EXCEPTION
    WHEN OTHERS THEN

     --**  proc level logging.
         IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;
            l_label := 'igs.plsql.igs_co_process.corp_submit_fulfil_request.inside_excep_section';
            l_debug_str :=  'inside exception section and exception is  ' || sqlerrm;
            fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
         END IF;
     --**
      Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGS_CO_PROCESS.corp_submit_fulfil_request');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END corp_submit_fulfil_request;

  PROCEDURE corp_post_process(
    p_person_id              IN        NUMBER,
    p_request_id             IN        NUMBER,
    p_document_id            IN        NUMBER,
    p_sys_ltr_code           IN        VARCHAR2,
    p_document_type          IN        VARCHAR2,
    p_adm_appl_number        IN        NUMBER,
    p_nominated_course_cd    IN        VARCHAR2,
    p_appl_seq_number        IN        NUMBER,
    p_awd_cal_type           IN        VARCHAR2,
    p_awd_ci_seq_number      IN        NUMBER,
    p_award_year             IN        VARCHAR2,
    p_delivery_type          IN        VARCHAR2,
    p_version_id             IN        NUMBER,
    p_award_prd_cd           IN        VARCHAR2
  ) AS
  /*************************************************************
  Created By :Nalin Kumar
  Date Created on : 05-Feb-2002
  Purpose : This procedure will perform post-processing.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
    l_rowid VARCHAR2(25);
  BEGIN

    IF p_sys_ltr_code = 'FAAWARD' THEN
      igf_aw_gen_004.award_letter_update(
        p_person_id     =>   p_person_id,
        p_award_year    =>   p_award_year,
        p_award_prd_cd  =>   p_award_prd_cd);
    ELSIF P_SYS_LTR_CODE = 'FAMISTM' THEN
      igf_aw_gen_004.missing_items_update(
        p_person_id     =>   p_person_id,
        p_award_year    =>   p_award_year);
    --Commented by Prajeesh as the Disbursement Update was happening before the CRM process it
    --pick up the record. As the record is getting updated first when CRM tries to pick, It is
    --Unable to pick up the record hence raises an Unhandled Exception.
    /*ELSIF P_SYS_LTR_CODE = 'FADISBT' THEN
      igf_aw_gen_004.loan_disbursement_update(
        p_person_id     =>   p_person_id,
        p_award_year    =>   p_award_year);*/
    END IF;

    --
    -- Insert the record into the igs_co_interac_hist table with the all relevant
    -- details and status from 'p_request_status'.
    --
    l_rowid := NULL;
    igs_co_interac_hist_pkg.insert_row(
      x_rowid                        =>  l_rowid,
      x_student_id                   =>  TO_NUMBER(p_person_id),
      x_request_id                   =>  TO_NUMBER(p_request_id),
      x_document_id                  =>  TO_NUMBER(p_document_id),
      x_document_type                =>  p_document_type,
      x_sys_ltr_code                 =>  p_sys_ltr_code,
      x_adm_application_number       =>  p_adm_appl_number,
      x_nominated_course_cd          =>  p_nominated_course_cd,
      x_sequence_number              =>  p_appl_seq_number,
      x_cal_type                     =>  p_awd_cal_type,
      x_ci_sequence_number           =>  p_awd_ci_seq_number,
      x_requested_date               =>  SYSDATE,
      x_delivery_type                =>  p_delivery_type,
      x_version_id                   =>  p_version_id
    );

    --**  proc level logging.
         IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;
            l_label := 'igs.plsql.igs_co_process.corp_post_process.afterinteractioninsert';
            l_debug_str :=  'Doc id :' ||p_document_id || 'Version Id :' ||p_version_id ||
                      'Person Id :'||p_person_id;
            fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
         END IF;
     --**

  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGS_CO_PROCESS.corp_post_process');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END corp_post_process;

  PROCEDURE corp_get_system_letter_view(
    p_sys_ltr_code      IN       VARCHAR2,
    p_view_name         OUT NOCOPY      VARCHAR2,
    p_where_clause      OUT NOCOPY      VARCHAR2
  ) AS
  /*************************************************************
  Created By :Nalin Kumar
  Date Created on : 05-Feb-2002
  Purpose : This procedure returns the view name for the system letter code.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
      Bayadav         24-MAY-2002     Included two system letter codes 'ENADHOC', 'SFADHOC' for adhoc letters as a part of bug 2376434
  ***************************************************************/
  BEGIN
    IF p_sys_ltr_code IN ('ADADHOC','FAADHOC','GENERIC','ENADHOC','SFADHOC') THEN
      p_view_name := ' hz_parties';
    ELSIF   p_sys_ltr_code = 'ADMISTM' THEN
      p_view_name := ' igs_ad_missing_items_letter_v';
      p_where_clause := ' s_adm_outcome_status <> ''CANCELLED''';
    ELSIF p_sys_ltr_code = 'ADACKMT' THEN
      p_view_name := ' igs_ad_ack_letter_v';
      p_where_clause := ' s_adm_outcome_status <> ''CANCELLED''';
    ELSIF p_sys_ltr_code = 'ADRESID'   THEN
      p_view_name := ' igs_ad_resi_letter_v';
      p_where_clause := ' 1=1 ';
    ELSIF p_sys_ltr_code = 'ADACCEP'   THEN
      p_view_name := ' igs_ad_outcome_letters_v';
      p_where_clause := ' s_adm_outcome_status = ''OFFER''
            AND previous_term_adm_appl_number IS NULL
      AND previous_term_sequence_number IS NULL ';
    ELSIF p_sys_ltr_code = 'ADREJEC'   THEN
      p_view_name := ' igs_ad_outcome_letters_v';
      p_where_clause := ' s_adm_outcome_status = ''REJECTED''';
    ELSIF p_sys_ltr_code = 'ADWAITL'   THEN
      p_view_name := ' igs_ad_outcome_letters_v';
      p_where_clause := ' s_adm_outcome_status = ''WAITLIST''';
    ELSIF p_sys_ltr_code = 'ADNOQUT'   THEN
      p_view_name := ' igs_ad_outcome_letters_v';
      p_where_clause := ' s_adm_outcome_status = ''NO-QUOTA''';
    ELSIF p_sys_ltr_code = 'ADFUTSE'   THEN
      p_view_name := ' igs_ad_outcome_letters_v';
      p_where_clause := ' s_adm_outcome_status = ''OFFER-FUTURE-TERM''';
    ELSIF p_sys_ltr_code = 'ADCONOF'   THEN
      p_view_name := ' igs_ad_outcome_letters_v';
      p_where_clause := ' s_adm_outcome_status = ''COND-OFFER''';
    ELSIF p_sys_ltr_code = 'ADPADMS'   THEN
      p_view_name := ' igs_ad_postadm_miss_itm_ltr_v';
      p_where_clause := ' s_adm_outcome_status <> ''CANCELLED''';
    ELSIF p_sys_ltr_code = 'ADMFTSA'   THEN
      p_view_name := ' igs_ad_outcome_letters_v';
      p_where_clause := ' s_adm_outcome_status = ''OFFER''
                        AND   previous_term_adm_appl_number IS NOT NULL
                  AND   previous_term_sequence_number IS NOT NULL ';
    ELSIF p_sys_ltr_code = 'FAAWARD'   THEN
      p_view_name := ' igf_aw_per_list_v';
    ELSIF p_sys_ltr_code = 'FAMISTM'   THEN
      p_view_name := ' igf_ap_mis_itms_ltr_v';
    ELSIF p_sys_ltr_code = 'FADISBT'   THEN
      p_view_name := ' igf_sl_disb_ltr_v';
    ELSIF p_sys_ltr_code = 'ADNORSP'   THEN
      p_view_name := ' igs_ad_outcome_letters_v';
      p_where_clause := ' s_adm_outcome_status IN (''OFFER'',''COND-OFFER'') '||
                        ' AND S_ADM_OFFER_RESP_STATUS = ''PENDING'' '||
      ' AND SYSDATE > OFFER_RESPONSE_DT ';
    ELSIF p_sys_ltr_code = 'ADINTRW'   THEN
      p_view_name := ' igs_ad_interview_letters_v';
      p_where_clause := '1=1';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGS_CO_PROCESS.corp_get_system_letter_view');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END corp_get_system_letter_view;

  PROCEDURE corp_get_parameter_value(
    p_sys_ltr_code     IN       VARCHAR2,
    p_parameter_1      IN       VARCHAR2,
    p_parameter_2      IN       VARCHAR2,
    p_parameter_3      IN       VARCHAR2,
    p_parameter_4      IN       VARCHAR2,
    p_parameter_5      IN       VARCHAR2,
    p_parameter_6      IN       VARCHAR2,
    p_parameter_7      IN       VARCHAR2,
    p_parameter_8      IN       VARCHAR2,
    p_parameter_9      IN       VARCHAR2,
    p_parameter_value  OUT NOCOPY      VARCHAR2
  ) AS
  /*************************************************************
  Created By :Nalin Kumar
  Date Created on : 05-Feb-2002
  Purpose : This procedure accepts 5 parameters and builds a where
            clause for student selection.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  ssaleem         28-OCT-2003     Bug : 3198795
                                  Part of the Dynamic/Static Person Groups modifications,
          In places where person group id is included to the SQL, a condition 1=1 is replaced.
  npalanis        23-OCT-2002     Bug : 2608360
                                  residency_status_id and residency_class_id is being removed from  igs_ad_resi_letter_v
                                  and the code class is being moved to igs_lookups therefore those are changed to
                                  residency_status_cd  and residency_class_cd.
  pkpatel         7-MAy-2003      Bug 2940810
                                  Modified for Bind Variable
  (reverse chronological order - newest change first)
  ***************************************************************/

    l_pers_group_id igs_ad_missing_items_letter_v.pers_group_id%TYPE;
    l_acad_cal_type VARCHAR(15); --igs_ad_missing_items_letter_v.acad_cal_type%TYPE;
    l_acad_ci_sequence_number igs_ad_missing_items_letter_v.acad_ci_sequence_number%TYPE;
    l_adm_cal_type VARCHAR(15); --igs_ad_ps_appl_inst.adm_cal_type%TYPE;
    l_adm_ci_sequence_number igs_ad_ps_appl_inst.adm_ci_sequence_number%TYPE;
    l_parameter_7 hz_parties.party_id%TYPE;
    l_parameter_8 igs_co_interac_hist.adm_application_number%TYPE;
    l_parameter_9 igs_co_interac_hist.nominated_course_cd%TYPE;
    l_parameter_10 igs_co_interac_hist.ci_sequence_number%TYPE;

  BEGIN
	 --** proc level logging.
        IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

            l_label := 'igs.plsql.igs_co_process.corp_get_parameter_value';
            l_debug_str :=  'p_sys_ltr_code:'||p_sys_ltr_code;
	    l_debug_str := l_debug_str ||' p_parameter_1 :'||p_parameter_1;
	    l_debug_str := l_debug_str ||' p_parameter_2 :'||p_parameter_2;
	    l_debug_str := l_debug_str ||' p_parameter_3 :'||p_parameter_3;
	    l_debug_str := l_debug_str ||' p_parameter_4 :'||p_parameter_4;
	    l_debug_str := l_debug_str ||' p_parameter_5 :'||p_parameter_5;
	    l_debug_str := l_debug_str ||' p_parameter_6 :'||p_parameter_6;
	    l_debug_str := l_debug_str ||' p_parameter_7 :'||p_parameter_7;
	    l_debug_str := l_debug_str ||' p_parameter_8 :'||p_parameter_8;
	    l_debug_str := l_debug_str ||' p_parameter_9 :'||p_parameter_9;

            fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
        END IF;
   --**

    fnd_dsql.add_text(' AND ');

    IF p_parameter_1 IS NOT NULL THEN
      l_pers_group_id := TO_NUMBER(p_parameter_1);
    END IF;

    IF p_sys_ltr_code <> 'ADRESID' THEN
      IF p_parameter_1 IS NULL THEN
        l_acad_cal_type := RTRIM(SUBSTR (p_parameter_2,101, 10));
        l_acad_ci_sequence_number := TO_NUMBER(SUBSTR (p_parameter_2,112));
        l_adm_cal_type :=RTRIM(SUBSTR (p_parameter_3, 1, 10));
        l_adm_ci_sequence_number := TO_NUMBER(SUBSTR (p_parameter_3,11));
      END IF;
    END IF;

    IF p_sys_ltr_code IN('ADPADMS','ADMISTM') THEN
      l_parameter_7 := TO_NUMBER(SUBSTR (p_parameter_8,1,15));    --person_id
      l_parameter_8 := TO_NUMBER(SUBSTR (p_parameter_8,16,2));   --admission_appl_number
      l_parameter_9 := RTRIM(SUBSTR (p_parameter_8,18,6));       --nominated_course_cd
      l_parameter_10:= TO_NUMBER(SUBSTR (p_parameter_8,24,6));      --sequence_number
    END IF;

    IF p_sys_ltr_code = 'ADMISTM' THEN
      IF p_parameter_1 IS NOT NULL THEN
        fnd_dsql.add_text(' 1=1 ' );
      ELSE
        fnd_dsql.add_text(' acad_cal_type = ');
        fnd_dsql.add_bind(l_acad_cal_type);
        fnd_dsql.add_text(' AND acad_ci_sequence_number = ');
        fnd_dsql.add_bind(l_acad_ci_sequence_number);
        fnd_dsql.add_text(' AND adm_cal_type = ');
        fnd_dsql.add_bind(l_adm_cal_type);
        fnd_dsql.add_text(' AND adm_ci_sequence_number =');
        fnd_dsql.add_bind(l_adm_ci_sequence_number);
        fnd_dsql.add_text(' AND adm_process_cat =');
        fnd_dsql.add_bind(p_parameter_4);
        fnd_dsql.add_text(' AND adm_doc_status = ');
        fnd_dsql.add_bind(p_parameter_5);
        fnd_dsql.add_text(' AND org_unit_cd = ');
        fnd_dsql.add_bind(p_parameter_6);
        fnd_dsql.add_text(' AND person_id = ');
        fnd_dsql.add_bind(l_parameter_7);
        fnd_dsql.add_text(' AND adm_appl_number = ');
        fnd_dsql.add_bind(l_parameter_8);
        fnd_dsql.add_text(' AND nominated_course_cd = ');
        fnd_dsql.add_bind(l_parameter_9);
        fnd_dsql.add_text(' AND appl_sequence_number = ');
        fnd_dsql.add_bind(l_parameter_10);
      END IF;

    ELSIF P_SYS_LTR_CODE = 'ADACKMT' THEN
      IF p_parameter_1 IS NOT NULL THEN
        fnd_dsql.add_text(' 1=1 ' );
      ELSE
        fnd_dsql.add_text(' acad_cal_type = ');
        fnd_dsql.add_bind(l_acad_cal_type);
        fnd_dsql.add_text(' AND acad_ci_sequence_number = ');
        fnd_dsql.add_bind(l_acad_ci_sequence_number);
        fnd_dsql.add_text(' AND adm_cal_type = ');
        fnd_dsql.add_bind(l_adm_cal_type);
        fnd_dsql.add_text(' AND adm_ci_sequence_number = ');
        fnd_dsql.add_bind(l_adm_ci_sequence_number);
        fnd_dsql.add_text(' AND adm_process_cat = ');
        fnd_dsql.add_bind(p_parameter_4);
        fnd_dsql.add_text(' AND TRUNC(appl_dt) >= TRUNC(igs_ge_date.igsdate(');
        fnd_dsql.add_bind(p_parameter_5);
        fnd_dsql.add_text(')) AND TRUNC(appl_dt) <= TRUNC(igs_ge_date.igsdate(');
        fnd_dsql.add_bind(p_parameter_6);
        fnd_dsql.add_text('))');
      END IF;
    ELSIF P_SYS_LTR_CODE = 'ADRESID' THEN
      IF p_parameter_1 IS NOT NULL THEN
        fnd_dsql.add_text(' 1=1 ' );
      ELSE
        fnd_dsql.add_text(' residency_status_cd = ');
        fnd_dsql.add_bind(p_parameter_2);
        fnd_dsql.add_text(' AND residency_class_cd = ');
        fnd_dsql.add_bind(p_parameter_3);
        fnd_dsql.add_text(' AND TRUNC(evaluation_date) >= TRUNC(igs_ge_date.igsdate( ');
        fnd_dsql.add_bind(p_parameter_4);
        fnd_dsql.add_text(')) AND  TRUNC(evaluation_date) <= TRUNC(igs_ge_date.igsdate( ');
        fnd_dsql.add_bind(p_parameter_5);
        fnd_dsql.add_text('))');
      END IF;
    ELSIF P_SYS_LTR_CODE = 'ADACCEP' THEN
      IF p_parameter_1 IS NOT NULL THEN
        fnd_dsql.add_text(' 1=1 ' );
      ELSE
        fnd_dsql.add_text(' acad_cal_type = ');
        fnd_dsql.add_bind(l_acad_cal_type);
        fnd_dsql.add_text(' AND acad_ci_sequence_number = ');
        fnd_dsql.add_bind(l_acad_ci_sequence_number);
        fnd_dsql.add_text(' AND adm_cal_type = ');
        fnd_dsql.add_bind(l_adm_cal_type);
        fnd_dsql.add_text(' AND adm_ci_sequence_number = ');
        fnd_dsql.add_bind(l_adm_ci_sequence_number);
        fnd_dsql.add_text(' AND admission_process_category = ');
        fnd_dsql.add_bind(p_parameter_4);
        fnd_dsql.add_text(' AND TRUNC(appl_dt) >= TRUNC(igs_ge_date.igsdate(');
        fnd_dsql.add_bind(p_parameter_5);
        fnd_dsql.add_text(' )) AND TRUNC(appl_dt) <= TRUNC(igs_ge_date.igsdate(');
        fnd_dsql.add_bind(p_parameter_6);
        fnd_dsql.add_text(' )) AND admission_outcome_status = ');
        fnd_dsql.add_bind(p_parameter_7);
      END IF;

    ELSIF P_SYS_LTR_CODE = 'ADREJEC' THEN
      IF p_parameter_1 IS NOT NULL THEN
        fnd_dsql.add_text(' 1=1 ' );
      ELSE
        fnd_dsql.add_text(' acad_cal_type = ');
        fnd_dsql.add_bind(l_acad_cal_type);
        fnd_dsql.add_text(' AND acad_ci_sequence_number = ');
        fnd_dsql.add_bind(l_acad_ci_sequence_number);
        fnd_dsql.add_text(' AND adm_cal_type = ');
        fnd_dsql.add_bind(l_adm_cal_type);
        fnd_dsql.add_text(' AND adm_ci_sequence_number = ');
        fnd_dsql.add_bind(l_adm_ci_sequence_number);
        fnd_dsql.add_text(' AND admission_process_category = ');
        fnd_dsql.add_bind(p_parameter_4);
        fnd_dsql.add_text(' AND TRUNC(appl_dt) >= TRUNC(igs_ge_date.igsdate( ');
        fnd_dsql.add_bind(p_parameter_5);
        fnd_dsql.add_text(')) AND TRUNC(appl_dt) <= TRUNC(igs_ge_date.igsdate( ');
        fnd_dsql.add_bind(p_parameter_6);
        fnd_dsql.add_text(')) AND admission_outcome_status = ');
        fnd_dsql.add_bind(p_parameter_7);
      END IF;
    ELSIF P_SYS_LTR_CODE = 'ADWAITL' THEN
      IF p_parameter_1 IS NOT NULL THEN
        fnd_dsql.add_text(' 1=1 ' );
      ELSE
        fnd_dsql.add_text(' acad_cal_type = ');
        fnd_dsql.add_bind(l_acad_cal_type);
        fnd_dsql.add_text(' AND acad_ci_sequence_number = ');
        fnd_dsql.add_bind(l_acad_ci_sequence_number);
        fnd_dsql.add_text(' AND adm_cal_type = ');
        fnd_dsql.add_bind(l_adm_cal_type);
        fnd_dsql.add_text(' AND adm_ci_sequence_number = ');
        fnd_dsql.add_bind(l_adm_ci_sequence_number);
        fnd_dsql.add_text(' AND admission_process_category = ');
        fnd_dsql.add_bind(p_parameter_4);
        fnd_dsql.add_text(' AND TRUNC(appl_dt) >= TRUNC(igs_ge_date.igsdate(');
        fnd_dsql.add_bind(p_parameter_5);
        fnd_dsql.add_text(' )) AND TRUNC(appl_dt) <= TRUNC(igs_ge_date.igsdate(');
        fnd_dsql.add_bind(p_parameter_6);
        fnd_dsql.add_text(' )) AND admission_outcome_status = ');
        fnd_dsql.add_bind(p_parameter_7);
      END IF;
    ELSIF P_SYS_LTR_CODE = 'ADNOQUT' THEN
      IF p_parameter_1 IS NOT NULL THEN
        fnd_dsql.add_text(' 1=1 ' );
      ELSE
        fnd_dsql.add_text(' acad_cal_type = ');
        fnd_dsql.add_bind(l_acad_cal_type);
        fnd_dsql.add_text(' AND acad_ci_sequence_number = ');
        fnd_dsql.add_bind(l_acad_ci_sequence_number);
        fnd_dsql.add_text(' AND adm_cal_type = ');
        fnd_dsql.add_bind(l_adm_cal_type);
        fnd_dsql.add_text(' AND adm_ci_sequence_number = ');
        fnd_dsql.add_bind(l_adm_ci_sequence_number);
        fnd_dsql.add_text(' AND admission_process_category = ');
        fnd_dsql.add_bind(p_parameter_4);
        fnd_dsql.add_text(' AND TRUNC(appl_dt) >= TRUNC(igs_ge_date.igsdate(');
        fnd_dsql.add_bind(p_parameter_5);
        fnd_dsql.add_text(' )) AND TRUNC(appl_dt) <= TRUNC(igs_ge_date.igsdate(');
        fnd_dsql.add_bind(p_parameter_6);
        fnd_dsql.add_text(' )) AND admission_outcome_status = ');
        fnd_dsql.add_bind(p_parameter_7);
      END IF;
    ELSIF P_SYS_LTR_CODE = 'ADCONOF' THEN
      IF p_parameter_1 IS NOT NULL THEN
        fnd_dsql.add_text(' 1=1 ' );
      ELSE
        fnd_dsql.add_text(' acad_cal_type = ');
        fnd_dsql.add_bind(l_acad_cal_type);
        fnd_dsql.add_text(' AND acad_ci_sequence_number = ');
        fnd_dsql.add_bind(l_acad_ci_sequence_number);
        fnd_dsql.add_text(' AND adm_cal_type = ');
        fnd_dsql.add_bind(l_adm_cal_type);
        fnd_dsql.add_text(' AND adm_ci_sequence_number = ');
        fnd_dsql.add_bind(l_adm_ci_sequence_number);
        fnd_dsql.add_text(' AND admission_process_category = ');
        fnd_dsql.add_bind(p_parameter_4);
        fnd_dsql.add_text(' AND TRUNC(appl_dt) >= TRUNC(igs_ge_date.igsdate(');
        fnd_dsql.add_bind(p_parameter_5);
        fnd_dsql.add_text(' )) AND TRUNC(appl_dt) <= TRUNC(igs_ge_date.igsdate(');
        fnd_dsql.add_bind(p_parameter_6);
        fnd_dsql.add_text(' )) AND admission_outcome_status = ');
        fnd_dsql.add_bind(p_parameter_7);
      END IF;
    ELSIF P_SYS_LTR_CODE = 'ADPADMS' THEN
      IF p_parameter_1 IS NOT NULL THEN
        fnd_dsql.add_text(' 1=1 ' );
      ELSE
        fnd_dsql.add_text(' acad_cal_type = ');
        fnd_dsql.add_bind(l_acad_cal_type);
        fnd_dsql.add_text(' AND acad_ci_sequence_number = ');
        fnd_dsql.add_bind(l_acad_ci_sequence_number);
        fnd_dsql.add_text(' AND adm_cal_type = ');
        fnd_dsql.add_bind(l_adm_cal_type);
        fnd_dsql.add_text(' AND adm_ci_sequence_number = ');
        fnd_dsql.add_bind(l_adm_ci_sequence_number);
        fnd_dsql.add_text(' AND adm_process_cat = ');
        fnd_dsql.add_bind(p_parameter_4);
        fnd_dsql.add_text(' AND adm_doc_status = ');
        fnd_dsql.add_bind(p_parameter_5);
        fnd_dsql.add_text(' AND org_unit_cd = ');
        fnd_dsql.add_bind(p_parameter_6);
        fnd_dsql.add_text(' AND person_id = ');
        fnd_dsql.add_bind(l_parameter_7);
        fnd_dsql.add_text(' AND adm_appl_number = ');
        fnd_dsql.add_bind(l_parameter_8);
        fnd_dsql.add_text(' AND nominated_course_cd = ');
        fnd_dsql.add_bind(l_parameter_9);
        fnd_dsql.add_text(' AND appl_sequence_number = ');
        fnd_dsql.add_bind(l_parameter_10);
      END IF;
    ELSIF P_SYS_LTR_CODE = 'ADFUTSE' THEN
      IF p_parameter_1 IS NOT NULL THEN
        fnd_dsql.add_text(' 1=1 ' );
      ELSE
        fnd_dsql.add_text(' acad_cal_type = ');
        fnd_dsql.add_bind(l_acad_cal_type);
        fnd_dsql.add_text(' AND acad_ci_sequence_number = ');
        fnd_dsql.add_bind(l_acad_ci_sequence_number);
        fnd_dsql.add_text(' AND adm_cal_type = ');
        fnd_dsql.add_bind(l_adm_cal_type);
        fnd_dsql.add_text(' AND adm_ci_sequence_number = ');
        fnd_dsql.add_bind(l_adm_ci_sequence_number);
        fnd_dsql.add_text(' AND admission_process_category = ');
        fnd_dsql.add_bind(p_parameter_4);
        fnd_dsql.add_text(' AND TRUNC(appl_dt) >= TRUNC(igs_ge_date.igsdate(');
        fnd_dsql.add_bind(p_parameter_5);
        fnd_dsql.add_text(' )) AND TRUNC(appl_dt) <= TRUNC(igs_ge_date.igsdate(');
        fnd_dsql.add_bind(p_parameter_6);
        fnd_dsql.add_text(' )) AND admission_outcome_status = ');
        fnd_dsql.add_bind(p_parameter_7);
      END IF;
    ELSIF P_SYS_LTR_CODE = 'ADMFTSA' THEN
      IF p_parameter_1 IS NOT NULL THEN
        fnd_dsql.add_text(' 1=1 ' );
      ELSE
        fnd_dsql.add_text(' acad_cal_type = ');
        fnd_dsql.add_bind(l_acad_cal_type);
        fnd_dsql.add_text(' AND acad_ci_sequence_number = ');
        fnd_dsql.add_bind(l_acad_ci_sequence_number);
        fnd_dsql.add_text(' AND adm_cal_type = ');
        fnd_dsql.add_bind(l_adm_cal_type);
        fnd_dsql.add_text(' AND adm_ci_sequence_number = ');
        fnd_dsql.add_bind(l_adm_ci_sequence_number);
        fnd_dsql.add_text(' AND admission_process_category = ');
        fnd_dsql.add_bind(p_parameter_4);
        fnd_dsql.add_text(' AND TRUNC(appl_dt) >= TRUNC(igs_ge_date.igsdate(');
        fnd_dsql.add_bind(p_parameter_5);
        fnd_dsql.add_text(' )) AND TRUNC(appl_dt) <= TRUNC(igs_ge_date.igsdate(');
        fnd_dsql.add_bind(p_parameter_6);
        fnd_dsql.add_text(' )) AND admission_outcome_status = ');
        fnd_dsql.add_bind(p_parameter_7);
      END IF;
    ELSIF P_SYS_LTR_CODE = 'ADNORSP' THEN
      IF p_parameter_1 IS NOT NULL THEN
      -- person id group if dynamic will not be available.
      -- all persons in the group already resolved in the build_sql
        fnd_dsql.add_text(' 1=1');
      ELSE
        --** proc level logging.
        IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

            l_label := 'igs.plsql.igs_co_process.corp_get_parameter_value';
            l_debug_str := 'p_parameter_1 is NULL ';
	    l_debug_str := l_debug_str ||' p_parameter_7 :'||p_parameter_7;
	    l_debug_str := l_debug_str ||' p_parameter_8 :'||p_parameter_8;
	    l_debug_str := l_debug_str ||' p_parameter_9 :'||p_parameter_9;

            fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
        END IF;
        --**
        fnd_dsql.add_text(' acad_cal_type = ');
        fnd_dsql.add_bind(l_acad_cal_type);
        fnd_dsql.add_text(' AND acad_ci_sequence_number = ');
        fnd_dsql.add_bind(l_acad_ci_sequence_number);
        fnd_dsql.add_text(' AND adm_cal_type = ');
        fnd_dsql.add_bind(l_adm_cal_type);
        fnd_dsql.add_text(' AND adm_ci_sequence_number = ');
        fnd_dsql.add_bind(l_adm_ci_sequence_number);
        fnd_dsql.add_text(' AND admission_process_category = ');
        fnd_dsql.add_bind(p_parameter_4);
        fnd_dsql.add_text(' AND course_cd = ');
        fnd_dsql.add_bind(p_parameter_5);
        fnd_dsql.add_text(' AND location_cd = ');
        fnd_dsql.add_bind(p_parameter_6);
        fnd_dsql.add_text(' AND attendance_mode = ');
        fnd_dsql.add_bind(p_parameter_7);
        fnd_dsql.add_text(' AND attendance_type=');
        fnd_dsql.add_bind(p_parameter_9);
      END IF;
    ELSIF P_SYS_LTR_CODE = 'ADINTRW' THEN
      IF p_parameter_1 IS NOT NULL THEN
      -- person id group if dynamic will not be available.
      -- all persons in the group already resolved in the build_sql
        fnd_dsql.add_text(' 1=1');
      ELSE
        fnd_dsql.add_text(' acad_cal_type = ');
        fnd_dsql.add_bind(l_acad_cal_type);
        fnd_dsql.add_text(' AND acad_ci_sequence_number = ');
        fnd_dsql.add_bind(l_acad_ci_sequence_number);
        fnd_dsql.add_text(' AND adm_cal_type = ');
        fnd_dsql.add_bind(l_adm_cal_type);
        fnd_dsql.add_text(' AND adm_ci_sequence_number =');
        fnd_dsql.add_bind(l_adm_ci_sequence_number);
        fnd_dsql.add_text(' AND admission_process_category =');
        fnd_dsql.add_bind(p_parameter_4);
        fnd_dsql.add_text(' AND panel_code= ');
        fnd_dsql.add_bind(p_parameter_5);
        fnd_dsql.add_text(' AND TRUNC(interview_date) = TRUNC(igs_ge_date.igsdate(');
        fnd_dsql.add_bind(p_parameter_6);
        fnd_dsql.add_text(' )) AND attendance_mode= ');
        fnd_dsql.add_bind(p_parameter_7);
        fnd_dsql.add_text(' AND attendance_type= ');
        fnd_dsql.add_bind(p_parameter_9);
        fnd_dsql.add_text(' AND interview_date > SYSDATE');
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGS_CO_PROCESS.corp_get_parameter_value');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END corp_get_parameter_value;

  PROCEDURE corp_check_request_status(
    errbuf              OUT NOCOPY      VARCHAR2,
    retcode             OUT NOCOPY      NUMBER,
    p_person_id         IN       NUMBER ,
    p_document_id       IN       NUMBER ,
    p_application_id    IN       NUMBER ,
    p_course_cd         IN       VARCHAR2,
    p_adm_seq_no        IN       NUMBER  ,
    p_awd_cal_type      IN       VARCHAR2,
    p_awd_seq_no        IN       NUMBER ,
    p_elapsed_days      IN       NUMBER ,
    p_no_of_repeats     IN       NUMBER ,
    p_sys_ltr_code      IN       VARCHAR2
  ) AS
  /*************************************************************
  Created By :Nalin Kumar
  Date Created on : 05-Feb-2002
  Purpose : This procedure will check the request status in OSS Interaction Table
            against CRM Interaction History and update the OSS Interaction table.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
      Bayadav         24-MAY-2002     Included two system letter codes 'ENADHOC', 'SFADHOC' for adhoc letters as a part of bug 2376434
      kpadiyar        18-NOV-2002     Removed the calls to the igs_co_interac_hist_pkg.update_row as the only column being updated was the outcome_status column
                                      and as this column has been obsoleted all the relevant calls to the update row have been removed.
     gmaheswa	5-Jan-2004	Bug 4869737 Added a call to SET_ORG_ID to disable OSS for R12.
  ***************************************************************/
    CURSOR c_crm_id(cp_request_id NUMBER) IS
    SELECT outcome_code --INTO l_request_status
    FROM jtf_fm_request_history
    WHERE hist_req_id = TO_NUMBER(cp_request_id);
    l_c_crm_id  c_crm_id%ROWTYPE;

    CURSOR cur_int_hist(cp_request_id NUMBER) IS
    SELECT hist.rowid row_id, hist.*
    FROM igs_co_interac_hist hist
    WHERE request_id = TO_NUMBER(cp_request_id);
    l_cur_int_hist cur_int_hist%ROWTYPE;

    CURSOR cur_gen_update IS
    SELECT request_id,
           comp_status
    FROM igs_co_interaction_history_v
    WHERE comp_status  IN ('SUBMITTED'); --Modified by Prajeesh to change NOT IN to IN as it will never change SUBMITED TO OTHER
                                         --STATE if it is NOT IN operator
    l_cur_gen_update cur_gen_update%ROWTYPE;
    l_called_from_conc VARCHAR2(1);
  BEGIN
    igs_ge_gen_003.set_org_id;

    l_called_from_conc := 'N';
    IF  p_person_id IS NULL AND
      (p_application_id IS NULL AND p_adm_seq_no IS NULL AND p_course_cd IS NULL) AND
      (p_awd_cal_type IS NULL AND p_awd_seq_no IS NULL) THEN
      --
      --  Update the status for all the records.
      --
      retcode := 0;
      l_called_from_conc := 'Y';
      OPEN cur_gen_update;
      LOOP
        FETCH cur_gen_update INTO l_cur_gen_update;
  IF cur_gen_update%FOUND THEN
          OPEN c_crm_id (l_cur_gen_update.request_id);
    LOOP
    FETCH c_crm_id INTO l_c_crm_id;
    IF c_crm_id%FOUND THEN
            IF l_cur_gen_update.comp_status <> l_c_crm_id.outcome_code  THEN
        OPEN cur_int_hist(l_cur_gen_update.request_id);
        FETCH cur_int_hist INTO l_cur_int_hist;
        --Modified by Prajeesh on 23-apr-2002 as the disbursement update was happening before the
        --letter is actually picked up the fulfilment server of CRM. Thus it will always fail to
        -- pick up the record and hence gives an error. This is solved by initially not updating the status
        -- and next time when run update the status at the intiaial if it successfully sent by CRM Server.
        IF l_cur_int_hist.sys_ltr_code='FADISBT' AND l_c_crm_id.outcome_code='SUCCESS' THEN
           igf_aw_gen_004.loan_disbursement_update(
                          p_person_id     =>   l_cur_int_hist.student_id,
                          p_award_year    =>   RPAD(l_cur_int_hist.cal_type,10)||to_char(l_cur_int_hist.ci_sequence_number,'999999')
                                      );
        END IF;
        CLOSE cur_int_hist;
      END IF;
    ELSE
        EXIT WHEN c_crm_id%NOTFOUND;
    END IF;
    END LOOP;
          CLOSE c_crm_id;
        ELSE
     EXIT WHEN cur_gen_update%NOTFOUND;
  END IF;
      END LOOP;
      CLOSE cur_gen_update;

   END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF l_called_from_conc = 'Y' THEN
        ROLLBACK;
        RETCODE:=2;
        ERRBUF:= Fnd_Message.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
        Igs_Ge_Msg_Stack.CONC_EXCEPTION_HNDL;
      ELSE
        Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_CO_PROCESS.corp_check_request_status');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
 END corp_check_request_status;

 PROCEDURE corp_validate_parameters(
    p_sys_ltr_code      IN       VARCHAR2,
    p_document_id       IN       NUMBER,
    p_select_type       IN       VARCHAR2,
    p_list_id           IN       NUMBER  ,
    p_person_id         IN       NUMBER  ,
    p_parameter_1       IN       VARCHAR2,
    p_parameter_2       IN       VARCHAR2,
    p_parameter_3       IN       VARCHAR2,
    p_parameter_4       IN       VARCHAR2,
    p_parameter_5       IN       VARCHAR2,
    p_parameter_6       IN       VARCHAR2,
    p_parameter_7       IN       VARCHAR2,
    p_parameter_8       IN       VARCHAR2,
    p_parameter_9       IN       VARCHAR2,
    p_override_flag     IN       VARCHAR2,
    p_delivery_type     IN       VARCHAR2,
    p_exception         OUT NOCOPY       VARCHAR2
  ) AS
  /*************************************************************
  Created By :Nalin Kumar
  Date Created on : 05-Feb-2002
  Purpose : This procedure will return true or false based on the validation.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
    l_error_flag VARCHAR2(10);
    l_all_not_null VARCHAR2(20);
    l_all_null VARCHAR2(20);
  BEGIN

  --**  proc level logging.
        IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
            l_label := 'igs.plsql.igs_co_process.corp_validate_parameters';
            l_debug_str :=  'Entering corp_validate_parameters. values are:';
	    l_debug_str := l_debug_str || 'p_sys_ltr_code=' ||   p_sys_ltr_code;
            l_debug_str := l_debug_str || ',p_document_id=' ||  p_document_id     ;
	    l_debug_str := l_debug_str || ',p_select_type=' ||  p_select_type     ;
	    l_debug_str := l_debug_str || ',p_list_id=' ||  p_list_id     ;
	    l_debug_str := l_debug_str || ',p_person_id=' ||  p_person_id     ;
	    l_debug_str := l_debug_str || ',p_parameter_1=' ||  p_parameter_1     ;
	    l_debug_str := l_debug_str || ',p_parameter_2=' ||  p_parameter_2     ;
	    l_debug_str := l_debug_str || ',p_parameter_3=' ||  p_parameter_3     ;
	    l_debug_str := l_debug_str || ',p_parameter_4=' ||  p_parameter_4     ;
	    l_debug_str := l_debug_str || ',p_parameter_5=' ||  p_parameter_5     ;
	    l_debug_str := l_debug_str || ',p_parameter_6=' ||  p_parameter_6     ;
	    l_debug_str := l_debug_str || ',p_parameter_7=' ||  p_parameter_7     ;
	    l_debug_str := l_debug_str || ',p_parameter_8=' ||  p_parameter_8     ;
	    l_debug_str := l_debug_str || ',p_parameter_9=' ||  p_parameter_9     ;
	    l_debug_str := l_debug_str || ',p_override_flag=' ||  p_override_flag     ;
	    l_debug_str := l_debug_str || ',p_delivery_type=' ||  p_delivery_type     ;
            fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
         END IF;
     --**

    l_error_flag := 'FALSE';
    l_all_not_null := 'FALSE';
    l_all_null := 'FALSE';
    p_exception := 'N';
    IF p_select_type = 'L' THEN
      IF p_sys_ltr_code = 'ADINTRW' THEN
        IF p_list_id IS NULL OR
        p_parameter_1 IS NOT NULL OR p_parameter_2 IS NOT NULL OR p_parameter_3 IS NOT NULL OR
        p_parameter_4 IS NOT NULL OR p_parameter_6 IS NOT NULL OR p_parameter_7 IS NOT NULL OR
        p_parameter_9 IS NOT NULL OR p_person_id   IS NOT NULL THEN
      p_exception := 'Y';
      fnd_message.set_name('IGS','IGS_CO_LIST_PRAM');
      fnd_file.put_line(fnd_file.log,fnd_message.get());
      fnd_file.put_line(FND_FILE.LOG,' ');
      --**  proc level logging.
        IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
            l_label := 'igs.plsql.igs_co_process.corp_validate_parameters';
            l_debug_str :=  'Exiting corp_validate_parameters. values are: ';
	    l_debug_str := l_debug_str || 'p_select_type is L and p_sys_ltr_code is ADINTRW';
	    fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
         END IF;
     --**
        RETURN;
        END IF;
     ELSIF p_sys_ltr_code = 'ADNORSP' THEN
       IF p_list_id IS NULL OR
        p_parameter_1 IS NOT NULL OR p_parameter_2 IS NOT NULL OR p_parameter_3 IS NOT NULL OR
        p_parameter_4 IS NOT NULL OR p_parameter_5 IS NOT NULL OR p_parameter_6 IS NOT NULL OR
        p_parameter_7 IS NOT NULL OR p_parameter_9 IS NOT NULL OR p_person_id   IS NOT NULL THEN
    --As letter has been submitted with select type as List
    --Only List Name should be specified
      p_exception := 'Y';
      fnd_message.set_name('IGS','IGS_CO_LIST_PRAM');
      fnd_file.put_line(fnd_file.log,fnd_message.get());
      fnd_file.put_line(FND_FILE.LOG,' ');
      --**  proc level logging.
        IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
            l_label := 'igs.plsql.igs_co_process.corp_validate_parameters';
            l_debug_str :=  'Exiting corp_validate_parameters. values are: ';
	    l_debug_str := l_debug_str || 'p_select_type is L and p_sys_ltr_code is ADNORSP';
            fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
         END IF;
     --**
      RETURN;
      END IF;
     ELSE
      IF p_list_id IS NULL OR
        p_parameter_1 IS NOT NULL OR p_parameter_2 IS NOT NULL OR p_parameter_3 IS NOT NULL OR
        p_parameter_4 IS NOT NULL OR p_parameter_5 IS NOT NULL OR p_parameter_6 IS NOT NULL OR
        p_parameter_7 IS NOT NULL OR p_person_id   IS NOT NULL THEN
  --
    --As letter has been submitted with select type as List
    --Only List Name should be specified
  --
      p_exception := 'Y';
      fnd_message.set_name('IGS','IGS_CO_LIST_PRAM');
      fnd_file.put_line(fnd_file.log,fnd_message.get());
      fnd_file.put_line(FND_FILE.LOG,' ');
      --**  proc level logging.
        IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
            l_label := 'igs.plsql.igs_co_process.corp_validate_parameters';
            l_debug_str :=  'Exiting corp_validate_parameters as p_select_type is L, none of the nested if condition is satisfied and ';
	    l_debug_str := l_debug_str || 'p_list_id is NULL or one of the parameters 1 to 7 is NOT NULL or person id is NOT null';
            fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
         END IF;
     --**
      RETURN;
      END IF;
     END IF;

    ELSIF p_select_type = 'S' THEN
      IF p_sys_ltr_code = 'ADINTRW' THEN
        IF p_person_id IS NULL OR
        p_parameter_1 IS NOT NULL OR p_parameter_2 IS NOT NULL OR p_parameter_3 IS NOT NULL OR
        p_parameter_4 IS NOT NULL OR p_parameter_6 IS NOT NULL OR p_parameter_7 IS NOT NULL OR
        p_parameter_9 IS NOT NULL THEN
        p_exception := 'Y';

  fnd_message.set_name('IGS','IGS_CO_STUD_PRAM');
        fnd_file.put_line(fnd_file.log,fnd_message.get());
        fnd_file.put_line(FND_FILE.LOG,' ');
	--**  proc level logging.
        IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
            l_label := 'igs.plsql.igs_co_process.corp_validate_parameters';
            l_debug_str :=  'Exiting corp_validate_parameters. values: ';
	    l_debug_str := l_debug_str || 'p_select_type is S and p_sys_ltr_code is ADINTRW';
	    fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
         END IF;
     --**
        RETURN;
        END IF;    -- p_person_id
      ELSIF p_sys_ltr_code = 'ADNORSP' THEN
        IF p_person_id IS NULL OR
        p_parameter_1 IS NOT NULL OR p_parameter_2 IS NOT NULL OR p_parameter_3 IS NOT NULL OR
        p_parameter_4 IS NOT NULL OR p_parameter_5 IS NOT NULL OR p_parameter_6 IS NOT NULL OR
        p_parameter_7 IS NOT NULL OR p_parameter_9 IS NOT NULL THEN
        --As letter has been submitted with select type as List
        --Only List Name should be specified
        p_exception := 'Y';
        fnd_message.set_name('IGS','IGS_CO_STUD_PRAM');
        fnd_file.put_line(fnd_file.log,fnd_message.get());
        fnd_file.put_line(FND_FILE.LOG,' ');
	--**  proc level logging.
        IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
            l_label := 'igs.plsql.igs_co_process.corp_validate_parameters';
            l_debug_str :=  'Exiting corp_validate_parameters. values: ';
	    l_debug_str := l_debug_str || 'p_select_type is S and p_sys_ltr_code is ADNORSP';
	    fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
         END IF;
     --**
        RETURN;
        END IF;   -- p_person_id
      ELSE

        IF p_person_id IS NULL OR
        p_parameter_1 IS NOT NULL OR p_parameter_2 IS NOT NULL OR p_parameter_3 IS NOT NULL OR
        p_parameter_4 IS NOT NULL OR p_parameter_5 IS NOT NULL OR p_parameter_6 IS NOT NULL OR
        p_parameter_7 IS NOT NULL OR
  p_list_id   IS NOT NULL THEN


          p_exception := 'Y';
          fnd_message.set_name('IGS','IGS_CO_STUD_PRAM');
          fnd_file.put_line(fnd_file.log,fnd_message.get());
          fnd_file.put_line(FND_FILE.LOG,' ');
	  --**  proc level logging.
        IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
            l_label := 'igs.plsql.igs_co_process.corp_validate_parameters';
            l_debug_str :=  'Exiting corp_validate_parameters as p_select_type is S, none of the nested if condition is satisfied and ';
	    l_debug_str := l_debug_str || 'p_list_id is NOT NULL or one of the parameters 1 to 7 is NOT NULL or person id is null';
            fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
         END IF;
     --**
          RETURN;
        END IF;  -- p_person_id IS NULL
      END IF;  -- p_select_type = S

    ELSIF p_select_type = 'P' THEN
      IF p_parameter_1 IS NOT NULL THEN
        IF p_sys_ltr_code IN ('ADINTRW','ADNORSP') THEN
          IF    (p_parameter_2 IS NULL AND p_parameter_3 IS NULL AND p_parameter_4 IS NULL AND
           p_parameter_6 IS NULL AND p_parameter_7 IS NULL AND p_parameter_9 IS NULL) THEN
           l_all_null := 'TRUE';
    ELSIF (p_parameter_2 IS NOT NULL AND p_parameter_3 IS NOT NULL AND p_parameter_4 IS NOT NULL AND
           p_parameter_5 IS NOT NULL AND p_parameter_6 IS NOT NULL AND p_parameter_7 IS NOT NULL AND
           p_parameter_8 IS NOT NULL AND p_parameter_9 IS NOT NULL) THEN
           l_all_not_null := 'TRUE';
          END IF;
          IF NOT( l_all_null = 'TRUE' OR l_all_not_null = 'TRUE') THEN
            p_exception := 'Y';
            fnd_message.set_name('IGS','IGS_AD_INVALID_PARAM_COMB');
            fnd_file.put_line(fnd_file.log,fnd_message.get());
            fnd_file.put_line(FND_FILE.LOG,' ');
	    --**  proc level logging.
        IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
            l_label := 'igs.plsql.igs_co_process.corp_validate_parameters';
            l_debug_str :=  'Exiting corp_validate_parameters. values: ';
	    l_debug_str := l_debug_str || 'p_select_type is P';
	    fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
         END IF;
     --**
            RETURN;
          END IF;
        ELSE  --for all other letters
          IF p_parameter_2 IS NOT NULL OR
          p_parameter_3 IS NOT NULL OR
          p_parameter_4 IS NOT NULL OR
          p_parameter_5 IS NOT NULL OR
          p_parameter_6 IS NOT NULL OR
          p_parameter_7 IS NOT NULL OR
      p_person_id IS NOT NULL OR
    p_list_id IS NOT NULL THEN
        --
          -- As letter has been submitted with select type as Parameter
          -- either Person ID Group or other parameters should be selected. Both cannot be specified.
        --
          p_exception := 'Y';
          fnd_message.set_name('IGS','IGS_AD_INVALID_PARAM_COMB');
          fnd_file.put_line(fnd_file.log,fnd_message.get());
          fnd_file.put_line(FND_FILE.LOG,' ');
	  --**  proc level logging.
        IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
            l_label := 'igs.plsql.igs_co_process.corp_validate_parameters';
            l_debug_str :=  'Exiting corp_validate_parameters for p_select_type P and all other values as none of the if conditions are satisfied.';
	    fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
         END IF;
     --**
          RETURN;
        END IF;
        END IF; -- p_sys_ltr_code IN ('ADINTRW','ADNORSP')
    END IF; -- selection type Parameter.

-- again checking that if Parameter_1 (person_id_group) is NULL then all other params should be
-- specified.
      IF p_parameter_1 IS NULL THEN

        IF p_sys_ltr_code = 'ADMISTM' AND
            (p_parameter_2 IS NULL OR p_parameter_3 IS NULL OR p_parameter_4 IS NULL OR p_parameter_5 IS NULL OR
             p_parameter_6 IS NULL OR p_parameter_8 IS NULL) THEN
             l_error_flag := 'TRUE';
        ELSIF p_sys_ltr_code = 'ADACKMT' AND
           (p_parameter_2 IS NULL OR p_parameter_3 IS NULL OR p_parameter_4 IS NULL OR p_parameter_5 IS NULL OR
            p_parameter_6 IS NULL) THEN
            l_error_flag := 'TRUE';
        ELSIF p_sys_ltr_code = 'ADRESID' AND
            (p_parameter_2 IS NULL OR  p_parameter_3 IS NULL OR p_parameter_4 IS NULL OR p_parameter_5 IS NULL) THEN
            l_error_flag := 'TRUE';
        ELSIF p_sys_ltr_code = 'ADACCEP' AND
            (p_parameter_2 IS NULL OR p_parameter_3 IS NULL OR p_parameter_4 IS NULL OR p_parameter_5 IS NULL OR
             p_parameter_6 IS NULL OR p_parameter_7 IS NULL) THEN
             l_error_flag := 'TRUE';
        ELSIF p_sys_ltr_code = 'ADREJEC' AND
          (p_parameter_2 IS NULL OR p_parameter_3 IS NULL OR p_parameter_4 IS NULL OR p_parameter_5 IS NULL OR
           p_parameter_6 IS NULL OR p_parameter_7 IS NULL) THEN
           l_error_flag := 'TRUE';
        ELSIF p_sys_ltr_code = 'ADWAITL' AND
          (p_parameter_2 IS NULL OR p_parameter_3 IS NULL OR p_parameter_4 IS NULL OR p_parameter_5 IS NULL OR
          p_parameter_6 IS NULL OR p_parameter_7 IS NULL) THEN
          l_error_flag := 'TRUE';
        ELSIF p_sys_ltr_code = 'ADNOQUT' AND
          (p_parameter_2 IS NULL OR p_parameter_3 IS NULL OR p_parameter_4 IS NULL OR p_parameter_5 IS NULL OR
          p_parameter_6 IS NULL OR p_parameter_7 IS NULL) THEN
          l_error_flag := 'TRUE';
        ELSIF p_sys_ltr_code = 'ADCONOF' AND
          (p_parameter_2 IS NULL OR p_parameter_3 IS NULL OR p_parameter_4 IS NULL OR p_parameter_5 IS NULL OR
          p_parameter_6 IS NULL OR p_parameter_7 IS NULL) THEN
          l_error_flag := 'TRUE';
        ELSIF p_sys_ltr_code = 'ADPADMS' AND
          (p_parameter_2 IS NULL OR p_parameter_3 IS NULL OR p_parameter_4 IS NULL OR p_parameter_5 IS NULL OR
          p_parameter_6 IS NULL OR p_parameter_8 IS NULL) THEN
          l_error_flag := 'TRUE';
        ELSIF p_sys_ltr_code = 'ADFUTSE' AND
          (p_parameter_2 IS NULL OR p_parameter_3 IS NULL OR p_parameter_4 IS NULL OR p_parameter_5 IS NULL OR
          p_parameter_6 IS NULL OR p_parameter_7 IS NULL) THEN
          l_error_flag := 'TRUE';
        ELSIF p_sys_ltr_code = 'ADMFTSA' AND
          (p_parameter_2 IS NULL OR p_parameter_3 IS NULL OR p_parameter_4 IS NULL OR p_parameter_5 IS NULL OR
          p_parameter_6 IS NULL OR p_parameter_7 IS NULL) THEN
          l_error_flag := 'TRUE';
         ELSIF p_sys_ltr_code = 'ADNORSP' AND
          (p_parameter_2 IS NULL OR p_parameter_3 IS NULL OR p_parameter_4 IS NULL OR p_parameter_5 IS NULL OR
           p_parameter_6 IS NULL OR p_parameter_7 IS NULL OR p_parameter_8 IS NULL OR p_parameter_9 IS NULL) THEN
           l_error_flag := 'TRUE';
        ELSIF p_sys_ltr_code = 'ADINTRW' AND
          (p_parameter_2 IS NULL OR p_parameter_3 IS NULL OR p_parameter_4 IS NULL OR p_parameter_5 IS NULL OR
           p_parameter_6 IS NULL OR p_parameter_7 IS NULL OR p_parameter_8 IS NULL OR p_parameter_9 IS NULL) THEN
           l_error_flag := 'TRUE';
        END IF;
      END IF;

    ELSIF p_select_type = 'G' THEN

      --check if p_parameter_1 (person_id_grp)  is null or not null.
      IF p_parameter_1 IS NOT NULL THEN
        IF p_sys_ltr_code = 'ADINTRW' THEN
          IF p_parameter_2 IS NOT NULL OR p_parameter_3 IS NOT NULL OR p_parameter_4 IS NOT NULL OR
       p_parameter_6 IS NOT NULL OR p_parameter_7 IS NOT NULL OR p_parameter_9 IS NOT NULL OR
             p_person_id IS NOT NULL OR p_list_id IS NOT NULL THEN
            --As letter has been submitted with select type as Group
            --Only Group Name should be specified
            p_exception := 'Y';
      fnd_message.set_name('IGS','IGS_CO_PER_LIS_PRAM');
            fnd_file.put_line(fnd_file.log,fnd_message.get());
            fnd_file.put_line(FND_FILE.LOG,' ');
	    --**  proc level logging.
        IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
            l_label := 'igs.plsql.igs_co_process.corp_validate_parameters';
            l_debug_str :=  'Exiting corp_validate_parameters. values: ';
	    l_debug_str := l_debug_str || 'p_select_type is G and p_sys_ltr_code is ADINTRW';
	    fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
         END IF;
     --**
            RETURN;
          END IF;
        ELSIF p_sys_ltr_code = 'ADNORSP' THEN
          IF p_parameter_2 IS NOT NULL OR p_parameter_3 IS NOT NULL OR
             p_parameter_4 IS NOT NULL OR p_parameter_5 IS NOT NULL OR p_parameter_6 IS NOT NULL OR
             p_parameter_7 IS NOT NULL OR p_parameter_9 IS NOT NULL OR
             p_person_id IS NOT NULL OR p_list_id IS NOT NULL THEN
             --As letter has been submitted with select type as Group
             --Only Group Name should be specified
             p_exception := 'Y';
             fnd_message.set_name('IGS','IGS_CO_PER_LIS_PRAM');
             fnd_file.put_line(fnd_file.log,fnd_message.get());
             fnd_file.put_line(FND_FILE.LOG,' ');
	        --**  proc level logging.
		IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
		    l_label := 'igs.plsql.igs_co_process.corp_validate_parameters';
		    l_debug_str :=  'Exiting corp_validate_parameters. values: ';
		    l_debug_str := l_debug_str || 'p_select_type is G and p_sys_ltr_code is ADNORSP';
		    fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
		 END IF;
	     --**
             RETURN;
          END IF;
        ELSE  -- for other letters.
          IF p_parameter_2 IS NOT NULL OR p_parameter_3 IS NOT NULL OR p_parameter_4 IS NOT NULL OR
       p_parameter_5 IS NOT NULL OR p_parameter_6 IS NOT NULL OR p_parameter_7 IS NOT NULL OR
             p_person_id IS NOT NULL OR
             p_list_id IS NOT NULL THEN
        --
              -- As letter has been submitted with select type as Parameter
              -- either Person ID Group or other parameters should be selected. Both cannot be specified.
        --
              p_exception := 'Y';
              fnd_message.set_name('IGS','IGS_CO_PER_LIS_PRAM');
              fnd_file.put_line(fnd_file.log,fnd_message.get());
              fnd_file.put_line(FND_FILE.LOG,' ');
	      --**  proc level logging.
		IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
		    l_label := 'igs.plsql.igs_co_process.corp_validate_parameters';
		    l_debug_str :=  'Exiting corp_validate_parameters. values: ';
		    l_debug_str := l_debug_str || 'p_select_type is G and all other letters';
		    fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
		 END IF;
	     --**
              RETURN;
        END IF;
        END IF;

      ELSIF p_parameter_1 IS NOT NULL AND (
      p_person_id IS NOT NULL OR
      p_list_id IS NOT NULL ) THEN
      --
        -- As letter has been submitted with select type as Parameter
        -- List nanm should not be selected
      --

           p_exception := 'N';
           fnd_message.set_name('IGS','IGS_CO_PER_LIS_PRAM');
           fnd_file.put_line(fnd_file.log,fnd_message.get());
           fnd_file.put_line(FND_FILE.LOG,' ');
	   --**  proc level logging.
		IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
		    l_label := 'igs.plsql.igs_co_process.corp_validate_parameters';
		    l_debug_str :=  'Exiting corp_validate_parameters as ';
		    l_debug_str := l_debug_str || 'p_parameter_1 IS NOT NULL AND (p_person_id IS NOT NULL OR p_list_id IS NOT NULL';
		    fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
		 END IF;
	     --**
           RETURN;

      END IF;   -- p_parameter_1 IS NOT NULL THEN

      IF p_parameter_1 IS NULL THEN
        p_exception := 'Y';
        fnd_message.set_name('IGS','IGS_CO_PER_LIS_PRAM');
        fnd_file.put_line(fnd_file.log,fnd_message.get());
        fnd_file.put_line(FND_FILE.LOG,' ');
      END IF;
   END IF; -- final end IF for selection type.

    --
    --  Check if the parameter values are not correct.
    --
    IF l_error_flag = 'TRUE' THEN
      p_exception := 'Y';
      fnd_message.set_name('IGS','IGS_AD_INVALID_PARAM_COMB');
      fnd_file.put_line(fnd_file.log,fnd_message.get());
      fnd_file.put_line(FND_FILE.LOG,' ');
      --**  proc level logging.
	IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
	    l_label := 'igs.plsql.igs_co_process.corp_validate_parameters';
	    l_debug_str :=  'Exiting corp_validate_parameters as l_error_flag is TRUE';
	    fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	 END IF;
     --**
      RETURN;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       --**  proc level logging.
	IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
	    l_label := 'igs.plsql.igs_co_process.corp_validate_parameters';
	    l_debug_str :=  'Exception in corp_validate_parameters.';
	    fnd_log.string_with_context( fnd_log.level_procedure,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,NULL);
	 END IF;
     --**
      Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGS_CO_PROCESS.corp_validate_parameters');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
  END corp_validate_parameters;

END igs_co_process;

/
