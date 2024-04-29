--------------------------------------------------------
--  DDL for Package Body IBE_PURGE_QUOTES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_PURGE_QUOTES" as
/* $Header: IBEPURGEB.pls 120.0.12010000.2 2015/08/01 05:43:30 ytian noship $  */

procedure purgeIBEQuoteObjects(
	errbuf	OUT NOCOPY VARCHAR2,
	retcode OUT NOCOPY NUMBER
)
is
 l_api_name     CONSTANT VARCHAR2(30) := 'purgeIBEQuoteObjects';
 error_code                NUMBER;
 error_msg                 VARCHAR2(2000);
BEGIN

/* DELETE the records in IBE_ACTIVE_QUOTES_ALL tables for the purged quotes in the ASO side */

BEGIN
  FND_FILE.PUT_LINE(FND_FILE.LOG,'Begin purging Table IBE_ACTIVE_QUOTES_ALL');

delete from  ibe_active_quotes_all a
where a.quote_header_id is not null
      and not exists
           (select 1
            from aso_quote_headers_all h
            where a.quote_header_id = h.quote_header_id);

FND_FILE.PUT_LINE(FND_FILE.LOG,'Purge IBE_ACTIVE_QUOTES_ALL completed sucessfully');

Exception
WHEN OTHERS THEN
  Error_code := SQLCODE;
  Error_msg  := SUBSTR(SQLERRM, 1, 200);
  FND_FILE.PUT_LINE(FND_FILE.LOG,
         'Exception in delete IBE_ACTIVE_QUOTES_ALL table'
         ||': Error Code:  '
         ||Error_code||' Error Msg  '|| Error_msg );
  FND_FILE.PUT_LINE(FND_FILE.LOG,
     'Exception: Unable to delete '||
     ' IBE_ACTIVE_QUOTES_ALL rows so Rollback');

  ROLLBACK;

END;

BEGIN
  FND_FILE.PUT_LINE(FND_FILE.LOG,
      'Begin purging IBE_SH_QUOTE_ACCESS');

  delete from  IBE_SH_QUOTE_ACCESS a
  where a.quote_header_id is not null
      and not exists
           (select 1
            from aso_quote_headers_all h
            where a.quote_header_id = h.quote_header_id);

FND_FILE.PUT_LINE(FND_FILE.LOG,
   'Done purging IBE_SH_QUOTE_ACCESS');

Exception
WHEN OTHERS THEN
  Error_code := SQLCODE;
  Error_msg  := SUBSTR(SQLERRM, 1, 200);
  FND_FILE.PUT_LINE(FND_FILE.LOG,
         'Exception in delete IBE_SH_QUOTE_ACCESS table'
         ||': Error Code:  '
         ||Error_code||' Error Msg  '|| Error_msg );
  FND_FILE.PUT_LINE(FND_FILE.LOG,
     'Exception: Unable to delete '||
     ' IBE_SH_QUOTE_ACCESS rows so Rollback');

  ROLLBACK;

END;

FND_FILE.PUT_LINE(FND_FILE.LOG,'Procedure completed sucessfully');

end;


end IBE_PURGE_QUOTES ;

/
