--------------------------------------------------------
--  DDL for Package Body XTR_DNM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_DNM_PKG" AS
/* $Header: xtrdnmpb.pls 120.6.12010000.2 2008/08/06 10:43:10 srsampat ship $ */


PROCEDURE AUTHORIZE(p_batch_id in NUMBER) IS

Cursor cur_dnm(p_batch_id in number) is
SELECT
     A.COMPANY_CODE
   , A.DEAL_NO
   , A.REVAL_CCY
   , SOB.CURRENCY_CODE SOB_CCY
   , A.PERIOD_TO
   , A.TRANSACTION_NO
   , A.BATCH_ID
   , decode(A.REALIZED_FLAG,'Y',A.REALISED_PL,A.UNREALISED_PL)  REAL_UNREAL_AMT -- replaced A.CUMM_GAIN_LOSS_AMOUNT
   , A.CURR_GAIN_LOSS_AMOUNT
   , A.REALIZED_FLAG
   , decode(A.DEAL_TYPE,'BOND',decode(A.AMOUNT_TYPE,'UNREAL','UNREAL' ,'REALAMC','REALAMC','REAL','REAL'),decode(A.REALIZED_FLAG,'Y','REAL','N','UNREAL'))   AMOUNT_TYPE
   , decode(A.DEAL_TYPE,'BOND',decode(A.AMOUNT_TYPE,'UNREAL','CCYUNRL','REALAMC','CCYAMRL','REAL','CCYREAL'),decode(A.REALIZED_FLAG,'Y','CCYREAL','N','CCYUNRL')) CURR_AMOUNT_TYPE
   , decode(sign(decode(A.REALIZED_FLAG,'Y',A.REALISED_PL,A.UNREALISED_PL)),-1,'LOSS','PROFIT') ACTION
   , decode(sign(A.CURR_GAIN_LOSS_AMOUNT),-1,'LOSS','PROFIT') CURR_ACTION
   , B.PERIOD_END
   , 'REVAL' DATE_TYPE
FROM
   XTR_REVALUATION_DETAILS A,
   XTR_BATCHES B,
   XTR_BATCH_EVENTS C,
   XTR_PARTIES_V P,
   GL_SETS_OF_BOOKS SOB
WHERE B.BATCH_ID 	     = p_batch_id
AND   B.BATCH_ID	     = A.BATCH_ID
AND   B.BATCH_ID	     = C.BATCH_ID
AND   C.EVENT_CODE	     = 'REVAL'
AND   P.PARTY_CODE	     = A.COMPANY_CODE
AND   P.CHART_OF_ACCOUNTS_ID = SOB.CHART_OF_ACCOUNTS_ID
AND   P.SET_OF_BOOKS_ID      = SOB.SET_OF_BOOKS_ID
AND   nvl(C.AUTHORIZED,'N')  <> 'Y'
AND   nvl(B.UPGRADE_BATCH,'N') <> 'Y'
AND  ( nvl(nvl(A.REALISED_PL,A.UNREALISED_PL),0) <> 0 OR nvl(A.CURR_GAIN_LOSS_AMOUNT,0) <> 0 )
--AND  ( nvl(A.CUMM_GAIN_LOSS_AMOUNT,0) <> 0 OR nvl(A.CURR_GAIN_LOSS_AMOUNT,0) <> 0 )
order by A.DEAL_NO;

Cursor cur_count IS
SELECT COUNT(*)
FROM   XTR_REVALUATION_DETAILS
WHERE  batch_id = p_batch_id
AND    complete_flag = 'N';

l_amount_type XTR_AMOUNT_TYPES.AMOUNT_TYPE%TYPE;
l_curr_amount_type XTR_AMOUNT_TYPES.AMOUNT_TYPE%TYPE;
row_id 	      VARCHAR2(64);
l_dnm_id      NUMBER;
l_count       NUMBER;

Begin
--xtr_debug_pkg.enable_file_debug;
IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
   xtr_debug_pkg.debug('>> BEGIN: XTR_DNM_PKG.AUTHORIZE');
