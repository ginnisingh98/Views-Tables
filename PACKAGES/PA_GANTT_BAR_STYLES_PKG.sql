--------------------------------------------------------
--  DDL for Package PA_GANTT_BAR_STYLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_GANTT_BAR_STYLES_PKG" AUTHID CURRENT_USER as
/* $Header: PAGCBSTS.pls 120.1 2005/08/19 16:32:41 mwasowic noship $ */

procedure INSERT_ROW (
  X_ROWID                     in out NOCOPY ROWID, --File.Sql.39 bug 4440895
  X_GANTT_BAR_STYLE_ID        in NUMBER,
  X_GANTT_VIEW_ID             in NUMBER,
  X_DISPLAY_SEQUENCE          in NUMBER,
  X_START_FROM                in VARCHAR2,
  X_END_TO                    in VARCHAR2,
  X_ROW_INDEX                 in NUMBER,
  X_GANTT_BAR_START_SHAPE     in VARCHAR2,
  X_GANTT_BAR_START_COLOR     in NUMBER,
  X_GANTT_BAR_MIDDLE_SHAPE    in VARCHAR2,
  X_GANTT_BAR_MIDDLE_PATTERN  in VARCHAR2,
  X_GANTT_BAR_MIDDLE_COLOR    in NUMBER,
  X_GANTT_BAR_END_SHAPE       in VARCHAR2,
  X_GANTT_BAR_END_COLOR       in NUMBER,
  X_RECORD_VERSION_NUMBER     in NUMBER,
  X_ATTRIBUTE_CATEGORY        in VARCHAR2,
  X_ATTRIBUTE1                in VARCHAR2,
  X_ATTRIBUTE2                in VARCHAR2,
  X_ATTRIBUTE3                in VARCHAR2,
  X_ATTRIBUTE4                in VARCHAR2,
  X_ATTRIBUTE5                in VARCHAR2,
  X_ATTRIBUTE6                in VARCHAR2,
  X_ATTRIBUTE7                in VARCHAR2,
  X_ATTRIBUTE8                in VARCHAR2,
  X_ATTRIBUTE9                in VARCHAR2,
  X_ATTRIBUTE10               in VARCHAR2,
  X_ATTRIBUTE11               in VARCHAR2,
  X_ATTRIBUTE12               in VARCHAR2,
  X_ATTRIBUTE13               in VARCHAR2,
  X_ATTRIBUTE14               in VARCHAR2,
  X_ATTRIBUTE15               in VARCHAR2,
  X_NAME                      in VARCHAR2,
  X_CREATION_DATE             in DATE,
  X_CREATED_BY                in NUMBER,
  X_LAST_UPDATE_DATE          in DATE,
  X_LAST_UPDATED_BY           in NUMBER,
  X_LAST_UPDATE_LOGIN         in NUMBER
  );

procedure LOCK_ROW (
  X_GANTT_BAR_STYLE_ID        in NUMBER,
  X_GANTT_VIEW_ID             in NUMBER,
  X_DISPLAY_SEQUENCE          in NUMBER,
  X_START_FROM                in VARCHAR2,
  X_END_TO                    in VARCHAR2,
  X_ROW_INDEX                 in NUMBER,
  X_GANTT_BAR_START_SHAPE     in VARCHAR2,
  X_GANTT_BAR_START_COLOR     in NUMBER,
  X_GANTT_BAR_MIDDLE_SHAPE    in VARCHAR2,
  X_GANTT_BAR_MIDDLE_PATTERN  in VARCHAR2,
  X_GANTT_BAR_MIDDLE_COLOR    in NUMBER,
  X_GANTT_BAR_END_SHAPE       in VARCHAR2,
  X_GANTT_BAR_END_COLOR       in NUMBER,
  X_RECORD_VERSION_NUMBER     in NUMBER,
  X_ATTRIBUTE_CATEGORY        in VARCHAR2,
  X_ATTRIBUTE1                in VARCHAR2,
  X_ATTRIBUTE2                in VARCHAR2,
  X_ATTRIBUTE3                in VARCHAR2,
  X_ATTRIBUTE4                in VARCHAR2,
  X_ATTRIBUTE5                in VARCHAR2,
  X_ATTRIBUTE6                in VARCHAR2,
  X_ATTRIBUTE7                in VARCHAR2,
  X_ATTRIBUTE8                in VARCHAR2,
  X_ATTRIBUTE9                in VARCHAR2,
  X_ATTRIBUTE10               in VARCHAR2,
  X_ATTRIBUTE11               in VARCHAR2,
  X_ATTRIBUTE12               in VARCHAR2,
  X_ATTRIBUTE13               in VARCHAR2,
  X_ATTRIBUTE14               in VARCHAR2,
  X_ATTRIBUTE15               in VARCHAR2,
  X_NAME                      in VARCHAR2
);

