--------------------------------------------------------
--  DDL for Package IGS_TR_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_TR_GEN_002" AUTHID CURRENT_USER AS
/* $Header: IGSTR02S.pls 115.18 2002/11/29 04:18:37 nsidana ship $ */

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. Used for deletion of tracking step notes, deletion of
        tracking steps, for tracking items, deletion of tracking group members for
        IGS_TR_ITEMS, deletion of tracking item notes for IGS_TR_ITEMS and deletion of
        IGS_TR_ITEMS

  Usage: (e.g. restricted, unrestricted, where to call from)
     1. Called from IGSTR007.fmb

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/
  FUNCTION trkp_del_tri(
    p_tracking_id IN NUMBER ,
    p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN;

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. This function returns the status of a tracking group

  Usage: (e.g. restricted, unrestricted, where to call from)
     1. Called from IGSTR007.FMB

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/
  FUNCTION trkp_get_group_sts(
    p_tracking_group_id IN NUMBER )
  RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES (trkp_get_group_sts, wnds);

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. This function returns the status of a tracking item

  Usage: (e.g. restricted, unrestricted, where to call from)
     1. Called from IGSTR007.FMB

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/
  FUNCTION trkp_get_item_status(
    p_tracking_id IN NUMBER )
  RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES (trkp_get_item_status, wnds,wnps);


  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
   1. This program unit is used to insert the default tracking_steps for an item
      based on the IGS_TR_TYPE and its associated tracking_type_steps, duplicate
      existing IGS_GE_NOTE records and insert IGS_TR_STEP_NOTES

  Usage: (e.g. restricted, unrestricted, where to call from)
   1. Called from IGSTR007.FMB upon creation of a tracking item.

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  msrinivi        06 Jul,2001    Added logic to insert the newly added columns, i.e.
                                 step catalog id,step group id and publish indicator
  *******************************************************************************/
  PROCEDURE trkp_ins_dflt_trst(
    p_tracking_id IN NUMBER ,
    p_message_name OUT NOCOPY VARCHAR2 );

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1.  This procedure will be used by batch processing to create a tracking item
         It will accept the details of the item to be created and insert a
         IGS_TR_ITEM record. The tracking item step will be defaulted
         when the database table  insert trigger fires for the tracking item.

  Usage: (e.g. restricted, unrestricted, where to call from)
     1. Called from IGSTR007.FMB

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  msrinivi        06 Jul,2001     Added 3 new columns : completion due dt,
                                  override offset clc ind and publish ind
  *******************************************************************************/
  PROCEDURE trkp_ins_trk_item(
    p_tracking_status IN VARCHAR2 ,
    p_tracking_type IN VARCHAR2 ,
    p_source_person_id IN NUMBER ,
    p_start_dt IN DATE ,
    p_target_days IN NUMBER ,
    p_sequence_ind IN VARCHAR2 ,
    p_business_days_ind IN VARCHAR2 ,
    p_originator_person_id IN NUMBER ,
    p_s_created_ind IN VARCHAR2 DEFAULT 'N',
    p_tracking_id OUT NOCOPY NUMBER ,
    p_message_name OUT NOCOPY VARCHAR2,
    p_override_offset_clc_ind IN VARCHAR2 DEFAULT 'N',
    p_completion_due_dt IN DATE DEFAULT NULL,
    p_publish_ind IN VARCHAR2 DEFAULT 'N'
);

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1.  This module will update fields of the action days of
         a IGS_TR_STEP record.
  Usage: (e.g. restricted, unrestricted, where to call from)
     1. Called from IGSTR007.FMB

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  msrinivi       06 Jul,2001     Modified to have the logic for step groups before update.
  *******************************************************************************/
  FUNCTION trkp_upd_trst(
    p_tracking_id IN NUMBER ,
    p_tracking_step_id IN NUMBER ,
    p_s_tracking_step_type IN VARCHAR2 ,
    p_action_dt IN DATE ,
    p_completion_dt IN DATE ,
    p_step_completion_ind IN VARCHAR2,
    p_by_pass_ind IN VARCHAR2,
    p_recipient_id IN NUMBER ,
    p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;


  /***********************************************************************************************************

  Created By:        pradhakr
  Date Created By:   11-Feb-2002
  Purpose:     This procedure will synchronise the content of the table IGS_TR_STEP_GRP_LMT with the content
               of IGS_TR_TYPE_STEP_V.
  	       1. If that step group being deleted in form IGSTR001 ( block tracking step) is the last one of its
	          kind for a particular tracking id, the step group id will be deleted  from IGS_TR_TSTP_GRP_LMT
   	          else Step Group Limit will be decremented by 1.
               2. Any new Step Group ID being created in the form IGSTR001 ( block tracking step) will also be created
	          in the table IGS_TR_TSTP_GRP_LMT and the Step Group Limit would be defaulted to 1.

  Known limitations,enhancements,remarks:
  Change History
  Who        When        What
  ************************************************************************************************************/

  PROCEDURE sync_trk_type_grplmt (
    p_tracking_type  IGS_TR_TYPE_STEP_V.tracking_type%TYPE,
    p_execute VARCHAR2 DEFAULT 'N'
    );


/***********************************************************************************************************

Created By:        Arun Iyer

Date Created By:   13-Feb-2002

Purpose:     This procedure will synchronise the content of the table IGS_TR_STEP_GRP_LMT with the content
             of IGS_TR_STEP_V.
	     1. If that step group being deleted in form IGSTR007 ( block tracking step) is the last one of its
	        kind for a particular tracking id, the step group id will be deleted  from IGS_TR_STEP_GRP_LMT

             2. Any new Step Group ID being created in the form IGSTR007 ( block tracking step) will also be created
	        in the table IGS_TR_STEP_GRP_LMT and the Step Group Limit would be defaulted to 1.

             3. In case IGS_TR_STEP_GRP_LMT.STEP_GROUP_LIMIT is greater than the count of step_group_id's for tracking_id and step_group_id
                combination in IGS_TR_STEP_V view then set it equal to the lower value (i.e count of step_group_id's in the IGS_TR_STEP_V).


 Known limitations,enhancements,remarks:

 Change History

 Who        When        What
 ************************************************************************************************************/

PROCEDURE sync_trk_item_grplmt ( p_tracking_id  IGS_TR_STEP_V.tracking_id %TYPE,
                                 p_execute VARCHAR2 DEFAULT 'N'
                                )  ;



/***********************************************************************************************************

Created By:        Arun Iyer

Date Created By:   13-Feb-2002

Purpose:      This procedure would be called from the post forms commit trigger of the form IGSTR007 (Tracking Items)
              when the user checks the sequential flag (value = Y' ) for the current tracking id.
              1. This checks whether all the previous steps have been completed or not. In case they have not been completed
	         it suitable raises an error.
	      2. If in the form the tracking status has been set to COMPLETE then this procedure validate whether
	         the tracking status changed to COMPLETE is correct or not.
		 In case it is incorrect then a suitable error message is returned back to the calling form

Known limitations,enhancements,remarks:

Change History

Who        When        What
************************************************************************************************************/

FUNCTION validate_completion_status ( p_tracking_id     IN IGS_TR_STEP_V.TRACKING_ID%TYPE,
                                      p_tracking_status IN IGS_TR_ITEM_V.TRACKING_STATUS%TYPE,
				      p_sequence_ind    IN IGS_TR_ITEM_V.SEQUENCE_IND%TYPE,
                                      p_message_name    OUT NOCOPY VARCHAR2
                                     ) RETURN BOOLEAN;




  /***********************************************************************************************************

  Created By:
  Date Created By:
  Purpose:
  Known limitations,enhancements,remarks:
  Change History
  Who        When          What
  pradhakr   14-Feb-2002   Added a parameter step_group_id in the function.
  ************************************************************************************************************/
  FUNCTION trkp_prev_step_cmplt (
    p_tracking_id igs_tr_step.tracking_id%TYPE,
    p_tracking_step_number igs_tr_step.tracking_step_number%TYPE,
    p_step_group_id igs_tr_step.step_group_id%TYPE,
    p_message_name OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN ;


END igs_tr_gen_002;

 

/
