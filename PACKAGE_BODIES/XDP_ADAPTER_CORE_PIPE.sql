--------------------------------------------------------
--  DDL for Package Body XDP_ADAPTER_CORE_PIPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_ADAPTER_CORE_PIPE" AS
/* $Header: XDPACOPB.pls 120.2 2005/07/07 02:23:52 appldev ship $ */


 pv_ChannelTruncLength number := 4;
 pv_ChannelLength number := 30;

Procedure CleanupPipe(p_ChannelName in varchar2,
		      p_CleanReturn in varchar2 default 'Y')
is
begin

 DBMS_PIPE.PURGE(p_ChannelName);
 if p_CleanReturn = 'Y' then
	DBMS_PIPE.PURGE(GetReturnChannelName(p_ChannelName => CleanupPipe.p_ChannelName));
 end if;

end CleanupPipe;

Procedure SendPipedMessage(p_ChannelName in varchar2,
			    p_Message in varchar2)
is
 ReturnCode number := 0;
begin

     -- dbms_output.put_line(to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));
     -- dbms_output.put_line('Sending ' || p_Message || ' on ' || p_ChannelName);
     DBMS_PIPE.PACK_MESSAGE(SendPipedMessage.p_Message);
     DBMS_PIPE.PACK_MESSAGE(SendPipedMessage.p_ChannelName);
     ReturnCode := DBMS_PIPE.SEND_MESSAGE
			(SendPipedMessage.p_ChannelName, pv_AckTimeout);

     -- dbms_output.put_line('After Sending... Return Code: ' || ReturnCode);
end SendPipedMessage;


Procedure ReceivePipedMessage(	p_ChannelName in varchar2,
				p_Timeout in number,
				p_ErrorCode OUT NOCOPY number,
				p_Message OUT NOCOPY varchar2)
is
 ActualTimeout number;
begin

	if p_Timeout is null then
		ActualTimeout := pv_AckTimeout;
	else
		ActualTimeout := p_Timeout;
	end if;


	-- dbms_output.put_line(to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));
	-- dbms_output.put_line('DBMS_PIPE.RECEIVE. Channel: ' || p_ChannelName || ' Timeout: ' || ActualTimeout);
	p_ErrorCode := DBMS_PIPE.RECEIVE_MESSAGE
			(ReceivePipedMessage.p_ChannelName, ActualTimeout);

--	dbms_output.put_line('After read..: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));
	-- dbms_output.put_line('Error Code: ' || p_ErrorCode);
	if p_ErrorCode = 0  then
		if DBMS_PIPE.NEXT_ITEM_TYPE <> 0  then
			-- dbms_output.put_line('Unpacking...');
			DBMS_PIPE.UNPACK_MESSAGE(p_Message);
			-- dbms_output.put_line('AFTER Unpacking...' || substr(p_Message,1,200));
		else
			p_Message := null;
		end if;
	end if;

-- exception
-- when others then
-- dbms_output.put_line('PIPE EXCEPTION: ' || SQLCODE);
-- dbms_output.put_line('PIPE EXCEPTION: ' || substr(sqlerrm,1,200));
-- dbms_output.put_line('PIPE EXCEPTION: ' || substr(sqlerrm,201,200));
end ReceivePipedMessage;


Function GetReturnChannelName(p_ChannelName in varchar2) return varchar2
is
 ReturnChannelName varchar2(40);
begin

	ReturnChannelName := GetReturnChannelName.p_ChannelName || '_R';

	return (ReturnChannelName);

end GetReturnChannelName;


function ConstructChannelName (p_ChannelType in varchar2,
				 p_ChannelName in varchar2) return varchar2
is

begin

 if p_ChannelType = 'CONTROL' then
	return ( p_ChannelName || '_C');
 elsif p_ChannelType = 'APPL' then
	return ( p_ChannelName || '_A');
 else
	return (p_ChannelName);
 end if;

end ConstructChannelName;


function GetUniqueChannelName (p_Name in varchar2) return varchar2
is
 l_ChannelName   varchar2(30);
 l_Temp        varchar2(80);
 l_Seq         number;
 l_SeqLen     number;
 l_TruncLen   number;
begin
  l_temp := RTRIM(p_Name,' ');
  l_temp := LTRIM(l_temp);


  l_temp := REPLACE(l_Temp, ' ', '_');

   SELECT XDP_CHANNEL_S.NEXTVAL into l_Seq
   FROM dual;

   l_ChannelName := to_char(l_Seq);

   l_SeqLen := LENGTH(l_ChannelName);

   l_TruncLen := pv_ChannelLength - (l_SeqLen + pv_ChannelTruncLength);

   l_ChannelName := SUBSTR(l_Temp, 1, l_TruncLen) || '_' || l_ChannelName;

 RETURN l_ChannelName;

end GetUniqueChannelName;

begin

 pv_AckTimeout := XDP_ADAPTER_CORE_DB.GetAckTimeOut;

end XDP_ADAPTER_CORE_PIPE;

/
