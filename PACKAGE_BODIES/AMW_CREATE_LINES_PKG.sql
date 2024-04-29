--------------------------------------------------------
--  DDL for Package Body AMW_CREATE_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_CREATE_LINES_PKG" AS
/* $Header: amwcrlnb.pls 120.2 2006/09/21 23:36:44 npanandi noship $ */
/*****************************************************************************/
/*****************************************************************************/
/*****************************************************************************/
/* Major Functionality of the followIng procedure includes:                  */
/* Reads the amw_risk-ctrl_interface table                                   */
/* following tables:                                                         */
/*  INSERTS OR UPDATES ARE DONE AGAINIST THE FOLLOWING TABLES                */
/*  Insert into ENG_CHANGE_SUBJECTS                                          */
/*  Insert into ENG_CHANGE_LINES_B and ENG_CHANGE_LINES_TL                     */
/*                                                                           */
/*****************************************************************************/
--
-- Used for exception processing
--

   G_USER_ID NUMBER := FND_GLOBAL.USER_ID;
   G_LOGIN_ID NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
/*****************************************************************************/
PROCEDURE CREATE_LINES (
   P_CHANGE_ID      IN NUMBER
  ,X_RETURN_STATUS  OUT NOCOPY VARCHAR2
  ,X_MSG_COUNT      OUT NOCOPY VARCHAR2
  ,X_MSG_DATA       OUT NOCOPY VARCHAR2
)
IS
/****************************************************/
   CURSOR C_ENTITY_NAME IS
      SELECT ENTITY_NAME
	        ,PK1_VALUE
			,PK2_VALUE
			,PK3_VALUE
			,PK4_VALUE
			,PK5_VALUE
	    FROM ENG_CHANGE_SUBJECTS
	   WHERE CHANGE_LINE_ID IS NULL
	     AND SUBJECT_LEVEL=1
		 AND CHANGE_ID=P_CHANGE_ID;

   L_ENTITY_NAME        C_ENTITY_NAME%ROWTYPE;
   LX_RETURN_STATUS	    VARCHAR2(30);
   LX_MSG_COUNT         NUMBER;
   LX_MSG_DATA          VARCHAR2(2000);

   e_no_import_access               		 EXCEPTION;
   e_invalid_requestor_id           		 EXCEPTION;
   l_init_msg_list		CONSTANT VARCHAR2(1) := FND_API.G_TRUE;
   ---02.15.2004 npanandi: added below variable to hold ProcessApprovalOption parameter value
   l_approval_option      varchar2(10) default NULL;
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( l_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   ---02.16.2005 npanandi: need to delete existing lines for this changeRequest
   ---and re-create rows with new process / risk /  control associations
   delete from eng_change_lines_tl where change_line_id in (select change_line_id from eng_change_lines where change_id=p_change_id);
   delete from eng_change_lines where change_id=p_change_id;
   delete from eng_change_subjects where change_line_id is not null and change_id=p_change_id;

   OPEN C_ENTITY_NAME;
      FETCH C_ENTITY_NAME INTO L_ENTITY_NAME;
   CLOSE C_ENTITY_NAME;

   IF(L_ENTITY_NAME.ENTITY_NAME = 'AMW_REVISION_ETTY') THEN
      --02.15.2004 npanandi: added below SQL to get the
      --ProcessApprovalOption parameter value for RiskLibrary ctx
      l_approval_option := amw_utility_pvt.get_parameter(-1, 'PROCESS_APPROVAL_OPTION');

      CREATE_LINES_RL(
	     P_CHANGE_ID       => P_CHANGE_ID
		,P_PK1             => L_ENTITY_NAME.PK1_VALUE
		,P_PK2             => L_ENTITY_NAME.PK2_VALUE
		,P_PK3             => L_ENTITY_NAME.PK3_VALUE
		,P_PK4             => L_ENTITY_NAME.PK4_VALUE
		,P_PK5             => L_ENTITY_NAME.PK5_VALUE
		,P_ENTITY_NAME     => L_ENTITY_NAME.ENTITY_NAME
		,p_approval_option => l_approval_option
	  );
   ELSE
      --02.15.2004 npanandi: added below SQL to get the
      --ProcessApprovalOption parameter value for RiskLibrary ctx
      l_approval_option := amw_utility_pvt.get_parameter(L_ENTITY_NAME.PK1_VALUE, 'PROCESS_APPROVAL_OPTION');

      CREATE_LINES_ORG(
	     P_CHANGE_ID       => P_CHANGE_ID
		,P_PK1             => L_ENTITY_NAME.PK1_VALUE
		,P_PK2             => L_ENTITY_NAME.PK2_VALUE
		,P_PK3             => L_ENTITY_NAME.PK3_VALUE
		,P_PK4             => L_ENTITY_NAME.PK4_VALUE
		,P_PK5             => L_ENTITY_NAME.PK5_VALUE
		,P_ENTITY_NAME     => L_ENTITY_NAME.ENTITY_NAME
		,p_approval_option => l_approval_option
	  );
   END IF;
EXCEPTION
   WHEN others THEN
      rollback;
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data => x_msg_data);
      --fnd_file.put_line (fnd_file.LOG, 'unexpected exception in create_lines: '||sqlerrm);
END CREATE_LINES;

