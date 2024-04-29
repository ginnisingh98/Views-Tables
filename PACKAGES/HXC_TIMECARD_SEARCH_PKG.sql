--------------------------------------------------------
--  DDL for Package HXC_TIMECARD_SEARCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIMECARD_SEARCH_PKG" AUTHID CURRENT_USER AS
/* $Header: hxcserch.pkh 120.0 2005/05/29 05:00:28 appldev noship $ */
--  get_search_attribute
--
-- procedure
--
--
-- description
--   Wrapper procedure the updates the status of an APPLICATION PERIOD
--   building block. Performs a validation to check if the correct
--   Time Building Block is being updated. Calls the Workflow to transisition
--   to HXC_APP_SET_PERIODS node.
-- parameters
--              p_flex_search_value               - to be searched item
--              p_flex_segment                  - segment of flex
--              p_flex_context                    - context of flex
--              p_flex_name                       - name of flex
--              p_application_short_name          - short name of application
--
/*
FUNCTION get_search_attribute(
  p_flex_search_value      IN  VARCHAR2
 ,p_flex_segment           IN  VARCHAR2
 ,p_flex_context           IN  VARCHAR2
 ,p_flex_name              IN  VARCHAR2
 ,p_application_short_name IN  VARCHAR2
 ,p_operator               IN  VARCHAR2
 ,p_resource_id            IN  VARCHAR2
 ,p_field_name             IN  VARCHAR2
)
RETURN VARCHAR2;
*/


PROCEDURE get_sql_where(
  p_resource_id           IN  VARCHAR2
 ,p_search_rows           IN  VARCHAR2
 ,p_search_input_string   IN  VARCHAR2
 ,p_where                 OUT NOCOPY VARCHAR2
);

--
-- function get_timecard_status_code
--
--
-- description 	Calculates the status of a timecard after looking
--		into the status of application periods within or
--		surrounding the timecard.
--
-- parameters
--              bb_id		  - Building block id of timecard
--              bb_ovn            - Building block ovn of the timecard
--
-- returns 	Status of timecard
--

function get_timecard_status_code(bb_id number, bb_ovn number)
return varchar2;


--
-- overloaded function get_timecard_status_code
--
--
-- description 	Calculates the status (Meaning) of a timecard after looking
--		into the status of application periods within or
--		surrounding the timecard.
--
-- parameters
--              bb_id		  - Building block id of timecard
--              bb_ovn            - Building block ovn of the timecard
--              p_mode            - Migration mode or normal mode.
--                                - in case of normal mode, the overloaded version
--                                - given above will be used.
--
-- returns 	Status of timecard
--


function get_timecard_status_code(bb_id number, bb_ovn number, p_mode varchar2)
return varchar2;


--
-- function get_timecard_status_meaning
--
--
-- description 	Calculates the status of a timecard after looking
--		into the status of application periods within or
--		surrounding the timecard.
--
-- parameters
--              bb_id		  - Building block id of timecard
--              bb_ovn            - Building block ovn of the timecard
--
-- returns 	Status of timecard
--

FUNCTION get_timecard_status_meaning(bb_id number, bb_ovn number)
return varchar2;


-- Start Changes 115.13
--
-- function get_timecard_cla_status
--
--
-- description 	Calculates the status of a timecard after looking
--		into the associated attributes to find if any
--		Change or Late Audit reasons are associated with
--              with the timecard.
--
-- parameters
--              bb_id		  - Building block id of timecard
--              bb_ovn            - Building block ovn of the timecard
--
-- returns 	CLA Status of timecard
--

FUNCTION get_timecard_cla_status(bb_id number, bb_ovn number)
return varchar2;

-- End Changes 115.13
/*
 ==========================================================================
 This procedure builds a complete sql for advanced search.  Java code
 calls this routine to build the VO.
 =========================================================================
*/
PROCEDURE get_search_sql(
  p_resource_id           IN  VARCHAR2
 ,p_search_start_time     IN  VARCHAR2
 ,p_search_stop_time      IN  VARCHAR2
 ,p_search_rows           IN  VARCHAR2
 ,p_search_input_string   IN  VARCHAR2
 ,p_result                OUT NOCOPY VARCHAR2
);

FUNCTION get_attributes(
  p_search_by              IN VARCHAR2
 ,p_search_value           IN VARCHAR2
 ,p_flex_segment           IN VARCHAR2
 ,p_flex_context           IN VARCHAR2
 ,p_flex_name              IN VARCHAR2
 ,p_application_short_name IN VARCHAR2
 ,p_operator               IN VARCHAR2
 ,p_resource_id            IN VARCHAR2
 ,p_field_name             IN VARCHAR2
 ,p_user_set               IN VARCHAR2 DEFAULT 'Y'
) RETURN VARCHAR2;

c_no_valueset_attached  CONSTANT VARCHAR2(20):= 'NO_VALUESET_ATTACHED';


END hxc_timecard_search_pkg;

 

/
