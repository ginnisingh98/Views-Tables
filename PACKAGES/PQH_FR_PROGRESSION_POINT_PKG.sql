--------------------------------------------------------
--  DDL for Package PQH_FR_PROGRESSION_POINT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_PROGRESSION_POINT_PKG" AUTHID CURRENT_USER as
/* $Header: pqfrpspp.pkh 120.0 2005/05/29 01:53:32 appldev noship $ */

PROCEDURE update_sal_rate_for_point(p_spinal_point_id in number,
                                    p_parent_spine_id in number,
                                    p_information_category in varchar2,
                                    p_information1    in varchar2,
                                    p_information1_o  in varchar2,
                                    p_information2    in varchar2,
                                    p_information2_o  in varchar2);

END pqh_fr_progression_point_pkg;

 

/
