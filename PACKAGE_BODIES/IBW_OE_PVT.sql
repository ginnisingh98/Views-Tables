--------------------------------------------------------
--  DDL for Package Body IBW_OE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBW_OE_PVT" AS
/* $Header: IBWOEB.pls 120.115 2008/06/20 09:48:14 saradhak ship $ */



--========================================================================
-- PROCEDURE : offline_engine	 PUBLIC
-- PARAMETERS: errbuf		       Error Buffer for Concurrent Program asset value
--           : retcode		     Return Code for Concurrent Program
-- COMMENT   : Main Fact Population Program which migrates Data FROM Page Access Tracking
--             to Web Analytics schema
--========================================================================


PROCEDURE offline_engine(
 errbuf OUT NOCOPY VARCHAR2,
 retcode OUT NOCOPY NUMBER
) AS
l_guest_user_pwd VARCHAR2(30);
l_guest_table_count PLS_INTEGER;
l_guest_username VARCHAR2(30);
error_messages VARCHAR2(240);
l_guest_party_id PLS_INTEGER;
l_guest_user_id PLS_INTEGER;
l_guest_person_id PLS_INTEGER;
l_visit_count PLS_INTEGER;
l_page_view_count PLS_INTEGER;

l_cart_code VARCHAR2(250);
l_xchkout_code VARCHAR2(250);
l_order_code VARCHAR2(250);
l_ordinq_code VARCHAR2(250);
l_invinq_code VARCHAR2(250);
l_payinq_code VARCHAR2(250);
l_userreg_code VARCHAR2(250);
l_optout_code VARCHAR2(250);


l_start_time date;
l_pat_date date;
--l_pat_3_date date;
--l_pat_4_date date;
l_pat_count PLS_INTEGER;
l_pat_3_count PLS_INTEGER;
l_pat_4_count PLS_INTEGER;
l_rec_count PLS_INTEGER;
l_page_id IBW_PAGES_B.PAGE_ID%TYPE;
l_page_name IBW_PAGES_TL.PAGE_NAME%TYPE;
l_ref_catg_id IBW_REFERRAL_CATEGORIES_B.REFERRAL_CATEGORY_ID%TYPE;
l_page_instance_id IBW_PAGE_INSTANCES.PAGE_INSTANCE_ID%TYPE;
l_return NUMBER(30);
l_message_text  FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
TEMP_CREATE_ERR EXCEPTION;

l_error_message VARCHAR2(240);
l_index_tablespace VARCHAR2(250);

x_ref_id   NUMBER(30);
l_ref_url IBW_PAGE_VIEWS.REFERRAL_URL%TYPE;
l_ref_name ibw_referral_categories_tl.REFERRAL_CATEGORY_NAME%TYPE;



CURSOR pat_cursor IS
SELECT   MAX (pat.last_update_date) AS patdate, pat.track_purpose
FROM jtf_pf_wa_info_vl pat
GROUP BY pat.track_purpose;


CURSOR tmp_page_views_instances IS
SELECT DISTINCT page_id, business_context, business_context_value
FROM ibw_page_views_tmp tmp
WHERE page_instance_id = -1
AND process_flag is null
AND page_id <> -1
AND not exists ( SELECT page_instance_id
             FROM ibw_page_instances
             WHERE page_id  =  tmp.page_id
             AND business_context=tmp.business_context
             AND business_context_value = NVL(tmp.business_context_value,'-999'));


CURSOR tmp_page_views_cache(flag number) IS
SELECT rec_id, page_id, page_view_seq_num, site_id, visit_id, evnt_type,
       evnt_id, tracked_page_code, tracked_page_name, tracked_page_url,
       tracked_application_context, business_context, business_context_value,
       search_phrase,search_result_size,EXACT_RESULT_SIZE_FLAG,referral_url
FROM ibw_page_views_tmp
 WHERE process_flag = flag;


CURSOR page_views_new_referral_cat IS
SELECT distinct referral_url
FROM ibw_page_views_tmp
WHERE page_view_seq_num = 1
AND process_flag is null
AND referral_URL is not null
AND length(referral_URL) <> 0
AND not exists
 (SELECT patterns.type_id
    FROM ibw_url_patterns_b patterns
    WHERE patterns.TYPE = 'R'
    AND UPPER(referral_url) LIKE
        UPPER(REPLACE (patterns.url_pattern, '*', '%') || '%' ));

CURSOR inactive_pages is
SELECT pages.page_id as page_id
FROM ibw_pages_b pages
WHERE pages.page_status = 'N'
AND exists (SELECT tmp.page_id
            FROM ibw_page_views_tmp tmp
            WHERE tmp.page_id = pages.page_id);



BEGIN

retcode := 0;

   printLog('Starting Fact Population Concurrent Program');

-- Variable Initialization
l_cart_code := 'CART';
l_xchkout_code := 'XCHKOUT';
l_order_code := 'ORDER';
l_ordinq_code := 'ORDINQ';
l_invinq_code := 'INVINQ';
l_payinq_code := 'PMTINQ';
l_userreg_code := 'USRREG';
l_optout_code := 'OPTOUT';


--Bug 6727218
 -- get guest party AND user ids
printLog('Getting Guest user name/Password');
--FND_PROFILE.GET ('GUEST_USER_PWD', l_guest_user_pwd);
l_guest_user_pwd:=FND_WEB_SEC.get_guest_username_pwd;

-- Get the user name out from the profile value which is in the format USERNAME/PASSWORD
l_guest_username := substr(l_guest_user_pwd,1,instr(l_guest_user_pwd,'/',1,1)-1);

SELECT customer_id,person_party_id,user_id
INTO l_guest_party_id,l_guest_person_id,l_guest_user_id
FROM fnd_user
WHERE user_name LIKE l_guest_username;

l_start_time :=  sysdate;

-- Insert record into ibw_guest_party table

printLog('Populating ibw_guest_party_table');
SELECT COUNT(PERSON_PARTY_ID)       --Changed by Venky
INTO l_guest_table_count
FROM ibw_guest_party
WHERE rownum < 2;

IF l_guest_table_count = 0
THEN
  INSERT INTO ibw_guest_party(CUSTOMER_ID
                              ,OBJECT_VERSION_NUMBER
			      ,PERSON_PARTY_ID
			      ,CREATED_BY
			      ,CREATION_DATE
			      ,LAST_updateD_BY
			      ,LAST_update_DATE
			      ,LAST_update_LOGIN)
  VALUES(l_guest_party_id
         ,1
	 ,l_guest_person_id
	 ,fnd_global.user_id
	 ,SYSDATE
	 ,fnd_global.user_id
	 ,SYSDATE,fnd_profile.VALUE('LOGIN_ID'));

ELSE
	UPDATE ibw_guest_party
	SET customer_id =  l_guest_party_id
	  , person_party_id = l_guest_person_id;
END IF;

-- get Last migrated date FROM pat table.
printLog('Get last pat update date');

--Changes after code review to hold earliest possible date by default

BEGIN              --Changed by Venky. Added code to handle no_data found

  l_pat_date  := TO_DATE('01/01/1970','MM/DD/YYYY');

  SELECT last_record_migrated_time
  INTO l_pat_date
  FROM JTF_PF_PURGEABLE
  WHERE track_purpose in (2,3,4)
  AND ROWNUM = 1;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	 l_pat_date  := TO_DATE('01/01/1970','MM/DD/YYYY');

 END;





-- Porcess express check out cache stored in ibw_page_views_tmp


printLog('Clean up Page views temp table');

DELETE FROM ibw_page_views_tmp
WHERE process_flag is null;

printLog('Processing Express Checkout cache stored in ibw_page_views_tmp');
FOR page_view IN tmp_page_views_cache(5)
LOOP

  SELECT COUNT(order_id)
  INTO l_rec_count
  FROM aso_quote_headers_all
	WHERE quote_header_id = SUBSTR(page_view.evnt_id,0,INSTR(page_view.evnt_id,',NOORDER')-1);   --Changed by Sanjay. Changed NULL to NOORDER
  IF l_rec_count > 0
  THEN
    UPDATE ibw_page_views_tmp tmp
    SET tmp.evnt_id =
	  (SELECT    quote_header_id|| ','|| NVL(order_id,'NULL')
		  FROM aso_quote_headers_all
		  WHERE quote_header_id = SUBSTR(tmp.evnt_id,0,INSTR(tmp.evnt_id,',NOORDER')-1))    --Changed by Sanjay. Changed NULL to NOORDER
      ,tmp.evnt_type=l_xchkout_code
      ,tmp.process_flag = null
    WHERE tmp.rec_id =  page_view.rec_id;
  ELSE
    UPDATE ibw_page_views_tmp tmp
    SET tmp.evnt_id =
		  (SELECT    quote_header_id
		  FROM aso_quote_headers_all
		  WHERE quote_header_id = SUBSTR(tmp.evnt_id,0,INSTR(tmp.evnt_id,',NOORDER')-1))    --Changed by Sanjay. Changed NULL to NOORDER
      ,tmp.evnt_type=l_cart_code
      ,tmp.process_flag = null
    WHERE tmp.rec_id =  page_view.rec_id;
  END IF;
END LOOP;



-- Migrate display pages into page views temp table FROM the PAT Schema
-- Process Flag Explanation
-- Process_flag = null : Pages which are ready to be moved to page views
-- process_flag = 7 : Pages which have invalid context and are to be ignored
-- process_flag = 5 : Express check out page views which dont have order id yet,
--                    they will be processed in next run

printLog('Migrating Display pageviews from PAT schema into temp table starting from '
          || l_pat_date );




