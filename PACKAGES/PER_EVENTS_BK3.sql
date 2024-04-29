--------------------------------------------------------
--  DDL for Package PER_EVENTS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_EVENTS_BK3" AUTHID CURRENT_USER as
/* $Header: peevtapi.pkh 120.1 2005/10/02 02:17:00 aroussel $ */

Procedure delete_event_b
(p_event_id in number
,p_object_version_number   in  number);

Procedure delete_event_a
(p_event_id in number
,p_object_version_number   in  number);

end PER_EVENTS_BK3;

 

/
