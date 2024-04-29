--------------------------------------------------------
--  DDL for Package Body DOM_DOCUMENT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DOM_DOCUMENT_UTIL" as
/*$Header: DOMPDUTB.pls 120.12.12010000.2 2009/01/23 22:03:40 ksuleman ship $ */
--  Global constant holding the package name

G_PKG_NAME CONSTANT VARCHAR2(30) := 'DOM_DOCUMENT_UTIL' ;


/********************************************************************
* API Type      : Local APIs
* Purpose       : Those APIs are Local
*********************************************************************/

PROCEDURE Get_Document_LC_Info( p_lc_tracking_id            IN  NUMBER
                              , p_route_id                  IN  NUMBER
                              , x_document_id               OUT NOCOPY NUMBER
                              , x_document_revision_id      OUT NOCOPY NUMBER
                              , x_checkout_status           OUT NOCOPY VARCHAR2
                              , x_lc_sequence_number        OUT NOCOPY NUMBER
                              , x_lc_phase_code             OUT NOCOPY NUMBER
                              , x_lc_phase_type             OUT NOCOPY NUMBER
                              , x_lc_phase_display_name     OUT NOCOPY VARCHAR2
                              )
IS

    CURSOR  c_doc_lc  (c_lc_tracking_id NUMBER
                      ,c_route_id       NUMBER)
    IS
       SELECT rev.document_id
            , rev.revision_id
            , rev.lifecycle_tracking_id
            , rev.lifecycle_phase_id
            , lifecycle.sequence_number
            , rev.checkout_status
            , lifecycle.status_code
            , stat.status_type
            , lifecycle.change_wf_route_id
            , stat.status_name
       FROM eng_change_statuses_vl stat
          , eng_lifecycle_statuses lifecycle
          , dom_document_revisions rev
       WHERE lifecycle.status_code = stat.status_code
       AND lifecycle.change_wf_route_id = c_route_id
       AND lifecycle.entity_id1 = rev.lifecycle_tracking_id
       AND lifecycle.entity_name = 'ENG_CHANGE'
       AND lifecycle.active_flag = 'Y'
       AND rev.lifecycle_tracking_id = c_lc_tracking_id  ;


BEGIN

    FOR l_rec IN c_doc_lc ( c_lc_tracking_id => p_lc_tracking_id
                          , c_route_id       => p_route_id  )
    LOOP

        x_document_id           := l_rec.document_id ;
        x_document_revision_id  := l_rec.revision_id ;
        x_checkout_status       := l_rec.checkout_status ;
        x_lc_sequence_number    := l_rec.sequence_number ;
        x_lc_phase_code         := l_rec.status_code ;
        x_lc_phase_type         := l_rec.status_type ;
        x_lc_phase_display_name := l_rec.status_name ;

    END LOOP ;


END  Get_Document_LC_Info ;




/********************************************************************
* API Type      : Private APIs
* Purpose       : Those APIs are private
*********************************************************************/


Procedure Change_Doc_LC_Phase
(  p_api_version      IN  NUMBER                             --
  ,p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE        --
  ,p_commit           IN  VARCHAR2 := FND_API.G_FALSE        --
  ,p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
  ,p_change_id        IN  NUMBER
  ,p_lc_phase_code    IN  NUMBER
  ,p_action_type      IN  VARCHAR2-- 'PROMOTE' or 'DEMOTE'
  ,p_api_caller       IN  VARCHAR2
  ,x_return_status    OUT  NOCOPY  VARCHAR2                   --
  ,x_msg_count        OUT  NOCOPY  NUMBER                     --
  ,x_msg_data         OUT  NOCOPY  VARCHAR2
)
IS

 l_api_name               CONSTANT VARCHAR2(50) := 'Change_Doc_LC_Phase';

 l_return_status          VARCHAR2(1);
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(2000);

BEGIN




IF ( DOM_LOG.CHECK_LOG_LEVEL) THEN
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'Begin ' || l_api_name);
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'-----------------------------------------------------');
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'Change Id          : ' || TO_CHAR(p_change_id) );
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'LC Phase Code      : ' || TO_CHAR(p_lc_phase_code) );
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'Action Type        : ' || p_action_type);
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'API Caller         : ' || p_api_caller);
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'-----------------------------------------------------');
END IF ;



    UPDATE dom_document_revisions SET  lifecycle_phase_id = p_lc_phase_code
    WHERE lifecycle_tracking_id  =  p_change_id;

    IF p_commit = FND_API.G_TRUE THEN
       commit;
    END IF;

     -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
     -- Standard ending code ------------------------------------------------

    FND_MSG_PUB.Count_And_Get
    ( p_count        =>      x_msg_count,
      p_data         =>      x_msg_data );




