--------------------------------------------------------
--  DDL for Package Body IGR_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGR_GEN_002" AS
/* $Header: IGSRT07B.pls 120.0 2005/06/01 23:22:07 appldev noship $ */

 /****************************************************************************
  Created By : nsinha
  Date Created On : August 27, 2003
  Purpose : 2664699

  Change History
  Who             When            What
   hreddych  26-may-2003    Capture Event Campaign
                          Added the x_source_promotion_id in the call to
                          igs_rc_inquiry_pkg
   jchin     14-Feb-05    Modified package for IGR pseudo product

  (reverse chronological order - newest change first)
  *****************************************************************************/
PROCEDURE Get_latest_batch_id (
      p_batch_id OUT NOCOPY NUMBER )
IS
  /*************************************************************
  Created By : Navin Sinha
  Date Created By : Tuesday, August 12, 2003
  Purpose : Admin_Quick_Entry, Enh#: 2885789
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_max_batch_id IS
      SELECT MAX(batch_id)
      FROM   igs_ad_imp_batch_det
      WHERE  created_by = FND_GLOBAL.USER_ID;
    l_max_batch_id  NUMBER;

    CURSOR cur_chk_batch (cp_batch_id igs_ad_interface_ctl.batch_id%TYPE) IS
      SELECT batch_id
      FROM   igs_ad_interface_ctl
      WHERE  batch_id = cp_batch_id;
    rec_chk_batch  cur_chk_batch%ROWTYPE;
BEGIN

    -- If any records are available for that user in the interface table then get the max batch_id.
    OPEN  cur_max_batch_id;
    FETCH cur_max_batch_id INTO l_max_batch_id ;
    IF ( NVL(l_max_batch_id,0) > 0 ) THEN
       -- For this batch_id check in igs_ad_interface_ctl if there is a record
       OPEN  cur_chk_batch(l_max_batch_id) ;
       FETCH cur_chk_batch INTO rec_chk_batch ;
       IF (cur_chk_batch%FOUND) THEN
            p_batch_id := 0; -- created new  Batch ID.
       ELSE -- No record found in igs_ad_interface_ctl for this batch_id
            p_batch_id := l_max_batch_id; -- Return the existing MAX Batch ID.
       END IF;
       CLOSE cur_chk_batch ;
    ELSE -- No record is available for that user in the interface table
       p_batch_id := 0; -- created new  Batch ID.
    END IF;
    CLOSE cur_max_batch_id ;
END Get_latest_batch_id;

PROCEDURE Get_batch_id (
      p_batch_id OUT NOCOPY NUMBER )
IS
  /*************************************************************
  Created By : Navin Sinha
  Date Created By : Tuesday, August 12, 2003
  Purpose : Admin_Quick_Entry, Enh#: 2885789
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
    -- Get the Batch ID for admission application import process
    CURSOR c_bat_id IS
      SELECT igs_ad_interface_batch_id_s.NEXTVAL
      FROM dual;
    l_imp_batch_id NUMBER;

    l_batch_desc VARCHAR2(2000);
    l_user_id NUMBER := FND_GLOBAL.USER_ID;

    -- Get the user name
    CURSOR cur_user_name IS
        SELECT SUBSTR(user_name,1,20)
        FROM fnd_user
        WHERE USER_ID = FND_GLOBAL.USER_ID;
    l_user_name VARCHAR2(50);

    l_create_new_batch  BOOLEAN := FALSE;
  BEGIN
    -- If any records are available for that user in the interface table then get the max batch_id.
    igr_gen_002.Get_latest_batch_id (p_batch_id);
    IF p_batch_id = 0 THEN -- create a new batch
         l_imp_batch_id := NULL ;

         -- Get the Batch ID for admission application import process
         OPEN c_bat_id;
         FETCH c_bat_id INTO l_imp_batch_id;
         CLOSE c_bat_id;

         -- Get the user name
         OPEN cur_user_name;
         FETCH cur_user_name INTO l_user_name;
         CLOSE cur_user_name;

         l_batch_desc := 'Quick Entry Batch Created For '||Substr(l_user_name,1,20) ||' on ' || sysdate;

         INSERT INTO igs_ad_imp_batch_det (
                  batch_id,
                  batch_desc,
                  created_by,
                  creation_date,
                  last_updated_by,
                  last_update_date,
                  last_update_login,
                  request_id,
                  program_application_id,
                  program_update_date,
                  program_id)
         VALUES ( l_imp_batch_id,
                  l_batch_desc,
                  fnd_global.user_id,
                  SYSDATE,
                  fnd_global.user_id,
                  SYSDATE,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL
                );
--hreddych Added this Since this record needs to be commited to be visible from other sessions
	  COMMIT;
          p_batch_id := l_imp_batch_id; -- Return the newly created Batch ID.
    END IF;
  END Get_batch_id;

  PROCEDURE Delete_Inquiry_Dtls (
      p_interface_id IN NUMBER )
  IS
  /*************************************************************
  Created By : Navin Sinha
  Date Created By : Tuesday, August 12, 2003
  Purpose : Admin_Quick_Entry, Enh#: 2885789
            If user clicks on Delete, the same record will be deleted from interface tables.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN
    -- All The records in the below interface tables
    -- which correspond to that Inquiry should be deleted .
    DELETE igs_ad_interface_all WHERE interface_id = p_interface_id;
    DELETE igs_ad_addr_int_all WHERE interface_id = p_interface_id;

    DELETE igr_i_lines_int WHERE interface_inq_appl_id IN
      (SELECT interface_inq_appl_id FROM igr_i_appl_int WHERE interface_id = p_interface_id);
    DELETE igr_i_appl_int WHERE interface_id = p_interface_id;

    DELETE igs_ad_acadhis_int_all WHERE interface_id = p_interface_id;
    DELETE igs_ad_contacts_int_all WHERE interface_id = p_interface_id;
    DELETE igs_pe_race_int WHERE interface_id = p_interface_id;
    DELETE igs_ad_stat_int WHERE interface_id = p_interface_id;
    COMMIT;
  EXCEPTION
	WHEN OTHERS THEN
	      Fnd_Message.Set_Name ('FND', 'IGS_GE_UNHANDLED_EXCEPTION');
	      igs_ge_msg_stack.add;
	      App_Exception.Raise_Exception;
  END Delete_Inquiry_Dtls;

END igr_gen_002;

/
