--------------------------------------------------------
--  DDL for Package Body IGI_SIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_SIA" AS
-- $Header: igisiaab.pls 120.7.12000000.1 2007/09/12 11:47:09 mbremkum ship $
p_return_message VARCHAR2(240);

PROCEDURE insert_sec_hold
	( p_InvoiceId NUMBER
	, p_LastUpdatedBy NUMBER
	) IS
v_org_id number(15,0);
BEGIN
  p_return_message := IGI_GEN.GET_LOOKUP_MEANING('IGI_SIA_AWAITING');

  /*  bug # 5905278 start R12 uptake of SIA - query to fetch the org_id */
  begin
   select org_id
   into v_org_id
   from ap_invoices
   where invoice_id = p_InvoiceId;
   exception
    when others then
    null;
   end;
  /* bug # 5905278 end */

	INSERT INTO AP_HOLDS
		( INVOICE_ID
		, HOLD_LOOKUP_CODE
		, LAST_UPDATE_DATE
		, LAST_UPDATED_BY
		, HELD_BY
		, HOLD_DATE
		, HOLD_REASON
		, CREATION_DATE
		, CREATED_BY
                , HOLD_ID   /* added for bug # 5905278 R12 Uptake of SIA */
		, ORG_ID   /* added for bug # 5905278 R12 Uptake of SIA */
                )
	SELECT
		p_InvoiceId
		, 'AWAIT_SEC_APP'
		, sysdate
		, p_LastUpdatedBy
		, p_LastUpdatedBy
		, sysdate
                , p_return_message
		, sysdate
		, p_LastUpdatedBy
                , AP_HOLDS_S.nextval   /* added for bug # 5905278 R12 Uptake of SIA */
                , v_org_id       /* added for bug # 5905278 R12 Uptake of SIA */
	FROM sys.dual
	WHERE NOT EXISTS ( SELECT 1
			   FROM ap_holds_all
			   WHERE invoice_id = p_InvoiceId
			   AND hold_lookup_code in ( 'AWAIT_SEC_APP',
                                                     'AWAIT_PAY_APP')
                           AND release_lookup_code is NULL
			 );

	EXCEPTION
                WHEN OTHERS THEN null;
END;
--
PROCEDURE release_holds
	( p_InvoiceId 		NUMBER
	, p_LastUpdatedBy 	NUMBER
	) IS
--
BEGIN

	UPDATE AP_HOLDS
	SET	  RELEASE_LOOKUP_CODE = 'MOD_RELEASE'
		, RELEASE_REASON = 	'Invoice Modified'
		, LAST_UPDATE_DATE =	sysdate
		, LAST_UPDATED_BY =	p_LastUpdatedBy
		WHERE 	invoice_id = p_InvoiceId
		AND	hold_lookup_code IN
			('AWAIT_SEC_APP', 'AWAIT_PAY_APP')
		AND	release_lookup_code is null;
END;
--

PROCEDURE SET_INVOICE_ID
		( p_inv_id		NUMBER
		, p_upd_by		NUMBER
	        , p_status              NUMBER
         	) IS
--
BEGIN
	l_TableRow			:=	l_TableRow + 1;
	l_InvoiceIdTable(l_TableRow)	:=	p_inv_id;
	l_UpdatedByTable(l_TableRow)	:=	p_upd_by;
	l_StatusTable(l_TableRow)	:=      p_status;
END;
--
PROCEDURE PROCESS_INVOICE_HOLDS (p_inv_id  NUMBER,
                                 p_upd_by  NUMBER) IS
