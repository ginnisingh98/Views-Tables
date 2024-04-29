--------------------------------------------------------
--  DDL for Package Body AR_CMGT_SCORING_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CMGT_SCORING_ENGINE" AS
 /* $Header: ARCMGSEB.pls 120.16.12010000.7 2010/03/25 03:00:30 mraymond ship $ */

pg_debug VARCHAR2(1) := ar_cmgt_util.get_wf_debug_flag;

PROCEDURE debug (
        p_message_name          IN      VARCHAR2 ) IS
BEGIN
    ar_cmgt_util.wf_debug ('SM',p_message_name);
END;

PROCEDURE   Calculate_score(
            p_score_model_id        IN      NUMBER,
            p_data_point_id         IN      NUMBER,
            p_data_point_value      IN      VARCHAR2,
            p_score                 OUT NOCOPY     NUMBER,
            p_error_msg             OUT NOCOPY     VARCHAR2,
            p_resultout             OUT NOCOPY     VARCHAR2 ) IS

 l_max_score         ar_cmgt_score_dtls.scores%TYPE;
 l_scores            ar_cmgt_score_dtls.scores%TYPE;
 l_weight            ar_cmgt_score_weights.weight%TYPE;
 l_data_point_type   VARCHAR2(255);
 l_data_point_value	 ar_cmgt_cf_dtls.data_point_value%type;
 l_date_format       VARCHAR2(255);
 NULL_ZERO_CONVR_IND VARCHAR2(1);
 BEGIN
 		IF pg_debug = 'Y'
        THEN
        	debug ( 'In calculate Score (+)');
        	debug ( 'Data Point Id : ' || p_data_point_id );
        	debug ( 'Data Point Value : ' || p_data_point_value );
        END IF;
        p_resultout := 0;

        BEGIN
            SELECT  max(scores)
            INTO    l_max_score
            FROM    ar_cmgt_score_dtls
            WHERE   score_model_id = p_score_model_id
            AND     data_point_id  = p_data_point_id;
