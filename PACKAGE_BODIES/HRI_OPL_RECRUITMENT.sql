--------------------------------------------------------
--  DDL for Package Body HRI_OPL_RECRUITMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OPL_RECRUITMENT" AS
/* $Header: hriprec.pkb 120.1 2006/02/02 06:13:39 cbridge noship $ */

  g_assignment_id         NUMBER;
  g_hire_asg_id           NUMBER;

  g_interview1_date       DATE;
  g_interview2_date       DATE;
  g_offer_date            DATE;
  g_accepted_date         DATE;
  g_current_date          DATE;
  g_hire_date             DATE;
  g_application_reason    VARCHAR2(30);
  g_interview1_reason     VARCHAR2(30);
  g_interview2_reason     VARCHAR2(30);
  g_offer_reason          VARCHAR2(30);
  g_accepted_reason       VARCHAR2(30);
  g_hire_reason           VARCHAR2(30);
  g_current_status        VARCHAR2(30);
  g_success_flag          VARCHAR2(30);

/* Variables for vacancy cache */
  g_vacancy_id            NUMBER := -1;
  g_vacancy_days_to_hire  NUMBER;
  g_vacancy_fill_to_hire  NUMBER;
  g_vacancy_days_to_fill  NUMBER;
  g_vacancy_apl_count     NUMBER;

PROCEDURE calculate_stages( p_assignment_id IN NUMBER,
                            p_person_id     IN NUMBER,
                            p_term_reason   IN VARCHAR2,
                            p_end_date      IN DATE) IS

/*
  CURSOR irec_stage_csr IS
  SELECT
   ias.status_change_date
  ,ast.per_system_status
  ,ias.status_change_reason
  FROM
   irc_assignment_statuses      ias
  ,per_assignment_status_types  ast
  WHERE ias.assignment_status_type_id = ast.assignment_status_type_id
  AND ias.assignment_id = p_assignment_id;
*/

  CURSOR irec_stage_csr IS
  SELECT
   asg.effective_start_date   status_change_date
  ,ast.per_system_status
  ,asg.change_reason          status_change_reason
  FROM
   per_all_assignments_f        asg
  ,per_assignment_status_types  ast
  WHERE asg.assignment_status_type_id = ast.assignment_status_type_id
  AND asg.assignment_id = p_assignment_id;

  CURSOR success_csr(cp_person_id NUMBER
                    ,cp_assignment_id NUMBER
                    ,cp_end_date DATE) IS
  SELECT 'Y', asg.change_reason, asg.assignment_id
  FROM per_all_assignments_f asg
  WHERE asg.person_id = cp_person_id
  AND asg.effective_start_date = cp_end_date + 1
  AND (asg.assignment_id = cp_assignment_id
    OR asg.primary_flag = 'Y')
  AND asg.assignment_type = 'E'
  ORDER BY DECODE(asg.assignment_id, cp_assignment_id, 1, 2);

