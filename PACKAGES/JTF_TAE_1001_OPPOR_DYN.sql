--------------------------------------------------------
--  DDL for Package JTF_TAE_1001_OPPOR_DYN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TAE_1001_OPPOR_DYN" AUTHID CURRENT_USER AS
/* $Header: jtfvtdos.pls 120.2 2005/09/14 00:17:01 achanda ship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TAE_1001_OPPOR_DYN
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force core territory manager public api's.
--      This package is used to return a list of winning Territories.
--      The package body is dynamically created when Sales Account Rules
--      are generated.
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

PROCEDURE  Search_Terr_Rules(
                              p_source_id           IN          NUMBER ,
                              p_trans_object_type_id     IN          NUMBER,
                              x_Return_Status           OUT NOCOPY VARCHAR2,
                              x_Msg_Count               OUT NOCOPY NUMBER,
                              x_Msg_Data                OUT NOCOPY VARCHAR2,
                              p_worker_id       IN NUMBER := 1
);


END JTF_TAE_1001_OPPOR_DYN;

 

/