INSERT INTO ibw_page_views_tmp
            ( rec_id
            , page_view_seq_num
            , page_instance_id
            , visit_id
            , page_view_start_time
            , page_view_duration
           , tracked_application_context
            , tracked_site_code
            , tracked_page_code
            , tracked_page_name
            , tracked_page_url
            , search_result_size
            , search_phrase
            , exact_result_size_flag
            , site_id
            , page_id
            , business_context_value
            , business_context
            , party_id
            , visitor_id
            , visitant_id
            , evnt_type
            , evnt_id
            , campaign_source_code_id
            , referral_url
            , ip_address
            , browser_os_info
            , user_id
            , user_guid
            , party_relationship_id
            , created_by
            , creation_date
            , last_updated_by
            , last_update_date
            , last_update_login
            , object_version_number
            , program_id
            , program_login_id
            , program_application_id
            , request_id
            , process_flag
            )
     SELECT ibw_page_views_s1.NEXTVAL
         , seqnum
          , -1 AS page_instance_id                            -- Set page instance id as -1 for processing it again later
          , visitid
          , pageviewstarttime
          , DURATION
          , appctx
          , tracked_site_code
          , tracked_page_code
          , tracked_page_name
          , url
          , srch_size
          , srch_str
          , srch_more
          , site_id
          , NVL ( pages.page_id, -1 ) AS page_id
          , DECODE(pv.business_context_value
                   ,'-1',pv.attribute10
                   ,pv.business_context_value
                   )
          , pv.business_context
          , party_id
          , visitorid
          , DECODE ( user_id
                   , l_guest_user_id, NVL2 ( guid
                                           ,    'g'
                                             || guid
                                           ,    'v'
                                             || visitorid
                                           )
                   , NULL, NVL2 ( guid
                                ,    'g'
                                  || guid
                                ,    'v'
                                  || visitorid
                                )
                   , NVL2 ( party_id
                          ,    'p'
                           || party_id
                          ,    'f'
                            || user_id
                          )
                   )
          , event_code
          , evnt_id
          , campaign_source_code
          , referrer
          , ip_address
          , useragent
          , user_id
          , guid
          , DECODE(customer_id,party_id,null,customer_id) AS rel_id
          , fnd_global.user_id
          , pat_last_update_date
          , fnd_global.user_id
          , pat_last_update_date
          , fnd_global.conc_login_id
          , 1
          , fnd_global.conc_program_id
          , fnd_global.conc_login_id
          , fnd_global.prog_appl_id
          , fnd_global.conc_request_id
          , DECODE ( INSTR ( evnt_id
                           , ',NULL'
                           , 1
                           , 1
                           )
                   , 0, DECODE ( business_context_value
                               , '-1', NVL2(page_id,7,DECODE(site_id
                                       ,-2,3
                                       ,NVL2(page_id,NULL,9)					--Changed 1 to NULL by Sanjay
                                       ))
                               , '-999',DECODE(pages.business_context
                                               ,'NONE',DECODE(site_id
                                                              ,-2,3
                                                             ,NVL2(page_id,NULL,9)					--Changed 1 to NULL by Sanjay
                                                              )			--Perf:63:Changed 1 to NULL by Sanjay
                              					       ,NULL,DECODE(site_id
                                                                    ,-2,3
                                                                    ,NVL2(page_id,NULL,9)					--Changed 1 to NULL by Sanjay
                                                                     )			--Perf:63:Changed 1 to NULL by Sanjay
                                               ,NVL2(page_id,6,DECODE(site_id
                                                                      ,-2,3
                                                                     ,NVL2(page_id,NULL,9)					--Changed 1 to NULL by Sanjay
                                                                      )
													)	--Perf:63:Changed 1 to NULL by Sanjay
                                               )
                               ,DECODE(site_id
                                       ,-2,3
                                       ,NVL2(page_id,NULL,9)					--Changed 1 to NULL by Sanjay
                                       )
                              )
                   , NULL, DECODE ( business_context_value
                               , '-1',NVL2(page_id,7,DECODE(site_id
                                       ,-2,3
                                       ,NVL2(page_id,NULL,9)					--Changed 1 to NULL by Sanjay
                                       ))
                               , '-999',DECODE(pages.business_context
                                               ,'NONE',DECODE(site_id
                                                              ,-2,3
                                                              ,NVL2(page_id,NULL,9)					--Changed 1 to NULL by Sanjay
                                                              )		--Perf:63:Changed 1 to NULL by Sanjay
					                                     ,NULL,DECODE(site_id
                                                                      ,-2,3
                                                                      ,NVL2(page_id,NULL,9)					--Changed 1 to NULL by Sanjay
                                                                     )		--Perf:63:Changed 1 to NULL by Sanjay
                                               ,NVL2(page_id,6,DECODE(site_id
                                                                      ,-2,3
                                                                      ,NVL2(page_id,NULL,9)					--Changed 1 to NULL by Sanjay
                                                                     )
                                                     )	--Perf:63:Changed 1 to NULL by Sanjay
                                               )
                               ,DECODE(site_id
                                       ,-2,3
                                       ,NVL2(page_id,NULL,9)					--Changed 1 to NULL by Sanjay
                                       )
                               )
                   , 5
                   ) AS process_flag
       FROM ibw_pages_b pages
       , ( SELECT  DECODE( pat.attribute16
                  ,'I', NVL ( sites1.msite_id, -1 )	           --Put site id as -1 if not there, for processing later
                  ,'E', NVL ( sites2.msite_id                  -- If doesnt have site id , resolve it.
                             , NVL( ( SELECT type_id        -- Match the URL stripping query string with all the url_pattern and take the site id
                                      FROM ibw_url_patterns_b
                                      WHERE TYPE = 'S'
                                      AND ROWNUM = 1
                                      AND SUBSTR ( pat.attribute24
                                                                         , 1
                                                                         , DECODE( INSTR( pat.attribute24
                                                                                          , '?'
                                                                                          , 1
                                                                                        )
                                                                                   , 0, LENGTH( pat.attribute24 )
                                                                                   , INSTR( pat.attribute24
                                                                                            , '?'
                                                                                            , 1
                                                                                          ) - 1
                                                    )
                                                                       ) LIKE
                                           REPLACE ( url_pattern
                                                    , '*'
                                                    , '%'
                                                  ) || '%'
                                     )
                                  , -2
			         )
		             )
	         ) AS site_id
       , TO_NUMBER ( pat.attribute1 ) AS visitid
       , TO_NUMBER ( pat.attribute2 ) AS visitorid
       , pat.TIMESTAMP AS pageviewstarttime                                        -- Put PAT.Timestamp as starttime for calculating duration
       , TO_NUMBER ( pat.attribute6 ) AS seqnum
       , NVL ( SUBSTR ( pat.attribute24
                      , 0
                      , 3999
                      ), ' ' ) AS url
       , pat.attribute16 AS appctx
       /*
	      * Page View Duration will be recorded as visitid-seqnum-duration by tracking either in the next page view or next next page view.
		 * It means that for page view 1 tracking may put page view duration in page view 2 or page view 3.
		 * Use Lead function to get next or next next page view.
		 * If page view duration is not tracked then put -1 for calculating duration with latency.
	      */
	     , TO_NUMBER ( DECODE ( (    pat.attribute1
                                || '-'
                                || pat.attribute6 )
                            , LEAD ( ( SUBSTR ( pat.attribute8
                                              , 0
                                              , (   INSTR ( pat.attribute8
                                                          , '-'
                                                          , 1
                                                          , 2
                                                          )
                                                  - 1
                                                )
                                              )
                                     )) OVER ( PARTITION BY TO_NUMBER ( pat.attribute1 ) ORDER BY TO_NUMBER ( pat.attribute6 )), NVL ( LEAD ( ( SUBSTR ( pat.attribute8
                                                                                                                                                       ,   INSTR ( pat.attribute8
                                                                                                                                                                , '-'
                                                                                                                                                                 , 1
                                                                                                                                                                 , 2
                                                                                                                                                                 )
                                                                                                                                                         + 1 )
                                                                                                                                              )) OVER ( PARTITION BY TO_NUMBER ( pat.attribute1 ) ORDER BY TO_NUMBER ( pat.attribute6 ))
                                                                                                                                     , -1 )
                            , LEAD ( ( SUBSTR ( pat.attribute8
                                              , 0
                                              , (   INSTR ( pat.attribute8
                                                          , '-'
                                                          , 1
                                                          , 2
                                                          )
                                                  - 1
                                                )
                                              )
                                     )
                                   , 2 ) OVER ( PARTITION BY TO_NUMBER ( pat.attribute1 ) ORDER BY TO_NUMBER ( pat.attribute6 )), NVL ( LEAD ( ( SUBSTR ( pat.attribute8
                                                                                                                                                        ,   INSTR ( pat.attribute8
                                                                                                                                                                  , '-'
                                                                                                                                                                  , 1
                                                                                                                                                                  , 2
                                                                                                                                                                  )
                                                                                                                                                          + 1 )
                                                                                                                                               )
                                                                                                                                             , 2 ) OVER ( PARTITION BY TO_NUMBER ( pat.attribute1 ) ORDER BY TO_NUMBER ( pat.attribute6 ))
                                                                                                                                      , -1 )
                            , NVL ( DECODE( LEAD( pat.attribute6) over ( PARTITION BY TO_NUMBER(pat.attribute1)
			                                                 ORDER BY TO_NUMBER(pat.starttime)
								       )
	                                    , pat.attribute6 + 1,  LEAD( pat.starttime) over ( PARTITION BY TO_NUMBER(pat.attribute1)
					                                                       ORDER BY TO_NUMBER(pat.starttime)
											     )
	                                    , pat.attribute6,  LEAD( pat.starttime) over ( PARTITION BY TO_NUMBER(pat.attribute1)
					                                                       ORDER BY TO_NUMBER(pat.starttime)
											 )
	                                    , pat.starttime ) - pat.starttime  ,  0) -- Perf:66:Changed page view duration update to decode
                            )) AS DURATION
	       /*
		   * Event validations and getting more information out of the published:
		   * For Express Check out: iStore will publish the cart id, we should get the order id if the cart has been converted.
		   * Otherwise the event will be cached in the page_views_tmp table to be picked up in the next run of this program.
		   * To know whether the cart has been converted into order the select stmt on the aso_quote_headers_all is giving a string
		   * like "cart_id,order_id" where order_id could be a known string like 'NOORDER'
		   *
		   * For Order Creation: iStore will publish cart id, we need to get the order id.
		   */
       , DECODE( pat.attribute16
            , 'I', DECODE ( pat.attribute20
                        , l_xchkout_code, NVL ( ( SELECT    quote_header_id
                                                  || ','
                                                  || DECODE ( order_id
                                                           , NULL, 'NOORDER'      --Changed by Sanjay. Changed from NULL to NOORDER
                                                           , TO_CHAR ( order_id )
                                                           )
                                                  FROM aso_quote_headers_all
                                                  WHERE quote_header_id =
                                                     SUBSTR ( pat.attribute21
                                                            ,   INSTR ( pat.attribute21
                                                                      , '=' )
                                                              + 1 ))
                                      , '-1' )
                        , l_order_code, ( SELECT TO_CHAR ( order_id )
                                          FROM aso_quote_headers_all
                                          WHERE quote_header_id =
                                             SUBSTR ( pat.attribute21
                                                    ,   INSTR ( pat.attribute21
                                                              , '=' )
                                                      + 1 ))
                        , 'SRCH',pat.attribute21
                        ,  SUBSTR ( pat.attribute21 ,   INSTR ( pat.attribute21 , '=' ) + 1 )
                       )
            , 'E', DECODE ( pat.attribute20
	                   ,l_cart_code,null
                           ,l_order_code,null
                           ,'SRCH',null
                           ,l_xchkout_code,null
			   , l_ordinq_code, NVL2 ( pat.attribute21
                                       , ( SELECT TO_CHAR ( header_id )
                                            FROM oe_order_headers_all
                                           WHERE header_id =
                                                      NVL (
                                                            DECODE(LTRIM(SUBSTR ( pat.attribute21
                                                                                  ,INSTR ( pat.attribute21
                                                                                           , '='
                                                                                         ) +1
                                                                                 )
                                                                          ,'0123456789'
                                                                         )
                                                                   ,NULL,pat.attribute10
                                                                   ,-1
                                                                   )
                                                           ,-1)
                                         )
                                       , '-1'
                                       )
                       , l_payinq_code, NVL2 ( pat.attribute21
                                       , ( SELECT TO_CHAR ( cash_receipt_id )
                                            FROM ar_cash_receipts_all
                                           WHERE cash_receipt_id =
                                                      NVL (
                                                            DECODE(LTRIM(SUBSTR ( pat.attribute21
                                                                                  ,INSTR ( pat.attribute21
                                                                                           , '='
                                                                                         ) +1
                                                                                 )
                                                                          ,'0123456789'
                                                                         )
                                                                   ,NULL,pat.attribute10
                                                                   ,-1
                                                                   )
                                                           ,-1)
                                         )
                                       , '-1'
                                       )
                       , l_invinq_code, NVL2 ( pat.attribute21
                                       , ( SELECT TO_CHAR ( customer_trx_id )
                                            FROM ra_customer_trx_all
                                           WHERE customer_trx_id =
                                                      NVL (
                                                            DECODE(LTRIM(SUBSTR ( pat.attribute21
                                                                                  ,INSTR ( pat.attribute21
                                                                                           , '='
                                                                                         ) +1
                                                                                 )
                                                                          ,'0123456789'
                                                                         )
                                                                   ,NULL,pat.attribute10
                                                                   ,-1
                                                                   )
                                                           ,-1)
                                         )                                      , '-1'
                                       )
                       , pat.attribute21
                      )
                ) AS evnt_id
       , pat.attribute7 AS tracked_site_code
       , pat.attribute4 AS tracked_page_code
       , pat.attribute5 AS tracked_page_name
       , NVL ( pat.attribute9, 'NONE' ) AS business_context
       , NVL2 (pat.attribute9
              , NVL ( DECODE ( pat.attribute9
                             , 'PRODUCT', ( SELECT    NVL2 ( inventory_item_id
                                                           ,    inventory_item_id
                                                             || '-'
                                                           , NULL
                                                           )
                                                   || NVL2 ( master_id
                                                           ,    SUBSTR ( master_id
                                                                       ,   INSTR ( master_id
                                                                                 , '-'
                                                                                 , 1
                                                                                 , 1
                                                                                 )
                                                                         + 1 )
                                                             || '-'
                                                           ,    organization_id
                                                             || '-'
                                                           )
                                                   || NVL2 ( organization_id
                                                           , organization_id
                                                           , NULL
                                                           )
                                             FROM eni_oltp_item_star
                                            WHERE inventory_item_id =
                                                       NVL ( DECODE(LTRIM(pat.attribute10,'0123456789'),NULL,pat.attribute10,-1),-1)
                                              AND organization_id =
                                                       NVL ( DECODE(LTRIM(pat.attribute15,'0123456789'),NULL,pat.attribute15,-1),-1)
                                          )
                             , 'SECTION', ( SELECT section_id
                                             FROM ibe_dsp_sections_b		      --Perf:70:Changed from sections_vl to sections_v
                                            WHERE section_id = pat.attribute10 )
                             , NULL
                             )
                    , '-1' )
              , '-999'
              ) AS business_context_value                 -- For section context:just validating the section id,
		                                                   -- for product context: getting a combination of childitem-masteritem-org
       , camptab.source_code_id AS campaign_source_code                  -- Validating if the campaign id is valid and numeric
									 --Perf:removed inner select and made outer join
       , DECODE ( DECODE(pat.attribute16,'I',sites1.enable_traffic_filter,sites2.enable_traffic_filter)
                , 'Y', NVL ( ( SELECT tag
                                FROM fnd_lookup_values
                               WHERE lookup_type = 'IBW_IP_ADDRESS'
                                 AND view_application_id = 666
                                 AND security_group_id = 0
                                 AND lookup_code = meaning
                                 AND ROWNUM=1
                                 AND pat.clientip LIKE
                                                     REPLACE ( tag
                                                             , '*'
                                                             , '%'
                                                             ))
                           , 'N' )
                , 'N'
                ) AS ipfilter                              -- assigning ipfilter=N if page doesnt qualify to be filtered out
       , pat.attribute20 AS event_code
       , TO_NUMBER ( DECODE ( pat.attribute20
                            , 'SRCH', SUBSTR ( pat.attribute21
                                             ,   INSTR ( attribute21
                                                       , 'SRCHSIZE=' )
                                               + 9
                                             , DECODE ( INSTR ( attribute21
                                                              , ':'
                                                              , INSTR ( attribute21
                                                                      , 'SRCHSIZE=' )
                                                              , 1
                                                              )
                                                      , 0, LENGTH ( attribute21 )
                                                         + 1
                                                      ,   INSTR ( attribute21
                                                                , ':'
                                                                , INSTR ( attribute21
                                                                        , 'SRCHSIZE=' )
                                                                , 1
                                                                )
                                                        - INSTR ( attribute21
                                                                , 'SRCHSIZE=' )
                                                        - LENGTH ( 'SRCHSIZE=' )
                                                      )
                                             )
                            , -1
                            )) AS srch_size                 -- Update search size by looking for key word SRCHSIZE=20,
					                                      -- may be a ':' could come to start another saerch attribute
       , DECODE ( pat.attribute20
                , 'SRCH', SUBSTR ( pat.attribute21
                                 ,   INSTR ( attribute21, 'SRCHSTR=' )
                                   + 8
                                 , DECODE ( INSTR ( attribute21
                                                  , ':'
                                                  , INSTR ( attribute21
                                                          , 'SRCHSTR=' )
                                                  , 1
                                                  )
                                          , 0, LENGTH ( attribute21 )
                                             + 1
                                          ,   INSTR ( attribute21
                                                    , ':'
                                                    , INSTR ( attribute21
                                                            , 'SRCHSTR=' )
                                                    , 1
                                                    )
                                            - INSTR ( attribute21, 'SRCHSTR=' )
                                            - LENGTH ( 'SRCHSTR=' )
                                          )
                                 )
                , NULL
                ) AS srch_str                                   -- Update search string by looking for key workd SRCHSTR=Web,
			                                                    -- may be a ':' could come to start another search attribute
       , DECODE ( pat.attribute20
                , 'SRCH', DECODE ( INSTR ( attribute21
                                         , 'SRCHMORE'
                                         , 1
                                         , 1
                                         )
                                 , 0, 'Y'
                                 , 'N'
                                 )
                , NULL
                ) AS srch_more                                  -- Update more result flag by looking for key word SRCHMORE
       , NVL ( NVL2 ( DECODE(pat.attribute16,'I',usertab1.customer_id,usertab2.customer_id)
                             , NVL ( DECODE(pat.attribute16,'I',rel1.object_id,rel2.object_id), DECODE(pat.attribute16,'I',usertab1.customer_id,usertab2.customer_id) )
                             , l_guest_party_id
                             )
             , l_guest_party_id ) AS party_id                   -- Get correct party id for b2b or b2c user if he is not guest user.
       , DECODE(pat.attribute16,'I',usertab1.customer_id,usertab2.customer_id) AS customer_id
       , pat.attribute14 AS loginevent
       , pat.clientip AS ip_address
       ,NVL ( SUBSTR ( pat.referrer
                      , 0
                      , 3999
                      ), NULL ) AS referrer
       , pat.useragent AS useragent
       , DECODE ( pat.attribute16
                 ,'I', NVL2 ( ( SELECT access_name
                                FROM ibe_dsp_attachments_v
		                WHERE UPPER(pat.attribute24) LIKE '%/' || UPPER(file_name) || '%'         --Changed by Venky.
                                AND ROWNUM = 1 )
                              , 'R'
                              , NVL2 ( pat.attribute4
                                       , 'C',NVL2 ( pat.attribute5
                                                   , 'N', 'U'
                                                  )
                                     )
                             )                            -- Matching criteria is R, if template is found for the jsp in the page view URL
		                                                         -- else if page code is found then C, else if page name is found then N, else U.
                 ,'E', NVL2 ( pat.attribute4
                              , 'C', NVL2( pat.attribute5
                                           , 'N', 'U'
                                         )
                             )                            -- Matching criteria for non-EBS is similar to EBS but no template mapping involved
                )  AS matching_criteria
       , DECODE( pat.attribute16
                 ,'I', UPPER(NVL ( ( SELECT access_name
                                     FROM ibe_dsp_attachments_v
		                      WHERE UPPER(pat.attribute24) LIKE '%/' || UPPER(file_name) || '%'           --Changed by Venky
                                     AND ROWNUM = 1 )
                                  , NVL ( pat.attribute4
                                          , NVL ( pat.attribute5
                                                  , SUBSTR ( pat.attribute24
                                                             , 1
                                                            , DECODE ( INSTR ( pat.attribute24
                                                                              , '?'
                                                                              , 1
                                                                              , 1
                                                                             )
                                                                      , 0, LENGTH ( pat.attribute24 )
                                                                      , INSTR ( pat.attribute24
                                                                                , '?'
                                                                                , 1
                                                                                , 1
                                                                              ) - 1
                                                                     )
                                                            )
                                                  )
                                        )
                                 )
                             )
                   ,'E', UPPER( NVL2 ( pat.attribute4
                                       , pat.attribute4, NVL2 ( pat.attribute5
                                                                , pat.attribute5, SUBSTR ( pat.attribute24
                                                                                          , 1
                                                                                          , DECODE ( INSTR ( pat.attribute24
                                                                                                             , '?'
                                                                                                             , 1
                                                                                                           )
                                                                                                    , 0, LENGTH ( pat.attribute24 )
                                                                                                    , INSTR ( pat.attribute24
                                                                                                              , '?'
                                                                                                              , 1
                                                                                                            ) - 1
                                                                                                   )
                                                                                          )
                                                               )
                                      )
                               )
		) AS matching_value                          -- Based on the matching_criteria get the matching_value also
       , NVL ( pat.userid, l_guest_user_id ) AS user_id                           -- Make all numm user id value as guest user id
       , pat.attribute3 AS guid
      , pat.attribute10 AS attribute10
      ,pat.last_update_date as pat_last_update_date
   FROM jtf_pf_wa_info_vl pat
      , ibe_msites_b sites1
      , ibe_msites_b sites2
      , ams_source_codes camptab
      , fnd_user usertab1
      , fnd_user usertab2
      , hz_relationships rel2
      , hz_relationships rel1
  WHERE pat.last_update_date > l_pat_date                             -- Consider only records logged after the last puged date
    AND pat.attribute11 = 'true'                                      -- Consider only display pages
    AND sites1.msite_id(+) = DECODE(pat.attribute16,'I',pat.attribute7,-1)
    AND sites2.access_name(+) = DECODE(pat.attribute16,'E',pat.attribute7,NULL)
    AND camptab.source_code_id (+) = NVL ( DECODE(LTRIM(pat.attribute13,'0123456789'),NULL,pat.attribute13,-1),-1) --Perf: Changed from inner select to outter join
    AND rel1.party_id(+) = usertab1.customer_id
    AND rel1.directional_flag(+) = 'F'
    AND rel2.party_id(+) = usertab2.customer_id
    AND rel2.directional_flag(+) = 'F'
    AND usertab1.user_id (+) = DECODE(pat.attribute16,'I',pat.userid,-1)                             --Perf: Removed inner select and made it join
    AND usertab2.user_guid (+) = DECODE(pat.attribute16,'E',pat.attribute3,NULL) ) pv
   WHERE pv.ipfilter = 'N'                                                         -- ipfilter is processed in the inner selects and
                                                                                   -- made 'Y' if it has to be filtered out
        AND pages.page_matching_criteria(+) = pv.matching_criteria                 -- The matching_criteria is evaluated in the inner select
	                                                                                 -- this should match the page matching criteria or be null
        AND pages.page_matching_value(+) = UPPER(pv.matching_value)                       -- The matching_value is evaluated in the inner selects's
	                                                                                 -- this should match the page matching value or be null
        AND pv.visitid NOT IN ( 0, -1 )                                            -- Bug # for visit id -1 (being defensive on the wrong data)
        AND pv.visitorid NOT IN ( -1, 0 );

