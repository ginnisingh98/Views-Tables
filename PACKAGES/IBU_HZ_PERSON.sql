--------------------------------------------------------
--  DDL for Package IBU_HZ_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBU_HZ_PERSON" AUTHID CURRENT_USER AS
/* $Header: ibuulngs.pls 115.0 2003/09/16 04:17:56 mukhan noship $ */

PROCEDURE Update_Person_Language(
    p_party_id		 IN    NUMBER,
    p_language_name      IN    VARCHAR2,
    p_created_by_module  IN  VARCHAR2,
    x_debug_buf          OUT NOCOPY  VARCHAR2,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_msg_count          OUT NOCOPY  NUMBER,
    x_msg_data           OUT NOCOPY  VARCHAR2
    );

end IBU_HZ_PERSON ;

 

/
