--------------------------------------------------------
--  DDL for Package Body IGI_IAC_SUBMIT_RXI_ASSET_BAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_SUBMIT_RXI_ASSET_BAL" AS
--  $Header: igiiaxab.pls 120.1.12000000.1 2007/08/01 16:19:52 npandya noship $

--===========================FND_LOG.START=====================================

g_state_level NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	     :=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	     :=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	     :=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(100)  := 'IGI.PLSQL.igiiaxab.igi_iac_submit_rxi_asset_bal.';

--===========================FND_LOG.END=======================================

  /****** Start Forward Declarations *****
!!!!THIS IS NO LONGER USED _ SEE COMMENTS AT END OF PROGRAM!!!!!!!
  FUNCTION publish_report ( p_parent_req_id in NUMBER
                           ,p_report_id in VARCHAR2
                           ,p_attrib_set in VARCHAR2
                           ,p_out_format in VARCHAR2)
  RETURN NUMBER;

  ****** End Forward Declarations *****/


  PROCEDURE submit_report ( errbuf   OUT NOCOPY       VARCHAR2
			    ,retcode  OUT NOCOPY       NUMBER
			    ,p_request_type            VARCHAR2
			    ,p_app_name                VARCHAR2
			    ,p_report_name_1           VARCHAR2 DEFAULT NULL
			    ,p_report_id_1             NUMBER
			    ,p_rep1_attrib_set         VARCHAR2 DEFAULT NULL
                            ,p_report_name_2           VARCHAR2 DEFAULT NULL
                            ,p_report_id_2             VARCHAR2
                            ,p_rep2_attrib_set         VARCHAR2 DEFAULT NULL
			    ,p_report_name_3           VARCHAR2 DEFAULT NULL
			    ,p_report_id_3             NUMBER
			    ,p_rep3_attrib_set         VARCHAR2 DEFAULT NULL
			    ,p_report_name_4           VARCHAR2 DEFAULT NULL
			    ,p_report_id_4             NUMBER
			    ,p_rep4_attrib_set         VARCHAR2 DEFAULT NULL
			    ,p_report_name_5           VARCHAR2 DEFAULT NULL
			    ,p_report_id_5             NUMBER
			    ,p_rep5_attrib_set         VARCHAR2 DEFAULT NULL
                            ,p_report_name_6           VARCHAR2 DEFAULT NULL
                            ,p_report_id_6             VARCHAR2
                            ,p_rep6_attrib_set         VARCHAR2 DEFAULT NULL
			    ,p_report_name_7           VARCHAR2 DEFAULT NULL
			    ,p_report_id_7             NUMBER
			    ,p_rep7_attrib_set         VARCHAR2 DEFAULT NULL
			    ,p_report_name_8           VARCHAR2 DEFAULT NULL
			    ,p_report_id_8             NUMBER
			    ,p_rep8_attrib_set         VARCHAR2 DEFAULT NULL
                            ,p_out_format              VARCHAR2
                            ,p_book_type_code          VARCHAR2
                            ,p_period_ctr           VARCHAR2
                            ,p_cat_struct_id           VARCHAR2
                            ,p_cat_id                  VARCHAR2
                            ,p_chart_of_acct           VARCHAR2 DEFAULT NULL
                            --,p_from_company            VARCHAR2 -- No longer required!!
                            --,p_to_company              VARCHAR2 -- No longer required!!
                            ,p_from_cost_center        VARCHAR2 DEFAULT NULL
                            ,p_to_cost_center          VARCHAR2 DEFAULT NULL
                            ,p_from_asset              VARCHAR2 DEFAULT NULL
                            ,p_to_asset                VARCHAR2 DEFAULT NULL)
  IS

  CURSOR c_get_report_desc (p_rep_short_name VARCHAR2) IS
    SELECT user_concurrent_program_name
    FROM fnd_concurrent_programs_vl
    WHERE application_id = 8400
    AND concurrent_program_name = p_rep_short_name;

    l_report_request_id    NUMBER ;
    l_publish_req          NUMBER;
    l_report_desc          VARCHAR2(240);
    l_ret  BOOLEAN;

    l_path varchar2(150) := g_path||'submit_report';
  BEGIN