BEGIN

  g_assignment_id    := p_assignment_id;

  g_interview1_date   := to_date(null);
  g_interview2_date   := to_date(null);
  g_offer_date        := to_date(null);
  g_accepted_date     := to_date(null);
  g_current_date      := to_date(null);
  g_hire_date         := to_date(null);
  g_interview1_reason := null;
  g_interview2_reason := null;
  g_offer_reason      := null;
  g_accepted_reason   := null;
  g_hire_reason       := null;
  g_success_flag      := null;
  g_current_status    := null;

  FOR stage_rec IN irec_stage_csr LOOP

    IF (stage_rec.per_system_status = 'ACTIVE_APL') THEN
      g_application_reason := stage_rec.status_change_reason;
    ELSIF (stage_rec.per_system_status = 'INTERVIEW1' AND
           g_interview1_date IS NULL) THEN
      g_interview1_date   := stage_rec.status_change_date;
      g_interview1_reason := stage_rec.status_change_reason;
    ELSIF (stage_rec.per_system_status = 'INTERVIEW2' AND
           g_interview2_date IS NULL) THEN
      g_interview2_date   := stage_rec.status_change_date;
      g_interview2_reason := stage_rec.status_change_reason;
    ELSIF (stage_rec.per_system_status = 'OFFER' AND
           g_offer_date IS NULL) THEN
      g_offer_date   := stage_rec.status_change_date;
      g_offer_reason := stage_rec.status_change_reason;
    ELSIF (stage_rec.per_system_status = 'ACCEPTED' AND
           g_accepted_date IS NULL) THEN
      g_accepted_date   := stage_rec.status_change_date;
      g_accepted_reason := stage_rec.status_change_reason;
    ELSIF (stage_rec.per_system_status = 'ACTIVE_ASSIGN' AND
          g_hire_date IS NULL) THEN
          g_hire_date   := stage_rec.status_change_date;
    END IF;

    g_current_status := stage_rec.per_system_status || '_PEND';
    g_current_date := stage_rec.status_change_date;

  END LOOP;

      OPEN success_csr(p_person_id, p_assignment_id, g_hire_date-1);
      FETCH success_csr INTO g_success_flag, g_hire_reason, g_hire_asg_id;
      CLOSE success_csr;

      IF (g_success_flag = 'Y') THEN
        g_current_status := 'END_SCCSS';
        g_current_date := g_hire_date ;
      ELSE
        g_success_flag := 'N';
        g_current_status := 'END_FAIL';
        g_current_date := g_current_date;
      END IF;

END calculate_stages;

PROCEDURE refresh_globals(p_assignment_id  IN NUMBER,
                          p_person_id     IN NUMBER,
                          p_term_reason   IN VARCHAR2,
                          p_end_date      IN DATE) IS

BEGIN

  IF (p_assignment_id = g_assignment_id) THEN
    null;
  ELSE
    calculate_stages(p_assignment_id => p_assignment_id,
                     p_person_id     => p_person_id,
                     p_term_reason   => p_term_reason,
                     p_end_date      => p_end_date);
  END IF;

END refresh_globals;

FUNCTION get_stage_status(p_assignment_id IN NUMBER,
                          p_person_id     IN NUMBER,
                          p_term_reason   IN VARCHAR2,
                          p_end_date      IN DATE,
                          p_system_status IN VARCHAR2)
                RETURN VARCHAR2 IS

  l_return_status      VARCHAR2(30);

BEGIN

  refresh_globals(p_assignment_id => p_assignment_id,
                  p_person_id     => p_person_id,
                  p_term_reason   => p_term_reason,
                  p_end_date      => p_end_date);

  IF (p_system_status = 'ACTIVE_APL') THEN
    IF (g_interview1_date IS NOT NULL OR
        g_interview2_date IS NOT NULL OR
        g_offer_date      IS NOT NULL OR
        g_accepted_date   IS NOT NULL) THEN
      l_return_status := p_system_status || '_ACC';
    ELSIF (p_end_date IS NULL) THEN
      l_return_status := p_system_status || '_PEND';
    ELSE
      l_return_status := p_system_status || '_REJ';
    END IF;
  ELSIF (p_system_status = 'INTERVIEW1' AND g_interview1_date IS NOT NULL) THEN
    IF (g_interview2_date IS NOT NULL OR
        g_offer_date      IS NOT NULL OR
        g_accepted_date   IS NOT NULL) THEN
      l_return_status := p_system_status || '_ACC';
    ELSIF (p_end_date IS NULL) THEN
      l_return_status := p_system_status || '_PEND';
    ELSE
      l_return_status := p_system_status || '_REJ';
    END IF;
  ELSIF (p_system_status = 'INTERVIEW2' AND g_interview2_date IS NOT NULL) THEN
    IF (g_offer_date IS NOT NULL OR g_accepted_date IS NOT NULL) THEN
      l_return_status := p_system_status || '_ACC';
    ELSIF (p_end_date IS NULL) THEN
      l_return_status := p_system_status || '_PEND';
    ELSE
      l_return_status := p_system_status || '_REJ';
    END IF;
  ELSIF (p_system_status = 'OFFER' AND g_offer_date IS NOT NULL) THEN
    IF (g_accepted_date IS NOT NULL) THEN
      l_return_status := p_system_status || '_ACC';
    ELSIF (p_end_date IS NULL) THEN
      l_return_status := p_system_status || '_PEND';
    ELSE
      l_return_status := p_system_status || '_REJ';
    END IF;
  ELSIF (p_system_status = 'ACCEPTED' AND g_accepted_date IS NOT NULL) THEN
    IF (g_success_flag = 'Y') THEN
      l_return_status := p_system_status || '_ACC';
    ELSIF (g_success_flag = 'N') THEN
      l_return_status := p_system_status || '_REJ';
    ELSE
      l_return_status := p_system_status || '_PEND';
    END IF;
  ELSIF (p_system_status = 'END' AND p_end_date IS NOT NULL) THEN
    IF (g_success_flag = 'Y') THEN
      l_return_status := p_system_status || '_SCCSS';
    ELSIF (g_success_flag = 'N') THEN
      l_return_status := p_system_status || '_FAIL';
    END IF;
  ELSIF (p_system_status = 'CURRENT') THEN
    l_return_status := g_current_status;
  END IF;

  RETURN l_return_status;

