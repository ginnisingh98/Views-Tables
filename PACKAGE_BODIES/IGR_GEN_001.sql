--------------------------------------------------------
--  DDL for Package Body IGR_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGR_GEN_001" AS
/* $Header: IGSRT01B.pls 120.2 2006/01/31 23:48:59 rghosh noship $ */

 /****************************************************************************
  Created By : RBODDU
  Date Created On : 12-FEB-2003
  Purpose : 2664699

  Change History
  Who         When           What
  sjlaport    07-Mar-2005    Modified for APC - bug #3799487
  sjlaport    17-Feb-2005    Added Function Admp_Del_Eap_Eitpi and Admp_Ins_Eap_Eitpi
                             for IGR Migration
  hreddych    26-may-2003    Capture Event Campaign
                             Added the x_source_promotion_id in the call to
                             igr_inquiry_pkg
  rghosh      10-May-2005    Removed the procedure update_mailed_dt_inq_info and
                             replaced the calls to the proceure update_mailed_dt_inq_info
			     with update_mailed_dt. This is the new functionality
			     from the bug 4354270

  (reverse chronological order - newest change first)
  *****************************************************************************/

PROCEDURE admp_upd_eap_avail(
  errbuf OUT NOCOPY VARCHAR2,
  retcode OUT NOCOPY NUMBER,
  p_process_status IN VARCHAR2 ,
  p_package_unavailable IN VARCHAR2 ,
  p_package_incomplete IN VARCHAR2 ,
  p_responsible_user IN NUMBER,
  p_default_user IN NUMBER,
  p_inq_src_type IN VARCHAR2,
  p_product_category_id  IN  NUMBER ,
  p_inq_date_low  IN  VARCHAR2 ,
  p_inq_date_high  IN  VARCHAR2 ,
  p_inq_info_type IN igr_i_info_types_v.info_type_id%TYPE )  -- New param added as part of IDOPA2
IS
/****************************************************************************
  Created By :
  Date Created On :
  Purpose :

  Change History
  Who          When            What
  pkpatel      04-JUN-2001     Erased the parameter p_inquiry_date and added parameters to
                               select person records as per the date range and according to
                               Inquiry source type and Inquiry Entry Status
  pkpatel      13-JUN-2001     Modified the parameter p_inq_entry_stat_id from Mandatory to Default
  nshee        13-JAN-2003     As part of fix for bug 2645948, Inquiry source type is not to be a mandatory parameter.
                               Changed definition of cursor c_eap_es
  sjlaport     07-MAR-2005     Changed definition of cursor c_eap_es for APC - bug #3799487
  *****************************************************************************/

        --declared variable to convert from VARCHAR2 to DATE
        p_enquiry_dt_high  DATE;
        p_enquiry_dt_low   DATE;

BEGIN   -- admp_upd_eap_avail
        -- This module processes all enquiry appl which do not have a system status
        -- of COMPLETE. Depending on the availability of package items, it may update
        -- the IGS_IN_ENQUIRY_APPL.enquiry_status to one of the following system statuses.
        -- * Registered to Complete     If all package items are available.
        -- * Registered to Acknowledge  If none or some of the package items are
        --                              available.
        -- * Acknowledge to Complete    If all unsent package items are available.
        -- * Acknowledge (no change)    If none or some of the unsent package items
        --                              are available.

	-- The following code is added for disabling of OSS in R12.IGS.A - Bug 4955201
        igs_ge_gen_003.set_org_id(null);

        retcode := 0;
        --Converted the variables from VARCHAR2 to DATE
        p_enquiry_dt_high        :=       IGS_GE_DATE.IGSDATE(p_inq_date_high);
        p_enquiry_dt_low         :=       IGS_GE_DATE.IGSDATE(p_inq_date_low);

        -- To check whether the Entered High date is smaller than Entered Low Date
        -- And if yes stop the Processing.
        IF p_enquiry_dt_high < p_enquiry_dt_low THEN
                FND_MESSAGE.SET_NAME('IGS','IGS_AD_DATE_VALIDATION');
                IGS_GE_MSG_STACK.ADD;
                APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