-- Migrate Processing Pages into page views temp table from PAT schema

-- Process Flag Explanationch

-- Process_flag = 8 : Processing Pages which have login event info
-- process_flag = 4 : Processing Pages which have business events
-- process_flag = 5 : Express check out page views which dont have order id yet,
--                    they will be processed in next run

	printLog('Migrating Processing iStore pageviews FROM PAT schema into temp table');

INSERT INTO ibw_page_views_tmp
            ( rec_id
            , page_view_seq_num
            , page_instance_id
            , visit_id
            , page_view_start_time
            , page_view_duration
            , tracked_application_context
            , tracked_site_code
            , tracked_page_code
            , tracked_page_name
            , tracked_page_url
            , search_result_size
            , search_phrase
            , exact_result_size_flag
            , site_id
            , page_id
            , business_context_value
            , business_context
            , party_id
            , visitor_id
            , visitant_id
            , evnt_type
            , evnt_id
            , campaign_source_code_id
            , referral_url
            , ip_address
            , browser_os_info
            , user_id
            , user_guid
            , party_relationship_id
            , created_by
            , creation_date
            , last_updated_by
            , last_update_date
            , last_update_login
            , object_version_number
            , program_id
            , program_login_id
            , program_application_id
            , request_id
            , process_flag
            )
     SELECT  ibw_page_views_s1.NEXTVAL
          , seqnum
          , -1
          , visitid
          , SYSDATE
          , 0
          , appctx
          , NULL
          , NULL
          , NULL
          , ' '
          , srch_size
          , srch_str
          , srch_more
          , site_id
          , -2
          , NULL
          , NULL
          , party_id
          , visitorid
          , DECODE ( user_id
                   , l_guest_user_id, NVL2 ( guid
                                           ,    'g'
                                             || guid
                                           ,    'v'
                                             || visitorid
                                           )
                   , NULL, NVL2 ( guid
                                ,    'g'
                                  || guid
                                ,    'v'
                                  || visitorid
                                )
                   , NVL2 ( party_id
                          ,    'p'
                            || party_id
                          ,    'f'
                            || user_id
                          )
                   )
          , event_code
          , evnt_id
          , NULL
          , NULL
          , ip_address
          , NULL
          , user_id
          , guid
          , NULL
          , fnd_global.user_id
          , pat_last_update_date
          , fnd_global.user_id
          , SYSDATE
          , fnd_global.conc_login_id
          , 1
          , fnd_global.conc_program_id
          , fnd_global.conc_login_id
          , fnd_global.prog_appl_id
          , fnd_global.conc_request_id
          , DECODE ( loginevent
                   , 'true', 8
                   , DECODE ( INSTR ( evnt_id
                                    , 'NULL'
                                    , 1
                                    , 1
                                    )
                            , 0, 4
                            , DECODE ( event_code
                                     , l_xchkout_code, 5
                                     , 4
                                     )
                            )
                   ) AS process_flag
       FROM ( SELECT pat.recid
                   , DECODE( pat.attribute16
		                  ,'I', NVL ( sites1.msite_id, -1 )	           --Put site id as -1 if not there, for processing later
		                  ,'E', NVL ( sites2.msite_id                  -- If doesnt have site id , resolve it.
		                             , NVL( ( SELECT type_id        -- Match the URL stripping query string with all the url_pattern and take the site id
		                                      FROM ibw_url_patterns_b
		                                      WHERE TYPE = 'S'
		                                      AND SUBSTR ( pat.attribute24
                                                                         , 1
                                                                         , DECODE( INSTR( pat.attribute24
                                                                                          , '?'
                                                                                          , 1
                                                                                        )
                                                                                   , 0, LENGTH( pat.attribute24 )
                                                                                   , INSTR( pat.attribute24
                                                                                            , '?'
                                                                                            , 1
                                                                                          ) - 1
                                                                                     )
                                                                       )
									       LIKE
										  REPLACE ( url_pattern
		                                                    , '*'
		                                                    , '%'
		                                                  ) || '%'
		                                     )
		                                  , -2
					         )
				             )
			         ) AS site_id
                   , TO_NUMBER ( pat.attribute1 ) AS visitid
                   , TO_NUMBER ( pat.attribute2 ) AS visitorid
                   , TO_NUMBER ( pat.attribute6 ) AS seqnum
                   , pat.attribute16 AS appctx
                   , ( DECODE ( pat.attribute20
                              , l_xchkout_code, ( SELECT    quote_header_id
                                                         || ','
                                                         || DECODE ( order_id
                                                                   , NULL, 'NOORDER'   --Changed by Sanjay. NULL to NORDER
                                                                   , TO_CHAR ( order_id )
                                                                   )
                                                   FROM aso_quote_headers_all
                                                  WHERE quote_header_id =
                                                             SUBSTR ( pat.attribute21
                                                                    ,   INSTR ( pat.attribute21
                                                                              , '=' )
                                                                      + 1 ))
                                , l_order_code, ( SELECT order_id
                                                 FROM aso_quote_headers_all
                                                WHERE quote_header_id =
                                                           SUBSTR ( pat.attribute21
                                                                  ,   INSTR ( pat.attribute21
                                                                            , '=' )
                                                                    + 1 ))
			      ,  'SRCH',pat.attribute21
                ,SUBSTR ( pat.attribute21
                                                    ,   INSTR ( pat.attribute21
                                                              , '=' )
                                                      + 1 )--Removed validations for enquiries by sanjay
                              )
                     ) AS evnt_id
					 , DECODE ( DECODE(pat.attribute16,'I',sites1.enable_traffic_filter,sites2.enable_traffic_filter)
		                  , 'Y', NVL ( ( SELECT tag
		                                FROM fnd_lookup_values
		                               WHERE lookup_type = 'IBW_IP_ADDRESS'
		                                 AND ROWNUM=1
		                                 AND pat.clientip LIKE
		                                                     REPLACE ( tag
		                                                             , '*'
		                                                             , '%'
		                                                             ))
		                           , 'N' )
		                , 'N'
		                ) AS ipfilter
                   , pat.clientip AS ip_address
                   , pat.attribute20 AS event_code
                   , TO_NUMBER ( DECODE ( pat.attribute20
                                        , 'SRCH', SUBSTR ( pat.attribute21
                                                         ,   INSTR ( attribute21
                                                                   , 'SRCHSIZE=' )
                                                           + LENGTH ( 'SRCHSIZE' )
                                                           + 1
                                                         , DECODE ( INSTR ( attribute21
                                                                          , ':'
                                                                          , INSTR ( attribute21
                                                                                  , 'SRCHSIZE=' )
                                                                          , 1
                                                                          )
                                                                  , 0, LENGTH ( attribute21 )
                                                                     + 1
                                                                  ,   INSTR ( attribute21
                                                                            , ':'
                                                                            , INSTR ( attribute21
                                                                                    , 'SRCHSIZE=' )
                                                                            , 1
                                                                            )
                                                                    - INSTR ( attribute21
                                                                            , 'SRCHSIZE=' )
                                                                    - LENGTH ( 'SRCHSIZE=' )
                                                                  )
                                                         )
                                        , -1
                                        )) AS srch_size
                   , DECODE ( pat.attribute20
                            , 'SRCH', SUBSTR ( pat.attribute21
                                             ,   INSTR ( attribute21
                                                       , 'SRCHSTR=' )
                                               + LENGTH ( 'SRCHSTR' )
                                               + 1
                                             , DECODE ( INSTR ( attribute21
                                                              , ':'
                                                              , INSTR ( attribute21
                                                                      , 'SRCHSTR=' )
                                                              , 1
                                                              )
                                                      , 0, LENGTH ( attribute21 )
                                                         + 1
                                                      ,   INSTR ( attribute21
                                                                , ':'
                                                                , INSTR ( attribute21
                                                                        , 'SRCHSTR=' )
                                                                , 1
                                                                )
                                                        - INSTR ( attribute21
                                                                , 'SRCHSTR=' )
                                                        - LENGTH ( 'SRCHSTR=' )
                                                      )
                                             )
                            , NULL
                            ) AS srch_str
                   , DECODE ( pat.attribute20
                            , 'SRCH', DECODE ( INSTR ( attribute21
                                                     , 'SRCHMORE'
                                                     , 1
                                                     , 1
                                                     )
                                             , 0, 'Y'
                                             , 'N'
                                             )
                            , NULL
                            ) AS srch_more
                   , NVL ( DECODE(pat.attribute16,'I',usertab1.user_id,usertab2.user_id), l_guest_user_id )
                                                                   AS user_id
                   , pat.attribute14 AS loginevent
                  , NVL ( NVL2 ( DECODE(pat.attribute16,'I',usertab1.customer_id,usertab2.customer_id)
                             , NVL ( DECODE(pat.attribute16,'I',rel1.object_id,rel2.object_id), DECODE(pat.attribute16,'I',usertab1.customer_id,usertab2.customer_id) )
                             , l_guest_party_id
                             )
               , l_guest_party_id ) AS party_id                   -- Get correct party id for b2b or b2c user if he is not guest user.
               , DECODE(pat.attribute16,'I',usertab1.customer_id,usertab2.customer_id) AS customer_id
                   , pat.attribute3 guid
                   ,pat.last_update_date as pat_last_update_date
               FROM jtf_pf_wa_info_vl pat
                  , ibe_msites_b sites1
                  , ibe_msites_b sites2
                   , fnd_user usertab1
                   , fnd_user usertab2
                   , hz_relationships rel1
                   , hz_relationships rel2
              WHERE pat.attribute11 = 'false'
                AND pat.last_update_date > l_pat_date
                AND sites1.msite_id(+) = DECODE(pat.attribute16,'I',pat.attribute7,-1)
                AND sites2.access_name(+) = DECODE(pat.attribute16,'E',pat.attribute7,NULL)
                AND rel1.party_id(+) = usertab1.customer_id
			    AND rel1.directional_flag(+) = 'F'
			    AND rel2.party_id(+) = usertab2.customer_id
			    AND rel2.directional_flag(+) = 'F'
			    AND usertab1.user_id (+) = DECODE(pat.attribute16,'I',pat.userid,-1)                             --Perf: Removed inner select and made it join
			    AND usertab2.user_guid (+) = DECODE(pat.attribute16,'E',pat.attribute3,NULL)) pv
      WHERE pv.visitid NOT IN ( 0, -1 )
      AND pv.visitorid NOT IN ( -1, 0 );



