--------------------------------------------------------
--  DDL for Package GL_JAHE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_JAHE_PKG" AUTHID CURRENT_USER as
/* $Header: glajahes.pls 120.15 2006/01/19 10:51:28 knag noship $ */

--
-- Function
--    has_loop
-- PURPOSE
--    Tree Loop Detection
-- 	Check to see if the source is in the parent path of target.
-- 	This is a recursive function.
-- History
--    13-JAN-00       Maria Hui       Created
-- Arguments
--    source		drag source - new child
--    target		drop target - parent to receive the new child
--    value_set_id	flex value set id
-- Return
--    TRUE	if there is loop in the drag and drop
--    FALSE	if drag and drop results in no loop
-- Notes
--

FUNCTION has_loop (source       IN  VARCHAR2,
                   target       IN  VARCHAR2,
                   value_set_id IN  NUMBER) RETURN VARCHAR2;

--
-- Function
--    modify_range
-- PURPOSE
--    Range Split
-- 	Determine how the range will be affected by a drag and drop action.
-- 	Depending on the position that the node that is being dragged in the
-- 	range. It may cause a range delection, range boundary modificaiton,
-- 	or range split.
-- History
--    26-JAN-00       Maria Hui       Created
-- Arguments
--     parent        old parent of the node that is being dragged away
--     child         the node that is being dragged away
--     range_attr    range attribute for the existing range
--     range_low     child_flex_value_low of the current range
--     range_high    child_flex_value_high of the current range
--     value_set_id  flex value set id of the row
-- Return
--    1		if the range split can be handled successfully
--    0		if there is any exception raised
-- Notes
--

FUNCTION modify_range ( parent          IN      VARCHAR2,
                        child           IN      VARCHAR2,
                        range_attr      IN      VARCHAR2,
                        range_low       IN      VARCHAR2,
                        range_high      IN      VARCHAR2,
                        value_set_id    IN      NUMBER) RETURN INTEGER;

--
-- Function
--    has_loop_in_range
-- PURPOSE
--    Loop Detection in Range Manipulation
-- 	Check to see if the new or edited range create loop in the hierarchy.
-- History
--    30-MAY-00       Maria Hui       Created
-- Arguments
--    parent		parent whose range is being modified
--    low		lower bound of the new range
--    high		upper bound of the new range
--    value_set_id	flex value set id
-- Return
--    NULL		if the new range will not cause any loop with existing range
--    flex_value	flex value in the new range that is causing a loop
-- Notes
--

FUNCTION has_loop_in_range(parent   IN  VARCHAR2,
                           low      IN  VARCHAR2,
                           high     IN  VARCHAR2,
                           value_set_id IN  NUMBER) RETURN VARCHAR2;

--
-- Procedure
--    Merge_Range
-- PURPOSE
--    Merge the current ranges. It merges the ranges in the temporary
--    table GL_AHE_DETAIL_RANGES_GT that with a status of 'C' (current) and
--    store the merged ranges back to the temporary table with a status
--    'M'. For overlapping ranges, it merges immediately. For non-
--    overlapping ranges, they can be merged if there are no flex values
--    between the ranges.
-- History
--    7-JUN-00       Maria Hui       Created
-- Arguments
--    parent		parent whose range is being merged
--    value_set_id	flex value set id of the parent flex value
-- Notes
--
PROCEDURE merge_range ( parent       IN  VARCHAR2,
                        value_set_id IN  NUMBER);

--
-- Function
--    unique_flex_value
-- PURPOSE
--    Checks to see if the flex value is unique.
-- History
--    21-JUN-00       Maria Hui       Created
-- Arguments
--    f_value		flex value in concern
--    parent_low	parent flex value low
--    value_set_id	flex value set id
-- Return
--    TRUE		if the value is unique
--    FALSE		otherwise
-- Notes
--

FUNCTION unique_flex_value (f_value      IN  VARCHAR2,
                            parent_low   IN  VARCHAR2,
                            value_set_id IN  NUMBER) RETURN VARCHAR2;

FUNCTION getCOAClause(  user_id    IN      NUMBER,
                        resp_id    IN      NUMBER,
                        appl_id    IN      NUMBER) RETURN VARCHAR2;

FUNCTION access_test RETURN VARCHAR2;

PROCEDURE lock_flex_value_set (fvsid NUMBER);

PROCEDURE flatten_hierarchy (fvsid NUMBER);

PROCEDURE insert_tl_records (fvsid NUMBER DEFAULT NULL);

PROCEDURE launch;

END GL_JAHE_PKG ;

 

/
