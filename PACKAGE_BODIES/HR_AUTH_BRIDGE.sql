--------------------------------------------------------
--  DDL for Package Body HR_AUTH_BRIDGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_AUTH_BRIDGE" as
/* $Header: hrathbrd.pkb 115.1 2002/05/29 05:42:14 pkm ship       $ */


FUNCTION get_coverage
  (
  p_prtt_enrt_rslt_id in number,
  p_per_in_ler_id     in number,
  p_acty_typ_cd       in varchar2,
  p_type              in varchar2
  )
  RETURN varchar2 IS
--
    CURSOR c_ee_contrib IS
    SELECT prv.cmcd_rt_val ||' '||
           HR_GENERAL.DECODE_LOOKUP('BEN_ENRT_INFO_RT_FREQ',
                                     prv.cmcd_ref_perd_cd)
    FROM   ben_prtt_rt_val prv
    WHERE  prv.prtt_enrt_rslt_id  = p_prtt_enrt_rslt_id
    AND    prv.per_in_ler_id      = p_per_in_ler_id
    AND    prv.acty_typ_cd        = p_acty_typ_cd
    AND    prv.prtt_rt_val_stat_cd IS NULL
    AND    prv.dsply_on_enrt_flag = 'Y';

    CURSOR c_er_contrib IS
    SELECT prv.cmcd_rt_val ||' '||
           HR_GENERAL.DECODE_LOOKUP('BEN_ENRT_INFO_RT_FREQ',
                                     prv.cmcd_ref_perd_cd)
    FROM   ben_prtt_rt_val prv
    WHERE  prv.prtt_enrt_rslt_id  = p_prtt_enrt_rslt_id
    AND    prv.per_in_ler_id      = p_per_in_ler_id
    AND    prv.acty_typ_cd        = p_acty_typ_cd
    AND    prv.prtt_rt_val_stat_cd IS NULL;

    l_ret_val varchar2(200);
--
BEGIN
--
    IF p_type = 'EE' THEN
      OPEN c_ee_contrib;
      FETCH c_ee_contrib INTO  l_ret_val;
      CLOSE c_ee_contrib;
    ELSIF p_type = 'ER' THEN
      OPEN c_er_contrib;
      FETCH c_er_contrib INTO  l_ret_val;
      CLOSE c_er_contrib;
    END IF;
    RETURN (l_ret_val);
--
END get_coverage;
--

FUNCTION get_beneficiaries
  (
  p_prtt_enrt_rslt_id in number,
  p_per_in_ler_id     in number,
  p_prmry_cntngnt_cd  in varchar2
  )
  RETURN varchar2 IS
--

  l_ret_val varchar2(1500);
--
BEGIN
--
     l_ret_val := get_beneficiaries(p_prtt_enrt_rslt_id,
                                    p_per_in_ler_id,
                                    p_prmry_cntngnt_cd,
                                    TRUNC(SYSDATE));

     RETURN (l_ret_val);
--
END;
--

FUNCTION get_beneficiaries
  (
  p_prtt_enrt_rslt_id in number,
  p_per_in_ler_id     in number,
  p_prmry_cntngnt_cd  in varchar2,
  p_effective_date    in date
  )
  RETURN varchar2 IS
--
    CURSOR c_bnf IS
    SELECT ppf.full_name ||' '||
           DECODE(pbn.pct_dsgd_num,NULL,TO_CHAR(pbn.amt_dsgd_val),TO_CHAR(pbn.pct_dsgd_num)||'%') beneficiary
    FROM   ben_pl_bnf_f pbn,
           per_all_people_f ppf
    WHERE  pbn.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    AND    pbn.per_in_ler_id     = p_per_in_ler_id
    AND    p_effective_date BETWEEN pbn.effective_start_date AND pbn.effective_end_date
    AND    pbn.prmry_cntngnt_cd  = p_prmry_cntngnt_cd
    AND    pbn.bnf_person_id     = ppf.person_id
    AND    p_effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date;

    l_ret_val varchar2(1500);
--
BEGIN
--
     FOR r_bnf IN c_bnf LOOP
       IF l_ret_val IS NULL THEN
         l_ret_val :=  r_bnf.beneficiary;
       ELSE
         l_ret_val := l_ret_val ||', '|| r_bnf.beneficiary;
       END IF;
     END LOOP;

     RETURN l_ret_val;
