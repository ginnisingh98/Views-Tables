--------------------------------------------------------
--  DDL for Package Body MSC_X_USER_EXCEP_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_X_USER_EXCEP_GEN" AS
/* $Header: MSCUDERB.pls 120.6 2007/07/19 08:36:24 vsiyer ship $ */




TYPE UDEVARCHAR_1 IS TABLE OF VARCHAR2(4000) ;
TYPE UDEVARCHAR_2 IS TABLE OF VARCHAR2(80);
TYPE UDEVARCHAR_3 IS TABLE OF VARCHAR2(30)  ;
TYPE UDEVARCHAR_4 IS TABLE OF VARCHAR2(1)  ;
TYPE UDENUMBER IS TABLE OF NUMBER;


ColumnNameList       UDEVARCHAR_1;
DetColumnNameList       UDEVARCHAR_3;
SeqNumList        UDENUMBER;
AttributeTypeList    UDEVARCHAR_3;
DataTypeList         UDEVARCHAR_3;
DisplayLengthList    UDENUMBER;
OrderTypeList                   UDENUMBER; -- 2393803
DisplayLableList     UDEVARCHAR_2;
CalculationNameList        UDEVARCHAR_3;
CompValueList1             UDEVARCHAR_1;
CompValueList2             UDEVARCHAR_1;
DateFilterFlagList           UDEVARCHAR_4;
RollingDateFlagList             UDEVARCHAR_4;
RollingNumberList               UDENUMBER;
RollingTypeList                 UDEVARCHAR_4;
OpColumnNameList                UDEVARCHAR_1;

v_NumRows            INTEGER ;
v_returnCode         INTEGER;
v_exception_id          NUMBER;
v_debug                    BOOLEAN;

v_Number1         DBMS_SQL.Number_Table;
v_Number2         DBMS_SQL.Number_Table;
v_Number3         DBMS_SQL.Number_Table;
v_Number4         DBMS_SQL.Number_Table;
v_Number5         DBMS_SQL.Number_Table;
v_Number6         DBMS_SQL.Number_Table;
v_Number7         DBMS_SQL.Number_Table;
v_Number8         DBMS_SQL.Number_Table;
v_Number9         DBMS_SQL.Number_Table;
v_Number10           DBMS_SQL.Number_Table;
vTransactionId1      DBMS_SQL.Number_Table;
vTransactionId2      DBMS_SQL.Number_Table;
vTransactionId3      DBMS_SQL.Number_Table;

v_Date1           DBMS_SQL.Date_Table;
v_Date2           DBMS_SQL.Date_Table;
v_Date3           DBMS_SQL.Date_Table;
v_Date4           DBMS_SQL.Date_Table;
v_Date5           DBMS_SQL.Date_Table;
v_Date6           DBMS_SQL.Date_Table;
v_Date7           DBMS_SQL.Date_Table;

v_varchar1        DBMS_SQL.VARCHAR2_TABLE;
v_varchar2        DBMS_SQL.VARCHAR2_TABLE;
v_varchar3        DBMS_SQL.VARCHAR2_TABLE;
v_varchar4        DBMS_SQL.VARCHAR2_TABLE;
v_varchar5        DBMS_SQL.VARCHAR2_TABLE;
v_varchar6        DBMS_SQL.VARCHAR2_TABLE;
v_varchar7        DBMS_SQL.VARCHAR2_TABLE;
v_varchar8        DBMS_SQL.VARCHAR2_TABLE;
v_varchar9        DBMS_SQL.VARCHAR2_TABLE;
v_varchar10          DBMS_SQL.VARCHAR2_TABLE;
v_varchar11          DBMS_SQL.VARCHAR2_TABLE;
v_varchar12          DBMS_SQL.VARCHAR2_TABLE;
v_varchar13          DBMS_SQL.VARCHAR2_TABLE;
v_varchar14          DBMS_SQL.VARCHAR2_TABLE;
v_varchar15          DBMS_SQL.VARCHAR2_TABLE;
v_varchar16          DBMS_SQL.VARCHAR2_TABLE;
v_varchar17          DBMS_SQL.VARCHAR2_TABLE;
v_varchar18          DBMS_SQL.VARCHAR2_TABLE;
v_varchar19          DBMS_SQL.VARCHAR2_TABLE;
v_varchar20          DBMS_SQL.VARCHAR2_TABLE;

v_CREATED_BY            DBMS_SQL.Number_Table;
v_CREATION_DATE         DBMS_SQL.Date_Table;
v_LAST_UPDATED_BY       DBMS_SQL.Number_Table;
v_LAST_UPDATE_DATE      DBMS_SQL.Date_Table;
v_EXCEPTION_DETAIL_ID      DBMS_SQL.Number_Table;
vExceptionTypeArray     DBMS_SQL.Number_Table;
vExceptionTypeNameArray    DBMS_SQL.VARCHAR2_TABLE;
vExceptionGroupArray       DBMS_SQL.Number_Table;
vOwningCompanyIdArray           DBMS_SQL.Number_Table;
vExceptionGroupNameArray   DBMS_SQL.VARCHAR2_TABLE;
vExRefreshNumber        NUMBER;
vNewExRefreshNumber     NUMBER;

vSelectStmt          VARCHAR2(8000);
vGroupByStmt         VARCHAR2(8000);
v_InsertStmt            VARCHAR2(8000);
vWhereStmt           VARCHAR2(8000);
capsString           VARCHAR2(16000);
vFromClause          VARCHAR2(1000);
v_ValueStmt             VARCHAR2(2000);
vSortStmt         VARCHAR2(500);
vHavingWhere                    VARCHAR2(2000) := null;
v_fetch_cursor          INTEGER ;
v_insert_cursor         INTEGER ;
v_notificationTitle     VARCHAR2(2000) := NULL;
v_exception_exist       NUMBER  := 0;
v_user_id               NUMBER :=  1003333;
v_resp_id            NUMBER := 54486;
v_resp_appl_id          NUMBER;
v_request_id            NUMBER;
v_item_type          VARCHAR2(30) ;
v_exception_name        VARCHAR2(80);
vExceptionGroupName        VARCHAR2(80);
v_wf_launch_flag     VARCHAR2(1);
v_notification_text     VARCHAR2(2000);
--v_notification_tokens       VARCHAR2(1000);
v_created_by_name          VARCHAR2(100);
v_company_id         NUMBER;
v_notificationToken1       NUMBER := -1;
v_notificationToken2       NUMBER := -1;
v_notificationToken3       NUMBER := -1;
v_addedWhereClause         VARCHAR2(1000) := null;
vTotalFetchedRows       NUMBER := 0;
vTotalNumberOfFetches      NUMBER := 0;
vGroupByFlag         VARCHAR2(1) := 'N';
vLastRunDate         DATE;
vFullDataFlag        VARCHAR2(1);
vExLastUpdateDate               DATE;
vLastUpdateDate                 DATE := sysdate;
--vItemPlannerNtfFlag      Varchar2(1);
vNtfBodyText              Varchar2(4000);
v_wf_process         Varchar2(240);

vCompanyIdIncluded            BOOLEAN := FALSE;
vCustomerIdIncluded           BOOLEAN := FALSE;
vSupplierIdIncluded           BOOLEAN := FALSE;


vFirstRow         BOOLEAN := FALSE;
dateCounter       NUMBER := 0;
numberCounter     NUMBER := 0;
varchar2Counter      NUMBER := 0;

exThresholdError     EXCEPTION;
ExTerminateProgram   EXCEPTION;


-- ========== Declare Local Procedures ==============
Function getVarcharArray(arrayIndex in number ) return DBMS_SQL.VARCHAR2_TABLE ;
Function VarcharValue(varcharCounter in number,
             rowCounter in Number) return varchar2  ;
Function NumberValue(NumberCounter in number,
             rowCounter in Number) return Number  ;
Function DateValue(dateCounter in number,
             rowCounter in Number) return Date ;
Procedure InitializeWfVariables(v_item_type IN VARCHAR2,
                                l_item_key IN VARCHAR2 ,
                                wfAttributeName IN VARCHAR2,
                                rowCounter  in number,
                                columnCounter in number,
                                selectCounter in number,
                                wfAttrValue   out NOCOPY Varchar2 );
Procedure getExceptionDef(v_exception_id In Number );
Procedure buildSqlStmt;
Procedure buildFromClause;
Procedure dumpStmt(Stmt IN VARCHAR2);
Procedure parseStmt(l_cursor in number, Stmt IN VARCHAR2);
Procedure executeSQL;
Procedure fetchAndInsertDetails;
Procedure launchWorkFlow;
Procedure addAutoWhereClause;
Function modifyWhereForThreshold(pExceptionId in number,pWhereCondition in varchar2) return varchar2;
Procedure DBMSSQLStep(DataArrayCounter in Number, data_type IN VARCHAR2,
                      dbms_call IN VARCHAR2,columnCounter in number);
function getNotificationToken(v_notification_text IN VARCHAR2,
                                        tokenNumber in Number) return Number ;
Procedure SendNtfToPlannerCode(p_item_type IN VARCHAR2,pItemKey IN VARCHAR2);

Procedure DeletePreviousData( l_exception_id in number);
Procedure insertExceptionSummary(l_exception_id in number);
Procedure updateExceptionSummary;
Procedure performSetUp;
PROCEDURE Delete_Item(l_type in varchar2, l_key in varchar2);
PROCEDURE deleteResolvedExceptions;

 -- =========== Private Functions =============

--function returns 0 if a user has selected a exception for notifiaction else returns 1
function validate_block_notification(p_user_name in varchar2, p_exception_type in number) return number is
	cursor check_user(p_user in varchar2, p_excep_type number) is
	select 1
	from MSC_EXCEPTION_PREFERENCES ep,
	     fnd_user u
	where ep.user_id = u.user_id
	and u.user_name = p_user
	and exception_type_lookup_code = p_excep_type
	and rank > 0;
	l_select_flag number;
begin
	open check_user(p_user_name, p_exception_type);
	fetch check_user into l_select_flag;
	if check_user%found then
		close check_user;
		return 0; --dont block, validation failed

	end if;
	close check_user;
	return 1; --block notification
end validate_block_notification; ---Added for bug # 6175897

Procedure LOG_MESSAGE( pBUFF  IN  VARCHAR2)
 IS
   BEGIN
     IF v_request_id > 0  THEN
         FND_FILE.PUT_LINE( FND_FILE.LOG, pBUFF);
     ELSE
     -- dbms_output.put_line(pBUFF);
         null;
     END IF;
   EXCEPTION
     WHEN OTHERS THEN
        RETURN;
END LOG_MESSAGE;


Procedure SendNtfToBuyer(p_item_type IN VARCHAR2,pItemKey IN VARCHAR2) is
l_user_name       VARCHAR2(100);
l_item_name       VARCHAR2(255);
l_publisher_item_name   VARCHAR2(255);
l_publisher_site_name   VARCHAR2(255);
l_tp_item_name          VARCHAR2(255);
lNtfId                Number;
  --if item and org are there
  cursor buyer_c1(p_item IN VARCHAR2,p_org IN VARCHAR2) is
   SELECT cont.name
    FROM   msc_partner_contacts cont,
  msc_system_items sys,
  msc_trading_partners mtp
    WHERE  sys.item_name = p_item
    AND    sys.plan_id = -1
    AND    cont.partner_id = sys.buyer_id
    AND    cont.partner_type = 4
 and sys.organization_id=mtp.sr_tp_id
 and     mtp.organization_code = p_org
 and     mtp.partner_type=3;


--if item is there but not the org

  cursor buyer_c2(p_item IN VARCHAR2) is
     SELECT cont.name
    FROM   msc_partner_contacts cont,
  msc_system_items sys,
  msc_trading_partners mtp
    WHERE  sys.item_name = p_item
    AND    sys.plan_id = -1
    AND    cont.partner_id = sys.buyer_id
    AND    cont.partner_type = 4
 and sys.organization_id=mtp.sr_tp_id
 and     mtp.sr_tp_id =mtp.sr_tp_id
 and     mtp.sr_tp_id =mtp.master_organization
 and     mtp.partner_type=3;

begin

--we fetch the item_name from the ouput attr
     l_publisher_item_name := wf_engine.getItemAttrText(
                      p_item_type,
                      pItemKey,
                      'P.ITEM_NAME' );
 l_publisher_site_name := wf_engine.getItemAttrText(
                      p_item_type,
                      pItemKey,
                      'P.PUBLISHER_SITE_NAME' );

 --if item is not slected in the output attribute then show teh warning in the log message...
     if l_publisher_item_name is not null then
        l_item_name := l_publisher_item_name;
     else
       log_message('Warning: Buyer is specified for notification but item is not selected');
     end if;

--if both the item and org(site) are specified in the output attr.
--then send the noti. to the buyer of that item in that org..
     if l_item_name is not null and l_publisher_site_name is not null then
      open buyer_c1(l_item_name,l_publisher_site_name);

         fetch buyer_c1 into l_user_name;
   if v_debug then
  log_message('Buyer: Item Name ::'||l_item_name);
  log_message('Buyer: User Name ::'||l_user_name);
   end if;
  if buyer_c1%NOTFOUND then
  log_message('Warning: Buyer not found for Item : '||l_item_name);
 else
	 if l_user_name is not null and validate_block_notification(l_user_name, v_exception_id) = 0 then ---Bug # 6175897
		 lNtfId := wf_notification.send
			   (
			     role =>l_user_name,
			     msg_type=> p_item_type ,
			     msg_name => v_msg_name ,
			     context => pItemKey,
			     callback => 'MSC_X_USER_EXCEP_GEN.setMesgAttribute'
			     );

		 if v_debug then
		   log_message('Buyer: Notification sent to user='||l_user_name);
		 end if;
	 end if;
end if;

       close buyer_c1;
     elsif l_item_name is not null and l_publisher_site_name is null then
     --if the item is specified in the output attr but the org(site) is not.
     --then send the noti. to the buyer of the item in the master org..
      open buyer_c2(l_item_name);
         fetch buyer_c2 into l_user_name;

 if v_debug then
  log_message('Buyer: Item Name ::'||l_item_name);
  log_message('Buyer: User Name ::'||l_user_name);
  end if;
         if buyer_c2%NOTFOUND then
  log_message('Warning: Buyer not found for Item : '||l_item_name);
 else
	if l_user_name is not null and validate_block_notification(l_user_name, v_exception_id) = 0 then ---Bug # 6175897
		 lNtfId := wf_notification.send
			   (
			     role =>l_user_name,
			     msg_type=> p_item_type ,
			     msg_name => v_msg_name ,
			     context => pItemKey,
			     callback => 'MSC_X_USER_EXCEP_GEN.setMesgAttribute'
			     );

		 if v_debug then
		   log_message('Buyer: Notification sent to user='||l_user_name);
		 end if;
	  end if;
  end if;
       close buyer_c2;
     end if;

-- added exception handler
Exception when others then
 log_message('Buyer: EXCEPTION ::'||sqlerrm);
 if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_ERROR,'MSC_X_USER_EXCEP_GEN.SendNtfToBuyer',SQLERRM);
 end if;



end SendNtfToBuyer;



Procedure SendNtfToSupplierContact(p_item_type IN VARCHAR2,pItemKey IN VARCHAR2) is
l_user_name       VARCHAR2(100);
l_sup_name   VARCHAR2(255);
l_sup_site_name   VARCHAR2(255);
l_publisher_item_name   VARCHAR2(255);
l_publisher_site_name   VARCHAR2(255);
lNtfId                Number;

  cursor SupplierContact_c(p_sup_name IN VARCHAR2,p_sup_site_name IN VARCHAR2,p_publisher_site_name IN VARCHAR2) is
 select
  distinct mpc.name
 from
  msc_partner_contacts mpc,
  msc_trading_partners mtp,
  msc_trading_partner_sites mtps,
  msc_trading_partners mtporg
 where
  mpc.partner_id=mtp.partner_id
  and mpc.partner_site_id=mtps.partner_site_id
  and mpc.PARTNER_TYPE =1--supplier
  and mtp.partner_name = p_sup_name--supplier_name
  and mtp.sr_instance_id=mtporg.sr_instance_id
  and mtporg.partner_type=3
  and mtporg.organization_code = p_publisher_site_name--org_NAME
  and mpc.sr_instance_id=mtporg.sr_instance_id
  and mtps.tp_site_code = p_sup_site_name--supplier_site_name
  and mtps.sr_instance_id=mtporg.sr_instance_id
  and mtps.partner_id=mtp.partner_id;

  cursor sup_modelled_org_c(p_sup_name IN VARCHAR2,p_sup_site_name IN VARCHAR2) is
 select
  distinct mpc.name
 from
  msc_partner_contacts mpc,
  msc_trading_partners mtp,
  msc_trading_partners mtporg
 where
  mpc.partner_id=mtp.MODELED_SUPPLIER_ID
  and mpc.partner_site_id=mtp.MODELED_SUPPLIER_SITE_ID
  and mpc.PARTNER_TYPE =1--supplier
  and mtp.organization_code = p_sup_site_name--supplier modelled as an org
  and mtp.partner_type=3
  and mtp.sr_instance_id=mpc.sr_instance_id
  and mtporg.partner_name=p_sup_name
  and mtp.sr_instance_id=mtporg.sr_instance_id;


begin

--get the supplier_name , supplier_site_name, and org.
  l_sup_name := wf_engine.getItemAttrText(
                      p_item_type,
                      pItemKey,
                      'P.SUPPLIER_NAME' );
  l_sup_site_name := wf_engine.getItemAttrText(
                      p_item_type,
                      pItemKey,
                      'P.SUPPLIER_SITE_NAME' );

 l_publisher_site_name := wf_engine.getItemAttrText(
                      p_item_type,
                      pItemKey,
                      'P.PUBLISHER_SITE_NAME' );

--show warning that Supplier/Supplier Site/Pub Site may not have been defined in the output attr.

if (l_publisher_site_name is null) then
 log_message('Warning: Supplier Contact is selected for notification but Company:Site is not defined in the Output attribute of the Custom Exception.');

elsif (l_sup_name is null) then
 log_message('Warning: Supplier Contact is selected for notification but either Company:Supplier is not defined in the Output attribute of the Custom Exception or the Supplier does not exist.');

elsif (l_sup_site_name is null) then
 log_message('Warning: Supplier Contact is selected for notification but Company:Supplier Site is not defined in the Output attribute of the Custom Exception.');

end if;

