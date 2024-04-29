--------------------------------------------------------
--  DDL for Package Body XDP_ADAPTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_ADAPTER" AS
/* $Header: XDPADBOB.pls 120.1 2005/06/08 23:39:05 appldev  $ */

e_RequiredInputDataNotPassed  	EXCEPTION;
e_DisplayNameNotUnique  	EXCEPTION;
-- e_AsyncParamWrong 		EXCEPTION;
e_ImplParamWrong 		EXCEPTION;
e_ConnParamWrong		EXCEPTION;
e_InboundParamWrong		EXCEPTION;

Procedure validate_operation(p_ChannelName in varchar2, p_Operation in varchar2,
                        p_CPID OUT NOCOPY NUMBER,
                        p_ProcessID OUT NOCOPY NUMBER,
	   	 	p_retcode OUT NOCOPY NUMBER,
		 	p_errbuf OUT NOCOPY VARCHAR2);

-- TODO Detailed processing for e_RequiredInputDataNotPassed

Procedure Create_Adapter(p_FeName in varchar2,
			   p_AdapterType in varchar2,
		    	   p_AdapterName in varchar2 default NULL,
			   p_AdapterDispName in varchar2,
			   p_ConcQID in number,
			   p_StartupMode in varchar2 default 'MANUAL',
			   p_UsageCode in varchar2 default 'NORMAL',
			   p_LogLevel in varchar2 default 'ERROR',
			   p_CODFlag in varchar2 default 'N',
			   p_MaxIdleTime in number default 0,
			   p_LogFileName in varchar2 default NULL,
			   p_SeqInFE in number default null,
			   p_CmdLineOpts in varchar2 default NULL,
                           p_CmdLineArgs in varchar2 default NULL,
			   p_retcode OUT NOCOPY NUMBER,
			   p_errbuf OUT NOCOPY VARCHAR2
			)
is
 l_ChannelName varchar2(40);
 l_AdapterName varchar2(40);
 l_ApplicationMode xdp_adapter_types_b.application_mode%TYPE;
 l_AdapterClass xdp_adapter_types_b.adapter_class%TYPE;
 l_ConnReqFlag xdp_adapter_types_b.connection_required_flag%TYPE;
 l_InboundReqFlag xdp_adapter_types_b.inbound_required_flag%TYPE;
 l_LogFileName xdp_adapter_reg.log_file_name%TYPE;
 l_FeID number := -1;

 l_GenCountActive NUMBER := 0;
 l_GenCountFuture NUMBER := 0;
 l_StartStatus VARCHAR2(30) := pv_statusNotAvailable;

 lv_mode VARCHAR2(8);  -- maintenance mode profile

 e_NoGenericExists EXCEPTION;
 e_AdapterConfigNA EXCEPTION;
 l_count number := 0;

begin
if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
	FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'XDP_ADAPTER.CREATE_ADAPTER',
				'BEGIN:p_AdapterDispName: '||p_AdapterDispName);
end if;
	p_retcode := 0;
	p_errbuf := '';

-- ********** Validate Order Type in High Availability Maintenance Mode

       FND_PROFILE.GET('APPS_MAINTENANCE_MODE', lv_mode);

       IF lv_mode = 'MAINT' THEN
           raise e_AdapterConfigNA;
       END IF;
-- **********


        --
        -- Validate mandatory parameters
        --
	if p_FeName is null or
		p_AdapterType is null or
		p_AdapterDispName is null or
		p_ConcQID is null then
                if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
		    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.CREATE_ADAPTER',
					'Required parameters are not passed');
		end if;
 		raise e_RequiredInputDataNotPassed;
	end if;

        --
        -- Validate unique display name
        --
	select count(*) into l_count from xdp_adapter_reg
		where adapter_display_name = p_AdapterDispName;
	if l_count > 0 then
 		raise e_DisplayNameNotUnique;
	end if;

	l_FeID := XDP_ADAPTER_CORE_DB.Get_Fe_Id_For_Name (p_FeName);

        select application_mode, adapter_class, connection_required_flag, inbound_required_flag
        into l_ApplicationMode, l_AdapterClass, l_ConnReqFlag, l_InboundReqFlag
        from xdp_adapter_types_b
        where adapter_type = p_AdapterType;

	--
	-- Validate parameters for non-implemented adapters
	--
	if l_AdapterClass = 'NONE' then
		if (p_LogFileName is not null) or
		   (p_CmdLineOpts is not null) or
                   (p_CmdLineArgs is not null) then
 			raise e_ImplParamWrong;
		end if;
	end if;

	--
	-- Validate parameters for inbound-only adapters
	--
	if (l_InboundReqFlag = 'Y' and l_ApplicationMode = 'NONE') then

		-- Startup Mode is SOD
		if (p_StartupMode = 'START_ON_DEMAND') then
			raise e_InboundParamWrong;
		end if;
	end if;

	--
	-- Validate connection parameters
	--

	-- If no connection required
	if l_ConnReqFlag = 'N' then
		if (p_CODFlag = 'Y') then
			raise e_ConnParamWrong;
		end if;
	-- If connection required
	else
		-- If SOD and COD
		if (p_CODFlag = 'Y' and p_startupMode = 'START_ON_DEMAND') then
			raise e_ConnParamWrong;
		end if;
	end if;

        --
        -- Validate software versions available
        --

	XDP_ADAPTER_CORE_DB.Are_Adapter_Generics_Available (
				p_fe_id => l_FeID,
				p_AdapterType => p_AdapterType,
				p_GenCountActive => l_GenCountActive,
				p_GenCountFuture => l_GenCountFuture);

	if ((l_GenCountActive = 0) and (l_GenCountFuture = 0)) then
 		raise e_NoGenericExists;
	else
	        --Set the adapter_status to pv_statusStopped or pv_statusNotAvailable
		if l_GenCountActive > 0 then
			l_StartStatus := pv_statusStopped;
		else
			l_StartStatus := pv_statusNotAvailable;
			if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
			    FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION, 'XDP_ADAPTER.CREATE_ADAPTER',
					'Adapter is not available');
			end if;
		end if;
	end if;

	XDP_ADAPTER_CORE_DB.CreateNewAdapterChannel(p_FeName, l_ChannelName);
        if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION, 'XDP_ADAPTER.CREATE_ADAPTER',
					'Channel name is: '||l_ChannelName);
        end if;

	-- Fill in the Consumer Name
        if l_ApplicationMode = 'QUEUE' then
		l_AdapterName := p_FeName;
	else
		l_AdapterName := l_ChannelName;
	end if;

        -- Append .log to the log file name if not present already
        l_LogFileName := Add_Log_File_Extension(p_LogFileName);

	XDP_ADAPTER_CORE_DB.LoadNewAdapter(	l_ChannelName,
		 			l_FeID,
		 			p_AdapterType,
		 			l_AdapterName,
		 			p_AdapterDispName,
 					l_StartStatus,
					p_ConcQID,
		 			p_StartupMode,
		 			p_UsageCode,
		 			p_LogLevel,
		 			p_CODFlag,
		 			p_MaxIdleTime,
		 			l_LogFileName,
		 			p_SeqInFE,
		 			p_CmdLineOpts,
                 			p_CmdLineArgs);

exception

when e_DisplayNameNotUnique then
	p_retCode := pv_retAdapterOtherError;
	FND_MESSAGE.CLEAR;
	fnd_message.set_name('FND','UNIQUE-DUPLICATE NAME');
 	p_errbuf := FND_MESSAGE.GET;
	if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   	   FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.CREATE_ADAPTER',
		'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
        end if;
when e_NoGenericExists then
	p_retCode := pv_retAdapterNoGenExists;
	FND_MESSAGE.CLEAR;
	fnd_message.set_name('XDP','XDP_ADAPTER_NO_SW_GEN_EXISTS');
 	p_errbuf := FND_MESSAGE.GET;
        if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	   FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.CREATE_ADAPTER',
		'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
        end if;
when e_AdapterConfigNA then
        p_retCode := pv_retAdapterConfigNA;
        FND_MESSAGE.CLEAR;
        fnd_message.set_name('XDP','XDP_ADAPTER_NOT_CONFIGURABLE');
        fnd_message.set_token('OPERATION', 'Create');
        p_errbuf := FND_MESSAGE.GET;
        if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.CREATE_ADAPTER',
                'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
        end if;
--when e_AsyncParamWrong then
--	p_retCode := pv_retAdapterAsyncParamWrong;
--        FND_MESSAGE.CLEAR;
--        fnd_message.set_name('XDP','XDP_ADAPTER_ASYNC_PARAM_WRONG');
--        p_errbuf := FND_MESSAGE.GET;
--        FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.CREATE_ADAPTER',
--                'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
when e_InboundParamWrong then
	p_retCode := pv_retAdapterInboundParamWrong;
        FND_MESSAGE.CLEAR;
        fnd_message.set_name('XDP','XDP_ADAPTER_INBND_PARAM_WRONG');
        p_errbuf := FND_MESSAGE.GET;
	if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.CREATE_ADAPTER',
                'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
        end if;
when e_ImplParamWrong then
	p_retCode := pv_retAdapterImplParamWrong;
        FND_MESSAGE.CLEAR;
        fnd_message.set_name('XDP','XDP_ADAPTER_IMPL_PARAM_WRONG');
        p_errbuf := FND_MESSAGE.GET;
	if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.CREATE_ADAPTER',
                'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
        end if;
when e_ConnParamWrong then
	p_retCode := pv_retAdapterConnParamWrong;
        FND_MESSAGE.CLEAR;
        fnd_message.set_name('XDP','XDP_ADAPTER_CONN_PARAM_WRONG');
        p_errbuf := FND_MESSAGE.GET;
	if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.CREATE_ADAPTER',
                'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
	end if;
when others then
if SQLCODE <> 0 then
 	p_retCode := SQLCODE;
 	p_errbuf :=  SQLERRM;
else
	p_retCode := pv_retAdapterOtherError;
 	p_errbuf := 'Other non-SQL error';
END IF;
if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.CREATE_ADAPTER',
	'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
end if;
end Create_Adapter;

-- ************* Added - sacsharm - START *****************************

