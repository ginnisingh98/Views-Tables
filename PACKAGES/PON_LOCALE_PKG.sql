--------------------------------------------------------
--  DDL for Package PON_LOCALE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_LOCALE_PKG" AUTHID CURRENT_USER as
/*$Header: PONLOCS.pls 120.1.12010000.2 2012/12/10 11:04:38 sgulkota ship $ */

/* Constants defined for the name format */
NAME_FIRST_LAST CONSTANT NUMBER := 1;
NAME_LAST_FIRST CONSTANT NUMBER := 2;
NAME_FIRST CONSTANT NUMBER := 3;
NAME_LAST CONSTANT NUMBER := 4;
NAME_TITLE_LAST CONSTANT NUMBER := 5;
NAME_TITLE_LAST_FIRST CONSTANT NUMBER := 6;
NAME_TITLE_FIRST_LAST CONSTANT NUMBER := 7;
NAME_TITLE_FIRST CONSTANT NUMBER := 8;
NAME_PREFIX_F_M_L_SUFFIX CONSTANT NUMBER := 9;
NAME_F_M_L_SUFFIX CONSTANT NUMBER := 10;
NAME_FIRST_M_LAST CONSTANT NUMBER := 11;
NAME_LAST_TITLE_FIRST CONSTANT NUMBER := 12;
--This is the default pattern that will be used across sourcing.
--This will be used by the function party_display_name_for_queries.
--One has to change this variable to appropriate display pattern if
--one needs to change the name display pattern in future.
DEFAULT_NAME_DISPLAY_PATTERN CONSTANT NUMBER := NAME_LAST_TITLE_FIRST;
/**
  Retrieves Party display name according to the given Name format.
*/
PROCEDURE party_display_name (
  p_first_name	   IN VARCHAR2
, p_last_name      IN VARCHAR2
, p_middle_name    IN VARCHAR2
, p_prefix         IN VARCHAR2
, p_suffix         IN VARCHAR2
, p_name_format    IN NUMBER
, p_language       IN VARCHAR2
, x_display_name  OUT NOCOPY VARCHAR2
, x_status        OUT NOCOPY VARCHAR2
, x_exception_msg OUT NOCOPY VARCHAR2
);

/**
  Retrieves Party display name according to the given Name format.
*/
PROCEDURE party_display_name (
  p_first_name	   IN VARCHAR2
, p_last_name      IN VARCHAR2
, p_name_format    IN NUMBER
, p_language       IN VARCHAR2
, x_display_name  OUT NOCOPY VARCHAR2
, x_status        OUT NOCOPY VARCHAR2
, x_exception_msg OUT NOCOPY VARCHAR2
);
/**
  Retrieves Party display name according to the given Name format.
*/

PROCEDURE retrieve_party_display_name (
  p_party_id       IN NUMBER
, p_name_format    IN NUMBER
, p_language       IN VARCHAR2
, x_display_name  OUT NOCOPY VARCHAR2
, x_status        OUT NOCOPY VARCHAR2
, x_exception_msg OUT NOCOPY VARCHAR2
);

/**
  Returns Party display name according to the given Name format.
*/
FUNCTION get_party_display_name(
  p_party_id NUMBER
, p_name_format NUMBER
, p_language VARCHAR2)
                     RETURN VARCHAR2;

/**
  Returns Party display name where
  language : userenv('LANG')
  Name_Format : NAME_FIRST_LAST
*/
FUNCTION get_party_display_name( p_party_id  NUMBER) RETURN VARCHAR2;


/**
  Retrieves Party display name according to the given Name format.
  Wrapper on the procedure retrieve_party_display_name
*/
FUNCTION party_display_name (
  p_first_name	   IN VARCHAR2
, p_last_name      IN VARCHAR2
, p_middle_name    IN VARCHAR2
, p_prefix         IN VARCHAR2
, p_suffix         IN VARCHAR2
, p_language       IN VARCHAR2) RETURN VARCHAR2;

--Fix for bug 14831857
--Overloading function with party_id
FUNCTION party_display_name (
  p_first_name	   IN VARCHAR2
, p_last_name      IN VARCHAR2
, p_middle_name    IN VARCHAR2
, p_prefix         IN VARCHAR2
, p_suffix         IN VARCHAR2
, p_language       IN VARCHAR2
, p_party_id       IN NUMBER) RETURN VARCHAR2;

END PON_LOCALE_PKG;

/

  GRANT EXECUTE ON "APPS"."PON_LOCALE_PKG" TO "EBSBI";
