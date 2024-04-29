--------------------------------------------------------
--  DDL for Package Body JTF_TERR_NAMED_ACCOUNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_NAMED_ACCOUNT" AS
/* $Header: jtftnamb.pls 120.1 2005/06/24 00:25:30 jradhakr ship $ */
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
--      04/03/03    SGKUMAR  Modified save_quals not to use count(*)
--                           2870648 performance bug fix
--    End of Comments
----
PROCEDURE delete_qual(p_acct_qual_map_id IN NUMBER) AS
BEGIN
 delete from jtf_tty_acct_qual_maps
 where ACCOUNT_QUAL_MAP_ID = p_acct_qual_map_id;
 commit;
END delete_qual;

PROCEDURE insert_customer_qual(p_account_id IN NUMBER)
AS
BEGIN
insert into jtf_tty_acct_qual_maps
(ACCOUNT_QUAL_MAP_ID,
 OBJECT_VERSION_NUMBER ,
NAMED_ACCOUNT_ID       ,
 QUAL_USG_ID  ,
 COMPARISON_OPERATOR ,
 VALUE1_CHAR ,
 VALUE1_NUM
, VALUE2_NUM
, CREATED_BY ,
 CREATION_DATE ,
LAST_UPDATED_BY ,
LAST_UPDATE_DATE ,
LAST_UPDATE_LOGIN
)
VALUES(2015,
       2,
       p_account_id,
       -1012,
       '=',
       'Betu',
       1,
       94403,
       94400,
       sysdate,
       1,
       sysdate,
       1
);
commit;

END insert_customer_qual;

PROCEDURE get_postal_qual_count(p_account_id IN NUMBER,
                          p_qual_count OUT NOCOPY NUMBER) AS
qual_count NUMBER;
BEGIN
  select count(*) into qual_count
  from   JTF_TTY_ACCT_QUAL_MAPS
  where   NAMED_ACCOUNT_ID = p_account_id
  and QUAL_USG_ID = -1007;

  p_qual_count := qual_count;
END get_postal_qual_count;

PROCEDURE get_customer_qual_count(p_account_id IN NUMBER,
                          p_qual_count OUT NOCOPY NUMBER) AS
qual_count NUMBER;
BEGIN
  select count(*) into qual_count
  from   JTF_TTY_ACCT_QUAL_MAPS
  where   NAMED_ACCOUNT_ID = p_account_id
  and QUAL_USG_ID = -1012;

  p_qual_count := qual_count;
END get_customer_qual_count;
PROCEDURE save_qual(p_acct_id IN NUMBER,
                    p_acct_qual_map_id IN NUMBER,
                    p_qual_usg_id IN NUMBER,
                    p_operator in VARCHAR2,
                    p_value1_char IN VARCHAR2,
                    p_value2_char IN VARCHAR2,
                    p_value1_num IN NUMBER,
                    p_value2_num IN NUMBER,
                    p_user_id in NUMBER
)
AS
 qual_count number;
BEGIN
 BEGIN
  select 1
  into qual_count
  from jtf_tty_acct_qual_maps
  where ACCOUNT_QUAL_MAP_ID = p_acct_qual_map_id
  and   rownum < 2;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
    qual_count := 0;
 END;
-- if a new entry, insert
if (qual_count = 0) then
 insert into jtf_tty_acct_qual_maps
(ACCOUNT_QUAL_MAP_ID,
 OBJECT_VERSION_NUMBER ,
 NAMED_ACCOUNT_ID       ,
 QUAL_USG_ID  ,
 COMPARISON_OPERATOR ,
 VALUE1_CHAR ,
 VALUE2_CHAR ,
 VALUE1_NUM
, VALUE2_NUM
, CREATED_BY ,
 CREATION_DATE ,
LAST_UPDATED_BY ,
LAST_UPDATE_DATE
)
VALUES(p_acct_qual_map_id,
       999,
       p_acct_id,
       p_qual_usg_id,
       p_operator,
       upper(p_value1_char),
       upper(p_value2_char),
       p_value1_num,
       p_value2_num,
       p_user_id,
       sysdate,
       p_user_id,
       sysdate
);
 else
 update jtf_tty_acct_qual_maps
 set    OBJECT_VERSION_NUMBER = 999,
        COMPARISON_OPERATOR   = p_operator,
        VALUE1_CHAR = upper(p_value1_char),
        VALUE2_CHAR = upper(p_value2_char),
        VALUE1_NUM = p_value1_num,
        VALUE2_NUM = p_value2_num,
        LAST_UPDATED_BY = p_user_id,
        LAST_UPDATE_DATE = sysdate
 where ACCOUNT_QUAL_MAP_ID = p_acct_qual_map_id;
 end if;
commit;
end save_qual;
PROCEDURE update_mapping(p_account_id IN VARCHAR2,
                         p_flag in VARCHAR2)
AS
BEGIN
 update jtf_tty_named_accts
 set MAPPING_COMPLETE_FLAG = p_flag
 where NAMED_ACCOUNT_ID = p_account_id;
 update jtf_tty_terr_grp_accts
 set DN_JNA_MAPPING_COMPLETE_FLAG = p_flag
 where NAMED_ACCOUNT_ID = p_account_id;
 commit;
END update_mapping;
end JTF_TERR_NAMED_ACCOUNT;

/
