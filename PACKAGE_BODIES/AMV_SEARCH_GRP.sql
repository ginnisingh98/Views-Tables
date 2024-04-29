--------------------------------------------------------
--  DDL for Package Body AMV_SEARCH_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_SEARCH_GRP" AS
/* $Header: amvgserb.pls 120.1 2005/06/21 17:48:49 appldev ship $ */
--
-- NAME
--   AMV_SEARCH_GRP
-- PURPOSE
--
-- HISTORY
--   12/07/1999        SLKRISHN        CREATED
--
--
--
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'AMV_SEARCH_GRP';

G_ITEM              CONSTANT  VARCHAR2(30) := AMV_UTILITY_PVT.G_ITEM;
G_AUTHOR            CONSTANT  VARCHAR2(30) := 'AUTHOR';
G_KEYWORD           CONSTANT  VARCHAR2(30) := 'KEYWORD';
G_TITLE_DESC        CONSTANT  VARCHAR2(30) := 'TITLE_DESC';
--
-- This package contains the following procedures
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : find_repositories
--    Type       : Group or Public
--    Pre-reqs   : Total number of repository names retrieved at a time will
--                 not need to exceed amv_utility_pub.g_max_array_size.  By
--                 not needing to exceed this limit, the parameters to
--                 control a "sliding window" of retrieved values is not
--                 needed, thus simplifying this API's signature.
--    Function   : Retrieves all repository names participating with
--                 MES Search that match the input parameters specified.
--                 Typically, only the status parameter will be set to
--                 retrieve only active Repositories.
--
--                 Marketing Encyclopedia (MES) will employ this procedure
--                 within its Search API and screens to retrieve
--                 repositories participating with MES search.
--
--
--    Parameters (Standard parameters not mentioned):
--    IN         : p_repository_id         IN NUMBER                  Optional
--                    Repository ID of the Repository to retrieve
--                    information for.  Corresponds to the column
--                    amv_d_entities_b.entity_id
--                    where amv_d_entities_b.usage_indicator = 'ASRN'
--
--               : p_repository_code       IN VARCHAR2(255)           Optional
--                    Repository Code of the Repository to retrieve
--                    information for.  Corresponds to the column
--                    amv_d_entities_b.table_name
--                    where amv_d_entities_b.usage_indicator = 'ASRN'
--
--               : p_repository_name       IN VARCHAR2(80)            Optional
--                    Description of the Repository that should appear
--                    on the Advanced Repository Area Search page.
--                    Corresponds to the column
--                    amv_d_entities_tl.entity_name.
--
--               : p_status                           IN  VARCHAR2    Optional
--                    Status condition to be queried.
--                    (A= active, I=inactive).
--
--               : p_object_version_number            IN  NUMBER      Optional
--                    Used as a means of detecting updates to a row.
--
--    OUT NOCOPY  NOCOPY         : x_searchrep_array        OUT NOCOPY  NOCOPY  ARRAY_TYPE
--                    Varying Array of Object amv_searchrep_obj_type that
--                    holds the resulting search matches.
--
--                       repository_id               OUT NOCOPY  NUMBER
--                          Repository ID that met the search criteria
--                          provided.
--
--                       repository_code             OUT NOCOPY  VARCHAR2(255)
--                          Repository code that met the search criteria
--                          provided.
--
--                       repository_name             OUT NOCOPY  VARCHAR2(80)
--                          Name of the Repository that met the
--                          search criteria provided.  Value will be
--                          what is displayed on the Advanced Repository Area
--                          Search page.
--
--                       status                      OUT NOCOPY  VARCHAR2(30)
--                          Status of the record.
--
--                       object_version_number       OUT NOCOPY  NUMBER
--                          Version number stamp of the record.
--
--    Version    : Current version     1.0
--                    {add comments here}
--                 Previous version    1.0
--                 Initial version     1.0
-- End of comments
--
PROCEDURE find_repositories
   (p_api_version             IN   NUMBER,
    p_init_msg_list           IN   VARCHAR2 := fnd_api.g_false,
    p_validation_level        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status           OUT NOCOPY   VARCHAR2,
    x_msg_count               OUT NOCOPY   NUMBER,
    x_msg_data                OUT NOCOPY   VARCHAR2,
    p_check_login_user        IN   VARCHAR2 := FND_API.G_TRUE,
    p_object_version_number   IN   NUMBER   := FND_API.G_MISS_NUM,
    p_repository_id           IN   NUMBER   := FND_API.G_MISS_NUM,
    p_repository_code         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_repository_name         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_status                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    x_searchrep_array         OUT NOCOPY   AMV_SEARCH_PVT.amv_searchrep_varray_type)

