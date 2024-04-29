--------------------------------------------------------
--  DDL for Package ARP_FLEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_FLEX" AUTHID CURRENT_USER AS
/* $Header: ARPLFLXS.pls 115.5 2002/11/20 01:56:40 dbetanco ship $ */

/*---------------------------------------------------------------------------+
 | PUBLIC HANDLES                                                            |
 |    These handles are automatically initialised during package startup     |
 |                                                                           |
 +---------------------------------------------------------------------------*/

--  General Ledger Accounts Structure for current SOB
function gl       return number;

--  Sales Tax Location Flexfield for current SOB
function location return number;


/*---------------------------------------------------------------------------+
 | PUBLIC FUNCTIONS                                                          |
 +---------------------------------------------------------------------------*/

function setup_flexfield(  application_id in number,
                           flex_code      in varchar2,
                           structure_id   in number ) return number;


/*---------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                           |
 |   expand                                                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |                                                                           |
 | Generate a flexfield lexical string given a flexfield handle, expanding   |
 | keyword tokens.                                                           |
 |                                                                           |
 | TOKEN EXPANSION  - Tokens are marked with a % either side of the word     |
 |                                                                           |
 |   COLUMN         - Name of Column in Code Combinations table              |
 |   NUMBER         - Segment Number                                         |
 |   QUALIFIER      - Segment Qualifier(s)                                   |
 |   POSITION       - Position of segment within flexfield structure         |
 |                                                                           |
 | TOKEN MODIFIERS  - If any token is prefixed with a modifier then either   |
 |                    the previous or last token is fetched.                 |
 |                                                                           |
 |   NEXT           - Gets information for next physical segment             |
 |   PREVIOUS       - Gets information for the previous segment              |
 |                                                                           |
 | EXAMPLE                                                                   |
 |   ar_flex.expand( ar_flex.gl, ' || ', 'cc.%COLUMN%' )                     |
 |   -- cc.SEGMENT1 || cc.SEGMENT2 || cc.SEGMENT3                            |
 |                                                                           |
 |   ar_flex.expand( ar_flex.gl, ' and ', 'cc.%COLUMN% = t%NUM%.SEGMENT')    |
 |   -- cc.SEGMENT1 = t1.SEGMENT and                                         |
 |      cc.SEGMENT2 = t2.SEGMENT and                                         |
 |      cc.SEGMENT3 = t3.SEGMENT                                             |
 |                                                                           |
 | KNOWN BUGS:                                                               |
 |   Future versions of replicate will support segment qualifiers            |
 |   Expansion is CASE sensitive, all token must be in upper case.           |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    22-Mar-93  Nigel Smith    Created.                                     |
 |                                                                           |
 |                                                                           |
 +---------------------------------------------------------------------------*/



function expand( flex_handle in number,
                 separator in varchar2,
                 word      in varchar2 ) return varchar2;

function expand( flex_handle in number,
                 qualifiers in varchar2,
                 separator in varchar2,
                 word      in varchar2 ) return varchar2;


function active_segments( flex_handle in number ) return number ;

end ARP_FLEX ;

 

/