--fa_rx_util_pkg.enable_debug; -- Does not fit within debug code standards!!!


      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_report_name_1 ' || p_report_name_1);
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_report_id_1 ' || p_report_id_1);
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_rep1_attrib_set ' || p_rep1_attrib_set);
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_report_name_2 ' || p_report_name_2);
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_report_id_2 ' || p_report_id_2);
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_rep2_attrib_set ' || p_rep2_attrib_set);
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_report_name_3 ' || p_report_name_3);
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_report_id_3 ' || p_report_id_3);
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_rep3_attrib_set ' || p_rep3_attrib_set);
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_report_name_4 ' || p_report_name_4);
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_report_id_4 ' || p_report_id_4);
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_rep4_attrib_set ' || p_rep4_attrib_set);
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_report_name_5 ' || p_report_name_5);
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_report_id_5 ' || p_report_id_5);
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_rep5_attrib_set ' || p_rep5_attrib_set);
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_report_name_6 ' || p_report_name_6);
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_report_id_6 ' || p_report_id_6);
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_rep6_attrib_set ' || p_rep6_attrib_set);
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_report_name_7 ' || p_report_name_7);
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_report_id_7 ' || p_report_id_7);
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_rep7_attrib_set ' || p_rep7_attrib_set);
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_report_name_8 ' || p_report_name_8);
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_report_id_8 ' || p_report_id_8);
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_rep8_attrib_set ' || p_rep8_attrib_set);


    -- ****** Start the first report *****
    IF p_report_id_1 IS NOT NULL THEN

      OPEN c_get_report_desc (p_report_name_1);
      FETCH c_get_report_desc INTO l_report_desc;

      IF (c_get_report_desc%NOTFOUND) THEN
        l_report_desc := p_report_name_1; -- Forget it - use report short name instead!!
      END IF;
      CLOSE c_get_report_desc;

