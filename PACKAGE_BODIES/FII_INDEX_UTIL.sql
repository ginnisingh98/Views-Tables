--------------------------------------------------------
--  DDL for Package Body FII_INDEX_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_INDEX_UTIL" as
/* $Header: FIIIDUTB.pls 120.2.12000000.3 2007/04/26 08:42:05 dhmehra ship $  */

procedure set_table_name( p_table_name IN VARCHAR2, p_owner VARCHAR2) IS

    l_debug_flag    VARCHAR2(1) := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');

  begin
    IF p_table_name is NOT NULL THEN
        g_tab_name := p_table_name;
        g_owner    := p_owner;
     END IF;

     IF l_debug_flag = 'Y' THEN
        g_debug_msg := 'Setting the table name to '||g_tab_name;
        FII_UTIL.put_line('');
        FII_UTIL.put_line(g_debug_msg);
     END IF;

end set_table_name; -- set_table_name


procedure drop_index(p_table_name VARCHAR2, p_owner VARCHAR2,
                     p_retcode in out NOCOPY Varchar2) is

  l_debug_flag    VARCHAR2(1) := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');

  var1 varchar2(2000) := NULL;
  var2 varchar2(500)  := NULL;
  var3 varchar2(500) := NULL;
  var4 varchar2(500) := NULL;
  var5 varchar2(500) := NULL;
  Errbuf VARCHAR2(200) := NULL;
  l_index_exists NUMBER := 0;
  l_counter number:=0;
  l_rows number:=0;
  l_next_extent varchar2(20);

  l_unique varchar2(100) := NULL;

  parallel_var number:=0;

  rec fii_indexes%rowtype;
  rec2 dba_indexes%rowtype;
  rec3 dba_ind_columns%rowtype;

cursor c1 is select * from fii_indexes where table_name = g_tab_name;

cursor c2 is select * from dba_indexes where table_name  = g_tab_name
                                         and TABLE_OWNER = g_owner;

cursor c3 (ind_name varchar2) is select * from dba_ind_columns
                                  where index_name  = ind_name
                                     and INDEX_OWNER = g_owner
				    ORDER BY column_position;