--output.put_line('the max score is = ' || l_max_score);

 		IF pg_debug = 'Y'
        THEN
        	debug ( 'l_max_score : ' || l_max_score );
    END IF;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                p_resultout := 1;
                p_error_msg := 'Unable to get Max. Score for Data Point '||
                                p_data_point_id;
                return;
            WHEN OTHERS THEN
                p_resultout := 1;
                p_error_msg := 'Fatal Error while getting Max. Score '|| sqlerrm;
                return;

        END;
        IF pg_debug = 'Y'
        THEN
        	debug ( 'Max Score ' ||l_max_score );
        END IF;
        -- in case score model or data point id does not exist in
        -- score model details
        IF l_max_score = 0
        THEN
            p_score := 0;
            return;
        END IF;

        BEGIN
	    SELECT RETURN_DATA_TYPE,RETURN_DATE_FORMAT
            INTO   l_data_point_type,l_date_format
            FROM   AR_CMGT_SCORABLE_DATA_POINTS_V
            WHERE  DATA_POINT_ID = p_data_point_id;
	    --we don not need to check for scorable data points
	    --because the score model will contain only scorable
	    --data points.

 	IF pg_debug = 'Y'
        THEN
       	  debug ( 'l_data_point_type : ' || l_data_point_type );
          debug ( 'l_date_format : ' || l_date_format );
        END IF;

        EXCEPTION
        	WHEN NO_DATA_FOUND THEN

          	p_error_msg := 'No return type and date format defined for data point' ||
					 		'Data Point Id:' ||p_data_point_id ||' Data Point value: '||
                                             p_data_point_value;
	        IF pg_debug = 'Y'
    	    THEN
        		debug ( 'NO_DATA_FOUND --> ' ||p_error_msg );
        	END IF;
                p_resultout := 1;
                return;

        WHEN OTHERS THEN
				p_resultout := 1;
				p_error_msg := sqlerrm;

             IF pg_debug = 'Y' THEN
        	   debug ( 'OTHERS --> ' ||p_error_msg );
             END IF;
            	return;
        END;

        IF l_data_point_type = 'N'
        THEN
        	BEGIN
        		-- kjoshi Changes for score model enhancement
				--change for selecting 0 in case weight is null i.e. not assigned
				-- IF the user has choosen convert the null value to zero.
				IF p_data_point_value IS NULL
				THEN

				BEGIN

           			SELECT NULL_ZERO_FLAG
           			INTO NULL_ZERO_CONVR_IND
           			FROM AR_CMGT_SCORES
           			WHERE SCORE_MODEL_ID = p_score_model_id;

 		IF pg_debug = 'Y'
        THEN
        	debug ( 'NULL_ZERO_CONVR_IND : ' || NULL_ZERO_CONVR_IND );
        END IF;

				EXCEPTION
            	                       WHEN NO_DATA_FOUND THEN

            		                NULL_ZERO_CONVR_IND := 'N';

                               WHEN OTHERS THEN

		  			p_resultout := 1;
		  			p_error_msg := sqlerrm;
                  	                return;
                                END;

				--convert to zero if data point value is null

 		IF pg_debug = 'Y'
        THEN
        	debug ( 'NULL_ZERO_CONVR_IND ==> ' || NULL_ZERO_CONVR_IND );
        END IF;

		                    IF NULL_ZERO_CONVR_IND = 'Y'
		                     AND p_data_point_value IS NULL
           	                    THEN

               		                       l_data_point_value := 0;

               	                    ELSIF NULL_ZERO_CONVR_IND = 'N'
				    THEN

					       l_data_point_value := p_data_point_value;

           	                    END IF;
                            ELSE

                            l_data_point_value := p_data_point_value;

			     END IF;

 	IF pg_debug = 'Y'
        THEN
        	debug ( 'l_data_point_value : ' || l_data_point_value );
        END IF;

              SELECT score.scores, NVL(weight.weight,0)
              INTO   l_scores, l_weight
              FROM   ar_cmgt_score_dtls score,
                     AR_CMGT_SCORE_WEIGHTS weight
              WHERE  score.score_model_id = p_score_model_id
              AND    score.data_point_id = p_data_point_id
              AND    score.score_model_id = weight.score_model_id
              AND    score.data_point_id = weight.data_point_id
              AND    to_number(l_data_point_value) between
                  score.range_from and score.range_to;

 	IF pg_debug = 'Y'
        THEN
            debug ( 'l_scores : ' || l_scores );
            debug ( 'l_weight : ' || l_weight );
        END IF;

            	--kjoshi Score model enhancement
 		--changes to evaluate diect score in the case where weights are not assigned.
                IF l_weight = 0
                THEN
                    p_score := l_scores;
                END IF;

				IF l_weight <> 0
                THEN
                    p_score := round(((l_scores/l_max_score) *(l_weight)),2);
                END IF;


            	IF pg_debug = 'Y'
            	THEN
                	debug ( 'Number Value Score '||p_score );
            	END IF;

	        --output.put_line('score calculated  = ' ||p_score);
        	EXCEPTION
            	WHEN NO_DATA_FOUND THEN
            		p_error_msg := 'Number Data Point values are out of Score Range' ||
						'Data Point Id:' ||p_data_point_id ||' Data Point value: '|| l_data_point_value;
                  	p_score := null;
                  	p_resultout := 1;
 		IF pg_debug = 'Y'
                THEN
                   debug ('l_data_point_type ==> ' || l_data_point_type);
       	           debug ( 'NO_DATA_FOUND ==> ' ||p_error_msg );
                END IF;

                WHEN OTHERS THEN
		   p_resultout := 1;
		   p_error_msg := sqlerrm;
 		IF pg_debug = 'Y'
                THEN
                  debug ('l_data_point_type ==> ' || l_data_point_type);
        	  debug ( 'OTHERS ==> ' ||p_error_msg );
                END IF;

                  	return;
            END;
		ELSIF  l_data_point_type = 'D'
		THEN
            BEGIN

              SELECT score.scores, NVL(weight.weight,0)
                INTO   l_scores, l_weight
                FROM   ar_cmgt_score_dtls score,
                       AR_CMGT_SCORE_WEIGHTS weight
              WHERE  score.score_model_id = p_score_model_id
              AND    score.data_point_id = p_data_point_id
              AND    score.score_model_id = weight.score_model_id
              AND    score.data_point_id = weight.data_point_id
              AND    to_date(p_data_point_value,l_date_format) between
                     to_date(score.range_from,l_date_format) AND
                     to_date(score.range_to,l_date_format);

 		IF pg_debug = 'Y'
        THEN
        	debug ( 'l_scores : ' || l_scores );
            debug ( 'l_weight : ' || l_weight );
        END IF;

				IF l_weight = 0
                THEN
                	p_score := l_scores;
                END IF;
                IF l_weight <> 0
                THEN
                	p_score := round(((l_scores/l_max_score) *(l_weight)),2);
                END IF;
                IF pg_debug = 'Y'
        		THEN
        			debug ( 'date Value Score '||p_score );
        		END IF;
            EXCEPTION
            	WHEN NO_DATA_FOUND THEN
                		p_error_msg := 'Date Data Point values are out of Score Range' ||
								   'Data Point Id:' ||p_data_point_id ||' Data Point value: '||
								    p_data_point_value;
                		p_score := null;
                		p_resultout := 1;

 		IF pg_debug = 'Y'
        THEN
            debug ('l_data_point_type ==> ' || l_data_point_type);
        	debug ( 'NO_DATA_FOUND ==> ' ||p_error_msg );
        END IF;
                 WHEN OTHERS THEN
						p_resultout := 1;
				 		p_error_msg := sqlerrm;

 		IF pg_debug = 'Y'
        THEN
            debug ('l_data_point_type ==> ' || l_data_point_type);
        	debug ( 'OTHERS ==> ' ||p_error_msg );
        END IF;
                    	return;
            END;
		ELSIF l_data_point_type = 'C'
        THEN
        	BEGIN

              SELECT score.scores, NVL(weight.weight,0)
              INTO   l_scores, l_weight
              FROM   ar_cmgt_score_dtls score,
                     AR_CMGT_SCORE_WEIGHTS weight
              WHERE  score.score_model_id = p_score_model_id
              AND    score.data_point_id = p_data_point_id
              AND    score.score_model_id = weight.score_model_id
              AND    score.data_point_id = weight.data_point_id
              AND    p_data_point_value between score.range_from and score.range_to;

 		IF pg_debug = 'Y'
        THEN
        	debug ( 'l_scores : ' || l_scores );
          debug ( 'l_weight : ' || l_weight );
    END IF;

               IF l_weight = 0
               THEN
                   p_score := l_scores;
               END IF;
               IF l_weight <> 0
               THEN
                   p_score := round(((l_scores/l_max_score) *(l_weight)),2);
               END IF;
			   IF pg_debug = 'Y'
			   THEN
	        		debug ( 'Char Value Score '||p_score );
        	   END IF;
            EXCEPTION
            	WHEN NO_DATA_FOUND THEN
                  p_error_msg := 'Char Data Point values are out of Score Range' ||
					'Data Point Id:' ||p_data_point_id ||' Data Point value: '|| p_data_point_value;
                  p_resultout := 1;
                  p_score := null;
 		IF pg_debug = 'Y'
        THEN
            debug ('l_data_point_type ==> ' || l_data_point_type);
        	debug ( 'NO_DATA_FOUND ==> ' ||p_error_msg );
        END IF;
                WHEN OTHERS THEN
		  			p_resultout := 1;
		  			p_error_msg := sqlerrm;

 		IF pg_debug = 'Y'
        THEN
            debug ('l_data_point_type ==> ' || l_data_point_type);
        	debug ( 'OTHERS ==> ' ||p_error_msg );
        END IF;

                  	return;
            END;
		END IF;

		--p_score := round(((l_scores/l_max_score) *(l_weight)),2);
		IF pg_debug = 'Y'
        THEN
      	    debug ( 'In calculate Score (-)');
        END IF;
