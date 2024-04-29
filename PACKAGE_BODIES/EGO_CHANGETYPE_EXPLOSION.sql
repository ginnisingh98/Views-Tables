--------------------------------------------------------
--  DDL for Package Body EGO_CHANGETYPE_EXPLOSION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_CHANGETYPE_EXPLOSION" as
/* $Header: EGOCHGXB.pls 115.2 2004/02/10 07:15:37 akanukun noship $ */

PROCEDURE explodeTemplates (
	p_change_id	 IN	NUMBER,
	p_change_type_id IN	NUMBER,
	p_user_id        IN	NUMBER,
	p_login_id       IN	NUMBER,
	p_prog_appid     IN	NUMBER,
	p_prog_id        IN	NUMBER,
	p_req_id         IN	NUMBER,
	p_err_text	 IN OUT NOCOPY VARCHAR2
	)
AS
	 -- varray_id NUM_ID_ARRAY;

         -- change_route_id NUMBER;
	 -- change_step_id NUMBER;

         -- Fetch all the life cycle Statuses for corresponding Type.
         CURSOR l_status_csr IS
                SELECT
		  ENTITY_ID2
		  ,ENTITY_ID3
		  ,ENTITY_ID4
		  ,ENTITY_ID5
		  ,SEQUENCE_NUMBER
		  ,STATUS_CODE
		  ,START_DATE
		  ,COMPLETION_DATE
		  ,AUTO_PROMOTE_STATUS
		  ,AUTO_DEMOTE_STATUS
		  ,WORKFLOW_STATUS
		  ,CHANGE_EDITABLE_FLAG
		  ,ITERATION_NUMBER
		  ,ACTIVE_FLAG
		  ,CHANGE_WF_ROUTE_ID
		FROM
		  ENG_LIFECYCLE_STATUSES
		WHERE
		  ENTITY_NAME = 'ENG_CHANGE_TYPE'
		  AND	ENTITY_ID1  = p_change_type_id;

BEGIN
	 FOR l_status_rec IN l_status_csr
	 LOOP
                  -- Insert the Statuses data
		  INSERT INTO ENG_LIFECYCLE_STATUSES
                  (
                     CHANGE_LIFECYCLE_STATUS_ID
                      ,ENTITY_NAME
                      ,ENTITY_ID1
                      ,ENTITY_ID2
                      ,ENTITY_ID3
                      ,ENTITY_ID4
                      ,ENTITY_ID5
                      ,SEQUENCE_NUMBER
                      ,STATUS_CODE
                      ,START_DATE
                      ,COMPLETION_DATE
                      ,CHANGE_WF_ROUTE_ID
                      ,AUTO_PROMOTE_STATUS
                      ,AUTO_DEMOTE_STATUS
--                      ,START_WORKFLOW_FLAG
                      ,WORKFLOW_STATUS
                      ,CHANGE_EDITABLE_FLAG
                      ,CREATION_DATE
                      ,CREATED_BY
                      ,LAST_UPDATE_DATE
                      ,LAST_UPDATED_BY
                      ,LAST_UPDATE_LOGIN
                      ,ITERATION_NUMBER
                      ,ACTIVE_FLAG
		      ,CHANGE_WF_ROUTE_TEMPLATE_ID
                    )
                    VALUES
                    (
		       ENG_LIFECYCLE_STATUSES_S.NEXTVAL
                       ,'ENG_CHANGE'
                       ,p_change_id
                       ,NULL -- l_status_rec.ENTITY_ID2
                       ,NULL -- l_status_rec.ENTITY_ID3
                       ,NULL -- l_status_rec.ENTITY_ID4
                       ,NULL -- l_status_rec.ENTITY_ID5
                       ,l_status_rec.SEQUENCE_NUMBER
                       ,l_status_rec.STATUS_CODE
                       ,NULL -- l_status_rec.START_DATE
                       ,NULL -- l_status_rec.COMPLETION_DATE
                       ,NULL -- CHANGE_WF_ROUTE_ID
                       ,l_status_rec.AUTO_PROMOTE_STATUS
                       ,l_status_rec.AUTO_DEMOTE_STATUS
--                       ,l_status_rec.START_WORKFLOW_FLAG
                       ,NULL -- l_status_rec.WORKFLOW_STATUS
                       ,l_status_rec.CHANGE_EDITABLE_FLAG
                       ,SYSDATE
                       ,p_user_id
                       ,SYSDATE
                       ,p_user_id
                       ,p_login_id
                       ,0 -- l_status_rec.ITERATION_NUMBER
                       ,'Y' -- l_status_rec.ACTIVE_FLAG
		       ,l_status_rec.CHANGE_WF_ROUTE_ID -- CHANGE_WF_ROUTE_TEMPLATE_ID
                    );
	 END LOOP; -- End loop l_status_csr
EXCEPTION
    WHEN OTHERS THEN
        p_err_text := 'EGO_CHANGETYPE_EXPLOSION(explodeTemplates) ' ||substrb(SQLERRM, 1, 60);
	NULL;
	--return(SQLCODE);
END explodeTemplates;

END EGO_CHANGETYPE_EXPLOSION;

/
