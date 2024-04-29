--------------------------------------------------------
--  DDL for Package Body OKL_CS_CREATE_QUOTE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CS_CREATE_QUOTE_PUB" AS
/* $Header: OKLPCTQB.pls 120.3 2007/12/17 04:58:55 asawanka ship $ */
 G_LEVEL_PROCEDURE CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
 G_LEVEL_EXCEPTION CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
 G_LEVEL_STATEMENT CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
 G_MODULE_NAME CONSTANT VARCHAR2(500) := 'okl.am.plsql.okl_cs_create_quote_pub.';

 PROCEDURE create_terminate_quote(
    p_api_version               IN NUMBER,
    p_init_msg_list             IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    p_quot_tbl                  IN quot_tbl_type,
    p_assn_tbl		        IN  OKL_AM_CREATE_QUOTE_PUB.assn_tbl_type,
    p_qpyv_tbl                  IN  qpyv_tbl_type DEFAULT G_EMPTY_QPYV_TBL,
    x_quot_tbl                 	OUT NOCOPY quot_tbl_type,
    x_tqlv_tbl			OUT NOCOPY  OKL_AM_CREATE_QUOTE_PUB.tqlv_tbl_type,
    x_assn_tbl			OUT NOCOPY  OKL_AM_CREATE_QUOTE_PUB.assn_tbl_type)AS

    l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);

    l_request_id             NUMBER;
    -- asawanka added for debug feature start
    l_module_name VARCHAR2(500) := G_MODULE_NAME || 'create_terminate_quote';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

    -- asawanka added for debug feature end

  BEGIN

    --SAVEPOINT create_terminate_quote;
  ------------ Call to Private Process API--------------
    IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'Begin(+)');
    END IF;

    IF (is_debug_statement_on) THEN
      FOR i IN p_quot_tbl.FIRST..p_quot_tbl.LAST LOOP
       IF p_quot_tbl.exists(i) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'Calling  okl_cs_create_quote_pvt.create_terminate_quote with parameters: ');
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
       END IF;
      END LOOP;
        IF (p_assn_tbl.COUNT > 0) THEN
                FOR ll IN p_assn_tbl.FIRST..p_assn_tbl.LAST LOOP
                  IF  p_assn_tbl.exists(ll) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_assn_tbl(l).'||'p_asset_id   :'|| p_assn_tbl(ll).p_asset_id   );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_assn_tbl(l).'||'p_asset_number   :'|| p_assn_tbl(ll).p_asset_number      );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_assn_tbl(l).'||'p_asset_qty   :'|| p_assn_tbl(ll).p_asset_qty         );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_assn_tbl(l).'||'p_quote_qty   :'|| p_assn_tbl(ll).p_quote_qty         );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_assn_tbl(l).'||'p_split_asset_number   :'|| p_assn_tbl(ll).p_split_asset_number);
                  END IF;
                End loop;
        END IF;
        IF  (p_qpyv_tbl.COUNT > 0) THEN
                FOR l1 IN p_qpyv_tbl.FIRST..p_qpyv_tbl.LAST LOOP
                  IF  p_qpyv_tbl.exists(l1) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).id                        = ' ||   p_qpyv_tbl(l1).id                        );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).qte_id                    = ' ||   p_qpyv_tbl(l1).qte_id                    );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).cpl_id                    = ' ||   p_qpyv_tbl(l1).cpl_id                    );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).object_version_number     = ' ||   p_qpyv_tbl(l1).object_version_number     );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).date_sent                 = ' ||   p_qpyv_tbl(l1).date_sent                 );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).created_by                = ' ||   p_qpyv_tbl(l1).created_by                );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).creation_date             = ' ||   p_qpyv_tbl(l1).creation_date             );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).last_updated_by           = ' ||   p_qpyv_tbl(l1).last_updated_by           );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).last_update_date          = ' ||   p_qpyv_tbl(l1).last_update_date          );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).last_update_login         = ' ||   p_qpyv_tbl(l1).last_update_login         );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).qpt_code                  = ' ||   p_qpyv_tbl(l1).qpt_code                  );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).delay_days                = ' ||   p_qpyv_tbl(l1).delay_days                );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).allocation_percentage     = ' ||   p_qpyv_tbl(l1).allocation_percentage     );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).email_address             = ' ||   p_qpyv_tbl(l1).email_address             );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).party_jtot_object1_code   = ' ||   p_qpyv_tbl(l1).party_jtot_object1_code   );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).party_object1_id1         = ' ||   p_qpyv_tbl(l1).party_object1_id1         );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).party_object1_id2         = ' ||   p_qpyv_tbl(l1).party_object1_id2         );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).contact_jtot_object1_code = ' ||   p_qpyv_tbl(l1).contact_jtot_object1_code );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).contact_object1_id1       = ' ||   p_qpyv_tbl(l1).contact_object1_id1       );
                          OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,' p_qpyv_tbl(l).contact_object1_id2       = ' ||   p_qpyv_tbl(l1).contact_object1_id2       );

                  END IF;
                End loop;

         END IF;
      END IF;

    OKL_CS_CREATE_QUOTE_PVT.create_terminate_quote (p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            x_return_status => l_return_status,
                                            x_msg_count     => l_msg_count,
                                            x_msg_data      => l_msg_data,
                                            p_quot_tbl      => p_quot_tbl,
                                            p_assn_tbl      => p_assn_tbl,
                                            p_qpyv_tbl      => p_qpyv_tbl,
                                            x_quot_tbl      => x_quot_tbl,
                                            x_tqlv_tbl      => x_tqlv_tbl,
                                            x_assn_tbl      => x_assn_tbl);

    IF (is_debug_statement_on) THEN
         OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,l_module_name,'called okl_cs_create_quote_pvt.create_terminate_quote , return status: ' || l_return_status);
    END IF;
    IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_ERROR');
      END IF;
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      IF (is_debug_exception_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,l_module_name, 'EXCEPTION :'||'G_EXCEPTION_UNEXPECTED_ERROR');
      END IF;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

  ------------ End Call to Private Process API--------------
  x_return_status := l_return_status;
  IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,l_module_name  ,'End (-)');
    END IF;
  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      --ROLLBACK TO create_terminate_quote;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      --ROLLBACK TO create_terminate_quote;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OTHERS THEN
      --ROLLBACK TO create_terminate_quote;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_CS_CREATE_QUOTE_PUB','create_terminate_quote');
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

  END create_terminate_quote;

END OKL_CS_CREATE_QUOTE_PUB;

/