END IF;

Open  cur_count;
Fetch cur_count INTO l_count;
Close cur_count;

If nvl(l_count,1) = 0 Then
   For dnm_rec in cur_dnm(p_batch_id)

   Loop

-- If nvl(dnm_rec.CUMM_GAIN_LOSS_AMOUNT,0) <> 0 Then
   If nvl(dnm_rec.REAL_UNREAL_AMT,0) <> 0 Then
      select XTR_GAIN_LOSS_DNM_S.nextval into l_dnm_id from dual;

      XTR_GAIN_LOSS_DNM_PKG.INSERT_ROW(
	row_id,
   	l_dnm_id ,
	dnm_rec.BATCH_ID,
	dnm_rec.COMPANY_CODE,
	dnm_rec.DEAL_NO,
	dnm_rec.TRANSACTION_NO,
	dnm_rec.date_type,
	abs(dnm_rec.real_unreal_amt),       -- replaced abs(dnm_rec.CUMM_GAIN_LOSS_AMOUNT),
	dnm_rec.amount_type,
	dnm_rec.action,
	dnm_rec.REVAL_CCY,
        dnm_rec.PERIOD_TO,
        'R',    -- Revaluation process flag
	sysdate,
	fnd_global.user_id,
	sysdate,
	fnd_global.user_id,
	fnd_global.login_id
	);
   End If;

     If nvl(dnm_rec.CURR_GAIN_LOSS_AMOUNT,0) <> 0 Then

       select XTR_GAIN_LOSS_DNM_S.nextval into l_dnm_id from dual;

      XTR_GAIN_LOSS_DNM_PKG.INSERT_ROW(
	row_id,
   	l_dnm_id,
	dnm_rec.BATCH_ID,
	dnm_rec.COMPANY_CODE,
	dnm_rec.DEAL_NO,
	dnm_rec.TRANSACTION_NO,
	dnm_rec.date_type,
	abs(dnm_rec.CURR_GAIN_LOSS_AMOUNT),
	dnm_rec.curr_amount_type,
	dnm_rec.curr_action,
	dnm_rec.SOB_CCY,  -- replaced dnm_rec.REVAL_CCY with dnm_rec.SOB_CCY,
        dnm_rec.PERIOD_TO,
        'R',    -- Revaluation process flag
	sysdate,
	fnd_global.user_id,
	sysdate,
	fnd_global.user_id,
	fnd_global.login_id
	);
      End If;

   End Loop;

  Begin
      Update XTR_BATCH_EVENTS
      set    AUTHORIZED 	= 'Y',
	     AUTHORIZED_BY = FND_GLOBAL.USER_ID,
	     AUTHORIZED_ON = SYSDATE,
             LAST_UPDATED_BY   = FND_GLOBAL.USER_ID,
	     LAST_UPDATE_DATE  = SYSDATE,
	     LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
      where  BATCH_ID = p_batch_id
      and    EVENT_CODE  = 'REVAL'
      and    nvl(AUTHORIZED,'N')  <> 'Y';

      if (sql%notfound) then
         raise no_data_found;
      end if;
   Exception
	When Others Then
	IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	   xtr_debug_pkg.debug('AUTHORIZE: ' || '>>EXCEPTION: Error updating XTR_BATCH_EVENTS');
	END IF;
      Raise;
   End;

Else
    NULL;
    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
       xtr_debug_pkg.debug('>>XTR_DNM_PKG.AUTHORIZE-->Can not Authorize with incomplete reval details');
    END IF;
End If;

EXCEPTION
	When Others Then
	IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
	   xtr_debug_pkg.debug('AUTHORIZE: ' || '>>EXCEPTION: Error in XTR_GAIN_LOSS_DNM_PKG.INSERT_ROW');
	END IF;
	Raise;
End AUTHORIZE;


