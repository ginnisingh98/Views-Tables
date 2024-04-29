--------------------------------------------------------
--  DDL for Package Body ICX_POR_EXTRACTOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_POR_EXTRACTOR" AS
/* $Header: ICXEXTMB.pls 120.2 2008/02/14 20:27:56 aharihar ship $*/

gLastRunDate		Date;

PROCEDURE setLastRunDates(pType 	IN VARCHAR2)
IS
  xErrLoc	PLS_INTEGER := 100;
BEGIN

  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
    'Update last run dates');

  IF pType = 'VENDOR_NAME' then
    xErrLoc := 120;
    UPDATE ICX_POR_LOADER_VALUES
    SET    vendor_last_run_date = gLastRunDate;
  ELSIF pType = 'CATEGORY' then
    IF gLoaderValue.load_categories = 'Y' THEN
      gLoaderValue.categories_last_run_date := gLastRunDate;
    END IF;
    xErrLoc := 120;
    UPDATE ICX_POR_LOADER_VALUES
    SET    categories_last_run_date =
           gLoaderValue.categories_last_run_date;
  ELSIF pType = 'TEMPLATE_HEADER' then
    IF gLoaderValue.load_template_headers = 'Y' THEN
      gLoaderValue.template_headers_last_run_date := gLastRunDate;
    END IF;
    xErrLoc := 140;
    UPDATE ICX_POR_LOADER_VALUES
    SET    template_headers_last_run_date =
           gLoaderValue.template_headers_last_run_date;
  ELSIF pType = 'TEMPLATE' THEN
    xErrLoc := 160;
    IF (gLoaderValue.load_template_lines = 'Y') THEN
      gLoaderValue.template_lines_last_run_date := gLastRunDate;
    END IF;
    UPDATE icx_por_loader_values
    SET    template_lines_last_run_date =
           gLoaderValue.template_lines_last_run_date;
  ELSIF pType = 'CONTRACT' THEN
    xErrLoc := 160;
    IF (gLoaderValue.load_contracts = 'Y') THEN
      gLoaderValue.contracts_last_run_date := gLastRunDate;
    END IF;
    UPDATE icx_por_loader_values
    SET    contracts_last_run_date =
           gLoaderValue.contracts_last_run_date;
  ELSIF pType = 'ITEM' THEN
    xErrLoc := 160;
    IF (gLoaderValue.load_item_master = 'Y') THEN
      gLoaderValue.item_master_last_run_date := gLastRunDate;
    END IF;
    IF (gLoaderValue.load_internal_item = 'Y') THEN
      gLoaderValue.internal_item_last_run_date := gLastRunDate;
    END IF;
    UPDATE icx_por_loader_values
    SET    item_master_last_run_date =
           gLoaderValue.item_master_last_run_date,
           internal_item_last_run_date =
           gLoaderValue.internal_item_last_run_date;
  END IF;

  xErrLoc := 200;
  ICX_POR_EXT_UTL.extAFCommit;

EXCEPTION
  when others then
    ICX_POR_EXT_UTL.extRollback;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXTRACTOR.setLastRunDates-'||
      xErrLoc||' '||SQLERRM);
    raise ICX_POR_EXT_UTL.gException;
END setLastRunDates;


--------------------------------------------------------------
--              Extractor Main Entry Procedure              --
--------------------------------------------------------------

PROCEDURE extract(pType 	IN VARCHAR2,
                  pFileName 	IN varchar2,
                  pDebugLevel 	IN PLS_INTEGER,
                  pCommitSize	IN PLS_INTEGER)
IS
  xErrLoc		PLS_INTEGER := 100;
  xFlexFrozenFlag	VARCHAR2(1);
  xCommitSize		PLS_INTEGER := 2000;
  xErrMsg		VARCHAR2(2000) := '';

