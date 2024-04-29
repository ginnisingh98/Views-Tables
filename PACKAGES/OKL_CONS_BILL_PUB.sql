--------------------------------------------------------
--  DDL for Package OKL_CONS_BILL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CONS_BILL_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPKONS.pls 120.1 2005/06/15 17:15:34 stmathew noship $ */
   PROCEDURE create_cons_bill(
	       p_api_version                  IN NUMBER,
    	   p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    	   x_return_status                OUT NOCOPY VARCHAR2,
    	   x_msg_count                    OUT NOCOPY NUMBER,
    	   x_msg_data                     OUT NOCOPY VARCHAR2,
           p_inv_msg                      IN VARCHAR2,
           p_assigned_process             IN VARCHAR2
        );

  PROCEDURE create_cons_bill
  ( errbuf                         OUT NOCOPY VARCHAR2
  , retcode                        OUT NOCOPY NUMBER
  , p_inv_msg                      IN  VARCHAR2 DEFAULT 'TRUE'
  , p_assigned_process             IN  VARCHAR2
  );


END Okl_Cons_Bill_Pub;

 

/
