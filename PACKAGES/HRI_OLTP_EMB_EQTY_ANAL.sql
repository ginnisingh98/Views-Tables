--------------------------------------------------------
--  DDL for Package HRI_OLTP_EMB_EQTY_ANAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_EMB_EQTY_ANAL" AUTHID CURRENT_USER AS
/* $Header: hrioembeanl.pkh 120.1.12000000.1 2007/01/15 22:09:30 appldev noship $ */

TYPE HRI_EMB_PARAM_REC_TYPE IS RECORD
      (effective_date           VARCHAR2(10),  -- MM/DD/YYYY
       job_id                   NUMBER,
       supervisor_person_id     NUMBER,
       logged_in_person_id      NUMBER,
       currency_code_to         VARCHAR2(3),
       inc_ceo_row              VARCHAR2(1),
       view_by                  VARCHAR2(100)
       );

/*
** Returns the data a single materialized view was last refreshed
**/
FUNCTION get_mv_last_refresh_date (p_mv_name IN VARCHAR2) RETURN DATE;

/* returns a translated string of the form:
** "Data Last Updated: DD-MON-YYYY"
**/
FUNCTION get_last_updated_date_msg (p_date_token DATE) RETURN VARCHAR2;

PROCEDURE GET_SQL(
                   p_effective_date         IN VARCHAR2
                  ,p_job_id                 IN NUMBER
                  ,p_supervisor_person_id   IN NUMBER
                  ,p_logged_in_person_id    IN NUMBER DEFAULT FND_GLOBAL.EMPLOYEE_ID
                  ,p_conv_to_currency_code  IN VARCHAR2
                  ,p_sal_amount_fmt         IN VARCHAR2 DEFAULT 'FM999,999,999,999'
                  ,p_ceo_row              IN VARCHAR2 DEFAULT 'N'
                  ,o_sql_string           OUT NOCOPY VARCHAR2
                  ,o_return_status        OUT NOCOPY VARCHAR2);

END HRI_OLTP_EMB_EQTY_ANAL;

 

/