--need to send the ntf to the contact of the supplier sites.
if (l_publisher_site_name is not null and l_sup_name is not null and l_sup_site_name is not null ) then
      open SupplierContact_c(l_sup_name,l_sup_site_name,l_publisher_site_name);

         fetch SupplierContact_c into l_user_name;
   if v_debug then
  log_message('Supplier Contact: User Name ::'||l_user_name);
  log_message('Supplier Contact: Supplier Name ::'||l_sup_name);
  log_message('Supplier Contact: Supplier Site Name ::'||l_sup_site_name);
  log_message('Supplier Contact: Site Name ::'||l_publisher_site_name);
   end if;
  if SupplierContact_c%NOTFOUND then

  open sup_modelled_org_c(l_sup_name,l_sup_site_name);

    fetch sup_modelled_org_c into l_user_name;

    if sup_modelled_org_c%NOTFOUND then
    log_message('Warning: Supplier Contact not found for Supplier :: '||l_sup_name ||' , Supplier Site :: '|| l_sup_site_name);
   else
if l_user_name is not null and validate_block_notification(l_user_name, v_exception_id) = 0 then ---Bug # 6175897
     lNtfId := wf_notification.send
        (
          role =>l_user_name,
          msg_type=> p_item_type ,
          msg_name => v_msg_name ,
          context => pItemKey,
          callback => 'MSC_X_USER_EXCEP_GEN.setMesgAttribute'
          );

     if v_debug then
       log_message('Supplier Contact: Notification sent to user='||l_user_name);
     end if;
  end if;
end if;
   close sup_modelled_org_c;

 else
	 if l_user_name is not null and validate_block_notification(l_user_name, v_exception_id) = 0 then ---Bug # 6175897
             lNtfId := wf_notification.send
                   (
                     role =>l_user_name,
                     msg_type=> p_item_type ,
                     msg_name => v_msg_name ,
                     context => pItemKey,
                     callback => 'MSC_X_USER_EXCEP_GEN.setMesgAttribute'
                     );

         if v_debug then
           log_message('Supplier Contact: Notification sent to user='||l_user_name);
         end if;
   end if;
 end if;

       close SupplierContact_c;
end if;
-- added exception handler
Exception when others then
 log_message('Supplier Contact: EXCEPTION ::'||sqlerrm);
 if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING(FND_LOG.LEVEL_ERROR,'MSC_X_USER_EXCEP_GEN.SendNtfToSupplierContact',SQLERRM);
 end if;

end SendNtfToSupplierContact;

Procedure GenerateException(ERRBUF out NOCOPY Varchar2,
                            RETCODE out NOCOPY number,
                             pException_Id   In NUMBER,
              pFullLoad      In VARCHAR2  default NULL ) is
begin
   v_exception_id := pException_Id;
   v_fetch_cursor := DBMS_SQL.OPEN_CURSOR;
   v_insert_cursor := DBMS_SQL.OPEN_CURSOR;

   if pFullLoad = '1' then
      vFullDataFlag  := 'Y';
      if v_debug then
     log_message('Compute exception for full load' );
      end if;
   elsif pFullLoad = '2' then
      vFullDataFlag := 'N';
   if v_debug then
     log_message('Compute exception for incremental load' );
   end if;
   elsif pFullLoad  is null then
       if v_debug then
     log_message('FullLoadFlag to be default by program');
   end if;
   else
   log_message('Incorrect value for Full Load flag');
        FND_MESSAGE.SET_NAME('MSC', 'MSC_UDE_FULLLOADFLAG');
   raise ExTerminateProgram;
   end if;

   if v_debug then
     log_message('before performSetup' );
   end if;
   performSetUp;

   -- retrive user exception definition
   if v_debug then
     log_message('before getExceptionDef');
   end if;
   getExceptionDef(v_exception_id) ;

   -- build select and where statement based on exception definition
   if v_debug then
    log_message('before buildSqlStmt' );
   end if;
   buildSqlStmt;

   -- modify where clause incase threshold is specified in where condition
   if v_debug then
     log_message('before modifyWhereForThreshold' );
   end if;
   vWhereStmt := modifyWhereForThreshold(v_exception_id,vWhereStmt);


   -- build from clause of select statement
   if v_debug then
    log_message('before buildFromClause' );
   end if;
   buildFromClause;

   --  add extra where clause based on creator's company id
   if v_debug then
    log_message('before addAutoWhereClause' );
   end if;
   addAutoWhereClause;

   --parse the complete select statement
   if v_debug then
     log_message('before select parseStmt' );
   end if;
   parseStmt(v_fetch_cursor,vSelectStmt||vFromClause||
         vWhereStmt||vGroupByStmt||vHavingWhere||vSortStmt);

   -- execute select statement
   if v_debug then
    log_message('before executeSQL' );
   end if;
   executeSQL;

   --delete previous exception summary and exception detail data
   --from msc_item_exceptions and msc_x_exception_details table
   --delete if  exception definition changed  or if it is for full data load
   if vFullDataFlag  = 'Y' then
    if v_debug then
         log_message('before DeletePreviousData' );
      end if;
      DeletePreviousData( v_exception_id);
   end if;

   -- Insert record into msc_item_exception
   -- count will be updated later
   insertExceptionSummary(v_exception_id);

   if v_debug then
    log_message('before insert parseStmt' );
   end if;
   parseStmt(v_insert_cursor, v_InsertStmt||v_ValueStmt);

   /* fetchAndInsertDetails does following
     1. fetch rows,
     2. insert into exception detail table
     3. Commit data
     4. For each row, create workflow process, iniitialize workflow attributes,
        build notification title, build urls in notification, launch workflow
   */
   if v_debug then
    log_message('before fetchAndInsertDetails' );
   end if;
   fetchAndInsertDetails;

--how to delete exceptions which are already resolved?
--Exception should be running in incremenatl and exception should not
--aggregate exception

  if vFullDataFlag  <> 'Y' and
     vGroupByFlag <> 'Y' then
   if v_debug then
      log_message('before deleteResolvedExceptions');
   end if;
   deleteResolvedExceptions ;

 end if;

   -- update exception count and last run information into summary table
   updateExceptionSummary;

   if RETCODE <> G_ERROR OR
      RETCODE <> G_WARNING Then
      RETCODE := G_SUCCESS;
   end if;

exception
when ExTerminateProgram then
 if dbms_sql.is_open(v_fetch_cursor) THEN
      dbms_sql.close_cursor(v_fetch_cursor);
  end if;

 if dbms_sql.is_open(v_insert_cursor) THEN
      dbms_sql.close_cursor(v_insert_cursor);
 end if;
 ERRBUF := FND_MESSAGE.GET;
 RETCODE := G_ERROR;
 log_message(ERRBUF);

when others then
 if dbms_sql.is_open(v_fetch_cursor) THEN
      dbms_sql.close_cursor(v_fetch_cursor);
  end if;

 if dbms_sql.is_open(v_insert_cursor) THEN
      dbms_sql.close_cursor(v_insert_cursor);
 end if;

 ERRBUF := SQLERRM;
 RETCODE := G_ERROR;
 log_message(SQLERRM);

end GenerateException;

Procedure performSetUp is
cursor exceptionInfo is
 select
  ex.NAME,
  FND.USER_NAME,
  ex.WF_ITEM_TYPE,
  ex.WF_PROCESS,
  ex.WF_LAUNCH_FLAG,
  translate(ex.NOTIFICATION_TEXT, fnd_global.local_chr(13) || fnd_global.local_chr(10), '  '),
  ex.company_id,
  ex.LAST_RUN_DATE,
  ex.LAST_UPDATE_DATE,
  ex.REFRESH_NUMBER
  --ex.item_planner_ntf_flag
 from
   MSC_USER_EXCEPTIONS ex
  ,fnd_user  fnd
 where
        ex.exception_id = v_exception_id
  and ex.CREATED_BY = fnd.USER_ID;

begin
       v_user_id      := FND_GLOBAL.USER_ID;
       v_resp_id      := FND_GLOBAL.RESP_ID;
       v_resp_appl_id := FND_GLOBAL.RESP_APPL_ID;
       v_request_id   := FND_GLOBAL.CONC_REQUEST_ID;
       vNewExRefreshNumber := null;
       vExRefreshNumber    := null;

       v_debug := FND_PROFILE.VALUE('MRP_DEBUG') = 'Y';
      -- v_debug := TRUE;

      open exceptionInfo ;
      fetch exceptionInfo into
          v_exception_name,
          v_created_by_name,
          v_item_type,
          v_wf_process,
          v_wf_launch_flag,
          v_notification_text,
          v_company_id,
          --vGroupByFlag,
          vLastRunDate,
          vExLastUpdateDate,
     vExRefreshNumber;
     --vItemPlannerNtfFlag;
      close exceptionInfo ;


      if v_exception_name is null then
          log_message('exception definition not found');
          FND_MESSAGE.SET_NAME('MSC', 'MSC_UDE_EXCNOTFOUND');
          raise ExTerminateProgram;
      end If;


      if v_debug then
        log_message('user_id: '||to_char(v_user_id) );
        log_message('resp_id: '||to_char(v_resp_id) );
        log_message('request_id: '||to_char(v_request_id) );
        log_message('exception name=' || v_exception_name);
        log_message('Company Id=' || v_company_id );
      end if;

end performSetUp;



Procedure getExceptionDef( v_exception_id in NUMBER) Is
begin
 dateCounter := 0;
 numberCounter := 0;
 varchar2Counter := 0;


Select
AkRegItem.attribute3,
AkRegItem.attribute4,
comp.seq_num ,
decode(comp.component_type,1,'SELECT',2,'FILTER','5','ADVWHERE','6','SIMPLECONDITION',NULL) ,  -- bug# 2365812
comp.component_type comp_order, -- 2393803
akattr.DATA_TYPE,
AkRegItem.DISPLAY_VALUE_LENGTH,
nvl(comp.LABEL, AkRegItemTl.ATTRIBUTE_LABEL_LONG),
NULL,
comp.COMPONENT_VALUE1,
comp.COMPONENT_VALUE2,
comp.DATE_FILTER_FLAG,
comp.ROLLING_DATE_FLAG,
comp.ROLLING_NUMBER,
comp.ROLLING_TYPE,
comp.attribute1             --bug# 2410159
BULK COLLECT INTO ColumnNameList,DetColumnNameList,SeqNumList,
     AttributeTypeList, OrderTypeList, DataTypeList,DisplayLengthList,
     DisplayLableList,CalculationNameList,CompValueList1,CompValueList2,
     DateFilterFlagList,RollingDateFlagList,RollingNumberList,RollingTypeList,OpColumnNameList
From
ak_attributes  akattr,
ak_region_items AkRegItem,
ak_region_items_tl AkRegItemTl,
MSC_USER_EXCEPTIONS  mse,
MSC_USER_EXCEPTION_COMPONENTS comp
where
    mse.region_code =  'MSCUSEREXCEPTION'
AND mse.exception_id = v_exception_id
AND mse.region_code = AkRegItem.region_code
AND mse.exception_id = comp.exception_id
AND comp.component_type in (1, 2, 5, 6) -- bug# 2365812
AND comp.ak_attribute_code = AkRegItem.attribute_code
AND AkRegItem.REGION_APPLICATION_ID = 724
AND AkRegItem.ATTRIBUTE_APPLICATION_ID = akattr.ATTRIBUTE_APPLICATION_ID
AND AkRegItem.ATTRIBUTE_CODE  = akattr.ATTRIBUTE_CODE
AND AkRegItem.REGION_CODE = AkRegItemTl.REGION_CODE
AND AkRegItem.ATTRIBUTE_CODE = AkRegItemTl.ATTRIBUTE_CODE
AND AkRegItem.REGION_APPLICATION_ID = AkRegItemTl.REGION_APPLICATION_ID
AND AkRegItem.ATTRIBUTE_APPLICATION_ID = AkRegItemTl.ATTRIBUTE_APPLICATION_ID
AND AkRegItemTl.LANGUAGE = 'US'
/* this will give you user calculations  */
union
Select
exp.Expression1,
NULL,
comp.seq_num,
decode(comp.component_type,4,'CALCULATION',NULL)  ,
decode(comp.component_type,4 ,1,NULL) comp_order , --2393803
exp.CALCULATION_DATATYPE,
exp.DISPLAY_LENGTH,
comp.Label,
exp.NAME,
NULL,
NULL,
NULL,
NULL,
to_number(null),
NULL,
NULL        --bug# 2410159
from
 MSC_USER_EXCEPTION_COMPONENTS comp,
 MSC_USER_ADV_EXPRESSIONS exp
where
     comp.exception_id = v_exception_id
AND  comp. component_type in (4)
AND  comp.expression_id = exp.expression_id
order by comp_order, seq_num; -- bug# 2365812

end getExceptionDef;



Procedure buildSqlStmt IS
num1 NUMBER  := 0;
l_colStr VARCHAR2(100) := NULL;
i_dateCounter NUMBER := 0;
i_numberCounter NUMBER := 0;
i_varchar2Counter NUMBER := 0;
vAdvWhere       VARCHAR2(8000) := null;
groupByPos1     NUMBER         := null;
havingPos1      NUMBER         := null;
iWhereListNumber NUMBER        := -1;

-- bug# 2365812
v_join_clause  Varchar2(10)    := ' AND ';  -- AND/ OR condition

begin
vSelectStmt  := NULL;
vSortStmt    := NULL;
v_InsertStmt := NULL;
vWhereStmt   := NULL;
vFromClause := NULL;
v_ValueStmt  := NULL;
vGroupByStmt := NULL;
dateCounter  := 0;
numberCounter := 0;
varchar2Counter := 0;
vCompanyIdIncluded     := FALSE;
vCustomerIdIncluded    := FALSE;
vSupplierIdIncluded    := FALSE;
vHavingWhere           := null;

