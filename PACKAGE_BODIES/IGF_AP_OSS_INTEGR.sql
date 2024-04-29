--------------------------------------------------------
--  DDL for Package Body IGF_AP_OSS_INTEGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_OSS_INTEGR" AS
/* $Header: IGFAP19B.pls 120.1 2005/09/21 09:34:54 appldev ship $ */


/**********************************************************************************
  Created By : adhawan
  Date Created On : 2001/06/11
  Purpose : This is a Generic Package which is used to provide Certain Student Details
            like
             * Active System Holds
             * Military Service
             * Residency Status
             * Citizenship Status
             * International Visa type
             * Retrive <<Selected Admission Application>> record.

           These details affect the Financial Aid Processing of the Student.

  Know limitations, enhancements or remarks
  Change History
  Bug No: 2154941
  Desc  : Disb Build Jul 2002 (FACCR001 DLD)

  Who             When            What                          --
  cdcruz          17-NOV-2004     Removed procedure GET_PE_RESIDENCY_STAT
                                  as its no longer used
  npalanis        23-OCT-2002     BUG : 2608360
                                  Reference to igs_pe_code_classes changed to igs_lookups
  mesriniv        22-JAN_2002     Added the NVL clauses for check against the
                                  Application Number,Course Code and Version Number
                                  in the cursor for geting addmission appl details

  (reverse chronological order - newest change first)
******************************************************************/

PROCEDURE get_pe_mil_service_type(p_person_id        IN  hz_parties.party_id%TYPE,
                                  p_mil_service_type OUT NOCOPY igs_lookups_view.lookup_code%TYPE,
                                  p_mil_service_desc OUT NOCOPY igs_lookups_view.meaning%TYPE,
                                  p_multiple         OUT NOCOPY VARCHAR2)