IF ( DOM_LOG.CHECK_LOG_LEVEL) THEN
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'End ' || l_api_name);
END IF ;



EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );

    WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg (       G_PKG_NAME, l_api_name );
                  END IF;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );

END Change_Doc_LC_Phase;


Procedure Update_Approval_Status
(  p_api_version        IN  NUMBER                             --
  ,p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE        --
  ,p_commit             IN  VARCHAR2 := FND_API.G_FALSE        --
  ,p_validation_level   IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
  ,p_change_id          IN  NUMBER
  ,p_approval_status    IN  NUMBER
  ,p_wf_route_status    IN  VARCHAR2
  ,p_api_caller         IN  VARCHAR2
  ,x_return_status      OUT  NOCOPY  VARCHAR2                   --
  ,x_msg_count          OUT  NOCOPY  NUMBER                     --
  ,x_msg_data           OUT  NOCOPY  VARCHAR2
)
IS

 l_api_name             CONSTANT VARCHAR2(50) := 'Update_Approval_Status';

 l_return_status        VARCHAR2(1);
 l_msg_count            NUMBER;
 l_msg_data             VARCHAR2(2000);
 l_version_id           NUMBER;
 l_status_code          NUMBER;
 l_status_type          NUMBER;
 l_seq_num              NUMBER;
 l_approval_status      VARCHAR2(10);
 l_row_count            NUMBER;


BEGIN

/*
LOOKUP_CODE                             MEANING                             DOM STATUS
--------------------------------------- ----------------------------------------
1                                       Not submitted for approval           N_SFA
2                                       Ready to approve                     SFA
3                                       Approval requested                   SFA
4                                       Rejected                             RJD
5                                       Approved                             A
6                                       No approval needed                   A
7                                       Processing error                     SFA
8                                       Time out           SFA
*/




