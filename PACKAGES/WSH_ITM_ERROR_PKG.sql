--------------------------------------------------------
--  DDL for Package WSH_ITM_ERROR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_ITM_ERROR_PKG" AUTHID CURRENT_USER AS
   /* $Header: WSHITERS.pls 115.2 2002/12/12 12:02:19 bradha ship $ */

 /*----------------------------------------------------------*/
 /* Insert_Row Procedure                                     */
 /*----------------------------------------------------------*/

 PROCEDURE Insert_Row
 (
   p_api_version        IN      NUMBER                          ,
   p_init_msg_list      IN      VARCHAR2 := fnd_api.g_false     ,
   p_commit             IN      VARCHAR2 := fnd_api.g_false     ,
   x_return_status      OUT NOCOPY      VARCHAR2                        ,
   x_msg_count          OUT NOCOPY      NUMBER                          ,
   x_msg_data           OUT NOCOPY      VARCHAR2                        ,
   p_VENDOR_ID          IN      NUMBER,
   p_VENDOR             IN      VARCHAR2,
   p_ERROR_TYPE         IN      VARCHAR2,
   p_ERROR_CODE         IN      VARCHAR2,
   p_INTERPRETED_CODE         IN      VARCHAR2,
   X_ROWID              OUT NOCOPY     VARCHAR2
  );

 /*----------------------------------------------------------*/
 /* Update_Row Procedure                                     */
 /*----------------------------------------------------------*/

PROCEDURE Update_Row
 (
   p_api_version        IN      NUMBER                          ,
   p_init_msg_list      IN      VARCHAR2 := fnd_api.g_false     ,
   p_commit             IN      VARCHAR2 := fnd_api.g_false     ,
   x_return_status      OUT NOCOPY      VARCHAR2                        ,
   x_msg_count          OUT NOCOPY      NUMBER                          ,
   x_msg_data           OUT NOCOPY      VARCHAR2                        ,
   p_VENDOR_ID          IN      NUMBER,
   p_VENDOR             IN      VARCHAR2,
   p_ERROR_TYPE         IN      VARCHAR2,
   p_ERROR_CODE         IN      VARCHAR2,
   p_INTERPRETED_CODE   IN      VARCHAR2,
   p_ROWID              IN      VARCHAR2
  );

 /*----------------------------------------------------------*/
 /* Delete_Row Procedure                                     */
 /*----------------------------------------------------------*/

 PROCEDURE Delete_Row
 (
   p_api_version        IN      NUMBER                          ,
   p_init_msg_list      IN      VARCHAR2 := fnd_api.g_false     ,
   p_commit             IN      VARCHAR2 := fnd_api.g_false     ,
   x_return_status      OUT NOCOPY      VARCHAR2                        ,
   x_msg_count          OUT NOCOPY      NUMBER                          ,
   x_msg_data           OUT NOCOPY      VARCHAR2                        ,
   p_rowid              IN      VARCHAR2
  );


 /*----------------------------------------------------------*/
 /* Lock_Row Procedure                                       */
 /*----------------------------------------------------------*/

 PROCEDURE Lock_Row
 (
   p_api_version        IN      NUMBER                          ,
   p_init_msg_list      IN      VARCHAR2 := fnd_api.g_false     ,
   p_commit             IN      VARCHAR2 := fnd_api.g_false     ,
   x_return_status      OUT NOCOPY      VARCHAR2                        ,
   x_msg_count          OUT NOCOPY      NUMBER                          ,
   x_msg_data           OUT NOCOPY      VARCHAR2                        ,
   p_VENDOR_ID               IN  NUMBER,
   p_VENDOR             IN      VARCHAR2,
   p_ERROR_TYPE         IN      VARCHAR2,
   p_ERROR_CODE         IN      VARCHAR2,
   p_INTERPRETED_CODE         IN      VARCHAR2,
   P_ROWID              IN    VARCHAR2
  );

END WSH_ITM_ERROR_PKG;

 

/