IS

 /*************************************************************
  Created By : adhawan
  Date Created On : 2001/06/07
  Purpose :To get the Military Assitance type  that would be considered by the financial Aid
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  CURSOR c_get_mil_service IS
    SELECT  cc.lookup_code        service_type,
            cc.meaning service_desc
      FROM  igs_pe_mil_services ms,
            igs_lookup_values cc
      WHERE  cc.lookup_code = ms.military_type_cd
      AND cc.lookup_type = 'PE_MIL_SEV_TYPE'
      AND    ms.person_id       = p_person_id
      ORDER BY ms.milit_service_id;
  l_get_mil_service_rec   c_get_mil_service%ROWTYPE;

BEGIN

  OPEN  c_get_mil_service;
  FETCH c_get_mil_service INTO p_mil_service_type, p_mil_service_desc;

  -- If Multiple records exists, then need to return "Y" for p_multiple.
  FETCH c_get_mil_service INTO l_get_mil_service_rec;
  IF c_get_mil_service%NOTFOUND THEN
        p_multiple := 'N';
  ELSE
        p_multiple := 'Y';
  END IF;

  CLOSE c_get_mil_service;

END get_pe_mil_service_type;



PROCEDURE get_pe_active_holds(p_person_id    IN  hz_parties.party_id%TYPE,
                              p_encumb_type  OUT NOCOPY VARCHAR2,
                              p_encumb_desc  OUT NOCOPY VARCHAR2,
                              p_multiple     OUT NOCOPY VARCHAR2)
IS

 /*************************************************************
  Created By : adhawan
  Date Created On : 2001/06/07
  Purpose :To get the active holds that would be considered by the financial Aid
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  CURSOR c_get_holds IS
  SELECT holdtyp.encumbrance_type encumbrance_type,
         b.description  dsp_description
    FROM  igs_pe_pers_encumb   holdtyp,igs_fi_encmb_type b, igs_pe_persenc_effct       holdefft
   WHERE holdtyp.person_id        = p_person_id
     AND b.encumbrance_type = holdtyp.encumbrance_type
     AND holdtyp.start_dt        <= TRUNC(SYSDATE)
     AND (    holdtyp.expiry_dt  >= TRUNC(SYSDATE)
      OR holdtyp.expiry_dt IS NULL)
     AND holdtyp.person_id        = holdefft.person_id
     AND holdtyp.encumbrance_type = holdefft.encumbrance_type
     AND holdefft.s_encmb_effect_type IN
         ('GRAD_BLK',  'RESULT_BLK','RSTR_AT_TY', 'RSTR_GE_CP','RSTR_LE_CP','RVK_SRVC',  'SUS_COURSE', 'SUS_SRVC',  'DENY_EACT');

  l_get_holds_rec   c_get_holds%ROWTYPE;

BEGIN

  OPEN  c_get_holds;
  FETCH c_get_holds INTO p_encumb_type, p_encumb_desc;

  -- If Multiple records exists, then need to return "Y" for p_multiple.
  FETCH c_get_holds INTO l_get_holds_rec;
  IF c_get_holds%NOTFOUND THEN
        p_multiple := 'N';
  ELSE
        p_multiple := 'Y';
  END IF;

  CLOSE c_get_holds;

END get_pe_active_holds;



PROCEDURE get_pe_visa_type(p_person_id  IN  hz_parties.party_id%TYPE,
                           p_visa_type  OUT NOCOPY igs_pe_visa.visa_type%TYPE,
                           p_visa_desc  OUT NOCOPY fnd_lookup_values.meaning%TYPE,
                           p_multiple   OUT NOCOPY VARCHAR2)
IS

 /*************************************************************
  Created By : adhawan
  Date Created On : 2001/06/07
  Purpose :To get the visa details  that would be considered by the financial Aid
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  CURSOR c_get_visa_type IS
  SELECT a.visa_type,
         b.meaning visa_description
  FROM   igs_pe_visa a , fnd_lookup_values b
  WHERE  a.person_id = p_person_id
  AND    b.view_application_id = 3
  AND    b.lookup_type = 'PER_US_VISA_TYPES'
  AND    a.visa_type = b.lookup_code;

  l_get_visa_type_rec  c_get_visa_type%ROWTYPE;

BEGIN

  OPEN  c_get_visa_type;
  FETCH c_get_visa_type INTO p_visa_type, p_visa_desc;

  -- If Multiple records exists, then need to return "Y" for p_multiple.
  FETCH c_get_visa_type INTO l_get_visa_type_rec;
  IF c_get_visa_type%NOTFOUND THEN
        p_multiple := 'N';
  ELSE
        p_multiple := 'Y';
  END IF;

  CLOSE c_get_visa_type;

END get_pe_visa_type;



PROCEDURE get_pe_citizenship_stat(p_person_id        IN  hz_parties.party_id%TYPE,
                                  p_citizenship_stat OUT NOCOPY igs_Lookups_view.lookup_code%TYPE,
                                  p_citizenship_desc OUT NOCOPY igs_lookups_view.meaning%TYPE)
IS

 /*************************************************************
  Created By : adhawan
  Date Created On : 2001/06/07
  Purpose :To get the citizenship status details that would be considered by the financial Aid
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  CURSOR c_get_citizen_stat IS
  SELECT * FROM igs_pe_eit_restatus_v
  WHERE person_id = p_person_id
  AND (
  (TRUNC(SYSDATE) BETWEEN TRUNC(start_date) AND TRUNC(end_date))
  OR (start_date IS NULL) OR (end_date IS NULL)
  );

  l_get_citizen_stat_rec   c_get_citizen_stat%ROWTYPE;

BEGIN

  OPEN  c_get_citizen_stat;
  FETCH c_get_citizen_stat INTO l_get_citizen_stat_rec;
  CLOSE c_get_citizen_stat;

 p_citizenship_stat := l_get_citizen_stat_Rec.restatus_code;
 p_citizenship_desc := l_get_citizen_stat_Rec.description;

END get_pe_citizenship_stat;






PROCEDURE get_acad_cal_from_awd(p_awd_cal_type  IN  igs_ca_inst_all.cal_type%TYPE,
                                p_awd_seq_num   IN  igs_ca_inst_all.sequence_number%TYPE,
                                p_acad_cal_type OUT NOCOPY igs_ca_inst_all.cal_type%TYPE,
                                p_acad_seq_num  OUT NOCOPY igs_ca_inst_all.sequence_number%TYPE,
                                p_acad_alt_code OUT NOCOPY igs_ca_inst_all.alternate_code%TYPE)
IS

 /*************************************************************
  Created By : adhawan
  Date Created On : 2001/06/07
  Purpose :To get the ACADEMIC CALENDAR associated with the AWARD CALENDAR.

  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  skoppula        2002/07/09      FACR09
  (reverse chronological order - newest change first)
  ***************************************************************/
