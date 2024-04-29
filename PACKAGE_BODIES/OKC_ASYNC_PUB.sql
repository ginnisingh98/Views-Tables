--------------------------------------------------------
--  DDL for Package Body OKC_ASYNC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_ASYNC_PUB" as
/* $Header: OKCPASNB.pls 120.1 2005/12/14 22:14:25 npalepu noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

--


procedure proc_call(
			--
			-- common API parameters
			--
				p_api_version	IN	NUMBER,
                     	p_init_msg_list	IN	VARCHAR2 ,
                     	x_return_status	OUT 	NOCOPY	VARCHAR2,
                     	x_msg_count		OUT 	NOCOPY	NUMBER,
                     	x_msg_data		OUT 	NOCOPY	VARCHAR2,
			--
			-- specific parameters
			--
			   	p_proc		IN	VARCHAR2,
				p_period_days	IN 	NUMBER ,
				p_stop_date		IN 	DATE ,
				x_key_to_stop	OUT	NOCOPY	VARCHAR2
) is
t OKC_ASYNC_PVT.par_tbl_typ;
   --
   l_proc varchar2(72) := '  OKC_ASYNC_PUB.'||'proc_call';
   --

begin

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

  t(1).par_type :=  'N';
  t(1).par_name :=  'P_PERIOD_DAYS';
  t(1).par_value :=  p_period_days;
  t(2).par_type :=  'D';
  t(2).par_name :=  'P_STOP_DATE';
  t(2).par_value :=  p_stop_date;
  OKC_ASYNC_PVT.wf_call(
				p_api_version	=> p_api_version,
                     	p_init_msg_list	=> p_init_msg_list,
                     	x_return_status	=> x_return_status,
                     	x_msg_count		=> x_msg_count,
                     	x_msg_data		=> x_msg_data,
			   	p_proc		=> substr(p_proc,1,4000),
				p_wf_par_tbl	=> t
  );
  if (x_return_status = 'S') then
    select to_char(okc_wf_notify_s1.currval) into x_key_to_stop from dual;
  end if;
        IF (l_debug = 'Y') THEN
           okc_debug.Log('1000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;
end;

procedure proc_stop(
			--
			-- common API parameters
			--
				p_api_version	IN	NUMBER,
                     	p_init_msg_list	IN	VARCHAR2 ,
                     	x_return_status	OUT 	NOCOPY	VARCHAR2,
                     	x_msg_count		OUT 	NOCOPY	NUMBER,
                     	x_msg_data		OUT 	NOCOPY	VARCHAR2,
			--
				p_stop_date		IN 	DATE ,
				p_key_to_stop	IN	VARCHAR2
) is
l_api_name                     CONSTANT VARCHAR2(30) := 'PROC_STOP';
l_return_status varchar2(1);
l_wf_name varchar2(100);
l_end_date date;
cursor wf_active is
  select end_date from WF_ITEMS
  where item_type = l_wf_name
   and item_key = p_key_to_stop
;
   --
   l_proc varchar2(72) := '  OKC_ASYNC_PUB.'||'proc_stop';
   --

begin

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

  l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              'OKC_ASYNC_PUB',
                                              OKC_API.G_TRUE,
                                              p_api_version,
                                              p_api_version,
                                              'PUB',
                                              x_return_status);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  l_wf_name := OKC_ASYNC_PVT.G_WF_NAME;
  open wf_active;
  fetch wf_active into l_end_date;
  close wf_active;
  if (l_end_date is not NULL) then
    if (p_stop_date > sysdate) then
      x_return_status := 'E';
    else
      x_return_status := 'S';
    end if;
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;
    return;
  end if;
--
  if ( trunc(NVL(p_stop_date,sysdate))
		-NVL(wf_engine.GetItemAttrNumber (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> p_key_to_stop,
  	      				aname 	=> 'P_PERIOD_DAYS'),0) <
	trunc(sysdate)+1) then
    wf_engine.abortprocess(L_WF_NAME,p_key_to_stop);
  else
    wf_engine.SetItemAttrDate (itemtype 	=> L_WF_NAME,
	      				itemkey  	=> p_key_to_stop,
  	      				aname 	=> 'P_STOP_DATE',
						avalue	=> trunc(p_stop_date) );
  end if;
  OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

        IF (l_debug = 'Y') THEN
           okc_debug.Log('1000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;

  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        'OKC_ASYNC_PUB',
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        'PUB');
        IF (l_debug = 'Y') THEN
           okc_debug.Log('2000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        'OKC_ASYNC_PUB',
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        'PUB');
        IF (l_debug = 'Y') THEN
           okc_debug.Log('3000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        'OKC_ASYNC_PUB',
        'OTHERS',
        x_msg_count,
        x_msg_data,
        'PUB');
        IF (l_debug = 'Y') THEN
           okc_debug.Log('4000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;
end proc_stop;

procedure msg_call(
			--
			-- common API parameters
			--
				p_api_version	IN	NUMBER,
                     	p_init_msg_list	IN	VARCHAR2 ,
                     	x_return_status	OUT 	NOCOPY	VARCHAR2,
                     	x_msg_count		OUT 	NOCOPY	NUMBER,
                     	x_msg_data		OUT 	NOCOPY	VARCHAR2,
			--
			-- specific parameters
			--
				p_recipient		IN	VARCHAR2,
			   	p_msg_subj 		IN	VARCHAR2,
			   	p_msg_body		IN	VARCHAR2,
			--
			-- hidden notification attributes
			--
				p_ntf_type		IN	VARCHAR2 ,
				p_contract_id	IN	NUMBER ,
				p_task_id		IN	NUMBER ,
				p_extra_attr_num	IN	NUMBER ,
				p_extra_attr_text	IN	VARCHAR2 ,
				p_extra_attr_date	IN	DATE
) is
t OKC_ASYNC_PVT.par_tbl_typ;
   --
   l_proc varchar2(72) := '  OKC_ASYNC_PUB.'||'msg_call';
   --

begin

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

  t(1).par_type :=  'C';
  t(1).par_name :=  'MESSAGE0';
  t(1).par_value :=  substr(p_msg_subj,1,4000);
  t(2).par_type :=  'C';
  t(2).par_name :=  'MESSAGE1';
  t(2).par_value :=  substr(p_msg_body,1,4000);
  t(3).par_type :=  'N';
  t(3).par_name :=  'CONTRACT_ID';
  t(3).par_value :=  p_contract_id;
  t(4).par_type :=  'N';
  t(4).par_name :=  'TASK_ID';
  t(4).par_value :=  p_task_id;
  t(5).par_type :=  'N';
  t(5).par_name :=  'EXTRA_ATTR_NUM';
  t(5).par_value :=  p_extra_attr_num;
  t(6).par_type :=  'C';
  t(6).par_name :=  'EXTRA_ATTR_TEXT';
  t(6).par_value :=  substr(p_extra_attr_text,1,4000);
  t(7).par_type :=  'D';
  t(7).par_name :=  'EXTRA_ATTR_DATE';
  t(7).par_value :=  p_extra_attr_date;
  OKC_ASYNC_PVT.wf_call(
				p_api_version	=> p_api_version,
                     	p_init_msg_list	=> p_init_msg_list,
                     	x_return_status	=> x_return_status,
                     	x_msg_count		=> x_msg_count,
                     	x_msg_data		=> x_msg_data,
			   	p_s_recipient	=> p_recipient,
			   	p_ntf_type		=> substr(p_ntf_type,1,4000),
				p_wf_par_tbl	=> t
  );
        IF (l_debug = 'Y') THEN
           okc_debug.Log('1000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;

end;

procedure proc_msg_call(
			--
			-- common API parameters
			--
				p_api_version	IN	NUMBER,
                     	p_init_msg_list	IN	VARCHAR2 ,
                     	x_return_status	OUT 	NOCOPY	VARCHAR2,
                     	x_msg_count		OUT 	NOCOPY	NUMBER,
                     	x_msg_data		OUT 	NOCOPY	VARCHAR2,
			--
			-- specific parameters
			--
			   	p_proc			IN	VARCHAR2,
                     	p_subj_first_msg		IN	VARCHAR2 ,
				p_s_recipient		IN	VARCHAR2, -- normal recipient
				p_e_recipient		IN	VARCHAR2, -- error recipient
			--
			-- hidden notification attributes
			--
				p_ntf_type		IN	VARCHAR2 ,
				p_contract_id	IN	NUMBER ,
				p_task_id		IN	NUMBER ,
				p_extra_attr_num	IN	NUMBER ,
				p_extra_attr_text	IN	VARCHAR2 ,
				p_extra_attr_date	IN	DATE
) is
t OKC_ASYNC_PVT.par_tbl_typ;
   --
   l_proc varchar2(72) := '  OKC_ASYNC_PUB.'||'proc_msg_call';
   --

begin

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

  t(1).par_type :=  'N';
  t(1).par_name :=  'CONTRACT_ID';
  t(1).par_value :=  p_contract_id;
  t(2).par_type :=  'N';
  t(2).par_name :=  'TASK_ID';
  t(2).par_value :=  p_task_id;
  t(3).par_type :=  'N';
  t(3).par_name :=  'EXTRA_ATTR_NUM';
  t(3).par_value :=  p_extra_attr_num;
  t(4).par_type :=  'C';
  t(4).par_name :=  'EXTRA_ATTR_TEXT';
  t(4).par_value :=  substr(p_extra_attr_text,1,4000);
  t(5).par_type :=  'D';
  t(5).par_name :=  'EXTRA_ATTR_DATE';
  t(5).par_value :=  p_extra_attr_date;
  OKC_ASYNC_PVT.wf_call(
				p_api_version	=> p_api_version,
                     	p_init_msg_list	=> p_init_msg_list,
                     	x_return_status	=> x_return_status,
                     	x_msg_count		=> x_msg_count,
                     	x_msg_data		=> x_msg_data,
				p_proc		=> substr(p_proc,1,4000),
                     	p_subj_first_msg	=> p_subj_first_msg,
			   	p_s_recipient	=> p_s_recipient,
			   	p_e_recipient	=> p_e_recipient,
			   	p_ntf_type		=> substr(p_ntf_type,1,4000),
				p_wf_par_tbl	=> t
  );
        IF (l_debug = 'Y') THEN
           okc_debug.Log('1000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;

end;

procedure resolver_call(
			--
			-- common API parameters
			--
				p_api_version	IN	NUMBER,
                     	p_init_msg_list	IN	VARCHAR2 ,
                     	x_return_status	OUT 	NOCOPY	VARCHAR2,
                     	x_msg_count		OUT 	NOCOPY	NUMBER,
                     	x_msg_data		OUT 	NOCOPY	VARCHAR2,
			--
			-- wf attributes
			--
			   	p_resolver		IN	VARCHAR2,
			   	p_msg_subj 		IN	VARCHAR2,
			   	p_msg_body	 	IN	VARCHAR2,
				p_note		IN VARCHAR2 ,
				p_accept_proc	IN VARCHAR2,
				p_reject_proc	IN VARCHAR2,
				p_timeout_proc	IN VARCHAR2 ,
				p_timeout_minutes IN NUMBER ,--month default to force wf end
			--
			-- hidden notification attributes
			--
				p_ntf_type		IN VARCHAR2 ,
				p_contract_id	IN NUMBER ,
				p_task_id		IN NUMBER ,
				p_extra_attr_num	IN NUMBER ,
				p_extra_attr_text	IN VARCHAR2 ,
				p_extra_attr_date	IN DATE
) is
   --
   l_proc varchar2(72) := '  OKC_ASYNC_PUB.'||'resolver_call';
   --

begin

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

  OKC_ASYNC_PVT.resolver_call(
				p_api_version	=> p_api_version,
                     	p_init_msg_list	=> p_init_msg_list,
                     	x_return_status	=> x_return_status,
                     	x_msg_count		=> x_msg_count,
                     	x_msg_data		=> x_msg_data,
--
			   	p_resolver		=> p_resolver,
			   	p_msg_subj_resolver => substr(p_msg_subj,1,4000),
			   	p_msg_body_resolver => substr(p_msg_body,1,4000),
				p_note		=> substr(p_note,1,4000),
				p_accept_proc	=> substr(p_accept_proc,1,4000),
				p_reject_proc	=> substr(p_reject_proc,1,4000),
				p_timeout_proc	=> substr(p_timeout_proc,1,4000),
				p_timeout_minutes => p_timeout_minutes,
--
				p_ntf_type		=> substr(p_ntf_type,1,4000),
				p_contract_id	=> p_contract_id,
				p_task_id		=> p_task_id,
				p_extra_attr_num	=> p_extra_attr_num,
				p_extra_attr_text	=> substr(p_extra_attr_text,1,4000),
				p_extra_attr_date	=> p_extra_attr_date
);
        IF (l_debug = 'Y') THEN
           okc_debug.Log('1000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;

end;

procedure send_doc(
			--
			-- common API parameters
			--
				p_api_version	IN	NUMBER,
                     	p_init_msg_list	IN	VARCHAR2 ,
                     	x_return_status	OUT 	NOCOPY	VARCHAR2,
                     	x_msg_count		OUT 	NOCOPY	NUMBER,
                     	x_msg_data		OUT 	NOCOPY	VARCHAR2,
			--
			-- specific parameters
			--
			   	p_recipient		IN	VARCHAR2,
			   	p_msg_subj 		IN	VARCHAR2,
			   	p_msg_body		IN	VARCHAR2,
			   	p_proc		IN	VARCHAR2,
			--
			-- hidden notification attributes
			--
				p_ntf_type		IN	VARCHAR2 ,
				p_contract_id	IN	NUMBER ,
				p_task_id		IN	NUMBER ,
				p_extra_attr_num	IN	NUMBER ,
				p_extra_attr_text	IN	VARCHAR2 ,
				p_extra_attr_date	IN	DATE
) is
t OKC_ASYNC_PVT.par_tbl_typ;
   --
   l_proc varchar2(72) := '  OKC_ASYNC_PUB.'||'send_doc';
   --

begin

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

  t(1).par_type :=  'C';
  t(1).par_name :=  'MESSAGE0';
  t(1).par_value :=  substr(p_msg_subj,1,4000);
  t(2).par_type :=  'C';
  t(2).par_name :=  'MESSAGE1';
  t(2).par_value :=  substr(p_msg_body,1,4000);
  t(3).par_type :=  'N';
  t(3).par_name :=  'CONTRACT_ID';
  t(3).par_value :=  p_contract_id;
  t(4).par_type :=  'N';
  t(4).par_name :=  'TASK_ID';
  t(4).par_value :=  p_task_id;
  t(5).par_type :=  'N';
  t(5).par_name :=  'EXTRA_ATTR_NUM';
  t(5).par_value :=  p_extra_attr_num;
  t(6).par_type :=  'C';
  t(6).par_name :=  'EXTRA_ATTR_TEXT';
  t(6).par_value :=  substr(p_extra_attr_text,1,4000);
  t(7).par_type :=  'D';
  t(7).par_name :=  'EXTRA_ATTR_DATE';
  t(7).par_value :=  p_extra_attr_date;
  t(8).par_type :=  'C';
  t(8).par_name :=  'P_DOC_PROC';
  t(8).par_value :=  substr(p_proc,1,4000);
  OKC_ASYNC_PVT.wf_call(
				p_api_version	=> p_api_version,
                     	p_init_msg_list	=> p_init_msg_list,
                     	x_return_status	=> x_return_status,
                     	x_msg_count		=> x_msg_count,
                     	x_msg_data		=> x_msg_data,
			   	p_s_recipient	=> p_recipient,
			   	p_ntf_type		=> substr(p_ntf_type,1,4000),
				p_wf_par_tbl	=> t
  );
        IF (l_debug = 'Y') THEN
           okc_debug.Log('1000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;

end;

procedure loop_call(
		--
		-- common API parameters
		--
			p_api_version	IN	NUMBER,
                 	p_init_msg_list	IN	VARCHAR2 ,
                 	x_return_status	OUT 	NOCOPY	VARCHAR2,
                 	x_msg_count		OUT 	NOCOPY	NUMBER,
                 	x_msg_data		OUT 	NOCOPY	VARCHAR2,
		--
		-- specific parameters
		--
		   	p_proc			IN	VARCHAR2,
			p_s_recipient		IN	VARCHAR2 ,
			p_e_recipient		IN	VARCHAR2 ,
			p_timeout_minutes 	IN NUMBER ,
			p_loops 			IN NUMBER ,
	            p_subj_first_msg		IN	VARCHAR2 ,
		--
		-- hidden notification attributes
		--
			p_ntf_type		IN	VARCHAR2 ,
			p_contract_id	IN	NUMBER ,
			p_task_id		IN	NUMBER ,
			p_extra_attr_num	IN	NUMBER ,
			p_extra_attr_text	IN	VARCHAR2 ,
			p_extra_attr_date	IN	DATE
) is
   --
   l_proc varchar2(72) := '  OKC_ASYNC_PUB.'||'loop_call';
   --

begin

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

  OKC_ASYNC_PVT.loop_call(
				p_api_version	=> p_api_version,
                     	p_init_msg_list	=> p_init_msg_list,
                     	x_return_status	=> x_return_status,
                     	x_msg_count		=> x_msg_count,
                     	x_msg_data		=> x_msg_data,
--
				p_proc		=> substr(p_proc,1,4000),
			   	p_s_recipient	=> p_s_recipient,
			   	p_e_recipient	=> p_e_recipient,
				p_timeout_minutes => p_timeout_minutes,
				p_loops		=> p_loops,
		            p_subj_first_msg  => p_subj_first_msg,
		--
		-- hidden notification attributes
		--
				p_ntf_type		=> substr(p_ntf_type,1,4000),
				p_contract_id	=> p_contract_id,
				p_task_id		=> p_task_id,
				p_extra_attr_num	=> p_extra_attr_num,
				p_extra_attr_text	=> substr(p_extra_attr_text,1,4000),
				p_extra_attr_date	=> p_extra_attr_date
);
        IF (l_debug = 'Y') THEN
           okc_debug.Log('1000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;

end;

--NPALEPU
--14-DEC-2005
--For Bug # 4699009, Added Overloaded LOOP_CALL API.
procedure loop_call(
                --
                -- common API parameters
                --
                        p_api_version           IN      NUMBER,
                        p_init_msg_list         IN      VARCHAR2 ,
                        x_return_status         OUT     NOCOPY  VARCHAR2,
                        x_msg_count             OUT     NOCOPY  NUMBER,
                        x_msg_data              OUT     NOCOPY  VARCHAR2,
                --
                -- specific parameters
                --
                        p_proc                  IN      VARCHAR2,
                        p_proc_name             IN      VARCHAR2,
                        p_s_recipient           IN      VARCHAR2 ,
                        p_e_recipient           IN      VARCHAR2 ,
                        p_timeout_minutes       IN      NUMBER ,
                        p_loops                         IN NUMBER ,
                    p_subj_first_msg            IN      VARCHAR2 ,
                --
                -- hidden notification attributes
                --
                        p_ntf_type              IN      VARCHAR2 ,
                        p_contract_id           IN      NUMBER ,
                        p_task_id               IN      NUMBER ,
                        p_extra_attr_num        IN      NUMBER ,
                        p_extra_attr_text       IN      VARCHAR2 ,
                        p_extra_attr_date       IN      DATE
) is
   --
   l_proc varchar2(72) := '  OKC_ASYNC_PUB.'||'loop_call';
   --

begin

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

  OKC_ASYNC_PVT.loop_call(      p_api_version      => p_api_version,
                                p_init_msg_list    => p_init_msg_list,
                                x_return_status    => x_return_status,
                                x_msg_count        => x_msg_count,
                                x_msg_data         => x_msg_data,
                                p_proc             => substr(p_proc,1,4000),
                                p_proc_name        => p_proc_name,
                                p_s_recipient      => p_s_recipient,
                                p_e_recipient      => p_e_recipient,
                                p_timeout_minutes  => p_timeout_minutes,
                                p_loops            => p_loops,
                                p_subj_first_msg   => p_subj_first_msg,
                --
                -- hidden notification attributes
                --
                                p_ntf_type        => substr(p_ntf_type,1,4000),
                                p_contract_id     => p_contract_id,
                                p_task_id         => p_task_id,
                                p_extra_attr_num  => p_extra_attr_num,
                                p_extra_attr_text => substr(p_extra_attr_text,1,4000),
                                p_extra_attr_date => p_extra_attr_date
                        );
        IF (l_debug = 'Y') THEN
           okc_debug.Log('1000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;

end LOOP_CALL;
--END NPALEPU

end OKC_ASYNC_PUB;

/
