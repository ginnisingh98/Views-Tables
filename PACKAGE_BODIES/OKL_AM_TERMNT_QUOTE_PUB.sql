--------------------------------------------------------
--  DDL for Package Body OKL_AM_TERMNT_QUOTE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_TERMNT_QUOTE_PUB" AS
/* $Header: OKLPTNQB.pls 120.4 2007/12/14 14:03:02 nikshah ship $ */

-- GLOBAL VARIABLES
  G_LEVEL_PROCEDURE            CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_EXCEPTION            CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_STATEMENT            CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME                CONSTANT VARCHAR2(500) := 'okl.am.plsql.okl_am_termnt_quote_pub.';

  --Bug #3921591: pagarg +++ Rollover +++
  -- additional parameter has been added to the call, to identify the acceptance source
  PROCEDURE terminate_quote(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_term_rec                      IN term_rec_type,
    x_term_rec                      OUT NOCOPY term_rec_type,
    x_err_msg                       OUT NOCOPY VARCHAR2,
    p_acceptance_source             IN  VARCHAR2 DEFAULT null) IS

    l_api_version NUMBER ;
    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);
    lp_term_rec  term_rec_type;
    lx_term_rec  term_rec_type;
    lx_err_msg  VARCHAR2(2000);
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'terminate_quote';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);


BEGIN
SAVEPOINT trx_terminate_quote;
 IF (is_debug_procedure_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
 END IF;
 IF (is_debug_statement_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_acceptance_source: ' || p_acceptance_source);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.id: ' || p_term_rec.id);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.qrs_code: ' || p_term_rec.qrs_code);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.qst_code: ' || p_term_rec.qst_code);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.qtp_code: ' || p_term_rec.qtp_code);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.trn_code: ' || p_term_rec.trn_code);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.pop_code_end: ' || p_term_rec.pop_code_end);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.pop_code_early: ' || p_term_rec.pop_code_early);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.consolidated_qte_id: ' || p_term_rec.consolidated_qte_id);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.khr_id: ' || p_term_rec.khr_id);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.art_id: ' || p_term_rec.art_id);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.pdt_id: ' || p_term_rec.pdt_id);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.early_termination_yn: ' || p_term_rec.early_termination_yn);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.partial_yn: ' || p_term_rec.partial_yn);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.preproceeds_yn: ' || p_term_rec.preproceeds_yn);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_requested: ' || p_term_rec.date_requested);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_proposal: ' || p_term_rec.date_proposal);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_effective_to: ' || p_term_rec.date_effective_to);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_accepted: ' || p_term_rec.date_accepted);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.summary_format_yn: ' || p_term_rec.summary_format_yn);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.consolidated_yn: ' || p_term_rec.consolidated_yn);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.principal_paydown_amount: ' || p_term_rec.principal_paydown_amount);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.residual_amount: ' || p_term_rec.residual_amount);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.yield: ' || p_term_rec.yield);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.rent_amount: ' || p_term_rec.rent_amount);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_restructure_end: ' || p_term_rec.date_restructure_end);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_restructure_start: ' || p_term_rec.date_restructure_start);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.term: ' || p_term_rec.term);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.purchase_percent: ' || p_term_rec.purchase_percent);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_due: ' || p_term_rec.date_due);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.payment_frequency: ' || p_term_rec.payment_frequency);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.remaining_payments: ' || p_term_rec.remaining_payments);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_effective_from: ' || p_term_rec.date_effective_from);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.quote_number: ' || p_term_rec.quote_number);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.approved_yn: ' || p_term_rec.approved_yn);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.accepted_yn: ' || p_term_rec.accepted_yn);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.payment_received_yn: ' || p_term_rec.payment_received_yn);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_payment_received: ' || p_term_rec.date_payment_received);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_approved: ' || p_term_rec.date_approved);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.approved_by: ' || p_term_rec.approved_by);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.org_id: ' || p_term_rec.org_id);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.purchase_amount: ' || p_term_rec.purchase_amount);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.purchase_formula: ' || p_term_rec.purchase_formula);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.asset_value: ' || p_term_rec.asset_value);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.residual_value: ' || p_term_rec.residual_value);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.unbilled_receivables: ' || p_term_rec.unbilled_receivables);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.gain_loss: ' || p_term_rec.gain_loss);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.PERDIEM_AMOUNT: ' || p_term_rec.PERDIEM_AMOUNT);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.currency_code: ' || p_term_rec.currency_code);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.currency_conversion_code: ' || p_term_rec.currency_conversion_code);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.currency_conversion_type: ' || p_term_rec.currency_conversion_type);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.currency_conversion_rate: ' || p_term_rec.currency_conversion_rate);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.currency_conversion_date: ' || p_term_rec.currency_conversion_date);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.legal_entity_id: ' || p_term_rec.legal_entity_id);
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.repo_quote_indicator_yn: ' || p_term_rec.repo_quote_indicator_yn);
 END IF;

l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_term_rec :=  p_term_rec;




-- call the insert of pvt
  --Bug #3921591: pagarg +++ Rollover +++
  -- additional parameter has been added to the call, to identify the acceptance source
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_TERMNT_QUOTE_PVT.terminate_quote');
    END IF;

	OKL_AM_TERMNT_QUOTE_PVT.terminate_quote(
                                               p_api_version       => l_api_version
	                                          ,p_init_msg_list     => l_init_msg_list
	                                          ,x_msg_data          => l_msg_data
	                                          ,x_msg_count         => l_msg_count
	                                          ,x_return_status     => l_return_status
	                                          ,p_term_rec          => lp_term_rec
  	                                          ,x_term_rec          => lx_term_rec
	                                          ,x_err_msg           => lx_err_msg
                                              ,p_acceptance_source => p_acceptance_source);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_TERMNT_QUOTE_PVT.terminate_quote , return status: ' || l_return_status);
    END IF;

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

	--Copy value of OUT record type variable in the IN record type
	lp_term_rec := lx_term_rec;



--Assign value to OUT variables
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
x_term_rec  := lx_term_rec;
x_err_msg  := lx_err_msg;
IF (is_debug_procedure_on) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_terminate_quote;
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
      ROLLBACK TO trx_terminate_quote;
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
      ROLLBACK TO trx_terminate_quote;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_TERMNT_QUOTE_PUB','terminate_quote');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;