--Get all page views from ibw_page_views for the visits in current run of offline engine
printLog('Get all page views for visits split across offline engine runs');
 INSERT INTO ibw_page_views_tmp( rec_id,
                                 PAGE_VIEW_SEQ_NUM,
                                 PAGE_INSTANCE_ID,
                                 VISIT_ID,
                                 PAGE_VIEW_START_TIME,
                                 PAGE_VIEW_DURATION,
                                 TRACKED_APPLICATION_CONTEXT,
                                 TRACKED_SITE_CODE,
                                 TRACKED_PAGE_CODE,
                                 TRACKED_PAGE_NAME,
                                 TRACKED_PAGE_URL,
                                 SEARCH_RESULT_SIZE,
                                 SEARCH_PHRASE,
                                 EXACT_RESULT_SIZE_FLAG,
                                 SITE_ID,
                                 PAGE_ID,
                                 BUSINESS_CONTEXT_VALUE,
                                 BUSINESS_CONTEXT,
                                 PARTY_ID,
                                 VISITOR_ID,
                                 VISITANT_ID,
                                 EVNT_TYPE,
                                 EVNT_ID,
                                 CAMPAIGN_SOURCE_CODE_ID,
                                 REFERRAL_URL,
                                 IP_ADDRESS,
                                 BROWSER_OS_INFO,
                                 USER_ID,
                                 USER_GUID,
                                 PARTY_RELATIONSHIP_ID,
                                 PROCESS_FLAG,
                                 OBJECT_VERSION_NUMBER,
                                 CREATED_BY,
                                 CREATION_DATE,
                                 LAST_UPDATED_BY,
                                 LAST_UPDATE_DATE
                                )
