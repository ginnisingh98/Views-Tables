--------------------------------------------------------
--  DDL for Package AK_ON_OBJECTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AK_ON_OBJECTS_PUB" AUTHID CURRENT_USER as
/* $Header: akdpons.pls 120.2 2005/09/02 17:37:44 tshort ship $ */

--
-- Global constants holding the package and file names to be used by
-- messaging routines in the case of an unexpected error.
--
G_PKG_NAME      CONSTANT    VARCHAR2(30) := 'AK_ON_OBJECTS_PUB';

--
-- Global constants for the p_write_mode parameter
--
G_APPEND     CONSTANT    VARCHAR2(1) := 'A';
G_OVERWRITE  CONSTANT    VARCHAR2(1) := 'W';

--
-- Max number of values per column (N) in the loader file
-- i.e  <column_name> = <value1> <value2> ... <valueN>
-- This value should equals one more than the max number of extended
-- attributes used by the NLS Translation team.
-- Regardless of what this value is, all values other than the first
-- value are ignored by the UPLOAD APIs.
--
G_MAX_NUM_LOADER_VALUES  CONSTANT   NUMBER := 3;

--
-- Date format used in all AK loader routines.
--
G_DATE_FORMAT CONSTANT   VARCHAR2(21) := 'YYYY-MM-DD HH24:MI:SS';

--
-- Flat file format version number
--
-- 110.1 is the version before JSP changes
-- 115.1 is the version after JSP changes

G_FILE_FORMAT_VER	NUMBER := 120.1;
G_OLD_FILE_FORMAT_VER1	NUMBER := 110.1;
G_OLD_FILE_FORMAT_VER2	NUMBER := 115.1;
G_OLD_FILE_FORMAT_VER3  NUMBER := 115.2;
G_OLD_FILE_FORMAT_VER4  NUMBER := 115.3;
G_OLD_FILE_FORMAT_VER5  NUMBER := 115.4;
G_OLD_FILE_FORMAT_VER6	NUMBER := 115.5;
G_OLD_FILE_FORMAT_VER7	NUMBER := 115.6;
G_OLD_FILE_FORMAT_VER8	NUMBER := 115.7;
G_OLD_FILE_FORMAT_VER9	NUMBER := 115.8;
G_OLD_FILE_FORMAT_VER10 NUMBER := 115.9;
G_OLD_FILE_FORMAT_VER11 NUMBER := 115.10;
G_OLD_FILE_FORMAT_VER12 NUMBER := 115.12;
G_OLD_FILE_FORMAT_VER14 NUMBER := 115.14;
G_OLD_FILE_FORMAT_VER15 NUMBER := 115.15;

--
-- Type definitions
--
-- buffer for one logical line. Logical lines are made up
-- of a single line in a file, or multiple lines in a file which are
-- logically one line and were connected with continuation characters ('')
--
buffer_type_template    VARCHAR2(4096);
SUBTYPE Buffer_Type IS buffer_type_template%TYPE;
--
-- Table of buffer lines for logical lines.
--
TYPE Buffer_Tbl_Type IS TABLE OF Buffer_Type
INDEX BY BINARY_INTEGER;

TYPE loader_temp_rec_type is RECORD (
TBL_INDEX     NUMBER          := NULL,
LINE_CONTENT  VARCHAR2(2000)  := NULL
);

-- Cursor Type and Cursor variable
TYPE LoaderCurTyp IS REF CURSOR RETURN loader_temp_rec_type;

--
-- Constants for missing data types
--
G_MISS_BUFFER_TBL          Buffer_Tbl_Type;

-- Indicate that it's currently uploading or downloading
-- valid values should be UPLOAD and DOWNLOAD
G_LOAD_MODE		VARCHAR2(10);
G_UPLOAD_FILE_VERSION	NUMBER;

end AK_ON_OBJECTS_PUB;

 

/
