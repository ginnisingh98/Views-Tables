--------------------------------------------------------
--  DDL for Package JTF_TAE_1001_RPT_DYN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TAE_1001_RPT_DYN" AUTHID CURRENT_USER AS
/* $Header: jtfvtrds.pls 115.4 2002/12/23 21:40:46 jdochert ship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TAE_1001_RPT_DYN
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force core territory manager public api's.
--      This package is used to return a list of winning Territories.
--      The package body is dynamically for reports.
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      02/14/02    SBEHERA        Created
--
--
--    End of Comments
--
--*******************************************************
--    Start of Comments
--*******************************************************

PROCEDURE  Search_Terr_Rules( p_source_id             IN   NUMBER,
                              p_trans_object_type_id  IN   NUMBER,
                              p_session_id            IN   NUMBER );


END JTF_TAE_1001_RPT_DYN;

 

/