IF ( DOM_LOG.CHECK_LOG_LEVEL) THEN
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'Begin ' || l_api_name);
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'-----------------------------------------------------');
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'Change Id          : ' || TO_CHAR(p_change_id) );
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'Approval Status    : ' || TO_CHAR(p_approval_status) );
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'WF Route Status    : ' || p_wf_route_status);
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'API Caller         : ' || p_api_caller);
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'-----------------------------------------------------');
END IF ;


     -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    SELECT rev.lifecycle_phase_id, status_type, life.sequence_number
    INTO l_status_code, l_status_type, l_seq_num
    FROM eng_change_statuses stat, dom_document_revisions rev, eng_lifecycle_statuses life
    WHERE
        life.status_code = stat.status_code AND
        stat.status_code = rev.lifecycle_phase_id AND
        life.entity_id1 = rev.lifecycle_tracking_id AND
        life.active_flag = 'Y' AND
        rev.lifecycle_tracking_id = p_change_id;


    SELECT status_code INTO l_approval_status
    FROM dom_doc_rev_versions
    WHERE version_id = (
    SELECT max(version_id)
        FROM dom_doc_rev_versions
        WHERE revision_id = (SELECT revision_id FROM dom_document_revisions WHERE lifecycle_tracking_id = p_change_id));



        IF ( l_status_type = 1 ) THEN
            l_approval_status := 'C';
        ELSIF ( l_status_type = 12 ) THEN
          BEGIN
            IF ( p_wf_route_status = ENG_WORKFLOW_UTIL.G_RT_NOT_STARTED ) THEN
                l_approval_status := 'SFR';
            ELSIF ( p_wf_route_status = ENG_WORKFLOW_UTIL.G_RT_IN_PROGRESS ) THEN
                l_approval_status := 'SFR';
            ELSIF (p_wf_route_status = ENG_WORKFLOW_UTIL.G_RT_COMPLETED) THEN

                    SELECT Count(*)
                    INTO l_row_count
                    FROM eng_lifecycle_statuses life,eng_change_statuses_vl stat
                    WHERE
                    life.status_code = stat.status_code and
                    life.entity_id1 = p_change_id AND
                    stat.status_type = l_status_type AND
                    life.sequence_number >  l_seq_num;

                    IF l_row_count > 0 THEN
                        l_approval_status := 'SFR';
                    ELSE
                        l_approval_status := 'RVD';
                    END IF;
            END IF;
          END;
        ELSIF ( l_status_type = 8 ) THEN
          BEGIN
            IF (p_approval_status = 1) THEN
                l_approval_status := 'N_SFA';
            ELSIF (p_approval_status = 2) THEN
                l_approval_status := 'SFA';
            ELSIF (p_approval_status = 3) THEN
                l_approval_status := 'SFA';
            ELSIF (p_approval_status = 4) THEN
                l_approval_status := 'RJD';
            ELSIF (p_approval_status = 5) THEN

                    SELECT Count(*)
                    INTO l_row_count
                    FROM eng_lifecycle_statuses life,eng_change_statuses_vl stat
                    WHERE
                    life.status_code = stat.status_code and
                    life.entity_id1 = p_change_id AND
                    stat.status_type = l_status_type AND
                    life.sequence_number >  l_seq_num;

                    IF (l_row_count > 0) THEN
                        l_approval_status := 'SFA';
                    ELSE
                        l_approval_status := 'A';
                    END IF;
            END IF;
           END;
        END IF;

        UPDATE dom_doc_rev_versions SET  STATUS_CODE = l_approval_status
        WHERE version_id =
        (SELECT version_id FROM dom_doc_rev_versions
        WHERE creation_date = (
        SELECT Max(ver.creation_date) FROM dom_doc_rev_versions ver, dom_document_revisions rev
        WHERE ver.revision_id  =  rev.revision_id
        AND rev.revision_id = ver.revision_id
        AND rev.lifecycle_tracking_id  =  p_change_id));

        IF p_commit = FND_API.G_TRUE THEN
            commit;
        END IF;




  -- Standard ending code ------------------------------------------------

    FND_MSG_PUB.Count_And_Get
    ( p_count        =>      x_msg_count,
      p_data         =>      x_msg_data );


IF ( DOM_LOG.CHECK_LOG_LEVEL) THEN
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'End ' || l_api_name);
END IF ;



EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg (       G_PKG_NAME, l_api_name );
                  END IF;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
END Update_Approval_Status;




--
-- Start DOC LC Phase Workflow to integrate CM Worklfow
-- This API is called when starting Doc LC Phase Workflow
-- We can put validation logic here
--
Procedure Start_Doc_LC_Phase_WF
(  p_api_version        IN  NUMBER                             --
  ,p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE        --
  ,p_commit             IN  VARCHAR2 := FND_API.G_FALSE        --
  ,p_validation_level   IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
  ,x_return_status      OUT  NOCOPY  VARCHAR2                   --
  ,x_msg_count          OUT  NOCOPY  NUMBER                     --
  ,x_msg_data           OUT  NOCOPY  VARCHAR2
  ,p_change_id          IN  NUMBER
  ,p_route_id           IN  NUMBER
  ,p_lc_phase_code      IN  NUMBER := NULL
  ,p_api_caller         IN  VARCHAR2
)
IS

   l_api_name         CONSTANT VARCHAR2(30) := 'Start_Doc_LC_Phase_WF';
   l_api_version      CONSTANT NUMBER       := 1.0;

   l_document_id          NUMBER ;
   l_document_revision_id NUMBER ;
   l_checkout_status      DOM_DOCUMENT_REVISIONS.CHECKOUT_STATUS%TYPE ;
   l_lc_sequence_number   NUMBER ;
   l_lc_phase_code        NUMBER ;
   l_lc_phase_type        NUMBER ;
   l_lc_phase_display_name VARCHAR2(80) ;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT l_api_name;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(  l_api_version
                                       , p_api_version
                                       , l_api_name
                                       , G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF ;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


IF ( DOM_LOG.CHECK_LOG_LEVEL) THEN
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'Begin ' || l_api_name);
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'-----------------------------------------------------');
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'Change Id          : ' || TO_CHAR(p_change_id) );
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'Route Id           : ' || TO_CHAR(p_route_id) );
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'LC Phase Code      : ' || TO_CHAR(p_lc_phase_code) );
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'API Caller         : ' || p_api_caller);
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'-----------------------------------------------------');
END IF ;


    -----------------------------------------------------------------
    -- API body
    -----------------------------------------------------------------
    -- 1. Get Document Lifecycle Info
    Get_Document_LC_Info( p_lc_tracking_id        => p_change_id
                        , p_route_id              => p_route_id
                        , x_document_id           => l_document_id
                        , x_document_revision_id  => l_document_revision_id
                        , x_checkout_status       => l_checkout_status
                        , x_lc_sequence_number    => l_lc_sequence_number
                        , x_lc_phase_code         => l_lc_phase_code
                        , x_lc_phase_type         => l_lc_phase_type
                        , x_lc_phase_display_name => l_lc_phase_display_name
                        ) ;


