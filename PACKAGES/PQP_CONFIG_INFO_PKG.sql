--------------------------------------------------------
--  DDL for Package PQP_CONFIG_INFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_CONFIG_INFO_PKG" AUTHID CURRENT_USER AS
/* $Header: pqcfigcp.pkh 115.1 2003/03/06 23:40:57 sshetty noship $ */

FUNCTION get_user_table_name ( p_table_id          IN NUMBER
                         ,p_business_group_id IN NUMBER
                         )
RETURN VARCHAR2;

FUNCTION get_element_name ( p_element_id          IN NUMBER
                           ,p_business_group_id   IN NUMBER
                         )
RETURN VARCHAR2;

PROCEDURE pqp_veh_calc_info
        ( errbuf                       OUT NOCOPY VARCHAR2,
          retcode                      OUT NOCOPY NUMBER,
          p_effective_date             IN DATE    default trunc(sysdate),
          p_business_group_id          IN NUMBER,
          p_legislation_code           IN VARCHAR2 default null,
          p_ownership                  IN VARCHAR2,
          p_usage_type                 IN VARCHAR2 default null ,
          p_vehicle_type               IN VARCHAR2 default null,
          p_fuel_type                  IN VARCHAR2 default null,
          p_user_rates_table           IN VARCHAR2 default null,
          p_element_entry_id           IN VARCHAR2 default null,
          p_mode                       IN VARCHAR2
 );



END;

 

/
