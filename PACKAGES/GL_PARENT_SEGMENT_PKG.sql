--------------------------------------------------------
--  DDL for Package GL_PARENT_SEGMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_PARENT_SEGMENT_PKG" AUTHID CURRENT_USER AS
/* $Header: glfcpsgs.pls 120.2 2005/05/05 02:04:58 kvora noship $ */

--
-- PACKAGE
--   GL_PARENT_SEGMENT_PKG
-- PURPOSE
--   This package will merge the child ranges of the parent value(s) of a
--   specific segment. All parent value(s) should be inserted to the
--   temporary table GL_REVAL_CHD_RANGES_GT before calling this package to
--   merge child ranges.
-- HISTORY
--   07/29/03          L Poon            Created
--

-- PROCEDURE
--   merge_child_ranges
-- PURPOSE
--   It will merge the child ranges of all parent values stored in
--   GL_REVAL_CHD_RANGES_GT for the passed segment and store the merged
--   child ranges back to GL_REVAL_CHD_RANGES_GT.
-- HISTORY
--   07/29/03          L Poon            Created
-- ARGUMENTS
--   fv_set_id  Flex Value Set ID
--   debug_mode Debug Mode (Y or N)
PROCEDURE merge_child_ranges(fv_set_id IN NUMBER,
                             debug_mode IN VARCHAR2);

-- PROCEDURE
--   get_min_max
-- PURPOSE
--   It will get the record count, the minimum and maximum child flex
--   values of the child ranges for the passed segment stored in
--   GL_REVAL_CHD_RANGES_GT.
-- HISTORY
--   07/29/03          L Poon            Created
-- ARGUMENTS
--   seg_num    Segment Number
--   parent_val Parent Flex Value to be processed
--   rec_count  Record Count
--   min_val    Minimum Child Flex Value
--   max_val    Maximum Child Flex Value
PROCEDURE get_min_max(fv_set_id  IN NUMBER,
                      parent_val IN VARCHAR2,
                      rec_count  OUT NOCOPY NUMBER,
                      min_val    OUT NOCOPY VARCHAR2,
                      max_val    OUT NOCOPY VARCHAR2);

-- PROCEDURE
--   get_fv_table
-- PURPOSE
--   It will get the name of the table which contains the flex values for
--   the passed segment.
-- HISTORY
--   07/29/03          L Poon            Created
-- ARGUMENTS
--   fv_set_id Flex Value Set ID
--   fv_table  Flex Value Table Name
--   fv_col    Flex Value Column Name
--   fv_type   Flex Value Validation Type
PROCEDURE get_fv_table(fv_set_id IN NUMBER,
                       fv_table  OUT NOCOPY VARCHAR2,
                       fv_col    OUT NOCOPY VARCHAR2,
                       fv_type   OUT NOCOPY VARCHAR2);

-- PROCEDURE
--   check_overlapping
-- PURPOSE
--   It will check whether any expanded and merged account ranges
--   in GL_REVAL_EXP_RANGES_GT overlap
-- HISTORY
--   08/29/03          L Poon            Created
-- ARGUMENTS
--   debug_mode     Debug Mode (Y or N)
--   is_overlapping Indicate if any ranges overlap (Y or N)
PROCEDURE check_overlapping(debug_mode     IN  VARCHAR2,
                            is_overlapping OUT NOCOPY VARCHAR2);

-- PROCEDURE
--   debug_msg
-- PURPOSE
--   It will print the debug message
-- HISTORY
--   07/29/03          L Poon            Created
-- ARGUMENTS
--   name Procedure/Function name
--   msg  Debug Message
PROCEDURE debug_msg(name IN VARCHAR2,
                    msg  IN VARCHAR2);

END GL_PARENT_SEGMENT_PKG;

 

/