END get_stage_status;

FUNCTION get_stage_reason(p_assignment_id IN NUMBER,
                          p_person_id     IN NUMBER,
                          p_term_reason   IN VARCHAR2,
                          p_end_date      IN DATE,
                          p_system_status IN VARCHAR2)
                RETURN VARCHAR2 IS

BEGIN

  refresh_globals(p_assignment_id => p_assignment_id,
                  p_person_id     => p_person_id,
                  p_term_reason   => p_term_reason,
                  p_end_date      => p_end_date);

  IF (p_system_status = 'ACTIVE_APL') THEN
    RETURN g_application_reason;
  ELSIF (p_system_status = 'INTERVIEW1') THEN
    RETURN g_interview1_reason;
  ELSIF (p_system_status = 'INTERVIEW2') THEN
    RETURN g_interview2_reason;
  ELSIF (p_system_status = 'OFFER') THEN
    RETURN g_offer_reason;
  ELSIF (p_system_status = 'ACCEPTED') THEN
    RETURN g_accepted_reason;
  ELSIF (p_system_status = 'HIRE') THEN
    RETURN g_hire_reason;
  END IF;

  RETURN null;

END get_stage_reason;

FUNCTION get_stage_date (p_assignment_id IN NUMBER,
                         p_person_id     IN NUMBER,
                         p_term_reason   IN VARCHAR2,
                         p_end_date      IN DATE,
                         p_system_status IN VARCHAR2)
                RETURN DATE IS

BEGIN

  refresh_globals(p_assignment_id => p_assignment_id,
                  p_person_id     => p_person_id,
                  p_term_reason   => p_term_reason,
                  p_end_date      => p_end_date);

  IF (p_system_status = 'INTERVIEW1') THEN
    RETURN g_interview1_date;
  ELSIF (p_system_status = 'INTERVIEW2') THEN
    RETURN g_interview2_date;
  ELSIF (p_system_status = 'OFFER') THEN
    RETURN g_offer_date;
  ELSIF (p_system_status = 'ACCEPTED') THEN
    RETURN g_accepted_date;
  ELSIF (p_system_status = 'CURRENT') THEN
    RETURN g_current_date;
  ELSIF (p_system_status = 'HIRE') THEN
    RETURN g_hire_date;
  END IF;

  RETURN to_date(null);

END get_stage_date;

FUNCTION get_hire_assignment(p_assignment_id IN NUMBER,
                             p_person_id     IN NUMBER,
                             p_term_reason   IN VARCHAR2,
                             p_end_date      IN DATE)
                RETURN NUMBER IS

