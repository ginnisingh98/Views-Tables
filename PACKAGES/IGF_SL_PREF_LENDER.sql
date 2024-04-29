--------------------------------------------------------
--  DDL for Package IGF_SL_PREF_LENDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_PREF_LENDER" AUTHID CURRENT_USER AS
/* $Header: IGFSL21S.pls 115.0 2003/09/14 13:40:47 bkkumar noship $ */

  /*************************************************************
  Created By : bkkumar
  Date Created On : 05-SEP-2003
  Purpose : FA 122 Loans Enhancements
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/



 PROCEDURE main (
                  errbuf          OUT NOCOPY VARCHAR2,
                  retcode         OUT NOCOPY NUMBER,
                  p_pergrp_id     IN         NUMBER,
                  p_rel_code      IN         VARCHAR2,
                  p_start_date    IN         VARCHAR2,
                  p_update        IN         VARCHAR2

                 );
END igf_sl_pref_lender;

 

/