DECLARE
        cst_acknowlege          CONSTANT        VARCHAR2(30) := 'OSS_ACKNOWLEGE';
        cst_complete            CONSTANT        VARCHAR2(30) := 'OSS_COMPLETE';
        cst_registered          CONSTANT        VARCHAR2(30) := 'OSS_REGISTERED';
        cst_both                CONSTANT        VARCHAR2(5) := 'BOTH';
        v_person_id                             igr_i_appl_all.person_id%TYPE;
        v_enquiry_appl_number                   igr_i_appl_all.enquiry_appl_number%TYPE;
        v_process_ind                           igr_i_appl_all.override_process_ind%TYPE;
        v_complete_status                       igr_i_status_v.enquiry_status%TYPE;
        v_acknowledge_status                    igr_i_status_v.enquiry_status%TYPE;
        v_group_id                              igs_pe_persid_group.group_id%TYPE;
        v_person_id_group_created               VARCHAR2(1);
        v_process_dt                            DATE;
        v_enquiries_processed                   NUMBER DEFAULT 0;
        v_enquiries_completed                   NUMBER DEFAULT 0;
        v_enquiries_acknowledged                NUMBER DEFAULT 0;
        v_dummy                                 VARCHAR2(1);
        e_resource_busy         EXCEPTION;
    l_ret_status       VARCHAR2(3);
        l_msg_data         VARCHAR2(3000);
        l_msg_count        NUMBER;
    l_s_enq_stat       igr_i_appl_v.s_enquiry_status%TYPE;
        PRAGMA EXCEPTION_INIT (e_resource_busy, -54);

	v_group_cd igs_pe_persid_group_all.group_cd%TYPE;

        -- Modified the following cursor as part of build of CRM recruitment changes. Bug: 2664699
    CURSOR c_es (cp_enquiry_status as_statuses_vl.status_code%TYPE) IS
        SELECT  es.enquiry_status
        FROM    igr_i_status_v es
        WHERE   es.s_enquiry_status  = cp_enquiry_status AND
                es.enabled_flag = 'Y';

        --Changed the Cursor to check the Enquiry_date between low and high date AND Enquiry source type
        --and Enquiry Entry status passed are valid for the Persons. Modified the following cursor as part of CRM recruitment
        --changes. Bug: 2664699
          CURSOR c_eap_es (cp_s_enquiry_status  as_statuses_vl.status_code%TYPE) IS
            SELECT  eap.*
            FROM    igr_i_appl  eap,
                    igr_i_status_v  es
            WHERE   ((eap.enquiry_dt  >= p_enquiry_dt_low  OR p_enquiry_dt_low IS NULL) AND
                     (eap.enquiry_dt  <= p_enquiry_dt_high OR p_enquiry_dt_high IS NULL)) AND
                    eap.enquiry_status       = es.enquiry_status AND
                    es.s_enquiry_status      = cp_s_enquiry_status AND
                    (eap.inquiry_method_code  = p_inq_src_type  OR p_inq_src_type IS NULL) AND
                    (p_product_category_id IS NULL OR  EXISTS (SELECT 'X' FROM igr_i_a_lines_v alin
                                                               WHERE alin.person_id       = eap.person_id AND
                                                               alin.enquiry_appl_number = eap.enquiry_appl_number AND
                                                               alin.product_category_id = p_product_category_id )) AND
                    (p_inq_info_type IS NULL OR EXISTS (SELECT 'X' FROM igr_i_a_itype ityp
                                                        WHERE ityp.person_id = eap.person_id AND
                                                        ityp.enquiry_appl_number = eap.enquiry_appl_number AND
                                                        ityp.info_type_id = p_inq_info_type))
                    FOR UPDATE OF eap.enquiry_status, eap.last_process_dt NOWAIT;


      --Cursor to check if there are any unsent (Mailed Date Null) available for the current Inquiry Instance.
      --Modified the cursor to fetch the Inquiry Instances having at least Package Item's Mailed Date as NULL. Bug:2664699
          CURSOR c_eapmpi ( cp_person_id            igr_i_a_pkgitm.person_id%TYPE,
                            cp_enquiry_appl_number  igr_i_a_pkgitm.enquiry_appl_number%TYPE) IS
                SELECT  'X'
                FROM    igr_i_a_pkgitm eapmpi,
                        igr_i_pkg_items_v  epi
                WHERE   eapmpi.person_id                = cp_person_id AND
                        eapmpi.enquiry_appl_number      = cp_enquiry_appl_number AND
                        eapmpi.mailed_dt   IS NULL AND
                        eapmpi.package_item_id          = epi.package_item_id ;


        -- Modified the following cursor as part of build of CRM recruitment changes. Bug: 2664699
    -- Modified to verify the Non-Availability of package item depending on the available date range.
      CURSOR c_eapmpi_epi ( cp_person_id            igr_i_a_pkgitm.person_id%TYPE,
                                cp_enquiry_appl_number  igr_i_a_pkgitm.enquiry_appl_number%TYPE) IS
                SELECT  'X'
                FROM    igr_i_a_pkgitm eapmpi,
                        igr_i_pkg_items_v  epi
                WHERE   eapmpi.person_id                = cp_person_id AND
                        eapmpi.enquiry_appl_number      = cp_enquiry_appl_number AND
                        eapmpi.mailed_dt   IS NULL AND
                        eapmpi.package_item_id          = epi.package_item_id AND
                        (epi.actual_avail_from_date > SYSDATE OR
                        epi.actual_avail_to_date  < SYSDATE);

        -- Modified the following cursor as part of build of CRM recruitment changes. Bug: 2664699
    -- Modified to verify the Availability of package item depending on the available date range.
          CURSOR c_eapmpi_get_epi ( cp_person_id        igr_i_a_pkgitm.person_id%TYPE,
                                    cp_enquiry_appl_number  igr_i_a_pkgitm.enquiry_appl_number%TYPE) IS
                SELECT  'X'
                FROM    igr_i_a_pkgitm eapmpi,
                        igr_i_pkg_items_v  epi
                WHERE   eapmpi.person_id                = cp_person_id AND
                        eapmpi.enquiry_appl_number      = cp_enquiry_appl_number AND
                        eapmpi.mailed_dt   IS NULL AND
                        eapmpi.package_item_id          = epi.package_item_id AND
                        (epi.actual_avail_from_date <= SYSDATE) AND
                        (epi.actual_avail_to_date  >= SYSDATE) AND
                         NVL(eapmpi.donot_mail_ind,'N') = 'N';


   /** IDOPA2 New cursors added to take care of package items if p_inq_info_type is not null **/

        -- Modified the following cursor as part of build of CRM recruitment changes. Bug: 2664699
          CURSOR c_pkgitems_exist (
                                cp_person_id            igr_i_a_pkgitm.person_id%TYPE,
                                cp_enquiry_appl_number  igr_i_a_pkgitm.enquiry_appl_number%TYPE) IS
                SELECT  'X'
                FROM         igr_i_a_pkgitm     eapmpi, --Transaction table holding Package items of the inquiry instance
                             igr_i_pkg_items_v  epi --Setup (joined with CRM setup to hold all the attributes of Packge Items)
                WHERE   eapmpi.person_id           = cp_person_id AND
                        eapmpi.enquiry_appl_number = cp_enquiry_appl_number AND
                        eapmpi.mailed_dt IS NULL AND
                        eapmpi.package_item_id   = epi.package_item_id AND
            NVL(eapmpi.donot_mail_ind,'N') = 'N' ;

          --Cursor to fetch the inquiry instances having the UNSENT (Mailed Date as NULL) package items for the
      --given enquiry instance. Added as part of Bug: 2664699
          CURSOR c_pkgitems_exist_more (
                                cp_person_id            igr_i_a_pkgitm.person_id%TYPE,
                                cp_enquiry_appl_number  igr_i_a_pkgitm.enquiry_appl_number%TYPE) IS
                SELECT  'X'
                FROM         igr_i_a_pkgitm     eapmpi, --Transaction table (Inquiry Instance table holding Package items)
                             igr_i_pkg_items_v  epi
                WHERE   eapmpi.person_id           = cp_person_id AND
                        eapmpi.enquiry_appl_number = cp_enquiry_appl_number AND
                        eapmpi.mailed_dt IS NULL AND
                        eapmpi.package_item_id   = epi.package_item_id AND
                        (epi.actual_avail_from_date <= SYSDATE) AND
                        (epi.actual_avail_to_date  >= SYSDATE) AND
            NVL(eapmpi.donot_mail_ind,'N') = 'N' ;

       -- Modified the following cursor as part of build of CRM recruitment changes. Bug: 2664699
       -- The following cursor if returns Row(s) then it means that the corresponding Package Item(s) are Available.
       CURSOR c_pkgitems_avail (
                                cp_person_id            igr_i_a_pkgitm.person_id%TYPE,
                                cp_enquiry_appl_number  igr_i_a_pkgitm.enquiry_appl_number%TYPE)  IS
                SELECT  'X'
                FROM            igr_i_a_pkgitm    eapmpi,
                                igr_i_pkg_items_v     epi
                WHERE   eapmpi.person_id             = cp_person_id AND
                        eapmpi.enquiry_appl_number   = cp_enquiry_appl_number AND
                        eapmpi.mailed_dt IS NULL AND
                        eapmpi.package_item_id  = epi.package_item_id AND
                        (epi.actual_avail_from_date > SYSDATE OR --Checks for UNAVAILABLE condition.
                         epi.actual_avail_to_date   <  SYSDATE);

        --Cursor to get the AVAILABLE package Items for the given Inquiry Instance.Bug: 2664699
        CURSOR c_pkgitems_get_avail (
                                cp_person_id            igr_i_a_pkgitm.person_id%TYPE,
                                cp_enquiry_appl_number  igr_i_a_pkgitm.enquiry_appl_number%TYPE)  IS
                SELECT  'X'
                FROM            igr_i_a_pkgitm    eapmpi,
                                igr_i_pkg_items_v     epi
                WHERE   eapmpi.person_id             = cp_person_id AND
                        eapmpi.enquiry_appl_number   = cp_enquiry_appl_number AND
                        eapmpi.mailed_dt IS NULL AND
                        eapmpi.package_item_id  = epi.package_item_id AND
                        (epi.actual_avail_from_date <= SYSDATE) AND --Checks for UNAVAILABLE condition.
                        (epi.actual_avail_to_date   >= SYSDATE) AND
                         NVL(eapmpi.donot_mail_ind,'N') = 'N';

        --Cursor to get the group code of the Person ID Group for a given group id (rghosh, bug#3973942: APC Integration Build)
	CURSOR c_get_group_cd(cp_group_id IGS_PE_PERSID_GROUP_ALL.GROUP_ID%TYPE) IS
	       SELECT group_cd
	       FROM igs_pe_persid_group_all
	       WHERE group_id = cp_group_id;


   /** IDOPA2 New cursors added to take care of package items if p_inq_info_type is not null **/

        PROCEDURE update_mailed_dt (
                p_person_id             igr_i_a_pkgitm.person_id%TYPE,
                p_enquiry_appl_number   igr_i_a_pkgitm.enquiry_appl_number%TYPE,
                p_mailed_dt             igr_i_a_pkgitm.mailed_dt%TYPE)
        IS
        /****************************************************************************
          Created By :
          Date Created On :
          Purpose :

          Change History
          Who             When            What
          (reverse chronological order - newest change first)
          *****************************************************************************/
        BEGIN   -- update_mailed_dt
                -- This procedure updates the mailed date of available packaged items.
        DECLARE

        -- Modified the following cursor as part of build of CRM recruitment changes. Bug: 2664699
                  CURSOR c_eapmpi_epi IS
                        SELECT  eapmpi.ROWID, eapmpi.*
                        FROM    igr_i_a_pkgitm    eapmpi,
                                igr_i_pkg_items_v epi -- Package Items setup view
                        WHERE   eapmpi.person_id                = p_person_id AND
                                eapmpi.enquiry_appl_number      = p_enquiry_appl_number AND
                                eapmpi.mailed_dt                IS NULL AND
                                eapmpi.package_item_id     = epi.package_item_id AND
                                (epi.actual_avail_from_date <= SYSDATE) AND
                                (epi.actual_avail_to_date  >= SYSDATE) AND
                                NVL(eapmpi.donot_mail_ind,'N') = 'N'
                        FOR UPDATE OF eapmpi.mailed_dt NOWAIT;

            l_ret_status VARCHAR2(3);
            l_msg_data   VARCHAR2(2000);
            l_msg_count  NUMBER;
            l_action     VARCHAR2(255);
             BEGIN
                FOR rec_igs_in_applml_pkgitm IN c_eapmpi_epi LOOP

                        igr_i_a_pkgitm_pkg.update_row (
                        X_Mode                              => 'R',
                        X_RowId                             => rec_igs_in_applml_pkgitm.rowid,
                        X_Person_Id                         => rec_igs_in_applml_pkgitm.person_id,
                        X_Enquiry_Appl_Number               => rec_igs_in_applml_pkgitm.enquiry_appl_number,
                        X_Package_Item_id                   => rec_igs_in_applml_pkgitm.package_item_id,
                        X_Mailed_Dt                         => p_mailed_dt,
            X_donot_mail_ind                    => 'Y',
            x_action                            => l_action,
                        x_ret_status                        => l_ret_status,
                        x_msg_data                          => l_msg_data,
                        x_msg_count                         => l_msg_count
                );

                END LOOP;
             EXCEPTION
                WHEN e_resource_busy THEN
                        IF c_eapmpi_epi%ISOPEN THEN
                                CLOSE c_eapmpi_epi;
                        END IF;
                        FND_MESSAGE.SET_NAME('IGS','IGS_AD_CANPRC_CURUPD_USER');
                        IGS_GE_MSG_STACK.ADD;
                    APP_EXCEPTION.RAISE_EXCEPTION;
                WHEN OTHERS THEN
                        IF c_eapmpi_epi%ISOPEN THEN
                                CLOSE c_eapmpi_epi;
                        END IF;
                        app_exception.raise_exception;
             END;
        EXCEPTION
                WHEN OTHERS THEN
            Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
            Fnd_Message.Set_Token('NAME','IGS_AD_GEN_012.update_mailed_dt');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
        END update_mailed_dt;

    /***********New local procedure added as part of IDOPA2 to update mailed_dt in case of inq_info_type not null ******/
        PROCEDURE create_person_id_group_secur (
                pl_group_id     IGS_PE_PRSID_GRP_SEC.group_id%TYPE)
        IS
        /****************************************************************************
          Created By :
          Date Created On :
          Purpose :

          Change History
          Who             When            What
          (reverse chronological order - newest change first)
         *****************************************************************************/

        BEGIN   -- create_person_id_group_secur
                -- After creating the IGS_PE_PERSID_GROUP record, create a security record giving
                -- select access on it, to the default user specified in the parameters..
        DECLARE
        lv_rowid        VARCHAR2(25);
        BEGIN
                IF p_default_user IS NOT NULL THEN
                igs_pe_prsid_grp_sec_pkg.insert_row (
                        X_Mode                              => 'R',
                        X_RowId                             => lv_rowid,
                        X_Group_Id                          => pl_group_id,
                        X_Person_Id                         => p_default_user,
                        X_Insert_Ind                        => 'N',
                        X_Update_Ind                        => 'N',
                        X_Delete_Ind                        => 'N'
                );

                END IF;
        END;
        EXCEPTION
                WHEN OTHERS THEN
            Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
            Fnd_Message.Set_Token('NAME','IGS_AD_GEN_012.create_person_id_group_secur');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
        END create_person_id_group_secur;

        FUNCTION create_person_id_group(p_responsible_user IN NUMBER)
        RETURN NUMBER
        IS
        /****************************************************************************
          Created By :
          Date Created On :
          Purpose :

          Change History
          Who             When            What
          (reverse chronological order - newest change first)
         *****************************************************************************/

        BEGIN   -- create_person_id_group
        DECLARE
        l_group_cd igs_pe_persid_group.group_cd%TYPE;
        l_req_id NUMBER;

                -- cst_adm_enquiry         CONSTANT        VARCHAR2(10) := 'ADM_ENQY';
        -- kamohan Bug 2382418
        -- Changed from ADMISSION ENQUIRY to ADMISSION INQUIRY

        cst_admission_enquiry   CONSTANT        VARCHAR2(20) := 'ADMISSION INQUIRY';
                v_user_id               IGS_PE_PERSON.person_id%TYPE;
                v_group_id              IGS_PE_PERSID_GROUP.group_id%TYPE;
                lv_rowid                VARCHAR2(25);
                l_org_id NUMBER(15);
                CURSOR c_get_next_seq IS
                        SELECT  IGS_PE_PERSID_GROUP_GP_ID_S.NEXTVAL
                        FROM    DUAL;
           BEGIN
        l_req_id := FND_GLOBAL.CONC_REQUEST_ID();
        l_group_cd := igs_ad_gen_012.ret_group_cd();
                -- Get the current user ID
                v_user_id := p_responsible_user;
                -- Get the next sequence number for the primary key
                OPEN c_get_next_seq;
                FETCH c_get_next_seq INTO v_group_id;
                CLOSE c_get_next_seq;
             l_org_id := igs_ge_gen_003.get_org_id;
             igs_pe_persid_group_pkg.Insert_Row (
                X_Mode                              => 'R',
                X_RowId                             => lv_rowid,
                X_Group_Id                          => v_group_id,
                X_Group_Cd                          => l_group_cd,
                X_Creator_Person_Id                 => v_user_id,
                X_Description                       => cst_admission_enquiry || '-' ||IGS_GE_NUMBER.TO_CANN ( l_req_id),
                X_Create_Dt                         => SYSDATE,
                X_Closed_Ind                        => 'N',
                X_Comments                          => Null ,
                X_Org_Id                            => l_org_id
                );

                -- Since create IGS_PE_PERSID_GROUP is called several times and
                -- create_person_id_group is used in each case.  It made sense to have the
                -- call actually in the create IGS_PE_PERSID_GROUP procedure.
                -- After creating the IGS_PE_PERSID_GROUP record, create a security record giving
                -- select access on it, to the default user specified in the parameters..
                create_person_id_group_secur(v_group_id);
                -- Note : p_group_id is an output parameter which returns the group_id so
                -- that it can be used to trigger other jobs.  This parameter has been
                -- removed for now, as it was causing problems in the parameter form.
                -- To be re-instated if functionality evolves in the future which allows
                -- output parameters to be used as input to other jobs in JBS.
                -- p_group_id := v_group_id;
                RETURN v_group_id;
           EXCEPTION
                WHEN OTHERS THEN
                        IF c_get_next_seq%ISOPEN THEN
                                CLOSE c_get_next_seq;
                        END IF;
                        app_exception.raise_exception;
           END;
        EXCEPTION
                WHEN OTHERS THEN
            Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
            Fnd_Message.Set_Token('NAME','IGS_AD_GEN_012.create_person_id_group');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
        END create_person_id_group;

        PROCEDURE create_person_id_group_member (
                p_group_id      igs_pe_prsid_grp_mem.group_id%TYPE,
                p_person_id     igs_pe_prsid_grp_mem.person_id%TYPE) IS
        /****************************************************************************
          Created By :
          Date Created On :
          Purpose :

          Change History
          Who             When            What
          (reverse chronological order - newest change first)
          *****************************************************************************/
        BEGIN
        DECLARE
                v_user_id               igs_pe_person.person_id%TYPE;
                v_group_id              igs_pe_persid_group.group_id%TYPE;
                lv_rowid        VARCHAR2(25);
                l_org_id NUMBER(15);
                CURSOR c_pigm (
                                cp_group_id     igs_pe_persid_group.group_id%TYPE,
                                cp_person_id    igs_pe_person.person_id%TYPE) IS
                        SELECT  'X'
                        FROM    igs_pe_prsid_grp_mem    pigm
                        WHERE   pigm.group_id   = cp_group_id AND
                                pigm.person_id  = cp_person_id AND
                                NVL(TRUNC(start_date),TRUNC(SYSDATE)) <= TRUNC(SYSDATE) AND
                                NVL(TRUNC(end_date),TRUNC(SYSDATE)) >= TRUNC(SYSDATE);
        BEGIN   -- create_person_id_group_member
                OPEN c_pigm(
                        p_group_id,
                        p_person_id);
                FETCH c_pigm INTO v_dummy;
                IF c_pigm%NOTFOUND THEN -- IGS_PE_PERSON not already in group
                        CLOSE c_pigm;
                l_org_id := igs_ge_gen_003.get_org_id;
                IGS_PE_PRSID_GRP_MEM_Pkg.Insert_Row (
                        X_Mode                              => 'R',
                        X_RowId                             => lv_rowid,
                        X_Group_Id                          => p_group_id,
                        X_Person_Id                         => p_person_id,
                        X_START_DATE                        => TRUNC(SYSDATE),
                        X_END_DATE                          => null,
                        X_org_Id                            => l_org_id
                );

                ELSE                    -- person already in group
                        CLOSE c_pigm;
                END IF;
        EXCEPTION
                WHEN OTHERS THEN
                        IF c_pigm%ISOPEN THEN
                                CLOSE c_pigm;
                        END IF;
                        APP_EXCEPTION.RAISE_EXCEPTION;
        END;
        EXCEPTION
                WHEN OTHERS THEN
            Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
            Fnd_Message.Set_Token('NAME','IGS_AD_GEN_012.create_person_id_group_member');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
        END create_person_id_group_member;
BEGIN
        -- 1. Set default values for later processing
        -- Get default status values for system enquiry statuses 'OSS_COMPLETE' and
        -- 'OSS_ACKNOWLEGE'. There may be more than one status mapped to the system
        -- status, so select the first found in each case.
        OPEN c_es(cst_complete);
        FETCH c_es INTO v_complete_status;
        CLOSE c_es;

        OPEN c_es(cst_acknowlege);
        FETCH c_es INTO v_acknowledge_status;
        CLOSE c_es;

        v_person_id_group_created := 'N';
        -- Set the process date to sysdate to ensure all records processed have the
        -- same date placed into the last_process_dt field and the mailed_dt
        -- fields of the package items. This assists in the subsequent reporting
        -- process, as well as ensuring some records don't have a different date
        -- component if the day changes while the process is running.
        v_process_dt := TRUNC(SYSDATE);
        -- 2. Firstly process enquiries with a system status of 'OSS_ACKNOWLEGE'
        --    or 'BOTH'


        IF p_process_status IN (cst_acknowlege, cst_both) THEN
                FOR v_eap_es_rec IN c_eap_es(cst_acknowlege) LOOP
                        v_person_id := v_eap_es_rec.person_id;
                        v_enquiry_appl_number := v_eap_es_rec.enquiry_appl_number;
                        v_process_ind := v_eap_es_rec.override_process_ind;

                IF p_inq_info_type IS NOT NULL THEN

            --c_pkgitems_exist returns the Package Items defined for current Enquiry Instance,
            --which have Mailed Date as NULL.
                        OPEN c_pkgitems_exist(
                                        v_person_id,
                                        v_enquiry_appl_number);
                        FETCH c_pkgitems_exist INTO v_dummy;


                        IF c_pkgitems_exist%NOTFOUND THEN  -- No items defined, no action required.
                           CLOSE c_pkgitems_exist;
                        ELSE -- Package Items for the given Inquiry Instance and Information Type Exist.
                           CLOSE c_pkgitems_exist;


                                -- c_pkgitems_avail returns ROW(S) if there are any UNAVAILABLE package items
                -- are there which are unsent (Mailed Date NULL) for the current Inquiry Instance
                                OPEN  c_pkgitems_avail(
                                                v_person_id,
                                                v_enquiry_appl_number);

                                FETCH c_pkgitems_avail INTO v_dummy;

                                -- First, check if atleast one UNSENT package Item is UNAVAILABLE
                                IF c_pkgitems_avail%NOTFOUND THEN  --NO package items found which are UNAVAILABLE. This means items are available

                                        CLOSE c_pkgitems_avail;

                                                --Update the Mailed Date of all the avaikable package items, to process date
                                                update_mailed_dt(
                                                        v_person_id,
                                                        v_enquiry_appl_number,
                                                        v_process_dt);

                                                IF v_person_id_group_created = 'N' THEN
                                                        v_group_id := create_person_id_group(p_responsible_user);
                                                        v_person_id_group_created := 'Y';
                                                END IF;
                                                create_person_id_group_member(
                                                                v_group_id,
                                                                v_person_id);

                                --Check if there are any additional package items available for current Inquiry Instance
                --which are unsent. Update the Inquiry Status accordingly.
                                                OPEN c_pkgitems_exist_more( v_person_id,
                                                                            v_enquiry_appl_number);
                                                FETCH c_pkgitems_avail INTO v_dummy;
                                IF c_pkgitems_exist_more%FOUND THEN
                                  l_s_enq_stat := cst_acknowlege;
                                ELSE
                                  l_s_enq_stat := cst_complete;
                                END IF;
                                CLOSE c_pkgitems_exist_more;
                                               v_enquiries_processed := v_enquiries_processed + 1;
                                              /* Update only the last process date and enquiry status as complete*/
                                               igr_inquiry_pkg.update_row (
                                                               x_rowid                     => v_eap_es_rec.Row_Id,
                                                               x_person_id                 => v_eap_es_rec.Person_Id,
                                                               x_enquiry_appl_number       => v_eap_es_rec.Enquiry_Appl_Number,
                                                               x_sales_lead_id             => v_eap_es_rec.sales_lead_id,
                                                               x_acad_cal_type             => v_eap_es_rec.Acad_Cal_Type,
                                                               x_acad_ci_sequence_number   => v_eap_es_rec.Acad_Ci_Sequence_Number,
                                                               x_adm_cal_type              => v_eap_es_rec.Adm_Cal_Type,
                                                               x_adm_ci_sequence_number    => v_eap_es_rec.Adm_Ci_Sequence_Number,
                                                               x_enquiry_dt                => v_eap_es_rec.Enquiry_Dt,
                                                               x_registering_person_id     => v_eap_es_rec.Registering_Person_Id,
                                                               x_override_process_ind      => v_eap_es_rec.Override_Process_Ind,
                                                               x_indicated_mailing_dt      => v_eap_es_rec.Indicated_Mailing_Dt,
                                                               x_last_process_dt           => v_process_dt,
                                                               x_comments                  => v_eap_es_rec.Comments,
                                                               x_org_id                    => v_eap_es_rec.org_id,
                                                               x_inq_entry_level_id        => v_eap_es_rec.Inq_Entry_Level_Id,
                                                               x_edu_goal_id               => v_eap_es_rec.Edu_Goal_Id,
                                                               x_party_id                  => v_eap_es_rec.Party_Id,
                                                               x_how_knowus_id             => v_eap_es_rec.How_Knowus_Id,
                                                               x_who_influenced_id         => v_eap_es_rec.Who_Influenced_Id,
                                                               x_attribute_category        => v_eap_es_rec.Attribute_Category,
                                                               x_attribute1                => v_eap_es_rec.Attribute1,
                                                               x_attribute2                => v_eap_es_rec.Attribute2,
                                                               x_attribute3                => v_eap_es_rec.Attribute3,
                                                               x_attribute4                => v_eap_es_rec.Attribute4,
                                                               x_attribute5                => v_eap_es_rec.Attribute5,
                                                               x_attribute6                => v_eap_es_rec.Attribute6,
                                                               x_attribute7                => v_eap_es_rec.Attribute7,
                                                               x_attribute8                => v_eap_es_rec.Attribute8,
                                                               x_attribute9                => v_eap_es_rec.Attribute9,
                                                               x_attribute10               => v_eap_es_rec.Attribute10,
                                                               x_attribute11               => v_eap_es_rec.Attribute11,
                                                               x_attribute12               => v_eap_es_rec.Attribute12,
                                                               x_attribute13               => v_eap_es_rec.Attribute13,
                                                               x_attribute14               => v_eap_es_rec.Attribute14,
                                                               x_attribute15               => v_eap_es_rec.Attribute15,
                                                               x_attribute16               => v_eap_es_rec.Attribute16,
                                                               x_attribute17               => v_eap_es_rec.Attribute17,
                                                               x_attribute18               => v_eap_es_rec.Attribute18,
                                                               x_attribute19               => v_eap_es_rec.Attribute19,
                                                               x_attribute20               => v_eap_es_rec.Attribute20,
                                                               x_s_enquiry_status          => l_s_enq_stat,
                                                               x_enabled_flag              => v_eap_es_rec.enabled_flag,
                                                               x_inquiry_method_code       => v_eap_es_rec.inquiry_method_code,
                                                               x_source_promotion_id       => v_eap_es_rec.source_promotion_id,
                                                               x_mode                      => 'R',
                                                               x_action                    => 'Upd',
                                                               x_ret_status                => l_ret_status,
                                                               x_msg_data                  => l_msg_data,
                                                               x_msg_count                 => l_msg_count,
							       x_pkg_reduct_ind            => v_eap_es_rec.pkg_reduct_ind
                                                             );
                                                          IF l_ret_status IN ('E','U') THEN
                                                            FND_FILE.PUT_LINE(FND_FILE.LOG,l_msg_data);
                                                          ELSE
                                                            v_enquiries_completed := v_enquiries_completed + 1;
                              END IF;

                                ELSE ---c_pkgitems_avail%FOUND. i.e atleast one Package Item is there which is UNAVAILABLE
                                                CLOSE c_pkgitems_avail;

                                                ---c_pkgitems_get_avail fetches the Package Items associated with current
                        -- Inquiry Instance, which are AVAILABLE.
                        OPEN c_pkgitems_get_avail(
                                                        v_person_id,
                                                        v_enquiry_appl_number);

                                                FETCH c_pkgitems_get_avail INTO v_dummy;
                                                -- Check if none of the package items are available
                                                IF c_pkgitems_get_avail%NOTFOUND THEN  -- No items are available
                                                   CLOSE c_pkgitems_get_avail;   -- Do nothing as in IDOPA2
                                                ELSE                            -- Some items are available
                                                   CLOSE c_pkgitems_get_avail;
                                                       IF NOT (p_package_incomplete = 'N' AND
                                                                v_process_ind = 'N') THEN

                                update_mailed_dt(
                                                                        v_person_id,
                                                                        v_enquiry_appl_number,
                                                                        v_process_dt);

                                                                IF v_person_id_group_created = 'N' THEN
                                                                        v_group_id := create_person_id_group(p_responsible_user);
                                                                        v_person_id_group_created := 'Y';
                                                                END IF;
                                                                        create_person_id_group_member(
                                                                                        v_group_id,
                                                                                        v_person_id);
                                                           /* Update The Enquiry Status obtained above and last process date of inquiry instance */
                                                           igr_inquiry_pkg.update_row (
                                                               x_rowid                     => v_eap_es_rec.Row_Id,
                                                               x_person_id                 => v_eap_es_rec.Person_Id,
                                                               x_enquiry_appl_number       => v_eap_es_rec.Enquiry_Appl_Number,
                                                               x_sales_lead_id             => v_eap_es_rec.sales_lead_id,
                                                               x_acad_cal_type             => v_eap_es_rec.Acad_Cal_Type,
                                                               x_acad_ci_sequence_number   => v_eap_es_rec.Acad_Ci_Sequence_Number,
                                                               x_adm_cal_type              => v_eap_es_rec.Adm_Cal_Type,
                                                               x_adm_ci_sequence_number    => v_eap_es_rec.Adm_Ci_Sequence_Number,
                                                               x_enquiry_dt                => v_eap_es_rec.Enquiry_Dt,
                                                               x_registering_person_id     => v_eap_es_rec.Registering_Person_Id,
                                                               x_override_process_ind      => v_eap_es_rec.Override_Process_Ind,
                                                               x_indicated_mailing_dt      => v_eap_es_rec.Indicated_Mailing_Dt,
                                                               x_last_process_dt           => v_process_dt,
                                                               x_comments                  => v_eap_es_rec.Comments,
                                                               x_org_id                    => v_eap_es_rec.org_id,
                                                               x_inq_entry_level_id        => v_eap_es_rec.Inq_Entry_Level_Id,
                                                               x_edu_goal_id               => v_eap_es_rec.Edu_Goal_Id,
                                                               x_party_id                  => v_eap_es_rec.Party_Id,
                                                               x_how_knowus_id             => v_eap_es_rec.How_Knowus_Id,
                                                               x_who_influenced_id         => v_eap_es_rec.Who_Influenced_Id,
                                                               x_attribute_category        => v_eap_es_rec.Attribute_Category,
                                                               x_attribute1                => v_eap_es_rec.Attribute1,
                                                               x_attribute2                => v_eap_es_rec.Attribute2,
                                                               x_attribute3                => v_eap_es_rec.Attribute3,
                                                               x_attribute4                => v_eap_es_rec.Attribute4,
                                                               x_attribute5                => v_eap_es_rec.Attribute5,
                                                               x_attribute6                => v_eap_es_rec.Attribute6,
                                                               x_attribute7                => v_eap_es_rec.Attribute7,
                                                               x_attribute8                => v_eap_es_rec.Attribute8,
                                                               x_attribute9                => v_eap_es_rec.Attribute9,
                                                               x_attribute10               => v_eap_es_rec.Attribute10,
                                                               x_attribute11               => v_eap_es_rec.Attribute11,
                                                               x_attribute12               => v_eap_es_rec.Attribute12,
                                                               x_attribute13               => v_eap_es_rec.Attribute13,
                                                               x_attribute14               => v_eap_es_rec.Attribute14,
                                                               x_attribute15               => v_eap_es_rec.Attribute15,
                                                               x_attribute16               => v_eap_es_rec.Attribute16,
                                                               x_attribute17               => v_eap_es_rec.Attribute17,
                                                               x_attribute18               => v_eap_es_rec.Attribute18,
                                                               x_attribute19               => v_eap_es_rec.Attribute19,
                                                               x_attribute20               => v_eap_es_rec.Attribute20,
                                                               x_s_enquiry_status          => v_eap_es_rec.s_enquiry_status,
                                                               x_enabled_flag              => v_eap_es_rec.enabled_flag,
                                                               x_inquiry_method_code       => v_eap_es_rec.inquiry_method_code,
                                                               x_source_promotion_id       => v_eap_es_rec.source_promotion_id,
                                                               x_mode                      => 'R',
                                                               x_action                    => 'Upd',
                                                               x_ret_status                => l_ret_status,
                                                               x_msg_data                  => l_msg_data,
                                                               x_msg_count                 => l_msg_count,
							       x_pkg_reduct_ind            => v_eap_es_rec.pkg_reduct_ind
                                                             );
                                                            IF l_ret_status IN ('E','U') THEN
                                                              FND_FILE.PUT_LINE(FND_FILE.LOG,l_msg_data);
                                END IF;
                                                        END IF;
                                          END IF;
                        END IF;
                     END IF;


                ELSIF p_inq_info_type IS  NULL THEN
                        /** This IF section has Original code -only change :: update if donot_mail_ind= 'N'- see cursor in update_mailed_dt*/

                        -- Check if enquiry has any package items defined.
                        -- If not, no processing is required.
                        OPEN c_eapmpi(
                                        v_person_id,
                                        v_enquiry_appl_number);
                        FETCH c_eapmpi INTO v_dummy;

                        IF c_eapmpi%NOTFOUND THEN  -- No Package items defined, no action required.
                                CLOSE c_eapmpi;
                        ELSE
                                CLOSE c_eapmpi;

                        -- For each record found check the availability of unsent package items
                        -- First, check if ALL required package items are available

                        OPEN c_eapmpi_epi(
                                        v_person_id,
                                        v_enquiry_appl_number);

                        FETCH c_eapmpi_epi INTO v_dummy;
                        IF c_eapmpi_epi%NOTFOUND THEN   -- No items found which are NOT in the Available Dates range.
                                            -- means that All items are available (checks on available From/To dates)
                                CLOSE c_eapmpi_epi;
                                update_mailed_dt(
                                                v_person_id,
                                                v_enquiry_appl_number,
                                                v_process_dt);

                                IF v_person_id_group_created = 'N' THEN
                                        v_group_id := create_person_id_group(p_responsible_user);
                                        v_person_id_group_created := 'Y';
                                END IF;
                                        create_person_id_group_member(
                                                                v_group_id,
                                                                v_person_id);
                                                           v_enquiries_processed := v_enquiries_processed + 1;
                                                          /* Update only the last process date and enquiry status as complete*/
                                                           igr_inquiry_pkg.update_row (
                                                               x_rowid                     => v_eap_es_rec.Row_Id,
                                                               x_person_id                 => v_eap_es_rec.Person_Id,
                                                               x_enquiry_appl_number       => v_eap_es_rec.Enquiry_Appl_Number,
                                                               x_sales_lead_id             => v_eap_es_rec.sales_lead_id,
                                                               x_acad_cal_type             => v_eap_es_rec.Acad_Cal_Type,
                                                               x_acad_ci_sequence_number   => v_eap_es_rec.Acad_Ci_Sequence_Number,
                                                               x_adm_cal_type              => v_eap_es_rec.Adm_Cal_Type,
                                                               x_adm_ci_sequence_number    => v_eap_es_rec.Adm_Ci_Sequence_Number,
                                                               x_enquiry_dt                => v_eap_es_rec.Enquiry_Dt,
                                                               x_registering_person_id     => v_eap_es_rec.Registering_Person_Id,
                                                               x_override_process_ind      => v_eap_es_rec.Override_Process_Ind,
                                                               x_indicated_mailing_dt      => v_eap_es_rec.Indicated_Mailing_Dt,
                                                               x_last_process_dt           => v_process_dt,
                                                               x_comments                  => v_eap_es_rec.Comments,
                                                               x_org_id                    => v_eap_es_rec.org_id,
                                                               x_inq_entry_level_id        => v_eap_es_rec.Inq_Entry_Level_Id,
                                                               x_edu_goal_id               => v_eap_es_rec.Edu_Goal_Id,
                                                               x_party_id                  => v_eap_es_rec.Party_Id,
                                                               x_how_knowus_id             => v_eap_es_rec.How_Knowus_Id,
                                                               x_who_influenced_id         => v_eap_es_rec.Who_Influenced_Id,
                                                               x_attribute_category        => v_eap_es_rec.Attribute_Category,
                                                               x_attribute1                => v_eap_es_rec.Attribute1,
                                                               x_attribute2                => v_eap_es_rec.Attribute2,
                                                               x_attribute3                => v_eap_es_rec.Attribute3,
                                                               x_attribute4                => v_eap_es_rec.Attribute4,
                                                               x_attribute5                => v_eap_es_rec.Attribute5,
                                                               x_attribute6                => v_eap_es_rec.Attribute6,
                                                               x_attribute7                => v_eap_es_rec.Attribute7,
                                                               x_attribute8                => v_eap_es_rec.Attribute8,
                                                               x_attribute9                => v_eap_es_rec.Attribute9,
                                                               x_attribute10               => v_eap_es_rec.Attribute10,
                                                               x_attribute11               => v_eap_es_rec.Attribute11,
                                                               x_attribute12               => v_eap_es_rec.Attribute12,
                                                               x_attribute13               => v_eap_es_rec.Attribute13,
                                                               x_attribute14               => v_eap_es_rec.Attribute14,
                                                               x_attribute15               => v_eap_es_rec.Attribute15,
                                                               x_attribute16               => v_eap_es_rec.Attribute16,
                                                               x_attribute17               => v_eap_es_rec.Attribute17,
                                                               x_attribute18               => v_eap_es_rec.Attribute18,
                                                               x_attribute19               => v_eap_es_rec.Attribute19,
                                                               x_attribute20               => v_eap_es_rec.Attribute20,
                                                               x_s_enquiry_status          => cst_complete,
                                                               x_enabled_flag              => v_eap_es_rec.enabled_flag,
                                                               x_inquiry_method_code       => v_eap_es_rec.inquiry_method_code,
                                                               x_source_promotion_id       => v_eap_es_rec.source_promotion_id,
                                                               x_mode                      => 'R',
                                                               x_action                    => 'Upd',
                                                               x_ret_status                => l_ret_status,
                                                               x_msg_data                  => l_msg_data,
                                                               x_msg_count                 => l_msg_count,
							       x_pkg_reduct_ind            => v_eap_es_rec.pkg_reduct_ind
                                                             );
                                                            IF l_ret_status IN ('E','U') THEN
                                                              FND_FILE.PUT_LINE(FND_FILE.LOG,l_msg_data);
                                ELSE
                                                              v_enquiries_completed := v_enquiries_completed + 1;
                                END IF;
                        ELSE --c_eapmpi_epi%FOUND
                                CLOSE c_eapmpi_epi;

                                -- c_eapmpi_get_epi returns Package Items defined for current Inquiry Instance which are AVAILABLE.
                                OPEN c_eapmpi_get_epi(
                                        v_person_id,
                                        v_enquiry_appl_number);

                                FETCH c_eapmpi_get_epi INTO v_dummy;

                -- Check if none of the package items are available
                IF c_eapmpi_get_epi%NOTFOUND THEN   -- No items are available
                                   CLOSE c_eapmpi_get_epi;   -- Do nothing as in IDOPA2 (also before)

                                ELSE -- Some items are available

                                        CLOSE c_eapmpi_get_epi;
                                        IF NOT (p_package_incomplete = 'N' AND
                                                v_process_ind = 'N') THEN

                                                update_mailed_dt(
                                                                v_person_id,
                                                                v_enquiry_appl_number,
                                                                v_process_dt);

                                                IF v_person_id_group_created = 'N' THEN
                                                        v_group_id := create_person_id_group(p_responsible_user);
                                                        v_person_id_group_created := 'Y';
                                                END IF;
                                                create_person_id_group_member(
                                                                        v_group_id,
                                                                        v_person_id);

                               /* Update only the last process date */
                                                           igr_inquiry_pkg.update_row (
                                                               x_rowid                     => v_eap_es_rec.Row_Id,
                                                               x_person_id                 => v_eap_es_rec.Person_Id,
                                                               x_enquiry_appl_number       => v_eap_es_rec.Enquiry_Appl_Number,
                                                               x_sales_lead_id             => v_eap_es_rec.sales_lead_id,
                                                               x_acad_cal_type             => v_eap_es_rec.Acad_Cal_Type,
                                                               x_acad_ci_sequence_number   => v_eap_es_rec.Acad_Ci_Sequence_Number,
                                                               x_adm_cal_type              => v_eap_es_rec.Adm_Cal_Type,
                                                               x_adm_ci_sequence_number    => v_eap_es_rec.Adm_Ci_Sequence_Number,
                                                               x_enquiry_dt                => v_eap_es_rec.Enquiry_Dt,
                                                               x_registering_person_id     => v_eap_es_rec.Registering_Person_Id,
                                                               x_override_process_ind      => v_eap_es_rec.Override_Process_Ind,
                                                               x_indicated_mailing_dt      => v_eap_es_rec.Indicated_Mailing_Dt,
                                                               x_last_process_dt           => v_process_dt,
                                                               x_comments                  => v_eap_es_rec.Comments,
                                                               x_org_id                    => v_eap_es_rec.org_id,
                                                               x_inq_entry_level_id        => v_eap_es_rec.Inq_Entry_Level_Id,
                                                               x_edu_goal_id               => v_eap_es_rec.Edu_Goal_Id,
                                                               x_party_id                  => v_eap_es_rec.Party_Id,
                                                               x_how_knowus_id             => v_eap_es_rec.How_Knowus_Id,
                                                               x_who_influenced_id         => v_eap_es_rec.Who_Influenced_Id,
                                                               x_attribute_category        => v_eap_es_rec.Attribute_Category,
                                                               x_attribute1                => v_eap_es_rec.Attribute1,
                                                               x_attribute2                => v_eap_es_rec.Attribute2,
                                                               x_attribute3                => v_eap_es_rec.Attribute3,
                                                               x_attribute4                => v_eap_es_rec.Attribute4,
                                                               x_attribute5                => v_eap_es_rec.Attribute5,
                                                               x_attribute6                => v_eap_es_rec.Attribute6,
                                                               x_attribute7                => v_eap_es_rec.Attribute7,
                                                               x_attribute8                => v_eap_es_rec.Attribute8,
                                                               x_attribute9                => v_eap_es_rec.Attribute9,
                                                               x_attribute10               => v_eap_es_rec.Attribute10,
                                                               x_attribute11               => v_eap_es_rec.Attribute11,
                                                               x_attribute12               => v_eap_es_rec.Attribute12,
                                                               x_attribute13               => v_eap_es_rec.Attribute13,
                                                               x_attribute14               => v_eap_es_rec.Attribute14,
                                                               x_attribute15               => v_eap_es_rec.Attribute15,
                                                               x_attribute16               => v_eap_es_rec.Attribute16,
                                                               x_attribute17               => v_eap_es_rec.Attribute17,
                                                               x_attribute18               => v_eap_es_rec.Attribute18,
                                                               x_attribute19               => v_eap_es_rec.Attribute19,
                                                               x_attribute20               => v_eap_es_rec.Attribute20,
                                                               x_s_enquiry_status          => v_eap_es_rec.s_enquiry_status,
                                                               x_enabled_flag              => v_eap_es_rec.enabled_flag,
                                                               x_inquiry_method_code       => v_eap_es_rec.inquiry_method_code,
                                                               x_source_promotion_id       => v_eap_es_rec.source_promotion_id,
                                                               x_mode                      => 'R',
                                                               x_action                    => 'Upd',
                                                               x_ret_status                => l_ret_status,
                                                               x_msg_data                  => l_msg_data,
                                                               x_msg_count                 => l_msg_count,
							       x_pkg_reduct_ind            => v_eap_es_rec.pkg_reduct_ind
                                                             );
                                                            IF l_ret_status IN ('E','U') THEN
                                                              FND_FILE.PUT_LINE(FND_FILE.LOG,l_msg_data);
                                END IF;
                                        END IF;
                                END IF;
                        END IF;
                     END IF;

                  END IF; -- p_inq_info_type IS NULL / NOT NULL --Newly added for IDOPA2
                END LOOP; -- For loopin in c_eap_es
        END IF; -- For Acknowledge or both


        -- 3. Now, process enquiries with a system status of 'REGISTERED'
        --    or 'BOTH'
        -- 3. Now, process enquiries with a system status of 'REGISTERED'
        --    or 'BOTH'


        IF p_process_status IN (cst_registered,cst_both) THEN  --(1)

                FOR v_eap_es_rec IN c_eap_es(cst_registered) LOOP   --Loop 1
                        v_person_id := v_eap_es_rec.person_id;
                        v_enquiry_appl_number := v_eap_es_rec.enquiry_appl_number;
                        v_process_ind := v_eap_es_rec.override_process_ind;

                IF  p_inq_info_type IS NOT NULL THEN  /** All new code as part of IDOOPA2 */ --(2)
                        -- Check if enquiry has any package items defined.  If not, no
                        -- processing is required.
                        OPEN c_pkgitems_exist(
                                        v_person_id,
                                        v_enquiry_appl_number);
                        FETCH c_pkgitems_exist INTO v_dummy;
                        IF c_pkgitems_exist%NOTFOUND THEN       -- No items defined, no action required. --(3)
                           CLOSE c_pkgitems_exist;
                        ELSE -- Package Items defined for the Inquiry Instance
                           CLOSE c_pkgitems_exist;
                          -- For each record found check the availability of unsent package items
                          -- First, check if ALL required package items are available

                           OPEN c_pkgitems_avail(
                                        v_person_id,
                                        v_enquiry_appl_number);
                           FETCH c_pkgitems_avail INTO v_dummy;

               IF c_pkgitems_avail%NOTFOUND THEN       -- All items are available --(4)
                                CLOSE c_pkgitems_avail;
                                update_mailed_dt(
                                                v_person_id,
                                                v_enquiry_appl_number,
                                                v_process_dt);

                                IF v_person_id_group_created = 'N' THEN --(5)

                                        v_group_id := create_person_id_group(p_responsible_user);
                                        v_person_id_group_created := 'Y';
                                END IF; --(5)


                                create_person_id_group_member(
                                                        v_group_id,
                                                        v_person_id);
                                                             OPEN c_pkgitems_exist_more( v_person_id,
                                                                                         v_enquiry_appl_number);
                                                             FETCH c_pkgitems_exist_more INTO v_dummy;
                                                             IF c_pkgitems_exist_more%FOUND THEN
                                                l_s_enq_stat := cst_acknowlege;
                                                             ELSE
                                                                l_s_enq_stat := cst_complete;
                                                             END IF;
                                                             CLOSE c_pkgitems_exist_more;

                                                           v_enquiries_processed := v_enquiries_processed + 1;
                                                           igr_inquiry_pkg.update_row (
                                                               x_rowid                     => v_eap_es_rec.Row_Id,
                                                               x_person_id                 => v_eap_es_rec.Person_Id,
                                                               x_enquiry_appl_number       => v_eap_es_rec.Enquiry_Appl_Number,
                                                               x_sales_lead_id             => v_eap_es_rec.sales_lead_id,
                                                               x_acad_cal_type             => v_eap_es_rec.Acad_Cal_Type,
                                                               x_acad_ci_sequence_number   => v_eap_es_rec.Acad_Ci_Sequence_Number,
                                                               x_adm_cal_type              => v_eap_es_rec.Adm_Cal_Type,
                                                               x_adm_ci_sequence_number    => v_eap_es_rec.Adm_Ci_Sequence_Number,
                                                               x_enquiry_dt                => v_eap_es_rec.Enquiry_Dt,
                                                               x_registering_person_id     => v_eap_es_rec.Registering_Person_Id,
                                                               x_override_process_ind      => v_eap_es_rec.Override_Process_Ind,
                                                               x_indicated_mailing_dt      => v_eap_es_rec.Indicated_Mailing_Dt,
                                                               x_last_process_dt           => v_process_dt,
                                                               x_comments                  => v_eap_es_rec.Comments,
                                                               x_org_id                    => v_eap_es_rec.org_id,
                                                               x_inq_entry_level_id        => v_eap_es_rec.Inq_Entry_Level_Id,
                                                               x_edu_goal_id               => v_eap_es_rec.Edu_Goal_Id,
                                                               x_party_id                  => v_eap_es_rec.Party_Id,
                                                               x_how_knowus_id             => v_eap_es_rec.How_Knowus_Id,
                                                               x_who_influenced_id         => v_eap_es_rec.Who_Influenced_Id,
                                                               x_attribute_category        => v_eap_es_rec.Attribute_Category,
                                                               x_attribute1                => v_eap_es_rec.Attribute1,
                                                               x_attribute2                => v_eap_es_rec.Attribute2,
                                                               x_attribute3                => v_eap_es_rec.Attribute3,
                                                               x_attribute4                => v_eap_es_rec.Attribute4,
                                                               x_attribute5                => v_eap_es_rec.Attribute5,
                                                               x_attribute6                => v_eap_es_rec.Attribute6,
                                                               x_attribute7                => v_eap_es_rec.Attribute7,
                                                               x_attribute8                => v_eap_es_rec.Attribute8,
                                                               x_attribute9                => v_eap_es_rec.Attribute9,
                                                               x_attribute10               => v_eap_es_rec.Attribute10,
                                                               x_attribute11               => v_eap_es_rec.Attribute11,
                                                               x_attribute12               => v_eap_es_rec.Attribute12,
                                                               x_attribute13               => v_eap_es_rec.Attribute13,
                                                               x_attribute14               => v_eap_es_rec.Attribute14,
                                                               x_attribute15               => v_eap_es_rec.Attribute15,
                                                               x_attribute16               => v_eap_es_rec.Attribute16,
                                                               x_attribute17               => v_eap_es_rec.Attribute17,
                                                               x_attribute18               => v_eap_es_rec.Attribute18,
                                                               x_attribute19               => v_eap_es_rec.Attribute19,
                                                               x_attribute20               => v_eap_es_rec.Attribute20,
                                                               x_s_enquiry_status          => l_s_enq_stat,
                                                               x_enabled_flag              => v_eap_es_rec.enabled_flag,
                                                               x_inquiry_method_code       => v_eap_es_rec.inquiry_method_code,
                                                               x_source_promotion_id       => v_eap_es_rec.source_promotion_id,
                                                               x_mode                      => 'R',
                                                               x_action                    => 'Upd',
                                                               x_ret_status                => l_ret_status,
                                                               x_msg_data                  => l_msg_data,
                                                               x_msg_count                 => l_msg_count,
							       x_pkg_reduct_ind            => v_eap_es_rec.pkg_reduct_ind
                                                             );

                                                            IF l_ret_status IN ('E','U') THEN
                                                              FND_FILE.PUT_LINE(FND_FILE.LOG,l_msg_data);
                                ELSE
                                                              IF l_s_enq_stat = cst_complete THEN
                                                                v_enquiries_completed := v_enquiries_completed + 1;
                                                              ELSIF l_s_enq_stat =  cst_acknowlege THEN
                                                                v_enquiries_acknowledged := v_enquiries_acknowledged +1;
                                                              END IF;
                                END IF;

                           ELSE --(4) All items available y/n (At least one Package Item is UNAVAILABLE.
                                CLOSE c_pkgitems_avail;
                                -- Check if none of the package items are available
                                OPEN c_pkgitems_get_avail(
                                        v_person_id,
                                        v_enquiry_appl_number);

                                FETCH c_pkgitems_get_avail INTO v_dummy;
                                IF c_pkgitems_get_avail%NOTFOUND THEN       -- No items are available
                                        CLOSE c_pkgitems_get_avail;
                                        IF p_package_unavailable = 'Y' THEN     -- Process anyway
                                                IF v_person_id_group_created = 'N' THEN
                                                        v_group_id := create_person_id_group(p_responsible_user);
                                                        v_person_id_group_created := 'Y';
                                                END IF;
                                                create_person_id_group_member(
                                                                        v_group_id,
                                                                        v_person_id);
                                                         --Update Process Date and Inquiry Status to 'Acknowledged'.
                                                         v_enquiries_processed := v_enquiries_processed + 1;
                                                         igr_inquiry_pkg.update_row (
                                                               x_rowid                     => v_eap_es_rec.Row_Id,
                                                               x_person_id                 => v_eap_es_rec.Person_Id,
                                                               x_enquiry_appl_number       => v_eap_es_rec.Enquiry_Appl_Number,
                                                               x_sales_lead_id             => v_eap_es_rec.sales_lead_id,
                                                               x_acad_cal_type             => v_eap_es_rec.Acad_Cal_Type,
                                                               x_acad_ci_sequence_number   => v_eap_es_rec.Acad_Ci_Sequence_Number,
                                                               x_adm_cal_type              => v_eap_es_rec.Adm_Cal_Type,
                                                               x_adm_ci_sequence_number    => v_eap_es_rec.Adm_Ci_Sequence_Number,
                                                               x_enquiry_dt                => v_eap_es_rec.Enquiry_Dt,
                                                               x_registering_person_id     => v_eap_es_rec.Registering_Person_Id,
                                                               x_override_process_ind      => v_eap_es_rec.Override_Process_Ind,
                                                               x_indicated_mailing_dt      => v_eap_es_rec.Indicated_Mailing_Dt,
                                                               x_last_process_dt           => v_process_dt,
                                                               x_comments                  => v_eap_es_rec.Comments,
                                                               x_org_id                    => v_eap_es_rec.org_id,
                                                               x_inq_entry_level_id        => v_eap_es_rec.Inq_Entry_Level_Id,
                                                               x_edu_goal_id               => v_eap_es_rec.Edu_Goal_Id,
                                                               x_party_id                  => v_eap_es_rec.Party_Id,
                                                               x_how_knowus_id             => v_eap_es_rec.How_Knowus_Id,
                                                               x_who_influenced_id         => v_eap_es_rec.Who_Influenced_Id,
                                                               x_attribute_category        => v_eap_es_rec.Attribute_Category,
                                                               x_attribute1                => v_eap_es_rec.Attribute1,
                                                               x_attribute2                => v_eap_es_rec.Attribute2,
                                                               x_attribute3                => v_eap_es_rec.Attribute3,
                                                               x_attribute4                => v_eap_es_rec.Attribute4,
                                                               x_attribute5                => v_eap_es_rec.Attribute5,
                                                               x_attribute6                => v_eap_es_rec.Attribute6,
                                                               x_attribute7                => v_eap_es_rec.Attribute7,
                                                               x_attribute8                => v_eap_es_rec.Attribute8,
                                                               x_attribute9                => v_eap_es_rec.Attribute9,
                                                               x_attribute10               => v_eap_es_rec.Attribute10,
                                                               x_attribute11               => v_eap_es_rec.Attribute11,
                                                               x_attribute12               => v_eap_es_rec.Attribute12,
                                                               x_attribute13               => v_eap_es_rec.Attribute13,
                                                               x_attribute14               => v_eap_es_rec.Attribute14,
                                                               x_attribute15               => v_eap_es_rec.Attribute15,
                                                               x_attribute16               => v_eap_es_rec.Attribute16,
                                                               x_attribute17               => v_eap_es_rec.Attribute17,
                                                               x_attribute18               => v_eap_es_rec.Attribute18,
                                                               x_attribute19               => v_eap_es_rec.Attribute19,
                                                               x_attribute20               => v_eap_es_rec.Attribute20,
                                                               x_s_enquiry_status          => cst_acknowlege,
                                                               x_enabled_flag              => v_eap_es_rec.enabled_flag,
                                                               x_inquiry_method_code       => v_eap_es_rec.inquiry_method_code,
                                                               x_source_promotion_id       => v_eap_es_rec.source_promotion_id,
                                                               x_mode                      => 'R',
                                                               x_action                    => 'Upd',
                                                               x_ret_status                => l_ret_status,
                                                               x_msg_data                  => l_msg_data,
                                                               x_msg_count                 => l_msg_count,
							       x_pkg_reduct_ind            => v_eap_es_rec.pkg_reduct_ind
                                                             );
                                                            IF l_ret_status IN ('E','U') THEN
                                                              FND_FILE.PUT_LINE(FND_FILE.LOG,l_msg_data);
                                ELSE
                                                              v_enquiries_acknowledged := v_enquiries_acknowledged + 1;
                                END IF;
                                        END IF;
                                ELSE  --c_pkgitems_get_avail%FOUND THEN
                                        CLOSE c_pkgitems_get_avail;
                                        IF NOT (p_package_incomplete = 'N' AND
                                                       v_process_ind = 'N') THEN

                                                update_mailed_dt(
                                                                v_person_id,
                                                                v_enquiry_appl_number,
                                                                v_process_dt);

                                                IF v_person_id_group_created = 'N' THEN
                                                        v_group_id := create_person_id_group(p_responsible_user);
                                                        v_person_id_group_created := 'Y';
                                                END IF;

                                                create_person_id_group_member(
                                                                        v_group_id,
                                                                        v_person_id);

                                                           v_enquiries_processed := v_enquiries_processed + 1;
                                                           -- Update the Last Process Date to current date and Inquiry Status to Acknowledged.
                                                           igr_inquiry_pkg.update_row (
                                                               x_rowid                     => v_eap_es_rec.Row_Id,
                                                               x_person_id                 => v_eap_es_rec.Person_Id,
                                                               x_enquiry_appl_number       => v_eap_es_rec.Enquiry_Appl_Number,
                                                               x_sales_lead_id             => v_eap_es_rec.sales_lead_id,
                                                               x_acad_cal_type             => v_eap_es_rec.Acad_Cal_Type,
                                                               x_acad_ci_sequence_number   => v_eap_es_rec.Acad_Ci_Sequence_Number,
                                                               x_adm_cal_type              => v_eap_es_rec.Adm_Cal_Type,
                                                               x_adm_ci_sequence_number    => v_eap_es_rec.Adm_Ci_Sequence_Number,
                                                               x_enquiry_dt                => v_eap_es_rec.Enquiry_Dt,
                                                               x_registering_person_id     => v_eap_es_rec.Registering_Person_Id,
                                                               x_override_process_ind      => v_eap_es_rec.Override_Process_Ind,
                                                               x_indicated_mailing_dt      => v_eap_es_rec.Indicated_Mailing_Dt,
                                                               x_last_process_dt           => v_process_dt,
                                                               x_comments                  => v_eap_es_rec.Comments,
                                                               x_org_id                    => v_eap_es_rec.org_id,
                                                               x_inq_entry_level_id        => v_eap_es_rec.Inq_Entry_Level_Id,
                                                               x_edu_goal_id               => v_eap_es_rec.Edu_Goal_Id,
                                                               x_party_id                  => v_eap_es_rec.Party_Id,
                                                               x_how_knowus_id             => v_eap_es_rec.How_Knowus_Id,
                                                               x_who_influenced_id         => v_eap_es_rec.Who_Influenced_Id,
                                                               x_attribute_category        => v_eap_es_rec.Attribute_Category,
                                                               x_attribute1                => v_eap_es_rec.Attribute1,
                                                               x_attribute2                => v_eap_es_rec.Attribute2,
                                                               x_attribute3                => v_eap_es_rec.Attribute3,
                                                               x_attribute4                => v_eap_es_rec.Attribute4,
                                                               x_attribute5                => v_eap_es_rec.Attribute5,
                                                               x_attribute6                => v_eap_es_rec.Attribute6,
                                                               x_attribute7                => v_eap_es_rec.Attribute7,
                                                               x_attribute8                => v_eap_es_rec.Attribute8,
                                                               x_attribute9                => v_eap_es_rec.Attribute9,
                                                               x_attribute10               => v_eap_es_rec.Attribute10,
                                                               x_attribute11               => v_eap_es_rec.Attribute11,
                                                               x_attribute12               => v_eap_es_rec.Attribute12,
                                                               x_attribute13               => v_eap_es_rec.Attribute13,
                                                               x_attribute14               => v_eap_es_rec.Attribute14,
                                                               x_attribute15               => v_eap_es_rec.Attribute15,
                                                               x_attribute16               => v_eap_es_rec.Attribute16,
                                                               x_attribute17               => v_eap_es_rec.Attribute17,
                                                               x_attribute18               => v_eap_es_rec.Attribute18,
                                                               x_attribute19               => v_eap_es_rec.Attribute19,
                                                               x_attribute20               => v_eap_es_rec.Attribute20,
                                                               x_s_enquiry_status          => cst_acknowlege,
                                                               x_enabled_flag              => v_eap_es_rec.enabled_flag,
                                                               x_inquiry_method_code       => v_eap_es_rec.inquiry_method_code,
                                                               x_source_promotion_id       => v_eap_es_rec.source_promotion_id,
                                                               x_mode                      => 'R',
                                                               x_action                    => 'Upd',
                                                               x_ret_status                => l_ret_status,
                                                               x_msg_data                  => l_msg_data,
                                                               x_msg_count                 => l_msg_count,
							       x_pkg_reduct_ind            => v_eap_es_rec.pkg_reduct_ind
                                                             );
                                                            IF l_ret_status IN ('E','U') THEN
                                                              FND_FILE.PUT_LINE(FND_FILE.LOG,l_msg_data);
                                ELSE
                                                              v_enquiries_acknowledged := v_enquiries_acknowledged + 1;
                                END IF;
                                        END IF; --Package incomplete
                                END IF; --No or some items
                        END IF; --(4) All items available y/n
                        END IF; --(3) -- For package items exists or not


                ELSIF p_inq_info_type IS  NULL THEN  /** Original code */

                        -- Check if enquiry has any package items defined.  If not, no
                        -- processing is required.
                        OPEN c_eapmpi(
                                        v_person_id,
                                        v_enquiry_appl_number);
                        FETCH c_eapmpi INTO v_dummy;
                        IF c_eapmpi%NOTFOUND THEN       -- No items defined, no action required.
                                CLOSE c_eapmpi;
                        ELSE   -- Package Items are defined for enquiry instance

                           CLOSE c_eapmpi;
                           -- For each record found check the availability of unsent package items
                           -- First, check if ALL required package items are available
                           OPEN c_eapmpi_epi(
                                        v_person_id,
                                        v_enquiry_appl_number);
                           FETCH c_eapmpi_epi INTO v_dummy;
                           IF c_eapmpi_epi%NOTFOUND THEN   -- All items are available

                              CLOSE c_eapmpi_epi;
                                update_mailed_dt(
                                                v_person_id,
                                                v_enquiry_appl_number,
                                                v_process_dt);
                                IF v_person_id_group_created = 'N' THEN
                                        v_group_id := create_person_id_group(p_responsible_user);
                                        v_person_id_group_created := 'Y';
                                END IF;
                                create_person_id_group_member(
                                                        v_group_id,
                                                        v_person_id);


                                                           v_enquiries_processed := v_enquiries_processed + 1;
                                                        /* Update only the last process date and enquiry status as complete*/
                                                           igr_inquiry_pkg.update_row (
                                                               x_rowid                     => v_eap_es_rec.Row_Id,
                                                               x_person_id                 => v_eap_es_rec.Person_Id,
                                                               x_enquiry_appl_number       => v_eap_es_rec.Enquiry_Appl_Number,
                                                               x_sales_lead_id             => v_eap_es_rec.sales_lead_id,
                                                               x_acad_cal_type             => v_eap_es_rec.Acad_Cal_Type,
                                                               x_acad_ci_sequence_number   => v_eap_es_rec.Acad_Ci_Sequence_Number,
                                                               x_adm_cal_type              => v_eap_es_rec.Adm_Cal_Type,
                                                               x_adm_ci_sequence_number    => v_eap_es_rec.Adm_Ci_Sequence_Number,
                                                               x_enquiry_dt                => v_eap_es_rec.Enquiry_Dt,
                                                               x_registering_person_id     => v_eap_es_rec.Registering_Person_Id,
                                                               x_override_process_ind      => v_eap_es_rec.Override_Process_Ind,
                                                               x_indicated_mailing_dt      => v_eap_es_rec.Indicated_Mailing_Dt,
                                                               x_last_process_dt           => v_process_dt,
                                                               x_comments                  => v_eap_es_rec.Comments,
                                                               x_org_id                    => v_eap_es_rec.org_id,
                                                               x_inq_entry_level_id        => v_eap_es_rec.Inq_Entry_Level_Id,
                                                               x_edu_goal_id               => v_eap_es_rec.Edu_Goal_Id,
                                                               x_party_id                  => v_eap_es_rec.Party_Id,
                                                               x_how_knowus_id             => v_eap_es_rec.How_Knowus_Id,
                                                               x_who_influenced_id         => v_eap_es_rec.Who_Influenced_Id,
                                                               x_attribute_category        => v_eap_es_rec.Attribute_Category,
                                                               x_attribute1                => v_eap_es_rec.Attribute1,
                                                               x_attribute2                => v_eap_es_rec.Attribute2,
                                                               x_attribute3                => v_eap_es_rec.Attribute3,
                                                               x_attribute4                => v_eap_es_rec.Attribute4,
                                                               x_attribute5                => v_eap_es_rec.Attribute5,
                                                               x_attribute6                => v_eap_es_rec.Attribute6,
                                                               x_attribute7                => v_eap_es_rec.Attribute7,
                                                               x_attribute8                => v_eap_es_rec.Attribute8,
                                                               x_attribute9                => v_eap_es_rec.Attribute9,
                                                               x_attribute10               => v_eap_es_rec.Attribute10,
                                                               x_attribute11               => v_eap_es_rec.Attribute11,
                                                               x_attribute12               => v_eap_es_rec.Attribute12,
                                                               x_attribute13               => v_eap_es_rec.Attribute13,
                                                               x_attribute14               => v_eap_es_rec.Attribute14,
                                                               x_attribute15               => v_eap_es_rec.Attribute15,
                                                               x_attribute16               => v_eap_es_rec.Attribute16,
                                                               x_attribute17               => v_eap_es_rec.Attribute17,
                                                               x_attribute18               => v_eap_es_rec.Attribute18,
                                                               x_attribute19               => v_eap_es_rec.Attribute19,
                                                               x_attribute20               => v_eap_es_rec.Attribute20,
                                                               x_s_enquiry_status          => cst_complete,
                                                               x_enabled_flag              => v_eap_es_rec.enabled_flag,
                                                               x_inquiry_method_code       => v_eap_es_rec.inquiry_method_code,
                                                               x_source_promotion_id       => v_eap_es_rec.source_promotion_id,
                                                               x_mode                      => 'R',
                                                               x_action                    => 'Upd',
                                                               x_ret_status                => l_ret_status,
                                                               x_msg_data                  => l_msg_data,
                                                               x_msg_count                 => l_msg_count,
							       x_pkg_reduct_ind            => v_eap_es_rec.pkg_reduct_ind
                                                             );
                                                            IF l_ret_status IN ('E','U') THEN
                                                              FND_FILE.PUT_LINE(FND_FILE.LOG,l_msg_data);
                                ELSE
                                                              v_enquiries_completed := v_enquiries_completed + 1;
                                END IF;

                                ELSE --c_eapmpi_epi%FOUND

                                  CLOSE c_eapmpi_epi;
                                  -- Check if none of the package items are available
                                  OPEN c_eapmpi_get_epi(
                                        v_person_id,
                                        v_enquiry_appl_number);
                                  FETCH c_eapmpi_get_epi INTO v_dummy;
                                  IF c_eapmpi_get_epi%NOTFOUND THEN   -- No items are available

                                        CLOSE c_eapmpi_get_epi;
                                        IF p_package_unavailable = 'Y' THEN     -- Process anyway
                                                IF v_person_id_group_created = 'N' THEN
                                                        v_group_id := create_person_id_group(p_responsible_user);
                                                        v_person_id_group_created := 'Y';
                                                END IF;
                                                create_person_id_group_member(
                                                                        v_group_id,
                                                                        v_person_id);

                                                     v_enquiries_processed := v_enquiries_processed + 1;
                                                     /* Update only the last process date */
                                                     igr_inquiry_pkg.update_row (
                                                               x_rowid                     => v_eap_es_rec.Row_Id,
                                                               x_person_id                 => v_eap_es_rec.Person_Id,
                                                               x_enquiry_appl_number       => v_eap_es_rec.Enquiry_Appl_Number,
                                                               x_sales_lead_id             => v_eap_es_rec.sales_lead_id,
                                                               x_acad_cal_type             => v_eap_es_rec.Acad_Cal_Type,
                                                               x_acad_ci_sequence_number   => v_eap_es_rec.Acad_Ci_Sequence_Number,
                                                               x_adm_cal_type              => v_eap_es_rec.Adm_Cal_Type,
                                                               x_adm_ci_sequence_number    => v_eap_es_rec.Adm_Ci_Sequence_Number,
                                                               x_enquiry_dt                => v_eap_es_rec.Enquiry_Dt,
                                                               x_registering_person_id     => v_eap_es_rec.Registering_Person_Id,
                                                               x_override_process_ind      => v_eap_es_rec.Override_Process_Ind,
                                                               x_indicated_mailing_dt      => v_eap_es_rec.Indicated_Mailing_Dt,
                                                               x_last_process_dt           => v_process_dt,
                                                               x_comments                  => v_eap_es_rec.Comments,
                                                               x_org_id                    => v_eap_es_rec.org_id,
                                                               x_inq_entry_level_id        => v_eap_es_rec.Inq_Entry_Level_Id,
                                                               x_edu_goal_id               => v_eap_es_rec.Edu_Goal_Id,
                                                               x_party_id                  => v_eap_es_rec.Party_Id,
                                                               x_how_knowus_id             => v_eap_es_rec.How_Knowus_Id,
                                                               x_who_influenced_id         => v_eap_es_rec.Who_Influenced_Id,
                                                               x_attribute_category        => v_eap_es_rec.Attribute_Category,
                                                               x_attribute1                => v_eap_es_rec.Attribute1,
                                                               x_attribute2                => v_eap_es_rec.Attribute2,
                                                               x_attribute3                => v_eap_es_rec.Attribute3,
                                                               x_attribute4                => v_eap_es_rec.Attribute4,
                                                               x_attribute5                => v_eap_es_rec.Attribute5,
                                                               x_attribute6                => v_eap_es_rec.Attribute6,
                                                               x_attribute7                => v_eap_es_rec.Attribute7,
                                                               x_attribute8                => v_eap_es_rec.Attribute8,
                                                               x_attribute9                => v_eap_es_rec.Attribute9,
                                                               x_attribute10               => v_eap_es_rec.Attribute10,
                                                               x_attribute11               => v_eap_es_rec.Attribute11,
                                                               x_attribute12               => v_eap_es_rec.Attribute12,
                                                               x_attribute13               => v_eap_es_rec.Attribute13,
                                                               x_attribute14               => v_eap_es_rec.Attribute14,
                                                               x_attribute15               => v_eap_es_rec.Attribute15,
                                                               x_attribute16               => v_eap_es_rec.Attribute16,
                                                               x_attribute17               => v_eap_es_rec.Attribute17,
                                                               x_attribute18               => v_eap_es_rec.Attribute18,
                                                               x_attribute19               => v_eap_es_rec.Attribute19,
                                                               x_attribute20               => v_eap_es_rec.Attribute20,
                                                               x_s_enquiry_status          => cst_acknowlege,
                                                               x_enabled_flag              => v_eap_es_rec.enabled_flag,
                                                               x_inquiry_method_code       => v_eap_es_rec.inquiry_method_code,
                                                               x_source_promotion_id       => v_eap_es_rec.source_promotion_id,
                                                               x_mode                      => 'R',
                                                               x_action                    => 'Upd',
                                                               x_ret_status                => l_ret_status,
                                                               x_msg_data                  => l_msg_data,
                                                               x_msg_count                 => l_msg_count,
							       x_pkg_reduct_ind            => v_eap_es_rec.pkg_reduct_ind
                                                             );
                                                            IF l_ret_status IN ('E','U') THEN
                                                              FND_FILE.PUT_LINE(FND_FILE.LOG,l_msg_data);
                                ELSE
                                                              v_enquiries_acknowledged := v_enquiries_acknowledged + 1;
                                END IF;
                                        END IF;
                                  ELSE  --c_eapmpi_get_epi%FOUND
                                        CLOSE c_eapmpi_get_epi;
                                        IF NOT (p_package_incomplete = 'N' AND
                                                        v_process_ind = 'N') THEN
                                                update_mailed_dt(
                                                                v_person_id,
                                                                v_enquiry_appl_number,
                                                                v_process_dt);

                                                IF v_person_id_group_created = 'N' THEN
                                                        v_group_id := create_person_id_group(p_responsible_user);
                                                        v_person_id_group_created := 'Y';
                                                END IF;

                                                create_person_id_group_member(
                                                                        v_group_id,
                                                                        v_person_id);

                                                           v_enquiries_processed := v_enquiries_processed + 1;
                            /* Update only the last process date and enquiry status as acknowlege*/
                                                            igr_inquiry_pkg.update_row (
                                                               x_rowid                     => v_eap_es_rec.Row_Id,
                                                               x_person_id                 => v_eap_es_rec.Person_Id,
                                                               x_enquiry_appl_number       => v_eap_es_rec.Enquiry_Appl_Number,
                                                               x_sales_lead_id             => v_eap_es_rec.sales_lead_id,
                                                               x_acad_cal_type             => v_eap_es_rec.Acad_Cal_Type,
                                                               x_acad_ci_sequence_number   => v_eap_es_rec.Acad_Ci_Sequence_Number,
                                                               x_adm_cal_type              => v_eap_es_rec.Adm_Cal_Type,
                                                               x_adm_ci_sequence_number    => v_eap_es_rec.Adm_Ci_Sequence_Number,
                                                               x_enquiry_dt                => v_eap_es_rec.Enquiry_Dt,
                                                               x_registering_person_id     => v_eap_es_rec.Registering_Person_Id,
                                                               x_override_process_ind      => v_eap_es_rec.Override_Process_Ind,
                                                               x_indicated_mailing_dt      => v_eap_es_rec.Indicated_Mailing_Dt,
                                                               x_last_process_dt           => v_process_dt,
                                                               x_comments                  => v_eap_es_rec.Comments,
                                                               x_org_id                    => v_eap_es_rec.org_id,
                                                               x_inq_entry_level_id        => v_eap_es_rec.Inq_Entry_Level_Id,
                                                               x_edu_goal_id               => v_eap_es_rec.Edu_Goal_Id,
                                                               x_party_id                  => v_eap_es_rec.Party_Id,
                                                               x_how_knowus_id             => v_eap_es_rec.How_Knowus_Id,
                                                               x_who_influenced_id         => v_eap_es_rec.Who_Influenced_Id,
                                                               x_attribute_category        => v_eap_es_rec.Attribute_Category,
                                                               x_attribute1                => v_eap_es_rec.Attribute1,
                                                               x_attribute2                => v_eap_es_rec.Attribute2,
                                                               x_attribute3                => v_eap_es_rec.Attribute3,
                                                               x_attribute4                => v_eap_es_rec.Attribute4,
                                                               x_attribute5                => v_eap_es_rec.Attribute5,
                                                               x_attribute6                => v_eap_es_rec.Attribute6,
                                                               x_attribute7                => v_eap_es_rec.Attribute7,
                                                               x_attribute8                => v_eap_es_rec.Attribute8,
                                                               x_attribute9                => v_eap_es_rec.Attribute9,
                                                               x_attribute10               => v_eap_es_rec.Attribute10,
                                                               x_attribute11               => v_eap_es_rec.Attribute11,
                                                               x_attribute12               => v_eap_es_rec.Attribute12,
                                                               x_attribute13               => v_eap_es_rec.Attribute13,
                                                               x_attribute14               => v_eap_es_rec.Attribute14,
                                                               x_attribute15               => v_eap_es_rec.Attribute15,
                                                               x_attribute16               => v_eap_es_rec.Attribute16,
                                                               x_attribute17               => v_eap_es_rec.Attribute17,
                                                               x_attribute18               => v_eap_es_rec.Attribute18,
                                                               x_attribute19               => v_eap_es_rec.Attribute19,
                                                               x_attribute20               => v_eap_es_rec.Attribute20,
                                                               x_s_enquiry_status          => cst_acknowlege,
                                                               x_enabled_flag              => v_eap_es_rec.enabled_flag,
                                                               x_inquiry_method_code       => v_eap_es_rec.inquiry_method_code,
                                                               x_source_promotion_id       => v_eap_es_rec.source_promotion_id,
                                                               x_mode                      => 'R',
                                                               x_action                    => 'Upd',
                                                               x_ret_status                => l_ret_status,
                                                               x_msg_data                  => l_msg_data,
                                                               x_msg_count                 => l_msg_count,
							       x_pkg_reduct_ind            => v_eap_es_rec.pkg_reduct_ind
                                                             );
                                                            IF l_ret_status IN ('E','U') THEN
                                                              FND_FILE.PUT_LINE(FND_FILE.LOG,l_msg_data);
                                ELSE
                                                              v_enquiries_acknowledged := v_enquiries_acknowledged + 1;
                                END IF;
                                        END IF;
                                END IF;
                        END IF;
                        END IF;
                  END IF; -- p_inq_info_type IS NULL / NOT NULL --Newly added for IDOPA2 --(2)
                END LOOP; -- For loopin in c_eap_es -Loop 1
        END IF;-- For Registered or both --(1)

        -- Write summary totals to the job scheduler runlog

      OPEN c_get_group_cd(v_group_id);
      FETCH c_get_group_cd INTO v_group_cd;
      CLOSE c_get_group_cd;

      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING('IGS','IGS_GE_TOTAL_REC_PROCESSED')||IGS_GE_NUMBER.TO_CANN(v_enquiries_processed));
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING('IGS','IGS_GE_TOTAL_REC_COMPLETED')||IGS_GE_NUMBER.TO_CANN(v_enquiries_completed));
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING('IGS','IGS_GE_TOTAL_REC_ACKNOWLEGED')||IGS_GE_NUMBER.TO_CANN(v_enquiries_acknowledged));
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING('IGS','IGR_PRSN_ID_GRP_CD')|| v_group_cd);
        COMMIT;
        RETURN;
