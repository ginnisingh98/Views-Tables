--------------------------------------------------------
--  DDL for Package ARP_PROCESS_SALESCREDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_SALESCREDIT" AUTHID CURRENT_USER AS
/* $Header: ARTETLSS.pls 115.3 2003/08/12 01:00:07 kmahajan ship $ */


PROCEDURE insert_salescredit(
           p_form_name                IN varchar2,
           p_form_version             IN number,
           p_run_auto_accounting_flag IN boolean,
           p_srep_rec		      IN ra_cust_trx_line_salesreps%rowtype,
           p_cust_trx_line_salesrep_id  OUT NOCOPY
               ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type,
           p_status                     OUT NOCOPY varchar2);

PROCEDURE create_line_salescredits(p_customer_trx_id IN
                              ra_customer_trx_lines.customer_trx_id%type,
                                   p_customer_trx_line_id IN
                              ra_customer_trx_lines.customer_trx_line_id%type,
                                   p_memo_line_type       IN
                                                 ar_memo_lines.line_type%type,
                                   p_delete_scredits_first_flag IN
                                          varchar2,
                                   p_run_autoaccounting_flag IN varchar2,
                                   p_status                  OUT NOCOPY varchar2);

PROCEDURE update_salescredit(
           p_form_name                   IN varchar2,
           p_form_version                IN number,
           p_run_auto_accounting_flag    IN boolean,
           p_backout_flag                IN boolean,
           p_cust_trx_line_salesrep_id   IN
                     ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type,
           p_customer_trx_id		 IN
                     ra_customer_trx.customer_trx_id%type,
           p_customer_trx_line_id	 IN
                     ra_customer_trx_lines.customer_trx_line_id%type,
           p_srep_rec		        IN ra_cust_trx_line_salesreps%rowtype,
           p_backout_done_flag          OUT NOCOPY boolean,
           p_status                     OUT NOCOPY varchar2 );

PROCEDURE delete_salescredit(
           p_form_name                   IN varchar2,
           p_form_version                IN number,
           p_run_auto_accounting_flag    IN boolean,
           p_cust_trx_line_salesrep_id   IN
                     ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type,
           p_customer_trx_id		 IN
                     ra_customer_trx.customer_trx_id%type,
           p_customer_trx_line_id	 IN
                     ra_customer_trx_lines.customer_trx_line_id%type,
           p_srep_rec		         IN ra_cust_trx_line_salesreps%rowtype,
           p_backout_flag                IN boolean DEFAULT FALSE,
           p_backout_done_flag          OUT NOCOPY boolean,
           p_status                     OUT NOCOPY varchar2 );

