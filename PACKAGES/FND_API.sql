--------------------------------------------------------
--  DDL for Package FND_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_API" AUTHID DEFINER AS
/* $Header: AFASAPIS.pls 120.1 2005/07/02 03:56:53 appldev ship $ */

--  *** G_MISS_XXX should no longer be used to default missing values.
--  *** Please see GSCC Standard File.Sql.48 and the new G_NULL_XXXX
--  *** constants defined at the end of this spec.
--  Global constants that represent missing values. These constants
--  are used as default values for PL/SQL procedures and functions
--  parameters to distinguish between parameters that are passed and
--  have a value of NULL and those which are not passed to the procedure.
G_MISS_NUM  	CONSTANT    NUMBER  	:= 9.99E125;
G_MISS_CHAR   	CONSTANT    VARCHAR2(1) := chr(0);
G_MISS_DATE    	CONSTANT    DATE    	:= TO_DATE('1','j');

--  Pre-defined validation levels
--
--  	NONE : 	Means the lowest validation level possible for a
--    	    	particular transaction.
--
--    	FULL : 	Means the highest validation level possible for a
--  	    	particular transaction.


G_VALID_LEVEL_NONE  CONSTANT	NUMBER := 0;
G_VALID_LEVEL_FULL  CONSTANT	NUMBER := 100;

--  FUNCTION	Compatible_API_Call
--
--  Usage   	Used by all APIs to compare a caller version number to
--  	    	an API version number in order to detect incompatible
--  	    	API calls.
--  	    	Every API has a standard call to this function.
--
--  Desc    	This function compares the major version number passed
--  	    	by an API caller to the current major version number
--  	    	of the API itself, if they are different this means
--  	    	that a program is making an incompatible API call. In
--  	    	this case, the function issues a standard unexpected
--  	    	error message and returns FALSE.
--
--  Parameters
--
--  Return  	Boolean.
--    	    	If the p_current_version_number matches the
--  	    	p_caller_version_number the function returns TRUE else
--  	    	it returns FALSE.


FUNCTION Compatible_API_Call
( p_current_version_number  	IN NUMBER		,
  p_caller_version_number    	IN NUMBER		,
  p_api_name	    		IN VARCHAR2		,
  p_pkg_name	    		IN VARCHAR2
)
RETURN BOOLEAN;

--  API return status
--
--  G_RET_STS_SUCCESS means that the API was successful in performing
--  all the operation requested by its caller.
--
--  G_RET_STS_ERROR means that the API failed to perform one or more
--  of the operations requested by its caller.
--
--  G_RET_STS_UNEXP_ERROR means that the API was not able to perform
--  any of the operations requested by its callers because of an
--  unexpected error.


G_RET_STS_SUCCESS   	CONSTANT    VARCHAR2(1)	:=  'S';
G_RET_STS_ERROR	      	CONSTANT    VARCHAR2(1)	:=  'E';
G_RET_STS_UNEXP_ERROR  	CONSTANT    VARCHAR2(1)	:=  'U';

--  API error exceptions.
--  G_EXC_ERROR :   Is used within API bodies to indicate an error,
--		    this exception should always be handled within the
--		    API body and p_return_status shoul;d be set to
--		    error. An API should never return this exception.
--  G_EXC_UNEXPECTED_ERROR :
--		    Is raised by APIs when encountering an unexpected
--		    error.

G_EXC_ERROR		EXCEPTION;
G_EXC_UNEXPECTED_ERROR 	EXCEPTION;

--  Global constants representing TRUE and FALSE.

G_TRUE	    CONSTANT	VARCHAR2(1) := 'T';
G_FALSE	    CONSTANT	VARCHAR2(1) := 'F';

