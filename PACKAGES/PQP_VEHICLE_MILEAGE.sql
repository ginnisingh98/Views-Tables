--------------------------------------------------------
--  DDL for Package PQP_VEHICLE_MILEAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_VEHICLE_MILEAGE" AUTHID CURRENT_USER AS
/* $Header: pqbladwr.pkh 115.0 2003/05/30 07:15:04 jcpereir noship $*/

PROCEDURE INITIALIZE_BALANCES(errbuf OUT NOCOPY VARCHAR2
                     ,retcode OUT NOCOPY NUMBER
                     ,p_business_group_id IN NUMBER
                     );

END;

 

/
