--------------------------------------------------------
--  DDL for Package Body IEX_SCOREAPI_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_SCOREAPI_PUB" AS
/* $Header: iexpsrab.pls 120.0 2005/06/15 17:39:57 acaraujo ship $ */

    PG_DEBUG NUMBER;

    G_PKG_NAME    CONSTANT VARCHAR2(30)   := 'IEX_SCOREAPI_PUB';
    G_FILE_NAME   CONSTANT VARCHAR2(12)   := 'iexpsrab.pls';
    G_MSG_ERROR   CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_ERROR;

    G_components_tbl  IEX_SCORE_NEW_PVT.SCORE_ENG_COMP_TBL;
    G_OBJECT_CODE     VARCHAR2(25);


procedure getScore( p_api_version     IN  NUMBER,
                    p_init_msg_list   IN  VARCHAR2,
                    p_SCORE_ID        IN  NUMBER,
                    p_OBJECT_ID       IN  NUMBER,
                    x_SCORE           OUT NOCOPY NUMBER,
                    x_return_status   OUT NOCOPY VARCHAR2,
                    x_msg_count       OUT NOCOPY NUMBER,
                    x_msg_data        OUT NOCOPY VARCHAR)
IS

    l_api_name                  CONSTANT VARCHAR2(30) := 'IEX_SCOREAPI_PUB';
    l_api_version               CONSTANT NUMBER := 1.0;
    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(32767);

    l_scores_tbl                IEX_SCORE_NEW_PVT.SCORES_TBL;
    l_object_ids                IEX_FILTER_PUB.UNIVERSE_IDS;
    l_count                     NUMBER;
    l_validobjectcode           boolean;
    l_validobjectID             boolean;
    --- Begin - Andre Araujo - 11/02/2004 - This has been changed because of a bug in the storage design in the scoring API
    l_running_score  		NUMBER := null;
    --- End - Andre Araujo - 11/02/2004 - This has been changed because of a bug in the storage design in the scoring API

