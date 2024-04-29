--------------------------------------------------------
--  DDL for Package CSM_PARTY_ASSIGNMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_PARTY_ASSIGNMENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmptags.pls 120.0 2008/01/11 23:47:32 trajasek noship $ */


PROCEDURE INSERT_PARTY_ASSG (p_user_id        IN NUMBER,
                             p_party_id       IN NUMBER,
                             p_owner_id       IN NUMBER,
                             p_party_site_id  IN NUMBER DEFAULT NULL,
			     x_return_status OUT NOCOPY VARCHAR2,
                             x_error_message OUT NOCOPY VARCHAR2
                            );

PROCEDURE DELETE_PARTY_ASSG (p_user_id        IN NUMBER,
                             p_party_id       IN NUMBER,
                             p_owner_id       IN NUMBER,
                             p_party_site_id  IN NUMBER DEFAULT NULL,
			     x_return_status OUT NOCOPY VARCHAR2,
                             x_error_message OUT NOCOPY VARCHAR2
                            );


END CSM_PARTY_ASSIGNMENT_PKG;


/
