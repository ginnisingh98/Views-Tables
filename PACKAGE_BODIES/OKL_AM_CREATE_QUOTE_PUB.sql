--------------------------------------------------------
--  DDL for Package Body OKL_AM_CREATE_QUOTE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_CREATE_QUOTE_PUB" AS
/* $Header: OKLPCQTB.pls 120.3.12010000.2 2009/06/15 21:57:26 sechawla ship $ */

-- GLOBAL VARIABLES
  G_LEVEL_PROCEDURE             CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT             CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  G_LEVEL_EXCEPTION             CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_MODULE_NAME                 CONSTANT VARCHAR2(500) := 'okl.am.plsql.okl_am_create_quote_pub.';

   PROCEDURE advance_contract_search(
            p_api_version          IN  NUMBER,
            p_init_msg_list        IN  VARCHAR2,
            x_return_status        OUT NOCOPY VARCHAR2,
            x_msg_count            OUT NOCOPY NUMBER,
            x_msg_data             OUT NOCOPY VARCHAR2,
            p_achr_rec             IN  ACHR_REC_TYPE,
            x_achr_tbl             OUT NOCOPY achr_tbl_type) IS

    l_api_version   NUMBER ;
    l_init_msg_list VARCHAR2(1);
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER ;
    l_msg_data      VARCHAR2(2000);
    lp_achr_rec     achr_rec_type;
    lx_achr_tbl     achr_tbl_type;

-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'advance_contract_search';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

   BEGIN

   SAVEPOINT trx_adv_contract_search;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

   l_api_version := p_api_version ;
   l_init_msg_list := p_init_msg_list ;
   l_return_status := x_return_status ;
   l_msg_count := x_msg_count;
   l_msg_data := x_msg_data;
   lp_achr_rec := p_achr_rec;

-- call the insert of pvt

 OKL_AM_CREATE_QUOTE_PVT.advance_contract_search(
            p_api_version          => l_api_version,
            p_init_msg_list        => l_init_msg_list,
            x_return_status        => l_return_status,
            x_msg_count            => l_msg_count,
            x_msg_data             => l_msg_data,
            p_achr_rec             => lp_achr_rec,
            x_achr_tbl             => lx_achr_tbl);


   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to OKL_AM_CREATE_QUOTE_PVT.advance_contract_search :'||l_return_status);
   END IF;

    IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
    RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

--Assign value to OUT variables
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
x_achr_tbl := lx_achr_tbl;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'USER DEFINED');
        END IF;

      ROLLBACK TO trx_adv_contract_search;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'UNEXPECTED');
      END IF;

      ROLLBACK TO trx_adv_contract_search;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
            IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
      ROLLBACK TO trx_adv_contract_search;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_CREATE_QUOTE_PUB','advance_contract_search');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

  END advance_contract_search;


  PROCEDURE create_terminate_quote(
    p_api_version  IN  NUMBER,
    p_init_msg_list  IN  VARCHAR2,
    x_return_status  OUT NOCOPY VARCHAR2,
    x_msg_count   OUT NOCOPY NUMBER,
    x_msg_data   OUT NOCOPY VARCHAR2,
    p_quot_rec   IN  quot_rec_type,
    p_assn_tbl   IN  assn_tbl_type,
    p_qpyv_tbl   IN  qpyv_tbl_type,
    x_quot_rec   OUT NOCOPY quot_rec_type,
    x_tqlv_tbl   OUT NOCOPY tqlv_tbl_type,
    x_assn_tbl   OUT NOCOPY assn_tbl_type,
	p_term_from_intf    IN VARCHAR2 DEFAULT 'N') IS --sechawla 15-jun-09 7383445 --added new parameter

    l_api_version NUMBER ;
    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);
    lp_quot_rec  quot_rec_type;
    lp_assn_tbl  assn_tbl_type;
    lp_qpyv_tbl  qpyv_tbl_type;
    lx_quot_rec  quot_rec_type;
    lx_assn_tbl  assn_tbl_type;
    lx_tqlv_tbl  tqlv_tbl_type;
-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'create_terminate_quote';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

BEGIN
SAVEPOINT trx_create_terminate_quote;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_quot_rec :=  p_quot_rec;
lp_assn_tbl :=  p_assn_tbl;
lp_qpyv_tbl :=  p_qpyv_tbl;
lx_quot_rec :=  p_quot_rec;
lx_assn_tbl :=  p_assn_tbl;




-- call the insert of pvt

 OKL_AM_CREATE_QUOTE_PVT.create_terminate_quote(
                                                p_api_version => l_api_version
                                               ,p_init_msg_list => l_init_msg_list
                                               ,x_msg_data      => l_msg_data
                                               ,x_msg_count     => l_msg_count
                                               ,x_return_status => l_return_status
                                               ,p_quot_rec      => lp_quot_rec
                                               ,p_assn_tbl      => lp_assn_tbl
                                               ,p_qpyv_tbl      => lp_qpyv_tbl
                                               ,x_quot_rec      => lx_quot_rec
                                               ,x_assn_tbl      => lx_assn_tbl
                                               ,x_tqlv_tbl      => lx_tqlv_tbl
											   ,p_term_from_intf => p_term_from_intf); --sechawla 15-jun-09 7383445 --added new parameter

  IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to OKL_AM_CREATE_QUOTE_PVT.create_terminate_quote :'||l_return_status);
  END IF;

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
 RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;


 --Copy value of OUT record type variable in the IN record type
 lp_quot_rec := lx_quot_rec;
 lp_assn_tbl := lx_assn_tbl;




--Assign value to OUT variables
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
x_quot_rec  := lx_quot_rec;
x_assn_tbl  := lx_assn_tbl;
x_tqlv_tbl  := lx_tqlv_tbl;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'USER DEFINED');
        END IF;
      ROLLBACK TO trx_create_terminate_quote;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'UNEXPECTED');
        END IF;
      ROLLBACK TO trx_create_terminate_quote;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
      ROLLBACK TO trx_create_terminate_quote;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_CREATE_QUOTE_PUB','create_terminate_quote');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

  END create_terminate_quote;


END OKL_AM_CREATE_QUOTE_PUB;

/
