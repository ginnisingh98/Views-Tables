--------------------------------------------------------
--  DDL for Package Body OCM_DATA_POINTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OCM_DATA_POINTS_PUB" AS
/*$Header: ARCMLDPB.pls 120.2.12010000.2 2010/03/05 11:53:47 vsanka ship $  */
/*#
* This API is used for entering User Defined Data Points at the time of
* Credit Request Submission
* @rep:scope public
* @rep:doccd 115ocmug.pdf Credit Management API User Notes, Oracle Credit Management User Guide
* @rep:product OCM
* @rep:lifecycle active
* @rep:displayname Get Data Points
* @rep:category BUSINESS_ENTITY OCM_GET_DATA_POINTS
*/

/*#
* Use this procedure to retreive data points based on a checklist.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Get Data Points
*/
pg_debug VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

PROCEDURE debug (
        p_message_name          IN      VARCHAR2 ) IS
BEGIN
    ar_cmgt_util.debug (p_message_name, 'ar.cmgt.plsql.OCM_DATA_POINTS_PUB' );
END;

PROCEDURE GET_DATA_POINTS (
        p_api_version           	IN          NUMBER,
        p_init_msg_list         	IN          VARCHAR2,
        p_commit                	IN          VARCHAR2,
        p_validation_level      	IN          VARCHAR2,
        p_credit_classification 	IN          VARCHAR2,
        p_review_type           	IN          VARCHAR2,
        p_data_point_category   	IN          VARCHAR2,
        p_data_point_sub_category	IN			VARCHAR2,
        x_return_status         	OUT NOCOPY  VARCHAR2,
        x_msg_count             	OUT NOCOPY  NUMBER,
        x_msg_data              	OUT NOCOPY  VARCHAR2,
        p_datapoints_tbl        	OUT NOCOPY  data_points_tbl ) IS

        l_status                    VARCHAR2(2000);
        l_check_flag                VARCHAr2(60);
        l_check_list_id             NUMBER(15);
        i 							NUMBER :=1;

        CURSOR getDataPointsC IS
        	SELECT  dp.DATA_POINT_ID,
        			dp.DATA_POINT_CODE,
        			dp.DATA_POINT_NAME                 ,
        			dp.DATA_POINT_CATEGORY             ,
        			dp.DESCRIPTION                     ,
        			dp.SCORABLE_FLAG                   ,
        			dp.APPLICATION_ID                  ,
        			dp.PACKAGE_NAME                    ,
        			dp.FUNCTION_NAME                   ,
        			dp.PARENT_DATA_POINT_ID            ,
        			dp.DATA_POINT_SUB_CATEGORY         ,
        			dp.FUNCTION_TYPE                   ,
        			dp.RETURN_DATA_TYPE                ,
        			dp.RETURN_DATE_FORMAT
					FROM ar_cmgt_data_points_vl dp,
						 ar_cmgt_check_lists chklist,
						 ar_cmgt_check_list_dtls chkdtls
					WHERE  chklist.credit_classification = p_credit_classification
					AND    chklist.review_type           = p_review_type
    					AND    sysdate between start_date and nvl(end_date, sysdate)
					AND    chklist.check_list_id = chkdtls.check_list_id
					AND    chkdtls.data_point_id = dp.data_point_id
					AND    dp.data_point_category = nvl(p_data_point_category, data_point_category)
					AND    dp.data_point_sub_category = nvl(p_data_point_sub_category, data_point_sub_category);

BEGIN
              IF pg_debug = 'Y'
              THEN
                        debug ( 'GET_DATA_POINTS(+)');
                        debug ( 'Credit Classification =' || p_credit_classification);
                        debug ( 'Review Type =' || p_review_type);
                        debug ( 'Data Point Category =' ||p_data_point_category);
                        debug ( 'Data Point Sub Category =' ||p_data_point_sub_category);
              END IF;
               x_return_status         := FND_API.G_RET_STS_SUCCESS;

                IF FND_API.to_Boolean( p_init_msg_list )
        		THEN
              		FND_MSG_PUB.initialize;
        		END IF;
				IF p_data_point_sub_category IS NOT NULL
					AND p_data_point_category IS NULL
				THEN
					IF pg_debug = 'Y'
              		THEN
                        debug ( 'Data Point category IS NULL and data Point Sub Category IS not null');
                    END IF;
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    x_msg_data := 'Data Point category IS NULL and data Point Sub Category IS not null';
                    return;
				END IF;


                IF p_data_point_sub_category IS NOT NULL
                THEN
                    BEGIN
                       SELECT 'x' INTO l_check_flag
                       FROM   ar_lookups
                       WHERE lookup_type = 'OCM_USER_DATA_POINT_CATEGORIES'
                       AND   lookup_code = p_data_point_sub_category
					   AND   enabled_flag = 'Y'
					   AND   trunc(sysdate) between trunc(start_date_active)
					   		and nvl(trunc(end_date_active), trunc(sysdate));

                       EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                x_msg_data := 'Invalid Data Point Sub Category';
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                return;
                            WHEN OTHERS THEN
                                x_msg_data := Sqlerrm;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                return;
                    END;
                END IF;
                IF pg_debug = 'Y'
              	THEN
                        debug ( 'Valid data point sub category');
              	END IF;
                IF p_data_point_category IS NOT NULL
                THEN
                    BEGIN
                       SELECT 'x' INTO l_check_flag
                       FROM   ar_lookups
                       WHERE lookup_type = 'AR_CMGT_DATA_POINT_CATEGORY'
                       AND   lookup_code = p_data_point_category
					   AND   enabled_flag = 'Y'
					   AND   trunc(sysdate) between trunc(start_date_active)
					   		and nvl(trunc(end_date_active), trunc(sysdate));

                       EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                x_msg_data := 'Invalid Data Point Category';
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                return;
                            WHEN OTHERS THEN
                                x_msg_data := Sqlerrm;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                return;
                    END;
                END IF;

                IF pg_debug = 'Y'
              	THEN
                        debug ( 'Valid data point category');
              	END IF;
				FOR getDataPointsRec IN getDataPointsC
				LOOP
					IF pg_debug = 'Y'
              		THEN
                        debug ( 'data_point_id ' || getDataPointsRec.data_point_id);
              		END IF;
					p_datapoints_tbl(i).data_point_id := getDataPointsRec.data_point_id;
					p_datapoints_tbl(i).data_point_name := getDataPointsRec.data_point_name;
					p_datapoints_tbl(i).data_point_code := getDataPointsRec.data_point_code;
					p_datapoints_tbl(i).data_point_category := getDataPointsRec.data_point_category;
					p_datapoints_tbl(i).data_point_sub_category := getDataPointsRec.data_point_sub_category;
					p_datapoints_tbl(i).description := getDataPointsRec.description;
					p_datapoints_tbl(i).scorable_flag := getDataPointsRec.scorable_flag;
					p_datapoints_tbl(i).application_id := getDataPointsRec.application_id;
					p_datapoints_tbl(i).package_name := getDataPointsRec.package_name;
					p_datapoints_tbl(i).function_name := getDataPointsRec.function_name;
					p_datapoints_tbl(i).parent_data_point_id := getDataPointsRec.parent_data_point_id;
					p_datapoints_tbl(i).function_type := getDataPointsRec.function_type;
					p_datapoints_tbl(i).return_data_type := getDataPointsRec.return_data_type;
					p_datapoints_tbl(i).return_date_format := getDataPointsRec.return_date_format;
					i := i + 1;
				END LOOP;

END;
END OCM_DATA_POINTS_PUB;

/
