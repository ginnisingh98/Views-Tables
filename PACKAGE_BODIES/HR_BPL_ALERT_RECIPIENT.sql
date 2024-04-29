--------------------------------------------------------
--  DDL for Package Body HR_BPL_ALERT_RECIPIENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_BPL_ALERT_RECIPIENT" AS
/* $Header: perbarpt.pkb 115.13 2003/07/07 19:12:35 ssherloc noship $ */
--
-- -----------------------------------------------------------------------------
--
-- Validate an email address is in the correct format RETURNING BOOLEAN
--
FUNCTION validate_email_address(p_email_address VARCHAR2)
  RETURN BOOLEAN
IS
  --
  c_count   NUMBER(15);
  c_char    VARCHAR2(4);
  l_length  NUMBER(15);
  --
  -- Counts
  --
  at_count               NUMBER(3) DEFAULT 0;
  fst_at_pos             NUMBER(3) DEFAULT 0;
  dot_before_at_count    NUMBER(3) DEFAULT 0;
  dot_after_at_count     NUMBER(3) DEFAULT 0;
  in_token               BOOLEAN;
  --
BEGIN
  --
  IF p_email_address IS NULL
  THEN
    --
    RETURN FALSE;
    --
  END IF;
  --
  l_length  := length(p_email_address) + 1;
  c_count   := 0;
  c_char    := '';
  in_token  := FALSE;
  --
  WHILE c_count < l_length LOOP
    --
    c_char := substr(p_email_address,c_count,1);
    --
    IF NVL(c_char,'&') = ' '
    THEN
      --
      RETURN FALSE;
      --
    ELSIF NVL(c_char,'&') = '@'
    THEN
      --
      IF NOT in_token
      THEN
        --
        RETURN FALSE;
        --
      END IF;
      --
      IF fst_at_pos = 0
      THEN
        --
        fst_at_pos := c_count;
        --
      END IF;
      --
      at_count   := at_count + 1;
      --
      in_token := FALSE;
      --
    ELSIF NVL(c_char,'&') = '.'
    THEN
      --
      IF NOT in_token
      THEN
        --
        RETURN FALSE;
        --
      END IF;
      --
      IF at_count > 0
      THEN
        --
        dot_after_at_count := dot_before_at_count + 1;
        --
      END IF;
      --
      in_token := FALSE;
      --
    ELSE
     --
     in_token := TRUE;
     --
    END IF;
    --
    c_count := c_count + 1;
    --
  END LOOP;
  --
  IF dot_after_at_count = 0
  THEN
    --
    RETURN FALSE;
    --
  ELSIF fst_at_pos = 0
  THEN
    --
    RETURN FALSE;
    --
  ELSIF NOT in_token
  THEN
    --
    RETURN FALSE;
    --
  ELSE
    --
    RETURN TRUE;
    --
  END IF;
  --
END validate_email_address;
--
-- -----------------------------------------------------------------------------
--
-- Validate an email address is in the correct format RETURNING CHAR
--
FUNCTION c_validate_email_address(p_email_address VARCHAR2)
  RETURN VARCHAR2
IS
  --
BEGIN
  --
  IF validate_email_address(p_email_address)
  THEN
    --
    RETURN 'TRUE';
    --
  ELSE
    --
    RETURN 'FALSE';
    --
  END IF;
  --