FOR i IN ColumnNameList.FIRST..ColumnNameList.LAST
LOOP

   if AttributeTypeList(i) in ( 'SELECT','CALCULATION') Then
      num1 := num1 + 1;
   --All these this should be checked in UI itself
   if ColumnNameList(i) is null then
      --Columname should not be null for calculation and select attribute
      FND_MESSAGE.SET_NAME('MSC', 'MSC_UDE_COLNAMENULL');
                 raise ExTerminateProgram;
   elsif SeqNumList(i) is null then
         --SeqNumber  should not  be null for calculation and select attribute
      FND_MESSAGE.SET_NAME('MSC', 'MSC_UDE_SQNUMNULL');
                 raise ExTerminateProgram;

   end If;

        if AttributeTypeList(i) = 'CALCULATION' then
          -- if we have any aggregate calculation, then we need to do the group by
     --  all non-aggrgated calculations
          -- also set the global flag indicating whether group be needs to be done or not
     -- we will do group by ONLY IF any aggregate calculation is used in exception
          -- DataTypeList(i) for calculation should not be null
             if  DataTypeList(i) <> 'AGGREGATE' or
                 DataTypeList(i)  is null then

                 if vGroupByStmt is null then
                    vGroupByStmt := ' group by '|| ColumnNameList(i);
                 else
          vGroupByStmt := vGroupByStmt||','||ColumnNameList(i);
                 end if;

             else

                  if v_debug then
                     log_message('calculation type ='||AttributeTypeList(i) );
                  end if;

                  vGroupByFlag := 'Y';
             end if;

      else

           if vGroupByStmt is null then
              vGroupByStmt := ' group by ' || ColumnNameList(i);
           else
                vGroupByStmt := vGroupByStmt||','||ColumnNameList(i);
           end if;

     end if;


     if vSelectStmt is null then
         vSelectStmt := ColumnNameList(i);
     else
         vSelectStmt := vSelectStmt||','||ColumnNameList(i);
     end if;

        -- sort is only on the first three selected attributes
     if i < 4 then

      if vSortStmt  is null then
      vSortStmt := ' Order By '|| ColumnNameList(i);
           else
      vSortStmt := vSortStmt ||' , '|| ColumnNameList(i);
      end if;

     end if;

      /*
         We need to build insert and values string too.
         Whatever is selected to be used for insert.
         For 'SELECT' p_out_column can be null
       */
     if DetColumnNameList(i) is not null then

         if v_InsertStmt is null then
            v_InsertStmt :=  ' Insert into MSC_X_EXCEPTION_DETAILS( '|| DetColumnNameList(i);
            v_ValueStmt :=  ' VALUES (:A'||to_char(num1) ;
         else
            v_InsertStmt := v_InsertStmt ||','||DetColumnNameList(i);
            v_ValueStmt  := v_ValueStmt  ||','||':A'||to_char(num1);
         end if;

     else
         /* columns not defined in table for this attribute or this is
            user calculation */

         if DataTypeList(i) in ('DATE' ,'DATETIME' )then
          i_dateCounter := i_dateCounter + 1;
          l_colStr := 'DATE'||to_char(i_dateCounter);
        elsif DataTypeList(i) in ('NUMBER','AGGREGATE') then
          i_numberCounter := i_numberCounter + 1;
          l_colStr := 'NUMBER'||to_char(i_numberCounter);
        elsif DataTypeList(i) in ('VARCHAR2') then
           i_varchar2Counter := i_varchar2Counter + 1;
           l_colStr :=  'USER_ATTRIBUTE'||to_char(i_varchar2Counter);
   else
      --Datatype not correct
      FND_MESSAGE.SET_NAME('MSC', 'MSC_UDE_INCORRECT_DATA_TYPE');
            raise ExTerminateProgram;

        end if;


         if v_InsertStmt is null then
           v_InsertStmt :=   ' Insert into MSC_X_EXCEPTION_DETAILS( '||
                               l_colStr;
           v_ValueStmt :=  ' VALUES (:A'||to_char(num1) ;
         else
           v_InsertStmt := v_InsertStmt || ','||l_colStr;
          v_ValueStmt  := v_ValueStmt  ||','||':A'||to_char(num1);
         end if;


    end if; /* DetColumnNameList(i) */

 elsif AttributeTypeList(i) in  ('FILTER','ADVWHERE') Then
  if v_debug  then
    log_message('i='||i||' Filter or advwhere'|| AttributeTypeList(i));
  end if;
   if AttributeTypeList(i) = 'FILTER' Then

   if CompValueList1(i) is null  AND DateFilterFlagList(i) <> 'R' then
      --Parameter should not be null for filter unless it's a date filter set to rolling time period
      FND_MESSAGE.SET_NAME('MSC', 'MSC_UDE_PARAM_VALUE_NULL');
            raise ExTerminateProgram;
        end if;

        if DataTypeList(i) in ('DATE' ,'DATETIME' )then
           -- from UI date always need to be stored in cannonical format
           --CompValueList1(i) :=
             --' to_date('||''''||CompValueList1(i)||''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''''||')';

          /* this is new changes proposed by pm */
          --DateFilterFlagList,RollingDateFlagList,RollingNumberList,RollingTypeList
          -- Date_filter_flag => D for Date Range, R for Rolling Time and P for Period to date
          -- RollingDateFlagList => L for LAST, N for NEXT
          -- RollingTypeList => D for Day, W for week, M for Month, Y for Year

             if DateFilterFlagList(i) = 'D' then
                 CompValueList1(i) := ' between to_date('||
        ''''||CompValueList1(i)||''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''''||')' ||
        'and to_date('||
                   ''''||CompValueList2(i)||''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''''||')';

             elsif DateFilterFlagList(i) = 'R' then

                if RollingDateFlagList(i) = 'L' then
                   if RollingTypeList(i) = 'D' then
                  CompValueList1(i) := ' between sysdate - '||RollingNumberList(i)||'*1'||' and sysdate';
                   elsif RollingTypeList(i) = 'W' then
                  CompValueList1(i) := ' between sysdate - '||RollingNumberList(i)||'*7'||' and sysdate';
                   elsif RollingTypeList(i) = 'M' then
                   CompValueList1(i) := ' between add_months(sysdate,-'||RollingNumberList(i)||
                     ') and sysdate';
                    elsif RollingTypeList(i) = 'Y' then
                    CompValueList1(i) := ' between add_months(sysdate,-'||RollingNumberList(i)||
                       '*12 ) and sysdate ';
                    end if;
                elsif RollingDateFlagList(i) = 'N' then
                    if RollingTypeList(i) = 'D' then
                        CompValueList1(i) := ' between sysdate and  sysdate + '||RollingNumberList(i)||'*1';
                    elsif RollingTypeList(i) = 'W' then
                        CompValueList1(i) := ' between sysdate and sysdate + '||RollingNumberList(i)||'*7';
                    elsif RollingTypeList(i) = 'M' then
                        CompValueList1(i) := ' between sysdate and add_months(sysdate,'||
                 RollingNumberList(i)||')' ;
                    elsif RollingTypeList(i) = 'Y' then
                         CompValueList1(i) := ' between sysdate and add_months(sysdate,'||
                   RollingNumberList(i)||'*12 )';
                     end if;
                 end if;

             elsif DateFilterFlagList(i) = 'P' then
                   CompValueList1(i) := ' between to_date('||
                       ''''||CompValueList1(i)||''''||','||''''||'YYYY/MM/DD HH24:MI:SS'||''''||')' ||
                   'and sysdate ';
              end if;

              if vWhereStmt is null then
                 vWhereStmt :=  ColumnNameList(i)||  CompValueList1(i);
              else
                  vWhereStmt := vWhereStmt ||' AND '||ColumnNameList(i)|| CompValueList1(i);
              end if;


         elsif DataTypeList(i) in ('NUMBER','AGGREGATE') then
               --need to figure how it is being stored
               null ;
               if vWhereStmt is null then
                   vWhereStmt :=  ColumnNameList(i)|| ' in ('|| CompValueList1(i)|| ')';
               else
                   vWhereStmt := vWhereStmt ||' AND '||ColumnNameList(i)|| ' in ('|| CompValueList1(i)|| ')';
               end if;

         elsif DataTypeList(i) in ('VARCHAR2') then
               CompValueList1(i) := ''''||replace(CompValueList1(i), '''', '''''')||'''';
              if vWhereStmt is null then
                  vWhereStmt :=  ColumnNameList(i)|| ' in ('|| CompValueList1(i)|| ')';
              else
                  vWhereStmt := vWhereStmt ||' AND '||ColumnNameList(i)|| ' in ('|| CompValueList1(i) || ')';
              end if;

         else
                --Datatype not correct
                FND_MESSAGE.SET_NAME('MSC', 'MSC_UDE_INCORRECT_DATA_TYPE');
                raise ExTerminateProgram;
          end if;


   else

     /* advance where condition */

        log_message('advance condition=' || i);
        iWhereListNumber := i;

   end if;

   -- bug# 2365812 (adding Simple Conditions)

   elsif AttributeTypeList(i) in  ('SIMPLECONDITION') Then

      if v_debug  then
        log_message('i='||i||' Simple Condition '|| AttributeTypeList(i));
      end if;

      if ((CompValueList1(i) is null and RollingNumberList(i) NOT IN (9,10))
             and (OpColumnNameList(i) is null)) then
              --Parameter should not be null for Simple Condition
               FND_MESSAGE.SET_NAME('MSC', 'MSC_UDE_PARAM_VALUE_NULL');
              raise ExTerminateProgram;
      end if;

      --bug# 2410159
      if OpColumnNameList(i) is not null then

          -- get column name from attribute code
          select attribute3 into OpColumnNameList(i)
          from ak_region_items
          where attribute_code = OpColumnNameList(i)
          and   REGION_APPLICATION_ID = 724
          and   region_code =  'MSCUSEREXCEPTION';

        if RollingTypeList(i) = '1' then
             v_join_clause  := ' AND ';
        elsif RollingTypeList(i) = '2' then
             v_join_clause  := ' OR ';
        else
             v_join_clause  := ' AND ';
        end if;

        if AttributeTypeList.EXISTS(i-1) then
              if AttributeTypeList(i-1) <> ('SIMPLECONDITION') then
                 if vWhereStmt is null then
                     vWhereStmt :=  ' ('; -- open bracket to take care of OR
                 else
                     vWhereStmt := vWhereStmt ||' AND '||'(';
                 end if;
              else
                     vWhereStmt := vWhereStmt || v_join_clause;
              end if;
        else -- if this is the first one
              if vWhereStmt is null then
                     vWhereStmt :=  ' ('; -- open bracket to take care of OR
              else
                     vWhereStmt := vWhereStmt ||' AND '||'(';
              end if;
        end if;



        if RollingNumberList(i) = '1' Then   -- Equal
             vWhereStmt := vWhereStmt ||ColumnNameList(i)|| ' = '|| OpColumnNameList(i);

        elsif RollingNumberList(i) = '2' Then-- Is Not
             vWhereStmt := vWhereStmt ||ColumnNameList(i)|| ' <> '|| OpColumnNameList(i);

        elsif RollingNumberList(i) = '3' Then-- Less Than
             vWhereStmt := vWhereStmt ||ColumnNameList(i)|| ' < '|| OpColumnNameList(i);

        elsif RollingNumberList(i) = '6' Then-- Greater Than
             vWhereStmt := vWhereStmt ||ColumnNameList(i)|| ' > '|| OpColumnNameList(i);

        end if;

        if AttributeTypeList.EXISTS(i+1) then
              if AttributeTypeList(i+1) <> ('SIMPLECONDITION') then
                vWhereStmt :=  vWhereStmt ||')'; -- close bracket opened for OR
              end if;
        else -- if this is the last one
              vWhereStmt :=  vWhereStmt ||')'; -- close bracket opened for OR
        end if;

      else -- OpColumnNameList is null

        if DataTypeList(i) in ('DATE' ,'DATETIME' )then
               CompValueList1(i) := ' to_date('||''''||CompValueList1(i)||''''||','||''''
                                               ||'YYYY/MM/DD HH24:MI:SS'||''''||')';
               if CompValueList2(i) IS NOT NULL THEN
                   CompValueList2(i) := ' to_date('||''''||CompValueList2(i)||''''||','||''''
                                                   ||'YYYY/MM/DD HH24:MI:SS'||''''||')';
               end if;

        elsif DataTypeList(i) in ('NUMBER','AGGREGATE') then
               null ;

        elsif DataTypeList(i) in ('VARCHAR2') then
              CompValueList1(i) := ''''|| replace(CompValueList1(i), '''', '''''') ||'''';

        else
              --Datatype not correct
              FND_MESSAGE.SET_NAME('MSC', 'MSC_UDE_INCORRECT_DATA_TYPE');
              raise ExTerminateProgram;

        end if;

        if RollingTypeList(i) = '1' then
             v_join_clause  := ' AND ';
        elsif RollingTypeList(i) = '2' then
             v_join_clause  := ' OR ';
        else
             v_join_clause  := ' AND ';
        end if;

        if AttributeTypeList.EXISTS(i-1) then
              if AttributeTypeList(i-1) <> ('SIMPLECONDITION') then
                 if vWhereStmt is null then
                     vWhereStmt :=  ' ('; -- open bracket to take care of OR
                 else
                     vWhereStmt := vWhereStmt ||' AND '||'(';
                 end if;
              else
                     vWhereStmt := vWhereStmt || v_join_clause;
              end if;
        else -- if this is the first one
              if vWhereStmt is null then
                     vWhereStmt :=  ' ('; -- open bracket to take care of OR
              else
                     vWhereStmt := vWhereStmt ||' AND '||'(';
              end if;
        end if;


        -- from MSC_FILTER_CONDITIONS lookup type

        if RollingNumberList(i) = '1' Then   -- Equal
             vWhereStmt := vWhereStmt ||ColumnNameList(i)|| ' = ('|| CompValueList1(i)|| ')';

        elsif RollingNumberList(i) = '2' Then-- Is Not
             vWhereStmt := vWhereStmt ||ColumnNameList(i)|| ' <> ('|| CompValueList1(i)|| ')';

        elsif RollingNumberList(i) = '3' Then-- Less Than
             vWhereStmt := vWhereStmt ||ColumnNameList(i)|| ' < ('|| CompValueList1(i)|| ')';

        elsif RollingNumberList(i) = '6' Then-- Greater Than
             vWhereStmt := vWhereStmt ||ColumnNameList(i)|| ' > ('|| CompValueList1(i)|| ')';

        elsif RollingNumberList(i) = '7' Then-- Between
             if CompValueList2(i) IS NULL THEN
                 CompValueList2(i) := CompValueList1(i);
             end if;
             vWhereStmt := vWhereStmt ||ColumnNameList(i)|| ' between ('|| CompValueList1(i)
                                      || ') and ('|| CompValueList2(i)|| ')';

        elsif RollingNumberList(i) = '8' Then-- Outside
             if CompValueList2(i) IS NULL THEN
                 CompValueList2(i) := CompValueList1(i);
             end if;
             vWhereStmt := vWhereStmt ||'( '||ColumnNameList(i)|| ' < ('|| CompValueList1(i)|| ') and '
                                      ||ColumnNameList(i)|| ' > ('|| CompValueList2(i) ||'))';

        elsif RollingNumberList(i) = '9' Then-- Is Empty
             vWhereStmt := vWhereStmt ||ColumnNameList(i)|| ' IS NULL';

        elsif RollingNumberList(i) = '10'Then-- Is Entered
             vWhereStmt := vWhereStmt ||ColumnNameList(i)|| ' IS NOT NULL';
        end if;

        if AttributeTypeList.EXISTS(i+1) then
              if AttributeTypeList(i+1) <> ('SIMPLECONDITION') then
                vWhereStmt :=  vWhereStmt ||')'; -- close bracket opened for OR
              end if;
        else -- if this is the last one
              vWhereStmt :=  vWhereStmt ||')'; -- close bracket opened for OR
        end if;
     end if;  -- OpColumnNameList is not null
 end if;

end loop;

   log_message('iWhereListNumbe='||iWhereListNumber);

 if iWhereListNumber <> -1 then
     vAdvWhere := CompValueList1(iWhereListNumber)||CompValueList2(iWhereListNumber);
   log_message('adv cond='|| CompValueList1(iWhereListNumber));
    /*
       1. if group by  and having both or present then don't do anything. This may be problem
       2. there is no group by but having clause specfied, insert group by before having
       3. there is no group by and and no having clause specified, generate group by
    */

     groupByPos1 := INSTR(upper(vAdvWhere),'GROUP BY');
     havingPos1  := INSTR(upper(vAdvWhere),'HAVING ');
     if groupByPos1 <> 0 and havingPos1 <> 0 then
       -- user specified group by and having clause
        if v_debug then
         log_message('Both group by and having clause specfied in adv condition');
        end if;
        vGroupByFlag := 'Y';
        vGroupByStmt := null;
     /* elsif groupByPos1 = 0 and havingPos1 <> 0 then
       --need group by clause and having clasue separate
        if v_debug then
         log_message('Having clause specfied in adv condition. Group by to be generated');
        end if;
        vHavingWhere := substr(vAdvWhere,havingPos1);
        vAdvWhere := substr(vAdvWhere,1,havingPos1-1);
     */
     elsif groupByPos1 = 0 and havingPos1 = 0 and vGroupByFlag = 'Y' then
        if v_debug then
         log_message('No group by and having clause in adv conditio but group by to be generated');
        end if;
     else
        if v_debug then
           log_message('It appears to be transaction exception');
        end if;
     end if;


   if vWhereStmt is null then
       vWhereStmt :=  vAdvWhere;
   else
       vWhereStmt :=   vWhereStmt ||' AND '|| vAdvWhere;

   end if;

 end if;


 if vFullDataFlag is null then
   --full load or incremental determined by whether
   --exception has any aggregate calculation or not
   -- or user might have specified group by in condition iteself

   if vGroupByFlag = 'Y'  then
      vFullDataFlag := 'Y';
   else
      vFullDataFlag := 'N';
   end if;
 end if;

 -- If Group by,Include group by statemnet else include trandsaction ids
 -- in select statement and as well as in insert and values statement
 if vSelectStmt is null then
    FND_MESSAGE.SET_NAME('MSC', 'MSC_UDE_SELECT_NULL');
    raise ExTerminateProgram;
 end if;

 if vGroupByFlag = 'Y' then
     if v_debug then
   log_message('Summary exception: Not including ids');
     end if;
     vGroupByStmt:= vGroupByStmt ;
 elsif vSelectStmt is not null    and
     vGroupByFlag <> 'Y'   then
     vGroupByStmt := NULL;
     if v_debug then
       log_message('Transaction exception: including ids');
     end if;
   if INSTR(vSelectStmt,'COMPANY.' ) <> 0 OR
      INSTR(vWhereStmt,'COMPANY.') <> 0 then
      vSelectStmt := vSelectStmt||', COMPANY.TRANSACTION_ID ';
      v_InsertStmt := v_InsertStmt||', TRANSACTION_ID1 ';
      v_ValueStmt  := v_ValueStmt||' ,:TRANSACTION_ID1';
      vCompanyIdIncluded := TRUE;
   end if;
   if INSTR(vSelectStmt,'CUSTOMER.' ) <> 0 OR
      INSTR(vWhereStmt,'CUSTOMER.') <> 0 then
      vSelectStmt := vSelectStmt||', CUSTOMER.TRANSACTION_ID ';
      v_InsertStmt := v_InsertStmt||', TRANSACTION_ID2 ';
      v_ValueStmt  := v_ValueStmt||' ,:TRANSACTION_ID2';
      vCustomerIdIncluded := TRUE;
   end if;
   if INSTR(vSelectStmt,'SUPPLIER.' ) <> 0  OR
      INSTR(vWhereStmt,'SUPPLIER.') <> 0 then
      vSelectStmt := vSelectStmt||', SUPPLIER.TRANSACTION_ID ';
      v_InsertStmt := v_InsertStmt||', TRANSACTION_ID3 ';
      v_ValueStmt  := v_ValueStmt||' ,:TRANSACTION_ID3';
      vSupplierIdIncluded := TRUE;
   end if;
 end if;

vSelectStmt := 'Select ' || vSelectStmt ;

   -- we need to close bracket for insert
   -- we need to add who columns here as well as other
   -- columns in exception details table
  v_InsertStmt := v_InsertStmt ||
         ',CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,'||
         'EXCEPTION_DETAIL_ID,EXCEPTION_TYPE,EXCEPTION_TYPE_NAME,EXCEPTION_GROUP, '||
    'EXCEPTION_GROUP_NAME,OWNING_COMPANY_ID ) ';

  -- we need to close bracket for values
  v_ValueStmt := v_ValueStmt ||
       ',:CREATED_BY,:CREATION_DATE,:LAST_UPDATED_BY,:LAST_UPDATE_DATE,'||
       ':EXCEPTION_DETAIL_ID,:EXCEPTION_TYPE,:EXCEPTION_TYPE_NAME,:EXCEPTION_GROUP,'||
       ':EXCEPTION_GROUP_NAME ,:OWNING_COMPANY_ID) ';


end buildSqlStmt;

Procedure buildFromClause is
begin

  --anuj reminder. We may have view for publisher, customer and supplier
   if ( INSTR(UPPER(vSelectStmt),'COMPANY.') <> 0 ) OR
       (INSTR(UPPER(vWhereStmt),'COMPANY.') <> 0 )  then
        vFromClause := ' FROM msc_sup_dem_ent_custom_ex_v COMPANY ';
   end if;

  if ( INSTR(UPPER(vSelectStmt),'SUPPLIER.') <> 0  ) OR
      ( INSTR(UPPER(vWhereStmt),'SUPPLIER.') <> 0 ) then
      if vFromClause is null then
         vFromClause := ' FROM msc_sup_dem_ent_custom_ex_v SUPPLIER ';
      else
        vFromClause := vFromClause || ' , msc_sup_dem_ent_custom_ex_v SUPPLIER ';
      end if;
   end if;
  if ( INSTR(UPPER(vSelectStmt),'CUSTOMER.') <> 0 ) OR
      ( INSTR(UPPER(vWhereStmt),'CUSTOMER.') <> 0 )  then
      if vFromClause is null then
         vFromClause := ' FROM msc_sup_dem_ent_custom_ex_v CUSTOMER ';
      else
        vFromClause := vFromClause || ' , msc_sup_dem_ent_custom_ex_v CUSTOMER ';
      end if;
   end if;

   vFromClause := vFromClause || ' WHERE ';
end buildFromClause;


Procedure addAutoWhereClause is

 lconditionTable  VARCHAR2(30);

 cursor lastUpdateC is
 select max(LAST_UPDATE_DATE)
 from MSC_USER_EXCEPTION_COMPONENTS
 where exception_id = v_exception_id;

 cursor lastUpdateE is
 select max(LAST_UPDATE_DATE)
 from MSC_USER_ADV_EXPRESSIONS
 where expression_id in  ( select expression_id
                           from MSC_USER_EXCEPTION_COMPONENTS
                           where exception_id = v_exception_id);
 l_lastupdatedateC   DATE;
 l_lastupdatedateE   DATE;