BEGIN

  gUserId := fnd_global.user_id;
  gLoginId := fnd_global.login_id;
  gRequestId := fnd_global.conc_request_id;
  gProgramApplicationId := fnd_global.prog_appl_id;
  gProgramId := fnd_global.conc_program_id;

  IF ICX_POR_EXT_TEST.gTestMode = 'Y' THEN
    gUserId := ICX_POR_EXT_TEST.TEST_USER_ID;
  END IF;

  xErrLoc := 105;
  -- get a dummy batch job, which is used for rebuild index
  IF gRequestId = -1 THEN
    select icx_por_batch_jobs_s.nextval
    into   gRequestId
    from   dual;
  END IF;
  gJobNum := gRequestId;

  ICX_POR_EXT_UTL.gDebugLevel := pDebugLevel;

  xErrLoc := 110;
  -- Bug#4364929 : For extractor concurrent program no need to
  -- open log explicitly.
  --ICX_POR_EXT_UTL.openLog(pFileName);
  fnd_file.put_line(fnd_file.log, 'Commented out openLog');

  xErrLoc := 120;

  -- set commit size > 2500 for better performance
  if (pCommitSize > 0) then
    ICX_POR_EXT_UTL.gCommitSize := pCommitSize;
  else
    -- get defaul commit size from profile option
    fnd_profile.get('POR_LOAD_PURGE_COMMIT_SIZE', xCommitSize);
    ICX_POR_EXT_UTL.gCommitSize := xCommitSize;
  end if;

  xErrLoc := 200;

  -- get loader value from ICX_POR_LOADER_VALUES
 -- Bug # 3991430
   -- New column is added in the ICX_POR_LOADER_VALUES table to extract one time item in all the installed languages

  select nvl(load_catalog_groups, 'N'),
         nvl(load_categories, 'N'),
         nvl(load_template_headers, 'N'),
         'Y',
         nvl(load_item_master, 'N'),
         nvl(load_template_lines, 'N'),
         catalog_groups_last_run_date,
         categories_last_run_date,
         template_headers_last_run_date,
         contracts_last_run_date,
         item_master_last_run_date,
         template_lines_last_run_date,
         vendor_last_run_date,
         nvl(load_internal_item, 'N'),
         internal_item_last_run_date,
         nvl(cleanup_flag, 'N'),
         nvl(load_onetimeitems_in_all_langs, 'N')  -- Bug # 3991430
    into gLoaderValue.load_catalog_groups,
         gLoaderValue.load_categories,
         gLoaderValue.load_template_headers,
         gLoaderValue.load_contracts,
         gLoaderValue.load_item_master,
         gLoaderValue.load_template_lines,
         gLoaderValue.catalog_groups_last_run_date,
         gLoaderValue.categories_last_run_date,
         gLoaderValue.template_headers_last_run_date,
         gLoaderValue.contracts_last_run_date,
         gLoaderValue.item_master_last_run_date,
         gLoaderValue.template_lines_last_run_date,
         gLoaderValue.vendor_last_run_date,
         gLoaderValue.load_internal_item,
         gLoaderValue.internal_item_last_run_date,
         gLoaderValue.cleanup_flag,
	 gLoaderValue.load_onetimeitems_all_langs  -- Bug # 3991430
    from icx_por_loader_values
   where rownum = 1;

  xErrLoc := 300;
  -- get last run date before starting process
  gLastRunDate := sysdate;

  xErrLoc := 310;

  -- get base and nls languages
  SELECT language_code,
         nls_language
  INTO   gBaseLang,
         gNLSLanguage
  FROM   fnd_languages
  WHERE  installed_flag = 'B';

  xErrLoc := 320;
  -- get system process ID for better debug
  select spid "System Process ID"
  into   gSpid
  from   v$process
  where  addr in (select paddr
                  from   v$session
                  where  audsid = userenv('sessionid'));

  xErrLoc := 340;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL, 'BEGIN Extractor');
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL, 'Start to extract ' ||
    pType || ': job number ' || gJobNum || ', system process id ' || gSpid);

  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
    'Commit size: ' || ICX_POR_EXT_UTL.gCommitSize ||
    ', Debug level: ' || ICX_POR_EXT_UTL.gDebugLevel);

  -- FPI feature, Print Extractor Parameters
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL, 'Loader Values[' ||
    'Load Catalog Groups: ' || gLoaderValue.load_catalog_groups || ', ' ||
    'Load Categories: ' || gLoaderValue.load_categories || ', ' ||
    'Load Template Headers: ' || gLoaderValue.load_template_headers ||', ' ||
    'Load Contracts: ' || gLoaderValue.load_contracts || ', ' ||
    'Load Item Master: ' || gLoaderValue.load_item_master || ', ' ||
    'Load Template Lines: ' || gLoaderValue.load_template_lines || ', ' ||
    'Load Internal Items: ' || gLoaderValue.load_internal_item || ', ' ||
    'Cleanup Flag: ' || gLoaderValue.cleanup_flag || ', ' ||
    'Catalog Groups Last Run Date: ' ||
    TO_CHAR(gLoaderValue.catalog_groups_last_run_date, 'MM/DD/YY HH24:MI:SS') || ', ' ||
    'Categories Last Run Date: ' ||
    TO_CHAR(gLoaderValue.categories_last_run_date, 'MM/DD/YY HH24:MI:SS') || ', ' ||
    'Template Headers Last Run Date: ' ||
    TO_CHAR(gLoaderValue.template_headers_last_run_date, 'MM/DD/YY HH24:MI:SS') || ', ' ||
    'Contracts Last Run Date: ' ||
    TO_CHAR(gLoaderValue.contracts_last_run_date, 'MM/DD/YY HH24:MI:SS') || ', ' ||
    'Item Master Last Run Date: ' ||
    TO_CHAR(gLoaderValue.item_master_last_run_date, 'MM/DD/YY HH24:MI:SS') || ', ' ||
    'Template Lines Last Run Date: ' ||
    TO_CHAR(gLoaderValue.template_lines_last_run_date, 'MM/DD/YY HH24:MI:SS') || ', ' ||
    'Vendor Last Run Date: ' ||
    TO_CHAR(gLoaderValue.vendor_last_run_date, 'MM/DD/YY HH24:MI:SS') || ', ' ||
    'Internal Item Last Run Date: ' ||
    TO_CHAR(gLoaderValue.internal_item_last_run_date, 'MM/DD/YY HH24:MI:SS') ||', ' ||  -- Bug # 3991430
    'Load One Time Items In all Langs: ' ||  -- Bug # 3991430
     gLoaderValue.load_onetimeitems_all_langs || ']');

  xErrLoc := 350;
  -- Get count of installed languages, in order to set commit size
  SELECT COUNT(*)
    INTO gInstalledLanguageCount
    FROM fnd_languages
   WHERE installed_flag IN ('B', 'I');

  xErrLoc := 400;
  if (pType = 'CLASSIFICATION') then
    xErrLoc := 410;
    -- Bug#2273120 - srmani : Message to Recompile FlexFields.
    -- Check if flex field 'Item Category' is compiled successfully
    select nvl(f.freeze_flex_definition_flag, 'N')
    into   xFlexFrozenFlag
    from   fnd_id_flex_structures f,
           mtl_default_sets_view m
    where  f.application_id = 401
    and    f.id_flex_code = 'MCAT'
    and    f.id_flex_num = m.structure_id
    and    m.functional_area_id = 2;

    xErrLoc := 420;
    if (xFlexFrozenFlag = 'Y') then
       ICX_POR_EXT_CLASS.extractClassificationData;
    else
      select message_text
      into   xErrMsg
      from   fnd_new_messages
      where  message_name = 'ICX_POR_RECOMPILE_CAT_FLEXFLDS'
      and    language_code = USERENV('LANG');

      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL, xErrMsg);
      RAISE ICX_POR_EXT_UTL.gFatalException;
      return;
    end if;

    -- purge classification data
    xErrLoc := 440;
    ICX_POR_EXT_PURGE.purgeClassificationData;
  elsif (pType = 'ITEM') then   -- ITEMS
    xErrLoc := 450;
   -- Bug#2273120 - srmani : Message to Recompile FlexFields.
   -- Check if flex field 'System Items' is compiled successfully
    select nvl(f.freeze_flex_definition_flag, 'N')
    into   xFlexFrozenFlag
    from   fnd_id_flex_structures f,
           mtl_default_sets_view m
    where  f.application_id = 401
    and    f.id_flex_code = 'MSTK'
    and    f.id_flex_num = 101
    and    rownum = 1;

    xErrLoc := 460;
    if (xFlexFrozenFlag = 'Y') then
       ICX_POR_EXT_ITEM.extractItemData;
    else
      select message_text
      into   xErrMsg
      from   fnd_new_messages
      where  message_name = 'ICX_POR_RECOMPILE_ITM_FLEXFLDS'
      and    language_code = USERENV('LANG');

      ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.ERROR_LEVEL, xErrMsg);
      RAISE ICX_POR_EXT_UTL.gFatalException;
      return;
    end if;

    -- Bug#6374614. Set the extractor_updated_flag to N if only BULKLOAD item
    -- prices are available.

    xErrLoc := 470;

    update icx_cat_items_b it
    SET EXTRACTOR_UPDATED_FLAG = 'N'
    WHERE NOT EXISTS
      (SELECT 1 FROM icx_cat_item_prices itp
       WHERE PRICE_TYPE NOT in ( 'BULKLOAD' , 'CONTRACT')
       AND itp.rt_item_id = it.rt_item_id)
    AND EXTRACTOR_UPDATED_FLAG = 'Y'
    AND trunc(it.PROGRAM_UPDATE_DATE) = trunc(gLastRunDate);

  end if;

  xErrLoc := 500;
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL, 'END Extractor');

  xErrLoc := 600;
  -- popolates interMedia index
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
    'Populate interMedia index BEGIN');
  ICX_POR_CTX_DESC.populateCtxDescAll(gJobNum, 'N');
  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
    'Populate interMedia index END');

  ICX_POR_EXT_UTL.closeLog;
  xErrLoc := 700;

