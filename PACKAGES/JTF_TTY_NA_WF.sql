--------------------------------------------------------
--  DDL for Package JTF_TTY_NA_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TTY_NA_WF" AUTHID CURRENT_USER AS
/* $Header: jtftrwas.pls 120.0 2005/06/02 18:21:59 appldev ship $ */

--  ---------------------------------------------------
--  Start of Comments
--  ---------------------------------------------------
--  PACKAGE NAME:   JTF_TTY_NA_WF
--  ---------------------------------------------------
--  PURPOSE
--      Reassign Catch All territories and create appropriate named accounts
--
--
--  PROCEDURES:
--       (see below for specification)
--
--  NOTES
--    This package is for PRIVATE USE ONLY use
--
--  HISTORY
--    12/13/02    ARPATEL          Package Created
--    End of Comments
--

G_USER          CONSTANT        VARCHAR2(60):=FND_GLOBAL.USER_ID;

TYPE NA_Rec_Type IS RECORD (
    NAMED_ACCOUNT_ID         NUMBER
   , TERR_GROUP_ID           NUMBER
   , SITE_RANK               NUMBER );

PROCEDURE AssignRep
        ( itemtype   IN     VARCHAR2
        , itemkey    IN     VARCHAR2
        , actid      IN     NUMBER
        , funcmode   IN     VARCHAR2
        , resultout     OUT NOCOPY VARCHAR2
        );

PROCEDURE add_org_to_terrgp(p_terr_gp_id IN NUMBER,
                            p_ref_account_id IN NUMBER,
                             p_party_id IN NUMBER,
                             p_resource_id IN NUMBER,
                             p_role_code IN VARCHAR2,
                             p_user_id in NUMBER,
                             p_rsc_group_id IN NUMBER,
                             p_lead_keyword IN VARCHAR2,
                             p_lead_postal_code IN VARCHAR2,
                             x_account_id OUT NOCOPY NUMBER);

PROCEDURE create_mapping_rules (p_account_id  IN NUMBER
                              , p_keyword     IN VARCHAR2
                              , p_postal_code IN VARCHAR2);

function get_site_type_code( p_party_id NUMBER ) return varchar2;

END JTF_TTY_NA_WF;


 

/
