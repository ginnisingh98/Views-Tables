--------------------------------------------------------
--  DDL for Package ECE_AP_PAYMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECE_AP_PAYMENT" AUTHID CURRENT_USER AS
-- $Header: ECEPYOS.pls 120.4 2006/04/19 03:48:51 arsriniv ship $


/*===========================================================================

  PROCEDURE NAME:      Extract_PYO_Outbound

  PURPOSE:             This procedure initiates the concurrent process to
                       extract the eligible deliveires on a dparture.

===========================================================================*/

PROCEDURE Extract_PYO_Outbound ( p_api_version            IN NUMBER,
                                 p_init_msg_list          IN VARCHAR2,
                                 p_commit                 IN VARCHAR2,
                                 x_return_status          OUT NOCOPY VARCHAR2,
                                 x_msg_count              OUT  NOCOPY NUMBER,
                                 x_msg_data               OUT  NOCOPY VARCHAR2,
                                 p_payment_instruction_id IN NUMBER);



END ECE_AP_PAYMENT;


 

/
