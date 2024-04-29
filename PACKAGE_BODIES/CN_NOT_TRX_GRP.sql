--------------------------------------------------------
--  DDL for Package Body CN_NOT_TRX_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_NOT_TRX_GRP" as
/* $Header: cngntxb.pls 120.1 2005/09/05 05:36:39 apink noship $ */

G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_NOT_TRX_GRP';

------------------------------------------------------------------------------+
-- Procedure   : Col_Adjustments
------------------------------------------------------------------------------+
PROCEDURE Col_Adjustments
(  p_api_version      IN NUMBER,
   p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
   p_commit           IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level IN  NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2,
   p_org_id 		  IN NUMBER -- Added For R12 MOAC Changes
 ) IS
     l_api_name     CONSTANT VARCHAR2(30) := 'Col_Adjustments';
     l_api_version  CONSTANT NUMBER  := 1.0;
     -- cursor which loops through all the adjusted lines
     CURSOR c_changed_lines IS
     SELECT *
       FROM cn_not_trx
     WHERE adjusted_flag = 'Y'
       AND collected_flag = 'N'
       AND (negated_flag IS NULL OR negated_flag = 'N')
	   AND org_id = p_org_id; -- Added For R12 MOAC Changes

     l_changed_line_rec c_changed_lines%ROWTYPE;

BEGIN
     -- Standard Start of API savepoint
     SAVEPOINT	col_adjustments;
     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call (l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME)
     THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
     END IF;
     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;
	-------------------+
     -- API body
	-------------------+
     FOR l_changed_line_rec IN c_changed_lines LOOP
         cn_comm_lines_api_pkg.negate_record
            (l_changed_line_rec.source_trx_id,
             l_changed_line_rec.source_trx_line_id,
		   l_changed_line_rec.source_doc_type,
		   p_org_id);
         -- update negated_flag to 'Y'
         UPDATE cn_not_trx
           SET negated_flag = 'Y'
         WHERE not_trx_id = l_changed_line_rec.not_trx_id
		 AND   org_id = p_org_id; -- Added For R12 MOAC Changes
     END LOOP;
	-------------------+
     -- End of API body.
	-------------------+
     -- Standard check of p_commit.
     IF FND_API.To_Boolean( p_commit ) THEN
         COMMIT WORK;
     END IF;
     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
                        (p_count   =>  x_msg_count ,
                         p_data    =>  x_msg_data  ,
                         p_encoded => FND_API.G_FALSE);
     EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
             ROLLBACK TO Col_Adjustments;
             x_return_status := FND_API.G_RET_STS_ERROR ;
             FND_MSG_PUB.Count_And_Get
                             (p_count   => x_msg_count,
                              p_data    => x_msg_data,
                              p_encoded => FND_API.G_FALSE);
         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             ROLLBACK TO Col_Adjustments;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             FND_MSG_PUB.Count_And_Get
                             (p_count   => x_msg_count,
                              p_data    => x_msg_data,
                              p_encoded => FND_API.G_FALSE);
         WHEN OTHERS THEN
             ROLLBACK TO Col_Adjustments;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             IF FND_MSG_PUB.Check_Msg_Level
                                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                 FND_MSG_PUB.Add_Exc_Msg
                                (G_PKG_NAME,
                                 l_api_name );
             END IF;
             FND_MSG_PUB.Count_And_Get
                             (p_count   => x_msg_count,
                              p_data    => x_msg_data,
                              p_encoded => FND_API.G_FALSE);
END Col_Adjustments;


END CN_NOT_TRX_GRP;

/
