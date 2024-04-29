--------------------------------------------------------
--  DDL for Package Body OKC_AQ_WRITE_ERROR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_AQ_WRITE_ERROR_PVT" AS
/* $Header: OKCRAQWB.pls 120.1 2006/03/31 17:32:09 vjramali noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

    -- Start of comments
    -- Procedure Name  : write_msgdata
    -- Description     : Inserts records into okc_aqerrors and okc_aqmsgstacks
    -- Version         : 1.0
    -- End of comments
    PROCEDURE WRITE_MSGDATA(p_api_version	IN NUMBER,
			    p_init_msg_list  	IN VARCHAR2 ,
			    p_source_name	IN VARCHAR2,
			    p_datetime		IN DATE,
			    p_msg_tab		IN OKC_AQ_PVT.msg_tab_typ,
			    p_q_name		IN VARCHAR2 ,
			    p_corrid	        IN VARCHAR2,
			    p_msgid		IN RAW ,
			    p_message_name	IN VARCHAR2 ,
			    p_msg_count		IN NUMBER,
			    p_msg_data		IN VARCHAR2,
			    p_commit		IN VARCHAR2 ) IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	ctr			NUMBER := 0;
	l_msg_text		VARCHAR2(4000);
	l_return_status	    	VARCHAR2(1);
	l_msg_count	    	NUMBER;
	l_msg_data	    	VARCHAR2(240);
	G_FIRST	    		CONSTANT	NUMBER	:=  -1;
	l_msg_clob		CLOB := EMPTY_CLOB();
	l_retry_count		NUMBER := 0;
	l_api_name              CONSTANT VARCHAR2(30) := 'WRITE_MSGDATA';
	l_init_msg_list		VARCHAR2(3) ;
	proc_notfound           NUMBER := 0;
	l_commit                VARCHAR2(3) := 'T';

	--Select the retry count from events table
	Cursor retry_cur(p_msgid IN RAW) is
	select /*+ INDEX (OKC_AQ_EV_TAB) */ retry_count
	from OKC_AQ_EV_TAB
	where msgid = p_msgid;

    BEGIN
	--Initialize return status
	l_return_status := OKC_API.G_RET_STS_SUCCESS;

	-- Standard START OF API SAVEPOINT
	DBMS_TRANSACTION.SAVEPOINT(l_api_name || '_PVT');

	--Get the retry count from events table
	IF p_msgid IS NOT NULL THEN
	  OPEN retry_cur(p_msgid);
	  FETCH retry_cur into l_retry_count;
	  CLOSE retry_cur;
	END IF;

	--Get the Queue contents
		OKC_AQ_WRITE_ERROR_PVT.get_clob_msg(p_msg_tab => p_msg_tab,
						    p_q_name  => p_q_name,
						    p_corrid  => p_corrid,
						    p_msg_clob => l_msg_clob,
						    x_return_status => l_return_status,
						    x_msg_count => l_msg_count,
                                                    x_msg_data => l_msg_data);
			IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      				RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    			ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      				RAISE OKC_API.G_EXCEPTION_ERROR;
			END IF;

	--Retrieve the first message from the stack
	IF p_msg_count = 1  or p_msg_count IS NULL THEN
		--Populate record for errors
		l_aqev_rec.source_name 		:= p_source_name;
		l_aqev_rec.datetime		:= p_datetime;
		l_aqev_rec.q_name		:= p_q_name;
		l_aqev_rec.msgid		:= p_msgid;
		l_aqev_rec.queue_contents	:= l_msg_clob;
		l_aqev_rec.retry_count		:= l_retry_count;

		--Populate the error messages table
			l_msg_text := FND_MSG_PUB.Get(p_msg_index => G_FIRST,
					 	      p_encoded => FND_API.G_FALSE);
		        proc_notfound := instr(l_msg_text,'ORA-06508',1,1);
			l_aqmv_tbl(1).message_text := SUBSTR(l_msg_text, 1, 1995);
			l_aqmv_tbl(1).msg_seq_no := 1;

		--Call the public api to insert records into error and message stack tables
		OKC_AQERRMSG_PUB.create_err_msg(
    				p_api_version		=> p_api_version,
    				p_init_msg_list		=> p_init_msg_list,
    				x_return_status		=> l_return_status,
    				x_msg_count		=> l_msg_count,
    				x_msg_data		=> l_msg_data,
    				p_aqev_rec		=> l_aqev_rec,
    				p_aqmv_tbl 		=> l_aqmv_tbl,
    				x_aqev_rec		=> x_aqev_rec,
   			 	x_aqmv_tbl 		=> x_aqmv_tbl);
			IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      				RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    			ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      				RAISE OKC_API.G_EXCEPTION_ERROR;
			ELSIF l_return_status = OKC_API.G_RET_STS_SUCCESS  THEN
		          l_commit := 'T';
			END IF;

	--Retrieves more than a single message
	ELSIF p_msg_count > 1 THEN
		l_aqev_rec.source_name 		:= p_source_name;
		l_aqev_rec.datetime 		:= p_datetime;
		l_aqev_rec.q_name 		:= p_q_name;
		l_aqev_rec.msgid 		:= p_msgid;
		l_aqev_rec.queue_contents 	:= l_msg_clob;
		l_aqev_rec.retry_count 		:= l_retry_count;

	 	FOR i IN 1..p_msg_count LOOP
			ctr := ctr + 1;
			l_msg_text := FND_MSG_PUB.Get(p_msg_index => ctr,
					 	      p_encoded => FND_API.G_FALSE);
		        proc_notfound := instr(l_msg_text,'ORA-06508',1,1);
			l_aqmv_tbl(ctr).message_text := SUBSTR(l_msg_text, 1, 1995);
			l_aqmv_tbl(ctr).msg_seq_no := ctr;
			IF proc_notfound <> 0 THEN
			  EXIT;
			END IF;
         	END LOOP;
		--Call the Public API to insert error records into the okc_aqerrors
		--and okc_aqmsgstacks
		OKC_AQERRMSG_PUB.create_err_msg(
    				p_api_version		=> p_api_version,
    				p_init_msg_list		=> p_init_msg_list,
    				x_return_status		=> l_return_status,
    				x_msg_count		=> l_msg_count,
    				x_msg_data		=> l_msg_data,
    				p_aqev_rec		=> l_aqev_rec,
    				p_aqmv_tbl 		=> l_aqmv_tbl,
    				x_aqev_rec		=> x_aqev_rec,
   			 	x_aqmv_tbl 		=> x_aqmv_tbl);
			IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      				RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    			ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      				RAISE OKC_API.G_EXCEPTION_ERROR;
			ELSIF l_return_status = OKC_API.G_RET_STS_SUCCESS  THEN
		          l_commit := 'T';
			END IF;
	END IF;
		IF  l_commit = 'T' THEN
		  IF proc_notfound <> 0 THEN
		  -- if ORA-06508 is found in the msg stack stop the listeners
		    OKC_AQ_PVT.stop_listener;
		  END IF;
			commit;
		END IF;
		OKC_API.END_ACTIVITY(l_msg_count, l_msg_data);
  EXCEPTION
   WHEN OKC_API.G_EXCEPTION_ERROR THEN
      		l_return_status := OKC_API.HANDLE_EXCEPTIONS
      		(
        	l_api_name,
        	G_PKG_NAME,
        	'OKC_API.G_RET_STS_ERROR',
        	l_msg_count,
        	l_msg_data,
        	'_PVT'
      		);

    	WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      		l_return_status := OKC_API.HANDLE_EXCEPTIONS
      		(
        	l_api_name,
        	G_PKG_NAME,
        	'OKC_API.G_RET_STS_UNEXP_ERROR',
        	l_msg_count,
        	l_msg_data,
        	'_PVT'
      		);

    	WHEN OTHERS THEN
      		l_return_status := OKC_API.HANDLE_EXCEPTIONS
      		(
        	l_api_name,
        	G_PKG_NAME,
        	'OTHERS',
        	l_msg_count,
        	l_msg_data,
        	'_PVT'
      		);
    END WRITE_MSGDATA;

    -- Start of comments
    -- Procedure Name  : update_error
    -- Description     : updates records in tables okc_aqerrors and okc_aqmsgstacks
    -- Version         : 1.0
    -- End of comments
    PROCEDURE UPDATE_ERROR(p_api_version   IN NUMBER,
				   p_init_msg_list IN VARCHAR2 ,
				   p_id		   IN NUMBER,
				   p_aqe_id        IN NUMBER,
				   p_msg_seq_no    IN NUMBER,
				   p_source_name   IN VARCHAR2,
				   p_datetime	   IN DATE,
				   p_q_name	   IN VARCHAR2 ,
				   p_msgid         IN RAW ,
			           p_message_no	   IN NUMBER,
				   p_message_name  IN VARCHAR2,
				   p_message_text  IN VARCHAR2,
				   x_msg_count	   OUT NOCOPY NUMBER,
				   x_msg_data	   OUT NOCOPY VARCHAR2,
				   x_return_status OUT NOCOPY VARCHAR2) IS
    BEGIN
	NULL;
    END UPDATE_ERROR;

    -- Start of comments
    -- Procedure Name  : write_msgdata
    -- Description     : Deletes records from tables okc_aqerrors and okc_aqmsgstacks
    -- Version         : 1.0
    -- End of comments
    PROCEDURE DELETE_ERROR(p_api_version   IN NUMBER,
				   p_init_msg_list IN VARCHAR2 ,
				   p_id 	   IN NUMBER,
				   x_msg_count	   OUT NOCOPY NUMBER,
				   x_msg_data	   OUT NOCOPY VARCHAR2,
				   x_return_status OUT NOCOPY VARCHAR2) IS
    BEGIN
	NULL;
    END DELETE_ERROR;

   PROCEDURE get_clob_msg(p_msg_tab       IN OKC_AQ_PVT.msg_tab_typ,
		          p_q_name        IN VARCHAR2,
			  p_corrid        IN VARCHAR2,
                          p_msg_clob      OUT NOCOPY CLOB,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count     OUT NOCOPY VARCHAR2,
			  x_msg_data      OUT NOCOPY VARCHAR2) IS

   	l_msg_clob	CLOB:=EMPTY_CLOB();
	l_msg_string	VARCHAR2(32767);
	i		NUMBER := 0;
	ctr		NUMBER := 0;
	l_action_name   okc_actions_tl.name%TYPE;
	l_api_name      CONSTANT VARCHAR2(30) := 'get_clob_msg';
	l_return_status	    	VARCHAR2(1);

	Cursor action_csr(p_corrid IN VARCHAR2) is
	select name
	from okc_actions_v
	where correlation = p_corrid;
   BEGIN
      -- Standard START OF API SAVEPOINT
      DBMS_TRANSACTION.SAVEPOINT(l_api_name || '_PVT');

     --Initialize return status
	l_return_status := OKC_API.G_RET_STS_SUCCESS;

      IF p_q_name = 'Events Queue' THEN
	IF p_msg_tab.COUNT > 0 THEN
     		i := p_msg_tab.FIRST;
		l_msg_string := p_msg_tab(i).element_name||'='||p_msg_tab(i).element_value;
		i := p_msg_tab.FIRST + 1;
      	  LOOP
		l_msg_string := l_msg_string||','||p_msg_tab(i).element_name||'='||p_msg_tab(i).element_value;
            EXIT WHEN (i = p_msg_tab.LAST);
            i := p_msg_tab.NEXT(i);
         END LOOP;
	END IF;

	--Fetch the action name for a specific correlation
	OPEN action_csr(p_corrid);
	FETCH action_csr INTO l_action_name;
	CLOSE action_csr;

	--Append the action name to the string
	l_msg_string := l_action_name||','||l_msg_string;
    ELSIF p_q_name = 'Outcome Queue' THEN
	IF p_msg_tab.COUNT > 0 THEN
		i := p_msg_tab.FIRST;
		l_msg_string := p_msg_tab(i).element_value;
     		i := p_msg_tab.NEXT(i);
		l_msg_string := l_msg_string ||'('||p_msg_tab(i).element_value;
		i := p_msg_tab.NEXT(i);
		l_msg_string := l_msg_string ||' '||p_msg_tab(i).element_value;
		i := p_msg_tab.NEXT(i);
		l_msg_string := l_msg_string ||' '||p_msg_tab(i).element_value;
		i := p_msg_tab.NEXT(i);
      	  LOOP
		l_msg_string := l_msg_string||', '||p_msg_tab(i).element_value;
		i := p_msg_tab.NEXT(i);
		l_msg_string := l_msg_string||' '||p_msg_tab(i).element_value;
		i := p_msg_tab.NEXT(i);
		l_msg_string := l_msg_string||' '||p_msg_tab(i).element_value;
            EXIT WHEN (i = p_msg_tab.LAST);
            i := p_msg_tab.NEXT(i);
         END LOOP;
		l_msg_string := l_msg_string ||')';
	END IF;
    ELSE
	l_return_status := OKC_API.G_RET_STS_ERROR;
      	RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

	--Build the clob
	DBMS_LOB.CREATETEMPORARY(l_msg_clob,TRUE, DBMS_LOB.SESSION);
	DBMS_LOB.OPEN (l_msg_clob, DBMS_LOB.LOB_READWRITE);
	 ctr := LENGTH(l_msg_string);
      	DBMS_LOB.WRITE(l_msg_clob, ctr, 1, l_msg_string);
	DBMS_LOB.CLOSE(l_msg_clob);
	p_msg_clob := l_msg_clob;

	OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
    EXCEPTION
	WHEN OKC_API.G_EXCEPTION_ERROR THEN
      		l_return_status := OKC_API.HANDLE_EXCEPTIONS
      		(
        	l_api_name,
        	G_PKG_NAME,
        	'OKC_API.G_RET_STS_ERROR',
        	x_msg_count,
        	x_msg_data,
        	'_PVT'
      		);

    	WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      		l_return_status := OKC_API.HANDLE_EXCEPTIONS
      		(
        	l_api_name,
        	G_PKG_NAME,
        	'OKC_API.G_RET_STS_UNEXP_ERROR',
        	x_msg_count,
        	x_msg_data,
        	'_PVT'
      		);

    	WHEN OTHERS THEN
      		l_return_status := OKC_API.HANDLE_EXCEPTIONS
      		(
        	l_api_name,
        	G_PKG_NAME,
        	'OTHERS',
        	x_msg_count,
        	x_msg_data,
        	'_PVT'
      		);
  END get_clob_msg;
end OKC_AQ_WRITE_ERROR_PVT;

/