EXCEPTION
        WHEN e_resource_busy THEN
                IF c_eap_es%ISOPEN THEN
                        CLOSE c_eap_es;
                END IF;
                IF c_eapmpi_epi%ISOPEN THEN
                        CLOSE c_eapmpi_epi;
                END IF;

                IF c_pkgitems_exist%ISOPEN THEN
                        CLOSE c_pkgitems_exist;
                END IF;

                IF c_pkgitems_avail%ISOPEN THEN
                        CLOSE c_pkgitems_avail;
                END IF;


                FND_MESSAGE.SET_NAME('IGS','IGS_AD_CANPRC_CURUPD_USER');
                IGS_GE_MSG_STACK.ADD;
            APP_EXCEPTION.RAISE_EXCEPTION;
        WHEN OTHERS THEN
                IF c_es%ISOPEN THEN
                        CLOSE c_es;
                END IF;
                IF c_eap_es%ISOPEN THEN
                        CLOSE c_eap_es;
                END IF;
                IF c_eapmpi_epi%ISOPEN THEN
                        CLOSE c_eapmpi_epi;
                END IF;

                IF c_pkgitems_exist%ISOPEN THEN
                        CLOSE c_pkgitems_exist;
                END IF;

                IF c_pkgitems_avail%ISOPEN THEN
                        CLOSE c_pkgitems_avail;
                END IF;

                IF c_eapmpi%ISOPEN THEN
                        CLOSE c_eapmpi;
                END IF;

                IF c_eapmpi_get_epi%ISOPEN THEN
                        CLOSE c_eapmpi_get_epi;
                END IF;

                IF c_pkgitems_exist_more%ISOPEN THEN
                        CLOSE c_pkgitems_exist_more;
                END IF;

                IF c_pkgitems_get_avail%ISOPEN THEN
                        CLOSE c_pkgitems_get_avail;
                END IF;

                APP_EXCEPTION.RAISE_EXCEPTION;
