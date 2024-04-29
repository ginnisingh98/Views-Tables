--------------------------------------------------------
--  DDL for Package IBU_EBLAST_PREF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBU_EBLAST_PREF_PKG" AUTHID CURRENT_USER AS
/* $Header: ibueblas.pls 115.3 2002/12/03 22:04:06 mkcyee noship $ */
         procedure create_preference(p_party_id   in  NUMBER,
                                     p_preference_code   in  VARCHAR2,

                                     x_contact_preference_id     OUT NOCOPY NUMBER,
                                     x_return_status             OUT NOCOPY VARCHAR2,
                                     x_msg_count                 OUT NOCOPY NUMBER,
                                     x_msg_data                  OUT NOCOPY VARCHAR2
                                     );
         procedure update_preference(p_contact_preference_id     IN  NUMBER,
                                     p_preference_code           IN  VARCHAR2,
                                     p_object_version_number     IN OUT NOCOPY NUMBER,

                                     x_return_status             OUT NOCOPY VARCHAR2,
                                     x_msg_count                 OUT NOCOPY NUMBER,
                                     x_msg_data                  OUT NOCOPY VARCHAR2
                                     );
end ibu_eblast_pref_pkg;

 

/