Procedure Update_Adapter(p_ChannelName in varchar2,
			    p_AdapterName in varchar2,
			    p_AdapterDispName in varchar2,
			    p_ConcQID in number,
			    p_StartupMode in varchar2 default 'MANUAL',
			    p_UsageCode in varchar2 default 'NORMAL',
			    p_LogLevel in varchar2 default 'ERROR',
			    p_CODFlag in varchar2 default 'N',
			    p_MaxIdleTime in number default 0,
			    p_LogFileName in varchar2 default NULL,
			    p_SeqInFE in number default null,
			    p_CmdLineOpts in varchar2 default NULL,
                            p_CmdLineArgs in varchar2 default NULL,
			    p_retcode	OUT NOCOPY NUMBER,
			    p_errbuf	OUT NOCOPY VARCHAR2
			)
is
 l_AdapterLocked varchar2(1) := 'N';
 l_CurrentStatus varchar2(30);
 l_ApplicationMode xdp_adapter_types_b.application_mode%TYPE;
 l_AdapterClass xdp_adapter_types_b.adapter_class%TYPE;
 l_ConnReqFlag xdp_adapter_types_b.connection_required_flag%TYPE;
 l_InboundReqFlag xdp_adapter_types_b.inbound_required_flag%TYPE;
 lv_mode VARCHAR2(8);  -- maintenance mode profile

 l_LogFileName xdp_adapter_reg.log_file_name%TYPE;

 e_AdapterConfigNA EXCEPTION;

 l_count number := 0;

BEGIN
	if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'XDP_ADAPTER.UPDATE_ADAPTER',
				'BEGIN:p_ChannelName: '||p_ChannelName);
	end if;
	p_retcode := 0;
	p_errbuf := '';

-- ********** Validate Order Type in High Availability Maintenance Mode

       FND_PROFILE.GET('APPS_MAINTENANCE_MODE', lv_mode);

       IF lv_mode = 'MAINT' THEN
           raise e_AdapterConfigNA;
       END IF;
-- **********

	if p_ChannelName is null then
	    if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 27 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.UPDATE_ADAPTER',
					'Required parameters are not passed');
	    end if;
            raise e_RequiredInputDataNotPassed;
	end if;

	if not XDP_ADAPTER_CORE.VerifyAdapterOperation(p_ChannelName,
					XDP_ADAPTER.pv_opUpdate,
					l_CurrentStatus) then
		raise e_InvalidAdapterState;
	end if;

        --TODO do we really need to take lock, state is already one of the STOPPED
	l_AdapterLocked := XDP_ADAPTER_CORE_DB.ObtainAdapterLock_Verify(p_ChannelName);
	if l_AdapterLocked = 'N' then
		raise e_UnabletoLockAdapter;
	end if;

        --
        -- Validate unique display name
        --
	select count(*) into l_count from xdp_adapter_reg
		where adapter_display_name = p_AdapterDispName and
		channel_name <> p_ChannelName;
	if l_count > 0 then
 		raise e_DisplayNameNotUnique;
	end if;

        select xat.application_mode, xat.adapter_class, xat.connection_required_flag, xat.inbound_required_flag
        into l_ApplicationMode, l_AdapterClass, l_ConnReqFlag, l_InboundReqFlag
        from xdp_adapter_types_b xat, xdp_adapter_reg xar
        where xat.adapter_type = xar.adapter_type
          and xar.channel_name = p_ChannelName;

	--
	-- Validate parameters for non-implemented adapters
	--
	if l_AdapterClass = 'NONE' then
		if (p_LogFileName is not null) or
		   (p_CmdLineOpts is not null) or
                   (p_CmdLineArgs is not null) then
 			raise e_ImplParamWrong;
		end if;
	end if;

	--
	-- Validate parameters for inbound-only adapters
	--
	if (l_InboundReqFlag = 'Y' and l_ApplicationMode = 'NONE') then

		-- Startup Mode is SOD
		if (p_StartupMode = 'START_ON_DEMAND') then
			raise e_InboundParamWrong;
		end if;
	end if;


	--
	-- Validate connection parameters
	--

	-- If no connection required
	if l_ConnReqFlag = 'N' then
		if (p_CODFlag = 'Y') then
			raise e_ConnParamWrong;
		end if;
	-- If connection required
	else
		-- If SOD and COD
		if (p_CODFlag = 'Y' and p_startupMode = 'START_ON_DEMAND') then
			raise e_ConnParamWrong;
		end if;
	end if;

        -- Append .log to the log file name if not present already
        l_LogFileName := Add_Log_File_Extension(p_LogFileName);


	XDP_ADAPTER_CORE_DB.UpdateAdapter(
				p_ChannelName => p_ChannelName,
				p_AdapterName => p_AdapterName,
				p_AdapterDispName => p_AdapterDispName,
				p_SvcInstId => p_ConcQID,
				p_StartupMode => p_StartupMode,
				p_UsageCode => p_UsageCode,
			    	p_LogLevel => p_LogLevel,
				p_CODFlag => p_CODFlag,
				p_MaxIdleTime => p_MaxIdleTime,
			    	p_LogFileName => l_LogFileName,
			    	p_SeqInFE => p_SeqInFE,
				p_CmdLineOpts => p_CmdLineOpts,
				p_CmdLineArgs => p_CmdLineArgs
				);

	if (XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName) = 'N') then
	    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED, 'XDP_ADAPTER.UPDATE_ADAPTER',
			'Could not release the lock, Channel name: '||p_ChannelName);
	    end if;
 	end if;

exception
when e_DisplayNameNotUnique then
if l_AdapterLocked = 'Y' then
	if (XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName) = 'N') then
	    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED, 'XDP_ADAPTER.UPDATE_ADAPTER',
			'Could not release the lock, Channel name: '||p_ChannelName);
	    end if;
 	end if;
end if;
	p_retCode := pv_retAdapterOtherError;
	FND_MESSAGE.CLEAR;
	fnd_message.set_name('FND','UNIQUE-DUPLICATE NAME');
 	p_errbuf := FND_MESSAGE.GET;
	if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 27 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.UPDATE_ADAPTER',
		'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
        end if;
when e_InvalidAdapterState then
	p_retCode := pv_retAdapterInvalidState;
	FND_MESSAGE.CLEAR;
	fnd_message.set_name('XDP','XDP_INVALID_ADAPTER_STATE');
 	p_errbuf := FND_MESSAGE.GET;
	if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 27 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.UPDATE_ADAPTER',
		'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
        end if;
when e_UnabletoLockAdapter then
	p_retCode := pv_retAdapterCannotLock;
	FND_MESSAGE.CLEAR;
	fnd_message.set_name('XDP','XDP_ADAPTER_UNLOCKABLE');
 	p_errbuf := FND_MESSAGE.GET;
	if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 27 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.UPDATE_ADAPTER',
		'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
        end if;
when e_AdapterConfigNA then
        p_retCode := pv_retAdapterConfigNA;
        FND_MESSAGE.CLEAR;
        fnd_message.set_name('XDP','XDP_ADAPTER_NOT_CONFIGURABLE');
        fnd_message.set_token('OPERATION', 'Update');
        p_errbuf := FND_MESSAGE.GET;
	if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 27 Apr 05
            FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.CREATE_ADAPTER',
                'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
        end if;
when e_ImplParamWrong then
	p_retCode := pv_retAdapterImplParamWrong;
        FND_MESSAGE.CLEAR;
        fnd_message.set_name('XDP','XDP_ADAPTER_IMPL_PARAM_WRONG');
        p_errbuf := FND_MESSAGE.GET;
	if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 27 Apr 05
            FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.CREATE_ADAPTER',
                'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
	end if;
when e_InboundParamWrong then
	p_retCode := pv_retAdapterInboundParamWrong;
        FND_MESSAGE.CLEAR;
        fnd_message.set_name('XDP','XDP_ADAPTER_INBND_PARAM_WRONG');
        p_errbuf := FND_MESSAGE.GET;
	if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 27 Apr 05
           FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.CREATE_ADAPTER',
                'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
	end if;
when e_ConnParamWrong then
	p_retCode := pv_retAdapterConnParamWrong;
        FND_MESSAGE.CLEAR;
        fnd_message.set_name('XDP','XDP_ADAPTER_CONN_PARAM_WRONG');
        p_errbuf := FND_MESSAGE.GET;
	if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 27 Apr 05
            FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.CREATE_ADAPTER',
                'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
	end if;
when others then
if l_AdapterLocked = 'Y' then
	if (XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName) = 'N') then
	    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED, 'XDP_ADAPTER.UPDATE_ADAPTER',
			'Could not release the lock, Channel name: '||p_ChannelName);
	    end if;
 	end if;
end if;
if SQLCODE <> 0 then
 	p_retCode := SQLCODE;
 	p_errbuf :=  SQLERRM;
else
	p_retCode := pv_retAdapterOtherError;
 	p_errbuf := 'Other non-SQL error';
END IF;
if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 27 Apr 05
    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.UPDATE_ADAPTER',
	'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
end if;
END Update_Adapter;

Procedure Delete_Adapter(p_ChannelName in varchar2,
		   	 p_retcode OUT NOCOPY NUMBER,
			 p_errbuf OUT NOCOPY VARCHAR2
			)
is

 l_AdapterLocked varchar2(1) := 'N';
 l_CurrentStatus varchar2(30);

 lv_mode VARCHAR2(8);  -- maintenance mode profile

 e_AdapterConfigNA EXCEPTION;

begin
	if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'XDP_ADAPTER.DELETE_ADAPTER',
				'BEGIN:p_ChannelName: '||p_ChannelName);
	end if;
	p_retcode := 0;
	p_errbuf := '';

-- ********** Validate Order Type in High Availability Maintenance Mode

       FND_PROFILE.GET('APPS_MAINTENANCE_MODE', lv_mode);

       IF lv_mode = 'MAINT' THEN
           raise e_AdapterConfigNA;
       END IF;
-- **********

	if p_ChannelName is null then
	    if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 27 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.DELETE_ADAPTER',
					'Required parameters are not passed');
            end if;
 		raise e_RequiredInputDataNotPassed;
	end if;

	if not XDP_ADAPTER_CORE.VerifyAdapterOperation(p_ChannelName,
					XDP_ADAPTER.pv_opDelete,
					l_CurrentStatus) then
		raise e_InvalidAdapterState;
	end if;

        --TODO do we really need to take lock, state is already one of the STOPPED
	l_AdapterLocked := XDP_ADAPTER_CORE_DB.ObtainAdapterLock_Verify(p_ChannelName);
	if l_AdapterLocked = 'N' then
		raise e_UnabletoLockAdapter;
	end if;

	XDP_ADAPTER_CORE_DB.Delete_Adapter (p_channel_name => p_ChannelName);

	if XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName) = 'N' then
	    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED, 'XDP_ADAPTER.DELETE_ADAPTER',
			'Could not release the lock, Channel name: '||p_ChannelName);
	    end if;
	end if;

