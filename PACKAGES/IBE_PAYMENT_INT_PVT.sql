--------------------------------------------------------
--  DDL for Package IBE_PAYMENT_INT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_PAYMENT_INT_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVPINS.pls 120.6 2005/11/19 20:03:34 mannamra noship $ */
-- Start of Comments
-- Package name     : IBE_payment_int_pvt
-- Purpose          :
-- NOTE             :
-- End of Comments

procedure save_credit_card
(p_api_version           IN Number
,p_init_msg_list         IN VARCHAR2 := FND_API.G_FALSE
,p_commit                IN VARCHAR2 := FND_API.G_FALSE
,p_operation_code        IN VARCHAR2
,p_credit_card_id        IN NUMBER
,p_assignment_id         IN NUMBER
,p_currency_code         IN VARCHAR2
,p_credit_card_num       IN VARCHAR2
,p_card_holder_name      IN VARCHAR2
,p_exp_date              IN DATE
,p_credit_card_type_code IN VARCHAR2
,p_party_id              IN NUMBER
,p_cust_id               IN NUMBER
,p_statement_address_id  IN NUMBER := FND_API.G_MISS_NUM
,x_credit_card_id        OUT NOCOPY  NUMBER
,x_assignment_id         OUT NOCOPY  NUMBER
,x_return_status         OUT NOCOPY  VARCHAR2
,x_msg_count             OUT NOCOPY  NUMBER
,x_msg_data              OUT NOCOPY  VARCHAR2 ) ;

PROCEDURE check_Payment_channel_setups
(p_api_version             IN Number
,p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE
,p_commit                  IN VARCHAR2 := FND_API.G_FALSE
,x_cvv2_setup              OUT NOCOPY  VARCHAR2
,x_statement_address_setup OUT NOCOPY  VARCHAR2
,x_return_status           OUT NOCOPY  VARCHAR2
,x_msg_count               OUT NOCOPY  NUMBER
,x_msg_data                OUT NOCOPY  VARCHAR2 );

PROCEDURE print_debug_log(p_debug_str IN VARCHAR2);

PROCEDURE mig_exp_checkout_pay_setup
(errbuf        OUT NOCOPY VARCHAR2
 ,retcode       OUT NOCOPY NUMBER
 ,p_debug_flag  IN VARCHAR2
 ,p_commit_size IN NUMBER);

 PROCEDURE migrate_primary_CC(
 errbuf        OUT NOCOPY VARCHAR2
 ,retcode       OUT NOCOPY NUMBER
 ,p_debug_flag  IN VARCHAR2
 ,p_commit_size IN NUMBER);


PROCEDURE migrate_ibe_cc_data(
p_cut_off_date date
,errbuf OUT NOCOPY VARCHAR2
,retcode OUT NOCOPY NUMBER);

END IBE_PAYMENT_INT_PVT;

 

/
