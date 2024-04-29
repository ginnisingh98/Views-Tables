--------------------------------------------------------
--  DDL for Package Body PA_PERF_STATUS_CLIENT_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PERF_STATUS_CLIENT_EXTN" AS
/* $Header: PAPESCLB.pls 120.0 2005/05/30 12:00:02 appldev noship $ */

/*======================Beginning of code====================================+

 The following code demonstrate how you can use the client extension
 to customize the logic to obtain the overall project performance status

 It implements the default logic MIN, which returns the most severe indicator
 for a given project.
+============================================================================*/

	function get_performance_status
	(
	  p_object_type in VARCHAR2          --- PA_PROJECTS
	, p_object_id in NUMBER              --- PROJECT_ID
	, p_kpa_summary  in pa_exception_engine_pkg.summary_table
	 )RETURN varchar2
	  IS
	     --- cursor to get the severity level of a indicator code
	     --- the severity level is from 1 to 5, 1 being the most severe

	     CURSOR get_severity(indicator_code IN VARCHAR2)
	       IS
		  SELECT To_number(predefined_flag) FROM pa_lookups
		    WHERE lookup_type = 'PA_PERF_INDICATORS'
		    AND lookup_code = indicator_code;

	     l_lowest_severity NUMBER := 100;

	     l_ind VARCHAR2(30);

	     l_severity NUMBER := NULL ;

	BEGIN

	   --- the default logic for getting the overall performance status
	   --- is to do a MIN
           --- MIN is taking the worst case scenario. The color indicator associated with
	   --- lowest severity number (which means the highest severity) will be returned.

	   --- when there is no color indicator passed to the function, we will return NULL
	   IF p_kpa_summary IS NULL THEN
	      RETURN NULL;

	   END IF;

	   --- loop through all indicators and find the most severe one
	   FOR i IN p_kpa_summary.first..p_kpa_summary.last LOOP

	      OPEN get_severity(p_kpa_summary(i).indicator_code);
	      FETCH get_severity INTO l_severity;

	      IF (get_severity%found) then

		 IF (l_severity IS NOT NULL AND l_severity < l_lowest_severity) THEN
		    --- find a more severe indicator, save it to the local variable
		    l_lowest_severity := l_severity;
		    l_ind := p_kpa_summary(i).indicator_code;
		 END IF;

	      END IF;

	      CLOSE get_severity;

	   END LOOP;

	   IF l_lowest_severity = 100 THEN
	      --- if the MIN logic has not found any indicator, return NULL
	      RETURN NULL;
	    ELSE
	      --- return the most severe indicator
	      RETURN l_ind;
	   END IF;




	EXCEPTION

	   WHEN NO_DATA_FOUND THEN

	      RETURN NULL;

	   WHEN OTHERS THEN
	      RETURN NULL;

	END;


END pa_perf_status_client_extn;

/
