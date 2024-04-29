--------------------------------------------------------
--  DDL for Package Body IBE_REPORTING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_REPORTING_PVT" AS
/* $Header: IBEVECRB.pls 120.2 2005/09/14 03:07:57 appldev ship $ */
	l_debug VARCHAR2(1) := 'N';
	l_debug_profile VARCHAR2(1) := 'N';

G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBE_REPORTING_PKG';

g_conversionType   FND_PROFILE_OPTION_VALUES.PROFILE_OPTION_VALUE%TYPE;
g_CurrencyCode     FND_PROFILE_OPTION_VALUES.PROFILE_OPTION_VALUE%TYPE;
g_periodSetName    FND_PROFILE_OPTION_VALUES.PROFILE_OPTION_VALUE%TYPE;
g_ForceRefreshFlag	Varchar2(1);
g_QuarterBeginFlag	Varchar2(1);
g_YearlyDataFlag        Varchar2(1);
g_ParallelFlag		Varchar2(1);
g_dayoffset			Number;
g_TruncateFlag		Varchar2(1);
g_RefreshMV			Varchar2(1);


g_inputRefreshMode	Varchar2(50) := 'COMPLETE';
g_inputBeginDate		Varchar2(50);
g_inputEndDate		Varchar2(50);
g_debugFlag			Varchar2(2) := 'Y';


g_maxRows 			Number;
g_data_source           Varchar2(2000);
g_refreshSysDate		Date;

g_idx_tablespace        Varchar2(30);

g_setupErrorCount	Number := 0;

g_maxamount_ceil        Number := 15000000;

g_error_threshhold      Number := 25;

IBE_ECR_SETUP_ERROR     Exception;
PRAGMA EXCEPTION_INIT(IBE_ECR_SETUP_ERROR,-20200);

IBE_ECR_CALENDER_ERROR     Exception;
PRAGMA EXCEPTION_INIT(IBE_ECR_CALENDER_ERROR,-20201);

IBE_ECR_PROFILE_ERROR     Exception;
PRAGMA EXCEPTION_INIT(IBE_ECR_PROFILE_ERROR,-20202);

IBE_ECR_CONVERSION_ERROR     Exception;
PRAGMA EXCEPTION_INIT(IBE_ECR_CONVERSION_ERROR,-20204);

IBE_ECR_RATES_MISSING_ERR     Exception;
PRAGMA EXCEPTION_INIT(IBE_ECR_RATES_MISSING_ERR,-20205);

Cursor c_lookup(ptype IN Varchar2) IS
	Select LookUp_Code,Meaning
	From   Fnd_Lookups
	Where  Lookup_Type  =  ptype;

Cursor c_currency(ptype IN Varchar2) IS
	Select LookUp_Code
	From   Fnd_Lookups
	Where  Lookup_Type  =  ptype;


    PROCEDURE printDebugLog(pDebugStmt Varchar2) IS
      BEGIN

       -- Debug Procedure
       -- Y : Display Debug in the Conc. Program Log.
       -- N:  No Debug Statement

        If g_debugFlag = 'Y' Then
           FND_FILE.PUT_LINE(FND_FILE.LOG,pDebugStmt);
        END IF;

           IF (l_debug_profile = 'Y') THEN
              IBE_UTIL.debug(pDebugStmt);
           END IF;

  End printDebugLog;

  PROCEDURE printOutput(pMessage Varchar2) IS
     l_printTimeStamp Varchar2(25):= NULL;
  BEGIN


       IF Substr(pMessage,1,1) <> '+' Then
       l_printTimeStamp := to_char(sysdate,'RRRR/MM/DD HH:MI:SS')||' ';
       End If;

       If FND_GLOBAL.user_id > -1 Then
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_printTimeStamp||pMessage);
       End If;

 END printOutput;



function  get_item_count(inventory_item_id in number,header_id in number) return number is
v_inventory_item_id  number;
v_result             number default 0;


cursor get_count(l_inventory_item_id number,l_header_id number) is
select count(distinct nvl(oh.order_number,0))
from oe_order_lines_all ol , oe_order_headers_all oh
WHERE oh.header_id = l_header_id and
oh.header_id = ol.header_id and
nvl(OH.cancelled_flag,'N') = 'N' and
nvl(oh.booked_flag,'N')= 'Y' and
ol.inventory_item_id = l_inventory_item_id and
nvl(ol.cancelled_flag,'N')= 'N' and
nvl(ol.booked_flag,'N')= 'Y' and
link_to_line_id is NULL ;

BEGIN

  open get_count(inventory_item_id,header_id);
  fetch get_count into v_result;
  close get_count;
  return(TO_NUMBER(v_result));
  EXCEPTION
  WHEN OTHERS THEN
   return(0);
END;


  FUNCTION getMessage(pOwner IN Varchar2,pName IN Varchar2) Return Varchar2

  IS
  	l_Message Varchar2(2000);

  BEGIN
            FND_MESSAGE.Set_Name(pOwner,pName);
            l_Message := FND_MESSAGE.get;
	    Return l_Message;
  END  getMessage;

  FUNCTION getMessage(pOwner IN Varchar2,pName IN Varchar2,ptokenValue IN Varchar2) Return Varchar2

  IS

  	l_Message Varchar2(2000);

  BEGIN
            FND_MESSAGE.Set_Name(pOwner,pName);
            FND_MESSAGE.Set_Token('NAME',ptokenValue);
            l_Message := FND_MESSAGE.get;
	    Return l_Message;
  END  getMessage;


 PROCEDURE getTableSpace(ptype IN Varchar2,pTabSpace OUT NOCOPY Varchar2) IS
 Begin
       IF (l_debug = 'Y') THEN
          printDebugLog('getTableSpace(+)');
   	 printDebugLog(fnd_global.tab||'IN Parameters: '||ptype);
       END IF;
         If ptype = 'INDEX' Then
              select i.index_tablespace  Into pTabSpace
              from fnd_product_installations i, fnd_application a, fnd_oracle_userid u
              where a.application_short_name = 'IBE'
              and a.application_id = i.application_id
              and u.oracle_id = i.oracle_id;
         End If;
       IF (l_debug = 'Y') THEN
          printDebugLog(fnd_global.tab||'OUT Parameters: '||pTabSpace);
          printDebugLog('getTableSpace(-)');
       END IF;
  End  getTableSpace;

  PROCEDURE printParameterOut(pMode IN Varchar2,pBeginDate IN Varchar2,pEndDate IN Varchar2,pDayOffset IN Varchar2) IS
  BEGIN

	printOutput('*** '||getMessage('IBE','IBE_ECR_INPUT_TITLE')||' ***');
        printOutput(getMessage('IBE','IBE_ECR_REFRESH_MODE')||': '||pMode);
        printOutput(getMessage('IBE','IBE_ECR_BEGIN_DATE')||': '||pBeginDate);
        printOutput(getMessage('IBE','IBE_ECR_END_DATE')||': '||pEndDate);
        -- printOutput(getMessage('IBE','IBE_ECR_DAYOFFSET')||': '||pdayOffset);

  END printParameterOut;


  PROCEDURE printProfileOut IS

  BEGIN

	printOutput('*** '||getMessage('IBE','IBE_ECR_PROFILE_TITLE')||' ***');
        printOutput('IBE_ECR_PERIOD_SET_NAME:' ||nvl(g_PeriodSetName,'ORA-20202: '|| getMessage('IBE','IBE_ECR_PROFILE_VALUE','IBE_ECR_PERIOD_SET_NAME')));
        printOutput('IBE_GL_CONVERSION_TYPE: ' || nvl(g_conversionType,'ORA-20202: '||getMessage('IBE','IBE_ECR_PROFILE_VALUE','IBE_GL_CONVERSION_TYPE')));
        printOutput('IBE_CURRENCY_CODE: ' || nvl(g_currencyCode,'ORA-20202: '||getMessage('IBE','IBE_ECR_PROFILE_VALUE','IBE_CURRENCY_CODE')));
        printOutput('IBE_ECR_FORCE_REFRESH: '||g_ForceRefreshFlag);
        printOutput('IBE_ENABLE_PARALLEL_PROCESSING: '||g_parallelFlag);
        printOutput('IBE_ECR_QUARTER_BEGIN_DATA: '||g_QuarterBeginFlag);
        printOutput('IBE_ECR_YEARLY_DATA: '||g_YearlyDataFlag);
        printOutput('IBE_TRUNC_RECORDS: '||g_TruncateFlag);

  END printProfileOut;

  PROCEDURE printBinFreqDateOut(pBinRefreshDate IN Date) IS

   l_StartDate Date;
   l_EndDate   Date;

  BEGIN
	printOutput('*** '||getMessage('IBE','IBE_ECR_BIN_FREQ_DATE')||' ***');
        For rec_lookup IN c_lookup('IBE_BIN_FREQUENCY') Loop
            Begin
            getFrequencyDate(pBinRefreshDate,rec_lookup.lookup_Code,g_PeriodSetName,
			     g_dayoffset,l_StartDate,l_EndDate);
            printOutput(rec_lookup.meaning||': '||to_char(l_StartDate,'YYYY/MM/DD  HH24:MI:SS')||' - '||to_char(l_EndDate,'YYYY/MM/DD  HH24:MI:SS'));
            Exception
             When IBE_ECR_CALENDER_ERROR Then
              g_setupErrorCount := g_setupErrorCount + 1;
              printOutput(rec_lookup.meaning||': ');
              printOutput(SQLERRM);
            End;
        End Loop;

  END printBinFreqDateOut;


  PROCEDURE printOrderSourceOut(pOrderSource IN Varchar2) IS

  BEGIN
	printOutput('*** '||getMessage('IBE','IBE_ECR_ORDER_SOURCES')||' ***');
	printOutput(nvl(pOrderSource,' '));
  END printOrderSourceOut;


PROCEDURE updateLog(pMvlogid  	IN      Number,
            	pStatus   	IN      Number,
          	pLogTime 	IN      Date,
		pCurrencyCode	IN	Varchar2,
		pErrorCode 	IN 	Varchar2 default  null,
		pErrorMessage  	IN 	Varchar2 default null )
