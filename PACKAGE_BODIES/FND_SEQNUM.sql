--------------------------------------------------------
--  DDL for Package Body FND_SEQNUM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_SEQNUM" as
/* $Header: AFSQNUMB.pls 120.2 2005/11/03 08:12:59 fskinner ship $ */


/*	Private structure for storing a cache of the info retrieved by get_seq_info()
	it is likey that during a given session this function may be called 100's of
	times with the same input parameters - thus the same Doc_Seq info */

TYPE t_SeqInfo IS RECORD (
	initFlag		boolean := FALSE,
	app_id			number,
	cat_code		varchar2(30),
    sob_id			number,
    met_code		char,
    docseq_id		number,
    docseq_type		char,
    docseq_name		varchar2(30),
	db_seq_name		varchar2(30),
	seq_ass_id		number,
	prd_tab_name	varchar2(30),
	aud_tab_name	varchar2(30),
	msg_flag		char,
	startDate		date,
	endDate			date,
	retStat			number );

v_SeqInfoCache	t_SeqInfo;	-- declare my global cache buffer

  function get_next_sequence (appid    in     number,
                              cat_code in     varchar2,
                              sobid    in     number,
                              met_code in     char,
                              trx_date in     date,
                              dbseqnm  in out nocopy varchar2,
                              dbseqid  in out nocopy integer) return number
  is
    t varchar2(1);
    seqval   integer;   /* the next sequence value */
    seqassid integer;   /* sequence assignment id  */
  begin

    /* Get DB_SEQUENCE_NAME, DOC_SEQUENCE_ID and SEQUENCE_ASSIGNMENT_ID. */
    get_seq_name(appid,cat_code,sobid,met_code,trx_date,
                 dbseqnm,dbseqid,seqassid);

	/* Bug 701013 - change where clause to use DOC_SEQUENCE_ID instead of
	DB_SEQUENCE_NAME user and gapless don't use db sequences */
    select type into t
      from FND_DOCUMENT_SEQUENCES
     where DOC_SEQUENCE_ID = dbseqid;

	/* Bug 701013 - added 't = G' to if statement to get Gapless */
    if ( (t = 'U') OR (t = 'G') ) then
      seqval := get_next_user_sequence(0,seqassid,dbseqid);
    elsif (t = 'A') then
      seqval := get_next_auto_seq(dbseqnm);
    end if;

    return(seqval);

  end get_next_sequence;

  procedure get_seq_name (appid    in  number,
                          cat_code in  varchar2,
                          sobid    in  number,
                          met_code in  char,
                          trx_date in  date,
                          dbseqnm  out nocopy varchar2,
                          dbseqid  out nocopy integer,
                          seqassid out nocopy integer)
  is
  begin

     SELECT SEQ.DB_SEQUENCE_NAME,
            SEQ.DOC_SEQUENCE_ID,
            SA.doc_sequence_assignment_id
      INTO dbseqnm, dbseqid, seqassid
      FROM FND_DOCUMENT_SEQUENCES SEQ,
           FND_DOC_SEQUENCE_ASSIGNMENTS SA
     WHERE SEQ.DOC_SEQUENCE_ID        = SA.DOC_SEQUENCE_ID
       AND SA.APPLICATION_ID          = appid
       AND SA.CATEGORY_CODE           = cat_code
       AND (SA.METHOD_CODE = met_code or SA.METHOD_CODE is NULL)
       AND (SA.SET_OF_BOOKS_ID = sobid or SA.SET_OF_BOOKS_ID is NULL)
	/* bug 1019289, 1295363 - change between to add .9999 to end date -- also removed extra
		todate() tochar() and work with straight dates */
       AND trx_date between SA.START_DATE and nvl( SA.END_DATE + .9999, trx_date + .9999 );
  end get_seq_name;

/*
 * This function gets the nextval for a db sequence given the seq name.
 * Fix Bug 1073084 - changed to use EXECUTE IMMEDIATE instead of dbms_sql.
 */
function get_next_auto_seq (dbseqnm in varchar2) return number
is
	v_proc_stmt		varchar2(100);
	v_nextVal		integer;

begin
	v_proc_stmt := 'select ' || dbseqnm || '.nextval ' || 'into :next_val from sys.dual';

	EXECUTE IMMEDIATE v_proc_stmt INTO v_nextVal;
	return( v_nextVal );

	exception
		when others then
			fnd_message.set_name( 'FND', 'SQL-GENERIC ERROR' );
			fnd_message.set_token( 'ERRNO', sqlcode, FALSE );
			fnd_message.set_token( 'ROUTINE', 'get_next_auto_seq', FALSE );
			fnd_message.set_token( 'REASON', sqlerrm, FALSE );
			fnd_message.set_token( 'ERRFILE', 'AFSQNUMB.pls', FALSE );
			fnd_message.set_token( 'SQLSTMT', v_proc_stmt, FALSE );
			app_exception.raise_exception;
			return( NULL );

end get_next_auto_seq;

  /*-------------------------------------------------------------------------+
   | get_next_auto_sequence
   |
   |  Determines the sequence used in the provided context and returns the
   |  next value. Sequence must exist, otherwise, an error message is issued.
   |
   |  'in' variables:
   |   appid = application_id
   |   sobid = set_of_books_id
   |   cat_code = category_code
   |   met_code = method_code
   |   trx_date = transaction_date
   *-------------------------------------------------------------------------*/
  function get_next_auto_sequence (appid in number,
                                   cat_code in varchar2,
                                   sobid in number,
                                   met_code in char,
                                   trx_date in varchar2) return number
  is
     proc_stmt      varchar2(100);
     dbseqnm        varchar2(30);
     c              integer;
     row_processed  integer;
     temp           integer;
     val            integer;
     next_val       integer;

  begin

     SELECT SEQ.DB_SEQUENCE_NAME into dbseqnm
      FROM FND_DOCUMENT_SEQUENCES SEQ,
           FND_DOC_SEQUENCE_ASSIGNMENTS SA
     WHERE SEQ.DOC_SEQUENCE_ID        = SA.DOC_SEQUENCE_ID
       AND SA.APPLICATION_ID          = appid
       AND SA.CATEGORY_CODE           = cat_code
       AND (SA.METHOD_CODE = met_code or SA.METHOD_CODE is NULL)
       AND (SA.SET_OF_BOOKS_ID = sobid or SA.SET_OF_BOOKS_ID is NULL)
