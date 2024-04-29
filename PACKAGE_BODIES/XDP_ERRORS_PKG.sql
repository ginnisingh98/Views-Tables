--------------------------------------------------------
--  DDL for Package Body XDP_ERRORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_ERRORS_PKG" AS
/* $Header: XDPERRRB.pls 120.1 2005/06/15 22:57:59 appldev  $ */

Procedure LogWFError(itemtype in varchar2, itemkey in varchar2, actid in number);

PROCEDURE Set_Message (
		p_object_type 		IN VARCHAR2,
		p_object_key 		IN VARCHAR2,
		p_message_name 		IN VARCHAR2,
		p_message_parameters	IN VARCHAR2,
		p_error_type		IN VARCHAR2 DEFAULT pv_typeSystem)
IS
	l_message_parameters 	xdp_error_log.message_parameters%TYPE;
        MSG  varchar2(2000);
begin

	--
	-- NOTE:
	-- Any caller of this procedure should not use any message longer than 2000 characters.
	-- This API can handle it, but when Get_Message is called, Fnd_Message.Get returns a maximum
	-- of 2000 characters and breaks if the message was bigger than this
	--

	if ((p_object_type is NULL) OR (p_object_key is NULL) OR (p_message_name is NULL)) then
		return;
	end if;

	MSG := FND_MESSAGE.GET_STRING ('XDP', p_message_name);

	-- Fnd_Message.Get fails if chr(0) is within the text
        l_message_parameters := REPLACE(p_message_parameters, chr(0));

	if ((MSG is NOT NULL) AND (LENGTH(MSG) <> 0)) then

		insert into XDP_ERROR_LOG (
			ERROR_ID,
			OBJECT_TYPE,
			OBJECT_KEY,
			ERROR_TIMESTAMP,
			MESSAGE_NAME,
			MESSAGE_PARAMETERS,
			ERROR_TYPE,
			CREATED_BY,
			CREATION_DATE,
			LAST_UPDATED_BY,
			LAST_UPDATE_DATE,
			LAST_UPDATE_LOGIN) values (
			XDP_ERRORS_S.NEXTVAL,
			p_object_type,
			p_object_key,
			SYSDATE,
			p_message_name,
			nvl(l_message_parameters, NULL),
			p_error_type,
			FND_GLOBAL.USER_ID,
			SYSDATE,
			FND_GLOBAL.USER_ID,
			SYSDATE,
			FND_GLOBAL.LOGIN_ID);
	END IF;

EXCEPTION
WHEN OTHERS THEN
	Rollback;
	xdp_utilities.generic_error('XDP_ERRORS_PKG', 'Set_Message', sqlcode, sqlerrm);
END SET_MESSAGE;

PROCEDURE Set_Message_Auto (
		p_object_type 		IN VARCHAR2,
		p_object_key 		IN VARCHAR2,
		p_message_name 		IN VARCHAR2,
		p_message_parameters	IN VARCHAR2,
		p_error_type		IN VARCHAR2 DEFAULT pv_typeSystem)
IS
 	PRAGMA AUTONOMOUS_TRANSACTION;

begin
	Set_Message (
		p_object_type 		=> p_object_type,
		p_object_key 		=> p_object_key,
		p_message_name 		=> p_message_name,
		p_message_parameters	=> p_message_parameters,
		p_error_type		=> p_error_type);
	commit;

END SET_MESSAGE_AUTO;


--  Wrapper to log workflow errors..
Procedure LOG_WF_ERROR (itemtype        in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        funcmode        in varchar2,
                        resultout       OUT NOCOPY varchar2) IS

 l_result varchar2(10);
 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
         IF (funcmode = 'RUN') THEN
           LogWFError(itemtype, itemkey, actid);
           resultout := 'COMPLETE';
           return;
         END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDP_ERRORS_PKG', 'LOG_WF_ERROR', itemtype, itemkey, to_char(actid), funcmode);
 raise;

END LOG_WF_ERROR;