begin

  -- get degree of parallelism

  parallel_var:=bis_common_parameters.get_degree_of_parallelism;


     set_table_name(p_table_name, p_owner);

     IF l_debug_flag = 'Y' THEN
               FII_UTIL.put_line('');
                FII_UTIL.put_line(parallel_var);
                g_debug_msg := 'Check if index exists, if not then they have already been dropped';
                FII_UTIL.put_line('');
                FII_UTIL.put_line(g_debug_msg);
     END IF;

     -- bug 4177221: added filter for SNAP$ indexes
   /*  select count(*) into l_index_exists from dba_indexes
      where table_name  = g_tab_name
        and TABLE_OWNER = g_owner
		and index_name not like 'I_SNAP$_FII_%'
		and index_name not like 'U_SNAP$_FII_%';*/

		--Changed above query for Performance bug 4992919
		begin
		 select 1 into l_index_exists from dba_indexes
     where table_name  = g_tab_name
     and TABLE_OWNER = g_owner
		 and index_name not like 'I_SNAP$_FII_%'
		 and index_name not like 'U_SNAP$_FII_%'
		 and rownum = 1;
   exception
    when others then
      l_index_exists := 0;
   end;

    -- select count(*) into l_rows from fii_indexes where table_name = g_tab_name;
    --Changed above query for Performance bug 4992919
   begin
		 select 1 into l_rows from fii_indexes where table_name = g_tab_name and rownum = 1;
	 exception
   when others then
     l_rows := 0;
   end;
     if(l_index_exists = 0) then

        -- index do not exist , so no action
         IF l_debug_flag = 'Y' THEN
         -- if no information exists to recreate them, provide message
           IF (l_rows=0) THEN
                g_debug_msg := 'Indexes do not exist and no information found to create them, so please create manually';
                FII_UTIL.put_line('');
                FII_UTIL.put_line(g_debug_msg);
           ELSE
                g_debug_msg := 'Index do not exist , so no need to drop';
                FII_UTIL.put_line('');
                FII_UTIL.put_line(g_debug_msg);
           END IF;
         END IF;

     else --   indexes are there and need to be dropped

       IF l_debug_flag = 'Y' THEN
                g_debug_msg := 'Index exist , so save definition and drop indexes';
                FII_UTIL.put_line('');
                FII_UTIL.put_line(g_debug_msg);
       END IF;

       -- store index names in table fii_indexes
       g_debug_msg := 'First, delete from fii_indexes for ' || g_tab_name;
        delete from fii_indexes where table_name = g_tab_name;

       g_debug_msg := 'Then, insert into fii_indexes for ' || g_tab_name || ' from dba_indexes';
        insert into fii_indexes (
		TABLE_NAME, INDEX_NAME, CREATE_STMT,
		CREATION_DATE, CREATED_BY,
		LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN
	)
        select g_tab_name, index_name, null, sysdate, -1, sysdate, -1, -1
          from dba_indexes
         where table_name  = g_tab_name
           and TABLE_OWNER = g_owner;

        -- form "create index" statements
       g_debug_msg := 'form create index statements';
        open c2;
          loop
              fetch c2 into rec2;
              var2:=rec2.index_name;
              exit when c2%notfound;
              l_counter := 0;

             open c3(rec2.index_name);
              loop
                fetch c3 into rec3;
                exit when c3%notfound;
                    if l_counter = 0 then
                        var4:=rec3.column_name;
                        l_counter := l_counter+1;
                    else
                        var4:=var4||','||rec3.column_name;
                        l_counter := l_counter+1;
                    end if;
               end loop;
            close c3;

            -- update fii_indexes to store the "create index" statements
         g_debug_msg := 'update fii_indexes to store the create index statements';

           if (rec2.uniqueness = 'UNIQUE') then
               l_unique := ' unique ';
           else
               l_unique := ' ';
           end if;

           var5:=rec2.next_extent;
            -- if next_extent is empty dont include next clause in "create index" statement
           if var5 is null then
               var3:='create'||l_unique||'index '||g_owner||'.'||rec2.index_name||' on '||g_owner||'.'||g_tab_name||' ('||var4 ||')' ||'
               storage ( INITIAL  '|| rec2.initial_extent||') tablespace '
               ||rec2.tablespace_name||' parallel '||parallel_var||' nologging ';
           else
               --use NEXT 10M rather than rec2.next_extent since it might be too large
               l_next_extent := '10M';
               var3:='create'||l_unique||'index '||g_owner||'.'||rec2.index_name||' on '||g_owner||'.'||g_tab_name||' ('||var4 ||')' ||'
               storage ( INITIAL  '|| rec2.initial_extent||' NEXT '||l_next_extent||') tablespace '
               ||rec2.tablespace_name||' parallel '||parallel_var||' nologging ';
           end if;

             update fii_indexes
                set create_stmt=var3
              where table_name = g_tab_name
                and index_name=rec2.index_name;

	     IF l_debug_flag = 'Y' THEN
                  g_debug_msg := 'Index definition saved in fii_indexes';
                  FII_UTIL.put_line('');
                  FII_UTIL.put_line(g_debug_msg);
            END IF;


          end loop;
          close c2;

        commit;

--bug 3152517: delete system-generated index like 'I_SNAP$_FII_%' and
--             'U_SNAP$_FII_%' from FII_INDEXES
     g_debug_msg := 'delete scripts for system-generated index I_SNAP$_FII_% from FII_INDEXES';

     delete from FII_INDEXES
      where table_name = g_tab_name
        and (index_name like 'I_SNAP$_FII_%' OR
             index_name like 'U_SNAP$_FII_%');

      IF l_debug_flag = 'Y' and SQL%ROWCOUNT > 0 THEN
             FII_UTIL.put_line('');
             FII_UTIL.put_line(g_debug_msg);
      END IF;

