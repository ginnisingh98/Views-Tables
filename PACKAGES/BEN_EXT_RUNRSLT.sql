--------------------------------------------------------
--  DDL for Package BEN_EXT_RUNRSLT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_RUNRSLT" AUTHID CURRENT_USER as
/* $Header: benxrunr.pkh 120.0.12000000.1 2007/01/19 19:29:44 appldev noship $
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation                  |
|			   Redwood Shores, California, USA                     |
|			        All rights reserved.	                         |
+==============================================================================+
Name :    Extract Run Result Process.
Purpose:  Run Result shows the payroll informations after the payroll run has
          executed. This process handles fields that are related to Element
	  entries and Input Value.
History:
        Date           Who             Version    What?
        ----           ---             -------    -----
        26 Apr 99      Anusree Sen     115.0      Created.
        14 May 99      Anusree Sen     115.1      Added Header.
        14 May 99      Anusree Sen     115.3      Deleted dbms_output.
--------------------------------------------------------------------------------
*/
--
--

PROCEDURE main
    (                        p_person_id          in number,
                             p_ext_rslt_id        in number,
                             p_ext_file_id        in number,
                             p_data_typ_cd        in varchar2,
                             p_ext_typ_cd         in varchar2,
                             p_chg_evt_cd         in varchar2,
                             p_business_group_id  in number,
                             p_effective_date     in date);


END;

 

/
