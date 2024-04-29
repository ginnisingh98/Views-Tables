--------------------------------------------------------
--  DDL for Package PER_CN_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CN_DATA_PUMP" AUTHID CURRENT_USER AS
/* $Header: hrcndpmf.pkh 115.0 2003/01/02 09:17:18 statkar noship $
--/*
--*NAME
--*   get_employer_id
--*DESCRIPTION
--*   Returns Legal Employer  ID.
--*NOTES
--*   This function returns an employer_id and is designed for use
--*   with the Data Pump.
  */

FUNCTION get_employer_id
(p_employer_name               in varchar2,
 p_business_group_id           in number)
 RETURN varchar2;
PRAGMA RESTRICT_REFERENCES (get_employer_id, WNDS);

------------------------------------------------------------------------------------
END per_cn_data_pump ;

 

/
