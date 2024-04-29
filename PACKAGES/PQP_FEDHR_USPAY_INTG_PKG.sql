--------------------------------------------------------
--  DDL for Package PQP_FEDHR_USPAY_INTG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_FEDHR_USPAY_INTG_PKG" 
/* $Header: pqpfhrel.pkh 115.20 2003/07/02 03:15:32 ashgupta noship $ */
AUTHID CURRENT_USER AS
-- ---------------------------------------------------------------------------
--  |--------------------< pqp_fedhr_element_creation >----------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--  Checks for
--     1) GHR,PAY Product Installations.Proceeds if Installed.
--     2) If already script is run,if yes stops exec.
--     3) If for the Element Prefix passed, any Element Link exists stops exec.
--     4) After all checks the Script creates the Federal Payroll Elements.
--
-- Access Status:
--   Internal Use Only.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE pqp_fedhr_element_creation
(
    errbuf              OUT NOCOPY VARCHAR2 ,
    retcode             OUT NOCOPY NUMBER   ,
    p_business_group_id            NUMBER   ,
    p_effective_date               VARCHAR2 ,
    p_prefix                       VARCHAR2
);
-- **************************************************************************
-- ---------------------------------------------------------------------------
--  |-----------------< update_or_ins_config_vals >----------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--  Checks for the existence of Old Element name under PQP_CONFIGURATION_VALUES
--     1) If exists then UPDATE the entry in pqp_configuration_values for
--        element_type_id with the new element element_type_id
--        ELSE
--     2) INSERT a row into pqp_configuration_values table.
--
-- Access Status:
--   Internal Use Only.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE update_or_ins_pqp_config_vals
(
     errbuf                OUT NOCOPY VARCHAR2 ,
     retcode               OUT NOCOPY NUMBER   ,
     p_business_group_id              NUMBER   ,
     p_old_ele_name                   VARCHAR2 ,
     p_new_ele_name                   VARCHAR2 ,
     p_is_pb_enabled                  VARCHAR2 ,
     p_pay_basis                      VARCHAR2
);

END pqp_fedhr_uspay_intg_pkg;

 

/