END terminate_quote;

  --Bug #3921591: pagarg +++ Rollover +++
  -- additional parameter has been added to the call, to identify the acceptance source
  PROCEDURE terminate_quote(
    p_api_version                  	IN NUMBER,
    p_init_msg_list                	IN VARCHAR2,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_term_tbl                      IN term_tbl_type,
    x_term_tbl                      OUT NOCOPY term_tbl_type,
    x_err_msg                       OUT NOCOPY VARCHAR2,
    p_acceptance_source             IN  VARCHAR2 DEFAULT null) IS

    l_api_version NUMBER ;
    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);
    lp_term_tbl  term_tbl_type;
    lx_term_tbl  term_tbl_type;
    lx_err_msg  VARCHAR2(2000);
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'terminate_quote';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);


BEGIN
SAVEPOINT trx_terminate_quote;
 IF (is_debug_procedure_on) THEN
   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
 END IF;
 IF (is_debug_statement_on) THEN
   FOR i IN p_term_tbl.FIRST..p_term_tbl.LAST LOOP
     IF (p_term_tbl.exists(i)) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_acceptance_source: ' || p_acceptance_source);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').id: ' || p_term_tbl(i).id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').qrs_code: ' || p_term_tbl(i).qrs_code);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').qst_code: ' || p_term_tbl(i).qst_code);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').qtp_code: ' || p_term_tbl(i).qtp_code);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').trn_code: ' || p_term_tbl(i).trn_code);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').pop_code_end: ' || p_term_tbl(i).pop_code_end);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').pop_code_early: ' || p_term_tbl(i).pop_code_early);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').consolidated_qte_id: ' || p_term_tbl(i).consolidated_qte_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').khr_id: ' || p_term_tbl(i).khr_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').art_id: ' || p_term_tbl(i).art_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').pdt_id: ' || p_term_tbl(i).pdt_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').early_termination_yn: ' || p_term_tbl(i).early_termination_yn);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').partial_yn: ' || p_term_tbl(i).partial_yn);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').preproceeds_yn: ' || p_term_tbl(i).preproceeds_yn);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').date_requested: ' || p_term_tbl(i).date_requested);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').date_proposal: ' || p_term_tbl(i).date_proposal);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').date_effective_to: ' || p_term_tbl(i).date_effective_to);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').date_accepted: ' || p_term_tbl(i).date_accepted);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').summary_format_yn: ' || p_term_tbl(i).summary_format_yn);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').consolidated_yn: ' || p_term_tbl(i).consolidated_yn);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').principal_paydown_amount: ' || p_term_tbl(i).principal_paydown_amount);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').residual_amount: ' || p_term_tbl(i).residual_amount);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').yield: ' || p_term_tbl(i).yield);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').rent_amount: ' || p_term_tbl(i).rent_amount);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').date_restructure_end: ' || p_term_tbl(i).date_restructure_end);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').date_restructure_start: ' || p_term_tbl(i).date_restructure_start);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').term: ' || p_term_tbl(i).term);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').purchase_percent: ' || p_term_tbl(i).purchase_percent);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').date_due: ' || p_term_tbl(i).date_due);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').payment_frequency: ' || p_term_tbl(i).payment_frequency);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').remaining_payments: ' || p_term_tbl(i).remaining_payments);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').date_effective_from: ' || p_term_tbl(i).date_effective_from);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').quote_number: ' || p_term_tbl(i).quote_number);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').approved_yn: ' || p_term_tbl(i).approved_yn);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').accepted_yn: ' || p_term_tbl(i).accepted_yn);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').payment_received_yn: ' || p_term_tbl(i).payment_received_yn);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').date_payment_received: ' || p_term_tbl(i).date_payment_received);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').date_approved: ' || p_term_tbl(i).date_approved);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').approved_by: ' || p_term_tbl(i).approved_by);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').org_id: ' || p_term_tbl(i).org_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').purchase_amount: ' || p_term_tbl(i).purchase_amount);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').purchase_formula: ' || p_term_tbl(i).purchase_formula);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').asset_value: ' || p_term_tbl(i).asset_value);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').residual_value: ' || p_term_tbl(i).residual_value);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').unbilled_receivables: ' || p_term_tbl(i).unbilled_receivables);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').gain_loss: ' || p_term_tbl(i).gain_loss);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').PERDIEM_AMOUNT: ' || p_term_tbl(i).PERDIEM_AMOUNT);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').currency_code: ' || p_term_tbl(i).currency_code);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').currency_conversion_code: ' || p_term_tbl(i).currency_conversion_code);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').currency_conversion_type: ' || p_term_tbl(i).currency_conversion_type);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').currency_conversion_rate: ' || p_term_tbl(i).currency_conversion_rate);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').currency_conversion_date: ' || p_term_tbl(i).currency_conversion_date);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').legal_entity_id: ' || p_term_tbl(i).legal_entity_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_tbl(' || i || ').repo_quote_indicator_yn: ' || p_term_tbl(i).repo_quote_indicator_yn);
     END IF;
   END LOOP;
 END IF;

l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_term_tbl :=  p_term_tbl;




-- call the insert of pvt

  --Bug #3921591: pagarg +++ Rollover +++
  -- additional parameter has been added to the call, to identify the acceptance source

    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_TERMNT_QUOTE_PVT.terminate_quote');
    END IF;
	OKL_AM_TERMNT_QUOTE_PVT.terminate_quote(
                                             p_api_version       => l_api_version
	                                        ,p_init_msg_list     => l_init_msg_list
	                                        ,x_msg_data          => l_msg_data
	                                        ,x_msg_count         => l_msg_count
	                                        ,x_return_status     => l_return_status
	                                        ,p_term_tbl          => lp_term_tbl
  	                                        ,x_term_tbl          => lx_term_tbl
	                                        ,x_err_msg           => lx_err_msg
                                            ,p_acceptance_source => p_acceptance_source);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_TERMNT_QUOTE_PVT.terminate_quote , return status: ' || l_return_status);
    END IF;

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

	--Copy value of OUT record type variable in the IN record type
	lp_term_tbl := lx_term_tbl;