IF ( DOM_LOG.CHECK_LOG_LEVEL) THEN
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'Got Document LC Info' );
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'-----------------------------------------------------');
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'Document Id        : ' || TO_CHAR(l_document_id) );
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'Document Rev Id    : ' || TO_CHAR(l_document_revision_id) );
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'Check Out Status   : ' || l_checkout_status);
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'LC Phase Seq Num   : ' || TO_CHAR(l_lc_sequence_number) );
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'LC Phase Code      : ' || TO_CHAR(l_lc_phase_code) );
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'LC Phase Type      : ' || TO_CHAR(l_lc_phase_type) );
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'LC Phase Display   : ' || l_lc_phase_display_name );
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'-----------------------------------------------------');
END IF ;


    IF l_checkout_status IS NOT NULL
    THEN
        -- Document LC Workflow cannot be started
        -- if the Document is being checked out
        IF l_lc_phase_type IN (G_PHASE_TYPE_REVIEW
                             , G_PHASE_TYPE_APPROVAL
                             , G_PHASE_TYPE_RELEASE
                             , G_PHASE_TYPE_ARCHIVE
                              )
        THEN

IF DOM_LOG.CHECK_LOG_LEVEL THEN
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'Document LC Workflow cannot be started in this status') ;
END IF ;

            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MESSAGE.SET_NAME('DOM', 'DOM_LC_WF_CANNOT_START') ;
            FND_MESSAGE.SET_TOKEN('LC_PHASE', l_lc_phase_display_name ) ;
            FND_MSG_PUB.Add ;

        END IF ;

    END IF ;


    -----------------------------------------------------------------
    -- End of API body
    -----------------------------------------------------------------


   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN

IF DOM_LOG.CHECK_LOG_LEVEL THEN
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'Do Commit.') ;
END IF ;

      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
      (  p_count  => x_msg_count
      ,  p_data   => x_msg_data
      );

IF ( DOM_LOG.CHECK_LOG_LEVEL) THEN
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'end ' || l_api_name);
END IF ;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        -- Standard check of p_commit.
       IF FND_API.To_Boolean( p_commit ) THEN

IF DOM_LOG.CHECK_LOG_LEVEL THEN
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'Rollback . . .') ;
END IF ;
           ROLLBACK TO l_api_name ;
       END IF;

       x_return_status := FND_API.G_RET_STS_ERROR ;

       FND_MSG_PUB.Count_And_Get
        (   p_count  =>      x_msg_count
         ,  p_data   =>      x_msg_data
        );

IF DOM_LOG.CHECK_LOG_LEVEL THEN
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'RollBack and Finish with Error.') ;
END IF ;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF FND_API.To_Boolean( p_commit ) THEN

IF DOM_LOG.CHECK_LOG_LEVEL THEN
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'Rollback . . .') ;
END IF ;
           ROLLBACK TO l_api_name ;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       FND_MSG_PUB.Count_And_Get
        (   p_count  =>      x_msg_count
         ,  p_data   =>      x_msg_data
        );

IF DOM_LOG.CHECK_LOG_LEVEL THEN
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'Rollback and Finish with unxepcted error.') ;
END IF ;

   WHEN OTHERS THEN
       IF FND_API.To_Boolean( p_commit ) THEN