--bug 3162509: should commit after the above delete
     commit;

        -- drop other indexes in FII_INDEXES
        open c1;
           loop
               fetch c1 into rec;
               exit when c1%notfound;
               var1:=rec.index_name;
               g_debug_msg := 'Trying to drop index ' || var1;
               execute immediate 'drop index ' ||g_owner||'.'||var1;
           end loop;
        close c1;

       IF l_debug_flag = 'Y' THEN
                g_debug_msg := 'Indexes dropped';
                FII_UTIL.put_line('');
                FII_UTIL.put_line(g_debug_msg);
       END IF;

     end if; -- check on index exists

EXCEPTION
        when others then
             Errbuf:= sqlerrm;
             p_retcode:=sqlcode;
             if l_debug_flag = 'Y' then
                FII_UTIL.put_line('ERROR in drop_index--> ' || p_retcode||':'||Errbuf);
                FII_UTIL.put_line('Phase--> ' || g_debug_msg);
             end if;

end drop_index; -- drop index procedure


procedure create_index(p_table_name VARCHAR2, p_owner VARCHAR2,
                       p_retcode    in out NOCOPY Varchar2) is

  l_debug_flag    VARCHAR2(1) := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');
  l_rows number:=0;
  var2 varchar2(500)  := NULL;
  var5 varchar2(2000)  := NULL;

  l_counter number:=0;
  Errbuf VARCHAR2(200);
  rec2 dba_indexes%rowtype;

  cursor c1A is select distinct create_stmt from fii_indexes
                where table_name = g_tab_name;
  cursor c1B is select index_name from fii_indexes
                where table_name = g_tab_name;
  cursor c2 is select * from dba_indexes where table_name  = g_tab_name
                                           and TABLE_OWNER = g_owner;

begin

-- create indexes

       set_table_name(p_table_name, p_owner);
       begin
        select 1 into l_rows from fii_indexes where table_name = g_tab_name and rownum = 1;
       exception
        when others then
         l_rows := 0;
       end;

       IF l_debug_flag = 'Y' THEN
                IF (l_rows=0) THEN
                   FII_UTIL.put_line('');
                ELSE
                   g_debug_msg := 'Creating Indexes';
                   FII_UTIL.put_line('');
                   FII_UTIL.put_line(g_debug_msg);
                END IF;
       END IF;

          g_debug_msg := 'Create indexes using statements from fii_indexes...';
              for r1a in c1A loop
        	 var5:=r1a.create_stmt;
            	 execute immediate var5;
              end loop;

          g_debug_msg := 'Alter the index definitions...';
       	      for r1b in c1B loop
                 execute immediate 'alter index '||g_owner||'.'||r1b.index_name||' logging noparallel';
              end loop;


       IF l_debug_flag = 'Y' THEN
                g_debug_msg := 'Indexes created';
                FII_UTIL.put_line('');
                FII_UTIL.put_line(g_debug_msg);
       END IF;



EXCEPTION
        when others then
                Errbuf:= sqlerrm;
                p_retcode:=sqlcode;
                if l_debug_flag = 'Y' then
                  FII_UTIL.put_line('ERROR in create_index--> ' ||p_retcode||':'||Errbuf);
                  FII_UTIL.put_line('Phase--> ' || g_debug_msg);
                  FII_UTIL.put_line('Failing Statement: ' || var5);
                end if;


 		-- Index creation has failed. Drop any indexes already created.
	       IF l_debug_flag = 'Y' THEN
                  g_debug_msg  := 'Index creation failed. Dropping any indexes that may have been created';
                  FII_UTIL.put_line('');
                  FII_UTIL.put_line(g_debug_msg);
       	       END IF;

	       open c2;
		  loop
			fetch c2 into rec2;
			exit when c2%NOTFOUND;
			var2:=rec2.index_name;
         	        execute immediate 'drop index ' ||g_owner||'.'||var2;
		  end loop;

	       close c2;


end create_index; -- create index

end fii_index_util;

/