IS
l_api_name	varchar2(30) := 'find_repositories';
BEGIN

	amv_search_pvt.find_repositories
   		(p_api_version => p_api_version,
    		p_init_msg_list => p_init_msg_list,
    		p_validation_level => p_validation_level,
    		x_return_status => x_return_status,
    		x_msg_count => x_msg_count,
    		x_msg_data => x_msg_data,
    		p_check_login_user => p_check_login_user,
    		p_object_version_number => p_object_version_number,
    		p_repository_id => p_repository_id,
    		p_repository_code => p_repository_code,
    		p_repository_name => p_repository_name,
    		p_status => p_status,
    		x_searchrep_array => x_searchrep_array);

EXCEPTION
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
		END IF;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
				p_encoded => FND_API.G_FALSE,
				p_count => x_msg_count,
				p_data  => x_msg_data
				);
END find_repositories;
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : find_repository_areas
--    Type       : Group or Public
--    Pre-reqs   : Total number of repository areas retrieved at a time will
--                 not need to exceed amv_utility_pub.g_max_array_size.  By
--                 not needing to exceed this limit, the parameters to
--                 control a "sliding window" of retrieved values is not
--                 needed, thus simplifying this API's signature.
--    Function   : Retrieves all repository areas for a given repository
--                 that is participating with MES Search which matches the
--                 input parameters specified.
--                 Typically, the repository code will be provided to
--                 restrict the return to include only areas for that
--                 repository; The status parameter will usually be set to
--                 retrieve only active Repository Areas.
--
--                 Marketing Encyclopedia (MES) will employ this procedure
--                 within its Search API and screens to retrieve Repository
--                 Areas valid for an MES search with the specified Repository.
--
--    Parameters (Standard parameters not mentioned):
--    IN         : p_repository_id         IN NUMBER                  Optional
--                    Repository identifier of the Repository Code to
--                    retrieve information for.  Corresponds to the column
--                    amv_d_entities_b.entity_id
--                    where amv_d_entities_b.usage_indicator = 'ASRN'
--
--               : p_repository_code       IN VARCHAR2(255)           Optional
--                    Repository Code of the Repository to retrieve
--                    information for.  Corresponds to the column
--                    amv_d_entities_b.table_name
--                    where amv_d_entities_b.usage_indicator = 'ASRN'
--
--               : p_area_id               IN NUMBER                  Optional
--                    Repository Area identifier of the Repository Area to
--                    retrieve information for.  Corresponds to the column
--                    amv_d_ent_attributes_b.attribute_id
--                    where amv_d_ent_attributes_b.usage_indicator = 'ASRA'
--
--               : p_area_code             IN VARCHAR2(255)           Optional
--                    Area Repository Code of the Repository to retrieve
--                    information for.  Corresponds to the column
--                    amv_d_ent_attributes_b.column_name
--                    where amv_d_ent_attributes_b.usage_indicator = 'ASRA'
--
--               : p_area_name              IN VARCHAR2(80)            Optional
--                    Description of the Repository that should appear
--                    on the Advanced Repository Area Search page.
--                    Corresponds to the column
--                    amv_d_ent_attributes_tl.attribute_name.
--
--               : p_status                           IN  VARCHAR2    Optional
--                    Status condition to be queried.
--                    (A= active, I=inactive).
--
--               : p_object_version_number            IN  NUMBER      Optional
--                    Used as a means of detecting updates to a row.
--
--    OUT NOCOPY         : x_searcharea_array        OUT NOCOPY  ARRAY_TYPE
--                    Varying Array of Object amv_searchrep_obj_type that
--                    holds the resulting search matches.
--
--                       repository_id               OUT NOCOPY  NUMBER
--                          Repository ID that met the search criteria
--                          provided.
--
--                       repository_code             OUT NOCOPY  VARCHAR2(255)
--                          Repository code that met the search criteria
--                          provided.
--
--                       area_id                     OUT NOCOPY  NUMBER
--                          Area ID that met the search criteria
--                          provided.
--
--                       area_code                   OUT NOCOPY  VARCHAR2(80)
--                          Area code that met the search criteria
--                          provided.
--
--                       area_name                   OUT NOCOPY  VARCHAR2(80)
--                          Name of the Repository Area that met the
--                          search criteria provided.  Value will be
--                          what is displayed on the Advanced Repository Area
--                          Search page.
--
--                       status                      OUT NOCOPY  VARCHAR2(30)
--                          Status of the record.
--
--                       object_version_number       OUT NOCOPY  NUMBER
--                          Version number stamp of the record.
--
--    Version    : Current version     1.0
--                    {add comments here}
--                 Previous version    1.0
--                 Initial version     1.0
-- End of comments
--
PROCEDURE find_repository_areas
   (p_api_version             IN   NUMBER,
    p_init_msg_list           IN   VARCHAR2 := fnd_api.g_false,
    p_validation_level        IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status           OUT NOCOPY   VARCHAR2,
    x_msg_count               OUT NOCOPY   NUMBER,
    x_msg_data                OUT NOCOPY   VARCHAR2,
    p_check_login_user        IN   VARCHAR2 := FND_API.G_TRUE,
    p_searcharea_obj          IN   AMV_SEARCH_PVT.amv_searchara_obj_type,
    x_searcharea_array        OUT NOCOPY   AMV_SEARCH_PVT.amv_searchara_varray_type)

