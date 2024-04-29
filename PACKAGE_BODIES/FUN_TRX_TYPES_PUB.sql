--------------------------------------------------------
--  DDL for Package Body FUN_TRX_TYPES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_TRX_TYPES_PUB" AS
--  $Header: funtrxutilb.pls 120.15.12010000.4 2009/11/17 07:41:05 srampure ship $

/****************************************************************
* PROCEDURE  get_trx_type_by_id					*
*								*
*	This procedure returns status of a transaction and the 	*
*	invoicing option for a given trx_type_id		*
****************************************************************/

	PROCEDURE get_trx_type_by_id (
	  p_trx_type_id in number,
	  x_trx_type_code out NOCOPY varchar2,
	  x_need_invoice out NOCOPY varchar2,
	  x_enabled out NOCOPY varchar2
	) IS

	CURSOR c_trx_type_id IS
	  select trx_type_code ,
	         allow_invoicing_flag ,
	         enabled_flag
	  from FUN_TRX_TYPES_VL
	  where trx_type_id = p_trx_type_id;

	l_trx_type_id 	c_trx_type_id%rowtype;

	BEGIN

	  OPEN c_trx_type_id;
	  FETCH c_trx_type_id into l_trx_type_id;

	  IF c_trx_type_id%NOTFOUND THEN
	  	close c_trx_type_id;
	  	x_trx_type_code	:=null;
	   	x_need_invoice	:=null;
     	  	x_enabled	:=null;

     	  END IF;

     	  x_trx_type_code	:=l_trx_type_id.trx_type_code;
     	  x_need_invoice	:=l_trx_type_id.allow_invoicing_flag;
     	  x_enabled		:=l_trx_type_id.enabled_flag;

     	  close c_trx_type_id;

	END;


/****************************************************************
* PROCEDURE  :get_trx_type_code					*
*								*
*	This procedure returns the status of a transaction and 	*
*	invoicing option for a given transaction type code	*
****************************************************************/

	PROCEDURE get_trx_type_by_code (
	  p_trx_type_code in varchar2,
	  x_trx_type_id out NOCOPY number,
	  x_need_invoice out NOCOPY varchar2,
	  x_enabled out NOCOPY varchar2
	) IS

	CURSOR c_trx_type_code IS
	  select trx_type_id ,
	         allow_invoicing_flag ,
	         enabled_flag
	  from FUN_TRX_TYPES_VL
	  where trx_type_code = p_trx_type_code;

	l_trx_type_code 	c_trx_type_code%rowtype;

	BEGIN
	  OPEN c_trx_type_code;
	  FETCH c_trx_type_code into l_trx_type_code;
	  IF c_trx_type_code%NOTFOUND THEN
	  	close c_trx_type_code;
	  	x_trx_type_id	:=null;
	     	x_need_invoice	:=null;
     	  	x_enabled	:=null;
     	  END IF;

     	  x_trx_type_id		:=l_trx_type_code.trx_type_id;
     	  x_need_invoice	:=l_trx_type_code.allow_invoicing_flag;
     	  x_enabled		:=l_trx_type_code.enabled_flag;

     	  close c_trx_type_code;

	END;

/****************************************************************
* FUNCTION  : is_trx_type_manual_approve			*
*								*
*	This function returns the manual approval option for a 	*
*	transaction type name given trx_type_id			*
****************************************************************/

	FUNCTION is_trx_type_manual_approve
	(
	  p_trx_type_id in number
	) RETURN VARCHAR2  IS

	CURSOR c_trx_type_manual_approve is
	  select manual_approve_flag
	  from FUN_TRX_TYPES_VL
	  where trx_type_id = p_trx_type_id;

	x_manual_approve varchar2(100);

	BEGIN

	  OPEN c_trx_type_manual_approve;
	  FETCH c_trx_type_manual_approve into x_manual_approve;
	  IF c_trx_type_manual_approve%NOTFOUND THEN
	  	close c_trx_type_manual_approve;
	  	return null;
     	  END IF;

     	  close c_trx_type_manual_approve;

	  RETURN x_manual_approve;


	END;


