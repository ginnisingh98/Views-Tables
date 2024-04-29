--------------------------------------------------------
--  DDL for Package PA_OBJECT_REGIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_OBJECT_REGIONS_PVT" AUTHID CURRENT_USER AS
--$Header: PAAPORVS.pls 120.2 2005/08/19 16:16:06 mwasowic noship $

procedure create_object_page_region (
  p_api_version                 IN     NUMBER :=  1.0,
  p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
  p_commit                      IN     VARCHAR2 := FND_API.g_false,
  p_validate_only               IN     VARCHAR2 := FND_API.g_true,
  p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,
  P_OBJECT_ID                   IN     NUMBER,
  P_OBJECT_TYPE 		IN     VARCHAR2,
  P_PLACEHOLDER_REG_CODE 	IN     VARCHAR2,
  P_REPLACEMENT_REG_CODE 	IN     VARCHAR2,
  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2			    --File.Sql.39 bug 4440895
);

procedure update_object_page_region (
  p_api_version                 IN     NUMBER :=  1.0,
  p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
  p_commit                      IN     VARCHAR2 := FND_API.g_false,
  p_validate_only               IN     VARCHAR2 := FND_API.g_true,
  p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,
  P_OBJECT_ID 			IN     NUMBER,
  P_OBJECT_TYPE 		IN     VARCHAR2,
  P_PLACEHOLDER_REG_CODE 	IN     VARCHAR2,
  P_REPLACEMENT_REG_CODE 	IN     VARCHAR2,
  p_record_version_number 	IN     NUMBER,
  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;

procedure DELETE_object_page_region (
  p_api_version                 IN     NUMBER :=  1.0,
  p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
  p_commit                      IN     VARCHAR2 := FND_API.g_false,
  p_validate_only               IN     VARCHAR2 := FND_API.g_true,
  p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,
  P_OBJECT_ID 			IN     NUMBER,
  P_OBJECT_TYPE 		IN     VARCHAR2,
  P_PLACEHOLDER_REG_CODE 	IN     VARCHAR2,
  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
				      ) ;
END  PA_OBJECT_REGIONS_PVT;

 

/
