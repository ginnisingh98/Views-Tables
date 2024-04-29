--------------------------------------------------------
--  DDL for Package Body OKC_QA_CHECK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_QA_CHECK_PVT" AS
/* $Header: OKCRQACB.pls 120.2.12010000.2 2009/05/07 05:51:07 spingali ship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  -- Start of comments
  --
  -- Procedure Name  : validate_qcl_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_qcl_id(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_qcl_id        IN    NUMBER
  ) IS
    l_dummy_var   VARCHAR2(1) := '?';
    CURSOR l_qclv_csr IS
      SELECT 'x'
        FROM OKC_QA_CHECK_LISTS_B qclv
       WHERE qclv.ID = p_qcl_id;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_qcl_id = OKC_API.G_MISS_NUM OR
        p_qcl_id IS NULL) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_REQUIRED_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'qcl_id');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- enforce foreign key
    OPEN  l_qclv_csr;
    FETCH l_qclv_csr INTO l_dummy_var;
    CLOSE l_qclv_csr;

    -- if l_dummy_var still set to default, data was not found
    IF (l_dummy_var = '?') THEN
      OKC_API.set_message(
        p_app_name      => G_APP_NAME,
        p_msg_name      => G_INVALID_VALUE,
        p_token1        => G_COL_NAME_TOKEN,
        p_token1_value  => 'qcl_id');
      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_qclv_csr%ISOPEN THEN
      CLOSE l_qclv_csr;
    END IF;
  END validate_qcl_id;
--
  -- Start of comments
  --
  -- Procedure Name  : execute_qa_check_list
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE execute_qa_check_list(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcl_id                       IN  NUMBER,
    p_chr_id                       IN  NUMBER,
    p_override_flag                IN  VARCHAR2 ,
    x_msg_tbl                      OUT NOCOPY msg_tbl_type) IS

   l_api_name CONSTANT VARCHAR2(30) := 'execute_qa_check_list';

   e_msg_tbl msg_tbl_type; -- ERROR table
   w_msg_tbl msg_tbl_type; -- WARNING table
   s_msg_tbl msg_tbl_type; -- SUCCESS table
   tot_msg_count NUMBER := 0;
   l_tot_err_count NUMBER := 0;
   l_tot_wrn_count NUMBER := 0;
   l_tot_suc_count NUMBER := 0;
   i  pls_integer;
   j  pls_integer;
   k  pls_integer;
   -- New variable introduces for backward compatibility.
   -- Used in the 2nd select statement below to retain the
   -- logic of OKS qa checks. Should be removed later when
   -- oks seed their processes for qa checks.
   qa_phase2_release Varchar2(1) := 'N';

  CURSOR l_scs_csr IS
    SELECT scs.cls_code,
           chr.application_id
      FROM OKC_SUBCLASSES_B scs,
           OKC_K_HEADERS_B chr
     WHERE scs.code = chr.scs_code
       AND chr.id   = p_chr_id;
  l_cls_code OKC_SUBCLASSES_B.CLS_CODE%TYPE;
  l_appl_id OKC_K_HEADERS_B.APPLICATION_ID%TYPE;

  -- cursor for the list of processes to be executed
  CURSOR l_qlp_csr IS
    select 1, pdf.name, pdf.description,
           pdf.package_name, pdf.procedure_name, qlp.pdf_id,
           qlp.run_sequence, qlp.severity
      from OKC_PROCESS_DEFS_V pdf,
           OKC_QA_LIST_PROCESSES qlp
           -- OKC_QA_CHECK_LISTS_TL qcl
     where pdf.id        = qlp.pdf_id
       and sysdate between pdf.begin_date and nvl(pdf.end_date,sysdate)
       and qlp.active_yn = 'Y'
       and qlp.qcl_id    = 1
       and  ((application_id = l_appl_id AND PDF.PROCEDURE_NAME <> 'CHECK_ADDRESS') OR
                application_id <> l_appl_id )    /*Bug 7447222*/

       -- and qlp.qcl_id    = qcl.id
       -- and qcl.name      = G_DEFAULT_QA_CHECK_LIST
       -- and qcl.language  = userenv('LANG')

