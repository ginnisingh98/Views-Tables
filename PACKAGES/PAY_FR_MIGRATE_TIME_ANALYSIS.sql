--------------------------------------------------------
--  DDL for Package PAY_FR_MIGRATE_TIME_ANALYSIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FR_MIGRATE_TIME_ANALYSIS" AUTHID CURRENT_USER as
/* $Header: pyfrmgta.pkh 120.0 2005/05/29 05:04:20 appldev noship $ */
--
procedure Migrate(errbuf              OUT NOCOPY VARCHAR2,
                  retcode             OUT NOCOPY NUMBER,
                  p_business_group_id IN NUMBER);
---

End PAY_FR_MIGRATE_TIME_ANALYSIS;

 

/