EXCEPTION
  WHEN OTHERS THEN
    ICX_POR_EXT_UTL.extRollback;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXTRACTOR.extract-'||
      xErrLoc||' '||SQLERRM);
    ICX_POR_EXT_UTL.printStackTrace;
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL, 'Extractor Stopped');
    -- popolates interMedia index
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
      'Populate interMedia index BEGIN');
    ICX_POR_CTX_DESC.populateCtxDescAll(gJobNum, 'N');
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
      'Populate interMedia index END');

    ICX_POR_EXT_UTL.closeLog;
    RAISE;
END extract;


--------------------------------------------------------------
--               Purge Main Entry Procedure                 --
--------------------------------------------------------------

PROCEDURE purge(pFileName 	IN varchar2,
                pDebugLevel 	IN PLS_INTEGER,
                pCommitSize	IN PLS_INTEGER)
IS
  xErrLoc		PLS_INTEGER := 100;
  xCommitSize		PLS_INTEGER := 2000;
BEGIN

  ICX_POR_EXT_UTL.gDebugLevel := pDebugLevel;

  xErrLoc := 110;
  -- Bug#4364929: For extractor concurrent program no need to
  -- open log explicitly.
  --ICX_POR_EXT_UTL.openLog(pFileName);
  fnd_file.put_line(fnd_file.log, 'Commented out openLog');

  xErrLoc := 120;

  -- set the commitsize equal to the one user entered
  -- set commit size > 2500 for better performance
  if (pCommitSize > 0) then
    ICX_POR_EXT_UTL.gCommitSize := pCommitSize;
  else
    -- get defaul commit size from profile option
    fnd_profile.get('POR_LOAD_PURGE_COMMIT_SIZE', xCommitSize);
    ICX_POR_EXT_UTL.gCommitSize := xCommitSize;
  end if;

  xErrLoc := 180;
  -- get base and nls languages
  SELECT language_code,
         nls_language
  INTO   gBaseLang,
         gNLSLanguage
  FROM   fnd_languages
  WHERE  installed_flag = 'B';

  xErrLoc := 190;
  -- get system process ID for better debug
  select spid "System Process ID"
  into   gSpid
  from   v$process
  where  addr in (select paddr
                  from   v$session
                  where  audsid = userenv('sessionid'));

  xErrLoc := 200;

  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL,
    'BEGIN Purge: system process id ' || gSpid);

  -- purge classification data
  xErrLoc := 300;
  ICX_POR_EXT_PURGE.purgeClassificationData;

  -- purge item data
  xErrLoc := 300;
  ICX_POR_EXT_PURGE.purgeItemData;

  ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL, 'END Purge');
  ICX_POR_EXT_UTL.closeLog;

EXCEPTION
  when ICX_POR_EXT_UTL.gFatalException then
    ICX_POR_EXT_UTL.extRollback;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXTRACTOR.purge-'||xErrLoc);
    ICX_POR_EXT_UTL.printStackTrace;
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL, 'Purge Stopped');
    ICX_POR_EXT_UTL.closeLog;
    raise;
  when ICX_POR_EXT_UTL.gException then
    ICX_POR_EXT_UTL.extRollback;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXTRACTOR.purge-'||xErrLoc);
    ICX_POR_EXT_UTL.printStackTrace;
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL, 'Purge Stopped');
    ICX_POR_EXT_UTL.closeLog;
    raise;
  when others then
    ICX_POR_EXT_UTL.extRollback;
    ICX_POR_EXT_UTL.pushError('ICX_POR_EXTRACTOR.purge-'||
      xErrLoc||' '||SQLERRM);
    ICX_POR_EXT_UTL.printStackTrace;
    ICX_POR_EXT_UTL.debug(ICX_POR_EXT_UTL.MUST_LEVEL, 'Purge Stopped');
    ICX_POR_EXT_UTL.closeLog;
    raise;
END purge;


END ICX_POR_EXTRACTOR;

/
