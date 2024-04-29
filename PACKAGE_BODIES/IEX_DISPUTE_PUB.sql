--------------------------------------------------------
--  DDL for Package Body IEX_DISPUTE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_DISPUTE_PUB" AS
/* $Header: iexpdisb.pls 120.6.12010000.2 2008/08/06 09:01:38 schekuri ship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IEX_DISPUTE_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'iexpdisb.pls';

--PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER; --  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
--Added parameters p_skip_workflow_flag and p_dispute_date
--for bug#6347547 by schekuri on 08-Nov-2007
-- Bug #6777367 bibeura 28-Jan-2008 Added parameter p_batch_source_name
PROCEDURE Create_Dispute(p_api_version     IN NUMBER,
                         p_init_msg_list   IN VARCHAR2,
                         p_commit          IN VARCHAR2,
                         p_disp_header_rec IN IEX_DISPUTE_PUB.DISP_HEADER_REC,
                         p_disp_line_tbl   IN IEX_DISPUTE_PUB.DISPUTE_LINE_TBL,
			 x_request_id      OUT NOCOPY NUMBER,
                         x_return_status   OUT NOCOPY VARCHAR2,
                         x_msg_count       OUT NOCOPY NUMBER,
                         x_msg_data        OUT NOCOPY VARCHAR2,
			 p_skip_workflow_flag   IN VARCHAR2    DEFAULT 'N',
			 p_batch_source_name    IN VARCHAR2    DEFAULT NULL,
			 p_dispute_date	IN DATE	DEFAULT NULL) IS

l_api_name           VARCHAR2(50); --  := 'create_dispute';
l_api_version_number NUMBER; -- := 1;
l_request_id         NUMBER;
l_status             VARCHAR(20);
l_init_msg_list      varchar2(10); -- := p_init_msg_list;
l_commit             varchar2(10); -- := p_commit;

l_return_status      VARCHAR2(10); -- := x_return_status;
l_msg_count          NUMBER; --   := x_msg_count;
l_msg_data           VARCHAR2(100); --  := x_msg_data;

l_disp_header_rec    IEX_DISPUTE_PUB.DISP_HEADER_REC; --  := p_disp_header_rec;
l_disp_line_tbl      IEX_DISPUTE_PUB.DISPUTE_LINE_TBL; -- := p_disp_line_tbl;

BEGIN
      l_api_name           := 'create_dispute';
      l_api_version_number := 1;
      l_init_msg_list      := p_init_msg_list;
      l_commit             := p_commit;
      l_return_status      := x_return_status;
      l_msg_count          := x_msg_count;
      l_msg_data           := x_msg_data;
      l_disp_header_rec    := p_disp_header_rec;
      l_disp_line_tbl      := p_disp_line_tbl;

      -- Standard Start of API savepoint
      SAVEPOINT create_dispute_pub;

        -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                          p_api_version,
                                          l_api_name,
                                          G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.logMessage('Create_Dispute: ' || 'PVT: ' || l_api_name || ' start');
      END IF;

      --
      -- API body
      --
      IEX_DISPUTE_PVT.Create_Dispute(p_api_version           => l_api_version_number,
                                     p_init_msg_list         => l_init_msg_list,
                                     p_commit                => l_commit,
                                     p_disp_header_rec       => l_disp_header_rec,
                                     p_disp_line_tbl         => l_disp_line_tbl,
				     p_skip_workflow_flag    => p_skip_workflow_flag,
				     p_batch_source_name     => p_batch_source_name,
				     p_dispute_date	     => p_dispute_date,
                                     x_request_id            => l_request_id,
                                     x_return_status         => l_return_status ,
                                     x_msg_count             => l_msg_count,
                                     x_msg_data              => l_msg_data);
      x_request_id    := l_request_id;
      x_return_status := l_return_status ;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;

      -- TEST TO CATCH ERROR HERE
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          FND_MESSAGE.SET_NAME('IEX', 'IEX_DISPUTE_FAILED');
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;

      END IF ;

     -- End of API body

     IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
     END IF;

     -- Debug Message
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.logMessage('Create_Dispute: ' || 'PVT: ' || l_api_name || ' end');
     END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);


      EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_dispute_pub;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_dispute_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_dispute_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END create_dispute;


PROCEDURE is_delinquency_dispute(p_api_version         IN  NUMBER,
                                 p_init_msg_list       IN  VARCHAR2,
                                 p_delinquency_id      IN  NUMBER,
                                 x_return_status       OUT NOCOPY VARCHAR2,
                                 x_msg_count           OUT NOCOPY NUMBER,
                                 x_msg_data            OUT NOCOPY VARCHAR2) IS

l_api_name           VARCHAR2(50); --  := 'is_delinquency_dispute';
l_api_version_number NUMBER := 1.0;
l_delinquency_id     NUMBER; -- := p_delinquency_id;
l_count              NUMBER := 0 ;
l_status             VARCHAR(20) ;
x                    varchar2(2000);
l_return_status      VARCHAR2(10);
l_msg_count          NUMBER;
l_msg_data           VARCHAR2(100);
l_init_msg_list      varchar2(10); -- := p_init_msg_list;

BEGIN

      l_init_msg_list   := p_init_msg_list;
      l_delinquency_id  := p_delinquency_id;
      l_api_name        := 'is_delinquency_dispute';
      -- Standard Start of API savepoint
      SAVEPOINT is_delinquency_pvt;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                          p_api_version,
                                          l_api_name,
                                          G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.logMessage('is_delinquency_dispute: ' || 'PVT: ' || l_api_name || ' start');
      END IF;

      --
      -- API body
      --
      IEX_DISPUTE_PVT.is_delinquency_dispute(p_api_version        => l_api_version_number,
                                             p_init_msg_list      => l_init_msg_list,
                                             p_delinquency_id     => l_delinquency_id,
                                             x_return_status      => l_return_status,
                                             x_msg_count          => l_msg_count,
                                             x_msg_data           => l_msg_data );

      x_return_status := l_return_status ;
      x_msg_count  := l_msg_count ;
      x_msg_data   := l_msg_data ;

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          FND_MESSAGE.SET_NAME('IEX', 'IEX_DISPUTE_DELINQUENT_FAILED');
          FND_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;

      END IF ;

     -- End of API body

     -- Debug Message
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.logMessage('is_delinquency_dispute: ' || 'PVT: ' || l_api_name || ' end');
     END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO is_delinquency_pvt;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO is_delinquency_pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO is_delinquency_pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END is_delinquency_dispute;

--Start bug 6856035 gnramasa 28th May 08
PROCEDURE CANCEL_DISPUTE (p_api_version     IN NUMBER,
                          p_commit          IN VARCHAR2,
			  p_dispute_id      IN NUMBER,
			  p_cancel_comments IN VARCHAR2,
                          x_return_status   OUT NOCOPY VARCHAR2,
                          x_msg_count       OUT NOCOPY NUMBER,
                          x_msg_data        OUT NOCOPY VARCHAR2) IS

l_api_name           VARCHAR2(50); --  := 'cancel_dispute';
l_api_version_number NUMBER; -- := 1;
l_dispute_id         NUMBER;
l_status             VARCHAR(20);
l_commit             varchar2(10); -- := p_commit;
errmsg               VARCHAR2(32767);

l_return_status      VARCHAR2(10); -- := x_return_status;
l_msg_count          NUMBER; --   := x_msg_count;
l_msg_data           VARCHAR2(100); --  := x_msg_data;

BEGIN
      l_api_name           := 'Cancel_dispute';
      l_api_version_number := 1;
      l_commit             := p_commit;
      l_return_status      := x_return_status;
      l_msg_count          := x_msg_count;
      l_msg_data           := x_msg_data;
      l_dispute_id         := p_dispute_id;

      -- Standard Start of API savepoint
      SAVEPOINT cancel_dispute_pub;

        -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                          p_api_version,
                                          l_api_name,
                                          G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.logMessage('Cancel_Dispute: ' || 'PVT: ' || l_api_name || ' start');
      END IF;

      --
      -- API body
      --
      IEX_DISPUTE_PVT.Cancel_Dispute( p_api_version     => l_api_version_number,
				      p_commit          => l_commit,
				      p_dispute_id      => l_dispute_id,
			              p_cancel_comments => p_cancel_comments,
                                      x_return_status   => l_return_status ,
                                      x_msg_count       => l_msg_count,
                                      x_msg_data        => l_msg_data);

      x_return_status := l_return_status ;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;

      -- TEST TO CATCH ERROR HERE
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE:  - exception');
		errmsg := SQLERRM;
		IEX_DEBUG_PUB.logMessage('CANCEL_DISPUTE:  - errmsg='||errmsg);
	  END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;

      END IF ;

     -- End of API body

     IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
     END IF;

     -- Debug Message
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.logMessage('Cancel_Dispute: ' || 'PVT: ' || l_api_name || ' end');
     END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);


      EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO cancel_dispute_pub;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO cancel_dispute_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO cancel_dispute_pub;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END cancel_dispute;
--End bug 6856035 gnramasa 28th May 08

FUNCTION init_disp_rec RETURN DISP_HEADER_REC
AS
l_dispute_header_rec IEX_DISPUTE_PUB.DISP_HEADER_REC;

BEGIN
   RETURN l_dispute_header_rec;

END init_disp_rec;

FUNCTION init_disp_line_tbl RETURN DISPUTE_LINE_TBL
AS
l_dispute_line_tbl IEX_DISPUTE_PUB.DISPUTE_LINE_TBL;

BEGIN
   RETURN l_dispute_line_tbl;

END init_disp_line_tbl;
begin
  PG_DEBUG := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

END IEX_DISPUTE_PUB ;

/
