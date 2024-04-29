--------------------------------------------------------
--  DDL for Package Body GMI_MO_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_MO_PURGE" AS
 /* $Header: GMIPURGB.pls 115.0 2004/02/23 21:27:25 lswamy noship $ */

Procedure Lines(
   errbuf               OUT NOCOPY   VARCHAR2
 , retcode              OUT NOCOPY   VARCHAR2
 , p_organization_id	IN NUMBER    :=NULL
 , p_date_from		IN VARCHAR2  :=NULL
 , p_date_to		IN VARCHAR2  :=NULL
 , p_lines_percommit    IN NUMBER    :=NULL
 , p_purge_option       IN NUMBER)  IS

 loopnum       number := 0;
 l_line_id     NUMBER;
 l_header_id   NUMBER;
 v_sql_stmt    VARCHAR2(300);
 v_object_name VARCHAR2(200);
 l_date_from   DATE:= trunc(fnd_date.canonical_to_date(p_date_from));
 l_date_to     DATE:= trunc(fnd_date.canonical_to_date(p_date_to));
 table_already_exists   EXCEPTION;
 PRAGMA EXCEPTION_INIT  (table_already_exists,-955);



 Cursor  Closed_order_lines IS
  select line_id, flow_status_code, open_flag, cancelled_flag
    from oe_order_lines_all lines
   where lines.flow_status_code in('CLOSED','CANCELLED')
     and ship_from_org_id=p_organization_id
     and trunc(lines.creation_date) between l_date_from and l_date_to;

 Cursor  Default_transactions (p_line_id VARCHAR2) is
 SELECT  trans_id
   FROM  ic_tran_pnd itp
  WHERE  doc_type = 'OMSO'
    AND  trans_qty = 0
    AND  lot_id    = 0
    AND  delete_mark = 0
    AND  completed_ind = 0
    AND  line_detail_id is NULL
    AND  line_id = p_line_id;

  Cursor  For_Cancelled_Closed_MO_lines (p_line_id VARCHAR2) IS
  SELECT  icl.line_id,
          icl.header_id
    FROM  ic_txn_request_lines   icl
   where  icl.line_status = 5
     and  icl.txn_source_line_id = p_line_id;

   Cursor See_if_inv_interface_is_done (p_line_id VARCHAR2) IS
   select count(*)
   from   wsh_delivery_details wdd
   where  wdd.source_line_id=p_line_id
   and    wdd.source_code='OE'
   and    wdd.inv_interfaced_flag = 'Y';

   is_inv_interface_done NUMBER;

   continue exception;

