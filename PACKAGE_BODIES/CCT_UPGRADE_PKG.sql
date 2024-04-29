--------------------------------------------------------
--  DDL for Package Body CCT_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_UPGRADE_PKG" AS
/* $Header: cctuupgb.pls 115.22 2004/03/26 00:27:13 sradhakr ship $ */
   PROCEDURE add_column (schema_name IN VARCHAR2,
		 table_name IN VARCHAR2, col_name IN VARCHAR2) IS

     table_not_found exception;
     pragma exception_init(table_not_found, -942);

     duplicate_column exception;
     pragma exception_init(duplicate_column, -1430);
   BEGIN
	 SAVEPOINT CCTUPG;
      EXECUTE IMMEDIATE 'LOCK TABLE ' || schema_name || '.' || table_name
         || ' IN EXCLUSIVE MODE';
      EXECUTE IMMEDIATE 'ALTER TABLE ' || schema_name || '.' || table_name
         || ' ADD ( ' || col_name  || ' NUMBER (15,0) )';
      COMMIT ;  -- used to release the table lock.
   EXCEPTION
      WHEN table_not_found THEN
      COMMIT ;  -- used to release the table lock.
        raise_application_error(-20000, 'Table '||table_name||' not found') ;

      WHEN duplicate_column THEN
      COMMIT ;  -- used to release the table lock.
	   -- not a problem allows the script to be rerun.
	   null;

      WHEN OTHERS THEN
      COMMIT ;  -- used to release the table lock.
        raise_application_error(-20000, sqlerrm || '. Could not add column')  ;
   END ADD_COLUMN;

   -----------------------------------------------------------------------

   PROCEDURE add_varchar_column (schema_name IN VARCHAR2,
		 table_name IN VARCHAR2, col_name IN VARCHAR2) IS

     table_not_found exception;
     pragma exception_init(table_not_found, -942);

     duplicate_column exception;
     pragma exception_init(duplicate_column, -1430);
   BEGIN
	 SAVEPOINT CCTUPG_VAR_COL;
      EXECUTE IMMEDIATE 'LOCK TABLE ' || schema_name || '.' || table_name
         || ' IN EXCLUSIVE MODE';
      EXECUTE IMMEDIATE 'ALTER TABLE ' || schema_name || '.' || table_name
         || ' ADD ( ' || col_name  || ' VARCHAR2 (64) )';
      COMMIT ;  -- used to release the table lock.
   EXCEPTION
      WHEN table_not_found THEN
      COMMIT ;  -- used to release the table lock.
        raise_application_error(-20000, 'Table '||table_name||' not found') ;

      WHEN duplicate_column THEN
      COMMIT ;  -- used to release the table lock.
	   -- not a problem allows the script to be rerun.
	   null;

      WHEN OTHERS THEN
      COMMIT ;  -- used to release the table lock.
        raise_application_error(-20000, sqlerrm || '. Could not add column')  ;
   END ADD_VARCHAR_COLUMN;


   -----------------------------------------------------------------------
   PROCEDURE update_column
         (
	  table_name IN VARCHAR2
          , new_col_name IN VARCHAR2
          , old_col_name IN VARCHAR2
          , new_value IN NUMBER
          , old_value IN NUMBER) IS

     table_not_found exception;
     pragma exception_init(table_not_found, -942);


   BEGIN
      SAVEPOINT CCTUPG;
      EXECUTE IMMEDIATE 'SELECT ' ||old_col_name ||' from '|| table_name
        || ' WHERE ' || old_col_name || ' = :y '
	   || ' FOR UPDATE ' USING old_value ;

      EXECUTE IMMEDIATE 'UPDATE ' || table_name
        || ' SET '   || new_col_name || ' = :x '
        || ' WHERE ' || old_col_name || ' = :y '  USING
            new_value, old_value;
   EXCEPTION
      WHEN table_not_found THEN
      COMMIT ;  -- used to release the table lock.
        raise_application_error(-20000, 'Table '||table_name||' not found') ;

      WHEN OTHERS THEN
      COMMIT ;  -- used to release the table lock.
        raise_application_error (-20000, sqlerrm || '. Could not update column.') ;
   END UPDATE_COLUMN;

   -----------------------------------------------------------------------
   PROCEDURE modify_column_to_nullable  (
         schema_name     IN VARCHAR2
	 , table_name    IN VARCHAR2
         , col_name      IN VARCHAR2) IS

     table_not_found exception;
     pragma exception_init(table_not_found, -942);

     column_not_found exception;
     pragma exception_init(column_not_found, -904);

     null_column exception;
     pragma exception_init(column_not_found, -1451);


   BEGIN
	 SAVEPOINT CCTUPG;
      EXECUTE IMMEDIATE 'LOCK TABLE ' || schema_name || '.' || table_name
         || ' IN EXCLUSIVE MODE';
      EXECUTE IMMEDIATE 'ALTER TABLE ' || schema_name || '.' || table_name
         || ' MODIFY ' || col_name || ' NUMBER NULL ' ;

      COMMIT ;  -- used to release the table lock.

   EXCEPTION
      WHEN table_not_found THEN
      COMMIT ;  -- used to release the table lock.
        raise_application_error(-20000, 'Table '||table_name||' not found') ;

      WHEN column_not_found THEN
      COMMIT ;  -- used to release the table lock.
	   -- not a problem allows the script to be rerun.
	   null;

      WHEN null_column THEN
      COMMIT ;  -- used to release the table lock.
	   -- not a problem allows the script to be rerun.
	   null;

      WHEN OTHERS THEN
      COMMIT ;  -- used to release the table lock.
        raise_application_error(-20000, sqlerrm || '. Could not modify column')  ;
   END MODIFY_COLUMN_TO_NULLABLE;


   PROCEDURE modify_new_sequence_from_old  (
	  schema_name  IN VARCHAR2
	  ,sequence_name    IN VARCHAR2
	  ,old_sequence_name IN VARCHAR2
         ) IS

     sequence_not_found exception;
     pragma exception_init(sequence_not_found, -942);
	l_old_seq_val VARCHAR2(10);
	l_new_seq_stmt VARCHAR2(2000);
	l_missing_sequence VARCHAR2(2000);
	l_drop_Seq_stmt VARCHAR2(2000);
	v_cursorID INTEGER;
	v_dummy INTEGER;
	v_old_seq_Stmt VARCHAR2(2000);
   BEGIN
	 SAVEPOINT CCTUPGSEQ;
	 BEGIN
     	 v_cursorID:=DBMS_SQL.OPEN_CURSOR;
     	 v_old_seq_stmt:='SELECT '||schema_name||'.'||old_sequence_name||'.NEXTVAL from dual';
           --dbms_output.put_line(v_old_seq_stmt);
	      DBMS_SQL.PARSE(v_cursorID,v_old_seq_stmt,DBMS_SQL.V7);
           --dbms_output.put_line('after parsing');
	      DBMS_SQL.DEFINE_COLUMN(v_cursorID,1,l_old_seq_val,10);
           --dbms_output.put_line('after define column');
	      v_dummy:=DBMS_SQL.EXECUTE(v_cursorID);
           --dbms_output.put_line('after execute');
	      Loop
	        if DBMS_SQL.FETCH_ROWS(v_cursorID)=0 THEN
               --dbms_output.put_line('exiting');
		     exit;
             end if;
             --dbms_output.put_line('before col valu');
             DBMS_SQL.COLUMN_VALUE(v_cursorID,1,l_old_seq_val);
             --dbms_output.put_line(l_old_Seq_val);
           END LOOP;
	      DBMS_SQL.CLOSE_CURSOR(v_cursorID);
        Exception
		 When others then
			l_missing_sequence:=old_sequence_name;
			raise sequence_not_found;
        end;

	   -- dropping sequence
	   Begin
	      l_drop_seq_stmt:='DROP SEQUENCE '||schema_name||'.'||sequence_name;
	      --dbms_output.put_line(l_drop_seq_stmt);
	      EXECUTE IMMEDIATE l_drop_seq_stmt;
        Exception
		 When others then
			l_missing_sequence:=sequence_name;
			raise sequence_not_found;
        end;

	   --create new sequence
	   l_new_seq_stmt:='CREATE SEQUENCE '||schema_name||'.'||sequence_name||' NOCYCLE NOORDER START WITH '||l_old_seq_val;
	   --dbms_output.put_line(l_new_seq_stmt);
	   EXECUTE IMMEDIATE l_new_seq_stmt;

   EXCEPTION
      WHEN sequence_not_found THEN
        raise_application_error(-20000, 'Sequence '||l_missing_sequence||' not found') ;

      WHEN OTHERS THEN
        raise_application_error(-20000, sqlerrm || '. Could not modify sequence')  ;
   END MODIFY_new_SEQUENCE_from_old;

