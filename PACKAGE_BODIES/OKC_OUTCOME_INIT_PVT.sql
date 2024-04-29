--------------------------------------------------------
--  DDL for Package Body OKC_OUTCOME_INIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_OUTCOME_INIT_PVT" AS
/* $Header: OKCROCEB.pls 120.1 2005/12/14 22:18:30 npalepu noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

--
-- Package Variables
--



  -- Start of comments
  -- Procedure Name  : Launch outcome
  -- Description     : Executes a plsql procedure or launches a workflow
  -- Version         : 1.0
  -- End of comments
  PROCEDURE Launch_outcome(p_api_version 	IN NUMBER,
			   p_init_msg_list	IN VARCHAR2  ,
			   p_corrid_rec   	IN corrid_rec_typ,
			   p_msg_tab_typ      	IN  msg_tab_typ,
			   x_msg_count    	OUT NOCOPY NUMBER,
			   x_msg_data         	OUT NOCOPY VARCHAR2,
		           x_return_status      OUT NOCOPY VARCHAR2) IS

	l_outcome_tbl		p_outcometbl_type;
	ctr			NUMBER := 0;
	ctr_wf			NUMBER := 0;
	l_outcome_name		VARCHAR2(200);
	l_api_name              CONSTANT VARCHAR2(30) := 'launch_outcome';
	l_api_version           NUMBER := 1.0;
        l_init_msg_list	        VARCHAR2(10)  := FND_API.G_TRUE;
	l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	v_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	l_msg_count		NUMBER;
	l_msg_data		VARCHAR2(240);
	l_proc                  VARCHAR2(4000);
        --NPALEPU
        --14-DEC-2005
        --bug # 4699009
        l_proc_name             VARCHAR2(4000);
        l_wf_proc_name             VARCHAR2(4000);
        l_plsql_proc_name             VARCHAR2(4000);
        --END NPALEPU
	l_plsql_proc            VARCHAR2(4000);
	l_wf_proc               VARCHAR2(4000);
	prof_s_recipient           VARCHAR2(100);
	prof_e_recipient           VARCHAR2(100);
	l_s_recipient           VARCHAR2(100);
	l_e_recipient           VARCHAR2(100);
	l_oce_id                NUMBER;
	l_contract_id                NUMBER;

	CURSOR profile_cur1 IS
	SELECT opval.profile_option_value profile_value
	FROM   fnd_profile_options op,
	       fnd_profile_option_values opval
	WHERE  op.profile_option_id = opval.profile_option_id
	AND    op.application_id    = opval.application_id
	AND    op.profile_option_name = 'OKC_S_RECIPIENT';
	profile_rec1  profile_cur1%ROWTYPE;

	CURSOR profile_cur2 IS
	SELECT opval.profile_option_value profile_value
	FROM   fnd_profile_options op,
	       fnd_profile_option_values opval
	WHERE  op.profile_option_id = opval.profile_option_id
	AND    op.application_id    = opval.application_id
	AND    op.profile_option_name = 'OKC_E_RECIPIENT';
	profile_rec2  profile_cur2%ROWTYPE;

	CURSOR success_user_cur(x IN NUMBER)
	IS
	SELECT f.user_name success_user
	FROM   jtf_rs_resource_extns r,
	       okc_outcomes_v  o,
	       fnd_user f
        WHERE  f.user_id = r.user_id
	AND    o.success_resource_id = r.resource_id
	AND    r.category = 'EMPLOYEE'
	AND    o.id = x;
	success_user_rec  success_user_cur%ROWTYPE;

	CURSOR failure_user_cur(x IN NUMBER)
	IS
	SELECT f.user_name failure_user
	FROM   jtf_rs_resource_extns r,
	       okc_outcomes_v  o,
	       fnd_user f
        WHERE  f.user_id = r.user_id
	AND    o.failure_resource_id = r.resource_id
	AND    r.category = 'EMPLOYEE'
	AND    o.id = x;
	failure_user_rec  failure_user_cur%ROWTYPE;

   --
   l_proc_n varchar2(72) := ' OKC_OUTCOME_INIT_PVT.'||'Launch_outcome';
   --

  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc_n);
     okc_debug.Log('10: Entering ',2);
  END IF;

	l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                  G_PKG_NAME,
                                                  l_init_msg_list,
                                                  l_api_version,
                                                  p_api_version,
                                                  G_LEVEL,
                                                  x_return_status);
	IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  	ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    		RAISE OKC_API.G_EXCEPTION_ERROR;
  	END IF;

        -- populate profile option values for success and error message recipients
        OPEN profile_cur1;
        FETCH profile_cur1 INTO profile_rec1;
	  prof_s_recipient := profile_rec1.profile_value;
	CLOSE profile_cur1;

        OPEN profile_cur2;
        FETCH profile_cur2 INTO profile_rec2;
	  prof_e_recipient := profile_rec2.profile_value;
	CLOSE profile_cur2;

	--Populate the Table with name, data_type and value
	IF p_msg_tab_typ.COUNT > 0 THEN
		ctr := p_msg_tab_typ.FIRST;
		-- Contract id is the first record, save it in a variable
		l_contract_id  :=  p_msg_tab_typ(ctr).element_value;
		ctr 	  := p_msg_tab_typ.FIRST + 1;
		-- Outcome id is the second record, save it in a variable
		l_oce_id  :=  p_msg_tab_typ(ctr).element_value;
		ctr 	  := p_msg_tab_typ.FIRST + 2;
		--The outcome name is Package.Procedure name
		l_outcome_name  := p_msg_tab_typ(ctr).element_value;
		ctr 		:= p_msg_tab_typ.NEXT(ctr);
	   LOOP
		ctr_wf := ctr_wf + 1;
		l_outcome_tbl(ctr_wf).name := p_msg_tab_typ(ctr).element_value;
		EXIT when (ctr = p_msg_tab_typ.LAST);
		ctr := p_msg_tab_typ.NEXT(ctr);
		l_outcome_tbl(ctr_wf).data_type := p_msg_tab_typ(ctr).element_value;
		EXIT when (ctr = p_msg_tab_typ.LAST);
		ctr := p_msg_tab_typ.NEXT(ctr);
		l_outcome_tbl(ctr_wf).value := p_msg_tab_typ(ctr).element_value;
	        EXIT when (ctr = p_msg_tab_typ.LAST);
	        ctr := p_msg_tab_typ.NEXT(ctr);
	   END LOOP;
	END IF;

	-- populate resource names for success and error recipients
        OPEN success_user_cur(l_oce_id);
        FETCH success_user_cur INTO success_user_rec;
	  l_s_recipient := success_user_rec.success_user;
	CLOSE success_user_cur;

        OPEN failure_user_cur(l_oce_id);
        FETCH failure_user_cur INTO failure_user_rec;
	  l_e_recipient := failure_user_rec.failure_user;
	CLOSE failure_user_cur;

	-- assign values to recipients
	l_s_recipient := NVL(l_s_recipient,prof_s_recipient);
	l_e_recipient := NVL(l_e_recipient,prof_e_recipient);

	--Check the correlation
	IF p_corrid_rec.corrid NOT IN ('PPS', 'WPS') THEN
		OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            	    p_msg_name     => G_INVALID_VALUE,
				    p_token1       => g_col_name_token,
				    p_token1_value => 'p_corrid_rec');
		raise OKC_API.G_EXCEPTION_ERROR;
	ELSIF p_corrid_rec.corrid = 'PPS' THEN
		--Create a plsql procedure
		Launch_plsql(p_api_version	=> p_api_version,
			     p_init_msg_list    => p_init_msg_list,
			     p_outcome_name	=> l_outcome_name,
			     p_outcome_tbl      => l_outcome_tbl,
			     x_proc             => l_plsql_proc,
                             --NPALEPU
                             --14-DEC-2005
                             --BUG # 4699009
                             x_proc_name        => l_plsql_proc_name,
                             --END NPALEPU
			     x_msg_count        => l_msg_count,
			     x_msg_data         => l_msg_data,
			     x_return_status    => l_return_status);
	   IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       		raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     	   ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       		raise OKC_API.G_EXCEPTION_ERROR;
     	   END IF;

	ELSIF p_corrid_rec.corrid = 'WPS' THEN
		--a workflow
		Launch_workflow(p_api_version	   => p_api_version,
			        p_init_msg_list    => p_init_msg_list,
				p_outcome_name	   => l_outcome_name,
			        p_outcome_tbl      => l_outcome_tbl,
			        x_proc             => l_wf_proc,
                                --NPALEPU
                                --14-DEC-2005
                                --BUG # 4699009
                                x_proc_name        => l_wf_proc_name,
                                --END NPALEPU
			        x_msg_count        => l_msg_count,
			        x_msg_data         => l_msg_data,
				x_return_status    => l_return_status);
	  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       		raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     	  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       		raise OKC_API.G_EXCEPTION_ERROR;
     	  END IF;
	END IF;

	  IF l_plsql_proc IS NOT NULL THEN
	    l_proc := l_plsql_proc;
            --NPALEPU
            --14-DEC-2005
            --BUG # 4699009
            l_proc_name := l_plsql_proc_name ;
            --END NPALEPU
	  ELSIF l_wf_proc IS NOT NULL THEN
	    l_proc := l_wf_proc;
            --NPALEPU
            --14-DEC-2005
            --BUG # 4699009
            l_proc_name := l_wf_proc_name;
            --END NPALEPU
          END IF;

	  -- Build executable to pass to generic workflow and attach message to show
	  -- Notification subject.
		l_proc := 'Begin declare V_MSG_COUNT  NUMBER; V_MSG_DATA VARCHAR2(2000); '
		||l_proc||'  end;';


	  -- Call generic workflow process to launch all types of outcomes and pass the executable string
      -- bug#4014546 changed p_loops to 2 from 100
         OKC_ASYNC_PUB.loop_call( p_api_version    =>  l_api_version
                                      ,x_return_status  =>  l_return_status
                                      ,x_msg_count      =>  l_msg_count
                                      ,x_msg_data       =>  l_msg_data
                                      ,p_proc           =>  l_proc
                                      --NPALEPU
                                      --14-DEC-2005
                                      --BUG # 4699009
                                      ,p_proc_name      =>  l_proc_name
                                      --END NPALEPU
                                      ,p_s_recipient    =>  l_s_recipient
                                      ,p_e_recipient    =>  l_e_recipient
                                      ,p_contract_id    =>  l_contract_id
                                      ,p_loops          =>  2
                                      ,p_subj_first_msg =>  'F'
                                      );
       OKC_API.END_ACTIVITY(l_msg_count, l_msg_data);

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        l_msg_count,
        l_msg_data,
        G_LEVEL);
        IF (l_debug = 'Y') THEN
           okc_debug.Log('2000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        l_msg_count,
        l_msg_data,
        G_LEVEL);
        IF (l_debug = 'Y') THEN
           okc_debug.Log('3000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        l_msg_count,
        l_msg_data,
        G_LEVEL);
        IF (l_debug = 'Y') THEN
           okc_debug.Log('4000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;
  END launch_outcome;

  -- Start of comments
  -- Procedure Name  : launch_plsql
  -- Description     : Executes a plsql procedure
  -- Version         : 1.0
  -- End of comments
  PROCEDURE Launch_plsql(p_api_version 	 IN NUMBER,
			 p_init_msg_list IN VARCHAR2  ,
			 p_outcome_name  IN VARCHAR2,
			 p_outcome_tbl   IN p_outcometbl_type,
			 x_proc          OUT NOCOPY VARCHAR2,
                         --NPALEPU
                         --14-DEC-2005
                         --BUG # 4699009
                         x_proc_name     OUT NOCOPY VARCHAR2,
                         --END NPALEPU
			 x_msg_count     OUT NOCOPY NUMBER,
			 x_msg_data      OUT NOCOPY VARCHAR2,
			 x_return_status OUT NOCOPY VARCHAR2) IS

	l_api_name              CONSTANT VARCHAR2(30) := 'launch_plsql';
	l_api_version           CONSTANT NUMBER := 1.0;
	l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	v_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    	v_msg_count		NUMBER;
    	v_msg_data		VARCHAR2(2000);
        plsql_block		VARCHAR2(4000);
	l_error_exception  	EXCEPTION;
	var2			VARCHAR2(100);
	i			NUMBER;
	l_pack_proc		VARCHAR2(4000);
	l_std_params		VARCHAR2(500);
	l_data_type		VARCHAR2(40);
    l_outcome_tbl		p_outcometbl_type;
    ctr    NUMBER := 0;
   --
   l_proc_n varchar2(72) := ' OKC_OUTCOME_INIT_PVT.'||'Launch_plsql';
   --
   --NPALEPU
   --14-DEC-2005
   --For Bug # 4699009
   CURSOR l_proc_name_csr(l_procedure_name VARCHAR2,l_package_name VARCHAR2)  is
   SELECT NAME
   FROM OKC_PROCESS_DEFS_V
   WHERE PROCEDURE_NAME = l_procedure_name
   AND PACKAGE_NAME = l_package_name;

   l_proc_name          VARCHAR2(4000);
   l_package_name       VARCHAR2(4000);
   l_procedure_name     VARCHAR2(4000);

   --END NPALEPU

  BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc_n);
     okc_debug.Log('10: Entering ',2);
  END IF;

	l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                  G_PKG_NAME,
                                                  p_init_msg_list,
                                                  l_api_version,
                                                  p_api_version,
                                                  G_LEVEL,
                                                  x_return_status);
	IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  	ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    		RAISE OKC_API.G_EXCEPTION_ERROR;
  	END IF;

        --NPALEPU
        --14-DEC-2005
        --Bug # 4699009
        --Package name
        l_package_name     := substr(p_outcome_name, 1, instr(p_outcome_name, '.', 1) - 1);
        --Procedure name
        l_procedure_name   := substr(p_outcome_name, instr(p_outcome_name , '.') + 1);

        IF l_package_name IS NOT NULL OR l_procedure_name IS NOT NULL THEN
           BEGIN
              OPEN l_proc_name_csr(l_procedure_name,l_package_name);
              FETCH l_proc_name_csr into l_proc_name;
              CLOSE l_proc_name_csr;
              x_proc_name := l_proc_name;
           EXCEPTION
              WHEN OTHERS THEN
                 x_proc_name := NULL;
           END;
        END IF;
        --END NPALEPU
/*
-- below commented out by marat (bug#2477385)
        --Build the plsql string
	IF p_outcome_tbl.COUNT > 0 THEN
	   i := p_outcome_tbl.FIRST;
	   l_data_type := p_outcome_tbl(i).data_type;

	   IF (l_data_type IN ('DATE', 'CHAR') AND p_outcome_tbl(i).name
	       NOT IN ('X_RETURN_STATUS', 'X_MSG_DATA', 'P_INIT_MSG_LIST')) THEN
		 IF UPPER(p_outcome_tbl(i).value) NOT IN ('OKC_API.G_MISS_CHAR','OKC_API.G_MISS_DATE','NULL') THEN
	            l_pack_proc := p_outcome_name || '('||p_outcome_tbl(i).name||
	                           ' => '||''''||p_outcome_tbl(i).value||'''';
		 ELSIF UPPER(p_outcome_tbl(i).value) IN ('OKC_API.G_MISS_CHAR','OKC_API.G_MISS_DATE','NULL') THEN
	            l_pack_proc := p_outcome_name || '('||p_outcome_tbl(i).name||
	                           ' => '||p_outcome_tbl(i).value;
                 END IF;

	   ELSIF (l_data_type IN ('DATE', 'CHAR') AND p_outcome_tbl(i).name
		  IN ('X_RETURN_STATUS', 'X_MSG_DATA', 'P_INIT_MSG_LIST')) THEN
	 		null;
	   ELSIF (l_data_type = 'NUMBER') AND (p_outcome_tbl(i).name <> 'X_MSG_COUNT') THEN
	      l_pack_proc := p_outcome_name ||
	      '('||p_outcome_tbl(i).name||' => '||p_outcome_tbl(i).value;

	   ELSIF (l_data_type = 'NUMBER') AND (p_outcome_tbl(i).name = 'X_MSG_COUNT') THEN
	      		null;
	   ELSE
		OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            	    p_msg_name     => G_INVALID_VALUE,
				    p_token1       => g_col_name_token,
				    p_token1_value => 'datatype');
		raise OKC_API.G_EXCEPTION_ERROR;
	   END IF;

   IF p_outcome_tbl.COUNT > 1 THEN

	   i := p_outcome_tbl.FIRST + 1;

	   LOOP
	       l_data_type := p_outcome_tbl(i).data_type;
	      IF (l_data_type IN ('DATE', 'CHAR') AND p_outcome_tbl(i).name
		  NOT IN ('X_RETURN_STATUS', 'X_MSG_DATA', 'P_INIT_MSG_LIST')) THEN
		    IF UPPER(p_outcome_tbl(i).value) NOT IN ('OKC_API.G_MISS_CHAR','OKC_API.G_MISS_DATE','NULL') THEN
	      	      l_pack_proc := l_pack_proc||', '||p_outcome_tbl(i).name||
		                     ' => '||''''||p_outcome_tbl(i).value||'''';
		    ELSIF UPPER(p_outcome_tbl(i).value) IN ('OKC_API.G_MISS_CHAR','OKC_API.G_MISS_DATE','NULL') THEN
	      	      l_pack_proc := l_pack_proc||', '||p_outcome_tbl(i).name||
		                     ' => '||p_outcome_tbl(i).value;
                    END IF;

	      ELSIF (l_data_type IN ('DATE', 'CHAR') AND p_outcome_tbl(i).name
		     IN ('X_RETURN_STATUS', 'X_MSG_DATA', 'P_INIT_MSG_LIST')) THEN
			null;

	      ELSIF (l_data_type = 'NUMBER') AND (p_outcome_tbl(i).name <>'X_MSG_COUNT')THEN
		     l_pack_proc := l_pack_proc ||', '||
		     p_outcome_tbl(i).name||' => '||p_outcome_tbl(i).value;

	      ELSIF (l_data_type = 'NUMBER') AND (p_outcome_tbl(i).name = 'X_MSG_COUNT') THEN
	      		null;
              ELSE
		OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            	    p_msg_name     => G_INVALID_VALUE,
				    p_token1       => g_col_name_token,
				    p_token1_value => 'datatype');
		raise OKC_API.G_EXCEPTION_ERROR;
	      END IF;
	      EXIT WHEN (i = p_outcome_tbl.LAST);
	      i := p_outcome_tbl.NEXT(i);
	   END LOOP;
    END IF;
	END IF;

	--Append all the standard parameters
	l_std_params := 'P_INIT_MSG_LIST => OKC_API.G_FALSE, X_RETURN_STATUS => :V_RETURN_STATUS,'||
	'X_MSG_COUNT => V_MSG_COUNT, X_MSG_DATA => V_MSG_DATA)';
	--Build the plsql string
	l_pack_proc := l_pack_proc ||', '||l_std_params;

	--Build the plsql block
      	plsql_block := 'Begin ' ||l_pack_proc||'; End;';

	-- assign the executable string to out parameter
        x_proc := plsql_block;
-- above commented out by marat (bug#2477385)
*/