begin
  v_addedWhereClause := null;
  capsString := null;
  if v_debug then
    log_message('company_id =' || v_company_id);
  end if;
  capsString := upper(vWhereStmt||vSelectStmt);

  if instr(capsString,'COMPANY.') <> 0 then
     lconditionTable := 'COMPANY';
  elsIf instr(capsString,'SUPPLIER.')  <> 0 then
     lconditionTable := 'SUPPLIER';
  elsif instr(capsString,'CUSTOMER.') <> 0 then
    lconditionTable := 'CUSTOMER';
  end if;

  select max(LAST_REFRESH_NUMBER)
  into vNewExRefreshNumber
  from   msc_sup_Dem_entries;

  if vExRefreshNumber is null then
         vExRefreshNumber := -2;
  end if;

  open lastUpdateC ;
  fetch lastUpdateC into l_lastUpdateDateC;
  close lastUpdateC;

  open lastUpdateE ;
  fetch lastUpdateE into l_lastUpdateDateE;
  close lastUpdateE;

  if l_lastUpdateDateC > vLastRunDate OR
     l_lastUpdateDateE > vLastRunDate Then
     --vExLastUpdateDate > vLastRunDate Then
       log_message('Exception definition changed since last Run. Exception to be run for complete data');
       log_message('CompDate='||l_lastUpdateDateC||' Exp Date='||l_lastUpdateDateE||' LastRun='||vLastRunDate);
       log_message('Previous exception output to be deleted');
       vFullDataFlag := 'Y';
  end if;


  if   vFullDataFlag <> 'Y' Then
   -- we need to add incremental clause
   v_addedWhereClause := v_addedWhereClause ||
                 ' nvl('||lconditionTable||'.last_refresh_number,-1) > ' ||vExRefreshNumber;


  end if;

  if v_addedWhereClause is not null then
     v_addedWhereClause := v_addedWhereClause || ' AND ';
  end if;

  v_addedWhereClause := v_addedWhereClause||
                        ' ( ' ||lconditionTable||'.PUBLISHER_ID = :company_id '||
              ' OR '||lconditionTable||'.SUPPLIER_ID  = :company_id '||
              ' OR '||lconditionTable||'.CUSTOMER_ID  = :company_id '||
                        ' ) ';

  if vWhereStmt is null then
        vWhereStmt :=  v_addedWhereClause;
  else
        vWhereStmt := v_addedWhereClause || ' AND '|| vWhereStmt ;
  end if;

end  addAutoWhereClause;


Procedure  executeSQL is
lCounterTemp NUMBER := 1;
begin
  dateCounter := 0;
  numberCounter := 0;
  varchar2Counter := 0;

  if v_debug then
     log_message('binding company id= '||v_company_id);
  end if;
  dbms_sql.bind_variable(v_fetch_cursor,':company_id',v_company_id);


  if v_debug then
     log_message('Before DEFINE_ARRAY');
  end if;

  For columnCounter IN 1..DataTypeList.COUNT loop

   --if SeqNumList(columnCounter) is not null then
   if AttributeTypeList(columnCounter) in ( 'SELECT','CALCULATION') then

     if DataTypeList(columnCounter) in ('DATE','DATETIME') then
         dateCounter := dateCounter + 1;
      if dateCounter > 7 then
      --Number of date column should not be more then 7
      FND_MESSAGE.SET_NAME('MSC', 'MSC_UDE_DATE_COL_EXCEEDED');
               raise ExTerminateProgram;
         end if;
         DBMSSQLStep(dateCounter, 'DATE' , 'DEFINE_ARRAY',lCounterTemp);
      elsif DataTypeList(columnCounter) in ( 'NUMBER','AGGREGATE') then
         numberCounter := numberCounter + 1;
      if numberCounter > 10 then
      --Number of Number column should not be more then 10
      FND_MESSAGE.SET_NAME('MSC', 'MSC_UDE_NUMBER_COL_EXCEEDED');
                 raise ExTerminateProgram;
         end if;
         DBMSSQLStep(numberCounter, 'NUMBER' , 'DEFINE_ARRAY',lCounterTemp);
      elsif DataTypeList(columnCounter) = 'VARCHAR2' then
         varchar2Counter := varchar2Counter + 1;
      if varchar2Counter > 20 then
      --Number of varchar2 column should not be more then 20
      FND_MESSAGE.SET_NAME('MSC', 'MSC_UDE_VARCHAR2_COL_EXCEEDED');
                 raise ExTerminateProgram;
         end if;
         DBMSSQLStep(varchar2Counter, 'VARCHAR2' , 'DEFINE_ARRAY',lCounterTemp);
     else
   --Datatype not correct
   FND_MESSAGE.SET_NAME('MSC', 'MSC_UDE_INCORRECT_DATA_TYPE');
         raise ExTerminateProgram;

     end if;

      lCounterTemp := lCounterTemp + 1;
   end if;
 end loop;

    -- define array for transaction ids which are added due to transaction exceptions
   if  vCompanyIdIncluded  then
     log_message('Before binding vTransactionId1. lCounterTemp='||lCounterTemp);
     DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,lCounterTemp,vTransactionId1,vBatchSize,1);
     lCounterTemp := lCounterTemp +1;
   end if;
   if vCustomerIdIncluded then
     log_message('Before binding vTransactionId2');
     DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,lCounterTemp,vTransactionId2,vBatchSize,1);
     lCounterTemp := lCounterTemp +1;
   end if;
   if vSupplierIdIncluded then
     log_message('Before binding vTransactionId3');
     DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,lCounterTemp,vTransactionId3,vBatchSize,1);
   end if;

  log_message('Before executing sql');
  v_ReturnCode := DBMS_SQL.EXECUTE(v_fetch_cursor);

end executeSQL ;

Procedure DeletePreviousData( l_exception_id in number) is

cursor detailIds is
select to_char(exception_Detail_id)
from msc_x_exception_details
where  EXCEPTION_TYPE = l_exception_id
and EXCEPTION_GROUP = -99;

lExceptionDetailsId   Varchar2(30);

Begin
 if(vFullDataFlag = 'Y' ) then
    -- delete previous workflows

   if v_item_type is not null then
     open detailIds;
     loop
        fetch detailIds into lExceptionDetailsId;
        exit when detailIds%NOTFOUND;
        if v_debug then
          log_message('deleting row='||lExceptionDetailsId);
        end if;
        Delete_Item(v_item_type,lExceptionDetailsId);
     end loop;
     close detailIds;
   end if;

    delete  from msc_x_exception_details
    where EXCEPTION_TYPE = l_exception_id
    and EXCEPTION_GROUP = -99;
   if v_debug then
      log_message('Number of records deleted from MSC_X_EXCEPTION_DETAILS ='||SQL%ROWCOUNT);
   end if;

   update  msc_item_exceptions
   set exception_count = 0
   where EXCEPTION_TYPE = l_exception_id
   and EXCEPTION_GROUP = -99;

  if v_debug then
     log_message('Number of records updated from MSC_ITEM_EXCEPTIONS = '||SQL%ROWCOUNT);
  end if;

 end if;
End DeletePreviousData;



Procedure insertExceptionSummary(l_exception_id in number) is
Cursor summaryRow is
select count(*)
from msc_item_exceptions
where EXCEPTION_TYPE = l_exception_id
and EXCEPTION_GROUP = -99;
lcount NUMBER := 0;
begin
  open summaryRow;
  fetch summaryRow into lcount;
  close summaryRow;

 if lcount = 0 then
  log_message('Inserting into msc_item_exceptions. Exception_type='||l_exception_id);
  insert into msc_item_exceptions(
   PLAN_ID,
   ORGANIZATION_ID,
   SR_INSTANCE_ID,
   INVENTORY_ITEM_ID,
   EXCEPTION_TYPE,
   EXCEPTION_COUNT,
   EXCEPTION_GROUP,
   LAST_UPDATE_DATE,
   LAST_UPDATED_BY,
   CREATION_DATE,
   CREATED_BY,
        REQUEST_ID,
        COMPANY_ID
       ) VALUES
     (
      -1,
      -1,
      -1,
      -1,
      l_exception_id,
      null,
      -99,
      sysdate,
      v_user_id,
      sysdate,
      v_user_id,
      v_request_id,
      v_company_id
      );
 elsif lcount > 1 then
   log_message('Data Error. More then 1 record exist in msc_item_exceptions');
   --rasie exception
 elsif lcount = 1 then
   if v_debug then
      log_message('1 record already exist already');
   end if;
 end if;
end insertExceptionSummary;



Procedure fetchAndInsertDetails is
  pItemKey        VARCHAR2(30);

