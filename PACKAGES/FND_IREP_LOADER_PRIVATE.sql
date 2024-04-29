--------------------------------------------------------
--  DDL for Package FND_IREP_LOADER_PRIVATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_IREP_LOADER_PRIVATE" AUTHID CURRENT_USER AS
/* $Header: AFIRLDRS.pls 120.2.12010000.2 2008/09/24 11:13:00 snalagan ship $ */
--
-- Procedure
--   UPLOAD_IREP_OBJECT
--
-- Purpose
--   Upload irep object
--
--
PROCEDURE UPLOAD_IREP_OBJECT(   P_UPLOAD_MODE IN VARCHAR2,
				P_OBJECT_NAME IN VARCHAR2,
				P_DEST_TABLE IN VARCHAR2,
				P_OWNER IN VARCHAR2,
				P_API_NAME IN VARCHAR2,
				P_OBJ_TYPE IN VARCHAR2,
				P_PRODUCT IN VARCHAR2,
				P_IMP_NAME IN VARCHAR2,
				P_COMPATABILITY IN VARCHAR2,
				P_SCOPE IN VARCHAR2,
				P_LIFECYCLE IN VARCHAR2,
				P_SOURCE_FILE_PRODUCT IN VARCHAR2,
				P_SOURCE_FILE_PATH IN VARCHAR2,
				P_SOURCE_FILE_NAME IN VARCHAR2,
				P_SOURCE_FILE_VERSION IN VARCHAR2,
				P_DESCRIPTION IN VARCHAR2,
				P_STANDARD IN VARCHAR2,
				P_STANDARD_VERSION IN VARCHAR2,
				P_STANDARD_SPEC IN VARCHAR2,
				P_DISPNAME IN VARCHAR2,
				P_SHORTDISC IN VARCHAR2,
				P_TIMESTAMP IN VARCHAR2,
				P_OI_FLAG IN VARCHAR2,
				P_MAPCODE IN VARCHAR2,
				P_PARSER_VERSION IN VARCHAR2,
				P_SDO_DEF_CLASS IN VARCHAR2,
				P_SDO_CLASS_NAME IN VARCHAR2,
				P_SDO_IS_FILTER IN VARCHAR2,
				P_SDO_FILTER_REQUIRED IN VARCHAR2,
				P_SDO_IS_EXPRESSION IN VARCHAR2,
				P_SB_INTERFACE_CLASS IN VARCHAR2,
				P_CRAWL_CRAWLABLE IN VARCHAR2,
				P_CRAWL_VISIBILITY_LEVEL IN VARCHAR2,
                                P_CRAWL_SEARCH_PLUGIN IN VARCHAR2,
                                P_CRAWL_UI_FUNCTION IN VARCHAR2,
                                P_CRAWL_CHANGE_EVENT_NAME IN VARCHAR2,
                                P_CRAWL_CHANGE_NTF IN VARCHAR2,
                                P_CRAWL_DRIVING_TABLE IN VARCHAR2);

--
-- Procedure
--   UPLOAD_Parents
--
-- Purpose
--   Upload parents
--
--
PROCEDURE UPLOAD_PARENTS(P_UPLOAD_MODE IN VARCHAR2,
			   P_OBJECT_NAME IN VARCHAR2,
		           P_DEST_TABLE IN VARCHAR2,
			   P_PARENT_NAME IN VARCHAR2);



--
-- Procedure
--   UPLOAD_OBJECT_CATEGORY
--
-- Purpose
--   Upload Object Category
--
PROCEDURE UPLOAD_OBJECT_CATEGORY(  P_UPLOAD_MODE IN VARCHAR2,
				   P_OBJECT_NAME IN VARCHAR2,
				   P_DEST_TABLE IN VARCHAR2,
				   P_TYPE IN VARCHAR2,
				   P_CODE IN VARCHAR2,
				   P_SEQUENCE IN VARCHAR2);


--
-- Procedure
--   UPLOAD_OBJ_CHILD_ANNOTATIONS
--
-- Purpose
--   Upload Object Child Annotations
--
PROCEDURE UPLOAD_OBJ_CHILD_ANNOTATIONS(  P_UPLOAD_MODE IN VARCHAR2,
					 P_OBJECT_NAME IN VARCHAR2,
                                         P_DEST_TABLE IN VARCHAR2,
					 P_CHILD_FLAG IN VARCHAR2,
					 P_VALUE IN VARCHAR2);


