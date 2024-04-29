--------------------------------------------------------
--  DDL for Package BEN_EXT_PAYROLL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_PAYROLL" AUTHID CURRENT_USER as
/* $Header: benxpayr.pkh 115.3 2003/02/10 11:23:43 rpgupta ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation                  |
|			   Redwood Shores, California, USA                     |
|			        All rights reserved.	                         |
+==============================================================================+
Name:
    Extract Payroll Process.
Purpose:
    This process handles fields that are related to Element Entries and Input Values.
History:
        Date             Who        Version    What?
        ----             ---        -------    -----
        18 Dec 98        Ty Hayden  115.0      Created.
        09 Mar 99        G Perry    115.1      IS to AS.
        14 Mar 99        Ty Hayden  115.2      Move globals variable to ben_ext_person.
*/
-----------------------------------------------------------------------------------
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
