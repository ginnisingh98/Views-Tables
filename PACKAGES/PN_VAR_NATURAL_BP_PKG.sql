--------------------------------------------------------
--  DDL for Package PN_VAR_NATURAL_BP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_VAR_NATURAL_BP_PKG" AUTHID CURRENT_USER AS
-- $Header: PNVRNBPS.pls 120.0 2007/10/03 14:29:35 rthumma noship $

  TYPE var_lease_rec IS RECORD (var_rent_id NUMBER,
                                lease_id NUMBER,
                                var_rent_num VARCHAR2(30));

  TYPE bkpt_rec IS RECORD (start_date DATE,
                           end_date DATE,
                           amount NUMBER,
                           bkpt_rate NUMBER);

  TYPE date_table_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
  TYPE number_table_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE var_lease_type IS TABLE OF var_lease_rec INDEX BY BINARY_INTEGER;
  TYPE bkpt_rec_type IS TABLE OF bkpt_rec INDEX BY BINARY_INTEGER;

  PROCEDURE build_bkpt_details_main(errbuf              OUT NOCOPY VARCHAR2,
                                    retcode             OUT NOCOPY VARCHAR2,
                                    p_var_rent_id       IN  NUMBER);

  PROCEDURE build_bkpt_details(errbuf           OUT NOCOPY VARCHAR2,
                               retcode          OUT NOCOPY VARCHAR2,
                               p_lease_id       IN  NUMBER,
                               p_var_rent_id    IN  NUMBER,
                               p_head_dflt_id   IN  NUMBER,
                               p_header_id      IN  NUMBER,
                               p_bkpt_rec       IN  OUT NOCOPY bkpt_rec_type
                               );



  PROCEDURE PN_VAR_NAT_TO_ARTIFICIAL(errbuf        OUT NOCOPY VARCHAR2
                                    ,retcode       OUT NOCOPY VARCHAR2
                                    ,p_mode        IN VARCHAR2
                                    ,p_prop_id     IN NUMBER DEFAULT NULL
                                    ,p_loc_id      IN NUMBER DEFAULT NULL
                                    ,p_lease_id    IN NUMBER DEFAULT NULL
                                    ,p_var_rent_id IN NUMBER DEFAULT NULL);


END pn_var_natural_bp_pkg;

/
