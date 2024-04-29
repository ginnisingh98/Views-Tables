--------------------------------------------------------
--  DDL for Package Body OKL_CS_CREATE_QUOTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CS_CREATE_QUOTE_PVT" AS
/* $Header: OKLRCTQB.pls 120.2 2007/12/17 05:04:44 asawanka ship $ */

 G_LEVEL_PROCEDURE CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
 G_LEVEL_EXCEPTION CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
 G_LEVEL_STATEMENT CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
 G_MODULE_NAME CONSTANT VARCHAR2(500) := 'okl.am.plsql.okl_cs_create_quote_pvt.';
 --------------------------------------------------------
--NOTE: This procedure is a wrapper over OKL_AM_CREATE_QUOTE_PVT
--This procedure accepts the parameter as table type and in turn
--calls the procedure that accepts the record type API in loop.
--For all practical purposes, only one record will be passed in
-- the pl/sql table and so the record api is called only once.
--------------------------------------------------------
 PROCEDURE create_terminate_quote(
    p_api_version               IN NUMBER,
    p_init_msg_list             IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    p_quot_tbl                  IN quot_tbl_type,
    p_assn_tbl                  IN  OKL_AM_CREATE_QUOTE_PUB.assn_tbl_type,
    p_qpyv_tbl                  IN  qpyv_tbl_type DEFAULT G_EMPTY_QPYV_TBL,
    x_quot_tbl                  OUT NOCOPY quot_tbl_type,
    x_tqlv_tbl                  OUT NOCOPY  OKL_AM_CREATE_QUOTE_PUB.tqlv_tbl_type,
    x_assn_tbl                  OUT NOCOPY  OKL_AM_CREATE_QUOTE_PUB.assn_tbl_type)AS

     l_return_status           VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                          NUMBER := 0;
    l_overall_status           VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    -- asawanka added for debug feature start
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'create_terminate_quote';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    -- asawanka added for debug feature end
  BEGIN
    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    IF (p_quot_tbl.COUNT > 0) THEN
      i := p_quot_tbl.FIRST;
     LOOP
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'Calling  okl_am_create_quote_pub.create_terminate_quote with parameters: ');
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).id : '||p_quot_tbl(i).id     );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).qrs_code : '||p_quot_tbl(i).qrs_code    );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).qst_code : '||p_quot_tbl(i).qst_code               );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).consolidated_qte_id : '||p_quot_tbl(i).consolidated_qte_id     );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).khr_id : '||p_quot_tbl(i).khr_id                 );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).art_id : '||p_quot_tbl(i).art_id                 );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).qtp_code : '||p_quot_tbl(i).qtp_code               );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).trn_code : '||p_quot_tbl(i).trn_code                 );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).pdt_id : '||p_quot_tbl(i).pdt_id                  );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).date_effective_from : '||p_quot_tbl(i).date_effective_from     );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).quote_number : '||p_quot_tbl(i).quote_number            );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).early_termination_yn : '||p_quot_tbl(i).early_termination_yn       );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).partial_yn : '||p_quot_tbl(i).partial_yn            );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).preproceeds_yn : '||p_quot_tbl(i).preproceeds_yn   );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).summary_format_yn : '||p_quot_tbl(i).summary_format_yn     );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).consolidated_yn : '||p_quot_tbl(i).consolidated_yn     );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).date_requested : '||p_quot_tbl(i).date_requested   );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).date_proposal : '||p_quot_tbl(i).date_proposal   );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).date_effective_to : '||p_quot_tbl(i).date_effective_to    );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).date_accepted : '||p_quot_tbl(i).date_accepted          );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).payment_received_yn : '||p_quot_tbl(i).payment_received_yn      );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).requested_by : '||p_quot_tbl(i).requested_by               );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).approved_yn : '||p_quot_tbl(i).approved_yn                  );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).accepted_yn : '||p_quot_tbl(i).accepted_yn                   );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).org_id : '||p_quot_tbl(i).org_id                        );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).purchase_amount : '||p_quot_tbl(i).purchase_amount               );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).purchase_formula : '||p_quot_tbl(i).purchase_formula              );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).asset_value : '||p_quot_tbl(i).asset_value                   );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).residual_value : '||p_quot_tbl(i).residual_value                );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).unbilled_receivables : '||p_quot_tbl(i).unbilled_receivables          );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).gain_loss : '||p_quot_tbl(i).gain_loss                     );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).PERDIEM_AMOUNT : '||p_quot_tbl(i).PERDIEM_AMOUNT                );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).currency_code : '||p_quot_tbl(i).currency_code                 );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).currency_conversion_code : '||p_quot_tbl(i).currency_conversion_code      );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).legal_entity_id : '||p_quot_tbl(i).legal_entity_id               );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_quot_tbl(i).repo_quote_indicator_yn : '||p_quot_tbl(i).repo_quote_indicator_yn       );

        IF (p_assn_tbl.COUNT > 0) THEN
                FOR l IN p_assn_tbl.FIRST..p_assn_tbl.LAST LOOP
                  IF  p_assn_tbl.exists(l) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_assn_tbl('||l||').'||'p_asset_id   :'|| p_assn_tbl(l).p_asset_id   );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_assn_tbl('||l||').'||'p_asset_number   :'|| p_assn_tbl(l).p_asset_number      );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_assn_tbl('||l||').'||'p_asset_qty   :'|| p_assn_tbl(l).p_asset_qty         );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_assn_tbl('||l||').'||'p_quote_qty   :'|| p_assn_tbl(l).p_quote_qty         );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_assn_tbl('||l||').'||'p_split_asset_number   :'|| p_assn_tbl(l).p_split_asset_number);
                  END IF;
                End loop;
        END IF;
        IF  (p_qpyv_tbl.COUNT > 0) THEN
                FOR l IN p_qpyv_tbl.FIRST..p_qpyv_tbl.LAST LOOP
                  IF  p_qpyv_tbl.exists(l) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).id                        = ' ||   p_qpyv_tbl(l).id                        );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).qte_id                    = ' ||   p_qpyv_tbl(l).qte_id                    );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).cpl_id                    = ' ||   p_qpyv_tbl(l).cpl_id                    );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).object_version_number     = ' ||   p_qpyv_tbl(l).object_version_number     );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).date_sent                 = ' ||   p_qpyv_tbl(l).date_sent                 );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).created_by                = ' ||   p_qpyv_tbl(l).created_by                );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).creation_date             = ' ||   p_qpyv_tbl(l).creation_date             );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).last_updated_by           = ' ||   p_qpyv_tbl(l).last_updated_by           );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).last_update_date          = ' ||   p_qpyv_tbl(l).last_update_date          );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).last_update_login         = ' ||   p_qpyv_tbl(l).last_update_login         );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).qpt_code                  = ' ||   p_qpyv_tbl(l).qpt_code                  );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).delay_days                = ' ||   p_qpyv_tbl(l).delay_days                );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).allocation_percentage     = ' ||   p_qpyv_tbl(l).allocation_percentage     );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).email_address             = ' ||   p_qpyv_tbl(l).email_address             );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).party_jtot_object1_code   = ' ||   p_qpyv_tbl(l).party_jtot_object1_code   );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).party_object1_id1         = ' ||   p_qpyv_tbl(l).party_object1_id1         );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).party_object1_id2         = ' ||   p_qpyv_tbl(l).party_object1_id2         );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).contact_jtot_object1_code = ' ||   p_qpyv_tbl(l).contact_jtot_object1_code );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).contact_object1_id1       = ' ||   p_qpyv_tbl(l).contact_object1_id1       );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).contact_object1_id2       = ' ||   p_qpyv_tbl(l).contact_object1_id2       );

                  END IF;
                End loop;

                END IF;
      END IF;
      okl_am_create_quote_pub.create_terminate_quote(
            p_api_version                 => p_api_version,
            p_init_msg_list               => FND_API.G_FALSE,
            x_return_status               => x_return_status,
            x_msg_count                   => x_msg_count,
            x_msg_data                    => x_msg_data,
            p_quot_rec                    => p_quot_tbl(i),
            p_assn_tbl                    => p_assn_tbl,
            p_qpyv_tbl                    => p_qpyv_tbl,
            x_quot_rec                    => x_quot_tbl(i),
            x_tqlv_tbl                    => x_tqlv_tbl,
            x_assn_tbl                    => x_assn_tbl);
        IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_create_quote_pub.create_terminate_quote , return status: ' || x_return_status);
        END IF;

        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
           END IF;
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        EXIT WHEN (i = p_quot_tbl.LAST);
        i := p_quot_tbl.NEXT(i);
      END LOOP;
      x_return_status := l_overall_status;
    END IF;
    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;
  END create_terminate_quote;


  PROCEDURE fetch_rule_quote_parties (
        p_api_version           IN  NUMBER,
        p_init_msg_list         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2,
        x_return_status         OUT NOCOPY VARCHAR2,
        p_qtev_tbl              IN  quot_tbl_type,
        x_qpyv_tbl              OUT NOCOPY okl_quote_parties_pub.qpyv_tbl_type,
        x_q_party_uv_tbl        OUT NOCOPY okl_am_parties_pvt.q_party_uv_tbl_type,
        x_record_count          OUT NOCOPY NUMBER)
  IS
    i                          NUMBER := 0;
    l_overall_status           VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    -- asawanka added for debug feature start
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'fetch_rule_quote_parties';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    -- asawanka added for debug feature end
  BEGIN
    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    OKC_API.init_msg_list(p_init_msg_list);
    IF (p_qtev_tbl.COUNT > 0) THEN
      i := p_qtev_tbl.FIRST;
     LOOP
     IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'Calling  okl_am_create_quote_pub.fetch_rule_quote_parties with parameters: ');
         IF p_qtev_tbl.count > 0 THEN
         FOR k IN p_qtev_tbl.FIRST..p_qtev_tbl.LAST LOOP
           IF p_qtev_tbl.exists(k) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).id                            = ' ||  p_qtev_tbl(k).id                         );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).qrs_code                      = ' ||  p_qtev_tbl(k).qrs_code                   );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).qst_code                      = ' ||  p_qtev_tbl(k).qst_code                   );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).consolidated_qte_id           = ' ||  p_qtev_tbl(k).consolidated_qte_id        );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).khr_id                        = ' ||  p_qtev_tbl(k).khr_id                     );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).art_id                        = ' ||  p_qtev_tbl(k).art_id                     );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).qtp_code                      = ' ||  p_qtev_tbl(k).qtp_code                   );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).trn_code                      = ' ||  p_qtev_tbl(k).trn_code                   );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).pop_code_end                  = ' ||  p_qtev_tbl(k).pop_code_end               );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).pop_code_early                = ' ||  p_qtev_tbl(k).pop_code_early             );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).pdt_id                        = ' ||  p_qtev_tbl(k).pdt_id                     );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).date_effective_from           = ' ||  p_qtev_tbl(k).date_effective_from        );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).quote_number                  = ' ||  p_qtev_tbl(k).quote_number               );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).object_version_number         = ' ||  p_qtev_tbl(k).object_version_number      );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).purchase_percent              = ' ||  p_qtev_tbl(k).purchase_percent           );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).term                          = ' ||  p_qtev_tbl(k).term                       );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).date_restructure_start        = ' ||  p_qtev_tbl(k).date_restructure_start     );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).date_due                      = ' ||  p_qtev_tbl(k).date_due                   );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).date_approved                 = ' ||  p_qtev_tbl(k).date_approved              );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).date_restructure_end          = ' ||  p_qtev_tbl(k).date_restructure_end       );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).remaining_payments            = ' ||  p_qtev_tbl(k).remaining_payments         );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).rent_amount                   = ' ||  p_qtev_tbl(k).rent_amount                );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).yield                         = ' ||  p_qtev_tbl(k).yield                      );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).residual_amount               = ' ||  p_qtev_tbl(k).residual_amount            );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).principal_paydown_amount      = ' ||  p_qtev_tbl(k).principal_paydown_amount   );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).payment_frequency             = ' ||  p_qtev_tbl(k).payment_frequency          );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).early_termination_yn          = ' ||  p_qtev_tbl(k).early_termination_yn       );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).partial_yn                    = ' ||  p_qtev_tbl(k).partial_yn                 );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).preproceeds_yn                = ' ||  p_qtev_tbl(k).preproceeds_yn             );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).summary_format_yn             = ' ||  p_qtev_tbl(k).summary_format_yn          );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).consolidated_yn               = ' ||  p_qtev_tbl(k).consolidated_yn            );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).date_requested                = ' ||  p_qtev_tbl(k).date_requested             );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).date_proposal                 = ' ||  p_qtev_tbl(k).date_proposal              );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).date_effective_to             = ' ||  p_qtev_tbl(k).date_effective_to          );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).date_accepted                 = ' ||  p_qtev_tbl(k).date_accepted              );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).payment_received_yn           = ' ||  p_qtev_tbl(k).payment_received_yn        );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).requested_by                  = ' ||  p_qtev_tbl(k).requested_by               );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).approved_yn                   = ' ||  p_qtev_tbl(k).approved_yn                );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).accepted_yn                   = ' ||  p_qtev_tbl(k).accepted_yn                );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).date_payment_received         = ' ||  p_qtev_tbl(k).date_payment_received      );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).approved_by                   = ' ||  p_qtev_tbl(k).approved_by                );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).org_id                        = ' ||  p_qtev_tbl(k).org_id                     );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).request_id                    = ' ||  p_qtev_tbl(k).request_id                 );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).program_application_id        = ' ||  p_qtev_tbl(k).program_application_id     );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).program_id                    = ' ||  p_qtev_tbl(k).program_id                 );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).program_update_date           = ' ||  p_qtev_tbl(k).program_update_date        );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute_category            = ' ||  p_qtev_tbl(k).attribute_category         );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute1                    = ' ||  p_qtev_tbl(k).attribute1                 );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute2                    = ' ||  p_qtev_tbl(k).attribute2                 );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute3                    = ' ||  p_qtev_tbl(k).attribute3                 );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute4                    = ' ||  p_qtev_tbl(k).attribute4                 );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute5                    = ' ||  p_qtev_tbl(k).attribute5                 );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute6                    = ' ||  p_qtev_tbl(k).attribute6                 );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute7                    = ' ||  p_qtev_tbl(k).attribute7                 );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute8                    = ' ||  p_qtev_tbl(k).attribute8                 );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute9                    = ' ||  p_qtev_tbl(k).attribute9                 );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute10                   = ' ||  p_qtev_tbl(k).attribute10                );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute11                   = ' ||  p_qtev_tbl(k).attribute11                );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute12                   = ' ||  p_qtev_tbl(k).attribute12                );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute13                   = ' ||  p_qtev_tbl(k).attribute13                );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute14                   = ' ||  p_qtev_tbl(k).attribute14                );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute15               = ' ||  p_qtev_tbl(k).attribute15                );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).created_by                    = ' ||  p_qtev_tbl(k).created_by                 );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).creation_date                 = ' ||  p_qtev_tbl(k).creation_date              );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).last_updated_by               = ' ||  p_qtev_tbl(k).last_updated_by            );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).last_update_date              = ' ||  p_qtev_tbl(k).last_update_date           );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).date_restructure_end          = ' ||  p_qtev_tbl(k).date_restructure_end              );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).remaining_payments            = ' ||  p_qtev_tbl(k).remaining_payments                );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).rent_amount                   = ' ||  p_qtev_tbl(k).rent_amount                       );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).yield                         = ' ||  p_qtev_tbl(k).yield                             );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).residual_amount               = ' ||  p_qtev_tbl(k).residual_amount                   );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).principal_paydown_amount      = ' ||  p_qtev_tbl(k).principal_paydown_amount          );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).payment_frequency             = ' ||  p_qtev_tbl(k).payment_frequency                 );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).early_termination_yn          = ' ||  p_qtev_tbl(k).early_termination_yn              );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).partial_yn                    = ' ||  p_qtev_tbl(k).partial_yn                        );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).preproceeds_yn                = ' ||  p_qtev_tbl(k).preproceeds_yn                    );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).summary_format_yn             = ' ||  p_qtev_tbl(k).summary_format_yn                 );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).consolidated_yn               = ' ||  p_qtev_tbl(k).consolidated_yn                   );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).date_requested                = ' ||  p_qtev_tbl(k).date_requested                    );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).date_proposal                 = ' ||  p_qtev_tbl(k).date_proposal                     );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).date_effective_to             = ' ||  p_qtev_tbl(k).date_effective_to                 );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).date_accepted                 = ' ||  p_qtev_tbl(k).date_accepted               );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).payment_received_yn           = ' ||  p_qtev_tbl(k).payment_received_yn         );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).requested_by                  = ' ||  p_qtev_tbl(k).requested_by                );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).approved_yn                   = ' ||  p_qtev_tbl(k).approved_yn                 );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).accepted_yn                   = ' ||  p_qtev_tbl(k).accepted_yn                 );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).date_payment_received         = ' ||  p_qtev_tbl(k).date_payment_received       );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).approved_by                   = ' ||  p_qtev_tbl(k).approved_by                 );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).org_id                        = ' ||  p_qtev_tbl(k).org_id                      );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).request_id                    = ' ||  p_qtev_tbl(k).request_id                  );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).program_application_id        = ' ||  p_qtev_tbl(k).program_application_id      );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).program_id                    = ' ||  p_qtev_tbl(k).program_id                 );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).program_update_date           = ' ||  p_qtev_tbl(k).program_update_date        );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute_category            = ' ||  p_qtev_tbl(k).attribute_category         );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute1                    = ' ||  p_qtev_tbl(k).attribute1                 );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute2                    = ' ||  p_qtev_tbl(k).attribute2                 );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute3                    = ' ||  p_qtev_tbl(k).attribute3                 );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute4                    = ' ||  p_qtev_tbl(k).attribute4                 );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute5                    = ' ||  p_qtev_tbl(k).attribute5                 );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute6                    = ' ||  p_qtev_tbl(k).attribute6                 );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute7                    = ' ||  p_qtev_tbl(k).attribute7                 );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute8                    = ' ||  p_qtev_tbl(k).attribute8                 );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute9                    = ' ||  p_qtev_tbl(k).attribute9                 );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute10                   = ' ||  p_qtev_tbl(k).attribute10                );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute11                   = ' ||  p_qtev_tbl(k).attribute11                );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute12                   = ' ||  p_qtev_tbl(k).attribute12                );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute13                   = ' ||  p_qtev_tbl(k).attribute13                );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute14                   = ' ||  p_qtev_tbl(k).attribute14                );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute15                   = ' ||  p_qtev_tbl(k).attribute15                );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).created_by                    = ' ||  p_qtev_tbl(k).created_by                 );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).creation_date                 = ' ||  p_qtev_tbl(k).creation_date              );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).last_updated_by               = ' ||  p_qtev_tbl(k).last_updated_by            );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).last_update_date              = ' ||  p_qtev_tbl(k).last_update_date           );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).last_update_login             = ' ||  p_qtev_tbl(k).last_update_login          );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).purchase_amount               = ' ||  p_qtev_tbl(k).purchase_amount            );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).purchase_formula              = ' ||  p_qtev_tbl(k).purchase_formula           );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).asset_value                   = ' ||  p_qtev_tbl(k).asset_value                );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).residual_value                = ' ||  p_qtev_tbl(k).residual_value             );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).unbilled_receivables          = ' ||  p_qtev_tbl(k).unbilled_receivables       );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).gain_loss                     = ' ||  p_qtev_tbl(k).gain_loss                  );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).PERDIEM_AMOUNT                = ' ||  p_qtev_tbl(k).PERDIEM_AMOUNT             );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).currency_code                 = ' ||  p_qtev_tbl(k).currency_code              );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).currency_conversion_code      = ' ||  p_qtev_tbl(k).currency_conversion_code   );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).currency_conversion_type      = ' ||  p_qtev_tbl(k).currency_conversion_type   );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).currency_conversion_rate      = ' ||  p_qtev_tbl(k).currency_conversion_rate   );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).currency_conversion_date      = ' ||  p_qtev_tbl(k).currency_conversion_date   );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).legal_entity_id               = ' ||  p_qtev_tbl(k).legal_entity_id            );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).repo_quote_indicator_yn       = ' ||  p_qtev_tbl(k).repo_quote_indicator_yn    );

           END IF;
         END LOOP;
         END IF;
      END IF;
        okl_am_parties_pvt.fetch_rule_quote_parties (
                        p_api_version           =>  p_api_version,
                        p_init_msg_list         =>  p_init_msg_list,
                        x_msg_count             =>  x_msg_count,
                        x_msg_data              =>  x_msg_data,
                        x_return_status         =>  x_return_status,
                        p_qtev_rec              =>  p_qtev_tbl(i),
                        x_qpyv_tbl              =>  x_qpyv_tbl,
                        x_q_party_uv_tbl        =>  x_q_party_uv_tbl,
                        x_record_count          =>  x_record_count);
       IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_create_quote_pub.fetch_rule_quote_parties , return status: ' || x_return_status);
       END IF;
       IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
           END IF;
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        EXIT WHEN (i = p_qtev_tbl.LAST);
        i := p_qtev_tbl.NEXT(i);
      END LOOP;

      x_return_status := l_overall_status;
    END IF;
    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;
  END fetch_rule_quote_parties;

  PROCEDURE submit_for_approval(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_term_tbl                     IN  quot_tbl_type,
    x_term_tbl                     OUT NOCOPY quot_tbl_type) AS

     l_return_status           VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                          NUMBER := 0;
    l_overall_status           VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    -- asawanka added for debug feature start
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'submit_for_approval';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    -- asawanka added for debug feature end
  BEGIN
    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    OKC_API.init_msg_list(p_init_msg_list);
    IF (p_term_tbl.COUNT > 0) THEN
      i := p_term_tbl.FIRST;
     LOOP
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'Calling  okl_am_create_quote_pub.submit_for_approval with parameters: ');
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).id : '||p_term_tbl(i).id     );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).qrs_code : '||p_term_tbl(i).qrs_code    );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).qst_code : '||p_term_tbl(i).qst_code               );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).consolidated_qte_id : '||p_term_tbl(i).consolidated_qte_id     );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).khr_id : '||p_term_tbl(i).khr_id                 );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).art_id : '||p_term_tbl(i).art_id                 );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).qtp_code : '||p_term_tbl(i).qtp_code               );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).trn_code : '||p_term_tbl(i).trn_code                 );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).pdt_id : '||p_term_tbl(i).pdt_id                  );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).date_effective_from : '||p_term_tbl(i).date_effective_from     );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).quote_number : '||p_term_tbl(i).quote_number            );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).early_termination_yn : '||p_term_tbl(i).early_termination_yn       );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).partial_yn : '||p_term_tbl(i).partial_yn            );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).preproceeds_yn : '||p_term_tbl(i).preproceeds_yn   );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).summary_format_yn : '||p_term_tbl(i).summary_format_yn     );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).consolidated_yn : '||p_term_tbl(i).consolidated_yn     );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).date_requested : '||p_term_tbl(i).date_requested   );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).date_proposal : '||p_term_tbl(i).date_proposal   );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).date_effective_to : '||p_term_tbl(i).date_effective_to    );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).date_accepted : '||p_term_tbl(i).date_accepted          );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).payment_received_yn : '||p_term_tbl(i).payment_received_yn      );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).requested_by : '||p_term_tbl(i).requested_by               );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).approved_yn : '||p_term_tbl(i).approved_yn                  );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).accepted_yn : '||p_term_tbl(i).accepted_yn                   );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).org_id : '||p_term_tbl(i).org_id                        );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).purchase_amount : '||p_term_tbl(i).purchase_amount               );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).purchase_formula : '||p_term_tbl(i).purchase_formula              );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).asset_value : '||p_term_tbl(i).asset_value                   );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).residual_value : '||p_term_tbl(i).residual_value                );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).unbilled_receivables : '||p_term_tbl(i).unbilled_receivables          );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).gain_loss : '||p_term_tbl(i).gain_loss                     );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).PERDIEM_AMOUNT : '||p_term_tbl(i).PERDIEM_AMOUNT                );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).currency_code : '||p_term_tbl(i).currency_code                 );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).currency_conversion_code : '||p_term_tbl(i).currency_conversion_code      );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).legal_entity_id : '||p_term_tbl(i).legal_entity_id               );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_term_tbl(i).repo_quote_indicator_yn : '||p_term_tbl(i).repo_quote_indicator_yn       );

      END IF;
      OKL_AM_TERMNT_QUOTE_PUB.submit_for_approval(
            p_api_version                 => p_api_version,
            p_init_msg_list               => FND_API.G_FALSE,
            x_return_status               => x_return_status,
            x_msg_count                   => x_msg_count,
            x_msg_data                    => x_msg_data,
            p_term_rec                    => p_term_tbl(i),
            x_term_rec                    => x_term_tbl(i));
       IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_create_quote_pub.submit_for_approval , return status: ' || x_return_status);
       END IF;

        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
           END IF;
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        EXIT WHEN (i = p_term_tbl.LAST);
        i := p_term_tbl.NEXT(i);
      END LOOP;
      x_return_status := l_overall_status;
    END IF;
    IF (is_debug_procedure_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End(-)');
    END IF;
  END submit_for_approval;

 PROCEDURE send_terminate_quote (
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_party_tbl                   IN  okl_am_parties_pvt.q_party_uv_tbl_type,
           x_party_tbl                   OUT NOCOPY okl_am_parties_pvt.q_party_uv_tbl_type,
           p_qtev_tbl                    IN  quot_tbl_type,
           x_qtev_tbl                    OUT NOCOPY quot_tbl_type) as

     l_return_status           VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                          NUMBER := 0;
    l_overall_status           VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    -- asawanka added for debug feature start
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'send_terminate_quote';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);
    -- asawanka added for debug feature end
  BEGIN
    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
    OKC_API.init_msg_list(p_init_msg_list);
    IF (p_qtev_tbl.COUNT > 0) THEN
      i := p_qtev_tbl.FIRST;
     LOOP
      IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'Calling  okl_am_create_quote_pub.send_terminate_quote with parameters: ');
         IF p_qtev_tbl.COUNT > 0 THEN
                 FOR k IN p_qtev_tbl.FIRST..p_qtev_tbl.LAST LOOP
                   IF p_qtev_tbl.exists(k) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).id                            = ' ||  p_qtev_tbl(k).id                         );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).qrs_code                      = ' ||  p_qtev_tbl(k).qrs_code                   );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).qst_code                      = ' ||  p_qtev_tbl(k).qst_code                   );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).consolidated_qte_id           = ' ||  p_qtev_tbl(k).consolidated_qte_id        );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).khr_id                        = ' ||  p_qtev_tbl(k).khr_id                     );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).art_id                        = ' ||  p_qtev_tbl(k).art_id                     );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).qtp_code                      = ' ||  p_qtev_tbl(k).qtp_code                   );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).trn_code                      = ' ||  p_qtev_tbl(k).trn_code                   );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).pop_code_end                  = ' ||  p_qtev_tbl(k).pop_code_end               );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).pop_code_early                = ' ||  p_qtev_tbl(k).pop_code_early             );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).pdt_id                        = ' ||  p_qtev_tbl(k).pdt_id                     );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).date_effective_from           = ' ||  p_qtev_tbl(k).date_effective_from        );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).quote_number                  = ' ||  p_qtev_tbl(k).quote_number               );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).object_version_number         = ' ||  p_qtev_tbl(k).object_version_number      );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).purchase_percent              = ' ||  p_qtev_tbl(k).purchase_percent           );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).term                          = ' ||  p_qtev_tbl(k).term                       );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).date_restructure_start        = ' ||  p_qtev_tbl(k).date_restructure_start     );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).date_due                      = ' ||  p_qtev_tbl(k).date_due                   );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).date_approved                 = ' ||  p_qtev_tbl(k).date_approved              );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).date_restructure_end          = ' ||  p_qtev_tbl(k).date_restructure_end       );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).remaining_payments            = ' ||  p_qtev_tbl(k).remaining_payments         );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).rent_amount                   = ' ||  p_qtev_tbl(k).rent_amount                );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).yield                         = ' ||  p_qtev_tbl(k).yield                      );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).residual_amount               = ' ||  p_qtev_tbl(k).residual_amount            );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).principal_paydown_amount      = ' ||  p_qtev_tbl(k).principal_paydown_amount   );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).payment_frequency             = ' ||  p_qtev_tbl(k).payment_frequency          );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).early_termination_yn          = ' ||  p_qtev_tbl(k).early_termination_yn       );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).partial_yn                    = ' ||  p_qtev_tbl(k).partial_yn                 );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).preproceeds_yn                = ' ||  p_qtev_tbl(k).preproceeds_yn             );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).summary_format_yn             = ' ||  p_qtev_tbl(k).summary_format_yn          );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).consolidated_yn               = ' ||  p_qtev_tbl(k).consolidated_yn            );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).date_requested                = ' ||  p_qtev_tbl(k).date_requested             );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).date_proposal                 = ' ||  p_qtev_tbl(k).date_proposal              );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).date_effective_to             = ' ||  p_qtev_tbl(k).date_effective_to          );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).date_accepted                 = ' ||  p_qtev_tbl(k).date_accepted              );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).payment_received_yn           = ' ||  p_qtev_tbl(k).payment_received_yn        );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).requested_by                  = ' ||  p_qtev_tbl(k).requested_by               );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).approved_yn                   = ' ||  p_qtev_tbl(k).approved_yn                );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).accepted_yn                   = ' ||  p_qtev_tbl(k).accepted_yn                );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).date_payment_received         = ' ||  p_qtev_tbl(k).date_payment_received      );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).approved_by                   = ' ||  p_qtev_tbl(k).approved_by                );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).org_id                        = ' ||  p_qtev_tbl(k).org_id                     );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).request_id                    = ' ||  p_qtev_tbl(k).request_id                 );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).program_application_id        = ' ||  p_qtev_tbl(k).program_application_id     );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).program_id                    = ' ||  p_qtev_tbl(k).program_id                 );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).program_update_date           = ' ||  p_qtev_tbl(k).program_update_date        );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute_category            = ' ||  p_qtev_tbl(k).attribute_category         );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute1                    = ' ||  p_qtev_tbl(k).attribute1                 );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute2                    = ' ||  p_qtev_tbl(k).attribute2                 );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute3                    = ' ||  p_qtev_tbl(k).attribute3                 );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute4                    = ' ||  p_qtev_tbl(k).attribute4                 );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute5                    = ' ||  p_qtev_tbl(k).attribute5                 );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute6                    = ' ||  p_qtev_tbl(k).attribute6                 );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute7                    = ' ||  p_qtev_tbl(k).attribute7                 );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute8                    = ' ||  p_qtev_tbl(k).attribute8                 );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute9                    = ' ||  p_qtev_tbl(k).attribute9                 );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute10                   = ' ||  p_qtev_tbl(k).attribute10                );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute11                   = ' ||  p_qtev_tbl(k).attribute11                );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute12                   = ' ||  p_qtev_tbl(k).attribute12                );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute13                   = ' ||  p_qtev_tbl(k).attribute13                );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute14                   = ' ||  p_qtev_tbl(k).attribute14                );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute15               = ' ||  p_qtev_tbl(k).attribute15                );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).created_by                    = ' ||  p_qtev_tbl(k).created_by                 );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).creation_date                 = ' ||  p_qtev_tbl(k).creation_date              );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).last_updated_by               = ' ||  p_qtev_tbl(k).last_updated_by            );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).last_update_date              = ' ||  p_qtev_tbl(k).last_update_date           );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).date_restructure_end          = ' ||  p_qtev_tbl(k).date_restructure_end              );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).remaining_payments            = ' ||  p_qtev_tbl(k).remaining_payments                );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).rent_amount                   = ' ||  p_qtev_tbl(k).rent_amount                       );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).yield                         = ' ||  p_qtev_tbl(k).yield                             );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).residual_amount               = ' ||  p_qtev_tbl(k).residual_amount                   );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).principal_paydown_amount      = ' ||  p_qtev_tbl(k).principal_paydown_amount          );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).payment_frequency             = ' ||  p_qtev_tbl(k).payment_frequency                 );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).early_termination_yn          = ' ||  p_qtev_tbl(k).early_termination_yn              );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).partial_yn                    = ' ||  p_qtev_tbl(k).partial_yn                        );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).preproceeds_yn                = ' ||  p_qtev_tbl(k).preproceeds_yn                    );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).summary_format_yn             = ' ||  p_qtev_tbl(k).summary_format_yn                 );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).consolidated_yn               = ' ||  p_qtev_tbl(k).consolidated_yn                   );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).date_requested                = ' ||  p_qtev_tbl(k).date_requested                    );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).date_proposal                 = ' ||  p_qtev_tbl(k).date_proposal                     );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).date_effective_to             = ' ||  p_qtev_tbl(k).date_effective_to                 );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).date_accepted                 = ' ||  p_qtev_tbl(k).date_accepted               );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).payment_received_yn           = ' ||  p_qtev_tbl(k).payment_received_yn         );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).requested_by                  = ' ||  p_qtev_tbl(k).requested_by                );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).approved_yn                   = ' ||  p_qtev_tbl(k).approved_yn                 );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).accepted_yn                   = ' ||  p_qtev_tbl(k).accepted_yn                 );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).date_payment_received         = ' ||  p_qtev_tbl(k).date_payment_received       );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).approved_by                   = ' ||  p_qtev_tbl(k).approved_by                 );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).org_id                        = ' ||  p_qtev_tbl(k).org_id                      );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).request_id                    = ' ||  p_qtev_tbl(k).request_id                  );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).program_application_id        = ' ||  p_qtev_tbl(k).program_application_id      );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).program_id                    = ' ||  p_qtev_tbl(k).program_id                 );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).program_update_date           = ' ||  p_qtev_tbl(k).program_update_date        );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute_category            = ' ||  p_qtev_tbl(k).attribute_category         );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute1                    = ' ||  p_qtev_tbl(k).attribute1                 );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute2                    = ' ||  p_qtev_tbl(k).attribute2                 );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute3                    = ' ||  p_qtev_tbl(k).attribute3                 );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute4                    = ' ||  p_qtev_tbl(k).attribute4                 );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute5                    = ' ||  p_qtev_tbl(k).attribute5                 );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute6                    = ' ||  p_qtev_tbl(k).attribute6                 );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute7                    = ' ||  p_qtev_tbl(k).attribute7                 );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute8                    = ' ||  p_qtev_tbl(k).attribute8                 );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute9                    = ' ||  p_qtev_tbl(k).attribute9                 );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute10                   = ' ||  p_qtev_tbl(k).attribute10                );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute11                   = ' ||  p_qtev_tbl(k).attribute11                );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute12                   = ' ||  p_qtev_tbl(k).attribute12                );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute13                   = ' ||  p_qtev_tbl(k).attribute13                );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute14                   = ' ||  p_qtev_tbl(k).attribute14                );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).attribute15                   = ' ||  p_qtev_tbl(k).attribute15                );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).created_by                    = ' ||  p_qtev_tbl(k).created_by                 );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).creation_date                 = ' ||  p_qtev_tbl(k).creation_date              );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).last_updated_by               = ' ||  p_qtev_tbl(k).last_updated_by            );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).last_update_date              = ' ||  p_qtev_tbl(k).last_update_date           );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).last_update_login             = ' ||  p_qtev_tbl(k).last_update_login          );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).purchase_amount               = ' ||  p_qtev_tbl(k).purchase_amount            );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).purchase_formula              = ' ||  p_qtev_tbl(k).purchase_formula           );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).asset_value                   = ' ||  p_qtev_tbl(k).asset_value                );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).residual_value                = ' ||  p_qtev_tbl(k).residual_value             );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).unbilled_receivables          = ' ||  p_qtev_tbl(k).unbilled_receivables       );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).gain_loss                     = ' ||  p_qtev_tbl(k).gain_loss                  );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).PERDIEM_AMOUNT                = ' ||  p_qtev_tbl(k).PERDIEM_AMOUNT             );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).currency_code                 = ' ||  p_qtev_tbl(k).currency_code              );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).currency_conversion_code      = ' ||  p_qtev_tbl(k).currency_conversion_code   );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).currency_conversion_type      = ' ||  p_qtev_tbl(k).currency_conversion_type   );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).currency_conversion_rate      = ' ||  p_qtev_tbl(k).currency_conversion_rate   );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).currency_conversion_date      = ' ||  p_qtev_tbl(k).currency_conversion_date   );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).legal_entity_id               = ' ||  p_qtev_tbl(k).legal_entity_id            );
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qtev_tbl(k).repo_quote_indicator_yn       = ' ||  p_qtev_tbl(k).repo_quote_indicator_yn    );

                   END IF;
                 END LOOP;
         END IF;
         IF p_party_tbl.COUNT > 0 THEN
           FOR l IN p_party_tbl.FIRST..p_party_tbl.LAST LOOP
             IF p_party_tbl.exists(l) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).quote_id               = ' ||  p_party_tbl(l).quote_id             );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).contract_id            = ' ||  p_party_tbl(l).contract_id          );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).k_buy_or_sell          = ' ||  p_party_tbl(l).k_buy_or_sell        );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).qp_party_id            = ' ||  p_party_tbl(l).qp_party_id          );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).qp_role_code           = ' ||  p_party_tbl(l).qp_role_code         );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).qp_party_role          = ' ||  p_party_tbl(l).qp_party_role        );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).qp_date_sent           = ' ||  p_party_tbl(l).qp_date_sent         );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).qp_date_hold           = ' ||  p_party_tbl(l).qp_date_hold         );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).qp_created_by          = ' ||  p_party_tbl(l).qp_created_by        );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).qp_creation_date       = ' ||  p_party_tbl(l).qp_creation_date     );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).qp_last_updated_by     = ' ||  p_party_tbl(l).qp_last_updated_by   );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).qp_last_update_date    = ' ||  p_party_tbl(l).qp_last_update_date  );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).qp_last_update_login   = ' ||  p_party_tbl(l).qp_last_update_login );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).kp_party_id            = ' ||  p_party_tbl(l).kp_party_id          );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).kp_role_code           = ' ||  p_party_tbl(l).kp_role_code         );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).kp_party_role          = ' ||  p_party_tbl(l).kp_party_role        );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).po_party_id1           = ' ||  p_party_tbl(l).po_party_id1         );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).po_party_id2           = ' ||  p_party_tbl(l).po_party_id2         );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).po_party_object        = ' ||  p_party_tbl(l).po_party_object      );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).po_party_name          = ' ||  p_party_tbl(l).po_party_name        );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).po_party_desc          = ' ||  p_party_tbl(l).po_party_desc        );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).co_contact_id1         = ' ||  p_party_tbl(l).co_contact_id1       );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).co_contact_id2         = ' ||  p_party_tbl(l).co_contact_id2       );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).co_contact_object      = ' ||  p_party_tbl(l).co_contact_object    );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).co_contact_name        = ' ||  p_party_tbl(l).co_contact_name      );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).co_contact_desc        = ' ||  p_party_tbl(l).co_contact_desc      );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).co_email               = ' ||  p_party_tbl(l).co_email             );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).co_order_num           = ' ||  p_party_tbl(l).co_order_num         );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).co_date_sent           = ' ||  p_party_tbl(l).co_date_sent         );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).cp_point_id            = ' ||  p_party_tbl(l).cp_point_id          );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).cp_point_type          = ' ||  p_party_tbl(l).cp_point_type        );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).cp_primary_flag        = ' ||  p_party_tbl(l).cp_primary_flag      );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).cp_email               = ' ||  p_party_tbl(l).cp_email             );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).cp_details             = ' ||  p_party_tbl(l).cp_details           );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).cp_order_num           = ' ||  p_party_tbl(l).cp_order_num         );
                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_party_tbl(l).cp_date_sent           = ' ||  p_party_tbl(l).cp_date_sent         );
             END IF;
           END LOOP;
         END IF;
      END IF;
      OKL_AM_SEND_FULFILLMENT_PUB.send_terminate_quote(
            p_api_version                 => p_api_version,
            p_init_msg_list               => FND_API.G_FALSE,
            x_return_status               => x_return_status,
            x_msg_count                   => x_msg_count,
            x_msg_data                    => x_msg_data,
            p_party_tbl                   => p_party_tbl,
            x_party_tbl                   => x_party_tbl,
            p_qtev_rec                    => p_qtev_tbl(i),
            x_qtev_rec                    => x_qtev_tbl(i));

       IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_am_create_quote_pub.send_terminate_quote , return status: ' || x_return_status);
       END IF;

        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF (is_debug_exception_on) THEN
             OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
           END IF;
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        EXIT WHEN (i = p_qtev_tbl.LAST);
        i := p_qtev_tbl.NEXT(i);
      END LOOP;
      x_return_status := l_overall_status;
    END IF;
    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;
  END send_terminate_quote;
END OKL_CS_CREATE_QUOTE_PVT;

/
