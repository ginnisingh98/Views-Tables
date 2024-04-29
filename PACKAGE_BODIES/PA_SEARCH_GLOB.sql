--------------------------------------------------------
--  DDL for Package Body PA_SEARCH_GLOB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_SEARCH_GLOB" AS
--$Header: PARIGLBB.pls 120.2 2006/06/21 04:30:14 avaithia noship $
--


PROCEDURE Check_Competence_Match(p_search_mode               IN  VARCHAR2,
                                 p_person_id                 IN  per_all_people_f.person_id%TYPE,
                                 p_requirement_id            IN  pa_project_assignments.assignment_id%TYPE,
                                 x_mandatory_match           OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 x_mandatory_count           OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 x_optional_match            OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 x_optional_count            OUT NOCOPY NUMBER) IS --File.Sql.39 bug 4440895


BEGIN

   --get mandatory and optional competence count for the requirement id
   SELECT nvl(sum(decode(mandatory,'Y',1,0)),0), nvl(sum(decode(mandatory,'N',1,0)),0) INTO x_mandatory_count, x_optional_count
     FROM per_competence_elements pce
    WHERE pce.object_name = 'OPEN_ASSIGNMENT'
      AND pce.object_id = p_requirement_id;

   --if the requirement has any competencies then get the mandatory/optional competence match
   --for the requirement / resource
   IF (x_mandatory_count > 0 OR x_optional_count > 0) THEN

      --do mandatory and optional match
      SELECT nvl(sum(decode(pce.mandatory,'Y',1,0)),0), nvl(sum(decode(pce.mandatory,'N',1,0)),0) INTO x_mandatory_match, x_optional_match
        FROM per_competence_elements pce,
             per_competence_elements pce2,
             per_rating_levels prl,
             per_rating_levels prl2
       WHERE pce.object_id = p_requirement_id
         AND pce.object_name = 'OPEN_ASSIGNMENT'
         AND pce.proficiency_level_id = prl.rating_level_id(+)
         AND pce.competence_id = pce2.competence_id
         AND pce2.person_id = p_person_id
         AND pce2.proficiency_level_id = prl2.rating_level_id(+)
         AND decode(prl2.step_value, NULL, decode(prl.step_value, NULL, -999,  PA_SEARCH_GLOB.get_min_prof_level(pce2.competence_id)), prl2.step_value) >= nvl(prl.step_value, nvl(prl2.step_value , -999));

   ELSE
      x_mandatory_match :=0;
      x_optional_match := 0;

   END IF;

  EXCEPTION WHEN OTHERS THEN
     RAISE;

END;

FUNCTION Check_Availability ( p_resource_id     IN NUMBER,
                              p_assignment_id   IN NUMBER,
                              p_project_id      IN NUMBER
	     ) RETURN NUMBER IS


--declare local variables.
l_availability    NUMBER;
l_assignment_days NUMBER;
l_person_id       NUMBER;

--The availability is calculated on a daily basis.
--The resource avail hours is divided by the assignment hours
--for each day, summed up and then divided by	 the total number of assignment days
--with non-zero hours.  We need to divide by l_assignment_days because days
--for which a resource has 0 hours will not be in the forecast items table,
--but we need to take those days into account for the availability calculation
--as the assignment does have hours on that day - basically we need to average
--in 0 for those days - this is taken care of by dividing by l_assignment_days
--as opposed to dividing by the number of days which make the join below.

  -- Bug 3182120: DIFF CAND SCORE OBTAINED FOR SAME EMP IN AUTO/MANUAL SEARCH
  -- This API should return the Definite Availability.
  CURSOR check_availability(p_assignment_days NUMBER) IS
  SELECT res.person_id, TRUNC(SUM(DECODE(SIGN(
         (nvl(res.capacity_quantity, 0) - nvl(res.confirmed_qty, 0))/
          asgmt.item_quantity-1),1, 1,
         greatest((nvl(res.capacity_quantity, 0) -
                    nvl(res.confirmed_qty, 0)), 0)/ asgmt.item_quantity))/
          l_assignment_days * 100)
    FROM PA_FORECAST_ITEMS res,
         PA_FORECAST_ITEMS asgmt
   WHERE res.resource_id = p_resource_id
     AND res.forecast_item_type = 'U'
     AND res.delete_flag = 'N'
     AND res.item_date = asgmt.item_date
     AND asgmt.assignment_id = p_assignment_id
     AND asgmt.delete_flag = 'N'
     AND asgmt.error_flag IN ('Y','N')
     AND asgmt.item_date >= trunc(SYSDATE)
     AND asgmt.item_quantity > 0
GROUP BY res.person_id;

BEGIN

   --need to know the number of assignment days because the pa_forecast_items
   --table does not store unassigned time resource records with 0 hours.
   --This will be used in the following sql statement...
   SELECT count(*) INTO l_assignment_days
     FROM pa_forecast_items
    WHERE assignment_id = p_assignment_id
      AND delete_flag = 'N'
      AND error_flag IN ('Y','N')
      AND item_date >= trunc(SYSDATE)
      AND item_quantity > 0;

 IF l_assignment_days > 0 THEN

    OPEN check_availability(l_assignment_days);

    FETCH check_availability INTO l_person_id, l_availability;

    IF check_availability%NOTFOUND THEN
       CLOSE  check_availability; -- 5347525
       RETURN 0;
    END IF;

    CLOSE check_availability;

    RETURN l_availability;

 ELSE

    RETURN 0;

 END IF;

EXCEPTION

  WHEN OTHERS THEN
     -- Start : 5347525

     IF check_availability%ISOPEN THEN
	CLOSE check_availability;
     END IF;

     -- ENd : 5347525
     RAISE;

END;


FUNCTION get_min_prof_level(l_competence_id IN NUMBER)
     RETURN NUMBER IS

    l_min_rating_level NUMBER;

    BEGIN

       --get the minimum proficiency level for a given competence.
       SELECT MIN(step_value) into l_min_rating_level
         FROM per_competence_levels_v
        WHERE competence_id = l_competence_id;

       RETURN l_min_rating_level;

    EXCEPTION

    WHEN OTHERS THEN
       RAISE;

  END;


END PA_SEARCH_GLOB;

/
