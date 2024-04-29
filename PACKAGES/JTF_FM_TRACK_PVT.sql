--------------------------------------------------------
--  DDL for Package JTF_FM_TRACK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_FM_TRACK_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvfmts.pls 115.4 2003/08/26 15:42:56 abuddhav ship $*/
-----------------------------------------------------------------------------
-- Procedure
--    track_image
--
-- PURPOSE
--    Save customer tracking information.
-----------------------------------------------------------------------------
PROCEDURE TRACK_IMAGE
(
   p_request_history_id    IN NUMBER,
   p_customer_id           IN NUMBER
);


PROCEDURE UNSUBSCRIBE_USER
(
   p_request_history_id    IN NUMBER,
   p_customer_id           IN NUMBER
);


PROCEDURE TRACK_BOUNCEBACK
(
   p_request_history_id    IN NUMBER,
   p_customer_id           IN NUMBER
);


END Jtf_Fm_Track_Pvt;

 

/
