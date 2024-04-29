--------------------------------------------------------
--  DDL for Package Body QA_RESULT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_RESULT_GRP" AS
/* $Header: qltgresb.plb 120.8.12000000.2 2007/02/20 21:43:03 shkalyan ship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30):='QA_RESULT_GRP';

-- R12 ERES Support in Service Family. Bug 4345768 Start
-- Global variable to hold the status of the eRecord for Txn Acknowledgement.
g_erec_success CONSTANT VARCHAR2(30) := 'SUCCESS';
g_erec_error   CONSTANT VARCHAR2(30) := 'ERROR';
g_ackn_by      CONSTANT VARCHAR2(30) := 'QUALITY TXN INTEGRATION';
-- R12 ERES Support in Service Family. Bug 4345768 End

PROCEDURE Purge
(       p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_commit                IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_validation_level      IN      NUMBER  :=
                                        FND_API.G_VALID_LEVEL_FULL      ,
        p_collection_id         IN      NUMBER                          ,
        p_return_status         OUT     NOCOPY VARCHAR2                 ,
        p_msg_count             OUT     NOCOPY NUMBER                           ,
        p_msg_data              OUT     NOCOPY VARCHAR2
)
IS
l_api_name                      CONSTANT VARCHAR2(30)   := 'Purge';
l_api_version                   CONSTANT NUMBER         := 1.0;

-- R12 ERES Support in Service Family. Bug 4345768
l_result_count                           NUMBER;
BEGIN

        -- Standard Start of API savepoint
        SAVEPOINT       Purge_GRP;
        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (    l_api_version           ,
                                                p_api_version           ,
                                                l_api_name              ,
                                                G_PKG_NAME )
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;
        --  Initialize API return status to success
        p_return_status := FND_API.G_RET_STS_SUCCESS;

        IF p_collection_id is not null THEN

           DELETE qa_results
           WHERE  collection_id = p_collection_id;

           -- R12 ERES Support in Service Family. Bug 4345768
           l_result_count := SQL%ROWCOUNT;
        END IF;

        -- R12 ERES Support in Service Family. Bug 4345768 Start
        -- Purge the Result Relationship
        IF ( l_result_count > 0 ) THEN
          DELETE  qa_pc_results_relationship
          WHERE   parent_collection_id = p_collection_id
          OR      child_collection_id = p_collection_id;

          -- Bug 5502106. Action Logs must also be purged.
          DELETE  qa_action_log
          WHERE   collection_id = p_collection_id;
        END IF;
        -- R12 ERES Support in Service Family. Bug 4345768 End

        -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
        END IF;
        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      p_msg_count     ,
                p_data                  =>      p_msg_data
        );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO Purge_GRP;
                p_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      p_msg_count     ,
                        p_data                  =>      p_msg_data
                );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO Purge_GRP;
                p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      p_msg_count     ,
                        p_data                  =>      p_msg_data
                );
        WHEN OTHERS THEN
                ROLLBACK TO Purge_GRP;
                p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.Add_Exc_Msg
                        (       G_PKG_NAME          ,
                                l_api_name
                        );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      p_msg_count     ,
                        p_data                  =>      p_msg_data
                );
END Purge;

--
-- Added new parameter p_incident_id for Service Request Enhancements Project
-- Default value is null for backward compatibility
-- rkunchal Tue Sep  3 10:20:12 PDT 2002
--

PROCEDURE Enable
(       p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_commit                IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_validation_level      IN      NUMBER  :=
                                        FND_API.G_VALID_LEVEL_FULL      ,
        p_collection_id         IN      NUMBER                          ,
        p_return_status         OUT     NOCOPY VARCHAR2                 ,
        p_msg_count             OUT     NOCOPY NUMBER                           ,
        p_msg_data              OUT     NOCOPY VARCHAR2                 ,
        p_incident_id           IN      NUMBER
)
IS
l_api_name                      CONSTANT VARCHAR2(30)   := 'Enable';
l_api_version                   CONSTANT NUMBER         := 1.0;


-- Gapless Sequence Proj. rponnusa Wed Jul 30 04:52:45 PDT 2003
l_return_status                          VARCHAR2(3);

--
-- bug 5642050
-- added a new variable to get the count of
-- rows updated
-- ntungare Sun Nov  5 22:28:57 PST 2006
--
no_of_rows_updated  NUMBER;

BEGIN

        -- Standard Start of API savepoint
        SAVEPOINT       Enable_GRP;
        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (    l_api_version           ,
                                                p_api_version           ,
                                                l_api_name              ,
                                                G_PKG_NAME )
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list ) THEN
                FND_MSG_PUB.initialize;
        END IF;
        --  Initialize API return status to success
        p_return_status := FND_API.G_RET_STS_SUCCESS;

        IF p_collection_id is not null THEN

           --
           -- Modified the following UPDATE for Service Request Enhancements Project
           -- The incident_id should also be updated during enabling the results
           -- rkunchal Tue Sep  3 10:20:12 PDT 2002
           --
           -- Bug 4473407.
           -- Update the status of the records to 2(Enabled Status) only if it
           -- is not already 2.
           -- ntungare Thu Sep  8 07:24:20 PDT 2005
           --
           UPDATE qa_results
           SET status = 2,
               cs_incident_id = nvl(p_incident_id, cs_incident_id)
           WHERE p_collection_id = collection_id
             AND status <> 2;

           --
           -- bug 5642050
           -- getting a count of rows updated
           -- ntungare Sun Nov  5 22:28:57 PST 2006
           --
           no_of_rows_updated := SQL%ROWCOUNT;

           -- Gapless Sequence Proj. rponnusa Wed Jul 30 04:52:45 PDT 2003
           -- Generate the sequence element value for all the records (including
           -- child,grand child plans
           -- call seq. api only if eres is not enabled.
           IF FND_PROFILE.VALUE('EDR_ERES_ENABLED') <> 'Y' THEN

              QA_SEQUENCE_API.Generate_Seq_for_Txn(
                                    p_collection_id,
                                    l_return_status);

              IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
                 -- in case of failure raise error.
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
           END IF;

           -- launch quality actions
           -- only actions that are performed in commit cycle are to be
           -- launched here
           --
           -- Bug 4473407.
           -- If the previous update statement had updated qa_results then
           -- SQL%ROWCOUNT would be > 0 and only in that case we call do_actions
           -- to fire the action. Before this fix qltdactb.do_actions was called
           -- without any condition and because of this whenever the procedure
           -- Enable is called the actions are also fired unnecessarily which is
           -- not correct. The actions should fire only once for the enabled
           -- records - even if the parent transaction calls QA_RESULT_GRP.ENABLE
           -- more than once, the updation of qa_results and action firing will
           -- happen only the first time and nothing would happen during the
           -- consecutive calls.
           -- ntungare Thu Sep  8 07:37:32 PDT 2005
           --
           --
           -- bug 5642050
           -- using the variable to check the updated
           -- rows count
           -- ntungare Sun Nov  5 22:28:57 PST 2006
           --
           -- IF SQL%ROWCOUNT > 0 THEN
           IF no_of_rows_updated > 0 THEN
             IF (QLTDACTB.DO_ACTIONS(p_collection_id,
                                     1,
                                     NULL,
                                     NULL,
                                     FALSE ,
                                     FALSE,
                                     'DEFERRED' ,
                                     'COLLECTION_ID'
                                    )= FALSE ) then
                 p_msg_count := -1 ;
             END IF   ;
           END IF   ;

        END IF ;


        -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
                COMMIT WORK;
        END IF;

        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      p_msg_count     ,
                p_data                  =>      p_msg_data
        );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO Enable_GRP;
                p_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      p_msg_count     ,
                        p_data                  =>      p_msg_data
                );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO Enable_GRP;
                p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      p_msg_count     ,
                        p_data                  =>      p_msg_data
                );
        WHEN OTHERS THEN
                -- ROLLBACK TO Enable_GRP;
                p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.Add_Exc_Msg
                        (       G_PKG_NAME          ,
                                l_api_name
                        );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      p_msg_count     ,
                        p_data                  =>      p_msg_data
                );
END Enable;

/********************************************************************

   Purpose: this procedure has been written specifically for WIP
   completion transaction. IN WIP COmpletion online , transaction are processed
   in batch and not row by row. Since collection id is different for each
   completion txn , our existing Enable API can not be called to
   enable Quality results for a batch of completion txns.
   Following procedure accepts a  material txn header id for a
   batch of txn and all the quality data for that batch of
   transaction are enabled.

   Date: 08/21/98
   Last Updated: 08/21/98
   Called From: WIP COMPLETION TXN COMMIT LOGIC
   Parameter: X_txn_header_id ( identifier for a group of material txns )

***********************************************************************/
PROCEDURE Enable_QA_Results ( X_Txn_Header_ID Number,
                              P_MSG_COUNT IN OUT  NOCOPY NUMBER  ) IS

   Cursor C_Collection_id is
      Select qa_collection_id
      from mtl_material_transactions_temp
      where Transaction_header_id = x_txn_header_id
      and qa_collection_id is not null;

   x_collection_id Number ;
   x_return_status varchar2(1);
   x_msg_count Number ;
   x_msg_data  varchar2(2000) ;
