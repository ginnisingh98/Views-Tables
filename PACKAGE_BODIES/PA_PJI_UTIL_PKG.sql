--------------------------------------------------------
--  DDL for Package Body PA_PJI_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PJI_UTIL_PKG" AS
/* $Header: PAPJIUTB.pls 120.1 2005/12/30 03:03:56 degupta noship $ */

---------------------------------------------------------------------
--This package replaces the PA package created from file PAPJIUTB.pls
--The utilization details are got from PJI data model
---------------------------------------------------------------------

PROCEDURE get_utilization_dtls
  ( p_org_id               IN pa_implementations_all.org_id%TYPE
                              := NULL
   ,p_organization_id      IN hr_organization_units.organization_id%TYPE
                              := NULL
   ,p_period_type          IN pa_forecasting_options_all.org_fcst_period_type%TYPE
                              := NULL
   ,p_period_set_name      IN gl_periods.period_set_name%TYPE
                              := NULL
   ,p_period_name          IN gl_periods.period_name%TYPE
                              := NULL
   ,x_utl_hours           OUT NOCOPY /* file.sql.39 change */ NUMBER
   ,x_utl_capacity        OUT NOCOPY /* file.sql.39 change */ NUMBER
   ,x_utl_percent         OUT NOCOPY /* file.sql.39 change */ NUMBER
   ,x_return_status       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
   ,x_err_code            OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS

    l_calendar_id NUMBER;
	l_period_id NUMBER;
	l_capacity_hrs NUMBER;
	l_reduce_capacity_hrs NUMBER;

BEGIN
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -----------------
	 --Get calendar ID
	 -----------------
	 BEGIN

	     SELECT calendar_id
		 INTO   l_calendar_id
		 FROM fii_time_cal_name
		 WHERE period_set_name = p_period_set_name AND
		       period_type = p_period_type;

	 EXCEPTION
	    WHEN NO_DATA_FOUND THEN
		    RETURN;
	 END;

	 --------------------------------
	 --Get period_id for the calendar
	 --------------------------------
	 BEGIN

	     SELECT cal_period_id
		 INTO   l_period_id
		 FROM fii_time_cal_period
		 WHERE calendar_id = l_calendar_id AND
		       name = p_period_name;

	 EXCEPTION
	    WHEN NO_DATA_FOUND THEN
		    x_return_status := FND_API.G_RET_STS_ERROR;
			x_err_code      := SQLERRM;
		    RETURN;
	 END;


	 --------------------------------
	 --Get Utilization details
	 --------------------------------
	 BEGIN

	     SELECT NVL(conf_wtd_org_hrs_s,0),
		        NVL(capacity_hrs,0),
				NVL(reduce_capacity_hrs_s,0)
		 INTO   x_utl_hours,
		        l_capacity_hrs,
				l_reduce_capacity_hrs
		 FROM pji_rm_org_f_mv
		 WHERE expenditure_organization_id = p_organization_id AND
		       expenditure_org_id          = p_org_id          AND
			   time_id                     = l_period_id       AND
               period_type_id              = 32                AND
               ROWNUM = 1;

	 EXCEPTION
	    WHEN NO_DATA_FOUND THEN
		    x_return_status := FND_API.G_RET_STS_ERROR;
			x_err_code      := SQLERRM;
		    RETURN;
	 END;

	 x_utl_capacity := l_capacity_hrs - l_reduce_capacity_hrs;

     IF x_utl_capacity = 0 THEN
         x_utl_percent := null;
     ELSE
   	     x_utl_percent  := (x_utl_hours * 100)/x_utl_capacity;
     END IF;

	 x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_err_code      := SQLERRM;

END get_utilization_dtls;


END pa_pji_util_pkg;

/