--
END;
--

FUNCTION get_primary_care_providers
  (
  p_prtt_enrt_rslt_id in number,
  p_business_group_id in number
  )
  RETURN varchar2 IS
--

  l_ret_val varchar2(1500);
--
BEGIN
--
     l_ret_val := get_primary_care_providers(p_prtt_enrt_rslt_id,
                                             p_business_group_id,
                                             TRUNC(SYSDATE));

     RETURN (l_ret_val);
--
END;
--

FUNCTION get_primary_care_providers
  (
   p_prtt_enrt_rslt_id in number,
   p_business_group_id in number,
   p_effective_date    in date
  )
  RETURN varchar2 IS
--

    CURSOR c_pcp IS
    SELECT pcp.name ||' '||
           HR_GENERAL.DECODE_LOOKUP('BEN_PRMRY_CARE_PRVDR_TYP',pcp.prmry_care_prvdr_typ_cd) primary_care_provider
    FROM   ben_prmry_care_prvdr_f pcp
    WHERE  pcp.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
    AND    pcp.business_group_id = p_business_group_id
    AND    p_effective_date BETWEEN pcp.effective_start_date AND pcp.effective_end_date;

   l_ret_val varchar2(1500);
--
BEGIN
--
   FOR r_pcp IN c_pcp LOOP
     IF l_ret_val IS NULL THEN
       l_ret_val :=  r_pcp.primary_care_provider;
     ELSE
       l_ret_val := l_ret_val ||', '|| r_pcp.primary_care_provider;
     END IF;
   END LOOP;

   RETURN (l_ret_val);
--
END;
--

FUNCTION get_interim_flag
  (
   p_prtt_enrt_rslt_id in number,
   p_business_group_id in number
  )
  RETURN varchar2 IS
--

  l_ret_val varchar2(100);
--
BEGIN
--
     l_ret_val := get_interim_flag(p_prtt_enrt_rslt_id,
                                   p_business_group_id,
                                   TRUNC(SYSDATE));

     RETURN (l_ret_val);
--
END;
--

FUNCTION get_interim_flag
  (
   p_prtt_enrt_rslt_id in number,
   p_business_group_id in number,
   p_effective_date in date
  )
  RETURN varchar2 IS
--
      CURSOR c_interim IS
      SELECT rplcs_sspndd_rslt_id
      FROM   ben_prtt_enrt_rslt_f pen
      WHERE  pen.rplcs_sspndd_rslt_id = p_prtt_enrt_rslt_id
      AND    pen.business_group_id    = p_business_group_id
      AND    p_effective_date BETWEEN pen.effective_start_date AND pen.effective_end_date;

     l_rplcs_sspndd_rslt_id ben_prtt_enrt_rslt_f.rplcs_sspndd_rslt_id%type;
     l_ret_val              varchar2(100);
--
BEGIN
--
       OPEN c_interim;
       FETCH c_interim INTO l_rplcs_sspndd_rslt_id;
       CLOSE c_interim;
       IF l_rplcs_sspndd_rslt_id IS NOT NULL THEN
         l_ret_val := FND_MESSAGE.GET_STRING('BEN','BEN_93047_INTERIM_PLAN');
       END IF;

       RETURN (l_ret_val);
--
END get_interim_flag;
--

FUNCTION get_contact_relationships
  (
   p_person_id         in number,
   p_contact_person_id in number
  )
  RETURN varchar2 IS
--

  l_ret_val varchar2(1500);
--
BEGIN
--
     l_ret_val := get_contact_relationships(p_person_id,
                                            p_contact_person_id,
                                            TRUNC(SYSDATE));

     RETURN (l_ret_val);
--
END;
--

FUNCTION get_contact_relationships
  (
   p_person_id         in number,
   p_contact_person_id in number,
   p_effective_date    in date
  )
  RETURN varchar2 IS
--

     CURSOR c_contacts IS
     SELECT HR_GENERAL.DECODE_LOOKUP('CONTACT',pcr.contact_type) contact_type
     FROM   per_contact_relationships pcr
     WHERE  pcr.person_id         = p_person_id
     AND    pcr.contact_person_id = p_contact_person_id
     AND    p_effective_date BETWEEN NVL(pcr.date_start,p_effective_date) AND NVL(pcr.date_end,p_effective_date)
     ORDER BY DECODE(pcr.personal_flag,'Y',1),pcr.contact_type;

     l_ret_val varchar2(1500);
