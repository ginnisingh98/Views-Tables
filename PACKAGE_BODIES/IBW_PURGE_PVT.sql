--------------------------------------------------------
--  DDL for Package Body IBW_PURGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBW_PURGE_PVT" AS
/* $Header: IBWPURB.pls 120.7 2006/04/18 02:24 vekancha noship $*/


  --
  --
  -- Start of Comments
  --
  -- NAME
  --   IBW_PURGE_PVT
  --
  -- PURPOSE
  --   Private API for purging transaction data
  --
  -- NOTES
  --   Administrator uses this program to purge the transaction data. The tables which will be purged are IBW_PAGE_VIEWS,
  --	IBW_SITE_VISITS, IBW_VISITORS, IBW_PAGE_INSTANCES.

  -- HISTORY
  --   05/10/2005	VEKANCHA	Created

  -- **************************************************************************

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IBW_PURGE_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12):= 'IBWPURB.pls';


-- ****************************************************************************
-- ****************************************************************************
--    PROCEDURES
--      1. purge_data
--		2. purge_statistics
-- ****************************************************************************
-- ****************************************************************************


-- ****************************************************************************
-- purges data
-- ****************************************************************************

PROCEDURE purge_data (
	start_date IN DATE,
	end_date IN DATE
)

IS

	temp 		BOOLEAN;
	visit_count NUMBER;
	visitor_count NUMBER;
	page_view_count NUMBER;

BEGIN

		SELECT COUNT(distinct(visit_id)) into visit_count FROM ibw_site_visits
		WHERE visit_start_time BETWEEN start_date AND end_date;

		/** purge ibw_site_visits */
		DELETE FROM ibw_site_visits
		WHERE visit_start_time between start_date AND end_date;



		SELECT count(page_view_id)into page_view_count FROM ibw_page_views pv
		WHERE 0 = (SELECT COUNT(visit_id)
 			       FROM ibw_site_visits v
	  		      WHERE v.visit_id=pv.visit_id);

		/** purge ibw_page_views */
		DELETE 	FROM ibw_page_views pv
		WHERE 0 = (SELECT COUNT(visit_id)
 			       FROM ibw_site_visits v
	  		      WHERE v.visit_id=pv.visit_id);

		/** purge ibw_page_views_tmp */
		DELETE 	FROM ibw_page_views_tmp pv
		WHERE 0 = (SELECT COUNT(visit_id)
			       FROM ibw_site_visits v
	  		      WHERE v.visit_id=pv.visit_id);


		SELECT count(visitor_id) into visitor_count FROM ibw_visitors visitors
		WHERE 0 = (SELECT COUNT(visitor_id)
					FROM  ibw_site_visits visit
					WHERE visit.visitor_id=visitors.visitor_id);

		/** purge ibw_visitors */
		DELETE FROM ibw_visitors visitors
		WHERE 0 = (SELECT COUNT(visitor_id)
					FROM  ibw_site_visits visit
					WHERE visit.visitor_id=visitors.visitor_id);

		/** purge ibw_page_instances */
		DELETE FROM ibw_page_instances pi
		WHERE 0 = (SELECT COUNT(page_instance_id)
		        	FROM ibw_page_views pv
					WHERE pv.page_instance_id=pi.page_instance_id);



		/** Store the end_date parameter of this purge request */
		temp:=FND_PROFILE.SAVE('IBW_PURGE_LAST_ENDDATE',end_date,'SITE');

		/** commit the changes */
		COMMIT;
		report_gen(visit_count, visitor_count, page_view_count,start_date, end_date, 'Y');

END purge_data;



PROCEDURE purge_statistics (
	start_date IN DATE,
	end_date IN DATE
)

IS
	visit_count NUMBER;
	visitor_count NUMBER;
	page_view_count NUMBER;
	page_instance_count NUMBER;

BEGIN

		/** purge ibw_site_visits */
		SELECT COUNT(distinct(site_visit_id)) cnt INTO visit_count
		FROM  ibw_site_visits
		WHERE visit_start_time between start_date AND end_date;

		/** purge ibw_page_views */
		SELECT COUNT(page_view_id) INTO page_view_count
		FROM ibw_page_views pv
		WHERE visit_id IN (SELECT visit_id
 			       FROM ibw_site_visits v
				     WHERE visit_start_time BETWEEN start_date AND end_date);

		/** purge ibw_visitors */
		SELECT COUNT(visitor_id) INTO visitor_count
		FROM ibw_visitors visitors
		WHERE 0= (SELECT count(visitor_id)
					FROM  ibw_site_visits visit
					WHERE visit_start_time NOT BETWEEN start_date AND end_date);
		report_gen(visit_count, visitor_count, page_view_count,start_date, end_date, 'N');

END purge_statistics;

