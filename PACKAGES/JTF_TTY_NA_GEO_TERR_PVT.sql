--------------------------------------------------------
--  DDL for Package JTF_TTY_NA_GEO_TERR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TTY_NA_GEO_TERR_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvnats.pls 120.0 2005/06/02 18:22:12 appldev ship $ */
--    Start of Comments
--    ---------------------------------------------------
--    OLD PACKAGE NAME:   JTF_TERR_ENGINE_GEN_PVT
--    PACKAGE NAME:   JTF_TTY_NA_GEO_TERR_PVT
--    ---------------------------------------------------
--    PURPOSE
--      This Package will create the physical territories for the
--      self-service named accounts and geography territories
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is not publicly available for use
--
--    HISTORY
--      08/09/03    JRADHAKR         Created by Moving the named account
--                                   procedure from JTF_TERR_ENGINE_GEN_PVT
--
--    End of Comments
--
-- Identifies the Package associated with
-- a territory with child nodes
--
 TYPE Terr_Package_Spec       IS RECORD
 (
    TERR_ID                 NUMBER,
    PACKAGE_COUNT           NUMBER
 );
 TYPE Terr_PkgSpec_Tbl_Type         IS TABLE OF  Terr_Package_Spec
                                   INDEX BY BINARY_INTEGER;

TYPE TERR_GRP_REC_TYPE IS RECORD
(
     TERR_GROUP_ID            NUMBER,
     TERR_GROUP_NAME          VARCHAR2(150),
     RANK                     NUMBER,
     ACTIVE_FROM_DATE         DATE,
     ACTIVE_TO_DATE           DATE,
     PARENT_TERR_ID           NUMBER,
     MATCHING_RULE_CODE       VARCHAR2(30),
     CREATED_BY               NUMBER(15),
     CREATION_DATE            DATE,
     LAST_UPDATED_BY          NUMBER(15),
     LAST_UPDATE_DATE         DATE,
     LAST_UPDATE_LOGIN        NUMBER,
     Catch_all_resource_id    NUMBER,
     catch_all_resource_type  VARCHAR2(30),
     generate_catchall_flag   VARCHAR2(1),
     NUM_WINNERS              NUMBER
);



 PROCEDURE generate_named_overlay_terr(p_mode VARCHAR2);


END JTF_TTY_NA_GEO_TERR_PVT;

 

/
