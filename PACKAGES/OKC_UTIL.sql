--------------------------------------------------------
--  DDL for Package OKC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_UTIL" AUTHID CURRENT_USER AS
/* $Header: OKCUTILS.pls 120.0.12010000.2 2010/08/09 05:53:08 spingali ship $ */

  -------------------------
  -- trace global variables
  -------------------------
l_trace_path            VARCHAR2(255);
l_trace_file     	UTL_FILE.FILE_TYPE;
l_trace_file_name       VARCHAR2(255);
l_output_file     	UTL_FILE.FILE_TYPE;
l_output_file_name      VARCHAR2(255);
l_trace_flag		BOOLEAN	:=FALSE;
l_log_flag		BOOLEAN	:=FALSE;
l_output_flag		BOOLEAN	:=FALSE;
l_before_trace_flag     BOOLEAN :=FALSE;
l_request_id		NUMBER;
l_program               VARCHAR2(80);
l_module                VARCHAR2(80);
l_complete_trace_file_name  VARCHAR2(255);
l_complete_trace_file_name2 VARCHAR2(255)  DEFAULT ' ';

  -------------------------
  -- standard trace constants
  -------------------------
g_trc_trace_file_prefix         CONSTANT VARCHAR2(30)  := 'okc_';
g_trc_trace_file_suffix         CONSTANT VARCHAR2(30)  := '.trc';

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE unq_rec_type IS RECORD (
                  p_col_name  varchar2(40),
                  p_col_val varchar2(2000));

  TYPE unq_tbl_type IS TABLE OF unq_rec_type
        INDEX BY BINARY_INTEGER;

  TYPE okc_control_rec_type IS RECORD (
                 source 	varchar2(15),
                 id		number,
                 flag		varchar2(1),
                 code		varchar2(30),
                 name		varchar2(240),
                 comments	varchar2(4000));

  TYPE okc_control_tbl_type IS TABLE OF okc_control_rec_type
        INDEX BY BINARY_INTEGER;

-- Stores the languages that are currently defined in FND_LANGUAGES.
-- This table is populated by the anonymous block in the package body.

  g_language_code                 OKC_DATATYPES.Var12TabTyp;

----------------------------------------------------------------------------
-- Procedure to add a view for checking length into global table
----------------------------------------------------------------------------
  Procedure  add_view(
    p_view_name                    IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2);

----------------------------------------------------------------------------
--  checks length of a varchar2 column
----------------------------------------------------------------------------
  Procedure  check_length(
    p_view_name                    IN VARCHAR2,
    p_col_name	                   IN VARCHAR2,
    p_col_value                    IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2);

----------------------------------------------------------------------------
--  checks length of a number column
----------------------------------------------------------------------------
 Procedure  check_length(
    p_view_name                    IN VARCHAR2,
    p_col_name                     IN VARCHAR2,
    p_col_value                    IN NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2);

----------------------------------------------------------------------------
 --checks uniqnuess of varchar2 when primary key is ID
----------------------------------------------------------------------------
    Procedure  Check_Unique(
    p_view_name                    IN VARCHAR2,
    p_col_name	                   IN VARCHAR2,
    p_col_value                    IN VARCHAR2,
    p_id                           IN NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2);

----------------------------------------------------------------------------
  --checks uniquness of DATE when primary key is ID
----------------------------------------------------------------------------
    Procedure  Check_Unique(
    p_view_name                    IN VARCHAR2,
    p_col_name	                   IN VARCHAR2,
    p_col_value                    IN DATE,
    p_id                           IN NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2);

----------------------------------------------------------------------------
  --checks uniquness of NUMBER when primary key is ID
----------------------------------------------------------------------------
    Procedure  Check_Unique(
    p_view_name                    IN VARCHAR2,
    p_col_name	                   IN VARCHAR2,
    p_col_value                    IN NUMBER,
    p_id                           IN NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2);

----------------------------------------------------------------------------
  --checks uniqueness of composite value made up of multiple columns when primary key is ID
----------------------------------------------------------------------------
    Procedure  Check_Comp_Unique(
    p_view_name                    IN VARCHAR2,
    p_col_tbl	                   IN unq_tbl_type,
    p_id                           IN NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2);

