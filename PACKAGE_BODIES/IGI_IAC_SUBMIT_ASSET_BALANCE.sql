--------------------------------------------------------
--  DDL for Package Body IGI_IAC_SUBMIT_ASSET_BALANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_SUBMIT_ASSET_BALANCE" AS
--  $Header: igiiabpb.pls 120.6.12000000.1 2007/08/01 16:13:00 npandya ship $

  --===========================FND_LOG.START=====================================

  g_state_level NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
  g_proc_level  NUMBER	     :=	FND_LOG.LEVEL_PROCEDURE;
  g_event_level NUMBER	     :=	FND_LOG.LEVEL_EVENT;
  g_excep_level NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
  g_error_level NUMBER	     :=	FND_LOG.LEVEL_ERROR;
  g_unexp_level NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
  g_path        VARCHAR2(100):= 'IGI.PLSQL.igiiabpb.igi_iac_submit_asset_balance.';

  --===========================FND_LOG.END=====================================

  PROCEDURE submit_report ( ERRBUF   OUT NOCOPY       VARCHAR2,
			    RETCODE  OUT NOCOPY       NUMBER ,
			    p_book_type_code          VARCHAR2 ,
			    p_period_counter          NUMBER ,
			    p_mode                    VARCHAR2 ,
			    p_category_struct_id      NUMBER ,
			    p_category_id             NUMBER ,
                            p_called_from             VARCHAR2,
                            acct_flex_structure       NUMBER,
                            p_from_cost_center        VARCHAR2,
                            p_to_cost_center          VARCHAR2,
                            p_from_asset              NUMBER,
                            p_to_asset                NUMBER )
  IS
	l_report_request_id    NUMBER ;
  	l_path_name VARCHAR2(150) := g_path||'submit_report';
  BEGIN


      IF ( p_mode  IN ( 'S' ,'A' ) ) THEN

        l_report_Request_id := FND_REQUEST.SUBMIT_REQUEST ( 'IGI'
                                                         , 'IGIIACAB'
                                                         , null
                                                         , null
                                                         , FALSE          -- Is a sub request
                                                         , 'P_BOOK_TYPE_CODE='||p_book_type_code
                                                         , 'P_PERIOD_COUNTER='||p_period_counter
                                                         , 'P_CATEGORY_ID='||p_category_id
                                                         , 'P_FROM_COST_CENTER='||p_from_cost_center
                                                         , 'P_TO_COST_CENTER='||p_to_cost_center
                                                         , 'P_FROM_ASSET='||p_to_asset
                                                         , 'P_TO_ASSET='||p_to_asset
                                                         );
  	 igi_iac_debug_pkg.debug_other_string(p_level => g_event_level,
		     p_full_path => l_path_name,
		     p_string => 'Asset Balance Summary Report Submitted .... ');

      END IF;
      IF ( p_mode  IN ( 'R' , 'A'  ) ) THEN
        l_report_Request_id := FND_REQUEST.SUBMIT_REQUEST ( 'IGI'
                                                         , 'IGIIACRB'
                                                         , null
                                                         , null
                                                         , FALSE          -- Is a sub request
                                                         , 'P_BOOK_TYPE_CODE='||p_book_type_code
                                                         , 'P_PERIOD_COUNTER='||p_period_counter
                                                         , 'P_CATEGORY_ID='||p_category_id
                                                         , 'P_FROM_COST_CENTER='||p_from_cost_center
                                                         , 'P_TO_COST_CENTER='||p_to_cost_center
                                                         , 'P_FROM_ASSET='||p_to_asset
                                                         , 'P_TO_ASSET='||p_to_asset
                                                         );
  	igi_iac_debug_pkg.debug_other_string(p_level => g_event_level,
		     p_full_path => l_path_name,
		     p_string => 'Asset Balance Revaluation Report Submitted .... ');

      END IF;
      IF ( p_mode  IN ( 'O' , 'A'  ) ) THEN
        l_report_Request_id := FND_REQUEST.SUBMIT_REQUEST ( 'IGI'
                                                         , 'IGIIACOB'
                                                         , null
                                                         , null
                                                         , FALSE          -- Is a sub request
                                                         , 'P_BOOK_TYPE_CODE='||p_book_type_code
                                                         , 'P_PERIOD_COUNTER='||p_period_counter
                                                         , 'P_CATEGORY_ID='||p_category_id
                                                         , 'P_FROM_COST_CENTER='||p_from_cost_center
                                                         , 'P_TO_COST_CENTER='||p_to_cost_center
                                                         , 'P_FROM_ASSET='||p_to_asset
                                                         , 'P_TO_ASSET='||p_to_asset
                                                         );
  	 igi_iac_debug_pkg.debug_other_string(p_level => g_event_level,
		     p_full_path => l_path_name,
		     p_string => 'Asset Balance Operating Expense Report Submitted .... ');


      END IF;
      IF ( p_mode  IN ( 'D' , 'A'  ) ) THEN
        l_report_Request_id := FND_REQUEST.SUBMIT_REQUEST ( 'IGI'
                                                         , 'IGIIACDB'
                                                         , null
                                                         , null
                                                         , FALSE          -- Is a sub request
                                                         , 'P_BOOK_TYPE_CODE='||p_book_type_code
                                                         , 'P_PERIOD_COUNTER='||p_period_counter
                                                         , 'P_CATEGORY_ID='||p_category_id
                                                         , 'P_FROM_COST_CENTER='||p_from_cost_center
                                                         , 'P_TO_COST_CENTER='||p_to_cost_center
                                                         , 'P_FROM_ASSET='||p_to_asset
                                                         , 'P_TO_ASSET='||p_to_asset
                                                         );

  	igi_iac_debug_pkg.debug_other_string(p_level => g_event_level,
		     p_full_path => l_path_name,
		     p_string => 'Asset Balance Depreciation Report Submitted .... ');
      END IF;

      COMMIT;
  END ;


  PROCEDURE submit_summary( ERRBUF   OUT NOCOPY       VARCHAR2,
			    RETCODE  OUT NOCOPY       NUMBER ,
			    p_book_type_code          VARCHAR2 ,
			    p_period_counter          NUMBER ,
			    p_mode                    VARCHAR2 ,
			    p_category_struct_id      NUMBER ,
			    p_category_id             NUMBER ,
                            p_called_from             VARCHAR2,
                            acct_flex_structure       NUMBER,
                            p_from_cost_center        VARCHAR2,
                            p_to_cost_center          VARCHAR2)
  IS
	l_report_request_id    NUMBER ;
  	l_path_name VARCHAR2(150) := g_path||'submit_summary';
  BEGIN


      IF ( p_mode  IN ( 'S' ,'A' ) ) THEN

        l_report_Request_id := FND_REQUEST.SUBMIT_REQUEST ( 'IGI'
                                                         , 'IGIIACAS'
                                                         , null
                                                         , null
                                                         , FALSE          -- Is a sub request
                                                         , 'P_BOOK_TYPE_CODE='||p_book_type_code
                                                         , 'P_PERIOD_COUNTER='||p_period_counter
                                                         , 'P_CATEGORY_ID='||p_category_id
                                                         , 'P_FROM_COST_CENTER='||p_from_cost_center
                                                         , 'P_TO_COST_CENTER='||p_to_cost_center
                                                         );
  	 igi_iac_debug_pkg.debug_other_string(p_level => g_event_level,
		     p_full_path => l_path_name,
		     p_string => 'Asset Balance Summary Report Submitted .... ');

      END IF;
      IF ( p_mode  IN ( 'R' , 'A'  ) ) THEN
        l_report_Request_id := FND_REQUEST.SUBMIT_REQUEST ( 'IGI'
                                                         , 'IGIIACRS'
                                                         , null
                                                         , null
                                                         , FALSE          -- Is a sub request
                                                         , 'P_BOOK_TYPE_CODE='||p_book_type_code
                                                         , 'P_PERIOD_COUNTER='||p_period_counter
                                                         , 'P_CATEGORY_ID='||p_category_id
                                                         , 'P_FROM_COST_CENTER='||p_from_cost_center
                                                         , 'P_TO_COST_CENTER='||p_to_cost_center
                                                         );
  	 igi_iac_debug_pkg.debug_other_string(p_level => g_event_level,
		     p_full_path => l_path_name,
		     p_string => 'Asset Balance Revaluation Report Submitted .... ');

      END IF;
      IF ( p_mode  IN ( 'O' , 'A'  ) ) THEN
        l_report_Request_id := FND_REQUEST.SUBMIT_REQUEST ( 'IGI'
                                                         , 'IGIIACOS'
                                                         , null
                                                         , null
                                                         , FALSE          -- Is a sub request
                                                         , 'P_BOOK_TYPE_CODE='||p_book_type_code
                                                         , 'P_PERIOD_COUNTER='||p_period_counter
                                                         , 'P_CATEGORY_ID='||p_category_id
                                                         , 'P_FROM_COST_CENTER='||p_from_cost_center
                                                         , 'P_TO_COST_CENTER='||p_to_cost_center
                                                         );
  	 igi_iac_debug_pkg.debug_other_string(p_level => g_event_level,
		     p_full_path => l_path_name,
		     p_string => 'Asset Balance Operating Expense Report Submitted .... ');


      END IF;
      IF ( p_mode  IN ( 'D' , 'A'  ) ) THEN
        l_report_Request_id := FND_REQUEST.SUBMIT_REQUEST ( 'IGI'
                                                         , 'IGIIACDS'
                                                         , null
                                                         , null
                                                         , FALSE          -- Is a sub request
                                                         , 'P_BOOK_TYPE_CODE='||p_book_type_code
                                                         , 'P_PERIOD_COUNTER='||p_period_counter
                                                         , 'P_CATEGORY_ID='||p_category_id
                                                         , 'P_FROM_COST_CENTER='||p_from_cost_center
                                                         , 'P_TO_COST_CENTER='||p_to_cost_center
                                                         );

  	 igi_iac_debug_pkg.debug_other_string(p_level => g_event_level,
		     p_full_path => l_path_name,
		     p_string => 'Asset Balance Depreciation Report Submitted .... ');
      END IF;

      COMMIT;
  END ;
END;

/
