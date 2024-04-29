--------------------------------------------------------
--  DDL for Package Body OKC_WORD_SYNC_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_WORD_SYNC_HOOK" AS
/* $Header: OKCWDHKB.pls 120.0.12010000.1 2011/12/23 08:03:51 serukull noship $ */

   /* Global constants*/
   g_pkg_name              CONSTANT VARCHAR2 (200) := 'OKC_WORD_SYNC_HOOK';
   g_app_name              CONSTANT VARCHAR2 (3)   := okc_api.g_app_name;
   g_module                CONSTANT VARCHAR2 (250)
                                         := 'OKC.plsql.' || g_pkg_name || '.';
   g_false                 CONSTANT VARCHAR2 (1)   := fnd_api.g_false;
   g_true                  CONSTANT VARCHAR2 (1)   := fnd_api.g_true;
   g_okc                   CONSTANT VARCHAR2 (3)   := 'OKC';
   g_ret_sts_success       CONSTANT VARCHAR2 (1)   := fnd_api.g_ret_sts_success;
   g_ret_sts_error         CONSTANT VARCHAR2 (1)   := fnd_api.g_ret_sts_error;
   g_ret_sts_unexp_error   CONSTANT VARCHAR2 (1)
                                             := fnd_api.g_ret_sts_unexp_error;
   g_unexpected_error      CONSTANT VARCHAR2 (200) := 'OKC_UNEXPECTED_ERROR';
   g_sqlerrm_token         CONSTANT VARCHAR2 (200) := 'ERROR_MESSAGE';
   g_sqlcode_token         CONSTANT VARCHAR2 (200) := 'ERROR_CODE';


  G_DBG_LEVEL							  NUMBER 		:= FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_PROC_LEVEL							NUMBER		:= FND_LOG.LEVEL_PROCEDURE;
  G_EXCP_LEVEL							NUMBER		:= FND_LOG.LEVEL_EXCEPTION;




/**=============================================================================
-- Created by serukull
Procedure        : download_contract_ext
Purpose          : The Contract document is available in Word 2003 XML (Word ML) format
                to the procedure. So any customizations to the document can be made
                in this procedure before the document gets downloaded to the desktop.
                Examples Include: Hiding the section titles.
                                  Hiding clause titles.
                                  Customization of Header and Footer elemetns.
                                  Other formattings.

Input Parameters:
==========================
  p_doc_type      :  Business Document Type
  p_doc_id        :  Business Document Id
  p_init_msg_list :  Message Stack initialization

In Out Parameters:
===========================
  x_contract_xml  : Contract document in Word 2003 XML format

Out  Parameters :
===========================
  x_return_status  : Return Status
                        'S' --> Success
                        'E' --> Error
                        'U' --> Unexpected Error
  x_msg_count      : Message Count
  x_msg_data     : Message Data (that can be shown in the UI in case of any error)

===============================================================================*/
PROCEDURE DOWNLOAD_CONTRACT_EXT(
      	p_doc_type                     IN  VARCHAR2,
    		p_doc_id                       IN  NUMBER,
        p_init_msg_list                IN VARCHAR2 := FND_API.G_FALSE,
        x_contract_xml                 IN OUT NOCOPY CLOB,
    		x_return_status                OUT NOCOPY VARCHAR2,
    		x_msg_count                    OUT NOCOPY NUMBER,
	    	x_msg_data                     OUT NOCOPY VARCHAR2
      )
      IS
l_api_name VARCHAR2(240) := 'DOWNLOAD_CONTRACT_EXT';

BEGIN

-- Initialize the return status to 'S'
x_return_status :=  g_ret_sts_success;

/* Comment this line*/
RETURN;

-- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                     G_MODULE||l_api_name,
                    '100: Start');
  END IF;

  /* Add your Processing Code Here */


  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                       G_MODULE||l_api_name,
                       '100: End');
  END IF;

EXCEPTION
WHEN OTHERS THEN
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                    G_MODULE||l_api_name,
                    '999: Exception '||sqlerrm);
 END IF;

 x_return_status := g_ret_sts_unexp_error;
 Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => sqlcode,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => sqlerrm);
 -- Standard call to get message count and if count is 1, get message info.
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );


END DOWNLOAD_CONTRACT_EXT;
END OKC_WORD_SYNC_HOOK;

/
