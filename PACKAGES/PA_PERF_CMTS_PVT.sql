--------------------------------------------------------
--  DDL for Package PA_PERF_CMTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PERF_CMTS_PVT" AUTHID CURRENT_USER AS
/* $Header: PAPECTVS.pls 120.1 2005/08/19 16:38:20 mwasowic noship $ */



/*==================================================================
  PROCEDURE
      create_comment
  PURPOSE
      This procedure inserts a row into the pa_perf_cmts table.
 ==================================================================*/

     PROCEDURE create_comment(
			     p_api_version           IN NUMBER :=  1.0,
			     p_init_msg_list         IN VARCHAR2 := fnd_api.g_true,
			     p_commit                IN VARCHAR2 := FND_API.g_false,
			     p_validate_only         IN VARCHAR2 := FND_API.g_true,
			     p_max_msg_count         IN NUMBER := FND_API.g_miss_num,
			     P_transaction_id        IN NUMBER,
			     P_COMMENT_TEXT          IN VARCHAR2,
			     p_commented_by          IN NUMBER,
			     P_comment_date          IN DATE,
			     x_comment_id            OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
			     X_RETURN_STATUS         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			     X_MSG_COUNT             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
			     X_MSG_DATA              OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
    ;


END PA_PERF_CMTS_PVT;


 

/
