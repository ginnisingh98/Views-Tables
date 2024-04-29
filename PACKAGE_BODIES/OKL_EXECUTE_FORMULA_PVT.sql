--------------------------------------------------------
--  DDL for Package Body OKL_EXECUTE_FORMULA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_EXECUTE_FORMULA_PVT" AS
  /* $Header: OKLRFMLB.pls 120.6 2007/05/25 11:55:26 prasjain noship $ */

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;

-- Start of comments
--
-- Procedure Name  : execute_eligibility_Criteria
-- Description     : Evaluates the function and returns a scalar value.
-- Business Rules  :
-- Parameters      : Function Name
-- Version         : 1.0
-- End of comments


PROCEDURE execute_eligibility_Criteria(p_api_version       IN  NUMBER
                            ,p_init_msg_list     IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                            ,x_return_status     OUT NOCOPY VARCHAR2
                            ,x_msg_count         OUT NOCOPY NUMBER
                            ,x_msg_data          OUT NOCOPY VARCHAR2
                            ,p_function_name     IN  okl_data_src_fnctns_v.name%TYPE
                            ,x_value             OUT NOCOPY NUMBER
                          ) IS

     -- Exception declarations
     FUNCTION_DATA_INVALID      EXCEPTION;
     FUNCTION_RETURNS_NULL      EXCEPTION;

    --  Local Variable Declarations
    l_value                NUMBER;
    l_init_msg_list        VARCHAR2(1) DEFAULT OKC_API.G_FALSE;
    l_return_status        VARCHAR2(1);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);
    l_evaluated_string     okl_formulae_v.formula_string%TYPE;
    l_no_dml_message       VARCHAR2(200) := 'OKL_FORMULAE_NO_DML';
    l_function_name        okl_data_src_fnctns_v.name%TYPE;
    l_function_source      okl_data_src_fnctns_v.source%TYPE;
    l_api_version          CONSTANT NUMBER := 1.0;

    l_program_name      CONSTANT VARCHAR2(30) := 'execute_eligibility_Criteria';
    l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_flag                 BOOLEAN DEFAULT FALSE;

    CURSOR data_src_fnctns_csr(cp_function_name IN okl_data_src_fnctns_v.name%TYPE)
    IS
      SELECT source
        FROM okl_data_src_fnctns_v
       WHERE name = cp_function_name
       AND fnctn_code = 'ELIGIBILITY_CRITERIA';

  BEGIN


    l_function_name  := p_function_name;

    FOR l_data_src_fnctns_csr IN data_src_fnctns_csr(cp_function_name => l_function_name)
    LOOP
      l_flag := TRUE;
      l_function_source := l_data_src_fnctns_csr.source;
      EXIT;
    END LOOP;


    IF l_flag THEN
      l_flag := FALSE;
    ELSE
      RAISE NO_DATA_FOUND;
    END IF;

    l_evaluated_string := l_function_source;
    --DBMS_OUTPUT.PUT_LINE('l_evaluated_string '||l_evaluated_string);


   IF l_evaluated_string IS NULL THEN
     RAISE FUNCTION_DATA_INVALID;
   ELSE
     l_evaluated_string  := 'SELECT '||l_evaluated_string ||' FROM dual';
   END IF;

   EXECUTE IMMEDIATE l_evaluated_string
                INTO l_value;
   --     DBMS_OUTPUT.PUT_LINE('function eval is '||l_evaluated_string||' values is '||l_value);

   IF l_value IS NULL THEN
    RAISE FUNCTION_RETURNS_NULL;
   ELSE
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     x_value := l_value;
  END IF;

  EXCEPTION
    WHEN FUNCTION_RETURNS_NULL THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => 'OKL_FUNCTION_RETURNS_NULL'
                         ,p_token1            => 'FUNCTION'
                         ,p_token1_value      => l_function_name );
      x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN FUNCTION_DATA_INVALID THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_function_data_invalid
                         ,p_token1            => 'FUNCTION'
                         ,p_token1_value      => l_function_name );
      x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN NO_DATA_FOUND THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_invalid_function
                         ,p_token1            => 'FUNCTION'
                         ,p_token1_value      => l_function_name );
      x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
       OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END execute_eligibility_Criteria;


