--------------------------------------------------------
--  DDL for Package CS_KB_SET_LINKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_KB_SET_LINKS_PKG" AUTHID CURRENT_USER AS
/* $Header: cskbsls.pls 120.1 2005/07/27 19:05:06 appldev ship $ */

  /* for return status */
  ERROR_STATUS      CONSTANT NUMBER      := -1;
  OKAY_STATUS       CONSTANT NUMBER      := 0;

function Clone_Link(
P_SET_SOURCE_ID in NUMBER,
P_SET_TARGET_ID in NUMBER
)return number;

procedure Create_Set_Link(
  P_LINK_TYPE in VARCHAR,
  P_OBJECT_CODE in VARCHAR,
  P_SET_ID in NUMBER,
  P_OTHER_ID in NUMBER,
  P_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  x_link_id         in OUT NOCOPY           NUMBER,
  x_return_status      OUT NOCOPY           VARCHAR2,
  x_msg_data           OUT NOCOPY           VARCHAR2,
  x_msg_count          OUT NOCOPY           NUMBER
  );

function Create_Set_Link(
  P_LINK_TYPE in VARCHAR,
  P_OBJECT_CODE in VARCHAR,
  P_SET_ID in NUMBER,
  P_OTHER_ID in NUMBER,
  P_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL
) return number;

procedure Create_Set_Ext_Link(
  P_LINK_TYPE in VARCHAR,
  P_OBJECT_CODE in VARCHAR,
  P_SET_ID in NUMBER,
  P_OTHER_ID in NUMBER,
  P_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  x_link_id         in OUT NOCOPY           NUMBER,
  x_return_status      OUT NOCOPY           VARCHAR2,
  x_msg_data           OUT NOCOPY           VARCHAR2,
  x_msg_count          OUT NOCOPY           NUMBER
  );

procedure Update_Set_Link(
  P_LINK_ID in NUMBER,
  P_LINK_TYPE in VARCHAR,
  P_OBJECT_CODE in VARCHAR,
  P_SET_ID in NUMBER,
  P_OTHER_ID in NUMBER,
  P_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_data      OUT NOCOPY VARCHAR2,
  x_msg_count     OUT NOCOPY NUMBER
  );

function Update_Set_Link(
  P_LINK_ID in NUMBER,
  P_LINK_TYPE in VARCHAR,
  P_OBJECT_CODE in VARCHAR,
  P_SET_ID in NUMBER,
  P_OTHER_ID in NUMBER,
  P_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL
) return number;

function Delete_Set_Link_W_Obj_Code (
  p_set_id        in Number,
  p_object_code   in Varchar2,
  p_other_id      in Number
) return number;

function Delete_Set_Link (
  P_LINK_ID in NUMBER
) return number;

procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_LINK_ID in NUMBER,
  X_LINK_TYPE in VARCHAR2,
  X_OBJECT_CODE in VARCHAR2,
  X_SET_ID in NUMBER,
  X_OTHER_ID in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL);

procedure UPDATE_ROW (
  X_LINK_ID in NUMBER,
  X_LINK_TYPE in VARCHAR2,
  X_OBJECT_CODE in VARCHAR2,
  X_SET_ID in NUMBER,
  X_OTHER_ID in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL
);

procedure Raise_Solution_Linked_Event(
   p_set_id NUMBER,
   p_object_code VARCHAR2,
   p_object_id   VARCHAR2,
   p_link_id     NUMBER,
   p_link_type   VARCHAR2,
   p_event_date  DATE );

procedure Raise_Soln_Link_Updated_Event(
   p_set_id            NUMBER,
   p_object_code       VARCHAR2,
   p_object_id         VARCHAR2,
   p_link_id           NUMBER,
   p_link_type         VARCHAR2,
   p_event_date        DATE );

function Create_Set_Link(
  P_OBJECT_CODE in VARCHAR,
  P_SET_ID in NUMBER,
  P_OTHER_ID in NUMBER,
  P_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL
) return number;

end CS_KB_SET_LINKS_PKG;

 

/
