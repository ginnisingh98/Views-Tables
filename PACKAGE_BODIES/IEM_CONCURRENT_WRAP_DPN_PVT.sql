--------------------------------------------------------
--  DDL for Package Body IEM_CONCURRENT_WRAP_DPN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_CONCURRENT_WRAP_DPN_PVT" as
/* $Header: iemdpwpb.pls 120.0 2005/08/08 18:31:22 kbeagle noship $*/

G_PKG_NAME CONSTANT varchar2(30) :='IEM_CONCURRENT_WRAP_DPN_PVT';
G_STAT			varchar2(30);

PROCEDURE LaunchProcess(ERRBUF   OUT NOCOPY     		VARCHAR2,
                       RETCODE  OUT NOCOPY     		VARCHAR2)
IS
    l_return_status           VARCHAR2(2000);
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(2000);


BEGIN


    IEM_DP_NOTIFICATION_WF_PUB.IEM_LAUNCH_WF_DPNTF(
										p_api_version_number =>1.0,
										p_init_msg_list      =>'T',
										p_commit             =>fnd_api.g_true,
										x_return_status	 =>l_return_status,
										x_msg_count		 =>l_msg_count,
										x_msg_data 		 =>l_msg_data);


    exception
        when others then
            G_STAT:='E';
            raise;
END  LaunchProcess;

END IEM_CONCURRENT_WRAP_DPN_PVT;

/