/* ******** For Bug# 3009832 ******************************
    union all
    select 2, pdf.name, pdf.description,
           pdf.package_name, pdf.procedure_name,
           -1, rownum, 'S'
      from OKC_PROCESS_DEFS_V pdf
     where pdf.package_name = 'OKS_QA_DATA_INTEGRITY'
       and l_cls_code = 'SERVICE'
       and sysdate between pdf.begin_date and nvl(pdf.end_date,sysdate)
       and p_override_flag = 'N'
       and qa_phase2_release = 'N'
*********************************************************** */
    union all
    select 3, pdf.name, pdf.description,
           pdf.package_name, pdf.procedure_name, qlp.pdf_id,
           qlp.run_sequence, qlp.severity
      from OKC_PROCESS_DEFS_V pdf,
           OKC_QA_LIST_PROCESSES qlp,
           OKC_QA_CHECK_LISTS_B qcl
           -- OKC_QA_CHECK_LISTS_v qcl
     where pdf.id = qlp.pdf_id
       and sysdate between pdf.begin_date and nvl(pdf.end_date,sysdate)
       and qlp.active_yn = 'Y'
       and qlp.qcl_id = qcl.id
       and qcl.id not in (1, p_qcl_id)
       and qcl.default_yn = 'Y'
       and qcl.application_id = l_appl_id
       and p_override_flag = 'N'
       -- and qcl.name <> G_DEFAULT_QA_CHECK_LIST
    union all
    select 4, pdf.name, pdf.description,
           pdf.package_name, pdf.procedure_name, qlp.pdf_id,
           qlp.run_sequence, qlp.severity
      from OKC_PROCESS_DEFS_V pdf,
           OKC_QA_LIST_PROCESSES qlp
           -- OKC_QA_CHECK_LISTS_TL qcl
     where pdf.id = qlp.pdf_id
       and sysdate between pdf.begin_date and nvl(pdf.end_date,sysdate)
       and qlp.active_yn = 'Y'
       and qlp.qcl_id = p_qcl_id
       and qlp.qcl_id <> 1
       -- and qlp.qcl_id = qcl.id
       -- and qcl.id = p_qcl_id
       -- and qcl.name      <> G_DEFAULT_QA_CHECK_LIST
       -- and qcl.language  = userenv('LANG')
