--------------------------------------------------------
--  DDL for Package Body AP_BANK_CHARGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_BANK_CHARGE_PKG" AS
/* $Header: apsudbcb.pls 120.6.12010000.5 2009/04/24 09:43:20 mayyalas ship $ */

   G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AP_BANK_CHARGE_PKG';
   G_MSG_UERROR        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
   G_MSG_ERROR         CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_ERROR;
   G_MSG_SUCCESS       CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
   G_MSG_HIGH          CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
   G_MSG_MEDIUM        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
   G_MSG_LOW           CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
   G_LINES_PER_FETCH   CONSTANT NUMBER       := 1000;

   G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   G_LEVEL_UNEXPECTED      CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
   G_LEVEL_ERROR           CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
   G_LEVEL_EXCEPTION       CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
   G_LEVEL_EVENT           CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
   G_LEVEL_PROCEDURE       CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
   G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
   G_MODULE_NAME           CONSTANT VARCHAR2(80) := 'AP_BANK_CHARGE_PKG';

PROCEDURE get_bank_number(
	P_bank_name		IN	VARCHAR2,
	P_bank_number		IN OUT NOCOPY	VARCHAR2) IS

    CURSOR C_bank(X_bank_name VARCHAR2)IS
	SELECT bank_number
	FROM   ce_bank_branches_v
	WHERE  bank_name = X_bank_name;

   l_debug_info   Varchar2(2000);
   l_api_name     CONSTANT VARCHAR2(100) := 'GET_BANK_NUMBER';

BEGIN

   l_debug_info := 'Getting the Bank Number';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

    OPEN C_bank(P_bank_name);
    FETCH C_bank INTO P_bank_number;
    CLOSE C_bank;

END get_bank_number;

PROCEDURE get_bank_branch_name(
	P_bank_branch_id	IN	NUMBER,
	P_bank_number		IN OUT NOCOPY	VARCHAR2,
	P_branch_number		IN OUT NOCOPY	VARCHAR2,
	P_branch_name		IN OUT NOCOPY	VARCHAR2) IS

   l_debug_info   Varchar2(2000);
   l_api_name     CONSTANT VARCHAR2(100) := 'GET_BANK_BRANCH_NAME';

BEGIN

    l_debug_info := 'Getting Bank Branch Info';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    select bank_number, branch_number, bank_branch_name
    into P_bank_number, P_branch_number, P_branch_name
    from ce_bank_branches_v
    where branch_party_id = p_bank_branch_id;

    exception
	when NO_DATA_FOUND then
           FND_MESSAGE.set_NAME('SQLAP','AP_DEBUG');
           FND_MESSAGE.set_TOKEN('ERROR',SQLERRM);
           FND_MESSAGE.set_TOKEN('DEBUG_INFO', 'Bank Branch Info can not be derived');
           APP_EXCEPTION.RAISE_EXCEPTION;
 	when OTHERS then
           IF (SQLCODE <> -20001) THEN
              FND_MESSAGE.set_NAME('SQLAP','AP_DEBUG');
              FND_MESSAGE.set_TOKEN('ERROR',SQLERRM);
              FND_MESSAGE.set_TOKEN('DEBUG_INFO',l_debug_info);
           END IF;

	   APP_EXCEPTION.RAISE_EXCEPTION;

END get_bank_branch_name;

PROCEDURE CHECK_BANK_COMBINATION(
		P_transferring_bank_branch_id 	IN 	NUMBER,
		P_transferring_bank_name	IN	VARCHAR2,
		P_transferring_bank		IN	VARCHAR2,
		P_transferring_branch		IN	VARCHAR2,
		P_receiving_bank_branch_id	IN	NUMBER,
		P_receiving_bank_name		IN	VARCHAR2,
		P_receiving_bank		IN	VARCHAR2,
		P_receiving_branch		IN	VARCHAR2,
		P_transfer_priority		IN	VARCHAR2,
		P_currency_code			IN	VARCHAR2) IS
    unique_check	NUMBER;
    RECORD_EXIST	EXCEPTION;
    l_debug_info   Varchar2(2000);
    l_api_name     CONSTANT VARCHAR2(100) := 'CHECK_BANK_COMBINATION';

begin

    l_debug_info := 'Checking Bank Combination';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    unique_check := 0;
    if (P_transferring_bank_branch_id is NULL) then
	if (P_receiving_bank_branch_id is NULL) then
	    if (P_transferring_bank = 'ONE') then
		if (P_receiving_bank = 'ONE') then
		    /*1A1A*/
                    l_debug_info := '*1A1A*';
                    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                    END IF;
		    select count(*) into unique_check
		    from ap_bank_charges
		    where transferring_bank_name = P_transferring_bank_name
		    and transferring_branch = P_transferring_branch
		    and receiving_bank_name = P_receiving_bank_name
		    and receiving_branch = P_receiving_branch
		    and transfer_priority = P_transfer_priority
		    and currency_code = P_currency_code;
		else /*1AAA*/
                    l_debug_info := '*1AAA*';
                    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                    END IF;

                    select count(*) into unique_check
                    from ap_bank_charges
                    where transferring_bank_name = P_transferring_bank_name
                    and transferring_branch = P_transferring_branch
                    and receiving_bank = P_receiving_bank
                    and receiving_branch = P_receiving_branch
                    and transfer_priority = P_transfer_priority
                    and currency_code = P_currency_code;
		end if;
	    else
		if (P_receiving_bank = 'ONE') then
		    /*AA1A*/
                    l_debug_info := '*AA1A*';
                    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                    END IF;

		    select count(*) into unique_check
		    from ap_bank_charges
		    where transferring_bank = P_transferring_bank
		    and transferring_branch = P_transferring_branch
		    and receiving_bank_name = P_receiving_bank_name
		    and receiving_branch = P_receiving_branch
		    and transfer_priority = P_transfer_priority
		    and currency_code = P_currency_code;
		else /*AAAA*/
                    l_debug_info := '*AAAA*';
                    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                    END IF;

		    select count(*) into unique_check
		    from ap_bank_charges
		    where transferring_bank = P_transferring_bank
		    and transferring_branch = P_transferring_branch
		    and receiving_bank = P_receiving_bank
		    and receiving_branch = P_receiving_branch
		    and transfer_priority = P_transfer_priority
		    and currency_code = P_currency_code;
		end if;
	    end if;
	else /*1A11*/
	    if (P_transferring_bank = 'ONE') then
                l_debug_info := '*1A11*';
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                END IF;

		select count(*) into unique_check
		from ap_bank_charges
		where transferring_bank_name = P_transferring_bank_name
		and transferring_branch = P_transferring_branch
		and receiving_bank_branch_id = P_receiving_bank_branch_id
		and transfer_priority = P_transfer_priority
		and currency_code = P_currency_code
                /* bug2191861 add check bank_name */
                and receiving_bank_name = P_receiving_bank_name ;
	    else /*AA11*/
                l_debug_info := '*AA11*';
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                END IF;

                select count(*) into unique_check
                from ap_bank_charges
                where transferring_bank = P_transferring_bank
                and transferring_branch = P_transferring_branch
                and receiving_bank_branch_id = P_receiving_bank_branch_id
                and transfer_priority = P_transfer_priority
                and currency_code = P_currency_code
        	/* bug2191861 add check bank_name */
		and receiving_bank_name = P_receiving_bank_name ;
	    end if;
	end if;
    elsif (P_receiving_bank_branch_id is NULL) then
        /* 11A1 */
	if (P_receiving_bank = 'ONE') then
           l_debug_info := '*11A1*';
           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
           END IF;

	    select count(*) into unique_check
	    from ap_bank_charges
	    where transferring_bank_branch_id = P_transferring_bank_branch_id
	    and receiving_bank_name = P_receiving_bank_name
	    and receiving_branch = P_receiving_branch
	    and transfer_priority = P_transfer_priority
	    and currency_code = P_currency_code
            /* bug2191861 add check bank_name */
            and transferring_bank_name = P_transferring_bank_name;
	else
           l_debug_info := '*111A*';
           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
           END IF;
            select count(*) into unique_check
            from ap_bank_charges
            where transferring_bank_branch_id = P_transferring_bank_branch_id
            and receiving_bank = P_receiving_bank
            and receiving_branch = P_receiving_branch
            and transfer_priority = P_transfer_priority
            and currency_code = P_currency_code
            /* bug2191861 add check bank_name */
 	    and transferring_bank_name = P_transferring_bank_name;
	end if/*P_receiving_bank_branch_id*/;
    else /*1111*/
       l_debug_info := '*1111*';
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;

	select count(*) into unique_check
	from ap_bank_charges
	where transferring_bank_branch_id = P_transferring_bank_branch_id
	and receiving_bank_branch_id = P_receiving_bank_branch_id
	and transfer_priority = P_transfer_priority
	and currency_code = P_currency_code
	/* bug2191861 add check bank_name */
        and receiving_bank_name = P_receiving_bank_name
        and transferring_bank_name = P_transferring_bank_name
        ;
    end if/*P_transferring_bank_branch_id*/;

    if (unique_check<> 0) then
	RAISE RECORD_EXIST;
    end if;
