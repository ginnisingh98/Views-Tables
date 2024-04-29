--------------------------------------------------------
--  DDL for Package PON_NEG_COPY_DATATYPES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_NEG_COPY_DATATYPES_GRP" AUTHID CURRENT_USER AS
--$Header: PONGCDTS.pls 120.0 2005/06/01 20:52:36 appldev noship $

-- Start of comments
--      API name : PON_NEG_COPY_DATATYPES_GRP
--
--      Type        : Group
--
--      Pre-reqs  : None
--
--      Function  : Declares a set of tables for holding different kind of datatypes and
--			  used as  placeholders while creating a negotiation from a
--			  given auction_header_id (PON_NEGOTIATION_COPY_GRP package)
--                        with given auction_header_id (p_source_auction_header_id)
--
--			 It has got tables for NUMBER, DATE and different lengths of VARCHARs
--
-- End of comments

TYPE  NUMBER_TYPE  IS TABLE OF NUMBER
	INDEX BY BINARY_INTEGER;

TYPE  SIMPLE_DATE_TYPE  IS TABLE OF DATE
	INDEX BY BINARY_INTEGER;

TYPE  VARCHAR1_TYPE  IS TABLE OF VARCHAR2(1)
	INDEX BY BINARY_INTEGER;

TYPE  VARCHAR20_TYPE  IS TABLE OF VARCHAR2(20)
	INDEX BY BINARY_INTEGER;

TYPE  VARCHAR50_TYPE  IS TABLE OF VARCHAR2(50)
	INDEX BY BINARY_INTEGER;

TYPE  VARCHAR100_TYPE  IS TABLE OF VARCHAR2(100)
	INDEX BY BINARY_INTEGER;

TYPE  VARCHAR300_TYPE  IS TABLE OF VARCHAR2(300)
	INDEX BY BINARY_INTEGER;

TYPE  VARCHAR1000_TYPE  IS TABLE OF VARCHAR2(1000)
	INDEX BY BINARY_INTEGER;

TYPE  VARCHAR2000_TYPE  IS TABLE OF VARCHAR2(2000)
	INDEX BY BINARY_INTEGER;

TYPE  VARCHAR2500_TYPE  IS TABLE OF VARCHAR2(2500)
	INDEX BY BINARY_INTEGER;

TYPE  VARCHAR4000_TYPE  IS TABLE OF VARCHAR2(4000)
	INDEX BY BINARY_INTEGER;

END PON_NEG_COPY_DATATYPES_GRP;

 

/