IS
l_api_name	varchar2(30) := 'find_repository_areas';
BEGIN

	amv_search_pvt.find_repository_areas
   		(p_api_version => p_api_version,
    		p_init_msg_list => p_init_msg_list,
    		p_validation_level => p_validation_level,
    		x_return_status => x_return_status,
    		x_msg_count => x_msg_count,
    		x_msg_data => x_msg_data,
    		p_check_login_user => p_check_login_user,
    		p_searcharea_obj => p_searcharea_obj,
    		x_searcharea_array => x_searcharea_array);

EXCEPTION
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
		END IF;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
				p_encoded => FND_API.G_FALSE,
				p_count => x_msg_count,
				p_data  => x_msg_data
				);
END find_repository_areas;
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Content_Search
--    Type       : Group or Public
--    Pre-reqs   : None
--    Function   : Accept a search string of a standardized syntax for the
--                 searching of one or more repositories for which
--                 this repository API supports.  The API name will be
--                 registered within the tables amv_d_entities_%,
--                 amv_d_ent_attributes_tl, and amv_d_ent_attributes_b
--                 with the later tables column, FUNCTION_CALL set to
--                 {user-defined name of [package.]procedure} (i.e. the
--                 name of this API).
--                 As the value stored within the column FUNCTION_CALL will be
--                 concatenated along with a pre-determined procedure
--                 specification for participation in a dynamic PL/SQL call,
--                 it is imperative that this value conforms to a valid
--                 Oracle PL/SQL [package.]procedure name.
--
--                 Marketing Encyclopedia (MES) will employ this procedure
--                 within its Search API and screens to retrieve and filter
--                 another repository's data that meets the specified
--                 search criteria passed in.
--
--    Parameters (Standard parameters not mentioned):
--    IN         : p_imt_search_string    IN VARCHAR2(400)           Required
--                    Search string defining what to search in interMedia
--                    Text syntax.  The intent is for this API to accept
--                    the string as-is, and drop the string into a
--                    Dynamic SQL statement containing the iMT CONTAINS()
--                    clause for immediate execution.
--
--                    Note, this string will NOT include the iMT keyword
--                    CONTAINS along with it's parentheses, just a valid
--                    string that can be dropped as-is into the CONTAINS
--                    clause.
--
--               : p_search_param_array  IN amv_searchpar_array_type Required
--                    Array of object amv_searchpar_obj_type listing values
--                    to search against database columns that are not
--                    interMedia Text enabled.
--
--                    The attributes of the object follow:
--
--                       : operator       IN VARCHAR2(30)            Required
--
--                            Oracle operators consisting values in
--              	{=,!=,IN,NOT IN,LIKE,NOT LIKE}.
--
--                       : string_value   IN VARCHAR2(400)           Required
--
--                            Value portion of the search in string form.
--
--                    The format of the two columns of this object type
--                    is such that the API will be able to concatenate
--                    these values with appropriate white space and the
--                    search source column name; This would form a
--                    syntactically valid SQL predicate for construction
--                    of a Dynamic SQL Statement.
--
--                    Example:
--
--                      col_name||two single quotes||operator||two single quotes||string_value
--
--                    The string_value will conform to the proper SQL
--                    syntax for its corresponding operator. (e.g. the
--                    string_value will be enclosed in parentheses for
--                    the IN operator).  As there could be multiple
--                    string_values, this API must be able to build a
--                    Dynamic SQL statement using all cells of this array.
--
--               : p_area_array           IN amv_area_array_type Optional
--                    Array structure that lists a subset of all areas
--                    of the repository for which this API is based.  If the
--                    array is NULL (by default), then all areas are to be
--                    searched.  Areas listed within this array must, for
--                    validation purposes, be registered under the MES tables
--                    amv_d_entities_%, amv_d_ent_attributes_% and
--                    amv_d_ attrib_operators.  Valid areas will be
--                    identified in the column
--                    amv_d_ent_attributes_b.column_name.
--
--                    The main AMV Search API will only recognize areas
--                    defined within this table.  The API will also refer to
--                    the status column of this table to ignore areas
--                    where this column's value is set to "disabled".
--
--               : p_user_id              IN NUMBER                  Required
--                    Identifier from FND that declares the end-user.  This
--                    API may required the ID to filter privileged items.
--
--               : p_request_array        IN  amv_request_array_type Required
--                    Object structure that specifies and controls a sliding
--                    window to the retrieved LOV results set (i.e. restricts
--                    the subset of rows returned, and controls its starting
--                    and ending record position of the complete set of rows
--                    that could potentially be retrieved).  See package
--                    amv_utility_pub for further specifications to the
--                    object's structure.  The attributes of the object and
--                    their description follow:
--
--                       records_requested            IN NUMBER
--                         Specifies the maximum number of records to return
--                         in the varray results subset  (Defaults to
--                         (amv_utility_pub.g_amv_max_varray_size).
--
--                       start_record_position        IN NUMBER
--                         Specifies a subscript into the varray results
--                         set for the first record to be returned in the
--                         retrieval subset.  Usually used in conjunction
--                         with p_request_obj.next_record_position
--                         (Default 1 ).
--
--                       return_total_count_flag      IN VARCHAR2
--                         Flag consisting of the values {fnd_api.g_true,
--                         fnd_api.g_false} to specify whether
--                         p_request_obj.total_record_count is
--                         derived, albeit at a possible cost to resources
--                         (Default fnd_api.g_false).
--
--    OUT NOCOPY         : x_return_obj            OUT NOCOPY  OBJ_TYPE
--                    Object structure that reports information abOUT NOCOPY  the
--                    retrieved results set defined by p_request_obj.
--                    See package amv_utility_pub for further
--                    specifications to the object's structure.
--                    Object structure of:
--
--                       returned_record_count        OUT NOCOPY  NUMBER
--                          Indicates the total number of records returned
--                          for the retrieved subset.  This value will not
--                          exceed p_request_obj.records_requested.
--
--                       next_record_position         OUT NOCOPY  NUMBER
--                          Indicates the subscript to the varray that is the
--                          starting point to the next subset of records in
--                          the set (base 1; that is, the first record of the
--                          set is one, NOT zero).  Will return 0 if there are
--                          no more rows.
--
--                       total_record_count           OUT NOCOPY  NUMBER
--                          Indicates the total record count in the complete
--                          varray retrieval set only if
--                          p_request_obj.return_total_count is set
--                          to fnd_api.g_true; Otherwise undefined.
--
--               : x_searchres_array       OUT NOCOPY  ARRAY_TYPE
--                    Varying Array of Object amv_searchres_obj_type that
--                    holds the resulting search matches.
--
--                       title                       IN VARCHAR2(80)
--                          Title of the item that met the search criteria
--                          provided.
--
--                       url_string                  IN VARCHAR2(2000)
--                          URL of the item that met the search.  If this item
--                          is a file, then it will conform to MIME types.
--                          If the item has it's body of a table column, then
--                          the URL will point to an appropriate viewer with
--                          the table column provided as a parameter into the
--                          viewer call.
--
--                       description                 IN VARCHAR2(200)
--                          Abbreviated description of the item that met the
--                          search criteria provided.
--
--                       score                       IN NUMBER
--                          Weighted score of the item that met the search.
--                          The determination of the score is derived by
--                          interMedia Text ranged 0 to 100 with 100 being
--                          the best score.  Exact matches against table
--                          columns which are not interMedia Text enabled will
--                          automatically score 100.
--
--                       area_id                     IN VARCHAR2(30)
--                          The area identifier of the area code.
--                          Corresponds to the column
--                          amv_d_ent_attributes_b.column_name where
--                          amv_d_ent_attributes_b.usage_indicator = 'ASRA'
--
--                       area_code                   IN VARCHAR2(30)
--                          The area code of the repository for which this API
--                          supports.  Valid values will be found within the
--                          column amv_d_ent_attributes_b.column_name where
--                          amv_d_ent_attributes_b.usage_indicator = 'ASRA'
--
--                       user1 - user3               IN VARCHAR2(255)
--                          Unused columns that exist for customized needs.
--
--
--    Version    : Current version     1.0
--                    {add comments here}
--                 Previous version    1.0
--                 Initial version     1.0
-- End of comments
--
PROCEDURE Content_Search
   (p_api_version        IN   NUMBER,
    p_init_msg_list      IN   VARCHAR2 := fnd_api.g_false,
    p_validation_level   IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY   VARCHAR2,
    x_msg_count          OUT NOCOPY   NUMBER,
    x_msg_data           OUT NOCOPY   VARCHAR2,
    p_check_login_user   IN   VARCHAR2 := FND_API.G_TRUE,
    p_application_id	IN   NUMBER,
    p_area_array         IN   AMV_SEARCH_PVT.amv_char_varray_type,
    p_content_array      IN   AMV_SEARCH_PVT.amv_char_varray_type,
    p_param_array        IN   AMV_SEARCH_PVT.amv_searchpar_varray_type,
    p_imt_string		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
    p_days	 	  	IN   NUMBER := FND_API.G_MISS_NUM,
    p_user_id            IN   NUMBER := FND_API.G_MISS_NUM,
    p_category_id		IN   AMV_SEARCH_PVT.amv_number_varray_type,
    p_include_subcats	IN	VARCHAR2 := FND_API.G_FALSE,
    p_external_contents	IN	VARCHAR2 := FND_API.G_FALSE,
    p_request_obj  		IN   AMV_SEARCH_PVT.amv_request_obj_type,
    x_return_obj         OUT NOCOPY   AMV_SEARCH_PVT.amv_return_obj_type,
    x_searchres_array    OUT NOCOPY   AMV_SEARCH_PVT.amv_searchres_varray_type)

IS
l_api_name	varchar2(30) := 'content_search';
BEGIN
	amv_search_pvt.Content_Search
   		(p_api_version => p_api_version,
    		p_init_msg_list => p_init_msg_list,
    		p_validation_level => p_validation_level,
    		x_return_status => x_return_status,
    		x_msg_count => x_msg_count,
    		x_msg_data => x_msg_data,
    		p_check_login_user => p_check_login_user,
    		p_application_id => p_application_id,
    		p_area_array => p_area_array,
    		p_content_array => p_content_array,
    		p_param_array => p_param_array,
    		p_imt_string => p_imt_string,
    		p_days => p_days,
    		p_user_id => p_user_id,
    		p_category_id => p_category_id,
    		p_include_subcats => p_include_subcats,
    		p_external_contents => p_external_contents,
    		p_request_obj => p_request_obj,
   		x_return_obj => x_return_obj,
    		x_searchres_array => x_searchres_array);

EXCEPTION
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
		END IF;
		-- Standard call to get message count and if count=1, get the message
		FND_MSG_PUB.Count_And_Get (
				p_encoded => FND_API.G_FALSE,
				p_count => x_msg_count,
				p_data  => x_msg_data
				);
END content_search;
--------------------------------------------------------------------------------
END amv_search_grp;

/