IS
Begin

	IF (l_debug = 'Y') THEN
   	printDebugLog('updateLog(+)');
           printDebugLog(fnd_global.tab||'IN Parameters: '||to_char(pMvlogid)||', '||pStatus||', '||to_char(pLogTime,'YYYY-MM-DD HH24:MI:SS')||', '||pCurrencyCode||', '||pErrorCode||', '||pErrorMessage);
	END IF;

       Update IBE_ECR_MVLOG
	   Set Refresh_Status = pStatus,
	   Refresh_Duration = ((pLogTime- Creation_Date)*24*60*60),
	   Currency_Code = pCurrencyCode,
	   Error_Code = pErrorCode,
           Error_Message = pErrorMessage
	   Where MvLog_id = pMvlogid;

	IF (l_debug = 'Y') THEN
   	printDebugLog('updateLog(-)');
	END IF;

End updateLog;

PROCEDURE updateLog(pName     		IN        Varchar2,
		pMode             	IN        Varchar2,
		pFromStatus 		IN        Number,
            	pToStatus 		IN        Number,
	    	pErrorCode 		IN 	Varchar2 default  null,
	    	pErrorMessage  		IN 	Varchar2 default null )
IS
BEGIN

	IF (l_debug = 'Y') THEN
   	printDebugLog('updateLog(+)');
           printDebugLog(fnd_global.tab||'IN Parameters: '||pName||', '||pMode||', '||to_char(pFromStatus)||', '||to_char(pToStatus)||', '||pErrorCode||', '||pErrorMessage );
	END IF;

	Update 	IBE_ECR_MVLOG
	Set 	Refresh_Status 	= 	pToStatus,
		Error_Code = nvl(pErrorCode,Error_Code),
	        Error_Message = nvl(pErrorMessage,Error_Message)
	Where 	Refresh_Status 	= 	pFromStatus
	And   	Mview_Name 	= 	pName
	And     Refresh_Mode = pMode;

	IF (l_debug = 'Y') THEN
   	printDebugLog('updateLog(-)');
	END IF;
End   updateLog;

