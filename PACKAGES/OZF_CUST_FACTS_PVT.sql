--------------------------------------------------------
--  DDL for Package OZF_CUST_FACTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_CUST_FACTS_PVT" AUTHID CURRENT_USER AS
/*$Header: ozfvcfts.pls 120.0 2005/06/01 02:40:42 appldev noship $*/
 G_PKG_NAME CONSTANT VARCHAR2(30) := 'OZF_REFRESH_DASHB_FACTS_PKG';

 PROCEDURE load_daily_facts( ERRBUF                  OUT  NOCOPY VARCHAR2,
                             RETCODE                 OUT  NOCOPY NUMBER,
                             p_report_date           IN   VARCHAR2 ) ;

 FUNCTION get_xtd_total( p_period_type_id        IN   NUMBER,
                         p_time_id               IN   NUMBER,
                         p_start_date            IN   DATE,
                         p_end_date              IN   DATE,
                         p_type                  IN   VARCHAR2) RETURN NUMBER;
 PRAGMA   RESTRICT_REFERENCES(get_xtd_total,WNDS,WNPS,RNPS);

 FUNCTION get_xtd_total( p_resource_id           IN   NUMBER,
                         p_period_type_id        IN   NUMBER,
                         p_time_id               IN   NUMBER,
                         p_type                  IN   VARCHAR2 ) RETURN NUMBER;
 PRAGMA   RESTRICT_REFERENCES(get_xtd_total,WNDS,WNPS,RNPS);

 FUNCTION get_cust_target ( p_site_use_id IN NUMBER,
                           p_bill_to_site_use_id IN NUMBER,
                           p_period_type_id IN NUMBER ,
                           p_time_id IN NUMBER,
                           p_report_date IN DATE ) RETURN NUMBER ;
 PRAGMA   RESTRICT_REFERENCES(get_cust_target,WNDS,WNPS,RNPS);


 FUNCTION get_cust_target ( p_party_id            IN NUMBER,
                            p_bill_to_site_use_id IN NUMBER,
                            p_site_use_id         IN NUMBER,
                            p_col                 IN VARCHAR2,
                            p_sales               IN NUMBER,
                            p_report_date         IN DATE,
                            p_resource_id         IN NUMBER) RETURN NUMBER ;
 PRAGMA   RESTRICT_REFERENCES(get_cust_target,WNDS,WNPS,RNPS);


END ozf_cust_facts_pvt;

 

/
