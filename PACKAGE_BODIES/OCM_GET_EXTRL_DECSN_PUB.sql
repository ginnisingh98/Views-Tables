--------------------------------------------------------
--  DDL for Package Body OCM_GET_EXTRL_DECSN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OCM_GET_EXTRL_DECSN_PUB" AS
/* $Header: ARCMPEXTB.pls 120.4 2005/12/27 18:28:31 bsarkar noship $ */
pg_debug VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

PROCEDURE debug (
        p_message_name          IN      VARCHAR2 ) IS
BEGIN
    ar_cmgt_util.debug (p_message_name, 'ar.cmgt.plsql.OCM_CREDIT_REQUEST_UPDATE_PUB' );
END;

 PROCEDURE Get_Score
     (  p_api_version		IN		NUMBER,
	    p_init_msg_list		IN		VARCHAR2 DEFAULT FND_API.G_TRUE,
	    p_commit		    IN		VARCHAR2,
	    p_validation_level	IN		VARCHAR2,
	    x_return_status		OUT NOCOPY	VARCHAR2,
	    x_msg_count		OUT NOCOPY	NUMBER,
        x_msg_data             	OUT NOCOPY	VARCHAR2,
        p_case_folder_id	IN		NUMBER,
        p_score_model_id	IN		NUMBER Default NULL,
        p_score			IN		NUMBER
     ) IS
l_case_folder_type      ar_cmgt_case_folders.type%type;
l_case_folder_status    ar_cmgt_case_folders.status%type;
l_data_point_id         ar_cmgt_score_dtls.DATA_POINT_ID%type;
l_party_id              ar_cmgt_case_folders.party_id%type;
l_cust_account_id       ar_cmgt_case_folders.cust_account_id%type;
l_site_use_id           ar_cmgt_case_folders.site_use_id%type;
l_score_model_id        ar_cmgt_case_folders.score_model_id%type;
l_data_point_code	ar_cmgt_data_points_b.data_point_code%type;
BEGIN
/* The following validation will be placed into the procedure
  1. If Score Model Id is passed then it must match with the case folder
     score_model_id and conatin the External Score data points.
     If the scoring model does not contain this data points then API should reject the score.
  2. Case folder Id must be of typed 'CASE'
  3. The case folder status must be in 'CREATED' or 'SAVED' status.
  4. Once the score is updated in 'CASE' type the same score need to be updated
     in 'DATA' type record also.
*/
      IF pg_debug = 'Y'
      THEN
              debug ( 'OCM_GET_EXTRL_DECSN_PUB.Get_Score(+)');
              debug ( 'Case Folder ID ' || p_case_folder_id);
              debug ( 'Score Model ID ' || p_score_model_id);
              debug ( 'Score ' || p_score);
      END IF;

  SAVEPOINT CREDIT_SCORE_PVT;

    IF FND_API.to_Boolean( p_init_msg_list )
          THEN
              FND_MSG_PUB.initialize;
          END IF;

  x_return_status         := FND_API.G_RET_STS_SUCCESS;

 IF p_case_folder_id IS NOT NULL THEN
    BEGIN
           select type,
		  status,
                  score_model_id,
                  party_id,
                  cust_account_id,
		          site_use_id
           into l_case_folder_type,
                l_case_folder_status,
                l_score_model_id,
                l_party_id,
                l_cust_account_id,
                l_site_use_id
           from ar_cmgt_case_folders
           where case_folder_id = p_case_folder_id ;

    IF l_case_folder_type = 'CASE' and
        ((l_case_folder_status = 'CREATED') or (l_case_folder_status = 'SAVED')
          or (l_case_folder_status = 'IN_PROCESS') ) THEN
    	  IF p_score_model_id IS NOT NULL  and (p_score_model_id = l_score_model_id) THEN
               BEGIN
       	 	 select sc.DATA_POINT_ID, dp.data_point_code
                 into   l_data_point_id, l_data_point_code
 		 from   ar_cmgt_score_dtls sc, ar_cmgt_data_points_vl dp
 		 where  sc.SCORE_MODEL_ID = p_score_model_id
 		 and    sc.data_point_id = dp.data_point_id
		 and    dp.data_point_code = 'OCM_EXTERNAL_SCORE';

                 update ar_cmgt_cf_dtls
                 set score = p_score,
		     data_point_value = p_score
                 where CASE_FOLDER_ID = p_case_folder_id
                 and DATA_POINT_ID = l_data_point_id;

                 update ar_cmgt_cf_dtls
                 set  score = p_score,
		     data_point_value = p_score
                 where CASE_FOLDER_ID = ( select CASE_FOLDER_ID
                                          from   ar_cmgt_case_folders
                                          where type = 'DATA'
                                          and   party_id = l_party_id
                                          and   cust_account_id = l_cust_account_id
                                          and   site_use_id  = l_site_use_id)
                 and  DATA_POINT_ID = l_data_point_id;
               EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        FND_MESSAGE.SET_NAME('AR','OCM_INVALID_SCORE_MODEL_ID');
                        FND_MSG_PUB.Add;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                    WHEN OTHERS THEN
                       x_return_status := FND_API.G_RET_STS_ERROR;
                        FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                        FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','GET_SCORE : '||SQLERRM);
               END ;

          ELSE
            /*Message : Please provide a score model id which matches with the case folder's
              score model id and conatin the External Score data points.  */
           FND_MESSAGE.SET_NAME('AR','OCM_INVALID_SCORE_MODEL_ID');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR;

  	 END IF;
    ELSE
      /*Message : Please provide a case folder id of case folder type 'CASE' and
                   status as 'CREATED' or 'SAVED' */
        FND_MESSAGE.SET_NAME('AR','OCM_INVALID_CASE_FOLDER');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
   EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('AR','OCM_INVALID_CASE_FOLDER');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR;
         WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
            FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','GET_SCORE : '||SQLERRM);

   END ;
 ELSE
      /*Messae : Please provide a case folder id of case folder type 'CASE' and
                   status as 'CREATED' or 'SAVED' */
        FND_MESSAGE.SET_NAME('AR','OCM_INVALID_CASE_FOLDER');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
 END IF;

  IF x_return_status =  FND_API.G_RET_STS_ERROR THEN
          ROLLBACK TO CREDIT_SCORE_PVT;
  END IF;
      IF pg_debug = 'Y'
      THEN
              debug ( 'OCM_GET_EXTRL_DECSN_PUB.Get_Score(-)');
      END IF;
