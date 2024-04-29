--------------------------------------------------------
--  DDL for Package IGS_FI_PRC_HOLDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_PRC_HOLDS" AUTHID CURRENT_USER AS
/* $Header: IGSFI67S.pls 120.1 2005/10/10 08:16:10 appldev ship $ */

/***************************************************************
   Created By           :       bayadav
   Date Created By      :       29-Nov-2001
   Purpose              : Process for batch application of holdsfor a person / group of persons / all persons
                and release of holds for a  person / group of persons / all persons
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who         When           What
   smadathi    28-Aug-2003    Enh Bug 3045007. Removed the parameter P_OFFSET_DAYS from
                              procedure finp_apply_holds.
   pathipat    12-Aug-2003    Enh 3076768 - Automatic Release of Holds
                              Added procedure finp_auto_release_holds()
   pathipat    25-Feb-2003    Enh:2747341 - Additional Security for Holds build
                              Removed parameter p_auth_person_id in proc finp_apply_holds
 ***************************************************************/


--procedure for batch application of holdsfor a person / group of persons / all persons
PROCEDURE finp_apply_holds(errbuf              OUT NOCOPY    VARCHAR2,
                          retcode                    OUT NOCOPY    NUMBER,
                          p_person_id          IN     igs_pe_person_v.person_id%TYPE         DEFAULT NULL,
                          p_person_id_group    IN     igs_pe_persid_group_v.group_id%TYPE    DEFAULT NULL,
                          P_process_start_date IN     VARCHAR2 ,
                          P_process_end_date   IN     VARCHAR2 ,
                          P_hold_plan_name     IN     Igs_fi_hold_plan.hold_plan_name%Type,
                          P_fee_period         IN     VARCHAR2,
                          P_test_run           IN     VARCHAR2 DEFAULT 'Y' );

--procedure for batch release of holds on a person / group of persons / all persons .It can be called from form or as concurrent process by wrapper prcedure
PROCEDURE finp_release_holds_main(p_person_id         IN     igs_pe_person.person_id%TYPE         DEFAULT NULL,
                                 p_person_id_group    IN     igs_pe_persid_group_v.group_id%TYPE   DEFAULT NULL,
                                 P_hold_plan_name     IN     Igs_fi_hold_plan.hold_plan_name%TYPE  DEFAULT NULL,
                                 P_test_run           IN     VARCHAR2 DEFAULT 'Y',
                                 P_message_name       OUT NOCOPY    fnd_new_messages.message_name%TYPE);

--Wrapper procedure to call above procedure for release holds on a person / group of persons / all persons
PROCEDURE  finp_release_holds(  errbuf               OUT NOCOPY    VARCHAR2,
                                retcode              OUT NOCOPY    NUMBER,
                                p_person_id          IN     igs_pe_person.person_id%TYPE       ,
                                p_person_id_group    IN     igs_pe_persid_group_v.group_id%TYPE ,
                                P_hold_plan_name     IN     Igs_fi_hold_plan.hold_plan_name%Type,
                                P_test_run           IN     VARCHAR2 )     ;

-- Wrapper procedure invoked to automatically release holds when a student makes a credit payment
-- through Self Service or through the Receipts form.
PROCEDURE finp_auto_release_holds ( p_person_id              IN NUMBER,
                                    p_hold_plan_level        IN VARCHAR2,
                                    p_release_credit_id      IN NUMBER,
                                    p_run_application        IN VARCHAR2,
                                    p_message_name           OUT NOCOPY VARCHAR2
                                   );

END igs_fi_prc_holds;

 

/
