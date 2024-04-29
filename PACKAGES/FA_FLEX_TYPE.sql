--------------------------------------------------------
--  DDL for Package FA_FLEX_TYPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FLEX_TYPE" AUTHID CURRENT_USER as
/* $Header: FAFBXITS.pls 120.0.12010000.2 2009/07/19 14:44:16 glchen ship $ */

  --
  -- Private Inter-Package Types
  --
  -- Following types are used to construct nested record type of table type
  --
  TYPE fafbglb IS RECORD (
        book_type_code		FA_BOOK_CONTROLS.book_type_code%TYPE,
  	book_type_name		FA_BOOK_CONTROLS.book_type_name%TYPE,
	function_name		varchar2(31),
  	id_flex_num		FA_BOOK_CONTROLS.accounting_flex_structure%TYPE,
   	appid		        number,
    	userid			number,
        login			number,
        acct_segnum		number,
        bal_segnum		number,
        cost_segnum		number,
        numsegs		        number,
        delim			varchar2(1));

  TYPE fafbact is RECORD (
       	type_name	varchar2(50),
  	type_code	varchar2(30),
	flag		varchar2(1));

    fafbglb_rec   fafbglb;
  --fafbact_rec   fafbact;
    fafbact_rec   fafbact;
  TYPE fafb_acct_tab_type IS TABLE OF fafbact
	INDEX BY BINARY_INTEGER;
  -- COMMON CONSTANT
  --
  -- Positional argument tokens
 -- Mode      - First argument is the mode
 -- Book_type - Book Type Code
  RUN_MODE		CONSTANT NUMBER := 1;
  BOOK_TYPE		CONSTANT NUMBER := 2;

-- Possible calling modes
-- seed_mode		:initial seeding mode
-- delete_mode		:delete a book
-- bad_mode		:non-existent mode
-- num_flex_params	:number of flexbuilder parameters
-- bad_arg		:bad argument

  SEED_MODE		CONSTANT NUMBER := 0;
  DELETE_MODE		CONSTANT NUMBER := 1;
  BAD_MODE		CONSTANT NUMBER := 2;
  NUM_FLEX_PARAMS	CONSTANT NUMBER := 3;

-- bonus: from 23 to 25; impairment to 27; sorp to 29
  NUM_ACCTS		CONSTANT NUMBER := 29;
  GL_APPL_ID		CONSTANT NUMBER :=101;
  FA_APPL_ID		CONSTANT NUMBER :=140;
  TOTAL_SEG_COLS	CONSTANT NUMBER :=30;  /* Total segments in gl_code_combinations  */

END FA_FLEX_TYPE;

/