-- bug 1019289, 1295363 - change between to add .9999 to end date, also removed trunc's
       AND to_date( trx_date, decode( length(trx_date),
                                  9,'DD-MON-RR',
                                  10,'DD-MM-YYYY',
                                  11,'DD-MON-YYYY',
                                     'YYYY/MM/DD') ) between
           sa.start_date and nvl(sa.end_date + .9999,to_date(trx_date,decode(length(trx_date),
                                         9,'DD-MON-RR',
                                         10,'DD-MM-YYYY',
                                         11,'DD-MON-YYYY',
                                            'YYYY/MM/DD')) +.9999);

    c := dbms_sql.open_cursor;

    proc_stmt := 'begin select ' || dbseqnm || '.nextval ' ||
                 'into :next_val from sys.dual; end;';

    dbms_sql.parse(c, proc_stmt, dbms_sql.native);
    dbms_sql.bind_variable(c, 'next_val', next_val);

    row_processed := dbms_sql.execute(c);
    dbms_sql.variable_value(c,'next_val', val);

    dbms_sql.close_cursor(c);
    return (val);

    exception
      when NO_DATA_FOUND then
        fnd_message.set_name('FND', 'GET_NEXT_SEQ_VALUE_ERROR');
        fnd_message.set_token('SEQUENCE', dbseqnm, FALSE);
        app_exception.raise_exception;

  end get_next_auto_sequence;

  function get_next_auto_sequence (appid in number,
                                   cat_code in varchar2,
                                   sobid in number,
                                   met_code in char,
                                   trx_date in date) return number
  is
     proc_stmt      varchar2(100);
     dbseqnm        varchar2(30);
     c              integer;
     row_processed  integer;
     temp           integer;
     val            integer;
     next_val       integer;

  begin

     SELECT SEQ.DB_SEQUENCE_NAME into dbseqnm
      FROM FND_DOCUMENT_SEQUENCES SEQ,
           FND_DOC_SEQUENCE_ASSIGNMENTS SA
     WHERE SEQ.DOC_SEQUENCE_ID        = SA.DOC_SEQUENCE_ID
       AND SA.APPLICATION_ID          = appid
       AND SA.CATEGORY_CODE           = cat_code
       AND (SA.METHOD_CODE = met_code or SA.METHOD_CODE is NULL)
       AND (SA.SET_OF_BOOKS_ID = sobid or SA.SET_OF_BOOKS_ID is NULL)
/* bug 1019289, 1295363 - change between to add .9999 to end date also removed trunc
and date coversion routines not needed since this trx_date is a date */
       AND trx_date between sa.start_date and nvl(sa.end_date + .9999, trx_date + .9999);

    c := dbms_sql.open_cursor;

    proc_stmt := 'begin select ' || dbseqnm || '.nextval ' ||
                 'into :next_val from sys.dual; end;';

    dbms_sql.parse(c, proc_stmt, dbms_sql.native);
    dbms_sql.bind_variable(c, 'next_val', next_val);

    row_processed := dbms_sql.execute(c);
    dbms_sql.variable_value(c,'next_val', val);

    dbms_sql.close_cursor(c);
    return (val);

    exception
      when NO_DATA_FOUND then
        fnd_message.set_name('FND', 'GET_NEXT_SEQ_VALUE_ERROR');
        fnd_message.set_token('SEQUENCE', dbseqnm, FALSE);
        app_exception.raise_exception;

  end get_next_auto_sequence;

  procedure create_gapless_sequences
  is
     cursor c
         is
     select seq.doc_Sequence_id
       from fnd_document_sequences seq
      where seq.doc_sequence_id not in
         (select su.doc_Sequence_id
           from fnd_doc_sequence_users su)
        and seq.type='G';
     seqid    number;
     result   number;
  begin

     open c;

     loop
       fetch c into seqid;
       exit when c%notfound;

       result := create_gapless_sequence(seqid);

     end loop;
     close c;

    commit;

    exception
      when others then
        fnd_message.set_name('FND', 'SQL-GENERIC ERROR');
        fnd_message.set_token('ERRNO', sqlcode, FALSE);
        fnd_message.set_token('ROUTINE', 'create_gapless_sequence', FALSE);
        fnd_message.set_token('REASON', sqlerrm, FALSE);
        fnd_message.set_token('ERRFILE', 'AFSQNUMB.pls', FALSE);
        fnd_message.set_token('SQLSTMT', 'select seq.doc_Sequence_id ...', FALSE);
        app_exception.raise_exception;

  end create_gapless_sequences;

  /* This function creates a row in the fnd_doc_sequence_users
   * to keep track of the sequence value of a gapless sequence.
   * This is called when a sequence is assigned to a document in
   * Assign Document Sequence form (FNDSNASQ).
   *
   * Bug 494345: FND_DOC_SEQUENCE_USERS should only record one sequence
   *             per entry, instead of one assignment per entry. Therefore,
   *             the sequence_assignment_id in this table is not really used
   *             in determining the sequence next value. The assignment_id
   *             of the first assignment that uses that particular sequence
   *             will be recorded.
   */
  function create_gapless_sequence (seqid in number) return number
  is
  begin

      insert into fnd_doc_sequence_users
                 (doc_sequence_id,
                  doc_sequence_assignment_id,
                  user_id,
                  nextval,
                  creation_date,
                  created_by,
                  last_update_date,
                  last_updated_by,
                  last_update_login)
      select seq.doc_sequence_id,
             sa.doc_sequence_assignment_id,
             0,
     /* Bug 508093: removed '+1' that was added to the NVL of initial_value
                    not sure why it was there in the first place it
                    prevented the value of '1' from ever being used by
                    a gapless sequence - the forms now protects against
                    the zero value - which may have been why we had it
                    there - so now the default will be 1 instead of 2

                    Replaced NVL with Decode - now we proctect the API from
                    zero or NULL (as per request from MWARREN) and do not
                    depend on forms.
      */
             DECODE(seq.initial_value, NULL, 1, 0, 1, seq.initial_value),
             sysdate, 0, sysdate, 0, 0
      from fnd_document_sequences seq,
           fnd_doc_sequence_assignments sa
      where seq.doc_sequence_id = sa.doc_sequence_id
      and   sa.doc_sequence_id = seqid
      and   sa.doc_Sequence_assignment_id =
        (select min(doc_sequence_assignment_id)
         from fnd_doc_sequence_assignments
         where doc_sequence_id = seqid);

      return(1);

    exception
      when others then
        fnd_message.set_name('FND', 'SQL-GENERIC ERROR');
        fnd_message.set_token('ERRNO', sqlcode, FALSE);
        fnd_message.set_token('ROUTINE', 'create_gapless_sequence( '|| seqid || ' )', FALSE);
        fnd_message.set_token('REASON', sqlerrm, FALSE);
        fnd_message.set_token('ERRFILE', 'AFSQNUMB.pls', FALSE);
        fnd_message.set_token('SQLSTMT', 'insert into fnd_doc_sequence_users ...', FALSE);
 		app_exception.raise_exception;
        return(0);

  end create_gapless_sequence;



  /* This function gets the nextval of a gapless/user sequence and update the
   * next nextval.
   *  fds_user_id = 0 for gapless sequence, userid for user sequence
   *  seqassid = sequence_assignment_id - not used since bug 494345
   *  seqid = doc_sequence_id
   */
function get_next_user_sequence (	fds_user_id	in number,
									seqassid	in number, -- not used
									seqid		in number) return number
is
	v_nextVal number;