/****************************************************************
* PROCEDURE  : get_trx_type_map					*
* 								*
*	This procedure returns the mapping details of transation*
*	type name given the org it is associated with and the id*
****************************************************************/
-- <bug 3520961>
-- The whole code of get_trx_type_map has been changed, remove
-- the use of cursor and change the defaulting logic
-- Added parameter p_trx_date for bug 5176112

	PROCEDURE get_trx_type_map (
	  p_org_id in number,
	  p_trx_type_id in number,
          p_trx_date    in date,
	  p_trx_id in number,
	  x_memo_line_id out NOCOPY number,
	  x_memo_line_name out NOCOPY varchar2,
	  x_ar_trx_type_id out NOCOPY number,
	  x_ar_trx_type_name out NOCOPY varchar2,
	  x_default_term_id  out NOCOPY number
	) IS
	--ER: 8288979
	l_init_amount_dr number;
	l_init_amount_cr number;
	l_trx_type  varchar2(4);

	CURSOR c_get_trx_amount IS
	SELECT INIT_AMOUNT_DR, INIT_AMOUNT_CR
	FROM fun_trx_headers
	WHERE TRX_ID = p_trx_id;

        CURSOR c_get_map IS
	SELECT  m.memo_line_id,
                m.name,
                ar.cust_trx_type_id,
		ar.name ,
                Nvl(ar.default_term, 4)
	FROM 	FUN_TRX_TYPE_AR_MAPS tm,
		RA_CUST_TRX_TYPES_ALL ar,
		AR_MEMO_LINES_ALL_VL m
	WHERE 	tm.trx_type_id   =   p_trx_type_id      AND
		tm.org_id        =   p_org_id           AND
		tm.ar_trx_type_id = ar.cust_trx_type_id AND
		tm.memo_line_id   = m.memo_line_id      AND
		tm.org_id         = m.org_id            AND
		ar.org_id         = m.org_id            AND
                p_trx_date BETWEEN Nvl(ar.start_date,p_trx_date) AND Nvl(ar.end_date, p_trx_date) AND
                p_trx_date BETWEEN Nvl(m.start_date, p_trx_date) AND Nvl(m.end_date, p_trx_date);
	-- Bug: 9126518
	CURSOR c_get_cm_map IS
	SELECT  m.memo_line_id,
                m.name,
                ar.cust_trx_type_id,
		ar.name ,
                null default_term_id
	FROM 	FUN_TRX_TYPE_AR_MAPS tm,
		RA_CUST_TRX_TYPES_ALL ar,
		AR_MEMO_LINES_ALL_VL m
	WHERE 	tm.trx_type_id   =   p_trx_type_id      AND
		tm.org_id        =   p_org_id           AND
		tm.ar_cm_trx_type_id = ar.cust_trx_type_id AND
		tm.memo_line_id   = m.memo_line_id      AND
		tm.org_id         = m.org_id            AND
		ar.org_id         = m.org_id            AND
                p_trx_date BETWEEN Nvl(ar.start_date,p_trx_date) AND Nvl(ar.end_date, p_trx_date) AND
                p_trx_date BETWEEN Nvl(m.start_date, p_trx_date) AND Nvl(m.end_date, p_trx_date);


        CURSOR c_get_def_map IS
        SELECT m.memo_line_id,
               m.name,
               ar.cust_trx_type_id,
               ar.name,
               4 default_term_id
        FROM fun_system_options fun,
               RA_CUST_TRX_TYPES_ALL ar,
               AR_MEMO_LINES_ALL_VL m
        WHERE fun.default_memo_line_id     = m.memo_line_id
        AND   fun.default_ar_trx_type_id   = ar.cust_trx_type_id
        AND   ar.org_id                    = m.org_id
        AND   ar.org_id                    = p_org_id
        AND   p_trx_date BETWEEN Nvl(ar.start_date,p_trx_date) AND Nvl(ar.end_date, p_trx_date)
        AND   p_trx_date BETWEEN Nvl(m.start_date, p_trx_date) AND Nvl(m.end_date, p_trx_date);

        CURSOR c_get_def_cm_map IS
        SELECT m.memo_line_id,
               m.name,
               ar.cust_trx_type_id,
               ar.name,
               null default_term_id
        FROM fun_system_options fun,
               RA_CUST_TRX_TYPES_ALL ar,
               AR_MEMO_LINES_ALL_VL m
        WHERE fun.default_memo_line_id     = m.memo_line_id
        AND   fun.default_cm_trx_type_id   = ar.cust_trx_type_id
        AND   ar.org_id                    = m.org_id
        AND   ar.org_id                    = p_org_id
        AND   p_trx_date BETWEEN Nvl(ar.start_date,p_trx_date) AND Nvl(ar.end_date, p_trx_date)
        AND   p_trx_date BETWEEN Nvl(m.start_date, p_trx_date) AND Nvl(m.end_date, p_trx_date);

	BEGIN

	l_trx_type := 'INV';
	OPEN c_get_trx_amount;
	FETCH c_get_trx_amount INTO l_init_amount_dr,
				    l_init_amount_cr;
        IF(l_init_amount_dr is null) THEN
		l_init_amount_dr := 0;
	END IF;
	IF(l_init_amount_cr is null) THEN
		l_init_amount_cr := 0;
	END IF;
	-- Credit memo transaction
	if( l_init_amount_dr < 0 OR l_init_amount_cr > 0) THEN
		l_trx_type := 'CM';
	END IF;

	IF( l_trx_type = 'INV') THEN
		OPEN  c_get_map;
		FETCH c_get_map INTO  x_memo_line_id,
					   x_memo_line_name,
					   x_ar_trx_type_id,
					   x_ar_trx_type_name ,
					   x_default_term_id;
	       CLOSE c_get_map;
	       IF  x_memo_line_id IS NULL OR  x_memo_line_name IS NULL
		OR  x_ar_trx_type_id IS NULL OR x_ar_trx_type_name IS NULL
		THEN
		   OPEN  c_get_def_map;
		   FETCH c_get_def_map INTO  x_memo_line_id,
					     x_memo_line_name,
					     x_ar_trx_type_id,
					     x_ar_trx_type_name ,
					     x_default_term_id;
		  CLOSE c_get_def_map;

	       END IF;
	ELSE
	--ER: 8288979. This is for credit memo transaction
		OPEN  c_get_cm_map;
		FETCH c_get_cm_map INTO  x_memo_line_id,
					 x_memo_line_name,
					 x_ar_trx_type_id,
					 x_ar_trx_type_name ,
					 x_default_term_id;
	       CLOSE c_get_cm_map;
	       IF  x_memo_line_id IS NULL OR  x_memo_line_name IS NULL
		OR  x_ar_trx_type_id IS NULL OR x_ar_trx_type_name IS NULL
		THEN
		   OPEN  c_get_def_cm_map;
		   FETCH c_get_def_cm_map INTO  x_memo_line_id,
						x_memo_line_name,
					        x_ar_trx_type_id,
					        x_ar_trx_type_name ,
					        x_default_term_id;
		  CLOSE c_get_def_cm_map;

	       END IF;

	END IF;