EXCEPTION
        WHEN OTHERS  THEN

                      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                      FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                      FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','GET_SCORE : '||SQLERRM);
                      FND_MSG_PUB.Add;

                ROLLBACK TO CREDIT_SCORE_PVT;

END Get_Score;

PROCEDURE Include_Data_Points
     (  p_api_version           IN              NUMBER,
        p_init_msg_list         IN              VARCHAR2 DEFAULT FND_API.G_TRUE,
        p_commit                IN              VARCHAR2,
        p_validation_level      IN              VARCHAR2,
        x_return_status         OUT NOCOPY      VARCHAR2,
        x_msg_count             OUT NOCOPY      NUMBER,
        x_msg_data              OUT NOCOPY      VARCHAR2,
        p_case_folder_id        IN              NUMBER,
        p_data_point_id         IN              data_point_id_varray
     ) IS
l_case_folder_type      ar_cmgt_case_folders.type%type;
l_case_folder_status      ar_cmgt_case_folders.status%type;
l_data_point_id         ar_cmgt_cf_dtls.DATA_POINT_ID%type;
BEGIN
/*  The following validation will be placed into the procedure
    1. Case folder Id must be of typed 'CASE'
    2. The case folder status must be in 'CREATED' or 'SAVED' status.
    3. Data Point Id must be a valid data point Id
*/
      IF pg_debug = 'Y'
      THEN
              debug ( 'OCM_GET_EXTRL_DECSN_PUB.Include_Data_Points(+)');
              debug ( 'Case Folder ID ' || p_case_folder_id);