--
-- This process checks following cases
-- 1. Invoice is approved by core functionality no holds placed. i.e. a new invoice
-- 2. Invoice was amended after secondary hold was placed and is approved by core functionality
-- 3. Invoice was amended after secondary hold was release and was awaiting payment hold release
--    and is approved by core functionality.
--  NOTE : Approved by core functionality means approval package has run successfully and has not
--         placed any non-SIA holds.
--
--   Added cancellation functionality, check sum(amount) = 0 for all dist. lines

 CURSOR c IS
  Select 1
  From   AP_INVOICE_DISTRIBUTIONS_ALL
  Where  Invoice_id = p_inv_id
  AND    NVL(match_status_flag,'N') <> 'A';

 CURSOR c1(p_hold  VARCHAR2) IS
  Select hold_lookup_code
  From   AP_HOLDS
  Where  invoice_id = p_inv_id
  And    hold_lookup_code = p_hold
  And    release_lookup_code is null;

 CURSOR c2 IS
  Select sum(nvl(amount,0))
  From   AP_INVOICE_DISTRIBUTIONS_ALL
  Where  Invoice_id = p_inv_id;

 CURSOR c3 IS
  Select hold_lookup_code
  From   AP_HOLDS
  Where  invoice_id = p_inv_id
  And    hold_lookup_code = 'AWAIT_PAY_APP';

 CURSOR c4 IS
  Select COUNT(1)
  From   AP_INVOICE_DISTRIBUTIONS_ALL
  Where  Invoice_id = p_inv_id
  and reversal_flag = 'Y';

  l_hold_lookup_code AP_HOLDS.hold_lookup_code%TYPE;
  l_count            NUMBER;
  l_sum              NUMBER;
  l_reverse_flag_cnt NUMBER;

 CURSOR cur_get_core_hold_count IS
  Select COUNT(1)
  From   AP_HOLDS
  Where  invoice_id = p_inv_id
  And    hold_lookup_code <> 'AWAIT_SEC_APP'
  And    Release_Lookup_code is Null;

 l_cnt NUMBER;

BEGIN
--Initialized inside BEGIN because of GSCC Standard - File.Sql.35

  l_hold_lookup_code := NULL;
  l_reverse_flag_cnt := 0;
  l_count  := 0;
  l_sum    := 0;

  l_cnt    := 0;
--
-- Check if any distribution line not approved by core functionality i.e approval package
--
  OPEN c;
  FETCH c INTO l_count;
  IF c%NOTFOUND THEN
     l_count := 0;
  END IF;
  CLOSE c;

       -- Bug 3409394 Start (1) --

	 OPEN cur_get_core_hold_count;
	 FETCH cur_get_core_hold_count INTO l_cnt;
	 close cur_get_core_hold_count;

       -- Bug 3409394 End (1) --


 IF l_count = 0 THEN
--
--  Check if the invoice is cancelled. i.e. Total Distribution amount = 0;
--  Bug 3409394
--  To truely check that the invoice is cancelled, you will need to check that
--  that invoice dist. add to zero, but also need check that the reversal_flag
--  is 'Y', otherwise it may be a pre-payment which has reversed the charges
--  in the distribution lines. There are many methods for checking invoice is
--  truely cancelled, but the easiest method is checking the reversal_flag, as
--  it does get set in the 'ap_cancel_pkg', for a cancelled invoice.
--
      OPEN c2;
      FETCH c2 INTO l_sum;
      CLOSE c2;

    -- Bug 3671954 Start (1) --
      OPEN c4;
      FETCH c4 INTO l_reverse_flag_cnt;
      CLOSE c4;
    -- Bug 3671954 End (1) --
--
-- If Invoice is not cancelled
--
      IF l_sum <> 0 OR l_reverse_flag_cnt = 0 THEN  -- Bug 3671954

--
--  If no such distribution line i.e. all are approved by approval package
--  check if there is any existing secondary hold  , ignore any other holds
--  placed by core functionality . In case of amendment a Secondary hold may
--  already exist.
--


    IF l_cnt = 0 then		-- Bug 3409394 Start (2) Only IF Condition

        OPEN c1('AWAIT_SEC_APP');
         FETCH c1 INTO l_hold_lookup_code;
         IF c1%NOTFOUND THEN
            l_hold_lookup_code := null;
         END IF;
         CLOSE c1;
--
-- If no hold exists then place secondary hold : case 1
--
         IF l_hold_lookup_code is NULL THEN
            insert_sec_hold(p_inv_id,p_upd_by);
         ELSIF l_hold_lookup_code = 'AWAIT_PAY_APP' then
-- if payment hold exists then Release Payment hold and place sec hold case 3
                release_holds(p_inv_id,p_upd_by);
                insert_sec_hold(p_inv_id,p_upd_by);
	 END IF;
      END IF;  -- If invoice is cancelled i.e sum = 0 then handle in trigger on
--                AP_INVOICES_ALL calling REVERSE_HOLDS.

   END IF; 	-- Bug 3409394 Start (2) Only END IF Condition