PROCEDURE insert_salescredit_cover(
           p_form_name                       IN varchar2,
           p_form_version                    IN number,
           p_run_auto_accounting_flag        IN boolean,

           p_customer_trx_id                 IN
                         ra_cust_trx_line_salesreps.customer_trx_id%type,
           p_customer_trx_line_id            IN
                         ra_cust_trx_line_salesreps.customer_trx_line_id%type,
           p_salesrep_id                     IN
                         ra_cust_trx_line_salesreps.salesrep_id%type,
           p_revenue_amount_split            IN
                         ra_cust_trx_line_salesreps.revenue_amount_split%type,
           p_non_revenue_amount_split        IN
                     ra_cust_trx_line_salesreps.non_revenue_amount_split%type,
           p_non_revenue_percent_split       IN
                    ra_cust_trx_line_salesreps.non_revenue_percent_split%type,
           p_revenue_percent_split           IN
                    ra_cust_trx_line_salesreps.revenue_percent_split%type,
           p_prev_cust_trx_line_srep_id      IN
               ra_cust_trx_line_salesreps.prev_cust_trx_line_salesrep_id%type,
           p_attribute_category              IN
                    ra_cust_trx_line_salesreps.attribute_category%type,
           p_attribute1                      IN
                    ra_cust_trx_line_salesreps.attribute1%type,
           p_attribute2                      IN
                    ra_cust_trx_line_salesreps.attribute2%type,
           p_attribute3                      IN
                    ra_cust_trx_line_salesreps.attribute3%type,
           p_attribute4                      IN
                    ra_cust_trx_line_salesreps.attribute4%type,
           p_attribute5                      IN
                    ra_cust_trx_line_salesreps.attribute5%type,
           p_attribute6                      IN
                    ra_cust_trx_line_salesreps.attribute6%type,
           p_attribute7                      IN
                    ra_cust_trx_line_salesreps.attribute7%type,
           p_attribute8                      IN
                    ra_cust_trx_line_salesreps.attribute8%type,
           p_attribute9                      IN
                    ra_cust_trx_line_salesreps.attribute9%type,
           p_attribute10                     IN
                    ra_cust_trx_line_salesreps.attribute10%type,
           p_attribute11                     IN
                    ra_cust_trx_line_salesreps.attribute11%type,
           p_attribute12                     IN
                    ra_cust_trx_line_salesreps.attribute12%type,
           p_attribute13                     IN
                    ra_cust_trx_line_salesreps.attribute13%type,
           p_attribute14                     IN
                    ra_cust_trx_line_salesreps.attribute14%type,
           p_attribute15                     IN
                    ra_cust_trx_line_salesreps.attribute15%type,
           p_cust_trx_line_salesrep_id  OUT NOCOPY
               ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type,
           p_status                     OUT NOCOPY varchar2,
           p_revenue_salesgroup_id           IN
                         ra_cust_trx_line_salesreps.revenue_salesgroup_id%type DEFAULT null,
           p_non_revenue_salesgroup_id       IN
                         ra_cust_trx_line_salesreps.non_revenue_salesgroup_id%type DEFAULT null);

PROCEDURE update_salescredit_cover(
           p_form_name                       IN varchar2,
           p_form_version                    IN number,
           p_run_auto_accounting_flag        IN boolean,
           p_backout_flag                    IN boolean,
           p_cust_trx_line_salesrep_id   IN
                     ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type,
           p_customer_trx_id                 IN
                         ra_cust_trx_line_salesreps.customer_trx_id%type,
           p_customer_trx_line_id            IN
                         ra_cust_trx_line_salesreps.customer_trx_line_id%type,
           p_salesrep_id                     IN
                         ra_cust_trx_line_salesreps.salesrep_id%type,
           p_revenue_amount_split            IN
                         ra_cust_trx_line_salesreps.revenue_amount_split%type,
           p_non_revenue_amount_split        IN
                     ra_cust_trx_line_salesreps.non_revenue_amount_split%type,
           p_non_revenue_percent_split       IN
                    ra_cust_trx_line_salesreps.non_revenue_percent_split%type,
           p_revenue_percent_split           IN
                    ra_cust_trx_line_salesreps.revenue_percent_split%type,
           p_prev_cust_trx_line_srep_id      IN
               ra_cust_trx_line_salesreps.prev_cust_trx_line_salesrep_id%type,
           p_attribute_category              IN
                    ra_cust_trx_line_salesreps.attribute_category%type,
           p_attribute1                      IN
                    ra_cust_trx_line_salesreps.attribute1%type,
           p_attribute2                      IN
                    ra_cust_trx_line_salesreps.attribute2%type,
           p_attribute3                      IN
                    ra_cust_trx_line_salesreps.attribute3%type,
           p_attribute4                      IN
                    ra_cust_trx_line_salesreps.attribute4%type,
           p_attribute5                      IN
                    ra_cust_trx_line_salesreps.attribute5%type,
           p_attribute6                      IN
                    ra_cust_trx_line_salesreps.attribute6%type,
           p_attribute7                      IN
                    ra_cust_trx_line_salesreps.attribute7%type,
           p_attribute8                      IN
                    ra_cust_trx_line_salesreps.attribute8%type,
           p_attribute9                      IN
                    ra_cust_trx_line_salesreps.attribute9%type,
           p_attribute10                     IN
                    ra_cust_trx_line_salesreps.attribute10%type,
           p_attribute11                     IN
                    ra_cust_trx_line_salesreps.attribute11%type,
           p_attribute12                     IN
                    ra_cust_trx_line_salesreps.attribute12%type,
           p_attribute13                     IN
                    ra_cust_trx_line_salesreps.attribute13%type,
           p_attribute14                     IN
                    ra_cust_trx_line_salesreps.attribute14%type,
           p_attribute15                     IN
                    ra_cust_trx_line_salesreps.attribute15%type,
           p_backout_done_flag              OUT NOCOPY boolean,
           p_status                     OUT NOCOPY varchar2,
           p_revenue_salesgroup_id           IN
                         ra_cust_trx_line_salesreps.revenue_salesgroup_id%type DEFAULT null,
           p_non_revenue_salesgroup_id       IN
                         ra_cust_trx_line_salesreps.non_revenue_salesgroup_id%type DEFAULT null);

