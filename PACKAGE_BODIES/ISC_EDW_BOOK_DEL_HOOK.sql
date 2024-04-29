--------------------------------------------------------
--  DDL for Package Body ISC_EDW_BOOK_DEL_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_EDW_BOOK_DEL_HOOK" AS
/*$Header: ISCHK00B.pls 115.4 2004/03/15 09:56:36 visgupta noship $ */

PROCEDURE POST_FACT_COLL IS

  l_number_rows		NUMBER;

  l_isc_owner		VARCHAR2(40);
  l_stmt 		VARCHAR2(4000);

BEGIN

  EDW_OWB_COLLECTION_UTIL.Write_To_Log_File('Post Collection Hook for the Bookings Fact');

  l_isc_owner := EDW_OWB_COLLECTION_UTIL.Get_Db_User('ISC');

  EDW_OWB_COLLECTION_UTIL.Write_To_Log_File('');
  EDW_OWB_COLLECTION_UTIL.Write_To_Log_File('Going to truncate ISC_EDW_BOOK_DEL table');

  l_stmt := 'TRUNCATE TABLE '||l_isc_owner||'.ISC_EDW_BOOK_DEL';
  EXECUTE IMMEDIATE l_stmt;

  EDW_OWB_COLLECTION_UTIL.Write_To_Log_File('');
  EDW_OWB_COLLECTION_UTIL.Write_To_Log_File('Truncation of the table ISC_EDW_BOOK_DEL done');


  EDW_OWB_COLLECTION_UTIL.Write_To_Log_File('');
  EDW_OWB_COLLECTION_UTIL.Write_To_Log_File('Going to insert into ISC_EDW_BOOK_DEL table');

  l_stmt :=	'INSERT INTO '||l_isc_owner||'.ISC_EDW_BOOK_DEL'||
		'     SELECT book.bookings_pk, book.line_id, inst.inst_instance_pk'||
		'	FROM ISC_EDW_BOOKINGS_F 	book,'||
		'	     EDW_INSTANCE_M 		inst'||
		'      WHERE book.fulfillment_flag = ''N'''||
		'	 AND book.instance_fk_key = inst.inst_instance_pk_key';
  EXECUTE IMMEDIATE l_stmt;

  EDW_OWB_COLLECTION_UTIL.Write_To_Log_File('Finished inserting into the table ISC_EDW_BOOK_DEL');
  EDW_OWB_COLLECTION_UTIL.Write_To_Log_File('');

  l_stmt := 'SELECT count(*) FROM ISC_EDW_BOOK_DEL';
  EXECUTE IMMEDIATE l_stmt INTO l_number_rows;

  EDW_OWB_COLLECTION_UTIL.Write_To_Log_File('Inserted '|| nvl(l_number_rows,0) ||' rows into ISC_EDW_BOOK_DEL.');

  COMMIT;

EXCEPTION

  WHEN OTHERS
    THEN
      ROLLBACK;
      EDW_OWB_COLLECTION_UTIL.Write_To_Log_File('Error in Post-Load Hook for Bookings Fact: '||sqlerrm);

END POST_FACT_COLL;

END ISC_EDW_BOOK_DEL_HOOK;

/
