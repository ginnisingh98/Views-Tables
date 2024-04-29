--------------------------------------------------------
--  DDL for Package CN_SYSTEM_PARAMETERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SYSTEM_PARAMETERS_PVT" AUTHID CURRENT_USER AS
/*$Header: cnvsysps.pls 115.5 2002/11/21 21:19:38 hlchen ship $*/

PROCEDURE Get_Data
  (x_name                    OUT NOCOPY VARCHAR2,
   x_status                  OUT NOCOPY VARCHAR2,
   x_status_code             OUT NOCOPY VARCHAR2,
   x_rev_class_hierarchy_id  OUT NOCOPY NUMBER,
   x_set_of_books_id         OUT NOCOPY NUMBER,
   x_sob_name                OUT NOCOPY VARCHAR2,
   x_sob_currency            OUT NOCOPY VARCHAR2,
   x_sob_calendar            OUT NOCOPY VARCHAR2,
   x_sob_period_type         OUT NOCOPY VARCHAR2,
   x_batch_size              OUT NOCOPY NUMBER,
   x_transfer_batch_size     OUT NOCOPY NUMBER,
   x_clawback_grace_days     OUT NOCOPY NUMBER,
   x_transaction_batch_size  OUT NOCOPY NUMBER,
   x_managerial_rollup       OUT NOCOPY VARCHAR2,
   x_latest_processed_date   OUT NOCOPY DATE,
   x_salesperson_batch_size  OUT NOCOPY NUMBER,
   x_rule_batch_size         OUT NOCOPY NUMBER,
   x_payables_flag           OUT NOCOPY VARCHAR2,
   x_payroll_flag            OUT NOCOPY VARCHAR2,
   x_payables_ccid_level     OUT NOCOPY VARCHAR2,
   x_usage_flag              OUT NOCOPY VARCHAR2,
   x_income_planner_disclaimer OUT NOCOPY VARCHAR2,
   x_object_version_number   OUT NOCOPY NUMBER);

PROCEDURE Update_Data
   (p_api_version             IN      NUMBER                          ,
    p_init_msg_list           IN      VARCHAR2 := FND_API.G_FALSE     ,
    p_commit                  IN      VARCHAR2 := FND_API.G_FALSE     ,
    p_validation_level        IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_name                    IN      VARCHAR2,
    p_rev_class_hierarchy_id  IN      NUMBER,
    p_set_of_books_id         IN      NUMBER,
    p_batch_size              IN      NUMBER,
    p_transfer_batch_size     IN      NUMBER,
    p_clawback_grace_days     IN      NUMBER,
    p_transaction_batch_size  IN      NUMBER,
    p_managerial_rollup       IN      VARCHAR2,
    p_salesperson_batch_size  IN      NUMBER,
    p_rule_batch_size         IN      NUMBER,
    p_payables_flag           IN      VARCHAR2,
    p_payroll_flag            IN      VARCHAR2,
    p_payables_ccid_level     IN      VARCHAR2,
    p_income_planner_disclaimer  IN   VARCHAR2,
    p_object_version_number   IN      NUMBER,
    x_return_status           OUT NOCOPY     VARCHAR2                        ,
    x_msg_count               OUT NOCOPY     NUMBER                          ,
    x_msg_data                OUT NOCOPY     VARCHAR2                       );

END CN_SYSTEM_PARAMETERS_PVT;

 

/