BEGIN

  refresh_globals(p_assignment_id => p_assignment_id,
                  p_person_id     => p_person_id,
                  p_term_reason   => p_term_reason,
                  p_end_date      => p_end_date);

  RETURN g_hire_asg_id;

END get_hire_assignment;

FUNCTION is_pursued_apl(p_person_id        IN NUMBER,
                        p_vacancy_id       IN NUMBER,
                        p_effective_date   IN DATE)
                RETURN NUMBER IS

  l_pursued_indicator         NUMBER;

  CURSOR pursued_apl_csr IS
  SELECT 1
  FROM
   irc_vacancy_considerations  ivc
  ,per_all_people_f            peo
  WHERE ivc.party_id = peo.party_id
  AND peo.person_id = p_person_id
  AND p_effective_date
        BETWEEN peo.effective_start_date AND peo.effective_end_date;

BEGIN

  OPEN pursued_apl_csr;
  FETCH pursued_apl_csr INTO l_pursued_indicator;
  CLOSE pursued_apl_csr;

  RETURN NVL(l_pursued_indicator,0);

END is_pursued_apl;

/* Refreshes vacancy cache if necessary */
PROCEDURE check_vacancy_cache(p_vacancy_id  IN NUMBER,
                              p_date_from   IN DATE) IS

  CURSOR vacancy_apl_details_csr IS
  SELECT
   AVG(DECODE(aac.current_status_code,
               'END_SCCSS', aac.hire_date - p_date_from,
              to_number(null)))                 days_to_recruit
  ,AVG(DECODE(aac.current_status_code,
               'END_SCCSS', aac.hire_date - aac.accepted_date,
              to_number(null)))                 days_accept_to_hire
  ,AVG(aac.accepted_date - p_date_from)         days_to_accept
  ,COUNT(aac.assignment_id)                     vacancy_apl_count
  FROM hri_mb_apl_activity_v aac
  WHERE fk_vacancy_id = p_vacancy_id; -- bug 4992287 performance enh.

BEGIN

  IF (p_vacancy_id <> g_vacancy_id) THEN
    OPEN vacancy_apl_details_csr;
    FETCH vacancy_apl_details_csr INTO g_vacancy_days_to_hire,
                                       g_vacancy_fill_to_hire,
                                       g_vacancy_days_to_fill,
                                       g_vacancy_apl_count;
    CLOSE vacancy_apl_details_csr;
    g_vacancy_id := p_vacancy_id;
  END IF;

END check_vacancy_cache;

FUNCTION calc_avg_days_to_hire(p_vacancy_id IN NUMBER,
                               p_date_from  IN DATE)
                RETURN NUMBER IS

BEGIN

  check_vacancy_cache(p_vacancy_id => p_vacancy_id,
                      p_date_from => p_date_from);

  RETURN g_vacancy_days_to_hire;

END calc_avg_days_to_hire;

FUNCTION calc_avg_days_to_fill(p_vacancy_id IN NUMBER,
                               p_date_from  IN DATE)
                RETURN NUMBER IS

BEGIN

  check_vacancy_cache(p_vacancy_id => p_vacancy_id,
                      p_date_from => p_date_from);

  RETURN g_vacancy_days_to_fill;

END calc_avg_days_to_fill;

FUNCTION calc_avg_fill_to_hire(p_vacancy_id IN NUMBER,
                               p_date_from  IN DATE)
                RETURN NUMBER IS

BEGIN

  check_vacancy_cache(p_vacancy_id => p_vacancy_id,
                      p_date_from => p_date_from);

  RETURN g_vacancy_fill_to_hire;

END calc_avg_fill_to_hire;

FUNCTION calc_no_apls(p_vacancy_id IN NUMBER,
                      p_date_from  IN DATE)
                RETURN NUMBER IS

BEGIN

  check_vacancy_cache(p_vacancy_id => p_vacancy_id,
                      p_date_from => p_date_from);

  RETURN g_vacancy_apl_count;

END calc_no_apls;

END hri_opl_recruitment;

/
