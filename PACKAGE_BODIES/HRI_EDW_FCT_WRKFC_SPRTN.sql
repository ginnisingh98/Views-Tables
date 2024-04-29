--------------------------------------------------------
--  DDL for Package Body HRI_EDW_FCT_WRKFC_SPRTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_EDW_FCT_WRKFC_SPRTN" AS
/* $Header: hriefwsp.pkb 115.7 2002/02/14 00:39:19 pkm ship       $ */
  --
  g_instance_fk        VARCHAR2(40);     -- Holds data source
  --
  /* Holds stage dates and reasons for each applicant */
  g_success            NUMBER;
  g_count NUMBER := 0;
  --
  -- Holds indicator showing whether invalid separation_mode is active
  --
  g_inv_sep_mode_on    VARCHAR2(200);
  --
  -- Set up globals for the PKS for gain, recruitment and na_edw as
  -- these will not change during the session.
  --
  g_gain_type_pk       VARCHAR2(400); -- Holds gain type pk
  g_recruitment_pk     VARCHAR2(400); -- Holds recruitment stage pk
  --
  -- The primary Key that is applied to any hierarchy that is not
  -- relevant for the movement type.
  --
  g_na_edw_pk          VARCHAR2(140); -- Points to N/A row
  --
/******************************************************************************/
/* This is a dummy function which calls the calc_abv function in the business */
/* process layer. It returns the assignment budget value of an applicant      */
/* given their assignment, the vacancy they are applying for, the effective   */
/* date the budget measurement type (BMT) and the applicant's business group  */
/******************************************************************************/
FUNCTION calc_abv(p_assignment_id     IN NUMBER,
                  p_business_group_id IN NUMBER,
                  p_budget_type       IN VARCHAR2,
                  p_effective_date    IN DATE)
                  RETURN NUMBER    IS
--
  l_return_value   NUMBER := to_number(null);  -- Keeps the ABV to be returned
--
BEGIN
--
  l_return_value := hri_bpl_abv.calc_abv
        ( p_assignment_id      => p_assignment_id
        , p_business_group_id  => p_business_group_id
        , p_budget_type        => p_budget_type
        , p_effective_date     => p_effective_date );
--
RETURN l_return_value;
--
EXCEPTION
  WHEN OTHERS THEN
    RETURN to_number(null);
END calc_abv;
--
--------------------------------------------------------------------------------
--  Procedure  : find_MOVEMENT_pk
--
--  Exceptions : NA
--
--  Description: Returns the PK of the separation or potential separation
--               in the Movement Type Dimension
--
--------------------------------------------------------------------------------
--
FUNCTION find_movement_fk(p_actual_termination_date    IN DATE
                         ,p_accepted_termination_date  IN DATE
                         ,p_notified_termination_date  IN DATE
                         ,p_projected_termination_date IN DATE
                         ,p_final_process_date         IN DATE
                         ,p_reason                IN VARCHAR2
                            )
                   RETURN VARCHAR2 IS
  --
  l_return_string     VARCHAR2(800);    -- Keeps the string to return
  l_stage_type        VARCHAR2(30);     -- Holds current stage
  --
  -- Movement Type PK is made by concatenating the following primary keys
  --
  l_loss_type_pk       VARCHAR2(400); -- Holds loss type pk
  l_separation_pk      VARCHAR2(400); -- Holds separation stage pk
  --
  -- Numbers used to determine if involuntary separations are
  -- being handled,  and if so whether the current Movement is
  -- for an involuntary separation.
  --
  l_sep_rsn_type       VARCHAR2(30);
  --
  -- Describes the sort of loss that has been identified by
  -- looking at the sep dates passed in.
  --
  l_loss_type          VARCHAR2(200);
  l_loss_cat           VARCHAR2(200);
  l_loss_rsn           VARCHAR2(200);
  --
  -- Cursor that queries a table that lists all involuntary
  -- separation reasons.  This table also contains a flag
  -- to indicate if involuntary separations are being detected
  --
  CURSOR c_sep_rsn_type IS
  SELECT termination_type
  FROM hri_inv_sprtn_rsns
  WHERE reason = p_reason;
  --
BEGIN
  --