END;

-- this is a wrapper for calculatescore. This function is getting called
-- from sql query to calculate score for individual data points.
FUNCTION    get_score (
            p_score_model_id        IN      NUMBER,
            p_data_point_id         IN      NUMBER,
            p_case_folder_id        IN      NUMBER,
            p_data_point_value      IN      VARCHAR2)
        return NUMBER IS
l_error_msg             VARCHAR2(2000);
l_resultout             VARCHAR2(1);
l_score                 NUMBER;
l_result                VARCHAR2(1);
l_updt_flag             VARCHAR2(1);
l_category              VARCHAR2(20);
l_chk_list              VARCHAR2(1);
l_function_name         VARCHAR2(60);
l_skip_currency_flag    VARCHAR2(1); -- For Bug 8627463

BEGIN
      --this flag is for checking if the score calculated is for
      --additional data point.
      l_updt_flag :='Y';
    IF pg_debug = 'Y'
    THEN
       	debug ( 'In get Score (+)');
    END IF;

    BEGIN

        -- If the Skip Currency Flag is set at the Scoring model, the case
        -- folder limit currency and scoring model currency need not be same
        -- So, we include the currency equality check only if the flag is not
        -- set (Bug 8627463) -- Start
        SELECT NVL(SKIP_CURRENCY_TEST_FLAG, 'N')
        INTO l_skip_currency_flag
        FROM AR_CMGT_SCORES
        WHERE SCORE_MODEL_ID = p_score_model_id;

        IF (l_skip_currency_flag = 'N') THEN
          SELECT 'X'
          INTO   l_result
          FROM ar_cmgt_scores score, ar_cmgt_case_folders case1
          WHERE  case1.case_folder_id = p_case_folder_id
          AND    score.score_model_id = p_score_model_id
          AND    case1.limit_currency = score.currency
          AND    trunc(sysdate) between trunc(score.start_date) and
                   nvl(trunc(score.end_date), trunc(sysdate));

          IF pg_debug = 'Y' THEN
            debug ( 'l_result  '||l_result );
          END IF;
        ELSE
          SELECT 'X'
          INTO   l_result
          FROM ar_cmgt_scores score, ar_cmgt_case_folders case1
          WHERE  case1.case_folder_id = p_case_folder_id
          AND    score.score_model_id = p_score_model_id
          AND    trunc(sysdate) between trunc(score.start_date) and
                   nvl(trunc(score.end_date), trunc(sysdate));
        END IF;
        -- Bug 8627463 -- End

    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            return NULL;
        WHEN TOO_MANY_ROWS
        THEN
            NULL;
        WHEN OTHERS THEN
             return NULL;
    END;

        Calculate_score(
            p_score_model_id        => p_score_model_id,
            p_data_point_id         => p_data_point_id,
            p_data_point_value      => p_data_point_value,
            p_score                 => l_score,
            p_error_msg             => l_error_msg,
            p_resultout             => l_resultout);

      /* 9342120 - Added function_name directly to view */
      SELECT v.data_point_category, v.function_name
      INTO   l_category, l_function_name
      FROM   ar_cmgt_scorable_data_points_v v
      WHERE  v.data_point_id = p_data_point_id;

            BEGIN

	         SELECT INCLUDED_IN_CHECKLIST
	         INTO l_chk_list
	         FROM AR_CMGT_CF_DTLS
	         WHERE CASE_FOLDER_ID=p_case_folder_id
	         AND DATA_POINT_ID=p_data_point_id;
            EXCEPTION

                    WHEN TOO_MANY_ROWS
                    THEN
                    return NULL;
            END;

            	IF pg_debug = 'Y'
            	THEN
                	debug ( 'l_category  '||l_category );
                  debug ( 'l_chk_list  '||l_chk_list );
                  debug ( 'l_score  '||l_score );
            	END IF;

	    IF l_category ='ADDITIONAL'
	    AND l_chk_list ='Y'
            AND l_function_name IS NULL
	    THEN
                l_updt_flag :='N';
            END IF;


	    --only update the other data points
	    --i.e. 'ADDITIONAL' data points are
	    --not updated from PLSQL.

	    if l_updt_flag ='Y' THEN

            Update ar_cmgt_cf_dtls
             set data_point_value = p_data_point_value,
                 score = l_score
	    WHERE data_point_id = p_data_point_id
            AND   case_folder_id = p_case_folder_id;

           end if;

            return l_score;
            /* IF l_score IS NULL
            THEN
                return l_score;
            ELSE
                return l_score;
            END IF; */
	IF pg_debug = 'Y'
    THEN
       	debug ( 'In get Score (-)');
    END IF;