SELECT  PAGE_VIEW_ID,
        PAGE_VIEW_SEQ_NUM,
        PAGE_INSTANCE_ID,
        VISIT_ID,
        PAGE_VIEW_START_TIME,
        PAGE_VIEW_DURATION,
        TRACKED_APPLICATION_CONTEXT,
        TRACKED_SITE_CODE,
        TRACKED_PAGE_CODE,
        TRACKED_PAGE_NAME,
        TRACKED_PAGE_URL,
        SEARCH_RESULT_SIZE,
        SEARCH_PHRASE,
        EXACT_RESULT_SIZE_FLAG,
        SITE_ID,
        PAGE_ID,
        BUSINESS_CONTEXT_VALUE,
        BUSINESS_CONTEXT,
        PARTY_ID,
        VISITOR_ID,
        VISITANT_ID,
        EVNT_TYPE,
        EVNT_ID,
        CAMPAIGN_SOURCE_CODE_ID,
        REFERRAL_URL,
        IP_ADDRESS,
        BROWSER_OS_INFO,
        USER_ID,
        USER_GUID,
        PARTY_RELATIONSHIP_ID,
        NULL,
        1,
        fnd_global.user_id,
        SYSDATE,
        fnd_global.user_id,
        last_update_date
        FROM ibw_page_views pv
WHERE exists (SELECT tmp.rec_id
              FROM ibw_page_views_tmp tmp
              WHERE pv.visit_id = tmp.visit_id
              AND (process_flag <> 5 or process_flag is null));

DELETE FROM ibw_page_views pv
WHERE exists (SELECT tmp.rec_id
              FROM ibw_page_views_tmp tmp
              WHERE pv.visit_id  = tmp.visit_id
              AND (process_flag <> 5 or process_flag is null));

-- Create Pages IF required for all pages with page id -1
printLog('Creating pages');
FOR page_view IN tmp_page_views_cache(9)
LOOP
  CREATEPAGE(page_view.tracked_page_code,page_view.tracked_page_name,page_view.tracked_page_url,page_view.tracked_application_context,page_view.business_context,l_page_id);
  IF (l_page_id = -1) THEN
    printLog('Cannot create a new page for visit_id :' || page_view.visit_id || ' and seq num :' || page_view.page_view_seq_num  );
  ELSE

   UPDATE ibw_page_views_tmp
    SET page_id = l_page_id ,process_flag = null
    WHERE rec_id = page_view.rec_id;
  END IF;
END LOOP;



-- populate reference column for exisiting pages

UPDATE ibw_pages_b pag
SET REFERENCE = ( SELECT tracked_page_url
                   FROM ibw_page_views_tmp
                  WHERE page_id = pag.page_id and rownum = 1) -- Changed by Venky. Added rownum=1 because select query could return more than 1 row
WHERE  REFERENCE IS NULL
   AND EXISTS ( SELECT 'x'                                    -- Changed by Venky. Replaces 'IN' with 'EXISTS'
		FROM ibw_page_views_tmp tmp
		WHERE tmp.page_id=pag.page_id)
   AND application_context = 'N';

-- Populate page instance table

printLog('Creating new Page instances');
FOR page_view IN tmp_page_views_instances
LOOP
                                --Changed by Venky. Using Exceptions to handle no_data condition


        IBW_PAGE_INSTANCES_PVT.INSERT_row (l_page_instance_id
                                        ,page_view.page_id
					,page_view.business_context
					,page_view.business_context_value
					,error_messages);

END LOOP;

UPDATE ibw_page_views_tmp pv
SET pv.page_instance_id =
         NVL ( ( SELECT pi.page_instance_id
                  FROM ibw_page_instances pi
                 WHERE pi.page_id = pv.page_id
                   AND pi.business_context_value = pv.business_context_value )
             , -1 );

	-- get page view COUNT for logging output


printLog('Getting Page views COUNT');
SELECT COUNT(rec_id)
INTO l_page_view_count
FROM ibw_page_views_tmp
WHERE page_id NOT IN ( -2, -3, -1 )
AND page_id IS NOT NULL
AND process_flag is null;

printLog('Process login events into page views tmp table');

UPDATE ibw_page_views_tmp tmp
SET (visitant_id,user_id ,party_id) =
(SELECT visitant_id
, user_id , party_id
  FROM ibw_page_views_tmp
  WHERE process_flag = 8 AND visit_id = tmp.visit_id AND ROWNUM=1 )
WHERE exists
      (SELECT 'x'
        FROM ibw_page_views_tmp
	WHERE visit_id =  tmp.visit_id
	AND process_flag=8);

printLog('Updating vistant Id,user_id,party_id for missing login events');
UPDATE ibw_page_views_tmp tmp
SET (visitant_id,user_id ,party_id) =
(SELECT visitant_id
        , user_id
        , party_id
  FROM ibw_page_views_tmp
  WHERE visit_id = tmp.visit_id AND ROWNUM=1 AND user_id <> l_guest_user_id)
WHERE (SELECT count(distinct user_id)
		FROM ibw_page_views_tmp
		WHERE visit_id = tmp.visit_id ) > 1;




-- find out if events can be matched to next page views

printLog('Updating processing page events from cache');



FOR page_view IN tmp_page_views_cache(-4)
LOOP
  SELECT COUNT(rec_id)              --Changed by Venky. Removed count(*)
  INTO l_rec_count
  FROM ibw_page_views_tmp tmp
  WHERE  tmp.visit_id =  page_view.visit_id
  AND tmp.page_view_seq_num =  page_view.page_view_seq_num;

  IF l_rec_count > 0 THEN
    UPDATE ibw_page_views_tmp tmp
    SET tmp.evnt_id = page_view.evnt_id
        ,tmp.evnt_type=page_view.evnt_type
        ,tmp.search_phrase=page_view.search_phrase
        ,tmp.search_result_size =  page_view.search_result_size
        ,tmp.EXACT_RESULT_SIZE_FLAG = page_view.EXACT_RESULT_SIZE_FLAG
    WHERE  tmp.visit_id =  page_view.visit_id AND tmp.page_view_seq_num =  page_view.page_view_seq_num;
  ELSE
    DELETE FROM ibw_page_views_tmp
    WHERE rec_id =  page_view.rec_id;
  END IF;
END LOOP;

printLog('Updating processing page events from temp table');

FOR page_view IN tmp_page_views_cache(4)
LOOP
  SELECT COUNT(rec_id)                --Changed by Venky. Removed count(*)
  INTO l_rec_count
  FROM ibw_page_views_tmp tmp
  WHERE  tmp.visit_id =  page_view.visit_id
  AND tmp.page_view_seq_num =  page_view.page_view_seq_num;

  IF l_rec_count > 0 THEN
    UPDATE ibw_page_views_tmp tmp
    SET tmp.evnt_id = page_view.evnt_id
        ,tmp.evnt_type=page_view.evnt_type
        ,tmp.search_phrase=page_view.search_phrase
        ,tmp.search_result_size =  page_view.search_result_size
        ,tmp.EXACT_RESULT_SIZE_FLAG = page_view.EXACT_RESULT_SIZE_FLAG
    WHERE  tmp.visit_id =  page_view.visit_id
    AND tmp.page_view_seq_num =  page_view.page_view_seq_num;
  ELSE
    UPDATE ibw_page_views_tmp
    SET process_flag =-4
    WHERE rec_id =  page_view.rec_id;
  END IF;
END LOOP;

-- Repopulate all campaign ids to all page views in a visit
printLog('Repopulate all campaign ids to all page views in a visit');
UPDATE ibw_page_views_tmp pv
SET pv.campaign_source_code_id =
             NVL ( ( SELECT max(tmp.campaign_source_code_id)
                      FROM ibw_page_views_tmp tmp
                     WHERE tmp.visit_id = pv.visit_id), NULL )
WHERE  EXISTS (
            SELECT 'x'
              FROM ibw_page_views_tmp tmp2
             WHERE tmp2.process_flag is null
               AND tmp2.visit_id = pv.visit_id
               AND tmp2.campaign_source_code_id is not null);


FOR page_view IN page_views_new_referral_cat
LOOP

  l_ref_url := page_view.referral_url;
printLog('Creating Referral Category for the URL:' ||l_ref_url);
  BEGIN
    SELECT patterns.type_id INTO x_ref_id
    FROM ibw_url_patterns_b patterns
    WHERE patterns.TYPE = 'R'
    AND UPPER(l_ref_url) LIKE
        UPPER(REPLACE (patterns.url_pattern, '*', '%') || '%' )
    AND rownum =1
    ORDER BY program_id desc
    ,length(url_pattern) desc
    ,creation_date ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_ref_id :=  NULL;
  END;


  IF x_ref_id is NULL THEN
--Bug 7191178
    IF INSTR (l_ref_url, '/',1,3) = 0
    THEN
      l_ref_name := SUBSTR (l_ref_url, 1,LENGTH (l_ref_url));
    ELSE
      l_ref_name := SUBSTR (l_ref_url, 1,INSTR(l_ref_url, '/',1,3)-1 );
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Creating Referral Category for referral name: ' || l_ref_name);

    IBW_REFERRAL_PVT.INSERT_row(x_ref_id,l_ref_name,l_ref_name,l_error_message);
    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      fnd_message.set_name('IBW','IBW_OE_NEW_REF_CAT');
      fnd_message.set_token('CATEGORY_NAME',l_ref_name);
      fnd_log.string(FND_LOG.LEVEL_EVENT,'IBW.PLSQL.IBWOE_PVT',fnd_message.get);
    END IF;
  END IF;