--
-- Procedure
--   UPLOAD_TYPE_MEMBERS
--
-- Purpose
--   Upload Type Members
--
PROCEDURE UPLOAD_TYPE_MEMBERS(   P_UPLOAD_MODE IN VARCHAR2,
				 P_OBJECT_NAME IN VARCHAR2,
                                 P_DEST_TABLE IN VARCHAR2,
				 P_SEQUENCE IN VARCHAR2,
				 P_INNERTYPE_SEQUENCE IN VARCHAR2,
				 P_MEMBER_NAME IN VARCHAR2,
				 P_TYPE IN VARCHAR2,
				 P_PRECISION IN VARCHAR2,
				 P_SIZE IN VARCHAR2,
				 P_SCALE IN VARCHAR2,
				 P_NULL_ALLOWED IN VARCHAR2,
				 P_DESCRIPTION IN VARCHAR2,
				 P_ATTR_SET IN VARCHAR2,
				 P_PRIMARY_KEY IN VARCHAR2,
				 P_TRANSLATABLE IN VARCHAR2,
				 P_COMPOSITE IN VARCHAR2,
				 P_DOMAIN_NAME IN VARCHAR2,
				 P_MEMBER_TYPE_NAME IN VARCHAR2,
				 P_SEARCH_CRITERIA_TYPE IN VARCHAR2,
				 P_ATTACHMENT IN VARCHAR2,
				 P_MIME_TYPE IN VARCHAR2,
				 P_DOMAIN_IMPLEMENTATION IN VARCHAR2,
				 P_IS_SORTABLE IN VARCHAR2,
				 P_CRAWL_IS_DATE_BASED IN VARCHAR2,
                                 P_CRAWL_MEMBER_VIS_LVL IN VARCHAR2,
                                 P_CRAWL_IS_DISPLAYED IN VARCHAR2,
                                 P_CRAWL_UI_FPARAM_NAME IN VARCHAR2,
                                 P_CRAWL_INDEXED IN VARCHAR2,
                                 P_CRAWL_STORED IN VARCHAR2,
                                 P_CRAWL_IS_SECURE IN VARCHAR2,
                                 P_CRAWL_IS_TITLE IN VARCHAR2,
                                 P_CRAWL_WEIGHT IN VARCHAR2);



--
-- Procedure
--   UPLOAD_USES_TABLE
--
-- Purpose
--   Upload Uses Table
--
PROCEDURE UPLOAD_USES_TABLE(  P_UPLOAD_MODE IN VARCHAR2,
			      P_OBJECT_NAME IN VARCHAR2,
                              P_DEST_TABLE IN VARCHAR2,
			      P_TABLE_NAME IN VARCHAR2,
  			      P_UT_SEQ IN VARCHAR2,
			      P_UT_DIRECTION IN VARCHAR2);



--
-- Procedure
--   UPLOAD_USES_MAP
--
-- Purpose
--   Upload Uses Map
--
PROCEDURE UPLOAD_USES_MAP(  P_UPLOAD_MODE IN VARCHAR2,
			    P_OBJECT_NAME IN VARCHAR2,
                            P_DEST_TABLE IN VARCHAR2,
			    P_MAP_NAME IN VARCHAR2,
			    P_UM_SEQ IN VARCHAR2);


--
-- Procedure
--   UPLOAD_CLASS_DATASOURCES
--
-- Purpose
--   Upload Class Datasources
--
PROCEDURE UPLOAD_CLASS_DATASOURCES(P_UPLOAD_MODE IN VARCHAR2,
			    	   P_OBJECT_NAME IN VARCHAR2,
                            	   P_DEST_TABLE IN VARCHAR2,
			    	   P_DATASOURCE_NAME IN VARCHAR2,
			    	   P_DEF_CLASS IN VARCHAR2,
			    	   P_QUERYABLE IN VARCHAR2,
			    	   P_UPDATEABLE IN VARCHAR2,
			    	   P_INSERTABLE IN VARCHAR2,
			    	   P_MERGEABLE IN VARCHAR2,
			    	   P_DELETEABLE IN VARCHAR2,
			    	   P_PROCESS_QNAME IN VARCHAR2,
			    	   P_QUERY_QNAME IN VARCHAR2);


--
-- Procedure
--   UPLOAD_OBJ_KEY_SET
--
-- Purpose
--   Upload Object Key Set
--
PROCEDURE UPLOAD_OBJ_KEY_SET(P_UPLOAD_MODE IN VARCHAR2,
			     P_OBJECT_NAME IN VARCHAR2,
                             P_DEST_TABLE IN VARCHAR2,
			     P_KEY_SET_NAME IN VARCHAR2,
			     P_KEY_SET_SEQUENCE IN VARCHAR2,
			     P_KEY1_MBR_NAME IN VARCHAR2,
			     P_KEY2_MBR_NAME IN VARCHAR2,
			     P_KEY3_MBR_NAME IN VARCHAR2,
			     P_KEY4_MBR_NAME IN VARCHAR2,
			     P_KEY5_MBR_NAME IN VARCHAR2,
			     P_ALT1_MBR_NAME IN VARCHAR2,
			     P_ALT2_MBR_NAME IN VARCHAR2,
			     P_ALT3_MBR_NAME IN VARCHAR2,
			     P_ALT4_MBR_NAME IN VARCHAR2,
			     P_ALT5_MBR_NAME IN VARCHAR2);