begin
	update	fnd_doc_sequence_users
	set		nextval = nextval + 1
	where	user_id = fds_user_id and doc_sequence_id = seqid;

	select	distinct nextval-1
	into	v_nextVal
	from	fnd_doc_sequence_users
	where	doc_sequence_id = seqid and user_id = fds_user_id;

	return(v_nextVal);

	exception
		when no_data_found then
			fnd_message.set_name( 'FND','SQL-ERROR SELECTING' );
			fnd_message.set_token( 'TABLENAME', 'FND_DOC_SEQUENCE_USERS' ,FALSE);
			app_exception.raise_exception;
			return(0);

		when others then
			fnd_message.set_name( 'FND', 'SQL-GENERIC ERROR' );
			fnd_message.set_token( 'ERRNO', sqlcode, FALSE );
			fnd_message.set_token( 'ROUTINE', 'get_next_user_sequence', FALSE );
			fnd_message.set_token( 'REASON', sqlerrm, FALSE );
			fnd_message.set_token( 'ERRFILE', 'AFSQNUMB.pls', FALSE );
			fnd_message.set_token( 'SQLSTMT', 'update fnd_doc_sequence_users ... nextval', FALSE );
			app_exception.raise_exception;
			return(0);
end get_next_user_sequence;



/*	This procedure is added for bug 586077 and creates data base sequences
	for all AUTOMATIC sequences defined in FND_DOCUMENT_SEQUENCES but does
	not yet have a real DB sequences in ALL_SEQUENCES.  This is done by the
	this server side PLSQL rather than spawning a Concurrent Request. */
/*	Fix for bug 1106208 -- behavior is changed from above to remove the outer
	join to ALL_SEQUENCES -- instead we now call this routine at the PRE-INSERT
	trigger of the define form for each record inserted.  Thus we can pass the
	new db_sequence_name and initial_value and create the DB Seq directly.  The
	only bad effect of calling from PRE-INSERT is that if something wierd happens
	and the commit fails and AD_DDL does not the DB Seq has still been created,
	this will not cause any functional problems since the call to create the name
	is called before this call - FND_DOCUMENT_SEQUENCES_S.nextval has already been
	fired and a duplicate name will not be generated - we do have an unused DB Seq
	hanging around, but the odds of this happing are low since this the last thing
	we do before the insert */
procedure create_db_seq (	db_seq_name	in	fnd_document_sequences.db_sequence_name%TYPE,
							init_value	in	fnd_document_sequences.initial_value%TYPE )
is
	v_ddl_sql		varchar2(150);
	v_fnd_schema	fnd_oracle_userid.oracle_username%TYPE;
	v_stage			number := 0;  /* sets the stage of execution for exception processing */

begin
	-- First get the FND schema name
	SELECT	fou.oracle_username into v_fnd_schema
	FROM	fnd_product_installations fpi,
			fnd_oracle_userid fou,
			fnd_application fa
	WHERE	fpi.application_id = fa.application_id
	AND		fpi.oracle_id = fou.oracle_id
	AND		fa.application_short_name = 'FND';

	-- actually create the DB seq using the magic of AD_DDL
	v_stage := 1;
	v_ddl_sql := 'CREATE SEQUENCE ' || db_seq_name ||
		' MINVALUE 1 NOMAXVALUE START WITH ' || init_value ||
		' NOCACHE ORDER NOCYCLE';
	ad_ddl.do_ddl( v_fnd_schema, 'FND', ad_ddl.create_sequence,
			v_ddl_sql, db_seq_name );

    exception
    	when others then
	        fnd_message.set_name('FND', 'SQL-GENERIC ERROR');
	        fnd_message.set_token('ERRNO', sqlcode, FALSE);
	        fnd_message.set_token('ROUTINE', 'create_db_seq', FALSE);
	        fnd_message.set_token('REASON', sqlerrm, FALSE);
	        fnd_message.set_token('ERRFILE', 'AFSQNUMB.pls', FALSE);
	        IF v_stage = 0 THEN
		        fnd_message.set_token('SQLSTMT', 'SELECT fou.oracle_username into v_fnd_schema ...', FALSE);
	        ELSE
		        fnd_message.set_token('SQLSTMT', ad_ddl.error_buf, FALSE);
		    END IF;
	        app_exception.raise_exception;

end create_db_seq;

/*
 * This function replaces or performs the actions of the 'C' code function fdssop()
 * Please see the comments in the spec file for usage information
 */
function get_seq_info (	app_id			in number,
						cat_code		in varchar2,
					    sob_id			in number,
					    met_code		in char,
					    trx_date		in date,
					    docseq_id		out nocopy number,
					    docseq_type		out nocopy char,
					    docseq_name		out nocopy varchar2,
						db_seq_name		out nocopy varchar2,
						seq_ass_id		out nocopy number,
						prd_tab_name	out nocopy varchar2,
						aud_tab_name	out nocopy varchar2,
						msg_flag		out nocopy char,
					    suppress_error	in char default 'N',
					    suppress_warn	in char default 'N'
					    ) return number
is
	v_profVal	varchar2(40);