EXCEPTION
    WHEN RECORD_EXIST THEN
   	FND_MESSAGE.SET_NAME('SQLAP', 'AP_CHARGE_EXIST');
        APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.set_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.set_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.set_TOKEN('DEBUG_INFO', 'Transferring and Receiving Bank Combination'||
                              ' is Invalid');
        APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN OTHERS then
        IF (SQLCODE <> -20001) THEN
          FND_MESSAGE.set_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.set_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.set_TOKEN('DEBUG_INFO',l_debug_info);
        END IF;

end CHECK_BANK_COMBINATION;

PROCEDURE CHECK_RANGE_OVERLAP(
		X_bank_charge_id	IN	NUMBER) IS

    CURSOR C_lines(P_bank_charge_id NUMBER) IS
	select trans_amount_from, nvl(trans_amount_to, 99999999999999),
		start_date,
		nvl(end_date, to_date('31-12-4712', 'DD-MM-YYYY'))
	from ap_bank_charge_lines
	where bank_charge_id = P_bank_charge_id;

P_bank_charge_id	NUMBER;
v_trans_amount_from	ap_bank_charge_lines.trans_amount_from%type;
v_trans_amount_to	ap_bank_charge_lines.trans_amount_to%type;
v_start_date		ap_bank_charge_lines.start_date%type;
v_end_date		ap_bank_charge_lines.end_date%type;

overlap 	NUMBER;
l_debug_info   Varchar2(2000);
l_api_name     CONSTANT VARCHAR2(100) := 'CHECK_RANGE_OVERLAP';

AMOUNT_OVERLAP	EXCEPTION;

BEGIN

    l_debug_info := 'Checking Amount Range Overlap';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    overlap :=0;
    OPEN C_lines(X_bank_charge_id);
    LOOP
	FETCH C_lines INTO v_trans_amount_from,
			   v_trans_amount_to,
			   v_start_date,
			   v_end_date;
	EXIT WHEN C_lines%NOTFOUND;

        l_debug_info := 'Checking Whether any Amount Overlap exists';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;

	select count(*) INTO overlap
	from ap_bank_charge_lines
	where bank_charge_id = X_bank_charge_id
	and ((trans_amount_from <= v_trans_amount_from
	and nvl(trans_amount_to, 99999999999999)
		> v_trans_amount_from)
	or (trans_amount_from < v_trans_amount_to
	and nvl(trans_amount_to, 99999999999999)
		 >= v_trans_amount_to))
	and ((start_date <= v_start_date
	and nvl(end_date, to_date('31-12-4712', 'DD-MM-YYYY')) >
		v_start_date)
	or (start_date < v_end_date
	and nvl(end_date, to_date('31-12-4712', 'DD-MM-YYYY')) >=
		v_end_date));

	if (overlap >1) then
	    RAISE AMOUNT_OVERLAP;
	end if;
    END LOOP;
    CLOSE C_lines;

    EXCEPTION
    WHEN AMOUNT_OVERLAP THEN
	FND_MESSAGE.SET_NAME('SQLAP', 'AP_GAPS');
        APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN OTHERS THEN
        IF (SQLCODE <> -20001) THEN
          FND_MESSAGE.set_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.set_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.set_TOKEN('DEBUG_INFO',l_debug_info);
        END IF;
	APP_EXCEPTION.RAISE_EXCEPTION;
END CHECK_RANGE_OVERLAP;

PROCEDURE CHECK_RANGE_GAP(X_bank_charge_id 	IN	NUMBER) IS

CURSOR C_lines(P_bank_charge_id NUMBER) IS
        select trans_amount_from, start_date,
                nvl(end_date, to_date('31-12-4712', 'DD-MM-YYYY'))
        from ap_bank_charge_lines
        where bank_charge_id = P_bank_charge_id;

P_bank_charge_id        NUMBER;
v_trans_amount_from      ap_bank_charge_lines.trans_amount_from%type;
v_start_date            ap_bank_charge_lines.start_date%type;
v_end_date              ap_bank_charge_lines.end_date%type;

AMOUNT_GAP	EXCEPTION;
START_ZERO	EXCEPTION;
gap 		NUMBER;
zero_check	NUMBER;
l_debug_info   Varchar2(2000);
l_api_name     CONSTANT VARCHAR2(100) := 'CHECK_RANGE_GAP';


