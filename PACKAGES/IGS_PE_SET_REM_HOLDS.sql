--------------------------------------------------------
--  DDL for Package IGS_PE_SET_REM_HOLDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_SET_REM_HOLDS" AUTHID CURRENT_USER AS
/* $Header: IGSPE08S.pls 115.5 2002/11/29 01:51:11 nsidana noship $ */

  ------------------------------------------------------------------
  --Created by  : Sanil Madathil, Oracle IDC
  --Date created: 21-SEP-2001
  --
  --Purpose: Package specification contains definition of procedures
  --         set_prsid_grp_holds and rel_prsid_grp_holds
  --
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --pkpatel     7-OCT-2002      Bug No: 2600842
  --                            Removed the parameter p_authorising_id from both set_prsid_grp_holds and rel_prsid_grp_holds
  -------------------------------------------------------------------

  PROCEDURE set_prsid_grp_holds ( errbuf           OUT NOCOPY VARCHAR2                                         ,
                                  retcode          OUT NOCOPY NUMBER                                           ,
                                  p_hold_type      IN  igs_pe_pers_encumb_v.encumbrance_type%TYPE       ,
                                  p_pid_group      IN  igs_pe_persid_group_v.group_id%TYPE              ,
                                  p_start_dt       IN  VARCHAR2                                         ,
                                  p_term           IN  VARCHAR2                                         ,
                                  p_org_id         IN  NUMBER
                                 ) ;

  PROCEDURE rel_prsid_grp_holds ( errbuf           OUT NOCOPY VARCHAR2                                         ,
                                  retcode          OUT NOCOPY NUMBER                                           ,
                                  p_hold_type      IN  igs_pe_pers_encumb_v.encumbrance_type%TYPE       ,
                                  p_pid_group      IN  igs_pe_persid_group_v.group_id%TYPE              ,
                                  p_start_dt       IN  VARCHAR2                                         ,
                                  p_expiry_dt      IN  VARCHAR2                                         ,
                                  p_term           IN  VARCHAR2                                         ,
                                  p_org_id         IN  NUMBER
                                 ) ;

END igs_pe_set_rem_holds ;

 

/