END;



 PROCEDURE get_dnb_data_point_value(
            p_case_folder_id        IN   NUMBER,
            p_data_point_id         IN   NUMBER,
            p_data_point_value      OUT NOCOPY  VARCHAR2) IS

    l_source_table_name         ar_cmgt_dnb_elements_vl.source_table_name%type;
    l_source_column_name        ar_cmgt_dnb_elements_vl.source_column_name%type;
    l_source_key                ar_cmgt_cf_dnb_dtls.source_key%type;
    l_source_key_type           ar_cmgt_cf_dnb_dtls.source_key_type%type;
    l_source_key_column_name    ar_cmgt_cf_dnb_dtls.source_key_column_name%type;
    l_source_key_column_type    ar_cmgt_cf_dnb_dtls.source_key_column_type_name%type;

    TYPE cur_type               IS REF CURSOR;
    c                           cur_type;

    queryStr                    VARCHAR2(2000);
BEGIN
    SELECT  source_table_name, source_column_name
    INTO    l_source_table_name, l_source_column_name
    FROM    ar_cmgt_dnb_elements_vl
    WHERE   data_element_id = p_data_point_id;

    SELECT  cfd.source_key, cfd.source_key_type, cfd.source_key_column_name,
            cfd.source_key_column_type_name
    INTO    l_source_key, l_source_key_type, l_source_key_column_name,
            l_source_key_column_type
    FROM    ar_cmgt_cf_dnb_dtls cfd
    WHERE   cfd.case_folder_id = p_case_folder_id
    AND     cfd.source_table_name = l_source_table_name;

    IF l_source_key_type IS NULL
    THEN
    --bug#5072562 changes start**************************************
    --SQL ID  16039932
        queryStr := 'SELECT '|| ':l_source_column_name' ||
                 ' FROM '|| ':l_source_table_name' ||
                 ' WHERE '|| ':l_source_key_column_name' || ' = :l_source_key';

        OPEN c FOR queryStr USING  l_source_column_name,l_source_table_name,l_source_key_column_name
	,l_source_key;
    --bug#5072562 changes end****************************************
	LOOP
            FETCH c INTO p_data_point_value;
            EXIT WHEN c%NOTFOUND;
        END LOOP;
        CLOSE c;
    ELSE
    --bug#5072562 changes start**************************************
    --SQL ID  16039933
        queryStr := 'SELECT '||':l_source_column_name' ||
                 ' FROM '|| ':l_source_table_name' ||
                 ' WHERE '|| ':l_source_key_column_name' || ' =  :l_source_key '||
                 ' AND ' || ':l_source_key_column_type' ||' = || :l_source_key_type';

        OPEN c FOR queryStr USING l_source_column_name,l_source_table_name, l_source_key_column_name,
	l_source_key_column_type,l_source_key, l_source_key_type;
    --bug#5072562 changes end****************************************

        LOOP
            FETCH c INTO p_data_point_value;
            EXIT WHEN c%NOTFOUND;
        END LOOP;
        CLOSE c;
    END IF;