-- Bug 2170973 ,This following query added to execute qa_pdf_id of okc_class_operations if
--  contract category has any operation of purpose 'INTEGRATION' defined in it.
    union all
     select 5, pdf.name, pdf.description, pdf.package_name, pdf.procedure_name,
            cop.qa_pdf_id,  OKC_API.G_MISS_NUM, 'S'
       from OKC_PROCESS_DEFS_V pdf,
            OKC_K_HEADERS_B khr,
            OKC_SUBCLASSES_B scs,
            OKC_CLASS_OPERATIONS  cop,
            OKC_OPERATIONS_B op,
            okc_assents_v ass
      where pdf.id = cop.qa_pdf_id
      and   sysdate between pdf.begin_date and nvl(pdf.end_date,sysdate)
      and   scs.code = khr.scs_code
      and   khr.id = p_chr_id
      and   ass.scs_code = scs.code
      and   ass.sts_code = khr.sts_code
      and   cop.opn_code = op.code
      and   cop.opn_code = ass.opn_code
      and   cop.cls_code = scs.cls_code
      and   op.purpose = 'INTEGRATION'
      and   p_override_flag = 'N'
      and   ass.allowed_YN = 'Y' --added for bug 2386576 abkumar
    order by 1, 7;
    -- order by 1, 5;

  l_qlp_rec l_qlp_csr%ROWTYPE;

  -- cursor for the parameter list for a processes
  CURSOR l_qpp_csr IS
    select pdp.name, pdp.data_type,
           REPLACE(qpp.parm_value, '''','''''') "PARM_VALUE"
      from OKC_PROCESS_DEF_PARAMETERS_V pdp,
           OKC_QA_PROCESS_PARMS_V qpp
     where pdp.id         = qpp.pdp_id
       and pdp.pdf_id     = qpp.qlp_pdf_id
       and qpp.qlp_pdf_id = l_qlp_rec.pdf_id
-- skekkar
       and qpp.qlp_run_sequence = l_qlp_rec.run_sequence
-- skekkar
       and qpp.qlp_qcl_id = p_qcl_id;

  l_qpp_rec l_qpp_csr%ROWTYPE;

  plsql_block VARCHAR2(30000);

  l_return_status VARCHAR2(1)   :=  OKC_API.G_RET_STS_SUCCESS;
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(2000);
  l_tot_msg_count NUMBER := 0;
--  Bug 2934909
  x number(1) := 1;
  l_parameter_tbl  parameter_tbl_type;
  l_cursor_id number;
  m number;
  l_dummy number;
-- End Bug 2934909
  BEGIN

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name,'Entering '|| G_PKG_NAME || '.' || l_api_name);
    END IF;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'p_qcl_id: ' || p_qcl_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'p_chr_id: ' || p_chr_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'p_override_flag: ' || p_override_flag);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    validate_qcl_id(
      x_return_status => x_return_status,
      p_qcl_id        => p_qcl_id);

    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      -- return status to caller, can not continue to process
      RETURN;
    END IF;
    --
    OPEN  l_scs_csr;
    FETCH l_scs_csr INTO l_cls_code, l_appl_id;
    CLOSE l_scs_csr;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_cls_code: ' || l_cls_code);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_appl_id: ' || l_appl_id);
    END IF;

    --anjkumar, save the context first  Bug 5609807
    okc_context.save_current_contexts;

    -- Set the org_id
    okc_context.set_okc_org_context(p_chr_id => p_chr_id);
    --

    OPEN  l_qlp_csr;
    LOOP
      FETCH l_qlp_csr INTO l_qlp_rec;
      EXIT WHEN l_qlp_csr%NOTFOUND;
      l_cursor_id := DBMS_SQL.OPEN_CURSOR;  --Bug2934909
      plsql_block := 'BEGIN ' ||
                      l_qlp_rec.package_name || '.' ||
                      l_qlp_rec.procedure_name || '( ' ||
                      'x_return_status => :l_return_status ' ||
                      ',p_chr_id  =>:p_chr_id ' ;


       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_qlp_rec.package_name: ' || l_qlp_rec.package_name);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_qlp_rec.procedure_name: ' || l_qlp_rec.procedure_name);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_qlp_rec.pdf_id: ' || l_qlp_rec.pdf_id);
       END IF;


      -- -1 means no parameters
--  Bug 2934909
      IF l_qlp_rec.pdf_id <> -1 THEN
        OPEN  l_qpp_csr;
        l_parameter_tbl.delete;
        m :=1;
        LOOP
          FETCH l_qpp_csr INTO l_qpp_rec;
          EXIT WHEN l_qpp_csr%NOTFOUND;
          plsql_block := plsql_block || ',' || l_qpp_rec.name || ' => :'||to_char(m) ;
           l_parameter_tbl(m).param_value := l_qpp_rec.parm_value;
           m := m+1;
        END LOOP;
        CLOSE l_qpp_csr;
      END IF;
-- End Bug 2934909

      plsql_block := plsql_block || ') ; END;';
--  Bug 2934909
      DBMS_SQL.PARSE(l_cursor_id,plsql_block , 2);
      DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':l_return_status',l_return_status);
      DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':p_chr_id',p_chr_id);

      If l_parameter_tbl.count > 0 then
         FOR j in l_parameter_tbl.FIRST..l_parameter_tbl.LAST LOOP
            DBMS_SQL.BIND_VARIABLE(l_cursor_id, to_char(j),l_parameter_tbl(j).param_value);
         END LOOP;
      end if;

-- End Bug 2934909
      -- clean up the message list
      fnd_msg_pub.initialize;

      l_dummy := DBMS_SQL.EXECUTE(l_cursor_id);
      dbms_Sql.variable_Value(l_cursor_id, ':l_return_status', l_return_status);

      DBMS_SQL.CLOSE_CURSOR(l_cursor_id);  --Bug 3385459

/* Bug2934909
      BEGIN
        EXECUTE IMMEDIATE plsql_block
          USING IN OUT l_return_status,IN p_chr_id;
      EXCEPTION
--   WHEN OTHERS THEN
--        -- store SQL error message on message stack
--        OKC_API.SET_MESSAGE(
--          p_app_name        => G_APP_NAME,
--          p_msg_name        => G_QA_PROCESS_ERROR);
--        -- notify caller of an error as UNEXPETED error
--        l_return_status := OKC_API.G_RET_STS_ERROR;
--      END;
--
--      -- Get error messages to return
--      -- assign message values to return
*/ -- End Bug2934909

     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'pub_qa_msg_tbl.count: ' || pub_qa_msg_tbl.count);
	END IF;

     IF pub_qa_msg_tbl.count > 0 THEN -- if QA check has populated the table, message stack is empty

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'QA check has populated the table, message stack is empty');
	 END IF;

      FOR i IN pub_qa_msg_tbl.first..pub_qa_msg_tbl.last LOOP
        IF  pub_qa_msg_tbl(i).error_status = 'E' THEN
          -- look at the severity
           IF l_qlp_rec.severity = 'S' THEN
              l_return_status := 'E';
           ELSE
              l_return_status := 'W';
           END IF;
        END IF;  -- l_return_status = 'E'
        IF l_return_status = 'E' THEN
           l_tot_err_count := l_tot_err_count + 1;
           e_msg_tbl(l_tot_err_count).name           := l_qlp_rec.name;
           e_msg_tbl(l_tot_err_count).description    := l_qlp_rec.description;
           e_msg_tbl(l_tot_err_count).package_name   := l_qlp_rec.package_name;
           e_msg_tbl(l_tot_err_count).procedure_name := l_qlp_rec.procedure_name;
           e_msg_tbl(l_tot_err_count).severity       := l_qlp_rec.severity;
           e_msg_tbl(l_tot_err_count).error_status   := l_return_status;
           e_msg_tbl(l_tot_err_count).data           := pub_qa_msg_tbl(i).data;
        ELSIF l_return_status = 'W' THEN
           l_tot_wrn_count := l_tot_wrn_count + 1;
           w_msg_tbl(l_tot_wrn_count).name           := l_qlp_rec.name;
           w_msg_tbl(l_tot_wrn_count).description    := l_qlp_rec.description;
           w_msg_tbl(l_tot_wrn_count).package_name   := l_qlp_rec.package_name;
           w_msg_tbl(l_tot_wrn_count).procedure_name := l_qlp_rec.procedure_name;
           w_msg_tbl(l_tot_wrn_count).severity       := l_qlp_rec.severity;
           w_msg_tbl(l_tot_wrn_count).error_status   := l_return_status;
           w_msg_tbl(l_tot_wrn_count).data           := pub_qa_msg_tbl(i).data;
        ELSE
           l_tot_suc_count := l_tot_suc_count + 1;
           s_msg_tbl(l_tot_suc_count).name           := l_qlp_rec.name;
           s_msg_tbl(l_tot_suc_count).description    := l_qlp_rec.description;
           s_msg_tbl(l_tot_suc_count).package_name   := l_qlp_rec.package_name;
           s_msg_tbl(l_tot_suc_count).procedure_name := l_qlp_rec.procedure_name;
           s_msg_tbl(l_tot_suc_count).severity       := l_qlp_rec.severity;
           s_msg_tbl(l_tot_suc_count).error_status   := l_return_status;
           s_msg_tbl(l_tot_suc_count).data           := pub_qa_msg_tbl(i).data;
       END IF;

       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'pub_qa_msg_tbl(' || i ||').error_status: ' || pub_qa_msg_tbl(i).error_status);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_return_status: ' || l_return_status);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_qlp_rec.name: ' || l_qlp_rec.name);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_qlp_rec.description: ' || l_qlp_rec.description);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_qlp_rec.package_name: ' || l_qlp_rec.package_name);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_qlp_rec.procedure_name: ' || l_qlp_rec.procedure_name);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_qlp_rec.severity: ' || l_qlp_rec.severity);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'pub_qa_msg_tbl(' || i ||').data: ' || pub_qa_msg_tbl(i).data);
	  END IF;

      END LOOP;
      pub_qa_msg_tbl.delete;
     ELSE -- else - QA check has populated the message stack, even if success
      l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first,
                                    p_encoded   => fnd_api.g_false);

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     IF l_msg_data IS NOT NULL THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'QA check has populated the message stack');
		ELSE
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'QA check has populated the message stack with no messages');
		END IF;
	 END IF;

        -- Even if succesful, the QA program will load a message for
        -- us to retrieve
      WHILE l_msg_data IS NOT NULL
      LOOP
        l_tot_msg_count := l_tot_msg_count + 1;

-- skekkar ####
--  Return status will depend on severity defined by the user if the qa check fails

        IF  l_return_status = 'E' THEN
          -- look at the severity
           IF l_qlp_rec.severity = 'S' THEN
              l_return_status := 'E';
           ELSE
              l_return_status := 'W';
           END IF;
        END IF;  -- l_return_status = 'E'
-- skekkar ####

        -- store the program results
        -- skekkar
        IF l_return_status = 'E' THEN
           l_tot_err_count := l_tot_err_count + 1;
           e_msg_tbl(l_tot_err_count).name           := l_qlp_rec.name;
           e_msg_tbl(l_tot_err_count).description    := l_qlp_rec.description;
           e_msg_tbl(l_tot_err_count).package_name   := l_qlp_rec.package_name;
           e_msg_tbl(l_tot_err_count).procedure_name := l_qlp_rec.procedure_name;
           e_msg_tbl(l_tot_err_count).severity       := l_qlp_rec.severity;
           e_msg_tbl(l_tot_err_count).error_status   := l_return_status;
           e_msg_tbl(l_tot_err_count).data           := l_msg_data;
        ELSIF l_return_status = 'W' THEN
           l_tot_wrn_count := l_tot_wrn_count + 1;
           w_msg_tbl(l_tot_wrn_count).name           := l_qlp_rec.name;
           w_msg_tbl(l_tot_wrn_count).description    := l_qlp_rec.description;
           w_msg_tbl(l_tot_wrn_count).package_name   := l_qlp_rec.package_name;
           w_msg_tbl(l_tot_wrn_count).procedure_name := l_qlp_rec.procedure_name;
           w_msg_tbl(l_tot_wrn_count).severity       := l_qlp_rec.severity;
           w_msg_tbl(l_tot_wrn_count).error_status   := l_return_status;
           w_msg_tbl(l_tot_wrn_count).data           := l_msg_data;
        ELSE
           l_tot_suc_count := l_tot_suc_count + 1;
           s_msg_tbl(l_tot_suc_count).name           := l_qlp_rec.name;
           s_msg_tbl(l_tot_suc_count).description    := l_qlp_rec.description;
           s_msg_tbl(l_tot_suc_count).package_name   := l_qlp_rec.package_name;
           s_msg_tbl(l_tot_suc_count).procedure_name := l_qlp_rec.procedure_name;
           s_msg_tbl(l_tot_suc_count).severity       := l_qlp_rec.severity;
           s_msg_tbl(l_tot_suc_count).error_status   := l_return_status;
           s_msg_tbl(l_tot_suc_count).data           := l_msg_data;
       END IF;

       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_return_status: ' || l_return_status);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_qlp_rec.name: ' || l_qlp_rec.name);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_qlp_rec.description: ' || l_qlp_rec.description);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_qlp_rec.package_name: ' || l_qlp_rec.package_name);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_qlp_rec.procedure_name: ' || l_qlp_rec.procedure_name);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_qlp_rec.severity: ' || l_qlp_rec.severity);
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_msg_data: ' || l_msg_data);
	  END IF;

        l_msg_data := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_next,
                                      p_encoded   => fnd_api.g_false);
      END LOOP;
     END IF;

    END LOOP;
    CLOSE l_qlp_csr;

     -- assign to out table in sort order E , W and S

      FOR  i IN NVL(e_msg_tbl.FIRST,0)..NVL(e_msg_tbl.LAST,-1)
      LOOP

        tot_msg_count := tot_msg_count + 1;

        x_msg_tbl(tot_msg_count).name           := e_msg_tbl(i).name;
        x_msg_tbl(tot_msg_count).description    := e_msg_tbl(i).description;
        x_msg_tbl(tot_msg_count).package_name   := e_msg_tbl(i).package_name;
        x_msg_tbl(tot_msg_count).procedure_name := e_msg_tbl(i).procedure_name;
        x_msg_tbl(tot_msg_count).severity       := e_msg_tbl(i).severity;
        x_msg_tbl(tot_msg_count).error_status   := e_msg_tbl(i).error_status;
        x_msg_tbl(tot_msg_count).data           := e_msg_tbl(i).data;

      END LOOP;

      FOR  j IN NVL(w_msg_tbl.FIRST,0)..NVL(w_msg_tbl.LAST,-1)
      LOOP

        tot_msg_count := tot_msg_count + 1;

        x_msg_tbl(tot_msg_count).name           := w_msg_tbl(j).name;
        x_msg_tbl(tot_msg_count).description    := w_msg_tbl(j).description;
        x_msg_tbl(tot_msg_count).package_name   := w_msg_tbl(j).package_name;
        x_msg_tbl(tot_msg_count).procedure_name := w_msg_tbl(j).procedure_name;
        x_msg_tbl(tot_msg_count).severity       := w_msg_tbl(j).severity;
        x_msg_tbl(tot_msg_count).error_status   := w_msg_tbl(j).error_status;
        x_msg_tbl(tot_msg_count).data           := w_msg_tbl(j).data;

      END LOOP;

      FOR  k IN NVL(s_msg_tbl.FIRST,0)..NVL(s_msg_tbl.LAST,-1)
      LOOP

        tot_msg_count := tot_msg_count + 1;

        x_msg_tbl(tot_msg_count).name           := s_msg_tbl(k).name;
        x_msg_tbl(tot_msg_count).description    := s_msg_tbl(k).description;
        x_msg_tbl(tot_msg_count).package_name   := s_msg_tbl(k).package_name;
        x_msg_tbl(tot_msg_count).procedure_name := s_msg_tbl(k).procedure_name;
        x_msg_tbl(tot_msg_count).severity       := s_msg_tbl(k).severity;
        x_msg_tbl(tot_msg_count).error_status   := s_msg_tbl(k).error_status;
        x_msg_tbl(tot_msg_count).data           := s_msg_tbl(k).data;

      END LOOP;


    --anjkumar, restore the context  Bug 5609807
    okc_context.restore_contexts;

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name,'Leaving '|| G_PKG_NAME || '.' || l_api_name);
   END IF;


  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN

    --anjkumar, restore the context  Bug 5609807
    okc_context.restore_contexts;

--Bug 3300707
      if (l_cursor_id is not null) then
            DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
      end if;
     IF l_qlp_csr%ISOPEN THEN
          CLOSE l_qlp_csr;
     END IF;
   IF l_qpp_csr%ISOPEN THEN
          CLOSE l_qpp_csr;
     END IF;
   IF l_scs_csr%ISOPEN THEN
          CLOSE l_scs_csr;
     END IF;


  WHEN OTHERS THEN

   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'WHEN OTHERS: setting message after encountering error: ' || SQLCODE || ' ' || SQLERRM);
   END IF;

    --anjkumar, restore the context  Bug 5609807
    okc_context.restore_contexts;

    -- close cursor
   if (l_cursor_id is not null) then  --Bug 3378989
    DBMS_SQL.CLOSE_CURSOR(l_cursor_id);  --Bug2934909
   end if;
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    IF l_qlp_csr%ISOPEN THEN
      CLOSE l_qlp_csr;
    END IF;
    IF l_qpp_csr%ISOPEN THEN
      CLOSE l_qpp_csr;
    END IF;
    IF l_scs_csr%ISOPEN THEN
      CLOSE l_scs_csr;
    END IF;
  END execute_qa_check_list;


END OKC_QA_CHECK_PVT;

/
