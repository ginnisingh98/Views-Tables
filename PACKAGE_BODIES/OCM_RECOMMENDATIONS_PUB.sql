--------------------------------------------------------
--  DDL for Package Body OCM_RECOMMENDATIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OCM_RECOMMENDATIONS_PUB" AS
/*$Header: ARCMRECB.pls 120.1 2006/03/23 01:02:46 bsarkar noship $  */

pg_debug VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

PROCEDURE debug (
        p_message_name          IN      VARCHAR2 ) IS
BEGIN
    ar_cmgt_util.debug (p_message_name, 'ar.cmgt.plsql.ARCM_RECOMMENDATIONS_PUB' );
END;

PROCEDURE get_recommendations (
        p_api_version           	IN          NUMBER,
        p_init_msg_list         	IN          VARCHAR2,
        p_commit                	IN          VARCHAR2,
        p_validation_level      	IN          VARCHAR2,
        p_credit_request_id         IN          NUMBER,
        p_case_folder_id            IN          NUMBER,
        p_appealed_flag             IN          VARCHAR2,
        p_recommendations_tbl       OUT NOCOPY  recommendations_tbl,
        x_return_status         	OUT NOCOPY  VARCHAR2,
        x_msg_count             	OUT NOCOPY  NUMBER,
        x_msg_data              	OUT NOCOPY  VARCHAR2 ) IS

        i                           NUMBER := 1;
        l_reco_ctr                  NUMBER := 0;

        CURSOR cRecommendations IS
            SELECT recommendation_id,
                   case_folder_id,
                   credit_request_id,
                   credit_recommendation,
                   recommendation_value1,
                   recommendation_value2,
                   status,
                   credit_type,
                   recommendation_name,
                   appealed_flag
            FROM   ar_cmgt_cf_recommends
            WHERE  credit_request_id = nvl(p_credit_request_id, credit_request_id)
            AND    nvl(appealed_flag, 'N') = p_appealed_flag
            AND    case_folder_id = nvl(p_case_folder_id, case_folder_id );

BEGIN
        IF pg_debug = 'Y'
        THEN
            debug ( 'ARCM_RECOMMENDATIONS_PUB.get_recommendations(+)');
            debug ( 'Credit Request Id : ' || p_credit_request_id );
            debug ( 'Case Folder Id : ' || p_case_folder_id );
            debug ( 'Appeal Flag : ' || p_appealed_flag );
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        IF p_credit_request_id IS NULL AND p_case_folder_id IS NULL
        THEN
            IF pg_debug = 'Y'
            THEN
                debug ( 'Both Credit Request and case folder Id is null');
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_msg_data := 'Both Credit Request Id and case Folder Id cannot be null';
            x_msg_count := 1;
            return;
        END IF;
        For RecommendationsRec IN cRecommendations
        LOOP
            p_recommendations_tbl(i).recommendation_id := RecommendationsRec.recommendation_id;
            p_recommendations_tbl(i).credit_request_id := RecommendationsRec.credit_request_id;
            p_recommendations_tbl(i).case_folder_id := RecommendationsRec.case_folder_id;
            p_recommendations_tbl(i).credit_recommendation := RecommendationsRec.credit_recommendation;
            p_recommendations_tbl(i).recommendation_value1 := RecommendationsRec.recommendation_value1;
            p_recommendations_tbl(i).recommendation_value2 := RecommendationsRec.recommendation_value2;
            p_recommendations_tbl(i).status := RecommendationsRec.status;
            p_recommendations_tbl(i).credit_type := RecommendationsRec.credit_type;
            p_recommendations_tbl(i).recommendation_name := RecommendationsRec.recommendation_name;
            p_recommendations_tbl(i).appealed_flag := RecommendationsRec.appealed_flag;

            i := i +1 ;
        END LOOP;

        l_reco_ctr := p_recommendations_tbl.first;
        IF l_reco_ctr IS NULL
        THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_msg_data := 'No recommendations Exists';
            x_msg_count := 1;
            return;
        END IF;
        IF pg_debug = 'Y'
        THEN
            debug ( 'ARCM_RECOMMENDATIONS_PUB.get_recommendations(-)');
        END IF;
