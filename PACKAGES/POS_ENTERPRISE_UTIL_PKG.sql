--------------------------------------------------------
--  DDL for Package POS_ENTERPRISE_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_ENTERPRISE_UTIL_PKG" AUTHID CURRENT_USER AS
--$Header: POSENTRS.pls 120.1 2005/07/21 01:43:47 bitang noship $

PROCEDURE get_enterprise_information
  (x_party_id      OUT NOCOPY NUMBER,
   x_party_name    OUT NOCOPY VARCHAR2,
   x_exception_msg OUT NOCOPY VARCHAR2,
   x_status        OUT NOCOPY VARCHAR2
   );

PROCEDURE get_enterprise_party_name
  ( x_party_name    OUT NOCOPY VARCHAR2,
    x_exception_msg OUT NOCOPY VARCHAR2,
    x_status        OUT NOCOPY VARCHAR2
    );

PROCEDURE get_enterprise_partyid
  (x_party_id      OUT NOCOPY NUMBER,
   x_exception_msg OUT NOCOPY VARCHAR2,
   x_status        OUT NOCOPY VARCHAR2
   );

PROCEDURE create_enterprise_party
  (  x_status        OUT NOCOPY VARCHAR2
   , x_exception_msg OUT NOCOPY VARCHAR2
   );

PROCEDURE pos_create_enterprise_user
  (p_username        IN  VARCHAR2, -- must
   p_firstname       IN  VARCHAR2, -- must
   p_lastname        IN  VARCHAR2, -- must
   p_emailaddress    IN  VARCHAR2 DEFAULT NULL,
   x_party_id        OUT NOCOPY NUMBER, -- party id of the user
   x_relationship_id OUT NOCOPY NUMBER, -- relationship_id of the user with the company
   x_exception_msg   OUT NOCOPY VARCHAR2,
   x_status          OUT NOCOPY VARCHAR2
   );

END pos_enterprise_util_pkg;

 

/