END LOOP;

-- Populate page views table FROM temp table.

printLog('Populating Page views table');

INSERT INTO ibw_page_views
            ( page_view_id
            , page_view_seq_num
            , page_instance_id
            , visit_id
            , page_view_start_time
            , page_view_duration
            , tracked_application_context
            , tracked_site_code
            , tracked_page_code
            , tracked_page_name
            , tracked_page_url
            , search_result_size
            , search_phrase
            , exact_result_size_flag
            , site_id
            , page_id
            , business_context_value
            , business_context
            , party_id
            , visitor_id
            , visitant_id
            , evnt_type
            , evnt_id
            , campaign_source_code_id
            , referral_url
            , ip_address
            , browser_os_info
            , user_id
            , user_guid
            , party_relationship_id
            , created_by
            , creation_date
            , last_updated_by
            , last_update_date
            , last_update_login
            , object_version_number
            , program_id
            , program_login_id
            , program_application_id
            , request_id
            )
     ( SELECT rec_id
            , page_view_seq_num
            , page_instance_id
            , visit_id
            , page_view_start_time
            , page_view_duration
            , tracked_application_context
            , tracked_site_code
            , tracked_page_code
            , tracked_page_name
            , tracked_page_url
            , search_result_size
            , search_phrase
            , exact_result_size_flag
            , site_id
            , page_id
            , business_context_value
            , business_context
            , party_id
            , visitor_id
            , visitant_id
            , evnt_type
            , evnt_id
            , campaign_source_code_id
            , referral_url
            , ip_address
            , browser_os_info
            , user_id
            , user_guid
            , party_relationship_id
            , fnd_global.user_id
            , SYSDATE
            , fnd_global.user_id
            , SYSDATE
            , fnd_global.conc_login_id
            , 1
            , fnd_global.conc_program_id
            , fnd_global.conc_login_id
            , fnd_global.prog_appl_id
            , fnd_global.conc_request_id
        FROM ibw_page_views_tmp
       WHERE page_id NOT IN ( -2, -3, -1 )
         AND page_id IS NOT NULL
         AND process_flag is NULL
         );



DELETE
FROM  ibw_page_views_tmp
WHERE process_flag IN (4, 8,5,9);      --Changed by Venky. Removed one delete



printLog('Inserting into site_visits table');


MERGE INTO ibw_site_visits sv
USING     (SELECT -1 AS site_visit_id
          , visit_id
          , site_id
          , visit_start_time
          , visitor_id
          , party_id
          , num_page_views
          , site_visit_duration
          , total_carts_created
          , total_orders_created
          , total_web_registrations
          , total_order_inquiries
          , total_payment_inquiries
          , total_invoice_inquiries
          , total_opt_outs
          , user_id
          , visitant_id
          , campaign_source_code_id
          , DECODE (INSTR (innerquery.visitant_id, 'p', 1, 1),
                                 0, DECODE ((SELECT COUNT (site_visit_id)
				                                     FROM ibw_site_visits
                                             WHERE visitor_id = innerquery.visitor_id
                                             AND visit_id <> innerquery.visit_id
                                             AND visit_start_time < innerquery.visit_start_time
                                             AND ROWNUM = 1
                                             )
                                             ,0, DECODE ((SELECT COUNT (rec_id)
                                                          FROM ibw_page_views_tmp
                                                          WHERE visitor_id = innerquery.visitor_id
                                                          AND visit_id <> innerquery.visit_id
                                                          AND page_view_start_time < innerquery.visit_start_time
                                                          AND ROWNUM = 1
                                                          )
                                                          ,0, NULL
                                                          , 'Y'
                                                          )
                                              , 'Y'),
                                 DECODE ((SELECT COUNT (site_visit_id)
                                          FROM ibw_site_visits
                                          WHERE party_id = innerquery.party_id
                                          AND visit_id <> innerquery.visit_id
                                          AND visit_start_time < innerquery.visit_start_time
                                          AND ROWNUM = 1
                                          )
                                          ,0, DECODE ((SELECT COUNT (rec_id)
                                                       FROM ibw_page_views_tmp
                                                       WHERE party_id = innerquery.party_id
                                                       AND visit_id <> innerquery.visit_id
                                                       AND page_view_start_time < innerquery.visit_start_time
                                                       AND ROWNUM = 1
                                                       )
                                                       ,0, NULL
                                                       , 'Y'
                                                       )
                                          , 'Y'
                                          )
                    ) as repeat_visit_flag
          , NVL((SELECT type_id
                 FROM (SELECT patterns.type_id
	                            ,VISIT_ID, patterns.program_id   ,patterns.url_pattern  ,patterns.creation_date
	                     FROM ibw_url_patterns_b patterns
		                        ,(SELECT upper(pv.referral_url)  URL ,VISIT_ID
                               FROM ibw_page_views_tmp pv
                               WHERE pv.page_view_seq_num = 1
			                         AND process_flag is null
                               ) PV
                       WHERE patterns.TYPE = 'R'
                       AND  PV.URL LIKE
                                   upper(patterns.url_pattern || '%')
                        ORDER BY program_id desc
                               ,length(url_pattern) desc
                               ,creation_date desc
                        )
                 WHERE visit_id = innerquery.visit_id
                 AND ROWNUM =1
	              )
               ,-1) as referral_category_id
       FROM (SELECT pv.visit_id
     , pv.site_id
     , MIN ( pv.page_view_start_time ) visit_start_time
     , pv.user_id AS user_id
     , pv.visitor_id
     , pv.party_id
     , pv.visitant_id
     , pv.campaign_source_code_id
     , COUNT ( DECODE ( pv.evnt_type
                      , l_optout_code, 1
                      , NULL
                      )) AS total_opt_outs
     , COUNT ( pv.rec_id ) num_page_views
     , SUM ( pv.page_view_duration ) site_visit_duration
     , COUNT ( DECODE ( pv.evnt_type
                      , l_cart_code , 1
                      , NULL
                      )) total_carts_created
     , COUNT ( DECODE ( pv.evnt_type
                      ,  l_order_code, 1
                      , NULL
                      )) total_orders_created
     , COUNT ( DECODE ( pv.evnt_type
                      , l_userreg_code, 1
                      , NULL
                      )) total_web_registrations
     , COUNT ( DECODE ( pv.evnt_type
                      , l_ordinq_code, 1
                      , NULL
                      )) total_order_inquiries
     , COUNT ( DECODE ( pv.evnt_type
                      ,  l_payinq_code, 1
                      , NULL
                      )) total_payment_inquiries
     , COUNT ( DECODE ( pv.evnt_type
                      ,  l_invinq_code , 1
                      , NULL
                      )) total_invoice_inquiries
  FROM ibw_page_views_tmp pv
 WHERE pv.page_id NOT IN ( -1, -2 )
   AND pv.page_id IS NOT NULL
   AND exists (SELECT 'x'
               FROM ibw_page_views_tmp tmp
	       WHERE process_flag is null
		AND tmp.visit_id=pv.visit_id)
  GROUP BY pv.visit_id
          ,pv.site_id
          ,pv.visitor_id
          ,pv.party_id
          ,pv.VISITANT_ID
          ,pv.user_id
          ,pv.campaign_source_code_id)  innerquery) tmp
ON         (    sv.site_id = tmp.site_id
            AND sv.visit_id = tmp.visit_id )
WHEN MATCHED THEN
     UPDATE
        SET sv.num_page_views = tmp.num_page_views
          , sv.site_visit_duration = tmp.site_visit_duration
          , sv.total_carts_created = tmp.total_carts_created
          , sv.total_orders_created = tmp.total_orders_created
          , sv.total_web_registrations = tmp.total_web_registrations
          , sv.total_order_inquiries = tmp.total_order_inquiries
          , sv.total_payment_inquiries = tmp.total_payment_inquiries
          , sv.total_invoice_inquiries = tmp.total_invoice_inquiries
          , sv.total_opt_outs = tmp.total_opt_outs
          , sv.last_update_date = SYSDATE
          , sv.last_updated_by = fnd_global.user_id
          , sv.repeat_visit_flag = tmp.repeat_visit_flag
          , sv.referral_category_id = tmp.referral_category_id
          , sv.user_id = tmp.user_id, sv.party_id = tmp.party_id
          , sv.visitant_id = tmp.visitant_id
          , sv.campaign_source_code_id = tmp.campaign_source_code_id
WHEN NOT MATCHED THEN
     INSERT ( site_visit_id, visit_id, site_id, visit_start_time, visitor_id
            , referral_category_id, party_id, num_page_views
            , site_visit_duration, total_carts_created, total_orders_created
            , total_web_registrations, total_order_inquiries
            , total_payment_inquiries, total_invoice_inquiries
            , total_opt_outs, user_id, visitant_id, campaign_source_code_id
            , repeat_visit_flag, created_by, creation_date, last_updated_by
            , last_update_date, object_version_number )
     VALUES ( ibw_site_visits_s1.NEXTVAL, tmp.visit_id, tmp.site_id
            , tmp.visit_start_time, tmp.visitor_id, tmp.referral_category_id
            , tmp.party_id, tmp.num_page_views, tmp.site_visit_duration
            , tmp.total_carts_created, tmp.total_orders_created
            , tmp.total_web_registrations, tmp.total_order_inquiries
            , tmp.total_payment_inquiries, tmp.total_invoice_inquiries
            , tmp.total_opt_outs, tmp.user_id, tmp.visitant_id
            , tmp.campaign_source_code_id, tmp.repeat_visit_flag
            , fnd_global.user_id, SYSDATE, fnd_global.user_id, SYSDATE, 1 );






	-- get visit count for logging output
printLog('Get visit count for logging output');

SELECT COUNT(distinct(visit_id))
INTO l_visit_count
FROM ibw_site_visits
WHERE creation_date > l_start_time;



-- mark PAT records for purging
printLog('Mark PAT records for purging');

SELECT MAX(last_update_date)
INTO l_pat_date
FROM ibw_page_views_tmp;


printLog('Got Pat date from Tmp'||l_pat_date);

IF l_pat_date IS NULL THEN
SELECT MAX(last_update_date)
INTO l_pat_date
FROM ibw_page_views;

printLog('Got Pat date from page views'||l_pat_date);
END IF;

IF l_pat_date IS NULL THEN
SELECT Min(last_update_date)
INTO l_pat_date
FROM jtf_pf_wa_info_vl;
printLog('Got Pat date from Pat'||l_pat_date);
END IF;

IF l_pat_date IS NOT NULL THEN
  jtf_pf_conv_pkg.MIGRATED_DATA(2,l_pat_date);
  jtf_pf_conv_pkg.MIGRATED_DATA(3,l_pat_date);
  jtf_pf_conv_pkg.MIGRATED_DATA(4,l_pat_date);

END IF;


-- Calling context configuration table population progrma
printLog('Calling context configuration table population program');

  CONTEXT_LOAD;
 	--log messages for invalid sites AND business contexts