/*****************************************************************************/
PROCEDURE CREATE_LINES_RL (
   P_CHANGE_ID      IN NUMBER
  ,P_PK1            IN NUMBER
  ,P_PK2            IN NUMBER
  ,P_PK3            IN NUMBER
  ,P_PK4            IN NUMBER
  ,P_PK5            IN NUMBER
  ,P_ENTITY_NAME    IN VARCHAR2 --AMW_REVISION_ETTY for Risk Library Approvals
  --02.15.2005 npanandi: added below parameter for ProcessApprovalOption parameter value
  ,p_approval_option in varchar2
)
IS
/****************************************************/
   --02.15.2004 npanandi: cursor to get downward Proceses which will
   --also get approved alongwith the Change Request for the Current Process
   --this is valid only if the ProcessApprovalOption parameter is 'B'
   cursor c_draft_child_processes is
      select parent_child_id as process_id
	        ,a.DISPLAY_NAME
			,a.DESCRIPTION
			,a.REVISION_NUMBER
			,a.approval_status
        from amw_proc_hierarchy_denorm d, amw_process_vl a
       where d.process_id = p_pk1 --processId
         and up_down_ind = 'D'
         and hierarchy_type = 'L'
         and a.process_id = d.PARENT_CHILD_ID
         and a.end_date is null
         and a.approval_status <> 'A'
		 and a.process_id in (select child_process_id
		                        from AMW_curr_app_HIERARCHY_rl_V
							   where parent_process_id=p_pk1);

   ---02.15.2004 npanandi: cursor to get processes for AddProcess lineType
   ---only 1 level below i.e. immediate child processes
   cursor c_add_process is
      SELECT ALR.PROCESS_ID
            ,ALR.NAME
            ,ALR.DISPLAY_NAME
	        ,ALR.DESCRIPTION
	        ,ALR.PROCESS_CODE
	        --,alr.revision_number
        FROM AMW_LATEST_REVISIONS_V ALR
            ,AMW_LATEST_HIERARCHY_RL_V APHD
       WHERE APHD.CHILD_process_ID=ALR.PROCESS_ID
         AND APHD.parent_PROCESS_ID=p_pk1 --processId
      minus
      SELECT ALR.PROCESS_ID
            ,ALR.NAME
            ,ALR.DISPLAY_NAME
	        ,ALR.DESCRIPTION
	        ,ALR.PROCESS_CODE
	        --,alr.revision_number
        FROM AMW_LATEST_REVISIONS_V ALR
            ,AMW_CURR_APP_HIERARCHY_RL_V APHD
       WHERE APHD.CHILD_process_ID=ALR.PROCESS_ID
         AND APHD.parent_PROCESS_ID=p_pk1; --processId

   ---02.15.2004 npanandi: cursor to get processes for DeleteProcess lineType
   ---only 1 level below i.e. immediate child processes
   cursor c_delete_process is
      SELECT ALR.PROCESS_ID
            ,ALR.NAME
            ,ALR.DISPLAY_NAME
	        ,ALR.DESCRIPTION
	        ,ALR.PROCESS_CODE
	        --,alr.revision_number
        FROM AMW_LATEST_REVISIONS_V ALR
            ,AMW_CURR_APP_HIERARCHY_RL_V APHD
       WHERE APHD.CHILD_process_ID=ALR.PROCESS_ID
         AND APHD.parent_PROCESS_ID=p_pk1 --processId
      minus
      SELECT ALR.PROCESS_ID
            ,ALR.NAME
            ,ALR.DISPLAY_NAME
	        ,ALR.DESCRIPTION
	        ,ALR.PROCESS_CODE
	        --,alr.revision_number
        FROM AMW_LATEST_REVISIONS_V ALR
            ,AMW_LATEST_HIERARCHY_RL_V APHD
       WHERE APHD.CHILD_process_ID=ALR.PROCESS_ID
         AND APHD.parent_PROCESS_ID=p_pk1; --processId

   ---02.16.2004 npanandi: cursor to get risks for AddRisk lineType
   ---only current Process risk additions
   cursor c_add_risk is
      (select arav.risk_id
	         ,ARAV.NAME
	         ,ARAV.DESCRIPTION
	     FROM AMW_RISKS_ALL_VL ARAV
	         ,AMW_RISK_ASSOCIATIONS ARA
	    WHERE ARA.RISK_ID=ARAV.RISK_ID
	      AND ARAV.LATEST_REVISION_FLAG='Y'
	      AND ARA.OBJECT_TYPE='PROCESS'
	      AND ARA.DELETION_DATE IS NULL
	      AND ARA.PK1=p_pk1) --processId
	  minus
	  (select arav.risk_id
	         ,ARAV.NAME
	         ,ARAV.DESCRIPTION
	     FROM AMW_RISKS_ALL_VL ARAV
	         ,AMW_RISK_ASSOCIATIONS ARA
	    WHERE ARA.RISK_ID=ARAV.RISK_ID
	      AND ARAV.LATEST_REVISION_FLAG='Y'
	      AND ARA.OBJECT_TYPE='PROCESS'
	      AND ARA.APPROVAL_DATE IS not NULL
	      and ara.DELETION_APPROVAL_DATE is null
	      AND ARA.PK1=p_pk1); --processId

   ---02.16.2004 npanandi: cursor to get risks for DeleteRisk lineType
   ---only current Process risk deletions
   cursor c_delete_risk is
      (select arav.risk_id
	         ,ARAV.NAME
	         ,ARAV.DESCRIPTION
	     FROM AMW_RISKS_ALL_VL ARAV
	         ,AMW_RISK_ASSOCIATIONS ARA
	    WHERE ARA.RISK_ID=ARAV.RISK_ID
	      AND ARAV.LATEST_REVISION_FLAG='Y'
	      AND ARA.OBJECT_TYPE='PROCESS'
	      AND ARA.APPROVAL_DATE IS not NULL
	      and ara.DELETION_APPROVAL_DATE is null
	      AND ARA.PK1=p_pk1) --processId
	  minus
      (select arav.risk_id
	         ,ARAV.NAME
	         ,ARAV.DESCRIPTION
	     FROM AMW_RISKS_ALL_VL ARAV
	         ,AMW_RISK_ASSOCIATIONS ARA
	    WHERE ARA.RISK_ID=ARAV.RISK_ID
	      AND ARAV.LATEST_REVISION_FLAG='Y'
	      AND ARA.OBJECT_TYPE='PROCESS'
	      AND ARA.DELETION_DATE IS NULL
	      AND ARA.PK1=p_pk1); --processId

   ---02.16.2004 npanandi: cursor to get risks for AddControl lineType
   ---only the current Process control additions
   cursor c_add_ctrl is
      (select acav.control_id
		     ,acav.NAME
		     ,acav.DESCRIPTION
	     FROM AMW_CONTROLS_ALL_VL acav
		     ,AMW_CONTROL_ASSOCIATIONS aca
	    WHERE aca.control_id=acav.control_id
	      AND acav.LATEST_REVISION_FLAG='Y'
	      AND aca.OBJECT_TYPE='RISK'
	      AND aca.DELETION_DATE IS NULL
	      AND aca.PK1=p_pk1)
	  minus
	  (select acav.control_id
		     ,acav.NAME
		     ,acav.DESCRIPTION
	     FROM AMW_CONTROLS_ALL_VL acav
		     ,AMW_CONTROL_ASSOCIATIONS aca
	    WHERE aca.control_id=acav.control_id
	      AND acav.LATEST_REVISION_FLAG='Y'
	      AND aca.OBJECT_TYPE='RISK'
	      AND aca.approval_DATE IS not NULL
	      and aca.deletion_approval_date is null
	      AND aca.PK1=p_pk1); --processId

   ---02.16.2004 npanandi: cursor to get controls for DeleteControl lineType
   ---only the current Process control deletions
   cursor c_delete_ctrl is
      (select acav.control_id
		     ,acav.NAME
		     ,acav.DESCRIPTION
	     FROM AMW_CONTROLS_ALL_VL acav
		     ,AMW_CONTROL_ASSOCIATIONS aca
	    WHERE aca.control_id=acav.control_id
	      AND acav.LATEST_REVISION_FLAG='Y'
	      AND aca.OBJECT_TYPE='RISK'
	      AND aca.approval_DATE IS not NULL
	      and aca.deletion_approval_date is null
	      AND aca.PK1=p_pk1) --processId
      minus
	  (select acav.control_id
		     ,acav.NAME
		     ,acav.DESCRIPTION
	     FROM AMW_CONTROLS_ALL_VL acav
		     ,AMW_CONTROL_ASSOCIATIONS aca
	    WHERE aca.control_id=acav.control_id
	      AND acav.LATEST_REVISION_FLAG='Y'
	      AND aca.OBJECT_TYPE='RISK'
	      AND aca.DELETION_DATE IS NULL
	      AND aca.PK1=p_pk1); --processId

   L_SEQ_NUM_INCR       NUMBER;
   L_CHANGE_LINE_ID     NUMBER;
   L_CHANGE_SUBJECT_ID	NUMBER;
   L_LINE_TYPE_ID       NUMBER;
   LX_ROW_ID            VARCHAR2(255);

   --02.02.2005 npanandi: added below vars for Delete Line Types
   L_DELETE_CHANGE_SUBJECT_ID	NUMBER;
   L_DELETE_LINE_TYPE_ID       NUMBER;

   LX_RETURN_STATUS	    VARCHAR2(30);
   LX_MSG_COUNT         NUMBER;
   LX_MSG_DATA          VARCHAR2(2000);

   e_no_import_access               		 EXCEPTION;
   e_invalid_requestor_id           		 EXCEPTION;
   l_revision_number    number;
BEGIN
   ---dbms_output.put_line( 'p_approval_option: '||p_approval_option );

   /* 02.15.2004 npanandi: added below if stmnt/cursor loop
      for creating lines for all downward processes which are
	  also undergoing Change alongwith the parent Process for which
	  the Change Request is made
    */
   --if p_approval_option = 'B'--> Automatically Approve all descendants
   --if p_approval_option = 'A'--> Approval Independent of Descendant's Approval Status
   if(p_approval_option = 'B')then
      for draft_proc_rec in c_draft_child_processes loop
	     L_SEQ_NUM_INCR := NVL(L_SEQ_NUM_INCR,0)+10;

		 --get the line_type_id for this child_approval_process_line_type
		 L_LINE_TYPE_ID := NULL;       --SET THIS TO NULL FOR PROCESS LINES
	     L_CHANGE_SUBJECT_ID := NULL;  --SET THIS TO NULL FOR PROCESS LINES

		 --- ***************************** WARNING STARTS *****************************
		 --- change the values of the parameters below after seeding correct lineType
		 --- ***************************** WARNING ENDS *****************************
		 l_line_type_id := get_line_type_id('AMW_PROCESS_RL_APPROVAL','AMW_LINE_APPR_PROCESS_ETTY','AMW_REVISION_ETTY');

         process_lines(
		    p_change_id     => p_change_id
		   ,p_seq_num_incr  => l_seq_num_incr
		   ,p_line_type_id  => l_line_type_id
		   ,p_name          => draft_proc_rec.display_name
		   ,p_description   => draft_proc_rec.description
		   ,p_entity_name1  => 'AMW_LINE_APPR_PROCESS_ETTY'
		   ,p_entity_name2  => 'AMW_REVISION_ETTY'
		   ,p_pk1_value     => draft_proc_rec.process_id
		   ,p_pk2_value     => draft_proc_rec.revision_number
		 );

		/**
         CREATE_CHANGE_REQUEST_LINES(
            P_CHANGE_ID      => P_CHANGE_ID
           ,p_seq_num_incr   => L_SEQ_NUM_INCR
           ,p_line_type_id   => L_LINE_TYPE_ID
           ,p_name           => draft_proc_rec.DISPLAY_NAME
           ,p_description    => draft_proc_rec.DESCRIPTION
		   ,x_change_line_id => l_change_line_id);

         CREATE_SUBJECT_LINES(
            p_change_id      => P_CHANGE_ID
           ,p_change_line_id => L_CHANGE_LINE_ID
           ,p_entity_name    => 'AMW_LINE_PROCESS_ETTY'
           ,p_pk1_value      => draft_proc_rec.process_id
           ,p_pk2_value      => draft_proc_rec.revision_number
           ,p_subject_level  => 1);

         CREATE_SUBJECT_LINES(
            p_change_id      => P_CHANGE_ID
           ,p_change_line_id => L_CHANGE_LINE_ID
           ,p_entity_name    => 'AMW_REVISION_ETTY'
           ,p_pk1_value      => draft_proc_rec.process_id
           ,p_pk2_value      => draft_proc_rec.revision_number
           ,p_subject_level  => 2);
		   **/
	  end loop;
   end if;

   ---Create Lines for All downward Processes
   FOR add_PROC_REC IN C_add_PROCESS LOOP
      L_SEQ_NUM_INCR := NVL(L_SEQ_NUM_INCR,0)+10;

	  --GET THE LINE_TYPE_ID FOR PROCESS LINE TYPE
	  L_LINE_TYPE_ID := NULL;       --SET THIS TO NULL FOR PROCESS LINES
	  L_CHANGE_SUBJECT_ID := NULL;  --SET THIS TO NULL FOR PROCESS LINES

	  l_line_type_id := get_line_type_id('AMW_PROCESS_RL_APPROVAL','AMW_LINE_PROCESS_ETTY','AMW_REVISION_ETTY');
	  /*select ecot.change_order_type_id
	        ,ESE.SUBJECT_ID
	    INTO L_LINE_TYPE_ID
		    ,L_CHANGE_SUBJECT_ID
        from eng_change_order_types ecot
            ,eng_subject_entities ese
       where ecot.change_mgmt_type_code='AMW_PROCESS_RL_APPROVAL'
         and ecot.SUBJECT_ID=ese.subject_id
         AND ESE.ENTITY_NAME='AMW_LINE_PROCESS_ETTY'
         AND ESE.PARENT_ENTITY_NAME='AMW_REVISION_ETTY'
         AND ESE.SUBJECT_LEVEL=1;*/

      ---02.16.2005 npanandi: below SQL gives the revisionNumber
	  ---of this process from the AmwLatestHierarchyV view
	  --- ****** reason why RevisionNumber is not incl. in Cursor stmt: ******
	  ---there may be an immediate child Process, which is also in Draft status
	  ---in this case, the AddProcess Cursor's 'minus' clause causes problems in
	  ---revisionNumber data, and incorrect resultSet is obtained.
	  select revision_number into l_revision_number
	    from amw_latest_revisions_v
	   where process_id=add_proc_rec.process_id;

      process_lines(
	     p_change_id     => p_change_id
	    ,p_seq_num_incr  => l_seq_num_incr
	    ,p_line_type_id  => l_line_type_id
	    ,p_name          => add_proc_rec.display_name
	    ,p_description   => add_proc_rec.description
	    ,p_entity_name1  => 'AMW_LINE_PROCESS_ETTY'
	    ,p_entity_name2  => 'AMW_REVISION_ETTY'
	    ,p_pk1_value     => add_proc_rec.process_id
	    ,p_pk2_value     => l_revision_number
	  );