--              debug ( 'Data Point IDs ' || p_data_point_id);
      END IF;

  SAVEPOINT CREDIT_INCLUDE_DP_PVT;

    IF FND_API.to_Boolean( p_init_msg_list )
          THEN
              FND_MSG_PUB.initialize;
    END IF;

  x_return_status         := FND_API.G_RET_STS_SUCCESS;
 IF p_case_folder_id IS NOT NULL THEN
  BEGIN
           select type,
                  status
           into   l_case_folder_type,
                  l_case_folder_status
           from   ar_cmgt_case_folders
           where   case_folder_id = p_case_folder_id ;

    IF l_case_folder_type = 'CASE' and
        ((l_case_folder_status = 'CREATED') or (l_case_folder_status = 'SAVED')
          or (l_case_folder_status = 'IN_PROCESS')) THEN
          IF p_data_point_id IS NOT NULL THEN
             FOR  i IN 1..p_data_point_id.count
             LOOP
                 BEGIN
                    select DATA_POINT_ID
                    into   l_data_point_id
                    from   ar_cmgt_cf_dtls
                    where  case_folder_id = p_case_folder_id
                    and    DATA_POINT_ID = p_data_point_id(i);

	            update ar_cmgt_cf_dtls
		    set included_in_checklist = 'Y'
		    where case_folder_id = p_case_folder_id
		    and data_point_id = l_data_point_id;

                  EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                           FND_MESSAGE.SET_NAME('AR','OCM_INVALID_DATAPOINT_ID');
                           FND_MSG_PUB.Add;
                           x_return_status := FND_API.G_RET_STS_ERROR;
                       WHEN OTHERS THEN
                          x_return_status := FND_API.G_RET_STS_ERROR;
                           FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                           FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','Include_Data_Points : '||SQLERRM);
                END ;
             END LOOP;
          ELSE
            /*Message : Please provide a valid data point id */
           FND_MESSAGE.SET_NAME('AR','OCM_INVALID_DATAPOINT_ID');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR;

         END IF;
    ELSE
      /*Message : Please provide a case folder id of case folder type 'CASE' and
                   status as 'CREATED' or 'SAVED' */
        FND_MESSAGE.SET_NAME('AR','OCM_INVALID_CASE_FOLDER');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

   EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('AR','OCM_INVALID_CASE_FOLDER');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR;
         WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
            FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','Include_Data_Points : '||SQLERRM);

   END ;
 ELSE
      /*Message : Please provide a case folder id of case folder type 'CASE' and
                   status as 'CREATED' or 'SAVED' */
        FND_MESSAGE.SET_NAME('AR','OCM_INVALID_CASE_FOLDER');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
 END IF;

  IF x_return_status =  FND_API.G_RET_STS_ERROR THEN
          ROLLBACK TO CREDIT_INCLUDE_DP_PVT;
  END IF;
      IF pg_debug = 'Y'
      THEN
              debug ( 'OCM_GET_EXTRL_DECSN_PUB.Include_Data_Points(-)');
      END IF;
EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
         FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','Include_Data_Points : '||SQLERRM);
         FND_MSG_PUB.Add;

          ROLLBACK TO CREDIT_INCLUDE_DP_PVT;
END ;

PROCEDURE Get_Recommendations
     (  p_api_version           IN              NUMBER,
        p_init_msg_list         IN              VARCHAR2 DEFAULT FND_API.G_TRUE,
        p_commit                IN              VARCHAR2,
        p_validation_level      IN              VARCHAR2,
        x_return_status         OUT NOCOPY      VARCHAR2,
        x_msg_count             OUT NOCOPY      NUMBER,
        x_msg_data              OUT NOCOPY      VARCHAR2,
        p_case_folder_id        IN              NUMBER,
        p_recommendations_type  IN              VARCHAR2,
        p_recommendations_tbl   IN              credit_recommendation_tbl
     ) IS
l_case_folder_type      ar_cmgt_case_folders.type%type;
l_case_folder_status    ar_cmgt_case_folders.status%type;
l_credit_request_id     ar_cmgt_case_folders.credit_request_id%type;
l_credit_type           ar_cmgt_credit_requests.credit_type%type;
l_lookup_type           fnd_lookups.lookup_type%type;
l_application_id        ar_cmgt_credit_requests.SOURCE_RESP_APPLN_ID%type;