END c_validate_email_address;
--
-- -----------------------------------------------------------------------------
--
-- Get details for the person who owns a given assignment
--
PROCEDURE cache_pasg_sup_details(p_assignment_id IN NUMBER)
  IS
  --
  CURSOR c_pasg_sup_details
      ( cp_assignment_id NUMBER )
  IS
  SELECT psn.email_address
        ,DECODE(psn.email_address,NULL,-1,p_assignment_id)
        ,DECODE(psn.person_id,NULL,-1,p_assignment_id)
        ,psn.person_id
        ,psn.full_name
        ,psn.correspondence_language
        ,psn.business_group_id
  FROM   per_all_people_f psn
        ,per_all_assignments_f asg
        ,per_all_assignments_f asg2
        ,per_assignment_status_types ast
        ,per_assignment_status_types ast2
  WHERE asg.assignment_id  = cp_assignment_id
  AND   asg.assignment_status_type_id = ast.assignment_status_type_id
  AND   asg.person_id      = asg2.person_id
  AND   asg2.primary_flag  = 'Y'
  AND   asg2.supervisor_id = psn.person_id
  AND   asg2.assignment_status_type_id = ast2.assignment_status_type_id
  /* Ensures only current primary assignment is used */
  AND   ((asg.effective_start_date
              BETWEEN asg2.effective_start_date
                  AND asg2.effective_end_date ) OR
         (asg2.effective_start_date
              BETWEEN asg.effective_start_date
                  AND asg.effective_end_date))
  AND   ((psn.effective_start_date
              BETWEEN asg2.effective_start_date
                  AND asg2.effective_end_date ) OR
         (asg2.effective_start_date
              BETWEEN psn.effective_start_date
                  AND psn.effective_end_date))
  /* Make sure that the Recipient is a current Worker */
  AND ((psn.current_employee_flag = 'Y') OR
       (psn.current_npw_flag = 'Y'))
  AND   (
         (TRUNC(SYSDATE) BETWEEN asg.effective_start_date
                         AND     asg.effective_end_date
          AND
          TRUNC(SYSDATE) BETWEEN psn.effective_start_date
                         AND psn.effective_end_date)
          OR
         (
          (NOT EXISTS (SELECT 'X'
                      FROM per_all_assignments_f asg2
                      WHERE asg2.assignment_id = asg.assignment_id
                      AND   ((asg2.assignment_type = 'E') OR
                             (asg2.assignment_type = 'C'))
                      AND   TRUNC(SYSDATE) BETWEEN asg2.effective_start_date
                                           AND     asg2.effective_end_date))
           AND
          (asg.effective_start_date IN
                      (
                      SELECT MIN(asg3.effective_start_date)
                      FROM per_all_assignments_f asg3
                      WHERE asg3.assignment_id = asg.assignment_id
                      AND   ((asg3.assignment_type = 'E') OR
                             (asg3.assignment_type = 'C'))
                      AND   asg3.effective_start_date > TRUNC(SYSDATE)
                      )
          )
         )
        )
        /* Return active assignment status types only */
  AND ast.per_system_status IN ('ACCEPTED','ACTIVE_APL'
                             ,'ACTIVE_ASSIGN','ACTIVE_CWK','END'
                             ,'INTERVIEW1','INTERVIEW2'
                             ,'OFFER','SUSP_ASSIGN','SUSP_CWK_ASG')
  AND ast2.per_system_status IN ('ACCEPTED','ACTIVE_APL'
                             ,'ACTIVE_ASSIGN','ACTIVE_CWK','END'
                             ,'INTERVIEW1','INTERVIEW2'
                             ,'OFFER','SUSP_ASSIGN','SUSP_CWK_ASG')

        ;
  --
  l_count NUMBER(7);
  --
BEGIN
  --
  -- If we don't have an id then we can't get an address
  --
  IF p_assignment_id IS NULL THEN
    --
    g_pasg_sup_person_email       := NULL;
    g_pasg_sup_person_email_set   := NULL;
    g_pasg_sup_person_available   := NULL;
    g_pasg_sup_sup_person_id      := NULL;
    g_pasg_sup_person_name        := NULL;
    g_pasg_sup_person_lang        := NULL;
    g_pasg_sup_business_group_id  := NULL;
    --
    RETURN;
    --
  END IF;
  --
  -- If we already have the email address use it.
  --
  IF p_assignment_id = g_pasg_sup_assignment_id THEN
    --
    RETURN;
    --
  END IF;
  --
  g_pasg_sup_assignment_id := p_assignment_id;
  --
  OPEN c_pasg_sup_details(
        p_assignment_id );
  --
  FETCH c_pasg_sup_details
  INTO  g_pasg_sup_person_email
       ,g_pasg_sup_person_email_set
       ,g_pasg_sup_person_available
       ,g_pasg_sup_sup_person_id
       ,g_pasg_sup_person_name
       ,g_pasg_sup_person_lang
       ,g_pasg_sup_business_group_id;
  --
  l_count := c_pasg_sup_details%rowcount;
  --
  CLOSE c_pasg_sup_details;
  --
  IF l_count = 0
  THEN
    --
    g_pasg_sup_person_email       := NULL;
    g_pasg_sup_person_email_set   := NULL;
    g_pasg_sup_person_available   := NULL;
    g_pasg_sup_sup_person_id      := NULL;
    g_pasg_sup_person_name        := NULL;
    g_pasg_sup_person_lang        := NULL;
    g_pasg_sup_business_group_id  := NULL;
    --
  ELSIF NOT validate_email_address(g_pasg_sup_person_email)
  THEN
    --
    g_pasg_sup_person_email_set := NULL;
    --
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    CLOSE c_pasg_sup_details;
    --
    g_pasg_sup_person_email       := NULL;
    g_pasg_sup_person_email_set   := NULL;
    g_pasg_sup_person_available   := NULL;
    g_pasg_sup_sup_person_id      := NULL;
    g_pasg_sup_person_name        := NULL;
    g_pasg_sup_person_lang        := NULL;
    g_pasg_sup_business_group_id  := NULL;
    --
  --