exception
when e_InvalidAdapterState then
	p_retCode := pv_retAdapterInvalidState;
	FND_MESSAGE.CLEAR;
	fnd_message.set_name('XDP','XDP_INVALID_ADAPTER_STATE');
 	p_errbuf := FND_MESSAGE.GET;
	if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 27 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.DELETE_ADAPTER',
		'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
	end if;
when e_UnabletoLockAdapter then
	p_retCode := pv_retAdapterCannotLock;
	FND_MESSAGE.CLEAR;
	fnd_message.set_name('XDP','XDP_ADAPTER_UNLOCKABLE');
 	p_errbuf := FND_MESSAGE.GET;
	if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 27 Apr 05
    	    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.DELETE_ADAPTER',
		'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
	end if;
when e_AdapterConfigNA then
        p_retCode := pv_retAdapterConfigNA;
        FND_MESSAGE.CLEAR;
        fnd_message.set_name('XDP','XDP_ADAPTER_NOT_CONFIGURABLE');
        fnd_message.set_token('OPERATION', 'Delete');
        p_errbuf := FND_MESSAGE.GET;
	if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 27 Apr 05
           FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.CREATE_ADAPTER',
                'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
	end if;
when others then
if l_AdapterLocked  = 'Y' then
	if (XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName) = 'N') then
	   if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED, 'XDP_ADAPTER.DELETE_ADAPTER',
			'Could not release the lock, Channel name: '||p_ChannelName);
	   end if;
 	end if;
end if;
if SQLCODE <> 0 then
 	p_retCode := SQLCODE;
 	p_errbuf :=  SQLERRM;
else
	p_retCode := pv_retAdapterOtherError;
 	p_errbuf := 'Other non-SQL error';
END IF;
if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 27 Apr 05
    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.DELETE_ADAPTER',
	'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
end if;
end Delete_Adapter;

Procedure Delete_All_For_FE (p_FeName in varchar2,
		   	 	  p_retcode OUT NOCOPY NUMBER,
			 	  p_errbuf OUT NOCOPY VARCHAR2)
is
 l_FeID number := -1;
 l_Flag boolean := FALSE;
 e_FEAdapterRunning  EXCEPTION;
begin
	if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'XDP_ADAPTER.DELETE_ALL_FOR_FE',
				'BEGIN:p_FeName: '||p_FeName);
	end if;
	p_retcode := 0;
	p_errbuf := '';

	l_FeID := XDP_ADAPTER_CORE_DB.Get_Fe_Id_For_Name (p_FeName);

	l_Flag := XDP_ADAPTER_CORE_DB.Is_FE_Adapter_Running (p_fe_id => l_FeID);
	if (l_Flag) then
	    if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.DELETE_ALL_FOR_FE',
				'Some adapters are running for the FE: '||p_FeName);
	    end if;
            raise e_FEAdapterRunning;
	END IF;

	XDP_ADAPTER_CORE_DB.Delete_Adapters_For_FE (p_fe_id => l_FeID);

exception

when e_FEAdapterRunning then
	p_retcode := pv_retFEAdapterRunning;
 	FND_MESSAGE.CLEAR;
	fnd_message.set_name('XDP','XDP_FE_RUNNING');
 	p_errbuf := FND_MESSAGE.GET;
	if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.DELETE_ALL_FOR_FE',
		'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
	end if;

when others then
if SQLCODE <> 0 then
 	p_retCode := SQLCODE;
 	p_errbuf :=  SQLERRM;
else
	p_retCode := pv_retAdapterOtherError;
 	p_errbuf := 'Other non-SQL error';
END IF;
if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then  --Fix Bug: 4256771, dputhiye, 28 Apr 05
    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.DELETE_ALL_FOR_FE',
	'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
end if;
end Delete_All_For_FE;

PROCEDURE Generic_Operation (p_ChannelName in varchar2,
				p_OperationName in varchar2,
				p_OperationParam in varchar2 default null,
				p_retcode	OUT NOCOPY NUMBER,
				p_errbuf	OUT NOCOPY VARCHAR2
				)
is
 l_CPID number;
 l_ProcessID number;
 l_CmdString varchar2(2000);
begin
	if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'XDP_ADAPTER.GENERIC_OPERATION',
				'BEGIN:p_ChannelName: '||p_ChannelName);
	end if;
	p_retcode := 0;
	p_errbuf := '';

        validate_operation(p_ChannelName => p_ChannelName,
                             p_Operation => XDP_ADAPTER.pv_opGeneric,
                             p_CPID => l_CPID,
                             p_ProcessID => l_ProcessID,
                             p_retcode => p_retcode,
                             p_errbuf => p_errbuf);

        if p_retcode <> 0 then
            return;
        END IF;

	if (XDP_ADAPTER_CORE_DB.Is_Adapter_Implemented (p_ChannelName)) then

                l_CmdString := p_ChannelName || pv_SMParamDelimiter ||
                               p_OperationName || pv_SMParamDelimiter ||
                               p_OperationParam || pv_SMParamDelimiter;

		XDP_CONTROLLER_CORE.GenericOperationAdapter(l_CPID, l_CmdString);
	end if;

exception

when others then
if SQLCODE <> 0 then
 	p_retCode := SQLCODE;
 	p_errbuf :=  SQLERRM;
else
	p_retCode := pv_retAdapterOtherError;
 	p_errbuf := 'Other non-SQL error';
END IF;
if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.GENERIC_OPERATION',
	'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
end if;
END Generic_Operation;

-- ************* Added - sacsharm - END *****************************

Procedure Create_Admin_Request (p_ChannelName in varchar2,
				 p_RequestType in varchar2,
				 p_RequestDate in date default sysdate,
				 p_RequestedBy in varchar2 default null,
				 p_Freq in number default null,
				 p_RequestID OUT NOCOPY number,
				 p_JobID OUT NOCOPY number,
				 p_retcode	OUT NOCOPY NUMBER,
				 p_errbuf	OUT NOCOPY VARCHAR2
				)
is
 e_InvalidRequestDate  EXCEPTION;

begin
	if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'XDP_ADAPTER.CREATE_ADMIN_REQUEST',
				'BEGIN:p_ChannelName: '||p_ChannelName);
	end if;
	p_retcode := 0;
	p_errbuf := '';

	if p_ChannelName is null then
            if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_ERROR,
					'XDP_ADAPTER.CREATE_ADMIN_REQUEST',
					'Required parameters are not passed');
	    end if;
 	    raise e_RequiredInputDataNotPassed;
	end if;

	if p_RequestDate < sysdate then
	    if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_ERROR,
					'XDP_ADAPTER.CREATE_ADMIN_REQUEST',
					'Request date is less than the sysdate');
	    end if;
            raise e_InvalidRequestDate;
	end if;

	XDP_ADAPTER_CORE_DB.SubmitAdapterAdminReq(
			p_ChannelName => p_ChannelName,
			p_RequestType => p_RequestType,
			p_RequestDate => p_RequestDate,
			p_RequestedBy => p_RequestedBy,
			p_Freq => p_Freq,
			p_RequestID => p_RequestID,
			p_JobID => p_JobID);

exception
when e_InvalidRequestDate then
	p_retcode := pv_retAdapterInvalidReqDate;
 	FND_MESSAGE.CLEAR;
	fnd_message.set_name('XDP','XDP_SCHED_REQ_FUTURE');
 	p_errbuf := FND_MESSAGE.GET;
	if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.CREATE_ADMIN_REQUEST',
		'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
	end if;
when others then
if SQLCODE <> 0 then
 	p_retCode := SQLCODE;
 	p_errbuf :=  SQLERRM;
else
	p_retCode := pv_retAdapterOtherError;
 	p_errbuf := 'Other non-SQL error';
END IF;
if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.CREATE_ADMIN_REQUEST',
	'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
end if;
end Create_Admin_Request;

Procedure Update_Admin_Request (p_RequestID in number,
				p_RequestDate in date default sysdate,
				p_RequestedBy in varchar2 default null,
				p_Freq in number default null,
				p_retcode	OUT NOCOPY NUMBER,
				p_errbuf	OUT NOCOPY VARCHAR2
				)
is

 e_InvalidRequestDate  EXCEPTION;

begin
	if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'XDP_ADAPTER.UPDATE_ADMIN_REQUEST',
				'BEGIN:p_RequestID: '||p_RequestID);
	end if;
	p_retcode := 0;
	p_errbuf := '';

	if p_RequestID is null then
	    if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_ERROR,
					'XDP_ADAPTER.UPDATE_ADMIN_REQUEST',
					'Required parameters are not passed');
	    end if;
            raise e_RequiredInputDataNotPassed;
	end if;

	if p_RequestDate < sysdate then
	    if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_ERROR,
					'XDP_ADAPTER.CREATE_ADMIN_REQUEST',
					'Request date is less than the sysdate');
	    end if;
 	    raise e_InvalidRequestDate;
	end if;

	XDP_ADAPTER_CORE_DB.UpdateAdapterAdminReq(
		p_RequestID => Update_Admin_Request.p_RequestID,
		p_RequestDate => Update_Admin_Request.p_RequestDate,
		p_RequestedBy => Update_Admin_Request.p_RequestedBy,
		p_Freq => Update_Admin_Request.p_Freq);

exception
when e_InvalidRequestDate then
	p_retcode := pv_retAdapterInvalidReqDate;
 	FND_MESSAGE.CLEAR;
	fnd_message.set_name('XDP','XDP_SCHED_REQ_FUTURE');
 	p_errbuf := FND_MESSAGE.GET;
	if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.UPDATE_ADMIN_REQUEST',
		'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
	end if;

when others then
if SQLCODE <> 0 then
 	p_retCode := SQLCODE;
 	p_errbuf :=  SQLERRM;
else
	p_retCode := pv_retAdapterOtherError;
 	p_errbuf := 'Other non-SQL error';
END IF;
if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.UPDATE_ADMIN_REQUEST',
	'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
end if;
end Update_Admin_Request;

Procedure Delete_Admin_Request (p_RequestID in number,
		   	 	 p_retcode OUT NOCOPY NUMBER,
			 	 p_errbuf OUT NOCOPY VARCHAR2)
is
 l_dummy varchar2(80);
 l_dummynum number;
 l_dummydate date;
 l_jobID number;
