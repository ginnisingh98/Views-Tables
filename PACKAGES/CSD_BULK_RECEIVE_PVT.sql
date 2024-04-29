--------------------------------------------------------
--  DDL for Package CSD_BULK_RECEIVE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_BULK_RECEIVE_PVT" AUTHID CURRENT_USER AS
/* $Header: csdvbrvs.pls 120.1.12010000.2 2009/09/02 05:32:56 subhat ship $ */

/* ---------------------------------------------------------*/
/* Define global variables                                  */
/* ---------------------------------------------------------*/
G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSD_BULK_RECEIVE_PVT';

-- 12.1.2 BR ER FP, subhat.
g_bulk_rcv_conc varchar2(3) := 'N';
g_conc_req_id number;
/*-----------------------------------------------------------------*/
/* procedure name: process_bulk_receive_items                      */
/* description   : Concurrent program to Bulk Receive Items        */
/*                                                                 */
/*-----------------------------------------------------------------*/

PROCEDURE process_bulk_receive_items
(
  errbuf                OUT    NOCOPY    VARCHAR2,
  retcode               OUT    NOCOPY    VARCHAR2,
  p_transaction_number  IN     NUMBER
);


END CSD_BULK_RECEIVE_PVT;

/
