--------------------------------------------------------
--  DDL for Package Body OKE_K_ORGANIZER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_K_ORGANIZER_PKG" as
/* $Header: OKEKORGB.pls 115.12 2003/04/30 20:59:06 syho ship $ */

--
-- Public Procedures and Functions
--


--
-- Procedure: populate_query_node
--
-- Purpose: return the tree node data based on the passed in where clause
--
-- Parameters:
--        (IN) x_user_valuse	varchar2	passed in where clause
--             x_icon		varchar2	tree node icon
--	       x_tree_object	varchar2	tree name
--	       x_node_state	number		tree node state
--	       x_low_value	number		low range associated w/current node
--	       x_high_value	number		high range associated w/current node
--
--	 (OUT) x_tree_data_table	fnd_apptree.node_tbl_type	store return tree node data
--	       x_return_status		varchar2			status
--

PROCEDURE populate_query_node (x_user_value		IN		varchar2,
			       x_icon			IN		varchar2,
			       x_tree_object		IN		varchar2,
			       x_node_state		IN		number,
			       x_low_value		IN     		number,
			       x_high_value		IN		number,
			       x_tree_data_table	OUT	NOCOPY	fnd_apptree.node_tbl_type,
			       x_return_status		OUT	NOCOPY	varchar2) is

   l_str		varchar2(10000);
   l_cur_hd 		number;
   l_row_processed 	number;
   l_k_number 		varchar2(120);
   l_k_header_id 	number;
   i 			number := 1;
   j			number := 1;
begin

   l_str := 'select k_number, k_header_id
             from oke_k_headers_secure_v k
             where ' || x_user_value ||
             ' order by k_number';

   l_cur_hd := dbms_sql.open_cursor;

   dbms_sql.parse(l_cur_hd, l_str, dbms_sql.native);
   dbms_sql.define_column(l_cur_hd, 1, l_k_number, 120);
   dbms_sql.define_column(l_cur_hd, 2, l_k_header_id);

   l_row_processed := dbms_sql.execute(l_cur_hd);

   loop

      if dbms_sql.fetch_rows(l_cur_hd) > 0 then

        if j >= x_low_value then

           dbms_sql.column_value(l_cur_hd, 1, l_k_number);
           dbms_sql.column_value(l_cur_hd, 2, l_k_header_id);

           x_tree_data_table(i).state := x_node_state;
           x_tree_data_table(i).depth := 1;
           x_tree_data_table(i).label := l_k_number;
           x_tree_data_table(i).icon  := x_icon;
           x_tree_data_table(i).value := l_k_header_id;
           x_tree_data_table(i).type  := x_tree_object;
           i := i + 1;

        end if;

     else

        exit;

     end if;

     exit when j >= x_high_value;
     j := j + 1;

   end loop;

   x_return_status := 'S';
   dbms_sql.close_cursor(l_cur_hd);

exception
   when OTHERS then
      x_return_status := 'E';

end populate_query_node;


--
-- Procedure: fifo_log
--
-- Purpose: update the contract documents log for user
--
-- Parameters:
--        (IN) x_user_id	number		user id
--             x_k_header_id	number		contract document id
--	       x_object_name	varchar2	tree object name
--

PROCEDURE fifo_log(x_user_id	   number,
  		   x_k_header_id   number,
  		   x_object_name   varchar2) is

     log_size NUMBER := FND_PROFILE.VALUE('OKE_K_FIFO_LOG');

     --
     -- Making this procedure as AUTONOMOUS transaction.
     --
     PRAGMA AUTONOMOUS_TRANSACTION;