-- Start of comments
--
-- Procedure Name  : execute_function
-- Description     : Evaluates the function and returns a scalar value used internally by package
-- Business Rules  :
-- Parameters      : Function_ID, Table of Context parameter Values
-- Version         : 1.0
-- End of comments

  PROCEDURE execute_function(p_api_version       IN  NUMBER
                            ,p_init_msg_list     IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                            ,x_return_status     OUT NOCOPY VARCHAR2

                            ,x_msg_count         OUT NOCOPY NUMBER
                            ,x_msg_data          OUT NOCOPY VARCHAR2
                            ,p_dsf_id            IN  okl_operands_v.dsf_id%TYPE
                            ,p_ctx_parameter_tbl IN  ctxt_parameter_tbl_type
                            ,p_contract_id       IN  okl_k_headers_v.id%TYPE
                            ,p_line_id           IN  okl_k_lines_v.id%TYPE
                            ,x_value             OUT NOCOPY NUMBER


                          ) IS
  --  Type Declarations
    TYPE fnctn_prmtrs_val_rec_type IS RECORD(pmr_id    okl_fnctn_prmtrs_v.pmr_id%TYPE
                                            ,value     okl_fnctn_prmtrs_v.value%TYPE
                                            ,fpr_type  okl_fnctn_prmtrs_v.fpr_type%TYPE
                                            );
    TYPE fnctn_prmtrs_val_tbl_type IS TABLE OF fnctn_prmtrs_val_rec_type
      INDEX BY BINARY_INTEGER;

  -- Exception declarations
     NO_DML_EXCEPTION           EXCEPTION;
     NO_CONSTANT_SPECIFIED      EXCEPTION;
     FUNCTION_DATA_INVALID      EXCEPTION;
     FUNCTION_DOES_NOT_EXIST    EXCEPTION;
     FUNCTION_RETURNS_NULL      EXCEPTION;

     PRAGMA EXCEPTION_INIT(NO_DML_EXCEPTION,-14551);
     PRAGMA EXCEPTION_INIT(FUNCTION_DOES_NOT_EXIST,-904);

  --  Local Variable Declarations
    l_formula_id           okl_formulae_v.id%TYPE;
    l_contract_id          okl_k_headers_v.id%TYPE;
    l_line_id              okl_k_lines_v.id%TYPE;
    l_value                NUMBER;
    l_init_msg_list        VARCHAR2(1) DEFAULT OKC_API.G_FALSE;
    l_return_status        VARCHAR2(1);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);
    l_formula_string       okl_formulae_v.formula_string%TYPE;
    l_evaluated_string     okl_formulae_v.formula_string%TYPE;
    l_evaluated_string2    okl_formulae_v.formula_string%TYPE;
    l_function_source      okl_data_src_fnctns_v.source%TYPE;
    l_function_source2     okl_data_src_fnctns_v.source%TYPE;
    l_function_source3     okl_data_src_fnctns_v.source%TYPE;
    l_fnctn_prmtrs_val_tbl fnctn_prmtrs_val_tbl_type;
    l_no_dml_message       VARCHAR2(200) := 'OKL_FORMULAE_NO_DML';
    l_dsf_id               okl_data_src_fnctns_v.id%TYPE;
    i                      PLS_INTEGER DEFAULT 1;
    j                      PLS_INTEGER DEFAULT 1;
    l_api_version          CONSTANT NUMBER := 1.0;
    l_api_name             CONSTANT VARCHAR2(30) := 'EXECUTE_FUNCTION';
    l_flag                 BOOLEAN DEFAULT FALSE;
    l_function_name	   okl_data_src_fnctns_v.name%TYPE;
  v1c varchar2(400);
  v2c varchar2(400);
  v3c varchar2(400);
  v4c varchar2(400);
  v5c varchar2(400);

    CURSOR data_src_fnctns_csr(cp_dsf_id IN okl_data_src_fnctns_v.id%TYPE)  IS
      SELECT fnctn_code
            ,name
            ,source
        FROM okl_data_src_fnctns_v
       WHERE id = cp_dsf_id;

    CURSOR fnctn_prmtrs_csr(cp_dsf_id IN okl_fnctn_prmtrs_v.dsf_id%TYPE)  IS
      SELECT dsf_id
            ,pmr_id
            ,sequence_number
            ,value
            ,fpr_type
        FROM okl_fnctn_prmtrs_v
       WHERE dsf_id = cp_dsf_id
    ORDER BY sequence_number;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In execute_function... p_dsf_id=' || p_dsf_id);
    END IF;
    l_dsf_id             := p_dsf_id;
    l_contract_id        := p_contract_id;
    l_line_id            := p_line_id;
    FOR l_data_src_fnctns_csr IN data_src_fnctns_csr(cp_dsf_id => l_dsf_id)
    LOOP
      l_flag := TRUE;
      l_function_source := l_data_src_fnctns_csr.source;
      l_function_name := l_data_src_fnctns_csr.name;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_function_source=' || l_function_source || ' l_function_name='||l_function_name);
      END IF;
      EXIT;
    END LOOP;
    IF l_flag THEN
      l_flag := FALSE;
    ELSE
      RAISE NO_DATA_FOUND;
    END IF;
    i := 1;
    FOR l_fnctn_prmtrs_csr IN fnctn_prmtrs_csr(cp_dsf_id => l_dsf_id)
    LOOP
      l_fnctn_prmtrs_val_tbl(i).pmr_id := l_fnctn_prmtrs_csr.pmr_id;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'pmr_id=' || l_fnctn_prmtrs_val_tbl(i).pmr_id || ' fpr_type='||l_fnctn_prmtrs_csr.fpr_type);
      END IF;

      IF l_fnctn_prmtrs_csr.fpr_type='STATIC' THEN
        IF l_fnctn_prmtrs_csr.value IS NULL THEN
          RAISE NO_CONSTANT_SPECIFIED;
        ELSE
          l_fnctn_prmtrs_val_tbl(i).value  := l_fnctn_prmtrs_csr.value;
        END IF;
      ELSE
        IF p_ctx_parameter_tbl.EXISTS(1) THEN
          j := p_ctx_parameter_tbl.FIRST;

          FOR j IN p_ctx_parameter_tbl.FIRST .. p_ctx_parameter_tbl.LAST
          LOOP
            IF p_ctx_parameter_tbl(j).parameter_id = l_fnctn_prmtrs_csr.pmr_id THEN
              l_fnctn_prmtrs_val_tbl(i).value := p_ctx_parameter_tbl(j).parameter_value;
              EXIT;
            ELSE

              NULL;
            END IF;
          END LOOP;
        END IF;
      END IF;
      i := i+1;
    END LOOP;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_fnctn_prmtrs_val_tbl.count='||l_fnctn_prmtrs_val_tbl.count);
    END IF;

    l_function_source2 := l_function_source;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'1.l_function_source2=' || l_function_source2);
    END IF;
    IF l_line_id IS NULL THEN
      --Changed by kthiruva for the bug 3671523 . l_contract_id and l_line_id are passed as strings
      l_function_source := l_function_source ||'('||''''||TO_CHAR(l_contract_id)||''''||','||''''||'''';
    ELSE
      --Changed by kthiruva for the bug 3671523 . l_contract_id and l_line_id are passed as strings
      l_function_source := l_function_source ||'('||''''||TO_CHAR(l_contract_id)||''''||','||''''||TO_CHAR(l_line_id)||'''';
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_function_source=' || l_function_source);
    END IF;
    --l_function_source2 := 'begin :3 := ' || l_function_source2 || '(:1, :2); end;'
    l_function_source2 := 'begin :3 := ' || l_function_source2 || '(:1, :2';
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'2.l_function_source2=' || l_function_source2);
    END IF;

