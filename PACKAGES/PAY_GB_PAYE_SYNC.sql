--------------------------------------------------------
--  DDL for Package PAY_GB_PAYE_SYNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_PAYE_SYNC" 
--  /* $Header: pygbpayesync.pkh 120.2.12010000.2 2009/06/04 06:29:41 jvaradra noship $ */
AUTHID CURRENT_USER AS


/* write_util_file : Thie procedure will fetch all the aggregated assignments
                     in the given tax reference which are not sharing the same tax
                     details records */


PROCEDURE write_util_file(errbuf                OUT   NOCOPY VARCHAR2,
                          retcode               OUT   NOCOPY NUMBER,
                           p_tax_ref            IN VARCHAR2,
                           p_business_group_id IN NUMBER,
                           p_eff_date          IN VARCHAR2
                          );

g_number number := 1;

/* read_util_file : Thie procedure will read the output file generated from the write_utl_file procedure
                    and update the tax details against the required assignemnts */

PROCEDURE read_util_file(errbuf OUT NOCOPY VARCHAR2,
                         retcode OUT NOCOPY NUMBER,
                         p_filename IN VARCHAR2,
                         P_RUN_MODE in VARCHAR2
                        );

end pay_gb_paye_sync;

/
