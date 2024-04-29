--------------------------------------------------------
--  DDL for Package BEN_EXT_ADV_CT_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_ADV_CT_CHECK" AUTHID CURRENT_USER as
/* $Header: benxadct.pkh 120.0 2006/05/03 23:24:19 rbingi noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation                  |
|			   Redwood Shores, California, USA                     |
|			        All rights reserved.	                         |
+==============================================================================+
Name:
    Extract Advanced Conditions.
Purpose:
       THIS PACKKAGE CAN NOT BE EDITED WITHOUT PERMISSION FORM EXTRACT OWNER
History:
        Date      Version  Who         What?
        ----      -------  ----------- -------------------------------------------
        25-Apr-06  115.0    Ty Hayden   Created.
*/
-----------------------------------------------------------------------------------
--
Procedure rcd_in_file(p_ext_rcd_in_file_id in number,
                          p_sprs_cd in varchar2,
                          p_exclude_this_rcd_flag out nocopy boolean);

Procedure data_elmt_in_rcd(p_ext_rcd_id in number,
                          p_exclude_this_rcd_flag out nocopy boolean);



Procedure chk_val(p_ext_where_clause_id                in number,
                  p_oper_cd                     in varchar2,
                  p_val                         in varchar2,
                  p_effective_date              in date
                  ) ;



END; -- Package spec

 

/