BEGIN
   Open c_collection_id ;
   LOOP
      fetch c_collection_id into x_collection_id ;
      exit when c_collection_id%notfound ;

      -- enable quality results
      ENABLE(
            p_api_version => 1.0,
            p_init_msg_list => 'F',
            p_commit => 'F',
            p_validation_level => 0,
            p_collection_id => x_collection_id,
            p_return_status => x_return_status,
            p_msg_count => x_msg_count,
            p_msg_data => x_msg_data);

      -- set the message count to indiacare that actions failed
      IF ( x_msg_count = -1)  THEN
         p_msg_count := -1 ;
      END IF ;

    END LOOP ;
    CLOSE C_COLLECTION_ID ;

    Exception When Others Then
      return ;
END Enable_QA_Results ;

-- Start R12 EAM Integration. Bug 4345492
PROCEDURE enable_and_fire_action (
    p_api_version       IN	NUMBER,
    p_init_msg_list	IN	VARCHAR2 := NULL,
    p_commit		IN  	VARCHAR2 := NULL,
    p_validation_level	IN  	NUMBER	 := NULL,
    p_collection_id	IN	NUMBER,
    x_return_status	OUT 	NOCOPY VARCHAR2,
    x_msg_count		OUT 	NOCOPY NUMBER,
    x_msg_data		OUT 	NOCOPY VARCHAR2) IS

    l_api_name		CONSTANT VARCHAR2(30)	:= 'enable_and_fire_action';
    l_api_version	CONSTANT NUMBER 	:= 1.0;
    l_error_found	BOOLEAN;
    actions_request_id  NUMBER;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT	enable_and_fire_action_grp;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        NVL( p_api_version, 1.0 ),
   	       	    	 		l_api_name,
		    	    	    	G_PKG_NAME ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( NVL( p_init_msg_list, FND_API.G_FALSE ) ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to error
    x_return_status := FND_API.G_RET_STS_ERROR;

    qa_results_api.enable(p_collection_id);
    actions_request_id := fnd_request.submit_request('QA', 'QLTACTWB', NULL,
                  NULL, FALSE, to_char(-p_collection_id));

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( NVL(p_commit, FND_API.G_FALSE ) ) THEN
	    COMMIT;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO enable_and_fire_action_grp;
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get
    	(p_count => x_msg_count,
         p_data  => x_msg_data
    	);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO enable_and_fire_action_grp;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get
    	(p_count => x_msg_count,
         p_data  => x_msg_data
    	);

     WHEN OTHERS THEN
	ROLLBACK TO enable_and_fire_action_grp;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       	    FND_MSG_PUB.Add_Exc_Msg
    	    (G_PKG_NAME,
    	     l_api_name
	    );
	END IF;
	FND_MSG_PUB.Count_And_Get
    	(p_count => x_msg_count,
         p_data  => x_msg_data
    	);

END enable_and_fire_action;
-- End R12 EAM Integration. Bug 4345492

  -- R12 ERES Support in Service Family. Bug 4345768 Start

  -- API to retrieve the Quality Results E-Records captured as
  -- part of a Transaction session ( collection )
  -- The E-Record IDs are returned as part of the x_qa_erecord_tbl
  -- output parameter.
  PROCEDURE get_qa_results_erecords
  (
   p_api_version      IN  NUMBER,
   p_init_msg_list    IN  VARCHAR2 := NULL ,
   p_commit           IN  VARCHAR2 := NULL ,
   p_validation_level IN  NUMBER   := NULL ,
   p_collection_id    IN  NUMBER ,
   x_qa_erecord_tbl   OUT NOCOPY qa_erecord_tbl_type ,
   x_return_status    OUT NOCOPY VARCHAR2 ,
   x_msg_count        OUT NOCOPY NUMBER ,
   x_msg_data         OUT NOCOPY VARCHAR2
  )
  IS
      l_api_name      CONSTANT VARCHAR2(30)   := 'get_qa_results_erecords';
      l_api_version   CONSTANT NUMBER         := 1.0;

      ctr                      NUMBER         := 1;
      l_prev_plan_id           NUMBER         := -1;
      l_event_key              EDR_PSIG_DOCUMENTS.event_key%TYPE;

      -- Get all occurrences for a collection
      -- Bug 5508639. SHKALYAN 13-Sep-2006.
      -- Process only Results which are in disabled status.
      -- Added status <> 2 check for filtering out already enabled records.
      -- Also added order by on txn_header_id to get the most recent txn first
      CURSOR get_occurrences( c_collection_id NUMBER )
      IS
         SELECT   plan_id,
                  txn_header_id,
                  occurrence
         FROM     QA_RESULTS
         WHERE    collection_id = c_collection_id
         AND      status <> 2
         ORDER BY txn_header_id DESC, plan_id;

      -- Bug 5508639. SHKALYAN 13-Sep-2006.
      l_txn_header_id          NUMBER         := NULL;
      l_event_processed        BOOLEAN        := FALSE;

      -- Get all the Quality ERES Events based on an Event Key
      -- Bug 5508639. SHKALYAN 13-Sep-2006.
      -- Modified cursor to get the most recent E-Record
      -- Also added a status check to retreive only valid E-Records

      -- Bug 5729384. SHKALYAN 20-Feb-2007.
      -- Removed the status check
      --  AND    psig_status = 'COMPLETE'
      -- in the cursor so that ALL the records are
      -- processed. This is because acknowledgment should be sent for all
      -- E-records including those with REJECTED and PENDING status.
      CURSOR get_erecords( c_event_key VARCHAR2 )
      IS
          SELECT event_name,
                 document_id
          FROM   EDR_PSIG_DOCUMENTS
          WHERE  event_key = c_event_key
          AND    event_name IN
                 ( 'oracle.apps.qa.ncm.create',
                   'oracle.apps.qa.ncm.update',
                   'oracle.apps.qa.ncm.master.approve',
                   'oracle.apps.qa.ncm.detail.approve',
                   'oracle.apps.qa.disp.create',
                   'oracle.apps.qa.disp.update',
                   'oracle.apps.qa.disp.header.approve',
                   'oracle.apps.qa.disp.detail.approve',
                   'oracle.apps.qa.car.create',
                   'oracle.apps.qa.car.update',
                   'oracle.apps.qa.car.approve',
                   'oracle.apps.qa.car.review.approve',
                   'oracle.apps.qa.car.impl.approve',
                   'oracle.apps.qa.result.create',
                   'oracle.apps.qa.result.update' )
         ORDER BY creation_date DESC;

  BEGIN

      IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_procedure,
          g_pkg_name || '.' || l_api_name,
          'Entering Procedure for collection: ' || p_collection_id
        );
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call
      (
        l_api_version,
        NVL( p_api_version, 1.0 ),
        l_api_name,
        g_pkg_name
      ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( NVL( p_init_msg_list, FND_API.G_FALSE ) ) THEN
        FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'Before getting occurrences for the collection'
        );
      END IF;

      FOR occ_cur IN get_occurrences( p_collection_id ) LOOP

        -- Bug 5508639. SHKALYAN 13-Sep-2006.
        -- Process only the most recent txn_header_id.
        IF ( NVL(l_txn_header_id, occ_cur.txn_header_id) <> occ_cur.txn_header_id ) THEN
          EXIT;
        END IF;

        l_txn_header_id := occ_cur.txn_header_id;

        IF ( occ_cur.plan_id <> l_prev_plan_id ) THEN

            l_event_key := occ_cur.plan_id || '-' || p_collection_id || '-';
            l_prev_plan_id := occ_cur.plan_id;

            IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
              FND_LOG.string
              (
                FND_LOG.level_statement,
                g_pkg_name || '.' || l_api_name,
                'Checking if event exists for the collection. Event Key: ' || l_event_key
              );
            END IF;

            FOR erec_cur IN get_erecords( l_event_key ) LOOP

              -- Ensure that only 1 event is processed
              IF ( l_event_processed ) THEN
                EXIT;
              ELSE
                l_event_processed := TRUE;
              END IF;

              x_qa_erecord_tbl(ctr).event_name := erec_cur.event_name;
              x_qa_erecord_tbl(ctr).event_key := l_event_key;
              x_qa_erecord_tbl(ctr).erec_id := erec_cur.document_id;

              IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
                FND_LOG.string
                (
                  FND_LOG.level_statement,
                  g_pkg_name || '.' || l_api_name,
                  'Found Event for the collection. Adding record: ' || ctr || ' E-Record: ' || x_qa_erecord_tbl(ctr).erec_id
                );
              END IF;

              ctr := ctr + 1;
            END LOOP;
            l_event_processed := FALSE;
        END IF;

        l_event_key := occ_cur.plan_id || '-' || p_collection_id || '-' || occ_cur.occurrence;

        IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
            FND_LOG.string
            (
              FND_LOG.level_statement,
              g_pkg_name || '.' || l_api_name,
              'Checking if event exists for the occurrence. Event Key: ' || l_event_key
            );
        END IF;

        FOR erec_cur IN get_erecords( l_event_key ) LOOP

            x_qa_erecord_tbl(ctr).event_name := erec_cur.event_name;
            x_qa_erecord_tbl(ctr).event_key := l_event_key;
            x_qa_erecord_tbl(ctr).erec_id := erec_cur.document_id;

            IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
              FND_LOG.string
              (
                FND_LOG.level_statement,
                g_pkg_name || '.' || l_api_name,
                'Found Event for the collection. Adding record: ' || ctr || ' E-Record: ' || x_qa_erecord_tbl(ctr).erec_id
              );
            END IF;
            ctr := ctr + 1;
        END LOOP;

      END LOOP;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

      IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_procedure,
          g_pkg_name || '.' || l_api_name,
          'Exiting Procedure: Success'
        );
      END IF;

    EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
        (
          p_count => x_msg_count,
          p_data  => x_msg_data
        );

        IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_procedure,
            g_pkg_name || '.' || l_api_name,
            'Exiting Procedure: Error'
          );
        END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get
        (
          p_count => x_msg_count,
          p_data  => x_msg_data
        );

        IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_procedure,
            g_pkg_name || '.' || l_api_name,
            'Exiting Procedure: Error'
          );
        END IF;

      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF ( FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) ) THEN
          FND_MSG_PUB.Add_Exc_Msg
          (
            p_pkg_name       => g_pkg_name,
            p_procedure_name => l_api_name,
            p_error_text     => SUBSTR(SQLERRM,1,240)
          );
        END IF;

        FND_MSG_PUB.Count_And_Get
        (
          p_count => x_msg_count,
          p_data  => x_msg_data
        );

        IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_procedure,
            g_pkg_name || '.' || l_api_name,
            'Exiting Procedure: Error'
          );
        END IF;

  END get_qa_results_erecords;

  -- Bug 5508639. SHKALYAN 13-Sep-2006.
  -- new API to delete the old invalid results For a collection_id
  -- This is needed because the Per Collection E-Records show
  -- up old invalid results for a given collection_id for SR Txn
  PROCEDURE purge_invalid_results
  (
   p_collection_id    IN  NUMBER
  ) IS
  PRAGMA autonomous_transaction;

  l_occurrences dbms_sql.number_table;
  l_plans       dbms_sql.number_table;

  CURSOR C IS
    SELECT occurrence, plan_id
    FROM   qa_results
    WHERE  collection_id = p_collection_id
    AND    status <> 2;

  BEGIN

      OPEN C;
      FETCH C BULK COLLECT INTO l_occurrences, l_plans;
      CLOSE C;

      -- Delete all old invaild records for collection_id
      FORALL i IN l_occurrences.FIRST..l_occurrences.LAST
        DELETE QA_RESULTS
        WHERE  plan_id = l_plans(i)
        AND    occurrence = l_occurrences(i);

      -- Delete Child relationships
      FORALL i in l_occurrences.FIRST..l_occurrences.LAST
        DELETE QA_PC_RESULTS_RELATIONSHIP
        WHERE  parent_occurrence = l_occurrences(i);

      -- Delete Parent relationships
      FORALL i in l_occurrences.FIRST..l_occurrences.LAST
        DELETE QA_PC_RESULTS_RELATIONSHIP
        WHERE  child_occurrence = l_occurrences(i);

      -- Autonomous commit
      COMMIT;

  END purge_invalid_results;

  -- API to enable the Quality Results captured as part of the
  -- Transaction session ( collection ). This API will call the existing
  -- enable API to enable the results and fire background quality actions
  -- in addition to invoking EDR API to stamp the acknowledgement status
  -- of the Quality E-Records captured as part of the Txn as SUCCESS
  PROCEDURE enable_results_erecords
  (
   p_api_version      IN  NUMBER ,
   p_init_msg_list    IN  VARCHAR2 := NULL ,
   p_commit           IN  VARCHAR2 := NULL ,
   p_validation_level IN  NUMBER   := NULL ,
   p_collection_id    IN  NUMBER ,
   p_incident_id      IN  NUMBER   := NULL,
   x_return_status    OUT NOCOPY VARCHAR2 ,
   x_msg_count        OUT NOCOPY NUMBER ,
   x_msg_data         OUT NOCOPY VARCHAR2
  )
  IS
      l_api_name      CONSTANT VARCHAR2(30)   := 'enable_results_erecords';
      l_api_version   CONSTANT NUMBER         := 1.0;
      l_commit        BOOLEAN;

      l_erec_tbl      qa_erecord_tbl_type;
      l_return_status VARCHAR2(1);
      l_msg_count     NUMBER;
      l_msg_data      VARCHAR2(5000);

      -- Bug 5508639. SHKALYAN 13-Sep-2006.
      -- Get the most recent txn_header_id for a collection
      -- processing will be done only for records with this txn_header_id
      -- Also Process only Results which are in disabled status.
      CURSOR get_txn_header_id( c_collection_id NUMBER )
      IS
         SELECT   MAX( txn_header_id )
         FROM     QA_RESULTS
         WHERE    collection_id = c_collection_id
         AND      status <> 2;

      -- Bug 5508639. SHKALYAN 13-Sep-2006.
      l_txn_header_id NUMBER;

      -- Bug 5656202. SHKALYAN 11-NOV-2006.
      -- Arrays for holding the return values of qa results
      -- enabled in the current session
      Type num_tab_typ is table of number index by binary_integer;
      plan_id_tab        num_tab_typ;
      collection_id_tab  num_tab_typ;
      occurrence_tab     num_tab_typ;

  BEGIN
      l_commit        := FND_API.To_Boolean( NVL(p_commit, FND_API.G_FALSE) );

      IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_procedure,
          g_pkg_name || '.' || l_api_name,
          'Entering Procedure for collection: ' || p_collection_id
        );
      END IF;

      -- Standard Start of API savepoint
      SAVEPOINT enable_results_erecords_GRP;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call
      (
        l_api_version,
        NVL( p_api_version, 1.0 ),
        l_api_name,
        g_pkg_name
      ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( NVL( p_init_msg_list, FND_API.G_FALSE ) ) THEN
        FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF ( FND_PROFILE.value('EDR_ERES_ENABLED') = 'Y' ) THEN

        IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_statement,
            g_pkg_name || '.' || l_api_name,
            'Before Getting QA Result ERecords'
          );
        END IF;

        -- Get all the QA Results E-Records for the given collection
        get_qa_results_erecords
        (
          p_api_version         => 1.0,
          p_init_msg_list       => FND_API.G_FALSE,
          p_commit              => FND_API.G_FALSE,
          p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
          p_collection_id       => p_collection_id,
          x_qa_erecord_tbl      => l_erec_tbl,
          x_return_status       => l_return_status,
          x_msg_count           => l_msg_count,
          x_msg_data            => l_msg_data
        );

        IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_statement,
            g_pkg_name || '.' || l_api_name,
            'Obtained ' || l_erec_tbl.COUNT || ' number of QA Result ERecords'
          );
        END IF;

        -- Send Transaction Acknowledgement for E-Records obtained
        IF ( l_erec_tbl.COUNT > 0 ) THEN
          FOR i IN l_erec_tbl.FIRST..l_erec_tbl.LAST LOOP

            IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
              FND_LOG.string
              (
                FND_LOG.level_statement,
                g_pkg_name || '.' || l_api_name,
                'Before Sending Txn acknowledgement for ERecord: ' || l_erec_tbl(i).erec_id || ' with event_name: ' || l_erec_tbl(i).event_name || ' and event_key: ' || l_erec_tbl(i).event_key
              );
            END IF;

            EDR_TRANS_ACKN_PUB.send_ackn
            (
               p_api_version       => 1.0,
               x_return_status     => l_return_status,
               x_msg_count         => l_msg_count,
               x_msg_data          => l_msg_data,
               p_event_name        => l_erec_tbl(i).event_name,
               p_event_key         => l_erec_tbl(i).event_key,
               p_erecord_id        => l_erec_tbl(i).erec_id,
               p_trans_status      => g_erec_success,
               p_ackn_by           => g_ackn_by,
               p_ackn_note         => '',
               p_autonomous_commit => FND_API.G_FALSE
            );

          END LOOP;
        END IF;

      END IF;

      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'Before Enabling QA Results and firing Actions'
        );
      END IF;

      -- Bug 5508639. SHKALYAN 13-Sep-2006.
      -- We were calling the enable API here. Modified to directly
      -- include the logic for updating qa_results and calling do_actions
      -- This is because we want to process based on txn_header_id
      -- instead of collection_id and the old enable api cannot be used.

      -- Get the most recent txn_header_id
      OPEN  get_txn_header_id( p_collection_id );
      FETCH get_txn_header_id INTO l_txn_header_id;
      CLOSE get_txn_header_id;

      -- Enable the results for the most recent txn_header_id

      -- Bug 5656202. SHKALYAN 11-NOV-2006.
      -- For Background results posted during the transaction, the
      -- txn_header_id will be NULL. Added OR condition to bring in
      -- background results. Also, since subsequent action processing
      -- cannot be based on just txn_header_id, collecting all the
      -- occurrences updated in this session, so that, actions can be fired
      -- for only these records
      UPDATE    qa_results
      SET       status = 2,
                cs_incident_id = nvl(p_incident_id, cs_incident_id)
      WHERE     p_collection_id = collection_id
      AND       (txn_header_id = l_txn_header_id OR txn_header_id IS NULL)
      AND       status = 1
      RETURNING plan_id, collection_id, occurrence
           bulk collect into plan_id_tab, collection_id_tab, occurrence_tab;

      IF SQL%ROWCOUNT > 0 THEN

         -- Generate the sequence element value for all the records (including
         -- child,grand child plans
         -- call seq. api only if eres is not enabled.
         IF FND_PROFILE.VALUE('EDR_ERES_ENABLED') <> 'Y' THEN

            QA_SEQUENCE_API.Generate_Seq_for_Txn(
                                    p_collection_id,
                                    l_return_status);

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
               -- in case of failure raise error.
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;

         -- launch quality actions for the most recent txn_header_id
         -- only actions that are performed in commit cycle are to be
         -- launched here. action processing is based on txn_header_id
         -- because txns such as service request is re-using the same
         -- collection_id throughout the lifecycle of the SR. In this
         -- case only un-processed records should be processed.
         --

         -- Bug 5656202. SHKALYAN 11-NOV-2006.
         -- Looping through all the records  updated in this session
         -- and firing actions for them
         FOR Cntr in 1..plan_id_tab.count LOOP

           -- Bug 5656202. SHKALYAN 11-NOV-2006.
           -- Calling the do_actions for the plan_id, collection_id,
           -- Occurrence combination instead of txn_header_id

           IF (QLTDACTB.do_actions( x_txn_header_id => collection_id_tab(cntr),
                                    x_concurrent => 1,
                                    x_po_txn_processor_mode => NULL,
                                    x_group_id => NULL,
                                    x_background => TRUE,
                                    x_debug => FALSE,
                                    x_action_type => 'DEFERRED',
                                    x_passed_id_name => 'COLLECTION_ID',
                                    p_occurrence => occurrence_tab(cntr),
                                    p_plan_id => plan_id_tab(cntr),
                                    x_argument => NULL
                                   ) = FALSE ) THEN
             raise FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF   ;
        END LOOP;
      END IF;
      -- Bug 5508639. SHKALYAN 13-Sep-2006.
      -- End code changes.

      -- Commit (if requested)
      IF ( l_commit ) THEN
        COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.count_and_get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

      IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_procedure,
          g_pkg_name || '.' || l_api_name,
          'Exiting Procedure: Success'
        );
      END IF;

    EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO enable_results_erecords_GRP;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
        (
          p_count => x_msg_count,
          p_data  => x_msg_data
        );

        IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_procedure,
            g_pkg_name || '.' || l_api_name,
            'Exiting Procedure: Error'
          );
        END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO enable_results_erecords_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get
        (
          p_count => x_msg_count,
          p_data  => x_msg_data
        );

        IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_procedure,
            g_pkg_name || '.' || l_api_name,
            'Exiting Procedure: Error'
          );
        END IF;

      WHEN OTHERS THEN
        ROLLBACK TO enable_results_erecords_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF ( FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) ) THEN
          FND_MSG_PUB.Add_Exc_Msg
          (
            p_pkg_name       => g_pkg_name,
            p_procedure_name => l_api_name,
            p_error_text     => SUBSTR(SQLERRM,1,240)
          );
        END IF;

        FND_MSG_PUB.Count_And_Get
        (
          p_count => x_msg_count,
          p_data  => x_msg_data
        );

        IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_procedure,
            g_pkg_name || '.' || l_api_name,
            'Exiting Procedure: Error'
          );
        END IF;

  END enable_results_erecords;

  -- API to purge the Quality Results captured as part of the
  -- Transaction session ( collection ). This API will call the existing
  -- purge API to delete the results in addition to invoking EDR API to
  -- stamp the acknowledgement status of the Quality E-Records captured
  -- as part of the Txn as SUCCESS
  PROCEDURE purge_results_erecords
  (
   p_api_version      IN  NUMBER ,
   p_init_msg_list    IN  VARCHAR2 := NULL ,
   p_commit           IN  VARCHAR2 := NULL ,
   p_validation_level IN  NUMBER   := NULL ,
   p_collection_id    IN  NUMBER ,
   x_return_status    OUT NOCOPY VARCHAR2 ,
   x_msg_count        OUT NOCOPY NUMBER ,
   x_msg_data         OUT NOCOPY VARCHAR2
  )
  IS
      l_api_name      CONSTANT VARCHAR2(30)   := 'purge_results_erecords';
      l_api_version   CONSTANT NUMBER         := 1.0;
      l_commit        BOOLEAN;

      l_erec_tbl      qa_erecord_tbl_type;
      l_return_status VARCHAR2(1);
      l_msg_count     NUMBER;
      l_msg_data      VARCHAR2(5000);

  BEGIN
      l_commit        := FND_API.To_Boolean( NVL(p_commit, FND_API.G_FALSE) );

      IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_procedure,
          g_pkg_name || '.' || l_api_name,
          'Entering Procedure for collection: ' || p_collection_id
        );
      END IF;

      -- Standard Start of API savepoint
      SAVEPOINT purge_results_erecords_GRP;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call
      (
        l_api_version,
        NVL( p_api_version, 1.0 ),
        l_api_name,
        g_pkg_name
      ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( NVL( p_init_msg_list, FND_API.G_FALSE ) ) THEN
        FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF ( FND_PROFILE.value('EDR_ERES_ENABLED') = 'Y' ) THEN

        IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_statement,
            g_pkg_name || '.' || l_api_name,
            'Before Getting QA Result ERecords'
          );
        END IF;

        -- Get all the QA Results E-Records for the given collection
        get_qa_results_erecords
        (
          p_api_version         => 1.0,
          p_init_msg_list       => FND_API.G_FALSE,
          p_commit              => FND_API.G_FALSE,
          p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
          p_collection_id       => p_collection_id,
          x_qa_erecord_tbl      => l_erec_tbl,
          x_return_status       => l_return_status,
          x_msg_count           => l_msg_count,
          x_msg_data            => l_msg_data
        );

        IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_statement,
            g_pkg_name || '.' || l_api_name,
            'Obtained ' || l_erec_tbl.COUNT || ' number of QA Result ERecords'
          );
        END IF;

        -- Send Transaction Acknowledgement for E-Records obtained
        IF ( l_erec_tbl.COUNT > 0 ) THEN
          FOR i IN l_erec_tbl.FIRST..l_erec_tbl.LAST LOOP

            IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
              FND_LOG.string
              (
                FND_LOG.level_statement,
                g_pkg_name || '.' || l_api_name,
                'Before Sending Txn acknowledgement for ERecord: ' || l_erec_tbl(i).erec_id || ' with event_name: ' || l_erec_tbl(i).event_name || ' and event_key: ' || l_erec_tbl(i).event_key
              );
            END IF;

            EDR_TRANS_ACKN_PUB.send_ackn
            (
               p_api_version       => 1.0,
               x_return_status     => l_return_status,
               x_msg_count         => l_msg_count,
               x_msg_data          => l_msg_data,
               p_event_name        => l_erec_tbl(i).event_name,
               p_event_key         => l_erec_tbl(i).event_key,
               p_erecord_id        => l_erec_tbl(i).erec_id,
               p_trans_status      => g_erec_error,
               p_ackn_by           => g_ackn_by,
               p_ackn_note         => '',
               p_autonomous_commit => FND_API.G_FALSE
            );

          END LOOP;
        END IF;

      END IF;

      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'Before Purging QA Results'
        );
      END IF;

      -- Purge the Quality Results for the Collection
      purge
      (
        p_api_version         => 1.0,
        p_init_msg_list       => FND_API.G_FALSE,
        p_commit              => FND_API.G_FALSE,
        p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
        p_collection_id       => p_collection_id,
        p_return_status       => l_return_status,
        p_msg_count           => l_msg_count,
        p_msg_data            => l_msg_data
      );

      -- Commit (if requested)
      IF ( l_commit ) THEN
        COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

      IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_procedure,
          g_pkg_name || '.' || l_api_name,
          'Exiting Procedure: Success'
        );
      END IF;

    EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO purge_results_erecords_GRP;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
        (
          p_count => x_msg_count,
          p_data  => x_msg_data
        );

        IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_procedure,
            g_pkg_name || '.' || l_api_name,
            'Exiting Procedure: Error'
          );
        END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO purge_results_erecords_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get
        (
          p_count => x_msg_count,
          p_data  => x_msg_data
        );

        IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_procedure,
            g_pkg_name || '.' || l_api_name,
            'Exiting Procedure: Error'
          );
        END IF;

      WHEN OTHERS THEN
        ROLLBACK TO purge_results_erecords_GRP;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF ( FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) ) THEN
          FND_MSG_PUB.Add_Exc_Msg
          (
            p_pkg_name       => g_pkg_name,
            p_procedure_name => l_api_name,
            p_error_text     => SUBSTR(SQLERRM,1,240)
          );
        END IF;

        FND_MSG_PUB.Count_And_Get
        (
          p_count => x_msg_count,
          p_data  => x_msg_data
        );

        IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_procedure,
            g_pkg_name || '.' || l_api_name,
            'Exiting Procedure: Error'
          );
        END IF;

  END purge_results_erecords;
  -- R12 ERES Support in Service Family. Bug 4345768 End

END qa_result_grp;

/
