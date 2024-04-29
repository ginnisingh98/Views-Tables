--------------------------------------------------------
--  DDL for Package ARP_RUN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_RUN" AUTHID CURRENT_USER AS
-- $Header: ARTERRPS.pls 115.11 2003/06/09 13:19:40 mraymond ship $

PROCEDURE revenue_recognition(errbuf           OUT NOCOPY VARCHAR2,
			      retcode          OUT NOCOPY NUMBER,
			      p_worker_number  IN  NUMBER,
			      p_report_mode    IN  VARCHAR2,
			      p_org_id	       IN  NUMBER);

PROCEDURE rev_rec_master      (errbuf           OUT NOCOPY VARCHAR2,
			       retcode          OUT NOCOPY NUMBER,
			       p_report_mode    IN  VARCHAR2 := 'S',
	                       p_max_workers    IN  NUMBER := 2,
			       p_interval       IN  NUMBER := 60,
			       p_max_wait       IN  NUMBER := 180,
			       p_org_id		IN  NUMBER);

PROCEDURE build_credit_distributions(errbuf           OUT NOCOPY VARCHAR2,
      			             retcode          OUT NOCOPY NUMBER,
                                     p_customer_trx_id IN NUMBER,
                                     p_prev_trx_id     IN NUMBER);

PROCEDURE submit_mrc_posting(p_psob_id                IN NUMBER,
                             p_gl_start_date          IN DATE,
                             p_gl_end_date            IN DATE,
                             p_gl_posted_date         IN DATE,
                             p_summary_flag           IN VARCHAR2,
                             p_journal_import         IN VARCHAR2,
                             p_posting_days_per_cycle IN NUMBER,
                             p_posting_control_id     IN NUMBER,
                             p_debug_flag             IN VARCHAR2,
                             p_org_id                 IN NUMBER,
                             retcode                  OUT NOCOPY NUMBER);

END;

 

/
