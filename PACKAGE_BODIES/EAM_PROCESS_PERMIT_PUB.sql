--------------------------------------------------------
--  DDL for Package Body EAM_PROCESS_PERMIT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_PROCESS_PERMIT_PUB" AS
/* $Header: EAMPWPTB.pls 120.0.12010000.4 2010/05/19 12:44:41 vboddapa noship $ */
/***************************************************************************
--
--  Copyright (c) 2010 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME:  EAMPWPTB.pls
--
--  DESCRIPTION:  Body of package EAM_PROCESS_PERMIT_PUB
--
--  NOTES
--
--  HISTORY
--
--  25-JAN-2009   Madhuri Shah     Initial Creation
***************************************************************************/


G_PKG_NAME CONSTANT VARCHAR2(30)  := 'EAM_PROCESS_PERMIT_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'EAMPWPTB.pls';


PROCEDURE  PROCESS_WORK_PERMIT
        (  p_bo_identifier              IN     VARCHAR2 := 'EAM'
         , p_api_version_number         IN     NUMBER := 1.0
         , p_init_msg_list              IN     BOOLEAN := FALSE
         , p_commit                     IN     VARCHAR2
         , p_work_permit_header_rec     IN     EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type
         , p_permit_wo_association_tbl  IN     EAM_PROCESS_PERMIT_PUB.eam_wp_association_tbl_type
         , p_debug                      IN     VARCHAR2
         , p_output_dir                 IN     VARCHAR2
         , p_debug_filename             IN     VARCHAR2
         , p_debug_file_mode            IN     VARCHAR2
         , x_permit_id                  OUT    NOCOPY NUMBER
         , x_return_status              OUT    NOCOPY VARCHAR2
         , x_msg_count                  OUT    NOCOPY NUMBER
        ) IS

         l_api_version                CONSTANT NUMBER       := 1.0;
         lx_work_permit_header_rec     EAM_PROCESS_PERMIT_PUB.eam_wp_header_rec_type;

        l_debug                 VARCHAR2(1) := p_debug;
        l_output_dir            VARCHAR2(512) := p_output_dir;
        l_debug_filename        VARCHAR2(512) := p_debug_filename;
        l_debug_file_mode       VARCHAR2(512) := p_debug_file_mode;
        l_out_mesg_token_tbl    EAM_ERROR_MESSAGE_PVT.mesg_token_tbl_type;
        l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;


        l_return_status         VARCHAR2(1);
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(240);

BEGIN

       IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version_number, G_PKG_NAME, G_FILE_NAME) THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

      IF p_init_msg_list
        THEN
            EAM_ERROR_MESSAGE_PVT.Initialize;
      END IF;

      SAVEPOINT EAM_PR_PROCESS_WORK_PERMIT;

      EAM_PROCESS_WO_PVT.Set_Debug(l_debug);

            IF l_debug = 'Y'
            THEN
                l_out_mesg_token_tbl        := l_mesg_token_tbl;
                EAM_ERROR_MESSAGE_PVT.Open_Debug_Session
                (  p_debug_filename     => p_debug_filename
                ,  p_output_dir         => p_output_dir
                ,  p_debug_file_mode    => l_debug_file_mode
                ,  x_return_status      => l_return_status
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  x_mesg_token_tbl     => l_out_mesg_token_tbl
                 );
                l_mesg_token_tbl        := l_out_mesg_token_tbl;

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                THEN
                    EAM_PROCESS_WO_PVT.Set_Debug('N');
                END IF;
            END IF;

    IF EAM_PROCESS_WO_PVT.get_debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.write_debug(' Calling EAM_PROCESS_PERMIT_PVT.PROCESS_WORK_PERMIT from  EAM_PROCESS_PERMIT_PUB'); end if;

     EAM_PROCESS_PERMIT_PVT.PROCESS_WORK_PERMIT(
           p_bo_identifier             => p_bo_identifier
         , p_api_version_number      	 => l_api_version
         , p_init_msg_list           	 => TRUE
         , p_commit                  	 => p_commit
         , p_work_permit_header_rec  	 => p_work_permit_header_rec
         , p_permit_wo_association_tbl => p_permit_wo_association_tbl
         , x_work_permit_header_rec  	 => lx_work_permit_header_rec
         , x_return_status           	 => l_return_status
         , x_msg_count               	 => l_msg_count
         , p_debug                     => l_debug
         , p_output_dir             	 => l_output_dir
         , p_debug_filename          	 => l_debug_filename
         , p_debug_file_mode        	 => l_debug_file_mode
     );

     x_permit_id :=lx_work_permit_header_rec.permit_id;
     x_return_status :=l_return_status;

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_msg_count :=l_msg_count;
     END IF;

