--------------------------------------------------------
--  DDL for Package Body PON_TEAM_SCORING_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_TEAM_SCORING_UTIL_PVT" AS
/*$Header: PONVSTUB.pls 120.7.12010000.6 2015/10/09 06:22:09 irasoolm ship $*/

g_pkg_name CONSTANT VARCHAR2(30) := 'PON_TEAM_SCORING_UTIL_PVT';

--------------------------------------------------------------------------------
--                 Private procedure/function definitions                     --
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--                 Public procedure/function definition                       --
--------------------------------------------------------------------------------


PROCEDURE calculate_dependent_req_score(p_auction_header_id IN NUMBER,
                                        p_bid_number IN NUMBER,
                                        p_sequence_number IN NUMBER,
                                        p_is_root IN VARCHAR2,
                                        x_score IN OUT NOCOPY NUMBER
                                         )
AS

child_exists NUMBER;
l_score NUMBER := 0;
l_score_sum NUMBER := 0;
l_child_num NUMBER := 0;
l_score_avg NUMBER := 0;
l_scoring_method VARCHAR2(50);

BEGIN
  BEGIN

  SELECT scoring_method INTO l_scoring_method
  FROM pon_Auction_attributes
  WHERE auction_header_id = p_auction_Header_id
  AND sequence_Number = p_sequence_number
  AND line_number = -1;

  IF l_scoring_method = 'NONE' THEN
    x_score := 0;
    RETURN;
  END IF;

  SELECT 1 INTO child_exists
  FROM pon_attributes_rules rules, pon_bid_attribute_values pba
  WHERE rules.auction_Header_id = p_auction_Header_id
  AND rules.parent_requirement_id = p_sequence_number
  AND pba.auction_header_id = rules.auction_header_id
  AND pba.bid_number = p_bid_number
  AND pba.auctioN_line_number = -1
  AND pba.sequence_number = rules.parent_requirement_id
  AND pba.Value IS NOT NULL
  AND ((OPERATOR = 'IS' AND rules.response_value = pba.Value)
        OR (OPERATOR = 'IS_NOT' AND Nvl2(pba.Value,rules.response_value,-1) <> Nvl(pba.Value,-1))
        OR (OPERATOR = 'LESSER_THAN' AND
            ((pba.datatype = 'NUM' and to_number(pba.value) < to_number(response_value))
            or (pba.datatype = 'DAT' AND to_date(pba.value,'dd-mm-yyyy') < to_date(rules.response_value,'dd-mm-yyyy'))))

        OR (OPERATOR = 'GREATER_THAN' AND
            ((pba.datatype = 'NUM' and to_number(pba.value) > to_number(response_value))
            or (pba.datatype = 'DAT' AND to_date(pba.value,'dd-mm-yyyy') > to_date(rules.response_value,'dd-mm-yyyy'))))
        OR (OPERATOR = 'BETWEEN' AND
        ((pba.datatype = 'NUM' and to_number(pba.value) > to_number(response_value))
            or (pba.datatype = 'DAT' AND to_date(pba.value,'dd-mm-yyyy') > to_date(rules.response_value,'dd-mm-yyyy')))
        and ((pba.datatype = 'NUM' and to_number(pba.value) < to_number(response_value_upper_limit))
            or (pba.datatype = 'DAT' AND to_date(pba.value,'dd-mm-yyyy') < to_date(rules.response_value_upper_limit,'dd-mm-yyyy'))))
        )
  AND ROWNUM < 2;


  EXCEPTION
  WHEN OTHERS THEN
    child_exists:= 0;
  END;


  IF child_exists = 1 THEN
    FOR children IN ( SELECT UNIQUE dependent_requirement_id
                      FROM pon_attributes_rules rules, pon_bid_attribute_values pbav
                      WHERE rules.auction_header_Id = p_auction_header_Id
                      AND rules.auction_header_Id = pbav.auction_header_Id
                      AND pbav.bid_number = p_bid_Number
                      AND rules.parent_requirement_id = p_sequence_number
                      AND rules.dependent_requirement_id = pbav.SEQUENCE_NUMBER
                      AND pbav.Value IS NOT NULL
                      AND pbav.auction_line_number = -1   ) LOOP
      calculate_dependent_req_score(p_auction_header_id,
                                    p_bid_number,
                                    children.dependent_requirement_id,
                                    'N',
                                    l_score );
      l_score_sum := l_score_sum + l_score;
      l_child_num := l_child_num + 1;

    END LOOP;

    l_score_avg := l_score_sum/l_child_num;

    IF p_is_root = 'N' THEN

      /*
      Bug 20797420
      weighted_score can be null.
      So we have to calculate score/maxscore
      */

      IF Nvl(l_score_avg,0) = 0 THEN
         /*
         If scoring is not used at child level, then it should be taken as 1 so it won't impact parent scoring
         */
         l_score_avg := 1;
      END IF;

      SELECT
      (Nvl2(paa.attr_max_score,(Nvl(pbav.score,0)/paa.attr_max_score) * l_score_avg, 1*l_score_avg))
      INTO x_score
      FROM pon_bid_attribute_values pbav, pon_auction_attributes paa
      WHERE bid_number = p_bid_number
      AND paa.auction_Header_id = pbav.auctioN_header_id
      AND paa.attribute_name  = pbav.attribute_name
      AND paa.sequence_number = p_sequence_number
      AND pbav.AUCTION_LINE_NUMBER = -1
      AND paa.line_Number = -1 ;

    ELSE
      x_score := l_score_avg;
    END IF;


  ELSE
      /*
      Bug 20797420
      weighted_score can be null.
      So we have to calculate score/maxscore
      */

       SELECT
      (Nvl2(paa.attr_max_score,(Nvl(pbav.score,0)/paa.attr_max_score) , 0))
      INTO x_score
      FROM pon_bid_attribute_values pbav, pon_auction_attributes paa
      WHERE bid_number = p_bid_number
      AND paa.auction_Header_id = pbav.auctioN_header_id
      AND paa.attribute_name  = pbav.attribute_name
      AND paa.sequence_number = p_sequence_number
      AND pbav.AUCTION_LINE_NUMBER = -1
      AND paa.line_Number = -1 ;



  END IF;