END;

PROCEDURE mark_appeal (
        p_api_version           	   IN          NUMBER,
        p_init_msg_list         	   IN          VARCHAR2,
        p_commit                	   IN          VARCHAR2,
        p_validation_level      	   IN          VARCHAR2,
        p_credit_request_id            IN          NUMBER,
        p_case_folder_id               IN          NUMBER,
        p_appealing_reco_tbl           IN          appealing_reco_tbl,
        x_return_status         	   OUT NOCOPY  VARCHAR2,
        x_msg_count             	   OUT NOCOPY  NUMBER,
        x_msg_data              	   OUT NOCOPY  VARCHAR2  ) IS

        l_check_rec_exists                  NUMBER;
        l_credit_request_id                 ar_cmgt_credit_requests.credit_request_id%type;
        l_case_folder_id                    ar_cmgt_case_folders.case_folder_id%type;

BEGIN
        IF pg_debug = 'Y'
        THEN
            debug ( 'ARCM_RECOMMENDATIONS_PUB.mark_appeal(+)');
            debug ( 'Credit Request Id : ' || p_credit_request_id );
            debug ( 'Case Folder Id : ' || p_case_folder_id );
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF p_credit_request_id IS NULL and p_case_folder_id IS NULL
        THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_msg_data := 'Both Credit Request Id and case Folder Id cannot be null';
            x_msg_count := 1;
            return;
        END IF;

        -- check the status of the case folder. It must be closed for appealing.
        BEGIN
            SELECT  credit_request_id, case_folder_id
            INTO    l_credit_request_id, l_case_folder_id
            FROM    ar_cmgt_case_folders
            WHERE   case_folder_id = nvl(p_case_folder_id, case_folder_id )
            AND     credit_request_id = nvl(p_credit_request_id, credit_request_id)
            AND     type = 'CASE'
            AND     status = 'CLOSED';

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    x_msg_data := 'Either Case Folder Does not Exists or Not Closed.';
                    x_msg_count := 1;
                    return;
                WHEN OTHERS THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    x_msg_data := 'Error while fetching case folder '||sqlerrm;
                    x_msg_count := 1;
                    return;

        END;
        l_check_rec_exists :=  p_appealing_reco_tbl.first;
        --fist updates all records to null
        BEGIN
            UPDATE ar_cmgt_cf_recommends
            SET    appealed_flag = NULL
            WHERE  case_folder_id = l_case_folder_id;

            EXCEPTION
                WHEN OTHERS THEN
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    x_msg_data := 'Error while updating Recommendation' ||sqlerrm;
                    x_msg_count := 1;
                    return;
        END;

        IF l_check_rec_exists >= 1
        THEN
            IF pg_debug = 'Y'
            THEN
                debug ( 'Record Exists ');
            END IF;

            FOR i in p_appealing_reco_tbl.first .. p_appealing_reco_tbl.last
            LOOP
                IF pg_debug = 'Y'
                THEN
                    debug ( 'Recommendation Id  ' || p_appealing_reco_tbl(i).recommendation_id);
                END IF;
                IF p_appealing_reco_tbl(i).recommendation_id IS NOT NULL
                THEN
                    UPDATE ar_cmgt_cf_recommends
                    SET appealed_flag = 'Y'
                    WHERE recommendation_id = p_appealing_reco_tbl(i).recommendation_id;
                END IF;
            END LOOP;
        ELSE -- table is not pupoltaed. Update all of the recommendations
            -- first updates all of
            UPDATE ar_cmgt_cf_recommends
               SET appealed_flag = 'Y'
            WHERE case_folder_id = l_case_folder_id;

        END IF;
END;

END OCM_RECOMMENDATIONS_PUB;

/