/* 115.5 - Look at final process first, then actual termination and so on */
  IF (p_final_process_date IS NOT NULL) THEN
    l_stage_type := 'FINAL';
    l_loss_cat   := 'LOSSES';
    l_loss_type  := 'LOSS_SEP';
  ELSIF (p_actual_termination_date IS NOT NULL) THEN
    l_stage_type := 'SEP';
    l_loss_cat   := 'LOSSES';
    l_loss_type  := 'LOSS_SEP';
  ELSIF (p_projected_termination_date IS NOT NULL) THEN
    l_stage_type := 'PLANNED';
    l_loss_cat   := 'POT_LOSSES';
    l_loss_type  := 'POT_SEP';
  ELSIF (p_accepted_termination_date IS NOT NULL) THEN
    l_stage_type := 'ACCEPT';
    l_loss_cat   := 'POT_LOSSES';
    l_loss_type  := 'POT_SEP';
  ELSIF (p_notified_termination_date IS NOT NULL) THEN
    l_stage_type := 'NOTIFY';
    l_loss_cat   := 'POT_LOSSES';
    l_loss_type  := 'POT_SEP';
  ELSE
  /* Is not a separation return NA_EDW */
    l_return_string := 'NA_EDW';
    RETURN l_return_string;
  END IF;
  --
  -- Check whether the reason passed in is voluntary or involuntary.
  --
  OPEN c_sep_rsn_type;
  FETCH c_sep_rsn_type INTO l_sep_rsn_type;
  CLOSE c_sep_rsn_type;
  --
  -- Is this an involuntary separation
  --
  IF (l_sep_rsn_type = 'I') THEN
    l_loss_rsn := 'SEP_INV';
  ELSIF (l_sep_rsn_type = 'V') THEN
    l_loss_rsn := 'SEP_VOL';
  ELSE
    l_loss_rsn := l_loss_type;
  END IF;
  --
  l_loss_type_pk := l_loss_cat || '-' || g_instance_fk || '-' || l_loss_type
      || '-' || g_instance_fk || '-' || l_loss_rsn || '-' || g_instance_fk;
  --
  -- Construct the Separation Component of the Movement Type PK
  --
  l_separation_pk := 'SEP_STAGE-' || g_instance_fk || '-' || l_stage_type || '-' ||
                     g_instance_fk || '-' || l_stage_type || '-' || g_instance_fk;
  --
  -- Construct the return string including the gain, loss, recruitment,
  -- and separation hierarchy PKs
  --
  l_return_string := g_gain_type_pk || '-' || l_loss_type_pk  || '-' ||
                     g_recruitment_pk || '-' || l_separation_pk || '-'
                     || g_instance_fk;
  --
  RETURN l_return_string;
  --
END find_movement_fk;
--
PROCEDURE populate_sep_rsns
IS

  l_formula_id        NUMBER;
  l_term_type         VARCHAR2(30);
  l_termination_type  VARCHAR2(30);
  l_update_allowed    VARCHAR2(30);

  CURSOR leaving_reasons_csr IS
  SELECT lookup_code
  FROM hr_lookups
  WHERE lookup_type = 'LEAV_REAS';

  CURSOR update_value_csr
  (v_reason_code    VARCHAR2)
  IS
  SELECT termination_type, update_allowed_flag
  FROM hri_inv_sprtn_rsns
  WHERE reason = v_reason_code;

BEGIN

  FOR v_leaving_reason IN leaving_reasons_csr LOOP

    l_formula_id := hr_person_flex_logic.GetTermTypeFormula
                      ( p_business_group_id => 0 );

    l_term_type  := HR_PERSON_FLEX_LOGIC.GetTermType
                      ( p_term_formula_id => l_formula_id,
                        p_leaving_reason  => v_leaving_reason.lookup_code,
                        p_session_date    => SYSDATE );

    OPEN update_value_csr(v_leaving_reason.lookup_code);
    FETCH update_value_csr INTO l_termination_type, l_update_allowed;

  /* If value does not already exist */
    IF (update_value_csr%NOTFOUND OR update_value_csr%NOTFOUND IS NULL) THEN
      CLOSE update_value_csr;
    /* Insert it */
      INSERT INTO hri_inv_sprtn_rsns
      ( reason
      , termination_type
      , update_allowed_flag )
      VALUES
        ( v_leaving_reason.lookup_code
        , l_term_type
        , 'N' );
  /* If termination type has changed and reason is updateable */
    ELSIF (l_update_allowed = 'Y' AND l_term_type <> l_termination_type) THEN
      CLOSE update_value_csr;
    /* Update the reason and reset the update allowed flag */
      UPDATE hri_inv_sprtn_rsns
      SET termination_type = l_term_type,
          update_allowed_flag = 'N'
      WHERE reason = v_leaving_reason.lookup_code;
    ELSE
      CLOSE update_value_csr;
    END IF;

  END LOOP;