Procedure LogWFError(itemtype in varchar2,
                     itemkey in varchar2,
                     actid in NUMBER       ) IS

 l_ObjectType      VARCHAR2(100);
 l_ObjectKey_char  VARCHAR2(100);
 l_ObjectKey       NUMBER;
 l_order_count     NUMBER;
 l_line_count      NUMBER;
 l_pkg_count       NUMBER;
 l_workitem_count  NUMBER;
 l_fa_count        NUMBER;
 l_message_type    VARCHAR2(100);
 l_message_params  xdp_error_log.message_parameters%TYPE;
 l_message         xdp_error_log.message_parameters%TYPE;
 l_error_type      VARCHAR2(100);

BEGIN

     l_order_count     := instr(itemkey,'MAIN') ;
     l_line_count      := instr(itemkey,'SVC') ;
     l_pkg_count       := instr(itemkey,'LINE');
     l_workitem_count  := instr(itemkey,'WI') ;
     l_fa_count        := instr(itemkey,'FA') ;

     IF l_order_count > 0 THEN
        l_ObjectType := 'ORDER';
        l_ObjectKey := WF_ENGINE.GETITEMATTRNUMBER(itemtype => LogWFError.itemtype,
                                                   itemkey  => LogWFError.itemkey,
                                                   aname    => 'ORDER_ID');

     ELSIF (l_line_count > 0 OR l_pkg_count > 0  )  THEN
        l_ObjectType := 'LINE';
        l_ObjectKey := WF_ENGINE.GETITEMATTRNUMBER(itemtype => LogWFError.itemtype,
                                                   itemkey  => LogWFError.itemkey,
                                                   aname    => 'LINE_ITEM_ID');

     ELSIF (l_workitem_count > 0 AND l_fa_count = 0) THEN
        l_ObjectType := 'WI';
        l_ObjectKey := wf_engine.GetItemAttrNumber(itemtype => LogWFError.itemtype,
                                                   itemkey  => LogWFError.itemkey,
                                                   aname    => 'WORKITEM_INSTANCE_ID');

     ELSIF l_fa_count > 0 THEN
        l_ObjectType := 'FA';
        l_ObjectKey := wf_engine.GetItemAttrNumber(itemtype => LogWFError.itemtype,
                                                   itemkey  => LogWFError.itemkey,
                                                   aname    => 'FA_INSTANCE_ID');
     END IF;

     --skilaru 01/27/02
     --If we couldnt find any key then this node is being used some where..
     --So lets log for what order ID this thing went wrong..
     --ideally we should never get into this kind of a situation..
     IF l_ObjectKey IS NULL THEN
        l_ObjectType := 'ORDER';
        l_ObjectKey := WF_ENGINE.GETITEMATTRNUMBER(itemtype => LogWFError.itemtype,
                                                   itemkey  => LogWFError.itemkey,
                                                   aname    => 'ORDER_ID');
     END IF;

     --SET_MESSAGE accepts object key as varchar..
     l_ObjectKey_Char := TO_CHAR( l_ObjectKey );

     --Who ever uses this activity in workflow have to pass what they want to log
     --and whether its a BUSINESS or SYSTEM error.
     l_message := WF_ENGINE.GetActivityattrtext(itemtype =>LogWFError.itemtype,
                                                      itemkey  =>LogWFError.itemkey,
                                                      actid    =>LogWFError.actid,
                                                      aname    =>'MESSAGE');

     l_error_type := WF_ENGINE.GetActivityattrtext(itemtype =>LogWFError.itemtype,
                                                      itemkey  =>LogWFError.itemkey,
                                                      actid    =>LogWFError.actid,
                                                      aname    =>'ERROR_TYPE');

     --build the message parameters fro setmessage signature..
     l_message_params := 'MESSAGE='||l_message||'#XDP#';
     -- skutil.sk_log( l_message_params );

     SET_MESSAGE( l_ObjectType, l_ObjectKey, 'XDP_ERROR_MESSAGE', l_message_params, l_error_type );
END LogWFError;


FUNCTION GET_MESSAGE (
	p_message_name 		IN VARCHAR2,
	p_message_parameters	IN VARCHAR2)
return VARCHAR2
is
l_temp_1        xdp_error_log.message_parameters%TYPE;
l_temp_2        xdp_error_log.message_parameters%TYPE;
l_name          xdp_error_log.message_parameters%TYPE;
l_value         xdp_error_log.message_parameters%TYPE;
l_offset        NUMBER;
l_offset1       NUMBER;
l_last_offset   NUMBER;
l_message_text  xdp_error_log.message_parameters%TYPE;

