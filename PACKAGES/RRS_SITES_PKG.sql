--------------------------------------------------------
--  DDL for Package RRS_SITES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RRS_SITES_PKG" AUTHID CURRENT_USER AS
/* $Header: RRSSTPKS.pls 120.2 2005/11/21 05:39:09 pfarkade noship $ */

PROCEDURE CREATE_PROPERTY_LOCATIONS
     (errbuf          OUT NOCOPY VARCHAR2
     ,retcode         OUT NOCOPY VARCHAR2
     ,p_batch_name    IN  VARCHAR2
     ,p_org_id        IN  NUMBER
     	) ;

PROCEDURE CREATE_PROPERTY_LOCATIONS_WRP
     (p_batch_name        IN  VARCHAR2
     ,p_org_id            IN  NUMBER
     ,x_request_id        OUT NOCOPY NUMBER
     ,x_return_status     OUT NOCOPY VARCHAR2
     ,x_msg_count         OUT NOCOPY NUMBER
     ,x_msg_data          OUT NOCOPY VARCHAR2
     ) ;

PROCEDURE CREATE_PROPERTY_LOCATIONS_CONC
     (p_batch_name        IN  VARCHAR2
     ,p_org_id            IN  NUMBER
     ,x_request_id        OUT NOCOPY NUMBER
     ,x_return_status     OUT NOCOPY VARCHAR2
     ,x_msg_count         OUT NOCOPY NUMBER
     ,x_msg_data          OUT NOCOPY VARCHAR2
     ) ;

PROCEDURE DELETE_TEMPLATE
     (
      p_site_id IN NUMBER
     );

--Bug 4742710
PROCEDURE GET_COUNTRYCODE
     (
       p_location_id        IN   NUMBER
      ,x_country_code  OUT  NOCOPY  VARCHAR2
      ,x_country_name  OUT  NOCOPY  VARCHAR2
     );

END RRS_SITES_PKG;


/