----------------------------------------------------------------------------
  --checks uniqueness of varchar2 when primary key is other than ID
----------------------------------------------------------------------------
   Procedure  Check_Unique(
    p_table_name                   IN VARCHAR2,
    p_col_name	                   IN VARCHAR2,
    p_col_value                    IN VARCHAR2,
    p_primary                      IN unq_tbl_type,
    x_return_status                OUT NOCOPY VARCHAR2);

----------------------------------------------------------------------------
  --checks uniqueness of NUMBER when primary key is other than ID
----------------------------------------------------------------------------
    Procedure  Check_Unique(
    p_table_name                   IN VARCHAR2,
    p_col_name	                   IN VARCHAR2,
    p_col_value                    IN NUMBER,
    p_primary                      IN unq_tbl_type,
    x_return_status                OUT NOCOPY VARCHAR2);

----------------------------------------------------------------------------
  --checks uniqueness of DATE when primary key is other than ID
----------------------------------------------------------------------------
    Procedure  Check_Unique(
    p_table_name                    IN VARCHAR2,
    p_col_name	                    IN VARCHAR2,
    p_col_value                     IN DATE,
    p_primary                       IN unq_tbl_type,
    x_return_status                 OUT NOCOPY VARCHAR2);

----------------------------------------------------------------------------
  --checks uniqueness of composite value made up of multiple columns when primary key is other than ID
----------------------------------------------------------------------------
    Procedure  Check_Comp_Unique(
    p_table_name                    IN VARCHAR2,
    p_col_tbl	                    IN unq_tbl_type,
    p_primary                       IN unq_tbl_type,
    x_return_status                 OUT NOCOPY VARCHAR2);

----------------------------------------------------------------------------
   --Check uniquness for COMPOSITE/Primary key  Columns in a table
----------------------------------------------------------------------------
    Procedure  Check_Comp_Unique(
    p_view_name                    IN VARCHAR2,
    p_col_tbl	                   IN unq_tbl_type,
    x_return_status                OUT NOCOPY VARCHAR2);

  ---------------------------------------------------------------------------
  --GLOBAL CONSTANT
  ---------------------------------------------------------------------------
  G_APP_NAME		     CONSTANT   VARCHAR2(3)           :=  OKC_API.G_APP_NAME;
  G_SQLERRM_TOKEN            CONSTANT   VARCHAR2(200)         := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN            CONSTANT   VARCHAR2(200)         := 'ERROR_CODE';
  G_LEN_CHK                  CONSTANT   VARCHAR2(200)         := 'OKC_LENGTH_EXCEEDS';
  G_UNQ                      CONSTANT   VARCHAR2(200)         := 'OKC_VALUE_NOT_UNIQUE';
  G_UNQS                     CONSTANT   VARCHAR2(200)         := 'OKC_VALUES_NOT_UNIQUE';
  G_NVL                      CONSTANT   VARCHAR2(200)         := 'OKC_NULL_VALUE_PASSED';
  G_NVL_CODE                 CONSTANT   VARCHAR2(200)         := 'OKC_NULL_CODE_PASSED';
  G_ALL_NVL                  CONSTANT   VARCHAR2(200)         := 'OKC_ALL_NULLS_PASSED';
  G_NOTFOUND                 CONSTANT   VARCHAR2(200)         := 'OKC_VIEW_NOT_FOUND';
  G_UNEXPECTED_ERROR	     CONSTANT   VARCHAR2(200)         := 'OKC_UNEXPECTED_ERROR';
  G_EXPECTED_ERROR	     CONSTANT   VARCHAR2(200)         := 'OKC_VALUE_ERROR';
  G_COL_NAME_TOKEN	     CONSTANT   VARCHAR2(200)         := OKC_API.G_COL_NAME_TOKEN;
  G_VIEW_TOKEN		     CONSTANT   VARCHAR2(200)         := 'G_VIEW_TOKEN';
  ---------------------------------------------------------------------------
  --GLOBAL CONSTANT
  ---------------------------------------------------------------------------

  procedure  call_user_hook(
  x_return_status                 OUT NOCOPY VARCHAR2,
	p_package_name            IN VARCHAR2,
	p_procedure_name          IN VARCHAR2,
	p_before_after            IN VARCHAR2);

