--------------------------------------------------------
--  DDL for Package Body OKL_EXECUTE_FORMULA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_EXECUTE_FORMULA_PUB" AS
  /* $Header: OKLPFMLB.pls 115.10 2004/04/13 10:45:20 rnaik noship $ */

  PROCEDURE execute(p_api_version           IN  NUMBER
                   ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                   ,x_return_status         OUT NOCOPY VARCHAR2
                   ,x_msg_count             OUT NOCOPY NUMBER
                   ,x_msg_data              OUT NOCOPY VARCHAR2
                   ,p_formula_name          IN  okl_formulae_v.name%TYPE
                   ,p_contract_id           IN  okl_k_headers_v.id%TYPE
                   ,p_line_id               IN  okl_k_lines_v.id%TYPE DEFAULT NULL
                   ,p_additional_parameters IN  ctxt_val_tbl_type DEFAULT g_additional_parameters_null
                   ,x_value                 OUT NOCOPY NUMBER
                   ) IS
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(100);
    l_api_name               CONSTANT VARCHAR2(30) := 'EXECUTE';
    l_return_status          VARCHAR2(1)           := FND_API.G_RET_STS_SUCCESS;
    l_formula_id             okl_formulae_v.id%TYPE;
    l_formula_string         okl_formulae_v.formula_string%TYPE;
    l_formula_name           okl_formulae_v.name%TYPE;
    l_contract_id            okl_k_headers_v.id%TYPE;
    l_line_id                okl_k_lines_v.id%TYPE;
    l_additional_parameters  ctxt_val_tbl_type;
    l_value                  NUMBER;
    l_init_msg_list            VARCHAR2(2) := 'T';  -- SGORANTL
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SAVEPOINT execute;
	  -- SGORANTL changed start
	IF NVL(p_init_msg_list,'F') = 'T'  THEN
        	OKL_API.init_msg_list(l_init_msg_list);
	END IF;
  -- SGORANTL changed end

    l_formula_name          := p_formula_name;
    l_contract_id           := p_contract_id;
    l_line_id               := p_line_id;
    l_additional_parameters := p_additional_parameters;



-- Added by Santonyr on 22-Oct-2003 to fix bug 3214171
    g_additional_parameters := p_additional_parameters;

    okl_execute_formula_pvt.execute(p_api_version           => p_api_version
                                   ,p_init_msg_list         => p_init_msg_list
                                   ,x_return_status         => l_return_status
                                   ,x_msg_count             => x_msg_count
                                   ,x_msg_data              => x_msg_data

                                   ,p_formula_name          => l_formula_name
                                   ,p_contract_id           => l_contract_id
                                   ,p_line_id               => l_line_id
                                   ,p_additional_parameters => l_additional_parameters
                                   ,x_value                 => l_value
                                   );

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    x_value := l_value;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO execute;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO execute;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      ROLLBACK TO execute;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_EXECUTE_FORMULA_PUB','execute');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END execute;

  PROCEDURE execute(p_api_version              IN  NUMBER
                   ,p_init_msg_list            IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                   ,x_return_status            OUT NOCOPY VARCHAR2
                   ,x_msg_count                OUT NOCOPY NUMBER
                   ,x_msg_data                 OUT NOCOPY VARCHAR2
                   ,p_formula_name             IN  okl_formulae_v.name%TYPE
                   ,p_contract_id              IN  okl_k_headers_v.id%TYPE
                   ,p_line_id                  IN  okl_k_lines_v.id%TYPE DEFAULT NULL
                   ,p_additional_parameters    IN  ctxt_val_tbl_type DEFAULT g_additional_parameters_null
                   ,x_operand_val_tbl          OUT NOCOPY operand_val_tbl_type
                   ,x_value                    OUT NOCOPY NUMBER
                   ) IS
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(100);
    l_api_name               CONSTANT VARCHAR2(30) := 'EXECUTE';
    l_return_status          VARCHAR2(1)           := FND_API.G_RET_STS_SUCCESS;
    l_formula_id             okl_formulae_v.id%TYPE;
    l_formula_string         okl_formulae_v.formula_string%TYPE;
    l_formula_name           okl_formulae_v.name%TYPE;
    l_contract_id            okl_k_headers_v.id%TYPE;
    l_line_id                okl_k_lines_v.id%TYPE;
    l_operand_val_tbl        operand_val_tbl_type;
    l_additional_parameters   ctxt_val_tbl_type;
    l_value                  NUMBER;
    l_init_msg_list            VARCHAR2(2) := 'T';  -- SGORANTL
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT execute;

  -- SGORANTL changed start
	IF NVL(p_init_msg_list,'F') = 'T'  THEN
        	OKL_API.init_msg_list(l_init_msg_list);
	END IF;
  -- SGORANTL changed end

    l_formula_name          := p_formula_name;
    l_contract_id           := p_contract_id;
    l_line_id               := p_line_id;
    l_additional_parameters := p_additional_parameters;

-- Added by Santonyr on 22-Oct-2003 to fix bug 3214171
    g_additional_parameters := p_additional_parameters;

    okl_execute_formula_pvt.execute(p_api_version           => p_api_version
                                   ,p_init_msg_list         => p_init_msg_list
                                   ,x_return_status         => l_return_status
                                   ,x_msg_count             => x_msg_count
                                   ,x_msg_data              => x_msg_data

                                   ,p_formula_name          => l_formula_name
                                   ,p_contract_id           => l_contract_id
                                   ,p_line_id               => l_line_id
                                   ,p_additional_parameters => l_additional_parameters
                                   ,x_operand_val_tbl       => l_operand_val_tbl
                                   ,x_value                 => l_value
                                   );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;


    x_value           := l_value;
    x_operand_val_tbl := l_operand_val_tbl;


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO execute;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO execute;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_EXECUTE_FORMULA_PUB','execute');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END execute;

END OKL_EXECUTE_FORMULA_PUB;

/
