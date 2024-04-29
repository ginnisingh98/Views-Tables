--------------------------------------------------------
--  DDL for Package FII_FDHM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_FDHM_PKG" AUTHID CURRENT_USER as
/* $Header: fiifdhms.pls 120.1 2005/07/18 20:25:43 juding noship $ */

--
-- Function
--    has_loop
-- PURPOSE
--    Tree Loop Detection
-- 	Check to see if the source is in the parent path of target.
-- 	This is a recursive function.
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
                        parent_value_set_id    IN      NUMBER,
                        child_value_set_id IN NUMBER) RETURN INTEGER;

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

FUNCTION lock_dim_value_sets (dim_short_name      VARCHAR2,
                        source_lgr_group_id NUMBER) RETURN VARCHAR2;

PROCEDURE release_value_set_lock(dim_short_name VARCHAR2, source_lgr_group_id NUMBER,
                 value_set_id NUMBER);


FUNCTION release_dimension_lock (dim_short_name      VARCHAR2,
                 source_lgr_group_id NUMBER) RETURN VARCHAR2;


PROCEDURE insert_dim_value_sets (dim_short_name VARCHAR2,  source_lgr_group_id NUMBER);

FUNCTION flatten_hierarchy (dim_short_name     VARCHAR2,
                            source_lgr_group_id NUMBER,
                            user_id    IN      NUMBER,
                            resp_id    IN      NUMBER,
                            appl_id    IN      NUMBER)  RETURN VARCHAR2;

PROCEDURE insert_tl_records;

PROCEDURE insert_tl_records_for_id(value_id number);

PROCEDURE delete_tl_records_for_id(value_id number);

FUNCTION get_compiled_value_attr(value_set_id NUMBER) RETURN VARCHAR2;

PROCEDURE launch( dim_short_name         IN VARCHAR2,
                  source_ledger_group_id IN NUMBER);

PROCEDURE delete_dim_value_sets(dim_short_name VARCHAR2,
                     source_lgr_group_id NUMBER);

PROCEDURE insert_fnd_norm_hier_rec( parent    IN      VARCHAR2,
                        child           IN      VARCHAR2,
                        range_attr      IN      VARCHAR2,
                        range_low       IN      VARCHAR2,
                        range_high      IN      VARCHAR2,
                        value_set_id    IN   NUMBER);

PROCEDURE delete_fnd_norm_hier_rec( parent          IN      VARCHAR2,
                        child           IN      VARCHAR2,
                        range_attr      IN      VARCHAR2,
                        range_low       IN      VARCHAR2,
                        range_high      IN      VARCHAR2,
                        value_set_id    IN   NUMBER);

FUNCTION access_test RETURN VARCHAR2;

END FII_FDHM_PKG ;

 

/
