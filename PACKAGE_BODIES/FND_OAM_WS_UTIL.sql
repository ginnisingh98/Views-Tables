--------------------------------------------------------
--  DDL for Package Body FND_OAM_WS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_WS_UTIL" as
/* $Header: AFOAMWSUTILB.pls 120.1 2005/08/21 12:14:54 ssuprasa noship $ */

/* Purge Function to delete all Data */
procedure delete_by_date_cp(   errbuf out NOCOPY varchar2,
                               retcode out NOCOPY varchar2,
                               start_date in  varchar2,
                               end_date in  varchar2 ) is
        v_strt_date DATE;
        v_end_date DATE;
        deleted_requests_count NUMBER;
        deleted_response_count NUMBER;
        deleted_method_count NUMBER;
	deleted_att_count NUMBER;


begin

  v_strt_date := FND_CONC_DATE.STRING_TO_DATE(start_date);
  v_end_date := FND_CONC_DATE.STRING_TO_DATE(end_date);
  IF(v_strt_date is NULL) then
     errbuf := 'Unexpected error converting character string to date:'
                   ||start_date;
     retcode := '2';
     FND_FILE.put_line(FND_FILE.log,errbuf);
     RETURN;
  END IF;
  IF(v_end_date is NULL) then
     errbuf := 'Unexpected error converting character string to date:'
                   ||end_date;
     retcode := '2';
     FND_FILE.put_line(FND_FILE.log,errbuf);
     RETURN;
  END IF;

  /* Purge Function to delete all requests Data */
  deleted_requests_count := delete_requests_by_date_range(v_strt_date,v_end_date);
  /* Purge Function to delete all response Data */
  deleted_response_count := delete_responses_by_date_range(v_strt_date,v_end_date);
  /* Purge Function to delete all method Data */
  deleted_method_count := delete_method_by_date_range(v_strt_date,v_end_date);
  /* Purge Function to delete all attachment Data */
  deleted_att_count := delete_att_by_date_range(v_strt_date,v_end_date);
  /* Purge Function to delete all attachment body Data */
  deleted_att_count := delete_body_by_date_range(v_strt_date,v_end_date);


end delete_by_date_cp;


/* Purge Function to delete all requests Data */
FUNCTION delete_requests_by_date_range(
         x_start_date IN DATE,
         x_end_date IN DATE) return NUMBER is
  rowcount number := 0;
  temp_rowcount number := 0;
BEGIN

  LOOP
    BEGIN

    DELETE
      FROM  OAM_PAT_WS_REQUEST
      WHERE message_id IN
	(SELECT WR.message_id
	FROM
	OAM_PAT_WS_REQUEST    WR
	WHERE
	(x_start_date IS NOT NULL and x_end_date IS NOT NULL)
	AND  nvl(x_start_date, WR.request_timestamp)<= WR.request_timestamp
	AND  nvl(x_end_date, WR.request_timestamp)>= WR.request_timestamp
	)
	AND rownum <= 1000;
      temp_rowcount := SQL%ROWCOUNT;
      COMMIT;
      rowcount := rowcount + temp_rowcount;
      EXIT WHEN (temp_rowcount = 0);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL; /* Should never happen */
      WHEN OTHERS THEN
        IF ((SQLCODE = 60) or (SQLCODE = 4020)) then
          NULL;  /* Ignore rows that are deadlocked */
        ELSE
          RAISE;
        END IF;
    END;

  END LOOP;
  fnd_file.put_line(fnd_file.output,'Deleted '|| rowcount ||' rows from OAM_PAT_WS_REQUEST ');
  RETURN rowcount;
END;



/* Purge Function to delete all response Data */
FUNCTION delete_responses_by_date_range(
         x_start_date IN DATE,
         x_end_date IN DATE) return NUMBER is
  rowcount number := 0;
  temp_rowcount number := 0;
BEGIN
  LOOP
    BEGIN




    DELETE
      FROM  OAM_PAT_WS_RESPONSE
      WHERE message_id IN
	(SELECT WR.message_id
	FROM
	OAM_PAT_WS_RESPONSE    WR
	WHERE
	(x_start_date IS NOT NULL and x_end_date IS NOT NULL)
	AND  nvl(x_start_date, WR.response_timestamp)<= WR.response_timestamp
	AND  nvl(x_end_date, WR.response_timestamp)>= WR.response_timestamp
	)
	AND rownum <= 1000;


      temp_rowcount := SQL%ROWCOUNT;
      COMMIT;
      rowcount := rowcount + temp_rowcount;
      EXIT WHEN (temp_rowcount = 0);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL; /* Should never happen */
      WHEN OTHERS THEN
        IF ((SQLCODE = 60) or (SQLCODE = 4020)) then
          NULL;  /* Ignore rows that are deadlocked */
        ELSE
          RAISE;
        END IF;
    END;

  END LOOP;
  fnd_file.put_line(fnd_file.output,'Deleted '|| rowcount ||' rows from FND_OAM_WS_RESPONSE ');
  RETURN rowcount;