PROCEDURE UNAUTHORIZE(p_batch_id in NUMBER) IS

   -- Bug 2685848 additions.

   Cursor DNM is
   Select rowid
   From   XTR_GAIN_LOSS_DNM A
   where  A.BATCH_ID = p_batch_id
   and    EXISTS (select 'Dummy' from XTR_BATCH_EVENTS  B
	            where   B.BATCH_ID = A.BATCH_ID
		    and     B.EVENT_CODE = 'REVAL'
		    and     B.AUTHORIZED = 'Y')
   and    NOT EXISTS (select 'X' from XTR_BATCH_EVENTS  C
	   		    where   C.BATCH_ID = A.BATCH_ID
		  	    and     C.EVENT_CODE = 'JRNLGN')
   for update nowait;

   Cursor BE is
   Select rowid
   From   XTR_BATCH_EVENTS
   Where  BATCH_ID = p_batch_id
     and  EVENT_CODE  = 'REVAL'
     and  AUTHORIZED  = 'Y'
     for update of batch_id nowait;

   l_rowid		rowid;
   l_err_table		number;
   l_err_num		number;
   l_err_msg		varchar2(100);

   -- End bug 2685848 additions.
Begin

   -- Bug 2685848 start modifications.
   -- Ensure all records to be deleted/updated can be successfully accessed
   -- before actual execution.

   l_err_table := 1;
   Open DNM;
   Loop
      Fetch DNM into l_rowid;
      Exit when DNM%NOTFOUND;

      Delete from XTR_GAIN_LOSS_DNM
      Where  rowid = l_rowid;
   End Loop;
   Close DNM;

   l_err_table := 2;
   Open BE;
   Loop
      Fetch BE into l_rowid;
      Exit when BE%NOTFOUND;

      Update XTR_BATCH_EVENTS
      set    AUTHORIZED = 'N',
             AUTHORIZED_BY = NULL,
	     AUTHORIZED_ON = NULL,
             LAST_UPDATED_BY   = FND_GLOBAL.USER_ID,
	     LAST_UPDATE_DATE  = SYSDATE,
	     LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
      where  rowid = l_rowid;
   End Loop;
   Close BE;

EXCEPTION
   When app_exception.record_lock_exception then
      If (xtr_debug_pkg.pg_sqlplus_enable_flag = 1) THEN
         xtr_debug_pkg.debug('>>XTR_DNM_PKG.UNAUTHORIZE --> Unable to lock records');
      End If;
      If (DNM%ISOPEN) then
         Close DNM;
      End If;
      If (BE%ISOPEN) then
         Close BE;
      End If;
      If (l_err_table = 1) then
         FND_MESSAGE.Set_Name ('XTR', 'XTR_DNM_LOCKED');
      Elsif (l_err_table = 2) then
         FND_MESSAGE.Set_Name ('XTR', 'XTR_REVAL_EVENT_LOCKED');
      End If;
      App_Exception.Raise_Exception;
/*
   When no_data_found then
dbms_output.put_line ('no data found exception');
      If (DNM%ISOPEN) then
         Close DNM;
      End If;
      If (BE%ISOPEN) then
         Close BE;
      End If;
      IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
         xtr_debug_pkg.debug('>>XTR_DNM_PKG.UNAUTHORIZE-->No_Data_Found');
      END IF;
*/
   When Others Then
      If (DNM%ISOPEN) then
         Close DNM;
      End If;
      If (BE%ISOPEN) then
         Close BE;
      End If;
      IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
         xtr_debug_pkg.debug('>>EXCEPTION: Error in XTR_DNM_PKG.UNAUTHORIZE');
      END IF;
      l_err_num := SQLCODE;
      l_err_msg := SQLERRM(l_err_num);
      FND_MESSAGE.SET_NAME('XTR', 'XTR_UNHANDLED_EXCEPTION');
      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'XTR_DNM_PKG.Unauthorize');
      FND_MESSAGE.SET_TOKEN('EVENT', l_err_msg);
      App_Exception.Raise_Exception;
End UNAUTHORIZE;

END XTR_DNM_PKG;

/
