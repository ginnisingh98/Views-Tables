--------------------------------------------------------
--  DDL for Package Body IGS_AS_SS_DOC_REQUEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_SS_DOC_REQUEST" AS
/* $Header: IGSAS45B.pls 120.6 2006/07/26 07:41:20 ijeddy ship $ */
  --
  --
  --
  FUNCTION check_waivers (p_person_id NUMBER)
     RETURN VARCHAR2
  AS
     CURSOR c_ftci
     IS
        SELECT   ftci.fee_cal_type, ftci.fee_ci_sequence_number
            FROM igs_fi_f_typ_ca_inst ftci,
                 igs_ca_da_inst_v daiv,
                 igs_ca_da_inst_v daiv1,
                 igs_fi_fee_type ft,
                 igs_fi_fee_str_stat stat
           WHERE ftci.fee_type = ft.fee_type
             AND ft.s_fee_type = 'DOCUMENT'
             AND ftci.fee_type_ci_status = stat.fee_structure_status
             AND stat.s_fee_structure_status = 'ACTIVE'
             AND NVL (ft.closed_ind, 'N') = 'N'
             AND (    daiv.dt_alias = ftci.start_dt_alias
                  AND daiv.sequence_number = ftci.start_dai_sequence_number
                  AND daiv.cal_type = ftci.fee_cal_type
                  AND daiv.ci_sequence_number = ftci.fee_ci_sequence_number
                 )
             AND (    daiv1.dt_alias = ftci.end_dt_alias
                  AND daiv1.sequence_number = ftci.end_dai_sequence_number
                  AND daiv1.cal_type = ftci.fee_cal_type
                  AND daiv1.ci_sequence_number = ftci.fee_ci_sequence_number
                 )
             AND SYSDATE BETWEEN daiv.alias_val
                             AND NVL (daiv1.alias_val, SYSDATE)
        ORDER BY daiv.alias_val DESC;

     v_ftci_rec   c_ftci%ROWTYPE;

     CURSOR c1 (
        l_person_id                igs_fi_wav_std_pgms.person_id%TYPE,
        l_fee_cal_type             igs_fi_wav_std_pgms.fee_cal_type%TYPE,
        l_fee_ci_sequence_number   igs_fi_wav_std_pgms.fee_ci_sequence_number%TYPE
     )
     IS
        SELECT 'X'
          FROM igs_fi_wav_std_pgms
         WHERE person_id = l_person_id
           AND fee_cal_type = l_fee_cal_type
           AND fee_ci_sequence_number = l_fee_ci_sequence_number
           AND assignment_status_code = 'ACTIVE';

     temp         VARCHAR2 (1);
  BEGIN
     OPEN c_ftci;
     FETCH c_ftci INTO v_ftci_rec;
     IF (c_ftci%NOTFOUND)
     THEN
        CLOSE c_ftci;
        RETURN 'NOSETUP';
     END IF;
     CLOSE c_ftci;
     OPEN c1 (
        p_person_id,
        v_ftci_rec.fee_cal_type,
        v_ftci_rec.fee_ci_sequence_number);
     FETCH c1 INTO temp;
     IF (c1%FOUND)
     THEN
        CLOSE c1;
        RETURN 'TRUE';
     ELSE
        CLOSE c1;
        RETURN 'FALSE';
     END IF;
  END;

  PROCEDURE get_summary_display_message (
    p_person_id                           NUMBER,
    p_hold_message                 OUT NOCOPY VARCHAR2,
    p_hint_message                 OUT NOCOPY VARCHAR2,
    p_request_allowed              OUT NOCOPY VARCHAR2,
    p_transcript_allowed           OUT NOCOPY VARCHAR2,
    p_encert_allowed               OUT NOCOPY VARCHAR2,
    p_lifetimefee_allowed          OUT NOCOPY VARCHAR2
  ) AS
    lvcmessage       VARCHAR2 (2000);
    --
    -- Cursor to get the institution setup for documents.
    --
    CURSOR c_setup IS
      SELECT lifetime_trans_fee_ind,
             provide_transcript_ind,
             trans_request_if_hold_ind,
             all_acad_hist_in_one_doc_ind,
             hold_deliv_ind,
             allow_enroll_cert_ind
      FROM   igs_as_docproc_stup;
    --
    cur_setup        c_setup%ROWTYPE;
    --
    -- Cursor to get the holds information for the student which has effect of blocking his transcript
    --
    CURSOR c_hold IS
      SELECT   encumbrance_type,
               pee_start_dt
      FROM     igs_pe_persenc_effct
      WHERE    person_id = p_person_id
      AND      s_encmb_effect_type IN ('TRANS_BLK','RVK_SRVC','SUS_SRVC','RESULT_BLK')
      AND      NVL (expiry_dt, SYSDATE) >= SYSDATE
      AND      pee_start_dt < SYSDATE
      ORDER BY pee_start_dt DESC;
    --
    cur_hold         c_hold%ROWTYPE;
    --
    -- Cursor to select the the info whether the student has paid the life time fee or not
    --
    CURSOR c_lifetime_fee IS
      SELECT lifetime_fee_paid
      FROM   igs_as_doc_fee_pmnt
      WHERE  person_id = p_person_id
      AND    document_type = 'TRANSCRIPT'
      AND    fee_paid_type = 'LIFETIME';
    --
    cur_lifetime_fee c_lifetime_fee%ROWTYPE;
    lvcholdexists    VARCHAR2 (1)             DEFAULT 'N';
    --
  BEGIN
    --
    -- Initialize the request allowed to 'Y'
    --
    p_request_allowed := 'Y';
    p_transcript_allowed := 'Y';
    p_encert_allowed := 'Y';
    p_lifetimefee_allowed := 'Y';
    --
    -- Initailize Hold Message to Null
    --
    p_hold_message := NULL;
    --
    -- Open Cursor to determine whether the lifetime fee is paid or not
    --
    OPEN c_setup;
    FETCH c_setup INTO cur_setup;
    CLOSE c_setup;
    OPEN c_hold;
    FETCH c_hold INTO cur_hold;
    IF c_hold%FOUND THEN
      lvcholdexists := 'Y';
    END IF;
    CLOSE c_hold;
    --
    IF lvcholdexists = 'Y' THEN
      fnd_message.set_name ('IGS', 'IGS_SS_AS_HOLD_EXISTS');
      fnd_message.set_token ('HOLD_TYPE', cur_hold.encumbrance_type);
      fnd_message.set_token ('START_DATE', cur_hold.pee_start_dt);
      p_hold_message := fnd_message.get;
    END IF;
    --
    -- Check for Lifetime Fee
    --
    IF cur_setup.lifetime_trans_fee_ind = 'Y' THEN
      OPEN c_lifetime_fee;
      FETCH c_lifetime_fee INTO cur_lifetime_fee;
      IF c_lifetime_fee%FOUND THEN
        p_lifetimefee_allowed := 'N';
      ELSE
        p_lifetimefee_allowed := 'Y';
      END IF;
      CLOSE c_lifetime_fee;
    ELSE
      p_lifetimefee_allowed := 'N';
    END IF;
    IF cur_setup.provide_transcript_ind = 'Y' THEN
      IF lvcholdexists = 'Y' THEN
        IF  cur_setup.trans_request_if_hold_ind = 'Y'
            AND cur_setup.hold_deliv_ind = 'N' THEN
          IF cur_setup.allow_enroll_cert_ind = 'Y' THEN
            fnd_message.set_name ('IGS', 'IGS_SS_AS_ENCERT_TILL_HOLD');
            p_hint_message := fnd_message.get;
            p_request_allowed := 'Y';
            p_transcript_allowed := 'N';
            p_encert_allowed := 'Y';
            RETURN;
          ELSE
            fnd_message.set_name ('IGS', 'IGS_SS_AS_NODOC_TILL_HOLD');
            p_hint_message := fnd_message.get;
            p_request_allowed := 'N';
            p_transcript_allowed := 'N';
            p_encert_allowed := 'N';
            RETURN;
          END IF;
        --
        -- kdande; 27-May-2002; Bug# 2375407
        -- Added the following code to display the messages properly and meaningfully.
        --
        ELSIF  cur_setup.trans_request_if_hold_ind = 'N'
               AND cur_setup.hold_deliv_ind = 'Y' THEN
          IF cur_setup.allow_enroll_cert_ind = 'Y' THEN
            fnd_message.set_name ('IGS', 'IGS_SS_AS_ENC_DLV_TILL_HOLD');
            p_hint_message := fnd_message.get;
            p_request_allowed := 'Y';
            p_transcript_allowed := 'Y';
            p_encert_allowed := 'Y';
            RETURN;
          ELSE
            fnd_message.set_name ('IGS', 'IGS_SS_AS_TRN_DLV_TILL_HOLD');
            p_hint_message := fnd_message.get;
            p_request_allowed := 'Y';
            p_transcript_allowed := 'Y';
            p_encert_allowed := 'N';
            RETURN;
          END IF;
        END IF;
        IF cur_setup.hold_deliv_ind = 'Y' THEN
          fnd_message.set_name ('IGS', 'IGS_SS_AS_HOLD_DEIV');
          p_hint_message := fnd_message.get;
        END IF;
      END IF;
      IF cur_setup.allow_enroll_cert_ind = 'Y' THEN
        fnd_message.set_name ('IGS', 'IGS_SS_AS_ORDER_BOTH_DOCS');
        p_hint_message := fnd_message.get;
      ELSE
        fnd_message.set_name ('IGS', 'IGS_SS_AS_ORDER_ONLY_TRANS');
        p_hint_message := fnd_message.get;
        p_transcript_allowed := 'Y';
        p_encert_allowed := 'N';
      END IF;
    ELSE
      IF cur_setup.allow_enroll_cert_ind = 'Y' THEN
        fnd_message.set_name ('IGS', 'IGS_SS_AS_ORDER_ONLY_ENCERT');
        p_hint_message := fnd_message.get;
        p_transcript_allowed := 'N';
        p_encert_allowed := 'Y';
      ELSE
        fnd_message.set_name ('IGS', 'IGS_SS_AS_ORDER_NO_DOC');
        p_hint_message := fnd_message.get;
        --
        -- Neither of Transcript and Enrollment Certification are allowed.
        -- Hence do not allow request.
        --
        p_request_allowed := 'N';
        p_transcript_allowed := 'N';
        p_encert_allowed := 'N';
      END IF;
    END IF;
  END get_summary_display_message;
  --
  --
  --
  FUNCTION get_item_details_for_order (p_order_number NUMBER)
    RETURN VARCHAR2 AS
    --
    -- Bug 2677640 added RECIP_PERS_NAME to query
    --
    CURSOR cur_item IS
      SELECT   order_number,
               lkup.meaning doc_type,
               item_number,
               item_status,
               recip_inst_name,
               recip_pers_name
      FROM     igs_as_doc_details dtls,
               igs_lookups_view lkup
      WHERE    dtls.document_sub_type = lkup.lookup_code
      AND      lkup.lookup_type = 'IGS_AS_DOCUMENT_SUB_TYPE'
      AND      order_number = p_order_number
      ORDER BY item_number; --msrinivi, for bug #2318474
    lvdocdetails VARCHAR2 (2000);
  BEGIN
    FOR cur_dtl IN cur_item LOOP
      -- Bug 2677640 Display Recipient name when entered else show Organisation name
      IF cur_dtl.recip_pers_name IS NULL THEN
        lvdocdetails :=    lvdocdetails
                        || 'Document No: '
                        || TO_CHAR (cur_item%ROWCOUNT)
                        || '<BR>'
                        || 'Recipient:  '
                        || cur_dtl.recip_inst_name
                        || '<BR>'
                        || 'Item Type:  '
                        || cur_dtl.doc_type
                        || '<BR>'
                        || '<BR>'
                        || fnd_global.newline ();
      ELSE
        lvdocdetails :=    lvdocdetails
                        || 'Document No: '
                        || TO_CHAR (cur_item%ROWCOUNT)
                        || '<BR>'
                        || 'Recipient:  '
                        || cur_dtl.recip_pers_name
                        || '<BR>'
                        || 'Item Type:  '
                        || cur_dtl.doc_type
                        || '<BR>'
                        || '<BR>'
                        || fnd_global.newline ();
      END IF;
    END LOOP;
    IF RTRIM (LTRIM (lvdocdetails)) IS NULL THEN
      RETURN fnd_message.get_string ('IGS', 'IGS_SS_AS_NO_ITEM');
    ELSE
      RETURN lvdocdetails;
    END IF;
  END get_item_details_for_order;

  FUNCTION get_order_details_include_addr (p_item_number NUMBER)
    RETURN VARCHAR2 AS
    -- Bug 2677640 added RECIP_PERS_NAME to query
    CURSOR cur_item IS
      SELECT   order_number,
               lkup.meaning doc_type,
               item_number,
               item_status,
               recip_inst_name,
               recip_pers_name,
                  recip_addr_line_1
               || ' '
               || recip_addr_line_2
               || ' '
               || recip_addr_line_3
               || ' '
               || recip_addr_line_4
               || ','
               || recip_city
               || ' '
               || recip_state
               || ', '
               || recip_country addr
      FROM     igs_as_doc_details dtls,
               igs_lookups_view lkup
      WHERE    dtls.document_sub_type = lkup.lookup_code
      AND      lkup.lookup_type = 'IGS_AS_DOCUMENT_SUB_TYPE'
      AND      item_number = p_item_number
      ORDER BY item_number; --msrinivi, for bug #2318474
    lvdocdetails VARCHAR2 (2000);
  BEGIN
    FOR cur_dtl IN cur_item LOOP
      -- Bug 2677640 Display Recipient name when entered else show Organisation name
      IF cur_dtl.recip_pers_name IS NULL THEN
        lvdocdetails :=    lvdocdetails
                        || 'Document No: '
                        || TO_CHAR (cur_item%ROWCOUNT)
                        || '<BR>'
                        || 'Recipient:  '
                        || cur_dtl.recip_inst_name
                        || '<BR>'
                        || 'Recipient Address:  '
                        || cur_dtl.addr
                        || '<BR>'
                        || 'Item Type:  '
                        || cur_dtl.doc_type
                        || '<BR>'
                        || '<BR>'
                        || fnd_global.newline ();
      ELSE
        lvdocdetails :=    lvdocdetails
                        || 'Document No: '
                        || TO_CHAR (cur_item%ROWCOUNT)
                        || '<BR>'
                        || 'Recipient:  '
                        || cur_dtl.recip_pers_name
                        || '<BR>'
                        || 'Recipient Address:  '
                        || cur_dtl.addr
                        || '<BR>'
                        || 'Item Type:  '
                        || cur_dtl.doc_type
                        || '<BR>'
                        || '<BR>'
                        || fnd_global.newline ();
      END IF;
    END LOOP;
    IF RTRIM (LTRIM (lvdocdetails)) IS NULL THEN
      RETURN fnd_message.get_string ('IGS', 'IGS_SS_AS_NO_ITEM');
    ELSE
      RETURN lvdocdetails;
    END IF;
  END get_order_details_include_addr;
  --
  --
  --
  FUNCTION get_transcript_fee (
    p_person_id                    IN     NUMBER,
    p_document_type                IN     VARCHAR2,
    p_number_of_copies             IN     NUMBER,
    p_include_delivery_fee         IN     VARCHAR2,
    p_delivery_method_type         IN     VARCHAR2,
    p_item_number                  IN     NUMBER
  )
    RETURN NUMBER IS
    --
    --  Cursor that gets the document fee setup details
    --  for the given document type.
    --
    CURSOR cur_doc_setup (cp_document_type IN VARCHAR2, l_start_at IN NUMBER) IS
      SELECT   dfs.lower_range lower_range,
               dfs.upper_range upper_range,
               dfs.payment_type payment_type,
               dfs.amount amount
      FROM     igs_as_doc_fee_stup dfs
      WHERE    dfs.document_type = cp_document_type
      AND      l_start_at < upper_range
      ORDER BY dfs.lower_range;
    --
    --  Cursor that gets the document delivery setup details
    --  for the given document delivery method type.
    --
    CURSOR cur_delivery_fee_setup (cp_delivery_method_type IN VARCHAR2) IS
      SELECT dlfs.amount amount
      FROM   igs_as_doc_dlvy_fee dlfs
      WHERE  dlfs.delivery_method_type = cp_delivery_method_type;
    --
    --  Cursor that checks if a person has paid life time fee or not
    --
    CURSOR cur_life_time_fee_paid (cp_person_id IN NUMBER) IS
      SELECT NVL (ltfp.lifetime_fee_paid, 'N') life_time_fee_paid
      FROM   igs_as_doc_fee_pmnt ltfp
      WHERE  ltfp.document_type = 'TRANSCRIPT'
      AND    fee_paid_type = 'LIFETIME'
      AND    ltfp.person_id = cp_person_id;
    --
    CURSOR cur_num_stu_ords (cp_item_number IN NUMBER) IS
      SELECT NVL (SUM (doc.num_of_copies), 0)
      FROM   igs_as_doc_details doc,
             igs_as_order_hdr hdr
      WHERE  doc.person_id = p_person_id
      AND    doc.plan_id IS NULL
      AND    doc.item_number < cp_item_number
      AND    doc.document_type =
               DECODE (
                 p_document_type,
                 'ENCERT', 'ENCERT',
                 'OFFICIAL', 'TRANSCRIPT',
                 'UNOFFICIAL', 'TRANSCRIPT',
                 'TRANSCRIPT')
      AND    hdr.order_number = doc.order_number
      AND    NVL (hdr.request_type, 'W') <> 'B';
    --
    CURSOR cur_ttl_itm_chrgd_und_free IS
      SELECT NVL (SUM (num_of_copies), 0)
      FROM   igs_as_doc_details
      WHERE  person_id = p_person_id
      AND    item_number <> NVL (p_item_number, -1)
      AND    plan_id IN (SELECT plan_id
                         FROM   igs_as_servic_plan
                         WHERE  plan_type IN (SELECT meaning
                                              FROM   igs_lookups_view
                                              WHERE  lookup_type = 'TRANSCRIPT_SERVICE_PLAN_TYPE'
                                              AND    lookup_code = 'FREE_TRANSCRIPT'));
    --
    CURSOR c_num_free_cops IS
      SELECT NVL (quantity_limit, 0)
      FROM   igs_as_servic_plan
      WHERE  plan_type IN (SELECT meaning
                           FROM   igs_lookups_view
                           WHERE  lookup_type = 'TRANSCRIPT_SERVICE_PLAN_TYPE'
                           AND    lookup_code = 'FREE_TRANSCRIPT');
    --
    --  Local Variables
    --
    l_life_time_fee_paid      VARCHAR2 (1);
    rec_cur_doc_setup         cur_doc_setup%ROWTYPE;
    l_document_fee            NUMBER (20, 2)                          DEFAULT 0;
    l_delivery_fee            igs_as_doc_dlvy_fee.amount%TYPE;
    l_number_of_copies        NUMBER;
    l_copies_in_slab          NUMBER;
    l_num_stu_ords            NUMBER                                  := 0;
    l_start_at                NUMBER                                  := 0;
    l_temp_var                NUMBER                                  := 0;
    l_diff_in_range           NUMBER                                  := 0;
    l_doc_type                igs_as_doc_details.document_type%TYPE;
    l_ttl_itm_chrgd_und_free  NUMBER;
    l_num_free_cops           NUMBER;
    l_diff_free_ofr_and_avail NUMBER;
  BEGIN
    SELECT   DECODE (
               p_document_type,
                 'ENCERT', 'ENCERT',
                 'OFFICIAL', 'TRANSCRIPT',
                 'UNOFFICIAL', 'TRANSCRIPT',
                 'TRANSCRIPT')
    INTO     l_doc_type
    FROM     dual;
    --
    -- Get prev num of copies placed by the student
    --
    OPEN cur_num_stu_ords (NVL (p_item_number, 999999999999999));
    FETCH cur_num_stu_ords INTO l_num_stu_ords;
    CLOSE cur_num_stu_ords;
    --
    --  Check if the person has paid life time transcript fee.
    --
    OPEN cur_life_time_fee_paid (p_person_id);
    FETCH cur_life_time_fee_paid INTO l_life_time_fee_paid;
    CLOSE cur_life_time_fee_paid;
    --
    --  Get the delivery fee for the document.
    --
    OPEN cur_delivery_fee_setup (p_delivery_method_type);
    FETCH cur_delivery_fee_setup INTO l_delivery_fee;
    CLOSE cur_delivery_fee_setup;
    -- If an item were given free transcripts
    -- and part of the same item was charged since
    -- num_cop_ordered > num_avail under free
    OPEN cur_ttl_itm_chrgd_und_free;
    FETCH cur_ttl_itm_chrgd_und_free INTO l_ttl_itm_chrgd_und_free;
    CLOSE cur_ttl_itm_chrgd_und_free;
    --
    OPEN c_num_free_cops;
    FETCH c_num_free_cops INTO l_num_free_cops;
    CLOSE c_num_free_cops;
    --
    l_diff_free_ofr_and_avail := NVL (l_ttl_itm_chrgd_und_free, 0) - NVL (l_num_free_cops, 0);
    l_start_at := NVL (l_num_stu_ords, 0);
    --
    IF  NVL (l_diff_free_ofr_and_avail, 0) >= 0
        AND l_doc_type = 'TRANSCRIPT' THEN
      l_start_at := l_start_at + NVL (l_diff_free_ofr_and_avail, 0);
    END IF;
    --
    l_number_of_copies := NVL (p_number_of_copies, 0);
    --
    --  Calculate the Document Fee only if the Life Time Transcript is not paid.
    --
    IF (l_doc_type = 'TRANSCRIPT'
        AND (NVL (l_life_time_fee_paid, 'N') = 'N')
       )
       OR l_doc_type = 'ENCERT' THEN
      --
      --  Loop through the document setup to compute the fee for the transcripts.
      --
      FOR rec_cur_doc_setup IN cur_doc_setup (p_document_type, l_start_at) LOOP
        l_temp_var := l_temp_var + 1;
        IF l_temp_var > 100 THEN
          l_document_fee := 10000;
        END IF;
        EXIT WHEN l_number_of_copies = 0
               OR l_temp_var > 100;
        --
        l_copies_in_slab := 0;
        l_diff_in_range := (rec_cur_doc_setup.upper_range - rec_cur_doc_setup.lower_range) + 1;
        --
        IF cur_doc_setup%ROWCOUNT = 1 THEN
          IF l_number_of_copies > (rec_cur_doc_setup.upper_range - l_start_at) THEN
            l_copies_in_slab := rec_cur_doc_setup.upper_range - l_start_at;
          ELSE
            l_copies_in_slab := l_number_of_copies;
          END IF;
          --
          IF (rec_cur_doc_setup.payment_type IN ('O', 'F')) THEN
            l_document_fee := l_document_fee + rec_cur_doc_setup.amount;
            EXIT;
          ELSE
            l_document_fee :=   l_document_fee
                              + (l_copies_in_slab * rec_cur_doc_setup.amount);
          END IF;
        ELSE
          IF l_diff_in_range > l_number_of_copies THEN
            l_copies_in_slab := l_number_of_copies;
          ELSE
            l_copies_in_slab := l_diff_in_range;
          END IF;
          --
          IF (rec_cur_doc_setup.payment_type IN ('O', 'F')) THEN
            l_document_fee := l_document_fee + rec_cur_doc_setup.amount;
            EXIT;
          ELSE
            l_document_fee :=   l_document_fee
                              + (l_copies_in_slab * rec_cur_doc_setup.amount);
          END IF;
        END IF;
        l_number_of_copies := l_number_of_copies - l_copies_in_slab;
      END LOOP;
    END IF;
    --
    --  Return the sum of Document Fee and Delivery Fee for the document.
    --
    IF (p_include_delivery_fee = 'Y') THEN
      RETURN (NVL (l_document_fee, 0) + NVL (l_delivery_fee, 0));
    ELSE
      RETURN (NVL (l_document_fee, 0));
    END IF;
  END get_transcript_fee;
  --
  --
  --
  FUNCTION enrp_get_career_dates (p_person_id IN NUMBER, p_course_type IN VARCHAR2)
    RETURN VARCHAR2 AS
    CURSOR c_comm_dt (
             cp_person_id igs_pe_person.person_id%TYPE,
             cp_course_type igs_ps_type.course_type%TYPE
           ) IS
      SELECT   spa.commencement_dt
      FROM     igs_en_stdnt_ps_att_all spa,
               igs_ps_ver_all pv
      WHERE    spa.person_id = cp_person_id
      AND      pv.course_type = cp_course_type
      AND      spa.course_cd = pv.course_cd
      AND      spa.version_number = pv.version_number
      AND      spa.course_attempt_status <> 'UNCONFIRM'
      AND      spa.commencement_dt IS NOT NULL
      ORDER BY spa.commencement_dt ASC;
    CURSOR c_cmpl_dt (
             cp_person_id igs_pe_person.person_id%TYPE,
             cp_course_type igs_ps_type.course_type%TYPE
           ) IS
      SELECT   spa.course_rqrmnts_complete_dt
      FROM     igs_en_stdnt_ps_att_all spa,
               igs_ps_ver_all pv
      WHERE    spa.person_id = cp_person_id
      AND      pv.course_type = cp_course_type
      AND      spa.course_cd = pv.course_cd
      AND      spa.version_number = pv.version_number
      AND      spa.course_attempt_status IN ('ENROLLED', 'COMPLETED')
      ORDER BY spa.course_rqrmnts_complete_dt DESC;
    v_commencement_dt            igs_en_stdnt_ps_att_all.commencement_dt%TYPE;
    v_course_rqrmnts_complete_dt igs_en_stdnt_ps_att_all.course_rqrmnts_complete_dt%TYPE;
  BEGIN
    /*  This function will return the earliest commencement date and the latest
        course requirements completion date of the particular student in a particular
      career passed as parameter
      1. if there are no commencement dates available, for the programs which are not 'UNCOMFIRMED',
         within the specified career, then this function will return null
      2. If more than one program with the specified career has commencement date
         then the least/earliest will be picked up
      3. If the COURSE_RQRMNTS_COMPLETE_DT is not availble for any of the
         'ENROLLED' and 'COMPLETED' programs, then requirements completion date will not be returned
      4. If all the 'ENROLLED' and 'COMPLETED' programs have a requirments completion date
         the latest of the dates will be picked up
      5. If the Commencement date is found and Completiont date is not
         then the commencement date alone will be returned
      6. If the Commencement date and Completiont date are found then both will be returned
      7. A freak case is also handled where the commencement date is not available
         but the completion date is found then completion date is being returned
    */
    OPEN c_comm_dt (p_person_id, p_course_type);
    FETCH c_comm_dt INTO v_commencement_dt;
    IF c_comm_dt%NOTFOUND THEN
      CLOSE c_comm_dt;
      RETURN NULL;
    END IF;
    CLOSE c_comm_dt;
    OPEN c_cmpl_dt (p_person_id, p_course_type);
    FETCH c_cmpl_dt INTO v_course_rqrmnts_complete_dt;
    IF c_cmpl_dt%NOTFOUND THEN
      CLOSE c_cmpl_dt;
      IF v_commencement_dt IS NOT NULL THEN
        RETURN (TO_CHAR (v_commencement_dt) || ' - ');
      ELSE
        RETURN NULL;
      END IF;
    END IF;
    CLOSE c_cmpl_dt;
    IF  v_commencement_dt IS NULL
        AND v_course_rqrmnts_complete_dt IS NULL THEN
      RETURN NULL;
    ELSIF  v_commencement_dt IS NOT NULL
           AND v_course_rqrmnts_complete_dt IS NULL THEN
      RETURN (TO_CHAR (v_commencement_dt) || ' - ');
    ELSIF  v_commencement_dt IS NULL
           AND v_course_rqrmnts_complete_dt IS NOT NULL THEN
      -- this case should ideally not occur just added in case
      RETURN ('NULL TO '|| TO_CHAR (v_course_rqrmnts_complete_dt));
    ELSIF  v_commencement_dt IS NOT NULL
           AND v_course_rqrmnts_complete_dt IS NOT NULL THEN
      RETURN (TO_CHAR (v_commencement_dt) || ' - ' || TO_CHAR (v_course_rqrmnts_complete_dt));
    END IF;
  END enrp_get_career_dates;
  --
  --
  --
  PROCEDURE create_invoice (
    p_order_number                 IN     NUMBER,
    p_payment_type                 IN     VARCHAR2,
    p_invoice_id                   OUT NOCOPY NUMBER,
    p_return_status                OUT NOCOPY VARCHAR2,
    p_msg_count                    OUT NOCOPY NUMBER,
    p_msg_data                     OUT NOCOPY VARCHAR2,
    p_waiver_amount                OUT NOCOPY NUMBER
  ) AS
    ------------------------------------------------------------------------------
    -- CHANGE HISTORY:
    -- WHO        WHEN        WHAT
    -- UUDAYAPR   09-MAR-2004 BUG#3478599.Added a new cursor c_igs_fi_invln to check whether a record already exists
    --                        for the given invoice id with the error flag set to y .
    -- vvutukur   27-Nov-2002 Enh#2584986.GL Interface Build. Removed the references to igs_fi_cur. Instead defaulted
    --                        the currency with the one that is set up in System Options Form. The same has been
    --                        used for the creation of the charge record.Passed exchange_rate always 1.
    -- vvutukur   19-Sep-2002 Enh#2564643.Removed references to subaccount_id from 1)cursor c_ftci and
    --                        2)call to IGS_FI_SS_CHARGES_API_PVT.create_charge.
    -- kdande     28-Jun-2002 Bug# 2434054. Changed the cursor c_ftci to consider
    --                        only the Active Fee Type Calendar Instances.
    -- smadathi   24-Jun-2002 Bug 2404720. CURSOR c_ftci select statement modified
    --                        to include DESCRIPTION column. The call to
    --                        igs_fi_ss_charges_api_pvt.create_charge was modified
    --                        to pass this description value to the formal parameter
    --                        p_invoice_desc.
    -- vvutukur   13-may-2002 Bug#2426560.Modified cursor c_ftci to select active
    --                        fee type of system fee type as Document.ie., included
    --                        closed_ind also in where clause.
    -- msrinivi   12-Aug-2002 Bug 2490258 - Added exception block to create_invoice
    --                         and raised error when order not found, sysdate
    --                         not in the ftci start end date aliases
    -- swaghmar	  22-Aug-2005 Bug 4506599
    ------------------------------------------------------------------------------
    CURSOR c_ord (cp_order_number igs_as_order_hdr.order_number%TYPE) IS
      SELECT (ord.delivery_fee + ord.order_fee) total_amount,
             ord.*,
             ord.ROWID row_id
      FROM   igs_as_order_hdr ord
      WHERE  order_number = cp_order_number;

    CURSOR c_inv(cp_inv igs_as_order_hdr.invoice_id%TYPE) IS
        SELECT invoice_amount_due
          FROM igs_fi_inv_int_all
         WHERE invoice_id = cp_inv;


    v_ord_rec        c_ord%ROWTYPE;

    CURSOR c_ftci IS
      SELECT   ftci.fee_cal_type,
               ftci.fee_ci_sequence_number,
               ftci.fee_type,
               ft.description description
      FROM     igs_fi_f_typ_ca_inst ftci,
               igs_ca_da_inst_v daiv,
               igs_ca_da_inst_v daiv1,
               igs_fi_fee_type ft,
               igs_fi_fee_str_stat stat
      WHERE    ftci.fee_type = ft.fee_type
      AND      ft.s_fee_type = 'DOCUMENT'
      AND      ftci.fee_type_ci_status = stat.fee_structure_status
      AND      stat.s_fee_structure_status = 'ACTIVE'
      AND      NVL (ft.closed_ind, 'N') = 'N'
      AND      (daiv.dt_alias = ftci.start_dt_alias
                AND daiv.sequence_number = ftci.start_dai_sequence_number
                AND daiv.cal_type = ftci.fee_cal_type
                AND daiv.ci_sequence_number = ftci.fee_ci_sequence_number
               )
      AND      (daiv1.dt_alias = ftci.end_dt_alias
                AND daiv1.sequence_number = ftci.end_dai_sequence_number
                AND daiv1.cal_type = ftci.fee_cal_type
                AND daiv1.ci_sequence_number = ftci.fee_ci_sequence_number
               )
      AND      SYSDATE BETWEEN daiv.alias_val AND NVL (daiv1.alias_val, SYSDATE)
      ORDER BY daiv.alias_val DESC;
    v_ftci_rec       c_ftci%ROWTYPE;
    l_v_currency     igs_fi_control_all.currency_cd%TYPE;
    l_v_curr_desc    fnd_currencies_tl.NAME%TYPE;
    l_v_message_name fnd_new_messages.message_name%TYPE;
    --CURSOR ADDED FOR CHECKING WHETHER A RECORD ALREADY EXISTS FOR THE INVOICE ID GIVEN.
    CURSOR  c_igs_fi_invln(cp_invoice_id igs_fi_inv_int.invoice_id%TYPE) IS
      SELECT  '1'
      FROM    igs_fi_invln_int_all
      WHERE   invoice_id = cp_invoice_id
      AND     NVL(error_account,'N') = 'Y'
      AND     ROWNUM  < 2;
    rec_c_igs_fi_invln c_igs_fi_invln%ROWTYPE;
    p_waiver_amount_ord NUMBER;
  BEGIN
    OPEN c_ord (p_order_number);
    FETCH c_ord INTO v_ord_rec;
    IF c_ord%NOTFOUND THEN
      CLOSE c_ord;
      p_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name ('IGS', 'IGS_SS_AS_NO_SUCH_ORD');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE c_ord;
    IF v_ord_rec.invoice_id IS NOT NULL THEN
      -- check if invoice is generated with error account 'Y'
      OPEN  c_igs_fi_invln(cp_invoice_id => v_ord_rec.invoice_id);
      FETCH c_igs_fi_invln INTO rec_c_igs_fi_invln;
      IF c_igs_fi_invln%FOUND THEN
        CLOSE c_igs_fi_invln;
        p_return_status := fnd_api.g_ret_sts_error;
        fnd_message.set_name ('IGS', 'IGS_FI_SRC_TXN_ACC_INV');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
      CLOSE c_igs_fi_invln;

      p_return_status := fnd_api.g_ret_sts_success;
      p_invoice_id := v_ord_rec.invoice_id;
      p_waiver_amount := '0.0';
    ELSE
      OPEN c_ftci;
      FETCH c_ftci INTO v_ftci_rec;
      IF c_ftci%NOTFOUND THEN
        CLOSE c_ftci;
        p_return_status := fnd_api.g_ret_sts_error;
        fnd_message.set_name ('IGS', 'IGS_SS_AS_FI_CAL_NOT_SET');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
      CLOSE c_ftci;
      --Capture the default currency that is set up in System Options Form.
      igs_fi_gen_gl.finp_get_cur (
        p_v_currency_cd                => l_v_currency,
        p_v_curr_desc                  => l_v_curr_desc,
        p_v_message_name               => l_v_message_name
      );
      IF l_v_message_name IS NOT NULL THEN
        fnd_message.set_name ('IGS', l_v_message_name);
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
      igs_fi_ss_charges_api_pvt.create_charge (
        p_api_version                  => 2.0,
        p_init_msg_list                => fnd_api.g_false,
        p_commit                       => fnd_api.g_false,
        p_validation_level             => fnd_api.g_valid_level_full,
        p_person_id                    => v_ord_rec.person_id,
        p_fee_type                     => v_ftci_rec.fee_type,
        p_fee_cat                      => NULL,
        p_fee_cal_type                 => v_ftci_rec.fee_cal_type,
        p_fee_ci_sequence_number       => v_ftci_rec.fee_ci_sequence_number,
        p_course_cd                    => NULL,
        p_attendance_type              => NULL,
        p_attendance_mode              => NULL,
        p_invoice_amount               => v_ord_rec.total_amount,
        p_invoice_creation_date        => SYSDATE,
        p_invoice_desc                 => v_ftci_rec.description,
        p_transaction_type             => 'DOCUMENT',
        p_currency_cd                  => l_v_currency,
        p_exchange_rate                => 1,
        p_effective_date               => NULL,
        p_waiver_flag                  => NULL,
        p_waiver_reason                => NULL,
        p_source_transaction_id        => NULL,
        p_invoice_id                   => p_invoice_id,
        x_return_status                => p_return_status,
        x_msg_count                    => p_msg_count,
        x_msg_data                     => p_msg_data,
        x_waiver_amount                => p_waiver_amount
      );
      IF (p_return_status <> fnd_api.g_ret_sts_success) THEN
        RETURN;
      END IF;
      --
      -- update the Order header table with the Invoice id returned by the create_charge api
      --
      FOR order_hdr_rec IN c_ord (p_order_number) LOOP
        igs_as_order_hdr_pkg.update_row (
          x_mode                         => 'R',
          x_rowid                        => order_hdr_rec.row_id,
          x_order_number                 => order_hdr_rec.order_number,
          x_order_status                 => order_hdr_rec.order_status,
          x_date_completed               => order_hdr_rec.date_completed,
          x_person_id                    => order_hdr_rec.person_id,
          x_addr_line_1                  => order_hdr_rec.addr_line_1,
          x_addr_line_2                  => order_hdr_rec.addr_line_2,
          x_addr_line_3                  => order_hdr_rec.addr_line_3,
          x_addr_line_4                  => order_hdr_rec.addr_line_4,
          x_city                         => order_hdr_rec.city,
          x_state                        => order_hdr_rec.state,
          x_province                     => order_hdr_rec.province,
          x_county                       => order_hdr_rec.county,
          x_country                      => order_hdr_rec.country,
          x_postal_code                  => order_hdr_rec.postal_code,
          x_email_address                => order_hdr_rec.email_address,
          x_phone_country_code           => order_hdr_rec.phone_country_code,
          x_phone_area_code              => order_hdr_rec.phone_area_code,
          x_phone_number                 => order_hdr_rec.phone_number,
          x_phone_extension              => order_hdr_rec.phone_extension,
          x_fax_country_code             => order_hdr_rec.fax_country_code,
          x_fax_area_code                => order_hdr_rec.fax_area_code,
          x_fax_number                   => order_hdr_rec.fax_number,
          x_delivery_fee                 => order_hdr_rec.delivery_fee,
          x_order_fee                    => order_hdr_rec.order_fee,
          x_request_type                 => order_hdr_rec.request_type,
          x_submit_method                => order_hdr_rec.submit_method,
          x_invoice_id                   => p_invoice_id, -- this is the value that is being updated
          x_return_status                => p_return_status,
          x_msg_data                     => p_msg_data,
          x_msg_count                    => p_msg_count,
          x_order_placed_by              => order_hdr_rec.order_placed_by,
          x_order_description            => order_hdr_rec.order_description,
          p_init_msg_list                => FND_API.G_FALSE
        );
        IF (p_return_status <> fnd_api.g_ret_sts_success) THEN
          RETURN;
        END IF;
      END LOOP;
    END IF;
    -- 22 Aug 05 swaghmar      Modified for Bug 4506599
    OPEN c_inv(v_ord_rec.invoice_id);
    FETCH c_inv INTO p_waiver_amount_ord;
    CLOSE c_inv;
    IF ((p_payment_type = 'BILL_ME_LATER') OR (p_waiver_amount_ord = 0)) THEN
                        igs_as_documents_api.update_document_details (
				p_order_number                 => p_order_number,
				p_item_number                  => NULL,
				p_init_msg_list                => fnd_api.g_false,
				p_return_status                => p_return_status,
				p_msg_count                    => p_msg_count,
				p_msg_data                     => p_msg_data
				);
    END IF;

    RETURN;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      p_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count => p_msg_count, p_data => p_msg_data);
      RETURN;
    WHEN fnd_api.g_exc_unexpected_error THEN
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => p_msg_count, p_data => p_msg_data);
      RETURN;
    WHEN OTHERS THEN
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_message.set_token ('NAME', 'CREATE_INVOICE_ID : ' || SQLERRM);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get (p_count => p_msg_count, p_data => p_msg_data);
      RETURN;
  END create_invoice;
  --
  --
  --
  FUNCTION show_bill_me_later (p_person_id IN NUMBER)
    RETURN VARCHAR2 IS
    --
    --  Cursor to find out if the institution allows Bill Me Later option
    --  for Order Payment made by the student. This check is not for the
    --  administrator
    --
    CURSOR cur_allow_bill_me_later IS
      SELECT NVL (bill_me_later_ind, 'N') bill_me_later_ind
      FROM   igs_as_docproc_stup;
    --
    --  Cursor to find out if the student is a student is a current or
    --  former student
    --
    CURSOR cur_student_type (cp_person_id IN NUMBER) IS
      SELECT 'Y' current_student
      FROM   igs_pe_person_types typ,
             igs_pe_typ_instances_all inst
      WHERE  inst.person_id = cp_person_id
      AND    inst.person_type_code = typ.person_type_code
      AND    typ.system_type = 'STUDENT'
      AND    inst.start_date <= SYSDATE
      AND    NVL (inst.end_date, SYSDATE) >= SYSDATE;
    --
    --  Local variables
    --
    rec_cur_student_type        cur_student_type%ROWTYPE;
    rec_cur_allow_bill_me_later cur_allow_bill_me_later%ROWTYPE;
    allow_bill_me_later         VARCHAR2 (1);
  BEGIN
    --
    --  Check if Bill Me Later is allowed for the student or not
    --
    OPEN cur_allow_bill_me_later;
    FETCH cur_allow_bill_me_later INTO rec_cur_allow_bill_me_later;
    CLOSE cur_allow_bill_me_later;
    --
    IF (rec_cur_allow_bill_me_later.bill_me_later_ind = 'Y') THEN
      allow_bill_me_later := 'Y';
    ELSE
      allow_bill_me_later := 'N';
    END IF;
    --
    --  Check for student type only if the institution is allowing Bill Me Later
    --
    IF (allow_bill_me_later = 'Y') THEN
      --
      --  Check if the Student is current student or former student
      --
      OPEN cur_student_type (p_person_id);
      FETCH cur_student_type INTO rec_cur_student_type;
      IF (cur_student_type%FOUND) THEN
        allow_bill_me_later := 'Y';
      ELSE
        allow_bill_me_later := 'N';
      END IF;
      CLOSE cur_student_type;
    END IF;
    --
    RETURN (allow_bill_me_later);
  END show_bill_me_later;
  --
  --
  --
  PROCEDURE update_order_fee (
    p_order_number                        NUMBER,
    p_item_number                         NUMBER,
    p_old_sub_doc_type                    VARCHAR2,
    p_old_deliv_type                      VARCHAR2,
    p_old_num_copies                      VARCHAR2,
    p_new_sub_doc_type                    VARCHAR2,
    p_new_deliv_type                      VARCHAR2,
    p_new_num_copies                      VARCHAR2,
    p_return_status                OUT NOCOPY VARCHAR2,
    p_msg_data                     OUT NOCOPY VARCHAR2,
    p_msg_count                    OUT NOCOPY NUMBER
  ) AS
    CURSOR c_order IS
      SELECT ROWID row_id,
             hdr.*
      FROM   igs_as_order_hdr hdr
      WHERE  order_number = p_order_number;
    cur_order       c_order%ROWTYPE;
    CURSOR c_doc IS
      SELECT SUM (NVL (overridden_document_fee, doc_fee_per_copy)),
             SUM (NVL (overridden_doc_delivery_fee, delivery_fee))
      FROM   igs_as_doc_details
      WHERE  order_number = p_order_number;
    --
    -- Variables
    --
    lndocfeepercopy igs_as_doc_details.doc_fee_per_copy%TYPE;
    lndeliveryfee   igs_as_doc_details.delivery_fee%TYPE;
    l_new_doc_fee   igs_as_doc_details.doc_fee_per_copy%TYPE;
    l_dummy_plan_id igs_as_doc_details.plan_id%TYPE;
    --
  BEGIN
    --
    OPEN c_order;
    FETCH c_order INTO cur_order;
    CLOSE c_order;
    --
    OPEN c_doc;
    FETCH c_doc INTO lndocfeepercopy,
                     lndeliveryfee;
    CLOSE c_doc;
    --
    -- Once all the information are available make a call to the update row of the order
    -- header table.
    --
    igs_as_order_hdr_pkg.update_row (
      x_msg_count                    => p_msg_count,
      x_msg_data                     => p_msg_data,
      x_return_status                => p_return_status,
      x_rowid                        => cur_order.row_id,
      x_order_number                 => cur_order.order_number,
      x_order_status                 => cur_order.order_status,
      x_date_completed               => cur_order.date_completed,
      x_person_id                    => cur_order.person_id,
      x_addr_line_1                  => cur_order.addr_line_1,
      x_addr_line_2                  => cur_order.addr_line_2,
      x_addr_line_3                  => cur_order.addr_line_3,
      x_addr_line_4                  => cur_order.addr_line_4,
      x_city                         => cur_order.city,
      x_state                        => cur_order.state,
      x_province                     => cur_order.province,
      x_county                       => cur_order.county,
      x_country                      => cur_order.country,
      x_postal_code                  => cur_order.postal_code,
      x_email_address                => cur_order.email_address,
      x_phone_country_code           => cur_order.phone_country_code,
      x_phone_area_code              => cur_order.phone_area_code,
      x_phone_number                 => cur_order.phone_number,
      x_phone_extension              => cur_order.phone_extension,
      x_fax_country_code             => cur_order.fax_country_code,
      x_fax_area_code                => cur_order.fax_area_code,
      x_fax_number                   => cur_order.fax_number,
      --X_LIFE_TIME_FEE_PAID    => cur_order.LIFE_TIME_FEE_PAID,
      x_delivery_fee                 => NVL (lndeliveryfee, 0),
      x_order_fee                    => NVL (lndocfeepercopy, 0),
      x_request_type                 => cur_order.request_type,
      x_submit_method                => cur_order.submit_method,
      x_invoice_id                   => cur_order.invoice_id,
      x_order_placed_by              => cur_order.order_placed_by,
      x_order_description            => cur_order.order_description
    );
  END update_order_fee;
  --
  --
  --

  --swaghmar bug# 4377816
  FUNCTION inst_is_edi_partner (
    p_inst_code VARCHAR2
  ) RETURN VARCHAR2 AS
  --
    CURSOR c_edi IS
      SELECT edi_transaction_handling,
             edi_id_number,
             edi_payment_method,
             edi_payment_format,
             edi_remittance_method,
             edi_remittance_instruction,
             edi_tp_header_id,
             edi_ece_tp_location_code
      FROM   hz_contact_points cont,
	     igs_pe_hz_parties ipz,
             hz_parties org
      WHERE  cont.owner_table_name = 'HZ_PARTIES'
      AND    cont.owner_table_id = org.party_id
      AND    ipz.party_id = org.party_id
      AND    ipz.oss_org_unit_cd = p_inst_code;
    cur_edi       c_edi%ROWTYPE;
    lvcedipartner VARCHAR2 (1)    DEFAULT 'N';
  BEGIN
    /* The fuction will be enabled when it is decided that EDI related info will be available to OSS.
       This function is just a place holder and currently always returns N meaning
       Institution is not an EDI partner.
    FOR  CUR_EDI IN C_EDI LOOP
      IF CUR_EDI.EDI_ID_NUMBER IS NOT NULL THEN
        lvcEDIPartner := 'Y';
        EXIT;
      END IF;
    END LOOP;
    */
    RETURN lvcedipartner;
  END;
  --
  --
  --
  FUNCTION is_all_progs_allowed
  RETURN VARCHAR2 AS
    --
    CURSOR c_all_prog IS
      SELECT all_acad_hist_in_one_doc_ind
      FROM   igs_as_docproc_stup;
    --
    l_all_prg VARCHAR2 (1);
  BEGIN
    OPEN c_all_prog;
    FETCH c_all_prog INTO l_all_prg;
    CLOSE c_all_prog;
    --
    RETURN l_all_prg;
  END is_all_progs_allowed;

  PROCEDURE create_as_application (
    p_credit_id                    IN     igs_fi_applications.credit_id%TYPE,
    p_invoice_id                   IN     igs_fi_applications.invoice_id%TYPE,
    p_amount_apply                 IN     igs_fi_applications.amount_applied%TYPE,
    p_appl_type                    IN     igs_fi_applications.application_type%TYPE,
    p_appl_hierarchy_id            IN     igs_fi_applications.appl_hierarchy_id%TYPE,
    p_validation                   IN     VARCHAR2,
    p_application_id               OUT NOCOPY igs_fi_applications.application_id%TYPE,
    p_err_msg                      OUT NOCOPY fnd_new_messages.message_name%TYPE,
    p_status                       OUT NOCOPY VARCHAR2
  ) AS
    /*----------------------------------------------------------------------------
     ||  Created By :
     ||  Created On :
     ||  Purpose :
     ||  Known limitations, enhancements or remarks :
     ||  Change History :
     ||  Who             When            What
     ||  (reverse chronological order - newest change first)
     || vvutukur     18-Nov-2002  Enh#2584986.Modified the call to create_application to pass sysdate to the
     ||                           new parameter p_d_gl_date.
     ----------------------------------------------------------------------------*/
    lb_status       BOOLEAN                                      := TRUE;
    l_dr_gl_ccid    igs_fi_cr_activities.dr_gl_ccid%TYPE;
    l_cr_gl_ccid    igs_fi_cr_activities.cr_gl_ccid%TYPE;
    l_dr_account_cd igs_fi_cr_activities.dr_account_cd%TYPE;
    l_cr_account_cd igs_fi_cr_activities.cr_account_cd%TYPE;
    l_unapp_amount  igs_fi_credits_all.unapplied_amount%TYPE;
    l_inv_amt_due   igs_fi_inv_int_all.invoice_amount_due%TYPE;
  BEGIN
    igs_fi_gen_007.create_application (
      p_application_id               => p_application_id,
      p_credit_id                    => p_credit_id,
      p_invoice_id                   => p_invoice_id,
      p_amount_apply                 => p_amount_apply,
      p_appl_type                    => p_appl_type,
      p_appl_hierarchy_id            => p_appl_hierarchy_id,
      p_validation                   => p_validation,
      p_dr_gl_ccid                   => l_dr_gl_ccid,
      p_cr_gl_ccid                   => l_cr_gl_ccid,
      p_dr_account_cd                => l_dr_account_cd,
      p_cr_account_cd                => l_cr_account_cd,
      p_unapp_amount                 => l_unapp_amount,
      p_inv_amt_due                  => l_inv_amt_due,
      p_err_msg                      => p_err_msg,
      p_status                       => lb_status,
      p_d_gl_date                    => TRUNC (SYSDATE)
    );
    IF (lb_status) THEN
      p_status := 'TRUE';
    ELSE
      p_status := 'FALSE';
    END IF;
  END create_as_application;
  --
  --
  --
  FUNCTION get_prg_st_end_dts (
    p_person_id NUMBER,
    p_course_cd VARCHAR2
  ) RETURN VARCHAR2 AS
    CURSOR c_sua_cmnt IS
      SELECT   load_description
      FROM     igs_en_su_attempt,
               igs_ca_teach_to_load_v
      WHERE    person_id = p_person_id
      AND      course_cd = p_course_cd
      AND      unit_attempt_status IN ('ENROLLED', 'COMPLETED', 'DUPLICATE', 'DISCONTIN')
      AND      teach_cal_type = cal_type
      AND      teach_ci_sequence_number = ci_sequence_number
      ORDER BY load_start_dt ASC;
    --
    CURSOR c_sua_end IS
      SELECT   load_description
      FROM     igs_en_su_attempt,
               igs_ca_teach_to_load_v
      WHERE    person_id = p_person_id
      AND      course_cd = p_course_cd
      AND      unit_attempt_status IN ('ENROLLED', 'COMPLETED', 'DUPLICATE', 'DISCONTIN')
      AND      teach_cal_type = cal_type
      AND      teach_ci_sequence_number = ci_sequence_number
      ORDER BY load_start_dt DESC;
    --
    CURSOR c_conferral_dt (p_person_id NUMBER, p_course_cd VARCHAR) IS
      SELECT spaa.conferral_date
      FROM   igs_en_spa_awd_aim spaa,
             igs_gr_graduand_all gr
      WHERE  spaa.person_id = p_person_id
      AND    spaa.course_cd = p_course_cd
      AND    gr.person_id = spaa.person_id
      AND    gr.course_cd = spaa.course_cd
      AND    gr.award_cd = spaa.award_cd
      AND    EXISTS (
               SELECT 'X'
               FROM   igs_gr_stat grst
               WHERE  grst.graduand_status = gr.graduand_status
               AND    grst.s_graduand_status = 'GRADUATED');
    --
    l_return_string VARCHAR2 (2000);
  BEGIN
    FOR c_sua_cmnt_rec IN c_sua_cmnt LOOP
      l_return_string := c_sua_cmnt_rec.load_description;
      EXIT;
    END LOOP;
    --
    FOR c_conferral_dt_rec IN c_conferral_dt (p_person_id, p_course_cd) LOOP
      l_return_string := l_return_string || ' ' || RTRIM (LTRIM (fnd_message.get_string ('IGS', 'IGS_GE_GRAD_DATE'))) || ' ' || c_conferral_dt_rec.conferral_date;
      EXIT;
    END LOOP;
    --
    FOR c_sua_end_rec IN c_sua_end LOOP
      l_return_string := l_return_string || ' ' || RTRIM (LTRIM (fnd_message.get_string ('IGS', 'IGS_GE_UNTIL'))) || ' ' || c_sua_end_rec.load_description;
      EXIT;
    END LOOP;
    --
    RETURN l_return_string;
  END get_prg_st_end_dts;
  --
  -- Added by msrinivi acc to bug 2318474 to delete items along with order
  --
  PROCEDURE delete_order_and_items (
    p_order_number                 IN     igs_as_order_hdr.order_number%TYPE,
    p_msg_count                    OUT NOCOPY NUMBER,
    p_msg_data                     OUT NOCOPY VARCHAR2,
    p_return_status                OUT NOCOPY VARCHAR2
  ) AS
    --
    CURSOR c_items IS
      SELECT ROWID
      FROM   igs_as_doc_details
      WHERE  order_number = p_order_number;
    --
    CURSOR c_order IS
      SELECT ROWID
      FROM   igs_as_order_hdr
      WHERE  order_number = p_order_number;
  BEGIN
    -- Delete items first
    FOR c_items_rec IN c_items LOOP
      EXIT WHEN c_items%NOTFOUND;
      igs_as_doc_details_pkg.delete_row (
        x_rowid                        => c_items_rec.ROWID,
        x_msg_count                    => p_msg_count,
        x_msg_data                     => p_msg_data,
        x_return_status                => p_return_status
      );
    END LOOP;
    --
    -- Delete order now
    --
    IF p_return_status IS NULL
       OR p_return_status = fnd_api.g_ret_sts_success THEN
      FOR c_order_rec IN c_order LOOP
        EXIT WHEN c_order%NOTFOUND;
        igs_as_order_hdr_pkg.delete_row (
          x_rowid                        => c_order_rec.ROWID,
          x_msg_count                    => p_msg_count,
          x_msg_data                     => p_msg_data,
          x_return_status                => p_return_status
        );
      END LOOP;
    END IF;
    --
    -- Delete all the interface items for this order
    --
    DELETE      igs_as_ord_itm_int
          WHERE order_number = p_order_number;
  END delete_order_and_items;
  --
  --
  --
  PROCEDURE get_doc_and_delivery_fee (
    p_person_id                    IN     NUMBER,
    p_document_type                IN     VARCHAR2,
    p_document_sub_type            IN     VARCHAR2,
    p_number_of_copies             IN     NUMBER,
    p_delivery_method_type         IN     VARCHAR2,
    p_document_fee                 OUT NOCOPY NUMBER,
    p_delivery_fee                 OUT NOCOPY NUMBER,
    p_program_on_file              IN     VARCHAR2,
    p_plan_id                      IN OUT NOCOPY NUMBER,
    p_item_number                  IN     NUMBER
  ) AS
    lnchrgcopy        NUMBER                            := p_number_of_copies;
    lnfree            VARCHAR2 (1)                      := 'N';
    lndocfee          NUMBER                            := 0;
    lncopies_availded NUMBER;
    lnyearspassed     NUMBER;
    lnmonthspassed    NUMBER;
    lninperd          NUMBER;
    l_delivery_fee    igs_as_doc_dlvy_fee.amount%TYPE;
    l_free_plan_id    igs_as_servic_plan.plan_id%TYPE;
    --
    -- Cursor to get all the plans subscribed by the student.
    -- Every time a user subscribes to a plan, a record is created in the doc_fee_pmnt table.
    --
    CURSOR cur_plans_subs (cp_plan_id NUMBER) IS
      SELECT subs.person_id,
             subs.fee_paid_date,
             subs.plan_id,
             subs.plan_discon_from,
             NVL (subs.num_of_copies, 0) num_of_copies,
             subs.cal_type,
             subs.ci_sequence_number,
             subs.prev_paid_plan,
             subs.program_on_file,
             pln.plan_type,
             pln.unlimited_ind,
             pln.quantity_limit,
             pln.period_of_plan,
             pln.total_periods_covered
      FROM   igs_as_doc_fee_pmnt subs,
             igs_as_servic_plan pln
      WHERE  subs.plan_id = pln.plan_id
      AND    subs.person_id = p_person_id
      AND    subs.plan_id = cp_plan_id
      AND    NVL (plan_discon_from, SYSDATE + 1) > SYSDATE;
    --
    fee_pmnt_rec      cur_plans_subs%ROWTYPE;
    -- Cursor to know whether the free plan is allowed by the institute or not...
    CURSOR cur_free_plan IS
      SELECT plan_id,
             plan_type,
             unlimited_ind,
             quantity_limit,
             period_of_plan,
             total_periods_covered
      FROM   igs_as_servic_plan pl,
             igs_lookups_view lk
      WHERE  pl.plan_type = lk.meaning
      AND    lk.lookup_type = 'TRANSCRIPT_SERVICE_PLAN_TYPE'
      AND    lk.lookup_code = 'FREE_TRANSCRIPT'
      AND    NVL (pl.closed_ind, 'N') = 'N';
    -- Cursor to get the delivery Fee:
    CURSOR cur_delivery_fee_setup (cp_delivery_method_type IN VARCHAR2) IS
      SELECT dlfs.amount amount
      FROM   igs_as_doc_dlvy_fee dlfs
      WHERE  dlfs.delivery_method_type = cp_delivery_method_type;
    --
    CURSOR cur_free_plan_id IS
      SELECT plan_id
      FROM   igs_as_servic_plan pl,
             igs_lookups_view lk
      WHERE  pl.plan_type = lk.meaning
      AND    lk.lookup_type = 'TRANSCRIPT_SERVICE_PLAN_TYPE'
      AND    lk.lookup_code = 'FREE_TRANSCRIPT'
      AND    NVL (pl.closed_ind, 'N') = 'N';
  BEGIN
    -- First get the delivery fee since it has nothing to do with document type and transcript plan.
    OPEN cur_delivery_fee_setup (p_delivery_method_type);
    FETCH cur_delivery_fee_setup INTO l_delivery_fee;
    CLOSE cur_delivery_fee_setup;
    --
    p_delivery_fee := NVL (l_delivery_fee, 0);
    --Free plan_id
    OPEN cur_free_plan_id;
    FETCH cur_free_plan_id INTO l_free_plan_id;
    CLOSE cur_free_plan_id;
    -- Service plan concept is applicable only for transcript and not for Enrollment certification:
    IF p_document_type <> 'ENCERT' THEN
      IF p_plan_id IS NULL
         OR p_plan_id = l_free_plan_id THEN --No plan or free plan
        --See if the student has subscribed to any plan
        FOR free_plan_rec IN cur_free_plan LOOP
          ---    See if the person has already availed this :
          SELECT SUM (NVL (num_of_copies, 0))
          INTO   lncopies_availded
          FROM   igs_as_doc_fee_pmnt
          WHERE  person_id = p_person_id
          AND    plan_id = free_plan_rec.plan_id
          AND    program_on_file IN ('ALL', p_program_on_file);
          -- See if the number of copies availed so far still alows the free transcript.
          lncopies_availded := NVL (lncopies_availded, 0);
          IF p_plan_id = l_free_plan_id THEN
            lncopies_availded := 0;
          END IF;
          IF (free_plan_rec.quantity_limit - lncopies_availded) >= p_number_of_copies THEN
            lnfree := 'Y';
            p_plan_id := free_plan_rec.plan_id;
          ELSE
            lnfree := 'N';
            IF (free_plan_rec.quantity_limit - lncopies_availded) > 0 THEN
              lnchrgcopy := p_number_of_copies - (free_plan_rec.quantity_limit - lncopies_availded);
              p_plan_id := free_plan_rec.plan_id;
            ELSE
              lnchrgcopy := p_number_of_copies;
            END IF;
          END IF;
        END LOOP;
      ELSIF p_plan_id IS NOT NULL THEN
        --See if the student has subscribed to any service plan:
        FOR plan_subs IN cur_plans_subs (p_plan_id) LOOP
          IF plan_subs.plan_type = 'Lifetime Transcript' THEN
            -- Since Lifetime type is unlimited hence do nothing extra.
            p_plan_id := plan_subs.plan_id;
            lnfree := 'Y';
            lnchrgcopy := 0;
            EXIT;
          ELSE
            ----See whether the student has already ordered some Xcript against the plan.
            IF plan_subs.period_of_plan = 'YEARS' THEN
              --Get the number of years lapsed between date fee was paid and sysdate
              SELECT NVL ((MONTHS_BETWEEN (SYSDATE, plan_subs.fee_paid_date) / 12), 0)
              INTO   lnyearspassed
              FROM   DUAL;
              IF lnyearspassed >= 0 THEN -- Plan is still Valid
                -- See if the student has already availed all the allowed number of copies.
                IF (plan_subs.quantity_limit - plan_subs.num_of_copies) > 0 THEN
                  lnfree := 'Y';
                  p_plan_id := plan_subs.plan_id;
                  lnchrgcopy := 0;
                  EXIT;
                ELSE
                  lnfree := 'N';
                  lnchrgcopy := p_number_of_copies - (plan_subs.quantity_limit - plan_subs.num_of_copies);
                  p_plan_id := plan_subs.plan_id;
                  EXIT;
                END IF;
              END IF;
            ---See if the Period = 'MONTHS'
            ELSIF plan_subs.period_of_plan = 'MONTHS' THEN
              --Get the number of Months lapsed between date fee was paid and sysdate
              SELECT NVL (MONTHS_BETWEEN (plan_subs.fee_paid_date, SYSDATE), 0)
              INTO   lnyearspassed
              FROM   DUAL;
              IF lnyearspassed >= 0 THEN -- Plan is still Valid
                -- See if the student has already availed all the allowed number of copies.
                lncopies_availded := plan_subs.quantity_limit - plan_subs.num_of_copies;

                IF lncopies_availded - p_number_of_copies >= 0 THEN
                  lnfree := 'Y';
                  p_plan_id := plan_subs.plan_id;
                  lnchrgcopy := 0;
                  EXIT;
                ELSIF lncopies_availded > 0 THEN
                  lnchrgcopy := p_number_of_copies - lncopies_availded;
                  lnfree := 'N';
                  p_plan_id := plan_subs.plan_id;
                  EXIT;
                ELSE
                  lnchrgcopy := p_number_of_copies;
                  lnfree := 'N';
                  p_plan_id := NULL;
                  EXIT;
                END IF;
              END IF;
            ELSIF (plan_subs.period_of_plan = 'ACADEMIC'
                   OR plan_subs.period_of_plan = 'TERM'
                  ) THEN
              --Verify if the SYSDATE is between start and End date of the Academic calendar.
              BEGIN
                SELECT 1
                INTO   lninperd
                FROM   igs_ca_inst ci
                WHERE  SYSDATE BETWEEN ci.start_dt AND ci.end_dt
                AND    cal_type = plan_subs.cal_type
                AND    sequence_number = plan_subs.ci_sequence_number;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  lninperd := 0;
              END;
              IF lninperd = 1 THEN -- Plan is still Valid
                -- See if the student has already availed all the allowed number of copies.
                lncopies_availded := plan_subs.quantity_limit - plan_subs.num_of_copies;
                IF lncopies_availded - p_number_of_copies >= 0 THEN
                  lnfree := 'Y';
                  p_plan_id := plan_subs.plan_id;
                  lnchrgcopy := 0;
                  EXIT;
                ELSIF lncopies_availded > 0 THEN
                  lnchrgcopy := p_number_of_copies - lncopies_availded;
                  lnfree := 'N';
                  p_plan_id := plan_subs.plan_id;
                  EXIT;
                ELSE
                  lnchrgcopy := p_number_of_copies;
                  lnfree := 'N';
                  p_plan_id := NULL;
                  EXIT;
                END IF;
              END IF;
            END IF;
          END IF;
        END LOOP;
      END IF;
    END IF; -- End if For Document Type;
    -- See if thestudent has to pay:
    IF lnfree = 'Y' THEN -- No user will get the document free...
      p_document_fee := 0;
      RETURN;
    ELSE -- Make a call to the  existing function to calculate the fee:
      lndocfee := igs_as_ss_doc_request.get_transcript_fee (
                    p_person_id                    => p_person_id,
                    p_document_type                => p_document_sub_type,
                    p_number_of_copies             => lnchrgcopy,
                    p_include_delivery_fee         => 'N',
                    p_delivery_method_type         => p_delivery_method_type,
                    p_item_number                  => p_item_number
                  );
      p_document_fee := NVL (lndocfee, 0);
    END IF;
  END get_doc_and_delivery_fee;

  PROCEDURE pay_lifetime_fees (
    p_person_id                    IN     NUMBER,
    p_order_number                 IN     NUMBER,
    p_return_status                OUT NOCOPY VARCHAR2,
    p_msg_data                     OUT NOCOPY VARCHAR2,
    p_msg_count                    OUT NOCOPY NUMBER
  ) AS
  -- To select the delivery method type:
    CURSOR c_deliv_type IS
      SELECT delivery_method_type
      FROM   igs_as_doc_dlvy_typ
      WHERE  s_delivery_method_type = 'MANUAL'
      AND    closed_ind = 'Y'
      AND    delivery_method_type = 'NONE';
    ldeliv_type       igs_as_doc_dlvy_typ.delivery_method_type%TYPE;
    --  To get the document fee setup details
    --  for the given document type.
    CURSOR cur_doc_setup IS
      SELECT dfs.amount amount
      FROM   igs_as_doc_fee_stup dfs
      WHERE  dfs.document_type = 'LIFE_TIME_TRANS';
    --  Variables
    l_item_number     igs_as_doc_details.item_number%TYPE;
    l_doc_fee         igs_as_order_hdr.order_fee%TYPE;
    l_delivery_fee    igs_as_order_hdr.delivery_fee%TYPE;
    l_itm_row_id      VARCHAR2 (25);
    l_fmnt_row_id     VARCHAR2 (25);
    l_lifetime_fee    igs_as_doc_fee_stup.amount%TYPE;
    l_default_country VARCHAR2 (80)                                   := fnd_profile.VALUE ('OSS_COUNTRY_CODE');
    l_return_status   VARCHAR2 (30);
    l_msg_data        VARCHAR2 (1000);
    l_msg_count       NUMBER;
  BEGIN
    OPEN c_deliv_type;
    FETCH c_deliv_type INTO ldeliv_type;
    CLOSE c_deliv_type;
    --
    SELECT igs_as_doc_details_s.NEXTVAL
    INTO   l_item_number
    FROM   DUAL;
    --
    OPEN cur_doc_setup;
    FETCH cur_doc_setup INTO l_lifetime_fee;
    CLOSE cur_doc_setup;
    -- Inserting an Item
    igs_as_doc_details_pkg.insert_row (
      x_rowid                        => l_itm_row_id,
      x_order_number                 => p_order_number,
      x_document_type                => 'TRANSCRIPT',
      x_document_sub_type            => 'LIFE_TIME_TRANS',
      x_item_number                  => l_item_number,
      x_item_status                  => 'INCOMPLETE',
      x_date_produced                => NULL,
      x_incl_curr_course             => NULL,
      x_num_of_copies                => 1,
      x_comments                     => NULL,
      x_recip_pers_name              => NULL,
      x_recip_inst_name              => NULL,
      x_recip_addr_line_1            => 'N/A',
      x_recip_addr_line_2            => NULL,
      x_recip_addr_line_3            => NULL,
      x_recip_addr_line_4            => NULL,
      x_recip_city                   => NULL,
      x_recip_postal_code            => NULL,
      x_recip_state                  => NULL,
      x_recip_province               => NULL,
      x_recip_county                 => NULL,
      x_recip_country                => l_default_country,
      x_recip_fax_area_code          => NULL,
      x_recip_fax_country_code       => NULL,
      x_recip_fax_number             => NULL,
      x_delivery_method_type         => ldeliv_type,
      x_programs_on_file             => NULL,
      x_missing_acad_record_data_ind => NULL,
      x_missing_academic_record_data => NULL,
      x_send_transcript_immediately  => NULL,
      x_hold_release_of_final_grades => NULL,
      x_fgrade_cal_type              => NULL,
      x_fgrade_seq_num               => NULL,
      x_hold_degree_expected         => NULL,
      x_deghold_cal_type             => NULL,
      x_deghold_seq_num              => NULL,
      x_hold_for_grade_chg           => NULL,
      x_special_instr                => NULL,
      x_express_mail_type            => NULL,
      x_express_mail_track_num       => NULL,
      x_ge_certification             => NULL,
      x_external_comments            => NULL,
      x_internal_comments            => NULL,
      x_dup_requested                => NULL,
      x_dup_req_date                 => NULL,
      x_dup_sent_date                => NULL,
      x_enr_term_cal_type            => NULL,
      x_enr_ci_sequence_number       => NULL,
      x_incl_attempted_hours         => NULL,
      x_incl_class_rank              => NULL,
      x_incl_progresssion_status     => NULL,
      x_incl_class_standing          => NULL,
      x_incl_cum_hours_earned        => NULL,
      x_incl_gpa                     => NULL,
      x_incl_date_of_graduation      => NULL,
      x_incl_degree_dates            => NULL,
      x_incl_degree_earned           => NULL,
      x_incl_date_of_entry           => NULL,
      x_incl_drop_withdrawal_dates   => NULL,
      x_incl_hrs_for_curr_term       => NULL,
      x_incl_majors                  => NULL,
      x_incl_last_date_of_enrollment => NULL,
      x_incl_professional_licensure  => NULL,
      x_incl_college_affiliation     => NULL,
      x_incl_instruction_dates       => NULL,
      x_incl_usec_dates              => NULL,
      x_incl_program_attempt         => NULL,
      x_incl_attendence_type         => NULL,
      x_incl_last_term_enrolled      => NULL,
      x_incl_ssn                     => NULL,
      x_incl_date_of_birth           => NULL,
      x_incl_disciplin_standing      => NULL,
      x_incl_no_future_term          => NULL,
      x_incl_acurat_till_copmp_dt    => NULL,
      x_incl_cant_rel_without_sign   => NULL,
      x_return_status                => l_return_status,
      x_msg_data                     => l_msg_data,
      x_msg_count                    => l_msg_count,
      x_doc_fee_per_copy             => l_lifetime_fee,
      x_delivery_fee                 => 0,
      x_recip_email                  => NULL,
      x_overridden_doc_delivery_fee  => NULL,
      x_overridden_document_fee      => NULL,
      x_fee_overridden_by            => NULL,
      x_fee_overridden_date          => NULL,
      x_incl_department              => NULL,
      x_incl_field_of_stdy           => NULL,
      x_incl_attend_mode             => NULL,
      x_incl_yop_acad_prd            => NULL,
      x_incl_intrmsn_st_end          => NULL,
      x_incl_hnrs_lvl                => NULL,
      x_incl_awards                  => NULL,
      x_incl_award_aim               => NULL,
      x_incl_acad_sessions           => NULL,
      x_incl_st_end_acad_ses         => NULL,
      x_incl_hesa_num                => NULL,
      x_incl_location                => NULL,
      x_incl_program_type            => NULL,
      x_incl_program_name            => NULL,
      x_incl_prog_atmpt_stat         => NULL,
      x_incl_prog_atmpt_end          => NULL,
      x_incl_prog_atmpt_strt         => NULL,
      x_incl_req_cmplete             => NULL,
      x_incl_expected_compl_dt       => NULL,
      x_incl_conferral_dt            => NULL,
      x_incl_thesis_title            => NULL,
      x_incl_program_code            => NULL,
      x_incl_program_ver             => NULL,
      x_incl_stud_no                 => NULL,
      x_incl_surname                 => NULL,
      x_incl_fore_name               => NULL,
      x_incl_prev_names              => NULL,
      x_incl_initials                => NULL,
      x_doc_purpose_code             => NULL,
      x_plan_id                      => NULL
    );
    -- Setting out params
    p_return_status := l_return_status;
    p_msg_data := l_msg_data;
    p_msg_count := l_msg_count;
    IF NVL (p_return_status, fnd_api.g_ret_sts_success) <> fnd_api.g_ret_sts_success THEN
      RETURN;
    END IF;
    -- Inserting record into fee payment, so that transcript items dos fees are calc to Zero
    /*IGS_AS_DOC_FEE_PMNT_PKG.INSERT_ROW(
         X_ROWID     => l_fmnt_row_Id,
         X_PERSON_ID   => p_person_id,
         X_DOCUMENT_TYPE   => 'TRANSCRIPT',
         X_FEE_PAID_TYPE   => 'LIFETIME',
         X_FEE_PAID_DATE   => NULL,
         X_LIFETIME_FEE_PAID => 'N',
         X_FEE_AMOUNT    => l_lifetime_fee,
         X_FEE_RECORDED_DATE => SYSDATE,
         X_FEE_RECORDED_BY => p_person_id
                                );*/
    -- Setting out params
    p_return_status := l_return_status;
    p_msg_data := l_msg_data;
    p_msg_count := l_msg_count;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      p_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count => p_msg_count, p_data => p_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => p_msg_count, p_data => p_msg_data);
    WHEN OTHERS THEN
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_message.set_token ('NAME', 'Pay_Lifetime_Fees: ' || SQLERRM);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get (p_count => p_msg_count, p_data => p_msg_data);
  END pay_lifetime_fees;

  PROCEDURE recalc_after_lft_paid (
    p_person_id                    IN     NUMBER,
    p_order_number                 IN     NUMBER,
    p_return_status                OUT NOCOPY VARCHAR2,
    p_msg_data                     OUT NOCOPY VARCHAR2,
    p_msg_count                    OUT NOCOPY NUMBER
  ) AS
    -- To select all orders for a person
    CURSOR c_order IS
      SELECT ord.ROWID row_id,
             ord.*
      FROM   igs_as_order_hdr ord
      WHERE  person_id = p_person_id
      AND    order_status = 'INCOMPLETE';
    --
    c_order_rec        c_order%ROWTYPE;
    -- To select all items for an order
    CURSOR c_order_item (cp_order_number IN NUMBER, cp_item_number IN NUMBER) IS
      SELECT dtl.ROWID row_id,
             dtl.*
      FROM   igs_as_doc_details dtl
      WHERE  order_number = cp_order_number
      AND    document_type = 'TRANSCRIPT'
      AND    document_sub_type <> 'LIFE_TIME_TRANS'
      AND    item_status = 'INCOMPLETE';
    --  Get rowid for doc_fee_pmnt table
    --  to update the lft flag
    CURSOR c_doc_fee_pmnt_record IS
      SELECT a.*,
             a.ROWID
      FROM   igs_as_doc_fee_pmnt a
      WHERE  person_id = p_person_id;
    c_doc_fee_pmnt_rec c_doc_fee_pmnt_record%ROWTYPE;
    c_order_item_rec   c_order_item%ROWTYPE;
    --  Variables
    l_order_number     igs_as_order_hdr.order_number%TYPE;
    l_item_number      igs_as_doc_details.item_number%TYPE;
    l_doc_fee          igs_as_order_hdr.order_fee%TYPE;
    l_delivery_fee     igs_as_order_hdr.delivery_fee%TYPE;
    l_itm_row_id       VARCHAR2 (25);
    l_fmnt_row_id      VARCHAR2 (25);
    l_lifetime_fee     igs_as_doc_fee_stup.amount%TYPE;
    l_default_country  VARCHAR2 (80)                         := fnd_profile.VALUE ('OSS_COUNTRY_CODE');
    l_return_status    VARCHAR2 (30);
    l_msg_data         VARCHAR2 (1000);
    l_msg_count        NUMBER;
  BEGIN
    OPEN c_doc_fee_pmnt_record;
    FETCH c_doc_fee_pmnt_record INTO c_doc_fee_pmnt_rec;
    -- Update record into fee payment, so that transcript items dos fees are calc to Zero
    /*IGS_AS_DOC_FEE_PMNT_PKG.UPDATE_ROW(
         X_ROWID     => c_doc_fee_pmnt_rec.rowid,
         X_PERSON_ID   => p_person_id,
         X_DOCUMENT_TYPE   => c_doc_fee_pmnt_rec.document_type,
         X_FEE_PAID_TYPE   => c_doc_fee_pmnt_rec.fee_paid_type,
         X_FEE_PAID_DATE   => SYSDATE,
         X_LIFETIME_FEE_PAID => 'Y',
         X_FEE_AMOUNT    => c_doc_fee_pmnt_rec.fee_amount,
         X_FEE_RECORDED_DATE => c_doc_fee_pmnt_rec.fee_recorded_date,
         X_FEE_RECORDED_BY => c_doc_fee_pmnt_rec.fee_recorded_by
                                );*/
    NULL;
    CLOSE c_doc_fee_pmnt_record;
    --
    OPEN c_order;
    LOOP
      FETCH c_order INTO c_order_rec;
      EXIT WHEN c_order%NOTFOUND;
      l_order_number := c_order_rec.order_number;
      OPEN c_order_item (c_order_rec.order_number, l_item_number);
      LOOP
        FETCH c_order_item INTO c_order_item_rec;
        EXIT WHEN c_order_item%NOTFOUND;
        -- Update all items for the current order with doc_fee = 0
        igs_as_doc_details_pkg.update_row (
          x_rowid                        => c_order_item_rec.row_id,
          x_order_number                 => c_order_item_rec.order_number,
          x_document_type                => c_order_item_rec.document_type,
          x_document_sub_type            => c_order_item_rec.document_sub_type,
          x_item_number                  => c_order_item_rec.item_number,
          x_item_status                  => c_order_item_rec.item_status,
          x_date_produced                => c_order_item_rec.date_produced,
          x_incl_curr_course             => c_order_item_rec.incl_curr_course,
          x_num_of_copies                => c_order_item_rec.num_of_copies,
          x_comments                     => c_order_item_rec.comments,
          x_recip_pers_name              => c_order_item_rec.recip_pers_name,
          x_recip_inst_name              => c_order_item_rec.recip_inst_name,
          x_recip_addr_line_1            => c_order_item_rec.recip_addr_line_1,
          x_recip_addr_line_2            => c_order_item_rec.recip_addr_line_2,
          x_recip_addr_line_3            => c_order_item_rec.recip_addr_line_3,
          x_recip_addr_line_4            => c_order_item_rec.recip_addr_line_4,
          x_recip_city                   => c_order_item_rec.recip_city,
          x_recip_postal_code            => c_order_item_rec.recip_postal_code,
          x_recip_state                  => c_order_item_rec.recip_state,
          x_recip_province               => c_order_item_rec.recip_province,
          x_recip_county                 => c_order_item_rec.recip_county,
          x_recip_country                => c_order_item_rec.recip_country,
          x_recip_fax_area_code          => c_order_item_rec.recip_fax_area_code,
          x_recip_fax_country_code       => c_order_item_rec.recip_fax_country_code,
          x_recip_fax_number             => c_order_item_rec.recip_fax_number,
          x_delivery_method_type         => c_order_item_rec.delivery_method_type,
          x_programs_on_file             => c_order_item_rec.programs_on_file,
          x_missing_acad_record_data_ind => c_order_item_rec.missing_acad_record_data_ind,
          x_missing_academic_record_data => c_order_item_rec.missing_academic_record_data,
          x_send_transcript_immediately  => c_order_item_rec.send_transcript_immediately,
          x_hold_release_of_final_grades => c_order_item_rec.hold_release_of_final_grades,
          x_fgrade_cal_type              => c_order_item_rec.fgrade_cal_type,
          x_fgrade_seq_num               => c_order_item_rec.fgrade_seq_num,
          x_hold_degree_expected         => c_order_item_rec.hold_degree_expected,
          x_deghold_cal_type             => c_order_item_rec.deghold_cal_type,
          x_deghold_seq_num              => c_order_item_rec.deghold_seq_num,
          x_hold_for_grade_chg           => c_order_item_rec.hold_for_grade_chg,
          x_special_instr                => c_order_item_rec.special_instr,
          x_express_mail_type            => c_order_item_rec.express_mail_type,
          x_express_mail_track_num       => c_order_item_rec.express_mail_track_num,
          x_ge_certification             => c_order_item_rec.ge_certification,
          x_external_comments            => c_order_item_rec.external_comments,
          x_internal_comments            => c_order_item_rec.internal_comments,
          x_dup_requested                => c_order_item_rec.dup_requested,
          x_dup_req_date                 => c_order_item_rec.dup_req_date,
          x_dup_sent_date                => c_order_item_rec.dup_sent_date,
          x_enr_term_cal_type            => c_order_item_rec.enr_term_cal_type,
          x_enr_ci_sequence_number       => c_order_item_rec.enr_ci_sequence_number,
          x_incl_attempted_hours         => c_order_item_rec.incl_attempted_hours,
          x_incl_class_rank              => c_order_item_rec.incl_class_rank,
          x_incl_progresssion_status     => c_order_item_rec.incl_progresssion_status,
          x_incl_class_standing          => c_order_item_rec.incl_class_standing,
          x_incl_cum_hours_earned        => c_order_item_rec.incl_cum_hours_earned,
          x_incl_gpa                     => c_order_item_rec.incl_gpa,
          x_incl_date_of_graduation      => c_order_item_rec.incl_date_of_graduation,
          x_incl_degree_dates            => c_order_item_rec.incl_degree_dates,
          x_incl_degree_earned           => c_order_item_rec.incl_degree_earned,
          x_incl_date_of_entry           => c_order_item_rec.incl_date_of_entry,
          x_incl_drop_withdrawal_dates   => c_order_item_rec.incl_drop_withdrawal_dates,
          x_incl_hrs_for_curr_term       => c_order_item_rec.incl_hrs_earned_for_curr_term,
          x_incl_majors                  => c_order_item_rec.incl_majors,
          x_incl_last_date_of_enrollment => c_order_item_rec.incl_last_date_of_enrollment,
          x_incl_professional_licensure  => c_order_item_rec.incl_professional_licensure,
          x_incl_college_affiliation     => c_order_item_rec.incl_college_affiliation,
          x_incl_instruction_dates       => c_order_item_rec.incl_instruction_dates,
          x_incl_usec_dates              => c_order_item_rec.incl_usec_dates,
          x_incl_program_attempt         => c_order_item_rec.incl_program_attempt,
          x_incl_attendence_type         => c_order_item_rec.incl_attendence_type,
          x_incl_last_term_enrolled      => c_order_item_rec.incl_last_term_enrolled,
          x_incl_ssn                     => c_order_item_rec.incl_ssn,
          x_incl_date_of_birth           => c_order_item_rec.incl_date_of_birth,
          x_incl_disciplin_standing      => c_order_item_rec.incl_disciplin_standing,
          x_incl_no_future_term          => c_order_item_rec.incl_no_future_term,
          x_incl_acurat_till_copmp_dt    => c_order_item_rec.incl_acurat_till_copmp_dt,
          x_incl_cant_rel_without_sign   => c_order_item_rec.incl_cant_rel_without_sign,
          x_mode                         => 'R',
          x_return_status                => l_return_status,
          x_msg_data                     => l_msg_data,
          x_msg_count                    => l_msg_count,
          x_doc_fee_per_copy             => 0,
          x_delivery_fee                 => c_order_item_rec.delivery_fee,
          x_recip_email                  => c_order_item_rec.recip_email,
          x_overridden_doc_delivery_fee  => c_order_item_rec.overridden_doc_delivery_fee,
          x_overridden_document_fee      => c_order_item_rec.overridden_document_fee,
          x_fee_overridden_by            => c_order_item_rec.fee_overridden_by,
          x_fee_overridden_date          => c_order_item_rec.fee_overridden_date,
          x_incl_department              => c_order_item_rec.incl_department,
          x_incl_field_of_stdy           => c_order_item_rec.incl_field_of_stdy,
          x_incl_attend_mode             => c_order_item_rec.incl_attend_mode,
          x_incl_yop_acad_prd            => c_order_item_rec.incl_yop_acad_prd,
          x_incl_intrmsn_st_end          => c_order_item_rec.incl_intrmsn_st_end,
          x_incl_hnrs_lvl                => c_order_item_rec.incl_hnrs_lvl,
          x_incl_awards                  => c_order_item_rec.incl_awards,
          x_incl_award_aim               => c_order_item_rec.incl_award_aim,
          x_incl_acad_sessions           => c_order_item_rec.incl_acad_sessions,
          x_incl_st_end_acad_ses         => c_order_item_rec.incl_st_end_acad_ses,
          x_incl_hesa_num                => c_order_item_rec.incl_hesa_num,
          x_incl_location                => c_order_item_rec.incl_location,
          x_incl_program_type            => c_order_item_rec.incl_program_type,
          x_incl_program_name            => c_order_item_rec.incl_program_name,
          x_incl_prog_atmpt_stat         => c_order_item_rec.incl_prog_atmpt_stat,
          x_incl_prog_atmpt_end          => c_order_item_rec.incl_prog_atmpt_end,
          x_incl_prog_atmpt_strt         => c_order_item_rec.incl_prog_atmpt_strt,
          x_incl_req_cmplete             => c_order_item_rec.incl_req_cmplete,
          x_incl_expected_compl_dt       => c_order_item_rec.incl_expected_compl_dt,
          x_incl_conferral_dt            => c_order_item_rec.incl_conferral_dt,
          x_incl_thesis_title            => c_order_item_rec.incl_thesis_title,
          x_incl_program_code            => c_order_item_rec.incl_program_code,
          x_incl_program_ver             => c_order_item_rec.incl_program_ver,
          x_incl_stud_no                 => c_order_item_rec.incl_stud_no,
          x_incl_surname                 => c_order_item_rec.incl_surname,
          x_incl_fore_name               => c_order_item_rec.incl_fore_name,
          x_incl_prev_names              => c_order_item_rec.incl_prev_names,
          x_incl_initials                => c_order_item_rec.incl_initials,
          x_doc_purpose_code             => c_order_item_rec.doc_purpose_code,
          x_plan_id                      => c_order_item_rec.plan_id,
          x_produced_by                  => c_order_item_rec.produced_by,
          x_person_id                    => c_order_item_rec.person_id
        );
        -- Setting out params
        p_return_status := l_return_status;
        p_msg_data := l_msg_data;
        p_msg_count := l_msg_count;
        IF NVL (p_return_status, fnd_api.g_ret_sts_success) <> fnd_api.g_ret_sts_success THEN
          RETURN;
        END IF;
      END LOOP;
      CLOSE c_order_item;
      SELECT NVL (SUM (doc_fee_per_copy), 0),
             NVL (SUM (delivery_fee), 0)
      INTO   l_doc_fee,
             l_delivery_fee
      FROM   igs_as_doc_details
      WHERE  order_number = l_order_number;
      -- Update the order for the above items
      igs_as_order_hdr_pkg.update_row (
        x_msg_count                    => l_msg_count,
        x_msg_data                     => l_msg_data,
        x_return_status                => l_return_status,
        x_rowid                        => c_order_rec.row_id,
        x_order_number                 => c_order_rec.order_number,
        x_order_status                 => c_order_rec.order_status,
        x_date_completed               => c_order_rec.date_completed,
        x_person_id                    => c_order_rec.person_id,
        x_addr_line_1                  => c_order_rec.addr_line_1,
        x_addr_line_2                  => c_order_rec.addr_line_2,
        x_addr_line_3                  => c_order_rec.addr_line_3,
        x_addr_line_4                  => c_order_rec.addr_line_4,
        x_city                         => c_order_rec.city,
        x_state                        => c_order_rec.state,
        x_province                     => c_order_rec.province,
        x_county                       => c_order_rec.county,
        x_country                      => c_order_rec.country,
        x_postal_code                  => c_order_rec.postal_code,
        x_email_address                => c_order_rec.email_address,
        x_phone_country_code           => c_order_rec.phone_country_code,
        x_phone_area_code              => c_order_rec.phone_area_code,
        x_phone_number                 => c_order_rec.phone_number,
        x_phone_extension              => c_order_rec.phone_extension,
        x_fax_country_code             => c_order_rec.fax_country_code,
        x_fax_area_code                => c_order_rec.fax_area_code,
        x_fax_number                   => c_order_rec.fax_number,
        x_delivery_fee                 => l_delivery_fee,
        x_order_fee                    => l_doc_fee,
        x_request_type                 => c_order_rec.request_type,
        x_submit_method                => c_order_rec.submit_method,
        x_invoice_id                   => c_order_rec.invoice_id,
        x_mode                         => 'R',
        x_order_placed_by              => c_order_rec.order_placed_by,
        x_order_description            => c_order_rec.order_description
      );
      IF NVL (p_return_status, fnd_api.g_ret_sts_success) <> fnd_api.g_ret_sts_success THEN
        RETURN;
      END IF;
      -- Setting out params
      p_return_status := l_return_status;
      p_msg_data := l_msg_data;
      p_msg_count := l_msg_count;
    END LOOP;
    CLOSE c_order;
    --Initialize API return status to success.
    p_return_status := fnd_api.g_ret_sts_success;
    --Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get (p_count => p_msg_count, p_data => p_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      p_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count => p_msg_count, p_data => p_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => p_msg_count, p_data => p_msg_data);
    WHEN OTHERS THEN
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_message.set_token ('NAME', 'update_document_details: ' || SQLERRM);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get (p_count => p_msg_count, p_data => p_msg_data);
  END recalc_after_lft_paid;

  PROCEDURE get_as_current_term (
    p_cal_type                     OUT NOCOPY VARCHAR2,
    p_sequence_number              OUT NOCOPY NUMBER,
    p_description                  OUT NOCOPY VARCHAR2
  ) AS
  BEGIN
    -- Procedure to select the current term calendar based on the current date
    EXECUTE IMMEDIATE 'SELECT cal_type, sequence_number, description
      FROM
  (SELECT
    ci.cal_type,
    ci.sequence_number,
    ci.description,
    NVL(
        ( SELECT  MIN(daiv.alias_val)
    FROM    igs_ca_da_inst_v daiv,
      igs_en_cal_conf secc
    WHERE   secc.s_control_num     = 1    AND
      daiv.cal_type          = ci.cal_type   AND
      daiv.ci_sequence_number= ci.sequence_number  AND
      daiv.dt_alias          = secc.load_effect_dt_alias),
      ci.start_dt) load_effect_dt
   FROM    igs_ca_inst_all ci,
     igs_ca_type cat,
     igs_ca_stat cs
   WHERE
       ci.end_dt       >= TRUNC(SYSDATE)  AND
       cat.cal_type    = ci.cal_type      AND
       cat.s_cal_cat   = ''LOAD''           AND
       cs.cal_status   = ci.cal_status    AND
       cs.s_cal_status = ''ACTIVE''         AND
       ci.ss_displayed = ''Y''              AND
       cat.closed_ind = ''N''
   ORDER BY  load_effect_dt DESC ) dates
   WHERE load_effect_dt <= SYSDATE
   AND   ROWNUM = 1 '
      INTO p_cal_type,
           p_sequence_number,
           p_description;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      p_cal_type := NULL;
      p_sequence_number := NULL;
      p_description := NULL;
  END get_as_current_term;

  PROCEDURE get_as_next_term (
    p_cal_type                     OUT NOCOPY VARCHAR2,
    p_sequence_number              OUT NOCOPY NUMBER,
    p_description                  OUT NOCOPY VARCHAR2
  ) AS
  BEGIN
    -- Procedure to select the next term calendar based on the current date
    EXECUTE IMMEDIATE 'select cal_type, sequence_number,description
