--------------------------------------------------------
--  DDL for Package OCM_RECOMMENDATIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OCM_RECOMMENDATIONS_PUB" AUTHID CURRENT_USER AS
/*$Header: ARCMRECS.pls 120.2 2006/06/30 22:07:23 bsarkar noship $  */
/*#
 * This API returns a list credit recommendations based on a credit request ID or
 * case folder ID.
 * @rep:scope public
 * @rep:doccd 120ocmug.pdf Credit Request Credit Management  API User Notes, Oracle credit Management User Guide
 * @rep:product OCM
 * @rep:lifecycle active
 * @rep:displayname Get Recommendations
 * @rep:category BUSINESS_ENTITY OCM_RECOMMENDATIONS
 */
/*#
 * Use this procedure to get a list of credit recommendations
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Recommendations
 */

/*
This procedure returs nlist of recommendations attached  to a case folder.
Either a credit_request_id or case_folder_id is required. If both are passed,
then please make sure the combination exists.

*/

TYPE recommendations_rec IS RECORD (
            recommendation_id           NUMBER,
            credit_request_id           NUMBER,
            case_folder_id              NUMBER,
            credit_recommendation       VARCHAR2(30),
            recommendation_value1       VARCHAR2(60),
            recommendation_value2       VARCHAr2(60),
            status                      VARCHAR2(15),
            credit_type                 VARCHAr2(30),
            recommendation_name         VARCHAR2(60),
            appealed_flag               VARCHAR2(1) );

TYPE recommendations_tbl IS TABLE OF recommendations_rec
     INDEX BY BINARY_INTEGER;


TYPE appealing_reco_rec IS RECORD (
        recommendation_id           NUMBER       ,
        credit_recommendation       VARCHAR2(30) default null,
        recommendation_name         VARCHAR2(60) default null );

TYPE appealing_reco_tbl IS TABLE OF appealing_reco_rec
     INDEX BY BINARY_INTEGER;

/************************************************************************
** The API lists all the recommendations based on credit_request_id or
** case_folder_id.
** The API needs either case_folder_id or credit_request_id to return all the
** recommendations. Neither is supplied, the API will raise an errorthe API will raise an error
** Based on the appealed_flag the recommendations will be returned.
** By default the flag is 'N'.
*************************************************************************/
PROCEDURE get_recommendations (
        p_api_version           	IN          NUMBER     DEFAULT 1.0,
        p_init_msg_list         	IN          VARCHAR2   := FND_API.G_FALSE ,
        p_commit                	IN          VARCHAR2   := FND_API.G_FALSE ,
        p_validation_level      	IN          VARCHAR2   DEFAULT NULL,
        p_credit_request_id         IN          NUMBER     DEFAULT NULL,
        p_case_folder_id            IN          NUMBER     DEFAULT NULL,
        p_appealed_flag             IN          VARCHAR2   DEFAULT 'N',
        p_recommendations_tbl       OUT NOCOPY  recommendations_tbl,
        x_return_status         	OUT NOCOPY  VARCHAR2,
        x_msg_count             	OUT NOCOPY  NUMBER,
        x_msg_data              	OUT NOCOPY  VARCHAR2 );

/************************************************************************
** The API will mark individual recommendations as appealed.
** The API requires either case_folder_id,credit_request_id or appealing_reco_tble
** to be populated. If appealing_reco_tbls is null then the API will mark
** all recommendations based on credit_request_id and case_folder_id.
*************************************************************************/
/*#
 * Use this procedure to mark individual recommendations for appealing.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Mark Appeal
 */

PROCEDURE mark_appeal (
        p_api_version           	   IN          NUMBER      DEFAULT 1.0,
        p_init_msg_list         	   IN          VARCHAR2    := FND_API.G_FALSE,
        p_commit                	   IN          VARCHAR2    := FND_API.G_FALSE,
        p_validation_level      	   IN          VARCHAR2    DEFAULT NULL,
        p_credit_request_id            IN          NUMBER      DEFAULT NULL,
        p_case_folder_id               IN          NUMBER      DEFAULT NULL ,
        p_appealing_reco_tbl           IN          appealing_reco_tbl,
        x_return_status         	   OUT NOCOPY  VARCHAR2,
        x_msg_count             	   OUT NOCOPY  NUMBER,
        x_msg_data              	   OUT NOCOPY  VARCHAR2  )  ;

END OCM_RECOMMENDATIONS_PUB;

 

/