/*
    IF l_line_id IS NULL THEN
      l_function_source := l_function_source ||'('||TO_CHAR(l_contract_id)||','||''''||'''';
    ELSE
      l_function_source := l_function_source ||'('||TO_CHAR(l_contract_id)||','||TO_CHAR(l_line_id);
    END IF;
*/


    IF l_fnctn_prmtrs_val_tbl.EXISTS(1) THEN
      l_evaluated_string := l_function_source ||',';
      --l_evaluated_string2 := l_function_source2 ||',';
      i := l_fnctn_prmtrs_val_tbl.FIRST;
      FOR i IN l_fnctn_prmtrs_val_tbl.FIRST .. l_fnctn_prmtrs_val_tbl.LAST
      LOOP
        IF i = l_fnctn_prmtrs_val_tbl.FIRST THEN
          l_evaluated_string := l_evaluated_string ||l_fnctn_prmtrs_val_tbl(i).value;
        ELSE
          l_evaluated_string := l_evaluated_string ||','||l_fnctn_prmtrs_val_tbl(i).value;
        END IF;
      l_evaluated_string2 := l_function_source2 ||', :' || i+2 ;
      END LOOP;
      l_evaluated_string := l_evaluated_string ||')';
      l_evaluated_string2 := l_evaluated_string2 ||'); end;';
   ELSE
     l_evaluated_string := l_function_source||')';
     l_evaluated_string2 := l_function_source2||'); end;';
   END IF;
   IF l_evaluated_string IS NULL THEN
     RAISE FUNCTION_DATA_INVALID;
   END IF;
   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_evaluated_string=' || l_evaluated_string);
     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_evaluated_string2=' || l_evaluated_string2);
   END IF;

   -- Commented by Santonyr on 22-Oct-2003 to fix bug 3214171

/*   ELSE
     l_evaluated_string  := 'SELECT '||l_evaluated_string ||' FROM dual';
   END IF;

-- EXECUTE IMMEDIATE l_evaluated_string INTO l_value;
-- DBMS_OUTPUT.PUT_LINE('function eval is '||l_evaluated_string||' values is '||l_value);

*/


   -- Changed by Santonyr on 22-Oct-2003 to fix bug 3214171

   v1c := l_contract_id;
   v2c := l_line_id; --dkagrawa removed the condition to fix bug# 4593579
   l_evaluated_string := 'BEGIN  :l_output_value := ' || l_evaluated_string || '; end;' ;
   --EXECUTE IMMEDIATE  l_evaluated_string USING OUT l_value;
   if (l_fnctn_prmtrs_val_tbl.count = 0) then
     EXECUTE IMMEDIATE  l_evaluated_string2 USING OUT l_value, IN v1c, IN v2c;
   end if;


  IF l_value IS NULL THEN
    RAISE FUNCTION_RETURNS_NULL;
  ELSE
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     x_value := l_value;
  END IF;

  EXCEPTION
    WHEN FUNCTION_RETURNS_NULL THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => 'OKL_FUNCTION_RETURNS_NULL'
                         ,p_token1            => 'FUNCTION'
                         ,p_token1_value      => l_function_name );
      x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN NO_DML_EXCEPTION THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_formulae_no_dml
                         ,p_token1            => 'FUNCTION'
                         ,p_token1_value      => l_function_name );
      x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN FUNCTION_DOES_NOT_EXIST THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_function_does_not_exist
                         ,p_token1            => 'FUNCTION'
                         ,p_token1_value      => l_function_name );
      x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN FUNCTION_DATA_INVALID THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_function_data_invalid
                         ,p_token1            => 'FUNCTION'
                         ,p_token1_value      => l_function_name );
      x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN G_EXCEPTION_HALT_PROCESSING THEN
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN NO_CONSTANT_SPECIFIED THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_no_constant_function
                         ,p_token1            => 'FUNCTION'
                         ,p_token1_value      => l_function_name );
      x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN NO_DATA_FOUND THEN

      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_invalid_function
                         ,p_token1            => 'FUNCTION'
                         ,p_token1_value      => l_function_name );
      x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN VALUE_ERROR THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => 'OKL_FUNCTION_VALUE_ERROR'
                         ,p_token1            => 'FUNCTION'
                         ,p_token1_value      => l_function_name );
      x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => sqlcode
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END execute_function;