from
(
  SELECT
    ci.cal_type,
    ci.sequence_number,
    ci.description,
    ci.end_dt ,
    NVL(
        (
        SELECT  MIN(daiv.alias_val)
          FROM    igs_ca_da_inst_v daiv,
                  igs_en_cal_conf secc
          WHERE   secc.s_control_num     = 1    AND
                  daiv.cal_type          = ci.cal_type   AND
                  daiv.ci_sequence_number= ci.sequence_number  AND
                  daiv.dt_alias          = secc.load_effect_dt_alias
       ),
         ci.start_dt
      ) load_effect_dt
   FROM    igs_ca_inst_all ci,
           igs_ca_type cat,
           igs_ca_stat cs
   WHERE
             ci.end_dt       >= TRUNC(SYSDATE)  AND
             cat.cal_type    = ci.cal_type      AND
             cat.s_cal_cat   = ''LOAD''           AND
             cs.cal_status   = ci.cal_status    AND
             cs.s_cal_status = ''ACTIVE''
  ORDER BY  load_effect_dt ASC
) dates
where load_effect_dt > SYSDATE and rownum=1 '
      INTO p_cal_type,
           p_sequence_number,
           p_description;
  END get_as_next_term;

  PROCEDURE get_as_previous_term (
    p_cal_type                     OUT NOCOPY VARCHAR2,
    p_sequence_number              OUT NOCOPY NUMBER,
    p_description                  OUT NOCOPY VARCHAR2
  ) AS
  BEGIN
    -- Procedure to select the next term calendar based on the current date
    EXECUTE IMMEDIATE 'select cal_type, sequence_number,description