lCounterTemp NUMBER := 1;
begin
 dateCounter := 0;
 numberCounter := 0;
 varchar2Counter := 0;
 vTotalNumberOfFetches := 0;

 vExceptionGroupName := MSC_X_USER_EXCEP_GEN.GET_MESSAGE_GROUP(-99);

 if v_notification_text is not null then
       v_notificationToken1  := getNotificationToken(v_notification_text, 1);
       v_notificationToken2  := getNotificationToken(v_notification_text,2);
       v_notificationToken3  := getNotificationToken(v_notification_text,3);
 end if;

 if v_debug then
        log_message('notificationToken1 ='||v_notificationToken1) ;
        log_message('notificationToken2 ='||v_notificationToken2) ;
        log_message('notificationToken3 ='||v_notificationToken3) ;
 end if;

 LOOP
   lCounterTemp  := 1;
   v_NumRows := DBMS_SQL.FETCH_ROWS(v_fetch_cursor);
   if v_debug then
      log_message('after fetch' );
   end if;
   vTotalFetchedRows  := dbms_sql.last_row_count;
   vTotalNumberOfFetches := vTotalNumberOfFetches + 1;

   if vTotalFetchedRows > 0 then
       v_exception_exist := 1;
   end if;

   if v_NumRows = 0 Then
     exit;
   end if;

   dateCounter := 0;
   numberCounter := 0;
   varchar2Counter := 0;

   if v_debug then
      log_message('Number of fetch = '||vTotalNumberOfFetches);
      if vTotalNumberOfFetches = 1 then
   log_message('Before column_value for select and bind array for insert');
      end if;
   end if;

   For columnCounter IN 1..DataTypeList.COUNT
   loop

     if AttributeTypeList(columnCounter) in ('SELECT','CALCULATION') then

      if DataTypeList(columnCounter) in ('DATE','DATETIME') then
         dateCounter := dateCounter + 1;
         DBMSSQLStep(dateCounter, 'DATE' , 'COLUMN_VALUE',lCounterTemp);
         DBMSSQLStep(dateCounter, 'DATE' , 'BIND_ARRAY',lCounterTemp);

      elsif DataTypeList(columnCounter) in ( 'NUMBER','AGGREGATE') then
         numberCounter := numberCounter + 1;
         DBMSSQLStep(numberCounter, 'NUMBER' , 'COLUMN_VALUE',lCounterTemp);
         DBMSSQLStep(numberCounter, 'NUMBER' , 'BIND_ARRAY',lCounterTemp);
      elsif DataTypeList(columnCounter) = 'VARCHAR2' then
         varchar2Counter := varchar2Counter + 1;
         DBMSSQLStep(varchar2Counter, 'VARCHAR2' , 'COLUMN_VALUE',lCounterTemp);
      DBMSSQLStep(varchar2Counter, 'VARCHAR2' , 'BIND_ARRAY',lCounterTemp);
           --this doesn't work
         --DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,getVarcharArray(varchar2Counter) );
      else
             --Datatype not correct
       FND_MESSAGE.SET_NAME('MSC', 'MSC_UDE_INCORRECT_DATA_TYPE');
             raise ExTerminateProgram;
      end if;
      lCounterTemp := lCounterTemp + 1;
    end if;

   end loop;

   --bind for transactions ids which are included by code
   if  vCompanyIdIncluded  then
     log_message('before COLUMN_VALUE for id. lCounterTemp='||lCounterTemp);
     DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,lCounterTemp,vTransactionId1);
     log_message('after COLUMN_VALUE for id. lCounterTemp='||lCounterTemp);
     DBMS_SQL.BIND_ARRAY(v_insert_cursor,':TRANSACTION_ID1',vTransactionId1,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
     log_message('after BIND_ARRAY for id. ');
     lCounterTemp := lCounterTemp + 1;
   end if;
   if vCustomerIdIncluded then
     DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,lCounterTemp,vTransactionId2);
     DBMS_SQL.BIND_ARRAY(v_insert_cursor,':TRANSACTION_ID2',vTransactionId2,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
     lCounterTemp := lCounterTemp + 1;
   end if;
   if vSupplierIdIncluded then
     DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,lCounterTemp,vTransactionId3);
     DBMS_SQL.BIND_ARRAY(v_insert_cursor,':TRANSACTION_ID3',vTransactionId3,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
   end if;

   -- other variables are binded. now bind who columns

   for i in 1..v_NumRows loop
      v_CREATED_BY(i) := v_user_id ;
      v_CREATION_DATE(i) := vLastUpdateDate;
      v_LAST_UPDATED_BY(i) := v_user_id;
      v_LAST_UPDATE_DATE(i) := vLastUpdateDate;
      select msc_x_exception_details_s.nextval into v_EXCEPTION_DETAIL_ID(i) from dual;
      vExceptionTypeArray(i)  := v_exception_id;
      vExceptionTypeNameArray(i) := v_exception_name;
      vExceptionGroupArray(i)    := -99;
      vExceptionGroupNameArray(i) := vExceptionGroupName;
      vOwningCompanyIdArray(i) := v_company_id;
   end loop;

   DBMS_SQL.BIND_ARRAY(v_insert_cursor,':CREATED_BY',v_CREATED_BY,1,v_NumRows);
   DBMS_SQL.BIND_ARRAY(v_insert_cursor,':CREATION_DATE',v_CREATION_DATE,1,v_NumRows);
   DBMS_SQL.BIND_ARRAY(v_insert_cursor,':LAST_UPDATED_BY',v_LAST_UPDATED_BY,1,v_NumRows);
   DBMS_SQL.BIND_ARRAY(v_insert_cursor,':LAST_UPDATE_DATE',v_LAST_UPDATE_DATE,1,v_NumRows);
   DBMS_SQL.BIND_ARRAY(v_insert_cursor,':EXCEPTION_DETAIL_ID',v_EXCEPTION_DETAIL_ID,1,v_NumRows);
   DBMS_SQL.BIND_ARRAY(v_insert_cursor,':EXCEPTION_TYPE',vExceptionTypeArray,1,v_NumRows);
   DBMS_SQL.BIND_ARRAY(v_insert_cursor,':EXCEPTION_TYPE_NAME',vExceptionTypeNameArray,1,v_NumRows);
   DBMS_SQL.BIND_ARRAY(v_insert_cursor,':EXCEPTION_GROUP',vExceptionGroupArray,1,v_NumRows);
   DBMS_SQL.BIND_ARRAY(v_insert_cursor,':EXCEPTION_GROUP_NAME',vExceptionGroupNameArray,1,v_NumRows);
   DBMS_SQL.BIND_ARRAY(v_insert_cursor,':OWNING_COMPANY_ID',vOwningCompanyIdArray,1,v_NumRows);


   -- for transaction exceptions,if it is not running for full load
   --  delete exceptions rows which
   --  returned by present run but already exist in exception details
  begin
   if vFullDataFlag <> 'Y' and
      vGroupByFlag <> 'Y'  then
      log_message('deleting record form msc_x_exception_details');
      if vCompanyIdIncluded then
          for i in 0..v_NumRows loop
           delete from msc_x_exception_details
             where EXCEPTION_TYPE  = v_exception_id
             and   EXCEPTION_GROUP = -99
             and   TRANSACTION_ID1 = vTransactionId1(i);
         end loop;
      elsif vSupplierIdIncluded Then
          for i in 0..v_NumRows loop
           delete from msc_x_exception_details
             where EXCEPTION_TYPE  = v_exception_id
             and   EXCEPTION_GROUP = -99
             and   TRANSACTION_ID2 = vTransactionId2(i);
         end loop;
     elsif vCustomerIdIncluded Then
          for i in 0..v_NumRows loop
             delete from msc_x_exception_details
             where EXCEPTION_TYPE  = v_exception_id
             and   EXCEPTION_GROUP = -99
             and   TRANSACTION_ID3 = vTransactionId3(i);
         end loop;
     end if;
  end if;
  exception
   when NO_DATA_FOUND then
    null;
 end;
     -- execute the insert statement
    if v_debug and vTotalNumberOfFetches = 1 Then
      log_message('Before insert execution ');
    end if;
    v_ReturnCode := DBMS_SQL.EXECUTE(v_insert_cursor);

    if v_debug and vTotalNumberOfFetches = 1 Then
      log_message('number of records inserted='||v_ReturnCode);
    end if;


    Commit;

 -- here we can launch workflow for each inserted record;
 -- all data is taken from memory rather reading again from detail table after commit

    if (v_item_type is not null and
   v_wf_process is not null) then

        launchWorkFlow;
    else

      if vTotalNumberOfFetches = 1 then
         log_message('No workflow launched as workflow is not specified in exception definition');
      end if;

    end if;


    EXIT when v_NumRows < vBatchSize;

 END LOOP;


  log_message('Total number of exception  ='||to_char(vTotalFetchedRows) );
  DBMS_SQL.CLOSE_CURSOR(v_fetch_cursor);
  DBMS_SQL.CLOSE_CURSOR(v_insert_cursor);

end fetchAndInsertDetails;

Procedure deleteResolvedExceptions is
  lDeletSqlStr VARCHAR2(4000);
  lTransactionIdDetName1  Varchar2(50);
  lViewName  Varchar2(50);
  lFromView  Varchar2(50);

begin
if vFullDataFlag  <> 'Y' and
     vGroupByFlag <> 'Y' then
  capsString := null;
  capsString := upper(vWhereStmt||vSelectStmt);
  if instr(capsString,'COMPANY.') <> 0 then
     lViewName  := 'COMPANY';
     lTransactionIdDetName1  := 'transaction_id1';
     lFromView := ' from msc_sup_dem_ent_custom_ex_v COMPANY';
  elsIf instr(capsString,'SUPPLIER.')  <> 0 then
     lViewName  := 'SUPPLIER';
   lTransactionIdDetName1  := 'transaction_id3';
     lFromView := ' from msc_sup_dem_ent_custom_ex_v SUPPLIER';
  elsif instr(capsString,'CUSTOMER.') <> 0 then
    lViewName  := 'CUSTOMER';
    lTransactionIdDetName1  := 'transaction_id2';
    lFromView := ' from msc_sup_dem_ent_custom_ex_v CUSTOMER';
  end if;

  lDeletSqlStr := 'delete from msc_x_exception_details edtl where edtl.exception_type = :lExceptionType '||
   ' and edtl.exception_group = -99 and edtl.last_update_date <> :vLastUpdateDate  '||
   ' and edtl.'||lTransactionIdDetName1||' in '||
        ' ( select '||lviewName||'.'||'transaction_id '|| lFromView ||' where '||v_addedWhereClause ||
   ')';



   dumpStmt('lDeletSqlStr='||lDeletSqlStr );


   execute immediate lDeletSqlStr
   using v_exception_id,vLastUpdateDate,
   v_company_id,v_company_id,v_company_id;

  log_message('Number of exceptions resolved ='||SQL%ROWCOUNT);

end if;
End deleteResolvedExceptions  ;

Procedure updateExceptionSummary is
begin
  update msc_item_exceptions
  set EXCEPTION_COUNT = (select count(*)
         from msc_x_exception_details
         where EXCEPTION_TYPE = v_exception_id
                        and EXCEPTION_GROUP = -99 )
  where EXCEPTION_TYPE = v_exception_id
  and EXCEPTION_GROUP = -99;

  update MSC_USER_EXCEPTIONS
  set
        LAST_RUN_DATE = sysdate
       ,REFRESH_NUMBER = vNewExRefreshNumber
       ,REQUEST_ID     = v_request_id
  where EXCEPTION_ID = v_exception_id;


end updateExceptionSummary;
 /*
      a. Extract notification tokens
   b.    c. see whether rows are returned
      d. for each row:
     1. build notification title
     2. launch workflow
      e. for each column in fetched row
     1. if its not a user calculation, find the db column name and populate the wf attributes
     2. if it is user calculation, create wf attribut dynamically and populate

 */

Procedure launchWorkFlow is

l_item_key        VARCHAR2(80) ;
wf_attribute_name    VARCHAR2(30);
l_temp_position      NUMBER;
l_temp         VARCHAR2(100);
details_url       VARCHAR2(1000);
l_Report_Run_str  VARCHAR2(200);
saveThreshold     NUMBER;
lFunctionId    NUMBER;
 columnNtfTableHeader   VARCHAR2(4000);
 columnNtfRowValue      VARCHAR2(4000);
 wfattrvalue             Varchar2(300);
selectCounter  Number;

begin
 columnNtfTableHeader := null;
 columnNtfRowValue   := null;
 vNtfBodyText         := null;

 saveThreshold := WF_ENGINE.threshold;

 If v_NumRows <> 0  Then

   For rowCounter in 1..v_NumRows
   LOOP
        if vTotalNumberOfFetches = 1 and
           rowCounter = 1 then
           vFirstRow := TRUE;
        else
           vFirstRow := FALSE;
        end if;

         -- item key. we are going to use exception_detail_id as item key.
         l_item_key  := to_char( v_EXCEPTION_DETAIL_ID(rowCounter));
         v_notificationTitle  := v_notification_text;


         --WF_ENGINE.threshold := -1;

         if v_debug and
            vFirstRow then
            log_message('Before creating workflow  = '||v_item_type);
            log_message('Workflow item_key  = '||l_item_key);
         end if;

         wf_engine.CreateProcess(  itemtype => v_item_type,
                                 itemkey  => l_item_key,
                                 process  => v_wf_process );

         if v_debug and
            vFirstRow then
            log_message('After creating workflow  = '||v_item_type);
         end if;
         -- Set the process owner to user who defined this exception

         wf_engine.SetItemOwner( itemtype  => v_item_type,
                                  itemkey  => l_item_key,
                                  owner    => v_created_by_name );



    dateCounter := 0;
    numberCounter := 0;
    varchar2Counter := 0;
         selectCounter := 0;
   columnNtfTableHeader := null;
        columnNtfRowValue    := null;

         For columnCounter IN 1..ColumnNameList.COUNT
         LOOP

           if AttributeTypeList(columnCounter) in ('SELECT','CALCULATION') then

              selectCounter := selectCounter +1;
              if AttributeTypeList(columnCounter) =  'SELECT' Then
                  -- attributes are named as p.db_column_name, s.db_column_name and
                  --c.db_column_name in workflow as internal name cannot be greater then 30 in wf
                     l_temp_position  := INSTR(ColumnNameList(columnCounter),'.');
                     l_temp := substr(ColumnNameList(columnCounter),1,l_temp_position-1 );

                    if upper(l_temp) = 'COMPANY' Then
                       wf_attribute_name := 'P.'||substr(ColumnNameList(columnCounter),l_temp_position+1,28) ;
                    elsif upper(l_temp) = 'SUPPLIER' Then
                       wf_attribute_name := 'S.'||substr(ColumnNameList(columnCounter),l_temp_position+1,28) ;
                    elsif upper(l_temp) = 'CUSTOMER' Then
                       wf_attribute_name := 'C.'||substr(ColumnNameList(columnCounter),l_temp_position+1,28) ;
                    end if;
              else
                    --wf_attribute_name := DisplayLableList(columnCounter);
                    wf_attribute_name := CalculationNameList(columnCounter);

              end if;

              InitializeWfVariables(
         v_item_type,
         l_item_key,
         wf_attribute_name,
         rowCounter,
         columnCounter,
                        selectCounter,
                        wfAttrValue);
             if wfAttrValue is null then
               wfAttrValue := '&'||'nbsp;';
             end if;

            if AttributeTypeList(columnCounter) = 'SELECT' Then
               columnNtfTableHeader  := columnNtfTableHeader||'<td>'||DisplayLableList(columnCounter)||'</td>';
            else
                /* calculation */
               columnNtfTableHeader  := columnNtfTableHeader||'<td>'||CalculationNameList(columnCounter)||'</td>';
            end if;

             columnNtfRowValue := columnNtfRowValue||'<td>'||wfAttrValue||'</td>';


           end if;

       end loop; -- columnCounter loop

       fnd_message.set_name('MSC','MSC_UDE_NTFBOD');
       fnd_message.set_token('EXCEPTION',v_exception_name);
       fnd_message.set_token('CREATION_DATE',vLastUpdateDate);

       vNtfBodyText := '<br> '||fnd_message.get||'</br>'||
                  '<table BORDER  WIDTH="100%" > '||
                       '<tr>'||columnNtfTableHeader||'</tr>'||
                  '<tr>'||columnNtfRowValue||'</tr>';

       wf_engine.SetItemAttrText ( itemtype      => v_item_type,
                                   itemkey       => l_item_key,
                                   aname         => 'NOTIFICATION_TITLE' ,
                                   avalue        => v_notificationTitle );

       wf_engine.SetItemAttrText ( itemtype      => v_item_type,
                                   itemkey       => l_item_key,
                                   aname         => 'NTF_BODY' ,
                                   avalue        => vNtfBodyText );
       if v_debug and
            vFirstRow then
            log_message('notificationTitle='||v_notificationTitle);
            --log_message('notificationText='||vNtfBodyText);
            dumpstmt('notificationText='||vNtfBodyText);
       end if;

       wf_engine.SetItemAttrText ( itemtype      => v_item_type,
                                   itemkey       => l_item_key,
                                   aname         => 'EXCEPTION_TYPE_NAME' ,
                                   avalue        => v_exception_name );


       wf_engine.SetItemAttrNumber ( itemtype        => v_item_type,
                                     itemkey         => l_item_key,
                                     aname           => 'EXCEPTION_TYPE' ,
                                     avalue          => v_exception_id );

       wf_engine.SetItemAttrNumber ( itemtype        => v_item_type,
                                     itemkey         => l_item_key,
                                     aname           => 'EXCEPTION_EXIST' ,
                                     avalue          => v_exception_exist );

       wf_engine.SetItemAttrNumber ( itemtype        => v_item_type,
                                     itemkey         => l_item_key,
                                     aname           => 'EXCEPTION_DETAIL_ID' ,
                                     avalue          => v_EXCEPTION_DETAIL_ID(rowCounter) );
       details_url :=
       'JSP:/OA_HTML/OA.jsp?akRegionCode=MSCXEXCEPDETAILSMAIN'||'&'||'akRegionApplicationId=724'||
         '&'||'OAFunc=MSC_EXCEPTION_DETAILS'||
                '&'||'exceptionTypeIds='||to_char(v_exception_id)||'&'||
                 'comingFrom=EXCEPTIONSUMMARY'||'&'||'addBreadCrumbs=Y';

             -- 'exceptiodDetailId='||to_char(v_EXCEPTION_DETAIL_ID(rowCounter));

    /* select fnd_profile.VALUE_SPECIFIC('APPS_WEB_AGENT',v_user_id)
    into details_url from dual;

    Select function_id into lFunctionId
    from fnd_form_functions
    where function_name = 'MSC_EXCEPTION_DETAILS';

         l_Report_Run_str := icx_call.encrypt2(
                                           724
                                           ||'*'
                                           ||v_resp_id
                                           ||'*'
                                           ||icx_sec.g_security_group_id
                                           ||'*'
                                           ||lFunctionId
                                           ||'**]'
                                           , icx_sec.getID(icx_sec.PV_SESSION_ID)
                                           );

       details_url :=  details_url||'/OracleApps.RF?F='||l_Report_Run_str; */
       log_message('oa details_url='||details_url);
       wf_engine.SetItemAttrText ( itemtype        => v_item_type,
                                     itemkey         => l_item_key,
                                     aname           => 'DETAILS_URL',
                                     avalue          => details_url );



       if v_debug and
          vFirstRow then
            log_message('Before starting workflow process. Key='|| l_item_key  );
       end if;

       wf_engine.StartProcess( itemtype => v_item_type,
                               itemkey  => l_item_key );


       if v_debug and
          vFirstRow then
            log_message('after starting workflow process. Key='|| l_item_key  );
       end if;

       WF_ENGINE.threshold := saveThreshold;

     end loop;  --v_NumRows

 end if;  -- v_NumRows <> 0

EXCEPTION
     WHEN OTHERS THEN
          Wf_Core.Context('MSC_USER_DEFINED_EXCEPTION',
                      'launchWorkFlow', v_item_type, l_item_key);
          --Wf_Core.Get_Error(err_name,err_msg,err_stack);
          Raise;
end launchWorkFlow;

function getNotificationToken(v_notification_text IN VARCHAR2,
                                        tokenNumber in Number) return Number is
l_position_of_sep   number := 0;
l_token_number      Number  := -1;
lTempNumber1        VARCHAR2(1);
lTempNumber2        VARCHAR2(1);
begin
    l_position_of_sep    :=  instr(v_notification_text,vNotificationSep,1,tokenNumber);


    if l_position_of_sep <> 0 Then
        lTempNumber1 := substr(v_notification_text,l_position_of_sep+1,1);
        if lTempNumber1 in ( '0','1','2','3','4','5','6','7','8','9') then
           lTempNumber2 := substr(v_notification_text,l_position_of_sep+2,1);
           if lTempNumber2 not in ( '0','1','2','3','4','5','6','7','8','9') then
              lTempNumber2 := NULL;
           end if;
        else
           --l_token_number := -1;
           --log_message('Notification token'||tokenNumber||' not specified correctly');
           fnd_message.set_name('MSC','MSC_UDE_NTFTOK_ERR');
           fnd_message.set_token('TOKENNUMBER',tokenNumber);
           raise ExTerminateProgram;
        end if;
        l_token_number := to_number(lTempNumber1||lTempNumber2);
        if l_token_number > 30 then
           fnd_message.set_name('MSC','MSC_UDE_NTFTOK_BIG');
           fnd_message.set_token('TOKENNUMBER',tokenNumber);
           raise ExTerminateProgram;
        end if;
    else
       log_message('Notification tokens'||tokenNumber||' not specified ');
    end if;


    return(l_token_number);

end getNotificationToken;

Procedure InitializeWfVariables(v_item_type IN VARCHAR2,
            l_item_key IN VARCHAR2 ,
            wfAttributeName IN VARCHAR2,
            rowCounter  in number,
            columnCounter in number,
            selectCounter in number,
                                wfAttrValue   out NOCOPY varchar2) is

l_DateValue DATE;
l_NumberValue  NUMBER;
l_VarcharValue VARCHAR2(2000);
l_SelValue     VARCHAR2(2000);

begin

   if DataTypeList(columnCounter) = 'DATE' then
      dateCounter := dateCounter + 1;
      l_dateValue := DateValue(dateCounter,rowCounter) ;
      l_SelValue  := to_char(l_dateValue);

      if v_debug and
         vFirstRow then
         log_message('Initializing wk flow Date attribute='||wfAttributeName ||
                      ' Value='||to_char(l_dateValue) );
      end if;
      if AttributeTypeList(columnCounter) =  'SELECT' then
         wf_engine.SetItemAttrDate ( itemtype        => v_item_type,
                                     itemkey         => l_item_key,
                                     aname           => wfAttributeName ,
                                     avalue          => l_dateValue );
      elsif AttributeTypeList(columnCounter) =  'CALCULATION' then
          wf_engine.AddItemAttr ( itemtype        => v_item_type,
                                  itemkey         => l_item_key,
                                  aname           => wfAttributeName ,
                                  date_value      => l_dateValue);
      end if;
   elsif DataTypeList(columnCounter) in ( 'NUMBER','AGGREGATE')  then
      if v_debug and
         vFirstRow then
          log_message('Initializing number/aggregate wk flow attribute='||wfAttributeName ||
         ' Value='||to_char(l_numberValue) );
      end if;

      numberCounter := numberCounter + 1;
      l_numberValue := NumberValue(numberCounter,rowCounter);
      l_SelValue  := to_char(l_numberValue);
      if AttributeTypeList(columnCounter) =  'SELECT' then

         wf_engine.SetItemAttrNumber ( itemtype        => v_item_type,
                                     itemkey         => l_item_key,
                                     aname           => wfAttributeName ,
                                     avalue          => l_SelValue );

      elsif AttributeTypeList(columnCounter) =  'CALCULATION' then

          wf_engine.AddItemAttr ( itemtype        => v_item_type,
                                  itemkey         => l_item_key,
                                  aname           => wfAttributeName ,
                                  number_value      => l_numberValue);
      end if;


   elsif DataTypeList(columnCounter) = 'VARCHAR2' then

      varchar2Counter := varchar2Counter + 1;
      l_varcharValue := VarcharValue(varchar2Counter,rowCounter);
      l_SelValue  := l_varcharValue;
      if v_debug and
         vFirstRow  then
          log_message('Initializing varchar wk flow attribute='||wfAttributeName ||
            ' Value='||l_varcharValue );
      end if;
      if AttributeTypeList(columnCounter) =  'SELECT' then

         wf_engine.SetItemAttrText ( itemtype        => v_item_type,
                                     itemkey         => l_item_key,
                                     aname           => wfAttributeName ,
                                     avalue          => l_varcharValue );

      elsif AttributeTypeList(columnCounter) =  'CALCULATION' then

          wf_engine.AddItemAttr ( itemtype        => v_item_type,
                                  itemkey         => l_item_key,
                                  aname           => wfAttributeName ,
                                  text_value      => l_varcharValue);

      end if;


  end if;

   wfAttrValue := l_SelValue;
    log_message( 'col_counter = '||selectCounter||' and tok1='||v_notificationToken1||' and tok2='||v_notificationToken2);
   if     selectCounter = v_notificationToken1 OR
          selectCounter = v_notificationToken2 OR
          selectCounter = v_notificationToken3 Then

          v_notificationTitle := substr(replace(v_notificationTitle ,
               vNotificationSep||to_char(selectCounter),
                                        l_SelValue),
               1,2000 );
        if v_debug then
         log_message('substitued value='||l_SelValue);
         log_message('after sub nottittl='||v_notificationTitle);
        end if;
  end if;


EXCEPTION
     WHEN OTHERS THEN
          Wf_Core.Context('MSC_USER_DEFINED_EXCEPTION',
                      'InitializeWfVariables', v_item_type, l_item_key);
          --Wf_Core.Get_Error(err_name,err_msg,err_stack);
          Raise;


end InitializeWfVariables;

Procedure parseStmt(l_cursor in number, Stmt IN VARCHAR2) is
errorPos     Number := -1;
begin
  dumpStmt(Stmt);
  DBMS_SQL.PARSE(l_cursor,Stmt, DBMS_SQL.native);
exception
   when others then
      errorPos := DBMS_SQL.last_error_position;
      if errorPos > 0 then
        log_message(substr(Stmt,1,errorPos)||'^^^^^');
     FND_MESSAGE.SET_NAME('MSC','MSC_UDE_PARSE_ERROR');
     FND_MESSAGE.SET_TOKEN('ERRPOS',to_char(errorPos) );

        log_message('Error occured at position = '||to_char(errorPos));
      end if;

      raise;
end parseStmt;


Function modifyWhereForThreshold(pExceptionId in number,pWhereCondition in varchar2) return VARCHAR2 is
 pmfLabel Varchar2(30) := upper(vPMFLabel);
 lpos       Number := 0;
 firstBracket  Number := 0;
 secondBracket    Number := 0;
 pmfstring      Varchar2(50) := null;
 stringToReplace VARCHAR2(100);
 replaceString   VARCHAR2(1000);
 replacedWhere   VARCHAR2(4000);
tempNumber  NUMBER;
begin
  lpos := -1;
  capsString := null;
  replacedWhere := pWhereCondition;
  while (lpos <> 0)
  LOOP
    capsString := upper(replacedWhere);
    lpos := INSTR(capsString,vPMFLabel,1,1);

    if v_debug then
       log_message('pmf label location='||lpos);
    end if;
    if lpos <> 0 then

      firstBracket := INSTR(capsString,'(', lpos+length(vPMFLabel),1 );
      secondBracket := INSTR(capsString,')', lpos+length(vPMFLabel),1 );

      if v_debug then
         log_message('pmf firstBracket='||firstBracket);
         log_message('pmf secondBracket='||secondBracket);
      end if;
      if firstBracket <> 0 and secondBracket <> 0 then
          --stringToReplace := pmfLabel||substr(replacedWhere,firstBracket,secondBracket - firstBracket+1);
          stringToReplace := substr(replacedWhere,lpos,length(vPMFLabel)+secondBracket-firstBracket+1);
          log_message('stringToReplace='||stringToReplace);
          pmfstring    :=  substr(replacedWhere,firstBracket+1,secondBracket-firstBracket-1);
          pmfstring    := ltrim(rtrim(pmfstring));
          if pmfstring is null or pmfstring = '' then
            -- for custom exceptions
             pmfstring := pExceptionId;
          end if;
          begin
             tempNumber := to_number(pmfstring);
          exception
          when others then
              --its not a seeded pmf but custom pmf
              --pmfstring := ''''||pmfstring||'''';
             raise ExTerminateProgram;
          end;
      else
         raise ExTerminateProgram;
      end if;

      replaceString := 'MSC_PMF_PKG.get_Threshold('||pmfstring||','||
             'COMPANY.PUBLISHER_ID,COMPANY.PUBLISHER_SITE_ID,COMPANY.INVENTORY_ITEM_ID,'||
        'COMPANY.SUPPLIER_ID,COMPANY.SUPPLIER_SITE_ID,COMPANY.CUSTOMER_ID,COMPANY.CUSTOMER_SITE_ID';
      -- till it is not finalised we are goingto pass null for date.
      -- once it is finalized, we need to pass data depending upon seeded pmf
       replaceString := replaceString ||',NULL ) ';

      if v_debug then
         log_message('threshold replace string='||replaceString);
      end if;

      replacedWhere := Replace(replacedWhere,stringToReplace,replaceString);
   end if;
 end loop;

 return(replacedWhere);
 EXCEPTION
   when ExTerminateProgram then
       --  log_message( 'Threshold condition not specified correctly');
         FND_MESSAGE.SET_NAME('MSC', 'MSC_UDE_THRESHOLDERROR');
         raise;
end modifyWhereForThreshold;

--------------------------------------------------------------------------
-- Function GET_MESSAGE_GROUP
----------------------------------------------------------------------
FUNCTION GET_MESSAGE_GROUP(p_exception_group in Number) RETURN Varchar2 IS
    l_message_group   Varchar2(100);
BEGIN

        select meaning
        into    l_message_group
        from    fnd_lookup_values
        where   lookup_type = 'MSC_X_EXCEPTION_GROUP'
        and     lookup_code = p_exception_group
        and     language = userenv('LANG')  ;

        return l_message_group;
EXCEPTION
         when others then
                l_message_group := null;

END get_message_group;


Procedure DBMSSQLStep(DataArrayCounter in Number, data_type IN VARCHAR2,
               dbms_call IN VARCHAR2, columnCounter in number)  IS

sql_stmt VARCHAR2(2000) := null;

begin
   if v_debug then
         log_message('DataArrayCounter='||to_char(DataArrayCounter)||
          ' data type='||data_type||' dbmscall='||dbms_call);
   end if;

       if DataArrayCounter = 1 then

          if dbms_call = 'DEFINE_ARRAY' then
            if data_type in ( 'DATE','DATETIME') then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_Date1,vBatchSize,1);
            elsif data_type  = 'NUMBER' then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_number1,vBatchSize,1);
            elsif data_type = 'VARCHAR2' then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_varchar1,vBatchSize,1);
            end if;
          elsif dbms_call = 'COLUMN_VALUE' Then
            if data_type in ( 'DATE','DATETIME') then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_Date1);
            elsif data_type  = 'NUMBER' then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_number1);
            elsif data_type = 'VARCHAR2' then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_varchar1);
            end if;
          elsif dbms_call = 'BIND_ARRAY' Then
            if data_type in ( 'DATE','DATETIME') then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_Date1,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            elsif data_type = 'VARCHAR2' then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_varchar1,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            elsif data_type  = 'NUMBER' then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_number1,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            end if;
          end if;

       elsif DataArrayCounter =  2 then

          if dbms_call = 'DEFINE_ARRAY' then
            if data_type in ( 'DATE','DATETIME') then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_Date2,vBatchSize,1);
            elsif data_type = 'VARCHAR2' then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_varchar2,vBatchSize,1);
            elsif data_type  = 'NUMBER' then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_number2,vBatchSize,1);
            end if;
          elsif dbms_call = 'COLUMN_VALUE' Then
            if data_type in ( 'DATE','DATETIME') then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_Date2);
            elsif data_type = 'VARCHAR2' then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_varchar2);
            elsif data_type  = 'NUMBER' then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_number2);
            end if;

          elsif dbms_call = 'BIND_ARRAY' Then

            if data_type in ( 'DATE','DATETIME') then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_Date2,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            elsif data_type = 'VARCHAR2' then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_varchar2,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            elsif data_type  = 'NUMBER' then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_number2,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            end if;

          end if;

       elsif DataArrayCounter =  3 then
          if dbms_call = 'DEFINE_ARRAY' then
            if data_type in ( 'DATE','DATETIME') then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_Date3,vBatchSize,1);
            elsif data_type = 'VARCHAR2' then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_varchar3,vBatchSize,1);
            elsif data_type  = 'NUMBER' then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_number3,vBatchSize,1);
            end if;
          elsif dbms_call = 'COLUMN_VALUE' Then
            if data_type in ( 'DATE','DATETIME') then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_Date3);
            elsif data_type = 'VARCHAR2' then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_varchar3);
            elsif data_type  = 'NUMBER' then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_number3);
            end if;

          elsif dbms_call = 'BIND_ARRAY' Then

            if data_type in ( 'DATE','DATETIME') then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_Date3,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            elsif data_type = 'VARCHAR2' then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_varchar3,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            elsif data_type  = 'NUMBER' then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_number3,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            end if;

          end if;

       elsif DataArrayCounter =  4 then

          if dbms_call = 'DEFINE_ARRAY' then
            if data_type in ( 'DATE','DATETIME') then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_Date4,vBatchSize,1);
            elsif data_type = 'VARCHAR2' then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_varchar4,vBatchSize,1);
            elsif data_type  = 'NUMBER' then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_number4,vBatchSize,1);
            end if;
          elsif dbms_call = 'COLUMN_VALUE' Then
            if data_type in ( 'DATE','DATETIME') then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_Date4);
            elsif data_type = 'VARCHAR2' then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_varchar4);
            elsif data_type  = 'NUMBER' then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_number4);
            end if;

          elsif dbms_call = 'BIND_ARRAY' Then

            if data_type in ( 'DATE','DATETIME') then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_Date4,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            elsif data_type = 'VARCHAR2' then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_varchar4,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            elsif data_type  = 'NUMBER' then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_number4,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            end if;

          end if;
     elsif DataArrayCounter =  5 then

          if dbms_call = 'DEFINE_ARRAY' then
            if data_type in ( 'DATE','DATETIME') then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_Date5,vBatchSize,1);
            elsif data_type = 'VARCHAR2' then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_varchar5,vBatchSize,1);
            elsif data_type  = 'NUMBER' then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_number5,vBatchSize,1);
            end if;
          elsif dbms_call = 'COLUMN_VALUE' Then
            if data_type in ( 'DATE','DATETIME') then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_Date5);
            elsif data_type = 'VARCHAR2' then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_varchar5);
            elsif data_type  = 'NUMBER' then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_number5);
            end if;

          elsif dbms_call = 'BIND_ARRAY' Then

            if data_type in ( 'DATE','DATETIME') then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_Date5,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            elsif data_type = 'VARCHAR2' then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_varchar5,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            elsif data_type  = 'NUMBER' then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_number5,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            end if;

          end if;

    elsif DataArrayCounter =  6 then

          if dbms_call = 'DEFINE_ARRAY' then
            if data_type in ( 'DATE','DATETIME') then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_Date6,vBatchSize,1);
            elsif data_type = 'VARCHAR2' then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_varchar6,vBatchSize,1);
            elsif data_type  = 'NUMBER' then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_number6,vBatchSize,1);
            end if;
          elsif dbms_call = 'COLUMN_VALUE' Then
            if data_type in ( 'DATE','DATETIME') then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_Date6);
            elsif data_type = 'VARCHAR2' then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_varchar6);
            elsif data_type  = 'NUMBER' then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_number6);
            end if;

          elsif dbms_call = 'BIND_ARRAY' Then

            if data_type in ( 'DATE','DATETIME') then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_Date6,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            elsif data_type = 'VARCHAR2' then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_varchar6,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            elsif data_type  = 'NUMBER' then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_number6,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            end if;

          end if;
    elsif DataArrayCounter = 7 then

         if dbms_call = 'DEFINE_ARRAY' then
            if data_type in ( 'DATE','DATETIME') then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_Date7,vBatchSize,1);
            elsif data_type = 'VARCHAR2' then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_varchar7,vBatchSize,1);
            elsif data_type  = 'NUMBER' then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_number7,vBatchSize,1);
            end if;
          elsif dbms_call = 'COLUMN_VALUE' Then
            if data_type in ( 'DATE','DATETIME') then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_Date7);
            elsif data_type = 'VARCHAR2' then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_varchar7);
            elsif data_type  = 'NUMBER' then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_number7);
            end if;

          elsif dbms_call = 'BIND_ARRAY' Then

            if data_type in ( 'DATE','DATETIME') then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_Date7,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            elsif data_type = 'VARCHAR2' then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_varchar7,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            elsif data_type  = 'NUMBER' then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_number7,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            end if;

          end if;


   elsif DataArrayCounter = 8 then
          if dbms_call = 'DEFINE_ARRAY' then
            If data_type = 'VARCHAR2' then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_varchar8,vBatchSize,1);
            elsif data_type  = 'NUMBER' then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_number8,vBatchSize,1);
            end if;
          elsif dbms_call = 'COLUMN_VALUE' Then
           if data_type = 'VARCHAR2' then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_varchar8);
            elsif data_type  = 'NUMBER' then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_number8);
            end if;

          elsif dbms_call = 'BIND_ARRAY' Then
            if data_type = 'VARCHAR2' then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_varchar8,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            elsif data_type  = 'NUMBER' then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_number8,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            end if;

          end if;

      elsif DataArrayCounter = 9 then
          if dbms_call = 'DEFINE_ARRAY' then
            If data_type = 'VARCHAR2' then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_varchar9,vBatchSize,1);
            elsif data_type  = 'NUMBER' then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_number9,vBatchSize,1);
            end if;
          elsif dbms_call = 'COLUMN_VALUE' Then
           if data_type = 'VARCHAR2' then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_varchar9);
            elsif data_type  = 'NUMBER' then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_number9);
            end if;

          elsif dbms_call = 'BIND_ARRAY' Then
            if data_type = 'VARCHAR2' then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_varchar9,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            elsif data_type  = 'NUMBER' then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_number9,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            end if;

          end if;

   elsif DataArrayCounter = 10 then
          if dbms_call = 'DEFINE_ARRAY' then
            If data_type = 'VARCHAR2' then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_varchar10,vBatchSize,1);
            elsif data_type  = 'NUMBER' then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_number10,vBatchSize,1);
            end if;
          elsif dbms_call = 'COLUMN_VALUE' Then
           if data_type = 'VARCHAR2' then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_varchar10);
            elsif data_type  = 'NUMBER' then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_number10);
            end if;

          elsif dbms_call = 'BIND_ARRAY' Then
            if data_type = 'VARCHAR2' then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_varchar10,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            elsif data_type  = 'NUMBER' then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_number10,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            end if;

          end if;

   elsif DataArrayCounter = 11 then
          if dbms_call = 'DEFINE_ARRAY' then
            If data_type = 'VARCHAR2' then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_varchar11,vBatchSize,1);
            end if;
          elsif dbms_call = 'COLUMN_VALUE' Then
           if data_type = 'VARCHAR2' then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_varchar11);
            end if;
          elsif dbms_call = 'BIND_ARRAY' Then
            if data_type = 'VARCHAR2' then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_varchar11,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            end if;
          end if;
   elsif DataArrayCounter = 12 then
          if dbms_call = 'DEFINE_ARRAY' then
            If data_type = 'VARCHAR2' then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_varchar12,vBatchSize,1);
            end if;
          elsif dbms_call = 'COLUMN_VALUE' Then
           if data_type = 'VARCHAR2' then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_varchar12);
            end if;
          elsif dbms_call = 'BIND_ARRAY' Then
            if data_type = 'VARCHAR2' then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_varchar12,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            end if;
          end if;
   elsif DataArrayCounter = 13 then
          if dbms_call = 'DEFINE_ARRAY' then
            If data_type = 'VARCHAR2' then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_varchar13,vBatchSize,1);
            end if;
          elsif dbms_call = 'COLUMN_VALUE' Then
           if data_type = 'VARCHAR2' then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_varchar13);
            end if;
          elsif dbms_call = 'BIND_ARRAY' Then
            if data_type = 'VARCHAR2' then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_varchar13,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            end if;
          end if;
        elsif DataArrayCounter = 14 then
          if dbms_call = 'DEFINE_ARRAY' then
            If data_type = 'VARCHAR2' then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_varchar14,vBatchSize,1);
            end if;
          elsif dbms_call = 'COLUMN_VALUE' Then
           if data_type = 'VARCHAR2' then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_varchar14);
            end if;
          elsif dbms_call = 'BIND_ARRAY' Then
            if data_type = 'VARCHAR2' then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_varchar14,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            end if;
          end if;
        elsif DataArrayCounter = 15 then
          if dbms_call = 'DEFINE_ARRAY' then
            If data_type = 'VARCHAR2' then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_varchar15,vBatchSize,1);
            end if;
          elsif dbms_call = 'COLUMN_VALUE' Then
           if data_type = 'VARCHAR2' then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_varchar15);
            end if;
          elsif dbms_call = 'BIND_ARRAY' Then
            if data_type = 'VARCHAR2' then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_varchar15,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            end if;
          end if;
        elsif DataArrayCounter = 16 then
          if dbms_call = 'DEFINE_ARRAY' then
            If data_type = 'VARCHAR2' then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_varchar16,vBatchSize,1);
            end if;
          elsif dbms_call = 'COLUMN_VALUE' Then
           if data_type = 'VARCHAR2' then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_varchar16);
            end if;
          elsif dbms_call = 'BIND_ARRAY' Then
            if data_type = 'VARCHAR2' then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_varchar16,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            end if;
          end if;
        elsif DataArrayCounter = 17 then
          if dbms_call = 'DEFINE_ARRAY' then
            If data_type = 'VARCHAR2' then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_varchar17,vBatchSize,1);
            end if;
          elsif dbms_call = 'COLUMN_VALUE' Then
           if data_type = 'VARCHAR2' then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_varchar17);
            end if;
          elsif dbms_call = 'BIND_ARRAY' Then
            if data_type = 'VARCHAR2' then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_varchar17,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            end if;
          end if;
        elsif DataArrayCounter = 18 then
          if dbms_call = 'DEFINE_ARRAY' then
            If data_type = 'VARCHAR2' then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_varchar18,vBatchSize,1);
            end if;
          elsif dbms_call = 'COLUMN_VALUE' Then
           if data_type = 'VARCHAR2' then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_varchar18);
            end if;
          elsif dbms_call = 'BIND_ARRAY' Then
            if data_type = 'VARCHAR2' then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_varchar18,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            end if;
          end if;
        elsif DataArrayCounter = 19 then
          if dbms_call = 'DEFINE_ARRAY' then
            If data_type = 'VARCHAR2' then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_varchar19,vBatchSize,1);
            end if;
          elsif dbms_call = 'COLUMN_VALUE' Then
           if data_type = 'VARCHAR2' then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_varchar19);
            end if;
          elsif dbms_call = 'BIND_ARRAY' Then
            if data_type = 'VARCHAR2' then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_varchar19,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            end if;
          end if;
        elsif DataArrayCounter = 20 then
          if dbms_call = 'DEFINE_ARRAY' then
            If data_type = 'VARCHAR2' then
              DBMS_SQL.DEFINE_ARRAY(v_fetch_cursor,columnCounter,v_varchar20,vBatchSize,1);
            end if;
          elsif dbms_call = 'COLUMN_VALUE' Then
           if data_type = 'VARCHAR2' then
              DBMS_SQL.COLUMN_VALUE(v_fetch_cursor,columnCounter,v_varchar20);
            end if;
          elsif dbms_call = 'BIND_ARRAY' Then
            if data_type = 'VARCHAR2' then
              DBMS_SQL.BIND_ARRAY(v_insert_cursor,':A'||to_char(columnCounter), v_varchar20,vTotalFetchedRows-v_NumRows+1,vTotalFetchedRows);
            end if;
          end if;

   end if;
         log_message('completed DataArrayCounter='||to_char(DataArrayCounter)||'dbms_call='||dbms_call);