END cache_pasg_sup_details;
--
-- -----------------------------------------------------------------------------
--
-- Get details for the person who supervises a given assignment
--
PROCEDURE cache_asg_sup_details(p_assignment_id IN NUMBER)
  IS
  --
  CURSOR c_asg_sup_details
      ( cp_assignment_id NUMBER )
  IS
  SELECT psn.email_address
        ,DECODE(psn.email_address,NULL,-1,p_assignment_id)
        ,DECODE(psn.person_id,NULL,-1,p_assignment_id)
        ,psn.person_id
        ,psn.full_name
        ,psn.correspondence_language
        ,psn.business_group_id
  FROM   per_all_people_f psn
        ,per_all_assignments_f asg
        ,per_assignment_status_types ast
  WHERE asg.assignment_id = cp_assignment_id
  AND   asg.supervisor_id = psn.person_id
  AND   asg.assignment_status_type_id = ast.assignment_status_type_id
    /* Ensures only current person and assignment used */
  AND   ((psn.effective_start_date
              BETWEEN asg.effective_start_date
                  AND asg.effective_end_date ) OR
         (asg.effective_start_date
              BETWEEN psn.effective_start_date
                  AND psn.effective_end_date))
  /* Make sure that the Recipient is a current Worker */
  AND ((psn.current_employee_flag = 'Y') OR
       (psn.current_npw_flag = 'Y'))
  AND   (
         (TRUNC(SYSDATE) BETWEEN asg.effective_start_date
                         AND     asg.effective_end_date
          AND
          TRUNC(SYSDATE) BETWEEN psn.effective_start_date
                         AND     psn.effective_end_date)
          OR
         (
          (NOT EXISTS (SELECT 'X'
                      FROM per_all_assignments_f asg2
                      WHERE asg2.assignment_id = asg.assignment_id
                      AND   ((asg2.assignment_type = 'E') OR
                             (asg2.assignment_type = 'C'))
                      AND   TRUNC(SYSDATE) BETWEEN asg2.effective_start_date
                                           AND     asg2.effective_end_date))
           AND
          (asg.effective_start_date IN
                      (
                      SELECT MIN(asg3.effective_start_date)
                      FROM per_all_assignments_f asg3
                      WHERE asg3.assignment_id = asg.assignment_id
                      AND   ((asg3.assignment_type = 'E') OR
                             (asg3.assignment_type = 'C'))
                      AND   asg3.effective_start_date > TRUNC(SYSDATE)
                      )
          )
         )
        )
  AND ast.per_system_status IN ('ACCEPTED','ACTIVE_APL'
                             ,'ACTIVE_ASSIGN','ACTIVE_CWK','END'
                             ,'INTERVIEW1','INTERVIEW2'
                             ,'OFFER','SUSP_ASSIGN','SUSP_CWK_ASG') ;
  --
  l_count NUMBER(7);
  --
BEGIN
  --
  -- If we don't have an id then we can't get an address
  --
  IF p_assignment_id IS NULL THEN
    --
    g_asg_sup_person_email       := NULL;
    g_asg_sup_person_email_set   := NULL;
    g_asg_sup_person_available   := NULL;
    g_asg_sup_sup_person_id      := NULL;
    g_asg_sup_person_name        := NULL;
    g_asg_sup_person_lang        := NULL;
    g_asg_sup_business_group_id  := NULL;
    --
    RETURN;
    --
  END IF;
  --
  -- If we already have the email address use it.
  --
  IF p_assignment_id = g_asg_sup_assignment_id THEN
    --
    RETURN;
    --
  END IF;
  --
  g_asg_sup_assignment_id := p_assignment_id;
  --
  OPEN c_asg_sup_details(
        p_assignment_id );
  --
  FETCH c_asg_sup_details
  INTO  g_asg_sup_person_email
       ,g_asg_sup_person_email_set
       ,g_asg_sup_person_available
       ,g_asg_sup_sup_person_id
       ,g_asg_sup_person_name
       ,g_asg_sup_person_lang
       ,g_asg_sup_business_group_id;
  --
  l_count := c_asg_sup_details%rowcount;
  --
  CLOSE c_asg_sup_details;
  --
  IF l_count = 0
  THEN
    --
    g_asg_sup_person_email       := NULL;
    g_asg_sup_person_email_set   := NULL;
    g_asg_sup_person_available   := NULL;
    g_asg_sup_sup_person_id      := NULL;
    g_asg_sup_person_name        := NULL;
    g_asg_sup_person_lang        := NULL;
    g_asg_sup_business_group_id  := NULL;
    --
  ELSIF NOT validate_email_address(g_asg_sup_person_email)
  THEN
    --
    g_asg_sup_person_email_set := NULL;
    --
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    CLOSE c_asg_sup_details;
    --
    g_asg_sup_person_email       := NULL;
    g_asg_sup_person_email_set   := NULL;
    g_asg_sup_person_available   := NULL;
    g_asg_sup_sup_person_id      := NULL;
    g_asg_sup_person_name        := NULL;
    g_asg_sup_person_lang        := NULL;
    g_asg_sup_business_group_id  := NULL;
    --
  --