begin

	/* Check to if the cache has been initialized */
	IF v_SeqInfoCache.initFlag THEN
		/* Check to see if the data in the cache has the 4 key values and the transaction date
			is still in range for this assignment */
		IF ( v_SeqInfoCache.app_id = app_id ) AND ( v_SeqInfoCache.cat_code = cat_code ) AND
		  ( v_SeqInfoCache.sob_id = sob_id ) AND ( v_SeqInfoCache.met_code = met_code ) AND
		  ( trx_date >= v_SeqInfoCache.startDate ) AND ( trx_date <= v_SeqInfoCache.endDate ) THEN
			IF v_SeqInfoCache.retStat = FND_SEQNUM.SEQSUCC THEN
			/* if we had a good status from the first select use the cache to populate this
				request's output parameters */
				docseq_id := v_SeqInfoCache.docseq_id;
				docseq_type := v_SeqInfoCache.docseq_type;
				docseq_name := v_SeqInfoCache.docseq_name;
				db_seq_name := v_SeqInfoCache.db_seq_name;
				seq_ass_id := v_SeqInfoCache.seq_ass_id;
				prd_tab_name := v_SeqInfoCache.prd_tab_name;
				aud_tab_name := v_SeqInfoCache.aud_tab_name;
				msg_flag := v_SeqInfoCache.msg_flag;
			END IF; /* retStat */
			/* if the status was bad last time, it still is and the data is not used
				so we just pass the same bad status again - i am not sure the
				functional app would call us twice in the same session with the
				same parameters after the first fail but if they do lets not waste
				the select time ... */
			return( v_SeqInfoCache.retStat );
		END IF; /* parameter compare */
		/* During a session the initFlag will always be TRUE after the first call but
			since the parameters have changed we will just drop through  and start anew */
	END IF; /* initFlag */

	/* No cache or new parameters - so load the parameters into the cache */
	v_SeqInfoCache.app_id := app_id;
	v_SeqInfoCache.cat_code := cat_code;
	v_SeqInfoCache.sob_id := sob_id;
	v_SeqInfoCache.met_code := met_code;
	v_SeqInfoCache.startDate := trx_date + 1;
	v_SeqInfoCache.endDate := trx_date - 1;
	v_SeqInfoCache.initFlag := TRUE;

	/* This call will retrieve the value of the "Sequential Numbering" profile option
	   'A' = Always Used, 'N' = Not Used, 'P' = Partially Used */
	FND_PROFILE.GET( 'UNIQUE:SEQ_NUMBERS', v_profVal );
	IF  v_profVal = 'N' THEN
		v_SeqInfoCache.retStat := FND_SEQNUM.NOTUSED;
		return( v_SeqInfoCache.retStat );
	ELSIF v_profVal <> 'P' AND v_profVal <> 'A' THEN
		v_SeqInfoCache.retStat := FND_SEQNUM.BADPROF;
		fnd_message.set_name( 'FND', 'PROFILES-VALUES' ); -- this should never happen, BUT...
		app_exception.raise_exception;
		return( v_SeqInfoCache.retStat );
	END IF; /* v_profVal */

	/* do our select into the cache */
	select	SEQ.DOC_SEQUENCE_ID, SEQ.TYPE, SEQ.NAME,
			SEQ.AUDIT_TABLE_NAME, SEQ.DB_SEQUENCE_NAME, SEQ.TABLE_NAME,
			SA.DOC_SEQUENCE_ASSIGNMENT_ID, SEQ.MESSAGE_FLAG,
			SA.START_DATE, SA.END_DATE
	into	v_SeqInfoCache.docseq_id, v_SeqInfoCache.docseq_type, v_SeqInfoCache.docseq_name,
			v_SeqInfoCache.aud_tab_name, v_SeqInfoCache.db_seq_name, v_SeqInfoCache.prd_tab_name,
			v_SeqInfoCache.seq_ass_id, v_SeqInfoCache.msg_flag,
			v_SeqInfoCache.startDate, v_SeqInfoCache.endDate
	from 	FND_DOCUMENT_SEQUENCES SEQ, FND_DOC_SEQUENCE_ASSIGNMENTS SA
	where 	SEQ.DOC_SEQUENCE_ID = SA.DOC_SEQUENCE_ID and
			SA.APPLICATION_ID = v_SeqInfoCache.app_id and
			SA.CATEGORY_CODE = v_SeqInfoCache.cat_code and
			( SA.SET_OF_BOOKS_ID = v_SeqInfoCache.sob_id or SA.SET_OF_BOOKS_ID is NULL ) and
		/* bug 1354846 -  add the NULL compare to v_SeqInfoCache.met_code so the
		assignment query can check for either type */
			( SA.METHOD_CODE = v_SeqInfoCache.met_code or SA.METHOD_CODE is NULL
				or v_SeqInfoCache.met_code is NULL ) and
		/* bug 1019289, 1295363 - change between to add .9999 to end date and trx_date */
			trx_date between SA.START_DATE and nvl( SA.END_DATE + .9999, trx_date + .9999 );

	/* Load the output parameters  from the newly filled cache */
	docseq_id := v_SeqInfoCache.docseq_id;
	docseq_type := v_SeqInfoCache.docseq_type;
	docseq_name := v_SeqInfoCache.docseq_name;
	db_seq_name := v_SeqInfoCache.db_seq_name;
	seq_ass_id := v_SeqInfoCache.seq_ass_id;
	prd_tab_name := v_SeqInfoCache.prd_tab_name;
	aud_tab_name := v_SeqInfoCache.aud_tab_name;
	msg_flag := v_SeqInfoCache.msg_flag;
	v_SeqInfoCache.retStat := FND_SEQNUM.SEQSUCC;

	return( v_SeqInfoCache.retStat );

	exception
		when no_data_found then
			/* 'A' = Always Used, 'N' = Not Used, 'P' = Partially Used */
			IF v_profVal = 'P' THEN
				v_SeqInfoCache.retStat := FND_SEQNUM.NOASSIGN;
				IF upper(suppress_warn) = 'N' THEN
					fnd_message.set_name( 'FND', 'UNIQUE-NO ASSIGNMENT' );
					app_exception.raise_exception;
				END IF;
			ELSIF v_profVal = 'A' THEN
				v_SeqInfoCache.retStat := FND_SEQNUM.ALWAYS;
				IF upper(suppress_error) = 'N' THEN
					fnd_message.set_name( 'FND', 'UNIQUE-ALWAYS USED' );
					app_exception.raise_exception;
				END IF;
			END IF;
			return( v_SeqInfoCache.retStat );

		when others then
			v_SeqInfoCache.retStat := FND_SEQNUM.ORAFAIL;
			fnd_message.set_name( 'FND', 'SQL-GENERIC ERROR' );
			fnd_message.set_token( 'ERRNO', sqlcode, FALSE );
			fnd_message.set_token( 'ROUTINE', 'get_seq_info', FALSE );
			fnd_message.set_token( 'REASON', sqlerrm, FALSE );
			fnd_message.set_token( 'ERRFILE', 'AFSQNUMB.pls', FALSE );
			fnd_message.set_token( 'SQLSTMT', 'select SEQ.DOC_SEQUENCE_ID, SEQ.TYPE, SEQ.NAME ...', FALSE );
			app_exception.raise_exception;
			return( v_SeqInfoCache.retStat );

end get_seq_info;

/*
 * This finction creates an audit record in the audit table for the current DocSeq
 * Fix Bug 1073084 - changed to use EXECUTE IMMEDIATE instead of dbms_sql.
 */
function create_audit_rec (	aud_tab_name	in varchar2,
							docseq_id		in number,
							seq_val 		in number,
							seq_ass_id		in number,
							user_id			in number
							) return number
is
	v_proc_stmt		varchar2(500);
	v_row_processed	integer;
begin


	v_proc_stmt := 'INSERT INTO ' || aud_tab_name || ' (DOC_SEQUENCE_ID, DOC_SEQUENCE_VALUE, ' ||
			'DOC_SEQUENCE_ASSIGNMENT_ID, CREATION_DATE, CREATED_BY) VALUES ( :seq_id, :val, ' ||
			':asgn_id, sysdate, :cr_by)';
	EXECUTE IMMEDIATE v_proc_stmt USING docseq_id, seq_val, seq_ass_id, user_id;
	return( FND_SEQNUM.SEQSUCC );

	exception
		when dup_val_on_index then
			fnd_message.set_name( 'FND', 'UNIQUE-DUPLICATE SEQUENCE' );
			app_exception.raise_exception;
			return( FND_SEQNUM.NOTUNIQ );
		when others then
			fnd_message.set_name( 'FND', 'SQL-GENERIC ERROR' );
			fnd_message.set_token( 'ERRNO', sqlcode, FALSE );
			fnd_message.set_token( 'ROUTINE', 'create_audit_rec', FALSE );
			fnd_message.set_token( 'REASON', sqlerrm, FALSE );
			fnd_message.set_token( 'ERRFILE', 'AFSQNUMB.pls', FALSE );
			fnd_message.set_token( 'SQLSTMT', v_proc_stmt, FALSE );
			app_exception.raise_exception;
			return( FND_SEQNUM.ORAFAIL );

end create_audit_rec;

/*
 * This function replaces/performs the actions of the user exit #FND SEQVAL
 * Please see the comments in the spec file for usage information
 */
function get_seq_val (	app_id			in number,
						cat_code		in varchar2,
					    sob_id			in number,
					    met_code		in char,
					    trx_date		in date,
					    seq_val 		in out nocopy number,
					    docseq_id		out nocopy number,
					    suppress_error	in char default 'N',
					    suppress_warn	in char default 'N'
					    ) return number
