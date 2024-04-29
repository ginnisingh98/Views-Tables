--------------------------------------------------------
--  DDL for Package IGW_AWARD_PARTICULARS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_AWARD_PARTICULARS_PKG" AUTHID CURRENT_USER as
--$Header: igwprsus.pls 115.9 2002/11/14 18:38:20 vmedikon ship $

  PROCEDURE get_award_costs (i_award_id   in NUMBER,
                             i_proposal_id  in  NUMBER,
                             o_direct_cost  out NOCOPY  NUMBER,
                             o_total_cost out NOCOPY NUMBER);

  PROCEDURE get_old_award_costs (i_award_id   in NUMBER,
                                 o_direct_cost  out NOCOPY  NUMBER,
                                 o_total_cost out NOCOPY NUMBER);

  PROCEDURE get_pi (i_award_id   in NUMBER,
                    i_proposal_id  in  NUMBER,
                    o_pi_id  out NOCOPY  NUMBER,
                    o_pi_name out NOCOPY VARCHAR2);


END IGW_AWARD_PARTICULARS_PKG;

 

/
