--------------------------------------------------------
--  DDL for Package Body HR_MISC_WEB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_MISC_WEB" AS
/* $Header: hrmscmnw.pkb 120.1 2005/09/23 15:05:51 svittal noship $*/


--------------------------------------------------------------------------------
-- Private Global Variables
--------------------------------------------------------------------------------
  gv_PACKAGE_NAME     CONSTANT VARCHAR2(30)   := 'hr_misc_web';




/*
||===========================================================================
|| PROCEDURE: remove_transaction
||----------------------------------------------------------------------------
||
|| Description:
||      This procedure removes transaction steps, transaction step values
||      and transaction id on Cancel or Exit to Main Menu.
||
|| Pre-Conditions:
||
|| Input Parameters:
||
|| Output Parameters:
||
|| In out nocopy Parameters:
||
|| Post Success:
||
||
|| Post Failure:
||     Raise exception.
||
|| Access Status:
||     Public
||
||=============================================================================
*/

  PROCEDURE remove_transaction(
               p_item_type    in varchar2
              ,p_item_key     in varchar2
              ,p_actid        in number
         )
  IS
  --
  l_index               integer default 0;
  ltt_trans_id_tbl        g_number_tbl_type
                          default g_number_tbl_default;
  --

 CURSOR get_transaction_id (
             p_item_type    in varchar2
            ,p_item_key     in varchar2
            ,p_actid        in number
         )
  IS
  SELECT distinct hats.transaction_id
  FROM   hr_api_transaction_steps  hats
  WHERE  hats.item_type  = p_item_type
  AND    hats.item_key = p_item_key
  AND    hats.activity_id = p_actid
  ORDER  by hats.transaction_id;
Begin
  --
  savepoint cleanup_transaction;
  --
  -- There may be multiple transaction_id associated to p_item_type and
  -- p_item_key.  We need to get all transaction_id's first.
  --
  l_index := 0;
  FOR csr1 in get_transaction_id(p_item_type => p_item_type
                                   ,p_item_key  => p_item_key
                                   ,p_actid     => p_actid)
  LOOP
      l_index := l_index + 1;
      ltt_trans_id_tbl(l_index) := csr1.transaction_id;
  END LOOP;
  --
  IF l_index > 1 THEN
        FOR i in 1..l_index LOOP
            hr_transaction_api.rollback_transaction
              (p_transaction_id => ltt_trans_id_tbl(i));
        END LOOP;
  ELSIF l_index = 1 THEN
        hr_transaction_api.rollback_transaction
              (p_transaction_id => ltt_trans_id_tbl(l_index));
  ELSE
        null;
  END IF;
  --
  Exception
    When others then
      rollback to cleanup_transaction;
      raise;
--
--
End remove_transaction;


  /*
  ||===========================================================================
  || FUNCTION: get_language_code
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This function returns the current language code.
  ||     Example:-   US  -  United States
  ||                 JP  -  Japan
  ||                 UK  -  United Kingdom
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  FUNCTION get_language_code
  RETURN VARCHAR2
  IS
  BEGIN

    RETURN (icx_sec.getID(icx_sec.PV_LANGUAGE_CODE));

  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.trace(' Exception in hr_misc_web.get_language_code ' || SQLERRM);
  END get_language_code;


  /*
  ||===========================================================================
  || FUNCTION: get_image_directory
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This function returns the image directory.
  ||     Example:-  '/OA_MEDIA/US/' in r11
  ||                '/OA_MEDIA/' in r115
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  FUNCTION get_image_directory
  RETURN VARCHAR2
  IS
  BEGIN

    RETURN hr_util_misc_web.get_image_directory;

  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.trace(' Exception in hr_misc_web.get_image_directory ' || SQLERRM);
  END get_image_directory;


  /*
  --===========================================================================
  --|| PROCEDURE: get_sshr_segment_value
  --||-------------------------------------------------------------------------
  --||
  --|| Description:
  --||     This procedure retrieves the segment value of input parameter
  --||     p_user_column_name from the context "SSHR Information"
  --||
  --||
  --|| Pre-Conditions: See the context "SSHR Information" is added.
  --||
  --|| Input Parameters: Business Group Id, User Segment Name
  --||
  --|| Output Parameters: Segment Value  of the input parameter.
  --||
  --|| In Out Parameters:
  --||
  --|| Post Success:
  --||      Exit to Main Menu
  --||
  --|| Post Failure:
  --||     Raise exception.
  --||
  --|| Access Status:
  --||     Public
  --||
  --||===========================================================================
  */

    FUNCTION   get_sshr_segment_value
     ( p_bg_id IN per_all_people_f.business_group_id%TYPE DEFAULT NULL,
       p_user_column_name IN varchar2 )
  RETURN VARCHAR2
     IS

     CURSOR get_org_column_name (
      user_column_name  VARCHAR2
     )
     IS
     select application_column_name
     from FND_DESCR_FLEX_COLUMN_USAGES
     where descriptive_flex_context_code = 'SSHR Information'
     and end_user_column_name = user_column_name
