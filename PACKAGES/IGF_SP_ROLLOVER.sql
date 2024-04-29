--------------------------------------------------------
--  DDL for Package IGF_SP_ROLLOVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SP_ROLLOVER" AUTHID CURRENT_USER AS
/* $Header: IGFSP02S.pls 115.1 2002/11/28 14:36:09 nsidana noship $ */

  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 24 Jan 2002
  --
  --Purpose: Package  Specification for sponsor fund rollover and sponsor student
  --         relation rollover process
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  PROCEDURE sponsor_rollover ( errbuf           OUT NOCOPY VARCHAR2                             ,
                               retcode          OUT NOCOPY NUMBER                               ,
                               p_award_year     IN  VARCHAR2                             ,
                               p_rollover       IN  VARCHAR2                             ,
                               p_fund_id        IN  igf_aw_fund_mast_all.fund_id%TYPE    ,
                               p_run_mode       IN  VARCHAR2 DEFAULT 'Y'
                           ) ;


END igf_sp_rollover ;

 

/
