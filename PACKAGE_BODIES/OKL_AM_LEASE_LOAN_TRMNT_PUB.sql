--------------------------------------------------------
--  DDL for Package Body OKL_AM_LEASE_LOAN_TRMNT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_LEASE_LOAN_TRMNT_PUB" AS
/* $Header: OKLPLLTB.pls 120.3 2007/12/14 13:58:25 nikshah ship $ */

-- GLOBAL VARIABLES
  G_LEVEL_PROCEDURE            CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_EXCEPTION            CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_STATEMENT            CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME                CONSTANT VARCHAR2(500) := 'okl.am.plsql.okl_am_lease_loan_trmnt_pub.';


PROCEDURE validate_contract(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_contract_id                 IN  NUMBER,
           p_control_flag                IN  VARCHAR2,
           x_contract_status             OUT NOCOPY VARCHAR2) AS

    l_api_version NUMBER ;
    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);
    lp_contract_id  NUMBER;
    lp_control_flag  VARCHAR2(200);
    lx_contract_status VARCHAR2(200);
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'validate_contract';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);


BEGIN
SAVEPOINT trx_validate_contract;
IF (is_debug_procedure_on) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
END IF;
IF (is_debug_statement_on) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_contract_id: ' || p_contract_id);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_control_flag: ' || p_control_flag);
END IF;
l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_contract_id := p_contract_id;
lp_control_flag := p_control_flag;
lx_contract_status := x_contract_status;




-- call the insert of pvt
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_LOAN_TRMNT_PVT.validate_contract');
    END IF;

	OKL_AM_LEASE_LOAN_TRMNT_PVT.validate_contract(
                                                p_api_version => l_api_version
	                                           ,p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_contract_id => lp_contract_id
	                                           ,p_control_flag => lp_control_flag
                                               ,x_contract_status => lx_contract_status) ;
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_LOAN_TRMNT_PVT.validate_contract , return status: ' || l_return_status);
    END IF;

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;




--Assign value to OUT variables
x_contract_status := lx_contract_status;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
IF (is_debug_procedure_on) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_validate_contract;
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
      ROLLBACK TO trx_validate_contract;
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
      ROLLBACK TO trx_validate_contract;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_LEASE_LOAN_TRMNT_PUB','validate_contract');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
 			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;
END validate_contract;



PROCEDURE lease_loan_termination(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_rec                    IN  term_rec_type,
           p_tcnv_rec                    IN  tcnv_rec_type) AS

    l_api_version NUMBER ;
    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);
    lp_term_rec  term_rec_type;
    lp_tcnv_rec  tcnv_rec_type;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'lease_loan_termination';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);



BEGIN
SAVEPOINT trx_lease_loan_termination;
IF (is_debug_procedure_on) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
END IF;
 IF (is_debug_statement_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_contract_id: ' || p_term_rec.p_contract_id);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_contract_number: ' || p_term_rec.p_contract_number);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_contract_modifier: ' || p_term_rec.p_contract_modifier);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_orig_end_date: ' || p_term_rec.p_orig_end_date);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_contract_version: ' || p_term_rec.p_contract_version);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_termination_date: ' || p_term_rec.p_termination_date);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_termination_reason: ' || p_term_rec.p_termination_reason);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_quote_id: ' || p_term_rec.p_quote_id);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_quote_type: ' || p_term_rec.p_quote_type);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_quote_reason: ' || p_term_rec.p_quote_reason);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_early_termination_yn: ' || p_term_rec.p_early_termination_yn);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_control_flag: ' || p_term_rec.p_control_flag);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.p_recycle_flag: ' || p_term_rec.p_recycle_flag);

   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.id: ' || p_tcnv_rec.id);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.rbr_code: ' || p_tcnv_rec.rbr_code);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.rpy_code: ' || p_tcnv_rec.rpy_code);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.rvn_code: ' || p_tcnv_rec.rvn_code);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.trn_code: ' || p_tcnv_rec.trn_code);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.khr_id_new: ' || p_tcnv_rec.khr_id_new);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.pvn_id: ' || p_tcnv_rec.pvn_id);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.pdt_id: ' || p_tcnv_rec.pdt_id);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.qte_id: ' || p_tcnv_rec.qte_id);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.aes_id: ' || p_tcnv_rec.aes_id);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.code_combination_id: ' || p_tcnv_rec.code_combination_id);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tax_deductible_local: ' || p_tcnv_rec.tax_deductible_local);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tax_deductible_corporate: ' || p_tcnv_rec.tax_deductible_corporate);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.accrual_status_yn: ' || p_tcnv_rec.accrual_status_yn);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.update_status_yn: ' || p_tcnv_rec.update_status_yn);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.amount: ' || p_tcnv_rec.amount);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.currency_code: ' || p_tcnv_rec.currency_code);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tcn_type: ' || p_tcnv_rec.tcn_type);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.rjn_code: ' || p_tcnv_rec.rjn_code);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.complete_transfer_yn: ' || p_tcnv_rec.complete_transfer_yn);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.org_id: ' || p_tcnv_rec.org_id);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.khr_id: ' || p_tcnv_rec.khr_id);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.khr_id_old: ' || p_tcnv_rec.khr_id_old);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.try_id: ' || p_tcnv_rec.try_id);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tsu_code: ' || p_tcnv_rec.tsu_code);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.set_of_books_id: ' || p_tcnv_rec.set_of_books_id);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.trx_number: ' || p_tcnv_rec.trx_number);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tmt_evergreen_yn: ' || p_tcnv_rec.tmt_evergreen_yn);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tmt_close_balances_yn: ' || p_tcnv_rec.tmt_close_balances_yn);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tmt_accounting_entries_yn: ' || p_tcnv_rec.tmt_accounting_entries_yn);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tmt_cancel_insurance_yn: ' || p_tcnv_rec.tmt_cancel_insurance_yn);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tmt_asset_disposition_yn: ' || p_tcnv_rec.tmt_asset_disposition_yn);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tmt_amortization_yn: ' || p_tcnv_rec.tmt_amortization_yn);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tmt_asset_return_yn: ' || p_tcnv_rec.tmt_asset_return_yn);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tmt_contract_updated_yn: ' || p_tcnv_rec.tmt_contract_updated_yn);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tmt_recycle_yn: ' || p_tcnv_rec.tmt_recycle_yn);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tmt_validated_yn: ' || p_tcnv_rec.tmt_validated_yn);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tmt_streams_updated_yn: ' || p_tcnv_rec.tmt_streams_updated_yn);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.accrual_activity: ' || p_tcnv_rec.accrual_activity);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tmt_split_asset_yn: ' || p_tcnv_rec.tmt_split_asset_yn);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.chr_id: ' || p_tcnv_rec.chr_id);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.source_trx_id: ' || p_tcnv_rec.source_trx_id);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.source_trx_type: ' || p_tcnv_rec.source_trx_type);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.legal_entity_id: ' || p_tcnv_rec.legal_entity_id);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.accounting_reversal_yn: ' || p_tcnv_rec.accounting_reversal_yn);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.product_name: ' || p_tcnv_rec.product_name);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.book_classification_code: ' || p_tcnv_rec.book_classification_code);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tax_owner_code: ' || p_tcnv_rec.tax_owner_code);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.tmt_status_code: ' || p_tcnv_rec.tmt_status_code);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_rec.representation_name: ' || p_tcnv_rec.representation_name);
 END IF;

