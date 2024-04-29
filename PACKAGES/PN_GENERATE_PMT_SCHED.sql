--------------------------------------------------------
--  DDL for Package PN_GENERATE_PMT_SCHED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_GENERATE_PMT_SCHED" AUTHID CURRENT_USER AS
  -- $Header: PNCPMTSS.pls 120.0 2005/05/29 12:07:10 appldev noship $

--
--
procedure create_sched_and_items (
                                   error_buf      OUT NOCOPY VARCHAR2,
                                   ret_code       OUT NOCOPY VARCHAR2,
                                   pn_lease_id    IN  NUMBER,
                                   normalize_only IN  VARCHAR2,
                                   pn_user_id     IN  NUMBER
                                 );

END PN_GENERATE_PMT_SCHED;

 

/