-- if only secondary exists or any other hold exists don't do anything
  ELSE
-- If there is an unapproved distribution line then check if a payment hold exists i.e. if invoice
-- was awaiting payment approval. release it and place secondary approval hold.
--


    OPEN c1('AWAIT_PAY_APP');
     FETCH c1 INTO l_hold_lookup_code;
     IF c1%NOTFOUND THEN
        l_hold_lookup_code := null;
     END IF;
     CLOSE c1;
     IF l_hold_lookup_code = 'AWAIT_PAY_APP' THEN
           release_holds(p_inv_id,p_upd_by);
           insert_sec_hold(p_inv_id,p_upd_by);
     END IF;


-- else donot release any other hold including secondary hold.
  END IF;

END;

PROCEDURE REVERSE_HOLDS (p_inv_id  NUMBER,
                         p_upd_by  NUMBER) IS
--
-- This procedure releases PAYMENT hold but places SECONDARY hold, this is
-- required if an invoice is cancelled
-- Release SECONDARY HOLD if invoice is cancelled. Bug - 1346321
-- added afterbug 1346321- all holds are release on cancellation
-- as cancellation adds more distribution lines i.e. same functionaliy as
-- amendment.
 CURSOR c1 IS
  Select hold_lookup_code
  From   AP_HOLDS
  Where  invoice_id = p_inv_id
  And    hold_lookup_code = 'AWAIT_PAY_APP';

 CURSOR c2 IS
  Select hold_lookup_code
  From   AP_HOLDS
  Where  invoice_id = p_inv_id
  And    hold_lookup_code = 'AWAIT_SEC_APP'
  AND    release_lookup_code = 'SEC_APP';

  l_hold_lookup_code AP_HOLDS.hold_lookup_code%TYPE;

BEGIN
--Intialized variable inside BEGIN because of GSCC Standard - File.Sql.35
l_hold_lookup_code := NULL;

  IF FND_PROFILE.VALUE('IGI_SIA_PAYMENT_APP') = 'Y' THEN
     OPEN c1;
     FETCH c1 INTO l_hold_lookup_code;
     IF c1%FOUND THEN
        insert_sec_hold(p_inv_id,p_upd_by);
     END IF;
     CLOSE c1;
  ELSE
     OPEN c2;
     FETCH c2 INTO l_hold_lookup_code;
     IF c2%FOUND THEN
        insert_sec_hold(p_inv_id,p_upd_by);
     END IF;
     CLOSE c2;
  END IF;
END;

PROCEDURE PROCESS_HOLDS
IS
l_Var	NUMBER(15);
p_invoice_Id NUMBER;
BEGIN
--Intialized variable inside BEGIN because of GSCC Standard - File.Sql.35
l_var := 0;
p_invoice_id := 0;

	FOR i in 1..l_TableRow
	LOOP
	l_Var	:=	l_Var + 1;
	  IF l_StatusTable(l_var) = 0 THEN
            IF p_invoice_id <> l_InvoiceIdTable(l_var)  THEN
              IGI_SIA.PROCESS_INVOICE_HOLDS
				( l_InvoiceIdTable(l_Var)
				, l_UpdatedByTable(l_Var)
				);
              p_invoice_id := l_InvoiceIdTable(l_Var);
            END IF;
	  l_StatusTable(l_var):= 1;
	  END IF;
	END LOOP;
        l_Var            := 0;
END;

PROCEDURE RELEASE_HOLDS
IS
l_Var	NUMBER(15);
p_invoice_Id NUMBER;
BEGIN
--Intialized variable inside BEGIN because of GSCC Standard - File.Sql.35
l_var := 0;
p_invoice_id := 0;

	FOR i in 1..l_TableRow
	LOOP
	l_Var	:=	l_Var + 1;
	  IF l_StatusTable(l_var) = 0 THEN
            IF p_invoice_id <> l_InvoiceIdTable(l_var) THEN
              IGI_SIA.release_holds
				( l_InvoiceIdTable(l_Var)
				, l_UpdatedByTable(l_Var)
				);
              p_invoice_id := l_InvoiceIdTable(l_Var);
            END IF;
	  l_StatusTable(l_var):= 1;
          END IF;
	END LOOP;
        l_Var            := 0;
END;
END;	-- package body

/
