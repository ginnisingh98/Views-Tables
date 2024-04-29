--------------------------------------------------------
--  DDL for Package AMS_PARTY_SEG_LOADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_PARTY_SEG_LOADER_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvcecs.pls 115.5 2002/11/22 02:24:32 jieli noship $ */


/******************************************************************************/
--PL\SQL table to hold the Partyids returned by execution for dbms_sql
/******************************************************************************/

TYPE t_party_tab is TABLE OF NUMBER
INDEX BY BINARY_INTEGER;

/*****************************************************************************/
-- Procedure
--   load_party_seg
-- Purpose
--   load ams_party_market_segments
--
--  Note
--     1. The process will execute the ams_cells_pvt.get_comp_sql for a given
--        cell to get its sql and its ancestors, then excute the sql to get
--        the parties that belong to that sql.
--     2. If cell_id is passed into, then only that cell will be refreshed or
--        else all the cells will be refreshed.
-- History
--   01/26/2001    yxliu      created
-------------------------------------------------------------------------------
PROCEDURE Load_Party_Seg
(
    p_cell_id       IN    NUMBER DEFAULT NULL,
    x_return_status OUT NOCOPY   VARCHAR2,
    x_msg_count     OUT NOCOPY   NUMBER,
    x_msg_data      OUT NOCOPY   VARCHAR2
);

/*****************************************************************************/
-- Procedure
--   Refresh_Party_Segment
--
-- PURPOSE
--   This procedure is created to as a concurrent program which
--   will call the load_party_seg and will return errors if any
--
-- NOTES
--
--
-- HISTORY
--   01/26/2001      yxliu    created
-- End of Comments
-------------------------------------------------------------------------------

PROCEDURE Refresh_Party_Segment
                        (errbuf        OUT NOCOPY    VARCHAR2,
                         retcode       OUT NOCOPY    NUMBER,
                         p_cell_id     IN     NUMBER DEFAULT NULL);

END AMS_Party_Seg_Loader_PVT;

 

/
