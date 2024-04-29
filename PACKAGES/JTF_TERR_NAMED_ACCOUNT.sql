--------------------------------------------------------
--  DDL for Package JTF_TERR_NAMED_ACCOUNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERR_NAMED_ACCOUNT" AUTHID CURRENT_USER AS
/* $Header: jtftnams.pls 120.0 2005/06/02 18:21:21 appldev ship $ */
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

PROCEDURE insert_customer_qual(p_account_id IN NUMBER);
PROCEDURE delete_qual(p_acct_qual_map_id IN NUMBER);
PROCEDURE update_mapping(p_account_id IN VARCHAR2,
                         p_flag in VARCHAR2);
PROCEDURE save_qual(p_acct_id IN NUMBER,
                    p_acct_qual_map_id IN NUMBER,
                    p_qual_usg_id IN NUMBER,
                    p_operator in VARCHAR2,
                    p_value1_char IN VARCHAR2,
                    p_value2_char IN VARCHAR2,
                    p_value1_num IN NUMBER,
                    p_value2_num IN NUMBER,
                    p_user_id in NUMBER
);
PROCEDURE get_customer_qual_count(p_account_id IN NUMBER, p_qual_count OUT NOCOPY NUMBER);
PROCEDURE get_postal_qual_count(p_account_id IN NUMBER, p_qual_count OUT NOCOPY NUMBER);
end JTF_TERR_NAMED_ACCOUNT;

 

/