begin
	if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'XDP_ADAPTER.DELETE_ADMIN_REQUEST',
				'BEGIN:p_RequestID: '||p_RequestID);
	end if;
	p_retcode := 0;
	p_errbuf := '';

	if p_RequestID is null then
	    if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_ERROR,
					'XDP_ADAPTER.DELETE_ADMIN_REQUEST',
					'Required parameters are not passed');
	    end if;
 	    raise e_RequiredInputDataNotPassed;
	end if;

	XDP_ADAPTER_CORE_DB.RemoveAdapterAdminReq(
		p_RequestID => Delete_Admin_Request.p_RequestID);

exception
when others then
if SQLCODE <> 0 then
 	p_retCode := SQLCODE;
 	p_errbuf :=  SQLERRM;
else
	p_retCode := pv_retAdapterOtherError;
 	p_errbuf := 'Other non-SQL error';
END IF;
if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.DELETE_ADMIN_REQUEST',
	'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
end if;
end Delete_Admin_Request;

-- End of Adapter Admin Requests Procedures

Procedure Start_Adapter(p_ChannelName in varchar2,
	   	 	p_retcode OUT NOCOPY NUMBER,
		 	p_errbuf OUT NOCOPY VARCHAR2)
is

 l_CmdOptions varchar2(2000);
 l_CmdArgs varchar2(2000);
 l_ApplChannelName varchar2(40);
 l_ControlChannelName varchar2(40);
 l_ApplMode varchar2(40);
 l_FeName varchar2(40);
 l_AdapterName varchar2(40);
 l_AdapterClass varchar2(240);
 l_InboundChannelName varchar2(80);
 l_ControllerFlag varchar2(10);
 l_ConcQID number;
 l_CPID number;

 l_LogFileName varchar2(240);
 l_AdapterLocked varchar2(1) := 'N';

 l_SMParamString varchar2(2000);
 l_Flag boolean := FALSE;
 l_FeID number := -1;
 l_CurrentStatus varchar2(30);

 e_MaxAdaptersReached  EXCEPTION;
begin
	if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'XDP_ADAPTER.START_ADAPTER',
				'BEGIN:p_ChannelName: '||p_ChannelName);
	end if;
	p_retcode := 0;
	p_errbuf := '';

	if p_ChannelName is null then
            if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.START_ADAPTER',
					'Required parameters are not passed');
	    end if;
 	    raise e_RequiredInputDataNotPassed;
	end if;

	if not XDP_ADAPTER_CORE.VerifyAdapterOperation(p_ChannelName,
					XDP_ADAPTER.pv_opStartup,
					l_CurrentStatus) then
		raise e_InvalidAdapterState;
	end if;

        --TODO do we really need to take lock, state is already one of the STOPPED
	l_AdapterLocked := XDP_ADAPTER_CORE_DB.ObtainAdapterLock_Verify(p_ChannelName);
	if l_AdapterLocked = 'N' then
		raise e_UnabletoLockAdapter;
	end if;

	XDP_ADAPTER_CORE_DB.FetchAdapterStartupInfo(
				p_ChannelName,
				l_CmdOptions,
				l_CmdArgs,
				l_ControlChannelName,
				l_ApplChannelName,
				l_ApplMode,
				l_FeName,
				l_AdapterClass,
				l_AdapterName,
				l_ConcQID,
				l_InboundChannelName,
				l_LogFileName);

	l_FeID := XDP_ADAPTER_CORE_DB.Get_Fe_Id_For_Name (l_FeName);

	l_Flag := XDP_ADAPTER_CORE_DB.Is_Max_Connection_Reached (l_FeID);
	if (l_Flag = FALSE) then
		if XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName) = 'N' then
		   if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
			FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED, 'XDP_ADAPTER.START_ADAPTER',
				'Could not release the lock, Channel name: '||p_ChannelName);
		   end if;
		end if;

	 	raise e_MaxAdaptersReached;
	end if;

	-- Construct the Adapter Launch string for the Controller
	-- The command format is as follows
-- jre <-D Options> <Log File Name> <Adapter Class Name> <Control Channel Name> <Arguments>
-- The Arguements to the Adapter are as follows:
-- <FE Name> <Adapter Name> <Control Channel Name> <Application Mode>
-- <Application Channel Name> <Inbound Channel Name> <User-defined args>

	l_SMParamString := 	l_CmdOptions || pv_SMParamDelimiter ||
				l_LogFileName || pv_SMParamDelimiter ||
				l_AdapterClass || pv_SMParamDelimiter ||
				l_ControlChannelName || pv_SMParamDelimiter ||
				l_FeName || pv_SMParamSpace ||
				l_AdapterName || pv_SMParamSpace ||
				l_ControlChannelName || pv_SMParamSpace ||
				l_ApplMode || pv_SMParamSpace ||
				l_ApplChannelName || pv_SMParamSpace ||
				l_InboundChannelName || pv_SMParamSpace ||
				l_CmdArgs || pv_SMParamDelimiter;

	XDP_CONTROLLER_CORE.VerifyControllerStatus(l_ConcQID, l_CPID, l_ControllerFlag);
	if l_ControllerFlag = 'N' then
		if XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName) = 'N' then
		   if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
			FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED, 'XDP_ADAPTER.START_ADAPTER',
				'Could not release the lock, Channel name: '||p_ChannelName);
		   end if;
		end if;

		raise e_ControllerNotRunning;
	end if;

	if (XDP_ADAPTER_CORE_DB.Is_Adapter_Implemented (p_ChannelName)) then

		XDP_ADAPTER_CORE_DB.Update_Adapter_Status(
			p_ChannelName => p_ChannelName,
			p_Status => pv_statusStarting);

		XDP_ADAPTER_CORE_PIPE.CleanupPipe(p_ChannelName => p_ChannelName);
		XDP_CONTROLLER_CORE.LaunchAdapter(l_CPID, l_SMParamString);

		--dbms_output.put_line(substr(l_SMParamString, 1,255));
	else
		XDP_ADAPTER_CORE_DB.Update_Adapter_Status(
			p_ChannelName => p_ChannelName,
			p_Status => pv_statusRunning);

		XDPCORE_FA.HandOverChannel (ChannelName => p_ChannelName,
                           	    FeID => 0,
                           	    ChannelUsageCode => NULL,
                           	    Caller => 'ADMIN',
                           	    ErrCode => p_retcode,
                           	    ErrStr => p_errbuf);
	end if;

	if (XDP_ADAPTER.pv_callerContext = XDP_ADAPTER.pv_CallerContextUser) then

		-- Reset start error count to 0 for Automatic adapters

		if (XDP_ADAPTER_CORE_DB.Is_Adapter_Automatic(p_ChannelName)) then

			XDP_ERRORS_PKG.UPDATE_ERROR_COUNT (
				p_object_type => XDP_ADAPTER.pv_errorObjectTypeAdapter,
				p_object_key => p_ChannelName);
		END IF;
	END IF;

	if XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName) = 'N' then
	    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED, 'XDP_ADAPTER.START_ADAPTER',
			'Could not release the lock, Channel name: '||p_ChannelName);
	    end if;
	end if;

exception
when e_MaxAdaptersReached then
	p_retcode := pv_retAdapterMaxNumReached;
 	FND_MESSAGE.CLEAR;
	fnd_message.set_name('XDP','XDP_MAX_NUM_CONN');
 	p_errbuf := FND_MESSAGE.GET;
	if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
   	    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.START_ADAPTER',
		'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
        end if;
when e_InvalidAdapterState then
	p_retCode := pv_retAdapterInvalidState;
	FND_MESSAGE.CLEAR;
	fnd_message.set_name('XDP','XDP_INVALID_ADAPTER_STATE');
 	p_errbuf := FND_MESSAGE.GET;
	if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
   	    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.START_ADAPTER',
		'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
	end if;
when e_UnabletoLockAdapter then
	p_retCode := pv_retAdapterCannotLock;
	FND_MESSAGE.CLEAR;
	fnd_message.set_name('XDP','XDP_ADAPTER_UNLOCKABLE');
 	p_errbuf := FND_MESSAGE.GET;
	if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.START_ADAPTER',
		'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
	end if;
when e_ControllerNotRunning then
	p_retCode := pv_retAdapterCtrlNotRunning;
	FND_MESSAGE.CLEAR;
	fnd_message.set_name('XDP','XDP_CONTROLLER_NOT_RUNNING');
 	p_errbuf := FND_MESSAGE.GET;
	if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
  	   FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.START_ADAPTER',
		'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
	end if;
when others then
if l_AdapterLocked = 'Y' then
	if (XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName) = 'N') then
	   if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED, 'XDP_ADAPTER.START_ADAPTER',
			'Could not release the lock, Channel name: '||p_ChannelName);
	   end if;
 	end if;
end if;
if SQLCODE <> 0 then
 	p_retCode := SQLCODE;
 	p_errbuf :=  SQLERRM;
else
	p_retCode := pv_retAdapterOtherError;
 	p_errbuf := 'Other non-SQL error';
END IF;
if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.START_ADAPTER',
	'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
end if;
End Start_Adapter;

Procedure Stop_Adapter(p_ChannelName in varchar2,
	   	 	p_retcode OUT NOCOPY NUMBER,
		 	p_errbuf OUT NOCOPY VARCHAR2)
is
 l_JobID number := 0;
 l_RequestID number := 0;

 l_CPID number;
 l_ProcessID number;
 l_CmdString varchar2(2000);