-- ***** Start new code for bug 2731002 *****
     and application_id=800
     and descriptive_flexfield_name='Org Developer DF';
-- ***** End new code for bug 2731002 *****

     col_name        fnd_descr_flex_column_usages.application_column_name%TYPE DEFAULT NULL;
     v_BlockStr VARCHAR2(500);
     v_ColName  VARCHAR2(100);
     v_BusGrpID NUMBER;
     v_segment_value VARCHAR2(200) DEFAULT NULL;

  BEGIN


      OPEN  get_org_column_name ( p_user_column_name );
      FETCH get_org_column_name INTO col_name;

      IF get_org_column_name%NOTFOUND
      THEN
        v_segment_value := NULL;
        CLOSE get_org_column_name;
        RETURN v_segment_value;
      ELSE
        CLOSE get_org_column_name;

        v_BlockStr :=     ' select ' || col_name ||
                          ' from hr_organization_information hoi ' ||
                          ' where hoi.organization_id = :1 '||
                          ' and hoi.org_information_context = ' ||'''SSHR Information''';

         -- Fix 3666171.
        BEGIN
        	EXECUTE IMMEDIATE v_BlockStr INTO v_segment_value USING p_bg_id;
       EXCEPTION
        WHEN NO_DATA_FOUND THEN
        v_segment_value := null;
        END;

          IF v_segment_value = '' THEN
              v_segment_value := NULL;
          END IF;
    END IF;
      RETURN v_segment_value;
  EXCEPTION
      WHEN OTHERS THEN
        IF get_org_column_name%isopen then
          close get_org_column_name;
        end if;
        hr_utility.trace(' Exception in hr_misc_web.get_target ' || SQLERRM);
  END get_sshr_segment_value;


  /*
  --===========================================================================
  --|| PROCEDURE: get_user_defined_job_segments
  --||-------------------------------------------------------------------------
  --||
  --|| Description:
  --||     This derives the Job Name according to the segments specified in
  --||     the p_job_segments. If p_job_segments is NULL then it returns
  --||     p_job_name as it is or if p_job_name is NULL or empty it returns
  --||     p_job_name as it is.
  --||
  --||
  --|| Pre-Conditions: See the context "SSHR Information" is added
  --||                 and the segment "Display MEE Job Segments" if want any
  --||                 configuration.
  --||
  --|| Input Parameters: segment string, job_name, job_id
  --||
  --|| Output Parameters: derived Job Name
  --||
  --|| In Out Parameters:
  --||
  --|| Post Success:
  --||      Exit to Main Menu
  --||
  --|| Post Failure:
  --||     Raise exception.
  --||
  --|| Access Status:
  --||     Public
  --||
  --||==========================================================================
  */

   FUNCTION  get_user_defined_job_segments
     ( p_job_segments IN varchar2 DEFAULT NULL,
       p_job_name IN per_jobs.name%TYPE DEFAULT NULL,
       p_job_id IN per_jobs.job_id%TYPE DEFAULT NULL)
     RETURN VARCHAR2
     IS

     v_BlockStr VARCHAR2(500);
     v_ColName  VARCHAR2(100);
     v_BusGrpID NUMBER;
     job_select_segments VARCHAR2(500) DEFAULT NULL;
     v_segment_value VARCHAR2(1000) DEFAULT NULL;
     --p_job_segments VARCHAR2(500) DEFAULT NULL;
     --p_job_id NUMBER DEFAULT NULL;

  BEGIN

      IF ( p_job_segments is NULL OR (length(p_job_segments) = 0)
           OR p_job_name is NULL OR  (length(p_job_name) = 0))
      THEN
          RETURN p_job_name;
      END IF;

      job_select_segments := replace(p_job_segments,'|','||''.''||');

      v_BlockStr :=   ' SELECT ' || job_select_segments ||
                      ' FROM per_job_definitions pjd, per_jobs pj ' ||
                      ' WHERE pjd.job_definition_id = pj.job_definition_id ' ||
                      ' AND pj.job_id = :1';

        -- Fix 3666171.
        BEGIN
        	EXECUTE IMMEDIATE v_BlockStr INTO v_segment_value USING p_job_id;
       EXCEPTION
        WHEN NO_DATA_FOUND THEN
        v_segment_value := null;
        END;

        IF v_segment_value = ''
        THEN
            v_segment_value := NULL;
        ELSE
            WHILE(INSTR(v_segment_value,'..',1,1) > 0)
            LOOP
              v_segment_value := replace(v_segment_value,'..','.');
            END LOOP;

            IF( INSTR(v_segment_value,'.',-1,1 ) = length(v_segment_value)) THEN
              v_segment_value := substr(v_segment_value,1,
					length(v_segment_value)-1);
            END IF;
        END IF;


      RETURN v_segment_value;


      EXCEPTION
      WHEN OTHERS THEN
	hr_utility.trace(' Exception in hr_misc_web.get_target ' || SQLERRM );
      raise;
  END get_user_defined_job_segments;



  /*
  --===========================================================================
  --|| PROCEDURE: get_job_segments
  --||-------------------------------------------------------------------------
  --||
  --|| Description:
  --||     Utility method used in V4 to get User Defined Job Segments.
  --||
  --||
  --|| Pre-Conditions: See the context "SSHR Information" is added
  --||                 and the segment "Display MEE Job Segments" if want any
  --||                 configuration.
  --||
  --|| Input Parameters: p_bg_id, job_name, job_id
  --||
  --|| Output Parameters: derived Job Name
  --||
  --|| In Out Parameters:
  --||
  --|| Post Success:
  --||
  --|| Post Failure:
  --||     Raise exception.
  --||
  --|| Access Status:
  --||     Public
  --||
  --||==========================================================================
  */


  FUNCTION   get_job_segments
     ( p_bg_id IN per_all_people_f.business_group_id%TYPE,
       p_job_id IN hr_organization_units.organization_id%TYPE,
       p_job_name IN hr_organization_units.name%TYPE)
  RETURN VARCHAR2
  IS
     sshr_segment            VARCHAR2(500) DEFAULT NULL;
     job_segments            VARCHAR2(500) DEFAULT '';
  BEGIN

     sshr_segment := hr_misc_web.get_sshr_segment_value
                                   ( p_bg_id,
                                     p_user_column_name => 'Display MEE Job Segments');

     IF ( (length(sshr_segment)>0) OR sshr_segment is not NULL) THEN
        job_segments := hr_misc_web.get_user_defined_job_segments
                                   ( p_job_segments => sshr_segment,
                                     p_job_id => p_job_id,
                                     p_job_name => p_job_name);

     END IF;


     RETURN  job_segments;

     EXCEPTION
       WHEN OTHERS THEN
       raise;
  END    get_job_segments;








  /*
  ||===========================================================================
  || FUNCTION: get_person_details
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This function will return details pertaining to the passed
  ||     person ID. It will return a record structure.
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  FUNCTION get_person_details (
    p_person_id    IN per_people_f.person_id%TYPE
  )
  RETURN hr_misc_web.grt_person_details
  IS

    -- Local Variables.
    lrt_person_details  hr_misc_web.grt_person_details;
--
--1839081
--
    CURSOR lc_person_details (
             p_person_id    IN per_people_f.person_id%TYPE
           ) IS
    SELECT full_name,
           business_group_id
    FROM   per_all_people_f
    WHERE  person_id = p_person_id
      AND  TRUNC(SYSDATE) BETWEEN effective_start_date
                          AND     NVL(effective_end_date, TRUNC(SYSDATE));

  BEGIN

    OPEN lc_person_details (p_person_id  => p_person_id);

    FETCH lc_person_details INTO
      lrt_person_details.full_name,
      lrt_person_details.business_group_id;

    CLOSE lc_person_details;

    RETURN lrt_person_details;

  EXCEPTION
    WHEN OTHERS THEN
      CLOSE lc_person_details;
      hr_utility.trace(' hr_misc_web.get_person_details ' || SQLERRM );

  END get_person_details;


  /*
  ||===========================================================================
  || FUNCTION: get_assignment_details
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This function will return details pertaining to the passed
  ||     assignment ID. It will return a record structure.
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  FUNCTION get_assignment_details (
    p_assignment_id    IN per_assignments_f.assignment_id%TYPE,
    p_effective_date   IN DATE
  )
  RETURN hr_misc_web.grt_assignment_details
  IS

    -- Local Variables.
    lrt_assignment_details  hr_misc_web.grt_assignment_details;
    lrt_empty               hr_misc_web.grt_assignment_details;

    CURSOR lc_assignment_details (
             p_assignment_id   IN per_assignments_f.assignment_id%TYPE,
             p_effective_date  IN DATE
           ) IS
    SELECT ppf.person_id,
           ppf.full_name,
           paf.assignment_number,
           paf.business_group_id,
           paf.effective_start_date,
           paf.effective_end_date,
           paf.payroll_id,
           paf.location_id,
           paf.primary_flag,
           paf.object_version_number
    FROM   per_all_people_f ppf,
           per_all_assignments_f paf
    WHERE  paf.assignment_id     = p_assignment_id
      AND  paf.person_id         = ppf.person_id
      AND  p_effective_date BETWEEN paf.effective_start_date
                                AND NVL(paf.effective_end_date, TRUNC(SYSDATE))
      AND  p_effective_date BETWEEN ppf.effective_start_date
                                AND NVL(ppf.effective_end_date, TRUNC(SYSDATE))
    ORDER BY paf.effective_start_date DESC;

    ---------------------------------------------------------------------------
    -- Bug 1803576 Fix:
    -- With global supervisor and cross business group, the comparison of
    -- the subordinate's business_group_id with the supervisor's bg id will
    -- result in no records found.  The reason is that the global supervisor's
    -- business_group_id will never be equal to the subordinate's bg id.  We
    -- don't need to compare the bg id here as long as the records are joined
    -- by person_id.  Thus, remove the AND clause:
    --  "paf.business_group_id + 0 = ppf.business_group_id + 0".
    ---------------------------------------------------------------------------

    --
    -- 1839081
    --
    CURSOR lc_supervisor_details (
             p_assignment_id   IN per_assignments_f.assignment_id%TYPE,
             p_effective_date  IN DATE
           ) IS
    SELECT ppf.person_id,
           ppf.full_name
    FROM   per_all_people_f ppf,
           per_all_assignments_f paf
    WHERE  paf.assignment_id     = p_assignment_id
      AND  paf.supervisor_id     = ppf.person_id
--      AND  paf.primary_flag      = 'Y' -- To supprot multiple assignments
      AND  p_effective_date BETWEEN paf.effective_start_date
                                AND NVL(paf.effective_end_date, TRUNC(SYSDATE))
      AND  p_effective_date BETWEEN ppf.effective_start_date
                                AND NVL(ppf.effective_end_date, TRUNC(SYSDATE))
    ORDER BY paf.effective_start_date DESC;


    --
    -- 1839081
    --
    CURSOR lc_job_details (
             p_assignment_id   IN per_assignments_f.assignment_id%TYPE,
             p_effective_date  IN DATE
           ) IS
    SELECT pj.job_id,
           pj.name
    FROM   per_jobs_vl pj,
           per_all_assignments_f paf
    WHERE  paf.assignment_id     = p_assignment_id
      AND  paf.job_id            = pj.job_id
--      AND  paf.primary_flag      = 'Y' -- To supprot multiple assignments
      AND  paf.business_group_id+0 = pj.business_group_id+0
      AND  p_effective_date BETWEEN paf.effective_start_date
                                AND NVL(paf.effective_end_date, TRUNC(SYSDATE))
    ORDER BY paf.effective_start_date DESC;


    --
    -- 1839081
    --
    CURSOR lc_loc_details (
             p_assignment_id   IN per_assignments_f.assignment_id%TYPE,
             p_effective_date  IN DATE
           ) IS
    SELECT hl.location_id,
           hl.location_code
    FROM   hr_locations hl,
           per_all_assignments_f paf
    WHERE  paf.assignment_id     = p_assignment_id
      AND  paf.location_id       = hl.location_id
--      AND  paf.primary_flag      = 'Y' -- To supprot multiple assignments
      AND  p_effective_date BETWEEN paf.effective_start_date
                                AND NVL(paf.effective_end_date, TRUNC(SYSDATE))
    ORDER BY paf.effective_start_date DESC;


    --
    -- 1839081
    --
    CURSOR lc_organization_details (
             p_assignment_id   IN per_assignments_f.assignment_id%TYPE,
             p_effective_date  IN DATE
           ) IS
    SELECT hou.organization_id,
           hou.name
    FROM   hr_organization_units hou,
           per_all_assignments_f paf
    WHERE  paf.assignment_id     = p_assignment_id
      AND  paf.organization_id   = hou.organization_id
--      AND  paf.primary_flag      = 'Y' -- To supprot multiple assignments
      AND  paf.business_group_id+0 = hou.business_group_id+0
      AND  p_effective_date BETWEEN paf.effective_start_date
                                AND NVL(paf.effective_end_date, TRUNC(SYSDATE))
    ORDER BY paf.effective_start_date DESC;

  BEGIN

    OPEN lc_assignment_details (
           p_assignment_id  => p_assignment_id,
           p_effective_date => p_effective_date
         );
    FETCH lc_assignment_details INTO
      lrt_assignment_details.person_id,
      lrt_assignment_details.person_full_name,
      lrt_assignment_details.assignment_number,
      lrt_assignment_details.business_group_id,
      lrt_assignment_details.effective_start_date,
      lrt_assignment_details.effective_end_date,
      lrt_assignment_details.payroll_id,
      lrt_assignment_details.location_id,
      lrt_assignment_details.primary_flag,
      lrt_assignment_details.object_version_number;
    CLOSE lc_assignment_details;

    OPEN lc_supervisor_details (
           p_assignment_id  => p_assignment_id,
           p_effective_date => p_effective_date
         );
    FETCH lc_supervisor_details INTO
      lrt_assignment_details.supervisor_id,
      lrt_assignment_details.supervisor_full_name;
    CLOSE lc_supervisor_details;


    OPEN lc_job_details (
           p_assignment_id  => p_assignment_id,
           p_effective_date => p_effective_date
         );
    FETCH lc_job_details INTO
      lrt_assignment_details.job_id,
      lrt_assignment_details.job_name;
    CLOSE lc_job_details;


    OPEN lc_organization_details (
           p_assignment_id  => p_assignment_id,
           p_effective_date => p_effective_date
         );
    FETCH lc_organization_details INTO
      lrt_assignment_details.organization_id,
      lrt_assignment_details.organization_name;
    CLOSE lc_organization_details;

    RETURN (lrt_assignment_details);

  EXCEPTION
    WHEN OTHERS THEN
      CLOSE lc_assignment_details;
      CLOSE lc_supervisor_details;
      CLOSE lc_job_details;
      CLOSE lc_organization_details;
      hr_utility.trace( ' hr_misc_web.get_assignment_details ' || SQLERRM );

  END get_assignment_details;


  /*
  ||===========================================================================
  || FUNCTION: get_assignment_id
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This function will return the current assignment id of the person
  ||     based on the person id.
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  FUNCTION get_assignment_id (
    p_person_id    IN per_people_f.person_id%TYPE
  )
  RETURN hr_misc_web.grt_assignment_details
  IS

    -- Local Variables.
    lrt_assignment_details  hr_misc_web.grt_assignment_details;

    --
    --1839081
    --
    CURSOR lc_get_assignment (p_person_id IN per_people_f.person_id%TYPE)
    IS
    SELECT paf.assignment_id, paf.effective_start_date
    FROM   per_all_assignments_f paf
    WHERE  paf.person_id = p_person_id
      AND  paf.primary_flag = 'Y'
     -- Fix for bug 2268056
      AND  paf.assignment_type in ('E','C')
    ORDER BY paf.effective_start_date DESC;

  BEGIN

    OPEN lc_get_assignment (
           p_person_id  => p_person_id
         );

    FETCH lc_get_assignment INTO
      lrt_assignment_details.assignment_id,
      lrt_assignment_details.effective_start_date;

    IF lc_get_assignment%NOTFOUND OR lc_get_assignment%NOTFOUND IS NULL
    THEN
      CLOSE lc_get_assignment;
      RETURN NULL;
    ELSE
      CLOSE lc_get_assignment;
    END IF;

    RETURN (lrt_assignment_details);

  EXCEPTION
    WHEN OTHERS THEN
      CLOSE lc_get_assignment;
      hr_utility.trace(' hr_misc_web.get_assignment_id ' || SQLERRM );

  END get_assignment_id;


  FUNCTION get_lookup_meaning (
    p_code        IN VARCHAR2,
    p_lookup_type IN VARCHAR2,
    p_date        IN DATE
  )
  RETURN VARCHAR2  IS

    CURSOR lc_meaning IS
      SELECT   meaning
      FROM     hr_lookups
      WHERE    LOOKUP_CODE = p_code
      AND      LOOKUP_TYPE = p_lookup_type AND
        p_date between nvl(start_date_active , p_date) AND
                     nvl(end_date_active, p_date)
      AND enabled_flag = 'Y' ;


    lv_meaning  hr_lookups.meaning%TYPE;

  BEGIN

    OPEN lc_meaning ;
    FETCH lc_meaning into lv_meaning ;
    IF lc_meaning%NOTFOUND
    THEN
      return NULL ;
    END IF ;
    CLOSE lc_meaning;

    return lv_meaning ;

    EXCEPTION
    WHEN OTHERS THEN
      CLOSE lc_meaning;
	raise;
  END get_lookup_meaning;


  /*
  ||===========================================================================
  || FUNCTION: get_enter_process_checks
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This function will return a record which will contain the data to
  ||     do the required error checking before launching a module from the
  ||     effective date dialog box.
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  FUNCTION get_enter_process_checks (
    p_assignment_id        IN NUMBER                               DEFAULT NULL,
    p_effective_date       IN DATE                                 DEFAULT NULL,
    p_enter_process_checks IN hr_misc_web.grt_enter_process_checks DEFAULT NULL
  )
  RETURN hr_misc_web.grt_enter_process_checks
  IS

    -- Local variables.
    -- Hire date

    --
    -- 1839081
    --
    CURSOR lc_hire_date
    IS
    SELECT MIN(pps.date_start)
    FROM   per_periods_of_service pps,
           per_all_assignments_f      asg
    WHERE  asg.assignment_id = p_assignment_id
    AND    asg.person_id     = pps.person_id;

    -- Termination date

    --
    -- 1839081
    -- 2173279
    -- Redefine the cursor lc_termination_date
    --
    --CURSOR lc_termination_date
    --IS
    --SELECT MAX(asg.effective_start_date)
    --FROM   per_all_assignments_f           asg,
    --       per_assignment_status_types ast
    --WHERE  asg.assignment_status_type_id = ast.assignment_status_type_id
    --AND    asg.assignment_id             = p_assignment_id
    --AND    per_system_status             = 'TERM_ASSIGN';

    CURSOR lc_termination_date IS
    select ser.actual_termination_date
    from per_periods_of_service ser,
    per_all_assignments_f ass
    where ass.period_of_service_id = ser.period_of_service_id
    AND  TRUNC(SYSDATE) between ass.effective_start_date
    AND ass.effective_end_date
    AND    ass.assignment_id  = p_assignment_id;
    -- 2173279

    -- Future assignment date

    --
    -- 1839081
    --
    CURSOR lc_future_assg_date
    IS
    SELECT MAX(effective_start_date)
    FROM   per_all_assignments_f
    WHERE  assignment_id        = p_assignment_id
    AND    effective_start_date > p_effective_date;

    ld_hire_date             DATE;
    ld_termination_date      DATE;
    ld_future_assg_date      DATE;
    lrt_enter_process_checks hr_misc_web.grt_enter_process_checks;

  BEGIN

    -- Assign all the checks to be done to the returning structure.
    lrt_enter_process_checks.hire_date :=
      p_enter_process_checks.hire_date;
    lrt_enter_process_checks.termination_date :=
      p_enter_process_checks.termination_date;
    lrt_enter_process_checks.future_assignment :=
      p_enter_process_checks.future_assignment;
    lrt_enter_process_checks.pending_workflow :=
      p_enter_process_checks.pending_workflow;
    lrt_enter_process_checks.correction_mode :=
      p_enter_process_checks.correction_mode;
    lrt_enter_process_checks.earlier_date :=
      p_enter_process_checks.earlier_date;


    -- Now get the required dates depending the checks to be made.

    -- Get the hire date of the employee.
    IF ( p_enter_process_checks.hire_date = 'Y' )
    THEN
      OPEN  lc_hire_date;
      FETCH lc_hire_date INTO ld_hire_date;
        IF lc_hire_date%NOTFOUND OR ld_hire_date IS NULL
        THEN
          ld_hire_date := NULL;
        END IF;
      CLOSE lc_hire_date;
      lrt_enter_process_checks.hire_date2 := ld_hire_date;
    ELSE
      lrt_enter_process_checks.hire_date2 := NULL;
    END IF;


    -- Get the termination date of the employee.
    IF ( p_enter_process_checks.termination_date = 'Y' )
    THEN
      OPEN  lc_termination_date;
      FETCH lc_termination_date INTO ld_termination_date;
        IF lc_termination_date%NOTFOUND OR ld_termination_date IS NULL
        THEN
          ld_termination_date := NULL;
        END IF;
      CLOSE lc_termination_date;
      lrt_enter_process_checks.termination_date2 := ld_termination_date;
    ELSE
      lrt_enter_process_checks.termination_date2 := NULL;
    END IF;



    -- Check for the existance of future dated assignment change.
    IF ( p_enter_process_checks.future_assignment = 'Y' )
    THEN
      OPEN  lc_future_assg_date;
      FETCH lc_future_assg_date INTO ld_future_assg_date;
        IF lc_future_assg_date%NOTFOUND OR ld_future_assg_date IS NULL
        THEN
          ld_future_assg_date := NULL;
        END IF;
      CLOSE lc_future_assg_date;
      lrt_enter_process_checks.future_assignment_date := ld_future_assg_date;
    ELSE
      lrt_enter_process_checks.future_assignment_date := NULL;
    END IF;


    RETURN (lrt_enter_process_checks);

  EXCEPTION

    WHEN OTHERS
    THEN
      raise;

  END get_enter_process_checks;

  /*
  ||===========================================================================
  || PROCEDURE: get_business_group_id
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This function is overloaded to get the business group id either from
  ||     the logged in person or from the selected resposibility.
  ||     Logged in Person -  This function will return the business group of
  ||                         the logged in person.
  ||     Responsibility   -  The Function call returns the Business Group ID
  ||                         for the current session's login responsibility.
  ||                         The defaulting levels are as defined in the
  ||                         package FND_PROFILE. It returns business group id
  ||                         value for a specific user/resp/appl combo.
  ||                         Default is user/resp/appl/site is current login.
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  FUNCTION get_business_group_id (
    p_person_id IN per_people_f.person_id%TYPE
  )
  RETURN per_business_groups.business_group_id%TYPE
  IS

    -- Local Variables.
    l_person_rec  per_people_f%ROWTYPE;

  BEGIN

    l_person_rec := hr_util_misc_web.get_person_rec (
                      p_effective_date => SYSDATE,
                      p_person_id      => p_person_id);

    RETURN (l_person_rec.business_group_id);

  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.trace(' Exception in  hr_misc_web.get_business_group_id ' || SQLERRM );

  END get_business_group_id;


  FUNCTION get_business_group_id
  RETURN   per_business_groups.business_group_id%TYPE
  IS

    -- Local Variables.
    ln_business_group_id  per_business_groups.business_group_id%TYPE;

  BEGIN

    fnd_profile.get (
      name => 'PER_BUSINESS_GROUP_ID',
      val  => ln_business_group_id
    );

    RETURN (ln_business_group_id);

  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.trace(' Exception in hr_misc_web.get_business_group_id ' || SQLERRM );

  END get_business_group_id;

  /*
  ||===========================================================================
  || FUNCTION: get_legislation_code
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This function will return the legislation code of a person,
  ||     an assignment, or of a business_group_id which ever is provided.
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  FUNCTION get_legislation_code (
    p_person_id         IN per_people_f.person_id%TYPE DEFAULT NULL,
    p_assignment_id     IN per_assignments_f.assignment_id%TYPE DEFAULT NULL,
    p_business_group_id IN per_business_groups.business_group_id%TYPE
                           DEFAULT NULL,
    p_effective_date    IN DATE DEFAULT SYSDATE
  )
  RETURN per_business_groups.legislation_code%TYPE
  IS

    -- Local Variables.
    l_legislation_code  VARCHAR2(150);

/*  --------------------------------------------------------------------------
    -- The following cursors are commented out because they use the
    -- per_business_groups complex views.  For better performance, they are
    -- replaced by base table which is hr_organization_information.
    --
    -- Avoid using join for better performance
    CURSOR csr_per_leg_code is
    SELECT pbg.legislation_code
    FROM   per_business_groups  pbg
    WHERE  pbg.business_group_id IN
             (SELECT per.business_group_id
              FROM   per_all_people_f per
              WHERE  per.person_id = p_person_id
                AND  TRUNC(p_effective_date) BETWEEN per.effective_start_date
                       AND NVL(per.effective_end_date, TRUNC(SYSDATE)));

    CURSOR csr_asg_leg_code is
    SELECT pbg.legislation_code
    FROM   per_business_groups pbg
    WHERE  pbg.business_group_id IN
             (SELECT paf.business_group_id
              FROM   per_all_assignments_f paf
              WHERE  paf.assignment_id = p_assignment_id
                AND  TRUNC(p_effective_date) BETWEEN paf.effective_start_date
                       AND NVL(paf.effective_end_date, TRUNC(SYSDATE)));

    CURSOR csr_bus_leg_code is
    SELECT legislation_code
    FROM   per_business_groups
    WHERE  business_group_id = p_business_group_id;

  -------------------------------------------------------------------------
*/

 -- Bug 1680269:
 -- The following cursors retrieve legislation_code information for better
 -- performance because base tables are used instead of views.  These cursors
 -- are similar to SSHR V4 common module code.
    CURSOR csr_per_leg_code is
    SELECT org.org_information9  legislation_code
    FROM   per_all_people_f             ppf
          ,hr_organization_information  org
    WHERE  org.organization_id = ppf.business_group_id
    AND    org.org_information_context = 'Business Group Information'
    AND    ppf.person_id = p_person_id
    AND    TRUNC(p_effective_date)
           BETWEEN ppf.effective_start_date
               AND ppf.effective_end_date;


    CURSOR csr_asg_leg_code is
    SELECT org.org_information9  legislation_code
    FROM   per_all_assignments_f   paf
          ,hr_organization_information  org
    WHERE  org.organization_id  = paf.business_group_id
    AND    org.org_information_context = 'Business Group Information'
    AND    paf.assignment_id = p_assignment_id
    AND    TRUNC(p_effective_date)
            BETWEEN paf.effective_start_date
                AND paf.effective_end_date;

    CURSOR csr_bus_leg_code is
    SELECT org_information9  legislation_code
    FROM   hr_organization_information
    WHERE  org_information_context = 'Business Group Information'
    and organization_id = p_business_group_id;

  BEGIN

    IF p_person_id IS NOT NULL
    THEN
      OPEN  csr_per_leg_code;
      FETCH csr_per_leg_code INTO l_legislation_code;
      CLOSE csr_per_leg_code;
    ELSIF p_assignment_id IS NOT NULL
    THEN
      OPEN  csr_asg_leg_code;
      FETCH csr_asg_leg_code INTO l_legislation_code;
      CLOSE csr_asg_leg_code;
    ELSIF p_business_group_id IS NOT NULL
    THEN
      OPEN  csr_bus_leg_code;
      FETCH csr_bus_leg_code INTO l_legislation_code;
      CLOSE csr_bus_leg_code;
    ELSE
      l_legislation_code := NULL;
    END IF;

    RETURN l_legislation_code;

  EXCEPTION
    WHEN OTHERS THEN
    hr_utility.trace(' Exception in hr_misc_web.get_legislation_code ' || SQLERRM );

  END get_legislation_code;



END hr_misc_web;

/
