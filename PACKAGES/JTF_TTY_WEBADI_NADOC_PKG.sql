--------------------------------------------------------
--  DDL for Package JTF_TTY_WEBADI_NADOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TTY_WEBADI_NADOC_PKG" AUTHID CURRENT_USER AS
/* $Header: jtfintfs.pls 120.2 2005/09/06 22:42:47 shli ship $ */
-- ===========================================================================+
-- |               Copyright (c) 1999 Oracle Corporation                       |
-- |                  Redwood Shores, California, USA                          |
-- |                       All rights reserved.                                |
-- +===========================================================================
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TAE_INDEX_CREATION_PVT
--    ---------------------------------------------------
--    PURPOSE
--
--      This package is used to return a list of column in order of selectivity.
--      And create indices on columns in order of  input
--
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      05/02/2002    SHLI        Created
--
--    End of Comments
--
-- *******************************************************
--    Start of Comments
-- *******************************************************

TYPE VARRAY_TYPE IS VARRAY(30) OF VARCHAR(360);
TYPE NARRAY_TYPE IS VARRAY(30) OF NUMBER;
/*
TYPE bulk_NAST_rec IS RECORD (
   user_sequence              jtf_terr_number_list ,
  user_id                    jtf_terr_number_list ,
  terr_grp_acct_id           jtf_terr_number_list ,
  jtf_tty_webadi_int_id      jtf_terr_number_list ,
  named_account              jtf_terr_char_360list,
  site_type                  jtf_terr_char_360list,
  duns                       jtf_terr_char_360list,
  trade_name                 jtf_terr_char_360list,
  gu_duns                    jtf_terr_char_360list,
  gu_name                    jtf_terr_char_360list,
  du_duns                    jtf_terr_char_360list,
  du_name                    jtf_terr_char_360list,
  city                       jtf_terr_char_360list,
  state                      jtf_terr_char_360list,
  province                   jtf_terr_char_360list,
  postal_code                jtf_terr_char_360list,
  territory_group            jtf_terr_char_360list,
  resource1_name             jtf_terr_char_360list,
  resource1_id               jtf_terr_number_list,
  group1_name                jtf_terr_char_360list,
  group1_id                  jtf_terr_number_list,
  role1_name                 jtf_terr_char_360list,
  role1_id                   jtf_terr_number_list,
  resource2_name             jtf_terr_char_360list,
  resource2_id               jtf_terr_number_list,
  group2_name                jtf_terr_char_360list,
  group2_id                  jtf_terr_number_list,
  role2_name                 jtf_terr_char_360list,
  role2_id                   jtf_terr_number_list,
  resource3_name             jtf_terr_char_360list,
  resource3_id               jtf_terr_number_list,
  group3_name                jtf_terr_char_360list,
  group3_id                  jtf_terr_number_list,
  role3_name                 jtf_terr_char_360list,
  role3_id                   jtf_terr_number_list,
  resource4_name             jtf_terr_char_360list,
  resource4_id               jtf_terr_number_list,
  group4_name                jtf_terr_char_360list,
  group4_id                  jtf_terr_number_list,
  role4_name                 jtf_terr_char_360list,
  role4_id                   jtf_terr_number_list,
  resource5_name             jtf_terr_char_360list,
  resource5_id               jtf_terr_number_list,
  group5_name                jtf_terr_char_360list,
  group5_id                  jtf_terr_number_list,
  role5_name                 jtf_terr_char_360list,
  role5_id                   jtf_terr_number_list,
  resource6_name             jtf_terr_char_360list,
  resource6_id               jtf_terr_number_list,
  group6_name                jtf_terr_char_360list,
  group6_id                  jtf_terr_number_list,
  role6_name                 jtf_terr_char_360list,
  role6_id                   jtf_terr_number_list,
  resource7_name             jtf_terr_char_360list,
  resource7_id               jtf_terr_number_list,
  group7_name                jtf_terr_char_360list,
  group7_id                  jtf_terr_number_list,
  role7_name                 jtf_terr_char_360list,
  role7_id                   jtf_terr_number_list,
  resource8_name             jtf_terr_char_360list,
  resource8_id               jtf_terr_number_list,
  group8_name                jtf_terr_char_360list,
  group8_id                  jtf_terr_number_list,
  role8_name                 jtf_terr_char_360list,
  role8_id                   jtf_terr_number_list,
  resource9_name             jtf_terr_char_360list,
  resource9_id               jtf_terr_number_list,
  group9_name                jtf_terr_char_360list,
  group9_id                  jtf_terr_number_list,
  role9_name                 jtf_terr_char_360list,
  role9_id                   jtf_terr_number_list,
  resource10_name            jtf_terr_char_360list,
  resource10_id              jtf_terr_number_list,
  group10_name               jtf_terr_char_360list,
  group10_id                 jtf_terr_number_list,
  role10_name                jtf_terr_char_360list,
  role10_id                  jtf_terr_number_list,
  resource11_name            jtf_terr_char_360list,
  resource11_id              jtf_terr_number_list,
  group11_name               jtf_terr_char_360list,
  group11_id                 jtf_terr_number_list,
  role11_name                jtf_terr_char_360list,
  role11_id                  jtf_terr_number_list,
  resource12_name            jtf_terr_char_360list,
  resource12_id              jtf_terr_number_list,
  group12_name               jtf_terr_char_360list,
  group12_id                 jtf_terr_number_list,
  role12_name                jtf_terr_char_360list,
  role12_id                  jtf_terr_number_list,
  resource13_name            jtf_terr_char_360list,
  resource13_id              jtf_terr_number_list,
  group13_name               jtf_terr_char_360list,
  group13_id                 jtf_terr_number_list,
  role13_name                jtf_terr_char_360list,
  role13_id                  jtf_terr_number_list,
  resource14_name            jtf_terr_char_360list,
  resource14_id              jtf_terr_number_list,
  group14_name               jtf_terr_char_360list,
  group14_id                 jtf_terr_number_list,
  role14_name                jtf_terr_char_360list,
  role14_id                  jtf_terr_number_list,
  resource15_name            jtf_terr_char_360list,
  resource15_id              jtf_terr_number_list,
  group15_name               jtf_terr_char_360list,
  group15_id                 jtf_terr_number_list,
  role15_name                jtf_terr_char_360list,
  role15_id                  jtf_terr_number_list,
  resource16_name            jtf_terr_char_360list,
  resource16_id              jtf_terr_number_list,
  group16_name               jtf_terr_char_360list,
  group16_id                 jtf_terr_number_list,
  role16_name                jtf_terr_char_360list,
  role16_id                  jtf_terr_number_list,
  resource17_name            jtf_terr_char_360list,
  resource17_id              jtf_terr_number_list,
  group17_name               jtf_terr_char_360list,
  group17_id                 jtf_terr_number_list,
  role17_name                jtf_terr_char_360list,
  role17_id                  jtf_terr_number_list,
  resource18_name            jtf_terr_char_360list,
  resource18_id              jtf_terr_number_list,
  group18_name               jtf_terr_char_360list,
  group18_id                 jtf_terr_number_list,
  role18_name                jtf_terr_char_360list,
  role18_id                  jtf_terr_number_list,
  resource19_name            jtf_terr_char_360list,
  resource19_id              jtf_terr_number_list,
  group19_name               jtf_terr_char_360list,
  group19_id                 jtf_terr_number_list,
  role19_name                jtf_terr_char_360list,
  role19_id                  jtf_terr_number_list,
  resource20_name            jtf_terr_char_360list,
  resource20_id              jtf_terr_number_list,
  group20_name               jtf_terr_char_360list,
  group20_id                 jtf_terr_number_list,
  role20_name                jtf_terr_char_360list,
  role20_id                  jtf_terr_number_list,
  resource21_name            jtf_terr_char_360list,
  resource21_id              jtf_terr_number_list,
  group21_name               jtf_terr_char_360list,
  group21_id                 jtf_terr_number_list,
  role21_name                jtf_terr_char_360list,
  role21_id                  jtf_terr_number_list,
  resource22_name            jtf_terr_char_360list,
  resource22_id              jtf_terr_number_list,
  group22_name               jtf_terr_char_360list,
  group22_id                 jtf_terr_number_list,
  role22_name                jtf_terr_char_360list,
  role22_id                  jtf_terr_number_list,
  resource23_name            jtf_terr_char_360list,
  resource23_id              jtf_terr_number_list,
  group23_name               jtf_terr_char_360list,
  group23_id                 jtf_terr_number_list,
  role23_name                jtf_terr_char_360list,
  role23_id                  jtf_terr_number_list,
  resource24_name            jtf_terr_char_360list,
  resource24_id              jtf_terr_number_list,
  group24_name               jtf_terr_char_360list,
  group24_id                 jtf_terr_number_list,
  role24_name                jtf_terr_char_360list,
  role24_id                  jtf_terr_number_list,
  resource25_name            jtf_terr_char_360list,
  resource25_id              jtf_terr_number_list,
  group25_name               jtf_terr_char_360list,
  group25_id                 jtf_terr_number_list,
  role25_name                jtf_terr_char_360list,
  role25_id                  jtf_terr_number_list,
  resource26_name            jtf_terr_char_360list,
  resource26_id              jtf_terr_number_list,
  group26_name               jtf_terr_char_360list,
  group26_id                 jtf_terr_number_list,
  role26_name                jtf_terr_char_360list,
  role26_id                  jtf_terr_number_list,
  resource27_name            jtf_terr_char_360list,
  resource27_id              jtf_terr_number_list,
  group27_name               jtf_terr_char_360list,
  group27_id                 jtf_terr_number_list,
  role27_name                jtf_terr_char_360list,
  role27_id                  jtf_terr_number_list,
  resource28_name            jtf_terr_char_360list,
  resource28_id              jtf_terr_number_list,
  group28_name               jtf_terr_char_360list,
  group28_id                 jtf_terr_number_list,
  role28_name                jtf_terr_char_360list,
  role28_id                  jtf_terr_number_list,
  resource29_name            jtf_terr_char_360list,
  resource29_id              jtf_terr_number_list,
  group29_name               jtf_terr_char_360list,
  group29_id                 jtf_terr_number_list,
  role29_name                jtf_terr_char_360list,
  role29_id                  jtf_terr_number_list,
  resource30_name            jtf_terr_char_360list,
  resource30_id              jtf_terr_number_list,
  group30_name               jtf_terr_char_360list,
  group30_id                 jtf_terr_number_list,
  role30_name                jtf_terr_char_360list,
  role30_id                  jtf_terr_number_list,
  created_by                 jtf_terr_number_list,
  last_updated_by            jtf_terr_number_list,
  last_update_login          jtf_terr_number_list,
  dnb_annual_rev             jtf_terr_number_list,
  dnb_num_of_em              jtf_terr_number_list,
  prior_won                  jtf_terr_number_list
);

--TYPE bulk_NAST_tbl IS TABLE OF bulk_NAST_rec;
*/

