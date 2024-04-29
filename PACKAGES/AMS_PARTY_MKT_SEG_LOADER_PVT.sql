--------------------------------------------------------
--  DDL for Package AMS_PARTY_MKT_SEG_LOADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_PARTY_MKT_SEG_LOADER_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvldrs.pls 120.1 2005/06/27 05:41:33 appldev ship $ */



/*****************************************************************************/
-- Define a PL sql table to hold the Discoverer SQL Query
-- Added by ptendulk on May03/2000

TYPE sql_rec_type IS TABLE OF VARCHAR2(2000)
INDEX BY BINARY_INTEGER;

/******************************************************************************/
--PL\SQL table to hold the Partyids returned by execution for dbms_sql
/******************************************************************************/

TYPE t_party_tab is TABLE OF NUMBER
INDEX BY BINARY_INTEGER;


-- Start of Comments
--
-- NAME
--   Refresh_Party_Market_Segment
--
-- PURPOSE
--   This procedure is created to as a concurrent program which
--   will call the load_party_mkt_seg and will return errors if any
--
-- NOTES
--
--
-- HISTORY
--   05/02/1999      ptendulk    created
-- End of Comments

PROCEDURE Refresh_Party_Market_Segment
                        (errbuf        OUT NOCOPY    VARCHAR2,
                         retcode       OUT NOCOPY    NUMBER,
                         p_cell_id     IN     NUMBER DEFAULT NULL);


/*****************************************************************************/
-- Procedure
--   load_party_mkt_seg
-- Purpose
--   load ams_party_market_segments
-- History
--   01/16/2000    julou    created
--   05/02/2000    ptendulk Modified , Added Parameters for Handling errors
--                 Parameters added : x_return_status,x_msg_data,x_msg_count
-------------------------------------------------------------------------------
PROCEDURE Load_Party_Mkt_Seg
(   p_cell_id       IN  NUMBER  DEFAULT NULL,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2
  );


-- Start of Comments
--
-- NAME
--   Validate_Sql
--
-- PURPOSE
--   This procedure is created to validate the discoverer sql created for
--   the Cells . It will follow the following steps :
--   1. Check If the sql length is less than 32k , If it's less than 32k
--      process and execute it as native sql or use dynamic sql
--   2. Check for the party id between SELECT and FROM of the SQL string
--   3. Substitue the party id for every thing between select and from
--   4. Execute the query
--
--   It will return the Parameters as
--   1. x_query : This table will have the discoverer sql query
--   2. x_sql_type : It will return 'NATIVE' if the sql is Native SQL
--                   or it will return 'DYNAMIC'
-- NOTES
--
--
-- HISTORY
--   05/02/1999      ptendulk    created
-- End of Comments

PROCEDURE Validate_Sql
           (p_workbook_name    IN   VARCHAR2,
            p_workbook_owner   IN   VARCHAR2,
            p_worksheet_name   IN   VARCHAR2,
            p_cell_name        IN   VARCHAR2,
            x_query            OUT NOCOPY  sql_rec_type,
            x_sql_type         OUT NOCOPY  VARCHAR2,

            x_return_status    OUT NOCOPY  VARCHAR2,
            x_msg_count        OUT NOCOPY  NUMBER,
            x_msg_data         OUT NOCOPY  VARCHAR2);


/*****************************************************************************/
-- Procedure
--   Refresh_Segment_Size
--
-- Purpose
--   This procedure is created to as a concurrent program which
--   will call the update_segment_size and will return errors if any
--
-- Notes
--
--
-- History
--   04/09/2001      yxliu    created
--   06/20/2001      yxliu    moved from AMS_Cell_Pvt package
------------------------------------------------------------------------------

PROCEDURE Refresh_Segment_Size
(   errbuf        OUT NOCOPY    VARCHAR2,
    retcode       OUT NOCOPY    NUMBER,
    p_cell_id     IN     NUMBER DEFAULT NULL
);


/*****************************************************************************
 * NAME
 *   LOAD_PARTIES_FOR_MARKET_QUALIFIERS
 *
 * PURPOSE
 *   This procedure is a concurrent program to
 *     generate party list that matches a given territory's qualifiers and buying group
 *
 * NOTES
 *
 * HISTORY
 *   10/04/2001      yzhao    created
*/

PROCEDURE LOAD_PARTY_MARKET_QUALIFIER
                        (errbuf        OUT NOCOPY    VARCHAR2,
                         retcode       OUT NOCOPY    NUMBER,
                         /* yzhao 07/17/2002 fix bug 2410322 - UPG1157:9I:AMS PACKAGE/PACKAGE BODY MISMATCHES
                         p_terr_id     IN     NUMBER,
                         p_bg_id       IN     NUMBER);
                         */
                         p_terr_id     IN     NUMBER      := NULL,
                         p_bg_id       IN     NUMBER      := NULL);


END AMS_Party_Mkt_Seg_Loader_PVT;

 

/