BEGIN
	l_message_text := '';

	if p_message_name is not null then
		FND_MESSAGE.SET_NAME ('XDP', p_message_name);
	else
		return l_message_text;
	end if;

	if p_message_parameters is not null then

		-- p_message_parameters should be of format:
		-- 'ADAPTER_NAME=SuperTel1#XDP#STATUS=SUSPENDED#XDP#'

		l_last_offset := 1;
		l_temp_1 := p_message_parameters;

		for i in 1..100 loop
			l_offset := INSTR (l_temp_1, pv_MsgParamSeparator, 1, i);
			if (l_offset <> 0) then
				-- Tag found
 				l_temp_2 := substr (l_temp_1, l_last_offset,
							l_offset-l_last_offset);
				-- DBMS_OUTPUT.PUT_LINE (l_temp_2);
				l_offset1 := INSTR (l_temp_2, pv_NameValueSeparator);
				if (l_offset1 <> 0) then
 					l_name := substr (l_temp_2, 1, l_offset1-1);
 					l_value := substr (l_temp_2, l_offset1+1);
					-- XDP_UTILITIES.DISPLAY ('Name:'||l_name);
					-- XDP_UTILITIES.DISPLAY ('Value:'||l_value);
					FND_MESSAGE.SET_TOKEN (l_name, l_value);
				else
					-- error, = missing between name, value
					exit;
				end if;
				l_last_offset := l_offset+pv_MsgParamSeparatorSize;
			else
				-- No more tags
				exit;
			end if;
		END LOOP;
	END IF;

	l_message_text := FND_MESSAGE.GET();
	return l_message_text;

EXCEPTION
WHEN OTHERS THEN
	xdp_utilities.generic_error('XDP_ERRORS_PKG', 'Get_Message', sqlcode, sqlerrm);
END GET_MESSAGE;

PROCEDURE Get_Last_Message (
		p_object_type 		IN VARCHAR2,
		p_object_key 		IN VARCHAR2,
		p_message 		OUT NOCOPY VARCHAR2,
		p_error_type		OUT NOCOPY VARCHAR2,
		p_message_timestamp 	OUT NOCOPY DATE)
is
BEGIN
	begin
		select message, error_type, MAX(error_timestamp)
		into p_message, p_error_type, p_message_timestamp
		from XDP_ERROR_LOG_V
		where object_type = p_object_type and object_key = p_object_key;
	exception
		WHEN NO_DATA_FOUND then
			null;
	END;

EXCEPTION
WHEN OTHERS THEN
	xdp_utilities.generic_error('XDP_ERRORS_PKG', 'Get_Last_Message', sqlcode, sqlerrm);
END GET_LAST_MESSAGE;

PROCEDURE Update_Error_Count (
		p_object_type 		IN VARCHAR2,
		p_object_key 		IN VARCHAR2,
		p_error_count		IN NUMBER DEFAULT 0)
is
begin

	UPDATE xdp_error_count SET
		error_count = p_error_count,
		last_updated_by = FND_GLOBAL.USER_ID,
		last_update_date = sysdate,
		last_update_login = FND_GLOBAL.USER_ID
	WHERE
		object_type = p_object_type and object_key = p_object_key;

	if (sql%notfound) then

		INSERT INTO XDP_ERROR_COUNT (
			object_type,
			object_key,
			error_count,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login
		) VALUES (
			p_object_type,
			p_object_key,
			p_error_count,
			FND_GLOBAL.USER_ID,
			sysdate,
			FND_GLOBAL.USER_ID,
			sysdate,
			FND_GLOBAL.LOGIN_ID);
	end if;

END UPDATE_ERROR_COUNT;

FUNCTION Get_Error_Count (
		p_object_type 		IN VARCHAR2,
		p_object_key 		IN VARCHAR2)
return		NUMBER
is
l_errorCount	NUMBER := 0;
begin

	begin
		SELECT error_count into l_errorCount
		FROM xdp_error_count
		WHERE object_type = p_object_type and object_key = p_object_key;

	EXCEPTION
	when no_data_found then
		null;
	END;

	return l_errorCount;

END Get_Error_Count;

END XDP_ERRORS_PKG;

/