procedure POPULATE_INTERFACE(      P_CALLFROM         IN VARCHAR2,
                                   P_SEARCHTYPE       IN VARCHAR2,
                                   P_SEARCHVALUE      IN VARCHAR2,
                                   P_USERID           IN INTEGER,
                                   P_GRPID            IN NUMBER,
                                   P_GRPNAME          IN VARCHAR2,
                                   P_SITE_TYPE        IN VARCHAR2,
                                   P_SICCODE          IN VARCHAR2,
                                   P_SITE_DUNS        IN VARCHAR2,
                                   P_NAMED_ACCOUNT    IN VARCHAR2,
                                   P_CITY             IN VARCHAR2,
                                   P_STATE            IN VARCHAR2,
                                   P_PROVINCE         IN VARCHAR2,
                                   P_POSTAL_CODE_FROM IN VARCHAR2,
                                   P_POSTAL_CODE_TO   IN VARCHAR2,
                                   P_COUNTRY          IN VARCHAR2,
                                   P_DU_DUNS          IN VARCHAR2,
                                   P_DU_NAME          IN VARCHAR2,
                                   P_GU_DUNS          IN VARCHAR2,
                                   P_GU_NAME          IN VARCHAR2,
                                   P_SALESPERSON      IN NUMBER,
                                   P_SALES_GROUP      IN NUMBER,
                                   P_SALES_ROLE       IN VARCHAR2,
                                   P_ASSIGNED_STATUS  IN VARCHAR2,
                                   P_IDENTADDRFLAG    IN VARCHAR2,
                                   P_ISADMINFLAG      IN VARCHAR2,
                                   X_SEQ            OUT NOCOPY VARCHAR2
                             );



END JTF_TTY_WEBADI_NADOC_PKG;

 

/