is
	v_seqType 	char;
	v_seqName	varchar2(30);
	v_dbSeqNm	varchar2(30);
	v_seqAssID	number;
	v_prdTabNm	varchar2(30);
	v_audTabNm	varchar2(30);
	v_msgFlg	char;
	v_stat		number;
	v_profVal	varchar2(70);
	v_docSeqId	number;
begin

	/* Get all the needed Doc_Seq info */
	v_stat := get_seq_info( app_id, cat_code, sob_id, met_code, trx_date, v_docSeqId, v_seqType,
		v_seqName, v_dbSeqNm, v_seqAssID, v_prdTabNm, v_audTabNm, v_msgFlg, suppress_error, suppress_warn );
	docseq_id := v_docSeqId;
	IF v_stat <> FND_SEQNUM.SEQSUCC THEN
		IF v_stat = FND_SEQNUM.NOTUSED THEN
			/* the profile is set to not used so we just return peacefully */
			return( FND_SEQNUM.SEQSUCC );
		ELSIF  v_stat = FND_SEQNUM.NOASSIGN THEN
			/* we found nothing but the profile is only set to partial so that is OK BUT,
			we would have given a warning in get_seq_info() based on the suppress_warn flag */
			return( FND_SEQNUM.SEQSUCC );
		ELSE
			return( v_stat );
		END IF;
	END IF;

	/* This call will retrieve the value of the "USER_ID" profile option */
	FND_PROFILE.GET( 'USER_ID', v_profVal );
	IF v_profVal IS NULL THEN
		fnd_message.set_name( 'FND', 'USER' ); -- this should never happen, BUT...
		app_exception.raise_exception;
		return( FND_SEQNUM.BADPROF );
	END IF;
	/* we found a good Doc_Seq assignment so we proceed ...
	first we check the Seq Type from the FND_DOCUMENT_SEQUENCES.TYPE - valid values are :
	'A' = Automatic, 'G' = Gapless and 'M' = Manual
	'U' = Auto by User - but it is not really working - never has(??) */
	IF v_seqType = 'A' THEN
		seq_val := get_next_auto_seq( v_dbSeqNm );
	ELSIF v_seqType = 'G' THEN
		seq_val := get_next_user_sequence( 0, v_seqAssID, v_docSeqId );
	ELSIF v_seqType = 'U' THEN
		seq_val := get_next_user_sequence( to_number(v_profVal), v_seqAssID, v_docSeqId );
	ELSIF v_seqType = 'M' THEN
		IF seq_val IS NULL THEN
			fnd_message.set_name( 'FND', 'UNIQUE-NO VALUE' );
			fnd_message.set_token( 'SEQUENCE', v_seqName, FALSE );
			app_exception.raise_exception;
			return( FND_SEQNUM.NOVALUE );
		END IF;
		/* i don't actually have a routine to check the uniqueness of the Manual DocSeq
		like they did in the 'C' code since the very next call from #FND SEQVAL updates
		the audit record - where we can trap the error and report it.  If there is a
		requirement for an equivalent to #FND SEQCHK we can write it seperately */
	ELSE
		 -- this should never happen, unless someone uses sqlplus on our tables form validates value...
		return( FND_SEQNUM.BADTYPE );
	END IF;

	v_stat := create_audit_rec( v_audTabNm, v_docSeqId, seq_val, v_seqAssID, to_number(v_profVal) );
	/* we could/should test this return stat but every thing we can handle is handled
		in the routine so lets just pass it on, and use it for debug on the wierd error */
	return( v_stat );

end get_seq_val;

/*
 * This function is for special internal Applications use to create new Document
 * Sequences in batch form by the Product teams for upgrades or coversions
 */
function define_doc_seq (
		app_id			in number,
		docseq_name		in fnd_document_sequences.name%TYPE,
		docseq_type		in fnd_document_sequences.type%TYPE,
		msg_flag		in fnd_document_sequences.message_flag%TYPE,
		init_value		in fnd_document_sequences.initial_value%TYPE,
		p_startDate		in date,
		p_endDate		in date default NULL
		) return number
is
	v_numRows	number;
	v_audTabNm	fnd_document_sequences.audit_table_name%TYPE;
	v_docSeqId	number;
	v_dbSeqNm	fnd_document_sequences.db_sequence_name%TYPE;
	v_startDate	date;
	v_endDate	date;
begin

	begin /* APPLICATION_ID check block */
		select count( APPLICATION_ID ) into v_numRows
		from FND_APPLICATION where APPLICATION_ID = app_id;
		IF v_numRows = 0 THEN
			return ( FND_SEQNUM.BADAPPID );
		END IF;
	exception
		when others then
			fnd_message.set_name( 'FND', 'SQL-GENERIC ERROR' );
			fnd_message.set_token( 'ERRNO', sqlcode, FALSE );
			fnd_message.set_token( 'ROUTINE', 'define_doc_seq', FALSE );
			fnd_message.set_token( 'REASON', sqlerrm, FALSE );
			fnd_message.set_token( 'ERRFILE', 'AFSQNUMB.pls', FALSE );
			fnd_message.set_token( 'SQLSTMT', 'select count from FND_APPLICATION where APPLICATION_ID = ' || to_char(app_id), FALSE );
			app_exception.raise_exception;
			return( FND_SEQNUM.ORAFAIL );
	end;	/* APPLICATION_ID check block */

	begin /* FND_DOCUMENT_SEQUENCES.NAME uniqueness check block */
		select count( NAME ) into v_numRows
		from FND_DOCUMENT_SEQUENCES where NAME = docseq_name;
		IF v_numRows > 0 THEN
			return ( FND_SEQNUM.DUPNAME );
		END IF;
	exception
		when others then
			fnd_message.set_name( 'FND', 'SQL-GENERIC ERROR' );
			fnd_message.set_token( 'ERRNO', sqlcode, FALSE );
			fnd_message.set_token( 'ROUTINE', 'define_doc_seq', FALSE );
			fnd_message.set_token( 'REASON', sqlerrm, FALSE );
			fnd_message.set_token( 'ERRFILE', 'AFSQNUMB.pls', FALSE );
			fnd_message.set_token( 'SQLSTMT', 'select count from FND_DOCUMENT_SEQUENCES where NAME = ' || docseq_name, FALSE );
			app_exception.raise_exception;
			return( FND_SEQNUM.ORAFAIL );
	end;	/* NAME check block */
/* validate the type */
	-- IF docseq_type NOT IN ( 'A', 'G', 'M', 'U' ) THEN  /* we do not do User any more ?? */
	IF docseq_type NOT IN ( 'A', 'G', 'M' ) THEN
		return( FND_SEQNUM.BADTYPE );
	END IF;
/* validate the message_flag */
	IF msg_flag NOT IN ( 'Y', 'N' ) THEN
		return( FND_SEQNUM.BADFLAG );
	END IF;
/* basic sanity on the dates only ???
	first the forms format mask only allows whole dates no hours so ... */
	v_startDate := trunc( p_startDate );
	v_endDate := trunc( p_endDate );
	IF p_endDate <> NULL THEN
		IF v_startDate >= v_endDate THEN
			return( FND_SEQNUM.BADDATE );
		END IF;
	END IF;
