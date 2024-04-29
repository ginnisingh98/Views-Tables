--------------------------------------------------------
--  DDL for Package PSA_MULTIFUND_DISTRIBUTION_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSA_MULTIFUND_DISTRIBUTION_EXT" AUTHID CURRENT_USER AS
/* $Header: PSAMFEXS.pls 120.2 2006/09/13 12:36:04 agovil noship $ */

FUNCTION CREATE_DISTRIBUTIONS_PUB
          (p_init_msg_list            IN  VARCHAR2 := FND_API.G_FALSE,
           x_return_status     	      OUT NOCOPY VARCHAR2,
           x_msg_count                OUT NOCOPY NUMBER,
           x_msg_data                 OUT NOCOPY VARCHAR2,
           p_sob_id                   IN  NUMBER,
           p_doc_id                   IN  NUMBER,
	   p_report_only	      IN  VARCHAR2 DEFAULT 'N') RETURN BOOLEAN;

END PSA_MULTIFUND_DISTRIBUTION_EXT;

 

/
