--------------------------------------------------------
--  DDL for Package QP_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_SECURITY" AUTHID CURRENT_USER AS
/* $Header: QPXSECUS.pls 120.1 2005/08/19 16:10:12 spgopal noship $ */
/*#
 * This package contains a function to determine functional object access for a
 * user.
 *
 * @rep:scope public
 * @rep:product QP
 * @rep:displayname Object Security
 * @rep:category BUSINESS_ENTITY QP_PRICE_LIST
 * @rep:category BUSINESS_ENTITY QP_PRICE_MODIFIER
 */

C_PKG_NAME CONSTANT VARCHAR2(30) := 'QP_SECURITY';
C_TYPE_SET CONSTANT VARCHAR2(30) := 'SET';
G_SECURITY_CONTROL_PROFILE CONSTANT VARCHAR2(100) := 'QP_SECURITY_CONTROL';
G_SECURITY_DEFAULT_VIEWONLY CONSTANT VARCHAR2(100) := 'QP_SECURITY_DEFAULT_VIEWONLY';
G_SECURITY_DEFAULT_MAINTAIN CONSTANT VARCHAR2(100):= 'QP_SECURITY_DEFAULT_MAINTAIN';
G_SECURITY_ON CONSTANT VARCHAR2(5) := 'ON';
G_SECURITY_OFF CONSTANT VARCHAR2(5) := 'OFF';

G_SECURITY_LEVEL_NONE 	CONSTANT VARCHAR2(10) := 'NONE';
G_SECURITY_LEVEL_OU 	CONSTANT VARCHAR2(10) := 'OU';
G_SECURITY_LEVEL_USER 	CONSTANT VARCHAR2(10) := 'USER';
G_SECURITY_LEVEL_RESP 	CONSTANT VARCHAR2(10) := 'RESP';
G_SECURITY_LEVEL_GLOBAL CONSTANT VARCHAR2(10) := 'GLOBAL';

G_GRANTEE_OU 	CONSTANT VARCHAR2(10) := 'OU';
G_GRANTEE_USER 	CONSTANT VARCHAR2(10) := 'USER';
G_GRANTEE_RESP 	CONSTANT VARCHAR2(10) := 'RESP';

G_VIEW 		CONSTANT VARCHAR2(1) := 'V';
G_MAINTAIN 	CONSTANT VARCHAR2(1) := 'M';

G_FUNCTION_VIEW CONSTANT VARCHAR2(20) := 'QP_SECU_VIEW';
G_FUNCTION_COPY CONSTANT VARCHAR2(20) := 'QP_SECU_COPY';
G_FUNCTION_UPDATE CONSTANT VARCHAR2(20) := 'QP_SECU_UPDATE';
G_FUNCTION_DELETE CONSTANT VARCHAR2(20) := 'QP_SECU_DELETE';

G_PRICELIST_OBJECT 	CONSTANT VARCHAR2(5) := 'PRL';
G_MODIFIER_OBJECT 	CONSTANT VARCHAR2(5) := 'MOD';
G_AGREEMENT_OBJECT      CONSTANT VARCHAR2(5) := 'AGR';
G_FORMULA_OBJECT	CONSTANT VARCHAR2(5) := 'FOR';

G_PRICELIST_TYPE 	CONSTANT VARCHAR2(30) := 'PRL';
G_MODIFIER_SUR		CONSTANT VARCHAR2(30) := 'SLT';
G_MODIFIER_PRO  	CONSTANT VARCHAR2(30) := 'PRO';
G_MODIFIER_DLT		CONSTANT VARCHAR2(30) := 'DLT';
G_MODIFIER_DEL  	CONSTANT VARCHAR2(30) := 'DEL';
G_MODIFIER_CHARGES 	CONSTANT VARCHAR2(30) :='CHARGES';
G_AGREEMENT_TYPE 	CONSTANT VARCHAR2(30) := 'AGR';
G_AUTHORIZED 	CONSTANT VARCHAR2(1) := 'T';
G_DENIED 	CONSTANT VARCHAR2(1) := 'F';
G_ERROR 	CONSTANT VARCHAR2(1) := 'E';
G_UN_ERROR 	CONSTANT VARCHAR2(1) := 'U';

G_YES		CONSTANT VARCHAR2(1) := 'Y';
G_NO		CONSTANT VARCHAR2(1) := 'N';

G_FUNCTION_NAME_CACHE VARCHAR2(30) := null;
G_FUNCTION_ID_CACHE NUMBER := null;

G_OBJECT_ID_CACHE NUMBER := null;
G_INSTANCE_TYPE_CACHE qp_grants.instance_type%TYPE := null;--VARCHAR2(5) := null;