/* this Audit Table name decode is also in the form FNDSNDSQ so change both if any */
	begin /* make Audit Table name block */
		select DECODE(app_id,0,'FND',	1,'FND',	101,'GL',	111,'RA',	140,'FA',
			160,'ALR',	168,'RG',	200,'AP',	201,'PO',	222,'AR',	260,'CE',
			300,'OE',	401,'INV',	500,'SA',	700,'MFG',	702,'BOM',	703,'ENG',
			704,'MRP',	705,'CRP',	706,'WIP',	800,'PER',	801,'PAY',	802,'FF',
			803,'DT',	804,'SSP',	7000,'JA',	7002,'JE',	7003,'JG',	7004,'JL',
			'FND') || '_DOC_SEQUENCE_AUDIT' into v_audTabNm from dual;
	exception
		when others then
			fnd_message.set_name( 'FND', 'SQL-GENERIC ERROR' );
			fnd_message.set_token( 'ERRNO', sqlcode, FALSE );
			fnd_message.set_token( 'ROUTINE', 'define_doc_seq', FALSE );
			fnd_message.set_token( 'REASON', sqlerrm, FALSE );
			fnd_message.set_token( 'ERRFILE', 'AFSQNUMB.pls', FALSE );
			fnd_message.set_token( 'SQLSTMT', 'select DECODE(' || to_char(app_id) || '...) from dual', FALSE );
			app_exception.raise_exception;
			return( FND_SEQNUM.ORAFAIL );
	end;	/* Audit Table name block */

/* hopefully we have checked enough to do an insert so lets pop the id sequence */
	begin /* get next DOC_SEQUENCE_ID block */
		select FND_DOCUMENT_SEQUENCES_S.nextval into v_docSeqId from dual;
	exception
		when others then
			fnd_message.set_name( 'FND', 'SQL-GENERIC ERROR' );
			fnd_message.set_token( 'ERRNO', sqlcode, FALSE );
			fnd_message.set_token( 'ROUTINE', 'define_doc_seq', FALSE );
			fnd_message.set_token( 'REASON', sqlerrm, FALSE );
			fnd_message.set_token( 'ERRFILE', 'AFSQNUMB.pls', FALSE );
			fnd_message.set_token( 'SQLSTMT', 'select FND_DOCUMENT_SEQUENCES_S.nextval from dual', FALSE );
			app_exception.raise_exception;
			return( FND_SEQNUM.ORAFAIL );
	end;	/* FND_DOCUMENT_SEQUENCES_S block */

	IF docseq_type = 'A' THEN
		v_dbSeqNm := 'FND_DOC_SEQ_'|| to_char(v_docSeqId) || '_S';
		FND_SEQNUM.create_db_seq( v_dbSeqNm, init_value );
	ELSE
		v_dbSeqNm := NULL;
	END IF;

	insert into FND_DOCUMENT_SEQUENCES ( DOC_SEQUENCE_ID, NAME, APPLICATION_ID,
		AUDIT_TABLE_NAME, DB_SEQUENCE_NAME, MESSAGE_FLAG, TYPE, INITIAL_VALUE,
		START_DATE, END_DATE, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE,
		CREATED_BY, LAST_UPDATE_LOGIN )
	values ( v_docSeqId, docseq_name, app_id, v_audTabNm, v_dbSeqNm, msg_flag,
		docseq_type, init_value, v_startDate, v_endDate, SYSDATE, FND_GLOBAL.USER_ID,
		SYSDATE, FND_GLOBAL.USER_ID, FND_GLOBAL.LOGIN_ID );

-- ok i assume all is well let's return SEQSUCC
	return( FND_SEQNUM.SEQSUCC );

exception
	when others then
		fnd_message.set_name( 'FND', 'SQL-GENERIC ERROR' );
		fnd_message.set_token( 'ERRNO', sqlcode, FALSE );
		fnd_message.set_token( 'ROUTINE', 'define_doc_seq', FALSE );
		fnd_message.set_token( 'REASON', sqlerrm, FALSE );
		fnd_message.set_token( 'ERRFILE', 'AFSQNUMB.pls', FALSE );
		fnd_message.set_token( 'SQLSTMT', 'insert into FND_DOCUMENT_SEQUENCES ..' || docseq_name || '...', FALSE );
		app_exception.raise_exception;
		return( FND_SEQNUM.ORAFAIL );

end define_doc_seq;

/*
 * This function is for special internal Applications use to create new Doc_Seq
 * Assignments in batch form by the Product teams for upgrades or coversions
 */
function assign_doc_seq (
		app_id			in number,
		docseq_name		in fnd_document_sequences.name%TYPE,
		cat_code		in fnd_doc_sequence_assignments.category_code%TYPE,
		sob_id			in fnd_doc_sequence_assignments.set_of_books_id%TYPE,
		met_code		in fnd_doc_sequence_assignments.method_code%TYPE,
		p_startDate		in date,
		p_endDate		in date default NULL
		) return number
is
	v_seqAssID	number;
	v_docSeqId	number;
	v_type		fnd_document_sequences.type%TYPE;
	v_prdTabNm	fnd_document_sequences.table_name%TYPE;
	v_enabled	fnd_descr_flex_column_usages.enabled_flag%TYPE;
	v_numRows	number;
	v_startDate	date;
	v_endDate	date;
