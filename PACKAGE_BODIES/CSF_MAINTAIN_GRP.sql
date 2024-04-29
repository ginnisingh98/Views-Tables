--------------------------------------------------------
--  DDL for Package Body CSF_MAINTAIN_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_MAINTAIN_GRP" as
/* $Header: csfpurgb.pls 120.9 2006/05/10 10:13:38 hhaugeru noship $ */
--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below

G_PKG_NAME     CONSTANT VARCHAR2(30):= 'CSF_MAINTAIN_GRP';

PROCEDURE Validate_FieldServiceObjects(
      P_API_VERSION                 IN        NUMBER,
      P_INIT_MSG_LIST              IN   VARCHAR2     := FND_API.G_FALSE,
      P_COMMIT                     IN   VARCHAR2     := FND_API.G_FALSE,
      P_PROCESSING_SET_ID                 IN        NUMBER,
      P_OBJECT_TYPE                IN  VARCHAR2,
      X_RETURN_STATUS              IN   OUT NOCOPY  VARCHAR2,
      X_MSG_COUNT                 IN OUT NOCOPY   NUMBER,
      X_MSG_DATA                 IN OUT NOCOPY VARCHAR2)
   IS

l_api_name                CONSTANT VARCHAR2(30) := 'Validate_FieldServiceObjects';
l_api_version_number      CONSTANT NUMBER   := 1.0;

l_return_status    VARCHAR2(1);
l_msg_count        NUMBER;
l_msg_data         VARCHAR2(2000);

   BEGIN

     SAVEPOINT Validate_FieldServiceObjects;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list
      FND_MSG_PUB.initialize;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

/*
Validation logic
-----------------
1	Check if the incident ids associated to the processing set id (i/p parameter) has incident links to CMRO objects.
1.1	If this check returns true,
1.1.1	Mark the corresponding incident id as NOT a candidate for purge
2	Invoke the mobile validation API to verify if the incident ids associated to the processing set id (i/p parameter) are eligible for purge. This API will mark those incident ids which are NOT candidates for purge
3	Check if the Field Service tasks that belong to the (unmarked) incident ids associated to the processing set id (i/p parameter) are in Closed/Cancelled/Completed task status
3.1	If this check returns false,
3.1.1	Mark the corresponding incident id as NOT a candidate for purge
4	Return Success
*/

IF (nvl(P_OBJECT_TYPE,  'SR') = 'SR') then

/* Step 1 : Mark SRs (for the given p_processing_set_id) as NOT a delete candidate
            IF the SR is linked to a CMRO object
*/
    update JTF_OBJECT_PURGE_PARAM_TMP
    set
        purge_status = 'E'
    ,   purge_error_message = 'CSF:CSF_DEBRIEF_PURGE_FAILED'
    where
        processing_set_id = P_PROCESSING_SET_ID and
        object_id in
        (
            select
                lnk.subject_id
            from
                cs_incident_links lnk
            ,   JTF_OBJECT_PURGE_PARAM_TMP tmp
            where
                tmp.object_id = lnk.subject_id and
                lnk.object_type = 'AHL_UMP_EFF' and
                lnk.link_type_id = 6 and
                nvl(tmp.purge_status, 'S') <> 'E' and
                tmp.processing_set_id = P_PROCESSING_SET_ID
        )
        and nvl(purge_status, 'S') <> 'E';

