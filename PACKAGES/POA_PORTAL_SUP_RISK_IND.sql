--------------------------------------------------------
--  DDL for Package POA_PORTAL_SUP_RISK_IND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_PORTAL_SUP_RISK_IND" AUTHID CURRENT_USER AS
/*$Header: poapsrds.pls 115.2 2002/01/24 16:19:03 pkm ship      $ */
FUNCTION get_target_level_id return number;
FUNCTION get_range1_low(ID in Number) return number;
FUNCTION get_range1_high(ID in Number) return number;
FUNCTION get_range2_low(ID in Number) return number;
FUNCTION get_range2_high(ID in Number) return number;
FUNCTION get_range3_low(ID in Number) return number;
FUNCTION get_range3_high(ID in Number) return number;

end;

 

/
