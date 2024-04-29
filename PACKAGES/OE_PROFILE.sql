--------------------------------------------------------
--  DDL for Package OE_PROFILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PROFILE" AUTHID CURRENT_USER AS
/* $Header: OEXPROFS.pls 120.0 2005/06/01 01:12:29 appldev noship $ */
/*#
* This API contains utilities used to retrieve Order Management profile options
* @rep:scope            private
* @rep:product          ONT
* @rep:lifecycle        active
* @rep:displayname      Order Management Profile Option Retrieval API
* @rep:category         BUSINESS_ENTITY ONT_SALES_ORDER
*/


-----------------------------------------------------------------
-- PROCEDURE GET
-- Use this instead of FND_PROFILE.GET to retrieve the value of
-- a profile option
-----------------------------------------------------------------
PROCEDURE GET
	(NAME		IN VARCHAR2
	,VAL		OUT NOCOPY /* file.sql.39 change */ VARCHAR2
	);


-----------------------------------------------------------------
-- FUNCTION VALUE
-- Use this function instead of FND_PROFILE.VALUE to retrieve the value of
-- a profile option
-----------------------------------------------------------------
FUNCTION VALUE
	(NAME 		IN VARCHAR2,
	ORG_ID 		IN NUMBER DEFAULT NULL
	)
RETURN VARCHAR2;


-----------------------------------------------------------------
-- FUNCTION VALUE_WNPS
-- Use this function instead of FND_PROFILE.VALUE to retrieve the value of
-- a profile option
-- Since this function has pragma WNPS associated with it, it can be
-- used in where clauses of SQL statements.
-----------------------------------------------------------------
FUNCTION VALUE_WNPS
	(NAME 		IN VARCHAR2,
	ORG_ID 		IN NUMBER DEFAULT NULL
	)
RETURN VARCHAR2;


-----------------------------------------------------------------
-- FUNCTION VALUE_SPECIFIC
-- Use this function instead of FND_PROFILE.VALUE_SPECIFIC to retrieve
-- the value of a profile option based on a user, responsiblity and application.
-- Since this function has pragma WNPS associated with it, it can also be
-- used in where clauses of SQL statements
-----------------------------------------------------------------
FUNCTION VALUE_SPECIFIC
	(NAME		IN VARCHAR2
	,USER_ID	IN NUMBER DEFAULT NULL
	,RESPONSIBILITY_ID	IN NUMBER DEFAULT NULL
	,APPLICATION_ID		IN NUMBER DEFAULT NULL
	)
RETURN VARCHAR2;


/*#
* This function returns the value of a profile option in the context of the user who created the line or order being processed.
* @param                p_header_id Input parameter containing the header id of the header being processed
* @param                p_line_id Input parameter containing the line id of the line being processed
* @param                p_profile_option_name Input parameter containing the name of the profile option being retrieved
* @rep:scope	 	private
* @rep:lifecycle	active
* @rep:category	        BUSINESS_ENTITY	ONT_SALES_ORDER
* @rep:displayname	Value
*/
FUNCTION VALUE (p_header_id                           IN NUMBER     DEFAULT  NULL,
		p_line_id                           IN NUMBER    DEFAULT NULL,
		p_profile_option_name    IN VARCHAR2)

RETURN VARCHAR2;

Type WF_Context_Rec_Type is Record
(
 user_id       Number  := null
,resp_appl_id  Number  := null
,resp_id       Number  := null
,org_id        Number  := null
,position      Number  := null
);


TYPE WF_Context_Tbl_Type IS TABLE OF WF_Context_Rec_Type
INDEX BY VARCHAR2(30);

Line_Context_Tbl                              WF_Context_Tbl_Type;
Header_Context_Tbl                         WF_Context_Tbl_Type;
MAX_CONTEXT_CACHE_SIZE   NUMBER := 15;