--fa_rx_util_pkg.debug('fa_rx_util_pkg1'); -- Does not fit within debug code standards!!!


      igi_iac_debug_pkg.debug_other_string(g_event_level,l_path,'Asset Balance Report "'
                       || l_report_desc || '"');
      igi_iac_debug_pkg.debug_other_string(g_event_level,l_path,'has been Submitted .... ');

      l_report_request_id := FND_REQUEST.SUBMIT_REQUEST
				( 'IGI'
				, 'IGIIARIQ'
				, null
				, SYSDATE
				, FALSE         -- Is a sub request
				,p_request_type
				,p_app_name
				,p_report_name_1
				,p_report_id_1
				,p_rep1_attrib_set
				,p_out_format
				,p_report_name_1
				,p_book_type_code
				,p_period_ctr
				,p_cat_struct_id
				,p_cat_id
				,p_chart_of_acct
				--,p_from_company
				--,p_to_company
				,p_from_cost_center
				,p_to_cost_center
				,p_from_asset
				,p_to_asset
				);

      IF l_report_request_id = 0 THEN
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Warning: Asset Balance Report "'
                           || l_report_desc || '"');
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'did not complete ');

      ELSE
        COMMIT;
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Asset Balance Report "' ||
                           l_report_desc || '"');
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path, '" is available at "Request ID" ' ||
                           l_report_request_id);

      END IF;
      l_report_request_id := 0;
    END IF;


    -- ****** Start the second report *****
    IF p_report_id_2 IS NOT NULL THEN

      OPEN c_get_report_desc (p_report_name_2);
      FETCH c_get_report_desc INTO l_report_desc;

      IF (c_get_report_desc%NOTFOUND) THEN
        l_report_desc := p_report_name_2; -- Forget it - use report short name instead!!
      END IF;
      CLOSE c_get_report_desc;

      igi_iac_debug_pkg.debug_other_string(g_event_level,l_path,'Asset Balance Report "'
                       || l_report_desc || '"');
      igi_iac_debug_pkg.debug_other_string(g_event_level,l_path,'has been Submitted .... ');

      l_report_request_id := FND_REQUEST.SUBMIT_REQUEST
				( 'IGI'
				, 'IGIIARIQ'
				, null
				, SYSDATE
				, FALSE         -- Is a sub request
				,p_request_type
				,p_app_name
				,p_report_name_2
				,p_report_id_2
				,p_rep2_attrib_set
				,p_out_format
				,p_report_name_2
				,p_book_type_code
				,p_period_ctr
				,p_cat_struct_id
				,p_cat_id
				,p_chart_of_acct
				--,p_from_company
				--,p_to_company
				,p_from_cost_center
				,p_to_cost_center
				,p_from_asset
				,p_to_asset
				);

      IF l_report_request_id = 0 THEN
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Warning: Asset Balance Report "'
                           || l_report_desc || '"');
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'did not complete ');
      ELSE
        COMMIT;
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Asset Balance Report "' ||
                           l_report_desc || '"');
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'" is available at "Request ID" ' ||
                           l_report_request_id);

      END IF;
      l_report_request_id := 0;
    END IF;


    -- ****** Start the third report *****
    IF p_report_id_3 IS NOT NULL THEN

      OPEN c_get_report_desc (p_report_name_3);
      FETCH c_get_report_desc INTO l_report_desc;

      IF (c_get_report_desc%NOTFOUND) THEN
        l_report_desc := p_report_name_3; -- Forget it - use report short name instead!!
      END IF;
      CLOSE c_get_report_desc;

      igi_iac_debug_pkg.debug_other_string(g_event_level,l_path,'Asset Balance Report "'
                       || l_report_desc || '"');
      igi_iac_debug_pkg.debug_other_string(g_event_level,l_path,'has been Submitted .... ');

      l_report_request_id := FND_REQUEST.SUBMIT_REQUEST
				( 'IGI'
				, 'IGIIARIQ'
				, null
				, SYSDATE
				, FALSE         -- Is a sub request
				,p_request_type
				,p_app_name
				,p_report_name_3
				,p_report_id_3
				,p_rep3_attrib_set
				,p_out_format
				,p_report_name_3
				,p_book_type_code
				,p_period_ctr
				,p_cat_struct_id
				,p_cat_id
				,p_chart_of_acct
				--,p_from_company
				--,p_to_company
				,p_from_cost_center
				,p_to_cost_center
				,p_from_asset
				,p_to_asset
				);

      IF l_report_request_id = 0 THEN
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Warning: Asset Balance Report "'
                           || l_report_desc || '"');
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'did not complete ');
      ELSE
        COMMIT;
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Asset Balance Report "' ||
                           l_report_desc || '"');
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'" is available at "Request ID" ' ||
                           l_report_request_id);
      END IF;
      l_report_request_id := 0;
    END IF;




    -- ****** Start the fourth report *****
    IF p_report_id_4 IS NOT NULL THEN

      OPEN c_get_report_desc (p_report_name_4);
      FETCH c_get_report_desc INTO l_report_desc;

      IF (c_get_report_desc%NOTFOUND) THEN
        l_report_desc := p_report_name_4; -- Forget it - use report short name instead!!
      END IF;
      CLOSE c_get_report_desc;

      igi_iac_debug_pkg.debug_other_string(g_event_level,l_path,'Asset Balance Report "'
                       || l_report_desc || '"');
      igi_iac_debug_pkg.debug_other_string(g_event_level,l_path,'has been Submitted .... ');

      l_report_request_id := FND_REQUEST.SUBMIT_REQUEST
				( 'IGI'
				, 'IGIIARIQ'
				, null
				, SYSDATE
				, FALSE         -- Is a sub request
				,p_request_type
				,p_app_name
				,p_report_name_4
				,p_report_id_4
				,p_rep4_attrib_set
				,p_out_format
				,p_report_name_4
				,p_book_type_code
				,p_period_ctr
				,p_cat_struct_id
				,p_cat_id
				,p_chart_of_acct
				--,p_from_company
				--,p_to_company
				,p_from_cost_center
				,p_to_cost_center
				,p_from_asset
				,p_to_asset
				);

      IF l_report_request_id = 0 THEN
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Warning: Asset Balance Report "'
                           || l_report_desc || '"');
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'did not complete ');

      ELSE
        COMMIT;
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Asset Balance Report "' ||
                           l_report_desc || '"');
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'" is available at "Request ID" ' ||
                           l_report_request_id);

      END IF;
      l_report_request_id := 0;
    END IF;


    -- ****** Start the fifth report *****
    IF p_report_id_5 IS NOT NULL THEN

      OPEN c_get_report_desc (p_report_name_5);
      FETCH c_get_report_desc INTO l_report_desc;

      IF (c_get_report_desc%NOTFOUND) THEN
        l_report_desc := p_report_name_5; -- Forget it - use report short name instead!!
      END IF;
      CLOSE c_get_report_desc;

      igi_iac_debug_pkg.debug_other_string(g_event_level,l_path,'Asset Balance Report "'
                       || l_report_desc || '"');
      igi_iac_debug_pkg.debug_other_string(g_event_level,l_path,'has been Submitted .... ');

      l_report_request_id := FND_REQUEST.SUBMIT_REQUEST
				( 'IGI'
				, 'IGIIARIQ'
				, null
				, SYSDATE
				, FALSE         -- Is a sub request
				,p_request_type
				,p_app_name
				,p_report_name_5
				,p_report_id_5
				,p_rep5_attrib_set
				,p_out_format
				,p_report_name_5
				,p_book_type_code
				,p_period_ctr
				,p_cat_struct_id
				,p_cat_id
				,p_chart_of_acct
				--,p_from_company
				--,p_to_company
				,p_from_cost_center
				,p_to_cost_center
				,p_from_asset
				,p_to_asset
				);

      IF l_report_request_id = 0 THEN
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Warning: Asset Balance Report "'
                           || l_report_desc || '"');
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'did not complete ');
      ELSE
        COMMIT;
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Asset Balance Report "' ||
                           l_report_desc || '"');
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'" is available at "Request ID" ' ||
                           l_report_request_id);

      END IF;
      l_report_request_id := 0;
    END IF;


    -- ****** Start the sixth report *****
    IF p_report_id_6 IS NOT NULL THEN

      OPEN c_get_report_desc (p_report_name_6);
      FETCH c_get_report_desc INTO l_report_desc;

      IF (c_get_report_desc%NOTFOUND) THEN
        l_report_desc := p_report_name_6; -- Forget it - use report short name instead!!
      END IF;
      CLOSE c_get_report_desc;

      igi_iac_debug_pkg.debug_other_string(g_event_level,l_path,'Asset Balance Report "'
                       || l_report_desc || '"');
      igi_iac_debug_pkg.debug_other_string(g_event_level,l_path,'has been Submitted .... ');

      l_report_request_id := FND_REQUEST.SUBMIT_REQUEST
				( 'IGI'
				, 'IGIIARIQ'
				, null
				, SYSDATE
				, FALSE         -- Is a sub request
				,p_request_type
				,p_app_name
				,p_report_name_6
				,p_report_id_6
				,p_rep6_attrib_set
				,p_out_format
				,p_report_name_6
				,p_book_type_code
				,p_period_ctr
				,p_cat_struct_id
				,p_cat_id
				,p_chart_of_acct
				--,p_from_company
				--,p_to_company
				,p_from_cost_center
				,p_to_cost_center
				,p_from_asset
				,p_to_asset
				);

      IF l_report_request_id = 0 THEN
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Warning: Asset Balance Report "'
                           || l_report_desc || '"');
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'did not complete ');
      ELSE
        COMMIT;
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Asset Balance Report "' ||
                           l_report_desc || '"');
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'" is available at "Request ID" ' ||
                           l_report_request_id);

      END IF;
      l_report_request_id := 0;
    END IF;



    -- ****** Start the seventh report *****
    IF p_report_id_7 IS NOT NULL THEN

      OPEN c_get_report_desc (p_report_name_7);
      FETCH c_get_report_desc INTO l_report_desc;

      IF (c_get_report_desc%NOTFOUND) THEN
        l_report_desc := p_report_name_7; -- Forget it - use report short name instead!!
      END IF;
      CLOSE c_get_report_desc;

      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Asset Balance Report "'
                       || l_report_desc || '"');
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'has been Submitted .... ');

      l_report_request_id := FND_REQUEST.SUBMIT_REQUEST
				( 'IGI'
				, 'IGIIARIQ'
				, null
				, SYSDATE
				, FALSE         -- Is a sub request
				,p_request_type
				,p_app_name
				,p_report_name_7
				,p_report_id_7
				,p_rep7_attrib_set
				,p_out_format
				,p_report_name_7
				,p_book_type_code
				,p_period_ctr
				,p_cat_struct_id
				,p_cat_id
				,p_chart_of_acct
				--,p_from_company
				--,p_to_company
				,p_from_cost_center
				,p_to_cost_center
				,p_from_asset
				,p_to_asset
				);

      IF l_report_request_id = 0 THEN
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Warning: Asset Balance Report "'
                           || l_report_desc || '"');
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'did not complete ');
      ELSE
        COMMIT;
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Asset Balance Report "' ||
                           l_report_desc || '"');
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'" is available at "Request ID" ' ||
                           l_report_request_id);

      END IF;
      l_report_request_id := 0;
    END IF;



    -- ****** Start the eigth report *****
    IF p_report_id_8 IS NOT NULL THEN

      OPEN c_get_report_desc (p_report_name_8);
      FETCH c_get_report_desc INTO l_report_desc;

      IF (c_get_report_desc%NOTFOUND) THEN
        l_report_desc := p_report_name_8; -- Forget it - use report short name instead!!
      END IF;
      CLOSE c_get_report_desc;

      igi_iac_debug_pkg.debug_other_string(g_event_level,l_path,'Asset Balance Report "'
                       || l_report_desc || '"');
      igi_iac_debug_pkg.debug_other_string(g_event_level,l_path,'has been Submitted .... ');

      l_report_request_id := FND_REQUEST.SUBMIT_REQUEST
				( 'IGI'
				, 'IGIIARIQ'
				, null
				, SYSDATE
				, FALSE         -- Is a sub request
				,p_request_type
				,p_app_name
				,p_report_name_8
				,p_report_id_8
				,p_rep8_attrib_set
				,p_out_format
				,p_report_name_8
				,p_book_type_code
				,p_period_ctr
				,p_cat_struct_id
				,p_cat_id
				,p_chart_of_acct
				--,p_from_company
				--,p_to_company
				,p_from_cost_center
				,p_to_cost_center
				,p_from_asset
				,p_to_asset
				);

      IF l_report_request_id = 0 THEN
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Warning: Asset Balance Report "'
                           || l_report_desc || '"');
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'did not complete ');
      ELSE
        COMMIT;
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Asset Balance Report "' ||
                           l_report_desc || '"');
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'" is available at "Request ID" ' ||
                           l_report_request_id);

      END IF;
      l_report_request_id := 0;
    END IF;


  EXCEPTION
    WHEN OTHERS THEN
           igi_iac_debug_pkg.debug_unexpected_msg(l_path);
  END submit_report;



