--------------------------------------------------------
--  DDL for Package POS_SECURITY_PROFILE_UTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_SECURITY_PROFILE_UTL_PKG" AUTHID CURRENT_USER AS
/*$Header: POSSPUTS.pls 120.2 2006/01/10 12:52:28 bitang noship $ */

TYPE number_table IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

PROCEDURE get_current_ous
  (x_ou_ids OUT nocopy number_table,
   x_count  OUT nocopy NUMBER
   );

END pos_security_profile_utl_pkg;

 

/