if((FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'CSF', 'In CSF_MAINTAIN_GRP.Validate_FieldServiceObjects() after first validation ');
END IF;
/* Step 2: Mark SRs (for the given p_processing_set_id) as NOT a delete candidate
           IF the SR is linked to mobile FS tasks that CANNOT be deleted
*/
/*
   This is the place where we call the mobile field service task validation API to further
   mark the JTF_OBJECT_PURGE_PARAM_TMP table with a status 'E' for all those SRs which have
   mobile field service tasks that CANNOT be deleted
*/
  csm_sr_purge_pkg.Validate_MobileFSObjects(
      P_API_VERSION               => P_API_VERSION,
      P_INIT_MSG_LIST             => P_INIT_MSG_LIST,
      P_COMMIT                    => P_COMMIT,
      P_PROCESSING_SET_ID         => P_PROCESSING_SET_ID,
      P_OBJECT_TYPE               => P_OBJECT_TYPE,
      X_RETURN_STATUS             => l_return_status,
      X_MSG_COUNT                 => l_msg_count,
      X_MSG_DATA                  => l_msg_data);

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        if((FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'CSF', 'csm_sr_purge_pkg.Validate_MobileFSObjects returned error ');
        END IF;
		RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        if((FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'CSF', 'csm_sr_purge_pkg.Validate_MobileFSObjects returned unexpected error ');
        END IF;
		RAISE fnd_api.g_exc_unexpected_error;
      END IF;



/* Step 3: Mark SRs (for the given p_processing_set_id) as NOT a delete candidate
           IF the SR is linked to FS tasks that are in Closed/Completed/Cancelled status
*/
    update JTF_OBJECT_PURGE_PARAM_TMP
    set
        purge_status = 'E'
    ,   purge_error_message = 'CSF:CSF_DEBRIEF_PURGE_FAILED'
    where
        processing_set_id = P_PROCESSING_SET_ID and
        object_id in
        (
            select
                tmp.object_id
            from
                jtf_tasks_b jtftk
            ,   jtf_task_statuses_b jtfts
            ,   jtf_task_types_b jttp
            ,   JTF_OBJECT_PURGE_PARAM_TMP tmp
            where
                tmp.object_id = jtftk.source_object_id and
                tmp.object_type = jtftk.source_object_type_code and
                jtftk.task_status_id = jtfts.task_status_id and
                (nvl(jtfts.closed_flag,'N') <> 'Y' and
                 nvl(jtfts.completed_flag,'N') <> 'Y' and
                 nvl(jtfts.cancelled_flag,'N') <> 'Y') and
                 nvl(tmp.purge_status, 'S') <> 'E' and
                jtftk.task_type_id = jttp.task_type_id and
                jttp.rule = 'DISPATCH' and
                 tmp.processing_set_id = P_PROCESSING_SET_ID
        )
        and nvl(purge_status, 'S') <> 'E';

        if((FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'CSF', 'In CSF_MAINTAIN_GRP.Validate_FieldServiceObjects() after third validation ');
        END IF;

    -- Standard check of p_commit
--    IF fnd_api.to_boolean(p_commit) THEN
--      COMMIT WORK;
--    END IF;

END IF;


  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO Validate_FieldServiceObjects;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO Validate_FieldServiceObjects;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      ROLLBACK TO Validate_FieldServiceObjects;
END;




PROCEDURE Purge_FieldServiceObjects(
      P_API_VERSION                 IN        NUMBER  ,
      P_INIT_MSG_LIST              IN   VARCHAR2     := FND_API.G_FALSE,
      P_COMMIT                     IN   VARCHAR2     := FND_API.G_FALSE,
      P_PROCESSING_SET_ID                 IN        NUMBER  ,
      P_OBJECT_TYPE                IN  VARCHAR2 ,
      X_RETURN_STATUS              IN   OUT NOCOPY  VARCHAR2,
      X_MSG_COUNT                 IN OUT NOCOPY   NUMBER,
      X_MSG_DATA                 IN OUT NOCOPY VARCHAR2)
   IS
l_api_name                CONSTANT VARCHAR2(30) := 'Purge_FieldServiceObjects';
l_api_version_number      CONSTANT NUMBER   := 1.0;

   BEGIN


     SAVEPOINT Purge_FieldServiceObjects;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list
      FND_MSG_PUB.initialize;

IF (nvl(P_OBJECT_TYPE,  'SR') = 'SR') then

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

/* Delete Logic
1      Fetch the incident ids associated to the processing set id (i/p parameter) which are marked for purge
1.1	If no incident ids (for the given processing set id) require purging, Return Success
2	Fetch Field Service tasks belonging to the incident ids which are purge candidates
3	Fetch debrief headers that belong to the fetched tasks
4	Fetch debrief lines that belong to the fetched debrief headers
5	Fetch debrief notes that belong to the fetched debrief headers
6	Fetch parts requirement headers that belong to the fetched tasks
7	Fetch parts requirement lines that belong to the fetched parts requirement headers
8	Fetch parts requirement line details that belong to the fetched parts requirement headers
9	Fetch required skills that are associated to the fetched tasks
10  Fetch Schedule Requests
11  Fetch Resource Results
12  Fetch Messages and Message Tokens
13	Delete contents fetched from step 3 - step 12
14	Return Success if delete operation is successful
15	Return Failure if delete operation fails
*/


/* Step 1 - Delete relevant debrief notes and note contexts */
	DELETE /*+ index(jnc) */ FROM JTF_NOTE_CONTEXTS jnc
	WHERE
		jtf_note_id in
		(
		SELECT /*+ no_unnest no_semijoin cardinality(10) */
			jtfnl.jtf_note_id
		FROM
		    JTF_NOTE_CONTEXTS jtfnl
		,   JTF_NOTES_B jtfnb
		,   CSF_DEBRIEF_HEADERS dbfh
		,   JTF_TASK_ASSIGNMENTS tska
		,   JTF_TASKS_B tskt
		,   JTF_OBJECT_PURGE_PARAM_TMP tmp
		WHERE
		    tmp.PROCESSING_SET_ID = P_PROCESSING_SET_ID and
			nvl(tmp.purge_status, 'S') <> 'E' and
		    tmp.object_id = tskt.source_object_id and
		    tmp.object_type = tskt.source_object_type_code and
		    tskt.task_id = tska.task_id and
		    tska.task_assignment_id = dbfh.task_assignment_id and
		    dbfh.debrief_header_id = jtfnb.source_object_id and
		    jtfnb.source_object_code = 'DF' and
		    jtfnb.jtf_note_id = jtfnl.jtf_note_id
		);



	DELETE /*+ index(jnt)*/ from JTF_NOTES_TL jnt
	WHERE
		jtf_note_id in
		(
		SELECT /*+ no_unnest no_semijoin cardinality(10) */
			jtfnb.jtf_note_id
		FROM
		    JTF_NOTES_B jtfnb
		,   CSF_DEBRIEF_HEADERS dbfh
		,   JTF_TASK_ASSIGNMENTS tska
		,   JTF_TASKS_B tskt
		,   JTF_OBJECT_PURGE_PARAM_TMP tmp
		WHERE
		    tmp.PROCESSING_SET_ID = P_PROCESSING_SET_ID and
			nvl(tmp.purge_status, 'S') <> 'E' and
		    tmp.object_id = tskt.source_object_id and
		    tmp.object_type = tskt.source_object_type_code  and
		    tskt.task_id = tska.task_id and
		    tska.task_assignment_id = dbfh.task_assignment_id and
		    dbfh.debrief_header_id = jtfnb.source_object_id and
		    jtfnb.source_object_code = 'DF'
		);


	DELETE /*+ index(jnb)*/ from JTF_NOTES_B jnb
	WHERE
		jtf_note_id in
		(
		SELECT /*+ no_unnest no_semijoin cardinality(10) */
			jtfnb.jtf_note_id
		FROM
		    JTF_NOTES_B jtfnb
		,   CSF_DEBRIEF_HEADERS dbfh
		,   JTF_TASK_ASSIGNMENTS tska
		,   JTF_TASKS_B tskt
		,   JTF_OBJECT_PURGE_PARAM_TMP tmp
		WHERE
		    tmp.PROCESSING_SET_ID = P_PROCESSING_SET_ID and
			nvl(tmp.purge_status, 'S') <> 'E' and
		    tmp.object_id = tskt.source_object_id and
		    tmp.object_type = tskt.source_object_type_code and
		    tskt.task_id = tska.task_id and
		    tska.task_assignment_id = dbfh.task_assignment_id and
		    dbfh.debrief_header_id = jtfnb.source_object_id and
		    jtfnb.source_object_code = 'DF'
		);

if((FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'CSF', 'In CSF_MAINTAIN_GRP.Purge_FieldServiceObjects() deleted FS task notes and note related objs ');
END IF;

/* Step 2 - Delete relevant debrief lines and debrief line related objects:
   1) CSF_DEBRIEF_LINES
*/

	DELETE /*+ index(cdl) */ FROM CSF_DEBRIEF_LINES cdl
	WHERE
		debrief_line_id in
		(
		SELECT /*+ no_unnest no_semijoin cardinality(10) */
			dbfl.debrief_line_id
		FROM
		    CSF_DEBRIEF_LINES dbfl
		,	CSF_DEBRIEF_HEADERS dbfh
		,   JTF_TASK_ASSIGNMENTS tska
		,   JTF_TASKS_B tskt
		,   JTF_OBJECT_PURGE_PARAM_TMP tmp
		WHERE
		    tmp.PROCESSING_SET_ID = P_PROCESSING_SET_ID and
			nvl(tmp.purge_status, 'S') <> 'E' and
		    tmp.object_id = tskt.source_object_id and
		    tmp.object_type = tskt.source_object_type_code and
		    tskt.task_id = tska.task_id and
		    tska.task_assignment_id = dbfh.task_assignment_id and
		    dbfh.debrief_header_id = dbfl.debrief_header_id
		);

if((FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'CSF', 'In CSF_MAINTAIN_GRP.Purge_FieldServiceObjects() deleted FS task debriefed line details ');
END IF;


/* Step 3 - Delete relevant debrief headers*/
	DELETE /*+ index(cdh) */ FROM CSF_DEBRIEF_HEADERS cdh
	WHERE
		debrief_header_id in
		(
		SELECT /*+ no_unnest no_semijoin cardinality(10) */
			dbfh.debrief_header_id
		FROM
		 	CSF_DEBRIEF_HEADERS dbfh
		,   JTF_TASK_ASSIGNMENTS tska
		,   JTF_TASKS_B tskt
		,   JTF_OBJECT_PURGE_PARAM_TMP tmp
		WHERE
		    tmp.PROCESSING_SET_ID = P_PROCESSING_SET_ID and
			nvl(tmp.purge_status, 'S') <> 'E' and
		    tmp.object_id = tskt.source_object_id and
		    tmp.object_type = tskt.source_object_type_code and
		    tskt.task_id = tska.task_id and
		    tska.task_assignment_id = dbfh.task_assignment_id
		);

if((FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'CSF', 'In CSF_MAINTAIN_GRP.Purge_FieldServiceObjects() deleted FS task debrief header details ');
END IF;

/* Step 4 - Delete relevant requirement line details */
	DELETE /*+ index(crld) */ FROM CSP_REQ_LINE_DETAILS crld
	WHERE
		req_line_detail_id in
		(
		SELECT /*+ no_unnest no_semijoin cardinality(10) */
			csprdt.req_line_detail_id
		FROM
		    CSP_REQ_LINE_DETAILS csprdt
	    ,	CSP_REQUIREMENT_LINES csprl
 	    ,   CSP_REQUIREMENT_HEADERS csprh
		,   JTF_TASKS_B tskt
		,   JTF_OBJECT_PURGE_PARAM_TMP tmp
		WHERE
		    tmp.PROCESSING_SET_ID = P_PROCESSING_SET_ID and
			nvl(tmp.purge_status, 'S') <> 'E' and
		    tmp.object_id = tskt.source_object_id and
		    tmp.object_type = tskt.source_object_type_code and
		    tskt.task_id = csprh.task_id and
		    csprh.requirement_header_id = csprl.requirement_header_id and
		    csprl.requirement_line_id = csprdt.requirement_line_id
		);


/* Step 5 - Delete relevant requirement lines */
	DELETE /*+ index(crl) */ FROM CSP_REQUIREMENT_LINES crl
	WHERE
		requirement_line_id in
		(
		SELECT /*+ no_unnest no_semijoin cardinality(10) */
			csprl.requirement_line_id
		FROM
		 	CSP_REQUIREMENT_LINES csprl
 	    ,   CSP_REQUIREMENT_HEADERS csprh
		,   JTF_TASKS_B tskt
		,   JTF_OBJECT_PURGE_PARAM_TMP tmp
		WHERE
		    tmp.PROCESSING_SET_ID = P_PROCESSING_SET_ID and
			nvl(tmp.purge_status, 'S') <> 'E' and
		    tmp.object_id = tskt.source_object_id and
		    tmp.object_type = tskt.source_object_type_code and
		    tskt.task_id = csprh.task_id and
		    csprh.requirement_header_id = csprl.requirement_header_id
		);



/* Step 6 - Delete relevant requirement headers */
	DELETE /*+ index(crh) */ FROM CSP_REQUIREMENT_HEADERS crh
	WHERE
		requirement_header_id in
		(
		SELECT /*+ no_unnest no_semijoin cardinality(10) */
			csprh.requirement_header_id
		FROM
 	        CSP_REQUIREMENT_HEADERS csprh
		,   JTF_TASKS_B tskt
		,   JTF_OBJECT_PURGE_PARAM_TMP tmp
		WHERE
		    tmp.PROCESSING_SET_ID = P_PROCESSING_SET_ID and
			nvl(tmp.purge_status, 'S') <> 'E' and
		    tmp.object_id = tskt.source_object_id and
		    tmp.object_type = tskt.source_object_type_code and
		    tskt.task_id = csprh.task_id
		);


if((FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'CSF', 'In CSF_MAINTAIN_GRP.Purge_FieldServiceObjects() deleted FS task requirement headers and lines ');
END IF;

/* Step 7 - Delete relevant required skills */
	DELETE /*+ index(crsb) */ FROM CSF_REQUIRED_SKILLS_B crsb
	WHERE
		required_skill_id in
		(
		SELECT /*+ no_unnest no_semijoin cardinality(10) */
			csfsk.required_skill_id
		FROM
 	        CSF_REQUIRED_SKILLS_B csfsk
		,   JTF_TASKS_B tskt
		,   JTF_OBJECT_PURGE_PARAM_TMP tmp
		WHERE
		    tmp.PROCESSING_SET_ID = P_PROCESSING_SET_ID and
			nvl(tmp.purge_status, 'S') <> 'E' and
		    tmp.object_id = tskt.source_object_id and
		    tmp.object_type = tskt.source_object_type_code and
		    tskt.task_id = csfsk.has_skill_id and
		    csfsk.has_skill_type = 'TASK'
		);

if((FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'CSF', 'In CSF_MAINTAIN_GRP.Purge_FieldServiceObjects() deleted FS task required skills ');
END IF;

/* Step 8 - Delete Access Hours */
	DELETE /*+ index(cahb) */ FROM CSF_ACCESS_HOURS_B cahb
	WHERE
		task_id in
		(
		SELECT /*+ no_unnest no_semijoin cardinality(10) */
			csacc.task_id
		FROM
 	        CSF_ACCESS_HOURS_B csacc
		,   JTF_TASKS_B tskt
		,   JTF_OBJECT_PURGE_PARAM_TMP tmp
		WHERE
		    tmp.PROCESSING_SET_ID = P_PROCESSING_SET_ID and
			nvl(tmp.purge_status, 'S') <> 'E' and
		    tmp.object_id = tskt.source_object_id and
		    tmp.object_type = tskt.source_object_type_code and
		    tskt.task_id = csacc.task_id
		);


	DELETE /*+ index(caht) */ FROM CSF_ACCESS_HOURS_TL caht
	WHERE
		access_hour_id in
		(
		SELECT /*+ no_unnest no_semijoin cardinality(10) */
			csacc.access_hour_id
		FROM
 	        CSF_ACCESS_HOURS_B csacc
		,   JTF_TASKS_B tskt
		,   JTF_OBJECT_PURGE_PARAM_TMP tmp
		WHERE
		    tmp.PROCESSING_SET_ID = P_PROCESSING_SET_ID and
			nvl(tmp.purge_status, 'S') <> 'E' and
		    tmp.object_id = tskt.source_object_id and
		    tmp.object_type = tskt.source_object_type_code and
		    tskt.task_id = csacc.task_id
		);

if((FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'CSF', 'In CSF_MAINTAIN_GRP.Purge_FieldServiceObjects() deleted FS task access hours details ');
END IF;


/* Step 9 - Delete Plan Options */
	DELETE /*+ index(crpo) */ FROM CSF_R_PLAN_OPTIONS crpo
	WHERE
		plan_option_id in
		(
		SELECT /*+ no_unnest no_semijoin cardinality(10) */
			csactl.plan_option_id
		FROM
		    CSF_R_PLAN_OPTIONS csactl
 	    ,   CSF_R_PLAN_OPTION_TASKS csacc
		,   JTF_TASKS_B tskt
		,   JTF_OBJECT_PURGE_PARAM_TMP tmp
		WHERE
		    tmp.PROCESSING_SET_ID = P_PROCESSING_SET_ID and
			nvl(tmp.purge_status, 'S') <> 'E' and
		    tmp.object_id = tskt.source_object_id and
		    tmp.object_type = tskt.source_object_type_code and
		    tskt.task_id = csacc.task_id and
		    csacc.plan_option_id = csactl.plan_option_id
		);


	DELETE /*+ index(crpot) */ FROM CSF_R_PLAN_OPTION_TASKS crpot
	WHERE
		task_id in
		(
		SELECT /*+ no_unnest no_semijoin cardinality(10) */
			csacc.task_id
		FROM
 	        CSF_R_PLAN_OPTION_TASKS csacc
		,   JTF_TASKS_B tskt
		,   JTF_OBJECT_PURGE_PARAM_TMP tmp
		WHERE
		    tmp.PROCESSING_SET_ID = P_PROCESSING_SET_ID and
			nvl(tmp.purge_status, 'S') <> 'E' and
		    tmp.object_id = tskt.source_object_id and
		    tmp.object_type = tskt.source_object_type_code and
		    tskt.task_id = csacc.task_id
		);


if((FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'CSF', 'In CSF_MAINTAIN_GRP.Purge_FieldServiceObjects() deleted FS task plan options ');
END IF;

/* Step 10 - Delete Schedule Requests */
	DELETE /*+ index(crsr) */  FROM CSF_R_SCHED_REQUESTS crsr
	WHERE
		SCHED_REQUEST_ID in
		(
		SELECT /*+ no_unnest no_semijoin cardinality(10) */
			csactl.SCHED_REQUEST_ID
		FROM
		    CSF_R_SCHED_REQUESTS csactl
 	    ,   CSF_R_REQUEST_TASKS csacc
		,   JTF_TASKS_B tskt
		,   JTF_OBJECT_PURGE_PARAM_TMP tmp
		WHERE
		    tmp.PROCESSING_SET_ID = P_PROCESSING_SET_ID and
			nvl(tmp.purge_status, 'S') <> 'E' and
		    tmp.object_id = tskt.source_object_id and
		    tmp.object_type = tskt.source_object_type_code and
		    tskt.task_id = csacc.REQUEST_TASK_ID and
		    csacc.SCHED_REQUEST_ID = csactl.SCHED_REQUEST_ID
		);


	DELETE /*+ index(crrt) */ FROM CSF_R_REQUEST_TASKS crrt
	WHERE
		REQUEST_TASK_ID in
		(
		SELECT /*+ no_unnest no_semijoin cardinality(10) */
			csacc.REQUEST_TASK_ID
		FROM
 	        CSF_R_REQUEST_TASKS csacc
		,   JTF_TASKS_B tskt
		,   JTF_OBJECT_PURGE_PARAM_TMP tmp
		WHERE
		    tmp.PROCESSING_SET_ID = P_PROCESSING_SET_ID and
			nvl(tmp.purge_status, 'S') <> 'E' and
		    tmp.object_id = tskt.source_object_id and
		    tmp.object_type = tskt.source_object_type_code and
		    tskt.task_id = csacc.REQUEST_TASK_ID
		);

if((FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'CSF', 'In CSF_MAINTAIN_GRP.Purge_FieldServiceObjects() deleted FS task scheduled requests ');
END IF;

/* Step 11 - Delete Resource Results */
	DELETE /*+ index(crso) */ FROM CSF_R_SPARES_OPTIONS crso
	WHERE
		RESOURCE_RESULT_ID in
		(
		SELECT /*+ no_unnest no_semijoin cardinality(10) */
			csactl.RESOURCE_RESULT_ID
		FROM
		    CSF_R_SPARES_OPTIONS csactl
 	    ,   CSF_R_RESOURCE_RESULTS csacc
		,   JTF_TASKS_B tskt
		,   JTF_OBJECT_PURGE_PARAM_TMP tmp
		WHERE
		    tmp.PROCESSING_SET_ID = P_PROCESSING_SET_ID and
			nvl(tmp.purge_status, 'S') <> 'E' and
		    tmp.object_id = tskt.source_object_id and
		    tmp.object_type = tskt.source_object_type_code and
		    tskt.task_id = csacc.REQUEST_TASK_ID and
		    csacc.RESOURCE_RESULT_ID = csactl.RESOURCE_RESULT_ID
		);


	DELETE /*+ index(crrr) */ FROM CSF_R_RESOURCE_RESULTS crrr
	WHERE
		REQUEST_TASK_ID in
		(
		SELECT /*+ no_unnest no_semijoin cardinality(10) */
			csacc.REQUEST_TASK_ID
		FROM
 	        CSF_R_RESOURCE_RESULTS csacc
		,   JTF_TASKS_B tskt
		,   JTF_OBJECT_PURGE_PARAM_TMP tmp
		WHERE
		    tmp.PROCESSING_SET_ID = P_PROCESSING_SET_ID and
			nvl(tmp.purge_status, 'S') <> 'E' and
		    tmp.object_id = tskt.source_object_id and
		    tmp.object_type = tskt.source_object_type_code and
		    tskt.task_id = csacc.REQUEST_TASK_ID
		);


if((FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'CSF', 'In CSF_MAINTAIN_GRP.Purge_FieldServiceObjects() deleted FS task resource results ');
END IF;


/* Step 12 - Delete Messages and Message Tokens */
	DELETE /*+ index(crmt) */ FROM CSF_R_MESSAGE_TOKENS crmt
	WHERE
		MESSAGE_ID in
		(
		SELECT /*+ no_unnest no_semijoin cardinality(10) */
			csactl.MESSAGE_ID
		FROM
		    CSF_R_MESSAGE_TOKENS csactl
 	    ,   CSF_R_MESSAGES csacc
		,   JTF_TASKS_B tskt
		,   JTF_OBJECT_PURGE_PARAM_TMP tmp
		WHERE
		    tmp.PROCESSING_SET_ID = P_PROCESSING_SET_ID and
			nvl(tmp.purge_status, 'S') <> 'E' and
		    tmp.object_id = tskt.source_object_id and
		    tmp.object_type = tskt.source_object_type_code and
		    tskt.task_id = csacc.REQUEST_TASK_ID and
		    csacc.MESSAGE_ID = csactl.MESSAGE_ID
		);


	DELETE /*+ index(crm) */ FROM CSF_R_MESSAGES crm
	WHERE
		REQUEST_TASK_ID in
		(
		SELECT /*+ no_unnest no_semijoin cardinality(10) */
			csacc.REQUEST_TASK_ID
		FROM
 	        CSF_R_MESSAGES csacc
		,   JTF_TASKS_B tskt
		,   JTF_OBJECT_PURGE_PARAM_TMP tmp
		WHERE
		    tmp.PROCESSING_SET_ID = P_PROCESSING_SET_ID and
			nvl(tmp.purge_status, 'S') <> 'E' and
		    tmp.object_id = tskt.source_object_id and
		    tmp.object_type = tskt.source_object_type_code and
		    tskt.task_id = csacc.REQUEST_TASK_ID
		);

if((FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'CSF', 'In CSF_MAINTAIN_GRP.Purge_FieldServiceObjects() deleted FS task messages and message tokens ');
END IF;



delete cac_sr_object_capacity
    where object_capacity_id in
    (select cac.object_capacity_id
        from
        cac_sr_object_capacity cac
        ,   JTF_TASKS_B tskt
        ,   JTF_OBJECT_PURGE_PARAM_TMP tmp
        ,   jtf_Task_assignments jtt
        ,   jtf_task_statuses_b jtfts
        WHERE
            tmp.PROCESSING_SET_ID = P_PROCESSING_SET_ID and
            nvl(tmp.purge_status, 'S') <> 'E' and
            tmp.object_id = tskt.source_object_id and
            tmp.object_type = tskt.source_object_type_code and
            tskt.task_id = jtt.TASK_ID and
            jtt.object_capacity_id = cac.object_capacity_id and
            jtt.assignment_status_id = jtfts.task_status_id  and
            (nvl(jtfts.closed_flag,'N') = 'Y' or
             nvl(jtfts.completed_flag,'N') = 'Y' or
             nvl(jtfts.cancelled_flag,'N') = 'Y') and
			 cac.end_date_time < sysdate and
            not exists (select 1 from
                        jtf_Task_assignments jtts, jtf_task_statuses_b jtsts
                        where
                        jtts.object_capacity_id = cac.object_capacity_id and
                        jtts.task_id <> jtt.task_id and
                        jtt.assignment_status_id = jtfts.task_status_id  and
                        (nvl(jtfts.closed_flag,'N') <> 'Y' and
                         nvl(jtfts.completed_flag,'N') <> 'Y' and
                         nvl(jtfts.cancelled_flag,'N') <> 'Y'))

            );



update cac_sr_object_capacity cac set cac.available_hours =
 ( SELECT (cac.END_DATE_TIME - cac.START_DATE_TIME) -
              SUM(ta.booking_end_date - ta.booking_start_date) -
              SUM(NVL(csf_util_pvt.convert_to_minutes(
                      ta.sched_travel_duration
                     , ta.sched_travel_duration_uom
                      ), 0)) /(24*60)
         FROM jtf_task_assignments ta
         WHERE ta.object_capacity_id = cac.object_capacity_id
  )
 where cac.start_date_time > sysdate and
 cac.object_capacity_id in
 (select cac.object_capacity_id
        from
        cac_sr_object_capacity cac
        ,   JTF_TASKS_B tskt
        ,   JTF_OBJECT_PURGE_PARAM_TMP tmp
        ,   jtf_Task_assignments jtt
        ,   jtf_task_statuses_b jtfts
        WHERE
            tmp.PROCESSING_SET_ID = P_PROCESSING_SET_ID and
            nvl(tmp.purge_status, 'S') <> 'E' and
            tmp.object_id = tskt.source_object_id and
            tmp.object_type = tskt.source_object_type_code and
            tskt.task_id = jtt.TASK_ID and
            jtt.object_capacity_id = cac.object_capacity_id and
            jtt.assignment_status_id = jtfts.task_status_id  and
            (nvl(jtfts.closed_flag,'N') = 'Y' or
             nvl(jtfts.completed_flag,'N') = 'Y' or
             nvl(jtfts.cancelled_flag,'N') = 'Y'));

if((FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) THEN
FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'CSF', 'In CSF_MAINTAIN_GRP.Purge_FieldServiceObjects() deleted FS capacities ');
END IF;


    -- Standard check of p_commit
--    IF fnd_api.to_boolean(p_commit) THEN
--      COMMIT WORK;
--    END IF;

END IF;


  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO Purge_FieldServiceObjects;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO Purge_FieldServiceObjects;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      ROLLBACK TO Purge_FieldServiceObjects;


   END;

   -- Enter further code below as specified in the Package spec.
End CSF_MAINTAIN_GRP;


/
