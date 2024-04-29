--------------------------------------------------------
--  DDL for Package BEN_DERIVABLE_FACTOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DERIVABLE_FACTOR" AUTHID CURRENT_USER as
/* $Header: bendrvft.pkh 120.0 2005/05/28 04:13:46 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
        Derivable Factor
Purpose
	This package is used to handle setting of Derivable Factor Participation Flag based on
        data changes that have occurred on child component tables.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        06-Mar-2000      KMahendr   115.0      Created.
*/
--------------------------------------------------------------------------------
--
procedure eligy_prfl_handler
  (p_event                       in  varchar2,
   p_table_name                  in  varchar2,
   p_col_name                    in  varchar2,
   p_col_id                     in  number);

procedure derivable_factor_handler
  (p_event         in varchar2,
   p_eligy_prfl_id in number);

-----------------------------------------------------------------------
end ben_derivable_factor;

 

/
