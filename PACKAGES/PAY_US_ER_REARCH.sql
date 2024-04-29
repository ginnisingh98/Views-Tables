--------------------------------------------------------
--  DDL for Package PAY_US_ER_REARCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_ER_REARCH" AUTHID CURRENT_USER as
/* $Header: pyuserre.pkh 120.1.12000000.1 2007/01/18 02:24:50 appldev noship $*/


PROCEDURE insert_er_rearch_data(errbuf          OUT nocopy    VARCHAR2,
                                retcode         OUT nocopy    NUMBER,
                                p_year          IN      VARCHAR2,
                                p_tax_unit_id   IN      NUMBER,
                                p_fed_state     IN      VARCHAR2,
                                p_is_state      IN      VARCHAR2,
                                p_state_code    IN      VARCHAR2 default null) ;


PROCEDURE print_er_rearch_data(p_user_entity_id   IN NUMBER,
                               p_federal_state    IN VARCHAR2,
                               p_old_value        IN VARCHAR2,
                               p_new_value        IN VARCHAR2);


end pay_us_er_rearch;

 

/