/*
      CREATE_CHANGE_REQUEST_LINES(
         P_CHANGE_ID      => P_CHANGE_ID
        ,p_seq_num_incr   => L_SEQ_NUM_INCR
        ,p_line_type_id   => L_LINE_TYPE_ID
        ,p_name           => add_PROC_REC.DISPLAY_NAME
        ,p_description    => add_PROC_REC.DESCRIPTION
		,x_change_line_id => l_change_line_id);

      CREATE_SUBJECT_LINES(
         p_change_id      => P_CHANGE_ID
        ,p_change_line_id => L_CHANGE_LINE_ID
        ,p_entity_name    => 'AMW_LINE_PROCESS_ETTY'
        ,p_pk1_value      => add_proc_rec.process_id
        ,p_pk2_value      => add_proc_rec.revision_number
        ,p_subject_level  => 1);

      CREATE_SUBJECT_LINES(
         p_change_id      => P_CHANGE_ID
        ,p_change_line_id => L_CHANGE_LINE_ID
        ,p_entity_name    => 'AMW_REVISION_ETTY'
        ,p_pk1_value      => add_proc_rec.process_id
        ,p_pk2_value      => add_proc_rec.revision_number
        ,p_subject_level  => 2);
*/
   END LOOP;

   ---02.16.2005 npanandi: added below loop for DeleteProcess lineTypes
   for delete_proc_rec in c_delete_process loop
      l_seq_num_incr := nvl(l_seq_num_incr,0)+10;
      ---02.02.2005 npanandi: added below stmnt
      ---get the line_type_id for 'Delete Process' lineType
      L_DELETE_LINE_TYPE_ID := NULL;       --SET THIS TO NULL FOR DELETE PROCESS LINES
	  L_DELETE_CHANGE_SUBJECT_ID := NULL;  --SET THIS TO NULL FOR DELETE PROCESS LINES

	  l_line_type_id := get_line_type_id('AMW_PROCESS_RL_APPROVAL','AMW_LINE_DEL_PROCESS_ETTY','AMW_REVISION_ETTY');
	  /*select ecot.change_order_type_id
	        ,ESE.SUBJECT_ID
        INTO L_DELETE_LINE_TYPE_ID
            ,L_DELETE_CHANGE_SUBJECT_ID
        from eng_change_order_types ecot
            ,eng_subject_entities ese
       where ecot.change_mgmt_type_code='AMW_PROCESS_RL_APPROVAL'
         and ecot.SUBJECT_ID=ese.subject_id
         AND ESE.ENTITY_NAME='AMW_LINE_DEL_PROCESS_ETTY'
         AND ESE.PARENT_ENTITY_NAME='AMW_REVISION_ETTY'
         AND ESE.SUBJECT_LEVEL=1;*/
      ---02.02.2005 npanandi: ends above stmnt

	  ---02.16.2005 npanandi: below SQL gives the revisionNumber
	  ---of this process from the AmwCurrAppHierarchyV view
	  --- ****** reason why RevisionNumber is not incl. in Cursor stmt: ******
	  ---there may be an immediate child Process, which is also in Draft status
	  ---in this case, the DeleteProcess Cursor's 'minus' clause causes problems in
	  ---revisionNumber data, and incorrect resultSet is obtained.
	  select child_revision_number into l_revision_number
	    from amw_curr_app_hierarchy_rl_v
	   where parent_process_id=p_pk1 --parentProcessId
	     and child_process_id=delete_proc_rec.process_id; --childProcessId

	  process_lines(
	     p_change_id     => p_change_id
	    ,p_seq_num_incr  => l_seq_num_incr
	    ,p_line_type_id  => l_line_type_id
	    ,p_name          => delete_proc_rec.display_name
	    ,p_description   => delete_proc_rec.description
	    ,p_entity_name1  => 'AMW_LINE_DEL_PROCESS_ETTY'
	    ,p_entity_name2  => 'AMW_REVISION_ETTY'
	    ,p_pk1_value     => delete_proc_rec.process_id
	    ,p_pk2_value     => l_revision_number
	  );
   end loop;

   --loop for AddRisk lineType
   FOR add_RISK_REC IN c_add_risk LOOP
      L_SEQ_NUM_INCR := NVL(L_SEQ_NUM_INCR,0)+10;

	  --GET THE LINE_TYPE_ID FOR RISK LINE TYPE
	  L_LINE_TYPE_ID := NULL;       --SET THIS TO NULL FOR RISK LINES
	  L_CHANGE_SUBJECT_ID := NULL;  --SET THIS TO NULL FOR RISK LINES
	  l_line_type_id := get_line_type_id('AMW_PROCESS_RL_APPROVAL','AMW_LINE_RISK_ETTY','AMW_REVISION_ETTY');
	  /*select ecot.change_order_type_id
	        ,ESE.SUBJECT_ID
        INTO L_LINE_TYPE_ID
	        ,L_CHANGE_SUBJECT_ID
        from eng_change_order_types ecot
            ,eng_subject_entities ese
       where ecot.change_mgmt_type_code='AMW_PROCESS_RL_APPROVAL'
         and ecot.SUBJECT_ID=ese.subject_id
         AND ESE.ENTITY_NAME='AMW_LINE_RISK_ETTY'
         AND ESE.PARENT_ENTITY_NAME='AMW_REVISION_ETTY'
         AND ESE.SUBJECT_LEVEL=1;*/

      process_lines(
	     p_change_id     => p_change_id
	    ,p_seq_num_incr  => l_seq_num_incr
	    ,p_line_type_id  => l_line_type_id
	    ,p_name          => add_risk_rec.name
	    ,p_description   => add_risk_rec.description
	    ,p_entity_name1  => 'AMW_LINE_RISK_ETTY'
	    ,p_entity_name2  => 'AMW_REVISION_ETTY'
	    ,p_pk1_value     => add_risk_rec.risk_id
	  );

	  /*
      CREATE_CHANGE_REQUEST_LINES(
         P_CHANGE_ID      => P_CHANGE_ID
        ,p_seq_num_incr   => L_SEQ_NUM_INCR
        ,p_line_type_id   => L_LINE_TYPE_ID
        ,p_name           => RISK_REC.NAME
        ,p_description    => risk_REC.DESCRIPTION
		,x_change_line_id => l_change_line_id);

      CREATE_SUBJECT_LINES(
         p_change_id      => P_CHANGE_ID
        ,p_change_line_id => L_CHANGE_LINE_ID
        ,p_entity_name    => 'AMW_LINE_RISK_ETTY'
        ,p_pk1_value      => risk_rec.risk_id
        ,p_subject_level  => 1);

      CREATE_SUBJECT_LINES(
         p_change_id      => P_CHANGE_ID
        ,p_change_line_id => L_CHANGE_LINE_ID
        ,p_entity_name    => 'AMW_REVISION_ETTY'
        ,p_pk1_value      => risk_rec.risk_id
        ,p_subject_level  => 2);*/
   END LOOP;

   --loop for DeleteRisk lineType
   for delete_risk_rec in c_delete_risk loop
      l_seq_num_incr := nvl(l_seq_num_incr,0)+10;

      L_DELETE_LINE_TYPE_ID := NULL;       --SET THIS TO NULL FOR DELETE RISK LINES
	  L_DELETE_CHANGE_SUBJECT_ID := NULL;  --SET THIS TO NULL FOR DELETE RISK LINES
      l_line_type_id := get_line_type_id('AMW_PROCESS_RL_APPROVAL','AMW_LINE_DEL_RISK_ETTY','AMW_REVISION_ETTY');

	  process_lines(
	     p_change_id     => p_change_id
	    ,p_seq_num_incr  => l_seq_num_incr
	    ,p_line_type_id  => l_line_type_id
	    ,p_name          => delete_risk_rec.name
	    ,p_description   => delete_risk_rec.description
	    ,p_entity_name1  => 'AMW_LINE_DEL_RISK_ETTY'
	    ,p_entity_name2  => 'AMW_REVISION_ETTY'
	    ,p_pk1_value     => delete_risk_rec.risk_id
	  );
   end loop;

   --loop for AddControl lineType
   for add_ctrl_rec in c_add_ctrl loop
      l_seq_num_incr := nvl(l_seq_num_incr,0)+10;

      L_DELETE_LINE_TYPE_ID := NULL;       --SET THIS TO NULL FOR DELETE RISK LINES
	  L_DELETE_CHANGE_SUBJECT_ID := NULL;  --SET THIS TO NULL FOR DELETE RISK LINES
      l_line_type_id := get_line_type_id('AMW_PROCESS_RL_APPROVAL','AMW_LINE_CTRL_ETTY','AMW_REVISION_ETTY');

	  process_lines(
	     p_change_id     => p_change_id
	    ,p_seq_num_incr  => l_seq_num_incr
	    ,p_line_type_id  => l_line_type_id
	    ,p_name          => add_ctrl_rec.name
	    ,p_description   => add_ctrl_rec.description
	    ,p_entity_name1  => 'AMW_LINE_CTRL_ETTY'
	    ,p_entity_name2  => 'AMW_REVISION_ETTY'
	    ,p_pk1_value     => add_ctrl_rec.control_id
	  );
   end loop;

   --loop for DeleteControl lineType
   for delete_ctrl_rec in c_delete_ctrl loop
      l_seq_num_incr := nvl(l_seq_num_incr,0)+10;

      L_DELETE_LINE_TYPE_ID := NULL;       --SET THIS TO NULL FOR DELETE RISK LINES
	  L_DELETE_CHANGE_SUBJECT_ID := NULL;  --SET THIS TO NULL FOR DELETE RISK LINES
      l_line_type_id := get_line_type_id('AMW_PROCESS_RL_APPROVAL','AMW_LINE_DEL_CTRL_ETTY','AMW_REVISION_ETTY');

	  process_lines(
	     p_change_id     => p_change_id
	    ,p_seq_num_incr  => l_seq_num_incr
	    ,p_line_type_id  => l_line_type_id
	    ,p_name          => delete_ctrl_rec.name
	    ,p_description   => delete_ctrl_rec.description
	    ,p_entity_name1  => 'AMW_LINE_DEL_CTRL_ETTY'
	    ,p_entity_name2  => 'AMW_REVISION_ETTY'
	    ,p_pk1_value     => delete_ctrl_rec.control_id
	  );
   end loop;