-- Start of comments
--
-- Procedure Name  : execute_formula
-- Description     : Evaluates the formula and returns a scalar value and a table of operand id, label and
--                   value.  Used internally by package for recursive calling
-- Business Rules  :
-- Parameters      : Formula_ID, Formula String, Contract ID, Line ID,Table of Context parameter Values
--
-- Version         : 1.0
-- End of comments

  PROCEDURE execute_formula(p_api_version       IN  NUMBER
                           ,p_init_msg_list     IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                           ,x_return_status     OUT NOCOPY VARCHAR2
                           ,x_msg_count         OUT NOCOPY NUMBER
                           ,x_msg_data          OUT NOCOPY VARCHAR2
                           ,p_formula_id        IN  okl_formulae_v.id%TYPE
                           ,p_formula_string    IN  okl_formulae_v.formula_string%TYPE
                           ,p_contract_id       IN  okl_k_headers_v.id%TYPE
                           ,p_line_id           IN  okl_k_lines_v.id%TYPE
                           ,p_ctx_parameter_tbl IN  ctxt_parameter_tbl_type
                           ,x_operand_val_tbl   OUT NOCOPY operand_val_tbl_type
                           ,x_value             OUT NOCOPY NUMBER
                           ) IS


  --  Local Variable Declarations
    l_ctxt_parameter_tbl       ctxt_parameter_tbl_type;
    l_operand_val_tbl          operand_val_tbl_type;
    l_operand_val_tbl_null     operand_val_tbl_type;
    l_formula_id               okl_formulae_v.id%TYPE;
    l_formula_name             okl_formulae_v.name%TYPE;
    l_contract_id              okl_k_headers_v.id%TYPE;
    l_line_id                  okl_k_lines_v.id%TYPE;
    l_value                    NUMBER;
    l_init_msg_list            VARCHAR2(1) DEFAULT OKC_API.G_FALSE;
    l_return_status            VARCHAR2(1);
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(2000);
    l_formula_string           okl_formulae_v.formula_string%TYPE;
    l_temp_string              okl_formulae_v.formula_string%TYPE DEFAULT NULL;
    l_temp_string1             okl_formulae_v.formula_string%TYPE DEFAULT NULL;
    l_evaluated_string         okl_formulae_v.formula_string%TYPE;
    i                          NUMBER DEFAULT 1;
    l_api_version              CONSTANT NUMBER := 1.0;
    l_api_name                 CONSTANT VARCHAR2(30) := 'EXECUTE_FORMULA';
    l_flag                     BOOLEAN DEFAULT FALSE;
    l_operand_name	       okl_operands_v.name%TYPE;

-- Exception declarations
    NO_OPERAND_FOUND           EXCEPTION;
    NO_FORMULA_OPERAND_FOUND   EXCEPTION;
    NO_CONSTANT_SPECIFIED      EXCEPTION;
    OPERAND_DATA_INVALID       EXCEPTION;

--  Cursor Declarations

    CURSOR formula_operand_csr(cp_fma_id IN okl_fmla_oprnds_v.fma_id%TYPE) IS
      SELECT label
            ,opd_id
        FROM okl_fmla_oprnds_v
       WHERE fma_id = cp_fma_id;

    CURSOR operand_csr(cp_operand_id IN okl_operands_v.id%TYPE)  IS
      SELECT fma_id
            ,dsf_id
            ,name
            ,source
            ,opd_type

        FROM okl_operands_v
       WHERE id = cp_operand_id;

    CURSOR formula_csr(cp_formula_id IN okl_formulae_v.id%TYPE) IS
      SELECT name
            ,formula_string
        FROM okl_formulae_v

       WHERE id = cp_formula_id;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In execute_formula...');
    END IF;
    l_formula_id         := p_formula_id;
    l_formula_string     := p_formula_string;
    l_contract_id        := p_contract_id;
    l_line_id            := p_line_id;
    l_ctxt_parameter_tbl := p_ctx_parameter_tbl;
    l_operand_val_tbl    := l_operand_val_tbl_null;
    i := 1;

