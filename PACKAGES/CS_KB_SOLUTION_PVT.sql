--------------------------------------------------------
--  DDL for Package CS_KB_SOLUTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_KB_SOLUTION_PVT" AUTHID CURRENT_USER AS
/* $Header: cskvsols.pls 120.1.12010000.2 2008/09/12 05:52:58 mmaiya ship $ */

  --for RETURN status
  ERROR_STATUS      CONSTANT NUMBER      := -1;

 --Exceptions
 INVALID_CATEGORY_ID                   EXCEPTION;
 INVALID_SET_CATEGORY_LINK             EXCEPTION;


 PROCEDURE Get_Set_Details(
   P_SET_ID          IN         NUMBER,
   X_SET_NUMBER      OUT NOCOPY VARCHAR2,
   X_STATUS          OUT NOCOPY VARCHAR2,
   X_FLOW_DETAILS_ID OUT NOCOPY NUMBER,
   X_LOCKED_BY       OUT NOCOPY NUMBER );

 FUNCTION Get_Set_Number(
   P_SET_ID IN NUMBER)
 RETURN VARCHAR2;

 FUNCTION Get_Latest_Version_Id(
   P_SET_NUMBER IN VARCHAR2)
 RETURN NUMBER;

 FUNCTION Get_Published_Set_Id(
   P_SET_NUMBER IN VARCHAR2)
 RETURN NUMBER;

 FUNCTION Get_Obsoleted_Set_Id(
   P_SET_NUMBER IN VARCHAR2)
 RETURN NUMBER;

 FUNCTION Get_Solution_Title(
   P_SET_ID IN NUMBER)
 RETURN VARCHAR2;

 FUNCTION Locked_By(
   P_SET_NUMBER IN VARCHAR2)
 RETURN NUMBER;

 FUNCTION Locked_By(
   P_SET_ID IN NUMBER)
 RETURN NUMBER;

 PROCEDURE Outdate_Solution(
   P_SET_NUMBER IN VARCHAR2,
   P_CURRENT_SET_ID IN NUMBER);

 FUNCTION Clone_Solution(
   P_SET_NUMBER      IN VARCHAR2,
   P_STATUS          IN VARCHAR2,
   P_FLOW_DETAILS_ID IN NUMBER,
   P_LOCKED_BY       IN NUMBER )
 RETURN NUMBER; --set_id

 PROCEDURE Get_Lock_Info(
   P_SET_NUMBER IN         VARCHAR2,
   X_LOCKED_BY  OUT NOCOPY NUMBER,
   X_LOCK_DATE  OUT NOCOPY DATE);

