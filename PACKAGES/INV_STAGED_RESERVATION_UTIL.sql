--------------------------------------------------------
--  DDL for Package INV_STAGED_RESERVATION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_STAGED_RESERVATION_UTIL" AUTHID CURRENT_USER AS
/* $Header: INVRSV9S.pls 120.1 2005/06/20 11:26:13 appldev ship $*/

/*
*/
PROCEDURE query_staged_flag
  ( x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    x_staged_flag         OUT NOCOPY VARCHAR2,
    p_reservation_id      IN  NUMBER);

PROCEDURE update_staged_flag
  ( x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_reservation_id      IN  NUMBER,
    p_staged_flag         IN  VARCHAR2);

END inv_staged_reservation_util;

 

/