END;
EXCEPTION
        WHEN OTHERS THEN
                retcode := 2;
                errbuf := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
END admp_upd_eap_avail;


Function Admp_Del_Eap_Eitpi(
  p_person_id IN NUMBER ,
  p_enquiry_appl_number IN NUMBER ,
  p_enquiry_information_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS
/****************************************************************************
  Created By :
  Date Created On :
  Purpose :

  Change History
  Who          When         What
  sjlaport     17-FEB-2005  Moved from IGS_AD_GEN_001 (IGSAD01B.pls)
  pkpatel      04-JUN-2001  Erased the parameter p_inquiry_date and added parameters to
                            select person records as per the date range and according to
                            Inquiry source type and Inquiry Entry Status
  pkpatel      13-JUN-2001  Modified the parameter p_inq_entry_stat_id from Mandatory to Default
  nshee        13-JAN-2003   As part of fix for bug 2645948, Inquiry source type is not to be a mandatory parameter.
                                                Changed definition of cursor c_eap_es
  (reverse chronological order - newest change first)
  *****************************************************************************/


BEGIN   -- admp_del_eap_eitpi
    -- Description: This routine will delete all IGR_I_A_PKGITM records
    -- associated with an IGR_I_A_ITYPE record which is being deleted.
DECLARE
    v_message_name          VARCHAR2(30);
    e_resource_busy_exception   EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_resource_busy_exception, -54);
    v_eapc_eltpi            VARCHAR2(1);
    v_eapc_cepi         VARCHAR2(1);
    v_eapit_eitpi           VARCHAR2(1);
    cst_course          CONSTANT VARCHAR2(7) := 'COURSE';

        CURSOR  c_eitpi IS
        SELECT  akit.deliverable_kit_part_id
        FROM      AMS_DELIV_KIT_ITEMS   akit,
                                  AMS_P_DELIVERABLES_V   apd
        WHERE   apd.deliverable_name = p_enquiry_information_type
        AND           apd.deliverable_id = akit.deliverable_kit_id;



        --Check INFORMATION type packages.(Other than the parameter type)
    CURSOR  c_eapit_eitpi(
        cp_enquiry_package_item_id   AMS_DELIV_KIT_ITEMS.deliverable_kit_part_id%TYPE) IS
        SELECT 'X'   FROM   IGR_I_A_ITYPE eapit,
                         AMS_DELIV_KIT_ITEMS akit,
             AMS_P_DELIVERABLES_V  apd
        WHERE    eapit.person_id = p_person_id    AND
                    eapit.enquiry_appl_number   = p_enquiry_appl_number AND
            apd.deliverable_name<> p_enquiry_information_type AND
            apd.deliverable_id = akit.deliverable_kit_id AND
            eapit.info_type_id = akit.deliverable_kit_id AND
                        akit.deliverable_kit_part_id = cp_enquiry_package_item_id;