from
(
  SELECT
    ci.cal_type,
    ci.sequence_number,
    ci.description,
    ci.end_dt ,
    NVL(
        (
        SELECT  MIN(daiv.alias_val)
          FROM    igs_ca_da_inst_v daiv,
                  igs_en_cal_conf secc
          WHERE   secc.s_control_num     = 1    AND
                  daiv.cal_type          = ci.cal_type   AND
                  daiv.ci_sequence_number= ci.sequence_number  AND
                  daiv.dt_alias          = secc.load_effect_dt_alias
       ),
         ci.start_dt
      ) load_effect_dt
   FROM    igs_ca_inst_all ci,
           igs_ca_type cat,
           igs_ca_stat cs
   WHERE
             ci.end_dt       < TRUNC(SYSDATE)  AND
             cat.cal_type    = ci.cal_type      AND
             cat.s_cal_cat   = ''LOAD''           AND
             cs.cal_status   = ci.cal_status    AND
             cs.s_cal_status = ''ACTIVE''
  ORDER BY  ci.end_dt DESC
) dates
where load_effect_dt <= SYSDATE and rownum=1'
      INTO p_cal_type,
           p_sequence_number,
           p_description;
  END get_as_previous_term;

  PROCEDURE re_calc_doc_fees (
    p_person_id                    IN     NUMBER,
    p_plan_id                      IN     NUMBER,
    p_subs_unsubs                  IN     VARCHAR2, -- Possible values 'U' and 'S'
    p_admin_person_id              IN     NUMBER, -- The person Id of the admin
    p_orders_recalc                OUT NOCOPY VARCHAR2 -- To return  comma seperated List of Order numbers that got recalculated.
  ) IS
    -- Cursor to get all the items with plan ID as passed in parameter.
    CURSOR cur_itm_dtls_unsc IS
      SELECT l.item_number,
             l.order_number,
             l.document_type,
             l.num_of_copies,
             l.delivery_method_type,
             l.programs_on_file
      FROM   igs_as_doc_details l,
             igs_as_order_hdr h
      WHERE  h.person_id = p_person_id
      AND    l.item_status = 'INCOMPLETE'
      AND    l.order_number = h.order_number
      AND    l.plan_id = p_plan_id;
    -- Cursor to get all the items which are incomplete and have plan_id = NULL;
    CURSOR cur_itm_dtls_subs IS
      SELECT l.item_number,
             l.order_number,
             l.document_type,
             l.num_of_copies,
             l.delivery_method_type,
             l.programs_on_file
      FROM   igs_as_doc_details l,
             igs_as_order_hdr h
      WHERE  h.person_id = p_person_id
      AND    l.item_status = 'INCOMPLETE'
      AND    l.order_number = h.order_number
      AND    l.plan_id IS NULL;
    -- Cursor to get the order details so that it can be updated..
    CURSOR cur_order (cp_order_number NUMBER) IS
      SELECT o.ROWID row_id,
             o.*
      FROM   igs_as_order_hdr o
      WHERE  order_number = cp_order_number;
    order_rec         cur_order%ROWTYPE;
    -- Cursor for updating the item
    CURSOR cur_itm_dtls_upd (cp_item_number NUMBER) IS
      SELECT l.ROWID AS row_id,
             l.*
      FROM   igs_as_doc_details l
      WHERE  l.item_number = cp_item_number;
    rec_dtls          cur_itm_dtls_upd%ROWTYPE;
    -- Cursor to get the plan Details:
    CURSOR cur_plan IS
      SELECT plan_id,
             plan_type,
             unlimited_ind,
             quantity_limit
      FROM   igs_as_servic_plan
      WHERE  plan_id = p_plan_id;
    plan_rec          cur_plan%ROWTYPE;
    -- Cursor to update the doc_fee_pmnt
    CURSOR cur_doc_fee_pmnt IS
      SELECT f.ROWID row_id,
             f.*
      FROM   igs_as_doc_fee_pmnt f
      WHERE  person_id = p_person_id
      AND    plan_id = p_plan_id;
    rec_doc_fee_pmnt  cur_doc_fee_pmnt%ROWTYPE;
    prev_order_number NUMBER;
    next_order_number NUMBER;
    lndoc_fee         NUMBER;
    ln_order_fee      NUMBER                     := 0;
    ln_msg_count      NUMBER;
    lv_msg_data       VARCHAR2 (100);
    lv_return_status  VARCHAR2 (30);
    lnplan_limit      NUMBER;
    lnitmused         NUMBER                     := 0;
    ln_plan_id        NUMBER;
    ldeliv_fee        NUMBER;
    -- Create a local Procedure to update  order:
    PROCEDURE update_order_for_recalc (p_order_number NUMBER, p_order_fee NUMBER) IS
    BEGIN
      OPEN cur_order (p_order_number);
      FETCH cur_order INTO order_rec;
      CLOSE cur_order;
      -- Make a Call to the update row fro igs_as_order_hdr
      igs_as_order_hdr_pkg.update_row (
        x_msg_count                    => ln_msg_count,
        x_msg_data                     => lv_msg_data,
        x_return_status                => lv_return_status,
        x_rowid                        => order_rec.row_id,
        x_order_number                 => order_rec.order_number,
        x_order_status                 => order_rec.order_status,
        x_date_completed               => order_rec.date_completed,
        x_person_id                    => order_rec.person_id,
        x_addr_line_1                  => order_rec.addr_line_1,
        x_addr_line_2                  => order_rec.addr_line_2,
        x_addr_line_3                  => order_rec.addr_line_3,
        x_addr_line_4                  => order_rec.addr_line_4,
        x_city                         => order_rec.city,
        x_state                        => order_rec.state,
        x_province                     => order_rec.province,
        x_county                       => order_rec.county,
        x_country                      => order_rec.country,
        x_postal_code                  => order_rec.postal_code,
        x_email_address                => order_rec.email_address,
        x_phone_country_code           => order_rec.phone_country_code,
        x_phone_area_code              => order_rec.phone_area_code,
        x_phone_number                 => order_rec.phone_number,
        x_phone_extension              => order_rec.phone_extension,
        x_fax_country_code             => order_rec.fax_country_code,
        x_fax_area_code                => order_rec.fax_area_code,
        x_fax_number                   => order_rec.fax_number,
        x_delivery_fee                 => order_rec.delivery_fee,
        x_order_fee                    => p_order_fee,
        x_request_type                 => order_rec.request_type,
        x_submit_method                => order_rec.submit_method,
        x_invoice_id                   => order_rec.invoice_id,
        x_mode                         => 'R',
        x_order_description            => order_rec.order_description,
        x_order_placed_by              => order_rec.order_placed_by
      );
    END update_order_for_recalc;
    -- Create a local Procedure to update  order:
    PROCEDURE update_itm_for_recalc (p_item_number NUMBER, p_order_fee NUMBER, p_plan_id NUMBER) IS
    BEGIN
      OPEN cur_itm_dtls_upd (p_item_number);
      FETCH cur_itm_dtls_upd INTO rec_dtls;
      CLOSE cur_itm_dtls_upd;
      -- Make a Call to the update row fro igs_as_doc_details
      igs_as_doc_details_pkg.update_row (
        x_rowid                        => rec_dtls.row_id,
        x_order_number                 => rec_dtls.order_number,
        x_document_type                => rec_dtls.document_type,
        x_document_sub_type            => rec_dtls.document_sub_type,
        x_item_number                  => rec_dtls.item_number,
        x_item_status                  => rec_dtls.item_status,
        x_date_produced                => rec_dtls.date_produced,
        x_incl_curr_course             => rec_dtls.incl_curr_course,
        x_num_of_copies                => rec_dtls.num_of_copies,
        x_comments                     => rec_dtls.comments,
        x_recip_pers_name              => rec_dtls.recip_pers_name,
        x_recip_inst_name              => rec_dtls.recip_inst_name,
        x_recip_addr_line_1            => rec_dtls.recip_addr_line_1,
        x_recip_addr_line_2            => rec_dtls.recip_addr_line_2,
        x_recip_addr_line_3            => rec_dtls.recip_addr_line_3,
        x_recip_addr_line_4            => rec_dtls.recip_addr_line_4,
        x_recip_city                   => rec_dtls.recip_city,
        x_recip_postal_code            => rec_dtls.recip_postal_code,
        x_recip_state                  => rec_dtls.recip_state,
        x_recip_province               => rec_dtls.recip_province,
        x_recip_county                 => rec_dtls.recip_county,
        x_recip_country                => rec_dtls.recip_country,
        x_recip_fax_area_code          => rec_dtls.recip_fax_area_code,
        x_recip_fax_country_code       => rec_dtls.recip_fax_country_code,
        x_recip_fax_number             => rec_dtls.recip_fax_number,
        x_delivery_method_type         => rec_dtls.delivery_method_type,
        x_programs_on_file             => rec_dtls.programs_on_file,
        x_missing_acad_record_data_ind => rec_dtls.missing_acad_record_data_ind,
        x_missing_academic_record_data => rec_dtls.missing_academic_record_data,
        x_send_transcript_immediately  => rec_dtls.send_transcript_immediately,
        x_hold_release_of_final_grades => rec_dtls.hold_release_of_final_grades,
        x_fgrade_cal_type              => rec_dtls.fgrade_cal_type,
        x_fgrade_seq_num               => rec_dtls.fgrade_seq_num,
        x_hold_degree_expected         => rec_dtls.hold_degree_expected,
        x_deghold_cal_type             => rec_dtls.deghold_cal_type,
        x_deghold_seq_num              => rec_dtls.deghold_seq_num,
        x_hold_for_grade_chg           => rec_dtls.hold_for_grade_chg,
        x_special_instr                => rec_dtls.special_instr,
        x_express_mail_type            => rec_dtls.express_mail_type,
        x_express_mail_track_num       => rec_dtls.express_mail_track_num,
        x_ge_certification             => rec_dtls.ge_certification,
        x_external_comments            => rec_dtls.external_comments,
        x_internal_comments            => rec_dtls.internal_comments,
        x_dup_requested                => rec_dtls.dup_requested,
        x_dup_req_date                 => rec_dtls.dup_req_date,
        x_dup_sent_date                => rec_dtls.dup_sent_date,
        x_enr_term_cal_type            => rec_dtls.enr_term_cal_type,
        x_enr_ci_sequence_number       => rec_dtls.enr_ci_sequence_number,
        x_incl_attempted_hours         => rec_dtls.incl_attempted_hours,
        x_incl_class_rank              => rec_dtls.incl_class_rank,
        x_incl_progresssion_status     => rec_dtls.incl_progresssion_status,
        x_incl_class_standing          => rec_dtls.incl_class_standing,
        x_incl_cum_hours_earned        => rec_dtls.incl_cum_hours_earned,
        x_incl_gpa                     => rec_dtls.incl_gpa,
        x_incl_date_of_graduation      => rec_dtls.incl_date_of_graduation,
        x_incl_degree_dates            => rec_dtls.incl_degree_dates,
        x_incl_degree_earned           => rec_dtls.incl_degree_earned,
        x_incl_date_of_entry           => rec_dtls.incl_date_of_entry,
        x_incl_drop_withdrawal_dates   => rec_dtls.incl_drop_withdrawal_dates,
        x_incl_hrs_for_curr_term       => rec_dtls.incl_hrs_earned_for_curr_term,
        x_incl_majors                  => rec_dtls.incl_majors,
        x_incl_last_date_of_enrollment => rec_dtls.incl_last_date_of_enrollment,
        x_incl_professional_licensure  => rec_dtls.incl_professional_licensure,
        x_incl_college_affiliation     => rec_dtls.incl_college_affiliation,
        x_incl_instruction_dates       => rec_dtls.incl_instruction_dates,
        x_incl_usec_dates              => rec_dtls.incl_usec_dates,
        x_incl_program_attempt         => rec_dtls.incl_program_attempt,
        x_incl_attendence_type         => rec_dtls.incl_attendence_type,
        x_incl_last_term_enrolled      => rec_dtls.incl_last_term_enrolled,
        x_incl_ssn                     => rec_dtls.incl_ssn,
        x_incl_date_of_birth           => rec_dtls.incl_date_of_birth,
        x_incl_disciplin_standing      => rec_dtls.incl_disciplin_standing,
        x_incl_no_future_term          => rec_dtls.incl_no_future_term,
        x_incl_acurat_till_copmp_dt    => rec_dtls.incl_acurat_till_copmp_dt,
        x_incl_cant_rel_without_sign   => rec_dtls.incl_cant_rel_without_sign,
        x_mode                         => 'R',
        x_return_status                => lv_return_status,
        x_msg_data                     => lv_msg_data,
        x_msg_count                    => ln_msg_count,
        x_doc_fee_per_copy             => p_order_fee,
        x_delivery_fee                 => rec_dtls.delivery_fee,
        x_recip_email                  => rec_dtls.recip_email,
        x_overridden_doc_delivery_fee  => rec_dtls.overridden_doc_delivery_fee,
        x_overridden_document_fee      => rec_dtls.overridden_document_fee,
        x_fee_overridden_by            => rec_dtls.fee_overridden_by,
        x_fee_overridden_date          => rec_dtls.fee_overridden_date,
        x_incl_department              => rec_dtls.incl_department,
        x_incl_field_of_stdy           => rec_dtls.incl_field_of_stdy,
        x_incl_attend_mode             => rec_dtls.incl_attend_mode,
        x_incl_yop_acad_prd            => rec_dtls.incl_yop_acad_prd,
        x_incl_intrmsn_st_end          => rec_dtls.incl_intrmsn_st_end,
        x_incl_hnrs_lvl                => rec_dtls.incl_hnrs_lvl,
        x_incl_awards                  => rec_dtls.incl_awards,
        x_incl_award_aim               => rec_dtls.incl_award_aim,
        x_incl_acad_sessions           => rec_dtls.incl_acad_sessions,
        x_incl_st_end_acad_ses         => rec_dtls.incl_st_end_acad_ses,
        x_incl_hesa_num                => rec_dtls.incl_hesa_num,
        x_incl_location                => rec_dtls.incl_location,
        x_incl_program_type            => rec_dtls.incl_program_type,
        x_incl_program_name            => rec_dtls.incl_program_name,
        x_incl_prog_atmpt_stat         => rec_dtls.incl_prog_atmpt_stat,
        x_incl_prog_atmpt_end          => rec_dtls.incl_prog_atmpt_end,
        x_incl_prog_atmpt_strt         => rec_dtls.incl_prog_atmpt_strt,
        x_incl_req_cmplete             => rec_dtls.incl_req_cmplete,
        x_incl_expected_compl_dt       => rec_dtls.incl_expected_compl_dt,
        x_incl_conferral_dt            => rec_dtls.incl_conferral_dt,
        x_incl_thesis_title            => rec_dtls.incl_thesis_title,
        x_incl_program_code            => rec_dtls.incl_program_code,
        x_incl_program_ver             => rec_dtls.incl_program_ver,
        x_incl_stud_no                 => rec_dtls.incl_stud_no,
        x_incl_surname                 => rec_dtls.incl_surname,
        x_incl_fore_name               => rec_dtls.incl_fore_name,
        x_incl_prev_names              => rec_dtls.incl_prev_names,
        x_incl_initials                => rec_dtls.incl_initials,
        x_doc_purpose_code             => rec_dtls.doc_purpose_code,
        x_plan_id                      => p_plan_id,
        x_produced_by                  => rec_dtls.produced_by,
        x_person_id                    => rec_dtls.person_id
      );
    END update_itm_for_recalc;
  BEGIN -- Begin Of Main Procedure
    ln_plan_id := p_plan_id;
    IF p_subs_unsubs = 'U' THEN
      -- Update the   IGS_AS_DOC_FEE_PMNT table with end date as SYSDATE.
      OPEN cur_doc_fee_pmnt;
      FETCH cur_doc_fee_pmnt INTO rec_doc_fee_pmnt;
      CLOSE cur_doc_fee_pmnt;
      BEGIN
        igs_as_doc_fee_pmnt_pkg.update_row (
          x_rowid                        => rec_doc_fee_pmnt.row_id,
          x_person_id                    => rec_doc_fee_pmnt.person_id,
          x_fee_paid_date                => rec_doc_fee_pmnt.fee_paid_date,
          x_fee_amount                   => rec_doc_fee_pmnt.fee_amount,
          x_fee_recorded_date            => rec_doc_fee_pmnt.fee_recorded_date,
          x_fee_recorded_by              => rec_doc_fee_pmnt.fee_recorded_by,
          x_mode                         => 'R',
          x_plan_id                      => rec_doc_fee_pmnt.plan_id,
          x_invoice_id                   => rec_doc_fee_pmnt.invoice_id,
          x_plan_discon_from             => SYSDATE,
          x_plan_discon_by               => p_admin_person_id,
          x_num_of_copies                => rec_doc_fee_pmnt.num_of_copies,
          x_prev_paid_plan               => rec_doc_fee_pmnt.prev_paid_plan,
          x_cal_type                     => rec_doc_fee_pmnt.cal_type,
          x_ci_sequence_number           => rec_doc_fee_pmnt.ci_sequence_number,
          x_program_on_file              => rec_doc_fee_pmnt.program_on_file,
          x_return_status                => lv_return_status,
          x_msg_data                     => lv_msg_data,
          x_msg_count                    => ln_msg_count
        );
      END;
      -- Update all the items with the proper fee.
      FOR uns_itm IN cur_itm_dtls_unsc LOOP
        prev_order_number := uns_itm.order_number;
        p_orders_recalc := p_orders_recalc || uns_itm.order_number || ',';
        --Get the Fee that this document will require if plan were not subscribed by the user.
        lndoc_fee := igs_as_ss_doc_request.get_transcript_fee (
                       p_person_id                    => p_person_id,
                       p_document_type                => uns_itm.document_type,
                       p_number_of_copies             => uns_itm.num_of_copies,
                       p_include_delivery_fee         => 'N',
                       p_delivery_method_type         => uns_itm.delivery_method_type,
                       p_item_number                  => uns_itm.item_number
                     );
        -- Upadete the Item Details table with Newly calculated Fee and Plan ID with NULL:
        update_itm_for_recalc (uns_itm.item_number, uns_itm.order_number, NULL);
        -- After Looping through all the Items of the order update the order
        IF NVL (next_order_number, prev_order_number) <> prev_order_number THEN
          update_order_for_recalc (prev_order_number, ln_order_fee);
          ln_order_fee := lndoc_fee;
        END IF;
        next_order_number := uns_itm.order_number;
        ln_order_fee := ln_order_fee + lndoc_fee;
      END LOOP; -- Upd Doc Details.
      ---   UPdate the order for the last Order or if the Order had only one item.
      -- Remove the trailing Comma
      p_orders_recalc := SUBSTR (p_orders_recalc, 1, LENGTH (p_orders_recalc) - 1);
      update_order_for_recalc (prev_order_number, ln_order_fee);
    ELSIF p_subs_unsubs = 'S' THEN
      OPEN cur_plan;
      FETCH cur_plan INTO plan_rec;
      CLOSE cur_plan;
      -- Hope not more than 100 items are in status 'INCOMPLETE'
      lnplan_limit := NVL (plan_rec.quantity_limit, 100);
      FOR subs_itm IN cur_itm_dtls_subs LOOP
        lnitmused := lnitmused + subs_itm.num_of_copies;
        EXIT WHEN lnitmused > lnplan_limit;
        prev_order_number := subs_itm.order_number;
        p_orders_recalc := p_orders_recalc || subs_itm.order_number || ',';
        --Get the Fee that this document will require if this plan is subscribed by the user.
        get_doc_and_delivery_fee (
          p_person_id                    => p_person_id,
          p_document_type                => subs_itm.document_type,
          p_document_sub_type            => NULL,
          p_number_of_copies             => subs_itm.num_of_copies,
          p_delivery_method_type         => subs_itm.delivery_method_type,
          p_program_on_file              => subs_itm.programs_on_file,
          p_plan_id                      => ln_plan_id,
          p_document_fee                 => lndoc_fee,
          p_delivery_fee                 => ldeliv_fee,
          p_item_number                  => subs_itm.item_number
        );
        -- Upadete the Item Details table with Newly calculated Fee and Plan ID with NULL:
        update_itm_for_recalc (subs_itm.item_number, subs_itm.order_number, ln_plan_id);
        -- After Looping through all the Items of the order update the order
        IF NVL (next_order_number, prev_order_number) <> prev_order_number THEN
          update_order_for_recalc (prev_order_number, ln_order_fee);
          ln_order_fee := lndoc_fee;
        END IF;
        next_order_number := subs_itm.order_number;
        ln_order_fee := ln_order_fee + lndoc_fee;
      END LOOP; -- Upd Doc Details for Subscribe.
      -- Update the order for the last Order or if the Order had only one item.
      -- Remove the trailing Comma
      p_orders_recalc := SUBSTR (p_orders_recalc, 1, LENGTH (p_orders_recalc) - 1);
      update_order_for_recalc (prev_order_number, ln_order_fee);
    END IF;
  END re_calc_doc_fees; -- End Procedure

  PROCEDURE create_trns_plan_invoice_id (
    p_person_id                    IN     NUMBER,
    p_fee_amount                   IN     NUMBER,
    p_invoice_id                   OUT NOCOPY NUMBER,
    p_return_status                OUT NOCOPY VARCHAR2,
    p_msg_count                    OUT NOCOPY NUMBER,
    p_msg_data                     OUT NOCOPY VARCHAR2,
    p_waiver_amount                OUT NOCOPY NUMBER
  ) AS
    /*----------------------------------------------------------------------------
     ||  Created By :
     ||  Created On :
     ||  Purpose :
     ||  Known limitations, enhancements or remarks :
     ||  Change History :
     ||  Who             When            What
     ||  (reverse chronological order - newest change first)
     || vvutukur   27-Nov-2002 Enh#2584986.GL Interface Build. Removed the references to igs_fi_cur. Instead defaulted
     ||                        the currency with the one that is set up in System Options Form. The same has been
     ||                        used for the creation of the charge record.
     || swaghmar   22-Aug-2005 Bug 4506599 Modified create_trns_plan_invoice_id ()
     ----------------------------------------------------------------------------*/