-- added by pnayani bug#2778651 - start
-- Removing standard params from the table and pass it to okc_wf package to build outcome
    for i in p_outcome_tbl.FIRST..p_outcome_tbl.LAST loop

        IF (p_outcome_tbl(i).name NOT IN
            ('X_RETURN_STATUS', 'X_MSG_DATA','X_MSG_COUNT','P_INIT_MSG_LIST')) THEN

        ctr := ctr + 1;
        l_outcome_tbl(ctr).name := p_outcome_tbl(i).name;
        l_outcome_tbl(ctr).data_type := p_outcome_tbl(i).data_type;
        l_outcome_tbl(ctr).value := p_outcome_tbl(i).value;

        END IF;

    end loop;

-- added by pnayani bug#2778651 - end


-- added by marat - start  (bug#2477385) - replacement for the above
    l_pack_proc:=okc_wf.build_wf_plsql
                (okc_wf.prebuild_wf_plsql
                (okc_wf.build_wf_string(    p_outcome_name,
                                            l_outcome_tbl
                                            )));
    if l_pack_proc is null then
	    OKC_API.SET_MESSAGE(   p_app_name => G_APP_NAME,
                              p_msg_name => G_INVALID_VALUE,
			    	               p_token1   => g_col_name_token,
				                  p_token1_value => 'datatype');
	    raise OKC_API.G_EXCEPTION_ERROR;
    end if;
    x_proc:=l_pack_proc;
-- added by marat - end    (bug#2477385)

	OKC_API.END_ACTIVITY(v_msg_count, v_msg_data);


  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

  Exception
       WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        v_msg_count,
        v_msg_data,
        G_LEVEL);
        IF (l_debug = 'Y') THEN
           okc_debug.Log('2000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        v_msg_count,
        v_msg_data,
        G_LEVEL);
        IF (l_debug = 'Y') THEN
           okc_debug.Log('3000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        v_msg_count,
        v_msg_data,
        G_LEVEL);
        IF (l_debug = 'Y') THEN
           okc_debug.Log('4000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;
  End Launch_plsql;

  -- Start of comments
  -- Procedure Name  : launch_workflow
  -- Description     : Launches a workflow
  -- Version         : 1.0
  -- End of comments
  PROCEDURE Launch_workflow(p_api_version   IN NUMBER,
			    p_init_msg_list IN VARCHAR2  ,
			    p_outcome_name  IN VARCHAR2,
			    p_outcome_tbl   IN  p_outcometbl_type,
			    x_proc          OUT NOCOPY VARCHAR2,
                            --NPALEPU
                            --14-DEC-2005
                            --BUG # 4699009
                            x_proc_name     OUT NOCOPY VARCHAR2,
                            --END NPALEPU
			    x_msg_count     OUT NOCOPY NUMBER,
			    x_msg_data      OUT NOCOPY VARCHAR2,
			    x_return_status OUT NOCOPY VARCHAR2) IS

	l_api_name	  	CONSTANT VARCHAR2(30) := 'Launch_workflow';
	l_api_version           CONSTANT NUMBER := 1.0;
	l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  	l_item_type 		VARCHAR2(100);
  	l_item_key  		VARCHAR2(100);
  	l_process   		VARCHAR2(100);
  	l_wf_proc   		VARCHAR2(4000);
        l_error_exception  	EXCEPTION;
	l_dummy			VARCHAR2(1);
    	l_end_date		DATE;
    	l_result		VARCHAR2(1);
	i			NUMBER := 0;
   --
   l_proc_n varchar2(72) := ' OKC_OUTCOME_INIT_PVT.'||'Launch_workflow';
   --
   --NPALEPU
   --14-DEC-2005
   --For Bug # 4699009
   CURSOR l_proc_name_csr(l_wf_name VARCHAR2,l_wf_process_name VARCHAR2)  is
   SELECT NAME
   FROM OKC_PROCESS_DEFS_V
   WHERE WF_NAME=l_wf_name
   AND WF_PROCESS_NAME = l_wf_process_name;

   l_proc_name VARCHAR2(4000);
   --END NPALEPU

  Begin

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc_n);
     okc_debug.Log('10: Entering ',2);
  END IF;

	l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                                  G_PKG_NAME,
                                                  p_init_msg_list,
                                                  l_api_version,
                                                  p_api_version,
                                                  G_LEVEL,
                                                  x_return_status);
	IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  	ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    		RAISE OKC_API.G_EXCEPTION_ERROR;
  	END IF;

	--Workflow name
	l_item_type 	:= substr(p_outcome_name, 1, instr(p_outcome_name, '.', 1) - 1);
	--Workflow Process name
	l_process 	:= substr(p_outcome_name, instr(p_outcome_name , '.') + 1);
	IF l_item_type IS NULL OR l_process IS NULL THEN
		OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            	    p_msg_name     => G_PROCESS_NOTFOUND,
				    p_token1       => g_wf_name_token,
				    p_token1_value => l_item_type,
				    p_token2	   => G_WF_P_NAME_TOKEN,
				    p_token2_value => l_process);
		RAISE OKC_API.G_EXCEPTION_ERROR;
	END IF;

        --NPALEPU
        --14-DEC-2005
        --Bug # 4699009
        BEGIN
           OPEN l_proc_name_csr(l_item_type,l_process);
           FETCH l_proc_name_csr into l_proc_name;
           CLOSE l_proc_name_csr;
           x_proc_name := l_proc_name;
        EXCEPTION
           WHEN OTHERS THEN
              x_proc_name := NULL;
        END;
        --END NPALEPU

	--Select the sequence number into l_item_key
	select okc_wf_outcome_s1.nextval into l_item_key from dual;

	--Launch the Workflow process
	WF_ENGINE.CREATEPROCESS(l_item_type, l_item_key, l_process);

	IF (p_outcome_tbl.COUNT > 0) THEN
		i := p_outcome_tbl.FIRST;
	   LOOP
		--Set the item attributes
		if p_outcome_tbl(i).data_type = 'CHAR' then
			WF_ENGINE.Setitemattrtext(itemtype => l_item_type,
						  itemkey  => l_item_key,
						  aname    => p_outcome_tbl(i).name,
						  avalue   => p_outcome_tbl(i).value);
		end if;

		if p_outcome_tbl(i).data_type = 'NUMBER' then
			WF_ENGINE.Setitemattrnumber(itemtype => l_item_type,
						    itemkey  => l_item_key,
						    aname    => p_outcome_tbl(i).name,
						    avalue   => p_outcome_tbl(i).value);
		end if;

		if p_outcome_tbl(i).data_type = 'DATE' then
			WF_ENGINE.Setitemattrdate(itemtype => l_item_type,
						  itemkey  => l_item_key,
						  aname    => p_outcome_tbl(i).name,
						  avalue   => p_outcome_tbl(i).value);
		end if;
	        EXIT WHEN (i = p_outcome_tbl.LAST);
		i := p_outcome_tbl.NEXT(i);
	   END LOOP;
	END IF;
	commit;
	l_wf_proc := 'begin WF_ENGINE.STARTPROCESS('||''''||l_item_type||''''||','||''''||l_item_key||''''||'); end;';
	x_proc := l_wf_proc;
	OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

  Exception
	WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
        IF (l_debug = 'Y') THEN
           okc_debug.Log('2000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
        IF (l_debug = 'Y') THEN
           okc_debug.Log('3000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_LEVEL);
        IF (l_debug = 'Y') THEN
           okc_debug.Log('4000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;
  End Launch_workflow;


  End OKC_OUTCOME_INIT_PVT;

/