CURSOR  c_eapmpi_del(
        cp_package_item_id   AMS_DELIV_KIT_ITEMS.deliverable_kit_part_id%TYPE) IS
        SELECT ROWID, eapmpi.*
        FROM    IGR_I_A_PKGITM   eapmpi
        WHERE   eapmpi.person_id        = p_person_id AND
            eapmpi.enquiry_appl_number  = p_enquiry_appl_number AND
            eapmpi.package_item_id  = cp_package_item_id
        FOR UPDATE OF   eapmpi.person_id NOWAIT;
    v_eapmpi_del            c_eapmpi_del%ROWTYPE;

BEGIN
    p_message_name := null;
    IF p_person_id IS NULL OR
            p_enquiry_appl_number IS NULL OR
            p_enquiry_information_type IS NULL THEN
        RETURN TRUE;
    END IF;
    -- 2.Check that the enquiry has not been completed.  If so,
    --the delete is not permitted
    IF IGR_VAL_EAP.admp_val_eap_comp (p_person_id,
                    p_enquiry_appl_number,
                    p_message_name) = FALSE THEN
        RETURN FALSE;
    END IF;
    -- 3.Issue a save point for the module so that if locks exist,
    -- a rollback can be performed.
    SAVEPOINT sp_save_point;
    -- 4.Loop through to select all package items defined for the nominated
    -- enquiry information
    FOR v_eitpi_rec IN c_eitpi LOOP
        --Check INFORMATION type packages.(Other than the parameter type)
        OPEN c_eapit_eitpi(
                v_eitpi_rec.deliverable_kit_part_id);
        FETCH c_eapit_eitpi INTO v_eapit_eitpi;
        IF (c_eapit_eitpi%FOUND) THEN
            CLOSE c_eapit_eitpi;
            EXIT;
        END IF;
        CLOSE c_eapit_eitpi;
        BEGIN
            --No matches found so record can be deleted.
            FOR v_eapmpi_del IN c_eapmpi_del(
                    v_eitpi_rec.deliverable_kit_part_id) LOOP
                IGR_I_A_PKGITM_PKG.DELETE_ROW (
                    X_ROWID => V_EAPMPI_DEL.ROWID );
            END LOOP;
        EXCEPTION
            WHEN e_resource_busy_exception THEN
                ROLLBACK TO sp_save_point;
                p_message_name := 'IGS_AD_NOTDEL_ENQUIRYPACKAGE';
                RETURN FALSE;
            WHEN OTHERS THEN
            App_Exception.Raise_Exception;
        END;
    END LOOP;

    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        IF c_eitpi%ISOPEN THEN
            CLOSE c_eitpi;
        END IF;
        IF c_eapit_eitpi%ISOPEN THEN
            CLOSE c_eapit_eitpi;
        END IF;
        IF c_eapmpi_del%ISOPEN THEN
            CLOSE c_eapmpi_del;
        END IF;
        App_Exception.Raise_Exception;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGR_GEN_001.admp_del_eap_eitpi');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END admp_del_eap_eitpi;

