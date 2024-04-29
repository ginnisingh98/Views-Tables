--------------------------------------------------------
--  DDL for Package Body IEX_STRATEGY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_STRATEGY_PUB" AS
/* $Header: iexpstpb.pls 120.11.12010000.11 2009/11/30 14:25:33 pnaveenk ship $ */
/*
 * This procedure needs to be called with an itemtype and workflow process
 * which'll launch workflow .Start Workflow will call workflow based on
 * Meth_flag in methodology base table
*/

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IEX_STRATEGY_PUB';


--PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER ;

PROCEDURE create_strategy
(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   ,
    P_Commit                     IN   VARCHAR2   ,
    p_validation_level           IN   NUMBER     ,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_DelinquencyID              IN   number,
    p_ObjectType                 IN   varchar2,
    p_ObjectID                   IN   number,
    p_Strategy_Temp_ID           IN   number := 0
) IS

	l_result               VARCHAR2(10);
	l_error_msg            VARCHAR2(2000);
	l_return_status        VARCHAR2(20);
	l_msg_count            NUMBER;
	l_msg_data             VARCHAR2(2000);
	l_api_name             VARCHAR2(100) ;
	l_api_version_number   CONSTANT NUMBER   := 2.0;

    vStrategyStatus         VARCHAR2(30);


	fdelinquencyId number;
	fPartyCustId number;
	fCustAccountId number;
    fCustomerSiteUseId number;
	fTransactionId number;
	fPaymentScheduleid number;
	fObjectId number;
	fobjectType varchar2(40);
    fScoreValue number;
    fJTFObjectId number;
	fJTFobjectType varchar2(40);
    fStrategyLevel number;

    l_ObjectType    VARCHAR2(30);
	l_strategy_id number;
	l_strategy_template_id number;
	l_object_version_number number := 2.0;

    c_DelSelect varchar2(1000) ;
    c_Bankruptcy varchar2(1000);
    C_WriteOff  varchar2(1000) ;
    C_Repossession varchar2(1000) ;
    C_Litigation varchar2(1000) ;
     C_Party varchar2(1000) ;
      C_IEX_Account varchar2(1000) ;
       C_IEX_BILLTO varchar2(1000) ;

    --Start bug 6723540 gnramasa 02 Jan 08
    C_Cont_Bankruptcy   varchar2(1000);
    C_Cont_WriteOff     varchar2(1000) ;
    C_Cont_Repossession varchar2(1000) ;
    C_Cont_Litigation   varchar2(1000) ;
    --End bug 6723540 gnramasa 02 Jan 08

    l_stry_cnt_rec  IEX_STRATEGY_TYPE_PUB.STRY_CNT_REC_TYPE ;

    l_strategy_rec IEX_STRATEGY_PVT.STRATEGY_REC_TYPE;

    Cursor c_score_exists( p_object_id number, p_object_type varchar2) is
         select score_value
                from iex_score_histories
                where score_object_id = p_object_id
                and score_object_code = p_object_type
                order by creation_date desc;

    -- Start Added for bug 6359338 gnramasa 23-Aug-07
   Cursor c_score_exists_del(p_object_id number,  p_object_type varchar2, p_object_id2 number, p_object_type2 varchar2) is
         select score_value
                from iex_score_histories
                where score_object_id in (p_object_id, p_object_id2)
                and score_object_code in (p_object_type, p_object_type2)
                order by creation_date desc;
   -- End Added for bug 6359338 gnramasa 23-Aug-07

    TYPE c_strategy_existsCurTyp IS REF CURSOR;  -- weak
    c_strategy_exists c_strategy_existsCurTyp;  -- declare cursor variable


    l_default_rs_id  number ;
    l_resource_id NUMBER;
    l_StrategyTempID number;
    b_Skip varchar2(10);

    l_Init_Msg_List              VARCHAR2(10)   ;
    l_Commit                     VARCHAR2(10)   ;
    l_validation_level           NUMBER     ;

    -- Start Added for bug 6359338 gnramasa 23-Aug-07
    l_StrategyLevel              VARCHAR2(20);
    l_ObjectId                   NUMBER;
    l_payment_schedule_id        NUMBER;
    l_Score_level                VARCHAR2(20);
    -- End Added for bug 6359338 gnramasa 23-Aug-07