END cache_asg_sup_details;
--
-- -----------------------------------------------------------------------------
--
-- Get details for the person who owns a given assignment
--
PROCEDURE cache_asg_psn_details(p_assignment_id IN NUMBER)
  IS
  --
  CURSOR c_asg_psn_details
      ( cp_assignment_id NUMBER)
  IS
  SELECT psn.email_address
        ,DECODE(psn.email_address,NULL,-1,p_assignment_id)
        ,psn.person_id
        ,psn.full_name
        ,psn.correspondence_language
        ,psn.business_group_id
  FROM   per_all_people_f psn
        ,per_all_assignments_f asg
        ,per_assignment_status_types ast
  WHERE asg.assignment_id = cp_assignment_id
  AND   asg.assignment_status_type_id = ast.assignment_status_type_id
  AND   asg.person_id     = psn.person_id
  /* Ensures only current person and assignment used */
  AND   ((psn.effective_start_date
              BETWEEN asg.effective_start_date
                  AND asg.effective_end_date ) OR
         (asg.effective_start_date
              BETWEEN psn.effective_start_date
                  AND psn.effective_end_date))
  /* Make sure that the Recipient is a current Worker */
  AND ((psn.current_employee_flag = 'Y') OR
       (psn.current_npw_flag = 'Y'))
  AND   (
         (TRUNC(SYSDATE) BETWEEN asg.effective_start_date
                         AND     asg.effective_end_date
          AND
          TRUNC(SYSDATE) BETWEEN psn.effective_start_date
                         AND     psn.effective_end_date)
          OR
         (
          (NOT EXISTS (SELECT 'X'
                      FROM per_all_assignments_f asg2
                      WHERE asg2.assignment_id = asg.assignment_id
                      AND   ((asg2.assignment_type = 'E') OR
                             (asg2.assignment_type = 'C'))
                      AND   TRUNC(SYSDATE) BETWEEN asg2.effective_start_date
                                           AND     asg2.effective_end_date))
           AND
          (asg.effective_start_date IN
                      (
                      SELECT MIN(asg3.effective_start_date)
                      FROM per_all_assignments_f asg3
                      WHERE asg3.assignment_id = asg.assignment_id
                      AND   ((asg3.assignment_type = 'E') OR
                             (asg3.assignment_type = 'C'))
                      AND   asg3.effective_start_date > TRUNC(SYSDATE)
                      )
          )
         )
        )
  AND ast.per_system_status IN ('ACCEPTED','ACTIVE_APL'
                             ,'ACTIVE_ASSIGN','ACTIVE_CWK','END'
                             ,'INTERVIEW1','INTERVIEW2'
                             ,'OFFER','SUSP_ASSIGN','SUSP_CWK_ASG') ;
  --
  l_count NUMBER(7);
  --
BEGIN
  --
  -- If we don't have an id then we can't get an address
  --
  IF p_assignment_id IS NULL THEN
    --
    g_asg_person_email       := NULL;
    g_asg_person_email_set   := NULL;
    g_asg_sup_person_id      := NULL;
    g_asg_person_name        := NULL;
    g_asg_person_lang        := NULL;
    g_asg_business_group_id  := NULL;
    --
    RETURN;
    --
  END IF;
  --
  -- If we already have the email address use it.
  --
  IF p_assignment_id = g_assignment_id THEN
    --
    RETURN;
    --
  END IF;
  --
  g_assignment_id          := p_assignment_id;
  --
  OPEN c_asg_psn_details(
        p_assignment_id );
  --
  FETCH c_asg_psn_details
  INTO  g_asg_person_email
       ,g_asg_person_email_set
       ,g_asg_sup_person_id
       ,g_asg_person_name
       ,g_asg_person_lang
       ,g_asg_business_group_id;
  --
  CLOSE c_asg_psn_details;
  --
  IF l_count = 0
  THEN
    --
    g_asg_person_email       := NULL;
    g_asg_person_email_set   := NULL;
    g_asg_sup_person_id      := NULL;
    g_asg_person_name        := NULL;
    g_asg_person_lang        := NULL;
    g_asg_business_group_id  := NULL;
    --
  ELSIF NOT validate_email_address(g_asg_person_email)
  THEN
    --
    g_asg_person_email_set := NULL;
    --
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    CLOSE c_asg_psn_details;
    --
    g_asg_person_email       := NULL;
    g_asg_person_email_set   := NULL;
    g_asg_sup_person_id      := NULL;
    g_asg_person_name        := NULL;
    g_asg_person_lang        := NULL;
    g_asg_business_group_id  := NULL;
    --
  --
END cache_asg_psn_details;
--
-- -----------------------------------------------------------------------------
--
-- Get's an email address for a given person_id
--
PROCEDURE Cache_psn_details(p_person_id     IN NUMBER)
IS
  --
  CURSOR c_psn_details
      ( cp_person_id NUMBER )
  IS
  SELECT email_address
        ,DECODE(email_address,NULL,-1,p_person_id)
        ,full_name
        ,correspondence_language
        ,business_group_id
  FROM   per_all_people_f psn
  WHERE person_id = cp_person_id
  AND ((psn.current_employee_flag = 'Y') OR
       (psn.current_npw_flag = 'Y'))
  AND   (
         (TRUNC(SYSDATE) BETWEEN psn.effective_start_date
                         AND     psn.effective_end_date)
          OR
         (
          (NOT EXISTS (SELECT 'X'
                      FROM per_all_people_f psn2
                      WHERE psn2.person_id = psn.person_id
                      AND   ((psn2.current_employee_flag = 'Y') OR
                             (psn2.current_npw_flag = 'Y'))
                      AND   TRUNC(SYSDATE) BETWEEN psn2.effective_start_date
                                           AND     psn2.effective_end_date))
           AND
          (psn.effective_start_date IN
                      (
                      SELECT MIN(psn3.effective_start_date)
                      FROM per_all_people_f psn3
                      WHERE psn3.person_id = psn.person_id
                      AND   ((psn3.current_employee_flag = 'Y') OR
                             (psn3.current_npw_flag = 'Y'))
                      AND   psn3.effective_start_date > TRUNC(SYSDATE)
                      )
          )
         )
        );
  --
  l_count NUMBER(7);
  --
