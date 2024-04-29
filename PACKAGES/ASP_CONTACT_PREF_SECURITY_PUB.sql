--------------------------------------------------------
--  DDL for Package ASP_CONTACT_PREF_SECURITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASP_CONTACT_PREF_SECURITY_PUB" AUTHID CURRENT_USER AS
/* $Header: aspctpss.pls 120.0 2005/05/30 22:02:03 appldev noship $ */

  PROCEDURE  DELETE_NO_ACCESS_CONTACTS
     (ERRBUF       OUT NOCOPY VARCHAR2,
      RETCODE      OUT NOCOPY VARCHAR2,
      P_DEBUG      IN  VARCHAR2
     );


END ASP_CONTACT_PREF_SECURITY_PUB;

 

/