END populate_sep_rsns;

PROCEDURE set_update_flag( p_reason_code     IN VARCHAR2 := NULL,
                           p_update_allowed  IN VARCHAR2)
IS

BEGIN

/* Check valid input */
  IF (p_update_allowed = 'Y' OR p_update_allowed = 'N') THEN

  /* Update table */
    UPDATE hri_inv_sprtn_rsns
    SET update_allowed_flag = p_update_allowed
    WHERE (reason = p_reason_code
      OR p_reason_code IS NULL);

  END IF;

END set_update_flag;
--
--------------------------------------------------------------------------------
--  Procedure  : populate_hri_prd_of_srvce
--
--  Exceptions : NA
--
--  Description: This procedure populates a table used by the
--               Separations Fact LCV to determine whether an assignment is
--               primary or not at each stage in the recruitment process
--
--------------------------------------------------------------------------------
--
PROCEDURE populate_hri_prd_of_srvce IS

BEGIN

/* Update reporting dates for separation stages for rows */
/* already existing in the performance table */
  UPDATE hri_edw_period_of_service hps
  SET
  (past_notified_date
  ,past_accepted_date
  ,effective_projected_date
  ,past_actual_date
  ,past_final_date) =
   (SELECT
     DECODE(SIGN(pos.notified_termination_date - sysdate),
              1, to_date(null),
            pos.notified_termination_date)
    ,DECODE(SIGN(pos.accepted_termination_date - sysdate),
              1, to_date(null),
            pos.accepted_termination_date)
    ,NVL(pos.projected_termination_date, pos.actual_termination_date)
    ,DECODE(SIGN(pos.actual_termination_date - sysdate),
              1, to_date(null),
            pos.actual_termination_date)
    ,DECODE(SIGN(pos.final_process_date - sysdate),
              1, to_date(null),
            pos.final_process_date)
    FROM per_periods_of_service   pos
    WHERE hps.period_of_service_id = pos.period_of_service_id);

-- This insert should pick up all assignment/person/period of
-- service combinations that do not exist in the performance
-- table hri_edw_period_of_service
  INSERT INTO hri_edw_period_of_service
    (assignment_id
    ,person_id
    ,period_of_service_id
    ,past_notified_date
    ,past_accepted_date
    ,effective_projected_date
    ,past_actual_date
    ,past_final_date)
  SELECT
   asg.assignment_id
  ,asg.person_id
  ,pps.period_of_service_id
  ,DECODE(SIGN(pps.notified_termination_date - sysdate),
            1, to_date(null),
          pps.notified_termination_date)
  ,DECODE(SIGN(pps.accepted_termination_date - sysdate),
            1, to_date(null),
          pps.accepted_termination_date)
  ,NVL(pps.projected_termination_date, pps.actual_termination_date)
  ,DECODE(SIGN(pps.actual_termination_date - sysdate),
            1, to_date(null),
          pps.actual_termination_date)
  ,DECODE(SIGN(pps.final_process_date - sysdate),
            1, to_date(null),
          pps.final_process_date)
  FROM
   per_all_assignments_f      asg
  ,per_periods_of_service     pps
  WHERE asg.person_id = pps.person_id
  AND asg.period_of_service_id  = pps.period_of_service_id
  AND asg.effective_start_date =
     (SELECT MAX(asg2.effective_start_date)
      FROM per_all_assignments_f asg2
      WHERE asg2.assignment_id = asg.assignment_id)
  AND NOT EXISTS (SELECT null
                  FROM hri_edw_period_of_service hps
                  WHERE hps.period_of_service_id = pps.period_of_service_id
                  AND   hps.assignment_id        = asg.assignment_id);