BEGIN
  --
  -- If we don't have an id then we can't get an address
  --
  --
  IF p_person_id IS NULL THEN
    --
    g_person_email      := NULL;
    g_person_email_set  := NULL;
    g_person_name       := NULL;
    g_person_lang       := NULL;
    g_person_bg_id      := NULL;
    --
    RETURN;
    --
  END IF;
  --
  -- If we already have the  email address use it.
  --
  IF p_person_id = g_person_id THEN
    --
    RETURN;
    --
  END IF;
  --
  g_person_id         := p_person_id;
  --
  OPEN c_psn_details(
        p_person_id );
  --
  FETCH c_psn_details
  INTO  g_person_email
       ,g_person_email_set
       ,g_person_name
       ,g_person_lang
       ,g_person_bg_id;
  --
  l_count := c_psn_details%rowcount;
  --
  CLOSE c_psn_details;
  --
  IF l_count = 0
  THEN
    --
    g_person_email      := NULL;
    g_person_email_set  := NULL;
    g_person_name       := NULL;
    g_person_lang       := NULL;
    g_person_bg_id      := NULL;
    --
  ELSIF NOT validate_email_address(g_person_email)
  THEN
    --
    g_person_email_set := NULL;
    --
  END IF;
  --
  RETURN;
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    CLOSE c_psn_details;
    --
    g_person_email      := NULL;
    g_person_email_set  := NULL;
    g_person_name       := NULL;
    g_person_lang       := NULL;
    g_person_bg_id      := NULL;
    --
    RETURN;
    --
  --
END Cache_psn_details;

--
-- -----------------------------------------------------------------------------
--
-- Get's an email address for a given person_id
--
PROCEDURE cache_all_psn_details(p_person_id     IN NUMBER)
IS
  --
  CURSOR c_all_psn_details
      ( cp_person_id NUMBER )
  IS
  SELECT email_address
        ,DECODE(email_address,NULL,-1,p_person_id)
        ,full_name
        ,correspondence_language
        ,business_group_id
  FROM   per_all_people_f psn
  WHERE person_id = cp_person_id
  --AND ((psn.current_employee_flag = 'Y') OR
  --   (psn.current_npw_flag = 'Y'))
  AND   (
         (TRUNC(SYSDATE) BETWEEN psn.effective_start_date
                         AND     psn.effective_end_date)
          OR
         (
          (NOT EXISTS (SELECT 'X'
                      FROM per_all_people_f psn2
                      WHERE psn2.person_id = psn.person_id
                      AND   ((psn2.current_employee_flag = 'Y') OR
                             (psn2.current_npw_flag = 'Y'))
                      AND   TRUNC(SYSDATE) BETWEEN psn2.effective_start_date
                                           AND     psn2.effective_end_date))
           AND
          (psn.effective_start_date IN
                      (
                      SELECT MIN(psn3.effective_start_date)
                      FROM per_all_people_f psn3
                      WHERE psn3.person_id = psn.person_id
                      AND   ((psn3.current_employee_flag = 'Y') OR
                             (psn3.current_npw_flag = 'Y'))
                      AND   psn3.effective_start_date > TRUNC(SYSDATE)
                      )
          )
         )
        );
  --
  l_count NUMBER(7);
  --
BEGIN
  --
  -- If we don't have an id then we can't get an address
  --
  --
  IF p_person_id IS NULL THEN
    --
    g_all_person_email      := NULL;
    g_all_person_email_set  := NULL;
    g_all_person_name       := NULL;
    g_all_person_lang       := NULL;
    g_all_person_bg_id      := NULL;
    --
    RETURN;
    --
  END IF;
  --
  -- If we already have the  email address use it.
  --
  IF p_person_id = g_all_person_id THEN
    --
    RETURN;
    --
  END IF;
  --
  g_all_person_id         := p_person_id;
  --
  OPEN c_all_psn_details(
        p_person_id );
  --
  FETCH c_all_psn_details
  INTO  g_all_person_email
       ,g_all_person_email_set
       ,g_all_person_name
       ,g_all_person_lang
       ,g_all_person_bg_id;
  --
  l_count := c_all_psn_details%rowcount;
  --
  CLOSE c_all_psn_details;
  --
  IF l_count = 0
  THEN
    --
    g_all_person_email      := NULL;
    g_all_person_email_set  := NULL;
    g_all_person_name       := NULL;
    g_all_person_lang       := NULL;
    g_all_person_bg_id      := NULL;
    --
  ELSIF NOT validate_email_address(g_all_person_email)
  THEN
    --
    g_all_person_email_set := NULL;
    --
  END IF;
  --
  RETURN;
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    CLOSE c_all_psn_details;
    --
    g_all_person_email      := NULL;
    g_all_person_email_set  := NULL;
    g_all_person_name       := NULL;
    g_all_person_lang       := NULL;
    g_all_person_bg_id      := NULL;
    --
    RETURN;
    --
  --