l_acad_cal_type                igs_ca_inst.cal_type%TYPE;
l_acad_sequence                igs_ca_inst.sequence_number%TYPE;

  CURSOR c_get_acad_cal IS
    SELECT  ci.cal_type cal_type,
            ci.sequence_number sequence_number,
      ci.alternate_code  alternate_code
            FROM  igs_ca_inst  ci
            WHERE ci.cal_type      = l_acad_cal_type
            AND   ci.sequence_number  = l_acad_sequence;

l_adm_cal_type                 igs_ca_inst.cal_type%TYPE;
l_adm_sequence                 igs_ca_inst.sequence_number%TYPE;
l_adm_alternate_cd             igs_ca_inst.alternate_code%TYPE;
l_message                      VARCHAR2(2000);

BEGIN

  igs_ad_gen_008.get_acad_cal(l_adm_cal_type,
                              l_adm_sequence,
            l_acad_cal_type,
            l_acad_sequence,
            l_adm_alternate_cd,
            l_message);
  OPEN c_get_acad_cal;
  FETCH c_get_acad_cal INTO
      p_acad_cal_type, p_acad_seq_num, p_acad_alt_code;
  CLOSE c_get_acad_cal;

END get_acad_cal_from_awd;


PROCEDURE get_awd_cal_from_acad(p_acad_cal_type IN  igs_ca_inst_all.cal_type%TYPE,
                                p_acad_seq_num  IN  igs_ca_inst_all.sequence_number%TYPE,
                                p_awd_cal_type  OUT NOCOPY igs_ca_inst_all.cal_type%TYPE,
                                p_awd_seq_num   OUT NOCOPY igs_ca_inst_all.sequence_number%TYPE,
                                p_awd_alt_code  OUT NOCOPY igs_ca_inst_all.alternate_code%TYPE)
IS

 /*************************************************************
  Created By : adhawan
  Date Created On : 2001/06/07
  Purpose :To get the AWARD CALENDAR associated with the ACADEMIC CALENDAR.

  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  skoppula        2002/07/09      This shall return the latest award
                                  year without reference to the acad year
          in context. This is modified as per
          FACR09. This procedure shall be modified
          in future releases ,once the method
          to establish the relation ship
          between the acad and award years is defined
  (reverse chronological order - newest change first)
  ***************************************************************/

  CURSOR c_get_awd_cal IS
    SELECT  ci.cal_type   cal_type,
            ci.sequence_number sequence_number,
            ci.alternate_code  alternate_code
            FROM  igs_ca_inst ci,
            igs_ca_type ct,
            igs_ca_stat st
            WHERE ct.s_cal_cat         =  'AWARD'
      AND   ct.cal_type          =   ci.cal_type
      AND   ci.cal_status        =   st.cal_status
      AND   st.s_cal_status        =   'ACTIVE'
      AND   TRUNC(ci.start_dt)   <   TRUNC(SYSDATE)
      AND   (
            ci.end_dt IS NULL
      OR TRUNC(ci.end_dt) > TRUNC(SYSDATE)
      )
            ORDER BY ci.start_dt,ci.sequence_number DESC;
BEGIN

  OPEN  c_get_awd_cal;
  FETCH c_get_awd_cal INTO
      p_awd_cal_type, p_awd_seq_num, p_awd_alt_code;
  CLOSE c_get_awd_cal;

END get_awd_cal_from_acad;




