--------------------------------------------------------
--  DDL for Package Body CCT_CHECK_SEQ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_CHECK_SEQ_PKG" AS
/* $Header: cctcksqb.pls 120.0.12010000.1 2008/07/25 23:41:46 appldev ship $ */


-- Check whether the current value of the sequence number is less than the max of
-- the column from the table.
-- If the sequence number is bigger, then do nothing.
-- Otherwise, recreate the sequence with the max of the column from the table

   PROCEDURE check_sequence  (
        table_name      IN VARCHAR2,
        column_name     IN VARCHAR2,
		sequence_name   IN VARCHAR2,
        cct_schema      IN VARCHAR2
         ) IS

    sequence_not_found exception;
    pragma exception_init(sequence_not_found, -942);
	l_missing_sequence VARCHAR2(2000);

	v_cursorID INTEGER;
	v_seq_stmt VARCHAR2(2000);
	l_seq_val VARCHAR2(10);
	v_dummy INTEGER;

	v_cursorID1 INTEGER;
	v_max_stmt VARCHAR2(2000);
	l_max_val VARCHAR2(10);
	v_dummy1 INTEGER;

    v_create_tbl_stmt VARCHAR2(2000);
    v_drop_tbl_stmt VARCHAR2(2000);
    v_inc_stmt VARCHAR2(2000);
    v_ins_stmt VARCHAR2(2000);

    v_new_begin INTEGER;
    diff INTEGER;
    l_num NUMBER;

   BEGIN
	 SAVEPOINT CCTCKSEQ;

	 -- Getting the current Sequence value
	 BEGIN

     	  v_cursorID:=DBMS_SQL.OPEN_CURSOR;
     	  v_seq_stmt:='SELECT '||cct_schema||'.'||sequence_name||'.NEXTVAL from dual';
          --dbms_output.put_line(v_seq_stmt);
	      DBMS_SQL.PARSE(v_cursorID,v_seq_stmt,DBMS_SQL.V7);
          --dbms_output.put_line('after parsing');
	      DBMS_SQL.DEFINE_COLUMN(v_cursorID,1,l_seq_val,10);
          --dbms_output.put_line('after define column');
	      v_dummy:=DBMS_SQL.EXECUTE(v_cursorID);
           --dbms_output.put_line('after execute 1');
	      Loop
	        if DBMS_SQL.FETCH_ROWS(v_cursorID)=0 THEN
            --dbms_output.put_line('exiting');
		    exit;
            end if;
            --dbms_output.put_line('before col valu');
            DBMS_SQL.COLUMN_VALUE(v_cursorID,1,l_seq_val);
            --dbms_output.put_line(l_seq_val);
          END LOOP;
	      DBMS_SQL.CLOSE_CURSOR(v_cursorID);
     Exception
		 When others then
			l_missing_sequence:=sequence_name;
			raise sequence_not_found;
     end;

     -- Getting the max column value from the table
	 BEGIN
     	 v_cursorID1:=DBMS_SQL.OPEN_CURSOR;
     	 v_max_stmt:='SELECT max('||column_name||') from '||cct_schema||'.'||table_name;
         --dbms_output.put_line(v_max_stmt);
	     DBMS_SQL.PARSE(v_cursorID1,v_max_stmt,DBMS_SQL.V7);
         --dbms_output.put_line('after parsing');
	     DBMS_SQL.DEFINE_COLUMN(v_cursorID1,1,l_max_val,10);
         --dbms_output.put_line('after define column');
	     v_dummy1:=DBMS_SQL.EXECUTE(v_cursorID1);
         --dbms_output.put_line('after execute 2');
	     Loop
	       if DBMS_SQL.FETCH_ROWS(v_cursorID1)=0 THEN
           --dbms_output.put_line('exiting');
		     exit;
           end if;
           --dbms_output.put_line('before col valu');
           DBMS_SQL.COLUMN_VALUE(v_cursorID1,1,l_max_val);
           --dbms_output.put_line(l_max_val);
         END LOOP;
	     DBMS_SQL.CLOSE_CURSOR(v_cursorID1);
     Exception
		 When others then
		    raise_application_error(-20000, 'Column '||table_name||':'||column_name||' SQLERRM::'||sqlerrm || '. Could not get the max value.');
     end;

     -- if the sequence value is less than the max column value then bump up the sequence to
     -- max column value, otherwise do nothing
     -- dbms_output.put_line('Sequence='||l_seq_val||', max column='||l_max_val);

     if (to_number(l_seq_val) <= to_number(l_max_val) )
     then
         begin

             v_new_begin := to_number(l_max_val)+1;
             diff := to_number(l_max_val) - to_number(l_seq_val) + 1;
             --dbms_output.put_line('diff is '||diff);
         end;

         begin
             v_inc_stmt:='alter SEQUENCE '||cct_schema||'.'||sequence_name||' INCREMENT BY '||diff;
             --dbms_output.put_line('Increase Sequence stmt='||v_inc_stmt);
             EXECUTE IMMEDIATE v_inc_stmt;

             EXECUTE IMMEDIATE 'select ' || cct_schema||'.'||sequence_name || '.nextval from dual where rownum=1 ' INTO l_num;
--             dbms_output.put_line('Increase Sequence value='||l_num);
             v_inc_stmt:='alter SEQUENCE '||cct_schema||'.'||sequence_name||' INCREMENT BY 1';
             --dbms_output.put_line('Increase Sequence stmt='||v_inc_stmt);
             EXECUTE IMMEDIATE v_inc_stmt;

         Exception
             When others then
                 l_missing_sequence:=sequence_name;
                 raise sequence_not_found;
         end;

	 END IF;

     COMMIT WORK;

     EXCEPTION
         WHEN sequence_not_found THEN
             ROLLBACK TO SAVEPOINT CCTCKSEQ;
             raise_application_error(-20000, 'Sequence '||l_missing_sequence||' not found') ;


         WHEN OTHERS THEN
             ROLLBACK TO SAVEPOINT CCTCKSEQ;
             raise_application_error(-20000, sqlerrm || '. Could not modify sequence')  ;
   END check_sequence;


END cct_check_seq_pkg;

/
