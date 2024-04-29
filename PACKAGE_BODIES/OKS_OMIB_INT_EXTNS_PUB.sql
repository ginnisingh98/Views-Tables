--------------------------------------------------------
--  DDL for Package Body OKS_OMIB_INT_EXTNS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_OMIB_INT_EXTNS_PUB" AS
/* $Header: OKSPOIXB.pls 120.1 2005/06/28 23:57:02 upillai noship $ */

  /* GLOBAL Variables for the procedures and functions of this package body */
  G_APP_NAME             CONSTANT VARCHAR2(200) := 'OKS';
  G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'ERROR_CODE';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';
  G_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(200) :=  FND_API.G_RET_STS_UNEXP_ERROR;
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKS_OMIB_INT_EXTNS_PUB';
  G_MODULE_CURRENT       CONSTANT VARCHAR2(255) := 'oks.plsql.oks_omib_int_extns_pub';

  PROCEDURE pre_integration(p_api_version      IN NUMBER
                           ,p_init_msg_list    IN VARCHAR2
                           ,p_from_integration IN VARCHAR2
                           ,p_transaction_type IN VARCHAR2
                           ,p_transaction_date IN DATE
                           ,p_order_line_id    IN NUMBER
                           ,p_old_instance_id  IN NUMBER
                           ,p_new_instance_id  IN NUMBER
					  ,x_process_status   OUT NOCOPY VARCHAR2
                           ,x_return_status    OUT NOCOPY VARCHAR2
                           ,x_msg_count        OUT NOCOPY NUMBER
                           ,x_msg_data         OUT NOCOPY VARCHAR2)
  IS
    l_api_name CONSTANT VARCHAR2(30) := 'pre_integration';
  BEGIN
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_PROCEDURE
                   ,G_MODULE_CURRENT||'.pre_integration.begin'
	              ,'p_api_version = '|| p_api_version ||
                 ' ,p_init_msg_list = ' || p_init_msg_list ||
                 ' ,p_from_integration = ' || p_from_integration ||
                 ' ,p_transaction_type = ' || p_transaction_type ||
                 ' ,p_transaction_date = ' || p_transaction_date ||
                 ' ,p_order_line_id = ' || p_order_line_id ||
                 ' ,p_old_instance_id = ' || p_old_instance_id ||
                 ' ,p_new_instance_id = ' || p_new_instance_id);
    END IF;

    IF (FND_API.to_boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
    END IF;
    x_process_status := 'C'; -- C - Continue the existing logic on the caller
    x_return_status  := FND_API.G_RET_STS_SUCCESS;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE
                    ,G_MODULE_CURRENT||'.pre_integration.end'
	               ,'x_process_status = ' || x_process_status ||
                  ' ,x_return_status = ' || x_return_status);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_UNEXPECTED
	                 ,G_MODULE_CURRENT||'.post_integration.UNEXPECTED'
	                 ,'sqlcode = '||sqlcode||' ,sqlerrm = '||sqlerrm);
      END IF;
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      OKC_API.set_message
              ( p_app_name     => 'OKC',
                p_msg_name     => 'OKC_CONTRACTS_UNEXP_ERROR',
                p_token1       => G_SQLCODE_TOKEN,
                p_token1_value => sqlcode,
                p_token2       => G_SQLERRM_TOKEN,
                p_token2_value => sqlerrm
              );
      FND_MSG_PUB.Count_And_Get
	    (
         p_count => x_msg_count,
         p_data => x_msg_data
		);
     x_process_status := 'U'; -- U - Unexpected Error
  END pre_integration;

  PROCEDURE post_integration(p_api_version      IN NUMBER
                            ,p_init_msg_list    IN VARCHAR2
                            ,p_from_integration IN VARCHAR2
                            ,p_transaction_type IN VARCHAR2
                            ,p_transaction_date IN DATE
                            ,p_order_line_id    IN NUMBER
                            ,p_old_instance_id  IN NUMBER
                            ,p_new_instance_id  IN NUMBER
                            ,p_chr_id           IN NUMBER
                            ,p_topline_id       IN NUMBER
                            ,p_subline_id       IN NUMBER
                            ,x_return_status    OUT NOCOPY VARCHAR2
                            ,x_msg_count        OUT NOCOPY NUMBER
                            ,x_msg_data         OUT NOCOPY VARCHAR2)
  IS
  BEGIN

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string(FND_LOG.LEVEL_PROCEDURE
                   ,G_MODULE_CURRENT||'.post_integration.begin'
                   ,'p_api_version = '|| p_api_version ||
                 ' ,p_init_msg_list = ' || p_init_msg_list ||
                 ' ,p_from_integration = ' || p_from_integration ||
                 ' ,p_transaction_type = ' || p_transaction_type ||
                 ' ,p_transaction_date = ' || p_transaction_type ||
                 ' ,p_order_line_id = ' || p_order_line_id ||
                 ' ,p_old_instance_id = ' || p_old_instance_id ||
                 ' ,p_new_instance_id = ' || p_new_instance_id ||
			  ' ,p_chr_id = ' || p_chr_id ||
			  ' ,p_topline_id = ' || p_topline_id ||
			  ' ,p_subline_id = ' || p_subline_id);
    END IF;

    IF (FND_API.to_boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE
                    ,G_MODULE_CURRENT||'.post_integration.end'
                    ,'x_return_status = ' || x_return_status);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_UNEXPECTED
	                 ,G_MODULE_CURRENT||'.post_integration.UNEXPECTED'
	                 ,'sqlcode = '||sqlcode||' ,sqlerrm = '||sqlerrm);
      END IF;
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      OKC_API.set_message
              ( p_app_name     => 'OKC',
                p_msg_name     => 'OKC_CONTRACTS_UNEXP_ERROR',
                p_token1       => G_SQLCODE_TOKEN,
                p_token1_value => sqlcode,
                p_token2       => G_SQLERRM_TOKEN,
                p_token2_value => sqlerrm
              );
      FND_MSG_PUB.Count_And_Get
	    (
         p_count => x_msg_count,
         p_data => x_msg_data
		);
  END post_integration;

END OKS_OMIB_INT_EXTNS_PUB;

/