end   DBMSSQLStep;

Procedure dumpStmt(Stmt IN VARCHAR2) is
len  NUMBER :=0;
counter1 NUMBER;

begin
if  v_request_id  > 0 then
   log_message(Stmt);
else
  len := length(Stmt);
   counter1 := 1;
   while( counter1 < len )
   loop
     log_message(substr(Stmt,counter1,100));
     counter1 := counter1 + 100;
   end loop;
end if;
end dumpStmt;



Function VarcharValue(varcharCounter in number,rowCounter in Number) return varchar2  is
begin
  if varcharCounter = 1 then
    return( v_varchar1(rowCounter) );
  elsif varcharCounter = 2 then
        return( v_VARCHAR2(rowCounter) );
  elsif varcharCounter = 3 then
       return( v_varchar3(rowCounter) );
  elsif varcharCounter = 4 then
       return( v_varchar4(rowCounter));
  elsif varcharCounter = 5 then
       return( v_varchar5(rowCounter));
  elsif varcharCounter = 6 then
       return( v_varchar6(rowCounter));
  elsif varcharCounter = 7 then
       return( v_varchar7(rowCounter));
  elsif varcharCounter = 8 then
       return( v_varchar8(rowCounter));
  elsif varcharCounter = 9 then
       return( v_varchar9(rowCounter));
  elsif varcharCounter = 10 then
       return( v_varchar10(rowCounter));
  elsif varcharCounter = 11 then
       return( v_varchar11(rowCounter));
  elsif varcharCounter = 12 then
       return( v_varchar12(rowCounter));
  elsif varcharCounter = 13 then
       return( v_varchar13(rowCounter));
  elsif varcharCounter = 14 then
       return( v_varchar14(rowCounter));
  elsif varcharCounter = 15 then
       return( v_varchar15(rowCounter));
  elsif varcharCounter = 16 then
       return( v_varchar16(rowCounter));
  elsif varcharCounter = 17 then
       return( v_varchar17(rowCounter));
  elsif varcharCounter = 18 then
       return( v_varchar18(rowCounter));
  elsif varcharCounter = 19 then
       return( v_varchar19(rowCounter));
  elsif varcharCounter = 20 then
       return( v_varchar20(rowCounter));
  end if;