EXCEPTION
   WHEN OTHERS THEN
   --    x_msg_count := EAM_ERROR_MESSAGE_PVT.Get_Message_Count;
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_msg_count :=l_msg_count;
    IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y'
        THEN
            EAM_ERROR_MESSAGE_PVT.Dump_Message_List;
            EAM_ERROR_MESSAGE_PVT.Close_Debug_Session;
    END IF;

END PROCESS_WORK_PERMIT;

PROCEDURE COPY_WORK_PERMIT(
          p_bo_identifier             IN  VARCHAR2 := 'EAM'
         , p_api_version_number        IN  NUMBER   := 1.0
         , p_init_msg_list             IN  BOOLEAN  := FALSE
         , p_commit                    IN  VARCHAR2
         , p_debug                     IN  VARCHAR2
         , p_output_dir                IN  VARCHAR2
         , p_debug_filename            IN  VARCHAR2
         , p_debug_file_mode           IN  VARCHAR2
         , p_org_id                    IN  NUMBER
         , px_permit_id                IN  OUT NOCOPY   NUMBER
         , x_return_status             OUT NOCOPY VARCHAR2
         , x_msg_count                 OUT NOCOPY NUMBER
)IS

        l_api_version                CONSTANT NUMBER       := 1.0;

        l_debug                 VARCHAR2(1) := p_debug;
        l_output_dir            VARCHAR2(512) := p_output_dir;
        l_debug_filename        VARCHAR2(512) := p_debug_filename;
        l_debug_file_mode       VARCHAR2(512) := p_debug_file_mode;
        l_out_mesg_token_tbl    EAM_ERROR_MESSAGE_PVT.mesg_token_tbl_type;
        l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;


        l_return_status         VARCHAR2(1);
        l_msg_count             NUMBER;

BEGIN

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version_number, G_PKG_NAME, G_FILE_NAME) THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

      IF p_init_msg_list
        THEN
            EAM_ERROR_MESSAGE_PVT.Initialize;
      END IF;

      SAVEPOINT EAM_PR_PROCESS_WORK_PERMIT;

      EAM_PROCESS_WO_PVT.Set_Debug(l_debug);

            IF l_debug = 'Y'
            THEN
                l_out_mesg_token_tbl        := l_mesg_token_tbl;
                EAM_ERROR_MESSAGE_PVT.Open_Debug_Session
                (  p_debug_filename     => p_debug_filename
                ,  p_output_dir         => p_output_dir
                ,  p_debug_file_mode    => l_debug_file_mode
                ,  x_return_status      => l_return_status
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  x_mesg_token_tbl     => l_out_mesg_token_tbl
                 );
                l_mesg_token_tbl        := l_out_mesg_token_tbl;

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                THEN
                    EAM_PROCESS_WO_PVT.Set_Debug('N');
                END IF;
            END IF;

    IF EAM_PROCESS_WO_PVT.get_debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.write_debug(' Calling EAM_PROCESS_PERMIT_PVT.COPY_WORK_PERMIT from  EAM_PROCESS_PERMIT_PUB'); end if;

     EAM_PROCESS_PERMIT_PVT.COPY_WORK_PERMIT(
           p_bo_identifier             => p_bo_identifier
         , p_api_version_number      	 => l_api_version
         , p_init_msg_list           	 => TRUE
         , p_commit                  	 => p_commit
         , p_debug                     => l_debug
         , p_output_dir             	 => l_output_dir
         , p_debug_filename          	 => l_debug_filename
         , p_debug_file_mode        	 => l_debug_file_mode
         , p_org_id  	                 => p_org_id
         , px_permit_id  	             => px_permit_id
         , x_return_status           	 => l_return_status
         , x_msg_count               	 => l_msg_count

     );


     x_return_status :=l_return_status;

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_msg_count :=l_msg_count;
     END IF;

EXCEPTION
   WHEN OTHERS THEN
   --    x_msg_count := EAM_ERROR_MESSAGE_PVT.Get_Message_Count;
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_msg_count :=l_msg_count;
    IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y'
        THEN
            EAM_ERROR_MESSAGE_PVT.Dump_Message_List;
            EAM_ERROR_MESSAGE_PVT.Close_Debug_Session;
    END IF;


END COPY_WORK_PERMIT;



END EAM_PROCESS_PERMIT_PUB;

/