-- Added by Santonyr Jul 12th, 2002.To get the formula name which will be used as a token.

    FOR formula_rec IN formula_csr (l_formula_id) LOOP
      l_formula_name := formula_rec.name;
    END LOOP;

    FOR l_formula_operand_csr IN formula_operand_csr(cp_fma_id => l_formula_id)
    LOOP
      l_flag := TRUE;
      l_operand_val_tbl(i).id    := l_formula_operand_csr.opd_id;
      l_operand_val_tbl(i).label := l_formula_operand_csr.label;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_operand_val_tbl('||i||').id=' || l_operand_val_tbl(i).id);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_operand_val_tbl('||i||').label=' || l_operand_val_tbl(i).label);
      END IF;
      i := i+1;
    END LOOP;
    IF l_flag THEN
      l_flag := FALSE;
    ELSE
      RAISE NO_FORMULA_OPERAND_FOUND;
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_operand_val_tbl.count=' || l_operand_val_tbl.count);
    END IF;
    i := 1;
    FOR i in l_operand_val_tbl.FIRST .. l_operand_val_tbl.LAST
    LOOP
      FOR l_operand_csr IN operand_csr(cp_operand_id => l_operand_val_tbl(i).id)
      LOOP
        l_value := NULL;
        l_operand_name := l_operand_csr.name;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i=' || i || ' l_operand_name='|| l_operand_name || ' operand_type=' || l_operand_csr.opd_type);
        END IF;
        IF l_operand_csr.opd_type = 'CNST' THEN
          IF l_operand_csr.source IS NULL THEN
            RAISE NO_CONSTANT_SPECIFIED;
          ELSE

            l_operand_val_tbl(i).value := l_operand_csr.source;
          END IF;
        ELSIF l_operand_csr.opd_type = 'FCNT' THEN
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Calling execute_function...');
          END IF;
          execute_function(p_api_version       => l_api_version
                          ,p_init_msg_list     => l_init_msg_list
                          ,x_return_status     => l_return_status
                          ,x_msg_count         => l_msg_count
                          ,x_msg_data          => l_msg_data
                          ,p_dsf_id            => l_operand_csr.dsf_id
                          ,p_ctx_parameter_tbl => l_ctxt_parameter_tbl
                          ,p_contract_id       => l_contract_id
                          ,p_line_id           => l_line_id
                          ,x_value             => l_value
                          );
          IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE G_EXCEPTION_HALT_PROCESSING;
          ELSE
            IF l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
              x_return_status := l_return_status;
              -- commented by prasjain for bug #5951213
              -- l_operand_val_tbl(i).value := l_value;
              -- added by prasjain for bug #5951213
              l_operand_val_tbl(i).value := fnd_number.number_to_canonical(l_value);
            ELSE
              RAISE G_EXCEPTION_ERROR;
            END IF;
          END IF;
        ELSIF l_operand_csr.opd_type = 'FMLA' THEN
          l_formula_id := l_operand_csr.fma_id;
          OPEN formula_csr(cp_formula_id  => l_formula_id);
          FETCH formula_csr
          INTO l_formula_name
              ,l_formula_string;
          IF formula_csr%NOTFOUND THEN
            CLOSE formula_csr;
            RAISE NO_DATA_FOUND;
          ELSE
            CLOSE formula_csr;
          END IF;
          execute_formula(p_api_version       => l_api_version
                         ,p_init_msg_list     => l_init_msg_list

                         ,x_return_status     => l_return_status
                         ,x_msg_count         => l_msg_count
                         ,x_msg_data          => l_msg_data
                         ,p_formula_id        => l_formula_id
                         ,p_formula_string    => l_formula_string
                         ,p_contract_id       => l_contract_id
                         ,p_line_id           => l_line_id
                         ,p_ctx_parameter_tbl => l_ctxt_parameter_tbl
                         ,x_operand_val_tbl   => l_operand_val_tbl_null
                         ,x_value             => l_value);
          IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE G_EXCEPTION_HALT_PROCESSING;
          ELSE
            IF l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
              x_return_status := l_return_status;
              -- commented by prasjain for bug #5951213
              -- l_operand_val_tbl(i).value := l_value;
              -- added by prasjain for bug #5951213
              l_operand_val_tbl(i).value := fnd_number.number_to_canonical(l_value);
            ELSE
              RAISE G_EXCEPTION_ERROR;
            END IF;
          END IF;
        END IF;
        l_flag := TRUE;
      END LOOP;
      IF l_flag THEN
        l_flag := FALSE;
      ELSE
        RAISE NO_OPERAND_FOUND;
      END IF;
    END LOOP;

    -- Added to take care of complex operand names

    l_formula_string := p_formula_string;
    FOR i IN 1 .. LENGTH(l_formula_string)
    LOOP
      l_temp_string1 := SUBSTR(l_formula_string,i,1);
      IF l_temp_string1 IN ('(','+','-','*','/',')') THEN
        IF l_temp_string IS NULL THEN
          l_evaluated_string   := l_evaluated_string||l_temp_string1;
        ELSE
          FOR i IN l_operand_val_tbl.FIRST .. l_operand_val_tbl.LAST
          LOOP
            IF l_operand_val_tbl(i).label = l_temp_string  THEN
              l_evaluated_string  := l_evaluated_string||l_operand_val_tbl(i).value||l_temp_string1;
              l_flag := TRUE;
            END IF;
          END LOOP;
          IF l_flag THEN
            l_flag := FALSE;
          ELSE
            l_evaluated_string  := l_evaluated_string||l_temp_string||l_temp_string1;
          END IF;
        END IF;
        l_temp_string := NULL;
      ELSE
        l_temp_string := l_temp_string||l_temp_string1;
      END IF;
    END LOOP;


    FOR i IN l_operand_val_tbl.FIRST .. l_operand_val_tbl.LAST
    LOOP
      IF l_operand_val_tbl(i).label = l_temp_string  THEN
        l_evaluated_string  := l_evaluated_string||l_operand_val_tbl(i).value;
        l_flag := TRUE;
      END IF;
    END LOOP;
    IF l_flag THEN
      l_flag := FALSE;
    ELSE
      l_evaluated_string  := l_evaluated_string||l_temp_string;
      l_temp_string := NULL;
    END IF;

    -- Function/Formula returns negative and operation is positive
    -- then follow basic arithmetic rules

    l_evaluated_string := REPLACE(l_evaluated_string
                                 ,'+-'
                                 ,'-'
                                 );

    l_evaluated_string := REPLACE(l_evaluated_string
                                  ,'--'
                                  ,'+'
                                  );
    IF l_evaluated_string IS NULL THEN
      RAISE OPERAND_DATA_INVALID;
    END IF;

   -- Commented by Santonyr on 22-Oct-2003 to fix bug 3214171
