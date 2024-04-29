--------------------------------------------------------
--  DDL for Package BEN_PROFILE_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PROFILE_HANDLER" AUTHID CURRENT_USER as
/* $Header: benprhnd.pkh 120.0 2005/05/28 09:19:53 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
	Profile Handler
Purpose
	This package is used to handle setting of profile flags based on
        data changes that have occurred on child component tables.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        07-OCT-1999      GPERRY     115.0      Created.
*/
--------------------------------------------------------------------------------
--
procedure event_handler
  (p_event                       in  varchar2,
   p_base_table                  in  varchar2,
   p_base_table_column           in  varchar2,
   p_base_table_column_value     in  number,
   p_base_table_reference_column in  varchar2,
   p_reference_table             in  varchar2,
   p_reference_table_column      in  varchar2);
-----------------------------------------------------------------------
end ben_profile_handler;

 

/