/**********
This function has now been removed It was originally added to accomodate
the data capture into the RXi interface table of 4 detail reports, as the
queries were identical for summary/detail; The only difference was the grouping.
The grouping was going to be handled within the RXi designer attribute sets.
However it has been found that the rollup grouping is not achievable within Rxi,
so 8 seperate queries are required for data capture and storage.

***********/

/*****
        --Do we need to run summary/detail report for this data?
        IF p_rep4_attrib_set_2 IS NOT NULL THEN

          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Printing report "'
                             || l_report_desc || '"');
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'for SUMMARY/DETAIL, using '
                             || p_rep4_attrib_set_2 || ' attribute set');

          l_publish_req := publish_report
				( l_report_request_id
				,p_report_id_4
				,p_rep4_attrib_set_2
				,p_out_format );

          IF l_publish_req = 0 THEN
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Warning: Unable to print ' ||
                               'Asset Balance Report ');
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'"' || l_report_desc || '"');
          ELSE
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path, 'Successfully printed Asset ' ||
                               'Balance Report');
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'"' || l_report_desc || '"');
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'at "Request ID" ' ||
                               l_publish_req);
          END IF;
        END IF;
      END IF;
      l_publish_req := 0;
      l_report_request_id := 0;
    END IF;


  FUNCTION publish_report ( p_parent_req_id in NUMBER
                          ,p_report_id in VARCHAR2
                          ,p_attrib_set in VARCHAR2
                          ,p_out_format in VARCHAR2)
  RETURN NUMBER IS

    l_child_req_id     NUMBER;
    l_report_req_id    NUMBER;
    l_message          VARCHAR2(1000);
    l_phase            VARCHAR2(100);
    l_status           VARCHAR2(100);
    l_dev_phase        VARCHAR2(100);
    l_dev_status       VARCHAR2(100);

    e_request_submit_error   EXCEPTION;
    e_request_wait_error     EXCEPTION;

    CURSOR c_child_request(p_p_request_id  NUMBER) IS
    SELECT request_id
    FROM fnd_concurrent_requests
    WHERE parent_request_id = p_p_request_id;

    l_path varchar2(150) := g_path||'publish_report';
  BEGIN

    -- Ensure the parent process has completed before launching child
    -- to re-publish RXI report

    -- *** NOTE THE INTERVAL, AND MAX WAIT PERIOD FOR FUNCTION CAN BE ***
    -- *** ADJUSTED FOR PERFORMANCE  ***
    IF NOT FND_CONCURRENT.Wait_For_Request (p_parent_req_id,
                                              30, -- interval seconds
                                              0,  -- max wait seconds
                                              l_phase,
                                              l_status,
                                              l_dev_phase,
                                              l_dev_status,
                                              l_message)
    THEN
      RETURN 0;
    END IF;

    -- Check request completion status
    IF l_dev_phase <> 'COMPLETE' OR
      l_dev_status <> 'NORMAL' THEN
	RETURN 0;
    END IF;

  OPEN c_child_request (p_parent_req_id);
  FETCH c_child_request INTO l_child_req_id;

  IF (c_child_request%FOUND) THEN
    l_report_req_id := FND_REQUEST.SUBMIT_REQUEST
			( 'OFA'
			, 'FARXPBSH'
			, null
			, null
			, FALSE
			,'PUBLISH'
			,l_child_req_id
			,p_report_id
			,p_attrib_set
			,p_out_format
			);


    IF l_report_req_id = 0 THEN
        CLOSE c_child_request;
        RETURN 0;
      ELSE
        COMMIT;
        CLOSE c_child_request;
        RETURN l_report_req_id;
      END IF;
  ELSE
    CLOSE c_child_request;
    RETURN 0;
  END IF;
  CLOSE c_child_request;

  RETURN l_report_req_id;

  EXCEPTION
    WHEN OTHERS THEN
	    igi_iac_debug_pkg.debug_unexpected_msg(l_path);
        RETURN 0;

  END publish_report;

*******/


END igi_iac_submit_rxi_asset_bal;

/
