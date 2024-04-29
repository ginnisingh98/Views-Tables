--------------------------------------------------------
--  DDL for Package ARP_QUEUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_QUEUE" AUTHID CURRENT_USER AS
             -- $Header: ARPQUEFS.pls 115.4 2002/11/15 02:44:47 anukumar ship $

   consumer_name VARCHAR2(2000);

   FUNCTION get_full_qname(p_qname IN VARCHAR2) RETURN VARCHAR2;
   PROCEDURE enqueue (p_msg IN system.AR_REV_REC_TYP);
   PROCEDURE dequeue (p_msg IN OUT NOCOPY system.AR_REV_REC_TYP,
		      p_browse IN BOOLEAN :=FALSE,
		      p_wait IN INTEGER := DBMS_AQ.NO_WAIT,
		      p_first IN BOOLEAN := FALSE);

END;

 

/