EXCEPTION
  WHEN no_data_found  THEN
    null;
  WHEN others  THEN
    raise;
END;

PROCEDURE GET_TOTAL_SCORE(
            p_case_folder_id    IN      NUMBER,
            p_score_model_id    IN      NUMBER,
            p_data_point_id     IN      NUMBER,
            p_score             OUT NOCOPY     NUMBER,
            p_error_msg         OUT NOCOPY     VARCHAR2,
            p_resultout         OUT NOCOPY     VARCHAR2) IS

 l_data_point_value  ar_cmgt_cf_dtls.data_point_value%TYPE;
 l_data_point_id     ar_cmgt_data_points_vl.data_point_id%TYPE;
 l_score_model_id    ar_cmgt_scores.score_model_id%TYPE;
 l_total_score       NUMBER := 0;
 l_score             NUMBER := 0;
 l_updt_flg        VARCHAR2(1);
 l_category        VARCHAR2(20);
 l_function_name   VARCHAR2(60);
 BEGIN
        l_updt_flg:='Y';

        /* 9342120 - Added function_name to view */
        SELECT v.data_point_category, v.function_name
	INTO l_category, l_function_name
	FROM ar_cmgt_scorable_data_points_v v
	where v.data_point_id = p_data_point_id;

    IF l_category='ADDITIONAL'
    AND l_function_name IS NULL
    THEN
	    l_updt_flg :='N';
    END IF;

    IF pg_debug = 'Y'
    THEN
       	debug ( 'GET_TOTAL_SCORE (+)');
    END IF;

    p_resultout := 0;
    p_score := 0;
    -- first get the data point id for Data records
    IF g_data_case_folder_id IS NULL
    THEN
        BEGIN
            SELECT data1.case_folder_id
            INTO  g_data_case_folder_id
            FROM  ar_cmgt_case_folders data1, ar_cmgt_case_folders case1
            WHERE data1.type = 'DATA'
            and    case1.case_folder_id = p_case_folder_id
            and    case1.party_id = data1.party_id
            and    case1.cust_account_id = data1.cust_account_id
            and    case1.site_use_id   = data1.site_use_id;

            	IF pg_debug = 'Y'
            	THEN
                	debug ( 'g_data_case_folder_id  '||g_data_case_folder_id );
            	END IF;

            -- update score for the data records to null.  This is required
            -- in because Scoreing model could be different for different
            -- case folders for the same party account and site combination.
            -- But the data records will be the same for the same combination.
            -- So it would be idle to update score to null.
            UPDATE  ar_cmgt_cf_dtls
            SET     score = null,
                    last_updated_by = fnd_global.user_id,                    last_update_date = sysdate,
                    last_update_login = fnd_global.login_id
            WHERE   case_folder_id = g_data_case_folder_id;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                g_data_case_folder_id := -99;
            WHEN OTHERS THEN
                g_data_case_folder_id := -99;
        END;
    END IF;
    /*IF p_data_point_id < 20000 -- all data points including DNB
    THEN */
            BEGIN
                /* 9342120 - using scorable_data_points_v to
                   accomodate DNB datapoints */
                SELECT cfd.data_point_value
                INTO   l_data_point_value
                FROM   ar_cmgt_scorable_data_points_v sdp,
                       ar_cmgt_cf_dtls cfd
                WHERE  cfd.case_folder_id = p_case_folder_id
                AND    sdp.data_point_id = cfd.data_point_id (+)
                AND    sdp.data_point_id = p_data_point_id;

            	IF pg_debug = 'Y'
            	THEN
                	debug ( 'l_data_point_value  '||l_data_point_value );
            	END IF;

            EXCEPTION
                WHEN OTHERS THEN
                    p_resultout := 1;
                    p_error_msg := 'Fatal Error While getting data point value '||
                                    p_data_point_id;
            	IF pg_debug = 'Y'
            	THEN
                	debug ( p_error_msg );
            	END IF;

                    return;
            END;

            -- calling
            Calculate_score(
                    p_score_model_id    => p_score_model_id,
                    p_data_point_id     => p_data_point_id,
                    p_data_point_value  => l_data_point_value,
                    p_score             => l_score,
                    p_error_msg         => p_error_msg,
                    p_resultout         => p_resultout );

            	IF pg_debug = 'Y'
            	THEN
                	debug ( 'l_score  '||l_score );
                  debug ( 'p_resultout  '||p_resultout );
            	END IF;

            IF p_resultout = 0
            THEN

 /*Changes Start----------------------------------------------------------------
   bug#5007954
   This code is chanded to update only in case the data point category is not
   ADDITIONAL.*/
                IF l_updt_flg ='Y'
		THEN
                AR_CMGT_CONTROLS.UPDATE_CASE_FOLDER_DETAILS
                        (   p_case_folder_id    => p_case_folder_id,
                            p_data_point_id     => p_data_point_id,
                            p_data_point_value  => l_data_point_value,
                            p_score             => l_score,
                            p_errmsg            => p_error_msg,
                            p_resultout         => p_resultout);
                END IF;