BEGIN
/*  The following validation will be placed into the API
  1.	Case folder Id must be of typed 'CASE'.
  2. 	The case folder status must be in 'CREATED' or 'SAVED' status.
  3.    Recommendations type will be validated against the FND lookup type.
  4.	Individual Recommendations will be validated against lookup code of the Recommendations type.
*/
      IF pg_debug = 'Y'
      THEN
              debug ( 'OCM_GET_EXTRL_DECSN_PUB.Get_Recommendations(+)');
              debug ( 'Case Folder ID ' || p_case_folder_id);
              debug ( 'Recommendation Type ' || p_recommendations_type);
      END IF;

  SAVEPOINT CREDIT_GET_RECO_PVT;

    IF FND_API.to_Boolean( p_init_msg_list )
          THEN
              FND_MSG_PUB.initialize;
    END IF;

  x_return_status         := FND_API.G_RET_STS_SUCCESS;
 IF p_case_folder_id IS NOT NULL THEN
 BEGIN
           select ar_cmgt_case_folders.type,
                  ar_cmgt_case_folders.status,
                  ar_cmgt_case_folders.credit_request_id,
                  ar_cmgt_credit_requests.credit_type,
                  ar_cmgt_credit_requests.SOURCE_RESP_APPLN_ID
           into   l_case_folder_type,
                  l_case_folder_status,
                  l_credit_request_id,
                  l_credit_type,
                  l_application_id
           from   ar_cmgt_case_folders,
                  ar_cmgt_credit_requests
           where  ar_cmgt_case_folders.case_folder_id = p_case_folder_id ;

    IF l_case_folder_type = 'CASE' and
        ((l_case_folder_status = 'CREATED') or (l_case_folder_status = 'SAVED')
          or (l_case_folder_status = 'IN_PROCESS') ) THEN
             IF p_recommendations_type IS NOT NULL and p_recommendations_tbl IS NOT NULL THEN
                   /* validation of Recommendations type */
              BEGIN
                   select  LOOKUP_TYPE
                   into    l_lookup_type
                   from    fnd_lookups
                   where   lookup_type = p_recommendations_type
                   and     enabled_flag = 'Y'
                   and     rownum =1;

                FOR i in 1 .. p_recommendations_tbl.count LOOP
               /*Individual Recommendations will be validated against lookup code of the Recommendations type */
                   select  LOOKUP_TYPE
                   into    l_lookup_type
                   from    fnd_lookups
                   where   lookup_type = p_recommendations_type
                   and     enabled_flag = 'Y'
                   and     lookup_code = p_recommendations_tbl(i).Credit_Recommendation;

                  INSERT INTO AR_CMGT_CF_RECOMMENDS
                                    (RECOMMENDATION_ID,
                                    LAST_UPDATED_BY,
                                    LAST_UPDATE_DATE,
                                    LAST_UPDATE_LOGIN,
                                    CREATION_DATE,
                                    CREATED_BY,
                                    CASE_FOLDER_ID,
                                    CREDIT_REQUEST_ID,
                                    CREDIT_REVIEW_DATE,
                                    CREDIT_RECOMMENDATION,
                                    RECOMMENDATION_VALUE1,
                                    RECOMMENDATION_VALUE2,
                                    STATUS,
                                    CREDIT_TYPE,
                                    RECOMMENDATION_NAME,
                                    APPLICATION_ID)
                                    (SELECT AR_CMGT_CF_RECOMMENDS_S.NEXTVAL,
                                    fnd_global.user_id,
                                    SYSDATE,
                                    fnd_global.login_id,
                                    SYSDATE,
                                    fnd_global.user_id,
                                    p_case_folder_id,
                                    l_credit_request_id,
                                    SYSDATE,
                                    p_recommendations_tbl(i).Credit_Recommendation,
                                    p_recommendations_tbl(i).Recommendation_value1,
                                    p_recommendations_tbl(i).Recommendation_value2,
                                    'O',
                                    l_credit_type,
                                    p_recommendations_type,
                                    l_application_id
                                    FROM dual
                                    );
                END LOOP;
               EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                          FND_MESSAGE.SET_NAME('AR','OCM_INVALID_RECOMMENDATIONS');
                          FND_MSG_PUB.Add;
                          x_return_status := FND_API.G_RET_STS_ERROR;
                      WHEN OTHERS THEN
                         x_return_status := FND_API.G_RET_STS_ERROR;
                          FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
                          FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','Get_Recommendations : '||SQLERRM);
              END;
             ELSE
                   /*Message : Please provide a valid data point id */
                  FND_MESSAGE.SET_NAME('AR','OCM_INVALID_RECOMMENDATIONS');
                  FND_MSG_PUB.Add;
                  x_return_status := FND_API.G_RET_STS_ERROR;
             END IF;
    ELSE
      /*Message : Please provide a case folder id of case folder type 'CASE' and
                   status as 'CREATED' or 'SAVED' */
        FND_MESSAGE.SET_NAME('AR','OCM_INVALID_CASE_FOLDER');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('AR','OCM_INVALID_CASE_FOLDER');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR;
         WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
            FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','Get_Recommendations : '||SQLERRM);

   END ;

 ELSE
      /*Message : Please provide a case folder id of case folder type 'CASE' and
                   status as 'CREATED' or 'SAVED' */
        FND_MESSAGE.SET_NAME('AR','OCM_INVALID_CASE_FOLDER');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
 END IF;
  IF x_return_status =  FND_API.G_RET_STS_ERROR THEN
          ROLLBACK TO CREDIT_GET_RECO_PVT;
  END IF;
      IF pg_debug = 'Y'
      THEN
              debug ( 'OCM_GET_EXTRL_DECSN_PUB.Get_Recommendations(-)');
      END IF;
EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
         FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','Get_Recommendations : '||SQLERRM);
         FND_MSG_PUB.Add;
          ROLLBACK TO CREDIT_GET_RECO_PVT;

END ;

PROCEDURE Submit_Case_Folder
     (  p_api_version           IN              NUMBER,
        p_init_msg_list         IN              VARCHAR2 DEFAULT FND_API.G_TRUE,
        p_commit                IN              VARCHAR2,
        p_validation_level      IN              VARCHAR2,
        x_return_status         OUT NOCOPY      VARCHAR2,
        x_msg_count             OUT NOCOPY      NUMBER,
        x_msg_data              OUT NOCOPY      VARCHAR2,
        p_case_folder_id        IN              NUMBER
     ) IS
l_case_folder_type      ar_cmgt_case_folders.type%type;
l_case_folder_status    ar_cmgt_case_folders.status%type;
l_credit_request_id     ar_cmgt_case_folders.credit_request_id%type;
BEGIN
/*  The following validation will be placed into the API
  1.	Case folder Id must be of typed 'CASE'.
  2. 	The case folder status must be in 'CREATED' or 'SAVED' status.
  3.	Will update the status of the case folder to Submitted and workflow
        need to be kicked off and will continue for Approval route.
*/
      IF pg_debug = 'Y'
      THEN
              debug ( 'OCM_GET_EXTRL_DECSN_PUB.Submit_Case_Folder(+)');
              debug ( 'Case Folder ID ' || p_case_folder_id);
      END IF;

  SAVEPOINT CASE_FOLDER_SUBMIT_PVT;

    IF FND_API.to_Boolean( p_init_msg_list )
          THEN
              FND_MSG_PUB.initialize;
    END IF;

  x_return_status         := FND_API.G_RET_STS_SUCCESS;

 IF p_case_folder_id IS NOT NULL THEN
 BEGIN
           select type,
                  status,
                  credit_request_id
           into   l_case_folder_type,
                  l_case_folder_status,
                  l_credit_request_id
           from   ar_cmgt_case_folders
           where  case_folder_id = p_case_folder_id ;

    IF l_case_folder_type = 'CASE' and
        ((l_case_folder_status = 'CREATED') or (l_case_folder_status = 'SAVED')
          or (l_case_folder_status = 'IN_PROCESS') ) THEN
            /* Update case folder status  to 'SUBMIT' and kick of the worlflow */
                    update ar_cmgt_case_folders
                    set status = 'SUBMIT'
                    where case_folder_id = p_case_folder_id ;

                      AR_CMGT_WF_ENGINE.START_WORKFLOW
                           (l_credit_request_id ,'SUBMIT');
    ELSE
      /*Message : Please provide a case folder id of case folder type 'CASE' and
                   status as 'CREATED' or 'SAVED' */
        FND_MESSAGE.SET_NAME('AR','OCM_INVALID_CASE_FOLDER');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
   EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('AR','OCM_INVALID_CASE_FOLDER');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR;
         WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
            FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','Submit_Case_Folder : '||SQLERRM);
   END ;

 ELSE
      /*Message : Please provide a case folder id of case folder type 'CASE' and
                   status as 'CREATED' or 'SAVED' */
        FND_MESSAGE.SET_NAME('AR','OCM_INVALID_CASE_FOLDER');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
 END IF;
  IF x_return_status =  FND_API.G_RET_STS_ERROR THEN
          ROLLBACK TO CASE_FOLDER_SUBMIT_PVT;
  END IF;
      IF pg_debug = 'Y'
      THEN
              debug ( 'OCM_GET_EXTRL_DECSN_PUB.Submit_Case_Folder(-)');
      END IF;
EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
         FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','Submit_Case_Folder : '||SQLERRM);
         FND_MSG_PUB.Add;
          ROLLBACK TO CASE_FOLDER_SUBMIT_PVT;

END ;

END OCM_GET_EXTRL_DECSN_PUB;

/