IF DOM_LOG.CHECK_LOG_LEVEL THEN
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'Rollback . . .') ;
END IF ;
           ROLLBACK TO l_api_name ;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       FND_MSG_PUB.Count_And_Get
        (   p_count  =>      x_msg_count
         ,  p_data   =>      x_msg_data
        );

       IF  FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
            FND_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME
              , l_api_name
              );
       END IF;

       FND_MSG_PUB.Count_And_Get
        (   p_count  =>      x_msg_count
         ,  p_data   =>      x_msg_data
        );

IF DOM_LOG.CHECK_LOG_LEVEL THEN
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'Rollback and finish with system unxepcted error: '
               || Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240));
END IF ;


END Start_Doc_LC_Phase_WF ;


--
--
-- Abort DOC LC Phase Workflow to integrate CM Worklfow
-- This API is called when starting Doc LC Phase Workflow
-- We can put validation logic here
--
Procedure Abort_Doc_LC_Phase_WF
(  p_api_version        IN  NUMBER                             --
  ,p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE        --
  ,p_commit             IN  VARCHAR2 := FND_API.G_FALSE        --
  ,p_validation_level   IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
  ,x_return_status      OUT  NOCOPY  VARCHAR2                   --
  ,x_msg_count          OUT  NOCOPY  NUMBER                     --
  ,x_msg_data           OUT  NOCOPY  VARCHAR2
  ,p_change_id          IN  NUMBER
  ,p_route_id           IN  NUMBER
  ,p_lc_phase_code      IN  NUMBER := NULL
  ,p_api_caller         IN  VARCHAR2
 )
 IS


    l_api_name         CONSTANT VARCHAR2(30) := 'Abort_Doc_LC_Phase_WF';
    l_api_version      CONSTANT NUMBER       := 1.0;

 BEGIN


     -- Standard Start of API savepoint
     SAVEPOINT l_api_name;

     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call(  l_api_version
                                        , p_api_version
                                        , l_api_name
                                        , G_PKG_NAME )
     THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
     END IF ;

     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;


IF ( DOM_LOG.CHECK_LOG_LEVEL) THEN
  DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'begin ' || l_api_name);
  DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'-----------------------------------------------------');
  DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'Change Id          : ' || TO_CHAR(p_change_id) );
  DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'Route Id           : ' || TO_CHAR(p_route_id) );
  DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'LC Phase Code      : ' || TO_CHAR(p_lc_phase_code) );
  DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'API Caller         : ' || p_api_caller);
  DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'-----------------------------------------------------');
END IF ;


    -----------------------------------------------------------------
    -- API body
    -----------------------------------------------------------------

    -- R12 No Business Logic
    -- At this time, this is place folder for future enh.


    -----------------------------------------------------------------
    -- End of API body
    -----------------------------------------------------------------

IF ( DOM_LOG.CHECK_LOG_LEVEL) THEN
   DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'end ' || l_api_name);
END IF ;


    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN

 IF DOM_LOG.CHECK_LOG_LEVEL THEN
    DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'Do Commit.') ;
 END IF ;

       COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
       (  p_count  => x_msg_count
       ,  p_data   => x_msg_data
       );

 IF DOM_LOG.CHECK_LOG_LEVEL THEN
    DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'Finish. Eng Of Proc') ;
 END IF ;


 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
 IF DOM_LOG.CHECK_LOG_LEVEL THEN
    DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'Rollback . . .') ;
 END IF ;
            ROLLBACK TO l_api_name ;
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR ;

        FND_MSG_PUB.Count_And_Get
         (   p_count  =>      x_msg_count
          ,  p_data   =>      x_msg_data
         );

 IF DOM_LOG.CHECK_LOG_LEVEL THEN
    DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'RollBack and Finish with Error.') ;
 END IF ;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF FND_API.To_Boolean( p_commit ) THEN
 IF DOM_LOG.CHECK_LOG_LEVEL THEN
    DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'Rollback . . .') ;
 END IF ;
            ROLLBACK TO l_api_name ;
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        FND_MSG_PUB.Count_And_Get
         (   p_count  =>      x_msg_count
          ,  p_data   =>      x_msg_data
         );

 IF DOM_LOG.CHECK_LOG_LEVEL THEN
    DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'Rollback and Finish with unxepcted error.') ;
 END IF ;

    WHEN OTHERS THEN
        IF FND_API.To_Boolean( p_commit ) THEN
 IF DOM_LOG.CHECK_LOG_LEVEL THEN
    DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'Rollback . . .') ;
 END IF ;
            ROLLBACK TO l_api_name ;
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        FND_MSG_PUB.Count_And_Get
         (   p_count  =>      x_msg_count
          ,  p_data   =>      x_msg_data
         );

        IF  FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
             FND_MSG_PUB.Add_Exc_Msg
               ( G_PKG_NAME
               , l_api_name
               );
        END IF;

        FND_MSG_PUB.Count_And_Get
         (   p_count  =>      x_msg_count
          ,  p_data   =>      x_msg_data
         );

 IF DOM_LOG.CHECK_LOG_LEVEL THEN
    DOM_LOG.LOG_STR(G_PKG_NAME,l_api_name, null,'Rollback and finish with system unxepcted error: '
                || Substr(To_Char(SQLCODE)||'/'||SQLERRM,1,240));
 END IF ;


 END Abort_Doc_LC_Phase_WF ;