begin

	begin /* APPLICATION_ID check block */
		select count( APPLICATION_ID ) into v_numRows
		from FND_APPLICATION where APPLICATION_ID = app_id;
		IF v_numRows = 0 THEN
			return ( FND_SEQNUM.BADAPPID );
		END IF;
	exception
		when others then
			fnd_message.set_name( 'FND', 'SQL-GENERIC ERROR' );
			fnd_message.set_token( 'ERRNO', sqlcode, FALSE );
			fnd_message.set_token( 'ROUTINE', 'assign_doc_seq', FALSE );
			fnd_message.set_token( 'REASON', sqlerrm, FALSE );
			fnd_message.set_token( 'ERRFILE', 'AFSQNUMB.pls', FALSE );
			fnd_message.set_token( 'SQLSTMT', 'select count from FND_APPLICATION where APPLICATION_ID = ' || to_char(app_id), FALSE );
			app_exception.raise_exception;
			return( FND_SEQNUM.ORAFAIL );
	end;	/* APPLICATION_ID check block */

	begin	/* FND_DOCUMENT_SEQUENCES.NAME check block */
		select DOC_SEQUENCE_ID, TYPE into v_docSeqId, v_type
		from FND_DOCUMENT_SEQUENCES where NAME = docseq_name;
	exception
		when NO_DATA_FOUND then
			return( FND_SEQNUM.BADNAME );
		when others then
			fnd_message.set_name( 'FND', 'SQL-GENERIC ERROR' );
			fnd_message.set_token( 'ERRNO', sqlcode, FALSE );
			fnd_message.set_token( 'ROUTINE', 'assign_doc_seq', FALSE );
			fnd_message.set_token( 'REASON', sqlerrm, FALSE );
			fnd_message.set_token( 'ERRFILE', 'AFSQNUMB.pls', FALSE );
			fnd_message.set_token( 'SQLSTMT', 'select DOC_SEQUENCE_ID from FND_DOCUMENT_SEQUENCES where NAME = ' || docseq_name, FALSE );
			app_exception.raise_exception;
			return( FND_SEQNUM.ORAFAIL );
	end;	/* NAME check block */

	begin	/* get the table name for category_code */
		select TABLE_NAME into v_prdTabNm from FND_DOC_SEQUENCE_CATEGORIES
		where CODE = cat_code and APPLICATION_ID = app_id;
	exception
		when NO_DATA_FOUND then
			return( FND_SEQNUM.BADCODE );
		when others then
			fnd_message.set_name( 'FND', 'SQL-GENERIC ERROR' );
			fnd_message.set_token( 'ERRNO', sqlcode, FALSE );
			fnd_message.set_token( 'ROUTINE', 'assign_doc_seq', FALSE );
			fnd_message.set_token( 'REASON', sqlerrm, FALSE );
			fnd_message.set_token( 'ERRFILE', 'AFSQNUMB.pls', FALSE );
			fnd_message.set_token( 'SQLSTMT', 'select TABLE_NAME from FND_DOC_SEQUENCE_CATEGORIES where CODE = ' || cat_code, FALSE );
			app_exception.raise_exception;
			return( FND_SEQNUM.ORAFAIL );
	end;	/* table name for category_code block */

	begin	/* check for Set of Books in Document Flexfield */
		select ENABLED_FLAG into v_enabled from FND_DESCR_FLEX_COLUMN_USAGES
		where APPLICATION_ID = 0 and APPLICATION_COLUMN_NAME = 'SET_OF_BOOKS_ID'
		and DESCRIPTIVE_FLEXFIELD_NAME = 'Document Flexfield'
		and DESCRIPTIVE_FLEX_CONTEXT_CODE = 'Global Data Elements';
		IF v_enabled = 'Y' THEN
			begin	/* verify the Set of Books ID */
				select count( SET_OF_BOOKS_ID ) into v_numRows
				from GL_SETS_OF_BOOKS where SET_OF_BOOKS_ID = sob_id;
				IF v_numRows = 0 THEN
					return ( FND_SEQNUM.BADSOB );
				END IF;
			exception
				when others then
					fnd_message.set_name( 'FND', 'SQL-GENERIC ERROR' );
					fnd_message.set_token( 'ERRNO', sqlcode, FALSE );
					fnd_message.set_token( 'ROUTINE', 'assign_doc_seq', FALSE );
					fnd_message.set_token( 'REASON', sqlerrm, FALSE );
					fnd_message.set_token( 'ERRFILE', 'AFSQNUMB.pls', FALSE );
					fnd_message.set_token( 'SQLSTMT', 'select count from GL_SETS_OF_BOOKS where SET_OF_BOOKS_ID = ' || to_char( sob_id ), FALSE );
					app_exception.raise_exception;
					return( FND_SEQNUM.ORAFAIL );
			end;	/* SOB block */
		END IF;
	exception
		when others then
			fnd_message.set_name( 'FND', 'SQL-GENERIC ERROR' );
			fnd_message.set_token( 'ERRNO', sqlcode, FALSE );
			fnd_message.set_token( 'ROUTINE', 'assign_doc_seq', FALSE );
			fnd_message.set_token( 'REASON', sqlerrm, FALSE );
			fnd_message.set_token( 'ERRFILE', 'AFSQNUMB.pls', FALSE );
			fnd_message.set_token( 'SQLSTMT', 'select ENABLED_FLAG from ... SET_OF_BOOKS_ID', FALSE );
			app_exception.raise_exception;
			return( FND_SEQNUM.ORAFAIL );
	end;	/* Document Flexfield block */

	begin	/* check for Method Code in Document Flexfield */
		select ENABLED_FLAG into v_enabled from FND_DESCR_FLEX_COLUMN_USAGES
		where APPLICATION_ID = 0 and APPLICATION_COLUMN_NAME = 'METHOD_CODE'
		and DESCRIPTIVE_FLEXFIELD_NAME = 'Document Flexfield'
		and DESCRIPTIVE_FLEX_CONTEXT_CODE = 'Global Data Elements';
		IF v_enabled = 'Y' THEN
			IF met_code NOT IN ( 'A', 'M', NULL ) THEN
				return( FND_SEQNUM.BADMTHD );
			END IF;
		END IF;
	exception
		when others then
			fnd_message.set_name( 'FND', 'SQL-GENERIC ERROR' );
			fnd_message.set_token( 'ERRNO', sqlcode, FALSE );
			fnd_message.set_token( 'ROUTINE', 'assign_doc_seq', FALSE );
			fnd_message.set_token( 'REASON', sqlerrm, FALSE );
			fnd_message.set_token( 'ERRFILE', 'AFSQNUMB.pls', FALSE );
			fnd_message.set_token( 'SQLSTMT', 'select ENABLED_FLAG from ... METHOD_CODE', FALSE );
			app_exception.raise_exception;
			return( FND_SEQNUM.ORAFAIL );
	end;	/* Document Flexfield block */

	begin	/* DATE check - again most of this code in forms so dual maintain */
		-- first the forms format mask only allows whole dates no hours so ...
		v_startDate := trunc( p_startDate );
		v_endDate := trunc( p_endDate );
		IF v_endDate is NULL THEN
			-- see if any rows of this document exist with a null end date.
			select	count( DOC_SEQUENCE_ASSIGNMENT_ID ) into v_numRows
			from	FND_DOC_SEQUENCE_ASSIGNMENTS
			where	CATEGORY_CODE = cat_code
			and		NVL( METHOD_CODE, 'NONE' ) = NVL( met_code, 'NONE' )
			and		APPLICATION_ID = app_id
			and		NVL( SET_OF_BOOKS_ID, 0 ) = NVL( sob_id, 0 )
			and		END_DATE IS NULL;
			IF v_numRows > 0  THEN
				-- ERROR!  there is another row with a null end_date!
				FND_MESSAGE.SET_NAME('FND','UNIQUE-NULL END DATE');
				return( FND_SEQNUM.BADDATE ); /* comment out this line and uncomment the next for debugging */
				-- app_exception.raise_exception;
			ELSE
				-- See if there is another row for this document with dates that overlap
				select	count( DOC_SEQUENCE_ASSIGNMENT_ID ) into v_numRows
				from	FND_DOC_SEQUENCE_ASSIGNMENTS
				where	CATEGORY_CODE = cat_code
				and		NVL( METHOD_CODE, 'NONE' ) = NVL( met_code, 'NONE' )
				and		APPLICATION_ID = app_id
				and		NVL( SET_OF_BOOKS_ID, 0 ) = NVL( sob_id, 0 )
				and		v_startDate <= END_DATE;
				IF v_numRows > 0  THEN
					-- ERROR!  there is a date overlap problem.
					FND_MESSAGE.SET_NAME('FND','UNIQUE-DATE OVERLAP');
					return( FND_SEQNUM.BADDATE ); /* comment out this line and uncomment the next for debugging */
					-- app_exception.raise_exception;
				END IF;
			END IF;
		ELSE
			-- see if there is another row in the database for the same document
			select	count( DOC_SEQUENCE_ASSIGNMENT_ID ) into v_numRows
			from	FND_DOC_SEQUENCE_ASSIGNMENTS
			where	CATEGORY_CODE = cat_code
			and		NVL( METHOD_CODE, 'NONE' ) = NVL( met_code, 'NONE' )
			and		APPLICATION_ID = app_id
			and		NVL( SET_OF_BOOKS_ID, 0 ) = NVL( sob_id, 0 );
			IF v_numRows > 0  THEN
				select	count( DOC_SEQUENCE_ASSIGNMENT_ID ) into v_numRows
				from	FND_DOC_SEQUENCE_ASSIGNMENTS
				where	CATEGORY_CODE = cat_code
				and		NVL( METHOD_CODE, 'NONE' ) = NVL( met_code, 'NONE' )
				and		APPLICATION_ID = app_id
				and		NVL( SET_OF_BOOKS_ID, 0 ) = NVL( sob_id, 0 )
				and
				(	( v_startDate >= START_DATE and v_startDate <= NVL(END_DATE, v_endDate) )
				or	( v_endDate >= START_DATE and v_endDate <= NVL(END_DATE, v_endDate) )
				or	( v_endDate <= START_DATE and v_endDate >= NVL(END_DATE, v_endDate + 1) ) );
				IF v_numRows > 0  THEN
					-- ERROR!  there is a date overlap problem.
					FND_MESSAGE.SET_NAME('FND','UNIQUE-DATE OVERLAP');
					return( FND_SEQNUM.BADDATE ); /* comment out this line and uncomment the next for debugging */
					-- app_exception.raise_exception;
				END IF;
			END IF;
		END IF;
	exception
		when others then
			fnd_message.set_name( 'FND', 'SQL-GENERIC ERROR' );
			fnd_message.set_token( 'ERRNO', sqlcode, FALSE );
			fnd_message.set_token( 'ROUTINE', 'assign_doc_seq', FALSE );
			fnd_message.set_token( 'REASON', sqlerrm, FALSE );
			fnd_message.set_token( 'ERRFILE', 'AFSQNUMB.pls', FALSE );
			fnd_message.set_token( 'SQLSTMT', 'select count( DOC_SEQUENCE_ASSIGNMENT_ID ) .. DATE checks', FALSE );
			app_exception.raise_exception;
			return( FND_SEQNUM.ORAFAIL );
	end;	/* DATE check block */