begin
	if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'XDP_ADAPTER.STOP_ADAPTER',
				'BEGIN:p_ChannelName: '||p_ChannelName);
	end if;
	p_retcode := 0;
	p_errbuf := '';

        validate_operation(p_ChannelName => p_ChannelName,
                             p_Operation => XDP_ADAPTER.pv_opStop,
                             p_CPID => l_CPID,
                             p_ProcessID => l_ProcessID,
                             p_retcode => p_retcode,
                             p_errbuf => p_errbuf);

        if p_retcode = XDP_ADAPTER.pv_retAdapterCannotLock then

		-- Stop operation is different, if we cannot lock
		-- we submit adapter admin request

		-- Submit a adapter admin request
		-- Commit should be done by the Caller
		l_JobID := XDP_ADAPTER_CORE_DB.DoesSystemReqAlreadyExist(
				p_ChannelName => p_ChannelName,
                                p_RequestType => XDP_ADAPTER.pv_opStop,
                                p_RequestDate => sysdate);
                if (l_JobID = 0) then
			XDP_ADAPTER_CORE_DB.SubmitAdapterAdminReq (
				p_ChannelName => p_ChannelName,
				p_RequestType => XDP_ADAPTER.pv_opStop,
				p_RequestedBy => XDP_ADAPTER.pv_adminReqBySystem,
				p_RequestID => l_RequestID,
				p_JobID => l_JobID);
		end if;
		raise e_UnabletoLockAdapter;

        elsif p_retcode <> 0 then
            return;
	end if;

	if (XDP_ADAPTER_CORE_DB.Is_Adapter_Implemented (p_ChannelName)) then

		XDP_ADAPTER_CORE_DB.Update_Adapter_Status(
			p_ChannelName => p_ChannelName,
			p_Status => pv_statusStopping);

		l_CmdString := p_ChannelName || pv_SMParamDelimiter;

		if (XDP_ADAPTER_CORE_DB.Is_Adapter_Automatic(p_ChannelName)) then
	  		if (XDP_ADAPTER.pv_callerContext = XDP_ADAPTER.pv_CallerContextUser) then
				l_CmdString := l_CmdString ||
						XDP_ADAPTER.pv_CallerContextUser ||
						pv_SMParamDelimiter;
                        else
				l_CmdString := l_CmdString ||
						XDP_ADAPTER.pv_CallerContextAdmin ||
						pv_SMParamDelimiter;
			END IF;
                END IF;

		XDP_CONTROLLER_CORE.StopAdapter(l_CPID, l_CmdString);

	else
		XDP_ADAPTER_CORE_DB.Update_Adapter_Status(
			p_ChannelName => p_ChannelName,
			p_Status => pv_statusStopped);

		-- Deactivate the automatic adapter in case user stops it.
  		if (XDP_ADAPTER.pv_callerContext = XDP_ADAPTER.pv_CallerContextUser) then

			if (XDP_ADAPTER_CORE_DB.Is_Adapter_Automatic(p_ChannelName)) then

				XDP_ADAPTER_CORE_DB.Update_Adapter_Status(
					p_ChannelName => p_ChannelName,
					p_Status => pv_statusDeactivated);
			END IF;
		END IF;

	end if;

	if XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName) = 'N' then
	   if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED, 'XDP_ADAPTER.STOP_ADAPTER',
			'Could not release the lock, Channel name: '||p_ChannelName);
	   end if;
	end if;

exception

when e_UnabletoLockAdapter then
        p_retCode := pv_retAdapterCannotLockReqSub;
        FND_MESSAGE.CLEAR;
        fnd_message.set_name('XDP','XDP_ADAPTER_UNLOCKABLE_REQ_SUB');
        fnd_message.set_token('JOB_ID', l_JobID);
        p_errbuf := FND_MESSAGE.GET;
	if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
            FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.STOP_ADAPTER',
                'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
	end if;
when others then
if (XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName) = 'N') then
    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
	FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED, 'XDP_ADAPTER.STOP_ADAPTER',
		'Could not release the lock, Channel name: '||p_ChannelName);
    end if;
end if;
if SQLCODE <> 0 then
 	p_retCode := SQLCODE;
 	p_errbuf :=  SQLERRM;
else
	p_retCode := pv_retAdapterOtherError;
 	p_errbuf := 'Other non-SQL error';
END IF;
if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.STOP_ADAPTER',
	'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
end if;
end Stop_Adapter;

Procedure Suspend_Adapter(p_ChannelName in varchar2,
	   	 	p_retcode OUT NOCOPY NUMBER,
		 	p_errbuf OUT NOCOPY VARCHAR2)
is

 l_CPID number;
 l_ProcessID number;
 l_CmdString varchar2(2000);
begin
	if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'XDP_ADAPTER.SUSPEND_ADAPTER',
				'BEGIN:p_ChannelName: '||p_ChannelName);
	end if;
	p_retcode := 0;
	p_errbuf := '';

        validate_operation(p_ChannelName => p_ChannelName,
                             p_Operation => XDP_ADAPTER.pv_opSuspend,
                             p_CPID => l_CPID,
                             p_ProcessID => l_ProcessID,
                             p_retcode => p_retcode,
                             p_errbuf => p_errbuf);

        if p_retcode <> 0 then
            return;
        END IF;

	if (XDP_ADAPTER_CORE_DB.Is_Adapter_Implemented (p_ChannelName)) then

		XDP_ADAPTER_CORE_DB.Update_Adapter_Status(
			p_ChannelName => p_ChannelName,
			p_Status => pv_statusSuspending);

		l_CmdString := p_ChannelName || pv_SMParamDelimiter;

		XDP_CONTROLLER_CORE.SuspendAdapter(l_CPID, l_CmdString);

	else
		XDP_ADAPTER_CORE_DB.Update_Adapter_Status(
			p_ChannelName => p_ChannelName,
			p_Status => pv_statusSuspended);
	end if;

	if XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName) = 'N' then
	    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED, 'XDP_ADAPTER.SUSPEND_ADAPTER',
			'Could not release the lock, Channel name: '||p_ChannelName);
	   end if;
	end if;

exception

when others then
if (XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName) = 'N') then
    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
	FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED, 'XDP_ADAPTER.SUSPEND_ADAPTER',
		'Could not release the lock, Channel name: '||p_ChannelName);
    end if;
end if;
if SQLCODE <> 0 then
 	p_retCode := SQLCODE;
 	p_errbuf :=  SQLERRM;
else
	p_retCode := pv_retAdapterOtherError;
 	p_errbuf := 'Other non-SQL error';
END IF;
if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.SUSPEND_ADAPTER',
	'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
end if;
end Suspend_Adapter;

Procedure Resume_Adapter(p_ChannelName in varchar2,
	   	 	p_retcode OUT NOCOPY NUMBER,
		 	p_errbuf OUT NOCOPY VARCHAR2)
is

 l_CPID number;
 l_ProcessID number;
 l_CmdString varchar2(2000);
begin
	if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'XDP_ADAPTER.RESUME_ADAPTER',
				'BEGIN:p_ChannelName: '||p_ChannelName);
	end if;
	p_retcode := 0;
	p_errbuf := '';

        validate_operation(p_ChannelName => p_ChannelName,
                             p_Operation => XDP_ADAPTER.pv_opResume,
                             p_CPID => l_CPID,
                             p_ProcessID => l_ProcessID,
                             p_retcode => p_retcode,
                             p_errbuf => p_errbuf);

        if p_retcode <> 0 then
            return;
        END IF;

	if (XDP_ADAPTER_CORE_DB.Is_Adapter_Implemented (p_ChannelName)) then

		XDP_ADAPTER_CORE_DB.Update_Adapter_Status(
			p_ChannelName => p_ChannelName,
			p_Status => pv_statusResuming);

		l_CmdString := p_ChannelName || pv_SMParamDelimiter;

		XDP_CONTROLLER_CORE.ResumeAdapter(l_CPID, l_CmdString);

                --HandOverChannel needs to be done by Controller

	else
		XDP_ADAPTER_CORE_DB.Update_Adapter_Status(
			p_ChannelName => p_ChannelName,
			p_Status => pv_statusRunning);

		XDPCORE_FA.HandOverChannel (ChannelName => p_ChannelName,
                       	    FeID => 0,
                       	    ChannelUsageCode => NULL,
                       	    Caller => 'ADMIN',
                       	    ErrCode => p_retcode,
                       	    ErrStr => p_errbuf);
	end if;

	if XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName) = 'N' then
	    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED, 'XDP_ADAPTER.RESUME_ADAPTER',
			'Could not release the lock, Channel name: '||p_ChannelName);
	    end if;
	end if;

exception

when others then
if (XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName) = 'N') then
    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
	FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED, 'XDP_ADAPTER.RESUME_ADAPTER',
		'Could not release the lock, Channel name: '||p_ChannelName);
    end if;
end if;
if SQLCODE <> 0 then
 	p_retCode := SQLCODE;
 	p_errbuf :=  SQLERRM;
else
	p_retCode := pv_retAdapterOtherError;
 	p_errbuf := 'Other non-SQL error';
END IF;
if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.RESUME_ADAPTER',
	'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
end if;
end Resume_Adapter;


Procedure Connect_Adapter(p_ChannelName in varchar2,
	   	 	p_retcode OUT NOCOPY NUMBER,
		 	p_errbuf OUT NOCOPY VARCHAR2)
is
 l_CPID number;
 l_ProcessID number;
 l_CmdString varchar2(2000);

begin
	if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'XDP_ADAPTER.CONNECT_ADAPTER',
				'BEGIN:p_ChannelName: '||p_ChannelName);
	end if;
	p_retcode := 0;
	p_errbuf := '';

        validate_operation(p_ChannelName => p_ChannelName,
                             p_Operation => XDP_ADAPTER.pv_opConnect,
                             p_CPID => l_CPID,
                             p_ProcessID => l_ProcessID,
                             p_retcode => p_retcode,
                             p_errbuf => p_errbuf);

        if p_retcode <> 0 then
            return;
        END IF;

	if (XDP_ADAPTER_CORE_DB.Is_Adapter_Implemented (p_ChannelName)) then

		XDP_ADAPTER_CORE_DB.Update_Adapter_Status(
			p_ChannelName => p_ChannelName,
			p_Status => pv_statusConnecting);

		l_CmdString := p_ChannelName || pv_SMParamDelimiter;

		XDP_CONTROLLER_CORE.ConnectAdapter(l_CPID, l_CmdString);

                --HandOverChannel needs to be done by Controller

	else
		XDP_ADAPTER_CORE_DB.Update_Adapter_Status(
			p_ChannelName => p_ChannelName,
			p_Status => pv_statusRunning);

		XDPCORE_FA.HandOverChannel (ChannelName => p_ChannelName,
                       	    FeID => 0,
                       	    ChannelUsageCode => NULL,
                       	    Caller => 'ADMIN',
                       	    ErrCode => p_retcode,
                       	    ErrStr => p_errbuf);
	end if;

	if XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName) = 'N' then
	    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED, 'XDP_ADAPTER.CONNECT_ADAPTER',
			'Could not release the lock, Channel name: '||p_ChannelName);
	    end if;
	end if;

exception

when others then
if (XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName) = 'N') then
    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
	FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED, 'XDP_ADAPTER.CONNECT_ADAPTER',
		'Could not release the lock, Channel name: '||p_ChannelName);
    end if;
end if;
if SQLCODE <> 0 then
 	p_retCode := SQLCODE;
 	p_errbuf :=  SQLERRM;
else
	p_retCode := pv_retAdapterOtherError;
 	p_errbuf := 'Other non-SQL error';