-- -----------------------------------------------------------------------------
--  API Name:       Generate_Seq_For_Doc_Category
--
--  Description:
--    Create sequences for Document categories for Number and Revision generation
-- -----------------------------------------------------------------------------
PROCEDURE Generate_Seq_For_Doc_Category (
       p_doc_category_id          IN  NUMBER
       ,p_seq_start_num                 IN  NUMBER
       ,p_seq_increment_by              IN  NUMBER
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
       ,p_num_rev_type                  IN VARCHAR2
)IS
    l_api_name               CONSTANT VARCHAR2(50) := 'Generate_Sequence_For_Doc_category';
    l_seq_name               VARCHAR2(100);
    l_syn_name               VARCHAR2(100);
    l_seq_name_prefix        VARCHAR2(70) ;
    l_seq_name_suffix        CONSTANT VARCHAR2(10) := '_S' ;
    l_dyn_sql                VARCHAR2(100);
    l_syn_name_prefix       VARCHAR2(40);
    l_status                 VARCHAR2(1);
    l_industry               VARCHAR2(1);
    l_schema                 VARCHAR2(30);
    l_apps_user              CONSTANT VARCHAR2(10) := 'APPS';

BEGIN

    IF FND_INSTALLATION.GET_APP_INFO('DOM', l_status, l_industry, l_schema) THEN
       IF l_schema IS NULL    THEN
          Raise_Application_Error (-20001, 'DOM Schema could not be located.');
       END IF;
    ELSE
       Raise_Application_Error (-20001, 'DOM Schema could not be located.');
    END IF;

    IF p_num_rev_type = 'NUM' THEN
      l_seq_name_prefix := l_schema ||'.'||'DOC_NUM_SEQ_';
      l_syn_name_prefix := 'DOC_NUM_SEQ_';
    ELSE
      l_seq_name_prefix := l_schema ||'.'||'DOC_REV_SEQ_';
      l_syn_name_prefix := 'DOC_REV_SEQ_';
    END IF;

    l_seq_name  := l_seq_name_prefix || p_doc_category_id || l_seq_name_suffix;
    l_dyn_sql   := 'CREATE SEQUENCE '||l_seq_name||' INCREMENT BY '||p_seq_increment_by||' START WITH '||p_seq_start_num || ' NOCACHE';
    EXECUTE IMMEDIATE l_dyn_sql;
    l_syn_name  := l_syn_name_prefix || p_doc_category_id || l_seq_name_suffix;
    l_dyn_sql   := 'CREATE SYNONYM '||l_syn_name||' FOR '||l_seq_name;
    EXECUTE IMMEDIATE l_dyn_sql;
    --fix for bug 7695643, create grant to APPS with grant option
    l_dyn_sql   := 'GRANT ALL ON ' || l_seq_name ||' TO ' || l_apps_user || ' WITH GRANT OPTION';
    ad_ddl.do_ddl('APPS', 'DOM', ad_ddl.create_grants, l_dyn_sql , l_seq_name);



EXCEPTION
   WHEN others THEN
      x_return_status  :=  G_RET_STS_UNEXP_ERROR;
      x_msg_data := G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;
END Generate_Seq_For_Doc_Category;

