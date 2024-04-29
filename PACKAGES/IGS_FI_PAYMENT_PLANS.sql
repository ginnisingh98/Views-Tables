--------------------------------------------------------
--  DDL for Package IGS_FI_PAYMENT_PLANS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_PAYMENT_PLANS" AUTHID CURRENT_USER AS
/* $Header: IGSFI87S.pls 120.0 2005/06/03 15:51:26 appldev noship $ */

/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL body for package: IGS_FI_PAYMENT_PLANS                    |
 |                                                                       |
 | NOTES                                                                 |
 | New Package created for Payment Plans concurrent processes.           |
 | Enh # 3045007                                                         |
 | HISTORY                                                               |
 | Who             When            What                                  |
 | vvutukur       27-Aug-2003     Creation of the package.               |
 *=======================================================================*/

  PROCEDURE activate_plan(errbuf                  OUT NOCOPY VARCHAR2,
                          retcode                 OUT NOCOPY NUMBER,
                          p_n_person_id_grp       IN  igs_pe_persid_group_all.group_id%TYPE,
                          p_v_fee_period          IN  VARCHAR2 DEFAULT NULL,
                          p_n_offset_days         IN  NUMBER DEFAULT NULL
                          );
  ------------------------------------------------------------------
  --Created by  : vvutukur, Oracle IDC
  --Date created: 04-Sep-2003
  --
  --Purpose:  Concurrent process that activates the Payment Plans
  --          that are in a planned status for the Student.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  PROCEDURE assign_students(errbuf                  OUT NOCOPY VARCHAR2,
                            retcode                 OUT NOCOPY NUMBER,
                            p_v_payment_plan_name   IN  igs_fi_pp_templates.payment_plan_name%TYPE,
                            p_n_person_id_grp       IN  igs_pe_persid_group_all.group_id%TYPE,
                            p_v_start_date          IN  VARCHAR2,
                            p_v_fee_period          IN  VARCHAR2 DEFAULT NULL
                            );
  ------------------------------------------------------------------
  --Created by  : vvutukur, Oracle IDC
  --Date created: 04-Sep-2003
  --
  --Purpose:  Concurrent process that assigns a Payment Plan to a Student.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  PROCEDURE close_status(errbuf                  OUT NOCOPY VARCHAR2,
                         retcode                 OUT NOCOPY NUMBER,
                         p_n_tolerance_threshold IN  NUMBER,
                         p_n_person_id_grp       IN  igs_pe_persid_group_all.group_id%TYPE DEFAULT NULL,
                         p_v_test_mode           IN  VARCHAR2
			 );
  ------------------------------------------------------------------
  --Created by  : vvutukur, Oracle IDC
  --Date created: 27-Aug-2003
  --
  --Purpose:  Concurrent process that closes the Student ACTIVE Payment Plans.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
END igs_fi_payment_plans;

 

/