END IF;
if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.CONNECT_ADAPTER',
	'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
end if;
end Connect_Adapter;


Procedure Disconnect_Adapter(p_ChannelName in varchar2,
	   	 	p_retcode OUT NOCOPY NUMBER,
		 	p_errbuf OUT NOCOPY VARCHAR2)
is
 l_CPID number;
 l_ProcessID number;
 l_CmdString varchar2(2000);
begin
	if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'XDP_ADAPTER.DISCONNECT_ADAPTER',
				'BEGIN:p_ChannelName: '||p_ChannelName);
	end if;
	p_retcode := 0;
	p_errbuf := '';

        validate_operation(p_ChannelName => p_ChannelName,
                             p_Operation => XDP_ADAPTER.pv_opDisconnect,
                             p_CPID => l_CPID,
                             p_ProcessID => l_ProcessID,
                             p_retcode => p_retcode,
                             p_errbuf => p_errbuf);

        if p_retcode <> 0 then
            return;
        END IF;

	if (XDP_ADAPTER_CORE_DB.Is_Adapter_Implemented (p_ChannelName)) then

		XDP_ADAPTER_CORE_DB.Update_Adapter_Status(
			p_ChannelName => p_ChannelName,
			p_Status => pv_statusDisconnecting);

		l_CmdString := p_ChannelName || pv_SMParamDelimiter;

		XDP_CONTROLLER_CORE.DisconnectAdapter(l_CPID, l_CmdString);

	else
		XDP_ADAPTER_CORE_DB.Update_Adapter_Status(
			p_ChannelName => p_ChannelName,
			p_Status => pv_statusDisconnected);
	end if;

	if XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName) = 'N' then
	    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED, 'XDP_ADAPTER.DISCONNECT_ADAPTER',
			'Could not release the lock, Channel name: '||p_ChannelName);
	    end if;
	end if;

exception

when others then
if (XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName) = 'N') then
    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
	FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED, 'XDP_ADAPTER.DISCONNECT_ADAPTER',
		'Could not release the lock, Channel name: '||p_ChannelName);
    end if;
end if;
if SQLCODE <> 0 then
 	p_retCode := SQLCODE;
 	p_errbuf :=  SQLERRM;
else
	p_retCode := pv_retAdapterOtherError;
 	p_errbuf := 'Other non-SQL error';
END IF;
if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.DISCONNECT_ADAPTER',
	'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
end if;
end Disconnect_Adapter;


Procedure Terminate_Adapter(p_ChannelName in varchar2,
	   	 	p_retcode OUT NOCOPY NUMBER,
		 	p_errbuf OUT NOCOPY VARCHAR2)
is

 l_CPID number;
 l_CmdString varchar2(2000);
 l_ProcessID number;
begin
	if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'XDP_ADAPTER.TERMINATE_ADAPTER',
				'BEGIN:p_ChannelName: '||p_ChannelName);
	end if;
	p_retcode := 0;
	p_errbuf := '';

        validate_operation(p_ChannelName => p_ChannelName,
                             p_Operation => XDP_ADAPTER.pv_opTerminate,
                             p_CPID => l_CPID,
                             p_ProcessID => l_ProcessID,
                             p_retcode => p_retcode,
                             p_errbuf => p_errbuf);

        if p_retcode <> 0 then
            return;
        END IF;

	if (XDP_ADAPTER_CORE_DB.Is_Adapter_Implemented (p_ChannelName)) then

		XDP_ADAPTER_CORE_DB.Update_Adapter_Status(
				p_ChannelName => p_ChannelName,
				p_Status => pv_statusTerminating);

		l_CmdString := p_ChannelName || pv_SMParamDelimiter ||
				l_ProcessID || pv_SMParamDelimiter;

		XDP_CONTROLLER_CORE.TerminateAdapter(l_CPID, l_CmdString);
	else
		XDP_ADAPTER_CORE_DB.Update_Adapter_Status(
			p_ChannelName => p_ChannelName,
			p_Status => pv_statusTerminated,
			p_ErrorMsg => 'XDP_ADAPTER_TERMINATED');
	end if;

	if XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName) = 'N' then
	   if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED, 'XDP_ADAPTER.TERMINATE_ADAPTER',
			'Could not release the lock, Channel name: '||p_ChannelName);
	   end if;
	end if;

exception

when others then
if (XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName) = 'N') then
    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
	FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED, 'XDP_ADAPTER.TERMINATE_ADAPTER',
		'Could not release the lock, Channel name: '||p_ChannelName);
    end if;
end if;
if SQLCODE <> 0 then
 	p_retCode := SQLCODE;
 	p_errbuf :=  SQLERRM;
else
	p_retCode := pv_retAdapterOtherError;
 	p_errbuf := 'Other non-SQL error';
END IF;
if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.TERMINATE_ADAPTER',
	'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
end if;
end Terminate_Adapter;

-- Return the Exit code of the Adapter
Function get_adapter_exit_code return varchar2
is
begin
 return pv_AdapterExitCode;
end get_adapter_exit_code;


/******** Commented out START - sacsharm - **************************

--------------- Use XDPATYP?.pls instead ----------------------------
Procedure CreateNewAdapterType( p_AdapterType in varchar2,
				p_AdapterClass in varchar2,
				p_ApplicationMode in varchar2,
				p_InboundReqFlag in varchar2 default 'N',
				p_SyncBufSize in number default 2000,
				p_CmdLineOpts in varchar2 default NULL,
				p_CmdLineArgs in varchar2 default NULL)
is

begin

 XDP_ADAPTER_CORE_DB.LoadNewAdapterType(p_AdapterType,
	 				p_AdapterClass,
					p_ApplicationMode,
					p_InboundReqFlag,
					p_SyncBufSize,
					p_CmdLineOpts,
					p_CmdLineArgs);

end CreateNewAdapterType;



********* Commented out START - sacsharm - *************************/

FUNCTION  Is_Adapter_Configured(
          p_fe_id      IN NUMBER
          ) RETURN BOOLEAN
IS
   lv_result BOOLEAN := FALSE ;
   lv_id NUMBER;

   CURSOR c1 IS
    SELECT 'x' FROM
          xdp_fes,
          xdp_adapter_reg
    WHERE xdp_fes.fe_id = p_fe_id
    AND   xdp_fes.fe_id = xdp_adapter_reg.fe_id;

BEGIN
   lv_result:=FALSE;

    FOR c1_rec IN c1
        LOOP
           lv_result:=TRUE;
        END LOOP;

    RETURN  lv_result;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
         lv_result:= FALSE;
         RETURN  lv_result;
END Is_Adapter_Configured;


FUNCTION Get_Adapter_Log_File_URL(p_channel_name in VARCHAR2,
                                  p_gwyuid in VARCHAR2,
                                  p_two_task in VARCHAR2) return VARCHAR2

AS
  l_log_file_name    xdp_adapter_reg_v.log_file_name%TYPE;
  l_target_node      xdp_adapter_reg_v.target_node%TYPE;
  l_file_id          fnd_file_temp.file_id%TYPE;
  l_url              VARCHAR2(2000);

BEGIN

  SELECT log_file_name, target_node
  INTO l_log_file_name, l_target_node
  FROM xdp_adapter_reg_v
  WHERE channel_name = p_channel_name;

  -- Comment back in the below two lines when FND provides the API
  l_file_id := Fnd_Webfile.create_id(l_log_file_name, l_target_node);
  l_url := Fnd_Webfile.get_url(Fnd_Webfile.generic_log, l_file_id, p_gwyuid, p_two_task, 10);

  return l_url;
END Get_Adapter_Log_File_URL;

FUNCTION Add_Log_File_Extension(p_file_name in VARCHAR2) return VARCHAR2

AS
  l_result 	VARCHAR2(200) 	:= p_file_name;
  name_length 	NUMBER		:= LENGTH(p_file_name);
  ext_length    NUMBER 		:= LENGTH(pv_logFileExtension);

BEGIN

  -- Add '.log' as a suffix if it's not present already
  IF (INSTR(p_file_name, pv_logFileExtension, name_length - ext_length) = 0)
  THEN
	l_result := p_file_name || pv_logFileExtension;
  END IF;

  return l_result;

END Add_Log_File_Extension;


Procedure Verify_Adapter (p_ChannelName in varchar2,
	   	 	p_retcode OUT NOCOPY NUMBER,
		 	p_errbuf OUT NOCOPY VARCHAR2)
is

 l_FeID number;
 l_ProcessID number;
 l_ConcQID number;

 l_AdapterLocked varchar2(1) := 'N';
 l_AdapterLocked1 varchar2(1) := 'N';
 l_CurrentStatus varchar2(30);

begin
	if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'XDP_ADAPTER.VERIFY_ADAPTER',
				'BEGIN:p_ChannelName: '||p_ChannelName);
	end if;
	p_retcode := 0;
	p_errbuf := '';

	if p_ChannelName is null then
	    if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.VERIFY_ADAPTER',
					'Required parameters are not passed');
	    end if;
            raise e_RequiredInputDataNotPassed;
	end if;

	if not XDP_ADAPTER_CORE.VerifyAdapterOperation(p_ChannelName,
				XDP_ADAPTER.pv_opVerify,
				l_CurrentStatus) then
		raise e_InvalidAdapterState;
	end if;

	--Hold session lock only for state change operations - bug3300862
	--l_AdapterLocked := XDP_ADAPTER_CORE_DB.ObtainAdapterLock_Verify(p_ChannelName);
	--if l_AdapterLocked = 'N' then
	--	raise e_UnabletoLockAdapter;
	--end if;

	if (XDP_ADAPTER_CORE_DB.Is_Adapter_Implemented (p_ChannelName)) then

		l_AdapterLocked1 := XDP_ADAPTER_CORE_DB.ObtainAdapterLock_Verify('SESSION_'||p_ChannelName);

		if l_AdapterLocked1 = 'Y' then

			-- Adapter NOT running, release the SESSION lock

			--dbms_output.put_line('Got SESSION lock for: ' || p_ChannelName);
			--dbms_output.put_line('Adapter NOT RUNNING');

			if XDP_ADAPTER_CORE_DB.ReleaseAdapterLock('SESSION_'||p_ChannelName) = 'N' then
			   if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
				FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED, 'XDP_ADAPTER.VERIFY_ADAPTER',
					'Could not release SESSION lock, Channel name: '||p_ChannelName);
			   end if;
			end if;

			XDP_ADAPTER_CORE_DB.FetchAdapterInfo(
				p_ChannelName => p_ChannelName,
				p_FEID => l_FeID,
	  			p_ProcessID => l_ProcessID,
	  			p_ConcQID => l_ConcQID);

			XDP_ADAPTER_CORE_DB.Update_Adapter_Status(
					p_ChannelName,
					pv_statusStoppedError,
					'XDP_ADAPTER_ABNORMAL_EXIT',
					'PROCESS_ID='||l_ProcessID||'#XDP#');

			raise e_OperationFailure;
		else
			--dbms_output.put_line('Did not get SESSION lock for: ' || p_ChannelName);
			--dbms_output.put_line('Adapter RUNNING');

			-- Could not get lock, Adapter running, update last_verified_date
			XDP_ADAPTER_CORE_DB.UpdateAdapter (
					p_ChannelName => p_ChannelName,
					p_LastVerified => sysdate);
		end if;
	else
		-- Adapter not implemented, so Adapter is 'running', update last_verified_date
		XDP_ADAPTER_CORE_DB.UpdateAdapter (
				p_ChannelName => p_ChannelName,
				p_LastVerified => sysdate);
	end if;

