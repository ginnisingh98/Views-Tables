--------------------------------------------------------
--  DDL for Package HXT_TC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_TC_UTIL" AUTHID CURRENT_USER AS
/* $Header: hxttcutl.pkh 115.1 2002/06/10 00:38:39 pkm ship      $ */

FUNCTION get_tc_hrs_total(p_tim_id IN NUMBER) RETURN NUMBER;
PROCEDURE update_approver(p_tim_row_id IN VARCHAR2,
                          p_approv_person_id   NUMBER,
                          p_approved_timestamp DATE,
                          p_last_updated_by    NUMBER,
                          p_last_update_date   DATE,
                          p_last_update_login  NUMBER
                          );

END hxt_tc_util;

 

/