--ijeddy modified the query in this cursor for bug 3229087.
    CURSOR c_ftci IS
      SELECT   ftci.fee_cal_type,
               ftci.fee_ci_sequence_number,
               ftci.fee_type,
               ft.description description
      FROM     igs_fi_f_typ_ca_inst ftci,
               igs_ca_da_inst_v daiv,
               igs_ca_da_inst_v daiv1,
               igs_fi_fee_type ft,
               igs_fi_fee_str_stat stat
      WHERE    ftci.fee_type = ft.fee_type
      AND      ft.s_fee_type = 'DOCUMENT'
      AND      ftci.fee_type_ci_status = stat.fee_structure_status
      AND      stat.s_fee_structure_status = 'ACTIVE'
      AND      NVL (ft.closed_ind, 'N') = 'N'
      AND      (daiv.dt_alias = ftci.start_dt_alias
                AND daiv.sequence_number = ftci.start_dai_sequence_number
                AND daiv.cal_type = ftci.fee_cal_type
                AND daiv.ci_sequence_number = ftci.fee_ci_sequence_number
               )
      AND      (daiv1.dt_alias = ftci.end_dt_alias
                AND daiv1.sequence_number = ftci.end_dai_sequence_number
                AND daiv1.cal_type = ftci.fee_cal_type
                AND daiv1.ci_sequence_number = ftci.fee_ci_sequence_number
               )
      AND      SYSDATE BETWEEN daiv.alias_val AND NVL (daiv1.alias_val, SYSDATE)
      ORDER BY daiv.alias_val DESC;
    v_ftci_rec       c_ftci%ROWTYPE;
    l_v_currency     igs_fi_control_all.currency_cd%TYPE;
    l_v_curr_desc    fnd_currencies_tl.NAME%TYPE;
    l_v_message_name fnd_new_messages.message_name%TYPE;
  BEGIN
    fnd_msg_pub.initialize;
    p_msg_count := 0;
    OPEN c_ftci;
    FETCH c_ftci INTO v_ftci_rec;
    IF c_ftci%NOTFOUND THEN
      CLOSE c_ftci;
      p_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name ('IGS', 'IGS_FI_FEE_ENCUMB_FEECAT_CAL');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE c_ftci;
    --Capture the default currency that is set up in System Options Form.
    igs_fi_gen_gl.finp_get_cur (
      p_v_currency_cd                => l_v_currency,
      p_v_curr_desc                  => l_v_curr_desc,
      p_v_message_name               => l_v_message_name
    );
    IF l_v_message_name IS NOT NULL THEN
      fnd_message.set_name ('IGS', l_v_message_name);
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;
    igs_fi_ss_charges_api_pvt.create_charge (
      p_api_version                  => 2.0,
      p_init_msg_list                => fnd_api.g_false,
      p_commit                       => fnd_api.g_false,
      p_validation_level             => fnd_api.g_valid_level_full,
      p_person_id                    => p_person_id,
      p_fee_type                     => v_ftci_rec.fee_type,
      p_fee_cat                      => NULL,
      p_fee_cal_type                 => v_ftci_rec.fee_cal_type,
      p_fee_ci_sequence_number       => v_ftci_rec.fee_ci_sequence_number,
      p_course_cd                    => NULL,
      p_attendance_type              => NULL,
      p_attendance_mode              => NULL,
      p_invoice_amount               => p_fee_amount,
      p_invoice_creation_date        => SYSDATE,
      p_invoice_desc                 => v_ftci_rec.description,
      p_transaction_type             => 'DOCUMENT',
      p_currency_cd                  => l_v_currency,
      p_exchange_rate                => 1,
      p_effective_date               => NULL,
      p_waiver_flag                  => NULL,
      p_waiver_reason                => NULL,
      p_source_transaction_id        => NULL,
      p_invoice_id                   => p_invoice_id,
      x_return_status                => p_return_status,
      x_msg_count                    => p_msg_count,
      x_msg_data                     => p_msg_data,
      x_waiver_amount                => p_waiver_amount
    );
    IF (p_return_status <> fnd_api.g_ret_sts_success) THEN
      RETURN;
    END IF;