END cache_all_psn_details;
--
-- -----------------------------------------------------------------------------
--
-- Get's a person's name for a given person_id
--
FUNCTION Get_psn_prsn_nm(p_person_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  Cache_psn_details(p_person_id);
  --
  RETURN g_person_name;
  --
END Get_psn_prsn_nm;
--
-- -----------------------------------------------------------------------------
--
-- Get's a person's name for a given person_id
--
FUNCTION Get_all_psn_prsn_nm(p_person_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  Cache_all_psn_details(p_person_id);
  --
  RETURN g_all_person_name;
  --
END Get_all_psn_prsn_nm;
--
-- -----------------------------------------------------------------------------
--
-- Get's an email address for a given person_id
--
FUNCTION Get_psn_eml_addrss(p_person_id     IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  Cache_psn_details(p_person_id);
  --
   RETURN g_person_email;
  --
END Get_psn_eml_addrss;
--
-- -----------------------------------------------------------------------------
--
-- Get details from the per_all_people_f for the primary
-- assignment supervisor for a given person_id
--
PROCEDURE cache_psn_sup_psn_details(p_person_id IN NUMBER)
  IS
  --
  CURSOR c_psn_sup_psn_details
      ( cp_person_id NUMBER )
  IS
  SELECT psn.email_address
        ,DECODE(psn.email_address,NULL,-1,p_person_id)
        ,psn.person_id
        ,psn.full_name
        ,psn.correspondence_language
        ,psn.business_group_id
  FROM   per_all_people_f psn
        ,per_all_assignments_f asg
  WHERE asg.person_id     = cp_person_id
  AND   asg.primary_flag  = 'Y'
  AND   asg.supervisor_id = psn.person_id
      /* Ensures only current person and assignment used */
  AND   ((psn.effective_start_date
              BETWEEN asg.effective_start_date
                  AND asg.effective_end_date ) OR
         (asg.effective_start_date
              BETWEEN psn.effective_start_date
                  AND psn.effective_end_date))
  /* Make sure that the Recipient is a current Worker */
  AND ((psn.current_employee_flag = 'Y') OR
       (psn.current_npw_flag = 'Y'))
  AND   (
         (TRUNC(SYSDATE) BETWEEN asg.effective_start_date
                         AND     asg.effective_end_date
          AND
          TRUNC(SYSDATE) BETWEEN psn.effective_start_date
                         AND     psn.effective_end_date)
          OR
         (
          (NOT EXISTS (SELECT 'X'
                      FROM per_all_assignments_f asg2
                      WHERE asg2.assignment_id = asg.assignment_id
                      AND   ((asg2.assignment_type = 'E') OR
                             (asg2.assignment_type = 'C'))
                      AND   TRUNC(SYSDATE) BETWEEN asg2.effective_start_date
                                           AND     asg2.effective_end_date))
           AND
          (asg.effective_start_date IN
                      (
                      SELECT MIN(asg3.effective_start_date)
                      FROM per_all_assignments_f asg3
                      WHERE asg3.assignment_id = asg.assignment_id
                      AND   ((asg3.assignment_type = 'E') OR
                             (asg3.assignment_type = 'C'))
                      AND   asg3.effective_start_date > TRUNC(SYSDATE)
                      )
          )
         )
        );
  --
  l_count NUMBER(7);
  --
BEGIN
  --
  -- If we don't have an id then we can't get an address
  --
  IF p_person_id IS NULL THEN
    --
    g_sup_person_email       := NULL;
    g_sup_person_email_set   := NULL;
    g_psn_sup_person_id      := NULL;
    g_sup_person_name        := NULL;
    g_sup_person_lang        := NULL;
    g_sup_business_group_id  := NULL;
    --
    RETURN;
    --
  END IF;
  --
  -- If we already have the email address use it.
  --
  IF p_person_id = g_sup_person_id THEN
    --
    RETURN;
    --
  END IF;
  --
  g_sup_person_id          := p_person_id;
  --
  OPEN c_psn_sup_psn_details(
        p_person_id );
  --
  FETCH c_psn_sup_psn_details
  INTO  g_sup_person_email
       ,g_sup_person_email_set
       ,g_psn_sup_person_id
       ,g_sup_person_name
       ,g_sup_person_lang
       ,g_sup_business_group_id;
  --
  l_count := c_psn_sup_psn_details%rowcount;
  --
  CLOSE c_psn_sup_psn_details;
  --
  IF l_count = 0
  THEN
    --
    g_sup_person_email       := NULL;
    g_sup_person_email_set   := NULL;
    g_psn_sup_person_id      := NULL;
    g_sup_person_name        := NULL;
    g_sup_person_lang        := NULL;
    g_sup_business_group_id  := NULL;
    --
  ELSIF NOT validate_email_address(g_sup_person_email)
  THEN
    --
    g_sup_person_email_set := NULL;
    --
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    CLOSE c_psn_sup_psn_details;
    --
    g_sup_person_email       := NULL;
    g_sup_person_email_set   := NULL;
    g_psn_sup_person_id      := NULL;
    g_sup_person_name        := NULL;
    g_sup_person_lang        := NULL;
    g_sup_business_group_id  := NULL;
    --
  --
END cache_psn_sup_psn_details;
--
-- -----------------------------------------------------------------------------
--
-- Get's an email address for a given person_id
--
FUNCTION Get_psn_sup_psn_eml_addrss(p_person_id     IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  cache_psn_sup_psn_details(p_person_id);
  --
  RETURN g_sup_person_email;
  --
END Get_psn_sup_psn_eml_addrss;
--
-- -----------------------------------------------------------------------------
--
-- Get's a primary assignment supervisor name for a given person_id
--
FUNCTION Get_psn_sup_psn_nm(p_person_id     IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  cache_psn_sup_psn_details(p_person_id);
  --
  RETURN g_sup_person_name;
  --
END Get_psn_sup_psn_nm;
--
-- -----------------------------------------------------------------------------
--
-- Gets a  bg's language for a given p_business_group_id
--
-- !!! Currently defaults language to US if no BG language available !!!
-- !!! THIS MUST BE CORRECTED                                        !!!
--
FUNCTION Get_bg_lng(p_business_group_id     IN NUMBER)
  RETURN VARCHAR2 IS
  --
  CURSOR c_bg_details
      ( cp_business_group_id NUMBER )
  IS
  SELECT org_information9 bg_lang
  FROM   hr_organization_information
  WHERE  org_information_context = 'Business Group Information'
  AND    organization_id = cp_business_group_id;
  --
  l_lang VARCHAR2(10) DEFAULT NULL;
  --
BEGIN
  --
  OPEN c_bg_details
      ( p_business_group_id );
  --
  FETCH c_bg_details
  INTO  l_lang;
  --
  CLOSE c_bg_details;
  --
  IF l_lang IS NULL THEN
    --
    l_lang := 'US';
    --
  END IF;
  --
  RETURN l_lang;
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    CLOSE c_bg_details;
    --
    RETURN 'US';
    --
END Get_bg_lng;

--
-- -----------------------------------------------------------------------------
--
-- Get's a language for a given person_id
--
FUNCTION Get_psn_lng(p_person_id     IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  cache_psn_details(p_person_id);
  --
  -- if the person does not have a language set
  --
  IF g_person_lang IS NULL THEN
    --
    g_person_lang := Get_bg_lng(g_person_bg_id);
    --
  END IF;
  --
  RETURN g_person_lang;
  --
END Get_psn_lng;
--
-- -----------------------------------------------------------------------------
--
-- Get's the primary assignment supervisor's language for a given person_id
--
FUNCTION Get_psn_sup_psn_lng(p_person_id     IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  cache_psn_sup_psn_details(p_person_id);
  --
  IF g_sup_person_lang IS NULL THEN
    --
    g_sup_person_lang := Get_bg_lng(g_sup_business_group_id);
    --
  END IF;
  --
  RETURN g_sup_person_lang;
  --
END Get_psn_sup_psn_lng;
--
-- -----------------------------------------------------------------------------
--
-- Find out if we have an email address for a person's primary
-- assignment supervisor, if we have return 'Y' otherwise 'N'
--
FUNCTION Check_sup_person_in_scope(p_person_id     IN NUMBER)
          RETURN NUMBER IS
  --
BEGIN
  --
  cache_psn_sup_psn_details(p_person_id);
  --
  RETURN g_sup_person_email_set;
  --
END Check_sup_person_in_scope;
--
-- -----------------------------------------------------------------------------
--
-- Find out if we have an email address for a person. If we have
-- return 'Y' otherwise 'N'.
--
FUNCTION Check_person_in_scope(p_person_id     IN NUMBER)
          RETURN NUMBER IS
  --
BEGIN
  --
  cache_psn_details(p_person_id);
  --
  RETURN g_person_email_set;
  --
END Check_person_in_scope;
--
-- -----------------------------------------------------------------------------
--
-- Get's an email address for a supervisor of a given assignment_id
--
FUNCTION Get_asg_sup_eml_addrss(p_assignment_id     IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  cache_asg_sup_details(p_assignment_id);
  --
  RETURN g_asg_sup_person_email;
  --
END Get_asg_sup_eml_addrss;
--
-- -----------------------------------------------------------------------------
--
-- Get's a primary assignment supervisor name for a given person_id
--
FUNCTION Get_asg_sup_nm(p_assignment_id     IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  cache_asg_sup_details(p_assignment_id);
  --
  RETURN g_asg_sup_person_name;
  --
END Get_asg_sup_nm;
--
-- -----------------------------------------------------------------------------
--
-- Get's the primary assignment supervisor's language for a given person_id
--
FUNCTION Get_asg_sup_lng(p_assignment_id     IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  cache_asg_sup_details(p_assignment_id);
  --
  IF g_asg_sup_person_lang IS NULL THEN
    --
    g_asg_sup_person_lang := Get_bg_lng(g_asg_sup_business_group_id);
    --
  END IF;
  --
  RETURN g_asg_sup_person_lang;
  --
END Get_asg_sup_lng;
--
-- -----------------------------------------------------------------------------
--
-- Find out if we have an email address for a person's primary
-- assignment supervisor, if we have return 'Y' otherwise 'N'
--
FUNCTION Check_asg_sup_in_scope(p_assignment_id     IN NUMBER)
          RETURN NUMBER IS
  --
BEGIN
  --
  cache_asg_sup_details(p_assignment_id);
  --
  RETURN g_asg_sup_person_email_set;
  --
END Check_asg_sup_in_scope;
--
-- -----------------------------------------------------------------------------
--
-- Get's an email address for a supervisor of a given assignment_id
--
FUNCTION Get_pasg_sup_eml_addrss(p_assignment_id     IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  cache_pasg_sup_details(p_assignment_id);
  --
  RETURN g_pasg_sup_person_email;
  --
END Get_pasg_sup_eml_addrss;
--
-- -----------------------------------------------------------------------------
--
-- Get's a primary assignment supervisor name for a given person_id
--
FUNCTION Get_pasg_sup_nm(p_assignment_id     IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  cache_pasg_sup_details(p_assignment_id);
  --
  RETURN g_pasg_sup_person_name;
  --
END Get_pasg_sup_nm;
--
-- -----------------------------------------------------------------------------
--
-- Get's the primary assignment supervisor's language for a given person_id
--
FUNCTION Get_pasg_sup_lng(p_assignment_id     IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  cache_pasg_sup_details(p_assignment_id);
  --
  IF g_pasg_sup_person_lang IS NULL THEN
    --
    g_pasg_sup_person_lang := Get_bg_lng(g_pasg_sup_business_group_id);
    --
  END IF;
  --
  RETURN g_pasg_sup_person_lang;
  --
END Get_pasg_sup_lng;
--
-- -----------------------------------------------------------------------------
--
-- Find out if we have an email address for a person's primary
-- assignment supervisor, if we have return 'Y' otherwise 'N'
--
FUNCTION Check_pasg_sup_in_scope(p_assignment_id     IN NUMBER)
          RETURN NUMBER IS
  --
BEGIN
  --
  cache_pasg_sup_details(p_assignment_id);
  --
  RETURN g_pasg_sup_person_email_set;
  --
END Check_pasg_sup_in_scope;
--
-- -----------------------------------------------------------------------------
--
-- Get's an email address for a supervisor of a given assignment_id
--
FUNCTION Get_asg_psn_eml_addrss(p_assignment_id     IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  cache_asg_psn_details(p_assignment_id);
  --
  RETURN g_asg_person_email;
  --
END Get_asg_psn_eml_addrss;
--
-- -----------------------------------------------------------------------------
--
-- Get's a primary assignment supervisor name for a given person_id
--
FUNCTION Get_asg_psn_nm(p_assignment_id     IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  cache_asg_psn_details(p_assignment_id);
  --
  RETURN g_asg_person_name;
  --
END Get_asg_psn_nm;
--
-- -----------------------------------------------------------------------------
--
-- Get's the primary assignment supervisor's language for a given person_id
--
FUNCTION Get_asg_psn_lng(p_assignment_id     IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  cache_asg_psn_details(p_assignment_id);
  --
  IF (g_asg_person_lang IS NULL) OR
     (g_asg_person_lang = '')
  THEN
    --
    g_asg_person_lang := Get_bg_lng(g_asg_business_group_id);
    --
  END IF;
  --
  RETURN g_asg_person_lang;
  --
END Get_asg_psn_lng;
--
-- -----------------------------------------------------------------------------
--
-- Find out if we have an email address for a person's primary
-- assignment supervisor, if we have return 'Y' otherwise 'N'
--
FUNCTION Check_asg_psn_in_scope(p_assignment_id     IN NUMBER)
          RETURN NUMBER IS
  --
BEGIN
  --
  cache_asg_psn_details(p_assignment_id);
  --
  RETURN g_asg_person_email_set;
  --
END Check_asg_psn_in_scope;
--
-- -----------------------------------------------------------------------------
--
-- Find out if the assignment has a current primary assignment supervisor
--
FUNCTION Check_pasg_sup_available(p_assignment_id IN NUMBER)
          RETURN NUMBER IS
  --
BEGIN
  --
  cache_pasg_sup_details(p_assignment_id);
  --
  RETURN g_pasg_sup_person_available;
  --
END Check_pasg_sup_available;
--
-- -----------------------------------------------------------------------------
--
-- Find out if the assignment has a current supervisor
--
FUNCTION Check_asg_sup_available(p_assignment_id IN NUMBER)
          RETURN NUMBER IS
  --
BEGIN
  --
  cache_asg_sup_details(p_assignment_id);
  --
  RETURN g_asg_sup_person_available;
  --
END Check_asg_sup_available;
--
END HR_BPL_ALERT_RECIPIENT;

/