--Assign value to OUT variables
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
x_term_tbl  := lx_term_tbl;
x_err_msg  := lx_err_msg;
IF (is_debug_procedure_on) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_terminate_quote;
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
      ROLLBACK TO trx_terminate_quote;
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
      ROLLBACK TO trx_terminate_quote;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_TERMNT_QUOTE_PUB','terminate_quote');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;


   END terminate_quote;

    PROCEDURE submit_for_approval(
        p_api_version                  	IN NUMBER,
        p_init_msg_list                	IN VARCHAR2,
        x_return_status                	OUT NOCOPY VARCHAR2,
        x_msg_count                    	OUT NOCOPY NUMBER,
        x_msg_data                     	OUT NOCOPY VARCHAR2,
        p_term_rec                      IN term_rec_type,
        x_term_rec                      OUT NOCOPY term_rec_type)  IS

        l_api_version NUMBER ;
        l_init_msg_list VARCHAR2(1) ;
        l_return_status VARCHAR2(1);
        l_msg_count NUMBER ;
        l_msg_data VARCHAR2(2000);
        lp_term_rec  term_rec_type;
        lx_term_rec  term_rec_type;
        l_module_name VARCHAR2(500) := G_MODULE_NAME || 'submit_for_approval';
        is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
        is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
        is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

    BEGIN
        SAVEPOINT submit_for_approval;
        IF (is_debug_procedure_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
        END IF;
		 IF (is_debug_statement_on) THEN
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.id: ' || p_term_rec.id);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.qrs_code: ' || p_term_rec.qrs_code);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.qst_code: ' || p_term_rec.qst_code);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.qtp_code: ' || p_term_rec.qtp_code);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.trn_code: ' || p_term_rec.trn_code);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.pop_code_end: ' || p_term_rec.pop_code_end);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.pop_code_early: ' || p_term_rec.pop_code_early);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.consolidated_qte_id: ' || p_term_rec.consolidated_qte_id);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.khr_id: ' || p_term_rec.khr_id);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.art_id: ' || p_term_rec.art_id);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.pdt_id: ' || p_term_rec.pdt_id);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.early_termination_yn: ' || p_term_rec.early_termination_yn);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.partial_yn: ' || p_term_rec.partial_yn);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.preproceeds_yn: ' || p_term_rec.preproceeds_yn);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_requested: ' || p_term_rec.date_requested);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_proposal: ' || p_term_rec.date_proposal);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_effective_to: ' || p_term_rec.date_effective_to);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_accepted: ' || p_term_rec.date_accepted);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.summary_format_yn: ' || p_term_rec.summary_format_yn);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.consolidated_yn: ' || p_term_rec.consolidated_yn);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.principal_paydown_amount: ' || p_term_rec.principal_paydown_amount);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.residual_amount: ' || p_term_rec.residual_amount);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.yield: ' || p_term_rec.yield);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.rent_amount: ' || p_term_rec.rent_amount);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_restructure_end: ' || p_term_rec.date_restructure_end);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_restructure_start: ' || p_term_rec.date_restructure_start);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.term: ' || p_term_rec.term);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.purchase_percent: ' || p_term_rec.purchase_percent);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_due: ' || p_term_rec.date_due);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.payment_frequency: ' || p_term_rec.payment_frequency);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.remaining_payments: ' || p_term_rec.remaining_payments);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_effective_from: ' || p_term_rec.date_effective_from);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.quote_number: ' || p_term_rec.quote_number);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.approved_yn: ' || p_term_rec.approved_yn);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.accepted_yn: ' || p_term_rec.accepted_yn);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.payment_received_yn: ' || p_term_rec.payment_received_yn);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_payment_received: ' || p_term_rec.date_payment_received);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.date_approved: ' || p_term_rec.date_approved);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.approved_by: ' || p_term_rec.approved_by);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.org_id: ' || p_term_rec.org_id);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.purchase_amount: ' || p_term_rec.purchase_amount);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.purchase_formula: ' || p_term_rec.purchase_formula);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.asset_value: ' || p_term_rec.asset_value);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.residual_value: ' || p_term_rec.residual_value);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.unbilled_receivables: ' || p_term_rec.unbilled_receivables);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.gain_loss: ' || p_term_rec.gain_loss);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.PERDIEM_AMOUNT: ' || p_term_rec.PERDIEM_AMOUNT);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.currency_code: ' || p_term_rec.currency_code);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.currency_conversion_code: ' || p_term_rec.currency_conversion_code);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.currency_conversion_type: ' || p_term_rec.currency_conversion_type);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.currency_conversion_rate: ' || p_term_rec.currency_conversion_rate);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.currency_conversion_date: ' || p_term_rec.currency_conversion_date);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.legal_entity_id: ' || p_term_rec.legal_entity_id);
		   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_term_rec.repo_quote_indicator_yn: ' || p_term_rec.repo_quote_indicator_yn);
		 END IF;

        l_api_version := p_api_version ;
        l_init_msg_list := p_init_msg_list ;
        l_return_status := x_return_status ;
        l_msg_count := x_msg_count ;
        l_msg_data := x_msg_data ;
        lp_term_rec :=  p_term_rec;

        -- call the private procedure
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_TERMNT_QUOTE_PVT.submit_for_approval');
        END IF;
        OKL_AM_TERMNT_QUOTE_PVT.submit_for_approval(
                                                   p_api_version   => l_api_version
	                                              ,p_init_msg_list => l_init_msg_list
	                                              ,x_msg_data      => l_msg_data
	                                              ,x_msg_count     => l_msg_count
	                                              ,x_return_status => l_return_status
	                                              ,p_term_rec      => lp_term_rec
  	                                              ,x_term_rec      => lx_term_rec);
        IF (is_debug_statement_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_TERMNT_QUOTE_PVT.submit_for_approval , return status: ' || l_return_status);
        END IF;

        IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
        	RAISE FND_API.G_EXC_ERROR;
        ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    	--Copy value of OUT record type variable in the IN record type
    	lp_term_rec := lx_term_rec;

        --Assign value to OUT variables
        x_return_status := l_return_status ;
        x_msg_count := l_msg_count ;
        x_msg_data := l_msg_data ;
        x_term_rec  := lx_term_rec;
        IF (is_debug_procedure_on) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
        END IF;

        EXCEPTION

            WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO submit_for_approval;
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
              ROLLBACK TO submit_for_approval;
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
              ROLLBACK TO submit_for_approval;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              x_msg_count := l_msg_count ;
              x_msg_data := l_msg_data ;
              FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_TERMNT_QUOTE_PUB','submit_for_approval');
              FND_MSG_PUB.count_and_get(
                     p_count   => x_msg_count
                    ,p_data    => x_msg_data);
              IF (is_debug_exception_on) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
              END IF;

    END submit_for_approval;
----------------------------------------------------------------------------------------------------
  FUNCTION check_asset_sno(p_asset_line IN OKL_K_LINES.ID%TYPE,
                           x_sno_yn     OUT NOCOPY VARCHAR2,
                           x_clev_tbl   OUT NOCOPY clev_tbl_type) RETURN VARCHAR2 IS
    l_clev_tbl      clev_tbl_type;
    l_asset_line    OKL_K_LINES.ID%TYPE;
    l_sno_yn        VARCHAR(3);
    l_return_status VARCHAR2(3) := FND_API.G_RET_STS_SUCCESS;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'check_asset_sno';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN
    SAVEPOINT check_assset_sno_sav;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_asset_line: ' || p_asset_line);
    END IF;
    l_clev_tbl   := x_clev_tbl;
    l_asset_line := p_asset_line;
    l_sno_yn     := x_sno_yn;
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_TERMNT_QUOTE_PVT.check_asset_sno');
    END IF;
    l_return_status := OKL_AM_TERMNT_QUOTE_PVT.check_asset_sno(p_asset_line => l_asset_line,
                                            x_sno_yn     => l_sno_yn,
                                            x_clev_tbl   => l_clev_tbl);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_TERMNT_QUOTE_PVT.check_asset_sno , return status: ' || l_return_status);
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'l_sno_yn: ' || l_sno_yn);
    END IF;

    IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Assign value to OUT variables
    x_sno_yn     := l_sno_yn;
    x_clev_tbl   := l_clev_tbl;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

    RETURN l_return_status;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO check_assset_sno_sav;
      l_return_status := FND_API.G_RET_STS_ERROR;
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXC_ERROR');
      END IF;
      RETURN l_return_status;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO check_assset_sno_sav;
      l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXC_UNEXPECTED_ERROR');
      END IF;
      RETURN l_return_status;
    WHEN OTHERS THEN
      ROLLBACK TO check_assset_sno_sav;
      l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_TERMNT_QUOTE_PUB','check_assset_sno_sav');
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;
      RETURN l_return_status;
  END check_asset_sno;