/*   ELSE
     l_evaluated_string  := 'SELECT '||l_evaluated_string ||' FROM dual';
   END IF;

   EXECUTE IMMEDIATE l_evaluated_string INTO l_value;
   dbms_output.put_line('Evaluated String is '||l_evaluated_string);

*/


   -- Changed by Santonyr on 22-Oct-2003 to fix bug 3214171
   l_evaluated_string := 'BEGIN  :l_output_value := ' || l_evaluated_string || '; END;';
   EXECUTE IMMEDIATE l_evaluated_string USING OUT l_value;

    x_operand_val_tbl := l_operand_val_tbl;
    x_return_status   := OKC_API.G_RET_STS_SUCCESS;
    x_value           := l_value;

  EXCEPTION
    WHEN NO_FORMULA_OPERAND_FOUND THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_invalid_formula_operand
                         ,p_token1            => 'FORMULA'
                         ,p_token1_value      => l_formula_name );


      x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN NO_OPERAND_FOUND THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_invalid_operand
                         ,p_token1            => 'FORMULA'
                         ,p_token1_value      => l_formula_name );
      x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN NO_CONSTANT_SPECIFIED THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_no_constant_operand
                         ,p_token1            => 'OPERAND'
                         ,p_token1_value      => l_operand_name );
      x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN OPERAND_DATA_INVALID THEN
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_operand_data_invalid
                         ,p_token1            => 'OPERAND'
                         ,p_token1_value      => l_operand_name );
      x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN G_EXCEPTION_HALT_PROCESSING THEN
      IF formula_csr%ISOPEN THEN
        CLOSE formula_csr;
      END IF;
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN NO_DATA_FOUND THEN
      IF formula_csr%ISOPEN THEN
        CLOSE formula_csr;
      END IF;
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_invalid_fmla_in_operand
                         ,p_token1            => 'OPERAND'
                         ,p_token1_value      => l_operand_name );
      x_return_status := OKC_API.G_RET_STS_ERROR;


    WHEN VALUE_ERROR THEN
      IF formula_csr%ISOPEN THEN
        CLOSE formula_csr;
      END IF;
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_value_error
                         ,p_token1            => 'FORMULA'
                         ,p_token1_value      => l_formula_name );
      x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      IF formula_csr%ISOPEN THEN
        CLOSE formula_csr;
      END IF;
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => sqlcode
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END execute_formula;

-- Start of comments
--
-- Procedure Name  : execute
-- Description     : Evaluates the formula and returns a scalar value.  This procedure is overloaded
--                   to return the operand id, label and value.  This procedure is exposed to public.
-- Business Rules  :
-- Parameters      : Formula_ID, Formula String, Contract ID, Line ID,Table of Context parameter Values
--
-- Version         : 1.0
-- End of comments

  PROCEDURE execute(p_api_version           IN  NUMBER
                   ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE

                   ,x_return_status         OUT NOCOPY VARCHAR2
                   ,x_msg_count             OUT NOCOPY NUMBER
                   ,x_msg_data              OUT NOCOPY VARCHAR2
                   ,p_formula_name          IN  okl_formulae_v.name%TYPE
                   ,p_contract_id           IN  okl_k_headers_v.id%TYPE
                   ,p_line_id               IN  okl_k_lines_v.id%TYPE DEFAULT NULL
                   ,p_additional_parameters IN ctxt_val_tbl_type  DEFAULT g_additional_parameters_null
                   ,x_value                 OUT NOCOPY NUMBER
                   ) IS

  -- Exception declarations
     ERROR_IN_EVALUATE_PARAM        EXCEPTION;

  --  Local Variable Declarations
    l_ctxt_value_tbl     ctxt_val_tbl_type;
    l_ctxt_parameter_tbl ctxt_parameter_tbl_type;
    l_operand_val_tbl    operand_val_tbl_type;
    l_formula_id         okl_formulae_v.id%TYPE;
    l_formula_string     okl_formulae_v.formula_string%TYPE;
    l_formula_name       okl_formulae_v.name%TYPE;

    l_contract_id        okl_k_headers_v.id%TYPE;
    l_line_id            okl_k_lines_v.id%TYPE;
    l_value              NUMBER;
    l_init_msg_list      VARCHAR2(1) DEFAULT OKC_API.G_FALSE;
    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    i                    PLS_INTEGER DEFAULT 1;
    l_api_version        CONSTANT NUMBER := 1.0;
    l_api_name           CONSTANT VARCHAR2(30) := 'EXECUTE';

  --  Cursor Declarations
    CURSOR formula_csr(cp_formula_name IN okl_formulae_v.name%TYPE) IS
      SELECT id
            ,formula_string
        FROM okl_formulae_v
       WHERE name = cp_formula_name
         AND start_date <= sysdate
         AND (end_date IS NULL OR end_date >= sysdate);
  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In okl_execute_formula_pvt2.execute...');
    END IF;
    l_formula_name := p_formula_name;
    l_contract_id  := p_contract_id;
    l_line_id      := p_line_id;

    OPEN formula_csr(cp_formula_name  => l_formula_name);
    FETCH formula_csr
     INTO l_formula_id
         ,l_formula_string;
    IF formula_csr%NOTFOUND THEN
      CLOSE formula_csr;
      RAISE NO_DATA_FOUND;
    ELSE
      CLOSE formula_csr;
    END IF;

