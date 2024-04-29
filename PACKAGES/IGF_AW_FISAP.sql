--------------------------------------------------------
--  DDL for Package IGF_AW_FISAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_FISAP" AUTHID CURRENT_USER AS
/* $Header: IGFAW11S.pls 115.4 2002/11/28 10:54:55 nsidana noship $ */

          /*
	  ||  Created By : Prabhat.Patel@Oracle.com
	  ||  Created On : 1-NOV-2001
	  ||  Purpose : This is the driving procedure for the concurrent job
	  ||            'Aggregate Matching'
	  ||  Known limitations, enhancements or remarks :
	  ||  Change History :
	  ||  Who             When            What
	  ||  (reverse chronological order - newest change first)
	  */
          PROCEDURE aggregate_match(
                             errbuf			OUT NOCOPY		VARCHAR2,
                             retcode			OUT NOCOPY		NUMBER,
                             p_award_year               IN              VARCHAR2,
                             p_sum_type                 IN              VARCHAR2,
                             p_org_id                   IN              NUMBER
                             );

END igf_aw_fisap;

 

/
