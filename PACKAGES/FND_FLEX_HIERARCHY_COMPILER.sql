--------------------------------------------------------
--  DDL for Package FND_FLEX_HIERARCHY_COMPILER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FLEX_HIERARCHY_COMPILER" AUTHID CURRENT_USER AS
/* $Header: AFFFCHYS.pls 120.2.12010000.5 2015/06/24 17:45:40 hgeorgi ship $ */


-- ==================================================
-- PROCEDURE : compile_hierarchy
-- ==================================================
-- Compiles the flex value hierarchy.
--
-- p_flex_value_set : Value set ID or value set NAME.
--                    If the passed value is a number then compiler
--                    will consider it as FLEX_VALUE_SET_ID
--                    otherwise it will be considered as FLEX_VALUE_SET_NAME.
-- p_debug_flag     : Debug flag. 'Y' or 'N'
-- x_result         : 'SUCCESS' if the compiler was successfull.
--                    'FAILURE' if the compiler was not successfull.
-- x_message        : Message from the compiler.
--
--
PROCEDURE compile_hierarchy(p_flex_value_set IN VARCHAR2,
			    p_debug_flag     IN VARCHAR2 DEFAULT 'N',
			    x_result         OUT nocopy VARCHAR2,
			    x_message        OUT nocopy VARCHAR2);

PROCEDURE compile_hierarchy(p_flex_value_set IN VARCHAR2,
			    x_result         OUT nocopy VARCHAR2,
			    x_message        OUT nocopy VARCHAR2);

PROCEDURE compile_hierarchy_all(p_flex_value_set IN VARCHAR2,
                            p_debug_flag     IN VARCHAR2 DEFAULT 'N',
                            x_result         OUT nocopy VARCHAR2,
                            x_message        OUT nocopy VARCHAR2);

PROCEDURE request_lock(p_lock_name           IN VARCHAR2,
                       x_lock_handle         OUT nocopy VARCHAR2);

PROCEDURE release_lock(p_lock_name           IN VARCHAR2,
                       p_lock_handle         IN VARCHAR2);

END fnd_flex_hierarchy_compiler;

/