-- Api's used in 11.5.10 by OAF:

 PROCEDURE Snatch_Lock_From_User(
   P_SET_ID        IN          NUMBER,
   P_SET_NUMBER    IN          VARCHAR2,
   P_USER_ID       IN          NUMBER,
   P_LOCKED_BY     IN          NUMBER,
   X_RETURN_STATUS OUT NOCOPY  VARCHAR2,
   X_MSG_DATA      OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT     OUT NOCOPY  NUMBER);

 PROCEDURE Create_Solution(
   X_SET_ID             IN OUT NOCOPY  NUMBER,
   P_SET_TYPE_ID        IN             NUMBER,
   P_NAME               IN             VARCHAR2,
   P_STATUS             IN             VARCHAR2 DEFAULT NULL,
   P_ATTRIBUTE_CATEGORY IN             VARCHAR2 DEFAULT NULL,
   P_ATTRIBUTE1         IN             VARCHAR2 DEFAULT NULL,
   P_ATTRIBUTE2         IN             VARCHAR2 DEFAULT NULL,
   P_ATTRIBUTE3         IN             VARCHAR2 DEFAULT NULL,
   P_ATTRIBUTE4         IN             VARCHAR2 DEFAULT NULL,
   P_ATTRIBUTE5         IN             VARCHAR2 DEFAULT NULL,
   P_ATTRIBUTE6         IN             VARCHAR2 DEFAULT NULL,
   P_ATTRIBUTE7         IN             VARCHAR2 DEFAULT NULL,
   P_ATTRIBUTE8         IN             VARCHAR2 DEFAULT NULL,
   P_ATTRIBUTE9         IN             VARCHAR2 DEFAULT NULL,
   P_ATTRIBUTE10        IN             VARCHAR2 DEFAULT NULL,
   P_ATTRIBUTE11        IN             VARCHAR2 DEFAULT NULL,
   P_ATTRIBUTE12        IN             VARCHAR2 DEFAULT NULL,
   P_ATTRIBUTE13        IN             VARCHAR2 DEFAULT NULL,
   P_ATTRIBUTE14        IN             VARCHAR2 DEFAULT NULL,
   P_ATTRIBUTE15        IN             VARCHAR2 DEFAULT NULL,
   X_SET_NUMBER         OUT NOCOPY     VARCHAR2,
   X_RETURN_STATUS      OUT NOCOPY     VARCHAR2,
   X_MSG_DATA           OUT NOCOPY     VARCHAR2,
   X_MSG_COUNT          OUT NOCOPY     NUMBER,
   P_VISIBILITY_ID      IN             NUMBER DEFAULT NULL );

 PROCEDURE Update_Solution(
   P_SET_ID             IN         NUMBER,
   P_SET_NUMBER         IN         VARCHAR2,
   P_SET_TYPE_ID        IN         NUMBER,
   P_NAME               IN         VARCHAR2,
   P_STATUS             IN         VARCHAR2,
   P_ATTRIBUTE_CATEGORY IN         VARCHAR2,
   P_ATTRIBUTE1         IN         VARCHAR2,
   P_ATTRIBUTE2         IN         VARCHAR2,
   P_ATTRIBUTE3         IN         VARCHAR2,
   P_ATTRIBUTE4         IN         VARCHAR2,
   P_ATTRIBUTE5         IN         VARCHAR2,
   P_ATTRIBUTE6         IN         VARCHAR2,
   P_ATTRIBUTE7         IN         VARCHAR2,
   P_ATTRIBUTE8         IN         VARCHAR2,
   P_ATTRIBUTE9         IN         VARCHAR2,
   P_ATTRIBUTE10        IN         VARCHAR2,
   P_ATTRIBUTE11        IN         VARCHAR2,
   P_ATTRIBUTE12        IN         VARCHAR2,
   P_ATTRIBUTE13        IN         VARCHAR2,
   P_ATTRIBUTE14        IN         VARCHAR2,
   P_ATTRIBUTE15        IN         VARCHAR2,
   X_RETURN_STATUS      OUT NOCOPY VARCHAR2,
   X_MSG_DATA           OUT NOCOPY VARCHAR2,
   X_MSG_COUNT          OUT NOCOPY NUMBER,
   P_VISIBILITY_ID      IN         NUMBER DEFAULT NULL );


 PROCEDURE Submit_Solution(
   P_SET_NUMBER     IN         VARCHAR2,
   P_SET_ID         IN         NUMBER ,
   P_NEW_STEP       IN         NUMBER ,
   X_RETURN         OUT NOCOPY NUMBER,
   X_RETURN_STATUS  OUT NOCOPY VARCHAR2,
   X_MSG_DATA       OUT NOCOPY VARCHAR2,
   X_MSG_COUNT      OUT NOCOPY NUMBER );

 FUNCTION Get_User_Soln_Access (
   P_SET_ID     IN NUMBER,
   P_SET_NUMBER IN VARCHAR2 )
 RETURN VARCHAR2;

 PROCEDURE CheckOut_Solution(
   P_SET_ID         IN         NUMBER ,
   X_RETURN_STATUS  OUT NOCOPY VARCHAR2,
   X_MSG_DATA       OUT NOCOPY VARCHAR2,
   X_MSG_COUNT      OUT NOCOPY NUMBER );

 PROCEDURE Move_Solutions(
   p_api_version        in number,
   p_init_msg_list      in varchar2   := FND_API.G_FALSE,
   p_commit             in varchar2   := FND_API.G_FALSE,
   p_validation_level   in number     := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY varchar2,
   x_msg_count          OUT NOCOPY number,
   x_msg_data           OUT NOCOPY varchar2,
   P_SET_IDS        IN  JTF_NUMBER_TABLE,
   P_SRC_CAT_ID     IN  NUMBER,
   P_DEST_CAT_ID    IN  NUMBER
);

--Start Bugfix 7117546
PROCEDURE unlock_solution
   (
      p_set_id IN NUMBER,
      p_commit IN VARCHAR2 DEFAULT 'N',
      x_return_status OUT NOCOPY VARCHAR2,
      x_msg_data      OUT NOCOPY VARCHAR2,
      x_msg_count     OUT NOCOPY NUMBER);

--End Bugfix 7117546

END CS_KB_SOLUTION_PVT;

/