BEGIN
    -- initialize variable
    l_Init_Msg_List := P_Init_Msg_List;
    l_Commit := P_Commit;
    l_validation_level  := p_validation_level;
    if (l_Init_msg_List is null) then
      l_Init_Msg_List              := FND_API.G_FALSE;
    end if;
    if (l_Commit is null) then
      l_Commit                     := FND_API.G_FALSE;
    end if;
    if (l_validation_level is null) then
      l_validation_level           := FND_API.G_VALID_LEVEL_FULL;
    end if;

    l_api_name             := 'CREATE_STRATEGY';

    --Start adding for bug 8834310 gnramasa 26th Aug 09
    if (p_Strategy_temp_id is null) or (p_Strategy_temp_id = 0) then
	    begin
	    select decode(preference_value, 'CUSTOMER', 10, 'ACCOUNT', 20, 'BILL_TO', 30, 'DELINQUENCY', 40,  40)
	      into l_DefaultStrategyLevel
	      from iex_app_preferences_b
	       where  preference_name = 'COLLECTIONS STRATEGY LEVEL' and enabled_flag = 'Y' and org_id is null;   -- Changed for bug 8708271 multi level strategy
	    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	    IEX_DEBUG_PUB.LogMessage( 'Default StrategyLevel ' || l_DefaultStrategyLevel);
	    END IF;
	    EXCEPTION
		    WHEN OTHERS THEN
			    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			    IEX_DEBUG_PUB.LogMessage( 'Strategy Level Rised Exception ');
			    END IF;
			    l_DefaultStrategyLevel := 40;
	    END;
    else
	    begin
	    select strategy_level
	      into l_DefaultStrategyLevel
	      from iex_strategy_templates_b
	       where  strategy_temp_id = p_Strategy_temp_id;
	    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	    IEX_DEBUG_PUB.LogMessage( 'Strategy template :' || p_Strategy_temp_id || ' ,StrategyLevel :' || l_DefaultStrategyLevel);
	    END IF;
	    EXCEPTION
		    WHEN OTHERS THEN
			    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			    IEX_DEBUG_PUB.LogMessage( 'Strategy template Level Rised Exception ');
			    END IF;
			    l_DefaultStrategyLevel := 40;
	    END;
     end if;
     --End adding for bug 8834310 gnramasa 26th Aug 09

    c_DelSelect :=
	    ' select d.party_cust_id, d.cust_account_id, d.customer_site_use_id,  d.delinquency_id, ' ||
		' d.transaction_id, d.payment_schedule_id,  ' ||
        ' d.delinquency_id object_id, ''DELINQUENT'' object_type , ' ||
		' d.score_value   ' ||
        ' , 40 strategy_level, d.delinquency_id jtf_object_id, ''IEX_DELINQUENCY'' jtf_object_type ' ||
    	' from iex_delinquencies d where (d.status = ''DELINQUENT'' ' ||
        ' or d.status = ''PREDELINQUENT'') ' ||
        ' and d.delinquency_id  = :pObjectID ';

    c_Bankruptcy :=
    	' select d.party_cust_id, d.cust_account_id, d.customer_site_use_id, d.delinquency_id, ' ||
        ' d.transaction_id, d.payment_schedule_id, ' ||
		' bankruptcy_id object_id, ''BANKRUPTCY'' object_type, ' ||
        ' d.score_value ' ||
        ' , NULL strategy_level, bankruptcy_id jtf_object_id, ''IEX_BANKRUPTCY'' jtf_object_type ' ||
		' from iex_delinquencies d, iex_bankruptcies b where (d.status = ''DELINQUENT'' ' ||
                ' or d.status = ''PREDELINQUENT'') ' ||
		' and d.delinquency_id = b.delinquency_id ' ||
        ' and d.delinquency_id = :p_DelinquencyID ' ||
        ' and b.bankruptcy_id = :p_ObjectID ';

    C_WriteOff  :=
	    ' select d.party_cust_id, d.cust_account_id,  d.customer_site_use_id, d.delinquency_id, ' ||
		' d.transaction_id, d.payment_schedule_id, ' ||
		' writeoff_id object_id, ''WRITEOFF'' object_type, ' ||
		' d.score_value ' ||
        ' , NULL strategy_level, writeoff_id jtf_object_id, ''IEX_WRITEOFF'' jtf_object_type ' ||
    	' from iex_delinquencies d, iex_writeoffs b  where (d.status = ''DELINQUENT'' ' ||
                ' or d.status = ''PREDELINQUENT'') ' ||
		' and d.delinquency_id = b.delinquency_id ' ||
        ' and d.delinquency_id = :p_DelinquencyID ' ||
        ' and b.writeoff_id = :p_ObjectID ';

    C_Repossession :=
	    ' select d.party_cust_id, d.cust_account_id,  d.customer_site_use_id, d.delinquency_id, ' ||
		' d.transaction_id, d.payment_schedule_id, ' ||
		' repossession_id object_id, ''REPOSSESSION'' object_type, ' ||
		' d.score_value ' ||
        ' , NULL strategy_level, repossession_id jtf_object_id, ''IEX_REPOSSESSION'' jtf_object_type ' ||
		' from iex_delinquencies d, iex_repossessions b where (d.status = ''DELINQUENT'' ' ||
                ' or d.status = ''PREDELINQUENT'') ' ||
		' and d.delinquency_id = b.delinquency_id  '  ||
        ' and d.delinquency_id = :p_DelinquencyID ' ||
        ' and b.repossession_id = :p_ObjectID ';

    C_Litigation :=
	    ' select d.party_cust_id, d.cust_account_id,  d.customer_site_use_id, d.delinquency_id, ' ||
		' d.transaction_id, d.payment_schedule_id, ' ||
		'litigation_id object_id, ''LITIGATION'' object_type, ' ||
		' d.score_value ' ||
        ' , NULL strategy_level, litigation_id jtf_object_id, ''IEX_LITIGATION'' jtf_object_type ' ||
		' from iex_delinquencies d, iex_litigations b where (d.status = ''DELINQUENT'' ' ||
                ' or d.status = ''PREDELINQUENT'') ' ||
		' and d.delinquency_id = b.delinquency_id  '  ||
        ' and d.delinquency_id = :p_DelinquencyID ' ||
        ' and b.litigation_id = :p_ObjectID ';

     C_Party :=
	       'select d.party_cust_id, null, null, null,  null, null, ' ||
		   ' d.PARTY_CUST_ID object_id, ''PARTY'' object_type, null' ||
           ' , 10 strategy_level,  d.PARTY_CUST_ID jtf_object_id, ''PARTY'' jtf_object_type' ||
		   ' from iex_delinquencies d' ||
           ' where (d.status = ''DELINQUENT'' ' ||
           ' or d.status = ''PREDELINQUENT'') ' ||
           ' and d.party_cust_id  = :pObjectID ' ||
           ' group by d.party_cust_id ';

      C_IEX_Account :=
           ' select d.party_cust_id, d.cust_account_id, null, null, null, null, ' ||
		   ' d.cust_account_id object_id, ''ACCOUNT'' object_type, null, ' ||
           ' 20 strategy_level, d.cust_account_id jtf_object_id, ''IEX_ACCOUNT'' jtf_object_type ' ||
		   ' from iex_delinquencies d  ' ||
           ' where (d.status = ''DELINQUENT''  ' ||
           ' or d.status = ''PREDELINQUENT'') ' ||
           ' and d.cust_account_id  = :pObjectID ' ||
           ' group by d.party_cust_id, d.cust_account_id ';

       C_IEX_BILLTO :=
           ' select d.party_cust_id, d.cust_account_id, d.customer_site_use_id , null, null, null, ' ||
		   ' d.customer_site_use_id object_id, ''BILL_TO'' object_type, null, ' ||
           ' 30 strategy_level, d.customer_site_use_id jtf_object_id, ''IEX_BILLTO'' jtf_object_type ' ||
		   ' from iex_delinquencies d  ' ||
           ' where (d.status = ''DELINQUENT''  ' ||
           ' or d.status = ''PREDELINQUENT'') ' ||
           ' and d.customer_site_use_id  = :pObjectID ' ||
           ' group by d.party_cust_id, d.cust_account_id, d.customer_site_use_id ';

 --Start bug 6723540 gnramasa 02 Jan 08
    C_Cont_Bankruptcy :=
    	' select party_id, cust_account_id, customer_site_use_id, NULL delinquency_id, ' ||
        ' NULL transaction_id, NULL payment_schedule_id, ' ||
		' bankruptcy_id object_id, ''BANKRUPTCY'' object_type, ' ||
        ' NULL score_value ' ||
        ' , NULL strategy_level, bankruptcy_id jtf_object_id, ''IEX_BANKRUPTCY'' jtf_object_type ' ||
		' from iex_bankruptcies where bankruptcy_id = :p_ObjectID ';

    C_Cont_WriteOff  :=
	    ' select party_id, cust_account_id,  customer_site_use_id, NULL delinquency_id, ' ||
		' NULL transaction_id, NULL payment_schedule_id, ' ||
		' writeoff_id object_id, ''WRITEOFF'' object_type, ' ||
		' NULL score_value ' ||
        ' , NULL strategy_level, writeoff_id jtf_object_id, ''IEX_WRITEOFF'' jtf_object_type ' ||
    	' from iex_writeoffs where writeoff_id = :p_ObjectID ';

    C_Cont_Repossession :=
	    ' select party_id, cust_account_id,  customer_site_use_id, NULL delinquency_id, ' ||
		' NULL transaction_id, NULL payment_schedule_id, ' ||
		' repossession_id object_id, ''REPOSSESSION'' object_type, ' ||
		' NULL score_value ' ||
        ' , NULL strategy_level, repossession_id jtf_object_id, ''IEX_REPOSSESSION'' jtf_object_type ' ||
		' from iex_repossessions where repossession_id = :p_ObjectID ';

    C_Cont_Litigation :=
	    ' select party_id, cust_account_id,  customer_site_use_id, NULL delinquency_id, ' ||
		' NULL transaction_id, NULL payment_schedule_id, ' ||
		' litigation_id object_id, ''LITIGATION'' object_type, ' ||
		' NULL score_value ' ||
        ' , NULL strategy_level, litigation_id jtf_object_id, ''IEX_LITIGATION'' jtf_object_type ' ||
		' from iex_litigations where litigation_id = :p_ObjectID ';
 --End bug 6723540 gnramasa 02 Jan 08

    l_stry_cnt_rec  := IEX_STRATEGY_TYPE_PUB.INST_STRY_CNT_REC;

    l_default_rs_id  := fnd_profile.value('IEX_STRY_DEFAULT_RESOURCE');
    l_resource_id :=  fnd_profile.value('IEX_STRY_FULFILMENT_RESOURCE');
    b_Skip := 'F';


    -- Standard Start of API savepoint
    SAVEPOINT CREATE_STRATEGY_PUB;

    -- Initialize API return status to SUCCESS
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    /*
    if (NVL(FND_PROFILE.VALUE('IEX_STRATEGY_DISABLED'), 'N') = 'Y') then
         return;
    end if;
    */

    /* check the default profile valuse */
    /* Check the required profiles for Strategy Concurrent before starting */
    if (NVL(FND_PROFILE.VALUE('IEX_STRATEGY_DISABLED'), 'N') = 'Y') then
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage( 'Strategy creation aborted. ' );
        IEX_DEBUG_PUB.LogMessage( 'Strategy Disabled by Profile ');
      END IF;
        return;
    end if;

    if (l_DefaultStrategyLevel = 50) Then
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage( 'Strategy creation stopped. ' );
        IEX_DEBUG_PUB.LogMessage( 'No Default Strategy Run Level from IEX_APP_PREFERENCES ');
        END IF;
        b_Skip := 'T';
    end if;

    l_StrategyTempID := NVL(to_number(FND_PROFILE.VALUE('IEX_STRATEGY_DEFAULT_TEMPLATE')), 0);
    if (l_StrategyTempID = 0) Then
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage( 'Strategy creation stopped. ' );
        IEX_DEBUG_PUB.LogMessage( 'No Default Strategy Template Profile ');
        END IF;
        b_Skip := 'T';
    end if;

    if (l_default_rs_ID = 0) Then
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage( 'Strategy creation stopped. ' );
        IEX_DEBUG_PUB.LogMessage( 'Strategy Default Resource Profile not set. ');
        IEX_DEBUG_PUB.LogMessage( 'Default Resource need to have view access all customers, if security enabled ');
        END IF;
        b_Skip := 'T';
    end if;

    if (l_resource_ID = 0) Then
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage( 'Strategy creation stopped. ' );
        IEX_DEBUG_PUB.LogMessage( 'Strategy Fulfilment Resource Profile not set. ');
        IEX_DEBUG_PUB.LogMessage( 'Fulfilment Resource should be configured for fulfilment ');
        END IF;
        b_Skip := 'T';
    end if;

    if (b_Skip = 'T') then
        /* retcode := '2'; */
        return;
    end if;


    l_objectType := UPPER(p_ObjectType);


    -- Initialize message list IF p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( l_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage(
            debug_msg => 'PUB:' || G_PKG_NAME || '.' || l_api_name || ' Start',
            print_date => 'Y');
    END IF;

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage(
            debug_msg => '1. D.ID= ' || p_delinquencyID || ' OID= ' || P_objectid || ' OT.= ' || P_objectType,
            print_date => 'Y');
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

--Start bug 6798118 gnramasa 05 Feb 08
If l_ObjectType in ('PARTY','ACCOUNT','BILL_TO','DELINQUENT') THEN
	if (l_ObjectType = 'PARTY') then
	--            IF PG_DEBUG < 10  THEN
	    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	       IEX_DEBUG_PUB.logmessage('create_strategy: ' ||  'STEP 35 Query: ' || C_Party);
	    END IF;
	    Execute Immediate C_Party into  fPartyCustID, fCustAccountID,  fCustomerSiteUseId,
		fDelinquencyID, fTransactionID,  fPaymentScheduleID, fObjectID,
		fObjectType, fScoreValue, fStrategyLevel, fJTFObjectId, fJTFobjectType
		using p_ObjectID;
	elsif (l_ObjectType = 'ACCOUNT') then
	--            IF PG_DEBUG < 10  THEN
	    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	       IEX_DEBUG_PUB.logmessage('create_strategy: ' ||  'STEP 35 Query: ' || C_IEX_Account);
	    END IF;
	    Execute Immediate C_IEX_Account into fPartyCustID, fCustAccountID, fCustomerSiteUseId,
		fDelinquencyID, fTransactionID,  fPaymentScheduleID, fObjectID,
		fObjectType, fScoreValue, fStrategyLevel, fJTFObjectId, fJTFobjectType
		using p_ObjectID;
	 elsif (l_ObjectType = 'BILL_TO') then
	--            IF PG_DEBUG < 10  THEN
	    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	       IEX_DEBUG_PUB.logmessage('create_strategy: ' ||  'STEP 35 Query: ' || C_IEX_BILLTO);
	    END IF;
	    Execute Immediate C_IEX_BILLTO into fPartyCustID, fCustAccountID, fCustomerSiteUseId,
		fDelinquencyID, fTransactionID,  fPaymentScheduleID, fObjectID,
		fObjectType, fScoreValue, fStrategyLevel, fJTFObjectId, fJTFobjectType
		using p_ObjectID;
	elsif (l_objectType = 'DELINQUENT')  then
	--            IF PG_DEBUG < 10  THEN
		    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		       iex_debug_pub.logmessage('create_strategy: ' ||  'STEP 35 Query: ' || c_DelSelect );
		    END IF;
		    Execute Immediate c_DelSelect into fPartyCustID, fcustAccountID, fCustomerSiteUseId,
			fDelinquencyID, fTransactionID, fPaymentScheduleID, fObjectID,
			fObjectType, fScoreValue, fStrategyLevel, fJTFObjectId, fJTFobjectType
			using p_ObjectID;

	end if;
ELSE
--Start bug 6723540 gnramasa 02 Jan 08
    if p_DelinquencyID IS NOT NULL then
	  BEGIN
		if (l_ObjectType = 'BANKRUPTCY') then
	--            IF PG_DEBUG < 10  THEN
		    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		       IEX_DEBUG_PUB.logmessage('create_strategy: ' ||  'STEP 35 Query: ' || c_Bankruptcy);
		    END IF;
		    Execute Immediate c_Bankruptcy into fPartyCustID, fcustAccountID, fCustomerSiteUseId,
			fDelinquencyID, fTransactionID, fPaymentScheduleID,  fObjectID,
			fObjectType, fScoreValue, fStrategyLevel, fJTFObjectId, fJTFobjectType
			using p_DelinquencyID, p_ObjectID;

		elsif (l_ObjectType = 'WRITEOFF') then
	--            IF PG_DEBUG < 10  THEN
		    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		       IEX_DEBUG_PUB.logmessage('create_strategy: ' ||  'STEP 35 Query: ' || c_WriteOff);
		    END IF;
		    Execute Immediate c_WriteOff into fPartyCustId, fcustAccountID,  fCustomerSiteUseId,
			fDelinquencyID, fTransactionID,  fPaymentScheduleID, fObjectID,
			fObjectType, fScoreValue, fStrategyLevel, fJTFObjectId, fJTFobjectType
			using p_DelinquencyID, p_ObjectID;

		elsif (l_ObjectType = 'REPOSSESSION') then
	--            IF PG_DEBUG < 10  THEN
		    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		       IEX_DEBUG_PUB.logmessage('create_strategy: ' ||  'STEP 35 Query: ' || c_Repossession);
		    END IF;
		    Execute Immediate c_Repossession into  fPartyCustId, fCustAccountID, fCustomerSiteUseId,
			fDelinquencyID, fTransactionID,  fPaymentScheduleID, fObjectID,
			fObjectType, fScoreValue, fStrategyLevel, fJTFObjectId, fJTFobjectType
			using p_DelinquencyID, p_ObjectID;

		elsif (l_ObjectType = 'LITIGATION') then
	--            IF PG_DEBUG < 10  THEN
		    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		       IEX_DEBUG_PUB.logmessage('create_strategy: ' ||  'STEP 35 Query: ' || c_Litigation);
		    END IF;
		    Execute Immediate c_Litigation into  fPartyCustID, fCustAccountId, fCustomerSiteUseId,
			fDelinquencyID, fTransactionID,  fPaymentScheduleID, fObjectID,
			fObjectType, fScoreValue, fStrategyLevel, fJTFObjectId, fJTFobjectType
			using p_DelinquencyID, p_ObjectID;


		else
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.LogMessage('ERROR: IEX_UNKNOWN_OBJTYPE ' ||  l_objectType);
            END IF;

            FND_MESSAGE.Set_Name('IEX', 'IEX_UNKNOWN_OBJTYPE');
            FND_MESSAGE.Set_Token('OBJECT_TYPE', l_ObjectType);
            FND_MSG_PUB.Add;

            RAISE FND_API.G_EXC_ERROR;
            return;
        end if;

    EXCEPTION
        When NO_DATA_FOUND then
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.LogMessage('ERROR:  IEX_OBJECT_NOT_EXISTS' ||  l_objectType);
            END IF;

            FND_MESSAGE.Set_Name('IEX', 'IEX_OBJECT_NOT_EXISTS');
            FND_MESSAGE.Set_Token('OBJECT_ID', to_char(fObjectID));
            FND_MSG_PUB.Add;

            RAISE FND_API.G_EXC_ERROR;
            return;

    END;
  elsif p_ObjectID IS NOT NULL then
        begin
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.logmessage('p_ObjectID IS NOT NULL, p_ObjectID : ' ||  p_ObjectID );
        END IF;
	if (l_ObjectType = 'BANKRUPTCY') then
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.logmessage('create_strategy: ' ||  'STEP 35 Query: ' || C_Cont_Bankruptcy);
            END IF;
            Execute Immediate C_Cont_Bankruptcy into fPartyCustID, fcustAccountID, fCustomerSiteUseId,
                fDelinquencyID, fTransactionID, fPaymentScheduleID,  fObjectID,
                fObjectType, fScoreValue, fStrategyLevel, fJTFObjectId, fJTFobjectType
                using p_ObjectID;

        elsif (l_ObjectType = 'WRITEOFF') then
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.logmessage('create_strategy: ' ||  'STEP 35 Query: ' || C_Cont_WriteOff);
            END IF;
            Execute Immediate C_Cont_WriteOff into fPartyCustId, fcustAccountID,  fCustomerSiteUseId,
                fDelinquencyID, fTransactionID,  fPaymentScheduleID, fObjectID,
                fObjectType, fScoreValue, fStrategyLevel, fJTFObjectId, fJTFobjectType
                using p_ObjectID;

        elsif (l_ObjectType = 'REPOSSESSION') then
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.logmessage('create_strategy: ' ||  'STEP 35 Query: ' || C_Cont_Repossession);
            END IF;
            Execute Immediate C_Cont_Repossession into  fPartyCustId, fCustAccountID, fCustomerSiteUseId,
                fDelinquencyID, fTransactionID,  fPaymentScheduleID, fObjectID,
                fObjectType, fScoreValue, fStrategyLevel, fJTFObjectId, fJTFobjectType
                using p_ObjectID;

        elsif (l_ObjectType = 'LITIGATION') then
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.logmessage('create_strategy: ' ||  'STEP 35 Query: ' || C_Cont_Litigation);
            END IF;
            Execute Immediate C_Cont_Litigation into  fPartyCustID, fCustAccountId, fCustomerSiteUseId,
                fDelinquencyID, fTransactionID,  fPaymentScheduleID, fObjectID,
                fObjectType, fScoreValue, fStrategyLevel, fJTFObjectId, fJTFobjectType
                using p_ObjectID;

        else
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.LogMessage(
                debug_msg => 'ERROR: IEX_UNKNOWN_OBJTYPE ' ||  l_objectType,
                print_date => 'Y');
            END IF;

            FND_MESSAGE.Set_Name('IEX', 'IEX_UNKNOWN_OBJTYPE');
            FND_MESSAGE.Set_Token('OBJECT_TYPE', l_ObjectType);
            FND_MSG_PUB.Add;

            RAISE FND_API.G_EXC_ERROR;
            return;
        end if;

    EXCEPTION
        When NO_DATA_FOUND then
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.LogMessage(
                debug_msg => 'ERROR:  IEX_OBJECT_NOT_EXISTS' ||  l_objectType,
                print_date => 'Y');
            END IF;

            FND_MESSAGE.Set_Name('IEX', 'IEX_OBJECT_NOT_EXISTS');
            FND_MESSAGE.Set_Token('OBJECT_ID', to_char(fObjectID));
            FND_MSG_PUB.Add;

            RAISE FND_API.G_EXC_ERROR;
            return;

    END;

  end if; -- p_DelinquencyID IS NOT NULL
END IF;
--End bug 6798118 gnramasa 05 Feb 08

    /* Create the strategy record */
    l_stry_cnt_rec.cust_account_id := fCustAccountID;
    l_stry_cnt_rec.party_cust_id := fPartyCustId;
    l_stry_cnt_rec.customer_site_use_id := fCustomerSiteUseId;
    l_stry_cnt_rec.delinquency_id := fDelinquencyId;
    l_stry_cnt_rec.transaction_id := fTransactionid;
    l_stry_cnt_rec.object_id := fObjectId;
    l_stry_cnt_rec.object_type := fObjectType;
  --  l_stry_cnt_rec.score_value := fScoreValue;  -- Commented by gnramasa for bug 6359338 23-Aug-07
    fStrategyLevel := l_DefaultStrategyLevel;
    l_stry_cnt_rec.strategy_level := fStrategyLevel;
     l_stry_cnt_rec.jtf_object_id := fJTFObjectId;
     l_stry_cnt_rec.jtf_object_type := fJTFObjectType;

    --Select the strategy level score instead of the delinquency level score.
    --Start added by gnramasa for bug 6359338 23-Aug-07
    fScoreValue := '';
    if l_ObjectType in ('LITIGATION', 'REPOSSESSION', 'BANKRUPTCY', 'WRITEOFF') then
	    BEGIN
		    select preference_value
		      into l_StrategyLevel
		      from iex_app_preferences_b
		       where  preference_name = 'COLLECTIONS STRATEGY LEVEL' and enabled_flag = 'Y' and org_id is null;  -- Changed for bug 8708271 multi level strategy
		    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		    IEX_DEBUG_PUB.LogMessage( 'StrategyLevel ' || l_StrategyLevel);
		    END IF;
		    EXCEPTION
			    WHEN OTHERS THEN
				    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				    IEX_DEBUG_PUB.LogMessage( 'Strategy Level Rised Exception ');
				    END IF;
				    l_StrategyLevel := 'CUSTOMER';
	    END;

	    if l_StrategyLevel = 'CUSTOMER' then
	        l_Score_level := 'PARTY';
		l_ObjectId := l_stry_cnt_rec.party_cust_id;
		--fJTFObjectId := l_stry_cnt_rec.party_cust_id;
		--fJTFObjectType := 'PARTY';
		--fObjectId := l_stry_cnt_rec.party_cust_id;
		--fObjectType := 'PARTY';
	    elsif l_StrategyLevel = 'ACCOUNT' then
	        l_Score_level := 'IEX_ACCOUNT';
		l_ObjectId := l_stry_cnt_rec.cust_account_id;
		--fJTFObjectId := l_stry_cnt_rec.cust_account_id;
		--fJTFObjectType := 'IEX_ACCOUNT';
		--fObjectId := l_stry_cnt_rec.cust_account_id;
		--fObjectType := 'IEX_ACCOUNT';
	    elsif l_StrategyLevel = 'BILL_TO' then
	        l_Score_level := 'IEX_BILLTO';
		l_ObjectId := l_stry_cnt_rec.customer_site_use_id;
		--fJTFObjectId := l_stry_cnt_rec.customer_site_use_id;
		--fJTFObjectType := 'IEX_BILLTO';
		--fObjectId := l_stry_cnt_rec.customer_site_use_id;
		--fObjectType := 'IEX_BILLTO';
	    end if;

	    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		IEX_DEBUG_PUB.LogMessage( 'l_ObjectId : ' || l_ObjectId);
		IEX_DEBUG_PUB.LogMessage( 'l_Score_level : ' || l_Score_level);
		IEX_DEBUG_PUB.LogMessage( 'l_DefaultStrategyLevel : ' || l_DefaultStrategyLevel);
	    END IF;

	    if l_DefaultStrategyLevel <> 40 then -- This will pick the scores for all levels but not for delinquency
                Open c_Score_Exists(l_ObjectId, l_Score_level);
                fetch c_Score_Exists into fScoreValue;
                Close c_Score_Exists;

		IF fScoreValue IS NOT NULL then
			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			IEX_DEBUG_PUB.LogMessage( ' Got New Score using c_Score_Exists  '
			   || '; l_ObjectId = ' || l_ObjectId
			   || '; Score Value = ' || fScoreValue );
			end if;
		ELSE
			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			       IEX_DEBUG_PUB.LogMessage('Score not exist for this object');
			       IEX_DEBUG_PUB.LogMessage('create_strategy: ' || 'NO score available ');
			END IF;
			l_strategy_rec.score_value := 0;
		END IF;

            else
                -- When looking for scores for delinquencies we should look for the newest score from either the payment schedule OR Delinquency
                -- This is so because the first score of a delinquency is the score of the delinquent payment schedule
                -- but if a customer scores the delinquency we should use the delinquency score to set the strategy
		begin
			select payment_schedule_id
			into l_payment_schedule_id
			from iex_delinquencies
			where delinquency_id = l_stry_cnt_rec.delinquency_id;
		exception
			WHEN OTHERS THEN
			    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
				IEX_DEBUG_PUB.LogMessage( 'While selecting payment_schedule_id Rised Exception ');
			    END IF;
		end;

                Open c_score_exists_del(l_payment_schedule_id, 'IEX_INVOICES', l_stry_cnt_rec.delinquency_id, 'IEX_DELINQUENCY');
                fetch c_score_exists_del into fScoreValue;
                Close c_score_exists_del;

		IF fScoreValue IS NOT NULL then
			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			IEX_DEBUG_PUB.LogMessage( ' Got New Score using c_Score_Exists_del  '
			   || '; l_payment_schedule_id = ' || l_payment_schedule_id
			   || '; delinquency_id = ' || l_stry_cnt_rec.delinquency_id
			   || '; Score Value = ' || fScoreValue );
			end if;
		ELSE
			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			       IEX_DEBUG_PUB.LogMessage('Score not exist for this object');
			       IEX_DEBUG_PUB.LogMessage('create_strategy: ' || 'NO score available ');
			END IF;
			l_strategy_rec.score_value := 0;
		END IF;

		--fJTFObjectId := l_stry_cnt_rec.delinquency_id;
		--fJTFObjectType := 'IEX_DELINQUENCY';
		--fObjectId := l_stry_cnt_rec.delinquency_id;
		--fObjectType := 'IEX_DELINQUENCY';
             end if;

    else
	if (l_ObjectType = 'PARTY' OR l_ObjectType = 'IEX_ACCOUNT' OR l_ObjectType = 'IEX_BILLTO') AND (fScoreValue IS NULL) THEN
	    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	          IEX_DEBUG_PUB.LogMessage('create_strategy: l_ObjectType = ' || l_ObjectType);
		  IEX_DEBUG_PUB.LogMessage('create_strategy: fScoreValue = ' || fScoreValue);
	    END IF;
	    BEGIN
              Open c_Score_Exists(l_stry_cnt_rec.jtf_object_id, l_stry_cnt_rec.jtf_object_type);
              fetch c_Score_Exists into fScoreValue;
              Close c_Score_Exists;

	      EXCEPTION
                WHEN OTHERS THEN
--                    IF PG_DEBUG < 10  THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                       IEX_DEBUG_PUB.LogMessage('create_strategy: ' || 'NO score available ');
                    END IF;
                    l_strategy_rec.score_value := 0;
            END;
	end if;
    end if;
    l_stry_cnt_rec.score_value := fScoreValue;
    --l_stry_cnt_rec.object_id := fObjectId;
    --l_stry_cnt_rec.object_type := fObjectType;
    --l_stry_cnt_rec.jtf_object_id := fJTFObjectId;
    --l_stry_cnt_rec.jtf_object_type := fJTFObjectType;
    --End added by gnramasa for bug 6359338 23-Aug-07


    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage( debug_msg => '2. D.ID= '
        || l_stry_cnt_rec.delinquency_id         || ' OId= ' || l_stry_cnt_rec.object_id
        || ' OT= ' || l_stry_cnt_rec.object_type || ' SV= ' || l_stry_cnt_rec.score_value,
        print_date => 'Y');
    END IF;

    if (p_Strategy_temp_id is null) or (p_Strategy_temp_id = 0) then

    	IEX_STRATEGY_PUB.GetStrategyTempID(
       	 x_return_status=>l_return_status,
       	 p_stry_cnt_rec => l_stry_cnt_rec,
       	 x_strategy_template_id => l_strategy_template_id
    	);

    	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	IEX_DEBUG_PUB.LogMessage( debug_msg => '3. D.ID= ' || l_stry_cnt_rec.delinquency_id ||
        ' S.TID=' || l_strategy_template_id,   print_date => 'Y');
    	END IF;

    else
        l_strategy_template_id := p_strategy_temp_id;
    end if;

    l_strategy_rec.strategy_template_id := l_strategy_template_id;
    l_strategy_rec.delinquency_id := fdelinquencyId;
    l_strategy_rec.party_id := fPartyCustId;
    l_strategy_rec.cust_account_id := fCustAccountId;
    l_strategy_rec.customer_site_use_id := fCustomerSiteUseId;
    l_strategy_rec.next_work_item_id	:= null;
    l_strategy_rec.object_id := fObjectID;
    l_strategy_rec.object_type := fObjectType;
    l_strategy_rec.status_code := 'OPEN';
    l_strategy_rec.score_value := fScoreValue;
    l_strategy_rec.checklist_yn := 'N';
    l_strategy_rec.strategy_level := fStrategyLevel;
    l_strategy_rec.jtf_object_id := fJTFObjectId;
    l_strategy_rec.jtf_object_type := fJTFObjectType;

    l_object_version_number := 1;

    --Added for Bug# 6870773  by pnaveenk
    if fnd_profile.value('IEX_PROC_STR_ORG')='Y' then
        --l_strategy_rec.org_id:=fnd_profile.value('ORG_ID');
        l_strategy_rec.org_id:=mo_global.get_current_org_id;

    else
        l_strategy_rec.org_id:=NULL;
    end if;
    -- start for bug 9044667 PNAVEENK
    if (p_strategy_temp_id>0) and (l_strategy_rec.score_value is null)  then  --Added for bug#8997969 by schekuri on 09-Oct-2009`

        l_strategy_rec.score_value := 9999;
    end if;
    -- end for 9044667
  /*
     IF l_DefaultStrategyLevel = 10 or l_DefaultStrategyLevel = 20 or l_DefaultStrategyLevel = 30 then
            begin
              Open c_Score_Exists(l_stry_cnt_rec.jtf_object_id, l_stry_cnt_rec.jtf_object_type);
              fetch c_Score_Exists into l_strategy_rec.score_value;
              Close c_Score_Exists;
              EXCEPTION
                WHEN OTHERS THEN
--                    IF PG_DEBUG < 10  THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                       IEX_DEBUG_PUB.LogMessage('create_strategy: ' || 'NO score available ');
                    END IF;
                    l_strategy_rec.score_value := 0;
            END;
      end if;
   */
--End bug 6723540 gnramasa 02 Jan 08

    vStrategyStatus :=  NULL;
    IF l_ObjectType not in ('LITIGATION', 'REPOSSESSION', 'BANKRUPTCY', 'WRITEOFF') THEN
	    IF l_DefaultStrategyLevel = 10  THEN
		 OPEN c_strategy_exists
		  FOR
		       select status_code from iex_strategies where party_id = l_strategy_rec.party_id and
		    jtf_object_id = l_strategy_rec.jtf_object_id and jtf_object_type = l_strategy_rec.jtf_object_type
		    and (checklist_yn IS null or checklist_yn = 'N') ;
	      elsif l_DefaultStrategyLevel = 20 THEN
		  OPEN c_strategy_exists
		  FOR
		    select status_code from iex_strategies where CUST_ACCOUNT_ID = l_strategy_rec.CUST_ACCOUNT_ID and
		    jtf_object_id = l_strategy_rec.jtf_object_id and jtf_object_type = l_strategy_rec.jtf_object_type
		    and (checklist_yn IS null or checklist_yn = 'N') ;
	      elsif l_DefaultStrategyLevel = 30 THEN
		  OPEN c_strategy_exists
		  FOR
		    select status_code from iex_strategies where customer_site_use_ID = l_strategy_rec.customer_site_use_ID and
		    jtf_object_id = l_strategy_rec.jtf_object_id and jtf_object_type = l_strategy_rec.jtf_object_type
		    and (checklist_yn IS null or checklist_yn = 'N') ;
	      ELSE
		 OPEN c_strategy_exists
		 FOR
		   select status_code from iex_strategies where
			   delinquency_id = l_strategy_rec.delinquency_id and
		   jtf_object_id = l_strategy_rec.jtf_object_id and jtf_object_type = l_strategy_rec.jtf_object_type
		   and (checklist_yn IS null or checklist_yn = 'N') ;
	    END IF;
	--    Open c_Strategy_Exists(l_strategy_rec.delinquency_id,
	--                       l_strategy_rec.jtf_object_id, l_strategy_rec.jtf_object_type);
	--
	    fetch c_Strategy_Exists into vStrategyStatus;
	    Close C_Strategy_Exists;
    End if;

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage( debug_msg => '4. S.St=' || vStrategyStatus,   print_date => 'Y');
    END IF;

    if (vStrategyStatus IS NULL) or vStrategyStatus in ('CANCELLED', 'CLOSED') then


        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage( debug_msg => '5. Create strategy ',   print_date => 'Y');
        END IF;

        Begin

            iex_strategy_pvt.create_strategy(
                P_Api_Version_Number=>2.0,
                p_commit =>  FND_API.G_FALSE,
                P_Init_Msg_List     =>FND_API.G_FALSE,
                p_strategy_rec => l_strategy_rec,
                x_return_status=>l_return_status,
                x_msg_count=>l_msg_count,
                x_msg_data=>l_msg_data,
                x_strategy_id => l_strategy_id
            );

            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.LogMessage( debug_msg => 'Return status = ' || l_return_status,   print_date => 'Y');
            END IF;

            if (x_return_status <> 'S') then
                 RAISE FND_API.G_EXC_ERROR;
            end if;

            l_strategy_rec.strategy_id := l_strategy_id;

            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.LogMessage( debug_msg => 'Strategy created. id = ' || l_strategy_id,   print_date => 'Y');
            END IF;

        EXCEPTION
            WHEN OTHERS THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                IEX_DEBUG_PUB.LogMessage( debug_msg => 'IEX_STRATEGY_CREATE_FAILED' || to_char(fObjectID),   print_date => 'Y');
                END IF;

                FND_MESSAGE.Set_Name('IEX', 'IEX_STRATEGY_CREATE_FAILED');
                FND_MESSAGE.Set_Token('OBJECT_ID', to_char(fObjectID));
                FND_MSG_PUB.Add;

                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END;


        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage( debug_msg => '6. Create Workflow ' || l_strategy_rec.strategy_id,   print_date => 'Y');
        END IF;

        BEGIN

            iex_strategy_wf_pub.start_workflow(
                P_Api_Version =>2.0,
                P_Init_Msg_List => FND_API.G_FALSE,
                p_commit =>  FND_API.G_FALSE,
                p_strategy_rec => l_strategy_rec,
                x_return_status=>l_return_status,
                x_msg_count=>l_msg_count,
                x_msg_data=>l_msg_data,
                bConcProg => 'NO'
                );

            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.LogMessage( debug_msg => 'Return status = ' || l_return_status,   print_date => 'Y');
            END IF;
            IEX_DEBUG_PUB.LogMessage('Return status = ' || l_return_status);

            if (x_return_status <> 'S') then
                 RAISE FND_API.G_EXC_ERROR;
            end if;

        EXCEPTION
            WHEN OTHERS THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                IEX_DEBUG_PUB.LogMessage( debug_msg => 'IEX_LAUNCH_WORKFLOW_FAILED' || to_char(fObjectID), print_date => 'Y');
                END IF;

                FND_MESSAGE.Set_Name('IEX', 'IEX_LAUNCH_WORKFLOW_FAILED');
                FND_MESSAGE.Set_Token('OBJECT_ID', to_char(fObjectID));
                FND_MSG_PUB.Add;

                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END;

         -- Standard check for p_commit
        IF FND_API.to_Boolean(l_commit) THEN
            COMMIT WORK;
        END IF;

    ELSE
        x_return_status := 'F';
	IF l_ObjectType in ('LITIGATION', 'REPOSSESSION', 'BANKRUPTCY', 'WRITEOFF') THEN
	        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		IEX_DEBUG_PUB.LogMessage( debug_msg => 'Strategy already exists with OPEN status, so strategy is not created.', print_date => 'Y');
		END IF;
	ELSE
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		IEX_DEBUG_PUB.LogMessage( debug_msg => 'IEX_LAUNCH_WORKFLOW_FAILED' || to_char(fObjectID), print_date => 'Y');
		END IF;

		FND_MESSAGE.Set_Name('IEX', 'IEX_LAUNCH_WORKFLOW_FAILED');
		FND_MESSAGE.Set_Token('OBJECT_ID', to_char(fObjectID));
		FND_MSG_PUB.Add;
	END IF;

    end if;
    -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data
     );

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage( debug_msg => 'Delinquency cursor ends', print_date => 'Y');
    END IF;

    IEX_DEBUG_PUB.LogMessage('Delinquency cursor ends' );

EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END create_strategy;


PROCEDURE GetStrategyTempID(
		p_stry_cnt_rec in	IEX_STRATEGY_TYPE_PUB.STRY_CNT_REC_TYPE,
		x_return_status out NOCOPY varchar2,
		x_strategy_template_id out NOCOPY number) IS
/*
    CURSOR c_strategyTemp(pCategoryType varchar2, pDelinquencyID number) IS
       SELECT ST.strategy_temp_id, ST.strategy_rank, OBF.ENTITY_NAME
            from  IEX_STRATEGY_TEMPLATES_B ST, IEX_OBJECT_FILTERS OBF
            where ST.category_type = pCategoryType and ST.Check_List_YN = 'N' AND
                 OBF.OBJECT_ID(+) = ST.Strategy_temp_ID and
                 OBF.OBJECT_FILTER_TYPE(+) = 'IEXSTRAT'
               and not exists
                 (select 'x' from iex_strategies SS where SS.delinquency_id = pDelinquencyID
                       and SS.OBJECT_TYPE = pCategoryType)
            ORDER BY strategy_rank DESC;
*/
    C_DynSql varchar2(1000);
    v_Exists varchar2(20);
    v_SkipTemp varchar2(20);

    l_StrategyTempID number ;
    TYPE c_strategyTempCurTyp IS REF CURSOR;  -- weak
    c_strategyTemp c_strategyTempCurTyp;  -- declare cursor variable
    c_rec_Strategy_temp_id NUMBER;
    c_Rec_Strategy_Rank varchar2(10);
    c_Rec_ENTITY_NAME varchar2(30);
    c_Rec_active_flag varchar2(1);

    -- clchang updated for sql bind var 05/07/2003
    vstr1   varchar2(100) ;
    vstr2   varchar2(100) ;
    vstr3   varchar2(100) ;
    vstr4   varchar2(100) ;
    vstr5   varchar2(100) ;
    vstr6   varchar2(100) ;