EXCEPTION
WHEN OTHERS THEN
x_score := 0;

END calculate_dependent_req_score;

--------------------------------------------------------------------------------
---                lock_scoring                                               --
--------------------------------------------------------------------------------

PROCEDURE lock_scoring(
          p_api_version              IN  NUMBER
	    ,p_auction_header_id       IN  pon_auction_headers_all.auction_header_id%TYPE
	    ,p_tpc_id                  IN pon_auction_headers_all.trading_partner_contact_id%TYPE
     	    ,x_return_status           OUT NOCOPY VARCHAR2
          ,x_msg_data                OUT NOCOPY VARCHAR2
          ,x_msg_count               OUT NOCOPY NUMBER
          ) IS


l_api_name    CONSTANT VARCHAR2(30) := 'LOCK_SCORING';
l_api_version CONSTANT NUMBER       := 1.0;
l_stage                VARCHAR2(50);


l_hierarchy_exists VARCHAR2(1);
l_child_score NUMBER;


BEGIN

 -- Check for API comptability
 l_stage := '10: API check';

 IF  fnd_api.compatible_api_call(
        p_current_version_number => l_api_version
       ,p_caller_version_number  => p_api_version
       ,p_api_name               => l_api_name
       ,p_pkg_name               => g_pkg_name)
 THEN
    NULL;
 ELSE
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

 -- update auction header if input parameters are not null
 l_stage := '20: updates begin here';

 IF (p_auction_header_id IS NULL) OR (p_tpc_id IS NULL) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

  -- update auction header
  l_stage := '30: update auction header';

  UPDATE pon_auction_headers_all
  SET    scoring_lock_date = SYSDATE
	   ,scoring_lock_tp_contact_id = p_tpc_id
         ,last_update_date = SYSDATE
	   ,last_updated_by = fnd_global.user_id
  WHERE  auction_header_id = p_auction_header_id
  AND    scoring_lock_date IS NULL;

  IF SQL%NOTFOUND THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_stage := '35: update the pon bid attribute values table';
  MERGE
  INTO pon_bid_attribute_values pbav
  USING
   (
   SELECT
      UNIQUE rules.parent_requirement_id
      ,ptmas.auction_header_id
      ,ptmas.bid_number
      ,paa.attribute_name
      ,paa.datatype
      ,null value
      ,SYSDATE creation_date
      ,fnd_global.user_id created_by
      ,SYSDATE last_update_date
      ,fnd_global.user_id updated_by
      ,AVG(ptmas.score) score
      ,ptmas.attribute_sequence_number
      ,paa.attr_level
      ,paa.attr_max_score
	  ,Nvl2(parent_requirement_id,1,paa.weight) weight
      ,paa.attr_group_seq_number
      ,paa.attr_disp_seq_number
      ,null old_value
   FROM pon_team_member_attr_scores ptmas
      ,pon_auction_attributes paa
      ,pon_team_member_bid_scores ptmbs
      ,pon_bid_headers pbh
      ,pon_auction_headers_all paha
      ,pon_auction_sections pas
      ,pon_attributes_rules rules
   WHERE  ptmas.auction_header_id = p_auction_header_id
      AND ptmas.auction_header_id = paa.auction_header_id
      AND paa.line_number = -1
      AND paa.attribute_list_id = -1
      AND paa.scoring_method = 'MANUAL'
      AND NVL(paa.display_only_flag, 'N') = 'N'
      AND ptmas.attribute_sequence_number = paa.sequence_number
      AND ptmbs.bid_number = ptmas.bid_number
      AND ptmbs.user_id = ptmas.user_id
      AND ptmbs.score_status = 'SUBMIT'
      AND ptmas.score IS NOT NULL
      AND pbh.auction_header_id = ptmas.auction_header_id
      AND ptmas.bid_number = pbh.bid_number
      AND pbh.bid_status = 'ACTIVE'
      AND paha.auction_header_id = paa.auction_header_id
      AND pas.auction_header_id = paa.auction_header_id
      AND pas.attr_group_seq_number = paa.attr_group_seq_number
      AND pas.section_name = paa.section_name
      AND (NVL(paha.two_part_flag,'N') = 'N' OR
          (paha.two_part_flag = 'Y' AND paha.sealed_auction_status = 'LOCKED') OR
          (paha.two_part_flag = 'Y' AND paha.sealed_auction_status <> 'LOCKED' AND pas.two_part_section_type = 'COMMERCIAL'))
      AND rules.auction_header_id(+) = ptmas.auction_header_id
      AND rules.dependent_requirement_id(+) = ptmas.attribute_sequence_number
   GROUP BY ptmas.auction_header_id
      ,ptmas.bid_number
      ,ptmas.attribute_sequence_number
      ,paa.attribute_name
      ,paa.datatype
      ,SYSDATE
      ,fnd_global.user_id
      ,SYSDATE
      ,fnd_global.user_id
      ,paa.attr_level
      ,paa.attr_max_score
      ,paa.weight
      ,paa.attr_group_seq_number
      ,paa.attr_disp_seq_number
      ,rules.parent_requirement_id
   )ptmavg
   ON
   (ptmavg.auction_header_id = pbav.auction_header_id
   AND ptmavg.bid_number = pbav.bid_number
   AND ptmavg.attribute_name = pbav.attribute_name
   AND pbav.auction_line_number = -1
   )
   WHEN MATCHED
   THEN
 UPDATE --update score and weighted score on required and optional attributes
   SET pbav.score = ptmavg.score
       ,pbav.weighted_score = ((ptmavg.score*ptmavg.weight)/NVL(ptmavg.attr_max_score, 0))
   WHEN NOT MATCHED
   THEN
 INSERT -- internal attributes
   (
      pbav.auction_header_id
      ,pbav.auction_line_number
      ,pbav.bid_number
      ,pbav.line_number
      ,pbav.attribute_name
      ,pbav.datatype
      ,pbav.value
      ,pbav.creation_date
      ,pbav.created_by
      ,pbav.last_update_date
      ,pbav.last_updated_by
      ,pbav.score
      ,pbav.sequence_number
      ,pbav.attr_level
      ,pbav.weighted_score
      ,pbav.attr_group_seq_number
      ,pbav.attr_disp_seq_number
      ,pbav.old_value
   )
   VALUES
   (
      ptmavg.auction_header_id
      ,-1
      ,ptmavg.bid_number
      ,-1
      ,ptmavg.attribute_name
      ,ptmavg.datatype
      ,null
      ,SYSDATE -- creation_date
      ,fnd_global.user_id -- created_by
      ,SYSDATE -- last_update_date
      ,fnd_global.user_id -- updated_by
      ,ptmavg.score -- Calculated member Average Score
      ,ptmavg.attribute_sequence_number
      ,ptmavg.attr_level
      ,((ptmavg.score*ptmavg.weight)/NVL(ptmavg.attr_max_score, 0)) -- calculated weighted score
      ,ptmavg.attr_group_seq_number
      ,ptmavg.attr_disp_seq_number
      ,null
   );


   BEGIN
    SELECT 'Y' INTO l_hierarchy_exists
    FROM pon_attributes_rules
    WHERE auction_header_id = p_auction_header_id
    AND ROWNUM < 2;

   EXCEPTION
   WHEN OTHERS THEN
     l_hierarchy_exists:='N';
   END;

   IF l_hierarchy_exists = 'Y' THEN
     FOR root_reqs IN (SELECT paa.sequence_number, pbh.bid_number
                       FROM pon_auction_attributes paa, pon_bid_headers pbh
                       WHERE paa.auction_Header_id = p_auction_Header_id
                       AND paa.auction_Header_id = pbh.auction_Header_id
                       AND paa.LINE_NUMBER = -1
                       AND paa.scoring_method <> 'NONE'
                       AND pbh.bid_status = 'ACTIVE'
                       AND NOT EXISTS(SELECT 1 FROM pon_attributes_rules rules2
                                      WHERE rules2.auction_Header_id = p_auction_Header_id
                                      AND rules2.dependent_requirement_id =  paa.sequence_number)
                       AND EXISTS(SELECT 1 FROM pon_attributes_rules rules2
                                      WHERE rules2.auction_Header_id = p_auction_Header_id
                                      AND rules2.parent_requirement_id =  paa.sequence_number))
     LOOP
       l_child_score := 0;
       calculate_dependent_req_score(p_auction_header_id, root_reqs.bid_number, root_reqs.sequence_number,'Y',  l_child_score);

       /*
       Bug 20797420
       l_child_score is weighted sum of all the children. Its value should be between 0 and 1
       pbav.score is the score of parent requirement.
       */

       IF Nvl(l_child_score,0) = 0 THEN
         /*
         If scoring is not used at child level, then it should be taken as 1 so it won't impact parent scoring
         */
         l_child_score := 1;
       END IF;

       UPDATE pon_bid_attribute_values
       SET weighted_score = (SELECT (weight * l_child_score * Nvl(pbav.score,0))/attr_max_score
                            FROM pon_bid_attribute_values pbav, pon_auction_attributes paa
                            WHERE paa.auction_HEADER_ID = p_auctioN_header_id
                            AND paa.auction_Header_id = pbav.auctioN_header_id
                            AND paa.sequence_number = root_reqs.sequence_number
                            AND paa.sequence_number = pbav.sequence_number
                            AND pbav.bid_number = root_reqs.bid_number
                            AND paa.line_number = -1
                            AND pbav.auction_line_number = -1)
       WHERE bid_number = root_reqs.bid_number
       AND sequence_number = root_reqs.sequence_number
       AND AUCTION_LINE_NUMBER = -1 ;


     END LOOP;

     UPDATE pon_bid_attribute_values pbav
     SET weighted_score = NULL
     WHERE auction_header_id = p_auction_Header_id
     AND AUCTION_LINE_NUMBER = -1
     AND EXISTS(SELECT 1 FROM pon_attributes_rules
                WHERE auction_Header_id = p_auction_Header_id
                AND pbav.sequence_number = dependent_requirement_id);
   END IF;

  x_return_status := fnd_api.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  IF fnd_msg_pub.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
	     fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name,SQLERRM);
	     IF ( fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
		   fnd_log.string(log_level => fnd_log.level_unexpected
     		  	        ,module   => g_pkg_name ||'.'||l_api_name
                          ,message  => l_stage || ': ' || SQLERRM);
	       fnd_log.string(log_level=>fnd_log.level_unexpected
                          ,module   =>g_pkg_name ||'.'||l_api_name
                          ,message  => 'Input parameter list: ' );
	       fnd_log.string(log_level=>fnd_log.level_unexpected
                          ,module   =>g_pkg_name ||'.'||l_api_name
                          ,message  => 'Auction Header Id :'||p_auction_header_id);
	       fnd_log.string(log_level=>fnd_log.level_unexpected
                          ,module   =>g_pkg_name ||'.'||l_api_name
                          ,message  => 'Trading Partner Contact Id'|| p_tpc_id );
	       fnd_log.string(log_level=>fnd_log.level_unexpected
                          ,module   =>g_pkg_name ||'.'||l_api_name
                          ,message  => 'p_api_version: '||p_api_version );
        END IF;
     END IF;
     FND_MSG_PUB.Count_and_Get(p_count => x_msg_count
                              ,p_data  => x_msg_data);
END;

--------------------------------------------------------------------------------
---            delete_member_scores                                           --
--------------------------------------------------------------------------------

PROCEDURE delete_member_scores(
          p_api_version              IN  NUMBER
	    ,p_auction_header_id       IN
 			pon_auction_headers_all.auction_header_id%TYPE
          ,p_team_id             	 IN  pon_scoring_teams.team_id%TYPE
	    ,p_user_id                 IN  fnd_user.user_id%TYPE
     	    ,x_return_status           OUT NOCOPY VARCHAR2
          ,x_msg_data                OUT NOCOPY VARCHAR2
          ,x_msg_count               OUT NOCOPY NUMBER
          )IS

l_api_name    CONSTANT VARCHAR2(30) := 'DELTE_MEMBER_SCORES';
l_api_version CONSTANT NUMBER       := 1.0;
l_stage                VARCHAR2(50);



BEGIN

 -- Check for API comptability
 l_stage := '10: API check';

 IF  fnd_api.compatible_api_call(
        p_current_version_number => l_api_version
       ,p_caller_version_number  => p_api_version
       ,p_api_name               => l_api_name
       ,p_pkg_name               => g_pkg_name)
 THEN
    NULL;
 ELSE
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

 -- delete scores if input parameters are not null
 l_stage := '20: deletes begin here';

 IF  (p_auction_header_id IS NULL)
     OR (p_user_id IS NULL)
     OR (p_team_id IS NULL) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;


    -- delete child record
	DELETE FROM pon_team_member_attr_scores
	WHERE       auction_header_id = p_auction_header_id
	AND         user_id = p_user_id
      AND         attribute_sequence_number IN
 		(SELECT 	paa.sequence_number
 		FROM 		pon_auction_attributes paa
 				,pon_auction_sections pas
 				,pon_scoring_team_sections psts
 			WHERE 	paa.auction_header_id = pas.auction_header_id
 			AND		paa.attr_group_seq_number = pas.attr_group_seq_number
 			AND		pas.auction_header_id = psts.auction_header_id
 			AND		pas.section_id = psts.section_id
 			AND 		psts.team_id = p_team_id);


	-- if no rows exist in the pon_team_member_attribute_scores
	-- for this user
	-- for a bid
	-- delete that bid and user from the pon_team_member_bid_scores
	DELETE FROM 	pon_team_member_bid_scores ptmbs
	WHERE			ptmbs.auction_header_id = p_auction_header_id
	AND			ptmbs.user_id = p_user_id
	AND	NOT EXISTS
		(SELECT 	'x'
	 	FROM 		pon_team_member_attr_scores ptmas
		WHERE		ptmas.auction_header_id = ptmbs.auction_header_id
		AND 		ptmas.user_id = ptmbs.user_id);

 x_return_status := fnd_api.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  IF fnd_msg_pub.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
	     fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name,SQLERRM);
	     IF ( fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
		   fnd_log.string(log_level => fnd_log.level_unexpected
     		  	        ,module   => g_pkg_name ||'.'||l_api_name
                          ,message  => l_stage || ': ' || SQLERRM);
	       fnd_log.string(log_level=>fnd_log.level_unexpected
                          ,module   =>g_pkg_name ||'.'||l_api_name
                          ,message  => 'Input parameter list: ' );
	       fnd_log.string(log_level=>fnd_log.level_unexpected
                          ,module   =>g_pkg_name ||'.'||l_api_name
                          ,message  => 'Auction Header Id :'||p_auction_header_id);
	       fnd_log.string(log_level=>fnd_log.level_unexpected
                          ,module   =>g_pkg_name ||'.'||l_api_name
                          ,message  => 'user_id'|| p_user_id );
	       fnd_log.string(log_level=>fnd_log.level_unexpected
                          ,module   =>g_pkg_name ||'.'||l_api_name
                          ,message  => 'p_api_version: '||p_api_version );
        END IF;
     END IF;
     FND_MSG_PUB.Count_and_Get(p_count => x_msg_count
                              ,p_data  => x_msg_data);
END;


--------------------------------------------------------------------------------
---            delete_team_scores                                             --
--------------------------------------------------------------------------------

PROCEDURE delete_team_scores(
          p_api_version              IN  NUMBER
	    ,p_auction_header_id       IN
 			pon_auction_headers_all.auction_header_id%TYPE
	    ,p_team_id                 IN pon_scoring_teams.team_id%TYPE
     	    ,x_return_status           OUT NOCOPY VARCHAR2
          ,x_msg_data                OUT NOCOPY VARCHAR2
          ,x_msg_count               OUT NOCOPY NUMBER
          )IS

l_api_name    CONSTANT VARCHAR2(30) := 'DELETE_TEAM_SCORES';
l_api_version CONSTANT NUMBER       := 1.0;
l_stage                VARCHAR2(50);



BEGIN

 -- Check for API comptability
 l_stage := '10: API check';

 IF  fnd_api.compatible_api_call(
        p_current_version_number => l_api_version
       ,p_caller_version_number  => p_api_version
       ,p_api_name               => l_api_name
       ,p_pkg_name               => g_pkg_name)
 THEN
    NULL;
 ELSE
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

 -- delete scores if input parameters are not null
 l_stage := '20: deletes begin here';

 IF (p_auction_header_id IS NULL) OR (p_team_id IS NULL) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

	-- delete child record
	DELETE FROM pon_team_member_attr_scores ptmas
	WHERE       ptmas.auction_header_id = p_auction_header_id
	AND         (user_id, attribute_sequence_number) IN
			(SELECT	pstm.user_id, paa.sequence_number
 			FROM 		pon_auction_attributes paa
 					,pon_auction_sections pas
		 			,pon_scoring_team_sections psts
            	            		,pon_scoring_team_members pstm
			WHERE 	paa.auction_header_id = pas.auction_header_id
		 	AND		paa.attr_group_seq_number = pas.attr_group_seq_number
			AND		paa.attribute_list_id = -1
			AND		paa.line_number = -1
		 	AND		pas.auction_header_id = psts.auction_header_id
		 	AND		pas.section_id = psts.section_id
		 	AND 		psts.team_id = p_team_id
                        AND             pstm.team_id = psts.team_id
			AND 		pstm.auction_header_id = psts.auction_header_id);



	-- if no rows exist in the pon_team_member_attribute_scores
	-- for the users of this team and
	-- for a bid
	-- delete that bid and user from the pon_team_member_bid_scores
	DELETE
	FROM 	pon_team_member_bid_scores ptmbs
	WHERE 	ptmbs.auction_header_id = p_auction_header_id
    	AND 	ptmbs.user_id IN
    		(
    		SELECT -- for all users of this team
        		user_id
    		FROM 	pon_scoring_team_members pstm
    		WHERE 	pstm.auction_header_id = ptmbs.auction_header_id
        	AND 	pstm.team_id = p_team_id
    		)
    	AND NOT EXISTS -- where there is no row for a bid in the child table
    		(
    		SELECT
        		'x'
    		FROM 	pon_team_member_attr_scores ptmas
    		WHERE 	ptmas.auction_header_id = ptmbs.auction_header_id
        	AND 	ptmas.bid_number = ptmbs.bid_number
        	AND 	ptmas.user_id = ptmbs.user_id
    		);

 x_return_status := fnd_api.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  IF fnd_msg_pub.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
	     fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name,SQLERRM);
	     IF ( fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
		   fnd_log.string(log_level => fnd_log.level_unexpected
     		  	        ,module   => g_pkg_name ||'.'||l_api_name
                          ,message  => l_stage || ': ' || SQLERRM);
	       fnd_log.string(log_level=>fnd_log.level_unexpected
                          ,module   =>g_pkg_name ||'.'||l_api_name
                          ,message  => 'Input parameter list: ' );
	       fnd_log.string(log_level=>fnd_log.level_unexpected
                          ,module   =>g_pkg_name ||'.'||l_api_name
                          ,message  => 'Auction Header Id :'||p_auction_header_id);
	       fnd_log.string(log_level=>fnd_log.level_unexpected
                          ,module   =>g_pkg_name ||'.'||l_api_name
                          ,message  => 'team_id'|| p_team_id );
	       fnd_log.string(log_level=>fnd_log.level_unexpected
                          ,module   =>g_pkg_name ||'.'||l_api_name
                          ,message  => 'p_api_version: '||p_api_version );
        END IF;
     END IF;
     FND_MSG_PUB.Count_and_Get(p_count => x_msg_count
                              ,p_data  => x_msg_data);
END;


--------------------------------------------------------------------------------
---            delete_subjective_scores                                       --
--------------------------------------------------------------------------------

PROCEDURE delete_subjective_scores(
          p_api_version              IN  NUMBER
	    ,p_auction_header_id       IN
 			pon_auction_headers_all.auction_header_id%TYPE
     	    ,x_return_status           OUT NOCOPY VARCHAR2
          ,x_msg_data                OUT NOCOPY VARCHAR2
          ,x_msg_count               OUT NOCOPY NUMBER
          )IS

l_api_name    CONSTANT VARCHAR2(30) := 'DELETE_SUBJECTIVE_SCORES';
l_api_version CONSTANT NUMBER       := 1.0;
l_stage                VARCHAR2(50);



BEGIN

 -- Check for API comptability
 l_stage := '10: API check';

 IF  fnd_api.compatible_api_call(
        p_current_version_number => l_api_version
       ,p_caller_version_number  => p_api_version
       ,p_api_name               => l_api_name
       ,p_pkg_name               => g_pkg_name)
 THEN
    NULL;
 ELSE
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

 -- delete scores if input parameters are not null
 l_stage := '20: deletes begin here';

 IF (p_auction_header_id IS NULL) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

        -- if scores exist for manually scored attributes
	-- update them to zero for this auction for all active bids
	-- so that teams can start scoring
	UPDATE 	pon_bid_attribute_values pbav
	SET	score = 0,
		weighted_score = 0
	WHERE   pbav.auction_header_id = p_auction_header_id
	AND	pbav.auction_line_number = -1
	AND     attribute_name IN
			(SELECT -- only header attributes that are scored manually
				paa.attribute_name
			FROM	pon_auction_attributes paa
			WHERE	paa.auction_header_id = pbav.auction_header_id
			AND	paa.line_number = -1
			AND	paa.attribute_list_id = -1
			AND 	paa.scoring_method = 'MANUAL')
	AND 	pbav.bid_number IN
			(SELECT --only active bids for this auction
				pbh.bid_number
			FROM	pon_bid_headers pbh
			WHERE	pbh.auction_header_id = pbav.auction_header_id
			AND	pbh.bid_status = 'ACTIVE');



 x_return_status := fnd_api.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  IF fnd_msg_pub.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
	     fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name,SQLERRM);
	     IF ( fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
		   fnd_log.string(log_level => fnd_log.level_unexpected
     		  	        ,module   => g_pkg_name ||'.'||l_api_name
                          ,message  => l_stage || ': ' || SQLERRM);
	       fnd_log.string(log_level=>fnd_log.level_unexpected
                          ,module   =>g_pkg_name ||'.'||l_api_name
                          ,message  => 'Input parameter list: ' );
	       fnd_log.string(log_level=>fnd_log.level_unexpected
                          ,module   =>g_pkg_name ||'.'||l_api_name
                          ,message  => 'Auction Header Id :'||p_auction_header_id);
	       fnd_log.string(log_level=>fnd_log.level_unexpected
                          ,module   =>g_pkg_name ||'.'||l_api_name
                          ,message  => 'p_api_version: '||p_api_version );
        END IF;
     END IF;
     FND_MSG_PUB.Count_and_Get(p_count => x_msg_count
                              ,p_data  => x_msg_data);
END;

--------------------------------------------------------------------------------
---            delete_section_assignment                                      --
--------------------------------------------------------------------------------

PROCEDURE delete_section_assignment(
          p_api_version              IN  NUMBER
	      ,p_auction_header_id       IN  pon_scoring_team_sections.auction_header_id%TYPE
          ,p_section_id              IN  pon_scoring_team_sections.section_id%TYPE
     	  ,x_return_status           OUT NOCOPY VARCHAR2
          ,x_msg_data                OUT NOCOPY VARCHAR2
          ,x_msg_count               OUT NOCOPY NUMBER
          )IS

l_api_name    CONSTANT VARCHAR2(30) := 'DELETE_SECTION_ASSIGNMENT';
l_api_version CONSTANT NUMBER       := 1.0;
l_stage                VARCHAR2(50);



BEGIN

 -- Check for API comptability
 l_stage := '10: API check';

 IF  fnd_api.compatible_api_call(
        p_current_version_number => l_api_version
       ,p_caller_version_number  => p_api_version
       ,p_api_name               => l_api_name
       ,p_pkg_name               => g_pkg_name)
 THEN
    NULL;
 ELSE
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

 -- delete scores if input parameters are not null
 l_stage := '20: delete begins here';

 IF (p_auction_header_id IS NULL) OR (p_section_id IS NULL) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

 -- delete the section assignment row
 DELETE FROM pon_scoring_team_sections
 WHERE 		 auction_header_id = p_auction_header_id
 AND		 section_id = p_section_id;


 x_return_status := fnd_api.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  IF fnd_msg_pub.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
	     fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name,SQLERRM);
	     IF ( fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
		   fnd_log.string(log_level => fnd_log.level_unexpected
     		  	        ,module   => g_pkg_name ||'.'||l_api_name
                          ,message  => l_stage || ': ' || SQLERRM);
	       fnd_log.string(log_level=>fnd_log.level_unexpected
                          ,module   =>g_pkg_name ||'.'||l_api_name
                          ,message  => 'Input parameter list: ' );
	       fnd_log.string(log_level=>fnd_log.level_unexpected
                          ,module   =>g_pkg_name ||'.'||l_api_name
                          ,message  => 'Auction Header Id :'||p_auction_header_id);
	       fnd_log.string(log_level=>fnd_log.level_unexpected
                          ,module   =>g_pkg_name ||'.'||l_api_name
                          ,message  => 'Section Id :'||p_section_id);
	       fnd_log.string(log_level=>fnd_log.level_unexpected
                          ,module   =>g_pkg_name ||'.'||l_api_name
                          ,message  => 'p_api_version: '||p_api_version );
        END IF;
     END IF;
     FND_MSG_PUB.Count_and_Get(p_count => x_msg_count
                              ,p_data  => x_msg_data);
END;


--------------------------------------------------------------------------------
---            unlock_scoring                                                 --
--------------------------------------------------------------------------------
PROCEDURE unlock_scoring(
          p_api_version              IN  NUMBER
	    ,p_auction_header_id       IN  pon_auction_headers_all.auction_header_id%TYPE
	    ,p_tpc_id                  IN pon_auction_headers_all.trading_partner_contact_id%TYPE
     	    ,x_return_status           OUT NOCOPY VARCHAR2
          ,x_msg_data                OUT NOCOPY VARCHAR2
          ,x_msg_count               OUT NOCOPY NUMBER
          ) IS


l_api_name    CONSTANT VARCHAR2(30) := 'UNLOCK_SCORING';
l_api_version CONSTANT NUMBER       := 1.0;
l_stage                VARCHAR2(50);



BEGIN

 -- Check for API comptability
 l_stage := '10: API check';

 IF  fnd_api.compatible_api_call(
        p_current_version_number => l_api_version
       ,p_caller_version_number  => p_api_version
       ,p_api_name               => l_api_name
       ,p_pkg_name               => g_pkg_name)
 THEN
    NULL;
 ELSE
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

 -- update auction header if input parameters are not null
 l_stage := '20: updates begin here';

 IF (p_auction_header_id IS NULL) OR (p_tpc_id IS NULL) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

  -- update auction header
  l_stage := '30: update auction header';

  UPDATE pon_auction_headers_all
  SET     scoring_lock_date = null
         ,scoring_lock_tp_contact_id = p_tpc_id
         ,last_update_date = SYSDATE
         ,last_updated_by = fnd_global.user_id
  WHERE  auction_header_id = p_auction_header_id
  AND    scoring_lock_date IS NOT NULL;

  IF SQL%NOTFOUND THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_stage := '35: update the pon bid attribute values table';

-- Wipe out the score data for all manually scored attributes if
-- scoring is unlocked

  UPDATE pon_bid_attribute_values
  SET      score           = NULL
         ,internal_note    = NULL
	 ,weighted_score   = NULL
	 ,last_update_date = SYSDATE
	 ,last_updated_by  = fnd_global.user_id
  WHERE  auction_header_id = p_auction_header_id
  AND    line_number       = -1
  AND    sequence_number IN
	 (SELECT paa.sequence_number
          FROM   pon_auction_attributes paa, pon_auction_headers_all paha, pon_auction_sections pas
          WHERE  paa.auction_header_id =  p_auction_header_id
          AND    paa.attribute_list_id = -1
          AND    paa.line_number       = -1
          AND    paa.scoring_method    = 'MANUAL'
          AND    NVL(paa.display_only_flag, 'N') = 'N'  -- display only attributes are not scored
          AND    paha.auction_header_id = paa.auction_header_id
          AND    pas.auction_header_id = paa.auction_header_id
          AND    pas.attr_group_seq_number = paa.attr_group_seq_number
          AND    pas.section_name = paa.section_name
          AND    (NVL(paha.two_part_flag,'N') = 'N' OR  -- Non 2 Stage negotiations
                  (paha.two_part_flag = 'Y' AND paha.sealed_auction_status = 'LOCKED') OR -- 2 Stage negotiations in technical phase
                  (paha.two_part_flag = 'Y' AND paha.sealed_auction_status <> 'LOCKED' AND pas.two_part_section_type = 'COMMERCIAL'))); --2 stage negotiations in commercial phase will clear only commercial scores

  l_stage := '40: update the pon bid headers table';

  UPDATE pon_bid_headers
  SET	 score_overriden_flag = NULL
         ,score_overriden_date = NULL
         ,score_override_tp_contact_id = NULL
	 ,last_update_date     = SYSDATE
	 ,last_updated_by      = fnd_global.user_id
  WHERE  auction_header_id = p_auction_header_id;

  x_return_status := fnd_api.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  IF fnd_msg_pub.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
	     fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name,SQLERRM);
	     IF ( fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
		   fnd_log.string(log_level => fnd_log.level_unexpected
     		  	        ,module   => g_pkg_name ||'.'||l_api_name
                          ,message  => l_stage || ': ' || SQLERRM);
	       fnd_log.string(log_level=>fnd_log.level_unexpected
                          ,module   =>g_pkg_name ||'.'||l_api_name
                          ,message  => 'Input parameter list: ' );
	       fnd_log.string(log_level=>fnd_log.level_unexpected
                          ,module   =>g_pkg_name ||'.'||l_api_name
                          ,message  => 'Auction Header Id :'||p_auction_header_id);
	       fnd_log.string(log_level=>fnd_log.level_unexpected
                          ,module   =>g_pkg_name ||'.'||l_api_name
                          ,message  => 'Trading Partner Contact Id'|| p_tpc_id );
	       fnd_log.string(log_level=>fnd_log.level_unexpected
                          ,module   =>g_pkg_name ||'.'||l_api_name
                          ,message  => 'p_api_version: '||p_api_version );
        END IF;
     END IF;
     FND_MSG_PUB.Count_and_Get(p_count => x_msg_count
                              ,p_data  => x_msg_data);

END;

END PON_TEAM_SCORING_UTIL_PVT;

/