/* Changes end------------------------------------------------------------------
 * bug#5007954
 */
                -- update data records too
                IF g_data_case_folder_id IS NOT NULL AND
                   g_data_case_folder_id <> -99
                THEN
                    AR_CMGT_CONTROLS.UPDATE_CASE_FOLDER_DETAILS
                        (   p_case_folder_id    => g_data_case_folder_id,
                            p_data_point_id     => p_data_point_id,
                            p_data_point_value  => l_data_point_value,
                            p_score             => l_score,
                            p_errmsg            => p_error_msg,
                            p_resultout         => p_resultout);
               END IF;
               p_score :=  p_score + l_score;

            	IF pg_debug = 'Y'
            	THEN
                	debug ( 'p_score  '||p_score );
            	END IF;
            ELSE
               p_score := null;
               return;
            END IF;

	IF pg_debug = 'Y'
    THEN
       	debug ( 'GET_TOTAL_SCORE (-)');
    END IF;
END;

/**********************************************************************
** Scoring Formula
** 1. Find out he Score for the value range
** 2. Get the largest possible for that datapoints
** 3. Divide the score with the largest score
** 4. Repeat above steps for each data points
** 5. Add all results of step 3 and multiply by 100.
**********************************************************************/
PROCEDURE GENERATE_SCORE(
            p_case_folder_id    IN      NUMBER,
            p_score             OUT NOCOPY     NUMBER,
            p_error_msg         OUT NOCOPY     VARCHAR2,
            p_resultout         OUT NOCOPY     VARCHAR2) IS


 CURSOR cScoreDataPoint IS
        SELECT distinct score.data_point_id, score.score_model_id
        FROM   ar_cmgt_score_dtls score,
               ar_cmgt_case_folders case1
        WHERE  case_folder_id = p_case_folder_id
        AND    case1.score_model_id = score.score_model_id;
 l_total_score          NUMBER := 0;

 BEGIN
 	IF pg_debug = 'Y'
    THEN
       	debug ( 'GENERATE_SCORE Ist (+)');
    END IF;
    p_resultout := 0;
    p_score := 0;
    -- update score for the case records to null.  This is required
    -- because Scoreing model can be changed by credit analyst during
    -- analysis. In case credit analyst change the scoring model
    -- then the old score need to be updated with the new value.
    -- Also the number of data points could vary from scoring model to
    -- scoring model.
    UPDATE  ar_cmgt_cf_dtls
    SET     score = null,
            last_updated_by = fnd_global.user_id,
            last_update_date = sysdate,
            last_update_login = fnd_global.login_id
    WHERE   case_folder_id = p_case_folder_id;

    FOR cScoreDataPoint_rec IN cScoreDataPoint
    LOOP

        get_total_score(
            p_case_folder_id   => p_case_folder_id,
            p_score_model_id   => cScoreDataPoint_rec.score_model_id,
            p_data_point_id    => cScoreDataPoint_rec.data_point_id,
            p_score            => p_score,
            p_error_msg        => p_error_msg,
            p_resultout        => p_resultout);

         IF pg_debug = 'Y'
    	 THEN
       		debug ( 'Data Point id '|| cScoreDataPoint_rec.data_point_id);
       		debug ( 'Score '|| p_score);
    	 END IF;
         IF  p_resultout <> 0
         THEN
            p_score := null;
            return;
         END IF;

         l_total_score := l_total_score + nvl(p_score,0);
         IF pg_debug = 'Y'
    	 THEN
       		debug ( ' Total Score '|| l_total_score);
    	 END IF;

     END LOOP;
     p_score := round(l_total_score,0);
     IF pg_debug = 'Y'
     THEN
    	debug ( ' Total Score '|| l_total_score);
       	debug ( 'GENERATE_SCORE Ist (-)');
     END IF;