BEGIN

    -- initialize variable
    l_StrategyTempID := 0;
    vstr1   := ' select 1 from ' ;
    vstr2   := ' where delinquency_id  = :DelId ' ;
    vstr3   := ' and rownum < 2 ';
    vstr4   := ' where CUST_ACCOUNT_id  = :AcctId ';
    vstr5   := ' where party_id  = :PartyId ';
    vstr6   := ' where customer_site_use_id  = :CustomerSiteUseId ';

    --Start adding for bug 8834310 gnramasa 26th Aug 09
    begin
    select decode(preference_value, 'CUSTOMER', 10, 'ACCOUNT', 20, 'BILL_TO', 30, 'DELINQUENCY', 40,  40)
      into l_DefaultStrategyLevel
      from iex_app_preferences_b
       where  preference_name = 'COLLECTIONS STRATEGY LEVEL' and enabled_flag = 'Y' and org_id is null;   -- Changed for bug 8708271 multi level strategy
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage( 'Default StrategyLevel ' || l_DefaultStrategyLevel);
    END IF;
    EXCEPTION
            WHEN OTHERS THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                    IEX_DEBUG_PUB.LogMessage( 'Strategy Level Rised Exception ');
                    END IF;
                    l_DefaultStrategyLevel := 40;
    END;
    --End adding for bug 8834310 gnramasa 26th Aug 09

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage( 'GetStrategyTempID: Object_Type = '
      || p_stry_cnt_rec.object_type || ' Delinquency ID = ' || p_stry_cnt_rec.delinquency_id );
    END IF;

    x_Strategy_Template_id := l_DefaultTempID;

    -- start for bug 8970972 PNAVEENK
    --Start added by gnramasa for bug 6359338 23-Aug-07
    if p_stry_cnt_rec.object_type in ('LITIGATION', 'REPOSSESSION', 'BANKRUPTCY', 'WRITEOFF') then
         OPEN c_strategyTemp
          FOR SELECT ST.strategy_temp_id, to_number(ST.strategy_rank), OBF.ENTITY_NAME, obf.active_flag
            from  IEX_STRATEGY_TEMPLATES_B ST, IEX_OBJECT_FILTERS OBF
            where ST.category_type = p_stry_cnt_rec.object_type and ST.Check_List_YN = 'N' AND
                ((ST.ENABLED_FLAG IS NULL) or ST.ENABLED_FLAG <> 'N') and
                 st.strategy_level = l_DefaultStrategyLevel and
                 OBF.OBJECT_ID(+) = ST.Strategy_temp_group_ID and
                 OBF.OBJECT_FILTER_TYPE(+) = 'IEXSTRAT'
                 and (TRUNC(SYSDATE) BETWEEN TRUNC(NVL(st.valid_from_dt, SYSDATE))
                      AND TRUNC(NVL(st.valid_to_dt, SYSDATE)))
		 and exists (select 1 from iex_strategy_template_groups tg
                          where tg.group_id = st.strategy_temp_group_id
                            and tg.enabled_flag <> 'N'
                            and trunc(sysdate) between trunc(nvl(tg.valid_from_dt,sysdate))
                                                   and trunc(nvl(tg.valid_to_dt,sysdate))  )
            ORDER BY to_number(strategy_rank) DESC;
     -- end for bug 8970972
     else


	      IF l_DefaultStrategyLevel = 10 or l_DefaultStrategyLevel = 20 or l_DefaultStrategyLevel = 30 THEN
		 OPEN c_strategyTemp
		  FOR SELECT ST.strategy_temp_id, to_number(ST.strategy_rank), OBF.ENTITY_NAME, obf.active_flag
		    from  IEX_STRATEGY_TEMPLATES_B ST, IEX_OBJECT_FILTERS OBF
		    where ST.Check_List_YN = 'N' AND
			 ((ST.ENABLED_FLAG IS NULL) or ST.ENABLED_FLAG <> 'N') and
			 st.strategy_level = l_DefaultStrategyLevel and
			 OBF.OBJECT_ID(+) = ST.Strategy_temp_ID and
			 OBF.OBJECT_FILTER_TYPE(+) = 'IEXSTRAT'
			 and nvl(st.valid_from_dt, sysdate) <= nvl(st.valid_to_dt,SYSDATE)
			 and (TRUNC(SYSDATE) BETWEEN TRUNC(NVL(st.valid_from_dt, SYSDATE))
			      AND TRUNC(NVL(st.valid_to_dt, SYSDATE)))
		    ORDER BY to_number(strategy_rank) DESC;
	      ELSE
		 OPEN c_strategyTemp
		  FOR SELECT ST.strategy_temp_id, to_number(ST.strategy_rank), OBF.ENTITY_NAME, obf.active_flag
		    from  IEX_STRATEGY_TEMPLATES_B ST, IEX_OBJECT_FILTERS OBF
		    where ST.category_type = p_stry_cnt_rec.object_type and ST.Check_List_YN = 'N' AND
			((ST.ENABLED_FLAG IS NULL) or ST.ENABLED_FLAG <> 'N') and
			 st.strategy_level = l_DefaultStrategyLevel and
			 OBF.OBJECT_ID(+) = ST.Strategy_temp_ID and
			 OBF.OBJECT_FILTER_TYPE(+) = 'IEXSTRAT'
			 and (TRUNC(SYSDATE) BETWEEN TRUNC(NVL(st.valid_from_dt, SYSDATE))
			      AND TRUNC(NVL(st.valid_to_dt, SYSDATE)))
		    ORDER BY to_number(strategy_rank) DESC;
		 /* in sync with iexpstcb.pls  -- retrieve the same strategy template
		    where ST.Check_List_YN = 'N' AND
			 st.strategy_level = l_DefaultStrategyLevel and
			 OBF.OBJECT_ID(+) = ST.Strategy_temp_ID and
			 OBF.OBJECT_FILTER_TYPE(+) = 'IEXSTRAT'
		       and not exists
			 (select 'x' from iex_strategies SS where SS.delinquency_id = p_stry_cnt_rec.delinquency_id
			       and SS.OBJECT_TYPE = p_stry_cnt_rec.object_type)
		    ORDER BY to_number(strategy_rank) DESC;
		 */
	      END IF;
	end if;
	 -- End added by gnramasa for bug 6359338 23-Aug-07


    /* Get the Strategy Template for requested Category Type */
    -- for c_rec in C_StrategyTemp(p_stry_cnt_rec.object_type, p_stry_cnt_rec.delinquency_id) loop
      LOOP
        FETCH C_StrategyTemp INTO c_rec_Strategy_temp_id, c_Rec_Strategy_Rank, c_Rec_ENTITY_NAME, c_rec_active_flag ;

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage( ' Get Strategy Template: Inside Cursor. Entity Name  '
                 || c_Rec_Entity_Name
                 || c_Rec_active_flag
                 || ' Rank ' || c_Rec_Strategy_Rank);
        END IF;

        if C_StrategyTemp%FOUND then
           v_SkipTemp := 'F';
           if c_Rec_Entity_Name is not null and c_rec_active_flag <> 'N' then
           BEGIN
             IF l_DefaultStrategyLevel = 40 THEN
               -- clchang updated for sql bind var 05/07/2003
               C_DynSql  := vstr1 || c_Rec_ENTITY_NAME ||
                            vstr2 ||
                            vstr3;
               Execute Immediate c_DynSql into v_Exists using p_stry_cnt_rec.delinquency_id;
              /*
               C_DynSql  :=
           	    ' select 1 from ' || c_Rec_ENTITY_NAME ||
                ' where delinquency_id  = ' || p_stry_cnt_rec.delinquency_id  ||
                ' and rownum < 2 ';
              */
            elsif l_DefaultStrategyLevel = 30 THEN
               C_DynSql  := vstr1 || c_Rec_ENTITY_NAME ||
                            vstr6 ||
                            vstr3;

               Execute Immediate c_DynSql into v_Exists using p_stry_cnt_rec.customer_site_use_id;

            elsif l_DefaultStrategyLevel = 20 THEN
               -- clchang updated for sql bind var 05/07/2003
               C_DynSql  := vstr1 || c_Rec_ENTITY_NAME ||
                            vstr4 ||
                            vstr3;

               Execute Immediate c_DynSql into v_Exists using p_stry_cnt_rec.cust_account_id;
              /*
                 C_DynSql  :=
           	    ' select 1 from ' || c_Rec_ENTITY_NAME ||
              	' where CUST_ACCOUNT_id  = ' || p_stry_cnt_rec.CUST_ACCOUNT_id  || ' and rownum < 2 ';
              */
             else
               C_DynSql  := vstr1 || c_Rec_ENTITY_NAME ||
                            vstr5 ||
                            vstr3;
               Execute Immediate c_DynSql into v_Exists using p_stry_cnt_rec.party_cust_id;

              /*
               C_DynSql  :=
           	    ' select 1 from ' || c_Rec_ENTITY_NAME ||
                ' where party_id  = ' || p_stry_cnt_rec.PARTY_CUST_ID  ||
                ' and rownum < 2 ';
              */
             end if;
             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             IEX_DEBUG_PUB.LogMessage( ' Dynamic SQL in GetStrategyTemplate '
                          || c_DynSql );
             END IF;

             --Execute Immediate c_DynSql into v_Exists;

           EXCEPTION
             When no_data_found then
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LogMessage( ' Get Strategy Template: No Data Found: ' || c_DynSql  );
               END IF;
               v_SkipTemp := 'T';
           END;
           end if;

           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage(' Get Strategy Template: v_SkipTemp ' || v_SkipTemp );
           END IF;

           if v_SkipTemp <> 'T' then

             if (p_stry_cnt_rec.score_value >= c_rec_strategy_rank) then
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		   IEX_DEBUG_PUB.LogMessage(' Get Strategy Template: c_rec_Strategy_temp_id: ' || c_rec_Strategy_temp_id );
		END IF;

               x_strategy_template_id := c_rec_Strategy_temp_id;
               return;
             end if;
           end if;
         ELSE  -- fetch failed, so exit loop
           EXIT;
        end if;
    end loop;
    close C_StrategyTemp;