----------------------------------------------------------------------
-- -----------------------------------------------------------------------------
--  API Name:       Drop_Sequence_For_Category
--
--  Description:
--  Drops the Sequence For Number Generation or Revision Generation
-- -----------------------------------------------------------------------------
PROCEDURE Drop_Sequence_For_Category (
       p_doc_category_seq_name               IN  VARCHAR2
       ,x_return_status                OUT NOCOPY VARCHAR2
       ,x_errorcode                    OUT NOCOPY NUMBER
       ,x_msg_count                    OUT NOCOPY NUMBER
       ,x_msg_data                     OUT NOCOPY VARCHAR2)
IS
    l_api_name               CONSTANT VARCHAR2(50) := 'Drop_Sequence_For_Category';
    l_dyn_sql                VARCHAR2(100);
    l_status                 VARCHAR2(1);
    l_industry               VARCHAR2(1);
    l_schema                 VARCHAR2(30);
BEGIN

    IF FND_INSTALLATION.GET_APP_INFO('DOM', l_status, l_industry, l_schema) THEN
       IF l_schema IS NULL    THEN
          Raise_Application_Error (-20001, 'DOM Schema could not be located.');
       END IF;
    ELSE
       Raise_Application_Error (-20001, 'DOM Schema could not be located.');
    END IF;

    l_dyn_sql   := 'DROP SYNONYM '||p_doc_category_seq_name;
    EXECUTE IMMEDIATE l_dyn_sql;
    l_dyn_sql   := 'DROP SEQUENCE '||l_schema||'.'||p_doc_category_seq_name;
    EXECUTE IMMEDIATE l_dyn_sql;
EXCEPTION
   WHEN others THEN
      x_return_status  :=  G_RET_STS_UNEXP_ERROR;
      x_msg_data := G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;
END Drop_Sequence_For_Category;
--------------------------------------------------------------------------------------

--  API Name:       GET_DOC_NUM_SCHEME
--
--  Description:
--  to get effective num generation scheme
-- -----------------------------------------------------------------------------
FUNCTION GET_DOC_NUM_SCHEME
(   P_CATEGORY_ID            IN  NUMBER
) RETURN VARCHAR2
IS
l_doc_num_scheme VARCHAR2(30);
BEGIN
SELECT
      DOC_NUM_SCHEME INTO l_doc_num_scheme
      FROM(
        SELECT  CATEGORY_ID
              , PARENT_CATEGORY_ID
              , DOC_NUM_SCHEME
          FROM  dom_document_categories
         WHERE  DOC_NUM_SCHEME <> 'INHERITED'
                CONNECT BY PRIOR parent_category_id = category_id
                START WITH category_id = P_CATEGORY_ID ) doc_schemes
 WHERE ROWNUM=1;

 RETURN l_doc_num_scheme;

END GET_DOC_NUM_SCHEME;
--------------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------
--  API Name:       rowtocol
--  Srinivas Chintamani
--  Description:
--    Generic function to convert rows returned by arbitrary SQL into
--    a list using the passed in seperator character.
-- -----------------------------------------------------------------------------
 FUNCTION rowtocol
  ( p_slct  IN VARCHAR2,
    p_dlmtr IN VARCHAR2 DEFAULT ','
  ) RETURN VARCHAR2 is

     /*
      1) Column should be character type.
      2) If it is non-character type, column has to be converted into character type.
      3) If the returned rows should in a specified order, put that ORDER BY CLASS in the SELECT statement argument.
      4) If the SQL statement happened to return duplicate values, and if you don't want that to happen, put DISTINCT in the SELECT statement argument.
     */

  TYPE c_refcur IS REF CURSOR;
  lc_str    VARCHAR2(4000);
  lc_colval VARCHAR2(4000);
  c_dummy   c_refcur;
  l         number;

  BEGIN
    OPEN c_dummy FOR p_slct;
    LOOP
      FETCH c_dummy INTO lc_colval;
      EXIT WHEN c_dummy%NOTFOUND;
      lc_str := lc_str || p_dlmtr || lc_colval;
    END LOOP;

    CLOSE c_dummy;
    RETURN SUBSTR(lc_str,2);

  EXCEPTION
    WHEN OTHERS THEN
      lc_str := SQLERRM;
    IF c_dummy%ISOPEN THEN
      CLOSE c_dummy;
    END IF;
    RETURN lc_str;
  END rowtocol;
--------------------------------------------------------------------------------------

END DOM_DOCUMENT_UTIL;

/