procedure UPDATE_ROW (
  X_GANTT_BAR_STYLE_ID        in NUMBER,
  X_GANTT_VIEW_ID             in NUMBER,
  X_DISPLAY_SEQUENCE          in NUMBER,
  X_START_FROM                in VARCHAR2,
  X_END_TO                    in VARCHAR2,
  X_ROW_INDEX                 in NUMBER,
  X_GANTT_BAR_START_SHAPE     in VARCHAR2,
  X_GANTT_BAR_START_COLOR     in NUMBER,
  X_GANTT_BAR_MIDDLE_SHAPE    in VARCHAR2,
  X_GANTT_BAR_MIDDLE_PATTERN  in VARCHAR2,
  X_GANTT_BAR_MIDDLE_COLOR    in NUMBER,
  X_GANTT_BAR_END_SHAPE       in VARCHAR2,
  X_GANTT_BAR_END_COLOR       in NUMBER,
  X_RECORD_VERSION_NUMBER     in NUMBER,
  X_ATTRIBUTE_CATEGORY        in VARCHAR2,
  X_ATTRIBUTE1                in VARCHAR2,
  X_ATTRIBUTE2                in VARCHAR2,
  X_ATTRIBUTE3                in VARCHAR2,
  X_ATTRIBUTE4                in VARCHAR2,
  X_ATTRIBUTE5                in VARCHAR2,
  X_ATTRIBUTE6                in VARCHAR2,
  X_ATTRIBUTE7                in VARCHAR2,
  X_ATTRIBUTE8                in VARCHAR2,
  X_ATTRIBUTE9                in VARCHAR2,
  X_ATTRIBUTE10               in VARCHAR2,
  X_ATTRIBUTE11               in VARCHAR2,
  X_ATTRIBUTE12               in VARCHAR2,
  X_ATTRIBUTE13               in VARCHAR2,
  X_ATTRIBUTE14               in VARCHAR2,
  X_ATTRIBUTE15               in VARCHAR2,
  X_NAME                      in VARCHAR2,
  X_LAST_UPDATE_DATE          in DATE,
  X_LAST_UPDATED_BY           in NUMBER,
  X_LAST_UPDATE_LOGIN         in NUMBER
);

procedure DELETE_ROW (
  X_GANTT_BAR_STYLE_ID        in NUMBER
);

procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW(
         X_GANTT_BAR_STYLE_ID     in      NUMBER
        ,X_OWNER                  in      VARCHAR2
        ,X_NAME                   in      VARCHAR2
);

procedure LOAD_ROW(
      X_GANTT_BAR_STYLE_ID          in    NUMBER
     ,X_GANTT_VIEW_ID               in    NUMBER
     ,X_DISPLAY_SEQUENCE            in    NUMBER
     ,X_START_FROM                  in    VARCHAR2
     ,X_END_TO                      in    VARCHAR2
     ,X_ROW_INDEX                   in    NUMBER
     ,X_GANTT_BAR_START_SHAPE       in    VARCHAR2
     ,X_GANTT_BAR_START_COLOR       in    NUMBER
     ,X_GANTT_BAR_MIDDLE_SHAPE      in    VARCHAR2
     ,X_GANTT_BAR_MIDDLE_PATTERN    in    VARCHAR2
     ,X_GANTT_BAR_MIDDLE_COLOR      in    NUMBER
     ,X_GANTT_BAR_END_SHAPE         in    VARCHAR2
     ,X_GANTT_BAR_END_COLOR         in    NUMBER
     ,X_RECORD_VERSION_NUMBER       in    NUMBER
     ,X_ATTRIBUTE_CATEGORY          in    VARCHAR2
     ,X_ATTRIBUTE1                  in    VARCHAR2
     ,X_ATTRIBUTE2                  in    VARCHAR2
     ,X_ATTRIBUTE3                  in    VARCHAR2
     ,X_ATTRIBUTE4                  in    VARCHAR2
     ,X_ATTRIBUTE5                  in    VARCHAR2
     ,X_ATTRIBUTE6                  in    VARCHAR2
     ,X_ATTRIBUTE7                  in    VARCHAR2
     ,X_ATTRIBUTE8                  in    VARCHAR2
     ,X_ATTRIBUTE9                  in    VARCHAR2
     ,X_ATTRIBUTE10                 in    VARCHAR2
     ,X_ATTRIBUTE11                 in    VARCHAR2
     ,X_ATTRIBUTE12                 in    VARCHAR2
     ,X_ATTRIBUTE13                 in    VARCHAR2
     ,X_ATTRIBUTE14                 in    VARCHAR2
     ,X_ATTRIBUTE15                 in    VARCHAR2
     ,X_OWNER                       in    VARCHAR2
     ,X_NAME                        in    VARCHAR2
);

end PA_GANTT_BAR_STYLES_PKG;

 

/