EXCEPTION
    when others then
        close C_StrategyTemp;
END;


/* Sets the strategy to ONHOLD/OPEN
    P_API_VERSION_NUMBER := 2.0
    Delinquency_iD = delinquency ID
      Object_Type = DELINQUENT, BANKRUPTCY, WRITEOFF, LITIGATION, REPOSSESSION
      Object_ID = DelinquencyID, BankruptcyID, writeoffid, litigationid, repossessionid
*/

PROCEDURE set_strategy
(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_DelinquencyID              IN   number,
    p_ObjectType                 IN   varchar2,
    p_ObjectID                   IN   number,
    p_Status                     IN   varchar2
) IS

	l_result       VARCHAR2(10);
	l_error_msg            VARCHAR2(2000);
	l_return_status        VARCHAR2(20);
	l_msg_count            NUMBER;
	l_msg_data             VARCHAR2(2000);
	l_api_name             VARCHAR2(100) ;
	l_api_version_number   CONSTANT NUMBER   := 2.0;

	fdelinquencyId number;
	fPartyCustId number;
	fCustAccountId number;
    fCustomerSiteUseId number;
	fTransactionId number;
	fPaymentScheduleid number;
	fObjectId number;
	fobjectType varchar2(40);
    fScoreValue number;
	fStrategyID number;
	fStrategyVersionNumber number ;
    workItemId number;  -- Added for bug#7416344 by PNAVEENK on 16-3-2009
    l_ObjectType    VARCHAR2(30);
	l_object_version_number number ;
    vStrategyStatus         VARCHAR2(30);

    vDelinquencyStatus      VARCHAR2(30);

    --Begin bug#2369298 schekuri 24-Feb-2006

    /*Cursor c_strategy_exists(p_delinquency_id number, p_object_id number, p_object_type varchar2) is
        select strategy_id, status_code, object_version_number from iex_strategies
        where ((delinquency_id = p_delinquency_id and
            object_id = p_object_id and object_type = p_object_type)) and (checklist_yn IS NULL or checkList_YN = 'N')
            and (status_code in ( 'OPEN', 'ONHOLD'));*/
    Cursor c_strategy_exists(p_object_id number, p_object_type varchar2) is
        select strategy_id, status_code, object_version_number from iex_strategies
        where object_id = p_object_id and
	object_type = p_object_type and
	(checklist_yn IS NULL or checkList_YN = 'N') and
	status_code in ( 'OPEN', 'ONHOLD');
    --End bug#2369298 schekuri 24-Feb-2006


    Cursor c_delinquency_status(p_delinquency_id number) is
        select status from iex_delinquencies
        where delinquency_id = p_delinquency_id;

     -- Added for bug#7416344 by PNAVEENK on 16-3-2009
    Cursor C_Strategy_Status(fStrategyID number) is
        select work_item_id from iex_strategy_work_items where strategy_id=fStrategyID and status_code in ('OPEN');
    -- End for bug#7416344

    l_strategy_rec IEX_STRATEGY_PVT.STRATEGY_REC_TYPE;

    l_Init_Msg_List              VARCHAR2(10)   ;
    l_Commit                     VARCHAR2(10)   ;
    l_validation_level           NUMBER     ;