l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_term_rec :=  p_term_rec;
lp_tcnv_rec :=  p_tcnv_rec;




-- call the insert of pvt
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_LOAN_TRMNT_PVT.lease_loan_termination');
    END IF;

	OKL_AM_LEASE_LOAN_TRMNT_PVT.lease_loan_termination(
                                                   p_api_version => l_api_version
	                                              ,p_init_msg_list => l_init_msg_list
	                                              ,x_msg_data => l_msg_data
	                                              ,x_msg_count => l_msg_count
	                                              ,x_return_status => l_return_status
	                                              ,p_term_rec => lp_term_rec
  	                                              ,p_tcnv_rec => lp_tcnv_rec) ;
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_LOAN_TRMNT_PVT.lease_loan_termination , return status: ' || l_return_status);
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
IF (is_debug_procedure_on) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_lease_loan_termination;
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
      ROLLBACK TO trx_lease_loan_termination;
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
      ROLLBACK TO trx_lease_loan_termination;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_LEASE_LOAN_TRMNT_PUB','lease_loan_termination');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
 			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;
END lease_loan_termination;


PROCEDURE lease_loan_termination(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_term_tbl                    IN  term_tbl_type,
           p_tcnv_tbl                    IN  tcnv_tbl_type) AS

    l_api_version NUMBER ;
    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);
    lp_term_tbl  term_tbl_type;
    lp_tcnv_tbl  tcnv_tbl_type;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'lease_loan_termination';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);



BEGIN
SAVEPOINT trx_lease_loan_termination;
IF (is_debug_procedure_on) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
END IF;
IF (is_debug_statement_on) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl.COUNT: ' || p_term_tbl.COUNT);
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tcnv_tbl.COUNT: ' || p_tcnv_tbl.COUNT);
END IF;
l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_term_tbl :=  p_term_tbl;
lp_tcnv_tbl :=  p_tcnv_tbl;




-- call the insert of pvt
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_LEASE_LOAN_TRMNT_PVT.lease_loan_termination');
    END IF;

	OKL_AM_LEASE_LOAN_TRMNT_PVT.lease_loan_termination(
                                                   p_api_version => l_api_version
	                                              ,p_init_msg_list => l_init_msg_list
	                                              ,x_msg_data => l_msg_data
	                                              ,x_msg_count => l_msg_count
	                                              ,x_return_status => l_return_status
	                                              ,p_term_tbl => lp_term_tbl
	                                              ,p_tcnv_tbl => lp_tcnv_tbl) ;

    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_LEASE_LOAN_TRMNT_PVT.lease_loan_termination , return status: ' || l_return_status);
    END IF;
/* -- do not roll back if error
IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
*/



--Assign value to OUT variables
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
IF (is_debug_procedure_on) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_lease_loan_termination;
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
      ROLLBACK TO trx_lease_loan_termination;
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
      ROLLBACK TO trx_lease_loan_termination;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_LEASE_LOAN_TRMNT_PUB','lease_loan_termination');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
 			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;
END lease_loan_termination;


END OKL_AM_LEASE_LOAN_TRMNT_PUB;

/