exception

when e_InvalidAdapterState then
	p_retCode := pv_retAdapterInvalidState;
	FND_MESSAGE.CLEAR;
	fnd_message.set_name('XDP','XDP_INVALID_ADAPTER_STATE');
 	p_errbuf := FND_MESSAGE.GET;
	if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
  	    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.VERIFY_ADAPTER',
		'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
	end if;

when e_OperationFailure then
	p_retCode := pv_retAdapterAbnormalExit;
	FND_MESSAGE.CLEAR;
	fnd_message.set_name('XDP','XDP_ADAPTER_ABNORMAL_EXIT');
	fnd_message.set_token('PROCESS_ID' , l_ProcessID);
 	p_errbuf := FND_MESSAGE.GET;
	if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
	   FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.VERIFY_ADAPTER',
		'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
	end if;
when others then
if l_AdapterLocked1 = 'Y' then
	if XDP_ADAPTER_CORE_DB.ReleaseAdapterLock('SESSION_'||p_ChannelName) = 'N' then
	    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED, 'XDP_ADAPTER.VERIFY_ADAPTER',
			'Could not release SESSION lock, Channel name: '||p_ChannelName);
	    end if;
	end if;
end if;

if SQLCODE <> 0 then
 	p_retCode := SQLCODE;
 	p_errbuf :=  SQLERRM;
else
	p_retCode := pv_retAdapterOtherError;
 	p_errbuf := 'Other non-SQL error';
END IF;
if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.VERIFY_ADAPTER',
	'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
end if;
end Verify_Adapter;

PROCEDURE  Verify_Running_Adapters (p_controller_instance_id IN NUMBER,
				x_adapter_info OUT NOCOPY VARCHAR2,
	   	 		p_retcode OUT NOCOPY NUMBER,
			 	p_errbuf OUT NOCOPY VARCHAR2)
is

BEGIN
	if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'XDP_ADAPTER.VERIFY_RUNNING_ADAPTERS', 'BEGIN:');
	end if;

	x_adapter_info := 'NONE';
	p_retcode := 0;

	for v_AdapterPID in XDP_ADAPTER_CORE_DB.G_Get_Running_Adapters
					(p_controller_instance_id) loop

		if (v_AdapterPID.is_implemented = 'Y') then

			if (((v_AdapterPID.process_id > 0) AND
				(v_AdapterPID.adapter_status <> XDP_ADAPTER.pv_statusStarting))
			OR
			((v_AdapterPID.adapter_status = XDP_ADAPTER.pv_statusStarting) AND
				((v_AdapterPID.STATUS_ACTIVE_TIME + (5/(60*24))) < SYSDATE))) then
				-- To take care of STARTING adapters, check after 5 minutes
				-- if they are still in STARTING state

				XDP_ADAPTER.Verify_Adapter (
					p_ChannelName 	=> v_AdapterPID.channel_name,
			   	 	p_retcode 	=> p_retcode,
				 	p_errbuf 	=> p_errbuf);

				if ((p_retcode <> 0) and
					(p_retcode <> XDP_ADAPTER.pv_retAdapterAbnormalExit) and
					(p_retcode <> XDP_ADAPTER.pv_retAdapterInvalidState)) then
						-- pv_retAdapterInvalidState means Adapter is
						-- already Stopped (with error), terminated or
						-- Not available
						-- OK case for this

					-- There are only 2 possibilities now, "CannotLock"
					-- or some "when others" error
					if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
					    FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
						'XDP_ADAPTER.VERIFY_RUNNING_ADAPTERS',
						'XDP_ADAPTER.Verify_Adapter errored ChannelName: '||
						v_AdapterPID.channel_name||', Errorcode: '||
						p_retcode||', ErrorDesc: '||
						p_errbuf);
					end if;

					if (p_retcode = XDP_ADAPTER.pv_retAdapterCannotLock) then

						if x_adapter_info = 'NONE' then
							-- First time
							x_adapter_info := v_AdapterPID.channel_name||
								XDP_ADAPTER.pv_SMParamDelimiter||
								v_AdapterPID.process_id||
								XDP_ADAPTER.pv_SMParamDelimiter;
						else
							x_adapter_info := x_adapter_info||
								v_AdapterPID.channel_name||
								XDP_ADAPTER.pv_SMParamDelimiter||
								v_AdapterPID.process_id||
								XDP_ADAPTER.pv_SMParamDelimiter;
						end if;
					else
						-- Some "when others" error
						raise e_OperationFailure;
					END IF;
				END IF;

				commit;

			else
				if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
				FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION,
					'XDP_ADAPTER.VERIFY_RUNNING_ADAPTERS',
					'Adapter verification ignored ChannelName: '||
					v_AdapterPID.channel_name||', process id: '||
					v_AdapterPID.process_id||', AdapterStatus: '||
					v_AdapterPID.adapter_status);
				end if;
			end if;

		end if;
	end loop;

	p_retcode := 0;
	if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_EXCEPTION, 'XDP_ADAPTER.VERIFY_RUNNING_ADAPTERS',
			'Adapters still required to be verified: '||x_adapter_info);
	end if;
exception
when e_OperationFailure then
x_adapter_info := 'NONE';
-- p_retcode and p_errbuf are already set
if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
     FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.VERIFY_RUNNING_ADAPTERS',
	'Verify_Adapter returned Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
end if;
when others then
x_adapter_info := 'NONE';
if SQLCODE <> 0 then
 	p_retCode := SQLCODE;
 	p_errbuf :=  SQLERRM;
else
	p_retCode := pv_retAdapterOtherError;
 	p_errbuf := 'Other non-SQL error';
END IF;
if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.VERIFY_RUNNING_ADAPTERS',
	'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
end if;
end Verify_Running_Adapters;


Procedure Verify_All_Adapters ( p_retcode	OUT NOCOPY NUMBER,
				p_errbuf	OUT NOCOPY VARCHAR2
				)
IS

l_CustomParamList 	varchar2(4000);

BEGIN
	p_retcode := 0;

	for v_GetSvcID in XDP_ADAPTER_CORE_DB.G_Get_Controller_Instances loop

		l_CustomParamList := 'NONE';

		XDP_ADAPTER.Verify_Running_Adapters (
					p_controller_instance_id => v_GetSvcID.service_instance_id,
					x_adapter_info => l_CustomParamList,
					p_retcode => p_retcode,
					p_errbuf => p_errbuf);

		-- We donot care for Adapters that could not be verified i.e. locked for
		-- verification

		if (p_retcode <> 0) then
			raise e_OperationFailure;
		end if;

	end loop;

exception
when e_OperationFailure then
-- p_retcode and p_errbuf are already set
if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.VERIFY_ALL_ADAPTERS',
	'Verify_Running_Adapters returned Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
end if;
when others then
if SQLCODE <> 0 then
 	p_retCode := SQLCODE;
 	p_errbuf :=  SQLERRM;
else
	p_retCode := pv_retAdapterOtherError;
 	p_errbuf := 'Other non-SQL error';
END IF;
if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.VERIFY_ALL_ADAPTERS',
	'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
end if;
END Verify_All_Adapters;

Procedure Verify_Adapters (p_FilterType IN varchar2,
				p_FilterKey 	IN VARCHAR2,
				p_retcode	OUT NOCOPY NUMBER,
				p_errbuf	OUT NOCOPY VARCHAR2
				)
IS

TYPE t_FlexibleRef IS REF CURSOR;
cv_Channelname	t_FlexibleRef;
sql_stmt 	VARCHAR2(4000);

l_ChannelName		XDP_ADAPTER_REG.CHANNEL_NAME%TYPE;
l_ProcessID 		XDP_ADAPTER_REG.PROCESS_ID%TYPE;
l_AdapterStatus 	XDP_ADAPTER_REG.ADAPTER_STATUS%TYPE;
l_StatusActiveTime	XDP_ADAPTER_REG.STATUS_ACTIVE_TIME%TYPE;