begin

     --
     -- Step 1 : Create entry if not exists; use sequence 0
     --
     INSERT INTO oke_k_fifo_logs
     ( user_log_id
     , k_header_id
     , sequence
     , object_name
     , last_update_date
     , last_updated_by
     , creation_date
     , created_by
     , last_update_login )
     SELECT oke_k_fifo_logs_s.nextval
     ,      X_K_Header_ID
     ,      0
     ,      X_Object_Name
     ,      sysdate
     ,      X_User_ID
     ,      sysdate
     ,      X_User_ID
     ,      null
     FROM   dual
     WHERE NOT EXISTS (
       SELECT null
       FROM   oke_k_fifo_logs
       WHERE  k_header_id = X_K_Header_ID
       AND    object_name = X_Object_Name
       AND    created_by  = X_User_ID
     );

     --
     -- Step 2 : Update entry to sequence 0 if already exists
     --
     UPDATE oke_k_fifo_logs
     SET    last_update_date = sysdate
     ,      last_updated_by  = X_User_ID
     ,      sequence         = 0
     WHERE  k_header_id = X_K_Header_ID
     AND    object_name = X_Object_Name
     AND    created_by  = X_User_ID
     AND    sequence   <> 0;

     --
     -- Step 3 : Renumber sequence from 1 while retaining order
     --
     UPDATE oke_k_fifo_logs l1
     SET    sequence = (
       SELECT count(1)
       FROM   oke_k_fifo_logs l2
       WHERE  l2.object_name = l1.object_name
       AND    l2.created_by  = l1.created_by
       AND    l2.last_update_date >= l1.last_update_date )
     WHERE object_name = X_Object_Name
     AND   created_by  = X_User_ID;

     IF ( sql%rowcount > nvl(log_size , 6) ) THEN
	 --
	 -- Step 4 : Prune entries older than profile setting
	 --
	 DELETE FROM oke_k_fifo_logs
	 WHERE object_name = X_Object_Name
	 AND   created_by  = X_User_ID
	 AND   sequence    > nvl(log_size , 6);

     END IF;

     --
     -- This commit is needed to release the lock.  The lock causes
     -- multiple calls to this function to hang.  This resolves the
     -- hanging problem of the organizer calling any other forms.
     --
     commit;

end fifo_log;


--
-- Procedure: get_party_name
--
-- Purpose: get the customer/contractor name for the contract document
--
-- Parameters:
--        (IN) x_role			varchar2		party role
--             x_k_header_id		number			contract document id
--
--	 (OUT) x_party_name		varchar2		party name
--


PROCEDURE get_party_name(x_role	        IN 		varchar2  ,
  		         x_k_header_id  IN  		number    ,
  		         x_party_name   OUT	NOCOPY 	varchar2  ) is
   cursor c_num is
      select object1_id1,
             object1_id2,
             jtot_object1_code
      from   okc_k_party_roles_b
      where  dnz_chr_id = x_k_header_id
      and    rle_code = x_role;

   cursor c_party_table(l_object varchar2) is
      select from_table,
             where_clause
      from   jtf_objects_b
      where  object_code = l_object;

   l_num 	       c_num%ROWTYPE;
   l_name              c_party_table%ROWTYPE;
   l_code              varchar2(50);
   i	               number := 0;
   l_str	       varchar2(10000);
   l_cur_hd            number;
   l_id1	       varchar2(40);
   l_id2	       varchar2(200);
   l_row_processed     number;

begin

    for l_num in c_num loop

        i := i + 1;

        if (i >= 2) then
           exit;
        end if;

        l_code := l_num.jtot_object1_code;
        l_id1  := l_num.object1_id1;

        if (l_num.object1_id2 <> '#') then
           l_id2  := l_num.object1_id2;
        end if;

    end loop;

    if (i >= 2) then

       fnd_message.set_name('OKE', 'OKE_MULTIPLE_PROMPT');
       x_party_name := fnd_message.get;

    elsif (i = 1) then

       open c_party_table(l_code);
       fetch c_party_table into l_name;
       close c_party_table;
     /*
       l_str := 'select name from ' || l_name.from_table
                || ' where id1 = ' || to_number(l_id1);

       if (l_id2 is not null) then
          l_str := l_str || ' and   id2 = ' || to_number(l_id2);
       end if;
     */

       l_str := 'select name from ' || l_name.from_table
                || ' where id1 = :id1';

       if (l_id2 is not null) then
          l_str := l_str || ' and   id2 = :id2';
       end if;

       if (l_name.where_clause is not null) then
          l_str := l_str || ' and ' || l_name.where_clause;
       end if;

       l_cur_hd := dbms_sql.open_cursor;

       dbms_sql.parse(l_cur_hd, l_str, dbms_sql.native);
       dbms_sql.bind_variable(l_cur_hd, 'id1', to_number(l_id1));
       if (l_id2 is not null) then
          dbms_sql.bind_variable(l_cur_hd, 'id2', to_number(l_id2));
       end if;
       dbms_sql.define_column(l_cur_hd, 1, x_party_name, 360);

       l_row_processed := dbms_sql.execute(l_cur_hd);

       loop

         if dbms_sql.fetch_rows(l_cur_hd) > 0 then
            dbms_sql.column_value(l_cur_hd, 1, x_party_name);
         else
            exit;
         end if;

       end loop;

       dbms_sql.close_cursor(l_cur_hd);

   end if;

exception
   when OTHERS then
        x_party_name := null;

end get_party_name;

end OKE_K_ORGANIZER_PKG;

/