PROCEDURE get_adm_appl_details( p_person_id                 IN      hz_parties.party_id%TYPE,
                                p_awd_cal_type              IN      igs_ca_inst_all.cal_type%TYPE,
                                p_awd_seq_num               IN      igs_ca_inst_all.sequence_number%TYPE,
                                p_ad_appl_row_id            OUT NOCOPY     ROWID,
                                p_ad_prog_appl_row_id       OUT NOCOPY     ROWID,
                                p_adm_appl_number           IN OUT NOCOPY  igs_ad_appl_all.admission_appl_number%TYPE,
                                p_course_cd                 IN OUT NOCOPY  igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE,
                                p_crv_version_number        IN OUT NOCOPY  igs_ad_ps_appl_inst_all.sequence_number%TYPE,
                                p_adm_offer_resp_stat       OUT NOCOPY     igs_ad_ps_appl_inst_all.adm_offer_resp_status%TYPE,
                                p_adm_outcome_stat          OUT NOCOPY     igs_ad_ps_appl_inst_all.adm_outcome_status%TYPE,
                                p_adm_appl_status           OUT NOCOPY     igs_ad_appl_all.adm_appl_status%TYPE,
                                p_multiple                  OUT NOCOPY     VARCHAR2   )
IS

 /*************************************************************
  Created By : adhawan
  Date Created On : 2001/06/07
  Purpose : To get the Selected Admission Application Record for a Person.
            Note - there can be more than 1 admission application record in OSS for
            an Academic Calender Instance.

  Know limitations, enhancements or remarks
  Change History:
   --Bug No:2296776
  Who             When            What
  sjalasut       16 Nov 03        FA126. Corrected the cursor c_get_adm_appl as the req is to
                                  return "Y" for multiple application instances and not multiple
                                  applications. changed the underlying table in the cursor
                                  from igs_ap_appl
  skoppula       10-APR-2002      Corrected the where clause of the the Cursor get_Adm_appl_details
                                  so that adm_appl_status and other statuses in adm_appl table
          are correctly mapped to the corresponding user defined statuses
  --Bug No:2154941 Desc : Disbursement Build Jul 2002
  Who             When            What
    mesriniv       22-JAN-2002      Added the NVL clauses for check against the Application Number,Course Code and Version Number
                                  as per the FACCR001 DLD

  (reverse chronological order - newest change first)
  ***************************************************************/

  lv_cal_type         igs_ca_inst.cal_type%TYPE         DEFAULT NULL;
  lv_sequence_number  igs_ca_inst.sequence_number%TYPE  DEFAULT NULL;
  lv_alt_code         igs_ca_inst.alternate_code%TYPE   DEFAULT NULL;

  lv_person_id        hz_parties.party_id%TYPE;
  lv_appl_sel_order   VARCHAR2(30);

  --Bug No:2154941 Desc : Disbursement Build Jul 2002
  --Added the NVL clauses for check against the Application Number,Course Code and Version Number
  --as per the FACCR001 DLD

  CURSOR c_get_adm_appl_details(p_person_id          hz_parties.party_id%TYPE,
                                c_cal_type           igs_ca_inst_all.cal_type%TYPE ,
                                c_sequence_number    igs_ca_inst_all.sequence_number%TYPE,
                                p_adm_appl_number    igs_ad_appl_all.admission_appl_number%TYPE,
                                p_course_cd          igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE,
                                p_crv_version_number igs_ad_ps_appl_inst_all.crv_version_number%TYPE) IS
    SELECT   aav.row_id   appl_inst_row_id,
             acai.row_id  appl_prog_inst_row_id,
             aav.person_id,
             aav.admission_appl_number,
             acai.course_cd,
             acai.crv_version_number,
             DECODE(rpstat.s_adm_offer_resp_status,'ACCEPTED',1, 'PENDING',2,'DEFERRAL',3,
                DECODE(oustat.s_adm_outcome_status,'OFFER',   5,'COND-OFFER',6,'PENDING',7,
                                                   'NO-QUOTA',8,'REJECTED',  8,'VOIDED', 8, 'WITHDRAWN',8,
                   DECODE(apstat.s_adm_appl_status,'COMPLETED',9,'RECEIVED',10,'WITHDRAWN',11,23)))   appl_selection_order,
             acai.adm_offer_resp_status,
             acai.adm_outcome_status,
             aav.adm_appl_status
    FROM IGS_AD_APPL     aav,
         IGS_AD_PS_APPL_INST  acai,
         IGS_PS_VER           crv,
         IGS_AD_APPL_STAT     apstat,
         IGS_AD_OU_STAT       oustat,
         IGS_AD_OFR_RESP_STAT rpstat
    WHERE aav.person_id = acai.person_id (+)
    AND   aav.admission_appl_number = acai.admission_appl_number(+)
    AND   aav.person_id               = p_person_id
    /*AND   aav.acad_cal_type           = c_cal_type
    AND   aav.acad_ci_sequence_number = c_sequence_number*/ -- Commented as per bug 2296776
    AND  aav.admission_appl_number =NVL(p_adm_appl_number,aav.admission_appl_number)
    AND  acai.course_cd            =NVL(p_course_cd,acai.course_cd)
    AND  acai.crv_version_number   =NVL(p_crv_version_number,acai.crv_version_number)
    AND   acai.course_cd              = crv.course_cd(+)
    AND   acai.crv_version_number     = crv.version_number(+)
    AND   (crv.federal_financial_aid       = 'Y'
           OR
           crv.state_financial_aid         = 'Y'
           OR
           crv.institutional_financial_aid = 'Y' )
    AND   acai.adm_offer_resp_status    = rpstat.adm_offer_resp_status(+)
    AND   acai.adm_outcome_status       = oustat.adm_outcome_status(+)
    AND   aav.adm_appl_status           = apstat.adm_appl_status
    ORDER BY 7, 4;

  l_get_adm_appl_details_rec    c_get_adm_appl_details%ROWTYPE;

  CURSOR c_get_adm_appl IS SELECT COUNT(*) cnt FROM igs_ad_ps_appl_inst WHERE
         person_id = p_person_id;
  l_adm_appl_cnt_rec c_get_adm_appl%ROWTYPE;