--
-- Procedure
--   UPLOAD_IREP_METHOD
--
-- Purpose
--   Upload iRep Method
--
PROCEDURE UPLOAD_IREP_METHOD(   P_UPLOAD_MODE IN VARCHAR2,
			        P_OBJECT_NAME IN VARCHAR2,
                                P_DEST_TABLE IN VARCHAR2,
			        P_FUNCTION_NAME IN VARCHAR2,
				P_METHOD_NAME IN VARCHAR2,
				P_OVERLOAD_SEQ IN VARCHAR2,
				P_SCOPE IN VARCHAR2,
				P_LIFECYCLE IN VARCHAR2,
			        P_DESCRIPTION IN VARCHAR2,
				P_COMPATABILITY IN VARCHAR2,
				P_SYNCHRO IN VARCHAR2,
				P_DIRECTION IN VARCHAR2,
				P_CTX_DEPENDENCE IN VARCHAR2,
				P_USER_FN_NAME IN VARCHAR2,
				P_SHORT_DESCRIPTION IN VARCHAR2,
				P_PRIMARY_FLAG IN VARCHAR2,
				P_INDIRECT_OP_FLAG IN VARCHAR2);


--
-- Procedure
--   UPLOAD_METHOD_CATEGORY
--
-- Purpose
--   Upload Method Category
--
PROCEDURE UPLOAD_METHOD_CATEGORY(  P_UPLOAD_MODE IN VARCHAR2,
                                   P_OBJECT_NAME IN VARCHAR2,
                                   P_DEST_TABLE IN VARCHAR2,
                                   P_FUNCTION_NAME IN VARCHAR2,
				   P_OVERLOAD_SEQ IN VARCHAR2,
				   P_TYPE IN VARCHAR2,
				   P_CODE IN VARCHAR2,
				   P_SEQUENCE IN VARCHAR2);

--
-- Procedure
--   UPLOAD_METHOD_CHILD_ANNOTATION
--
-- Purpose
--   Upload Method Child Annotation
--
PROCEDURE UPLOAD_METHOD_CHILD_ANNOTATION(P_UPLOAD_MODE IN VARCHAR2,
                                   	 P_OBJECT_NAME IN VARCHAR2,
                                   	 P_DEST_TABLE IN VARCHAR2,
                                   	 P_FUNCTION_NAME IN VARCHAR2,
                                   	 P_OVERLOAD_SEQ IN VARCHAR2,
				   	 P_CHILD_FLAG IN VARCHAR2,
				   	 P_VALUE IN VARCHAR2);


--
-- Procedure
--   UPLOAD_PARAMS
--
-- Purpose
--   Upload Parameters
--
PROCEDURE UPLOAD_PARAMS(   P_UPLOAD_MODE IN VARCHAR2,
                           P_OBJECT_NAME IN VARCHAR2,
                           P_DEST_TABLE IN VARCHAR2,
                           P_FUNCTION_NAME IN VARCHAR2,
                           P_OVERLOAD_SEQ IN VARCHAR2,
			   P_SEQUENCE IN VARCHAR2,
			   P_INNERTYPE_SEQUENCE IN VARCHAR2,
			   P_NAME IN VARCHAR2,
			   P_DIRECTION IN VARCHAR2,
			   P_OPTIONAL IN VARCHAR2,
			   P_TYPE IN VARCHAR2,
			   P_PRECISION IN VARCHAR2,
			   P_SIZE IN VARCHAR2,
			   P_SCALE IN VARCHAR2,
			   P_NULL_ALLOWED IN VARCHAR2,
			   P_DESCRIPTION IN VARCHAR2,
			   P_DEFAULT_VALUE IN VARCHAR2,
			   P_DISPLAYED IN VARCHAR2,
			   P_ATTRIBUTE_SET IN VARCHAR2);


--
-- Function
--   COMPARE_VERSIONS
--
-- Purpose
--   Compare the version numbers of two files
--
-- Returns: The string "=" if p_version1 = p_version2
--          The string ">" if p_version1 > p_version2
--          The string "<" if p_version1 < p_version2

FUNCTION COMPARE_VERSIONS(p_version1 IN VARCHAR2,
                          p_version2 IN VARCHAR2)
			  RETURN VARCHAR2;



--
-- Procedure
--   iRepPostProcess
--
-- Purpose
--   Do various post processing to irep data.  Currently just denormalizes
-- inherited methods into child classes.  This is called from the post
-- processing java code which does various other post processing (such as
-- updating schema entries).
--

PROCEDURE iRepPostProcess;

--
-- Procedure
--   ADD_LANGUAGE
--
-- Purpose
--   This is a hack to support the mls procedure provided by mls table handlers.
-- Even though translations are not supported for these tables, for historical
-- reasons we utilize the _TL/_VL design.
--
-- In order to avoid missing data in a newly added language we need to provide
-- an add_language procedure (even though it is not attached to a traditional
-- table handler package).
--

PROCEDURE ADD_LANGUAGE;

-- Procedure
-- GET_DELETE_GRANTS
-- Purpose
--- Used to fetch and store menu entries and grants associated with a function
PROCEDURE GET_DELETE_GRANTS(key_id IN NUMBER);

-- Procedure
-- RESTORE_GRANTS
-- Purpose
--- Used to restore menus and grants for a function
PROCEDURE RESTORE_GRANTS(f_id IN NUMBER,f_name in varchar);

end FND_IREP_LOADER_PRIVATE;

/
