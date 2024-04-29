--------------------------------------------------------
--  DDL for Package OZF_PARTY_MKT_SEG_LOADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_PARTY_MKT_SEG_LOADER_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvldrs.pls 120.0 2005/06/01 00:56:54 appldev noship $ */



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
                         /* yzhao 07/17/2002 fix bug 2410322 - UPG1157:9I:OZF PACKAGE/PACKAGE BODY MISMATCHES
                         p_terr_id     IN     NUMBER,
                         p_bg_id       IN     NUMBER);
                         */
                         p_terr_id     IN     NUMBER      := NULL,
                         p_bg_id       IN     NUMBER      := NULL);


END OZF_Party_Mkt_Seg_Loader_PVT;

 

/