--    COMMIT;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      p_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count => p_msg_count, p_data => p_msg_data);
      RETURN;
    WHEN fnd_api.g_exc_unexpected_error THEN
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => p_msg_count, p_data => p_msg_data);
      RETURN;
    WHEN OTHERS THEN
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_message.set_token ('NAME', 'CREATE_INVOICE_ID : ' || SQLERRM);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get (p_count => p_msg_count, p_data => p_msg_data);
      RETURN;
  END create_trns_plan_invoice_id;

  PROCEDURE delete_bulk_item (
    p_item_number                  IN     NUMBER,
    p_msg_count                    OUT NOCOPY NUMBER,
    p_msg_data                     OUT NOCOPY VARCHAR2,
    p_return_status                OUT NOCOPY VARCHAR2
  ) AS
    -- Delete allowed only if the item is
    -- not in completed state
    CURSOR c_chk_del_allwed IS
      SELECT COUNT (*)
      FROM   igs_as_doc_details
      WHERE  item_number = p_item_number
      AND    item_status = 'PROCESSED';
    CURSOR c_items IS
      SELECT ROWID
      FROM   igs_as_doc_details
      WHERE  item_number = p_item_number;
    -- Record types
    c_items_rec c_items%ROWTYPE;
    l_count     NUMBER;
    l_rowid     igs_as_order_hdr_v.row_id%TYPE;
  BEGIN
    fnd_msg_pub.initialize;
    OPEN c_chk_del_allwed;
    FETCH c_chk_del_allwed INTO l_count;
    CLOSE c_chk_del_allwed;
    IF l_count > 0 THEN
      fnd_message.set_name ('IGS', 'IGS_SS_AS_CNT_DEL_BLK_ITM');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;
    -- Delete all the items in this order
    FOR c_items_rec IN c_items LOOP
      igs_as_doc_details_pkg.delete_row (
        x_rowid                        => c_items_rec.ROWID,
        x_return_status                => p_return_status,
        x_msg_data                     => p_msg_data,
        x_msg_count                    => p_msg_count
      );
      IF NVL (p_return_status, fnd_api.g_ret_sts_success) <> fnd_api.g_ret_sts_success THEN
        RETURN;
      END IF;
    END LOOP;
    --Delete all the interface items for this order
    DELETE igs_as_ord_itm_int
    WHERE  item_number = p_item_number;
    -- Initialize API return status to success.
    p_return_status := fnd_api.g_ret_sts_success;
    -- Standard call to get message count and if count is 1, get message info
    fnd_msg_pub.count_and_get (p_count => p_msg_count, p_data => p_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      p_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count => p_msg_count, p_data => p_msg_data);
      RETURN;
    WHEN fnd_api.g_exc_unexpected_error THEN
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => p_msg_count, p_data => p_msg_data);
      RETURN;
    WHEN OTHERS THEN
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_message.set_token ('NAME', 'Insert_Row : ' || SQLERRM);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get (p_count => p_msg_count, p_data => p_msg_data);
      RETURN;
  END delete_bulk_item;

  PROCEDURE place_bulk_order (
    p_person_ids                   IN     VARCHAR2,
    p_program_cds                  IN     VARCHAR2,
    p_prog_vers                    IN     VARCHAR2,
    p_printer_name                 IN     VARCHAR2,
    p_schedule_date                IN     DATE,
    p_action_type                  IN     VARCHAR2, -- Whether create doc only or create doc and produce docs also
    p_trans_type                   IN     igs_as_doc_details.document_type%TYPE,
    p_deliv_meth                   IN     igs_as_doc_details.delivery_method_type%TYPE,
    p_incl_ind                     IN     VARCHAR2,
    p_num_copies                   IN     NUMBER,
    p_admin_person_id              IN     hz_parties.party_id%TYPE,
    p_order_desc                   IN     igs_as_order_hdr.order_description%TYPE,
    p_purpose                      IN     igs_as_doc_details.doc_purpose_code%TYPE,
    p_effbuff                      OUT NOCOPY VARCHAR2,
    p_status                       OUT NOCOPY VARCHAR2
  ) AS
    l_req_id NUMBER;
  BEGIN
    --Call bulk order job
    bulk_order_job (
      errbuf                         => p_effbuff,
      retcode                        => p_status,
      p_person_ids                   => p_person_ids,
      p_program_cds                  => p_program_cds,
      p_prog_vers                    => p_prog_vers,
      p_printer_name                 => p_printer_name,
      p_schedule_date                => p_schedule_date,
      p_action_type                  => p_action_type,
      p_trans_type                   => p_trans_type,
      p_deliv_meth                   => p_deliv_meth,
      p_incl_ind                     => p_incl_ind,
      p_num_copies                   => p_num_copies,
      p_admin_person_id              => p_admin_person_id,
      p_order_desc                   => p_order_desc,
      p_purpose                      => p_purpose
    );
    IF  p_action_type = 'PRODUCE_DOCS'
        AND p_effbuff = 0 THEN
      p_status := fnd_api.g_ret_sts_error;
      p_effbuff := fnd_message.get;
    ELSIF p_status = 1 THEN
      p_status := fnd_api.g_ret_sts_error;
    ELSE
      p_status := fnd_api.g_ret_sts_success;
    END IF;
  END place_bulk_order;

  PROCEDURE submit_print_request (
    p_errbuf                       OUT NOCOPY VARCHAR2,
    p_retcode                      OUT NOCOPY VARCHAR2,
    p_order_number                 IN     igs_as_order_hdr.order_number%TYPE,
    p_item_numbers                 IN     igs_as_doc_details.item_number%TYPE,
    p_printer_name                 IN     VARCHAR2,
    p_schedule_date                IN     DATE
  ) AS
    CURSOR cur_document_type (cp_order_number IN igs_as_order_hdr.order_number%TYPE) IS
      SELECT document_type
      FROM   igs_as_doc_details
      WHERE  order_number = cp_order_number;
    rec_document_type     cur_document_type%ROWTYPE;
    l_msg_count           NUMBER (10);
    l_msg_data            VARCHAR2 (2000);
    l_return_status       VARCHAR2 (2);
    l_rowid               VARCHAR2 (30)                              := NULL;
    l_order_number        igs_as_doc_details.order_number%TYPE;
    l_item_number         igs_as_doc_details.item_number%TYPE;
    l_programs_on_file    igs_as_doc_details.programs_on_file%TYPE;
    l_printer_options_ret BOOLEAN;
    l_req_id              NUMBER;
    l_oss_country_cd      VARCHAR2 (10)                              := fnd_profile.VALUE ('OSS_COUNTRY_CODE');
    l_rep_name            VARCHAR2 (10);
    l_message             VARCHAR2 (2000);
  BEGIN
    l_printer_options_ret :=
      fnd_request.set_print_options (
        printer => p_printer_name,
        -- style          => 'PORTRAIT'     ,
        copies => 1,
        save_output => TRUE,
        print_together => 'N'
      );
    OPEN cur_document_type (p_order_number);
    FETCH cur_document_type INTO rec_document_type;
    CLOSE cur_document_type;
    IF (rec_document_type.document_type = 'TRANSCRIPT') THEN
      IF l_oss_country_cd = 'US' THEN
        l_rep_name := 'IGSASP26';
      ELSE
        l_rep_name := 'IGSASP27';
      END IF;
    END IF;
    --This report now needs to take the order number as parameter
    l_req_id := fnd_request.submit_request (
                  application                    => 'IGS',
                  program                        => l_rep_name,
                  description                    => NULL,
                  start_time                     => NVL (p_schedule_date, SYSDATE),
                  sub_request                    => FALSE,
                  argument1                      => 'N',
                  argument2                      => '',
                  argument3                      => '',
                  argument4                      => '',
                  argument5                      => NULL,
                  argument6                      => '',
                  argument7                      => '',
                  argument8                      => '',
                  argument9                      => p_order_number,
                  argument10                     => p_item_numbers
                );
    p_retcode := TO_CHAR (l_req_id);
    IF l_req_id = 0 THEN
      p_errbuf := fnd_message.get;
    END IF;
    COMMIT; --Since the job will not be saved till commit is done
  END submit_print_request;

  PROCEDURE produce_docs_ss (
    p_item_numbers                 IN     VARCHAR2,
    p_printer_name                 IN     VARCHAR2,
    p_schedule_date                IN     DATE,
    p_ret_status                   OUT NOCOPY VARCHAR2,
    p_effbuff                      OUT NOCOPY VARCHAR2,
    p_req_ids                      OUT NOCOPY VARCHAR2
  ) AS
    l_req_id              NUMBER (20);
    l_item_numbers        VARCHAR2 (2000);
    l_oss_country_cd      VARCHAR2 (10);
    l_rep_name            VARCHAR2 (10);
    l_printer_options_ret BOOLEAN;
    TYPE rec IS REF CURSOR;
    v                     rec;
    v1                    rec;
    encert                VARCHAR2 (2000)
      := 'SELECT 1  FROM   igs_as_ord_itm_int WHERE  document_type = ''ENCERT'' AND item_number IN ('
         || p_item_numbers
         || ')';
    trns                  VARCHAR2 (2000)
      := 'SELECT 1 FROM   igs_as_ord_itm_int WHERE  document_type = ''TRANSCRIPT''  AND item_number IN ('
         || p_item_numbers
         || ')';
    CURSOR c_doc (cp_doc_type igs_as_ord_itm_int.document_type%TYPE, cp_item_numbers VARCHAR2) IS
      SELECT 1
      FROM   igs_as_ord_itm_int
      WHERE  document_type = cp_doc_type
      AND    item_number IN (cp_item_numbers);
    l_encert              NUMBER (1)      := 0;
    l_trns                NUMBER (1)      := 0;
  BEGIN
    l_oss_country_cd := fnd_profile.VALUE ('OSS_COUNTRY_CODE');
    -- verify the type of doc
    OPEN v FOR encert;
    LOOP
      FETCH v INTO l_encert;
      EXIT WHEN v%NOTFOUND;
    END LOOP;
    OPEN v1 FOR trns;
    LOOP
      FETCH v1 INTO l_trns;
      EXIT WHEN v1%NOTFOUND;
    END LOOP;
    IF l_trns = 1 THEN
      IF l_oss_country_cd = 'US' THEN
        l_rep_name := 'IGSASP26';
      ELSE
        l_rep_name := 'IGSASP27';
      END IF;
      l_printer_options_ret := fnd_request.set_print_options (
                                 printer                        => p_printer_name,
                                 -- style          => 'PORTRAIT'     ,
                                 copies                         => 1,
                                 save_output                    => TRUE,
                                 print_together                 => 'N'
                               );
      l_req_id := fnd_request.submit_request (
                    application                    => 'IGS',
                    program                        => l_rep_name,
                    description                    => NULL,
                    start_time                     => NVL (p_schedule_date, SYSDATE),
                    sub_request                    => FALSE,
                    argument1                      => 'N',
                    argument2                      => '',
                    argument3                      => NULL,
                    argument4                      => '',
                    argument5                      => NULL,
                    argument6                      => '',
                    argument7                      => '',
                    argument8                      => '',
                    argument9                      => NULL, --Order Number
                    argument10                     => p_item_numbers --Concatr string of item number
                  );
      IF l_req_id = 0 THEN
        p_ret_status := fnd_api.g_ret_sts_error;
        p_effbuff := fnd_message.get;
      ELSIF l_req_id IS NULL THEN
        p_ret_status := fnd_api.g_ret_sts_unexp_error;
        p_effbuff := fnd_message.get;
      ELSE
        p_ret_status := fnd_api.g_ret_sts_success;
        p_req_ids := l_req_id;
      END IF;
    END IF;
    IF l_encert = 1 THEN
      IF l_oss_country_cd = 'US' THEN
        l_rep_name := 'IGSASP28';
      ELSE
        l_rep_name := 'IGSASP29';
      END IF;
      l_printer_options_ret := fnd_request.set_print_options (
                                 printer                        => p_printer_name,
                                 -- style          => 'PORTRAIT'     ,
                                 copies                         => 1,
                                 save_output                    => TRUE,
                                 print_together                 => 'N'
                               );
      l_req_id := fnd_request.submit_request (
                    application                    => 'IGS',
                    program                        => l_rep_name,
                    description                    => NULL,
                    start_time                     => NVL (p_schedule_date, SYSDATE),
                    sub_request                    => FALSE,
                    argument1                      => 'N',
                    argument2                      => '',
                    argument3                      => p_item_numbers,
                    argument4                      => '',
                    argument5                      => NULL,
                    argument6                      => '',
                    argument7                      => ''
                  );
      IF l_req_id = 0 THEN
        p_ret_status := fnd_api.g_ret_sts_error;
        p_effbuff := fnd_message.get;
      ELSIF l_req_id IS NULL THEN
        p_ret_status := fnd_api.g_ret_sts_unexp_error;
        p_effbuff := fnd_message.get;
      ELSE
        p_ret_status := fnd_api.g_ret_sts_success;
        IF p_req_ids IS NULL THEN
          p_req_ids := l_req_id;
        ELSE
          p_req_ids := p_req_ids || ', ' || l_req_id;
        END IF;
      END IF;
    END IF;
    COMMIT;
  END produce_docs_ss;

  PROCEDURE bulk_order_job (
    errbuf                         OUT NOCOPY VARCHAR2,
    retcode                        OUT NOCOPY NUMBER,
    p_person_ids                   IN     VARCHAR2,
    p_program_cds                  IN     VARCHAR2,
    p_prog_vers                    IN     VARCHAR2,
    p_printer_name                 IN     VARCHAR2,
    p_schedule_date                IN     DATE,
    p_action_type                  IN     VARCHAR2, -- Whether create doc only or create doc and produce docs also
    p_trans_type                   IN     igs_as_doc_details.document_type%TYPE,
    p_deliv_meth                   IN     igs_as_doc_details.delivery_method_type%TYPE,
    p_incl_ind                     IN     VARCHAR2,
    p_num_copies                   IN     NUMBER,
    p_admin_person_id              IN     hz_parties.party_id%TYPE,
    p_order_desc                   IN     igs_as_order_hdr.order_description%TYPE,
    p_purpose                      IN     igs_as_doc_details.doc_purpose_code%TYPE
  ) AS
    l_person_id           VARCHAR2 (15);
    l_prog_cd             VARCHAR2 (10);
    l_prog_ver            NUMBER (10);
    l_seperator           VARCHAR2 (1)                               := '*';
    l_person_ids          VARCHAR2 (2000);
    l_program_cds         VARCHAR2 (2000);
    l_prog_vers           VARCHAR2 (2000);
    l_msg_count           NUMBER (10);
    l_msg_data            VARCHAR2 (2000);
    l_return_status       VARCHAR2 (2);
    l_rowid               VARCHAR2 (30)                              := NULL;
    l_order_number        igs_as_doc_details.order_number%TYPE;
    l_item_number         igs_as_doc_details.item_number%TYPE;
    l_programs_on_file    igs_as_doc_details.programs_on_file%TYPE;
    l_printer_options_ret BOOLEAN;
    l_req_id              NUMBER;
    l_oss_country_cd      VARCHAR2 (10);
    l_rep_name            VARCHAR2 (10);
    l_message             VARCHAR2 (2000);

    CURSOR c_prsn_info (p_person_id hz_parties.party_id%TYPE) IS
      SELECT party_name,
             address1,
             address2,
             address3,
             address4,
             city,
             state,
             province,
             postal_code,
             county,
             country,
             email_address,
             party_number
      FROM   hz_parties
      WHERE  party_id = p_person_id;
    -- kdande; 12-Jan-2004; Bug# 3220696
    CURSOR c_lkup_meaning IS
      SELECT meaning
      FROM   fnd_lookup_values
      WHERE  lookup_type = 'PE_MIL_ASS_STATUS'
      AND    lookup_code = 'NA'
      AND    LANGUAGE = USERENV ('LANG')
      AND    view_application_id = 8405
      AND    security_group_id = 0;
    c_prsn_info_rec       c_prsn_info%ROWTYPE;
    l_one_item_created    BOOLEAN                                    := FALSE;
    l_na_meaning          igs_lookups_view.meaning%TYPE;
  BEGIN

    IGS_GE_GEN_003.SET_ORG_ID(); -- swaghmar, bug# 4951054

    l_oss_country_cd := fnd_profile.VALUE ('OSS_COUNTRY_CODE');
    l_person_ids := p_person_ids;
    l_program_cds := p_program_cds;
    l_prog_vers := p_prog_vers;
    -- Admin Person address information for order header table
    OPEN c_prsn_info (p_admin_person_id);
    FETCH c_prsn_info INTO c_prsn_info_rec;
    CLOSE c_prsn_info;
    --Get meaning of word NA
    OPEN c_lkup_meaning;
    FETCH c_lkup_meaning INTO l_na_meaning;
    CLOSE c_lkup_meaning;
    --Admin can create order if there is no primary address associated with admin.
    --Only addr1 and country will have NA
    --Create Order Here
    errbuf := '0';
    --ijeddy, Bug 3129712, put the nvl to country instead of county.
    igs_as_order_hdr_pkg.insert_row (
      x_msg_count                    => l_msg_count,
      x_msg_data                     => l_msg_data,
      x_return_status                => l_return_status,
      x_rowid                        => l_rowid,
      x_order_number                 => l_order_number,
      x_order_status                 => 'INPROCESS',
      x_date_completed               => NULL,
      x_person_id                    => p_admin_person_id,
      x_addr_line_1                  => NVL (c_prsn_info_rec.address1, l_na_meaning),
      x_addr_line_2                  => c_prsn_info_rec.address2,
      x_addr_line_3                  => c_prsn_info_rec.address3,
      x_addr_line_4                  => c_prsn_info_rec.address4,
      x_city                         => c_prsn_info_rec.city,
      x_state                        => c_prsn_info_rec.state,
      x_province                     => c_prsn_info_rec.province,
      x_county                       => c_prsn_info_rec.county,
      x_country                      => NVL (c_prsn_info_rec.country, l_na_meaning),
      x_postal_code                  => c_prsn_info_rec.postal_code,
      x_email_address                => c_prsn_info_rec.email_address,
      x_phone_country_code           => NULL,
      x_phone_area_code              => NULL,
      x_phone_number                 => NULL,
      x_phone_extension              => NULL,
      x_fax_country_code             => NULL,
      x_fax_area_code                => NULL,
      x_fax_number                   => NULL,
      x_delivery_fee                 => 0,
      x_order_fee                    => 0,
      x_request_type                 => 'B',
      x_submit_method                => NULL,
      x_invoice_id                   => NULL,
      x_mode                         => 'R',
      x_order_description            => p_order_desc,
      x_order_placed_by              => p_admin_person_id
    );
    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      fnd_message.set_name ('IGS', l_msg_data);
      fnd_msg_pub.ADD;
      --Log the error and exit since if order is not created, no item can be created
      fnd_file.put_line (fnd_file.LOG, '------------------------------------------------------------------------');
      fnd_file.put_line (fnd_file.LOG, l_msg_data);
      fnd_file.put_line (fnd_file.LOG, '------------------------------------------------------------------------');
      RAISE fnd_api.g_exc_error;
    END IF;
    -- This is the main loop which loops through the persons for whom the items are  to be created ---------
    l_one_item_created := FALSE;
    WHILE LENGTH (l_person_ids) > 2 LOOP
      l_person_id := SUBSTR (l_person_ids, 0, INSTR (l_person_ids, l_seperator, 1) - 1); -- First Person Id
      l_prog_cd := SUBSTR (l_program_cds, 0, INSTR (l_program_cds, l_seperator, 1) - 1); -- First Prog Cd
      l_prog_ver := TO_NUMBER (SUBSTR (l_prog_vers, 0, INSTR (l_prog_vers, l_seperator, 1) - 1)); -- First Prog ver
      l_rowid := NULL; -- Nullify old row id
      l_item_number := NULL; -- Nullify old item number
      --Create Order Item here with items in inprocess status
      OPEN c_prsn_info (l_person_id);
      FETCH c_prsn_info INTO c_prsn_info_rec;
      CLOSE c_prsn_info;
      IF p_incl_ind = 'ALL' THEN
        l_programs_on_file := 'ALL';
      ELSE
        l_programs_on_file := l_prog_cd;
      END IF;
      igs_as_doc_details_pkg.insert_row (
        x_rowid                        => l_rowid,
        x_order_number                 => l_order_number,
        x_document_type                => 'TRANSCRIPT',
        x_document_sub_type            => p_trans_type,
        x_item_number                  => l_item_number,
        x_item_status                  => 'INPROCESS',
        x_date_produced                => NULL,
        x_incl_curr_course             => NULL,
        x_num_of_copies                => p_num_copies,
        x_comments                     => NULL,
        x_recip_pers_name              => c_prsn_info_rec.party_name,
        x_recip_inst_name              => c_prsn_info_rec.party_number,
        x_recip_addr_line_1            => NVL (c_prsn_info_rec.address1, l_na_meaning),
        x_recip_addr_line_2            => c_prsn_info_rec.address2,
        x_recip_addr_line_3            => c_prsn_info_rec.address3,
        x_recip_addr_line_4            => c_prsn_info_rec.address4,
        x_recip_city                   => c_prsn_info_rec.city,
        x_recip_postal_code            => c_prsn_info_rec.postal_code,
        x_recip_state                  => c_prsn_info_rec.state,
        x_recip_province               => c_prsn_info_rec.province,
        x_recip_county                 => c_prsn_info_rec.county,
        x_recip_country                => NVL (c_prsn_info_rec.country, l_na_meaning),
        x_recip_fax_area_code          => NULL,
        x_recip_fax_country_code       => NULL,
        x_recip_fax_number             => NULL,
        x_delivery_method_type         => p_deliv_meth,
        x_programs_on_file             => l_programs_on_file,
        x_missing_acad_record_data_ind => NULL,
        x_missing_academic_record_data => NULL,
        x_send_transcript_immediately  => NULL,
        x_hold_release_of_final_grades => NULL,
        x_fgrade_cal_type              => NULL,
        x_fgrade_seq_num               => NULL,
        x_hold_degree_expected         => NULL,
        x_deghold_cal_type             => NULL,
        x_deghold_seq_num              => NULL,
        x_hold_for_grade_chg           => NULL,
        x_special_instr                => NULL,
        x_express_mail_type            => NULL,
        x_express_mail_track_num       => NULL,
        x_ge_certification             => NULL,
        x_external_comments            => NULL,
        x_internal_comments            => NULL,
        x_dup_requested                => NULL,
        x_dup_req_date                 => NULL,
        x_dup_sent_date                => NULL,
        x_enr_term_cal_type            => NULL,
        x_enr_ci_sequence_number       => NULL,
        x_incl_attempted_hours         => NULL,
        x_incl_class_rank              => NULL,
        x_incl_progresssion_status     => NULL,
        x_incl_class_standing          => NULL,
        x_incl_cum_hours_earned        => NULL,
        x_incl_gpa                     => NULL,
        x_incl_date_of_graduation      => NULL,
        x_incl_degree_dates            => NULL,
        x_incl_degree_earned           => NULL,
        x_incl_date_of_entry           => NULL,
        x_incl_drop_withdrawal_dates   => NULL,
        x_incl_hrs_for_curr_term       => NULL,
        x_incl_majors                  => NULL,
        x_incl_last_date_of_enrollment => NULL,
        x_incl_professional_licensure  => NULL,
        x_incl_college_affiliation     => NULL,
        x_incl_instruction_dates       => NULL,
        x_incl_usec_dates              => NULL,
        x_incl_program_attempt         => NULL,
        x_incl_attendence_type         => NULL,
        x_incl_last_term_enrolled      => NULL,
        x_incl_ssn                     => NULL,
        x_incl_date_of_birth           => NULL,
        x_incl_disciplin_standing      => NULL,
        x_incl_no_future_term          => NULL,
        x_incl_acurat_till_copmp_dt    => NULL,
        x_incl_cant_rel_without_sign   => NULL,
        x_mode                         => 'R',
        x_return_status                => l_return_status,
        x_msg_data                     => l_msg_data,
        x_msg_count                    => l_msg_count,
        x_doc_fee_per_copy             => 0,
        x_delivery_fee                 => 0,
        x_recip_email                  => c_prsn_info_rec.email_address,
        x_overridden_doc_delivery_fee  => NULL,
        x_overridden_document_fee      => NULL,
        x_fee_overridden_by            => NULL,
        x_fee_overridden_date          => NULL,
        x_incl_department              => NULL,
        x_incl_field_of_stdy           => NULL,
        x_incl_attend_mode             => NULL,
        x_incl_yop_acad_prd            => NULL,
        x_incl_intrmsn_st_end          => NULL,
        x_incl_hnrs_lvl                => NULL,
        x_incl_awards                  => NULL,
        x_incl_award_aim               => NULL,
        x_incl_acad_sessions           => NULL,
        x_incl_st_end_acad_ses         => NULL,
        x_incl_hesa_num                => NULL,
        x_incl_location                => NULL,
        x_incl_program_type            => NULL,
        x_incl_program_name            => NULL,
        x_incl_prog_atmpt_stat         => NULL,
        x_incl_prog_atmpt_end          => NULL,
        x_incl_prog_atmpt_strt         => NULL,
        x_incl_req_cmplete             => NULL,
        x_incl_expected_compl_dt       => NULL,
        x_incl_conferral_dt            => NULL,
        x_incl_thesis_title            => NULL,
        x_incl_program_code            => NULL,
        x_incl_program_ver             => NULL,
        x_incl_stud_no                 => NULL,
        x_incl_surname                 => NULL,
        x_incl_fore_name               => NULL,
        x_incl_prev_names              => NULL,
        x_incl_initials                => NULL,
        x_doc_purpose_code             => p_purpose,
        x_plan_id                      => NULL,
        x_produced_by                  => NULL,
        x_person_id                    => l_person_id
      );
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        fnd_file.put_line (fnd_file.LOG, '------------------------------------------------------------------------');
        fnd_file.put_line (fnd_file.LOG, l_msg_data);
        fnd_file.put_line (fnd_file.LOG, '------------------------------------------------------------------------');
        RAISE fnd_api.g_exc_error;
      ELSIF  l_one_item_created = FALSE
             AND l_return_status = fnd_api.g_ret_sts_success THEN
        l_one_item_created := TRUE;
      END IF;
      --If docs are to be produced, create order Interface table item here so that report can pick it up
      INSERT INTO igs_as_ord_itm_int
                  (order_number, person_id, document_type, document_sub_type, item_number, item_status, date_produced,
                   num_of_copies, programs_on_file, comments, recip_pers_name, recip_inst_name, recip_addr_line_1,
                   recip_addr_line_2, recip_addr_line_3, recip_addr_line_4, recip_city,
                   recip_postal_code, recip_state, recip_province, recip_county,
                   recip_country, recip_fax_area_code, recip_fax_country_code, recip_fax_number, delivery_method_type,
                   dup_requested, dup_req_date, dup_sent_date, fgrade_cal_type, fgrade_seq_num, deghold_cal_type,
                   deghold_seq_num, hold_for_grade_chg, hold_degree_expected, hold_release_of_final_grades,
                   incl_curr_course, missing_acad_record_data_ind, missing_academic_record_data,
                   send_transcript_immediately, special_instr, express_mail_type, express_mail_track_num,
                   ge_certification, external_comments, internal_comments, enr_term_cal_type, enr_ci_sequence_number,
                   incl_attempted_hours, incl_class_rank, incl_progresssion_status, incl_class_standing,
                   incl_cum_hours_earned, incl_gpa, incl_date_of_graduation, incl_degree_dates, incl_degree_earned,
                   incl_date_of_entry, incl_drop_withdrawal_dates, incl_hrs_earned_for_curr_term, incl_majors,
                   incl_last_date_of_enrollment, incl_professional_licensure, incl_college_affiliation,
                   incl_instruction_dates, incl_usec_dates, incl_program_attempt, incl_attendence_type,
                   incl_last_term_enrolled, incl_ssn, incl_date_of_birth, incl_disciplin_standing, incl_no_future_term,
                   incl_acurat_till_copmp_dt, incl_cant_rel_without_sign, creation_date, created_by, last_update_date,
                   last_updated_by, last_update_login, request_id, program_id, program_application_id,
                   program_update_date, recip_email)
           VALUES (l_order_number, l_person_id, 'TRANSCRIPT', p_trans_type, l_item_number, 'INPROCESS', NULL,
                   p_num_copies, l_prog_cd, NULL, c_prsn_info_rec.party_name, NULL, c_prsn_info_rec.address1,
                   c_prsn_info_rec.address2, c_prsn_info_rec.address3, c_prsn_info_rec.address4, c_prsn_info_rec.city,
                   c_prsn_info_rec.postal_code, c_prsn_info_rec.state, c_prsn_info_rec.province, c_prsn_info_rec.county,
                   c_prsn_info_rec.country, NULL, NULL, NULL, p_deliv_meth,
                   NULL, NULL, NULL, NULL, NULL, NULL,
                   NULL, NULL, NULL, NULL,
                   NULL, NULL, NULL,
                   NULL, NULL, NULL, NULL,
                   NULL, NULL, NULL, NULL, NULL,
                   NULL, NULL, NULL, NULL,
                   NULL, NULL, NULL, NULL, NULL,
                   NULL, NULL, NULL, NULL,
                   NULL, NULL, NULL,
                   NULL, NULL, NULL, NULL,
                   NULL, NULL, NULL, NULL, NULL,
                   NULL, NULL, SYSDATE, fnd_global.user_id, SYSDATE,
                   fnd_global.user_id, fnd_global.user_id, NULL, NULL, NULL,
                   NULL, c_prsn_info_rec.email_address);
      --End of creation of order and int item
      -- Change the concat string to substr for the bext loop--------
      l_person_ids := SUBSTR (l_person_ids, INSTR (l_person_ids, l_seperator, 1) + 1); -- Person Id string reduced
      l_program_cds := SUBSTR (l_program_cds, INSTR (l_program_cds, l_seperator, 1) + 1); -- Prog Cd string reduced
    END LOOP;
    IF NOT l_one_item_created THEN
      ROLLBACK;
    END IF;
    --Submit job printing report here if docs are also to be produced
    IF  l_one_item_created
        AND p_action_type = 'PRODUCE_DOCS' THEN
      COMMIT; -- Reqd since the report will need the rec in the database
      l_printer_options_ret := fnd_request.set_print_options (
                                 printer                        => p_printer_name,
                                 -- style          => 'PORTRAIT'     ,
                                 copies                         => p_num_copies,
                                 save_output                    => TRUE,
                                 print_together                 => 'N'
                               );
      IF l_oss_country_cd = 'US' THEN
        l_rep_name := 'IGSASP26';
      ELSE
        l_rep_name := 'IGSASP27';
      END IF;
      -- This report now needs to take the order number as parameter
      l_req_id := fnd_request.submit_request (
                    application                    => 'IGS',
                    program                        => l_rep_name,
                    description                    => NULL,
                    start_time                     => NVL (p_schedule_date, SYSDATE),
                    sub_request                    => FALSE,
                    argument1                      => 'N',
                    argument2                      => '',
                    argument3                      => NULL,
                    argument4                      => '',
                    argument5                      => p_deliv_meth,
                    argument6                      => '',
                    argument7                      => '',
                    argument8                      => '',
                    argument9                      => l_order_number, --Order Number
                    argument10                     => NULL -- Concatr string of item number
                  );
      IF NVL (l_req_id, 0) = 0 THEN
        fnd_message.set_name ('IGS', 'IGS_JOB_FAILED');
        fnd_file.put_line (fnd_file.LOG, '------------------------------------------------------------------------');
        fnd_file.put_line (fnd_file.LOG, fnd_message.get);
        fnd_file.put_line (fnd_file.LOG, '------------------------------------------------------------------------');
      END IF;
    END IF;
    -- End of the main loop which loops through the persons for whom the order is to be created ---------
    errbuf := NVL (l_req_id, 0);
    COMMIT;
    -- Initialize API return status to success.
    l_return_status := fnd_api.g_ret_sts_success;
    -- Standard call to get message count and if count is 1, get message
    -- info.
    fnd_msg_pub.count_and_get (p_count => l_msg_count, p_data => l_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK;
      l_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count => l_msg_count, p_data => l_msg_data);
      errbuf := l_msg_data;
      retcode := 1; --l_RETURN_STATUS;
      RETURN;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK;
      l_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count => l_msg_count, p_data => l_msg_data);
      errbuf := l_msg_data;
      retcode := 1; --l_RETURN_STATUS;
      RETURN;
    WHEN OTHERS THEN
      ROLLBACK;
      l_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_message.set_token ('NAME', 'Insert_Row : ' || SQLERRM);
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get (p_count => l_msg_count, p_data => l_msg_data);
      errbuf := l_msg_data;
      retcode := 2; --l_RETURN_STATUS;
      RETURN;
  END bulk_order_job;

  FUNCTION get_latest_yop (p_person_id hz_parties.party_id%TYPE, p_course_cd igs_ps_ver.course_cd%TYPE)
    RETURN VARCHAR2 IS
    CURSOR c_susa IS
      SELECT   susa.unit_set_cd
      FROM     igs_as_su_setatmpt susa
      WHERE    susa.person_id = p_person_id
      AND      susa.course_cd = p_course_cd
      ORDER BY susa.selection_dt DESC;
    l_yop      VARCHAR2 (10);
    c_susa_rec c_susa%ROWTYPE;
  BEGIN
    OPEN c_susa;
    FETCH c_susa INTO c_susa_rec;
    l_yop := c_susa_rec.unit_set_cd;
    CLOSE c_susa;
    RETURN l_yop;
  END get_latest_yop;

  FUNCTION is_order_del_alwd (p_order_number NUMBER)
    RETURN VARCHAR2 IS
    CURSOR c_chk_itm_count IS
      SELECT COUNT (*)
      FROM   igs_as_doc_details
      WHERE  order_number = p_order_number
      AND    item_status = 'PROCESSED';
    l_ret_value VARCHAR2 (1);
    l_count     NUMBER (10);
  BEGIN
    OPEN c_chk_itm_count;
    FETCH c_chk_itm_count INTO l_count;
    CLOSE c_chk_itm_count;
    IF NVL (l_count, 0) > 0 THEN
      RETURN 'N';
    ELSE
      RETURN 'Y';
    END IF;
  END is_order_del_alwd;
END Igs_As_Ss_Doc_Request;

/
