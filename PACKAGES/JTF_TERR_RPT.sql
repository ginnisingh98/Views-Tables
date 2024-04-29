--------------------------------------------------------
--  DDL for Package JTF_TERR_RPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERR_RPT" AUTHID CURRENT_USER AS
/* $Header: jtftrtrs.pls 115.2 2002/12/18 02:55:05 jdochert ship $ */
--    Start of Comments
--    PURPOSE
--      Custom Assignment API
--
--    NOTES
--      ORACLE INTERNAL USE ONLY: NOT for customer use
--
--    HISTORY
--      03/18/02    SGKUMAR  Created
--      03/20/02    SGKUMAR  Created procedure insert_qualifiers
--      03/20/02    SGKUMAR  Created procedure set_winners
--    End of Comments
----

PROCEDURE cleanup;
PROCEDURE get_results(p_session_id IN NUMBER,
                      p_resource_id IN NUMBER,
                      p_group_id IN NUMBER,
                      p_active_date IN VARCHAR2);

PROCEDURE get_keyword_parties(p_session_id IN NUMBER,
                      p_terr_id IN NUMBER);

end JTF_TERR_RPT;

 

/