BEGIN

       PG_DEBUG := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
       G_OBJECT_CODE := null;
       l_validobjectcode := TRUE;
       l_validobjectID := TRUE;

       /*--------------------------------------------------+
        |   Standard call to check for call compatibility  |
        +--------------------------------------------------*/

        IF NOT FND_API.Compatible_API_Call(
                                            l_api_version,
                                            p_api_version,
                                            l_api_name,
                                            G_PKG_NAME
                                          )
        THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;

            /*--------------------------------------------------+
            |  Get message count and if 1, return message data  |
            +---------------------------------------------------*/

            FND_MSG_PUB.Count_And_Get(
					p_encoded => FND_API.G_FALSE,
                                        p_count   => l_msg_count,
                                        p_data    => l_msg_data
                                      );
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('Compatility error occurred.', G_MSG_ERROR);
            END IF;

            x_msg_count := l_msg_count;
            x_msg_data  := l_msg_data;

            RETURN ;

        END IF;

       /*-------------------------------------------------------------+
       |   Initialize message list if p_init_msg_list is set to TRUE  |
       +-------------------------------------------------------------*/

        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
            FND_MSG_PUB.initialize;
        END IF;


   	-- Initialize API return status to success
   	l_return_status := FND_API.G_RET_STS_SUCCESS;

   	-- START OF BODY OF API
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	    iex_debug_pub.LogMessage(l_api_name || ': Start of API');
	END IF;


      -- enumerate components for this scoring engine
         IEX_SCORE_NEW_PVT.getComponents(p_score_id       => p_score_id ,
                                         X_SCORE_COMP_TBL => g_components_tbl);

         IF g_components_tbl is null or g_components_tbl.count < 1 then

             FND_FILE.PUT_LINE(FND_FILE.LOG, 'IEX_SCORE: scoreObjects: No score components for engine ' || p_score_id);
             FND_MESSAGE.Set_Name('IEX', 'IEX_NO_SCORE_ENG_COMPONENTS');
             FND_MSG_PUB.Add;
             --RAISE FND_API.G_EXC_ERROR;
             x_return_status := FND_API.G_RET_STS_ERROR;
             FND_MSG_PUB.Count_And_Get(
				       p_encoded => FND_API.G_FALSE,
                                       p_count   => l_msg_count,
                                       p_data    => l_msg_data
                                      );

             if (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                 IEX_DEBUG_PUB.logMessage('IEX_SCORE: scoreObjects: No score components for engine');
             end if;

             x_msg_count := l_msg_count;
             x_msg_data  := l_msg_data;

             RETURN;

         END IF;


      -- Validate Scoring Engine

         l_validobjectcode := checkObject_Compatibility(P_SCORE_ID);
         IF l_validobjectcode = FALSE THEN

            if (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.logMessage('IEX_SCORE: scoreObjects: Score Object is not match to engine');
            end if;

            FND_FILE.PUT_LINE(FND_FILE.LOG, 'IEX_SCORE: scoreObjects: Score Object is not match to engine ' || p_score_id);
            FND_MESSAGE.Set_Name('IEX', 'IEX_INVALID_SCORING_ENGINE');
            FND_MSG_PUB.Add;
            -- RAISE FND_API.G_EXC_ERROR;
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get(
				   p_encoded => FND_API.G_FALSE,
                                   p_count   => l_msg_count,
                                   p_data    => l_msg_data
                                  );
            x_msg_count := l_msg_count;
            x_msg_data  := l_msg_data;
            RETURN;

         END IF;

      -- Validate Object ID

         l_validobjectID := IEX_SCORE_NEW_PVT.validateObjectID(P_OBJECT_ID,G_OBJECT_CODE);

         IF l_validobjectID = FALSE THEN

            if (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.logMessage('IEX_SCORE: scoreObjects: Score Object ID is not match to engine');
            end if;

            FND_FILE.PUT_LINE(FND_FILE.LOG, 'IEX_SCORE: scoreObjects: Score Object ID is not match to engine ' || p_object_id);
            FND_MESSAGE.Set_Name('IEX', 'IEX_INVALID_SCORING_ENGINE');
            FND_MSG_PUB.Add;
            -- RAISE FND_API.G_EXC_ERROR;
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get(
				   p_encoded => FND_API.G_FALSE,
                                   p_count   => l_msg_count,
                                   p_data    => l_msg_data
                                  );
            x_msg_count := l_msg_count;
            x_msg_data  := l_msg_data;
            RETURN;

         END IF;


         l_object_ids(1) := p_object_id;


      -- get the scores for the object

         l_count := l_scores_tbl.count;

         For i in 1..l_count Loop
               l_scores_tbl(i) := 0;
         End Loop;

    --- Begin - Andre Araujo - 11/02/2004 - This has been changed because of a bug in the storage design in the scoring API
--         IEX_SCORE_NEW_PVT.getScores(p_score_comp_tbl => g_componentS_tbl,
--                                     t_object_ids     => l_object_ids,
--                                     x_scores_tbl     => l_scores_tbl
--                                     );
	    l_running_score := IEX_SCORE_NEW_PVT.get1Score( g_components_tbl, l_object_ids(1) );

	    l_scores_tbl(1) := l_running_score;

         IF l_running_score is null then
--         IF l_scores_tbl is null or l_scores_tbl.count < 1 then
    --- End - Andre Araujo - 11/02/2004 - This has been changed because of a bug in the storage design in the scoring API

            FND_FILE.PUT_LINE(FND_FILE.LOG, 'No Scores Calculated for Engine: ' || p_score_id);
            FND_MESSAGE.Set_Name('IEX', 'IEX_UNABLE_TO_COMPUTE_SCORES');
            FND_MSG_PUB.Add;
            --RAISE FND_API.G_EXC_ERROR;
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get(
				      p_encoded => FND_API.G_FALSE,
                                      p_count   => l_msg_count,
                                      p_data    => l_msg_data
                                     );

            if (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.logMessage('IEX_SCORE: scoreObjects: Unable to compute scores');
            end if;

            x_msg_count := l_msg_count;
            x_msg_data  := l_msg_data;

            RETURN;

         END if;

         x_return_status := l_return_status ;

             /*--------------------------------------------------+
             |  Get message count and if 1, return message data  |
             +---------------------------------------------------*/

         FND_MSG_PUB.Count_And_Get(
			           p_encoded => FND_API.G_FALSE,
                                   p_count   => l_msg_count,
                                   p_data    => l_msg_data
                                  );

         x_msg_count := l_msg_count;
         x_msg_data  := l_msg_data;

         X_SCORE := l_scores_tbl(1);

  exception
    when others then
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count;
      x_msg_data  := l_msg_data;
      RETURN;

END;


procedure getStatus( p_api_version     IN  NUMBER,
                     p_init_msg_list   IN  VARCHAR2,
                     p_commit          IN  VARCHAR2,
                     p_SCORE_ID        IN  NUMBER,
                     p_SCORE           IN  NUMBER,
                     x_STATUS          OUT NOCOPY VARCHAR2,
                     x_return_status   OUT NOCOPY VARCHAR2,
                     x_msg_count       OUT NOCOPY NUMBER,
                     x_msg_data        OUT NOCOPY VARCHAR)
IS
    l_api_name                  CONSTANT VARCHAR2(30) := 'IEX_SCOREAPI_PUB';
    l_api_version               CONSTANT NUMBER := 1.0;
    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(32767);

    CURSOR C_getStatus(P_SCORE_ID NUMBER,P_SCORE NUMBER)  is
           SELECT  del_status
             FROM  iex_del_statuses
             WHERE P_SCORE between score_value_low and score_value_high
               AND  score_id = P_SCORE_ID;

   l_validobjectcode  boolean;
   l_status           varchar2(25);

BEGIN
       PG_DEBUG := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
       G_OBJECT_CODE := null;
       l_validobjectcode := TRUE;
       l_status := null;

       /*--------------------------------------------------+
        |   Standard call to check for call compatibility  |
        +--------------------------------------------------*/

        IF NOT FND_API.Compatible_API_Call(
                                            l_api_version,
                                            p_api_version,
                                            l_api_name,
                                            G_PKG_NAME
                                          )
        THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;

            /*--------------------------------------------------+
            |  Get message count and if 1, return message data  |
            +---------------------------------------------------*/

            FND_MSG_PUB.Count_And_Get(
				      p_encoded => FND_API.G_FALSE,
                                      p_count   => l_msg_count,
                                      p_data    => l_msg_data
                                     );
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('Compatility error occurred.', G_MSG_ERROR);
            END IF;

            x_msg_count := l_msg_count;
            x_msg_data  := l_msg_data;
            RETURN ;
        END IF;

       /*-------------------------------------------------------------+
       |   Initialize message list if p_init_msg_list is set to TRUE  |
       +-------------------------------------------------------------*/

        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
            FND_MSG_PUB.initialize;
        END IF;


   	-- Initialize API return status to success
   	l_return_status := FND_API.G_RET_STS_SUCCESS;

   	-- START OF BODY OF API
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	    iex_debug_pub.LogMessage(l_api_name || ': Start of API');
	END IF;


      l_validobjectcode := checkObject_Compatibility(P_SCORE_ID);

      IF l_validobjectcode = FALSE THEN

         if (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             IEX_DEBUG_PUB.logMessage('IEX_SCORE: scoreObjects: Score Object is not match to engine');
         end if;

         FND_FILE.PUT_LINE(FND_FILE.LOG, 'IEX_SCORE: scoreObjects: Score Object is not match to engine ' || p_score_id);
         FND_MESSAGE.Set_Name('IEX', 'IEX_INVALID_SCORING_ENGINE');
         FND_MSG_PUB.Add;
         -- RAISE FND_API.G_EXC_ERROR;
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get(
				   p_encoded => FND_API.G_FALSE,
                                   p_count   => l_msg_count,
                                   p_data    => l_msg_data
                                  );
         x_msg_count := l_msg_count;
         x_msg_data  := l_msg_data;
         RETURN;

      ELSE

         Open C_getStatus(P_SCORE_ID,P_SCORE);
         Fetch C_getStatus into l_status;
         IF C_getStatus%NOTFOUND then
            x_STATUS := null;
            x_return_status := FND_API.G_RET_STS_ERROR;
            if PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('Get Status : ' ||'No Status for Score Engine,Score provided. ');
            end if;
         ELSE
            x_STATUS := l_status;
            x_return_status := l_return_status;
         END IF;

       END IF;

       FND_MSG_PUB.Count_And_Get(
				 p_encoded => FND_API.G_FALSE,
                                 p_count   => l_msg_count,
                                 p_data    => l_msg_data
                                );

      x_msg_count := l_msg_count;
      x_msg_data  := l_msg_data;
      RETURN;


      EXCEPTION
         When Others then
           FND_FILE.PUT_LINE(FND_FILE.LOG, 'IEX_SCORE: No Status found ' || p_score_id);
           FND_MESSAGE.Set_Name('AR', 'AR_OPLB_NO_DATA_FOUND');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR;
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_util.debug('Get Status : ' ||'No Status for Score Engine,Score provided. ');
           END IF;
           FND_MSG_PUB.Count_And_Get(
				     p_encoded => FND_API.G_FALSE,
                                     p_count   => l_msg_count,
                                     p_data    => l_msg_data
                                    );
           x_msg_count := l_msg_count;
           x_msg_data  := l_msg_data;
           RETURN;

END;


procedure getScoreStatus( p_api_version IN  NUMBER,
                          p_init_msg_list   IN  VARCHAR2,
                          p_SCORE_ID        IN  NUMBER,
                          p_OBJECT_ID       IN  NUMBER,
                          x_STATUS          OUT NOCOPY VARCHAR2,
                          x_SCORE           OUT NOCOPY NUMBER,
                          x_return_status   OUT NOCOPY VARCHAR2,
                          x_msg_count       OUT NOCOPY NUMBER,
                          x_msg_data        OUT NOCOPY VARCHAR)
IS
    l_api_name                  CONSTANT VARCHAR2(30) := 'IEX_SCOREAPI_PUB';
    l_api_version               CONSTANT NUMBER := 1.0;
    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(32767);

    l_validobjectcode           boolean;
    l_status                    varchar2(25);
    l_score                     number;

BEGIN

       PG_DEBUG := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
       G_OBJECT_CODE := null;
       l_validobjectcode := TRUE;
       l_status := null;
       l_score := 0;
       /*--------------------------------------------------+
        |   Standard call to check for call compatibility  |
        +--------------------------------------------------*/

        IF NOT FND_API.Compatible_API_Call(
                                           l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME
                                          )
        THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;

            /*--------------------------------------------------+
            |  Get message count and if 1, return message data  |
            +---------------------------------------------------*/

            FND_MSG_PUB.Count_And_Get(
					p_encoded => FND_API.G_FALSE,
                                        p_count => l_msg_count,
                                        p_data  => l_msg_data
                                      );
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('Compatility error occurred.', G_MSG_ERROR);
            END IF;

            x_msg_count := l_msg_count;
            x_msg_data  := l_msg_data;

            RETURN ;

        END IF;

       /*-------------------------------------------------------------+
       |   Initialize message list if p_init_msg_list is set to TRUE  |
       +-------------------------------------------------------------*/

        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
            FND_MSG_PUB.initialize;
        END IF;


   	-- Initialize API return status to success
   	l_return_status := FND_API.G_RET_STS_SUCCESS;

   	-- START OF BODY OF API
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	    iex_debug_pub.LogMessage(l_api_name || ': Start of API');
	END IF;


       getScore( p_api_version     =>  1.0,
                 p_init_msg_list   =>  FND_API.G_FALSE,
                 p_SCORE_ID        =>  p_score_id,
                 p_OBJECT_ID       =>  p_object_id,
                 x_SCORE           =>  l_score,
                 x_return_status   =>  l_return_status,
                 x_msg_count       =>  l_msg_count,
                 x_msg_data        =>  l_msg_data);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('Getting Score : ' ||'No Score for Object provided. ');
            END IF;
            FND_MSG_PUB.Count_And_Get(
				      p_encoded => FND_API.G_FALSE,
                                      p_count   => l_msg_count,
                                      p_data    => l_msg_data
                                     );
            x_msg_count := l_msg_count;
            x_msg_data  := l_msg_data;
            RETURN;
      END IF;

      x_score := l_score;

      getStatus( p_api_version     =>  1.0,
                 p_init_msg_list   =>  FND_API.G_FALSE,
                 p_commit          =>  FND_API.G_FALSE,
                 p_SCORE_ID        =>  p_score_id,
                 p_SCORE           =>  l_score,
                 x_STATUS          =>  l_status,
                 x_return_status   =>  l_return_status,
                 x_msg_count       =>  l_msg_count,
                 x_msg_data        =>  l_msg_data);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('Getting Status : ' ||'No Status for Object provided. ');
            END IF;
            FND_MSG_PUB.Count_And_Get(
				      p_encoded => FND_API.G_FALSE,
                                      p_count   => l_msg_count,
                                      p_data    => l_msg_data
                                     );
            x_msg_count := l_msg_count;
            x_msg_data  := l_msg_data;
            RETURN;
      END IF;

      x_msg_count := l_msg_count;
      x_msg_data  := l_msg_data;
      x_status := l_status;
      x_return_status := l_return_status;

  exception
    when others then
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count;
      x_msg_data  := l_msg_data;
      RETURN;

END;


Function checkObject_Compatibility(p_score_id in number)
                                   return BOOLEAN
is
    l_object_code          varchar2(25);
    l_valid_invoice_object varchar2(25);
    l_valid_case_object    varchar2(25);
    l_valid_loan_object    varchar2(25);

begin

    l_valid_invoice_object := 'IEX_INVOICES';
    l_valid_case_object    := 'IEX_CASES';
    l_valid_loan_object    := 'IEX_LOANS';

   begin
        Execute Immediate
        ' Select jtf_object_code ' ||
        ' From iex_scores ' ||
        ' where score_id = :p_score_id'
        into l_object_code
        using p_score_id;
   Exception
        When no_data_found then
        G_OBJECT_CODE := null;
        return FALSE;
        When others then
        G_OBJECT_CODE := null;
        return FALSE;
   end;

    G_OBJECT_CODE := l_object_code;
    return TRUE;

    /* fixed a bug 3799715 by ehuh
    if (l_object_code = l_valid_invoice_object) OR
       (l_object_code = l_valid_loan_object) OR
       (l_object_code = l_valid_case_object) THEN
        return TRUE;
    else
        G_OBJECT_CODE := null;
        return FALSE;
    end if;
    */

Exception
    when others then
            G_OBJECT_CODE := null;
            return false;

end;

END;

/
