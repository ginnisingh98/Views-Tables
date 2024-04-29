--------------------------------------------------------
--  DDL for Package PN_MODIFY_PMT_SCHED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_MODIFY_PMT_SCHED" AUTHID CURRENT_USER AS
  -- $Header: PNMPMTSS.pls 120.0 2005/05/29 12:04:30 appldev noship $

--
--
procedure modify_sched_and_items (
                                   error_buf      OUT NOCOPY VARCHAR2,
                                   ret_code       OUT NOCOPY VARCHAR2,
                                   pn_lease_id    IN  NUMBER,
                                   pn_user_id     IN  NUMBER
                                 );

END PN_MODIFY_PMT_SCHED;

 

/
