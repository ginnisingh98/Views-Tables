--------------------------------------------------------
--  DDL for Package PN_LEASE_DETAILS_SEND_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_LEASE_DETAILS_SEND_UPD" AUTHID CURRENT_USER AS
  -- $Header: PNUPLEDS.pls 115.1 2002/11/12 23:13:36 stripath noship $

PROCEDURE update_lease_se(
  errbuf            OUT NOCOPY     VARCHAR2,
  retcode           OUT NOCOPY     VARCHAR2,
  p_lease_class     IN      VARCHAR2,
  p_lease_num_from  IN      VARCHAR2,
  p_lease_num_to    IN      VARCHAR2);

END PN_LEASE_DETAILS_SEND_UPD;

 

/
