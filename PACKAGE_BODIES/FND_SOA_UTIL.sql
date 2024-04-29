--------------------------------------------------------
--  DDL for Package Body FND_SOA_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_SOA_UTIL" as
/* $Header: FNDSOAUB.pls 120.1.12010000.4 2010/05/18 06:47:45 dsardar ship $ */

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
		deleted_error_count NUMBER;
		deleted_log_count NUMBER;


begin

  v_strt_date := trunc(FND_CONC_DATE.STRING_TO_DATE(start_date),'DD');
  v_end_date :=trunc( FND_CONC_DATE.STRING_TO_DATE(end_date),'DD');
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

  /* Purge Function to delete obsoleted Log Data */
  deleted_log_count := delete_log_by_date_range(v_strt_date,v_end_date);
  /* Purge Function to delete all requests Data */
  deleted_requests_count :=
delete_requests_by_date_range(v_strt_date,v_end_date);
  /* Purge Function to delete all method Data */
  deleted_method_count := delete_method_by_date_range(v_strt_date,v_end_date);
  /* Purge Function to delete all attachment Data */
  deleted_att_count := delete_att_by_date_range(v_strt_date,v_end_date);
  /* Purge Function to delete all attachment body Data */
  deleted_att_count := delete_body_by_date_range(v_strt_date,v_end_date);
  /* Purge Function to delete all Error Data */
  deleted_error_count := delete_error_by_date_range(v_strt_date,v_end_date);



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
      FROM  FND_SOA_REQUEST
      WHERE message_id IN
	(SELECT WR.message_id
	FROM
	FND_SOA_REQUEST    WR
	WHERE
	(x_start_date IS NOT NULL and x_end_date IS NOT NULL)
	AND  x_start_date<= trunc(WR.request_timestamp,'DD')
	AND  x_end_date>= trunc(WR.request_timestamp,'DD')
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
  fnd_file.put_line(fnd_file.output,'Deleted '|| rowcount ||' rows from
FND_SOA_REQUEST ');
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
	FROM FND_SOA_RESPONSE_METHOD
	WHERE
	message_id NOT  IN
	(SELECT message_id
	FROM
	FND_SOA_REQUEST)
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
			'Deleted '|| rowcount ||' rows from
FND_SOA_RESPONSE_METHOD ');
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
	FROM FND_SOA_ATTACHMENT WA
	WHERE
	(message_id NOT  IN
	(SELECT message_id
	FROM
	FND_SOA_REQUEST))
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
			'Deleted '|| rowcount ||' rows from FND_SOA_ATTACHMENT
');
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
	FROM FND_SOA_BODY_PIECE WP
	WHERE
	(message_id NOT IN
	(SELECT message_id
	FROM
	FND_SOA_REQUEST))
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
			'Deleted '|| rowcount ||' rows from FND_SOA_BODY_PIECE');
RETURN rowcount;
END;

/* Purge function to delete all Error Data */
FUNCTION delete_error_by_date_range(
		x_start_date IN DATE,
		x_end_date IN DATE) return NUMBER is
	rowcount number := 0;
	temp_rowcount number := 0;
BEGIN
	LOOP
		BEGIN

		DELETE
		FROM FND_SOA_RUNTIME_ERROR RE
		WHERE
		(message_id NOT IN
		(SELECT message_id
		FROM
		FND_SOA_REQUEST))
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
			'Deleted '|| rowcount ||' rows from FND_SOA_RUNTIME_ERROR');
RETURN rowcount;
END;

/* Purge function to delete all Log Data */
FUNCTION delete_log_by_date_range(
		x_start_date IN DATE,
		x_end_date IN DATE) return NUMBER is
	rowcount number := 0;
	temp_rowcount number := 0;
BEGIN
	LOOP
		BEGIN

		delete
		from fnd_log_messages
		where transaction_context_id in
		(select transaction_context_id
		from fnd_log_transaction_context
			where transaction_type = 'SOA_INSTANCE'
			and transaction_id in
			(select message_id
			from fnd_soa_request
				where REQUEST_STATUS = 'SUCCESS'
				and x_start_date<= trunc(REQUEST_COMPLETED,'DD')
				AND x_end_date>= trunc(REQUEST_COMPLETED,'DD')))
	and rownum <= 1000;

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
			'Deleted '|| rowcount ||' rows from FND_LOG_MESSAGES');
RETURN rowcount;
END;

/* Purge Function to Delete Log Details by Message ID */
FUNCTION delete_log_by_instance_id(
	x_instance_id IN NUMBER) return NUMBER is
	rowcount number := 0;
	temp_rowcount number := 0;
BEGIN
	LOOP
		BEGIN

		delete
		from fnd_log_messages
		where transaction_context_id in
		(select transaction_context_id
			from fnd_log_transaction_context
			where transaction_type = 'SOA_INSTANCE'
			and transaction_id = x_instance_id)
		and rownum <= 1000;

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
RETURN rowcount;
END;

end  fnd_soa_util;

/