BEGIN
	p_retcode := 0;

	if p_FilterKey is null or p_FilterType is null then
		Verify_All_Adapters ( p_retcode	=> p_retcode,
				p_errbuf => p_errbuf);
	else

		sql_stmt := 'select CHANNEL_NAME, PROCESS_ID, ADAPTER_STATUS, STATUS_ACTIVE_TIME from XDP_ADAPTER_REG_V a, XDP_ADAPTER_TYPES_B b where ADAPTER_STATUS not in ';
		sql_stmt := sql_stmt||'('''||XDP_ADAPTER.pv_statusStopped||''','''||XDP_ADAPTER.pv_statusStoppedError||''','''||XDP_ADAPTER.pv_statusTerminated||''','''||XDP_ADAPTER.pv_statusNotAvailable||''',''';
		sql_stmt := sql_stmt||XDP_ADAPTER.pv_statusDeactivated||''','''||XDP_ADAPTER.pv_statusDeactivatedSystem||''')';
		sql_stmt := sql_stmt||' and a.adapter_type = b.adapter_type and b.adapter_class <> ''NONE'' and UPPER('||p_FilterType||') like UPPER('''||p_FilterKey||''')';

		--XDP_UTILITIES.DISPLAY('sql_stmt:'||sql_stmt||':');

		OPEN cv_ChannelName FOR sql_stmt ;
		LOOP
		FETCH cv_ChannelName INTO l_ChannelName, l_ProcessID, l_AdapterStatus, l_StatusActiveTime;
			EXIT WHEN cv_ChannelName%NOTFOUND;

			if (((l_ProcessID > 0) AND
					(l_AdapterStatus <> XDP_ADAPTER.pv_statusStarting))
				OR
			((l_AdapterStatus = XDP_ADAPTER.pv_statusStarting) AND
				((l_StatusActiveTime + (5/(60*24))) < SYSDATE))) then

				XDP_ADAPTER.Verify_Adapter (
					p_ChannelName 	=> l_ChannelName,
			   	 	p_retcode 	=> p_retcode,
				 	p_errbuf 	=> p_errbuf);

				if ((p_retcode <> 0) and
					(p_retcode <> XDP_ADAPTER.pv_retAdapterInvalidState) and
					(p_retcode <> XDP_ADAPTER.pv_retAdapterAbnormalExit) and
					(p_retcode <> XDP_ADAPTER.pv_retAdapterCannotLock)) then
						raise e_OperationFailure;
				END IF;
			END IF;

			commit;

		END LOOP;

		CLOSE cv_ChannelName;

	END IF;

	p_retcode := 0;

exception

when e_OperationFailure then
if cv_ChannelName%ISOPEN then
	CLOSE cv_ChannelName;
END IF;
-- p_retcode and p_errbuf are already set
if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.VERIFY_ADAPTERS',
	'Verify_Adapter returned Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
end if;
when others then
if cv_ChannelName%ISOPEN then
	CLOSE cv_ChannelName;
END IF;
-- p_retcode and p_errbuf are already set
if SQLCODE <> 0 then
 	p_retCode := SQLCODE;
 	p_errbuf :=  SQLERRM;
else
	p_retCode := pv_retAdapterOtherError;
 	p_errbuf := 'Other non-SQL error';
END IF;
if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.VERIFY_ADAPTERS',
	'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
end if;
END Verify_Adapters;

-- This procedure is called by Controller to reset status of automatic adpaters
-- having status pv_statusDeactivatedSystem to pv_statusStopped
-- So it is an automatic adapter and status is DEACTIVATED_SYSTEM is assumed
-- and not checked.

Procedure Reset_SysDeactivated_Adapter (p_ChannelName in varchar2,
				p_ResetStatusFlag in boolean default true)
IS

 l_AdapterLocked varchar2(1) := 'N';

BEGIN
	l_AdapterLocked := XDP_ADAPTER_CORE_DB.ObtainAdapterLock_Verify(p_ChannelName);
	if l_AdapterLocked = 'N' then
		return;
	else
		if (p_ResetStatusFlag) then
			XDP_ADAPTER_CORE_DB.UpdateAdapter(
				p_ChannelName => p_ChannelName,
				p_Status => pv_statusStopped);
		END IF;

		-- Reset start error count to 0

		XDP_ERRORS_PKG.UPDATE_ERROR_COUNT (
			p_object_type => XDP_ADAPTER.pv_errorObjectTypeAdapter,
			p_object_key => p_ChannelName);

		if (XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName) = 'N') then
		   if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
			FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED, 'XDP_ADAPTER.RESET_SYSDEACTIVATED_ADAPTER',
				'Could not release the lock, Channel name: '||p_ChannelName);
		   end if;
	 	end if;
	end if;

exception

when others then

if l_AdapterLocked = 'Y' then
	if (XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName) = 'N') then
	   if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED, 'XDP_ADAPTER.RESET_SYSDEACTIVATED_ADAPTER',
			'Could not release the lock, Channel name: '||p_ChannelName);
	   end if;
 	end if;
end if;
if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.RESET_SYSDEACTIVATED_ADAPTER',
	'Unhandled error, SQLCODE: '||SQLCODE);
end if;
END Reset_SysDeactivated_Adapter;

PROCEDURE  Reset_SysDeactivated_Adapters (p_controller_instance_id IN NUMBER)
is
BEGIN
	if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'XDP_ADAPTER.RESET_SYSDEACTIVATED_ADAPTERS', 'BEGIN:');
	end if;

	for v_SysDeactivatedAdapter in XDP_ADAPTER_CORE_DB.G_Get_SysDeactivated_Adapters
					(p_controller_instance_id) loop

		if (v_SysDeactivatedAdapter.adapter_status = XDP_ADAPTER.pv_statusDeactivatedSystem) then

			XDP_ADAPTER.Reset_SysDeactivated_Adapter (
				p_ChannelName => v_SysDeactivatedAdapter.channel_name);
		else
			XDP_ADAPTER.Reset_SysDeactivated_Adapter (
				p_ChannelName => v_SysDeactivatedAdapter.channel_name,
				p_ResetStatusFlag => false);
		END IF;

		commit;

	end loop;

exception

when others then
if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.RESET_SYSDEACTIVATED_ADAPTERS',
	'Unhandled error, SQLCODE: '||SQLCODE);
end if;
end RESET_SYSDEACTIVATED_ADAPTERS;

Procedure validate_operation(p_ChannelName in varchar2, p_Operation in varchar2,
                        p_CPID OUT NOCOPY NUMBER,
                        p_ProcessID OUT NOCOPY NUMBER,
	   	 	p_retcode OUT NOCOPY NUMBER,
		 	p_errbuf OUT NOCOPY VARCHAR2)
is
 l_CurrentStatus varchar2(30);

 l_FeID number;
 l_ConcQID number;
 l_Flag varchar2(10);
begin
	if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_PROCEDURE, 'XDP_ADAPTER.VALIDATE_OPERATION',
				'BEGIN:p_ChannelName: '||p_ChannelName);
	end if;
	p_retcode := 0;
	p_errbuf := '';

	if p_ChannelName is null then
	    if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
		FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.VALIDATE_OPERATION',
					'Required parameters are not passed');
	   end if;
 	   raise e_RequiredInputDataNotPassed;
	end if;

        --Verify adapter state for operation only if operation is not Terminate
        if (p_Operation <> XDP_ADAPTER.pv_opTerminate) then
            if not XDP_ADAPTER_CORE.VerifyAdapterOperation(p_ChannelName, p_Operation,
                                                           l_CurrentStatus) then
                    raise e_InvalidAdapterState;
            end if;
	END IF;

        --Hold session lock only for state change operations - bug3300862
        if (p_Operation <> XDP_ADAPTER.pv_opGeneric) then
            if (XDP_ADAPTER_CORE_DB.ObtainAdapterLock_Verify(p_ChannelName) = 'N') then
                raise e_UnabletoLockAdapter;
            end if;
        END IF;

        -- Though Controller is only needed for implemented adapter types but to give consistent
        -- response for non-implemented adapter types we should always check if Controller
        -- is up.
	if (XDP_ADAPTER_CORE_DB.Is_Adapter_Implemented (p_ChannelName)) then

                -- We need to retrieve process id, Verify_Adapter could set it to -1
                XDP_ADAPTER_CORE_DB.FetchAdapterInfo(
			p_ChannelName => p_ChannelName,
			p_FEID => l_FeID,
			p_ProcessID => p_ProcessID,
			p_ConcQID => l_ConcQID);

        	--Verify adapter state for operation only if operation is not Start
		if (p_Operation <> XDP_ADAPTER.pv_opStartup) then
                    -- Cannot use Verify_Adapter API as call to update row has to be autonomous
                    if not XDP_ADAPTER_CORE_DB.Verify_Adapter (p_ChannelName) then
                        if XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName) = 'N' then
			    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
                                FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED, 'XDP_ADAPTER.VALIDATE_OPERATION',
                                    'Could not release the lock, Channel name: '||p_ChannelName);
		            end if;
                        end if;

                        raise e_OperationFailure;
                    END IF;
                END IF;

                XDP_CONTROLLER_CORE.VerifyControllerStatus(l_ConcQID, p_CPID, l_Flag);
                if l_Flag = 'N' then
                    if XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName) = 'N' then
		        if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
                            FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED, 'XDP_ADAPTER.VALIDATE_OPERATION',
                            'Could not release the lock, Channel name: '||p_ChannelName);
			end if;
                    end if;

                    raise e_ControllerNotRunning;
                end if;

	end if;

exception
when e_OperationFailure then
	FND_MESSAGE.CLEAR;
	p_retCode := pv_retAdapterCommFailed;
	-- p_retCode := pv_retAdapterAbnormalExit;
	fnd_message.set_name('XDP','XDP_ADAPTER_ABNORMAL_EXIT');
	fnd_message.set_token('PROCESS_ID' , p_ProcessID);

	p_errbuf := FND_MESSAGE.GET;
	if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.VALIDATE_OPERATION',
		'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
	end if;

when e_InvalidAdapterState then
	p_retCode := pv_retAdapterInvalidState;
	FND_MESSAGE.CLEAR;
	fnd_message.set_name('XDP','XDP_INVALID_ADAPTER_STATE');
 	p_errbuf := FND_MESSAGE.GET;
	if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.VALIDATE_OPERATION',
		'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
	end if;
when e_UnabletoLockAdapter then
	p_retCode := pv_retAdapterCannotLock;
	FND_MESSAGE.CLEAR;
	fnd_message.set_name('XDP','XDP_ADAPTER_UNLOCKABLE');
 	p_errbuf := FND_MESSAGE.GET;
	if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.VALIDATE_OPERATION',
		'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
	end if;
when e_ControllerNotRunning then
	p_retCode := pv_retAdapterCtrlNotRunning;
	FND_MESSAGE.CLEAR;
	fnd_message.set_name('XDP','XDP_CONTROLLER_NOT_RUNNING');
 	p_errbuf := FND_MESSAGE.GET;
	if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
	    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.VALIDATE_OPERATION',
		'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
	end if;
when others then
if (XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName) = 'N') then
    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
	FND_LOG.STRING (FND_LOG.LEVEL_UNEXPECTED, 'XDP_ADAPTER.VALIDATE_OPERATION',
		'Could not release the lock, Channel name: '||p_ChannelName);
    end if;
end if;
if SQLCODE <> 0 then
 	p_retCode := SQLCODE;
 	p_errbuf :=  SQLERRM;
else
	p_retCode := pv_retAdapterOtherError;
 	p_errbuf := 'Other non-SQL error';
END IF;
if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then     --Fix Bug: 4256771, dputhiye, 28 Apr 05
    FND_LOG.STRING (FND_LOG.LEVEL_ERROR, 'XDP_ADAPTER.VALIDATE_OPERATION',
	'Error code: '||p_retCode||' ,Error desc: '||p_errbuf);
end if;
end validate_operation;

END XDP_ADAPTER;

/
