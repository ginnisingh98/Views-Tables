--------------------------------------------------------
--  DDL for Package Body XNP_DEF_JEOPARDY_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_DEF_JEOPARDY_INT" AS
/* $Header: XNPJINTB.pls 120.1 2005/06/21 04:07:32 appldev ship $ */

--------------------------------------------------------------------------------
-----  API Name      : get_interval
-----  Type          : Private
-----  Purpose       : Get interval for the default jeopardy timer.
-----  Parameters    : p_order_id
--------------------------------------------------------------------------------


/*
--  This function was truncating the Time component in the due date
--  also it was nota taking care of the Due date already passed
--  scenario
--  All these errors have been corrected in the new function

FUNCTION get_interval ( p_order_id IN NUMBER)
RETURN number
IS

 l_due_date	DATE;
 l_interval     NUMBER;
 l_due_date_string VARCHAR2(40);
 e_DUE_DATE_NOT_FOUND	EXCEPTION;

begin
	l_interval := 0;

	-- Select Due Date from xdp_oe_order_headers
	select NVL(to_char(due_date),'NOT FOUND')
	into l_due_date_string
        --FROM xdp_oe_order_headers
        --skilaru 03/27/2001
	from xdp_order_headers
	where order_id = p_order_id;

	IF l_due_date_string = 'NOT FOUND'
	THEN
		RAISE e_DUE_DATE_NOT_FOUND;
	ELSE
		l_due_date := to_date(l_due_date_string);

		l_interval := (l_due_date - sysdate)*24*60*60;

		return l_interval;

	END IF;

	EXCEPTION
		WHEN e_DUE_DATE_NOT_FOUND THEN
		  fnd_message.set_name('XNP','XNP_JEP_DUE_DATE_NOT_FOUND');
		  fnd_message.set_token('ORDER_ID',p_order_id);
		APP_EXCEPTION.RAISE_EXCEPTION;
		return NULL;
end;
*/

--  Get Jeopardy interval in seconds for the Order using Due date
--  If Due date is already passed then return 0


FUNCTION get_interval (p_order_id IN NUMBER)
RETURN number
IS
	l_due_date DATE;
	l_interval     NUMBER;
	e_DUE_DATE_NOT_FOUND   EXCEPTION;

BEGIN

	SELECT due_date
    INTO l_due_date
    --FROM xdp_oe_order_headers
    --skilaru 03/27/2001
    FROM xdp_order_headers
    WHERE order_id = p_order_id;


	IF l_due_date IS NULL THEN
		RAISE e_DUE_DATE_NOT_FOUND;
	ELSE
		l_interval := (l_due_date - sysdate)*24*60*60;

		-- If Due date is already passed then in Jeopardy
		IF l_interval < 0 THEN
			l_interval := 0;
		END IF;

		return l_interval;

	END IF;

EXCEPTION
 	WHEN e_DUE_DATE_NOT_FOUND THEN
 		fnd_message.set_name('XNP','XNP_JEP_DUE_DATE_NOT_FOUND');
 		fnd_message.set_token('ORDER_ID',p_order_id);
        APP_EXCEPTION.RAISE_EXCEPTION;
 		RETURN null;
END get_interval;


END xnp_def_jeopardy_int;

/