G_USER_NAME  VARCHAR2(240) := null;
G_RESP_ID    NUMBER := null;
G_ORG_ID     NUMBER := null;
G_USER_ID NUMBER := null;
--G_MENU_MAINTAIN_ID NUMBER := null;

Procedure Set_Grants(p_user_name IN VARCHAR2,
                     p_resp_id   IN NUMBER,
                     p_org_id    IN NUMBER
                    );

FUNCTION security_on
RETURN VARCHAR2;

FUNCTION GET_OBJECT_ID_FOR_INSTANCE(p_instance_type IN VARCHAR2 default null)
RETURN NUMBER;

/*#
 * This API is used to check if a specific user, logging in with a specific
 * responsibility and within a specific operating unit, has functional access to
 * a specific pricing object or not.
 *
 * @param p_function_name the level of access for which to check: either
 *        'QP_SECU_VIEW' or 'QP_SECU_UPDATE'
 * @param p_instance_type the type of the object: either 'PRL' for standard price
 *        list, 'MOD' for modifier list, or 'AGR' for agreement
 *        price list
 * @param p_instance_pk1 the list_header_id from qp_list_headers_b for the object
 * @param p_instance_pk2 not used
 * @param p_instance_pk3 not used
 * @param p_user_name the user name
 * @param p_resp_id the responsibility
 * @param p_org_id the operating unit
 *
 * @return T if the user has access to the object, F if the user does not have
 *         access to the object, and E-<error message> if an error occurred
 *         within the API
 *
 * @rep:displayname Check Function
 */
FUNCTION check_function(
        p_function_name IN VARCHAR2,
        p_instance_type  IN VARCHAR2,
        p_instance_pk1 IN  NUMBER,
        p_instance_pk2 IN  NUMBER default null,
        p_instance_pk3 IN  NUMBER default null,
        p_user_name IN VARCHAR2 default null,
        p_resp_id IN NUMBER default null,
        p_org_id IN NUMBER default null
)
RETURN VARCHAR2;

FUNCTION auth_instances(
 p_function_name		IN  VARCHAR2,
 p_instance_type		IN  VARCHAR2 default null,
 p_user_name IN VARCHAR2 default G_USER_NAME,
 p_resp_id   IN NUMBER default G_RESP_ID,
 p_org_id IN NUMBER default G_ORG_ID
) RETURN system.qp_inst_pk_vals;

PROCEDURE create_default_grants(
	p_instance_type IN VARCHAR2,
	p_instance_pk1 IN NUMBER,
        p_instance_pk2 IN NUMBER default null,
        p_instance_pk3 IN NUMBER default null,
        p_user_name IN VARCHAR2 default null,
        p_resp_id IN NUMBER default null,
        p_org_id IN NUMBER default null,
        x_return_status OUT NOCOPY VARCHAR2);

---------------vpd----------------
FUNCTION qp_v_sec (owner VARCHAR2, objname VARCHAR2)
RETURN VARCHAR2;

FUNCTION qp_vl_sec (owner VARCHAR2, objname VARCHAR2)
RETURN VARCHAR2;

FUNCTION GET_USER_ID (l_user_name IN VARCHAR2 default FND_GLOBAL.USER_NAME)
RETURN NUMBER;

FUNCTION GET_ORG_ID
RETURN NUMBER;

FUNCTION GET_RESP_ID
RETURN NUMBER;

FUNCTION GET_MENU_MAINTAIN_ID
RETURN NUMBER;

FUNCTION GET_UPDATE_ALLOWED (p_object_name IN VARCHAR2, p_list_header_id IN NUMBER)
RETURN VARCHAR2;

--------------vpd----------------


-------------moac vpd --------------
--added for MOAC
--this will be the VPD policy for the secured synonym qp_list_headers_b
--
-- Name
--   qp_org_security
--
-- Purpose
--   This function implements the security policy for the Multi-Org
--   Access Control mechanism for QP_LIST_HEADERS_B.
--   It is automatically called by the oracle
--   server whenever a secured table or view is referenced by a SQL
--   statement. Products should not call this function directly.
--
--   The security policy function is expected to return a predicate
--   (a WHERE clause) that will control which records can be accessed
--   or modified by the SQL statement. After incorporating the
--   predicate, the server will parse, optimize and execute the
--   modified statement.
--
-- Arguments
--   obj_schema - the schema that owns the secured object
--   obj_name   - the name of the secured object
--

FUNCTION QP_ORG_SECURITY(obj_schema VARCHAR2,
                      obj_name   VARCHAR2) RETURN VARCHAR2;

-------------moac vpd --------------

END qp_security;

 

/
