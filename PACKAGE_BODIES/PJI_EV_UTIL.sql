--------------------------------------------------------
--  DDL for Package Body PJI_EV_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_EV_UTIL" AS
-- $Header: PJIPREVB.pls 120.1 2005/09/16 15:25:12 appldev noship $

PROCEDURE populate_percent_complete
	(p_start_date           IN VARCHAR2,
	 p_end_date             IN VARCHAR2,
	 p_calendar_id          IN NUMBER,
	 p_slice_name           IN VARCHAR2,
	 p_project_id           IN VARCHAR2,
	 p_proj_element_id      IN VARCHAR2,
	 p_structure_version_id	IN	NUMBER,
	p_include_sub_tasks_flag	IN VARCHAR2 ,
	p_calendar_type	IN VARCHAR2,
	p_prg_flag IN VARCHAR2,
	 x_msg_count            IN OUT NOCOPY NUMBER,
	 x_return_status        OUT NOCOPY VARCHAR2,
	 x_err_msg_data         OUT NOCOPY VARCHAR2)
  IS
  l_completed_per       NUMBER ;
  l_object_type pa_proj_elements.object_type%TYPE;
  l_calendar_type pji_fp_xbs_accum_f.calendar_type%TYPE := p_calendar_type;

	 CURSOR ent_periods IS
	SELECT ent_period_id period_id , end_date
	FROM pji_time_ent_period_v
	WHERE end_date >= TO_DATE(p_start_date,'j')
	AND start_date <= TO_DATE(p_end_date,'j')
	AND 'PJI_TIME_ENT_PERIOD_V'=p_slice_name
	UNION ALL
	SELECT ent_qtr_id period_id , end_date
	FROM pji_time_ent_qtr_v
	WHERE end_date >= TO_DATE(p_start_date,'j')
	AND start_date <= TO_DATE(p_end_date,'j')
	AND 'PJI_TIME_ENT_QTR_V'=p_slice_name
	UNION ALL
	SELECT ent_year_id period_id , end_date
	FROM pji_time_ent_year_v
	WHERE end_date >= TO_DATE(p_start_date,'j')
	AND start_date <= TO_DATE(p_end_date,'j')
	AND 'PJI_TIME_ENT_YEAR_V'=p_slice_name
	ORDER BY period_id;

	CURSOR gl_pa_periods IS
	SELECT cal_period_id period_id , end_date
	FROM pji_time_cal_period_v
	WHERE end_date >= TO_DATE(p_start_date,'j')
	AND start_date <= TO_DATE(p_end_date,'j')
	AND calendar_id=p_calendar_id
	AND 'PJI_TIME_CAL_PERIOD_V'=p_slice_name
	UNION ALL
	SELECT cal_qtr_id period_id , end_date
	FROM pji_time_cal_qtr_v
	WHERE end_date >= TO_DATE(p_start_date,'j')
	AND start_date <= TO_DATE(p_end_date,'j')
	AND calendar_id=p_calendar_id
	AND 'PJI_TIME_CAL_QTR_V'=p_slice_name
	UNION ALL
	SELECT cal_year_id period_id , end_date
	FROM pji_time_cal_year_v
	WHERE end_date >= TO_DATE(p_start_date,'j')
	AND start_date <= TO_DATE(p_end_date,'j')
	AND calendar_id=p_calendar_id
	AND 'PJI_TIME_CAL_YEAR_V'=p_slice_name
	ORDER BY period_id;

CURSOR object_type IS
	SELECT object_type
	FROM pa_proj_elements
	WHERE proj_element_id =  p_proj_element_id
	AND project_id =  p_project_id ;


  BEGIN
       x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

	OPEN object_type;
	FETCH object_type INTO  l_object_type;
	CLOSE object_type;

	DELETE PJI_PRD_PER_COMPLETE_TMP;

/* If calendar is enterprise, then open the corresponding cursor and fetch the percent complete */
       IF (l_calendar_type = 'E')
        THEN

			  FOR rec_ent_periods IN  ent_periods LOOP
			  	  IF p_prg_flag = 'N' THEN
					 l_completed_per := Pa_Progress_Utils.get_pc_from_sub_tasks_assgn
											(p_project_id
											,p_proj_element_id
											,p_structure_version_id
											,p_include_sub_tasks_flag
											,'FINANCIAL'
											,l_object_type
											,rec_ent_periods.end_date);
				  ELSE
				  	  l_completed_per := NULL;
				  END IF;

				INSERT INTO PJI_PRD_PER_COMPLETE_TMP (period_id,completed_percentage) VALUES
				(rec_ent_periods.period_id,l_completed_per);

			END LOOP;


	/* else fetch data for pa and gl calendars */
	ELSE


			  FOR rec_gl_pa_periods IN gl_pa_periods LOOP
			  	 IF p_prg_flag = 'N' THEN
					 l_completed_per  := Pa_Progress_Utils.get_pc_from_sub_tasks_assgn
											(p_project_id
											,p_proj_element_id
											,p_structure_version_id
											,p_include_sub_tasks_flag
											,'FINANCIAL'
											,l_object_type
											,rec_gl_pa_periods.end_date);
				 ELSE
				 	 l_completed_per := NULL;
			     END IF;

				INSERT INTO PJI_PRD_PER_COMPLETE_TMP (period_id,completed_percentage) VALUES
				(rec_gl_pa_periods.period_id,l_completed_per );


			END LOOP;


	END IF;


   EXCEPTION
   WHEN OTHERS THEN
       x_return_status :=  Fnd_Api.G_RET_STS_UNEXP_ERROR;
       x_msg_count := x_msg_count + 1;
       RAISE;

END populate_percent_complete;


END Pji_Ev_Util;

/
