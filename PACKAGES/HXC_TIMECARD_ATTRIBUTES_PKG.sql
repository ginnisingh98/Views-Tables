--------------------------------------------------------
--  DDL for Package HXC_TIMECARD_ATTRIBUTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIMECARD_ATTRIBUTES_PKG" AUTHID CURRENT_USER as
/* $Header: hxctcrda.pkh 115.2 2002/06/10 13:31:12 pkm ship    $ */
--
-- function get_timecard_attribute
--
--
-- description Returns the first found Attribute for the given Detail Building
--             block.
--
-- parameters
--        p_timecard_id		  - Detail Building block id of timecard
--        p_timecard_ovn          - Detail Building block ovn of the timecard
--        p_map                   - Map for the attribute from the mappings
--        p_field_name            - Field Name of the attribute from the mappings
--
-- returns 	Attribute
--
FUNCTION get_timecard_attribute(
           p_timecard_id number,
           p_timecard_ovn number,
           p_map varchar2,
           p_field_name varchar2)
RETURN varchar2;

END hxc_timecard_attributes_pkg;

 

/
