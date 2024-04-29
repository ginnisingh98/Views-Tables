--------------------------------------------------------
--  DDL for Package OCM_DATA_POINTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OCM_DATA_POINTS_PUB" AUTHID CURRENT_USER AS
/*$Header: ARCMLDPS.pls 120.2.12010000.2 2009/05/14 13:35:23 mraymond ship $  */
/*#
* This API returns the list of data points for a given credit classification,
* review type, data point category or data point subcategory.
* @rep:scope public
* @rep:doccd 120ocmug.pdf Credit Management API User Notes, Oracle Credit Management User Guide
* @rep:product OCM
* @rep:lifecycle active
* @rep:displayname Get Data Points
* @rep:category BUSINESS_ENTITY OCM_GET_DATA_POINTS
*/


TYPE data_points_rec IS RECORD (
        DATA_POINT_ID                   NUMBER(15)     DEFAULT NULL,
        DATA_POINT_CODE                 VARCHAR2(60)   DEFAULT NULL,
        DATA_POINT_NAME                 VARCHAR2(60)   DEFAULT NULL,
        DATA_POINT_CATEGORY             VARCHAR2(30)   DEFAULT NULL,
        DESCRIPTION                     VARCHAR2(120)  DEFAULT NULL,
        SCORABLE_FLAG                   VARCHAR2(1)    DEFAULT NULL,
        APPLICATION_ID                  NUMBER(15)     DEFAULT NULL,
        PACKAGE_NAME                    VARCHAR2(60)   DEFAULT NULL,
        FUNCTION_NAME                   VARCHAR2(60)   DEFAULT NULL,
        PARENT_DATA_POINT_ID            NUMBER(15)     DEFAULT NULL,
        DATA_POINT_SUB_CATEGORY         VARCHAR2(30)   DEFAULT NULL,
        FUNCTION_TYPE                   VARCHAR2(10)   DEFAULT NULL,
        RETURN_DATA_TYPE                VARCHAR2(30)   DEFAULT NULL,
        RETURN_DATE_FORMAT              VARCHAR2(60)   DEFAULT NULL
        );

TYPE data_points_tbl IS TABLE OF data_points_rec
        INDEX BY BINARY_INTEGER;

/***********************************************************************
** The procedure will return a list of all data points that belong to
** a checklist. Credit_classification and review_type are mandatory parameters.
** If a checklist does not exist, the procedure will raise an error.
** If data_point_category
** (like CREDIT, REFERENCE, etc) or data_point_sub_category(user-defined based
** on lookup types OCM_USER_DATA_POINT_CATEGORIES) has been passed, then
** data points will be filtered based on these values.
************************************************************************/
/*#
 * Use this procedure to return a list of all data points that belong
 * to a given checklist.  The list can be further filtered by
 * category and subcategory.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Checklist Data Points
 */
PROCEDURE GET_DATA_POINTS (
        p_api_version           	IN          NUMBER  DEFAULT 1.0,
        p_init_msg_list         	IN          VARCHAR2 DEFAULT FND_API.G_TRUE,
        p_commit                	IN          VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_validation_level      	IN          VARCHAR2,
        p_credit_classification 	IN          VARCHAR2,
        p_review_type           	IN          VARCHAR2,
        p_data_point_category   	IN          VARCHAR2 DEFAULT NULL,
        p_data_point_sub_category	IN			VARCHAR2 DEFAULT NULL,
        x_return_status         	OUT NOCOPY  VARCHAR2,
        x_msg_count             	OUT NOCOPY  NUMBER,
        x_msg_data              	OUT NOCOPY  VARCHAR2,
        p_datapoints_tbl        	OUT NOCOPY  data_points_tbl );


END OCM_DATA_POINTS_PUB;

/