BEGIN
    -- initialize variable
    l_Init_Msg_List := P_Init_Msg_List;
    l_Commit := P_Commit;
    l_validation_level  := p_validation_level;
    if (l_Init_msg_List is null) then
      l_Init_Msg_List              := FND_API.G_FALSE;
    end if;
    if (l_Commit is null) then
      l_Commit                     := FND_API.G_FALSE;
    end if;
    if (l_validation_level is null) then
      l_validation_level           := FND_API.G_VALID_LEVEL_FULL;
    end if;

    l_api_name             := 'SET_STRATEGY';

    --Start adding for bug 8834310 gnramasa 26th Aug 09
    begin
    select decode(preference_value, 'CUSTOMER', 10, 'ACCOUNT', 20, 'BILL_TO', 30, 'DELINQUENCY', 40,  40)
      into l_DefaultStrategyLevel
      from iex_app_preferences_b
       where  preference_name = 'COLLECTIONS STRATEGY LEVEL' and enabled_flag = 'Y' and org_id is null;   -- Changed for bug 8708271 multi level strategy
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage( 'Default StrategyLevel ' || l_DefaultStrategyLevel);
    END IF;
    EXCEPTION
            WHEN OTHERS THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                    IEX_DEBUG_PUB.LogMessage( 'Strategy Level Rised Exception ');
                    END IF;
                    l_DefaultStrategyLevel := 40;
    END;
    --End adding for bug 8834310 gnramasa 26th Aug 09

    fStrategyVersionNumber := 2.0;
    l_object_version_number := 2.0;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Standard Start of API savepoint


    -- Initialize API return status to SUCCESS
    l_return_status := FND_API.G_RET_STS_SUCCESS;
    if (NVL(FND_PROFILE.VALUE('IEX_STRATEGY_DISABLED'), 'N') = 'Y') then
         return;
    end if;
    l_objectType := UPPER(p_ObjectType);
   -- commenting for bug 8864768 PNAVEENK
 /*   if (l_DefaultStrategyLevel = 10) or (l_DefaultStrategyLevel = 20) or (l_DefaultStrategyLevel = 30) then
          if (l_ObjectType not in ('BILL_TO', 'ACCOUNT', 'PARTY')) THEN
            return;
          end if;
    end if; */
    -- end for bug 8864768
    SAVEPOINT SET_STRATEGY;

    -- Initialize message list IF p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( l_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage(
        debug_msg => 'PUB:' || G_PKG_NAME || '.' || l_api_name || ' Start',
        print_date => 'Y');
    END IF;

     -- Debug Message
    IEX_DEBUG_PUB.LogMessage('PUB:' || G_PKG_NAME || '.' || l_api_name || ' Start');


    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage(
        debug_msg => '1. D.ID= ' || p_delinquencyID || ' OID= ' || P_objectid || ' OT.= ' || P_objectType,
        print_date => 'Y');
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;
     -- Debug Message
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage(
        debug_msg => '2. CHECK VALID STATUS => ' || p_Status,
        print_date => 'Y');
    END IF;

    if (p_Status NOT IN ('OPEN', 'ONHOLD')) then

        FND_MESSAGE.Set_Name('IEX', 'IEX_UNKNOWN_STATUS');
        FND_MESSAGE.Set_Token('STATUS', p_Status);
        FND_MSG_PUB.Add;

        RAISE FND_API.G_EXC_ERROR;
        return;

    end if;


    vDelinquencyStatus := NULL;
    Open C_Delinquency_Status (p_delinquencyid);
    fetch C_Delinquency_Status into vDelinquencyStatus;
    Close C_Delinquency_Status;

    l_object_version_number := 1;
    vStrategyStatus :=  NULL;

    --begin bug#2369298 schekuri 24-Feb-2006
    --Open c_Strategy_Exists(p_delinquencyid, p_objectid, p_objecttype);
    Open c_Strategy_Exists(p_objectid, p_objecttype);
    --end bug#2369298 schekuri 24-Feb-2006
    fetch c_Strategy_Exists into fStrategyID, vStrategyStatus, fStrategyVersionNumber;
    Close C_Strategy_Exists;

    -- Added for bug#7416344 by PNAVEENK on 16-3-2009
    Open C_Strategy_Status(fStrategyID);
    fetch C_Strategy_Status into workItemId;
    Close C_Strategy_Status;
    -- End for bug#7416344

    --begin bug#2369298 schekuri 24-Feb-2006
    --if strategy is already open no need to update it again if p_status is OPEN
    if p_Status = vStrategyStatus then
	return;
    end if;
    --end bug#2369298 schekuri 24-Feb-2006

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage(
            debug_msg => '4. Current S.St=' || vStrategyStatus ,
            print_date => 'Y');
    END IF;

    if ((fStrategyID IS NOT NULL) and vStrategyStatus NOT IN ('CLOSED', 'CANCELLED')) then

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage(
            debug_msg => '5. Update strategy ' || fStrategyID,
            print_date => 'Y');
        END IF;

        l_strategy_rec.strategy_id := fStrategyId;
        l_strategy_rec.object_version_number := fStrategyVersionNumber;
        l_strategy_rec.status_code := p_status;

        Begin

            iex_strategy_pvt.update_strategy(
                P_Api_Version_Number=>2.0,
                p_commit =>  FND_API.G_FALSE,
                P_Init_Msg_List     =>FND_API.G_FALSE,
                p_strategy_rec => l_strategy_rec,
                x_return_status=>l_return_status,
                x_msg_count=>l_msg_count,
                x_msg_data=>l_msg_data,
                xo_object_version_number => l_object_version_number
            );

            if (x_return_status <> 'S') then
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            end if;

        EXCEPTION
            WHEN OTHERS THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                IEX_DEBUG_PUB.LogMessage(
                    debug_msg => 'IEX_STRATEGY_UPDATE_FAILED' || fObjectID,
                    print_date => 'Y');
                END IF;

                FND_MESSAGE.Set_Name('IEX', 'IEX_STRATEGY_UPDATE_FAILED');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END;

         -- Standard check for p_commit
        IF FND_API.to_Boolean(l_commit) THEN
            COMMIT WORK;
        END IF;

        IEX_STRATEGY_WF.SEND_SIGNAL(process     => 'IEXSTRY',
                  strategy_id => fStrategyId,
                  status      => p_status ) ;

        -- Added for bug#7416344 by PNAVEENK on 16-3-2009
        IF workItemID is not null THEN
          IEX_STRY_UTL_PUB.refresh_uwq_str_summ(workItemID);
        END IF;
	-- End for bug#7416344

    ELSE

        if (vDelinquencyStatus = 'PREDELINQUENT') then
          return;
        end if;

        x_return_status := 'F';

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage(
            debug_msg => 'IEX_NO_STRATEGIES_EXIST ' || fObjectID,
            print_date => 'Y');
        END IF;

        FND_MESSAGE.Set_Name('IEX', 'IEX_NO_STRATEGIES_EXIST');
        FND_MESSAGE.Set_Token('OBJECT_ID', to_char(fObjectID));
        FND_MSG_PUB.ADD;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   end if;

    -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data
     );

    IEX_DEBUG_PUB.LogMessage('Delinquency cursor ends' );


EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END;


FUNCTION GetDefaultStrategyTempID return NUMBER IS
    l_StrategyTempID number;
    lCursorStrategyTempID number;
    Cursor C_getFirstTempID IS
        Select Strategy_Temp_ID FROM IEX_STRATEGY_TEMPLATES_B where
            Check_List_YN = 'N';
BEGIN
    l_StrategyTempID := NVL(to_number(FND_PROFILE.VALUE('IEX_STRATEGY_DEFAULT_TEMPLATE')), 0);
    if (l_StrategyTempID = 0) Then
        Open C_getFirstTempID;
        fetch C_getFirstTempID into lCursorStrategyTempID;
        if C_getFirstTempID%FOUND then
            l_StrategyTempID := lCursorStrategyTempID;
        end if;
        Close C_getFirstTempID;
    end if;
    return l_StrategyTempID;
END;

PROCEDURE GetStrategyCurrentWorkItem
(
    p_DelinquencyID              IN   number,
    p_ObjectType                 IN   varchar2,
    p_ObjectID                   IN   number,
    x_StrategyID                 OUT NOCOPY  number,
    x_StrategyName		        OUT NOCOPY  varchar2,
    x_WorkItemID                 OUT NOCOPY  number,
    x_WorkItemName               OUT NOCOPY  VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
) IS

	l_result               VARCHAR2(10);
	l_error_msg            VARCHAR2(2000);
	l_return_status        VARCHAR2(20);
	l_msg_count            NUMBER;
	l_msg_data             VARCHAR2(2000);
	l_api_name             VARCHAR2(100) ;
	l_api_version_number   CONSTANT NUMBER   := 2.0;

	fStrategyID number;
    fWorkItemId number;
    fWorkItemName varchar2(240);
    fStrategyName varchar2(240);
	fStrategyVersionNumber number ;

    l_ObjectType    VARCHAR2(30);
	l_object_version_number number ;

    Cursor c_strategy(p_delinquency_id number, p_object_id number, p_object_type varchar2) is
        select s.strategy_id, st.strategy_name, s.next_work_item_id,  t.name from iex_strategies s,
             iex_strategy_templates_vl st,
             iex_strategy_work_items w,
			 iex_stry_temp_work_items_vl t
           where ((s.delinquency_id = p_delinquency_id and
            s.object_id = p_object_id and s.object_type = p_object_type)) and
            (s.checklist_yn IS NULL or s.checkList_YN = 'N')
            and s.strategy_template_id = st.strategy_temp_id(+)
            and s.next_work_item_id = w.work_item_id
		  and w.work_item_template_id = t.work_item_temp_id(+)
            order by s.creation_date desc;

--Start bug 6723540 gnramasa 02 Jan 08
    Cursor c_cont_strategy(p_object_id number, p_object_type varchar2) is
        select s.strategy_id, st.strategy_name, s.next_work_item_id,  t.name from iex_strategies s,
             iex_strategy_templates_vl st,
             iex_strategy_work_items w,
			 iex_stry_temp_work_items_vl t
           where (s.object_id = p_object_id and s.object_type = p_object_type) and
            (s.checklist_yn IS NULL or s.checkList_YN = 'N')
            and s.strategy_template_id = st.strategy_temp_id(+)
            and s.next_work_item_id = w.work_item_id
		  and w.work_item_template_id = t.work_item_temp_id(+)
            order by s.creation_date desc;
--End bug 6723540 gnramasa 02 Jan 08

    l_strategy_rec IEX_STRATEGY_PVT.STRATEGY_REC_TYPE;

begin
    -- initialize variables
	l_api_name             := 'GetStrategyCurrentWorkItem';
	fStrategyVersionNumber := 2.0;
	l_object_version_number := 2.0;

    x_return_status := 'T';
    if (NVL(FND_PROFILE.VALUE('IEX_STRATEGY_DISABLED'), 'N') = 'Y') then
         return;
    end if;

    FND_MSG_PUB.initialize;

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage(
        debug_msg => 'PUB:' || G_PKG_NAME || '.' || l_api_name || ' Start',
        print_date => 'Y');
    END IF;


    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage(
        debug_msg => '1. D.ID= ' || p_delinquencyID || ' OID= ' || P_objectid || ' OT.= ' || P_objectType,
        print_date => 'Y');
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Start bug 6723540 gnramasa 02 Jan 08
    if p_delinquencyid is not null then
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		IEX_DEBUG_PUB.LogMessage(debug_msg => 'PUB:' || G_PKG_NAME || '.' || l_api_name ||' : p_delinquencyid = ' || p_delinquencyid,
		    print_date => 'Y');
	    END IF;
	    Open c_Strategy(p_delinquencyid, p_objectid, p_objecttype);
	    fetch c_Strategy into fStrategyID, fStrategyName, fWorkItemId, fWorkItemName;
	    Close C_Strategy;
    elsif p_objectid is not null then
	    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		IEX_DEBUG_PUB.LogMessage(debug_msg => 'PUB:' || G_PKG_NAME || '.' || l_api_name ||' : p_objectid = ' || p_objectid,
		    print_date => 'Y');
	    END IF;
	    Open c_cont_Strategy(p_objectid, p_objecttype);
	    fetch c_cont_Strategy into fStrategyID, fStrategyName, fWorkItemId, fWorkItemName;
	    Close c_cont_Strategy;
    else
	   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		IEX_DEBUG_PUB.LogMessage(debug_msg => 'PUB:' || G_PKG_NAME || '.' || l_api_name ||' : p_delinquencyid and p_objectid is NULL',
		    print_date => 'Y');
	    END IF;
	    return;
    end if;
    --End bug 6723540 gnramasa 02 Jan 08

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage(
            debug_msg => '4. WorkItemName=' || fWorkItemName,
            print_date => 'Y');
    END IF;

    if (fStrategyID > 0) then
        x_strategyId := fStrategyId;
        x_strategyName := fStrategyName;
        x_workitemID := fWorkItemID;
        x_workItemName := fWorkItemName;
    else
        x_return_status := 'F';

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage(debug_msg => 'IEX_NO_STRATEGY_EXISTS ' || p_DelinquencyID,
            print_date => 'Y');
        END IF;

        FND_MESSAGE.Set_Name('IEX', 'IEX_NO_STRATEGIES_EXIST');
        FND_MESSAGE.Set_Token('OBJECT_ID', to_char(p_DelinquencyID));
        FND_MSG_PUB.ADD;

        RAISE FND_API.G_EXC_ERROR;

    end if;