end;

Function NumberValue(NumberCounter in number,rowCounter in Number) return Number  is
begin
 if NumberCounter = 1 then
    return( v_Number1(rowCounter) );
  elsif NumberCounter = 2 then
        return( v_Number2(rowCounter) );
  elsif NumberCounter = 3 then
       return( v_Number3(rowCounter) );
  elsif NumberCounter = 4 then
       return( v_Number4(rowCounter) );
  elsif NumberCounter = 5 then
       return( v_Number5(rowCounter) );
  elsif NumberCounter = 6 then
       return( v_Number6(rowCounter) );
  elsif NumberCounter = 7 then
       return( v_Number7(rowCounter) );
  elsif NumberCounter = 8 then
       return( v_Number8(rowCounter) );
  elsif NumberCounter = 9 then
       return( v_Number9(rowCounter) );
  elsif NumberCounter = 10 then
       return( v_Number10(rowCounter) );
  end if;

end;

Function DateValue(dateCounter in number,rowCounter in Number) return Date  is
begin
 if dateCounter = 1 then
    return( v_Date1(rowCounter) );
  elsif dateCounter = 2 then
        return( v_Date2(rowCounter) );
  elsif dateCounter = 3 then
       return( v_Date3(rowCounter) );
  elsif dateCounter = 4 then
       return( v_Date4(rowCounter));
  elsif dateCounter = 5 then
       return( v_Date5(rowCounter));
  elsif dateCounter = 6 then
       return( v_Date6(rowCounter));
  elsif dateCounter = 7 then
       return( v_Date7(rowCounter));
  end if;

end;

--this Procedure is being called from workflow
Procedure SEND_NTF(p_item_type      IN VARCHAR2,
                   pItemKey         IN VARCHAR2,
                   p_actid          IN NUMBER,
                   p_funcmode       IN VARCHAR2,
                   p_result         OUT NOCOPY VARCHAR2) Is

cursor wfNtfRev(l_exception_id in number) is
select WF_ROLE,WF_ROLE_TYPE
from  MSC_USER_EXCEPTION_NTFS
where EXCEPTION_ID = l_exception_id and
      SEND_NTF_FLAG = 'Y' ;

l_exception_exist  NUMBER := 0;

lWfRole            VARCHAR2(240);
lWfRoleType        VARCHAR2(1);
lNtfId             NUMBER;

cursor getAdhocUser(lEmailAddress in VARCHAR2) is
select NAME
from  wf_local_users
where Name = lEmailAddress;

lAdhocUser Varchar2(320);

begin
 if ( p_funcmode = 'RUN'  ) THEN
   l_exception_exist := wf_engine.getItemAttrNumber(
      p_item_type,
      pItemKey,
      'EXCEPTION_EXIST');

   open wfNtfRev(v_exception_id);
   loop
        fetch wfNtfRev into  lWfRole , lWfRoleType;
        exit when wfNtfRev%NOTFOUND;

        /*
           lWfRoleType = 1=> User
           lWfRoleType = 2=> responsibility
           lWfRoleType = 3=> email
           lWfRoleType = 4 =>item Planner
    lWfRoleType = 5 =>Buyer
    lWfRoleType = 6 =>SupplierContact
        */
         if v_debug then
  log_message('SEND_NTF: Role Type  ::'||lWfRoleType);
  log_message('SEND_NTF: Exception Id ::'||v_exception_id);
 end if;

 if lWfRoleType = 6 then
            SendNtfToSupplierContact(p_item_type,pItemKey);
  elsif lWfRoleType = 5 then
            SendNtfToBuyer(p_item_type,pItemKey);
        elsif lWfRoleType = 4 then
            SendNtfToPlannerCode(p_item_type,pItemKey);
        else
          if lWfRoleType = 3 then
              --check if this is an email
              lAdhocUser := null;
              open getAdhocUser(lWfRole);
              fetch getAdhocUser into lAdhocUser;
              close getAdhocUser;

              if v_debug then
                log_message('Sending Notification to user='||lWfRole);
              end if;

              if lAdhocUser is null then
                 --create adhoc user
                 wf_directory.CREATEADHOCUSER
                 ( NAME =>  lWfRole
                  ,DISPLAY_NAME => lWfRole
                  ,NOTIFICATION_PREFERENCE =>'MAILHTML'
                  ,EMAIL_ADDRESS => lWfRole
                 );

                 if v_debug then
                    log_message('creating adhoc user '||lWfRole);
                 end if;

                 lAdhocUser := lWfRole;

              end if;

              lWfRole := lAdhocUser;

           end if;
	if lWfRole is not null and validate_block_notification(lWfRole, v_exception_id) = 0 then ---Bug # 6175897
           if v_debug then
                    log_message('sending notification =  '||lWfRole);
           end if;

           lNtfId := wf_notification.send
                   (
                     role =>lWfRole,
                     msg_type=> p_item_type ,
                     msg_name => v_msg_name ,
                     context => pItemKey,
           DUE_DATE => sysdate+ 7,
                     callback => 'MSC_X_USER_EXCEP_GEN.setMesgAttribute'
                     );
	 end if;
       end if;

   end loop;

   close wfNtfRev;

  elsif ( p_funcmode = 'CANCEL' ) THEN
        null;
  end if;
exception
  when others then
    Wf_Core.Context('MSC_USER_EXCEP_GEN', 'SEND_NTF', p_item_type, pItemKey);
    raise;
end SEND_NTF;

Procedure SendNtfToPlannerCode(p_item_type IN VARCHAR2,pItemKey IN VARCHAR2) is
l_user_name       VARCHAR2(100);
l_item_name       VARCHAR2(255);
l_publisher_item_name   VARCHAR2(255);
l_publisher_site_name   VARCHAR2(255);
l_tp_item_name          VARCHAR2(255);
l_planner_code          VARCHAR2(10);
lNtfId                Number;
cursor planner_c(p_item IN VARCHAR2) is
select distinct pl.user_name,
       pl.planner_code
from    msc_planners pl,
        msc_system_items itm
where   itm.plan_id = -1
--and     itm.organization_id = p_organization_id
and     itm.item_name = p_item
--and   itm.sr_instance_id = pl.sr_instance_id
and     pl.organization_id = itm.organization_id
and     pl.planner_code = itm.planner_code;

 --if item and org are there
  cursor planner_c1(p_item IN VARCHAR2,p_org IN VARCHAR2) is
  select distinct pl.user_name,
       pl.planner_code
from    msc_planners pl,
        msc_system_items itm,
  msc_trading_partners mtp
where   itm.plan_id = -1
and     itm.organization_id = pl.organization_id
and     itm.item_name = p_item
and     pl.organization_id = itm.organization_id
and     pl.planner_code = itm.planner_code
and     pl.organization_id=mtp.sr_tp_id
and     mtp.organization_code =p_org
and     mtp.partner_type=3;


--if item is there but not the org

  cursor planner_c2(p_item IN VARCHAR2) is
    select distinct pl.user_name,
       pl.planner_code
from    msc_planners pl,
        msc_system_items itm,
  msc_trading_partners mtp
where   itm.plan_id = -1
and     itm.organization_id = pl.organization_id
and     itm.item_name = p_item
and     pl.organization_id = itm.organization_id
and     pl.planner_code = itm.planner_code
and     pl.organization_id=mtp.sr_tp_id
and     mtp.sr_tp_id =mtp.master_organization
and     mtp.partner_type=3;

begin

  --we fetch the item_name from the ouput attr
     l_publisher_item_name := wf_engine.getItemAttrText(
                      p_item_type,
                      pItemKey,
                      'P.ITEM_NAME' );

 l_publisher_site_name := wf_engine.getItemAttrText(
                      p_item_type,
                      pItemKey,
                      'P.PUBLISHER_SITE_NAME' );

  --if item is not selected in the output attribute then show the warning in the log message...

   if l_publisher_item_name is not null then
        l_item_name := l_publisher_item_name;


     else
       log_message('Warning: Planner Code is specified for notification but item is not selected');
     end if;

--if both the item and org(site) are specified in the output attr.
--then send the noti. to the planner of that item in that org..

     if l_item_name is not null and l_publisher_site_name is not null then
      open planner_c1(l_item_name,l_publisher_site_name);

         fetch planner_c1 into l_user_name,l_planner_code;
   if v_debug then
  log_message('Planner: Item Name ::'||l_item_name);
  log_message('Planner: User Name ::'||l_user_name);
   end if;
         if planner_c1%NOTFOUND then
  log_message('Warning: Planner not found for Item : '||l_item_name);

 else
   if l_user_name is not null and validate_block_notification(l_user_name, v_exception_id) = 0 then ---Bug # 6175897
         lNtfId := wf_notification.send
                   (
                     role =>l_user_name,
                     msg_type=> p_item_type ,
                     msg_name => v_msg_name ,
                     context => pItemKey,
                     callback => 'MSC_X_USER_EXCEP_GEN.setMesgAttribute'
                     );
          if v_debug then
           log_message('Planner Code: Notification sent to user='||l_user_name);
         end if;
       end if;
  end if;
    close planner_c1;
      elsif l_item_name is not null and l_publisher_site_name is null then
       --if the item is specified in the output attr but the org(site) is not.
     --then send the noti. to the planner of the item in the master org..

  open planner_c2(l_item_name);
         fetch planner_c2 into l_user_name,l_planner_code;
 if v_debug then
  log_message('Planner: Item Name ::'||l_item_name);
  log_message('Planner: User Name ::'||l_user_name);
  end if;
        if planner_c2%NOTFOUND then
  log_message('Warning: Planner not found for Item : '||l_item_name);

    else
        if l_user_name is not null and validate_block_notification(l_user_name, v_exception_id) = 0 then ---Bug # 6175897
         lNtfId := wf_notification.send
                   (
                     role =>l_user_name,
                     msg_type=> p_item_type ,
                     msg_name => v_msg_name ,
                     context => pItemKey,
                     callback => 'MSC_X_USER_EXCEP_GEN.setMesgAttribute'
                     );
        if v_debug then
           log_message('Planner Code: Notification sent to user='||l_user_name);
         end if;
       end if;
      end if;
           close planner_c2;
     end if;
-- added exception handler
Exception when others then
  log_message('Planner Code: EXCEPTION ::'||sqlerrm);
  IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_ERROR,'MSC_X_USER_EXCEP_GEN.SendNtfToPlannerCode',SQLERRM);
  END IF;

end SendNtfToPlannerCode;

Procedure setMesgAttribute(
command IN VARCHAR2,
context IN VARCHAR2,
attr_name IN VARCHAR2,
attr_type IN VARCHAR2,
text_value in out NOCOPY varchar2,
number_value in out NOCOPY number,
date_value in out NOCOPY date)is
l_item_key  VARCHAR2(80);
l_start_pos   number;
l_end_pos number;
begin

 if command = 'GET' then
       text_value := wf_engine.getItemAttrText(
                v_item_type,
                context,
                attr_name);
    if v_debug then
      log_message('ATTR_NAME='||attr_name||' VALUE='||text_value);
    end if;
 end if;

-- added exception handler
exception when others then
  IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_ERROR,'MSC_X_USER_EXCEP_GEN.setMesgAttribute',SQLERRM);
  END IF;

end;

PROCEDURE Delete_Item(l_type in varchar2, l_key in varchar2)
IS
   CURSOR c1 IS
        select nt.notification_id,nt.status
      from wf_item_activity_statuses st,
	   wf_notifications nt
      where st.item_type = l_type
      and st.item_key like l_key
	  and nt.notification_id = st.notification_id
	    union
      	  select nt.notification_id,nt.status
      from wf_item_activity_statuses_h st1,wf_notifications nt
      where st1.item_type = l_type
      and st1.item_key like l_key
	   and
	   nt.notification_id = st1.notification_id;


BEGIN

    FOR aRec IN c1 LOOP
    update wf_notifications set
    end_date = sysdate
    where notification_id = aRec.notification_id;
    IF aRec.status = 'OPEN' THEN
          wf_notification.close(aRec.notification_id);
    END IF;
 END LOOP;

    update wf_items set
      end_date = sysdate
    where item_type = l_type
    and item_key like l_key;

    update wf_item_activity_statuses set
      end_date = sysdate
    where item_type = l_type
    and item_key like l_key;

    update wf_item_activity_statuses_h set
      end_date = sysdate
    where item_type = l_type
    and item_key like l_key;

    -- bug 3622235: Perf issue in purging design time data also.
    -- WF team added a new 5th param (runTimeDataOnly). Set it true
    -- so that design time data is not purged.

    wf_purge.total(l_type,l_key,sysdate,false,true);

EXCEPTION
  WHEN OTHERS THEN
        return;
END Delete_Item;

Procedure  ValidateCondition(pAdvCondition  in varchar2,
                              oErrorMessage  OUT NOCOPY VARCHAR2,
                              oErrorPosition OUT NOCOPY NUMBER ) is
capsAdvString VARCHAR2(4000);
fromString    Varchar2(500) := null;
lSQLString    VARCHAR2(4000);
begin
  oErrorPosition := 0;
  oErrorMessage := null;
  capsAdvString := modifyWhereForThreshold(0,pAdvCondition);

  capsAdvString := upper( capsAdvString );
  if instr(capsAdvString,'COMPANY.') <> 0 then
     fromString := ' msc_sup_dem_ent_custom_ex_v COMPANY ';
  end if;

  if instr(capsAdvString,'SUPPLIER.')  <> 0 then
     if fromString is null then
        fromString  := ' msc_sup_dem_ent_custom_ex_v SUPPLIER';
     else
       fromString  := fromString ||' , msc_sup_dem_ent_custom_ex_v SUPPLIER';
     end if;
  end if;

  if instr(capsAdvString,'CUSTOMER.') <> 0 then
     if fromString is null then
        fromString  := ' msc_sup_dem_ent_custom_ex_v CUSTOMER';
     else
       fromString  := fromString ||' , msc_sup_dem_ent_custom_ex_v CUSTOMER';
     end if;
  end if;

 if fromString is not null then
    lSQLString := ' select 1 '||' from ' || fromString || ' where rownum = 1 and '||capsAdvString;

   log_message('cal string='||lSQLString);
   execute immediate lSQLString;
 else
   lSQLString := 'select 1 from dual where rownum = 1 and '||capsAdvString;
   log_message('cal string='||lSQLString);
   execute immediate lSQLString;

 end if;

exception
  when ExTerminateProgram then
  oErrorMessage := fnd_message.get;
  log_message(oErrorMessage);

  when others then
  oErrorMessage  :=  SQLERRM;
  oErrorPosition := DBMS_SQL.last_error_position;
  log_message(oErrorPosition);
  log_message(oErrorMessage);
end ;

-- this is quick and dirty check for calculations
Procedure ValidateCalculation(pCalculationString in varchar2,
               oErrorMessage  OUT NOCOPY VARCHAR2,
               oErrorPosition OUT NOCOPY NUMBER ) is
capsCalString VARCHAR2(2000) := upper(pCalculationString);
fromString    Varchar2(500) := null;
lSQLString    VARCHAR2(2000);
begin
  oErrorPosition := 0;
  oErrorMessage := null;

  if instr(capsCalString,'COMPANY.') <> 0 then
     fromString := ' msc_sup_dem_ent_custom_ex_v COMPANY';
  end if;

  if instr(capsCalString,'SUPPLIER.')  <> 0 then
     if fromString is null then
        fromString  := ' msc_sup_dem_ent_custom_ex_v SUPPLIER';
     else
       fromString  := fromString ||' , msc_sup_dem_ent_custom_ex_v SUPPLIER';
     end if;
  end if;

  if instr(capsCalString,'CUSTOMER.') <> 0 then
     if fromString is null then
        fromString  := ' msc_sup_dem_ent_custom_ex_v CUSTOMER';
     else
       fromString  := fromString ||' , msc_sup_dem_ent_custom_ex_v CUSTOMER';
     end if;
  end if;

 if fromString is not null then
    fromString := ' from ' || fromString || ' where rownum = 1 ';

   lSQLString  := 'select '||pCalculationString||fromString;
   log_message('cal string='||lSQLString);
   execute immediate lSQLString;
 else
   lSQLString := 'select ( '||pCalculationString||') from dual ';
   log_message('cal string='||lSQLString);
   execute immediate lSQLString;

 end if;
exception
  when others then
  oErrorMessage  :=  SQLERRM;
  oErrorPosition := DBMS_SQL.last_error_position;
  log_message(oErrorPosition);
  log_message(oErrorMessage);
end;



--this is called form UI Only
Procedure ValidateDefinition( pExceptionId   In NUMBER ,
                              oSqlStmt       OUT NOCOPY VARCHAR2,
                              oErrorMessage  OUT NOCOPY VARCHAR2,
                              oErrorPosition OUT NOCOPY NUMBER
                              ) is
begin
   v_exception_id := pExceptionId;
   oErrorPosition := -1;
   oErrorMessage  := null;
   osqlstmt       := null;

   performSetUp;

   -- retrive user exception definition
   getExceptionDef(v_exception_id) ;


   -- build select and where statement based on exception definition
   if v_debug then
    log_message('before buildSqlStmt' );
   end if;
   buildSqlStmt;


   -- modify where clause incase threshold is specified in where condition
  -- modifyWhereForThreshold;
   vWhereStmt := modifyWhereForThreshold(v_exception_id,vWhereStmt);


   -- build from clause of select statement
   if v_debug then
    log_message('before buildFromClause' );
   end if;
   buildFromClause;

  --parse the complete select statement
   v_fetch_cursor := DBMS_SQL.OPEN_CURSOR;
   if v_debug then
    log_message('before select parseStmt' );
   end if;
   oSqlStmt := vSelectStmt||vFromClause||vWhereStmt||vGroupByStmt||vHavingWhere||vSortStmt;
   parseStmt(v_fetch_cursor,oSqlStmt);

  --everything is fine
    oErrorPosition := 0;