-- Added Oct 05 2001 rajayara
-- Verify if new sequence is less than old sequence, if so drop sequence name and re create it
--   with old_seq_val, else do nothing
   PROCEDURE modify_sequence_with_verify  (
	  schema_name  IN VARCHAR2
	  ,sequence_name    IN VARCHAR2
	  ,old_sequence_name IN VARCHAR2
         ) IS

     sequence_not_found exception;
     pragma exception_init(sequence_not_found, -942);
	l_old_seq_val VARCHAR2(10);
	l_new_seq_val VARCHAR2(10);
	l_new_seq_stmt VARCHAR2(2000);
	l_missing_sequence VARCHAR2(2000);
	l_drop_Seq_stmt VARCHAR2(2000);
	v_cursorID INTEGER;
	v_cursorID1 INTEGER;
	v_dummy INTEGER;
	v_dummy1 INTEGER;
	v_old_seq_Stmt VARCHAR2(2000);
	v_new_seq_Stmt VARCHAR2(2000);
   BEGIN
	 SAVEPOINT CCTUPGSEQ;

	 -- Getting the Old Sequence value

	 BEGIN
     	 v_cursorID:=DBMS_SQL.OPEN_CURSOR;
     	 v_old_seq_stmt:='SELECT '||schema_name||'.'||old_sequence_name||'.NEXTVAL from dual';
           --dbms_output.put_line(v_old_seq_stmt);
	      DBMS_SQL.PARSE(v_cursorID,v_old_seq_stmt,DBMS_SQL.V7);
           --dbms_output.put_line('after parsing');
	      DBMS_SQL.DEFINE_COLUMN(v_cursorID,1,l_old_seq_val,10);
           --dbms_output.put_line('after define column');
	      v_dummy:=DBMS_SQL.EXECUTE(v_cursorID);
           --dbms_output.put_line('after execute');
	      Loop
	        if DBMS_SQL.FETCH_ROWS(v_cursorID)=0 THEN
               --dbms_output.put_line('exiting');
		     exit;
             end if;
             --dbms_output.put_line('before col valu');
             DBMS_SQL.COLUMN_VALUE(v_cursorID,1,l_old_seq_val);
             --dbms_output.put_line(l_old_seq_val);
           END LOOP;
	      DBMS_SQL.CLOSE_CURSOR(v_cursorID);
        Exception
		 When others then
			l_missing_sequence:=old_sequence_name;
			raise sequence_not_found;
        end;

        -- Getting the New Sequence value

	 BEGIN
     	     v_cursorID1:=DBMS_SQL.OPEN_CURSOR;
     	     v_new_seq_stmt:='SELECT '||schema_name||'.'||sequence_name||'.NEXTVAL from dual';
              --dbms_output.put_line(v_new_seq_stmt);
	      DBMS_SQL.PARSE(v_cursorID1,v_new_seq_stmt,DBMS_SQL.V7);
              --dbms_output.put_line('after parsing');
	      DBMS_SQL.DEFINE_COLUMN(v_cursorID1,1,l_new_seq_val,10);
              --dbms_output.put_line('after define column');
	      v_dummy1:=DBMS_SQL.EXECUTE(v_cursorID1);
              --dbms_output.put_line('after execute');
	      Loop
	            if DBMS_SQL.FETCH_ROWS(v_cursorID1)=0 THEN
                     --dbms_output.put_line('exiting');
		             exit;
                end if;
                --dbms_output.put_line('before col valu');
                DBMS_SQL.COLUMN_VALUE(v_cursorID1,1,l_new_seq_val);
                --dbms_output.put_line(l_new_seq_val);
             END LOOP;
	      DBMS_SQL.CLOSE_CURSOR(v_cursorID1);
        Exception
		 When others then
			l_missing_sequence:=sequence_name;
  			l_missing_sequence:=l_missing_sequence||' SQLERRM::'||sqlerrm;
			raise sequence_not_found;
        end;

        -- if new sequence is less than old sequence then bump up new sequence to old seq, else do nothing
        --dbms_output.put_line('New Sequence='||l_new_Seq_val||', l_old_Seq_val='||l_old_Seq_val);
        if (to_number(l_new_Seq_val) < to_number(l_old_Seq_val) )
        then
	   -- dropping sequence
	   Begin
	      l_drop_seq_stmt:='DROP SEQUENCE '||schema_name||'.'||sequence_name;
	      --dbms_output.put_line(l_drop_seq_stmt);
	      EXECUTE IMMEDIATE l_drop_seq_stmt;
           Exception
		 When others then
			l_missing_sequence:=sequence_name;
			raise sequence_not_found;
           end;

	   --create new sequence
	   l_new_seq_stmt:='CREATE SEQUENCE '||schema_name||'.'||sequence_name||' NOCYCLE NOORDER START WITH '||l_old_seq_val;
	   --dbms_output.put_line(l_new_seq_stmt);
	   EXECUTE IMMEDIATE l_new_seq_stmt;
	END IF;

   EXCEPTION
      WHEN sequence_not_found THEN
        raise_application_error(-20000, 'Sequence '||l_missing_sequence||' not found') ;

      WHEN OTHERS THEN
        raise_application_error(-20000, sqlerrm || '. Could not modify sequence')  ;
   END modify_sequence_with_verify;

   -----------------------------------------------------------------------
   PROCEDURE drop_column (schema_name IN VARCHAR2,
		  table_name IN VARCHAR2, col_name IN VARCHAR2) IS

     table_not_found exception;
     pragma exception_init(table_not_found, -942);

     column_not_found exception;
     pragma exception_init(column_not_found, -904);
   BEGIN
	 SAVEPOINT CCTUPG;
      EXECUTE IMMEDIATE 'LOCK TABLE ' || schema_name || '.' || table_name
         || ' IN EXCLUSIVE MODE';
      EXECUTE IMMEDIATE 'ALTER TABLE ' || schema_name || '.' || table_name
         || ' DROP COLUMN ' || col_name ;
      COMMIT ;  -- used to release the table lock.
   EXCEPTION
      WHEN table_not_found THEN
      COMMIT ;  -- used to release the table lock.
        raise_application_error(-20000, 'Table '||table_name||' not found') ;

      WHEN column_not_found THEN
      COMMIT ;  -- used to release the table lock.
	   -- not a problem allows the script to be rerun.
	   null;

      WHEN OTHERS THEN
      COMMIT ;  -- used to release the table lock.
        raise_application_error(-20000, 'Could not drop column')  ;
   END DROP_COLUMN;

   -----------------------------------------------------------------------
   PROCEDURE copy_all_rows (old_table_name IN VARCHAR2
                           , new_table_name IN VARCHAR2)
   IS

   CURSOR c1 IS
    SELECT column_name
      FROM all_tab_columns
      WHERE table_name = old_table_name
	 and owner=(Select user from dual);

     l_string   		VARCHAR2 (8000) ;

     l_table_name		VARCHAR2 (40);
     l_column_name		VARCHAR2 (40);

     l_delete_string            VARCHAR2 (200);

     table_not_found exception;
     pragma exception_init(table_not_found, -942);

     column_not_found exception;
     pragma exception_init(column_not_found, -904);

   BEGIN
     BEGIN
     -- Get all the column names in the old table
     OPEN c1;
     FETCH c1 INTO l_column_name;
     l_string := l_column_name;
     LOOP
       FETCH c1 INTO l_column_name;
       EXIT WHEN c1%NOTFOUND;
       l_string := l_string || ', ' || l_column_name;
     END LOOP;
     CLOSE c1;
     EXCEPTION
       WHEN table_not_found THEN
         l_table_name := old_table_name;
         raise ;
     END;

     l_table_name := new_table_name;

	SAVEPOINT CCTUPG;
     EXECUTE IMMEDIATE 'LOCK TABLE ' || new_table_name
         || ',' || old_table_name || ' IN EXCLUSIVE MODE';

     -- delete all rows from the new table before inserting
     l_delete_string := 'DELETE FROM ' || new_table_name;
     EXECUTE IMMEDIATE l_delete_string;

     -- Insert into the new table
     l_string := ' INSERT INTO ' ||  new_table_name
         ||  ' SELECT ' || l_string || ' FROM ' || old_table_name ;

     EXECUTE IMMEDIATE l_string;
     COMMIT ; -- required to release the table locks
   EXCEPTION
      WHEN table_not_found THEN
      COMMIT ;  -- used to release the table lock.
        raise_application_error(-20000, 'Table '||l_table_name||' not found') ;

      WHEN OTHERS THEN
      COMMIT ;  -- used to release the table lock.
        raise_application_error(-20000, sqlerrm || '.' || l_string)  ;


   END COPY_ALL_ROWS;

   PROCEDURE delete_fnd_lookups( lookupType  IN VARCHAR2
                                 ,lookupCode IN VARCHAR2
                               )
   IS
     CURSOR csr_installed_langs IS
        SELECT distinct language FROM fnd_lookup_values
        WHERE lookup_type=lookupType;

     lang   fnd_languages.language_code%TYPE;
	l_string VARCHAR2(20) := 'DELETE_FND_LOOKUPS';

   BEGIN

     OPEN  csr_installed_langs;

     LOOP
       FETCH csr_installed_langs into lang;
       EXIT WHEN csr_installed_langs%NOTFOUND;

       delete_fnd_lookups( lookupType,lookupCode, lang);

     END LOOP;

     CLOSE csr_installed_langs;

   EXCEPTION
     WHEN others THEN
        CLOSE csr_installed_langs;
	   raise_application_error(-20000, sqlerrm || '.' || l_string)  ;
   END;

   PROCEDURE delete_fnd_lookups( lookupType IN VARCHAR2
         , lookupCode IN VARCHAR2
         , lang      IN VARCHAR2)
   IS
	l_string VARCHAR2(25) := 'DELETE_FND_LOOKUPS-LANG';
   BEGIN

     if lookupCode  is null then

       DELETE fnd_lookup_values
       WHERE lookup_type=lookupType
       AND  language = lang;

       -- Also deleting the lookup type as we have deleted all the values
       DELETE FND_LOOKUPS
       WHERE lookup_type=lookupType;

     else

       DELETE fnd_lookup_values
       WHERE lookup_type=lookupType
       AND lookup_code = lookupCode
       AND  language = lang;

       -- Also deleting the lookup type as we have deleted all the values
       DELETE FND_LOOKUPS
       WHERE lookup_type=lookupType
       AND lookup_code = lookupCode;

     end if;


   EXCEPTION
     WHEN others THEN
	   raise_application_error(-20000, sqlerrm || '.' || l_string)  ;
   END;

   Procedure change_params_in_mvalues
   IS
	l_string VARCHAR2(64) := 'change_mware_paramsinvalues';
   Begin
    Begin
	update cct_middleware_values
	set name='MW_SERVER_IPADDRESS'
	where name='OT_SERVER_IPADDRESS'
	or name='OPENTEL_SERVER_NAME';
    Exception
	When others then
	null;
    End;

    Begin
	update cct_middleware_values
	set name='MW_SERVER_INFO_1'
	where name='OT_SERVER_INFO1'
	or name='OT_SERVER_INFO_1';

    Exception
	When others then
	null;
    End;


    Begin
	update cct_middleware_values
	set name='MW_SERVER_INFO_2'
	where name='OT_SERVER_INFO2'
	or name='OT_SERVER_INFO_2';

    Exception
	When others then
	null;
    End;

    Begin
	update cct_middleware_values
	set name='MW_SERVER_INFO_3'
	where name='OT_SERVER_INFO3'
	or name='OT_SERVER_INFO_3';

    Exception
	When others then
	null;
    End;

    Begin
	update cct_middleware_values
	set name='MW_SERVER_INFO_4'
	where name='OT_SERVER_INFO4'
	or name='OT_SERVER_INFO_4';

    Exception
	When others then
	null;
    End;

    Begin
	update cct_middleware_values
	set name='MW_SERVER_INFO_5'
	where name='OT_SERVER_INFO5'
	or name='OT_SERVER_INFO_5';

    Exception
	When others then
	null;
    End;

    Begin
	delete cct_middleware_values
	where name='CTI_ENABLER_NAME'
	or name='LOCAL_CALL_DATA_FILE';
    Exception
	When others then
	null;
    End;


   Exception
     WHEN others THEN
	   raise_application_error(-20000, sqlerrm || '.' || l_string)  ;
   END;

   Procedure delete_prospect_aspect
   IS
      Cursor c_mw
	 is
	 Select a.middleware_id
	 from cct_middlewares a,cct_middleware_types b
	 where a.middleware_type_id=b.middleware_type_id
	 and b.middleware_type='PROSPECT_ASPECT';

   Begin

      For v_mw in c_mw
	 Loop
	    Begin
      	    delete cct_middleware_values
	         where middleware_id=v_mw.middleware_id;
         Exception
		    When others then
			  --dbms_output.put_line('error in deleting middleware values for Prospect Aspect');
			  null;
         End;
	    Begin
      	    delete jtf_rs_ResourcE_values
	         where value_type=v_mw.middleware_id;
         Exception
		    When others then
			  --dbms_output.put_line('error in deleting resourcE_middleware values for Prospect Aspect');
			  null;
         End;
	    Begin
      	    delete cct_middlewares
	         where middleware_id=v_mw.middleware_id;
         Exception
		    When others then
			  --dbms_output.put_line('error in deleting middleware for type Prospect Aspect');
			  null;
         End;
      End Loop;
	    Begin
      	    delete cct_middleware_params
	         where middleware_type_id=(Select middleware_Type_id
								from cct_middleware_types
								where middleware_type='PROSPECT_ASPECT');
         Exception
		    When others then
			  --dbms_output.put_line('error in deleting middleware_param for Prospect Aspect');
			  null;
         End;
	    Begin
      	    delete jtf_rs_resource_params
	         where param_type=(Select middleware_Type_id
								from cct_middleware_types
								where middleware_type='PROSPECT_ASPECT');
         Exception
		    When others then
			  --dbms_output.put_line('error in deleting middleware_param for Prospect Aspect');
			  null;
         End;
	    Begin
      	    delete cct_middleware_types
		    where middleware_type='PROSPECT_ASPECT';
         Exception
		    When others then
			  --dbms_output.put_line('error in deleting middleware_type=Prospect Aspect');
			  null;
         End;
   Exception
	  When others then
		null;
   End;


   Procedure upgrade_mware_values
   IS
	l_mvid Number;
	l_mpname Varchar2(64);
	l_mpid Number;
	l_string VARCHAR2(64) := 'upgrade_mware_values';
	Cursor c_mvp
	is
	Select a.middleware_value_id,a.name,b.middleware_param_id
	from cct_middleware_values a, cct_middleware_params b,
		cct_middlewares c
	where a.name=b.name
	and a.middleware_param_id is null
	and  a.middleware_id=c.middleware_id
	and  c.middleware_type_id=b.middleware_type_id;
   Begin
	for v_mvp in c_mvp LOOP
	    --dbms_output.put_line('in loop');
	    update cct_middleware_values
	    set middleware_param_id=v_mvp.middleware_param_id
	    where middleware_value_id=v_mvp.middleware_value_id;
     end loop;
   Exception
	when others then
	   raise_application_error(-20000, sqlerrm || '.' || l_string)  ;
   END;

   Procedure update_agparam_in_agvalues(p_old_type IN VARCHAR2,p_old_param_name IN VARCHAR2,p_new_type IN VARCHAR2,p_new_param_name IN VARCHAR2)
   IS
	 Cursor c_value
	 is
	 Select resource_param_value_id
	 from jtf_rs_resource_values v,jtf_rs_resource_params p,cct_middleware_types t
	 where t.middleware_type=p_old_type
	 and p.param_type=t.middleware_type_id
	 and p.name=p_old_param_name
	 and v.resource_param_id=p.resource_param_id;

	 l_new_param_id Number;
	 l_string VARCHAR2(1000);
   Begin
	l_string:='Error updating JTF_RS_RESOURCE_VALUES for middleware_type='||p_old_type||' agent param name='||p_old_param_name;
	Select resourcE_param_id
	into l_new_param_id
	from jtf_rs_resource_params p,cct_middleware_types t
	where t.middleware_type=p_new_type
	and p.param_type=t.middleware_type_id
	and p.name=p_new_param_name;

	for v_valueID in c_value LOOP
	    update jtf_rs_resource_values
	    set resourcE_param_id=l_new_param_id
	    where resource_param_value_id=v_valueID.resource_param_value_id;
	end loop;
   Exception
	When others then
	   raise_application_error(-20000, sqlerrm || '.' || l_string )  ;
   END;


   Procedure update_mwparam_in_mwvalues(p_old_type IN VARCHAR2,p_old_param_name IN VARCHAR2,p_new_type IN VARCHAR2,p_new_param_name IN VARCHAR2)
   IS
	 Cursor c_value
	 is
	 Select middleware_value_id
	 from cct_middleware_values v,cct_middleware_params p,cct_middleware_types t
	 where t.middleware_type=p_old_type
	 and p.middleware_type_id=t.middleware_type_id
	 and p.name=p_old_param_name
	 and v.middleware_param_id=p.middleware_param_id;

	 l_new_param_id Number;
	 l_string VARCHAR2(1000);
   Begin
	l_string:='Error updating CCT_Middleware_values for middleware_type='||p_old_type||' param name='||p_old_param_name;
	Select middleware_param_id
	into l_new_param_id
	from cct_middleware_params p,cct_middleware_types t
	where t.middleware_type=p_new_type
	and p.middleware_type_id=t.middleware_type_id
	and p.name=p_new_param_name;

	for v_mvalueID in c_value LOOP
	    update cct_middleware_values
	    set middleware_param_id=l_new_param_id
	    where middleware_value_id=v_mvalueID.middleware_value_id;
	end loop;
   Exception
	When no_data_found then
	   null;
	When others then
	   raise_application_error(-20000, sqlerrm || '.' || l_string )  ;
   END;

   Procedure update_mtype_in_mware(p_middleware_id IN Number,p_old_type in VARCHAR2, p_new_type IN VARCHAR2)
   IS
      Cursor c_middleware
      is
      Select m.middleware_id
      from cct_middlewares m,cct_middleware_types t
      where t.middleware_type=p_old_type
	 and t.middleware_type_id=m.middleware_type_id
	 and m.middleware_id=p_middleware_id;

      l_string VARCHAR2(1000);
      l_new_type_id Number;
   Begin
      l_string :='Error updating CCT_MIDDLEWARE_VALUES table middleware_id='||to_char(p_middleware_id)||' p_old_type='||p_old_type;
	 Select middleware_type_id
	 into l_new_type_id
	 from cct_middleware_types
	 where middleware_type=p_new_type;

	 for v_middleware in c_middleware Loop
	    update cct_middlewares
	    set middleware_Type_id=l_new_type_id
	    where middleware_id=p_middleware_id;
      end loop;

   Exception
	When no_data_found then
	   null;
	When others then
	   raise_application_error(-20000, sqlerrm || '.' || l_string )  ;
   END;

   Procedure delete_middleware_value(p_middleware_type in VARCHAR2,p_param_name in VARCHAR2)
   is
	 Cursor c_mvalue
	 is
	 Select v.middleware_value_id
	 from cct_middleware_values v,cct_middleware_params p,cct_middleware_types t
	 where t.middleware_type=p_middleware_type
	 and t.middleware_type_id=p.middleware_type_id
	 and p.name=p_param_name
	 and v.middleware_param_id=p.middleware_param_id;
	 l_string VARCHAR2(1000);
   Begin
	l_string:='ERROR deleting obsolete middleware values for type='||p_middleware_type||' and param='||p_param_name;
	For v_value in c_mvalue LOOP
	  Begin
      	  update cct_middleware_values
	       set f_deletedflag='D'
	       where middleware_value_id=v_value.middleware_value_id;
       Exception
		 When no_data_found then
		    null;
       end;

     end loop;
   Exception
	When no_data_found then
	   null;
	When others then
	   raise_application_error(-20000, sqlerrm || ':'||l_string )  ;
   END;

   Procedure delete_middleware_type(p_middleware_type_id in Number)
   IS
      Cursor c_mw
	 is
	 Select a.middleware_id
	 from cct_middlewares a,cct_middleware_types b
	 where a.middleware_type_id=b.middleware_type_id
	 and b.middleware_type_id=p_middleware_type_id;

   Begin

      For v_mw in c_mw
	 Loop
	    Begin
      	    delete cct_middleware_values
	         where middleware_id=v_mw.middleware_id;
         Exception
		    When others then
			  --dbms_output.put_line('error in deleting middleware values for Prospect Aspect');
			  null;
         End;
	    Begin
      	    delete jtf_rs_ResourcE_values
	         where value_type=v_mw.middleware_id;
         Exception
		    When others then
			  --dbms_output.put_line('error in deleting resourcE_middleware values for Prospect Aspect');
			  null;
         End;
	    Begin
      	    delete cct_middlewares
	         where middleware_id=v_mw.middleware_id;
         Exception
		    When others then
			  --dbms_output.put_line('error in deleting middleware for type Prospect Aspect');
			  null;
         End;
      End Loop;
	    Begin
      	    delete cct_middleware_params
	         where middleware_type_id=(Select middleware_Type_id
								from cct_middleware_types
								where middleware_type_id=p_middleware_type_id);
         Exception
		    When others then
			  --dbms_output.put_line('error in deleting middleware_param for Prospect Aspect');
			  null;
         End;
	    Begin
      	    delete jtf_rs_resource_params
	         where param_type=(Select middleware_Type_id
								from cct_middleware_types
								where middleware_type_id=p_middleware_type_id);
         Exception
		    When others then
			  --dbms_output.put_line('error in deleting middleware_param for Prospect Aspect');
			  null;
         End;
	    Begin
      	    delete cct_middleware_types
		    where middleware_type_id=p_middleware_type_id;
         Exception
		    When others then
			  --dbms_output.put_line('error in deleting middleware_type=Prospect Aspect');
			  null;
         End;
   Exception
	  When others then
		null;
   End;

   -- Need to Update Middleware Values because of AOM bug, implimenting workaround as described
   --  in bug 2276001
   Procedure upgrade_ao_flg_mw_values
   IS
	l_mvid Number;
	l_mval CCT_MIDDLEWARE_VALUES.VALUE%TYPE;
	l_mpid Number;
	l_string VARCHAR2(64) := 'upg_ao_flg_mware_values';
	Cursor c_mvp
	is
	  SELECT b.middleware_value_id, b.VALUE
      FROM cct_middleware_params a, cct_middleware_values b
      WHERE a.middleware_param_id = b.middleware_param_id
      AND a.domain_lookup_type = 'CCT_AO_FLAG'
      AND (b.f_deletedflag <> 'D' OR b.f_deletedflag IS NULL);
   Begin
	for v_mvp in c_mvp LOOP
	    --dbms_output.put_line('in loop');
	    update cct_middleware_values
	    set value= decode(v_mvp.value,'Y', 'YES', 'N','NO','' )
	    where middleware_value_id=v_mvp.middleware_value_id;
     end loop;
   Exception
	when others then
	   raise_application_error(-20000, sqlerrm || '.' || l_string)  ;
   END;

 PROCEDURE MODIFY_SEQUENCE_WITH_VALUE  (
	  schema_name  IN VARCHAR2
	  ,sequence_name    IN VARCHAR2
	  ,replacement_value IN VARCHAR2
         ) IS

     sequence_not_found exception;
     pragma exception_init(sequence_not_found, -942);
     	l_old_seq_val VARCHAR2(10);
	l_new_seq_val VARCHAR2(10);
	l_new_seq_stmt VARCHAR2(2000);
	l_missing_sequence VARCHAR2(2000);
	l_drop_Seq_stmt VARCHAR2(2000);
	v_cursorID INTEGER;
	v_dummy INTEGER;
	v_old_seq_Stmt VARCHAR2(2000);
	l_seq_val      varchar2(20);
   BEGIN
	 SAVEPOINT CCTUPGSEQ;


	 -- Getting the Current Sequence value
	 BEGIN
     	 v_cursorID:=DBMS_SQL.OPEN_CURSOR;
     	 v_old_seq_stmt:='SELECT '||schema_name||'.'||sequence_name||'.NEXTVAL from dual';
           --dbms_output.put_line(v_old_seq_stmt);
	      DBMS_SQL.PARSE(v_cursorID,v_old_seq_stmt,DBMS_SQL.V7);
           --dbms_output.put_line('after parsing');
	      DBMS_SQL.DEFINE_COLUMN(v_cursorID,1,l_seq_val,10);
           --dbms_output.put_line('after define column');
	      v_dummy:=DBMS_SQL.EXECUTE(v_cursorID);
           --dbms_output.put_line('after execute');
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

	 IF ( (to_number(replacement_value)) > (to_number(l_seq_val)) )THEN
	  l_seq_val := replacement_value;


	   -- dropping sequence
	   Begin
	      l_drop_seq_stmt:='DROP SEQUENCE '||schema_name||'.'||sequence_name;
	      --dbms_output.put_line(l_drop_seq_stmt);
	      EXECUTE IMMEDIATE l_drop_seq_stmt;
           Exception
		 When others then
			l_missing_sequence:=sequence_name;
			raise sequence_not_found;
           end;

	   --create new sequence
	   l_new_seq_stmt:='CREATE SEQUENCE '||schema_name||'.'||sequence_name||' NOCYCLE NOORDER START WITH '||l_seq_val;
	   --dbms_output.put_line(l_new_seq_stmt);
	   EXECUTE IMMEDIATE l_new_seq_stmt;
        END IF;
   EXCEPTION
      WHEN sequence_not_found THEN
        raise_application_error(-20000, 'Sequence '||l_missing_sequence||' not found') ;

      WHEN OTHERS THEN
        raise_application_error(-20000, sqlerrm || '. Could not modify sequence')  ;
   END MODIFY_SEQUENCE_WITH_VALUE;

   Procedure update_agent_values(p_agent_param IN VARCHAR2,p_middleware_type_id IN VARCHAR2,p_new_agent_param_id In NUMBER)
   IS
	  Cursor c_values(p_param_id Number)
	  is
	  Select resource_param_value_id
	  from jtf_rs_resource_values
	  where resource_param_id=p_param_id;
	  l_old_param_id Number;
   BEGIN
	  -- check if the resource_param_id is incorrect
	  Select resource_param_id
       into l_old_param_id
	  from jtf_rs_resource_params
	  where name=p_agent_param
	  and param_type=p_middleware_type_id
	  and resource_param_id<>p_new_agent_param_id;

	  --dbms_output.put_line('l_old_param_id='||to_char(l_old_param_id));

	  -- if there is an incorrect param then get all the resource values for that param and update it with the correct param id (from JTFRSPAR.ldt file)
	  For v_values in c_values(l_old_param_id) LOOP
	     --dbms_output.put_line('updating Resource Value id='||to_char(v_values.resource_param_value_id));
		Update jtf_rs_ResourcE_values
		set resource_param_id=p_new_agent_param_id
		where resource_param_value_id=v_values.resource_param_value_id;
       End Loop;

	  -- Delete the incorrect resource param
	  delete jtf_rs_resource_params
	  where resource_param_id=l_old_param_id;
	  --dbms_output.put_line('deleted l_old_param_id='||to_char(l_old_param_id));
   Exception
	  When no_data_found then
		null;
       When others then
          raise_application_error(-20000, sqlerrm || '. Could not update agent param values')  ;
   End;
   Procedure increment_ikey_sequence
   is
   current_val number;
   target_val number:=2000;
   Begin
	Select cct_interaction_keys_s.nextval
	into current_val
	from dual;

	while (current_val<target_val) loop
	   Select cct_interaction_keys_s.nextval
	   into current_val
	   from dual;
     end loop;
   end;
END cct_upgrade_pkg;

/