---------------------------------------------------------------------------------------------------
  PROCEDURE quote_line_dtls(p_api_version      IN  NUMBER,
                            p_init_msg_list    IN  VARCHAR2,
                            x_return_status    OUT NOCOPY VARCHAR2,
                            x_msg_count        OUT NOCOPY NUMBER,
                            x_msg_data         OUT NOCOPY VARCHAR2,
                            p_qld_tbl          IN OUT NOCOPY qte_ln_dtl_tbl) IS
    l_api_version      NUMBER ;
    l_init_msg_list    VARCHAR2(3) ;
    l_msg_count        NUMBER ;
    l_msg_data         VARCHAR2(2000);
    l_qld_tbl          qte_ln_dtl_tbl;
    l_return_status    VARCHAR2(3) := FND_API.G_RET_STS_SUCCESS;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'quote_line_dtls';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN
    SAVEPOINT quote_line_dtls;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
	 IF (is_debug_statement_on) THEN
	   FOR i IN p_qld_tbl.FIRST..p_qld_tbl.LAST LOOP
	     IF (p_qld_tbl.exists(i)) THEN
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qld_tbl(' || i || ').qst_code: ' || p_qld_tbl(i).qst_code);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qld_tbl(' || i || ').qte_id: ' || p_qld_tbl(i).qte_id);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qld_tbl(' || i || ').instance_quantity: ' || p_qld_tbl(i).instance_quantity);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qld_tbl(' || i || ').tql_id: ' || p_qld_tbl(i).tql_id);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qld_tbl(' || i || ').tqd_id: ' || p_qld_tbl(i).tqd_id);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qld_tbl(' || i || ').select_yn: ' || p_qld_tbl(i).select_yn);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qld_tbl(' || i || ').ib_line_id: ' || p_qld_tbl(i).ib_line_id);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qld_tbl(' || i || ').fin_line_id: ' || p_qld_tbl(i).fin_line_id);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_qld_tbl(' || i || ').dnz_chr_id: ' || p_qld_tbl(i).dnz_chr_id);
	     END IF;
	   END LOOP;
	 END IF;
    l_api_version   := p_api_version;
    l_init_msg_list := p_init_msg_list;
    l_qld_tbl       := p_qld_tbl;
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_TERMNT_QUOTE_PVT.quote_line_dtls');
    END IF;
    OKL_AM_TERMNT_QUOTE_PVT.quote_line_dtls(p_api_version   => l_api_version,
                                            p_init_msg_list => l_init_msg_list,
                                            x_return_status => l_return_status,
                                            x_msg_count     => l_msg_count,
                                            x_msg_data      => l_msg_data,
                                            p_qld_tbl       => l_qld_tbl);
    IF (is_debug_statement_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_TERMNT_QUOTE_PVT.quote_line_dtls , return status: ' || l_return_status);
    END IF;

    IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Assign value to OUT variables
    p_qld_tbl   := l_qld_tbl;
    x_return_status := l_return_status ;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    IF (is_debug_procedure_on) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO quote_line_dtls;
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
      ROLLBACK TO quote_line_dtls;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
       FND_MSG_PUB.count_and_get(
                   p_count   => x_msg_count
                  ,p_data    => x_msg_data);
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXC_UNEXPECTED_ERROR');
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO quote_line_dtls;
      l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_TERMNT_QUOTE_PUB','quote_line_dtls');
      FND_MSG_PUB.count_and_get(
                   p_count   => x_msg_count
                  ,p_data    => x_msg_data);
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;
  END quote_line_dtls;




  -- Start of comments
  --
  -- Function  Name  : create_quote_line
  -- Description     : Creates quote line
  -- Business Rules  :
  -- Parameters      : Input parameters : p_tqlv_rec
  --                   Output Parameters : X_tqlv_rec
  -- Version         : 1.0
  -- History         : 23-DEC-02 RMUNJULU 2726739 Created
  -- End of comments
  PROCEDURE create_quote_line(
               p_api_version    IN NUMBER,
               p_init_msg_list  IN VARCHAR2 DEFAULT G_FALSE,
               x_return_status  OUT NOCOPY VARCHAR2,
               x_msg_count      OUT NOCOPY NUMBER,
               x_msg_data       OUT NOCOPY VARCHAR2,
               p_tqlv_rec       IN tqlv_rec_type,
               x_tqlv_rec       OUT NOCOPY tqlv_rec_type) IS


    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    lp_tqlv_rec tqlv_rec_type := p_tqlv_rec;
    lx_tqlv_rec tqlv_rec_type := p_tqlv_rec;
    l_api_name VARCHAR2(30) := 'create_quote_line';
    l_api_version NUMBER := p_api_version;
    l_init_msg_list VARCHAR2(1) := p_init_msg_list;
    l_msg_count NUMBER := x_msg_count;
    l_msg_data VARCHAR2(2000) := x_msg_data;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'create_quote_line';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);


  BEGIN


     -- Create Savepoint
     SAVEPOINT trx_create_quote_line;

     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;
	 IF (is_debug_statement_on) THEN
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.id: ' || p_tqlv_rec.id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.qlt_code: ' || p_tqlv_rec.qlt_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.kle_id: ' || p_tqlv_rec.kle_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.sty_id: ' || p_tqlv_rec.sty_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.qte_id: ' || p_tqlv_rec.qte_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.line_number: ' || p_tqlv_rec.line_number);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.amount: ' || p_tqlv_rec.amount);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.modified_yn: ' || p_tqlv_rec.modified_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.taxed_yn: ' || p_tqlv_rec.taxed_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.defaulted_yn: ' || p_tqlv_rec.defaulted_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.org_id: ' || p_tqlv_rec.org_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.start_date: ' || p_tqlv_rec.start_date);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.period: ' || p_tqlv_rec.period);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.number_of_periods: ' || p_tqlv_rec.number_of_periods);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.lock_level_step: ' || p_tqlv_rec.lock_level_step);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.advance_or_arrears: ' || p_tqlv_rec.advance_or_arrears);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.yield_name: ' || p_tqlv_rec.yield_name);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.yield_value: ' || p_tqlv_rec.yield_value);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.implicit_interest_rate: ' || p_tqlv_rec.implicit_interest_rate);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.asset_value: ' || p_tqlv_rec.asset_value);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.residual_value: ' || p_tqlv_rec.residual_value);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.unbilled_receivables: ' || p_tqlv_rec.unbilled_receivables);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.asset_quantity: ' || p_tqlv_rec.asset_quantity);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.quote_quantity: ' || p_tqlv_rec.quote_quantity);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.split_kle_id: ' || p_tqlv_rec.split_kle_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.split_kle_name: ' || p_tqlv_rec.split_kle_name);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_code: ' || p_tqlv_rec.currency_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_conversion_code: ' || p_tqlv_rec.currency_conversion_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_conversion_type: ' || p_tqlv_rec.currency_conversion_type);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_conversion_rate: ' || p_tqlv_rec.currency_conversion_rate);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_conversion_date: ' || p_tqlv_rec.currency_conversion_date);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.due_date: ' || p_tqlv_rec.due_date);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.try_id: ' || p_tqlv_rec.try_id);
	 END IF;

     -- Insert line into table using PVT
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_TERMNT_QUOTE_PVT.create_quote_line');
     END IF;
     OKL_AM_TERMNT_QUOTE_PVT.create_quote_line(
               p_api_version   => l_api_version,
               p_init_msg_list => l_init_msg_list,
               x_return_status => l_return_status,
               x_msg_count     => l_msg_count,
               x_msg_data      => l_msg_data,
               p_tqlv_rec      => lp_tqlv_rec,
               x_tqlv_rec      => lx_tqlv_rec);
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_TERMNT_QUOTE_PVT.create_quote_line , return status: ' || l_return_status);
     END IF;


     -- raise exception if error
     IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;


     -- Assign value to OUT variables
     x_return_status := l_return_status ;
     x_msg_count := l_msg_count ;
     x_msg_data := l_msg_data ;
     x_tqlv_rec := lx_tqlv_rec;
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
     END IF;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO trx_create_quote_line;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXC_ERROR');
      END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO trx_create_quote_line;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXC_UNEXPECTED_ERROR');
      END IF;

    WHEN OTHERS THEN

      ROLLBACK TO trx_create_quote_line;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_TERMNT_QUOTE_PUB',l_api_name);
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;


  END create_quote_line;


  -- Start of comments
  --
  -- Function  Name  : create_quote_line
  -- Description     : Creates quote lines
  -- Business Rules  :
  -- Parameters      : Input parameters : p_tqlv_tbl
  --                   Output Parameters : x_tqlv_tbl
  -- Version         : 1.0
  -- History         : 23-DEC-02 RMUNJULU 2726739 Created
  -- End of comments
  PROCEDURE create_quote_line(
               p_api_version    IN NUMBER,
               p_init_msg_list  IN VARCHAR2 DEFAULT G_FALSE,
               x_return_status  OUT NOCOPY VARCHAR2,
               x_msg_count      OUT NOCOPY NUMBER,
               x_msg_data       OUT NOCOPY VARCHAR2,
               p_tqlv_tbl       IN tqlv_tbl_type,
               x_tqlv_tbl       OUT NOCOPY tqlv_tbl_type) IS


    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    lp_tqlv_tbl tqlv_tbl_type := p_tqlv_tbl;
    lx_tqlv_tbl tqlv_tbl_type := p_tqlv_tbl;
    l_api_name VARCHAR2(30) := 'create_quote_line';
    l_api_version NUMBER := p_api_version;
    l_init_msg_list VARCHAR2(1) := p_init_msg_list;
    l_msg_count NUMBER := x_msg_count;
    l_msg_data VARCHAR2(2000) := x_msg_data;

    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'create_quote_line';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN


     -- Create Savepoint
     SAVEPOINT trx_create_quote_line;

     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;
	 IF (is_debug_statement_on) THEN
	   FOR i IN p_tqlv_tbl.FIRST..p_tqlv_tbl.LAST LOOP
	     IF (p_tqlv_tbl.exists(i)) THEN
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').id: ' || p_tqlv_tbl(i).id);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').qlt_code: ' || p_tqlv_tbl(i).qlt_code);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').kle_id: ' || p_tqlv_tbl(i).kle_id);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').sty_id: ' || p_tqlv_tbl(i).sty_id);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').qte_id: ' || p_tqlv_tbl(i).qte_id);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').line_number: ' || p_tqlv_tbl(i).line_number);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').amount: ' || p_tqlv_tbl(i).amount);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').modified_yn: ' || p_tqlv_tbl(i).modified_yn);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').taxed_yn: ' || p_tqlv_tbl(i).taxed_yn);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').defaulted_yn: ' || p_tqlv_tbl(i).defaulted_yn);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').org_id: ' || p_tqlv_tbl(i).org_id);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').start_date: ' || p_tqlv_tbl(i).start_date);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').period: ' || p_tqlv_tbl(i).period);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').number_of_periods: ' || p_tqlv_tbl(i).number_of_periods);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').lock_level_step: ' || p_tqlv_tbl(i).lock_level_step);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').advance_or_arrears: ' || p_tqlv_tbl(i).advance_or_arrears);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').yield_name: ' || p_tqlv_tbl(i).yield_name);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').yield_value: ' || p_tqlv_tbl(i).yield_value);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').implicit_interest_rate: ' || p_tqlv_tbl(i).implicit_interest_rate);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').asset_value: ' || p_tqlv_tbl(i).asset_value);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').residual_value: ' || p_tqlv_tbl(i).residual_value);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').unbilled_receivables: ' || p_tqlv_tbl(i).unbilled_receivables);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').asset_quantity: ' || p_tqlv_tbl(i).asset_quantity);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').quote_quantity: ' || p_tqlv_tbl(i).quote_quantity);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').split_kle_id: ' || p_tqlv_tbl(i).split_kle_id);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').split_kle_name: ' || p_tqlv_tbl(i).split_kle_name);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').currency_code: ' || p_tqlv_tbl(i).currency_code);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').currency_conversion_code: ' || p_tqlv_tbl(i).currency_conversion_code);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').currency_conversion_type: ' || p_tqlv_tbl(i).currency_conversion_type);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').currency_conversion_rate: ' || p_tqlv_tbl(i).currency_conversion_rate);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').currency_conversion_date: ' || p_tqlv_tbl(i).currency_conversion_date);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').due_date: ' || p_tqlv_tbl(i).due_date);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').try_id: ' || p_tqlv_tbl(i).try_id);
	      END IF;
	   END LOOP;
	 END IF;

     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_TERMNT_QUOTE_PVT.create_quote_line');
     END IF;
     -- Insert line into table using PVT
     OKL_AM_TERMNT_QUOTE_PVT.create_quote_line(
               p_api_version   => l_api_version,
               p_init_msg_list => l_init_msg_list,
               x_return_status => l_return_status,
               x_msg_count     => l_msg_count,
               x_msg_data      => l_msg_data,
               p_tqlv_tbl      => lp_tqlv_tbl,
               x_tqlv_tbl      => lx_tqlv_tbl);
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_TERMNT_QUOTE_PVT.create_quote_line , return status: ' || l_return_status);
     END IF;


     -- raise exception if error
     IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;


     -- Assign value to OUT variables
     x_return_status := l_return_status ;
     x_msg_count := l_msg_count ;
     x_msg_data := l_msg_data ;
     x_tqlv_tbl := lx_tqlv_tbl;
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
     END IF;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO trx_create_quote_line;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXC_ERROR');
      END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO trx_create_quote_line;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXC_UNEXPECTED_ERROR');
      END IF;

    WHEN OTHERS THEN

      ROLLBACK TO trx_create_quote_line;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_TERMNT_QUOTE_PUB',l_api_name);
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;

  END create_quote_line;


  -- Start of comments
  --
  -- Function  Name  : update_quote_line
  -- Description     : Updates quote line
  -- Business Rules  :
  -- Parameters      : Input parameters : p_tqlv_rec
  --                   Output Parameters : X_tqlv_rec
  -- Version         : 1.0
  -- History         : 23-DEC-02 RMUNJULU 2726739 Created
  -- End of comments
  PROCEDURE update_quote_line(
               p_api_version    IN NUMBER,
               p_init_msg_list  IN VARCHAR2 DEFAULT G_FALSE,
               x_return_status  OUT NOCOPY VARCHAR2,
               x_msg_count      OUT NOCOPY NUMBER,
               x_msg_data       OUT NOCOPY VARCHAR2,
               p_tqlv_rec       IN tqlv_rec_type,
               x_tqlv_rec       OUT NOCOPY tqlv_rec_type) IS


    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    lp_tqlv_rec tqlv_rec_type := p_tqlv_rec;
    lx_tqlv_rec tqlv_rec_type := p_tqlv_rec;
    l_api_name VARCHAR2(30) := 'update_quote_line';
    l_api_version NUMBER := p_api_version;
    l_init_msg_list VARCHAR2(1) := p_init_msg_list;
    l_msg_count NUMBER := x_msg_count;
    l_msg_data VARCHAR2(2000) := x_msg_data;
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'update_quote_line';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);


  BEGIN


     -- Create Savepoint
     SAVEPOINT trx_update_quote_line;
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;
	 IF (is_debug_statement_on) THEN
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.id: ' || p_tqlv_rec.id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.qlt_code: ' || p_tqlv_rec.qlt_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.kle_id: ' || p_tqlv_rec.kle_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.sty_id: ' || p_tqlv_rec.sty_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.qte_id: ' || p_tqlv_rec.qte_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.line_number: ' || p_tqlv_rec.line_number);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.amount: ' || p_tqlv_rec.amount);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.modified_yn: ' || p_tqlv_rec.modified_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.taxed_yn: ' || p_tqlv_rec.taxed_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.defaulted_yn: ' || p_tqlv_rec.defaulted_yn);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.org_id: ' || p_tqlv_rec.org_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.start_date: ' || p_tqlv_rec.start_date);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.period: ' || p_tqlv_rec.period);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.number_of_periods: ' || p_tqlv_rec.number_of_periods);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.lock_level_step: ' || p_tqlv_rec.lock_level_step);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.advance_or_arrears: ' || p_tqlv_rec.advance_or_arrears);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.yield_name: ' || p_tqlv_rec.yield_name);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.yield_value: ' || p_tqlv_rec.yield_value);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.implicit_interest_rate: ' || p_tqlv_rec.implicit_interest_rate);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.asset_value: ' || p_tqlv_rec.asset_value);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.residual_value: ' || p_tqlv_rec.residual_value);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.unbilled_receivables: ' || p_tqlv_rec.unbilled_receivables);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.asset_quantity: ' || p_tqlv_rec.asset_quantity);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.quote_quantity: ' || p_tqlv_rec.quote_quantity);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.split_kle_id: ' || p_tqlv_rec.split_kle_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.split_kle_name: ' || p_tqlv_rec.split_kle_name);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_code: ' || p_tqlv_rec.currency_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_conversion_code: ' || p_tqlv_rec.currency_conversion_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_conversion_type: ' || p_tqlv_rec.currency_conversion_type);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_conversion_rate: ' || p_tqlv_rec.currency_conversion_rate);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.currency_conversion_date: ' || p_tqlv_rec.currency_conversion_date);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.due_date: ' || p_tqlv_rec.due_date);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.try_id: ' || p_tqlv_rec.try_id);
	 END IF;


     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_TERMNT_QUOTE_PVT.update_quote_line');
     END IF;
     -- Insert line into table using PVT
     OKL_AM_TERMNT_QUOTE_PVT.update_quote_line(
               p_api_version   => l_api_version,
               p_init_msg_list => l_init_msg_list,
               x_return_status => l_return_status,
               x_msg_count     => l_msg_count,
               x_msg_data      => l_msg_data,
               p_tqlv_rec      => lp_tqlv_rec,
               x_tqlv_rec      => lx_tqlv_rec);
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_TERMNT_QUOTE_PVT.update_quote_line , return status: ' || l_return_status);
     END IF;


     -- raise exception if error
     IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;


     -- Assign value to OUT variables
     x_return_status := l_return_status ;
     x_msg_count := l_msg_count ;
     x_msg_data := l_msg_data ;
     x_tqlv_rec := lx_tqlv_rec;
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
     END IF;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO trx_update_quote_line;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXC_ERROR');
      END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO trx_update_quote_line;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXC_UNEXPECTED_ERROR');
      END IF;

    WHEN OTHERS THEN

      ROLLBACK TO trx_update_quote_line;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_TERMNT_QUOTE_PUB',l_api_name);
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;


  END update_quote_line;


  -- Start of comments
  --
  -- Function  Name  : update_quote_line
  -- Description     : Updates quote lines
  -- Business Rules  :
  -- Parameters      : Input parameters : p_tqlv_tbl
  --                   Output Parameters : x_tqlv_tbl
  -- Version         : 1.0
  -- History         : 23-DEC-02 RMUNJULU 2726739 Created
  -- End of comments
  PROCEDURE update_quote_line(
               p_api_version    IN NUMBER,
               p_init_msg_list  IN VARCHAR2 DEFAULT G_FALSE,
               x_return_status  OUT NOCOPY VARCHAR2,
               x_msg_count      OUT NOCOPY NUMBER,
               x_msg_data       OUT NOCOPY VARCHAR2,
               p_tqlv_tbl       IN tqlv_tbl_type,
               x_tqlv_tbl       OUT NOCOPY tqlv_tbl_type) IS


    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    lp_tqlv_tbl tqlv_tbl_type := p_tqlv_tbl;
    lx_tqlv_tbl tqlv_tbl_type := p_tqlv_tbl;
    l_api_name VARCHAR2(30) := 'update_quote_line';
    l_api_version NUMBER := p_api_version;
    l_init_msg_list VARCHAR2(1) := p_init_msg_list;
    l_msg_count NUMBER := x_msg_count;
    l_msg_data VARCHAR2(2000) := x_msg_data;

    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'update_quote_line';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN


     -- Create Savepoint
     SAVEPOINT trx_update_quote_line;
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;
	 IF (is_debug_statement_on) THEN
	   FOR i IN p_tqlv_tbl.FIRST..p_tqlv_tbl.LAST LOOP
	     IF (p_tqlv_tbl.exists(i)) THEN
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').id: ' || p_tqlv_tbl(i).id);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').qlt_code: ' || p_tqlv_tbl(i).qlt_code);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').kle_id: ' || p_tqlv_tbl(i).kle_id);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').sty_id: ' || p_tqlv_tbl(i).sty_id);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').qte_id: ' || p_tqlv_tbl(i).qte_id);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').line_number: ' || p_tqlv_tbl(i).line_number);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').amount: ' || p_tqlv_tbl(i).amount);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').modified_yn: ' || p_tqlv_tbl(i).modified_yn);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').taxed_yn: ' || p_tqlv_tbl(i).taxed_yn);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').defaulted_yn: ' || p_tqlv_tbl(i).defaulted_yn);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').org_id: ' || p_tqlv_tbl(i).org_id);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').start_date: ' || p_tqlv_tbl(i).start_date);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').period: ' || p_tqlv_tbl(i).period);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').number_of_periods: ' || p_tqlv_tbl(i).number_of_periods);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').lock_level_step: ' || p_tqlv_tbl(i).lock_level_step);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').advance_or_arrears: ' || p_tqlv_tbl(i).advance_or_arrears);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').yield_name: ' || p_tqlv_tbl(i).yield_name);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').yield_value: ' || p_tqlv_tbl(i).yield_value);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').implicit_interest_rate: ' || p_tqlv_tbl(i).implicit_interest_rate);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').asset_value: ' || p_tqlv_tbl(i).asset_value);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').residual_value: ' || p_tqlv_tbl(i).residual_value);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').unbilled_receivables: ' || p_tqlv_tbl(i).unbilled_receivables);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').asset_quantity: ' || p_tqlv_tbl(i).asset_quantity);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').quote_quantity: ' || p_tqlv_tbl(i).quote_quantity);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').split_kle_id: ' || p_tqlv_tbl(i).split_kle_id);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').split_kle_name: ' || p_tqlv_tbl(i).split_kle_name);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').currency_code: ' || p_tqlv_tbl(i).currency_code);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').currency_conversion_code: ' || p_tqlv_tbl(i).currency_conversion_code);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').currency_conversion_type: ' || p_tqlv_tbl(i).currency_conversion_type);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').currency_conversion_rate: ' || p_tqlv_tbl(i).currency_conversion_rate);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').currency_conversion_date: ' || p_tqlv_tbl(i).currency_conversion_date);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').due_date: ' || p_tqlv_tbl(i).due_date);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').try_id: ' || p_tqlv_tbl(i).try_id);
	      END IF;
	   END LOOP;
	 END IF;


     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_TERMNT_QUOTE_PVT.update_quote_line');
     END IF;
     -- Insert line into table using PVT
     OKL_AM_TERMNT_QUOTE_PVT.update_quote_line(
               p_api_version   => l_api_version,
               p_init_msg_list => l_init_msg_list,
               x_return_status => l_return_status,
               x_msg_count     => l_msg_count,
               x_msg_data      => l_msg_data,
               p_tqlv_tbl      => lp_tqlv_tbl,
               x_tqlv_tbl      => lx_tqlv_tbl);
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_TERMNT_QUOTE_PVT.update_quote_line , return status: ' || l_return_status);
     END IF;


     -- raise exception if error
     IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;


     -- Assign value to OUT variables
     x_return_status := l_return_status ;
     x_msg_count := l_msg_count ;
     x_msg_data := l_msg_data ;
     x_tqlv_tbl := lx_tqlv_tbl;
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
     END IF;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO trx_update_quote_line;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXC_ERROR');
      END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO trx_update_quote_line;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXC_UNEXPECTED_ERROR');
      END IF;

    WHEN OTHERS THEN

      ROLLBACK TO trx_update_quote_line;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_TERMNT_QUOTE_PUB',l_api_name);
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;

  END update_quote_line;



  -- Start of comments
  --
  -- Function  Name  : delete_quote_line
  -- Description     : deletes quote line
  -- Business Rules  :
  -- Parameters      : Input parameters : p_tqlv_rec
  -- Version         : 1.0
  -- History         : 16-JAN-03 RMUNJULU 2754574 Created
  -- End of comments
  PROCEDURE delete_quote_line(
               p_api_version    IN NUMBER,
               p_init_msg_list  IN VARCHAR2 DEFAULT G_FALSE,
               x_return_status  OUT NOCOPY VARCHAR2,
               x_msg_count      OUT NOCOPY NUMBER,
               x_msg_data       OUT NOCOPY VARCHAR2,
               p_tqlv_rec       IN tqlv_rec_type) IS


    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    lp_tqlv_rec tqlv_rec_type := p_tqlv_rec;
    l_api_name VARCHAR2(30) := 'update_quote_line';
    l_api_version NUMBER := p_api_version;
    l_init_msg_list VARCHAR2(1) := p_init_msg_list;
    l_msg_count NUMBER := x_msg_count;
    l_msg_data VARCHAR2(2000) := x_msg_data;

    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'delete_quote_line';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN


     -- Create Savepoint
     SAVEPOINT trx_delete_quote_line;
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;
	 IF (is_debug_statement_on) THEN
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.id: ' || p_tqlv_rec.id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.qlt_code: ' || p_tqlv_rec.qlt_code);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.qte_id: ' || p_tqlv_rec.qte_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.line_number: ' || p_tqlv_rec.line_number);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.org_id: ' || p_tqlv_rec.org_id);
	   OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_rec.try_id: ' || p_tqlv_rec.try_id);
	 END IF;


     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_TERMNT_QUOTE_PVT.delete_quote_line');
     END IF;
     -- Insert line into table using PVT
     OKL_AM_TERMNT_QUOTE_PVT.delete_quote_line(
               p_api_version   => l_api_version,
               p_init_msg_list => l_init_msg_list,
               x_return_status => l_return_status,
               x_msg_count     => l_msg_count,
               x_msg_data      => l_msg_data,
               p_tqlv_rec      => lp_tqlv_rec);
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_TERMNT_QUOTE_PVT.delete_quote_line , return status: ' || l_return_status);
     END IF;


     -- raise exception if error
     IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;


     -- Assign value to OUT variables
     x_return_status := l_return_status ;
     x_msg_count := l_msg_count ;
     x_msg_data := l_msg_data ;
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
     END IF;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO trx_delete_quote_line;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXC_ERROR');
      END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO trx_delete_quote_line;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXC_UNEXPECTED_ERROR');
      END IF;

    WHEN OTHERS THEN

      ROLLBACK TO trx_delete_quote_line;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_TERMNT_QUOTE_PUB',l_api_name);
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;


  END delete_quote_line;


  -- Start of comments
  --
  -- Function  Name  : delete_quote_line
  -- Description     : Deletes quote lines
  -- Business Rules  :
  -- Parameters      : Input parameters : p_tqlv_tbl
  -- Version         : 1.0
  -- History         : 16-JAN-03 RMUNJULU 2754574 Created
  -- End of comments
  PROCEDURE delete_quote_line(
               p_api_version    IN NUMBER,
               p_init_msg_list  IN VARCHAR2 DEFAULT G_FALSE,
               x_return_status  OUT NOCOPY VARCHAR2,
               x_msg_count      OUT NOCOPY NUMBER,
               x_msg_data       OUT NOCOPY VARCHAR2,
               p_tqlv_tbl       IN tqlv_tbl_type) IS


    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    lp_tqlv_tbl tqlv_tbl_type := p_tqlv_tbl;
    l_api_name VARCHAR2(30) := 'delete_quote_line';
    l_api_version NUMBER := p_api_version;
    l_init_msg_list VARCHAR2(1) := p_init_msg_list;
    l_msg_count NUMBER := x_msg_count;
    l_msg_data VARCHAR2(2000) := x_msg_data;

    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'delete_quote_line';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

  BEGIN


     -- Create Savepoint
     SAVEPOINT trx_delete_quote_line;
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
     END IF;

	 IF (is_debug_statement_on) THEN
	   FOR i IN p_tqlv_tbl.FIRST..p_tqlv_tbl.LAST LOOP
	     IF (p_tqlv_tbl.exists(i)) THEN
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').id: ' || p_tqlv_tbl(i).id);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').qlt_code: ' || p_tqlv_tbl(i).qlt_code);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').qte_id: ' || p_tqlv_tbl(i).qte_id);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').line_number: ' || p_tqlv_tbl(i).line_number);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').amount: ' || p_tqlv_tbl(i).amount);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').org_id: ' || p_tqlv_tbl(i).org_id);
	       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'In param, p_tqlv_tbl(' || i || ').try_id: ' || p_tqlv_tbl(i).try_id);
	      END IF;
	   END LOOP;
	 END IF;

     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'calling OKL_AM_TERMNT_QUOTE_PVT.delete_quote_line');
     END IF;
     -- Insert line into table using PVT
     OKL_AM_TERMNT_QUOTE_PVT.delete_quote_line(
               p_api_version   => l_api_version,
               p_init_msg_list => l_init_msg_list,
               x_return_status => l_return_status,
               x_msg_count     => l_msg_count,
               x_msg_data      => l_msg_data,
               p_tqlv_tbl      => lp_tqlv_tbl);
     IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called OKL_AM_TERMNT_QUOTE_PVT.delete_quote_line , return status: ' || l_return_status);
     END IF;


     -- raise exception if error
     IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;


     -- Assign value to OUT variables
     x_return_status := l_return_status ;
     x_msg_count := l_msg_count ;
     x_msg_data := l_msg_data ;
     IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
     END IF;
  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

      ROLLBACK TO trx_delete_quote_line;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXC_ERROR');
      END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      ROLLBACK TO trx_delete_quote_line;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXC_UNEXPECTED_ERROR');
      END IF;

    WHEN OTHERS THEN

      ROLLBACK TO trx_delete_quote_line;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_TERMNT_QUOTE_PUB',l_api_name);
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count,
             p_data    => x_msg_data);
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'OTHERS, SQLCODE: '
			                || sqlcode || ' , SQLERRM : ' || sqlerrm);
      END IF;

  END delete_quote_line;

END OKL_AM_TERMNT_QUOTE_PUB;

/