--
BEGIN
--
   FOR r_contacts IN c_contacts LOOP
     IF l_ret_val IS NULL THEN
       l_ret_val :=  r_contacts.contact_type;
     ELSE
       l_ret_val := l_ret_val ||', '|| r_contacts.contact_type;
     END IF;
   END LOOP;

   RETURN (l_ret_val);
--
END;
--

FUNCTION get_proposed_salary
  (
   p_assignment_id     in number
  )
  RETURN varchar2 IS
--

  l_ret_val varchar2(50);
--
BEGIN
--
     l_ret_val := get_proposed_salary(p_assignment_id,
                                      TRUNC(SYSDATE));

     RETURN (l_ret_val);
--
END;
--

FUNCTION get_proposed_salary
  (
   p_assignment_id     in number,
   p_effective_date    in date
  )
  RETURN varchar2 IS
--

     CURSOR c_salary IS
     SELECT TO_CHAR(ppp.proposed_salary_n)
     FROM   per_pay_proposals ppp
     WHERE  ppp.pay_proposal_id = (SELECT MAX(ppp1.pay_proposal_id)
                                   FROM   per_pay_proposals ppp1
                                   WHERE  ppp1.assignment_id = p_assignment_id
                                   AND    ppp1.approved = 'Y'
                                   AND    ppp1.change_date <= p_effective_date);

     l_ret_val varchar2(50);
--
BEGIN
--
   OPEN c_salary;
   FETCH c_salary INTO l_ret_val;
   CLOSE c_salary;

   RETURN (l_ret_val);
--
END;
--

FUNCTION get_salary_change_date
  (
   p_assignment_id     in number
  )
  RETURN varchar2 IS
--

  l_ret_val varchar2(20);
--
BEGIN
--
     l_ret_val := get_salary_change_date(p_assignment_id,
                                         TRUNC(SYSDATE));

     RETURN (l_ret_val);
--
END;
--

FUNCTION get_salary_change_date
  (
   p_assignment_id     in number,
   p_effective_date    in date
  )
  RETURN varchar2 IS
--

     CURSOR c_change_dt IS
     SELECT TO_CHAR(ppp.change_date,'MM/DD/YYYY')
     FROM   per_pay_proposals ppp
     WHERE  ppp.pay_proposal_id = (SELECT MAX(ppp1.pay_proposal_id)
                                   FROM   per_pay_proposals ppp1
                                   WHERE  ppp1.assignment_id = p_assignment_id
                                   AND    ppp1.approved = 'Y'
                                   AND    ppp1.change_date <= p_effective_date);

     l_ret_val varchar2(20);
--
BEGIN
--
   OPEN c_change_dt;
   FETCH c_change_dt INTO  l_ret_val;
   CLOSE c_change_dt;

   RETURN (l_ret_val);
--
END;
--

FUNCTION get_performance_rating
  (
   p_person_id     in number
  )
  RETURN varchar2 IS
--

  l_ret_val varchar2(50);
--
BEGIN
--
     l_ret_val := get_performance_rating(p_person_id,
                                         TRUNC(SYSDATE));

     RETURN (l_ret_val);
--
END;
--

FUNCTION get_performance_rating
  (
   p_person_id         in number,
   p_effective_date    in date
  )
  RETURN varchar2 IS
--

     CURSOR c_rating IS
     SELECT ppr.performance_rating
     FROM   per_performance_reviews ppr
     WHERE  ppr.performance_review_id = (SELECT MAX(ppr1.performance_review_id)
                                         FROM   per_performance_reviews ppr1
                                         WHERE  ppr1.person_id = p_person_id
                                         AND    ppr1.review_date <= p_effective_date);

     l_ret_val per_performance_reviews.performance_rating%type;
--
BEGIN
--
   OPEN c_rating;
   FETCH c_rating INTO l_ret_val;
   CLOSE c_rating;

   RETURN (l_ret_val);
--
END;
--

FUNCTION get_person_start_date
  (
   p_person_id                in number,
   p_period_of_service_id     in number,
   p_paf_effective_start_date in date,
   p_assignment_type          in varchar2
  )
  RETURN date IS