/**
   --Create Lines for All Controls
   FOR CTRL_REC IN C_ASSOCIATED_CTRLS LOOP
      L_SEQ_NUM_INCR := NVL(L_SEQ_NUM_INCR,0)+10;

	  --GET THE LINE_TYPE_ID FOR RISK LINE TYPE
	  L_LINE_TYPE_ID := NULL;       --SET THIS TO NULL FOR CONTROL LINES
	  L_CHANGE_SUBJECT_ID := NULL;  --SET THIS TO NULL FOR CONTROL LINES
	  l_line_type_id := get_line_type_id('AMW_PROCESS_RL_APPROVAL','AMW_LINE_CTRL_ETTY','AMW_REVISION_ETTY');
	  select ecot.change_order_type_id
	        ,ESE.SUBJECT_ID
        INTO L_LINE_TYPE_ID
	        ,L_CHANGE_SUBJECT_ID
        from eng_change_order_types ecot
            ,eng_subject_entities ese
       where ecot.change_mgmt_type_code='AMW_PROCESS_RL_APPROVAL'
         and ecot.SUBJECT_ID=ese.subject_id
         AND ESE.ENTITY_NAME='AMW_LINE_CTRL_ETTY'
         AND ESE.PARENT_ENTITY_NAME='AMW_REVISION_ETTY'
         AND ESE.SUBJECT_LEVEL=1;

      ---02.02.2005 npanandi: added below stmnt
      ---get the line_type_id for 'Delete Control' lineType
      L_DELETE_LINE_TYPE_ID := NULL;       --SET THIS TO NULL FOR DELETE CONTROL LINES
	  L_DELETE_CHANGE_SUBJECT_ID := NULL;  --SET THIS TO NULL FOR DELETE CONTROL LINES
      l_line_type_id := get_line_type_id('AMW_PROCESS_RL_APPROVAL','AMW_LINE_DEL_CTRL_ETTY','AMW_REVISION_ETTY');
	  select ecot.change_order_type_id
	        ,ESE.SUBJECT_ID
        INTO L_DELETE_LINE_TYPE_ID
            ,L_DELETE_CHANGE_SUBJECT_ID
        from eng_change_order_types ecot
            ,eng_subject_entities ese
       where ecot.change_mgmt_type_code='AMW_PROCESS_RL_APPROVAL'
         and ecot.SUBJECT_ID=ese.subject_id
         AND ESE.ENTITY_NAME='AMW_LINE_DEL_CTRL_ETTY'
         AND ESE.PARENT_ENTITY_NAME='AMW_REVISION_ETTY'
         AND ESE.SUBJECT_LEVEL=1;
      ---02.02.2005 npanandi: ends above stmnt

      CREATE_CHANGE_REQUEST_LINES(
         P_CHANGE_ID      => P_CHANGE_ID
        ,p_seq_num_incr   => L_SEQ_NUM_INCR
        ,p_line_type_id   => L_LINE_TYPE_ID
        ,p_name           => CTRL_REC.NAME
        ,p_description    => CTRL_REC.DESCRIPTION
		,x_change_line_id => l_change_line_id);

      CREATE_SUBJECT_LINES(
         p_change_id      => P_CHANGE_ID
        ,p_change_line_id => L_CHANGE_LINE_ID
        ,p_entity_name    => 'AMW_LINE_CTRL_ETTY'
        ,p_pk1_value      => ctrl_rec.control_id
        ,p_subject_level  => 1);

      CREATE_SUBJECT_LINES(
         p_change_id      => P_CHANGE_ID
        ,p_change_line_id => L_CHANGE_LINE_ID
        ,p_entity_name    => 'AMW_REVISION_ETTY'
        ,p_pk1_value      => ctrl_rec.control_id
        ,p_subject_level  => 2);
   END LOOP;
   **/

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;

END CREATE_LINES_RL;

/*****************************************************************************/
PROCEDURE CREATE_LINES_ORG (
   P_CHANGE_ID      IN NUMBER
  ,P_PK1            IN NUMBER  --ORGANIZATION_ID
  ,P_PK2            IN NUMBER  --PROCESS_ID
  ,P_PK3            IN NUMBER  --REVISION_NUMBER
  ,P_PK4            IN NUMBER
  ,P_PK5            IN NUMBER
  ,P_ENTITY_NAME    IN VARCHAR2 --AMW_REVISION_ETTY for Risk Library Approvals
  --02.15.2005 npanandi: added below parameter for ProcessApprovalOption parameter value
  ,p_approval_option in varchar2
)
IS
/****************************************************/
   --02.15.2004 npanandi: cursor to get downward Proceses which will
   --also get approved alongwith the Change Request for the Current Process
   --this is valid only if the ProcessApprovalOption parameter is 'B'
   cursor c_draft_org_child_processes is
   		SELECT apo.process_id process_id,
       apo.display_name display_name,
       apo.revision_number revision_number,
       apo.approval_status approval_status,
       apo.description description
from amw_process_organization_vl apo, amw_latest_hierarchies alh
where
    alh.organization_id = p_pk1
    and alh.parent_id = p_pk2
    and apo.process_id = alh.child_id
    and apo.end_date is null
    and apo.approval_date is null;

    --ko replacing the below clause for removing amw_org_hierarchy_denorm usage...