Function Admp_Ins_Eap_Eitpi(
  p_person_id IN NUMBER ,
  p_enquiry_appl_number IN NUMBER ,
  p_enquiry_information_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS
    gv_other_detail     VARCHAR2(255);
        lv_return_status VARCHAR2(10);
        lv_msg_data VARCHAR2(2000);
        lv_msg_count NUMBER;
        l_action VARCHAR2(10);
BEGIN   -- admp_ins_eap_eitpi
    -- Insert records into the IGR_I_A_PKGITMtable for a nominated
    -- IGS_IN_ENQ_INFO_TYPE.
DECLARE
    v_message_name  varchar2(30);
    v_dummy         VARCHAR2(1);
    --(This cursor is changed as a part of the SQL tuning bug 4991561)
    CURSOR c_eitpi IS
                SELECT akit.deliverable_kit_part_id
                FROM   AMS_P_DELIVERABLES_V apd,
                       AMS_P_DELIVERABLES_V apd1,
                       AMS_DELIV_KIT_ITEMS akit
                WHERE  apd.deliverable_id = akit.deliverable_kit_part_id
                AND    apd.actual_avail_from_date <= SYSDATE
                AND    apd.actual_avail_to_date >= SYSDATE
                AND    akit.deliverable_kit_id  = apd1.deliverable_id
                AND    apd1.deliverable_name = p_enquiry_information_type;


    CURSOR c_eapmpi_exists (
        cp_package_item_id
                    IGR_I_A_PKGITM.package_item_id%TYPE) IS
        SELECT  'x'
        FROM    IGR_I_A_PKGITM  eapmpi
        WHERE   eapmpi.person_id        = p_person_id       AND
            eapmpi.enquiry_appl_number  = p_enquiry_appl_number AND
            eapmpi.package_item_id  = cp_package_item_id;
    lv_rowid            VARCHAR2(25);
BEGIN
    -- set default value
    p_message_name := null;
        l_action := 'Add';
    -- 1. Validate parameters.
    IF p_person_id IS NULL OR
            p_enquiry_appl_number IS NULL OR
            p_enquiry_information_type IS NULL THEN
        RETURN TRUE;
    END IF;
    -- 2. Check that the enquiry has not been completed.
    -- If so, the insert is not permitted.
    IF IGR_VAL_EAP.admp_val_eap_comp (   p_person_id,
                        p_enquiry_appl_number,
                        v_message_name) = FALSE THEN
        p_message_name := v_message_name;
        RETURN FALSE;
    END IF;
    -- 3. Use a loop to select all package items defined for the nominated
    -- enquiry information type.  Join to the IGS_IN_ENQ_PKG_ITEM table to
    -- ensure that the package item is not closed.
    FOR v_eitpi_rec IN c_eitpi LOOP
            -- Check that the package item is not already defined in the
        -- IGR_I_A_PKGITMtable.
        OPEN c_eapmpi_exists (
                    v_eitpi_rec.deliverable_kit_part_id);
        FETCH c_eapmpi_exists INTO v_dummy;
        IF c_eapmpi_exists%NOTFOUND THEN
            CLOSE c_eapmpi_exists;
            IGR_I_A_PKGITM_Pkg.Insert_Row (
                X_Mode                              => 'R',
                X_RowId                             => lv_rowid,
                X_Person_Id                         => p_person_id,
                X_Enquiry_Appl_Number               => p_enquiry_appl_number,
                X_Package_Item_id                   => v_eitpi_rec.deliverable_kit_part_id,
                X_Mailed_Dt                         => Null ,
                        X_donot_mail_ind                    => 'N' ,--ADDED as part of Impact of IDOPA2--sykrishn
                x_ret_status                        => lv_return_status,
                    x_msg_data              => lv_msg_data,
                x_msg_count                         => lv_msg_count,
                X_action                            => l_action  );

            p_message_name := lv_msg_data;

        ELSE
            CLOSE c_eapmpi_exists;
        END IF;
    END LOOP;
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        IF c_eitpi%ISOPEN THEN
            CLOSE c_eitpi;
        END IF;
        IF c_eapmpi_exists%ISOPEN THEN
            CLOSE c_eapmpi_exists;
        END IF;
        APP_EXCEPTION.RAISE_EXCEPTION;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGR_GEN_001.admp_ins_eap_eitpi');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END; -- admp_ins_eap_eitpi


END igr_gen_001;

/
