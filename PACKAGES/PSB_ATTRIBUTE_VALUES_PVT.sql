--------------------------------------------------------
--  DDL for Package PSB_ATTRIBUTE_VALUES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_ATTRIBUTE_VALUES_PVT" AUTHID CURRENT_USER as
 /* $Header: PSBVPAVS.pls 120.2 2005/07/13 11:27:50 shtripat ship $ */

procedure INSERT_ROW (
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  P_ROWID                       in OUT  NOCOPY  VARCHAR2,
  --
  P_ATTRIBUTE_VALUE_ID          in      NUMBER,
  P_ATTRIBUTE_ID                in      NUMBER,
  P_ATTRIBUTE_VALUE             in      VARCHAR2,
  P_HR_VALUE_ID                 in      VARCHAR2,
  P_DESCRIPTION                 in      VARCHAR2,
  P_DATA_EXTRACT_ID             in      NUMBER,
  P_CONTEXT                     in      VARCHAR2,
  P_ATTRIBUTE1                  in      VARCHAR2,
  P_ATTRIBUTE2                  in      VARCHAR2,
  P_ATTRIBUTE3                  in      VARCHAR2,
  P_ATTRIBUTE4                  in      VARCHAR2,
  P_ATTRIBUTE5                  in      VARCHAR2,
  P_ATTRIBUTE6                  in      VARCHAR2,
  P_ATTRIBUTE7                  in      VARCHAR2,
  P_ATTRIBUTE8                  in      VARCHAR2,
  P_ATTRIBUTE9                  in      VARCHAR2,
  P_ATTRIBUTE10                 in      VARCHAR2,
  P_ATTRIBUTE11                 in      VARCHAR2,
  P_ATTRIBUTE12                 in      VARCHAR2,
  P_ATTRIBUTE13                 in      VARCHAR2,
  P_ATTRIBUTE14                 in      VARCHAR2,
  P_ATTRIBUTE15                 in      VARCHAR2,
  P_ATTRIBUTE16                 in      VARCHAR2,
  P_ATTRIBUTE17                 in      VARCHAR2,
  P_ATTRIBUTE18                 in      VARCHAR2,
  P_ATTRIBUTE19                 in      VARCHAR2,
  P_ATTRIBUTE20                 in      VARCHAR2,
  P_ATTRIBUTE21                 in      VARCHAR2,
  P_ATTRIBUTE22                 in      VARCHAR2,
  P_ATTRIBUTE23                 in      VARCHAR2,
  P_ATTRIBUTE24                 in      VARCHAR2,
  P_ATTRIBUTE25                 in      VARCHAR2,
  P_ATTRIBUTE26                 in      VARCHAR2,
  P_ATTRIBUTE27                 in      VARCHAR2,
  P_ATTRIBUTE28                 in      VARCHAR2,
  P_ATTRIBUTE29                 in      VARCHAR2,
  P_ATTRIBUTE30                 in      VARCHAR2,
  P_LAST_UPDATE_DATE            in      DATE,
  P_LAST_UPDATED_BY             in      NUMBER,
  P_LAST_UPDATE_LOGIN           in      NUMBER,
  P_CREATED_BY                  in      NUMBER,
  P_CREATION_DATE               in      DATE
);