PROCEDURE report_gen (
	visit_count NUMBER,
	visitor_count NUMBER,
	page_view_count NUMBER,
	start_date IN DATE,
	end_date IN DATE,
	execmode IN CHAR
)
IS
BEGIN

  		 FND_MESSAGE.SET_NAME('IBW','IBW_TR_PUR_DATE');
		 FND_MESSAGE.SET_TOKEN('DATE', to_char(sysdate));
 		 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.GET);

 		 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');

		 IF execmode = 'Y' THEN
		 	FND_MESSAGE.SET_NAME('IBW','IBW_TR_PURGE_EXECMODE');
		 	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.GET);
		 ELSE
		 	 FND_MESSAGE.SET_NAME('IBW','IBW_TR_PURGE_EVALMODE');
		 	 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.GET);
		 END IF;

  		 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');

		 FND_MESSAGE.SET_NAME('IBW','IBW_TR_PURGE_DATERANGE');
		 FND_MESSAGE.SET_TOKEN('START_DATE', to_char(start_date,'DD-MON-RRRR'));
		 FND_MESSAGE.SET_TOKEN('END_DATE', to_char(end_date,'DD-MON-RRRR'));
 		 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.GET);

  		 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');

		 FND_MESSAGE.SET_NAME('IBW','IBW_TR_PURGE_REPORT');
		 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.GET);

		 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '===============================================');

  		 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');

  		 FND_MESSAGE.SET_NAME('IBW','IBW_TR_PURGE_PAGEVIEWS');
 		 FND_MESSAGE.SET_TOKEN('COUNT', to_char(page_view_count));
 		 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.GET);

  		 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');

		 FND_MESSAGE.SET_NAME('IBW','IBW_TR_PURGE_VISITS');
 		 FND_MESSAGE.SET_TOKEN('COUNT', to_char(visit_count));
 		 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.GET);

  		 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');

		 FND_MESSAGE.SET_NAME('IBW','IBW_TR_PURGE_VISITORS');
   		 FND_MESSAGE.SET_TOKEN('COUNT', to_char(visitor_count));
 		 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.GET);
END report_gen;


PROCEDURE data_purge (
		  err_msg OUT NOCOPY VARCHAR2,
		  err_code OUT NOCOPY NUMBER,
		  start_date IN VARCHAR2,
		  end_date IN VARCHAR2,
		  exec_mode IN CHAR
)
IS

  startDate		 VARCHAR2(100);
  error_messages	VARCHAR2(200);
  sDate		DATE;
  eDate		DATE;
  INVALID_DATE  EXCEPTION;

BEGIN

	/** If start_date is null, then initialize it with the end_date of the previous run which is stored in
		the profiles.
 	 */
	IF start_date=null THEN
		FND_PROFILE.GET('IBW_PREVIOUS_PURGE_DATE',startDate);
	ELSE
		startDate:=start_date;
	END IF;

	/** If end_date is null, then exit the procedure
	 */
	IF end_date=null THEN
		FND_MESSAGE.SET_NAME('IBW','IBW_TR_PURGE_NULLDATE_ERR');
	 	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.GET);
		raise INVALID_DATE;
	/** If start_date is greater than the end_date, then exit the procedure.
	 */
	ELSIF startDate >= end_date THEN
		FND_MESSAGE.SET_NAME('IBW','IBW_TR_PURGE_DATE_ERR');
	 	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.GET);
		raise INVALID_DATE;

	ELSE
		sDate := to_date(startDate, 'RRRR/MM/DD HH24:MI:SS');
		eDate := to_date(end_date,'RRRR/MM/DD HH24:MI:SS');

		IF exec_mode='Y' THEN
		   purge_data(sDate,eDate);
		ELSE
			purge_statistics(sDate, eDate);
		END IF;
	END IF;

	EXCEPTION
	WHEN OTHERS THEN
		err_code := 2;
END data_purge;


PROCEDURE purge_oam (
		  start_date IN DATE,
		  end_date	 IN	DATE
)
IS
  	cnt NUMBER;
	temp_name varchar2(100);
	startDate DATE;
	error_messages VARCHAR2(100);

BEGIN

	/** If start_date is null, then initialize it with the end_date of the previous run which is stored in
		the profiles.
 	 */
	IF start_date=null THEN
		FND_PROFILE.GET('IBW_PREVIOUS_PURGE_DATE',startDate);
	ELSE
		startDate:=start_date;
	END IF;

	/** If end_date is null, then exit the procedure
	 */
	IF end_date=null THEN
		error_messages := 'End date is null';


	/** If start_date is greater than the end_date, then exit the procedure.
	 */
	ELSIF startDate >= end_date THEN
		error_messages := 'start date is greater than end date. ';

	ELSE
		/** purge ibw_site_visits */
		SELECT COUNT(site_visit_id) INTO cnt
		FROM  ibw_site_visits
		WHERE visit_start_time between startDate AND end_date;

		temp_name := fnd_message.get_string('IBW', 'IBW_TR_PURGE_VISITS');
		fnd_conc_summarizer.insert_row(temp_name, to_char(cnt));

		/** purge ibw_page_views */
		SELECT COUNT(page_view_id) INTO cnt
		FROM ibw_page_views pv
		WHERE 0 = (SELECT COUNT(visit_id)
 			       FROM ibw_site_visits v
				     WHERE v.visit_id=pv.visit_id);

		temp_name := fnd_message.get_string('IBW', 'IBW_TR_PURGE_PAGEVIEWS');
		fnd_conc_summarizer.insert_row(temp_name, to_char(cnt));


		/** purge ibw_visitors */
		SELECT COUNT(visitor_id) INTO cnt
		FROM ibw_visitors visitors
		WHERE 0 = (SELECT COUNT(visitor_id)
					FROM  ibw_site_visits visit
					WHERE visit.visitor_id=visitors.visitor_id);

		temp_name := fnd_message.get_string('IBW', 'IBW_TR_PURGE_VISITORS');
		fnd_conc_summarizer.insert_row(temp_name, to_char(cnt));


	END IF;
END purge_oam;

END IBW_PURGE_PVT;

/
