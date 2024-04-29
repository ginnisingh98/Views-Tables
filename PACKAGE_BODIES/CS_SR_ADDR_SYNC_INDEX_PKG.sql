--------------------------------------------------------
--  DDL for Package Body CS_SR_ADDR_SYNC_INDEX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_ADDR_SYNC_INDEX_PKG" AS
/* $Header: csadsyib.pls 115.2 2004/02/10 20:37:43 aneemuch noship $ */

   -- errbuf = err messages
   -- retcode = 0 success, 1 = warning, 2=error

   -- bmode: S = sync  OFAST=optimize fast, OFULL = optimize full

PROCEDURE Sync_All_Index  (
   ERRBUF         OUT NOCOPY  VARCHAR2,
   RETCODE        OUT NOCOPY  NUMBER,
   BMODE          IN          VARCHAR2 DEFAULT NULL )
IS
   l_errbuf varchar2(2000);
   l_retcode number;
   l_mode varchar2(5);
BEGIN
   l_mode := bmode;

   if(bmode is null) then
      l_mode := 'S';
   elsif( bmode not in ('S','OFAST', 'OFULL')) then
      errbuf := 'Invalid mode specified';
      begin
         --3..FND_FILE.PUT_LINE(3..FND_FILE.LOG, errbuf);
         FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);
      exception
         when others then
         null;
      end;

      retcode := 2;
      return;
   end if;

   Sync_Address_Index (l_errbuf, l_retcode, l_mode);

   -- If not success, return error
   if( l_retcode <> 0 ) then
      errbuf  := l_errbuf;
      retcode := l_retcode;
   end if;

   -- Return successfully
   errbuf  := 'Success';
   retcode := 0;

END SYNC_ALL_INDEX;

PROCEDURE Sync_Address_Index  (
   ERRBUF         OUT NOCOPY  VARCHAR2,
   RETCODE        OUT NOCOPY  NUMBER,
   BMODE          IN          VARCHAR2)

IS
-- To fix bug 3431755 added owner to the cursor
   -- cursor to get the owner of the CTX_SUMMARY_INDEX
   cursor get_ind_owner is
   select owner
   from   all_indexes
   where  index_name  = 'ADDRESS_CTX_INDEX'
   and    index_type  = 'DOMAIN'
   and    owner       = 'CS';

-- end of changes , bug fix 3431755

   l_ind_owner       VARCHAR2(90);
   sql_stmt1         VARCHAR2(250);

BEGIN

   if(bmode is null or bmode not in ('S', 'OFAST', 'OFULL')) then
      errbuf := 'Invalid mode specified';

      begin
         --3..FND_FILE.PUT_LINE(3..FND_FILE.LOG, errbuf);
         FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);
      exception
         when others then
         null;
      end;

      retcode := 2;
      return;
   end if;

   open  get_ind_owner;
   fetch get_ind_owner into l_ind_owner;

   if ( get_ind_owner%NOTFOUND ) then
      close get_ind_owner;

      errbuf := 'Index ADDRESS_CTX_INDEX is not found. Please create the domain index ' ||
		'before executing this concurrent program.';
      begin
         FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);
      exception
         when others then
            null;
      end;
      retcode := 2;
      return;
   end if;

   close get_ind_owner;

   sql_stmt1 := 'alter index ' || l_ind_owner || '.address_ctx_index REBUILD ONLINE';

   if(bmode = 'S') then
      sql_stmt1 := sql_stmt1 || ' parameters (''SYNC'') ';
   elsif(bmode = 'OFAST') then
      sql_stmt1 := sql_stmt1 || ' parameters (''OPTIMIZE FAST'') ';
   elsif(bmode = 'OFULL') then
      sql_stmt1 := sql_stmt1 || ' parameters (''OPTIMIZE FULL'') ';
   end if;

   if (bmode = 'S') then
    --ctx_ddl.sync_index( '1..address_ctx_index' );
     ad_ctx_ddl.sync_index( l_ind_owner ||'.address_ctx_index' );
   else
      EXECUTE IMMEDIATE sql_stmt1;
   end if;

   -- Return successfully
   errbuf := 'Success';
   retcode := 0;

EXCEPTION
   WHEN OTHERS THEN
      -- Return error
      errbuf := 'Unexpected error while attempting to sync domain index ADDRESS_CTX_INDEX.'
		|| ' Error : '|| SQLERRM;

      begin
         FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);
      exception
         when others then
            null;
      end;

      retcode := 2;

END Sync_Address_Index;

END CS_SR_ADDR_SYNC_INDEX_PKG;

/
