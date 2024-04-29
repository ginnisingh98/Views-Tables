--------------------------------------------------------
--  DDL for Package BIM_TARGET_SEGMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_TARGET_SEGMENT_PKG" AUTHID CURRENT_USER AS
/* $Header: bimtrgts.pls 115.2 2000/01/07 16:16:05 pkm ship  $ */

FUNCTION target_segment_fk(p_customer_id number,
                           p_source_code varchar2) RETURN NUMBER;

END BIM_TARGET_SEGMENT_PKG;

 

/