----------------------------------------------------------------------------
 -- Count number of business days between two dates
----------------------------------------------------------------------------
  FUNCTION count_business_days(
		start_date IN DATE,
		end_date IN DATE)
	return NUMBER;

----------------------------------------------------------------------------
   --Check if valid code for a type in fnd lookup
----------------------------------------------------------------------------
   FUNCTION check_lookup_code(
		p_type in VARCHAR2,
		p_code IN VARCHAR2)
  return VARCHAR2;


----------------------------------------------------------------------------
   --Functions from John to get data from JTF objects
----------------------------------------------------------------------------
FUNCTION GET_NAME_FROM_JTFV(
		p_object_code 	IN VARCHAR2,
		p_id1 		IN VARCHAR2,
		p_id2 		IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION GET_DESC_FROM_JTFV(
		p_object_code 	IN VARCHAR2,
		p_id1 		IN VARCHAR2,
		p_id2 		IN VARCHAR2)
RETURN VARCHAR2;

PROCEDURE GET_NAME_DESC_FROM_JTFV(
		p_object_code 	IN VARCHAR2,
		p_id1 		IN VARCHAR2,
		p_id2 		IN VARCHAR2,
		x_name 	 OUT NOCOPY VARCHAR2,
		x_description  OUT NOCOPY VARCHAR2);

FUNCTION  GET_SQL_FROM_JTFV(p_object_code IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  GET_SELECTNAME_FROM_JTFV(p_object_code IN VARCHAR2,p_id IN NUMBER) RETURN VARCHAR2;

Function Get_All_K_Access_Level(p_chr_id IN NUMBER,
                                p_application_id IN NUMBER Default Null,
                                p_scs_code IN VARCHAR2 Default Null) Return Varchar2;


----------------------------------------------------------------------
---               get_k_access_level
----------------------------------------------------------------------
-- Function Get_K_Access_Level
-- This function checks whether the current user has access to a given
-- contract. The contract id and the subclass (optionally) are passed
-- in. The called from parameter denotes whether the function was called
-- from forms or the Java(security) code in contracts online. An orig
-- source code of KSSA_HDR means that the contract was created in contracts
-- online. Currently to isolate the contracts from contracts online and
-- the contracts created in forms, a contracts created in forms will have
-- only a read access in online, except attachments. Any
-- attachment created in forms, can be updated in contracts online subject
-- to the modify access being available to the user. Any contract created
-- in contracts online can be modified in forms as per the rules pertaining
-- to forms contracts.
-- It returns the highest type of access that the user has based on the
-- setup and the source. The types are:
--     U - Update
--     R - Read only
--     N - No access
----------------------------------------------------------------------

Function Get_K_Access_Level(p_chr_id IN NUMBER,
                            p_scs_code IN VARCHAR2 Default Null,
                            p_called_from IN VARCHAR2 Default 'F',
                            p_update_attachment IN VARCHAR2 Default 'false',
			    p_orig_source_code IN VARCHAR2 DEFAULT Null  ) Return Varchar2;

Function Create_K_Access(p_scs_code IN VARCHAR2 ) Return Boolean;

-----------------------------------------------------------------------------
--copies clob text to other recs with same source_lang as lang
------------------------------------------------------------------------------
FUNCTION Copy_CLOB(id number,release varchar2,lang varchar2)
 RETURN VARCHAR2;

-----------------------------------------------------------------------------
-- copies clob text to other recs with same source_lang as lang
-- in OKC_K_ARTICLES_TL table
------------------------------------------------------------------------------
FUNCTION Copy_Articles_Text(p_id NUMBER,lang varchar2,p_text VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

-----------------------------------------------------------------------------
-- copies standard article text to non-standard article's varied text
------------------------------------------------------------------------------
FUNCTION Copy_Articles_Varied_Text(
				p_article_id	NUMBER,
				p_sae_id	NUMBER,
				lang varchar2)
RETURN VARCHAR2;

-----------------------------------------------------------------------------
--Function to retrieve the Organization Title for forms; called from OKCSTAND.pll
------------------------------------------------------------------------------
FUNCTION Get_Org_Window_Title
RETURN VARCHAR2;


PROCEDURE forms_savepoint(p_savepoint IN VARCHAR2);

PROCEDURE forms_rollback(p_savepoint IN VARCHAR2);

PROCEDURE init_msg_list(
		p_init_msg_list	IN VARCHAR2);

PROCEDURE set_message (
	p_app_name		IN VARCHAR2 DEFAULT OKC_API.G_APP_NAME,
	p_msg_name		IN VARCHAR2,
	p_token1		IN VARCHAR2 DEFAULT NULL,
	p_token1_value		IN VARCHAR2 DEFAULT NULL,
	p_token2		IN VARCHAR2 DEFAULT NULL,
	p_token2_value		IN VARCHAR2 DEFAULT NULL,
	p_token3		IN VARCHAR2 DEFAULT NULL,
	p_token3_value		IN VARCHAR2 DEFAULT NULL,
	p_token4		IN VARCHAR2 DEFAULT NULL,
	p_token4_value		IN VARCHAR2 DEFAULT NULL,
	p_token5		IN VARCHAR2 DEFAULT NULL,
	p_token5_value		IN VARCHAR2 DEFAULT NULL,
	p_token6		IN VARCHAR2 DEFAULT NULL,
	p_token6_value		IN VARCHAR2 DEFAULT NULL,
	p_token7		IN VARCHAR2 DEFAULT NULL,
	p_token7_value		IN VARCHAR2 DEFAULT NULL,
	p_token8		IN VARCHAR2 DEFAULT NULL,
	p_token8_value		IN VARCHAR2 DEFAULT NULL,
	p_token9		IN VARCHAR2 DEFAULT NULL,
	p_token9_value		IN VARCHAR2 DEFAULT NULL,
	p_token10		IN VARCHAR2 DEFAULT NULL,
	p_token10_value		IN VARCHAR2 DEFAULT NULL
);

/*
-------------------------------------------------------------------------------------------
-- Procedure:           get_trace_path
-- Version:		1.0
-- Purpose:             define the root directory for trace files
--
-- In Parameters:
-- Out Parameters:
--
FUNCTION get_trace_path (p_path IN VARCHAR2)
RETURN VARCHAR2;

-------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------
-- Procedure:           close_trace_file
-- Version:		1.0
-- Purpose:             close the trace file for the current session
--
-- In Parameters:
-- Out Parameters:
--
PROCEDURE close_trace_file;

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-- Procedure:           reset_trace_context
-- Version:		1.0
-- Purpose:             Resets the trace context or closes a log file for a conc.program
--
-- In Parameters:
-- Out Parameters:
--
PROCEDURE reset_trace_context;

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-- Procedure:           open_trace_file
-- Version:		1.0
-- Purpose:             open a trace file for the current session
--
-- In Parameters:
-- Out Parameters:
--
PROCEDURE open_trace_file(g_request_id NUMBER);

*/

-------------------------------------------------------------------------------------------
-- Procedure:           set_trace_context
-- Version:		1.0
-- Purpose:             sets the trace context or opens a log file for a conc.program
--
-- In Parameters:
-- Out Parameters:
--
PROCEDURE set_trace_context(g_request_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2);
--
-------------------------------------------------------------------------------------------
-- Procedure:           stop_trace
-- Version:		1.0
-- Purpose:             Turn off the trace mode
--
-- In Parameters:
-- Out Parameters:
--
PROCEDURE stop_trace;

-------------------------------------------------------------------------------------------
-- Procedure:           print_output
-- Version:		1.0
-- Purpose:             write a output line in the output file
--
-- In Parameters:
-- Out Parameters:
--
PROCEDURE print_output (p_indent     IN NUMBER,
			p_trace_line IN VARCHAR2);

-------------------------------------------------------------------------------------------
-- Procedure:           print_trace
-- Version:		1.0
-- Purpose:             write a trace line in the trace file
--
-- In Parameters:
-- Out Parameters:
--
PROCEDURE print_trace (p_indent     IN NUMBER,
			     p_trace_line IN VARCHAR2,
                       p_level      IN NUMBER DEFAULT 1,
                       p_module     IN VARCHAR2 DEFAULT 'OKC');

-------------------------------------------------------------------------------------------
-- Procedure:           print_trace_header
-- Purpose:             print the standard header for trace files
--
-- In Parameters:
-- Out Parameters:
--
PROCEDURE print_trace_header;

-------------------------------------------------------------------------------------------
-- Procedure:           print_trace_footer
-- Purpose:             print the standard footer for trace files
--
-- In Parameters:
-- Out Parameters:
--
PROCEDURE print_trace_footer;

-------------------------------------------------------------------------------------------
-- Procedure:           init_trace
-- Version:		1.0
-- Purpose:             setup the trace mode
--
-- In Parameters:
-- Out Parameters:
--
PROCEDURE init_trace;

-------------------------------------------------------------------------------------------
-- Function           get_userenv_lang
-- Purpose:           This function returns the value of USERENV('LANG').
--                    Once it has retrieved the value, it is cached and subsequent calls
--                    to this function from the same session, do not result in a database
--                    hit. This is because a := USERENV('LANG') results in a
--                    SELECT USERENV('LANG') FROM SYS.DUAL; and can be an overhead
--                    for mass INSERTs/UPDATEs.
--
--                    Caching is done in the global variable g_userenv_lang
--                    declared in the package BODY
--
--                    This is a partial fix for Bug 1365356.
--
-- In Parameters : None
-- Out Parameters: None
-- Return value  : VARCHAR2
--

FUNCTION get_userenv_lang RETURN VARCHAR2;

Function get_prcnt(
	p_owner varchar2,
	p_table varchar2,
	p_column varchar2,
	p_value varchar2) return number;

-- returns 0 if small group
-- returns 1 if not small group
Function grp_dense(p_grp_like varchar2) return number;

-------------------------------------------------------------------------
function DECODE_LOOKUP (        p_lookup_type varchar2,
                                p_lookup_code varchar2) return varchar2;

PROCEDURE Set_Search_String(
      p_srch_str      IN         VARCHAR2,
      x_return_status OUT NOCOPY VARCHAR2);

-------------------------------------------------------------------
---- Variable used in Set_Search_String
-------------------------------------------------------------------
  g_qry_clause Varchar2(2000);

PROCEDURE Get_Search_String(
         x_srch_str OUT NOCOPY VARCHAR2);

----------------------------------------------------------------------------
---Procedure to generate contract number
----------------------------------------------------------------------------

PROCEDURE generate_contract_number(
      x_contract_number OUT NOCOPY VARCHAR2,
      x_return_status OUT NOCOPY VARCHAR2);

-------------------------------------------------------------------------
function get_application_name ( p_application_id number) return varchar2;

-------------------------------------------------------------------------
function DECODE_LOOKUP_DESC (   p_lookup_type varchar2,
                                p_lookup_code varchar2) return varchar2;
----------------------------------------------------------------------------
---Procedure to Prepare Contract Terms (dummy in 11.5.9, real for 11.5.10)
----------------------------------------------------------------------------
PROCEDURE Prepare_Contract_Terms(
    p_chr_id        IN NUMBER,
    x_doc_id        OUT NOCOPY NUMBER,
    x_doc_type      OUT NOCOPY VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2
  );
------------------------------------------------------------------------

----------------------------------------------------------------------------
--Function to decide to a descriptive flexfield should be displayed
--It will return 'Y' if at least one of the DFF segment is both enabled and displayed
--It will return 'N' otherwise
--p_api_version: standard input parameter for the API version
--p_init_msg_list: standard input parameter for initialize message or not, defaulted to False
--p_application_short_name: the three letter application short name, e.g. 'OKC'
--p_dff_name: the name of the descriptive flexfield, e.g., 'DELIVERABLES_FLEX'
----------------------------------------------------------------------------
FUNCTION Dff_Displayed ( p_api_version      IN  NUMBER,
                            p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,
                            p_application_short_name VARCHAR2,
                            p_dff_name VARCHAR2,
                            x_return_status    OUT NOCOPY VARCHAR2,
                            x_msg_data         OUT NOCOPY VARCHAR2,
                            x_msg_count        OUT NOCOPY NUMBER)
                            return VARCHAR2;

----------------------------------------------------------------------------------------
----Function to check if a user has access to a contract.   --added for bug 9648125
-----------------------------------------------------------------------------------------
FUNCTION ACCESS_ELIGIBLE (object_schema in varchar2, object_name varchar2) return VARCHAR2;
END OKC_UTIL;

/
