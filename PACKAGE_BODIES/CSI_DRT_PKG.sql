--------------------------------------------------------
--  DDL for Package Body CSI_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_DRT_PKG" AS
/* $Header: csidrtpb.pls 120.0.12010000.3 2018/06/18 09:31:46 aabmishr noship $ */

L_PACKAGE      VARCHAR2(100) := 'CSI_DRT_PKG';


PROCEDURE CSI_TCA_DRC(PERSON_ID       IN NUMBER,
                      RESULT_TBL OUT NOCOPY PER_DRT_PKG.RESULT_TBL_TYPE) IS

  L_PROC         VARCHAR2(72);
  L_DEBUG        BOOLEAN := FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE;
  L_PERSON_ID        NUMBER;
  --N                  NUMBER;
  l_active_Instance_party  VARCHAR2(1) := 'N';
  L_RESULT_TBL   PER_DRT_PKG.RESULT_TBL_TYPE;

BEGIN
    L_PERSON_ID := PERSON_ID;

    IF L_DEBUG THEN
		L_PROC := L_PACKAGE || 'CSI_TCA_DRC';
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_PROC, 'Entering:' || L_PROC);
    END IF;

	IF L_DEBUG THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_PROC, '  Checking constraints for L_PERSON_ID:' || L_PERSON_ID);
    END IF;

      SELECT  'Y'
	  INTO    l_active_Instance_party
	  FROM    dual
	  WHERE   EXISTS
	  (
	  SELECT  cii.instance_id
	  FROM    csi_i_parties cip
	  	,csi_item_instances cii
	  WHERE   cip.party_id = L_PERSON_ID
	  AND     (
	  				sysdate BETWEEN nvl (cip.active_start_date
	  									,sysdate - 1)
	  						AND     nvl (cip.active_end_date
	  									,sysdate + 1)
	  		)
	  AND     (
	  				sysdate BETWEEN nvl (cii.active_start_date
	  									,sysdate - 1)
	  						AND     nvl (cii.active_end_date
	  									,sysdate + 1)
	  		)
	  AND     cip.instance_id = cii.instance_id
	  AND 	  cip.party_source_table = 'HZ_PARTIES'
	  );

    IF l_active_Instance_party = 'Y' THEN
      -- N := L_RESULT_TBL.COUNT + 1;
      --L_RESULT_TBL(N).PERSON_ID := L_PERSON_ID;
      --L_RESULT_TBL(N).ENTITY_TYPE := CSI_DRT_PKG.ENTITY_TYPE_TCA;
      --L_RESULT_TBL(N).STATUS := 'W';
      --L_RESULT_TBL(N).MSGCODE := 'CSI_TCA_DRC_ACTIVE_RECORD';
      --L_RESULT_TBL(N).MSGTEXT := FND_MESSAGE.GET_STRING(APPIN => 'CSI', NAMEIN => L_RESULT_TBL(n).MSGCODE);


	 per_drt_pkg.add_to_results (person_id => L_PERSON_ID , entity_type => CSI_DRT_PKG.ENTITY_TYPE_TCA , status => 'W' ,
               msgcode => 'CSI_TCA_DRC_ACTIVE_RECORD' , msgaplid => 542 , result_tbl => L_RESULT_TBL);

	  IF L_DEBUG THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_PROC, '    Failed with CSI_TCA_DRC_ACTIVE_RECORD');
          END IF;

    END IF;
	RESULT_TBL  := L_RESULT_TBL;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF L_DEBUG THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_PROC, '  Note: No TCA active record for person_id = ' || L_PERSON_ID);
        END IF;
		RESULT_TBL  := L_RESULT_TBL;
    WHEN OTHERS THEN
        IF L_DEBUG THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_PROC, '  Note: Error while getting the record for person_id = ' || L_PERSON_ID);
        END IF;
		RESULT_TBL  := L_RESULT_TBL;
END CSI_TCA_DRC;

PROCEDURE CSI_HR_DRC(PERSON_ID       IN NUMBER,
                      RESULT_TBL OUT NOCOPY PER_DRT_PKG.RESULT_TBL_TYPE) IS

  L_PROC         VARCHAR2(72);
  L_DEBUG        BOOLEAN := FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE;
  L_PERSON_ID        NUMBER;
  --N                  NUMBER;
  l_active_Instance_party  VARCHAR2(1) := 'N';
  L_RESULT_TBL   PER_DRT_PKG.RESULT_TBL_TYPE;

