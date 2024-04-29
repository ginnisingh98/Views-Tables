--------------------------------------------------------
--  DDL for Package OCM_GET_EXTRL_DECSN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OCM_GET_EXTRL_DECSN_PUB" AUTHID CURRENT_USER AS
/* $Header: ARCMPEXTS.pls 120.1 2006/06/30 22:06:34 bsarkar noship $ */
/*#
 * This API lets users import scores and credit recommendations.
 * If no recommendations have been imported, then an automation rule will be
 * used to generate the recommendations based on the score.
 * @rep:scope public
 * @rep:doccd 120ocmug.pdf Credit Management API User Notes,Oracle Credit Management User Guide
 * @rep:product OCM
 * @rep:lifecycle active
 * @rep:displayname Get External Score
 * @rep:category BUSINESS_ENTITY OCM_GET_EXTRL_DECSN_PUB
 */

/*#
 * Use this procedure to import a credit score.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Score
 */


 PROCEDURE Get_Score
     (  p_api_version		IN		NUMBER,
	p_init_msg_list		IN		VARCHAR2 DEFAULT FND_API.G_TRUE,
	p_commit		IN		VARCHAR2,
	p_validation_level	IN		VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
        x_msg_data             	OUT NOCOPY	VARCHAR2,
        p_case_folder_id	IN		NUMBER,
        p_score_model_id	IN		NUMBER Default NULL,
        p_score			IN		NUMBER
     );
TYPE data_point_id_varray IS varray(50) of  NUMBER;

/*#
 * Use this procedure to include additional data points that are not part of checklists.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Include Data Points
 */
PROCEDURE Include_Data_Points
     (  p_api_version		IN		NUMBER,
	p_init_msg_list		IN		VARCHAR2 DEFAULT FND_API.G_TRUE,
	p_commit		IN		VARCHAR2,
	p_validation_level	IN		VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data             	OUT NOCOPY	VARCHAR2,
	p_case_folder_id	IN		NUMBER,
	p_data_point_id		IN		data_point_id_varray
     );

TYPE credit_recommendations_rec IS RECORD (
		Credit_Recommendation		VARCHAR2(30),
		Recommendation_value1		VARCHAR2(60),
		Recommendation_value2		VARCHAR2(60)
		);
TYPE credit_recommendation_tbl IS TABLE OF credit_recommendations_rec INDEX BY BINARY_INTEGER;
/*#
 * Use this procedure to import credit recommendations.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Recommendations
 */
PROCEDURE Get_Recommendations
     (  p_api_version		IN		NUMBER,
	p_init_msg_list		IN		VARCHAR2 DEFAULT FND_API.G_TRUE,
	p_commit		IN		VARCHAR2,
	p_validation_level	IN		VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
        x_msg_data             	OUT NOCOPY	VARCHAR2,
        p_case_folder_id	IN		NUMBER,
        p_recommendations_type	IN		VARCHAR2,
        p_recommendations_tbl	IN	        credit_recommendation_tbl
      );

/*#
 * Use this procedure to submit the case folder and start the Credit Management workflow.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Submit Case Folder
 */
PROCEDURE Submit_Case_Folder
     (  p_api_version		IN		NUMBER,
	p_init_msg_list		IN		VARCHAR2 DEFAULT FND_API.G_TRUE,
	p_commit		IN		VARCHAR2,
	p_validation_level	IN		VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
        x_msg_data             	OUT NOCOPY	VARCHAR2,
        p_case_folder_id	IN		NUMBER
     );


END OCM_GET_EXTRL_DECSN_PUB;

 

/
