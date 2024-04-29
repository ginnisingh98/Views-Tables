--------------------------------------------------------
--  DDL for Package CN_PERIODS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PERIODS_API" AUTHID CURRENT_USER AS
-- $Header: cnsyprs.pls 120.3 2005/12/19 13:34:00 mblum noship $


/* ----------------------------------------------------------------------- */
  --+
  -- Procedure Name
  --   Update_GL_Status
  -- Purpose
  -- Update status in GL_PERIOD_STATUSES
  --+

  PROCEDURE update_gl_status (x_org_id             NUMBER, -- MOAC Change
                              x_period_name	   VARCHAR2,
			      x_closing_status	   VARCHAR2,
			      x_forecast_flag      VARCHAR2,
			      x_application_id	   NUMBER,
			      x_set_of_books_id    NUMBER,
			      x_freeze_flag        VARCHAR2,
			      x_last_update_date   DATE,
			      x_last_update_login  NUMBER,
			      x_last_updated_by    NUMBER) ;


/* ----------------------------------------------------------------------- */
  --+
  -- Procedure Name
  -- Check_CN_Period_Record
  -- Purpose
  -- Create a CN status record in CN_PERIOD_STATUSES if it doesn't exist.
  --+

  PROCEDURE Check_CN_Period_Record (x_org_id             NUMBER, -- MOAC Change
                                    x_period_name	 VARCHAR2,
				    x_closing_status	 VARCHAR2,
				    x_period_type	 VARCHAR2,
				    x_period_year	 NUMBER,
				    x_quarter_num        NUMBER,
				    x_period_num	 NUMBER,
				    x_period_set_name    VARCHAR2,
				    x_start_date         DATE,
				    x_end_date           DATE,
				    x_freeze_flag        VARCHAR2,
				    x_repository_id	 NUMBER) ;


  --+
  -- Procedure Name
  --   Set_Dates
  -- Purpose
  --   Return a data range.  Used by Collection/Notify code.
  --+

  PROCEDURE Set_Dates ( x_start_period_id  cn_period_statuses.period_id%TYPE,
			x_end_period_id    cn_period_statuses.period_id%TYPE,
			x_org_id           cn_period_statuses.org_id%TYPE,
			x_start_date	   OUT NOCOPY    DATE,
			x_end_date	   OUT NOCOPY    DATE) ;

  PROCEDURE populate_srp_tables(errbuf OUT NOCOPY VARCHAR2,
                                retcode OUT NOCOPY NUMBER);

  PROCEDURE populate_srp_tables_runner(errbuf OUT nocopy VARCHAR2,
				       retcode OUT nocopy NUMBER,
				       p_physical_batch_id NUMBER,
				       p_parent_proc_audit_id NUMBER);

END cn_periods_api;
 

/