-- This update should pick up all the latest (date track) primary
-- primary assignment status for the point of notification
-- for each combination of assignment/person/period of service
-- that exist in the table hri_edw_period_of_service
  UPDATE hri_edw_period_of_service hps
  SET notified_trmntn_primary_flag =
            (SELECT asg.primary_flag
             FROM per_all_assignments_f   asg
             WHERE hps.past_notified_date IS NOT NULL
             AND hps.assignment_id = asg.assignment_id
             AND hps.past_notified_date
               BETWEEN asg.effective_start_date AND asg.effective_end_date);

-- This update should pick up all the latest (date track) primary
-- primary assignment status for the point of acceptance
-- for each combination of assignment/person/period of service
-- that exist in the table hri_edw_period_of_service
  UPDATE hri_edw_period_of_service hps
  SET accepted_trmntn_primary_flag =
            (SELECT asg.primary_flag
             FROM per_all_assignments_f      asg
             WHERE hps.past_accepted_date IS NOT NULL
             AND hps.assignment_id = asg.assignment_id
             AND hps.past_accepted_date
               BETWEEN asg.effective_start_date AND asg.effective_end_date);

-- This update should pick up all the latest (date track) primary
-- primary assignment status for the point of planned separation
-- for each combination of assignment/person/period of service
-- that exist in the table hri_edw_period_of_service
  UPDATE hri_edw_period_of_service hps
  SET projected_trmntn_primary_flag =
    (SELECT asg.primary_flag
     FROM per_all_assignments_f      asg
     WHERE hps.effective_projected_date IS NOT NULL
     AND hps.assignment_id = asg.assignment_id
     AND LEAST(hps.effective_projected_date, SYSDATE)
       BETWEEN asg.effective_start_date AND asg.effective_end_date);

-- This update should pick up all the latest (date track) primary
-- primary assignment status for the point of actual separation
-- for each combination of assignment/person/period of service
-- that exist in the table hri_edw_period_of_service
  UPDATE hri_edw_period_of_service hps
  SET actual_trmntn_primary_flag =
            (SELECT asg.primary_flag
             FROM per_all_assignments_f      asg
             WHERE hps.past_actual_date IS NOT NULL
             AND hps.assignment_id = asg.assignment_id
             AND hps.past_actual_date
               BETWEEN asg.effective_start_date AND asg.effective_end_date);

-- This update should pick up all the latest (date track) primary
-- primary assignment status for the point of final processing
-- for each combination of assignment/person/period of service
-- that exist in the table hri_edw_period_of_service
  UPDATE hri_edw_period_of_service hps
  SET final_process_primary_flag =
             (SELECT asg.primary_flag
              FROM per_all_assignments_f      asg
              WHERE hps.past_final_date IS NOT NULL
              AND hps.assignment_id = asg.assignment_id
              AND hps.past_final_date
                BETWEEN asg.effective_start_date AND asg.effective_end_date);

-- This update should pick up all the latest (date track) primary
-- primary assignment status for the point of the latest stage in
-- the recruitment process, for each combination of assignment/
-- person/period of service that exist in the table
-- hri_edw_period_of_service
  UPDATE hri_edw_period_of_service hps
  SET latest_stage_primary_flag =
    (SELECT asg.primary_flag
     FROM per_all_assignments_f   asg
     WHERE hps.assignment_id = asg.assignment_id
     AND NVL(hps.past_final_date,
           NVL(hps.past_actual_date,
             NVL(hps.effective_projected_date,
               NVL(hps.past_accepted_date,
                 NVL(hps.past_notified_date,sysdate)))))
          BETWEEN asg.effective_start_date AND asg.effective_end_date);
  --
END populate_hri_prd_of_srvce;
--
BEGIN
  --
  -- Get instance code
  --
  SELECT instance_code INTO g_instance_fk
  FROM edw_local_instance;
  --
  --  Set Globals up used multiple times later
  --
  --  Construct the default NA_EDW pk for any of the Movement
  --  Type hierarchies.
  --
  g_na_edw_pk := 'NA_EDW-' || g_instance_fk || '-NA_EDW-' ||
               g_instance_fk || '-NA_EDW-' || g_instance_fk;
  g_recruitment_pk := g_na_edw_pk;
  g_gain_type_pk   := g_na_edw_pk;
  --
END hri_edw_fct_wrkfc_sprtn;

/
