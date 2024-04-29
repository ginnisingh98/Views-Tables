--------------------------------------------------------
--  DDL for Package PER_GET_ASG_POS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_GET_ASG_POS" AUTHID CURRENT_USER AS
/* $Header: pegetpos.pkh 120.0.12010000.1 2009/08/17 05:47:32 sidsaxen noship $ */
  function start_date (p_assignment_id  in number,
                        p_position_id   in number,
                        p_effective_start_date in date,
                        p_effective_end_date  in date) return date;
  pragma restrict_references(start_date, WNPS, WNDS);
  --
  function end_date (p_assignment_id    in number,
                        p_position_id   in number,
                        p_effective_start_date in date,
                        p_effective_end_date in date) return date;
 -- pragma restrict_references(end_date, WNPS, WNDS);
end per_get_asg_pos;

/
