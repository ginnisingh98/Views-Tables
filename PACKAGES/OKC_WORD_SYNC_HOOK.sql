--------------------------------------------------------
--  DDL for Package OKC_WORD_SYNC_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_WORD_SYNC_HOOK" AUTHID CURRENT_USER AS
/* $Header: OKCWDHKS.pls 120.0.12010000.1 2011/12/23 08:03:19 serukull noship $ */

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
  p_doc_type  :  Business Document Type
  p_doc_id    :  Business Document Id

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
  x_msg_data       : Message Data (that can be shown in the UI in case of any error)

===============================================================================*/
  PROCEDURE download_contract_ext(
      	p_doc_type                     IN  VARCHAR2,
    		p_doc_id                       IN  NUMBER,
        p_init_msg_list                IN VARCHAR2 := FND_API.G_FALSE,
        x_contract_xml   IN OUT NOCOPY CLOB,
    		x_return_status                OUT NOCOPY VARCHAR2,
    		x_msg_count                    OUT NOCOPY NUMBER,
	    	x_msg_data                     OUT NOCOPY VARCHAR2
      );
END OKC_WORD_SYNC_HOOK;

/
