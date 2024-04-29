--------------------------------------------------------
--  DDL for Package ONT_ORDERSUMMARY_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_ORDERSUMMARY_UTIL" AUTHID CURRENT_USER AS
/* $Header: ontosvas.pls 120.0 2005/06/01 01:07:10 appldev noship $ */
  FUNCTION get_value_descr(p_structure_code IN VARCHAR2,
                           p_segment_number IN NUMBER,
                           p_value IN VARCHAR2) RETURN VARCHAR2;
END ont_ordersummary_util;

 

/
