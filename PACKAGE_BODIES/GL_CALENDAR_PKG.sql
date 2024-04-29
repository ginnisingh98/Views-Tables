--------------------------------------------------------
--  DDL for Package Body GL_CALENDAR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_CALENDAR_PKG" as
/* $Header: glustclb.pls 120.2 2005/05/19 22:38:13 djogg noship $ */

  PROCEDURE get_num_periods_in_date_range(
                         calendar_name 			VARCHAR2,
                         period_type 			VARCHAR2,
                         start_date			DATE,
                         end_date			DATE,
			 check_missing			BOOLEAN,
			 num_periods	   OUT NOCOPY   NUMBER,
			 return_code       OUT NOCOPY   VARCHAR2,
			 unmapped_date     OUT NOCOPY   DATE) IS
    low_period_name VARCHAR2(15);
    high_period_name VARCHAR2(15);
  BEGIN

    return_code := success;

--Added by Service Contracts Team to handle monthly revenue recognition

    Begin
    if nvl(fnd_profile.value ('OKS_ACCDUR_BASIS'),'MONTHLY') = 'MONTHLY' Then
       num_periods := ceil(months_between(end_date, start_date));
--Logic to handle one day
       if num_periods = 0 then
          num_periods := 1;
       end if;
       return;
    end if;
    Exception
    When Others Then
       return_code := 'ERROR';
       return;
    End;

--Added by Service Contracts Team to handle monthly revenue recognition

    BEGIN
      SELECT period_name
      INTO low_period_name
      FROM gl_date_period_map
      WHERE period_set_name = calendar_name
      AND   period_type = get_num_periods_in_date_range.period_type
      AND   accounting_date = start_date;

      IF (low_period_name = 'NOT ASSIGNED') THEN
        return_code := bad_start;
        unmapped_date := start_date;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        return_code := bad_start;
        unmapped_date := start_date;
    END;

    BEGIN
      SELECT period_name
      INTO high_period_name
      FROM gl_date_period_map
      WHERE period_set_name = calendar_name
      AND   period_type = get_num_periods_in_date_range.period_type
      AND   accounting_date = end_date;

      IF (high_period_name = 'NOT ASSIGNED') THEN
        return_code := bad_end;
        unmapped_date := end_date;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        return_code := bad_end;
        unmapped_date := end_date;
    END;

    IF (    (check_missing)
        AND (return_code = 'SUCCESS')
       ) THEN
      BEGIN
        SELECT min(accounting_date)
        INTO unmapped_date
        FROM gl_date_period_map
        WHERE period_set_name = calendar_name
        AND   period_type = get_num_periods_in_date_range.period_type
        AND   accounting_date between start_date and end_date
        AND   period_name = 'NOT ASSIGNED';

        IF (unmapped_date IS NOT NULL) THEN
          return_code := unmapped_day;
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          unmapped_date := null;
      END;
    END IF;

    SELECT count(*)
    INTO num_periods
    FROM gl_periods
    WHERE period_set_name = calendar_name
    AND   period_type = get_num_periods_in_date_range.period_type
    AND   adjustment_period_flag = 'N'
    AND   start_date <= get_num_periods_in_date_range.end_date
    AND   end_date >= get_num_periods_in_date_range.start_date;
  END get_num_periods_in_date_range;

END GL_CALENDAR_PKG;

/
