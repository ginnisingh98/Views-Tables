--------------------------------------------------------
--  DDL for Package PAY_AE_IV_MIGRATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AE_IV_MIGRATE_PKG" AUTHID CURRENT_USER AS
/* $Header: payaeivmigr.pkh 120.0.12000000.1 2007/02/16 08:44:03 abppradh noship $ */

  PROCEDURE update_iv_si_element
    (errbuf                      OUT NOCOPY VARCHAR2
    ,retcode                    OUT NOCOPY VARCHAR2
    ,p_business_group_id IN NUMBER);

    ---------
    FUNCTION get_lookup_meaning
          (p_lookup_type varchar2
          ,p_lookup_code varchar2)
      RETURN VARCHAR2;

END pay_ae_iv_migrate_pkg;


 

/