/*#
* This procedure tries to get the context values for a particular header or line from the cache
* @param                p_entity Input parameter that specifies whether a header or line is being processed
* @param                p_entity_id Input parameter that specifies the header id or line id
* @param                x_application_id Output parameter containing the application id associated with the user who created the input header or line
* @param                x_user_id Output parameter containing the user id associated with the user who created the input header or line
* @param                x_responsibility_id Output parameter containing the responsibility id associated with the user who created the input header or line
* @param                x_org_id Output parameter containing the org id associated with the user who created the input header or line
* @param                x_result Output parameter containing the result of the cache query
* @rep:scope	 	private
* @rep:lifecycle	active
* @rep:category	        BUSINESS_ENTITY	ONT_SALES_ORDER
* @rep:displayname	Get Cached Context
*/
PROCEDURE GET_CACHED_CONTEXT(   p_entity     IN   VARCHAR2,
			        p_entity_id   IN NUMBER,
				x_application_id OUT NOCOPY   NUMBER,
				x_user_id   OUT NOCOPY     NUMBER,
				x_responsibility_id  OUT NOCOPY   NUMBER,
				x_org_id  OUT NOCOPY NUMBER,
				x_result  OUT NOCOPY  VARCHAR2);

/*#
* This procedure caches the context values for a particular header or line
* @param                p_entity Input parameter that specifies whether a header or line is being processed
* @param                p_entity_id Input parameter that specifies the header id or line id
* @param                p_application_id Input parameter containing the application id associated with the user who created the input header or line
* @param                p_user_id Input parameter containing the user id associated with the user who created the input header or line
* @param                p_responsibility_id Input parameter containing the responsibility id associated with the user who created the input header or line
* @param                p_org_id Input parameter containing the org id associated with the user who created the input header or line
* @rep:scope	 	private
* @rep:lifecycle	active
* @rep:category	        BUSINESS_ENTITY	ONT_SALES_ORDER
* @rep:displayname	Put Cached Context
*/
PROCEDURE PUT_CACHED_CONTEXT(   p_entity     IN   VARCHAR2,
			        p_entity_id   IN NUMBER,
	                        p_application_id IN   NUMBER,
				p_user_id   IN     NUMBER,
				p_responsibility_id  IN   NUMBER,
				p_org_id  IN NUMBER);

TYPE Prf_Rec_Type IS RECORD
(   prf_value         varchar2(240)   := NULL
  , position           NUMBER := NULL
);

TYPE  Prf_Tbl_Type IS TABLE OF Prf_Rec_Type
INDEX BY VARCHAR2(100);

Prf_Tbl                 Prf_Tbl_Type;


max_profile_cache_size  NUMBER := max_context_cache_size * 15;


/*#
* This procedure tries to retrieve a cached profile option value for a particular context
* @param                p_profile_option_name Input parameter that specifies the profile option being queried
* @param                p_application_id Input parameter containing the application id for the desired context
* @param                p_user_id Input parameter containing the user id for the desired context
* @param                p_responsibility_id Input parameter containing the responsibility id for the desired context
* @param                p_org_id Input parameter containing the org id for the desired context
* @param                x_profile_option_value Output parameter containing the value of the profile option being queried
* @param                x_result Output parameter containing the result of the cache query
* @rep:scope	 	private
* @rep:lifecycle	active
* @rep:category	        BUSINESS_ENTITY	ONT_SALES_ORDER
* @rep:displayname	Get Cached Profile For Context
*/
PROCEDURE GET_CACHED_PROFILE_FOR_CONTEXT(   p_profile_option_name     IN   VARCHAR2,
                                            p_application_id IN NUMBER,
                                            p_user_id   IN     NUMBER,
                                            p_responsibility_id  IN   NUMBER,
           		  	            p_org_id  IN NUMBER,
	                                    x_profile_option_value OUT NOCOPY VARCHAR2,
	                                    x_result OUT NOCOPY  VARCHAR2);

/*#
* This procedure tries to cache a profile option value for a particular context
* @param                p_profile_option_name Input parameter that specifies the profile option
* @param                p_application_id Input parameter containing the application id
* @param                p_user_id Input parameter containing the user id
* @param                p_responsibility_id Input parameter containing the responsibility id
* @param                p_org_id Input parameter containing the org id
* @param                p_profile_option_value Input parameter containing the profile option value being cached
* @rep:scope	 	private
* @rep:lifecycle	active
* @rep:category	        BUSINESS_ENTITY	ONT_SALES_ORDER
* @rep:displayname	Put Cached Profile For Context
*/
PROCEDURE PUT_CACHED_PROFILE_FOR_CONTEXT (   p_profile_option_name     IN   VARCHAR2,
	                                     p_application_id IN   NUMBER,
	                                     p_user_id   IN     NUMBER,
	                                     p_responsibility_id  IN   NUMBER,
		       		             p_org_id  IN NUMBER,
	                                     p_profile_option_value  IN VARCHAR2);


END OE_PROFILE;

 

/