--

  l_ret_val date;
--
BEGIN
--
     l_ret_val := get_person_start_date(p_person_id,
                                        p_period_of_service_id,
                                        p_paf_effective_start_date,
                                        p_assignment_type,
                                        TRUNC(SYSDATE));

     RETURN (l_ret_val);
--
END;
--

FUNCTION get_person_start_date
  (
   p_person_id                 in number,
   p_period_of_service_id      in number,
   p_paf_effective_start_date  in date,
   p_assignment_type           in varchar2,
   p_effective_date            in date
  )
  RETURN date IS
--

    CURSOR c_pps_start_dt IS
    SELECT pps.date_start
    FROM   per_periods_of_service pps
    WHERE  pps.period_of_service_id = p_period_of_service_id
    AND    pps.person_id = p_person_id;

     l_ret_val date;
--
BEGIN
--
   IF p_assignment_type = 'B' THEN
     l_ret_val := p_paf_effective_start_date;
   ELSIF p_assignment_type = 'E' THEN
     OPEN c_pps_start_dt;
     FETCH c_pps_start_dt INTO l_ret_val;
     CLOSE c_pps_start_dt;
   END IF;

   RETURN (l_ret_val);
--
END;
--

FUNCTION get_person_end_date
  (
   p_person_id              in number,
   p_period_of_service_id   in number,
   p_paf_effective_end_date in date,
   p_assignment_type        in varchar2
  )
  RETURN date IS
--

  l_ret_val date;
--
BEGIN
--
     l_ret_val := get_person_end_date(p_person_id,
                                      p_period_of_service_id,
                                      p_paf_effective_end_date,
                                      p_assignment_type,
                                      TRUNC(SYSDATE));

     RETURN (l_ret_val);
--
END;
--

FUNCTION get_person_end_date
  (
   p_person_id                 in number,
   p_period_of_service_id      in number,
   p_paf_effective_end_date    in date,
   p_assignment_type           in varchar2,
   p_effective_date            in date
  )
  RETURN date IS
--

     CURSOR c_pps_end_dt IS
     SELECT NVL(pps.actual_termination_date,TO_DATE('12/31/4712','MM/DD/YYYY'))
     FROM   per_periods_of_service pps
     WHERE  pps.period_of_service_id = p_period_of_service_id
     AND    pps.person_id = p_person_id;

     l_ret_val date;
--
BEGIN
--
   IF p_assignment_type = 'B' THEN
     l_ret_val := p_paf_effective_end_date;
   ELSIF p_assignment_type = 'E' THEN
     OPEN c_pps_end_dt;
     FETCH c_pps_end_dt INTO l_ret_val;
     CLOSE c_pps_end_dt;
   END IF;

   RETURN (l_ret_val);
--
END;
--

FUNCTION get_per_system_status
  (
   p_assignment_status_type_id in number
  )
  RETURN varchar2 IS
--

     CURSOR c_per_system_status IS
     SELECT pas.per_system_status
     FROM   per_assignment_status_types pas
     WHERE  pas.assignment_status_type_id = p_assignment_status_type_id;

     l_ret_val per_assignment_status_types.per_system_status%type;
--
BEGIN
--
     OPEN c_per_system_status;
     FETCH c_per_system_status INTO l_ret_val;
     CLOSE c_per_system_status;

     RETURN (l_ret_val);
--
END;
--

FUNCTION get_assignment_id
  (
  p_person_id in number
  )
RETURN number IS
--
   CURSOR c_assignment IS
   SELECT paf.assignment_id
   FROM   per_all_assignments_f paf
   WHERE  paf.person_id = p_person_id
   AND    TRUNC(SYSDATE) BETWEEN paf.effective_start_date AND paf.effective_end_date
   AND    hr_auth_bridge.get_per_system_status(paf.assignment_status_type_id) = 'ACTIVE_ASSIGN'
   AND    paf.primary_flag = 'Y'
   AND    paf.assignment_type IN ('E','B')
   ORDER BY paf.assignment_type DESC;

   l_assignment_id   per_all_assignments_f.assignment_id%type;
--
BEGIN
--
  OPEN c_assignment;
  FETCH c_assignment INTO l_assignment_id;
  CLOSE c_assignment;

  RETURN l_assignment_id;
END;

END hr_auth_bridge;

/