/*
      select parent_child_id as process_id
	        ,a.DISPLAY_NAME
			,a.REVISION_NUMBER
			,a.approval_status
			,a.description
        from amw_org_hierarchy_denorm d, amw_latest_rev_org_v a
       where d.process_id = p_pk2 --processId
         and d.organization_id = p_pk1 --organizationId
         and up_down_ind = 'D'
         and hierarchy_type = 'L'
         and a.process_id = d.PARENT_CHILD_ID
         and a.organization_id = p_pk1 --organizationId
         and a.end_date is null
         and a.approval_status <> 'A'
		 and a.process_id in (select child_process_id
		                        from AMW_curr_app_HIERARCHY_ORG_V
							   where parent_process_id=p_pk2
							     and child_organization_id=p_pk1);
*/
   ---02.17.2004 npanandi: cursor to get processes for AddProcess lineType
   ---only 1 level below i.e. immediate child processes
   cursor c_add_process is
      SELECT ALR.PROCESS_ID
	        ,ALR.DISPLAY_NAME
		    ,ALR.DESCRIPTION
		    ,ALR.PROCESS_CODE
		    --,alr.revision_number
	    FROM amw_latest_rev_org_v ALR
	        ,AMW_LATEST_HIERARCHY_ORG_V APHD
	   WHERE APHD.CHILD_process_ID=ALR.PROCESS_ID
	     and alr.ORGANIZATION_ID=p_pk1 --organizationId
	     and aphd.CHILD_ORGANIZATION_ID=p_pk1 --organizationId
	     AND APHD.parent_PROCESS_ID=p_pk2 --processId
	  minus
	  SELECT ALR.PROCESS_ID
	        ,ALR.DISPLAY_NAME
		    ,ALR.DESCRIPTION
		    ,ALR.PROCESS_CODE
		    --,alr.revision_number
	    FROM amw_latest_rev_org_v ALR
	        ,AMW_CURR_APP_HIERARCHY_ORG_V APHD
	   WHERE APHD.CHILD_process_ID=ALR.PROCESS_ID
	     and alr.ORGANIZATION_ID=p_pk1 --organizationId
	     and aphd.CHILD_ORGANIZATION_ID=p_pk1 --organizationId
	     AND APHD.parent_PROCESS_ID=p_pk2; --processId

   ---02.17.2004 npanandi: cursor to get processes for DeleteProcess lineType
   ---only 1 level below i.e. immediate child processes
   cursor c_delete_process is
      SELECT ALR.PROCESS_ID
	        ,ALR.DISPLAY_NAME
		    ,ALR.DESCRIPTION
		    ,ALR.PROCESS_CODE
		    --,alr.revision_number
	    FROM amw_latest_rev_org_v ALR
	        ,AMW_CURR_APP_HIERARCHY_ORG_V APHD
	   WHERE APHD.CHILD_process_ID=ALR.PROCESS_ID
	     and alr.ORGANIZATION_ID=p_pk1 --organizationId
	     and aphd.CHILD_ORGANIZATION_ID=p_pk1 --organizationId
	     AND APHD.parent_PROCESS_ID=p_pk2 --processId
	  minus
      SELECT ALR.PROCESS_ID
	        ,ALR.DISPLAY_NAME
		    ,ALR.DESCRIPTION
		    ,ALR.PROCESS_CODE
		    --,alr.revision_number
	    FROM amw_latest_rev_org_v ALR
	        ,AMW_LATEST_HIERARCHY_ORG_V APHD
	   WHERE APHD.CHILD_process_ID=ALR.PROCESS_ID
	     and alr.ORGANIZATION_ID=p_pk1 --organizationId
	     and aphd.CHILD_ORGANIZATION_ID=p_pk1 --organizationId
	     AND APHD.parent_PROCESS_ID=p_pk2; --processId

   cursor c_add_risk is
      (select arav.risk_id
	         ,ARAV.NAME
	         ,ARAV.DESCRIPTION
	     FROM AMW_RISKS_ALL_VL ARAV
	         ,AMW_RISK_ASSOCIATIONS ARA
	    WHERE ARA.RISK_ID=ARAV.RISK_ID
	      AND ARAV.LATEST_REVISION_FLAG='Y'
	      AND ARA.OBJECT_TYPE='PROCESS_ORG'
	      AND ARA.DELETION_DATE IS NULL
	      AND ARA.PK1=p_pk1 --organizationId
	      and ara.pk2=p_pk2) --processId
      minus
	  (select arav.risk_id
	         ,ARAV.NAME
	         ,ARAV.DESCRIPTION
	     FROM AMW_RISKS_ALL_VL ARAV
	         ,AMW_RISK_ASSOCIATIONS ARA
	    WHERE ARA.RISK_ID=ARAV.RISK_ID
	      AND ARAV.LATEST_REVISION_FLAG='Y'
	      AND ARA.OBJECT_TYPE='PROCESS_ORG'
	      AND ARA.APPROVAL_DATE IS not NULL
	      and ara.DELETION_APPROVAL_DATE is null
	      and ara.pk1=p_pk1 --organizationId
	      AND ARA.PK2=p_pk2); --processId

   cursor c_delete_risk is
      (select arav.risk_id
	         ,ARAV.NAME
	         ,ARAV.DESCRIPTION
	     FROM AMW_RISKS_ALL_VL ARAV
	         ,AMW_RISK_ASSOCIATIONS ARA
	    WHERE ARA.RISK_ID=ARAV.RISK_ID
	      AND ARAV.LATEST_REVISION_FLAG='Y'
	      AND ARA.OBJECT_TYPE='PROCESS_ORG'
	      AND ARA.APPROVAL_DATE IS not NULL
	      and ara.DELETION_APPROVAL_DATE is null
	      and ara.pk1=p_pk1 --organizationId
	      AND ARA.PK2=p_pk2) --processId
      minus
	  (select arav.risk_id
	         ,ARAV.NAME
	         ,ARAV.DESCRIPTION
	     FROM AMW_RISKS_ALL_VL ARAV
	         ,AMW_RISK_ASSOCIATIONS ARA
	    WHERE ARA.RISK_ID=ARAV.RISK_ID
	      AND ARAV.LATEST_REVISION_FLAG='Y'
	      AND ARA.OBJECT_TYPE='PROCESS_ORG'
	      AND ARA.DELETION_DATE IS NULL
	      AND ARA.PK1=p_pk1 --organizationId
	      and ara.pk2=p_pk2); --processId

   cursor c_add_ctrl is
      (select acav.control_id
		     ,acav.NAME
		     ,acav.DESCRIPTION
	     FROM AMW_CONTROLS_ALL_VL acav
	         ,AMW_CONTROL_ASSOCIATIONS aca
	    WHERE aca.control_id=acav.control_id
	      AND acav.LATEST_REVISION_FLAG='Y'
	      AND aca.OBJECT_TYPE='RISK_ORG'
	      AND aca.DELETION_DATE IS NULL
	      AND aca.PK1=p_pk1 ---organizationId
		  and aca.pk2=p_pk2) --processId
      minus
	  (select acav.control_id
	         ,acav.NAME
	         ,acav.DESCRIPTION
	    FROM AMW_CONTROLS_ALL_VL acav
	        ,AMW_CONTROL_ASSOCIATIONS aca
	   WHERE aca.control_id=acav.control_id
	     AND acav.LATEST_REVISION_FLAG='Y'
	     AND aca.OBJECT_TYPE='RISK_ORG'
	     AND aca.approval_DATE IS not NULL
	     and aca.deletion_approval_date is null
	     AND aca.PK1=p_pk1 ---organizationId
	     and aca.pk2=p_pk2); --processId

   cursor c_delete_ctrl is
      (select acav.control_id
	         ,acav.NAME
	         ,acav.DESCRIPTION
	    FROM AMW_CONTROLS_ALL_VL acav
	        ,AMW_CONTROL_ASSOCIATIONS aca
	   WHERE aca.control_id=acav.control_id
	     AND acav.LATEST_REVISION_FLAG='Y'
	     AND aca.OBJECT_TYPE='RISK_ORG'
	     AND aca.approval_DATE IS not NULL
	     and aca.deletion_approval_date is null
	     AND aca.PK1=p_pk1 ---organizationId
	     and aca.pk2=p_pk2) --processId
      minus
	  (select acav.control_id
		     ,acav.NAME
		     ,acav.DESCRIPTION
	     FROM AMW_CONTROLS_ALL_VL acav
	         ,AMW_CONTROL_ASSOCIATIONS aca
	    WHERE aca.control_id=acav.control_id
	      AND acav.LATEST_REVISION_FLAG='Y'
	      AND aca.OBJECT_TYPE='RISK_ORG'
	      AND aca.DELETION_DATE IS NULL
	      AND aca.PK1=p_pk1 ---organizationId
		  and aca.pk2=p_pk2); --processId

   ---CURSOR TO GET ALL CONTROLS FOR A GIVEN PROCESS IN ORG
   CURSOR C_ASSOCIATED_CTRLS IS
      SELECT ACAV.CONTROL_ID
            ,ACAV.NAME
            ,ACAV.DESCRIPTION
        FROM AMW_CONTROLS_ALL_VL ACAV
            ,AMW_CONTROL_ASSOCIATIONS ACA
	        ,(select distinct child_id from
              amw_latest_hierarchies
              START WITH CHILD_ID = p_pk2 AND ORGANIZATION_ID = p_pk1
              CONNECT BY PRIOR CHILD_ID = PARENT_ID
              and  organization_id = p_pk1 ) AOHD
       WHERE ACA.PK1 = p_pk1
         AND AOHD.CHILD_ID=ACA.PK2
         AND ACA.OBJECT_TYPE='RISK_ORG'
         AND ACA.DELETION_DATE IS NULL
         AND ACA.CONTROL_ID=ACAV.CONTROL_ID
         AND ACAV.CURR_APPROVED_FLAG='Y' ;

