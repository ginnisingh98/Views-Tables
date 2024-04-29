--------------------------------------------------------
--  DDL for Package HRI_BPL_PERF_RATING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_BPL_PERF_RATING" AUTHID CURRENT_USER AS
/* $Header: hribpfrt.pkh 120.0 2005/05/29 07:04:05 appldev noship $ */
--
-- Exceptions raised when there is a problem with a fast formula
--
-- Raised when a fast formula is not compiled
--
ff_perf_rating_not_compiled         EXCEPTION;
--
-- Raised when a the fast formula returns an invalid value for the parameter
--
ff_returned_invalid_value           EXCEPTION;
--
FUNCTION get_appraisal_ff (p_business_group_id     IN NUMBER)
RETURN NUMBER;
--
FUNCTION get_review_ff
RETURN NUMBER;
--
FUNCTION ff_exits_and_compiled(p_business_group_id     IN NUMBER,
			       p_date                  IN DATE,
			       p_ff_name               IN VARCHAR2)
RETURN NUMBER;
--
FUNCTION get_perf_rating_val
  ( p_session_date	        IN   DATE
  , p_business_group_id         IN   NUMBER
  , p_perf_rating_cd	        IN   VARCHAR2
  , p_review_type               IN   VARCHAR2
  , p_appraisal_template_name   IN   VARCHAR2
  )
RETURN NUMBER;
--
FUNCTION get_perf_sql
RETURN VARCHAR2;
--
FUNCTION get_perf_rating_band
              (p_perf_nrmlsd_rating       NUMBER
              ,p_business_group_id        NUMBER
              ,p_person_id                NUMBER
              ,p_perf_rating_cd           VARCHAR2
              ,p_review_type              VARCHAR2
              ,p_appraisal_template_name  VARCHAR2)
RETURN NUMBER;
--
END HRI_BPL_PERF_RATING;

 

/