BEGIN

   IF NOT INV_GMI_RSV_BRANCH.Process_Branch(p_organization_id)THEN
     RETURN;
   END IF;

   --
   -- If purge transactions are selected
   --
   IF p_purge_option in (0,2) THEN
      GMI_Reservation_Util.PrintLn('Purging default transactions');
      FOR Order_rec IN Closed_order_lines
      LOOP
        FOR c1rec in Default_transactions (Order_rec.line_id)
        LOOP
           --
           -- Logically delete the transactions.
           --
           update ic_Tran_pnd
           set delete_mark=1
           where trans_id= c1rec.trans_id;


           loopnum := loopnum + 1;

           IF (mod(loopnum, p_lines_percommit) = 0) then
             COMMIT;
           END IF;
        END LOOP; -- Default_transactions
        COMMIT;
      END LOOP;  -- Closed_order_lines
      GMI_Reservation_Util.PrintLn(' '||loopnum||' Default transactions Successfully purged');
    END IF;

    IF p_purge_option in (1,2) THEN
      --
      -- Create the table. If table exists handle the exception.
      --
      BEGIN
         v_sql_stmt := 'CREATE TABLE IC_TXN_REQUEST_HEADERS_BAK AS SELECT * FROM IC_TXN_REQUEST_HEADERS WHERE 1=2';
         EXECUTE IMMEDIATE v_sql_stmt;
      EXCEPTION
        WHEN table_already_exists THEN
          NULL;
      END;

      --
      -- Create the table. If table exists handle the exception.
      --
       BEGIN
         v_sql_stmt := 'CREATE TABLE IC_TXN_REQUEST_LINES_BAK AS SELECT * FROM IC_TXN_REQUEST_LINES WHERE 1=2';
         EXECUTE IMMEDIATE v_sql_stmt;
       EXCEPTION
        WHEN table_already_exists THEN
          NULL;
       END;

      GMI_Reservation_Util.PrintLn('Backup MO Tables successfully Created');
    END IF;

    --
    -- If purge Move order is selected
    --
    IF p_purge_option in (1,2) THEN
      loopnum := 0; -- Intialize loopnum
      GMI_Reservation_Util.PrintLn('Purging Move Order Header/Lines');
      FOR Order_rec IN Closed_order_lines
      LOOP
         BEGIN
            --
            -- Check if the order is CLOSED and deliveries are INV interfaced.
            --
            IF (Order_rec.flow_status_code = 'CLOSED') THEN
	            OPEN  See_if_inv_interface_is_done (Order_rec.line_id);
	            FETCH See_if_inv_interface_is_done into is_inv_interface_done;
	            CLOSE See_if_inv_interface_is_done;

	            IF (is_inv_interface_done = 0) THEN
	              -- this line is not yet interfaced. Skip this record.
	              RAISE continue;
	            END IF;
	    END IF;

	    --
	    -- Loop thru all the MO lines and archive them in _BAK table.
	    --
	    OPEN For_Cancelled_Closed_MO_lines (Order_rec.line_id);
	    LOOP
	         FETCH For_Cancelled_Closed_MO_lines into l_line_id, l_header_id;
	         EXIT WHEN For_Cancelled_Closed_MO_lines%NOTFOUND;

	         BEGIN
                         --
                         -- Archive first.
                         --
			 v_sql_stmt :=
			 'INSERT INTO IC_TXN_REQUEST_LINES_BAK ' ||
			 '(SELECT * FROM IC_TXN_REQUEST_LINES  ' ||
			 ' WHERE line_id = :1) ';

			 EXECUTE IMMEDIATE v_sql_stmt using l_line_id;

			 v_sql_stmt :=
			 'INSERT INTO IC_TXN_REQUEST_HEADERS_BAK ' ||
			 ' (SELECT * FROM IC_TXN_REQUEST_HEADERS ' ||
			 ' WHERE header_id = :1) ';

			 EXECUTE IMMEDIATE v_sql_stmt using l_header_id;

                         --
                         -- Physically delete.
                         --
			 DELETE FROM  ic_txn_request_lines
			         WHERE line_id=l_line_id;

			 DELETE  FROM   ic_txn_request_headers ich
			          WHERE  header_id=l_header_id
			          AND  NOT EXISTS (select 1 from ic_txn_request_lines icl
			                            where icl.header_id=ich.header_id);
		 EXCEPTION
		      WHEN others THEN
		          raise continue;
		 END;

	    END LOOP; -- For_Cancelled_Closed_MO_lines

	    IF (For_Cancelled_Closed_MO_lines%ISOPEN) THEN
	       CLOSE For_Cancelled_Closed_MO_lines;
	    END IF;

	    loopnum := loopnum + 1;

	    IF (mod(loopnum,p_lines_percommit) = 0) THEN
	         COMMIT;
	    END IF;


         EXCEPTION
           WHEN continue THEN
               NULL;
         END;
      END LOOP;
      COMMIT;
      GMI_Reservation_Util.PrintLn('About '||loopnum||' Move Order Header/Lines purged successfully');
    END IF;
    EXCEPTION
            when others then
            GMI_Reservation_Util.PrintLn('Exception has occurred'||SQLERRM|| ' : ' || SQLCODE );
            ROLLBACK;

    END Lines;

END GMI_MO_PURGE;

/