--ko replacing the below clause for removing amw_org_hierarchy_denorm usage...
/*
   CURSOR C_ASSOCIATED_CTRLS IS
      SELECT ACAV.CONTROL_ID
            ,ACAV.NAME
            ,ACAV.DESCRIPTION
        FROM AMW_CONTROLS_ALL_VL ACAV
            ,AMW_CONTROL_ASSOCIATIONS ACA
	        ,AMW_ORG_HIERARCHY_DENORM AOHD
       WHERE AOHD.UP_DOWN_IND='D'
         AND AOHD.ORGANIZATION_ID=ACA.PK1
         AND AOHD.PARENT_CHILD_ID=ACA.PK2
         AND ACA.OBJECT_TYPE='RISK_ORG'
         AND ACA.DELETION_DATE IS NULL
         AND ACA.CONTROL_ID=ACAV.CONTROL_ID
         AND ACAV.CURR_APPROVED_FLAG='Y'
         AND AOHD.ORGANIZATION_ID=P_PK1
		 AND AOHD.PROCESS_ID=P_PK2
         --NPANANDI 12.16.2004: ADDED BELOW TO RESTRICT ROWS RETURNED
		 --TO BE THOSE FROM LATEST HIERARCHY
         AND AOHD.HIERARCHY_TYPE='L'
      UNION
	  SELECT ACAV.CONTROL_ID
	        ,ACAV.NAME
	        ,ACAV.DESCRIPTION
	    FROM AMW_CONTROLS_ALL_VL ACAV
	        ,AMW_CONTROL_ASSOCIATIONS ACA
	   WHERE ACA.OBJECT_TYPE='RISK_ORG'
	     AND ACA.DELETION_DATE IS NULL
	     AND ACAV.LATEST_REVISION_FLAG='Y'
		 AND ACAV.CONTROL_ID=ACA.CONTROL_ID
	     AND ACA.PK1=P_PK1 --ORGID
		 AND ACA.PK2=P_PK2; --PROCESSID
*/

   L_SEQ_NUM_INCR       NUMBER;
   L_CHANGE_LINE_ID     NUMBER;
   L_CHANGE_SUBJECT_ID	NUMBER;
   L_LINE_TYPE_ID       NUMBER;
   LX_ROW_ID            VARCHAR2(255);

   LX_RETURN_STATUS	    VARCHAR2(30);
   LX_MSG_COUNT         NUMBER;
   LX_MSG_DATA          VARCHAR2(2000);

   --02.02.2005 npanandi: added below vars for Delete Line Types
   L_DELETE_CHANGE_SUBJECT_ID	NUMBER;
   L_DELETE_LINE_TYPE_ID       NUMBER;

   e_no_import_access               		 EXCEPTION;
   e_invalid_requestor_id           		 EXCEPTION;

   l_revision_number    number;
BEGIN
   /* 02.15.2004 npanandi: added below if stmnt/cursor loop
      for creating lines for all downward processes which are
	  also undergoing Change alongwith the parent Process for which
	  the Change Request is made
    */
   --if p_approval_option = 'B'--> Automatically Approve all descendants
   --if p_approval_option = 'A'--> Approval Independent of Descendant's Approval Status
   if(p_approval_option = 'B')then
      for draft_proc_rec in c_draft_org_child_processes loop
	     L_SEQ_NUM_INCR := NVL(L_SEQ_NUM_INCR,0)+10;

		 --get the line_type_id for this child_approval_process_line_type
		 L_LINE_TYPE_ID := NULL;       --SET THIS TO NULL FOR PROCESS LINES
	     L_CHANGE_SUBJECT_ID := NULL;  --SET THIS TO NULL FOR PROCESS LINES

		 --- ***************************** WARNING STARTS *****************************
		 --- change the values of the parameters below after seeding correct lineType
		 --- ***************************** WARNING ENDS *****************************
		 l_line_type_id := get_line_type_id('AMW_PROCESS_ORG_APPROVAL','AMW_ORG_LINE_APPR_PROC_ETTY','AMW_ORG_REV_ETTY');

         process_lines(
		    p_change_id     => p_change_id
		   ,p_seq_num_incr  => l_seq_num_incr
		   ,p_line_type_id  => l_line_type_id
		   ,p_name          => draft_proc_rec.display_name
		   ,p_description   => draft_proc_rec.description
		   ,p_entity_name1  => 'AMW_ORG_LINE_APPR_PROC_ETTY'
		   ,p_entity_name2  => 'AMW_ORG_REV_ETTY'
		   ,p_pk1_value     => p_pk1 ---organizationId
		   ,p_pk2_value     => draft_proc_rec.process_id --processId
		   ,p_pk3_value     => draft_proc_rec.revision_number --revisionNumber
		 );
	  end loop;
   end if;

   --02.17.2005 npanandi: loop for AddProcess LineType
   for add_proc_rec in c_add_process loop
      l_seq_num_incr := nvl(l_seq_num_incr,0)+10;

	  --GET THE LINE_TYPE_ID FOR PROCESS LINE TYPE
	  L_LINE_TYPE_ID := NULL;       --SET THIS TO NULL FOR PROCESS LINES
	  L_CHANGE_SUBJECT_ID := NULL;  --SET THIS TO NULL FOR PROCESS LINES
	  l_line_type_id := get_line_type_id('AMW_PROCESS_ORG_APPROVAL','AMW_ORG_LINE_PROCESS_ETTY','AMW_ORG_REV_ETTY');

	  ---02.17.2005 npanandi: below SQL gives the revisionNumber
	  ---of this process from the AmwLatestRevOrgV view
	  --- ****** reason why RevisionNumber is not incl. in Cursor stmt: ******
	  ---there may be an immediate child Process, which is also in Draft status
	  ---in this case, the AddProcess Cursor's 'minus' clause causes problems in
	  ---revisionNumber data, and incorrect resultSet is obtained.
	  select revision_number into l_revision_number
	    from amw_latest_rev_org_v
	   where organization_id=p_pk1
	     and process_id=add_proc_rec.process_id;

      process_lines(
	     p_change_id     => p_change_id
	    ,p_seq_num_incr  => l_seq_num_incr
	    ,p_line_type_id  => l_line_type_id
	    ,p_name          => add_proc_rec.display_name
	    ,p_description   => add_proc_rec.description
	    ,p_entity_name1  => 'AMW_ORG_LINE_PROCESS_ETTY'
	    ,p_entity_name2  => 'AMW_ORG_REV_ETTY'
	    ,p_pk1_value     => p_pk1 ---organizationId
		,p_pk2_value     => add_proc_rec.process_id --processId
		,p_pk3_value     => l_revision_number --revisionNumber
	  );
   end loop;

   ---02.17.2005 npanandi: added below loop for DeleteProcess lineTypes
   for delete_proc_rec in c_delete_process loop
      l_seq_num_incr := nvl(l_seq_num_incr,0)+10;

	  ---02.02.2005 npanandi: added below stmnt
      ---get the line_type_id for 'Delete Process' lineType
      L_DELETE_LINE_TYPE_ID := NULL;       --SET THIS TO NULL FOR DELETE PROCESS LINES
	  L_DELETE_CHANGE_SUBJECT_ID := NULL;  --SET THIS TO NULL FOR DELETE PROCESS LINES

	  l_line_type_id := get_line_type_id('AMW_PROCESS_ORG_APPROVAL','AMW_ORG_LINE_DEL_PROCESS_ETTY','AMW_ORG_REV_ETTY');
      ---02.02.2005 npanandi: ends above stmnt

	  ---02.17.2005 npanandi: below SQL gives the revisionNumber
	  ---of this process from the AmwCurrAppHierarchyOrgV view
	  --- ****** reason why RevisionNumber is not incl. in Cursor stmt: ******
	  ---there may be an immediate child Process, which is also in Draft status
	  ---in this case, the DeleteProcess Cursor's 'minus' clause causes problems in
	  ---revisionNumber data, and incorrect resultSet is obtained.
	  select child_revision_number into l_revision_number
		from amw_curr_app_hierarchy_org_v
	   where child_organization_id=p_pk1 --organizationId
		 and parent_process_id=p_pk2 --parentProcessId
		 and child_process_id=delete_proc_rec.process_id; --childProcessId;

	  process_lines(
	     p_change_id     => p_change_id
	    ,p_seq_num_incr  => l_seq_num_incr
	    ,p_line_type_id  => l_line_type_id
	    ,p_name          => delete_proc_rec.display_name
	    ,p_description   => delete_proc_rec.description
	    ,p_entity_name1  => 'AMW_ORG_LINE_DEL_PROCESS_ETTY'
	    ,p_entity_name2  => 'AMW_ORG_REV_ETTY'
		,p_pk1_value     => p_pk1 --organizationId
	    ,p_pk2_value     => delete_proc_rec.process_id
	    ,p_pk3_value     => l_revision_number
	  );
   end loop;

   --02.17.2005 npanandi: loop for AddRisk lineType
   FOR add_RISK_REC IN c_add_risk LOOP
      L_SEQ_NUM_INCR := NVL(L_SEQ_NUM_INCR,0)+10;

	  --GET THE LINE_TYPE_ID FOR RISK LINE TYPE
	  L_LINE_TYPE_ID := NULL;       --SET THIS TO NULL FOR RISK LINES
	  L_CHANGE_SUBJECT_ID := NULL;  --SET THIS TO NULL FOR RISK LINES
	  l_line_type_id := get_line_type_id('AMW_PROCESS_ORG_APPROVAL','AMW_ORG_LINE_RISK_ETTY','AMW_ORG_REV_ETTY');

      process_lines(
	     p_change_id     => p_change_id
	    ,p_seq_num_incr  => l_seq_num_incr
	    ,p_line_type_id  => l_line_type_id
	    ,p_name          => add_risk_rec.name
	    ,p_description   => add_risk_rec.description
	    ,p_entity_name1  => 'AMW_ORG_LINE_RISK_ETTY'
	    ,p_entity_name2  => 'AMW_ORG_REV_ETTY'
	    ,p_pk1_value     => add_risk_rec.risk_id
	  );
   END LOOP;

   --02.17.2005 npanandi: loop for DeleteRisk lineType
   FOR delete_RISK_REC IN c_delete_risk LOOP
      L_SEQ_NUM_INCR := NVL(L_SEQ_NUM_INCR,0)+10;

	  --GET THE LINE_TYPE_ID FOR RISK LINE TYPE
	  L_LINE_TYPE_ID := NULL;       --SET THIS TO NULL FOR RISK LINES
	  L_CHANGE_SUBJECT_ID := NULL;  --SET THIS TO NULL FOR RISK LINES
	  l_line_type_id := get_line_type_id('AMW_PROCESS_ORG_APPROVAL','AMW_ORG_LINE_DEL_RISK_ETTY','AMW_ORG_REV_ETTY');

      process_lines(
	     p_change_id     => p_change_id
	    ,p_seq_num_incr  => l_seq_num_incr
	    ,p_line_type_id  => l_line_type_id
	    ,p_name          => delete_risk_rec.name
	    ,p_description   => delete_risk_rec.description
	    ,p_entity_name1  => 'AMW_ORG_LINE_DEL_RISK_ETTY'
	    ,p_entity_name2  => 'AMW_ORG_REV_ETTY'
	    ,p_pk1_value     => delete_risk_rec.risk_id
	  );
   END LOOP;

   --02.17.2005 npanandi: loop for AddControl lineType
   for add_ctrl_rec in c_add_ctrl loop
      l_seq_num_incr := nvl(l_seq_num_incr,0)+10;

      L_DELETE_LINE_TYPE_ID := NULL;       --SET THIS TO NULL FOR DELETE RISK LINES
	  L_DELETE_CHANGE_SUBJECT_ID := NULL;  --SET THIS TO NULL FOR DELETE RISK LINES
      l_line_type_id := get_line_type_id('AMW_PROCESS_ORG_APPROVAL','AMW_ORG_LINE_CTRL_ETTY','AMW_ORG_REV_ETTY');

	  process_lines(
	     p_change_id     => p_change_id
	    ,p_seq_num_incr  => l_seq_num_incr
	    ,p_line_type_id  => l_line_type_id
	    ,p_name          => add_ctrl_rec.name
	    ,p_description   => add_ctrl_rec.description
	    ,p_entity_name1  => 'AMW_ORG_LINE_CTRL_ETTY'
	    ,p_entity_name2  => 'AMW_ORG_REV_ETTY'
	    ,p_pk1_value     => add_ctrl_rec.control_id
	  );
   end loop;

   --02.17.2005 npanandi: loop for DeleteControl lineType
   for delete_ctrl_rec in c_delete_ctrl loop
      l_seq_num_incr := nvl(l_seq_num_incr,0)+10;

      L_DELETE_LINE_TYPE_ID := NULL;       --SET THIS TO NULL FOR DELETE RISK LINES
	  L_DELETE_CHANGE_SUBJECT_ID := NULL;  --SET THIS TO NULL FOR DELETE RISK LINES
      l_line_type_id := get_line_type_id('AMW_PROCESS_ORG_APPROVAL','AMW_ORG_LINE_DEL_CTRL_ETTY','AMW_ORG_REV_ETTY');

	  process_lines(
	     p_change_id     => p_change_id
	    ,p_seq_num_incr  => l_seq_num_incr
	    ,p_line_type_id  => l_line_type_id
	    ,p_name          => delete_ctrl_rec.name
	    ,p_description   => delete_ctrl_rec.description
	    ,p_entity_name1  => 'AMW_ORG_LINE_DEL_CTRL_ETTY'
	    ,p_entity_name2  => 'AMW_ORG_REV_ETTY'
	    ,p_pk1_value     => delete_ctrl_rec.control_id
	  );
   end loop;