exception
   when ExTerminateProgram then
        --log_message('ExTerminateProgram exception');
        oErrorMessage := fnd_message.get;
        oErrorPosition := -1;
        log_message(oErrorMessage);
   when others then
      if oSqlStmt is null then
       -- unexpected error happened before reaching parse statement
        oErrorPosition := -1;
      else
        -- error ocured during parse
        oErrorPosition := DBMS_SQL.last_error_position;
      end if;

      oErrorMessage  :=  SQLERRM;
      if dbms_sql.is_open(v_fetch_cursor) THEN
         dbms_sql.close_cursor(v_fetch_cursor);
      end if;
      if dbms_sql.is_open(v_insert_cursor) THEN
         dbms_sql.close_cursor(v_insert_cursor);
      end if;

end   ValidateDefinition;

-- this is called from UI only for copy exception
Procedure copyException(newExName      IN Varchar2,
                        newDescription IN Varchar2,
         exceptionId    IN Number,
         status         OUT NOCOPY NUMBER,
         returnMessage  OUT NOCOPY VARCHAR2) IS
lexceptionId  Number;
lUserId Number := FND_GLOBAL.USER_ID;

cursor adv_exp is
select
MSC_USER_ADV_EXPRESSIONS_S.NEXTVAL
,ex.Expression_Id
,ex.NAME
,ex.DESCRIPTION
,ex.COMPONENT_TYPE
,ex.DISPLAY_LENGTH
,ex.CALCULATION_DATATYPE
,ex.REGION_CODE
,ex.GLOBAL_FLAG
,ex.COMPANY_ID
,ex.EXPRESSION1
,ex.ATTRIBUTE1
,ex.ATTRIBUTE2
,ex.ATTRIBUTE3
,ex.ATTRIBUTE4
,ex.ATTRIBUTE5
,ex.ATTRIBUTE6
,ex.ATTRIBUTE7
,ex.ATTRIBUTE8
,ex.ATTRIBUTE9
,ex.ATTRIBUTE10
,ex.ATTRIBUTE11
,ex.ATTRIBUTE12
,ex.ATTRIBUTE13
,ex.ATTRIBUTE14
,ex.ATTRIBUTE15
,ex.CONTEXT
FROM MSC_USER_ADV_EXPRESSIONS ex,
     MSC_USER_EXCEPTION_COMPONENTS comp
WHERE ex.EXPRESSION_ID = comp.EXPRESSION_ID
and   comp.EXCEPTION_ID =  exceptionId;

 lExpressionId Number;
 lName               Varchar2(30);
 lDescription     Varchar2(240);
 lComponentType   Number;
 lDisplayLength   Number;
 lCompanyId       Number;
 lCalculationDatatype   Varchar2(30);
 lRegionCode            Varchar2(30);
 lGlobalFlag            Varchar2(1);
 lExpression1           Varchar2(4000);
 oldExpressionId        Number;
 lAttribute1      VARCHAR2(240);
  lAttribute2 VARCHAR2(240);
  lAttribute3 VARCHAR2(240);
  lAttribute4 VARCHAR2(240);
  lAttribute5 VARCHAR2(240);
  lAttribute6 VARCHAR2(240);
  lAttribute7 VARCHAR2(240);
  lAttribute8 VARCHAR2(240);
  lAttribute9 VARCHAR2(240);
  lAttribute10 VARCHAR2(240);
  lAttribute11 VARCHAR2(240);
  lAttribute12 VARCHAR2(240);
  lAttribute13 VARCHAR2(240);
  lAttribute14 VARCHAR2(240);
  lAttribute15 VARCHAR2(240);
  lContext   VARCHAR2(240);
begin
select MSC_USER_EXCEPTIONS_S.NEXTVAL
into lexceptionId from dual;

insert into MSC_USER_EXCEPTIONS(
 EXCEPTION_ID
,NAME
,DESCRIPTION
,REGION_CODE
,COMPANY_ID
,SECURITY_FLAG
--,GROUP_BY_FLAG
,WF_ITEM_TYPE
,WF_PROCESS
,WF_LAUNCH_FLAG
,NOTIFICATION_TEXT
,REQUEST_ID
,START_FLAG
,RECURRENCE_FLAG
,EVENT
,START_DATE
,REPEAT_INTERVAL
,REPEAT_TYPE
,REPEAT_END_TIME
,LAST_RUN_DATE
,FULL_DATA_FLAG
,REFRESH_NUMBER
,LAST_UPDATE_DATE
,LAST_UPDATED_BY
,CREATION_DATE
,CREATED_BY
,LAST_UPDATE_LOGIN
,ATTRIBUTE1
,ATTRIBUTE2
,ATTRIBUTE3
,ATTRIBUTE4
,ATTRIBUTE5
,ATTRIBUTE6
,ATTRIBUTE7
,ATTRIBUTE8
,ATTRIBUTE9
,ATTRIBUTE10
,ATTRIBUTE11
,ATTRIBUTE12
,ATTRIBUTE13
,ATTRIBUTE14
,ATTRIBUTE15
,CONTEXT
)
select
 lexceptionId
,newExName
,newDescription
,REGION_CODE
,COMPANY_ID
,SECURITY_FLAG
--,GROUP_BY_FLAG
,WF_ITEM_TYPE
,WF_PROCESS
,WF_LAUNCH_FLAG
,NOTIFICATION_TEXT
,NULL
,START_FLAG
,RECURRENCE_FLAG
,EVENT
,START_DATE
,REPEAT_INTERVAL
,REPEAT_TYPE
,REPEAT_END_TIME
,NULL
,FULL_DATA_FLAG
,NULL
,sysdate
,lUserId
,sysdate
,lUserId
,null
,ATTRIBUTE1
,ATTRIBUTE2
,ATTRIBUTE3
,ATTRIBUTE4
,ATTRIBUTE5
,ATTRIBUTE6
,ATTRIBUTE7
,ATTRIBUTE8
,ATTRIBUTE9
,ATTRIBUTE10
,ATTRIBUTE11
,ATTRIBUTE12
,ATTRIBUTE13
,ATTRIBUTE14
,ATTRIBUTE15
,CONTEXT
from MSC_USER_EXCEPTIONS
where exception_id = exceptionId;


insert into MSC_USER_EXCEPTION_COMPONENTS(
COMPONENT_ID
,EXCEPTION_ID
,SEQ_NUM
,COMPONENT_TYPE
,AK_ATTRIBUTE_CODE
,LABEL
,EXPRESSION_ID
,COMPONENT_VALUE1
,COMPONENT_VALUE2
,DATE_FILTER_FLAG
,ROLLING_DATE_FLAG
,ROLLING_NUMBER
,ROLLING_TYPE
,LAST_UPDATE_DATE
,LAST_UPDATED_BY
,CREATION_DATE
,CREATED_BY
,LAST_UPDATE_LOGIN
,ATTRIBUTE1
,ATTRIBUTE2
,ATTRIBUTE3
,ATTRIBUTE4
,ATTRIBUTE5
,ATTRIBUTE6
,ATTRIBUTE7
,ATTRIBUTE8
,ATTRIBUTE9
,ATTRIBUTE10
,ATTRIBUTE11
,ATTRIBUTE12
,ATTRIBUTE13
,ATTRIBUTE14
,ATTRIBUTE15
,CONTEXT
)
select
 MSC_USER_EXCEPTION_COMP_S.NEXTVAL
,lexceptionId
,SEQ_NUM
,COMPONENT_TYPE
,AK_ATTRIBUTE_CODE
,LABEL
,EXPRESSION_ID
,COMPONENT_VALUE1
,COMPONENT_VALUE2
,DATE_FILTER_FLAG
,ROLLING_DATE_FLAG
,ROLLING_NUMBER
,ROLLING_TYPE
,sysdate
,lUserId
,sysdate
,lUserId
,NULL
,ATTRIBUTE1
,ATTRIBUTE2
,ATTRIBUTE3
,ATTRIBUTE4
,ATTRIBUTE5
,ATTRIBUTE6
,ATTRIBUTE7
,ATTRIBUTE8
,ATTRIBUTE9
,ATTRIBUTE10
,ATTRIBUTE11
,ATTRIBUTE12
,ATTRIBUTE13
,ATTRIBUTE14
,ATTRIBUTE15
,CONTEXT
from MSC_USER_EXCEPTION_COMPONENTS
where EXCEPTION_ID = exceptionId ;

-- its is decided to copy calculation also when copying exceptions
--no global calclations. Data model not modified becasue  we may want global calculation
-- later on

open adv_exp;
loop
  fetch adv_exp into
  lExpressionId,oldExpressionId,
  lName,lDescription,lComponentType,lDisplayLength,lCalculationDatatype,
  lRegionCode,lGlobalFlag,lCompanyId,lExpression1,
  lAttribute1,lAttribute2,lAttribute3,lAttribute4,lAttribute5,lAttribute6,lAttribute7,
  lAttribute8,lAttribute9,lAttribute10,lAttribute11,lAttribute12,lAttribute13,lAttribute14,
   lAttribute15,lContext;
  exit when adv_exp%NOTFOUND;

  insert into MSC_USER_ADV_EXPRESSIONS(
   EXPRESSION_ID
   ,NAME
   ,DESCRIPTION
   ,COMPONENT_TYPE
   ,DISPLAY_LENGTH
   ,CALCULATION_DATATYPE
   ,REGION_CODE
   ,GLOBAL_FLAG
   ,COMPANY_ID
   ,EXPRESSION1
   ,LAST_UPDATE_DATE
   ,LAST_UPDATED_BY
   ,CREATION_DATE
   ,CREATED_BY
   ,LAST_UPDATE_LOGIN
   ,ATTRIBUTE1
   ,ATTRIBUTE2
   ,ATTRIBUTE3
   ,ATTRIBUTE4
   ,ATTRIBUTE5
   ,ATTRIBUTE6
   ,ATTRIBUTE7
   ,ATTRIBUTE8
   ,ATTRIBUTE9
   ,ATTRIBUTE10
   ,ATTRIBUTE11
   ,ATTRIBUTE12
   ,ATTRIBUTE13
   ,ATTRIBUTE14
   ,ATTRIBUTE15
   ,CONTEXT
     ) values
     (
   lExpressionId,
      lName,lDescription,lComponentType,lDisplayLength,lCalculationDatatype,
   lRegionCode,lGlobalFlag,lCompanyId,lExpression1,
   sysdate ,lUserId ,sysdate ,lUserId ,null,
      lAttribute1,lAttribute2,lAttribute3,lAttribute4,lAttribute5,lAttribute6,lAttribute7,
      lAttribute8,lAttribute9,lAttribute10,lAttribute11,lAttribute12,lAttribute13,lAttribute14,
   lAttribute15,lContext
    ) ;

   update MSC_USER_EXCEPTION_COMPONENTS comp1
   set EXPRESSION_ID = lExpressionId
   where EXPRESSION_ID = oldExpressionId
   and   EXCEPTION_ID = lexceptionId;

end loop;
close adv_exp;

insert into MSC_USER_EXCEPTION_NTFS(
NOTIFICATION_ENTRY_ID
,EXCEPTION_ID
,WF_ROLE
,WF_ROLE_TYPE
,SEND_NTF_FLAG
,SHOW_EXCEPTION_DTL_FLAG
,LAST_UPDATE_DATE
,LAST_UPDATED_BY
,CREATION_DATE
,CREATED_BY
,LAST_UPDATE_LOGIN
,ATTRIBUTE1
,ATTRIBUTE2
,ATTRIBUTE3
,ATTRIBUTE4
,ATTRIBUTE5
,ATTRIBUTE6
,ATTRIBUTE7
,ATTRIBUTE8
,ATTRIBUTE9
,ATTRIBUTE10
,ATTRIBUTE11
,ATTRIBUTE12
,ATTRIBUTE13
,ATTRIBUTE14
,ATTRIBUTE15
,CONTEXT
)
select
 MSC_USER_EXCEPTION_NTFS_S.NEXTVAL
,lexceptionId
,WF_ROLE
,WF_ROLE_TYPE
,SEND_NTF_FLAG
,SHOW_EXCEPTION_DTL_FLAG
,sysdate
,lUserId
,sysdate
,lUserId
,NULL
,ATTRIBUTE1
,ATTRIBUTE2
,ATTRIBUTE3
,ATTRIBUTE4
,ATTRIBUTE5
,ATTRIBUTE6
,ATTRIBUTE7
,ATTRIBUTE8
,ATTRIBUTE9
,ATTRIBUTE10
,ATTRIBUTE11
,ATTRIBUTE12
,ATTRIBUTE13
,ATTRIBUTE14
,ATTRIBUTE15
,CONTEXT
from MSC_USER_EXCEPTION_NTFS
where EXCEPTION_ID = exceptionId;

insert into MSC_RELATED_EXCEPTIONS
(
RELATION_ID
,EXCEPTION_ID
,LINK_TYPE
,RELATED_EXCEPTION_ID
,URLNAME
,URL
,LAST_UPDATE_DATE
,LAST_UPDATED_BY
,CREATION_DATE
,CREATED_BY
,LAST_UPDATE_LOGIN
,ATTRIBUTE1
,ATTRIBUTE2
,ATTRIBUTE3
,ATTRIBUTE4
,ATTRIBUTE5
,ATTRIBUTE6
,ATTRIBUTE7
,ATTRIBUTE8
,ATTRIBUTE9
,ATTRIBUTE10
,ATTRIBUTE11
,ATTRIBUTE12
,ATTRIBUTE13
,ATTRIBUTE14
,ATTRIBUTE15
,CONTEXT
)
select
MSC_RELATED_EXCEPTIONS_S.NEXTVAL
,lexceptionId
,LINK_TYPE
,RELATED_EXCEPTION_ID
,URLNAME
,URL
,sysdate
,lUserId
,sysdate
,lUserId
,NULL
,ATTRIBUTE1
,ATTRIBUTE2
,ATTRIBUTE3
,ATTRIBUTE4
,ATTRIBUTE5
,ATTRIBUTE6
,ATTRIBUTE7
,ATTRIBUTE8
,ATTRIBUTE9
,ATTRIBUTE10
,ATTRIBUTE11
,ATTRIBUTE12
,ATTRIBUTE13
,ATTRIBUTE14
,ATTRIBUTE15
,CONTEXT
from MSC_RELATED_EXCEPTIONS
where EXCEPTION_ID = lexceptionId;


 status := 1;
 FND_MESSAGE.Set_NAME('MSC','MSCX_UDE_EXCEP_COPY');
 returnMessage := FND_MESSAGE.get;


Exception
  when others then
  status := -1;
  returnMessage := SQLERRM;

end copyException;


--this is called from UI only for deleting exception

Procedure deleteException(exceptionId IN NUMBER,
                        status      OUT NOCOPY NUMBER,
                        returnMessage OUT NOCOPY VARCHAR2) IS
cursor detailIds is
select to_char(exception_Detail_id)
from msc_x_exception_details
where  EXCEPTION_TYPE = exceptionId
and EXCEPTION_GROUP = -99;

lItemType VARCHAR2(8);
lExceptionDetailsId   Varchar2(30);

cursor wfItems is
 select WF_ITEM_TYPE
     from MSC_USER_EXCEPTIONS
     where EXCEPTION_ID = exceptionId;


Begin
      status := -1;
      --returnMessage := 'delete failed';
      FND_MESSAGE.SET_NAME('MSC', 'MSC_UDE_DEL_FAILED');
      returnMessage := FND_MESSAGE.get;

      open wfItems;
      fetch wfItems into lItemType;
      close wfItems;

      if lItemType is not null then
         open detailIds;
         loop
            fetch detailIds into lExceptionDetailsId;
            exit when detailIds%NOTFOUND;
            if v_debug then
             log_message('deleting exception='||lExceptionDetailsId);
            end if;
            Delete_Item(lItemType,lExceptionDetailsId);
         end loop;
         close detailIds;
      end if;


   delete from msc_x_exception_details
   where exception_type = exceptionId
   and exception_group = -99;

        /*delete from MSC_EXCEPTION_PREFERENCES
        where EXCEPTION_TYPE_LOOKUP_CODE = exceptionId; */

   delete from msc_item_exceptions
   where exception_type = exceptionId
   and exception_group = -99;

  /*  delete from MSC_USER_EXCEPTION_NTFS
   where EXCEPTION_ID = exceptionId;

   delete from MSC_RELATED_EXCEPTIONS
   where EXCEPTION_ID = exceptionId;
  */
   delete from MSC_USER_ADV_EXPRESSIONS exp
   where exp.expression_id in (
   select ex.expression_id
   from MSC_USER_EXCEPTION_COMPONENTS ex
   where ex.EXCEPTION_ID = exceptionId
   );
      -- calculations are no longer global
   --and GLOBAL_FLAG <> 'Y';

  /*
   delete from MSC_USER_EXCEPTION_COMPONENTS
   where EXCEPTION_ID = exceptionId;

   delete from MSC_USER_EXCEPTIONS
   where EXCEPTION_ID = exceptionId;
  */

        status := 1;
        --returnMessage := 'delete completed';
      FND_MESSAGE.SET_NAME('MSC', 'MSC_UDE_DEL_SUCCESS');
      returnMessage := FND_MESSAGE.get;


end;

--this doesn't work
function getVarcharArray(arrayIndex in number ) return DBMS_SQL.VARCHAR2_TABLE IS
begin
  if arrayIndex = 1 then
    return( v_varchar1);
  elsif arrayIndex = 2 then
        return( v_varchar2);
elsif arrayIndex = 3 then
       return( v_varchar3);
elsif arrayIndex = 4 then
       return( v_varchar4);
elsif arrayIndex = 5 then
       return( v_varchar5);
elsif arrayIndex = 6 then
       return( v_varchar6);
end if;
end getVarcharArray;


-- this is called form netting engine
Procedure RunCustomExcepWithNetting is
cursor getExceptions is
select exception_id,NAME from
msc_user_exceptions ex
where RECURRENCE_FLAG = '0';
lExceptionId Number;
lName VARCHAR2(80);
lRequestId Number;
begin
open getExceptions;
loop
   fetch getExceptions into lExceptionId,lName;
   exit when getExceptions%NOTFOUND;
   lRequestId := FND_REQUEST.SUBMIT_REQUEST(
                             'MSC',
                             'MSCEXGEN',
                             'Custom Exception',  -- description
                             null,  -- start date
                             FALSE, -- sub request,
                             lExceptionId,
                             NULL);
  if lRequestId > 0 then
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Launched custom exception '||lName);
    update msc_user_exceptions
    set request_id= lRequestId
   where exception_id = lExceptionId;
  else
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in launching custom exceptions ');
  end if;
end loop;
  commit;
 close getExceptions;
end;

END MSC_X_USER_EXCEP_GEN;

/
