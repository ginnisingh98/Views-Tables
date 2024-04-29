--------------------------------------------------------
--  DDL for Package OKS_REPROC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_REPROC_PUB" AUTHID CURRENT_USER As
/* $Header: OKSOREPS.pls 115.4 2004/05/24 10:10:35 mmadhavi noship $ */

PROCEDURE submit_request(x_request_id OUT NOCOPY NUMBER);

Procedure insert_order_line(p_ordline_id IN NUMBER,
                            p_processed IN VARCHAR2,
                            p_reprocess IN VARCHAR2,
                            p_hdr_id IN NUMBER,
			    p_ordnum IN NUMBER,
			    x_id OUT NOCOPY VARCHAR2,
			    x_rowid OUT NOCOPY VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2
                           );
Procedure Update_Order_Lines(p_item IN VARCHAR2,
			     x_return_status OUT NOCOPY VARCHAR2
			     );
Procedure translate_msg(p_id IN NUMBER,x_msg OUT NOCOPY VARCHAR2);


END OKS_REPROC_PUB;

 

/