/*
   --Create Lines for All Controls
   FOR CTRL_REC IN C_ASSOCIATED_CTRLS LOOP
      L_SEQ_NUM_INCR := NVL(L_SEQ_NUM_INCR,0)+10;

      --GET THE LINE_TYPE_ID FOR PROCESS LINE TYPE
	  L_LINE_TYPE_ID := NULL;       --SET THIS TO NULL FOR PROCESS LINES
	  L_CHANGE_SUBJECT_ID := NULL;  --SET THIS TO NULL FOR PROCESS LINES
	  l_line_type_id := get_line_type_id('AMW_PROCESS_ORG_APPROVAL','AMW_ORG_LINE_CTRL_ETTY','AMW_ORG_REV_ETTY');
	  select ecot.change_order_type_id
	        ,ESE.SUBJECT_ID
	    INTO L_LINE_TYPE_ID
		    ,L_CHANGE_SUBJECT_ID
        from eng_change_order_types ecot
            ,eng_subject_entities ese
       where ecot.change_mgmt_type_code='AMW_PROCESS_ORG_APPROVAL'
         and ecot.SUBJECT_ID=ese.subject_id
         AND ESE.ENTITY_NAME='AMW_ORG_LINE_CTRL_ETTY'
         AND ESE.PARENT_ENTITY_NAME='AMW_ORG_REV_ETTY'
         AND ESE.SUBJECT_LEVEL=1;

      ---02.02.2005 npanandi: added below stmnt
      ---get the line_type_id for 'Delete Control' lineType
      L_DELETE_LINE_TYPE_ID := NULL;       --SET THIS TO NULL FOR DELETE PROCESS LINES
	  L_DELETE_CHANGE_SUBJECT_ID := NULL;  --SET THIS TO NULL FOR DELETE PROCESS LINES
      l_line_type_id := get_line_type_id('AMW_PROCESS_ORG_APPROVAL','AMW_ORG_LINE_DEL_CTRL_ETTY','AMW_ORG_REV_ETTY');
	  select ecot.change_order_type_id
	        ,ESE.SUBJECT_ID
        INTO L_DELETE_LINE_TYPE_ID
            ,L_DELETE_CHANGE_SUBJECT_ID
        from eng_change_order_types ecot
            ,eng_subject_entities ese
       where ecot.change_mgmt_type_code='AMW_PROCESS_ORG_APPROVAL'
         and ecot.SUBJECT_ID=ese.subject_id
         AND ESE.ENTITY_NAME='AMW_ORG_LINE_DEL_CTRL_ETTY'
         AND ESE.PARENT_ENTITY_NAME='AMW_ORG_REV_ETTY'
         AND ESE.SUBJECT_LEVEL=1;
      ---02.02.2005 npanandi: ends above stmnt

      CREATE_CHANGE_REQUEST_LINES(
         P_CHANGE_ID      => P_CHANGE_ID
        ,p_seq_num_incr   => L_SEQ_NUM_INCR
        ,p_line_type_id   => L_LINE_TYPE_ID
        ,p_name           => CTRL_REC.NAME
        ,p_description    => CTRL_REC.DESCRIPTION
		,x_change_line_id => l_change_line_id);

      CREATE_SUBJECT_LINES(
         p_change_id      => P_CHANGE_ID
        ,p_change_line_id => L_CHANGE_LINE_ID
        ,p_entity_name    => 'AMW_ORG_LINE_CTRL_ETTY'
        ,p_pk1_value      => CTRL_REC.control_id
        ,p_subject_level  => 1);

      CREATE_SUBJECT_LINES(
         p_change_id      => P_CHANGE_ID
        ,p_change_line_id => L_CHANGE_LINE_ID
        ,p_entity_name    => 'AMW_ORG_REV_ETTY'
        ,p_pk1_value      => CTRL_REC.control_id
        ,p_subject_level  => 2);

      ---CREATE_SUBJECT_LINES(P_CHANGE_ID,L_CHANGE_LINE_ID,'AMW_ORG_LINE_CTRL_ETTY',1);
      ---CREATE_SUBJECT_LINES(P_CHANGE_ID,L_CHANGE_LINE_ID,'AMW_ORG_REV_ETTY',2);
   END LOOP;
*/

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;