/* hopefully we have checked enough to do an insert so lets pop the id sequence */
	begin /* get next DOC_SEQUENCE_ASSIGNMENT_ID block */
		select FND_DOC_SEQUENCE_ASSIGNMENTS_S.nextval into v_seqAssID from dual;
	exception
		when others then
			fnd_message.set_name( 'FND', 'SQL-GENERIC ERROR' );
			fnd_message.set_token( 'ERRNO', sqlcode, FALSE );
			fnd_message.set_token( 'ROUTINE', 'define_doc_seq', FALSE );
			fnd_message.set_token( 'REASON', sqlerrm, FALSE );
			fnd_message.set_token( 'ERRFILE', 'AFSQNUMB.pls', FALSE );
			fnd_message.set_token( 'SQLSTMT', 'select FND_DOC_SEQUENCE_ASSIGNMENTS_S.nextval from dual', FALSE );
			app_exception.raise_exception;
			return( FND_SEQNUM.ORAFAIL );
	end;	/* FND_DOC_SEQUENCE_ASSIGNMENTS_S block */

	insert into FND_DOC_SEQUENCE_ASSIGNMENTS ( DOC_SEQUENCE_ASSIGNMENT_ID, DOC_SEQUENCE_ID,
		APPLICATION_ID, CATEGORY_CODE, SET_OF_BOOKS_ID, METHOD_CODE, START_DATE, END_DATE,
		LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN )
	values ( v_seqAssID, v_docSeqId, app_id, cat_code, sob_id, met_code, v_startDate, v_endDate,
		SYSDATE, FND_GLOBAL.USER_ID, SYSDATE, FND_GLOBAL.USER_ID, FND_GLOBAL.LOGIN_ID );

	begin	/* update the table name for the Doc_Seq */
		UPDATE FND_DOCUMENT_SEQUENCES
		set TABLE_NAME = v_prdTabNm
		where DOC_SEQUENCE_ID = v_docSeqId;
	exception
		when others then
			fnd_message.set_name( 'FND', 'SQL-GENERIC ERROR' );
			fnd_message.set_token( 'ERRNO', sqlcode, FALSE );
			fnd_message.set_token( 'ROUTINE', 'assign_doc_seq', FALSE );
			fnd_message.set_token( 'REASON', sqlerrm, FALSE );
			fnd_message.set_token( 'ERRFILE', 'AFSQNUMB.pls', FALSE );
			fnd_message.set_token( 'SQLSTMT', 'update FND_DOCUMENT_SEQUENCES set TABLE_NAME (..' || docseq_name || '..)', FALSE );
			app_exception.raise_exception;
			return( FND_SEQNUM.ORAFAIL );
	end;	/* Doc_Seq update block */

	IF v_type = 'G' THEN
		begin /* Create Gapless check block */
			select count( DOC_SEQUENCE_ID ) into v_numRows
			from FND_DOC_SEQUENCE_USERS where DOC_SEQUENCE_ID = v_docSeqId;
			IF v_numRows = 0 THEN
				v_numRows := FND_SEQNUM.create_gapless_sequence( v_docSeqId );
				IF v_numRows <> 1 THEN
					return( FND_SEQNUM.ORAFAIL );
				END IF;
			END IF;
		exception
			when others then
				fnd_message.set_name( 'FND', 'SQL-GENERIC ERROR' );
				fnd_message.set_token( 'ERRNO', sqlcode, FALSE );
				fnd_message.set_token( 'ROUTINE', 'assign_doc_seq', FALSE );
				fnd_message.set_token( 'REASON', sqlerrm, FALSE );
				fnd_message.set_token( 'ERRFILE', 'AFSQNUMB.pls', FALSE );
				fnd_message.set_token( 'SQLSTMT', 'select count(DOC_SEQUENCE_ID) from FND_DOC_SEQUENCE_USERS', FALSE );
				app_exception.raise_exception;
				return( FND_SEQNUM.ORAFAIL );
		end;	/* Gapless check block */
	END IF;

-- ok i assume all is well let's return SEQSUCC
	return( FND_SEQNUM.SEQSUCC );

exception
	when others then
		fnd_message.set_name( 'FND', 'SQL-GENERIC ERROR' );
		fnd_message.set_token( 'ERRNO', sqlcode, FALSE );
		fnd_message.set_token( 'ROUTINE', 'assign_doc_seq', FALSE );
		fnd_message.set_token( 'REASON', sqlerrm, FALSE );
		fnd_message.set_token( 'ERRFILE', 'AFSQNUMB.pls', FALSE );
		fnd_message.set_token( 'SQLSTMT', 'insert into FND_DOC_SEQUENCE_ASSIGNMENTS (..' || docseq_name || '..)', FALSE );
		app_exception.raise_exception;
		return( FND_SEQNUM.ORAFAIL );

end	assign_doc_seq;

end FND_SEQNUM;


/