printOutput('Messages for Invalid External Sites:');
printOutput('====================================');
FOR page_view IN tmp_page_views_cache(3)
LOOP
  retcode := 1;
  fnd_message.set_name('IBW','IBW_OE_NO_SITE_FOUND');
  fnd_message.set_token('PAGE_URL',page_view.tracked_page_url);
  l_message_text := fnd_message.get;
  printOutput(l_message_text);
END LOOP;


printOutput('Missing page context identifiers:');
printOutput('============================');
FOR page_view IN tmp_page_views_cache(7)
LOOP
  retcode := 1;
  fnd_message.set_name('IBW','IBW_OE_INVALID_CTX_ID');
  l_page_id :=  page_view.page_id;
  SELECT pages_tl.page_name
  INTO l_page_name
  FROM ibw_pages_tl pages_tl
  WHERE pages_tl.page_id = l_page_id
  AND language = userenv('LANG');
  fnd_message.set_token('PAGE_NAME',l_page_name);
  fnd_message.set_token('CONTEXT_ID',page_view.business_context_value);
  l_message_text := fnd_message.get;
  printOutput(l_message_text);
END LOOP;


printOutput('Page Views Invalid page context information');
printOutput('=================================');
FOR page_view IN tmp_page_views_cache(6)
LOOP
  retcode := 1;
  fnd_message.set_name('IBW','IBW_OE_CTX_ID_NOT_FOUND');
  l_page_id :=  page_view.page_id;
  BEGIN
  SELECT pages_tl.page_name
  INTO l_page_name
  FROM ibw_pages_tl pages_tl
  WHERE pages_tl.page_id = l_page_id
  AND language = userenv('LANG');
  EXCEPTION
  WHEN OTHERS THEN
    l_page_name := page_view.tracked_page_url;
  END;
  fnd_message.set_token('PAGE_NAME',l_page_name);
  l_message_text := fnd_message.get;
  printOutput(l_message_text);
END LOOP;

printOutput('Inactive pages for which Page Views are tracked');
printOutput('===============================================');

FOR page_view IN inactive_pages
LOOP
  retcode := 1;
  fnd_message.set_name('IBW','IBW_OE_INACTIVEPAGE_MATCH');
  l_page_id :=  page_view.page_id;
  SELECT pages_tl.page_name
  INTO l_page_name
  FROM ibw_pages_tl pages_tl
  WHERE pages_tl.page_id = l_page_id
  AND language = userenv('LANG');
  fnd_message.set_token('PAGE_NAME',l_page_name);
  l_message_text := fnd_message.get;
  printOutput(l_message_text);
END LOOP;


-- Remove all page views to be ignored
DELETE FROM ibw_page_views_tmp
WHERE process_flag in (4,3,6,7) or process_flag is null;




printOutput('Fact Population Program Output:');
printOutput('===============================');

FND_MESSAGE.SET_NAME('IBW','IBW_OE_OUTPUT_NUM_PG_VIEWS');
FND_MESSAGE.SET_TOKEN('NUM_PAGE_VIEWS',l_page_view_count);
l_message_text := fnd_message.get;
printOutput(l_message_text);

FND_MESSAGE.SET_NAME('IBW','IBW_OE_OUTPUT_NUM_SITE_VISITS');
FND_MESSAGE.SET_TOKEN('NUM_VISITS',l_visit_count);
l_message_text := fnd_message.get;
printOutput(l_message_text);


printLog('Done with  Fact Population Concurrent Program');
errbuf := 'SUCCESS';

EXCEPTION
WHEN OTHERS THEN
  printOutput('Exception :'||sqlerrm);
  retcode := 2;
   errbuf := ' errbuf' || ' '||SQLCODE||'-'||SQLERRM;
END offline_engine;

-- ===========================================================
--  Procedure printLog uses FND_FILE.PUT_LINE  to write in the
--  "log" file of a concurrent program
-- ===========================================================
PROCEDURE printLog(p_message IN VARCHAR2)
IS
pragma AUTONOMOUS_TRANSACTION;
BEGIN
  FND_FILE.PUT_LINE(FND_FILE.LOG,p_message);
  commit;
EXCEPTION
WHEN OTHERS THEN
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception :'||sqlerrm);
END printLog;

-- ===========================================================
--  Procedure printOutput uses FND_FILE.PUT_LINE  to write in the
--  "Output" file of a concurrent program
-- ===========================================================
PROCEDURE printOutput(p_message IN VARCHAR2)
IS
pragma AUTONOMOUS_TRANSACTION;
BEGIN
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,p_message);
  printLog(p_message);
  commit;
EXCEPTION
WHEN OTHERS THEN
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception :'||sqlerrm);
END printOutput;


--=================================================================================
-- PROCEDURE :createpage		PUBLIC
-- PARAMETERS: pagecode			Page code for the page to be created
--           : pagename			Page name for the page to be created
--           : URL			Page view URL forthe page to be created
--           : appctx			Application context for the page to be created
--           : bizctx			Business Context for the page to be created
--           : pageid			Out variable to hold the page id
-- COMMENT   : Procedure checks IF a page exists for a given page view
--            AND created a page IF necessary
--===============================================================================


PROCEDURE createpage (
  pagecode  IN  VARCHAR2
  ,pagename IN  VARCHAR2
  ,url      IN  VARCHAR2
  ,appctx   IN  VARCHAR2
  ,bizctx   IN  VARCHAR2
  ,pageid   OUT  NOCOPY NUMBER
)
IS
x_page_id   NUMBER (30);
l_rec_count   NUMBER (30);
l_error_message VARCHAR2(240);
l_template_access_name ibe_dsp_attachments_v.access_name%type;
l_template_description ibe_dsp_attachments_v.description%type;
l_template_name jtf_amv_items_vl.item_name%type;
l_appctx VARCHAR2(30);
l_url VARCHAR2(3000);
BEGIN
--find IF page matches AND then create page
l_appctx := appctx;
l_template_description := NULL;
IF l_appctx = 'I' THEN


  BEGIN                            --Changed by Venky. Added code to handle no_data_found exception
    SELECT dsp.access_name,item.item_name,dsp.description
    INTO  l_template_access_name ,l_template_name,l_template_description
    FROM ibe_dsp_attachments_v dsp,jtf_amv_items_vl item
    WHERE UPPER(url) LIKE '%/' || UPPER(file_name) || '%'             --Changed by Venky
    AND item.item_id = dsp.logical_id
    AND ROWNUM = 1;

    BEGIN                    --Changed by Venky. Added code to handle no_data_found exception
      SELECT page_id
      INTO pageid
      FROM ibw_pages_b pages
      WHERE pages.page_matching_criteria =
          NVL2(l_template_access_name
              ,'R'
              ,DECODE (pagecode,
                 NULL, DECODE (pagename,
                           NULL, 'U'
           ,'N'
           )
                      ,'C'
                    )
            )
      AND UPPER(pages.page_matching_value) =
          UPPER(NVL(l_template_access_name,
            NVL(pagecode,
                NVL(pagename,
                    SUBSTR (url
                ,1
          ,DECODE(INSTR (url, '?', 1, 1) - 1
                  ,-1,LENGTH(url)
            ,INSTR (url, '?', 1, 1) - 1
            )
                            )
                    )
                )
            ));

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
  END;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_template_access_name := NULL;
      l_template_name := NULL;
      l_appctx := 'E';
      l_rec_count := 0 ;
 END;

ELSIF l_appctx = 'E'
THEN
  l_appctx := 'N';

      BEGIN                             --Changed by Venky. Added code to handle no_data_found exception
	SELECT page_id
        INTO pageid
        FROM ibw_pages_b pages
	WHERE pages.page_matching_criteria =
                DECODE (pagecode,
                        NULL, DECODE (pagename,
                                      NULL, 'U',
                                      'N'
                                     ),
                        'C'
                       )
         AND UPPER(pages.page_matching_value) =
                UPPER(DECODE (pagecode,
                        NULL, DECODE (pagename,
                                      NULL, SUBSTR (url,
                                                    1,
                                                    DECODE (INSTR (url, '?',
                                                                   1),
                                                            0, LENGTH (url),
                                                              INSTR (url,
                                                                     '?',
                                                                     1
                                                                    )
                                                            - 1
                                                           )
                                                   ),
                                      pagename
                                     ),
                        pagecode
                       ));
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           pageid := 0;
     END;
   END IF;

   IF pageid = 0
   THEN
      IF l_appctx = 'I'
      THEN

		l_appctx := 'T';
		ibw_pages_pvt.INSERT_row (x_page_id,
					l_template_name,
          l_template_description,
					FND_API.G_MISS_CHAR,
					l_appctx,
					bizctx,
					l_template_name,
					'R',
					l_template_access_name,
					l_error_message);
		pageid := x_page_id;
         ELSE
         IF pagecode is NULL
         THEN
            IF pagename is NULL
            THEN
              SELECT SUBSTR (url,
                                                    1,
                                                    DECODE (INSTR (url, '?',
                                                                   1),
                                                            0, LENGTH (url),
                                                              INSTR (url,
                                                                     '?',
                                                                     1
                                                                    )
                                                            - 1
                                                           )
                                                   )
              INTO l_url FROM DUAL;
               ibw_pages_pvt.INSERT_row (x_page_id,
					l_url,
          l_template_description,
					FND_API.G_MISS_CHAR,
                                       l_appctx,
                                       bizctx,
                                       url,
                                       'U',
                                       l_url,
									   l_error_message
                                      );
            ELSE
               ibw_pages_pvt.INSERT_row (x_page_id,
			   						   pagename,
                       l_template_description,
									   FND_API.G_MISS_CHAR,
                                       l_appctx,
                                       bizctx,
                                       url,
                                       'N',
                                       pagename,
									   l_error_message
                                      );
            END IF;
         ELSE
		ibw_pages_pvt.INSERT_row (x_page_id,
					pagecode,
          l_template_description,
					pagecode,
					l_appctx,
					bizctx,
					url,
					'C',
					pagecode,
					l_error_message
					);
         END IF;
		 		 pageid := x_page_id;
      END IF;
	  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Page created page id ' || pageid);
	  IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	    fnd_message.set_name('IBW','IBW_OE_PAGE_NOT_FOUND');
        fnd_message.set_token('PAGE_NAME',pagename);
        fnd_log.string(FND_LOG.LEVEL_EVENT,'IBW.PLSQL.IBWOE_PVT',fnd_message.get);
        fnd_file.put_line(fnd_file.log,fnd_message.get);
	  END IF;
   END IF;
  pageid := pageid;
IF pageid is null then
  RAISE no_data_found;
END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  pageid := -1;
WHEN OTHERS THEN
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception :'||sqlerrm);
  pageid := -1;
END createpage;




--========================================================================
-- PROCEDURE : recategorize_referrals	PUBLIC
-- PARAMETERS: errbuf			Error Buffer for Concurrent Program asset value
--           : retcode			Return Code for Concurrent Program
-- COMMENT   : This procedure re populates all referral categories into the site visits table
--========================================================================

Procedure recategorize_referrals(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY NUMBER)
is
Begin


   printLog('Starting Referral Category Concurrent Program');

