--------------------------------------------------------
--  DDL for Package Body CSI_MIG_SLABS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_MIG_SLABS_PKG" AS
/* $Header: csislabb.pls 115.7 2004/03/30 22:30:31 srramakr ship $*/

/*Get a value from the sql statement passed*/
FUNCTION get_sql_value(sqlstr IN VARCHAR) RETURN NUMBER IS
  l_cursor_handle INTEGER;
  l_value NUMBER;
  l_n_temp NUMBER;
BEGIN
  l_cursor_handle := dbms_sql.open_cursor;

  begin
    dbms_sql.parse(l_cursor_handle,sqlstr,dbms_sql.native);
  exception
    when others then
	 raise_application_error(-20001,'error while parsing sql:'||sqlerrm);
  end;

  DBMS_SQL.DEFINE_COLUMN(l_cursor_handle,1,l_value);
   l_n_temp := dbms_sql.execute(l_cursor_handle);

   IF dbms_sql.fetch_rows(l_cursor_handle) > 0 THEN
	dbms_sql.column_value(l_cursor_handle,1,l_value);
   END IF;
   --Close cursor
   DBMS_SQL.close_cursor(l_cursor_handle);
   return l_value;
END;


/* Get min and max value of next available slab*/
PROCEDURE get_table_slabs(p_table_name  IN VARCHAR,
                          p_module      in VARCHAR,
                          p_slab_number IN NUMBER,
	                     x_start_slab  OUT nocopy NUMBER,
	                     x_end_slab    OUT nocopy NUMBER) IS
   CURSOR upg_slabs IS
   select slab_start, slab_end
   FROM   cs_upg_slabs
   where  slab_number  = p_slab_number
   and    source_table = p_table_name
   and    module       = p_module;
BEGIN
   for r in upg_slabs loop
      x_start_slab := r.slab_start;
      x_end_slab := r.slab_end;
      exit when true;
   end loop;
END;


/*Create slabs for a table/view */
PROCEDURE create_table_slabs(p_table_name  IN VARCHAR,
                             p_module      in VARCHAR,
	                        p_min_sql     IN VARCHAR,
	                        p_max_sql     IN VARCHAR,
	                        p_no_of_slabs IN NUMBER,
	                        p_min_slab_size IN NUMBER) IS
  l_min NUMBER;  --min pk
  l_max NUMBER;  -- max pk
  l_slab_size NUMBER; --size of the slab
  l_slab_num NUMBER;
  l_last_slab NUMBER; --end of last slab
  l_max_slab NUMBER;
  l_temp NUMBER;
begin
  delete from cs_upg_slabs
  where  source_table = p_table_name
  and    module       = p_module;

  l_min := get_sql_value(p_min_sql);
  l_max := get_sql_value(p_max_sql);
  l_slab_size := ceil((l_max-l_min+1) / p_no_of_slabs);

  --if calculated slab size is smaller then use the min slab size

  if l_slab_size < p_min_slab_size then
	 l_slab_size := p_min_slab_size;
  end if;

  l_last_slab := l_min - 1;
  l_slab_num := 0;

  /*if no available in the table then dont create slabs*/
  if l_min is not null then
    loop
	  l_slab_num := l_slab_num + 1;
	  l_max_slab := l_last_slab + l_slab_size;
	  if l_max_slab > l_max then
		l_max_slab := l_max;
       end if;
       INSERT INTO CS_UPG_SLABS
		(SOURCE_TABLE,
                 MODULE,
                 SLAB_NUMBER,
                 SLAB_START,
                 SLAB_END,
                 CREATED_BY,
  		 CREATED_ON)
	     VALUES (p_table_name,
	             p_module,
                     l_slab_num,
                     l_last_slab + 1,
                     l_max_slab,
                     fnd_global.user_id,
                     sysdate);
       l_last_slab := l_last_slab + l_slab_size;
       exit when l_last_slab >= l_max ;
    end loop;
  end if;
end;

/*Create slabs for a table/view */
PROCEDURE create_table_slabs(
	p_table_name IN VARCHAR,
	p_module IN VARCHAR,
	p_pk_column IN VARCHAR,
	p_no_of_slabs IN NUMBER ,
	p_min_slab_size IN NUMBER
	) IS

l_min_str varchar2(250);
l_max_str varchar2(250);

begin
  l_min_str := 'select min('||p_pk_column||') from '||p_table_name;
  l_max_str := 'select max('||p_pk_column||') from '||p_table_name;
  create_table_slabs(p_table_name => p_table_name,
                     p_module => p_module,
			p_min_sql=>l_min_str,
			p_max_sql=>l_max_str,
			p_no_of_slabs => p_no_of_slabs,
			p_min_slab_size => p_min_slab_size
			);
end;

end csi_mig_slabs_pkg;

/