END CREATE_LINES_ORG;

---
---02.03.2005 npanandi: added below method
---
PROCEDURE CREATE_CHANGE_REQUEST_LINES(
   P_CHANGE_ID      IN NUMBER
  ,p_seq_num_incr   IN NUMBER
  ,p_line_type_id   IN number
  ,p_name           in varchar2
  ,p_description    in varchar2
  ,x_change_line_id out nocopy number)
IS
   l_change_line_id     NUMBER;
   LX_ROW_ID            VARCHAR2(255);
BEGIN
   --get the changeLineId sequence value
   SELECT ENG_CHANGE_LINES_S.NEXTVAL
     INTO L_CHANGE_LINE_ID
     FROM DUAL;

	  ENG_CHANGE_LINES_PKG.INSERT_ROW(
        X_ROWID                         => LX_ROW_ID
       ,X_CHANGE_LINE_ID                => L_CHANGE_LINE_ID
       ,X_REQUEST_ID                    => NULL
       ,X_CHANGE_ID                     => P_CHANGE_ID
       ,X_SEQUENCE_NUMBER               => p_SEQ_NUM_INCR
       ,X_CHANGE_TYPE_ID                => p_LINE_TYPE_ID
       ,X_STATUS_CODE                   => '11'
       ,X_ASSIGNEE_ID                   => NULL --DON'T NEED SINCE LINES AREN'T ASSIGNED
       ,X_NEED_BY_DATE                  => NULL
       ,X_ORIGINAL_SYSTEM_REFERENCE     => NULL
       ,X_NAME                          => p_name
       ,X_DESCRIPTION                   => p_description
       ,X_SCHEDULED_DATE                => NULL
       ,X_IMPLEMENTATION_DATE           => sysdate
       ,X_CANCELATION_DATE              => NULL
       ,X_CREATION_DATE                 => SYSDATE
       ,X_CREATED_BY                    => G_USER_ID
       ,X_LAST_UPDATE_DATE              => SYSDATE
       ,X_LAST_UPDATED_BY               => G_USER_ID
       ,X_LAST_UPDATE_LOGIN             => G_LOGIN_ID
       ,X_PROGRAM_ID                    => NULL
       ,X_PROGRAM_APPLICATION_ID        => NULL
       ,X_PROGRAM_UPDATE_DATE           => NULL
       ,X_APPROVAL_STATUS_TYPE          => NULL
	   ,X_APPROVAL_DATE                 => NULL
       ,X_APPROVAL_REQUEST_DATE         => NULL
       ,X_ROUTE_ID                      => NULL
       ,X_REQUIRED_FLAG                	=> NULL
       ,X_COMPLETE_BEFORE_STATUS_CODE   => NULL
       ,X_START_AFTER_STATUS_CODE       => NULL
      );

	  x_change_line_id := l_change_line_id;
END CREATE_CHANGE_REQUEST_LINES;
--02.03.2005 npanandi: end CreateChangeRequestLines procedure

PROCEDURE CREATE_SUBJECT_LINES(
   P_CHANGE_ID      IN NUMBER
  ,P_CHANGE_LINE_ID IN NUMBER
  ,P_ENTITY_NAME    IN VARCHAR2
  --02.03.2005 npanandi: added pk1 to pk5 to populate for Process/Risk/Ctrl Lines
  ,p_pk1_value      in number
  ,p_pk2_value      in number
  ,p_pk3_value      in number
  ,p_pk4_value      in number
  ,p_pk5_value      in number
  ,P_SUBJECT_LEVEL  IN NUMBER)
IS
   L_CHANGE_SUBJECT_ID NUMBER;
BEGIN
   --Insert into Eng_Change_Subjects
	  SELECT ENG_CHANGE_SUBJECTS_S.NEXTVAL
	    INTO L_CHANGE_SUBJECT_ID
	    FROM DUAL;

	  INSERT INTO ENG_CHANGE_SUBJECTS (
	     CHANGE_SUBJECT_ID
		,CHANGE_ID
		,CHANGE_LINE_ID
		,ENTITY_NAME
		--02.03.2005 npanandi: added pk1 to pk5 to populate for Process/Risk/Ctrl Lines
		,pk1_value
		,pk2_value
		,pk3_value
		,pk4_value
		,pk5_value
		,SUBJECT_LEVEL
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_LOGIN
	  ) VALUES (
	     L_CHANGE_SUBJECT_ID
		,P_CHANGE_ID
		,P_CHANGE_LINE_ID
		,P_ENTITY_NAME
		--02.03.2005 npanandi: added pk1 to pk5 to populate for Process/Risk/Ctrl Lines
		,p_pk1_value
		,p_pk2_value
		,p_pk3_value
		,p_pk4_value
		,p_pk5_value
		,P_SUBJECT_LEVEL
		,SYSDATE
		,G_USER_ID
		,SYSDATE
		,G_USER_ID
		,G_LOGIN_ID
	  );
END CREATE_SUBJECT_LINES;

---
---02.16.2005 npanandi: added method to create lines in
---EngChangeLinesB, EngChangeLinesTl and insert rows in EngChangeSubjects tables
---
PROCEDURE process_lines(
   P_CHANGE_ID      IN NUMBER
  ,p_seq_num_incr   in number
  ,p_line_type_id   in number
  ,p_name           in varchar2
  ,p_description    in varchar2
  ,P_ENTITY_NAME1   IN VARCHAR2
  ,P_ENTITY_NAME2   IN VARCHAR2
  ,p_pk1_value      in number
  ,p_pk2_value      in number
  ,p_pk3_value      in number
  ,p_pk4_value      in number
  ,p_pk5_value      in number)
IS
   l_change_line_id number;
BEGIN
   /*
   dbms_output.put_line( 'p_change_id: '||p_change_id||', p_seq_num_incr: '||p_seq_num_incr);
   dbms_output.put_line( 'p_line_type_id: '||p_line_type_id||', p_name: '||p_name||', p_description: '||p_description);
   dbms_output.put_line( 'p_entity_name1: '||p_entity_name1||', p_entity_name2: '||p_entity_name2);
   dbms_output.put_line( 'p_pk1_value: '||p_pk1_value||', p_pk2_value: '||p_pk2_value||', p_pk3_value: '||p_pk3_value||', p_pk4_value: '||p_pk4_value||', p_pk5_value: '||p_pk5_value);
   dbms_output.put_line( '*******************************************************' );
   */

   CREATE_CHANGE_REQUEST_LINES(
      P_CHANGE_ID      => P_CHANGE_ID
     ,p_seq_num_incr   => p_seq_num_incr
     ,p_line_type_id   => p_line_type_id
     ,p_name           => p_name
     ,p_description    => p_description
	 ,x_change_line_id => l_change_line_id);

   CREATE_SUBJECT_LINES(
      p_change_id      => P_CHANGE_ID
     ,p_change_line_id => L_CHANGE_LINE_ID
     ,p_entity_name    => p_entity_name1
     ,p_pk1_value      => p_pk1_value
     ,p_pk2_value      => p_pk2_value
	 ,p_pk3_value      => p_pk3_value
     ,p_subject_level  => 1);

   CREATE_SUBJECT_LINES(
      p_change_id      => P_CHANGE_ID
     ,p_change_line_id => L_CHANGE_LINE_ID
     ,p_entity_name    => p_entity_name2
     ,p_pk1_value      => p_pk1_value
     ,p_pk2_value      => p_pk2_value
	 ,p_pk3_value      => p_pk3_value
     ,p_subject_level  => 2);

END process_lines;

--
--02.15.2004 npanandi: added below function to get lineTypeId
--given ChangeMgmtTypeCode, EntityName, ParentEntityName
--
FUNCTION get_line_type_id(
   p_change_mgmt_type_code IN varchar2
  ,p_entity_name           in varchar2
  ,p_parent_entity_name    IN VARCHAR2) RETURN number
IS
   L_LINE_TYPE_ID number;
BEGIN
   select ecot.change_order_type_id
	 INTO L_LINE_TYPE_ID
     from eng_change_order_types ecot
         ,eng_subject_entities ese
    where ecot.change_mgmt_type_code=p_change_mgmt_type_code
      and ecot.SUBJECT_ID=ese.subject_id
      AND ESE.ENTITY_NAME=p_entity_name
      AND ESE.PARENT_ENTITY_NAME=p_parent_entity_name
      AND ESE.SUBJECT_LEVEL=1;

   return L_LINE_TYPE_ID;
END get_line_type_id;

END AMW_CREATE_LINES_PKG;

/
