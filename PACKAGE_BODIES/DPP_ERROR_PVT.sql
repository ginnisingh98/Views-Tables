--------------------------------------------------------
--  DDL for Package Body DPP_ERROR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DPP_ERROR_PVT" AS
/* $Header: dppverrb.pls 120.4.12010000.2 2010/04/21 13:36:28 kansari ship $ */

-- Package name     : DPP_ERROR_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'DPP_ERROR_PVT';
G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
G_FILE_NAME     CONSTANT VARCHAR2(14) := 'dpperrb.pls';

---------------------------------------------------------------------
-- PROCEDURE
--    UUpdate_Error
--
-- PURPOSE
--    Update Error
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

PROCEDURE Update_Error(
    p_api_version   	 IN 	  NUMBER
   ,p_init_msg_list	     IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_commit	         IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level	 IN 	  NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status	     OUT  NOCOPY	  VARCHAR2
   ,x_msg_count	         OUT NOCOPY	  NUMBER
   ,x_msg_data	         OUT 	NOCOPY  VARCHAR2
   ,p_exe_update_rec	 IN   dpp_error_rec_type
   ,p_lines_tbl	         IN   dpp_lines_tbl_type
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Update_Error';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

l_return_status         varchar2(30);
l_msg_count             number;
l_msg_data              varchar2(4000);

l_exe_update_rec        DPP_ERROR_PVT.dpp_error_rec_type    := p_exe_update_rec;
l_lines_tbl             DPP_ERROR_PVT.dpp_lines_tbl_type    := p_lines_tbl;
l_update_count          NUMBER;
v_Output_XML            CLOB;

l_x_exe_update_rec      DPP_ExecutionDetails_PVT.DPP_EXE_UPDATE_REC_TYPE;
l_status_Update_tbl     DPP_ExecutionDetails_PVT.dpp_status_Update_tbl_type;
l_module 				CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_ERROR_PVT.UPDATE_ERROR';

BEGIN

-- Standard begin of API savepoint
    SAVEPOINT  Update_Error_PVT;
-- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
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

   dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Private API: ' || l_api_name || 'start');

-- Initialize API return status to sucess
    l_return_status := FND_API.G_RET_STS_SUCCESS;

--
-- API body
--

     BEGIN

        l_x_EXE_UPDATE_rec.Execution_Detail_ID          := l_exe_update_rec.Execution_Detail_ID;
        l_x_EXE_UPDATE_rec.Transaction_Header_ID        := l_exe_update_rec.Transaction_Header_ID;

        l_x_exe_update_rec.Execution_End_Date           := sysdate;
        l_x_exe_update_rec.execution_status             := 'ERROR';
        l_x_exe_update_rec.Last_Updated_By              := l_exe_update_rec.Last_Updated_By;
        l_x_exe_update_rec.Provider_Process_Id          := l_exe_update_rec.Provider_Process_Id;
        l_x_exe_update_rec.Provider_Process_Instance_id   := l_exe_update_rec.Provider_Process_Instance_id;
        l_x_exe_update_rec.Output_XML                     := l_exe_update_rec.Output_XML;

    FOR i IN l_lines_tbl.FIRST..l_lines_tbl.LAST
    LOOP

    l_status_Update_tbl(i).update_status := 'N';
    l_status_Update_tbl(i).transaction_line_id := l_lines_tbl(i);

    END LOOP;

        DPP_ExecutionDetails_PVT.Update_ExecutionDetails(
         p_api_version   	 => l_api_version
        ,p_init_msg_list	 => FND_API.G_FALSE
        ,p_commit	         => FND_API.G_FALSE
        ,p_validation_level	 => FND_API.G_VALID_LEVEL_FULL
        ,x_return_status	 => l_return_status
        ,x_msg_count	     => l_msg_count
        ,x_msg_data	         => l_msg_data
        ,p_EXE_UPDATE_rec	 => l_x_exe_update_rec
        ,p_status_Update_tbl => l_status_Update_tbl
        );

    END;

    x_return_status := l_return_status;

-- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;
   -- Debug Message

   dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Private API: ' || l_api_name || 'end');

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
   );

   IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;

--Exception Handling
    EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO Update_Error_PVT;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count   => x_msg_count,
   p_data    => x_msg_data
   );
   IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Update_Error_PVT;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count => x_msg_count,
   p_data  => x_msg_data
   );
   IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;

WHEN OTHERS THEN
   ROLLBACK TO Update_Error_PVT;
   fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
               fnd_message.set_token('ROUTINE', 'DPP_ERROR_PVT.Update_Error');
               fnd_message.set_token('ERRNO', sqlcode);
               fnd_message.set_token('REASON', sqlerrm);
               FND_MSG_PUB.add;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
   p_encoded => FND_API.G_FALSE,
   p_count => x_msg_count,
   p_data  => x_msg_data
   );
   IF x_msg_count > 1 THEN
   FOR I IN 1..x_msg_count LOOP
       x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
   END LOOP;
END IF;


  END Update_Error;

END DPP_ERROR_PVT;

/
