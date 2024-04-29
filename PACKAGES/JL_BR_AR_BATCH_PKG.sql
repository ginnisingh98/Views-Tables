--------------------------------------------------------
--  DDL for Package JL_BR_AR_BATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_BR_AR_BATCH_PKG" AUTHID CURRENT_USER as
/* $Header: jlbrrbgs.pls 115.2 2002/11/21 17:44:30 vsidhart ship $ */


/*----------------------------------------------------------------------------*
 |   GLOBAL PARAMETER            					      |
 *----------------------------------------------------------------------------*/



  PROCEDURE get_batch_id (
        p_request_id IN NUMBER,
        x_batch_id OUT NOCOPY NUMBER);



END JL_BR_AR_BATCH_PKG;

 

/
