--------------------------------------------------------
--  DDL for Package OKS_OMIB_INT_EXTNS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_OMIB_INT_EXTNS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKSPOIXS.pls 120.1 2005/06/28 23:55:31 upillai noship $ */

 /*==================================================================
  Procedure  : pre_integration
  Description: This Procedure can be used to include custom logic before
               any Contract Operation due to IB instance operation.
               This is called from :
               1. oks_ibint_pub.ib_interface only for "Replace"(RPL)
                  transaction types. From ib_interface p_order_line_id
                  is passed as NULL.p_transaction_type is passed as "RPL"
               2. oks_ocint_pub.oc_interface. This case p_order_line_id
                  is passed. ie the NEW order line id.p_transaction_type
                  is passed as NULL.
               3. oks_ocint_pub.order_reprocess. This case also
                  p_order_line_id is passed. p_transaction_type is passed
                  as NULL.
               x_process_status should be 'C' if the caller needs to execute
			the existing code. Any other code should be treated as
			deffered(Existing code will not be executed).
               x_return_status has to be Success to do existing code
			and post integration
 ====================================================================*/
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
                           ,x_msg_data         OUT NOCOPY VARCHAR2);

 /*==================================================================
  Procedure  : post_integration
  Description: This procedure can be used to include custom logic after
               any Contract Operation due to IB instance operation.
               This is called from :
               1. oks_ibint_pub.ib_interface only for "Replace"(RPL)
                  transaction types. From ib_interface p_order_line_id
                  is passed as NULL.
               2. oks_ocint_pub.oc_interface. This case p_order_line_id
                  is passed. ie the NEW order line id.
               3. oks_ocint_pub.order_reprocess. This case also
                  p_order_line_id is passed.
 ====================================================================*/
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
                            ,x_msg_data         OUT NOCOPY VARCHAR2);

END OKS_OMIB_INT_EXTNS_PUB;

 

/