BEGIN

    l_debug_info := 'Checking Amount Range Gap';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    gap :=0;
    zero_check :=0;

    OPEN C_lines(X_bank_charge_id);
    LOOP
        FETCH C_lines INTO v_trans_amount_from,
                           v_start_date,
                           v_end_date;
        EXIT WHEN C_lines%NOTFOUND;

        l_debug_info := 'Checking whether Amount Range Gap exists';
        IF (G_LEVEL_STATEMENT  >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;

	if (v_trans_amount_from <> 0) then
            select count(*) INTO gap
            from ap_bank_charge_lines
            where bank_charge_id = X_bank_charge_id
            and trans_amount_to = v_trans_amount_from
            and ((start_date <= v_start_date
            and nvl(end_date, to_date('31-12-4712', 'DD-MM-YYYY')) >
                    v_start_date)
            or (start_date < v_end_date
            and nvl(end_date, to_date('31-12-4712', 'DD-MM-YYYY')) >=
                    v_end_date));
       	    if (gap = 0) then
            	RAISE AMOUNT_GAP;
            end if;

	else
	    zero_check := 1;
	end if;
    END LOOP;
    CLOSE C_lines;
    if (zero_check = 0) then
	RAISE START_ZERO;
    end if;
EXCEPTION
    WHEN AMOUNT_GAP THEN
	FND_MESSAGE.SET_NAME('SQLAP', 'AP_GAPS');
	APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN START_ZERO THEN
	FND_MESSAGE.SET_NAME('SQLAP', 'AP_NEED_ZERO');
        APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN OTHERS THEN
        IF (SQLCODE <> -20001) THEN
          FND_MESSAGE.set_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.set_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.set_TOKEN('DEBUG_INFO',l_debug_info);
        END IF;
	APP_EXCEPTION.RAISE_EXCEPTION;
END CHECK_RANGE_GAP;

PROCEDURE CHECK_LAST_RANGE(X_bank_charge_id  	IN	NUMBER) IS
CURSOR C_lines(P_bank_charge_id NUMBER) IS
        select  start_date,
                nvl(end_date, to_date('31-12-4712', 'DD-MM-YYYY'))
        from ap_bank_charge_lines
        where bank_charge_id = P_bank_charge_id
	and trans_amount_to is null;

v_trans_amount_from     ap_bank_charge_lines.trans_amount_from%type;
v_trans_amount_to	ap_bank_charge_lines.trans_amount_to%type;
v_start_date            ap_bank_charge_lines.start_date%type;
v_end_date              ap_bank_charge_lines.end_date%type;
cursor_check		NUMBER;
AMOUNT_GAP		EXCEPTION;
AMOUNT_OVERLAP		EXCEPTION;
l_debug_info   Varchar2(2000);
l_api_name     CONSTANT VARCHAR2(100) := 'CHECK_LAST_RANGE';


BEGIN

    l_debug_info := 'Checking Amount Last Range ';
    IF (G_LEVEL_STATEMENT  >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    cursor_check := 0;
    OPEN C_lines(X_bank_charge_id);
    LOOP
	FETCH C_lines INTO v_start_date, v_end_date;
	EXIT WHEN C_lines%NOTFOUND;

        l_debug_info := 'Checking whether it is Amount Last Range ';
        IF (G_LEVEL_STATEMENT  >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;

	cursor_check := 1;
	select trans_amount_from into v_trans_amount_from
	from ap_bank_charge_lines
	where bank_charge_id = X_bank_charge_id
	and trans_amount_to is null
        and ((start_date <= v_start_date
        and nvl(end_date, to_date('31-12-4712', 'DD-MM-YYYY')) >
                   v_start_date)
        or (start_date < v_end_date
        and nvl(end_date, to_date('31-12-4712', 'DD-MM-YYYY')) >=
                    v_end_date));

	if SQL%FOUND then
           l_debug_info := 'Amount Last Range Found ';
           IF (G_LEVEL_STATEMENT  >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
           END IF;

	    select max(trans_amount_to)
	    into v_trans_amount_to
	    from ap_bank_charge_lines
	    where bank_charge_id = X_bank_charge_id
	    and ((start_date <= v_start_date
            and nvl(end_date, to_date('31-12-4712', 'DD-MM-YYYY')) >
                    v_start_date)
            or (start_date < v_end_date
            and nvl(end_date, to_date('31-12-4712', 'DD-MM-YYYY')) >=
                    v_end_date));
	    if (v_trans_amount_from <> 0) and
		(v_trans_amount_from > v_trans_amount_to) then
		RAISE AMOUNT_GAP;
	    elsif (v_trans_amount_from <> 0) and
                (v_trans_amount_from < v_trans_amount_to) then
		RAISE AMOUNT_OVERLAP;
	    end if;

	end if;
    END LOOP;
    CLOSE C_lines;
    if (cursor_check = 0) then
	RAISE TOO_MANY_ROWS;
    end if;
EXCEPTION
    WHEN AMOUNT_GAP THEN
	FND_MESSAGE.SET_NAME('SQLAP', 'AP_GAPS');
	APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN AMOUNT_OVERLAP THEN
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_OVERLAP1');
        APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN NO_DATA_FOUND THEN
	FND_MESSAGE.SET_NAME('SQLAP', 'AP_LAST4');
        APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN TOO_MANY_ROWS THEN
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_LAST5');
        APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN OTHERS THEN
        IF (SQLCODE <> -20001) THEN
          FND_MESSAGE.set_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.set_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.set_TOKEN('DEBUG_INFO',l_debug_info);
        END IF;
        APP_EXCEPTION.RAISE_EXCEPTION;

END CHECK_LAST_RANGE;

PROCEDURE GET_BANK_CHARGE(
                P_bank_charge_bearer            IN      VARCHAR2,
                P_transferring_bank_branch_id   IN      NUMBER,
                P_receiving_bank_branch_id      IN      NUMBER,
                P_transfer_priority             IN      VARCHAR2,
                P_currency_code                 IN      VARCHAR2,
                P_transaction_amount            IN      NUMBER,
                P_transaction_date              IN      DATE,
                P_bank_charge_standard          OUT NOCOPY  NUMBER,
                P_bank_charge_negotiated        OUT NOCOPY  NUMBER,
                P_calc_bank_charge_standard     OUT NOCOPY  NUMBER,
                P_calc_bank_charge_negotiated   OUT NOCOPY  NUMBER,
                P_tolerance_limit               OUT NOCOPY  NUMBER) IS


    CURSOR C_CHARGE_HEADER(
                X_transferring_bank_branch_id   NUMBER,
                X_transferring_bank_name        VARCHAR2,
                X_receiving_bank_branch_id      NUMBER,
                X_receiving_bank_name           VARCHAR2,
                X_transfer_priority             VARCHAR2,
                X_currency_code                 VARCHAR2) IS
    SELECT      bc.bank_charge_id,
                bc.transferring_bank_branch_id,
                bc.transferring_bank_name,
                bc.transferring_bank,
                bc.transferring_branch,
                bc.receiving_bank_branch_id,
                bc.receiving_bank_name,
                bc.receiving_bank,
                bc.receiving_branch,
                bc.transfer_priority,
                bc.currency_code
    FROM        ap_bank_charges bc, ap_bank_charge_lines bcl
    WHERE       ((bc.transferring_bank_branch_id = X_transferring_bank_branch_id
    -- bug2242764 added bank_name condition
    AND          bc.transferring_bank_name = X_transferring_bank_name)
    OR          (bc.transferring_bank_name = X_transferring_bank_name
    AND         bc.transferring_branch = 'ALL')
    OR          (bc.transferring_bank = 'ALL'
    AND         bc.transferring_branch = 'ALL'))
    AND         ((bc.receiving_bank_branch_id = X_receiving_bank_branch_id
    -- bug2242764 added bank_name condition
    AND          bc.receiving_bank_name = X_receiving_bank_name )
    OR          (bc.receiving_bank_name = X_receiving_bank_name
    AND         bc.receiving_branch in ('ALL', 'OTHER'))
    OR          (bc.receiving_bank in ('ALL', 'OTHER')
    AND         bc.receiving_branch = 'ALL'))
    AND         (bc.transfer_priority = X_transfer_priority
    OR          bc.transfer_priority = 'AR'
    OR          bc.transfer_priority = 'ANY')
    AND         bc.currency_code = X_currency_code
    AND         bc.bank_charge_id = bcl.bank_charge_id  -- Bug 2073366
    AND         bcl.start_date <= P_transaction_date
    AND         nvl(bcl.end_date,
                   to_date('31-12-4712', 'DD-MM-YYYY')) > P_transaction_date;


    CURSOR C_get_bank_name(X_bank_branch_id NUMBER) IS
    SELECT      bank_name
    FROM        ce_bank_branches_v
    WHERE       branch_party_id = X_bank_branch_id;

    CURSOR C_precision(X_currency_code  VARCHAR2) IS
    SELECT precision
    FROM   fnd_currencies
    WHERE  currency_code = X_currency_code;

    CURSOR C_CHARGE_LINE(X_bank_charge_id       NUMBER,
                         X_transaction_date     DATE) IS
    SELECT trans_amount_from,
           nvl(trans_amount_to, 99999999999999),
           bank_charge_standard,
           bank_charge_negotiated,
           tolerance_limit
    FROM   ap_bank_charge_lines
    WHERE  bank_charge_id = X_bank_charge_id
    AND    (start_date <= X_transaction_date
    AND    nvl(end_date, to_date('31-12-4712', 'DD-MM-YYYY')) >
                X_transaction_date)
    ORDER BY trans_amount_from desc;


P_bank_charge_id                NUMBER;
P_transferring_bank_name        ce_bank_branches_v.bank_name%TYPE;
P_receiving_bank_name           ce_bank_branches_v.bank_name%TYPE;

v_bank_charge_id                NUMBER;
v_trans_bank_branch_id          NUMBER;
v_trans_bank_name               ce_bank_branches_v.bank_name%TYPE;
v_trans_bank                    ce_bank_branches_v.bank_name%TYPE;
v_trans_branch                  ce_bank_branches_v.bank_branch_name%TYPE;
v_recei_bank_branch_id          NUMBER;
v_recei_bank_name               ce_bank_branches_v.bank_name%TYPE;
v_recei_bank                    ce_bank_branches_v.bank_name%TYPE;
v_recei_branch                  ce_bank_branches_v.bank_branch_name%TYPE;
v_transfer_priority             VARCHAR2(30);
v_currency_code                 VARCHAR2(15);

priority                NUMBER;
temp_priority           NUMBER;
temp_bank_charge_id     NUMBER;
v_precision             NUMBER;

v_transaction_amount		NUMBER;
v_trans_amount_from             NUMBER;
v_trans_amount_to             	NUMBER;
v_bank_charge_standard          NUMBER;
v_bank_charge_negotiated        NUMBER;
v_tolerance_limit               NUMBER;

amount_bank_charge      NUMBER;
NO_BANK_CHARGES         EXCEPTION;
l_debug_info   Varchar2(2000);
l_api_name     CONSTANT VARCHAR2(100) := 'GET_BANK_CHARGE';


BEGIN

    l_debug_info := 'Get Bank Charge Begin';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

v_precision := 0;
P_bank_charge_id := 0;
P_bank_charge_standard :=0;
P_bank_charge_negotiated :=0;
priority := 37;
temp_priority :=37;
temp_bank_charge_id := 0;

if (P_bank_charge_bearer is not null) or
	(P_transfer_priority is null) then

    l_debug_info := 'Opening cursor for transferring bank info';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    OPEN C_get_bank_name(P_transferring_bank_branch_id);
    FETCH C_get_bank_name INTO P_transferring_bank_name;
    CLOSE C_get_bank_name;

    l_debug_info := 'Opening cursor for receiving bank info';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    OPEN C_get_bank_name(P_receiving_bank_branch_id);
    FETCH C_get_bank_name INTO P_receiving_bank_name;
    CLOSE C_get_bank_name;

    l_debug_info := 'Opening cursor for charge header';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

	l_debug_info := 'Parameters for charge header -- P_transferring_bank_branch_id -- '||to_char(P_transferring_bank_branch_id)
		     ||' P_transferring_bank_name -- '||to_char(P_transferring_bank_name)||' P_receiving_bank_branch_id -- '||
		     to_char(P_receiving_bank_branch_id)||' P_receiving_bank_name -- '||to_char(P_receiving_bank_name)||
		     ' P_transfer_priority -- '||to_char(P_transfer_priority)||' P_currency_code -- '||to_char(P_currency_code);
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    OPEN C_CHARGE_HEADER(
                P_transferring_bank_branch_id,
                P_transferring_bank_name,
                P_receiving_bank_branch_id,
                P_receiving_bank_name,
                P_transfer_priority,
                P_currency_code);
	l_debug_info := 'Opened cursor for charge header';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    LOOP
        FETCH C_CHARGE_HEADER INTO
                v_bank_charge_id,
                v_trans_bank_branch_id,
                v_trans_bank_name,
                v_trans_bank,
                v_trans_branch,
                v_recei_bank_branch_id,
                v_recei_bank_name,
                v_recei_bank,
                v_recei_branch,
                v_transfer_priority,
                v_currency_code;
    l_debug_info := 'fetch cursor for charge header -- 1';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

        EXIT WHEN C_CHARGE_HEADER%NOTFOUND;

    l_debug_info := 'fetch cursor for charge header -- 2';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

        if((P_bank_charge_bearer is not null) and
           (v_transfer_priority <>'AR')) or
           ((P_bank_charge_bearer is null) and
           (v_transfer_priority ='AR')) then
            if (v_trans_bank_branch_id is not null) then
                if (v_recei_bank_branch_id is not null) then
                    temp_priority := 1;
                    temp_bank_charge_id := v_bank_charge_id;
                elsif(v_recei_bank = 'ONE') then
                    if(v_recei_branch = 'OTHER') then
                        temp_priority := 2;
                        temp_bank_charge_id := v_bank_charge_id;
                    elsif(v_recei_branch = 'ALL') then
                        temp_priority :=3;
                        temp_bank_charge_id :=v_bank_charge_id;
                    end if;
                elsif(v_recei_bank = 'OTHER') then
                    temp_priority := 4;
                    temp_bank_charge_id := v_bank_charge_id;
                elsif(v_recei_bank = 'ALL') then
                    temp_priority := 5;
                    temp_bank_charge_id := v_bank_charge_id;
                end if;
            elsif(v_trans_bank = 'ONE') then
                if(v_recei_bank_branch_id is not null) then
                    temp_priority := 6;
                    temp_bank_charge_id := v_bank_charge_id;
                elsif(v_recei_bank = 'ONE') then
                    temp_priority := 7;
                    temp_bank_charge_id := v_bank_charge_id;
                elsif(v_recei_bank = 'OTHER') then
                    temp_priority := 8;
                    temp_bank_charge_id := v_bank_charge_id;
                elsif(v_recei_bank = 'ALL')then
                    temp_priority := 9;
                    temp_bank_charge_id := v_bank_charge_id;
                end if;
            elsif(v_trans_bank = 'ALL') then
                if(v_recei_bank_branch_id is not null) then
                    temp_priority := 10;
                    temp_bank_charge_id := v_bank_charge_id;
                elsif(v_recei_bank = 'ONE') then
                    temp_priority := 11;
                    temp_bank_charge_id := v_bank_charge_id;
                elsif(v_recei_bank = 'ALL') then
                    temp_priority := 12;
                    temp_bank_charge_id := v_bank_charge_id;
                end if;
            end if;

            if (P_receiving_bank_branch_id is not null) or
                ((temp_priority <> 2) and (temp_priority <> 4) and
                 (temp_priority <> 8)) then
                if(v_transfer_priority ='AR') or
                  (v_transfer_priority = 'EXPRESS') then
                    temp_priority := 3*temp_priority -2;
                elsif(v_transfer_priority = 'NORMAL') then
                    temp_priority := 3*temp_priority -1;
                else
                    temp_priority := 3*temp_priority;
                end if;

                if (priority > temp_priority) then
                    priority := temp_priority;
                    P_bank_charge_id := temp_bank_charge_id;
                end if;
            end if;
        end if;
    END LOOP;
    CLOSE C_CHARGE_HEADER;
    l_debug_info := 'close cursor for charge header - p_bank_charge_id '||to_char(P_bank_charge_id);
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    if (P_bank_charge_id <>0) then
/**************************************************************/
/* Change the Supplier to appropriate value */
/* NOTE: Bank_Charge_Bearer I: Internal     */
/*                          S: Supplier/Standard */
/*                          N: Supplier/Negotiated */

        l_debug_info := 'Bank Charge Id exits';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;

	if(P_transaction_amount is NULL) then
	    v_transaction_amount := 0;
	else
	    v_transaction_amount := P_transaction_amount;
	end if;
        if(P_bank_charge_bearer = 'I') or
                ((P_bank_charge_bearer is null)and
                 (P_transfer_priority is null)) then
        l_debug_info := 'Bank Charge Bearer is I';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;

            SELECT bank_charge_standard,
                   bank_charge_negotiated,
                   tolerance_limit
            INTO   P_bank_charge_standard,
                   P_bank_charge_negotiated,
                   P_tolerance_limit
            FROM   ap_bank_charge_lines
            WHERE  bank_charge_id = P_bank_charge_id
            AND    trans_amount_from <= v_transaction_amount
            AND    nvl(trans_amount_to, 99999999999999) > v_transaction_amount
            AND    start_date <= P_transaction_date
            AND    nvl(end_date,
                   to_date('31-12-4712', 'DD-MM-YYYY')) >
                                P_transaction_date;
        elsif(P_bank_charge_bearer = 'S') or
             (P_bank_charge_bearer = 'N') then

            l_debug_info := 'Bank Charge Bearer is not I';
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
            END IF;

            OPEN C_CHARGE_LINE(P_bank_charge_id,
                               P_transaction_date);

            LOOP

                FETCH C_CHARGE_LINE INTO v_trans_amount_from,
                                         v_trans_amount_to,
                                         v_bank_charge_standard,
                                         v_bank_charge_negotiated,
                                         v_tolerance_limit;
		EXIT WHEN C_CHARGE_LINE%NOTFOUND;

/*
1542954 fbreslin: Bank charges were not getting calculated correctly in corner
                  cases.Commented below code as amount_bank_charge variable is
                  not used further in the procedure.
                  Also replace amount_bank_charge with v_transaction_amount to.

                if(P_bank_charge_bearer = 'S') then
                    amount_bank_charge :=v_transaction_amount -
                                                v_bank_charge_standard;
                else
                    amount_bank_charge :=v_transaction_amount -
                                                v_bank_charge_negotiated;
                end if;
*/

		if(v_transaction_amount >= 0 ) then
                    if(v_transaction_amount >= v_trans_amount_from) then
                    	if(v_transaction_amount < v_trans_amount_to) then
                           P_bank_charge_standard := v_bank_charge_standard;
                           P_bank_charge_negotiated := v_bank_charge_negotiated;
                           P_tolerance_limit := v_tolerance_limit;
                           EXIT;
                    	else
                           P_bank_charge_standard := v_bank_charge_standard;
                           P_bank_charge_negotiated := v_bank_charge_negotiated;
                           OPEN C_precision(P_currency_code);
                           FETCH C_precision INTO v_precision;
                           CLOSE C_precision;
                           if(P_bank_charge_bearer = 'S') then
                            	P_calc_bank_charge_standard :=
                                    v_transaction_amount - v_trans_amount_to
                                    + 1/power(10, v_precision);
                           else
                            	P_calc_bank_charge_negotiated :=
                                    v_transaction_amount - v_trans_amount_to
                                    + 1/power(10, v_precision);
                           end if;
                           P_tolerance_limit := v_tolerance_limit;
                           EXIT;
                    	end if;
                    end if;
		end if;
            END LOOP;
            CLOSE C_CHARGE_LINE;
	    if (amount_bank_charge <0) then
			l_debug_info := 'amount_bank_charge is negative - '||to_char(amount_bank_charge);
			IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
				FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
			END IF;

		RAISE NO_BANK_CHARGES;
	    end if;
        else
			l_debug_info := 'P_bank_charge_bearer is not valid - '||to_char(P_bank_charge_bearer);
			IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
				FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
			END IF;

            RAISE NO_BANK_CHARGES;
        end if;
    else
			l_debug_info := 'P_bank_charge_id is not valid - '||to_char(P_bank_charge_id);
			IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
				FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
			END IF;

		NULL;
  --      RAISE NO_BANK_CHARGES;  bug8253986
    end if;
else
			l_debug_info := 'P_bank_charge_bearer is null - '||to_char(P_bank_charge_bearer)||
							' or P_transfer_priority is not null -- '||to_char(P_transfer_priority);
			IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
				FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
			END IF;

    RAISE NO_BANK_CHARGES;
end if;

-- B#  8340655
--P_tolerance_limit := 0 ;
IF (P_tolerance_limit is NULL) THEN
	P_tolerance_limit := 0 ;
END IF ;

EXCEPTION
    WHEN NO_BANK_CHARGES THEN
       p_tolerance_limit := NULL;
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_NO_CHARGE_FOUND');
        FND_MSG_PUB.ADD;
        --APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_NO_CHARGE_FOUND');
        FND_MSG_PUB.ADD;
        p_tolerance_limit := NULL;
        --APP_EXCEPTION.RAISE_EXCEPTION;
    WHEN OTHERS THEN
        IF (SQLCODE <> -20001) THEN
          FND_MESSAGE.set_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.set_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.set_TOKEN('DEBUG_INFO',l_debug_info);
        END IF;
        p_tolerance_limit := NULL;
        FND_MSG_PUB.ADD;
        --APP_EXCEPTION.RAISE_EXCEPTION;


END GET_BANK_CHARGE;

PROCEDURE CHECK_BANK_CHARGE(
                P_bank_charge_bearer            IN      VARCHAR2,
                P_transferring_bank_branch_id   IN      NUMBER,
                P_receiving_bank_branch_id      IN      NUMBER,
                P_transfer_priority             IN      VARCHAR2,
                P_currency_code                 IN      VARCHAR2,
                P_transaction_amount            IN      NUMBER,
                P_transaction_date              IN      DATE,
                P_check_bc_flag                 OUT NOCOPY     VARCHAR2,
                P_do_not_pay_reason             OUT NOCOPY     VARCHAR2) IS


    CURSOR C_CHARGE_HEADER(
                X_transferring_bank_branch_id   NUMBER,
                X_transferring_bank_name        VARCHAR2,
                X_receiving_bank_branch_id      NUMBER,
                X_receiving_bank_name           VARCHAR2,
                X_transfer_priority             VARCHAR2,
                X_currency_code                 VARCHAR2) IS
    SELECT      bc.bank_charge_id,
                bc.transferring_bank_branch_id,
                bc.transferring_bank_name,
                bc.transferring_bank,
                bc.transferring_branch,
                bc.receiving_bank_branch_id,
                bc.receiving_bank_name,
                bc.receiving_bank,
                bc.receiving_branch,
                bc.transfer_priority,
                bc.currency_code
    FROM        ap_bank_charges bc, ap_bank_charge_lines bcl
    WHERE       ((bc.transferring_bank_branch_id = X_transferring_bank_branch_id
    -- bug2242764 added bank_name condition
    AND          transferring_bank_name = X_transferring_bank_name)
    OR          (bc.transferring_bank_name = X_transferring_bank_name
    AND         bc.transferring_branch = 'ALL')
    OR          (bc.transferring_bank = 'ALL'
    AND         bc.transferring_branch = 'ALL'))
    AND         ((bc.receiving_bank_branch_id = X_receiving_bank_branch_id
    -- bug2242764 added bank_name condition
    AND          receiving_bank_name = X_receiving_bank_name)
    OR          (bc.receiving_bank_name = X_receiving_bank_name
    AND         bc.receiving_branch in ('ALL', 'OTHER'))
    OR          (bc.receiving_bank in ('ALL', 'OTHER')
    AND         bc.receiving_branch = 'ALL'))
    AND         (bc.transfer_priority = X_transfer_priority
    OR          bc.transfer_priority = 'AR'
    OR          bc.transfer_priority = 'ANY')
    AND         bc.currency_code = X_currency_code
    AND         bc.bank_charge_id = bcl.bank_charge_id -- Bug 2177997
    AND         bcl.start_date <= P_transaction_date
    AND         nvl(bcl.end_date,
                to_date('31-12-4712', 'DD-MM-YYYY')) > P_transaction_date;

    CURSOR C_get_bank_name(X_bank_branch_id NUMBER) IS
    SELECT      bank_name
    FROM        ce_bank_branches_v
    WHERE       branch_party_id = X_bank_branch_id;

    CURSOR C_precision(X_currency_code  VARCHAR2) IS
    SELECT precision
    FROM   fnd_currencies
    WHERE  currency_code = X_currency_code;

    CURSOR C_CHARGE_LINE(X_bank_charge_id       NUMBER,
                         X_transaction_date     DATE) IS
    SELECT trans_amount_from,
           nvl(trans_amount_to, 99999999999999),
           bank_charge_standard,
           bank_charge_negotiated,
           tolerance_limit
    FROM   ap_bank_charge_lines
    WHERE  bank_charge_id = X_bank_charge_id
    AND    (start_date <= X_transaction_date
    AND    nvl(end_date, to_date('31-12-4712', 'DD-MM-YYYY')) >
                X_transaction_date)
    ORDER BY trans_amount_from desc;


P_bank_charge_id                NUMBER;
P_transferring_bank_name        ce_bank_branches_v.bank_name%TYPE;
P_receiving_bank_name           ce_bank_branches_v.bank_name%TYPE;

v_bank_charge_id                NUMBER;
v_trans_bank_branch_id          NUMBER;
v_trans_bank_name               ce_bank_branches_v.bank_name%TYPE;
v_trans_bank                    ce_bank_branches_v.bank_name%TYPE;
v_trans_branch                  ce_bank_branches_v.bank_branch_name%TYPE;
v_recei_bank_branch_id          NUMBER;
v_recei_bank_name               ce_bank_branches_v.bank_name%TYPE;
v_recei_bank                    ce_bank_branches_v.bank_name%TYPE;
v_recei_branch                  ce_bank_branches_v.bank_branch_name%TYPE;
v_transfer_priority             VARCHAR2(30);
v_currency_code                 VARCHAR2(15);

priority                NUMBER;
temp_priority           NUMBER;
temp_bank_charge_id     NUMBER;
v_precision             NUMBER;

v_transaction_amount            NUMBER;
v_trans_amount_from             NUMBER;
v_trans_amount_to               NUMBER;
v_bank_charge_standard          NUMBER;
v_bank_charge_negotiated        NUMBER;
v_tolerance_limit               NUMBER;

amount_bank_charge      NUMBER;
NO_BANK_CHARGES         EXCEPTION;

l_debug_info   Varchar2(2000);
l_api_name     CONSTANT VARCHAR2(100) := 'CHECK_BANK_CHARGE';


BEGIN

    l_debug_info := 'Check Bank Charge Begin';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

v_precision := 0;
P_bank_charge_id := 0;
priority := 37;
temp_priority :=37;
temp_bank_charge_id := 0;
P_check_bc_flag := 'N';
P_do_not_pay_reason := '';

if (P_bank_charge_bearer is not null) or
        (P_transfer_priority is null) then
    l_debug_info := 'Opening Cursor for transferring bank info';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    OPEN C_get_bank_name(P_transferring_bank_branch_id);
    FETCH C_get_bank_name INTO P_transferring_bank_name;
    CLOSE C_get_bank_name;

    l_debug_info := 'Opening Cursor for receiving bank info';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    OPEN C_get_bank_name(P_receiving_bank_branch_id);
    FETCH C_get_bank_name INTO P_receiving_bank_name;
    CLOSE C_get_bank_name;

    l_debug_info := 'Opening Charge Header Cursor';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    l_debug_info := 'Parameters for charge header 1 -- P_transferring_bank_branch_id -- '||to_char(P_transferring_bank_branch_id)
		     ||' P_transferring_bank_name -- '||to_char(P_transferring_bank_name)||' P_receiving_bank_branch_id -- '||
		     to_char(P_receiving_bank_branch_id)||' P_receiving_bank_name -- '||to_char(P_receiving_bank_name)||
		     ' P_transfer_priority -- '||to_char(P_transfer_priority)||' P_currency_code -- '||to_char(P_currency_code);
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    OPEN C_CHARGE_HEADER(
                P_transferring_bank_branch_id,
                P_transferring_bank_name,
                P_receiving_bank_branch_id,
                P_receiving_bank_name,
                P_transfer_priority,
                P_currency_code);

	l_debug_info := 'Opened charge header cursor';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

	LOOP
        FETCH C_CHARGE_HEADER INTO
                v_bank_charge_id,
                v_trans_bank_branch_id,
                v_trans_bank_name,
                v_trans_bank,
                v_trans_branch,
                v_recei_bank_branch_id,
                v_recei_bank_name,
                v_recei_bank,
                v_recei_branch,
                v_transfer_priority,
                v_currency_code;

    l_debug_info := 'Fetched data from C_charge_header';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

        EXIT WHEN C_CHARGE_HEADER%NOTFOUND;

        if((P_bank_charge_bearer is not null) and
           (v_transfer_priority <>'AR')) or
           ((P_bank_charge_bearer is null) and
           (v_transfer_priority ='AR')) then
            if (v_trans_bank_branch_id is not null) then
                if (v_recei_bank_branch_id is not null) then
                    temp_priority := 1;
                    temp_bank_charge_id := v_bank_charge_id;
                elsif(v_recei_bank = 'ONE') then
                    if(v_recei_branch = 'OTHER') then
                        temp_priority := 2;
                        temp_bank_charge_id := v_bank_charge_id;
                    elsif(v_recei_branch = 'ALL') then
                        temp_priority :=3;
                        temp_bank_charge_id :=v_bank_charge_id;
                    end if;
                elsif(v_recei_bank = 'OTHER') then
                    temp_priority := 4;
                    temp_bank_charge_id := v_bank_charge_id;
                elsif(v_recei_bank = 'ALL') then
                    temp_priority := 5;
                    temp_bank_charge_id := v_bank_charge_id;
                end if;
            elsif(v_trans_bank = 'ONE') then
                if(v_recei_bank_branch_id is not null) then
                    temp_priority := 6;
                    temp_bank_charge_id := v_bank_charge_id;
                elsif(v_recei_bank = 'ONE') then
                    temp_priority := 7;
                    temp_bank_charge_id := v_bank_charge_id;
                elsif(v_recei_bank = 'OTHER') then
                    temp_priority := 8;
                    temp_bank_charge_id := v_bank_charge_id;
                elsif(v_recei_bank = 'ALL')then
                    temp_priority := 9;
                    temp_bank_charge_id := v_bank_charge_id;
                end if;
            elsif(v_trans_bank = 'ALL') then
                if(v_recei_bank_branch_id is not null) then
                    temp_priority := 10;
                    temp_bank_charge_id := v_bank_charge_id;
                elsif(v_recei_bank = 'ONE') then
                    temp_priority := 11;
                    temp_bank_charge_id := v_bank_charge_id;
                elsif(v_recei_bank = 'ALL') then
                    temp_priority := 12;
                    temp_bank_charge_id := v_bank_charge_id;
                end if;
            end if;

            if (P_receiving_bank_branch_id is not null) or
                ((temp_priority <> 2) and (temp_priority <> 4) and
                 (temp_priority <> 8)) then
                if(v_transfer_priority ='AR') or
                  (v_transfer_priority = 'EXPRESS') then
                    temp_priority := 3*temp_priority -2;
                elsif(v_transfer_priority = 'NORMAL') then
                    temp_priority := 3*temp_priority -1;
                else
                    temp_priority := 3*temp_priority;
                end if;

                if (priority > temp_priority) then
                    priority := temp_priority;
                    P_bank_charge_id := temp_bank_charge_id;
                end if;
            end if;
        end if;
    END LOOP;
    CLOSE C_CHARGE_HEADER;

    l_debug_info := 'P_BANK_CHARGE_ID EXISTS -- '||to_char(P_bank_charge_id);
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    if (P_bank_charge_id <>0) then
/**************************************************************/
/* Change the Supplier to appropriate value */
/* NOTE: Bank_Charge_Bearer I: Internal     */
/*                          S: Supplier/Standard */
/*                          N: Supplier/Negotiated */

        l_debug_info := 'Bank Charge Id exits';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;

        if(P_transaction_amount is NULL) then
            v_transaction_amount := 0;
        else
            v_transaction_amount := P_transaction_amount;
        end if;
        if(P_bank_charge_bearer = 'I') or
                ((P_bank_charge_bearer is null)and
                 (P_transfer_priority is null)) then
            l_debug_info := 'Bank Charge Bearer is I';
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
            END IF;

            SELECT bank_charge_standard,
                   bank_charge_negotiated,
                   tolerance_limit
            INTO   v_bank_charge_standard,
                   v_bank_charge_negotiated,
                   v_tolerance_limit
            FROM   ap_bank_charge_lines
            WHERE  bank_charge_id = P_bank_charge_id
            AND    trans_amount_from <= v_transaction_amount
            AND    nvl(trans_amount_to, 99999999999999) > v_transaction_amount
            AND    start_date <= P_transaction_date
            AND    nvl(end_date,
                   to_date('31-12-4712', 'DD-MM-YYYY')) >
                                P_transaction_date;
            P_check_bc_flag := 'Y';
        elsif(P_bank_charge_bearer = 'S') or
             (P_bank_charge_bearer = 'N') then

            l_debug_info := 'Bank Charge Bearer is not I';
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
            END IF;


            OPEN C_CHARGE_LINE(P_bank_charge_id,
                               P_transaction_date);
            LOOP
                FETCH C_CHARGE_LINE INTO v_trans_amount_from,
                                         v_trans_amount_to,
                                         v_bank_charge_standard,
                                         v_bank_charge_negotiated,
                                         v_tolerance_limit;
                EXIT WHEN C_CHARGE_LINE%NOTFOUND;
                if(P_bank_charge_bearer = 'S') then
                    amount_bank_charge :=v_transaction_amount -
                                                v_bank_charge_standard;
                else
                    amount_bank_charge :=v_transaction_amount -
                                                v_bank_charge_negotiated;
                end if;
                if(amount_bank_charge >= 0 ) then
                    if(amount_bank_charge >= v_trans_amount_from) then
                        P_check_bc_flag := 'Y';
                        EXIT;
                    end if;
                end if;
            END LOOP;

            -- for BUG 1714850
            if C_CHARGE_LINE%ROWCOUNT = 0
            then
              P_check_bc_flag := 'N';
              P_do_not_pay_reason := 'NO BANK CHARGE';
            end if;

            CLOSE C_CHARGE_LINE;
            if (amount_bank_charge <0) then
                P_check_bc_flag := 'N';
                P_do_not_pay_reason := 'BC GREATER THAN AMOUNT';
            end if;
        else
			l_debug_info := 'P_bank_charge_bearer is not valid - '||to_char(P_bank_charge_bearer);
			IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
				FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
			END IF;


            RAISE NO_BANK_CHARGES;
        end if;
    else

			l_debug_info := 'P_bank_charge_id is not valid - '||to_char(P_bank_charge_id);
			IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
				FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
			END IF;

		  P_check_bc_flag := 'Y';
 --       RAISE NO_BANK_CHARGES;  bug8253986
    end if;
else

		l_debug_info := 'P_bank_charge_bearer is null - '||to_char(P_bank_charge_bearer)||
						' or P_transfer_priority is not null -- '||to_char(P_transfer_priority);
		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
		END IF;

    RAISE NO_BANK_CHARGES;
end if;
EXCEPTION
    WHEN NO_BANK_CHARGES THEN
        P_check_bc_flag := 'N';
        P_do_not_pay_reason := 'NO BANK CHARGE';
    WHEN NO_DATA_FOUND THEN
        P_check_bc_flag := 'N';
        P_do_not_pay_reason := 'NO BANK CHARGE';
    WHEN OTHERS THEN
       IF (SQLCODE <> -20001) THEN
          FND_MESSAGE.set_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.set_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.set_TOKEN('DEBUG_INFO',l_debug_info);
       END IF;
       FND_MSG_PUB.ADD;

END CHECK_BANK_CHARGE;


FUNCTION Bank_charge_get_info(
	    p_selected_check_id	        IN  NUMBER,
	    p_external_bank_account_id  IN  NUMBER,
	    p_currency_code             IN  VARCHAR2,
	    p_minimum_accountable_unit  OUT nocopy NUMBER,
	    p_precision                 OUT nocopy NUMBER,
	    p_bank_charge_bearer        OUT nocopy VARCHAR2,
	    p_transferring_bank_branch_id  OUT nocopy NUMBER,
            p_receiving_bank_branch_id  OUT nocopy NUMBER,
	    p_transfer_priority	        OUT nocopy VARCHAR2,
            p_num_of_invoices           OUT nocopy NUMBER,
 	    p_calling_sequence          IN VARCHAR2,
            p_internal_bank_account_id  IN NUMBER,
            p_supplier_site_id          IN NUMBER) RETURN BOOLEAN IS

current_calling_sequence  	VARCHAR2(2000);
l_debug_info   Varchar2(2000);
l_api_name     CONSTANT VARCHAR2(100) := 'BANK_CHARGE_GET_INFO';


BEGIN

    current_calling_sequence := 'bank_charge_get_info<-'||P_calling_sequence;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,current_calling_sequence);
    END IF;

    l_debug_info := 'Get bank charge bearer from po vendor sites';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

  -- Bug7014739. Added nvl.
  IF p_supplier_site_id IS NOT NULL THEN
    SELECT nvl(PVS.bank_charge_bearer, 'I')
    INTO p_bank_charge_bearer
    FROM iby_hook_payments_t iby,
         ap_supplier_sites_all PVS
    WHERE iby.payment_id = p_selected_check_id
     AND iby.supplier_site_id = PVS.vendor_site_id;
  END IF;

  l_debug_info := 'Get p_transferring_bank_branch_id';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  SELECT ABA.bank_branch_id
    INTO p_transferring_bank_branch_id
    FROM ce_bank_accounts ABA
   WHERE aba.bank_account_id = p_internal_bank_account_id;

  l_debug_info := 'Get p_receiving_bank_branch_id';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  if p_external_bank_account_id is not null then

    SELECT ieb.branch_id
      INTO p_receiving_bank_branch_id
      FROM iby_ext_bank_accounts ieb
     WHERE ieb.ext_bank_account_id = p_external_bank_account_id;

  end if;

  l_debug_info := 'Get transfer_priority and currency code';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;


  SELECT AISC.transfer_priority
    INTO p_transfer_priority
    FROM ap_inv_selection_criteria_ALL AISC,
         iby_hook_docs_in_pmt_t IBY
   WHERE IBY.CALLING_APP_DOC_UNIQUE_REF1 = AISC.CHECKRUN_ID
     and rownum=1;


  l_debug_info := 'Get number of invoices for this check';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  SELECT count(*)
    INTO p_num_of_invoices
    FROM iby_hook_payments_t
   WHERE payment_id = p_selected_check_id;

  l_debug_info := 'Get min_account_unit and precision for currency';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  SELECT minimum_accountable_unit,
         nvl(precision, 0)
    INTO p_minimum_accountable_unit,
	 p_precision
    FROM fnd_currencies_vl
   WHERE currency_code = p_currency_code;

  RETURN (TRUE);

  EXCEPTION
 WHEN OTHERS then
   IF (SQLCODE < 0 ) then
     null; --rlandows SRW.MESSAGE('999',SQLERRM);
   END IF;

   RETURN (FALSE);

END bank_charge_get_info;



FUNCTION Bank_charge_get_amt_due(
        p_selected_check_id             IN      NUMBER,
        p_amount_due                    OUT     nocopy NUMBER,
        p_calling_sequence              IN      VARCHAR2) RETURN BOOLEAN IS

debug_info                      VARCHAR2(200);
current_calling_sequence        VARCHAR2(2000);

BEGIN

     current_calling_sequence := 'bank_charge_get_amt_due<-'||P_calling_sequence;


  debug_info := 'Get p_amount_due';

  SELECT sum(decode(dont_pay_flag, 'Y', 0,
                    document_amount + nvl(PAYMENT_CURR_DISCOUNT_TAKEN,0)))
    INTO p_amount_due
    FROM iby_hook_docs_in_pmt_t
   WHERE payment_id= p_selected_check_id;


  RETURN (TRUE);

  EXCEPTION

        WHEN OTHERS THEN

          FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
          FND_MESSAGE.SET_TOKEN('PARAMETERS',
              ' p_selected_check_id  =  '||to_char(p_selected_check_id));
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
          --APP_EXCEPTION.RAISE_EXCEPTION;

   RETURN (FALSE);

END bank_charge_get_amt_due;



PROCEDURE ap_JapanBankChargeHook(
                p_api_version    IN  NUMBER,
                p_init_msg_list  IN  VARCHAR2,
                p_commit         IN  VARCHAR2,
                x_return_status  OUT nocopy VARCHAR2,
                x_msg_count      OUT nocopy NUMBER,
                x_msg_data       OUT nocopy VARCHAR2)
is


CURSOR selected_checks IS
SELECT iby.payment_id,
       iby.payment_currency_code,
       iby.payment_date,
       iby.external_bank_account_id,
       iby.dont_pay_flag,
       iby.internal_bank_account_id,
       iby.supplier_site_id
  FROM iby_hook_payments_t iby,
       ap_system_parameters_all asp --5007989
 WHERE dont_pay_flag <> 'Y'
   AND nvl(dont_pay_reason_code,'dummy') <> 'OVERFLOW'
   AND asp.org_id = iby.org_id
   AND nvl(asp.use_bank_charge_flag,'N') = 'Y'
 ORDER BY payment_id;


CURSOR adjustment_for_rounding_error (c_selected_check_id NUMBER,
	c_rounding_error NUMBER) IS
SELECT	PAYMENT_CURR_DISCOUNT_TAKEN
  FROM	iby_hook_docs_in_pmt_t
 WHERE	payment_id = c_selected_check_id
   AND	ABS(document_amount) >= ABS(c_rounding_error)
 ORDER BY PAYMENT_CURR_DISCOUNT_TAKEN desc;


l_selected_check_id		NUMBER;
l_currency_code			VARCHAR2(15);
l_payment_date			DATE;
l_external_bank_account_id	NUMBER;
l_bank_charge_bearer		VARCHAR2(1);
l_transferring_bank_branch_id	NUMBER;
l_ok_to_pay_flag		VARCHAR2(1);
l_bc_ok_to_pay_flag		VARCHAR2(1);
l_bc_dont_pay_reason_code	VARCHAR2(25);
l_receiving_bank_branch_id	NUMBER;
l_transfer_priority		VARCHAR2(25);
l_bank_charge_standard		NUMBER;
l_bank_charge_negotiated	NUMBER;
l_calc_bank_charge_standard	NUMBER;
l_calc_bank_charge_negotiated	NUMBER;
l_tolerance_limit		NUMBER;
l_best_bank_charge		NUMBER;
l_num_of_invoices		NUMBER;
l_prorate_bank_charge		NUMBER;
l_rounding_error		NUMBER;
l_min_account_unit		NUMBER;
l_precision			NUMBER;
l_amt_due 			NUMBER;
l_payment_method                VARCHAR2(25);
l_max_discount_amount		NUMBER;
l_rem_rounding_error_amount	NUMBER; /*1649310 */
l_supplier_site_id              NUMBER;

bank_charge_failure		EXCEPTION;
l_debug_info   		  	VARCHAR2(200);
current_calling_sequence  	VARCHAR2(2000);

l_internal_bank_account_id number;
l_api_name                  CONSTANT VARCHAR2(30)   := 'ap_JapanBankChargeHook';
l_api_version               CONSTANT NUMBER         := 1.0;


BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence := 'AP_BANK_CHARGE_PKG.AP_JAPANBANKCHARGEHOOK';

  -------------------------------------------------------------------------
  -- Step 0, Return true and do nothing if use_bank_charge_flag is not 'Y'
  -------------------------------------------------------------------------

  l_debug_info := 'Creating Savepoint';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  -- Standard Start of API savepoint
  SAVEPOINT   AP_JAPANBANKCHARGEHOOK;

  l_debug_info := 'Checking API Compatibility';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
     FND_MSG_PUB.initialize;
  END IF;

  l_debug_info := 'Calling AP Void Pkg.Iby_Void_Check';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --------------------------------------------
  -- Step 1, Open , fetch selected check cursor
  --------------------------------------------
  l_debug_info := 'Open selected_checks Cursor';


  OPEN selected_checks;

  LOOP

    l_debug_info := 'Fetch selected_checks Cursor';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;


    FETCH selected_checks
    INTO 	l_selected_check_id,
	        l_currency_code,
	        l_payment_date,
		l_external_bank_account_id,
		l_ok_to_pay_flag,
		l_internal_bank_account_id,
                l_supplier_site_id;

    EXIT WHEN selected_checks%NOTFOUND;


    -------------------------------------------------------
    -- Step 2, Call Bank_charge_get_info for each check
    -------------------------------------------------------
    l_debug_info := 'Call Bank_charge_get_info';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;


    IF (bank_charge_get_info(
                             l_selected_check_id,
	                     l_external_bank_account_id,
			     l_currency_code,
			     l_min_account_unit,		 -- OUT
			     l_precision,			 -- OUT
			     l_bank_charge_bearer,		 -- OUT
			     l_transferring_bank_branch_id,   -- OUT
                 	     l_receiving_bank_branch_id,	 -- OUT
			     l_transfer_priority,		 -- OUT
			     l_num_of_invoices,		 -- OUT, not currently used.
		             current_calling_sequence,
                             l_internal_bank_account_id,
                             l_supplier_site_id) <> TRUE) THEN
          x_msg_data := 'Failed to derive transferring/receiving bank/branch info';
          l_debug_info := 'Failed to derive transferring/receiving bank/branch info';
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;
	  RAISE bank_charge_failure;
    END IF;


    -------------------------------------------------------
    -- Step 3, Call Bank_charge_get_amt_due for each check
    -------------------------------------------------------
    l_debug_info := 'Call Bank_charge_get_amt_due';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;


    IF (bank_charge_get_amt_due(l_selected_check_id,
                                l_amt_due,                       -- OUT
                                current_calling_sequence) <> TRUE) THEN
      x_msg_data := 'Failed to derive bank charge amount due';
      l_debug_info := 'Failed to derive bank charge amount due';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;
      RAISE bank_charge_failure;
    END IF;


    -----------------------------------------------------------------------------
    -- Step 4
    -- Call ap_bank_charge_pkg.check_bank_charge, it will return ok_to_pay_flag to
    -- 'N' and dont_pay_reason if bank charge information is insufficient.
    -- Since this is a procedure without return value, the exception handler will
    -- be different
    -----------------------------------------------------------------------------
      BEGIN
       -----------
       -- Step 4.1
       -----------
       l_debug_info := 'Check all the mandatory parameters for ap_bank_charge_pkg.check_bank_charge';
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;

       IF (l_bank_charge_bearer IS NULL OR
	        l_transfer_priority IS NULL OR
	        l_currency_code IS NULL OR
	        l_amt_due IS NULL OR
	        l_payment_date IS NULL) THEN
          x_msg_data := 'Can not call Check_Bank_Charge function because of mandatory parameter';
          l_debug_info := 'Can not call Check_Bank_Charge function because of mandatory parameter';
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;
          RAISE bank_charge_failure;

        END IF;
       ------------
       -- Step 4.2
       ------------
       l_debug_info := 'Call ap_bank_charge_pkg.check_bank_charge';
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;

                CHECK_BANK_CHARGE(
				l_bank_charge_bearer,
				l_transferring_bank_branch_id,
				l_receiving_bank_branch_id,
				l_transfer_priority,
				l_currency_code,
				l_amt_due,
				l_payment_date,
				l_bc_ok_to_pay_flag,		-- OUT
				l_bc_dont_pay_reason_code);	-- OUT




       EXCEPTION
        WHEN OTHERS THEN

          FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
          FND_MESSAGE.SET_TOKEN('PARAMETERS',
              ' l_bank_charge_bearer  = ' ||l_bank_charge_bearer
		    ||' l_transferring_bank_branch_id  =  '||to_char(l_transferring_bank_branch_id)
		    ||' l_receiving_bank_branch_id  =  '||to_char(l_receiving_bank_branch_id)
		    ||' l_transfer_priority  = '||l_transfer_priority
		    ||' l_currency_code  = '||l_currency_code
		    ||' l_amt_due  = '||to_char(l_amt_due)
		    ||' l_payment_date  = '||to_char(l_payment_date) );
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          --APP_EXCEPTION.RAISE_EXCEPTION;

       END;

      -------------------------------------------------
      -- Step 4.3
      --  Update ap_selected_invoice_checks
      -------------------------------------------------
      if (NVL(l_bc_ok_to_pay_flag,'Y') = 'N') then
       l_debug_info := 'Update iby_hook_payments_t if ok_to_pay_flag is N';
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;

       UPDATE iby_hook_payments_t
          SET payment_amount = 0,
              dont_pay_flag = 'Y',
              dont_pay_reason_code = l_bc_dont_pay_reason_code
        WHERE payment_id = l_selected_check_id;


        l_ok_to_pay_flag := l_bc_ok_to_pay_flag;
      else
        l_ok_to_pay_flag :=  'Y' ; -- Bug 6195497. Added else part.
      end if;


    --=======================================================================
    -- Don't update the tables if ok_to_pay_flag is not 'Y' or 'F', since the
    -- payment amount will be zero in this case. or bank_charge_bearer
    -- is 'I' (internal)
    --=======================================================================
    if (l_ok_to_pay_flag <> 'N' AND l_bank_charge_bearer <> 'I') then

      -----------------------------------------------------------------------------
      -- Step 5
      -- Call ap_bank_charge_pkg.get_bank_charge, Since this is a procedure without
      --  return value, the exception handler will be different
      -----------------------------------------------------------------------------
      BEGIN
       -----------
       -- Step 5.1
       -----------
       l_debug_info := 'Check all the mandatory parameters for ap_bank_charge_pkg.get_bank_charge';
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;


        IF (l_bank_charge_bearer IS NULL OR
            l_transfer_priority IS NULL OR
	        l_currency_code IS NULL OR
            l_amt_due IS NULL OR
	        l_payment_date IS NULL) THEN

          RAISE bank_charge_failure;

        END IF;
       -----------
       -- Step 5.2
       -----------
       l_debug_info := 'Call ap_bank_charge_pkg.get_bank_charge';
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;


                GET_BANK_CHARGE(
				l_bank_charge_bearer,
				l_transferring_bank_branch_id,
				l_receiving_bank_branch_id,
				l_transfer_priority,
				l_currency_code,
				l_amt_due,
				l_payment_date,
				l_bank_charge_standard,		-- OUT
				l_bank_charge_negotiated,	-- OUT
				l_calc_bank_charge_standard,	-- OUT
				l_calc_bank_charge_negotiated,	-- OUT
				l_tolerance_limit);		-- OUT, should always be 0.

                IF l_tolerance_limit is NULL THEN
                  Raise Bank_Charge_Failure;
                END IF;

      EXCEPTION
        WHEN OTHERS THEN
          CLOSE selected_checks;
          FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
          FND_MESSAGE.SET_TOKEN('PARAMETERS',
              ' l_bank_charge_bearer  = ' ||l_bank_charge_bearer
		    ||' l_transferring_bank_branch_id  =  '||to_char(l_transferring_bank_branch_id)
		    ||' l_receiving_bank_branch_id  =  '||to_char(l_receiving_bank_branch_id)
		    ||' l_transfer_priority  = '||l_transfer_priority
		    ||' l_currency_code  = '||l_currency_code
		    ||' l_amt_due  = '||to_char(l_amt_due)
		    ||' l_payment_date  = '||to_char(l_payment_date) );
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          --APP_EXCEPTION.RAISE_EXCEPTION;


      END;

      -------------------------------------------------------------
      -- Step 6, Get the best deal for bank charge
      -------------------------------------------------------------
      l_debug_info := 'Get the best bank charge';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;


      IF (l_bank_charge_bearer = 'S') then
        SELECT greatest(	nvl(l_bank_charge_standard,0),
				nvl(l_calc_bank_charge_standard,0))
        INTO l_best_bank_charge
        FROM sys.dual;

      ELSIF (l_bank_charge_bearer = 'N') then
        SELECT greatest(	nvl(l_bank_charge_negotiated,0),
				nvl(l_calc_bank_charge_negotiated,0))
        INTO l_best_bank_charge
	    FROM sys.dual;
      END IF;




      ----------------------------------------------------------
      -- Step 7 , Update ap_selected_invoice_checks
      -- 1, Update discount_amount to the bank_charge_amount and
      -- 2, subtract the bank charge amount from the check amount
      ----------------------------------------------------------
      l_debug_info := 'Update iby_hook_payments_t';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      UPDATE iby_hook_payments_t
         SET DISCOUNT_AMOUNT_TAKEN= l_best_bank_charge,
	         payment_amount = l_amt_due - l_best_bank_charge
       WHERE payment_id = l_selected_check_id;



      ---------------------------------------------------------
      -- Step 8 , Update ap_selected_invoices
      -- 1, Update discount_amount to proportion of the
      --       bank_charge_amount
      -- 2, Subtract the proportion of the bank_charge_amount from
      --       payment_amount and proposed_payment_amount
      ----------------------------------------------------------
      l_debug_info := 'Update iby_hook_docs_in_pmt_t';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;


      UPDATE iby_hook_docs_in_pmt_t
         SET PAYMENT_CURR_DISCOUNT_TAKEN = decode(l_amt_due, 0, 0,
                                      decode(l_min_account_unit,
            			             null, round(l_best_bank_charge *
						         (document_amount/l_amt_due),
						         l_precision),
                                             round(l_best_bank_charge *
				  	           (document_amount/l_amt_due)/l_min_account_unit) *
                               		                                           l_min_account_unit)
                                     ),
	     document_amount = (document_amount + nvl(PAYMENT_CURR_DISCOUNT_TAKEN, 0)) -
				decode(l_amt_due, 0, 0,
                                       decode(l_min_account_unit,
            			               null, round(l_best_bank_charge *
						           (document_amount/l_amt_due),
						           l_precision),
                                               round(l_best_bank_charge *
				  	             (document_amount/l_amt_due)/l_min_account_unit) *
                               		                                             l_min_account_unit)
                                      )
       WHERE payment_id = l_selected_check_id
         AND nvl(dont_pay_flag, 'Y') = 'N';







      ---------------------------------------------------------
      -- Step 9 , Calculate the rounding error
      --    The difference between sum of proposed_payment_amount
      --    for all invoices and the new check_amount
      ----------------------------------------------------------
      l_debug_info := 'Calculate the rounding error';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;


    /*Bug7394744 Changed query to make sure rounding amount is calculated properly*/
      SELECT l_amt_due - l_best_bank_charge - SUM(document_amount)
      INTO l_rounding_error
        FROM iby_hook_docs_in_pmt_t
       WHERE payment_id = l_selected_check_id;


      ---------------------------------------------------------
      -- Step 10 , subtract the rounding error from the
      --         proposed_payment_amount of the first invoice
      ----------------------------------------------------------
      l_debug_info := 'Fix rounding error';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      IF (l_rounding_error <> 0) then

      -- Bug Fix: 1351943
      -- The Invoice with the maximum Discount Amount is selected
      -- to set-off the rounding error.

      SELECT max(ABS(PAYMENT_CURR_DISCOUNT_TAKEN))
	    INTO l_max_discount_amount
	    FROM iby_hook_docs_in_pmt_t
       WHERE payment_id = l_selected_check_id
         AND ABS(document_amount) >= ABS(l_rounding_error);



	IF (l_max_discount_amount >= l_rounding_error) THEN

	      UPDATE iby_hook_docs_in_pmt_t
         	SET PAYMENT_CURR_DISCOUNT_TAKEN = PAYMENT_CURR_DISCOUNT_TAKEN - l_rounding_error,
	     		document_amount = document_amount + l_rounding_error
       		WHERE payment_id = l_selected_check_id
         	AND ABS(PAYMENT_CURR_DISCOUNT_TAKEN) = l_max_discount_amount
         	AND ABS(document_amount) >= ABS(l_rounding_error)
	 	    AND ROWNUM = 1;



	ELSE
/* Rounding Error is greater than the Maximum Discount Amount. The Rounding Error
amount must be split across invoices. */

		l_rem_rounding_error_amount := l_rounding_error;
		OPEN adjustment_for_rounding_error(l_selected_check_id,
							l_rem_rounding_error_amount);

/* Starting the loop which will process the rounding difference. */

		WHILE (l_rem_rounding_error_amount > 0) LOOP

/* Selecting the maximum discount amount again since the correction for the Rounding Difference
needs to be spread over multiple invoices. */

			FETCH adjustment_for_rounding_error INTO l_max_discount_amount;
		    EXIT WHEN adjustment_for_rounding_error%NOTFOUND;

/* If the maximum discount amount is less than the rounding error then subtract the maximum
discount amount from the discount amount for that invoice. This will amount to making the discount
amount equal to zero. */

			IF (l_max_discount_amount <= l_rem_rounding_error_amount) THEN

				UPDATE iby_hook_docs_in_pmt_t
         			   SET PAYMENT_CURR_DISCOUNT_TAKEN = PAYMENT_CURR_DISCOUNT_TAKEN - l_max_discount_amount,
	     				document_amount = document_amount + l_max_discount_amount
       				 WHERE  payment_id = l_selected_check_id
         			   AND ABS(PAYMENT_CURR_DISCOUNT_TAKEN) = l_max_discount_amount
         			   AND ABS(document_amount) >= ABS(l_rem_rounding_error_amount)
	 			       AND ROWNUM = 1;


/* The rounding difference has been adjusted by the Maximum Discount Amount. So now the rounding difference
amount needs to be recalculated. */

				l_rem_rounding_error_amount := l_rem_rounding_error_amount -
								l_max_discount_amount;
			ELSE

/* The Remaining Rounding Error is less than the maximum discount amount. So now use the remaining
rounding error amount as the adjustment amount. */

				UPDATE iby_hook_docs_in_pmt_t
         			   SET PAYMENT_CURR_DISCOUNT_TAKEN = PAYMENT_CURR_DISCOUNT_TAKEN -
								l_rem_rounding_error_amount,
	     				document_amount = document_amount + l_rem_rounding_error_amount
       				 WHERE payment_id = l_selected_check_id
         			   AND ABS(PAYMENT_CURR_DISCOUNT_TAKEN) = l_max_discount_amount
	 			       AND ABS(document_amount) >= ABS(l_rem_rounding_error_amount)
	 			       AND ROWNUM = 1;


/* The entire rounding error amount has been adjusted in the above step. The loop can now be exited.
The invoice discount amount is subtracted from the rounding error amount to exit the loop. */

				l_rem_rounding_error_amount := l_rem_rounding_error_amount -
								l_max_discount_amount;
			END IF;
		END LOOP;
		CLOSE adjustment_for_rounding_error;
	END IF;
/*1649310 End */

      END IF;

    end if;  -- for (l_ok_to_pay_flag = 'Y')

  END LOOP;

  l_debug_info := 'Close selected_checks Cursor';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;


  CLOSE selected_checks;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO AP_JAPANBANKCHARGEHOOK;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO AP_JAPANBANKCHARGEHOOK;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );

  WHEN BANK_CHARGE_FAILURE THEN
    ROLLBACK TO AP_JAPANBANKCHARGEHOOK;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    IF x_msg_data is NOT NULL THEN
      x_msg_count := 1;
    ELSE
      FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );
    END IF;

  WHEN OTHERS then

   CLOSE selected_checks;

   ROLLBACK TO AP_JAPANBANKCHARGEHOOK;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
   FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
   FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
   FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);

   IF FND_MSG_PUB.Check_Msg_Level
         (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg
                        (       G_PKG_NAME,
                                l_api_name
                        );
   END IF;
   FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );

END ap_JapanBankChargeHook;


END AP_BANK_CHARGE_PKG;

/