-- Commented by Santonyr on 22-Oct-2003 to fix bug 3214171
-- okl_execute_formula_pub.g_additional_parameters := p_additional_parameters;

    okl_formulaevaluate_pub.eva_getparametervalues(p_api_version       => l_api_version

                                                  ,p_init_msg_list     => l_init_msg_list
                                                  ,x_return_status     => l_return_status
                                                  ,x_msg_count         => l_msg_count
                                                  ,x_msg_data          => l_msg_data
                                                  ,p_fma_id            => l_formula_id
                                                  ,p_contract_id       => l_contract_id
                                                  ,p_line_id           => l_line_id
                                                  ,x_ctx_parameter_tbl => l_ctxt_parameter_tbl
                                                  );

    IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE ERROR_IN_EVALUATE_PARAM;
    ELSE
      IF l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
        x_return_status := l_return_status;
      ELSE
        RAISE ERROR_IN_EVALUATE_PARAM;
      END IF;
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After calling okl_formulaevaluate_pub.eva_getparametervalues l_ctxt_parameter_tbl.count='||l_ctxt_parameter_tbl.count);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Calling execute_formula...');
    END IF;
    execute_formula(p_api_version       => l_api_version
                   ,p_init_msg_list     => l_init_msg_list
                   ,x_return_status     => l_return_status
                   ,x_msg_count         => l_msg_count
                   ,x_msg_data          => l_msg_data
                   ,p_formula_id        => l_formula_id
                   ,p_formula_string    => l_formula_string
                   ,p_contract_id       => l_contract_id
                   ,p_line_id           => l_line_id
                   ,p_ctx_parameter_tbl => l_ctxt_parameter_tbl
                   ,x_operand_val_tbl   => l_operand_val_tbl
                   ,x_value             => l_value
                   );

    IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE G_EXCEPTION_HALT_PROCESSING;
    ELSIF l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      x_value         := l_value;
    ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
      RAISE G_EXCEPTION_ERROR;

    ELSE
      RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;
  EXCEPTION
    WHEN ERROR_IN_EVALUATE_PARAM  THEN
      IF formula_csr%ISOPEN THEN
        CLOSE formula_csr;
      END IF;
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_error_in_evaluate_param
                         ,p_token1            => 'FORMULA'
                         ,p_token1_value      => l_formula_name );
      x_return_status := l_return_status;

    WHEN G_EXCEPTION_HALT_PROCESSING THEN
      IF formula_csr%ISOPEN THEN
        CLOSE formula_csr;
      END IF;
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;


    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN NO_DATA_FOUND THEN
      IF formula_csr%ISOPEN THEN
        CLOSE formula_csr;
      END IF;
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_invalid_formula
                         ,p_token1            => 'FORMULA'
                         ,p_token1_value      => l_formula_name );
      x_return_status := OKC_API.G_RET_STS_ERROR;


    WHEN OTHERS THEN
      IF formula_csr%ISOPEN THEN
        CLOSE formula_csr;
      END IF;
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => sqlcode
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END execute;

-- Start of comments
--
-- Procedure Name  : execute
-- Description     : Evaluates the formula and returns a scalar value.  This procedure is overloaded
--                   to return the operand id, label and value.  This procedure is exposed to public.
--                   This procedure is overloaded to allow more granular results at the operand level
--                   It is used for validate formula screen where we can get values for
--                   each of the operand.

