--------------------------------------------------------
--  DDL for Package PA_GANTT_VIEWS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_GANTT_VIEWS_PKG" AUTHID CURRENT_USER as
/* $Header: PAGCGVTS.pls 120.1 2005/08/19 16:33:15 mwasowic noship $ */

procedure INSERT_ROW (
  X_ROWID                     in out NOCOPY ROWID --File.Sql.39 bug 4440895
 ,X_GANTT_VIEW_ID             in NUMBER
 ,X_GANTT_VIEW_USAGE          in VARCHAR2
 ,X_ENABLE_FLAG               in VARCHAR2
 ,X_SHOW_SUMMARY_ROOT_FLAG    in VARCHAR2
 ,X_SHOW_DEPENDENCIES_FLAG    in VARCHAR2
 ,X_SHOW_SPLIT_TASK_FLAG      in VARCHAR2
 ,X_BAR_HEIGHT                in NUMBER
 ,X_TABLE_BACKGROUND          in NUMBER
 ,X_TABLE_FOREGROUND          in NUMBER
 ,X_CHART_BACKGROUND          in NUMBER
 ,X_COMPARISON_FLAG           in VARCHAR2
 ,X_GANTT_BAR_TEXT_LEFT       in VARCHAR2
 ,X_GANTT_BAR_TEXT_RIGHT      in VARCHAR2
 ,X_GANTT_BAR_TEXT_TOP        in VARCHAR2
 ,X_GANTT_BAR_TEXT_BOTTOM     in VARCHAR2
 ,X_GANTT_BAR_TEXT_INSIDE     in VARCHAR2
 ,X_RECORD_VERSION_NUMBER     in NUMBER
 ,X_ATTRIBUTE_CATEGORY        in VARCHAR2
 ,X_ATTRIBUTE1                in VARCHAR2
 ,X_ATTRIBUTE2                in VARCHAR2
 ,X_ATTRIBUTE3                in VARCHAR2
 ,X_ATTRIBUTE4                in VARCHAR2
 ,X_ATTRIBUTE5                in VARCHAR2
 ,X_ATTRIBUTE6                in VARCHAR2
 ,X_ATTRIBUTE7                in VARCHAR2
 ,X_ATTRIBUTE8                in VARCHAR2
 ,X_ATTRIBUTE9                in VARCHAR2
 ,X_ATTRIBUTE10               in VARCHAR2
 ,X_ATTRIBUTE11               in VARCHAR2
 ,X_ATTRIBUTE12               in VARCHAR2
 ,X_ATTRIBUTE13               in VARCHAR2
 ,X_ATTRIBUTE14               in VARCHAR2
 ,X_ATTRIBUTE15               in VARCHAR2
 ,X_NAME                      in VARCHAR2
 ,X_DESCRIPTION               in VARCHAR2
 ,X_CREATION_DATE             in DATE
 ,X_CREATED_BY                in NUMBER
 ,X_LAST_UPDATE_DATE          in DATE
 ,X_LAST_UPDATED_BY           in NUMBER
 ,X_LAST_UPDATE_LOGIN         in NUMBER
 );

procedure LOCK_ROW (
  X_GANTT_VIEW_ID             in NUMBER,
  X_GANTT_VIEW_USAGE          in VARCHAR2,
  X_ENABLE_FLAG               in VARCHAR2,
  X_SHOW_SUMMARY_ROOT_FLAG    in VARCHAR2,
  X_SHOW_DEPENDENCIES_FLAG    in VARCHAR2,
  X_SHOW_SPLIT_TASK_FLAG      in VARCHAR2,
  X_BAR_HEIGHT                in NUMBER,
  X_TABLE_BACKGROUND          in NUMBER,
  X_TABLE_FOREGROUND          in NUMBER,
  X_CHART_BACKGROUND          in NUMBER,
  X_COMPARISON_FLAG           in VARCHAR2,
  X_GANTT_BAR_TEXT_LEFT       in VARCHAR2,
  X_GANTT_BAR_TEXT_RIGHT      in VARCHAR2,
  X_GANTT_BAR_TEXT_TOP        in VARCHAR2,
  X_GANTT_BAR_TEXT_BOTTOM     in VARCHAR2,
  X_GANTT_BAR_TEXT_INSIDE     in VARCHAR2,
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
  X_DESCRIPTION               in VARCHAR2
);