BEGIN
    L_PERSON_ID := PERSON_ID;

    IF L_DEBUG THEN
		L_PROC := L_PACKAGE || 'CSI_HR_DRC';
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_PROC, 'Entering:' || L_PROC);
    END IF;

	IF L_DEBUG THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_PROC, '  Checking constraints for L_PERSON_ID:' || L_PERSON_ID);
    END IF;

      SELECT  'Y'
	  INTO    l_active_Instance_party
	  FROM    dual
	  WHERE   EXISTS
	  (
	  SELECT  cii.instance_id
	  FROM    csi_i_parties cip
	  	,csi_item_instances cii
	  WHERE   cip.party_id = L_PERSON_ID
	  AND     (
	  				sysdate BETWEEN nvl (cip.active_start_date
	  									,sysdate - 1)
	  						AND     nvl (cip.active_end_date
	  									,sysdate + 1)
	  		)
	  AND     (
	  				sysdate BETWEEN nvl (cii.active_start_date
	  									,sysdate - 1)
	  						AND     nvl (cii.active_end_date
	  									,sysdate + 1)
	  		)
	  AND     cip.instance_id = cii.instance_id
	  AND 	  cip.party_source_table = 'EMPLOYEE'
	  );

    IF l_active_Instance_party = 'Y' THEN
	 /* N := L_RESULT_TBL.COUNT + 1;
      L_RESULT_TBL(N).PERSON_ID := L_PERSON_ID;
      L_RESULT_TBL(N).ENTITY_TYPE := CSI_DRT_PKG.ENTITY_TYPE_HR;
	  L_RESULT_TBL(N).STATUS := 'W';
      L_RESULT_TBL(N).MSGCODE := 'CSI_HR_DRC_ACTIVE_RECORD';
      L_RESULT_TBL(N).MSGTEXT := FND_MESSAGE.GET_STRING(APPIN => 'CSI', NAMEIN => L_RESULT_TBL(n).MSGCODE);
	  */

	  per_drt_pkg.add_to_results (person_id => L_PERSON_ID , entity_type => CSI_DRT_PKG.ENTITY_TYPE_HR , status => 'W' ,
               msgcode => 'CSI_HR_DRC_ACTIVE_RECORD' , msgaplid => 542 , result_tbl => L_RESULT_TBL);

	  IF L_DEBUG THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_PROC, '    Failed with  CSI_HR_DRC_ACTIVE_RECORD');
          END IF;
    END IF;
	RESULT_TBL  := L_RESULT_TBL;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF L_DEBUG THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_PROC, '  Note: No HR active record for person_id = ' || L_PERSON_ID);
        END IF;
		RESULT_TBL  := L_RESULT_TBL;
    WHEN OTHERS THEN
        IF L_DEBUG THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_PROC, '  Note: Error while getting the record for person_id = ' || L_PERSON_ID);
        END IF;
		RESULT_TBL  := L_RESULT_TBL;
END CSI_HR_DRC;

PROCEDURE CSI_FND_DRC(PERSON_ID       IN NUMBER,
                      RESULT_TBL OUT NOCOPY PER_DRT_PKG.RESULT_TBL_TYPE) IS

  L_PROC         VARCHAR2(72);
  L_DEBUG        BOOLEAN := FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE;
  L_PERSON_ID        NUMBER;
  --N                  NUMBER;
  l_pending_batch  VARCHAR2(1) := 'N';
  L_RESULT_TBL   PER_DRT_PKG.RESULT_TBL_TYPE;

BEGIN
    L_PERSON_ID := PERSON_ID;

    IF L_DEBUG THEN
		L_PROC := L_PACKAGE || 'CSI_FND_DRC';
		FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_PROC, 'Entering:' || L_PROC);
    END IF;

	IF L_DEBUG THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_PROC, '  Checking constraints for L_PERSON_ID:' || L_PERSON_ID);
    END IF;

      SELECT  'Y'
	  	INTO    l_pending_batch
			FROM    csi_mass_edit_entries_vl
			WHERE   created_by = L_PERSON_ID
			AND     status_code <> 'SUCCESSFUL'
			AND rownum =1;

    IF l_pending_batch = 'Y' THEN
	  /*N := L_RESULT_TBL.COUNT + 1;
      L_RESULT_TBL(N).PERSON_ID := L_PERSON_ID;
      L_RESULT_TBL(N).ENTITY_TYPE := CSI_DRT_PKG.ENTITY_TYPE_TCA;
	  L_RESULT_TBL(N).STATUS := 'W';
      L_RESULT_TBL(N).MSGCODE := 'CSI_FND_DRC_ACTIVE_RECORD';
      L_RESULT_TBL(N).MSGTEXT := FND_MESSAGE.GET_STRING(APPIN => 'CSI', NAMEIN => L_RESULT_TBL(n).MSGCODE);
		*/

per_drt_pkg.add_to_results (person_id => L_PERSON_ID , entity_type => CSI_DRT_PKG.ENTITY_TYPE_FND , status => 'W' ,
               msgcode => 'CSI_FND_DRC_ACTIVE_RECORD' , msgaplid => 542 , result_tbl => L_RESULT_TBL);

	  IF L_DEBUG THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_PROC, '    Failed with CSI_FND_DRC_ACTIVE_RECORD');
      END IF;
    END IF;
	RESULT_TBL  := L_RESULT_TBL;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF L_DEBUG THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_PROC, '  Note: No pending batch records for person_id = ' || L_PERSON_ID);
        END IF;
		RESULT_TBL  := L_RESULT_TBL;
    WHEN OTHERS THEN
        IF L_DEBUG THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_PROC, '  Note: Error while getting the record for person_id = ' || L_PERSON_ID);
        END IF;
		RESULT_TBL  := L_RESULT_TBL;
END CSI_FND_DRC;

END CSI_DRT_PKG;

/
