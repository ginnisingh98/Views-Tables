--------------------------------------------------------
--  DDL for Package PER_RU_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RU_DATA_PUMP" AUTHID CURRENT_USER AS
/* $Header: hrrudpmf.pkh 120.0 2005/05/31 02:35:14 appldev noship $
--/*
--*NAME
--*   get_employer_id
--*DESCRIPTION
--*   Returns Legal Employer  ID.
--*NOTES
--*   This function returns an employer_id and is designed for use
--*   with the Data Pump.
  */
   FUNCTION get_employer_id (
      p_employer_name            IN   VARCHAR2,
      p_business_group_id   IN   NUMBER,
      p_effective_date      IN   DATE,
      p_language_code       IN   VARCHAR2 DEFAULT NULL
   )
      RETURN VARCHAR2;

   PRAGMA RESTRICT_REFERENCES (get_employer_id, WNDS);
------------------------------------------------------------------------------------
END per_ru_data_pump;

 

/
