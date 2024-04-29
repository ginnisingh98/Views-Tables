--------------------------------------------------------
--  DDL for Package Body OKL_CONS_BILL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CONS_BILL_PUB" AS
/* $Header: OKLPKONB.pls 120.5 2005/09/06 16:51:01 stmathew noship $ */

PROCEDURE create_cons_bill (
   	       p_api_version                  IN NUMBER,
    	   p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    	   x_return_status                OUT NOCOPY VARCHAR2,
    	   x_msg_count                    OUT NOCOPY NUMBER,
    	   x_msg_data                     OUT NOCOPY VARCHAR2,
           p_inv_msg                      IN VARCHAR2,
           p_assigned_process             IN VARCHAR2
        )
IS

l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);

BEGIN

   	  Okl_Cons_Bill.CREATE_CONS_BILL(
  	       p_api_version      => p_api_version,
    	   p_init_msg_list    => p_init_msg_list,
           p_commit           => FND_API.G_TRUE,
    	   x_return_status    => x_return_status,
    	   x_msg_count        => x_msg_count,
    	   x_msg_data         => x_msg_data,
           p_inv_msg          => p_inv_msg,
           p_assigned_process => p_assigned_process);

EXCEPTION
    WHEN OTHERS THEN
        -- -------------------------------------------
        -- Purge data from the Parallel process Table
        -- -------------------------------------------
        IF p_assigned_process IS NOT NULL THEN
            DELETE OKL_PARALLEL_PROCESSES
            WHERE assigned_process = p_assigned_process;
            COMMIT;
        END IF;

END create_cons_bill;

  PROCEDURE create_cons_bill
  ( errbuf                         OUT NOCOPY VARCHAR2
  , retcode                        OUT NOCOPY NUMBER
  , p_inv_msg                      IN  VARCHAR2
  , p_assigned_process             IN  VARCHAR2
  )  IS

  l_api_vesrions   NUMBER := 1;
  lx_msg_count     NUMBER;
  l_count1          NUMBER;
  l_count2          NUMBER;
  l_count           NUMBER;
  lx_msg_data       VARCHAR2(450);
  i                 NUMBER:=0;
  l_msg_index_out   NUMBER:=0;
  lx_return_status  VARCHAR2(1);

    BEGIN


           create_cons_bill( p_api_version      => l_api_vesrions,
                             p_init_msg_list    => OKC_API.G_FALSE,
                        	 x_return_status    => lx_return_status,
                        	 x_msg_count        => lx_msg_count,
                        	 x_msg_data         => errbuf,
                             p_inv_msg          => p_inv_msg,
                             p_assigned_process => p_assigned_process
                         );
  EXCEPTION
    WHEN OTHERS THEN
        -- -------------------------------------------
        -- Purge data from the Parallel process Table
        -- -------------------------------------------
        IF p_assigned_process IS NOT NULL THEN
            DELETE OKL_PARALLEL_PROCESSES
            WHERE assigned_process = p_assigned_process;
            COMMIT;
        END IF;

  END;

END Okl_Cons_Bill_Pub;

/
