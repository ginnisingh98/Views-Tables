--------------------------------------------------------
--  DDL for Package BEN_DERIVABLE_RATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DERIVABLE_RATE" AUTHID CURRENT_USER as
/* $Header: bendrvrt.pkh 120.0 2005/05/28 04:14:03 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
        Derivable Factor Rate
Purpose
	This package is used to handle setting of Derivable Factor Applies Rate Flag based on
        data changes that have occurred on child component tables.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        07-Mar-2000      KMahendr   115.0      Created.
*/
--------------------------------------------------------------------------------
--
procedure rate_prfl_handler
  (p_event                       in  varchar2,
   p_table_name                  in  varchar2,
   p_col_name                    in  varchar2,
   p_col_id                      in  number);

procedure derivable_rate_handler
  (p_event         in varchar2,
   p_vrbl_rt_prfl_id in number);

-----------------------------------------------------------------------
end ben_derivable_rate;

 

/
