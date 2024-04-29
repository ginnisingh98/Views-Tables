--------------------------------------------------------
--  DDL for Package OE_MESSAGE_PURGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_MESSAGE_PURGE_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXMPRGS.pls 120.2 2005/09/29 01:48:00 pkannan noship $ */

/* ---------------------------------------------------------------
--  Start of Comments
--  API name    OE_MESSAGE_PURGE_PVT
--  Type        Private
--  Function
--  Pre-reqs
--  Parameters
--  Version     Current version = 1.0
--              Initial version = 1.0
--  Notes
--
--  End of Comments
------------------------------------------------------------------ */

/* -----------------------------------------------------------
   Procedure: Purge_Messages
 ----------------------------------------------------------- */
PROCEDURE PURGE(
errbuf OUT NOCOPY VARCHAR2

,retcode OUT NOCOPY NUMBER

  ,p_commit IN NUMBER DEFAULT 500
  ,p_start_date IN VARCHAR2
  ,p_end_date IN VARCHAR2
  ,p_message_source IN VARCHAR2
  ,p_customer_id_name IN NUMBER
  ,p_customer_id_number IN NUMBER
  ,p_order_type_id IN NUMBER
  ,p_start_order_num IN NUMBER
  ,p_end_order_num IN NUMBER
  ,p_message_status_code IN Varchar2 Default Null);

END OE_MESSAGE_PURGE_PVT;

 

/
