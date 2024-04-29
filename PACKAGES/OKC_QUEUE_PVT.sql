--------------------------------------------------------
--  DDL for Package OKC_QUEUE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_QUEUE_PVT" authid DEFINER as
-- $Header: OKCRQUES.pls 120.0 2005/05/27 05:18:39 appldev noship $
  event_queue_name    varchar2(61);
  outcome_queue_name  varchar2(61);
  -- this function is used to resolve subscriber rule during enqueue and dequeue
  FUNCTION get_acn_type (p_corrid  IN  VARCHAR2) RETURN VARCHAR2;
end;

 

/

  GRANT EXECUTE ON "APPS"."OKC_QUEUE_PVT" TO "AQ_ADMINISTRATOR_ROLE";
  GRANT EXECUTE ON "APPS"."OKC_QUEUE_PVT" TO "OKC";
