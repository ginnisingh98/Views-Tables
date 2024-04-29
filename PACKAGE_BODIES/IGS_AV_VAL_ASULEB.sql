--------------------------------------------------------
--  DDL for Package Body IGS_AV_VAL_ASULEB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AV_VAL_ASULEB" AS
/* $Header: IGSAV07B.pls 115.7 2003/12/10 07:40:42 nalkumar ship $ */

  G_ITEM_TYPE  VARCHAR2(300);
  -- To validate the basis year advanced standing units or levels.
  FUNCTION advp_val_basis_year(
  p_basis_year IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
    gv_other_detail   VARCHAR2(255);
  BEGIN -- advp_val_basis_year
    -- validate the basis year
  DECLARE
    v_qualification_recency IGS_PS_VER.qualification_recency%TYPE;
    CURSOR c_qualification_recency IS
      SELECT  qualification_recency
      FROM  IGS_PS_VER
      WHERE   course_cd = p_course_cd AND
        version_number = p_version_number;
  BEGIN
     p_message_name := null;
    -- Validate input parameter
    IF (p_basis_year IS NULL OR
      p_course_cd IS NULL OR
      p_version_number IS NULL) THEN
      RETURN TRUE;
    END IF;
    -- Validate that basis_year is not greater than the current year.(E)
    IF (p_basis_year > TO_NUMBER(SUBSTR(IGS_GE_DATE.IGSCHAR(SYSDATE),1,4))) THEN
      p_message_name := 'IGS_AV_LYENR_NOTGT_CURYR';
      p_return_type := 'E';
      RETURN FALSE;
    END IF;
    -- Validate that basis_yr is not outside the recency for the IGS_PS_COURSE version (W)
    OPEN c_qualification_recency;
    FETCH c_qualification_recency INTO v_qualification_recency;
    IF (c_qualification_recency%NOTFOUND) THEN
      CLOSE c_qualification_recency;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c_qualification_recency;
        IF (p_basis_year <
      TO_NUMBER(SUBSTR(IGS_GE_DATE.IGSCHAR(SYSDATE),1,4)) - v_qualification_recency) THEN
        p_message_name := 'IGS_AV_LRENR_OUTSIDE_QUALIFY';
        p_return_type := 'W';
        RETURN FALSE;
      END IF;
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AV_VAL_ASULEB.ADVP_VAL_BASIS_YEAR');
      App_Exception.Raise_Exception;
      IGS_GE_MSG_STACK.ADD;
    END;
  END advp_val_basis_year;

  PROCEDURE create_transcript
  (
    document_id   IN      VARCHAR2,
    display_type  IN      VARCHAR2,
    document      IN OUT NOCOPY CLOB,
    document_type IN OUT NOCOPY VARCHAR2
  ) IS
  /*
    ||==============================================================================||
    ||  Created By : Nalin Kumar                                                    ||
    ||  Created On : 15-Nov-2003                                                    ||
    ||  Purpose    : To set the value of the Attributes attached to the messages.   ||
    ||               Added as part of RECR50; Bug# 3270446                          ||
    ||                                                                              ||
    ||  Known limitations, enhancements or remarks :                                ||
    ||  Change History :                                                            ||
    ||  Who             When            What                                        ||
    ||  (reverse chronological order - newest change first)                         ||
    ||==============================================================================||
  */
    l_item_type        VARCHAR2(300);
    l_item_key         VARCHAR2(300);
    l_item             VARCHAR2(32000);
    l_message          VARCHAR2(32000);
  BEGIN
    IF document_id IS NOT NULL THEN
      --Fetch the item Type, Item Key and Item Name from the passed Document ID.
      l_item_type := substr(document_id, 1, instr(document_id,':')-1);
      l_item_key  := substr (document_id, INSTR(document_id, ':') +1,  (INSTR(document_id, '*') - INSTR(document_id, ':'))-1) ;
      l_item := substr(document_id, instr(document_id,'*')+1);
      l_message := NULL;
      IF l_item IS NOT NULL THEN
        --
        -- If the Item Name is not null then get the value of the item from the WF
        -- and return it to the message in a document (CLOB) format.
        --
        l_message := wf_engine.GetItemAttrText( itemtype => l_item_type,
                                                itemkey  => l_item_key,
                                                aname    => l_item);
      END IF;
    END IF;
    /* Write the header doc into CLOB variable */
    WF_NOTIFICATION.WriteToClob(document, l_message);
  EXCEPTION
     WHEN OTHERS THEN
      wf_core.context('igs_av_val_asuleb','create_transcript',l_item_type,l_item_key);
      RAISE;
  END create_transcript;

  PROCEDURE wf_set_role(
    itemtype  IN  VARCHAR2,
    itemkey   IN  VARCHAR2,
    actid     IN  NUMBER  ,
    funcmode  IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2) AS
  /*
    ||==============================================================================||
    ||  Created By : Nalin Kumar                                                    ||
    ||  Created On : 15-Nov-2003                                                    ||
    ||  Purpose    : To set the role and decide that which all notification needs   ||
    ||               to be sent. Added as part of RECR50; Bug# 3270446              ||
    ||                                                                              ||
    ||  Known limitations, enhancements or remarks :                                ||
    ||  Change History :                                                            ||
    ||  Who             When            What                                        ||
    ||  (reverse chronological order - newest change first)                         ||
    ||==============================================================================||
  */
    l_notification_flag   VARCHAR2(30) := NULL;
    l_del_basis_dtls_body VARCHAR2(4000);
    l_mod_basis_dtls_body VARCHAR2(4000);
    l_new_basis_dtls_body VARCHAR2(4000);
    l_basis_header VARCHAR2(32000);
    l_msg_document_plsql_proc VARCHAR2(32000);

  BEGIN
    IF (funcmode  = 'RUN') THEN

      --
      -- Validate the Advanced Standing Records and set the Parameters Values
      --
      get_transcript_data(
        p_itemtype        => itemtype,
        p_itemkey         => itemkey ,
        p_person_id     => wf_engine.getitemattrtext(itemtype,itemkey,'P_STUDENT_ID'),
        p_education_id  => wf_engine.getitemattrtext(itemtype,itemkey,'P_REC_EDUCATION_ID'),
        p_transcript_id => wf_engine.getitemattrtext(itemtype,itemkey,'P_REC_TRANSCRIPT_ID'));

      wf_engine.setitemattrtext(ItemType  =>  itemtype,
                                ItemKey   =>  itemkey,
                                aname     =>  'IA_ADHOCROLE',
                                avalue    =>  wf_engine.getitemattrtext(itemtype,itemkey,'IA_REC_ADHOCROLE'));

      l_del_basis_dtls_body := wf_engine.getitemattrtext(itemtype,itemkey,'P_REC_DEL_UDTL');
      l_mod_basis_dtls_body := wf_engine.getitemattrtext(itemtype,itemkey,'P_REC_MOD_UDTL');
      l_new_basis_dtls_body := wf_engine.getitemattrtext(itemtype,itemkey,'P_REC_NEW_BDTL');

      -- Based on the value of l_del_basis_dtls_body, l_mod_basis_dtls_body and l_new_basis_dtls_body
      -- set the lookup code value.
      IF l_del_basis_dtls_body IS NOT NULL THEN
        l_notification_flag := 'D';
      END IF;
      IF l_mod_basis_dtls_body IS NOT NULL THEN
        l_notification_flag := l_notification_flag||'M';
      END IF;
      IF l_new_basis_dtls_body IS NOT NULL THEN
        l_notification_flag := l_notification_flag||'N';
      END IF;

      --
      --Based on the value of the Notification Flag set the value of the Message Attributes.
      --
      IF NVL(l_notification_flag, 'Z') IN ('D', 'DM', 'DN', 'DMN') THEN
        wf_engine.setitemattrtext(ItemType  => itemtype,
                                  ItemKey   => itemkey,
                                  aname     => 'P_DEL_UDTL',
                                  avalue    => 'PLSQLCLOB:igs_av_val_asuleb.create_transcript/'||itemtype||':'||itemkey||'*P_REC_DEL_UDTL');
        wf_engine.setitemattrtext(ItemType  => itemtype,
                                  ItemKey   => itemkey,
                                  aname     => 'P_DEL_BDTL',
                                  avalue    => 'PLSQLCLOB:igs_av_val_asuleb.create_transcript/'||itemtype||':'||itemkey||'*P_REC_DEL_BDTL');
      END IF;
      IF NVL(l_notification_flag, 'Z') IN ('DM', 'MN', 'M', 'DMN') THEN
        wf_engine.setitemattrtext(ItemType  => itemtype,
                                  ItemKey   => itemkey,
                                  aname     => 'P_MOD_UDTL',
                                  avalue    => 'PLSQLCLOB:igs_av_val_asuleb.create_transcript/'||itemtype||':'||itemkey||'*P_REC_MOD_UDTL');
        wf_engine.setitemattrtext(ItemType  => itemtype,
                                  ItemKey   => itemkey,
                                  aname     => 'P_MOD_BDTL',
                                  avalue    => 'PLSQLCLOB:igs_av_val_asuleb.create_transcript/'||itemtype||':'||itemkey||'*P_REC_MOD_BDTL');
      END IF;
      IF NVL(l_notification_flag, 'Z') IN ('DMN', 'DN', 'MN', 'N') THEN
        wf_engine.setitemattrtext(ItemType  => itemtype,
                                  ItemKey   => itemkey,
                                  aname     => 'P_NEW_BDTL',
                                  avalue    => 'PLSQLCLOB:igs_av_val_asuleb.create_transcript/'||itemtype||':'||itemkey||'*P_REC_NEW_BDTL');

      END IF;

      --
      --Return the l_notification_flag which will indicate that which all notifications need to be sent.
      --
      resultout := 'COMPLETE:'||l_notification_flag;
      RETURN;
    END IF;
  END wf_set_role;

  PROCEDURE validate_transcript(
    p_person_id     IN NUMBER,
    p_education_id  IN NUMBER,
    p_transcript_id IN NUMBER) IS
  /*
    ||==============================================================================||
    ||  Created By : Nalin Kumar                                                    ||
    ||  Created On : 15-Nov-2003                                                    ||
    ||  Purpose    : To launch the IGSAV001 workflow and set the attributes values. ||
    ||               Added as part of RECR50; Bug# 3270446                          ||
    ||                                                                              ||
    ||  Known limitations, enhancements or remarks :                                ||
    ||  Change History :                                                            ||
    ||  Who             When            What                                        ||
    ||  (reverse chronological order - newest change first)                         ||
    ||==============================================================================||
  */
    l_event_t          wf_event_t;
    l_raise_event      VARCHAR2(50);
    l_seq_val         VARCHAR2(100) := 'IGSAV001'||to_char(SYSDATE,'YYYYMMDDHH24MISS');
    l_parameter_list_t wf_parameter_list_t;
  BEGIN

    l_raise_event := 'oracle.apps.igs.av.validate_transcript';
    --
    -- initialize the wf_event_t object
    --
    wf_event_t.initialize(l_event_t);

    --
    -- Adding the parameters to the parameter list
    --
    wf_event.addparametertolist( p_name    => 'P_STUDENT_ID',
                                 p_value   => p_person_id  ,
                                 p_parameterlist => l_parameter_list_t);

    wf_event.addparametertolist( p_name    => 'P_REC_EDUCATION_ID',
                                 p_value   => p_education_id,
                                 p_parameterlist => l_parameter_list_t);
    wf_event.addparametertolist( p_name    => 'P_REC_TRANSCRIPT_ID',
                                 p_value   => p_transcript_id,
                                 p_parameterlist => l_parameter_list_t);

    -- Set this role to the workflow
    wf_event.addparametertolist( p_name    => 'IA_REC_ADHOCROLE',
                                 p_value   => fnd_global.user_name,
                                 p_parameterlist => l_parameter_list_t);

    G_ITEM_TYPE := l_seq_val;

    --Raise the event...
    wf_event.raise (p_event_name => l_raise_event,
                    p_event_key  => l_seq_val,
                    p_parameters => l_parameter_list_t);

    --
    -- Deleting the Parameter list after the event is raised
    --
    l_parameter_list_t.delete;
  EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('IGS_AV_VAL_ASULEB', 'VALIDATE_TRANSCRIPT',
    l_seq_val,l_raise_event);
    RAISE;
  END validate_transcript;

  --
  -- To validate the Advanced Standing records when a new Transcript is submitted.
  --
  PROCEDURE get_transcript_data(
    p_itemtype      IN  VARCHAR2,
    p_itemkey       IN  VARCHAR2,
    p_person_id     IN NUMBER,
    p_education_id  IN NUMBER,
    p_transcript_id IN NUMBER) IS
  /*
    ||==============================================================================||
    ||  Created By : Nalin Kumar                                                    ||
    ||  Created On : 15-Nov-2003                                                    ||
    ||  Purpose    : Created this procedure as per RECR050 Build. Bug# 3270446      ||
    ||               This is to validate the Advanced Standing records when a new   ||
    ||               Transcript is submitted.                                       ||
    ||  Known limitations, enhancements or remarks :                                ||
    ||  Change History :                                                            ||
    ||  Who             When            What                                        ||
    ||  (reverse chronological order - newest change first)                         ||
    ||==============================================================================||
  */
    --
    CURSOR cur_get_unit_details_id(cp_unit_details_id NUMBER, cp_unit VARCHAR2, cp_term_details_id NUMBER) IS
    SELECT unit, term_details_id, unit_details_id, cp_attempted, cp_earned, grade, unit_grade_points
    FROM igs_ad_term_unitdtls
    WHERE unit_details_id = NVL(cp_unit_details_id, unit_details_id)
    AND unit = NVL(cp_unit, unit)
    AND term_details_id = NVL(cp_term_details_id, term_details_id);
    rec_get_old_unit_details cur_get_unit_details_id%ROWTYPE;
    rec_get_new_unit_details cur_get_unit_details_id%ROWTYPE;

    --Cursor to fetch all terms attached to the Transcript.
    CURSOR cur_get_term_dtls(cp_transcript_id NUMBER, cp_term_details_id NUMBER)IS
    SELECT term_details_id, transcript_id
    FROM igs_ad_term_details
    WHERE transcript_id = NVL(cp_transcript_id, transcript_id) AND
          term_details_id = NVL(cp_term_details_id, term_details_id);
    rec_get_old_term_dtls cur_get_term_dtls%ROWTYPE;

    --Cursor to get the Advanced Standing records for Student.
    CURSOR cur_chk_adv(cp_person_id NUMBER, cp_exemption_institution_cd VARCHAR2) IS
    SELECT DISTINCT rslt.unit_details_id FROM (
      SELECT DISTINCT unit_details_id
      FROM igs_av_stnd_unit_all
      WHERE person_id = cp_person_id
      AND exemption_institution_cd = cp_exemption_institution_cd
      AND unit_details_id IS NOT NULL
      UNION ALL
      SELECT DISTINCT unit_details_id
      FROM igs_av_stnd_unit_lvl_all
      WHERE person_id = cp_person_id
      AND exemption_institution_cd = cp_exemption_institution_cd
      AND unit_details_id IS NOT NULL) rslt;
    rec_chk_adv cur_chk_adv%ROWTYPE;

    nbsp VARCHAR2(10) := fnd_global.local_chr(38) || 'nbsp;';
    --Cursor to find if there is any new Unit attached to the New Transcript which was not attached to the old transcript.
    CURSOR cur_chk_new_tran(cp_new_tid NUMBER, cp_old_transcript_id NUMBER) IS
    SELECT '<td align="center">'||(RPAD(NVL(nt.unit, nbsp), 10))||'</td>'     new_unit,
           '<td align="center">'||(RPAD(NVL(td.term, nbsp), 30))||'</td>'     term_completed,
           '<td align="center">'||(LPAD(NVL(TO_CHAR(nt.cp_earned), nbsp), 7))||'</td>' cp_earned,
           '<td align="center">'||(RPAD(NVL(nt.grade, nbsp),10))||'</td>'     grade
    FROM igs_ad_term_unitdtls nt, igs_ad_term_details td
    WHERE nt.term_details_id = cp_new_tid
    AND td.term_details_id = nt.term_details_id
    AND NOT EXISTS
    (SELECT 'x'
      FROM igs_ad_term_unitdtls ot
      WHERE ot.term_details_id IN (select term_details_id FROM igs_ad_term_details WHERE transcript_id = cp_old_transcript_id)
      AND ot.unit = nt.unit);

    --Cursor to fetch the Advanced Standing details which has to be Deleted/Updated.
    CURSOR cur_del_adv_dtls (cp_person_id       NUMBER,
                             cp_unit_details_id NUMBER )IS
    SELECT '<td align="center">'||(RPAD(NVL(av.cal_type, nbsp), 12))||'</td>'                    cal_type,
           '<td align="center">'||(RPAD(NVL(av.unit_cd, nbsp), 15))||'</td>'                     unit,
           '<td align="center">'||(RPAD(NVL(av.s_adv_stnd_recognition_type, nbsp), 30))||'</td>' ece_type,
           '<td align="center">'||(LPAD(NVL(TO_CHAR(av.achievable_credit_points), nbsp), 9))||'</td>' credit_points,
           '<td align="center">'||(RPAD(NVL(av.s_adv_stnd_granting_status, nbsp), 30))||'</td>'  adv_status,
           '<td align="center">'||(RPAD(NVL(TO_CHAR(av.approved_dt), nbsp), 13))||'</td>'        approved_dt,
           '<td align="center">'||(RPAD(NVL(av.exemption_institution_cd, nbsp), 30))||'</td>'    exemption_institution_cd,
           '<td align="center">'||(RPAD(NVL(atu.unit, nbsp), 10))||'</td>'                       new_unit,
           '<td align="center">'||(RPAD(NVL(TO_CHAR(atu.cp_earned), nbsp), 7))||'</td>'          new_cp_earned,
           '<td align="center">'||(RPAD(NVL(atu.grade, nbsp), 10))||'</td>'                      new_grade,
           'UNIT' lvl,
           av.av_stnd_unit_id pk
    FROM igs_av_stnd_unit_all av,
         igs_ad_term_unitdtls atu
    WHERE av.person_id = cp_person_id
    AND av.unit_details_id = cp_unit_details_id
    AND atu.unit_details_id = av.unit_details_id
    UNION ALL
    SELECT '<td align="center">'||(RPAD(NVL(avl.cal_type, '& '), 12))||'</td>'                   cal_type,
           '<td align="center">'||(RPAD(NVL(avl.unit_level, nbsp), 15))||'</td>'                 unit,
           '<td align="center">'||(RPAD(nbsp, 30))||'</td>'                                      ece_type,
           '<td align="center">'||(LPAD(NVL(TO_CHAR(avl.credit_points), nbsp),9))||'</td>'       credit_points,
           '<td align="center">'||(RPAD(NVL(avl.s_adv_stnd_granting_status, nbsp), 30))||'</td>' adv_status,
           '<td align="center">'||(RPAD(NVL(TO_CHAR(avl.approved_dt), nbsp), 13))||'</td>'       approved_dt,
           '<td align="center">'||(RPAD(NVL(avl.exemption_institution_cd, nbsp), 30))||'</td>'   exemption_institution_cd,
           '<td align="center">'||(RPAD(NVL(atu1.unit, nbsp), 10))||'</td>'                      new_unit,
           '<td align="center">'||(RPAD(NVL(TO_CHAR(atu1.cp_earned), nbsp), 7))||'</td>'         new_cp_earned,
           '<td align="center">'||(RPAD(NVL(atu1.grade, nbsp), 10))||'</td>'                     new_grade,
           'UNIT LEVEL' lvl,
           avl.av_stnd_unit_lvl_id pk
    FROM igs_av_stnd_unit_lvl_all avl,
         igs_ad_term_unitdtls atu1
    WHERE avl.person_id = cp_person_id
    AND avl.unit_details_id = cp_unit_details_id
    AND atu1.unit_details_id = avl.unit_details_id;

    --Select Advanced Standing Unit records for updation of unit_details_id.
    CURSOR cur_get_adv_unit_dtls(cp_av_stnd_unit_id NUMBER) IS
    SELECT unit.rowid,
           unit.*
    FROM igs_av_stnd_unit_all unit
    WHERE unit.av_stnd_unit_id = cp_av_stnd_unit_id
    FOR UPDATE OF unit_details_id;
    rec_get_adv_unit_dtls cur_get_adv_unit_dtls%ROWTYPE;

    --Select Advanced Standing Unit Level records for updation of unit_details_id.
    CURSOR cur_get_adv_unit_lvl_dtls(cp_av_stnd_unit_lvl_id NUMBER) IS
    SELECT unl_lvl.rowid,
           unl_lvl.*
    FROM igs_av_stnd_unit_lvl_all unl_lvl
    WHERE unl_lvl.av_stnd_unit_lvl_id = cp_av_stnd_unit_lvl_id
    FOR UPDATE OF unit_details_id;
    rec_get_adv_unit_lvl_dtls cur_get_adv_unit_lvl_dtls%ROWTYPE;

    --Cursor to fetch the New Term Name
    CURSOR cur_get_term(cp_term_details_id NUMBER) IS
    SELECT '<td align="center">'||(RPAD(NVL(td.term, nbsp), 30))||'</td>' term_completed
    FROM igs_ad_term_details td
    WHERE td.term_details_id = cp_term_details_id;
    rec_get_term cur_get_term%ROWTYPE;
    rec_get_new_term cur_get_term%ROWTYPE;

    --Cursor to fetch the Alt Unit Details for the Unit Advanced Standing.
    CURSOR cur_get_alt_unit(cp_av_stnd_unit_id NUMBER) IS
    SELECT alt.rowid
    FROM igs_av_stnd_alt_unit alt
    WHERE alt.av_stnd_unit_id = cp_av_stnd_unit_id;
    rec_get_alt_unit cur_get_alt_unit%ROWTYPE;

    --Cursor to fetch the Basis Details for the Unit Advanced Standing.
    CURSOR cur_get_bas_dtl(cp_av_stnd_unit_id NUMBER) IS
    SELECT bas.rowid
    FROM igs_av_std_unt_basis_all bas
    WHERE bas.av_stnd_unit_id = cp_av_stnd_unit_id;
    rec_get_bas_dtl cur_get_bas_dtl%ROWTYPE;

    --Cursor to fetch the Basis Details for the Unit Level Advanced Standing.
    CURSOR cur_get_bas_lvl(cp_av_stnd_unit_lvl_id  NUMBER) IS
    SELECT lvl.rowid
    FROM igs_av_std_ulvlbasis_all lvl
    WHERE lvl.av_stnd_unit_lvl_id = cp_av_stnd_unit_lvl_id;
    rec_get_bas_lvl cur_get_bas_lvl%ROWTYPE;

    -- Cursor to fetch the Institution Code
    CURSOR cur_get_inst_cd(cp_education_id NUMBER) IS
    SELECT institution_code
    FROM igs_ad_acad_history_v
    WHERE education_id = cp_education_id;
    rec_get_inst_cd cur_get_inst_cd%ROWTYPE;

    l_del_unit_details_body VARCHAR2(4000) := NULL;
    l_del_basis_dtls_body   VARCHAR2(4000) := NULL;
    l_mod_unit_details_body VARCHAR2(4000) := NULL;
    l_mod_basis_dtls_body   VARCHAR2(4000) := NULL;
    l_new_basis_dtls_body   VARCHAR2(4000) := NULL;
    l_adv_deleted   VARCHAR2(1);
    l_grade_changed VARCHAR2(1);
    l_new_unit      VARCHAR2(1) := 'N';
  BEGIN
    --
    -- Fetch the Institution Code from the Education Code.
    --
    OPEN cur_get_inst_cd(p_education_id);
    FETCH cur_get_inst_cd INTO rec_get_inst_cd;
    CLOSE cur_get_inst_cd;

    -- o Try to find that if the Student has any Advanced Standing Records for given Institution.
    FOR rec_chk_adv IN cur_chk_adv(p_person_id, rec_get_inst_cd.institution_code) LOOP
      --Initilalize the variables...
      l_adv_deleted   := 'N';
      l_grade_changed := 'N';

      --Get the Old Transcript Details and Unit associated with it...
      OPEN cur_get_unit_details_id(rec_chk_adv.unit_details_id, NULL, NULL);
      FETCH cur_get_unit_details_id INTO rec_get_old_unit_details;
      CLOSE cur_get_unit_details_id;

      -- Fetch all Terms attached to the New Transcript and check if all Unit is
      --  attached to it, which were attached to the Old Transcript...
      l_grade_changed := 'N';

      --Fetch Old Transcript Id
      OPEN cur_get_term_dtls(NULL, rec_get_old_unit_details.term_details_id);
      FETCH cur_get_term_dtls INTO rec_get_old_term_dtls;  --rec_get_old_term_dtls.transcript_id --Old Transcript Id
      CLOSE cur_get_term_dtls;

      -- Fetch all Terms attached to the New Transcript...
      FOR rec_get_new_term_id IN cur_get_term_dtls(p_transcript_id, NULL) LOOP  --New Terms...
        -- Fetch New Term Name.
        OPEN cur_get_term(rec_get_new_term_id.term_details_id);
        FETCH cur_get_term INTO rec_get_new_term;
        CLOSE cur_get_term;

        IF l_grade_changed = 'N' THEN
          OPEN cur_get_unit_details_id(NULL, rec_get_old_unit_details.unit, rec_get_new_term_id.term_details_id);
          FETCH cur_get_unit_details_id INTO rec_get_new_unit_details;
            IF cur_get_unit_details_id%FOUND THEN
              -- The new transcript has the old unit associated with it.
              -- ooo Check for Grade Details Changed
              IF NVL(rec_get_old_unit_details.cp_attempted, -1)      <> NVL(rec_get_new_unit_details.cp_attempted, -1)      OR
                 NVL(rec_get_old_unit_details.cp_earned, -1)         <> NVL(rec_get_new_unit_details.cp_earned, -1)         OR
                 NVL(rec_get_old_unit_details.grade, 'NULL')         <> NVL(rec_get_new_unit_details.grade, 'NULL')         OR
                 NVL(rec_get_old_unit_details.unit_grade_points, -1) <> NVL(rec_get_new_unit_details.unit_grade_points, -1) THEN
                --Put a flag to indicate that there is some Grade differences and it needs to be verified.
                l_grade_changed := 'Y';
              ELSE
                l_grade_changed := 'U';
              END IF;
            END IF;
          CLOSE cur_get_unit_details_id;
        END IF;

        --Check for New Units...
        --If the new transcript has units that are not in transcript that the advanced standing
        --records are based upon, a notification is sent describing the new unit details.
        IF l_new_unit = 'N' THEN
          --Fetch all new Units details attached to the New Transcript...
          FOR rec_chk_new_tran IN cur_chk_new_tran(TO_NUMBER(rec_get_new_term_id.term_details_id),
                                                   TO_NUMBER(rec_get_old_term_dtls.transcript_id)) LOOP
            --Populate the Basis Details...
            l_new_basis_dtls_body := l_new_basis_dtls_body
                                     ||'<tr><td align="center">'||(RPAD(rec_get_inst_cd.institution_code,30))||'</td>'||
                                     rec_chk_new_tran.new_unit||
                                     rec_get_new_term.term_completed||
                                     rec_chk_new_tran.cp_earned||
                                     rec_chk_new_tran.grade||'</tr>';
          END LOOP;
        END IF;
      END LOOP;

      IF l_new_basis_dtls_body IS NOT NULL THEN
        --Put a flag to indicate that all new units details has been fetched and
        --no futher processing is required.
        l_new_unit := 'Y';
      END IF;

      IF l_grade_changed NOT IN ('Y', 'U') THEN
        --Put a flag to indecate that the Advanced Standing Deletion notification needs to be sent.
        l_adv_deleted := 'Y';
      END IF;

      -- Fetch the Old Term Name.
      OPEN cur_get_term(rec_get_old_unit_details.term_details_id);
      FETCH cur_get_term INTO rec_get_term;
      CLOSE cur_get_term;
      --Fetch all Advanced Standing Records
      IF l_adv_deleted = 'Y' OR l_grade_changed IN ('Y','U') THEN
        FOR rec_del_adv_dtls IN cur_del_adv_dtls(p_person_id,
                                                 rec_get_old_unit_details.unit_details_id) LOOP

          IF l_adv_deleted = 'Y' THEN
            --Populate the Unit Details...
            l_del_unit_details_body := l_del_unit_details_body||'<tr>'||rec_del_adv_dtls.cal_type||rec_del_adv_dtls.unit||
                                   rec_del_adv_dtls.ece_type||rec_del_adv_dtls.credit_points||rec_del_adv_dtls.adv_status||
                                   rec_del_adv_dtls.approved_dt||'</tr>';
            --Populate the Basis Details...
            l_del_basis_dtls_body := l_del_basis_dtls_body||'<tr>'||rec_del_adv_dtls.exemption_institution_cd||rec_del_adv_dtls.new_unit||
                                     rec_get_term.term_completed||rec_del_adv_dtls.new_cp_earned||rec_del_adv_dtls.new_grade||'</tr>';
            -- ** Delete the Advanced Standing related records for the given p_person_id,
            -- ** p_transcript_id and rec_get_old_unit_details.unit_details_id
--/*
            IF RTRIM(rec_del_adv_dtls.lvl) = 'UNIT' AND SUBSTR(rec_del_adv_dtls.ece_type, 20, 10) = 'PRECLUSION' THEN
              --Check if there exists any Alternate Unit Details; If exists then delete it;
              FOR rec_get_alt_unit IN cur_get_alt_unit(rec_del_adv_dtls.pk) LOOP
                igs_av_stnd_alt_unit_pkg.delete_row(X_ROWID => rec_get_alt_unit.rowid);
              END LOOP;

              --Check if there exists any Unit Basis Details; If exists then delete it;
              FOR rec_get_bas_dtl IN cur_get_bas_dtl(rec_del_adv_dtls.pk) LOOP
                igs_av_std_unt_basis_pkg.delete_row(X_ROWID => rec_get_bas_dtl.rowid);
              END LOOP;

              --Fetch the Advanced Standing Unit Record for deletion...
              OPEN cur_get_adv_unit_dtls(rec_del_adv_dtls.pk);
              FETCH cur_get_adv_unit_dtls INTO rec_get_adv_unit_dtls;
              CLOSE cur_get_adv_unit_dtls;
              igs_av_stnd_unit_pkg.delete_row(X_ROWID => rec_get_adv_unit_dtls.rowid);
            ELSIF  RTRIM(rec_del_adv_dtls.lvl) = 'UNIT' AND SUBSTR(rec_del_adv_dtls.ece_type, 20, 10) <> 'PRECLUSION' THEN
              --Check if there exists any Unit Basis Details; If exists then delete it;
              FOR rec_get_bas_dtl IN cur_get_bas_dtl(rec_del_adv_dtls.pk) LOOP
                igs_av_std_unt_basis_pkg.delete_row(X_ROWID => rec_get_bas_dtl.rowid);
              END LOOP;

              --Fetch the Advanced Standing Unit Record for deletion...
              OPEN cur_get_adv_unit_dtls(rec_del_adv_dtls.pk);
              FETCH cur_get_adv_unit_dtls INTO rec_get_adv_unit_dtls;
              CLOSE cur_get_adv_unit_dtls;
              igs_av_stnd_unit_pkg.delete_row(X_ROWID => rec_get_adv_unit_dtls.rowid);
            ELSIF RTRIM(rec_del_adv_dtls.lvl) = 'UNIT LEVEL' THEN
              --Check if there exists any Unit Level Basis Details; If exists then delete it;
              FOR rec_get_bas_lvl IN cur_get_bas_lvl(rec_del_adv_dtls.pk) LOOP
                igs_av_std_ulvlbasis_pkg.delete_row(X_ROWID => rec_get_bas_lvl.rowid);
              END LOOP;

              --Fetch the Advanced Standing Unit Level Record for deletion...
              OPEN cur_get_adv_unit_lvl_dtls(rec_del_adv_dtls.pk);
              FETCH cur_get_adv_unit_lvl_dtls INTO rec_get_adv_unit_lvl_dtls;
              CLOSE cur_get_adv_unit_lvl_dtls;
              igs_av_stnd_unit_lvl_pkg.delete_row(X_ROWID => rec_get_adv_unit_lvl_dtls.rowid);
            END IF;
--*/
          ELSIF l_grade_changed IN ('Y', 'U') THEN
            IF l_grade_changed = 'Y' THEN
              --Populate the Unit Details...
              l_mod_unit_details_body := l_mod_unit_details_body||'<tr>'||rec_del_adv_dtls.cal_type||rec_del_adv_dtls.unit||
                                     rec_del_adv_dtls.ece_type||rec_del_adv_dtls.credit_points||rec_del_adv_dtls.adv_status||
                                     rec_del_adv_dtls.approved_dt||'</tr>';
              --Populate the Basis Details...
              l_mod_basis_dtls_body := l_mod_basis_dtls_body||'<tr>'||rec_del_adv_dtls.exemption_institution_cd||rec_del_adv_dtls.new_unit||
                                       rec_get_term.term_completed||rec_del_adv_dtls.new_cp_earned||rec_del_adv_dtls.new_grade||'</tr>';
            END IF;
            -- oooo Update Transcript Details Pointer
            -- ** Before exiting, the advanced standing record is updated to reflect the
            -- ** association with new transcript by updating each UNIT_DETAILS_ID in
            -- ** IGS_AV_ADV_STND_UNIT_ALL and IGS_AV_ADV_STND_LVL_ALL where EXEMPTION_INSTITUTION_CD
            -- ** equals the EDUCATION_ID parameter to point to the unit under the new transcript.

            IF rec_del_adv_dtls.lvl = 'UNIT' THEN
              OPEN cur_get_adv_unit_dtls(rec_del_adv_dtls.pk);
              FETCH cur_get_adv_unit_dtls INTO rec_get_adv_unit_dtls;
                IF cur_get_adv_unit_dtls%FOUND THEN
                  igs_av_stnd_unit_pkg.update_row(
                    X_ROWID                        => rec_get_adv_unit_dtls.rowid                      ,
                    X_PERSON_ID                    => rec_get_adv_unit_dtls.person_id                  ,
                    X_AS_COURSE_CD                 => rec_get_adv_unit_dtls.as_course_cd               ,
                    X_AS_VERSION_NUMBER            => rec_get_adv_unit_dtls.as_version_number          ,
                    X_S_ADV_STND_TYPE              => rec_get_adv_unit_dtls.s_adv_stnd_type            ,
                    X_UNIT_CD                      => rec_get_adv_unit_dtls.unit_cd                    ,
                    X_VERSION_NUMBER               => rec_get_adv_unit_dtls.version_number             ,
                    X_S_ADV_STND_GRANTING_STATUS   => rec_get_adv_unit_dtls.s_adv_stnd_granting_status ,
                    X_CREDIT_PERCENTAGE            => NULL                                             ,
                    X_S_ADV_STND_RECOGNITION_TYPE  => rec_get_adv_unit_dtls.s_adv_stnd_recognition_type,
                    X_APPROVED_DT                  => rec_get_adv_unit_dtls.approved_dt                ,
                    X_AUTHORISING_PERSON_ID        => rec_get_adv_unit_dtls.authorising_person_id      ,
                    X_CRS_GROUP_IND                => rec_get_adv_unit_dtls.crs_group_ind              ,
                    X_EXEMPTION_INSTITUTION_CD     => rec_get_adv_unit_dtls.exemption_institution_cd   ,
                    X_GRANTED_DT                   => rec_get_adv_unit_dtls.granted_dt                 ,
                    X_EXPIRY_DT                    => rec_get_adv_unit_dtls.expiry_dt                  ,
                    X_CANCELLED_DT                 => rec_get_adv_unit_dtls.cancelled_dt               ,
                    X_REVOKED_DT                   => rec_get_adv_unit_dtls.revoked_dt                 ,
                    X_COMMENTS                     => rec_get_adv_unit_dtls.comments                   ,
                    X_AV_STND_UNIT_ID              => rec_get_adv_unit_dtls.av_stnd_unit_id            ,
                    X_CAL_TYPE                     => rec_get_adv_unit_dtls.cal_type                   ,
                    X_CI_SEQUENCE_NUMBER           => rec_get_adv_unit_dtls.ci_sequence_number         ,
                    X_INSTITUTION_CD               => rec_get_adv_unit_dtls.institution_cd             ,
                    X_UNIT_DETAILS_ID              => rec_get_new_unit_details.unit_details_id         , --Change the unit_details_id.
                    X_TST_RSLT_DTLS_ID             => rec_get_adv_unit_dtls.tst_rslt_dtls_id           ,
                    X_GRADING_SCHEMA_CD            => rec_get_adv_unit_dtls.grading_schema_cd          ,
                    X_GRD_SCH_VERSION_NUMBER       => rec_get_adv_unit_dtls.grd_sch_version_number     ,
                    X_GRADE                        => rec_get_adv_unit_dtls.grade                      ,
                    X_ACHIEVABLE_CREDIT_POINTS     => rec_get_adv_unit_dtls.achievable_credit_points   ,
                    X_DEG_AUD_DETAIL_ID            => rec_get_adv_unit_dtls.deg_aud_detail_id          ,
                    X_MODE                         => 'R'
                  );
                END IF;
              CLOSE cur_get_adv_unit_dtls;
            ELSE
              OPEN cur_get_adv_unit_lvl_dtls(rec_del_adv_dtls.pk);
              FETCH cur_get_adv_unit_lvl_dtls INTO rec_get_adv_unit_lvl_dtls;
                IF cur_get_adv_unit_lvl_dtls%FOUND THEN
                  igs_av_stnd_unit_lvl_pkg.update_row(
                    X_ROWID                        => rec_get_adv_unit_lvl_dtls.rowid                     ,
                    X_PERSON_ID                    => rec_get_adv_unit_lvl_dtls.person_id                 ,
                    X_AS_COURSE_CD                 => rec_get_adv_unit_lvl_dtls.as_course_cd              ,
                    X_AS_VERSION_NUMBER            => rec_get_adv_unit_lvl_dtls.as_version_number         ,
                    X_S_ADV_STND_TYPE              => rec_get_adv_unit_lvl_dtls.s_adv_stnd_type           ,
                    X_UNIT_LEVEL                   => rec_get_adv_unit_lvl_dtls.unit_level                ,
                    X_CRS_GROUP_IND                => rec_get_adv_unit_lvl_dtls.crs_group_ind             ,
                    X_EXEMPTION_INSTITUTION_CD     => rec_get_adv_unit_lvl_dtls.exemption_institution_cd  ,
                    X_S_ADV_STND_GRANTING_STATUS   => rec_get_adv_unit_lvl_dtls.s_adv_stnd_granting_status,
                    X_CREDIT_POINTS                => rec_get_adv_unit_lvl_dtls.credit_points             ,
                    X_APPROVED_DT                  => rec_get_adv_unit_lvl_dtls.approved_dt               ,
                    X_AUTHORISING_PERSON_ID        => rec_get_adv_unit_lvl_dtls.authorising_person_id     ,
                    X_GRANTED_DT                   => rec_get_adv_unit_lvl_dtls.granted_dt                ,
                    X_EXPIRY_DT                    => rec_get_adv_unit_lvl_dtls.expiry_dt                 ,
                    X_CANCELLED_DT                 => rec_get_adv_unit_lvl_dtls.cancelled_dt              ,
                    X_REVOKED_DT                   => rec_get_adv_unit_lvl_dtls.revoked_dt                ,
                    X_COMMENTS                     => rec_get_adv_unit_lvl_dtls.comments                  ,
                    X_AV_STND_UNIT_LVL_ID          => rec_get_adv_unit_lvl_dtls.av_stnd_unit_lvl_id       ,
                    X_CAL_TYPE                     => rec_get_adv_unit_lvl_dtls.cal_type                  ,
                    X_CI_SEQUENCE_NUMBER           => rec_get_adv_unit_lvl_dtls.ci_sequence_number        ,
                    X_INSTITUTION_CD               => rec_get_adv_unit_lvl_dtls.institution_cd            ,
                    X_UNIT_DETAILS_ID              => rec_get_new_unit_details.unit_details_id            , --Change the unit_details_id.
                    X_TST_RSLT_DTLS_ID             => rec_get_adv_unit_lvl_dtls.tst_rslt_dtls_id          ,
                    X_DEG_AUD_DETAIL_ID            => rec_get_adv_unit_lvl_dtls.deg_aud_detail_id         ,
                    X_QUAL_DETS_ID                 => rec_get_adv_unit_lvl_dtls.qual_dets_id              ,
                    X_MODE                         => 'R'
                  );
                END IF;
              CLOSE cur_get_adv_unit_lvl_dtls;
            END IF;
          END IF;
        END LOOP;
      END IF;
    END LOOP;
    --
    --Close all html tables
    --
    IF l_del_unit_details_body IS NOT NULL THEN
      l_del_unit_details_body := l_del_unit_details_body||'</table>';
      l_del_basis_dtls_body   := l_del_basis_dtls_body||'</table>';
    END IF;
    IF l_mod_unit_details_body IS NOT NULL THEN
      l_mod_unit_details_body := l_mod_unit_details_body||'</table>';
      l_mod_basis_dtls_body   := l_mod_basis_dtls_body||'</table>';
    END IF;
    IF l_new_basis_dtls_body IS NOT NULL THEN
      l_new_basis_dtls_body := l_new_basis_dtls_body||'</table>';
    END IF;

    --
    -- Set the value of the Paramentes in Workflow....
    --
    wf_engine.setitemattrtext(ItemType  => p_itemtype,
                              ItemKey   => p_itemkey,
                              aname     => 'P_REC_DEL_UDTL',
                              avalue    => l_del_unit_details_body);

    wf_engine.setitemattrtext(ItemType  => p_itemtype,
                              ItemKey   => p_itemkey,
                              aname     => 'P_REC_DEL_BDTL',
                              avalue    => l_del_basis_dtls_body);

    wf_engine.setitemattrtext(ItemType  => p_itemtype,
                              ItemKey   => p_itemkey,
                              aname     => 'P_REC_MOD_UDTL',
                              avalue    => l_mod_unit_details_body);
    wf_engine.setitemattrtext(ItemType  => p_itemtype,
                              ItemKey   => p_itemkey,
                              aname     => 'P_REC_MOD_BDTL',
                              avalue    => l_mod_basis_dtls_body);

    wf_engine.setitemattrtext(ItemType  => p_itemtype,
                              ItemKey   => p_itemkey,
                              aname     => 'P_REC_NEW_BDTL',
                              avalue    => l_new_basis_dtls_body);
  END get_transcript_data;
END igs_av_val_asuleb;

/