PROCEDURE delete_salescredit_cover(
           p_form_name                       IN varchar2,
           p_form_version                    IN number,
           p_run_auto_accounting_flag        IN boolean,
           p_backout_flag                    IN boolean,
           p_cust_trx_line_salesrep_id   IN
                     ra_cust_trx_line_salesreps.cust_trx_line_salesrep_id%type,
           p_customer_trx_id                 IN
                         ra_cust_trx_line_salesreps.customer_trx_id%type,
           p_customer_trx_line_id            IN
                         ra_cust_trx_line_salesreps.customer_trx_line_id%type,
           p_salesrep_id                     IN
                         ra_cust_trx_line_salesreps.salesrep_id%type,
           p_revenue_amount_split            IN
                         ra_cust_trx_line_salesreps.revenue_amount_split%type,
           p_non_revenue_amount_split        IN
                     ra_cust_trx_line_salesreps.non_revenue_amount_split%type,
           p_non_revenue_percent_split       IN
                    ra_cust_trx_line_salesreps.non_revenue_percent_split%type,
           p_revenue_percent_split           IN
                    ra_cust_trx_line_salesreps.revenue_percent_split%type,
           p_prev_cust_trx_line_srep_id      IN
               ra_cust_trx_line_salesreps.prev_cust_trx_line_salesrep_id%type,
           p_attribute_category              IN
                    ra_cust_trx_line_salesreps.attribute_category%type,
           p_attribute1                      IN
                    ra_cust_trx_line_salesreps.attribute1%type,
           p_attribute2                      IN
                    ra_cust_trx_line_salesreps.attribute2%type,
           p_attribute3                      IN
                    ra_cust_trx_line_salesreps.attribute3%type,
           p_attribute4                      IN
                    ra_cust_trx_line_salesreps.attribute4%type,
           p_attribute5                      IN
                    ra_cust_trx_line_salesreps.attribute5%type,
           p_attribute6                      IN
                    ra_cust_trx_line_salesreps.attribute6%type,
           p_attribute7                      IN
                    ra_cust_trx_line_salesreps.attribute7%type,
           p_attribute8                      IN
                    ra_cust_trx_line_salesreps.attribute8%type,
           p_attribute9                      IN
                    ra_cust_trx_line_salesreps.attribute9%type,
           p_attribute10                     IN
                    ra_cust_trx_line_salesreps.attribute10%type,
           p_attribute11                     IN
                    ra_cust_trx_line_salesreps.attribute11%type,
           p_attribute12                     IN
                    ra_cust_trx_line_salesreps.attribute12%type,
           p_attribute13                     IN
                    ra_cust_trx_line_salesreps.attribute13%type,
           p_attribute14                     IN
                    ra_cust_trx_line_salesreps.attribute14%type,
           p_attribute15                     IN
                    ra_cust_trx_line_salesreps.attribute15%type,
           p_backout_done_flag          OUT NOCOPY boolean,
           p_status                     OUT NOCOPY varchar2,
           p_revenue_salesgroup_id           IN
                         ra_cust_trx_line_salesreps.revenue_salesgroup_id%type DEFAULT null,
           p_non_revenue_salesgroup_id       IN
                         ra_cust_trx_line_salesreps.non_revenue_salesgroup_id%type DEFAULT null);

END ARP_PROCESS_SALESCREDIT;

 

/