PROCEDURE makeLogEntry(pMviewName 	IN Varchar2,
            		pMode       IN Varchar2,
            		pStatus     IN Number,
			pBeginDate 	IN Date,
			pEndDate 	IN Date,
            		pLogTime 	IN Date,
			pErrorCode 	IN Varchar2 default  null,
			pErrorMessage  	IN Varchar2 default null,
            		pLogId      OUT NOCOPY Number) IS

  l_refreshStatus   Number :=0;

  BEGIN
	IF (l_debug = 'Y') THEN
   	printDebugLog('makeLogEntry(+)');
           printDebugLog(fnd_global.tab||'IN Parameters: '||pMviewName||', '||pMode||', '||pStatus||',
	'||to_char(pBeginDate,'YYYY-MM-DD  HH24:MI:SS')||', '||to_char(pEndDate,'YYYY-MM-DD HH24:MI:SS')||',
	'||to_char(pLogTime,'YYYY-MM-DD HH24:MI:SS')||', '||pErrorCode||', '||pErrorMessage );

	END IF;

-- Make New Entry.
     	Insert into  IBE_ECR_MVLOG
		(mvlog_id,object_version_number,Created_by,Creation_Date,
		last_updated_by,last_update_date,last_update_login,
		Program_application_id,Request_id,Program_id,Program_update_Date,Refresh_Mode,
                mview_Name, Refresh_Status, Begin_Date, End_Date,Fact_Source,Error_Code, Error_Message,Refresh_Duration,
		CONVERSION_TYPE, DAY_BIN_OFFSET,FORCE_REFRESH_FLAG, QUARTER_BEGIN_FLAG, PERIOD_SET_NAME)
                Values (ibe_ecr_mvlog_s1.nextval,0,
                                FND_GLOBAL.user_id,pLogTime,
                                FND_GLOBAL.user_id,sysdate,
                                FND_GLOBAL.Conc_Login_ID,
                                fnd_global.prog_appl_id, fnd_global.conc_request_id,
				fnd_global.conc_program_id,Sysdate,pmode,
                                pMviewName, pStatus, pBeginDate, pEndDate,
				g_data_source, pErrorCode, pErrorMessage,0,
				g_ConversionType, g_dayoffset, g_ForceRefreshFlag, g_QuarterBeginFlag, g_periodSetName)
				RETURNING mvlog_id into  plogid;

        IF (l_debug = 'Y') THEN
           printDebugLog(fnd_global.tab||'IN Parameters: '||to_char(plogid));
   	printDebugLog('makeLogEntry(-)');
        END IF;
   EXCEPTION
          When Others Then
             printOutput(getMessage('IBE','IBE_ECR_MVLOG_ERROR',pMviewName));
             Raise;
END makeLogEntry;


PROCEDURE  dropIndex( pMode IN Varchar2, pOwner IN Varchar2,pName IN Varchar2) IS

  CURSOR dr_obj(p_owner varchar2,p_name varchar2) is
          Select owner,index_name
          From all_indexes
          Where table_owner = p_owner
          And 	table_name = p_name;
Begin
	IF (l_debug = 'Y') THEN
   	printDebugLog('dropIndex(+)');
           printDebugLog(fnd_global.tab||'IN Parameters: '||pMode||', '||pOwner||', '||pName);
	END IF;

	If pMode = 'COMPLETE' Then
	  for chg_tbl in dr_obj(pOwner,pName) loop
	    EXECUTE IMMEDIATE 'drop index '||chg_tbl.owner||'.'||chg_tbl.index_name;
	  end loop;
	End If;

	IF (l_debug = 'Y') THEN
   	printDebugLog('dropIndex(-)');
	END IF;
END dropIndex;


PROCEDURE  createIndex( pMode IN Varchar2, pName IN Varchar2) IS

  l_idx_High_space_clause Varchar2(2000);
  l_idx_Low_space_clause Varchar2(2000);
  l_addOption Varchar2(100);

Begin

	IF (l_debug = 'Y') THEN
   	printDebugLog('createIndex(+)');
           printDebugLog(fnd_global.tab||'IN Parameters: '||pMode||', '||pName);
	END IF;


	If pMode = 'COMPLETE' Then

            l_addOption := '';

          If g_ParallelFlag = 'Y' Then
            l_addOption := ' parallel';
          End If;

         /*
         l_idx_High_space_clause := ' storage (initial 10M next 10M pctincrease 0) tablespace '||g_idx_tablespace||'  pctfree 0'||l_addOption;
         l_idx_Low_space_clause := ' storage (initial 50K next 50K pctincrease 0) tablespace '||g_idx_tablespace||'  pctfree 0'||l_addOption;
         */


         l_idx_High_space_clause := ' tablespace '||g_idx_tablespace||' '||l_addOption;
         l_idx_Low_space_clause :=  ' tablespace '||g_idx_tablespace||' '||l_addOption;


	   If pName = 'IBE_ECR_ORDER_HEADERS_FACT' Then

	     	EXECUTE IMMEDIATE 'Create  index IBE_ECR_ORDER_HEADERS_FACT_N1 on IBE_ECR_ORDER_HEADERS_FACT(FACT_DATE) '||l_idx_High_space_clause;

	     	EXECUTE IMMEDIATE 'Create  index IBE_ECR_ORDER_HEADERS_FACT_N2 on IBE_ECR_ORDER_HEADERS_FACT(FACT_DATE,INVOICE_TO_ORG_ID)'||l_idx_High_space_clause;

	     	EXECUTE IMMEDIATE 'Create UNIQUE index IBE_ECR_ORDER_HEADERS_FACT_U1 on IBE_ECR_ORDER_HEADERS_FACT(HEADER_ID) '||l_idx_High_space_clause;
           ElsIf pName = 'IBE_ECR_ORDERS_FACT' Then

		EXECUTE IMMEDIATE 'Create  index IBE_ECR_ORDERS_FACT_N1 on IBE_ECR_ORDERS_FACT(ORGANIZATION_ID,INVENTORY_ITEM_ID) '||l_idx_High_space_clause;
		EXECUTE IMMEDIATE 'Create  index IBE_ECR_ORDERS_FACT_N2 on IBE_ECR_ORDERS_FACT(ORG_ID)'||l_idx_High_space_clause;
		EXECUTE IMMEDIATE 'Create  index IBE_ECR_ORDERS_FACT_N3 on IBE_ECR_ORDERS_FACT(FACT_DATE)'||l_idx_High_space_clause;

                /* **** Bug# 4550680  Begin
                           Removing the code for IBE_ECR_BIN_FACT table.
                           Reason: From R12 release, we are decommissioning the iStore Merchant UI reports.
                           So, IBE_ECR_BIN_FACT table is not required.
                   **** Bug# 4550680  End *****   */


           ElsIf pName = 'IBE_ECR_QUOTES_FACT' Then

		EXECUTE IMMEDIATE 'Create  index IBE_ECR_QUOTES_FACT_N1 on IBE_ECR_QUOTES_FACT(ORGANIZATION_ID,INVENTORY_ITEM_ID)'||l_idx_High_space_clause;
		EXECUTE IMMEDIATE 'Create  index IBE_ECR_QUOTES_FACT_N2 on IBE_ECR_QUOTES_FACT(ORG_ID)'||l_idx_High_space_clause;
		EXECUTE IMMEDIATE 'Create  index IBE_ECR_QUOTES_FACT_N3 on IBE_ECR_QUOTES_FACT(CUST_ACCOUNT_ID)'||l_idx_High_space_clause;

	   End If;

	End If;


	IF (l_debug = 'Y') THEN
   	printDebugLog('createIndex(-)');
	END IF;
END createIndex;

PROCEDURE  setSessionParallel( pFlag IN Varchar2) IS
 Begin
  IF (l_debug = 'Y') THEN
     printDebugLog('setSessionParallel(+)');
     printDebugLog(fnd_global.tab||'IN Parameters: '||pFlag);
  END IF;

  If pFlag = 'Y' Then

    EXECUTE IMMEDIATE ' alter session enable parallel dml';
    EXECUTE IMMEDIATE ' alter session enable parallel query';

  End If;

 IF (l_debug = 'Y') THEN
    printDebugLog('setSessionParallel(-)');
 END IF;
End setSessionParallel;

PROCEDURE  resetSessionParallel( pFlag IN Varchar2) IS
 Begin
  IF (l_debug = 'Y') THEN
     printDebugLog('resetSessionParallel(+)');
     printDebugLog(fnd_global.tab||'IN Parameters: '||pFlag);
  END IF;

  If pFlag = 'Y' Then
    EXECUTE IMMEDIATE ' alter session disable parallel dml';
    EXECUTE IMMEDIATE ' alter session disable parallel query';
  End If;

 IF (l_debug = 'Y') THEN
    printDebugLog('resetSessionParallel(-)');
 END IF;
End resetSessionParallel;



PROCEDURE  setTableParallel( pFlag IN Varchar2, pOwner IN Varchar2, pName IN Varchar2) IS
l_addOption Varchar2(100) := null;
Begin

	IF (l_debug = 'Y') THEN
   	printDebugLog('setTableParallel(+)');
           printDebugLog(fnd_global.tab||'IN Parameters: '||pFlag||', '||pOwner||', '||pName);
	END IF;

	If pFlag = 'Y' or pFlag is NULL Then
            l_addOption := 'Parallel';
            EXECUTE IMMEDIATE 'Alter table '||pOwner||'.'||pName||' '||l_addOption;
      End If;


	IF (l_debug = 'Y') THEN
   	printDebugLog('setTableParallel(-)');
	END IF;
End setTableParallel;


PROCEDURE  resetTableParallel( pFlag IN Varchar2, pOwner IN Varchar2, pName IN Varchar2) IS
Begin

	IF (l_debug = 'Y') THEN
   	printDebugLog('resetTableParallel(+)');
           printDebugLog(fnd_global.tab||'IN Parameters: '||pFlag||', '||pOwner||', '||pName);
	END IF;

	If pFlag = 'Y' Then
		EXECUTE IMMEDIATE 'Alter table '||pOwner||'.'||pName||' noparallel ';
        End If;
	IF (l_debug = 'Y') THEN
   	printDebugLog('resetTableParallel(-)');
	END IF;

End resetTableParallel;


PROCEDURE  removeFactData( pMode IN Varchar2, pName IN Varchar2, pFromDate IN Date, pToDate IN Date) IS

  l_application_short_name  varchar2(300) ;
  l_status_AppInfo          varchar2(300) ;
  l_industry_AppInfo        varchar2(300) ;
  l_oracle_schema_AppInfo   varchar2(300) ;
BEGIN
	IF (l_debug = 'Y') THEN
   	printDebugLog('removeFactData(+)');
           printDebugLog(fnd_global.tab||'IN Parameters: '||pMode||', '||pNAME||', '||to_char(pFromDate,'YYYY-MM-DD HH24:MI:SS')||', '||to_char(pToDate,'YYYY-MM-DD HH24:MI:SS') );
	END IF;

	If pMode = 'COMPLETE' Then

		If g_TruncateFlag = 'Y' Then
		      select application_short_name
                into l_application_short_name
                from fnd_application
                where application_id = 671;
                IF (fnd_installation.get_app_info(l_application_short_name,
  			                                   l_status_AppInfo          ,
  			                                   l_industry_AppInfo        ,
  			                                   l_oracle_schema_AppInfo   )) then
			   EXECUTE IMMEDIATE 'TRUNCATE TABLE '|| l_oracle_schema_AppInfo|| '.'||pName;
			ELSE
			   EXECUTE IMMEDIATE 'Delete From '||pName;
               END IF;

          Else
			EXECUTE IMMEDIATE 'Delete From '||pName;

		End If;

	Else

                If pName = 'IBE_ECR_QUOTES_FACT' Then

			Delete from IBE_ECR_QUOTES_FACT where quote_date between pFromDate and pToDate;

		Else

	                EXECUTE IMMEDIATE 'Delete From '||pName||' Where fact_date between :1 and :2'
			USING pFromDate,pToDate;

		End IF;


        End If;

	IF (l_debug = 'Y') THEN
   	printDebugLog('removeFactData(-)');
	END IF;
END  removeFactData;

Procedure getFrequencyDate(pDate IN Date, pFrequency IN Varchar2, pPeriodSetName IN varchar2,pdayoffset IN Number, pStartDate OUT NOCOPY Date, pEndDate OUT NOCOPY Date) IS

 l_StartDay  Number := 1; -- week starts on Sunday

 Cursor c_PeriodDate(p_periodSetName Varchar2,p_periodType varchar2,p_date date) Is
  Select Start_Date,End_Date
  From   GL_Periods
  Where  period_set_name = p_periodsetname
  and    period_type = p_periodType
  and    adjustment_period_flag = 'N'
  and    p_Date between Start_date and End_date;

Begin

         pStartDate := NULL;
         pEndDate   := NULL;

  If pFrequency = 'DAY' Then
         pStartDate := trunc(pDate - pdayoffset);
         pEndDate   := pDate;
  ElsIf pFrequency = 'WEEK' Then

         Select  trunc(NEXT_DAY(pDate-7,l_StartDay))
         into pStartDate
         From Dual;

         -- pStartDate := trunc(NEXT_DAY(pDate-7,l_StartDay));
         pEndDate   := pDate;
  ElsIf pFrequency = 'ROLLING13WK' Then

         Select  trunc(NEXT_DAY(pDate-7*14,l_StartDay))
         into pStartDate
         From Dual;

	    pEndDate   := pDate;

  ElsIf pFrequency = 'MONTH' Then
       For rec_period In c_periodDate(pPeriodSetName,'Month',Trunc(pDate)) Loop
         pStartDate :=  rec_period.start_date;
         pEndDate   :=  pDate;
       End Loop;
  ElsIf pFrequency = 'QUARTER' Then
         For rec_period In c_periodDate(pPeriodSetName,'Quarter',Trunc(pDate)) Loop
          pStartDate :=  rec_period.start_date;
          pEndDate   :=  pDate;
         End Loop;
  ElsIf pFrequency = 'YEAR' Then
         For rec_period In c_periodDate(pPeriodSetName,'Year',Trunc(pDate)) Loop
          pStartDate :=  rec_period.start_date;
          pEndDate   :=  pDate;
         End Loop;
  End If;


   If (pStartDate is null and pEndDate is null) Then
	    FND_MESSAGE.Set_Name('IBE','IBE_ECR_CALENDER_ERROR');
            FND_MESSAGE.Set_Token('NAME',InitCap(pFrequency));
            FND_MESSAGE.Set_Token('PERIODSETNAME',nvl(pPeriodSetName,'???'));
            FND_MESSAGE.Set_Token('DATE',to_char(pdate));
            Raise_application_error(-20201, FND_MESSAGE.get);
   End If;

End getFrequencyDate;



Procedure getTransactionSource(pSourceName IN Varchar2,pSourceValue OUT NOCOPY Varchar2,pSourceMeaning OUT NOCOPY Varchar2) IS
 l_data_sources  Varchar2(2000);
 l_Meaning	 Varchar2(4000);

Begin
	IF (l_debug = 'Y') THEN
   	printDebugLog('getTransactionSource(+)');
	END IF;
	For rec_lookup IN c_lookup(pSourceName) Loop
	    l_data_sources :=  l_data_sources||' ,'||''''||InitCap(rec_lookup.lookup_Code)||'''';
            l_Meaning      :=  l_Meaning||', '||rec_lookup.meaning;
        End Loop;

	pSourceValue   := substr(trim(l_data_sources),2,length(trim(l_data_sources)));
        pSourceMeaning := substr(trim(l_Meaning),2,length(trim(l_Meaning)));
	IF (l_debug = 'Y') THEN
   	printDebugLog('getTransactionSource(-)');
	END IF;

End getTransactionSource;


Procedure getBinMaxRows(pRows OUT NOCOPY NUMBER) IS
	l_type Varchar2(30) := 'IBE_BIN_NUM_ROW';
Begin
	IF (l_debug = 'Y') THEN
   	printDebugLog('getBinMaxRows(+)');
   	printDebugLog(fnd_global.tab||'IN Parameters: None');
	END IF;

	Select nvl(max(to_number(lookup_code)),20) into pRows
	From fnd_lookups
	Where lookup_type = l_type;

	IF (l_debug = 'Y') THEN
   	printDebugLog(fnd_global.tab||'OUT Parameters: '||to_char(pRows));
   	printDebugLog('getBinMaxRows(-)');
	END IF;

End getBinMaxRows;


PROCEDURE getProfileValues IS

BEGIN

        IF (l_debug = 'Y') THEN
           printDebugLog('getProfileValues(+)');
           printDebugLog(fnd_global.tab||'No IN Parameters');
        END IF;

  	  g_conversionType 	:= 	fnd_profile.Value_Specific('IBE_GL_CONVERSION_TYPE',null,null,671);

	  If g_conversionType is null Then
           g_setupErrorCount := g_setupErrorCount + 1;
	  End If;

	  g_currencyCode 		:=     	fnd_profile.Value_Specific('IBE_CURRENCY_CODE',null,null,671);


	  If g_currencyCode is null Then
         g_setupErrorCount := g_setupErrorCount + 1;
      End If;

        g_PeriodSetName  	:= 	fnd_profile.Value_Specific('IBE_ECR_PERIOD_SET_NAME',null,null,671);

	  If g_PeriodSetName   is null Then
          g_setupErrorCount := g_setupErrorCount + 1;
	  End If;

 	  g_ForceRefreshFlag   	:= 	nvl(fnd_profile.value_specific('IBE_ENABLE_FORCE_REFRESH',null,null,671),'Y');
	  g_parallelFlag  	:=   	nvl(fnd_profile.value_specific('IBE_ENABLE_PARALLEL_PROCESSING',null,null,671),'N');
	  g_QuarterBeginFlag	:= 	nvl(fnd_profile.Value_Specific('IBE_ECR_QUARTER_BEGIN_DATA',null,null,671),'Y');
	  g_YearlyDataFlag      := 	nvl(fnd_profile.Value_Specific('IBE_ECR_YEARLY_DATA',null,null,671),'Y');
	  g_TruncateFlag	 	:= 	nvl(fnd_profile.Value_Specific('IBE_TRUNC_RECORDS',null,null,671),'Y');

        IF (l_debug = 'Y') THEN
           printDebugLog(fnd_global.tab||'No OUT Parameters');
           printDebugLog('getProfileValues(-)');
        END IF;

End getProfileValues;


PROCEDURE getPeriodDate(pMode IN Varchar2,pfactName IN varchar2,pBeginDate IN Varchar2,pEndDate IN Varchar2,
                        pFromDate OUT NOCOPY Date,pToDate OUT NOCOPY Date) IS

l_endDate Date;

BEGIN

      IF (l_debug = 'Y') THEN
         printDebugLog('getPeriodDate(+)');
     	printDebugLog(fnd_global.tab||'IN Parameters: '||pMode||', '||pfactName||', '||pBeginDate||', '||pEndDate);
      END IF;

	If pMode = 'COMPLETE' Then

               If g_YearlyDataFlag = 'Y' Then

                   getFrequencyDate(sysdate,'YEAR',g_PeriodSetName, g_dayoffset, pFromDate,l_endDate);

               ElsIf g_QuarterBeginFlag = 'Y' Then

                   getFrequencyDate(sysdate,'QUARTER',g_PeriodSetName,g_dayoffset,pFromDate,l_endDate);

		   Else

		       pFromDate 	:= 	trunc(g_refreshSysDate);

	         End If;

               If ((pBeginDate is not null) and (pFromDate >  trunc(to_date(pBeginDate,'YYYY/MM/DD HH24:MI:SS')))) Then
                    pFromDate 		:= 	trunc(to_date(pBeginDate,'YYYY/MM/DD HH24:MI:SS'));
               End If;

       ElsIf pMode = 'INCREMENT' Then

 			  Select min(End_Date) Into pFromDate
		       	  From   ibe_ecr_mvlog
			  Where  refresh_mode = pMode
		          And    mview_name  = pfactName
		          And    refresh_status  = 1;

			  If pFromDate is null Then

			   	Select min(Begin_Date) Into pFromDate
		       	  	From   ibe_ecr_mvlog
				Where  refresh_mode = pMode
		          	And    mview_name   = pfactName
		          	And    refresh_status  = -1;

			       If pFromDate is null Then

			  	  Begin
			   	   Select End_Date Into pFromDate
                           From   ibe_ecr_mvlog
			   	   Where  refresh_mode = 'COMPLETE'
		           	   And    mview_name  = pfactName
		           	   And    refresh_status  = 1;
               		          Exception
                           When NO_DATA_FOUND Then
			   	    printOutput(getMessage('IBE','IBE_ECR_COMPLETE_FIRST'));
			   	    Raise;
			  	  End;

			       End If;

			    End If;

                      pFromDate  := Trunc(pFromDate);

        End If;


	If pEndDate is null Then

	    	pToDate 	:= 	g_refreshSysDate;

	Else
		pToDate 	:= 	to_date(pEndDate, 'YYYY/MM/DD HH24:MI:SS');

	End If;



	IF (l_debug = 'Y') THEN
   	printDebugLog(fnd_global.tab||'OUT  Parameters: '||to_char(pFromDate,'YYYY/MM/DD HH24:MI:SS')||', '||to_char(pToDate,'YYYY/MM/DD HH24:MI:SS'));
         printDebugLog('getPeriodDate(-)');
	END IF;
END getPeriodDate;

PROCEDURE CheckRatesAvailable(pMode in Varchar2, pFactName in Varchar2, pFromDate in Varchar2,
                              pToDate in Varchar2, pAmount in Number, missingCount out nocopy number) IS
CURSOR RateExistCheckRecs (l_start_date Date, l_end_date Date)
is
  SELECT DISTINCT Transactional_Curr_Code,
                  Ordered_date
  FROM (
    SELECT  DISTINCT
    OH.Transactional_Curr_Code,
    trunc(oh.ordered_date) ordered_date
    FROM
	Oe_order_Sources OS,
    oe_order_headers_all oh,
    fnd_lookups fndlkp
    WHERE
    nvl(oh.booked_flag,'N')    =  'Y'
    AND     nvl(oh.cancelled_flag,'N') =  'N'
    AND     fndlkp.lookup_type =  'IBE_ECR_ORDER_SOURCE'
    AND     fndlkp.lookup_code = upper(OS.Name)
    AND     OH.Source_Document_Type_ID = OS.order_source_id
    AND     oh.booked_date BETWEEN l_start_date AND l_end_date
    UNION ALL
    SELECT DISTINCT
      a.currency_code Transactional_Curr_Code,
      to_date(pToDate,'yyyy/mm/dd hh24:mi:ss') ordered_date
    FROM
    aso_quote_headers_all a,
    fnd_lookups fndlkp
    WHERE
    a.quote_header_id = (SELECT max(quote_header_id) quote_header_id
                          FROM   aso_quote_headers_all
                          WHERE  quote_number = a.quote_number)
    AND ( (
             fndlkp.lookup_code = upper(a.quote_source_code)
             AND a.resource_id IS NULL  )
	  OR   a.resource_id IS NOT NULL)
    AND fndlkp.lookup_type =  'IBE_ECR_ORDER_SOURCE'
    AND a.order_id IS NULL
    AND a.creation_date BETWEEN l_start_date and l_end_date
    AND a.total_quote_price <= pAmount
  );

  l_rateexist Char(1);
  l_factStartDate 	Date;
  l_factEndDate 		Date;

  begin

   missingCount := 0;
   getPeriodDate(pMode,pFactName, pFromDate, pToDate,l_factStartDate, l_factEndDate);

   for RateRec in RateExistCheckRecs (l_factStartDate, l_factEndDate )
   loop
   l_rateexist := gl_currency_api.rate_exists(
                      RateRec.Transactional_Curr_Code,
                      g_CurrencyCode,
                      RateRec.ordered_date,
                      g_ConversionType);

   if l_rateexist = 'N' then
      missingCount := missingCount + 1;
   if missingCount = 1 then
      FND_FILE.PUT_LINE(FND_FILE.LOG,getMessage('IBE','IBE_ECR_RATES_MISSING_ERR'));
      FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
      FND_FILE.PUT_LINE(FND_FILE.LOG,getMessage('IBE','IBE_ECR_RATES_MISSING_HEADER'));
      FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
      FND_FILE.PUT_LINE(FND_FILE.LOG,rpad(getMessage('IBE','IBE_ECR_FROM_CURRENCY'),17,' ')||
                                     rpad(getMessage('IBE','IBE_ECR_TO_CURRENCY'),17,' ')||
    			             rpad(getMessage('IBE','IBE_PRMT_DATE_G'),17)||
				     getMessage('IBE','IBE_ECR_CONVERSION_TYPE'));
   end if;
   FND_FILE.PUT_LINE(FND_FILE.LOG,rpad(RateRec.Transactional_Curr_Code,17,' ')||
                                    rpad(g_CurrencyCode,17,' ')||
				    rpad(RateRec.ordered_date,17,' ')||
				    g_ConversionType);
   if missingCount =  g_error_threshhold then
     exit;
   end if;
  end if;
  end loop ;

  end checkRatesAvailable;


PROCEDURE getFactDataPeriod(pMode IN VARCHAR2,pfactName IN Varchar2,pStatus IN Number,
			    pStartDate Out NOCOPY Date,pEndDate OUT NOCOPY Date)  IS
BEGIN
	IF (l_debug = 'Y') THEN
   	printDebugLog('getFactDataPeriod(+)');
   	printDebugLog(fnd_global.tab||'IN Parameters: '||pMode||', '||pfactName||', '||to_char(pStatus));
	END IF;


           Select Begin_Date, End_Date
           Into   pStartDate, pEndDate
           From   IBE_ECR_MVLOG
           Where  Refresh_Status = pStatus
           And    Mview_Name = pFactname
           And    Refresh_Mode = pMode;
	IF (l_debug = 'Y') THEN
   	printDebugLog(fnd_global.tab||'OUT Parameters: '||to_char(pStartDate,'YYYY/MM/DD')||', '||to_char(pEndDate,'YYYY/MM/DD'));
   	printDebugLog('getFactDataPeriod(-)');
	END IF;
END getFactDataPeriod;

PROCEDURE  insertOrderHeaderFact( p_currency_code IN Varchar2, pFromDate IN Date, pToDate IN Date) IS
	l_booked_flag  varchar2(1) := 'Y';
	l_cancelled_flag  varchar2(1) := 'N';
	l_fact_source varchar2(240) :=  'IBE_ECR_ORDER_SOURCE';
BEGIN
	IF (l_debug = 'Y') THEN
   	printDebugLog('insertOrderHeaderFact(+)');
           printDebugLog(fnd_global.tab||'IN Parameters: '||p_currency_code||', '||to_char(pFromDate,'YYYY-MM-DD  HH24:MI:SS')||', '||to_char(pToDate,'YYYY-MM-DD HH24:MI:SS') );
	END IF;

   Insert /*+ append */  Into IBE_ECR_ORDER_HEADERS_FACT (fact_date, object_version_number, created_by,creation_date,
	last_updated_by, last_update_date, last_update_login, resource_id, org_id, currency_code, header_id, ordered_date,
	order_number,Transactional_Curr_Code,Conversion_Rate, sold_to_org_id, invoice_to_org_id, agreement_id, salesrep_id,
	functional_amount, reported_amount, customer_class_code, party_id ) 	SELECT Trunc(OH.booked_date) 		Fact_Date,
        	 	0	 			Object_Version_Number,
			FND_GLOBAL.user_id 		Created_By,
			sysdate 			Creation_Date,
			FND_GLOBAL.user_id 		Last_Updated_By,
			sysdate 			Last_Updation_Date,
			FND_GLOBAL.user_id 		Last_update_login,
                	null				Resource_id,
			oh.Org_id,
			p_currency_code			Currency_Code,
		        oh.Header_id 			Header_id,
		       	oh.Ordered_date,
		 	oh.Order_number,
			oh.Transactional_Curr_Code,
			oh.Conversion_Rate,
			OH.Sold_To_Org_ID,
			oh.Invoice_To_Org_ID,
			OH.Agreement_ID,
			OH.SalesRep_ID,
			Sum((decode(OL.line_category_code,'RETURN',-1,1)* nvl(OL.Pricing_Quantity,0))*
(nvl(OL.Unit_Selling_Price,0)*nvl(Oh.conversion_rate,1)))  Functional_Amount,
		              Sum((decode(OL.line_category_code,'RETURN',-1,1)* nvl(OL.Pricing_Quantity,0))*
gl_currency_api.convert_amount_sql(OH.Transactional_Curr_Code,p_currency_code,trunc(oh.ordered_date),
g_conversionType,nvl(OL.Unit_Selling_Price,0))) Reported_Amount,
      hca.customer_class_code, hca.party_id
		      FROM    Oe_order_Sources OS,
			      Oe_order_headers_all OH,
			      Oe_order_lines_all   OL,
	                      hz_cust_accounts hca,
  	                      hz_cust_site_uses_all hcsu,
                              hz_cust_acct_sites_all hcas,
			      fnd_lookups fndlkp
		      WHERE       fndlkp.lookup_type = l_fact_source
		            AND     fndlkp.lookup_code = upper(OS.Name)
		            AND     OH.Source_Document_Type_ID = OS.order_source_id
		            AND     OH.Header_id      = OL.Header_id
		            AND     nvl(OH.Booked_flag,'N')    =  l_booked_flag
			    AND     nvl(OH.cancelled_flag,'N') =  l_cancelled_flag
			    AND     OH.booked_date between pFromDate and pToDate
                            AND     oh.invoice_To_org_id = hcsu.site_use_id
                            AND     hcsu.cust_acct_site_id = hcas.cust_acct_site_id
                            AND     hcas.cust_account_id = hca.Cust_account_id
		        GROUP BY Trunc(OH.booked_date), OH.Org_ID,
			         oh.header_id, oh.ordered_date,
				 oh.order_number, oh.Transactional_Curr_Code,
				 oh.Conversion_Rate,OH.Invoice_To_Org_ID,
				 OH.Sold_To_Org_ID, OH.Agreement_ID, OH.SalesRep_ID,
				 hca.customer_class_code,hca.party_id;

	IF (l_debug = 'Y') THEN
   	printDebugLog('insertOrderHeaderFact(-)');
	END IF;
End insertOrderHeaderFact;

PROCEDURE  insertOrderLineFact( p_currency_code IN Varchar2, pFromDate IN Date, pToDate IN Date) IS
	l_booked_flag  varchar2(1) := 'Y';
	l_cancelled_flag  varchar2(1) := 'N';
	l_fact_source varchar2(240) :=  'IBE_ECR_ORDER_SOURCE';
BEGIN

	IF (l_debug = 'Y') THEN
   	printDebugLog('insertOrderLineFact(+)');
           printDebugLog(fnd_global.tab||'IN Parameters: '||p_currency_code||', '||to_char(pFromDate,'YYYY-MM-DD HH24:MI:SS')||', '||to_char(pToDate,'YYYY-MM-DD HH24:MI:SS') );
	END IF;
/* The following query returns only recordss for type STANDARD, SERVICE and other parent records. */
	Insert /*+ append */  into IBE_ECR_ORDERS_FACT (fact_date, object_version_number, created_by, creation_date,
 last_updated_by, last_update_date, last_update_login, resource_id, org_id, msite_id, currency_code, section_id,
organization_id, inventory_item_id, uom_code, sold_to_org_id, invoice_to_org_id, agreement_id, salesrep_id,
num_times_ordered, sale_quantity, functional_amount, reported_amount) SELECT  ift.fact_date	Fact_Date,
			0 			Object_Version_Number,
			FND_GLOBAL.user_id 	Created_By,
			sysdate 		Creation_Date,
			FND_GLOBAL.user_id 	Last_Updated_By,
			sysdate 		Last_Update_Date,
			FND_GLOBAL.user_id 	Last_update_login,
			null 			Resource_id,
			ift.Org_id,
			1 			MSite_id,
			p_currency_code 	Currency_Code,
			1 			Section_id,
			osp.Master_Organization_id ORGANIZATION_ID,
			ol.Inventory_Item_ID,
			ol.Pricing_quantity_uom UOM_Code,
			ol.Sold_To_Org_ID,
			ol.Invoice_To_Org_ID,
		        ift.Agreement_ID,
	              	ift.SalesRep_ID,
	              	Count(ift.order_number)  NUM_TIMES_ORDERED,
	              	Sum(decode(OL.line_category_code,'RETURN',-1,1)* nvl(OL.Pricing_Quantity,0)) AS Sale_Quantity,
                        return_functional_amount(ol.inventory_item_id,osp.Master_Organization_id,ift.header_id,ol.item_type_code,OL.line_category_code,
                        OL.ordered_Quantity,OL.Unit_Selling_Price,ift.conversion_rate)  Functional_Amount,
              		gl_currency_api.convert_amount_sql( ift.Transactional_Curr_Code,g_CurrencyCode ,
			trunc(ift.ordered_date),g_ConversionType,
			return_functional_amount(ol.inventory_item_id,osp.Master_Organization_id,ift.header_id,
			ol.item_type_code,OL.line_category_code,
                        OL.ordered_Quantity,OL.Unit_Selling_Price,ift.conversion_rate)     ) Reported_Amount
		FROM      IBE_ECR_ORDER_HEADERS_FACT ift,
	           	  OE_ORDER_LINES_ALL   OL,
	           	  OE_SYSTEM_PARAMETERS_ALL OSP
		WHERE   ift.Header_id      = OL.Header_id
            AND     ift.fact_date between pFromDate and pToDate
		AND     nvl(OL.cancelled_flag,'N') =  l_cancelled_flag
		AND    OL.link_to_line_id is NULL
            AND     OL.Org_ID         = OSP.Org_ID
				GROUP BY ift.fact_date, ift.Org_ID, OSP.Master_Organization_id,  OL.Inventory_Item_ID, OL.Pricing_quantity_uom, OL.Invoice_To_Org_ID, OL.Sold_To_Org_ID,ift.Agreement_ID,  ift.SalesRep_ID ,ift.header_id
                 ,ol.item_type_code,OL.line_category_code,OL.ordered_Quantity,OL.Unit_Selling_Price,ift.conversion_rate,
                 ift.Transactional_Curr_Code,ift.ordered_date;


	IF (l_debug = 'Y') THEN
   	printDebugLog('insertOrderLineFact(-)');
	END IF;
End insertOrderLineFact;


PROCEDURE  insertQuotesFact(pFromDate IN Date, pToDate IN Date) IS
  l_fact_source varchar2(240) :=  'IBE_ECR_ORDER_SOURCE';
BEGIN

	IF (l_debug = 'Y') THEN
   	printDebugLog('insertQuotesFact(+)');
           printDebugLog(fnd_global.tab||'IN Parameters: '||to_char(pFromDate,'YYYY-MM-DD  HH24:MI:SS')||', '||to_char(pToDate,'YYYY-MM-DD HH24:MI:SS') );
	END IF;

               Insert /*+ append  */ into IBE_ECR_QUOTES_FACT (quote_date, object_version_number, created_by, creation_date,
last_updated_by,  last_update_date, last_update_login, msite_id, org_id, currency_code, section_id, organization_id,
inventory_item_id, uom_code, cust_account_id, employee_person_id, added_to_cart_frequency, quote_quantity,
item_ordered_frequency, order_quantity)
                SELECT
	        Trunc(QH.Creation_Date) 	Quote_Date,
	        0 				Object_Version_Number,
		FND_GLOBAL.user_id 		Created_By,
		sysdate 			Creation_Date,
		FND_GLOBAL.user_id 		Last_Updated_By,
		sysdate 			Last_Updation_Date,
		FND_GLOBAL.user_id 		Last_update_login,
                1 Msite_ID,
                QH.Org_id,
                QH.Currency_Code,
                1 Section_ID,
                QL.ORGANIZATION_ID,
                QL.Inventory_item_id,
                QL.UOM_Code,
                QH.Cust_Account_ID,
                QH.Employee_Person_ID,
                Count(*) Added_To_Cart_Frequency,
                Sum(nvl(QL.Quantity,0)) AS Quote_Quantity,
        --        Count(decode(nvl(OH.Booked_Flag,'N'),'N',Null,QH.order_id)) Item_Ordered_Frequency,
                SUM(get_item_count(ql.inventory_item_id,nvl(oh.header_id,0))) Item_Ordered_Frequency,
                Sum(decode(nvl(OH.Booked_Flag,'N'),'N',0, nvl(QL.Quantity,0))) AS Order_Quantity
               FROM  Aso_quote_headers_all QH,
                     Aso_quote_lines_all QL,
                     OE_Order_Headers_ALL OH,
			   Fnd_lookups         fndlkp
		   WHERE  fndlkp.lookup_type = l_fact_source
               AND    upper(Qh.Quote_Source_Code) = fndlkp.lookup_code
               AND    QH.Creation_Date between pFromDate and pToDate
               AND    Qh.quote_header_id = Ql.quote_header_id
               and    ql.item_type_code <> 'CFG'
               AND    Qh.order_id = OH.Header_ID (+)
               AND    Qh.max_version_flag = 'Y'
               GROUP BY Trunc(QH.Creation_Date), QH.Org_id ,QH.Currency_Code,QL.ORGANIZATION_ID, QL.Inventory_item_id, QL.UOM_Code, QH.Currency_Code, QH.Cust_Account_ID,QH.Employee_Person_ID;

	IF (l_debug = 'Y') THEN
   	printDebugLog('insertQuotesFact(-)');
	END IF;
End insertQuotesFact;


PROCEDURE  insertBinTOPORD(pLookupCode IN Varchar2, pStartDate IN Date, pEndDate IN Date,pDataFromOM IN Boolean default FALSE) IS
Begin
        null;
/* **** Bug# 4550680  Begin
   Removing the code for IBE_ECR_BIN_FACT table.
   Reason: From R12 release, we are decommissioning the iStore Merchant UI reports.
   So, IBE_ECR_BIN_FACT table is not required.
 **** Bug# 4550680  End *****   */
End insertBinTOPORD;


PROCEDURE  insertBinTOPORD(pCurrencyCode IN Varchar2, pLookupCode IN Varchar2, pStartDate IN Date, pEndDate IN Date) IS

Begin
null;
/* **** Bug# 4550680  Begin
   Removing the code for IBE_ECR_BIN_FACT table.
   Reason: From R12 release, we are decommissioning the iStore Merchant UI reports.
   So, IBE_ECR_BIN_FACT table is not required.
 **** Bug# 4550680  End *****   */

End insertBinTOPORD;


PROCEDURE  insertBinTOPPRD(pLookupCode IN Varchar2, pStartDate IN Date, pEndDate IN Date, pDataFromOM IN Boolean default FALSE) IS
Begin
null;
/* **** Bug# 4550680  Begin
   Removing the code for IBE_ECR_BIN_FACT table.
   Reason: From R12 release, we are decommissioning the iStore Merchant UI reports.
   So, IBE_ECR_BIN_FACT table is not required.
 **** Bug# 4550680  End *****   */

End insertBinTOPPRD;

PROCEDURE  insertBinTOPPRD(pCurrencyCode IN Varchar2,pLookupCode IN Varchar2, pStartDate IN Date, pEndDate IN Date) IS
Begin
null;
/* **** Bug# 4550680  Begin
   Removing the code for IBE_ECR_BIN_FACT table.
   Reason: From R12 release, we are decommissioning the iStore Merchant UI reports.
   So, IBE_ECR_BIN_FACT table is not required.
 **** Bug# 4550680  End *****   */
End insertBinTOPPRD;


PROCEDURE  insertBinTOPCUST(pLookupCode IN Varchar2, pStartDate IN Date, pEndDate IN Date,pDataFromOM IN Boolean default FALSE) IS

Begin
null;
/* **** Bug# 4550680  Begin
   Removing the code for IBE_ECR_BIN_FACT table.
   Reason: From R12 release, we are decommissioning the iStore Merchant UI reports.
   So, IBE_ECR_BIN_FACT table is not required.
 **** Bug# 4550680  End *****   */

End insertBinTOPCUST;


PROCEDURE  insertBinTOPCUST(pCurrencyCode IN Varchar2,pLookupCode IN Varchar2, pStartDate IN Date, pEndDate IN Date) IS

Begin
null;
/* **** Bug# 4550680  Begin
   Removing the code for IBE_ECR_BIN_FACT table.
   Reason: From R12 release, we are decommissioning the iStore Merchant UI reports.
   So, IBE_ECR_BIN_FACT table is not required.
 **** Bug# 4550680  End *****   */
End insertBinTOPCUST;

PROCEDURE  insertBinSUMM(pLookupCode IN Varchar2, pStartDate IN Date, pEndDate IN Date,pDataFromOM IN Boolean default FALSE) IS

Begin
null;
/* **** Bug# 4550680  Begin
   Removing the code for IBE_ECR_BIN_FACT table.
   Reason: From R12 release, we are decommissioning the iStore Merchant UI reports.
   So, IBE_ECR_BIN_FACT table is not required.
 **** Bug# 4550680  End *****   */
End insertBinSUMM;


PROCEDURE  insertBinSUMM(pCurrencyCode IN Varchar2,pLookupCode IN Varchar2, pStartDate IN Date, pEndDate IN Date) IS

Begin
null;
/* **** Bug# 4550680  Begin
   Removing the code for IBE_ECR_BIN_FACT table.
   Reason: From R12 release, we are decommissioning the iStore Merchant UI reports.
   So, IBE_ECR_BIN_FACT table is not required.
 **** Bug# 4550680  End *****   */
End insertBinSUMM;



PROCEDURE  insertBinSUMMCart(pLookupCode IN Varchar2, pStartDate IN Date, pEndDate IN Date)
IS
Begin
null;
/* **** Bug# 4550680  Begin
   Removing the code for IBE_ECR_BIN_FACT table.
   Reason: From R12 release, we are decommissioning the iStore Merchant UI reports.
   So, IBE_ECR_BIN_FACT table is not required.
 **** Bug# 4550680  End *****   */
End insertBinSUMMCart;

PROCEDURE forceRefreshData(pForceRefreshFlag IN Varchar2,pMode IN Varchar2, pObjName IN Varchar2,pBeginDate IN Date,pEndDate IN Date,pForceRefreshStatus OUT NOCOPY Varchar2) IS

        l_begindate 	date;
        l_enddate  	date;
	l_mvlog_id	Number;
        l_mvlog_Status Number :=1;

     BEGIN
         IF (l_debug = 'Y') THEN
            printDebugLog('ForceRefreshData(+)');
            printDebugLog(fnd_global.tab||'IN Parameters: '||pForceRefreshFlag||', '||pMode||', '||pObjName||', '||pBeginDate||', '||pEndDate );
         END IF;

         -- Set Force Data Refresh to 'Yes' by default.

         pForceRefreshStatus := 'Y';

         If pForceRefreshFlag = 'N' Then

                  Begin

        	  Select Mvlog_id, Begin_Date, End_Date Into l_mvlog_id,l_begindate,l_enddate
	          From IBE_ECR_MVLOG
        	  Where Refresh_Status = l_mvlog_Status
	          And   Mview_Name = pObjName
	          And   Refresh_Mode = pMode;

                  If (l_begindate = pBeginDate And l_enddate = pendDate) Then

			pForceRefreshStatus := 'N';

		            Update IBE_ECR_MVLOG
		            Set Program_ID = fnd_global.conc_program_id,
		                Request_id = fnd_global.conc_request_id,
                		Program_update_Date = SysDate,
		                last_updated_by = FND_GLOBAL.USER_ID,
                		last_update_date = sysdate,
		                Program_application_id = fnd_global.prog_appl_id
		            Where mvlog_id = l_mvlog_id;

                   End if;

                  Exception
                   When Others Then
                     pForceRefreshStatus := 'Y';
                  End;
         End if;

         IF (l_debug = 'Y') THEN
            printDebugLog(fnd_global.tab||'OUT Parameters: '||pForceRefreshStatus);
            printDebugLog('ForceRefreshData(-)');
         END IF;
 END ForceRefreshData;




PROCEDURE  insertBinFact(pRefreshDate IN Date) IS
Begin
null;
/* **** Bug# 4550680  Begin
   Removing the code for IBE_ECR_BIN_FACT table.
   Reason: From R12 release, we are decommissioning the iStore Merchant UI reports.
   So, IBE_ECR_BIN_FACT table is not required.
 **** Bug# 4550680  End *****   */
END insertBinFact;


PROCEDURE  insertBinFact(pCurrencyCode IN Varchar2,pRefreshDate IN Date) IS
Begin
null;
/* **** Bug# 4550680  Begin
   Removing the code for IBE_ECR_BIN_FACT table.
   Reason: From R12 release, we are decommissioning the iStore Merchant UI reports.
   So, IBE_ECR_BIN_FACT table is not required.
 **** Bug# 4550680  End *****   */
END insertBinFact;


PROCEDURE  refreshFact(pMode IN Varchar2,pFactName IN Varchar2,pBeginDate IN Varchar2, pEndDate IN Varchar2) IS

	l_factStartDate 	Date;
	l_factEndDate 		Date;

	l_ForceRefreshStatus 	Varchar2(2);
        l_mvLogID		Number;
	l_factCurrencyCode	Varchar2(240);

Begin

	IF (l_debug = 'Y') THEN
   	printDebugLog('refreshFact(+)');
           printDebugLog(fnd_global.tab||'IN Parameters: '||pMode||', '||pBeginDate||', '||pEndDate);
	END IF;

	printOutput('+-----------------------------------------------------------------------------+');
	printOutput(getMessage('IBE','IBE_ECR_REFRESH_START',pfactName));

	getPeriodDate(pMode,pfactName, pBeginDate, pEndDate,l_factStartDate, l_factEndDate);

	 l_factCurrencyCode := g_CurrencyCode;

	 forceRefreshData(g_ForceRefreshFlag,pMode,pfactName,l_factStartDate,l_factEndDate, l_ForceRefreshStatus);

	 If l_ForceRefreshStatus = 'Y' Then

		 makeLogEntry(pfactName,pMode,0,l_factStartDate,l_factEndDate,Sysdate,null,null,l_mvLogID);

	         Begin

			 updateLog(pfactName,pMode,1,2,null,null);
			 updateLog(pfactName,pMode,-1,2,null,null);

		         If pMode = 'COMPLETE' Then
        		    updateLog(pfactName,'INCREMENT',1,2,null,null);
	        	    updateLog(pfactName,'INCREMENT',-1,2,null,null);
		         End If;

			   setTableParallel(g_parallelFlag,'IBE',pfactName);

		         removeFactData(pMode,pfactName,l_factStartDate,l_factEndDate);

		         dropIndex(pMode,'IBE',pfactName);

			 If pFactName = 'IBE_ECR_ORDER_HEADERS_FACT' Then

		 	   insertOrderHeaderFact(g_CurrencyCode,l_factStartDate,l_factEndDate);
                     Commit;

                     Delete From IBE_ECR_ORDER_HEADERS_FACT where functional_amount > g_maxamount_ceil;

			 ElsIf pFactName = 'IBE_ECR_ORDERS_FACT' Then

		         insertOrderLineFact(g_CurrencyCode,l_factStartDate, l_factEndDate);

			 ElsIf pFactName = 'IBE_ECR_QUOTES_FACT' Then

		         insertQuotesFact(l_factStartDate, l_factEndDate);
                       /* **** Bug# 4550680  Begin
                                  Removing the code for IBE_ECR_BIN_FACT table.
                                  Reason: From R12 release, we are decommissioning the iStore Merchant UI reports.
                                  So, IBE_ECR_BIN_FACT table is not required.
                          **** Bug# 4550680  End *****   */
			 End If;

		       createIndex(pMode,pfactName);

                   resetTableParallel(g_parallelFlag,'IBE',pfactName);

		 	 updateLog(l_mvLogID,1,sysdate,l_FactCurrencyCode,null,null);

			 Commit;

		 Exception
		 When Others Then
			updateLog(l_mvLogID,-1,sysdate,null,SQLCODE,SQLERRM);
			Raise;
	         End;
           End if;

		printOutput(getMessage('IBE','IBE_ECR_REFRESH_PERIOD',pfactName)||' '||to_char(l_factStartDate,'YYYY/MM/DD HH24:MI:SS')||' - '||to_char(l_factEndDate,'YYYY/MM/DD HH24:MI:SS'));

		printOutput(getMessage('IBE','IBE_ECR_REFRESH_SUCCESS',pfactName));
		printOutput('+-----------------------------------------------------------------------------+');

	      IF (l_debug = 'Y') THEN
   	      printDebugLog(fnd_global.tab||'OUT Parameters: None');
   		printDebugLog('refreshFact(-)');
	      END IF;
	 Exception
           When Others Then

	        IF (l_debug = 'Y') THEN
   	        printDebugLog('Exception: refershFact(-):'||SQLCODE);
	        END IF;
		printOutput(getMessage('IBE','IBE_ECR_REFRESH_ERROR',pfactName)||'-'||SQLERRM);
		printOutput('+-----------------------------------------------------------------------------+');
		Raise;
End refreshFact;



PROCEDURE refreshFactMain(errbuf OUT NOCOPY VARCHAR2,
                          retcode OUT NOCOPY NUMBER,
					 pMode IN varchar2,
					 pBeginDate IN varchar2,
					 pEndDate IN varchar2,
					 pDayOffset IN Number,
					 pDebugFlag IN Varchar2,
					 pRateCheckFlag IN Varchar2) IS
 l_Meaning	 Varchar2(4000);
 l_MissingCount  Number;

Begin

  l_debug_profile := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');
  if ( l_debug_profile = 'Y' OR pDebugFlag = 'Y') then
   l_debug := 'Y';
  else
   l_debug := 'N';
  end if;

  if (l_debug_profile = 'Y') then
	IBE_UTIL.ENABLE_DEBUG_NEW('N');
  else
     IBE_UTIL.DISABLE_DEBUG_NEW();
  end if;

        g_debugFlag := pDebugFlag;

        If pDebugFlag = 'Y' Then
          IBE_UTIL.Enable_Debug;
        End If;

	IF (l_debug = 'Y') THEN
   	printDebugLog('refreshFactMain(+)');
           printDebugLog(fnd_global.tab||'IN Parameters: '||pBeginDate||', '||pEndDate||', '||pMode||', '||pDayoffset);
	END IF;

	printOutput('+-----------------------------------------------------------------------------+');

        -- Setting up Global Variables

 	g_inputRefreshMode := pMode;

	g_setupErrorCount := 0;

      g_refreshSysDate := Sysdate;

	g_dayoffset := nvl(pDayOffset,0);

      getTableSpace('INDEX',g_idx_tablespace);

	getProfileValues();

	getBinMaxRows(g_maxRows);

	getTransactionSource('IBE_ECR_ORDER_SOURCE',g_data_source,l_Meaning);


       printOutput('+-----------------------------------------------------------------------------+');
       printParameterOut(pMode,pBeginDate,pEndDate,pDayOffset);
	 printOutput('+-----------------------------------------------------------------------------+');
       printProfileOut();
	 printOutput('+-----------------------------------------------------------------------------+');
	 printOrderSourceOut(l_Meaning);
       printOutput('+-----------------------------------------------------------------------------+');

        If pEndDate is null Then
   	   printBinFreqDateOut(g_refreshSysDate);
        Else
           printBinFreqDateOut(to_date(pEndDate, 'YYYY/MM/DD HH24:MI:SS'));
        End If;

        printOutput('+-----------------------------------------------------------------------------+');
        If (g_setupErrorCount > 0) Then

         raise_application_error(-20200,getMessage('IBE','IBE_ECR_SETUP_ERROR'));

        End If;

	if  pRateCheckFlag = 'Y' then
	  CheckRatesAvailable(pMode,'IBE_ECR_ORDER_HEADERS_FACT',pBeginDate, pEndDate,g_maxamount_ceil, l_MissingCount);

	  if l_MissingCount > 0 then
	    raise_application_error(-20205,getMessage('IBE','IBE_ECR_RATES_MISSING_ERR'));
	  end if;
	end if;

	setSessionParallel( g_parallelFlag);

        Update IBE_ECR_MVLOG Set Refresh_status = -1 Where Refresh_Status = 0;


	refreshFact(pMode,'IBE_ECR_ORDER_HEADERS_FACT',pBeginDate, pEndDate);
  	refreshFact(pMode,'IBE_ECR_ORDERS_FACT',pBeginDate, pEndDate);

 	/* **** Bug# 4550680  Begin
		   Removing the code for IBE_ECR_BIN_FACT table.
		   Reason: From R12 release, we are decommissioning the iStore Merchant UI reports.
                   So, IBE_ECR_BIN_FACT table is not required.
           **** Bug# 4550680  End *****   */
 	refreshFact(pMode,'IBE_ECR_QUOTES_FACT',pBeginDate, pEndDate);

 	IF (l_debug = 'Y') THEN
    	printDebugLog('refreshFactMain(-)');
 	END IF;
        commit;

	resetSessionParallel(g_parallelFlag);

  Exception
  When Others Then
	printOutput(SQLCODE||'-'||SQLERRM);
     	commit;
	resetSessionParallel( g_parallelFlag);
	retcode := 2;
	raise;
End refreshFactMain;


PROCEDURE  dropMview( pMode IN Varchar2, pOwner IN Varchar2,pName IN Varchar2) IS

   CURSOR dr_obj_mv(pOwner IN Varchar2,pName IN Varchar2)  is
    Select 'drop materialized view  '||owner||'.'||mview_name sqlstmt
    From    all_mviews
    Where   owner = pOwner
    And     mview_name = pName;
ddl_curs integer;
Begin
	IF (l_debug = 'Y') THEN
   	printDebugLog('dropMview(+)');
           printDebugLog(fnd_global.tab||'IN Parameters: '||pMode||', '||pOwner||', '||pName);
	END IF;

	If pMode = 'COMPLETE' Then
/*
	  for chg_tbl in dr_obj_mv(pOwner,pName) loop
	    EXECUTE IMMEDIATE chg_tbl.sqlstmt;
	  end loop;
*/

          ddl_curs := dbms_sql.open_cursor;
             for chg_tbl in dr_obj_mv(pOwner,pName) loop
               /* Parse implicitly executes the DDL statements */
               dbms_sql.parse(ddl_curs, chg_tbl.sqlstmt,dbms_sql.native) ;
             end loop;
             dbms_sql.close_cursor(ddl_curs);

	End If;
	IF (l_debug = 'Y') THEN
   	printDebugLog('dropMview(-)');
	END IF;
END dropMview;

Procedure registerMview(pOperation IN VARCHAR2, pMviewName IN Varchar2) IS

l_Stmt Varchar2(2000);

Begin
      IF (l_debug = 'Y') THEN
         printDebugLog('registerMview(+)');
         printDebugLog(fnd_global.tab||'IN Parameters: '||pOperation||', '||pMviewName);
      END IF;

       If pOperation = 'CREATE' Then

          l_Stmt := 'Create materialized view '||pMviewName||' on prebuilt table refresh complete on demand ENABLE query rewrite As ';

       ElsIf pOperation = 'INSERT' Then
          l_Stmt := 'insert /*+append */ into '||pMviewName||' ';
       End If;
                                       /* **** Bug# 4550680  Begin
                                                  Removing the code for IBE_ECR_BIN_FACT table.
                                                  Reason: From R12 release, we are decommissioning the iStore Merchant UI reports.
                                                  So, IBE_ECR_BIN_FACT table is not required.
                                         **** Bug# 4550680  End *****/


IF (l_debug = 'Y') THEN
   printDebugLog('registerMview(-)');
END IF;
End registerMview;

PROCEDURE IsFactDataAvailable(pMode IN Varchar2,pName IN Varchar2,pStatus OUT NOCOPY Varchar2,pBeginDate OUT NOCOPY Date,pEndDate OUT NOCOPY  Date,
pConversionType OUT NOCOPY Varchar2, pCurrencyCode OUT NOCOPY Varchar2, pFactSource OUT NOCOPY Varchar2, pDayOffset OUT NOCOPY Number, pForceRefresh OUT
NOCOPY Varchar2, pQuarterBegin OUT NOCOPY Varchar2, pPeriodSetName OUT NOCOPY Varchar2, pErrorMessage OUT NOCOPY Varchar2) IS
         l_mvlogStatus Number;
       BEGIN
         IF (l_debug = 'Y') THEN
            printDebugLog('IsFactDataAvailable(+)');
            printDebugLog(fnd_global.tab||'IN Parameters: '||pMode||', '||pName);
         END IF;

         l_mvlogStatus := 1; -- '1' indicates Successfull

         Select 'Y',Begin_Date,End_Date,Conversion_Type,Currency_code,Fact_Source,
	 day_bin_offset,Force_Refresh_Flag,Quarter_Begin_Flag,Period_Set_Name
         INTO pStatus,pBeginDate,pEndDate,pConversionType,pCurrencyCode,pFactSource,
	 pDayOffset, pForceRefresh, pQuarterBegin,pPeriodSetName
         From IBE_ECR_MVLOG
         WHERE 	MView_Name = pName
       	 ANd 	Refresh_Status = l_mvlogStatus
	 And    Refresh_Mode = pMode;


         IF (l_debug = 'Y') THEN
            printDebugLog(fnd_global.tab||'OUT Parameters: '||pStatus||', '||pBeginDate||', '||pEndDate||',
'||pConversionType||', '||pCurrencyCode||', '||pFactSource||', '||to_char(pDayOffset)||', '||pForceRefresh||',
'||pQuarterBegin||', '||pPeriodSetName);

         END IF;

         IF (l_debug = 'Y') THEN
            printDebugLog('IsFactDataAvailable(-)');
         END IF;

       EXCEPTION

        WHEN OTHERS THEN
         pStatus := 'N';
         pBeginDate := sysdate;
         pEndDate := sysdate;
	 pConversionType := null;
	 pCurrencyCode := null;
	 pFactSource := null;
	 pDayOffset := null;
	 pForceRefresh := null;
	 pQuarterBegin := null;
	 pPeriodSetName := null;

	 pErrorMessage := getMessage('IBE','IBE_ECR_NO_FACT_DATA',pName);

         printOutput(pErrorMessage);

         IF (l_debug = 'Y') THEN
            printDebugLog(fnd_global.tab||'OUT Parameters: '||pStatus||', '||pBeginDate||', '||pEndDate);
            printDebugLog('IsDataAvailable(-):'||SQLCODE);
         END IF;

END IsFactDataAvailable;

PROCEDURE  refreshMview(pMode IN Varchar2, pMViewName Varchar2,pFactName Varchar2) IS

         x_DataAvailable Varchar2(2);

         x_BeginDate Date;
         x_EndDate Date;

	 l_mvLogID Number;
         x_forceRefresh Varchar2(2)   := 'Y';
         x_NoFactMessage Varchar2(2000);

	 l_username  Varchar2(100);

         IBE_ECR_NO_FACT_DATA Exception;

         BEGIN
           IF (l_debug = 'Y') THEN
              printDebugLog('refershMView(+)');
              printDebugLog(fnd_global.tab||'IN Parameters: '||pMode||', '||pMViewName||', '||pFactName);
           END IF;

	   printOutput('+-----------------------------------------------------------------------------+');

           printOutput(getMessage('IBE','IBE_ECR_REFRESH_START',pMviewName));

           IsFactDataAvailable(pMode, pFactName, x_DataAvailable, x_begindate, x_enddate,g_conversionType, g_currencyCode,
		 g_data_source,g_dayoffset,g_ForceRefreshFlag,g_QuarterBeginFlag,g_periodSetName,x_NoFactMessage);

           If x_DataAvailable = 'Y' Then

             forceRefreshData(g_ForceRefreshFlag,'COMPLETE',pMViewName,x_BeginDate,x_EndDate,x_forceRefresh);

             If x_forceRefresh = 'Y' Then

		makeLogEntry(pMViewName,'COMPLETE',0,x_BeginDate,x_EndDate,Sysdate,null,null,l_mvLogID);

                Begin

		select user into l_username from dual;

		updateLog(pMViewName,'COMPLETE',1,2,null,null);
		updateLog(pMViewName,'COMPLETE',-1,2,null,null);

                  -- Complete Refresh
                  -- No Rollback Segment specified
                  -- Continue after errors
                  -- FALSE, 0,0,0 (only required by warehouse refresh as used  by replciation process
                  -- Atomic Refresh since refreshing just one mv at a time.
                  -- DBMS_MVIEW.REFRESH(pMViewName, 'A', '', TRUE, FALSE, 0,0,0, TRUE);

                 dropIndex('COMPLETE',l_username,pMViewName);
                 dropMview('COMPLETE',l_username,pMViewName);

                 EXECUTE IMMEDIATE 'TRUNCATE TABLE '||pMViewName||' drop storage';

                If g_refreshMV = 'Y' Then

		    setTableParallel(g_parallelFlag,l_username,pMViewName);
		    registerMview('INSERT',pMViewName);
		    Commit;
                    resetTableParallel(g_parallelFlag,l_username,pMViewName);
                    createIndex('COMPLETE', pMViewName);
                    registerMview('CREATE',pMViewName);

                End If;
		    updateLog(l_mvLogID,1,sysdate,g_currencyCode,null,null);

                Exception
                  WHEN OTHERS THEN
                   updateLog(l_mvLogID,-1,sysdate,null,SQLCODE,SQLERRM);
                  Raise;
                End;
               End If;
            Else
             -- make the log entry for no fact data and raise the exception.
                makeLogEntry(pMViewName,'COMPLETE',0,x_BeginDate,x_EndDate,Sysdate,null,null,l_mvLogID);
		updateLog(l_mvLogID,-1,sysdate,null,'IBE_ECR_NO_FACT_DATA',x_NoFactMessage);
            --Raise;
            End If;


            IF (l_debug = 'Y') THEN
               printDebugLog(fnd_global.tab||'No OUT Parameters');
               printDebugLog('refershMView(-)');
            END IF;

            printOutput(getMessage('IBE','IBE_ECR_REFRESH_SUCCESS',pMviewName));
	    printOutput('+-----------------------------------------------------------------------------+');

         EXCEPTION
         WHEN OTHERS THEN
           IF (l_debug = 'Y') THEN
              printDebugLog('Exception: refershMView(-):'||SQLCODE);
           END IF;
           printOutput(getMessage('IBE','IBE_ECR_REFRESH_ERROR',pMviewName));
	   printOutput('+-----------------------------------------------------------------------------+');
           Raise;
 END refreshMView;



PROCEDURE refreshMviewMain( errbuf OUT NOCOPY VARCHAR2,retcode OUT NOCOPY NUMBER, pfactRefreshMode IN Varchar2, pDebugFlag IN Varchar2 )    IS
  BEGIN

  /* ***
     batoleti: This procedure is obsoleted.
	          We are not populating the data into prebuilt tables and to MVs.
			Always the report queries are constructed on FACT tables.
			So, to avoid issues relating to MVs, we are obsolting this procedure.
	          Please refer the bug# 3993969 for details.
  * ***/
	NULL;
End refreshMviewMain;

PROCEDURE purgeMain(errbuf    OUT NOCOPY VARCHAR2,retcode OUT NOCOPY  NUMBER, pDebugFlag IN Varchar2) IS

            l_owner Varchar2(30);
            l_tablespace Varchar2(30);
            l_mvlogStatus Number;

        BEGIN
        l_debug_profile := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');
        if ( l_debug_profile = 'Y' OR pDebugFlag = 'Y') then
	      l_debug := 'Y';
	   else
	    	 l_debug := 'N';
	   end if;

        if (l_debug_profile = 'Y') then
	      IBE_UTIL.ENABLE_DEBUG_NEW('N');
        else
           IBE_UTIL.DISABLE_DEBUG_NEW();
       end if;

             -- Set Debug Mode
              g_debugFlag := pDebugFlag;
              If pDebugFlag = 'Y' Then
                IBE_UTIL.Enable_Debug;
              End If;

            IF (l_debug = 'Y') THEN
               printDebugLog('purgeMain(+)');
            END IF;

            l_mvlogStatus := 2;
            Delete from IBE_ECR_MVLOG where Refresh_Status = l_mvlogStatus ;
            Commit;
            printOutput(getMessage('IBE','IBE_ECR_MVLOG_PURGE'));
            IF (l_debug = 'Y') THEN
               printDebugLog('purgeMain(-)');
            END IF;
       EXCEPTION
        when OTHERS then
	   printOutput(SQLCODE||'-'||SQLERRM);
	   retcode := 2;
           raise;
       END purgeMain;



function return_amount(p_inventory_item_id number , p_organization_id number ,
     p_order_header_id number )
 RETURN NUMBER  IS
l_return_amount number;

begin

select Sum((decode(OL.line_category_code,'RETURN',-1,1)* nvl(OL.ordered_Quantity,0))*
           (nvl(OL.Unit_Selling_Price,0))) into l_return_amount
           from oe_order_lines_all ol
           where header_id = p_order_header_id
           and  exists
                ( select line_id from oe_order_lines_all x
                  where  x.inventory_item_id = p_inventory_item_id
                  and    ol.top_model_line_id = x.top_model_line_id
                )  ;


return l_return_amount;

end return_amount;




function return_functional_amount(p_inventory_item_id number , p_organization_id number ,
     p_order_header_id number , p_item_type_code varchar2,p_line_category_code varchar2,
     p_ordered_Quantity number ,p_Unit_Selling_Price number,p_conversion_rate number)
 RETURN NUMBER  IS
l_return_amount number;

begin
 select decode(p_item_type_code,'MODEL',
               return_amount(p_inventory_item_id,p_organization_id,p_order_header_id),
               Sum((decode(p_line_category_code,'RETURN',-1,1)* nvl(p_ordered_Quantity,0))*
                          (nvl(p_Unit_Selling_Price,0)*nvl(p_conversion_rate,1))))
 into l_return_amount
 from dual ;


return l_return_amount;

end return_functional_amount;
function  get_section_path(section_id in number,store_id in number) return varchar2 is
l_section_id  number;
l_store_id    number;
v_root_section_id  varchar2(10);
l_string      varchar2(2000) DEFAULT NULL;
v_string      varchar2(2000) DEFAULT NULL;
v_concat_ids  varchar2(1000);
l_iter   number;
l_concat_begin_brace  number;
l_display_name varchar2(100);
cursor get_concat_ids(section_id number, l_store_id number) is
 select a.concat_ids, b.msite_root_section_id
 from ibe_dsp_msite_sct_sects a,
      ibe_msites_b            b
 where a.child_section_id = section_id
   and a.mini_site_id = 1
   and b.msite_id  = l_store_id
   and b.site_type = 'I'; -- Changed as per the Bug # 4394901
cursor get_section_name(l_concat_section_id number) is
       SELECT display_name
         FROM ibe_dsp_sections_tl
        WHERE section_id = l_concat_section_id
          AND language = userenv('LANG');
BEGIN
     OPEN get_concat_ids(section_id, store_id);
     l_concat_begin_brace := 0;
     FETCH get_concat_ids into v_concat_ids,v_root_section_id;
     v_concat_ids := v_concat_ids||'.';
     l_iter:= 1;
      WHILE (length(v_concat_ids) > 1)
      LOOP
         begin
           v_string:= substr(v_concat_ids,1,instr(v_concat_ids,'.')-1);
            OPEN get_section_name(TO_NUMBER(v_string));
            FETCH get_section_name INTO l_display_name;
            CLOSE get_section_name;
            IF (TO_NUMBER(v_root_section_id) = TO_NUMBER(v_string)) THEN
              IF (l_iter > 1) THEN
                 l_string := l_string||']'||'> '||ltrim(rtrim(l_display_name));
                 l_iter := l_iter + 1;
                 l_concat_begin_brace := 1;
              ELSE
                 l_string := l_string||'> '||ltrim(rtrim(l_display_name));
                 l_iter := l_iter + 1;
              END IF;
           ELSE
             l_string := l_string||'> '||ltrim(rtrim(l_display_name));
             l_iter := l_iter + 1;
           END IF;
           v_concat_ids := substr(v_concat_ids,instr(v_concat_ids,'.')+1) ;
         end;
      END LOOP;
      l_string := substr(l_string,3,length(l_string));
      IF (l_concat_begin_brace = 1) THEN
         l_string := '['||l_string;
      END IF;
      return(l_string);
END;

END IBE_REPORTING_PVT;

/