-- Business Rules  :
-- Parameters      : Formula_ID, Formula String, Contract ID, Line ID,Table of Context parameter Values
--
-- Version         : 1.0
-- End of comments

  PROCEDURE execute(p_api_version           IN  NUMBER
                   ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                   ,x_return_status         OUT NOCOPY VARCHAR2
                   ,x_msg_count             OUT NOCOPY NUMBER
                   ,x_msg_data              OUT NOCOPY VARCHAR2
                   ,p_formula_name          IN  okl_formulae_v.name%TYPE
                   ,p_contract_id           IN  okl_k_headers_v.id%TYPE
                   ,p_line_id               IN  okl_k_lines_v.id%TYPE DEFAULT NULL
                   ,p_additional_parameters IN ctxt_val_tbl_type  DEFAULT g_additional_parameters_null
                   ,x_operand_val_tbl       OUT NOCOPY operand_val_tbl_type
                   ,x_value                 OUT NOCOPY NUMBER
                   ) IS

  -- Exception declarations
     ERROR_IN_EVALUATE_PARAM        EXCEPTION;

  --  Local Variable Declarations
    l_ctxt_value_tbl     ctxt_val_tbl_type;
    l_ctxt_parameter_tbl ctxt_parameter_tbl_type;
    l_operand_val_tbl    operand_val_tbl_type;
    l_formula_id         okl_formulae_v.id%TYPE;
    l_formula_string     okl_formulae_v.formula_string%TYPE;
    l_formula_name       okl_formulae_v.name%TYPE;
    l_contract_id        okl_k_headers_v.id%TYPE;
    l_line_id            okl_k_lines_v.id%TYPE;
    l_value              NUMBER;
    l_init_msg_list      VARCHAR2(1) DEFAULT OKC_API.G_FALSE;
    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    i                    PLS_INTEGER DEFAULT 1;
    l_api_version        CONSTANT NUMBER := 1.0;
    l_api_name           CONSTANT VARCHAR2(30) := 'EXECUTE';

  --  Cursor Declarations
    CURSOR formula_csr(cp_formula_name IN okl_formulae_v.name%TYPE) IS
      SELECT id
            ,formula_string

        FROM okl_formulae_v
       WHERE name = cp_formula_name
         AND start_date <= sysdate
         AND (end_date IS NULL OR end_date >= sysdate);
  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In okl_execute_formula_pvt2.execute2...');
    END IF;
    l_formula_name := p_formula_name;
    l_contract_id  := p_contract_id;
    l_line_id      := p_line_id;

    OPEN formula_csr(cp_formula_name  => l_formula_name);
    FETCH formula_csr
     INTO l_formula_id
         ,l_formula_string;
    IF formula_csr%NOTFOUND THEN
      CLOSE formula_csr;
      RAISE NO_DATA_FOUND;
    ELSE
      CLOSE formula_csr;

    END IF;

  -- Commented by Santonyr on 22-Oct-2003 to fix bug 3214171
  -- okl_execute_formula_pub.g_additional_parameters := p_additional_parameters;

    okl_formulaevaluate_pub.eva_getparametervalues(p_api_version       => l_api_version
                                                  ,p_init_msg_list     => l_init_msg_list
                                                  ,x_return_status     => l_return_status
                                                  ,x_msg_count         => l_msg_count
                                                  ,x_msg_data          => l_msg_data
                                                  ,p_fma_id            => l_formula_id
                                                  ,p_contract_id       => l_contract_id
                                                  ,p_line_id           => l_line_id
                                                  ,x_ctx_parameter_tbl => l_ctxt_parameter_tbl
                                                  );
    IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE ERROR_IN_EVALUATE_PARAM;
    ELSE
      IF l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
        x_return_status := l_return_status;
      ELSE
        RAISE ERROR_IN_EVALUATE_PARAM;
      END IF;
    END IF;
    execute_formula(p_api_version       => l_api_version
                   ,p_init_msg_list     => l_init_msg_list
                   ,x_return_status     => l_return_status
                   ,x_msg_count         => l_msg_count
                   ,x_msg_data          => l_msg_data
                   ,p_formula_id        => l_formula_id
                   ,p_formula_string    => l_formula_string
                   ,p_contract_id       => l_contract_id
                   ,p_line_id           => l_line_id
                   ,p_ctx_parameter_tbl => l_ctxt_parameter_tbl

                   ,x_operand_val_tbl   => l_operand_val_tbl
                   ,x_value             => l_value
                   );
    IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE G_EXCEPTION_HALT_PROCESSING;
    ELSIF l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
      x_operand_val_tbl := l_operand_val_tbl;
      x_return_status   := l_return_status;
      x_value           := l_value;
    ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
      RAISE G_EXCEPTION_ERROR;
    ELSE
        RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;
  EXCEPTION
    WHEN ERROR_IN_EVALUATE_PARAM  THEN
      IF formula_csr%ISOPEN THEN
        CLOSE formula_csr;
      END IF;
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_error_in_evaluate_param
                         ,p_token1            => 'FORMULA'
                         ,p_token1_value      => l_formula_name );
      x_return_status := l_return_status;

    WHEN G_EXCEPTION_HALT_PROCESSING THEN
      IF formula_csr%ISOPEN THEN
        CLOSE formula_csr;
      END IF;
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN NO_DATA_FOUND THEN
      IF formula_csr%ISOPEN THEN
        CLOSE formula_csr;
      END IF;
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_invalid_formula
                         ,p_token1            => 'FORMULA'
                         ,p_token1_value      => l_formula_name );
      x_return_status := OKC_API.G_RET_STS_ERROR;


    WHEN OTHERS THEN
      IF formula_csr%ISOPEN THEN

        CLOSE formula_csr;
      END IF;
      OKC_API.SET_MESSAGE(p_app_name          => g_app_name
                         ,p_msg_name          => g_unexpected_error
                         ,p_token1            => g_sqlcode_token
                         ,p_token1_value      => sqlcode
                         ,p_token2            => g_sqlerrm_token
                         ,p_token2_value      => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END execute;

END OKL_EXECUTE_FORMULA_PVT;

/