BEGIN

  -- Get the Academic Calender Instance for the given Award Year.

 -- get_acad_cal_from_awd(p_awd_cal_type, p_awd_seq_num, lv_cal_type, lv_sequence_number, lv_alt_code);

  -- Get the <<Selected Admission Application>> record for the given Person and Academic Calender.
  -- NOTE : THE ENTIRE BELOW LOGIC IS TAKEN CARE IN THE CURSOR ITSELF.

  -- Note : Only the programs which are eligible for Federal/State/Institutional Aid are selected
  -- Criteria for retreiving the <<Selected Admission Application>> Record :
  -- 1. Select the Appl with Offer Response Status as ACCEPTED.
  -- 2. If more than 1 exists, then select the first one.
  -- 3. Else, select the appl with Offer Response Status as PENDING
  -- 4. If more than 1 exists, then select the first one.
  -- 5. Else, select the appl with Offer Response Status as DEFERRAL
  -- 6. If more than 1 exists, then select the first one.
  -- 7. Else, select the appl with adm outcome status as OFFER, COND-OFFER, PENDING, NO-QUOTA,
  --                                                     REJECTED, VOIDED, WITHDRAWN,
  --    in that order.
  --    Note : every status value to be considered once, as done for "Offer Response Status".
  -- 8. If more than 1 exists, then select the first one.
  -- 9. Else, If select the Appl record with Admission Appl Status as COMPLETED,
  --                                                RECEIVED, WITHDRAWN,
  --    in that order.
  -- 10. If more than 1 exists, select the first one.


  --Modified call to open cursor(added last three parameters) here as per the FACCR001 Disbursement Build Jul 2002
  --Bug 2154941 Disbursement Build
    -------------------------------------------------------



  OPEN c_get_adm_appl_details(p_person_id, lv_cal_type, lv_sequence_number,p_adm_appl_number,p_course_cd,
                              p_crv_version_number) ;
  FETCH c_get_adm_appl_details INTO
        p_ad_appl_row_id, p_ad_prog_appl_row_id, lv_person_id,
        p_adm_appl_number, p_course_cd, p_crv_version_number, lv_appl_sel_order,
        p_adm_offer_resp_stat, p_adm_outcome_stat, p_adm_appl_status;

  -- If Multiple records exists, then need to return "Y" for p_multiple.
--  FETCH c_get_adm_appl_details INTO l_get_adm_appl_details_rec;
  CLOSE c_get_adm_appl_details;

  OPEN c_get_adm_appl;
  FETCH c_get_adm_appl INTO l_adm_appl_cnt_rec;
  IF NVL(l_adm_appl_cnt_rec.cnt,0) > 1 THEN
        p_multiple            := 'Y';
  ELSE
        p_multiple            := 'N';
  END IF;
  CLOSE c_get_adm_appl;

