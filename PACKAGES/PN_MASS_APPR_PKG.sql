--------------------------------------------------------
--  DDL for Package PN_MASS_APPR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_MASS_APPR_PKG" AUTHID CURRENT_USER AS
  -- $Header: PNMASAPS.pls 120.0 2005/05/29 12:21:56 appldev noship $

PROCEDURE approve( errbuf                 OUT NOCOPY  VARCHAR2
                  ,retcode                OUT NOCOPY  VARCHAR2
                  ,p_schedule_from_date   IN  DATE
                  ,p_schedule_to_date     IN  DATE
                  ,p_trx_from_date        IN  DATE
                  ,p_trx_to_date          IN  DATE
                  ,p_lease_class_code     IN  VARCHAR2
                  ,p_set_of_books         IN  VARCHAR2
                  ,p_payment_period       IN  VARCHAR2
                  ,p_billing_period       IN  VARCHAR2
                  ,p_lease_from_number    IN  VARCHAR2
                  ,p_lease_to_number      IN  VARCHAR2
                  ,p_location_from_code   IN  VARCHAR2
                  ,p_location_to_code     IN  VARCHAR2
                  ,p_responsible_user     IN  NUMBER);

PROCEDURE unapprove( errbuf                 OUT NOCOPY  VARCHAR2
                    ,retcode                OUT NOCOPY  VARCHAR2
                    ,p_schedule_from_date   IN  DATE
                    ,p_schedule_to_date     IN  DATE
                    ,p_trx_from_date        IN  DATE
                    ,p_trx_to_date          IN  DATE
                    ,p_lease_class_code     IN  VARCHAR2
                    ,p_set_of_books         IN  VARCHAR2
                    ,p_lease_from_number    IN  VARCHAR2
                    ,p_lease_to_number      IN  VARCHAR2
                    ,p_location_from_code   IN  VARCHAR2
                    ,p_location_to_code     IN  VARCHAR2
                    ,p_responsible_user     IN  NUMBER);

PROCEDURE pn_mass_app( errbuf                 OUT NOCOPY  VARCHAR2
                      ,retcode                OUT NOCOPY  VARCHAR2
                      ,p_action_type          IN  VARCHAR2
                      ,p_schedule_from_date   IN  VARCHAR2
                      ,p_schedule_to_date     IN  VARCHAR2
                      ,p_trx_from_date        IN  VARCHAR2
                      ,p_trx_to_date          IN  VARCHAR2
                      ,p_lease_class_code     IN  VARCHAR2
                      ,p_set_of_books         IN  VARCHAR2
                      ,p_payment_period_dummy IN  VARCHAR2
                      ,p_billing_period_dummy IN  VARCHAR2
                      ,p_payment_period       IN  VARCHAR2
                      ,p_billing_period       IN  VARCHAR2
                      ,p_lease_from_number    IN  VARCHAR2
                      ,p_lease_to_number      IN  VARCHAR2
                      ,p_location_from_code   IN  VARCHAR2
                      ,p_location_to_code     IN  VARCHAR2
                      ,p_responsible_user     IN  NUMBER);

END pn_mass_appr_pkg;

 

/