procedure LOCK_ROW (
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  p_lock_row                    OUT  NOCOPY     VARCHAR2,
  P_ROWID                       in      VARCHAR2,
  --
  P_ATTRIBUTE_VALUE_ID          in      NUMBER,
  P_ATTRIBUTE_ID                in      NUMBER,
  P_ATTRIBUTE_VALUE             in      VARCHAR2,
  P_HR_VALUE_ID                 in      VARCHAR2,
  P_DESCRIPTION                 in      VARCHAR2,
  P_DATA_EXTRACT_ID             in      NUMBER,
  P_CONTEXT                     in      VARCHAR2,
  P_ATTRIBUTE1                  in      VARCHAR2,
  P_ATTRIBUTE2                  in      VARCHAR2,
  P_ATTRIBUTE3                  in      VARCHAR2,
  P_ATTRIBUTE4                  in      VARCHAR2,
  P_ATTRIBUTE5                  in      VARCHAR2,
  P_ATTRIBUTE6                  in      VARCHAR2,
  P_ATTRIBUTE7                  in      VARCHAR2,
  P_ATTRIBUTE8                  in      VARCHAR2,
  P_ATTRIBUTE9                  in      VARCHAR2,
  P_ATTRIBUTE10                 in      VARCHAR2,
  P_ATTRIBUTE11                 in      VARCHAR2,
  P_ATTRIBUTE12                 in      VARCHAR2,
  P_ATTRIBUTE13                 in      VARCHAR2,
  P_ATTRIBUTE14                 in      VARCHAR2,
  P_ATTRIBUTE15                 in      VARCHAR2,
  P_ATTRIBUTE16                 in      VARCHAR2,
  P_ATTRIBUTE17                 in      VARCHAR2,
  P_ATTRIBUTE18                 in      VARCHAR2,
  P_ATTRIBUTE19                 in      VARCHAR2,
  P_ATTRIBUTE20                 in      VARCHAR2,
  P_ATTRIBUTE21                 in      VARCHAR2,
  P_ATTRIBUTE22                 in      VARCHAR2,
  P_ATTRIBUTE23                 in      VARCHAR2,
  P_ATTRIBUTE24                 in      VARCHAR2,
  P_ATTRIBUTE25                 in      VARCHAR2,
  P_ATTRIBUTE26                 in      VARCHAR2,
  P_ATTRIBUTE27                 in      VARCHAR2,
  P_ATTRIBUTE28                 in      VARCHAR2,
  P_ATTRIBUTE29                 in      VARCHAR2,
  P_ATTRIBUTE30                 in      VARCHAR2
);

procedure UPDATE_ROW (
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  P_ATTRIBUTE_VALUE_ID          in      NUMBER,
  P_ATTRIBUTE_ID                in      NUMBER,
  P_ATTRIBUTE_VALUE             in      VARCHAR2,
  P_HR_VALUE_ID                 in      VARCHAR2,
  P_DESCRIPTION                 in      VARCHAR2,
  P_DATA_EXTRACT_ID             in      NUMBER,
  P_CONTEXT                     in      VARCHAR2,
  P_ATTRIBUTE1                  in      VARCHAR2,
  P_ATTRIBUTE2                  in      VARCHAR2,
  P_ATTRIBUTE3                  in      VARCHAR2,
  P_ATTRIBUTE4                  in      VARCHAR2,
  P_ATTRIBUTE5                  in      VARCHAR2,
  P_ATTRIBUTE6                  in      VARCHAR2,
  P_ATTRIBUTE7                  in      VARCHAR2,
  P_ATTRIBUTE8                  in      VARCHAR2,
  P_ATTRIBUTE9                  in      VARCHAR2,
  P_ATTRIBUTE10                 in      VARCHAR2,
  P_ATTRIBUTE11                 in      VARCHAR2,
  P_ATTRIBUTE12                 in      VARCHAR2,
  P_ATTRIBUTE13                 in      VARCHAR2,
  P_ATTRIBUTE14                 in      VARCHAR2,
  P_ATTRIBUTE15                 in      VARCHAR2,
  P_ATTRIBUTE16                 in      VARCHAR2,
  P_ATTRIBUTE17                 in      VARCHAR2,
  P_ATTRIBUTE18                 in      VARCHAR2,
  P_ATTRIBUTE19                 in      VARCHAR2,
  P_ATTRIBUTE20                 in      VARCHAR2,
  P_ATTRIBUTE21                 in      VARCHAR2,
  P_ATTRIBUTE22                 in      VARCHAR2,
  P_ATTRIBUTE23                 in      VARCHAR2,
  P_ATTRIBUTE24                 in      VARCHAR2,
  P_ATTRIBUTE25                 in      VARCHAR2,
  P_ATTRIBUTE26                 in      VARCHAR2,
  P_ATTRIBUTE27                 in      VARCHAR2,
  P_ATTRIBUTE28                 in      VARCHAR2,
  P_ATTRIBUTE29                 in      VARCHAR2,
  P_ATTRIBUTE30                 in      VARCHAR2,
  P_LAST_UPDATE_DATE            in      DATE,
  P_LAST_UPDATED_BY             in      NUMBER,
  P_LAST_UPDATE_LOGIN           in      NUMBER
);


procedure DELETE_ROW (
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  P_ATTRIBUTE_VALUE_ID          IN      NUMBER
);


PROCEDURE Check_References
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_ATTRIBUTE_ID              IN       NUMBER,
  p_ATTRIBUTE_VALUE_ID        IN       NUMBER,
  p_Return_Value              IN OUT  NOCOPY   VARCHAR2
);


end PSB_ATTRIBUTE_VALUES_PVT;

 

/
