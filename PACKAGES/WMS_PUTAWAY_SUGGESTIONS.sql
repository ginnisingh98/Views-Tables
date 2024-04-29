--------------------------------------------------------
--  DDL for Package WMS_PUTAWAY_SUGGESTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_PUTAWAY_SUGGESTIONS" AUTHID CURRENT_USER AS
/* $Header: WMSPRGES.pls 120.2.12010000.2 2010/02/19 08:48:07 vissubra ship $ */
--
/*===========================================================================+
 | Procedure:                                                                |
 |    conc_pre_generate                                                      |
 |                                                                           |
 | Description:                                                              |
 |    This is a wrapper API that calls WMS_PUTAWAY_SUGGESTIONS.PRE_GENERATE  |
 | API. It has the necessary parameters required for being a concurrent      |
 | program.                                                                  |
 |                                                                           |
 | Input Parameters:                                                         |
 |       p_organization_id                                                   |
 |         Mandatory parameter. Organization where putaway suggestions have  |
 |         to be pre-generated.                                              |
 |       p_lpn_id                                                            |
 |         Optional parameter. LPN for which suggestions have to be created. |
 |                                                                           |
 | Output Parameters:                                                        |
 |        x_retcode                                                          |
 |          Standard Concurrent program parameter - Normal, Warning, Error.  |
 |        x_errorbuf                                                         |
 |          Standard Concurrent program parameter - Holds error message.     |
 |                                                                           |
 | API Used:                                                                 |
 |     PRE_GENERATE API to generate the putaway suggestions.                 |
 +===========================================================================*/

--Return values for x_retcode(standard for concurrent programs)

RETCODE_SUCCESS         CONSTANT     VARCHAR2(1)  := '0';
RETCODE_WARNING         CONSTANT     VARCHAR2(1)  := '1';
RETCODE_ERROR           CONSTANT     VARCHAR2(1)  := '2';

PROCEDURE conc_pre_generate(
    x_errorbuf         OUT  NOCOPY VARCHAR2,
    x_retcode          OUT  NOCOPY VARCHAR2,
    p_organization_id   IN  NUMBER,
    p_lpn_id            IN  NUMBER,
    p_is_srs_call       IN VARCHAR2 DEFAULT NULL
    );

-- Procedure called by receiving. The procedure submits a request to start
--the concurrent program

PROCEDURE start_pregenerate_program
  (p_org_id               IN   NUMBER,
   p_lpn_id               IN   NUMBER,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2
   );


--
/*===========================================================================+
 | Procedure:                                                                |
 |     pre_generate                                                          |
 |                                                                           |
 | Description:                                                              |
 |    This API polls receipts table for receipts yet to be put away and      |
 | create suggestions for their put away.                                    |
 |                                                                           |
 | Input Parameters:                                                         |
 |       p_from_conc_pgm                                                     |
 |         Mandatory parameter. Default 'Y'. Indicates if the caller is      |
 |         concurrent program or otherwise. This is needed to know if        |
 |         messages have to be logged in a file.                             |
 |       p_commit                                                            |
 |         Mandatory parameter. Default 'Y'. Indicates if commit has to      |
 |         happen.                                                           |
 |       p_organization_id                                                   |
 |         Mandatory parameter. Organization where putaway suggestions have  |
 |         to be pre-generated.                                              |
 |       p_lpn_id                                                            |
 |         Optional parameter. LPN for which suggestions have to be created. |
 |                                                                           |
 | Output Parameters:                                                        |
 |        x_return_status                                                    |
 |          Standard API return status - Success, Error, Unexpected Error.   |
 |        x_msg_count                                                        |
 |          Number of messages in the message queue                          |
 |        x_msg_data                                                         |
 |          If the number of messages in the message queue is one,           |
 |          x_msg_data has the message text.                                 |
 |        x_partial_success                                                  |
 |          Indicates if one or more lpns errored out.                       |
 |        x_lpn_line_error_tbl                                               |
 |          Plsql table to hold the errored out lpn_id and line ids.         |
 |                                                                           |
 | Tables Used:                                                              |
 |        1. mtl_txn_request_headers                                         |
 |        2. mtl_txn_request_lines                                           |
 +===========================================================================*/
--lpn_tbl and line_tbl are plsql tables to hold the errored lpn_id, line_id

/* Start of fix for bug # 4964866 */

/*-- Bug# 4178478: Fix Begin
TYPE l_lpn_table_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
-- Bug# 4178478: Fix End */

TYPE mmtt_type_rec is RECORD
(
   lpn_id                         NUMBER
 , organization_id                NUMBER
 , subinventory_code              VARCHAR2(10)
 , locator_id                     NUMBER
 , backorder_delivery_detail_id   NUMBER -- for bug8775458
 );

TYPE mmtt_table_type IS TABLE OF mmtt_type_rec INDEX BY BINARY_INTEGER;

/* End of fix for bug # 4964866 */

TYPE lpn_line_rec IS RECORD (
     lpn_id NUMBER,
     line_id NUMBER);
TYPE lpn_line_error_tbl IS TABLE OF lpn_line_rec INDEX BY BINARY_INTEGER;

PROCEDURE pre_generate(
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    x_partial_success  	    OUT NOCOPY VARCHAR2,
    x_lpn_line_error_tbl    OUT NOCOPY lpn_line_error_tbl,
    p_from_conc_pgm          IN  VARCHAR2,
    p_commit                 IN  VARCHAR2,
    p_organization_id        IN  NUMBER,
    p_lpn_id                 IN  NUMBER,
    p_is_srs_call            IN  VARCHAR2 DEFAULT NULL
    );

PROCEDURE cleanup_suggestions
  (p_org_id                       IN  NUMBER,
   p_lpn_id                       IN  NUMBER,
   x_return_status                OUT NOCOPY VARCHAR2,
   x_msg_count                    OUT NOCOPY NUMBER,
   x_msg_data                     OUT NOCOPY VARCHAR2,
   p_move_order_line_id           IN NUMBER DEFAULT NULL  --added for ATF_J2
   );

/*===========================================================================+
 | Procedure:                                                                |
 |     print_message                                                         |
 |                                                                           |
 | Description:                                                              |
 |    Writes message text in log files.                                      |
 |                                                                           |
 | Input Parameters:                                                         |
 |        None                                                               |
 |                                                                           |
 | Output Parameters:                                                        |
 |        None                                                               |
 |                                                                           |
 | Tables Used:                                                              |
 |        None                                                               |
 +===========================================================================*/

PROCEDURE print_message(dummy IN VARCHAR2 DEFAULT NULL);

END wms_putaway_suggestions;

/