procedure UPDATE_ROW (
  X_GANTT_VIEW_ID             in NUMBER,
  X_GANTT_VIEW_USAGE          in VARCHAR2,
  X_ENABLE_FLAG               in VARCHAR2,
  X_SHOW_SUMMARY_ROOT_FLAG    in VARCHAR2,
  X_SHOW_DEPENDENCIES_FLAG    in VARCHAR2,
  X_SHOW_SPLIT_TASK_FLAG      in VARCHAR2,
  X_BAR_HEIGHT                in NUMBER,
  X_TABLE_BACKGROUND          in NUMBER,
  X_TABLE_FOREGROUND          in NUMBER,
  X_CHART_BACKGROUND          in NUMBER,
  X_COMPARISON_FLAG           in VARCHAR2,
  X_GANTT_BAR_TEXT_LEFT       in VARCHAR2,
  X_GANTT_BAR_TEXT_RIGHT      in VARCHAR2,
  X_GANTT_BAR_TEXT_TOP        in VARCHAR2,
  X_GANTT_BAR_TEXT_BOTTOM     in VARCHAR2,
  X_GANTT_BAR_TEXT_INSIDE     in VARCHAR2,
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
  X_DESCRIPTION               in VARCHAR2,
  X_LAST_UPDATE_DATE          in DATE,
  X_LAST_UPDATED_BY           in NUMBER,
  X_LAST_UPDATE_LOGIN         in NUMBER
);

procedure DELETE_ROW (
  X_GANTT_VIEW_ID             in NUMBER
);

procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW(
         X_GANTT_VIEW_ID            in    NUMBER
        ,X_OWNER                    in    VARCHAR2
        ,X_NAME                     in    VARCHAR2
        ,X_DESCRIPTION              in    VARCHAR2
);

procedure LOAD_ROW(
         X_GANTT_VIEW_ID             in   NUMBER
        ,X_GANTT_VIEW_USAGE          in   VARCHAR2
        ,X_COMPARISON_FLAG           in   VARCHAR2
        ,X_ENABLE_FLAG               in   VARCHAR2
        ,X_SHOW_SUMMARY_ROOT_FLAG    in   VARCHAR2
        ,X_SHOW_DEPENDENCIES_FLAG    in   VARCHAR2
        ,X_SHOW_SPLIT_TASK_FLAG      in   VARCHAR2
        ,X_BAR_HEIGHT                in   NUMBER
        ,X_TABLE_BACKGROUND          in   NUMBER
        ,X_TABLE_FOREGROUND          in   NUMBER
        ,X_CHART_BACKGROUND          in   NUMBER
        ,X_GANTT_BAR_TEXT_LEFT       in   VARCHAR2
        ,X_GANTT_BAR_TEXT_RIGHT      in   VARCHAR2
        ,X_GANTT_BAR_TEXT_TOP        in   VARCHAR2
        ,X_GANTT_BAR_TEXT_BOTTOM     in   VARCHAR2
        ,X_GANTT_BAR_TEXT_INSIDE     in   VARCHAR2
        ,X_RECORD_VERSION_NUMBER     in   NUMBER
        ,X_ATTRIBUTE_CATEGORY        in   VARCHAR2
        ,X_ATTRIBUTE1                in   VARCHAR2
        ,X_ATTRIBUTE2                in   VARCHAR2
        ,X_ATTRIBUTE3                in   VARCHAR2
        ,X_ATTRIBUTE4                in   VARCHAR2
        ,X_ATTRIBUTE5                in   VARCHAR2
        ,X_ATTRIBUTE6                in   VARCHAR2
        ,X_ATTRIBUTE7                in   VARCHAR2
        ,X_ATTRIBUTE8                in   VARCHAR2
        ,X_ATTRIBUTE9                in   VARCHAR2
        ,X_ATTRIBUTE10               in   VARCHAR2
        ,X_ATTRIBUTE11               in   VARCHAR2
        ,X_ATTRIBUTE12               in   VARCHAR2
        ,X_ATTRIBUTE13               in   VARCHAR2
        ,X_ATTRIBUTE14               in   VARCHAR2
        ,X_ATTRIBUTE15               in   VARCHAR2
        ,X_OWNER                     in   VARCHAR2
        ,X_NAME                      in   VARCHAR2
        ,X_DESCRIPTION               in   VARCHAR2
);

end PA_GANTT_VIEWS_PKG;

 

/