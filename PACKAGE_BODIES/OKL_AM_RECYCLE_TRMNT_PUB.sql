--------------------------------------------------------
--  DDL for Package Body OKL_AM_RECYCLE_TRMNT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_RECYCLE_TRMNT_PUB" AS
/* $Header: OKLPRTXB.pls 120.3 2007/12/14 14:01:27 nikshah ship $ */

-- GLOBAL VARIABLES
  G_LEVEL_PROCEDURE            CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_EXCEPTION            CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_STATEMENT            CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME                CONSTANT VARCHAR2(500) := 'okl.am.plsql.okl_am_recycle_trmnt_pub.';

PROCEDURE recycle_termination(
    p_api_version                  	IN  NUMBER,
    p_init_msg_list                	IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_recy_rec					   	IN  recy_rec_type,
    x_recy_rec					   	OUT NOCOPY recy_rec_type) AS

    l_api_version NUMBER ;
    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);
    lp_recy_rec  recy_rec_type;
    lx_recy_rec  recy_rec_type;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'recycle_termination';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

BEGIN
SAVEPOINT trx_recycle_termination;
IF (is_debug_procedure_on) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
END IF;
IF (is_debug_statement_on) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_recy_rec.p_contract_id: ' || p_recy_rec.p_contract_id);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_recy_rec.p_contract_number: ' || p_recy_rec.p_contract_number);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_recy_rec.p_contract_status: ' || p_recy_rec.p_contract_status);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_recy_rec.p_transaction_id: ' || p_recy_rec.p_transaction_id);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_recy_rec.p_transaction_status: ' || p_recy_rec.p_transaction_status);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_recy_rec.p_tmt_recycle_yn: ' || p_recy_rec.p_tmt_recycle_yn);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_recy_rec.p_transaction_date: ' || p_recy_rec.p_transaction_date);
END IF;

l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_recy_rec :=  p_recy_rec;
lx_recy_rec :=  x_recy_rec;




-- call the insert of pvt

    IF (is_debug_statement_on) THEN
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_RECYCLE_TRMNT_PVT.recycle_termination');
    END IF;
	OKL_AM_RECYCLE_TRMNT_PVT.recycle_termination(  p_api_version => l_api_version
	                                              ,p_init_msg_list => l_init_msg_list
	                                              ,x_msg_data => l_msg_data
	                                              ,x_msg_count => l_msg_count
	                                              ,x_return_status => l_return_status
   	                                              ,p_recy_rec => lp_recy_rec
	                                              ,x_recy_rec => lx_recy_rec) ;
    IF (is_debug_statement_on) THEN
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_RECYCLE_TRMNT_PVT.recycle_termination , return status: ' || l_return_status);
    END IF;

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_recy_rec := lx_recy_rec;



--Assign value to OUT variables
x_recy_rec  := lx_recy_rec;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
IF (is_debug_procedure_on) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_recycle_termination;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXC_ERROR');
      END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_recycle_termination;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXC_UNEXPECTED_ERROR');
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO trx_recycle_termination;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_RECYCLE_TRMNT_PUB','recycle_termination');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
 			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;
END recycle_termination;

PROCEDURE recycle_termination(
    p_api_version                  	IN  NUMBER,
    p_init_msg_list                	IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_recy_tbl					   	IN  recy_tbl_type,
    x_recy_tbl					   	OUT NOCOPY recy_tbl_type) AS

    l_api_version NUMBER ;
    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);
    lp_recy_tbl  recy_tbl_type;
    lx_recy_tbl  recy_tbl_type;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'recycle_termination';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

BEGIN
SAVEPOINT trx_recycle_termination;
IF (is_debug_procedure_on) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
END IF;
IF (is_debug_statement_on) THEN
  FOR i IN p_recy_tbl.FIRST..p_recy_tbl.LAST
  LOOP
    IF p_recy_tbl.EXISTS(i) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_recy_tbl(' || i || ').p_contract_id: ' || p_recy_tbl(i).p_contract_id);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_recy_tbl(' || i || ').p_contract_number: ' || p_recy_tbl(i).p_contract_number);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_recy_tbl(' || i || ').p_contract_status: ' || p_recy_tbl(i).p_contract_status);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_recy_tbl(' || i || ').p_transaction_id: ' || p_recy_tbl(i).p_transaction_id);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_recy_tbl(' || i || ').p_transaction_status: ' || p_recy_tbl(i).p_transaction_status);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_recy_tbl(' || i || ').p_tmt_recycle_yn: ' || p_recy_tbl(i).p_tmt_recycle_yn);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_recy_tbl(' || i || ').p_transaction_date: ' || p_recy_tbl(i).p_transaction_date);
    END IF;
  END LOOP;
END IF;

l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_recy_tbl :=  p_recy_tbl;
lx_recy_tbl :=  x_recy_tbl;




-- call the insert of pvt

    IF (is_debug_statement_on) THEN
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_RECYCLE_TRMNT_PVT.recycle_termination');
    END IF;
	OKL_AM_RECYCLE_TRMNT_PVT.recycle_termination(  p_api_version => l_api_version
	                                              ,p_init_msg_list => l_init_msg_list
	                                              ,x_msg_data => l_msg_data
	                                              ,x_msg_count => l_msg_count
	                                              ,x_return_status => l_return_status
   	                                              ,p_recy_tbl => lp_recy_tbl
	                                              ,x_recy_tbl => lx_recy_tbl) ;
    IF (is_debug_statement_on) THEN
     OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_RECYCLE_TRMNT_PVT.recycle_termination , return status: ' || l_return_status);
    END IF;

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_recy_tbl := lx_recy_tbl;



--Assign value to OUT variables
x_recy_tbl  := lx_recy_tbl;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
IF (is_debug_procedure_on) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_recycle_termination;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXC_ERROR');
      END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_recycle_termination;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXC_UNEXPECTED_ERROR');
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO trx_recycle_termination;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_RECYCLE_TRMNT_PUB','recycle_termination');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
 			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;

END recycle_termination;

END OKL_AM_RECYCLE_TRMNT_PUB;

/
