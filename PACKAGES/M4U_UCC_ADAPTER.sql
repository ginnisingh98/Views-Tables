--------------------------------------------------------
--  DDL for Package M4U_UCC_ADAPTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."M4U_UCC_ADAPTER" AUTHID CURRENT_USER AS
/* $Header: m4uinaqs.pls 120.0 2005/05/24 16:20:49 appldev noship $ */
/*#
* This package is called for queueing the response from UCCnet adapter.
* @rep:scope private
* @rep:product CLN
* @rep:displayname M4U API for INBOUND message enqueue.
* @rep:category BUSINESS_ENTITY  EGO_ITEM
* @rep:compatibility  N
* @rep:lifecycle  active
*/

        /*#
        * This function is called to enqueue an inbound XML message from UCCnet adapter.
        * @param clob_payload INBOUND XML Message
        * @return enqueue_status SUCCESS/Error
        * @rep:displayname Enqueue XML message from UCCnet
        * @rep:scope private
        */
        FUNCTION pushtoAQ( clob_payload CLOB) RETURN VARCHAR2;
END;

 

/
