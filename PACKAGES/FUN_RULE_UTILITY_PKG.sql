--------------------------------------------------------
--  DDL for Package FUN_RULE_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_RULE_UTILITY_PKG" AUTHID CURRENT_USER AS
/*$Header: FUNXTMRULGENUTS.pls 120.1 2006/02/22 10:51:10 ammishra noship $ */

--------------------------------------
-- public procedures and functions
--------------------------------------

/**
 * FUNCTION get_session_process_id
 *
 * DESCRIPTION
 *     Return OS process id of current session.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   10-Sep-2004    Amulya Mishra      Created.
 *
 */

FUNCTION get_session_process_id RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES ( get_session_process_id, WNDS, WNPS, RNPS );

/**
 * FUNCTION
 *     created_by
 *     creation_date
 *     last_updated_by
 *     last_update_date
 *     last_update_login
 *     request_id
 *     program_id
 *     program_application_id
 *     program_update_date
 *     user_id
 *
 * DESCRIPTION
 *     Return standard who value.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   10-Sep-2004    Amulya Mishra      Created.
 *
 */

FUNCTION created_by RETURN NUMBER;

FUNCTION creation_date RETURN DATE;

FUNCTION last_updated_by RETURN NUMBER;

FUNCTION last_update_date RETURN DATE;

FUNCTION last_update_login RETURN NUMBER;

FUNCTION request_id RETURN NUMBER;

FUNCTION program_id RETURN NUMBER;

FUNCTION program_application_id RETURN NUMBER;

FUNCTION application_id RETURN NUMBER;

FUNCTION program_update_date RETURN DATE;

FUNCTION user_id RETURN NUMBER;

FUNCTION Get_SchemaName (
    p_app_short_name             IN     VARCHAR2
) RETURN VARCHAR2;

FUNCTION Get_AppsSchemaName RETURN VARCHAR2;

FUNCTION Get_LookupMeaning (
    p_lookup_table                          IN     VARCHAR2 DEFAULT 'AR_LOOKUPS',
    p_lookup_type                           IN     VARCHAR2,
    p_lookup_code                           IN     VARCHAR2
) RETURN VARCHAR2;

/*
PROCEDURE CREATE_DUPLICATE_RULE(
          P_RULE_DETAIL_ID IN FUN_RULE_DETAILS.RULE_DETAIL_ID%TYPE,
          P_RULE_OBJECT_ID IN FUN_RULE_DETAILS.RULE_OBJECT_ID%TYPE
          );
*/

FUNCTION GET_MAX_SEQ (
    P_RULE_OBJECT_ID IN FUN_RULE_DETAILS.RULE_OBJECT_ID%TYPE
)RETURN NUMBER;

FUNCTION getApplicationID(p_AppShortName IN VARCHAR2)
                          RETURN  NUMBER;

FUNCTION getApplicationShortName(p_ApplicationId IN NUMBER)
                          RETURN VARCHAR2;

FUNCTION getValueSetDataType(p_ValueSetId  IN NUMBER)
                          RETURN VARCHAR2;

FUNCTION get_rule_dff_result_value(p_FlexFieldAppShortName	IN VARCHAR2,
                                   p_FlexFieldName		IN VARCHAR2,
				   p_AttributeCategory		IN VARCHAR2,
				   p_Attribute1			IN VARCHAR2,
				   p_Attribute2			IN VARCHAR2,
				   p_Attribute3			IN VARCHAR2,
				   p_Attribute4			IN VARCHAR2,
				   p_Attribute5			IN VARCHAR2,
				   p_Attribute6			IN VARCHAR2,
				   p_Attribute7			IN VARCHAR2,
				   p_Attribute8			IN VARCHAR2,
				   p_Attribute9			IN VARCHAR2,
				   p_Attribute10		IN VARCHAR2,
				   p_Attribute11		IN VARCHAR2,
				   p_Attribute12		IN VARCHAR2,
				   p_Attribute13		IN VARCHAR2,
				   p_Attribute14		IN VARCHAR2,
				   p_Attribute15		IN VARCHAR2
				   )RETURN VARCHAR2;

PROCEDURE print_debug(p_indent IN NUMBER,p_text IN VARCHAR2 );

FUNCTION get_moac_org_id RETURN NUMBER;

/* Rule Object Instance Enhancement for MULTIVALUE:
 * This function returns TRU if the RULE_OBJECT_ID passed is an instance or not.
 */

FUNCTION IS_USE_INSTANCE(p_rule_object_id IN NUMBER) RETURN BOOLEAN;

END FUN_RULE_UTILITY_PKG;

 

/