EXCEPTION
    WHEN OTHERS THEN
        RAISE;

END get_trx_type_map;


/****************************************************************
* FUNCTION  : get_ar_trx_creation_sign    			*
*								*
*	For a given intercompany transaction type, this function*
*       returns the transaction creation sign of the associated *
*	AR transaction type. The input to the function is the   *
*	intercompany transaction type, organization id and the  *
*	transaction batch date                                  *
*								*
****************************************************************/
FUNCTION get_ar_trx_creation_sign (
	  p_org_id in number,
	  p_trx_type_id in number,
          p_trx_date    in date,
	  p_trx_type in varchar2
       ) RETURN NUMBER IS

	--ER: 8288979
       CURSOR c_get_sign (p_trx_type_id  NUMBER,
                          p_org_id       NUMBER,
                          p_trx_date     DATE)
       IS
       SELECT  decode(ar.creation_sign,'P',+1,'N',-1,'A',0)
       FROM     FUN_TRX_TYPE_AR_MAPS tm,
                RA_CUST_TRX_TYPES_ALL ar
       WHERE    tm.trx_type_id   =   p_trx_type_id      AND
                tm.org_id        =   p_org_id           AND
                tm.org_id        =   ar.org_id          AND
                tm.ar_trx_type_id = ar.cust_trx_type_id AND
                p_trx_date BETWEEN Nvl(ar.start_date,p_trx_date) AND Nvl(ar.end_date, p_trx_date);

       CURSOR c_get_cm_sign (p_trx_type_id  NUMBER,
                          p_org_id       NUMBER,
                          p_trx_date     DATE)
       IS
       SELECT  decode(ar.creation_sign,'P',+1,'N',-1,'A',0)
       FROM     FUN_TRX_TYPE_AR_MAPS tm,
                RA_CUST_TRX_TYPES_ALL ar
       WHERE    tm.trx_type_id   =   p_trx_type_id      AND
                tm.org_id        =   p_org_id           AND
                tm.org_id        =   ar.org_id          AND
                tm.ar_cm_trx_type_id = ar.cust_trx_type_id AND
                p_trx_date BETWEEN Nvl(ar.start_date,p_trx_date) AND Nvl(ar.end_date, p_trx_date);

       CURSOR c_get_def ( p_org_id       NUMBER,
                          p_trx_date     DATE)
        IS
        SELECT decode(ar.creation_sign,'P',+1,'N',-1,'A',0)
        FROM   fun_system_options fun,
               RA_CUST_TRX_TYPES_ALL ar
        WHERE fun.default_ar_trx_type_id   = ar.cust_trx_type_id
        AND   ar.org_id                    = p_org_id
        AND   p_trx_date BETWEEN Nvl(ar.start_date,p_trx_date) AND Nvl(ar.end_date, p_trx_date);

       CURSOR c_get_def_cm ( p_org_id       NUMBER,
                          p_trx_date     DATE)
        IS
        SELECT decode(ar.creation_sign,'P',+1,'N',-1,'A',0)
        FROM   fun_system_options fun,
               RA_CUST_TRX_TYPES_ALL ar
        WHERE fun.default_cm_trx_type_id   = ar.cust_trx_type_id
        AND   ar.org_id                    = p_org_id
        AND   p_trx_date BETWEEN Nvl(ar.start_date,p_trx_date) AND Nvl(ar.end_date, p_trx_date);

       x_ar_creation_sign number;
       BEGIN
	IF( p_trx_type = 'INV') THEN
	       OPEN c_get_sign (p_trx_type_id, p_org_id, p_trx_date);
	       FETCH c_get_sign INTO  x_ar_creation_sign;

	       IF c_get_sign%NOTFOUND
	       THEN
		   OPEN c_get_def (p_org_id, p_trx_date);
		   FETCH c_get_def INTO x_ar_creation_sign;
		   CLOSE c_get_def;
	       END IF;

	       CLOSE c_get_sign;
	ELSE
	--ER: 8288979. This is for credit memo transaction
	       OPEN c_get_cm_sign (p_trx_type_id, p_org_id, p_trx_date);
	       FETCH c_get_cm_sign INTO  x_ar_creation_sign;

	       IF c_get_cm_sign%NOTFOUND
	       THEN
		   OPEN c_get_def_cm (p_org_id, p_trx_date);
		   FETCH c_get_def_cm INTO x_ar_creation_sign;
		   CLOSE c_get_def_cm;
	       END IF;
	       CLOSE c_get_cm_sign;
	END IF;
       RETURN x_ar_creation_sign;

       EXCEPTION
       WHEN OTHERS THEN
          RETURN  NULL;
       END get_ar_trx_creation_sign;

END FUN_TRX_TYPES_PUB;

/
