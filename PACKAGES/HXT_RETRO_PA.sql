--------------------------------------------------------
--  DDL for Package HXT_RETRO_PA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_RETRO_PA" AUTHID CURRENT_USER AS
/* $Header: hxtrpa.pkh 120.0 2005/05/29 05:55:39 appldev noship $ */
  g_user_id	        fnd_user.user_id%TYPE    := fnd_global.User_Id;
  g_sysdate	        DATE 		        := trunc(SYSDATE);
  g_batch_err_id        hxt_errors.ppb_id%TYPE   DEFAULT NULL;
  g_timecard_err_id     hxt_errors.tim_id%TYPE   DEFAULT NULL;
  g_sum_hours_err_id    hxt_errors.hrw_id%TYPE   DEFAULT NULL;
  g_time_period_err_id  hxt_errors.ptp_id%TYPE   DEFAULT NULL;
  g_err_effective_start DATE			DEFAULT TRUNC(SYSDATE);
  g_err_effective_end   DATE                    DEFAULT hr_general.end_of_time; --sir149 --FORMS60

  g_error_log_error    EXCEPTION;
  g_hours_per_year     NUMBER                  := FND_PROFILE.Value( 'HXT_HOURS_PER_YEAR' );

PROCEDURE retro_pa_process(	o_err_buf OUT NOCOPY VARCHAR2,
				o_ret_code OUT NOCOPY NUMBER,
				i_payroll_id IN NUMBER,
              	       		i_time_period_id IN NUMBER);

FUNCTION retro_non_ewr_transfer(i_timecard_id IN NUMBER,
			  	   i_ending_date IN DATE,
				   i_annual_pay_periods IN NUMBER,
                                   i_employee_number IN VARCHAR2,
				   o_location OUT NOCOPY VARCHAR2,
				   o_error_text OUT NOCOPY VARCHAR2,
				   o_system_text OUT NOCOPY VARCHAR2)RETURN NUMBER;

FUNCTION log_transfer_errors(	i_location IN VARCHAR2,
				i_error_text IN VARCHAR2,
			        i_system_text IN VARCHAR2)RETURN NUMBER;

END HXT_RETRO_PA;

 

/
