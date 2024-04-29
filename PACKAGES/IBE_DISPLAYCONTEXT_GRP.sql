--------------------------------------------------------
--  DDL for Package IBE_DISPLAYCONTEXT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_DISPLAYCONTEXT_GRP" AUTHID CURRENT_USER AS
  /* $Header: IBEGCTXS.pls 120.1 2005/06/10 03:47:06 appldev  $ */

g_pkg_name   CONSTANT VARCHAR2(30):='IBE_DisplayContext_GRP';
g_api_version CONSTANT NUMBER       := 1.0;


TYPE display_context_rec_type  IS RECORD (
  Context_delete          VARCHAR2(1),
  Object_Version_Number   NUMBER,
  Context_id              NUMBER,
  Access_name             VARCHAR2(40),
  Display_name            VARCHAR2(80),
  Description             VARCHAR2(240),
  Context_type            VARCHAR2(30),
  Component_type_code     VARCHAR2(30),
  Default_deliverable_id  NUMBER
                                         );

TYPE display_context_tbl_type  IS TABLE OF
  display_context_rec_type INDEX BY BINARY_INTEGER;

PROCEDURE save_display_context(
                               p_api_version           IN  NUMBER,
                               p_init_msg_list    IN   VARCHAR2 := FND_API.g_false,
  p_commit                IN  VARCHAR2  := FND_API.g_false,
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY  NUMBER,
  x_msg_data            OUT NOCOPY  VARCHAR2,
  p_display_context_rec   IN OUT NOCOPY DISPLAY_CONTEXT_REC_TYPE
                              );

PROCEDURE save_delete_display_context(
                                      p_api_version         IN  NUMBER,
                                      p_init_msg_list       IN   VARCHAR2 := FND_API.g_false,
  p_commit              IN  VARCHAR2  := FND_API.g_false,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY  NUMBER,
  x_msg_data            OUT NOCOPY  VARCHAR2,
  p_display_context_tbl IN OUT NOCOPY DISPLAY_CONTEXT_TBL_TYPE
                                     );
PROCEDURE delete_display_context(
                                 p_api_version         IN  NUMBER,
                                 p_init_msg_list       IN  VARCHAR2 := FND_API.g_false,
  p_commit              IN  VARCHAR2 := FND_API.g_false,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY  NUMBER,
  x_msg_data            OUT NOCOPY  VARCHAR2,
  p_display_context_rec IN OUT NOCOPY DISPLAY_CONTEXT_REC_TYPE
                                );

PROCEDURE delete_deliverable(
                             p_deliverable_id      IN  NUMBER
                            );

procedure INSERT_ROW (
                      X_ROWID                   in out NOCOPY   VARCHAR2,
                      X_CONTEXT_ID                      in      NUMBER,
                      X_OBJECT_VERSION_NUMBER   in      NUMBER,
                      X_ACCESS_NAME             in      VARCHAR2,
                      X_CONTEXT_TYPE_CODE               in      VARCHAR2,
                      X_ITEM_ID                         in      NUMBER,
                      X_NAME                    in      VARCHAR2,
                      X_DESCRIPTION             in      VARCHAR2,
                      X_CREATION_DATE           in      DATE,
                      X_CREATED_BY                      in      NUMBER,
                      X_LAST_UPDATE_DATE                in      DATE,
                      X_LAST_UPDATED_BY                 in      NUMBER,
                      X_LAST_UPDATE_LOGIN               in      NUMBER,
                                  X_COMPONENT_TYPE_CODE in VARCHAR2 DEFAULT NULL);

procedure LOCK_ROW (
                    X_CONTEXT_ID                        in      NUMBER,
                    X_OBJECT_VERSION_NUMBER     in      NUMBER,
                    X_ACCESS_NAME               in      VARCHAR2,
                    X_CONTEXT_TYPE_CODE                 in      VARCHAR2,
                    X_ITEM_ID                   in      NUMBER,
                    X_NAME                      in      VARCHAR2,
                    X_DESCRIPTION               in      VARCHAR2
                   );

procedure UPDATE_ROW (
                      X_CONTEXT_ID              in      NUMBER,
                      X_OBJECT_VERSION_NUMBER   in      NUMBER,
                      X_ACCESS_NAME             in      VARCHAR2,
                      X_CONTEXT_TYPE_CODE       in      VARCHAR2,
                      X_ITEM_ID                 in      NUMBER,
                      X_NAME                    in      VARCHAR2,
                      X_DESCRIPTION             in      VARCHAR2,
                      X_LAST_UPDATE_DATE        in      DATE,
                      X_LAST_UPDATED_BY         in      NUMBER,
                      X_LAST_UPDATE_LOGIN       in      NUMBER,
                      X_COMPONENT_TYPE_CODE     in      VARCHAR2 DEFAULT NULL
                     );

procedure DELETE_ROW (
                      X_CONTEXT_ID in NUMBER
                     );

procedure TRANSLATE_ROW (
                         X_CONTEXT_ID           in      NUMBER,
                         X_OWNER                in      VARCHAR2,
                         X_NAME                 in      VARCHAR2,
                         X_DESCRIPTION          in      VARCHAR2,
                         X_LAST_UPDATE_DATE     in      VARCHAR2,
                         X_CUSTOM_MODE          in      VARCHAR2);

procedure LOAD_ROW (
                    X_CONTEXT_ID                in      NUMBER,
                    X_OWNER                     in      VARCHAR2,
                    X_OBJECT_VERSION_NUMBER     in      NUMBER,
                    X_ACCESS_NAME               in      VARCHAR2,
                    X_CONTEXT_TYPE_CODE         in      VARCHAR2,
                    X_ITEM_ID                   in      NUMBER,
                    X_NAME                      in      VARCHAR2,
                    X_DESCRIPTION               in      VARCHAR2,
                    X_LAST_UPDATE_DATE          in      VARCHAR2,
                    X_CUSTOM_MODE               in      VARCHAR2,
                    X_COMPONENT_TYPE_CODE       in      VARCHAR2 DEFAULT NULL);

Procedure LOAD_SEED_ROW(
                        X_CONTEXT_ID                  in VARCHAR2,
                        X_OWNER                       in VARCHAR2,
                        X_OBJECT_VERSION_NUMBER       in VARCHAR2,
                        X_ACCESS_NAME                 in VARCHAR2,
                        X_CONTEXT_TYPE_CODE           in VARCHAR2,
                        X_ITEM_ID                     in VARCHAR2,
                        X_NAME                        in VARCHAR2,
                        X_DESCRIPTION                 in VARCHAR2,
                        X_COMPONENT_TYPE_CODE         in VARCHAR2,
                        X_LAST_UPDATE_DATE            in VARCHAR2,
                        X_CUSTOM_MODE                 in VARCHAR2,
                        X_UPLOAD_MODE                 in VARCHAR2);

PROCEDURE add_language;

END IBE_DisplayContext_GRP;

 

/
