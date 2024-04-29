--------------------------------------------------------
--  DDL for Package BEN_COLLAPSE_LIFE_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_COLLAPSE_LIFE_EVENTS" AUTHID CURRENT_USER as
/* $Header: benclple.pkh 120.0 2005/05/28 03:49:44 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
	Collapse Life Events
Purpose
	This package is used to collapse life events. It is designed to be
        called from fast formula but can be called from forms or reports as
        well.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        01 Dec 98        G Perry    115.0      Created.
        07 Dec 98        G Perry    115.1      Added function
                                               get_life_event_occured_date.
*/
-----------------------------------------------------------------------
function collapse_life_event
         (p_effective_date           in varchar2,
          p_assignment_id            in number,
          p_ler_id                   in number) return number;
-----------------------------------------------------------------------
function get_life_event_occured_date return varchar2;
-----------------------------------------------------------------------
end ben_collapse_life_events;

 

/
