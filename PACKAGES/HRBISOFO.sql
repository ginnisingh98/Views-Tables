--------------------------------------------------------
--  DDL for Package HRBISOFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRBISOFO" AUTHID CURRENT_USER AS
/* $Header: hrbisofo.pkh 115.0 99/07/15 19:38:57 porting shi $ */

FUNCTION primary_sales_job
          (p_person_id in NUMBER) return NUMBER;


END hrbisofo;

 

/
