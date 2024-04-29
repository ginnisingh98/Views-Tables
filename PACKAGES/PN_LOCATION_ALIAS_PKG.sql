--------------------------------------------------------
--  DDL for Package PN_LOCATION_ALIAS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_LOCATION_ALIAS_PKG" AUTHID CURRENT_USER AS
/* $Header: PNLCALSS.pls 115.1 2003/06/19 19:48:39 ftanudja noship $ */

PROCEDURE change_alias(
            errbuf           OUT NOCOPY VARCHAR2,
            retcode          OUT NOCOPY VARCHAR2,
            p_location_type  IN pn_locations.location_type_lookup_code%TYPE,
            p_location_code  IN pn_locations.location_code%TYPE,
            p_new_alias      IN pn_locations.location_alias%TYPE);

END pn_location_alias_pkg;

 

/