EXCEPTION
    WHEN NO_DATA_FOUND then
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage(debug_msg => 'IEX_NO_STRATEGIES_EXIST ' || p_DelinquencyID,
            print_date => 'Y');
        END IF;

        FND_MESSAGE.Set_Name('IEX', 'IEX_NO_STRATEGIES_EXIST');
        FND_MESSAGE.Set_Token('OBJECT_ID', to_char(p_DelinquencyID));
        FND_MSG_PUB.ADD;

	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
end;

/* CLOSES STRATEGY
    P_API_VERSION_NUMBER := 2.0
    Delinquency_iD = delinquency ID
      Object_Type = DELINQUENT, BANKRUPTCY, WRITEOFF, LITIGATION, REPOSSESSION
      Object_ID = DelinquencyID, BankruptcyID, writeoffid, litigationid, repossessionid
*/

PROCEDURE  close_strategy
(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_DelinquencyID              IN   number,
    p_ObjectType                 IN   varchar2,
    p_ObjectID                   IN   number
) IS

	l_result       VARCHAR2(10);
	l_error_msg            VARCHAR2(2000);
	l_return_status        VARCHAR2(20);
	l_msg_count            NUMBER;
	l_msg_data             VARCHAR2(2000);
	l_api_name             VARCHAR2(100) ;
	l_api_version_number   CONSTANT NUMBER   := 2.0;

	fdelinquencyId number;
	fPartyCustId number;
	fCustAccountId number;
    fCustomerSiteUseId number;
	fTransactionId number;
	fPaymentScheduleid number;
	fObjectId number;
	fobjectType varchar2(40);
	fScoreValue number;
	fStrategyID number;
	fStrategyVersionNumber number ;

    l_ObjectType    VARCHAR2(30);
	l_object_version_number number ;
    vStrategyStatus         VARCHAR2(30);

    TYPE c_open_strategiesCurTyp IS REF CURSOR;  -- weak
    c_open_strategies c_open_strategiesCurTyp;  -- declare cursor variable
    /*
    Cursor c_strategy_exists(p_delinquency_id number, p_object_id number, p_object_type varchar2) is
        select strategy_id, status_code, object_version_number from iex_strategies where ((delinquency_id = p_delinquency_id and
            object_id = p_object_id and object_type = p_object_type)) and (checklist_yn IS NULL or checkList_YN = 'N');
    */
    l_strategy_rec IEX_STRATEGY_PVT.STRATEGY_REC_TYPE;

    l_Init_Msg_List              VARCHAR2(10)   ;
    l_Commit                     VARCHAR2(10)   ;
    l_validation_level           NUMBER     ;
BEGIN
    -- initialize variable
    l_Init_Msg_List := P_Init_Msg_List;
    l_Commit := P_Commit;
    l_validation_level  := p_validation_level;
    if (l_Init_msg_List is null) then
      l_Init_Msg_List              := FND_API.G_FALSE;
    end if;
    if (l_Commit is null) then
      l_Commit                     := FND_API.G_FALSE;
    end if;
    if (l_validation_level is null) then
      l_validation_level           := FND_API.G_VALID_LEVEL_FULL;
    end if;

    l_api_name             := 'CLOSE_STRATEGY';

    --Start adding for bug 8834310 gnramasa 26th Aug 09
    begin
    select decode(preference_value, 'CUSTOMER', 10, 'ACCOUNT', 20, 'BILL_TO', 30, 'DELINQUENCY', 40,  40)
      into l_DefaultStrategyLevel
      from iex_app_preferences_b
       where  preference_name = 'COLLECTIONS STRATEGY LEVEL' and enabled_flag = 'Y' and org_id is null;   -- Changed for bug 8708271 multi level strategy
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage( 'Default StrategyLevel ' || l_DefaultStrategyLevel);
    END IF;
    EXCEPTION
            WHEN OTHERS THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                    IEX_DEBUG_PUB.LogMessage( 'Strategy Level Rised Exception ');
                    END IF;
                    l_DefaultStrategyLevel := 40;
    END;
    --End adding for bug 8834310 gnramasa 26th Aug 09

    fStrategyVersionNumber := 2.0;
    l_object_version_number := 2.0;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    if (NVL(FND_PROFILE.VALUE('IEX_STRATEGY_DISABLED'), 'N') = 'Y') then
         return;
    end if;
    -- Standard Start of API savepoint
    SAVEPOINT SET_STRATEGY;

    -- Initialize API return status to SUCCESS
    l_return_status := FND_API.G_RET_STS_SUCCESS;
    l_objectType := UPPER(p_ObjectType);


    -- Initialize message list IF p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( l_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage(
        debug_msg => 'PUB:' || G_PKG_NAME || '.' || l_api_name || ' Start',
        print_date => 'Y');
    END IF;

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage(
        debug_msg => '1. D.ID= ' || p_delinquencyID || ' OID= ' || P_objectid || ' OT.= ' || P_objectType,
        print_date => 'Y');
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_object_version_number := 1;
    vStrategyStatus :=  NULL;


    IF l_DefaultStrategyLevel = 10  THEN
         OPEN c_open_strategies
          FOR
           select strategy_id, status_code, object_version_number from iex_strategies
           where (party_id = p_objectid and object_id = p_objectid and object_type = p_objecttype)
            and (checklist_yn IS NULL or checkList_YN = 'N') and Status_Code not in ('CLOSED', 'CANCELLED');

      elsif l_DefaultStrategyLevel = 20 THEN
          OPEN c_open_strategies
	       FOR
           select strategy_id, status_code, object_version_number from iex_strategies
           where (cust_account_id = p_objectid and object_id = p_objectid and object_type = p_objecttype)
            and (checklist_yn IS NULL or checkList_YN = 'N') and Status_Code not in ('CLOSED', 'CANCELLED');
      elsif l_DefaultStrategyLevel = 30 THEN
          OPEN c_open_strategies
	       FOR
           select strategy_id, status_code, object_version_number from iex_strategies
           where (customer_site_use_id = p_objectid and object_id = p_objectid and object_type = p_objecttype)
            and (checklist_yn IS NULL or checkList_YN = 'N') and Status_Code not in ('CLOSED', 'CANCELLED');
      ELSE
         OPEN c_open_strategies
          FOR
           select strategy_id, status_code, object_version_number from iex_strategies
           where (delinquency_id = p_delinquencyid and object_id = p_objectid and object_type = p_objecttype)
            and (checklist_yn IS NULL or checkList_YN = 'N') and Status_Code not in ('CLOSED', 'CANCELLED');
      END IF;
    -- Open c_Strategy_Exists(p_delinquencyid, p_objectid, p_objecttype);
    fetch c_open_strategies into fStrategyID, vStrategyStatus, fStrategyVersionNumber;
    Close c_open_strategies;

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage(
            debug_msg => '4. Current S.St=' || vStrategyStatus ,
            print_date => 'Y');
    END IF;

    if ((fStrategyID IS NOT NULL) and vStrategyStatus NOT IN ('CLOSED', 'CANCELLED')) then

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage(
            debug_msg => '5. Update strategy ' || fStrategyID,
            print_date => 'Y');
        END IF;

        l_strategy_rec.strategy_id := fStrategyId;
        l_strategy_rec.object_version_number := fStrategyVersionNumber;
        l_strategy_rec.status_code := 'CLOSED';

        Begin

            iex_strategy_pvt.update_strategy(
                P_Api_Version_Number=>2.0,
                p_commit =>  FND_API.G_FALSE,
                P_Init_Msg_List     =>FND_API.G_FALSE,
                p_strategy_rec => l_strategy_rec,
                x_return_status=>l_return_status,
                x_msg_count=>l_msg_count,
                x_msg_data=>l_msg_data,
                xo_object_version_number => l_object_version_number
            );

            if (x_return_status <> 'S') then
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            end if;

        EXCEPTION
            WHEN OTHERS THEN
                IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                IEX_DEBUG_PUB.LogMessage(
                    debug_msg => 'IEX_STRATEGY_UPDATE_FAILED' || fObjectID,
                    print_date => 'Y');
                END IF;

                FND_MESSAGE.Set_Name('IEX', 'IEX_STRATEGY_UPDATE_FAILED');
                FND_MSG_PUB.ADD;

                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END;

         -- Standard check for p_commit
        IF FND_API.to_Boolean(l_commit) THEN
            COMMIT WORK;
        END IF;

        IEX_STRATEGY_WF.SEND_SIGNAL(process     => 'IEXSTRY',
                  strategy_id => fStrategyId,
                  status      => 'CLOSED' ) ;

   end if;
    -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data
     );

    IEX_DEBUG_PUB.LogMessage('Delinquency cursor ends' );


EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    		FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                END IF;
                FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END;


BEGIN
    -- initialize variables
    PG_DEBUG := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_MsgLevel := NVL(to_number(FND_PROFILE.VALUE('FND_AS_MSG_LEVEL_THRESHOLD')), FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
    l_DefaultTempID := GetDefaultStrategyTempID;

    --Start adding for bug 8834310 gnramasa 26th Aug 09
    /*
        begin
    select decode(preference_value, 'CUSTOMER', 10, 'ACCOUNT', 20, 'BILL_TO', 30, 'DELINQUENCY', 40,  40)
      into l_DefaultStrategyLevel
      from iex_app_preferences_b
       where  preference_name = 'COLLECTIONS STRATEGY LEVEL' and enabled_flag = 'Y' and org_id is null;   -- Changed for bug 8708271 multi level strategy
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage( 'Default StrategyLevel ' || l_DefaultStrategyLevel);
    END IF;
    EXCEPTION
            WHEN OTHERS THEN
                    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                    IEX_DEBUG_PUB.LogMessage( 'Strategy Level Rised Exception ');
                    END IF;
                    l_DefaultStrategyLevel := 40;
    END;
    */
    --End adding for bug 8834310 gnramasa 26th Aug 09

END IEX_STRATEGY_PUB;

/