END get_adm_appl_details;

FUNCTION get_adm_appl_val(p_person_id    IN hz_parties.party_id%TYPE,
                          p_awd_cal_type IN igs_ca_inst_all.cal_type%TYPE,
                          p_awd_seq_num  IN igs_ca_inst_all.sequence_number%TYPE)
RETURN ROWID
IS

/*************************************************************
  Created By : adhawan
  Date Created On : 2001/06/07
  Purpose :This is provided to get the rowid for igs_ad_appl table in the Selected Applicaition Record
  which inturn is based on the Academic calendar corresponding to the Award Calendar being passed(last two parameters)
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

        -- The OUT NOCOPY parameter variable to capture the values returned from the get_adm_appl_details procedure.
        lv_ad_appl_row_id      ROWID;
        lv_ad_prog_appl_row_id ROWID;
        lv_adm_appl_number     igs_ad_appl_all.admission_appl_number%TYPE;
        lv_course_cd           igs_ad_ps_appl_inst_all.course_cd%TYPE;
        lv_crv_version_number  igs_ad_ps_appl_inst_all.crv_version_number%TYPE;
        lv_adm_offer_resp_stat igs_ad_ofr_resp_stat.adm_offer_resp_status%TYPE;
        lv_adm_outcome_stat    igs_ad_ou_stat.adm_outcome_status%TYPE;
        lv_adm_appl_status     igs_ad_appl_all.adm_appl_status%TYPE;
        lv_multiple            VARCHAR2(10) ;
BEGIN

  get_adm_appl_details(p_person_id ,
                       p_awd_cal_type ,
                       p_awd_seq_num ,
                       lv_ad_appl_row_id,
                       lv_ad_prog_appl_row_id,
                       lv_adm_appl_number,
                       lv_course_cd,
                       lv_crv_version_number,
                       lv_adm_offer_resp_stat,
                       lv_adm_outcome_stat,
                       lv_adm_appl_status,
                       lv_multiple);

  return lv_ad_appl_row_id;

END get_adm_appl_val;




FUNCTION get_adm_prog_appl_val(p_person_id    IN hz_parties.party_id%TYPE,
                               p_awd_cal_type IN igs_ca_inst_all.cal_type%TYPE,
                               p_awd_seq_num  IN igs_ca_inst_all.sequence_number%TYPE)
RETURN ROWID
IS

/*************************************************************
  Created By : adhawan
  Date Created On : 2001/06/07
  Purpose :This is provided to get the rowid for igs_ad_ps_appl_inst table in the Selected Applicaition Record
  which inturn is based on the Academic calendar corresponding to the Award Calendar being passed(last two parameters)
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

        -- The OUT NOCOPY parameter variable to capture the values returned from the get_adm_appl_details procedure.
        lv_ad_appl_row_id      ROWID;
        lv_ad_prog_appl_row_id ROWID;
        lv_adm_appl_number     igs_ad_appl_all.admission_appl_number%TYPE;
        lv_course_cd           igs_ad_ps_appl_inst_all.course_cd%TYPE;
        lv_crv_version_number  igs_ad_ps_appl_inst_all.crv_version_number%TYPE;
        lv_adm_offer_resp_stat igs_ad_ofr_resp_stat.adm_offer_resp_status%TYPE;
        lv_adm_outcome_stat    igs_ad_ou_stat.adm_outcome_status%TYPE;
        lv_adm_appl_status     igs_ad_appl_all.adm_appl_status%TYPE;
        lv_multiple            VARCHAR2(10) ;
BEGIN

  get_adm_appl_details(p_person_id ,
                       p_awd_cal_type ,
                       p_awd_seq_num ,
                       lv_ad_appl_row_id,
                       lv_ad_prog_appl_row_id,
                       lv_adm_appl_number,
                       lv_course_cd,
                       lv_crv_version_number,
                       lv_adm_offer_resp_stat,
                       lv_adm_outcome_stat,
                       lv_adm_appl_status,
                       lv_multiple);
  return lv_ad_prog_appl_row_id;

END get_adm_prog_appl_val;


END igf_ap_oss_integr;

/