END;
/* This procedure is overloaded with Generate_score
   At this moment this procedure is called from Case folder UI
   in case CA wants to change the scoring model and generate the
   new score for the case folder*/

PROCEDURE GENERATE_SCORE(
            p_case_folder_id    IN      NUMBER,
            p_score_model_id    IN      NUMBER,
            p_score             OUT NOCOPY     NUMBER,
            p_error_msg         OUT NOCOPY     VARCHAR2,
            p_resultout         OUT NOCOPY     VARCHAR2) IS

CURSOR cScoreDataPoint IS
        SELECT distinct score.data_point_id, score.score_model_id
        FROM   ar_cmgt_score_dtls score
        WHERE  score_model_id = p_score_model_id;

l_total_score          NUMBER := 0;
l_result               VARCHAR2(1);
l_skip_currency_flag   VARCHAR2(1);  -- For Bug 8627463
 BEGIN
 	IF pg_debug = 'Y'    THEN
       	debug ( 'GENERATE_SCORE 2nd (+)');
       	debug ( 'case Folder ID : ' || p_case_folder_id);
       	debug ( 'score model id : ' || p_score_model_id);
    END IF;

    p_resultout := 0;
    p_score := 0;
    --first check whether scoring currency and case folder
    -- currency is same or not. In case it is different then
    -- raise an error. Bug 3624543
    BEGIN

        -- If the Skip Currency Flag is set at the Scoring model, the case
        -- folder limit currency and scoring model currency need not be same
        -- So, we include the currency equality check only if the flag is not
        -- set (Bug 8627463) -- Start
        SELECT NVL(SKIP_CURRENCY_TEST_FLAG, 'N')
        INTO l_skip_currency_flag
        FROM AR_CMGT_SCORES
        WHERE SCORE_MODEL_ID = p_score_model_id;

        IF ( l_skip_currency_flag = 'N') THEN
          SELECT 'X'
          INTO   l_result
          FROM ar_cmgt_scores score, ar_cmgt_case_folders case1
          WHERE  case1.case_folder_id = p_case_folder_id
          AND    score.score_model_id = p_score_model_id
          AND    case1.limit_currency = score.currency
          AND    trunc(sysdate) between trunc(score.start_date) and
                   nvl(trunc(score.end_date), trunc(sysdate));
        ELSE
          SELECT 'X'
          INTO   l_result
          FROM ar_cmgt_scores score, ar_cmgt_case_folders case1
          WHERE  case1.case_folder_id = p_case_folder_id
          AND    score.score_model_id = p_score_model_id
          AND    trunc(sysdate) between trunc(score.start_date) and
                   nvl(trunc(score.end_date), trunc(sysdate));
        END IF;
        -- (Bug 8627463) -- End


    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            p_resultout := 1;
            return;
        WHEN TOO_MANY_ROWS
        THEN
            NULL;
        WHEN OTHERS THEN
             p_resultout := 1;
             return;
    END;
    -- update score for the case records to null.  This is required
    -- because Scoreing model can be changed by credit analyst during
    -- analysis. In case credit analyst change the scoring model
    -- then the old score need to be updated with the new value.
    -- Also the number of data points could vary from scoring model to
    -- scoring model.
   /*Changes Start----------------------------------------------------------------
    * bug#5007954
    UPDATE  ar_cmgt_cf_dtls
    SET     score = null,
            last_updated_by = fnd_global.user_id,
            last_update_date = sysdate,
            last_update_login = fnd_global.login_id
    WHERE   case_folder_id = p_case_folder_id;
   * Changes end------------------------------------------------------------------
   * bug#5007954
   */
 -- update the scoring model Id in case folder table
    /* UPDATE ar_cmgt_case_folders
      set score_model_id = p_score_model_id,
          last_updated = SYSDATE,
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id
    WHERE case_folder_id = p_case_folder_id;  */

    FOR cScoreDataPoint_rec IN cScoreDataPoint
    LOOP
        get_total_score(
            p_case_folder_id   => p_case_folder_id,
            p_score_model_id   => cScoreDataPoint_rec.score_model_id,
            p_data_point_id    => cScoreDataPoint_rec.data_point_id,
            p_score            => p_score,
            p_error_msg        => p_error_msg,
            p_resultout        => p_resultout);

            IF pg_debug = 'Y'
    		THEN
       			debug ( 'Data Point id '|| cScoreDataPoint_rec.data_point_id);
       			debug ( 'Score '|| p_score);
    		END IF;
            IF  p_resultout <> 0
            THEN
                p_score := null;
                return;
            END IF;
            l_total_score := l_total_score + nvl(p_score,0);

     END LOOP;
     p_score := round(l_total_score,0);
     IF pg_debug = 'Y'
    THEN
       	debug ( 'Total score : ' || p_score);
       	debug ( 'GENERATE_SCORE 2nd (-)');
    END IF;
END;

END AR_CMGT_SCORING_ENGINE;

/