--  FUNCTION	To_Boolean ( p_char IN VARCHAR2 ) RETURN BOOLEAN
--
--  Usage   	Used to convert varchar2 boolean like parameters into
--		their boolean equivalents.
--
--  Desc    	This function converts a character string into its
--		BOOLEAN equivalent by comparing it against the G_TRUE
--		and G_FALSE constants defined in this package. the
--		comparison is as follows :
--
--		p_char = G_TRUE	    => Returns  TRUE
--		p_char = G_FALSE    => Returns  FALSE
--		p_char = NULL	    => Returns  NULL
--		Otherwise, the function raises the exception
--		FND_API.G_EXC_UNEXPECTED_ERROR, and adds a message o
--		the API message list.
--
--  Parameters
--  IN		p_char :
--		    Character value to be converted. Legal values are
--			'T' or FND_API.G_TRUE
--			'F' or FND_API.G_FALSE
--			NULL
--  Return  	Boolean.
--		p_char = G_TRUE	    => Returns  TRUE
--		p_char = G_FALSE    => Returns  FALSE
--		p_char = NULL	    => Returns  NULL
--		Otherwise, the function raises the exception
--		FND_API.G_EXC_UNEXPECTED_ERROR, and adds a message o
--		the API message list.

FUNCTION    To_Boolean ( p_char IN VARCHAR2 ) RETURN BOOLEAN;

--  Types and constants used by shared API packages as well as the
--  PL/SQL API generator.

--  Attribute record type.

TYPE Attribute_Rec_Type IS RECORD
(   name		VARCHAR2(30)	:=  NULL
,   column		VARCHAR2(30)	:=  NULL
,   code		VARCHAR2(30)	:=  NULL
,   value		BOOLEAN		:=  FALSE
,   value_type		VARCHAR2(30)	:=  NULL
,   type		VARCHAR2(30)	:=  NULL
,   length		NUMBER		:=  NULL
,   context		BOOLEAN		:=  FALSE
,   category		NUMBER		:=  NULL
,   db_attr		BOOLEAN		:=  TRUE
,   pk_flag		BOOLEAN		:=  FALSE
,   text1		VARCHAR2(30)	:=  NULL
,   text2		VARCHAR2(30)	:=  NULL
,   text3		VARCHAR2(30)	:=  NULL
);

--  Attribute table type.

TYPE Attribute_Tbl_Type IS TABLE OF Attribute_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Gloabl attribute table.

g_attr_tbl	Attribute_Tbl_Type;

--  Missing constants

G_MISS_ATTR_REC			Attribute_Rec_Type;
G_MISS_ATTR_TBL			Attribute_Tbl_Type;

--  Entity record type.

TYPE Entity_Rec_Type IS RECORD
(   name		VARCHAR2(30)    :=  NULL
,   tbl			VARCHAR2(30)    :=  NULL
,   parent		NUMBER		:=  NULL
,   multiple		BOOLEAN		:=  FALSE
,   code		VARCHAR2(30)    :=  NULL
,   pk_column		VARCHAR2(30)    :=  NULL
,   text1		VARCHAR2(30)	:=  NULL
,   text2		VARCHAR2(30)	:=  NULL
,   text3		VARCHAR2(30)	:=  NULL
);

--  Entity table type.

TYPE Entity_Tbl_Type IS TABLE OF Entity_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Missing constants

G_MISS_ENTITY_REC		Entity_Rec_Type;
G_MISS_ENTITY_TBL		Entity_Tbl_Type;

--  Gloabl entity table.

g_entity_tbl	Entity_Tbl_Type;

--  Added for New GSCC Standard File.Sql.48
--  The new standard is to treat missing values as NULL and to use the
--  G_NULL_XXX constants to assign a value of NULL to a variable if needed.
G_NULL_NUM  	CONSTANT    NUMBER  	:= 9.99E125;
G_NULL_CHAR   	CONSTANT    VARCHAR2(1) := chr(0);
G_NULL_DATE    	CONSTANT    DATE    	:= TO_DATE('1','j');

END FND_API;

 

/