END;

/* Purge Function to delete all method Data */
FUNCTION delete_method_by_date_range(
         x_start_date IN DATE,
         x_end_date IN DATE) return NUMBER is
  rowcount number := 0;
  temp_rowcount number := 0;
BEGIN
  LOOP
    BEGIN

	DELETE
	FROM OAM_PAT_WS_RESPONSE_METHOD
	WHERE
	message_id NOT  IN
	(SELECT message_id
	FROM
	OAM_PAT_WS_RESPONSE)
	AND rownum <= 1000;

      temp_rowcount := SQL%ROWCOUNT;
      COMMIT;
      rowcount := rowcount + temp_rowcount;
      EXIT WHEN (temp_rowcount = 0);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL; /* Should never happen */
      WHEN OTHERS THEN
        IF ((SQLCODE = 60) or (SQLCODE = 4020)) then
          NULL;  /* Ignore rows that are deadlocked */
        ELSE
          RAISE;
        END IF;
    END;

  END LOOP;
  fnd_file.put_line(fnd_file.output,
			'Deleted '|| rowcount ||' rows from OAM_PAT_WS_RESPONSE_METHOD ');
  RETURN rowcount;
END;

/* Purge Function to delete all attachment Data */
FUNCTION delete_att_by_date_range(
         x_start_date IN DATE,
         x_end_date IN DATE) return NUMBER is
  rowcount number := 0;
  temp_rowcount number := 0;
BEGIN
  LOOP
    BEGIN

	DELETE
	FROM OAM_PAT_WS_ATTACHMENT WA
	WHERE
	((WA.BELONGS_TO='REQUEST' AND  message_id NOT  IN
	(SELECT message_id
	FROM
	OAM_PAT_WS_REQUEST))
	OR
	(WA.BELONGS_TO='RESPONSE' AND  message_id NOT  IN
	(SELECT message_id
	FROM
	OAM_PAT_WS_RESPONSE)))
	AND rownum <= 1000;

      temp_rowcount := SQL%ROWCOUNT;
      COMMIT;
      rowcount := rowcount + temp_rowcount;
      EXIT WHEN (temp_rowcount = 0);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL; /* Should never happen */
      WHEN OTHERS THEN
        IF ((SQLCODE = 60) or (SQLCODE = 4020)) then
          NULL;  /* Ignore rows that are deadlocked */
        ELSE
          RAISE;
        END IF;
    END;

  END LOOP;
  fnd_file.put_line(fnd_file.output,
			'Deleted '|| rowcount ||' rows from OAM_PAT_WS_ATTACHMENT ');
  RETURN rowcount;
END;


/* Purge Function to delete all attachment body Data */
FUNCTION delete_body_by_date_range(
         x_start_date IN DATE,
         x_end_date IN DATE) return NUMBER is
  rowcount number := 0;
  temp_rowcount number := 0;
BEGIN
  LOOP
    BEGIN

	DELETE
	FROM OAM_PAT_WS_BODY_PIECE WP
	WHERE
	((WP.BELONGS_TO='REQUEST' AND  message_id NOT  IN
	(SELECT message_id
	FROM
	OAM_PAT_WS_REQUEST))
	OR
	(WP.BELONGS_TO='RESPONSE' AND  message_id NOT  IN
	(SELECT message_id
	FROM
	OAM_PAT_WS_RESPONSE)))
	AND rownum <= 1000;

      temp_rowcount := SQL%ROWCOUNT;
      COMMIT;
      rowcount := rowcount + temp_rowcount;
      EXIT WHEN (temp_rowcount = 0);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL; /* Should never happen */
      WHEN OTHERS THEN
        IF ((SQLCODE = 60) or (SQLCODE = 4020)) then
          NULL;  /* Ignore rows that are deadlocked */
        ELSE
          RAISE;
        END IF;
    END;

  END LOOP;
  fnd_file.put_line(fnd_file.output,
			'Deleted '|| rowcount ||' rows from OAM_PAT_WS_BODY_PIECE ');
  RETURN rowcount;
END;



end  fnd_oam_ws_util;

/
