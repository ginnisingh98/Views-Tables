--------------------------------------------------------
--  DDL for Package CSD_RO_BULLETINS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_RO_BULLETINS_PKG" AUTHID CURRENT_USER as
/* $Header: csdtrobs.pls 120.0 2008/01/12 02:24:23 rfieldma noship $ */
-- Start of Comments
-- Package name     : CSD_RO_BULLETINS_PKG
-- Purpose          : Table handler for CSD_RO_BULLETINS
-- History          : Jan-10-2008   rfieldma    created
-- NOTE             :
-- End of Comments
/*--------------------------------------------------*/
/* procedure name: Insert_Row                       */
/* description   : Inserts a row                    */
/*                 CSD_RO_BULLETINS                 */
/* params:    p_RO_BULLETIN_ID  NUMBER  not req     */
/*            p_REPAIR_LINE_ID  NUMBER  not req     */
/*            p_BULLETIN_ID     NUMBER  not req     */
/*            p_LAST_VIEWED_DATE  DATE  not req     */
/*            p_SOURCE_TYPE     VARCHAR2 not req    */
/*            p_SOURCE_ID       NUMBER   not req    */
/*            p_OBJECT_VERSION_NUMBER NUMBER req    */
/*            p_CREATED_BY      NUMBER  req         */
/*            p_CREATION_DATE   DATE    req         */
/*            p_LAST_UPDATED_BY NUMBER  req         */
/*            p_LAST_UPDATE_DATE DATE   req         */
/*            p_LAST_UPDATE_LOGIN       not req     */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Insert_Row(
          px_RO_BULLETIN_ID   IN OUT NOCOPY NUMBER
         ,p_REPAIR_LINE_ID    IN     NUMBER
         ,p_BULLETIN_ID       IN     NUMBER
         ,p_LAST_VIEWED_DATE  IN     DATE
         ,p_LAST_VIEWED_BY    IN     NUMBER
         ,p_SOURCE_TYPE       IN     VARCHAR2
         ,p_SOURCE_ID         IN     NUMBER
         ,p_OBJECT_VERSION_NUMBER IN NUMBER
         ,p_CREATED_BY            IN NUMBER
         ,p_CREATION_DATE         IN DATE
         ,p_LAST_UPDATED_BY       IN NUMBER
         ,p_LAST_UPDATE_DATE      IN DATE
         ,p_LAST_UPDATE_LOGIN     IN NUMBER);

/*--------------------------------------------------*/
/* procedure name: Update_Row                       */
/* description   : Updates a row                    */
/*                 CSD_RO_BULLETINS                 */
/* params:    p_RO_BULLETIN_ID  NUMBER  required    */
/*            p_REPAIR_LINE_ID  NUMBER  not req     */
/*            p_BULLETIN_ID     NUMBER  not req     */
/*            p_LAST_VIEWED_DATE  DATE  not req     */
/*            p_SOURCE_TYPE     VARCHAR2 not req    */
/*            p_SOURCE_ID       VARCHAR2 not req    */
/*            p_OBJECT_VERSION_NUMBER NUMBER req    */
/*            p_CREATED_BY      NUMBER  req         */
/*            p_CREATION_DATE   DATE    req         */
/*            p_LAST_UPDATED_BY NUMBER  req         */
/*            p_LAST_UPDATE_DATE DATE   req         */
/*            p_LAST_UPDATE_LOGIN       not req     */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE Update_Row(
          p_RO_BULLETIN_ID        IN NUMBER
         ,p_REPAIR_LINE_ID        IN NUMBER
         ,p_BULLETIN_ID           IN NUMBER
         ,p_LAST_VIEWED_DATE      IN DATE
         ,p_LAST_VIEWED_BY        IN NUMBER
         ,p_SOURCE_TYPE           IN VARCHAR2
         ,p_SOURCE_ID             IN NUMBER
         ,p_OBJECT_VERSION_NUMBER IN NUMBER
         ,p_CREATED_BY            IN NUMBER
         ,p_CREATION_DATE         IN DATE
         ,p_LAST_UPDATED_BY       IN NUMBER
         ,p_LAST_UPDATE_DATE      IN DATE
         ,p_LAST_UPDATE_LOGIN     IN NUMBER);

/*--------------------------------------------------  */
/* procedure name: Lock_Row                           */
/* description   : Locks ro                           */
/*                 CSD_RO_BULLETINS                   */
/* params:    p_RO_BULLETIN_ID  NUMBER   required     */
/*            p_OBJECT_VERSION_NUMBER NUMBER required */
/*--------------------------------------------------  */
PROCEDURE Lock_Row(
          p_RO_BULLETIN_ID        IN NUMBER
         ,p_OBJECT_VERSION_NUMBER IN NUMBER);

/*-------------------------------------------------- */
/* procedure name: Delete_Row                        */
/* description   : Deletes a row in CSD_RO_BULLETINS */
/* params:    P_RO_BULLETIN_ID  NUMBER  required     */
/*                                                   */
/*-------------------------------------------------- */
PROCEDURE Delete_Row(
    p_RO_BULLETIN_ID IN NUMBER);



END CSD_RO_BULLETINS_PKG;

/