UPDATE ibw_site_visits tmp
SET tmp.referral_category_id =
    NVL((SELECT type_id
         FROM (SELECT patterns.type_id
	                   ,VISIT_ID, patterns.program_id   ,patterns.url_pattern  ,patterns.creation_date
				    FROM ibw_url_patterns_b patterns
				            ,(SELECT upper(pv.referral_url)  URL ,VISIT_ID
						  FROM ibw_page_views_tmp pv
						  WHERE pv.page_view_seq_num = 1
						           AND process_flag is null
						  ) PV
				   WHERE patterns.TYPE = 'R'
				   AND  PV.URL LIKE
                                   upper(patterns.url_pattern || '%')
                        ORDER BY program_id desc
                               ,length(url_pattern) desc
                               ,creation_date desc
                        )
                 WHERE visit_id = tmp.visit_id
                 AND ROWNUM =1
                   )
               ,-1)
   WHERE  tmp.last_update_date >
                  ( SELECT patterns.last_update_date
                 FROM ibw_url_patterns_b patterns
                 WHERE patterns.TYPE = 'R'
                   AND patterns.type_id = tmp.referral_category_id );




printLog('Done Referral Category Concurrent Program');
printOutput('Recategorization of Referrals successful');
EXCEPTION
WHEN OTHERS THEN
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception :'||sqlerrm);
  retcode := 2;
END recategorize_referrals;

--------------------------------------------------------------------------------------------------
-- This procedure populates all the data required for IBW_CONTEXT_INTERFACE_B/TL table
--
--                      PROCEDURE  CONTEXT_LOAD
--------------------------------------------------------------------------------------------------

PROCEDURE CONTEXT_LOAD
IS
    l_user_id                 NUMBER := FND_GLOBAL.USER_ID();
    l_business_context        VARCHAR2(30);
    x_return_status           VARCHAR2(30);
    l_last_update_login       NUMBER;
    l_program_id              NUMBER;
    l_program_login_id        NUMBER;
    l_program_app_id          NUMBER;
    l_request_id              NUMBER;

        -- This cursor holds business_context for record with 'NONE' AS the business context
        CURSOR bus_ctx_cur IS  SELECT business_context
                   FROM ibw_context_interface_vl
                  WHERE context_instance_value = -999;

BEGIN
   FND_PROFILE.GET('LOGIN_ID', l_last_update_login);
     FND_PROFILE.GET('CONC_PROGRAM_ID', l_program_id);
     FND_PROFILE.GET('CONC_LOGIN_ID', l_program_login_id);
     FND_PROFILE.GET('CONC_PROGRAM_APPLICATION_ID', l_program_app_id);
     FND_PROFILE.GET('CONC_REQUEST_ID', l_request_id);

       begin

       OPEN bus_ctx_cur;
        FETCH bus_ctx_cur INTO l_business_context;
        CLOSE bus_ctx_cur;
      -- Checking whether No Context record exists.

      IF (l_business_context IS NULL) THEN
      -- Inserting record with 'NONE' AS the business context
      INSERT INTO ibw_context_interface_b cont
             (
              cont.context_interface_id
             ,cont.context_instance_value
             ,cont.context_instance_code
             ,cont.business_context
             ,cont.object_version_number
             ,cont.created_by
             ,cont.creation_date
             ,cont.last_updated_by
             ,cont.last_update_date
             ,cont.last_update_login,cont.program_id,cont.program_login_id,cont.program_application_id,cont.request_id )
       VALUES
             (ibw_context_interface_b_s1.nextval
             ,-999
             ,NULL
             ,'NONE',1,l_user_id,SYSDATE,l_user_id,SYSDATE,l_last_update_login,l_program_id,l_program_login_id,l_program_app_id,l_request_id);

      -- Inserting record with 'NONE' AS the business context IN TL Table

      INSERT INTO ibw_context_interface_tl cont_tl
            ( context_interface_id
             ,language
             ,context_instance_name
             ,source_lang
             ,object_version_number
             ,created_by
             ,creation_date
             ,last_updated_by
             ,last_update_date
             ,last_update_login
             ,program_id
             ,program_login_id
             ,program_application_id
             ,request_id  )
    SELECT        cont.context_interface_id context_interface_id
             ,lang.language_code        language
             ,lookup.meaning            context_instance_name
             ,USERENV('LANG')           source_lang
             ,1				object_version_number
             ,l_user_id 		created_by
             ,SYSDATE			creation_date
             ,l_user_id 		last_updated_by
             ,SYSDATE			last_update_date
             ,l_last_update_login 	last_update_login
             ,l_program_id		program_id
             ,l_program_login_id	program_login_id
             ,l_program_app_id		program_application_id
             ,l_request_id		request_id
      FROM ibw_context_interface_b cont
           ,fnd_languages lang
	   ,fnd_lookup_values lookup
      WHERE cont.context_instance_value = -999
	    and lookup.lookup_type = 'IBW_BUSINESS_CONTEXT'
	    and lookup.lookup_code = 'NONE'
	    and lookup.LANGUAGE = lang.LANGUAGE_CODE
        AND lang.installed_flag in ('B','I');

      END IF;
      COMMIT;

   EXCEPTION
      WHEN OTHERS THEN
      ROLLBACK;
      --dbms_output.put_line('CONTEXT_LOAD:' || sqlerrm);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception in Context Load Program  - NONE Context :' || sqlerrm);
	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Context Load Program Return Status: - NONE Context' ||  x_return_status );
      END;


    -- For populating the IBW_CONTEXT_INTERFACE_B table with the Section related data

begin
    MERGE INTO ibw_context_interface_b  cont
    USING (SELECT page.business_context
                 ,sect.section_id
                 ,sect.access_name
             FROM ibw_page_instances   page
             -- To get the section related information for all the pages that have been tracked by web analytics.
                 ,ibe_dsp_sections_vl  sect
             -- To get the sections related information FROM this iStore view
            WHERE page.business_context       = 'SECTION'
            -- Required AS we are taking into account pages with context of 'SECTION' other contexts eg 'PRODUCT' are hANDled separately
              AND page.business_context_value =  sect.section_id
	       group by
		  page.business_context
                 ,sect.section_id
                 ,sect.access_name
          ) pagesect
            ON(
                    cont.context_instance_value = pagesect.section_id
                AND cont.business_context       = pagesect.business_context
              )
       WHEN MATCHED THEN
        UPDATE
           SET  cont.context_instance_code  = pagesect.access_name
               ,cont.last_updated_by        = l_user_id
               ,cont.last_update_date       = SYSDATE
               ,cont.object_version_number  = cont.object_version_number + 1
               ,cont.last_update_login      = l_last_update_login
               ,cont.program_id             = l_program_id
               ,cont.program_login_id       = l_program_login_id
               ,cont.program_application_id = l_program_app_id
               ,cont.request_id             = l_request_id
       WHEN NOT MATCHED THEN
          INSERT(
                 cont.context_interface_id
                ,cont.context_instance_value
                ,cont.context_instance_code
                ,cont.business_context
                ,cont.object_version_number
                ,cont.created_by
                ,cont.creation_date
                ,cont.last_updated_by
                ,cont.last_update_date
                ,cont.last_update_login
                ,cont.program_id
                ,cont.program_login_id
                ,cont.program_application_id
                ,cont.request_id)
          VALUES(
                 IBW_CONTEXT_INTERFACE_B_S1.nextval
                ,pagesect.section_id
                ,pagesect.access_name
                ,pagesect.business_context
                ,1
                ,l_user_id
                ,SYSDATE
                ,l_user_id
                ,SYSDATE
                ,l_last_update_login
                ,l_program_id
                ,l_program_login_id
                ,l_program_app_id
                ,l_request_id);
EXCEPTION

   WHEN OTHERS THEN
        ROLLBACK;
     --dbms_output.put_line('CONTEXT_LOAD:' || sqlerrm);
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception in Context Load Program-Merge of ibw_context_interface_b :' || sqlerrm);
	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Context Load Program Return Status 1:' ||  x_return_status );

end;

   -- For populating the IBW_CONTEXT_INTERFACE_TL table

   -- Here the Primary Key is combination of context_interface_id (FROM ibw_context_interface_b) AND language column

  begin
  MERGE INTO ibw_context_interface_tl  cont_tl
    USING (SELECT
                  cont.context_interface_id   context_interface_id         /* Changed the query for Performance Bug No 4777097 */
                  ,sect.display_name          context_instance_name        /* SQLID: 14752675. Removed FND_LANGUAGES table from the */
                  ,sect.language              language                     /* query thereby avoiding MERGE CARTESIAN JOIN */
                  ,USERENV('LANG')            source_lang                  /* Chamge by gjothiku */
            FROM
                    ibe_dsp_sections_tl       sect
                    ,ibw_context_interface_b  cont
            WHERE
                    cont.context_instance_value = sect.section_id
          ) conttl
            ON(
                   cont_tl.context_interface_id = conttl.context_interface_id
              AND  cont_tl.language             = conttl.language
              )
       WHEN MATCHED THEN
        UPDATE
           SET cont_tl.context_instance_name  = conttl.context_instance_name
              ,cont_tl.last_updated_by        = l_user_id
              ,cont_tl.last_update_date       = SYSDATE
              ,cont_tl.object_version_number  = cont_tl.object_version_number + 1
              ,cont_tl.last_update_login      = l_last_update_login
              ,cont_tl.program_id             = l_program_id
              ,cont_tl.program_login_id       = l_program_login_id
              ,cont_tl.program_application_id = l_program_app_id
              ,cont_tl.request_id             = l_request_id
       WHEN NOT MATCHED THEN
          INSERT(
                 cont_tl.context_interface_id
                ,cont_tl.language
                ,cont_tl.context_instance_name
                ,cont_tl.source_lang
                ,cont_tl.object_version_number
                ,cont_tl.created_by
                ,cont_tl.creation_date
                ,cont_tl.last_updated_by
                ,cont_tl.last_update_date
                ,cont_tl.last_update_login
                ,cont_tl.program_id
                ,cont_tl.program_login_id
                ,cont_tl.program_application_id
                ,cont_tl.request_id
                 )
          VALUES(
                 conttl.context_interface_id
                ,conttl.language
                ,conttl.context_instance_name
                ,conttl.source_lang
                ,1
                ,l_user_id
                ,SYSDATE
                ,l_user_id
                ,SYSDATE
                ,l_last_update_login  ,l_program_id,l_program_login_id ,l_program_app_id  ,l_request_id
                 );

EXCEPTION

   WHEN OTHERS THEN
        ROLLBACK;
     --dbms_output.put_line('CONTEXT_LOAD:' || sqlerrm);
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception in Context Load Program -Merge of ibw_context_interface_tl :' || sqlerrm);
	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Context Load Program Return Status 2:' ||  x_return_status );
end;
  COMMIT;

EXCEPTION

   WHEN OTHERS THEN
        ROLLBACK;
     --dbms_output.put_line('CONTEXT_LOAD:' || sqlerrm);
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception in Context Load Program :' || sqlerrm);
	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Context Load Program Return Status:' ||  x_return_status );
END CONTEXT_LOAD;

END IBW_OE_PVT;

/
